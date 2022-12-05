#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: MTA450R.PRW                                                         *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 07/01/2014                                                          *
// Objetivo..: Ponto de Entrada disparado na rejeição da Análise Crédito/Pedidos.  *
//             Grava na ZZ0 o registro de indicação de Pedido Rejeitado pela Aná-  *
//             lise de Crédito.                                                    *
//**********************************************************************************

User Function MTA450R()

   U_AUTOM628("MTA450R")

   U_GrvLogSts( xFilial("SC9"), SC9->C9_PEDIDO, SC9->C9_ITEM, "15", "MTA450R") 

Return(.T.)