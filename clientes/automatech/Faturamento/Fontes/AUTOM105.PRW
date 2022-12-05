#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM105.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  (X) Gatilho  ( ) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 23/04/2012                                                          *
// Objetivo..: Gatilho disparado no código do cliente. Verifica se o cliente possui*
//             NCC(Notas de Crédito) em aberto com a Automatech. Caso tenha, sis-  *
//             tema dispara mensagem informando ao vendedor do valor das NCC       *
// Parâmetros: _Cliente -> Código do Cliente                                       *
//             _Loja    -> Loja do Cliente                                         *
//**********************************************************************************

User Function AUTOM105(_Cliente, _Loja)

   Local cSql := ""
   
   U_AUTOM628("AUTOM105")

   If Empty(Alltrim(_Cliente))
      Return ""
   Endif

   If Select("T_CREDITO") > 0
      T_CREDITO->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT E1_CLIENTE,"
   cSql += "       E1_LOJA   ,"
   cSql += "       E1_TIPO   ,"
   cSql += "       SUM(E1_VALOR) AS VALOR,"
   cSql += "       SUM(E1_SALDO) AS SALDO "
   cSql += "  FROM " + RetSqlName("SE1")
   cSql += " WHERE E1_TIPO      = 'NCC'"
   cSql += "   AND E1_CLIENTE   = '" + Alltrim(_Cliente) + "'"
   cSql += "   AND E1_LOJA      = '" + Alltrim(_Loja)    + "'"
   cSql += "   AND E1_SALDO     > 0"
   cSql += "   AND R_E_C_D_E_L_ = ''"
   cSql += " GROUP BY E1_CLIENTE, E1_LOJA, E1_TIPO"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CREDITO", .T., .T. )

   If T_CREDITO->( EOF() )
      Return _Cliente
   Endif
   
   MsgAlert("Atenção!!!" + chr(13) + chr(13) + "O Cliente informado possui o valor de R$ " + Transform(T_CREDITO->SALDO,'9999999.99') + " ref. a Nota de Crédito.")
   
Return _Cliente