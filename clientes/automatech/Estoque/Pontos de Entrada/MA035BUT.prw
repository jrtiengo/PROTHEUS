#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: MA035BUT.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 22/10/2012                                                          *
// Objetivo..: Ponto de entrada que cria novas opções no cadastro de Grupo de Pro- *
//             dutos.                                                              *
// Parâmetros: Sem Parâmetros                                                      *
//**********************************************************************************

User Function MA035BUT()

   Local aButtons :=  {{ 'S4WB007N', { || U_AUTOM138(SBM->BM_GRUPO, SBM->BM_DESC, SBM->BM_COMIS) }, OemtoAnsi('Comissões (Exceções)') }} 

   U_AUTOM628("MA035BUT")
   
Return(aButtons)