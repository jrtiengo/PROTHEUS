#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "jpeg.ch" 

// ###################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            ##
// -------------------------------------------------------------------------------- ##
// Referencia: AT200BUT.PRW                                                         ##
// Parâmetros: Nenhum                                                               ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                      ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                              ##
// Data......: 07/03/2017                                                           ##
// Objetivo..: Ponto de Entrada que habilita opções no enchoice da tela de Contrato ##
//             de Assistência Técnica.                                              ##
// ###################################################################################

User Function AT200BUT

   aBotao := {} 
   
   AAdd( aBotao, { "Seleção Nº Séries"   , { || U_AUTOM548() }, "Seleção Nº de Séries" } ) 
   AAdd( aBotao, { "Importação Contratos", { || U_AUTOM643() }, "Importação Contratos" } ) 
   
Return( aBotao )           