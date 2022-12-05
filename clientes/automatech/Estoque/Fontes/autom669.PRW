#INCLUDE "TOTVS.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'AP5MAIL.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#DEFINE  ENTER CHR(13)+CHR(10)

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM669.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald hans Löschenkohl                                             ##
// Data......: 11/01/2018                                                          ##
// Objetivo..: Novo layout da Ordem de Produção - Atech                            ##
// ##################################################################################

User Function AUTOM669()

   Local aArea  	  := GetArea()
   Local cSql         := ""
   Local cGramat      :=	""
   Local cMetr	      :=	""
   Local cEtqRol      :=	""
   Local cRolos	      :=	""
   Local nMetr        := 0
   Local nEtqRol      := 0
   Local nRolos       := 0
   Local aEmbalagem   := {}

   Private nLinha	  := 000
   Private nPagina	  := 001
   Private cLogo 	  := "nlogoautoma.bmp"   && 'lgrl01.bmp'
   Private aComp	  := {}
   Private aPanF	  := {}
   Private aPanV	  := {}
   Private nCount     := 0                          
   Private __nQtdLin  := 0
   Private __nQtdM2   := 0
   Private aImpressos := {}

   // #######################################################################
   // Verifica se existe a pasta C:\SIMFRETE. Caso não exista, será criada ##
   // #######################################################################
   If !ExistDir( "\IMGETQ" )

      nRet := MakeDir( "\IMGETQ" )
   
      If nRet != 0
         MsgAlert("Não foi possível criar a pasta \IMGETQ - Erro: " + cValToChar( FError() ) )
         Return(.T.)
      Endif
   
   Endif

   // #############################
   // Carrega o array aEmbalagem ##
   // #############################
   If Select("T_EMBALAGEM") > 0
      T_EMBALAGEM->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZPJ_FILIAL,"
   cSql += "       ZPJ_CODI  ,"
   cSql += "	   ZPJ_NOME  ,"
   cSql += "	   ZPJ_VTOT   "
   cSql += "  FROM " + RetSqlName("ZPJ")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += " ORDER BY ZPJ_VTOT"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EMBALAGEM", .T., .T. )

   T_EMBALAGEM->( DbGoTop() )
   
   WHILE !T_EMBALAGEM->( EOF() )
      aAdd( aEmbalagem, { T_EMBALAGEM->ZPJ_CODI, T_EMBALAGEM->ZPJ_NOME, T_EMBALAGEM->ZPJ_VTOT })
      T_EMBALAGEM->( DbSkip() )
   ENDDO

   // ##################################################
   // Abre a tela de parâmettros para impressão da OP ##
   // ##################################################
   Pergunte("AUTR314",.T.)

   // #####################################################
   // Posiciona a ordem de produção passada no parâmetro ##
   // #####################################################
   DbSelectArea("SC2")
   DBSEEK(xFilial("SC2") + MV_PAR01)

   If SC2->C2_ZQTD == 0
   Else
      DbSelectArea("SC2")
      RecLock("SC2",.F.)
      SC2->C2_QUANT := SC2->C2_ZQTD 
      SC2->C2_ZQTD  := 0
      MsUnLock()              
   Endif

   // ##############################################################
   // Cria os fontes de letras para utilização na impressão da OP ##
   // ##############################################################
   oFont12   := TFont():New( "Arial",,12,,.F.,,,,,.F. )
   oFont12N  := TFont():New( "Arial",,12,,.T.,,,,,.F. )
   oFontC 	 := TFont():New( "Arial",,9,,.T.,,,,,.F.  )
   oFontC1	 := TFont():New( "Arial",,14,,.T.,,,,,.F. )
   oFontC2	 := TFont():New( "Arial",,16,,.T.,,,,,.F. )
   oFont10   := TFont():New( "Arial",,10,,.F.,,,,,.F. )
   oFont10N  := TFont():New( "Arial",,10,,.T.,,,,,.F. )
   oFont09N  := TFont():New( "Arial",,09,,.T.,,,,,.F. )

   // ##########################
   // Parâmetros de Impressão ##
   // ##########################
   oPrint := TAvPrinter():New( "Relatório de Ordem de Produção" )
   oPrint :Setup() 
   oPrint:SetPortrait() 		//	Retrato
   //oPrint:SetLandscape()		//	Paisagem
   //oPrint:nHorzRes()			//	Retorna a resolução horizontal da impressora configurada.
   oPrint:SetPaperSize(9)     	//	(DMPAPER_A4)
                                                  
   // ########################################################
   // Retorna a orientação (Retrato ou Paisagem) do objeto. ##
   // ########################################################
   If oPrint:GetOrientation()	!= 1		//	1=Portrait (retrato) ou 2=Landscape (paisagem).
	  oPrint:SetPortrait()
   EndIf    

   // ###################################################
   // Seta o códiugo da Filial conforme Empresa logada ##
   // ###################################################
   k_Filial := cFilAnt

//   If cEmpAnt == "01" .And. cFilAnt == "04"
//      k_Filial := "04"
//   Endif
//
//   If cEmpAnt == "01" .And. cFilAnt == "07"
//      k_Filial := "07"
//   Endif
//
//   If cEmpAnt == "03" .And. cFilAnt == "01"
//      k_Filial := "01"
//   Endif      
   
   // ##########################
   // Cria condição de filtro ##
   // ##########################
   cCondicao := "C2_FILIAL == '" + Alltrim(k_Filial) + "' .AND. C2_NUM + C2_ITEM + C2_SEQUEN >= '" + MV_PAR01 + "' .AND. C2_NUM + C2_ITEM + C2_SEQUEN <= '" + MV_PAR02 + "' "

   If !Empty(MV_PAR03)
      cCondicao += ".AND. C2_EMISSAO >= CTOD('"+DTOC(MV_PAR03)+"') .AND. C2_EMISSAO <= CTOD('"+DTOC(MV_PAR04)+"')  "
   Endif

   // ###########################
   // Set Filter to &cCondicao ##
   // DBGotop()                ##
   // ###########################
   cChave := xFilial("SC2") + C2_NUM + C2_ITEM + C2_SEQUEN

   Do While !Eof() .and. &cCondicao

      IF &cCondicao
   
         aAdd( aImpressos, C2_NUM )

         IF xFilial("SC2") + C2_NUM + C2_ITEM + C2_SEQUEN <> cChave
            cChave  := xFilial("SC2") + C2_NUM + C2_ITEM + C2_SEQUEN
            nPagina := 01
         ENDIF

         nLinha := 025

         oPrint:StartPage()

         // ##################################################
         // Captura dados do pedido de venda para impressão ##
         // ##################################################
         If !Empty(SC2->C2_PEDIDO)

            DbSelectArea('SC5')
            DbSetOrder(1)
            DbGoTop()
	        
	        If DbSeek(xFilial('SC5') + SC2->C2_PEDIDO, .F.)
               cProducao   := Alltrim(SC2->C2_NUM) + "." + Alltrim(SC2->C2_ITEM) + "." + Alltrim(SC2->C2_SEQUEN)
               cCliente	   := Alltrim(SC5->C5_CLIENTE) + '.'   + Alltrim(SC5->C5_LOJACLI) + " - " + AllTrim(Posicione('SA1', 1, xFilial('SA1') + SC5->C5_CLIENTE + SC5->C5_LOJACLI,'A1_NOME')) 
               cCidade     := AllTrim(Posicione('SA1', 1, xFilial('SA1') + SC5->C5_CLIENTE + SC5->C5_LOJACLI,'A1_MUN')) + "/" + ;
                              AllTrim(Posicione('SA1', 1, xFilial('SA1') + SC5->C5_CLIENTE + SC5->C5_LOJACLI,'A1_EST'))
		       cVendedor   := Alltrim(SC5->C5_VEND1)   + " - " + AllTrim(Posicione('SA3', 1, xFilial('SA3') + SC5->C5_VEND1 ,'A3_NOME'))
		       cTransporte := Alltrim(SC5->C5_TRANSP)  + " - " + Alltrim(Posicione('SA4', 1, xFilial('SA4') + SC5->C5_TRANSP,'A4_NOME'))
               cPedido     := Alltrim(SC2->C2_PEDIDO ) + " - " + Alltrim(SC2->C2_ITEMPV)
               cCodPedi    := SC2->C2_PEDIDO
               cEmissao    := "EMISSÃO OP: " + Dtoc(Date()) + " / " + Time() + " / EMISSÃO PV: " + DtoC(SC5->C5_EMISSAO)
               cEntrega    := DtoC(SC2->C2_DATPRF)
               cQuantidade := Transform(SC2->C2_QUANT, PesqPict("SC2","C2_QUANT", TamSx3('C2_QUANT')[1])) + " " + Alltrim(Posicione('SB1', 1, xFilial('SB1')+SC2->C2_PRODUTO,'B1_UM'  ))
               cQtdProduto := SC2->C2_QUANT
               cCodProduto := SC2->C2_PRODUTO
               cProduto    := Alltrim(SC2->C2_PRODUTO) + " - " + Alltrim(Posicione('SB1', 1, xFilial('SB1')+SC2->C2_PRODUTO,'B1_DESC')) + " " + ;
															     Alltrim(Posicione('SB1', 1, xFilial('SB1')+SC2->C2_PRODUTO,'B1_DAUX'))
															     
            Else
               cProducao   := Alltrim(SC2->C2_NUM) + "." + Alltrim(SC2->C2_ITEM) + "." + Alltrim(SC2->C2_SEQUEN)
               cCliente	   := ""
               cCidade     := ""
		       cVendedor   := ""
		       cTransporte := ""
               cPedido     := ""
               cCodPedi    := ""
               cEmissao    := Dtoc(Date()) + " / " + Time()
               cEntrega    := ""
               cQuantidade := ""
               cQtdProduto := 0
               cCodProduto := ""
               cProduto    := ""
            Endif
         Else      
            cProducao   := Alltrim(SC2->C2_NUM) + "." + Alltrim(SC2->C2_ITEM) + "." + Alltrim(SC2->C2_SEQUEN)
            cCliente	:= "OP AVULSA"
            cCidade     := ""
            cVendedor   := ""
            cTransporte := ""
            cPedido     := ""
            cCodPedi    := ""
            cEmissao    := Dtoc(Date()) + " / " + Time()
            cEntrega    := ""
            cQuantidade := Transform(SC2->C2_QUANT, PesqPict("SC2","C2_QUANT", TamSx3('C2_QUANT')[1])) + " " + Alltrim(Posicione('SB1', 1, xFilial('SB1')+SC2->C2_PRODUTO,'B1_UM'  ))
            cQtdProduto := SC2->C2_QUANT
            cCodProduto := SC2->C2_PRODUTO
            cProduto    := Alltrim(SC2->C2_PRODUTO) + " - " + Alltrim(Posicione('SB1', 1, xFilial('SB1')+SC2->C2_PRODUTO,'B1_DESC')) + " " + ;
 													          Alltrim(Posicione('SB1', 1, xFilial('SB1')+SC2->C2_PRODUTO,'B1_DAUX'))
         Endif
                 
         // ############################
         // De cima para baixo: Box 1 ##
         // ############################
         oPrint:Box(nLinha, 020, nLinha + 180, 2370)
   
         nLinha += 15

         // ####################################
         // Imprime a logomarca da Automatech ##
         // ####################################
         oPrint:SayBitmap( nLinha, 030, "xlogoautoma.bmp", nLinha + 450,150)

         nLinha += 50

         oPrint:Say( nLinha, 0825,  PADR("AUTOMATECH - Empresa: " + Upper(Alltrim(SM0->M0_NOME)) + " / Filial: " +  Alltrim(SM0->M0_FILIAL),100), oFontC1, 1400, CLR_BLACK )

         nLinha += 130

         // ############################
         // De cima para baixo: Box 2 ##
         // ############################
         oPrint:Box(nLinha, 020, nLinha + 135, 2370)

         nLinha += 25

         oPrint:Say( nLinha, 0035, 'CLIENTE: '  + Alltrim(cCliente) , oFontC, 1400, CLR_BLACK )
         oPrint:Say( nLinha, 1600, 'VENDEDOR: ' + Alltrim(cVendedor), oFontC, 1400, CLR_BLACK )

         nLinha += 50

         oPrint:Say( nLinha, 0035, "TRANSP.: " + Alltrim(cTransporte), oFontC, 1400, CLR_BLACK )
         oPrint:Say( nLinha, 1600, "CIDADE: "  + Alltrim(cCidade)    , oFontC, 1400, CLR_BLACK )

         nLinha += 85

         // ############################
         // De cima para baixo: Box 3 ##
         // ############################
         oPrint:Box(nLinha, 020, nLinha + 250, 2370)

         nLinha += 25

         // ##################################################
         // Imprime o código de barras da Ordem de Produção ##
         // ##################################################
         MsBar3("CODE128",04,16,SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN,oPrint,.F.,,.T.,0.030,1.0,.F.,,,.F.) 

         oPrint:Say( nLinha + 13, 0035, "OP: "   , oFontC , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0200     , cProducao, oFontC2, 1400, CLR_BLACK )

         IF "EXATA" $ SC2->C2_OBS
            oPrint:Say( nLinha, 1900, 'QUANTIDADE EXATA', oFontC2, 1400, CLR_BLACK )
         ENDIF

         nLinha += 80

         oPrint:Say( nLinha + 17 , 0035, "PEDIDO: ", oFontC , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0200      , cPedido   , oFontC2, 1400, CLR_BLACK )

         nLinha += 80

         oPrint:Say( nLinha, 0035, cEmissao, oFontC , 1400, CLR_BLACK )

         nLinha += 85

         // ############################
         // De cima para baixo: Box 4 ##
         // ############################
         oPrint:Box(nLinha, 020, nLinha + 165, 2370)

         nLinha += 25

         oPrint:Say( nLinha + 05 , 0035, "PRODUTO: ", oFontC , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0250, cProduto         , oFontC2, 1400, CLR_BLACK )
         
         nLinha += 60

         oPrint:Say( nLinha + 05, 0035, "QTD: "    , oFontC , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0150     , cQuantidade, oFontC2, 1400, CLR_BLACK )

         oPrint:Say( nLinha + 05, 1500, "ENTREGA: ", oFontC , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 1700     , cEntrega   , oFontC2, 1400, CLR_BLACK )

         nLinha += 95

         // ############################
         // De cima para baixo: Box 5 ##
         // ############################
         oPrint:Box(nLinha, 020, nLinha + 80, 2370)

         nLinha += 05

         oPrint:Say( nLinha, 1000, "COMPONENTES", oFontC2 , 1400, CLR_BLACK )

         nLinha += 74
   
         // ############################
         // De cima para baixo: Box 5 ##
         // ############################
         oPrint:Box(nLinha, 020, nLinha + 080, 2370)

         oPrint:Box(nLinha, 020, nLinha + 193, 0180)
         oPrint:Box(nLinha, 020, nLinha + 193, 1700)
         oPrint:Box(nLinha, 020, nLinha + 193, 2000)

         nLinha += 20

         oPrint:Say( nLinha, 0035, "CÓDIGO"      , oFontC , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0200, "DESCRIÇÃO"   , oFontC , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 1825, "M2"          , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 2055, "MTS LINEARES", oFontC , 1400, CLR_BLACK )   

         nLinha += 61
         
         // ######################################
         // Carrega o array aComp - Componentes ##
         // ######################################
         aComp     := U_xBuscaComp()

         // ############################
         // De cima para baixo: Box 6 ##
         // ############################
         oPrint:Box(nLinha, 020, nLinha + 110, 2370)

         nLinha += 20
         nVezes := 2

         For nComponente = 1 to Len(aComp)

             // ###############################
             // Calcula dados para impressão ##
             // ###############################
             __nQtdLin := U_CalcPerda("OP", SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN,SC2->C2_PRODUTO,.F.)
	         __nQtdM2  := IIF(Len(aComp)>0,__nQtdLin * aComp[nComponente][8],0)

             // #################################################
             // Atualiza a metragem linear DA op NA TABELA sc2 ##
             // #################################################
//           DbSelectArea("SC2")
//           RecLock("SC2",.F.)
//           If SC2->C2_ZQTD == 0
//              SC2->C2_ZQTD := SC2->C2_QUANT
//           Endif   
//           SC2->C2_QUANT:= __nQtdLin
//           MsUnLock()              



             oPrint:Say( nLinha, 0040, aComp[nComponente,01]             , oFontC , 1400, CLR_BLACK )
             oPrint:Say( nLinha, 0205, aComp[nComponente,02]             , oFontC , 1400, CLR_BLACK )

             oPrint:Say( nLinha, 1765, Transform(__nQtdM2 , "9999999.99"), oFontC , 1400, CLR_BLACK )   
             oPrint:Say( nLinha, 2130, Transform(__nQtdLin, "999999.999"), oFontC , 1400, CLR_BLACK )   
                      
/////             oPrint:Say( nLinha, 1765, Transform(__nQtdM2 , "9999999.99"), oFontC , 1400, CLR_BLACK )   
/////             oPrint:Say( nLinha, 2130, Transform(SC2->C2_QUANT, "999999.999"), oFontC , 1400, CLR_BLACK )   


             nLinha += 50
             nVezes := nVezes - 1
   
             If nVezes == 0
                Exit
             Endif   

         Next nComponente

         Do Case
            Case nVezes == 2
                 nLinha += 100
            Case nVezes == 1
                 nLinha += 50
         EndCase        
                 
         nLinha += 61

         // ############################
         // De cima para baixo: Box 7 ##
         // ############################
         oPrint:Box(nLinha, 020, nLinha + 83, 2370)

         nLinha += 07

         oPrint:Say( nLinha, 975, "CARACTERÍSTICAS", oFontC2 , 1400, CLR_BLACK )

         nLinha += 75
   
         // ############################
         // De cima para baixo: Box 8 ##
         // ############################
         oPrint:Box(nLinha, 020, nLinha + 080, 2370)
 
         oPrint:Box(nLinha, 020, nLinha + 170, 0260) // Faca
         oPrint:Box(nLinha, 020, nLinha + 170, 0410) // Código
         oPrint:Box(nLinha, 020, nLinha + 170, 1400) // Substrato
         oPrint:Box(nLinha, 020, nLinha + 170, 1600) // Tubete
         oPrint:Box(nLinha, 020, nLinha + 170, 1850) // Serilha

         nLinha += 22

         oPrint:Say( nLinha, 0050, "FACA"           , oFontC , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0275, "CÓDIGO"         , oFontC , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0800, "SUBSTRATO"      , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 1450, "TUBETE"         , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 1680, "SERILHA"        , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 1960, "CARACTERÍSTICA" , oFontC , 1400, CLR_BLACK )   

         nLinha += 58
   
         // ############################
         // De cima para baixo: Box 9 ##
         // ############################
         oPrint:Box(nLinha, 020, nLinha + 90, 2370)

         nLinha += 22

         // ########################################################
         // Pesquisa as características do produto para impressão ##
         // ########################################################
         _cFaca   := U_BuscaCar(SC2->C2_PRODUTO,"FAC")
         _xFaca   := Substr(SC2->C2_PRODUTO,03,04)
         _cPapel  := U_BuscaCar(SC2->C2_PRODUTO,"PAP")
         _cTubete := U_BuscaCar(SC2->C2_PRODUTO,"TUB")
         _cSerr	  := U_BuscaCar(SC2->C2_PRODUTO,"SER")
         _cCarac  := U_BuscaCar(SC2->C2_PRODUTO,"CAR")

         oPrint:Say( nLinha, 0040, _cFaca   , oFontC , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0285, _xFaca   , oFontC , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0420, _cPapel  , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 1510, _cTubete , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 1735, _cSerr   , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 1865, _cCarac  , oFontC , 1400, CLR_BLACK )   

         nLinha += 79

         // #########################################
         // De cima para baixo: Box 10 - IMPRESSÃO ##
         // #########################################
         oPrint:Box(nLinha, 0020, nLinha + 83, 1225)
         oPrint:Box(nLinha, 1250, nLinha + 83, 2370)

         nLinha += 10

         oPrint:Say( nLinha, 0500, "IMPRESSÃO", oFontC2 , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 1800, "MÁQUINA"  , oFontC2 , 1400, CLR_BLACK )

         nLinha += 72

         oPrint:Box(nLinha, 020, nLinha + 450, 0190)
         oPrint:Box(nLinha, 020, nLinha + 450, 0395)
         oPrint:Box(nLinha, 020, nLinha + 450, 0640)  
         oPrint:Box(nLinha, 020, nLinha + 450, 1225)  
   
         oPrint:Box(nLinha, 1250, nLinha + 450, 1495)
         oPrint:Box(nLinha, 1250, nLinha + 450, 2370)

         // ################################
         // Box da Impressão e da Máquina ##
         // ################################
         oPrint:Box(nLinha, 0020, nLinha + 50, 1225)
         oPrint:Box(nLinha, 1250, nLinha + 50, 2370)

         nLinha += 10

         oPrint:Say( nLinha, 0035, "ESTÁGIO"  , oFont09N , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0200, "PANTONE"  , oFont09N , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0400, "ANILOX"   , oFont09N , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 0650, "BORRACHA" , oFont09N , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 1280, "CÓDIGO"   , oFont09N , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 1515, "MÁQUINA"  , oFont09N , 1400, CLR_BLACK )   

         nLinha += 50

         // ################################################################
         // Inicializa as variáveis de Impressão e Máquina para impressão ##
         // ################################################################
         kEstagio01 := ""; kEstagio02 := ""; kEstagio03 := ""; kEstagio04 := ""; kEstagio05 := ""; kEstagio06 := ""; kEstagio07 := ""; kEstagio08 := ""
         kPantone01 := ""; kPantone02 := ""; kPantone03 := ""; kPantone04 := ""; kPantone05 := ""; kPantone06 := ""; kPantone07 := ""; kPantone08 := ""                                                      
         kAnilox01  := ""; kAnilox02  := ""; kAnilox03  := ""; kAnilox04  := ""; kAnilox05  := ""; kAnilox06  := ""; kAnilox07  := ""; kAnilox08  := ""                                             
         kBorra01   := ""; kBorra02   := ""; kBorra03   := ""; kBorra04   := ""; kBorra05   := ""; kBorra06   := ""; kBorra07   := ""; kBorra08   := ""                                                      
         kCodMaq01  := ""; kCodMaq02  := ""; kCodMaq03  := ""; kCodMaq04  := ""; kCodMaq05  := ""; kCodMaq06  := ""; kCodMaq07  := ""; kCodMaq08  := ""                                                      
         KNome01    := ""; KNome02    := ""; KNome03    := ""; KNome04    := ""; KNome05    := ""; KNome06    := ""; KNome07    := ""; KNome08    := "" 

         // ###########################################################
         // Pesquisa os estágios do produto e máquina para impressão ##
         // ###########################################################
         If Select("T_ESTAGIOS") > 0
            T_ESTAGIOS->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT ZP3.ZP3_ESTAG ,"
         cSql += "       ZP3.ZP3_PANTON,"
         cSql += "	     ZP3.ZP3_ANILOX,"
         cSql += "	     ZP3.ZP3_BORR  ," 
         cSql += "      (SELECT H1_CODIGO FROM " + RetSqlName("SH1") + " WHERE H1_FILIAL = ZP3.ZP3_FILIAL AND H1_CODIGO = ZP3.ZP3_RECURS AND D_E_L_E_T_ = '') AS CODIGO   ,"
         cSql += "      (SELECT H1_DESCRI FROM " + RetSqlName("SH1") + " WHERE H1_FILIAL = ZP3.ZP3_FILIAL AND H1_CODIGO = ZP3.ZP3_RECURS AND D_E_L_E_T_ = '') AS DESCRICAO "
         cSql += "  FROM " + RetSqlName("ZP3") + " ZP3 "
         cSql += " WHERE ZP3.ZP3_FILIAL = '" + Alltrim(cFilAnt)     + "'"
         cSql += "   AND ZP3.ZP3_COD    = '" + Alltrim(cCodProduto) + "'"
         cSql += "   AND ZP3.D_E_L_E_T_ = ''"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ESTAGIOS", .T., .T. )

         T_ESTAGIOS->( DbGoTop() )

         nAteOito := 0
          
         WHILE !T_ESTAGIOS->( EOF() )

            nAteOiti := nAteOito + 1

            If nAteOito == 9
               Exit
            Endif             

            j := Strzero(nAteOito,2)

            kEstagio&j := T_ESTAGIOS->ZP3_ESTAG
            kPantone&J := T_ESTAGIOS->ZP3_PANTON
            kAnilox&J  := T_ESTAGIOS->ZP3_ANILOX
            kBorra&j   := T_ESTAGIOS->ZP3_BORR
            kCodMaq&J  := T_ESTAGIOS->CODIGO
            KNome&J    := T_ESTAGIOS->DESCRICAO
             
            T_ESTAGIOS->( DbSkip() )
             
         ENDDO   

         For xImprime = 1 to 8

             j := Strzero(xImprime,2)

             oPrint:Say( nLinha, 0040, kEstagio&j, oFontC , 1400, CLR_BLACK )
             oPrint:Say( nLinha, 0205, kPantone&j, oFontC , 1400, CLR_BLACK )
             oPrint:Say( nLinha, 0405, kAnilox&j , oFontC , 1400, CLR_BLACK )   
             oPrint:Say( nLinha, 0655, kBorra&j  , oFontC , 1400, CLR_BLACK )   
             oPrint:Say( nLinha, 1305, kCodMaq&j , oFontC , 1400, CLR_BLACK )   
             oPrint:Say( nLinha, 1505, kNome&j   , oFontC , 1400, CLR_BLACK )   

             nLinha += 50
             
         Next xImprime    

/*
         oPrint:Say( nLinha, 0040, kEstagio02, oFontC , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0205, kPantone02, oFontC , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0405, kAnilox02 , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 0655, kBorra02  , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 1305, kCodMaq02 , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 1505, kNome02   , oFontC , 1400, CLR_BLACK )   

         nLinha += 50

         oPrint:Say( nLinha, 0040, kEstagio03, oFontC , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0205, kPantone03, oFontC , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0405, kAnilox03 , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 0655, kBorra03  , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 1305, kCodMaq03 , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 1505, kNome03   , oFontC , 1400, CLR_BLACK )   

         nLinha += 50

         oPrint:Say( nLinha, 0040, kEstagio04, oFontC , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0205, kPantone04, oFontC , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0405, kAnilox04 , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 0655, kBorra04  , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 1305, kCodMaq04 , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 1505, kNome04   , oFontC , 1400, CLR_BLACK )   

         nLinha += 50

         oPrint:Say( nLinha, 0040, kEstagio05, oFontC , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0205, kPantone05, oFontC , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0405, kAnilox05 , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 0655, kBorra05  , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 1305, kCodMaq05 , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 1505, kNome05   , oFontC , 1400, CLR_BLACK )   

         nLinha += 50

         oPrint:Say( nLinha, 0040, kEstagio06, oFontC , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0205, kPantone06, oFontC , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0405, kAnilox06 , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 0655, kBorra06  , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 1305, kCodMaq06 , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 1505, kNome06   , oFontC , 1400, CLR_BLACK )   

         nLinha += 50

         oPrint:Say( nLinha, 0040, kEstagio07, oFontC , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0205, kPantone07, oFontC , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0405, kAnilox07 , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 0655, kBorra07  , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 1305, kCodMaq07 , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 1505, kNome07   , oFontC , 1400, CLR_BLACK )   

         nLinha += 50

         oPrint:Say( nLinha, 0040, kEstagio08, oFontC , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0205, kPantone08, oFontC , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0405, kAnilox08 , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 0655, kBorra08  , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 1305, kCodMaq08 , oFontC , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 1505, kNome08   , oFontC , 1400, CLR_BLACK )   

         nLinha += 61


*/

         // ########################################
         // De cima para baixo: Box 11 - PRODUÇÃO ##
         // ########################################
         oPrint:Box(nLinha, 020, nLinha + 83, 2370)

         nLinha += 10

         oPrint:Say( nLinha, 0980, "# # # PRODUÇÃO # # #", oFontC2 , 1400, CLR_BLACK )

         nLinha += 72

         oPrint:Box(nLinha, 020, nLinha + 050, 0595)
         oPrint:Box(nLinha, 020, nLinha + 050, 1295)
         oPrint:Box(nLinha, 020, nLinha + 050, 1940)  
         oPrint:Box(nLinha, 020, nLinha + 050, 2370)  

         nLinha += 10

         oPrint:Say( nLinha, 0035, "GRAMATURA"        , oFont10N , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0750, "METRO LINEAR ROLO", oFont10N , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 1500, "ETQ/ROLO"         , oFont10N , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 2100, "ROLOS"            , oFont10N , 1400, CLR_BLACK )   

         nLinha += 40

         // ################################################
         // Pesquisa os dados de gramatura para impressão ##
         // ################################################
         DbSelectArea('SB1')
         DbSetOrder(1)
         DbGoTop()

         If DbSeek(xFilial('SB1') + SC2->C2_PRODUTO, .F.)

	        _aRet1 := U_CALCMETR(SC2->C2_PRODUTO)

    	    // ###############################
  	        // 1 = Metragem Linear por rolo ##
	        // 2 = Qtd Etoquetas por rolo   ##
	        // 3= Tubete                    ##
	        // ###############################
	        cGramat := TABELA("ZP",SB1->B1_MPCLAS,.f.)
	        nMetr	:= _aRet1[1]
	        nEtqRol := _aRet1[2]

	        IF SB1->B1_UM == "MI"
               nRolos	 := (SC2->C2_QUANT*1000)/nEtqRol
               // nRolos := (SC2->C2_ZQTD*1000)/nEtqRol
	        ELSE
               nRolos	 :=	SC2->C2_QUANT
//             nRolos :=	SC2->C2_ZQTD
	        ENDIF

         EndIf

         oPrint:Say( nLinha, 0030, PadC(cGramat,20,'')              , oFontC2 , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 0800, TRANSFORM(nMetr  ,"@R 999,999.9"), oFontC2 , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 1500, TRANSFORM(nEtqRol,"@R 999,999")  , oFontC2 , 1400, CLR_BLACK )   
         oPrint:Say( nLinha, 2050, TRANSFORM(nRolos ,"@R 999,999")  , oFontC2 , 1400, CLR_BLACK )   

         oPrint:Box(nLinha, 020, nLinha + 065, 0595)
         oPrint:Box(nLinha, 020, nLinha + 065, 1295)
         oPrint:Box(nLinha, 020, nLinha + 065, 1940)
         oPrint:Box(nLinha, 020, nLinha + 065, 2370)  

         nLinha += 79

         // ################################################
         // De cima para baixo: Box 12 - POSIÇÃO DE SAÍDA ##
         // ################################################
         oPrint:Box(nLinha, 0020, nLinha + 80, 1225)
         oPrint:Box(nLinha, 1250, nLinha + 80, 2370)

         nLinha += 10

         oPrint:Say( nLinha, 0420, "POSIÇÃO DE SAÍDA", oFontC2 , 1400, CLR_BLACK )
         oPrint:Say( nLinha, 1700, "LAYOUT"          , oFontC2 , 1400, CLR_BLACK )

         nLinha += 70

         // ###################################
         // Box da Posição de Saída e Layout ##
         // ###################################
         oPrint:Box(nLinha, 0020, nLinha + 0525, 1225)
         oPrint:Box(nLinha, 1250, nLinha + 0730, 2370)

         // ############################
         // Imprime o sentido do rolo ##
         // ############################
	     cImagem := "RoloM" + Upper(Alltrim(Posicione("SB1", 1, xFilial("SB1") + SC2->C2_PRODUTO,"B1_ROLO")) + ".bmp")
  	     oPrint:SayBitmap(nLinha + 003, 0300, cImagem, 450, 500 )                                                                     

         // ###############################
         // Imprime o layout da etiqueta ##
         // ###############################
         If File("\imgetq\" + Alltrim(cCodProduto) + ".bmp")
            kImgEtq := "\imgetq\" + Alltrim(cCodProduto) + ".bmp"
     	    oPrint:SayBitmap(nLinha + 010, 1280, kImgEtq, 1075,700)            
    	 Endif   

         // #############
         // EMABALAGEM ##
         // #############
         nLinha += 500

         oPrint:Say( nLinha + 25, 0500, "EMBALAGEM", oFontC2 , 1400, CLR_BLACK )
         oPrint:Box(nLinha, 0020, nLinha + 100, 1225)

         nLinha += 100

         oPrint:Box(nLinha, 0020, nLinha + 130, 1225)

         nLinha += 10
   
         // ##############################################################
         // Calcula a quantidade de volumes para impressão da Embalagem ##
         // ##############################################################

         // #################################################################################################
         // Carrega a string com os códigos dos produtos a serem enviados ao Web Service do SimFrete do SM ##
         // #################################################################################################
         kSeqProduto := Alltrim(cCodProduto) + "|"

         // #####################################################################################################
         // Carrega a string com as quantidades dos produtos a serem enviados ao Web Service do SimFrete do SM ##
         // #####################################################################################################
         kSeqQuantidade := Alltrim(Str(cQtdProduto)) + "|"

         // ######################################
         // Calcula o volume total dos produtos ##
         // ######################################
         nVolumeIndiv := 0
         nVolumeTotal := 0

         If POSICIONE("SB1",1,XFILIAL("SB1") + cCodProduto, "B1_EMBA")$("1#2#3#4#5#6#7")
            If POSICIONE("SB1",1,XFILIAL("SB1") + cCodProduto, "B1_ZVIN") == "N"
               nVolumeIndiv := U_AUTOM630(POSICIONE("SB1",1,XFILIAL("SB1") + cCodProduto, "B1_EMBA"),;
                                          POSICIONE("SB1",1,XFILIAL("SB1") + cCodProduto, "B1_ALTU"),;
                                          POSICIONE("SB1",1,XFILIAL("SB1") + cCodProduto, "B1_LARG"),;
                                          POSICIONE("SB1",1,XFILIAL("SB1") + cCodProduto, "B1_COMP"),;
                                          POSICIONE("SB1",1,XFILIAL("SB1") + cCodProduto, "B1_ZBAS"),;
                                          POSICIONE("SB1",1,XFILIAL("SB1") + cCodProduto, "B1_RAIO"),;
                                          POSICIONE("SB1",1,XFILIAL("SB1") + cCodProduto, "B1_LADO"),;
                                          cQtdProduto)
            Else                                                     
               nQtdIndiv    := 1
               nVolumeTotal := U_AUTOM630(POSICIONE("SB1",1,XFILIAL("SB1") + aCols[xContar,xPosProd], "B1_EMBA"),;
                                          POSICIONE("SB1",1,XFILIAL("SB1") + aCols[xContar,xPosProd], "B1_ALTU"),;
                                          POSICIONE("SB1",1,XFILIAL("SB1") + aCols[xContar,xPosProd], "B1_LARG"),;
                                          POSICIONE("SB1",1,XFILIAL("SB1") + aCols[xContar,xPosProd], "B1_COMP"),;
                                          POSICIONE("SB1",1,XFILIAL("SB1") + aCols[xContar,xPosProd], "B1_ZBAS"),;
                                          POSICIONE("SB1",1,XFILIAL("SB1") + aCols[xContar,xPosProd], "B1_RAIO"),;
                                          POSICIONE("SB1",1,XFILIAL("SB1") + aCols[xContar,xPosProd], "B1_LADO"),;
                                          cQtdProduto)
            Endif                                                    
         Endif   

         // ################################################################################################
         // Elimina o último | da string dos códigos das strings de consumo do web service do SimFrete SM ##
         // ################################################################################################
         kSeqProduto    := Substr(kSeqProduto   , 01, Len(Alltrim(kSeqProduto)) - 1)
         kSeqQuantidade := Substr(kSeqQuantidade, 01, Len(Alltrim(kSeqQuantidade)) - 1)

         // ##################################
         // Calcula a quantidade de volumes ##
         // ##################################
         nQtdCaixas    := 0
         nQtdVolumes   := 0
         nEmbalar      := nVolumeIndiv + nVolumeTotal    
         kUltimaEmba   := .F.
         cGravaVol     := ""

         While nEmbalar <> 0   

            For xContar = 1 to Len(aEmbalagem)
  
                If nEmbalar <= aEmbalagem[xContar,03]

                   nQtdVolumes := nQtdVolumes + 1
                   cGravaVol   := cGravaVol + "1 " + Alltrim(aEmbalagem[xContar,02]) + " - "

                   nEmbalar := nEmbalar - aEmbalagem[xContar,03]

                   If nEmbalar < 0
                      nEmbalar := 0
                   Endif   
                                     
                   Exit
                            
                Else
          
                   If xContar == Len(aEmbalagem)
                      nQtdVolumes := nQtdVolumes + 1
                      cGravaVol   := cGravaVol + "1 " + Alltrim(aEmbalagem[xContar,02]) + " - "
                      nEmbalar    := (aEmbalagem[xContar,03] - nEmbalar) * -1
                   Endif   
          
                Endif      

            Next xContar

         Enddo

         // #######################################################
         // Junta as Quantidades de Volumes + os Volumes Cúbicos ##
         // #######################################################
         nQtdVolumes  := nQtdVolumes  &&  + nQtdIndiv
         nVolumeTotal := nVolumeTotal + nVolumeIndiv
         nVolTotal    := ""
         nVolumeTotal := nQtdVolumes * nVolumeTotal

         oPrint:Say( nLinha, 035, cGravaVol, oFontC2 , 1400, CLR_BLACK )
         nLinha += 75
         //oPrint:Say( nLinha, 035, "20 UNIDADES POR CAIXA", oFontC , 1400, CLR_BLACK )

         nLinha += 70

         // ###########################################
         // OBSERVAÇÕES INTERNAAS DO PEDIDO DE VENDA ##
         // ###########################################
         oPrint:Box(nLinha, 0020, nLinha + 80, 2370)

         nLinha += 10
          
         oPrint:Say( nLinha, 0778, "OBSERVAÇÕES INTERNAS DO PEDIDO", oFontC2 , 1400, CLR_BLACK )
          
         nLinha += 70

         If Select("T_INTERNAS") > 0
            T_INTERNAS->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT CAST(CAST (C5_OBSI AS VARBINARY (1000)) AS VARCHAR (1000)) INTERNAS"
         cSql += "  FROM " + RetSqlName("SC5")
         cSql += " WHERE C5_FILIAL  = '" + Alltrim(cFilAnt)  + "'"
         cSql += "   AND C5_NUM     = '" + Alltrim(cCodPedi) + "'"
         cSql += "   AND D_E_L_E_T_ = ''"
        
         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_INTERNAS", .T., .T. )

         If T_INTERNAS->( EOF() )
            cInternas := ""
         Else
            cInternas := T_INTERNAS->INTERNAS
         Endif      

         cObs01 := "" 
         cObs02 := ""
         cObs03 := ""
         cObs04 := ""
         cObs05 := ""
         cObs06 := ""
         cObs07 := ""
         cObs08 := ""
         cObs09 := ""
         cObs10 := ""                                                                                                         

         If Empty(Alltrim(cInternas))
         Else
         
            cInternas := cInternas + chr(13)

            For kNotas = 1 to U_P_OCCURS(cInternas, CHR(13), 1) 
                Do Case
                   Case kNotas == 1
                        cObs01 := U_P_CORTA(cInternas, CHR(13), knotas)
                   Case kNotas == 2
                        cObs02 := U_P_CORTA(cInternas, CHR(13), knotas)
                   Case kNotas == 3
                        cObs03 := U_P_CORTA(cInternas, CHR(13), knotas)
                   Case kNotas == 4
                        cObs04 := U_P_CORTA(cInternas, CHR(13), knotas)
                   Case kNotas == 5
                        cObs05 := U_P_CORTA(cInternas, CHR(13), knotas)
                   Case kNotas == 6
                        cObs06 := U_P_CORTA(cInternas, CHR(13), knotas)
                   Case kNotas == 7
                        cObs07 := U_P_CORTA(cInternas, CHR(13), knotas)
                   Case kNotas == 8
                        cObs08 := U_P_CORTA(cInternas, CHR(13), knotas)
                   Case kNotas == 9
                        cObs09 := U_P_CORTA(cInternas, CHR(13), knotas)
                   Case kNotas == 10
                        cObs10 := U_P_CORTA(cInternas, CHR(13), knotas)
                EndCase
            Next kNotas    
            
         Endif            

         // ##################################################
         // Box das Observações Internas do Pedido de Venda ##
         // ##################################################
         oPrint:Box(nLinha, 0020, nLinha + 270, 2370)

         // #####################################################
         // Imprime as observações internas do pedido de venda ##
         // #####################################################
         oPrint:Say( nLinha, 035, Rtrim(cObs01), oFontC2 , 1400, CLR_BLACK )
         nLinha += 50
         oPrint:Say( nLinha, 035, Rtrim(cObs02), oFontC2 , 1400, CLR_BLACK )
         nLinha += 50
         oPrint:Say( nLinha, 035, Rtrim(cObs03), oFontC2 , 1400, CLR_BLACK )
         nLinha += 50
         oPrint:Say( nLinha, 035, Rtrim(cObs04), oFontC2 , 1400, CLR_BLACK )
         nLinha += 50
         oPrint:Say( nLinha, 035, Rtrim(cObs05), oFontC2 , 1400, CLR_BLACK )
         nLinha += 50

      Endif

      DBSelectArea("SC2")
      DBSkip()

   EndDo	                
   
   Set Filter to 
   oPrint:Preview()
   oPrint:End() 

   // #################################################################
   // Atualiza o campo C2_IMPR COM 1 indicando que a OP foi impressa ##
   // #################################################################
   For nContar = 1 to Len(aImpressos)
       DbSelectArea("SC2")
       If DBSEEK(xFilial("SC2") + aImpressos[nContar])
          RecLock("SC2",.F.)
          SC2->C2_IMPR := 1
          MsUnLock()              
       Endif
   Next nContar    

   RestArea(aArea)

Return(.T.)

Static Function CheckFim()

   //If nLinha > (oPrint:nVertRes() + 150 )
   If nLinha > 3169     
      //PrintRodape()					//	[	IMPRIME RODAPE	]		
      oPrint:EndPage()

      if SQL->(EOF())
         return()
      endif

      npagina++
      PrintCabec()				//	[	IMPRIME DADOS DO CABECALHO			]
      DadosOp()					//	[	IMPRIME DADOS DA ORDEM DE PRODUCAO	]
      DadosCli()     
      nLinha := 900
      oPrint:Box(nLinha, 020, nLinha+80, 2370)
      BoxRot()                                                      
      nLinha := 750
      nLinCB := 7.0
   EndIf

Return()

// ######################################################
// Função que imprime o cabeçalho da Ordem de Produção ##
// ######################################################
Static Function PrintCabec()

   oPrint:StartPage()

   // ####################################################################
   // Prepara as variáveis para impressão dos dados a ordem de produção ##
   // ####################################################################
   cCliente	 :=	Space(TamSx3('A2_COD')[01])
   cPedido 	 :=	Space(TamSx3('C2_PEDIDO')[01])
   cEmissao  :=	Space(TamSx3('C5_EMISSAO')[01])
   cVendedor := Space(TamSx3('C5_VEND1')[01])
   cTransp	 := Space(TamSx3('C5_TRANSP')[01])
   cFone 	 := Space(TamSx3('A1_TEL')[01])
   cDDD	 	 := Space(TamSx3('A4_DDD')[01])
   cEmailT	 :=	Space(TamSx3('A4_EMAIL')[01])
   cEmailC	 :=	Space(TamSx3('A1_EMAIL')[01])
   cEmail 	 :=	Space(TamSx3('A1_EMAIL')[01])
   cCidade	 := space(TamSx3('A1_MUN'  )[01])

   If !Empty(SC2->C2_PEDIDO)
      DbSelectArea('SC5');DbSetOrder(1);DbGoTop()
	  If DbSeek(xFilial('SC5') + SC2->C2_PEDIDO, .F.)
		 cCliente	:=	AllTrim(SC5->C5_CLIENTE)+' - '+AllTrim(SC5->C5_LOJACLI)
		 cCliente	+=	AllTrim(Posicione('SA1', 1, xFilial('SA1')+SC5->C5_CLIENTE+SC5->C5_LOJACLI,'A1_NOME')) 
		 cCidade	    :=  AllTrim(Posicione('SA1', 1, xFilial('SA1')+SC5->C5_CLIENTE+SC5->C5_LOJACLI,'A1_MUN'))
		 cPedido 	:=	AllTrim(SC2->C2_PEDIDO )+' - '+AllTrim(SC2->C2_ITEMPV)
		 cEmissao 	:=	DtoC(SC5->C5_EMISSAO)
		 cVendedor	:=	AllTrim(SC5->C5_VEND1)
		 cVendedor	+=	IIF(!Empty(SC5->C5_VEND1), +' - '+left(AllTrim(Posicione('SA3', 1, xFilial('SA3')+SC5->C5_VEND1,'A3_NOME')),18), '')
		 cTransp		:=	AllTrim(SC5->C5_TRANSP)
		 cTransp		+=	IIF(!Empty(SC5->C5_TRANSP), +' - '+AllTrim(Posicione('SA4', 1, xFilial('SA4')+SC5->C5_TRANSP,'A4_NOME')), '')		
		 cDDD		:=	AllTrim(Posicione('SA4', 1, xFilial('SA4')+SC5->C5_TRANSP,'A4_DDD')) 	
		 cFone		:=	AllTrim(Posicione('SA4', 1, xFilial('SA4')+SC5->C5_TRANSP,'A4_TEL')) 	
		 cEmailT		:=	AllTrim(Posicione('SA4', 1, xFilial('SA4')+SC5->C5_TRANSP,'A4_EMAIL'))
		 aEmail		:=	StrTokArr (cEmail, ';')
		 cEmail		:=	''
		 For nX := 1 To Len(aEmail)
			 cEmail	+=	aEmail[nX]+ENTER
		 Next
		 If Empty(cEmailC)
			cEmailC	:=	AllTrim(Posicione('SA1', 1, xFilial('SA1')+SC5->C5_CLIENTE+SC5->C5_LOJACLI,'A1_EMAIL'))
		 EndIf		
	  EndIf
   EndIf



   // ############################
   // De cima para baixo: Box 1 ##
   // ############################
   oPrint:Box(nLinha, 020, nLinha + 180, 2370)
   
   nLinha += 15

   // ####################################
   // Imprime a logomarca da Automatech ##
   // ####################################
   oPrint:SayBitmap( nLinha, 030, "xlogoautoma.bmp", nLinha + 400,150) &&    210, 080 )

   nLinha += 50

   oPrint:Say( nLinha, 0850,  PADR("AUTOMATECH - Empresa: " + Upper(Alltrim(SM0->M0_NOME)) + " / Filial: " +  Alltrim(SM0->M0_FILIAL),100), oFontC1, 1400, CLR_BLACK )

   nLinha += 130

   // ############################
   // De cima para baixo: Box 2 ##
   // ############################
   oPrint:Box(nLinha, 020, nLinha + 135, 2370)

   nLinha += 25

   oPrint:Say( nLinha, 0035, 'CLIENTE: '  + "NOME DO CLIENTE"  , oFontC, 1400, CLR_BLACK )
   oPrint:Say( nLinha, 1800, 'VENDEDOR: ' + "NOME DO VENDEDOR" , oFontC, 1400, CLR_BLACK )

   nLinha += 50

   oPrint:Say( nLinha, 0035, "TRANSP.: " + "NOME DA TRANSPORTADORA", oFontC, 1400, CLR_BLACK )
   oPrint:Say( nLinha, 1800, "CIDADE: "  + "NOME DA CIDADE - RS"   , oFontC, 1400, CLR_BLACK )

   nLinha += 85

   // ############################
   // De cima para baixo: Box 3 ##
   // ############################
   oPrint:Box(nLinha, 020, nLinha + 250, 2370)

   nLinha += 25

   // ##################################################
   // Imprime o código de barras da Ordem de Produção ##
   // ##################################################
// cCodBarInic  := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN) + SQL->G2_OPERAC + "01"
   cCodBarInic  := "004818020010101"
   MsBar3("CODE128",nLinha + 15,1400,cCodBarInic,oPrint,.F.,,.T.,0.025,1.0,.F.,,,.F.) 

   oPrint:Say( nLinha + 15, 0035, "OP: "          , oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0150     , "004818.02.001" , oFontC2, 1400, CLR_BLACK )

   nLinha += 80

   oPrint:Say( nLinha + 17 , 0035, "PEDIDO: "      , oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0150      , "007550 - 03"   , oFontC2, 1400, CLR_BLACK )

   nLinha += 80

   oPrint:Say( nLinha, 0035, "EMISSÃO OP: 18/12/2017 / HORA: 15:10:19 / EMISSÃO PV: 15/12/2017"      , oFontC , 1400, CLR_BLACK )

   nLinha += 85

   // ############################
   // De cima para baixo: Box 4 ##
   // ############################
   oPrint:Box(nLinha, 020, nLinha + 165, 2370)

   nLinha += 25

   oPrint:Say( nLinha, 0035, "PRODUTO: 03035827620000001 - ET 50X25X02 EP S2045/105 1.BRANCO", oFontC , 1400, CLR_BLACK )

   nLinha += 60

   oPrint:Say( nLinha + 15, 0035, "QTD: "    , oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0150     , "40 ROLOS" , oFontC2, 1400, CLR_BLACK )

   oPrint:Say( nLinha + 15, 1500, "ENTREGA: "  , oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 1650     , "28/02/2018" , oFontC2, 1400, CLR_BLACK )

   nLinha += 95
   
   // ############################
   // De cima para baixo: Box 5 ##
   // ############################
   oPrint:Box(nLinha, 020, nLinha + 80, 2370)

   nLinha += 05

   oPrint:Say( nLinha, 1150, "COMPONENTES", oFontC2 , 1400, CLR_BLACK )

   nLinha += 74
   
   // ############################
   // De cima para baixo: Box 5 ##
   // ############################
   oPrint:Box(nLinha, 020, nLinha + 80, 2370)

   oPrint:Box(nLinha, 020, nLinha + 193, 0160)
   oPrint:Box(nLinha, 020, nLinha + 193, 1700)
   oPrint:Box(nLinha, 020, nLinha + 193, 2000)

   nLinha += 20

   oPrint:Say( nLinha, 0035, "CÓDIGO"      , oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0170, "DESCRIÇÃO"   , oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 1800, "M2"          , oFontC , 1400, CLR_BLACK )   
   oPrint:Say( nLinha, 2150, "MTS LINEARES", oFontC , 1400, CLR_BLACK )   

   nLinha += 61
   
   // ############################
   // De cima para baixo: Box 6 ##
   // ############################
   oPrint:Box(nLinha, 020, nLinha + 110, 2370)

   nLinha += 20

   oPrint:Say( nLinha, 0040, "007582"                    , oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0175, "PAP FAS ECOPRINT S2045/105", oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 1805, "166,32"                    , oFontC , 1400, CLR_BLACK )   
   oPrint:Say( nLinha, 2155, "1.584"                     , oFontC , 1400, CLR_BLACK )   

   nLinha += 50

   oPrint:Say( nLinha, 0040, "007582"                    , oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0175, "PAP FAS ECOPRINT S2045/105", oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 1805, "166,32"                    , oFontC , 1400, CLR_BLACK )   
   oPrint:Say( nLinha, 2155, "1.584"                     , oFontC , 1400, CLR_BLACK )   

   nLinha += 61

   // ############################
   // De cima para baixo: Box 7 ##
   // ############################
   oPrint:Box(nLinha, 020, nLinha + 80, 2370)

   nLinha += 07

   oPrint:Say( nLinha, 1100, "CARACTERÍSTICAS", oFontC2 , 1400, CLR_BLACK )

   nLinha += 75
   
   // ############################
   // De cima para baixo: Box 8 ##
   // ############################
   oPrint:Box(nLinha, 020, nLinha + 80, 2370)

   oPrint:Box(nLinha, 020, nLinha + 170, 0190)
   oPrint:Box(nLinha, 020, nLinha + 170, 0395)
   oPrint:Box(nLinha, 020, nLinha + 170, 1495)
   oPrint:Box(nLinha, 020, nLinha + 170, 1695)
   oPrint:Box(nLinha, 020, nLinha + 170, 1945)

   nLinha += 22

   oPrint:Say( nLinha, 0035, "FACA"           , oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0200, "CÓDIGO"         , oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0400, "SUBSTRATO"      , oFontC , 1400, CLR_BLACK )   
   oPrint:Say( nLinha, 1500, "TUBETE"         , oFontC , 1400, CLR_BLACK )   
   oPrint:Say( nLinha, 1700, "SER."           , oFontC , 1400, CLR_BLACK )   
   oPrint:Say( nLinha, 1950, "CARACTERÍSTICA" , oFontC , 1400, CLR_BLACK )   

   nLinha += 58
   
   // ############################
   // De cima para baixo: Box 9 ##
   // ############################
   oPrint:Box(nLinha, 020, nLinha + 90, 2370)

   nLinha += 22

   oPrint:Say( nLinha, 0040, "150X250X02"         , oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0205, "0358"               , oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0405, "BOPP PEROL DFAM/105", oFontC , 1400, CLR_BLACK )   
   oPrint:Say( nLinha, 1505, "1"                  , oFontC , 1400, CLR_BLACK )   
   oPrint:Say( nLinha, 1705, "."                  , oFontC , 1400, CLR_BLACK )   
   oPrint:Say( nLinha, 1955, "BRANCO"             , oFontC , 1400, CLR_BLACK )   

   nLinha += 79

   // #########################################
   // De cima para baixo: Box 10 - IMPRESSÃO ##
   // #########################################
   oPrint:Box(nLinha, 0020, nLinha + 80, 1225)
   oPrint:Box(nLinha, 1250, nLinha + 80, 2370)

   nLinha += 10

   oPrint:Say( nLinha, 0500, "IMPRESSÃO", oFontC2 , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 1800, "MÁQUINA"  , oFontC2 , 1400, CLR_BLACK )

   nLinha += 72

   oPrint:Box(nLinha, 020, nLinha + 450, 0190)
   oPrint:Box(nLinha, 020, nLinha + 450, 0395)
   oPrint:Box(nLinha, 020, nLinha + 450, 0640)  
   oPrint:Box(nLinha, 020, nLinha + 450, 1225)  
   
   oPrint:Box(nLinha, 1250, nLinha + 450, 1495)
   oPrint:Box(nLinha, 1250, nLinha + 450, 2370)

   // ################################
   // Box da Impressão e da Máquina ##
   // ################################
   oPrint:Box(nLinha, 0020, nLinha + 50, 1225)
   oPrint:Box(nLinha, 1250, nLinha + 50, 2370)

   nLinha += 10

   oPrint:Say( nLinha, 0035, "ESTÁGIO"  , oFont10N , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0200, "PANTONE"  , oFont10N , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0400, "ANILOX"   , oFont10N , 1400, CLR_BLACK )   
   oPrint:Say( nLinha, 0650, "BORRACHA" , oFont10N , 1400, CLR_BLACK )   

   oPrint:Say( nLinha, 1280, "CÓDIGO"   , oFont10N , 1400, CLR_BLACK )   
   oPrint:Say( nLinha, 1500, "MÁQUINA"	, oFont10N , 1400, CLR_BLACK )   

   nLinha += 50
   
   oPrint:Say( nLinha, 0040, "001"       , oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0205, "P350 VERDE", oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0405, "54 BCN"    , oFontC , 1400, CLR_BLACK )   
   oPrint:Say( nLinha, 0655, "MACIA"     , oFontC , 1400, CLR_BLACK )   

   oPrint:Say( nLinha, 1305, "000001"       , oFontC , 1400, CLR_BLACK )   
   oPrint:Say( nLinha, 1505, "REINAFLEX 160", oFontC , 1400, CLR_BLACK )   

   nLinha += 50

   oPrint:Say( nLinha, 0040, "002"        , oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0205, "P350 VERDE" , oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0405, "54 BCN"     , oFontC , 1400, CLR_BLACK )   
   oPrint:Say( nLinha, 0655, "MACIA"      , oFontC , 1400, CLR_BLACK )   

   oPrint:Say( nLinha, 1305, "000002"     , oFontC , 1400, CLR_BLACK )   
   oPrint:Say( nLinha, 1505, "MAQFLEX 160", oFontC , 1400, CLR_BLACK )   

   nLinha += 50

   oPrint:Say( nLinha, 0040, "003"       , oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0205, "P350 VERDE", oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0405, "54 BCN"    , oFontC , 1400, CLR_BLACK )   
   oPrint:Say( nLinha, 0655, "MACIA"     , oFontC , 1400, CLR_BLACK )   

   nLinha += 50

   oPrint:Say( nLinha, 0040, "004"       , oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0205, "P350 VERDE", oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0405, "54 BCN"    , oFontC , 1400, CLR_BLACK )   
   oPrint:Say( nLinha, 0655, "MACIA"     , oFontC , 1400, CLR_BLACK )   

   nLinha += 50

   oPrint:Say( nLinha, 0040, "005"       , oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0205, "P350 VERDE", oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0405, "54 BCN"    , oFontC , 1400, CLR_BLACK )   
   oPrint:Say( nLinha, 0655, "MACIA"     , oFontC , 1400, CLR_BLACK )   

   nLinha += 50

   oPrint:Say( nLinha, 0040, "006"       , oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0205, "P350 VERDE", oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0405, "54 BCN"    , oFontC , 1400, CLR_BLACK )   
   oPrint:Say( nLinha, 0655, "MACIA"     , oFontC , 1400, CLR_BLACK )   

   nLinha += 50

   oPrint:Say( nLinha, 0040, "007"       , oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0205, "P350 VERDE", oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0405, "54 BCN"    , oFontC , 1400, CLR_BLACK )   
   oPrint:Say( nLinha, 0655, "MACIA"     , oFontC , 1400, CLR_BLACK )   

   nLinha += 50

   oPrint:Say( nLinha, 0040, "008"       , oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0205, "P350 VERDE", oFontC , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0405, "54 BCN"    , oFontC , 1400, CLR_BLACK )   
   oPrint:Say( nLinha, 0655, "MACIA"     , oFontC , 1400, CLR_BLACK )   

   nLinha += 61

   // ########################################
   // De cima para baixo: Box 11 - PRODUÇÃO ##
   // ########################################
   oPrint:Box(nLinha, 020, nLinha + 80, 2370)

   nLinha += 10

   oPrint:Say( nLinha, 1100, "PRODUÇÃO", oFontC2 , 1400, CLR_BLACK )

   nLinha += 72

   oPrint:Box(nLinha, 020, nLinha + 050, 0595)
   oPrint:Box(nLinha, 020, nLinha + 050, 1295)
   oPrint:Box(nLinha, 020, nLinha + 050, 1940)  
   oPrint:Box(nLinha, 020, nLinha + 050, 2370)  

   nLinha += 10

   oPrint:Say( nLinha, 0035, "GRAMATURA"        , oFont10N , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0750, "METRO LINEAR ROLO", oFont10N , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 1500, "ETQ/ROLO"         , oFont10N , 1400, CLR_BLACK )   
   oPrint:Say( nLinha, 2100, "ROLOS"            , oFont10N , 1400, CLR_BLACK )   

   nLinha += 40

   oPrint:Say( nLinha, 0040, "ROLO ADESIVO", oFontC2 , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0900, "36"          , oFontC2 , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 1500, "10.285"      , oFontC2 , 1400, CLR_BLACK )   
   oPrint:Say( nLinha, 2150, "40"          , oFontC2 , 1400, CLR_BLACK )   

   oPrint:Box(nLinha, 020, nLinha + 065, 0595)
   oPrint:Box(nLinha, 020, nLinha + 065, 1295)
   oPrint:Box(nLinha, 020, nLinha + 065, 1940)
   oPrint:Box(nLinha, 020, nLinha + 065, 2370)  

   nLinha += 79

   // ################################################
   // De cima para baixo: Box 12 - POSIÇÃO DE SAÍDA ##
   // ################################################
   oPrint:Box(nLinha, 0020, nLinha + 80, 1225)
   oPrint:Box(nLinha, 1250, nLinha + 80, 2370)

   nLinha += 10

   oPrint:Say( nLinha, 0450, "POSIÇÃO DE SAÍDA", oFontC2 , 1400, CLR_BLACK )
   oPrint:Say( nLinha, 1750, "LAYOUT"          , oFontC2 , 1400, CLR_BLACK )

   nLinha += 70

   // ###################################
   // Box da Posição de Saída e Layout ##
   // ###################################
   oPrint:Box(nLinha, 0020, nLinha + 0800, 1225)
   oPrint:Box(nLinha, 1250, nLinha + 1500, 2370)

   // #############
   // EMABALAGEM ##
   // #############
   nLinha += 845

   oPrint:Say( nLinha + 25, 0500, "EMBALAGEM", oFontC2 , 1400, CLR_BLACK )
   oPrint:Box(nLinha, 0020, nLinha + 100, 1225)

   nLinha += 100

   oPrint:Box(nLinha, 0020, nLinha + 130, 1225)

   nLinha += 10
   
   oPrint:Say( nLinha, 035, "CAIXA 12", oFontC2 , 1400, CLR_BLACK )
   nLinha += 75
   oPrint:Say( nLinha, 035, "20 UNIDADES POR CAIXA", oFontC , 1400, CLR_BLACK )

   nLinha += 70

   // ###########################################
   // OBSERVAÇÕES INTERNAAS DO PEDIDO DE VENDA ##
   // ###########################################
   oPrint:Box(nLinha, 0020, nLinha + 80, 1225)

   nLinha += 10

   oPrint:Say( nLinha, 0350, "OBS. INTERNAS DO PEDIDO", oFontC2 , 1400, CLR_BLACK )

   nLinha += 70
   
   oPrint:Box(nLinha, 0020, nLinha + 320, 1225)

//   nLinha += 100

//   oPrint:Box(nLinha, 0020, nLinha + 130, 1225)

//   oPrint:Say( nLinha, 035, "CAIXA 12", oFontC2 , 1400, CLR_BLACK )
//   nLinha += 75
//   oPrint:Say( nLinha, 035, "20 UNIDADES POR CAIXA", oFontC , 1400, CLR_BLACK )
   
   
   
   
   
   
   
   
                                      

//
//   nLinha+=40
//   oPrint:Say( nLinha, 035,  'AUTR314' , oFontC, 1400, CLR_BLACK )
//   //oPrint:Say( 180, 2100, 'DT.Ref.:  '+DtoC(Date()) , oFontC, 1400, CLR_BLACK )
//   //oPrint:Say( 180, 2060, 'DT.Ref.:  '+DtoC(Date()) , oFontC, 1400, CLR_BLACK )
//
//   nLinha+=60
//   oPrint:Say( nLinha, 035,  'Hora...:  '+Time() +'  -  Empresa: '+AllTrim(SM0->M0_NOME)+' / Filial: '+AllTrim(SM0->M0_FILIAL) , oFontC, 1400, CLR_BLACK )
//   oPrint:Say( nLinha, 2000, 'Emissao OP: '+DtoC(dDataBase) , oFontC, 1400, CLR_BLACK )
//
//   nLinha+=70
//
//   IF "EXATA" $ SC2->C2_OBS
//      oPrint:Say( nLinha, 0800, 'QUANTIDADE EXATA', oFontC2, 1400, CLR_BLACK )
//   ENDIF
//

Return()

Static Function DadosOp()

   nLinha+=100
   oPrint:Box(nlinha, 020, nlinha+205, 2370)                                      
   nLinha+=25
   oPrint:Say( nLinha, 0035, 'PEDIDO:  '+ AllTrim(SC2->C2_PEDIDO )+' - '+AllTrim(SC2->C2_ITEMPV), oFontC1, 1400, CLR_BLACK )
   oPrint:Say( nLinha, 0800, 'ORDEM DE PRODUÇÃO  ', oFontC1, 1400, CLR_BLACK )
   oPrint:Say( nLinha, 1410, ' N°   '+SC2->C2_NUM+'.'+SC2->C2_ITEM+'.'+SC2->C2_SEQUEN, oFontC1, 1400, CLR_BLACK )
   nLinha+=60

   oPrint:Say( nLinha, 035, 'QTD.: '+Transform(SC2->C2_QUANT, PesqPict("SC2","C2_QUANT", TamSx3('C2_QUANT')[1]))	;
			+' '+AllTrim(Posicione('SAH', 1, xFilial('SAH')+SC2->C2_UM,'AH_UMRES')) ;
			+'    PRV.ENTREGA:'+DtoC(SC2->C2_DATPRF);
			, oFontC1, 1400, CLR_BLACK )

//   oPrint:Say( nLinha, 035, 'QTD.: '+Transform(SC2->C2_ZQTD, PesqPict("SC2","C2_ZQTD", TamSx3('C2_ZQTD')[1]))	;
//			+' '+AllTrim(Posicione('SAH', 1, xFilial('SAH')+SC2->C2_UM,'AH_UMRES')) ;
//			+'    PRV.ENTREGA:'+DtoC(SC2->C2_DATPRF);
//			, oFontC1, 1400, CLR_BLACK )

   //oPrint:Say( nLinha, 780, 'UM: '+AllTrim(Posicione('SAH', 1, xFilial('SAH')+SC2->C2_UM,'AH_UMRES')), oFontC, 1400, CLR_BLACK )
   //oPrint:Say( nLinha, 1200, 'PRV. ENTREGA: '+DtoC(SC2->C2_DATPRF), oFontC, 1400, CLR_BLACK )
   nLinha+=70
   oPrint:Say( nLinha, 035,  'PRODUTO:  '+AllTrim(SC2->C2_PRODUTO) +' - '+AllTrim(Posicione('SB1', 1, xFilial('SB1')+SC2->C2_PRODUTO,'B1_DESC'));
															    +' '+AllTrim(Posicione('SB1', 1, xFilial('SB1')+SC2->C2_PRODUTO,'B1_DAUX')), oFontC1, 1400, CLR_BLACK )

   MsBar3("CODE128",05,16,SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,oPrint,.F.,,.T.,0.030,1.0,.F.,,,.F.) 

Return()

Static Function DadosCli()

   Local cCliente	:=	Space(TamSx3('A2_COD')[01])
   Local cPedido 	:=	Space(TamSx3('C2_PEDIDO')[01])
   Local cEmissao 	:=	Space(TamSx3('C5_EMISSAO')[01])
   Local cVendedor  := 	Space(TamSx3('C5_VEND1')[01])
   Local cTransp	:= 	Space(TamSx3('C5_TRANSP')[01])
   Local cFone 	    := 	Space(TamSx3('A1_TEL')[01])
   Local cDDD	 	:= 	Space(TamSx3('A4_DDD')[01])
   Local cEmailT	:=	Space(TamSx3('A4_EMAIL')[01])
   Local cEmailC	:=	Space(TamSx3('A1_EMAIL')[01])
   Local cEmail 	:=	Space(TamSx3('A1_EMAIL')[01])
   Local cCidade	:=  space(TamSx3('A1_MUN'  )[01])

   If !Empty(SC2->C2_PEDIDO)
      DbSelectArea('SC5');DbSetOrder(1);DbGoTop()
	  If DbSeek(xFilial('SC5') + SC2->C2_PEDIDO, .F.)
		 cCliente	:=	AllTrim(SC5->C5_CLIENTE)+' - '+AllTrim(SC5->C5_LOJACLI)
		 cCliente	+=	AllTrim(Posicione('SA1', 1, xFilial('SA1')+SC5->C5_CLIENTE+SC5->C5_LOJACLI,'A1_NOME')) 
		 cCidade	    :=  AllTrim(Posicione('SA1', 1, xFilial('SA1')+SC5->C5_CLIENTE+SC5->C5_LOJACLI,'A1_MUN'))
		 cPedido 	:=	AllTrim(SC2->C2_PEDIDO )+' - '+AllTrim(SC2->C2_ITEMPV)
		 cEmissao 	:=	DtoC(SC5->C5_EMISSAO)
		 cVendedor	:=	AllTrim(SC5->C5_VEND1)
		 cVendedor	+=	IIF(!Empty(SC5->C5_VEND1), +' - '+left(AllTrim(Posicione('SA3', 1, xFilial('SA3')+SC5->C5_VEND1,'A3_NOME')),18), '')
		 cTransp		:=	AllTrim(SC5->C5_TRANSP)
		 cTransp		+=	IIF(!Empty(SC5->C5_TRANSP), +' - '+AllTrim(Posicione('SA4', 1, xFilial('SA4')+SC5->C5_TRANSP,'A4_NOME')), '')		
		 cDDD		:=	AllTrim(Posicione('SA4', 1, xFilial('SA4')+SC5->C5_TRANSP,'A4_DDD')) 	
		 cFone		:=	AllTrim(Posicione('SA4', 1, xFilial('SA4')+SC5->C5_TRANSP,'A4_TEL')) 	
		 cEmailT		:=	AllTrim(Posicione('SA4', 1, xFilial('SA4')+SC5->C5_TRANSP,'A4_EMAIL'))
		 aEmail		:=	StrTokArr (cEmail, ';')
		 cEmail		:=	''
		 For nX := 1 To Len(aEmail)
			 cEmail	+=	aEmail[nX]+ENTER
		 Next
		 If Empty(cEmailC)
			cEmailC	:=	AllTrim(Posicione('SA1', 1, xFilial('SA1')+SC5->C5_CLIENTE+SC5->C5_LOJACLI,'A1_EMAIL'))
		 EndIf		
	  EndIf
   EndIf

   nLinha+=100
   oPrint:Box(nLinha, 020, nLinha +150, 2370)
   nLinha+=30
   oPrint:Say( nLinha, 035,  'CLIENTE: ' +cCliente	, oFontC, 1400, CLR_BLACK )
   oPrint:Say( nLinha, 1300, 'VENDEDOR: '+cVendedor+' EMISSAO PV: '+cEmissao	, oFontC, 1400, CLR_BLACK )
   nLinha+=60
   oPrint:Say( nlinha, 035, 'TRANSP.:' +cTransp 		, oFont10, 1400, CLR_BLACK )          
   //oPrint:Say( nlinha, 1200,'FONE:('+IIF(!Empty(cDDD),cDDD,'XXX')+') '+cFone , oFont10, 1400, CLR_BLACK ) 
   oPrint:Say( nlinha, 1200,cCidade , oFont10, 1400, CLR_BLACK )
   //oPrint:Say( nLinha, 1700,'EMAIL:'+Lower(cEmailT) , oFont10, 1400, CLR_BLACK )

Return()

Static Function ProdCaract()

   Local aCaract := {}

   nLinha+=100
   //oPrint:Box(930, 020, 1010, 2510) 				//	Box ( < nRow>, < nCol>, < nBottom>, < nRight>, [ uParam5] ) --> NIL
   oPrint:Box(nLinha, 020, nLinha+80, 2370)
   nLinha+=30
   oPrint:Say(nLinha, 0900, 'CARACTERISTICAS', oFontC1, 1400, CLR_BLACK )

   nLinha+=50
   oPrint:Box(nLinha, 020, nLinha+80, 0380)
   oPrint:Box(nLinha, 020, nLinha+80, 1100)
   oPrint:Box(nLinha, 020, nLinha+80, 1300)
   oPrint:Box(nLinha, 020, nLinha+80, 1475)
   oPrint:Box(nLinha, 020, nLinha+80, 2370)
   nLinha+=30
   oPrint:Say(nLinha, 0180, 'FACA' 		 , oFontC, 1400, CLR_BLACK )
   oPrint:Say(nLinha, 0580, 'SUBSTRATO'	 , oFontC, 1400, CLR_BLACK )
   oPrint:Say(nLinha, 1130, 'TUBETE'		 , oFontC, 1400, CLR_BLACK )
   oPrint:Say(nLinha, 1300, 'SERRILHA'		 , oFontC, 1400, CLR_BLACK )
   oPrint:Say(nLinha, 1850, 'CARACTERISTICA', oFontC, 1400, CLR_BLACK )

   _cFaca 		:= U_BuscaCar(SC2->C2_PRODUTO,"FAC")
   _cPapel 	:= U_BuscaCar(SC2->C2_PRODUTO,"PAP")
   _cTubete	:= U_BuscaCar(SC2->C2_PRODUTO,"TUB")
   _cSerr		:= U_BuscaCar(SC2->C2_PRODUTO,"SER")
   _cCarac		:= U_BuscaCar(SC2->C2_PRODUTO,"CAR")
   nLinha+=50
   oPrint:Box(nLinha, 020, nLinha+80, 0380)
   oPrint:Box(nLinha, 020, nLinha+80, 1100)
   oPrint:Box(nLinha, 020, nLinha+80, 1300)
   oPrint:Box(nLinha, 020, nLinha+80, 1475)                                                                  
   oPrint:Box(nLinha, 020, nLinha+80, 2370)
   nLinha+=30
   oPrint:Say(nLinha, 0180, _cFaca   , oFontC, 1400, CLR_BLACK )
   oPrint:Say(nLinha, 0580, _cPapel  , oFontC, 1400, CLR_BLACK )
   oPrint:Say(nLinha, 1130, _cTubete , oFontC, 1400, CLR_BLACK )
   oPrint:Say(nLinha, 1320, _cSerr   , oFontC, 1400, CLR_BLACK )
   oPrint:Say(nLinha, 1500, _cCarac  , oFontC, 1400, CLR_BLACK )

Return()

Static Function BoxPantone()

   nLinha+=100
   oPrint:Box(nlinha, 020, nLinha+80, 2370)
   nLinha+=30
   oPrint:Say(nLinha, 0900, 'PANTONES', oFontC1, 1400, CLR_BLACK )

   nLinha+=50
   oPrint:Box(nLinha, 0020, nLinha+80, 0140)
   oPrint:Box(nLinha, 0140, nLinha+80, 0510)
   oPrint:Box(nLinha, 0510, nLinha+80, 0700)
   oPrint:Box(nLinha, 0700, nLinha+80, 0920)                            
   oPrint:Box(nLinha, 0920, nLinha+80, 1040)
   oPrint:Box(nLinha, 1040, nLinha+80, 1410)
   oPrint:Box(nLinha, 1410, nLinha+80, 1600)
   oPrint:Box(nLinha, 1600, nLinha+80, 1820)
   nLinha+=30
   oPrint:Say(nLinha, 0032, 'EST.'			, oFontC, 1400, CLR_BLACK )
   oPrint:Say(nLinha, 0220, 'PANTONE'		, oFontC, 1400, CLR_BLACK )
   oPrint:Say(nLinha, 0550, 'ANILOX'		, oFontC, 1400, CLR_BLACK )
   oPrint:Say(nLinha, 0720, 'BORRACHA'		, oFontC, 1400, CLR_BLACK )
   oPrint:Say(nLinha, 0930, 'EST.'			, oFontC, 1400, CLR_BLACK )
   oPrint:Say(nLinha, 1050, 'PANTONE'		, oFontC, 1400, CLR_BLACK )
   oPrint:Say(nLinha, 1420, 'ANILOX'		, oFontC, 1400, CLR_BLACK )
   oPrint:Say(nLinha, 1620, 'BORRACHA'		, oFontC, 1400, CLR_BLACK )

Return()                                 

Static Function DadosPan()

   Local cBorracha := ""
   
   aPanF := {}     
   aPanV := {}

   // ###################################
   // BUSCA DADOS REFERENTE AO PANTONE ##
   // ###################################
   IIF(Select('SQL')!= 0, SQL->(DbCLoseArea()), )

      cQuery 	:= " SELECT * 	"+ENTER
      cQuery 	+= " FROM   "+RetSqlName('ZP3')+ " ZP3 "				+ENTER
      cQuery 	+= " WHERE	ZP3.ZP3_FILIAL	 =	'"+xFilial('ZP3')+"'"	+ENTER
      cQuery 	+= " AND	ZP3.ZP3_COD		 =	'"+SC2->C2_PRODUTO+"'"	+ENTER
      cQuery 	+= " AND	ZP3.D_E_L_E_T_ 	!= '*' "				   	+ENTER
      cQuery 	+= " ORDER BY ZP3.ZP3_ESTAG	"						   	+ENTER

      // MemoWrit(GetTempPath()+'RELOP_DADOS_PAN.TXT', cQuery )
      DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SQL', .F., .T.)

      // ###########################
      // Crio os Arrays completos ##
      // ###########################
      
      DbSelectArea("SX5")
      DbSetOrder(1)
      DbSeek(xFilial("SX5")+'Z4')
      Do While SX5->(X5_FILIAL+ X5_TABELA) == xFilial("SX5")+'Z4'
         IF LEFT(SX5->X5_CHAVE,1) = "F"
            Aadd(aPanF, { SX5->X5_CHAVE, '', '', '' })
         ElseIf LEFT(SX5->X5_CHAVE,1) = "V"
            Aadd(aPanV, { SX5->X5_CHAVE, '', '', '' })   
         ENDIF                                         
         SX5->(DbSkip())
      Enddo

      DbSelectArea('SQL');DbGoTop()

      Do While !Eof()      
		
	     If SQL->ZP3_BORR == '1' 
		    cBorracha	:= 'Macia'
	     ElseIf SQL->ZP3_BORR == '2'
		    cBorracha	:= 	'Media'
	     ElseIf SQL->ZP3_BORR == '3'
		    cBorracha	:= 	'Dura'
  	     EndIf
	
	     If Left(SQL->ZP3_ESTAG,01) == 'F'
		    nPos := ascan(aPanF, { | aVal | alltrim(aVal[1] ) == Alltrim(SQL->ZP3_ESTAG) } )
		    If nPos > 0
		       aPanF[nPos,2] := SQL->ZP3_PANTON
		       aPanF[nPos,3] := SQL->ZP3_ANILOX
		       aPanF[nPos,4] := cBorracha
		    Endif
         Else
		    nPos := ascan(aPanV, { | aVal | alltrim(aVal[1] ) == Alltrim(SQL->ZP3_ESTAG) } )		
		    If nPos > 0
		       aPanV[nPos,2] := SQL->ZP3_PANTON
		       aPanV[nPos,3] := SQL->ZP3_ANILOX
		       aPanV[nPos,4] := cBorracha
		    Endif
         EndIf
    
	     DbSkip()

      EndDo

      IIF(Select('SQL')!= 0, SQL->(DbCLoseArea()), )

Return()

Static Function BoxComp()

   nLinha 	+= 080
   nLinFim	:= nLinha + 080
   //oPrint:Box(nLinha, 020, nLinFim, 2510) 				//	Box ( < nRow>, < nCol>, < nBottom>, < nRight>, [ uParam5] ) --> NIL
   oPrint:Box(nLinha, 020, nLinFim, 2370)
   nLinha += 020
   oPrint:Say(nLinha, 0900, 'COMPONENTES', oFontC1, 1400, CLR_BLACK )

   nLinha += 070
   oPrint:Say( nLinha,  050, 'PRODUTO'      , oFontC, 1400, CLR_BLACK )
   oPrint:Say( nLinha,  380, 'DESCRIÇÃO'    , oFontC, 1400, CLR_BLACK )
 //oPrint:Say( nLinha, 1100, IIF(__nQtdLin>0,'Perda','QTD EMP '),		oFontC, 1400, CLR_BLACK )
   oPrint:Say( nLinha, 1100, 'QTD'          , oFontC, 1400, CLR_BLACK )
 //oPrint:Say( nLinha, 1500, 'UM'           , oFontC, 1400, CLR_BLACK )
   oPrint:Say( nLinha, 1250, 'UM'           , oFontC, 1400, CLR_BLACK )
   oPrint:Say( nLinha, 1500, 'QTD SEP'      , oFontC, 1400, CLR_BLACK )
   oPrint:Say( nLinha, 1700, 'UM'           , oFontC, 1400, CLR_BLACK )
 //oPrint:Say( nLinha, 1850, 'LOCAL'        , oFontC, 1400, CLR_BLACK )
 //oPrint:Say( nLinha, 1950, 'LOCAL'        , oFontC, 1400, CLR_BLACK )            

   nLinha += 050

Return()

// ################################################
// Função que pesquisa o componente da etiqueta  ##
// ################################################
User Function xBuscaComp()

   Local aRetorno  := {}
   Local aDim      := {}

   Local aDim      := {}
   Local _nL       := 0
   Local _nH       := 0
   Local _nC       := 0   
   Local _nEspEtq  := SuperGetMv("MV_ESPETQ",,3)
   Local _aQtdRolo := {}

   // ###########################################
   // Busca as dimensões da Etiqueta           ##
   // ###########################################
   _aQtdRolo := u_CalcMetr(SC2->C2_PRODUTO)

   // ################################
   // Pega a largura da Fatia da MP ##
   // ################################
   cDesc := Alltrim(Posicione('SB1', 1, xFilial('SB1')+SC2->C2_PRODUTO,'B1_DESC'))
   nPos  := AT("/",cDesc)
   nMult := Val(Substr(cDesc,nPos+1,3))/1000

   // #######################################################################################################################################
   // Calcula a quantidade de etiquetas da OP, se for em ROLO, multiplica pela QTD de etiq p/rolo, se for em MI, já pega direto o C2_QUANT ##
   // #######################################################################################################################################
   nQtdEtiq := IIF(SC2->C2_UM =="RL",_aQtdRolo[2]*SC2->C2_QUANT,SC2->C2_QUANT*1000)

//   nQtdEtiq := IIF(SC2->C2_UM =="RL",_aQtdRolo[2]*SC2->C2_ZQTD,SC2->C2_ZQTD*1000)

   // ##################################################################################################
   // Calcula a metragem linear da OP, se for em ROLO, multiplica pela metragem p/rolo, se for em MI, ##
   // calcula  a metragem por rl x quantos rolos dariam os MIL..                                      ##
   // ##################################################################################################
   nQtdLin := IIF(SC2->C2_UM =="RL",_aQtdRolo[1]*SC2->C2_QUANT,_aQtdRolo[1]*((SC2->C2_QUANT*1000)/_aQtdRolo[2]))

// nQtdLin := IIF(SC2->C2_UM =="RL",_aQtdRolo[1]*SC2->C2_ZQTD,_aQtdRolo[1]*((SC2->C2_ZQTD*1000)/_aQtdRolo[2]))

   // ###############################
   // QUERY SD4 - ITENS EMPENHADOS ##
   // ###############################
   IIF(Select('SQL')!= 0, SQL->(DbCLoseArea()), )

   cQuery 	:= " SELECT * "                                                                             + ENTER
   cQuery 	+= "   FROM " + RetSqlName('SD4') + " SD4 "		                                            + ENTER	
   cQuery 	+= "  WHERE	SD4.D4_FILIAL		= '" + xFilial('SD4') + "'"	                                + ENTER
   cQuery 	+= "    AND	LEFT(SD4.D4_OP, 11)	= '" + SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + "'"	+ ENTER
   cQuery 	+= "    AND	SD4.D_E_L_E_T_ 	   != '*' "				   		                                + ENTER
   cQuery 	+= "  ORDER BY SD4.D4_OP		      "					   		                            + ENTER

   //MemoWrit(GetTempPath()+'RELOP.TXT', cQuery )
   DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SQL', .F., .T.)

   DbSelectArea('SQL');DbGoTop()
   Do While !Eof()      

      cDescProd :=	Alltrim(Posicione('SB1', 1, xFilial('SB1') + SQL->D4_COD, 	'B1_DESC'	))
	  cUM 		:= 	Alltrim(Posicione('SB1', 1, xFilial('SB1') + SQL->D4_COD, 	'B1_UM'		))
	  cDescUM	:=	AllTrim(Posicione('SAH', 1, xFilial('SAH') + cUM,			'AH_UMRES'	))
		
	  Aadd(aRetorno, { SQL->D4_COD, cDescProd, Transform(SQL->D4_QUANT, PesqPict("SD4","D4_QUANT", TamSx3('D4_QUANT')[1])), cUM, SQL->D4_LOCAL, nQtdLin, "MTS LINEARES",nMult})

	  DbSkip()

   EndDo

   IIF(Select('SQL')!= 0, SQL->(DbCLoseArea()), )

Return(aRetorno)

Static Function DadosGramat(nLinGra)

   Local cGramat :=	""
   Local cMetr	 :=	""
   Local cEtqRol :=	""
   Local cRolos	 :=	""
   Local nMetr   := 0
   Local nEtqRol := 0
   Local nRolos  := 0

   DbSelectArea('SB1')
   DbSetOrder(1)
   DbGoTop()

   If DbSeek(xFilial('SB1') + SC2->C2_PRODUTO, .F.)

	  _aRet1   := U_CALCMETR(SC2->C2_PRODUTO)

  	  // ###############################
  	  // 1 = Metragem Linear por rolo ##
	  // 2 = Qtd Etoquetas por rolo   ##
	  // 3= Tubete                    ##
	  // ###############################
	  cGramat :=	TABELA("ZP",SB1->B1_MPCLAS,.f.)
	  nMetr	  :=	_aRet1[1]
	  nEtqRol :=	_aRet1[2]

	  IF SB1->B1_UM == "MI"
         nRolos	  := (SC2->C2_QUANT*1000)/nEtqRol
         //nRolos := (SC2->C2_ZQTD*1000)/nEtqRol
	  ELSE
	     nRolos	  :=	SC2->C2_QUANT
         //nRolos :=	SC2->C2_ZQTD
	  ENDIF

   EndIf

   oPrint:Box(nLinGra, 1020, nLinGra+080, 1200)
   oPrint:Say(nLinGra+020, 1035, 'GRAMAT.', oFontC, 1400, CLR_BLACK )

   oPrint:Box(nLinGra, 1200, nLinGra+080, 1450)
   oPrint:Say(nLinGra+020, 1240, 'METR.LIN', oFontC, 1400, CLR_BLACK )

   oPrint:Box(nLinGra, 1450, nLinGra+080, 1670)
   oPrint:Say(nLinGra+020, 1480, 'ETQ/ROLO', oFontC, 1400, CLR_BLACK )

   //oPrint:Box(nLinGra, 1750, nLinGra+080, 2200)
   oPrint:Box(nLinGra, 1670, nLinGra+080, 1820)
   oPrint:Say(nLinGra+020, 1695, 'ROLOS', oFontC, 1400, CLR_BLACK )

   nLinGra += 80
   oPrint:Box(nLinGra, 1020, nLinGra+080, 1200)
   //oPrint:Say(nLinGra+020, 1090, PadC(cGramat,20,''), oFontC, 1400, CLR_BLACK )
   oPrint:Say(nLinGra+020, 975, PadC(cGramat,20,''), oFontC, 1400, CLR_BLACK )

   oPrint:Box(nLinGra, 1200, nLinGra+080, 1450)
   oPrint:Say(nLinGra+020, 1230, TRANSFORM(nMetr,"@R 999,999.9"), oFontC, 1400, CLR_BLACK )

   oPrint:Box(nLinGra, 1450, nLinGra+080, 1670)
   oPrint:Say(nLinGra+020, 1480, TRANSFORM(nEtqRol,"@R 999,999"), oFontC, 1400, CLR_BLACK )

   //oPrint:Box(nLinGra, 1750, nLinGra+080, 2200)
   oPrint:Box(nLinGra, 1670, nLinGra+080, 1820)
   //oPrint:Say(nLinGra+020, 1800, TRANSFORM(nRolos,"@R 999,999"), oFontC, 1400, CLR_BLACK )
   oPrint:Say(nLinGra+020, 1700, TRANSFORM(nRolos,"@R 999,999"), oFontC, 1400, CLR_BLACK )

   nLinGra	:=	nLinGra+080

Return()

// ##################################################
// Função que carrega dados do roteiro de produção ##
// ##################################################
Static Function DadosRoteiro()

   Local cQuery := ""

   nLinha 	+= 080
   nLinFim	:= nLinha + 090

   //oPrint:Box(nLinha, 020, nLinFim, 1970) 				//	Box ( < nRow>, < nCol>, < nBottom>, < nRight>, [ uParam5] ) --> NIL
   //oPrint:Box(nLinha, 020, nLinFim, 2510) 				//	Box ( < nRow>, < nCol>, < nBottom>), < nRight>, [ uParam5] ) --> NIL

   oPrint:Box(nLinha, 020, nLinFim, 2370)

   nLinha += 020

   //oPrint:Say(nLinha, 0850, 'ROTEIRO DE OPERAÇÃO', oFontC1, 1400, CLR_BLACK )
   oPrint:Say(nLinha, 0900, 'ROTEIRO DE OPERAÇÃO', oFontC1, 2510, CLR_BLACK )

   nLinha  := nLinFim
   nLinFim	:= nLinha  + 070                           

   // ###################
   // Box dos roteiros ##
   // ###################
   BoxRot()

   // #######################
   // QUERY SG2 - ROTEIROS ##
   // #######################
   IIF(Select('SQL')!= 0, SQL->(DbCLoseArea()), )

   cQuery 	:= " SELECT *"
   cQuery 	+= "   FROM " + RetSqlName('SG2') + " SG2 "
   cQuery 	+= "  WHERE	SG2.G2_FILIAL		= ' " + xFilial('SG2')  + "'"
   cQuery 	+= "    AND	SG2.G2_PRODUTO		= ' " + SC2->C2_PRODUTO + "'"
   cQuery 	+= "    AND	SG2.D_E_L_E_T_ 	   != '*'"
   cQuery 	+= "  ORDER BY SG2.G2_OPERAC"

   // MemoWrit(GetTempPath()+'RELOP___ROTEIRO.TXT', cQuery )
   // MemoWrit('c:\sql\RELOP.TXT', cQuery )
   DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SQL', .F., .T.)
   DbSelectArea('SQL')
   DbGoTop()
             
   nLinCB 	:=	0
   nLnIni  := 	nLinha
   nLnFim	:=	0
   nCount	:=	0  

   // 99 = FINAL
   // 98 = INICIO
   Do While !Eof()      

	nCount++                               
	
	//If nCount == 1              
		//nLinha  := nLinFim
		//nLinFim	:= nLinha  + 230           
		nLinha := nLinha  + 230
		 
		cOperacao := AllTrim(SQL->G2_DESCRI)
		
		//oPrint:Box(nLinha,0020, nLinFim, 0490)
		//oPrint:Say(nLinha+0080, 070, cOperacao, oFontC, 1400,chef CLR_BLACK )  
		//oPrint:Say(nLinha+0300, 070, cOperacao, oFontC, 1400, CLR_BLACK )  
        oPrint:Say(nLinha+0095, 080, cOperacao, oFontC, 1400, CLR_BLACK )  		
		//oPrint:Box(nLinha,0490, nLinFim, 0980)
		//oPrint:Box(nLinha,0980, nLinFim, 1460)
		//oPrint:Box(nLinha,1460, nLinFim, 1970)

    //EndIf
    
	                       
	//If nCount == 1
	//	nColCB := 05//(520/10)
	//ElseIf nCount == 2
	//	nColCB := 10//(1100/10)
	//ElseIf nCount == 3
	//	nColCB := 17 //(1500/10)
	//EndIf


//if nCount == 1
	
		//nLinCB	+= IIF(nCount!=2, 19.50, 25)
		
		//nLinCB	+= IIF(ncount == 1,10.3,1)		
		nLinCB	+= IIF(ncount == 1,20.40,2.2)
		//cCodBarra := "99"+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)+SG2->G2_OPERAC
		cCodBarInic  := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN) + SQL->G2_OPERAC + "01"
     //   cCodBarParc  := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN) + SQL->G2_OPERAC + "02"		
       // cCodBarFinal := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN) + SQL->G2_OPERAC + "09"
	  //	MsBar3("CODE128",nLinCB,4.5,cCodBarInic,oPrint,.F.,,.T.,0.025,1.0,.F.,,,.F.) 
        //JEFERSON ARTEIRO-FOI FALADO COM O FERNANDO NO DIA 20/05/2015 E ELE PEDIU PARA RETIRAR ESTA VALIDAÇÃO	    
	    //If (SQL->G2_OPERAC <> "01")
	    	MsBar3("CODE128",nLinCB-1,8.5,cCodBarInic,oPrint,.F.,,.T.,0.025,1.0,.F.,,,.F.) 
	 //		MsBar3("CODE128",nLinCB,13.0,cCodBarFinal,oPrint,.F.,,.T.,0.025,1.0,.F.,,,.F.) 
		//EndIf
	/*                             
	
		MSBAR3 -Impressão de código de barras na deskjet HP e laser 
		( 
			[ cTypeBar ] [ nRow ] [ nCol ] [ cCode ] [ oPr ] [ lCheck ] [ Color ] [ lHort ] [ nWidth ] [ nHeigth ]	//	[10] 
			[ lBanner ] [ cFont ] [ cMode ] [ lPrint ] [ nPFWidth ] [ nPFHeigth ] 									//	[16]
		) --> Nil	
	*/                       

//endif	                                                                   
	    
    **************************   
   	//CheckFim()	 
    **************************	    
	//nLinha := 250		
	//BoxComp() 					//	[	IMPRIME BOX DO COMPONENTE			]
	//nCount 	:= 	IIF(nCount==3, 0, nCount)
	//nLnFim	:=	nLinha	
	DBSelectArea("SQL")
	DbSkip()            
   **************************   
   	CheckFim()	 
    **************************	    
	
EndDo
// BOX PARA IMAGEM DA ETIQUETA - B1_BITMAP
//oPrint:Box(nLnIni,1970, nLinFim+109, 2510)
//oPrint:Box(nLnIni,1970, nLinFim+109, 2370)
		



IIF(Select('SQL')!= 0, SQL->(DbCLoseArea()), )

Return()



******************************************************************
Static Function PrintRodape()
******************************************************************

nLinha := oPrint:nVertRes() + 080
//oPrint:Box(nLinha, 020, nLinha+050, 2510) 				//	Box ( < nRow>, < nCol>, < nBottom>, < nRight>, [ uParam5] ) --> NIL
oPrint:Box(nLinha, 020, nLinha+050, 2370)
//oPrint:SayBitmap(nLinha,025,cLogo, 250, 080 )	//	SayBitmap ( < nLinha>, < nCol>, < cBitmap>, [ nWidth], [ nHeight] )

Return()
******************************************************************
Static Function MyA093SBSVars(cCodigo)
******************************************************************
Local cCodBS  := Nil
Local cDescBS := Nil
Local cDescBsI:= Nil
Local aSavAre := {GetArea(), SBQ->(GetArea()), SBS->(GetArea())}
Local aRet    := {}
Local nTFam   := SuperGetMv("SOL_TFAM",.T.,4)   //Tamanho das FAMILIAS de Produtos

DbSelectArea("SBP");DbSetorder(1)
DbSeek(xFilial("SBP")+Left(cCodigo,nTFam))

If !SBP->BP_CODPAD == "2"
	cCodigo := SubStr(cCodigo, Len(AllTrim(SBP->BP_BASE)) + 1)
EndIf
 
DbSelectArea("SBQ");DbSetOrder(1)
DbSeek(xFilial("SBQ") + SBP->BP_BASE)
Do While ! Eof() .And. SBQ->(BQ_FILIAL + BQ_BASE) == xFilial("SBQ") + SBP->BP_BASE

	If SBP->BP_CODPAD == "2"
		cCodBS  := Substr(cCodigo, SBQ->BQ_INICIO, SBQ->BQ_TAMANHO)
	Else
		cCodBS  := SubStr(cCodigo, 1, SBQ->BQ_TAMANHO)
		cCodigo := SubStr(cCodigo, SBQ->BQ_TAMANHO + 1)
	EndIf
	
	If SBQ->BQ_TIPDEF == "1"
		SBS->(dbSeek(xFilial("SBS") + SBQ->(BQ_BASE + BQ_ID) + cCodBS))
		cDescBS  := SBS->BS_DESCPRD
		cDescBSI := SBS->BS_DESCR
	ElseIf SBQ->BQ_TIPDEF == "2"
		SBX->(dbSeek(xFilial("SBX") + SBQ->BQ_CONJUNT + cCodBS))
		cDescBS  := SBX->BX_DESCPR
		cDescBSI := SBX->BX_DESC
	ElseIf SBQ->BQ_TIPDEF == "3"
		cDescBS  := cCodBS
		cDescBSI := cCodBS
	EndIf

	Aadd(aRet, {SBQ->BQ_ID, cCodBS,cDescBS,cDescBSI })
	DbSkip()

EndDo

RestArea(aSavAre[3])
RestArea(aSavAre[2])
RestArea(aSavAre[1])
Return(aRet)
//*************************************************
Static Function BoxRot()

  oPrint:Box(nLinha,020, nLinFim, 490)
  oPrint:Say(nLinha+10,  170, 'OPERAÇÃO', oFontC, 1400, CLR_BLACK )
  oPrint:Box(nLinha+1,   020, nLinFim+300, 490)
  oPrint:Box(nLinha+369, 020, nLinFim+550, 490)
  oPrint:Box(nLinha+849, 020, nLinFim+550, 490)
  oPrint:Box(nLinha+1099,020, nLinFim+550, 490)


  oPrint:Box(nLinha, 490, nLinFim, 2370)
 // oPrint:Say(nLinha+10, 710, 'APONTAMENTO', oFontC, 1400, CLR_BLACK )      
  oPrint:Box(nLinha+1,020, nLinFim+300, 2370)  
  oPrint:Box(nLinha+369,020, nLinFim+550, 2370)
  oPrint:Box(nLinha+849,020, nLinFim+550, 2400) 
  oPrint:Box(nLinha+1099,020, nLinFim+550, 2400)
  
 // oPrint:Box(nLinha, 980, nLinFim, 1460)
  oPrint:Say(nLinha+10, 1130, 'APONTAMENTO', oFontC, 1400, CLR_BLACK )
  //oPrint:Box(nLinha+1,020, nLinFim+300, 1460)
  //oPrint:Box(nLinha+369,020, nLinFim+550, 1460)
  //oPrint:Box(nLinha+849,020, nLinFim+550, 1460)
  //oPrint:Box(nLinha+1099,020, nLinFim+550, 1460)

  //oPrint:Box(nLinha, 1460, nLinFim, 1970)
  //oPrint:Box(nLinha, 1460, nLinFim, 2510)
//  oPrint:Box(nLinha, 1460, nLinFim, 2400)
  //oPrint:Say(nLinha+10,  1600, 'FIM TOTAL', oFontC, 1400, CLR_BLACK )
  //oPrint:Box(nLinha+1,1460, nLinFim+300, 2510)
  //oPrint:Box(nLinha+1,1460, nLinFim+300, 2400)
  //oPrint:Box(nLinha+369,020, nLinFim+550, 2510)
  //oPrint:Box(nLinha+369,020, nLinFim+550, 2400)
  //oPrint:Box(nLinha+849,020, nLinFim+550, 2510)  
  //oPrint:Box(nLinha+849,020, nLinFim+550, 2400)
  //oPrint:Box(nLinha+1099,020, nLinFim+550, 2510)
  //oPrint:Box(nLinha+1099,020, nLinFim+550, 2400)

Return(.T.)















/*

	     PrintCabec()  //	[	IMPRIME DADOS DO CABECALHO			]

//	     DadosCli()					//	[	IMPRIME DADOS DO CLIENTE			]
//	     DadosOp()					//	[	IMPRIME DADOS DA ORDEM DE PRODUCAO	]
//	     BoxComp() 					//	[	IMPRIME BOX DO COMPONENTE			]




         aComp     := U_xBuscaComp()		//	[	QUERY PARA BUSCAR COMPONENTES DA OP	]		
         __nQtdLin := U_CalcPerda("OP", SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN,SC2->C2_PRODUTO,.F.)
	     __nQtdM2  := IIF(Len(aComp)>0,__nQtdLin * aComp[1][8],0)

         // #################################################
         // Atualiza a metragem linear DA op NA TABELA sc2 ##
         // #################################################
         DbSelectArea("SC2")
         RecLock("SC2",.F.)
         If SC2->C2_ZQTD == 0
            SC2->C2_ZQTD := SC2->C2_QUANT
         Endif   
         SC2->C2_QUANT:= __nQtdLin
         MsUnLock()              

	     For nX := 1 To Len(aComp)

		     nLinha += 050
		     oPrint:Say( nLinha,  050, aComp[nX][01], 	oFontC, 1400, CLR_BLACK )	//	D4_COD
		     oPrint:Say( nLinha,  380, aComp[nX][02], 	oFontC, 1400, CLR_BLACK )	//	B1_DESC
	         //oPrint:Say( nLinha, 1050, aComp[nX][03],	oFontC, 1400, CLR_BLACK )	//	D4_QUANT
		     oPrint:Say( nLinha, 1050, Transform(__nQtdM2, PesqPict("SD4","D4_QUANT", TamSx3('D4_QUANT')[1])),	oFontC, 1400, CLR_BLACK )	//	D4_QUANT
	         //oPrint:Say( nLinha, 1490, aComp[nX][04],	oFontC, 1400, CLR_BLACK )	//	B1_UM
		     oPrint:Say( nLinha, 1240, aComp[nX][04],	oFontC, 1400, CLR_BLACK )	//	B1_UM
             oPrint:Say( nLinha, 1480, Transform(__nQtdLin, PesqPict("SD4","D4_QUANT", TamSx3('D4_QUANT')[1])),oFontC, 1400, CLR_BLACK )	//  QTD LINEAR        
             oPrint:Say( nLinha, 1700,	aComp[nX][07],	oFontC, 1400, CLR_BLACK )	//  UNIDADE LINEAR        
	         //oPrint:Say( nLinha, 1850, aComp[nX][05],	oFontC, 1400, CLR_BLACK )	//	D4_LOCAL
	         //oPrint:Say( nLinha, 2000, aComp[nX][05],	oFontC, 1400, CLR_BLACK )	//	D4_LOCAL
	    
		     CheckFim()			//	[	VERIFICA SE CHEGOU NO FINAL DA PAGINA	] 

   	     Next

	     ProdCaract()				//	[	IMPRIME CARACTERISTICA DO PRODUTO	]

	     // #################################################################
	     // BUSCA DADOS REFERENTE AO PANTONE - FRENTE \ VERSAO  - TAB. ZP3 ## 
         // #################################################################
	     BoxPantone()			//	[	IMPRIME BOX PANTONE					]
	     DadosPan()

	     // ###########################################
	     // IMPRIME DADOS FRENTE - PANTONE - TAB ZP3 ##
	     // ###########################################
 	     nLinIni	:=	nLinha
 	     nLinFim	:=	nLinha
	     nLinGra	:=	0
       
	     For nX := 1 To Len(aPanF)

		     nLinIni := IIF(nX == 1, nLinha, nLinIni)

		     nLinha 	+= 	050
		     nLinFim := nLinha
		
	         nColEst	:=	050
	         nColPan	:=	190
	         nColAli :=	580
	         nColBor	:=	740

		     oPrint:Say( nLinha, nColEst,  aPanF[nX][01], oFontC, 1400, CLR_BLACK )
		     oPrint:Say( nLinha, nColPan,  aPanF[nX][02], oFontC, 1400, CLR_BLACK )	//	ZP3_PANTON
		     oPrint:Say( nLinha, nColAli,  aPanF[nX][03], oFontC, 1400, CLR_BLACK )	//	ZP3_ALINOX
		     oPrint:Say( nLinha, nColBor,  aPanF[nX][04], oFontC, 1400, CLR_BLACK )	//	ZP3_BORR

		     CheckFim()			//	[	VERIFICA SE CHEGOU NO FINAL DA PAGINA	]
    
		     nLinGra := IIF(nX==6, nLinha, nLinGra)	

 	     Next

	     // ###########################################
	     // IMPRIME DADOS VERSO  - PANTONE - TAB ZP3 ##
	     // ###########################################
	     For nX := 1 To Len(aPanV)

		     nLinha	:=	IIF(nX==1, nLinIni, nLinha )
		     nLinha 	+= 	050
				
	         nColEst	:=	0950
	         nColPan	:=	1070
	         nColAli :=	1440	    
	         nColBor	:=	1640
            
		     oPrint:Say( nLinha, nColEst,  aPanV[nX][01], oFontC, 1400, CLR_BLACK )	//	ZP3_ESTAG
		     oPrint:Say( nLinha, nColPan,  aPanV[nX][02], oFontC, 1400, CLR_BLACK )	//	ZP3_PANTON
		     oPrint:Say( nLinha, nColAli,  aPanV[nX][03], oFontC, 1400, CLR_BLACK )	//	ZP3_ALINOX
		     oPrint:Say( nLinha, nColBor,  aPanV[nX][04], oFontC, 1400, CLR_BLACK )	//	ZP3_BORR
	    
		     CheckFim()			//	[	VERIFICA SE CHEGOU NO FINAL DA PAGINA	]

   	     Next
    
	     DadosGramat(nLinGra) 

         // ###############################
	     // RETORNA VALOR DA LINHA FINAL ##
	     // ###############################
	     nLinha	:=	nLinFim

	     // ##############################################################
	     //   					BOX 'GERAL'                             ##
	     // 	 COMECA NO PANTONE E TERMINA NA LINHA DA GRAMATURA		##
	     // ##############################################################
	     //Box ( < nRow>, < nCol>, < nBottom>, < nRight>, [ uParam5] ) --> NIL
	     //oPrint:Box(1230, 020, nLinha+060, 2510)                                                   
	
	     //oPrint:Box(1230, 020, nLinha+080, 2400)
	
	     cImagem := 	"RoloM"+Upper(AllTrim(Posicione('SB1', 1, xFilial('SB1')+SC2->C2_PRODUTO,'B1_ROLO'))+'.bmp')
	     // cImgRep := RepExtract('',cImagem)
	     //oPrint:SayBitmap(1335, 2230, cImagem, 270, 475 )	//	SayBitmap ( < nLinha>, < nCol>, < cBitmap>, [ nWidth ], [ nHeight] )
	     //oPrint:SayBitmap(1335, 2210, cImagem, 270, 475 )	//	SayBitmap ( < nLinha>, < nCol>, < cBitmap>, [ nWidth ], [ nHeight] )
	     oPrint:SayBitmap(nLinIni, 1950, cImagem, 350, 400 )	//	SayBitmap ( < nLinha>, < nCol>, < cBitmap>, [ nWidth ], [ nHeight] )
    
	     //Sentido do rolo
         //oPrint:SayBitmap( 1310, 2200, cLogo, 250, 350 )	//	SayBitmap ( < nLinha>, < nCol>, < cBitmap>, [ nWidth], [ nHeight] )
		
	     nLinha	+=	050
	     DadosRoteiro()
	     //PrintRodape()				//	[	IMPRIME RODAPE	]
	     oPrint:EndPage()

*/
