#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPACO01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 01/03/2012                                                          *
// Objetivo..: Programa que realiza o acompanhamento das tarefas por usuário       *
//**********************************************************************************

User Function ESPACO01()

   Local cSql      := "" 
   Local aComboBx1 := {}
   Local aComboBx2 := {}
   Local cComboBx1
   Local cComboBx2
   Local lChumba   := .F.
   Local lChumba   := .F.
   Local lChumbaU  := .F.

   Private cMemo1	   := ""
   Private cMemo2	   := ""

   Private oMemo1
   Private oMemo2

   Private oDlg
   Private aBrowse := {}
   Private oBrowse
   Private lHoras  := .T.

   // Declara as Legendas
   Private oVerde    := LoadBitmap(GetResources(),'br_verde')
   Private oVermelho := LoadBitmap(GetResources(),'br_vermelho')
   Private oAzul     := LoadBitmap(GetResources(),'br_azul')
   Private oAmarelo  := LoadBitmap(GetResources(),'br_amarelo')
   Private oPreto    := LoadBitmap(GetResources(),'br_preto')
   Private oLaranja  := LoadBitmap(GetResources(),'br_laranja')
   Private oCinza    := LoadBitmap(GetResources(),'br_cinza')
   Private oBranco   := LoadBitmap(GetResources(),'br_branco')

   // Carrega o combo de Usuários

   If Alltrim(Upper(cUserName))$("ADMINISTRADOR#GUSTAVO")
      lChumbaU := .T.
      // Pesquisa os usuários importados para display
      If Select("T_USUARIO") > 0
         T_USUARIO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZA_CODI, "
      cSql += "       ZZA_NOME, "
      cSql += "       ZZA_EMAI  "
      cSql += "  FROM " + RetSqlName("ZZA")
      cSql += " WHERE D_E_L_E_T_ = ''"
      cSql += " ORDER BY ZZA_NOME "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIO", .T., .T. )

      If T_USUARIO->( EOF() )
         aUsuarios := {}
      Else
         T_USUARIO->( DbGoTop() )
         WHILE !T_USUARIO->( EOF() )
            aAdd( aComboBx1, T_USUARIO->ZZA_NOME )
            T_USUARIO->( DbSkip() )
         ENDDO
      ENDIF
   Else
      lChumbaU := .F.
      aAdd( aComboBx1, cUserName )
   Endif   

   // Carrega o Combo de Status
   If Select("T_STATUS") > 0
      T_STATUS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZC_CODIGO, "
   cSql += "       ZZC_NOME    "
   cSql += "  FROM " + RetSqlName("ZZC")
   cSql += " WHERE ZZC_DELETE = ''"
   cSql += " ORDER BY ZZC_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_STATUS", .T., .T. )

   aComboBx2 := {}

   aAdd( aComboBx2, '0 - TODOS OS STATUS' )

   If !T_STATUS->( EOF() )
      WHILE !T_STATUS->( EOF() )
         aAdd( aComboBx2, Alltrim(STR(INT(VAL(T_STATUS->ZZC_CODIGO)))) + " - " + T_STATUS->ZZC_NOME )
         T_STATUS->( DbSkip() )
      ENDDO
   Endif

   // Seta o Status inicial para 1 - Abertura
   cComboBx2 := "1"

   aAdd( aBrowse, { '', '', '', '', '', '', '', '', '' } )

   DEFINE MSDIALOG oDlg TITLE "Acompanhamento de Tarefas" FROM C(178),C(181) TO C(615),C(895) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp"                                         Size C(170),C(030) PIXEL NOBORDER OF oDlg

   @ C(027),C(289) Say "ACOMPANHAMENTO DE TAREFAS"                                    Size C(090),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(038),C(005) Say "Usuários"                                                     Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(038),C(118) Say "Status"                                                       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(139),C(005) Say "Descrição da tarefa selecionada"                              Size C(079),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(159),C(289) Say "Detalhes da tarefa"                                           Size C(047),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(208),C(005) Say "Duplo click sobre a tarefa para visualizar a sua solicitação" Size C(138),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO Size C(350),C(001) PIXEL OF oDlg

   @ C(046),C(005) ComboBox cComboBx1 Items aComboBx1 When lChumbaU Size C(108),C(010) PIXEL OF oDlg
   @ C(046),C(118) ComboBox cComboBx2 Items aComboBx2               Size C(096),C(010) PIXEL OF oDlg

   @ C(044),C(228) Button "Legenda"   Size C(037),C(012) PIXEL OF oDlg ACTION( U_ESPSTA03() )
   @ C(044),C(276) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( NOVAPTAR( cComboBx1, cComboBx2 ) )
   @ C(138),C(343) Button "..."       Size C(013),C(008) PIXEL OF oDlg ACTION ( AbreMelhor(aBrowse[oBrowse:nAt,02]) )

   @ C(147),C(005) GET oMemo2 Var cMemo2 MEMO When lChumba Size C(351),C(049) PIXEL OF oDlg

   @ C(202),C(222) Button "Visão Geral do Projeto" Size C(066),C(012) PIXEL OF oDlg ACTION( U_ESPARV01(aBrowse[oBrowse:nAt,09], lHoras) )
   @ C(204),C(293) CheckBox oCheckBox1 Var lHoras Prompt "Visualizar com Horas" Size C(058),C(008) PIXEL OF oDlg

   @ C(044),C(315) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 075 , 005, 450, 100,,{'','Codigo', 'Tipo', 'Apelido', 'Título da Tarefa', 'Abertura', 'Previsto', 'Produção', 'Projeto'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
   
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
                       } }

   oBrowse:bLDblClick := {|| MOSTRACON(aBrowse[oBrowse:nAt,02]) } 

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Sub-Função que mostra a Descrição da Tarefa e a Solução Adotada
Static Function MOSTRACON(_Codigo)

   Local cSql     := ""
   Local cTexto   := ""
   Local cTarefa  := ""
   Local cSolucao := ""

   cMemo1 := ""
   cMemo2 := ""

   If Select("T_MOSTRA") > 0
      T_MOSTRA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZG_FILIAL,"
   cSql += "       ZZG_CODI  ,"
   cSql += "       ZZG_SEQU  ,"
   cSql += "CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZG_DES1)) AS SOLICITA "
   cSql += "  FROM " + RetSqlName("ZZG")
   cSql += " WHERE ZZG_DELE  = ''"
   cSql += "   AND ZZG_CODI  = '" + Substr(_Codigo,01,06) + "'"
   cSql += "   AND ZZG_SEQU  = '" + Substr(_Codigo,08,02) + "'"   

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MOSTRA", .T., .T. )

   If T_MOSTRA->( EOF() )
      Return .T.
   Endif

   cMemo2:= T_MOSTRA->SOLICITA
   oMemo2:Refresh()

Return(.T.)

// Sub-Função que remonta a pesquisa conforme a troca de status
Static Function NOVAPTAR( _Usuario, _Status)

   Local cSql := ""

   aBrowse := {}

   // Carrega o Array com os Componentes de tarefas cadastrados
   If Select("T_STATUS") > 0
      T_STATUS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZG_FILIAL," + CHR(13)
   cSql += "       A.ZZG_CODI  ," + CHR(13)
   cSql += "       A.ZZG_SEQU  ," + CHR(13)
   cSql += "       A.ZZG_TITU  ," + CHR(13)
   cSql += "       A.ZZG_USUA  ," + CHR(13)
   cSql += "       A.ZZG_DATA  ," + CHR(13)
   cSql += "       A.ZZG_HORA  ," + CHR(13)
   cSql += "       A.ZZG_STAT  ," + CHR(13)
   cSql += "       A.ZZG_DES1  ," + CHR(13)
   cSql += "       A.ZZG_PRIO  ," + CHR(13)
   cSql += "       A.ZZG_NOT1  ," + CHR(13)
   cSql += "       A.ZZG_PREV  ," + CHR(13)
   cSql += "       A.ZZG_TERM  ," + CHR(13)
   cSql += "       A.ZZG_PROD  ," + CHR(13)
   cSql += "       A.ZZG_SOL1  ," + CHR(13)
   cSql += "       A.ZZG_DELE  ," + CHR(13)
   cSql += "       A.ZZG_ORIG  ," + CHR(13)
   cSql += "       A.ZZG_CHAM  ," + CHR(13)
   cSql += "       A.ZZG_COMP  ," + CHR(13)
   cSql += "       A.ZZG_PROG  ," + CHR(13)
   cSql += "       A.ZZG_PROJ  ," + CHR(13)
   cSql += "       B.ZZD_NOME  ," + CHR(13)
   cSql += "       D.ZZB_NOME   " + CHR(13)
   cSql += "  FROM " + RetSqlName("ZZG") + " A, "                  + CHR(13)
   cSql += "       " + RetSqlName("ZZD") + " B, "                  + CHR(13)
   cSql += "       " + RetSqlName("ZZB") + " D  "                  + CHR(13)
   cSql += " WHERE A.ZZG_DELE   = ''"                              + CHR(13)
   cSql += "   AND A.ZZG_PRIO           = B.ZZD_CODIGO "           + CHR(13)
   cSql += "   AND A.ZZG_COMP           = D.ZZB_CODIGO "           + CHR(13)
   cSql += "   AND UPPER(A.ZZG_USUA)    = '" + UPPER(Alltrim(_Usuario)) + "'" + CHR(13)

   If Alltrim(Substr(_status,01,02)) == "0"
   Else
      cSql += " AND A.ZZG_STAT = '" + Alltrim(Substr(_Status,01,02)) + "'" + CHR(13)
   Endif

   cSql += " ORDER BY A.ZZG_PREV " + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_STATUS", .T., .T. )

   If T_STATUS->( EOF() )
      aAdd( aBrowse, { '', '', '', '', '', '', '', '', '' } )
   Else                  

      aBrowse := {}
      WHILE !T_STATUS->( EOF() )

         // Pesquisa o código da Legenda para display
         If Select("T_NOMEST") > 0
            T_NOMEST->( dbCloseArea() )
         EndIf
      
         cSql := ""
         cSql := "SELECT ZZC_LEGE"
         cSql += "  FROM " + RetSqlName("ZZC")
         cSql += " WHERE ZZC_CODIGO = '" + Strzero(INT(VAL(T_STATUS->ZZG_STAT)),6) + "'"
         cSql += "   AND ZZC_DELETE = ''

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOMEST", .T., .T. )
      
         If T_NOMEST->( EOF() )
            cNome_Status := ""
         Else
            cNome_Status := T_NOMEST->ZZC_LEGE
         Endif

         // Pesquisa a Chave do projeto   
         If Empty(Alltrim(T_STATUS->ZZG_PROJ))
            cNome_Chave := ""
         Else
            If Select("T_CHAVE") > 0
               T_CHAVE->( dbCloseArea() )
            EndIf
      
            cSql := ""
            cSql := "SELECT ZZY_CHAVE"
            cSql += "  FROM " + RetSqlName("ZZY")
            cSql += " WHERE ZZY_CODIGO = '" + Alltrim(T_STATUS->ZZG_PROJ) + "'"
            cSql += "   AND ZZY_DELETE = ''"

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CHAVE", .T., .T. )

            If T_CHAVE->( EOF() )
               cNome_Chave := ""
            Else
               cNome_Chave := T_CHAVE->ZZY_CHAVE
            Endif      
         Endif   

         // Adiciona um dia a mais na previsão de entrega como "gordura"
         If Empty(T_STATUS->ZZG_PREV)
            __Previsao := ""
         Else
            __Previsao := Dtoc(Ctod(Substr(T_STATUS->ZZG_PREV,07,02) + "/" + Substr(T_STATUS->ZZG_PREV,05,02) + "/" + Substr(T_STATUS->ZZG_PREV,01,04)) + 1)
         Endif   

         aAdd( aBrowse, { cNome_Status                                                    ,;
                          Alltrim(T_STATUS->ZZG_CODI) + "." + Alltrim(T_STATUS->ZZG_SEQU) ,;
                          IIF(EMPTY(ALLTRIM(T_STATUS->ZZG_PROJ)), "Normal", "Projetos")   ,;
                          cNome_Chave                                                     ,;
                          T_STATUS->ZZG_TITU                                              ,;
                          Substr(T_STATUS->ZZG_DATA,07,02) + "/" + Substr(T_STATUS->ZZG_DATA,05,02) + "/" + Substr(T_STATUS->ZZG_DATA,01,04) ,;
                          __Previsao                                                                                                         ,;
                          Substr(T_STATUS->ZZG_PROD,07,02) + "/" + Substr(T_STATUS->ZZG_PROD,05,02) + "/" + Substr(T_STATUS->ZZG_PROD,01,04) ,;
                          T_STATUS->ZZG_PROJ ;
                        } )
         T_STATUS->( DbSkip() )
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
                        } }
Return .T.

// Função que abre a janela do detalhe da tarefa selecionada
Static Function ABREMELHOR(_xCodTar)

   Local cMemo1	 := ""
   Local oMemo1

   Private oDlgDetalhe
  
   If Empty(Alltrim(_xCodTar))
      Return(.T.)
   Endif   

   // Pesquisa detalhes da tarefa selecionada
   If Select("T_MOSTRA") > 0
      T_MOSTRA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZG_FILIAL,"
   cSql += "       ZZG_CODI  ,"
   cSql += "       ZZG_SEQU  ,"
   cSql += "       ZZG_TITU  ,"
   cSql += "       ZZG_USUA  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZG_DES1)) AS DESCRICAO, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZG_NOT1)) AS NOTAS    , "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZG_SOL1)) AS SOLICITAS  "
   cSql += "  FROM " + RetSqlName("ZZG")
   cSql += " WHERE ZZG_DELE  = ''"
   cSql += "   AND ZZG_CODI  = '" + Substr(_xCodTar,01,06) + "'"
   cSql += "   AND ZZG_SEQU  = '" + Substr(_xCodTar,08,02) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MOSTRA", .T., .T. )

   If T_MOSTRA->( EOF() )
      Return .T.
   Endif

   // Carrega o campo cTexto
   If !Empty(Alltrim(T_MOSTRA->DESCRICAO))
      cTarefa := "TAREFA Nº: "  + Substr(_xCodTar,01,06) + "." + Substr(_xCodTar,08,02) + " - " + Alltrim(T_MOSTRA->ZZG_TITU) + chr(13) + chr(10) + chr(13) + chr(10)
      cTarefa += "Solicitante:" + Alltrim(T_MOSTRA->ZZG_USUA) + chr(13) + chr(10) + chr(13) + chr(10)
      ctarefa += "Solicitação:" + chr(13) + chr(10) + chr(13) + chr(10)
      cMemo1  := cTarefa + Chr(13) + Alltrim(T_MOSTRA->DESCRICAO)
   Endif

   DEFINE MSDIALOG oDlgDetalhe TITLE "Detalhes da Tarefa" FROM C(178),C(181) TO C(601),C(745) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(130),C(023) PIXEL NOBORDER OF oDlgDetalhe
   @ C(019),C(230) Say "DETALHES DA TAREFA"   Size C(061),C(008) COLOR CLR_BLACK PIXEL OF oDlgDetalhe
   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(278),C(164) PIXEL OF oDlgDetalhe
   @ C(196),C(122) Button "Voltar"            Size C(037),C(012) PIXEL OF oDlgDetalhe ACTION( oDlgDetalhe:End() )

   ACTIVATE MSDIALOG oDlgDetalhe CENTERED 

Return(.T.)