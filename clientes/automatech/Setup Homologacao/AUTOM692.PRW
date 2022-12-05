#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ###########################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                    ##
// ---------------------------------------------------------------------------------------- ##
// Referencia: AUTOM692.PRW                                                                 ##
// Parâmetros: Nenhum                                                                       ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                              ##
// ---------------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                      ##
// Data......: 16/07/2018                                                                   ##
// Objetivo..: Programa Setup de Homologação                                                ##
//             Preparador automático do ambiente de homologação                             ##
// ###########################################################################################

User Function AUTOM692()




                 dbUseArea(.T., , "SX2010.DTC", "DBF_TABELA", .T., .F.)
                 dbUseArea(.T., , "SX3010.DTC", "DBF_ORIGEM", .T., .F.)
