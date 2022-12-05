#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ATVMOV02.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 30/07/2012                                                          *
// Objetivo..: Programa de Movimentação de Atividades - Realizado                  *
//**********************************************************************************

User Function ATVMOV02( _Atividade, _Area, _Registro, _Data1, _Data2, _Adm, _Supervisor, _Normal, _Agrupado)

   Local lChumba    := .F.
   Local ctexto     := ""
   Local cSql       := ""

   Local cCodigo    := _Atividade
   Local cAbertura  := ""
   Local cNArea	    := Space(40)
   Local cStatus    := Space(25)
   Local cUsuario   := Space(20)
   Local cAtividade := Space(40)
   Local cResponsa  := Space(40)
   Local cDetalhe   := ""
   Local cPara      := Space(40)
   Local cAgenda    := Space(25)
   Local cDe01	    := Ctod("  /  /    ")
   Local cAte01	    := Ctod("  /  /    ")
   Local cDe02      := 0
   Local cAte02     := 0
   Local cReal	    := Ctod("  /  /    ")
   Local cAlcada    := Ctod("  /  /    ")
   Local cProblema  := ""
   Local cMelhoras  := ""
   Local cMes       := 0
   Local cAno       := 0

   Local oGet1
   Local oGet11
   Local oGet12
   Local oGet13
   Local oGet14
   Local oGet15
   Local oGet16
   Local oGet17
   Local oGet18
   Local oGet4
   Local oGet5
   Local oGet6
   Local oGet7
   Local oGet8
   Local oGet9
   Local oMemo1
   Local oMemo2
   Local oMemo3
   Local oGet19
   Local oGet20

   Private oDlg

   Default _Data1      := Ctod("  /  /    ")
   Default _Data2      := Ctod("  /  /    ")

   // Pesquisa os dados da atividade para display
   If Select("T_ATIVIDADE") > 0
      T_ATIVIDADE->( dbCloseArea() )
   EndIf

   cSql := "SELECT A.ZZV_FILIAL,"
   cSql += "       A.ZZV_CODIGO,"
   cSql += "       A.ZZV_DATA  ,"
   cSql += "       A.ZZV_AREA  ,"
   cSql += "       A.ZZV_STATUS,"
   cSql += "       A.ZZV_ATIV  ,"
   cSql += "       A.ZZV_PERI  ,"
   cSql += "       A.ZZV_PARA  ,"
   cSql += "       A.ZZV_USUA  ,"
   cSql += "       B.ZZU_NOME  ,"                             	
   cSql += "       C.ZZR_NOME  ,"
   cSql += "       D.ZZT_NORM  ,"
   cSql += "       D.ZZT_SUPE  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), B.ZZU_DETA)) AS DETALHE"
   cSql += "  FROM " + RetSqlName("ZZV") + " A, "
   cSql += "       " + RetSqlName("ZZU") + " B, "
   cSql += "       " + RetSqlName("ZZR") + " C, "
   cSql += "       " + RetSqlName("ZZT") + " D  "
   cSql += " WHERE A.ZZV_DELETE = ''"
   cSql += "   AND A.ZZV_CODIGO = '" + Alltrim(_Atividade) + "'"
   cSql += "   AND A.ZZV_AREA   = '" + Alltrim(_Area)      + "'"
   cSql += "   AND A.ZZV_ATIV   = B.ZZU_CODIGO"
   cSql += "   AND B.ZZU_DELETE = ''"
   cSql += "   AND A.ZZV_AREA   = C.ZZR_CODIGO"
   cSql += "   AND C.ZZR_DELETE = ''"
   cSql += "   AND A.ZZV_USUA   = D.ZZT_USUA  "
   cSql += "   AND D.ZZT_DELETE = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATIVIDADE", .T., .T. )
   
   cAbertura  := Substr(T_ATIVIDADE->ZZV_DATA,07,02) + "/" + Substr(T_ATIVIDADE->ZZV_DATA,05,02) + "/" + Substr(T_ATIVIDADE->ZZV_DATA,01,04)
   cNarea     := T_ATIVIDADE->ZZR_NOME
   cStatus    := IIF(T_ATIVIDADE->ZZV_STATUS == "A", "ATIVA", "INATIVA")
   cUsuario   := T_ATIVIDADE->ZZV_USUA
   cAtividade := T_ATIVIDADE->ZZU_NOME
   cResponsa  := T_ATIVIDADE->ZZT_NORM
   cPara      := T_ATIVIDADE->ZZV_PARA
   cDetalhe   := T_ATIVIDADE->DETALHE

   // Diário
   If U_P_CORTA(T_ATIVIDADE->ZZV_PERI, "|", 1) == "T"
      cAgenda := "DIARIA"
      cDe01	  := 0
      cAte01  := 0
      cDe02   := 0
      cAte02  := 0
   Endif
         
   // Semanal
   If U_P_CORTA(T_ATIVIDADE->ZZV_PERI, "|", 2) == "T"
      cAgenda := "SEMANAL"
      cDe01	  := 0
      cAte01  := 0
      cDe02   := 0
      cAte02  := 0
   Endif
   
   // Quinzenal
   If U_P_CORTA(T_ATIVIDADE->ZZV_PERI, "|", 10) == "T"
      cAgenda := "QUINZENAL"
      cDe01	  := U_P_CORTA(T_ATIVIDADE->ZZV_PERI, "|", 11)
      cAte01  := U_P_CORTA(T_ATIVIDADE->ZZV_PERI, "|", 12)
      cDe02   := U_P_CORTA(T_ATIVIDADE->ZZV_PERI, "|", 13)
      cAte02  := U_P_CORTA(T_ATIVIDADE->ZZV_PERI, "|", 14)
   Endif

   // Mensal
   If U_P_CORTA(T_ATIVIDADE->ZZV_PERI, "|", 15) == "T"
      cAgenda := "MENSAL"
      cDe01	  := U_P_CORTA(T_ATIVIDADE->ZZV_PERI, "|", 16)
      cAte01  := U_P_CORTA(T_ATIVIDADE->ZZV_PERI, "|", 17)
      cDe02   := 0
      cAte02  := 0
   Endif

   // Anual
   If U_P_CORTA(T_ATIVIDADE->ZZV_PERI, "|", 18) == "T"
      cAgenda := "MENSAL"
      cDe01	  := U_P_CORTA(T_ATIVIDADE->ZZV_PERI, "|", 19)
      cAte01  := U_P_CORTA(T_ATIVIDADE->ZZV_PERI, "|", 20)
      cDe02   := 0
      cAte02  := 0
   Endif

   cMes := U_P_CORTA(T_ATIVIDADE->ZZV_PERI, "|", 21)
   cAno := U_P_CORTA(T_ATIVIDADE->ZZV_PERI, "|", 22)

   If !Empty(_Data1)
      cDe01	  := _Data1
      cAte01  := _Data2
   Endif

   // Pesquisa a Data real de execusão e a data da alçada
   If Select("T_REAL") > 0
      T_REAL->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZX_REAL,"
   cSql += "       ZZX_ALCA,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZX_PROB)) AS PROBLEMA,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZX_MELH)) AS MELHORAS "
   cSql += "  FROM " + RetSqlName("ZZX")
   cSql += " WHERE R_E_C_N_O_ = '" + Alltrim(_Registro) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_REAL", .T., .T. )
   
   cReal     := Ctod(Substr(T_REAL->ZZX_REAL,07,02) + "/" + Substr(T_REAL->ZZX_REAL,05,02) + "/" + Substr(T_REAL->ZZX_REAL,01,04))
   cAlcada   := Ctod(Substr(T_REAL->ZZX_ALCA,07,02) + "/" + Substr(T_REAL->ZZX_ALCA,05,02) + "/" + Substr(T_REAL->ZZX_ALCA,01,04))
   cProblema := T_REAL->PROBLEMA
   cMelhoras := T_REAL->MELHORAS

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Atividades" FROM C(178),C(181) TO C(588),C(943) PIXEL

   @ C(004),C(006) Say "Código"                          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(004),C(035) Say "Abertura"                        Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(004),C(077) Say "Área"                            Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(004),C(191) Say "Status"                          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(004),C(252) Say "Usuário"                         Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(027),C(006) Say "Atividade"                       Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(027),C(252) Say "Responsável Usuário"             Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(048),C(313) Say "para Quem"                       Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(049),C(006) Say "Detalhes da Atividade"           Size C(056),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(049),C(252) Say "Agendamento"                     Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(072),C(252) Say "Execução da Atividade em (Data)" Size C(081),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(084),C(252) Say "Inicial"                         Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(083),C(324) Say "Final"                           Size C(012),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(097),C(252) Say "Mês"                             Size C(010),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(097),C(269) Say "Ano"                             Size C(010),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(097),C(298) Say "Realizado em"                    Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   If _Agrupado
      @ C(097),C(338) Say "Supervisão"                      Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   Endif
      
   @ C(117),C(006) Say "Observações Gerais (Problemas)"  Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(117),C(194) Say "Sugestão de Melhorias"           Size C(056),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   If Empty(cReal) .Or. Empty(cAlcada)
      @ C(014),C(006) MsGet oGet1  Var cCodigo        When lChumba Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(014),C(035) MsGet oGet4  Var cAbertura      When lChumba Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(014),C(077) MsGet oGet11 Var cNarea         When lChumba Size C(104),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(014),C(192) MsGet oGet12 Var cStatus        When lChumba Size C(050),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(014),C(252) MsGet oGet13 Var cUsuario       When lChumba Size C(123),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(036),C(006) MsGet oGet18 Var cAtividade     When lChumba Size C(237),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(036),C(252) MsGet oGet5  Var cResponsa      When lChumba Size C(124),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(059),C(006) GET oMemo1   Var cDetalhe MEMO  When lChumba Size C(237),C(057) PIXEL OF oDlg
      @ C(058),C(312) MsGet oGet6  Var cPara          When lChumba Size C(064),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(058),C(253) MsGet oGet14 Var cAgenda        When lChumba Size C(055),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(083),C(269) MsGet oGet7  Var cDe01          When lChumba Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(083),C(339) MsGet oGet8  Var cAte01         When lChumba Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(106),C(253) MsGet oGet19 Var cMes           When lChumba Size C(012),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(106),C(269) MsGet oGet20 Var cAno           When lChumba Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(106),C(298) MsGet oGet9  Var cReal          When  Empty(cReal) .Or. T_ATIVIDADE->ZZT_NORM == "T" Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

      If _Agrupado
         @ C(106),C(339) MsGet oGet17 Var cAlcada Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      Endif   

      @ C(126),C(006) GET oMemo2   Var cProblema MEMO              Size C(184),C(058) PIXEL OF oDlg
      @ C(127),C(193) GET oMemo3   Var cMelhoras MEMO              Size C(182),C(058) PIXEL OF oDlg

      @ C(188),C(154) Button "Salvar" Size C(037),C(012) PIXEL OF oDlg ACTION( SalvaAtiv(_Registro, cReal, cAlcada, cProblema, cMelhoras ) )
      @ C(188),C(192) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )
   Else
      @ C(014),C(006) MsGet oGet1  Var cCodigo        When lChumba Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(014),C(035) MsGet oGet4  Var cAbertura      When lChumba Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(014),C(077) MsGet oGet11 Var cNarea         When lChumba Size C(104),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(014),C(192) MsGet oGet12 Var cStatus        When lChumba Size C(050),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(014),C(252) MsGet oGet13 Var cUsuario       When lChumba Size C(123),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(036),C(006) MsGet oGet18 Var cAtividade     When lChumba Size C(237),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(036),C(252) MsGet oGet5  Var cResponsa      When lChumba Size C(124),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(059),C(006) GET oMemo1   Var cDetalhe MEMO  When lChumba Size C(237),C(057) PIXEL OF oDlg
      @ C(058),C(312) MsGet oGet6  Var cPara          When lChumba Size C(064),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(058),C(253) MsGet oGet14 Var cAgenda        When lChumba Size C(055),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(083),C(269) MsGet oGet7  Var cDe01          When lChumba Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(083),C(339) MsGet oGet8  Var cAte01         When lChumba Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(106),C(253) MsGet oGet19 Var cMes           When lChumba Size C(012),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(106),C(269) MsGet oGet20 Var cAno           When lChumba Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(106),C(298) MsGet oGet9  Var cReal          When lChumba Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(106),C(339) MsGet oGet17 Var cAlcada        When lChumba Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

      @ C(126),C(006) GET oMemo2   Var cProblema MEMO When lChumba Size C(184),C(058) PIXEL OF oDlg
      @ C(127),C(193) GET oMemo3   Var cMelhoras MEMO When lChumba Size C(182),C(058) PIXEL OF oDlg

      @ C(188),C(154) Button "Salvar" When lChumba Size C(037),C(012) PIXEL OF oDlg ACTION( SalvaAtiv(_Registro, cReal, cAlcada, cProblema, cMelhoras ) )
      @ C(188),C(192) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )
   Endif   

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que atualiza a tabela ZZX com os dados informados na tela.
Static Function SALVAATIV( nRegistro, dReal, dAlcada, _Problema, _Melhoras )

   Local cSql     := ""
   Local __Real   := ""
   Local __Alcada := ""

   If Empty(dReal) .And. Empty(dAlcada)
      Return .T.
   endif

   __Real   := Strzero(year(dReal)  ,4) + Strzero(Month(dreal)  ,2) + Strzero(Day(dReal)  ,2)
   __Alcada := Strzero(year(dAlcada),4) + Strzero(Month(dAlcada),2) + Strzero(Day(dAlcada),2)

   cSql := ""
   cSql := "UPDATE " + RetSqlName("ZZX")
   cSql += "   SET "

   cSql += " ZZX_PROB = '" + Alltrim(_Problema) + "',"
   cSql += " ZZX_MELH = '" + Alltrim(_Melhoras) + "' "

   If !Empty(dReal)
      cSql += " ,ZZX_REAL = '" + Alltrim(__Real)   + "'"
      If !Empty(dAlcada)
         cSql += " , "
      Endif   
   endif

   If !Empty(dAlcada)      
      cSql += "   ZZX_ALCA = '" + Alltrim(__Alcada) + "' "
   Endif
      
   cSql += " WHERE R_E_C_N_O_ = '" + Alltrim(STR(INT(VAL(nRegistro)))) + "'"      

   lResult := TCSQLEXEC(cSql)
   If lResult < 0
      Return MsgStop("Erro durante a atualização da atividade: " + TCSQLError())
   EndIf

   oDlg:End()

Return .T.