#INCLUDE "Protheus.ch"                                

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: FISTRFNFE.PRW                                                       ##
// Par�metros: Nenhum                                                              ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                             ##
// Data......: 30/08/2017                                                          ##
// Objetivo..: Adi��o de bot�es no menu do SPEDNFE                                 ##
// ##################################################################################

User Function FISTRFNFE()

   U_AUTOM628("FISTRFNFE")

   aadd(aRotina,{'Abertura de Ticket','U_AUTOM620()' , 0 , 3,0,NIL})
   
Return Nil