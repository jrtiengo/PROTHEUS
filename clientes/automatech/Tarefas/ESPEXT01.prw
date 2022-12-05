#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPEXT01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 11/06/2012                                                          *
// Objetivo..: Programa que registra tarefas Extra-Controle                        *
//**********************************************************************************

User Function ESPEXT01()

   Local cMemo10     := ""
   Local oMemo10

   Private aComboBx1 := {"Item01","Item02"}
   Private cComboBx1
   Private lSalvar   := .F.

   Private oDlg

   // Verifica se o usuário logado possui permissão para liberar tarefas
   If Select("T_USUARIO") > 0
      T_USUARIO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZA_CODI, "
   cSql += "       ZZA_NOME, "
   cSql += "       ZZA_EMAI, "
   cSql += "       ZZA_VISU  "
   cSql += "  FROM " + RetSqlName("ZZA")
   cSql += "WHERE RTRIM(LTRIM(UPPER(ZZA_NOME))) = '" + Upper(Alltrim(cUserName)) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIO", .T., .T. )
   
   If T_USUARIO->( EOF() )
      MsgAlert("Atenção! Você não possui permissão para realizar esta operação.")
      Return(.T.)
   Endif
            
   If T_USUARIO->ZZA_VISU <> "T"
      lSalvar := .T.
   Else
      lSalvar := .F.   
   Endif

   // Carrega o Combo de Desenvolvedores
   If Select("T_DESENVE") > 0
      T_DESENVE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZE_CODIGO, "
   cSql += "       ZZE_NOME    "
   cSql += "  FROM " + RetSqlName("ZZE")
   cSql += " WHERE ZZE_DELETE = ''"
   cSql += " ORDER BY ZZE_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DESENVE", .T., .T. )

   aComboBx1 := {}

   If !T_DESENVE->( EOF() )
      WHILE !T_DESENVE->( EOF() )
         aAdd( aComboBx1, T_DESENVE->ZZE_CODIGO + " - " + T_DESENVE->ZZE_NOME )
         T_DESENVE->( DbSkip() )
      ENDDO
   Endif

   DEFINE MSDIALOG oDlg TITLE "Tarefas Extra-Controle" FROM C(178),C(181) TO C(339),C(624) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(140),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo10 Var cMemo10 MEMO Size C(214),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Desenvolvedores" Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(046),C(005) ComboBox cComboBx1 Items aComboBx1 Size C(211),C(010) PIXEL OF oDlg

   @ C(062),C(072) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( JANELADES( cComboBx1 ))
   @ C(062),C(111) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Abre janela com as data do desenvolvedor selecionado
Static Function JanelaDes( cComboBx1 )

   Local lChumba   := .F.
   Local cGet1	   := cComboBx1
   Local oGet1

   Private cMemo1  := ""
   Private oMemo1
   Private aExtras := {}

   Private oDlgj

   If Empty(Alltrim(cComboBx1))
      Return .T.
   Endif

   aExtras := {}

   If Select("T_AGENDAS") > 0
      T_AGENDAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZN_DATA, "
   cSql += "       ZZN_PROG  "
   cSql += "  FROM " + RetSqlName("ZZN")
   cSql += " WHERE ZZN_DELE   = ''"
   cSql += "   AND ZZN_PROG   = '" + Alltrim(Substr(cComboBx1,01,06)) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += " ORDER BY ZZN_DATA DESC"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AGENDAS", .T., .T. )

   If T_AGENDAS->( EOF() )
      aAdd( aExtras, { '' } )
   Else
      T_AGENDAS->( DbGoTop() )
      WHILE !T_AGENDAS->( EOF() )
         aAdd( aExtras, { Substr(T_AGENDAS->ZZN_DATA,07,08) + "/" + Substr(T_AGENDAS->ZZN_DATA,05,02) + "/" + Substr(T_AGENDAS->ZZN_DATA,01,04)} )
         T_AGENDAS->( DbSkip() )
      ENDDO
   Endif

   DEFINE MSDIALOG oDlgj TITLE "Tarefas Extra-Controle" FROM C(178),C(181) TO C(526),C(893) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(140),C(026) PIXEL NOBORDER OF oDlgj

   @ C(030),C(004) Say "Datas"                                       Size C(017),C(008) COLOR CLR_BLACK PIXEL OF oDlgj
   @ C(030),C(078) Say "Detalhes da Data Selecionada"                Size C(075),C(008) COLOR CLR_BLACK PIXEL OF oDlgj
   @ C(030),C(252) Say "Duplo click sobre a data, visualiza detalhe" Size C(101),C(008) COLOR CLR_BLACK PIXEL OF oDlgj

   @ C(040),C(077) GET oMemo1 Var cMemo1 MEMO Size C(275),C(115) PIXEL OF oDlgj

   @ C(010),C(182) MsGet oGet1 Var cGet1 When lChumba Size C(170),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgj

   @ C(159),C(020) Button "Transf.Horas" Size C(037),C(012) PIXEL OF oDlgj ACTION( Envia_as_Horas(aExtras[oExtras:nAt,01], Substr(cComboBx1,01,06)) ) When lSalvar
   @ C(159),C(193) Button "Incluir"      Size C(037),C(012) PIXEL OF oDlgj ACTION( MANUJAN( "I", aExtras[oExtras:nAt,01], cComboBx1 ) ) When lSalvar
   @ C(159),C(233) Button "Alterar"      Size C(037),C(012) PIXEL OF oDlgj ACTION( MANUJAN( "A", aExtras[oExtras:nAt,01], cComboBx1 ) ) When lSalvar
   @ C(159),C(274) Button "Excluir"      Size C(037),C(012) PIXEL OF oDlgj ACTION( MANUJAN( "E", aExtras[oExtras:nAt,01], cComboBx1 ) ) When lSalvar
   @ C(159),C(315) Button "Voltar"       Size C(037),C(012) PIXEL OF oDlgj ACTION( oDlgj:End() )

   // Cria objeto grid
   oExtras := TCBrowse():New( 051 , 004, 090, 149,,{'Datas'},{20,50,50,50},oDlgj,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oExtras:SetArray(aExtras) 
   oExtras:bLine := {||{ aExtras[oExtras:nAt,01] } }
   oExtras:bLDblClick := {|| MOSTRADET(aExtras[oExtras:nAt,01], Substr(cComboBx1,01,06) ) } 

   MOSTRADET(aExtras[oExtras:nAt,01], Substr(cComboBx1,01,06) )

   ACTIVATE MSDIALOG oDlgj CENTERED 

Return(.T.)

// Função que mostra os detalhes da data selecionada
Static Function MOSTRADET( _Data, _Programador )

   Local cSql   := ""
   Local ctexto := ""

   // Verifica se já existe registro para a data/programador
   If Select("T_CHAVE") > 0
      T_CHAVE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZN_DATA , "
   cSql += "       ZZN_PROG , "
   cSql += "       ZZN_CHAV1, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZN_CHAVE)) AS DESCRICAO"
   cSql += "  FROM " + RetSqlName("ZZN")
   cSql += " WHERE ZZN_DATA   = '" + Substr(_Data,07,04) + Substr(_Data,04,02) + Substr(_Data,01,02) + "'"
   cSql += "   AND ZZN_PROG   = '" + Alltrim(Substr(_Programador,01,06)) + "'"
   cSql += "   AND ZZN_DELE   = ''"
   cSql += "   AND D_E_L_E_T_ = ''"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CHAVE", .T., .T. )

   If T_CHAVE->( EOF() )
      Return .T.
   Endif
      
   cMemo1 := Alltrim(T_CHAVE->DESCRICAO)
   oMemo1:Refresh()
   
Return .t.   

// Função que abre janela de manutenção dos dados (Inclusão, Alterarção e Exclusão)
Static Function MANUJAN( _Tipo, _Data, _Programador )

   Local cSql           := ""
   Local cEscrita       := ""
   Local lChumba        := .F.
   Local lFechado       := .F.

   Private cData	    := Ctod("  /  /    ")
   Private cProgramador := _Programador
   Private cTexto  	    := ""

   Private oGet2
   Private oGet3
   Private oMemo1

   Private oDlgm

   If _Tipo == "I"
      lChumba := .T.
   Else             
      lChumba := .F.
      cData   := Ctod(Substr(_Data,01,02) + "/" + Substr(_Data,04,02) + "/" + Substr(_Data,07,04))

      // Verifica se já existe registro para a data/programador
      If Select("T_CHAVE") > 0
         T_CHAVE->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZN_DATA , "
      cSql += "       ZZN_PROG , "
      cSql += "       ZZN_CHAV1, "
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZN_CHAVE)) AS DESCRICAO"
      cSql += "  FROM " + RetSqlName("ZZN")
      cSql += " WHERE ZZN_DATA   = '" + Substr(_Data,07,04) + Substr(_Data,04,02) + Substr(_Data,01,02) + "'"
      cSql += "   AND ZZN_PROG   = '" + Alltrim(Substr(_Programador,01,06)) + "'"
      cSql += "   AND ZZN_DELE   = ''"
      cSql += "   AND D_E_L_E_T_ = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CHAVE", .T., .T. )

      If T_CHAVE->( EOF() )
         Return .T.
      Endif
      
      cTexto := Alltrim(T_CHAVE->DESCRICAO)

   Endif

   DEFINE MSDIALOG oDlgm TITLE "Tarefas Extra-Controle" FROM C(178),C(181) TO C(526),C(904) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(140),C(026) PIXEL NOBORDER OF oDlgm
   
   @ C(030),C(004) Say "Datas"                                 Size C(017),C(008) COLOR CLR_BLACK PIXEL OF oDlgm
   @ C(030),C(046) Say "Programador"                           Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgm
   @ C(052),C(004) Say "Descrição das Atividades Extra-Agenda" Size C(096),C(008) COLOR CLR_BLACK PIXEL OF oDlgm
   
   @ C(040),C(004) MsGet oGet2 Var cData        When lChumba  Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgm
   @ C(040),C(046) MsGet oGet3 Var cProgramador When lFechado Size C(158),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgm

   @ C(062),C(004) GET oMemo1 Var cTexto MEMO Size C(353),C(94) PIXEL OF oDlgm

   @ C(159),C(281) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgm ACTION( SALVAEXTRA(_Tipo) )
   @ C(159),C(320) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgm ACTION( oDlgm:End() )

   ACTIVATE MSDIALOG oDlgm CENTERED 

Return(.T.)

// Altera Valor da Variável lLibera e lChumba
Static Function SalvaExtra( _Operacao )

   Local cSql := ""

   // Operação de Inclusão
   If _Operacao == "I"

      If Empty(cData)
         MsgAlert("Data não informada. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(cTexto))
         MsgAlert("Descritivo da Tarefa não informada. Verique !!")
         Return .T.
      Endif   

      // Verifica se já existe registro para a data/programador
      If Select("T_JATEM") > 0
         T_JATEM->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZN_DATA, "
      cSql += "       ZZN_PROG  "
      cSql += "  FROM " + RetSqlName("ZZN")
      cSql += " WHERE ZZN_DELE   = ''"
      cSql += "   AND ZZN_DATA   = '" + Substr(Dtoc(cData),07,04) + Substr(Dtoc(cData),04,02) + Substr(Dtoc(cData),01,02) + "'"
      cSql += "   AND ZZN_PROG   = '" + Alltrim(Substr(cProgramador,01,06)) + "'"
      cSql += "   AND ZZN_DELE   = ''"
      cSql += "   AND D_E_L_E_T_ = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JATEM", .T., .T. )

      If !T_JATEM->( EOF() )
         MsgAlert("Atenção! Já existe registro para esta data/programador. Verifique !!")
         Return .T.
      Endif

      // Inseri os dados na Tabela
      aArea := GetArea()

      dbSelectArea("ZZN")
      RecLock("ZZN",.T.)
      ZZN_DATA  := cData
      ZZN_PROG  := cProgramador
      ZZN_CHAVE := cTexto
      ZZN_DELE  := ""
      MsUnLock()

   Endif

   // Operação de Alteração
   If _Operacao == "A"

      cSql := ""
      cSql := "UPDATE " + RetSqlName("ZZN")
      cSql += "   SET"
      cSql += "   ZZN_CHAVE      = '" + Alltrim(cTexto) + "'"
      cSql += " WHERE ZZN_DATA   = '" + Substr(Dtoc(cData),07,04) + Substr(Dtoc(cData),04,02) + Substr(Dtoc(cData),01,02) + "'"
      cSql += "   AND ZZN_PROG   = '" + Alltrim(Substr(cProgramador,01,06)) + "'"
      cSql += "   AND ZZN_DELE   = ''"
      cSql += "   AND D_E_L_E_T_ = ''"

      TCSQLEXEC(cSql)

   Endif

   // Operação de Exclusão
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclusão deste registro?")

         cSql := ""
         cSql := "UPDATE " + RetSqlName("ZZN")
         cSql += "   SET"
         cSql += "   ZZN_DELE       = 'X'"
         cSql += " WHERE ZZN_DATA   = '" + Substr(Dtoc(cData),07,04) + Substr(Dtoc(cData),04,02) + Substr(Dtoc(cData),01,02) + "'"
         cSql += "   AND ZZN_PROG   = '" + Alltrim(Substr(cProgramador,01,06)) + "'"
         cSql += "   AND ZZN_DELE   = ''"
         cSql += "   AND D_E_L_E_T_ = ''"

         TCSQLEXEC(cSql)

      Endif   

   Endif

   ODlgm:End()

   aExtras := {}

   If Select("T_AGENDAS") > 0
      T_AGENDAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZN_DATA, "
   cSql += "       ZZN_PROG, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZN_CHAVE)) AS DESCRICAO"
   cSql += "  FROM " + RetSqlName("ZZN")
   cSql += " WHERE ZZN_DELE   = ''"
   cSql += "   AND ZZN_PROG   = '" + Alltrim(Substr(cComboBx1,01,06)) + "'"
   cSql += "   AND ZZN_DELE   = ''"
   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += " ORDER BY ZZN_DATA DESC"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AGENDAS", .T., .T. )

   If T_AGENDAS->( EOF() )
      aAdd( aExtras, { '' } )
   Else
      T_AGENDAS->( DbGoTop() )
      WHILE !T_AGENDAS->( EOF() )
         aAdd( aExtras, { Substr(T_AGENDAS->ZZN_DATA,07,08) + "/" + Substr(T_AGENDAS->ZZN_DATA,05,02) + "/" + Substr(T_AGENDAS->ZZN_DATA,01,04)} )
         T_AGENDAS->( DbSkip() )
      ENDDO
   Endif

   // Seta vetor para a browse                            
   oExtras:SetArray(aExtras) 
    
   oExtras:bLine := {||{ aExtras[oExtras:nAt,01] } }

   oExtras:bLDblClick := {|| MOSTRADET(aExtras[oExtras:nAt,01], Substr(cComboBx1,01,06) ) } 

   MOSTRADET(aExtras[oExtras:nAt,01], Substr(cComboBx1,01,06) )

Return Nil                                                                   

// Função que realiza a transferência de apontamentos para as tarefas do projeto
Static Function Envia_as_Horas(__Data, __Usuario)

   Local lChumba   := .F.
   Local aDesenve  := {}
   Local dInicial  := Ctod("  /  /    ")
   Local dFinal    := Ctod("  /  /    ")
   Local cProjeto  := "000017 - PROTHEUS"
   Local cTarefap  := "000733 - DESENVOLVIMENTO/SUPORTE"
   Local nContar   := 0

   Local cComboBx1
   Local cMemo1	   := ""
   Local oMemo1

   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4

   Private oDlgT

   dInicial := __Data

   // Carrega combobox com os usuários
   If Select("T_DESENVE") > 0
      T_DESENVE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZE_CODIGO,"
   cSql += "       ZZE_NOME   "
   cSql += "  FROM " + RetSqlName("ZZE")
   cSql += " WHERE ZZE_DELETE = ''"
   cSql += " ORDER BY ZZE_NOME"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DESENVE", .T., .T. )

   // Carrega o Combo dos Projetos
   aDesenvolve := {}
   aAdd( aDesenvolve, "Selecione o Desenvolvedor" )
   T_DESENVE->( EOF() )
   WHILE !T_DESENVE->( EOF() )
      aAdd( aDesenvolve, T_DESENVE->ZZE_CODIGO + " - " + Alltrim(T_DESENVE->ZZE_NOME) )
      T_DESENVE->( DbSkip() )
   ENDDO

   // Posiciona o Usuário
   For nContar = 1 to Len(aDesenvolve)
       If Substr(aDesenvolve[nContar],01,06) == Alltrim(__Usuario)
          cComboBx1 := aDesenvolve[nContar]
          Exit
       Endif
   Next nContar

   DEFINE MSDIALOG oDlgT TITLE "Transferência de Apontamentos" FROM C(178),C(181) TO C(461),C(580) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(134),C(026) PIXEL NOBORDER OF oDlgT

   @ C(031),C(002) GET oMemo1 Var cMemo1 MEMO Size C(190),C(001) PIXEL OF oDlgT

   @ C(037),C(005) Say "Data a Transferir" Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
// @ C(037),C(047) Say "Data Final"        Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(059),C(005) Say "Usuário"           Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(079),C(005) Say "Projeto"           Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(100),C(005) Say "Tarefa do Projeto" Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   
   @ C(046),C(005) MsGet    oGet1     Var   dInicial    Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT When lChumba
// @ C(046),C(047) MsGet    oGet2     Var   dFinal      Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT
   @ C(067),C(005) ComboBox cComboBx1 Items aDesenvolve Size C(188),C(010)                              PIXEL OF oDlgT When lChumba
   @ C(088),C(005) MsGet    oGet3     Var   cProjeto    Size C(188),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT When lChumba
   @ C(108),C(005) MsGet    oGet4     Var   cTarefap    Size C(188),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT When lChumba

   @ C(124),C(061) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgT ACTION( xEnviaHoras(dInicial, dFinal, cProjeto, cTarefap, cComboBx1 ) )
   @ C(124),C(100) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgT ACTION( oDlgT:End() )

   ACTIVATE MSDIALOG oDlgT CENTERED 

Return(.T.)

// Função que realiza a transferência de apontamentos para a tarefa de horas dos projetos
Static Function xEnviaHoras( _dInicial, _dFinal, _Projeto, _Tarefap, _Usuario )

   Local cTexto      := ""
   Local cObservacao := ""
   Local nContar     := 0
   Local nVezes      := 0
   Local aHoras      := {}
   Local nHoras      := 0
   Local nMinutos    := 0
   Local cTotHoras   := ""
   Local cProximo    := ""

   If Empty(_Dinicial)
      MsgAlert("Data inicial de transferência de horário não informado.")
      Return(.T.)
   Endif
      
//   If Empty(_Dfinal)
//      MsgAlert("Data final de transferência de horário não informado.")
//      Return(.T.)
//   Endif

   If Substr(_Usuario,01,06) == "000000"
      MsgAlert("Desenvolvedor não selecionado.")
      Return(.T.)
   Endif

   // Captura a quantidade de horas referente a horas extras-tarefas
   If Select("T_EXTRAS") > 0
      T_EXTRAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZN_DATA , "
   cSql += "       ZZN_PROG , "
   cSql += "       ZZN_CHAV1, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZN_CHAVE)) AS DESCRICAO"
   cSql += "  FROM " + RetSqlName("ZZN")
   cSql += " WHERE ZZN_DATA    = CONVERT(DATETIME,'" + _dInicial + "', 103)" + CHR(13)
   cSql += "   AND ZZN_PROG    = '" + Substr(_Usuario,01,06)     + "'"
   cSql += "   AND ZZN_DELE    = ''"
   cSql += "   AND D_E_L_E_T_  = ''"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EXTRAS", .T., .T. )
   
   If T_EXTRAS->( EOF() )
      MsgAlert("Não existem horas de apontamentos a serem transferidos.")
      Return(.T.)
   Endif

   cObservacao := T_EXTRAS->DESCRICAO

   cTexto := ""
   cTexto := Strtran(T_EXTRAS->DESCRICAO, chr(13), "#")
   nVezes := U_P_OCCURS(ctexto, "#", 1)

   For nContar = 1 to nVezes
       aAdd( aHoras, U_P_CORTA(U_P_CORTA(TRIM(cTexto), "#", nContar),"@",2) )
   Next nContar

   nHoras    := 0
   nMinutos  := 0
   cTotHoras := ""
      
   // Soma as horas para gravação
   For nContar = 1 to Len(aHoras)
       nHoras   := nHoras   + VAL(Substr(aHoras[nContar],01,02))
       nMinutos := nMinutos + Val(Substr(aHoras[nContar],04,02))
   Next nContar

   nTotHoras := Strzero(nHoras + Int(nMinutos / 60),2) + ":" + Strzero(Mod(nMinutos,60),2)

   // Grava o Apontamento

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
   ZZW_PROJ   := Substr(_Projeto,01,06)
   ZZW_CLIENT := "000329"
   ZZW_LOJA   := "001"
   ZZW_TARE   := Substr(_Tarefap,01,06)
   ZZW_DATA   := Ctod(_dInicial)
   ZZW_HORA   := nTotHoras
   ZZW_NOTA   := cObservacao
   ZZW_USUA   := Substr(_Usuario,10)
   ZZW_CDES   := Substr(_Usuario,01,06)
   ZZW_DELE   := ""
   MsUnLock()
      
   Msgalert("Horário transfereido com sucesso.")

   oDlgT:End()

Return(.T.)