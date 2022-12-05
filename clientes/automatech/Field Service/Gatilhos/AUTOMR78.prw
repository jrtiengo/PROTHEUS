#include "Protheus.ch"                             

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR78.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: ( ) Programa  (X) Gatilho ( ) Ponto de Entrada                      *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 09/02/2012                                                          *
// Objetivo..: Gatilho disparado na quantidade do poduto da tabela AB5 ( Aponta-   *
//             mentos do Or�amento do Filed Service). Verifica  se a quantidade    *
//             informada para o Or�amento � suficiente no estoque.                 *
// Par�metros: < _C�digo > - C�digo do Poduto                                      *
//             < _Quanti > - Qunatidade informada no apontamento para verifica��o  *
//**********************************************************************************

//utiliza��o da fun��o DbTree
User Function AUTOMR78( _Codigo, _Quanti )

   Local cSql := ""

   // Verifica se o c�digo informado � m�o-de-obra. Se for, n�o consiste saldo
   If Select("T_PRODUTO") > 0
      T_PRODUTO->( dbCloseArea() )
   EndIf
      
   cSql := ""
   cSql := "SELECT B1_TIPO "  
   cSql += "  FROM " + RetSqlName("SB1")
   cSql += " WHERE B1_COD       = '" + Alltrim(_codigo) + "'"
   cSql += "   AND R_E_C_D_E_L_ = 0"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTO", .T., .T. )

   If T_PRODUTO->( EOF() )
      Return _Quanti
   Endif
   
   If Alltrim(T_PRODUTO->B1_TIPO) <> "PA"
      Return _Quanti
   Endif
   
   // Pesquisa o saldo do produto informado
   If Select("T_SALDO") > 0
      T_SALDO->( dbCloseArea() )
   EndIf
      
   cSql := ""
   cSql := "SELECT SUM(B2_QATU) AS SALDO "
   cSql += "  FROM " + RetSqlName("SB2")
   cSql += " WHERE B2_FILIAL    = '01'"
   cSql += "   AND B2_COD       = '" + Alltrim(_Codigo) + "'"
   cSql += "   AND R_E_C_D_E_L_ = '0'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SALDO", .T., .T. )

   If T_SALDO->( EOF() )
      MsgAlert("ATEN��O !!" + Chr(13) + Chr(13) + "N�o existe saldo dispon�vel para o poduto informado.")
      Return 0
   Endif
   
   If _Quanti > T_SALDO->SALDO 
      MsgAlert("ATEN��O !!" + Chr(13) + Chr(13) + "Quantidade informada � superior ao saldo dispon�vel do produto." + chr(13) + chr(13) + "Quantidade Informada: " + Str(_Quanti,10,02) + Chr(13) + "Saldo Dispon�vel: " + Str(T_SALDO->SALDO,10,02))
      Return 0
   Endif

Return _Quanti