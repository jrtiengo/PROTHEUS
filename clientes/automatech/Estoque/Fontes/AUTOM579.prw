#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM579.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 02/06/2017                                                          ##
// Objetivo..: Programa que executa automaticamente o cálculo do Custo Médio.      ##
//             Executado via Gerenciador de Tarefa do Window.                      ##
// Parâmetros: Código da Empresa                                                   ##
//             Código da Filial                                                    ##
// ##################################################################################
User Function AUTOM579(kEmpresa, kFilial)

   Local lCPParte  := .F. // Define que não será processado o custo em partes
   Local lBat      := .T. // Define que a rotina será executada em Batch
   Local aListaFil := {}  // Carrega Lista com as Filiais a serem processadas
   Local cCodFil   := ''  // Código da Filial a ser processada 
   Local cNomFil   := ''  // Nome da Filial a ser processada
   Local cCGC      := ''  // CGC da filial a ser processada
   Local aParAuto  := {}  // Carrega a lista com os 21 parâmetros

   // ###########################################################################
   // Seta os parâmetros para a execção do programa de Cálçculo do Custo Médio ##
   // ###########################################################################
   MV_PAR01  = Date() - 1        // Data Limite Final
   MV_PAR02  = "Nao"             // Mostra lanctos. Contábeis
   MV_PAR03  = "Nao"             // Aglutina Lanctos Contábeis
   MV_PAR04  = "Sim"             // Atualizar Arq. de Movimentos
   MV_PAR05  = 0                 // % de aumento da MOD
   MV_PAR06  = "Contabil"        // Centro de Custo
   MV_PAR07  = "               " // Conta Contábil a inibir de
   MV_PAR08  = "ZZZZZZZZZZZZZZZ" // Conta Contábil a inibir até
   MV_PAR09  = "Nao"             // Apagar estornos
   MV_PAR010 = "Nao"             // Gerar Lancto. Contábil
   MV_PAR011 = "Nao"             // Gerar estrutura pela Moviment
   MV_PAR012 = "Ambas"           // Contabilização On-Line Por
   MV_PAR013 = "Nao"             // Calcula mão-de-Obra
   MV_PAR014 = "Diaria"          // Método de apropriação
   MV_PAR015 = "Nao"             // Recalcula Nível de Estrut
   MV_PAR016 = "Custo Medio"     // Mostra sequência de Cálculo
   MV_PAR017 = "Custo Medio"     // Seq Processamento FIFO
   MV_PAR018 = "Antes"           // Mov Internos Valorizados
   MV_PAR019 = "Sim"             // Recálculo Custo transportes
   MV_PAR020 = "Todas filiais"   // Cálculo de custos por
   MV_PAR021 = "Nao"             // Calcular Custo em Partes

//   PREPARE ENVIRONMENT EMPRESA kEmpresa FILIAL kFilial MODULO "EST" TABLES "AF9","SB1","SB2","SB3","SB8","SB9","SBD","SBF","SBJ","SBK","SC2","SC5","SC6","SD1","SD2","SD3","SD4","SD5","SD8","SDB","SDC","SF1","SF2","SF4","SF5","SG1","SI1","SI2","SI3","SI5","SI6","SI7","SM2","ZAX","SAH","SM0","STL"

//   Conout("Início da execução do AUTOM579")

msgalert(time())


   // ####################################
   // Adiciona filial a ser processada  ##
   // ####################################
   dbSelectArea("SM0")
   dbSeek(kEmpresa)

   Do While ! Eof() .And. SM0->M0_CODIGO == kEmpresa

      cCodFil := SM0->M0_CODFIL
      cNomFil := SM0->M0_FILIAL
      cCGC    := SM0->M0_CGC

      // ###########################################
      // Somente adiciona a Filial 01 e Filial 02 ##
      // ###########################################
      If Alltrim(cCodFil) == "99"
      Else         
         // ############################################################
         // Adiciona a filial na lista de filiais a serem processadas ##
         // ############################################################
         Aadd(aListaFil,{.T.,cCodFil,cNomFil,cCGC,.F.,})
      EndIf 

      dbSkip()

   EndDo

   // ###############################################
   // Executa a rotina de recálculo do custo médio ##
   // ###############################################
   MATA330(lBat,aListaFil,lCPParte, aParAuto)

//   ConOut("Término da execução do AUTOM579")

msgalert(time())
 
Return