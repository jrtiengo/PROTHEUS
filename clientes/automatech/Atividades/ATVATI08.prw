#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ATVATI10.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 30/07/2012                                                          *
// Objetivo..: Programa de Atividades X �reas                                      *
//**********************************************************************************

User Function ATVATI08()

   Private aComboBx1	 := {}
   Private aComboBx2	 := {}

   Private cComboBx1
   Private cComboBx2

   Private oDlg

   // Carrega o combo de �reas para sele��o
   If Select("T_AREAS") > 0
      T_AREAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZR_CODIGO , "
   cSql += "       A.ZZR_NOME     "
   cSql += "  FROM " + RetSqlName("ZZR") + " A  "
   cSql += " WHERE A.ZZR_DELETE = ''"
   cSql += " ORDER BY A.ZZR_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AREAS", .T., .T. )

   If T_AREAS->( EOF () )
      MsgAlert("Cadastro de �reas est� vazio. Verifique !!!!")
      Return .T.
   Endif
   
   T_AREAS->( DbGoTop() )
   WHILE !T_AREAS->( EOF() )
      aAdd(aComboBx1, T_AREAS->ZZR_CODIGO + " - " + Alltrim(T_AREAS->ZZR_NOME) )   
      T_AREAS->( DbSkip() )
   ENDDO

   // Carrega o combo de Usu�rios
   If Select("T_USUARIOS") > 0
      T_USUARIOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZT_USUA "
   cSql += "  FROM " + RetSqlName("ZZT")
   cSql += " WHERE ZZT_DELETE = ''"
   cSql += " ORDER BY ZZT_USUA "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIOS", .T., .T. )

   If T_USUARIOS->( EOF() )
      MsgAlert("N�o existem Usu�rios parametrizados para esta �rea.")
      Return .T.
   Endif
   
   aComboBx2 := {}

   T_USUARIOS->( DbGoTop() )
   WHILE !T_USUARIOS->( EOF() )
      aAdd(aComboBx2, T_USUARIOS->ZZT_USUA )
      T_USUARIOS->( DbSkip() )
   ENDDO

   DEFINE MSDIALOG oDlg TITLE "Cadastro de �reas X Atividades" FROM C(178),C(181) TO C(319),C(480) PIXEL

   @ C(004),C(006) Say "�rea para Pesquisa" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(027),C(006) Say "Usu�rios"           Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(013),C(006) ComboBox cComboBx1 Items aComboBx1 Size C(138),C(010) PIXEL OF oDlg 
   @ C(035),C(006) ComboBox cComboBx2 Items aComboBx2 Size C(138),C(010) PIXEL OF oDlg

   @ C(052),C(040) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( _Chama09(SubStr(cComboBx1,01,06), SubStr(cComboBx1,10), cComboBx2))
   @ C(052),C(079) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Fun��o que chama o programa ATVATI09
Static Function _Chama09(xArea, xNome, xUsuario)

   If Empty(Alltrim(xUsuario))
      MsgAlert("Necess�rio informar o Usu�rio para pesquisa.")
      Return .T.
   Endif

   // Verifica se o usu�rio pertence a �rea selecionada
   If Select("T_USUARIOS") > 0
      T_USUARIOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZT_USUA "
   cSql += "  FROM " + RetSqlName("ZZT")
   cSql += " WHERE ZZT_DELETE = ''"
   cSql += "   AND ZZT_AREA   = '" + Alltrim(xArea)    + "'"
   cSql += "   AND ZZT_USUA   = '" + Alltrim(xUsuario) + "'"
   cSql += " ORDER BY ZZT_USUA "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIOS", .T., .T. )

   If T_USUARIOS->( EOF() )
      MsgAlert("Usu�rio n�o pertence a esta �rea.")
      Return .T.
   Endif

   U_ATVATI09(xArea, xNome, xUsuario)
   
Return .T.   