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
// Referencia: AUTR314.PRW                                                         ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Fabianao Pereira (Solutio)                                          ##
// Data......: 25/08/2014                                                          ##
// Objetivo..: Impressão da Ordem de Produção                                      ##
// ##################################################################################

User Function AUTR314()

   Local   aArea  	  := GetArea()

   Private nLinha	  := 000
   Private nPagina	  := 001
   Private cLogo 	  := 'lgrl01.bmp'
   Private aComp	  := {}
   Private aPanF	  := {}
   Private aPanV	  := {}
   Private nCount     := 0                          
   Private __nQtdLin  := 0
   Private __nQtdM2   := 0
   Private aImpressos := {}

   Pergunte("AUTR314",.T.)

   // #####################################################
   // Posiciona a ordem de produção passada no parâmetro ##
   // #####################################################
   DbSelectArea("SC2")
   DBSEEK(xFilial("SC2") + MV_PAR01)

//   If SC2->C2_ZQTD == 0
//   Else
//      DbSelectArea("SC2")
//      RecLock("SC2",.F.)
//      SC2->C2_QUANT := SC2->C2_ZQTD 
//      SC2->C2_ZQTD  := 0
//      MsUnLock()              
//   Endif

   //DbSeek("0400878401001  ")             

   oFont12   := TFont():New( "Arial",,12,,.F.,,,,,.F. )
   oFont12N  := TFont():New( "Arial",,12,,.T.,,,,,.F. )
   //oFontC  := TFont():New( "Arial",,12,,.T.,,,,,.F. )
   oFontC 	 := TFont():New( "Arial",,9,,.T.,,,,,.F. )
   //oFontC1 := TFont():New( "Arial",,16,,.T.,,,,,.F. )
   oFontC1	 := TFont():New( "Arial",,14,,.T.,,,,,.F. )
   oFontC2	 := TFont():New( "Arial",,18,,.T.,,,,,.F. )
   oFont10   := TFont():New( "Arial",,10,,.F.,,,,,.F. )
   oFont10N  := TFont():New( "Arial",,10,,.T.,,,,,.F. )

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

   k_Filial := cFilAnt
   
   cCondicao := "C2_FILIAL == '" + Alltrim(k_Filial) + "' .AND. C2_NUM + C2_ITEM + C2_SEQUEN >= '"+MV_PAR01+"' .AND. C2_NUM + C2_ITEM + C2_SEQUEN <= '"+MV_PAR02+"' "

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
   
         // ###########################################################
         // Alimenta o array aImpressos para marcar as ops impressas ##
         // ###########################################################
         aAdd( aImpressos, C2_NUM )

         IF xFilial("SC2") + C2_NUM + C2_ITEM + C2_SEQUEN <> cChave
            cChave  := xFilial("SC2") + C2_NUM + C2_ITEM + C2_SEQUEN
            nPagina := 01
         ENDIF

         nLinha := 025 /// Inicio do Cabeçalho
	     PrintCabec()				//	[	IMPRIME DADOS DO CABECALHO			]
	     DadosCli()					//	[	IMPRIME DADOS DO CLIENTE			]
	     DadosOp()					//	[	IMPRIME DADOS DA ORDEM DE PRODUCAO	]
	     BoxComp() 					//	[	IMPRIME BOX DO COMPONENTE			]

         aComp     := U_BuscaComp()		//	[	QUERY PARA BUSCAR COMPONENTES DA OP	]		
         __nQtdLin := U_CalcPerda("OP", SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN,SC2->C2_PRODUTO,.F.)
	     __nQtdM2  := IIF(Len(aComp)>0,__nQtdLin * aComp[1][8],0)

         // #################################################
         // Atualiza a metragem linear DA op NA TABELA sc2 ##
         // #################################################
//         DbSelectArea("SC2")
//         RecLock("SC2",.F.)
//         If SC2->C2_ZQTD == 0
//            SC2->C2_ZQTD := SC2->C2_QUANT
//         Endif   
//         SC2->C2_QUANT:= __nQtdLin
//         MsUnLock()              

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
	
	     //oPrint:Box(1230, 020, nLinha+080, 2450)
	
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

Return()


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
      oPrint:Box(nLinha, 020, nLinha+80, 2450)
      BoxRot()                                                      
      nLinha := 750
      nLinCB := 7.0
   EndIf

Return()

Static Function PrintCabec()

   oPrint:StartPage()

   oPrint:Box(nLinha, 020, nLinha+265, 2450)                       
   nLinha+=15
   oPrint:SayBitmap( nLinha, 030, cLogo, nLinha+210, 080 )

   nLinha+=80
   oPrint:Say( nLinha, 0035,  AllTrim(SM0->M0_NOME)+' / '+AllTrim(SM0->M0_FILIAL), oFontC, 1400, CLR_BLACK )
   oPrint:Say( nLinha, 2000, 'Página:  '+AllTrim(Str(nPagina)), oFontC, 1400, CLR_BLACK )

   nLinha+=40
   oPrint:Say( nLinha, 035,  'AUTR314' , oFontC, 1400, CLR_BLACK )
   //oPrint:Say( 180, 2100, 'DT.Ref.:  '+DtoC(Date()) , oFontC, 1400, CLR_BLACK )
   //oPrint:Say( 180, 2060, 'DT.Ref.:  '+DtoC(Date()) , oFontC, 1400, CLR_BLACK )

   nLinha+=60
   oPrint:Say( nLinha, 035,  'Hora...:  '+Time() +'  -  Empresa: '+AllTrim(SM0->M0_NOME)+' / Filial: '+AllTrim(SM0->M0_FILIAL) , oFontC, 1400, CLR_BLACK )
   oPrint:Say( nLinha, 2000, 'Emissao OP: '+DtoC(dDataBase) , oFontC, 1400, CLR_BLACK )

   nLinha+=70

   IF "EXATA" $ SC2->C2_OBS
      oPrint:Say( nLinha, 0800, 'QUANTIDADE EXATA', oFontC2, 1400, CLR_BLACK )
   ENDIF

Return()

Static Function DadosOp()

   nLinha+=100
   oPrint:Box(nlinha, 020, nlinha+205, 2450)                                      
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
   oPrint:Box(nLinha, 020, nLinha +150, 2450)
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
   oPrint:Box(nLinha, 020, nLinha+80, 2450)
   nLinha+=30
   oPrint:Say(nLinha, 0900, 'CARACTERISTICAS', oFontC1, 1400, CLR_BLACK )

   nLinha+=50
   oPrint:Box(nLinha, 020, nLinha+80, 0380)
   oPrint:Box(nLinha, 020, nLinha+80, 1100)
   oPrint:Box(nLinha, 020, nLinha+80, 1300)
   oPrint:Box(nLinha, 020, nLinha+80, 1475)
   oPrint:Box(nLinha, 020, nLinha+80, 2450)
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
   oPrint:Box(nLinha, 020, nLinha+80, 2450)
   nLinha+=30
   oPrint:Say(nLinha, 0180, _cFaca   , oFontC, 1400, CLR_BLACK )
   oPrint:Say(nLinha, 0580, _cPapel  , oFontC, 1400, CLR_BLACK )
   oPrint:Say(nLinha, 1130, _cTubete , oFontC, 1400, CLR_BLACK )
   oPrint:Say(nLinha, 1320, _cSerr   , oFontC, 1400, CLR_BLACK )
   oPrint:Say(nLinha, 1500, _cCarac  , oFontC, 1400, CLR_BLACK )

Return()

Static Function BoxPantone()

   nLinha+=100
   oPrint:Box(nlinha, 020, nLinha+80, 2450)
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
   oPrint:Box(nLinha, 020, nLinFim, 2450)
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
User Function BuscaComp()

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

*********************************************************************
Static Function DadosGramat(nLinGra)
*********************************************************************
Local cGramat 	:= 	''
Local cMetr		:=	''
Local cEtqRol	:=	''                '
Local cRolos	:=	''
Local nMetr     := 0
Local nEtqRol   := 0
Local nRolos    := 0

DbSelectArea('SB1');DbSetOrder(1);DbGoTop()
If DbSeek(xFilial('SB1') + SC2->C2_PRODUTO, .F.)
	_aRet1   := U_CALCMETR(SC2->C2_PRODUTO)
	// 1 = Metragem Linear por rolo
	// 2 = Qtd Etoquetas por rolo
	// 3= Tubete
	cGramat	:=	TABELA("ZP",SB1->B1_MPCLAS,.f.)
	nMetr	:=	_aRet1[1]
	nEtqRol	:=	_aRet1[2]
	IF SB1->B1_UM == "MI"
       nRolos	:= (SC2->C2_QUANT*1000)/nEtqRol
//     nRolos	:= (SC2->C2_ZQTD*1000)/nEtqRol
	ELSE
	   nRolos	:=	SC2->C2_QUANT
// 	   nRolos	:=	SC2->C2_ZQTD
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
*********************************************************************
Static Function DadosRoteiro()
*********************************************************************
Local cQuery := ""

nLinha 	+= 080
nLinFim	:= nLinha + 090
//oPrint:Box(nLinha, 020, nLinFim, 1970) 				//	Box ( < nRow>, < nCol>, < nBottom>, < nRight>, [ uParam5] ) --> NIL
//oPrint:Box(nLinha, 020, nLinFim, 2510) 				//	Box ( < nRow>, < nCol>, < nBottom>), < nRight>, [ uParam5] ) --> NIL
oPrint:Box(nLinha, 020, nLinFim, 2450)
nLinha += 020
//oPrint:Say(nLinha, 0850, 'ROTEIRO DE OPERAÇÃO', oFontC1, 1400, CLR_BLACK )
oPrint:Say(nLinha, 0900, 'ROTEIRO DE OPERAÇÃO', oFontC1, 2510, CLR_BLACK )

nLinha  := nLinFim
nLinFim	:= nLinha  + 070                           
//Box dos roteiros
BoxRot()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³   QUERY SG2 - ROTEIROS					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IIF(Select('SQL')!= 0, SQL->(DbCLoseArea()), )

cQuery 	:= " SELECT * 	"+ENTER
cQuery 	+= " FROM "+ RetSqlName('SG2')+ " SG2 "		+ENTER	
cQuery 	+= " WHERE	SG2.G2_FILIAL		=	'"+xFilial('SG2')+"'"	+ENTER
cQuery 	+= " AND	SG2.G2_PRODUTO		=	'"+SC2->C2_PRODUTO+"'"	+ENTER
cQuery 	+= " AND	SG2.D_E_L_E_T_ 		!= '*' "					+ENTER
cQuery 	+= " ORDER BY SG2.G2_OPERAC		"					   		+ENTER

//MemoWrit(GetTempPath()+'RELOP___ROTEIRO.TXT', cQuery )
//MemoWrit('c:\sql\RELOP.TXT', cQuery )
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SQL', .F., .T.)
DbSelectArea('SQL')
DbGoTop()
             
nLinCB 	:=	0
nLnIni  := 	nLinha
nLnFim	:=	0
nCount	:=	0  

//99 = FINAL
//98 = INICIO
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
//oPrint:Box(nLnIni,1970, nLinFim+109, 2450)
		



IIF(Select('SQL')!= 0, SQL->(DbCLoseArea()), )
Return()
******************************************************************
Static Function PrintRodape()
******************************************************************

nLinha := oPrint:nVertRes() + 080
//oPrint:Box(nLinha, 020, nLinha+050, 2510) 				//	Box ( < nRow>, < nCol>, < nBottom>, < nRight>, [ uParam5] ) --> NIL
oPrint:Box(nLinha, 020, nLinha+050, 2450)
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


  oPrint:Box(nLinha, 490, nLinFim, 2450)
 // oPrint:Say(nLinha+10, 710, 'APONTAMENTO', oFontC, 1400, CLR_BLACK )      
  oPrint:Box(nLinha+1,020, nLinFim+300, 2450)  
  oPrint:Box(nLinha+369,020, nLinFim+550, 2450)
  oPrint:Box(nLinha+849,020, nLinFim+550, 2450) 
  oPrint:Box(nLinha+1099,020, nLinFim+550, 2450)
  
 // oPrint:Box(nLinha, 980, nLinFim, 1460)
  oPrint:Say(nLinha+10, 1130, 'APONTAMENTO', oFontC, 1400, CLR_BLACK )
  //oPrint:Box(nLinha+1,020, nLinFim+300, 1460)
  //oPrint:Box(nLinha+369,020, nLinFim+550, 1460)
  //oPrint:Box(nLinha+849,020, nLinFim+550, 1460)
  //oPrint:Box(nLinha+1099,020, nLinFim+550, 1460)

  //oPrint:Box(nLinha, 1460, nLinFim, 1970)
  //oPrint:Box(nLinha, 1460, nLinFim, 2510)
//  oPrint:Box(nLinha, 1460, nLinFim, 2450)
  //oPrint:Say(nLinha+10,  1600, 'FIM TOTAL', oFontC, 1400, CLR_BLACK )
  //oPrint:Box(nLinha+1,1460, nLinFim+300, 2510)
  //oPrint:Box(nLinha+1,1460, nLinFim+300, 2450)
  //oPrint:Box(nLinha+369,020, nLinFim+550, 2510)
  //oPrint:Box(nLinha+369,020, nLinFim+550, 2450)
  //oPrint:Box(nLinha+849,020, nLinFim+550, 2510)  
  //oPrint:Box(nLinha+849,020, nLinFim+550, 2450)
  //oPrint:Box(nLinha+1099,020, nLinFim+550, 2510)
  //oPrint:Box(nLinha+1099,020, nLinFim+550, 2450)

Return(.T.)
