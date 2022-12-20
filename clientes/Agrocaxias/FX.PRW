#INCLUDE "PROTHEUS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#Include "TOPCONN.ch"
#Include "fileio.ch"

#DEFINE DMPAPER_A4 9
#DEFINE MAXMENLIN 140                                               // Máximo de caracteres por linha de dados adicionais - Obs
#DEFINE MAXMENLIN1 58                                               // Máximo de caracteres por linha de dados adicionais - Desc
#DEFINE MAXMENLIN2 35                                               // Máximo de caracteres por linha de dados adicionais - Nome Empresa
#DEFINE MAXMENLIN3 15                                               // Máximo de caracteres por linha de dados adicionais - Cod Produto
#DEFINE PDFPATH   "\PDF_FOLDER\"
#DEFINE PDFOS     "\os\"
#DEFINE PDFTEMP   "\PDF_TEMP\"
#DEFINE BAT       "\bat\"
//#DEFINE PDFBALCAO  "\PDF_FOLDER\PDF_BALCAO\"
//#DEFINE PDFEXPED   "\PDF_FOLDER\PDF_EXPED\"


// -- defines de texto para impressao
#DEFINE TITULO  "ORDEM DE SEPARAÇÃO"
#DEFINE TITULO1 "DT.ENTREGA"
#DEFINE LINHA   15

/***********************************************************************************
|----------------------------------------------------------------------------------|
|* Programa   | FXFAT601                                        Data | 21/11/16 | *|
|----------------------------------------------------------------------------------|   
|* Autor      | 4Fx Soluções em Tecnologia                                        *|
|----------------------------------------------------------------------------------|
|* Utilização | Rotina de Expedição                                               *|
|----------------------------------------------------------------------------------|
|* Descricao  | Impressão de Ordens de Separação                 	              *|
|*            |                                                                   *|
|----------------------------------------------------------------------------------|
***********************************************************************************/

User Function FXFAT601(_lAut,lImpCup)

	Local   aGetArea := getArea()
	Local   cQuery   := ""
	Local   cOrd     := ""
	Local 	cFolder	 := ""
	Local	cTpVend  := ""
	Local   _cBat    := "FXFAT601.bat"
	Local   cPathBat  := ""


	Private nX := 620 	//constante posicionamento horizontal
	Private nY := 840  	//constante posicionamento vertical

	Private nLinha  := 15
	Private nColuna := 10
	Private nColFim := 193

	Private nCellDiv1 := (nX-nColuna)/3
	Private nCellDiv2 := ((nX-nColuna)/8 )+ 10

	Private nPag := 1

	Private oFonte := nil
	Private oRelat := nil
	

	Private cPerg   := PADR(("FXFAT601"),LEN(SX1->X1_GRUPO)," ")//perguntas

	Default _lAut 	:= .T.
	Default lImpCup := .T.

	IF !_lAut .and. !lImpCup
		lImpCup := MsgYesNo("Deseja imprimir a Ordem de Separação no formato reduzido ?")
	Endif
	
	/*
	IF _lAut
		cFoldImp := PDFTEMP	//GetSrvProfString("ROOTPATH","") + PDFTEMP
		cFolder  := PDFOS	//GetSrvProfString("ROOTPATH","") + PDFOS
		conout("<< PT006SCH - Diretorio onde sera salvo o arquivo .pdf quando via schedule: "+cFolder)
		cPathBat := GetSrvProfString("ROOTPATH","") + BAT
		conout("<< PT006SCH - Diretorio onde sera salvo o arquivo .bat quando via schedule: "+cPathBat)
		//cFolder := GetTempPath()
		//Alert(cFolder)
	else
		cFolder := GetTempPath()
	endif
	*/


	cFolder := GetTempPath()
	// -- Instancia os objetos de fonte antes da pintura do relatorio
	oFont06N := TFont():New( "Arial",, 06,,.T.)
	oFont06  := TFont():New( "Arial",, 06,,.F.)
	oFont07  := TFont():New( "Arial",, 07,,.F.)
	oFont08N := TFont():New( "Arial",, 08,,.T.)
	oFont08  := TFont():New( "Arial",, 08,,.F.)
	oFont10  := TFont():New( "Arial",, 10,,.F.)
	oFont10N := TFont():New( "Arial",, 10,,.T.)
	oFont11  := TFont():New( "Arial",, 11,,.F.)
	oFont11N := TFont():New( "Arial",, 11,,.T.)
	oFont12  := TFont():New( "Arial",, 12,,.F.)
	oFont12N := TFont():New( "Arial",, 12,,.T.)
	oFont13  := TFont():New( "Arial",, 13,,.F.)
	oFont13N := TFont():New( "Arial",, 13,,.T.)
	oFont14  := TFont():New( "Arial",, 14,,.F.)
	oFont14N := TFont():New( "Arial",, 14,,.T.)
	oFont16N := TFont():New( "Arial",, 16,,.T.)

	cTpVend := Posicione("SA3",2,XFILIAL("SA3")+CB7->CB7_ANMVEN,"A3_TIPO")

	If cTpVend="I"
		cImpress := "\\AGREXP02\EPSON"
		cNomeF := cTpVend+"_AUTO_"+ALLTRIM(CB7->CB7_ORDSEP)
	else
		cImpress := "\\AGREXP01\ELGIN"
		cNomeF := ALLTRIM(CB7->CB7_ORDSEP)
	Endif 

	/* Desabilitado Isabel 23/06/22 - Substituido por código acima
	IF _lAut
		cNomeF := cTpVend+"_AUTO_"+ALLTRIM(CB7->CB7_ORDSEP)
	else
		cNomeF := ALLTRIM(CB7->CB7_ORDSEP)
	endif

	if !empty(CB7->CB7_CODOPE)
		cNomeF += '_' + alltrim(CB7->CB7_CODOPE) + '_' + alltrim(CB7->CB7_FILIAL)  
	endIf	

	// -- Validações de setup
	oRelat := FWMSPrinter():New(cNomeF,IMP_PDF,.F.,cFolder,.T.)	
	*/

	IF _lAut
		//oRelat := FWMSPrinter():New(cNomeF,IMP_SPOOL,.F.,cFolder,.T.,.F.,,Alltrim(cImpress))
		//oRelat := FWMsPrinter():New(cNomeF+".pdf",IMP_PDF,.T.,cFoldImp,.T.,,oRelat ,,.T.,,,.F.)	
		lAdjustToLegacy := .F.
   		lDisableSetup   := .T.
		//oRelat := FwMsPrinter():New(cNomeF+".pdf", IMP_PDF, lAdjustToLegacy, cFoldImp, lDisableSetup, , , , , , .F., )
		oRelat := FWMSPrinter():New(cNomeF,IMP_SPOOL,lAdjustToLegacy,cFolder,lDisableSetup,.F.,,Alltrim(cImpress))
		Conout(" << PT006SCH - Imprimindo " + cNomeF+".pdf  em: " + Alltrim(cImpress))
	else
		oRelat := FWMSPrinter():New(cNomeF,IMP_SPOOL,.F.,cFolder,.T.)		
	endif
		//FWMSPrinter():New(cFilePrint+".etq",IMP_SPOOL,lAdjustToLegacy,"/spool/",lDisableSetup,,,Alltrim(cImpress) )
	oRelat:SetResolution(72)
	oRelat:SetPortrait()
	oRelat:SetPaperSize(1)
	oRelat:lServer := .T.  
	//oRelat:cPathPDF := cFolder

	//If _lAut
	//	oRelat:lInJob  := .T.
	//	oRelat:lServer := .T.  // TROCADO PARA .F. Isabel BM Tec 23/06
	//	oRelat:SetMargin(00,00,00,00)
		//oRelat:cPrinter :="\\192.168.1.33\"+cImpress 
	//else
		//oRelat:lServer := .T.  // ADICIONADO Isabel BM Tec 23/06	
		//oRelat:SetMargin(05,05,05,05)
		//oRelat:SetUp()
	//Endif


	//dbSelectArea("CB7")
		RecLock("CB7",.F.)
			CB7->CB7_IMP = 'S'
		MsUnLock()

	//-- posiciona no primeiro item da ordem de separacao
	CB8->(dbGoTop())
	CB8->(dbSetOrder(7))
	CB8->(msSeek(xFilial("CB8") + CB7->CB7_ORDSEP))

	if isInCallStatic("U_FXFAT103") //se for chamado por esta rotina precisa posicionar o SF2...via PE ja esta posicionado
		dbSelectArea("SF2")
		SF2->(dbSetOrder(1))
		SF2->(dbSeek(xFilial('SF2')+PADR(Alltrim(CB7->CB7_NOTA),TAMSX3("F2_DOC")[1])+PADR(Alltrim(CB7->CB7_SERIE),TAMSX3("F2_SERIE")[1])))
	endIf
	
	conout(" << PT006SCH - Iniciando a Impressao.")
	oRelat:Startpage()

	IF !lImpCup
		// -- desenha margens na folha
		ImpBoxPage()
		// -- imprime cabecalho
		ImpCabec()
		// -- imprime itens
		ImpItem()
	else
		ImpCabCup()
		ImpItCup()
	endif

	oRelat:EndPage()
	oRelat:Print()
	conout(" << PT006SCH - Fim da Impressao.")
	Sleep(5000)

	/*IF _lAut
		
		cPathPDF  := AllTrim( oRelat:cPathPDF )
		cFileRel  := Lower( AllTrim( oRelat:cFileName) )
		cFileName := StrTran( Lower( AllTrim( oRelat:cFileName ) ) , ".rel" , ".pdf" )

		//If alltrim(cPathPDF) != alltrim(cFolder)
			If __CopyFile( cPathPDF + cFileName, cFolder + cFileName )
				FErase( cPathPDF + cFileName )//Apaga o arquivo 
					//Cria.Bat
				//_cCmdBat    := 'c:\autoimp\sumatrapdf.exe -print-settings "noscale" -print-to "'+cImpress+'" '+ GetSrvProfString("ROOTPATH","") + cFolder + cFileName

				//if fGerBat(cPathBat,_cBat,_cCmdBat)
					//Executabat
					//_nErro := WinExec(cPathBat + _cBat)
					//WaitRun(cPathBat + _cBat, 2)
					WaitRunSrv( cPathBat + _cBat, .T. , "C:\" )
					//ShellExecute("OPEN", cPathBat + _cBat, "", cPathBat, 0 )
					conout(" << PT006SCH - Enviado arquivo para impressão com sucesso.")
					AEVAL(DIRECTORY("*.pdf"), { |aFile| FERASE(aFile[F_NAME]) })
					/*
					If _nErro == 0
						conout(" << PT006SCH - Enviado arquivo para impressão com sucesso.")
					Else
						conout(" << PT006SCH - Falha ao enviar arquivo para impressão. Erro de OS = " + cValToChar(_nErro))
					EndIf */    
				//endif
			//else
				//conout(" << PT006SCH - Nao conseguiu copiar o arquivo da pasta: "+cPathPDF + cFileName+" para a pasta: "+cFolder + cFileName)
			//EndIf
			//conout(" << PT006SCH - Nao conseguiu copiar o arquivo da pasta: ")
		//Endif
		
		//Alert("Copia arq")
		//oRelat := FWMSPrinter():New(cNomeF,IMP_PDF,.F.,cFolder,.T.,.F.,,)	
		//oRelat:Preview()

		//Copy File (cFolder+cNomeF+".pdf") to (PDFPATH+cNomeF+".pdf")
		//Sleep(2000)
		//delete file (cFolder+cNomeF+".pdf")
		//conout("FXFAT601")
		//cPathPDF  := AllTrim( oRelat:cPathPDF )
		//conout("Caminho do pdf:")
		//conout(cPathPDF)
		//cFileRel  := Lower( AllTrim( oRelat:cFileName) )
		//conout("Nome do Arquivo:")
		//conout(cFileRel)
		//cFileName := StrTran( Lower( AllTrim( oRelat:cFileName ) ) , ".rel" , ".pdf" )
		//conout("Nome do Arquivo substituindo .rel por .pdf:")
		//conout(cFileName)
		//If __CopyFile( cPathPDF + cFileName , PDFPATH + cFileName )
		//	conout("Conseguiu copiar o arquivo "+cFileName+" do local: "+cPathPDF+" para o local: "+PDFPATH)
		//	FErase( cPathPDF + cFileName )//Apaga o arquivo      
		//else
		//	conout("Não conseguiu copiar o arquivo "+cFileName+" do local: "+cPathPDF+" para o local: "+PDFPATH)
		//EndIf

	//Endif

	FreeObj(oRelat)
	Sleep(5000)


	restArea(aGetArea)

Return nil


Static Function ImpBoxPage()

	// -- linhas horizontais
	oRelat:Line(nLinha     ,nColuna      , nLinha     ,nX - nColuna)
	oRelat:Line(nLinha*50, nColuna, nLinha*50,nX - nColuna)

	// -- linhas verticais
	oRelat:Line(nLinha, nColuna ,nLinha*50,nColuna)
	oRelat:Line(nLinha, nX - nColuna ,nLinha*50,nX - nColuna)

Return nil

Static Function ImpCabCup()

	Local cOrdSep := Alltrim(CB7->CB7_ORDSEP)
	Local cPedido := Alltrim(CB7->CB7_PEDIDO)
	Local cCliente:= ""
	Local cLoja   := Alltrim(CB7->CB7_CLIENTE) + "-" + Alltrim(CB7->CB7_LOJA)
	Local cNota   := Alltrim(CB7->CB7_NOTA)
	Local cSerie  := Alltrim(CB7->CB7_SERIE)
	Local cOP     := Alltrim(CB7->CB7_OP)
	Local cStatus := RetStatus(CB7->CB7_STATUS)
	Local cArmaz  := AllTrim(CB8->CB8_LOCAL)
	Local cDtEnt  := DtoC(CB7->CB7_DTEMIS)
	Local cHrEmis := CB7->CB7_HREMIS
	Local cVend   := SF2->F2_VEND1
	Local cTrans  := SF2->F2_TRANSP
	Local dDtEntr := fBuscaCpo("SC5", 1, xFilial("SC5") + CB7->CB7_PEDIDO, "C5_FECENT" )

	//Local aTrb    := GetArea()
	nLinha := 0
	
	dbSelectArea("SA1")
	dbSetOrder(1)

	SA1->(msSeek( xFilial("SA1") + CB7->CB7_CLIENT + CB7->CB7_LOJA) )
	cCliente := left((alltrim(SA1->A1_NOME)), 38)

	dbSelectArea("SA3")
	SA3->(dbSetOrder(1))
	SA3->(MsSeek( xFilial("SA3") + cVend ))

	dbSelectArea("SA4")
	SA4->(dbSetOrder(1))
	SA4->(MsSeek( xFilial("SA4") + cTrans ))

	// -- empresa
	oRelat:SayAlign(nLinha,nColuna,alltrim(SM0->M0_NOMECOM),oFont11N,nColFim, 50,, 2, 0)
	nLinha += LINHA
	nLinha += LINHA
	nLinha += LINHA
	nLinha += LINHA
	nLinha += LINHA
	nLinha += LINHA
	nLinha += LINHA
	oRelat:QRCode(nLinha,065,cOrdSep, 070)
	oRelat:SayAlign(nLinha,nColuna,TITULO,oFont16N,nColFim, 9,, 2, 0)
	nLinha += LINHA
	oRelat:SayAlign(nLinha,nColuna,cOrdSep,oFont16N,nColFim, 9,, 2, 0)
	nLinha += LINHA
	oRelat:SayAlign(nLinha,nColuna,TITULO1,oFont16N,nColFim, 9,, 2, 0)
	nLinha += LINHA
	oRelat:SayAlign(nLinha,nColuna,dtoc(dDtEntr),oFont16N,nColFim, 9,, 2, 0)

	nLinha += LINHA
	nLinha += (LINHA/2)
	oRelat:Line(nLinha,nColuna, nLinha,nColFim+nColuna,,"-8")
	oRelat:SayAlign(nLinha,nColuna,cDtEnt ,oFont11N,nColFim, 9,, 0, 0)
	oRelat:SayAlign(nLinha,nColuna,cHrEmis,oFont11N,nColFim, 9,, 1, 0)

	nLinha += LINHA
	oRelat:SayAlign(nLinha,nColuna,"NOTA FISCAL",oFont10,nColFim, 9,, 0, 0)
	IF !Empty(cPedido)
		oRelat:SayAlign(nLinha,nColuna,"PEDIDO",oFont11,nColFim, 9,, 1, 0)
	endif
	nLinha += (LINHA/2)+2
	oRelat:SayAlign(nLinha,nColuna,cSerie + ' / ' + cNota,oFont14N,nColFim, 9,, 0, 0)
	oRelat:SayAlign(nLinha,nColuna,cPedido,oFont14N,nColFim, 9,, 1, 0)
	nLinha += LINHA
	oRelat:SayAlign(nLinha,nColuna,"TRANSPORTADORA",oFont10,nColFim, 9,, 0, 0)
	nLinha += (LINHA/2)
	oRelat:SayAlign(nLinha,nColuna,Alltrim(SA4->A4_NOME),oFont12N,nColFim, 9,, 0, 0)
	nLinha += LINHA
	nLinha += (LINHA/2)
	oRelat:SayAlign(nLinha,nColuna,"CLIENTE",oFont10,nColFim, 9,, 0, 0)
	nLinha += (LINHA/2)
	oRelat:SayAlign(nLinha,nColuna,cCliente,oFont12N,nColFim, 9,, 0, 0)
	nLinha += LINHA
	nLinha += (LINHA/2)
	oRelat:SayAlign(nLinha,nColuna,"VENDEDOR",oFont10,nColFim, 9,, 0, 0)
	nLinha += (LINHA/2)
	oRelat:SayAlign(nLinha,nColuna,Alltrim(SA3->A3_NOME),oFont12N,nColFim, 9,, 0, 0)
	cTpVend := SA3->A3_TIPO
	nLinha += LINHA
	nLinha += (LINHA/2)
	oRelat:Line(nLinha,nColuna, nLinha,nColFim+nColuna,,"-6")
	
Return nil


Static Function ImpItCup()

	Local nCol 		:= 90
	Local cObs 		:= ""
	Local aAux2 	:= {}
	Local nLinItem	:= 17
	Local nItem		:= 0
	Local nCont		:= 0
	Local _x		:= 0
	
	SB8->(DBSetOrder(5))

	while !CB8->(EoF()) .AND. CB8->CB8_FILIAL + CB8->CB8_ORDSEP == xFilial("CB8") + CB7->CB7_ORDSEP
	
		nItem++
		
		// Linha separadora dos itens
		IF nItem > 1 
			oRelat:Line(nLinha,nColuna+30, nLinha,nColFim+nColuna-30,,"-6")
		endif
		IF nItem == 8
			oRelat:Endpage()
			oRelat:Startpage()
			nLinha := 0
			nItem  := 1
		endif
	

		oRelat:SayAlign(nLinha,nColuna,"Produto",oFont11,nColFim, 9,, 0, 0)
		oRelat:SayAlign(nLinha,nColuna,"Endereço",oFont11,nColFim, 9,, 2, 0)
		oRelat:SayAlign(nLinha,nColuna,"Quantidade",oFont11,nColFim, 9,, 1, 0)
		nLinha += (nLinItem/2)
		oRelat:SayAlign(nLinha,nColuna,CB8->CB8_PROD,oFont12N,nColFim, 9,, 0, 0)
		oRelat:SayAlign(nLinha,nColuna,Alltrim(CB8->CB8_LCALIZ),oFont12N,nColFim, 9,, 2, 0)
		oRelat:SayAlign(nLinha,nColuna,transform(CB8->CB8_QTDORI,"@E 999,999,999.99"),oFont12N,nColFim, 9,, 1, 0)
		nLinha += (nLinItem/1.5)//(nLinItem/1.5)
		cDesc := Alltrim(fBuscaCPO("SB1",1,xFilial("SB1") + CB8->CB8_PROD, "B1_DESC"))
		oRelat:SayAlign(nLinha,nColuna,cDesc,oFont12N,nColFim, 9,, 0, 0)
		nLinha += nLinItem
		nLinha += (nLinItem/2)

		If !Empty(CB8->CB8_NUMSER) .or. !Empty(CB8->CB8_LOTECT)
		
			IF !Empty(CB8->CB8_LOTECT)
				SB8->(MsSeek(xFilial('SB8') + CB8->CB8_PROD + CB8->CB8_LOTECT ))
				oRelat:SayAlign(nLinha,nColuna,"Lote",oFont11,nColFim, 9,, 0, 0)
				oRelat:SayAlign(nLinha,nColuna,"Validade",oFont11,nColFim, 9,, 2, 0)
			endif
			IF !Empty(CB8->CB8_NUMSER)
				oRelat:SayAlign(nLinha,nColuna,"Número de Série",oFont11,nColFim, 9,, 1, 0)
			endif
			nLinha += (nLinItem/2)
			IF !Empty(CB8->CB8_LOTECT)
				oRelat:SayAlign(nLinha,nColuna,CB8->CB8_LOTECT,oFont12N,nColFim, 9,, 0, 0)
				oRelat:SayAlign(nLinha,nColuna,DtoC(SB8->B8_DTVALID),oFont12N,nColFim, 9,, 2, 0)
			Endif
			oRelat:SayAlign(nLinha,nColuna,CB8->CB8_NUMSER,oFont12N,nColFim, 9,, 1, 0)
			nLinha += nLinItem
		endIf


		CB8->(dbSkip())
	endDo
	oRelat:Line(nLinha,nColuna, nLinha,nColFim+nColuna,,"-6")
	cObs := fBuscaCpo("SC5", 1, CB7->CB7_FILIAL + CB7->CB7_PEDIDO, "C5_AOBSSEP" )

	oRelat:SayAlign(nLinha,nColuna,"Observações",oFont11,nColFim, 9,, 0, 0)
	nLinha += (nLinItem/2)

	aAux2 := _Msg(cObs,30)

	For _x := 1 to Len(aAux2)
		oRelat:SayAlign(nLinha,nColuna,aAux2[_x],oFont12N,nColFim, 9,, 4, 0)
		nLinha += (nLinItem/2)
	Next

	nLinha += nLinItem
	oRelat:Line(nLinha,nColuna, nLinha,nColFim+nColuna,,"-8")

Return nil







Static Function ImpCabec()

	Local cOrdSep := Alltrim(CB7->CB7_ORDSEP)
	Local cPedido := Alltrim(CB7->CB7_PEDIDO)
	Local cCliente:= ""
	Local cLoja   := Alltrim(CB7->CB7_CLIENTE) + "-" + Alltrim(CB7->CB7_LOJA)
	Local cNota   := Alltrim(CB7->CB7_NOTA)
	Local cSerie  := Alltrim(CB7->CB7_SERIE)
	Local cOP     := Alltrim(CB7->CB7_OP)
	Local cStatus := RetStatus(CB7->CB7_STATUS)
	Local cArmaz  := AllTrim(CB8->CB8_LOCAL)
	Local cDtEnt  := DtoC(CB7->CB7_DTEMIS)
	Local cHrEmis := CB7->CB7_HREMIS
	Local cVend   := fBuscaCpo("SC5", 1, xFilial("SC5") + CB7->CB7_PEDIDO, "C5_VEND1" )

	//Local aTrb    := GetArea()

	dbSelectArea("SA1")
	dbSetOrder(1)

	SA1->(msSeek( xFilial("SA1") + CB7->CB7_CLIENT + CB7->CB7_LOJA) )
	cCliente := left((alltrim(SA1->A1_NOME)), 38)

	dbSelectArea("SA3")
	SA3->(dbSetOrder(1))
	SA3->(MsSeek( xFilial("SA3") + cVend ))

	// -- empresa
	oRelat:SayAlign(nLinha,nColuna,alltrim(SM0->M0_NOMECOM),oFont11N,560, 9,, 2, 0)
	nLinha += LINHA
	oRelat:SayAlign(nLinha,nColuna,TITULO,oFont16N,560, 9,, 2, 0)

	// -- dados de Separação
	oRelat:Line(nLinha - LINHA     ,nColuna + 100     , nLinha + (LINHA*2) ,nColuna + 100)
	oRelat:Line(nLinha - LINHA     ,462     , nLinha + (LINHA*6)+08 ,462)
	nLinha += 2*LINHA
	oRelat:Line(nLinha     ,nColuna      , nLinha     ,nX - nColuna - 128) // AQUI
	//oRelat:Say(nLinha - 30 ,nColuna + 3,"Ord. Sep.:" + cOrdem,oFont12)
	oRelat:Say(nLinha - 30      ,465,"Ped. Ven.:",oFont08)
	oRelat:Code128c(nLinha - 5 ,505, cPedido, 40)    	
	nLinha += LINHA

	oRelat:Say(nLinha - 33 ,nColuna + 3,"Dt. Emis.: " + cDtEnt,oFont12N)
	oRelat:Say(nLinha - 20 ,nColuna + 3,"Hr. Emis.: " + cHrEmis,oFont12N)


	oRelat:Say(nLinha,nColuna+3   ,"Ordem de Separacao: " + cOrdSep,oFont12)
	oRelat:Say(nLinha,350,"Pedido de Venda: " + cPedido ,oFont12)

	nLinha += LINHA
	oRelat:Say(nLinha,nColuna+3,"Cliente / Loja : " + cCliente + " / " + cLoja,oFont12)
	oRelat:Say(nLinha,350    ,"Status: "+cStatus ,oFont12)

	oRelat:Say(nLinha,465,"Ord. Sep.:",oFont08)
	oRelat:Code128c(nLinha + 25 ,505, 	Alltrim(cOrdSep), 40)

	nLinha += LINHA
	oRelat:Say(nLinha,nColuna+3,"Vendedor : " + Alltrim(SA3->A3_COD) + " / " + Alltrim(SA3->A3_NOME),oFont12)
	nLinha += LINHA		 
	oRelat:Say(nLinha,nColuna+3,"Armazem: " + cArmaz,oFont12)
	nLinha += LINHA/2	
	oRelat:Line(nLinha     ,nColuna      , nLinha     ,nX - nColuna)

	//RestArea(aTrb)
Return nil

static Function ImpItem()

	Local nCol 	:= 90
	Local cObs 	:= ""
	Local aAux2 := {}
	Local _x	:= 0

	nLinha += LINHA/2
	nLinha += LINHA/4
	oRelat:Say(nLinha,nColuna +3           ,"Produto",oFont12N)
	oRelat:Say(nLinha,nColuna + 3.4*nCol   ,"Endereço",oFont12N)
	oRelat:Say(nLinha,nColuna + 4.2*nCol   ,"Qtd Original",oFont12N)
	oRelat:Say(nLinha,nColuna + 5.2*nCol   ,"Qtd a Separar",oFont12N)
	//oRelat:Say(nLinha,nColuna + 5.2*nCol   ,"Qtd a Embalar",oFont12N)
	nLinha += LINHA/2
	oRelat:Line(nLinha     ,nColuna      , nLinha     ,nX - nColuna)
	nLinha += LINHA

	// -- contador de itens
	nCount := 1

	// -- escreve item a item
	while !CB8->(EoF()) .AND. CB8->CB8_FILIAL + CB8->CB8_ORDSEP == xFilial("CB8") + CB7->CB7_ORDSEP

		if nCount >= 40
			nCount := 1
			nLinha  := 15
			oRelat:EndPage()
			oRelat:StartPage()
			ImpBoxPage()
			ImpCabec()
			nLinha += LINHA/2
			nLinha += LINHA/4
		endIf

		cDesc := subStr(fBuscaCPO("SB1",1,xFilial("SB1") + CB8->CB8_PROD, "B1_DESC"),0,30)

		oRelat:Say(nLinha,nColuna +3           ,CB8->CB8_PROD + cDesc,oFont12)
		oRelat:Say(nLinha,nColuna + 3.4*nCol   ,CB8->CB8_LCALIZ,oFont12)		
		oRelat:Say(nLinha,nColuna + 4.2*nCol   ,transform(CB8->CB8_QTDORI,"@E 999,999,999.99"),oFont12)
		oRelat:Say(nLinha,nColuna + 5.2*nCol   ,transform(CB8->CB8_SALDOS,"@E 999,999,999.99"),oFont12)
		//oRelat:Say(nLinha,nColuna + 5.2*nCol ,transform(CB8->CB8_SALDOE,"@E 999,999,999.99"),oFont12)
		nLinha += LINHA
		nCount ++

		If !Empty(CB8->CB8_NUMSER) .OR. !Empty(CB8->CB8_LOTECT) 

			oRelat:Say(nLinha,nColuna + 3          ,"Num. Série: " + CB8->CB8_NUMSER,oFont12N)
			oRelat:Say(nLinha,nColuna + 3.4*nCol   ,"Lote: "  + CB8->CB8_LOTECT,oFont12N)
			nLinha += LINHA
			nCount ++

		endIf

		CB8->(dbSkip())
	endDo

	nLinha += LINHA
	nLinha += LINHA
	nLinha += LINHA
	nLinha += LINHA

	cObs := fBuscaCpo("SC5", 1, CB7->CB7_FILIAL + CB7->CB7_PEDIDO, "C5_AOBSSEP" )

	oRelat:Say(nLinha,nColuna + 3 ,"Observações: ", oFont12N)
	nLinha += LINHA

	aAux2 := _Msg(cObs,MAXMENLIN)

	For _x := 1 to Len(aAux2)
		oRelat:Say(nLinha,nColuna + 3 ,aAux2[_x], oFont12)
		nLinha += LINHA
	Next

Return nil

// -- valida existencia de pasta dedicada aos arquivos pdf da rotina automatica
static function existPDFLD()
	Local lRet := .T.

	if ! existDir(PDFPATH)
		If ! makeDir(PDFPATH) == 0
			lRet := .F.
		EndIf
	endIf

Return lRet


Static Function RetStatus(cStatus)
	Local cDescri:= " "

	If Empty(cStatus) .or. cStatus == "0"
		cDescri:= "Nao iniciado"
	ElseIf cStatus == "1"
		cDescri:= "Em separacao"
	ElseIf cStatus == "2"
		cDescri:= "Separacao finalizada"
	ElseIf cStatus == "3"
		cDescri:= "Em processo de embalagem"
	ElseIf cStatus == "4"
		cDescri:= "Embalagem Finalizada"
	ElseIf cStatus == "5"
		cDescri:= "Nota gerada"
	ElseIf cStatus == "6"
		cDescri:= "Nota impressa"
	ElseIf cStatus == "7"
		cDescri:= "Volume impresso"
	ElseIf cStatus == "8"
		cDescri:=  "Em processo de embarque"
	ElseIf cStatus == "9"
		cDescri:=  "Finalizado"
	EndIf

Return(cDescri)

/***********************************************************************************
|----------------------------------------------------------------------------------|
|* Função     | _MSG                                            Data | 20/12/16 | *|
|----------------------------------------------------------------------------------|   
|* Autor      | 4Fx Soluções em Tecnologia                                        *|
|----------------------------------------------------------------------------------|
|* Descricao  | Função auxiliar para tratamento de quebra dos dados adicionais p/ *|
|*            | não ultrapassar o limite definido no layout.                      *|
|----------------------------------------------------------------------------------|
***********************************************************************************/

Static Function _MSG(_cObs,_nTam)

	Local _aMsg := {}
	Local _i    := 0

	_cObs := StrTran(_cObs, " ", ";")
	Do While At(";;", _cObs) != 0
		_cObs := StrTran(_cObs, ";;", ";")
	EndDo

	_aObs := {}
	Do While Len(_cObs) > 0
		If At(";", _cObs) != 0
			AADD(_aObs, SubStr(_cObs, 1, At(";", _cObs) -1))
			_cObs := Stuff(_cObs, 1, At(";", _cObs), "")
		Else
			AADD(_aObs, AllTrim(_cObs))
			_cObs := ""
		EndIf
	EndDo

	_cObs := ""
	For _i := 1 To Len(_aObs)
		If Len(_cObs + cValToChar(_aObs[_i])) > _nTam
			AADD(_aMsg, Padr(_cObs,_nTam))
			_cObs := _aObs[_i] + " "
		Else
			_cObs := _cObs + _aObs[_i] + " "
		EndIf
	Next _i

	If AllTrim(_cObs) != ""
		AADD(_aMsg, Padr(_cObs,_nTam))
	EndIf

Return _aMsg

Static Function fGerBat(_cPath,_cBat,_cCmdBat)
	Local __nHdl    := 0
	Local lRet := .T.

	If File(_cPath + _cBat )
		fErase(_cPath + _cBat )
	EndIf
	
	__nHdl := FCREATE(_cPath + _cBat )
	if __nHdl = -1
		lRet := .f.
	    conout("Erro ao criar arquivo .bat - ferror " + Str(Ferror()))
	else		
		FSeek(__nHdl,0,0)
		FWrite(__nHdl, _cCmdBat + CRLF, Len(_cCmdBat) + 2)
		FClose(__nHdl)
		conout(" << PT006SCH - Gerou o arquivo .bat no diretorio: "+_cPath+_cBat)
	endIf	
Return lRet

