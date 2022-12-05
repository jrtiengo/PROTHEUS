#include "Protheus.ch"                             

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM148.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 11/01/2013                                                          *
// Objetivo..: Pesquisa o nome do fornecedor para preencher coluna do browse da    *
//             tela do pedido de compra.                                           *
//**********************************************************************************

User Function AUTOM148(_Codigo, _Loja)

   Local cSql := ""

   U_AUTOM628("AUTOM148")

   If Empty(Alltrim(_Codigo))
      Return ""
   Endif
      
   // Pesquisa o nome do fronecedor
   If Select("T_FORNECEDOR") > 0
   	  T_FORNECEDOR->( dbCloseArea() )
   EndIf

   cSql := "SELECT A2_COD   , "
   cSql += "       A2_LOJA  , "
   cSql += "       A2_NOME    "
   cSql += "  FROM " + RetSqlName("SA2")
   cSql += " WHERE A2_COD  = '" + Alltrim(_Codigo) + "'"
   cSql += "   AND A2_LOJA = '" + Alltrim(_Loja)   + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FORNECEDOR", .T., .T. )

   If T_FORNECEDOR->( Eof() )
      Return ""
   Endif
   
Return T_FORNECEDOR->A2_NOME