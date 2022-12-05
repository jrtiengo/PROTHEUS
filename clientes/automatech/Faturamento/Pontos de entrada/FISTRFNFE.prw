#INCLUDE "Protheus.ch"                                

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: FISTRFNFE.PRW                                                       ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 30/08/2017                                                          ##
// Objetivo..: Adição de botões no menu do SPEDNFE                                 ##
// ##################################################################################

User Function FISTRFNFE()

   U_AUTOM628("FISTRFNFE")

   aadd(aRotina,{'Abertura de Ticket','U_AUTOM620()' , 0 , 3,0,NIL})
   
Return Nil