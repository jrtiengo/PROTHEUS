#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR45.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 14/01/2012                                                          *
// Objetivo..: Programa que mostra as Observações Internas do pedido com Scroll    *
//             habilitado.                                                         *
// Parâmetros: < _Filial  > - Filial                                               *
//             < _Pedido  > - Nº do Pedido                                         *
//**********************************************************************************

User Function AUTOMR45( _Filial, _Pedido)

   Local cMemo1	:= ""
   Local oMemo1
   Local cSql   := ""

   Private oDlg

   U_AUTOM628("AUTOMR45")

   // Pesquisa o codigo do Orçamento para pesquisa do nº da proposta comercial
   If Select("T_PEDIDO") > 0
      T_PEDIDO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SUBSTRING(C6_NUMORC,01,06) AS ORCA, "  
   cSql += "       C6_FILIAL   , "
   cSql += "       R_E_C_D_E_L_  "
   cSql += "  FROM " + RetSqlName("SC6")
   cSql += " WHERE C6_NUM       = '" + ALLTRIM(_Pedido) + "'"
   cSql += "   AND  C6_FILIAL   = '" + ALLTRIM(_Filial) + "'"
   cSql += "   AND R_E_C_D_E_L_ = '0'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDO", .T., .T. )

   If T_PEDIDO->( EOF() )
      Return .T.
   Endif
      
   // Pesquisa o código da proposta comercial para capturar 
   If Select("T_ORCAMENTO") > 0
      T_ORCAMENTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT CJ_PROPOST "
   cSql += "  FROM " + RetSqlName("SCJ") 
   cSql += " WHERE CJ_NUM    = '" + alltrim(T_PEDIDO->ORCA) + "'"
   cSql += "   AND CJ_FILIAL = '" + Alltrim(_Filial)        + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ORCAMENTO", .T., .T. )

   If T_ORCAMENTO->( EOF() )
      Return .T.
   Endif
   
   // Pesquisa a observação a ser capturada para display
   If Select("T_OBSERVA") > 0
      T_OBSERVA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql += "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ADY_OBSI)) AS cNOTA" 
   cSql += "  FROM " + RetSqlName("ADY") 
   cSql += " WHERE ADY_PROPOS = '" + alltrim(T_ORCAMENTO->CJ_PROPOST) + "'"
   cSql += "   AND ADY_FILIAL = '" + Alltrim(_Filial)        + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OBSERVA", .T., .T. )

   cMemo1 := T_OBSERVA->cNOTA



   DEFINE MSDIALOG oDlg TITLE "Observações Pedido de Venda" FROM C(178),C(181) TO C(398),C(646) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(001),C(005) Say "Observações Internas" Size C(061),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(010),C(005) GET oMemo1 Var cMemo1 MEMO Size C(222),C(079) PIXEL OF oDlg

   @ C(093),C(189) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION ( oDlg:End() )
   
   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)