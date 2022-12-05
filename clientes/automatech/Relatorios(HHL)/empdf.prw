#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
User Function fPrintPDF() 
	Local lAdjustToLegacy := .F.
	Local lDisableSetup  := .T.
	Local oPrinter
	Local cLocal          := "c:\simfrete\"
	Local cCodINt25 := "34190184239878442204400130920002152710000053475"
	Local cCodEAN :=      "123456789012"   
	Local cFilePrint := ""

	oPrinter := FWMSPrinter():New('orcamento_000000.PD_', IMP_PDF, lAdjustToLegacy,cLocal, lDisableSetup, , , , , , .F., )

	oPrinter:FWMSBAR("INT25" /*cTypeBar*/,1/*nRow*/ ,1/*nCol*/, cCodINt25/*cCode*/,oPrinter/*oPrint*/,.T./*lCheck*/,/*Color*/,.T./*lHorz*/,0.02/*nWidth*/,0.8/*nHeigth*/,.T./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,2/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/)
	oPrinter:FWMSBAR("EAN13" /*cTypeBar*/,5/*nRow*/ ,1/*nCol*/ ,cCodEAN  /*cCode*/,oPrinter/*oPrint*/,/*lCheck*/,/*Color*/,/*lHorz*/, /*nWidth*/,/*nHeigth*/,/*lBanner*/,/*cFont*/,/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,/*lCmtr2Pix*/)
	oPrinter:Box( 130, 10, 500, 700, "-4")
	oPrinter:Say(210,10,"Teste para Code128C")
	cFilePrint := cLocal+"orcamento_000000.PD_"
	File2Printer( cFilePrint, "PDF" )
        oPrinter:cPathPDF:= cLocal 
	oPrinter:Preview()
Return