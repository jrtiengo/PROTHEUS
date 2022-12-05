#INCLUDE "protheus.ch"
#INCLUDE "TOTVS.CH"

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: AUTOM520.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Gatilho                                               ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 26/12/2016                                                              ##
// Objetivo..: Programa que popula o c´pdigo e nome do vendedor nos campos virtuais do ##
//             da tabeal SC6 (Itens de Pedido de venda) para display na tela do progra-##
//             ma Liberação de Margem de Pedido de Venda.                              ##
// Parametros: _Filial -> Codigoi da filial do pedido de venda                         ##
//             _Pedido -> Numero do pedido de venda                                    ##
//             _Tipo   -> Tipo de retorno (1 - Codigo, 2 - Nome Vendedor)              ##
// ######################################################################################

User Function AUTOM520(_Filial, _Pedido, _Tipo)

   Local cSql      := ""
   Local cVendedor := "000000"

   U_AUTOM628("AUTOM520")
   
   If Empty(Alltrim(_Pedido))
      If _Tipo == 1
         cVendedor := "000000"
      Else
         cvendedor := ""
      Endif
      Return cVendedor
   Endif
 
   If Select("T_VENDEDOR") > 0
      T_VENDEDOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT TOP(1) SC6.C6_FILIAL,"
   cSql += "       SC6.C6_NUM   ,"
   cSql += "       SC5.C5_VEND1 ,"
   cSql += "       SA3.A3_NOME   "
   cSql += "  FROM " + RetSqlName("SC6") + " SC6, "
   cSql += "       " + RetSqlName("SC5") + " SC5, "
   cSql += "	   " + RetSqlName("SA3") + " SA3  "
   cSql += " WHERE SC6.C6_FILIAL = '" + Alltrim(_Filial) + "'"
   cSql += "   AND SC6.C6_NUM    = '" + Alltrim(_Pedido) + "'"
   cSql += "   AND SC5.C5_FILIAL  = SC6.C6_FILIAL"
   cSql += "   AND SC5.C5_NUM     = SC6.C6_NUM   "
   cSql += "   AND SC6.D_E_L_E_T_ = ''"
   cSql += "   AND SC5.D_E_L_E_T_ = ''"
   cSql += "   AND SA3.A3_COD     = SC5.C5_VEND1"
   cSql += "   AND LTRIM(RTRIM(SA3.A3_NOME)) <> 'Harald Hans Loschenkohl'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

   If T_VENDEDOR->( EOF() )
      If _Tipo == 1
         cVendedor := "000000"
      Else
         cVendedor := ""
      Endif      
   Else   
      If _Tipo == 1
         cVendedor := T_VENDEDOR->C5_VEND1
      Else
         cVendedor := T_VENDEDOR->A3_NOME
      Endif   
   Endif
   
Return cVendedor