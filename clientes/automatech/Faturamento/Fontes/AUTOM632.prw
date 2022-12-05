#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM632.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##                    
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 19/09/2017                                                          ##
// Objetivo..: Programa que mostra variáveis para cálculo do SimFrete              ##
// ##################################################################################

User Function AUTOM632()

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

   Local kValorTotal := 0
   Local kQtdGeral   := 0
   Local kPesogeral  := 0

   Private oDlg

   U_AUTOM628("AUTOM632")
   
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
   cString += "----------------------------------------------------------------------------------------------------------------------" + CHR(13) + CHR(10) 
   cString += "                                        VARIÁVEIS DE PARA CÁLCULO DE FRETE - SIMFRETE                                 " + CHR(13) + CHR(10) 
   cString += "----------------------------------------------------------------------------------------------------------------------" + CHR(13) + CHR(10) + CHR(13) + CHR(10)

   kpesoGeral := 0

   For nContar = 1 to Len(aCols)
   
       kForma       := POSICIONE("SB1",1, XFILIAL("SB1") + aCols[nContar,nPosCod], "B1_EMBA")
       kIndividual  := POSICIONE("SB1",1, XFILIAL("SB1") + aCols[nContar,nPosCod], "B1_ZVIN")
       kAltura      := POSICIONE("SB1",1, XFILIAL("SB1") + aCols[nContar,nPosCod], "B1_ALTU")
       kLargura     := POSICIONE("SB1",1, XFILIAL("SB1") + aCols[nContar,nPosCod], "B1_LARG")
       kComprimento := POSICIONE("SB1",1, XFILIAL("SB1") + aCols[nContar,nPosCod], "B1_COMP")
       kBase        := POSICIONE("SB1",1, XFILIAL("SB1") + aCols[nContar,nPosCod], "B1_ZBAS")
       kRaio        := POSICIONE("SB1",1, XFILIAL("SB1") + aCols[nContar,nPosCod], "B1_RAIO")
       kLado        := POSICIONE("SB1",1, XFILIAL("SB1") + aCols[nContar,nPosCod], "B1_LADO")
       kPeso        := POSICIONE("SB1",1, XFILIAL("SB1") + aCols[nContar,nPosCod], "B1_PESC")
       kPesoTot     := Str(aCols[nContar,nPosQtde] * kPeso,10,03)

       kValorTotal  := kValorTotal + (aCols[nContar,nPosQtde] * aCols[nContar,nPosPrc])
       kQtdGeral    := kQtdGeral   + aCols[nContar,nPosQtde]
       kPesogeral   := kPesogeral  + (aCols[nContar,nPosQtde] * kPeso)

       Do Case
          Case kForma == "1"
               nForma   := "CUBO"
               kFormula := "LARGURA X ALTURA X COMPRIMENTO"
          Case kForma == "2"
               nForma   := "RETANGULO"
               kFormula := "LARGURA X ALTURA X COMPRIMENTO"
          Case kForma == "3"
               nForma   := "CILINDRO"
               kFormula := "PI X (R)2 X ALTURA"
          Case kForma == "4"
               nForma   := "PRISMA"
               kFormula := "BASE X ALTURA"
          Case kForma == "5"
               nForma   := "PIRAMIDE"
               kFormula := "(ALTURA * LADO * LADO) / 3"
          Case kForma == "6"
               nForma   := "CONE"
               kFormula := "(PI * (RAIO X RAIO) * ALTURA) / 3"
          Case kForma == "7"
               nForma   := "ESFERA"
               kFormula := "(4 * PI * (RAIO X RAIO X RAIO)) / 3"
          Otherwise
               nForma   := "Forma não indicada para o produto"
               kFormula := ""
       EndCase        

       cString += Strzero(nContar,3) + "º PRODUTO"                            + CHR(13) + CHR(10) + CHR(13) + CHR(10)
       cString += "Produto...........: " + aCols[nContar,nPosCod]             + CHR(13) + CHR(10)
       cString += "Descrição.........: " + aCols[nContar,nPosDesc]            + CHR(13) + CHR(10)
       cString += "Quantidade........: " + Str(aCols[nContar,nPosQtde],10,02) + CHR(13) + CHR(10)
       cString += "Unitário..........: " + Str(aCols[nContar,nPosPrc],10,02)  + CHR(13) + CHR(10)
       cString += "Total Produto.....: " + Str(aCols[nContar,nPosTot],10,02)  + CHR(13) + CHR(10)
       cString += "Forma do Produto..: " + nForma                             + CHR(13) + CHR(10)
       cString += "Cál.Vol. Indiviual: " + kIndividual                        + CHR(13) + CHR(10)
       cString += "Fórmula...........: " + kFormula                           + CHR(13) + CHR(10)
       cString += "Altura............: " + Str(kAltura,10,03) + " cm"         + CHR(13) + CHR(10)
       cString += "Largura...........: " + Str(kLargura,10,03) + " cm"        + CHR(13) + CHR(10)
       cString += "Comprimento.......: " + Str(kComprimento,10,03) + " cm"    + CHR(13) + CHR(10)
       cString += "Base..............: " + Str(kBase,10,03) + " cm"           + CHR(13) + CHR(10)
       cString += "Raio..............: " + Str(kRaio,10,03) + " cm"           + CHR(13) + CHR(10)
       cString += "Lado..............: " + Str(kLado,10,03) + " cm"           + CHR(13) + CHR(10)
       cString += "Peso Individual...: " + Str(kPeso,10,03) + " Kgs"          + CHR(13) + CHR(10)
       cString += "Peso Total........: " + kPesoTot         + " Kgs"          + CHR(13) + CHR(10) + CHR(13) + CHR(10)
       
   Next nContar
   
   cString += "Valor Total do Pedido: " + Str(kValorTotal,10,02)           + CHR(13) + CHR(10)
   cString += "Quantidade Total.....: " + Str(kQtdGeral,10,02)             + CHR(13) + CHR(10)
   cString += "Peso Total Produtos..: " + Str(kPesogeral,10,03)  + " Kgs"  + CHR(13) + CHR(10)

   // ###########################################################
   // Desenha a tela para display dos dados do Pedido de Venda ##
   // ###########################################################
   DEFINE MSDIALOG oDlg TITLE "Parâmetros Web Service SimFrete (SM)" FROM C(178),C(181) TO C(638),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1  MEMO Size C(385),C(001) PIXEL OF oDlg

   @ C(036),C(005) GET oMemo2 Var cString MEMO Size C(383),C(175) FONT oFont PIXEL OF oDlg

   @ C(214),C(005) Button "Parâmetros Web Service" Size C(100),C(012) PIXEL OF oDlg ACTION( ParWebSrvSM() )
   @ C(214),C(351) Button "Voltar"                 Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #######################################################################################################################
// Função que abre tela para visualização dos parâmetros enviados e recebidos do web service do Sale Machine (SimFrete) ##
// ####################################################################################################################### 
Static Function ParWebSrvSM()

   Local cMemo1	     := ""
   Local cMemo2	     := ""
   Local cParametros := Alltrim(M->C5_ZRSM)
   
   Local oMemo1
   Local oMemo2
   Local oFont

   Private oDlg

   DEFINE FONT oFont Name "Courier New" Size 0, -14 BOLD

   // #############################################
   // Desenha a tela para display dos parâmetros ##
   // #############################################
   DEFINE MSDIALOG oDlgWS TITLE "Parâmetros Web Service SimFrete (SM)" FROM C(178),C(181) TO C(638),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp"     Size C(130),C(026) PIXEL NOBORDER OF oDlgWS

   @ C(032),C(002) GET oMemo1 Var cMemo1      MEMO Size C(385),C(001) PIXEL OF oDlgWS

   @ C(036),C(005) GET oMemo2 Var cparametros MEMO Size C(383),C(175) FONT oFont PIXEL OF oDlgWS

   @ C(214),C(351) Button "Voltar"                 Size C(037),C(012) PIXEL OF oDlgWS ACTION( oDlgWS:End() )

   ACTIVATE MSDIALOG oDlgWS CENTERED 

Return(.T.)