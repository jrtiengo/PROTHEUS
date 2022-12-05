#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: MTA450R.PRW                                                         *
// Par�metros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 07/01/2014                                                          *
// Objetivo..: Ponto de Entrada disparado na rejei��o da An�lise Cr�dito/Pedidos.  *
//             Grava na ZZ0 o registro de indica��o de Pedido Rejeitado pela An�-  *
//             lise de Cr�dito.                                                    *
//**********************************************************************************

User Function MTA450R()

   U_AUTOM628("MTA450R")

   U_GrvLogSts( xFilial("SC9"), SC9->C9_PEDIDO, SC9->C9_ITEM, "15", "MTA450R") 

Return(.T.)