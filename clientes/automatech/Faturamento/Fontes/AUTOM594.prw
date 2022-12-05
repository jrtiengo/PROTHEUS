#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM594.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##                    
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 01/08/2017                                                          ##
// Objetivo..: Programa que mostra o Resumo do Pedido de Venda Selecionado         ##
// ##################################################################################

User Function AUTOM594()

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local cString := ""
   
   Local oMemo1
   Local oMemo2
   Local oFont
   
   Local nPosCod   := aScan( aHeader, { |x| x[2] == 'C6_PRODUTO' } )
   Local nPosDesc  := aScan( aHeader, { |x| x[2] == 'C6_DESCRI ' } )   
   Local nPosUm    := aScan( aHeader, { |x| x[2] == 'C6_UM     ' } )   
   Local nPosQtde  := aScan( aHeader, { |x| x[2] == 'C6_QTDVEN ' } )
   Local nPosPrc   := aScan( aHeader, { |x| x[2] == 'C6_PRCVEN ' } )
   Local nPosTot   := aScan( aHeader, { |x| x[2] == 'C6_VALOR  ' } )
   Local nPosTes   := aScan( aHeader, { |x| x[2] == 'C6_TES    ' } )
   Local nPosCm1   := aScan( aHeader, { |x| x[2] == 'C6_COMIS1 ' } )
   Local nPosCm2   := aScan( aHeader, { |x| x[2] == 'C6_COMIS2 ' } )
   Local nPosOCO   := aScan( aHeader, { |x| x[2] == 'C6_ORDC   ' } )
   Local nPosANO   := aScan( aHeader, { |x| x[2] == 'C6_ORDA   ' } )
   Local nPosITE   := aScan( aHeader, { |x| x[2] == 'C6_ORDS   ' } )      

   Private oDlg

   U_AUTOM628("AUTOM594")
   
   DEFINE FONT oFont Name "Courier New" Size 0, -14 BOLD

   // ##################################### 
   // Elabora a string a ser visualizada ##
   // #####################################
   cStirng := ""

   cString += "                                                Nº PV: " + Alltrim(M->C5_NUM)                                           + CHR(13) + CHR(10) 
   cString += "----------------------------------------------------------------------------------------------------------------------" + CHR(13) + CHR(10) + CHR(13) + CHR(10)

   cString += "Cliente...........: " + M->C5_CLIENTE + "." + M->C5_LOJACLI    + chr(13) + chr(10)
   cString += "                    " + POSICIONE("SA1",1, XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_NOME")   + CHR(13) + CHR(10)
   cString += "                    " + POSICIONE("SA1",1, XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_END")    + CHR(13) + CHR(10)
   cString += "                    " + POSICIONE("SA1",1, XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_BAIRRO") + CHR(13) + CHR(10)   
   cString += "                    " + Alltrim(POSICIONE("SA1",1, XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_CEP"))    + " - " + ;
                                       Alltrim(POSICIONE("SA1",1, XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_MUN"))    + "/"   + ;   
                                       Alltrim(POSICIONE("SA1",1, XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_EST"))    + CHR(13) + CHR(10) + CHR(13) + CHR(10)
   cString += "Ped.Intermediação.: " + IIF(M->C5_EXTERNO == "1", "SIM", "NÃO") + CHR(13) + CHR(10) + CHR(13) + CHR(10)

   If M->C5_EXTERNO == "1"
      cString += "                    Fornecedor.........: " + Alltrim(POSICIONE("SA2",1, XFILIAL("SA2") + M->C5_FORNEXT + M->C5_LOJAEXT, "A2_NOME")) + CHR(13) + CHR(10)
      cString += "                    NF Distribuidor....: " + Alltrim(M->C5_NFDISTR) + CHR(13) + CHR(10) 
      cString += "                    Fech. Distribuidor.: " + Alltrim(M->C5_DFEC)    + CHR(13) + CHR(10) + CHR(13) + CHR(10) 
   Endif   

   cString += "Moeda.............: " + IIF(M->C5_MOEDA == 1, "REAL", "DOLAR") + CHR(13) + CHR(10) + CHR(13) + CHR(10) 
   cString += "Condição Pagamento: " + Alltrim(M->C5_CONDPAG) + " - " + Posicione( "SE4", 1, xFilial("SE4") + M->C5_CONDPAG, "E4_DESCRI") + CHR(13) + CHR(10) + CHR(13) + CHR(10)
   cString += "Transportadora....: " + Alltrim(M->C5_TRANSP)  + " - " + Posicione( "SA4", 1, xFilial("SA4") + M->C5_TRANSP , "A4_NOME"  ) + CHR(13) + CHR(10) + CHR(13) + CHR(10)
   
   Do case
      Case M->C5_TPFRETE == "C"
           cString += "Tipo do Frete.....: CIF"  + CHR(13) + CHR(10) + CHR(13) + CHR(10)      
      Case M->C5_TPFRETE == "F"
           cString += "Tipo do Frete.....: FOB"  + CHR(13) + CHR(10) + CHR(13) + CHR(10)      
      Case M->C5_TPFRETE == "T"
           cString += "Tipo do Frete.....: Por Conta de Terceiros"  + CHR(13) + CHR(10) + CHR(13) + CHR(10)      
      Case M->C5_TPFRETE == "S"
           cString += "Tipo do Frete.....: Sem Frete"  + CHR(13) + CHR(10) + CHR(13) + CHR(10)      
   EndCase

   cString += "Valor do Frete....: " + Transform(M->C5_FRETE, "@E 9999999.99")  + CHR(13) + CHR(10) + CHR(13) + CHR(10)
   
   cString += "Vendedor 1 .......: " + Alltrim(M->C5_VEND1)  + " - " + Posicione( "SA3", 1, xFilial("SA3") + M->C5_VEND1, "A3_NOME"  ) + CHR(13) + CHR(10) + CHR(13) + CHR(10)

   If Empty(Alltrim(M->C5_VEND2))
   Else
      cString += "Vendedor 2 .......: " + Alltrim(M->C5_VEND2)  + " - " + Posicione( "SA3", 1, xFilial("SA3") + M->C5_VEND2, "A3_NOME"  ) + CHR(13) + CHR(10) + CHR(13) + CHR(10)
   Endif   

   cString += "----------------------------------------------------------------------------------------------------------------------" + CHR(13) + CHR(10)
   cString += "                                          MENSAGEM PARA NOTA FISCAL                                                   " + CHR(13) + CHR(10) 
   cString += "----------------------------------------------------------------------------------------------------------------------" + CHR(13) + CHR(10) + CHR(13) + CHR(10)   
   cString += Alltrim(M->C5_MENNOTA) + CHR(13) + CHR(10) + CHR(13) + CHR(10)

   cString += "----------------------------------------------------------------------------------------------------------------------" + CHR(13) + CHR(10)
   cString += "                                             OBSERVAÇÕES INTERNAS                                                     " + CHR(13) + CHR(10) 
   cString += "----------------------------------------------------------------------------------------------------------------------" + CHR(13) + CHR(10) + CHR(13) + CHR(10)
   cString += Alltrim(M->C5_OBSI) + CHR(13) + CHR(10) + CHR(13) + CHR(10)

   cString += "----------------------------------------------------------------------------------------------------------------------" + CHR(13) + CHR(10)
   cString += "                                                LOG DE SEPARAÇÃO                                                      " + CHR(13) + CHR(10) 
   cString += "----------------------------------------------------------------------------------------------------------------------" + CHR(13) + CHR(10)  + CHR(13) + CHR(10)   
   cString += Alltrim(M->C5_ZMSP) + CHR(13) + CHR(10) + CHR(13) + CHR(10)

   cString += "----------------------------------------------------------------------------------------------------------------------" + CHR(13) + CHR(10)
   cString += "                                                 P R O D U T O S                                                      " + CHR(13) + CHR(10)
   cString += "----------------------------------------------------------------------------------------------------------------------" + CHR(13) + CHR(10)   
   cString += "CÓDIGO            DESCRIÇÃO DOS PRODUTOS                         UM QUANTIDADE   UNITÁRIO      TOTAL TES %COM 1 %COM 2" + CHR(13) + CHR(10)   
   cString += "----------------------------------------------------------------------------------------------------------------------" + CHR(13) + CHR(10)   

   // ##################################################################################################
   // Captura o valor total dos produtos para proporcionalizar o valor do frete para cálculo do Difal ##
   // ##################################################################################################
   nValorRateio := 0

   For nContar = 1 to Len(aCols)
       nValorRateio := nValorRateio + aCols[nContar,nPosTot]
   Next nContar    

   // #########################################
   // Imprime os produtos do pedido de venda ##
   // #########################################
   nTotProdutos := 0
   nTotDifal    := 0

   For nContar = 1 to Len(aCols)

//                  aCols[nContar,nPosDesc] + Space(16)                 + " " + ;

       // #############################
       // Imprime dados dos produtos ##
       // #############################
       cString += Substr(aCols[nContar,nPosCod],01,17)                + " " + ;
                  Substr(aCols[nContar,nPosDesc],01,046)              + " " + ;
                  aCols[nContar,nPosUm]                               + " " + ;
                  Transform(aCols[nContar,nPosQtde], "@E 9999999.99") + " " + ; 
                  Transform(aCols[nContar,nPosPrc] , "@E 9999999.99") + " " + ; 
                  Transform(aCols[nContar,nPosTot] , "@E 9999999.99") + " " + ; 
                  aCols[nContar,nPosTes]                              + " " + ; 
                  Transform(aCols[nContar,nPosCm1] , "@E 999.99")     + " " + ;
                  Transform(aCols[nContar,nPosCm2] , "@E 999.99")     + CHR(13) + CHR(10)

       If Empty(Alltrim(aCols[nContar,nPosOCO]))
       Else
          cString += "                  OC: "       + Alltrim(aCols[nContar,nPosOCO]) + ;
                     " ANO: "     + Alltrim(aCols[nContar,nPosANO]) + ;
                     " ITEM OC: " + Alltrim(aCols[nContar,nPosITE]) + CHR(13) + CHR(10)
       Endif

       // ######################################
       // Atualiza o valor total dos produtos ##
       // ######################################
       nTotProdutos := nTotProdutos + aCols[nContar,nPosTot]

       // #############################
       // Pesquisa o tipo de cliente ##
       // #############################
       xTipoCli := POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_TIPO")

       // ###############################
       // Calculo ST e Outros Impostos ##
       // ###############################                     
       MaFisIni(M->C5_CLIENTE, M->C5_LOJACLI, "C", "N", xTipoCli, MaFisRelImp("MTR700",{"SC5","SC6"}),,,"SB1","MTR700")

       // #########################################################
       // Proporcionaliza o valro do frete para cálculo do Difal ##
       // #########################################################
       If M->C5_FRETE == 0
          nFreteRat   := 0
       Else
          nPercentual := Round((aCols[nContar,nPosTot] / nValorRateio) * 100,2)
          nFreteRat   := Round((M->C5_FRETE * nPercentual) / 100,2)
       Endif

       // ######################
       // Calcula os Impostos ##
       // ######################
       MaFisAdd(aCols[nContar,nPosCod]             ,; // 01 - Código do Produto (Obrigatório)
                aCols[nContar,nPosTes]             ,; // 02 - Código do TES (Obrigatório)
                aCols[nContar,nPosQtde]            ,; // 03 - Quantidade de Venda do Produto (Obrigatório)
                aCols[nContar,nPosPrc]             ,; // 04 - Preço Unitário de Venda do Produto (Obrigatório)
                0                                  ,; // 05 - Valor do Desconto (Opcional)
                ""                                 ,; // 06 - Nº da NF Original (Devolução/Beneficiamento)
                ""                                 ,; // 07 - Série da NF Original (Devolução/Beneficiamento)
                0                                  ,; // 08 - RecNo da NF Original do arq SD1/SD2
                0                                  ,; // 09 - Valor do Frete do Item ( Opcional )
                0                                  ,; // 10 - Valor da Despesa do item ( Opcional )
                0                                  ,; // 11 - Valor do Seguro do item ( Opcional )
                0                                  ,; // 12 - Valor do Frete Autonomo ( Opcional )
                aCols[nContar,nPosTot] + nFreteRat ,; // 13 - Valor da Mercadoria ( Obrigatorio )
                0                                  ,; // 14 - Valor da Embalagem ( Opiconal )
                0                                  ,; // 15 - RecNo do SB1
                0)                                    // 16 - RecNo do SF4
           
       // #################################
       // Captura os valores de impostos ##
       // #################################
       _nAliqIcm := MaFisRet(1,"IT_ALIQICM")
       _nValIcm  := MaFisRet(1,"IT_VALICM" )
       _nBaseIcm := MaFisRet(1,"IT_BASEICM")
       _nValIpi  := MaFisRet(1,"IT_VALIPI" )
       _nValMerc := MaFisRet(1,"IT_VALMERC")
       _nValSol  := MaFisRet(1,"IT_VALSOL" )
       aDifalPF  := MaFisRet(1,"IT_LIVRO"  )

       MaFisEnd()         

       nTotDifal := nTotDifal + _nValSol

   Next nContar

   cString += "----------------------------------------------------------------------------------------------------------------------" + CHR(13) + CHR(10)
   cString += "                                              TOTAL DO PEDIDO DE VENDA                                                " + CHR(13) + CHR(10)   
   cString += "----------------------------------------------------------------------------------------------------------------------" + CHR(13) + CHR(10)
   cString += "        TOTAL DOS PRODUTO                TOTAL DO FRETE               VALOR DIFAL      VALOR TOTAL DO PEDIDO          " + CHR(13) + CHR(10)
   cString += "----------------------------------------------------------------------------------------------------------------------" + CHR(13) + CHR(10)   
   cString += "               " + Transform(nTotProdutos, "@E 9999999.99") + "                    " + ;
                                  Transform(M->C5_FRETE, "@E 9999999.99")  + "                "     + ;
                                  Transform(nTotDifal, "@E 9999999.99")    + "                 "    + ;
                                  Transform((nTotProdutos + M->C5_FRETE + nTotDifal), "@E 9999999.99") + CHR(13) + CHR(10)   

   // ###########################################################
   // Desenha a tela para display dos dados do Pedido de Venda ##
   // ###########################################################
   DEFINE MSDIALOG oDlg TITLE "Resumo Pedido de Venda" FROM C(178),C(181) TO C(638),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1  MEMO Size C(385),C(001) PIXEL OF oDlg

   @ C(036),C(005) GET oMemo2 Var cString MEMO Size C(383),C(175) FONT oFont PIXEL OF oDlg

   @ C(214),C(351) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)