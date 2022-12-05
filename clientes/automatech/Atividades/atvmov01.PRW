#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ATVMOV01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 30/07/2012                                                          *
// Objetivo..: Programa de Movimentação de Atividades                              *
//**********************************************************************************

User Function ATVMOV01()

   // Declara as variáveis privadas do programa

   // Declara as Legendas dos Status
   Private oVerde    := LoadBitmap(GetResources(),'br_verde')    // Executado Antes do Prazo
   Private oVermelho := LoadBitmap(GetResources(),'br_vermelho') // Executado Fora do Prazo
   Private oAzul     := LoadBitmap(GetResources(),'br_azul')     // Executado no Prazo
   Private oAmarelo  := LoadBitmap(GetResources(),'br_amarelo')  // Vencida e não Executada
   Private oLaranja  := LoadBitmap(GetResources(),'br_laranja')  // Aguardando Aprovação do Supervisor
   Private oBranco   := LoadBitmap(GetResources(),'br_branco')   // Atividade Encerrada
   Private oPreto    := LoadBitmap(GetResources(),'br_preto')    // Disponível
   Private oCinza    := LoadBitmap(GetResources(),'br_cinza')    // Disponível

   Private aComboBx2	 := {"01","02","03","04","05","06","07","08","09","10","11","12"}
   Private aComboBx3	 := {"2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019", "2020", "2021", "2022", "2023", "2024", "2025"}
   Private aComboBx4	 := {}
   Private aComboBx6	 := {}
   Private aComboBx7	 := {}
   Private cDetalhes     := ""
   Private cProblema     := ""
   Private cMelhoria     := ""

   Private cComboBx2 
   Private cComboBx3 
   Private cComboBx4
   Private cComboBx6
   Private cComboBx7
   Private oMemo1
   Private oMemo2
   Private oMemo3

   Private aBrowse := {}
   
   // Inicializa o Array aBrowse
   aAdd( aBrowse, { '','','','','','','','','','','', '' } )

   Private oDlg

   // Carrega o array dos meses
   aComboBx2 := {"01","02","03","04","05","06","07","08","09","10","11","12"}

   // Carrega o array dos anos
   aComboBx3 := {"2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019", "2020", "2021", "2022", "2023", "2024", "2025"}

   // Carrega o Combo de Áreas
   If Select("T_AREAS") > 0
      T_AREAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZR_CODIGO , "
   cSql += "       ZZR_NOME     "
   cSql += "  FROM " + RetSqlName("ZZR")
   cSql += " WHERE ZZR_DELETE = ''"
   cSql += " ORDER BY ZZR_NOME  "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AREAS", .T., .T. )

   If T_AREAS->( EOF() )
      MsgAlert("Cadastro de Áreas está vazio.")
      Return .T.
   Endif

   T_AREAS->( DbGoTop() )
   WHILE !T_AREAS->( EOF() )
      aAdd(aComboBx7, T_AREAS->ZZR_CODIGO + " - " + Alltrim(T_AREAS->ZZR_NOME) )
      T_AREAS->( DbSkip() )
   ENDDO   

   // Carrega o Array dos Status
   aComboBx4 := {"00 - Todos os Status", "01 - Antes do Prazo", "02 - Fora do Prazo", "03 - Executado no Prazo", "04 - Vencidas e não Executadas", "05 - No Prazo e não Executadas"}

   // Carrega o array de Usuários

   // Primeiro verifica o tipo de usuário que está logado
   If Select("T_TIPO") > 0
      T_TIPO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZT_USUA, "
   cSql += "       ZZT_NOMS, "
   cSql += "       ZZT_ADM , "
   cSql += "       ZZT_SUPE, "
   cSql += "       ZZT_NORM  "  
   cSql += "  FROM " + RetSqlName("ZZT")
   cSql += " WHERE ZZT_DELETE = ''"
   cSql += "   AND ZZT_USUA   = '" + Alltrim(UPPER(cUserName)) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TIPO", .T., .T. )
   
   IF T_TIPO->( EOF() )
      MsgAlert("Usuário sem permissão para realizar esta consulta ou usuário não cadastrado.")
      Return .T.
   Endif

   // Pesquisa os usuários conforme o tipo de usuário logado
   If Select("T_USUARIOS") > 0
      T_USUARIOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZT_USUA , "
   cSql += "       ZZT_NOMS   "
   cSql += "  FROM " + RetSqlName("ZZT")

   // Usuário do Tipo ADM
   If T_TIPO->ZZT_ADM == "T"
      cSql += " WHERE ZZT_DELETE = ''"
   Endif
      
   // Usuário do Tipo Supervisor
   If T_TIPO->ZZT_SUPE == "T"
      cSql += " WHERE ZZT_DELETE = ''"
      cSql += "   AND ZZT_RESP   = '" + Alltrim(UPPER(cUserName)) + "'"
   Endif
      
   // Usuário do Tipo ADM
   If T_TIPO->ZZT_NORM == "T"
      cSql += " WHERE ZZT_DELETE = ''"
      cSql += "   AND ZZT_USUA   = '" + Alltrim(UPPER(cUserName)) + "'"
   Endif
      
   cSql += " ORDER BY ZZT_NOMS "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIOS", .T., .T. )

   If T_USUARIOS->( EOF() )
      MsgAlert("Cadastro de Usuários está vazio.")
      Return .T.
   Endif

   T_USUARIOS->( DbGoTop() )
   WHILE !T_USUARIOS->( EOF() )
      aAdd(aComboBx6, T_USUARIOS->ZZT_USUA)
      T_USUARIOS->( DbSkip() )
   ENDDO   
                                
   DEFINE MSDIALOG oDlg TITLE "Movimentos de Atividades" FROM C(178),C(181) TO C(617),C(967) PIXEL

   @ C(004),C(006) Say "Mês"     Size C(011),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(004),C(036) Say "Ano"     Size C(012),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(004),C(067) Say "Área"    Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(004),C(176) Say "Status"  Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(004),C(278) Say "Usuário" Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(114),C(006) Say "Detalhes da Atividade"                          Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(149),C(006) Say "Problemas apontados para execusão da atividade" Size C(120),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(149),C(198) Say "Sugestão de melhorias para a atividade"         Size C(120),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(005) ComboBox cComboBx2 Items aComboBx2 Size C(024),C(010) PIXEL OF oDlg
   @ C(014),C(034) ComboBox cComboBx3 Items aComboBx3 Size C(030),C(010) PIXEL OF oDlg
   @ C(014),C(067) ComboBox cComboBx7 Items aComboBx7 Size C(105),C(010) PIXEL OF oDlg
   @ C(014),C(176) ComboBox cComboBx4 Items aComboBx4 Size C(097),C(010) PIXEL OF oDlg
   @ C(014),C(277) ComboBox cComboBx6 Items aComboBx6 Size C(110),C(010) PIXEL OF oDlg

   @ C(124),C(005) GET oMemo3 Var cDetalhes MEMO Size C(381),C(024) PIXEL OF oDlg
   @ C(159),C(005) GET oMemo1 Var cProblema MEMO Size C(191),C(040) PIXEL OF oDlg
   @ C(159),C(198) GET oMemo2 Var cMelhoria MEMO Size C(188),C(040) PIXEL OF oDlg

   @ C(204),C(005) Button "Atualizar" Size C(037),C(012) PIXEL OF oDlg ACTION( PesqMovim() )
   @ C(204),C(179) Button "Leganda"   Size C(037),C(012) PIXEL OF oDlg ACTION(__Legendas() )
   @ C(204),C(271) Button "Alterar"   Size C(037),C(012) PIXEL OF oDlg ACTION( CHAMAATIV(aBrowse[oBrowse:nAt,02], Substr(cComboBx7,01,06), aBrowse[oBrowse:nAt,10] ))
   @ C(204),C(349) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Cria o objeto grid
   oBrowse := TCBrowse():New( 033 , 005, 490, 110,,{'L','Codigo', 'Atividade', 'Descrição das Atividades', 'Agenda', 'Início', 'Final' , 'Realizado', 'Supervisão', 'Registro'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oCinza   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho, oBranco)))))))),;                         
                         aBrowse[oBrowse:nAt,02]               ,;
                         aBrowse[oBrowse:nAt,03]               ,;
                         aBrowse[oBrowse:nAt,04]               ,;                         
                         aBrowse[oBrowse:nAt,05]               ,;                         
                         aBrowse[oBrowse:nAt,06]               ,;                         
                         aBrowse[oBrowse:nAt,07]               ,;                         
                         aBrowse[oBrowse:nAt,08]               ,;                         
                         aBrowse[oBrowse:nAt,09]               ,;                         
                         aBrowse[oBrowse:nAt,10]               }}
      
   oBrowse:bLDblClick := {|| MOSTRADET(aBrowse[oBrowse:nAt,10]) } 

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que chama a tela de alteração da atividade
Static Function CHAMAATIV(xAtividade, xArea, xRegistro)

   cDetalhes := ""
   cProblema := ""
   cMelhoria := ""

   oMemo1:Refresh()
   oMemo2:Refresh()   
   oMemo3:Refresh()   

   U_ATVMOV02(xAtividade, xArea, xRegistro)

   PesqMovim()
   
Return .T.   

// Função que mostra os detalhes da atividade selecionada
Static Function MOSTRADET(nRegistro)

   Local cSql := ""

   If Select("T_REAL") > 0
      T_REAL->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZZX_PROB)) AS PROBLEMA,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZZX_MELH)) AS MELHORAS," 
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), B.ZZU_DETA)) AS DETALHES "
   cSql += "  FROM " + RetSqlName("ZZX") + " A, "
   cSql += "       " + RetSqlName("ZZU") + " B  "
   cSql += " WHERE A.R_E_C_N_O_ = '" + Alltrim(nRegistro) + "'"
   cSql += "   AND A.ZZX_ATIV   = B.ZZU_CODIGO"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_REAL", .T., .T. )

   If T_REAL->( EOF() )
      cDetalhes := ""
      cProblema := ""
      cMelhoria := ""
   Else
      cDetalhes := T_REAL->DETALHES
      cProblema := T_REAL->PROBLEMA
      cMelhoria := T_REAL->MELHORAS
   Endif

   oMemo1:Refresh()
   oMemo2:Refresh()   
   oMemo3:Refresh()   
   
Return .T.               

// Função que carrega o grid conforme os parâmetros informados
Static Function PESQMOVIM()

   Local cSql    := ""
   Local cStatus := ""

   aBrowse := {}

   // Pesquisar aqui os dados a última pesquisa do usuário para ser restaurado
   If Select("T_MOVIMENTOS") > 0
      T_MOVIMENTOS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT A.ZZX_FILIAL,"
   cSql += "       A.ZZX_CODIGO,"
   cSql += "       A.ZZX_MES   ,"
   cSql += "       A.ZZX_ANO   ,"
   cSql += "       A.ZZX_USUA  ,"
   cSql += "       A.ZZX_STAT  ,"
   cSql += "       A.ZZX_ATIV  ,"
   cSql += "       A.ZZX_DAT1  ,"
   cSql += "       A.ZZX_DAT2  ,"
   cSql += "       A.ZZX_REAL  ,"
   cSql += "       A.ZZX_ALCA  ,"
   cSql += "       A.ZZX_ATR1  ,"
   cSql += "       A.ZZX_ATR2  ,"
   cSql += "       A.ZZX_SEMA  ,"
   cSql += "       A.R_E_C_N_O_ AS REGISTRO,"
   cSql += "       B.ZZU_NOME   "
   cSql += "  FROM " + RetSqlName("ZZX") + " A, "
   cSql += "       " + RetSqlName("ZZU") + " B  "
   cSql += " WHERE A.ZZX_DELETE = ''"
   cSql += "   AND A.ZZX_STAT   = 'A'
   cSql += "   AND A.ZZX_USUA   = '" + Alltrim(cComboBx6) + "'"
   cSql += "   AND A.ZZX_MES    = '" + Alltrim(Str(Int(val(cComboBx2)))) + "'"
   cSql += "   AND A.ZZX_ANO    = '" + Alltrim(Str(Int(val(cComboBx3)))) + "'"
   cSql += "   AND A.ZZX_ATIV   = B.ZZU_CODIGO"
   cSql += "   AND B.ZZU_DELETE = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MOVIMENTOS", .T., .T. )

   If T_MOVIMENTOS->( EOF() )
      MsgAlert("Não existem dados a serem visualizados para estes parâmetros.")
      aBrowse := {}
   Else
      T_MOVIMENTOS->( DbGoTop() )
      WHILE !T_MOVIMENTOS->( EOF() )

         // Calcula o Status da Atividade
         
         // Executado
         If !Empty(Ctod(Substr(T_MOVIMENTOS->ZZX_REAL,07,02) + "/" + Substr(T_MOVIMENTOS->ZZX_REAL,05,02) + "/" + Substr(T_MOVIMENTOS->ZZX_REAL,01,04))) 

            // VERDE - Executado Antes do Prazo
            If Ctod(Substr(T_MOVIMENTOS->ZZX_REAL,07,02) + "/" + Substr(T_MOVIMENTOS->ZZX_REAL,05,02) + "/" + Substr(T_MOVIMENTOS->ZZX_REAL,01,04)) < ; 
               Ctod(Substr(T_MOVIMENTOS->ZZX_DAT2,07,02) + "/" + Substr(T_MOVIMENTOS->ZZX_DAT2,05,02) + "/" + Substr(T_MOVIMENTOS->ZZX_DAT2,01,04))
               cStatus := "2"
            Endif

            // AZUL - Executado no Prazo
            If Ctod(Substr(T_MOVIMENTOS->ZZX_REAL,07,02) + "/" + Substr(T_MOVIMENTOS->ZZX_REAL,05,02) + "/" + Substr(T_MOVIMENTOS->ZZX_REAL,01,04)) == ; 
               Ctod(Substr(T_MOVIMENTOS->ZZX_DAT2,07,02) + "/" + Substr(T_MOVIMENTOS->ZZX_DAT2,05,02) + "/" + Substr(T_MOVIMENTOS->ZZX_DAT2,01,04))
               cStatus := "5"
            Endif
               
            // VERMELHO - Excutado Fora do Prazo
            If Ctod(Substr(T_MOVIMENTOS->ZZX_REAL,07,02) + "/" + Substr(T_MOVIMENTOS->ZZX_REAL,05,02) + "/" + Substr(T_MOVIMENTOS->ZZX_REAL,01,04)) > ; 
               Ctod(Substr(T_MOVIMENTOS->ZZX_DAT2,07,02) + "/" + Substr(T_MOVIMENTOS->ZZX_DAT2,05,02) + "/" + Substr(T_MOVIMENTOS->ZZX_DAT2,01,04))
               cStatus := "8"
            Endif

         Else

            // AMARELO - Vencida e não Executada
            If Ctod(Substr(T_MOVIMENTOS->ZZX_DAT2,07,02) + "/" + Substr(T_MOVIMENTOS->ZZX_DAT2,05,02) + "/" + Substr(T_MOVIMENTOS->ZZX_DAT2,01,04)) < Date()
               cStatus := "4"
            Endif
            
            // BRANCO - No Prazo não Executado
            If Ctod(Substr(T_MOVIMENTOS->ZZX_DAT2,07,02) + "/" + Substr(T_MOVIMENTOS->ZZX_DAT2,05,02) + "/" + Substr(T_MOVIMENTOS->ZZX_DAT2,01,04)) > Date()
               cStatus := "1"
            Endif

         Endif

         // Executadas Antes do Prazo
         If Substr(cComboBx4,01,02) == "01"
            If cStatus <> "2"
               T_MOVIMENTOS->( DbSkip() )               
               Loop
            Endif
         Endif
               
         // Executadas Fora do Prazo
         If Substr(cComboBx4,01,02) == "02"
            If cStatus <> "8"
               T_MOVIMENTOS->( DbSkip() )               
               Loop
            Endif
         Endif

         // Executadas no Prazo
         If Substr(cComboBx4,01,02) == "03"
            If cStatus <> "5"
               T_MOVIMENTOS->( DbSkip() )               
               Loop
            Endif
         Endif

         // Vencidas e não executadas
         If Substr(cComboBx4,01,02) == "04"
            If cStatus <> "4"
               T_MOVIMENTOS->( DbSkip() )               
               Loop
            Endif
         Endif

         // No prazo e não executadas
         If Substr(cComboBx4,01,02) == "05"
            If cStatus <> "1"
               T_MOVIMENTOS->( DbSkip() )               
               Loop
            Endif
         Endif

         // Carrega o array aBrowse com os dados pesquisados
         aAdd( aBrowse, { cStatus                          ,;
                          Alltrim(T_MOVIMENTOS->ZZX_CODIGO),;
                          Alltrim(T_MOVIMENTOS->ZZX_ATIV)  ,;
                          T_MOVIMENTOS->ZZU_NOME           ,;
                          T_MOVIMENTOS->ZZX_SEMA           ,;
                          Substr(T_MOVIMENTOS->ZZX_DAT1,07,02) + "/" + Substr(T_MOVIMENTOS->ZZX_DAT1,05,02) + "/" + Substr(T_MOVIMENTOS->ZZX_DAT1,01,04) ,;
                          Substr(T_MOVIMENTOS->ZZX_DAT2,07,02) + "/" + Substr(T_MOVIMENTOS->ZZX_DAT2,05,02) + "/" + Substr(T_MOVIMENTOS->ZZX_DAT2,01,04) ,;
                          Substr(T_MOVIMENTOS->ZZX_REAL,07,02) + "/" + Substr(T_MOVIMENTOS->ZZX_REAL,05,02) + "/" + Substr(T_MOVIMENTOS->ZZX_REAL,01,04) ,;
                          Substr(T_MOVIMENTOS->ZZX_ALCA,07,02) + "/" + Substr(T_MOVIMENTOS->ZZX_ALCA,05,02) + "/" + Substr(T_MOVIMENTOS->ZZX_ALCA,01,04) ,;
                          STRZERO(T_MOVIMENTOS->REGISTRO,06)})
         T_MOVIMENTOS->( DbSkip() )
      ENDDO
   Endif      
       
   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oCinza   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho, oBranco)))))))),;                         
                         aBrowse[oBrowse:nAt,02]               ,;
                         aBrowse[oBrowse:nAt,03]               ,;
                         aBrowse[oBrowse:nAt,04]               ,;                         
                         aBrowse[oBrowse:nAt,05]               ,;                         
                         aBrowse[oBrowse:nAt,06]               ,;                         
                         aBrowse[oBrowse:nAt,07]               ,;                         
                         aBrowse[oBrowse:nAt,08]               ,;                         
                         aBrowse[oBrowse:nAt,09]               ,;                         
                         aBrowse[oBrowse:nAt,10]               } }
      
   oBrowse:bLDblClick := {|| MOSTRADET(aBrowse[oBrowse:nAt,10]) } 

Return .T.

// Função que abre a janela das Legendas de Movimentação das Atividades
Static Function __Legendas()

   Local aLegenda  := {}
   Local oVerde    := LoadBitmap(GetResources(),'br_verde')    // Executado Antes do Prazo
   Local oVermelho := LoadBitmap(GetResources(),'br_vermelho') // Executado Fora do Prazo
   Local oAzul     := LoadBitmap(GetResources(),'br_azul')     // Executado no Prazo
   Local oAmarelo  := LoadBitmap(GetResources(),'br_amarelo')  // Vencida e não Executada
   Local oLaranja  := LoadBitmap(GetResources(),'br_laranja')  // Aguardando Aprovação do Supervisor
   Local oBranco   := LoadBitmap(GetResources(),'br_branco')   // Atividade Encerrada
   Local oPreto    := LoadBitmap(GetResources(),'br_preto')    // Disponível
   Local oCinza    := LoadBitmap(GetResources(),'br_cinza')    // Disponível

   Private oDlgL

   aAdd( aLegenda, { '1', 'Executado Antes do Prazo' } )
   aAdd( aLegenda, { '2', 'Executado Fora do Prazo'  } )
   aAdd( aLegenda, { '3', 'Executado no Prazo'       } )
   aAdd( aLegenda, { '4', 'Vencida e não Executada'  } )
   aAdd( aLegenda, { '5', 'Aguardando Aprovação do Supervisor' } )
   aAdd( aLegenda, { '6', 'Atividade Encerrada'      } )
   aAdd( aLegenda, { '7', 'Disponível'               } )
   aAdd( aLegenda, { '8', 'Disponível'               } )                  

   DEFINE MSDIALOG oDlgL TITLE "Legenda de Movimentação das Atividades" FROM C(178),C(181) TO C(417),C(542) PIXEL

   // Cria o objeto grid
   oLegenda := TCBrowse():New( 005 , 005, 160, 140,,{'L','Status da Legenda'},{20,50,50,50},oDlgL,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oLegenda:SetArray(aLegenda) 
    
   // Monta a linha a ser exibina no Browse
   oLegenda:bLine := {||{ If(Alltrim(aLegenda[oLegenda:nAt,01]) == "1", oBranco  ,;
                          If(Alltrim(aLegenda[oLegenda:nAt,01]) == "2", oVerde   ,;
                          If(Alltrim(aLegenda[oLegenda:nAt,01]) == "3", oCinza   ,;                         
                          If(Alltrim(aLegenda[oLegenda:nAt,01]) == "4", oAmarelo ,;                         
                          If(Alltrim(aLegenda[oLegenda:nAt,01]) == "5", oAzul    ,;                         
                          If(Alltrim(aLegenda[oLegenda:nAt,01]) == "6", oLaranja ,;                         
                          If(Alltrim(aLegenda[oLegenda:nAt,01]) == "7", oPreto   ,;                         
                          If(Alltrim(aLegenda[oLegenda:nAt,01]) == "8", oVermelho, oBranco)))))))),;                         
                          aLegenda[oLegenda:nAt,02]}}

   @ C(103),C(138) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgL ACTION( oDlgL:End() )

   ACTIVATE MSDIALOG oDlgL CENTERED 

Return(.T.)