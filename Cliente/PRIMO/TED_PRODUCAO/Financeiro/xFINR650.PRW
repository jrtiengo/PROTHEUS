#INCLUDE "FINR650.CH"
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

Static lExecJob := ExecSchedule()

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
User Function xFinr650(aParam)

	Local oReport
	DEFAULT aParam := {}

	oReport:=ReportDef(aParam)
	If !lExecJob
		oReport:PrintDialog()
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

Static Function ReportDef(aParam)

	Local oReport
	Local nI := NIL
	DEFAULT aParam := {}	//Modelo conteudo do array {{'MV_PAR01',Valor},{'MV_PAR02',Valor},{'MV_PARn',ValorN}}
	//Adicinar no MV_PAR01 a lupa (F3) de consultapadrão "DIR" para seleção do arquivo a ser importado.
	If EMPTY(aParam)
		Pergunte("FIN650",.F.)
	Else
		For nI := 1 To LEN(aParam)
			If 'MV_PAR' $ UPPER(aParam[nI,1])
				&(aParam[nI,1]) := aParam[nI,2]
			EndIf
		Next nI
	EndIf

	oReport := TReport():New("FINR650",STR0004,"FIN650",{|oReport| ReportPrint(oReport)},STR0001+STR0002+STR0003)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Secao 1 - Titulos a Receber   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oSection1 := TRSection():New(oReport,STR0047)
	//TRCell():New(oSection1,"SEC1_TIT",,STR0031,,25,,)
	TRCell():New(oSection1,"SEC1_CLI",,STR0032,,30,,)
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
	// Jean Rehermann - 03/08/2020 - Incluí a linha abaixo
	TRCell():New(oSection1,"SEC1_TIT",,STR0031,,23,,)
	//TRCell():New(oSection1,"SEC1_NTIT",,STR0043,,19,,)
	TRCell():New(oSection1,"SEC1_CONS",,STR0046,,26,,)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Secao 3 - Subtotais  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

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
Local cArqConf ,cArqEnt
Local lOcorr := .F.
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
Local lProcessa := .T.
Local aTabela 	:= {}
Local cChave650
Local nPos := 0
Local lAchouTit := .F.
Local nValPadrao := 0
Local aValores := {}
LOCAL lF650Var := ExistBlock("F650VAR" )
LOCAL dDataFin := Getmv("MV_DATAFIN")
Local lOk
Local x
Local nCntOco  := 0
Local aCntOco  := {}
Local cCliFor	:= "  "
Local lFr650Fil:= ExistBlock("FR650FIL")
Local nValOrig	:= 0
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
Local cChave 	:= ""
Local cDestino  := ""
Local cBarra    := If(isSrvUnix(),"/","\")
Local cFileName := ""
Local aFile		:= {}
Local aArqConf	:= {}		// Atributos do arquivo de configuracao
Local aAreaSE1	:= {}
Local aAreaSE2	:= {}
Local cLocRec 	:= SuperGetMV( "MV_LOCREC" , .F. , " " )
Local lBarra    := isSrvUnix()
Local cCamArq	:= ""

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
   nTamDet := Iif(Empty (SEE->EE_NRBYTES), 400, SEE->EE_NRBYTES)
   ntamDet += 2  // Ajusta tamanho do detalhe para leitura do CR (fim de linha)
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

MV_PAR01 := Alltrim(MV_PAR01)
cLocRec  := Alltrim(cLocRec)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o arquivo de entrada esta na maquina local, e se estiver copia para o servidor ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Substr(mv_par01,2,2)== ":"+cBarra
	aFile := Directory(Alltrim(mv_par01))
	If Empty(aFile)
		Help(" ",1,"NOARQENT")
		Return .F.
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
Else
	If Empty(cLocRec)
		If File(MV_PAR01)
			cArqEnt := MV_PAR01
		Else
			Help( Nil, Nil, "Arquivo não Encontrado", Nil , "O arquivo "+ MV_PAR01 + ", não foi localizado. Favor verificar" , 1, 0 )
			Return .F.
		Endif
	Else
		If AT("/", MV_PAR01) > 0 .Or. AT("\", MV_PAR01) > 0 .Or. AT(":", MV_PAR01) > 0
			If File(MV_PAR01)
				cArqEnt := MV_PAR01
			Else
				cCamArq  := cLocRec + MV_PAR01
				If File(cCamArq)
					cArqEnt := cCamArq
				Else
					Help( Nil, Nil, "Arquivo não Encontrado", Nil , "O arquivo "+ MV_PAR01 + "," + "Informado no caminho " + cCamArq + "não foi localizado. Favor verificar" , 1, 0 )  //"Arquivo não Encontrado" # "O arquivo " #  " "Informado no caminho " # "não foi localizado. Favor verificar"
					Return .F.
				Endif
			Endif
		Else
			If ! SubStr(cLocRec, Len(cLocRec), 1 ) $ "/|\|"
				If lBarra
					cLocRec := cLocRec + "/"
				Else
					cLocRec := cLocRec + "\"
				Endif
			Endif

			cCamArq  := cLocRec + MV_PAR01
			If File(cCamArq)
				cArqEnt := cCamArq
			Else
				If !lExecJob
					Help( Nil, Nil, "Arquivo não Encontrado", Nil , "O arquivo "+ MV_PAR01 + "," + "Informado no caminho " + cCamArq + "não foi localizado. Favor verificar" , 1, 0 )  //"Arquivo não Encontrado" # "O arquivo " #  " "Informado no caminho " # "não foi localizado. Favor verificar"
					Return .F.
				Else
					Return .F.
				Endif
			Endif
		Endif
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre arquivo enviado pelo banco ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !FILE(cArqEnt)
	Set Device To Screen
	Set Printer To
	Help(" ",1,"NOARQENT")
	Return .F.
Else
	nHdlBco:=FOPEN(cArqEnt,0+64)
EndIf

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
//oSection1:Cell("SEC1_NTIT"):SetBlock({||Pad(cNossoNum,19)})
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

	lRej:=.F.
	lProcessa:=.T.

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

				//Busca por IDCNAB sem filial no indice
				lAchouTit := .F.
				dbSelectArea(IIF(mv_par07==1,"SE1","SE2"))
				dbSetOrder(IIF(mv_par07==1,19,13))
				cChave := Substr(cNumTit,1,10)

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
						cNumTit := SubStr(cNumTit,1,nTamPre)+Padr(Substr(cNumTit,nTampre+1,nTamNum),nTamNum)+SubStr(cNumTit,nTamPre+nTamNum+1,nTamPar)
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
					cCliFor	:= IIF(mv_par07==1,SE1->E1_CLIENTE+"-"+Left(Posicione("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,"SA1->A1_NREDUZ"),30),SE2->E2_FORNECE+"-"+Left(Posicione("SA2",1,xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"SA2->A2_NREDUZ"),30))
				EndIF
				If cEspecie $ MVABATIM			// Nao lˆ titulo de abatimento
					nLidos += nTamDet
					Loop
				EndIf
			EndIF
		Else
			lProcessa := .F.
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
		If Len(Alltrim(cOcorr)) > 2 .And. mv_par07 == 2
			cOcorr := PadR( Left(Alltrim(cOcorr),2) , 3)
		EndIf
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

		//Busca por IDCNAB sem filial no indice
		lAchouTit := .F.
		dbSelectArea(IIF(mv_par07==1,"SE1","SE2"))
		dbSetOrder(IIF(mv_par07==1,19,13))
		cChave := Substr(cNumTit,1,10)

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
				cNumTit := SubStr(cNumTit,1,nTamPre)+Padr(Substr(cNumTit,nTampre+1,nTamNum),nTamNum)+SubStr(cNumTit,nTamPre+nTamNum+1,nTamPar)
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
			cCliFor	:= IIF(mv_par07==1,SE1->E1_CLIENTE+"-"+Left(Posicione("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,"SA1->A1_NREDUZ"),30),SE2->E2_FORNECE+"-"+Left(Posicione("SA2",1,xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,"SA2->A2_NREDUZ"),30))
		EndIF
		If cEspecie $ MVABATIM			// Nao lˆ titulo de abatimento
			nLidos += nTamDet
			Loop
		EndIf
	EndIf

	If ( !lProcessa )
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

	If SEB->(dbSeek(cFilial+mv_par03+cOcorr+cCarteira))
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
				If dbSeek(cFilial+mv_par03+cOcorr+cCarteira+Substr(cRej,1,3))
						cDescr := RTrim(cOcorr) + "(" + Substr(cRej,1,3) + ;
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
			If Round(NoRound((xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,1,dBaixa,3,SE1->E1_TXMOEDA)-nTotAbat + SE1->E1_ACRESC - SE1->E1_DECRESC - SE1->E1_VLBOLSA),3),2) < Round(NoRound(nValRec,3),2)
				lPrint := If(Empty(cDescr2),.T.,.F.)
				cDescr2 := STR0050 //"VLR REC MAIOR"
		     	lOk := PRINTLINE(oReport,lPrint)
			ElseIf Round(NoRound((xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,1,dBaixa,3,SE1->E1_TXMOEDA)-nTotAbat + SE1->E1_ACRESC - SE1->E1_DECRESC - SE1->E1_VLBOLSA),3),2) > Round(NoRound(nValRec,3),2)
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
			If Round(NoRound((xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,1,dBaixa,3,SE2->E2_TXMOEDA)-nTotAbat),3),2) < Round(NoRound(nValPadrao,3),2)
				lPrint := If(Empty(cDescr2),.T.,.F.)
				cDescr2 := STR0052 //"VLR PAGO MAIOR"
		     	lOk := PRINTLINE(oReport,lPrint)
			Endif
			If Round(NoRound((xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,1,dBaixa,3,SE2->E2_TXMOEDA)-nTotAbat),3),2) > Round(NoRound(nValPadrao,3),2)
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

	//oSection1:Cell("SEC1_NTIT"):Show()

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

	//oSection1:Cell("SEC1_NTIT"):Hide()

	oSection1:PrintLine()

EndIf

Return .F.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ExecSchedule³ Autor ³ Aldo Barbosa dos Santos      ³21/12/10³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna se o programa esta sendo executado via schedule     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ExecSchedule()
Local lRetorno := .T.

lRetorno := IsBlind()

Return( lRetorno )
