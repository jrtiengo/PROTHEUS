#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: MA035BUT.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 22/10/2012                                                          *
// Objetivo..: Ponto de entrada que cria novas op��es no cadastro de Grupo de Pro- *
//             dutos.                                                              *
// Par�metros: Sem Par�metros                                                      *
//**********************************************************************************

User Function MA035BUT()

   Local aButtons :=  {{ 'S4WB007N', { || U_AUTOM138(SBM->BM_GRUPO, SBM->BM_DESC, SBM->BM_COMIS) }, OemtoAnsi('Comiss�es (Exce��es)') }} 

   U_AUTOM628("MA035BUT")
   
Return(aButtons)