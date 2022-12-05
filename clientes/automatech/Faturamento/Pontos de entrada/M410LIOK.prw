#INCLUDE "protheus.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: M410LIOK.PRW                                                        ##
// Par�metros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                             ##
// Data......: 13/05/2014                                                          ##
// Objetivo..: VALIDA��O DE LINHA DO PEDIDO VENDA. Valida��o de linha no pedido de ##
//             venda.                                                              ##
// ##################################################################################

User Function M410LIOK()
   
   U_AUTOM628("M410OLIOK")

   // ##############################################################
   // Envia para a fun��o que calcula a margem do pedido de venda ##
   // ##############################################################

   // ##########################################################################################################################
   // 03/01/2017                                                                                                              ##
   // Conforme Sr. Roger, o disparo da rotina que calcula a Margem dos produtos n�o deve mais ser realizada quando a linha do ##
   // pedido de venda � trocada e sim, o processo do programa AUUTOM524 deve ser disparado para todos  os  produtos  no bot�o ##
   // confirmar do pedido de venda.                                                                                           ##
   // ##########################################################################################################################
   // U_QTGPED()

Return(.T.)