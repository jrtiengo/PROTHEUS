#INCLUDE "rwmake.ch"
#INCLUDE "jpeg.ch"    
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"
#include "fileio.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM610.PRW                                                        ##
// Par�metros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                             ##
// Data......: 11/08/2017                                                          ##
// Objetivo..: Gatilho respons�vel por popular o campo C2_ZDOE (Ordem de Produ��o) ##
// ##################################################################################

User Function AUTOM610()

   U_AUTOM628("AUTOM610")

   If INCLUI == .T.
      M->C2_ZDOE := M->C2_DATPRF
   Endif
   
Return(M->C2_DATPRF)