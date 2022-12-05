#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTG012.PRW                                                         *
// Par�metros: Nenhum                                                              *
// Tipo......: ( ) Programa  (X) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 11/11/2011                                                          *
// Objetivo..: Gatilho que verifica se produto informado na proposta comercial es- *
//             t� bloqueado ou n�o.                                                *
// Par�metros: << C�digo do Produto >>                                             *
// Retorno...: C�digo do Produto                                                   *
//**********************************************************************************

User Function AUTG012(_Codigo)   

   Local cSql        := ""
   Local _POS_PRCTAB := 0

   U_AUTOM628("AUTG012")

   If _Codigo = NIL
      Return ""
   Endif
   
   // Zera o pre�o unit�rio de tabela de pre�o para que o Sistema n�o gera desconto na nota fiscal
   _POS_PRCTAB           := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "ADZ_PRCTAB" } )               
   aCols[n][_POS_PRCTAB] := 0

   // Pesquisa se o produto informado est� bloqueado
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
      MsgAlert("Aten��o !!" + chr(13) + "Produto informado est� bloqueado. Utiliza��o n�o permitida.")
      Return ""
   Endif

Return _Codigo