#INCLUDE "PROTHEUS.CH"
#INCLUDE "ACADEF.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FINA070.CH"
#INCLUDE "FWLIBVERSION.CH"

Static lIsRussia := cPaisLoc == 'RUS'
Static nFirstRsn :=Iif(lIsRussia,nFirstRsn := 2,  nFirstRsn := 1)
Static lOpenCmc7
Static aPrefixo
Static lFDataUse
Static __lF070AltV
Static __F070VDATA 
Static lFinImp		:= .T.       //Define se ha retencao de impostos PCC/IRPJ no R.A  
Static dLastPcc		:= CTOD("22/06/2015")
Static __lRatAut	:= .F.
Static lMVGlosa		:= SuperGetMv("MV_GLOSA",.F.,.F.)
Static __lF070EAI	:= NIL
Static cAliasLote	:= ""
Static lTSE5FI70E	:= ExistTemplate("SE5FI70E")
Static lGEMSE5Grv	:= HasTemplate("LOT") .and. ExistTemplate("GEMSE5Grv")
Static lSE5FI70E	:= ExistBlock("SE5FI70E")
Static lF070GerAb	:= ExistBlock("F070GerAb")
Static lF070CTC		:= ExistBlock("F070CTC")
Static lF070EST		:= ExistBlock("F070EST")
Static lF070EST2	:= ExistBlock("F070EST2")
Static lF070HisCan	:= ExistBlock("F070HisCan")
Static __aVAAuto	:= NIL
Static lPodeTVA		:= ExistFunc("FAPodeTVA")
Static lCpoSIX		:= ExistFunc("FinCposSix")
Static lF070ACRE	:= ExistBlock("F070ACRE")
Static lFA070POS	:= ExistBlock("FA070POS")
Static lF070TCTR	:= ExistBlock("F070TCTR")
Static lFA070ACR	:= ExistBlock("FA070ACR")
Static lF070ACONT	:= ExistBlock("F070ACONT")
Static lF070CTB		:= ExistBlock("F070CTB")
Static lSACI008		:= ExistBlock("SACI008")
Static __lFPIXatv   := FindFunction("PIXIsActiv")
Static __lImpPix 	:= FindFunction("RetImpBxCR")	
Static __lBordImp   := FindFunction("BorderoImp")
Static __lTemBx  	:= FindFunction("FTemBxParc")
Static __lFa070Ca4	:= ExistBlock("FA070CA4")
Static __lF070Cancel:= ExistBlock("F070CANCEL")
Static __lF070BAUT	:= ExistBlock("F070BAUT")
Static __lF070CABT	:= EXISTBLOCK("F070CANABT")
Static __lF70ALTABAT:= ExistBlock("F70ALTABAT")
Static __lF070CHDV	:= ExistBlock("F070CHDV")
Static __lTravaSa1	:= ExistBlock("F070TRAVA")
Static __lF070DCDes := ExistBlock("F070DCDesc")
Static __lF070JRVlr := ExistBlock("F070JRVlr")
Static __lFA070CA3	:= ExistBlock("FA070CA3")
Static __FA070CAN	:= ExistBlock("FA070CAN")
Static __FA070CA2 	:= ExistBlock("FA070CA2")

Static __nBxaPrin   := 0

Static __lF70TREA 	:= .F.
Static __lCancTBx   := .F.
// Motor de retenção 
Static __lTemMR		:= NIL
Static __nTotImp	:= 0
Static nOldImp 		:= 0
Static __nMRBxTot	:= 0	// Armazenar o valor total de impostos de motor se baixa fosse total
Static __oRetMot 	as Object
Static __lMotor 	as Logical
Static __lPccMR		as Logical
Static __lInsMR		as Logical
Static __lIrfMR		as Logical
Static __lIssMR		as Logical
Static __lImpMR  	as Logical
Static __lPropPcc 	as Logical
Static __lGlosaMr 	as Logical // Substituição da usabilidade do parâmetro MV_GLOSA pela configuração FKM_PGTPAR
Static __lGlosIrf 	as Logical
Static __lGlosPis 	as Logical
Static __lGlosCof 	as Logical
Static __lGlosCsl 	as Logical
Static __lGlosIss 	as Logical
Static __lGlosIns 	as Logical
Static __lGlosOut 	as Logical
Static __lMetric	:= .F.
Static __cFunBkp	:= ""
Static __cFunMet	:= ""
Static __lCalcImp   := .F.
Static __lCnabImp   := .F.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  FINA070  ³ Autor ³ Wagner Xavier        ³ Data ³ 26/05/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Baixa de Titulos a Receber                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FINA070()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jose Glez   ³03/08/17³MMI-6282³Problemas de performance,Se modifica    ³±±
±±³            ³        ³        ³la busqueda para cuando exista Recibos  ³±±
±±³            ³        ³        ³y ubicarlo por la serie del recibo      ³±±
±±³LuisEnríquez³16/07/18³DMINA-  ³Se replica funcionalidad atendida en    ³±±
±±³(PER)       ³        ³3630    ³DMINA-62 de Facturación de Anticipos.   ³±±
±±³Oscar Garcia³13/08/18³DMINA-³Se realiza modificación en func. fA070Tit ³±±
±±³            ³        ³3752  ³para convertir nParciais a moneda 1. (MEX)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function xFinA070( xAutoCab, nOpc, lNoMbrowse, nOpbaixa, cFiltro ,aParam ,lRatAuto ,aVAAut ,aRatEvEz, lCtbBx, lMov,lPix )
Local nPosDtCred	:= 0
Local nPos			:= 0
Local lPanelFin		:= IsPanelFin()
Local lRet			:= .T.
Local nRecSv		:= 0

Private lF070Auto	:= (xAutoCab <> NIL)
Private aAutoCab	:= {}
Private cPortado	:= CriaVar("E1_PORTADO",.F.)
Private cBanco		:= CriaVar("E1_PORTADO",.F.)
Private cAgencia	:= CriaVar("E1_AGEDEP" ,.F.)
Private cConta		:= CriaVar("E1_CONTA"  ,.F.)
Private cNatMov     := ''
Private lValidou	:= .F.
Private lOracle		:= "ORACLE"$Upper(TCGetDB())
Private aDadosRef	:= Array(7)
Private lFini055	:= FwIsInCallStack("FINI055")
Private aRatAut		:= {}
Private lCtb060		:= .T.

Default nOpc		:= 3
Default lNoMBrowse	:= .F.
Default nOpBaixa	:= 1
Default cFiltro		:= NIL
Default lRatAuto	:= .F.
Default aRatEvEz 	:= {}
Default lCtbBx		:= .T.
Default lMov		:= .T. //Russia controling to create or not bank moviment
Default lPix		:= .F.
lCtb060 := lCtbBx

//Inicialização de variáveis estáticas
lFinImp		:= .T. //Define se ha retencao de impostos PCC/IRPJ no R.A
dLastPcc	:= CTOD("22/06/2015")
__lRatAut	:= .F.
lMVGlosa	:= SuperGetMv("MV_GLOSA",.F.,.F.)
__lF070EAI	:= NIL
cAliasLote	:= ""
lTSE5FI70E	:= ExistTemplate("SE5FI70E")
lGEMSE5Grv	:= HasTemplate("LOT") .and. ExistTemplate("GEMSE5Grv")
lSE5FI70E	:= ExistBlock("SE5FI70E")
lF070GerAb	:= ExistBlock("F070GerAb")
lF070CTC	:= ExistBlock("F070CTC")
lF070EST	:= ExistBlock("F070EST")
lF070EST2	:= ExistBlock("F070EST2")
lF070HisCan	:= ExistBlock("F070HisCan")
__aVAAuto	:= NIL
lPodeTVA	:= ExistFunc("FAPodeTVA")
lCpoSIX		:= ExistFunc("FinCposSix")
lF070ACRE	:= ExistBlock("F070ACRE")
lFA070POS	:= ExistBlock("FA070POS")
lF070TCTR	:= ExistBlock("F070TCTR")
lFA070ACR	:= ExistBlock("FA070ACR")
lF070ACONT	:= ExistBlock("F070ACONT")
lF070CTB	:= ExistBlock("F070CTB")
lSACI008	:= ExistBlock("SACI008")
__lF70TREA	:= .F.
__lCancTBx	:= .F.
__lMetric	:= FwLibVersion() >= "20210517" 
__lCnabImp := SuperGetMv("MV_CNABIMP", .F., .F.)

//Restringe o uso do programa ao Financeiro e Sigaloja
If !(AmIIn(5,6,12,11,14,41,97,33,49,59,72))		// S¢ Fat,Fin,Loja,Veiculos,Ofina, Pecas, Especiais e PLS, 49-GE, 59-GAC
	Return
EndIf

If lF070Auto .and. lPodeTVA
	//Valores Acessórios - Rotina Automatica Bx CR
	If (aVAAut <> Nil )
		__aVAAuto := aClone(aVAAut)
	Else
		__aVAAuto := {}
	EndIf
EndIf

If lF070Auto .and. len(aRatEvEz) > 0
	aRatAut := aClone(aRatEvEz)
EndIf

//Tratamento para não redeclarar as variáveis.
//No retorno CNAB com calculo de PCC + IR esta variável já vem declarada.
If Type("nValRec")=="U"
	PRIVATE nValRec := 0
EndIf
If Type("nOldValRec")=="U"
	PRIVATE nOldValRec := 0
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Vari veis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina 	 := MenuDef()
PRIVATE nValTot 	 := 0
PRIVATE nJuros		 := 0
PRIVATE nVA			 := 0
PRIVATE nMulta		 := 0
PRIVATE nPIS    	 := 0
PRIVATE nCOFINS    	 := 0
PRIVATE nCSLL    	 := 0
PRIVATE nIss		 := 0
PRIVATE nInss		 := 0
PRIVATE nlImpMR 	 := 0
PRIVATE nCM			 := 0
PRIVATE nDescont	 := 0
PRIVATE nTotAGer     := 0
PRIVATE nTotADesp    := 0
PRIVATE nTotADesc    := 0
PRIVATE nTotAMul     := 0
PRIVATE nTotAJur     := 0
PRIVATE nValPadrao   := 0
PRIVATE nValEstrang  := 0
PRIVATE cMarca       := Get070Mark()
PRIVATE cLote		 := ""
PRIVATE cLoteFin     := If(Type("cLoteFin") != "C", Space(TamSX3("E1_LOTE")[1]), cLoteFin)
PRIVATE cNaturLote   := Space (10)
PRIVATE nAcresc      := 0
PRIVATE nDecresc     := 0
PRIVATE aCaixaFin    := xCxFina() // Caixa Geral do Financeiro (MV_CXFIN)
PRIVATE aCols		 := {}
PRIVATE aHeader		 := {}
PRIVATE nMoedaBco	 := 1
PRIVATE nCM1      	 := 0
PRIVATE nProRata  	 := 0
PRIVATE cCodDiario	 := ""
PRIVATE nVlRetPis	 := 0
PRIVATE nVlRetCof	 := 0
PRIVATE nVlRetCsl	 := 0
PRIVATE aDadosRet 	 := Array(7)
PRIVATE nIrrf 		 := 0
PRIVATE nOldIrrf	 := 0

//Variaveis utilizada para acrescimo e decrescimo
PRIVATE aBxAcr		:= {}
PRIVATE aBxDec		:= {}
PRIVATE nDecrVlr		:= 0		//tratar visualizacao da varivel na tela de valores
PRIVATE nOdlMoedBco	 := 1

PRIVATE nTxMoeda

LoteCont( "FIN" )

PRIVATE oFontLbl, oFontAnt
PRIVATE lInverte := .F.

//***Reestruturacao SE5***
Private nPisCalc	:= 0
Private nCofCalc	:= 0
Private nCslCalc	:= 0
Private nIrfCalc	:= 0
Private nIssCalc	:= 0
Private nPisBaseR 	:= 0
Private nCofBaseR	:= 0
Private nCslBaseR 	:= 0
Private nIrfBaseR 	:= 0
Private nIssBaseR 	:= 0
Private nPisBaseC 	:= 0
Private nCofBaseC 	:= 0
Private nCslBaseC 	:= 0
Private nIrfBaseC 	:= 0
Private nIssBaseC 	:= 0
//***Reestruturacao SE5***

Private aParamAuto	:= {}

//Valida a existência da das tabelas do Motor de retenção
If __lTemMR == NIL
	__lTemMR := If(FindFunction("FTemMotor"), FTemMotor(), .F.)
EndIf
__lRatAut := lRatAuto
__lF70TREA 	:= ExistBlock("F070TREA")

VALOR := 0

If !lPanelFin
	SetKey (VK_F12,{|a,b| AcessaPerg("FIN070",.T.)})
Else
	SetKey (VK_F12,{|a,b| PergInPanel("FIN070",.T.)})
EndIf

If FunName() <> "FINA415"
	Pergunte("FIN070",.F.)
	aParamAuto := If(aParam <> Nil,aParam,Nil)
	FI070PerAut()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabe‡alho da tela de baixas                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := STR0006 // "Baixa de Titulos"

If lNoMBrowse
	dbSelectArea("SE1")
	If ( nOpc <> 0 ) .And. !Deleted()
		bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nOpc,2 ] + "(a,b,c,d,e) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nOpc)
	EndIf
Else
	If !lF070Auto
		DEFINE FONT oFontLbl NAME "Arial" SIZE 6, 15 BOLD

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada para pre-validar os dados a serem  ³
		//³ exibidos.                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF ExistBlock("F070BROW")
			ExecBlock("F070BROW",.f.,.f.)
		Endif

		mBrowse(6, 1, 22, 75, "SE1",,,,,, Fa040Legenda("SE1"),,,,,,,, Iif(ExistBlock("F070FILB"), ExecBlock("F070FILB", .F., .F.), Nil))

		If GetMv("MV_CMC7FIN") == "S"
			CMC7Fec(nHdlCMC7,GetMv("MV_CMC7PRT"))
		EndIf
		lOpenCmc7 := Nil

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Recupera a Integridade dos dados                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SET KEY VK_F12 to
		RELEASE FONT oFontLbl
	Else
		dbSelectArea('SE1')
		If FwIsInCallStack("FINA550") .or. FwIsInCallStack("FINA450")
			nRecSv:= SE1->(Recno())
		Endif	
		
		aAutoCab := SE1->(MSArrayXDB(xAutoCab,nil,4))
		
		If Len(aAutoCab) == 0
			Return
		EndIf
		
		If FwIsInCallStack("FINA550") .or. FwIsInCallStack("FINA450")
			SE1->(dbGoto(nRecSv))
		Endif
		
		If (nPos := aScan(aAutoCab,{|x| x[1] == 'AUTMOTBX'})) > 0 .AND. (aAutoCab[nPos][2] == 'TRF')
			If (nPos := aScan(aAutoCab,{|x| x[1] == 'AUTVALREC'})) >0
				nPosDtCred := aScan(aAutoCab,{|x| x[1] == 'AUTDTBAIXA'})
				aAutoCab[nPos][2] := xMoeda(aAutoCab[nPos][2],SE1->E1_MOEDA,1,aAutoCab[nPosDtCred][2])
			EndIf
		EndIf
		
		If nOpc == 3
            If (nPos := ascan(aAutoCab, {|x| x[1] == "AUTBANCO"})) > 0
				cBanco := aAutoCab[nPos,2]
				
				If (nPos := ascan(aAutoCab, {|x| x[1] == "AUTAGENCIA"})) > 0
					cAgencia := aAutoCab[nPos,2]
				EndIf
				
				If (nPos := ascan(aAutoCab, {|x| x[1] == "AUTCONTA"})) > 0
					cConta := aAutoCab[nPos,2] 
				EndIf
			EndIf
			
			If (FindFunction("FOrigTitRM") .AND. FindFunction("ValidarBXTIN") .AND. FOrigTitRM("SE1"))
		  		lRet := ValidarBXTIN(xAutoCab)	
			EndIf
			
			If lRet
				lRet := u_xfA070Tit("SE1",SE1->(Recno()),4,,.T.,lPix)			 
			EndIf
			
			If __nBxaPrin > 0 .And. (nPos := Ascan(xAutoCab, {|x| x[1] == "AUTREGBXPRIN"})) > 0
				xAutoCab[nPos, 2] := __nBxaPrin
			EndIf
			
			__nBxaPrin := 0
		ElseIf nOpc == 5	// Cancelamento
			If lIsRussia //Russia
				fA070Can("SE1",Recno(),5,,nOpbaixa)
			Else
				fA070Can("SE1",Recno(),5,,nOpbaixa)
			Endif
		ElseIf nOpc == 6		// Exclusão
			fA070Can("SE1",Recno(),6,,nOpbaixa)
		Endif
	EndIf
EndIf

//Limpa a variável estática que indica se a tela de baixa foi cancelada (controle de processo com integração Protheus x TIN)
__lCancTBx := .F.

If lPodeTVA
	//Valores Acessórios

	If (__aVAAuto <> Nil )
		aSize(__aVAAuto,0)
		__aVAAuto := Nil
	Endif
EndIf

//Limpa os objetos criados pelo cálculo de IR
IF FindFunction("FObjClean")
	FObjClean()
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fA070Tit ³ Autor ³ Wagner Xavier         ³ Data ³ 26/05/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fun‡„o utilizada para Baixa de Titulos                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fA070Tit()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function xfA070Tit(cAlias,nReg,nOpcx,aM,lAut,lPix)
LOCAL oDlg
LOCAL oCbx
LOCAL oCodCli
LOCAL aDescMotbx		:= {}
LOCAL oMulta
LOCAL oJuros
LOCAL oVA
LOCAL oPIS
LOCAL oCOFINS
LOCAL oCSLL
LOCAL oOtrga
LOCAL oDifCambio
LOCAL nDecrescF
LOCAL nOpt
LOCAL nHdlPrv			:= 0
LOCAL nTotal			:= 0
LOCAL lPadrao
LOCAL cArquivo
LOCAL lRet     			:= .T.
LOCAL nSalvRec			:= 0
LOCAL cParcela
LOCAL cNum				:= CRIAVAR ("E1_NUM",.F.)
LOCAL cPrefixo
LOCAL cMoeda
LOCAL nOrdem
LOCAL nT				:= 0
LOCAL nY				:= 0
LOCAL nErro				:= 0
LOCAL lBaixou			:= .F.
LOCAL lJuros
LOCAL aCaixaLoja
LOCAL nTolerPg			:= GetMv("MV_TOLERPG")
Local lFINA200			:= FunName() == "FINA200" .Or. FwIsInCallStack("fA200Ger")
Local lREC2TIT			:= SuperGetMv("MV_REC2TIT",,"2") == "1"
Local lFina450			:= FwIsInCallStack("Fa450cmp")
LOCAL lContabiliza		:= Iif(mv_par04==1,.T.,.F.) .and. !lFINA200 .and. !lFina450
Local lFa070Tit			:= ExistBlock("FA070TIT")
Local lTFa070Tit		:= ExistTemplate("FA070TIT")
Local lFa070MDB			:= ExistBlock("FA070MDB")
Local lMdbOk			:= .F.
LOCAL aMotBx			:= ReadMotBx()
LOCAL nEstOriginal		:= 0
Local cMoedaTx, nA		:= 0
LOCAL aModalSpb			:= {"1=TED","2=CIP","3=COMP"}
LOCAL oModSpb
LOCAL lSpbInUse			:= SpbInUse()
Local oTxMoeda
Local nUltLin
Local bSetKey			:= {||}
Local oMultNat
Local lOk				:= .F. //Controla se foi confirmada a distribuicao
Local aColsSEV			:= {}
Local NI
Local lFa070Bco			:= ExistBlock("FA070BCO")
Local lF070Bxpc			:= ExistBlock("F070BXPC")
Local aArea				:= GetArea()
Local nTotAdto			:= 0
Local lBaixaAbat		:= .F.
Local nVlrBaixa			:= 0
Local lBxCec			:= .F.
Local lBxLiq			:= .F.
Local cTipo
Local cCliente
Local cLoja
Local aBaixa			:= {}
Local x
Local nLinha			:= 0
Local aButtons			:= {}
Local lImpBxCr			:= GetNewPar( "MV_IMPBXCR", "1" ) == "2"
LOCAL oValorLiq
Local nLin2				:= 0
Local oCM1
Local oProRata
Local lGemInUse			:= .F.
Local aSeqSe5			:= {} // Para gravar a sequencia no SEF com a mesma sequencia dos movimentos bancarios gerados
Local nVlMinImp			:= GetNewPar("MV_VL10925",5000)
Local lPanelFin			:= IsPanelFin()
LOCAL oNaturez
LOCAL oTipo
LOCAL aDiario			:= {}
Local aGrvLctPco		:= {{"000004","09","FINA070"},;
							{"000004","10","FINA070"}}
Local aFlagCTB			:= {}
Local lUsaFlag			:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Local lAcessMul			:= .T.
Local lAcessJur			:= .T.
Local lAcessDesc		:= .T.
Local lAcessdBaixa		:= .T.
Local lAcessDtCredito	:= .T.
Local lAcessCSLL			:= .T.
Local lAcessCOF			:= .T.
Local lAcessPIS			:= .T.
Local lMultNat 			:= .F.

Local oDtBaixa
Local oDtCredito
Local aCposDes			:= {}
Local nTotMult			:= 0

//Controla o Pis Cofins e Csll na baixa  (1-Retem PCC na Baixa ou 2-Retem PCC na Emissão(default) )
Local lPccBxCr			:= FPccBxCr(.T.)
Local lEECFIN			:= SuperGetMv("MV_AVG0131",.F.,.F.) //DFS - 17/02/11 - Parâmetro para verificar integração com financeiro.
Local aHdlPrv			:= {}

Local lIrPjBxCr			:= FIrPjBxCr(.T.)	 //Controla IRPJ na baixa
Local oIrrf

Local lTipBxCP			:= .F.
Local lSigaloja			:= .F.

Local lF070VLAD			:= ExistBlock("F070VLAD")

Local lSubsPrv			:= FwIsInCallStack("FINA040")
Local lFA070BLQ			:= ExistBlock("FA070BLQ")
Local lLibCm			:= .F.
Local lVlTitCR			:= GetNewPar("MV_VLTITCR",.F.)
Local lTpDesc			:= cPaisLoc == "BRA" //Verifica campo TPDESC na tabela SE5 (<C>ondicional ou <I>ncondicional)
Local lNatApura			:= .F. //Natureza configurada para apurar impostos no SPED PIS/COFINS.
Local lCposSped			:= cPaisLoc == "BRA" //Campos que apuram impostos no SPED PIS/COFINS.
Local aAreaSED 			:= {}
Local lRMBibli			:= GetNewPar('MV_RMBIBLI',.F.)
Local lRMClass			:= GetNewPar('MV_RMCLASS',.F.)
Local lBQ10925			:= .F.
Local cFilOrgTr			:= "" //Filial de origem do documento de ISS, processo de transferência
Local nTotAbISS			:= 0 //Valor do abatimento de ISS na origem, processo de transferência
Local oMasterPanel
Local lMoedaBco			:= SuperGetMv("MV_MOEDBCO",, .F.)
Local dDtRecbAux
Local nValOld			:= 0
//desconto da bolsa para classis
Local nDescBol			:= 0
Local cAuxMBx			:= ""
Local lSaveState		:= ALTERA
Local aAlt				:= {}
Local cChaveTit		:= ""
Local cChaveFK7		:= ""
Local aPcc       := {}
Local nBase      := 0
Local lJurMulDes := (SuperGetMv("MV_IMPBAIX",.t.,"2") == "1")
Local nPccRetPrc := 0
Local lGerChqAdt := .F.
Local cTipoOr    := ""
Local aBaixas    := {}
Local aVlOringl  := Array( 8 )//|1=Valor recebido|2=Pis|3=Cofins|4=Csll|5=Juros|6=Multa|7=Desconto|8=Base
local lCalcPCC	 := .T.
Local lRecIss	 := .F.
Local lCalcIssBx := GetNewPar("MV_MRETISS","1") == "2"  //Retencao do ISS pela emissao (1) ou baixa (2)
Local nPos       := 0
Local lSDACRVL   := SuperGetMv("MV_SDACRVL",.T.,.F.)
Local lSDDECVL	 := .F.
Local aRelTit	 := {}									//Array contendo o titulo baixado para impressao do Recibo
Local aFormPg	 := {}									//Array contendo os pagamento em cheque para impressao do Recibo
Local lLojrRec	 := FindFunction("LOJRREC")				//Relatorio de impressao de Recibo (OBSOLETO)
Local lULOJRREC	 := FindFunction("U_LOJRRecibo")		//Relatorio de impressao de Recibo (RDMAKE)
Local lImpLjRe	 := SuperGetMV( "MV_IMPLJRE",.F., .F.)
Local aAreaSe1	 := {}
Local aAreaSe5	 := {}
Local aAreaRec	 := {}
//Valores Acessorios
Local oModelVA	 := Nil
Local nLaco		 := 0
Local aFKDID	 := {}
//Validaca da Baixa para nao permitir a baixa apenas no Protheus da Integracao RM Classis X Protheus
Local cProdRM	 := SuperGetMv('MV_RMORIG',, "E|U|S")
Local lExistVA 	 := TableInDic("FKD") .and. TableInDic("FKC")
Local lFKDID     := lExistVA .And. FKD->( FieldPos("FKD_IDFKD") ) > 0 .And. ExistFunc("FN040VAID") // Proteção campo criado 12.1.25
Local cAcaoVA    := ""
Local nVaCalc    := 0
Local cAuxMoeda  := ""
Local lCalcCM    := GetMv("MV_CALCCM") == "S"
Local cBxDtFin   := SuperGetMv( "MV_BXDTFIN",, "1" )
Local lSaldoChq  := GetMv("MV_SLDBXCR") == "C"
Local lAntCred   := GetMv("MV_ANTCRED")
Local cPrefRM    := SuperGetMv("MV_PREFRM",,"TIN")
Local aRetInteg	 := {}
Local nRecSe1    := 0
Local lJFilBco   := ExistFunc("JurVldSA6") .And. SuperGetMv("MV_JFILBCO", .F., .F.) //Indica se filtra as contas correntes vinculadas ao escritório logado - SIGAPFS
Local cEscrit    := IIF(lJFilBco, JurGetDados("NS7", 4, xFilial("NS7") + cFilant + cEmpAnt, "NS7_COD"), "")
Local cF3Bco     := IIF(lJFilBco, "SA6JUR", "SA6")
Local nDecs		 := SuperGetMv("MV_CENT",,3)
Local lMudouMulta   := .F.
Local nDtContOn		:= SuperGetMv("MV_DTCNBX",.F.,1) // Data para contabilização Online baixas receber 1- Data Digitação; 2- Data Disponibilidade; 3- Data Recebimento

// Motor de Retenção
Local aImpos 	    as Array	// Motor de retenção
Local lTemImpPad    := .F.
Local nW            := 0
Local nImp          := 0
Local cMsg          := ""
Local nAux2			:= 0
Local nAuxImpAut	:= 0
Local nOldTxmoeda	:= 0
Local nValParc      := 0
Local nOldMoeBco    := 1
Local nCountCH		:= 0
Local oNomCli		:= NIl
Local cSituaCob     := "0"
//Projeto FKS
Local aTitCalc	    := {}
Local dDtLanc		:= dDataBase 
Local lImpPIx		:= .F.
Local aImpPix 		:= {}
Local nInicio		:= 0
Local nFim			:= 0
Local lModDesIss    := SuperGetMv("MV_DESCISS", .F., .F.)
Local lSC5RecIss    := SC5->(FieldPos("C5_RECISS")) > 0
Local cTipoCm	 	:= SuperGetMv("MV_TIPOCM", .T., "T") 
Local lFina415		:= FwIsInCallStack("FINA415")

PRIVATE lRaRtImp	:= lFinImp .And.FRaRtImp()     //Define se ha retencao de impostos PCC/IRPJ no R.A
PRIVATE nParciais	:= 0
PRIVATE aBaixaSE5		:= {}
PRIVATE cMotBx		:= ""
PRIVATE oVlEstrang	:= nil
PRIVATE oValRec		:= nil
PRIVATE oCM			:= nil
PRIVATE oAgencia	:= oBanco	:= oConta := nil
PRIVATE oDescont	:= nil
PRIVATE nOtrga		:= 0
PRIVATE nDifCambio	:= 0
PRIVATE aTxMoedas	:= {}
PRIVATE cModSpb		:= "1"
PRIVATE nAcrescF	:= 0
//Variaveis PRIVATE utilizadas pela funcao FA040AxAlt()
PRIVATE nIndexSE1	:= ""
PRIVATE cIndexSE1	:= ""
PRIVATE lAltera		:= .T.
PRIVATE nOldValor	:= SE1->E1_VALOR
PRIVATE nOldIss		:= SE1->E1_ISS
PRIVATE nOldInss	:= SE1->E1_INSS
PRIVATE nOldPis		:= SE1->E1_PIS
PRIVATE nOldCofins	:= SE1->E1_COFINS
PRIVATE nOldCsll	:= SE1->E1_CSLL
PRIVATE nOldVlAcres	:= SE1->E1_ACRESC
PRIVATE nOldIrrf	:= SE1->E1_IRRF
PRIVATE nOldVlDecres:= SE1->E1_DECRESC
PRIVATE lAlterNat	:= .F.
PRIVATE nOldVencto	:= SE1->E1_VENCTO
PRIVATE nOldVenRea	:= SE1->E1_VENCREA
PRIVATE cOldNatur	:= SE1->E1_NATUREZ
PRIVATE nOldVlCruz	:= SE1->E1_VLCRUZ
PRIVATE lAlterImp	:= .F.
PRIVATE aDadosRet	:= {}
PRIVATE nSomaCheq	:= 0
Private nIrrf		:= 0
PRIVATE nOldDescont	:= 0
PRIVATE nOldMulta	:= 0
PRIVATE nOldJuros	:= 0
PRIVATE nOldVA 		:= 0
PRIVATE cOldVA 		:= ""
PRIVATE lTitLote  	:= .T.
Private cTpDesc 	:= "I"
PRIVATE lBloqSa1   	:= .T.
PRIVATE cFilAbat 	:= cFilAnt
Private lBolsa		:= .F.
PRIVATE nDescCalc 	:= 0
PRIVATE nJurosCalc 	:= 0
PRIVATE nMultaCalc 	:= 0
Private aRetMsg		:= {}
Private dOldBaixa 	:= CToD("")
Private nOldBanco  	:= ""
Private nOldAgencia	:= ""
Private nOldConta	:= ""
Default lPix		:= .F.

__cFunBkp   := FunName()
__cFunMet	:= Iif(AllTrim(__cFunBkp)=='RPC',"RPCFINA070",__cFunBkp)

If __lMetric
	SetFunName(__cFunMet)
	// Metrica de controle de acessos 
    FwCustomMetrics():setSumMetric(Alltrim(ProcName()), "financeiro-protheus_qtd-por-acesso_total", 1)
	SetFunName(__cFunBkp)
Endif

If lIsRussia
	nValRec    := 0
	nOldValRec := 0
EndIf

aImpos 	:= {}	// Motor de retenção

If lF070Auto 
	PRIVATE lAutValRec := .F.
EndIf

//****************************************
// Restringe o uso do programa Financeiro
// Quando a origem do titulo for de origem
// Totvs Incorporação
//****************************************
If FindFunction("FINTP01") .AND. FINTP01(.T.)
	Return
EndIf

__lCalcImp := .F.

//Tratamento para não redeclarar a variável.
//No retorno CNAB com calculo de PCC + IR esta variável já vem declarada.
If Type("dBaixa")=="U"
	PRIVATE dBaixa	:= CriaVar("E1_BAIXA")	
EndIf
dOldBaixa := dBaixa

__nMRBxTot := 0

If lPccBxCr .and. dBaixa >= dLastPcc
	nVlMinImp	:= 0
EndIf

lBQ10925 := SuperGetMV("MV_BQ10925",,"2") == "1" .And. !lRaRtImp

//Variaveis utilizada para acrescimo e decrescimo
aBxAcr					:= {}
aBxDec					:= {}
nDecrVlr				:= 0		//tratar visualizacao da varivel na tela de valores
aFill( aVlOringl , 0 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso tenha seja um titulo gerado pelo SIGAEIC ou SIGAEEC não poderá sofrer baixa através desta rotina ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetMV("MV_EASYFIN") == "S" .And. UPPER(Alltrim(SE1->E1_ORIGEM)) == "SIGAEIC"
	HELP(" ",1,"FAORIEIC")
	Return
EndIf

// TDF - 26/12/11 - Acrescentado o módulo EFF para permitir liquidação
If lEECFIN .And. UPPER(Alltrim(SE1->E1_ORIGEM)) == "SIGAEEC" .AND. !(cModulo $ "EEC/EDC/ECO/EFF") //DFS - 17/02/11 - Trava para outros módulos para títulos gerados no EEC
   HELP(" ",1,"FAORIEEC")
   Return
EndIf

//Validação de mensagem de titulo RM Classis
If(AllTrim(SE1->E1_ORIGEM) $ cProdRM .And. !lF070Auto)
	HELP(" ",1,"ProtheusXClassis" ,,STR0277,2,0,,,,,, {STR0279})//"Título gerado pela Integração Protheus X Classis não Pode ser baixado pelo Protheus" ## "Efetua a baixa através do sistema RM Classis"
	return .F.
EndIf

//Validação quando utiliza módulo do agro
If !lF070Auto .And. SuperGetMv("MV_SIGAAGR",,.F.)
	If FindFunction("AGRTITFIN")
		If !AGRTITFIN()	
			return .F.
		EndIf
	EndIf  
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso titulos originados pelo SIGALOJA estejam nas carteiras :  ³
//³I = Carteira Caixa Loja                                        ³
//³J = Carteira Caixa Geral                                       ³
//³Nao permitir esta operacao, pois ele precisa ser transferido   ³
//³antes pelas rotinas do SIGALOJA.                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//SITCOB
If Upper(AllTrim(SE1->E1_SITUACA)) $ "I|J" .AND. !IsMoney(SE1->E1_TIPO) .AND. Upper(AllTrim(SE1->E1_ORIGEM)) $ "LOJA010|LOJA701|FATA701"
	Help(" ",1,"NOUSACLJ")
	Return
Endif

//Caso a rotina esteja cadastrada no adapter, so pode ser enviada como 'Sincrona'. Uma baixa enviada como assincrona
//sera concretizada mesmo que de erro no sistema integrado.
If !lFini055 .And. !lF070Auto
	If !(FA070Integ(.F.))
		Return .F.
	Endif
Endif

//PCREQ-3782 - Bloqueio por situação de cobrança
If !F023VerBlq("1","0003",SE1->E1_SITUACA,.T.)
	Return .F.
Endif

// Zerar variaveis para contabilizar os impostos da lei 10925.
VALOR5 := 0
VALOR6 := 0
VALOR7 := 0

cTpDesc	:= "I"
lF415Auto := IIf(Type("lF415Auto")=="U",.F.,lF415Auto)		// Sergio Fuzinaka - 05.06.02
cPortado  := IIf(Type("cPortado")=="U",CriaVar("E1_PORTADO",.F.),cPortado)
cBanco 	 := IIf(Type("cBanco")=="U",CriaVar("E1_PORTADO",.F.), cBanco)
cAgencia  := IIf(Type("cAgencia")=="U",CriaVar("E1_AGEDEP" ,.F.),cAgencia)
cConta	 := IIf(Type("cConta")=="U",CriaVar("E1_CONTA"  ,.F.),cConta)

If mv_par10 == 1 .And. FunName() == "FINA740"
	cPortado	:= cPorta740
	cBanco 		:= cBanco740
	cAgencia	:= cAgenc740
	cConta		:= cConta740
EndIf

nOpc1    := 0
If cPaisLoc <> "BRA"
   aAdd(aTxMoedas,{"",1,PesqPict("SM2","M2_MOEDA1")})
   For nA	:=	2 To MoedFin()
	  cMoedaTx := Str(nA,IIf(nA <= 9,1,2))
	  cAuxMoeda := GetMv( "MV_MOEDA" + cMoedaTx )
	  If ! Empty( cAuxMoeda )
	  	If lF070Auto .And. nA==SE1->E1_MOEDA
			 aAdd( aTxMoedas, {cAuxMoeda, SE1->E1_TXMOEDA, PesqPict("SM2", "M2_MOEDA" + cMoedaTx)} )
		Else
			 aAdd( aTxMoedas, {cAuxMoeda, RecMoeda(dDataBase,nA), PesqPict("SM2", "M2_MOEDA" + cMoedaTx)} )
		Endif
	  Else
		 Exit
	  Endif
   Next
   nTotAGer     := 0
   nTotADesp    := 0
   nTotADesc    := 0
   nTotAMul     := 0
   nTotAJur     := 0
   cMarca       := Get070Mark()
   cLoteFin     := Space(TamSX3("E1_LOTE")[1])
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PONTO DE ENTRADA 																	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (ExistBlock( "FA070CHK" ) )
	If !(ExecBlock("FA070CHK",.F.,.F.))
		Return .F.
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PONTO DE ENTRADA TEMPLATE	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (ExistTemplate( "FA070CHK" ) )
	If !(ExecTemplate("FA070CHK",.F.,.F.))

		// Indica que houve um erro ao executar por rotina automatica, para tratamento externo
		If Type('lF070Auto') == 'L' .And. lF070Auto
			lMsErroAuto := .T.
		Endif

		Return .F.
	EndIf
Endif

IF ExistBlock("F070MNAT")
	lMultNat := ExecBlock("F070MNAT",.F.,.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta Hist¢rico da Baixa para digita‡„o pelo usu rio                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cHist070 := Criavar("E5_HISTOR")        //Inicilizador padrao

If Empty(cHist070)
	cHist070 := PADR(STR0007,Len(cHist070),' ')  // "Valor recebido s/ T¡tulo"
Endif

cMotBx := criavar("E5_MOTBX")
IF lAut=NIL
	lAut:=.F.
EndIF

//*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//*³Salva ordem atual                                                     ³
//*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOrdem:=IndexOrd()
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria as vari veis utilizadas para receber os dados do t¡tulo          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dDtCredito  := dDataBase
dOldDtCredito	:= dDtCredito
If Alltrim(SE1->E1_ORIGEM) $ "LOJA010|LOJXTEF"

	aCaixaLoja  := xCxLoja()
	cPortado    := SE1->E1_PORTADO
	cBanco      := SE1->E1_PORTADO
	cAgencia    := SE1->E1_AGEDEP
	cConta      := SE1->E1_CONTA
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³aCaixaFin conter  os dados Bco/Age/Cta do Caixa Geral, caso o titulo  ³
	//³esteja em carteira (SITUACA == 0).                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// 0 = Carteira
	// F = Carteira Protesto
	// G = Carteira Acordo
	//SITCOB
	If (mv_par10 == 2 .or. Empty(cBanco)) .and. (Len(aAutoCab) == 0)
		If ! lJFilBco
			cPortado    := IIF(FN022SITCB(SE1->E1_SITUACA)[1], aCaixaFin[1] ,SE1->E1_PORTADO)
			cBanco      := IIF(FN022SITCB(SE1->E1_SITUACA)[1], aCaixaFin[1] ,SE1->E1_PORTADO)
			cAgencia    := IIF(FN022SITCB(SE1->E1_SITUACA)[1], aCaixaFin[2] ,SE1->E1_AGEDEP)
			cConta      := IIF(FN022SITCB(SE1->E1_SITUACA)[1], aCaixaFin[3] ,SE1->E1_CONTA)
		Else
			cPortado    := CriaVar("E1_PORTADO",.F.)
			cBanco      := CriaVar("E1_PORTADO",.F.)
			cAgencia    := CriaVar("E1_AGEDEP",.F.)
			cConta      := CriaVar("E1_CONTA",.F.)
		EndIf
	Else
		If (nPos := ascan(aAutoCab,{|x| x[1]='AUTBANCO'})) > 0
			 cBanco:= aAutoCab[nPos][2]
		Endif
		If (nPos := ascan(aAutoCab,{|x| x[1]='AUTAGENCIA'}) ) > 0
			 cAgencia:= aAutoCab[nPos][2]
		EndIf
		If (nPos := ascan(aAutoCab,{|x| x[1]='AUTCONTA'}) ) > 0
			 cConta:= aAutoCab[nPos][2]
		EndIf
		//Si es para Argentina, viene de la rutina FINA074 y tiene la variable aDatBnDif defina y con datos
		If Upper(AllTrim(SE1->E1_ORIGEM)) == "FINA074" .And. cPaisLoc == "ARG" .And. (Empty(cPortado) .Or. Empty(cBanco) .Or. Empty(cAgencia) .Or. Empty(cConta)) .And. (Type("aDatBnDif") != "U" .And. Len(aDatBnDif) > 0)
			cPortado := aDatBnDif[1][1]
			cBanco := aDatBnDif[1][1]
			cAgencia := aDatBnDif[1][2]
			cConta := aDatBnDif[1][3]
		EndIf
		//Caso seja rotina automatica e não sejam passados os dados bancarios para baixa
		//Verificamos se possui informações de portador do título e assume como conta corrente da baixa
		If lF070Auto
			If (Empty(cBanco) .or. Empty(cAgencia) .or. Empty(cConta)) .and. ;
				!Empty(SE1->E1_PORTADO) .AND. !Empty(SE1->E1_AGEDEP) .AND. !Empty(SE1->E1_CONTA)
				cBanco	:= SE1->E1_PORTADO
				cAgencia	:= SE1->E1_AGEDEP
				cConta	:= SE1->E1_CONTA
			Endif
		Endif
	Endif
EndIf

//Obtem a moeda do banco
nOrdSA6:=SA6->(IndexOrd())
DbSetOrder(1)
If cPaisLoc <> "ARG"	
	SA6->(MsSeek(xFilial("SA6")+cBanco+cAgencia+cConta))
ElseIf !(Empty(cBanco) .And. Empty(cAgencia) .And. Empty(cConta))
	SA6->(MsSeek(xFilial("SA6")+cBanco+cAgencia+cConta))
EndIf
nMoedaBco:= Max(SA6->A6_MOEDA,1)
SA6->(DbSetOrder(nOrdSA6))

If lF070Auto .AND. (nT := ascan(aAutoCab,{|x| x[1]='AUTMOTBX'})) > 0 
	cMotBx	:=	aAutoCab[nT,2]
    If ( (Len(AllTrim(cMotBx)) == 3 .AND. (nY := AScan(aMotBx, {|x| SubStr(x, 01, 03) == AllTrim(cMotBx)})) == 0) ;
     .OR. (Len(cMotBx) >= 10 .AND. (nY := AScan(aMotBx, {|x| SubStr(x, 07, 10) == Subs(cMotBx,1,10)})) == 0) );
     .AND. !(Alltrim(cMotBx) $ 'STP|DIF|TRF|BFT|CNF|BCF') 
        HELP(" ", 01, "MOTBX" , , STR0089 + " " + cMotBx + " " + STR0297, 02,0,,,,,, {STR0298})//"Mot. Baixa" ## "não encontrado" ## "Selecione um motivo de baixa existente"
        Return .F. 
    EndIf	
    If Empty(cBanco)
        If Len(AllTrim(cMotBx)) == 3
            If (nY := ascan(aMotBx,{|x| SubStr(x,1,3) == AllTrim(cMotBx)})) > 0
                aAutoCab[nT,2] := SubStr(aMotBx[nY],07,10)
                cMotBx := aAutoCab[nT,2]
            EndIf
        EndIf
        If lFina415
			If MovBcoBx( cMotBx , .T. )
				cPortado    := aCaixaFin[1]
				cBanco      := aCaixaFin[1]
				cAgencia    := aCaixaFin[2]
				cConta      := aCaixaFin[3]
				
				nOrdSA6:=SA6->(IndexOrd())
				DbSetOrder(1)
				If cPaisLoc <> "ARG"	
					SA6->(MsSeek(xFilial("SA6")+cBanco+cAgencia+cConta))
				ElseIf !(Empty(cBanco) .And. Empty(cAgencia) .And. Empty(cConta))
					SA6->(MsSeek(xFilial("SA6")+cBanco+cAgencia+cConta))
				EndIf
				nMoedaBco:= Max(SA6->A6_MOEDA,1)
				SA6->(DbSetOrder(nOrdSA6))
			Else
				nMoedaBco:= 1
			EndIf
		ElseIf !MovBcoBx( cMotBx , .T. )
			nMoedaBco:= 1
		EndIf
	EndIf
ElseIf lF070Auto .AND. (nT := ascan(aAutoCab,{|x| x[1]='AUTMOTBX'})) == 0
	HELP(" ", 01, "MOTBX" , , STR0089 + " " + cMotBx + " " + STR0297, 02,0,,,,,, {STR0298})//"Mot. Baixa" ## "não encontrado" ## "Selecione um motivo de baixa existente"
	Return .F.
EndIf

//
// Eh um titulo gerado pelo template GEM ?
//
If HasTemplate("LOT") .and. ExistTemplate("GEMSE1LIX")
	lGemInUse := ExecTemplate("GEMSE1LIX",.F.,.F.)
EndIf
If !SoftLock( "SE1" )
	Return
EndIf
// Verifica integracao com PMS e nao permite alteracao de titulos que tenham solicitacoes
// de transferencias em aberto.
If !( Alltrim(Upper(FunName())) == "FINA630" .or. (Type("lF630Auto")=="L" .and.  lF630Auto) ) .And. !Empty(SE1->E1_NUMSOL)
	HELP(" ",1,"FIN62003")
	Return
Endif

// Nao permitir baixar titulos de adiantamento relacionados a pedido
If cPaisLoc == "BRA" .and. AliasInDic("FIE")
	If FinAdtSld( "R", SE1->( E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO ) )
		Help(" ",1,"ADTXPED",,STR0224,1,0) //"Adiantamento relacionado a um pedido. Somente poderá ser utilizado no relacionamento com pedidos."
		Return(.F.)
	Endif
Endif

If SE1->( Deleted() )
	Help( " " , 1 , "RECNO" )
	Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SIGAPFS‚ A cotação para baixa dos títulos no módulo jurídico deve ser sempre na cotação diária.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If UPPER(Alltrim(SE1->E1_ORIGEM)) $ "JURA203"
	nTxMoeda := If(SE1->E1_MOEDA > 1, RecMoeda(dBaixa,SE1->E1_MOEDA), 0)
Else 
	If cPaisLoc == "BRA"
		If nMoedaBco == SE1->E1_MOEDA
			nTxMoeda := 1
		ElseIf nMoedaBco > 1 .AND. SE1->E1_MOEDA = 1
            nTxMoeda := RecMoeda(dBaixa,nMoedaBco)
        Else   
        	nTxMoeda 	:= If(SE1->E1_MOEDA > 1, If(SE1->E1_TXMOEDA > 0, SE1->E1_TXMOEDA,RecMoeda(dBaixa,SE1->E1_MOEDA)),0)
        EndIf
	Else
		If nMoedaBco == SE1->E1_MOEDA
			nTxMoeda := 1
        ElseIf nMoedaBco > 1 .AND. SE1->E1_MOEDA = 1
            nTxMoeda := RecMoeda(dBaixa,nMoedaBco)
        Else
            nTxMoeda := RecMoeda(dBaixa,SE1->E1_MOEDA)
   		EndIf
	EndIf
EndIf

// Se estiver utilizando CMC7, abre a porta para cadastro do cheque recebido.
If lOpenCmc7 == Nil .And. !lAut .And. GetMv("MV_CMC7FIN") == "S"
	OpenCMC7()
	lOpenCmc7 := .T.
Endif

lTemImpPad := !( __lPccMR .And. __lInsMR .And. __lIrfMR .And. __lIssMR )

If !lF070Auto .And. lImpBxCr .And. (SE1->E1_MULTNAT != "1" .or. (SE1->E1_MULTNAT == "1" .AND. F070RTMNBL())) .And. lTemImpPad
	AADD(aButtons, {"SIMULACAO", {|| FaCalcImp()}, STR0195, STR0299 }) //"Recálculo dos Impostos"
EndIf

//Botao de Cheques no Painel Financeiro
AADD(aButtons, {"LIQCHECK", {|| CadCheqCR(cBanco,cAgencia,cConta,nValRec,dBaixa,1)}, STR0141 }) //"Cheques"

//Valores Acessorios.
If lPodeTVA .and. lExistVA
 	FAPodeTVA(SE1->E1_TIPO,SE1->E1_NATUREZ,.F.,"R")
	Aadd(aButtons, {"VALACESS", {||	If (FINA070VA() == 0,fA070Val(nVA,nTxMoeda),/**/) },STR0274})	//"Valores Acessórios"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica os botoes de usuarios.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("FA070BTN")
	aButtons:= ExecBlock("FA070BTN",.F.,.F.,{aButtons})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica os botoes de usuarios no Template.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If HasTemplate("LOT") .and. ExistTemplate("FA070BTN")
	aButtons := ExecTemplate("FA070BTN",.F.,.F.,{aButtons})
EndIf

//Ponto de entrada para desabilitar campos de Multa, Juros ou Descontos, data de baixa, data de credito
If ExistBlock("F070DCNB")
	aCposDes:=ExecBlock("F070DCNB",.F.,.F.)
	If Len(aCposDes) > 0
		IF (nT := ascan(aCposDes,'MULTA')) > 0
			lAcessMul := .F.
		Endif
		IF (nT := ascan(aCposDes,'DESCONTO')) > 0
			lAcessDesc := .F.
		Endif
		IF (nT := ascan(aCposDes,'JUROS')) > 0
			lAcessJur := .F.
		Endif
		IF (nT := ascan(aCposDes,'DATABAIXA')) > 0
			lAcessdBaixa := .F.
		Endif
		IF (nT := ascan(aCposDes,'DATACREDITO')) > 0
			lAcessDtCredito := .F.
		Endif
		IF (nT := ascan(aCposDes,'PIS')) > 0
			lAcessPIS := .F.
		Endif
		IF (nT := ascan(aCposDes,'COFINS')) > 0
			lAcessCOF := .F.
		Endif
		IF (nT := ascan(aCposDes,'CSLL')) > 0
			lAcessCSLL := .F.
		Endif
	Endif
Endif

//verifica se o titulo é da integração Protheus X Tin, caso afirmativo, não e permitido alterar os valores
If AllTrim(SE1->E1_ORIGEM)=="FINI055"  .And. !lF070Auto .And. SuperGetMv("MV_ITLBCPO",,.F.) == .F.
	lAcessMul := .F.
	lAcessDesc := .F.
	lAcessJur := .F.
	lAcessdBaixa := .F.
	lAcessDtCredito := .F.
Elseif AllTrim(SE1->E1_ORIGEM)=="FINI055"  .And. !lF070Auto .And. SuperGetMv("MV_ITLBCPO",,.F.) == .T.
	lAcessMul := .T.
	lAcessDesc := .T.
	lAcessJur := .T.
	lAcessdBaixa := .T.
	lAcessDtCredito := .T.
Endif

If __lBordImp .And. !Empty(SE1->E1_NUMBOR)
	__lCalcImp := BorderoImp(SE1->E1_FILORIG, SE1->E1_NUMBOR, "R", SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
EndIf

If __lFPIXatv .And. !__lCalcImp .And. !__lCnabImp
	__lCalcImp := PIXIsActiv()
EndIf

While .T.
	nOpc1		:= 0
	nJuros      := 0
	nVA			:= 0		//Valores Acessorios
	nPIS	    := 0
	nCOFINS    	:= 0
	nCSLL    	:= 0
	nVlRetPis	:= 0
	nVlRetCof	:= 0
	nVlRetCsl	:= 0
	nMulta      := 0
	nCM         := 0
	nDescont    := 0
	If !lF070Auto
		If Type("nValRec")=="U"
			nValRec     := 0
			dBaixa      := CriaVar("E1_BAIXA")
		ElseIf Type("nValRec")!="N"
			nValRec     := 0
		Endif
	Endif
	nValEstrang := 0
	nParciais   := 0
	aBaixaSE5   :={}

	nAcrescF	:= SE1->E1_SDACRES
	nDeCrescF	:= SE1->E1_SDDECRE  + nDecrVlr

	// Motor de Retenção
	__lMotor 	:= .F.
	__lPccMR	:= .F.
	__lInsMR	:= .F.
	__lIrfMR	:= .F.
	__lIssMR	:= .F.
	__lImpMR  	:= .F.
	__lGlosaMr	:= .F.
 	__lGlosIrf	:= .F.
 	__lGlosPis	:= .F.
 	__lGlosCof	:= .F.
	__lGlosCsl	:= .F.
 	__lGlosIss	:= .F.
 	__lGlosIns	:= .F.
 	__lGlosOut	:= .F.
 	__lPropPcc	:= .F.
	//***Reestruturacao SE5***
	nPisCalc	:= 0
	nCofCalc	:= 0
	nCslCalc	:= 0
	nIrfCalc	:= 0
	nIssCalc	:= 0
	nPisBaseR 	:= 0
	nCofBaseR	:= 0
	nCslBaseR 	:= 0
	nIrfBaseR 	:= 0
	nIssBaseR 	:= 0
	nPisBaseC 	:= 0
	nCofBaseC 	:= 0
	nCslBaseC 	:= 0
	nIrfBaseC 	:= 0
	nIssBaseC 	:= 0
	//***Reestruturacao SE5***

	If lF070ACRE
		ExecBlock("F070ACRE",.F.,.F.)
	EndIf

	lNatApura	:=	.F.
	aAreaSED 	:= SED->(GetArea())
	DbSelectArea("SED")
	DbSetOrder(1)
	If DbSeek(xFilial("SED")+ SE1->E1_NATUREZ) .And. lCposSped
		If (!Empty(SED->ED_APURCOF) .Or. !Empty(SED->ED_APURPIS))
			lNatApura	:=	.T. //Natureza configurada para apurar impostos no SPED PIS/COFINS.
		Endif
	Endif
	RestArea(aAreaSED)

	nAcresc     := Round(NoRound(xMoeda(nAcrescF,SE1->E1_MOEDA,nMoedaBco,dBaixa,3,nTxMoeda),3),2)
	nDecresc    := Round(NoRound(xMoeda(nDeCrescF,SE1->E1_MOEDA,nMoedaBco,dBaixa,3,nTxMoeda),3),2)
	nCM1        := 0
	nProRata    := 0

	// Motor de retenção
  	If !__lCalcImp .And. __lTemMR
  		aImpos := F070VldImp(Iif(SE1->E1_VALOR <> SE1->E1_SALDO, 0, SE1->E1_VALOR), dBaixa, @lPccBxCr, @lIrPjBxCr, @lCalcIssBx)
  	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o T¡tulo j  foi Baixado Totalmente                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SE1->E1_SALDO == 0 .And. !( lFINA200 .And. lREC2TIT )// Tratamento do Parâmeto MV_REC2TIT - Geração de RECANT(RA) via RETORNO CNAB.
		If lIsRussia
			Help(NIL,NIL,"TITBAIXADO", NIL, "", 1, 0, NIL, NIL, NIL, NIL, NIL, {""}) // show only problem description, not solution
		Else
			Help(" ",1,"TITBAIXADO")
		EndIf
		MsUnlock()
		Exit
	EndIF

	If lVlTitCR .And. !(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG)
		aAreaSE1:=SE1->(GetArea())
		nBusca := F070BuscCR( "SE1", SE1->E1_CLIENTE, SE1->E1_LOJA )
		If nBusca <> 0
			lAD := .T.
			cMsg := STR0241 //"O Cliente deste titulo possui "
			Do Case
				Case nBusca = 1 // Recebimento Antecipado
					cMsg += STR0242 //"Recebimento(s) Antecipado(s)."
				Case nBusca = 2 // NCC
					cMsg += STR0243 //"titulo(s) de credito."
			End Case
			cMsg += chr(13)+chr(10)
			cMsg += STR0244 //"Deseja mesmo assim baixa-lo ?"
			If isBlind()
				If lF070VLAD
					If !(ExecBlock("F070VLAD",.F.,.F.))
						Return .F.
					Endif
				Endif
			Else
				If !MsgYesNo( cMsg )
					Return .F. /*Function fA070Tit*/
				Endif
			Endif
		Endif
		RestArea(aAreaSE1)
	Endif

	faLojxRMul(dDtCredito,nTxMoeda,nMoedaBco)

	//Trato o desconto por bolsa de estudos quando há integração com o RM Classis
	If FWHasEAI("FINI070A",.T.,,.T.) .And. FWHasEai("FINA070",.T.,,.T.) .And. (AllTrim(SE1->E1_ORIGEM) $ 'L|S|T' .Or. SE1->E1_IDLAN > 0)
		nDescBol := SE1->E1_VLBOLSA
	EndIf

	//Verifica se é um registro Principal
	IF SE1->E1_TIPO $ MVABATIM+"/"+MVIRABT+"/"+MVINABT+"/"+MVFUABT //adicionado MVFUABT pois a variável MVABATIM não está retornando FU-
		Help(" ",1,"NAOPRINCIP")
		MsUnlock()
		Exit
	End
	
	//Verifica se é um t¡tulo provisório
	IF SE1->E1_TIPO $ MVPROVIS .AND. !lSubsPrv .and. !lFini055
		Help(" ",1,"TITULOPROV")
		MsUnlock()
		Exit
	EndIf

	nSalvRec  := RecNO()
	cNum      := SE1->E1_NUM
	cPrefixo  := SE1->E1_PREFIXO
	cParcela  := SE1->E1_PARCELA
	cTipo     := SE1->E1_TIPO
	cCliente  := SE1->E1_CLIENTE
	cLoja     := SE1->E1_LOJA
	nTotAbat  := 0
	nTotAbImp := 0
	nTotAbLiq := 0
	nValorLiq := 0
	nValPadrao:= 0
	nTotAbat  := SumAbatRec(cPrefixo,cNum,cParcela,SE1->E1_MOEDA,"S",dBaixa,@nTotAbImp,,,,,,cFilAbat, nTxMoeda)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca os valores de ISS no caso de documento transferido com ISS na origem³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFilOrgTr := FilISSTran()
	If !Empty( cFilOrgTr )
		SumAbatRec(cPrefixo,cNum,cParcela,SE1->E1_MOEDA,"S",dBaixa,nTotAbImp,,,,,,cFilOrgTr, nTxMoeda,@nTotAbISS)
		nTotAbat  += nTotAbISS
		nTotAbImp += nTotAbISS
	EndIf

	nTotAbLiq := nTotAbat - nTotAbImp
	dbGoto(nSalvRec)
	cMoeda := IIF(Empty(SE1->E1_MOEDA),"1",AllTrim(Str(SE1->E1_MOEDA,2)))

	//Recebe os dados do título a ser baixado
	SA1->(MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
	cTitulo 	:= SE1->E1_PREFIXO + " " + SE1->E1_NUM+ " " + SE1->E1_PARCELA
	cSituacao 	:= SE1->E1_SITUACA + " " + fa070situa()
	cDescMoeda 	:= SubStr(GetMV("MV_SIMB"+cMoeda),1,3)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Para que o valor da baixa parcial nao fique negativo, verifico o saldo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (SE1->E1_SALDO+SE1->E1_SDACRES)>0 .And. Empty(SE1->E1_TIPOLIQ)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Procura pelas baixas deste titulo ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lTipBxCP:=lRaRtImp
		
		If Type("aTxMoedas") = "A" .AND. cPaisLoc <> "BRA" .And.  !lFina415
			Fa070SetMd(@nTxMoeda,.F.)
		EndIf

		aBaixa := Sel070Baixa( "VL /V2 /BA /RA /CP /LJ /" + MV_CRNEG, cPrefixo	, cNum			, cParcela	,;
								cTipo								, @nTotAdto	, @lBaixaAbat	, cCliente	,;
								cLoja								, @nVlrBaixa, Nil			, @lBxCec	,;
								@lBxLiq 							, @lSigaloja, @lTipBxCP		)
										
		For x := 1 To Len(aBaixaSE5)
			
			// Não considera a baixa de um recebimento de titulo pago em dinheiro originado pelo SIGALOJA
			If AllTrim(aBaixaSE5[x][25]) == "BA" .AND. AllTrim(aBaixaSE5[x][29]) == "LOJ" .AND. IsMoney(aBaixaSE5[x][24])
				Loop
			EndIf
									
			If SE1->E1_MOEDA == Val(aBaixaSE5[x][24]) .And. SE1->E1_MOEDA > 1
				nValParc := xMoeda(aBaixaSE5[x][36],Val(aBaixaSE5[x][24]),1,aBaixaSE5[x][7],nDecs,nTxMoeda)
			ElseIf SE1->E1_MOEDA > 1 .AND. Val(aBaixaSE5[x][24]) = 1  
				nValParc := xMoeda(aBaixaSE5[x][36],SE1->E1_MOEDA,1,aBaixaSE5[x][7],nDecs,nTxMoeda)
			ElseIf SE1->E1_MOEDA == 1 .AND. Val(aBaixaSE5[x][24]) > 1
				nValParc := aBaixaSE5[x][36]
			Else
				nValParc := aBaixaSE5[x][8]
			EndIf 
			
   			If lPccBxCR
   				If lRaRtImp //.And. nParciais > nVlMinImp
			   		nValParc += aBaixaSE5[x][18]+aBaixaSE5[x][19]+aBaixaSE5[x][20]+aBaixaSE5[x][30]// somar impostos PCC
			   	EndIf
			   	nPccRetPrc += aBaixaSE5[x][18]+aBaixaSE5[x][19]+aBaixaSE5[x][20]+ IIf( lIrPjBxCr , aBaixaSE5[x][30] , 0 )
			Elseif lIrPjBxCr .And. lRaRtImp
		  		nValParc += aBaixaSE5[x][30]
			Endif
			nTotMult	 += (aBaixaSE5[x][14]+aBaixaSE5[x][15])  // Soma Acrescimo mais Multa
			If lRaRtImp
		 		nValParc += aBaixaSE5[x][32]+aBaixaSE5[x][33]
		 		nTotAbat  -= aBaixaSE5[x][32]+aBaixaSE5[x][33]
			Endif

			//Verifica baixas parciais no caso de desconto.
			If ABAIXASE5[x][16] > 0 .and. lSDACRVL
				nValParc += ABAIXASE5[x][16]
            Endif

			nParciais += nValParc
		Next
		nParciais += nTotAdto
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Soma valor de decrescimo em baixas parciais, para evitar         ³
		//³ diferencas entre valor original e valor recebido                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SE1->E1_SDDECRE <> SE1->E1_DECRESC
			If SE1->E1_SDDECRE = 0
				lSDDECVL := .T.
				If lSDACRVL
					nParciais -= SE1->E1_DECRESC
				Endif
			Else
				If lSDACRVL
					nParciais += ( SE1->E1_DECRESC - SE1->E1_SDDECRE )
				Endif
			Endif
		EndIf

	Else
		nParciais 	:= SE1->E1_VALOR-SE1->E1_SALDO
	Endif

	If "RA" $ SE1->E1_TIPO
		nParciais 	:= SE1->E1_VALOR-SE1->E1_SALDO
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Array aDescMotbx contendo apenas a descricao do motivo das Baixas. 	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nPos := aScan(aAutoCab,{|x| x[1] == 'AUTMOTBX'})) > 0 .AND. len(aAutoCab[nPos][2]) == 3
		If (nY := ascan(aMotBx,{|x| SubStr(x,1,3) == aAutoCab[nPos][2]})) > 0
			AADD( aDescMotbx,SubStr(aMotBx[nY],07,10))
		EndIf
	EndIf
	If Len( aDescMotbx ) == 0
		For nI := 1 to len( aMotBx )
			If SubStr(aMotBx[nI],34,01) == "A" .or. SubStr(aMotBx[nI],34,01) =="R"
				If !(substr(aMotBx[nI],01,03) $ "FAT|LOJ|LIQ|CEC|CMP|STP") .And.;
					!(substr(aMotBx[nI],01,03) $ "CNF" .And. Empty(AllTrim(SE1->E1_JURFAT)) .and. AllTrim(SE1->E1_ORIGEM) != 'JURA203') // Validação SIGAPFS - não permiti utilizar o motivo de baixa CNF se o título não tiver origem fatura do SIGAPFS
					AADD( aDescMotbx,SubStr(aMotBx[nI],07,10))
				EndIf
			EndIf
		Next nI
	EndIf

	// Carrega varivael cMotBx para sua verifcacao na funcao fa070totmes()
	cMotBx := aDescMotBx[Min(nFirstRsn,Len(aDescMotBx))]  // Default posting reason

	If !( Upper(AllTrim(SE1->E1_ORIGEM)) $ cProdRM ) // Integração RM -> Origem pertence ao parâmetro = Baixa RM |||  Origem não pertence ao parâmetro = Baixa Protheus
		// Calcula o desconto e o juros (se houver) e valida a data
		// Idem para Valores Acessórios
		fA070Data(@nTxMoeda,.F.,/*oDtBaixa*/,/*oJuros*/,/*oCbx*/,/*lReclcJur*/,/*oVa*/,/*aImpos*/,/*lMudouMulta*/, aTitCalc)
		u_xF070Ret()
	EndIf

	nDescCalc 	:= nDescont + nDecresc
	nJurosCalc 	:= IIf(cPaisLoc<>"CHI",nJuros + nAcresc,nOtrga)
	nMultaCalc 	:= nMulta

	// adiciona o desconto da bolsa ao desconto financeiro para o Classis
	If (SE1->E1_ORIGEM $ 'L|S|T') .And. (SE1->E1_VALOR == SE1->E1_SALDO)
		nDescont := nDescbol + nDescont
		// para validação da bolsa
		lBolsa := .T.
	EndIf

	If FWHasEAI("FINI070A",.T.,,.T.) .And. FWHasEai("FINA070",.T.,,.T.) .And. (AllTrim(SE1->E1_ORIGEM) $ 'L|S|T' .Or. SE1->E1_IDLAN > 0)
		nDescont := nDescBol + SE1->E1_DESCONT + nDescont
	EndIf

	If !lF070Auto
		nOldValRec	:= nValRec
	Else
		lAutValRec := (nPos := aScan(aAutoCab,{|x| x[1] == 'AUTVALREC'})) > 0
		If TYPE("nValRec") == "N"
			If nValRec == 0
				If lAutValRec
					nValRec := aAutoCab[nPos][2]
					If lBq10925 .And. nValRec == SE1->E1_SALDO
			        	nValRec := SE1->E1_VALOR - nParciais + nTotMult
			        EndIf
				else
					nValRec := SE1->E1_VALOR
					nValRec -= nParciais - nTotMult
				EndIf
			Endif
		ElseIf TYPE("nValRec") == "U"
			If lAutValRec
				nValRec := aAutoCab[nPos][2]
			else
				nValRec := SE1->E1_VALOR
				nValRec -= nParciais - nTotMult
			EndIf
		Endif
	Endif

	If SE1->E1_MOEDA > 1
    	If !lF070Auto 
            nValRec := xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,1,dDatabase,3,nTxMoeda)
		Else
            If Type("nValRec")=="N"
                If SE1->E1_MOEDA > 1 
                    nValRec := nValRec
                Else
                    nValRec := xMoeda(nValRec,SE1->E1_MOEDA,1,dDatabase,3,nTxMoeda)
                EndIf
			Endif
		Endif
		nValRec:=nValRec - (IIf((!lBQ10925 .And. Alltrim(SE1->E1_ORIGEM) == "FINA280"), SE1->E1_VALLIQ, nParciais) - nTotMult)
    Else
    	If !lF070Auto
    	    If (lPccBxCR .And. !__lPccMR) .and. dBaixa < dLastPcc
        		nValRec := SE1->E1_VALOR - (IIf((!lBQ10925 .And. Alltrim(SE1->E1_ORIGEM) == "FINA280"), SE1->E1_VALLIQ, nParciais) - nTotMult) // (nTotMult = pagamento de multas nas baixas efetuadas anteriormente). Se fizermos 2 baixas parciais com multa alta, o valor SE1->E1_VALOR - nParciais será negativo
        	Else
        		If lBq10925
        			nValRec := SE1->E1_VALOR - nParciais + nTotMult
        		Else
        			nValRec := SE1->E1_SALDO
        		EndIf
        	EndIf
        	nOldValRec	:= nValRec
   		Endif
	EndIf

	If lF070Auto
		/*
			Iniciar valores do execauto aqui para calculo do imposto PCC e IR na baixa utilizarem
		*/
		If (nT := ascan(aAutoCab,{|x| x[1]='AUTJUROS'}) ) > 0
			nJuros := Round(NoRound(aAutoCab[nT,2]),2)
		EndIf

		If (nT := ascan(aAutoCab,{|x| x[1]='AUTDESCONT'}) ) > 0
			nDescont := Round(NoRound(aAutoCab[nT,2]),2)
		EndIf

		If (nT := ascan(aAutoCab,{|x| x[1]='AUTMULTA'}) ) > 0
			nMulta := Round(NoRound(aAutoCab[nT,2]),2)
		EndIf

		If (nT := ascan(aAutoCab,{|x| x[1]='AUTACRESC'}) ) > 0
			nAcresc := Round(NoRound(aAutoCab[nT,2]),2)
		EndIf

		If (nT := ascan(aAutoCab,{|x| x[1]='AUTDECRESC'}) ) > 0
			nDecresc := Round(NoRound(aAutoCab[nT,2]),2)
		EndIf
		
		If (nT := Ascan(aAutoCab, {|x| x[1] == "AUTSITUCOB"})) > 0 
			cSituaCob := aAutoCab[nT,2] 
		EndIf	
	EndIf

	If cPaisLoc == "BRA"
		If SED->ED_RECIRRF == "3" .and. SA1->A1_RECIRRF == "" // Se definir na natureza que o cliente define quem retem e o cliente não definir, não retenho
			nIrrf	:= 0
		Else
			If	lIrPjBxCr .and. !(SE1->E1_TIPO $ MVRECANT)

				If __lFPIXatv .And. PIXIsActiv()
					aImpPix := Iif(__lImpPix,RetImpBxCR(),{})
					IF Len(aImpPix) > 0
						lImpPIx := .T.
					EndIf
				EndIf


				If ((lMVGlosa .and. !__lIrfMR) .or. __lGlosIrf) .And. !lImpPIx
					If nParciais == 0 // Não houve baixas parciais ainda
						nIrrf :=  IIf(cPaisLoc == "BRA" .And. !__lCalcImp, FCaIrBxCR(SE1->E1_VALOR), 0)
					Else
						nIrrf := 0
					EndIf
				ElseIf !lImpPIx
					If __lTemMR .And. __lIrfMR
						nParciais += Iif(nParciais > 0, nIrrf, 0)
					Else
						nParciais += nIrrf
					EndIf
					If lF070Auto .and. ((nPos := aScan(aAutoCab,{|x| x[1] == 'AUTMOTBX'})) > 0 .AND. (aAutoCab[nPos][2] == 'TRF'))
						nIrrf := 0
					ElseIf !__lIrfMR
						nIrrf:= Iif(cPaisLoc == "BRA" .And. !__lCalcImp, FCaIrBxCR(nValRec,,(SE1->E1_VALOR <> SE1->E1_SALDO .AND. (lRaRtImp .Or. lBQ10925)),,!(nParciais == 0),dBaixa),0)
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If lPccBxCR
		If (lMVGlosa .And. !__lPccMR) .Or. (__lGlosPis .Or. __lGlosCof .Or. __lGlosCsl)
			nPis    := 0
			nCofins := 0
			nCsll   := 0			
			
			If !__lCalcImp .And. nParciais == 0 // Não houve baixas parciais ainda
				nBase	:= SE1->E1_VALOR
				
				If lJurMulDes .And. nBase+nDescont-nJuros-nVa-nMulta-nAcresc+nDecresc > 0
					nBase 	:= nBase+Iif(cSituaCob != "0", 0, nDescont)-nJuros-nVa-nMulta-nAcresc+nDecresc
				EndIf

				aPcc	:= newMinPcc(dBaixa, nBase,SE1->E1_NATUREZ,"R",SA1->A1_COD+SA1->A1_LOJA,,,,,,cMotBx)
				nPis	:= aPcc[2]
				nCofins	:= aPcc[3]
				nCsll	:= aPcc[4]
			EndIf
			
			If Len(aDadosRef) < 7
				aDadosRef := Array(7)
				AFill( aDadosRef, 0 )
			EndIf
			
			If Len(adadosRet) < 7
				aDadosRet := Array(7)
				AFill( aDadosRet, 0 )
			EndIf
		Else
			If lF070Auto .and. ((nPos := aScan(aAutoCab,{|x| x[1] == 'AUTMOTBX'})) > 0 .AND. (aAutoCab[nPos][2] == 'TRF'))
				aAdd(aDadosRet, 0)
			Else
				If dBaixa < dLastPcc
					f070TotMes(dBaixa,.T.,,,,nTxMoeda)
				Else
					nBase	:= FBaseRPCC(nValRec,@lCalcPCC)
					
					If lJurMulDes
						If nBase-nDescont+nJuros+nVA+nMulta+nAcresc-nDecresc > 0
							nBase 	:= nBase-Iif(cSituaCob != "0", 0, nDescont)+nJuros+nVA+nMulta+nAcresc-nDecresc
						EndIf
					Else
						If FwIsInCallStack("FA450CMP") .AND. SE1->E1_SALDO <= (nValRec+Iif(!IsIssBx("R"), getVlIss(SE1->E1_FILIAL,SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)), 0)+If(!lIrPjBxCr,SE1->E1_IRRF,0)+Iif(!lPropBx,  SE1->E1_INSS, 0)+Iif(lPccBxCR, SE1->(E1_PIS+E1_COFINS+E1_CSLL),0))
							nBase	+= Iif(!IsIssBx("R"), getVlIss(SE1->E1_FILIAL,SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)), 0)
							nBase	+= If(!lIrPjBxCr,SE1->E1_IRRF,0)
							nBase 	+= Iif(!lPropBx,  SE1->E1_INSS, 0)
							If lPccBxCR .and. nBase + SE1->(E1_PIS+E1_COFINS+E1_CSLL) == SE1->E1_VALOR
								nBase	+= SE1->(E1_PIS+E1_COFINS+E1_CSLL)
							EndIf
						Endif
					EndIf
					
					aTitCalc := {}

					If !__lPccMR .And. !SE1->E1_TIPO $ MVRECANT .And. !__lCalcImp .And. lCalcPCC
						aPcc	:= newMinPcc(dBaixa, nBase, SE1->E1_NATUREZ, "R", SA1->(A1_COD+A1_LOJA), Nil, Nil, Nil, Nil, Nil, cMotBx)
						nPis	:= aPcc[2]
						nCofins	:= aPcc[3]
						nCsll	:= aPcc[4]
						
						If len(aPCC) > 4
							aTitCalc := aPCC[5]
						Endif						

						If lBq10925 .And. FwIsInCallStack("FA450CMP") .And. (nBase == SE1->E1_SALDO .and. nValRec <> nBase - (nPis + nCofins + nCsll))
							nValRec	:= nValRec - (nPis + nCofins + nCsll)
					  	Endif
					EndIf
				EndIf
			EndIf
		EndIf
	ElseIf !__lPccMR .and. !__lIrfMR
		If cPaisLoc == "BRA" .And. !lF070Auto
			nValRec := (xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,1,dDatabase,3,nTxMoeda) - xMoeda(nParciais,SE1->E1_MOEDA,1,dDatabase,3,nTxMoeda))
			If dBaixa >= dLastPcc
				nValRec	-= nTotAbat
			EndIf
		Else 
            If Type("lAutValRec") <> "L" .OR. !lAutValRec
                If SE1->E1_MOEDA > 1 
                    nValRec := xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,1,dDatabase,nDecs,nTxMoeda) - nParciais
                Else
                    nValRec :=  SE1->E1_VALOR - nParciais 
                EndIf
			EndIf
		EndIf
	EndIf

	// Motor de retenção
  	If __lTemMR .And. SE1->E1_VALOR != SE1->E1_SALDO .And. !__lCalcImp
  		aImpos := F070VldImp(nValRec, dBaixa, @lPccBxCr, @lIrPjBxCr, @lCalcIssBx)
  	EndIf
	//Carrego a variável para validação quando origem for mensagem única
	cAuxMBx	:= IIf(lF070Auto .And. ((nPos := aScan(aAutoCab,{|x| x[1] == 'AUTMOTBX'})) > 0), aAutoCab[nPos][2],"")

	//----------------------------------------------------------------------
	// Pré-inicializa o valor recebido.
	//----------------------------------------------------------------------
	cMotBx := aDescMotBx[Min(nFirstRsn,Len(aDescMotBx))]    // Default posting reason

	//-------------------------------------------------------------------------
	// PONTO DE ENTRADA FA070POS
	//
	// Permite a alteração de variáveis apos carga de dados do título a ser
	// baixado, antes das informa‡äes serem mostradas na Tela.
	// Variáveis disponíveis para serem alteradas : 
	//
	// cBanco , cAgencia, cConta, cCheque
	//-------------------------------------------------------------------------

	// Template GEM
	If HasTemplate("LOT") .and. ExistTemplate("FA070POS")
		ExecTemplate("FA070POS",.F.,.F.)
	EndIf
	If lFA070POS
		ExecBlock("FA070POS",.F.,.F.)
	EndIf

	aColsSEV := {}

    fa070val( nValrec, nTxMoeda)
	//-------------------------------------------------------------------------
	// Pre-inicializa a modalidade de SPB
	//-------------------------------------------------------------------------
	If lSpbInUse
		If !Empty(SE1->E1_MODSPB)
			cModSpb := SE1->E1_MODSPB
		Else		
		   cModSpb := "1"
		EndIf
	EndIf

	If lFA070BLQ
	     lLibCm := ExecBlock("FA070BLQ",.F.,.F.)
    EndIf

	If !lF070Auto
		bSetKey := SetKey(VK_F4,{|| If( !SE1->E1_TIPO $ MV_CRNEG,CadCheqCR(cBanco,cAgencia,cConta,nValRec,dBaixa,1),.F.)})
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Recebe os dados do t¡tulo a ser baixado                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( cPaisLoc=="CHI" )
			DEFINE FONT oFontLbl NAME "Arial" SIZE 6,15 BOLD
			DEFINE MSDIALOG oDlg FROM  69,33 TO 530,581 TITLE STR0103 PIXEL OF oMainWnd  //"Baixas a Receber"
		Else
			DEFINE FONT oFontLbl NAME "Arial" SIZE 6, 15 BOLD
			nLin2 := If(cPaisLoc=="BRA",700,520)
			// Template GEM, nova linha do rodape para os campos especificos do template.
			If lGemInUse
				nLin2 += 24
			EndIf

			//Valores Acessorios.	
			If lPodeTVA .and. lExistVA
				nLin2 += 24
			EndIf

		    DEFINE MSDIALOG oDlg FROM  69,33 TO nLin2,593 TITLE STR0103 PIXEL OF oMainWnd  //"Baixas a Receber"
		EndIf

		If !Empty(cMotBx) .and. !MovBcoBx(cMotBx, .T.)
			cBanco 		:= CriaVar("E1_PORTADO",.F.)
			cAgencia	:= CriaVar("E1_AGEDEP" ,.F.)
			cConta 		:= CriaVar("E1_CONTA"  ,.F.)
		EndIf
		
		nOldBanco  	:= cBanco
		nOldAgencia	:= cAgencia
		nOldConta	:= cConta
		nOldMoeBco  := nMoedaBco

		//Defino o tamanho dos componentes através do método FwDefSize(), amarrando ao objeto oDlg
		oSize := FwDefSize():New(.T.,,,oDlg)

		oSize:lLateral := .F.
		oSize:lProp := .T.

		oSize:AddObject("MASTER",100,100,.T.,.T.)

		oSize:Process()

		//Instancio um painel "master" como container dos demais paineis, mantendo a hierarquia
		oMasterPanel := TPanel():New(oSize:GetDimension("MASTER","LININI"),oSize:GetDimension("MASTER","COLINI"),;
								,oDlg,,,,,,oSize:GetDimension("MASTER","XSIZE"),oSize:GetDimension("MASTER","YSIZE"),.F.,.F.)

		oPanel1 := TPanel():New(0,0,'',oMasterPanel,, .T., .T.,, ,45,45,.f.,.f. )
		oPanel1:Align := CONTROL_ALIGN_TOP

		oPanel2 := TPanel():New(0,0,'',oMasterPanel,, .T., .T.,, ,30,30,.f.,.f. )
		oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

		@ 001,002 GROUP oGrp1 TO 043, 272 LABEL STR0008 OF oPanel1 PIXEL //"Principal"
		@ 001,002 GROUP oGrp2 TO If(cPaisLoc=="BRA",227,165), 133 LABEL STR0009 OF oPanel2  PIXEL //"Dados Gerais"
		@ 001,139 GROUP oGrp3 TO If(cPaisLoc=="BRA",227,165), 272 LABEL STR0010 OF oPanel2  PIXEL //"Valores da Baixa"
		oGrp1:oFont := oFontLbl
		oGrp2:oFont := oFontLbl
		oGrp3:oFont := oFontLbl

		//////////////////////////
		//Dados do titulo
		@ 008,004 SAY STR0211			SIZE 31,07 OF oPanel1 PIXEL //"Prefixo"
		@ 008,027 MSGET SE1->E1_PREFIXO	SIZE 25,08 OF oPanel1 PIXEL When .F.
		@ 008,060 SAY STR0212 			SIZE 31,07 OF oPanel1 PIXEL //"Número"
		@ 008,085 MSGET SE1->E1_NUM		SIZE 70,08 OF oPanel1 PIXEL When .F.
		@ 008,165 SAY STR0213			SIZE 31,07 OF oPanel1 PIXEL //"Parcela"
		@ 008,188 MSGET SE1->E1_PARCELA	SIZE 25,08 OF oPanel1 PIXEL When .F.
		@ 008,220 SAY STR0214			SIZE 31,07 OF oPanel1 PIXEL //"Tipo"
		@ 008,238 MSGET oTipo VAR cTipo	F3 Iif(lIsRussia, "05", "SE1RDO") SIZE 30,08 OF oPanel1 PIXEL HASBUTTON
		oTipo:lReadOnly := .T.

		@ 019,004 SAY STR0014 SIZE 22, 07 OF oPanel1 PIXEL //"Cliente"
		@ 019,027 MSGET oCodCli VAR SE1->E1_CLIENTE F3 "SA1" SIZE 65,08 OF oPanel1 PIXEL HASBUTTON //READONLY
		oCodCli:lReadOnly := .T.
		@ 019,105 MSGET oNomCli VAR SA1->A1_NOME SIZE 165,08 OF oPanel1 PIXEL When .F.

		If RetGlbLGPD("A1_NOME")
			oNomCli:lObfuscate := .T.
		EndIf

		@ 030,004 SAY STR0052 			SIZE 31,07 OF oPanel1 PIXEL //"Natureza"
		@ 030,027 MSGET oNaturez VAR SE1->E1_NATUREZ	F3 "SED" SIZE 70,08 OF oPanel1 PIXEL HASBUTTON
		oNaturez:lReadOnly := .T.
		@ 030,105 SAY STR0012 			SIZE 31,07 OF oPanel1 PIXEL //"Emiss„o"
		@ 030,133 MSGET SE1->E1_EMISSAO	SIZE 48,08 OF oPanel1 PIXEL HASBUTTON When .F.
		@ 030,189 SAY STR0013 			SIZE 49,07 OF oPanel1 PIXEL //"Vencto.Atual"
		@ 030,222 MSGET SE1->E1_VENCREA	SIZE 48,08 OF oPanel1 PIXEL HASBUTTON When .F.

		//////////////////////////
		//Dados Gerais

		nUltLin := 10
		@ nUltLin,005 SAY STR0015 SIZE 39, 07 OF oPanel2 PIXEL //"Hist.Emiss„o"
		@ nUltLin,065 MSGET SE1->E1_HIST       SIZE 65, 08 OF oPanel2 PIXEL When .F.

		nUltLin += 12
		@ nUltLin,005 SAY STR0016 SIZE 35, 07 OF oPanel2 PIXEL //"Situa‡„o"
		@ nUltLin,065 MSGET cSituacao          SIZE 65, 08 OF oPanel2 PIXEL When .F.

		nUltLin += 12
		@ nUltLin,005 SAY STR0023 SIZE 32, 07 OF oPanel2 PIXEL //"Mot.Baixa"

		aVlOringl[ 1 ] := nValRec
		aVlOringl[ 2 ] := nPIS
		aVlOringl[ 3 ] := nCOFINS
		aVlOringl[ 4 ] := nCSLL
		aVlOringl[ 5 ] := nJuros
		aVlOringl[ 6 ] := nMulta
		aVlOringl[ 7 ] := nDescont
		aVlOringl[ 8 ] := nBase

		@ nUltLin,065 MSCOMBOBOX oCbx VAR cMotBx ITEMS aDescMotBx SIZE 65, 47 OF oPanel2 PIXEL ;
					ON CHANGE oBanco:lReadOnly := FN022SITCB(SE1->E1_SITUACA)[3] .or. !MovBcobx(cMotBx, .T.) ;
					VALID u_xfa070BDev(oJuros, oMulta, oDescont, oCm, nTxMoeda, oCbx,.T., aImpos,oDtBaixa,aTitCalc)	.and. ;
					fA070Val(nValRec,nTxMoeda,(!Empty(oCbx) .AND. oCbx:lModified),.T.) .and. ;
					IIF(lFA070MDB,lMdbOk:=ExecBlock("FA070MDB",.F.,.F.),.T.)

		nUltLin += 18
		@ nUltLin,005 SAY STR0017 SIZE 32, 07 OF oPanel2 PIXEL //"Banco"
		@ nUltLin,065 MSGET oBanco var cBanco  SIZE 65, 08 OF oPanel2 PIXEL F3 cF3Bco ;
				Valid (u_xAtulValidou() .And. !MovBcobx(cMotBx, .T.) .and. Empty(cBanco)) .or. ;
						(IiF(lFa070Bco,ExecBlock("FA070BCO",.F.,.F.),.T.) .And.;
							u_xF070VldBco(cBanco,@cAgencia,@cConta,.T.,.T.) .And. ;
							f070AltBco(@nTxMoeda, oJuros, oMulta, oDescont, oCm, oBanco, @nValRec, @oTxMoeda,@nOldMoeBco) .And. ;
							ValTxMoeda( nTxMoeda , @nOldTxmoeda , nMulta , nOldMulta , nJuros , nOldJuros, aTitCalc ).And. ;
							Iif(lMoedaBco .And. SE1->E1_MOEDA <> SA6->A6_MOEDA, (F070CnvPcc(nTxMoeda, SE1->E1_MOEDA), oPanel2:Refresh(), .T.),.T.) .And. ;
							IIF(lJFilBco, JurVldSA6("1", {cEscrit, cBanco, cAgencia, cConta}), .T.)) HASBUTTON
		oBanco:lReadOnly := (FN022SITCB(SE1->E1_SITUACA)[3] .OR. !MovBcobx(cMotBx, .T.))

		If RetGlbLGPD("A6_COD") .Or. RetGlbLGPD("A6_AGENCIA") .Or. RetGlbLGPD("A6_NUMCON")
			oBanco:lObfuscate	:= .T.
			oBanco:bWhen		:= {|| .F. }
			cBanco				:= Replicate("*", TamSX3("A6_COD")[1])
			oBanco:cText 		:= cBanco
		EndIf
		nUltLin += 12
		@ nUltLin,005 SAY STR0018 SIZE 32, 07 OF oPanel2 PIXEL //"Agˆncia"
		@ nUltLin,065 MSGET oAgencia var cAgencia  SIZE 65, 08 OF oPanel2 PIXEL Valid ;
							If(!lValidou,If(u_xF070VldBco(cBanco,cAgencia,@cConta,.T.,.T.,cAgencia) .AND. ;
							f070AltBco(@nTxMoeda, oJuros, oMulta, oDescont, oCm, oBanco, @nValRec, @oTxMoeda,@nOldMoeBco) .And. ;
							ValTxMoeda( nTxMoeda , @nOldTxmoeda , nMulta , nOldMulta , nJuros , nOldJuros , aTitCalc ),.T.,oBanco:SetFocus()),.T.) .And. ;
							IIF(lJFilBco, JurVldSA6("2", {cEscrit, cBanco, cAgencia, cConta}), .T.) ;
							WHEN ( !FN022SITCB(SE1->E1_SITUACA)[3] .and. MovBcoBx(cMotBx, .T.) )
		If RetGlbLGPD("A6_COD") .Or. RetGlbLGPD("A6_AGENCIA") .Or. RetGlbLGPD("A6_NUMCON")
			oAgencia:lObfuscate	:= .T.
			oAgencia:bWhen		:= {|| .F. } 
			cAgencia			:= Replicate("*", TamSX3("A6_AGENCIA")[1])	
			oAgencia:cText 		:= cAgencia	
		EndIf
		nUltLin += 12
		@ nUltLin,005 SAY STR0019 SIZE 28, 07 OF oPanel2 PIXEL //"Conta"
		@ nUltLin,065 MSGET oConta var cConta  SIZE 65, 08 OF oPanel2 PIXEL Valid ;
							If(!lValidou,If(u_xF070VldBco(cBanco,cAgencia,cConta,.T.,.T.,cAgencia+cConta) .And. ;
							f070AltBco(@nTxMoeda,oJuros, oMulta, oDescont, oCm,oBanco,@nValRec, @oTxMoeda,@nOldMoeBco) .And. ;
							ValTxMoeda( nTxMoeda , @nOldTxmoeda , nMulta , nOldMulta , nJuros , nOldJuros, aTitCalc  ),.T.,oBanco:SetFocus()),.T.) .And. ;
							IIF(lJFilBco, JurVldSA6("3", {cEscrit, cBanco, cAgencia, cConta}), .T.)   ;
							WHEN ( !FN022SITCB(SE1->E1_SITUACA)[3] .and. MovBcoBx(cMotBx, .T.) )

		If RetGlbLGPD("A6_COD") .Or. RetGlbLGPD("A6_AGENCIA") .Or. RetGlbLGPD("A6_NUMCON")
			oConta:lObfuscate	:= .T.
			oConta:bWhen		:= {|| .F. }
			cConta				:= Replicate("*", TamSX3("A6_NUMCON")[1]) 	
			oConta:cText 		:= cConta	
		EndIf
		nUltLin += 12
		dDtRecbAux := dBaixa
		@ nUltLin,005 SAY STR0020 SIZE 39, 07 OF oPanel2 PIXEL//"Data Receb."
		@ nUltLin,065 MSGET oDtBaixa VAR dBaixa SIZE 65, 08 OF oPanel2 PIXEL HASBUTTON When F070DtRe() .and. lAcessdBaixa Valid fA070Data(@nTxMoeda,,oDtBaixa,oJuros,,,,@aImpos,lMudouMulta,aTitCalc) ; //feito a chamada aqui, pois nao estava executando a funcao fa070data ao perder o foco no campo
							 .And. ( ( nOldJuros := nJuros, .T. ) .and. If (dBaixa <> dDataBase .and.;
							  SE1->E1_VALOR == nValRec+nPis+nCofins+nCsll+nIrrf,(nIrrf:=Iif(cPaisLoc == "BRA" .And. !__lCalcImp, FCaIrBxCR(SE1->E1_VALOR),0),Iif(dBaixa < dLastPcc,f070TotMes(dBaixa,.T.,,,dBaixa <> dDtRecbAux),.T.)), .T. ))

		nUltLin += 12
		@ nUltLin,005 SAY STR0021 SIZE 32, 07 OF oPanel2 PIXEL //"Data Cr‚dito"
		@ nUltLin,065 MSGET oDtCredito VAR dDtCredito SIZE 65, 08 OF oPanel2 PIXEL HASBUTTON Valid (dDtCredito >= dBaixa  .and. Iif(cBxDtFin == "2", DtMovFin(dDtCredito,,"2"), .T.) ) .or. lAntCred
		oDtCredito:SetEnable( lAcessDtCredito )

		nUltLin += 12
		@ nUltLin, 005 SAY STR0022	SIZE Iif(lIsRussia, 60, 32), 07 OF oPanel2 PIXEL //"Hist.Baixa"
		@ nUltLin,065 MSGET cHist070           SIZE 65, 08 OF oPanel2 PIXEL HASBUTTON Picture "@!" VALID CheckSX3("E5_HISTOR") When VisualSX3("E5_HISTOR")

		If cPaisLoc == "BRA" .And. SE1->E1_MOEDA > 1
			nUltLin += 12
			@ nUltLin,005 SAY STR0142 	SIZE 53, 07 OF oPanel2 PIXEL //"Taxa contratada"
			@ nUltLin,065 MSGET oTxMoeda VAR nTxMoeda  SIZE 65, 08 OF oPanel2 PIXEL HASBUTTON Picture PesqPict( "SM2","M2_MOEDA"+AllTrim(Str(SE1->E1_MOEDA))) ;
						 			Valid ( ValTxMoeda( nTxMoeda , @nOldTxmoeda , nMulta , nOldMulta , nJuros , nOldJuros, aTitCalc ) , oPanel2:Refresh() )

		EndIf

		nOldTxmoeda := nTxMoeda

		If lSpbInUse
			nUltLin += 12
			@ nUltLin,005 SAY STR0140 SIZE 32, 07 OF oPanel2 PIXEL  //"Modalidade SPB"
			@ nUltLin,065 COMBOBOX oModSPB VAR cModSpb ITEMS aModalSpb SIZE 65, 47 OF oPanel2 PIXEL ;
								  When MovBcoBx(cMotBx,.T.)
		EndIf

		nUltLin += 12
		@ nUltLin,005 SAY STR0173 SIZE 100, 07 OF oPanel2 PIXEL	//"Rateio Mult.Naturezas"
		@ nUltLin,065 CHECKBOX oMultNat VAR lMultNat PROMPT "" SIZE 12,12 OF oPanel2 PIXEL

		//////////////////////////
		//Dados da Baixa
		nLinha := 10
		If cPaisLoc <> "CHI"
		   @ nLinha,144 SAY STR0027 + cDescMoeda SIZE 53, 08 OF oPanel2 PIXEL COLOR CLR_HBLUE//"Valor Original "
		   @ nLinha,204 MSGET SE1->E1_VALOR  SIZE 66, 08 OF oPanel2 PIXEL COLOR CLR_HBLUE When .F. Picture PesqPict("SE1","E1_VALOR") HASBUTTON //"@E 999,999,999,999.99"

		Else
		   @ nLinha,144 SAY STR0027 SIZE 53, 08 OF oPanel2 PIXEL COLOR CLR_HBLUE //"Valor Original "
		   @ nLinha,204 MSGET SE1->E1_VLCRUZ      SIZE 66, 08 OF oPanel2 PIXEL COLOR CLR_HBLUE When .F. Picture PesqPict("SE1","E1_VLCRUZ") HASBUTTON //"@E 999,999,999,999.99"
		EndIf

		nEstOriginal := nValEstrang-(xMoeda(nJuros+nVA+(nCm1+nProRata)+nMulta-nDescont-nOtrga+nAcresc-nDecresc - Iif(lPccBxCr,nPis+nCofins+nCsll,0)-Iif(lIrPjBxCr,nIrrf,0),nMoedaBco,SE1->E1_MOEDA,,,,nTxMoeda))

		FA070CORR(nEstOriginal,nTxMoeda)

		If cPaisLoc <> "CHI"
			nLinha +=12
			@ nLinha,144 SAY STR0028 SIZE 53, 07 OF oPanel2 PIXEL // "- Abatimentos"
			@ nLinha,204 MSGET nTotAbLiq   SIZE 66, 08 OF oPanel2 PIXEL When .F.  Picture PesqPict( "SE1","E1_VALOR" ) HASBUTTON  //"@E 999,999,999,999.99"

			If cPaisLoc == "BRA"
				nLinha +=12
				@ nLinha,144 SAY STR0186 SIZE 53, 07 OF oPanel2 PIXEL // "- Impostos"
				@ nLinha,204 MSGET nTotAbImp  SIZE 66, 08 OF oPanel2 PIXEL When .F.  Picture PesqPict( "SE1","E1_VALOR" ) HASBUTTON //"@E 999,999,999,999.99"

				nValorLiq :=  (SE1->E1_VALOR - nTotAbLiq - nTotAbImp)
				nLinha +=12
				@ nLinha,144 SAY STR0187 SIZE 53, 07 OF oPanel2 PIXEL // "Valor Liquido"
				@ nLinha,204 MSGET oValorLiq VAR nValorLiq     SIZE 66, 08 OF oPanel2 PIXEL When .F. Picture PesqPict("SE1","E1_VLCRUZ") HASBUTTON //"@E 999,999,999,999.99"
			EndIf
		Else
			nLinha +=12
			@ nLinha,144 SAY STR0134 SIZE 53, 7 OF oPanel2 PIXEL // "+/- Dif. Cambio"
			@ nLinha,204 MSGET oDifCambio VAR nDifCambio SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON Picture PesqPict("SE1","E1_VLCRUZ" /*"E1_CAMBIO"*/)  When .F.
		EndIf
		nLinha +=12
		@ nLinha,144 SAY STR0029 SIZE 53, 07 OF oPanel2 PIXEL //"- Pagtos Parciais"
		@ nLinha,204 MSGET nParciais          SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON When .F.  Picture PesqPict( "SE1","E1_VALOR" )  //"@E 999,999,999,999.99"

		nLinha +=12
		@ nLinha,144 SAY  STR0136 SIZE 53, 07 OF oPanel2 PIXEL //"- Decrescimo"
		@ nLinha,204 MSGET Iif(lSDDECVL, SE1->E1_DECRESC,Iif(nDecrescF > 0,nDecrescF,nDecrVlr))  SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON     Picture PesqPict( "SE1","E1_DECRESC" )  When .f.

		nLinha +=12
		@ nLinha,144 SAY STR0135 SIZE 53, 07 OF oPanel2 PIXEL //"+ Acrescimo"
		@ nLinha,204 MSGET IIF(lSDACRVL,SE1->E1_ACRESC,nAcresc)  SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON     Picture PesqPict( "SE1","E1_ACRESC" )  When .F.

		// Template GEM, campos especifico do template.
		If lGemInUse
			nLinha +=12
			@ nLinha,144 SAY STR0203 SIZE 53, 07 OF oPanel2 PIXEL // "+ C.M."
			@ nLinha,204 MSGET oCM1 VAR nCM1  SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON When iIf( IIf(ExistBlock("PEBLQCM"), ExecBlock("PEBLQCM",.F.,.F.), .F.) .Or. SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG .And. !MovBcobx(cMotBx, .T.), .F., .T.)  Picture PesqPict( "SE1","E1_JUROS" ) ; //"@E 999,999,999,999.99"
																Valid fa070CM1(oCM1,oJuros,oMulta) .AND. fa070Calc( nTxMoeda )
		EndIf

		nLinha +=12
		@ nLinha,144 SAY STR0030 SIZE 53, 07 OF oPanel2 PIXEL //"- Descontos"
		@ nLinha,204 MSGET oDescont VAR nDescont  SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON When F070DSC() .And. If(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG .And. !MovBcobx(cMotBx, .T.), .F., .T.) .And. lAcessDesc Picture PesqPict( "SE1","E1_DESCONT" ) ; //"@E 999,999,999,999.99"
																Valid F70VlDsc(lTpDesc,lNatApura)

		oDescont:SetEnable( lAcessDesc )
		nOldDescont := nDescont

		// Template GEM, campo especifico do template.
		If lGemInUse
			nLinha +=12
			@ nLinha,144 SAY STR0204 SIZE 53, 07 OF oPanel2 PIXEL // "+ Pro Rata"
			@ nLinha,204 MSGET oProRata VAR nProRata SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON When iIf(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG .And. !MovBcobx(cMotBx, .T.), .F., .T.)  Picture PesqPict( "SE1","E1_JUROS" ) ; //"@E 999,999,999,999.99"
																Valid fa070PRata( oProRata ,oJuros ,oMulta, aTitCalc ) .AND. fa070Calc( nTxMoeda )
		EndIf

		nLinha +=12
		@ nLinha,144 SAY STR0101 SIZE 53, 07 OF oPanel2 PIXEL //"+ Multa"
		@ nLinha,204 MSGET oMulta VAR nMulta  SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON When If(F070Mul(oMulta,aTitCalc) .And. SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG .And. !MovBcobx(cMotBx, .T.), .F., .T.)  .And. lAcessMul Picture PesqPict( "SE1","E1_MULTA" ) ; //"@E 999,999,999,999.99"
															Valid (F070Mul(oMulta,aTitCalc),Iif( (!Empty(oMulta) .AND. oMulta:lModified), (fA070Val(nMulta,nTxMoeda),Iif(nOldMulta <> nMulta, lMudouMulta := .T., lMudouMulta := .F.),nOldMulta := nMulta), .T.))
		oMulta:SetEnable( lAcessMul )
		nOldMulta := nMulta

	   If cPaisLoc <> "CHI"
			nLinha +=12
			@ nLinha,144 SAY STR0031 SIZE 53, 07 OF oPanel2 PIXEL //"+ Tx.Permanenc."
			@ nLinha,204 MSGET oJuros VAR nJuros   SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON When F070Jrs() .And. If(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG .And. !MovBcobx(cMotBx, .T.), .F., .T.) .And. lAcessJur Picture PesqPict( "SE1","E1_JUROS" ) ; //"@E 999,999,999,999.99"
															Valid F070TxPer(oJuros,aTitCalc) .AND. Iif(!Empty(oJuros) .and. oJuros:lModified, (fA070Val(nJuros,nTxMoeda),nOldJuros := nJuros),.T.)
		   	oJuros:SetEnable( lAcessJur )
			nOldJuros := nJuros
		Else
		   nLinha +=12
		   @ nLinha,144 SAY STR0133 SIZE 53, 07 OF oPanel2 PIXEL //"- Outros Gastos"
		   @ nLinha,204 MSGET oOtrga VAR nOtrga  SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON     Picture PesqPict( "SE1","E1_OTRGA" ) ; //"@E 999,999,999,999.99"
		   Valid fA070Val(nOtrga)
		EndIf

		//Valores Acessorios
		If lPodeTVA .and. lExistVA
		 	FAPodeTVA(SE1->E1_TIPO,SE1->E1_NATUREZ,.F.,"R")
			nLinha +=12
			@ nLinha,144 SAY "+ " + STR0274 	SIZE 53,07 OF oPanel2 PIXEL		//"Valores Acessórios"
			@ nLinha,204 MSGET oVA VAR nVA SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON Picture PesqPict("FKD","FKD_VALOR") When  .F.
			nOldVA := nVA
		EndIf

		//Controla IRPJ na baixa
		If cPaisLoc == "BRA" .And. lIrPjBxCr .And. !__lIrfMR
			nLinha +=12
			@ nLinha,144 SAY STR0228  SIZE 53, 07 OF oPanel2 PIXEL  // "- IRRF"
			@ nLinha,204 MSGET oIrrf VAR nIrrf SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON Picture PesqPict( "SE1","E1_IRRF" ); //"@E 999,999,999,999.99"
															 Valid Iif( nOldIrrf # nIrrf, (fA070Val(nIrrf,nTxMoeda,.T.,,"IRRF"),nOldIrrf := nIrrf), .T.)
			nOldIrrf := nIrrf
		EndIf

		If cPaisLoc == "BRA" .And. lPccBxCR .And. !__lPccMR //1-Retem PCC na Baixa ou 2-Retem PCC na Emissão(default)
			nLinha +=12
			@ nLinha,144 SAY STR0216 SIZE 53, 07 OF oPanel2 PIXEL //"- PIS"
			@ nLinha,204 MSGET oPIS VAR nPIS   SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON  Picture PesqPict( "SE1","E1_PIS" ) ; //"@E 999,999,999,999.99"
					Valid Iif(nOldPis # nPis, (fA070Val(nPIS,nTxMoeda,.T.,,"PIS"),nOldPis := nPis), .T.)
			nOldPis := nPis
			oPIS:SetEnable( lAcessPIS )

			nLinha +=12
			@ nLinha,144 SAY STR0217 SIZE 53, 07 OF oPanel2 PIXEL //"- COFINS"
			@ nLinha,204 MSGET oCOFINS VAR nCOFINS   SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON Picture PesqPict( "SE1","E1_COFINS" ) ; //"@E 999,999,999,999.99"
				Valid Iif(nOldCofins # nCofins, (fA070Val(nCOFINS,nTxMoeda,.T.,,"COFINS"),nOldCofins := nCofins), .T.)
			nOldCofins := nCofins
			oCOFINS:SetEnable( lAcessCOF )

			nLinha +=12
			@ nLinha,144 SAY STR0218 SIZE 53, 07 OF oPanel2 PIXEL //"- CSLL"
			@ nLinha,204 MSGET oCSLL VAR nCSLL   SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON Picture PesqPict( "SE1","E1_CSLL" ) ; //"@E 999,999,999,999.99"
				Valid (oCSLL:Refresh(),Iif(nOldCsll # nCsll, (fA070Val(nCsll,nTxMoeda,.T.,,"CSLL"),nOldCsll := nCsll), .T.))
			nOldCsll := nCsll
			oCSLL:SetEnable( lAcessCSLL )
		EndIf

		If __lTemMR .And. __nTotImp > 0
			nLinha +=12
			@ nLinha,144 SAY STR0286	SIZE 53,07 OF oPanel2 PIXEL //"- Retenções"
			@ nLinha,204 MSGET __oRetMot VAR __nTotImp	SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON Picture PesqPict("SE1","E1_VALLIQ")  ;
			Valid .T. When .F.
		EndIf

        nLinha +=12
        @ nLinha,144 SAY STR0033 SIZE 53,07 OF oPanel2 PIXEL COLOR CLR_HBLUE //"= Valor Recebido"
        @ nLinha,204 MSGET oValRec VAR nValRec SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON COLOR CLR_HBLUE Picture PesqPict( "SE1","E1_VALOR" )  ;//"@E 999,999,999,999.99"
                                                        Valid (     (oValRec:Refresh(), .T.) .And. ;
                                                                    fa070Calc(nTxMoeda,.F.,.T.,.T.) .And. ;
                                                                    Fa070ValVR(nTxMoeda) .And. ;
                                                                    Iif(u_xFA070ValRec(oJuros,oMulta,oProRata,oDescont,aVlOringl,@aImpos,oValRec:lModified, aTitCalc) .and. Fa070Liq(oJuros,oValRec, oPanel2),   ;
                                                                    (oVlEstrang:Refresh() , oCM:Refresh(), .T.),;
                                                                    (oVlEstrang:Refresh() , oCM:Refresh(),oValRec:Refresh(), .F.))) 
                                                                                                                                
        nLinha +=12
        @ nLinha,144 SAY STR0034+SubStr(GetMV("MV_SIMB"+cMoeda),1,3) SIZE 53, 7 OF oPanel2 PIXEL // "Valor "
        @ nLinha,204 MSGET oVlEstrang VAR nValEstrang SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON  ;
                        Picture PesqPict( "SE1","E1_VALOR" )  ;
                        VALID Iif(FA070Estrang(nTxMoeda),.T.,(Help(" ",1,"ValorMaior"),.F.)) .And.;
                                Fa070ValEstrang(	nValEstrang,@nTxMoeda,@nValRec,dBaixa,oValRec,oTxMoeda,;
                                                    nJuros+(nCm1+nProRata),nMulta,nDescont,nOtrga,nEstOriginal,oVlEstrang) .And.;
	                            u_xFA070ValRec(oJuros,oMulta,oProRata,oDescont,,@aImpos,, aTitCalc)
        nLinha +=12
        @ nLinha,144 SAY STR0032 SIZE 53,07 OF oPanel2 PIXEL // "+ Corr.Monet ria"
        @ nLinha,204 MSGET oCM     VAR nCM		SIZE 66, 08 OF oPanel2 PIXEL HASBUTTON     Picture PesqPict( "SE1", "E1_CORREC" )  ; // "@E 999,999,999,999.99"
                                                        When ( lCalcCM .And. cPaisLoc <> "BRA" ) .OR. lLibCm

		If ( cPaisLoc <> "BRA" )
			If lIsRussia
				AADD(aButtons, {"TABPRICE", {|| (nTxMoeda:=Fa070SetMd(),f070AltBco(nTxMoeda,oJuros, oMulta, oDescont, oCm))}, STR0307 }) //Troca de Taxas
			Else
	            AADD(aButtons, {"TABPRICE", {|| (nTxMoeda:=Fa070SetMd(),Iif( nOldJuros + nJuros > 0 , fA070Data(nTxMoeda,.F.,,,,.T.) , Nil ) , Iif( nOldMulta + nMulta > 0 , fA070Val(nMulta,nTxMoeda) , Nil ) , F070CnvPcc(nTxMoeda, SE1->E1_MOEDA) , oPanel2:Refresh())},"MOEDAS" }) //Troca de Taxas
			EndIf
		Endif

		If __lTemMR .And. __nTotImp > 0
			Aadd(aButtons, {"NOTE", {||F070ConImp(aImpos)},,STR0284,STR0284}) //"Retenção de impostos"
		EndIf

		If lPanelFin
			ACTIVATE MSDIALOG oDlg ON INIT FaMyBar(oDlg,{|| IIf(FA070BtOK(),iIf( IIf( MovBcoBx(cMotBx, .T.),u_xF070VldBco(cBanco,cAgencia,cConta,.T.,.F.), .T. ) ;
					.and. If(cBxDtFin == "2",DtMovFin(dBaixa,,"2"),.T.) .and. PcoVldLan("000004","01","FINA070") .and. iIf(lFA070MDB .and. !lMdbOk,lMdbOk:=ExecBlock("FA070MDB",.F.,.F.) ,.T.) ,;
					(nOpc1 := 1,oDlg:End()),Nil),Nil)},;
					{||(nOpc1 := 0,oDlg:End())},aButtons) CENTERED
		Else
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| iIf(FA070BtOK(),iIf( IIf( MovBcoBx(cMotBx, .T.),u_xF070VldBco(cBanco,cAgencia,cConta,.T.,.T.), .T. ) ;
					.and. If(cBxDtFin == "2",DtMovFin(dBaixa,,"2"),.T.) .and. 	PcoVldLan("000004","01","FINA070") .and. iIf(lFA070MDB .and. !lMdbOk,lMdbOk:=ExecBlock("FA070MDB",.F.,.F.) ,.T.) ;
					,IIf( UsaSeqCor(), IIf( FA070Diario(), (nOpc1 := 1,oDlg:End()),Nil), (nOpc1 := 1,oDlg:End()) ) ;
					,Nil),Nil)};
					,{||(nOpc1 := 0,oDlg:End())},,aButtons) CENTERED
		EndIf

		Pergunte("FIN070",.F.)
				
		If __lTemMR  .and. __lPropPcc .and. nValrec < __nTotImp
			nImp := Len(aImpos)
			For nW := 1 To nImp
				Do Case
					Case __lPccMR .And. nPis <> nOldPis .And. AllTrim(aImpos[nW,8]) == "PIS" .And. aImpos[nW,9] == "2"
						aImpos[nW,5] := nPis
					Case __lPccMR .And. nCofins <> nOldCofins .And. AllTrim(aImpos[nW,8]) == "COF" .And. aImpos[nW,9] == "2"
						aImpos[nW,5] := nCofins
					Case __lPccMR .And. nCsll <> nOldCsll .And. AllTrim(aImpos[nW,8]) == "CSL" .And. aImpos[nW,9] == "2"
						aImpos[nW,5] := nCsll
					Case __nTotImp <> nOldImp .And.(!(AllTrim(aImpos[nW,8]) == "PIS") .And. !(AllTrim(aImpos[nW,8]) == "COF") .And. !(AllTrim(aImpos[nW,8]) == "CSL"))  .And. aImpos[nW,9] == "2"
						aImpos[nW,5] := __nTotImp
				End Case
			Next nW
		EndIf
   		If (nPis+nCofins+nCSLL) <> (nOldPis+nOldCofins+nOldCsll)
	   		//Atualiza valores retido, caso o usuário tenha alterado o valor dos impostos
			nVlRetPis := nPis
			nVlRetCof := nCofins
			nVlRetCsl := nCsll
	   		//Refazendo base de retenção caso ocorra alteração do usuário
			nPisBaseR   := nPis * 100
			nCofBaseR   := nCofins * 100
			nCslBaseR   := nCsll * 100
	   	EndIf
  		SetKey(VK_F4,bSetKey)
    Else
    	If FwIsInCallStack("FA450CMP")
			nValOld := nValRec
    	Endif

		//Valores Acessorios
		//ESTRUTURA __aVAAuto
		//__aVAAuto[nLaco][1] = cChaveFK7
		//__aVAAuto[nLaco][2] = Código do VA
		//__aVAAuto[nLaco][3] = Valor do VA
		If lPodeTVA .and. lExistVA
			FKD->( dbSetOrder( 2 ) ) //FKD_FILIAL+FKD_IDDOC+FKD_CODIGO
			nRecSe1 := SE1->(RecNo())

			If Len(__aVAAuto) > 0
				FVAAuto( .T. ) //Indica que, ao ativar o model FINA070VA, os VAs não serão recalculados (pois os valores já vieram na execauto)

				For nLaco := 1 To Len(__aVAAuto)

					cAcaoVA := Posicione( "FKC", 1, FWxFilial("FKC") + __aVAAuto[nLaco][2], "FKC_ACAO" )
					If cAcaoVA == "2" //Se for VA de subtração, então multiplica o valor informado na execauto por -1
						nVaCalc := __aVAAuto[nLaco][3] * -1
					Else
						nVaCalc := __aVAAuto[nLaco][3]
					Endif
					If lFKDID // Proteção campo criado 12.1.25
						aFKDID := FN040VAID( __aVAAuto[nLaco][1], __aVAAuto[nLaco][2], .T. ) // Retorna o recno FKD atual se existir.
						If Len(aFKDID[2]) > 0
							FKD->(DbGoTo(aFKDID[2][1][1]))
							RecLock("FKD",.F.)
								FKD->FKD_VLCALC := nVaCalc
								FKD->FKD_VLINFO := nVaCalc
							FKD->(MsUnlock())
							Loop
						EndIf
					Else
						If FKD->( msSeek( FWxFilial("FKD") + __aVAAuto[nLaco][1] + __aVAAuto[nLaco][2] ) )
							RecLock("FKD",.F.)
								FKD->FKD_VLCALC := nVaCalc
								FKD->FKD_VLINFO := nVaCalc
							FKD->(MsUnlock())
							Loop
						EndIf
					EndIf

					RecLock("FKD",.T.)
						FKD->FKD_FILIAL := xFilial("FKD")
						FKD->FKD_IDDOC  := __aVAAuto[nLaco][1]
						FKD->FKD_CODIGO := __aVAAuto[nLaco][2]
						FKD->FKD_VALOR  := __aVAAuto[nLaco][3]
						FKD->FKD_SALDO  := 0
						FKD->FKD_DTBAIX := CtoD("//")
						FKD->FKD_VLCALC := nVaCalc
						FKD->FKD_VLINFO := nVaCalc
						If lFKDID // Proteção campo criado 12.1.25
							FKD->FKD_IDFKD  := FWUUIDV4()
						EndIf
					FKD->(MsUnlock())
				Next nLaco
			ElseIf lF070Auto
				FVAAuto( .F. ) //Indica que, ao ativar o model FINA070VA, os VAs serão calculados
			Endif

			//Ativa o modelo de dados para calcular os VAs (ou considerar os valores recebidos na execauto)
			cOldVA := ""
			oModelVA := FWLoadModel("FINA070VA")
			oModelVA:SetOperation( MODEL_OPERATION_UPDATE )
			oModelVA:Activate()
			cOldVA  := oModelVA:GetXMLData(,,,,.F.,,,)
			oModelVa:Deactivate()
			oModelVa:Destroy()
			oModelVa := NIL
			FVAAuto( .F. )

			dbSelectArea("SE1")
			SE1->( dbGoTo(nRecSe1) )

		Endif

		aValidGet:= {}
		
		If (nT := ascan(aAutoCab,{|x| x[1]='AUTMOTBX'})) > 0
			cMotBx	:=	aAutoCab[nT,2]
			If Len(AllTrim(cMotBx)) == 3
				If (nY := ascan(aMotBx,{|x| SubStr(x,1,3) == AllTrim(cMotBx)})) > 0
					aAutoCab[nT,2] := SubStr(aMotBx[nY],07,10)
					cMotBx := aAutoCab[nT,2]
				EndIf
			EndIf
			If ! lFA070MDB
	 	 		Aadd(aValidGet,{'cMotBx' ,aAutoCab[nT,2],"fa070BDev()",.t.})
	 	 	Else
 	 			Aadd(aValidGet,{'cMotBx' ,aAutoCab[nT,2],"fa070BDev()	.and. ExecBlock('FA070MDB',.F.,.F.)",.t.})
 	 		EndIf
 	 	EndIf
		
		If (! FN022SITCB(SE1->E1_SITUACA)[3]) .and. MovBcobx(cMotBx, .T.)
			If (nT := ascan(aAutoCab,{|x| x[1]='AUTBANCO'})) > 0
				Aadd(aValidGet,{'cBanco' ,aAutoCab[nT,2],"u_xCarregaSa(@cBanco,,,.T.)",.t.})
			Endif
			If (nT := ascan(aAutoCab,{|x| x[1]='AUTAGENCIA'}) ) > 0
				Aadd(aValidGet,{'cAgencia' ,aAutoCab[nT,2],"u_xCarregaSa(@cBanco,@cAgencia,,.T.)",.t.})
			EndIf
			If (nT := ascan(aAutoCab,{|x| x[1]='AUTCONTA'}) ) > 0
				Aadd(aValidGet,{'cConta' ,aAutoCab[nT,2],"u_xCarregaSa(@cBanco,@cAgencia,@cConta,.T.,,.T.)",.t.})
			EndIf
		EndIF
		
		If (nT := ascan(aAutoCab,{|x| x[1]='AUTDTBAIXA'}) ) > 0
            Aadd(aValidGet,{'dBaixa' ,aAutoCab[nT,2],"fA070Data(,.F.)",.t.})
            If (AllTrim(SE1->E1_ORIGEM) $ 'L|S|T' .Or. SE1->E1_IDLAN > 0)
                dBaixa := aAutoCab[nT,2]
			EndIf
		EndIf
		
		If (nT := ascan(aAutoCab,{|x| x[1]='AUTDTCREDITO'}) ) > 0
		   Aadd(aValidGet,{'dDTCredito' ,aAutoCab[nT,2],"(dDtCredito >= dBaixa  .and. Iif(SuperGetMv('MV_BXDTFIN',,'1') == '2', DtMovFin(dDtCredito), .T.)) .or. GetMv('MV_ANTCRED')",.t.})
            If (AllTrim(SE1->E1_ORIGEM) $ 'L|S|T' .Or. SE1->E1_IDLAN > 0)
                dDTCredito := aAutoCab[nT,2]
            EndIf
        EndIf
		
		If VisualSX3("E5_HISTOR") .AND. (nT := ascan(aAutoCab,{|x| x[1]='AUTHIST'}) ) > 0
			Aadd(aValidGet,{'cHist070' ,aAutoCab[nT,2],"CheckSX3('E5_HISTOR')",.t.})
			If (AllTrim(SE1->E1_ORIGEM) $ 'L|S|T' .Or. SE1->E1_IDLAN > 0)
				cHist070 := aAutoCab[nT,2]
			EndIf
		EndIf

		If (nT := ascan(aAutoCab,{|x| x[1]='AUTACRESC'}) ) > 0
			Aadd(aValidGet,{'nAcresc' ,aAutoCab[nT,2],"fA070Val(nAcresc)",.t.})
		EndIf

		If (nT := ascan(aAutoCab,{|x| x[1]='AUTMULTA'}) ) > 0
			Aadd(aValidGet,{'nMulta' ,aAutoCab[nT,2],"fA070Val(nMulta)",.t.})
		EndIf
		If (nT := ascan(aAutoCab,{|x| x[1]='AUTJUROS'}) ) > 0
			Aadd(aValidGet,{'nJuros' ,aAutoCab[nT,2],"fA070Val(nJuros)",.t.})
		EndIf

		// Template GEM, validacao dos campos especificos do template.
		If lGemInUse
			If (nT := ascan(aAutoCab,{|x| x[1]='AUTCM1'}) ) > 0
				Aadd(aValidGet,{'nCM1' ,aAutoCab[nT,2],"fa070Calc()",.t.})
			EndIf
			If (nT := ascan(aAutoCab,{|x| x[1]='AUTPRORATA'}) ) > 0
				Aadd(aValidGet,{'nProRata' ,aAutoCab[nT,2],"fa070Calc()",.t.})
			EndIf
		EndIf

		If (nT := ascan(aAutoCab,{|x| x[1]='AUTDESCONT'}) ) > 0
			If lGemInUse
				Aadd(aValidGet,{'nDescont' ,aAutoCab[nT,2],"u_xFA070DESC(oDescont) .and. fA070Val(nDescont) .and. (nDescont <= (Round(nCM1+nMulta+nJuros+nVA+nProRata,2)+xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,nMoedaBco,dBAIXA,,nTxMoeda)))",.t.})
			Else
				Aadd(aValidGet,{'nDescont' ,aAutoCab[nT,2],"u_xFA070DESC(oDescont) .and. fA070Val(nDescont) .and. (nDescont <= Round(nMulta+nJuros+nVA,2)+xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,nMoedaBco,dBAIXA,,nTxMoeda))",.t.})
			Endif

		EndIf

		If (nT := ascan(aAutoCab,{|x| x[1]='AUTDECRESC'}) ) > 0
			Aadd(aValidGet,{'nDecresc' ,aAutoCab[nT,2],"fA070Val(nDecresc)",.t.})
		EndIf

		If SE1->E1_MOEDA > 1  .Or. cPaisLoc<>"BRA"
			If cPaisLoc == "BRA"
				If (nT := ascan(aAutoCab,{|x| x[1]='AUTTXMOEDA'}) ) > 0
					nTxMoeda	:=	aAutoCab[nT,2]
					Aadd(aValidGet,{'nTxMoeda' ,aAutoCab[nT,2],"Fa070Val(0,"+STR(nTxMoeda,17,TamSx3("E2_TXMOEDA")[2])+")",.t.})
				EndIf
			Endif
			If (nT := ascan(aAutoCab,{|x| x[1]='AUTVALREC'}) ) > 0
				Aadd(aValidGet,{'nValRec' ,aAutoCab[nT,2],"Fa070ValVR("+Alltrim(Str(nTxMoeda))+")",.t.})
			EndIf
		Else
			If (nT := ascan(aAutoCab,{|x| x[1]='AUTVALREC'}) ) > 0
				Aadd(aValidGet,{'nValRec' ,aAutoCab[nT,2],".T.",.t.})
			EndIf
		Endif
		
		nEstOriginal := nValEstrang-(xMoeda(nJuros+nVA+(nCm1+nProRata)+nMulta-nDescont-nOtrga+nAcresc-nDecresc - Iif(lPccBxCr,nPis+nCofins+nCsll,0)-Iif(lIrPjBxCr,nIrrf,0),nMoedaBco,SE1->E1_MOEDA,,,,nTxMoeda))
		FA070CORR(nEstOriginal)

		If !( Upper(AllTrim(SE1->E1_ORIGEM)) $ cProdRM )	// Integração RM -> Origem pertence ao parâmetro = Baixa RM |||  Origem não pertence ao parâmetro = Baixa Protheus
			nInicio := Seconds()
			If ! SE1->(MsVldGAuto(aValidGet)) // consiste os gets
				Return .f.
			EndIf
			nFim := Seconds() - nInicio
			If __lMetric
				SetFunName(__cFunMet)
				// Metrica do tempo das validações execauto
        		FwCustomMetrics():setAverageMetric("AutTempoVld", "financeiro-protheus_tempo-conclusão-processo_seconds", nFim)
				SetFunName(__cFunBkp)
			Endif
		EndIf

		If lF070Auto
			//Se o valor acessório vínculado (FKD) não foi informado na ExecAuto, então a rotina fará o cálculo e nesse trecho irá tratar (subtrair ou somar) o VA no valor recebido.
			If ValType( __AVAAUTO ) <> "A" .Or. Len( __AVAAUTO ) == 0
				nValRec := nValRec + nVA
			EndIf

			If !lMVGlosa
				If lFINA200 .Or. FwIsInCallStack("Fa450cmp") .Or. (AllTrim(SE1->E1_ORIGEM) $ 'S|L|T') // se for retorno do Cnab ou compesação entre carteiras ou baixa oriunda de integração

					// Considera diretamente os valores passados pela EXECAUTO.
					If (nT := ascan(aAutoCab,{|x| x[1]='AUTJUROS'}) ) > 0
						nJuros := Round(NoRound(aAutoCab[nT,2]),2)
					EndIf

					If (nT := ascan(aAutoCab,{|x| x[1]='AUTDESCONT'}) ) > 0
						nDescont := Round(NoRound(aAutoCab[nT,2]),2)
					EndIf

					If (nT := ascan(aAutoCab,{|x| x[1]='AUTMULTA'}) ) > 0
						nMulta := Round(NoRound(aAutoCab[nT,2]),2)
					EndIf

					If (nT := ascan(aAutoCab,{|x| x[1]='AUTACRESC'}) ) > 0
						nAcresc := Round(NoRound(aAutoCab[nT,2]),2)
					EndIf

					If (nT := ascan(aAutoCab,{|x| x[1]='AUTDECRESC'}) ) > 0
						nDecresc := Round(NoRound(aAutoCab[nT,2]),2)
					EndIf

					If !(lRecIss := (lModDesIss .And. SA1->A1_RECISS == "1" .And. AllTrim(SE1->E1_ORIGEM) == "FINA040"))
						If lModDesIss .And. lSC5RecIss .And. AllTrim(SE1->E1_ORIGEM) != "FINA040"
							SC5->(dbSetOrder(1))
							lRecIss := (SC5->(DbSeek(xFilial("SC5", SE1->E1_FILORIG)+SE1->E1_PEDIDO)) .And. (SC5->C5_RECISS == "1"))
						Endif					
					EndIf
					
					If nValRec == SE1->E1_VALOR // Só se for baixa total por Cnab					
						nValrec -= Iif(lPccBxCr,  0, SE1->(E1_PIS+E1_COFINS+E1_CSLL)) //PCC
						nValrec -= Iif(lIrPjBxCr, 0, SE1->E1_IRRF) + SE1->E1_INSS     //IRRF + INSS
						
						If lRecIss .And. !(lFINA200 .And. AllTrim(SE1->E1_ORIGEM) != "FINA040")
							nValrec -= SE1->E1_ISS //ISS
						EndIf									
					Endif
					
					If lPccBxCr
						nValrec -= nPis + nCofins + nCsll
						nAuxImpAut += nPis + nCofins + nCsll
					EndIf
					
					If lIrPjBxCr
						nValrec -= nIrrf
						nAuxImpAut += nIrrf
					EndIf
					
					If lCalcIssBx .And. lRecIss
						If !(lFINA200 .And. AllTrim(SE1->E1_ORIGEM) != "FINA040")
							nValrec -= SE1->E1_ISS
						EndIf
						
						nAuxImpAut += SE1->E1_ISS
					EndIf

					nValRec += nJuros + nVA - nDescont + nMulta + nAcresc - nDecresc
								
					If (AllTrim(SE1->E1_ORIGEM) $ 'S|L|T') .AND. lAutValRec		// Integração e foi passado valor a ser baixado nValRec (PaymentValue)
						/*
							Intensão é identificar se o valor passado seria para baixa parcial.
							Sendo baixa parcial, considerar o nValRec com o valor passado (PaymentValue)
							Obs: Considerar a possibilidade de assumir como nValRec o que foi mandado no PaymentValue
						*/
						nPos := aScan(aAutoCab,{|x| x[1] == 'AUTVALREC'})
						nAux2 := aAutoCab[nPos,2]	// Valor passado xml
						If nAux2 <= SE1->E1_SALDO + nTotMult + nJuros + nVA - nDescont + nMulta + nAcresc - nDecresc - nAuxImpAut
							nValRec := nAux2
						EndIf

					EndIf

					If (nT := ascan(aAutoCab,{|x| x[1]='AUTVALREC'}) ) > 0
						aAutoCab[nT,2] := Round(NoRound(nValRec,2),2)
					EndIf
				Else
					If !lBq10925 // Baixa Parcial - Liquido
						nOldValRec := nValRec
						nValRec := nValRec - nPis - nCoFins - nCsll - nIrrf

						If nValRec < 0
							nValRec := nOldValRec
						Endif

						If (nT := ascan(aAutoCab,{|x| x[1]='AUTVALREC'}) ) > 0
							aAutoCab[nT,2] := Round(NoRound(nValRec,2),2)
						EndIf
					EndIf
				EndIf
			EndIf
		Endif

		nOpc1 := 1

		// Se o conteudo do campo estiver vazio(zero), se existir o 4o. elemento no array de campos
		// e o mesmo retornar .T., assume os valores que o usuario enviou no array da rotina automatica
		If (nT := ascan(aAutoCab,{|x| x[1]='AUTJUROS'}) ) > 0
			If Empty(aAutoCab[nT,2]) .And. Len(aAutoCab[nT]) >= 4 .And. aAutoCab[nT][4]
				nJuros := aAutoCab[nT,2]
				fa070val(nJuros,nTxMoeda,.F.)
			Endif
		EndIf
		If (nT := ascan(aAutoCab,{|x| x[1]='AUTMULTA'}) ) > 0
			If Empty(aAutoCab[nT,2]) .And. Len(aAutoCab[nT]) >= 4 .And. aAutoCab[nT][4]
				nMulta := aAutoCab[nT,2]
				fa070val(nMulta,nTxMoeda,.F.)
			Endif
		EndIf
		If (nT := ascan(aAutoCab,{|x| x[1]='AUTDESCONT'}) ) > 0
			If Empty(aAutoCab[nT,2]) .And. Len(aAutoCab[nT]) >= 4 .And. aAutoCab[nT][4]
				nDescont := aAutoCab[nT,2]
				fa070val(nDescont,nTxMoeda,.F.)
			Endif
		EndIf

		// Template GEM, validacao dos campos especificos do template.
		If lGemInUse
			If (nT := ascan(aAutoCab,{|x| x[1]='AUTCM1'}) ) > 0
				If Empty(aAutoCab[nT,2]) .And. Len(aAutoCab[nT]) >= 4 .And. aAutoCab[nT][4]
					nCM1 := aAutoCab[nT,2]
					fa070val(nCM1)
				EndIf
			EndIf
			If (nT := ascan(aAutoCab,{|x| x[1]='AUTPRORATA'}) ) > 0
				If Empty(aAutoCab[nT,2]) .And. Len(aAutoCab[nT]) >= 4 .And. aAutoCab[nT][4]
					nProRata := aAutoCab[nT,2]
					fa070val(nProRata)
				EndIf
			EndIf
		EndIf
	EndIf

	//Define a variável estática que indica se a tela de baixa foi cancelada (controle de processo com integração Protheus x TIN)
	__lCancTBx := ( nOpc1 == 0 )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada para permitir um controle do total de ³
	//³ cheques informados com o total a ser baixado           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lF070TCTR .And. nOpc1 > 0 .And. nSomaCheq > 0
		nOpc1 := ExecBlock("F070TCTR",.F.,.F.,{nOpc1,nSomaCheq,nValRec})
	EndIf

	If nOpc1 == 1
		If aCols <> Nil
			If Type("aCols") == "A" .And. Len(aCols) > 0
				For nCountCH := 1 To Len(aCols)
					If Empty(aCols[nCountCH,7])
						Help(" ",1,"F070VLDCH",, STR0308,1,0) // "Existe cheque vinculado que não tem remetente informado. Favor rever o cadastro de cheques." 
						Return .F.
					Endif
				Next nCountCH
			Else
				//Se os cheques foram incluídos no FINA040 e o usuário não clicar no botão de cheque na hora da baixa,
				//então será carregado o aCols com os cheques para fazer a gravação da sequencia da baixa, conforme os
				//movimentos gerados no SE5.
				If Empty(aCols) .And. Type("cMotBx") == "C" .And. ChqMotBx(cMotBx)
					CadCheqCR(Nil,Nil,Nil,Nil,Nil,1,Nil,.F.)
				EndIf
				If Type("aCols") == "A" .And. Len(aCols) > 0
					For nCountCH := 1 To Len(aCols)
						If Empty(aCols[nCountCH,7])
							Help(" ",1,"F070VLDCH",, STR0308,1,0) // "Existe cheque vinculado que não tem remetente informado. Favor rever o cadastro de cheques." 
							aCols := {}
							Return .F.
						Endif
					Next nCountCH
				Endif
			Endif
		Endif
	Endif

	If nOpc1 == 0
		nErro ++
	EndIF

	If !lF070Auto .And. nOpc1 == 0 .And. AllTrim(SE1->E1_ORIGEM)=="FINI055"
		If FWHasEAI("FINI070A",.T.,,.T.)
			SetRotInteg('FINI070A')
			MsgRun ( STR0234+" "+rTrim(SE1->E1_NUM)+ " " +STR0235,STR0236,{||aRetMsg:=FinI070A()} )//"Atualizando título" "a valor presente..." Valor Presente
			If ValType(aRetMSg[1]) <> "U" .And. !aRetMsg[1]
				If ValType(aRetMsg[2]) <> "U" .And. aRetMsg[2] <> Nil .and. !Empty(aRetMsg[2])
					MsgAlert(STR0237 + CRLF + aRetMsg[2])//"Foi realizada uma tentativa de atualização do título, e foi retornada a seguinte mensagem:"
				Else
					MsgAlert(STR0238 + " " + Rtrim(SE1->E1_NUM)+". "+STR0239)//"Ocorreu um erro inesperado na tentativa de atualização do título " "Verifique as configurações da integração  e tente novamente."
				EndIf
			ElseIf Valtype(aRetMSg[1]) == "U"
				MsgAlert(STR0238 + " " + Rtrim(SE1->E1_NUM) + ". " + STR0239)//"Ocorreu um erro inesperado na tentativa de atualização do título " "Verifique as configurações da integração  e tente novamente."
			Endif
			SetRotInteg('FINA070')
		Else
			MsgAlert(STR0240)//"Para realizar as baixas de integrações como TIN, é necessário cadastrar o adapter da rotina FINI070A - UPDATECONTRACTPARCEL."
		EndIf
	Endif

	If SE1->( Deleted() )
		nOpc1 := 0
		Help( " " , 1 , "RECNO" )
		Return .F.
	EndIf

	If nErro > 2
		nErro :=0
		If Abandona()
			MsUnlock()
			Return Nil
		Endif
	Endif
	
	If nOpc1 == 1

		If nCM1 > 0
			nJuros += nCM1
		Else
			nDescont -= nCM1
		EndIf

		If nProRata > 0
			nJuros += nProRata
		Else
			nDescont -= nProRata
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se dados bancários estão OK                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !FwIsInCallStack("FA450CMP")
			If MovBcobx(cMotBx, .T.) .and. !u_xCarregaSA(@cBanco,@cAgencia,@cConta,.T.,,.T.)
				// Se nao for baixa por rotina automatica, volta para o usuario corrigir os
				// dados, senao abandona a baixa.
				If !lF070Auto
					loop
				Else
					lRet := .F.
					Exit
				Endif
			EndIf
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se nao foi alterado o banco quando for tit. em desconto.     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( FN022SITCB(SE1->E1_SITUACA)[3] .And.;
			cBanco+cAgencia+cConta!=SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA )
			Help(" ",1,"FINA070BCO")
			// Se nao for baixa por rotina automatica, volta para o usuario corrigir os
			// dados, senao abandona a baixa.
			If !lF070Auto
				loop
			Else
				lRet := .F.
				Exit
			Endif
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se valor da baixa ‚ maior que o valor m ximo a receber       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If !( lFINA200 .And. lREC2TIT ) .and. !FwIsInCallStack("FA450CMP") // Tratamento do Parâmeto MV_REC2TIT - Geração de RECANT(RA) via RETORNO CNAB.
			If cPaisLoc<>"BRA"
				nValRecL := Round(nValRec,2)
			EndIf
            If !lFina415
                If SE1->E1_MOEDA == 1 .and. Str(Iif(cPaisLoc<>"BRA",nValRecL,nValRec),17,2) > Str(Round(xMoeda(SE1->E1_SALDO-nTotAbat + Iif(SE1->E1_JUROS > 0,nMulta,nTotMult),nMoedaBco,SE1->E1_MOEDA,dBaixa,7,nTxMoeda),2)+Round(Iif(Alltrim(SE1->E1_ORIGEM) == "FINA074",0,nJuros+nVA+nMulta-nDescont-nOtrga+nTolerPg+nAcresc-nDecresc),2),17,2)

					Help(" ",1,"ValorMaior")
                    
                    If ( SE1->E1_MOEDA == 1 )
						// Se nao for baixa por rotina automatica, volta para o usuario corrigir os
						// dados, senao abandona a baixa.
						If !lF070Auto
							nIrrf := 0
							loop
						Else
							lRet := .F.
							Exit
						Endif
					Else
						loop
					EndIf
                ElseIf SE1->E1_MOEDA > 1 .and. Str(xMoeda(nValEstrang, SE1->E1_MOEDA, nMoedaBco,dbaixa,7,nTxMoeda),17,2) > Str(Round(xMoeda(SE1->E1_SALDO-nTotAbat + Iif(SE1->E1_JUROS > 0,nMulta,nTotMult),SE1->E1_MOEDA,nMoedaBco,dBaixa,7,nTxMoeda),2)+Round(Iif(Alltrim(SE1->E1_ORIGEM) == "FINA074",0,nJuros+nVA+nMulta-nDescont-nOtrga+nTolerPg+nAcresc-nDecresc),2),17,2)
                    Help(" ",1,"ValorMaior")
                    loop
                EndIf
			EndIf
		EndIf

		// Se controla saldo na compensacao do cheque
		// A primeira baixa tem que ter no mínimo o valor dos cheques, pois esses são completamente baixados
		// pelo sistema.
		If FwIsInCallStack("FA450CMP")
			nValRec:= nValOld
		EndIf
		If lSaldoChq
			If	!(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG)
				// Soma o total recebido em cheque
				nSomaCheq := SomaCheqCr(.F.,SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE)
				If nValRec < nSomaCheq
			   		Aviso(STR0219,STR0222 + STR0223 ,{STR0221}) //"Não é possível realizar baixa de valor inferior aos cheques amarrados quando MV_SLDBXCR = 'C'.""Nessa configuração, os cheques serão sempre baixados primeiro."
			   		lRet := .F.
			   		exit
				EndIf
			EndIf
		Else 
			nSomaCheq := 0
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida se e baixa parcial, quando e titulo do BIBLIOS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If alltrim(Upper(SE1->E1_ORIGEM)) = 'L' .and. lRMBibli
	        If nValRec < (SE1->E1_VALOR - SE1->E1_DECRESC + E1_ACRESC - nDescont + nMulta + nJuros + nVA )
		   		Aviso(STR0219,STR0220,{STR0221}) //"Não é possivel realizar a baixa parcial de um título nativo do RM Biblios"
		   		lRet := .F.
		   		exit
			endif
        endif

	   //Baixa de titulo em moeda forte com a cotacao da moeda igual a zero !!
		If SE1->E1_MOEDA > 1 .and. RECMOEDA(dBaixa,cMoeda) == 0 .and. nTxMoeda == 0 .and. ;
				nValRec == 0 .and. nValEstrang == 0
			Help(" ",1,"TX_MOEDA",, STR0168,1,0)	//"Nao sera possivel baixar este titulo pois a cotacao da moeda do titulo na data da baixa é igual a zero."
			// Se nao for baixa por rotina automatica, volta para o usuario corrigir os
			// dados, senao abandona a baixa.
			If !lF070Auto
				loop
			Else
				lRet := .F.
				Exit
			Endif
		Endif
		iF FwIsInCallStack("FA450CMP")
			nValRec := nValOld
		Endif
		If nValRec < (nJuros + nVA + nAcresc)
			nValPadrao := nValRec-(nJuros + nVA+Iif(SE1->E1_MOEDA<=1,nCM,0)+nMulta-nDescont-nDecresc)
			If nValRec < nAcresc .and. nValRec <> 0
				nAcresc		:= nValRec
			Endif
		Else
			nValPadrao := nValRec-(nJuros + nVA+Iif(SE1->E1_MOEDA<=1,nCM,0)+nMulta-nDescont+nAcresc-nDecresc) 
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se saldo estava em outra moeda, caso estiver, converte valor ³
		//³recebido pela taxa diaria da moeda                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nOpt  := IIF(Str(nValPadrao,14,2)=Str(xMoeda(SE1->E1_SALDO-nTotAbat,SE1->E1_MOEDA,nMoedaBco,dBaixa,,nTxMoeda),14,2),1,2)
	Else
		lRet := .F.
		MsUnlock()
		//Se os valores dos impostos de abatimentos foram recalculados e se a baixa
		//do titulo nao for confirmada, restauro os valores calculados pelo sistema
		If lAlterImp

			//Guardo os valores "nOld" para retornar apos calculos
			nAntPis   	:= nOldPis
			nAntCofins	:= nOldCofins   
			nAntCsll  	:= nOldCsll
			nAntIrrf  	:= nOldIrrf
			nAntIss	   := nOldIss
			nAntInss  	:= nOldInss

			nPisAlter := SE1->E1_PIS
			nCofAlter := SE1->E1_COFINS
			nCslAlter := SE1->E1_CSLL
			nIrfAlter := SE1->E1_IRRF
			nIssAlter := SE1->E1_ISS
			nInsAlter := SE1->E1_INSS

			//Altero os valores somente para a funcao considerar o calculo
			//pois os valores de SE1-> e nOld precisam ser diferentes
			RecLock("SE1")
			If !lPccBxCr
				SE1->E1_PIS    := nOldPis
				SE1->E1_COFINS := nOldCofins
				SE1->E1_CSLL   := nOldCsll
			EndIf
			If !lIrPjBxCr
				SE1->E1_IRRF   := nOldIrrf
			EndIf
			SE1->E1_ISS	 := nOldIss
			SE1->E1_INSS   := nOldInss
			SE1->(MsUnlock())

			nOldPis    := nPisAlter
			nOldCofins := nCofAlter
			nOldCsll   := nCslAlter
			nOldIrrf	 := nIrfAlter
			nOldIss	 := nIssAlter
			nOldInss	 := nInsAlter

			//Faz a alteração dos valores
			FA040AxAlt(cAlias,lAlterImp)

			//Restauro os valores para nao gerar problemas em novos calculos
			nOldPis    := nAntPis
			nOldCofins := nAntCofins
			nOldCsll   := nAntCsll
			nOldIrrf		:= nAntIrrf
			nOldIss		:= nAntIss
			nOldInss		:= nAntInss

			//Se o valor total for menor que o valor minimo de retenção
			If  !lPccBxCr .and. (aDadosRet[1] + nValRec) <= nVlMinImp
				RecLock("SE1")
				SE1->E1_SABTPIS	+= If(SE1->E1_SABTPIS >= 0 ,nOldPis,0)
				SE1->E1_SABTCOF	+= If(SE1->E1_SABTCOF >= 0 ,nOldCofins,0)
				SE1->E1_SABTCSL	+= If(SE1->E1_SABTCSL >= 0 ,nOldCsll,0)
				SE1->E1_PIS			:= SE1->E1_SABTPIS
				SE1->E1_COFINS		:= SE1->E1_SABTCOF
				SE1->E1_CSLL		:= SE1->E1_SABTCSL
				SE1->(MsUnlock())
			Endif
		EndIf
		Exit
	Endif
	
	If Empty( cMotBx )
		cMotBx := aDescMotBx[nFirstRsn] // Default posting reason
	Endif
	
	IF nOpc1 == 1

		 If lFA070ACR
		 	nAux := ExecBlock("FA070ACR",.F.,.F.,{nDecrVlr})
		 	If Valtype(nAux) == "N"
            	nDecresc := nAux
    		EndIf
     	 Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se data da baixa e valida                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF (dBaixa < SE1->E1_EMISSAO .OR. dBaixa > dDataBase) .and. !lAntCred
			Help( " ", 1, "DATAERR" )
			// Se nao for baixa por rotina automatica, volta para o usuario corrigir os
			// dados, senao abandona a baixa.
			If !lF070Auto
				loop
			Else
				lRet := .F.
				Exit
			Endif
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se modalidade do SPB é valida.									    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lSpbInUse
			cModSpb := Substr(cModSpb,1,1)
			IF !(SpbTipo("SE1",cModSpb,SE1->E1_TIPO))
				// Se nao for baixa por rotina automatica, volta para o usuario corrigir os
				// dados, senao abandona a baixa.
				If !lF070Auto
					loop
				Else
					lRet := .F.
					Exit
				Endif
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se permite ou nao baixar o titulo com o valor recebido menor ³
		//³que a soma dos valores de juros, multa e desconto                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !F070VldRec()
			If !lF070Auto
				loop
			Else
				lRet := .F.
				Exit
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de Entrada de Template para Confirmacao da Baixa       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTFa070Tit
			lRet := ExecTemplate("FA070TIT",.F.,.F.,{nParciais})
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de Entrada para Confirmacao da Baixa                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFa070Tit
			lRet := ExecBlock("FA070TIT",.F.,.F.,{nParciais})
			If !lRet
				// Se nao for baixa por rotina automatica, volta para o usuario corrigir os dados, senao abandona a baixa.
				If !lF070Auto
					loop
				Else
					Exit
				Endif
			Endif
		Endif

		If !lRet
			Return lRet
		EndIf

		dbSelectArea("SE1")
		IF Empty(dBaixa) .or. (nValRec < 0 ) .or. Empty(cMotBx)
			Help(" ",1,"FA070INV")
			// Se nao for baixa por rotina automatica, volta para o usuario corrigir os
			// dados, senao abandona a baixa.
			If !lF070Auto
				loop
			Else
				lRet := .F.
				Exit
			Endif
		EndIF

		// Aqui neste ponto a variavel nJuros esta somada com o valor de nCM1
		// e da Prorata se esta for positiva, se for negativa
		// a prorata eh somada a nDescont

        IF nModulo == 43 //TMS
			If nDescont != Round(nMulta+nJuros + nVA+xMoeda((SE1->E1_SALDO+SE1->E1_ACRESC-SE1->E1_DECRESC),SE1->E1_MOEDA,1,dBaixa,2,nTxMoeda),2)
				If (nTotAbat=0.and.nValRec=0.and.nDescont==0).or.;
					(nValRec=0.and.nTotAbat!=SE1->E1_SALDO .and.;
					 nDescont!=Round(nMulta+nJuros + nVA+xMoeda(SE1->E1_SALDO-nTotAbat,SE1->E1_MOEDA,1,dBaixa,3,nTxMoeda),2)+nAcresc-nDecresc)
					Help(" ",1,"FA070INV")
					// Se nao for baixa por rotina automatica, volta para o usuario corrigir os
					// dados, senao abandona a baixa.
					If !lF070Auto
						loop
					Else
						lRet := .F.
						Exit
					Endif
				EndIf
			EndIF
	    Else
			If nDescont != Round(nMulta+nJuros + nVA+xMoeda((SE1->E1_SALDO+SE1->E1_ACRESC-(SE1->E1_DECRESC+nDecrescF+nDecrVlr)),SE1->E1_MOEDA,1,dBaixa,2,nTxMoeda),2) .And.;
				(!(AllTrim(SE1->E1_ORIGEM) $ "S|L|T") .And. AllTrim(cAuxMBx) <> "BOL")
				If (nTotAbat=0.and.nValRec=0.and.nDescont==0).and.;
					(nValRec=0.and.nTotAbat!=SE1->E1_SALDO .and.nPIS==0.and.nCOFINS==0.and.nCSLL==0.and.;
					nDescont!=Round(nMulta+nJuros + nVA+xMoeda(SE1->E1_SALDO-nTotAbat,SE1->E1_MOEDA,1,dBaixa,3,nTxMoeda),2)+nAcresc-nDecresc)
					Help(" ",1,"FA070INV")
					// Se nao for baixa por rotina automatica, volta para o usuario corrigir os
					// dados, senao abandona a baixa.
					If !lF070Auto
						loop
					Else
						lRet := .F.
						Exit
					Endif
				Else
					If (nValRec=0.and.nDescont==0).and.;
					(nValRec=0.and.nTotAbat!=SE1->E1_SALDO .and.nPIS==0.and.nCOFINS==0.and.nCSLL==0.and.;
					nDescont!=Round(nMulta+nJuros + nVA+xMoeda(SE1->E1_SALDO-nTotAbat,SE1->E1_MOEDA,1,dBaixa,3,nTxMoeda),2)+nAcresc-nDecresc)
						If MsgYESNO( STR0247 + chr(10) + chr(13) + ;
							STR0248, STR0035 )
							loop
						Else
							lRet := .F.
							Exit
						Endif
					EndIf
				EndIf
			EndIF
	    EndIf

		If !FA070ValMo()
			// Se nao for baixa por rotina automatica, volta para o usuario corrigir os
			// dados, senao abandona a baixa.
			If !lF070Auto
				loop
			Else
				lRet := .F.
				Exit
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Soma nos totalizadores, exceto se a situa‡„o do t¡tulo for:     ³
		//³2 - Cobran‡a Descontada   ou   7 - Cobranca Cau‡„o Descontada   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF !(FN022SITCB(SE1->E1_SITUACA)[3])
			nTotAGer  += nValRec
			nTotADesc += nDescont+nDecresc
			nTotAMul  += nMulta
			nTotAJur  += nJuros + nVA + nAcresc
			nTotADesp += Iif(SE1->E1_MOEDA<=1,nCM,0)
		Endif
		// verifica se nao esta utilizando rotina automatica para poder gerar os lanctos contabeis
		cPadrao   := fA070Pad()
		lPadrao   := VerPadrao(cPadrao)

	  	IF !lF070Auto
			// Verifica se esta utilizando multiplas naturezas
			// E chama a rotina para distribuir o valor entre as naturezas
			If MV_MULNATR .and. lMultNat
				MultNatB("SE1",.F.,STR(mv_par07,1),@lOk,@aColsSEV,@lMultNat)
			Endif
		ElseIf __lRatAut
			If MV_MULNATR
				lMultNat := .T.
				MultNatB("SE1",.F.,'1',@lOk,@aColsSEV,@lMultNat,.T.)
			Endif
		Endif
		
		If lF070Auto .And. MV_MULNATR .And. len(aRatAut) > 0
			If !MultNatB("SE1",.F.,'1',@lOk,@aColsSEV,@lMultNat,.T.,aRatAut)
				lRet := .F.
				//Se existir temporario para rateio c. custo deleta
				If Select("SEZTMP") > 0
					FINXDETMP()
				Endif
				Exit	
			EndIf
		EndIf

       	If nModulo == 12  // SIGALOJA Não atualiza saldo do cliente padrão
			If AllTrim(SE1->E1_CLIENTE) + AllTrim(SE1->E1_LOJA) == AllTrim(SuperGetMv("MV_CLIPAD",,"")) + AllTrim(SuperGetMv("MV_LOJAPAD",,""))
				lBloqSa1 := .F.
			EndIf
		EndIf

       	If __lTravaSa1
			lBloqSa1 := ExecBlock("F070TRAVA",.f.,.f.)
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa a gravacao dos lancamentos do SIGAPCO          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PcoIniLan("000004")

		If  lOracle .and. Iif(mv_par01==1,.T.,.F.) .and. Iif(MV_PAR04==1,.T.,.F.)
			Private aAltera		:= {}
			Private aHeader		:= {}
			CtbCrTmpBD()
		EndIF

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicio da prote‡„o via TTS                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Begin Transaction
			If lRMClass .And. SE1->E1_IDLAN != 0
				If FWHasEAI("FINI070A",.T.,,.T.)
					SetRotInteg('FINI070A')
					aRetMsg := FinI070A()
					If ValType(aRetMSg[1]) <> "U" .And. !aRetMsg[1]
						If ValType(aRetMsg[2]) <> "U" .And. aRetMsg[2] <> Nil .and. !Empty(aRetMsg[2])
							MsgAlert(STR0237 + CRLF + aRetMsg[2])//"Foi realizada uma tentativa de atualização do título, e foi retornada a seguinte mensagem:"
						Else
							MsgAlert(STR0238 + " " + Rtrim(SE1->E1_NUM)+". "+STR0239)//"Ocorreu um erro inesperado na tentativa de atualização do título " "Verifique as configurações da integração  e tente novamente."
						EndIf
					ElseIf Valtype(aRetMSg[1]) == "U"
						MsgAlert(STR0238 + " " + Rtrim(SE1->E1_NUM) + ". " + STR0239)//"Ocorreu um erro inesperado na tentativa de atualização do título " "Verifique as configurações da integração  e tente novamente."
					Endif
					SetRotInteg('FINA070')
				Else
					MsgAlert(STR0240)//"Para realizar as baixas de integrações como TIN, é necessário cadastrar o adapter da rotina FINI070A - UPDATECONTRACTPARCEL."
				EndIf
			EndIf

			lJuros  := IIF( mv_par05 == 1, .T., .F. )

			Aadd(aHdlPrv,{nHdlPrv,cPadrao,aFlagCTB,cArquivo})

			If lF070Auto .And. len(aAutoCab) > 0
				nPos := aScan(aAutoCab,{|x| x[1] == 'AUTVALREC'})
				If nPos > 0
					nValrec := aAutoCab[nPos,2]
				EndIf
			EndIf
			iF FwIsInCallStack("FA450CMP")
				nValRec := nValOld
			Endif
			lSaveState := ALTERA

			//Métricas - MV_TIPOCM
			IF __lMetric .and. SE1->E1_MOEDA != nMoedaBco .AND. nCm > 0 .and. ;
					(nJuros + nVA + nMulta + nDescont + nAcresc + nDecresc) != 0
				SetFunName(__cFunMet)
				// Metrica do tempo das validações execauto
				FwCustomMetrics():setUniqueMetric("MV_TIPOCM ("+ cTipoCm + ")", "financeiro-protheus_qtd-por-conteudo_total", cTipoCm)
				SetFunName(__cFunBkp)
			Endif

			//-----------------------------------------------------------
			//Valores Acessorios.
			//-----------------------------------------------------------
			//Se for execauto, primeiro chama as funções de baixa e somente depois chama a função FAtuFKDBx, para atualização da data de baixa do VA na FKD, evitando gravação duplicada de FK6 quando informadas 2 baixas parciais via integração com VA de aplicação única
			If lF070Auto
				nInicio := Seconds()
				lBaixou := fA070Grv(lPadrao, Nil, Nil, Nil, lFINA200, dDtCredito, lJuros, Nil, Nil, nTxMoeda, mv_par08==1,;
				aSeqSe5, aHdlPrv, lBloqSa1, lMultNat, Nil, aImpos, __lPccMR, __lIrfMR, __lInsMR, __lIssMR, __lGlosaMr,;
				__lImpMR, aTitCalc, lPix, cSituaCob, @__nBxaPrin)
				
				If lBaixou
					nFim := Seconds() - nInicio
					
					IF __lMetric
						SetFunName(__cFunMet)
						// Metrica do tempo das validações execauto
  						FwCustomMetrics():setAverageMetric("TempoGravação", "financeiro-protheus_tempo-conclusão-processo_seconds", nFim)
						SetFunName(__cFunBkp)
					Endif
				Endif

				If lPodeTVA .and. lExistVA
					FAtuFKDBx()
				Endif
			Else
				If lPodeTVA .and. lExistVA
					FAtuFKDBx()
				Endif
				
				lBaixou := fA070Grv(lPadrao, Nil, Nil, Nil, lFINA200, dDtCredito, lJuros, Nil, Nil, nTxMoeda, mv_par08==1,;
				aSeqSe5, aHdlPrv, lBloqSa1, lMultNat, Nil, aImpos, __lPccMR, __lIrfMR, __lInsMR, __lIssMR, __lGlosaMr,;
				__lImpMR, aTitCalc, Nil, cSituaCob, @__nBxaPrin)
			Endif

			If lFINA200
				lBAIXCNAB := lBaixou
			EndIf
			ALTERA := lSaveState
			nHdlPrv	:= aHdlPrv[1][1]

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			F070PcoDet()

			// Se nao for baixa por rotina automatica, chama a rotina de contabilizacao
		  	//-----
		  	//Caso o o executo esteja com a opção de ratear a baixa poderá ser rateada com a replica do rateio da inclusão
		  	IF !lF070Auto
				// Verifica se esta utilizando multiplas naturezas
				If MV_MULNATR .and. lMultNat .and. lOk .And. ( AllTrim(SE1->E1_TIPO) <> "RA" )
					MultNatC("SE1",@nHdlPrv,@nTotal,@cArquivo,lContabiliza,.F.,STR(mv_par07,1),,lOk,aColsSEV,lBaixou,aGrvLctPco)
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de entrada antes da contabilizacao.			  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lF070ACONT
					ExecBlock("F070ACONT",.F.,.F.)
				EndIf

				If lBaixou
		  			GravaChqCR(SE5->E5_SEQ,"FINA070",,aSeqSe5,lBaixou,aFormPg) // Grava os cheques no SEF

					//Monta o Array para impressao do Recibo
		  			aAdd(aRelTit, {	SE1->E1_NUM				,;	//01-Nro do Titulo
							       	SE1->E1_PREFIXO			,;	//02-Prefixo
							       	SE1->E1_PARCELA			,;	//03-Parcela
							       	SE1->E1_TIPO 			,;	//04-Tipo
							       	SE1->E1_CLIENTE			,;	//05-Cliente
							       	SE1->E1_LOJA			,;	//06-Loja
							       	Dtos(SE1->E1_EMISSAO)	,;	//07-Emissao
							       	Dtos(SE1->E1_VENCTO)	,;	//08-Vencimento
							       	SE1->E1_VLCRUZ			,;	//09-Valor Original
							       	SE1->E1_SALDO			,;	//10-Saldo
							       	SE1->E1_MULTA			,;	//11-Multa
							       	SE1->E1_JUROS			,;	//12-Juros
							       	SE1->E1_DESCONT			,;	//13-Desconto
							       	SE1->E1_VALLIQ			})	//14-Valor Recebido
		  		Endif
		  	ElseIf __lRatAut .Or. len(aColsSEV) > 0 .And. cSituaCob == "0"
					// Verifica se esta utilizando multiplas naturezas
				If MV_MULNATR .and. lOk .And. ( AllTrim(SE1->E1_TIPO) <> "RA" )
					lMultNat := .T.
					MultNatC("SE1",@nHdlPrv,@nTotal,@cArquivo,lContabiliza,.F.,'1',,lOk,aColsSEV,lBaixou,aGrvLctPco)
				Endif
			Endif

					/*
			Atualiza o status do titulo no SERASA */
			If cPaisLoc == "BRA"
				If SE1->E1_SALDO <= 0
					cChaveTit := xFilial("SE1") + "|" +;
								SE1->E1_PREFIXO + "|" +;
								SE1->E1_NUM		+ "|" +;
								SE1->E1_PARCELA + "|" +;
								SE1->E1_TIPO	+ "|" +;
								SE1->E1_CLIENTE + "|" +;
								SE1->E1_LOJA
					cChaveFK7 := FINGRVFK7("SE1",cChaveTit)
					F770BxRen("1",TrazCodMot(cMotBx),cChaveFK7)
					dbSelectArea("SE1")
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza a gravacao dos lancamentos do SIGAPCO ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PcoFinLan("000004")

			If ChqMotBx( cMotBx ) // Verifica se Motivo de baixa gera cheque
				If mv_par08 == 1  // Verifica se o Parâmetro "Gera Cheque para Adiantamento" = Sim
					lGerChqAdt := .T.
				Else
					lGerChqAdt := .F.
				EndIf
			Else
				lGerChqAdt := .F.
			EndIf

			cTipoOr		:= SE1->E1_TIPO

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caso seja baixa de adiantamento, dever  ser estornado saldo  ³
			//³ banc rio. Apenas Baixa que gere movimentacao bancaria		  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cSituaCob == "0"
				If SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG
					If (MovBcoBx(cMotBx, .T.) .And. !lGerChqAdt) .Or. cAuxMBx == "TRF"
						AtuSalBco( cBanco, cAgencia, cConta, dBaixa, nValRec, "-" )
					Endif

					fa070Adiant( lPadrao, lContabiliza, IIF(cMotBx == "CEC", .T.,lGerChqAdt), @aBaixas, dDtCredito , nTxMoeda, lMultNat )

					// Verifica se esta utilizando multiplas naturezas e grava o flag de rateio no SE1
					If MV_MULNATR .and. lMultNat
						MultNatC("SE1",@nHdlPrv,@nTotal,@cArquivo,lContabiliza,.F.,STR(mv_par07,1),,lOk,aColsSEV,lBaixou,aGrvLctPco)
						If !Empty(SE5->E5_SEQ) .And. SE1->E1_MULTNAT <> "1"
							RecLock("SE1",.F.)
							SE1->E1_MULTNAT := "1"
							SE1->(MsUnlock())
						Endif
					Endif

					If cPaisLoc == "COL"
						If FindFunction("FinProcITF") .And. FinProcITF( SE5->( Recno() ),1 ) .and. cTipoOr=='RA '
							FinProcITF( SE5->( Recno() ), 3, , .F.,, )
						EndIf
					EndIf
				EndIf

				If lPadrao .and. lContabiliza .and. lBaixou
					If nHdlPrv <= 0
						nHdlPrv		:= HeadProva(cLote,"FINA070",Substr(cUsuario,7,6),@cArquivo)
					EndIf

					VALOR			:= SE1->E1_VALLIQ
					ABATIMENTO	:= Round(NoRound(xMoeda(nTotAbat,SE1->E1_MOEDA,nMoedaBco,dBaixa,3,nTxMoeda),3),2)

					If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
						aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
						aAdd( aFlagCTB, {"FK1_LA", "S", "FK1", FK1->( Recno() ), 0, 0, 0} )
						If !(SE5->E5_TIPODOC $ "BA|V2")
							aAdd( aFlagCTB, {"FK5_LA", "S", "FK5", FK5->( Recno() ), 0, 0, 0} )
						EndIf
					EndIf
					nTotal += DetProva( nHdlPrv, cPadrao, "FINA070", cLote, /*nLinha*/, /*lExecuta*/,;
										/*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/,;
										/*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ )

					If lF070CTB
						nTotal += ExecBlock("F070CTB",.F.,.F.,{cPadrao,nHdlPrv})
					EndIf
				EndIf
				
				IF lPadrao .and. lContabiliza .and. lBaixou
					//-- Se for rotina automatica força exibir mensagens na tela, pois mesmo quando não exibe os lançametnos, a tela
					//-- sera exibida caso ocorram erros nos lançamentos padronizados
					If lF070Auto
						lSetAuto := _SetAutoMode(.F.)
						lSetHelp := HelpInDark(.F.)
						If Type('lMSHelpAuto') == 'L'
							lMSHelpAuto := !lMSHelpAuto
						EndIf
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Localizacao Portugal - Gera dados para diario contabil ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If UsaSeqCor()
						AAdd( aDiario, {"SE5",SE5->(Recno()),cCodDiario,"E5_NODIA","E5_DIACTB"} )
					Else
						aDiario := {}
					EndIf

					//	Define data da contabilização on line
					Do Case 
						Case nDtContOn == 1 // 1- Data Digitação
							dDtLanc := dDataBase
						Case nDtContOn == 2 // 2- Data Disponibilizadade
							dDtLanc := dDtCredito
						Case nDtContOn == 3 // 3- Data Recebimento
							dDtLanc := dBaixa
					EndCase

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Envia para Lan‡amento Cont bil                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cA100Incl( cArquivo, nHdlPrv, 3 /*nOpcx*/, cLote, Iif(mv_par01==1,.T.,.F.) /*lDigita*/,;
								Iif(mv_par02==1,.T.,.F.) /*lAglut*/,;
								/*cOnLine*/, dDtLanc, /*dReproc*/, @aFlagCTB, /*aDadosProva*/, aDiario )
					aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento

					If lF070Auto
						HelpInDark(lSetHelp)
						_SetAutoMode(lSetAuto)
						If Type('lMSHelpAuto') == 'L'
							lMSHelpAuto := !lMSHelpAuto
						EndIf
					EndIf
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Trecho incluido para integração e-commerce          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lBaixou
				If  LJ861EC01(SE1->E1_NUM, SE1->E1_PREFIXO, .T./*PrecisaTerPedido*/, SE1->E1_FILORIG)
					LJ861EC02(SE1->E1_NUM, SE1->E1_PREFIXO, SE1->E1_FILORIG)
				EndIf
			EndIf

			// Integração SIGAPFS x SIGAFIN
			If lBaixou .And. FindFunction("JGrvBaixa")
				lRet := JGrvBaixa(SE1->(Recno()), SE5->(Recno()))

				If !lRet
					DisarmTransaction()
					Return .F.
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Final  da prote‡„o via TTS                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lFini055 .and. FWHasEAI("FINA070",.T.,,.T.) .and. SE1->E1_PREFIXO <> cPrefRM
				cIntegSeq := SE5->E5_SEQ//utilizada na integdef. Nao transformar em local.
				aRetInteg := FwIntegDef( 'FINA070' )
				//Se der erro no envio da integração, então faz rollback e apresenta mensagem em tela para o usuário
				If ValType(aRetInteg) == "A" .AND. Len(aRetInteg) >= 2 .AND. !aRetInteg[1]
					If ! IsBlind()
						Help( ,, "FINA070INTEG",, STR0238 + ": " + STR0006 + " - " + AllTrim(DecodeUTF8(aRetInteg[2])), 1, 0,,,,,, {STR0239} ) //"Ocorreu um erro inesperado na tentativa de atualização do título: Baixa de Títulos ", "Verifique se a integração está configurada corretamente."
					Endif
					DisarmTransaction()
					Return .F.
				Endif
			Endif

			If !("FINA630" $ FunName())
				///numbor
				aAlt := {}
			    aadd( aAlt,{ STR0259,'','','',STR0260 +  Alltrim(Transform(SE5->E5_VALOR,PesqPict("SE5","E5_VALOR"))) })
				///chamada da Função que cria o Histórico de Cobrança
				DbSelectArea("SE1")
				FinaCONC(aAlt)
			endif

		End Transaction

		If !lF070Auto .And. AllTrim(SE1->E1_ORIGEM)=="FINI055"
			If FWHasEAI("FINI070A",.T.,,.T.)
				SetRotInteg('FINI070A')
				MsgRun ( STR0234+" "+rTrim(SE1->E1_NUM)+ " " +STR0235,STR0236,{||aRetMsg:=FinI070A()} )//"Atualizando título" "a valor presente..." Valor Presente
				If ValType(aRetMSg[1]) <> "U" .And. !aRetMsg[1]
					If ValType(aRetMsg[2]) <> "U" .And. aRetMsg[2] <> Nil .and. !Empty(aRetMsg[2])
						MsgAlert(STR0237 + CRLF + aRetMsg[2])//"Foi realizada uma tentativa de atualização do título, e foi retornada a seguinte mensagem:"
					Else
						MsgAlert(STR0238 + " " + Rtrim(SE1->E1_NUM)+". "+STR0239)//"Ocorreu um erro inesperado na tentativa de atualização do título " "Verifique as configurações da integração  e tente novamente."
					EndIf
				ElseIf Valtype(aRetMSg[1]) == "U"
					MsgAlert(STR0238 + " " + Rtrim(SE1->E1_NUM) + ". " + STR0239)//"Ocorreu um erro inesperado na tentativa de atualização do título " "Verifique as configurações da integração  e tente novamente."
				Endif
				SetRotInteg('FINA070')
			Else
				MsgAlert(STR0240)//"Para realizar as baixas de integrações como TIN, é necessário cadastrar o adapter da rotina FINI070A - UPDATECONTRACTPARCEL."
			EndIf
		Endif

		If cSituaCob == "0" .And. !(FN022SITCB(SE1->E1_SITUACA)[3]) ; // Carteiras descontadas 
			.And. MovBcoBx(cMotBx, .T.) .and. !(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG) .and. Empty( cLoteFin )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravar Saldo Banc rio 											        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc<>"BRA"
				AtuSalBco(cBanco,cAgencia,cConta,dDtCredito,nValRec-nSomaCheq,"+")
			Else
				AtuSalBco(cBanco,cAgencia,cConta,dDtCredito,Iif( lPccBxCr .And. nValRec - ( nPis + nCofins + nCsll ) == nOldValRec , nOldValRec , nValRec ) - nSomaCheq , "+" )
			Endif
		EndIf

		//Ponto de entrada do Template.
		If ExistTemplate("SACI008")
			ExecTemplate("SACI008",.F.,.F.)
		EndIf

		If lSACI008
			ExecBlock("SACI008",.F.,.F.)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Integracao protheus X tin	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	EndIf

	If lF070Bxpc .And. ( SE1->E1_SALDO > 0 )
	   	ExecBlock( "F070BXPC", .F., .F. )
	Else
		Exit
	EndIf
End

If SubStr(SE1->E1_ORIGEM,1,3)  == 'GTP' .AND. FindFunction("GTPBXTIT")
	GTPBXTIT()
EndIf

If "CX" $ cBanco
	aCaixaFin[1] := cBanco
	aCaixaFin[2] := cAgencia
	aCaixaFin[3] := cConta
EndIf

If cAlias != NIL
	dbSelectArea(cAlias)
	dbSetOrder(nOrdem)
	dbGoTo( nReg )
EndIf

RestArea (aArea)

If nOpc1 == 0
	aCols := aSize(aCols, 0)
EndIf

If FunName() == "FINA740"
	cPorta740 := cPortado
	cBanco740 := cBanco
	cAgenc740 := cAgencia
	cConta740 := cConta
Endif

If ValType( aVlOringl ) == "A"
	aSize( aVlOringl , 0 )
	aVlOringl := Nil
EndIf

//Faz a impressao do Recibo
If lImpLjRe .And. lBaixou .And. (lLojrRec .Or. lULOJRREC)
	aAreaSe1 := SE1->(GetArea())
	aAreaSe5 := SE5->(GetArea())
	aAreaRec := GetArea()

	//Passo os parametros do SE5 para futura reimpressão do recibo deverá pegar as informações do E5, pois a baixa pode ser
	//parcial, o numero do recibo será Numero+Cliente+Loja+E5_SEQ. Desenvolver a reimpressão usando estas informações na query
	If lULOJRREC
		//Fonte não será mais padrao mas sim um RDMake padrão.
		U_LOJRRecibo(	""				, ""				, aRelTit			, aFormPg				,;
						Nil				, SE5->E5_HISTOR	, SE5->E5_SEQ		, DTOC(SE5->E5_DATA)	,;
						SE5->E5_TIPODOC	, SE5->E5_MOTBX		, SE5->E5_NUMERO	, SE5->E5_PARCELA		,;
						SE5->E5_CLIFOR	, SE5->E5_LOJA 		)
	Else
		LOJRREC(	""				, ""				, aRelTit			, aFormPg				,;
					Nil				, SE5->E5_HISTOR	, SE5->E5_SEQ		, DTOC(SE5->E5_DATA)	,;
					SE5->E5_TIPODOC	, SE5->E5_MOTBX		, SE5->E5_NUMERO	, SE5->E5_PARCELA		,;
					SE5->E5_CLIFOR	, SE5->E5_LOJA 		)
	EndIf
	RestArea(aAreaSe1)
	RestArea(aAreaSe5)
	RestArea(aAreaRec)
Endif

If lIsRussia .And. !IsBlind() .And. nOpc1 == 1
	Aviso(STR0300, STR0301)
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fA070Lot ³ Autor ³ Wagner Xavier         ³ Data ³ 03/08/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Seleciona titulos a serem baixados                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fA070Lot()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function xFa070Lot( cAlias,nReg,nOpcx )
LOCAL oDlg
LOCAL oCredConta

LOCAL lGrava		:= .F.
LOCAL nOrdem
LOCAL oLoteFin
Local lPreMark 		:= .T.
Local lF070Mark 	:= ExistBlock("F070MARK")
Local oBancolt
Local oAgencialt
Local oContalt
Local lFa070Bco		:= ExistBlock("FA070BCO")
Local cChaveLbn		:= ""
Local cChaveLbnOld 	:= ""
Local oPanel
Local nOrder		:= 1
Local nA			:= 0
Local cMoedaTx		:= ""
Local lEECFIN 		:= SuperGetMv("MV_AVG0131",.F.,.F.) //DFS - 17/02/11 - Parâmetro para verificar integração com financeiro.
Local lBxDtFin 		:= SuperGetMv("MV_BXDTFIN",,"1") == "2"
Local cAuxMoeda     := ""
Local lJFilBco      := ExistFunc("JurVldSA6") .And. SuperGetMv("MV_JFILBCO", .F., .F.) //Indica se filtra as contas correntes vinculadas ao escritório logado - SIGAPFS
Local cEscrit       := IIF(lJFilBco, JurGetDados("NS7", 4, xFilial("NS7") + cFilant + cEmpAnt, "NS7_COD"), "")
Local cF3Bco        := IIF(lJFilBco, "SA6JUR", "SA6")

//294 - Natureza sintetica/Analitica
Local lNatSA := FNatSAIsOn()

PRIVATE dVencDe   := Ctod(Space(8))
PRIVATE cNatDe    := CriaVar("E1_NATUREZ")
PRIVATE dVencAte  := Ctod(Space(8))
PRIVATE cNatAte   := CriaVar("E1_NATUREZ")
PRIVATE cBancoLt  := CriaVar("E1_PORTADO")
PRIVATE cAgenciaLt:= CriaVar("E1_AGEDEP")
PRIVATE cContaLt  := CriaVar("E1_CONTA")
PRIVATE nNroTit   := 0
PRIVATE nTotDesp  := 0
PRIVATE nTotJur   := 0
PRIVATE nTotVA	  := 0
PRIVATE nTotMul   := 0
PRIVATE nCredConta:= 0
PRIVATE nTotDesc  := 0
PRIVATE nTotGer   := 0
PRIVATE nValor    := 0
PRIVATE cLoteFin  := Space(TamSX3("E1_LOTE")[1])
PRIVATE cNaturLote:= Space(10)
PRIVATE nTotAGer  := 0
PRIVATE nTotADesp := 0
PRIVATE nTotADesc := 0
PRIVATE nTotAMul  := 0
PRIVATE nTotAJur  := 0
PRIVATE nQtdTit   := 0
PRIVATE nOtrga    := 0
PRIVATE nDifCambio:= 0
PRIVATE aTxMoedas := {}
Private nMoedaBco := 1
Private lTitLote  := .T.

__cFunBkp   := FunName()
__cFunMet	:= Iif(AllTrim(__cFunBkp)=='RPC',"RPCFINA070",__cFunBkp)

If __lMetric
	SetFunName(__cFunMet)
	// Metrica de controle de acessos 
    FwCustomMetrics():setSumMetric(Alltrim(ProcName()), "financeiro-protheus_qtd-por-acesso_total", 1)
	SetFunName(__cFunBkp)
Endif

If cPaisLoc <> "BRA"
	aAdd(aTxMoedas,{"",1,PesqPict("SM2","M2_MOEDA1")})
	For nA := 2 To MoedFin()
		cMoedaTx := Str(nA,IIf(nA <= 9,1,2))
		cAuxMoeda := GetMv( "MV_MOEDA" + cMoedaTx )
		If ! Empty( cAuxMoeda )
			If lF070Auto .And. nA == SE1->E1_MOEDA
				aAdd( aTxMoedas, { cAuxMoeda, SE1->E1_TXMOEDA, PesqPict("SM2","M2_MOEDA" + cMoedaTx) } )
			Else
				aAdd( aTxMoedas, { cAuxMoeda, RecMoeda(dDataBase, nA), PesqPict("SM2","M2_MOEDA" + cMoedaTx) } )
			Endif
		Else
			Exit
		Endif
	Next
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso tenha seja um titulo gerado pelo SIGAEIC ou SIGAEEC não poderá sofrer baixa através desta rotina ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetMV("MV_EASYFIN") == "S" .And. UPPER(Alltrim(SE1->E1_ORIGEM)) == "SIGAEIC"
	HELP(" ",1,"FAORIEIC")
	Return
Endif

// TDF - 26/12/11 - Acrescentado o módulo EFF para permitir liquidação
If lEECFIN .And. UPPER(Alltrim(SE1->E1_ORIGEM)) == "SIGAEEC" .and. !(cModulo $ "EEC/EDC/ECO/EFF") //DFS - 17/02/11 - Trava para outros módulos para títulos gerados no EEC
   HELP(" ",1,"FAORIEEC")
   Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso titulos originados pelo SIGALOJA estejam nas carteiras :  ³
//³I = Carteira Caixa Loja                                        ³
//³J = Carteira Caixa Geral                                       ³
//³Nao permitir esta operacao, pois ele precisa ser transferido   ³
//³antes pelas rotinas do SIGALOJA.                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Upper(AllTrim(SE1->E1_SITUACA)) $ "I|J" .AND. !IsMoney(SE1->E1_TIPO) .AND. Upper(AllTrim(SE1->E1_ORIGEM)) $ "LOJA010|LOJA701|FATA701"
	Help(" ",1,"NOUSACLJ")
	Return
Endif
While .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Zera Acumuladores                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nNroTit   := 0
	nTotDesp  := 0
	nTotJur   := 0
	nTotVA	  := 0
	nTotMul   := 0
	nCredConta:= 0
	nTotDesc  := 0
	nTotGer   := 0
	nValor    := 0
	nTotAGer  := 0
	nTotADesp := 0
	nTotADesc := 0
	nTotAMul  := 0
	nTotAJur  := 0
	nQtdTit   := 0
	cMarca    := Get070Mark()

	If lF070Mark
		lPreMark := ExecBlock("F070MARK",.F.,.F.)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Salva ordem atual                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea ( cAlias )
	nOrdem:=IndexOrd()
	nSalvRec:=Recno()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desenha tela padr„o do browse                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpc1    := 0
	nValor   := 0
	nQtdTit  := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se data do movimento ‚ menor que data limite de     ³
	//³ movimentacao no financeiro                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lBxDtFin .and. !DtMovFin(,,"2")
		Return
	Endif

	UltiLote()

	If IsPanelFin()  //Chamado pelo Painel Financeiro
		dbSelectArea(cAlias)
		oPanelDados := FinWindow:GetVisPanel()
		oPanelDados:FreeChildren()
		aDim := DLGinPANEL(oPanelDados)
		DEFINE MSDIALOG oDlg OF oPanelDados:oWnd FROM 0,0 To 0,0 PIXEL STYLE nOR( WS_VISIBLE, WS_POPUP )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Observacao Importante quanto as coordenadas calculadas abaixo: ³
		//³ -------------------------------------------------------------- ³
		//³ a funcao DlgWidthPanel() retorna o dobro do valor da area do	 ³
		//³ painel, sendo assim este deve ser dividido por 2 antes da sub- ³
		//³ tracao e redivisao por 2 para a centralizacao. 					 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nEspLarg := (((DlgWidthPanel(oPanelDados)/2) - 266) /2) -5
		nEspLin  := 0

	Else

		DEFINE MSDIALOG oDlg FROM	102,5 TO 305,555 TITLE OemToAnsi(STR0058)	PIXEL //"Baixa a Pagar em Lote"
		nEspLarg := 0
		nEspLin  := 0

	Endif

	@ 02+nEspLin, 004+nEspLarg TO 98+nEspLin, 77+nEspLarg  LABEL OemToAnsi(STR0044) 	 		PIXEL OF oPanel   //"Dados Banc rios"
	@ 02+nEspLin, 079+nEspLarg TO 98+nEspLin, 180+nEspLarg LABEL OemToAnsi(STR0045) 			PIXEL OF oPanel //"Valores"
	@ 02+nEspLin, 182+nEspLarg TO 75+nEspLin, 274+nEspLarg LABEL OemToAnsi(STR0046)				PIXEL OF oPanel //"Filtragem"

	//--------------------------------------------------------------
	//Coluna 1
	@ 15+nEspLin, 009+nEspLarg SAY STR0047 SIZE 30,07 OF oPanel PIXEL //"Banco"
	@ 12+nEspLin, 035+nEspLarg MSGET oBancolt VAR cBancolt 	SIZE 40, 10 PIXEL OF oPanel Hasbutton PIXEL F3 cF3Bco ;
					Valid IIF(nOpc1 ==2, .T.,u_xAtulValidou() .And. u_xF070VldBco(cBancolt,@cAgencialt,@cContalt,.T.,.T.,,.T.) ;
					.And. IiF(lFa070Bco,ExecBlock("FA070BCO",.F.,.F.),.T.) .And. IIF(lJFilBco, JurVldSA6("1", {cEscrit, cBancolt, cAgencialt, cContalt}), .T.))

	If RetGlbLGPD("A6_COD") .Or. RetGlbLGPD("A6_AGENCIA") .Or. RetGlbLGPD("A6_NUMCON")
		oBancolt:lObfuscate	:= .T.
		oBancolt:bWhen		:= {|| .F. }
		cBancolt			:= Replicate("*", TamSX3("A6_COD")[1])
		oBancolt:cText 		:= cBancolt
	Endif
	@ 29+nEspLin ,009+nEspLarg SAY STR0048 SIZE 30,07 OF oPanel PIXEL //"Agência"
	@ 26+nEspLin ,035+nEspLarg MSGET oAgencialt VAR cAgencialt            	SIZE 40, 10 PIXEL OF oPanel Hasbutton ;
					Valid IIF(nOpc1 ==2, .T.,If(!lValidou,If(u_xF070VldBco(cBancolt,@cAgencialt,@cContalt,.T.,.T.,cAgencialt,.T.),.T.,oBancolt:SetFocus()),.T.) ;
					.And. IIF(lJFilBco, JurVldSA6("2", {cEscrit, cBancolt, cAgencialt, cContalt}), .T.))

	If RetGlbLGPD("A6_COD") .Or. RetGlbLGPD("A6_AGENCIA") .Or. RetGlbLGPD("A6_NUMCON")
		oAgencialt:lObfuscate	:= .T.
		oAgencialt:bWhen		:= {|| .F. } 
		cAgencialt				:= Replicate("*", TamSX3("A6_AGENCIA")[1])	
		oAgencialt:cText 		:= cAgencialt	
	Endif
	@ 42+nEspLin ,009+nEspLarg SAY STR0049 					SIZE 30,07 OF oPanel PIXEL //"Conta"
	@ 40+nEspLin ,035+nEspLarg MSGET oContalt VAR cContalt              	SIZE 40, 10 PIXEL OF oPanel Hasbutton ;
					Valid IIF(nOpc1 ==2, .T.,If(!lValidou,If(u_xF070VldBco(cBancolt,@cAgencialt,@cContalt,.T.,.T.,cAgencialt+cContalt,.T.),.T.,oBancolt:SetFocus()),.T.);
					.And. IIF(lJFilBco, JurVldSA6("3", {cEscrit, cBancolt, cAgencialt, cContalt}), .T.))

	If RetGlbLGPD("A6_COD") .Or. RetGlbLGPD("A6_AGENCIA") .Or. RetGlbLGPD("A6_NUMCON")
		oContalt:lObfuscate	:= .T.
		oContalt:bWhen		:= {|| .F. }
		cContalt			:= Replicate("*", TamSX3("A6_NUMCON")[1]) 	
		oContalt:cText 		:= cContalt	
	Endif

	@ 56+nEspLin ,009+nEspLarg SAY STR0050 SIZE 30,07 OF oPanel PIXEL //"N.Titulos"
	@ 54+nEspLin ,035+nEspLarg MSGET nNroTit               	SIZE 40,10 OF oPanel PIXEL Picture "999" Valid nNroTit > 0

	@ 70+nEspLin ,009+nEspLarg SAY STR0051 					SIZE 30,07 OF oPanel PIXEL //"Lote"
	@ 69+nEspLin ,035+nEspLarg MSGET oLoteFin VAR cLoteFin 	SIZE 40,10 OF oPanel PIXEL Picture "@!" ;
					 Valid IIF(nOpc1 ==2,.T.,(cChaveLbnOld := cChaveLbn, CheckLote("R")) .And. Fa070LoteFin(cLoteFin, @cChaveLbn)) ON CHANGE UnLockByName(cChaveLbn,.T.,.F.)  // Libera Lock

	@ 84+nEspLin ,009+nEspLarg SAY STR0052 					SIZE 30,07 OF oPanel PIXEL //"Natureza"
	@ 82+nEspLin ,035+nEspLarg MSGET cNaturLote            	SIZE 40,10 OF oPanel PIXEL Picture "@!"  F3 "SED" Valid ExistCpo("SED") .and. If(lNatSA, FinVldNat(.F.,cNaturLote,1),.T.) HASBUTTON


	//--------------------------------------------------------------
	//Coluna 2
	@ 14+nEspLin ,084+nEspLarg SAY STR0053 SIZE 53,07 OF oPanel PIXEL //"Valor T¡tulos"
	@ 11+nEspLin ,125+nEspLarg MSGET nTotGer    SIZE 52, 08 PIXEL OF oPanel Picture PesqPict("SE1","E1_VALOR") Valid MontaTotal(oCredConta) HASBUTTON

	@ 27+nEspLin ,084+nEspLarg SAY STR0054 SIZE 53,07 OF oPanel PIXEL //"Total Despesas"
	@ 25+nEspLin ,125+nEspLarg MSGET nTotDesp   SIZE 52, 08 PIXEL OF oPanel Picture PesqPict("SE1","E1_VALOR") Valid MontaTotal(oCredConta) HASBUTTON

	@ 42+nEspLin ,084+nEspLarg SAY STR0055 SIZE 53,07 OF oPanel PIXEL //"Total Descontos"
	@ 39+nEspLin ,125+nEspLarg MSGET nTotDesc   SIZE 52, 08 PIXEL OF oPanel Picture PesqPict("SE1","E1_DESCONT") Valid MontaTotal(oCredConta) HASBUTTON

	@ 56+nEspLin ,084+nEspLarg SAY STR0056 SIZE 53,07 OF oPanel PIXEL //"Total Multas"
	@ 54+nEspLin ,125+nEspLarg MSGET nTotMul	SIZE 52, 08 PIXEL OF oPanel Picture PesqPict("SE1","E1_MULTA") Valid MontaTotal(oCredConta) HASBUTTON

	@ 70+nEspLin ,084+nEspLarg SAY STR0057 SIZE 53,07 OF oPanel PIXEL //"Total Juros"
	@ 69+nEspLin ,125+nEspLarg MSGET nTotJur	SIZE 52, 08 PIXEL OF oPanel Picture PesqPict("SE1","E1_JUROS") Valid MontaTotal(oCredConta) HASBUTTON

	@ 85+nEspLin ,084+nEspLarg SAY STR0058 SIZE 53,07 OF oPanel PIXEL //"Cr‚dito em C/C"
	@ 83+nEspLin ,125+nEspLarg MSGET oCredConta VAR nCredConta  SIZE 52, 08 PIXEL OF oPanel Picture PesqPict("SE1","E1_VALOR") HASBUTTON


	//Coluna 3
	@ 16+nEspLin ,187+nEspLarg SAY STR0059 SIZE 44,07 OF oPanel PIXEL //"Do Vencto."
	@ 14+nEspLin ,227+nEspLarg MSGET dVencDe        SIZE 50, 10 PIXEL OF oPanel Valid IIF(nOpc1 ==2, .T.,! Empty(dVencDe)) HASBUTTON

	@ 30+nEspLin ,187+nEspLarg SAY STR0060 SIZE 42,07 OF oPanel PIXEL //"At‚ o Vencto."
	@ 28+nEspLin ,227+nEspLarg MSGET dVencAte		SIZE 50, 10 PIXEL OF oPanel Valid IIF(nOpc1 ==2, .T.,! Empty(dVencAte)) HASBUTTON

	@ 45+nEspLin ,187+nEspLarg SAY STR0061 SIZE 39,07 OF oPanel PIXEL //"Da Natureza"
	@ 42+nEspLin ,227+nEspLarg MSGET cNatDe			SIZE 50, 10 PIXEL OF oPanel Picture "@!" F3 "SED" HASBUTTON

	@ 59+nEspLin ,187+nEspLarg SAY STR0062 SIZE 45,07 OF oPanel PIXEL //"Até a Natureza"
	@ 57+nEspLin ,227+nEspLarg MSGET cNatAte		SIZE 50, 10 PIXEL OF oPanel Picture "@!" F3 "SED" HASBUTTON Valid cNatAte>=cNatDe


	If IsPanelFin()  //Chamado pelo Painel Financeiro
		oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1])
		ACTIVATE MSDIALOG oDlg ON INIT FaMyBar(oDlg,;
		{||(nOpc1 := 1, IIF(F070OkLote(cBancolt,cAgencialt,cContalt,cLoteFin),oDlg:End(),nOpc1 := 0))},;
		{||(nOpc1 := 2,oDlg:End())})

		FinVisual(cAlias,FinWindow,(cAlias)->(Recno()),.T.)
	Else
		DEFINE SBUTTON FROM 80, 214 TYPE 1 ENABLE OF oDlg ACTION (nOpc1 := 1,IIF(Empty(cLoteFin),(oLoteFin:SetFocus(),nOpc1 := 0),oDlg:End()))
		DEFINE SBUTTON FROM 80, 244 TYPE 2 ENABLE OF oDlg ACTION (nOpc1 := 2,oDlg:End())
		ACTIVATE MSDIALOG oDlg VALID (iif(nOpc1==1,( u_xCarregaSA(cBancolt,cAgencialt,cContalt,.T.,,.T.).and. ValidaTotal() ),.T.)) CENTERED
	EndIf

	If nOpc1 != 1
		UnLockByName(cChaveLbn,.T.,.F.)  // Libera Lock
		If __lSX8
			RollBackSX8()
		EndIf
		Exit
	EndIf

	//-----------------------------------------------------------------------
	// Chama a SumAbatRec antes da IndRegua para abrir alias auxiliar __SE1 ³
	//-----------------------------------------------------------------------
	SumAbatRec( "", "", "", 1, "")

	nMoedaBco := Max(MoedaBco(cBancoLt,cAgenciaLt,cContaLt),1)

	//-----------------------------------------------------------------------
	// Filtra o arquivo para t¡tulos em abertos
	//-----------------------------------------------------------------------

	nValor   := 0    // valor total dos T¡tulos,mostrado no rodape do browse
	nQtdTit  := 0    // quantidade de T¡tulos,mostrado no rodape do browse
	nOpca    := 0

	lRet := FA070Mark(cBancolt,lPreMark)

	If lRet
		lGrava := u_xfA070Grava()
		If __lSX8 .And. lGrava
			ConfirmSX8()
		Endif
	Else
		If __lSX8
			RollBackSX8()
		Endif
	EndIf
	UnLockByName(cChaveLbn,.T.,.F.)  // Libera Lock
	Exit
End

IF FindFunction("FObjClean")
	FObjClean()
Endif

//-----------------------------------------------------------------------
// Restaura os indices
//-----------------------------------------------------------------------
dbSelectArea("SE1")
DbClearFilter()
DbSetorder(nOrder)
dbGoTo(nSalvRec)
cLoteFin := SPACE(TamSX3("E1_LOTE")[1])

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³F070BXCOMP³ Autor ³ TOTVS				    ³ Data ³ 11/06/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna valor de titulos baixados por compensação          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ F070BXCOMP                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function xF070BXCOMP
Local nValorBx   := 0
Local nValorCxBx := 0
Local nValor     := 0
Local aArea	     := GetArea()
Local aAreaSE5	 := SE5->(GetArea())

DbSelectArea("SE5")
DbSetOrder(10)
DbSeek(xFilial("SE5")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_LOJA)

Do While SE5->(!Eof() .And. TRIM(E5_FILIAL+E5_DOCUMEN) == TRIM(SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_LOJA))
	If E5_TIPODOC == "BA"
	    nValorBx += E5_VALOR
	ElseIf E5_TIPODOC == "ES"
		nValorCxBx += E5_VALOR
	EndIf
	DbSkip()
EndDo

nValor :=nValorBx - nValorCxBx
RestArea(aAreaSE5)
RestArea(aArea)

Return (nValor)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fA070TitW ³ Autor ³ Wagner Xavier         ³ Data ³ 26/05/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fun‡„o utilizada para Baixa de Titulos - Windows           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fA070Titw()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function XfA070(cMarca,nTotal,nHdlPrv,lHdlPrv,lPadrao,cArquivo,cPadrao,nTotLtEZ,aDiario,aFlagCTB)
Local nOpca
Local lJuros		:= IIF( mv_par05 == 1, .T., .F. )
LOCAL lMovBco  		:= .T.
LOCAL lBaixou  		:= .F.
LOCAL nTolerPg 		:= GetMv("MV_TOLERPG")
LOCAL oDlgLote
LOCAL oTitulo
LOCAL oEmissao
LOCAL oVencRea
LOCAL oNomeCli
LOCAL oHist
LOCAL oSituacao
LOCAL oBaixa
LOCAL oDtCredito
LOCAL oHist070
LOCAL oMotBx
LOCAL oValor
LOCAL oTotAbLiq
Local oProRata
LOCAL oTotAbImp
LOCAL oValorLiq
LOCAL oParciais
LOCAL oMulta
LOCAL oJuros
LOCAL oVA			//Valores Acessorios
LOCAL oValEstr
LOCAL oAcresc
LOCAL oDecresc
LOCAL nDecrescF
LOCAL oCMonet
Local nSalvRec  	:= RecNO( )
LOCAL cParcela
LOCAL cMoeda
LOCAL aMotBx     	:= ReadMotBx()
LOCAL aDescMotBx 	:= {}
Local lFa070MDB  	:= ExistBlock("FA070MDB")
Local lMdbOk     	:= .F.
Local oModSpb
Local aModalSpb 	:= {"1=TED","2=CIP","3=COMP"}
Local lSpbInUse 	:= SpbInUse()
Local nUltLin
Local bSetKey 		:= {||}
Local oMultNat
Local lMultNat 		:= .F.
Local NI
Local oPrefixo
Local oTipo
Local oParcela
Local lPanelFin 	:= IsPanelFin()
Local aButtons 		:= {}
Local oSize
Local a1stRow 		:= {}
Local a2ndRow 		:= {}
Local nBase			:= 0
Local lJurMulDes	:= (SuperGetMv("MV_IMPBAIX",.t.,"2") == "1")

//Controla o Pis Cofins e Csll na baixa  (1-Retem PCC na Baixa ou 2-Retem PCC na Emissão(default) )
Local lPccBxCr		:= FPccBxCr(.T.)
Local oPis
Local oCofins
Local oCsll
Local aPcc			:= {}
//Controla IRPJ na baixa
Local lIrPjBxCr		:= FIrPjBxCr(.T.)
Local oIrrf
Local x
LOCAL lBxLiq		:= .F.
LOCAL lBxCEC		:= .F.  //Verificador de existencia de baixa por compensacao entre carteiras
Local aBaixa    	:= {}
LOCAL nVlrBaixa 	:= 0
LOCAL lBaixaAbat	:= .F.
LOCAL nTotAdto		:= 0
Local lExistVA 		:= TableInDic("FKD") .and. TableInDic("FKC")
Local lSDACRVL 		:= SuperGetMv("MV_SDACRVL",.T.,.F.)
Local lSDDECVL		:= .F.
Local lCalcIssBx	:= GetNewPar("MV_MRETISS","1") == "2"  //Retencao do ISS pela emissao (1) ou baixa (2)
Local aTitCalc		:= {}

PRIVATE aBaixaSE5	:= {}
Private nAcrescF	:= 0
Private nIrrf 		:= 0
PRIVATE nOldIrrf	:= 0
Private nOldPis     := SE1->E1_PIS
Private nOldCofins  := SE1->E1_COFINS
Private nOldCsll    := SE1->E1_CSLL
PRIVATE lRaRtImp  	:= lFinImp .And.FRaRtImp()     //Define se ha retencao de impostos PCC/IRPJ no R.A
PRIVATE cOldVA		:= ""	//Valores Acessorios
Private nOldDescont := 0
Private oBanco
Private oAgencia
Private oConta
Private oDescont
Private oValRec
Private nOldMulta 	:= 0
Private nOldJuros 	:= 0
Private nOldVA 		:= 0

If lIsRussia
	nValRec    := 0
	nOldValRec := 0
EndIf

lF415Auto := IIf(Type("lF415Auto")=="U",.F.,lF415Auto)

__nMRBxTot := 0

IF ExistBlock("F070MNAT")
	lMultNat := ExecBlock("F070MNAT",.F.,.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna o Array aDescMotbx contendo apenas a descricao do	³
//³ motivo das Baixas. 						  								³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If len( aDescMotbx ) ==0
	For NI := 1 to Len(aMotBx)
		If Substr(aMotBx[nI],34,01) == "A" .or. Substr(aMotBx[nI],34,01) =="R"
			AADD( aDescMotbx,Substr(aMotBx[nI],07,10))
		EndIf
	Next
EndIf

While (cAliasLote)->(!Eof())
	If (cAliasLote)->E1_OK != cMarca .or. (cAliasLote)->E1_TIPO $ MVABATIM+"/"+MVFUABT //adicionado MVFUABT pois a variável MVABATIM não está retornando FU-
		(cAliasLote)->(dbSKip())
		Loop
	Else
		SE1->(dbGoto((cAliasLote)->RECNOSE1))
		Exit
	EndIf
Enddo

__lCalcImp := .F.

If __lBordImp .And. !Empty(SE1->E1_NUMBOR) 
	__lCalcImp := BorderoImp(SE1->E1_FILORIG, SE1->E1_NUMBOR, "R", SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
EndIf

If __lFPIXatv .And. !__lCalcImp .And. !__lCnabImp
	__lCalcImp := PIXIsActiv()
EndIf

//Posiciona Cliente no SA1
dbSelectArea("SA1")
SA1->(MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
dbSelectArea("SE1")
lIrPjBxCr		:= FIrPjBxCr(.T.)

//Carrega Variaveis da Baixa
nSalvRec := RecNo()
cTitulo 	:= SE1->E1_PREFIXO + " " + SE1->E1_NUM+ " " + SE1->E1_PARCELA
cParcela := SE1->E1_PARCELA
dEmissao	:= SE1->E1_EMISSAO
dVencRea	:= SE1->E1_VENCREA
cNomeCli := SE1->E1_CLIENTE + " - " + Subst(SA1->A1_NOME,1,40)
cHist		:= SE1->E1_HIST
cSituacao:= SE1->E1_SITUACA + " " + fa070situa()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Sustituidas as linhas acima pelas linhas abaixo para processamento   ³
//³da baixa por lote com os valores definidos na tela de lote.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// 0 = Carteira
// F = Carteira Protesto
// G = Carteira Acordo
cBanco	 := Iif( cLoteFin != Space( TamSX3("E1_LOTE")[1] ), cBancolt  , Iif( FN022SITCB(SE1->E1_SITUACA)[1],aCaixaFin[1], SE1->E1_PORTADO ))
cAgencia := Iif( cLoteFin != Space( TamSX3("E1_LOTE")[1] ), cAgencialt, Iif( FN022SITCB(SE1->E1_SITUACA)[1],aCaixaFin[2], SE1->E1_AGEDEP  ))
cConta	 := Iif( cLoteFin != Space( TamSX3("E1_LOTE")[1] ), cContalt  , Iif( FN022SITCB(SE1->E1_SITUACA)[3],aCaixaFin[3], SE1->E1_CONTA   ))

nMoedaBco:= Max(MoedaBco(cBanco,cAgencia,cConta),1)

dBaixa      := CriaVar("E1_BAIXA")
If cPaisLoc == "BRA"
	nTxMoeda 	:= If(SE1->E1_MOEDA > 1, If(SE1->E1_TXMOEDA > 0, SE1->E1_TXMOEDA,RecMoeda(dBaixa,SE1->E1_MOEDA)),0)
Endif
dDtCredito  := dDataBase
cHist070	:= Criavar("E5_HISTOR")		//Inicilizador padrao
If Empty(cHist070)
	cHist070 := STR0007+Space(Len(cHist070)-24)  // "Valor recebido s/ T¡tulo"
Endif
cMotBx		:= ""
nValor		:= SE1->E1_VALOR
nTotAbImp   := 0
nTotAbLiq   := 0
nTotAbat    := SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"S",dBaixa,@nTotAbImp)
nValorLiq 	:= 0
nTotAbLiq   := nTotAbat - nTotAbImp
dbGoto(nSalvRec)
nParciais	:= 0//SE1->E1_VALOR-SE1->E1_SALDO
nAcrescF		:= SE1->E1_SDACRES

If ExistBlock("F070ACRE")
	ExecBlock("F070ACRE",.F.,.F.)
Endif

nDecrescF	:= SE1->E1_SDDECRE
nAcresc		:= Round(NoRound(xMoeda(nAcrescF,SE1->E1_MOEDA,nMoedaBco,dBaixa,3,nTxMoeda),3),2)
nDecresc    := Round(NoRound(xMoeda(nDeCrescF,SE1->E1_MOEDA,nMoedaBco,dBaixa,3,nTxMoeda),3),2)
nDescont	:= 0
nMulta		:= 0
nJuros		:= 0
nVa			:= 0 //Valores Acessórios
nCM			:= 0
nValrec		:= Round(Noround(xMoeda(SE1->E1_SALDO-nTotAbat,SE1->E1_MOEDA,nMoedaBco,dBaixa,3,nTxMoeda),3),2)+nMulta+nJuros+nVA-nDescont+nAcresc-nDecresc
nPIS		:= 0
nCOFINS		:= 0
nCSLL		:= 0
//***Reestruturacao SE5***
nPisCalc	:= 0
nCofCalc	:= 0
nCslCalc	:= 0
nIrfCalc	:= 0
nIssCalc	:= 0
nPisBaseR 	:= 0
nCofBaseR	:= 0
nCslBaseR 	:= 0
nIrfBaseR 	:= 0
nIssBaseR 	:= 0
nPisBaseC 	:= 0
nCofBaseC 	:= 0
nCslBaseC 	:= 0
nIrfBaseC 	:= 0
nIssBaseC 	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Para que o valor da baixa parcial nao fique negativo, verifico o saldo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (SE1->E1_VALOR > SE1->E1_SALDO) .And. Empty(SE1->E1_TIPOLIQ)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Procura pelas baixas deste titulo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lTipBxCP:=lRaRtImp
	aBaixa := Sel070Baixa( "VL /V2 /BA /RA /CP /LJ /" + MV_CRNEG, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO,;
					@nTotAdto, @lBaixaAbat, SE1->E1_CLIENTE, SE1->E1_LOJA, @nVlrBaixa, , @lBxCec, @lBxLiq,,.T.)
	For x := 1 To Len(aBaixaSE5)
		nParciais += aBaixaSE5[x][8]
       	If lPccBxCR .And. lRaRtImp .and. !(aBaixaSE5[x][21]$ "1|2")
		   nParciais += aBaixaSE5[x][18]+aBaixaSE5[x][19]+aBaixaSE5[x][20]+aBaixaSE5[x][30]// somar impostos PCC
		Elseif lIrPjBxCr .And. lRaRtImp
	  		nParciais += aBaixaSE5[x][30]
		Endif
		If lRaRtImp
			nParciais += aBaixaSE5[x][32]+aBaixaSE5[x][33]
			nTotAbat  -= aBaixaSE5[x][32]+aBaixaSE5[x][33]
		Endif

		//Verifica baixas parciais no caso de desconto.
		If ABAIXASE5[x][16] > 0 .and. lSDACRVL
			nParciais += ABAIXASE5[x][16]
		Endif
		//
	Next
	nParciais += nTotAdto
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Soma valor de decrescimo em baixas parciais, para evitar         ³
	//³ diferencas entre valor original e valor recebido                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SE1->E1_SDDECRE <> SE1->E1_DECRESC
		If SE1->E1_SDDECRE = 0
			lSDDECVL := .T.
			If lSDACRVL
				nParciais -= SE1->E1_DECRESC
			Endif
		Else
			If lSDACRVL
				nParciais += ( SE1->E1_DECRESC - SE1->E1_SDDECRE )
			Endif
		Endif
	EndIf
Else
	nParciais := SE1->E1_VALOR - SE1->E1_SALDO
Endif

If	lIrPjBxCr
	nParciais += nIrrf
	nValRec := SE1->E1_VALOR - nParciais
	If !__lIrfMR
		nIrrf:= Iif(cPaisLoc == "BRA" .And. !__lCalcImp, FCaIrBxCR(nValRec), 0)
		nOldIrrf := nIrrf
	EndIf
EndIf

// Calcula o desconto e o juros (se houver) e valida a data Idem para Valores Acessorios
fA070Data(@nTxMoeda,.F.,/*oDtBaixa*/,/*oJuros*/,/*oCbx*/,/*lReclcJur*/,/*oVa*/,/*aImpos*/,/*lMudouMulta*/, aTitCalc)

// Motor de retenção
If __lTemMR .And. !__lCalcImp
   	aImpos := F070VldImp(nValRec, dBaixa,@lPccBxCr, @lIrPjBxCr, @lCalcIssBx,@__lImpMR)
EndIf

//PCC Baixa CR
If lPccBxCR
	nParciais += nPis + nCofins + nCsll

    If SE1->E1_MOEDA > 1
		nValRec:= xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,1,dDatabase,3,nTxMoeda)
		nValRec:= nValRec - nParciais
	Else
		nValRec := SE1->E1_VALOR - nParciais
	EndIf

	nOldValRec	:= nValRec
	
	If dBaixa < dLastPcc
		f070TotMes(dBaixa,.T.,,.F.)
	Else
		nBase	:= FBaseRPCC(nValRec)
		
		If lJurMulDes .And. (nBase-nDescont+nJuros + nVA+nMulta+nAcresc-nDecresc > 0)
				nBase 	:= nBase-nDescont+nJuros + nVA+nMulta+nAcresc-nDecresc
			EndIf

		aTitCalc := {}
		
		If !__lPccMR .And. !__lCalcImp .And. !SE1->E1_TIPO $ MVRECANT
			aPcc	:= newMinPcc(dBaixa, nBase,SE1->E1_NATUREZ,"R",SA1->A1_COD+SA1->A1_LOJA,,,,,,cMotBx) 
			nPis	:= aPcc[2]
			nCofins	:= aPcc[3]
			nCsll	:= aPcc[4]
			If len(aPCC) > 4
				aTitCalc := aPCC[5]
			Endif
		Endif
	EndIf
	
	If Type("aDadosRet") = "A" .And. ValType(aDadosRet[1]) == "U"
		aDadosRet := Array(7)
		AFill( aDadosRet, 0 )
	Endif
Endif

fa070val( nValrec, nTxMoeda )
cMoeda 		:= IIF(Empty(SE1->E1_MOEDA),"1",AllTrim(Str(SE1->E1_MOEDA,2)))
cDescMoeda 	:= SubStr(GetMV("MV_SIMB"+cMoeda),1,3)

nOldPis     := nPis
nOldCofins  := nCofins
nOldCsll    := nCsll

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pr‚-inicializa a modalidade de SPB                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lSpbInUse
	If !Empty(SE1->E1_MODSPB)
		cModSpb := SE1->E1_MODSPB
	Else
	   cModSpb := "1"
	Endif
Endif

//Botao de Cheques no Painel Financeiro
AADD(aButtons, {"LIQCHECK", {|| CadCheqCR(cBanco,cAgencia,cConta,nValRec,dBaixa,1)}, STR0141 }) //"Cheques"
bSetKey := SetKey(VK_F4,{|| If( !SE1->E1_TIPO $ MV_CRNEG,CadCheqCR(cBanco,cAgencia,cConta,nValRec,dBaixa,1),.F.)})

DEFINE FONT oFontLbl NAME "Arial" SIZE 6, 15 BOLD
nLin2 := If(cPaisLoc=="BRA",700,520)

//Valores Acessorios.	
If lPodeTVA .and. lExistVA
	nLin2 += 24
EndIf

If lIsRussia
	DEFINE MSDIALOG oDlgLote FROM  69,33 TO 565,599 TITLE STR0103 PIXEL OF oMainWnd  // Accounts Receivable
Else
	DEFINE MSDIALOG oDlgLote FROM  69,33 TO nLin2,593 TITLE STR0103 PIXEL OF oMainWnd  //"Baixas a Receber"
EndIf

//Faz o calculo automatico de dimensoes de objetos
oSize := FwDefSize():New(.T.,,,oDlgLote )

oSize:lLateral := .F.
oSize:lProp	:= .T. // Proporcional

oSize:AddObject( "1STROW" ,  100, 18, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "2NDROW" ,  100, 82, .T., .T. ) // Totalmente dimensionavel

oSize:Process() // Dispara os calculos

a1stRow := {oSize:GetDimension("1STROW","LININI"),;
			oSize:GetDimension("1STROW","COLINI"),;
			oSize:GetDimension("1STROW","LINEND"),;
			oSize:GetDimension("1STROW","XSIZE")}

a2ndRow := {oSize:GetDimension("2NDROW","LININI"),;
			oSize:GetDimension("2NDROW","COLINI"),;
			oSize:GetDimension("2NDROW","LINEND"),;
			oSize:GetDimension("2NDROW","XSIZE")}

If lIsRussia
	@ a1stRow[1] + 000, a1stRow[2] + 000 GROUP oGrp1 TO a1stRow[3]+12, (a1stRow[4]-19) LABEL STR0008 OF oDlgLote PIXEL //"Main"
	a2ndRow[1]:= a2ndRow[1] + 13	
	@ a2ndRow[1] + 000, a2ndRow[2] + 000 GROUP oGrp2 TO a2ndRow[3]-2, 135 LABEL STR0009 OF oDlgLote  PIXEL //"General Data"
	@ a2ndRow[1] + 000, a2ndRow[2] + 139 GROUP oGrp3 TO a2ndRow[3]-2, (a2ndRow[4]-19) LABEL STR0010 OF oDlgLote  PIXEL //"Amounts Posted"
Else
	@ a1stRow[1] + 000, a1stRow[2] + 000 GROUP oGrp1 TO a1stRow[3], (a1stRow[4]-15) LABEL STR0008 OF oDlgLote PIXEL //"Principal"
	@ a2ndRow[1] + 000, a2ndRow[2] + 000 GROUP oGrp2 TO a2ndRow[3], 135 LABEL STR0009 OF oDlgLote  PIXEL //"Dados Gerais"
	@ a2ndRow[1] + 000, a2ndRow[2] + 139 GROUP oGrp3 TO a2ndRow[3], (a2ndRow[4]-15) LABEL STR0010 OF oDlgLote  PIXEL //"Valores da Baixa"
EndIf

oGrp1:oFont := oFontLbl
oGrp2:oFont := oFontLbl
oGrp3:oFont := oFontLbl

//////////////////////////
//Dados do titulo
@ a1stRow[1] + 008, a1stRow[2] + 004 SAY STR0211				SIZE 31,07 OF oDlgLote PIXEL //"Prefixo"
@ a1stRow[1] + 008, a1stRow[2] + Iif(lIsRussia,31,27) MSGET oPrefixo VAR SE1->E1_PREFIXO	SIZE 25,08 OF oDlgLote PIXEL When .F.
@ a1stRow[1] + 008, a1stRow[2] + 060 SAY STR0212 				SIZE 31,07 OF oDlgLote PIXEL //"Número"
@ a1stRow[1] + 008, a1stRow[2] + 085 MSGET oTitulo VAR SE1->E1_NUM		SIZE 70,08 OF oDlgLote PIXEL When .F.
@ a1stRow[1] + 008, a1stRow[2] + 165 SAY STR0213				SIZE 31,07 OF oDlgLote PIXEL //"Parcela"
@ a1stRow[1] + 008, a1stRow[2] + Iif(lIsRussia,191,188) MSGET oParcela VAR SE1->E1_PARCELA	SIZE 25,08 OF oDlgLote PIXEL When .F.
@ a1stRow[1] + 008, a1stRow[2] + 220 SAY STR0214				SIZE 31,07 OF oDlgLote PIXEL //"Tipo"
@ a1stRow[1] + 008, a1stRow[2] + 238 MSGET oTipo VAR SE1->E1_TIPO	F3 Iif(lIsRussia, "05", "SE1RDO") SIZE 30,08 OF oDlgLote PIXEL HASBUTTON
oTipo:lReadOnly := .T.

@ a1stRow[1] + 020, a1stRow[2] + 004 SAY STR0014 SIZE Iif(lIsRussia,25,22), 07 OF oDlgLote PIXEL //"Cliente"
@ a1stRow[1] + 020, a1stRow[2] + Iif(lIsRussia,31,27) MSGET oNomeCli VAR SE1->E1_CLIENTE F3 "SA1" SIZE 70,08 OF oDlgLote PIXEL HASBUTTON
oNomeCli:lReadOnly := .T.
@ a1stRow[1] + 020, a1stRow[2] + 105 MSGET SA1->A1_NOME SIZE 165,08 OF oDlgLote PIXEL When .F.

@ a1stRow[1] + 032, a1stRow[2] + 004 SAY STR0052 				SIZE 31,07 OF oDlgLote PIXEL //"Natureza"
@ a1stRow[1] + 032, a1stRow[2] + Iif(lIsRussia,31,27) MSGET oNaturez VAR SE1->E1_NATUREZ	F3 "SED" SIZE 70,08 OF oDlgLote PIXEL HASBUTTON
oNaturez:lReadOnly := .T.
@ a1stRow[1] + 032, a1stRow[2] + 105 SAY STR0012 				SIZE 31,07 OF oDlgLote PIXEL //"Emiss„o"
@ a1stRow[1] + 032, a1stRow[2] + 133 MSGET oEmissao VAR dEmissao	SIZE 48,08 OF oDlgLote PIXEL HASBUTTON When .F.
@ a1stRow[1] + 032, a1stRow[2] + 189 SAY STR0013 				SIZE 49,07 OF oDlgLote PIXEL //"Vencto.Atual"
@ a1stRow[1] + 032, a1stRow[2] + 222 MSGET oVencRea VAR dVencRea SIZE 48,08 OF oDlgLote PIXEL HASBUTTON When .F.

//////////////////////////
//Dados Gerais
nUltLin := 10 + a2ndRow[1]
@ nUltLin,005 SAY STR0015 SIZE 39, 07 OF oDlgLote PIXEL //"Hist.Emiss„o"
@ nUltLin,065 MSGET oHist		VAR cHist	SIZE 65, 08 OF oDlgLote PIXEL When .F.

nUltLin += 12
@ nUltLin,005 SAY STR0016 SIZE 35, 07 OF oDlgLote PIXEL //"Situa‡„o"
@ nUltLin,065 MSGET oSituacao	VAR cSituacao	SIZE 65, 08 OF oDlgLote PIXEL When .F.

nUltLin += 12
@ nUltLin,005 SAY STR0023 SIZE 32, 07 OF oDlgLote PIXEL //"Mot.Baixa"

@ nUltLin,065 MSCOMBOBOX oMotBx VAR cMotBx ITEMS aDescMotBx ;
	VALID IIF(lFA070MDB,lMdbOk:=ExecBlock("FA070MDB",.F.,.F.),.T.) ;
	SIZE 56, 10 OF oDlgLote PIXEL

nUltLin += 12
@ nUltLin,005 SAY STR0017 SIZE 32, 07 OF oDlgLote PIXEL //"Banco"
@ nUltLin,065 MSGET oBanco		VAR cBanco		F3 "SA6" SIZE 22, 08 OF oDlgLote PIXEL  HASBUTTON Valid u_CarregaSa(@cBanco,,,.T.)
oBanco:lReadOnly := .T.


nUltLin += 12
@ nUltLin,005 SAY STR0018 SIZE 32, 07 OF oDlgLote PIXEL //"Agˆncia"
@ nUltLin,065 MSGET oAgencia 	VAR cAgencia	SIZE 35, 08 OF oDlgLote PIXEL Valid ;
											u_CarregaSa(@cBanco,@cAgencia,,.T.) ;
											WHEN ( If(!(FN022SITCB(SE1->E1_SITUACA)[1]),.F.,.T.) .and. MovBcobx(cMotBx, .T.)) .and. ;
										 	If ( cLoteFin == Space(TamSX3("E1_LOTE")[1]), .t., .f. )

nUltLin += 12
@ nUltLin,005 SAY STR0019 SIZE 28, 07 OF oDlgLote PIXEL //"Conta"
@ nUltLin,065 MSGET oConta		VAR cConta		SIZE 65, 08 OF oDlgLote PIXEL Valid ;
											If(u_CarregaSa(@cBanco,@cAgencia,@cConta,.T.,,.T.),.T.,oBanco:SetFocus()) ;
											WHEN ( If(!(FN022SITCB(SE1->E1_SITUACA)[3]),.F.,.T.) .and. MovBcobx(cMotBx, .T.)) .and. ;
										 	If ( cLoteFin == Space(TamSX3("E1_LOTE")[1]), .t., .f. )

nUltLin += 12
@ nUltLin, 005 SAY STR0020 SIZE 39, 07 OF oDlgLote PIXEL//"Data Receb."
@ nUltLin, 065 MSGET oBaixa		VAR dBaixa		SIZE 50, 08 OF oDlgLote PIXEL HASBUTTON When F070DtRe() .and. !(Alltrim(SE1->E1_ORIGEM)=="FINI055") ;
	Valid fA070Data(@nTxMoeda,/*lHelp*/,/*oDtBaixa*/,/*oJuros*/,/*oCbx*/,/*lReclcJur*/,/*oVa*/,/*aImpos*/,/*lMudouMulta*/, aTitCalc)

nUltLin += 12
@ nUltLin, 005 SAY STR0021 SIZE 32, 07 OF oDlgLote PIXEL //"Data Cr‚dito"
@ nUltLin, 065 MSGET oDtCredito	VAR dDtCredito	SIZE 50, 08 OF oDlgLote PIXEL HASBUTTON Valid (dDtCredito >= dBaixa  .and. Iif(SuperGetMv("MV_BXDTFIN",,"1") == "2", DtMovFin(dDtCredito,,"2"), .T.)) .or. GetMv("MV_ANTCRED")

nUltLin += 12
@ nUltLin, 005 SAY STR0022	SIZE Iif(lIsRussia, 65, 32), 07 OF oDlgLote PIXEL //"Hist.Baixa"
@ nUltLin, 065 MSGET oHist070	VAR cHist070	SIZE 65, 08 OF oDlgLote PIXEL Picture "@!" VALID CheckSX3("E5_HISTOR") When VisualSX3("E5_HISTOR")

If cPaisLoc == "BRA"
	nUltLin += 12
	@ nUltLin,005 SAY STR0142 	SIZE 53, 07 OF oDlgLote PIXEL //"Taxa contratada"
	@ nUltLin,0065 MSGET nTxMoeda         SIZE 65, 08 OF oDlgLote PIXEL HASBUTTON Picture PesqPict( "SM2","M2_MOEDA"+AllTrim(Str(SE1->E1_MOEDA))) ;
				 When SE1->E1_MOEDA > 1 Valid Fa070Val(0,nTxMoeda)
Endif
If lSpbInUse
	nUltLin += 12
	@ nUltLin,005 SAY STR0140 SIZE 32, 07 OF oDlgLote PIXEL  //"Modalidade SPB"
	@ nUltLin,065 COMBOBOX oModSPB VAR cModSpb ITEMS aModalSpb SIZE 56, 47 OF oDlgLote PIXEL
Endif
If !__lPyme
	nUltLin += 12
	@ nUltLin,005 SAY STR0173 SIZE 100, 07 OF oDlgLote PIXEL  //"Rateio Mult.Naturezas"
	@ nUltLin,65 CHECKBOX oMultNat VAR lMultNat PROMPT "" SIZE 11,11 OF oDlgLote PIXEL
EndIf

//////////////////////////
//Dados da Baixa
nUltLin := 7 + a2ndRow[1]
@ nUltLin,144 SAY STR0027 + cDescMoeda SIZE 53, 08 OF oDlgLote PIXEL //"Valor Original "
@ nUltLin,204 MSGET oValor 	VAR nValor	SIZE 65, 08 OF oDlgLote PIXEL  HASBUTTON When .F. Picture PesqPict( "SE1","E1_VALOR" )  //"@E 999,999,999,999.99"

If cPaisLoc <> "CHI"
	nUltLin += 12
	@ nUltLin,144 SAY STR0028 SIZE 53, 07 OF oDlgLote PIXEL // "- Abatimentos"
	@ nUltLin,204 MSGET oTotAbLiq	VAR nTotAbLiq  	SIZE 65, 08 OF oDlgLote PIXEL HASBUTTON  When .F.  Picture PesqPict( "SE1","E1_VALOR" )  //"@E 999,999,999,999.99"

	If cPaisLoc == "BRA"
		nUltLin += 12
		@ nUltLin,144 SAY STR0186 SIZE 53, 07 OF oDlgLote PIXEL // "- Impostos"
		@ nUltLin,204 MSGET oTotAbImp  VAR nTotAbImp  SIZE 65, 08 OF oDlgLote PIXEL  HASBUTTON When .F.  Picture PesqPict( "SE1","E1_VALOR" )  //"@E 999,999,999,999.99"

		nValorLiq :=  (SE1->E1_VALOR - nTotAbLiq - nTotAbImp)
		nUltLin += 12
		@ nUltLin,144 SAY STR0187 SIZE 53, 07 OF oDlgLote PIXEL // "Valor Liquido"
		@ nUltLin,204 MSGET oValorLiq VAR nValorLiq     SIZE 65, 08 OF oDlgLote PIXEL HASBUTTON When .F. Picture PesqPict("SE1","E1_VLCRUZ") //"@E 999,999,999,999.99"
	Endif
EndIf
nUltLin += 12
@ nUltLin,144 SAY STR0029 SIZE 53, 07 OF oDlgLote PIXEL //"- Pagtos Parciais"
@ nUltLin,204 MSGET oParciais	VAR nParciais	SIZE 65, 08 OF oDlgLote PIXEL  HASBUTTON When .F.  Picture PesqPict( "SE1","E1_VALOR" )  //"@E 999,999,999,999.99"

nUltLin += 12
@ nUltLin,144 SAY  STR0136 SIZE 53, 07 OF oDlgLote PIXEL //"- Decrescimo"
@ nUltLin,204 MSGET oDecresc VAR Iif(lSDDECVL, SE1->E1_DECRESC,nDecrescF)  SIZE 65, 08 OF oDlgLote PIXEL  HASBUTTON     Picture PesqPict( "SE1","E1_DECRESC" )  When .f.

nUltLin += 12
@ nUltLin,144 SAY  STR0135 SIZE 53, 07 OF oDlgLote PIXEL //"+ Acrescimo"
@ nUltLin,204 MSGET oAcresc VAR nAcrescF  SIZE 65, 08 OF oDlgLote PIXEL  HASBUTTON     Picture PesqPict( "SE1","E1_ACRESC" )  When .f. //"@E 999,999,999,999.99"

nUltLin += 12
@ nUltLin,144 SAY STR0030 SIZE 53, 07 OF oDlgLote PIXEL //"- Descontos"
@ nUltLin,204 MSGET oDescont VAR nDescont  SIZE 65, 08 OF oDlgLote PIXEL HASBUTTON When F070DSC()  Picture PesqPict( "SE1","E1_DESCONT" ) ; //"@E 999,999,999,999.99"
															Valid F70VlDsc()

nOldDescont := nDescont

nUltLin += 12
@ nUltLin,144 SAY STR0101 SIZE 53, 07 OF oDlgLote PIXEL //"+ Multa"
@ nUltLin,204 MSGET oMulta VAR nMulta  SIZE 65, 08 OF oDlgLote PIXEL HASBUTTON Picture PesqPict( "SE1","E1_MULTA" ) ; //"@E 999,999,999,999.99"
															When F070Mul(oMulta,aTitCalc) .And. If(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG .And. !MovBcobx(cMotBx, .T.), .F., .T.);
															Valid Iif(nOldMulta # nMulta, (fA070Val(nMulta,nTxMoeda),nOldMulta := nMulta), .T.)
nOldMulta := nMulta

If cPaisLoc <> "CHI"
	nUltLin += 12
   @ nUltLin,144 SAY STR0031 SIZE 53, 07 OF oDlgLote PIXEL //"+ Tx.Permanenc."
   @ nUltLin,204 MSGET oJuros VAR nJuros   SIZE 65, 08 OF oDlgLote PIXEL HASBUTTON When F070JRS() Picture PesqPict( "SE1","E1_JUROS" ) ; //"@E 999,999,999,999.99"
		   													Valid Iif(nOldJuros # nJuros, (fA070Val(nJuros,nTxMoeda),nOldJuros := nJuros), .T.)
	nOldJuros := nJuros
Else
	nUltLin += 12
   @ nUltLin,144 SAY STR0133 SIZE 53, 07 OF oDlgLote PIXEL //"- Outros Gastos"
   @ nUltLin,204 MSGET oOtrga VAR nOtrga   SIZE 65, 08 OF oDlgLote PIXEL HASBUTTON Picture PesqPict( "SE1","E1_OTRGA" ) ; //"@E 999,999,999,999.99"
   Valid fA070Val(nOtrga)
EndIf
//Controla IRPJ na baixa
If cPaisLoc == "BRA" .And. lIrPjBxCr .And. !__lIrfMR
	nUltLin+=12
	@ nUltLin,144 SAY STR0228  SIZE 53, 07 OF oDlgLote PIXEL  // "- IRRF"
	@ nUltLin,204 MSGET oIrrf VAR nIrrf SIZE 66, 08 OF oDlgLote PIXEL HASBUTTON Picture PesqPict( "SE1","E1_IRRF" ); //"@E 999,999,999,999.99"
													 Valid Iif( nOldIrrf # nIrrf, (fA070Val(nIrrf,nTxMoeda),nOldIrrf := nIrrf), .T.) When nIrrf > 0  
	nOldIrrf := nIrrf
EndIf

//Pcc Baixa CR
If cPaisLoc == "BRA" .And. lPccBxCR .And. !__lPccMR //1-Retem PCC na Baixa ou 2-Retem PCC na Emissão(default)
   nUltLin +=12
   @ nUltLin,144 SAY STR0216 SIZE 53, 07 OF oDlgLote PIXEL //"- PIS"
   @ nUltLin,204 MSGET oPIS VAR nPIS   SIZE 66, 08 OF oDlgLote PIXEL HASBUTTON  Picture PesqPict( "SE1","E1_PIS" ) ; //"@E 999,999,999,999.99"
		   Valid Iif(nOldPis # nPis, (fA070Val(nPIS,nTxMoeda,.T.),nOldPis := nPis), .T.)
			nOldPis := nPis

   nUltLin +=12
   @ nUltLin,144 SAY STR0217 SIZE 53, 07 OF oDlgLote PIXEL //"- COFINS"
   @ nUltLin,204 MSGET oCOFINS VAR nCOFINS   SIZE 66, 08 OF oDlgLote PIXEL HASBUTTON Picture PesqPict( "SE1","E1_COFINS" ) ; //"@E 999,999,999,999.99"
		   Valid Iif(nOldCofins # nCofins, (fA070Val(nCOFINS,nTxMoeda,.T.),nOldCofins := nCofins), .T.)
			nOldCofins := nCofins

   nUltLin +=12
   @ nUltLin,144 SAY STR0218 SIZE 53, 07 OF oDlgLote PIXEL //"- CSLL"
   @ nUltLin,204 MSGET oCSLL VAR nCSLL   SIZE 66, 08 OF oDlgLote PIXEL HASBUTTON Picture PesqPict( "SE1","E1_CSLL" ) ; //"@E 999,999,999,999.99"
		   Valid Iif(nOldCsll # nCsll, (fA070Val(nCsll,nTxMoeda,.T.),nOldCsll := nCsll), .T.)
			nOldCsll := nCsll
EndIf

//Motor de Retenções
If __lTemMR .And. (__nTotImp > 0 .or. !Empty(cLote))
	nUltLin +=12
	@ nUltLin,144 SAY STR0286	SIZE 53,07 OF oDlgLote PIXEL //"- Retenções"
	@ nUltLin,204 MSGET __oRetMot VAR __nTotImp	SIZE 66, 08 OF oDlgLote PIXEL HASBUTTON Picture PesqPict("SE1","E1_VALLIQ")  ;
	Valid .T. When .F.
EndIf

//Valores Acessorios
If lPodeTVA .and. lExistVA
	nUltLin +=12
	@ nUltLin,144 SAY "+ "+ STR0274		SIZE 53,07 OF oDlgLote PIXEL	//"+ Valores Acessórios"
	@ nUltLin,204 MSGET oVA VAR nVA	SIZE 66, 08 OF oDlgLote PIXEL HASBUTTON Picture PesqPict("FKD","FKD_VALOR") When  .F.
	nOldVA := nVA
Endif

nUltLin += 12
@ nUltLin,144 SAY STR0033 SIZE 53,07 OF oDlgLote PIXEL //"= Valor Recebido"
@ nUltLin,204 MSGET oValRec VAR nValRec SIZE 65, 08 OF oDlgLote PIXEL HASBUTTON Picture PesqPict( "SE1","E1_VALOR" )  ;//"@E 999,999,999,999.99"
			Valid IIF( SE1->E1_MOEDA == 1,;
					( u_xFA070ValRec(oJuros,oMulta,oProRata,oDescont,,,, aTitCalc), nValEstrang := nValRec , oVlEstrang:Refresh()),;
					( oValRec:Refresh() , Fa070ValVR(nTxMoeda) , oVlEstrang:Refresh() , oCM:Refresh()) )

nUltLin += 12
@ nUltLin,144 SAY STR0034+cDescMoeda SIZE 53, 7 OF oDlgLote PIXEL // "Valor "
@ nUltLin,204 MSGET oVlEstrang VAR nValEstrang SIZE 65, 08 OF oDlgLote PIXEL HASBUTTON Picture PesqPict( "SE1","E1_VALOR" )  When SE1->E1_MOEDA > 1  //"@E 999,999,999,999.99"

nUltLin += 12
@ nUltLin,144 SAY STR0032 SIZE 53,07 OF oDlgLote PIXEL // "+ Corr.Monet ria"
@ nUltLin,204 MSGET oCM     VAR nCM		SIZE 65, 08 OF oDlgLote PIXEL  HASBUTTON    Picture PesqPict( "SE1","E1_CORREC" )  ;// "@E 999,999,999,999.99"
												When SE1->E1_MOEDA > 1 .And. (IIf(GetMv("MV_CALCCM") == "S",.T.,.F.))

If lPanelFin
	ACTIVATE MSDIALOG oDlgLote ON INIT FaMyBar(oDlgLote,{||( nOpca := 1,;
						If(lFA070MDB.and. !lMdbOk,lMdbOk:=ExecBlock("FA070MDB",.F.,.F.),.t.) .and. ;
						IIf(UsaSeqCor() , FA070Diario(), .T. ) .and.;
						u_XFa070But(nOpca,nTolerPg,lMovBco,lJuros,@lBaixou,;
						@cTitulo,@oTitulo,@cParcela,@dEmissao,@oEmissao,;
						@dVencRea,@oVencRea,@cNomeCli,@oNomeCli,@cHist,@oHist,;
						@cSituacao,@oSituacao,@cBanco,@oBanco,@cAgencia,@oAgencia,;
						@cConta,@oConta,@oBaixa,@dDtCredito,@oDtCredito,;
						@cHist070,@oHist070,@cMotBx,@oMotBx,@nValor,@oValor,;
						@nTotAbLiq,@oTotAbLiq,@nTotAbImp,@oTotAbImp,@nParciais,@oParciais,@oDescont,;
						@oMulta,Iif(cPaisLoc <> "CHI",@oJuros,@oOtrga),@oValRec,@oValEstr,@oCMonet,@oDlgLote,;
						cMarca,@nTotal, @nHdlPrv, @lHdlPrv, @lPadrao,@cArquivo,;
						@cPadrao, aDescMotBx,@nAcresc,@oAcresc,@nDecresc,@oDecresc,@nAcrescF,@nDecrescF,;
						aModalSpb,@oModSpb,lSpbInUse,nTxMoeda,@oMultNat,@lMultNat,@nTotLtEZ,@nValorLiq,@oValorLiq,.T.,;
						@oPrefixo,@oParcela,@oTipo,@aDiario,lPccBxCr,@oPis,@oCofins,@oCsll,;
						@nOldDescont,@nOldMulta,@nOldJuros,@nOldPis,@nOldCofins,@nOldCsll, @lIrPjBxCr, @nIrrf,@oIrrf, @nOldIrrf,;
						@oVA,@aFlagCTB, aTitCalc))},;
                  {||( nOpca := 0 ,;
						U_XFa070But(nOpca,nTolerPg,lMovBco,lJuros,@lBaixou,;
						@cTitulo,@oTitulo,@cParcela,@dEmissao,@oEmissao,;
						@dVencRea,@oVencRea,@cNomeCli,@oNomeCli,@cHist,@oHist,;
						@cSituacao,@oSituacao,@cBanco,@oBanco,@cAgencia,@oAgencia,;
						@cConta,@oConta,@oBaixa,@dDtCredito,@oDtCredito,;
						@cHist070,@oHist070,@cMotBx,@oMotBx,@nValor,@oValor,;
						@nTotAbLiq,@oTotAbLiq,@nTotAbImp,@oTotAbImp,@nParciais,@oParciais,@oDescont,;
						@oMulta,Iif(cPaisLoc <> "CHI",@oJuros,@oOtrga),@oValRec,@oValEstr,@oCMonet,@oDlgLote,cMarca,;
						@nTotal, @nHdlPrv, @lHdlPrv, @lPadrao, @cArquivo,@cPadrao,;
						aDescmotBx,@nAcresc,@oAcresc,@nDecresc,@oDecresc,@nAcrescF,@nDecrescF,;
						aModalSpb,@oModSpb,lSpbInUse,nTxMoeda,@oMultNat,@lMultNat,@nTotLtEZ,@nValorLiq,@oValorLiq,.T.,;
						@oPrefixo,@oParcela,@oTipo,@aDiario,lPccBxCr,@oPis,@oCofins,@oCsll,;
						@nOldDescont,@nOldMulta,@nOldJuros,@nOldPis,@nOldCofins,@nOldCsll,@lIrPjBxCr, @nIrrf,@oIrrf, @nOldIrrf,;
						@oVA,@aFlagCTB, aTitCalc))},aButtons) CENTERED

Else

	ACTIVATE MSDIALOG oDlgLote ON INIT EnchoiceBar(oDlgLote,{|| ( nOpca := 1,;
						If(lFA070MDB.and. !lMdbOk,lMdbOk:=ExecBlock("FA070MDB",.F.,.F.),.t.) .and. ;
						IIf(UsaSeqCor() , FA070Diario(), .T. ) .and.;
						U_XFa070But(nOpca,nTolerPg,lMovBco,lJuros,@lBaixou,;
						@cTitulo,@oTitulo,@cParcela,@dEmissao,@oEmissao,;
						@dVencRea,@oVencRea,@cNomeCli,@oNomeCli,@cHist,@oHist,;
						@cSituacao,@oSituacao,@cBanco,@oBanco,@cAgencia,@oAgencia,;
						@cConta,@oConta,@oBaixa,@dDtCredito,@oDtCredito,;
						@cHist070,@oHist070,@cMotBx,@oMotBx,@nValor,@oValor,;
						@nTotAbLiq,@oTotAbLiq,@nTotAbImp,@oTotAbImp,@nParciais,@oParciais,@oDescont,;
						@oMulta,Iif(cPaisLoc <> "CHI",@oJuros,@oOtrga),@oValRec,@oValEstr,@oCMonet,@oDlgLote,;
						cMarca,@nTotal, @nHdlPrv, @lHdlPrv, @lPadrao,@cArquivo,;
						@cPadrao, aDescMotBx,@nAcresc,@oAcresc,@nDecresc,@oDecresc,@nAcrescF,@nDecrescF,;
						aModalSpb,@oModSpb,lSpbInUse,nTxMoeda,@oMultNat,@lMultNat,@nTotLtEZ,@nValorLiq,@oValorLiq,.T.,;
						@oPrefixo,@oParcela,@oTipo,@aDiario,lPccBxCr,@oPis,@oCofins,@oCsll,;
						@nOldDescont,@nOldMulta,@nOldJuros,@nOldPis,@nOldCofins,@nOldCsll, @lIrPjBxCr, @nIrrf,@oIrrf, @nOldIrrf,;
						@oVA,@aFlagCTB, aTitCalc))},;
                  {||( nOpca := 0 ,;
						U_XFa070But(nOpca,nTolerPg,lMovBco,lJuros,@lBaixou,;
						@cTitulo,@oTitulo,@cParcela,@dEmissao,@oEmissao,;
						@dVencRea,@oVencRea,@cNomeCli,@oNomeCli,@cHist,@oHist,;
						@cSituacao,@oSituacao,@cBanco,@oBanco,@cAgencia,@oAgencia,;
						@cConta,@oConta,@oBaixa,@dDtCredito,@oDtCredito,;
						@cHist070,@oHist070,@cMotBx,@oMotBx,@nValor,@oValor,;
						@nTotAbLiq,@oTotAbLiq,@nTotAbImp,@oTotAbImp,@nParciais,@oParciais,@oDescont,;
						@oMulta,Iif(cPaisLoc <> "CHI",@oJuros,@oOtrga),@oValRec,@oValEstr,@oCMonet,@oDlgLote,cMarca,;
						@nTotal, @nHdlPrv, @lHdlPrv, @lPadrao, @cArquivo,@cPadrao,;
						aDescmotBx,@nAcresc,@oAcresc,@nDecresc,@oDecresc,@nAcrescF,@nDecrescF,;
						aModalSpb,@oModSpb,lSpbInUse,nTxMoeda,@oMultNat,@lMultNat,@nTotLtEZ,@nValorLiq,@oValorLiq,.T.,;
						@oPrefixo,@oParcela,@oTipo,@aDiario,lPccBxCr,@oPis,@oCofins,@oCsll,;
						@nOldDescont,@nOldMulta,@nOldJuros,@nOldPis,@nOldCofins,@nOldCsll, @lIrPjBxCr, @nIrrf,@oIrrf, @nOldIrrf,;
						@oVA,@aFlagCTB, aTitCalc))},,aButtons ) CENTERED
Endif

SetKey(VK_F4,bSetKey)
Return lBaixou

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fA070OK   ³ Autor ³ Wagner Xavier         ³ Data ³ 26/05/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se dados digitados esta OK                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fA070ok()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function XFa070OK(cBanco,cAgencia,cConta,nValRec,dBaixa,nJuros,nCM,nMulta,;
						nDescont,nTotAbat,nTolerPg,lMovBco,aDescMotBx,nAcresc,nDecresc,;
						lSpbInUse,nTxMoeda,nTotLtEZ,nVa)
										
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se nao foi alterado o banco quando for tit. em desconto.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( FN022SITCB(SE1->E1_SITUACA)[3] .And.;
	 cBanco+cAgencia+cConta!=SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA )
	Help(" ",1,"FINA070BCO")
	Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se valor da baixa ‚ maior que o valor m ximo a receber       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Str(nValRec,17,2) > Str(Round(NoRound(xMoeda(SE1->E1_SALDO-nTotAbat,SE1->E1_MOEDA,nMoedaBco,dBaixa,7,nTxMoeda),3),MsDecimais(SE1->E1_MOEDA))+Iif(Alltrim(SE1->E1_ORIGEM) == "FINA074",0,nJuros+nVa+nMulta-nDescont-nOtrga+nTolerPg+nAcresc-nDecresc),17,2)
    Help(" ",1,"ValorMaior")
    Return .F.
EndIf

dbSelectArea("SE1")
If Empty( cMotBx )
	cMotBx := aDescMotBx[nFirstRsn]  // Default posting reason
Endif

IF Empty(dBaixa) .or. (nValRec < 0 ) .or. Empty(cMotBx)
	Help(" ",1,"FA070INV")
	Return .F.
EndIF

If nDescont != Round(xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,nMoedaBco,dBaixa,3,nTxMoeda),2)
	If (nTotAbat=0.and.nValRec=0).or.(nValRec=0.and.nTotAbat!=SE1->E1_SALDO)
		Help(" ",1,"FA070INV")
		Return .F.
	EndIf
EndIF

If !FA070ValMo(lMovBco)
	Return .F.
EndIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se modalidade do SPB é valida.									    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lSpbInUse
	cModSpb := Substr(cModSpb,1,1)
	IF !(SpbTipo("SE1",cModSpb,SE1->E1_TIPO))
		Return .F.
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se data da baixa e valida                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF (dBaixa < SE1->E1_EMISSAO .OR. dBaixa > dDataBase) .and. !GetMv("MV_ANTCRED")
	Help( " ", 1, "DATAERR" )
	Return .F.
Endif
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FA070But  ³ Autor ³ Wagner Xavier         ³ Data ³ 26/05/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Recarrega Variaveis                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa070But()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function XFa070But(nOpca,nTolerPg,lMovBco,lJuros,lBaixou,;
						cTitulo,oTitulo,cParcela,dEmissao,oEmissao,;
						dVencRea,oVencRea,cNomeCli,oNomeCli,cHist,oHist,;
						cSituacao,oSituacao,cBanco,oBanco,cAgencia,oAgencia,;
						cConta,oConta,oBaixa,dDtCredito,oDtCredito,;
						cHist070,oHist070,cMotBx,oMotBx,nValor,oValor,;
						nTotAbLiq,oTotAbLiq,nTotAbImp,oTotAbImp,nParciais,oParciais,oDescont,;
						oMulta,oJuros,oValRec,oValEstr,oCMonet,oDlgLote,cMarca,;
						nTotal, nHdlPrv, lHdlPrv, lPadrao, cArquivo,cPadrao,aDescMotBx,;
						nAcresc,oAcresc,nDecresc,oDecresc,nAcrescF,nDecrescF,;
						aModalSpb,oModSpb,lSpbInUse,nTxMoeda,oMultNat,lMultNat,nTotLtEZ,nValorLiq,oValorLiq,lBxLote,;
						oPrefixo,oParcela,oTipo,aDiario,lPccBxCr,oPis,oCofins,oCsll,;
						nOldDescont,nOldMulta,nOldJuros,nOldPis,nOldCofins,nOldCsll, lIrPjBxCr, nIrrf,oIrrf, nOldIrrf,;
						oVA,aFlagCTB,aTitCalc)

Local nSalvRec
Local lRet			:= .T.
LOCAL lContabiliza	:= (mv_par04 == 1)
Local lOk			:= .F. //Controla se foi confirmada a distribuicao
Local aColsSEV		:= {}
Local lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Local x
LOCAL lBxLiq		:= .F.
LOCAL lBxCEC		:= .F.  //Verificador de existencia de baixa por compensacao entre carteiras
Local aBaixa		:= {}
LOCAL nVlrBaixa		:= 0
LOCAL lBaixaAbat	:= .F.
LOCAL nTotAdto		:= 0
Local lSaveState	:= ALTERA
Local aAlt			:= {}
Local aPcc			:= {}
Local nBase			:= 0
Local lJurMulDes	:= (SuperGetMv("MV_IMPBAIX",.t.,"2") == "1")
Local lExistVA 		:= TableInDic("FKD") .and. TableInDic("FKC")
Local lSDACRVL 		:= SuperGetMv("MV_SDACRVL",.T.,.F.)
Local lSDDECVL	 	:= .F.
Local lCalcIssBx 	:= GetNewPar("MV_MRETISS","1") == "2"  //Retencao do ISS pela emissao (1) ou baixa (2)

DEFAULT nTxMoeda 	:= 0
DEFAULT lBxLote 	:= .F.
DEFAULT lPccBxCr 	:= .F.
DEFAULT lIrPjBxCr 	:= .F.
DEFAULT aFlagCTB	:= {}
DEFAULT aTitCalc	:= {}

If Type("aImpos") == "U"
	aImpos := {}
EndIf

__nMRBxTot := 0

// Zerar variaveis para contabilizar os impostos da lei 10925.
VALOR5 := 0
VALOR6 := 0
VALOR7 := 0

If nOpca == 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada de Template para Confirmacao da Baixa       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistTemplate("FA070TIT")
		lRet := ExecTemplate("FA070TIT",.F.,.F.,{nParciais})
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada para Confirmacao da Baixa                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("FA070TIT")
		lRet := ExecBlock("FA070TIT",.F.,.F.,{nParciais})
	EndIf

	If !lRet
		Return lRet
	Else
		oDescont:Refresh()
		oMulta:Refresh()
		oJuros:Refresh()
		oValRec:Refresh()
		oAcresc:Refresh()
		oDecresc:Refresh()
		If lPodeTVA .and. lExistVA
			oVA:Refresh()
		EndIf
	EndIf

	If MovBcobx(cMotBx, .T.) .and. If(!FwIsInCallStack("FA450CMP") ,!u_xCarregaSA(cBanco,cAgencia,cConta,.T.,,.T.),.F.)
		Return .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se data do movimento ‚ menor que data limite de     ³
	//³ movimentacao no financeiro                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SuperGetMv("MV_BXDTFIN",,"1") == "2" .and.!DtMovFin(dDtCredito,,"2")
		Return
	EndIf

	If !U_xFa070OK(cBanco,cAgencia,cConta,nValRec,dBaixa,nJuros,;
			nCM,nMulta,nDescont,nTotAbat,nTolerPg,lMovBco,aDescMotBx,nAcresc,nDecresc,;
			lSpbInUse,nTxMoeda,,nVA)
		Return .F.
	EndIf
	nValPadrao := nValRec-(nJuros+nVa+Iif(SE1->E1_MOEDA<=1,nCM,0)+nMulta-nDescont+nAcresc-nDecresc)
	If Empty( cMotBx )
		cMotBx := aDescMotBx[nFirstRsn]  // Default posting reason
	Endif

	cPadrao   := fA070Pad()
	lPadrao   := VerPadrao(cPadrao)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicio da prote‡„o via TTS                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SE1")
	nRegSE1 := Recno()

	If MV_MULNATR .and. lMultNat
		MultNatB("SE1",.F.,STR(mv_par07,1),@lOk,@aColsSEV,@lMultNat)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa a gravacao dos lancamentos do SIGAPCO          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PcoIniLan("000004")

	Begin Transaction
		aHdlPrv	:= {}
		Aadd(aHdlPrv,{nHdlPrv,cPadrao,aFlagCTB,cArquivo})
		lSaveState := ALTERA
		lBaixou := fA070Grv(lPadrao,Nil,NIl,Nil,Nil,dDtCredito,lJuros,Nil,Nil,nTxMoeda,mv_par08==1,{},aHdlPrv,.F.,lMultNat,, aImpos,__lPccMR,__lIrfMR,__lInsMR,__lIssMR,__lGlosaMr,__lImpMR, aTitCalc) //Nil=Arquivo Cnab//Nil=Arquivo Cnab
		ALTERA := lSaveState
		dbSelectArea("SE1")
		dbGoTo(nRegSE1)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Soma nos totalizadores, exceto se a situa‡„o do t¡tulo for:     ³
		//³2 - Cobran‡a Descontada   ou   7 - Cobranca Cau‡„o Descontada   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF !(FN022SITCB(SE1->E1_SITUACA)[3])
			nTotAGer  += nValRec
			nTotADesc += nDescont+nDecresc
			nTotAMul  += nMulta
			nTotAJur  += nJuros+nAcresc
			nTotADesp += Iif(SE1->E1_MOEDA<=1,nCM,0)
		Endif

		// Verifica se esta utilizando multiplas naturezas
		// Chama rotina de gravacao do SEV e SEZ
		If MV_MULNATR .and. lMultNat .and. lOk
			MultNatC("SE1",@nHdlPrv,@nTotal,@cArquivo,lContabiliza,.T.,STR(mv_par07,1),@nTotLtEZ,lOk,aColsSEV,lBaixou)
			lHdlPrv := nHdlPrv > 0
		Endif

		If lBaixou

			/*
			Atualiza o status do titulo no SERASA */
			If cPaisLoc == "BRA"
				If SE1->E1_SALDO <= 0
					cChaveTit := xFilial("SE1") + "|" +;
								SE1->E1_PREFIXO + "|" +;
								SE1->E1_NUM		+ "|" +;
								SE1->E1_PARCELA + "|" +;
								SE1->E1_TIPO	+ "|" +;
								SE1->E1_CLIENTE + "|" +;
								SE1->E1_LOJA
					cChaveFK7 := FINGRVFK7("SE1",cChaveTit)
					F770BxRen("1",TrazCodMot(cMotBx),cChaveFK7)
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava os cheques no SEF ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			GravaChqCR(SE5->E5_SEQ,"FINA070")

			//-----------------------------------------------------------
			//Valores Acessorios.
			//-----------------------------------------------------------
			If lPodeTVA .and. lExistVA
				FAtuFKDBx()
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			F070PcoDet()
			///numbor
			aAlt := {}
		    aadd( aAlt,{ STR0261,'','','',STR0262 +  Alltrim(cLoteFin) + STR0263 + Alltrim(Transform(SE5->E5_VALOR,PesqPict("SE5","E5_VALOR"))) })
			///chamada da Função que cria o Histórico de Cobrança
			DbSelectArea("SE1")
			FinaCONC(aAlt)

		EndIf

		If lBaixou .and. lContabiliza .and. !lMultNat

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Localizacao Portugal - Gera dados para diario contabil ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If UsaSeqCor()
				AAdd( aDiario, {"SE5",SE5->(Recno()),cCodDiario,"E5_NODIA","E5_DIACTB"} )
			Else
				aDiario := {}
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica qual o Lanc Padr„o que sera utilizado 	  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cPadrao := fa070Pad()
			lPadrao:=VerPadrao(cPadrao)
			IF !lHdlPrv .And. lPadrao
		 		nHdlPrv:=HeadProva(cLote,"FINA070",Substr(cUsuario,7,6),@cArquivo)
				lHdlPrv := .T.
			EndIF
			If lPadrao .and. lHdlPrv .and. !FwIsInCallStack("Fa450Can")
				VALOR := 0
				ABATIMENTO := Round(NoRound(xMoeda(nTotAbat,SE1->E1_MOEDA,nMoedaBco,dBaixa,3),3),2)

				If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
					aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
					aAdd( aFlagCTB, {"FK1_LA", "S", "FK1", FK1->( Recno() ), 0, 0, 0} )
				Endif
				nTotal += DetProva( nHdlPrv, cPadrao, "FINA070", cLote, /*nLinha*/, /*lExecuta*/,;
				                    /*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/,;
				                    /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ )

			EndIf

		EndIf

		If !lFini055 .and. FWHasEAI("FINA070",.T.,,.T.)
			FwIntegDef( 'FINA070' )
		Endif
		// Integração SIGAPFS x SIGAFIN
		If lBaixou .And. FindFunction("JGrvBaixa")
			lBaixou := JGrvBaixa(SE1->(Recno()), SE5->(Recno()))

			If !lBaixou
				DisarmTransaction()
			EndIf
		EndIf
	End Transaction

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a gravacao dos lancamentos do SIGAPCO          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PcoFinLan("000004")

	If ExistBlock ("F070BXLT")
		ExecBlock ("F070BXLT",.F.,.F.,{lBxLote})
	EndIF

	dbSelectArea("SE1")
	dbGoTo(nRegSE1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Integracao protheus X tin Baixa por Lote	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpa marca para titulo com baixa abortada.                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAliasLote)
	Begin Transaction
		RecLock (cAliasLote,.F.)
		Replace E1_OK with ""
	End Transaction
Endif

//Posiciono no próximo registro do TRB
(cAliasLote)->(dbSKip())
While (cAliasLote)->(!Eof())
	If (cAliasLote)->E1_OK != cMarca .or. (cAliasLote)->E1_TIPO $ MVABATIM+"/"+MVFUABT //adicionado MVFUABT pois a variável MVABATIM não está retornando FU-
		(cAliasLote)->(dbSKip())
		Loop
	Else
		SE1->(dbGoto((cAliasLote)->RECNOSE1))
		Exit
	EndIf
EndDO

If (cAliasLote)->(Eof())
	oDlgLote:End()
	Return lBaixou
EndIf

__lCalcImp := .F.	

If __lBordImp .And. !Empty(SE1->E1_NUMBOR)
	__lCalcImp := BorderoImp(SE1->E1_FILORIG, SE1->E1_NUMBOR, "R", SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
EndIf

If __lFPIXatv .And. !__lCalcImp .And. !__lCnabImp
	__lCalcImp := PIXIsActiv()
EndIf

// Posiciona Natureza no SED
SED->(dbSetOrder(1))
SED->(MSSeek(xFilial("SED")+SE1->E1_NATUREZ))

// Posiciona Cliente no SA1
SA1->(MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
dbSelectArea("SE1")
lIrPjBxCr	:= FIrPjBxCr(.T.)

//Carrega Variaveis da Baixa
cTitulo		:= SE1->E1_NUM
cParcela	:= SE1->E1_PARCELA
dEmissao	:= SE1->E1_EMISSAO
dVencRea	:= SE1->E1_VENCREA
cNomeCli	:= SE1->E1_CLIENTE + " - " + Subst(SA1->A1_NOME,1,40)
cHist		:= SE1->E1_HIST
cSituacao	:= SE1->E1_SITUACA + " " + fa070situa()
dBaixa		:= CriaVar("E1_BAIXA")
dDtCredito  := dDataBase
cHist070	:= Criavar("E5_HISTOR")		//Inicilizador padrao
If Empty(cHist070)
	cHist070 := STR0007+Space(Len(cHist070)-24)  // "Valor recebido s/ T¡tulo"
Endif
nValor		:= SE1->E1_VALOR
dbSelectArea("SE1")
nSalvRec 	:= Recno()
nTotAbImp   := 0
nTotAbLiq   := 0
nTotAbat		:= SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"S",dBaixa,@nTotAbImp)
dbSelectArea("SE1")
dbGoto(nSalvRec)
nDescont    := 0
nMulta      := 0
nJuros      := 0
nCM         := 0
nVa			:= 0 //Valores Acessórios
nAcrescF		:= SE1->E1_SDACRES
If ExistBlock("F070ACRE")
	ExecBlock("F070ACRE",.F.,.F.)
Endif
If AllTrim(Type("cLoteFin")) == "C"
	If !Empty(AllTrim(cLoteFin))
		nTotAbLiq := nTotAbat
	EndIf
EndIf
nDeCrescF 	:= SE1->E1_SDDECRE
nValorLiq 	:= SE1->E1_VALOR - nTotAbLiq - nTotAbImp
nAcresc   	:= Round(NoRound(xMoeda(nAcrescF,SE1->E1_MOEDA,nMoedaBco,dBaixa,3),3),2)
nDecresc  	:= Round(NoRound(xMoeda(SE1->E1_SDDECRE,SE1->E1_MOEDA,nMoedaBco,dBaixa,3),3),2)
nValrec   	:= Round(Noround(xMoeda(SE1->E1_SALDO-nTotAbat,SE1->E1_MOEDA,nMoedaBco,dBaixa,3),3),2)+nMulta+nJuros+nVa-nDescont+nAcresc-nDecresc-nPis-nCofins-nCsll
nPIS      	:= 0
nCOFINS   	:= 0
nCSLL	  	:= 0
nIrrf	  	:= 0
nParciais 	:= 0
aBaixaSE5	:={}
//***Reestruturacao SE5***
nPisCalc	:= 0
nCofCalc	:= 0
nCslCalc	:= 0
nIrfCalc	:= 0
nIssCalc	:= 0
nPisBaseR 	:= 0
nCofBaseR	:= 0
nCslBaseR 	:= 0
nIrfBaseR 	:= 0
nIssBaseR 	:= 0
nPisBaseC 	:= 0
nCofBaseC 	:= 0
nCslBaseC 	:= 0
nIrfBaseC 	:= 0
nIssBaseC 	:= 0

If __lTemMR .And. __lImpMR .And. !__lCalcImp
	aImpos := F070VldImp(nValRec, dBaixa,@lPccBxCr, @lIrPjBxCr, @lCalcIssBx,@__lImpMR)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Para que o valor da baixa parcial nao fique negativo, verifico o saldo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (SE1->E1_VALOR > SE1->E1_SALDO) .And. Empty(SE1->E1_TIPOLIQ)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Procura pelas baixas deste titulo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lTipBxCP:=lRaRtImp
	aBaixa := Sel070Baixa("VL /V2 /BA /RA /CP /LJ /" + MV_CRNEG, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO,;
					@nTotAdto, @lBaixaAbat, SE1->E1_CLIENTE, SE1->E1_LOJA, @nVlrBaixa, , @lBxCec, @lBxLiq,,.T.)
	For x := 1 To Len(aBaixaSE5)
		If aBaixaSE5[x][1]+substr(aBaixaSE5[x][2],1,TamSX3("E1_NUM")[1])+aBaixaSE5[x][3]+aBaixaSE5[x][4]+aBaixaSE5[x][5]+aBaixaSE5[x][6]== SE1->E1_PREFIXO+ SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA
			nParciais += aBaixaSE5[x][8]
	        If lPccBxCR .And. lRaRtImp .and. !(aBaixaSE5[x][21]$ "1|2")
			   nParciais += aBaixaSE5[x][18]+aBaixaSE5[x][19]+aBaixaSE5[x][20]+aBaixaSE5[x][30]// somar impostos PCC
			Elseif lIrPjBxCr .And. lRaRtImp
		  		nParciais += aBaixaSE5[x][30]
			Endif
			If lRaRtImp
		 		nParciais += aBaixaSE5[x][32]+aBaixaSE5[x][33]
		 		nTotAbat  -= aBaixaSE5[x][32]+aBaixaSE5[x][33]
			Endif
		Endif

		//Verifica baixas parciais no caso de desconto.
		If ABAIXASE5[x][16] > 0 .and. lSDACRVL
			nParciais += ABAIXASE5[x][16]
		Endif
		//
	Next
	nParciais += nTotAdto
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Soma valor de decrescimo em baixas parciais, para evitar         ³
	//³ diferencas entre valor original e valor recebido                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SE1->E1_SDDECRE <> SE1->E1_DECRESC
		If SE1->E1_SDDECRE = 0
			lSDDECVL := .T.
			If lSDACRVL
				nParciais -= SE1->E1_DECRESC
			Endif
		Else
			If lSDACRVL
				nParciais += ( SE1->E1_DECRESC - SE1->E1_SDDECRE )
			Endif
		Endif
	EndIf
Else
	nParciais 	:= SE1->E1_VALOR-SE1->E1_SALDO
Endif

If	lIrPjBxCr
	nValRec  := SE1->E1_VALOR - nParciais
	If !__lIrfMR
		nIrrf:= Iif(cPaisLoc == "BRA" .And. !__lCalcImp, FCaIrBxCR(nValRec), 0)
		nOldIrrf := nIrrf
	ElseIf __lTemMR .And. __lIrfMR .And. !__lCalcImp
		aImpos:= F070VldImp(nValRec, dBaixa)
 	EndIf
EndIf

//PCC Baixa CR
If lPccBxCR
	nParciais += nPis + nCofins + nCsll

    If SE1->E1_MOEDA > 1
		nValRec:= xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,1,dDatabase,3,nTxMoeda)
		nValRec:= nValRec - nParciais
	Else
		nValRec := SE1->E1_VALOR - nParciais
	EndIf

	nOldValRec	:= nValRec
	
	If dBaixa < dLastPcc
		f070TotMes(dBaixa,.T.,,.F.)
	Else
		nBase	:= FBaseRPCC(nValRec)
		
		If !lJurMulDes .And. (nBase+nDescont-nJuros-nVa-nMulta-nAcresc+nDecresc > 0)
			nBase 	:= nBase+nDescont-nJuros-nVa-nMulta-nAcresc+nDecresc
		EndIf

		aTitCalc := {}
		
		If !__lCalcImp
			If !__lPccMR .And. !SE1->E1_TIPO $ MVRECANT
				aPcc	:= newMinPcc(dBaixa, nBase,SE1->E1_NATUREZ,"R",SA1->A1_COD+SA1->A1_LOJA,,,,,,cMotBx)
				nPis	:= aPcc[2]
				nCofins	:= aPcc[3]
				nCsll	:= aPcc[4]
	
				If len(aPCC) > 4
					aTitCalc := aPCC[5]
				Endif
	
				nOldPis     := nPis
				nOldCofins  := nCofins
				nOldCsll    := nCsll
			ElseIf __lTemMR .And. __lPccMR
				aImpos:= F070VldImp(nValRec, dBaixa)
			Endif
		Endif
	EndIf
Endif

fa070val( nValrec, nTxMoeda )

cMoeda 		:= IIF(Empty(SE1->E1_MOEDA),"1",AllTrim(Str(SE1->E1_MOEDA,2)))
cDescMoeda 	:= SubStr(GetMV("MV_SIMB"+cMoeda),1,3)
lMultNat		:= .F.

IF ExistBlock("F070MNAT")
	lMultNat := ExecBlock("F070MNAT",.F.,.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trecho incluido para integração e-commerce          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  LJ861EC01(SE1->E1_NUM, SE1->E1_PREFIXO, .T./*PrecisaTerPedido*/,SE1->E1_FILORIG)
	LJ861EC02(SE1->E1_NUM, SE1->E1_PREFIXO,SE1->E1_FILORIG)
EndIf

// Calcula o desconto e o juros (se houver) e valida a data
fA070Data(@nTxMoeda,.F.,/*oDtBaixa*/,/*oJuros*/,/*oCbx*/,/*lReclcJur*/,/*oVa*/,/*aImpos*/,/*lMudouMulta*/, aTitCalc)

oPrefixo:Refresh()
oTitulo:Refresh()
oParcela:Refresh()
oTipo:Refresh()
oEmissao:Refresh()
oVencRea:Refresh()
oNomeCli:Refresh()
oHist:Refresh()
oSituacao:Refresh()
oBanco:Refresh()
oBanco:SetFocus()
oAgencia:Refresh()
oConta:Refresh()
oBaixa:Refresh()
oDtCredito:Refresh()
oHist070:Refresh()
oMotBx:Refresh()
oMotBx:SetFocus()
oValor:Refresh()
IF cPaisLoc <> "CHI"
	oTotAbLiq:Refresh()
Endif
If cPaisLoc == "BRA"
	oTotAbImp:Refresh()
	oValorLiq:Refresh()
	If lPccBxCr
		nOldPis		:= nPis
		nOldCofins	:= nCofins
		nOldCsll		:= nCsll
		oPis:Refresh()
		oCofins:Refresh()
		oCsll:Refresh()
	Endif
	If lIrPjBxCr
 		oIrrf:Refresh()
 	Endif
Endif
oParciais:Refresh()
oDescont:Refresh()
oMulta:Refresh()
oJuros:Refresh()
If lPodeTVA .and. lExistVA
	oVA:Refresh()		//Valores Acessorios
Endif
oValRec:Refresh()
oAcresc:Refresh()
oDecresc:Refresh()

If !__lPyme
	oMultNat:Refresh()
EndIf

If SE1->E1_MOEDA > 1
	oVlEstrang:Refresh()
	oCM:Refresh()
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pr‚-inicializa a modalidade de SPB                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lSpbInUse
	If !Empty(SE1->E1_MODSPB)
		cModSpb := SE1->E1_MODSPB
	Else
	   cModSpb := "1"
	Endif
	oModSpb:Refresh()
Endif

nOldDescont := nDescont
nOldMulta 	:= nMulta
nOldJuros	:= nJuros
nOldVA		:= nVa

Return lBaixou

//-------------------------------------------------------------------------
/*/{Protheus.doc} fA070Grava
Grava as baixas em Lote

@author Mauricio Pequim Jr
@since  06/01/2016
@version 12.1.7
/*/
//-------------------------------------------------------------------------
User Function xfA070Grava(dDtCredito)

LOCAL cArquivo
LOCAL lDigita	:= (mv_par01 == 1)
Local nTotal	:= 0
Local nHdlPrv	:= 0
LOCAL lAglut 	:= (mv_par02 == 1)
Local cPadrao	:= ""
Local lPadrao 	:= .F.
LOCAL nRecSe1	:= 0
LOCAL lContabiliza := (mv_par04 == 1)
Local cLoteOrig	:= ""
Local lHdlPrv 	:= .F.
Local dDataDisp	:= CTOD("//")
Local nRetencao	:= 0
Local nCont		:= 0
Local lSpbInUse	:= SpbInUse()
Local lF070DtCr	:= ExistBlock("F070DTCR")
Local nTotLtEZ	:= 0	//Totalizador da Bx Lote Mult Nat CC
Local nRecSeV	:= 0
Local nRecSeZ	:= 0
Local aDiario	:= {}
Local aFlagCTB	:= {}
Local lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Local lTpDesc	:= (cPaisLoc == "BRA") //Verifica campo TPDESC na tabela SE5 (<C>ondicional ou <I>ncondicional)
//***Reestruturação SE5***
Local oModelMvR	:= FWLoadModel("FINM030")
Local oSubFK5	:= oModelMvR:GetModel("FK5DETAIL")
Local oSubFKA	:= oModelMvR:GetModel("FKADETAIL")
Local oModelMvRI   := Nil 
Local oSubFK5Ax	 := Nil 
Local oSubFKAAx	 := Nil 
Local cLog		:= ""
Local cCamposE5	:= ""
Local cQuery := ""
Local cAliasQry := ""
Local nRecSE5	:= 0
Local nRecFK5	:= 0
Local nRecFK1	:= 0
Local lRuSkipChk :=.F. 

//***Reestruturação SE5***

DEFAULT dDtCredito := dDataBase

If Type("cTpDesc") == "U"
	cTpDesc:="I"
Endif

// Zerar variaveis para contabilizar os impostos da lei 10925.
VALOR5 := 0
VALOR6 := 0
VALOR7 := 0

//-------------------------------------------------------------------------
// Caso o usuario configure que deseja usar o lote financeiro, o
// sistema becapeia o lote cont bil original e depois o restaura.
//-------------------------------------------------------------------------


cLoteOrig := cLote
If GetMv("MV_LOTEFIN") == "S" .and. !Empty( cLoteFin )
	//-------------------------------------------------------------------------
	// Somente atualiza o lote contabil com o lote financeiro se o tamanho do
	// lote financeiro for menor ou igual ao do lote contabil.
	//-------------------------------------------------------------------------
	If TamSX3("E1_LOTE")[1] > 4 .And. TamSX3("E1_LOTE")[1] <= TamSX3( "CT2_LOTE" )[1]
		cLote := cLoteFin
	EndIf
Endif

//-------------------------------------------------------------------------
// O processo os titulos a serem baixado no lote
//-------------------------------------------------------------------------
dbSelectArea(cAliasLote)
(cAliasLote)->(dbGoTop())

While !(cAliasLote)->(Eof())
	SE1->(dbGoto((cAliasLote)->RECNOSE1))
	U_XFa070(cMarca,@nTotal,@nHdlPrv,@lHdlPrv,@lPadrao,@cArquivo,@cPadrao,@nTotLtEZ,@aDiario,@aFlagCTB)
EndDo

//-------------------------------------------------------------------------
// Gera saldo banc rio totalizador, quando baixa p/lote
//-------------------------------------------------------------------------
If (nTotAGer > 0 )

	If lF070DtCr		// permite simular outra data base / data credito
		dDtCredito := Execblock("F070DTCR",.F.,.F.,dDtCredito)
	Endif

	//-------------------------------------------------------------------------
	// Grava registro totalizador da movimenta‡„o banc ria
	//-------------------------------------------------------------------------
	If mv_par09 == 1
		If GetNewPar("MV_RETLTBX","1") == "1"		//1=Sim, 2=Nao
			//   Data de disponibilizacao -> considera dias de retencao
			nRetencao  := SA6->A6_RETENCA
			if nRetencao > 0
				For nCont := 1 To nRetencao
					dDtCredito := DataValida(dDtCredito+1,.T.)
				Next nCont
			EndiF
		Endif
	Else
		nRetencao := 0
	EndIf

	//Pega o valor correto do totalizador da baixa em lote
	cQuery := "SELECT SUM(FK1_VALOR) TOTBL FROM " + RetSQLName("FK1")
	cQuery += " WHERE  FK1_FILIAL = '" + FWxFilial("FK1") + "'"
	cQuery += " AND FK1_LOTE = '" + cLoteFin + "'"
	cQuery += " AND FK1_RECPAG = 'R'"
	cQuery += " AND FK1_TPDOC = 'BA'"
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery( cQuery )

	cAliasQry := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )
	If ( cAliasQry )->( !EOF() )
		nTotAGer := ( cAliasQry )->TOTBL
	Endif
	( cAliasQry )->( DbCloseArea() )

	cCamposE5 += "{"
	If lTpDesc
		cCamposE5 += "{'E5_TPDESC'  , '" + cTpDesc + "' },"
	Endif
	cCamposE5 += "{'E5_DTDIGIT',StoD('" + DtoS(dDtCredito) + "')}"
	cCamposE5 += ",{'E5_LOTE','" + cLoteFin + "'}"
	cCamposE5 += "}"

	//Inicializo os models
	oModelMvR:SetOperation( MODEL_OPERATION_INSERT ) //Inclusao
	oModelMvR:Activate()
	oModelMvR:SetValue( "MASTER", "E5_GRV", .T. ) //Informa se vai gravar SE5 ou não
	oModelMvR:SetValue( "MASTER", "NOVOPROC", .T. ) //Novo processo
	oModelMvR:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 ) //Informa os campos da SE5 que serão gravados indepentes de FK5

	If !oSubFKA:IsEmpty()
		//Inclui a quantidade de linhas necessárias
		oSubFKA:AddLine()
		//Vai para linha criada
		oSubFKA:GoLine( oSubFKA:Length() )
	Endif
	oSubFKA:SetValue( "FKA_IDORIG"	, FWUUIDV4() )
	oSubFKA:SetValue( "FKA_TABORI"	, "FK5" )
	If Empty(cNaturLote)
		cNaturLote := FINNATMOV("R")
	Endif
	oSubFK5:SetValue( "FK5_BANCO"	, cBancolt )
	oSubFK5:SetValue( "FK5_AGENCI"	, cAgencialt )
	oSubFK5:SetValue( "FK5_CONTA"	, cContalt )
	oSubFK5:SetValue( "FK5_RECPAG" 	, "R" )
	oSubFK5:SetValue( "FK5_HISTOR"	, STR0130 + cLoteFin )
	oSubFK5:SetValue( "FK5_DATA"	, dDtCredito )
	oSubFK5:SetValue( "FK5_TPDOC"	, "BL" )
	oSubFK5:SetValue( "FK5_LOTE"	, cLoteFin )
	oSubFK5:SetValue( "FK5_VALOR"	, nTotAGer )
	oSubFK5:SetValue( "FK5_NATURE"	, cNaturLote )
	oSubFK5:SetValue( "FK5_FILORI"	, xFilial("SE1") )
	oSubFK5:SetValue( "FK5_DTDISP"	, dDtCredito )
	oSubFK5:SetValue( "FK5_ORIGEM"	, "FINA070" )
	If lSpbInUse
		// Se houver retencao ModSpb = Comp, caso contrario, STR
		oSubFK5:SetValue("FK5_MODSPB"	,IIF(SE5->E5_DTDISPO > dDataBase,"3","1") )
	Endif
	oSubFK5:SetValue("FK5_MOEDA"	,StrZero(nMoedaBco,2) )
	oSubFK5:SetValue("FK5_LA"		,IIf((lContabiliza .And. lPadrao .And. lHdlPrv) .Or. nHdlPrv > 0,'S','') )

	If oModelMvR:VldData()
	    oModelMvR:CommitData()
	Else
	    cLog := cValToChar(oModelMvR:GetErrorMessage()[4]) + ' - '
	    cLog += cValToChar(oModelMvR:GetErrorMessage()[5]) + ' - '
	    cLog += cValToChar(oModelMvR:GetErrorMessage()[6])

	    Help( ,,"M030VLDA1",,cLog, 1, 0 )
	Endif
	oModelMvR:DeActivate()
	oModelMvR:Destroy()
	oModelMvR := Nil

	AtuSalBco( cBancolt, cAgencialt, cContalt, dDtCredito, nTotAGer, "+" )

	If cPaisLoc $ "ARG|POR|EUA|ANG|COL|MEX"
		//-------------------------------------------------------------------------
		// Gerar a Movimentacao Bancaria na 2a. Moeda.
		//-------------------------------------------------------------------------
		nRetencao := SA6->A6_RETENCA
		If !Empty(SA6->A6_MOEDA) .and. ( SA6->A6_MOEDA != SE1->E1_MOEDA )
			AtuSalBco( cBancolt, cAgencialt, cContalt, dDataBase, nTotAGer, "+" )

			If nRetencao > 0
				For nCont := 1 To nRetencao
					dDataDisp := DataValida(dDataDisp+1,.T.)
				Next nCont
			EndIf

			//Inicializo os models
			oModelMvRI := FWLoadModel("FINM030")
			oModelMvRI:SetOperation(MODEL_OPERATION_INSERT) //Inclusao
			oModelMvRI:Activate()
			oModelMvRI:SetValue("MASTER","E5_GRV",.T.) //Informa se vai gravar SE5 ou não
			oModelMvRI:SetValue("MASTER","E5_CAMPOS",cCamposE5) //Informa os campos da SE5 que serão gravados indepentes de FK5

			cCamposE5 := "{{'E5_DTDIGIT',dDataBase}"
			cCamposE5 += ",{'E5_LOTE','" + cLoteFin + "'}}"

			If !oSubFKAAx:IsEmpty()
				//Inclui a quantidade de linhas necessárias
				oSubFKAAx:AddLine()
				//Vai para linha criada
				oSubFKAAx:GoLine( oSubFKA:Length() )
			Endif
			oSubFKAAx:SetValue( 'FKA_IDORIG', FWUUIDV4() )
			oSubFKAAx:SetValue( 'FKA_TABORI', "FK5" )

			oSubFK5Ax:SetValue("FK5_FILIAL"	, cFilial )
			oSubFK5Ax:SetValue("FK5_BANCO"	, cBancolt )
			oSubFK5Ax:SetValue("FK5_AGENCI"	, cAgencialt )
			oSubFK5Ax:SetValue("FK5_CONTA"	, cContalt )
			oSubFK5Ax:SetValue("FK5_RECPAG"	, "R" )
			oSubFK5Ax:SetValue("FK5_HISTOR"	, STR0001 + cLoteFin )
			oSubFK5Ax:SetValue("FK5_DATA"	, dDataBase )
			oSubFK5Ax:SetValue("FK5_TPDOC"	, "BL" )
			oSubFK5Ax:SetValue("FK5_LOTE"	, cLoteFin )
			oSubFK5Ax:SetValue("FK5_VALOR"	, xMoeda( nTotAGer, nMoedaBco, SA6->A6_MOEDA, dDataBase ) )
			oSubFK5Ax:SetValue("FK5_NATURE"	, cNaturLote )
			oSubFK5Ax:SetValue("FK5_FILORI"	, cFilial )
			oSubFK5Ax:SetValue("FK5_DTDISP"	, Iif( Empty(dDtCredito), dDataDisp, dDtCredito ) )
			oSubFK5Ax:SetValue("FK5_MOEDA"	, StrZero( SA6->A6_MOEDA, 2 ) )
			oSubFK5Ax:SetValue("FK5_ORIGEM"	, "FINA070" )

			If oModelMvRI:VldData()
			    oModelMvRI:CommitData()
			Else
			    cLog := cValToChar(oModelMvRI:GetErrorMessage()[4]) + ' - '
			    cLog += cValToChar(oModelMvRI:GetErrorMessage()[5]) + ' - '
			    cLog += cValToChar(oModelMvRI:GetErrorMessage()[6])

			    Help( ,,"M030VLDA1",,cLog, 1, 0 )
			Endif
		EndIf
		oModelMvRI:DeActivate()
		oModelMvRI:Destroy()
		oModelMvRI:= Nil
	Endif

	//-------------------------------------------------------------------------
	// Localizacao Portugal - Gera dados para diario contabil
	//-------------------------------------------------------------------------
	If UsaSeqCor()
		AAdd( aDiario, {"SE5",SE5->(Recno()),cCodDiario,"E5_NODIA","E5_DIACTB"} )
	Else
		aDiario := {}
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ PONTO DE ENTRADA PARA VALIDACAO APOS A GRAVACAO ³
    //³ DOS CAMPOS DA SE5 NA BAIXA POR LOTE             ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If ExistBlock("F070VSE5")
       ExecBlock("F070VSE5",.F.,.F.)
    EndIf

EndIf
//-------------------------------------------------------------------------
// Avisa quando totais nao baterem
//-------------------------------------------------------------------------
If lIsRussia
	lRuSkipChk := nTotGer==0
Endif
If Str(nTotGer,16,2) != Str(nTotAGer,16,2) .and. !lRuSkipChk
	Help(" ",1,"TOTGERAL",, STR0137  + Space(1) +;
                            Trans(nTotGer, "@E 99,999,999,999.99") +;
                            Chr(13)+CHR(10) + STR0138 + Space(1) +;
                            Trans(nTotAGer, "@E 99,999,999,999.99"), 4, 0)
ElseIf Str(nTotDesp,16,2) != Str(nTotADesp,16,2)
	Help(" ",1,"TOTDESP" ,, STR0137  + Space(1) +;
   								 Trans(nTotDesp, "@E 99,999,999,999.99") +;
                            Chr(13)+CHR(10) + STR0138 + Space(1) +;
                            Trans(nTotADesp, "@E 99,999,999,999.99"), 4, 0)
ElseIf Str(nTotDesc,16,2) != Str(nTotADesc,16,2)
	Help(" ",1,"TOTDESC" ,, STR0137  + Space(1) +;
                            Trans(nTotDesc, "@E 99,999,999,999.99") +;
                            Chr(13)+CHR(10) + STR0138 + Space(1) +;
                            Trans(nTotADesc, "@E 99,999,999,999.99"), 4, 0)
ElseIf Str(nTotMul,16,2) != Str(nTotAMul,16,2)
	Help(" ",1,"TOTMULT" ,, STR0137  + Space(1) +;
                            Trans(nTotMul, "@E 99,999,999,999.99") +;
                            Chr(13)+CHR(10) + STR0138 + Space(1) +;
                            Trans(nTotAMul, "@E 99,999,999,999.99"), 4, 0)
ElseIf Str(nTotJur,16,2) != Str(nTotAJur,16,2)
	Help(" ",1,"TOTJUROS",, STR0137  + Space(1) +;
 									 Trans(nTotJur, "@E 99,999,999,999.99") +;
                            Chr(13)+CHR(10) + STR0138 + Space(1) +;
                            Trans(nTotAJur, "@E 99,999,999,999.99"), 4, 0)
EndIf

IF ExistBlock("FA070BXL")
   ExecBlock("FA070BXL",.F.,.F.)
ENDIF
//-------------------------------------------------------------------------
//Envia para Lan‡amento Cont bil, se gerado arquivo
//-------------------------------------------------------------------------
IF (lHdlPrv .And. lPadrao .and. lContabiliza) .OR. nHdlPrv > 0 .and. !!FwIsInCallStack("Fa450Can")

	dbSelectArea( "SE1" )

	//vai para EOF() para contabilizar apenas o total
	nRecSE1 := SE1->( RecNo() )
	nRecSE5 := SE5->( RecNo() )
	nRecSEV := SEV->( RecNo() )
	nRecSEV := SEZ->( RecNo() )
	nRecFK1 := FK1->( RecNo() )
	nRecFK5 := FK5->( RecNo() )

	SE1->( dbGoBottom() )
	SE1->( dbSkip() )
	SE5->( dbGoBottom() )
	SE5->( dbSkip() )
	SEV->( dbGoBottom() )
	SEZ->( dbSkip() )
	FK1->( dbGoBottom() )
	FK1->( dbSkip() )


	If nTotAGer != 0
		//Contabilizar totalizador exceto o rateado por MultNat C.Custo
		VALOR := nTotaGer - nTotLtEZ
		ABATIMENTO := 0

		If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
			aAdd( aFlagCTB, {"E5_LA", "S", "SE5", nRecSE5, 0, 0, 0} )
			aAdd( aFlagCTB, {"FK5_LA", "S", "FK5", nRecFK5, 0, 0, 0} )
		Endif

		//Contabilizar totalizador dos rateios MultNat com C.Custo
		If nTotLtEZ > 0
			VALOR := nTotLtEZ
			ABATIMENTO := 0

			If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
				aAdd( aFlagCTB, {"E5_LA", "S", "SE5", nRecSE5, 0, 0, 0} )
			Endif

			nTotal += DetProva( nHdlPrv, cPadrao, "FINA070", cLote, /*nLinha*/, /*lExecuta*/,;
			                    /*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/,;
			                    /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ )
		EndIf
	EndIf

	cA100Incl( cArquivo, nHdlPrv, 3 /*nOpcx*/, cLote, lDigita, lAglut,;
	           /*cOnLine*/, /*dData*/, /*dReproc*/, @aFlagCTB, /*aDadosProva*/, aDiario )
	aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento

	dbSelectArea("SE1")
	SE1->(dbGoTo(nRecSe1))

	dbSelectArea("SEV")
	SEV->(dbGoTo(nRecSeV))

	dbSelectArea("SEZ")
	SEZ->(dbGoTo(nRecSeZ))

	//Restaura a posicao do arquivo
	SE1->( dbGoTo( nRecSE1 ) )
	SE5->( dbGoTo( nRecSE5 ) )
	SEV->( dbGoTo( nRecSEV ) )
	SEZ->( dbGoTo( nRecSEZ ) )
	FK1->( dbGoTo( nRecFK1 ) )
	FK5->( dbGoTo( nRecFK5 ) )

EndIf
//-------------------------------------
// Restaura o lote contabil original
//-------------------------------------
cLote := cLoteOrig
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa070BDev ³ Autor ³ Andreia Santos        ³ Data ³ 26/11/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Limpa conteudo de Bco/Age/Cta/N.Chque se baixa DEVOLUCAO   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Fa070bDev()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA070													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Xfa070BDev(oJuros, oMulta, oDescont, oCm, nTxMoeda, oCbx, lMotBx, aImpos,oDtBaixa,aTitCalc)
Local dBaixa
Local aPcc			:= {}
Local nBase			:= 0
Local lJurMulDes	:= (SuperGetMv("MV_IMPBAIX",.t.,"2") == "1")
Local lBq10925		:= SupergetMv("MV_BQ10925",.F.,"2") == "1"
Local lIrrfBxPj 	:= FIrPjBxCr(.T.)
Local lPccBxCr		:= FPccBxCr(.T.)

Default lMotBx		:= .F.
Default aImpos		:= {}
Default oDtBaixa 	:=""
DEFAULT aTitCalc	:= {}


// Motor de retenção de impostos
If __lTemMR
	F070VerImp("2",cFilAnt,SE1->E1_CLIENTE,SE1->E1_LOJA,,.T.,,@lPccBxCr)
EndIf
lAutValRec := If(Type('lAutValRec') == 'L', lAutValRec, .T.)

If ! MovBcoBx(cMotBx, .T.)
	//***Reestruturacao SE5***
	nPisCalc	:= 0
	nCofCalc	:= 0
	nCslCalc	:= 0
	nIrfCalc	:= 0
	nIssCalc	:= 0
	//***Reestruturacao SE5***

	if !lMotBx
		nJuros		:= 0
		nDescont	:= 0
		nMulta		:= 0
		nCM			:= 0
	Endif
	If !Empty(oCbx) .AND. (oCbx:lModified .Or. !lAutValRec)
		nValRec		:= Round(Noround(xMoeda(SE1->E1_SALDO-nTotAbat,SE1->E1_MOEDA,nMoedaBco,dBaixa,3,nTxMoeda),3),2)+nMulta+nJuros+nVa-nDescont+nAcresc-nDecresc
	Endif
	cBanco 		:= Space(3)
	cAgencia	:= Space(5)
	cConta 		:= Space(10)
	fA070Data(@nTxMoeda,,oDtBaixa,,oCbx)
ElseIf Empty(cBanco)
	If Alltrim(SE1->E1_ORIGEM) $ "LOJA010|LOJXTEF"
		aCaixaLoja  := xCxLoja()
		cPortado    := SE1->E1_PORTADO
		cBanco      := SE1->E1_PORTADO
		cAgencia    := SE1->E1_AGEDEP
		cConta      := SE1->E1_CONTA
	ElseIf !FwIsInCallStack("Fa450cmp")
		// 0 = Carteira
		// F = Carteira Protesto
		// G = Carteira Acordo
		cPortado    := IIF(FN022SITCB(SE1->E1_SITUACA)[1] .and. Empty(cPortado), aCaixaFin[1] , SE1->E1_PORTADO)
		cBanco      := IIF(FN022SITCB(SE1->E1_SITUACA)[1] .and. Empty(cBanco)  , aCaixaFin[1] , SE1->E1_PORTADO)
		cAgencia    := IIF(FN022SITCB(SE1->E1_SITUACA)[1] .and. Empty(cAgencia), aCaixaFin[2] , SE1->E1_AGEDEP )
		cConta      := IIF(FN022SITCB(SE1->E1_SITUACA)[1] .and. Empty(cConta)  , aCaixaFin[3] , SE1->E1_CONTA  )
	EndIf
	
	// Calcula o desconto e o juros (se houver) e valida a data
	fA070Data(@nTxMoeda,.F.,oDtBaixa,,oCbx,,, aImpos,/*lMudouMulta*/, aTitCalc)
	
	If !lMotBx
		u_xF070Ret()
	EndIf
EndIf

If (!Empty(oCbx) .AND. oCbx:lModified) .and. !lMotBx
	__lCalcImp := .F.
	dBaixa      := CriaVar("E1_BAIXA")
	nTxMoeda 	:= If(SE1->E1_MOEDA > 1, If(SE1->E1_TXMOEDA > 0, SE1->E1_TXMOEDA,RecMoeda(dBaixa,SE1->E1_MOEDA)),0)
	
	If __lBordImp .And. !Empty(SE1->E1_NUMBOR)
		__lCalcImp := BorderoImp(SE1->E1_FILORIG, SE1->E1_NUMBOR, "R", SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
	EndIf

	If __lFPIXatv .And. !__lCalcImp .And. !__lCnabImp
		__lCalcImp := PIXIsActiv()
	EndIf	
	
	If dBaixa < dLastPcc .and. lPccBxCr
		f070TotMes(dBaixa,.T.,,,,nTxMoeda)
	Else
		nValRec		:= Round(Noround(xMoeda(SE1->E1_SALDO-nTotAbat,SE1->E1_MOEDA,nMoedaBco,dBaixa,3,SE1->E1_TXMOEDA),3),2)+nMulta+nJuros+nVa-nDescont+nAcresc-nDecresc
		If lBq10925 .and. nValrec == nOldValrec
			nValRec	:= nValRec + (nPis + nCofins + nCsll)
		EndIf
		
		nBase	:= FBaseRPCC(nValRec)
		
		If lJurMulDes .And. (nBase-nDescont+nJuros+nVa+nMulta+nAcresc-nDecresc > 0)
			nBase 	:= nBase-nDescont+nJuros+nVa+nMulta+nAcresc-nDecresc
		EndIf

		aTitCalc := {}
		
		If !__lPccMR .And. lPccBxCr .And. !SE1->E1_TIPO $ MVRECANT .And. !__lCalcImp
			aPcc	:= newMinPcc(dBaixa, nBase,SE1->E1_NATUREZ,"R",SA1->A1_COD+SA1->A1_LOJA,,,,,,cMotBx)
			nPis	:= aPcc[2]
			nCofins	:= aPcc[3]
			nCsll	:= aPcc[4]
			If len(aPCC) > 4
				aTitCalc := aPCC[5]
			Endif
		Endif
	EndIf
	If !__lIrfMR .and. lIrrfBxPj
		nIrrf  := IIf(cPaisLoc == "BRA" .And. !__lCalcImp, FCaIrBxCR(SE1->E1_VALOR), 0)
	EndIf
EndIf

If Type('lF070Auto') =='U' .OR. !lF070Auto
	oBanco:Refresh()
	oAgencia:Refresh()
	oConta:Refresh()
	If ValType(oJuros) == "O"
		oJuros:Refresh()
	EndIf
	If ValType(oDescont) == "O"
		oDescont:Refresh()
	EndIf
	If ValType(oMulta) == "O"
		oMulta:Refresh()
	EndIf
	If ValType(oCm) == "O"
		oCm:Refresh()
	EndIf
EndIf
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FA070Desc ³ Autor ³ Mauricio Pequim Jr	  ³ Data ³ 13/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Alteracao de dados	da baixa											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ F070Desc()			 													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA070																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function xFA070Desc(oDescont, aTitCalc)
Local lFa070Dsc		:= ExistBlock("F070DESC")
Local lRet 			:= .T.
Local dBaixa		:= CtoD("")
Local cTxMod		:= If(SE1->E1_MOEDA > 1, If(SE1->E1_TXMOEDA > 0, SE1->E1_TXMOEDA,RecMoeda(dBaixa,SE1->E1_MOEDA)),0)
Local aPcc			:= {}
Local nBase			:= 0
Local lJurMulDes	:= (SuperGetMv("MV_IMPBAIX",.t.,"2") == "1")
Local lIrrfBxPj 	:= FIrPjBxCr(.T.)
Local lPccBxCr		:= FPccBxCr(.T.)

DEFAULT aTitCalc	:= {}

If lFa070Dsc
	lRet := ExecBlock("F070DESC",.F.,.F.,{nDescont})
	If ValType(lRet) <> "L"
		lRet := .T.
	EndIf
Endif

If lRet .And. (!Empty(oDescont) .AND. oDescont:lModified)
	__lCalcImp := .F.	
	dBaixa      := CriaVar("E1_BAIXA")
	
	If !nTxMoeda <> cTxMod
		nTxMoeda 	:= If(SE1->E1_MOEDA > 1, If(SE1->E1_TXMOEDA > 0, SE1->E1_TXMOEDA,RecMoeda(dBaixa,SE1->E1_MOEDA)),0)
	EndIf

	If __lBordImp .And. !Empty(SE1->E1_NUMBOR)
		__lCalcImp := BorderoImp(SE1->E1_FILORIG, SE1->E1_NUMBOR, "R", SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
	EndIf
	
	If __lFPIXatv .And. !__lCalcImp .And. !__lCnabImp
		__lCalcImp := PIXIsActiv()
	EndIf	
	
	If lPccBxCr
		F070CnvPcc(nTxMoeda, SE1->E1_MOEDA)

		If dBaixa < dLastPcc
			f070TotMes(dBaixa,.T.,,,,nTxMoeda)
		Else
			aTitCalc := {}

			If !__lPccMR .and. lJurMulDes .And. !SE1->E1_TIPO $ MVRECANT .And. !__lCalcImp
				nBase	:= FBaseRPCC() // Carrega a base do PCC
				If nBase-nDescont+nJuros+nVa+nMulta+nAcresc-nDecresc > 0
					nBase	:= nBase-nDescont+nJuros+nVa+nMulta+nAcresc-nDecresc
				EndIf
				aPcc	:= newMinPcc(dBaixa, nBase,SE1->E1_NATUREZ,"R",SA1->A1_COD+SA1->A1_LOJA,,,,,,cMotBx)
				nPis	:= aPcc[2]
				nCofins	:= aPcc[3]
				nCsll	:= aPcc[4]
				If len(aPCC) > 4
					aTitCalc := aPCC[5]
				Endif
			Endif
		Endif
	EndIf

	If !__lIrfMR .And. lIrrfBxPj .And. lJurMulDes .And. !__lCalcImp
		nIrrf := IIf(cPaisLoc == "BRA", FCaIrBxCR(nValRec), 0)
	EndIf
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F070ConImp()
Consulta de impostos do Motor de retenções.
@author  Rodrigo Oliveira
@since 23/01/2018
@version 12
/*/
//-------------------------------------------------------------------
Static Function F070ConImp(aImpos)
Local aImpMR As Array
Local nOpcao As Numeric
Local nVlr As Numeric
Local lAltImp as Logical
Default aImpos := {}

//Inicializa variáveis.
aImpMR := Aclone(aImpos)
nOpcao := 1
nVlr := 0
lAltImp := .F.

If Len(aImpMR) > 0
	nVlr := __nTotImp
	nOpcao := FINMRET(aImpMR, 'SE1', .T., @nVlr)

	lAltImp:= F070AltImp(aImpMR)

	//Se houve alguma alteração nos impostos
	If nOpcao != 1 .And. lAltImp

		If __nTotImp > nVlr
			nVlr := (__nTotImp - nVlr)
				nValrec += nVlr
			 __nTotImp -= nVlr
		Else
			nVlr := (nVlr - __nTotImp)
			nValrec -= nVlr
			 __nTotImp += nVlr
		Endif

		aImpos := Aclone(aImpMR)

		//atual variáveis para gravar os vrets
		F070AtuImp(aImpos)

		nOldValRec := nValrec
		nValEstrang := nValrec
		__oRetMot:Refresh()
		oValRec:Refresh()
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} F070AltImp()
Verifica se houve alteração no Valor dos impostos.
@author  Jose.Gavetti
@since 24/01/2018
@version 12
/*/
//-------------------------------------------------------------------
Static Function F070AltImp(aImpos As Array)
Local nY As Numeric
Local nImpos As Numeric
Local lAltImp := .F.

Default aImpos := {}


//Inicializa variáveis
nY := 0
nImpos := Len(aImpos)

For nY := 1 To nImpos

	Do Case
		Case aImpos[nY,8] == "PIS" .and.  aImpos[nY,5] <> nPis
			nPIS := aImpos[nY,5]
			lAltImp := .T.
		Case aImpos[nY,8] == "COF" .and. aImpos[nY,5] <> nCofins
			nCofins := aImpos[nY,5]
			lAltImp := .T.
		Case aImpos[nY,8] == "CSL" .and. aImpos[nY,5] <> nCsll
			nCsll := aImpos[nY,5]
			lAltImp := .T.
		Case aImpos[nY,8] == "IRF" .and. aImpos[nY,5] <> nIrrf
			nIrrf := aImpos[nY,5]
			lAltImp := .T.
		Case aImpos[nY,8] == "INSS" .and. aImpos[nY,5] <> nInss
			nInss := aImpos[nY,5]
			lAltImp := .T.
		Case aImpos[nY,8] == "ISS" .and. aImpos[nY,5] <> nIss
			nIss := aImpos[nY,5]
			lAltImp := .T.
	EndCase
Next nY

Return lAltImp

//-------------------------------------------------------------------
/*/{Protheus.doc} F070AtuImp()
Atualiza as variáveis para gravação dos vrets
@author  Jose.Gavetti
@since 24/01/2018
@version 12
/*/
//-------------------------------------------------------------------
Static Function F070AtuImp(aImpos As Array)
Local nZ As Numeric
Local nImpos As Numeric

Default aImpos := {}

//Inicializa variáveis
nZ := 0
nImpos := Len(aImpos)

For nZ := 1 To nImpos

	//Variáveis para gravar os Vrets.
	Do Case
		Case aImpos[nZ,8] == "PIS"
			nPIS := aImpos[nZ,5]
		Case aImpos[nZ,8] == "COF"
			nCofins := aImpos[nZ,5]
		Case aImpos[nZ,8] == "CSL"
			nCsll := aImpos[nZ,5]
		Case aImpos[nZ,8] == "IRF"
			nIrrf := aImpos[nZ,5]
		Case aImpos[nZ,8] == "INSS"
			nInss := aImpos[nZ,5]
		Case aImpos[nZ,8] == "ISS"
			nIss := aImpos[nZ,5]
	EndCase
Next nZ

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FA070ValRec³ Autor ³ Adrianne Furtado  	 ³ Data ³ 05/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Alteracao de dados da baixa							   	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FA070ValRec()			 								   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA070													   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function XFA070ValRec(oJuros,oMulta,oProRata,oDescont,aVlOringl,aImpos,lAltValor, aTitCalc)

Local lFa070VlRec	:= ExistBlock("F070VREC")
Local lRet			:= .T.
Local lPccBxCr		:= FPccBxCr(.T.)
Local lIrPjBxCr		:= FIrPjBxCr(.T.)
Local lProp			:= SuperGetMV("MV_DESCFIN",,"I")=="P"
Local lAtOldRec		:= .T.
Local lBQ10925		:= SuperGetMV("MV_BQ10925",,"2") == "1" .And. !lRaRtImp
Local nRecAltera	:= 0
Local nValOld 		:= 0
Local aPcc			:= {}
Local nBase			:= 0
Local lJurMulDes	:= (SuperGetMv("MV_IMPBAIX",.t.,"2") == "1")
LOCAL nTolerPg		:= GetMv("MV_TOLERPG")
Local lCpoValRec	:= ReadVar() == "NVALREC"
Local lVerfcOrg		:= .F.
Local lCalcPcc		:= .T.
Local lCalcIssBx 	:= GetNewPar("MV_MRETISS","1") == "2"  //Retencao do ISS pela emissao (1) ou baixa (2)
Local lFxIsBxTot 	:= FindFunction("FxIsBxTotal")
Local lPccMan:= .F.
Local lIrMan:= .F.
Local lImpPIx	:= .F.
Local aImpPix 	:= {}
Default lAltValor	:= STR(nValRec,17,2) != STR(nOldValRec,17,2)

// Motor de retenção de impostos
Default aImpos		:= {}
DEFAULT aTitCalc	:= {}

If __lTemMR
	F070VerImp("2",cFilAnt,SE1->E1_CLIENTE,SE1->E1_LOJA,,.T.,@lIrPjBxCr,@lPccBxCr)
EndIf
Default aVlOringl := Nil

lVerfcOrg := lAltValor .And. ValType( aVlOringl ) == "A" .And. Len( aVlOringl ) == 8

If Type("nTxMoeda") == "U" .and. cPaisLoc <> "BRA"
    nTxMoeda    := aTxMoedas[SE1->E1_MOEDA][2]
EndIf

//Valores Acessorios
IF nVA > 0 .and. nValRec-nJuros-nMulta+nDescont+nOtrga-nDifCambio-nTolerPg-nAcresc+nDecresc < nVA
	Help(" ",1,"VLRMENORQVA",,STR0276,1,0)	//"O valor efetivamente recebido é menor que os Valores Acessórios. Por favor, ajuste os Valores Acessórios."
	Return .F.
EndIf

__lCalcImp := .F.

If __lBordImp .And. !Empty(SE1->E1_NUMBOR)
	__lCalcImp := BorderoImp(SE1->E1_FILORIG, SE1->E1_NUMBOR, "R", SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
EndIf

lPccMan:= ((SE1->E1_PIS=0 .And. nPis > 0) .Or. (SE1->E1_COFINS=0 .AND. nCoFins > 0) .Or. (SE1->E1_CSLL=0 .AND. nCsll > 0)) 
lIrMan := SE1->E1_IRRF = 0 .And. nIrrf > 0

If __lFPIXatv
	If !__lCalcImp .And. !__lCnabImp
		__lCalcImp := PIXIsActiv()
	EndIf	
	
	aImpPix := Iif(__lImpPix,RetImpBxCR(),{})
	
	IF Len(aImpPix) > 0
		lImpPIx := .T.
	EndIf
EndIf

If lAltValor .And. lIrPjBxCr .And. !(lRaRtImp .And. SE1->E1_TIPO $ MVRECANT) .And. !lIrMan .And. !lImpPIx .And. !__lCalcImp
  If !__lIrfMR
	If !lMVGlosa
		nIrrf    := Iif(cPaisLoc == "BRA" .And. !__lCalcImp, FCaIrBxCR(nValRec,,.T.,,lAltValor), 0)
		nOldIrrf := nIrrf
	EndIf
  ElseIf __lTemMR .And. __lIrfMR
	aImpos := F070VldImp(nValRec, dBaixa)
  EndIf
EndIf

If !__lPccMR .and. lMVGlosa
	nPis 	:= nOldPis
	nCofins := nOldCofins
	nCsll 	:= nOldCsll
EndIf

If lAltValor .and. !lRaRtImp .and. lPccBxCr .and. nValRec == (SE1->E1_SALDO)
	nRecAltera	:= nValRec
EndIf

If lAltValor .And. lPccBxCr 
	If !lMVGlosa
		If dBaixa < dLastPcc
			f070TotMes(dBaixa,.T.)
		Else
			nBase	:= FBaseRPCC(nValRec,@lCalcPCC)
			
			If lJurMulDes
				If nValRec <= nAcresc
					nBase	:= 0
				EndIf
				If nBase+nDescont-nJuros-nVa-nMulta-nAcresc+nDecresc > 0
					nBase 	:= nBase+nDescont-nJuros-nVa-nMulta-nAcresc+nDecresc
				EndIf
			EndIf

			//No caso do usuário alterar o valor e retornar ao valor originalmente calculado
			If lVerfcOrg .And. aVlOringl[ 1 ] == nValRec .And. aVlOringl[ 5 ] == nJuros .And. aVlOringl[ 6 ] == nMulta .And. aVlOringl[ 7 ] == nDescont
				nPis      := aVlOringl[ 2 ]
				nCofins   := aVlOringl[ 3 ]
				nCsll     := aVlOringl[ 4 ]
				nPisCalc  := nPis
				nPisBaseC := aVlOringl[ 8 ]
				nPisBaseR := aVlOringl[ 8 ]
				nCofCalc  := nCofins
				nCofBaseC := aVlOringl[ 8 ]
				nCofBaseR := aVlOringl[ 8 ]
				nCslCalc  := nCsll
				nCslBaseC := aVlOringl[ 8 ]
				nCslBaseR := aVlOringl[ 8 ]
				If Type( "nOldPis+nOldCofins+nOldCsll" ) == "N"
					nOldPis    := nPis
					nOldCofins := nCofins
					nOldCsll   := nCsll
				EndIf
			ElseIf !SE1->E1_TIPO $ MVRECANT .And. lCalcPcc
				aTitCalc := {}
				
				If !__lCalcImp
					If !__lPccMR
						aPcc	:= newMinPcc(dBaixa, nBase,SE1->E1_NATUREZ,"R",SA1->A1_COD+SA1->A1_LOJA,,,,,,cMotBx)
						nPis	:= aPcc[2]
						nCofins	:= aPcc[3]
						nCsll	:= aPcc[4]
						If len(aPCC) > 4
							aTitCalc := aPCC[5]
						Endif
						If Type( "nOldPis+nOldCofins+nOldCsll" ) == "N"
							nOldPis    := nPis
							nOldCofins := nCofins
							nOldCsll   := nCsll
						EndIf
					ElseIf __lTemMR .And. __lPccMR
						aImpos := F070VldImp(nValRec, dBaixa)
					EndIf
				EndIf
			ElseIf lPccMan .And. nBase = 0
				nPisCalc	:= nPis
				nPisBaseC	:= nValRec
				nPisBaseR 	:= nValRec
				nCofCalc	:= nCofins
				nCofBaseC	:= nValRec
				nCofBaseR 	:= nValRec
				nCslCalc	:= nCsll
				nCslBaseC	:= nValRec
				nCslBaseR 	:= nValRec
			EndIf
		EndIf
		nValOld := nValRec
	EndIf
	
	If lRaRtImp .And. lAltValor
		nOldValRec := nValRec
		nValRec := nValRec-nPis-nCoFins-nCsll-nIrrf

		If nValRec < 0
			nValRec := nOldValRec
		Endif

		If SE1->E1_MOEDA == 1 .And. nMoedaBco == SE1->E1_MOEDA
			nValEstrang := nValRec // nValEstrang = variavel que contem o valor do campo "valor pago" na baixa
		EndIf

		If lAtOldRec
			nOldValRec	 := nValRec
		EndIf
	ElseIf lAltValor .And. lPccBxCr
		nOldValRec := nValRec
		If lRaRtImp .And. ( lAltValor .And. lPccBxCr )
			nValRec := nValRec-nPis-nCoFins-nCsll-nIrrf
		EndIF
		If nValRec < 0
			nValRec := nOldRec
		EndIf

		If SE1->E1_MOEDA == 1 .And. nMoedaBco == SE1->E1_MOEDA
			nValEstrang := nValRec // nValEstrang = variavel que contem o valor do campo "valor pago" na baixa
		EndIf

		If lBQ10925 .And. (nValRec == SE1->E1_VALOR .OR. (nValRec - nPis - nCofins - nCsll) == SE1->E1_SALDO )
			fa070val( nValrec, nTxMoeda,!lCpoValRec)
		EndIf

		If nValRec != nOldValRec
			nOldValRec := nValRec
		EndIf
	EndIf
ElseIf !lAltValor .And. lPccMan .And. lPccBxCr
	nBase:= nValRec+nPis+nCoFins+nCsll+nIrrf
	nPisCalc	:= nPis
	nPisBaseC	:= nBase
	nPisBaseR 	:= nBase
	nCofCalc	:= nCofins
	nCofBaseC	:= nBase
	nCofBaseR 	:= nBase
	nCslCalc	:= nCsll
	nCslBaseC	:= nBase
	nCslBaseR 	:= nBase
EndIf

If __lTemMR .And. __lImpMR .And. !__lCalcImp
	aImpos := F070VldImp( Iif( lFxIsBxTot .And. FxIsBxTotal( nValRec , nParciais, __nMRBxTot ), SE1->E1_VALOR, nValRec), dBaixa,@lPccBxCr, @lIrPjBxCr, @lCalcIssBx,@__lImpMR)
EndIf

//Recalcula o desconto
If lAltValor .And.( lProp .And. (nValRec + nDescont) <> nOldValRec) 
	nDescont 	:= FaDescFin("SE1",dBaixa,nValRec,nMoedaBco)
	nValRec  	-= nDescont
	nValEstrang := Round(NoRound(xMoeda(nValRec,nMoedaBco,SE1->E1_MOEDA,dBaixa,3,,nTxMoeda),3),MsDecimais(SE1->E1_MOEDA))
EndIf

// Valida novamente o valor recebido após recálculo dos impostos
If Str(nValRec,17,2) > Str(Round(NoRound(xMoeda(SE1->E1_SALDO-nTotAbat,SE1->E1_MOEDA,nMoedaBco,dBaixa,7,nTxMoeda),3),MsDecimais(SE1->E1_MOEDA))+Iif(Alltrim(SE1->E1_ORIGEM) == "FINA074",0,nJuros+nVa+nMulta-nDescont-nOtrga+nTolerPg+nAcresc-nDecresc- IIF(lPccBxCr,nPis+nCoFins+nCsll,0) - IIF(lIrPjBxCr,nIrrf,0) - IIF(lCalcIssBx,nIss,0) ) - IIF(__lTemMR, __nTotImp , 0) ,17,2)
    Help(" ",1,"ValorMaior")
    Return .F.
EndIf

If lFa070VlRec
	lRet := ExecBlock("F070VREC",.F.,.F.,{nValRec})	
	If ValType(lRet) <> "L"
		lRet := .T.
	EndIf
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³F070SetMd ³ Autor ³ Fernando Machima      ³ Data ³ 09/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mostra a tela de taxas de moeda    								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³F070SetMd()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³FINA070                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fa070SetMd(nTxMoeda,lGetMd)
Local oDlg, nLenMoedas	:= Len(aTxMoedas)
Default lGetMd := .T.

If nLenMoedas > 1 .and. lGetMd
	DEFINE MSDIALOG oDlg From 200,0 TO 362,230 TITLE STR0132 PIXEL
	@ 005,005  To 062,110 OF oDlg PIXEL
	@ 012,010 SAY  aTxMoedas[2][1]  Of oDlg PIXEL
	@ 010,060 MSGET aTxMoedas[2][2] PICTURE aTxMoedas[1][3] Of oDlg PIXEL  HASBUTTON
	If nLenMoedas > 2
	   @ 024,010 SAY  aTxMoedas[3][1]  Of oDlg PIXEL
	   @ 022,060 MSGET aTxMoedas[3][2] PICTURE aTxMoedas[2][3] Of oDlg PIXEL  HASBUTTON
	   If nLenMoedas > 3
	      @ 036,010 SAY  aTxMoedas[4][1]  Of oDlg PIXEL
	      @ 034,060 MSGET aTxMoedas[4][2] PICTURE aTxMoedas[3][3] Of oDlg PIXEL  HASBUTTON
	      If nLenMoedas > 4
	         @ 048,010 SAY  aTxMoedas[5][1]  Of oDlg PIXEL
	         @ 046,060 MSGET aTxMoedas[5][2] PICTURE aTxMoedas[4][3] Of oDlg PIXEL  HASBUTTON
	      Endif
	   Endif
	Endif
	DEFINE SButton FROM 064,80 TYPE 1 Action (oDlg:End() ) ENABLE OF oDlg  PIXEL

   ACTIVATE MSDialog oDlg CENTERED

EndIf

If nLenMoedas > 1
	If SE1->E1_MOEDA > 1 .And. cPaisLoc<>"BRA"  // somente se o titulo original for em moeda diferente de 1
		nTxMoeda := aTxMoedas[SE1->E1_MOEDA][2]
	EndIf
    nDifCambio := ((SE1->E1_VALOR * aTxMoedas[SE1->E1_MOEDA][2]) - SE1->E1_VLCRUZ)
    If SE1->E1_MOEDA == nMoedabco .and. cPaisLoc<>"BRA" .and. nDifCambio < 0 
		nDifCambio:= 0
	Endif 
Endif

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³F070GetChq³ Autor ³ Claudio D. de Souza   ³ Data ³ 28/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Entrada de dados do cheque   										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ F460GetChq(ExpA1,ExpD1,ExpN1)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aCmc7=Array contendo dados do cheque (vindos da leitora)	  ³±±
±±³          ³ EF_BANCO=Codigo do banco, por referencia						  ³±±
±±³          ³ EF_AGENCIA=Codigo da agencia, por referencia					  ³±±
±±³          ³ EF_AGENCIA=Codigo da agencia, por referencia					  ³±±
±±³          ³ EF_CONTA=Codigo da conta, por referencia					     ³±±
±±³          ³ EF_NUM=Numero do Cheque, por referencia					     ³±±
±±³          ³ EF_DATA=Data do cheque, por referencia					  		  ³±±
±±³          ³ EF_VENCTO=Vencto. do cheque, por referencia					  ³±±
±±³          ³ EF_EMITENT=Emitente do cheque, por referencia				  ³±±
±±³          ³ EF_VALOR=Valor nominal, por referencia					  		  ³±±
±±³          ³ EF_CPFCNPJ=Cpf/Cnpj do cheque, por referencia				  ³±±
±±³          ³ EF_HIST=Historico do cheque, por referencia			  		  ³±±
±±³          ³ lGetDados=.T. se estiver chamando da GetDados				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA070, FINA040 e FINA191											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function F070GetChq(aCmC7,EF_BANCO,EF_AGENCIA,EF_CONTA,EF_NUM,EF_DATA,;
									EF_VENCTO,EF_EMITENT,EF_VALOR,EF_CPFCNPJ,EF_TEL,EF_HIST,;
									lGetDados)
Local lCorrige := .F.
Local lRet := .F.
Local nOpca := 0
Local oDlg
Local aValid 	:= {}
Local aPicture := {}
Local oBanco
Local cValid

// Pequisa um determinados campo no SX3 e retorna o conteudo desejado do dicionario.
Local bSx3		:= { |cCampo,cCampoSx3|	SX3->(DbSetOrder(2)), SX3->(MsSeek(cCampo)),;
													SX3->(DbSetOrder(1)), SX3->&(cCampoSx3) }

If lGetDados .And. Type("aHeader")=="A"
	cValid := StrTran(aHeader[1][6],"aCols[n][12]!='Sim'",".T.")
	Aadd(aValid, {"Banco"	, "{||"+If(Empty(cValid),".T.",cValid)+"}"})
	Aadd(aPicture, {"Banco"	, aHeader[1][3]})
	cValid := StrTran(aHeader[2][6],"aCols[n][12]!='Sim'",".T.")
	Aadd(aValid, {"Agencia"	, "{||"+If(Empty(cValid),".T.",cValid)+"}"})
	Aadd(aPicture, {"Agencia"	, aHeader[2][3]})
	cValid := StrTran(aHeader[3][6],"aCols[n][12]!='Sim'",".T.")
	Aadd(aValid, {"Conta"	, "{||"+If(Empty(cValid),".T.",cValid)+"}"})
	Aadd(aPicture, {"Conta"	, aHeader[3][3]})
	cValid := StrTran(aHeader[4][6],"aCols[n][12]!='Sim'",".T.")
	Aadd(aValid, {"Numero"	, "{||"+If(Empty(cValid),".T.",cValid)+"}"})
	Aadd(aPicture, {"Numero"	, aHeader[4][3]})
	cValid := StrTran(aHeader[5][6],"aCols[n][13]!='Sim'",".T.")
	Aadd(aValid, {"Valor"	, "{||"+If(Empty(cValid),".T.",cValid)+"}"})
	Aadd(aPicture, {"Valor"	, aHeader[5][3]})
	cValid := StrTran(aHeader[8][6],"aCols[n][12]!='Sim'",".T.")
	Aadd(aValid, {"Emissao"	, "{||"+If(Empty(cValid),".T.",cValid)+"}"})
	Aadd(aPicture, {"Emissao"	, aHeader[8][3]})
	cValid := StrTran(aHeader[9][6],"aCols[n][13]!='Sim'",".T.")
	cValid := StrTran(cValid, ".And. aCols[n][9] >= aCols[n][8]","")
	Aadd(aValid, {"Vencto"	, "{||"+If(Empty(cValid),".T.",cValid)+"}"})
	Aadd(aPicture, {"Vencto"	, aHeader[9][3]})
	cValid := StrTran(aHeader[7][6],"aCols[n][13]!='Sim'",".T.")
	Aadd(aValid, {"Emitente", "{||"+If(Empty(cValid),".T.",cValid)+"}"})
	Aadd(aPicture, {"Emitente", aHeader[7][3]})
	cValid := StrTran(aHeader[10][6],"aCols[n][13]!='Sim'",".T.")
	Aadd(aValid, {"CPF/CNPJ", "{||"+If(Empty(cValid),".T.",cValid)+"}"})
	Aadd(aPicture, {"CPF/CNPJ", aHeader[10][3]})
	cValid := StrTran(aHeader[12][6],"aCols[n][13]!='Sim'",".T.")
	Aadd(aValid, {"OBS"		, "{||"+If(Empty(cValid),".T.",cValid)+"}"})
	Aadd(aPicture, {"OBS", aHeader[12][3]})
	cValid := StrTran(aHeader[11][6],"aCols[n][13]!='Sim'",".T.")
	Aadd(aValid, {"Telefone", "{||"+If(Empty(cValid),".T.",cValid)+"}"})
	Aadd(aPicture, {"Telefone", aHeader[11][3]})
Else
	cValid := Eval(bSx3,"EF_BANCO","X3_VALID")
	Aadd(aValid, {"Banco"	, "{||"+If(Empty(cValid),".T.",cValid)+"}"})
	Aadd(aPicture, {"Banco"	, Eval(bSx3,"EF_BANCO","X3_PICTURE")})
	cValid := Eval(bSx3,"EF_AGENCIA","X3_VALID")
	Aadd(aValid, {"Agencia"	, "{||"+If(Empty(cValid),".T.",cValid)+"}"})
	Aadd(aPicture, {"Agencia"	, Eval(bSx3,"EF_AGENCIA","X3_PICTURE")})
	cValid := Eval(bSx3,"EF_CONTA","X3_VALID")
	Aadd(aValid, {"Conta"	, "{||"+If(Empty(cValid),".T.",cValid)+"}"})
	Aadd(aPicture, {"Conta"	, Eval(bSx3,"EF_CONTA","X3_PICTURE")})
	cValid := Eval(bSx3,"EF_NUM","X3_VALID")
	Aadd(aValid, {"Numero"	, "{||"+If(Empty(cValid),".T.",cValid)+"}"})
	Aadd(aPicture, {"Numero"	, Eval(bSx3,"EF_NUM","X3_PICTURE")})
	cValid := Eval(bSx3,"EF_VALOR","X3_VALID")
	Aadd(aValid, {"Valor"	, "{||"+If(Empty(cValid),".T.",cValid)+"}"})
	Aadd(aPicture, {"Valor"	, Eval(bSx3,"EF_VALOR","X3_PICTURE")})
	cValid := Eval(bSx3,"EF_DATA","X3_VALID")
	Aadd(aValid, {"Emissao"	, "{||"+If(Empty(cValid),".T.",cValid)+"}"})
	Aadd(aPicture, {"Emissao"	, Eval(bSx3,"EF_DATA","X3_PICTURE")})
	cValid := Eval(bSx3,"EF_VENCTO","X3_VALID")
	Aadd(aValid, {"Vencto"	, "{||"+If(Empty(cValid),".T.",cValid)+"}"})
	Aadd(aPicture, {"Vencto"	, Eval(bSx3,"EF_VENCTO","X3_PICTURE")})
	cValid := Eval(bSx3,"EF_EMITENT","X3_VALID")
	Aadd(aValid, {"Emitente", "{||"+If(Empty(cValid),".T.",cValid)+"}"})
	Aadd(aPicture, {"Emitente", Eval(bSx3,"EF_EMITENT","X3_PICTURE")})
	cValid := Eval(bSx3,"EF_CPFCNPJ","X3_VALID")
	Aadd(aValid, {"CPF/CNPJ", "{||"+If(Empty(cValid),".T.",cValid)+"}"})
	Aadd(aPicture, {"CPF/CNPJ", Eval(bSx3,"EF_CPFCNPJ","X3_PICTURE")})
	cValid := Eval(bSx3,"EF_HIST","X3_VALID")
	Aadd(aValid, {"OBS", "{||"+If(Empty(cValid),".T.",cValid)+"}"})
	Aadd(aPicture, {"OBS", Eval(bSx3,"EF_HIST","X3_PICTURE")})
	cValid := Eval(bSx3,"EF_TEL","X3_VALID")
	Aadd(aValid, {"Telefone", "{||"+If(Empty(cValid),".T.",cValid)+"}"})
	Aadd(aPicture, {"Telefone", Eval(bSx3,"EF_TEL","X3_PICTURE")})
Endif

While .T.
	nOpca := 0

	DEFINE MSDIALOG oDlg FROM	38,16 TO 347,550 TITLE  STR0161 PIXEL   //"Dados do cheque"
	@ 003, 004 TO 120, 265 OF oDlg  PIXEL
	@ 010, 011 SAY STR0145		OF oDlg PIXEL  //"Banco"
	@ 020, 011 MSGET oBanco VAR aCmc7[1]	WHEN lCorrige .Or. "?" $ aCmc7[1] ;
														VALID Eval(&(aValid[1][2])) PICTURE aPicture[1][2] SIZE 17, 11 OF oDlg PIXEL
	@ 010, 038 SAY STR0146	OF oDlg PIXEL  //"Agência"
	@ 020, 038 MSGET aCmc7[3]	WHEN lCorrige .Or. "?" $ aCmc7[3] ;
										VALID Eval(&(aValid[2][2])) PICTURE aPicture[2][2] SIZE 30, 11 OF oDlg PIXEL
	@ 010, 078 SAY STR0147		OF oDlg PIXEL   //"Conta"
	@ 020, 078 MSGET aCmc7[4]	WHEN lCorrige .Or. "?" $ aCmc7[4];
										VALID Eval(&(aValid[3][2])) PICTURE aPicture[3][2] SIZE 37, 11 OF oDlg PIXEL
	@ 010, 125 SAY STR0162	SIZE 46, 7 OF oDlg PIXEL  //"Número do Cheque"
	@ 020, 125 MSGET aCmc7[2]	WHEN lCorrige .Or. "?" $ aCmc7[2];
										VALID Eval(&(aValid[4][2])) PICTURE aPicture[4][2] SIZE 40, 11 OF oDlg PIXEL
	@ 010, 175 SAY STR0163	OF oDlg PIXEL	 //"Valor Nominal"
	@ 020, 175 MSGET M->EF_VALOR VALID Eval(&(aValid[4][2])) PICTURE aPicture[5][2] Size 60,11  OF oDlg PIXEL
	@ 035, 011 SAY STR0164 OF oDlg PIXEL	 //"Data de Emissão"
	@ 045, 011 MSGET M->EF_DATA VALID Eval(&(aValid[6][2])) PICTURE aPicture[6][2] SIZE 60,11 OF oDlg PIXEL
	@ 035, 078 SAY STR0165 OF oDlg PIXEL	 //"Data de Vencto"
	@ 045, 078 MSGET M->EF_VENCTO  VALID Eval(&(aValid[7][2])) PICTURE aPicture[7][2] SIZE 60,11 OF oDlg PIXEL

	@ 060, 011 SAY STR0150 OF oDlg PIXEL //"Emitente"
	@ 070, 011 MSGET M->EF_EMITENT SIZE 140,11 VALID Eval(&(aValid[8][2])) PICTURE aPicture[8][2] OF oDlg PIXEL

	@ 060, 175 SAY STR0166 OF oDlg PIXEL	 //"CNPJ/CPF"
	@ 070, 175 MSGET M->EF_CPFCNPJ VALID Eval(&(aValid[9][2])) PICTURE If(Empty(aPicture[9][2]),"99999999999999",aPicture[9][2])SIZE 50,11 OF oDlg PIXEL

	@ 085, 011 SAY STR0155 OF oDlg PIXEL	 //"Observações"
	@ 095, 011 MSGET M->EF_HIST VALID Eval(&(aValid[10][2])) PICTURE If(Empty(aPicture[10][2]),"@!",aPicture[10][2]) SIZE 140,11 OF oDlg PIXEL

	@ 085, 175 SAY STR0154 OF oDlg PIXEL	 //"Telefone"
	@ 095, 175 MSGET M->EF_TEL  VALID Eval(&(aValid[11][2])) PICTURE If(Empty(aPicture[11][2]),"@!",aPicture[11][2]) SIZE 50,11 OF oDlg PIXEL

	DEFINE SBUTTON FROM 130, 175 TYPE 1 ACTION (nOpca:=1,oDlg:End())ENABLE OF oDlg PIXEL
	DEFINE SBUTTON FROM 130, 205 TYPE 2 ACTION (nOpca:=2,oDlg:End())ENABLE OF oDlg PIXEL
	DEFINE SBUTTON FROM 130, 235 TYPE 5 ACTION (nOpca:=3,lCorrige:=.T.,oBanco:SetFocus()) ENABLE OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpca == 1  // Confirma Dados do Cheque
		M->EF_BANCO		:= aCmc7[1]
		M->EF_AGENCIA	:= aCmc7[3]
		M->EF_CONTA		:= aCmc7[4]
		M->EF_NUM		:= aCmc7[2]
		lRet := .T.
		lCorrige := .F.
		Exit
	ElseIf nOpca == 2 	// Finaliza inclusao de cheques
		lRet := .F.
		lCorrige := .F.
		Exit
	ElseIf nOpca == 3   // Edita dados do cheque
		aCmc7[1] := PADR(aCmc7[1],3," ")
		aCmc7[3] := PADR(aCmc7[3],4," ")
		aCmc7[4] := PADR(aCmc7[4],8," ")
		aCmc7[2] := PADR(aCmc7[2],6," ")
		lCorrige := .T.
	Endif
End
Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³F070Ret   ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 10/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Tratamento de retencao na data de credito					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ F070Ret(ExpC1,ExpD4) 						              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data de Credito Atual                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA070 													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function XF070Ret()
Local j
Local cFunName	:= AllTrim( Upper( FunName() ) )	// Nome da Rotina
Local lConsRet	:= .T.								// Considera retancao bancaria

// Determina se a rotina considera retencao bancaria, se esta funcao foi
// chamada por outro programa sempre considera.
If	( cFunName $ "FINA070*FINA740" .AND. mv_par09 <> 1 ) .OR.;
	( cFunName == "FINA110" .AND. mv_par07 <> 1 )

	lConsRet	:= .F.
EndIf

If !( cFunName $ "FINA070*FINA740" ) .OR. lConsRet

	SA6->(MsSeek(xFilial("SA6")+cBanco+cAgencia+cConta))	

	If SA6->(!Eof()) .AND. SA6->A6_RETENCA > 0 .AND. (FN022SITCB(SE1->E1_SITUACA)[2] .OR. FN022SITCB(SE1->E1_SITUACA)[1]) //SE1->E1_SITUACA $ "12347"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza data vencto real c/reten‡„o Banc ria³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dDtCredito := dBaixa
		For j:=1 To SA6->A6_RETENCA
			dDtCredito := DataValida(dDtCredito+1,.T.)
		Next j
	Endif

Endif

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ f070AltBco   ³ Autor ³ Leonardo Ruben     	³ Data ³ 02/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica moeda        para o banco escolhido/alterado          ³±±
±±³          ³ Somente paises localizados                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function f070AltBco(nTxMoeda, oJuros, oMulta, oDescont, oCm, oBanco, nValRec, oTxMoeda, nOldMoeBco)
Local lRet		 := .T.
Local lPccBxCr   := FPccBxCr()
Local lIrPjBxCr  := FIrPjBxCr()
Local nMoedaBx   := Max(SE1->E1_MOEDA, 1)
Local nTxMdaOr   := 0

DEFAULT oBanco := ""
DEFAULT nOldMoeBco := 0

If (cBanco+cAgencia+cConta == SA6->A6_COD+SA6->A6_AGENCIA+SA6->A6_NUMCON)
	nMoedaBco := Max( SA6->A6_MOEDA, 1)
	If nOldMoeBco <> nMoedaBco
		If cPaisLoc <> "BRA"
			If nMoedaBco == nMoedaBx
				nTxMoeda := 1
	        ElseIf nMoedaBco > 1 .AND. SE1->E1_MOEDA = 1
	            nTxMoeda := aTxMoedas[nMoedaBco][2]
			ElseIf SE1->E1_MOEDA > 1 .AND. nMoedaBco =1
	            nTxMoeda := aTxMoedas[SE1->E1_MOEDA][2]
	        Else
	            nTxMoeda := RecMoeda(dBaixa,SE1->E1_MOEDA)
	   		EndIf
			nTxMdaOr:=aTxMoedas[SE1->E1_MOEDA][2]
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ SIGAPFS‚ A cotação para baixa dos títulos no módulo jurídico deve ser sempre na cotação diária.  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If UPPER(Alltrim(SE1->E1_ORIGEM)) $ "JURA203"
				nTxMoeda := If(SE1->E1_MOEDA > 1, RecMoeda(dBaixa,SE1->E1_MOEDA), 0)
			ElseIf nMoedaBco == nMoedaBx
				nTxMoeda := 1
	        ElseIf nMoedaBco > 1 .AND. SE1->E1_MOEDA = 1
	            nTxMoeda := RecMoeda(dBaixa,nMoedaBco)
	        Else
				nTxMoeda := If(SE1->E1_MOEDA > 1, If(SE1->E1_TXMOEDA > 0, SE1->E1_TXMOEDA,RecMoeda(dBaixa,SE1->E1_MOEDA)),0)
			EndIf
	
			nTxMdaOr := If(SE1->E1_MOEDA > 1, If(SE1->E1_TXMOEDA > 0, SE1->E1_TXMOEDA,RecMoeda(dBaixa,SE1->E1_MOEDA)),0)
		Endif
		
		nBsVlEstr := SE1->E1_SALDO - nTotAbat
		nOutrosValores := nJuros+nVa+(nCm1+nProRata)+nMulta-nDescont-nOtrga+nAcresc-nDecresc - Iif(lPccBxCr,nPis+nCofins+nCsll,0)-Iif(lIrPjBxCr,nIrrf,0)
	    If SE1->E1_MOEDA == 1
	    	If nMoedaBco > 1
	    		nValRec := Round(NoRound( xMoeda(nValEstrang,SE1->E1_MOEDA,nMoedaBco,dBaixa,5,nTxMdaOr,nTxMoeda) ,3),MsDecimais(SE1->E1_MOEDA)) 
	    		nValEstrang := Round(NoRound( xMoeda(nValRec,nMoedaBco,SE1->E1_MOEDA,dBaixa,5,nTxMoeda,) ,3),MsDecimais(SE1->E1_MOEDA))  
	    	Else
	    		nValRec := nValEstrang
	    	EndIf
	    Else
	        //"Resolver" problemas de arredondamento em moeda 2
	        nVlEstRnd   := Round(NoRound(xMoeda(nValEstrang,nOldMoeBco,SE1->E1_MOEDA,dBaixa,5,nTxMdaOr,nTxMoeda),3),MsDecimais(SE1->E1_MOEDA))
	        nVlEstNoRd  := NoRound(xMoeda(nValEstrang,nOldMoeBco,SE1->E1_MOEDA,dBaixa,5,nTxMdaOr,nTxMoeda),MsDecimais(SE1->E1_MOEDA))
	        If SE1->E1_SALDO == nVlEstRnd .AND. nOutrosValores == 0 // Se saldo igual Round do nValRec
	            nValEstrang := nVlEstRnd
	        ElseIf SE1->E1_SALDO == nVlEstNoRd .AND. nOutrosValores == 0 // Se saldo igual a noRound do nValRec
	            nValEstrang := nVlEstNoRd
	        Else // mudou o valor de baixa, faço como o padrão sempre fez
	            nValEstrang := Round(NoRound(xMoeda(nValEstrang,nOldMoeBco,SE1->E1_MOEDA,dBaixa,5,nTxMdaOr,nTxMoeda),3),MsDecimais(SE1->E1_MOEDA))
	        EndIf
			If SE1->E1_MOEDA == nMoedaBco
				nValRec := nValEstrang
			Else
				nValRec := Round(NoRound(xMoeda(nValEstrang,nOldMoeBco,nMoedaBco,dBaixa,5,nTxMdaOr,nTxMoeda),3),MsDecimais(SE1->E1_MOEDA)) 
			EndIf
		EndIf	
		If nOutrosValores == 0	// Vai baixar o título sem nenhum outro valor além do título?
			If Abs(nValEstrang - nBsVlEstr ) == 0.01
				nValEstrang := nBsVlEstr	// Corrigir diferença de 0,01 em conversão de moedas. Exemplo: E1_VALOR = 115890, E1_MOEDA = 2 , Taxa = 0,03348
			EndIf
		EndIf
	
		oValRec:Refresh()
	
		If Type("oTxMoeda") == "O"
			oTxMoeda:Refresh()
		Endif
	
	    If Type("oVlEstrang") == "O" .and. oVlEstrang:lModified
	        oVlEstrang:Refresh()
		Endif
	
		nEstOriginal := nValEstrang-(xMoeda(nOutrosValores,1,SE1->E1_MOEDA,,,,nTxMoeda))
	    If (!EMPTY(oDescont) .AND. oDescont:lModified) .OR. EMPTY(oDescont)
			nDescont := FaDescFin("SE1",dBaixa,SE1->E1_SALDO-nTotAbat,nMoedaBco)
		EndIf
		IF (!Empty(oJuros) .AND. oJuros:lModified) .or. Empty(oJuros)
			fa070Juros(nMoedaBco)
		EndIf
	
		If (!Empty(oBanco) .AND. (oBanco:lModified))
			FA070CORR(nEstOriginal,nTxMoeda)
	    endIF
	
		If cPaisLoc == "BRA"
			oJuros:Refresh()
			oMulta:Refresh()
			oDescont:Refresh()
			If Type("oCm") == "O"
				oCm:Refresh()
			Endif
		Endif
	EndIf

	nOldMoeBco := nMoedaBco
EndIf

//Ponto de entrada para validacao do Banco
If ExistBlock("F070KCO")
	lRet := ExecBlock("F070KCO",.F.,.F.,{cBanco,cAgencia,cConta})
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Fa080ValEs³ Autor ³ Claudio D. de Souza   ³ Data ³ 17.09.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do valor recebido em moeda estrangeira			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Fa080ValEstrang(	nValEstrang,nTxMoeda,nValRec,dBaixa, 	  ³±±
±±³			 ³ 					 oValRec,oTxMoeda,nJuros,nMulta,nDescont, ³±±
±±³			 ³ 						nOtrga,nEstOriginal)  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA070  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function Fa070ValEstrang(	nValEstrang,nTxMoeda,nValRec,dBaixa,oValRec,oTxMoeda,;
											nJuros,nMulta,nDescont,nOtrga,nEstOriginal,oVlEstrang)
Local nTxMdaOr := 0
Local lPccBxCr 	:= FPccBxCr()
Local lIrPjBxCr	:= FIrPjBxCr()
If cPaisLoc<>"BRA"
	nTxMdaOr:=Iif(nMoedaBco>0,aTxMoedas[nMoedaBco][2],1)
EndIf

If Type("nTxMoeda") == "U" .and. cPaisLoc <> "BRA"
    nTxMoeda    := aTxMoedas[SE1->E1_MOEDA][2]
EndIf

If nTxMoeda > 0 .And. oVlEstrang:lModified
	// Converte o valor em moeda estrangeira para identificar o valor total do pagto.
	If cPaisLoc <> "BRA"
		nValRec := Round(NoRound( xMoeda(nValEstrang,SE1->E1_MOEDA,nMoedaBco,dBaixa,3,nTxMoeda,nTxMdaOr) ,3),MsDecimais(SE1->E1_MOEDA))
	Else
		nValRec := Round(NoRound( xMoeda(nValEstrang,SE1->E1_MOEDA,nMoedaBco,dBaixa,3,nTxMoeda) ,3),MsDecimais(SE1->E1_MOEDA)) 
	EndIf

	// Atualiza os objetos
	If cPaisLoc=="BRA" .AND. Type("oTxMoeda") == "O"
		oTxMoeda:Refresh()
	EndIf
	oValRec:Refresh()
	// Calcula a correcao monetaria
	nEstOriginal := nValEstrang-(xMoeda(nJuros+nVa+(nCm1+nProRata)+nMulta-nDescont-nOtrga+nAcresc-nDecresc - Iif(lPccBxCr,nPis+nCofins+nCsll,0)-Iif(lIrPjBxCr,nIrrf,0),nMoedaBco,SE1->E1_MOEDA,,,,nTxMoeda))
	FA070CORR(nEstOriginal,nTxMoeda)
Endif

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fa070LoteFin ³ Autor ³ Claudio Donizete   	³ Data ³ 27/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria trava para lote financeiro na baixa por lote, para        ³±±
±±³          ³ dois usuarios nao utilizem o mesmo numero de lote.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINA070                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fa070LoteFin(cLoteFin,cChaveLbn)
Local lRet := .T.
Local cChave

//-- Parametros da Funcao LockByName() :
//   1o - Nome da Trava
//   2o - usa informacoes da Empresa na chave
//   3o - usa informacoes da Filial na chave
cChave := "CRBXLOTE"+cLoteFin
If !LockByName(cChave,.T.,.F.)
	//-- Se Ja estiver reservado retorna .F. pois nao pode executar a Rotina
	MsgAlert(STR0181,STR0182) // "Existe outro usuário utilizando este mesmo número de lote. Não é permitida a baixa por lote com mesmo número por dois usuários" ## "Atenção"
	lRet := .F.
Else
	cChaveLbn := cChave
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fa070Cm1  ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 19/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao do campo Correcao monetaria 1                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fa070Cm1( oCM1 ,oJuros ,oMulta )                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fa070Cm1( oCM1 ,oJuros ,oMulta )
Local lOk     := .T.
Local aRet    := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Template GEM - Calcula os valores de ProRata, Multa e Juros sobre o Titulo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If HasTemplate("LOT") .and. ExistTemplate("GEMTitRec")
		aRet := ExecTemplate("GEMTitRec",.F.,.F.,{SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA ,nCM1 ,nProRata ,dBaixa })
		If Valtype(aRet) == "A"
			nJuros   := aRet[1]
			nMulta   := aRet[2]
		EndIf
	EndIf

	oCM1:refresh()
	oJuros:refresh()
	oMulta:refresh()

Return( lOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fa070PRata³ Autor ³ Reynaldo Miyashita    ³ Data ³ 19/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao do campo de Pro Rata Atraso diario                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fa070PRata( oProRata ,oJuros ,oMulta )                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA070                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fa070PRata( oProRata ,oJuros ,oMulta, aTitCalc )
Local lOk       := .T.
Local aRet      := {}
Local aPcc		:= {}
Local lIrrfBxPj := FIrPjBxCr(.T.)
Local lPccBxCr	:= FPccBxCr(.T.)

DEFAULT aTitCalc	:= {}

//---------------------------------------------------------------------
// Template GEM - Calcula os valores de Multa e Juros sobre o Titulo
//---------------------------------------------------------------------
If HasTemplate("LOT") .and. ExistTemplate("GEMTitRec")
	aRet := ExecTemplate("GEMTitRec",.F.,.F.,{SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA ,nCM1 ,nProRata ,dBaixa })
	If Valtype(aRet) == "A"
		nJuros   := aRet[1]
		nMulta   := aRet[2]
	EndIf
EndIf

If (!Empty(oProRata) .AND. oProRata:lModified)
	__lCalcImp := .F.	
	dBaixa      := CriaVar("E1_BAIXA")
	nTxMoeda 	:= If(SE1->E1_MOEDA > 1, If(SE1->E1_TXMOEDA > 0, SE1->E1_TXMOEDA,RecMoeda(dBaixa,SE1->E1_MOEDA)),0)

	If __lBordImp .And. !Empty(SE1->E1_NUMBOR)
		__lCalcImp := BorderoImp(SE1->E1_FILORIG, SE1->E1_NUMBOR, "R", SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
	EndIf
	
	If __lFPIXatv .And. !__lCalcImp .And. !__lCnabImp
		__lCalcImp := PIXIsActiv()
	EndIf	
	
	If lPccBxCr
		If dBaixa < dLastPcc
			f070TotMes(dBaixa,.T.,,,,nTxMoeda)
		Else
			aTitCalc := {}

			If !__lPccMR .And. !SE1->E1_TIPO $ MVRECANT .And. !__lCalcImp
				aPcc	:= newMinPcc(dBaixa, nValRec,SE1->E1_NATUREZ,"R",SA1->A1_COD+SA1->A1_LOJA,,,,,,cMotBx)
				nPis	:= aPcc[2]
				nCofins	:= aPcc[3]
				nCsll	:= aPcc[4]
				If len(aPCC) > 4
					aTitCalc := aPCC[5]
				Endif
			Endif
		Endif
	EndIf

	If !__lIrfMR .And. lIrrfBxPj .And. lJurMulDes .And. !__lCalcImp
		nIrrf := IIf(cPaisLoc == "BRA", FCaIrBxCR(nValRec), 0)
	EndIf
Endif

oProRata:refresh()
oJuros:refresh()
oMulta:refresh()

Return( lOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³FA070AtuTT³ Autor ³Norbert Waage Junior   ³ Data ³ 26/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualizacao dos totalizadores da tela                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³FA070AtuTT()                               					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³FINA070				            									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA070AtuTT()
Local nX 		:= 0
Local nTamCol	:= Len(aCols)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Zera acumuladores³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nVlrNomCheq := 0
nVlRefBxChq := 0
nQtdCheq	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Recalcula totais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to nTamCol

	If !aTail(aCols[nX])
		nVlrNomCheq += aCols[nX][5] // VALOR NOMINAL
		If cPaisLoc == "BRA"
			nVlRefBxChq += aCols[nX][6] // VALOR REF. BAIXA
		EndIf
		nQtdCheq 	++
	EndIf

Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza objetos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("oVlrNomCheq") == "O"
	oVlrNomCheq:Refresh()
Endif
If Type("oQtdCheq") == "O"
	oQtdCheq:Refresh()
Endif
If Type("oVlRefBxChq") == "O"
	oVlRefBxChq:Refresh()
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³21/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static function MenuDef()
Local lFa070BUT := .F. //ExistBlock("FA070BUT")
Private aRotina := {}

If __lTemMR == NIL
	__lTemMR := If(FindFunction("FTemMotor"), FTemMotor(), .F.)
EndIf

aAdd( aRotina,	{ STR0001, "AxPesqui" , 0 , 1,,.F. }) //"Pesquisar"

If lIsRussia
	aRotina := RU06XFUN76("FINA070",aRotina,{OemToAnsi(STR0002),OemToAnsi(STR0003),;
	OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0139),OemToAnsi(STR0302),OemToAnsi(STR0306)})
Else
	aAdd( aRotina,	{ STR0002, "fa070Visual" 	, 0 , 2 			}) //"Visualizar"
	aAdd( aRotina,	{ STR0003, "fA070Tit" 		, 0 , 4 			}) //"Baixar"
	aAdd( aRotina,	{ STR0004, "u_xfA070Lot" 		, 0 , 4 			}) //"Lote"
	aAdd( aRotina,	{ STR0005, "fA070Can" 		, 0 , 5 			}) //"Canc Baixa"
	aAdd( aRotina,	{ STR0131, "fA070CAN" 		, 0 , 5	,52			}) //"Excluir"
	aAdd( aRotina,	{ STR0139, "FA040Legenda"	, 0 , 6	, 	,.F.	}) //"Legenda"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica no parametro se gera um Contas a Pagar ³
//³ quando existir taxa na admistradora do cartao,  ³
//³ para habilitar menu de baixa por adminstradora  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SuperGetMV("MV_LJGERTX",,.F.)
	aAdd( aRotina,	{ STR0225, "LJXBxAdmFi" , 0 , 4 }) //"Baixa Adm/Fin."
Endif

//Rateio Multinatureza
If FindFunction("F040CMNT") .and. GetNewPar("MV_MULNATR",.F.)
	aAdd( aRotina,	{ STR0281 ,"F040CMNT()", 0 , 2})	//"Consulta Rateio Multi Naturezas"
Endif

If FindFunction("FTemMotor") .and. __lTemMR
	Aadd(aRotina,{ STR0285,"FINCRET('SE1')", 0, 2}) //'Consulta de Retenções'
EndIf

//If lFa070BUT			
// ExecBlock("FA070BUT",.F.,.F.)
//Endif
Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³F070VLDBCO³ Autor ³ Andre O Anjos         ³ Data ³ 02/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida o cadastro do banco + agencia + conta informados na  ³±±
±±³          ³baixa do titulo (esta funcao foi criada pois a usada anteri ³±±
±±³          ³ormente era falha e permitia o erro do BOPS 133332)		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lVdlCnta : Indica se valida Bco+Ag+Cnta ou somente Bco+Ag   ³±±
±±³			 ³lHelp : Indica se exibe o help FA100BCO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³F070VLDBCO()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³FINA070                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function xF070VldBco(cBco,cAg,cCnta,lVldCnta,lHelp,cChaveBco,lTelaLote)
Local aArea		:= GetArea()
Local lRet 		:= .T.

DEFAULT lVldCnta  := .T.
DEFAULT cChaveBco := "" //Chave para considerar a agencia e/ou conta, quando necessario
DEFAULT lHelp := .F.
DEFAULT lTelaLote := .F.

If !lTelaLote
	If Empty(cChaveBco) .and. !oBanco:lModiFied
		cChaveBco:= cAg + cCnta
	Endif
EndIf

dbSelectArea("SA6")
SA6->(dbSetOrder(1))
If Empty(cBco) .OR. Empty(cAg) .OR. (lVldCnta .And. Empty(cCnta)) .OR. ;
	!SA6->(dbSeek(xFilial("SA6") + cBco + cAg + IIf(lVldCnta,cCnta,"")))
	If (!SA6->(Found()) .OR. SA6->A6_COD # cBco) .OR. Empty(cAg) .OR. (lVldCnta .And. Empty(cCnta))
		If SA6->(dbSeek(xFilial("SA6") + cBco + cChaveBco))
			cAg := SA6->A6_AGENCIA
			cCnta := SA6->A6_NUMCON
		Else
			If lHelp
				Help(" ",1,"FA100BCO")
				lValidou := .T.
			EndIf
			lRet := .F.
		Endif
	Else
		If lHelp
			Help(" ",1,"FA100BCO")
			lValidou := .T.
		EndIf
		lRet := .F.
	Endif
ElseIf !Empty(cBco) .AND. !Empty(cAg) .AND. (!lVldCnta .OR. Empty(cCnta))	//Conta
	If SA6->(Found()) .AND. SA6->(A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON) == xFilial("SA6")+cBco+cAg+cCnta
		If !Empty(SA6->A6_NUMCON)
			cCnta := SA6->A6_NUMCON
		Else
			If lHelp
				Help(" ",1,"FA100BCO")
				lValidou := .T.
			EndIf
			lRet := .F.
		Endif
	Else
		If lHelp
			Help(" ",1,"FA100BCO")
			lValidou := .T.
		EndIf
		lRet := .F.
	Endif
EndIf

// Verifica se o banco selecionado pode ser usado para baixa do titulo
If lRet .AND. !lTelaLote .and. !Empty( cCnta ) .AND. FXMultSld()
	lRet := FXVldBxBco( cBco, cAg, cCnta, SE1->E1_NATUREZ, SE1->E1_MOEDA )
	If !lRet
		lValidou := .T.
	EndIf
EndIf

If lRet .AND. !Empty(cBco) .AND. !Empty(cAg) .AND. !Empty(cCnta) .AND. !(IsInCallStack('u_xFA070LOT')) .AND. AllTrim(Upper(ReadVar())) $ "CBANCO|CAGENCIA|CCONTA"
	If !(cBco + cAg + cCnta == nOldBanco + nOldAgencia + nOldConta)
		nOldBanco 	:= cBco
		nOldAgencia := cAg
		nOldConta 	:= cCnta
		If SA6->A6_RETENCA > 0
			If SA6->(A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON) == xFilial("SA6")+cBco+cAg+cCnta			
				u_xF070Ret()	// "Gatilha" a Data de Crédito dDtCredito (E5_DTDISPO) de acordo com o A6_RETENCA			
			EndIf
		Else
			dDtCredito := dBaixa
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return (lRet)

User Function XAtulValidou() //Faz parte da F070VLDBCO

lValidou := .F.

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FA070Diario º Autor ³ Gustavo Henrique º Data ³  31/05/08  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Seleciona codigo do diario contabil, utilizado na quando   º±±
±±º          ³ selecionada contabilizacao on-line.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Financeiro - Localizacao Portugal                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA070Diario()
Local lRet := .T.

cCodDiario	:= CTBAVerDia()
lRet := !Empty( cCodDiario )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA070   ºAutor  ³Pâmela Bernardo     º Data ³  01/18/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função que totaliza os cheques existentes na SEF para      º±±
±±º          ³ Validar se o Valor do cheque é menor que total de todas as º±±
±±º				Baixas efetuadas com esse numero de cheque                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP  FINA070                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F070TOTCH(cBanco,cAgencia,cConta,cNum,nValorbx,cCliente)
Local aArea := GetArea()
Local aAreaSEF := SEF->(GetArea())
Local nTot := nValorbx
Local cQuery

// Se nao estiver na base ainda, soma o aCols, onde estao os cheques que serao
// cadastrados
cQuery := "SELECT Sum(EF_VALORBX) Soma FROM "+RetSqlName("SEF")+" WHERE "
cQuery += "EF_FILIAL='"+xFilial("SEF")+"' AND "
cQuery += "EF_BANCO='"+cBanco+"' AND "
cQuery += "EF_AGENCIA='"+cAgencia+"' AND "
cQuery += "EF_CONTA='"+cConta+"' AND "
cQuery += "EF_NUM='"+cNum+"' AND "
cQuery += "(EF_FORNECE='"+cCliente+"' OR "
cQuery += " EF_CLIENTE='"+cCliente+"') AND "
cQuery += "D_E_L_E_T_=' '"
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"__SOMACHEQ",.T.,.T.)
nTot += __SOMACHEQ->SOMA
dbCloseArea()

RestArea(aAreaSEF)
RestArea(aArea)

Return nTot

/*/{Protheus.doc} IntegDef
Função para integração via Mensagem Única Totvs.

@author  Wilson de Godoi
@version P12.1.17
@since   06/02/2012
/*/
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

Local aRet := {}
Private aRetMsg	:= {}

If Type("cIntegSeq")=="U"
	PRIVATE cIntegSeq := ""
Endif
aRet := FINI070(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

If Len(aRet) > 0
	If !aRet[1]
		MsgAlert(aRet[2])
	Endif
Endif

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA070   ºAutor  ³TOTVS           º Data ³  03/18/13   		º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Conversão do nPis, nCofins, nCSLL para a nova taxa digitadaº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA070                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F070CnvPcc(nTxMoeda, nMoeda, aTitCalc)
Local lPccBxCr  := FPccBxCr(.T.)
Local lIrPjBxCr := FIrPjBxCr(.T.) //Controla IRPJ na baixa
Local nOutImp   := 0
Local aPcc		:= {}
Local nBase		:= 0
Local lJurMulDes := (SuperGetMv("MV_IMPBAIX",.t.,"2") == "1")

DEFAULT nTxMoeda	:= 0
DEFAULT nMoeda 		:= 1

If __lTemMR
	F070VerImp("2",cFilAnt,SE1->E1_CLIENTE,SE1->E1_LOJA,,.T.,@lIrPjBxCr,@lPccBxCr)
EndIf

__lCalcImp := .F.

If __lBordImp .And. !Empty(SE1->E1_NUMBOR)
	__lCalcImp := BorderoImp(SE1->E1_FILORIG, SE1->E1_NUMBOR, "R", SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
EndIf

If __lFPIXatv .And. !__lCalcImp .And. !__lCnabImp
	__lCalcImp := PIXIsActiv()
EndIf

If lPccBxCr
	If dBaixa < dLastPcc
		f070TotMes(dBaixa,.T.,,,,nTxMoeda)
	Else
		aTitCalc := {}

		If !__lPccMR .And. lJurMulDes .And. !SE1->E1_TIPO $ MVRECANT .And. !__lCalcImp
			nBase	:= FBaseRPCC() // Carrega a base do PCC
			If nBase-nDescont+nJuros+nVa+nMulta+nAcresc-nDecresc > 0
				nBase	:= nBase-nDescont+nJuros+nVa+nMulta+nAcresc-nDecresc
			EndIf
			aPcc	:= newMinPcc(dBaixa, nBase,SE1->E1_NATUREZ,"R",SA1->A1_COD+SA1->A1_LOJA,,,,,,cMotBx)
			nPis	:= aPcc[2]
			nCofins	:= aPcc[3]
			nCsll	:= aPcc[4]
			If len(aPCC) > 4
				aTitCalc := aPCC[5]
			Endif
		Endif
	Endif
Endif

If !__lIrfMR .And. lIrPjBxCr .And. lJurMulDes .And. !__lCalcImp
   	nIrrf:= Iif(cPaisLoc == "BRA" ,FCaIrBxCR(nValRec,,,nTxMoeda),0)
EndIf

nTotAbat  := SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"S",dBaixa,@nOutImp,,,,,,, nTxMoeda)
nTotAbImp:=nOutImp
Fa070Val(0,nTxMoeda)
fa070ValVR(nTxMoeda)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FA070EstBL
Gera estorno na FK5, referente ao cancelamento de baixas a receber realizadas em lote

@param cLoteFin, Lote financeiro da baixa
@param cHistorico, Histórico que será salvo no registro de estorno na FK5
@return Nil

@author Pedro Alencar
@since 11/09/2014
@version P12
/*/
//-------------------------------------------------------------------
Static Function FA070EstBL( cLoteFin, cHistorico, cBanco, cAgenc, cCont )
	Local oModelMov := FWLoadModel( "FINM030" )
	Local oSubFK5 := oModelMov:GetModel( "FK5DETAIL" )
	Local oSubFKA	:= oModelMov:GetModel( "FKADETAIL" )
	Local oModelAux
	Local oSubFK5aux
	Local oSubFKAaux
	Local cLog	 := ""
	Local cProcFK5 := ""
	Local nX := 0
	Local aAuxFK5	:= {}
	Local aCamposFK5 := FK5->( DbStruct() )
	Local nValorES := SE5->E5_VALOR
	Local cIDFK5 := ""
	Local aAreaFK5 := FK5->( GetArea() )
	Local aAreaSE5 := SE5->( GetArea() )
	Default cBanco	:= ""
	Default cAgenc	:= ""
	Default cCont	:= ""

	//Pega o ID do movimento BL na FK5
	FK5->( dbSetOrder( 2 ) ) //Lote + Tipo Doc

	If FK5->( msSeek( FWxFilial("FK5") + cLoteFin + "BL" ) ) .OR. FK5->( msSeek( FWxFilial("FK5") + cLoteFin + "VL" ) )
		cIDFK5 := FK5->FK5_IDMOV
		//-----------------------------------------------------------------------------------------------------------------
		// Alteracao implementada em 23/06/2016:																		  |
		// Funcional apenas para baixas via CNAB feitas ANTES da correção do chamado TVCGOK (FINA200 = 14/06/16). 		  |
		// Retirar este trecho em periodo futuro.																		  |
		//-----------------------------------------------------------------------------------------------------------------
		If AllTrim(FK5->FK5_ORIGEM) $ "FINA200|FINA740"		// Lote gerado pelo retorno CNAB
			While !FK5->(Eof()) .And. FK5->FK5_LOTE == cLoteFin		// Caso haja bancos diferentes no mesmo lote
				If FK5->FK5_FILIAL == FWxFilial("FK5") .And.;
				   AllTrim(FK5->FK5_BANCO) == AllTrim(cBanco) .And.;
				   AllTrim(FK5->FK5_AGENCI) == AllTrim(cAgenc) .And.;
				   AllTrim(FK5->FK5_CONTA) == AllTrim(cCont)
				   cIDFK5 := FK5->FK5_IDMOV
				   Exit
				EndIf
				FK5->(dbSkip())
			EndDo
		EndIf

	Endif
	FK5->( RestArea( aAreaFK5 ) )

	//Posiciona no BL da SE5 para carregar o processo no model e pegar os valores da FK5 para gravar no estorno
	If !Empty( cIDFK5 )
		SE5->( DbSetOrder( 21 ) ) //E5_FILIAL + E5_IDORIG
		If SE5->( msSeek( FWxFilial("SE5") + cIDFK5 ) )
			//Pega o número do processo do BL gerado na baixa em lote
			cProcFK5 := FINProcFKs( cIDFK5, "FK5" )

			oModelAux := FWLoadModel( "FINM030" )
			oModelAux:SetOperation( MODEL_OPERATION_UPDATE ) //Inclusao
			oModelAux:Activate()
			oSubFKAaux := oModelAux:GetModel( "FKADETAIL" )
			oSubFK5aux := oModelAux:GetModel( "FK5DETAIL" )

			If oSubFKAaux:SeekLine( { { "FKA_IDORIG", cIDFK5 } } )
				For nX := 1 To Len( aCamposFK5 )
					aAdd( aAuxFK5, oSubFK5aux:GetValue( aCamposFK5[nX][1] ) )
				Next nX
			Endif
			oModelAux:DeActivate()
			oModelAux:Destroy()
			oModelAux:= Nil
		Endif
	 	SE5->( RestArea( aAreaSE5 ) )

		//Inicializo o model
		oModelMov:SetOperation( MODEL_OPERATION_INSERT ) //Inclusao
		oModelMov:Activate()
		oModelMov:SetValue( "MASTER", "E5_GRV", .F. ) //Informa se vai gravar SE5 ou não
		oModelMov:SetValue( "MASTER", "NOVOPROC", .F. ) //Não cria um novo processo
		oModelMov:SetValue( "MASTER", "IDPROC", cProcFK5 ) //Define o número do processo para o estorno do BL

		If !oSubFKA:IsEmpty()
			oSubFKA:AddLine()
		Endif

		oSubFKA:SetValue( "FKA_IDORIG", FWUUIDV4() )
		oSubFKA:SetValue( "FKA_TABORI", "FK5" )

		If Len( aAuxFK5 ) > 0
			For nX := 1 To Len(aCamposFK5)
				oSubFK5:SetValue( aCamposFK5[nX][1], aAuxFK5[nX] )
			Next nX
		Endif

		oSubFK5:SetValue( "FK5_TPDOC", "ES" )
		oSubFK5:SetValue( "FK5_RECPAG", "P" )
		oSubFK5:SetValue( "FK5_HISTOR", cHistorico )
		oSubFK5:SetValue( "FK5_VALOR", nValorES )
		oSubFK5:SetValue( "FK5_DATA", dDataBase )
		cBanco := oSubFK5:GetValue("FK5_BANCO")
		cAgenc := oSubFK5:GetValue("FK5_AGENCI")
		cCont  := oSubFK5:GetValue("FK5_CONTA")

		If oModelMov:VldData()
			oModelMov:CommitData()
		Else
			cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
			cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
			cLog += cValToChar(oModelMov:GetErrorMessage()[6])

			Help( , , "M30F070EST", , cLog, 1, 0 )
		Endif
		oModelMov:DeActivate()
		oModelMov:Destroy()
		oModelMov:= Nil
	Endif

	SE5->( RestArea( aAreaSE5 ) )

Return Nil

Static Function ConfIRRF(nValor,oIrrf)
Local lIrrfBxPj := FIrPjBxCr(.T.)
Local lret := .T.

If nValor == 0 .and. !lIrrfBxPj
	If  !MsgYesNo( STR0267+chr(13)+chr(10) +STR0268+chr(13)+chr(10) +STR0269, STR0144) //"Ao zerar o valor do imposto gerado na emissão,"#"o título de imposto será excluído definitivamente."#"Deseja realmente zerar o valor?"
		nValor := SE1->E1_IRRF
		oIrrf:Refresh()
		lRet := .f.

	EndIf
EndIf
Return lret



//-------------------------------------------------------------------
/*/{Protheus.doc}FBaseRPCC
Consiste valor base de calculo do PCC.
@author Leonardo Castro
@since  19/02/2016
@version 12
/*/
//-------------------------------------------------------------------
Static Function FBaseRPCC(nValorRec,lCalcPCC)
Local lFINA450	:= FwIsInCallStack("FA450CMP")
Local nValBase	:= 0
Local nBaseRet	:= 0
Local aBase 	:= {}
Local nX 		:= 0
Local cChaveAux := ""
Local nBase	 	:= If(SE1->E1_BASECSL > 0, SE1->E1_BASECSL, If(SE1->E1_BASEPIS > 0, SE1->E1_BASEPIS, If(SE1->E1_BASECOF > 0, SE1->E1_BASECOF, 0)))
Local nParc		:= 0

DEFAULT nValorRec	:= nBase
DEFAULT lCalcPcc	:= .T.

If __lTemMR .And. __lPccMR .And. nBase == 0
	cChaveAux := FWxFilial( "SE1", SE1->E1_FILORIG ) + "|" + SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA

	aBase := FinImpFis(cChaveAux,SE1->E1_FILORIG,"SE1")
	For nX := 1 to Len(aBase)
		nBase := aBase[nX][2]
	Next
Endif

nParc := IF(Type("nParciais") != "N", 0, nParciais)// real

If FindFunction("FxIsBxTotal")
	/*
		- Se o valor vai baixar Totalmente o título -> considerar base - Parciais (Parciais é considerado mais abaixo)
		- Ou se o valor não vai baixar totalmente -> considerar como base o valor passado (nValRec normalmente) - Valor Recebido
	*/	
	If FxIsBxTotal( nValorRec , nParc , __nMRBxTot )	
		nValorRec := nBase
	EndIf
Else
	nValorRec := IIF(ReadVar() == "NVALREC" .or. ReadVar() == "NVALESTRANG", nValorRec, nBase)
EndIf

nValBase := nBase
nMoedaBco	:= IF(Type("nMoedaBco") != "N", 1, nMoedaBco)

If SE1->E1_MOEDA > 1
	nParc	:= xMoeda(nParc,nMoedaBco,SE1->E1_MOEDA,dDatabase,3,,nTxMoeda)
EndIf

If FwIsInCallStack("u_xFA070VALREC") .and. SE1->E1_MOEDA > 1// Se for alteração o valor a ser baixado vem em dolar
	nValorRec	:= xMoeda(nValorRec,nMoedaBco,SE1->E1_MOEDA,dDatabase,3,,nTxMoeda)
EndIf

If lFINA450
	nValBase := nValorRec
ElseIf nParc < nValBase // Se o valor das baixas parciais nao atingiram o valor da base.
	nValBase := nValBase - nParc
	If nValorRec < nValBase
		nValBase := nValorRec
	EndIf
Else // Se ja alcançou a base de calculo.
	nBaseRet	:= 0
	lCalcPcc	:= .F.
EndIf

nBaseRet := nValBase

Return nBaseRet

//-------------------------------------------------------------------
/*/{Protheus.doc}getVlIss
pega o valor do ISS
@author Fernando Amorim
@since  18/08/15
@version 12
/*/
//-------------------------------------------------------------------

Static Function getVlIss(cFil,cChave)
Local aAreaAt		:= getArea()
Local cAliasQry	:= GetNextAlias()
Local cQuery		:= ""
Local nValor		:= 0
Local cTipo 		:= "IS-"
Local cNatu 		:= "ISS"

Default cFil		:= xFilial("SE1")
Default cChave		:= ""

cQuery := " SELECT SUM(E1_VALOR) VALOR "
cQuery += " FROM "+RetSQLName("SE1")+" SE1 "
cQuery += " WHERE E1_TIPO = '"+cTipo+"'  "
cQuery += " AND E1_NATUREZ = '"+cNatu+"' "
cQuery += " AND E1_FILIAL = '"+cFil+"'  "
cQuery += " AND E1_TITPAI LIKE '%"+cChave+"%' "
cQuery += " AND SE1.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery( cQuery )

If Select(cAliasQry) > 0
	( cAliasQRY )->( dbCloseArea() )
Endif

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

DbSelectArea(cAliasQry)
DbGoTop()

While !Eof()
	TCSetField(cAliasQry, "VALOR" ,"N",16,2)
	nValor := (cAliasQry)->(VALOR)
	DbSkip()
EndDo

If Select(cAliasQry) > 0
	(cAliasQRY)->(dbCloseArea())
Endif

RestArea(aAreaAt)

Return nValor

/*/{Protheus.doc} LjBxDup
Tem o objetivo de remover os registros das baixas pagas em R$
@type		function
@param		aBaixa
@author  	michael.gabriel
@version 	P11.80
@since   	06/06/2017
@return  	aRetBaixa
@obs		Quando há uma baixa em R$ no LOJA, ele gera dois registros baixados na SE5,
			causando duplicidade na exibicao das baixas que podem ser estornadas.
/*/
Static Function LjBxDup( aBaixa )
Local cUltBaixa	:= ""		//indica a ultima baixa
Local nI		:= 0
Local aRetBaixa	:= {{},{}}	//[1]aBaixa tratado (sem duplicidade) [2] aBaixa Original
Local aAuxBaixa	:= {}		//copia do aBaixa, pois ele sera reordenado

Default aBaixa	:= {}

// copia o aBaixa original, pois ele sera ordenado
aAuxBaixa := aClone( aBaixa )

// ordena o aBaixa copiado em ordem crescente
aSort( aAuxBaixa, /*nInicio*/, /*nItens*/, {|x,y| x > y} )

For nI := 1 to Len(aAuxBaixa)
	If cUltBaixa <> aAuxBaixa[nI]
		// adiciona a baixa valida ao retorno
		Aadd( aRetBaixa[1], aAuxBaixa[nI] )
		//obtem a baixa para a comparacao com a proxima
		cUltBaixa := aAuxBaixa[nI]
	EndIf
Next

//copia o conteudo original do aBaixa, pois ele sera restaurado
aRetBaixa[2] := aClone( aBaixa )

// destroi o vetor auxiliar
aSize( aAuxBaixa, 0 )
aAuxBaixa := Nil

Return aRetBaixa

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa070bAval
Bloco de Marcação da Markbrowse

@author Mauricio Pequim Jr
@since  06/01/2016
@version 12.1.7
/*/
//-------------------------------------------------------------------
Static Function Fa070bAval(cAliasSE1,cMarca,oValor,oQtda)
Local lRet	:= .T.

SE1->(dbGoto((cAliasSE1)->RECNOSE1))

lRet	:=	FA070Integ(.F.)

If lRet
	// Verifica se o registro nao esta sendo utilizado em outro terminal
	If SE1->(MsRLock()) .AND. (cAliasSE1)->(MsRLock())
		FA070Inverte(cMarca,oValor,oQtda,.F.,cAliasLote) // Marca o registro e trava
		lRet := .T.
	Else
		IW_MsgBox(STR0215,STR0144,"STOP")  //"Este titulo está sendo utilizado em outro terminal, não pode ser utilizado na fatura"###"Atenção"
		lRet := .F.
	Endif
Endif
Return lRet


//-------------------------------------------------------------------------
/*/{Protheus.doc} F70VlDsc
Função de Validação do campo de desconto
@param lTpDesc, flag para verificar o campo TPDESC na tabela SE5 (<C>ondicional ou <I>ncondicional)
@param lNatApura, flag para verificar se a Natureza está configurada para apurar impostos no SPED PIS/COFINS
@return lRet – Retorna se o valor de desconto digitado é válido ou não
@author Rogerio Melonio
@since  04/04/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------------
Static Function F70VlDsc( lTpDesc as Logical , lNatApura As Logical ) As Logical
	Local lRet 		As Logical
	Local l070Desc  As Logical
	Local l070Valor As Logical
	Local lBolsaRM  As Logical
	Local nBolsaRM  As Numeric
	
	Default lTpDesc   := .F.
	Default lNatApura := .F.

	lRet 		:= .T.
	l070Desc 	:= .T.
	l070Valor 	:= .T.
	lBolsaRM 	:= .T.
	nBolsaRM 	:= 0

	If ( nOldDescont <> nDescont ) .And.  (!Empty(oDescont) .AND. oDescont:lModified)

		l070Desc := u_xFA070DESC(oDescont)

		If nDescont > (xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,nMoedaBco,dBaixa,,nTxMoeda) + nJuros+nVA+nMulta+nAcresc-nDecresc)
			lRet	:= .F.
		EndIf
		If lRet
			l070Valor := fA070Val(nDescont,nTxMoeda)
		EndIf

		//Se houver valor de bolsa informado no título (título do RM educacional), então não deixa digitar um desconto menor do que o valor da bolsa
		nBolsaRM := SE1->E1_VLBOLSA
		If nBolsaRM > 0
			If nDescont >= nBolsaRM
				lBolsaRM := .T.
			Else
				lBolsaRM := .F.
				Help( ,, "F70VlDscBolsa",, STR0288 + cValToChar(nBolsaRM), 1, 0,,,,,, {STR0289} ) //"O título a ser baixado possuí um valor de bolsa informado. O valor de desconto não pode ser inferior ao valor de bolsa. Valor da bolsa: ", "Informe um valor de desconto igual ou superior ao valor de bolsa. Caso o valor de bolsa esteja incorreto, verifique tal informação junto ao sistema educacional integrado."
			EndIf
		Else
			lBolsaRM := .T.
		EndIf

		If lRet
			lRet := l070Desc .And. l070Valor .And. ( nDescont <= (xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,nMoedaBco,dBaixa,,nTxMoeda)+ nJuros+nVA+nMulta+nAcresc-nDecresc) ) .And. lBolsaRM
		EndIf

		If lRet
			nOldDescont := nDescont
			If lNatApura
				Fa070DesCI(lTpDesc,lNatApura)
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValTxMoeda()
Validação do campo Taxa Contratada
@author rafael.ronodn
@since 09/09/2019
@version 12
/*/
//-------------------------------------------------------------------
Static Function ValTxMoeda( nTxMoeda 	As Numeric , nOldTxmoeda	As Numeric , nMulta As Numeric , nOldMulta As Numeric , ;
							nJuros 		As Numeric , nOldJuros		As Numeric , aTitCalc As Array ) As Logical

If nOldTxmoeda <> nTxMoeda

	If nOldJuros + nJuros > 0 
		fA070Data(nTxMoeda,.F.,,,,.T.,,,,aTitCalc)
	EndIf

	If nOldMulta + nMulta > 0
		fA070Val(nMulta,nTxMoeda)
	EndIf

	F070CnvPcc(nTxMoeda, SE1->E1_MOEDA)

	nOldTxmoeda := nTxMoeda

EndIf

Return .T.


/*/{Protheus.doc} F070TemMR
	Verifica se o fornecedor em questão possui amarração com o 
	configurador de tributos

	@Type Static Function
	@author Vitor Duca
	@since 03/12/2020
	@version 1.0
	@param cCodCli, Character, Codigo do Cliente
	@param cLoja, Character, Loja do Cliente
	@return lRet, Logical, Se achou a amarração com o configurador
	@example
	F070TemMR(SA1->A1_COD,SA1->A1_LOJA)
/*/
Static Function F070TemMR(cCodCli As Character, cLoja As Character) As Logical
	Local lRet As Logical
	Local aArea As Array

	Default cCodFor := ""
	Default cLoja	:= ""

	aArea := GetArea()
	lRet := .F.

	FOJ->(DbSetOrder(1))
	lRet := FOJ->(MsSeek(xFilial("FOJ")+cCodCli+cLoja))

	RestArea(aArea)
Return lRet

Static Function Get070Mark()
Local cMarca

cMarca :=GetMark()
While cMarca == "xx"
  cMarca := Getmark()
End
Return cMarca
