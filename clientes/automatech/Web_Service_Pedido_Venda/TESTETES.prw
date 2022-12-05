#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM642.PRW                                                        ##
// Par�metros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                             ##
// Data......: 19/10/2012                                                          ##
// Objetivo..: Programa do Parametrizador Customiz�vel - Parte II                  ##
// ################################################################################## 

User Function TESTETES()
                      
   Local kTES := ""
   
   kTES := ""

   kTES := MaTesInt(2, "03", "000329", "001", "C", "004442")
   
   MsgAlert(kTES)
   
Return(.T.)    