#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: TMK380BTN.PRW                                                       *
// Par�metros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho (X) Ponto de Entrada                      *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 25/01/2012                                                          *
// Objetivo..: Ponto de Entrada que cria um novo bot�o na tela de agenda do opera- *
//             dor de TeleCobran�a.                                                *
//**********************************************************************************

User Function TMK380BTN()

   Local aBotoes := {}
   
   U_AUTOM628("TMK380BTN")

   aAdd( aBotoes, { "PENDENTE", {|| U_AUTOMR84() }, "Estat�stica de Atendimentos", "Estat�stica" } )
   aAdd( aBotoes, { "PENDENTE", {|| U_AUTOM190() }, "Condi��o de Pagamento", "Condi��o de Pagamento" } )
  
Return aBotoes