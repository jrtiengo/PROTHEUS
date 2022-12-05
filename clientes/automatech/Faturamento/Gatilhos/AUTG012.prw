#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTG012.PRW                                                         *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  (X) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 11/11/2011                                                          *
// Objetivo..: Gatilho que verifica se produto informado na proposta comercial es- *
//             tá bloqueado ou não.                                                *
// Parâmetros: << Código do Produto >>                                             *
// Retorno...: Código do Produto                                                   *
//**********************************************************************************

User Function AUTG012(_Codigo)   

   Local cSql        := ""
   Local _POS_PRCTAB := 0

   U_AUTOM628("AUTG012")

   If _Codigo = NIL
      Return ""
   Endif
   
   // Zera o preço unitário de tabela de preço para que o Sistema não gera desconto na nota fiscal
   _POS_PRCTAB           := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "ADZ_PRCTAB" } )               
   aCols[n][_POS_PRCTAB] := 0

   // Pesquisa se o produto informado está bloqueado
   If Select("T_BLOQUEADO") > 0
      T_BLOQUEADO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT B1_MSBLQL"
   csql += "  FROM " + RetSqlName("SB1010")
   cSql += " WHERE B1_COD = '" + Alltrim(_Codigo) + "'"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_BLOQUEADO", .T., .T. )

   If T_BLOQUEADO->B1_MSBLQL == "1"
      MsgAlert("Atenção !!" + chr(13) + "Produto informado está bloqueado. Utilização não permitida.")
      Return ""
   Endif

Return _Codigo