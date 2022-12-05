#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM106.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 23/04/2012                                                          *
// Objetivo..: Programa que mostra relação de clientes que possuem notas de crédi- *
//             to em aberto junto a Automatech.                                    *
//**********************************************************************************

User Function AUTOM106()

   Local cSql      := ""
   Local cClientes := 0
   Local cValor    := 0
   Local lChumba   := .F.

   Local oGet1
   Local oGet2

   Private aBrowse := {}

   Private oDlg

   If Select("T_CREDITO") > 0
      T_CREDITO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.E1_CLIENTE,"
   cSql += "       A.E1_LOJA   ,"
   cSql += "       B.A1_NOME   ,"
   cSql += "       SUM(A.E1_VALOR) AS VALOR,"
   cSql += "       SUM(A.E1_SALDO) AS SALDO "
   cSql += "  FROM " + RetSqlName("SE1") + " A, "
   cSql += "       " + RetSqlName("SA1") + " B  "
   cSql += " WHERE A.E1_TIPO      = 'NCC'    "
   cSql += "   AND A.E1_SALDO     > 0        "
   cSql += "   AND A.E1_CLIENTE   = B.A1_COD "
   cSql += "   AND A.E1_LOJA      = B.A1_LOJA"
   cSql += "   AND A.R_E_C_D_E_L_ = ''"
   cSql += "  GROUP BY E1_CLIENTE, E1_LOJA, A1_NOME"
   cSql += "  ORDER BY B.A1_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CREDITO", .T., .T. )

   If T_CREDITO->( EOF() )
      If _Rodar1 <> nil
         _Rodar1 := .T.
      Endif   
      Return .T.
   Endif
   
   T_CREDITO->( DbGoTop() )

   cClientes := 0
   cValor    := 0
   
   WHILE !T_CREDITO->( EOF() )
      Aadd( aBrowse, { Alltrim(T_CREDITO->E1_CLIENTE), Alltrim(T_CREDITO->E1_LOJA), T_CREDITO->A1_NOME, Str(T_CREDITO->SALDO, 10,02 ) } )
      cClientes := cClientes + 1
      cValor    := cValor    + T_CREDITO->VALOR
      T_CREDITO->( DbSkip() )
   ENDDO

   If _Rodar1 <> nil
      _Rodar1 := .T.
   Endif   

   DEFINE MSDIALOG oDlg TITLE "Relação de Clientes com NCC (notas de Crédtio)" FROM C(178),C(181) TO C(571),C(761) PIXEL

   @ C(002),C(004) Say "Abaixo segue relação de clientes que possuem notas de crédito em aberto junto a Automatech para sua avaliação." Size C(275),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(183),C(004) Say "Total de Clientes:" Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(183),C(100) Say "Valor Total:"       Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(182),C(038) MsGet oGet1 Var cClientes When lChumba Size C(020),C(010) COLOR CLR_BLACK Picture "99999"      PIXEL OF oDlg
   @ C(182),C(125) MsGet oGet2 Var cValor    When lChumba Size C(040),C(010) COLOR CLR_BLACK Picture "9999999.99" PIXEL OF oDlg

   @ C(180),C(253) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Desenha o Browse
   oBrowse := TCBrowse():New( 012 , 005, 365, 215,,{'Cliente', 'Loja', 'Descrição dos Clientes' + Space(130), 'Valor NCC' },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04] } }

   ACTIVATE MSDIALOG oDlg CENTERED 
   
Return .T.