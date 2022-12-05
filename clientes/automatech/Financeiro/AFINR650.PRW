#INCLUDE "finr650.CH"
#Include "PROTHEUS.CH"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para tratamento dos Sub-Totais por Ocorrencia  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE DESPESAS           3
#DEFINE DESCONTOS          4
#DEFINE ABATIMENTOS        5
#DEFINE VALORRECEBIDO      6
#DEFINE JUROS              7
#DEFINE VALORIOF			8
#DEFINE VALORCC				9
#DEFINE VALORORIG			10

// 17/08/2009 - Compilacao para o campo filial de 4 posicoes
// 18/08/2009 - Compilacao para o campo filial de 4 posicoes

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FINR650  ³ Autor ³ Marcel Borges Ferreira ³ Data ³ 03/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impress„o do Retorno da Comunica‡„o Banc ria                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FinR650()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function aFinr650()

Local oReport

AjustaSX1()

If FindFunction("TRepInUse") .And. TRepInUse() .And. !IsBlind()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:=ReportDef()
	oReport:PrintDialog()
	
Else
	u_autr650R3()
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Marcel Borges Ferreira ³ Data ³ 17/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ReportDef()

Local oReport

Pergunte("FIN650",.F.)

oReport := TReport():New("FINR650",STR0004,"FIN650",{|oReport| ReportPrint(oReport)},STR0001+STR0002+STR0003)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Secao 1 - Titulos a Receber  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oSection1 := TRSection():New(oReport,STR0047)
TRCell():New(oSection1,"SEC1_TIT",,STR0031,,25,,)
TRCell():New(oSection1,"SEC1_CLI",,STR0032,,10,,)
TRCell():New(oSection1,"SEC1_OCOR",,STR0033,,31,,)
TRCell():New(oSection1,"SEC1_DTOCOR",,STR0034,,10,,)
TRCell():New(oSection1,"SEC1_VORIG",,StrTran(STR0035," ",CRLF),"@E 99999,999.99",12,,,"RIGHT",,"RIGHT")
TRCell():New(oSection1,"SEC1_VRECE",,StrTran(STR0036," ",CRLF),"@E 99999,999.99",12,,,"RIGHT",,"RIGHT")
TRCell():New(oSection1,"SEC1_VPAGO",,StrTran(STR0037," ",CRLF),"@E 99999,999.99",12,,,"RIGHT",,"RIGHT")
TRCell():New(oSection1,"SEC1_DCOB" ,,StrTran(STR0038," ",CRLF),"@E 99999,999.99",12,,,"RIGHT",,"RIGHT")
TRCell():New(oSection1,"SEC1_VDESC",,StrTran(STR0039," ",CRLF),"@E 99999,999.99",12,,,"RIGHT",,"RIGHT")
TRCell():New(oSection1,"SEC1_VABAT",,StrTran(STR0040," ",CRLF),"@E 99999,999.99",12,,,"RIGHT",,"RIGHT")
TRCell():New(oSection1,"SEC1_VJURO",,StrTran(STR0041," ",CRLF),"@E 99999,999.99",12,,,"RIGHT",,"RIGHT")
TRCell():New(oSection1,"SEC1_VIOF" ,,StrTran(STR0042," ",CRLF),"@E 99999,999.99",12,,,"RIGHT",,"RIGHT")
TRCell():New(oSection1,"SEC1_OCRED",,StrTran(STR0044," ",CRLF),"@E 99999,999.99",12,,,"RIGHT",,"RIGHT")
TRCell():New(oSection1,"SEC1_DTCRED",,STR0045,,10,,)
TRCell():New(oSection1,"SEC1_NTIT",,STR0043,,19,,)
TRCell():New(oSection1,"SEC1_CONS",,STR0046,,26,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Secao 3 - Subtotais ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oSection2 := TRSection():New(oReport,STR0048)
TRCell():New(oSection2,"STOT_TIT",,STR0027,,69,,)
TRCell():New(oSection2,"STOT_VORIG",,StrTran(STR0035," ",CRLF),"@E 99999,999.99",12,,,"RIGHT",,"RIGHT")
TRCell():New(oSection2,"STOT_VRECE",,StrTran(STR0036," ",CRLF),"@E 99999,999.99",12,,,"RIGHT",,"RIGHT")
TRCell():New(oSection2,"STOT_VPAGO",,StrTran(STR0037," ",CRLF),"@E 99999,999.99",12,,,"RIGHT",,"RIGHT")
TRCell():New(oSection2,"STOT_DCOB" ,,StrTran(STR0038," ",CRLF),"@E 99999,999.99",12,,,"RIGHT",,"RIGHT")
TRCell():New(oSection2,"STOT_VDESC",,StrTran(STR0039," ",CRLF),"@E 99999,999.99",12,,,"RIGHT",,"RIGHT")
TRCell():New(oSection2,"STOT_VABAT",,StrTran(STR0040," ",CRLF),"@E 99999,999.99",12,,,"RIGHT",,"RIGHT")
TRCell():New(oSection2,"STOT_VJURO",,StrTran(STR0041," ",CRLF),"@E 99999,999.99",12,,,"RIGHT",,"RIGHT")
TRCell():New(oSection2,"STOT_VIOF" ,,StrTran(STR0042," ",CRLF),"@E 99999,999.99",12,,,"RIGHT",,"RIGHT")
TRCell():New(oSection2,"STOT_OCRED",,StrTran(STR0044," ",CRLF),"@E 99999,999.99",12,,,"RIGHT",,"RIGHT")


oSection2:SetHeaderSection(.T.)
oReport:SetLandScape()

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³Marcel Borges Ferreira ³ Data ³ 23/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportPrint devera ser criada para todos os³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.           ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                            ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ReportPrint(oReport)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)


Local cPosPrin,cPosJuro,cPosMult,cPosCC ,cPosTipo
Local cPosNum ,cPosData,cPosDesp,cPosDesc,cPosAbat,cPosDtCC,cPosIof,cPosOcor
Local cPosNosso, cPosForne, cPosCgc
Local lPosNum  := .f. , lPosData := .f. , lPosAbat := .f.
Local lPosDesp := .f. , lPosDesc := .f. , lPosMult := .f.
Local lPosPrin := .f. , lPosJuro := .f. , lPosDtCC := .f.
Local lPosOcor := .f. , lPosTipo := .f. , lPosIof  := .f.
Local lPosCC   := .f. , lPosNosso:= .f. , lPosRej	:= .f.
Local lPosForne:=.f. , lPosCgc := .F.
Local nLidos ,nLenNum  ,nLenData ,nLenDesp ,nLenDesc ,nLenAbat ,nLenDtCC, nLenCGC
Local nLenPrin ,nLenJuro ,nLenMult ,nLenOcor ,nLenTipo ,nLenIof  ,nLenCC
Local nLenRej := 0
Local cArqConf ,cArqEnt ,nTipo
Local tamanho   := "G", lOcorr := .F.
Local cDescr
Local cDescr2
LOCAL cEspecie,cData,nTamArq,cForne,cCgc
Local nValIof	:= 0
Local nHdlBco  := 0
Local nHdlConf := 0
Local cTabela 	:= "17"
Local lRej := .f.
Local cCarteira
Local nTamDet
Local lHeader := .f.
Local lTrailler:= .F.
Local aTabela 	:= {}
Local cChave650
Local nPos := 0
Local lAchouTit := .F.
Local nValPadrao := 0
Local aValores := {}
LOCAL lF650Var := ExistBlock("F650VAR" )
LOCAL dDataFin := Getmv("MV_DATAFIN")
Local nCont
Local lOk
Local x
Local nCntOco  := 0
Local aCntOco  := {}
Local cCliFor	:= "  "
Local lFr650Fil:= ExistBlock("FR650FIL")
Local nValOrig	:= 0
Local nOriT := 0
Local nTamPre	:= TamSX3("E1_PREFIXO")[1]
Local nTamNum	:= TamSX3("E1_NUM")[1]
Local nTamPar	:= TamSX3("E1_PARCELA")[1]
Local nTamTit	:= nTamPre+nTamNum+nTamPar
Local nTamForn	:= Tamsx3("E2_FORNECE")[1]
Local lPrint := .T.
Local nTit
Local nVOrig
Local nVReceb
Local nDCOB
Local nVDESC
Local nVABAT
Local nVJURO
Local nVIOF
Local nOCRED
Local cDestino := ""
Local cBarra := If(isSrvUnix(),"/","\")
Local cFileName := ""
Local lNewIndice := FaVerInd()  //Verifica a existencia dos indices de IDCNAB sem filial
Local aFile	:= ""
Local aArqConf	:= {}		// Atributos do arquivo de configuracao
Local aAreaSE1	:= {}
Local aAreaSE2	:= {}

PRIVATE m_pag , cbtxt , cbcont , li

//Essas variaveis tem que ser private para serem manipuladas
//nos pontos de entrada, assim como eh feito no FINA200
Private cNumTit
Private dBaixa
Private cTipo
Private cNossoNum
Private nDespes	:= 0
Private nDescont	:= 0
Private nAbatim	:= 0
Private nValrec	:= 0
Private nJuros	:= 0
Private nMulta	:= 0
Private nValCc	:= 0
Private dCred
Private cOcorr
Private xBuffer

// Guarda area do contas a receber ou contas a pagar
If mv_par07 == 1	// Receber
	aAreaSE1 := SE1->(GetArea())
Else				// Pagar
	aAreaSE2 := SE2->(GetArea())
EndIf
oReport:SetTitle(STR0004+' - '+mv_par01)		//"Impressao do Retorno da Comunicacao Bancaria"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca tamanho do detalhe na configura‡„o do banco            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SEE")
If dbSeek(xFilial("SEE")+mv_par03+mv_par04+mv_par05+mv_par06)
	nTamDet:= Iif(Empty (SEE->EE_NRBYTES), 400, SEE->EE_NRBYTES)
	ntamDet+= 2  // Ajusta tamanho do detalhe para leitura do CR (fim de linha)
Else
	Set Device To Screen
	Set Printer To
	Help(" ",1,"NOBCOCAD")
	Return .F.
Endif

cTabela := Iif( Empty(SEE->EE_TABELA), "17" , SEE->EE_TABELA )

dbSelectArea( "SX5" )
If !SX5->( dbSeek( cFilial + cTabela ) )
	Help(" ",1,"PAR150")
	Return .F.
Endif
While !SX5->(Eof()) .and. SX5->X5_TABELA == cTabela
	AADD(aTabela,{Alltrim(X5Descri()),Pad(SX5->X5_CHAVE,Len(IIF(mv_par07==1,SE1->E1_TIPO,SE2->E2_TIPO)))})
	SX5->(dbSkip( ))
Enddo

IF mv_par08 == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abre arquivo de configura‡„o ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cArqConf:=mv_par02
	IF !FILE(cArqConf)
		Set Device To Screen
		Set Printer To
		Help(" ",1,"NOARQPAR")
		Return .F.
	Else
		nHdlConf:=FOPEN(cArqConf,0+64)
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Lˆ arquivo de configura‡„o ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLidos :=0
	FSEEK(nHdlConf,0,0)
	nTamArq:=FSEEK(nHdlConf,0,2)
	FSEEK(nHdlConf,0,0)
	
	While nLidos <= nTamArq
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o tipo de qual registro foi lido ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		xBuffer:=Space(85)
		FREAD(nHdlConf,@xBuffer,85)
		
		IF SubStr(xBuffer,1,1) == CHR(1)
			nLidos+=85
			Loop
		EndIF
		IF !lPosNum
			cPosNum:=Substr(xBuffer,17,10)
			nLenNum:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosNum:=.t.
			nLidos+=85
			Loop
		EndIF
		IF !lPosData
			cPosData:=Substr(xBuffer,17,10)
			nLenData:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosData:=.t.
			nLidos+=85
			Loop
		EndIF
		IF !lPosDesp
			cPosDesp:=Substr(xBuffer,17,10)
			nLenDesp:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosDesp:=.t.
			nLidos+=85
			Loop
		EndIF
		IF !lPosDesc
			cPosDesc:=Substr(xBuffer,17,10)
			nLenDesc:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosDesc:=.t.
			nLidos+=85
			Loop
		EndIF
		IF !lPosAbat
			cPosAbat:=Substr(xBuffer,17,10)
			nLenAbat:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosAbat:=.t.
			nLidos+=85
			Loop
		EndIF
		IF !lPosPrin
			cPosPrin:=Substr(xBuffer,17,10)
			nLenPrin:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosPrin:=.t.
			nLidos+=85
			Loop
		EndIF
		IF !lPosJuro
			cPosJuro:=Substr(xBuffer,17,10)
			nLenJuro:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosJuro:=.t.
			nLidos+=85
			Loop
		EndIF
		IF !lPosMult
			cPosMult:=Substr(xBuffer,17,10)
			nLenMult:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosMult:=.t.
			nLidos+=85
			Loop
		EndIF
		IF !lPosOcor
			cPosOcor:=Substr(xBuffer,17,10)
			nLenOcor:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosOcor:=.t.
			nLidos+=85
			Loop
		EndIF
		IF !lPosTipo
			cPosTipo:=Substr(xBuffer,17,10)
			nLenTipo:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosTipo:=.t.
			nLidos+=85
			Loop
		EndIF
		
		If mv_par07 == 1						// Somente cart receber deve ler estes campos
			IF !lPosIof
				cPosIof:=Substr(xBuffer,17,10)
				nLenIof:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosIof:=.t.
				nLidos+=85
				Loop
			EndIF
			IF !lPosCC
				cPosCC:=Substr(xBuffer,17,10)
				nLenCC:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosCC:=.t.
				nLidos+=85
				Loop
			EndIF
			IF !lPosDtCc
				cPosDtCc:=Substr(xBuffer,17,10)
				nLenDtCc:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosDtCc:=.t.
				nLidos+=85
				Loop
			EndIF
		EndIf
		
		IF !lPosNosso
			cPosNosso:=Substr(xBuffer,17,10)
			nLenNosso:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosNosso:=.t.
			nLidos+=85
			Loop
		EndIF
		IF !lPosRej
			cPosRej:=Substr(xBuffer,17,10)
			nLenRej:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosRej:=.t.
			nLidos+=85
			Loop
		EndIF
		If mv_par07 == 2
			IF !lPosForne
				cPosForne := Substr(xBuffer,17,10)
				nLenForne := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosForne := .t.
				nLidos += 85
				Loop
			EndIF
			IF !lPosCgc
				cPosCgc   := Substr(xBuffer,17,10)
				nLenCgc   := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosCgc   := .t.
				nLidos += 85
				Loop
			EndIF
		Endif
		Exit
	EndDo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ fecha arquivo de configuracao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Fclose(nHdlConf)
Endif

cArqEnt:=mv_par01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o arquivo de entrada esta na maquina local, e se estiver copia para o servidor ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Substr(mv_par01,2,2)== ":"+cBarra
	aFile := Directory(mv_par01)
	If Empty(aFile)
		cArqEnt := ""
	Else
		cFileName := aFile[1][1]
		cDestino := GetSrvProfString("StartPath","")+If(Right(GetSrvProfString("StartPath",""),1) == cBarra,"",cBarra)+"CNABTmp"
		If !File(cDestino)
			MAKEDIR(cDestino)
		EndIf
		If CpyT2S(mv_par01,cDestino,.T.)
			cArqEnt := cDestino+cBarra+cFileName
		Else
			Help(" ",1,"F650COPY",,STR0049,1,0) //"Não foi possível copiar o arquivo de entrada para o servidor. O arquivo será processado a partir da máquina local, para um melhor desempenho, copie o arquivo diretamente no servidor."
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre arquivo enviado pelo banco ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !FILE(cArqEnt)
	Set Device To Screen
	Set Printer To
	Help(" ",1,"NOARQENT")
	Return .F.
Else
	nHdlBco:=FOPEN(cArqEnt,0+64)
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lˆ arquivo enviado pelo banco ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLidos:=0
FSEEK(nHdlBco,0,0)
nTamArq:=FSEEK(nHdlBco,0,2)
FSEEK(nHdlBco,0,0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Valores da Secao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:Cell("SEC1_TIT"):SetBlock({||cNumTit+' '+cEspecie})
oSection1:Cell("SEC1_CLI"):SetBlock({||cCliFor})
oSection1:Cell("SEC1_OCOR"):SetBlock({||Subs(cDescr,1,26)})
oSection1:Cell("SEC1_DTOCOR"):SetBlock({||dBaixa})
oSection1:Cell("SEC1_VORIG"):SetBlock({||nValOrig})
oSection1:Cell("SEC1_DCOB"):SetBlock({||nDespes})
oSection1:Cell("SEC1_VDESC"):SetBlock({||nDescont})
oSection1:Cell("SEC1_VABAT"):SetBlock({||nAbatim})
oSection1:Cell("SEC1_VJURO"):SetBlock({||(nJuros+nMulta)})
oSection1:Cell("SEC1_NTIT"):SetBlock({||Pad(cNossoNum,19)})
oSection1:Cell("SEC1_CONS"):SetBlock({||cDescr2})

oSection2:Cell("STOT_TIT"):SetBlock({||nTit})
oSection2:Cell("STOT_VORIG"):SetBlock({||nVOrig})

oSection2:Cell("STOT_DCOB"):SetBlock({||nDCOB})
oSection2:Cell("STOT_VDESC"):SetBlock({||nVDESC})
oSection2:Cell("STOT_VABAT"):SetBlock({||nVABAT})
oSection2:Cell("STOT_VJURO"):SetBlock({||nVJURO})



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Totalizador                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

TRFunction():New (oSection2:Cell("STOT_VORIG"),,"SUM",,,"@E 99999,999.99",,.F.,.T.)
TRFunction():New (oSection2:Cell("STOT_DCOB"),,"SUM",,,"@E 99999,999.99",,.F.,.T.)
TRFunction():New (oSection2:Cell("STOT_VDESC"),,"SUM",,,"@E 99999,999.99",,.F.,.T.)
TRFunction():New (oSection2:Cell("STOT_VABAT"),,"SUM",,,"@E 99999,999.99",,.F.,.T.)
TRFunction():New (oSection2:Cell("STOT_VJURO"),,"SUM",,,"@E 99999,999.99",,.F.,.T.)


If mv_par07 == 1
	
	oSection1:Cell("SEC1_VPAGO"):Disable()
	oSection2:Cell("STOT_VPAGO"):Disable()
	
	oSection1:Cell("SEC1_VIOF"):SetBlock({||nValIof})
	oSection1:Cell("SEC1_OCRED"):SetBlock({||nValCc})
	oSection1:Cell("SEC1_DTCRED"):SetBlock({||If(Empty(dCred),dDataBase,dCred)})
	
	oSection1:Cell("SEC1_VRECE"):SetBlock({||nValRec})
	oSection2:Cell("STOT_VIOF"):SetBlock({||nVIOF})
	oSection2:Cell("STOT_OCRED"):SetBlock({||nOCRED})
	oSection2:Cell("STOT_VRECE"):SetBlock({||nVReceb})
	
	TRFunction():New (oSection2:Cell("STOT_VIOF"),,"SUM",,,"@E 99999,999.99",,.F.,.T.)
	TRFunction():New (oSection2:Cell("STOT_OCRED"),,"SUM",,,"@E 99999,999.99",,.F.,.T.)
	TRFunction():New (oSection2:Cell("STOT_VRECE"),,"SUM",,,"@E 99999,999.99",,.F.,.T.)
Else
	
	oSection1:Cell("SEC1_VRECE"):Disable()
	oSection1:Cell("SEC1_VIOF"):Disable()
	oSection1:Cell("SEC1_OCRED"):Disable()
	oSection1:Cell("SEC1_DTCRED"):Disable()
	oSection2:Cell("STOT_VIOF"):Disable()
	oSection2:Cell("STOT_OCRED"):Disable()
	oSection2:Cell("STOT_VRECE"):Disable()
	
	
	oSection1:Cell("SEC1_VPAGO"):SetBlock({||nValRec})
	oSection2:Cell("STOT_VPAGO"):SetBlock({||nVReceb})
	
	TRFunction():New (oSection2:Cell("STOT_VPAGO"),,"SUM",,,"@E 99999,999.99",,.F.,.T.)
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega atributos do arquivo de configuracao                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aArqConf := Directory(mv_par02)

oReport:SetTotalText(STR0023)
oReport:SetTotalinLine(.F.)
oReport:SetMeter(nTamArq/nTamDet)

oSection1:Init()
While nTamArq-nLidos >= nTamDet
	
	If oReport:Cancel() .AND. oReport:Cancel()
		Exit
	EndIf
	
	If mv_par08 == 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tipo qual registro foi lido ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		xBuffer:=Space(nTamDet)
		FREAD(nHdlBco,@xBuffer,nTamDet)
		
		oReport:IncMeter()
		
		IF !lHeader
			nLidos+=nTamDet
			lHeader := .t.
			Loop
		EndIF
		
		IF	SubStr(xBuffer,1,1) == "0" .or. SubStr(xBuffer,1,1) == "9" .or. ;
			SubStr(xBuffer,1,1) == "8" .or. SubStr(xBuffer,1,1) == "5"
			nLidos+=nTamDet
			Loop
		EndIF
		
		If SubStr(xBuffer,1,1) $ "1#F#J#7#2" .or. Substr(xBuffer,1,3) == "001"
			nDespes :=0
			nDescont:=0
			nAbatim :=0
			nValRec :=0
			nJuros  :=0
			nMulta  :=0
			If mv_par07 == 1						// somente carteira receber
				nValIof :=0
				nValCc  :=0
				dCred   :=ctod("  /  /  ")
			Else
				cCgc := " "
			EndIf
			cData   :=""
			dBaixa  :=ctod("  /  /  ")
			cEspecie:="  "
			cNossoNum:=Space(15)
			cForne:= Space(8)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Lˆ os valores do arquivo Retorno ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF !Empty(cPosDesp)
				nDespes:=Val(Substr(xBuffer,Int(Val(Substr(cPosDesp,1,3))),nLenDesp))/100
			EndIF
			IF !Empty(cPosDesc)
				nDescont:=Val(Substr(xBuffer,Int(Val(Substr(cPosDesc,1,3))),nLenDesc))/100
			EndIF
			IF !Empty(cPosAbat)
				nAbatim:=Val(Substr(xBuffer,Int(Val(Substr(cPosAbat,1,3))),nLenAbat))/100
			EndIF
			IF !Empty(cPosPrin)
				nValRec :=Val(Substr(xBuffer,Int(Val(Substr(cPosPrin,1,3))),nLenPrin))/100
			EndIF
			IF !Empty(cPosJuro)
				nJuros  :=Val(Substr(xBuffer,Int(Val(Substr(cPosJuro,1,3))),nLenJuro))/100
			EndIF
			IF !Empty(cPosMult)
				nMulta  :=Val(Substr(xBuffer,Int(Val(Substr(cPosMult,1,3))),nLenMult))/100
			EndIF
			IF !Empty(cPosIof)
				nValIof :=Val(Substr(xBuffer,Int(Val(Substr(cPosIof,1,3))),nLenIof))/100
			EndIF
			IF !Empty(cPosCc)
				nValCc :=Val(Substr(xBuffer,Int(Val(Substr(cPosCc,1,3))),nLenCc))/100
			EndIF
			IF !Empty(cPosNosso)
				cNossoNum :=Substr(xBuffer,Int(Val(Substr(cPosNosso,1,3))),nLenNosso)
			EndIF
			IF !Empty(cPosForne)
				cForne  :=Substr(xBuffer,Int(Val(Substr(cPosForne,1,3))),nLenForne)
			Endif
			If !Empty(cPosCgc)
				cCgc  :=Substr(xBuffer,Int(Val(Substr(cPosCgc,1,3))),nLenCgc)
			Endif
			
			cDescr  := ""
			cNumTit :=Substr(xBuffer,Int(Val(Substr(cPosNum, 1,3))),nLenNum )
			cData   :=Substr(xBuffer,Int(Val(Substr(cPosData,1,3))),nLenData)
			If !Empty(cData)
				cData   := ChangDate(cData,SEE->EE_TIPODAT)
				dBaixa  :=Ctod(Substr(cData,1,2)+"/"+Substr(cData,3,2)+"/"+Substr(cData,5),"ddmm"+Replicate("y",Len(Substr(cData,5))))
			Else
				dBaixa  := dDataBase
			EndIf
			cTipo   :=Substr(xBuffer,Int(Val(Substr(cPosTipo, 1,3))),nLenTipo )
			cTipo   := Iif(Empty(cTipo),"NF ",cTipo)		// Bradesco
			IF !Empty(cPosDtCc)
				cData :=Substr(xBuffer,Int(Val(Substr(cPosDtCc,1,3))),nLenDtCc)
				dCred :=Ctod(Substr(cData,1,2)+"/"+Substr(cData,3,2)+"/"+Substr(cData,5,2),"ddmmyy")
			EndIF
			If nLenOcor == 2
				cOcorr  :=Substr(xBuffer,Int(Val(Substr(cPosOcor,1,3))),nLenOcor) + " "
			Else
				cOcorr  :=Substr(xBuffer,Int(Val(Substr(cPosOcor,1,3))),nLenOcor)
			EndIf
			If nLenRej > 0
				cRej	:= Substr(xBuffer,Int(Val(Substr(cPosRej,1,3))),nLenRej)
			EndIf
			
			lOk := .T.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ o array aValores ir  permitir ³
			//³ que qualquer exce‡„o ou neces-³
			//³ sidade seja tratado no ponto  ³
			//³ de entrada em PARAMIXB        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			// Estrutura de aValores
			//	Numero do T¡tulo	- 01
			//	data da Baixa		- 02
			// Tipo do T¡tulo		- 03
			// Nosso Numero		- 04
			// Valor da Despesa	- 05
			// Valor do Desconto	- 06
			// Valor do Abatiment- 07
			// Valor Recebido    - 08
			// Juros					- 09
			// Multa					- 10
			// Valor do Credito	- 11
			// Data Credito		- 12
			// Ocorrencia			- 13
			// Linha Inteira		- 14
			
			aValores := ( { cNumTit, dBaixa, cTipo, cNossoNum, nDespes, nDescont, nAbatim, nValRec, nJuros, nMulta, nValCc, dCred, cOcorr, xBuffer })
			
			// Template GEM
			If lF650Var
				ExecBlock("F650VAR",.F.,.F.,{aValores})
			ElseIf ExistTemplate("GEMBaixa")
				ExecTemplate("GEMBaixa",.F.,.F.,)
			Endif
			
			If !Empty(cTipo)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica especie do titulo    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPos := Ascan(aTabela, {|aVal|aVal[1] == AllTrim(Substr(cTipo,1,Len(IIF(mv_par07==1,SE1->E1_TIPO,SE2->E2_TIPO))))})
				If nPos != 0
					cEspecie := aTabela[nPos][2]
				Else
					cEspecie	:= "  "
				EndIf
				If cEspecie $ MVABATIM			// Nao lˆ titulo de abatimento
					nLidos+=nTamDet
					Loop
				Endif
				
				If lNewIndice .and. !Empty(xFilial(IIF(mv_par07==1,"SE1","SE2")))
					//Busca por IDCNAB sem filial no indice
					dbSelectArea(IIF(mv_par07==1,"SE1","SE2"))
					dbSetOrder(IIF(mv_par07==1,19,13))
					cChave := Substr(cNumTit,1,10)
				Else
					//Busca por IDCNAB com filial no indice
					dbSelectArea(IIF(mv_par07==1,"SE1","SE2"))
					dbSetOrder(IIF(mv_par07==1,16,11))
					cChave := xFilial(IIF(mv_par07==1,"SE1","SE2"))+Substr(cNumTit,1,10)
				Endif
				
				lAchouTit := .F.
				// Busca pelo IdCnab
				If !Empty(cNumTit) .And. MsSeek(cChave)
					If ( mv_par07 == 1 )
						cEspecie  := SE1->E1_TIPO
					Else
						cEspecie  := SE2->E2_TIPO
					Endif
					lAchouTit := .T.
					nPos   	  := 1
				Endif
				
				// Localiza o titulo
				If lFr650Fil
					lAchouTit := Execblock("FR650FIL",.F.,.F.,{aValores})
				Endif
				
				// Busca pela chave antiga
				If !lAchouTit
					dbSetOrder(1)
					//Chave retornada pelo banco
					cChave650 := IIf(!Empty(cForne),Pad(cNumTit,nTamTit)+cEspecie+SubStr(cForne,1,nTamForn),Pad(cNumTit,nTamTit)+cEspecie)
					While !lAchouTit
						If !dbSeek(xFilial()+cChave650)
							nPos := Ascan(aTabela, {|aVal|aVal[1] == AllTrim(Substr(cTipo,1,Len(IIF(mv_par07==1,SE1->E1_TIPO,SE2->E2_TIPO))))},nPos+1)
							If nPos != 0
								cEspecie := aTabela[nPos][2]
								cChave650 := IIf(!Empty(cForne),Pad(cNumTit,nTamTit)+cEspecie+SubStr(cForne,1,nTamForn),Pad(cNumTit,nTamTit)+cEspecie)
							Else
								Exit
							Endif
						Else
							lAchouTit := .T.
						Endif
					Enddo
					
					//Chave retornada pelo banco com a adicao de espacos para tratar chave enviada ao banco com
					//tamanho de nota de 6 posicoes e retornada quando o tamanho da nota e 9 (atual)
					If !lAchouTit
						cNumTit := SubStr(cNumTit,1,nTamPre)+Padr(Substr(cNumTit,4,6),nTamNum)+SubStr(cNumTit,10,nTamPar)
						cChave650 := IIf(!Empty(cForne),Pad(cNumTit,nTamTit)+cEspecie+SubStr(cForne,1,nTamForn),Pad(cNumTit,nTamTit)+cEspecie)
						nPos := Ascan(aTabela, {|aVal|aVal[1] == AllTrim(Substr(cTipo,1,Len(IIF(mv_par07==1,SE1->E1_TIPO,SE2->E2_TIPO))))})
						While !lAchouTit
							If !dbSeek(xFilial()+cChave650)
								nPos := Ascan(aTabela, {|aVal|aVal[1] == AllTrim(Substr(cTipo,1,Len(IIF(mv_par07==1,SE1->E1_TIPO,SE2->E2_TIPO))))},nPos+1)
								If nPos != 0
									cEspecie := aTabela[nPos][2]
									cChave650 := IIf(!Empty(cForne),Pad(cNumTit,nTamTit)+cEspecie+SubStr(cForne,1,nTamForn),Pad(cNumTit,nTamTit)+cEspecie)
								Else
									Exit
								Endif
							Else
								lAchouTit := .T.
							Endif
						Enddo
					Endif
					
					If lAchouTit
						If mv_par07 == 2
							cNumSe2   := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO
							cChaveSe2 := IIf(!Empty(cForne),cNumSe2+SE2->E2_FORNECE,cNumSe2)
							nPosEsp	  := nPos	// Gravo nPos para volta-lo ao valor inicial, caso
							// Encontre o titulo
							While !Eof() .and. SE2->E2_FILIAL+cChaveSe2 == xFilial("SE2")+cChave650
								nPos := nPosEsp
								If Empty(cCgc)
									Exit
								Endif
								dbSelectArea("SA2")
								If dbSeek(xFilial()+SE2->E2_FORNECE+SE2->E2_LOJA)
									If Substr(SA2->A2_CGC,1,14) == cCGC .or. StrZero(Val(SA2->A2_CGC),14,0) == StrZero(Val(cCGC),14,0)
										Exit
									Endif
								Endif
								dbSelectArea("SE2")
								dbSkip()
								cNumSe2   := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO
								cChaveSe2 := IIf(!Empty(cForne),cNumSe2+SE2->E2_FORNECE,cNumSe2)
								nPos 	  := 0
							Enddo
						Endif
					Endif
				EndIf
				If nPos == 0
					cEspecie	:= "  "
					cCliFor	:= "  "
				Else
					cEspecie := IIF(mv_par07==1,SE1->E1_TIPO,SE2->E2_TIPO)
					cNumTit := IIF(mv_par07==1,SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA),SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA))
					cCliFor	:= IIF(mv_par07==1,SE1->E1_CLIENTE+" "+SE1->E1_LOJA,SE2->E2_FORNECE+" "+SE2->E2_LOJA)
				EndIF
				If cEspecie $ MVABATIM			// Nao lˆ titulo de abatimento
					nLidos += nTamDet
					Loop
				EndIf
			EndIF
		Else
			lTrailler := .T.
		Endif
	Else
		aLeitura := ReadCnab2(nHdlBco,MV_PAR02,nTamDet,aArqConf)
		cNumTit  	:= SubStr(aLeitura[1],1,nTamTit)
		cData    	:= aLeitura[04]
		If !Empty(cData)
			cData    :=	ChangDate(cData,SEE->EE_TIPODAT)
			dBaixa   :=	Ctod(Substr(cData,1,2)+"/"+Substr(cData,3,2)+"/"+Substr(cData,5),"ddmm"+Replicate("y", Len(Substr(cData,5))))
		Else
			dBaixa   := dDataBase
		EndIf
		cTipo    	:= aLeitura[02]
		cTipo    	:= Iif(Empty(cTipo),"NF ",cTipo)		// Bradesco
		cNossoNum   := aLeitura[11]
		nDespes  	:= aLeitura[06]
		nDescont 	:= aLeitura[07]
		nAbatim  	:= aLeitura[08]
		nValRec  	:= aLeitura[05]
		nJuros   	:= aLeitura[09]
		nMulta   	:= aLeitura[10]
		cOcorr   	:= PadR(aLeitura[03],3)
		nValIof		:= aLeitura[12]
		nValCC   	:= aLeitura[13]
		cData    	:= aLeitura[14]
		If !Empty(cData)
			cData     := ChangDate(cData,SEE->EE_TIPODAT)
			dDataCred := Ctod(Substr(cData,1,2)+"/"+Substr(cData,3,2)+"/"+Substr(cData,5,2),"ddmmyy")
		Else
			dDataCred := dDataBase
		EndIf
		dDataUser	:= dDataCred
		dCred			:= dDataCred
		cRej		  	:= aLeitura[15]
		cForne		:= aLeitura[16]
		xBuffer		:= aLeitura[17]
		
		//CGC
		If Len(aLeitura) > 19
			cCgc := aLeitura[20]
		Else
			cCgc := " "
		Endif
		
		lOk := .t.
		lAchouTit := .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ o array aValores ir  permitir ³
		//³ que qualquer exce‡„o ou neces-³
		//³ sidade seja tratado no ponto  ³
		//³ de entrada em PARAMIXB        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// Estrutura de aValores
		//	Numero do T¡tulo	- 01
		//	data da Baixa		- 02
		// Tipo do T¡tulo		- 03
		// Nosso Numero		- 04
		// Valor da Despesa	- 05
		// Valor do Desconto	- 06
		// Valor do Abatiment- 07
		// Valor Recebido    - 08
		// Juros					- 09
		// Multa					- 10
		// Valor do Credito	- 11
		// Data Credito		- 12
		// Ocorrencia			- 13
		// Linha Inteira		- 14
		
		aValores := ( { cNumTit, dBaixa, cTipo, cNossoNum, nDespes, nDescont, nAbatim, nValRec, nJuros, nMulta, nValCc, dCred, cOcorr, xBuffer })
		nLenRej := Len(AllTrim(cRej))
		
		// Template GEM
		If lF650Var
			ExecBlock("F650VAR",.F.,.F.,{aValores})
		ElseIf ExistTemplate("GEMBaixa")
			ExecTemplate("GEMBaixa",.F.,.F.,)
		Endif
		
		If Empty(cNumTit)
			nLidos += nTamDet
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica especie do titulo    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPos := Ascan(aTabela, {|aVal|aVal[1] == AllTrim(Substr(cTipo,1,Len(IIF(mv_par07==1,SE1->E1_TIPO,SE2->E2_TIPO))))})
		If nPos != 0
			cEspecie := aTabela[nPos][2]
		Else
			cEspecie	:= "  "
		EndIf
		If cEspecie $ MVABATIM			// Nao lˆ titulo de abatimento
			nLidos += nTamDet
			Loop
		Endif
		If lNewIndice .and. !Empty(xFilial(IIF(mv_par07==1,"SE1","SE2")))
			//Busca por IDCNAB sem filial no indice
			dbSelectArea(IIF(mv_par07==1,"SE1","SE2"))
			dbSetOrder(IIF(mv_par07==1,19,13))
			cChave := Substr(cNumTit,1,10)
		Else
			//Busca por IDCNAB com filial no indice
			dbSelectArea(IIF(mv_par07==1,"SE1","SE2"))
			dbSetOrder(IIF(mv_par07==1,16,11))
			cChave := xFilial(IIF(mv_par07==1,"SE1","SE2"))+Substr(cNumTit,1,10)
		Endif
		
		lAchouTit := .F.
		// Busca pelo IdCnab
		If !Empty(cNumTit) .And. MsSeek(cChave)
			If ( mv_par07 == 1 )
				cEspecie  := SE1->E1_TIPO
			Else
				cEspecie  := SE2->E2_TIPO
			Endif
			lAchouTit := .T.
			nPos   	  := 1
		Endif
		
		// Localiza o titulo
		If lFr650Fil
			lAchouTit := Execblock("FR650FIL",.F.,.F.,{aValores})
		Endif
		
		// Busca pela chave antiga
		If !lAchouTit
			dbSetOrder(1)
			//Chave retornada pelo banco
			cChave650 := IIf(!Empty(cForne),Pad(cNumTit,nTamTit)+cEspecie+SubStr(cForne,1,nTamForn),Pad(cNumTit,nTamTit)+cEspecie)
			While !lAchouTit
				If !dbSeek(xFilial()+cChave650)
					nPos := Ascan(aTabela, {|aVal|aVal[1] == AllTrim(Substr(cTipo,1,Len(IIF(mv_par07==1,SE1->E1_TIPO,SE2->E2_TIPO))))},nPos+1)
					If nPos != 0
						cEspecie := aTabela[nPos][2]
						cChave650 := IIf(!Empty(cForne),Pad(cNumTit,nTamTit)+cEspecie+SubStr(cForne,1,nTamForn),Pad(cNumTit,nTamTit)+cEspecie)
					Else
						Exit
					Endif
				Else
					lAchouTit := .T.
				Endif
			Enddo
			
			//Chave retornada pelo banco com a adicao de espacos para tratar chave enviada ao banco com
			//tamanho de nota de 6 posicoes e retornada quando o tamanho da nota e 9 (atual)
			If !lAchouTit
				cNumTit := SubStr(cNumTit,1,nTamPre)+Padr(Substr(cNumTit,4,6),nTamNum)+SubStr(cNumTit,10,nTamPar)
				cChave650 := IIf(!Empty(cForne),Pad(cNumTit,nTamTit)+cEspecie+SubStr(cForne,1,nTamForn),Pad(cNumTit,nTamTit)+cEspecie)
				While !lAchouTit
					If !dbSeek(xFilial()+cChave650)
						nPos := Ascan(aTabela, {|aVal|aVal[1] == AllTrim(Substr(cTipo,1,Len(IIF(mv_par07==1,SE1->E1_TIPO,SE2->E2_TIPO))))},nPos+1)
						If nPos != 0
							cEspecie := aTabela[nPos][2]
							cChave650 := IIf(!Empty(cForne),Pad(cNumTit,nTamTit)+cEspecie+SubStr(cForne,1,nTamForn),Pad(cNumTit,nTamTit)+cEspecie)
						Else
							Exit
						Endif
					Else
						lAchouTit := .T.
					Endif
				Enddo
			Endif
			
			If lAchouTit
				If mv_par07 == 2
					cNumSe2   := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO
					cChaveSe2 := IIf(!Empty(cForne),cNumSe2+SE2->E2_FORNECE,cNumSe2)
					nPosEsp	  := nPos	// Gravo nPos para volta-lo ao valor inicial, caso
					// Encontre o titulo
					While !Eof() .and. SE2->E2_FILIAL+cChaveSe2 == xFilial("SE2")+cChave650
						nPos := nPosEsp
						If Empty(cCgc)
							Exit
						Endif
						dbSelectArea("SA2")
						If dbSeek(xFilial()+SE2->E2_FORNECE+SE2->E2_LOJA)
							If Substr(SA2->A2_CGC,1,14) == cCGC .or. StrZero(Val(SA2->A2_CGC),14,0) == StrZero(Val(cCGC),14,0)
								Exit
							Endif
						Endif
						dbSelectArea("SE2")
						dbSkip()
						cNumSe2   := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO
						cChaveSe2 := IIf(!Empty(cForne),cNumSe2+SE2->E2_FORNECE,cNumSe2)
						nPos 	  := 0
					Enddo
				Endif
			Endif
		Endif
		If nPos == 0
			cEspecie	:= "  "
			cCliFor	:= "  "
		Else
			cEspecie := IIF(mv_par07==1,SE1->E1_TIPO,SE2->E2_TIPO)
			cNumTit := IIF(mv_par07==1,SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA),SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA))
			cCliFor	:= IIF(mv_par07==1,SE1->E1_CLIENTE+" "+SE1->E1_LOJA,SE2->E2_FORNECE+" "+SE2->E2_LOJA)
		EndIF
		If cEspecie $ MVABATIM			// Nao lˆ titulo de abatimento
			nLidos += nTamDet
			Loop
		EndIf
	EndIf
	
	If ( ltrailler )
		nLidos+=nTamDet
		loop
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica codigo da ocorrencia ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nValOrig := 0
	dbSelectArea("SEB")
	If mv_par07 == 1
		cCarteira := "R"
		If lAchouTit
			nValOrig := SE1->E1_VLCRUZ
		Endif
	Else
		cCarteira := "P"
		If lAchouTit
			nValOrig := SE2->E2_VLCRUZ
		Endif
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a despesa est     ³
	//³ descontada do valor principal ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SEE->EE_DESPCRD == "S"
		nValRec := nValRec+nDespes+nValIOF - nValCC
	EndIf
	
	If (dbSeek(cFilial+mv_par03+cOcorr+cCarteira))
		cDescr := RTrim(cOcorr) + "-" + Subs(SEB->EB_DESCRI,1,27)
		
		// Ponto de entrada para alterar a descricao do relatorio
		If ExistBlock ("F650DESCR")
			cDescr := ExecBlock("F650DESCR",.F.,.F.,{cDescr})
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua contagem dos SubTotais por ocorrencia  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nCntOco := Ascan(aCntOco, { |X| X[1] == cOcorr})
		If nCntOco == 0
			Aadd(aCntOco,{cOcorr,Subs(SEB->EB_DESCRI,1,27),nDespes,nDescont,nAbatim,nValRec,nJuros+nMulta,nValIof,nValCc,nValOrig})
		Else
			aCntOco[nCntOco][DESPESAS]     +=nDespes
			aCntOco[nCntOco][DESCONTOS]    +=nDescont
			aCntOco[nCntOco][ABATIMENTOS]  +=nAbatim
			aCntOco[nCntOco][VALORRECEBIDO]+=nValRec
			aCntOco[nCntOco][JUROS]        +=nJuros+nMulta
			aCntOco[nCntOco][VALORIOF]     +=nValIOF
			aCntOco[nCntOco][VALORCC]      +=nValCC
			aCntOco[nCntOco][VALORORIG]    +=nValOrig
		Endif
		
		If SEB->EB_OCORR $ "03ü15ü16ü17ü40ü41ü42"		//Registro rejeitado
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica tabela de rejeicao   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nLenRej > 0
				If dbSeek(cFilial+mv_par03+cOcorr+cCarteira+Substr(cRej,1,2))
					cDescr := RTrim(cOcorr) + "(" + Substr(cRej,1,2) + ;
					")" + "-" + Substr(SEB->EB_DESCMOT,1,22)
				EndIf
				lRej := .T.
			EndIf
		EndIf
		lOcorr := .T.
	Else
		cDescr  := Space(29)
		lOcorr  := .F.
		nCntOco := Ascan(aCntOco, { |X| X[2] == OemToAnsi(STR0016)})
		If nCntOco == 0
			Aadd(aCntOco,{"00 ",OemToAnsi(STR0016),nDespes,nDescont,nAbatim,nValRec,nJuros+nMulta,nValIof,nValCc,nValOrig})
		Else
			aCntOco[nCntOco][DESPESAS]     +=nDespes
			aCntOco[nCntOco][DESCONTOS]    +=nDescont
			aCntOco[nCntOco][ABATIMENTOS]  +=nAbatim
			aCntOco[nCntOco][VALORRECEBIDO]+=nValRec
			aCntOco[nCntOco][JUROS]        +=nJuros+nMulta
			aCntOco[nCntOco][VALORIOF]     +=nValIOF
			aCntOco[nCntOco][VALORCC]      +=nValCC
			aCntOco[nCntOco][VALORORIG]    +=nValOrig
		Endif
	Endif
	If mv_par07 == 1
		dbSelectArea("SE1")
	Else
		dbSelectArea("SE2")
	EndIf
	
	IF Empty(cOcorr)
		lPrint := If(Empty(cDescr2),.T.,.F.)
		cDescr2 := OemToAnsi(STR0015)  	//"OCORRENCIA NAO ENVIADA"
		lOk := PRINTLINE(oReport,lPrint)
	Else
		If ! lOcorr
			lPrint := If(Empty(cDescr2),.T.,.F.)
			cDescr2 := OemToAnsi(STR0016)  //"OCORRENCIA NAO ENCONTRADA"
			lOk := PRINTLINE(oReport,lPrint)
		End
	EndIf
	
	If dBaixa < dDataFin
		lPrint := If(Empty(cDescr2),.T.,.F.)
		cDescr2 := OemToAnsi(STR0026)		//"DATA MENOR QUE DATA FECH.FINANCEIRO"
		lOk := PRINTLINE(oReport,lPrint)
	Endif
	
	IF Empty(cNumTit)
		lPrint := If(Empty(cDescr2),.T.,.F.)
		cDescr2 := OemToAnsi(STR0017)  	//"NUMERO TITULO NAO ENVIADO"
		lOk := PRINTLINE(oReport,lPrint)
	End
	
	If !lAchouTit
		lPrint := If(Empty(cDescr2),.T.,.F.)
		cDescr2 := OemToAnsi(STR0018)  	//"TITULO NAO ENCONTRADO"
		lOk := PRINTLINE(oReport,lPrint)
	Endif
	IF Substr(dtoc(dBaixa),1,1)=' '
		lPrint := If(Empty(cDescr2),.T.,.F.)
		cDescr2 := OemToAnsi(STR0019) 		//"DATA DE BAIXA NAO ENVIADA"
		lOk := PRINTLINE(oReport,lPrint)
	EndIF
	
	IF Empty(cTipo)
		lPrint := If(Empty(cDescr2),.T.,.F.)
		cDescr2 := OemToAnsi(STR0020)  	//"ESPECIE NAO ENVIADA"
		lOk := PRINTLINE(oReport,lPrint)
	Endif
	
	If Empty(cEspecie)
		lPrint := If(Empty(cDescr2),.T.,.F.)
		cDescr2 := OemToAnsi(STR0021)  	//"ESPECIE NAO ENCONTRADA"
		lOk := PRINTLINE(oReport,lPrint)
	Endif
	
	If mv_par07 == 1 .and. lAchouTit .and. nAbatim == 0 .and. SE1->E1_SALDO > 0
		nValPadrao := nValRec-(nJuros+nMulta-nDescont)
		nTotAbat := SumAbatRec(Substr(cNumtit,1,TamSX3("E1_PREFIXO")[1]),Substr(cNumtit,TamSX3("E1_PREFIXO")[1]+1,TamSX3("E1_NUM")[1]),;
		Substr(cNumtit,TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]+1,TamSX3("E1_PARCELA")[1]),1,"S")
		If Round(NoRound(nValPadrao,3),2) > 0
			If Round(NoRound((SE1->E1_SALDO-nTotAbat),3),2) < Round(NoRound(nValPadrao,3),2)
				lPrint := If(Empty(cDescr2),.T.,.F.)
				cDescr2 := STR0050 //"VLR REC MAIOR"
				lOk := PRINTLINE(oReport,lPrint)
			Endif
			If Round(NoRound((SE1->E1_SALDO-nTotAbat),3),2) > Round(NoRound(nValPadrao,3),2)
				lPrint := If(Empty(cDescr2),.T.,.F.)
				cDescr2 := STR0051 //"VLR REC MENOR"
				lOk := PRINTLINE(oReport,lPrint)
			Endif
		EndIf
	Endif
	
	If mv_par07 == 2 .and. lAchouTit .and. nAbatim == 0 .and. SE2->E2_SALDO > 0
		nValPadrao := nValRec-(nJuros+nMulta-nDescont)
		nTotAbat	:= SumAbatPag(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_FORNECE,SE2->E2_MOEDA,"S",dDatabase,SE2->E2_LOJA)
		If Round(NoRound(nValPadrao,3),2) > 0
			If Round(NoRound((SE2->E2_SALDO-nTotAbat),3),2) < Round(NoRound(nValPadrao,3),2)
				lPrint := If(Empty(cDescr2),.T.,.F.)
				cDescr2 := STR0052 //"VLR PAGO MAIOR"
				lOk := PRINTLINE(oReport,lPrint)
			Endif
			If Round(NoRound((SE2->E2_SALDO-nTotAbat),3),2) > Round(NoRound(nValPadrao,3),2)
				lPrint := If(Empty(cDescr2),.T.,.F.)
				cDescr2 := STR0053 //"VLR PAGO MENOR"
				lOk := PRINTLINE(oReport,lPrint)
			Endif
		EndIf
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Informa a condicao da baixa do titulo         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lOk
		If mv_par07 == 1
			If SE1->E1_SALDO = 0
				lPrint := If(Empty(cDescr2),.T.,.F.)
				cDescr2 := STR0028 //"BAIXADO ANTERIORMENTE - TOTAL"
				lOk := PRINTLINE(oReport,lPrint)
			ElseIf SE1->E1_VALOR <> SE1->E1_SALDO
				lPrint := If(Empty(cDescr2),.T.,.F.)
				cDescr2 := STR0029 //"BAIXADO ANTERIORMENTE - PARCIAL"
				lOk := PRINTLINE(oReport,lPrint)
			End
		Else
			If SE2->E2_SALDO = 0
				lPrint := If(Empty(cDescr2),.T.,.F.)
				cDescr2 := STR0028 //"BAIXADO ANTERIORMENTE - TOTAL"
				lOk := PRINTLINE(oReport,lPrint)
			ElseIf SE2->E2_VALOR <> SE2->E2_SALDO
				lPrint := If(Empty(cDescr2),.T.,.F.)
				cDescr2 := STR0029 //"BAIXADO ANTERIORMENTE - PARCIAL"
				lOk := PRINTLINE(oReport,lPrint)
			End
		Endif
	Endif
	
	If lOk
		If lRej
			lPrint := If(Empty(cDescr2),.T.,.F.)
			cDescr2 := OemToAnsi(STR0055)  	//"TITULO REJEITADO"
			lOk := PRINTLINE(oReport,lPrint)
		Else
			If mv_par07 == 1
				lPrint := If(Empty(cDescr2),.T.,.F.)
				cDescr2 := OemToAnsi(STR0022)  	//"TITULO RECEBIDO"
			Else
				lPrint := If(Empty(cDescr2),.T.,.F.)
				cDescr2 := OemToAnsi(STR0030)  	//"TITULO PAGO"
			Endif
			lOk := PRINTLINE(oReport,lPrint)
		EndIf
	EndIf
	cDescr2 := ""
EndDO
oSection1:Finish()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Subtotais por ocorrencia  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection2:Init()
For x :=1 to Len(aCntOco)
	nTit    := aCntOco[x][1] + Substr(aCntOco[x][2],1,30)
	nVOrig  := aCntOco[x][10]
	nVReceb := aCntOco[x][6]
	nDCOB   := aCntOco[x][3]
	nVDESC  := aCntOco[x][4]
	nVABAT  := aCntOco[x][5]
	nVJURO  := aCntOco[x][7]
	nVIOF   := aCntOco[x][8]
	nOCRED  := aCntOco[x][9]
	
	oSection2:PrintLine()
Next
oSection2:Finish()

//printline

// Restaura area do contas a receber ou contas a pagar
If mv_par07 == 1	// Receber
	RestArea( aAreaSE1 )
Else				// Pagar
	RestArea( aAreaSE2 )
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha os Arquivos ASCII ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
fClose(nHdlBco)
fClose(nHdlConf)

If FILE(cDestino+cBarra+cFileName)
	FErase(cDestino+cBarra+cFileName)
EndIf

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PRINTLINE ³ Autor ³ Marcel Borges Ferreira³ Data ³ 04/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impress„o da Linha                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ IMPLIN(texto)                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINR650.PRG                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PRINTLINE(oReport,lPrint)

Local oSection1 := oReport:Section(1)

If lPrint
	oSection1:Cell("SEC1_TIT"):Show()
	oSection1:Cell("SEC1_CLI"):Show()
	oSection1:Cell("SEC1_OCOR"):Show()
	oSection1:Cell("SEC1_DTOCOR"):Show()
	oSection1:Cell("SEC1_VORIG"):Show()
	oSection1:Cell("SEC1_DCOB"):Show()
	oSection1:Cell("SEC1_VDESC"):Show()
	oSection1:Cell("SEC1_VABAT"):Show()
	oSection1:Cell("SEC1_VJURO"):Show()
	
	If mv_par07 == 1
		oSection1:Cell("SEC1_VRECE"):Show()
		oSection1:Cell("SEC1_VIOF"):Show()
		oSection1:Cell("SEC1_OCRED"):Show()
		oSection1:Cell("SEC1_DTCRED"):Show()
	Else
		oSection1:Cell("SEC1_VPAGO"):Show()
	EndIf
	
	oSection1:Cell("SEC1_NTIT"):Show()
	
	oSection1:PrintLine()
	
Else
	
	oSection1:Cell("SEC1_TIT"):Hide()
	oSection1:Cell("SEC1_CLI"):Hide()
	oSection1:Cell("SEC1_OCOR"):Hide()
	oSection1:Cell("SEC1_DTOCOR"):Hide()
	oSection1:Cell("SEC1_VORIG"):Hide()
	oSection1:Cell("SEC1_DCOB"):Hide()
	oSection1:Cell("SEC1_VDESC"):Hide()
	oSection1:Cell("SEC1_VABAT"):Hide()
	oSection1:Cell("SEC1_VJURO"):Hide()
	If mv_par07 == 1
		oSection1:Cell("SEC1_VRECE"):Hide()
		oSection1:Cell("SEC1_VIOF"):Hide()
		oSection1:Cell("SEC1_OCRED"):Hide()
		oSection1:Cell("SEC1_DTCRED"):Hide()
	Else
		oSection1:Cell("SEC1_VPAGO"):Hide()
	EndIf
	
	oSection1:Cell("SEC1_NTIT"):Hide()
	
	oSection1:PrintLine()
	
EndIf

Return .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FinR650  ³ Autor ³ Elaine F. T. Beraldo  ³ Data ³ 17/06/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impress„o do Retorno da Comunica‡„o Banc ria               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FinR650()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function autr650R3()
Local wnrel
Local cString
Local cDesc1  := STR0001  //"Este programa tem como objetivo imprimir o arquivo"
Local cDesc2  := STR0002  //"Retorno da Comunica‡„o Banc ria, conforme layout, "
Local cDesc3  := STR0003  //"previamente configurado."
LOCAL tamanho := "G"
Local nTamPar1,nTamPar2,nTamPar3,nTamPar4,nTamPar5,nTamPar6

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE Titulo := OemToAnsi(STR0004)  //"Impressao do Retorno da Comunicacao Bancaria"
PRIVATE cabec1
PRIVATE cabec2
PRIVATE aReturn  := { OemToAnsi(STR0005), 1,OemToAnsi(STR0006), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
PRIVATE cPerg    := "FIN650"   , nLastKey := 0
PRIVATE nomeprog := "finr650"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01            // Arquivo de Entrada                    ³
//³ mv_par02            // Arquivo de Configura‡„o               ³
//³ mv_par03            // Codigo do Banco                       ³
//³ mv_par04            // Codigo Agencia							     ³
//³ mv_par05            // Codigo Conta			                 ³
//³ mv_par06            // Codigo SubConta			              ³
//³ mv_par07            // Receber / Pagar                       ³
//³ mv_par08            // Modelo Cnab / Cnab2		              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If mv_par07 == 1
	cString := "SE1"
Else
	cString := "SE2"
EndIf

nTamPar1:=len(mv_par01)
nTamPar2:=len(mv_par02)
nTamPar3:=len(mv_par03)
nTamPar4:=len(mv_par04)
nTamPar5:=len(mv_par05)
nTamPar6:=len(mv_par06)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "FINR650"            //Nome Default do relatorio em Disco
aOrd  := {OemToAnsi(STR0007),OemToAnsi(STR0008),OemToAnsi(STR0009),; 			//"Por Numero"###"Por Natureza"###"Por Vencimento"
OemToAnsi(STR0010),OemToAnsi(STR0011),OemToAnsi(STR0012),OemToAnsi(STR0013)}  //"Por Banco"###"Fornecedor"###"Por Emissao"###"Por Cod.Fornec."
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

If mv_par07 == 1
	cString := "SE1"
Else
	cString := "SE2"
EndIf

mv_par01:=padr(mv_par01, nTamPar1)
mv_par02:=padr(mv_par02, nTamPar2)
mv_par03:=padr(mv_par03, nTamPar3)
mv_par04:=padr(mv_par04, nTamPar4)
mv_par05:=padr(mv_par05, nTamPar5)
mv_par06:=padr(mv_par06, nTamPar6)

If nLastKey == 27
	Return
End

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

RptStatus({|lEnd| u_autr650Imp(@lEnd,wnRel,cString)},Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FA650Imp ³ Autor ³ Elaine F. T. Beraldo  ³ Data ³ 20/06/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impress„o da Comunicacao Bancaria - Retorno                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FA650Imp()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINR650                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function autr650Imp(lEnd,wnRel,cString)

Local cPosPrin,cPosJuro,cPosMult,cPosCC ,cPosTipo
Local cPosNum ,cPosData,cPosDesp,cPosDesc,cPosAbat,cPosDtCC,cPosIof,cPosOcor
Local cPosNosso, cPosForne, cPosCgc
Local lPosNum  := .f. , lPosData := .f. , lPosAbat := .f.
Local lPosDesp := .f. , lPosDesc := .f. , lPosMult := .f.
Local lPosPrin := .f. , lPosJuro := .f. , lPosDtCC := .f.
Local lPosOcor := .f. , lPosTipo := .f. , lPosIof  := .f.
Local lPosCC   := .f. , lPosNosso:= .f. , lPosRej	:= .f.
Local lPosForne:=.f. , lPosCgc := .F.
Local nLidos ,nLenNum  ,nLenData ,nLenDesp ,nLenDesc ,nLenAbat ,nLenDtCC, nLenCGC
Local nLenPrin ,nLenJuro ,nLenMult ,nLenOcor ,nLenTipo ,nLenIof  ,nLenCC
Local nLenRej := 0
Local cArqConf ,cArqEnt ,nTipo
Local tamanho   := "G", lOcorr := .F.
Local cDescr
LOCAL cEspecie,cData,nTamArq,cForne,cCgc
Local nValIof	:= 0
Local nDespT:=nDescT:=nAbatT:=nValT:=nJurT:=nMulT:=nIOFT:=nCCT:=0
Local nHdlBco  := 0
Local nHdlConf := 0
Local cTabela 	:= "17"
Local lRej := .f.
Local cCarteira
Local nTamDet
Local lHeader := .f.
Local lTrailler:= .F.
Local aTabela 	:= {}
Local cChave650
Local nPos := 0
Local lAchouTit := .F.
Local nValPadrao := 0
Local aValores := {}
LOCAL lF650Var := ExistBlock("F650VAR" )
Local nTmClifor:= IIF(mv_par07==1,TamSX3("E1_CLIENTE")[1]+TamSX3("E1_LOJA")[1],TamSX3("E2_FORNECE")[1]+TamSX3("E2_LOJA")[1])
LOCAL dDataFin := Getmv("MV_DATAFIN")
Local nCont
Local lOk
Local x
Local nCntOco  := 0
Local aCntOco  := {}
Local cCliFor	:= "  "
Local lFr650Fil:= ExistBlock("FR650FIL")
Local nValOrig	:= 0
Local nOriT := 0
Local nTamPre	:= TamSX3("E1_PREFIXO")[1]
Local nTamNum	:= TamSX3("E1_NUM")[1]
Local nTamPar	:= TamSX3("E1_PARCELA")[1]
Local nTamTit	:= nTamPre+nTamNum+nTamPar
Local nTamForn	:= Tamsx3("E2_FORNECE")[1]
Local cDestino := ""
Local cBarra := If(isSrvUnix(),"/","\")
Local cFileName := ""
Local lNewIndice := FaVerInd()  //Verifica a existencia dos indices de IDCNAB sem filial
Local aFile		:= {}
Local aArqConf	:= {}		// Atributos do arquivo de configuracao
Local aAreaSE1	:= {}
Local aAreaSE2	:= {}

//Essas variaveis tem que ser private para serem manipuladas
//nos pontos de entrada, assim como eh feito no FINA200
Private cNumTit
Private dBaixa
Private cTipo
Private cNossoNum
Private nDespes	:= 0
Private nDescont	:= 0
Private nAbatim	:= 0
Private nValrec	:= 0
Private nJuros	:= 0
Private nMulta	:= 0
Private nValCc	:= 0
Private dCred
Private cOcorr
Private xBuffer
PRIVATE m_pag , cbtxt , cbcont , li

// Guarda area do contas a receber ou contas a pagar
If mv_par07 == 1	// Receber
	aAreaSE1 := SE1->(GetArea())
Else				// Pagar
	aAreaSE2 := SE2->(GetArea())
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos cabecalhos                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par07 == 1
	cabec1  := OemToAnsi(STR0014)  //"No.Titulo           Cli/For   Ocorrencia                 Dt.Ocor.  Vlr Original  Vlr Recebido   Desp. Cobr.  Vlr Desconto   Vlr Abatim.    Vlr Juros      Vlr IOF  Out Creditos Dt.Cred.   Nro Titulo Bco   Consistencia"
Else
	cabec1  := OemToAnsi(STR0024)  //"No.Titulo           Cli/For   Ocorrencia                 Dt.Ocor.  Vlr Original      Vlr Pago   Desp. Cobr.  Vlr Desconto   Vlr Abatim.    Vlr Juros        Nro Titulo Bco      Consistencia"
EndIf
cabec2  := ""
nTipo:=Iif(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM"))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca tamanho do detalhe na configura‡„o do banco            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SEE")
If dbSeek(xFilial("SEE")+mv_par03+mv_par04+mv_par05+mv_par06)
	nTamDet:= Iif(Empty (SEE->EE_NRBYTES), 400, SEE->EE_NRBYTES)
	ntamDet+= 2  // Ajusta tamanho do detalhe para leitura do CR (fim de linha)
Else
	Set Device To Screen
	Set Printer To
	Help(" ",1,"NOBCOCAD")
	Return .F.
Endif

cTabela := Iif( Empty(SEE->EE_TABELA), "17" , SEE->EE_TABELA )

dbSelectArea( "SX5" )
If !SX5->( dbSeek( cFilial + cTabela ) )
	Help(" ",1,"PAR150")
	Return .F.
Endif
While !SX5->(Eof()) .and. SX5->X5_TABELA == cTabela
	AADD(aTabela,{Alltrim(X5Descri()),Pad(SX5->X5_CHAVE,Len(IIF(mv_par07==1,SE1->E1_TIPO,SE2->E2_TIPO)))})  // correcao da tabela de titulos (Pequim 18/08/00)
	SX5->(dbSkip( ))
Enddo

IF mv_par08 == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abre arquivo de configura‡„o ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cArqConf:=mv_par02
	IF !FILE(cArqConf)
		Set Device To Screen
		Set Printer To
		Help(" ",1,"NOARQPAR")
		Return .F.
	Else
		nHdlConf:=FOPEN(cArqConf,0+64)
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Lˆ arquivo de configura‡„o ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLidos :=0
	FSEEK(nHdlConf,0,0)
	nTamArq:=FSEEK(nHdlConf,0,2)
	FSEEK(nHdlConf,0,0)
	
	While nLidos <= nTamArq
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o tipo de qual registro foi lido ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		xBuffer:=Space(85)
		FREAD(nHdlConf,@xBuffer,85)
		
		IF SubStr(xBuffer,1,1) == CHR(1)
			nLidos+=85
			Loop
		EndIF
		IF !lPosNum
			cPosNum:=Substr(xBuffer,17,10)
			nLenNum:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosNum:=.t.
			nLidos+=85
			Loop
		EndIF
		IF !lPosData
			cPosData:=Substr(xBuffer,17,10)
			nLenData:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosData:=.t.
			nLidos+=85
			Loop
		EndIF
		IF !lPosDesp
			cPosDesp:=Substr(xBuffer,17,10)
			nLenDesp:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosDesp:=.t.
			nLidos+=85
			Loop
		EndIF
		IF !lPosDesc
			cPosDesc:=Substr(xBuffer,17,10)
			nLenDesc:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosDesc:=.t.
			nLidos+=85
			Loop
		EndIF
		IF !lPosAbat
			cPosAbat:=Substr(xBuffer,17,10)
			nLenAbat:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosAbat:=.t.
			nLidos+=85
			Loop
		EndIF
		IF !lPosPrin
			cPosPrin:=Substr(xBuffer,17,10)
			nLenPrin:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosPrin:=.t.
			nLidos+=85
			Loop
		EndIF
		IF !lPosJuro
			cPosJuro:=Substr(xBuffer,17,10)
			nLenJuro:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosJuro:=.t.
			nLidos+=85
			Loop
		EndIF
		IF !lPosMult
			cPosMult:=Substr(xBuffer,17,10)
			nLenMult:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosMult:=.t.
			nLidos+=85
			Loop
		EndIF
		IF !lPosOcor
			cPosOcor:=Substr(xBuffer,17,10)
			nLenOcor:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosOcor:=.t.
			nLidos+=85
			Loop
		EndIF
		IF !lPosTipo
			cPosTipo:=Substr(xBuffer,17,10)
			nLenTipo:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosTipo:=.t.
			nLidos+=85
			Loop
		EndIF
		
		If mv_par07 == 1						// Somente cart receber deve ler estes campos
			IF !lPosIof
				cPosIof:=Substr(xBuffer,17,10)
				nLenIof:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosIof:=.t.
				nLidos+=85
				Loop
			EndIF
			IF !lPosCC
				cPosCC:=Substr(xBuffer,17,10)
				nLenCC:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosCC:=.t.
				nLidos+=85
				Loop
			EndIF
			IF !lPosDtCc
				cPosDtCc:=Substr(xBuffer,17,10)
				nLenDtCc:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosDtCc:=.t.
				nLidos+=85
				Loop
			EndIF
		EndIf
		
		IF !lPosNosso
			cPosNosso:=Substr(xBuffer,17,10)
			nLenNosso:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosNosso:=.t.
			nLidos+=85
			Loop
		EndIF
		IF !lPosRej
			cPosRej:=Substr(xBuffer,17,10)
			nLenRej:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
			lPosRej:=.t.
			nLidos+=85
			Loop
		EndIF
		If mv_par07 == 2
			IF !lPosForne
				cPosForne := Substr(xBuffer,17,10)
				nLenForne := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosForne := .t.
				nLidos += 85
				Loop
			EndIF
			IF !lPosCgc
				cPosCgc   := Substr(xBuffer,17,10)
				nLenCgc   := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosCgc   := .t.
				nLidos += 85
				Loop
			EndIF
		Endif
		Exit
	EndDo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ fecha arquivo de configuracao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Fclose(nHdlConf)
Endif

cArqEnt:=mv_par01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o arquivo de entrada esta na maquina local, e se estiver copia para o servidor ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Substr(mv_par01,2,2)== ":"+cBarra
	aFile := Directory(mv_par01)
	If Empty( aFile )
		cArqEnt := ""
	Else
		cFileName := aFile[1][1]
		cDestino := GetSrvProfString("StartPath","")+If(Right(GetSrvProfString("StartPath",""),1) == cBarra,"",cBarra)+"CNABTmp"
		If !File(cDestino)
			MAKEDIR(cDestino)
		EndIf
		If CpyT2S(mv_par01,cDestino,.T.)
			cArqEnt := cDestino+cBarra+cFileName
		Else
			Help(" ",1,"F650COPY",,STR0049,1,0) //"Não foi possível copiar o arquivo de entrada para o servidor. O arquivo será processado a partir da máquina local, para um melhor desempenho, copie o arquivo diretamente no servidor."
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre arquivo enviado pelo banco ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !FILE(cArqEnt)
	Set Device To Screen
	Set Printer To
	Help(" ",1,"NOARQENT")
	Return .F.
Else
	nHdlBco:=FOPEN(cArqEnt,0+64)
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lˆ arquivo enviado pelo banco ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLidos:=0
FSEEK(nHdlBco,0,0)
nTamArq:=FSEEK(nHdlBco,0,2)
FSEEK(nHdlBco,0,0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega atributos do arquivo de configuracao                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aArqConf := Directory(mv_par02)

SetRegua(nTamArq/nTamDet)

While nTamArq-nLidos >= nTamDet
	
	lRej := .F.
	
	If mv_par08 == 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tipo qual registro foi lido ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		xBuffer:=Space(nTamDet)
		FREAD(nHdlBco,@xBuffer,nTamDet)
		
		IncRegua()
		
		IF !lHeader
			nLidos+=nTamDet
			lHeader := .t.
			Loop
		EndIF
		
		IF	SubStr(xBuffer,1,1) == "0" .or. SubStr(xBuffer,1,1) == "9" .or. ;
			SubStr(xBuffer,1,1) == "8" .or. SubStr(xBuffer,1,1) == "5"
			nLidos+=nTamDet
			Loop
		EndIF
		
		If SubStr(xBuffer,1,1) $ "1#F#J#7#2" .or. Substr(xBuffer,1,3) == "001"
			nDespes :=0
			nDescont:=0
			nAbatim :=0
			nValRec :=0
			nJuros  :=0
			nMulta  :=0
			If mv_par07 == 1						// somente carteira receber
				nValIof :=0
				nValCc  :=0
				dCred   :=ctod("  /  /  ")
			Else
				cCgc := " "
			EndIf
			cData   :=""
			dBaixa  :=ctod("  /  /  ")
			cEspecie:="  "
			cNossoNum:=Space(15)
			cForne:= Space(8)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Lˆ os valores do arquivo Retorno ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF !Empty(cPosDesp)
				nDespes:=Val(Substr(xBuffer,Int(Val(Substr(cPosDesp,1,3))),nLenDesp))/100
			EndIF
			IF !Empty(cPosDesc)
				nDescont:=Val(Substr(xBuffer,Int(Val(Substr(cPosDesc,1,3))),nLenDesc))/100
			EndIF
			IF !Empty(cPosAbat)
				nAbatim:=Val(Substr(xBuffer,Int(Val(Substr(cPosAbat,1,3))),nLenAbat))/100
			EndIF
			IF !Empty(cPosPrin)
				nValRec :=Val(Substr(xBuffer,Int(Val(Substr(cPosPrin,1,3))),nLenPrin))/100
			EndIF
			IF !Empty(cPosJuro)
				nJuros  :=Val(Substr(xBuffer,Int(Val(Substr(cPosJuro,1,3))),nLenJuro))/100
			EndIF
			IF !Empty(cPosMult)
				nMulta  :=Val(Substr(xBuffer,Int(Val(Substr(cPosMult,1,3))),nLenMult))/100
			EndIF
			IF !Empty(cPosIof)
				nValIof :=Val(Substr(xBuffer,Int(Val(Substr(cPosIof,1,3))),nLenIof))/100
			EndIF
			IF !Empty(cPosCc)
				nValCc :=Val(Substr(xBuffer,Int(Val(Substr(cPosCc,1,3))),nLenCc))/100
			EndIF
			IF !Empty(cPosNosso)
				cNossoNum :=Substr(xBuffer,Int(Val(Substr(cPosNosso,1,3))),nLenNosso)
			EndIF
			IF !Empty(cPosForne)
				cForne  :=Substr(xBuffer,Int(Val(Substr(cPosForne,1,3))),nLenForne)
			Endif
			If !Empty(cPosCgc)
				cCgc  :=Substr(xBuffer,Int(Val(Substr(cPosCgc,1,3))),nLenCgc)
			Endif
			
			cDescr  := ""
			cNumTit :=Substr(xBuffer,Int(Val(Substr(cPosNum, 1,3))),nLenNum )
			cData   :=Substr(xBuffer,Int(Val(Substr(cPosData,1,3))),nLenData)
			If !Empty(cData)
				cData   := ChangDate(cData,SEE->EE_TIPODAT)
				dBaixa  :=Ctod(Substr(cData,1,2)+"/"+Substr(cData,3,2)+"/"+Substr(cData,5),"ddmm"+Replicate("y",Len(Substr(cData,5))))
			Else
				dBaixa  := dDataBase
			EndIf
			cTipo   :=Substr(xBuffer,Int(Val(Substr(cPosTipo, 1,3))),nLenTipo )
			cTipo   := Iif(Empty(cTipo),"NF ",cTipo)		// Bradesco
			IF !Empty(cPosDtCc)
				cData :=Substr(xBuffer,Int(Val(Substr(cPosDtCc,1,3))),nLenDtCc)
				dCred :=Ctod(Substr(cData,1,2)+"/"+Substr(cData,3,2)+"/"+Substr(cData,5,2),"ddmmyy")
			EndIF
			If nLenOcor == 2
				cOcorr  :=Substr(xBuffer,Int(Val(Substr(cPosOcor,1,3))),nLenOcor) + " "
			Else
				cOcorr  :=Substr(xBuffer,Int(Val(Substr(cPosOcor,1,3))),nLenOcor)
			EndIf
			If nLenRej > 0
				cRej		:= Substr(xBuffer,Int(Val(Substr(cPosRej,1,3))),nLenRej)
			EndIf
			
			lOk := .T.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ o array aValores ir  permitir ³
			//³ que qualquer exce‡„o ou neces-³
			//³ sidade seja tratado no ponto  ³
			//³ de entrada em PARAMIXB        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			// Estrutura de aValores
			//	Numero do T¡tulo	- 01
			//	data da Baixa		- 02
			// Tipo do T¡tulo		- 03
			// Nosso Numero		- 04
			// Valor da Despesa	- 05
			// Valor do Desconto	- 06
			// Valor do Abatiment- 07
			// Valor Recebido    - 08
			// Juros					- 09
			// Multa					- 10
			// Valor do Credito	- 11
			// Data Credito		- 12
			// Ocorrencia			- 13
			// Linha Inteira		- 14
			
			aValores := ( { cNumTit, dBaixa, cTipo, cNossoNum, nDespes, nDescont, nAbatim, nValRec, nJuros, nMulta, nValCc, dCred, cOcorr, xBuffer })
			
			// Template GEM
			If lF650Var
				ExecBlock("F650VAR",.F.,.F.,{aValores})
			ElseIf ExistTemplate("GEMBaixa")
				ExecTemplate("GEMBaixa",.F.,.F.,)
			Endif
			
			If !Empty(cTipo)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica especie do titulo    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPos := Ascan(aTabela, {|aVal|aVal[1] == AllTrim(Substr(cTipo,1,Len(IIF(mv_par07==1,SE1->E1_TIPO,SE2->E2_TIPO))))})
				If nPos != 0
					cEspecie := aTabela[nPos][2]
				Else
					cEspecie	:= "  "
				EndIf
				If cEspecie $ MVABATIM			// Nao lˆ titulo de abatimento
					nLidos+=nTamDet
					Loop
				Endif
				
				If lNewIndice .and. !Empty(xFilial(IIF(mv_par07==1,"SE1","SE2")))
					//Busca por IDCNAB sem filial no indice
					dbSelectArea(IIF(mv_par07==1,"SE1","SE2"))
					dbSetOrder(IIF(mv_par07==1,19,13))
					cChave := Substr(cNumTit,1,10)
				Else
					//Busca por IDCNAB com filial no indice
					dbSelectArea(IIF(mv_par07==1,"SE1","SE2"))
					dbSetOrder(IIF(mv_par07==1,16,11))
					cChave := xFilial(IIF(mv_par07==1,"SE1","SE2"))+Substr(cNumTit,1,10)
				Endif
				
				lAchouTit := .F.
				// Busca pelo IdCnab
				If !Empty(cNumTit) .And. MsSeek(cChave)
					If ( mv_par07 == 1 )
						cEspecie  := SE1->E1_TIPO
					Else
						cEspecie  := SE2->E2_TIPO
					Endif
					lAchouTit := .T.
					nPos   	  := 1
				Endif
				
				// Localiza o titulo
				If lFr650Fil
					lAchouTit := Execblock("FR650FIL",.F.,.F.,{aValores})
				Endif
				
				// Busca pela chave antiga
				If !lAchouTit
					dbSetOrder(1)
					//Chave retornada pelo banco
					cChave650 := IIf(!Empty(cForne),Pad(cNumTit,nTamTit)+cEspecie+SubStr(cForne,1,nTamForn),Pad(cNumTit,nTamTit)+cEspecie)
					While !lAchouTit
						If !dbSeek(xFilial()+cChave650)
							nPos := Ascan(aTabela, {|aVal|aVal[1] == AllTrim(Substr(cTipo,1,Len(IIF(mv_par07==1,SE1->E1_TIPO,SE2->E2_TIPO))))},nPos+1)
							If nPos != 0
								cEspecie := aTabela[nPos][2]
								cChave650 := IIf(!Empty(cForne),Pad(cNumTit,nTamTit)+cEspecie+SubStr(cForne,1,nTamForn),Pad(cNumTit,nTamTit)+cEspecie)
							Else
								Exit
							Endif
						Else
							lAchouTit := .T.
						Endif
					Enddo
					
					//Chave retornada pelo banco com a adicao de espacos para tratar chave enviada ao banco com
					//tamanho de nota de 6 posicoes e retornada quando o tamanho da nota e 9 (atual)
					If !lAchouTit
						cNumTit := SubStr(cNumTit,1,nTamPre)+Padr(Substr(cNumTit,4,6),nTamNum)+SubStr(cNumTit,10,nTamPar)
						cChave650 := IIf(!Empty(cForne),Pad(cNumTit,nTamTit)+cEspecie+SubStr(cForne,1,nTamForn),Pad(cNumTit,nTamTit)+cEspecie)
						nPos := Ascan(aTabela, {|aVal|aVal[1] == AllTrim(Substr(cTipo,1,Len(IIF(mv_par07==1,SE1->E1_TIPO,SE2->E2_TIPO))))})
						While !lAchouTit
							If !dbSeek(xFilial()+cChave650)
								nPos := Ascan(aTabela, {|aVal|aVal[1] == AllTrim(Substr(cTipo,1,Len(IIF(mv_par07==1,SE1->E1_TIPO,SE2->E2_TIPO))))},nPos+1)
								If nPos != 0
									cEspecie := aTabela[nPos][2]
									cChave650 := IIf(!Empty(cForne),Pad(cNumTit,nTamTit)+cEspecie+SubStr(cForne,1,nTamForn),Pad(cNumTit,nTamTit)+cEspecie)
								Else
									Exit
								Endif
							Else
								lAchouTit := .T.
							Endif
						Enddo
					Endif
					
					If lAchouTit
						If mv_par07 == 2
							cNumSe2   := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO
							cChaveSe2 := IIf(!Empty(cForne),cNumSe2+SE2->E2_FORNECE,cNumSe2)
							nPosEsp	  := nPos	// Gravo nPos para volta-lo ao valor inicial, caso
							// Encontre o titulo
							While !Eof() .and. SE2->E2_FILIAL+cChaveSe2 == xFilial("SE2")+cChave650
								nPos := nPosEsp
								If Empty(cCgc)
									Exit
								Endif
								dbSelectArea("SA2")
								If dbSeek(xFilial()+SE2->E2_FORNECE+SE2->E2_LOJA)
									If Substr(SA2->A2_CGC,1,14) == cCGC .or. StrZero(Val(SA2->A2_CGC),14,0) == StrZero(Val(cCGC),14,0)
										Exit
									Endif
								Endif
								dbSelectArea("SE2")
								dbSkip()
								cNumSe2   := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO
								cChaveSe2 := IIf(!Empty(cForne),cNumSe2+SE2->E2_FORNECE,cNumSe2)
								nPos 	  := 0
							Enddo
						Endif
					Endif
				EndIf
				If nPos == 0
					cEspecie	:= "  "
					cCliFor	:= "  "
				Else
					cEspecie := IIF(mv_par07==1,SE1->E1_TIPO,SE2->E2_TIPO)
					cNumTit := IIF(mv_par07==1,SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA),SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA))
					cCliFor	:= IIF(mv_par07==1,SE1->E1_CLIENTE+" "+SE1->E1_LOJA,SE2->E2_FORNECE+" "+SE2->E2_LOJA)
				EndIF
				If cEspecie $ MVABATIM			// Nao lˆ titulo de abatimento
					nLidos += nTamDet
					Loop
				EndIf
			EndIF
		Else
			lTrailler := .T.
		Endif
	Else
		aLeitura := ReadCnab2(nHdlBco,MV_PAR02,nTamDet,aArqConf)
		If ( Empty(aLeitura[1]) )
			nLidos += nTamDet
			Loop
		Endif
		cNumTit  	:= SubStr(aLeitura[1],1,nTamTit)
		cData    	:= aLeitura[04]
		If !Empty(cData)
			cData    :=	ChangDate(cData,SEE->EE_TIPODAT)
			dBaixa   :=	Ctod(Substr(cData,1,2)+"/"+Substr(cData,3,2)+"/"+Substr(cData,5),"ddmm"+Replicate("y", Len(Substr(cData,5))))
		Else
			dBaixa   := dDataBase
		EndIf
		cTipo    	:= aLeitura[02]
		cTipo    	:= Iif(Empty(cTipo),"NF ",cTipo)		// Bradesco
		cNossoNum   := aLeitura[11]
		nDespes  	:= aLeitura[06]
		nDescont 	:= aLeitura[07]
		nAbatim  	:= aLeitura[08]
		nValRec  	:= aLeitura[05]
		nJuros   	:= aLeitura[09]
		nMulta   	:= aLeitura[10]
		cOcorr   	:= PadR(aLeitura[03],3)
		nValIof		:= aLeitura[12]
		nValCC   	:= aLeitura[13]
		cData    	:= aLeitura[14]
		If !Empty(cData)
			cData     := ChangDate(cData,SEE->EE_TIPODAT)
			dDataCred := Ctod(Substr(cData,1,2)+"/"+Substr(cData,3,2)+"/"+Substr(cData,5,2),"ddmmyy")
		Else
			dDataCred := dDataBase
		EndIf
		dDataUser	:= dDataCred
		dCred			:= dDataCred
		cRej		  	:= aLeitura[15]
		cForne		:= aLeitura[16]
		xBuffer		:= aLeitura[17]
		
		//CGC
		If Len(aLeitura) > 19
			cCgc := aLeitura[20]
		Else
			cCgc := " "
		Endif
		
		lOk := .t.
		lAchouTit := .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ o array aValores ir  permitir ³
		//³ que qualquer exce‡„o ou neces-³
		//³ sidade seja tratado no ponto  ³
		//³ de entrada em PARAMIXB        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// Estrutura de aValores
		//	Numero do T¡tulo	- 01
		//	data da Baixa		- 02
		// Tipo do T¡tulo		- 03
		// Nosso Numero		- 04
		// Valor da Despesa	- 05
		// Valor do Desconto	- 06
		// Valor do Abatiment- 07
		// Valor Recebido    - 08
		// Juros					- 09
		// Multa					- 10
		// Valor do Credito	- 11
		// Data Credito		- 12
		// Ocorrencia			- 13
		// Linha Inteira		- 14
		
		aValores := ( { cNumTit, dBaixa, cTipo, cNossoNum, nDespes, nDescont, nAbatim, nValRec, nJuros, nMulta, nValCc, dCred, cOcorr, xBuffer })
		nLenRej := Len(AllTrim(cRej))
		
		// Template GEM
		If lF650Var
			ExecBlock("F650VAR",.F.,.F.,{aValores})
		ElseIf ExistTemplate("GEMBaixa")
			ExecTemplate("GEMBaixa",.F.,.F.,)
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica especie do titulo    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPos := Ascan(aTabela, {|aVal|aVal[1] == AllTrim(Substr(cTipo,1,Len(IIF(mv_par07==1,SE1->E1_TIPO,SE2->E2_TIPO))))})
		If nPos != 0
			cEspecie := aTabela[nPos][2]
		Else
			cEspecie	:= "  "
		EndIf
		If cEspecie $ MVABATIM			// Nao lˆ titulo de abatimento
			nLidos += nTamDet
			Loop
		Endif
		If lNewIndice .and. !Empty(xFilial(IIF(mv_par07==1,"SE1","SE2")))
			//Busca por IDCNAB sem filial no indice
			dbSelectArea(IIF(mv_par07==1,"SE1","SE2"))
			dbSetOrder(IIF(mv_par07==1,19,13))
			cChave := Substr(cNumTit,1,10)
		Else
			//Busca por IDCNAB com filial no indice
			dbSelectArea(IIF(mv_par07==1,"SE1","SE2"))
			dbSetOrder(IIF(mv_par07==1,16,11))
			cChave := xFilial(IIF(mv_par07==1,"SE1","SE2"))+Substr(cNumTit,1,10)
		Endif
		
		lAchouTit := .F.
		// Busca pelo IdCnab
		If !Empty(cNumTit) .And. MsSeek(cChave)
			If ( mv_par07 == 1 )
				cEspecie  := SE1->E1_TIPO
			Else
				cEspecie  := SE2->E2_TIPO
			Endif
			lAchouTit := .T.
			nPos   	  := 1
		Endif
		
		// Localiza o titulo
		If lFr650Fil
			lAchouTit := Execblock("FR650FIL",.F.,.F.,{aValores})
		Endif
		
		// Busca pela chave antiga
		While !lAchouTit
			dbSetOrder(1)
			//Chave retornada pelo banco
			cChave650 := IIf(!Empty(cForne),Pad(cNumTit,nTamTit)+cEspecie+SubStr(cForne,1,6),Pad(cNumTit,nTamTit)+cEspecie)
			If !dbSeek(xFilial()+cChave650)
				nPos := Ascan(aTabela, {|aVal|aVal[1] == AllTrim(Substr(cTipo,1,Len(IIF(mv_par07==1,SE1->E1_TIPO,SE2->E2_TIPO))))},nPos+1)
				If nPos != 0
					cEspecie := aTabela[nPos][2]
				Else
					Exit
				Endif
			Else
				lAchouTit := .T.
			Endif
			
			//Chave retornada pelo banco com a adicao de espacos para tratar chave enviada ao banco com
			//tamanho de nota de 6 posicoes e retornada quando o tamanho da nota e 9 (atual)
			If !lAchouTit
				cChave650 := SubStr(cChave650,1,nTamPre)+Padr(Substr(cChave650,4,6),nTamNum)+SubStr(cChave650,10)
				If !dbSeek(xFilial()+cChave650)
					nPos := Ascan(aTabela, {|aVal|aVal[1] == AllTrim(Substr(cTipo,1,Len(IIF(mv_par07==1,SE1->E1_TIPO,SE2->E2_TIPO))))},nPos+1)
					If nPos != 0
						cEspecie := aTabela[nPos][2]
					Else
						Exit
					Endif
				Else
					lAchouTit := .T.
				Endif
			Endif
			
			If lAchouTit
				If mv_par07 == 2
					cNumSe2   := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO
					cChaveSe2 := IIf(!Empty(cForne),cNumSe2+SE2->E2_FORNECE,cNumSe2)
					nPosEsp	  := nPos	// Gravo nPos para volta-lo ao valor inicial, caso
					// Encontre o titulo
					While !Eof() .and. SE2->E2_FILIAL+cChaveSe2 == xFilial("SE2")+cChave650
						nPos := nPosEsp
						If Empty(cCgc)
							Exit
						Endif
						dbSelectArea("SA2")
						If dbSeek(xFilial()+SE2->E2_FORNECE+SE2->E2_LOJA)
							If Substr(SA2->A2_CGC,1,14) == cCGC .or. StrZero(Val(SA2->A2_CGC),14,0) == StrZero(Val(cCGC),14,0)
								Exit
							Endif
						Endif
						dbSelectArea("SE2")
						dbSkip()
						cNumSe2   := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO
						cChaveSe2 := IIf(!Empty(cForne),cNumSe2+SE2->E2_FORNECE,cNumSe2)
						nPos 	  := 0
					Enddo
				Endif
			Endif
		Enddo
		If nPos == 0
			cEspecie	:= "  "
			cCliFor	:= "  "
		Else
			cEspecie := IIF(mv_par07==1,SE1->E1_TIPO,SE2->E2_TIPO)
			cNumTit := IIF(mv_par07==1,SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA),SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA))
			cCliFor	:= IIF(mv_par07==1,SE1->E1_CLIENTE+" "+SE1->E1_LOJA,SE2->E2_FORNECE+" "+SE2->E2_LOJA)
		EndIF
		If cEspecie $ MVABATIM			// Nao lˆ titulo de abatimento
			nLidos += nTamDet
			Loop
		EndIf
	EndIf
	
	If ( lTrailler )
		nLidos+=nTamDet
		loop
	EndIf
	
	IF lEnd
		@ PROW()+1, 001 PSAY STR0054  //"CANCELADO PELO OPERADOR"
		Exit
	End
	
	IF li > 58
		cabec(Titulo+' - '+mv_par01,cabec1,cabec2,nomeprog,tamanho,nTipo)
	End
	
	@li,000 PSAY cNumTit
	@li,016 PSAY cEspecie
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica codigo da ocorrencia ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nValOrig := 0
	dbSelectArea("SEB")
	If mv_par07 == 1
		cCarteira := "R"
		If lAchouTit
			nValOrig := SE1->E1_VLCRUZ
		Endif
	Else
		cCarteira := "P"
		If lAchouTit
			nValOrig := SE2->E2_VLCRUZ
		Endif
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a despesa est     ³
	//³ descontada do valor principal ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SEE->EE_DESPCRD == "S"
		nValRec := nValRec+nDespes+nValIOF - nValCC
	EndIf
	
	If (dbSeek(cFilial+mv_par03+cOcorr+cCarteira))
		cDescr := RTrim(cOcorr) + "-" + Subs(SEB->EB_DESCRI,1,27)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua contagem dos SubTotais por ocorrencia  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nCntOco := Ascan(aCntOco, { |X| X[1] == cOcorr})
		If nCntOco == 0
			Aadd(aCntOco,{cOcorr,Subs(SEB->EB_DESCRI,1,27),nDespes,nDescont,nAbatim,nValRec,nJuros+nMulta,nValIof,nValCc,nValOrig})
		Else
			aCntOco[nCntOco][DESPESAS]     +=nDespes
			aCntOco[nCntOco][DESCONTOS]    +=nDescont
			aCntOco[nCntOco][ABATIMENTOS]  +=nAbatim
			aCntOco[nCntOco][VALORRECEBIDO]+=nValRec
			aCntOco[nCntOco][JUROS]        +=nJuros+nMulta
			aCntOco[nCntOco][VALORIOF]     +=nValIOF
			aCntOco[nCntOco][VALORCC]      +=nValCC
			aCntOco[nCntOco][VALORORIG]    +=nValOrig
		Endif
		
		If SEB->EB_OCORR $ "03ü15ü16ü17ü40ü41ü42"		//Registro rejeitado
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica tabela de rejeicao   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nLenRej > 0
				If dbSeek(cFilial+mv_par03+cOcorr+cCarteira+Substr(cRej,1,2))
					cDescr := RTrim(cOcorr) + "(" + Substr(cRej,1,2) + ;
					")" + "-" + Substr(SEB->EB_DESCMOT,1,22)
				EndIf
				lRej := .T.
			EndIf
		EndIf
		lOcorr := .T.
	Else
		cDescr  := Space(29)
		lOcorr  := .F.
		nCntOco := Ascan(aCntOco, { |X| X[2] == OemToAnsi(STR0016)})
		If nCntOco == 0
			Aadd(aCntOco,{"00 ",OemToAnsi(STR0016),nDespes,nDescont,nAbatim,nValRec,nJuros+nMulta,nValIof,nValCc,nValOrig})
		Else
			aCntOco[nCntOco][DESPESAS]     +=nDespes
			aCntOco[nCntOco][DESCONTOS]    +=nDescont
			aCntOco[nCntOco][ABATIMENTOS]  +=nAbatim
			aCntOco[nCntOco][VALORRECEBIDO]+=nValRec
			aCntOco[nCntOco][JUROS]        +=nJuros+nMulta
			aCntOco[nCntOco][VALORIOF]     +=nValIOF
			aCntOco[nCntOco][VALORCC]      +=nValCC
			aCntOco[nCntOco][VALORORIG]    +=nValOrig
		Endif
	Endif
	
	// Ponto de entrada para alterar a descricao do relatorio
	If ExistBlock ("F650DESCR")
		cDescr := ExecBlock("F650DESCR",.F.,.F.,{cDescr})
	EndIf
	
	If mv_par07 == 1
		dbSelectArea("SE1")
	Else
		dbSelectArea("SE2")
	EndIf
	
	@li,020 PSAY cCliFor
	// Caso o tamanho do campo cliente/fornecedor seja maior do que 6.
	If nTmClifor > 8
		li++
	Endif
	
	@li,030 PSAY Subs(cDescr,1,25)
	@li,055 PSAY dBaixa
	@li,063 PSAY nValOrig picture tm(nValOrig,13) //'@E 99999,999.99'
	@li,077 PSAY nValRec  picture tm(nValRec,13)	 //'@E 99999,999.99'
	@li,092 PSAY nDespes  picture tm(nDespes,12)  //'@E 99999,999.99'
	@li,106 PSAY nDescont picture tm(nDescont,12) //'@E 99999,999.99'
	@li,120 PSAY nAbatim  picture tm(nAbatim,12)  //'@E 99999,999.99'
	@li,133 PSAY nJuros+nMulta  picture tm(nJuros+nMulta,12)	 //'@E 99999,999.99'
	If mv_par07 == 1
		@li,146 PSAY nValIof  picture tm(nValIof,10) //'@E 999,999.99'
		@li,157 PSAY nValCc   picture tm(nValCC,10)  //'@E 999,999.99'
		@li,168 PSAY Iif(Empty(dCred),dDataBase,dCred)
		@li,179 PSAY Pad(cNossoNum,19)
	Else
		@li,153 PSAY Pad(cNossoNum,19)
	EndIf
	
	nDespT += nDespes
	nDescT += nDescont
	nAbatT += nAbatim
	nValT  += nValRec
	nJurT  += nJuros+nMulta
	nOriT  += nValOrig
	
	If mv_par07 == 1
		nIOFT  += nValIOF
		nCCT   += nValCC
	EndIf
	
	IF Empty(cOcorr)
		cDescr := OemToAnsi(STR0015)  	//"OCORRENCIA NAO ENVIADA"
		lOk := autrImpCons(cDescr)
	Else
		If ! lOcorr
			cDescr := OemToAnsi(STR0016)  //"OCORRENCIA NAO ENCONTRADA"
			lOk := autrImpCons(cDescr)
		End
	EndIf
	
	If dBaixa < dDataFin
		cDescr := OemToAnsi(STR0026)		//"DATA MENOR QUE DATA FECH.FINANCEIRO"
		lOk := autrImpCons(cDescr)
	Endif
	
	IF Empty(cNumTit)
		cDescr := OemToAnsi(STR0017)  	//"NUMERO TITULO NAO ENVIADO"
		lOk := autrImpCons(cDescr)
	End
	
	If !lAchouTit
		cDescr := OemToAnsi(STR0018)  	//"TITULO NAO ENCONTRADO"
		lOk := autrImpCons(cDescr)
	Endif
	IF Substr(dtoc(dBaixa),1,1)=' '
		cDescr := OemToAnsi(STR0019) 		//"DATA DE BAIXA NAO ENVIADA"
		lOk := autrImpCons(cDescr)
	EndIF
	
	IF Empty(cTipo)
		cDescr := OemToAnsi(STR0020)  	//"ESPECIE NAO ENVIADA"
		lOk := autrImpCons(cDescr)
	Endif
	
	If Empty(cEspecie)
		cDescr := OemToAnsi(STR0021)  	//"ESPECIE NAO ENCONTRADA"
		lOk := autrImpCons(cDescr)
	Endif
	
	If mv_par07 == 1 .and. lAchouTit .and. nAbatim == 0 .and. SE1->E1_SALDO > 0
		nValPadrao := nValRec-(nJuros+nMulta-nDescont)
		nTotAbat := SumAbatRec(Substr(cNumtit,1,3),Substr(cNumtit,4,6),;
		Substr(cNumtit,10,1),1,"S")
		If Round(NoRound(nValPadrao,3),2) > 0
			If Round(NoRound((SE1->E1_SALDO-nTotAbat),3),2) < Round(NoRound(nValPadrao,3),2)
				cDescr := STR0050 //"VLR REC MAIOR"
				lOk := autrImpCons(cDescr)
			Endif
			If Round(NoRound((SE1->E1_SALDO-nTotAbat),3),2) > Round(NoRound(nValPadrao,3),2)
				cDescr := STR0051 //"VLR REC MENOR"
				lOk := autrImpCons(cDescr)
			Endif
		EndIf
	Endif
	
	If mv_par07 == 2 .and. lAchouTit .and. nAbatim == 0 .and. SE2->E2_SALDO > 0
		nValPadrao := nValRec-(nJuros+nMulta-nDescont)
		nTotAbat	:= SumAbatPag(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_FORNECE,SE2->E2_MOEDA,"S",dDatabase,SE2->E2_LOJA)
		If Round(NoRound(nValPadrao,3),2) > 0
			If Round(NoRound((SE2->E2_SALDO-nTotAbat),3),2) < Round(NoRound(nValPadrao,3),2)
				cDescr := STR0052 //"VLR PAGO MAIOR"
				lOk := autrImpCons(cDescr)
			Endif
			If Round(NoRound((SE2->E2_SALDO-nTotAbat),3),2) > Round(NoRound(nValPadrao,3),2)
				cDescr := STR0053 //"VLR PAGO MENOR"
				lOk := autrImpCons(cDescr)
			Endif
		EndIf
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Informa a condicao da baixa do titulo         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lOk
		If mv_par07 == 1
			If SE1->E1_SALDO = 0
				cDescr := STR0028 //"BAIXADO ANTERIORMENTE - TOTAL"
				lOk := autrImpCons(cDescr)
			ElseIf SE1->E1_VALOR <> SE1->E1_SALDO
				cDescr := STR0029 //"BAIXADO ANTERIORMENTE - PARCIAL"
				lOk := autrImpCons(cDescr)
			End
		Else
			If SE2->E2_SALDO = 0
				cDescr := STR0028 //"BAIXADO ANTERIORMENTE - TOTAL"
				lOk := autrImpCons(cDescr)
			ElseIf SE2->E2_VALOR <> SE2->E2_SALDO
				cDescr := STR0029 //"BAIXADO ANTERIORMENTE - PARCIAL"
				lOk := autrImpCons(cDescr)
			End
		Endif
	Endif
	
	If lOk
		If lRej
			cDescr := OemToAnsi(STR0055)  	//"TITULO REJEITADO"
			lOk := autrImpCons(cDescr)
		Else
			If mv_par07 == 1
				cDescr := OemToAnsi(STR0022)  	//"TITULO RECEBIDO"
			Else
				cDescr := OemToAnsi(STR0030)  	//"TITULO PAGO"
			Endif
			lOk := autrImpCons(cDescr)
		EndIf
	EndIf
	
	If nLenRej > 0
		If Len(Alltrim(cRej)) > 2
			For nCont := 3 to Len(Alltrim(cRej)) Step 2
				If lRej
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica tabela de rejeicao   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SEB")
					If dbSeek(cFilial+mv_par03+cOcorr+cCarteira+Substr(cRej,nCont,2))
						cDescr := RTrim(cOcorr) + "(" + Substr(cRej,nCont,2) + ;
						")" + "-" + Substr(SEB->EB_DESCMOT,1,22)
						@li,030 PSAY Subs(cDescr,1,26)
						li++
					EndiF
				EndIf
			Next nCont
		EndIf
	EndIf
	If mv_par07 == 1
		dbSelectArea("SE1")
	Else
		dbSelectArea("SE2")
	EndIf
	If mv_par08 == 1
		nLidos+=nTamDet
	Endif
EndDO

IF li != 80
	Li+=2
	
	If (Len(aCntOco) + Li) > 55
		Cabec(Titulo+' - '+mv_par01,cabec1,cabec2,nomeprog,tamanho,nTipo)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime Subtotais por ocorrencia  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@li,000 PSAY OemToAnsi(STR0027)  //"SUBTOTAIS DO RELATORIO"
	Li+=2
	For x :=1 to Len(aCntOco)
		@li,000 PSAY aCntOco[x][1] + Substr(aCntOco[x][2],1,30)
		@li,063 PSAY (aCntOco[x][VALORORIG])		picture Tm((aCntOco[x][10]),13) //'@E 9,999,999,999.99'
		@li,077 PSAY (aCntOco[x][VALORRECEBIDO]) picture Tm((aCntOco[x][06]),13) //'@E 9,999,999,999.99'
		@li,092 PSAY (aCntOco[x][DESPESAS])      picture Tm((aCntOco[x][03]),12) //'@E 9,999,999,999.99'
		@li,106 PSAY (aCntOco[x][DESCONTOS])     picture Tm((aCntOco[x][04]),12) //'@E 9,999,999,999.99'
		@li,120 PSAY (aCntOco[x][ABATIMENTOS])   picture Tm((aCntOco[x][05]),12) //'@E 9,999,999,999.99'
		@li,133 PSAY (aCntOco[x][JUROS])         picture Tm((aCntOco[x][07]),12) //'@E 9,999,999,999.99'
		If mv_par07 == 1
			@li,146 PSAY (aCntOco[x][VALORIOF])   picture Tm((aCntOco[x][08]),10) //'@E 9999,999.99'
			@li,157 PSAY (aCntOco[x][VALORCC])    picture Tm((aCntOco[x][09]),10) //'@E 9999,999.99'
		Endif
		Li ++
	Next
	Li+=2
	
	If (Len(aCntOco) + Li) > 58
		Cabec(Titulo+' - '+mv_par01,cabec1,cabec2,nomeprog,tamanho,nTipo)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime Totais                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@li,000 PSAY OemToAnsi(STR0023)  //"TOTAIS DO RELATORIO"
	@li,063 PSAY nOriT       picture Tm(nOriT,13)  //'@E 9,999,999,999.99'
	@li,077 PSAY nValT       picture Tm(nValT,13)  //'@E 9,999,999,999.99'
	@li,092 PSAY nDespT      picture TM(nDespT,12) //'@E 9,999,999,999.99'
	@li,106 PSAY nDescT      picture TM(nDescT,12) //'@E 9,999,999,999.99'
	@li,120 PSAY nAbatT      picture TM(nAbatT,12) //'@E 9,999,999,999.99'
	@li,133 PSAY nJurT       picture Tm(nJurT,12)  //'@E 9,999,999,999.99'
	
	If mv_par07 == 1
		@li,146 PSAY nIofT    picture TM(nIofT,10) //'@E 9999,999.99'
		@li,157 PSAY nCcT     picture TM(nCcT,10)  //'@E 9999,999.99'
	EndIf
	roda(cbcont,cbtxt,tamanho)
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha os Arquivos ASCII ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
fClose(nHdlBco)
fClose(nHdlConf)

If FILE(cDestino+cBarra+cFileName)
	FErase(cDestino+cBarra+cFileName)
EndIf

Set Device TO Screen
dbSelectArea("SEF")
dbSetOrder(1)
Set Filter To

// Restaura area do contas a receber ou contas a pagar
If mv_par07 == 1	// Receber
	RestArea( aAreaSE1 )
Else				// Pagar
	RestArea( aAreaSE2 )
EndIf
If aReturn[5] = 1
	Set Printer To
	dbCommit()
	Ourspool(wnrel)
End
MS_FLUSH()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ IMPCONS  ³ Autor ³ Elaine F. T. Beraldo  ³ Data ³ 27/06/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impress„o da Consistencia                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ IMPCONS(texto)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINR650.PRG                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function autrImpCons(cTexto)

If mv_par07 == 1
	@ li,195 PSAY Pad(cTexto,23)
Else
	@ li,173 PSAY Pad(cTexto,31)
EndIf
li++

Return .F.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³AjustaSX1 ³ Autor ³ Gustavo Henrique      ³ Data ³ 13/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza perguntas no SX1                              	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³AjustaSX1 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³FINR650													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1()

Local aArea		:= GetArea()
Local aAreaSX1	:= SX1->( GetArea() )
Local nTamGrupo	:= Len( SX1->X1_GRUPO )
Local nTamPerg	:= 0

// Compatibiliza tamanho da pergunta "Arquivo de Entrada?" entre os grupos de
// pergunta da rotina de Retorno de Cobrancas e o relatorio de Retorno CNAB
If	SX1->( MsSeek( PadR( "AFI200", nTamGrupo ) + "04" ) )
	
	nTamPerg := SX1->X1_TAMANHO
	
	// Altera tamanho da pergunta 01
	If	SX1->( MsSeek( PadR( "FIN650", nTamGrupo ) + "01" ) ) .And.;
		nTamPerg <> SX1->X1_TAMANHO
		
		SX1->( RecLock( "SX1", .F. ) )
		SX1->X1_TAMANHO := nTamPerg
		SX1->( MsUnlock() )
		
	EndIf
	
EndIf

// Compatibiliza tamanho da pergunta "Arquivo de Config?" entre os grupos de
// pergunta da rotina de Retorno de Cobrancas e o relatorio de Retorno CNAB
If	SX1->( MsSeek( PadR( "AFI200", nTamGrupo ) + "05" ) )
	
	nTamPerg := SX1->X1_TAMANHO
	
	// Altera tamanho da pergunta 02
	If SX1->( MsSeek( PadR( "FIN650", nTamGrupo ) + "02" ) ) .And.;
		nTamPerg <> SX1->X1_TAMANHO
		
		SX1->( RecLock( "SX1", .F. ) )
		SX1->X1_TAMANHO := nTamPerg
		SX1->( MsUnlock() )
		
	EndIf
	
EndIf

RestArea( aAreaSX1 )
RestArea( aArea )

Return
