#Include "CTBR180.Ch"
#Include "PROTHEUS.Ch"
                                                                                                                 
static TAM_VALOR := 25 //20 //25

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                                                    
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄ¿±±
±±³Fun‡…o	 ³ xCTBR180  ³  Autor  ³ Cicero J. Silva/Reiner Trennepohl   ³ Data ³ 25.10.2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄ´±±                    
±±³Descri‡…o ³ Balancete Centro de Custo/Conta         			 	                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Ctbr180()    									                                                        	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum       										                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso 		 ³ SIGACTB      										                                                    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                            
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function xCTBR180()

Local aArea := GetArea()
Local oReport

Local lOk 			:= .T.
Local aCtbMoeda		:= {}
Local nDivide		:= 1

PRIVATE cTipoAnt	:= ""
PRIVATE cPerg	 	:= "CTR180"
PRIVATE nomeProg  := "xCTBR180"
PRIVATE titulo
PRIVATE aSelFil	:= {}     

	
	Pergunte(cPerg,.T.) // Precisa ativar as perguntas antes das definicoes.
	
	If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
		lOk := .F.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
	//³ Gerencial -> montagem especifica para impressao)			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    if ! Empty( mv_par08 )
    	lOK := VdSetOfBook( mv_par08 , .F. ) // codigo do livro , visao gerencial
	endif
	
	If lOk
		If mv_par24 == 2			// Divide por cem
			nDivide := 100
		
		ElseIf mv_par24 == 3		// Divide por mil
			nDivide := 1000
		
		ElseIf mv_par24 == 4		// Divide por milhao
			nDivide := 1000000
		
		EndIf
		
		aCtbMoeda := CtbMoeda( mv_par10 , nDivide ) // Moeda?

		If Empty( aCtbMoeda[1] )
			Help(" ",1,"NOMOEDA")
			lOk := .F.
		Endif 
	Endif
	
	If lOk .And. mv_par37 == 1 .And. Len( aSelFil ) <= 0
		aSelFil := AdmGetFil()
		If Len( aSelFil ) <= 0
			lOk := .F.
		EndIf 
	EndIf     
	
	If lOk
		If (mv_par34 == 1) .and. ( Empty(mv_par35) .or. Empty(mv_par36) )
			cMensagem	:= STR0023	// "Favor preencher os parametros Grupos Receitas/Despesas e Data Sld Ant. Receitas/Despesas ou "
			cMensagem	+= STR0024	// "deixar o parametro Ignora Sl Ant.Rec/Des = Nao "
			MsgAlert(cMensagem,STR0025) //"Ignora Sl Ant.Rec/Des"
			lOk	:= .F.
		EndIf
	EndIf

	If lOk
		oReport := ReportDef( aCtbMoeda, nDivide )

		If Valtype( oReport ) == 'O'
			oReport:PrintDialog()
		Endif

		oReport := nil
	EndIf

//Limpa os arquivos temporários 
CTBGerClean()

RestArea(aArea)

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
Static Function ReportDef( aCtbMoeda, nDivide )

Local oReport
Local oSection1
Local oSection2
Local oTotais

Local cSayCC		:= CtbSayApro("CTT")

Local cDesc1 		:= OemToAnsi(STR0001)+ Upper(cSayCC)+ " / " + Upper(OemToAnsi(STR0021))	//"Este programa ira imprimir o Balancete de  / Conta "
Local cDesc2 		:= OemToansi(STR0002)  //"de acordo com os parametros solicitados pelo Usuario"

Local aTamCC    	:= TAMSX3( "CTT_CUSTO" )
Local aTamCCRes 	:= TAMSX3( "CTT_RES"   )
Local aTamConta		:= TAMSX3( "CT1_CONTA" )
Local aTamCtaRes	:= TAMSX3( "CT1_RES"   )
Local nTamCC  		:= Len( CriaVar( "CTT->CTT_DESC"+mv_par10))
Local nTamCta 		:= Len( CriaVar( "CT1->CT1_DESC"+mv_par10))
Local nTamGrupo		:= Len( CriaVar( "CT1->CT1_GRUPO"))

Local lPula			:= .T.

Local lPrintZero	:= Iif(mv_par22==1,.T.,.F.)
Local lPulaSint		:= Iif(mv_par21==1,.T.,.F.)
Local lPulaPag		:= Iif(mv_par20==1,.T.,.F.)
Local lCCNormal		:= Iif(mv_par23==1,.T.,.F.)
Local lCNormal		:= Iif(mv_par25==1,.T.,.F.)

Local cSegAte   	:= mv_par14 // Imprimir ate o Segmento?

Local nDigitAte		:= 0
Local lMov		:= IIF( mv_par19 == 1 , .T. ,.F.) // Imprime movimento ?
Local cCCNormal

Local cSepara1		:= ""
Local cSepara2		:= ""
Local aSetOfBook := CTBSetOf(mv_par08)

Local cMascara1		:= IIF (Empty(aSetOfBook[2]),GetMv("MV_MASCARA"),RetMasCtb(aSetOfBook[2],@cSepara1))//Mascara da Conta
Local cMascara2		:= IIF (Empty(aSetOfBook[6]),GetMv("MV_MASCCUS"),RetMasCtb(aSetOfBook[6],@cSepara2))//Mascara do Centro de Custo

Local cPicture 		:= aSetOfBook[4]
Local nDecimais 	:= DecimalCTB(aSetOfBook,mv_par10)
Local cDescMoeda 	:= aCtbMoeda[2]

Local bCdCUSTO	:= {|| EntidadeCTB(cArqTmp->CUSTO,0,0,20,.F.,cMascara2,cSepara2,,,,,.F.) }
Local bCdCCRES	:= {|| EntidadeCTB(cArqTmp->CCRES,0,0,20,.F.,cMascara2,cSepara2,,,,,.F.) }

Local bCdCONTA	:= {|| EntidadeCTB(cArqTmp->CONTA,0,0,25 ,.F.,cMascara1,cSepara1,,,,,.F.)}
Local bCdCTRES	:= {|| EntidadeCTB(cArqTmp->CTARES,0,0,20,.F.,cMascara1,cSepara1,,,,,.F.)}
Local lColDbCr 	:= IIf(cPaisLoc $ "RUS",.T.,.F.) // Disconsider cTipo in ValorCTB function, setting cTipo to empty

titulo	:= OemToAnsi(STR0003)+ Upper(cSayCC)+ " / " +  Upper(OemToAnsi(STR0021))	//"Balancete de Verificacao  / Conta"

If Empty(cPicture) 
	cPicture := PesqPict("CT2","CT2_VALOR")
EndiF

oReport := TReport():New(nomeProg,titulo,cPerg,{|oReport| ReportPrint(oReport,aSetOfBook,cDescMoeda,cSayCC,nDivide,cMascara1,cMascara2,cSepara1,cSepara2,cPicture,nDecimais)},cDesc1+cDesc2)   
oReport:SetPortrait(.T.)
//oReport:SetLandScape(.T.)          // DIMINUIR TB O ESPAÇO ENTRE LINHAS
oReport:DisableOrientation()

// Sessao 1
oSection1 := TRSection():New(oReport,cSayCC ,{"cArqTmp","CTT"},/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/) //"Conta"

oReport:SetTotalInLine(.F.)
oReport:EndPage(.T.)

//Somente sera impresso centro de custo analitico
TRCell():New(oSection1,	"CUSTO"	,"cArqTmp",STR0029	,/*Picture*/,aTamCC[1]*2-1		,/*lPixel*/,bCdCUSTO, /*"LEFT"*/,,/*"LEFT"*/,,,.F.)
TRCell():New(oSection1,	"CCRES"	,"cArqTmp",STR0027	,/*Picture*/,aTamCCRes[1]	,/*lPixel*/,bCdCCRES, /*"LEFT"*/,,/*"LEFT"*/,,,.F.) //"Cód. Reduzido"
TRCell():New(oSection1,	"DESCCC","cArqTmp",STR0028	,/*Picture*/,nTamCC			,/*lPixel*/,/*{|| }*/, /*"LEFT"*/,,/*"LEFT"*/,,,.F.) //"Descricao"


If lCCNormal
	oSection1:Cell("CCRES"	):Disable()
Else
	oSection1:Cell("CUSTO"	):Disable()
EndIf

If lPulaPag
	oSection1:SetPageBreak(.T.)
EndIf

// Sessao 2
oSection2 := TRSection():New(oReport,STR0026,{"cArqTmp","CT1"},/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/) //"Conta"
oSection2:SetTotalInLine(.F.)
oSection2:SetHeaderPage()

TRCell():New(oSection2,"CONTA"		,"cArqTmp",STR0029,/*Picture*/,aTamConta[1]		,/*lPixel*/, bCdCONTA )// Codigo da Conta //"Código"
TRCell():New(oSection2,"CTARES"		,"cArqTmp",STR0027,/*Picture*/,aTamCtaRes[1]	,/*lPixel*/, bCdCTRES )// Codigo Reduzido da Conta //"Cód. Reduzido"
TRCell():New(oSection2,"DESCCTA"	,"cArqTmp",STR0028,/*Picture*/,nTamCta			,/*lPixel*/,/*{|| }*/ )// Descricao da Conta //"Descricao"
TRCell():New(oSection2,"SALDOANT"	,"cArqTmp",STR0030,/*Picture*/,TAM_VALOR+2		,/*lPixel*/,{|| ValorCTB(cArqTmp->SALDOANT ,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.)}, /*"RIGHT"*/,,"RIGHT",,,.F.)// Saldo Anterior //"Saldo anterior"
TRCell():New(oSection2,"SALDODEB"	,"cArqTmp",STR0031,/*Picture*/,TAM_VALOR+2		,/*lPixel*/,{|| ValorCTB(cArqTmp->SALDODEB ,,,TAM_VALOR  ,nDecimais,.F.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.,lColDbCr)}, /*"RIGHT"*/,,"RIGHT",,,.F.,,,.T.)// Debito //"Débito"
TRCell():New(oSection2,"SALDOCRD"	,"cArqTmp",STR0032,/*Picture*/,TAM_VALOR+2		,/*lPixel*/,{|| ValorCTB(cArqTmp->SALDOCRD ,,,TAM_VALOR  ,nDecimais,.F.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.,lColDbCr)}, /*"RIGHT"*/,,"RIGHT",,,.F.,,,.T.)// Credito //"Crédito"

If lMov //Imprime Coluna Movimento!!
	TRCell():New(oSection2,"MOVIMENTO","cArqTmp",STR0033	,/*Picture*/,TAM_VALOR+2	,/*lPixel*/,{|| ValorCTB(cArqTmp->MOVIMENTO,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.)}, /*"RIGHT"*/,,"RIGHT",,,.F.)// Movimento do Periodo //"Movimento do periodo"
EndIf

TRCell():New(oSection2,"SALDOATU"	,"cArqTmp",STR0034	,/*Picture*/,TAM_VALOR+2		,/*lPixel*/,{|| ValorCTB(cArqTmp->SALDOATU ,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.)}, /*"RIGHT"*/,,"RIGHT",,,.F.)// Saldo Atual //"Saldo atual"

TRPosition():New( oSection2, "CT1", 1, {|| xFilial("CT1") + cArqTMP->CONTA })

If lCNormal
	oSection2:Cell("CTARES"):Disable()
Else
	oSection2:Cell("CONTA"	):Disable()
EndIf

oSection2:Cell("SALDOANT"):SetAlign("RIGHT")
oSection2:Cell("SALDODEB"):SetAlign("RIGHT")
oSection2:Cell("SALDOCRD"):SetAlign("RIGHT")
oSection2:Cell("SALDOATU"):SetAlign("RIGHT")

oSection2:Cell("SALDOANT"):lHeaderSize	:= .F.
oSection2:Cell("SALDODEB"):lHeaderSize	:= .F.
oSection2:Cell("SALDOCRD"):lHeaderSize	:= .F.
oSection2:Cell("SALDOATU"):lHeaderSize	:= .F.  

If lMov //Imprime Coluna Movimento!!
//	oSection2:Cell("MOVIMENTO"):SetHeaderAlign("RIGHT")
	oSection2:Cell("MOVIMENTO"):SetAlign("RIGHT")
	oSection2:Cell("MOVIMENTO"):lHeaderSize	:= .F.
Endif

oSection2:OnPrintLine( {|| ( IIf( lPulaSint .And. (cTipoAnt == "1" .Or. (cArqTmp->TIPOCONTA == "1" .And. cTipoAnt == "2")), oReport:SkipLine(),NIL),;
									cTipoAnt := cArqTmp->TIPOCONTA;
									)  })

// Totais das sessoes
oTotais := TRSection():New( oReport,STR0039,,, .F., .F. ) //"Total"

TRCell():New( oTotais,"TOT"			,,""		,/*Picture*/,aTamConta[1] + nTamCta - 2 /*Size*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New( oTotais,"TOT_SPACE"	,,""		,/*Picture*/,1/*Size*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,30,,,,.F.)
TRCell():New( oTotais,"TOT_ANT"		,,STR0030	,/*Picture*/,TAM_VALOR+2,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,1,,,,.F.) //"A N T E R I O R"
TRCell():New( oTotais,"TOT_DEBITO"	,,STR0031	,/*Picture*/,TAM_VALOR+2,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,1,,,,.T.) //"D E B I T O    "
TRCell():New( oTotais,"TOT_CREDITO"	,,STR0032	,/*Picture*/,TAM_VALOR+2,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,1,,,,.T.) //"C R E D I T O  "

If lMov
	TRCell():New( oTotais, "TOT_MOV"	,,STR0033,/*Picture*/,TAM_VALOR+2,/*lPixel*/,/*{|| code-block de impressao }*/) //"M O V I M E N T O"
	oTotais:Cell("TOT_MOV"):HideHeader()
	oTotais:Cell("TOT_MOV"):SetAlign("RIGHT")
	oTotais:Cell("TOT_MOV"):lHeaderSize := .F.
EndIf

TRCell():New( oTotais,"TOT_ATU"		,,STR0034,/*Picture*/,TAM_VALOR+2,/*lPixel*/,/*{|| code-block de impressao }*/) //"A T U A L"

If lCNormal
	oTotais:Cell("TOT"):SetSize(aTamConta[1] + nTamCta - 1 )
Else
   	oTotais:Cell("TOT"):SetSize(aTamCtaRes[1] + nTamCta - 1 )
Endif

oTotais:Cell("TOT_ANT"    ):HideHeader()
oTotais:Cell("TOT_DEBITO" ):HideHeader()
oTotais:Cell("TOT_CREDITO"):HideHeader()
oTotais:Cell("TOT_ATU"    ):HideHeader()

oTotais:Cell("TOT_ANT"    ):SetAlign("RIGHT")
oTotais:Cell("TOT_DEBITO" ):SetAlign("RIGHT")
oTotais:Cell("TOT_CREDITO"):SetAlign("RIGHT")
oTotais:Cell("TOT_ATU"    ):SetAlign("RIGHT")

//oSection:Cell("VLCTBSBC"):SetHeaderAlign("RIGHT")

oTotais:Cell("TOT_ANT"    ):lHeaderSize	:= .F.  
oTotais:Cell("TOT_DEBITO" ):lHeaderSize	:= .F.  
oTotais:Cell("TOT_CREDITO"):lHeaderSize	:= .F.  
oTotais:Cell("TOT_ATU"    ):lHeaderSize	:= .F.  

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
Static Function ReportPrint(oReport,aSetOfBook,cDescMoeda,cSayCC,nDivide,cMascara1,cMascara2,cSepara1,cSepara2,cPicture,nDecimais)

Local oSection1 	:= oReport:Section(1)
Local oSection2		:= oReport:Section(2)
Local oTotais		:= oReport:Section(3)

Local cArqTmp		:= ""
Local cFiltro		:= oSection2:GetAdvplExp('CT1')
Local nTamCC  		:= Len(CriaVar("CTT->CTT_DESC"+mv_par10))

Local dDataLP		:= mv_par27
Local dDataFim		:= mv_par02
Local lVlrZerado	:= Iif(mv_par09==1,.T.,.F.)
Local lMov			:= IIF(mv_par19 == 1,.T.,.F.) // Imprime movimento ?
Local lPrintZero	:= Iif(mv_par22==1,.T.,.F.)
Local lImpAntLP		:= Iif(mv_par26==1,.T.,.F.)
Local lRecDesp0		:= Iif(mv_par34==1,.T.,.F.)
Local lCttSint 		:= Iif(mv_par33 == 1 .or. mv_par33 == 3,.T.,.F.)
Local cRecDesp		:= mv_par35
Local dDtZeraRD		:= mv_par36
Local cSegAte   	:= mv_par14

Local aTotCCSup		:= {0,0,0,0,0}	//{Saldo Ant,Debito,Credito,Movimento,Saldo Atual}
Local nTotDeb		:= 0
Local nTotCrd		:= 0
Local nTotMov		:= 0
Local nCCTMov 		:= 0
Local nTotCCDeb		:= 0
Local nTotCCCrd		:= 0
Local nCCSldAnt		:= 0
Local nCCSldAtu		:= 0
Local nTotSldAnt	:= 0
Local nTotSldAtu	:= 0
Local nDigitAte		:= 0
Local nDigCCAte		:= 0
Local nRegTmp		:= 0
Local nGrpDeb		:= 0
Local nGrpCrd		:= 0
Local cFiltCTT		:=oSection1:Getadvplexp('CTT')	
Local cmask1,cmask2
Local nCont    := 0
Local lCNormal		:= Iif(mv_par25==1,.T.,.F.)
Local aTamConta		:= TAMSX3( "CT1_CONTA" )
Local aTamCtaRes	:= TAMSX3( "CT1_RES"   )  
Local aSaldos		:= {}
Local nPos 			:= 0
Local lColDbCr 		:= IIf(cPaisLoc $ "RUS",.T.,.F.) // Disconsider cTipo in ValorCTB function, setting cTipo to empty
Local lRedStorn		:= IIf(cPaisLoc $ "RUS",SuperGetMV("MV_REDSTOR",.F.,.F.),.F.) // Parameter to activate Red Storn

SaveInter()

If oReport:GetOrientation() == 1 //retrato
	TAM_VALOR := 22     
	
	oSection2:Cell( "DESCCTA" ):SetSize(40, .F.) // ERA 18 :SetSize(18, .F.)
	//oSection2:Cell( "DESCCTA" ):SetLineBreak()
	//oTotais:Cell("TOT"):SetSize( oTotais:Cell("TOT"):GetSize() - ( Len( CriaVar( "CT1->CT1_DESC"+mv_par10)) - 18 ) )
	oTotais:Cell("TOT"):SetSize( oTotais:Cell("TOT"):GetSize() - ( Len( CriaVar( "CT1->CT1_DESC"+mv_par10)) ) )
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega titulo do relatorio: Analitico / Sintetico			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF mv_par07 == 1		/// Se imprime somente contas sinteticas
	Titulo:=	OemToAnsi(STR0007) + Upper(cSayCC) + "/" + Upper(OemToAnsi(STR0021))//"BALANCETE SINTETICO DE  "
ElseIf mv_par07 == 2		/// Se imprime somente contas analiticas
	Titulo:=	OemToAnsi(STR0006) + Upper(cSayCC) + "/" + Upper(OemToAnsi(STR0021))//"BALANCETE ANALITICO DE  "
ElseIf mv_par07 == 3
	Titulo:=	OemToAnsi(STR0008) + Upper(cSayCC)	+  "/" + Upper(OemToAnsi(STR0021))//"BALANCETE DE  "
EndIf

Titulo += 	OemToAnsi(STR0009) + DTOC(mv_par01) + OemToAnsi(STR0010) + Dtoc(mv_par02) + ;
OemToAnsi(STR0011) + cDescMoeda

If mv_par12 > "1"
	Titulo += " (" + Tabela("SL", mv_par12, .F.) + ")"
EndIf

If nDivide > 1
	Titulo += " (" + OemToAnsi(STR0022) + Alltrim(Str(nDivide)) + ")"
EndIf

oReport:SetPageNumber(mv_par11) //mv_par14	-	Pagina Inicial
oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataFim,titulo,,,,,oReport) } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao					     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
						mv_par01,mv_par02,"CT3","",mv_par03,mv_par04,mv_par05,mv_par06,,,,,mv_par10,;
						mv_par12,aSetOfBook,mv_par15,mv_par16,mv_par17,mv_par18,;
						!lMov,.T.,,"CTT",lImpAntLP,dDataLP, nDivide,lVlrZerado,,,;
						mv_par29,mv_par30,mv_par31,mv_par32,,,,,,,,,cFiltro,lRecDesp0,;
						cRecDesp,dDtZeraRD,,,,,,,,,aSelFil,,,,,,,,lCttSint)},;
				OemToAnsi(OemToAnsi(STR0014)),;  //"Criando Arquivo Tempor rio..."
				OemToAnsi(STR0003)+Upper(cSayCC)+ " / "+Upper(OemToAnsi(STR0021)))     //"Balancete Verificacao "
		
dbSelectArea("cArqTmp")
dbGoTop()    

//Se tiver parametrizado com Plano Gerencial, exibe a mensagem que o Plano Gerencial
//nao esta disponivel e sai da rotina.
If RecCount() == 0 .And. ! Empty(aSetOfBook[5])
	dbCloseArea()
	FErase(cArqTmp+GetDBExtension())
	FErase("cArqInd"+OrdBagExt())
	
	oReport:Cancel()

	Return .F.
Endif

// Verifica Se existe filtragem Ate o Segmento
If !Empty(cSegAte)
	nDigitAte := CtbRelDig(cSegAte,cMascara1) 	
EndIf

// Verifica Se existe filtragem Ate o Segmento de C.Custo
If !Empty(mv_par28)
	nDigCCAte := CtbRelDig(mv_par28,cMascara2) 	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia a impressao do relatorio                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//dbSelectArea("cArqTmp")
//dbGotop()

//Se tiver parametrizado com Plano Gerencial, exibe a mensagem que o Plano Gerencial
//nao esta disponivel e sai da rotina.

aSaldos := SldCCusto(oReport)

CTT->(DbSetOrder(1))

If ! ( RecCount() == 0 ) .And. Empty( aSetOfBook[5] )
	
	cGrupo := cArqTmp->GRUPO
	
	While mv_par33 == 1 .And. cArqTmp->TIPOCC == "2"
		dbSkip()
		cCusto := cArqTmp->CUSTO
	EndDo 
		
	While ! Eof()   
	
		If f180Fil( cSegAte, nDigitAte, nDigCCAte, cMascara1 , cMascara2 ) // regra de skip do relatorio
			dbSelectArea("cArqTmp")
			dbSkip()
			Loop
		EndIf

		//Imprime Section(1) Cabecalho                     
		If CTT->( ! DbSeek( xFilial( "CTT" ) + cArqTMP->CUSTO ))
			dbSelectArea("cArqTmp")
			dbSkip()
			Loop
		Else
			If !Empty(cFiltCTT) .And. !CTT->(&(cFiltCTT))
				dbSelectArea("cArqTmp")		
				dbSkip()
				Loop
			Endif		
	
			cCCAnt := cArqTmp->CUSTO 
			
			nPos := aScan( aSaldos, { |x| x[1] == cCCAnt}) 

			nCCSldAnt := aSaldos[nPos][2]
			nTotCCDeb := aSaldos[nPos][3]
			nTotCCCrd := aSaldos[nPos][4]
			nCCSldAtu := aSaldos[nPos][5]  
		
			nTotDeb 	:= aSaldos[nPos][3]
			nTotCrd 	:= aSaldos[nPos][4]
			nTotSldAnt	:= aSaldos[nPos][2]
			nTotSldAtu	:= aSaldos[nPos][5]
			nGrpDeb 	:= aSaldos[nPos][3]
			nGrpCrd 	:= aSaldos[nPos][4]
	
			oSection1:Init()
			oSection1:PrintLine()
			oReport:ThinLine()
	
			oSection1:Finish()
			oSection2:Init()
			
			While ! Eof() .And. (cCCAnt == cArqTmp->CUSTO) 
				
				If mv_par13 == 1 .And. cGrupo != cArqTmp->Grupo
					Exit				
				Endif
				
				If f180Fil( cSegAte, nDigitAte, nDigCCAte, cMascara1 , cMascara2 ) // regra de skip do relatorio
					dbSelectArea("cArqTmp")
					dbSkip()
					Loop
				EndIf
				
				IF ( MV_PAR07 == 3 .Or. ( ( MV_PAR07 == 1 .And. cArqTmp->TIPOCONTA == '1' ) .Or. ( MV_PAR07 == 2 .And. cArqTmp->TIPOCONTA == '2' ) ) )
					If !lVlrZerado .AND. cArqTmp->SALDOANT == 0 .AND. cArqTmp->SALDODEB == 0 .AND. cArqTmp->SALDOCRD == 0 .AND. cArqTmp->SALDOATU == 0						
						dbSkip()
						Loop
					Else
						oSection2:PrintLine()
					Endif
				Endif
				
				dbSkip()
			EndDo
	
			oSection2:Finish()
	
			If mv_par13 == 1 // Grupo Diferente - Totaliza e Quebra
				If cGrupo != cArqTmp->GRUPO
					oTotais:Init()
	
					oTotais:Cell("TOT"):SetTitle(OemToAnsi(STR0019) + cGrupo + " )")
					oTotais:Cell( "TOT_DEBITO"	):SetBlock( { || ValorCTB(nGrpDeb,,,TAM_VALOR-2,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr) } )
					oTotais:Cell( "TOT_CREDITO"):SetBlock( { || ValorCTB(nGrpCrd,,,TAM_VALOR-2,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr) } )
					
					oTotais:PrintLine()
					oTotais:Finish()
					oReport:EndPage()
					
					cGrupo	:= cArqTmp->GRUPO
				EndIf
			Else
				If (cCCAnt <> cArqTmp->CUSTO) // Imprime Totalizador do Centro de Custo
					
					oTotais:Cell("TOT"):SetTitle(OemToAnsi(STR0020)+ RTrim( Upper(cSayCC) ) + " : " )  //ALTEREI AQUI
					dbSelectArea("CTT")
					dbSetOrder(1)
					If MsSeek(xFilial("CTT")+cArqTmp->CUSTO)
						cCCSup	:= CTT->CTT_CCSUP	//Centro de Custo Superior
					Else
						cCCSup	:= ""
					EndIf
					If MsSeek(xFilial("CTT")+cCCAnt)
						cAntCCSup := CTT->CTT_CCSUP	//Centro de Custo Superior do Centro de custo anterior.
						cCCRes	  := CTT->CTT_RES
					Else
						cAntCCSup := ""
					EndIf
					dbSelectArea("cArqTmp")
					If mv_par23 == 2 //Se Impr. Cod. Red. C.C
						If CTT->CTT_CUSTO == cCCAnt .And. CTT->CTT_CLASSE == '2' //Se for analitico
							oTotais:Cell( "TOT"):SetBlock( { || EntidadeCTB(cCCRes,0 ,0 ,nTamCC,.F.,cMascara2,cSepara2,"CTT",,,,.F.) } )
						Else
							oTotais:Cell( "TOT"):SetBlock( { || EntidadeCTB(cCCAnt,0 ,0 ,nTamCC,.F.,cMascara2,cSepara2,"CTT",,,,.F.) } )
						EndIf
					Else//Se Imprime Cod. normal do C.Custo
						oTotais:Cell( "TOT"):SetBlock( { || EntidadeCTB(cCCAnt,0 ,0 ,nTamCC,.F.,cMascara2,cSepara2,"CTT",,,,.F.) } )
					Endif

					cCCNormal := Posicione("CTT" , 1 , xFilial("CTT") + cCCAnt , "CTT_NORMAL")

					oTotais:Cell( "TOT_SPACE"   ):SetBlock( { || "" } )  
					oTotais:Cell( "TOT_ANT"		):SetBlock( { || ValorCTB(nCCSldAnt,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cCCNormal,,,,,,lPrintZero,.F.,lColDbCr) } )
					oTotais:Cell( "TOT_DEBITO"	):SetBlock( { || ValorCTB(nTotCCDeb,,,TAM_VALOR-2,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr) } )
					oTotais:Cell( "TOT_CREDITO"	):SetBlock( { || ValorCTB(nTotCCCrd,,,TAM_VALOR-2,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr) } )

					If lMov
						// Totaliza Centro de Custo
						If lRedStorn
							nTotMov := (nTotCCDeb - nTotCCCrd)
							oTotais:Cell("TOT_MOV"):Enable()				
							oTotais:Cell("TOT_MOV"):SetBlock( { || ValorCTB(nTotMov,,,TAM_VALOR-2,nDecimais,.T.,cPicture," ",,,,,,lPrintZero,.F.,lColDbCr) } )
						Else
							nTotMov := (nTotCCCrd - nTotCCDeb)
							oTotais:Cell("TOT_MOV"):Enable()				
							oTotais:Cell("TOT_MOV"):SetBlock( { || ValorCTB(nTotMov,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cCCNormal,,,,,,lPrintZero,.F.,lColDbCr) } )
						Endif
					EndIf
					If lRedStorn
						oTotais:Cell( "TOT_ATU"		):SetBlock( { || ValorCTB(nCCSldAnt + (nTotCCDeb - nTotCCCrd),,,TAM_VALOR-2,nDecimais,.T.,cPicture," ",,,,,,lPrintZero,.F.,lColDbCr) } )
					Else
						oTotais:Cell( "TOT_ATU"		):SetBlock( { || ValorCTB(nCCSldAtu,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cCCNormal,,,,,,lPrintZero,.F.,lColDbCr) } )					
					Endif	
					
					// Imprime totalizado
				 	oTotais:Init()
					oTotais:PrintLine()
					oTotais:Finish()
				EndIf
			EndIF
		EndIf
		dbSelectArea("cArqTmp")
	EndDo
	         
	
	 nPos := aScan( aSaldos, { |x| x[1] == "TOTGERAL"}) 

	nCCSldAnt 	:= aSaldos[nPos][2]
	nTotCCDeb 	:= aSaldos[nPos][3]
	nTotCCCrd 	:= aSaldos[nPos][4]
	nCCSldAtu	:= aSaldos[nPos][5]  
	
	nTotDeb 	:= aSaldos[nPos][3]
	nTotCrd 	:= aSaldos[nPos][4]
	nTotSldAnt	:= aSaldos[nPos][2]
	nTotSldAtu	:= aSaldos[nPos][5]
	nGrpDeb 	:= aSaldos[nPos][3]
	nGrpCrd 	:= aSaldos[nPos][4]

	
	oTotais:Cell("TOT"):SetTitle(OemToAnsi(STR0018))
	oTotais:Cell("TOT"):SetBlock({|| ""})
	oTotais:Cell("TOT_ANT"):SetBlock( { || ValorCTB(nTotSldAnt,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.,lColDbCr) } )
	oTotais:Cell("TOT_DEBITO"):SetBlock( { || ValorCTB(nTotDeb,,,TAM_VALOR-2,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr) } )
	oTotais:Cell("TOT_CREDITO"):SetBlock( { || ValorCTB(nTotCrd,,,TAM_VALOR-2,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr) } )

    If lMov
		If lRedStorn
			nTotMov := (nTotDeb - nTotCrd)
			oTotais:Cell("TOT_MOV"):Enable()
			oTotais:Cell("TOT_MOV"):SetBlock( { || ValorCTB(nTotMov,,,TAM_VALOR-2,nDecimais,.T.,cPicture," ",,,,,,lPrintZero,.F.,lColDbCr) } )
		Else
			nTotMov := (nTotCrd - nTotDeb)
			oTotais:Cell("TOT_MOV"):Enable()
			If Round(NoRound(nTotMov,3),2) < 0
				oTotais:Cell("TOT_MOV"):SetBlock( { || ValorCTB(nTotMov,,,TAM_VALOR-2,nDecimais,.T.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr) } )
			ElseIf Round(NoRound(nTotMov,3),2) >= 0
				oTotais:Cell("TOT_MOV"):SetBlock( { || ValorCTB(nTotMov,,,TAM_VALOR-2,nDecimais,.T.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr) } )
			EndIf
		Endif
	EndIf

	If lRedStorn
		oTotais:Cell("TOT_ATU"):SetBlock( { || ValorCTB(nTotSldAnt + (nTotDeb - nTotCrd),,,TAM_VALOR-2,nDecimais,.T.,cPicture," ",,,,,,lPrintZero,.F.,lColDbCr) } )
	Else
		oTotais:Cell("TOT_ATU"):SetBlock( { || ValorCTB(nTotSldAtu,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.,lColDbCr) } )
	Endif
	
	// Imprime totalizado
	oTotais:Init()
	oTotais:PrintLine()
	oTotais:Finish()
	
EndIf

dbSelectArea("cArqTmp")

Set Filter To
dbCloseArea()

If Select("cArqTmp") == 0
	//	Ferase(cArqTmp+GetDBExtension())
	//	FErase("cArqInd"+OrdBagExt())
EndIf

dbselectArea("CT2")
RestInter()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³f180Fil   ºAutor  ³Cicero J. Silva     º Data ³  24/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBR180                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function f180Fil(cSegAte,nDigitAte,nDigCCAte,cMascara1,cMascara2)
Local lDeixa	:= .F.

If mv_par33 == 1					// So imprime Sinteticas
	If cArqTmp->TIPOCC == "2"
		lDeixa := .T.
	EndIf
ElseIf mv_par33 == 2				// So imprime Analiticas
	If cArqTmp->TIPOCC == "1"
		lDeixa := .T.
	EndIf
EndIf

If mv_par07 == 1					// So imprime Sinteticas
	If cArqTmp->TIPOCONTA == "2"
		lDeixa := .T.
	EndIf
ElseIf mv_par07 == 2				// So imprime Analiticas
	If cArqTmp->TIPOCONTA == "1"
		lDeixa := .T.
	EndIf
EndIf

//Filtragem ate o Segmento da Conta( antigo nivel do SIGACON)
If !Empty(mv_par14)
	If Len(Alltrim(cArqTmp->CONTA)) > nDigitAte
		lDeixa := .T.
	Endif
EndIf

//Filtragem ate o Segmento do CC( antigo nivel do SIGACON)
If !Empty(mv_par28)
	If Len(Alltrim(cArqTmp->CUSTO)) > nDigCCAte
		lDeixa := .T.
	Endif
EndIf


dbSelectArea("cArqTmp")

Return (lDeixa)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SldCCusto ºAutor  ³TOTVS               º Data ³  25/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SldCCusto(oReport,cFilt)
Local aSaldos := {}
Local aCcusto := {}
Local cCusto  := ""
Local nSldDeb := 0  
Local nSldCrd := 0
Local nSldAnt := 0   
Local nSldAtu := 0
Local nTotAnt := 0
Local nTotDeb := 0
Local nTotCrd := 0
Local nTotAtu := 0   
Local oSection1 := ""
Local cFiltCTT	:= ""

	oSection1 := oReport:Section(1) 
	cFiltCTT  :=oSection1:Getadvplexp('CTT')	

While mv_par33 == 1 .And. cArqTmp->TIPOCC == "2"
	dbSkip()
EndDo  

cCusto := cArqTmp->CUSTO

While !Eof()

   If !Empty(cFiltCTT)
       dbSelectArea("cArqTmp")		
   Endif             

	If cArqTmp->TIPOCONTA == "2"   

		If cCusto == cArqTmp->CUSTO         
			nSldAnt	+= cArqTmp->SALDOANT  
			nSldDeb += cArqTmp->SALDODEB	     
			nSldCrd += cArqTmp->SALDOCRD	     
		    nSldAtu += cArqTmp->SALDOATU  
		    
			If cArqTmp->TIPOCC == "2"
				nTotAnt	+= cArqTmp->SALDOANT  
				nTotDeb += cArqTmp->SALDODEB	     
				nTotCrd += cArqTmp->SALDOCRD	     
		    	nTotAtu += cArqTmp->SALDOATU  
		    Endif
		Else 
			AADD(aCCusto, cCusto)
	    	AADD(aCCusto, nSldAnt) 
		    AADD(aCCusto, nSldDeb) 
			AADD(aCCusto, nSldCrd) 	    
			AADD(aCCusto, nSldAtu) 	    
	    
	        AADD(aSaldos,aCCusto) 
    	    aCCusto := {} 
        
	        cCusto  := cArqTmp->CUSTO
    	    nSldAnt := cArqTmp->SALDOANT
        	nSldDeb := cArqTmp->SALDODEB
	        nSldCrd := cArqTmp->SALDOCRD
    	    nSldAtu := cArqTmp->SALDOATU  
    	    
    	    If cArqTmp->TIPOCC == "2"
	    	    nTotAnt	+= cArqTmp->SALDOANT  
				nTotDeb += cArqTmp->SALDODEB	     
				nTotCrd += cArqTmp->SALDOCRD	     
		    	nTotAtu += cArqTmp->SALDOATU  
            Endif 
		Endif
	
	Endif

	dbSkip()
EndDo  

If !Empty(cFiltCTT)
	AADD(aCCusto, cCusto)
	AADD(aCCusto, nSldAnt) 
	AADD(aCCusto, nSldDeb) 
	AADD(aCCusto, nSldCrd) 	    
	AADD(aCCusto, nSldAtu) 	    
	AADD(aSaldos, aCCusto)
	aCCusto := {}
	
	AADD(aCCusto, "TOTGERAL")
	AADD(aCCusto, nSldAnt) 
	AADD(aCCusto, nSldDeb) 
	AADD(aCCusto, nSldCrd) 	    
	AADD(aCCusto, nSldAtu)    
	AADD(aSaldos,aCCusto) 
Else
	AADD(aCCusto, cCusto)
	AADD(aCCusto, nSldAnt) 
	AADD(aCCusto, nSldDeb) 
	AADD(aCCusto, nSldCrd) 	    
	AADD(aCCusto, nSldAtu) 	    
	AADD(aSaldos, aCCusto)
	aCCusto := {}  
	
	AADD(aCCusto, "TOTGERAL")
	AADD(aCCusto, nTotAnt) 
	AADD(aCCusto, nTotDeb) 
	AADD(aCCusto, nTotCrd) 	    
	AADD(aCCusto, nTotAtu) 	    
	AADD(aSaldos,aCCusto) 
Endif	

dbGoTop()

Return aSaldos