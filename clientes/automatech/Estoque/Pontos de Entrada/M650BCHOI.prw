#INCLUDE 'rwmake.ch'
#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: M650BCHOI.PRW                                                       *
// Par�metros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 07/03/2014                                                          *
// Objetivo..: Ponto de Entrada que cria novas op��es na Enchoice da tela de Ordem *
//             de Produ��o. (Ap�s Consulta da Ordem de Produ��o).                  *
//**********************************************************************************

User Function M650BCHOI()

   Local cBitMap := 'RELATORIO'
   Local cHint   := 'Impress�o Ordem Produ��o'
   Local aButtons := {{cBitMap,{|| U_AUTOMR05()},cHint}} 

   U_AUTOM628("M650BCHOI")
   
Return aButtons