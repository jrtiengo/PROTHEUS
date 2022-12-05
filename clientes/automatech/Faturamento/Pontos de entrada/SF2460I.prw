#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: SF2460I.PRW                                                         ##
// Par�metros: Nenhum                                                              ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                             ##
// Data......: 03/08/2017                                                          ##
// Objetivo..: Ponto de Entrada executado ap�s a atualiza��o das tabelas da nota   ##
//             fiscal de sa�da. PE utilizdo para abertura de ticket de GNRE ou de  ##
//             Nota Fiscal de Remessa de Demonstra��o.                             ##
// ##################################################################################

User Function SF2460I()

   U_AUTOM628("SF2460I")

   // ##############################################################################
   // Verifica se h� a necessidade de abertura de ticket FreshDesk para Guia GRNE ##
   // ##############################################################################
// Abre_GNRE_Auto()
   
   // ###############################################################################################
   // Verifica se h� a necessidade de abertura de ticket FreshDesk para documentos de demonstra��o ##
   // ###############################################################################################
   Abre_DEMO_Auto()

Return(.T.)   

// ##########################################################################
// Fun��o que verifica se h� a necessidade de abertura de ticket para GNRE ##
// ##########################################################################
Static Function Abre_GNRE_Auto()
 
   Local aArea       := GetArea()
   Local aAreaSC6    := SC6->(GetArea())
   Local aAreaSC5    := SC5->(GetArea())
   Local aAreaSF2    := SF2->(GetArea())
   Local aAreaSD2    := SD2->(GetArea())
   Local nFreteRat   := 0
   Local nPercentual := 0
   Local nValorGNRE  := 0
   Local kCNPJ       := POSICIONE("SA1",1, XFILIAL("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA, "A1_CGC")

   dbSelectArea("SD2")
   dbSetOrder(3)
   dbSeek( SF2->( F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA ) )
 
   WHILE SD2->( !EOF() ) .and. SF2->( F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA ) == SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA )

      // #########################################
      // Verifica se CFOP do produto � = a 6108 ##
      // #########################################
      If SD2->D2_CF == "6108"

         // ################################################################################################ 
         // Se Empresa for a 01 - Automatech, somente verificar� a necessidade de abertura de ticket para ##
         // Estados Diferente de S�o Paulo, Santa Catariana, Minas Gerais, Rio de Janeiro e Paran�)       ##
         // ################################################################################################
         If cEmpAnt == "01"
            
            If POSICIONE("SA1",1, XFILIAL("SA1") + SD2->D2_CLIENTE + SD2->D2_LOJA, "A1_EST")$("SP#SC#MG#RJ#PR")
               dbSelectArea("SD2")
               SD2->( dbSkip() )
               Loop
             Endif
             
         Endif
             
         // #############################################################
         // Pesquisa o valor do ICMS Complemantar para gera��o da GNRE ##
         // ############################################################# 
                    
         // #############################
         // Pesquisa o tipo de cliente ##
         // #############################
         xTipoCli := POSICIONE("SA1",1,XFILIAL("SA1") + SD2->D2_CLIENTE + SD2->D2_LOJA, "A1_TIPO")

         // ###############################
         // Calculo ST e Outros Impostos ##
         // ###############################                     
         MaFisIni(SD2->D2_CLIENTE, SD2->D2_LOJA, "C", "N", xTipoCli, MaFisRelImp("MTR700",{"SF2","SD2"}),,,"SB1","MTR700")

         // #########################################################
         // Proporcionaliza o valor do frete para c�lculo do Difal ##
         // #########################################################
         If SF2->F2_FRETE == 0
            nFreteRat   := 0
         Else
            nPercentual := Round((SD2->D2_TOTAL / SF2->F2_VALMERC) * 100,2)
            nFreteRat   := Round((SF2->F2_FRETE * nPercentual) / 100,2)
         Endif

         // ######################
         // Calcula os Impostos ##
         // ######################
         MaFisAdd(SD2->D2_COD               ,; // 01 - C�digo do Produto (Obrigat�rio)
                  SD2->D2_TES               ,; // 02 - C�digo do TES (Obrigat�rio)
                  SD2->D2_QUANT             ,; // 03 - Quantidade de Venda do Produto (Obrigat�rio)
                  SD2->D2_PRCVEN            ,; // 04 - Pre�o Unit�rio de Venda do Produto (Obrigat�rio)
                  0                         ,; // 05 - Valor do Desconto (Opcional)
                  ""                        ,; // 06 - N� da NF Original (Devolu��o/Beneficiamento)
                  ""                        ,; // 07 - S�rie da NF Original (Devolu��o/Beneficiamento)
                  0                         ,; // 08 - RecNo da NF Original do arq SD1/SD2
                  0                         ,; // 09 - Valor do Frete do Item ( Opcional )
                  0                         ,; // 10 - Valor da Despesa do item ( Opcional )
                  0                         ,; // 11 - Valor do Seguro do item ( Opcional )
                  0                         ,; // 12 - Valor do Frete Autonomo ( Opcional )
                  SD2->D2_TOTAL + nFreteRat ,; // 13 - Valor da Mercadoria ( Obrigatorio )
                  0                         ,; // 14 - Valor da Embalagem ( Opiconal )
                  0                         ,; // 15 - RecNo do SB1
                  0)                           // 16 - RecNo do SF4
           
         // #################################
         // Captura os valores de impostos ##
         // #################################
         aDifalPF  := MaFisRet(1,"IT_LIVRO"  )

         MaFisEnd()         

         // ############################################################
         // Acumula o valor do ICMS Complementar para gera��o da GNRE ##
         // ############################################################
         nValorGNRE := nValorGNRE + aDifalPF[129]
         
         dbSelectArea("SD2")
         SD2->( dbSkip() )

      Endif

   Enddo

   // ######################################################################################################
   // Se houver valor em nValorGNRE, envia para o programa que realiza a abertura do Tickert no FreshDesk ##
   // ######################################################################################################  
   If nValorGNRE == 0
   Else
      U_AUTOM585( SF2->F2_DOC, SF2->F2_SERIE, nValorGNRE, kCNPJ)
   Endif
 
   RestArea(aAreaSD2)
   RestArea(aAreaSF2)
   RestArea(aAreaSC5)
   RestArea(aAreaSC6)
   RestArea(aArea) 
 
Return(.T.)

// ###################################################################################################
// Fun��o que verifica se h� a necessidade de abertura de ticket para Notas Fiscais de Demonstra��o ##
// ###################################################################################################
Static Function Abre_DEMO_Auto()

   Local aArea       := GetArea()
   Local aAreaSC6    := SC6->(GetArea())
   Local aAreaSC5    := SC5->(GetArea())
   Local aAreaSF2    := SF2->(GetArea())
   Local aAreaSD2    := SD2->(GetArea())
   Local lAbreTicket := .F.
   Local cTipoOper   := ""
   Local kCNPJ       := POSICIONE("SA1",1, XFILIAL("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA, "A1_CGC")
   Local kPedido     := ""

   // ######################################
   // Pesquisa os produtos da nota fiscal ##
   // ######################################
   dbSelectArea("SD2")
   dbSetOrder(3)
   dbSeek( SF2->( F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA ) )
 
   WHILE SD2->( !EOF() ) .and. SF2->( F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA ) == SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA )

      kPedido := SD2->D2_PEDIDO

      // ##################################################################
      // Verifica se o TES do produto � uma TES de Demonstra��o de Sa�da ##
      // ##################################################################
      If SD2->D2_TES$("731#732#720#721#778")
         cTipoOper   := "A"          
         lAbreTicket := .T.
      Endif
         
      // ####################################################################
      // Verifica se o TES do produto � uma TES de Demonstra��o de Entrada ##
      // ####################################################################
      If SD2->D2_TES$("235#236#238#239#267")
         cTipoOper   := "F"          
         lAbreTicket := .T.
      Endif

      dbSelectArea("SD2")
      SD2->( dbSkip() )

   Enddo

   // #################################################################################################
   // Envia para o programa que abre o tickt no FreshDesk se atender a condi��o acima (Demonstra��o) ##
   // #################################################################################################
   If lAbreTicket == .T.
      U_AUTOM595( cTipoOper, kPedido, SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_ZTICK)
   Endif
 
   RestArea(aAreaSD2)
   RestArea(aAreaSF2)
   RestArea(aAreaSC5)
   RestArea(aAreaSC6)
   RestArea(aArea) 

Return(.T.)