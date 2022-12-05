#include "RWMAKE.CH"
#include "MATR968.CH"    
#include 'topconn.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATR968   ºAutor  ³Mary C. Hergert     º Data ³  03/08/2006 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao do RPS - Recibo Provisorio de Servicos - referenteº±±
±±º          ³ao processo da Nota Fiscal Eletronica de Sao Paulo.         º±±
±±º          ³Impressao grafica - sem integracao com word.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Sigafis                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AMATR968()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local wnrel
Local tamanho		:= "G"
Local titulo		:= "Impressão da Nota"
Local cDesc1		:= "Impressão da Nota de Serviços - RPS"
Local cDesc2		:= " "
Local cDesc3		:= " "
Local cTitulo		:= ""
Local cErro			:= ""
Local cSolucao		:= ""                         

Local lPrinter		:= .T.
Local lOk			:= .F.
Local aSays     	:= {}, aButtons := {}, nOpca := 0

Private nomeprog 	:= "MATR968"
Private nLastKey 	:= 0
Private cPerg

Private oPrint

cString := "SF2"
wnrel   := "MATR968"
cPerg   := "MTR968"

AjustaSX1()
Pergunte(cPerg,.F.)

AADD(aSays,"Impressão da Nota Fiscal de Serviços Eletrônica") //"Impressão do Recibo Provisório de Serviços - RPS"

AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|| nOpca := 1, FechaBatch() }} )
AADD(aButtons, { 2,.T.,{|| nOpca := 0, FechaBatch() }} )  

FormBatch( Titulo, aSays, aButtons,, 160 )

If nOpca == 0
   Return
EndIf   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configuracoes para impressao grafica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint := TMSPrinter():New("Impressão")		//"Impressão RPS"
oPrint:SetPortrait()					// Modo retrato
oPrint:SetPaperSize(9)					// Papel A4

If nLastKey = 27
	dbClearFilter()
	Return
Endif

RptStatus({|lEnd| Mt968Print(@lEnd,wnRel,cString)},Titulo)

oPrint:Preview()  		// Visualiza impressao grafica antes de imprimir

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Mt968Print³ Autor ³ Mary C. Hergert       ³ Data ³ 03/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chamada do Processamento do Relatorio                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATR968                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Mt968Print(lEnd,wnRel,cString)

Local aAreaRPS		:= {}
Local aPrintServ	:= {}
Local aPrintObs		:= {}
Local aTMS			:= {}
Local aItensSD2     := {}

Local cServ			:= ""
Local cDescrServ	:= ""
Local cCNPJCli		:= ""                            
Local cTime			:= "" 
Local lNfeServ		:= AllTrim(SuperGetMv("MV_NFESERV",.F.,"1")) == "1"
Local cLogo			:= ""
Local cServPonto	:= ""               
Local cObsPonto		:= ""
Local cAliasSF3		:= "SF3"
Local cCli			:= ""
Local cIMCli		:= ""
Local cEndCli		:= ""
Local cBairrCli		:= ""
Local cCepCli		:= ""
Local cMunCli		:= ""
Local cUFCli		:= ""
Local cEmailCli		:= ""
Local cCampos		:= ""     
Local cDescrBar     := SuperGetMv("MV_DESCBAR",.F.,"")
Local cCodServ      := ""
Local cF3_NFISCAL   := ""
Local cF3_SERIE     := ""
Local cF3_CLIEFOR   := ""
Local cF3_LOJA      := ""
Local cF3_EMISSAO   := ""
Local cKey          := ""        
Local cObsRio       := ""
Local cLogAlter     := GetNewPar("MV_LOGRPS","") // caminho+nome do logotipo alternativo  
Local cTotImp       := ""
Local cFontImp      := ""

Local lCampBar      := !Empty(cDescrBar) .And. SB1->(FieldPos(cDescrBar)) > 0
Local lIssMat		:= (cAliasSF3)->(FieldPos("F3_ISSMAT")) > 0
Local lDescrNFE		:= ExistBlock("MTDESCRNFE")
Local lObsNFE		:= ExistBlock("MTOBSNFE")
Local lCliNFE		:= ExistBlock("MTCLINFE")           
Local lPEImpRPS		:= ExistBlock("MTIMPRPS")           
Local lDescrBar     := GetNewPar("MV_DESCSRV",.F.)
Local lImpRPS		:= .T. 
Local lcmpAbat		:= SD2->( FieldPos("D2_ABATISS")>0 .And. FieldPos("D2_ABATMAT")>0 )

Local nValDed		  := 0
Local nTOTAL        := 0 
Local nDEDUCAO      := 0 
Local nBASEISS      := 0 
Local nALIQISS      := 0
Local nVALISS       := 0 
Local nDescIncond   := 0
Local nValLiq       := 0
Local nVlContab     := 0
Local nValDesc	     := 0

Local nAliqPis      := 0
Local nAliqCof      := 0
Local nAliqCSLL     := 0
Local nAliqIR       := 0
Local nAliqINSS     := 0
Local nValPis       := 0
Local nValCof       := 0
Local nValCSLL      := 0
Local nValIR        := 0
Local nValINSS      := 0 
Local cNatureza     := ""
Local cRecIss       := "" 
Local cRecCof       := ""
Local cRecPis       := ""
Local cRecIR        := ""    
Local cRecCsl       := ""           
Local cRecIns		:= ""

Local nCopias		:= mv_par07
Local nLinIni		:= 225  
Local nColIni		:= 225
Local nColFim		:= 2175
Local nLinFim		:= 2975
Local nX			:= 1
Local nY			:= 1
Local nLinha		:= 0
Local _cObsAuto     := "" //Michel Aoki

Local oFont10 	:= TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFont10n	:= TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.)	//Negrito
Local oFont12n	:= TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.)	//Negrito
Local oFont09 	:= TFont():New("Courier New",9,9,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFont09n	:= TFont():New("Courier New",9,9,,.T.,,,,.T.,.F.)	//Negrito

Local oFontA08	:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFontA08n := TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)	//Negrito
Local oFontA09	:= TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFontA09n := TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)	//Negrito
Local oFontA10	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFontA10n := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)	//Negrito
Local oFontA11	:= TFont():New("Arial",11,11,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFontA11n := TFont():New("Arial",11,11,,.T.,,,,.T.,.F.)	//Negrito
Local oFontA12	:= TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFontA12n := TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)	//Negrito
Local oFontA13	:= TFont():New("Arial",13,13,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFontA13n := TFont():New("Arial",13,13,,.T.,,,,.T.,.F.)	//Negrito
Local oFontA14	:= TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFontA14n := TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)	//Negrito
Local oFontA16	:= TFont():New("Arial",16,16,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFontA16n := TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)	//Negrito
Local oFontA18	:= TFont():New("Arial",18,18,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFontA18n := TFont():New("Arial",18,18,,.T.,,,,.T.,.F.)	//Negrito
Local oFontA20  := TFont():New("Arial",20,20,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFontA20n := TFont():New("Arial",20,20,,.T.,,,,.T.,.F.)	//Negrito

                                               
#IFDEF TOP
	Local cQuery    := "" 
#ELSE 
	Local cChave    := ""
	Local cFiltro   := ""       
#ENDIF

Private lRecife	   := Iif(GetNewPar("MV_ESTADO","xx") == "PE" .And. Upper(Alltrim(SM0->M0_CIDENT)) == "RECIFE",.T.,.F.) 
Private lJoinville := Iif(GetNewPar("MV_ESTADO","xx") == "SC" .And. Upper(Alltrim(SM0->M0_CIDENT)) == "JOINVILLE",.T.,.F.)
Private lSorocaba  := Iif(GetNewPar("MV_ESTADO","xx") == "SP" .And. Upper(Alltrim(SM0->M0_CIDENT)) == "SOROCABA",.T.,.F.)
Private lRioJaneiro:= Iif(GetNewPar("MV_ESTADO","xx") == "RJ" .And. Upper(Alltrim(SM0->M0_CIDENT)) == "RIO DE JANEIRO",.T.,.F.)      
Private lBhorizonte:= Iif(GetNewPar("MV_ESTADO","xx") == "MG" .And. Upper(Alltrim(SM0->M0_CIDENT)) == "BELO HORIZONTE",.T.,.F.) 
Private _cnumNFSE := ""     

dbSelectArea("SF3")
dbSetOrder(6)

#IFDEF TOP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Campos que serao adicionados a query somente se existirem na base³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lIssMat
    	cCampos := " ,F3_ISSMAT "
	Endif
	 
	If lRecife
    	cCampos += " ,F3_CNAE "
	Endif	     
	
	If Empty(cCampos)
		cCampos := "%%"
	Else       
		cCampos := "% " + cCampos + " %"
	Endif                              

    If TcSrvType()<>"AS/400"
    
		lQuery 		:= .T.
		cAliasSF3	:= GetNextAlias()    
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se imprime ou nao os documentos cancelados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par08 == 2
			cQuery := "% SF3.F3_DTCANC = '' AND %"
		Else                                      
			cQuery := "%%"
		Endif
		
		BeginSql Alias cAliasSF3
			COLUMN F3_ENTRADA AS DATE
			COLUMN F3_EMISSAO AS DATE
			COLUMN F3_DTCANC AS DATE
			COLUMN F3_EMINFE AS DATE
			SELECT F3_FILIAL,F3_ENTRADA,F3_EMISSAO,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_PDV,
				F3_LOJA,F3_ALIQICM,F3_BASEICM,F3_VALCONT,F3_TIPO,F3_VALICM,F3_ISSSUB,F3_ESPECIE,
				F3_DTCANC,F3_CODISS,F3_OBSERV,F3_NFELETR,F3_EMINFE,F3_CODNFE,F3_CREDNFE, F3_ISENICM, F3_RECISS
				%Exp:cCampos%
			
			FROM %table:SF3% SF3
				
			WHERE SF3.F3_FILIAL = %xFilial:SF3% AND 
				SF3.F3_CFO >= '5' AND 
				SF3.F3_ENTRADA >= %Exp:mv_par01% AND 
				SF3.F3_ENTRADA <= %Exp:mv_par02% AND 
				SF3.F3_TIPO = 'S' AND
				SF3.F3_CODISS <> %Exp:Space(TamSX3("F3_CODISS")[1])% AND
				SF3.F3_CLIEFOR >= %Exp:mv_par03% AND
				SF3.F3_CLIEFOR <= %Exp:mv_par04% AND
				SF3.F3_NFISCAL >= %Exp:mv_par05% AND
				SF3.F3_NFISCAL <= %Exp:mv_par06% AND
				%Exp:cQuery%
				SF3.%NotDel%                           
					
			ORDER BY SF3.F3_ENTRADA,SF3.F3_SERIE,SF3.F3_NFISCAL,SF3.F3_TIPO,SF3.F3_CLIEFOR,SF3.F3_LOJA
		EndSql
	
		dbSelectArea(cAliasSF3)
	Else

#ENDIF
		cArqInd	:=	CriaTrab(NIL,.F.)
		cChave	:=	"DTOS(F3_ENTRADA)+F3_SERIE+F3_NFISCAL+F3_TIPO+F3_CLIEFOR+F3_LOJA+F3_CNAE"
		cFiltro := "F3_FILIAL == '" + xFilial("SF3") + "' .And. "
		cFiltro += "F3_CFO >= '5" + SPACE(LEN(F3_CFO)-1) + "' .And. "	
		cFiltro += "DtOs(F3_ENTRADA) >= '" + Dtos(mv_par01) + "' .And. "
		cFiltro	+= "DtOs(F3_ENTRADA) <= '" + Dtos(mv_par02) + "' .And. "
		cFiltro	+= "F3_TIPO == 'S' .And. F3_CODISS <> '" + Space(Len(F3_CODISS)) + "' .And. "
		cFiltro	+= "F3_CLIEFOR >= '" + mv_par03 + "' .And. F3_CLIEFOR <= '" + mv_par04 + "' .And. "
		cFiltro	+= "F3_NFISCAL >= '" + mv_par05 + "' .And. F3_NFISCAL <= '" + mv_par06 + "'"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se imprime ou nao os documentos cancelados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par08 == 2
			cFiltro	+= " .And. Empty(F3_DTCANC)"
		Endif

		IndRegua(cAliasSF3,cArqInd,cChave,,cFiltro,STR0006)  //"Selecionando Registros..."
		#IFNDEF TOP
			DbSetIndex(cArqInd+OrdBagExt())
		#ENDIF                
		(cAliasSF3)->(dbGotop())
		SetRegua(LastRec())

#IFDEF TOP
	Endif    
#ENDIF

If lSorocaba
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime os RPS gerados de acordo com o numero de copias selecionadas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While (cAliasSF3)->(!Eof())
		
		ProcRegua(LastRec())
		If Interrupcao(@lEnd)
			Exit
		Endif
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca o SF2 para verificar NF Cupom nao sera processada     ³
		//³e valor da Carga Tributária - Lei 12.741			           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTotImp := ""
		cFontImp:= ""
		
		SF2->(dbSetOrder(1))
		If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
			If !Empty(SF2->F2_NFCUPOM)
				(cAliasSF3)->(dbSKip())
				Loop
			Endif
			
			/* Comentado Michel Aoki - Futuramente usar este codigo, pois e o standard
			//Lei Transparência - 12.741
			cTotImp := Iif(SF2->(FieldPos("F2_TOTIMP"))>0 .And. SF2->F2_TOTIMP > 0,"Valor Aproximado dos Tributos: R$ "+Alltrim(Transform(SF2->F2_TOTIMP,"@E 999,999,999,999.99")+"."),"")
			
			//Busca a fonte da Carga Tributária - Lei Transparência - 12.741
			SB1->(dbSetOrder(1))  
		 	SD2->(dbSetOrder(3))
	     	If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
			   If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
			   		cFontImp:= Iif(!Empty(cTotImp) .And. "IBPT" $ AlqLeiTran("SB1","SBZ")[2],"Fonte: "+AlqLeiTran("SB1","SBZ")[2],"")
			   EndIf
			EndIf
			*/
		Endif
		
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para verificar se esse RPS deve ser impresso ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAreaRPS := (cAliasSF3)->(GetArea())
		lImpRPS	 := .T.
		If lPEImpRPS
			lImpRPS := Execblock("MTIMPRPS",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
		Endif
		RestArea(aAreaRPS)
		
		If !lImpRPS
			(cAliasSF3)->(dbSKip())
			Loop
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca a descricao do codigo de servicos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cDescrServ := ""
		SX5->(dbSetOrder(1))
		If SX5->(dbSeek(xFilial("SX5")+"60"+(cAliasSF3)->F3_CODISS))
			cDescrServ := Alltrim(SX5->X5_DESCRI)
		Endif
		If lDescrBar
			SF2->(dbSetOrder(1))
			SD2->(dbSetOrder(3))
			SB1->(dbSetOrder(1))
			If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
				If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
					If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
						cDescrServ := If (lCampBar,SB1->(AllTrim(&cDescrBar)),cDescrServ)
					Endif
				Endif
			Endif
		Endif
		
		If !Empty(cCodServ)
			cCodServ += " / "
		EndIf

		cCodServ += Alltrim((cAliasSF3)->F3_CODISS) + " - " + alltrim(cDescrServ)
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca o pedido para discriminar os servicos prestados no documento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cServ := ""
		If lNfeServ
			SC6->(dbSetOrder(4))
			SC5->(dbSetOrder(1))
			If SC6->(dbSeek(xFilial("SC6")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
				dbSelectArea("SX5")
				SX5->(dbSetOrder(1))
				If SC5->(dbSeek(xFilial("SC5")+SC6->C6_NUM)) .And. dbSeek(xFilial("SX5")+"60"+PadR(AllTrim((cAliasSF3)->F3_CODISS),6))
					cServ := _BuscaDescr(SC5->C5_NUM,(cAliasSF3)->F3_NFISCAL)
					cServ := AllTrim(SC5->C5_MENNOTA)+CHR(13)+CHR(10)+" | "+AllTrim(SubStr(SX5->X5_DESCRI,1,55))
				Endif
			Endif
		Else
			dbSelectArea("SX5")
			SX5->(dbSetOrder(1))
			If dbSeek(xFilial("SX5")+"60"+PadR(AllTrim((cAliasSF3)->F3_CODISS),6))
				cServ := AllTrim(SubStr(SX5->X5_DESCRI,1,55))
			Endif
		Endif

		If Empty(cServ)
			cServ := cCodServ
		Endif
				
		//Lei Transparência
		/*If !Empty(cTotImp)
			cServ+= +CHR(13)+CHR(10)+cTotImp+cFontImp
		EndIf*/
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para compor a descricao a ser apresentada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAreaRPS	:= (cAliasSF3)->(GetArea())
		cServPonto	:= ""
		If lDescrNFE
			cServPonto := Execblock("MTDESCRNFE",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
		Endif
		RestArea(aAreaRPS)
		If !(Empty(cServPonto))
			cServ := cServPonto
		Endif
		aPrintServ	:= M968Discri(cServ,10,1400)		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica o Cliente/Fornecedor do documento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCNPJCli := ""
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
			If RetPessoa(SA1->A1_CGC) == "F"
				cCNPJCli := Transform(SA1->A1_CGC,"@R 999.999.999-99")
			Else
				cCNPJCli := Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
			Endif
			cCli		:= SA1->A1_NOME
			cIMCli		:= SA1->A1_INSCRM
			cEndCli		:= SA1->A1_END
			cBairrCli	:= SA1->A1_BAIRRO
			cCepCli		:= SA1->A1_CEP
			cMunCli		:= SA1->A1_MUN
			cUFCli		:= SA1->A1_EST
			cEmailCli	:= SA1->A1_EMAIL
		Else
			(cAliasSF3)->(dbSKip())
			Loop
		Endif	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao que retorna o endereco do solicitante quando houver integracao com TMS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If IntTms()
			aTMS := TMSInfSol((cAliasSF3)->F3_FILIAL,(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE)
			If Len(aTMS) > 0
				cCli		:= aTMS[04]
				If RetPessoa(Alltrim(aTMS[01])) == "F"
					cCNPJCli := Transform(Alltrim(aTMS[01]),"@R 999.999.999-99")
				Else
					cCNPJCli := Transform(Alltrim(aTMS[01]),"@R 99.999.999/9999-99")
				Endif
				cIMCli		:= aTMS[02]
				cEndCli		:= aTMS[05]
				cBairrCli	:= aTMS[06]
				cCepCli		:= aTMS[09]
				cMunCli		:= aTMS[07]
				cUFCli		:= aTMS[08]
				cEmailCli	:= aTMS[10]
			Endif
		Endif		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para trocar o cliente a ser impresso.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCliNFE
			aMTCliNfe := Execblock("MTCLINFE",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
			// O ponto de entrada somente e utilizado caso retorne todas as informacoes necessarias
			If Len(aMTCliNfe) >= 12
				cCli		:= aMTCliNfe[01]
				cCNPJCli	:= aMTCliNfe[02]
				If RetPessoa(cCNPJCli) == "F"
					cCNPJCli := Transform(cCNPJCli,"@R 999.999.999-99")
				Else
					cCNPJCli := Transform(cCNPJCli,"@R 99.999.999/9999-99")
				Endif
				cIMCli		:= aMTCliNfe[03]
				cEndCli		:= aMTCliNfe[04]
				cBairrCli	:= aMTCliNfe[05]
				cCepCli		:= aMTCliNfe[06]
				cMunCli		:= aMTCliNfe[07]
				cUFCli		:= aMTCliNfe[08]
				cEmailCli	:= aMTCliNfe[09]
			Endif
		Endif

      cF3_NFISCAL := (cAliasSF3)->F3_NFISCAL
      cF3_SERIE   := (cAliasSF3)->F3_SERIE
      cF3_CLIEFOR := (cAliasSF3)->F3_CLIEFOR
      cF3_LOJA    := (cAliasSF3)->F3_LOJA
      cF3_EMISSAO := (cAliasSF3)->F3_EMISSAO
      _cNumNFSE   := Padl(StrZero(Year((cAliasSF3)->F3_EMISSAO),4)+"/"+(cAliasSF3)->F3_NFELETR,14)
	   nTOTAL   	+= (cAliasSF3)->F3_VALCONT
      nDEDUCAO 	+= (cAliasSF3)->F3_ISSSUB + Iif( lIssMat , (cAliasSF3)->F3_ISSMAT , 0 )
      nBASEISS 	+= (cAliasSF3)->F3_BASEICM
      nALIQISS 	:= (cAliasSF3)->F3_ALIQICM
      nVALISS		+= (cAliasSF3)->F3_VALICM
       
      cKey			:= (cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA

		(cAliasSF3)->(dbSkip())
		
		If  cKey <> (cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA .Or. ((cAliasSF3)->(Eof()))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Obtendo os Valores de PIS/COFINS/CSLL/IR/INSS da NF de saida                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SF2->(dbSetOrder(1))
			If SF2->(dbSeek(xFilial("SF2")+cKey))
				nValPis  := SF2->F2_VALPIS 
				nValCof  := SF2->F2_VALCOFI
				nValINSS := SF2->F2_VALINSS
				nValIR   := SF2->F2_VALIRRF
				nValCSLL := SF2->F2_VALCSLL 
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Obtendo as aliquotas de PIS/COFINS/CSLL/IR/INSS atraves da natureza da NF de saida       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SE1->(dbSetOrder(2))
			If SE1->(dbSeek(xFilial("SE1")+cF3_CLIEFOR+cF3_LOJA+cF3_SERIE+cF3_NFISCAL))
				While SE1->(!Eof()) .And. SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM == xFilial("SF3")+cF3_CLIEFOR+cF3_LOJA+cF3_SERIE+cF3_NFISCAL
					If SE1->E1_TIPO == MVNOTAFIS
						cNatureza := SE1->E1_NATUREZ
						Exit
					EndIf
					SE1->(dbSKip())
				EndDo				
				SED->(dbSetOrder(1))
				If SED->(dbSeek(xFilial("SDE")+cNatureza))
					nAliqPis  := Iif( nValPis  > 0 , Iif( SED->ED_PERCPIS > 0 , SED->ED_PERCPIS , SuperGetMv("MV_TXPIS"  )) , 0 )
					nAliqCof  := Iif( nValCof  > 0 , Iif( SED->ED_PERCCOF > 0 , SED->ED_PERCCOF , SuperGetMv("MV_TXCOFIN")) , 0 )
					nALiqINSS := Iif( nValINSS > 0 , SED->ED_PERCINS , 0 )
					nAliqIR   := Iif( nValIR   > 0 , Iif( SED->ED_PERCIRF > 0 , SED->ED_PERCIRF , SuperGetMV("MV_ALIQIRF")) , 0 )
					nALiqCSLL := Iif( nValCSLL > 0 , Iif( SED->ED_PERCCSL > 0 , SED->ED_PERCCSL , SuperGetMv("MV_TXCSLL" )) , 0 )
				EndIf
         Else
				nAliqPis  := Iif( nValPis  > 0 , SuperGetMv("MV_TXPIS"  ) , 0 )
				nAliqCof  := Iif( nValCof  > 0 , SuperGetMv("MV_TXCOFIN") , 0 )
				nAliqIR   := Iif( nValIR   > 0 , SuperGetMV("MV_ALIQIRF") , 0 )
				nALiqCSLL := Iif( nValCSLL > 0 , SuperGetMv("MV_TXCSLL" ) , 0 )
			EndIf

         aItensSD2 := {}
			SD2->(dbSetOrder(3))
			SB1->(dbSetOrder(1))
			If SD2->(dbSeek(xFilial("SD2")+cKey))
				Do While SD2->(!Eof()) .And. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == xFilial("SD2")+cKey                      
					SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD))	
               aAdd(aItensSD2,{SD2->D2_ITEM,SB1->B1_DESC,SD2->D2_QUANT,SD2->D2_PRCVEN,SD2->D2_TOTAL})  
					SD2->(dbSkip())
            EndDo
			Endif
			
			ASort(aItensSD2,,,{|x,y| x[1]  < y[1] })

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Relatorio Grafico:                                                                                      ³
			//³* Todas as coordenadas sao em pixels	                                                                   ³
			//³* oPrint:Line - (linha inicial, coluna inicial, linha final, coluna final)Imprime linha nas coordenadas ³
			//³* oPrint:Say(Linha,Coluna,Valor,Picture,Objeto com a fonte escolhida)		                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX := 1 to nCopias
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ SESSAO - CABECALHO DO RPS - LOGOTIPO - NUMERO E EMISSAO                                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oPrint:SayBitmap(0110,0170, GetSrvProfString("Startpath","")+"SOROCABA.BMP" ,2350,1800) // o arquivo com o logo deve estar abaixo do rootpath (mp10\system)
				PrintBox( 0080,0080,3350,2330)
				PrintLine(0220,1850,0220,2330)
				PrintLine(0080,1850,0360,1850)     
				PrintBox( 0080,0080,3350,2330)
				oPrint:Say(0120,0850,"Prefeitura de Sorocaba",oFontA13n)
				oPrint:Say(0180,0850,"Secretaria de Finanças",oFontA13n)
				oPrint:Say(0250,0500,"NOTA FISCAL DE SERVIÇOS ELETRÔNICA",oFontA16n)
				oPrint:Say(0100,1860,"Número/Prefeit.",oFontA10)                                                                      
			   	oPrint:Say(0160,1950,Padl(StrZero(Year((cAliasSF3)->F3_EMISSAO),4)+"/"+(cAliasSF3)->F3_NFELETR,14),oFontA10n)
//				oPrint:Say(2440,370,(cAliasSF3)->F3_DOC+"/"+(cAliasSF3)->F3_SERIE,oFontA10n)
				oPrint:Say(0235,1860,"Data de Emissão",oFontA10)
				oPrint:Say(0300,1950,PadC(cF3_EMISSAO,15),oFontA10n)				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ SESSAO - PRESTADOR DE SERVICOS                                                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PrintLine(0360,0080,0360,2330)
				oPrint:Say(0370,0965,"PRESTADOR DE SERVIÇOS",oFontA10n)
				oPrint:Say(0410,0100,"Nome/Razão Social:",oFontA08)
				oPrint:Say(0410,0370,PadR(Alltrim(SM0->M0_NOMECOM),40),oFontA08n)
				oPrint:Say(0455,0100,"CNPJ:",oFontA08)
				oPrint:Say(0455,1640,"Inscrição Mobiliária: ",oFontA08)
				oPrint:Say(0455,0265,PadR(Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),50),oFontA08n)
				oPrint:Say(0455,1950,PadR(Alltrim(SM0->M0_INSCM),50),oFontA08n)
				oPrint:Say(0505,0100,"Endereço: ",oFontA08)
				oPrint:Say(0505,0265,PadR(Alltrim(SM0->M0_ENDENT),50) + " - Bairro: " + PadR(Alltrim(Alltrim(SM0->M0_BAIRENT) + " - CEP: " + Transform(SM0->M0_CEPENT,"@R 99999-999")),50) ,oFontA08n)
				oPrint:Say(0555,0100,"Município: ",oFontA08)
				oPrint:Say(0555,1050,"UF: ",oFontA08)
				oPrint:Say(0555,0265,PadR(Alltrim(SM0->M0_CIDENT),50),oFontA08n)
				oPrint:Say(0555,1120,PadR(Alltrim(SM0->M0_ESTENT),50),oFontA08n)				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ SESSAO - TOMADOR DE SERVICOS                                                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PrintLine(0600,0080,0600,2330)
				oPrint:Say(0610,0990,"TOMADOR DE SERVIÇOS",oFontA10n)
				oPrint:Say(0650,0100,"Nome/Razão Social:",oFontA08)
				oPrint:Say(0650,0370,PadR(Alltrim(cCli),40),oFontA08n)
				oPrint:Say(0695,0100,"CNPJ/CPF:",oFontA08)
				oPrint:Say(0695,0265,PadR(cCNPJCli,50),oFontA08n)
				oPrint:Say(0745,0100,"Endereço: ",oFontA08)
				oPrint:Say(0745,0265,PadR(Alltrim(cEndCli),50) + " - Bairro: " + PadR(Alltrim(Alltrim(cBairrCli) + " - CEP: " + Transform(cCepCli,"@R 99999-999")),50) ,oFontA08n)
				oPrint:Say(0795,0100,"Município: ",oFontA08)
				oPrint:Say(0795,1050,"UF: ",oFontA08)
				oPrint:Say(0795,1250,"E-mail: ",oFontA08)
				oPrint:Say(0795,0265,PadR(Alltrim(cMunCli),50),oFontA08n)
				oPrint:Say(0795,1120,PadR(Alltrim(cUFCli),50),oFontA08n)
				oPrint:Say(0795,1350,PadR(Alltrim(cEmailCli),50),oFontA08n)				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ SESSAO - DESCRIMINACAO DOS SERVICOS                                                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PrintLine(0845,0080,0845,2330)
				oPrint:Say(0855,0940,"DISCRIMINAÇÃO DOS SERVIÇOS",oFontA10n)
				PrintLine(0905,0080,0905,2330)
				oPrint:Say(0915,0100,"Descrição:",oFontA08)				
				nLinha	:= 0950
				For nY := 1 to Len(aPrintServ)
					If nY > 10
						Exit
					Endif
					oPrint:Say(nLinha,0100,Alltrim(aPrintServ[nY]),oFontA08)
					nLinha 	:= nLinha + 39
				Next nY				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ SESSAO - ITENS DO RPS 25 ITEMS POR RPS SEGUNDO O WEB-SERVICES DA NFS-E                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PrintLine(1335,0080,1335,2330)
				PrintLine(1335,1450,2645,1450)
				PrintLine(1335,1640,2645,1640)
				PrintLine(1335,1950,2645,1950)
				oPrint:Say(1345,0100,"Item",oFontA08)
				oPrint:Say(1345,1470,"Quantidade",oFontA08)
				oPrint:Say(1345,1660,"Valor Unitário",oFontA08)
				oPrint:Say(1345,1970,"Valor Total",oFontA08)
				nLinha	:= 1390    
            For nY := 1 to Len(aItensSD2)
					If nY > 25
						Exit
					Endif
					oPrint:Say(nLinha,0100,PadR(aItensSD2[nY][01] + "    " + aItensSD2[nY][02],100),oFontA09)
					oPrint:Say(nLinha,1470,Transform(aItensSD2[nY][03], PesqPict("SD2","D2_QUANT" )),oFontA09)
					oPrint:Say(nLinha,1710,Transform(aItensSD2[nY][04], PesqPict("SD2","D2_PRCVEN")),oFontA09)
					oPrint:Say(nLinha,2020,Transform(aItensSD2[nY][05], PesqPict("SD2","D2_TOTAL" )),oFontA09)		
					nLinha 	:= nLinha + 45
				Next nY
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ SESSAO - PIS / COFINS / INSS / IR / CSLL                                                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PrintLine(2645,0080,2645,2330)
				PrintLine(2645,0530,2765,0530)
				PrintLine(2645,0980,2765,0980)
				PrintLine(2645,1430,2765,1430)
				PrintLine(2645,1880,2765,1880)
				oPrint:Say(2665,0210,"PIS("   +Transform(nAliqPis, "@E 99.99") +"%):" ,oFontA09)
				oPrint:Say(2665,0640,"COFINS("+Transform(nAliqCof, "@E 99.99") +"%):" ,oFontA09)
				oPrint:Say(2665,1090,"INSS("  +Transform(nAliqINSS,"@E 99.99") +"%):" ,oFontA09)
				oPrint:Say(2665,1580,"IR("    +Transform(nAliqIR  ,"@E 99.99") +"%):" ,oFontA09)
				oPrint:Say(2665,2000,"CSLL("  +Transform(nAliqCSLL,"@E 99.99") +"%):" ,oFontA09)

				oPrint:Say(2710,0230,"R$ " + Transform(nValPis ,PesqPict("SF3","F3_VALICM")),oFontA10n) 
				oPrint:Say(2710,0675,"R$ " + Transform(nValCof ,PesqPict("SF3","F3_VALICM")),oFontA10n) 
				oPrint:Say(2710,1125,"R$ " + Transform(nValINSS,PesqPict("SF3","F3_VALICM")),oFontA10n) 
				oPrint:Say(2710,1575,"R$ " + Transform(nValIR  ,PesqPict("SF3","F3_VALICM")),oFontA10n) 
				oPrint:Say(2710,2020,"R$ " + Transform(nValCSLL,PesqPict("SF3","F3_VALICM")),oFontA10n) 
								
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ SESSAO - VALOR TOTAL DO RPS                                                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PrintLine(2765,0080,2765,2330)
				oPrint:Say(2785,0950,"VALOR TOTAL DO RPS =",oFontA11n)
				oPrint:Say(2785,1950,"R$ " + Transform(nTOTAL,PesqPict("SF3","F3_VALCONT")),oFontA11n)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ SESSAO - RODAPE - VALOR TODAL DE DEDUCOES - BASE DE CALCULO - ALIQUOTA - VALOR DO ISS                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PrintLine(2855,0080,2855,2330)
				PrintLine(2855,0642,2980,0642)
				PrintLine(2855,1204,2980,1204)
				PrintLine(2855,1766,2980,1766)
 				
				oPrint:Say(2865,0100,"VL. Total Deduções:",oFontA09)
				oPrint:Say(2865,0662,"Base de Cálculo:"   ,oFontA09)
				oPrint:Say(2865,1224,"Alíquota:"          ,oFontA09)
				oPrint:Say(2865,1786,"Valor do ISS:"      ,oFontA09)
				
				oPrint:Say(2920,0360,"R$ " + Transform(nDEDUCAO,PesqPict("SF3","F3_BASEICM")),oFontA10n)
				oPrint:Say(2920,0890,"R$ " + Transform(nBASEISS,PesqPict("SF3","F3_BASEICM")),oFontA10n)
				oPrint:Say(2920,1640,Transform(nALIQISS,PesqPict("SF3","F3_ALIQICM"))+"%",oFontA10n)
				oPrint:Say(2920,2020,"R$ " + Transform(nVALISS ,PesqPict("SF3","F3_VALICM" )),oFontA10n)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ SESSAO - INFORMACOES IMPORTANTES                                                                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PrintLine(2980,0080,2980,2330)
				oPrint:Say(2990,0920,"INFORMAÇÕES IMPORTANTES",oFontA10n)
				oPrint:Say(3035,0100,"É possível consultar a autenticidade desta nota no site da prefeitura",oFontA08)
			//	oPrint:Say(3075,0100,"substituí-lo por uma Nota Fiscal de Serviços Eletrônica.",oFontA08)               
				oPrint:Say(3075,0100,"* Valores para Alíquota e Valor de ISSQN serão calculados de acordo com o movimento econômico com base na tabela de faixa de faturamento.",oFontA08)
			   //	oPrint:Say(3170,0100,"* Valores para Alíquota e Valor de ISSQN serão calculados de acordo com o movimento econômico com base na tabela de faixa de faturamento.",oFontA08)
				
				If nCopias > 1 .And. nX < nCopias
					oPrint:EndPage()
				Endif

			Next nX
            
			cCodServ := ""
            cServ    := "" 
            nTotal   := 0
	        nDeducao := 0
	        nBaseISS := 0
	        nValISS  := 0

		EndIf

		If !((cAliasSF3)->(Eof()))
			oPrint:EndPage()
		Endif		
	Enddo	
Else	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime os RPS gerados de acordo com o numero de copias selecionadas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While (cAliasSF3)->(!Eof())		
		ProcRegua(LastRec())
		
	
		If Interrupcao(@lEnd)
			Exit
		Endif		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Analisa Deducoes do ISS  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nValDed := (cAliasSF3)->F3_ISSSUB		
		If lIssMat
			nValDed += (cAliasSF3)->F3_ISSMAT
		Endif	
           
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valor contabil ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      nVlContab := (cAliasSF3)->F3_VALCONT		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca o SF2 para verificar o horario de emissao do documento e Lei da Transparência³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SF2->(dbSetOrder(1))
		cTime   := ""
		cTotImp := ""
		cFontImp:= ""
		
		If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
			cTime := Transform(SF2->F2_HORA,"@R 99:99")			
			/*Comentado Michel Aoki - Descomentar futuramente, pois este é o standard
			//Lei Transparência - 12.741
			cTotImp := Iif(SF2->(FieldPos("F2_TOTIMP"))>0 .And. SF2->F2_TOTIMP > 0,"Valor Aproximado dos Tributos: R$ "+Alltrim(Transform(SF2->F2_TOTIMP,"@E 999,999,999,999.99")+"."),"")
			
			//Busca a fonte da Carga Tributária - Lei Transparência - 12.741
			SB1->(dbSetOrder(1))  
		 	SD2->(dbSetOrder(3))
	     	If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
			   If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
			   		cFontImp:= Iif(!Empty(cTotImp) .And. "IBPT" $ AlqLeiTran("SB1","SBZ")[2],"Fonte: "+AlqLeiTran("SB1","SBZ")[2],"")
			   EndIf
			EndIf
			*/
			// NF Cupom nao sera processada
			If !Empty(SF2->F2_NFCUPOM)
				(cAliasSF3)->(dbSKip())
				Loop
			Endif
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para verificar se esse RPS deve ser impresso ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAreaRPS := (cAliasSF3)->(GetArea())
		lImpRPS	 := .T.
		If lPEImpRPS
			lImpRPS := Execblock("MTIMPRPS",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
		Endif
		RestArea(aAreaRPS)
		
		If !lImpRPS
			(cAliasSF3)->(dbSKip())
			Loop
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca a descricao do codigo de servicos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cDescrServ := ""
		SX5->(dbSetOrder(1))
		If SX5->(dbSeek(xFilial("SX5")+"60"+(cAliasSF3)->F3_CODISS))
			cDescrServ := SX5->X5_DESCRI
		Endif
//		If lDescrBar 
			SF2->(dbSetOrder(1))
			SD2->(dbSetOrder(3))
			SB1->(dbSetOrder(1))
			If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
				If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
					If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
						cTotImp := _Transparencia(Alltrim(SB1->B1_DESC),SD2->D2_TOTAL)//Lei da Transparência Michel Aoki
					Endif
				Endif
			Endif
		//Endif 
	
		If lRecife
			cCodAtiv := Alltrim((cAliasSF3)->F3_CNAE)
		Else
			cCodServ := Alltrim((cAliasSF3)->F3_CODISS) + " - " + cDescrServ
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca o pedido para discriminar os servicos prestados no documento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cServ := ""
		If lNfeServ
			SC6->(dbSetOrder(4))
			SC5->(dbSetOrder(1))
			If SC6->(dbSeek(xFilial("SC6")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
				dbSelectArea("SX5")
				SX5->(dbSetOrder(1))
				If SC5->(dbSeek(xFilial("SC5")+SC6->C6_NUM)) .And. dbSeek(xFilial("SX5")+"60"+PadR(AllTrim((cAliasSF3)->F3_CODISS),6))
					cServ := AllTrim(SC5->C5_MENNOTA)+CHR(13)+CHR(10)+" | "+AllTrim(SubStr(SX5->X5_DESCRI,1,55))
				Endif
			Endif
		Else
		
			SC6->(dbSetOrder(4))
			SC5->(dbSetOrder(1))
			If SC6->(dbSeek(xFilial("SC6")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
				dbSelectArea("SX5")
				SX5->(dbSetOrder(1))
				If SC5->(dbSeek(xFilial("SC5")+SC6->C6_NUM)) .And. dbSeek(xFilial("SX5")+"60"+PadR(AllTrim((cAliasSF3)->F3_CODISS),6))
					cServ := _BuscaDescr(SC5->C5_NUM,(cAliasSF3)->F3_NFISCAL)
				Endif
			Endif
			
		Endif        
		
		
		
		If Empty(cServ)
			cServ := cDescrServ
		Endif
		
		//Lei Transparência
		/*If !Empty(cTotImp) Michel Aoki
			cServ+= +CHR(13)+CHR(10)+cTotImp+cFontImp
		EndIf
		  */
		
		//Adicionado Michel aoki - Observação Automatech
		SC6->(dbSetOrder(4))
		SC5->(dbSetOrder(1))
		If SC6->(dbSeek(xFilial("SC6")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
				_cObsAuto := _ObsPv(SC6->C6_NUM)
		Endif
		//>>>>>>>>>>>>>>>>>>>>>>>>	
		
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para compor a descricao a ser apresentada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAreaRPS	:= (cAliasSF3)->(GetArea())
		cServPonto	:= ""
		If lDescrNFE
			cServPonto := Execblock("MTDESCRNFE",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
		Endif
		RestArea(aAreaRPS)
		If !(Empty(cServPonto))
			cServ := cServPonto
		Endif
		aPrintServ	:= Mtr968Mont(cServ,13,999)
		
		If lRioJaneiro
         cObsRio := ""
         nDescIncond := 0                         
			SF2->(dbSetOrder(1))
			SD2->(dbSetOrder(3))
			If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
				If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
		         SF4->(DbSetOrder(1))		
					If SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
		            If SF2->F2_DESCONT > 0
		               If SF4->F4_DESCOND == "1"  
		                  cObsRio := " Deconto Condic. de (R$) " 
		                  cObsRio += Alltrim(Transform(SF2->F2_DESCONT,"@ze 9,999,999,999,999.99")) 
		               Else
		                  nDescIncond := SF2->F2_DESCONT                  
		               EndIf
		            EndIf
		    		EndIf
				Endif
			Endif            
		Endif
		cObserv 	:= Alltrim((cAliasSF3)->F3_OBSERV) + Iif(!Empty((cAliasSF3)->F3_OBSERV)," | ","")
		cObserv 	+= Iif(!Empty((cAliasSF3)->F3_PDV) .And. Alltrim((cAliasSF3)->F3_ESPECIE) == "CF",STR0042 + " | ","")
	    If lRioJaneiro
		    cObsRio     += "'Obrigatória a conversão em Nota Fiscal de Serviços Eletrônica – NFS-e – NOTA CARIOCA em até vinte dias.'" + " | "
		EndIf
		aAreaRPS 	:= (cAliasSF3)->(GetArea())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para complementar as observacoes a serem apresentadas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cObsPonto	:= ""
		cObsPonto	:= _cObsAuto//Adicionado Michel Aoki
		
		/*If lObsNFE Comentado Michel aoki
			cObsPonto := Execblock("MTOBSNFE",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
		Endif */
		RestArea(aAreaRPS)
		cObserv 	:= _cObsAuto//cObserv + cObsPonto
		cObserv 	:= cObserv + cObsRio
		aPrintObs	:= Mtr968Mont(cObserv,11,675)		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica o cLiente/fornecedor do documento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCNPJCli := ""
		cRecIss  := ""
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
			If RetPessoa(SA1->A1_CGC) == "F"
				cCNPJCli := Transform(SA1->A1_CGC,"@R 999.999.999-99")
			Else
				cCNPJCli := Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
			Endif
			cCli			:= SA1->A1_NOME
			cIMCli		:= SA1->A1_INSCRM
			cEndCli		:= SA1->A1_END
			cBairrCli	:= SA1->A1_BAIRRO
			cCepCli		:= SA1->A1_CEP
			cMunCli		:= SA1->A1_MUN
			cUFCli		:= SA1->A1_EST
			cEmailCli	:= SA1->A1_EMAIL
			cRecIss     := SA1->A1_RECISS
			cRecCof     := SA1->A1_RECCOFI
			cRecPis     := SA1->A1_RECPIS
			cRecIR      := SA1->A1_RECIRRF    
			cRecCsl     := SA1->A1_RECCSLL         
			cRecIns     := SA1->A1_RECINSS
		Else
			(cAliasSF3)->(dbSKip())
			Loop
		Endif		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao que retorna o endereco do solicitante quando houver integracao com TMS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If IntTms()
			aTMS := TMSInfSol((cAliasSF3)->F3_FILIAL,(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE)
			If Len(aTMS) > 0
				cCli		:= aTMS[04]
				If RetPessoa(Alltrim(aTMS[01])) == "F"
					cCNPJCli := Transform(Alltrim(aTMS[01]),"@R 999.999.999-99")
				Else
					cCNPJCli := Transform(Alltrim(aTMS[01]),"@R 99.999.999/9999-99")
				Endif
				cIMCli		:= aTMS[02]
				cEndCli		:= aTMS[05]
				cBairrCli	:= aTMS[06]
				cCepCli		:= aTMS[09]
				cMunCli		:= aTMS[07]
				cUFCli		:= aTMS[08]
				cEmailCli	:= aTMS[10]
			Endif
		Endif		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada para trocar o cliente a ser impresso.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCliNFE
			aMTCliNfe := Execblock("MTCLINFE",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
			// O ponto de entrada somente e utilizado caso retorne todas as informacoes necessarias
			If Len(aMTCliNfe) >= 12
				cCli		:= aMTCliNfe[01]
				cCNPJCli	:= aMTCliNfe[02]
				If RetPessoa(cCNPJCli) == "F"
					cCNPJCli := Transform(cCNPJCli,"@R 999.999.999-99")
				Else
					cCNPJCli := Transform(cCNPJCli,"@R 99.999.999/9999-99")
				Endif
				cIMCli		:= aMTCliNfe[03]
				cEndCli		:= aMTCliNfe[04]
				cBairrCli	:= aMTCliNfe[05]
				cCepCli		:= aMTCliNfe[06]
				cMunCli		:= aMTCliNfe[07]
				cUFCli		:= aMTCliNfe[08]
				cEmailCli	:= aMTCliNfe[09]
			Endif
		Endif

		lBhorizonte := .T. // Jean Rehermann - Solutio IT - 28/05/2015 - Forço a entrada neste trecho para calcular os impostos
		
		If lBhorizonte                        
			nValDed     := 0
			nValDesc    := 0
			nDescIncond := 0
			nValLiq     := 0
			nVALISS     := 0
			nValPis     := 0
			nValCof     := 0
			nValCSLL    := 0
			nValIR      := 0
			nValINSS	:= 0
								
			nValDed := Iif( (cAliasSF3)->F3_RECISS == "1", (cAliasSF3)->F3_VALICM, 0 )
			cRecIss := (cAliasSF3)->F3_RECISS // Caso cliente tenha sido alterado após emissão da nota, tenho que considerar o que está na nota
			
			SF2->(dbSetOrder(1))
			SD2->(dbSetOrder(3))
			If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
				If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
					While SD2->(!Eof()) .And. xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA==xFilial("SD2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
						If Alltrim(SD2->D2_CODISS) == Alltrim((cAliasSF3)->F3_CODISS) 
							SF4->(DbSetOrder(1))		
							If SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
								nValLiq		+= SD2->D2_TOTAL
								nVALISS		+= Iif(SD2->(FieldPos("D2_VALISS")) > 0,SD2->D2_VALISS, 0) 
								nValPis		:= Iif(SD2->(FieldPos("D2_VALPIS")) > 0,SD2->D2_VALPIS, 0) 
								nValCof		:= Iif(SD2->(FieldPos("D2_VALCOF")) > 0,SD2->D2_VALCOF, 0) 
								nValCSLL	:= Iif(SD2->(FieldPos("D2_VALCSL")) > 0,SD2->D2_VALCSL, 0) 
								nValIR		:= Iif(SD2->(FieldPos("D2_VALIRRF")) > 0,SD2->D2_VALIRRF, 0)
								nValINSS	:= Iif(SD2->(FieldPos("D2_VALINS")) > 0,SD2->D2_VALINS, 0)

								nValDesc	:= SD2->D2_DESCON

								If SF4->F4_DESCOND <> "1"  
									nDescIncond := nValDesc
								EndIf

								If SF4->F4_AGREG == "D"
									nValDesc += SD2->D2_DESCICM
									nValLiq -= SD2->D2_DESCICM
									//nVlContab := nVlContab + SD2->D2_DESCICM
								Endif
							EndIf
						Endif
						SD2->(dbSkip())
					Enddo 
				Endif 
			EndIf
			nRetFeder   := 0
	        If cRecIss == "1"
            	nValLiq := nValLiq - nValISS
	        EndIf
         	If cRecCof == "S"
            	nValLiq    := nValLiq - nValCof
			   	nRetFeder  := nRetFeder + nValCof
			EndIf
         	If cRecPis == "S"
            	nValLiq := nValLiq - nValPis     
            	nRetFeder  := nRetFeder + nValPis
			EndIf
         	If cRecCsl == "S"
            	nValLiq := nValLiq - nValCsll
            	nRetFeder  := nRetFeder + nValCsll
			EndIf
         	If cRecIr == "1"
            	nValLiq := nValLiq - nValIR    
            	nRetFeder  := nRetFeder + nValIR
			Endif            
			If cRecIns == "S"
				nValLiq := nValLiq - nValINSS
				nRetFeder  := nRetFeder + nValINSS
			EndIf

			lBhorizonte := .F. // Jean Rehermann - Solutio IT - 28/05/2015 - Retorno o Flag para o original após o cálculo dos impostos
		Endif
		
		If lJoinville
			SF2->(dbSetOrder(1))
			SB1->(dbSetOrder(1))
			SD2->(dbSetOrder(3))
			If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->(F3_NFISCAL+F3_SERIE)))
				If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
					If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
						nValBase	:= Iif (Empty((cAliasSF3)->F3_BASEICM),(cAliasSF3)->F3_ISENICM,(cAliasSF3)->F3_BASEICM)
						nAliquota	:= SB1->B1_ALIQISS
					Endif
				EndIf
			EndIf
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Relatorio Grafico:                                                                                      ³
		//³* Todas as coordenadas sao em pixels	                                                                   ³
		//³* oPrint:Line - (linha inicial, coluna inicial, linha final, coluna final)Imprime linha nas coordenadas ³
		//³* oPrint:Say(Linha,Coluna,Valor,Picture,Objeto com a fonte escolhida)		                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 to nCopias
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Box no tamanho do RPS³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oPrint:Line(nLinIni,nColIni,nLinIni,nColFim)
			oPrint:Line(nLinIni,nColIni,nLinFim,nColIni)
			oPrint:Line(nLinIni,nColFim,nLinFim,nColFim)
			oPrint:Line(nLinFim,nColIni,nLinFim,nColFim)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Título do Documento  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oPrint:Say(160,740,"NOTA FISCAL DE SERVIÇOS ELETRÔNICA",oFont12n)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Dados da empresa emitente do documento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
   			If Empty(cLogAlter)   			
   			    cLogo := GetSrvProfString("Startpath","") + cEmpAnt +"logo_nfse.bmp" //FisxLogo("1")
    		Else
    		    cLogo := cLogAlter
    		EndIf
    		// o arquivo com o logo deve estar abaixo do rootpath (mp8\system)
    		oPrint:SayBitmap(280,nColIni+10,cLogo,350,340) 
			oPrint:Line(nLinIni,1800,612,1800)
			oPrint:Line(354,1800,354,nColFim)
			oPrint:Line(483,1800,483,nColFim)
			oPrint:Line(612,nColIni,612,nColFim)
			oPrint:Say(245,730,PadC(Alltrim(SM0->M0_NOMECOM),40),oFont12n)
			oPrint:Say(305,680,PadC(Alltrim(SM0->M0_ENDENT),50),oFont10)
			oPrint:Say(355,680,PadC(Alltrim(Alltrim(SM0->M0_BAIRENT) + " - " + Transform(SM0->M0_CEPENT,"@R 99999-999")),50),oFont10)
			oPrint:Say(405,680,PadC(Alltrim(SM0->M0_CIDENT) + " - " + Alltrim(SM0->M0_ESTENT),50),oFont10)
			oPrint:Say(455,680,PadC(Alltrim(STR0013) + Alltrim(SM0->M0_TEL),50),oFont10) // Telefone:
			oPrint:Say(505,680,PadC(Alltrim(STR0014) + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),50),oFont10) // C.N.P.J.::
			oPrint:Say(555,680,PadC(Alltrim(STR0015) + Alltrim(SM0->M0_INSCM),50),oFont10) // I.M.:
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Informacoes sobre a emissao do RPS³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oPrint:Say(250,1830,"Número/Prefeit.",oFont10n) // "Número/Série RPS"
		   //	oPrint:Say(295,1830,PadC(Alltrim(Alltrim((cAliasSF3)->F3_NFISCAL) + Iif(!Empty((cAliasSF3)->F3_SERIE)," / " + Alltrim((cAliasSF3)->F3_SERIE),"")),15),oFont10)
		    oPrint:Say(295,1830,Padl(StrZero(Year((cAliasSF3)->F3_EMISSAO),4)+"/"+(cAliasSF3)->F3_NFELETR,14),oFont10) 
			oPrint:Say(375,1830,PadC(Alltrim(STR0017),15),oFont10n) // "Data Emissão"
			oPrint:Say(420,1830,PadC((cAliasSF3)->F3_EMISSAO,15),oFont10)
			oPrint:Say(510,1830,PadC(Alltrim(STR0018),15),oFont10n) // "Hora Emissão"
			oPrint:Say(555,1830,PadC(Alltrim(cTime),15),oFont10)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Dados do destinatario³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oPrint:Say(625,nColIni,PadC(Alltrim(STR0019),75),oFont12n) // "DADOS DO DESTINATÁRIO"
			oPrint:Say(685,250,STR0020,oFont10n) // "Nome/Razão Social:"
			oPrint:Say(745,250,STR0021,oFont10n) // "C.P.F./C.N.P.J.:"
			oPrint:Say(805,250,STR0022,oFont10n) // "Inscrição Municipal:"
			oPrint:Say(865,250,STR0024,oFont10n) // "Endereço:"
			oPrint:Say(925,250,STR0025,oFont10n) // "CEP:"
			oPrint:Say(985,250,STR0026,oFont10n) // "Município:"
			oPrint:Say(985,1800,STR0028,oFont10n) // "UF:"
			oPrint:Say(1045,250,STR0027,oFont10n) // "E-mail:"
			oPrint:Say(685,750,Alltrim(cCli),oFont10)
			oPrint:Say(745,750,Alltrim(cCNPJCli),oFont10)
			oPrint:Say(805,750,Alltrim(cIMCli),oFont10)
			oPrint:Say(865,750,Alltrim(cEndCli) + " - " + Alltrim(cBairrCli) ,oFont10)
			oPrint:Say(925,750,Transform(cCepCli,"@R 99999-999"),oFont10)
			oPrint:Say(985,750,Alltrim(cMunCli),oFont10)
			oPrint:Say(985,1900,Alltrim(cUFCli),oFont10)
			oPrint:Say(1045,750,Alltrim(cEmailCli),oFont10)
			oPrint:Line(1105,nColIni,1105,nColFim)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Discriminacao dos Servicos ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oPrint:Say(1118,nColIni,PadC(Alltrim(STR0029),75),oFont12n) // "DISCRIMINAÇÃO DOS SERVIÇOS"
			nLinha	:= 1178
			For nY := 1 to Len(aPrintServ)
				If nY > 7  // Jean Rehermann - Solutio IT - 28/05/2015 - Alterei de 15 para 7 linhas para apresentar os impostos retidos
					Exit
				Endif
				oPrint:Say(nLinha,250,Alltrim(aPrintServ[nY]),oFont10)
				nLinha 	:= nLinha + 45
			Next                        

			// Jean Rehermann - Solutio IT - Impressão das linhas das retenções
			nLinha := 1538
			cPictRet := PesqPict("SF3","F3_VALICM")
			
		    oPrint:Say(nLinha,250,Alltrim("ISS Ret.: "),oFont09n)
	    	oPrint:Say(nLinha,920,Transform( Iif( nValISS > 0 .And. cRecIss == "1", nValISS, 0 ) , cPictRet ),oFont09)
	    	nLinha += 45
			oPrint:Say(nLinha,250,"PIS:" ,oFont09n)
			oPrint:Say(nLinha,920,Transform( Iif( nValPis > 0 .And. cRecPis == "S", nValPis, 0 ) , cPictRet ),oFont09) 
	    	nLinha += 45
			oPrint:Say(nLinha,250,"COFINS:" ,oFont09n)
			oPrint:Say(nLinha,920,Transform( Iif( nValCof > 0 .And. cRecCof == "S", nValCof, 0 ) , cPictRet ),oFont09) 
	    	nLinha += 45
			oPrint:Say(nLinha,250,"CSLL:" ,oFont09n)
			oPrint:Say(nLinha,920,Transform( Iif( nValCSLL > 0 .And. cRecCsl == "S", nValCSLL, 0 ) , cPictRet ),oFont09) 
	    	nLinha += 45
			oPrint:Say(nLinha,250,"IR Ret.:" ,oFont09n)
			oPrint:Say(nLinha,920,Transform( Iif( nValIR > 0 .And. cRecIr == "1", nValIR, 0 ) , cPictRet ),oFont09) 
	    	nLinha += 45
			oPrint:Say(nLinha,250,"INSS Ret.:" ,oFont09n)
			oPrint:Say(nLinha,920,Transform( Iif( nValINSS > 0 .And. cRecIns == "S", nValINSS, 0 ) , cPictRet ),oFont09)
	    	nLinha += 45

// Fim


            oPrint:Line(1850,nColIni,1850,nColFim)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valores da prestacao de servicos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lBhorizonte
			    oPrint:Say(1880,nColIni,PadC(Alltrim(STR0030),50),oFont12n) // "VALOR TOTAL DA PRESTAÇÃO DE SERVIÇOS"
			    //oPrint:Say(1885,1700,"R$ " + Transform(nVlContab,"@E 999,999,999.99"),oFont10)
			    oPrint:Say(1885,1700,"R$ " + Transform(nValLiq,"@E 999,999,999.99"),oFont10)
			    oPrint:Line(1950,nColIni,1950,nColFim)
			EndIf 
			
			If lRecife
				oPrint:Say(1965,250,Alltrim(STR0043),oFont10n) // "Código do Serviço"
				oPrint:Say(2005,250,Alltrim(cCodAtiv),oFont10)
			ElseIf lBhorizonte
				oPrint:Say(1865,250,Alltrim(STR0043),oFont10n) // "Código do Serviço"
				oPrint:Say(1865,950,Alltrim(cCodServ),oFont10)			
			Else
				oPrint:Say(1965,250,Alltrim(STR0031),oFont10n) // "Código do Serviço"
				oPrint:Say(2005,250,Alltrim(cCodServ),oFont10)
			EndIf
			If lBhorizonte
			    oPrint:Line(1925,nColIni,1925,nColFim)
			Else
			    oPrint:Line(2050,nColIni,2050,nColFim)
			EndIf   
			
			If lRioJaneiro
    			oPrint:Line(2050,632,2150,632)
	    		oPrint:Line(2050,979,2150,979)
		    	oPrint:Line(2050,1446,2150,1446)    
		    	oPrint:Line(2050,1736,2150,1736)    
                
			    oPrint:Say(2065,250,Alltrim(STR0032),oFont09n) // "Total deduções (R$)"
		    	oPrint:Say(2105,320,Transform(nValDed,"@E 999,999,999.99"),oFont09)        
			    
			    oPrint:Say(2065,647,Alltrim(STR0044),oFont09n) // "Desc.Incond. (R$)"
			    oPrint:Say(2105,667,Transform(nDescIncond,"@E 999,999,999.99"),oFont09)
			    
			    oPrint:Say(2065,1014,Alltrim(STR0033),oFont09n) // "Base de cálculo (R$)"
			    oPrint:Say(2105,1134,Transform((cAliasSF3)->F3_BASEICM,"@E 999,999,999.99"),oFont09)
			    
			    oPrint:Say(2065,1484,Alltrim(STR0034),oFont09n) // "Alíquota (%)"
			    oPrint:Say(2105,1584,Transform((cAliasSF3)->F3_ALIQICM,"@E 999.99"),oFont09)
			    
			    oPrint:Say(2065,1791,Alltrim(STR0035),oFont09n) // "Valor do ISS (R$)"
			    oPrint:Say(2105,1881,Transform((cAliasSF3)->F3_VALICM,"@E 999,999,999.99"),oFont09)
			    
			    oPrint:Line(2150,nColIni,2150,nColFim)
		
			ElseIf lBhorizonte 
			    oPrint:Say(1950,250,Alltrim("Valor dos serviços: "),oFont09n) // "Valor dos serviços"
		    	oPrint:Say(1950,920,Transform(nVlContab,"@E 999,999,999.99"),oFont09)        
    			oPrint:Say(1950,1250,Alltrim("Valor dos serviços: "),oFont09n) // "Valor dos serviços"
		    	oPrint:Say(1950,1870,Transform(nVlContab,"@E 999,999,999.99"),oFont09)        
			    oPrint:Say(2000,250,Alltrim("(-)Descontos: "),oFont09n) // "Descontos"
		    	oPrint:Say(2000,920,Transform(nValDesc,"@E 999,999,999.99"),oFont09)        
    			oPrint:Say(2000,1250,Alltrim("(-)Deduçoes: "),oFont09n) // "Deduções"
		    	oPrint:Say(2000,1870,Transform(nValDed,"@E 999,999,999.99"),oFont09)        
			    oPrint:Say(2050,250,Alltrim("(-)Ret.Federais: "),oFont09n) // "Ret.Federais"
		    	oPrint:Say(2050,920,Transform(nRetFeder,"@E 999,999,999.99"),oFont09)        
    			oPrint:Say(2050,1250,Alltrim("(-)Desc.Incond.: "),oFont09n) // "Desc.Incod"
		    	oPrint:Say(2050,1870,Transform(nDescIncond,"@E 999,999,999.99"),oFont09)        
			    oPrint:Say(2100,250,Alltrim("(-)ISS Ret.: "),oFont09n) // "ISS Ret."
		    	oPrint:Say(2100,920,Transform(IIf(cRecIss=="1",nValISS,0),"@E 999,999,999.99"),oFont09)        
    			oPrint:Say(2100,1250,Alltrim("(=)Base Cálc.: "),oFont09n) // "Base Cálc."
		    	oPrint:Say(2100,1870,Transform((cAliasSF3)->F3_BASEICM,"@E 999,999,999.99"),oFont09)        
			    oPrint:Say(2150,250,Alltrim("Valor Liq.: "),oFont09n) // "Valor Liq."
		    	oPrint:Say(2150,920,Transform(nValLiq,"@E 999,999,999.99"),oFont09)        
    			oPrint:Say(2150,1250,Alltrim("Alíquota: "),oFont09n) // "Alíquota"
		    	oPrint:Say(2150,1988,Transform((cAliasSF3)->F3_ALIQICM,"@E 999.99"),oFont09)        
    			oPrint:Say(2200,1250,Alltrim("(=)Valor ISS: "),oFont09n) // "Valor ISS"
		    	oPrint:Say(2200,1870,Transform((cAliasSF3)->F3_VALICM,"@E 999,999,999.99"),oFont09)        
				oPrint:Say(2260,250,"PIS:" ,oFont09)
				oPrint:Say(2260,285,Transform(nValPis ,PesqPict("SF3","F3_VALICM")),oFont09) 

    			oPrint:Say(2260,630,"COFINS:" ,oFont09)
				oPrint:Say(2260,660,Transform(nValCof ,PesqPict("SF3","F3_VALICM")),oFont09) 

				oPrint:Say(2260,1005,"IR:" ,oFont09)
				oPrint:Say(2260,1035,Transform(nValIR  ,PesqPict("SF3","F3_VALICM")),oFont09) 

				oPrint:Say(2260,1380,"CSLL:" ,oFont09)
				oPrint:Say(2260,1410,Transform(nValCSLL,PesqPict("SF3","F3_VALICM")),oFont09) 

				oPrint:Say(2260,1755,"INSS:" ,oFont09)
				oPrint:Say(2260,1785,Transform(nValINSS,PesqPict("SF3","F3_VALICM")),oFont09)

				oPrint:Say(2330,nColIni,PadC(Alltrim(STR0036),75),oFont10n) // "INFORMAÇÕES SOBRE A NOTA FISCAL ELETRÔNICA"
				oPrint:Line(2380,nColIni,2380,nColFim)
				oPrint:Line(2380,712,2380,712)
				oPrint:Line(2380,1070,2380,1070)
				oPrint:Line(2380,1686,2380,1686)
				oPrint:Say(2400,250,Alltrim("Número do RPS"),oFont09n) // "Número"
				//oPrint:Say(2440,370,Padl(StrZero(Year((cAliasSF3)->F3_EMISSAO),4)+"/"+(cAliasSF3)->F3_NFELETR,14),oFont09) 
				oPrint:Say(2440,370,(cAliasSF3)->F3_DOC+"/"+(cAliasSF3)->F3_SERIE,oFont09)
				oPrint:Say(2400,737,Alltrim(STR0038),oFont09n) // "Emissão"
				oPrint:Say(2440,757,Padl(Transform(dToC((cAliasSF3)->F3_EMINFE),"@d"),14),oFont09)
				oPrint:Say(2400,1094,Alltrim(STR0039),oFont09n) // "Código Verificação"
				oPrint:Say(2440,1144,Padl((cAliasSF3)->F3_CODNFE,24),oFont09)
				oPrint:Say(2400,1711,Alltrim(STR0040),oFont09n) // "Crédito IPTU"
				oPrint:Say(2440,1831,Transform((cAliasSF3)->F3_CREDNFE,"@E 999,999,999.99"),oFont09)
				oPrint:Line(2500,nColIni,2500,nColFim)
				
				nLinha	:= 2530
				For nY := 1 to Len(aPrintObs)
					If nY > 11
						Exit
					Endif
					oPrint:Say(nLinha,250,Alltrim(aPrintObs[nY]),oFont09)
					nLinha 	:= nLinha + 50
				Next
                			
			Else
    			oPrint:Line(2050,712,2150,712)
	    		oPrint:Line(2050,1199,2150,1199)
		    	oPrint:Line(2050,1686,2150,1686)    
			    oPrint:Say(2065,250,Alltrim(STR0032),oFont10n) // "Total deduções (R$)(Iss+Fed)"
		    	oPrint:Say(2105,370,Transform(nValDed + nRetFeder,"@E 999,999,999.99"),oFont10)
			    oPrint:Say(2065,737,Alltrim(STR0033),oFont10n) // "Base de cálculo (R$)"
			    oPrint:Say(2105,857,Iif(lJoinville,Transform(nValBase,"@E 999,999,999.99"),Transform((cAliasSF3)->F3_BASEICM,"@E 999,999,999.99")),oFont10)
			    oPrint:Say(2065,1224,Alltrim(STR0034),oFont10n) // "Alíquota (%)"
			    oPrint:Say(2105,1344,Iif(lJoinville,Transform(nAliquota,"@E 999,999,999.99"),Transform((cAliasSF3)->F3_ALIQICM,"@E 999,999,999.99")),oFont10)
			    oPrint:Say(2065,1711,Alltrim(STR0035),oFont10n) // "Valor do ISS (R$)"
			    oPrint:Say(2105,1831,Transform((cAliasSF3)->F3_VALICM,"@E 999,999,999.99"),oFont10)
			    oPrint:Line(2150,nColIni,2150,nColFim)
		    EndIf
            If !lBhorizonte
				oPrint:Say(2180,nColIni,PadC(Alltrim(STR0036),75),oFont12n) // "INFORMAÇÕES SOBRE A NOTA FISCAL ELETRÔNICA"
				oPrint:Line(2250,nColIni,2250,nColFim)
				oPrint:Line(2250,712,2350,712)
				oPrint:Line(2250,1070,2350,1070)
				oPrint:Line(2250,1686,2350,1686)
				oPrint:Say(2265,250,Alltrim(STR0037)+"/RPS",oFont10n) // "Número"
				oPrint:Say(2305,370,Padl(StrZero(Year((cAliasSF3)->F3_EMISSAO),4)+"/"+(cAliasSF3)->F3_NFISCAL,14),oFont10)
				oPrint:Say(2265,737,Alltrim(STR0038),oFont10n) // "Emissão"
				oPrint:Say(2305,757,Padl(Transform(dToC((cAliasSF3)->F3_EMINFE),"@d"),14),oFont10)
				oPrint:Say(2265,1094,Alltrim(STR0039),oFont10n) // "Código Verificação"
				oPrint:Say(2305,1144,Padl((cAliasSF3)->F3_CODNFE,24),oFont10)
				oPrint:Say(2265,1711,Alltrim(STR0040),oFont10n) // "Crédito IPTU"
				oPrint:Say(2305,1831,Transform((cAliasSF3)->F3_CREDNFE,"@E 999,999,999.99"),oFont10)
				oPrint:Line(2350,nColIni,2350,nColFim)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Outras Informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oPrint:Say(2363,nColIni,PadC(Alltrim(STR0041),75),oFont12n) // "OUTRAS INFORMAÇÕES"
				nLinha	:= 2423
				For nY := 1 to Len(aPrintObs)
					If nY > 11
						Exit
					Endif
					oPrint:Say(nLinha,250,Alltrim(aPrintObs[nY]),oFont10)
					nLinha 	:= nLinha + 50
				Next     
				//Adicionado Michel Aoki - 09/03
				oPrint:Say(nLinha,250,Alltrim(cTotImp),oFont10)
				
				oPrint:Line(1850,nColIni,1850,nColFim)
	
            EndIF
			
			If nCopias > 1 .And. nX < nCopias
				oPrint:EndPage()
			Endif
			
		Next
		
		(cAliasSF3)->(dbSkip())
		
		If !((cAliasSF3)->(Eof()))  
			oPrint:EndPage()
		Endif
		

	Enddo
	
EndIf
                            


If !lQuery
	RetIndex("SF3")	
	dbClearFilter()	
	Ferase(cArqInd+OrdBagExt())
Else
	dbSelectArea(cAliasSF3)
	dbCloseArea()
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTR948Str ºAutor  ³Mary Hergert        º Data ³ 03/08/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Montar o array com as strings a serem impressas na descr.   º±±
±±º          ³dos servicos e nas observacoes.                             º±±
±±º          ³Se foi uma quebra forcada pelo ponto de entrada, e          º±±
±±º          ³necessario manter a quebra. Caso contrario, montamos a linhaº±± 
±±º          ³de cada posicao do array a ser impressa com o maximo de     º±±
±±º          ³caracteres permitidos.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Array com os campos da query                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cString: string completa a ser impressa                     º±±
±±º          ³nLinhas: maximo de linhas a serem impressas                 º±±
±±º          ³nTotStr: tamanho total da string em caracteres              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MATR968                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function Mtr968Mont(cString,nLinhas,nTotStr)

Local aAux		:= {}
Local aPrint	:= {}

Local cMemo 	:= ""
Local cAux		:= ""

Local nX		:= 1
Local nY 		:= 1
Local nPosi		:= 1

cString := SubStr(cString,1,nTotStr)

For nY := 1 to Min(MlCount(cString,86),nLinhas)

	cMemo := MemoLine(cString,86,nY) 
			
	// Monta a string a ser impressa ate a quebra
	Do While .T.
		nPosi 	:= At("|",cMemo)
		If nPosi > 0
			Aadd(aAux,{SubStr(cMemo,1,nPosi-1),.T.})
			cMemo 	:= SubStr(cMemo,nPosi+1,Len(cMemo))
		Else    
			If !Empty(cMemo)
				Aadd(aAux,{cMemo,.F.})
			Endif
			Exit
		Endif	
	Enddo
Next            
		
For nY := 1 to Len(aAux)
	cMemo := ""
	If aAux[nY][02]   
		Aadd(aPrint,aAux[nY][01])
	Else
		cMemo += Alltrim(aAux[nY][01]) + Space(01)
		Do While !aAux[nY][02]
			nY += 1  
			If nY > Len(aAux)
				Exit
			Endif
			cMemo += Alltrim(aAux[nY][01]) + Space(01)
		Enddo
		For nX := 1 to Min(MlCount(cMemo,86),nLinhas)
			cAux := MemoLine(cMemo,86,nX) 
		   	Aadd(aPrint,cAux)
		Next
	Endif                            
Next   

Return(aPrint)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AjustaSX1 ³ Autor ³ Mary C. Hergert       ³ Data ³05/07/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria as perguntas necessarias a impressao do RPS            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATR968                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1()
Local 	aAreaSX1	:= SX1->(GetArea())

SX1->(dbSetOrder(1))
If SX1->(dbSeek("MTR968    05")) 
	If SX1->X1_TAMANHO <> TamSx3("F3_NFISCAL")[1]
    	RecLock("SX1",.F.)
		SX1->X1_TAMANHO := TamSx3("F3_NFISCAL")[1]
    	SX1->(MSUnlock())
	Endif
Endif

If SX1->(dbSeek("MTR968    06")) 
	If SX1->X1_TAMANHO <> TamSx3("F3_NFISCAL")[1]
    	RecLock("SX1",.F.)
	    SX1->X1_TAMANHO := TamSx3("F3_NFISCAL")[1]
    	SX1->(MSUnlock())
	Endif
Endif

RestArea(aAreaSX1)                   
Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M968Discri³ Autor ³Alexandre Inacio Lemes ³ Data ³27/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta um array com a string quebrada em linhas com o tamanho³±±
±±³          ³da capacidade de impressao da linha utilizado RPS Sorocaba  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATR968                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function M968Discri(cString,nLinhas,nTotStr)

Local aAux		:= {}
Local aPrint	:= {}

Local cMemo 	:= ""
Local cAux		:= ""

Local nX		:= 1
Local nY 		:= 1
Local nPosi		:= 1

cString := SubStr(cString,1,nTotStr)

For nY := 1 to Min(MlCount(cString,130),nLinhas)

	cMemo := MemoLine(cString,130,nY) 
			
	// Monta a string a ser impressa ate a quebra
	Do While .T.
		nPosi 	:= At("|",cMemo)
		If nPosi > 0
			Aadd(aAux,{SubStr(cMemo,1,nPosi-1),.T.})
			cMemo 	:= SubStr(cMemo,nPosi+1,Len(cMemo))
		Else    
			If !Empty(cMemo)
				Aadd(aAux,{cMemo,.F.})
			Endif
			Exit
		Endif	
	Enddo
Next            
		
For nY := 1 to Len(aAux)
	cMemo := ""
	If aAux[nY][02]   
		Aadd(aPrint,aAux[nY][01])
	Else
		cMemo += Alltrim(aAux[nY][01]) + Space(01)
		Do While !aAux[nY][02]
			nY += 1  
			If nY > Len(aAux)
				Exit
			Endif
			cMemo += Alltrim(aAux[nY][01]) + Space(01)
		Enddo
		For nX := 1 to Min(MlCount(cMemo,130),nLinhas)
			cAux := MemoLine(cMemo,130,nX) 
		   	Aadd(aPrint,cAux)
		Next
	Endif                            
Next   

Return(aPrint)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PrintBox  ³ Autor ³Alexandre Inacio Lemes ³ Data ³27/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para "ENGROSSAR" a espessura das linhas do BOX atrave³±±
±±³          ³s do deslocamento dos pixels pelo for next                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATR968                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrintBox(nPosY,nPosX,nAltura,nTamanho)

Local nX := 0

For nX := 1 To 5
	oPrint:Box(nPosY+nX,nPosX+nX,nAltura+nX,nTamanho+nX)
Next nX

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PrintLine ³ Autor ³Alexandre Inacio Lemes ³ Data ³27/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para "ENGROSSAR" a espessura das linhas do PrintLine ³±±
±±³          ³Atraves do deslocamento dos pixels pelo for next            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATR968                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrintLine(nPosY,nPosX,nAltura,nTamanho)

Local nX := 0

For nX := 1 To 5
	oPrint:Line(nPosY+nX,nPosX+nX,nAltura+nX,nTamanho+nX)
Next nX

Return

 
//Michel Aoki 
//Observação da nota

Static Function _ObsPv(_xPedido)
	  
	  Local _aArea   := GetArea()
	  Local _aRetObs  := {}
	  Local cMensagem := ""
	  Local cNumeroOS := ""
	  // Impressão da mensagem da nota.
	  cQuery := {}
	  cQuery := " SELECT CAST( CAST(C5_MENNOTA AS VARBINARY(1024)) AS VARCHAR(1024)) AS OBSERVA,"
      cQuery += "       (SELECT DISTINCT SUBSTRING(C6_NUMORC,01,06)"
      cQuery += "          FROM " + RetSqlName("SC6")
      cQuery += "         WHERE C6_FILIAL  = C5_FILIAL" 
      cQuery += "           AND C6_NUM     = C5_NUM"
      cQuery += "           AND C6_NUMORC <> ''"
      cQuery += "           AND D_E_L_E_T_ = '') AS NUMEROOS"  
      cQuery += "   FROM " + RETSQLNAME("SC5")
	  cQuery += "  WHERE C5_NUM    = '" + Alltrim(_Xpedido) + "'"
	  cQuery += "    AND C5_FILIAL = '" + xFilial("SC5") + "'"
	  cQuery += "    AND D_E_L_E_T_ <> '*'"

 	  cQuery := ChangeQuery(cQuery)
	  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TSC5",.T.,.T.)
	
	  DbSelectArea("TSC5")
      cNumeroOs := Alltrim(TSC5->NUMEROOS)
	  cMensagem := Alltrim(TSC5->OBSERVA)
	  DbSelectArea("TSC5")
	  DbCloseArea()               
 
      If Empty(Alltrim(cMensagem))
         If Empty(Alltrim(cNumeroOS))
            cMensagem +=  "PEDIDO NR. " + Alltrim(_Xpedido)
         Else   
            cMensagem +=  "OS NR. " + Alltrim(cNumeroOS) + " - " + "PEDIDO NR. " + Alltrim(_Xpedido)
         Endif   
      Else
         If !Empty(Alltrim(cNumeroOS))
            cMensagem +=  "OS NR. " + Alltrim(cNumeroOS) + " - " + cMensagem
         Endif   
      Endif
	
		 
	 RestArea(_aArea)

Return(cMensagem)


//Adicionado Michel Aoki - Lei Transparência

Static Function _Transparencia(_cDesc,_nTotal)

   Local _cMensTransp := ""
   Local _nAproximado := 0	
         
   // Pesquisa as naturezas de serviços e seus Percentuais para cálculo dos impostos aproximados para impressão
   If Select("T_ALIQUOTAS") > 0
      T_ALIQUOTAS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4.ZZ4_NATT, "
   cSql += "      (SELECT EL0_ALIQIM FROM EL0010 WHERE EL0_COD = ZZ4.ZZ4_NATT AND D_E_L_E_T_ = '') AS PRC_TEC,"
   cSql += "       ZZ4.ZZ4_NATP, " 
   cSql += "      (SELECT EL0_ALIQIM FROM EL0010 WHERE EL0_COD = ZZ4.ZZ4_NATP AND D_E_L_E_T_ = '') AS PRC_PRO,"
   cSql += "       ZZ4_NATA    , "    
   cSql += "      (SELECT EL0_ALIQIM FROM EL0010 WHERE EL0_COD = ZZ4.ZZ4_NATA AND D_E_L_E_T_ = '') AS PRC_AGE "
   cSql += "  FROM " + RetSqlName("ZZ4") + " ZZ4 "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ALIQUOTAS", .T., .T. )

   If !T_ALIQUOTAS->( EOF() )
      cPrcTecnica := T_ALIQUOTAS->PRC_TEC
      cPrcProjeto := T_ALIQUOTAS->PRC_PRO
      cPrcAgencia := T_ALIQUOTAS->PRC_AGE
   Endif

   If Empty(Alltrim(T_ALIQUOTAS->ZZ4_NATT))
      MsgAlert("Atenção! Naturezas de Serviços de Assistência Técnica não parametrizada no Parametrizador Automatech. Verifique!")
      Return("")
   Endif
      
   If Empty(Alltrim(T_ALIQUOTAS->ZZ4_NATP))
      MsgAlert("Atenção! Naturezas de Serviços de Projetos não parametrizado no Parametrizador Automatech. Verifique!")
      Return("")
   Endif

   If Empty(Alltrim(T_ALIQUOTAS->ZZ4_NATA))
      MsgAlert("Atenção! Naturezas de Serviços de Agenciamento não parametrizado no Parametrizador Automatech. Verifique!")
      Return("")
   Endif

		 
		 
 // Calcula o valor aproximado dos tributos para impressão da nota fiscal
           
    // Em caso do produto ser serviço de Assistência Técnica
    If Substr(_cDesc,01,03) == "AST" .Or. Substr(_cDesc,01,05) == "CONTR" .Or. Substr(_cDesc,01,04) == "BEMA" .Or. Substr(_cDesc,01,04) == "OUTR";
    	 .Or. Substr(_cDesc,01,03) == "SUP"
        _nAproximado := _nAproximado + Round(((_nTotal * cPrcTecnica) / 100),2)
    Endif
              
    // Em caso do produto ser serviço de Projetos
    If Substr(_cDesc,01,03) == "PRJ"
        _nAproximado := _nAproximado + Round(((_nTotal * cPrcProjeto) / 100),2)
    Endif

    // Em caso do produto ser serviço de Agenciamento - Comissão
    If Substr(_cDesc,01,12) == "AGENCIAMENTO" .Or. Substr(_cDesc,01,08) == "COMISSAO"
       _nAproximado := _nAproximado + Round(((_nTotal * cPrcAgencia) / 100),2)
    Endif

    If _nAproximado > 0
		_cMensTransp:= "Valor Aproximado dos Tributos: R$ " + Alltrim(Transform(_nAproximado, "@E 999,999,999.99")) + "   Fonte: IBPT"
	ENDIF
			
	T_ALIQUOTAS->( dbCloseArea() )
			
Return(_cMensTransp)



 
Static Function _BuscaDescr(_cNumPV,_cDoc)

Local _cRetorno := ""
Local _nCont    := 0

_cQuery := " SELECT C6_DESCRI, C6_VALOR FROM " +RetSqlName('SC6')
_cQuery += " where C6_NUM = '"+alltrim(_cNumPV)+"' "
_cQuery += " AND   C6_FILIAL =  '"+alltrim(xFilial("SC6"))+"' "
_cQuery += " AND C6_NOTA = '"+alltrim(_cDoc)+"' "
_cQuery += " AND D_E_L_E_T_= '' "
TcQuery _cQuery NEW ALIAS ("TMP")

WHILE  TMP->(!EOF())
	_nCont++
	If _nCont == 1
		_cRetorno += Alltrim(TMP->C6_DESCRI)+" Vlr Total: "+Alltrim(Transform(TMP->C6_VALOR,'@E 99,999,999,999.99'))
	Else             
		_cRetorno += CHR(13)+CHR(10)+" | "+Alltrim(TMP->C6_DESCRI)+" Vlr Total: "+Alltrim(Transform(TMP->C6_VALOR,'@E 99,999,999,999.99'))
	EndIf
	
	TMP->(Dbskip())
enddo

TMP->(DbCloseArea())
Return(	_cRetorno)		