#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: SIGACOM.PRW                                                         *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho (X) Ponto de Entrada                      *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 30/10/2012                                                          *
// Objetivo..: Ponto de Entrada no login do Módulo de Compras.                     *
//**********************************************************************************

User Function SIGACOM()

   Public _Intermediacao
   Public _VeMensagem
   Public _Ativi
   Public _News
   Public _Validacao
   Public _TaxaDolar

   Default _Intermediacao := .F. 
   Default _VeMensagem    := .F.
   Default _Ativi         := .F.
   Default _News          := .F.
   Default _Validacao     := .F.
   Default _TaxaDolar     := .F.

   // ######################################################################################################
   // Envia para o programa que carrega a taxa do dolar automaticamente pelo web service do banco Central ##
   // ######################################################################################################
   If _TaxaDolar
   ElSe
      U_AUTOM645()   
   Endif   

   // #########################################################
   // Bloqueia produtos que deixaram de ser de intermediação ##
   // #########################################################
   If !_Intermediacao
      U_AUTOM689()
   Endif

   // Protheli News
   If !_VeMensagem
      U_AUTOM338()
   Endif

   // Verifica se existem atividades a ser executadas
   If !_Ativi
      U_ATVATI15()
   Endif

   // Automatech News
   If !_News
      U_AUTOM171()
   Endif

   // Verifica Validações de Tarefas
   If !_Validacao
      U_ESPVAL02()
   Endif

Return .T.