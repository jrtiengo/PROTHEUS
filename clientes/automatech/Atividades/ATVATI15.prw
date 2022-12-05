#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ATVATI15.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 29/10/2012                                                          *
// Objetivo..: Programa que abre a relação de atividades em atraso/a realizar por  *
//             usuário quando este se loga no Sistema Protheus.                    *
//**********************************************************************************

User Function ATVATI15(_Supervisor)
                           
   Local nPosicao      := 0
   Local nContar       := 0
   Local lChumba       := .F.
   Local lAdm          := .F.
   Local lSupervisor   := .F.
   Local lNormal       := .F.      
   Local cSql          := ""
   Local cData1        := Ctod("  /  /    ")
   Local cData2        := Ctod("  /  /    ")
   Local cSemana       := ""
   Local lMaisHoje     := .F.
   Local lAgrupado     := .F.

   Private cAntesPrazo := 0
   Private cNoPrazo    := 0
   Private cAprovacao  := 0
   Private cForaPrazo  := 0
   Private cVenciNao   := 0
   Private cEncerrada  := 0
   Private cAvencer    := 0
   Private cDetalhe	   := ""
   Private cProblema   := ""
   Private cSugestao   := ""

   Private aAdm        := {}
   Private aSupervisor := {}
   Private aUsuario    := {}
   Private aStatus     := {}
   Private aMes        := {'1','2','3','4','5','6','7','8','9','10','11','12'}
   Private aAno        := {'2012','2013','2014','2015','2016','2017','2018','2019','2020','2021','2022','2023','2024','2025','2026','2027','2028','2029','2030'} 
   Private nPara	   := 1

   Private aStatus     := {'0 - Todos os Status'                ,;
                           '1 - Executado antes do prazo'       ,;
                           '2 - Executao fora do prazo'         ,;
                           '3 - Executado no prazo'             ,;
                           '4 - Vencida e não executada'        ,;
                           '5 - Aguardando aprovação supervisor',;
                           '6 - Atividade Encerrada'            ,;
                           '7 - A Vencer'}

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4
   Private cComboBx5
   Private cComboBx6   

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet7
   Private oGet8
   Private oGet9
   Private oGet10
   Private oPara
   Private oMemo1
   Private oMemo2
   Private oMemo3   
   
   Private oDlg

   Private aBrowse    := {}
   Private __UserName := ""

   Default _Supervisor := ""

   cComboBx5 := Month(Date())

   If Empty(_Supervisor)
      __UserName := cUserName
   Else
      __UserName := _Supervisor
   Endif      

   // Acha o posicionamento no combo de Anos
   nPosicao  := 1
   For nContar = 1 to 20
       If Strzero(Year(Date()),4) == aAno[nContar]
          nPosicao := nContar
          Exit
       Endif
   Next nContar    
                    
   cComboBx6 := nPosicao

   Private oVerde    := LoadBitmap(GetResources(),'br_verde')    // Executado Antes do Prazo
   Private oVermelho := LoadBitmap(GetResources(),'br_vermelho') // Executado Fora do Prazo
   Private oAzul     := LoadBitmap(GetResources(),'br_azul')     // Executado no Prazo
   Private oAmarelo  := LoadBitmap(GetResources(),'br_amarelo')  // Vencida e não Executada
   Private oLaranja  := LoadBitmap(GetResources(),'br_laranja')  // Aguardando Aprovação do Supervisor
   Private oBranco   := LoadBitmap(GetResources(),'br_branco')   // Atividade Encerrada
   Private oPreto    := LoadBitmap(GetResources(),'br_preto')    // Disponível
   Private oCinza    := LoadBitmap(GetResources(),'br_cinza')    // Disponível

   _Ativi := .T.

   // Verifica o tipo de usuário e se pode ser aberta a tela de verificação
   If Select("T_USUARIO") > 0
      T_USUARIO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZT_USUA, ZZT_ADM , ZZT_SUPE, ZZT_NORM, ZZT_VISU, ZZT_LOGI "
   cSql += "  FROM " + RetSqlName("ZZT")
   cSql += " WHERE ZZT_DELETE = ''"
   cSql += "   AND ZZT_USUA   = '" + Alltrim(UPPER(__UserName)) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIO", .T., .T. )

   If T_USUARIO->( EOF() )
      Return(.T.)
   Endif
  
   // Se o usuário logado for Adm
   If T_USUARIO->ZZT_ADM == "T"
      Return .T.
   Endif   

   // Verifica se o usuário logado pode verificar suas atividades
   If T_USUARIO->ZZT_LOGI <> "T"
      Return .T.
   Endif

   // Se o usuário logado for Supervisor
   If T_USUARIO->ZZT_SUPE == "T"

      IF T_USUARIO->ZZT_ADM == "T"
         lAdm        := .T.
         lSupervisor := .T.
         lNormal     := .T.      
         lAgrupado   := .T.
      Else
         lAdm        := .F.
         lSupervisor := .F.
         lNormal     := .T.      
         lAgrupado   := .T.
      Endif         

      // Carrega o Adm do Supervisor
      If Select("T_GERENTE") > 0
         T_GERENTE->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZT_GERE"
      cSql += "  FROM " + RetSqlName("ZZT")
      cSql += " WHERE ZZT_DELETE = ''"
      cSql += "   AND ZZT_USUA   = '" + Alltrim(UPPER(__UserName)) + "'"
      cSql += " ORDER BY ZZT_USUA"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GERENTE", .T., .T. )

      aAdd( aAdm, T_GERENTE->ZZT_GERE )

      If Len(aAdm) == 0
         aAdd( aAdm, "" )
      Endif
         
      // Carrega os Supervisores
      aAdd( aSupervisor, Alltrim(UPPER(__UserName)) )

      // Carrega os Usuários do Supervisores
      If Select("T_NORMAL") > 0
         T_NORMAL->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZT_USUA"
      cSql += "  FROM " + RetSqlName("ZZT")
      cSql += " WHERE ZZT_DELETE = ''"
      cSql += "   AND ZZT_RESP   = '" + Alltrim(UPPER(__UserName)) + "'"
      cSql += " ORDER BY ZZT_USUA"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NORMAL", .T., .T. )
      
      WHILE !T_NORMAL->( EOF() )   
         aAdd( aUsuario, T_NORMAL->ZZT_USUA )
         T_NORMAL->( DbSkip() )
      ENDDO

      If Len(aUsuario) == 0
//         aAdd( aNormal, "" )
      Endif   
      
   Endif   

   // Se o usuário logado for Normal
   If T_USUARIO->ZZT_NORM == "T"

      lAdm        := .F.
      lSupervisor := .F.
      lNormal     := .F.      
      lAgrupado   := .F.

      // Carrega o Adm do Supervisor
      If Select("T_NORMAL") > 0
         T_NORMAL->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZT_USUA,"
      cSql += "       ZZT_RESP,"
      cSql += "       ZZT_GERE "
      cSql += "  FROM " + RetSqlName("ZZT")
      cSql += " WHERE ZZT_DELETE = ''"
      cSql += "   AND ZZT_USUA   = '" + Alltrim(UPPER(__UserName)) + "'"
      cSql += " ORDER BY ZZT_USUA"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NORMAL", .T., .T. )

      aAdd( aAdm       , T_NORMAL->ZZT_GERE )
      aAdd( aSupervisor, T_NORMAL->ZZT_RESP )
      aAdd( aUsuario   , T_NORMAL->ZZT_USUA )
      
   Endif   

   If Len(aUsuario) == 0
      MsgAlert("Não existem dados a serem visualizados.")
      Return .T.
   Endif

   // Envia para a função que carrega o array aBrowse para display
   PESQUSUS(aUsuario[1], aStatus[1], Strzero(Month(date()),2), Strzero(year(date()),4), nPara, "E")

   If Len(aBrowse) == 0
      aBrowse := {}
      aAdd( aBrowse, { '','','','','','','','','','','' } )
   Endif         

   DEFINE MSDIALOG oDlg TITLE "Agenda de Atividades - Em Atraso / A Realizar" FROM C(178),C(181) TO C(613),C(967) PIXEL

   @ C(005),C(005) Say "Administrador"                      Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(069) Say "Supervisor"                         Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(133) Say "Usuários"                           Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(197) Say "Status"                             Size C(012),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(274) Say "Mês"                                Size C(011),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(301) Say "Ano"                                Size C(011),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(337) Say "Para"                               Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(028),C(005) Say "Relação de Atividades pesquisadas"  Size C(104),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(193),C(027) Say "Executadas antes do prazo"          Size C(071),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(193),C(130) Say "Executado no prazo"                 Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(193),C(230) Say "Aguardando aprovação do supervisor" Size C(091),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(192),C(318) Say "A VENCER"                           Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(205),C(027) Say "Executado fora do prazo"            Size C(071),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(205),C(130) Say "Vencidas e não executadas"          Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(205),C(230) Say "Atividades encerradas"              Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(145),C(005) Say "Descritivo da Atividade"            Size C(057),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(145),C(119) Say "Problema Encontrado na Execução"    Size C(086),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(145),C(234) Say "Sugestão"                           Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(005) ComboBox cComboBx1 Items aAdm        Size C(059),C(010) PIXEL OF oDlg When lAdm
   @ C(014),C(069) ComboBox cComboBx2 Items aSupervisor Size C(059),C(010) PIXEL OF oDlg When lSupervisor
   @ C(014),C(133) ComboBox cComboBx3 Items aUsuario    Size C(059),C(010) PIXEL OF oDlg 
   @ C(014),C(197) ComboBox cComboBx4 Items aStatus     Size C(071),C(010) PIXEL OF oDlg
   @ C(014),C(274) ComboBox cComboBx5 Items aMes        Size C(022),C(010) PIXEL OF oDlg
   @ C(014),C(301) ComboBox cComboBx6 Items aAno        Size C(031),C(010) PIXEL OF oDlg
   @ C(013),C(338) Radio oPara Var nPara Items "Mês <=","Mês =" 3D Size C(027),C(010) PIXEL OF oDlg

   @ C(154),C(005) GET oMemo1 Var cDetalhe  MEMO Size C(112),C(033) PIXEL OF oDlg
   @ C(154),C(119) GET oMemo2 Var cProblema MEMO Size C(112),C(033) PIXEL OF oDlg
   @ C(154),C(234) GET oMemo3 Var cSugestao MEMO Size C(112),C(033) PIXEL OF oDlg
	
   @ C(191),C(005) MsGet oGet1  Var cAntesPrazo  When lChumba Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(191),C(108) MsGet oGet3  Var cNoPrazo     When lChumba Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(191),C(208) MsGet oGet8  Var cAprovacao   When lChumba Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(203),C(005) MsGet oGet2  Var cForaPrazo   When lChumba Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(203),C(108) MsGet oGet7  Var cVenciNao    When lChumba Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(203),C(208) MsGet oGet9  Var cEncerrada   When lChumba Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(203),C(322) MsGet oGet10 Var cAvencer     When lChumba Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(012),C(371) Button ">>>"                        Size C(017),C(013) PIXEL OF oDlg ACTION( PESQUSUS(cComboBx3, cComboBx4, cComboBx5, aAno[cComboBx6], nPara, "X") )
   @ C(146),C(351) Button "Legenda"                    Size C(037),C(012) PIXEL OF oDlg ACTION( ___Legendas() )
   @ C(164),C(351) Button "Bx Agrupado" When lAgrupado Size C(037),C(012) PIXEL OF oDlg ACTION( BxAgrupadas( cComboBx1, cComboBx2, cComboBx3 ) )
   @ C(182),C(351) Button "Bx Detalhe"                 Size C(037),C(012) PIXEL OF oDlg ACTION( ABRE_DET(aBrowse[oBrowse:nAt,06],aBrowse[oBrowse:nAt,09],aBrowse[oBrowse:nAt,10],aBrowse[oBrowse:nAt,03],aBrowse[oBrowse:nAt,04], lAdm, lSupervisor, lNormal, lAgrupado))
   @ C(200),C(351) Button "Sair"                       Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oGet1:Refresh()
   oGet2:Refresh()
   oGet3:Refresh()
   oGet7:Refresh()
   oGet8:Refresh()
   oGet9:Refresh()
   oGet10:Refresh()

   oBrowse := TCBrowse():New( 045 , 005, 490, 138,,{'L', 'E', 'De', 'Até', 'Semana', 'Código', 'Descrição das Atividades', 'Usuário', 'Realizado Em', 'Encerrado Em'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
   
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
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "8", oVermelho, oBranco)))))))),;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "3", oCinza   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "8", oVermelho, oBranco)))))))),;                         
                         aBrowse[oBrowse:nAt,03] ,;
                         aBrowse[oBrowse:nAt,04] ,;
                         aBrowse[oBrowse:nAt,05] ,;
                         aBrowse[oBrowse:nAt,06] ,;
                         aBrowse[oBrowse:nAt,07] ,;
                         aBrowse[oBrowse:nAt,08] ,;
                         aBrowse[oBrowse:nAt,11] ,;
                         aBrowse[oBrowse:nAt,12] }}

      oBrowse:bLDblClick := {|| MOSTRANOT(aBrowse[oBrowse:nAt,10]) } 

      MOSTRANOT(aBrowse[oBrowse:nAt,10])   

   ACTIVATE MSDIALOG oDlg CENTERED 
 
Return(.T.)

// Sub-Função que mostra a Descrição da Atividade selecionada
Static Function MOSTRANOT(_Codigo)

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
   cSql := ""
   cSql := "SELECT DISTINCT A.ZZX_CODIGO,"
   cSql += "       A.ZZX_ATIV           ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), B.ZZU_DETA)) AS DETALHE ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZZX_PROB)) AS PROBLEMA,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZZX_MELH)) AS SUGESTAO"   
   cSql += "  FROM " + RetSqlName("ZZX") + " A, "
   cSql += "       " + RetSqlName("ZZU") + " B  "
   cSql += " WHERE A.R_E_C_N_O_ = '" + Alltrim(_Codigo) + "'"
   cSql += "   AND A.ZZX_DELETE = ''
   cSql += "   AND A.ZZX_ATIV   = B.ZZU_CODIGO 
   cSql += "   AND B.ZZU_DELETE = ''

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MOSTRA", .T., .T. )

   If T_MOSTRA->( EOF() )
      Return .T.
   Endif

   // Carrega o campo cTexto
   If !Empty(Alltrim(T_MOSTRA->DETALHE))
      cDetalhe  := Alltrim(T_MOSTRA->DETALHE)
      cProblema := Alltrim(T_MOSTRA->PROBLEMA)
      cSugestao := Alltrim(T_MOSTRA->SUGESTAO)
   Else
      cDetalhe  := ""
      cProblema := ""
      cSugestao := ""
   Endif      

   oMemo1:Refresh()
   oMemo2:Refresh()
   oMemo3:Refresh()   

Return .T.

// Função que pesquisa dados do usuário selecionado no ComboBx1
Static Function PESQUSUS(xUsuario, xStatus, xMes, xAno, xPara, xTipo  )

   If ValType(xMes) == "N"
      xMes := Alltrim(Str(xMes))
   Endif

   // Limpa o array         
   aBrowse := {}

   If xTipo == "X"
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
                            If(Alltrim(aBrowse[oBrowse:nAt,02]) == "1", oBranco  ,;
                            If(Alltrim(aBrowse[oBrowse:nAt,02]) == "2", oVerde   ,;
                            If(Alltrim(aBrowse[oBrowse:nAt,02]) == "3", oCinza   ,;                         
                            If(Alltrim(aBrowse[oBrowse:nAt,02]) == "4", oAmarelo ,;                         
                            If(Alltrim(aBrowse[oBrowse:nAt,02]) == "5", oAzul    ,;                         
                            If(Alltrim(aBrowse[oBrowse:nAt,02]) == "6", oLaranja ,;                         
                            If(Alltrim(aBrowse[oBrowse:nAt,02]) == "7", oPreto   ,;                         
                            If(Alltrim(aBrowse[oBrowse:nAt,02]) == "8", oVermelho, oBranco)))))))),;                         
                            aBrowse[oBrowse:nAt,03] ,;
                            aBrowse[oBrowse:nAt,04] ,;
                            aBrowse[oBrowse:nAt,05] ,;
                            aBrowse[oBrowse:nAt,06] ,;
                            aBrowse[oBrowse:nAt,07] ,;
                            aBrowse[oBrowse:nAt,08] ,;
                            aBrowse[oBrowse:nAt,11] ,;
                            aBrowse[oBrowse:nAt,12]}}

      oBrowse:Refresh()
   Endif

   // Pesquisa as atividades em atraso/a realizar para o usuário logado
   If Select("T_ATIVIDADES") > 0
      T_ATIVIDADES->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZX_FILIAL,"
   cSql += "       A.ZZX_DAT1  ,"
   cSql += "       A.ZZX_DAT2  ,"
   cSql += "       A.ZZX_REAL  ,"
   cSql += "       A.ZZX_ALCA  ,"
   cSql += "       A.ZZX_CODIGO,"
   cSql += "       B.ZZU_NOME  ,"
   cSql += "       A.ZZX_USUA  ,"
   cSql += "       A.R_E_C_N_O_ AS REGISTRO,"
   cSql += "       C.ZZV_AREA   "
   cSql += "  FROM " + RetSqlName("ZZX") + " A, "
   cSql += "       " + RetSqlName("ZZU") + " B, "
   cSql += "       " + RetSqlName("ZZV") + " C  "
   cSql += " WHERE A.ZZX_ATIV   = B.ZZU_CODIGO"
   cSql += "   AND A.ZZX_DELETE = ''"
   cSql += "   AND A.ZZX_CODIGO = C.ZZV_CODIGO"
   cSql += "   AND C.ZZV_DELETE = ''"
   cSql += "   AND A.ZZX_USUA   = '" + Alltrim(xUsuario) + "'"
   cSql += "   AND B.ZZU_DELETE = ''"

   If Int(Val(xMes)) <> 0
      If xPara = 1
         cSql += "   AND A.ZZX_MES <= '" + Alltrim(xMes) + "'"
      Else
         cSql += "   AND A.ZZX_MES  = '" + Alltrim(xMes) + "'"
      Endif
      cSql += "   AND A.ZZX_ANO     = '" + Alltrim(xAno) + "'"
   Endif

   cSql += " ORDER BY A.ZZX_USUA, A.ZZX_DAT1 "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATIVIDADES", .T., .T. )

   cAntesPrazo := 0
   cNoPrazo    := 0
   cAprovacao  := 0
   cForaPrazo  := 0
   cVenciNao   := 0
   cEncerrada  := 0
   cAvencer    := 0

   If xTipo == "X"
      oGet1:Refresh()
      oGet2:Refresh()
      oGet3:Refresh()
      oGet7:Refresh()
      oGet8:Refresh()
      oGet9:Refresh()
      oGet10:Refresh()
   Endif   

   aBrowse := {}

   WHILE !T_ATIVIDADES->( EOF() )

      cData1 := Ctod(Substr(T_ATIVIDADES->ZZX_DAT1,07,02) + "/" + Substr(T_ATIVIDADES->ZZX_DAT1,05,02) + "/" + Substr(T_ATIVIDADES->ZZX_DAT1,01,04))
      cData2 := Ctod(Substr(T_ATIVIDADES->ZZX_DAT2,07,02) + "/" + Substr(T_ATIVIDADES->ZZX_DAT2,05,02) + "/" + Substr(T_ATIVIDADES->ZZX_DAT2,01,04))
      cReal  := Ctod(Substr(T_ATIVIDADES->ZZX_REAL,07,02) + "/" + Substr(T_ATIVIDADES->ZZX_REAL,05,02) + "/" + Substr(T_ATIVIDADES->ZZX_REAL,01,04))
      cAlca  := Ctod(Substr(T_ATIVIDADES->ZZX_ALCA,07,02) + "/" + Substr(T_ATIVIDADES->ZZX_ALCA,05,02) + "/" + Substr(T_ATIVIDADES->ZZX_ALCA,01,04))      

      Do Case
         Case Dow(cData1) == 1
              cSemana := "Domingo"
         Case Dow(cData1) == 2
              cSemana := "Segunda"
         Case Dow(cData1) == 3
              cSemana := "Terça"
         Case Dow(cData1) == 4
              cSemana := "Quarta"
         Case Dow(cData1) == 5
              cSemana := "Quinta"
         Case Dow(cData1) == 6
              cSemana := "Sexta"
         Case Dow(cData1) == 7
              cSemana := "Sábado"
      EndCase              

      // Calcula o Status da Atividade

      // Executados
      If Empty(cReal)

         If Date() < cData1
            cStatus  := "5"
            cAvencer += 1
         Endif
         
         If Date() > cData2
            cStatus   := "4"
            cVenciNao += 1
         Endif
      
      Else

         // Executado no Prazo
         If cReal >= cData1 .And. cReal <= cData2
            cStatus  := "3"
            cNoPrazo += 1
         Endif

         // Executado Antes do Prazo
         If cReal < cData1
            cStatus     := "1"
            cAntesPrazo += 1
         Endif
                     
         // Executado Fora do Prazo
         If cReal > cData2
            cStatus    := "2"
            cForaPrazo += 1
         Endif

      Endif

      // Atualiza a legenda Aguardando Supervisor/Atividade Encerrada
      cStatus2 := ""
      
      If Empty(cAlca)
         If !Empty(cReal)
            cStatus2   := "7"
            cAprovacao +=1 
         Endif
      Else
         cStatus2   := "6"      
         cEncerrada += 1
      Endif

      If Empty(cReal) .And. Empty(cAlca)
         cStatus2   := "7"
      Endif      

      Do Case
         Case Substr(xStatus,01,01) == "1"
              If cStatus <> "1"
                 T_ATIVIDADES->( DbSkip() )
                 Loop
              Endif
         Case Substr(xStatus,01,01) == "2"
              If cStatus <> "2"
                 T_ATIVIDADES->( DbSkip() )
                 Loop
              Endif
         Case Substr(xStatus,01,01) == "3"
              If cStatus <> "3"
                 T_ATIVIDADES->( DbSkip() )
                 Loop
              Endif
         Case Substr(xStatus,01,01) == "4"
              If cStatus <> "4"
                 T_ATIVIDADES->( DbSkip() )
                 Loop
              Endif
         Case Substr(xStatus,01,01) == "5"
              If cStatus <> "5"
                 T_ATIVIDADES->( DbSkip() )
                 Loop
              Endif
         Case Substr(xStatus,01,01) == "6"
              If cStatus2 <> "6"
                 T_ATIVIDADES->( DbSkip() )
                 Loop
              Endif
         Case Substr(xStatus,01,01) == "7"
              If cStatus2 <> "7"
                 T_ATIVIDADES->( DbSkip() )
                 Loop
              Endif
      EndCase        

      // Atualiza o Array aBrowse
      aAdd( aBrowse, { cStatus                           ,; // 01 - Status da Atividade
                       cStatus2                          ,; // 02 - Status da Aprovação
                       cData1                            ,; // 03 - Data inicial de execução da atividade
                       cData2                            ,; // 04 - Data final de execução da atividade
                       cSemana                           ,; // 05 - Dia da Semana
                       T_ATIVIDADES->ZZX_CODIGO          ,; // 06 - Código da Atividade
                       T_ATIVIDADES->ZZU_NOME            ,; // 07 - Nome da Atividade
                       T_ATIVIDADES->ZZX_USUA            ,; // 08 - Usuário
                       T_ATIVIDADES->ZZV_AREA            ,; // 09 - Área
                       Strzero(T_ATIVIDADES->REGISTRO,06),; // 10 - Nº do Registro
                       cReal                             ,; // 11 - Data da Realização
                       cAlca                             ,; // 12 - Data de Encerramento                       
                       } )
      
      T_ATIVIDADES->( DbSkip() )
      
   ENDDO

   If xTipo == "E"
      Return .T.
   Endif   

   oGet1:Refresh()
   oGet2:Refresh()
   oGet3:Refresh()
   oGet7:Refresh()
   oGet8:Refresh()
   oGet9:Refresh()
   oGet10:Refresh()
   
   If Len(aBrowse) == 0   
      aAdd( aBrowse, { '','','','','','','','','','' } )
      MsgAlert("Não existem dados a serem visualizados para esta seleção.")
      Return .T.'
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
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "8", oVermelho, oBranco)))))))),;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "3", oCinza   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "8", oVermelho, oBranco)))))))),;                         
                         aBrowse[oBrowse:nAt,03] ,;
                         aBrowse[oBrowse:nAt,04] ,;
                         aBrowse[oBrowse:nAt,05] ,;
                         aBrowse[oBrowse:nAt,06] ,;
                         aBrowse[oBrowse:nAt,07] ,;
                         aBrowse[oBrowse:nAt,08] ,;
                         aBrowse[oBrowse:nAt,11] ,;
                         aBrowse[oBrowse:nAt,12] }}

   oBrowse:Refresh()

   If !Empty(aBrowse[oBrowse:nAt,10])
      MOSTRANOT(aBrowse[oBrowse:nAt,10])   
   Endif

Return .T.

// Função que abre a tela de detalhes da tarefa
Static Function ABRE_DET(xAtividade, xArea, xRegistro, xData1, xData2, xAdm, xSupervisor, xNormal, xAgrupado)

   U_ATVMOV02(xAtividade, xArea, xRegistro, xData1, xData2, xAdm, xSupervisor, xNormal, xAgrupado)

   PESQUSUS(cComboBx3, cComboBx4, cComboBx5, aAno[cComboBx6], nPara, "X")
   
Return .T.

// Função que abre a janela das Legendas de Movimentação das Atividades
Static Function ___Legendas()

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

   aAdd( aLegenda, { '1', '[L] - Executado Antes do Prazo - [E] - Sem Efeito' } )
   aAdd( aLegenda, { '2', 'Executado Fora do Prazo'                           } )
   aAdd( aLegenda, { '3', 'Executado no Prazo'                                } )
   aAdd( aLegenda, { '4', 'Vencida e não Executada'                           } )
   aAdd( aLegenda, { '5', 'A Vencer'                                          } )
   aAdd( aLegenda, { '6', 'Atividade Encerrada'                               } )
   aAdd( aLegenda, { '7', 'Aguardando Aprovação'                              } )
   aAdd( aLegenda, { '8', 'Disponível'                                        } )                  

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

// Função que abre a janela para baixa agrupada das atividades
Static Function BxAgrupadas(cComboBx1, cComboBx2, cComboBx3)

   Local lChumba := .F.
   Local nContar := 0
   Local cAdm    := cComboBx1
   Local cSup    := cComboBx2
   Local cUsu    := cComboBx3
   Local cData   := Ctod("  /  /    ")
   Local oOk     := LoadBitmap( GetResources(), "LBOK" )
   Local oNo     := LoadBitmap( GetResources(), "LBNO" )
   
   Local oGet1
   Local oGet2
   Local oGet3

   Private oDlgA

   Private aLista := {}
   Private oLista

   // Carrega o Array aLista com o conteúdo da pesquisa
   For nContar = 1 to Len(aBrowse)
       If !Empty(aBrowse[nContar,11]) .And. Empty(aBrowse[nContar,12])
 	      AADD(aLista, {.F.                   ,; // 01 - Marcação
                        aBrowse[nContar,03]   ,; // 02 - Data de
                        aBrowse[nContar,04]   ,; // 03 - Data Até
                        aBrowse[nContar,06]   ,; // 04 - Código Atividade
                        aBrowse[nContar,07]   ,; // 05 - Descrição da Atividade
                        aBrowse[nContar,10]   ,; // 06 - Código do Registro do Lançamento
                        aBrowse[nContar,11]   ,; // 07 - Data de Realização
                        aBrowse[nContar,12]})    // 08 - Data do Encerramento
       Endif                        
   Next nContar

   If Len(aLista) == 0
      MsgAlert("Não existem Atividades a serem visualizadas.")
      Return .T.
   Endif   

   DEFINE MSDIALOG oDlgA TITLE "Aprovação de Atividades por Usuário" FROM C(178),C(181) TO C(560),C(736) PIXEL

   @ C(005),C(005) Say "Administrador"     Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(005),C(071) Say "Supervisor"        Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(005),C(138) Say "Usuário"           Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(177),C(005) Say "Data da Aprovação" Size C(048),C(008) COLOR CLR_BLACK PIXEL OF oDlgA

   @ C(014),C(005) MsGet oGet1 Var cAdm  When lChumba Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA
   @ C(014),C(071) MsGet oGet2 Var cSup  When lChumba Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA
   @ C(014),C(138) MsGet oGet3 Var cUsu  When lChumba Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA
   @ C(176),C(056) MsGet oGet4 Var cData              Size C(042),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA

   @ C(025),C(005) Say "Atividades "  Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgA

   @ C(174),C(197) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgA ACTION( GRVMARCADAS(aLista, cData) )
   @ C(174),C(235) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgA ACTION( oDlgA:End() )

   @ 040,005 LISTBOX oLista FIELDS HEADER "M", "Data De:" ,"Data Até:", "Realizado Em", "Encerrado Em", "Código", "Atividade", "Registro" PIXEL SIZE 345,175 OF oDlgA;
             ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())        

   oLista:SetArray( aLista )
   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
           					    aLista[oLista:nAt,02],;
          	        	        aLista[oLista:nAt,03],;
          	        	        aLista[oLista:nAt,07],;
          	        	        aLista[oLista:nAt,08],;
         	        	        aLista[oLista:nAt,04],;
         	        	        aLista[oLista:nAt,05],;
         	        	        aLista[oLista:nAt,06]}}

   ACTIVATE MSDIALOG oDlgA CENTERED 

Return(.T.)

// Função que salva as datas de encerramento para as atividades selecionadas
Static Function GrvMarcadas(aLista, cData)

   Local nContar := 0
   Local cSql    := ""
   Local lMarca  := .F.
   Local _Data   := ""

   // Verifica se houve a marcação de alguima atividade para atualização
   For nContar = 1 to Len(aLista)
       If aLista[nContar,1] == .T.
          lMarca := .T.
          Exit
       Endif   
   Next nContar
   
   If !lMarca
      MsgAlert("Não houve marcação de nenhuma atividade para encerramento. Verifique!")
      Return .T.
   Endif

   If Empty(cData)
      MsgAlert("Data de encerramento de atividades não informada.")
      Return .T.
   Endif  

   If cData < (Date() - 5)
      MsgAlert("Data de encerramento da atividade não pode ser inferior a " + Dtoc((date() - 5)) + ". Verifique !")
      Return .T.
   Endif
   
   // Atualiza a data de encerramento da atividade
   For nContar = 1 to Len(aLista)
  
       If aLista[nContar,1] == .F.
          Loop
       Endif   

       _Data := Substr(Dtoc(cData),07,04) + Substr(Dtoc(cData),04,02) + Substr(Dtoc(cData),01,02)
   
       cSql := ""
       cSql := "UPDATE " + RetSqlName("ZZX")
       cSql += "   SET "
       cSql += " ZZX_ALCA = '" + Alltrim(_Data) + "'"
       cSql += " WHERE R_E_C_N_O_ = '" + Alltrim(STR(INT(VAL(aLista[nContar,06])))) + "'"      
 
       lResult := TCSQLEXEC(cSql)
       If lResult < 0
          Return MsgStop("Erro durante a atualização da data de encerramento da atividade: " + TCSQLError())
      EndIf

   Next nContar   
   
   oDlgA:End()

   // Envia para a função que carrega o array aBrowse para display
   PESQUSUS(cComboBx3, cComboBx4, cComboBx5, aAno[cComboBx6], nPara, "X")

Return .T.