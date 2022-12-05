#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM642.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 19/10/2012                                                          ##
// Objetivo..: Programa do Parametrizador Customizável - Parte II                  ##
// ################################################################################## 

User Function TESTETES()
                      
   Local kTES := ""
   
   kTES := ""

   kTES := MaTesInt(2, "03", "000329", "001", "C", "004442")
   
   MsgAlert(kTES)
   
Return(.T.)    