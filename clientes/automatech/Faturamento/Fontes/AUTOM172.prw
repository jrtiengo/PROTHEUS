#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM172.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 23/04/2013                                                          *
// Objetivo..: Programa que pesquisa a condição de pagamento do pedido de venda e  *
//             preenche a coluna Cond.Pagamento da tela do MATA450 - Liberação de  *
//             Crédito de Pedidos de Venda.                                        *
//**********************************************************************************

User Function AUTOM172()
                       
   Local cSql      := ""
   Local cCondicao := ""

   U_AUTOM628("AUTOM172")

   // Pesquisa a Condição de Pagamento do Pedido de Venda selecionado
   If Select("T_CONDICAO") > 0
      T_CONDICAO->( dbCloseArea() )
   EndIf
  
   cSql := ""
   cSql := "SELECT SC9.C9_FILIAL , "
   cSql += "       SC9.C9_PEDIDO , "
   cSql += "       SC5.C5_CONDPAG, "
   cSql += "       SE4.E4_DESCRI   "
   cSql += "  FROM " + RetSqlName("SC9") + " SC9, "
   cSql += "       " + RetSqlName("SC5") + " SC5, "
   cSql += "       " + RetSqlName("SE4") + " SE4  "
   cSql += " WHERE SC9.C9_FILIAL  = '" + ALLTRIM(SC9->C9_FILIAL) + "'"
   cSql += "   AND SC9.C9_PEDIDO  = '" + ALLTRIM(SC9->C9_PEDIDO) + "'"
   cSql += "   and SC9.D_E_L_E_T_ = ''            "
   cSql += "   AND SC9.C9_FILIAL  = SC5.C5_FILIAL " 
   cSql += "   AND SC9.C9_PEDIDO  = SC5.C5_NUM    "
   cSql += "   AND SC5.D_E_L_E_T_ = ''            "
   cSql += "   AND SC5.C5_CONDPAG = SE4.E4_CODIGO "
   cSql += "   AND SE4.D_E_L_E_T_ = ''            "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONDICAO", .T., .T. )
   
   If T_CONDICAO->( EOF() )

      cCondicao := ""

   Else

      cCondicao := Alltrim(T_CONDICAO->E4_DESCRI)

      // Verifica se título foi gerado pelo vendedor. Se positivo, complementa a descrição da condição de pagamento
      If Select("T_PELOVENDEDOR") > 0
         T_PELOVENDEDOR->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZS0_FILIAL,"
      cSql += "       ZS0_PEDIDO,"
      cSql += "       ZS0_CODCLI,"
      cSql += "       ZS0_LOJCLI "
      cSql += "  FROM " + RetSqlName("ZS0")
      cSql += " WHERE ZS0_FILIAL = '" + ALLTRIM(SC9->C9_FILIAL) + "'"
      cSql += "   AND ZS0_PEDIDO = '" + ALLTRIM(SC9->C9_PEDIDO) + "'"
      cSql += "   AND ZS0_DELE   = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PELOVENDEDOR", .T., .T. )

      If !T_PELOVENDEDOR->( EOF() )
         cCondicao := cCondicao + " - Boleto emitido pelo Vendedor"
	  EndIf

   Endif

Return cCondicao