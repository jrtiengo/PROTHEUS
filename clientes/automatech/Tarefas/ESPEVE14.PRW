#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPEVE14.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 11/10/2012                                                          *
// Objetivo..: Visualiza��o de Aprova��o/Reprova��o de Agendamento de Eventos      *
//**********************************************************************************

User Function ESPEVE14(_Codigo)

   Local cSql        := ""
   Local lChumba     := .F.

   Private cUsuario	 := Space(40)
   Private cAno 	 := Space(04)
   Private cCodigo	 := _Codigo
   Private cData	 := Ctod("  /  /    ")
   Private cTempo	 := Space(02)
   Private cEvento	 := Space(40)
   Private cNota	 := ""
   Private cLinha	 := ""
   Private cTexto	 := ""

   Private lAprova	 := .F.
   Private lReprova	 := .F.

   Private oCheckBox1
   Private oCheckBox2
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oMemo1
   Private oMemo2
   Private oMemo3

   Private oDlg

   If Select("T_AGENDA") > 0
      T_AGENDA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZ2_CODIGO, "
   cSql += "       A.ZZ2_USUA  , "
   cSql += "       B.ZZE_NOME  , "
   cSql += "       A.ZZ2_ANO   , "
   cSql += "       A.ZZ2_EVEN  , "
   cSql += "       C.ZZS_NOME  , "
   cSql += "       A.ZZ2_DATA  , "
   cSql += "       A.ZZ2_AUTO  , "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZZ2_NOTA))  AS DESCRICAO,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZZ2_TEXTO)) AS JUSTIFICA,"
   cSql += "       A.ZZ2_TEMPO   "
   cSql += "  FROM " + RetSqlName("ZZ2") + " A, "
   cSql += "       " + RetSqlName("ZZE") + " B, "
   cSql += "       " + RetSqlName("ZZS") + " C  "
   cSql += " WHERE A.ZZ2_DELETE = ''"  
   cSql += "   AND A.ZZ2_CODIGO = '" + Alltrim(cCodigo) + "'"
   cSql += "   AND A.ZZ2_USUA   = B.ZZE_CODIGO "
   cSql += "   AND B.ZZE_DELETE = ''"
   cSql += "   AND A.ZZ2_EVEN   = C.ZZS_CODIGO "
   cSql += "   AND C.ZZS_DELETE = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AGENDA", .T., .T. )

   cUsuario	 := T_AGENDA->ZZE_NOME
   cAno 	 := T_AGENDA->ZZ2_ANO
   cCodigo	 := T_AGENDA->ZZ2_CODIGO
   cData	 := Ctod(Substr(T_AGENDA->ZZ2_DATA,07,02) + "/" + Substr(T_AGENDA->ZZ2_DATA,05,02) + "/" + Substr(T_AGENDA->ZZ2_DATA,01,04))
   cTempo	 := T_AGENDA->ZZ2_TEMPO
   cEvento	 := T_AGENDA->ZZS_NOME
   cNota	 := T_AGENDA->DESCRICAO
   cLinha	 := ""

   If T_AGENDA->ZZ2_AUTO == "S"
      lAprova  := .T.
      lReprova := .F.
   Else
      lAprova  := .F.
      lReprova := .T.
   Endif   

   cTexto	 := T_AGENDA->JUSTIFICA

   DEFINE MSDIALOG oDlg TITLE "Agendamento de Eventos" FROM C(184),C(187) TO C(569),C(582) PIXEL

   @ C(005),C(005) Say "C�digo"         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(033) Say "Usu�rios"       Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(173) Say "Ano"            Size C(011),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(027),C(005) Say "Eventos"        Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(027),C(160) Say "Data Evento"    Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(049),C(005) Say "Observa��es"    Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(100),C(005) Say "Tempo Estimado" Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(014),C(005) MsGet oGet3  Var cCodigo         Size C(022),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(014),C(033) MsGet oGet1  Var cUsuario        Size C(134),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(014),C(173) MsGet oGet2  Var cAno            Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(036),C(005) MsGet oGet6  Var cEvento         Size C(150),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(036),C(161) MsGet oGet4  Var cData           Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(058),C(005) GET   oMemo1 Var cNota    MEMO   Size C(187),C(038) PIXEL OF oDlg                              When lChumba
   @ C(099),C(050) MsGet oGet5  Var cTempo          Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(112),C(005) GET oMemo2   Var cLinha   MEMO   Size C(187),C(001) PIXEL OF oDlg                              When lChumba
   @ C(116),C(005) CheckBox oCheckBox1 Var lAprova  Prompt "Aprova"    Size C(027),C(008) PIXEL OF oDlg           When lChumba
   @ C(116),C(044) CheckBox oCheckBox2 Var lReprova Prompt "Reprova"   Size C(036),C(008) PIXEL OF oDlg           When lChumba
   @ C(128),C(005) GET oMemo3   Var cTexto   MEMO   Size C(187),C(044) PIXEL OF oDlg                              When lChumba

   @ C(176),C(155) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)