#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: SIGAFIS.PRW                                                         *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho (X) Ponto de Entrada                      *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 30/10/2012                                                          *
// Objetivo..: Ponto de Entrada no login do Módulo Fiscal.                         *
//**********************************************************************************

User Function SIGAFIS()

   Public _VeMensagem
   Public _Ativi
   Public _Validacao

   Default _VeMensagem := .F.
   Default _Ativi      := .F.
   Default _Validacao  := .F.

   // Prothelito News
   If !_VeMensagem
      U_AUTOM338()
   Endif

   // Verifica se existem atividades a ser executadas
   If !_Ativi
      U_ATVATI15()
   Endif

   // Verifica a existência de tarefas a serem validadas
   If !_Validacao
      U_ESPVAL02()
   Endif

Return .T.