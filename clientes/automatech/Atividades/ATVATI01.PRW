#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ATVATI01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 30/07/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Atividades                    *
//**********************************************************************************

User Function ATVATI01()

   Local aComboBx1	 := {}
   Local lAlfabetica := .F.
   Local lCodificada := .F.
   Local lOrdenada   := .F.

   Local cComboBx1
   Local oCheckBox1
   Local oCheckBox2
   Local oCheckBox3

   Private oDlg

   // Carrega o combo de Áreas para seleção
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
      MsgAlert("Cadastro de Áreas está vazio. Verifique !!!!")
      Return .T.
   Endif
   
   aAdd(aComboBx1, "000000 - Todas as Áreas" )

   T_AREAS->( DbGoTop() )
   WHILE !T_AREAS->( EOF() )
      aAdd(aComboBx1, T_AREAS->ZZR_CODIGO + " - " + Alltrim(T_AREAS->ZZR_NOME) )   
      T_AREAS->( DbSkip() )
   ENDDO

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Atividades" FROM C(178),C(181) TO C(340),C(519) PIXEL

   @ C(004),C(006) Say "Áreas"                        Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(028),C(006) Say "Abrir pesquisa ordenada por:" Size C(069),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(013),C(006) ComboBox cComboBx1 Items aComboBx1                                  Size C(158),C(010) PIXEL OF oDlg

   @ C(028),C(079) CheckBox oCheckBox1 Var lAlfabetica Prompt "Alfabética"              Size C(048),C(008) PIXEL OF oDlg
   @ C(038),C(079) CheckBox oCheckBox2 Var lCodificada Prompt "Código de Cadastramento" Size C(074),C(008) PIXEL OF oDlg
   @ C(049),C(079) CheckBox oCheckBox3 Var lOrdenada   Prompt "Campo Ordenação"         Size C(056),C(008) PIXEL OF oDlg

   @ C(064),C(045) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( CHAMAATIV(SubStr(cComboBx1,01,06), lAlfabetica, lCodificada, lOrdenada))
   @ C(064),C(083) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que chama a tela de consulta de atividades
Static Function CHAMAATIV(__Area, __Alfabetica, __Codificada, __Ordenada)

   Local nMarcadas := 0

   If __Alfabetica
      nMarcadas := nMarcadas + 1
   Endif
   
   If __Codificada
      nMarcadas := nMarcadas + 1
   Endif

   If __Ordenada
      nMarcadas := nMarcadas + 1
   Endif

   If nMarcadas > 1
      MsgAlert("Indique somente um tipo de ordenação a ser utilizada na pesquisa.")
      Return .T.
   Endif

   If nMarcadas == 0
      __Alfabetica := .T.
   Endif

   U_ATVATI02(__Area, __Alfabetica, __Codificada, __Ordenada) 

Return .T.