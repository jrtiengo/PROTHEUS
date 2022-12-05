#INCLUDE 'rwmake.ch'
#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: M650BCHOI.PRW                                                       *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 07/03/2014                                                          *
// Objetivo..: Ponto de Entrada que cria novas opções na Enchoice da tela de Ordem *
//             de Produção. (Após Consulta da Ordem de Produção).                  *
//**********************************************************************************

User Function M650BCHOI()

   Local cBitMap := 'RELATORIO'
   Local cHint   := 'Impressão Ordem Produção'
   Local aButtons := {{cBitMap,{|| U_AUTOMR05()},cHint}} 

   U_AUTOM628("M650BCHOI")
   
Return aButtons