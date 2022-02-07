#Include "CTBR440.Ch"
#Include "PROTHEUS.Ch"

#DEFINE TAM_VALOR  20
#DEFINE TAM_CONTA  20

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ CTBR440  ³ Autor ³ Cicero J. Silva   	³ Data ³ 04.08.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Razao Centro de Custo/Conta          			 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CTBR440()    											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum       											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso 		 ³ SIGACTB      											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
/*User Function _CTBR440(cCustoIni, cCustoFim, dDataIni, dDataFim, cMoeda, cSaldo,;
			cBook, cContaIni, cContaFim, lItem, cItemIni, cItemFim, lCLVL,;
			cCLVLIni, cCLVLFim,lSalLin,aSelFil)
*/

User Function _CTBR440(cCustoIni, cCustoFim, dDataIni, dDataFim, cMoeda, cSaldo,;
			cBook, cContaIni, cContaFim, lItem, cItemIni, cItemFim, lCLVL,;
			cCLVLIni, cCLVLFim,lSalLin,aSelFil)


Local aArea := GetArea()
Local aCtbMoeda		:= {}

Local lOk := .T.
Local lExterno		:= cContaIni <> Nil
Local lImpRazR4	:= FindFunction( "TRepInUse" ) .And. TRepInUse()

DEFAULT lItem		:= .F.
DEFAULT lCLVL		:= .F.
Default lSalLin		:= .T.
Default aSelFil	:= {}

PRIVATE cPerg	 	:= "CTR440"
PRIVATE nomeProg  	:= "CTBR440"
PRIVATE nSldTransp	:= 0 // Esta variavel eh utilizada para calcular o valor de transporte
Private lSaltLin:=.T.
Private nTamFilial := Len(CT2->CT2_FILIAL)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01            // do Centro de Custo                    ³
//³ mv_par02            // Ate Centro de Custo                   ³
//³ mv_par03            // da data                               ³
//³ mv_par04            // Ate a data                            ³
//³ mv_par05            // Moeda			                          ³   
//³ mv_par06            // Saldos		                          ³   
//³ mv_par07            // Set Of Books                          ³
//³ mv_par08            // Analitico ou Resumido dia (resumo)    ³
//³ mv_par09            // Imprime conta sem movimento?          ³
//³ mv_par10            // Imprime Cod (Normal / Reduzida)       ³
//³ mv_par11            // Totaliza tb por Conta?                ³
//³ mv_par12            // Da Conta                              ³
//³ mv_par13            // Ate a Conta                           ³
//³ mv_par14            // Imprime Item?	                       ³	
//³ mv_par15            // Do Item                               ³
//³ mv_par16            // Ate Item                              ³
//³ mv_par17            // Imprime Classe de Valor?              ³	
//³ mv_par18            // Da Classe de Valor                    ³
//³ mv_par19            // Ate a Classe de Valor                 ³
//³ mv_par20            // Salta folha por c.c.?                 ³
//³ mv_par21            // Pagina Inicial                        ³
//³ mv_par22            // Pagina Final                          ³
//³ mv_par23            // Numero da Pag p/ Reiniciar            ³
//³ mv_par24            // Imprime Cod. CCusto(Normal/Reduzido)  ³
//³ mv_par25            // Imprime Cod. Item (Normal/Reduzido)   ³
//³ mv_par26            // Imprime Cod. Cl.Valor(Normal/Reduzido)³	   	    
//³ mv_par27            // Imprime Valor 0.00						  ³	   	   
//³ mv_par28            // Salta linha            				     ³	   	   
//³ mv_par29            // Seleciona filiais ?				        ³	   	   
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


// Ajusta a pergunta 36 em possiveis clientes que ja tenham criado do tipo Range.
CtAjustSx1('CTR440') 

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	lOk := .F.
EndIf

If !lExterno .And. lOk
	If ! Pergunte(cPerg, .T.)
		lOk := .F.
	Endif
	// Se aFil nao foi enviada, exibe tela para selecao das filiais
	If lOk .And. mv_par29 == 1 .And. Len( aSelFil ) <= 0
		aSelFil := AdmGetFil()
		If Len( aSelFil ) <= 0
			lOk := .F.
		EndIf 
	EndIf  
Else
	Pergunte(cPerg, .F.)
Endif


If lOk
	//Verifica se o relatorio foi chamado a partir de outro programa. Ex. CTBC400
	If !lExterno
		lItem		:= Iif(mv_par14 == 1,.T.,.F.)
		lCLVL		:= Iif(mv_par17 == 1,.T.,.F.)
	Else  //Caso seja externo, atualiza os parametros do relatorio com os dados passados como parametros.
		mv_par01 := cCustoIni
		mv_par02 := cCustoFim
		mv_par03 := dDataIni
		mv_par04 := dDataFim
		mv_par05 := cMoeda
		mv_par06 := cSaldo
		mv_par07 := cBook
		mv_par12 := cContaIni
		mv_par13 := cContaFim
		mv_par14 := If(lItem, 1, 2)
		mv_par15 := cItemIni
		mv_par16 := cItemFim
		mv_par17 := If(lClVl, 1, 2)
		mv_par18 := cClVlIni
		mv_par19 := cClVlFim  
		MV_PAR28 := Iif(lSalLin == .T.,1,2)
	Endif

	aCtbMoeda  	:= CtbMoeda(mv_par05) // Moeda?

	If Empty(aCtbMoeda[1])
    	Help(" ",1,"NOMOEDA")
		lOk := .F.
	Endif
Endif 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
//³ Gerencial -> montagem especifica para impressao)			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! Empty( mv_par07 ) 
	If ! VdSetOfBook( mv_par07 , .F. )
		lOk := .F.
	Endif
Endif
	
If lOk
	If lImpRazR4
		_CTBR4R4(aCtbMoeda,lItem,lCLVL,aSelFil)

	Else
		_CTBR4R3(cCustoIni, cCustoFim, dDataIni, dDataFim, cMoeda, cSaldo,;
				cBook, cContaIni, cContaFim, lItem, cItemIni, cItemFim, lCLVL,;
				cCLVLIni, cCLVLFim,lSalLin,aSelFil)
	Endif
EndIf

If Select("cArqTmp") > 0
		dbSelectArea("cArqTmp")
		Set Filter To
		dbCloseArea()

		If Select("cArqTmp") == 0
			FErase(cArqTmp+GetDBExtension())
			FErase(cArqTmp+OrdBagExt())
		EndIf
EndIf	

RestArea(aArea)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CTBR440R4 º Autor ³                    º Data ³  15/09/09  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Impressao do relatorio em R4                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACTB                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function _CTBR4R4(aCtbMoeda,lItem,lCLVL,aSelFil)
Local oReport := Nil 

oReport := _ReportDef(aCtbMoeda,lItem,lCLVL,aSelFil)
oReport:PrintDialog() 
oReport := Nil  

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ReportDef º Autor ³ Cicero J. Silva    º Data ³  01/08/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Definicao do objeto do relatorio personalizavel e das      º±±
±±º          ³ secoes que serao utilizadas                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aCtbMoeda  - Matriz ref. a moeda                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACTB                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function _ReportDef(aCtbMoeda,lItem,lCLVL,aSelFil)

Local oReport
Local oSection1
Local oSection2 
Local oSection3 

Local cSayCusto		:= CtbSayApro("CTT")
Local cSayItem		:= CtbSayApro("CTD")
Local cSayClVl		:= CtbSayApro("CTH")

Local cDesc1		:= STR0001+Alltrim(cSayCusto) 	//"Este programa ir  imprimir o Razao Contabil por "
Local cDesc2		:= STR0002	//"de Custo de acordo com os parametros solicitados"
Local cDesc3		:= STR0003	//"pelo usuario"
Local titulo		:= STR0006 + Alltrim(cSayCusto)	//"Emissao do Razao Contabil por Centro de Custo"

Local lAnalitico	:= Iif(mv_par08==1,.T.,.F.)// Analitico ou Resumido dia (resumo)
Local lPrintZero	:= IIf(mv_par27==1,.T.,.F.)// Imprime valor 0.00    ?
Local lSalto		:= Iif(mv_par20==1,.T.,.F.)// Salto de pagina                       ³

Local aSetOfBook := CTBSetOf(mv_par07)// Set Of Books	

Local cSepara1		:= ""
Local cSepara2		:= ""
Local cSepara3		:= ""
Local cSepara4		:= ""

// Mascara da Conta
Local cMascara1 := IIf ( Empty(aSetOfBook[2]),GetMv("MV_MASCARA"),RetMasCtb(aSetOfBook[2],@cSepara1) )
// Mascara do Centro de Custo
Local cMascara2 := IIf ( Empty(aSetOfBook[6]),GetMv("MV_MASCCUS"),RetMasCtb(aSetOfBook[6],@cSepara2) )
// Mascara do Item Contabil
Local cMascara3 := IIf ( lItem .And. Empty(aSetOfBook[7]),ALLTRIM(STR(Len(CTD->CTD_ITEM))) , RetMasCtb(aSetOfBook[7],@cSepara3) )
// Mascara da Classe de Valor
Local cMascara4 := IIf ( lCLVL .And. Empty(aSetOfBook[8]) , ALLTRIM(STR(Len(CTH->CTH_CLVL))) , RetMasCtb(aSetOfBook[8],@cSepara4) )

Local aTamCusto	:= TAMSX3("CT3_CUSTO")
Local nTamConta	:= 5 + TamCpoMask( "CT1_CONTA" , cMascara1 ) // Len(CriaVar("CT1_CONTA"))
Local nTamCusto	:= 5 + TamCpoMask( "CT3_CUSTO" , cMascara2 ) // Len(CriaVar("CT3_CUSTO"))
Local nTamItem	:= 5 + TamCpoMask( "CTD_ITEM"  , cMascara3 ) // Len(CriaVar("CTD_ITEM"))
Local nTamCLVL	:= 5 + TamCpoMask( "CTH_CLVL"  , cMascara4 ) // Len(CriaVar("CTH_CLVL"))

Local nTamHist	:= 50 // chumbo o tamanho do historico para não dar problema na impressão do relatorio

Local cPicture 		:= aSetOfBook[4]
Local cDescMoeda 	:= aCtbMoeda[2]
Local nDecimais 	:= DecimalCTB(aSetOfBook,mv_par05)// Moeda


oReport := TReport():New(nomeProg,titulo,cPerg, {|oReport| ;//			Pergunte(cPerg,.F.),;
			Iif( ReportPrint(oReport,aCtbMoeda,aSetOfBook,cPicture,cDescMoeda,nDecimais,nTamConta,lAnalitico,lItem,lCLVL,aSelFil), .T., oReport:CancelPrint())},cDesc1+cDesc2+cDesc3)

oReport:SetTotalInLine(.F.)
oReport:EndPage(.T.)

IF GETNEWPAR("MV_CTBPOFF",.T.)
	oReport:SetEdit(.F.)
ENDIF	

If lAnalitico
	oReport:SetLandScape(.T.)
	oReport:lDisableOrientation := .T.  // Desabilita a alteração da orientação do papel, evitando desalinhamento por falta de espaço
Else
	oReport:SetPortrait(.T.)
EndIf
	
	
// oSection1
oSection1 := TRSection():New(oReport,STR0027,{"cArqTmp"},/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/)	//"Conta" 

If lSalto
	oSection1:SetPageBreak(.T.)
EndIf

TRCell():New(oSection1,"CUSTO"		,"cArqTmp",Upper(STR0028),/*Picture*/,nTamCusto + 5 ,/*lPixel*/,/*{|| }*/)
TRCell():New(oSection1,"DESCCC"	    ,""		  ,,/*Picture*/,70 + nTamconta + nTamItem + nTamCLVL + (TAM_VALOR * 2) - nTamCusto,/*lPixel*/,/*{|| }*/,/*"RIGHT"*/,.T.,/*"RIGHT"*/,,,.T.)	//"DESCRICAO"
TRCell():New(oSection1,"TPSLDANT"	,""       ,STR0026,/*Picture*/, TAM_VALOR+4	,/*lPixel*/,/*{|| }*/,/*"RIGHT"*/,,"RIGHT")// Sinal do Saldo Atual => Consulta Razao	 ### "SALDO ATERIOR"
oSection1:Cell("DESCCC"):HideHeader()

// oSection2
oSection2 := TRSection():New(oReport,STR0028,{"cArqTmp","CT2"},/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/)	// Custo
oSection2:SetTotalInLine(.F.)
oSection2:SetHeaderPage(.T.)

TRCell():New(oSection2,"DATAL"		,"cArqTmp" ,STR0019			,/*Picture*/ ,10			,/*lPixel*/ ,/*{|| }*/)// Data do Lancamento
TRCell():New(oSection2,"DOCUMENTO"	,""        ,STR0029			,/*Picture*/ ,20			,/*lPixel*/ ,{|| cArqTmp->LOTE+cArqTmp->SUBLOTE+cArqTmp->DOC+cArqTmp->LINHA })//"LOTE/SUB/DOC/LINHA"
TRCell():New(oSection2,"FILIAL"		,""        ,"FL"			,/*Picture*/ ,nTamFilial	,/*lPixel*/ ,{|| cArqTmp->FILIAL})//"FILIAL"
TRCell():New(oSection2,"HISTORICO"	,"cArqTmp" ,STR0030			,/*Picture*/ ,nTamHist		,/*lPixel*/ ,{||cArqTmp->HISTORICO },/*"RIGHT"*/,.T.,/*"RIGHT"*/,,,.T.)// Historico
TRCell():New(oSection2,"XPARTIDA"	,"cArqTmp" ,STR0031			,/*Picture*/ ,nTamConta 	,/*lPixel*/ ,/*{|| }*/)// Contra Partida
TRCell():New(oSection2,"ITEM"		,"cArqTmp" ,Upper(cSayItem) ,/*Picture*/ ,nTamItem  	,/*lPixel*/ ,/*{|| }*/)// Item Contabil
TRCell():New(oSection2,"CLVL"		,"cArqTmp" ,Upper(cSayClVl) ,/*Picture*/ ,nTamCLVL  	,/*lPixel*/ ,/*{|| }*/)// Classe de Valor
TRCell():New(oSection2,"LANCDEB"	,"cArqTmp" ,STR0032			,/*Picture*/ ,TAM_VALOR		,/*lPixel*/ ,{|| ValorCTB(cArqTmp->LANCDEB,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.) },/*"RIGHT"*/,,"RIGHT")// Debito
TRCell():New(oSection2,"LANCCRD"	,"cArqTmp" ,STR0033			,/*Picture*/ ,TAM_VALOR		,/*lPixel*/ ,{|| ValorCTB(cArqTmp->LANCCRD,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) },/*"RIGHT"*/,,"RIGHT")// Credito
TRCell():New(oSection2,"TPSLDATU"	,"cArqTmp" ,STR0034			,/*Picture*/ ,TAM_VALOR+4	,/*lPixel*/ ,/*{|| }*/,/*"RIGHT"*/,,"RIGHT")// Sinal do Saldo Atual => Consulta Razao ### SALDO ATUAL

oSection2:Cell("LANCDEB"	):lHeaderSize	:= .F.
oSection2:Cell("LANCCRD"	):lHeaderSize	:= .F.
oSection2:Cell("TPSLDATU"	):lHeaderSize	:= .F.                           

If lAnalitico         
	If !lItem
		oSection2:Cell("ITEM"	):Hide()
		oSection2:Cell("ITEM"	):HideHeader() 
	EndIf
	If !lCLVL
		oSection2:Cell("CLVL"	):Hide()
		oSection2:Cell("CLVL"	):HideHeader() 
	EndIf
	oSection2:Cell("DATAL"		):lHeaderSize	:= .F.
	oSection2:Cell("DOCUMENTO"	):lHeaderSize	:= .F.
	oSection2:Cell("FILIAL"		):lHeaderSize	:= .F.
	oSection2:Cell("HISTORICO"	):lHeaderSize	:= .F.
	oSection2:Cell("XPARTIDA"	):lHeaderSize	:= .F.
	oSection2:Cell("ITEM"		):lHeaderSize	:= .F.
	oSection2:Cell("CLVL"		):lHeaderSize	:= .F.
	
Else // Resumido
	oSection2:Cell("ITEM"	):Hide()
	oSection2:Cell("ITEM"	):HideHeader() 
	oSection2:Cell("CLVL"	):Hide()
	oSection2:Cell("CLVL"	):HideHeader() 

//	oSection2:Cell("HISTORICO"	):Disable()
	oSection2:Cell("DOCUMENTO"	):Hide()
	oSection2:Cell("DOCUMENTO"	):HideHeader() 
	oSection2:Cell("XPARTIDA"	):Hide()
	oSection2:Cell("XPARTIDA"	):HideHeader()
	oSection2:Cell("HISTORICO"	):Hide()
	oSection2:Cell("HISTORICO"	):HideHeader()
	
EndIf

// oSection3 - Totais das sessoes	
oSection3 := TRSection():New( oReport,STR0035,,, .F., .F. )	// Total
TRCell():New(oSection3,"TOT"		,"" ,		 ,/*Picture*/ , 75 + nTamConta + nTamItem + nTamCLVL,/*lPixel*/,/*{|| code-block de impressao }*/,/*"RIGHT"*/,.T.,/*"RIGHT"*/,,,.T.)
TRCell():New(oSection3,"TOT_DEBITO"	,""	,STR0032 ,/*Picture*/ ,TAM_VALOR,/*lPixel*/,/*{|| code-block de impressao }*/,/*"RIGHT"*/,,"RIGHT")	//"CREDITO"
TRCell():New(oSection3,"TOT_CREDITO","" ,STR0033 ,/*Picture*/ ,TAM_VALOR,/*lPixel*/,/*{|| code-block de impressao }*/,/*"RIGHT"*/,,"RIGHT")	//"DEBITO"
TRCell():New(oSection3,"TOT_ATU"	,"" ,STR0034 ,/*Picture*/ ,TAM_VALOR+4,/*lPixel*/,/*{|| code-block de impressao }*/,/*"RIGHT"*/,,"RIGHT")	// "SALDO ATUAL"

oSection3:Cell( "TOT_DEBITO"	):HideHeader() 
oSection3:Cell( "TOT_CREDITO"	):HideHeader() 
oSection3:Cell( "TOT_ATU"		):HideHeader() 

// oSection4 - Transporte	
oSection4 := TRSection():New( oReport,"Transporte",,, .F., .F. )	// Total
TRCell():New(oSection4,"CTRANSP"	,"" ,		 ,/*Picture*/ , 75 + nTamConta + nTamItem + nTamCLVL + (TAM_VALOR * 2),/*lPixel*/,/*{|| code-block de impressao }*/,/*"RIGHT"*/,.T.,/*"RIGHT"*/,,,.T.)
TRCell():New(oSection4,"TVLTRANSP"	,"" ,		 ,/*Picture*/ ,TAM_VALOR+4,/*lPixel*/,/*{|| code-block de impressao }*/,/*"RIGHT"*/,,"RIGHT")	// "SALDO ATUAL"
oSection4:SetHeaderSection(.F.) 

oSection1:SetEdit(.F.)
oSection2:SetEdit(.F.)
oSection3:SetEdit(.F.)
oSection4:SetEdit(.T.) 

oReport:ParamReadOnly()

Return oReport

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportPrintº Autor ³ Cicero J. Silva    º Data ³  14/07/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Definicao do objeto do relatorio personalizavel e das      º±±
±±º          ³ secoes que serao utilizadas                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function _ReportPrint(oReport,aCtbMoeda,aSetOfBook,cPicture,cDescMoeda,nDecimais,nTamConta,lAnalitico,lItem,lCLVL,aSelFil)

Local oSection1 	:= oReport:Section(1)
Local oSection2		:= oReport:Section(2)
Local oSection3		:= oReport:Section(3)  
Local oSection4		:= oReport:Section(4)

Local cArqTmp		:= ""
Local cFiltro		:= oSection2:GetAdvplExp()

Local cSayCusto		:= CtbSayApro("CTT")
Local cSayItem		:= CtbSayApro("CTD")
Local cSayClVl		:= CtbSayApro("CTH")

Local aSaldo		:= {}
Local aSaldoAnt		:= {}

Local cContaIni		:= mv_par12 // da conta
Local cContaFIm		:= mv_par13 // ate a conta
Local cMoeda		:= mv_par05 // Moeda
Local cSaldo		:= mv_par06 // Saldos
Local cCustoIni		:= mv_par01 // Do Centro de Custo
Local cCustoFim		:= mv_par02 // At‚ o Centro de Custo
Local cItemIni		:= mv_par15 // Do Item 
Local cItemFim		:= mv_par16 // Ate Item 
Local cCLVLIni		:= mv_par18 // Imprime Classe de Valor?
Local cCLVLFim		:= mv_par19 // Ate a Classe de Valor       
Local lSalLin		:= IIf(MV_PAR28==1,.T.,.F.)//"Salta linha entre contas?"
Local cContaAnt		:= ""
Local cCodRes		:= ""
Local cResCC		:= ""
Local cResItem		:= ""
Local cResCLVL		:= ""

Local cConta		:= ""

Local cSepara1		:= ""
Local cSepara2		:= ""
Local cSepara3		:= ""
Local cSepara4		:= ""
// Mascara da Conta
Local cMascara1 := IIf (Empty(aSetOfBook[2]),GetMv("MV_MASCARA"),RetMasCtb(aSetOfBook[2],@cSepara1) )
// Mascara do Centro de Custo
Local cMascara2 := IIf ( Empty(aSetOfBook[6]),GetMv("MV_MASCCUS"),RetMasCtb(aSetOfBook[6],@cSepara2) )
// Mascara do Item Contabil
Local cMascara3 := IIf ( lItem .And. Empty(aSetOfBook[7]),ALLTRIM(STR(Len(CTD->CTD_ITEM))) , RetMasCtb(aSetOfBook[7],@cSepara3) )
// Mascara da Classe de Valor
Local cMascara4 := IIf ( lCLVL .And. Empty(aSetOfBook[8]) , ALLTRIM(STR(Len(CTH->CTH_CLVL))) , RetMasCtb(aSetOfBook[8],@cSepara4) )

Local dDataAnt		:= CTOD("  /  /  ")
Local dDataIni		:= mv_par03 // da data
Local dDataFim		:= mv_par04 // Ate a data

Local nReinicia 	:= mv_par23 // Numero da Pag p/ Reiniciar 
Local nPagFim		:= mv_par22 // Pagina Final 
Local nTamCusto:= Len(CriaVar("CTT->CTT_DESC"+mv_par05))

Local nTotDeb		:= 0
Local nTotCrd		:= 0
Local nTotDebG		:= 0
Local nTotCrdG		:= 0

Local nVlrDeb		:= 0
Local nVlrCrd		:= 0
Local nTotCtaDeb	:= 0
Local nTotCtaCrd	:= 0

Local lNoMov		:= Iif(mv_par09==1,.T.,.F.) // Imprime conta sem movimento?
Local lPrintZero	:= Iif(mv_par27==1,.T.,.F.) // Imprime valor 0.00    ?
Local lEmissUnica	:= If(GetNewPar("MV_CTBQBPG","M") == "M",.T.,.F.)			/// U=Quebra única (.F.) ; M=Multiplas quebras (.T.)
Local lOk			:= .T.
Local cNormal 		:= ""

Local nTamItem	:= 5 + TamCpoMask( "CTD_ITEM"  , cMascara3 ) // Len(CriaVar("CTD_ITEM"))
Local nTamCLVL	:= 5 + TamCpoMask( "CTH_CLVL"  , cMascara4 ) // Len(CriaVar("CTH_CLVL"))
Local nTamHist	:= 50 // chumbo o tamanho do historico para não dar problema na impressão do relatorio

Local cFilOld := cFilAnt
Local cArq
Local nX
Local cFil := ""
Local cFilRazao,cFilAuxStr		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Titulo do Relatorio                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("NewHead")== "U"
	Titulo	:=	STR0007	+ Upper(Alltrim(cSayCusto))//"RAZAO POR "
	IF lAnalitico
		Titulo	+=  STR0008 	//"ANALITICO EM"
	Else                    	
		Titulo	+=	STR0014		//"SINTETICO EM"
	EndIf
	Titulo += 	cDescMoeda + space(01)+STR0009 + space(01)+DTOC(dDataIni) +;	// "DE"
				space(01)+STR0010 + space(01)+ DTOC(dDataFim)						// "ATE"
	
	If mv_par06 > "1"
		Titulo += " (" + Tabela("SL", mv_par06, .F.) + ")"
	EndIf
Else
	Titulo := NewHead
EndIf

oReport:SetTitle(Titulo)
oReport:SetPageNumber(mv_par21) //mv_par21	-	Pagina Inicial
oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataFim,oReport:Title(),,,,,oReport) } )
          
If lAnalitico
	If !lItem
		oSection2:Cell("ITEM"):Hide()
		oSection2:Cell("ITEM"):HideHeader() 
		oSection2:Cell("ITEM"):SetBlock( { || " " } )

	EndIf
	If !lCLVL
		oSection2:Cell("CLVL"):Hide()
		oSection2:Cell("CLVL"):HideHeader() 
		oSection2:Cell("CLVL"):SetBlock( { || " " } )
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao							  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
				CTBGerRaz(oMeter,oText,oDlg,lEnd,@cArqTmp,cContaIni,cContaFim,cCustoIni,cCustoFim,;
							 cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
							 aSetOfBook,lNoMov,cSaldo,.t.,"2",lAnalitico,,,cFiltro,,aSelFil)},;
				STR0018,;		// "Criando Arquivo Temporario..."
				STR0006 + Alltrim(cSayCusto))						// "Emissao do Razao"

dbSelectArea("cArqTmp")
dbSetOrder(1)
dbGoTop()
oReport:SetMeter( RecCount() )
oReport:NoUserFilter()

//Se tiver parametrizado com Plano Gerencial, exibe a mensagem que o Plano Gerencial 
//nao esta disponivel e sai da rotina.
lOk := !(cArqTmp->(RecCount()) == 0 .And. !Empty(aSetOfBook[5]))
If lOk
	While !cArqTmp->(Eof() .And. !oReport:Cancel())
		
		cFilAnt := cArqTmp->FILORI
		
		If oReport:Cancel()
    		Exit
		EndIf        
	  	oSection1:Init()       
		   
		// Calcula o saldo anterior do centro de custo atual
		aSaldoAnt	:= SaldTotCT3(cArqTmp->CCUSTO,cArqTmp->CCUSTO,cContaIni,cContaFim,dDataIni,cMoeda,cSaldo,aSelFil)
		aSaldo		:= SaldTotCT3(cArqTmp->CCUSTO,cArqTmp->CCUSTO,cContaIni,cContaFim,cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)

		If f440Fil(lNoMov,aSaldo,dDataIni)
			dbSkip()
			Loop
		EndIf

		nSaldoAtu:= 0
		nTotDeb	:= 0
		nTotCrd	:= 0                              

		// Conta Sintetica	
		dbSelectArea("CTT")
		dbSetOrder(1)
		dbSeek(xFilial()+cArqTMP->CCUSTO)  
		cResCC := CTT->CTT_RES
		
		oSection1:Cell("CUSTO"):SetTitle(Upper(Alltrim(cSayCusto)))
		If mv_par24 == 1// Imprime Codigo Normal de Centro de Custo
			oSection1:Cell("CUSTO"):SetBlock( { || EntidadeCTB(cArqTmp->CCUSTO,0,0,nTamCusto,.F.,cMascara2,cSepara2,,,,,.F.) } )
		Else
			oSection1:Cell("CUSTO" ):SetBlock( { || EntidadeCTB(cResCC,0,0,Len(cResCC),.F.,cMascara2,cSepara2,,,,,.F.) } )
		Endif
		oSection1:Cell("DESCCC"):SetBlock( { || " - " + CtbDescMoeda("CTT->CTT_DESC"+cMoeda) } )
		oSection1:Cell("TPSLDANT"):SetTitle(STR0026)
		oSection1:Cell("TPSLDANT"):SetBlock( { || ValorCTB(aSaldoAnt[6],,,TAM_VALOR+4,nDecimais,.T.,cPicture,	cNormal ,,,,,,lPrintZero,.F.) } )

		oSection4:Cell("CTRANSP"):SetBlock( { || Iif(oReport:PageBreak(),STR0023,STR0022) } )	
		oSection4:Cell("TVLTRANSP"):SetBlock( { || ValorCTB(nSldTransp,,,TAM_VALOR+4,nDecimais,.T.,cPicture,cNormal,,,,,,lPrintZero,.F.) } )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Impressao do Saldo Anterior do Centro de Custo³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSection1:PrintLine()
		
		nSaldoAtu := aSaldoAnt[6]                                           
		
		dbSelectArea("cArqTmp")		
		
	    oReport:SetPageFooter(10, {|| Iif(nSldTransp != 0, (oSection4:Init(),oSection4:PrintLine()),) } ) // A TRANSPORTAR
		oReport:OnPageBreak( {|| Iif(nSldTransp != 0, (oSection4:printline(),oReport:SkipLine(),oSection4:Finish()),) } )      // DE TRANSPORTE
        
		cFilRazao := cArqTmp->FILIAL
		cCustoAnt := cArqTmp->CCUSTO
		
	   	oSection2:Init()                            

		While !oReport:Cancel() .And. cArqTmp->( !Eof() .And. FILIAL+CCUSTO == cFilRazao+cCustoAnt )
		
			If oReport:Cancel()
				Exit
			EndIf

			cContaAnt	:= cArqTmp->CONTA
			dDataAnt	:= cArqTmp->DATAL

	  		If lItem .or. lClvl .Or. Empty(cArqTmp->FILIAL)
				cFilAuxStr := ""
			Else
				cFilAuxStr := STR0037+":"+cArqTmp->FILIAL+Space(1)
			EndIf

			If lAnalitico
			
				nTotCtaDeb  := 0
				nTotCtaCrd	:= 0
				If ! Empty(cArqTmp->CONTA)

					cConta := cFilAuxStr+STR0024 //"CONTA - "	

					dbSelectArea("CT1")
					dbSetOrder(1)
					If MsSeek(xFilial("CT1")+cArqTMP->CONTA,.T.)
						cCodRes := CT1->CT1_RES
						cNormal := CT1->CT1_NORMAL
						If mv_par10 == 1 // Imprime Codigo de Impressao
							cConta += EntidadeCTB(cArqTmp->CONTA,0,0,nTamConta,.F.,cMascara1,cSepara1,,,,,.F.)
						Else // Caso contrário usa codigo reduzido
							cConta += EntidadeCTB(cCodRes,0,0,nTamConta,.F.,cMascara1,cSepara1,,,,,.F.)
						EndIf
						cConta += CtbDescMoeda("CT1->CT1_DESC"+cMoeda)
					Endif
				EndIf	

				oReport:PrintText(cConta)

				If lSalLin
					oReport:SkipLine()
				Endif
			    			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³INICIO DA 2a SECAO³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("cArqTmp")

				While !oReport:Cancel() .And. cArqTmp->(!Eof() .And. FILIAL+CCUSTO+CONTA == cFilRazao+cCustoAnt+cContaAnt )
                                                  
					If oReport:Cancel()
						Exit
					EndIf	

					oReport:IncMeter()

   					nSaldoAtu 	:= nSaldoAtu - cArqTmp->LANCDEB + cArqTmp->LANCCRD
					nTotDeb		+= cArqTmp->LANCDEB
					nTotCrd		+= cArqTmp->LANCCRD
					nTotCtaDeb	+= cArqTmp->LANCDEB
					nTotCtaCrd	+= cArqTmp->LANCCRD			
					
					If dDataAnt <> cArqTmp->DATAL 
						oSection2:Cell("DATAL"):SetBlock( { || cArqTmp->DATAL } )
						dDataAnt := cArqTmp->DATAL    
					Else
						oSection2:Cell("DATAL"):SetBlock( { || dDataAnt } )
					EndIf	

					dbSelectArea("CT1")
					dbSetOrder(1)
					MsSeek(xFilial("CT1")+cArqTmp->XPARTIDA)
					cCodRes := CT1->CT1_RES
					dbSelectArea("cArqTmp")
					
					If mv_par10 == 1 // Impr Cod (Normal/Reduzida/Cod.Impress)
						oSection2:Cell("XPARTIDA"):SetBlock( { || EntidadeCTB(cArqTmp->XPARTIDA,0,0,nTamConta,.F.,cMascara1,cSepara1,,,,,.F.) } )
					Else
						oSection2:Cell("XPARTIDA"):SetBlock( { || EntidadeCTB(cCodRes,0,0,TAM_CONTA,.F.,cMascara1,cSepara1,,,,,.F.) } )
					Endif
						
					If lItem 						//Se imprime item 
//						If mv_par25 == 1 //Imprime Codigo Normal Item Contabl
//							oSection2:Cell("ITEM"):SetBlock( { || EntidadeCTB(cArqTmp->ITEM,0,0,TAM_CONTA,.F.,cMascara3,cSepara3,,,,,.F.) } )
//						Else
							dbSelectArea("CTD")
							dbSetOrder(1)
							dbSeek(xFilial("CTD")+cArqTmp->ITEM)				
//							cResItem := CTD->CTD_RES
							cResItem := CTD->CTD_DESC01 //Leonel
							oSection2:Cell("ITEM"):SetBlock( { || EntidadeCTB(cResItem,0,0,TAM_CONTA,.F.,cMascara3,cSepara3,,,,,.F.) } )
							dbSelectArea("cArqTmp")					
//						Endif
					Endif
					If lCLVL //Se imprime classe de valor
						If mv_par26 == 1 //Imprime Cod. Normal Classe de Valor
							oSection2:Cell("CLVL"):SetBlock( { || EntidadeCTB(cArqTmp->CLVL,0,0,TAM_CONTA,.F.,cMascara4,cSepara4,,,,,.F.) } )
						Else
							dbSelectArea("CTH")
							dbSetOrder(1)
							dbSeek(xFilial("CTH")+cArqTmp->CLVL)				
							cResClVl := CTH->CTH_RES						
							oSection2:Cell("CLVL"):SetBlock( { || EntidadeCTB(cResClVl,0,0,TAM_CONTA,.F.,cMascara4,cSepara4,,,,,.F.) } )
							dbSelectArea("cArqTmp")					
						Endif			
					Endif

					// Sinal do Saldo Atual => Consulta Razao
					oSection2:Cell("TPSLDATU"):SetBlock( { || ValorCTB(nSaldoAtu,,,TAM_VALOR+4,nDecimais,.T.,cPicture,cNormal,,,,,,lPrintZero,.F.) })
                              
					oSection2:PrintLine()
					nSldTransp := nSaldoAtu  
                    
					//ImpCompl(oReport) //FJC
					ImpCompl( oSection2 )
				    
				    lTotConta := ! Empty(cArqTmp->CONTA)
					dbSelectArea("cArqTmp")
					dDataAnt := cArqTmp->DATAL		
					dbSkip()
				EndDo //cArqTmp->(!Eof() .And. FILIAL+CCUSTO+CONTA == cFilRazao+cCustoAnt+cContaAnt )

				If lTotConta .And. mv_par11 == 1	// Totaliza tb por Conta
					
		   			oSection3:Init() // oSection3 - Totalizadora
			    
					//oSection3:Cell("TOT"):SetTitle(OemToAnsi(STR0020))//"T o t a i s  d a  C o n t a  ==> " 	    
					oSection3:Cell("TOT"):SetTitle(Space(10))//"          " 	    
					oSection3:Cell("TOT"):SetBlock( { || OemToAnsi(STR0020) } )//"T o t a i s  d a  C o n t a  ==> " 	    
					oSection3:Cell("TOT_DEBITO"	 ):SetBlock( { || ValorCTB(nTotCtaDeb,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.) } )
					oSection3:Cell("TOT_CREDITO" ):SetBlock( { || ValorCTB(nTotCtaCrd,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) } )

					// Imprime totalizado

					oSection3:PrintLine()         
					oReport:SkipLine() 
			
					oSection3:Finish()  
					nSldTransp := nSaldoAtu  
				
					nTotCtaDeb := 0
					nTotCtaCrd := 0
				
				EndIf	

			Else // !lAnalitico	 -- Se for resumido.                               			
				oReport:IncMeter()
						
				dbSelectArea("cArqTmp")
				If ! Empty(cArqTmp->CONTA)
					CT1->(dbSeek(xFilial()+cArqTmp->CONTA))
					cCodRes := CT1->CT1_RES
					cNormal := CT1->CT1_NORMAL
				Else
					cNormal := ""
				Endif
						
				While !oReport:Cancel() .And.  cArqTmp->( ! Eof() .And. dDataAnt == DATAL .And. FILIAL+CCUSTO == cFilRazao+cCustoAnt )
					If oReport:Cancel()
						Exit
					EndIf	
					nVlrDeb	+= cArqTmp->LANCDEB		                                         
					nVlrCrd	+= cArqTmp->LANCCRD		                                         
					dbSkip()                                                                    				
				EndDo		   
						
				nSaldoAtu	:= nSaldoAtu - nVlrDeb + nVlrCrd
				
				oSection2:Cell("LANCDEB"):SetBlock( { || ValorCTB(nVlrDeb,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.) })// Debito
				oSection2:Cell("LANCCRD"):SetBlock( { || ValorCTB(nVlrCrd,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) })// Credito
				oSection2:Cell("TPSLDATU"):SetBlock( { || ValorCTB(nSaldoAtu,,,TAM_VALOR+4,nDecimais,.T.,cPicture,cNormal,,,,,,lPrintZero,.F.) })// Sinal do Saldo Atual => Consulta Razao			

				//Imprime Section(1) - resumida.
			
				oSection2:PrintLine()  
				nSldTransp := nSaldoAtu 

				nTotDeb	+= nVlrDeb
				nTotCrd	+= nVlrCrd         
				nVlrDeb	:= 0
				nVlrCrd	:= 0
			Endif // lAnalitico		   			

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³FIM DA 2a SECAO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        EndDo //cArqTmp->( !Eof() .And. FILIAL+CCUSTO == cFilRazao+cCustoAnt )

		oSection2:Finish()        
        
        
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³INICIO DA 3a SECAO - Totais da Conta ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ! oReport:Cancel()
			cCCusto := "( "
			If lAnalitico
				If mv_par24 == 1 // Se imprime cod. normal de Centro de Custo
					cCCusto += EntidadeCTB(cCustoAnt,0,0,nTamCusto,.F.,cMascara2,cSepara2,,,,,.F.)
				Else
					dbSelectArea("CTT")
					dbSetOrder(1)
					dbSeek(xFilial()+cCustoAnt)  
					cResCC := CTT->CTT_RES
					cCCusto += EntidadeCTB(cResCC,0,0,nTamCusto,.F.,cMascara2,cSepara2,,,,,.F.)
				Endif
			Else
				If mv_par24 == 1
					cCCusto += EntidadeCTB(cCustoAnt,0,0,nTamCusto,.F.,cMascara2,cSepara2,,,,,.F.)
				Else
					dbSelectArea("CTT")
					dbSetOrder(1)
					dbSeek(xFilial()+cCustoAnt)  
					cResCC := CTT->CTT_RES
					cCCusto += EntidadeCTB(cResCC,0,0,nTamCusto,.F.,cMascara2,cSepara2,,,,,.F.)
				Endif
			Endif
			cCCusto +=" )"
			
			oSection3:Cell("TOT"):SetTitle(STR0017+ Upper(Alltrim(cSayCusto)) + " ==> "+cCCusto)//"T o t a i s  d o  C e n t r o  d e  C u s t o  ==> " 			
			oSection3:Cell("TOT_DEBITO"	    ):SetBlock(	{ || ValorCTB(nTotDeb  ,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.) } )
			oSection3:Cell("TOT_CREDITO" 	):SetBlock(	{ || ValorCTB(nTotCrd  ,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) } )
			oSection3:Cell("TOT_ATU"		):SetBlock(	{ || ValorCTB(nSaldoAtu,,,TAM_VALOR+4,nDecimais,.T.,cPicture,cNormal,,,,,,lPrintZero,.F.) } )

			// Imprime totalizado
			oSection3:Init()
			nSldTransp := 0
			oSection3:PrintLine()  
			oSection3:Finish()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³FIM DA 3a SECAO - Totais da Conta³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		EndIf
		oSection1:Finish()        
	EndDo //lImpLivro .And. !cArqTmp->(Eof())

	oReport:SetPageFooter( 0, {||.T.})
	oReport:OnPageBreak( {|| .T.})
EndIf //!(cArqTmp->(RecCount()) == 0 .And. !Empty(aSetOfBook[5]))

cFilAnt := cFilOld
dbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()

If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIf	

dbselectArea("CT2")

Return lOk

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpCompl  ºAutor  ³Cicero J. Silva     º Data ³  27/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a descricao, da conta contabil, item, centro de     º±±
±±º          ³custo ou classe valor                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBR390                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _ImpCompl(oSection2)
	
	oSection2:Cell("DATAL"		):Hide()
	oSection2:Cell("DOCUMENTO"	):Hide()
	//oSection2:Cell("HISTORICO"	):Hide()
	oSection2:Cell("XPARTIDA"	):Hide()
	oSection2:Cell("ITEM"		):Hide()
	oSection2:Cell("CLVL"		):Hide()
	oSection2:Cell("LANCDEB"	):Hide()
	oSection2:Cell("LANCCRD"	):Hide()
	oSection2:Cell("TPSLDATU"	):Hide()


	
	// Procura pelo complemento de historico
	dbSelectArea("CT2")               
	dbSetOrder(10)
	If MsSeek(xFilial("CT2")+cArqTMP->(DTOS(DATAL)+LOTE+SUBLOTE+DOC+SEQLAN+EMPORI+FILORI),.F.)
		dbSkip()

		If CT2->CT2_DC == "4"			//// TRATAMENTO PARA IMPRESSAO DAS CONTINUACOES DE HISTORICO
			While !CT2->(Eof()) .And.;
					CT2->CT2_FILIAL == xFilial("CT2") .And.;
					 CT2->CT2_LOTE == cArqTMP->LOTE .And.;
					  CT2->CT2_SBLOTE == cArqTMP->SUBLOTE .And.;
					   CT2->CT2_DOC == cArqTmp->DOC .And.;
						CT2->CT2_SEQLAN == cArqTmp->SEQLAN .And.;
						 CT2->CT2_EMPORI == cArqTmp->EMPORI .And.;
						  CT2->CT2_FILORI == cArqTmp->FILORI .And.;
						   CT2->CT2_DC == "4" .And.;
				    	    DTOS(CT2->CT2_DATA) == DTOS(cArqTmp->DATAL)
			
				oSection2:Cell("HISTORICO"):SetBlock({|| CT2->CT2_HIST } )
				oSection2:Printline()

				CT2->(dbSkip())			
			EndDo	
		EndIf
	EndIf                  

	oSection2:Cell("HISTORICO"):SetBlock( { || cArqTmp->HISTORICO } )

	oSection2:Cell("DATAL"		):Show()
	oSection2:Cell("DOCUMENTO"	):Show()
	oSection2:Cell("XPARTIDA"	):Show()
	oSection2:Cell("ITEM"		):Show()
	oSection2:Cell("CLVL"		):Show()
	oSection2:Cell("LANCDEB"	):Show()
	oSection2:Cell("LANCCRD"	):Show()
	oSection2:Cell("TPSLDATU"	):Show()

	dbSelectArea("cArqTmp")

Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³f440Fil   ºAutor  ³Cicero J. Silva     º Data ³  24/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBR440                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function _f440Fil(lNoMov,aSaldo,dDataIni)

Local lDeixa	:= .F.

	If !lNoMov //Se imprime conta sem movimento
		If aSaldo[6] == 0 .And. cArqTmp->LANCDEB ==0 .And. cArqTmp->LANCCRD == 0 
			lDeixa	:= .T.
		Endif	
	Endif             
	
	If lNoMov .And. aSaldo[6] == 0 .And. cArqTmp->LANCDEB ==0 .And. cArqTmp->LANCCRD == 0 
		If CtbExDtFim("CTT") 			
			dbSelectArea("CTT") 
			dbSetOrder(1) 
			If MsSeek(xFilial()+cArqTmp->CCUSTO)
				If !CtbVlDtFim("CTT",dDataIni)
					lDeixa	:= .T.
	            EndIf                                   
		    EndIf
		EndIf
	EndIf

	dbSelectArea("cArqTmp")

Return (lDeixa)

/*

------------------------------------------------------- RELESE 4 ---------------------------------------------------------------

*/

/*/                               
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBR440R3³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 05.02.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao do Razao por Centro de Custo                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBR440R3(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//User Function _CTBR4R3(cCustoIni, cCustoFim, dDataIni, dDataFim, cMoeda, cSaldo,;
Static Function _CTBR4R3(cCustoIni, cCustoFim, dDataIni, dDataFim, cMoeda, cSaldo,;
			cBook, cContaIni, cContaFim, lItem, cItemIni, cItemFim, lCLVL,;
			cCLVLIni, cCLVLFim,lSalLin,aSelFil)

Local aCtbMoeda	:= {}
Local WnRel			:= "CTBR440"

Local cSayCusto	:= CtbSayApro("CTT")
Local cSayItem		:= CtbSayApro("CTD")                     
Local cSayClVl		:= CtbSayApro("CTH")
Local cDesc1		:= STR0001+Alltrim(cSayCusto) 	//"Este programa ir  imprimir o Razao Contabil por "
Local cDesc2		:= STR0002	//"de Custo de acordo com os parametros solicitados"
Local cDesc3		:= STR0003	//"pelo usuario"
Local cString		:= "CT2"

Local titulo		:= STR0006 + Alltrim(cSayCusto)	//"Emissao do Razao Contabil por Centro de Custo"

Local lRet			:= .T.
Local lExterno		:= cCustoIni <> Nil

Local nTamLinha	:= 220

Default lItem		:= .T.
Default lCLVL		:= .T.
Default lSalLin		:= .T.
Default aSelFil		:= {}

Private aReturn	:= { STR0004, 1,STR0005, 2, 2, 1, "", 1 }  //"Zebrado"###"Administracao"
Private aLinha		:= {}

Private cPerg		:= "CTR440"

Private nomeprog	:= "CTBR440"
Private nLastKey	:= 0

Private Tamanho	:= "G"
Private lSaltLin:=.T.

aSetOfBook := CTBSetOf(mv_par07)
aCtbMoeda  	:= CtbMoeda(mv_par05)
lItem		:= Iif(mv_par14 == 1,.T.,.F.)
lCLVL		:= Iif(mv_par17 == 1,.T.,.F.)
lAnalitico	:= Iif(mv_par08 == 1,.T.,.F.)
Tamanho		:= If( lAnalitico .and. (lItem .or. lClvl), Tamanho, "M")
nTamLinha	:= If( lAnalitico .and. (lItem .or. lClvl), 220, 132)

wnrel := SetPrint(cString,wnrel,,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

lAnalitico	:= Iif(mv_par08 == 1,.T.,.F.)
Tamanho		:= If( lAnalitico .and. (lItem .or. lClvl), Tamanho, "M")
nTamLinha	:= If( lAnalitico .and. (lItem .or. lClvl), 220, 132)
lSaltLin	:= If(MV_PAR28==1,.T.,.F.)

If aReturn[4] == 2		/// Se forçar formato paisagem
	Tamanho		:= "G"
	nTamLinha	:= 220
EndIf	

If nLastKey = 27
	Set Filter To
	Return
Endif

SetDefault(aReturn,cString,,,Tamanho,aReturn[4])

If nLastKey == 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| _CTR4Imp(@lEnd,wnRel,cString,aSetOfBook,lItem,lCLVL,;
		lAnalitico,Titulo,nTamlinha,aCtbMoeda,cSayCusto,cSayItem,cSayClVl,aSelFil)})
Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³CTR440Imp ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 05/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Impressao do Razao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³Ctr440Imp(lEnd,wnRel,cString,aSetOfBook,lItem,;             ³±±
±±³           ³          lCLVL,Titulo,nTamLinha,aCtbMoeda)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ lEnd       - A‡ao do Codeblock                             ³±±
±±³           ³ wnRel      - Nome do Relatorio                             ³±±
±±³           ³ cString    - Mensagem                                      ³±±
±±³           ³ aSetOfBook - Array de configuracao set of book             ³±±
±±³           ³ lItem      - Imprime Item Contabil?                        ³±±
±±³           ³ lCLVL      - Imprime Classe de Valor?                      ³±±
±±³           ³ Titulo     - Titulo do Relatorio                           ³±±
±±³           ³ nTamLinha  - Tamanho da linha a ser impressa               ³±±
±±³           ³ aCtbMoeda  - Array ref. a moeda solicitada                 ³±±
±±³           ³ cSayCusto  - Nomenclatura utilizada para o Centro de Custo ³±±
±±³           ³ cSayItem   - Nomenclatura utilizada para o Item            ³±±
±±³           ³ cSayClVl   - Nomenclatura utilizada para a Classe de valor ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//User Function _CTR4Imp(lEnd,WnRel,cString,aSetOfBook,lItem,lCLVL,lAnalitico,Titulo,nTamlinha,;
Static Function _CTR4Imp(lEnd,WnRel,cString,aSetOfBook,lItem,lCLVL,lAnalitico,Titulo,nTamlinha,;
						aCtbMoeda,cSayCusto,cSayItem,cSayClvl,aSelFil)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local CbTxt
Local cbcont
Local Cabec1		:= ""
Local Cabec2		:= ""

Local aSaldo		:= {} 
Local aSaldoAnt		:= {}
Local aColunas

Local cDescMoeda
Local cMascara1	:= ""
Local cMascara2	:= ""
Local cMascara3	:= ""
Local cMascara4	:= ""
Local cPicture
Local cSepara1		:= ""
Local cSepara2		:= ""
Local cSepara3		:= ""
Local cSepara4		:= ""
Local cSaldo		:= mv_par06
Local cContaIni	:= mv_par12
Local cContaFIm	:= mv_par13
Local cCustoIni	:= mv_par01
Local cCustoFim	:= mv_par02
Local cItemIni		:= mv_par15
Local cItemFim		:= mv_par16
Local cCLVLIni		:= mv_par18
Local cCLVLFim		:= mv_par19
Local cContaAnt		:= ""
Local cArqTmp

Local cCodRes		:= ""
Local cResCC		:= ""
Local cResItem 		:= ""
Local cResCLVL		:= ""		
Local cMoeda		:= mv_par05
Local cNormal 		:= ""

Local dDataAnt		:= CTOD("  /  /  ")
Local dDataIni		:= mv_par03
Local dDataFim		:= mv_par04

Local lNoMov		:= Iif(mv_par09==1,.T.,.F.)
Local lSalto		:= Iif(mv_par20==1,.T.,.F.)
Local lTotConta   
Local lPrintZero	:= Iif(mv_par27 == 1,.T.,.F.)

Local nDecimais
Local nTotDeb		:= 0
Local nTotCrd		:= 0
Local nTotDebG		:= 0
Local nTotCrdG		:= 0
Local nReinicia 	:= mv_par23
Local nPagFim		:= mv_par22
Local nVlrDeb		:= 0
Local nVlrCrd		:= 0
Local l1StQb := .T.
Local lQbPg			:= .F.
Local lEmissUnica	:= If(GetNewPar("MV_CTBQBPG","M") == "M",.T.,.F.)			/// U=Quebra única (.F.) ; M=Multiplas quebras (.T.)
Local nPagIni		:= mv_par21
Local lNewPAGFIM	:= If(nReinicia > nPagFim,.T.,.F.)
Local nBloco		:= 0
Local nBlCount		:= 0
Local nSpacCta		:= TamSx3( 'CT1_CONTA' )[1]
Local lFirst		:= .T.
Local nTamVal		:= 17
Local nX
Local cFilOld := cFilAnt
Local cFil := ""
Local cFilRazao,cFilAuxStr		

m_pag    := 1
If lEmissUnica
	CtbQbPg(.T.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt				:= SPACE(10)
cbcont				:= 0
li       			:= 80

cDescMoeda 	:= Alltrim(aCtbMoeda[2])
nDecimais 	:= DecimalCTB(aSetOfBook,cMoeda)

// Mascara da Conta
If Empty(aSetOfBook[2])
	cMascara1 := GetMv("MV_MASCARA")
Else
	cMascara1	:= RetMasCtb(aSetOfBook[2],@cSepara1)
EndIf
 
// Mascara do Centro de Custo
If Empty(aSetOfBook[6])
	cMascara2 := GetMv("MV_MASCCUS")            
Else
	cMascara2	:= RetMasCtb(aSetOfBook[6],@cSepara2)
EndIf                                                

If lItem 
	// Mascara do Item Contabil
	If Empty(aSetOfBook[7])
		cMascara3 := ""
	Else
		cMascara3 := RetMasCtb(aSetOfBook[7],@cSepara3)
	EndIf
Endif    

If lCLVL
	// Mascara da Classe de Valor
	If Empty(aSetOfBook[8])
		cMascara4 := ""
	Else
		cMascara4 := RetMasCtb(aSetOfBook[8],@cSepara4)
	EndIf
EndIf	

cPicture 	:= aSetOfBook[4]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Titulo do Relatorio                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("NewHead")== "U"
	Titulo	:=	STR0007	+ Upper(Alltrim(cSayCusto))//"RAZAO POR "
	IF lAnalitico
		Titulo	+=  STR0008 	//"ANALITICO EM"
	Else                    	
		Titulo	+=	STR0014		//"SINTETICO EM"
	EndIf
	Titulo += 	cDescMoeda + space(01)+STR0009 + space(01)+DTOC(dDataIni) +;	// "DE"
				space(01)+STR0010 + space(01)+ DTOC(dDataFim)						// "ATE"
	
	If mv_par06 > "1"
		Titulo += " (" + Tabela("SL", mv_par06, .F.) + ")"
	EndIf
Else
	Titulo := NewHead
EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Resumido                                  						         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// DATA                         					                                DEBITO               CREDITO            SALDO ATUAL
// XX/XX/XXXX 			                                 		     99,999,999,999,999.99 99,999,999,999,999.99 99,999,999,999,999.99D
// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16         17        18        19        20       21        22
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cabe‡alho Conta                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// DATA
// LOTE/SUB/DOC/LINHA H I S T O R I C O                        C/PARTIDA                      DEBITO          CREDITO       SALDO ATUAL"
// XX/XX/XXXX         
// XXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX 9999999999999.99 9999999999999.99 9999999999999.99D
// 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234
//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cabe‡alho Conta + Item + Classe de Valor								     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// DATA
// LOTE/SUB/DOC/LINHA H I S T O R I C O                                  C/PARTIDA                                ITEM                 CLASSE DE VALOR                     DEBITO               CREDITO            SALDO ATUAL"
// XX/XX/XXXX 
// XXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX  99,999,999,999,999.99 99,999,999,999,999.99 999,999,999,999,999.99D
// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16         17        18        19        20       21        22

#DEFINE 	COL_NUMERO 			1
#DEFINE 	COL_FILIAL			2
#DEFINE 	COL_HISTORICO		3
#DEFINE 	COL_CONTRA_PARTIDA	4
#DEFINE 	COL_ITEM_CONTABIL 	5
#DEFINE 	COL_CLASSE_VALOR  	6 
#DEFINE 	COL_VLR_DEBITO		7
#DEFINE 	COL_VLR_CREDITO		8
#DEFINE 	COL_VLR_SALDO  		9
#DEFINE 	TAMANHO_TM       	10           
#DEFINE 	COL_VLR_TRANSPORTE  11

If aReturn[4] == 1 .and. !lItem .and. !lClVl
	If mv_par10 == 2
		nSpacCta := Len(CT1->CT1_RES)+Len(ALLTRIM(cMascara1))
	Else
		nSpacCta := Len(CT1->CT1_CONTA)
	EndIf
EndIf

If !(lItem .or. lClvl)
	nTamVal := 16
EndIf

If ! lAnalitico
	aColunas := { 000, 019, 022,    ,    ,    , 068, 092, 113, 18,090}
Else
	If lItem .or. lClvl
		aColunas := { 000, 019, 022, 063, 111, 135, 164, 181, 198, nTamVal, 176 }
	Else
		aColunas := { 000,   0, 019, 060,   0,   0,  80,  96, 112, nTamVal, 112 }	
	EndIf	
Endif

If lAnalitico							// Relatorio Analitico
	Cabec1 := STR0019					// "DATA"
	If lItem .or. lClVl
		Cabec2 := StrTran(STR0013,"FL",Space(2))// "LOTE/SUB/DOC/LINHA  H I S T O R I C O                        C/PARTIDA            ITEM                 CLASSE DE VALOR                     DEBITO               CREDITO           SALDO ATUAL"
		Cabec2 += Space(aColunas[5]-aColunas[4]-9) + Upper(cSayItem) + Space(14) + Upper(cSayClVl)+Space(30)
	Else
		Cabec2 := STR0038				// "LOTE/SUB/DOC/LINHA  H I S T O R I C O                        C/PARTIDA            ITEM                 CLASSE DE VALOR                     DEBITO               CREDITO           SALDO ATUAL"
		Cabec2 += Space(aColunas[7]-aColunas[4]+1)
	EndIf
	Cabec2 += STR0021
Else
	lClVl  := .F.
	lItem	 := .F.
	Cabec1 := STR0025	// "DATA			                    		                   					                                               DEBITO           CREDITO       SALDO ATUAL"
EndIf	         
m_pag := mv_par21
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTBGerRaz(oMeter,oText,oDlg,lEnd,@cArqTmp,cContaIni,cContaFim,cCustoIni,cCustoFim,;
			cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
			aSetOfBook,lNoMov,cSaldo,.t.,"2",lAnalitico,,,aReturn[7],,aSelFil)},;
			STR0018,;		// "Criando Arquivo Temporario..."
			STR0006 + Alltrim(cSayCusto))						// "Emissao do Razao"

dbSelectArea("cArqTmp")
dbSetOrder(1)
SetRegua(RecCount())
dbGoTop()

//Se tiver parametrizado com Plano Gerencial, exibe a mensagem que o Plano Gerencial 
//nao esta disponivel e sai da rotina.
If RecCount() == 0 .And. !Empty(aSetOfBook[5])
	dbCloseArea()
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())	
	Return
Endif

While !Eof()
	cFilAnt := cArqTmp->FILORI

	IF lEnd
		@Prow()+1,0 PSAY STR0015  //"***** CANCELADO PELO OPERADOR *****"
		Exit
	EndIF

	IncRegua()

	// Calcula o saldo anterior do centro de custo atual
	aSaldoAnt	:= SaldTotCT3(cArqTmp->CCUSTO,cArqTmp->CCUSTO,cContaIni,cContaFim,dDataIni,cMoeda,cSaldo,aSelFil)
	aSaldo		:= SaldTotCT3(cArqTmp->CCUSTO,cArqTmp->CCUSTO,cContaIni,cContaFim,cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)

	If !lNoMov //Se imprime sem movimento
		If aSaldo[6] == 0 .And. cArqTmp->LANCDEB ==0 .And. cArqTmp->LANCCRD == 0 
			dbSelectArea("cArqTmp")
			dbSkip()
			Loop                                    
		Endif	
	Endif     
	
	If lNomov .And. aSaldo[6] == 0 .And. cArqTmp->LANCDEB ==0 .And. cArqTmp->LANCCRD == 0 
		If CtbExDtFim("CTT") 			
			dbSelectArea("CTT") 
			dbSetOrder(1) 
			If MsSeek(xFilial()+cArqTmp->CCUSTO)
				If !CtbVlDtFim("CTT",dDataIni) 		
					dbSelectArea("cArqTmp")
					dbSkip()
					Loop								
	            EndIf
		    EndIf
		    dbSelectArea("cArqTmp")
		EndIf
	EndIf
	        
	If li > 56 .Or. lSalto              
		If lEmissUnica	
			CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.F. TRATA A QUEBRA/REINICIO
		Else
			If m_pag > nPagFim
				If lNewPAGFIM
					nPagFim := m_pag+nPagFim		
					If l1StQb							//// SE FOR A 1ª QUEBRA
						m_pag := nReinicia
						l1StQb := .F.					//// INDICA Q NÃO É MAIS A 1ª QUEBRA
					Endif
				Else
					m_pag := nReinicia
				Endif
			EndIf	
		Endif

		CtCGCCabec(lItem,.F.,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)
		
		If !lFirst		
			lQbPg	:= .T.
		Else
			lFirst := .F.
		Endif		
		
	EndIf

	nSaldoAtu:= 0
	nTotDeb	:= 0
	nTotCrd	:= 0

	@li,011 PSAY Upper(Alltrim(cSayCusto)) + " - "  		//"CENTRO DE CUSTO - "
	
	dbSelectArea("CTT")
	dbSetOrder(1)
	dbSeek(xFilial()+cArqTMP->CCUSTO)  
	cResCC := CTT->CTT_RES
	
	If mv_par24 == 1 // Imprime Codigo Normal de Centro de Custo
		EntidadeCTB(cArqTmp->CCUSTO,li,pcol()+2,20,.F.,cMascara2,cSepara2)
	Else                                                                     
		EntidadeCTB(cResCC,li,pcol()+2,20,.F.,cMascara2,cSepara2)
	Endif
	
	@ li, pCol()+2 PSAY "- " + CtbDescMoeda("CTT->CTT_DESC"+cMoeda)
	
	If lAnalitico	//Se for analitico
		@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0026) - 1 PSAY STR0026	//"SALDO ANTERIOR: "	
	Else	//Se for resumido
		@li,aColunas[COL_VLR_CREDITO]  PSAY STR0026	//"SALDO ANTERIOR: "		
	EndIf
		 
	// Impressao do Saldo Anterior do Centro de Custo
	ValorCTB(aSaldoAnt[6],li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais,.T.,cPicture)  

	nSaldoAtu := aSaldoAnt[6]
	If lSaltLin
		li += 2         
	Else
		li += 1         
	EndIf
	
	dbSelectArea("cArqTmp")		
	cFilRazao := cArqTmp->FILIAL
	cCustoAnt := cArqTmp->CCUSTO
	While cArqTmp->(!Eof() .And. FILIAL+CCUSTO == cFilRazao+cCustoAnt)
	
		cContaAnt	:= cArqTmp->CONTA
		dDataAnt	:= cArqTmp->DATAL
		If Empty(cArqTmp->FILIAL)
			cFilAuxStr := ""
		Else
			cFilAuxStr := STR0037+":"+cArqTmp->FILIAL+Space(1)
		EndIf
			
		If lAnalitico
			nTotCtaDeb  := 0
			nTotCtaCrd	:= 0
			
			If ! Empty(cArqTmp->CONTA)
				If lSaltLin
					li++
				EndIf
				@li,000 PSAY cFilAuxStr+STR0024				// "CONTA - "
		
				dbSelectArea("CT1")
				dbSetOrder(1)
				dbSeek(xFilial()+cArqTmp->CONTA)
				cCodRes := CT1->CT1_RES
				cNormal := CT1->CT1_NORMAL
		
				If mv_par10 == 1							// Imprime Cod Normal
					EntidadeCTB(cArqTmp->CONTA,li,pcol()+2,nSpacCta,.F.,cMascara1,cSepara1)
				Else
					EntidadeCTB(cCodRes,li,pcol()+2,20,.F.,cMascara1,cSepara1)
				EndIf

				@ li, pCol()+2 PSAY CtbDescMoeda("CT1->CT1_DESC"+cMoeda)
			
				If lSaltLin
					li+=2
				Else
					li+=1
				EndIf
				
				
			Endif
			@li,000 PSAY cArqTmp->DATAL
			If ! Empty(cArqTmp->CONTA)
				li++
			Endif
			
			lTotConta := .F.
			While cArqTmp->(!Eof() .And. FILIAL+CCUSTO+CONTA == cFilRazao+cCustoAnt+cContaAnt)
		
				If li > 56  
					If lEmissUnica
						CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS
					Else
						If m_pag > nPagFim
							If lNewPAGFIM
								nPagFim := m_pag+nPagFim		
								If l1StQb							//// SE FOR A 1ª QUEBRA
									m_pag := nReinicia
									l1StQb := .F.					//// INDICA Q NÃO É MAIS A 1ª QUEBRA
								Endif
							Else
								m_pag := nReinicia
							Endif
						EndIf	
					Endif
					If Empty(cArqTmp->CONTA)				//// CONDICAO INVERSA DA QUEBRA DE LINHA ACIMA
						li++								//// PARA NAO QUEBRAR 2 LINHAS SEGUIDAS
					Endif
					@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0022) - 1 PSAY STR0022	//"A TRANSPORTAR : "

					ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais,.T.,cPicture,cNormal)
					
					CtCGCCabec(lItem,.F.,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)
					lQbPg := .T.
					
					@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0023) - 1 PSAY STR0023	//"A TRANSPORTAR : "
					ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO], aColunas[TAMANHO_TM],nDecimais,.T.,cPicture,cNormal)
					li++
				EndIf            
				nSaldoAtu 	:= nSaldoAtu - cArqTmp->LANCDEB + cArqTmp->LANCCRD
				nTotDeb		+= cArqTmp->LANCDEB
				nTotCrd		+= cArqTmp->LANCCRD
				nTotCtaDeb  += cArqTmp->LANCDEB
				nTotCtaCrd  += cArqTmp->LANCCRD
	
				// Imprime os lancamentos para a conta 
				If dDataAnt != cArqTmp->DATAL
					li++      
					@li,000 PSAY cArqTmp->DATAL
					li++
					dDataAnt := cArqTmp->DATAL
				ElseIf lQbPg
					If !lSalto
						@li,000 PSAY dDataAnt
						li++
					EndIf
					lQbPg := .F.
				EndIf
			    
				@li,aColunas[COL_NUMERO] PSAY cArqTmp->LOTE+cArqTmp->SUBLOTE+;
											   cArqTmp->DOC+cArqTmp->LINHA

				@li,aColunas[COL_HISTORICO] PSAY Subs(cArqTmp->HISTORICO,1,40)
				dbSelectArea("CT1")
				dbSetOrder(1)
				dbSeek(xFilial()+cArqTmp->XPARTIDA)
				cCodRes := CT1->CT1_RES

				If mv_par10 == 1
					EntidadeCTB(cArqTmp->XPARTIDA,li,aColunas[COL_CONTRA_PARTIDA],nSpacCta,.F.,cMascara1,cSepara1)
				Else
					EntidadeCTB(cCodRes,li,aColunas[COL_CONTRA_PARTIDA],20,.F.,cMascara1,cSepara1)				
				Endif                              

				If lItem 						//Se imprime item 
//					If mv_par25 == 1 //Imprime Codigo Normal Item Contabl
//						EntidadeCTB(cArqTmp->ITEM,li,aColunas[COL_ITEM_CONTABIL],20,.F.,cMascara3,cSepara3)
//					Else
						dbSelectArea("CTD")
						dbSetOrder(1)
						dbSeek(xFilial()+cArqTmp->ITEM)				
//						cResItem := CTD->CTD_RES
						cResItem := CTD->CTD_DESC01  // Leonel
						EntidadeCTB(cResItem,li,aColunas[COL_ITEM_CONTABIL],20,.F.,cMascara3,cSepara3)						
//					Endif
				Endif
				
				If lCLVL						//Se imprime classe de valor
					If mv_par26 == 1 //Imprime Cod. Normal Classe de Valor
						EntidadeCTB(cArqTmp->CLVL,li,aColunas[COL_CLASSE_VALOR],20,.F.,cMascara4,cSepara4)
					Else
						dbSelectArea("CTH")
						dbSetOrder(1)
						dbSeek(xFilial()+cArqTmp->CLVL)				
						cResClVl := CTH->CTH_RES						
						EntidadeCTB(cResClVl,li,aColunas[COL_CLASSE_VALOR],20,.F.,cMascara4,cSepara4)
					Endif			
				Endif
				
				ValorCTB( cArqTmp->LANCDEB	,li,aColunas[COL_VLR_DEBITO]	,aColunas[TAMANHO_TM],nDecimais,.F.,cPicture,"1",,,,,,lPrintZero)
				ValorCTB( cArqTmp->LANCCRD	,li,aColunas[COL_VLR_CREDITO]	,aColunas[TAMANHO_TM],nDecimais,.F.,cPicture,"2",,,,,,lPrintZero) 
				ValorCTB( nSaldoAtu			,li,aColunas[COL_VLR_SALDO]		,aColunas[TAMANHO_TM],nDecimais,.T.,cPicture,cNormal,,,,,,lPrintZero)
		
				// Procura pelo complemento de historico
				dbSelectArea("CT2")
				dbSetOrder(10)
				If dbSeek(xFilial("CT2")+cArqTMP->(DTOS(DATAL)+LOTE+SUBLOTE+DOC+SEQLAN+EMPORI+FILORI),.F.)
					dbSkip()
					If CT2->CT2_DC == "4"
						While !Eof() .And. CT2->CT2_FILIAL == xFilial() .And.;
							CT2->CT2_LOTE == cArqTMP->LOTE .And. CT2->CT2_DOC == cArqTmp->DOC .And.;
							CT2->CT2_SEQLAN == cArqTmp->SEQLAN .And.;
							CT2->CT2_EMPORI == cArqTmp->EMPORI	.And.;
							CT2->CT2_FILORI == cArqTmp->FILORI	.And.;
							CT2->CT2_DC == "4" .And.;
							DTOS(CT2->CT2_DATA) == DTOS(cArqTmp->DATAL)                        
							li++
							If li > 56
								If lEmissUnica
									CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS
								Else
									If m_pag > nPagFim
										If lNewPAGFIM
											nPagFim := m_pag+nPagFim		
											If l1StQb							//// SE FOR A 1ª QUEBRA
												m_pag := nReinicia
												l1StQb := .F.					//// INDICA Q NÃO É MAIS A 1ª QUEBRA
											Endif
										Else
										m_pag := nReinicia
										Endif
									EndIf	
								Endif		
								CtCGCCabec(lItem,.F.,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)
								li++
								If !lSalto
									@li,000 PSAY dDataAnt
									li++
								EndIf
							EndIf
							@li,aColunas[COL_NUMERO]  PSAY CT2->CT2_LOTE+ CT2->CT2_SBLOTE+CT2->CT2_DOC+CT2->CT2_LINHA
							@li,aColunas[COL_HISTORICO] PSAY Subs(CT2->CT2_HIST,1,40)
							dbSkip()
						EndDo	
					EndIf	
				EndIf	
				dbSelectArea("cArqTmp")
				li++

				If li > 56
					If lEmissUnica
						CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS
					Else
						If m_pag > nPagFim
							If lNewPAGFIM
								nPagFim := m_pag+nPagFim		
								If l1StQb							//// SE FOR A 1ª QUEBRA
									m_pag := nReinicia
									l1StQb := .F.					//// INDICA Q NÃO É MAIS A 1ª QUEBRA
								Endif
							Else
								m_pag := nReinicia
							Endif
						EndIf	
					Endif		

					@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0022) - 1;
								 PSAY STR0022	//"A TRANSPORTAR : "
					ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais,.T.,cPicture,cNormal)
					
					CtCGCCabec(lItem,.F.,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)
					
					@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0023) - 1 PSAY STR0023	//"A TRANSPORTAR : "
					ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais,.T.,cPicture,cNormal)

					li++
					If !lSalto
						@li,000 PSAY dDataAnt
						li++
					Endif
					lQbPg := .F.				
				EndIf   
	         	lTotConta := ! Empty(cArqTmp->CONTA)
				dbSelectArea("cArqTmp")
				dDataAnt := cArqTmp->DATAL		
				dbSkip()
			EndDo      	
   
			If lTotConta .And. mv_par11 == 1	// Totaliza tb por Conta
				
				If lSaltLin
					li += 1
			    EndIf
			    
				@li,aColunas[If(lAnalitico,COL_HISTORICO,COL_NUMERO)] PSAY STR0020  //"T o t a i s  d a  C o n t a  ==> " 
				ValorCTB(nTotCtaDeb,li,aColunas[COL_VLR_DEBITO] ,aColunas[TAMANHO_TM],nDecimais,.F.,cPicture,"1",,,,,,lPrintZero)
				ValorCTB(nTotCtaCrd,li,aColunas[COL_VLR_CREDITO],aColunas[TAMANHO_TM],nDecimais,.F.,cPicture,"2",,,,,,lPrintZero)
			
				nTotCtaDeb := 0
				nTotCtaCrd := 0
			
				li++
				@li, 00 PSAY Replicate("-",nTamLinha)
				li++
			EndIf	
			If lTotConta .and. lSaltLin
				li++
			Endif
		Else					//Se for resumido
			dbSelectArea("cArqTmp")
			If ! Empty(cArqTmp->CONTA)
				CT1->(dbSeek(xFilial()+cArqTmp->CONTA))
				cCodRes := CT1->CT1_RES
				cNormal := CT1->CT1_NORMAL
			Else
				cNormal := ""
			Endif
			If li > 56
				If lEmissUnica
					CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS
				Else
					If m_pag > nPagFim
						If lNewPAGFIM
							nPagFim := m_pag+nPagFim		
							If l1StQb							//// SE FOR A 1ª QUEBRA
								m_pag := nReinicia
								l1StQb := .F.					//// INDICA Q NÃO É MAIS A 1ª QUEBRA
							Endif
						Else
							m_pag := nReinicia
						Endif
					EndIf	
				Endif
				li++									//// A QUEBRA JA E FEITA ACIMA
				@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0022) - 1 PSAY STR0022	//"A TRANSPORTAR : "
				ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO], aColunas[TAMANHO_TM],nDecimais, .T.,cPicture,cNormal)
				
				CtCGCCabec(lItem,.F.,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)
					
				@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0023) - 1 PSAY STR0023	//"A TRANSPORTAR : "
				ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO], aColunas[TAMANHO_TM],nDecimais, .T.,cPicture,cNormal)
				li++
			EndIf   
			@li,000 PSAY cArqTmp->DATAL
			If !Empty(cFilAuxStr)
				@li,pcol()+10 PSAY cFilAuxStr
			EndIf
		
			While  cArqTmp->(!Eof() .And. FILIAL+CCUSTO == cFilRazao+cCustoAnt .And. dDataAnt == DATAL ) //cArqTmp->(! Eof() .And. dDataAnt == cArqTmp->DATAL .And. cCustoAnt == cArqTmp->CCUSTO
				nVlrDeb	+= cArqTmp->LANCDEB		                                         
				nVlrCrd	+= cArqTmp->LANCCRD		                                         
				dbSkip()                                                                    				
			EndDo		   
				                                                                    
			nSaldoAtu := nSaldoAtu - nVlrDeb + nVlrCrd
			ValorCTB(nVlrDeb	,li	,aColunas[COL_VLR_DEBITO] ,aColunas[TAMANHO_TM],nDecimais,.F.,cPicture,"1"		,,,,,,lPrintZero)
			ValorCTB(nVlrCrd	,li	,aColunas[COL_VLR_CREDITO],aColunas[TAMANHO_TM],nDecimais,.F.,cPicture,"2"		,,,,,,lPrintZero)
			ValorCTB(nSaldoAtu	,li	,aColunas[COL_VLR_SALDO]  ,aColunas[TAMANHO_TM],nDecimais,.T.,cPicture,cNormal	,,,,,,lPrintZero)
			
			nTotDeb		+= nVlrDeb
			nTotCrd		+= nVlrCrd
			nVlrDeb	:= 0
			nVlrCrd	:= 0
		Endif
		dbSelectArea("cArqTmp")
		li++
	EndDo	
	If lSaltLin
		li += If(lAnalitico, 0, 1)
    EndIf
	
	If li > 56
		If lEmissUnica
			CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS
		Else
			If m_pag > nPagFim
				If lNewPAGFIM
					nPagFim := m_pag+nPagFim		
					If l1StQb							//// SE FOR A 1ª QUEBRA
						m_pag := nReinicia
						l1StQb := .F.					//// INDICA Q NÃO É MAIS A 1ª QUEBRA
					Endif
				Else
					m_pag := nReinicia
				Endif
			EndIf	
		Endif

		@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0022) - 1	 PSAY STR0022	//"A TRANSPORTAR : "
		ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO], aColunas[TAMANHO_TM],nDecimais,.T.,cPicture,cNormal)
					
		CtCGCCabec(lItem,.F.,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)
					
		@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0023) - 1 PSAY STR0023	//"A TRANSPORTAR : "
		ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],  aColunas[TAMANHO_TM],nDecimais,.T.,cPicture,cNormal)
			li++
	EndIf   

	@li,aColunas[If(lAnalitico,COL_HISTORICO,COL_NUMERO)] PSAY STR0017 + Upper(Alltrim(cSayCusto)) + " ==> "  //"T o t a i s  d o  C e n t r o  d e  C u s t o  ==> " 
    
	If lAnalitico
		@li, pcol()+1 PSAY "( "
		
		If mv_par24 == 1 // Se imprime cod. normal de Centro de Custo
			EntidadeCTB(cCustoAnt,li,pcol(),aColunas[COL_HISTORICO],.F.,cMascara2,cSepara2)
		Else
			dbSelectArea("CTT")
			dbSetOrder(1)
			dbSeek(xFilial()+cCustoAnt)  
			cResCC := CTT->CTT_RES
			EntidadeCTB(cResCC,li,pcol(),aColunas[COL_HISTORICO],.F.,cMascara2,cSepara2)		
		Endif
		@li, pcol()+1 PSAY " )"
	Else
		@li, pcol()+1 PSAY "( " 	   
		If mv_par24 == 1
			EntidadeCTB(cCustoAnt,li,pcol(),aColunas[COL_HISTORICO],.F.,cMascara2,cSepara2)
		Else
			dbSelectArea("CTT")
			dbSetOrder(1)
			dbSeek(xFilial()+cCustoAnt)  
			cResCC := CTT->CTT_RES
			EntidadeCTB(cResCC,li,pcol()+2,aColunas[COL_HISTORICO],.F.,cMascara2,cSepara2)				
		Endif
		@li, pcol()+1 PSAY " )"
	Endif

	// T o t a i s
	ValorCTB(nTotDeb	,li,aColunas[COL_VLR_DEBITO]	,aColunas[TAMANHO_TM],nDecimais,.F.,cPicture,"1",,,,,,lPrintZero)
	ValorCTB(nTotCrd	,li,aColunas[COL_VLR_CREDITO]	,aColunas[TAMANHO_TM],nDecimais,.F.,cPicture,"2",,,,,,lPrintZero)
	ValorCTB(nSaldoAtu	,li,aColunas[COL_VLR_SALDO]		,aColunas[TAMANHO_TM],nDecimais,.T.,cPicture,	 ,,,,,,lPrintZero)

	nTotDebG := nTotDebG + nTotDeb
	nTotCrdG := nTotCrdG + nTotCrd
		
	li++
	@li, 00 PSAY Replicate("=",nTamLinha)
	If lSaltLin
	  	li += 2  
	Else         
		li += 1         
	EndIf
	
	dbSelectArea("cArqTmp")
EndDo	

//Leo
@li,aColunas[If(lAnalitico,COL_HISTORICO,COL_NUMERO)] PSAY 'T o t a l  G e r a l ==>'  
ValorCTB(nTotDebG	,li,aColunas[COL_VLR_DEBITO]	,aColunas[TAMANHO_TM],nDecimais,.F.,cPicture,"1",,,,,,lPrintZero)
ValorCTB(nTotCrdG	,li,aColunas[COL_VLR_CREDITO]	,aColunas[TAMANHO_TM],nDecimais,.F.,cPicture,"2",,,,,,lPrintZero)
//Leo
	li++
	@li, 00 PSAY Replicate("=",nTamLinha)
	If lSaltLin
	  	li += 2  
	Else         
		li += 1         
	EndIf
//Leo

cFilAnt := cFilOld
If li != 80
	roda(cbcont,cbtxt,Tamanho)
EndIf
If aReturn[5] = 1
	Set Printer To
	Commit
	Ourspool(wnrel)
End


dbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIf	

dbselectArea("CT2")

MS_FLUSH()          
Return     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBR440   ºAutor  ³Renato F. Campos    º Data ³  02/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula o tamanho real do campo deacordo com o campo infor-º±±
±±º          ³mado e a mascara informada                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function TamCpoMask( cCodigo , cMascara )
Local nTamanho

// codigo não informado pelo programador
If Empty( cCodigo )
	Return 0
Endif

// pega o tamanho do campo informado
nTamanho := Len( CriaVar( cCodigo ) )

If ! Empty( cMascara )
	nTamanho := nTamanho + ( Len( Alltrim( cMascara ) ) / 2 )
EndIf

RETURN nTamanho

