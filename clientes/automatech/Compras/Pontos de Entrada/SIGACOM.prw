#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: SIGACOM.PRW                                                         *
// Par�metros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho (X) Ponto de Entrada                      *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 30/10/2012                                                          *
// Objetivo..: Ponto de Entrada no login do M�dulo de Compras.                     *
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
   // Bloqueia produtos que deixaram de ser de intermedia��o ##
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

   // Verifica Valida��es de Tarefas
   If !_Validacao
      U_ESPVAL02()
   Endif

Return .T.