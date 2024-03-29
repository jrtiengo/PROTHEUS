#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TBICONN.CH" 
#INCLUDE "TBICODE.CH" 
#include "TOTVS.ch" 
#include "RWMake.ch" 
#include "AP5mail.ch" 

// ###################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                            ##
// -------------------------------------------------------------------------------- ##
// Referencia: AUTOM536.PRW                                                         ##
// Par�metros: Nenhum                                                               ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                      ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                              ##
// Data......: 06/07/2017                                                           ##
// Objetivo..: Programa que executa o Refaz Acumulados em processo autom�tico       ##
// ###################################################################################

User Function AUTOM536(kEmpresa, kFilial) 

   Local PARAMIXB := .T.  
   Local cTexto   := ""
   Local cString  := ""
   Local cCaminho := "\LOGREFAZACUM\LOG_RFA_" + DTOC(DATE()) + ".LOG"

   Private _lMsErroAuto

   // #####################################################################################
   // Verifica se existe a pasta LogRefazAcum na aplica��o. Caso n�o exista, ser� criada ##
   // #####################################################################################
   If !ExistDir( "\logrefazacum" )

      nRet := MakeDir( "\logrefazacum" )
   
      If nRet != 0
         Return(.T.)
      Endif
   
   Endif

   // #########################################################################
   // Verifica se houve a passagem dos par�metros para execus�o do prodgrama ##
   // ######################################################################### 

   // ########################################################### 
   // Verifica se o c�digo da Empresa foi passado no par�metro ##
   // ###########################################################
   If kEmpresa == Nil

      cString  := ""
      cString  += "Data...: " + Dtoc(Date()) + " - " + Time()                             + chr(13) + chr(10)
      cString  += "Status.: " + "C�digo da Empresa n�o foi passado na chamada da fun��o." + chr(13) + chr(10)
      cString  += "         Processo n�o executado." 

      nHdl := fCreate(cCaminho)
      fWrite (nHdl, cString ) 
      fClose(nHdl)

      RESET ENVIRONMENT   
         
      Return(.T.)
      
   Endif   

   // ########################################################## 
   // Verifica se o c�digo da Filial foi passado no par�metro ##
   // ##########################################################
   If kFilial == Nil

      cString  := ""
      cString  += "Data...: " + Dtoc(Date()) + " - " + Time()                            + chr(13) + chr(10)
      cString  += "Status.: " + "C�digo da Filial n�o foi passado na chamada da fun��o." + chr(13) + chr(10)

      nHdl := fCreate(cCaminho)
      fWrite (nHdl, cString ) 
      fClose(nHdl)

      RESET ENVIRONMENT   

      Return(.T.)
      
   Endif   

   // ##########################################################
   // Executa o Refaz Acumulado para a Empresa 01 - Filial 01 ##
   // ##########################################################
   DiaInicial := Dtoc(Date())
   HorInicial := Time()

   PREPARE ENVIRONMENT EMPRESA kEmpresa Filial kFilial USER 'Administrador' PASSWORD '@tech15006' TABLES "SA1","SB2","SC0","SC6","SC7","SC9","SD1","SD4","SE2","VCB" MODULO "EST"

   MSExecAuto({|x| mata215(x)},PARAMIXB)

   DiaFinal := Dtoc(Date())
   HorFinal := Time()

   // #########################################
   // Atualiza o log de execus�o do programa ##
   // #########################################
   cString  := ""
   cString  += "Data/Hora Inicial: " + DiaInicial + " - " + HorInicial + chr(13) + chr(10)
   cString  += "Data/Hora Final..: " + DiaFinal   + " - " + HorFinal   + chr(13) + chr(10)
   If !_lMsErroAuto
      cString  += "Status...........: Processo executado com sucesso." 
   Else
      cString  += "Status...........: Processo n�o executado." 
   Endif

   nHdl := fCreate(cCaminho)
   fWrite (nHdl, cString ) 
   fClose(nHdl)

   RESET ENVIRONMENT

Return(.T.)