#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ###########################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                                    ##
// ---------------------------------------------------------------------------------------- ##
// Referencia: AUTOM692.PRW                                                                 ##
// Par�metros: Nenhum                                                                       ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                              ##
// ---------------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                                      ##
// Data......: 16/07/2018                                                                   ##
// Objetivo..: Programa Setup de Homologa��o                                                ##
//             Preparador autom�tico do ambiente de homologa��o                             ##
// ###########################################################################################

User Function AUTOM692()




                 dbUseArea(.T., , "SX2010.DTC", "DBF_TABELA", .T., .F.)
                 dbUseArea(.T., , "SX3010.DTC", "DBF_ORIGEM", .T., .F.)
