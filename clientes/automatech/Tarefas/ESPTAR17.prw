#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "XMLXFUN.CH"
#Include "Tbiconn.Ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPTAR17.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 27/09/2012                                                          *
// Objetivo..: Programa de Apontamento de Horas para Tarefas do Projeto            *
//**********************************************************************************

User Function ESPTAR17()

   Local cSql        := ""

   Private lChumba   := .F.
   Private aComboBx1 := {}
   Private cProjetos
   Private aBrowse   := {}
   Private lHoras    := .T.

   Private aListBox  := {"Selecione um Projeto para visualizar Tarefas"}
   Private oListBox1

   Private cCliente  := Space(25)
   Private cTotHoras := Space(03)
   Private cTrabalha := Space(03)
   Private cSaldo    := Space(03)
   Private cSituacao := Space(40)
   Private cHtotal   := Space(03)
   Private cRealiz   := Space(03)
   Private cHsaldo   := Space(03)
   Private cPercen   := Space(03)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9

   Private nMeter1	 := 0
   Private oMeter1

   Private oDlg

   // Verifica se o usuário logado possui vínculo com o cadastro de desenvolvedores
   If Select("T_DESENVE") > 0
      T_DESENVE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZE_CODIGO"
   cSql += "  FROM " + RetSqlName("ZZE")
   cSql += " WHERE ZZE_LOGIN  = '" + Alltrim(UPPER(cUserName)) + "'"
   cSql += "   AND ZZE_DELETE = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DESENVE", .T., .T. )

   If T_DESENVE->( EOF() )
      MsgAlert("Atenção! Usuário sem vínculo com o cadastro de desenvolvedores. Entre em contato com o administrador do Sistema.")
      Return(.T.)
   Endif

   // Carrega o combo de Projetos
   If Select("T_PROJETO") > 0
      T_PROJETO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZY_CODIGO, "
   cSql += "       ZZY_TITULO, "
   cSql += "       ZZY_CHAVE   "
   cSql += "  FROM " + RetSqlName("ZZY")
   cSql += " WHERE ZZY_DELETE = ''"
   cSql += " ORDER BY ZZY_CHAVE  "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROJETO", .T., .T. )

   If T_PROJETO->( EOF() )
      MsgAlert("Cadastro de Projetos está vazio.")
      Return .T.
   Endif

   // Carrega o Combo dos Projetos
   aComboBx1 := {}
   aAdd( aComboBx1, "Selecione um Projeto" )
   T_PROJETO->( EOF() )
   WHILE !T_PROJETO->( EOF() )
      aAdd( aComboBx1, T_PROJETO->ZZY_CODIGO + " - " + Alltrim(T_PROJETO->ZZY_CHAVE) )
      T_PROJETO->( DbSkip() )
   ENDDO

   aAdd( aBrowse, { '', '', '', '', ''} )

   DEFINE MSDIALOG oDlg TITLE "Apontamento de Horas" FROM C(178),C(181) TO C(602),C(925) PIXEL

   @ C(006),C(008) Say "Projeto"                         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(006),C(206) Say "Cliente"                         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(028),C(255) Say "Apontamento de Horas do Projeto" Size C(082),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(029),C(008) Say "Tarefas"                         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(156),C(008) Say "Total Hrs Projeto"               Size C(041),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(156),C(109) Say "Status da Tarefa Selecionada"    Size C(072),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(156),C(255) Say "Total Horas"                     Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(169),C(008) Say "Total Hrs Realizadas"            Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(169),C(255) Say "Trabalhadas"                     Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(181),C(008) Say "Saldo Hrs"                       Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(181),C(255) Say "Saldo"                           Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(195),C(084) Say "%"                               Size C(006),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(016),C(008) ComboBox cProjetos Items aComboBx1 Size C(153),C(010) PIXEL OF oDlg VALID(__BuscaCliente(cProjetos))
   @ C(014),C(164) Button "Visão"                     Size C(037),C(012) PIXEL OF oDlg ACTION( U_ESPARV01(Substr(cProjetos,01,06), lHoras))
   @ C(027),C(164) CheckBox oCheckBox1 Var lHoras     Prompt "Com Horas" Size C(048),C(008) PIXEL OF oDlg
   @ C(016),C(206) MsGet oGet1 Var cCliente           Size C(158),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(155),C(063) MsGet oGet6 Var cHtotal            Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(168),C(063) MsGet oGet7 Var cRealiz            Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(181),C(063) MsGet oGet8 Var cHSaldo            Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(194),C(063) MsGet oGet9 Var cPercen            Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(168),C(109) MsGet oGet5 Var cSituacao          Size C(081),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(155),C(290) MsGet oGet2 Var cTotHoras          Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(168),C(290) MsGet oGet3 Var cTrabalha          Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(181),C(290) MsGet oGet4 Var cSaldo             Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(188),C(104) Say "0 %"                 Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(188),C(117) METER oMeter1 VAR nMeter1 Size C(110),C(008) NOPERCENTAGE    PIXEL OF oDlg
   @ C(188),C(231) Say "100 %"               Size C(016),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(037),C(008) ListBox oListBox1 Fields HEADER "Tarefas do Projeto" Size C(244),C(112) Of oDlg Pixel ;
                   ON LEFT DBLCLICK ( CARREGA_PRO(aListBox[oListBox1:nAt])), ON RIGHT CLICK (CARREGA_PRO(aListBox[oListBox1:nAt]))

   @ C(166),C(193) Button "Alterar Status"        Size C(047),C(012) PIXEL OF oDlg ACTION( TrocaHist() )
   @ C(154),C(320) Button "Incluir"               Size C(044),C(012) PIXEL OF oDlg ACTION( __Apontamento("I", cProjetos, cCliente, aListBox[oListBox1:nAt], Ctod("  /  /    "), Space(03), Space(06), "" ))
   @ C(167),C(320) Button "Alterar"               Size C(044),C(012) PIXEL OF oDlg ACTION( __Apontamento("A", cProjetos, cCliente, aListBox[oListBox1:nAt], aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,04], aBrowse[oBrowse:nAt,05]) )
   @ C(181),C(320) Button "Excluir"               Size C(044),C(012) PIXEL OF oDlg ACTION( __Apontamento("E", cProjetos, cCliente, aListBox[oListBox1:nAt], aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,04], aBrowse[oBrowse:nAt,05]) )
   @ C(194),C(256) Button "Consulta Apontamentos" Size C(061),C(012) PIXEL OF oDlg ACTION( U_ESPAPO01() )
   @ C(194),C(320) Button "Voltar"                Size C(044),C(012) PIXEL OF oDlg ACTION( oDlg:End()  )

   oListBox1:SetArray(aListBox)
   
   oListBox1:bLine := {|| {aListBox[oListBox1:nAt]} }

   // Desenha o browse de apontamento de horas da tarefa selecionada
   oBrowse := TCBrowse():New( 047 , 325, 150, 142,,{'Data', 'Hora', 'Usuário'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
      
   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03] } }

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que pesquisa o nome do cliente para o projeto selecionado
Static Function CARREGA_PRO(__Tarefa)

   Local cSql := ""
   
   If Empty(Alltrim(__Tarefa))
      cSituacao := Space(40)
      cTotHoras := Space(03)
      @ C(155),C(290) MsGet oGet2 Var cTotHoras          Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
      @ C(168),C(109) MsGet oGet5 Var cSituacao          Size C(081),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
      oGet5:Refresh()                                 
      Return .T.
   Endif

   // Carrega o combo das tarefas do projeto
   If Select("T_TAREFAS") > 0
      T_TAREFAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZG_CODI,"
   cSql += "       ZZG_SEQU,"
   cSql += "       ZZG_STAT,"
   cSql += "       ZZG_HTOT "
   cSql += "  FROM " + RetSqlName("ZZG")
   cSql += " WHERE ZZG_CODI = '" + Substr(__Tarefa,01,06) + "'"
   cSql += "   AND ZZG_SEQU = '" + Substr(__Tarefa,08,02) + "'"
   cSql += "   AND ZZG_DELE = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAREFAS", .T., .T. )
   
   If T_TAREFAS->( EOF() )
      cSituacao := Space(40)
      cTotHoras := Space(03)
      @ C(155),C(290) MsGet oGet2 Var cTotHoras          Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
      @ C(168),C(109) MsGet oGet5 Var cSituacao          Size C(081),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
      oGet5:Refresh()                                 
      Return .T.
   Endif   

   cTotHoras := T_TAREFAS->ZZG_HTOT   

   Do Case
      Case Alltrim(T_TAREFAS->ZZG_STAT) == "1"
           cSituacao := "1 - ABERTURA"
      Case Alltrim(T_TAREFAS->ZZG_STAT) == "2"
           cSituacao := "2 - APROVADA"
      Case Alltrim(T_TAREFAS->ZZG_STAT) == "3"
           cSituacao := "3 - REPROVADA"
      Case Alltrim(T_TAREFAS->ZZG_STAT) == "4"
           cSituacao := "4 - DESENVOLVIMENTO"
      Case Alltrim(T_TAREFAS->ZZG_STAT) == "7"
           cSituacao := "7 - EM PRODUÇÃO"
      Case Alltrim(T_TAREFAS->ZZG_STAT) == "8"
           cSituacao := "8 - LIBERADA PARA PRODUÇÃO"
   EndCase        
                  
   @ C(155),C(290) MsGet oGet2 Var cTotHoras          Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(168),C(109) MsGet oGet5 Var cSituacao          Size C(081),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   oGet5:Refresh()                                 

   // Carrega o grid com os apontamentos da tarefa selecionada
   Carrega_Grid()

Return .T.   

// Função que pesquisa o nome do cliente para o projeto selecionado
Static Function __BuscaCliente( cProjetos)
 
   Local nTHorasP := 0

   If Empty(Alltrim(cProjetos))
      cCliente := space(40)
   Endif

   If UPPER(Alltrim(cProjetos)) == "SELECI"
      cCliente := space(40)
   Endif

   cSituacao := Space(40)
   cTotHoras := Space(03)
   @ C(155),C(290) MsGet oGet2 Var cTotHoras          Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(168),C(109) MsGet oGet5 Var cSituacao          Size C(081),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   oGet2:Refresh()                                 
   oGet5:Refresh()                                             

   // Pesquisa o cliente do projeto selecionado
   If Select("T_PROJETO") > 0
      T_PROJETO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZY_CODIGO, "
   cSql += "       A.ZZY_CLIENT, "
   cSql += "       A.ZZY_LOJA  , "
   cSql += "       B.A1_NOME     "
   cSql += "  FROM " + RetSqlName("ZZY") + " A, "
   cSql += "       " + RetSqlName("SA1") + " B  "
   cSql += " WHERE A.ZZY_DELETE = ''"
   cSql += "   AND A.ZZY_CODIGO = '" + Substr(cProjetos,01,06) + "'"
   cSql += "   AND A.ZZY_DELETE = ''"
   cSql += "   AND A.ZZY_CLIENT = B.A1_COD  "
   cSql += "   AND A.ZZY_LOJA   = B.A1_LOJA "
   cSql += "   AND B.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROJETO", .T., .T. )
   
   If T_PROJETO->( eof() )
      cCliente  := Space(40)
      cSituacao := Space(40)
      cTotHoras := Space(03)
      @ C(155),C(290) MsGet oGet2 Var cTotHoras          Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
      @ C(168),C(109) MsGet oGet5 Var cSituacao          Size C(081),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
      oGet2:Refresh()                                 
      oGet5:Refresh()                                 
   Else
      cCLiente := T_PROJETO->ZZY_CLIENT + "." + T_PROJETO->ZZY_LOJA + " - " + Alltrim(T_PROJETO->A1_NOME)
   Endif
   
   // Carrega o combo das tarefas do projeto
   If Select("T_TAREFAS") > 0
      T_TAREFAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZG_CODI,"
   cSql += "       ZZG_SEQU,"
   cSql += "       ZZG_TITU,"
   cSql += "       ZZG_STAT,"
   cSql += "       ZZG_HTOT "
   cSql += "  FROM " + RetSqlName("ZZG")
   cSql += " WHERE ZZG_PROJ = '" + Substr(cProjetos,01,06) + "'"
   cSql += "   AND ZZG_DELE = ''"
   cSql += "   AND ZZG_STAT <> '1'"
   cSql += " ORDER BY ZZG_CODI DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAREFAS", .T., .T. )

   If !T_TAREFAS->( EOF() )
      Do Case
         Case Alltrim(T_TAREFAS->ZZG_STAT) == "1"
              cSituacao := "1 - ABERTURA"
         Case Alltrim(T_TAREFAS->ZZG_STAT) == "2"
              cSituacao := "2 - APROVADA"
         Case Alltrim(T_TAREFAS->ZZG_STAT) == "3"
              cSituacao := "3 - REPROVADA"
         Case Alltrim(T_TAREFAS->ZZG_STAT) == "4"
              cSituacao := "4 - DESENVOLVIMENTO"
         Case Alltrim(T_TAREFAS->ZZG_STAT) == "7"
              cSituacao := "7 - EM PRODUÇÃO"
         Case Alltrim(T_TAREFAS->ZZG_STAT) == "8"
              cSituacao := "8 - LIBERADA PARA PRODUÇÃO"
      EndCase        
      cTotHoras := T_TAREFAS->ZZG_HTOT
      @ C(155),C(290) MsGet oGet2 Var cTotHoras          Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
      @ C(168),C(109) MsGet oGet5 Var cSituacao          Size C(081),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
      oGet2:Refresh()                                 
      oGet5:Refresh()                                             
   Endif

   // Carrega o Combo das Tarefas
   aListBox := {}
   T_TAREFAS->( EOF() )
   WHILE !T_TAREFAS->( EOF() )
      aAdd( aListBox, Alltrim(T_TAREFAS->ZZG_CODI) + "." + Alltrim(T_TAREFAS->ZZG_SEQU) + " - " + Alltrim(T_TAREFAS->ZZG_TITU))
      T_TAREFAS->( DbSkip() )
   ENDDO

   If Len(aListBox) == 0
      aListBox := {"Não existem tarefas a serem visualizadas."}   
   Endif   

   cHtotal := Str(nTHorasP,5,1)
   @ C(155),C(063) MsGet oGet6 Var cHtotal    Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   oListBox1:SetArray(aListBox)
   oListBox1:Refresh()

   IF Len(aListBox) == 0
      If Upper(Alltrim(aListBox[oListBox1:nAt])) <> "Não existem tarefas a serem visualizadas."   
         CARREGA_PRO(aListBox[oListBox1:nAt])
      Endif
   Endif

   // Carrega as horas apontadas para a tarefa selecionada
   Carrega_Grid()

   // Envia para a função que atualiza a estatística de horas do projeto selecionado
   H_Estatistica(cProjetos)

Return .T.

// Função que atualiza as estatísticas de horas do projeto selecionado
Static Function H_Estatistica(cProjetos)

   Local cSql     := ""
   Local nHTotalP := 0   
   Local nHTotalR := 0   
   
   // Carrega o combo das tarefas do projeto
   If Select("T_TAREFAS") > 0
      T_TAREFAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZG_CODI,"
   cSql += "       ZZG_SEQU,"
   cSql += "       ZZG_TITU,"
   cSql += "       ZZG_HTOT "
   cSql += "  FROM " + RetSqlName("ZZG")
   cSql += " WHERE ZZG_PROJ = '" + Substr(cProjetos,01,06) + "'"
   cSql += "   AND ZZG_DELE = ''"
   cSql += " ORDER BY ZZG_CODI DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAREFAS", .T., .T. )

   cHtotal := Space(03)
   cRealiz := Space(03)
   cHsaldo := Space(03)
   cPercen := Space(03)

   nMeter1 := 0
   oMeter1:Refresh()

   If T_TAREFAS->( EOF() )
      @ C(155),C(063) MsGet oGet6 Var cHtotal    Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
      @ C(168),C(063) MsGet oGet7 Var cRealiz    Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
      @ C(181),C(063) MsGet oGet8 Var cHSaldo    Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
      @ C(194),C(063) MsGet oGet9 Var cPercen    Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   Endif
      
   // Pesquisa as Horas total do Projeto
   nHTotalP := 0   
   nHTotalR := 0
   T_TAREFAS->( DbGoTop() )
   WHILE !T_TAREFAS->( EOF() )
      nHTotalP := nHTotalP + VAL(T_TAREFAS->ZZG_HTOT)
      T_TAREFAS->( DbSkip() )
   ENDDO
      
   cHtotal := Str(nHTotalP,5,1)

   // Pesquisa as horas trabalhadas
   If Select("T_REALIZADAS") > 0
      T_REALIZADAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZW_HORA"
   cSql += "  FROM " + RetSqlName("ZZW")
   cSql += " WHERE ZZW_PROJ = '" + Substr(cProjetos,01,06) + "'"
   cSql += "   AND ZZW_DELE = ' '"
        
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_REALIZADAS", .T., .T. )

   // Pesquisa as Horas total do Projeto
   nHTotalR := 0
   T_REALIZADAS->( DbGoTop() )
   WHILE !T_REALIZADAS->( EOF() )
      nHTotalR := nHTotalR + VAL(T_REALIZADAS->ZZW_HORA)
      T_REALIZADAS->( DbSkip() )
   ENDDO
      
   cRealiz := Str(nHTotalR,5,1)
   cHsaldo := Str((nHTotalP - nHTotalR),5,1)

   cPercen := Str(Round(((nHTotalR * 100) / nHTotalP),2),6,2)

   @ C(155),C(063) MsGet oGet6 Var cHtotal    Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(168),C(063) MsGet oGet7 Var cRealiz    Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(181),C(063) MsGet oGet8 Var cHSaldo    Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(194),C(063) MsGet oGet9 Var cPercen    Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   nMeter1 := Round(((nHTotalR * 100) / nHTotalP),2)
   
   If nMeter1 > 100
      nMeter1 := 100
   Endif
   
   oMeter1:Refresh()

   @ C(188),C(104) Say "0 %"                 Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(188),C(117) METER oMeter1 VAR nMeter1 Size C(110),C(008) NOPERCENTAGE    PIXEL OF oDlg
   @ C(188),C(231) Say "100 %"               Size C(016),C(008) COLOR CLR_BLACK PIXEL OF oDlg

Return .T.

// Função que abre a tela de informação de Data, Hora e Observações
Static Function __Apontamento( __Tipo, __Projeto, __Cliente, __Tarefa, __Data, __Hora, __Controle, __Nota)

   Local lChumba   := .F.

   Private cGet1	   := __Cliente
   Private cData	   := IIF(__Tipo == "I", Ctod("  /  /    "), Ctod(__Data))
   Private cHora	   := IIF(__Tipo == "I", Space(05), __Hora)
   Private cGet8	   := __Projeto
   Private cGet9	   := __Tarefa
   Private cGet10    := __Controle
   Private cUsuario  := Alltrim(cUserName)
   Private cMemo1	   := __Nota
   Private cVendedor := Space(06)
   Private cNomeVend := Space(60)

   Private oGet1
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
   Private oGet10
   Private oGet11
   Private oGet12
   Private oGet13
   Private oMemo1

   Private oDlgA

   // Verificase se houve seleção de uma projeto para apontamento
   If Alltrim(Upper(__Projeto)) == "SELECIONE UM PROJETO"
      Msgalert("Atenção!" + chr(13) + chr(13) + "Nenhuma tarefa foi selecionada para realizar apontamento de horas.")
      Return(.T.)
   Endif

   If __Tipo == "I"
      cData := Date()
      cHora := Space(05)
   Else
      // Verifica se o apontamento pertence ao usuário logado
	      DbSelectArea("ZZW")
      DbSetOrder(1)
      If DbSeek(cFilAnt + __Controle)
         If Alltrim(ZZW->ZZW_USUA) <> Alltrim(cUsuario)
            IF __Tipo == "A"
               Msgalert("Alteração não permitida. Apontamento pertence a outro usuário.")
            Else
               Msgalert("Exclusão não permitida. Apontamento pertence a outro usuário.")               
            Endif
            Return .T.            
         Endif

         cVendedor := ZZW->ZZW_VEND
         cNomeVend := Posicione("SA3", 1, xFilial("SA3") + cVendedor, "A3_NOME")

      Endif   
   Endif   

   If Empty(Alltrim(cHora))
      cHora := Space(05)
   Endif
      
   // Desenha a tela de apontamento da hora da tarefa selecionada
   DEFINE MSDIALOG oDlgA TITLE "Apontamento de Horas" FROM C(178),C(181) TO C(552),C(597) PIXEL

   @ C(004),C(005) Say "Projeto"                                    Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(025),C(005) Say "Cliente"                                    Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(047),C(005) Say "Tarefa"                                     Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(070),C(005) Say "Data"                                       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(070),C(052) Say "Hr"                                         Size C(007),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(070),C(178) Say "Controle"                                   Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(093),C(052) Say "Utilize Vírgula para representar meia hora" Size C(100),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(093),C(005) Say "Vendedor"                                   Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(115),C(005) Say "Observações"                                Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(173),C(005) Say "INCLUIR"                                    Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgA

   @ C(013),C(005) MsGet oGet8  Var cGet8     Size C(198),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA When lChumba
   @ C(035),C(005) MsGet oGet1  Var cGet1     Size C(198),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA When lChumba
   @ C(056),C(005) MsGet oGet9  Var cGet9     Size C(198),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA When lChumba
   @ C(080),C(005) MsGet oGet6  Var cData     Size C(041),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA
   @ C(080),C(052) MsGet oGet7  Var cHora     Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA
   @ C(080),C(075) MsGet oGet14 Var cUsuario  Size C(099),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA When lChumba
   @ C(080),C(178) MsGet oGet10 Var cGet10    Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA When lChumba
   @ C(102),C(005) MsGet oGet12 Var cVendedor Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA F3("SA3") VALID( CaptaVnd(cVendedor) )
   @ C(102),C(036) MsGet oGet13 Var cNomeVend Size C(167),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA When lChumba
   @ C(124),C(005) GET oMemo1 Var cMemo1 MEMO Size C(198),C(044) PIXEL OF oDlgA

   @ C(171),C(126) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgA ACTION(__GravaApon(__Tipo, cGet8, cGet1, cGet9, cData, Alltrim(cHora), cGet10, cMemo1, cUsuario, cVendedor))
   @ C(171),C(165) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgA ACTION(oDlgA:End())

   ACTIVATE MSDIALOG oDlgA CENTERED 

Return(.T.)

// Função que pesquisa o vendedor informado
Static Function captaVnd(_Vendedor)

   If Empty(Alltrim(_Vendedor))
      cVendedor := Space(06)
      cNomeVend := Space(60)
      oGet12:Refresh()
      oGet13:Refresh()
      Return(.T.)
   Endif
      
   cNomeVend := Posicione("SA3", 1, xFilial("SA3") + _Vendedor, "A3_NOME")

Return(.T.)

// Função que salva o apontamento
Static Function __GravaApon( __Tipo, __Projeto, __Cliente, __Tarefa, __Data, __Hora, __Controle, __Nota, __Usuario, __Vendedor)

   Local cProximo  := ""
   Local cSql      := ""
   Local nContar   := 0
   Local lPrimeiro := .T.

   // Consiste os dados antes da gravação
   If Empty(__Data)
      MsgAlert("Data do Apontamento não informada.")
      Return .T.
   Endif
      
   If Empty(__Hora)
      MsgAlert("Hora do Apontamento não informada.")
      Return .T.
   Endif

   __NovaHora := ""

   For nContar = 1 to Len(Alltrim(__Hora))
       If IsDigit(Substr(__Hora,nContar,1))
          __NovaHora := __NovaHora + Substr(__Hora,nContar,1)
       Else
          If lPrimeiro 
             __NovaHora := __NovaHora + "."
             lPrimeiro  := .F.
          Endif
       Endif
   Next nContar                    

   __Hora := __NovaHora

   // Pesquisa o código do desenvolvedor para gravação
   If Select("T_DESENVE") > 0
      T_DESENVE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZE_CODIGO"
   cSql += "  FROM " + RetSqlName("ZZE")
   cSql += " WHERE ZZE_LOGIN  = '" + Alltrim(UPPER(__Usuario)) + "'"
   cSql += "   AND ZZE_DELETE = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DESENVE", .T., .T. )

   // INCLUSÃO
   If __Tipo == "I"
   
      // Pesquisa o próximo código para inclusão
      If Select("T_NUMERO") > 0
         T_NUMERO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZW_CODIGO"
      cSql += "  FROM " + RetSqlName("ZZW")
      cSql += " ORDER BY ZZW_CODIGO DESC"
            
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NUMERO", .T., .T. )

      If T_NUMERO->( EOF() )
         cProximo := "000001"
      Else
         cProximo := STRZERO((INT(VAL(T_NUMERO->ZZW_CODIGO)) + 1),6)
      Endif
      
      // Inclui
      dbSelectArea("ZZW")
      RecLock("ZZW",.T.)
      ZZW_FILIAL := cFilAnt
      ZZW_CODIGO := cProximo
      ZZW_PROJ   := Substr(__Projeto,01,06)
      ZZW_CLIENT := Substr(__Cliente,01,06)
      ZZW_LOJA   := Substr(__Cliente,08,03)
      ZZW_TARE   := Substr(__Tarefa,01,06)
      ZZW_SEQU   := Substr(__Tarefa,08,02)
      ZZW_DATA   := __Data
      ZZW_HORA   := __Hora
      ZZW_NOTA   := __Nota
      ZZW_USUA   := __Usuario
      ZZW_CDES   := T_DESENVE->ZZE_CODIGO
      ZZW_DELE   := ""
      ZZW_VEND   := __Vendedor
      MsUnLock()
      
   Endif

   // Operação de Alteração
   If __Tipo == "A"

      DbSelectArea("ZZW")
      DbSetOrder(1)
      If DbSeek(cFilAnt + __Controle)
         RecLock("ZZW",.F.)
         ZZW_PROJ   := Substr(__Projeto,01,06)
         ZZW_CLIENT := Substr(__Cliente,01,06)
         ZZW_LOJA   := Substr(__Cliente,08,03)
         ZZW_TARE   := Substr(__Tarefa,01,06)
         ZZW_SEQU   := Substr(__Tarefa,08,02)
         ZZW_DATA   := __Data
         ZZW_HORA   := __Hora
         ZZW_NOTA   := __Nota
         ZZW_DELE   := ""
         ZZW_VEND   := __Vendedor
         MsUnLock()              
      Endif
      
   Endif

   // Operação de Exclusão
   If __tIPO == "E"

      If MsgYesNo("Confirma a exclusão deste registro?")

         DbSelectArea("ZZW")
         DbSetOrder(1)
         If DbSeek(cFilAnt + __Controle)
            RecLock("ZZW",.F.)
            ZZW_DELE := "X"
            MsUnLock()              
         Endif

      Endif   

   Endif

   OdlgA:End() 

   Carrega_Grid()

   H_Estatistica(cProjetos)
   
Return .T.

// Função que carrega o grid conforme a tarefa selecionada
Static Function Carrega_grid()

   Local cSql  := ""
   Local cSoma := 0

   If Len(aListBox) == 0
      cTotHoras := Space(03)
      cTrabalha := Space(03)
      cSaldo    := Space(03)
      @ C(155),C(290) MsGet oGet2 Var cTotHoras          Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
      @ C(168),C(290) MsGet oGet3 Var cTrabalha          Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
      @ C(181),C(290) MsGet oGet4 Var cSaldo             Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
      Return .T.
   Endif   

   // Carrega as horas apontadas para a tarefa selecionada
   If Select("T_HORAS") > 0
      T_HORAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZW_FILIAL,"
   cSql += "       ZZW_CODIGO,"
   cSql += "       ZZW_PROJ  ,"
   cSql += "       ZZW_CLIENT,"
   cSql += "       ZZW_LOJA  ,"
   cSql += "       ZZW_TARE  ,"
   cSql += "       ZZW_SEQU  ,"
   cSql += "       ZZW_DATA  ,"
   cSql += "       ZZW_HORA  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZW_NOTA)) AS NOTA,"
   cSql += "       ZZW_USUA  ,"
   cSql += "       ZZW_DELE   " 
   cSql += "  FROM " + RetSqlName("ZZW")
// cSql += " WHERE ZZW_FILIAL = '" + Alltrim(cFilAnt)        + "'"
   cSql += " WHERE ZZW_PROJ   = '" + Substr(cProjetos,01,06) + "'"
   cSql += "   AND ZZW_TARE   = '" + Substr(aListBox[oListBox1:nAt],01,06) + "'"
   cSql += "   AND ZZW_SEQU   = '" + Substr(aListBox[oListBox1:nAt],08,02) + "'"
   cSql += "   AND ZZW_DELE   = ''"
   cSql += " ORDER BY ZZW_DATA DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_HORAS", .T., .T. )

   aBrowse := {}
   cSoma   := 0
   
   If !T_HORAS->( EOF() )
   
      T_HORAS->( DbGoTop() )
      
      WHILE !T_HORAS->( EOF() )
      
         aAdd( aBrowse, { SUBSTR(T_HORAS->ZZW_DATA,07,02) + "/" + SUBSTR(T_HORAS->ZZW_DATA,05,02) + "/" + SUBSTR(T_HORAS->ZZW_DATA,01,04),;
                          T_HORAS->ZZW_HORA  ,;
                          T_HORAS->ZZW_USUA  ,;
                          T_HORAS->ZZW_CODIGO,;
                          T_HORAS->NOTA})

         cSoma := cSoma + VAL(T_HORAS->ZZW_HORA)

         T_HORAS->( DbSkip() )
         
      ENDDO
                                                             
   Else   

      aAdd( aBrowse, { '', '', '', '', ''} )

   Endif

   oBrowse:SetArray(aBrowse) 
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03] } }
   oBrowse:Refresh()

   cTrabalha := Str(cSoma,5,1)
   cSaldo    := Str((VAL(cTotHoras) - VAL(cTrabalha)),5,1)

   @ C(168),C(290) MsGet oGet3 Var cTrabalha          Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(181),C(290) MsGet oGet4 Var cSaldo             Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

Return .T.

// Abre tela de status da tarefa
Static Function TrocaHist()

   U_ESPHIS01(Substr(aListBox[oListBox1:nAt],01,06))

Return .T.