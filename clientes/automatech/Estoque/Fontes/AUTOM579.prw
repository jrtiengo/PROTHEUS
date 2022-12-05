#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM579.PRW                                                        ##
// Par�metros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                             ##
// Data......: 02/06/2017                                                          ##
// Objetivo..: Programa que executa automaticamente o c�lculo do Custo M�dio.      ##
//             Executado via Gerenciador de Tarefa do Window.                      ##
// Par�metros: C�digo da Empresa                                                   ##
//             C�digo da Filial                                                    ##
// ##################################################################################
User Function AUTOM579(kEmpresa, kFilial)

   Local lCPParte  := .F. // Define que n�o ser� processado o custo em partes
   Local lBat      := .T. // Define que a rotina ser� executada em Batch
   Local aListaFil := {}  // Carrega Lista com as Filiais a serem processadas
   Local cCodFil   := ''  // C�digo da Filial a ser processada 
   Local cNomFil   := ''  // Nome da Filial a ser processada
   Local cCGC      := ''  // CGC da filial a ser processada
   Local aParAuto  := {}  // Carrega a lista com os 21 par�metros

   // ###########################################################################
   // Seta os par�metros para a exec��o do programa de C�l�culo do Custo M�dio ##
   // ###########################################################################
   MV_PAR01  = Date() - 1        // Data Limite Final
   MV_PAR02  = "Nao"             // Mostra lanctos. Cont�beis
   MV_PAR03  = "Nao"             // Aglutina Lanctos Cont�beis
   MV_PAR04  = "Sim"             // Atualizar Arq. de Movimentos
   MV_PAR05  = 0                 // % de aumento da MOD
   MV_PAR06  = "Contabil"        // Centro de Custo
   MV_PAR07  = "               " // Conta Cont�bil a inibir de
   MV_PAR08  = "ZZZZZZZZZZZZZZZ" // Conta Cont�bil a inibir at�
   MV_PAR09  = "Nao"             // Apagar estornos
   MV_PAR010 = "Nao"             // Gerar Lancto. Cont�bil
   MV_PAR011 = "Nao"             // Gerar estrutura pela Moviment
   MV_PAR012 = "Ambas"           // Contabiliza��o On-Line Por
   MV_PAR013 = "Nao"             // Calcula m�o-de-Obra
   MV_PAR014 = "Diaria"          // M�todo de apropria��o
   MV_PAR015 = "Nao"             // Recalcula N�vel de Estrut
   MV_PAR016 = "Custo Medio"     // Mostra sequ�ncia de C�lculo
   MV_PAR017 = "Custo Medio"     // Seq Processamento FIFO
   MV_PAR018 = "Antes"           // Mov Internos Valorizados
   MV_PAR019 = "Sim"             // Rec�lculo Custo transportes
   MV_PAR020 = "Todas filiais"   // C�lculo de custos por
   MV_PAR021 = "Nao"             // Calcular Custo em Partes

//   PREPARE ENVIRONMENT EMPRESA kEmpresa FILIAL kFilial MODULO "EST" TABLES "AF9","SB1","SB2","SB3","SB8","SB9","SBD","SBF","SBJ","SBK","SC2","SC5","SC6","SD1","SD2","SD3","SD4","SD5","SD8","SDB","SDC","SF1","SF2","SF4","SF5","SG1","SI1","SI2","SI3","SI5","SI6","SI7","SM2","ZAX","SAH","SM0","STL"

//   Conout("In�cio da execu��o do AUTOM579")

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
   // Executa a rotina de rec�lculo do custo m�dio ##
   // ###############################################
   MATA330(lBat,aListaFil,lCPParte, aParAuto)

//   ConOut("T�rmino da execu��o do AUTOM579")

msgalert(time())
 
Return