#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM174.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 03/05/2013                                                          *
// Objetivo..: Programa que pesquisa a transportadora do pedido de venda e preen-  *
//             che a coluna Transporte da tela do MATA450 - Liberação de Crédito   *
//             de Pedidos de Venda e Documento de Saída.                           *
//**********************************************************************************

User Function AUTOM174()
                       
   Local cSql      := ""
   Local cCondicao := ""
   
   U_AUTOM628("AUTOM174")

   // Pesquisa a Transportadora do Pedido de Venda selecionado
   If Select("T_TRANSPORTE") > 0
      T_TRANSPORTE->( dbCloseArea() )
   EndIf
  
   csql := ""
   csql := "SELECT SC9.C9_FILIAL , "
   csql += "       SC9.C9_PEDIDO , "
   csql += "       SC5.C5_TRANSP , "
   csql += "       SA4.A4_NOME     "
   csql += "  FROM " + RetSqlName("SC9") + " SC9, "
   csql += "       " + RetSqlName("SC5") + " SC5, "
   csql += "       " + RetSqlName("SA4") + " SA4  "
   csql += " WHERE SC9.C9_FILIAL  = '" + ALLTRIM(SC9->C9_FILIAL) + "'"
   csql += "   AND SC9.C9_PEDIDO  = '" + ALLTRIM(SC9->C9_PEDIDO) + "'"
   csql += "   AND SC9.D_E_L_E_T_ = ''            "
   csql += "   AND SC9.C9_FILIAL  = SC5.C5_FILIAL "
   csql += "   AND SC9.C9_PEDIDO  = SC5.C5_NUM    "
   csql += "   AND SC5.D_E_L_E_T_ = ''            "
   csql += "   AND SC5.C5_TRANSP  = SA4.A4_COD    "
   csql += "   AND SA4.D_E_L_E_T_ = ''            "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TRANSPORTE", .T., .T. )
   
   If T_TRANSPORTE->( EOF() )
      cTransporte := ""
   Else
      cTransporte := T_TRANSPORTE->A4_NOME
   Endif

Return cTransporte