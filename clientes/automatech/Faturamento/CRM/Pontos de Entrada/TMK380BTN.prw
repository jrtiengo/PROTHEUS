#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: TMK380BTN.PRW                                                       *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho (X) Ponto de Entrada                      *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 25/01/2012                                                          *
// Objetivo..: Ponto de Entrada que cria um novo botão na tela de agenda do opera- *
//             dor de TeleCobrança.                                                *
//**********************************************************************************

User Function TMK380BTN()

   Local aBotoes := {}
   
   U_AUTOM628("TMK380BTN")

   aAdd( aBotoes, { "PENDENTE", {|| U_AUTOMR84() }, "Estatística de Atendimentos", "Estatística" } )
   aAdd( aBotoes, { "PENDENTE", {|| U_AUTOM190() }, "Condição de Pagamento", "Condição de Pagamento" } )
  
Return aBotoes