#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TBICONN.CH" 
#INCLUDE "TBICODE.CH" 
#include "TOTVS.ch" 
#include "RWMake.ch" 
#include "AP5mail.ch" 

// ###################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            ##
// -------------------------------------------------------------------------------- ##
// Referencia: AUTOM536.PRW                                                         ##
// Parâmetros: Nenhum                                                               ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                      ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                              ##
// Data......: 06/07/2017                                                           ##
// Objetivo..: Programa que executa o Refaz Acumulados em processo automático       ##
// ###################################################################################

User Function AUTOM536(kEmpresa, kFilial) 

   Local PARAMIXB := .T.  
   Local cTexto   := ""
   Local cString  := ""
   Local cCaminho := "\LOGREFAZACUM\LOG_RFA_" + DTOC(DATE()) + ".LOG"

   Private _lMsErroAuto

   // #####################################################################################
   // Verifica se existe a pasta LogRefazAcum na aplicação. Caso não exista, será criada ##
   // #####################################################################################
   If !ExistDir( "\logrefazacum" )

      nRet := MakeDir( "\logrefazacum" )
   
      If nRet != 0
         Return(.T.)
      Endif
   
   Endif

   // #########################################################################
   // Verifica se houve a passagem dos parâmetros para execusão do prodgrama ##
   // ######################################################################### 

   // ########################################################### 
   // Verifica se o código da Empresa foi passado no parâmetro ##
   // ###########################################################
   If kEmpresa == Nil

      cString  := ""
      cString  += "Data...: " + Dtoc(Date()) + " - " + Time()                             + chr(13) + chr(10)
      cString  += "Status.: " + "Código da Empresa não foi passado na chamada da função." + chr(13) + chr(10)
      cString  += "         Processo não executado." 

      nHdl := fCreate(cCaminho)
      fWrite (nHdl, cString ) 
      fClose(nHdl)

      RESET ENVIRONMENT   
         
      Return(.T.)
      
   Endif   

   // ########################################################## 
   // Verifica se o código da Filial foi passado no parâmetro ##
   // ##########################################################
   If kFilial == Nil

      cString  := ""
      cString  += "Data...: " + Dtoc(Date()) + " - " + Time()                            + chr(13) + chr(10)
      cString  += "Status.: " + "Código da Filial não foi passado na chamada da função." + chr(13) + chr(10)

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
   // Atualiza o log de execusão do programa ##
   // #########################################
   cString  := ""
   cString  += "Data/Hora Inicial: " + DiaInicial + " - " + HorInicial + chr(13) + chr(10)
   cString  += "Data/Hora Final..: " + DiaFinal   + " - " + HorFinal   + chr(13) + chr(10)
   If !_lMsErroAuto
      cString  += "Status...........: Processo executado com sucesso." 
   Else
      cString  += "Status...........: Processo não executado." 
   Endif

   nHdl := fCreate(cCaminho)
   fWrite (nHdl, cString ) 
   fClose(nHdl)

   RESET ENVIRONMENT

Return(.T.)