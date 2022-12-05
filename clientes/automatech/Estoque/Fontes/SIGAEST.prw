#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: SIGAEST.PRW                                                         *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 16/04/2012                                                          *
// Objetivo..: Programa chamado na entrada do modulo de estoque .                  *
//             Caso usu�rio = conferencia, chama direto o programa U_AUTOMR52      *
//**********************************************************************************

User Function SIGAEST()

   Local cCodigo := RetCodUsr()

   Public _VeMensagem
   Public _Rodar  
   Public _Intermediacao
   Public _News
   Public _Ativi
   Public _Validacao
   Public _EncerraRma
   Public _AvisoRMA
   Public _DataEntrega
   Public _TaxaDolar

   Default _Intermediacao := .F.
   Default _VeMensagem    := .F.
   Default _Rodar         := .F.
   Default _News          := .F.
   Default _Ativi         := .F.
   Default _Validacao     := .F.
   DeFault _EncerraRma    := .F.
   Default _AvisoRMA      := .F.
   Default _Dataentrega   := .F. 
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

   // Prothelito News
   If !_VeMensagem
      U_AUTOM338()
   Endif

   // Verifica se existem atividades pendentes de execu��o
   If !_Ativi
      U_ATVATI15()
   Endif

   If !_Rodar
      If cCodigo == "000136"
         U_AUTOMR52()
      Endif   
   Endif   

   If !_News
      U_AUTOM171()
   Endif

   // Verifica tarefas a serem validadas
   If !_Validacao
      U_ESPVAL02()
   Endif

   // Encerramento de RMA Autom�tica
   If !_EncerraRma
      U_AUTOM222()
   Endif

   // Aviso de Solicita��o de Aprova��o de RMA
   If !_AvisoRMA
      U_AUTOM225()
   Endif

   // Verifica se existem produtos com Status 05 que dever�o ser alterados para o status 08
   If !_DataEntrega
      U_AUTOM612()
   Endif

Return .T.