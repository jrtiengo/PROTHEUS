#Include "Protheus.ch"
#Include "TOTVS.ch"
#include "jpeg.ch"    
#INCLUDE "topconn.ch"    
#INCLUDE "XMLXFUN.CH"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"

#define SW_HIDE             0 // Escondido
#define SW_SHOWNORMAL       1 // Normal
#define SW_NORMAL           1 // Normal
#define SW_SHOWMINIMIZED    2 // Minimizada
#define SW_SHOWMAXIMIZED    3 // Maximizada
#define SW_MAXIMIZE         3 // Maximizada
#define SW_SHOWNOACTIVATE   4 // Na Ativa��o
#define SW_SHOW             5 // Mostra na posi��o mais recente da janela
#define SW_MINIMIZE         6 // Minimizada
#define SW_SHOWMINNOACTIVE  7 // Minimizada
#define SW_SHOWNA           8 // Esconde a barra de tarefas
#define SW_RESTORE          9 // Restaura a posi��o anterior
#define SW_SHOWDEFAULT      10// Posi��o padr�o da aplica��o
#define SW_FORCEMINIMIZE    11// For�a minimiza��o independente da aplica��o executada
#define SW_MAX              11// Maximizada

// ###############################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                                        ##
// -------------------------------------------------------------------------------------------- ##
// Referencia: AUTOM645.PRW                                                                     ##
// Par�metros: Nenhum                                                                           ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                                  ##
// -------------------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                                          ##
// Data......: 09/10/2017                                                                       ##
// Objetivo..: Programa que pesquisa a cota��o do dolar no Banco Central na entrada do Sistema. ##
// ###############################################################################################

User Function MA090ATU()

  nOpc := "3"

Return(.T.)

