#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ########################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                                 ##
// ------------------------------------------------------------------------------------- ##
// Referencia: AUTOM674.PRW                                                              ##
// Par�metros: Nenhum                                                                    ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                           ##
// ------------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                                   ##
// Data......: 07/02/2018                                                                ##
// Objetivo..: Nova consulta de saldos de produtos                                       ##
// Par�metros: Sem par�metros                                                            ##
// ########################################################################################

User Function A250SPRC()

   cOP    := PARAMIXB[1]
   dDtRef := PARAMIXB[2]
   
   lRet := .T.//Customiza��es
   
Return lRet