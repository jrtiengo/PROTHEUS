#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: TK271DESROD.PRW                                                     *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 21/05/2013                                                          *
// Objetivo..: Ponto de Entrada executado no campo desconto do rodapé Call Center. *
//**********************************************************************************

User Function TK271DESROD()

   // Calcula os totais do Atendimento Call Center
   U_AUTOM237()
   
Return(.T.)   