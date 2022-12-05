#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: TK271DESROD.PRW                                                     *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 21/05/2013                                                          *
// Objetivo..: Ponto de Entrada executado no campo desconto do rodap� Call Center. *
//**********************************************************************************

User Function TK271DESROD()

   // Calcula os totais do Atendimento Call Center
   U_AUTOM237()
   
Return(.T.)   