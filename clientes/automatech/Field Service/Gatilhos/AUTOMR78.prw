#include "Protheus.ch"                             

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR78.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  (X) Gatilho ( ) Ponto de Entrada                      *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 09/02/2012                                                          *
// Objetivo..: Gatilho disparado na quantidade do poduto da tabela AB5 ( Aponta-   *
//             mentos do Orçamento do Filed Service). Verifica  se a quantidade    *
//             informada para o Orçamento é suficiente no estoque.                 *
// Parâmetros: < _Código > - Código do Poduto                                      *
//             < _Quanti > - Qunatidade informada no apontamento para verificação  *
//**********************************************************************************

//utilização da função DbTree
User Function AUTOMR78( _Codigo, _Quanti )

   Local cSql := ""

   // Verifica se o código informado é mão-de-obra. Se for, não consiste saldo
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
      MsgAlert("ATENÇÃO !!" + Chr(13) + Chr(13) + "Não existe saldo disponível para o poduto informado.")
      Return 0
   Endif
   
   If _Quanti > T_SALDO->SALDO 
      MsgAlert("ATENÇÃO !!" + Chr(13) + Chr(13) + "Quantidade informada é superior ao saldo disponível do produto." + chr(13) + chr(13) + "Quantidade Informada: " + Str(_Quanti,10,02) + Chr(13) + "Saldo Disponível: " + Str(T_SALDO->SALDO,10,02))
      Return 0
   Endif

Return _Quanti