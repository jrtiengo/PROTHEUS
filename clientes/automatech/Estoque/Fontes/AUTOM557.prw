#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#Include "protheus.ch"
#Include "totvs.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"

// ###################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                            ##
// -------------------------------------------------------------------------------- ##
// Referencia: AUTOM557.PRW                                                         ##
// Par�metros: Nenhum                                                               ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                      ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                              ##
// Data......: 06/07/2017                                                           ##
// Objetivo..: Programa que gera automaticamente o c�lculo do Custo M�dio das       ##
//             filiais da Empresa                                                   ##
// Par�metros: kEmpresa = C�digo da Empresa                                         ##
//             kFilial  = C�digo da Filial                                          ##     
// ###################################################################################

User Function AUTOM557(kEmpresa, kFilial)

   Local lCPParte  := .F.       // Define que n�o ser� processado o custo em partes
   Local lBat      := .T.       // Define que a rotina ser� executada em Batch
   Local aListaFil := {}        // Carrega Lista com as Filiais a serem processadas
   Local cCodFil   := ''        // C�digo da Filial a ser processada 
   Local cNomFil   := ''        // Nome da Filial a ser processada
   Local cCGC      := ''        // CGC da filial a ser processada
   Local aParAuto  := {}        // Carrega a lista com os 21 par�metros
   Local cString  := ""
   Local cCaminho := "\LOGCMEDIO\LOG_CST_" + DTOC(DATE()) + ".LOG"

   Private _lMsErroAuto

   U_AUTOM628("AUTOM557")

   MV_PAR01 = Date() - 1        // Data a ser considerada para o c�lculo
   MV_PAR02 = 2                 // Mostra lanctos. Cont�beis
   MV_PAR03 = 2                 // Aglutina Lanctos Cont�beis
   MV_PAR04 = 1                 // Atualizar Arq. de Movimentos
   MV_PAR05 = 0                 // % de aumento da MOD
   MV_PAR06 = 1                 // Centro de Custo
   MV_PAR07 = ""                // Conta Cont�bil a inibir de
   MV_PAR08 = "ZZZZZZZZZZZZZZZ" // Conta Cont�bil a inibir at�
   MV_PAR09 = 2                 // Apagar estornos
   MV_PAR10 = 2                 // Gerar Lancto. Cont�bil
   MV_PAR11 = 2                 // Gerar estrutura pela Moviment
   MV_PAR12 = 3                 // Contabiliza��o On-Line Por
   MV_PAR13 = 2                 // Calcula m�o-de-Obra
   MV_PAR14 = 3                 // M�todo de apropria��o
   MV_PAR15 = 2                 // Recalcula N�vel de Estrut
   MV_PAR16 = 2                 // Mostra sequ�ncia de C�lculo
   MV_PAR17 = 2                 // Seq Processamento FIFO
   MV_PAR18 = 1                 // Mov Internos Valorizados
   MV_PAR19 = 1                 // Rec�lculo Custo transportes
   MV_PAR20 = 1                 // C�lculo de custos por
   MV_PAR21 = 2                 // Calcular Custo em Partes

   // ##################################################################################
   // Carrega o array com os par�metros a serem utilizado para a execu��o do programa ##
   // ##################################################################################
   Aadd(aParAuto,MV_PAR01)
   Aadd(aParAuto,MV_PAR02)
   Aadd(aParAuto,MV_PAR03)
   Aadd(aParAuto,MV_PAR04)
   Aadd(aParAuto,MV_PAR05)
   Aadd(aParAuto,MV_PAR06)
   Aadd(aParAuto,MV_PAR07)
   Aadd(aParAuto,MV_PAR08)
   Aadd(aParAuto,MV_PAR09)
   Aadd(aParAuto,MV_PAR10)
   Aadd(aParAuto,MV_PAR11)
   Aadd(aParAuto,MV_PAR12)
   Aadd(aParAuto,MV_PAR13)
   Aadd(aParAuto,MV_PAR14)
   Aadd(aParAuto,MV_PAR15)
   Aadd(aParAuto,MV_PAR16)
   Aadd(aParAuto,MV_PAR17)
   Aadd(aParAuto,MV_PAR18)
   Aadd(aParAuto,MV_PAR19)
   Aadd(aParAuto,MV_PAR20)
   Aadd(aParAuto,MV_PAR21)                                                   

   // #####################################################################################
   // Verifica se existe a pasta LogRefazAcum na aplica��o. Caso n�o exista, ser� criada ##
   // #####################################################################################
   If !ExistDir( "\logCstMedio" )

      nRet := MakeDir( "\logCstMedio" )
   
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

   // ###############################################
   // Prepara o ambiente para execu��o do processo ##
   // ###############################################
   PREPARE ENVIRONMENT EMPRESA kEmpresa FILIAL kFilial USER 'Administrador' PASSWORD '@tech15006' TABLES "AF9","SB1","SB2","SB3","SB8","SB9","SBD","SBF","SBJ","SBK","SC2","SC5","SC6","SD1","SD2","SD3","SD4","SD5","SD8","SDB","SDC","SF1","SF2","SF4","SF5","SG1","SI1","SI2","SI3","SI5","SI6","SI7","SM2","ZAX","SAH","SM0","STL"

   // ###################################
   // Adiciona filial a ser processada ##
   // ###################################
   dbSelectArea("SM0")
   dbSeek(cEmpAnt)

   Do While ! Eof() .And. SM0->M0_CODIGO == kEmpresa
      
      cCodFil := SM0->M0_CODFIL
      cNomFil := SM0->M0_FILIAL
      cCGC    := SM0->M0_CGC

      // ############################################################
      // Adiciona a filial na lista de filiais a serem processadas ##
      // ############################################################
      Aadd(aListaFil,{.T.,cCodFil,cNomFil,cCGC,.F.,})

      dbSkip()
   
   EndDo

   // ###############################################
   // Executa a rotina de rec�lculo do custo m�dio ##
   // ###############################################
   MATA330(lBat,aListaFil,lCPParte, aParAuto)

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