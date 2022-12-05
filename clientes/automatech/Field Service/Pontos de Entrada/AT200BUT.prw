#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "jpeg.ch" 

// ###################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                            ##
// -------------------------------------------------------------------------------- ##
// Referencia: AT200BUT.PRW                                                         ##
// Par�metros: Nenhum                                                               ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                      ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                              ##
// Data......: 07/03/2017                                                           ##
// Objetivo..: Ponto de Entrada que habilita op��es no enchoice da tela de Contrato ##
//             de Assist�ncia T�cnica.                                              ##
// ###################################################################################

User Function AT200BUT

   aBotao := {} 
   
   AAdd( aBotao, { "Sele��o N� S�ries"   , { || U_AUTOM548() }, "Sele��o N� de S�ries" } ) 
   AAdd( aBotao, { "Importa��o Contratos", { || U_AUTOM643() }, "Importa��o Contratos" } ) 
   
Return( aBotao )           