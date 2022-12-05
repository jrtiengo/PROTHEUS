#INCLUDE "protheus.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: M410LIOK.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 13/05/2014                                                          ##
// Objetivo..: VALIDAÇÃO DE LINHA DO PEDIDO VENDA. Validação de linha no pedido de ##
//             venda.                                                              ##
// ##################################################################################

User Function M410LIOK()
   
   U_AUTOM628("M410OLIOK")

   // ##############################################################
   // Envia para a função que calcula a margem do pedido de venda ##
   // ##############################################################

   // ##########################################################################################################################
   // 03/01/2017                                                                                                              ##
   // Conforme Sr. Roger, o disparo da rotina que calcula a Margem dos produtos não deve mais ser realizada quando a linha do ##
   // pedido de venda é trocada e sim, o processo do programa AUUTOM524 deve ser disparado para todos  os  produtos  no botão ##
   // confirmar do pedido de venda.                                                                                           ##
   // ##########################################################################################################################
   // U_QTGPED()

Return(.T.)