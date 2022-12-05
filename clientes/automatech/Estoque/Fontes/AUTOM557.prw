#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#Include "protheus.ch"
#Include "totvs.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"

// ###################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            ##
// -------------------------------------------------------------------------------- ##
// Referencia: AUTOM557.PRW                                                         ##
// Parâmetros: Nenhum                                                               ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                      ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                              ##
// Data......: 06/07/2017                                                           ##
// Objetivo..: Programa que gera automaticamente o cálculo do Custo Médio das       ##
//             filiais da Empresa                                                   ##
// Parâmetros: kEmpresa = Código da Empresa                                         ##
//             kFilial  = Código da Filial                                          ##     
// ###################################################################################

User Function AUTOM557(kEmpresa, kFilial)

   Local lCPParte  := .F.       // Define que não será processado o custo em partes
   Local lBat      := .T.       // Define que a rotina será executada em Batch
   Local aListaFil := {}        // Carrega Lista com as Filiais a serem processadas
   Local cCodFil   := ''        // Código da Filial a ser processada 
   Local cNomFil   := ''        // Nome da Filial a ser processada
   Local cCGC      := ''        // CGC da filial a ser processada
   Local aParAuto  := {}        // Carrega a lista com os 21 parâmetros
   Local cString  := ""
   Local cCaminho := "\LOGCMEDIO\LOG_CST_" + DTOC(DATE()) + ".LOG"

   Private _lMsErroAuto

   U_AUTOM628("AUTOM557")

   MV_PAR01 = Date() - 1        // Data a ser considerada para o cálculo
   MV_PAR02 = 2                 // Mostra lanctos. Contábeis
   MV_PAR03 = 2                 // Aglutina Lanctos Contábeis
   MV_PAR04 = 1                 // Atualizar Arq. de Movimentos
   MV_PAR05 = 0                 // % de aumento da MOD
   MV_PAR06 = 1                 // Centro de Custo
   MV_PAR07 = ""                // Conta Contábil a inibir de
   MV_PAR08 = "ZZZZZZZZZZZZZZZ" // Conta Contábil a inibir até
   MV_PAR09 = 2                 // Apagar estornos
   MV_PAR10 = 2                 // Gerar Lancto. Contábil
   MV_PAR11 = 2                 // Gerar estrutura pela Moviment
   MV_PAR12 = 3                 // Contabilização On-Line Por
   MV_PAR13 = 2                 // Calcula mão-de-Obra
   MV_PAR14 = 3                 // Método de apropriação
   MV_PAR15 = 2                 // Recalcula Nível de Estrut
   MV_PAR16 = 2                 // Mostra sequência de Cálculo
   MV_PAR17 = 2                 // Seq Processamento FIFO
   MV_PAR18 = 1                 // Mov Internos Valorizados
   MV_PAR19 = 1                 // Recálculo Custo transportes
   MV_PAR20 = 1                 // Cálculo de custos por
   MV_PAR21 = 2                 // Calcular Custo em Partes

   // ##################################################################################
   // Carrega o array com os parâmetros a serem utilizado para a execução do programa ##
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
   // Verifica se existe a pasta LogRefazAcum na aplicação. Caso não exista, será criada ##
   // #####################################################################################
   If !ExistDir( "\logCstMedio" )

      nRet := MakeDir( "\logCstMedio" )
   
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

   // ###############################################
   // Prepara o ambiente para execução do processo ##
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
   // Executa a rotina de recálculo do custo médio ##
   // ###############################################
   MATA330(lBat,aListaFil,lCPParte, aParAuto)

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