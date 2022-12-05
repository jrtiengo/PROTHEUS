#INCLUDE "Totvs.ch"


//Jean Rehermann - Solutio IT - 29/06/2015 - Efetua a copia de uma TES
User Function IBAF090()

    SF4COPIA()
	
Return( .T. )

Static Function SF4COPIA()

	Local aSize     := MsAdvSize() 
	Local aInfo     := {} 
	Local aObjects  := {} 
	Local aObj      := {}
	Local aNoFields := {"FC_TES"}
	Local bCampo    := {|nCPO| Field(nCPO)}
	Local bCondicao := {|| .T.}
	Local cSeek     := ""
	Local cWhile    := ""
	Local cCampo    := ""
	Local lGravaOk  := .T.
	Local nX,nZ,nY  := 0
	Local nOpca     := 0
	Local nRecSF4   := SF4->(Recno())
	Local oDlg
	Local aHeadCC7  := {}
	Local aColsCC7  := {}
	Local lAjICMS   := AliasIndic("CC6").And.AliasIndic("CC7").And.AliasIndic("CC8").And.AliasIndic("CC9").And.;
						 AliasIndic("CCA").And.AliasIndic("CCB").And.AliasIndic("CCC").And.AliasIndic("CCD")
	Local lCalcImpV := GetMV("MV_GERIMPV")=="S"
	Local aFolders  :=	{}
	Local cOk       := ""
	Local aButtons  := {}
	Local aButtonUsr:= {}
	Local nPosX     := 0
	Local bSkip     := IIF(lAjICMS .And. CC7->(FieldPos("CC7_TPREG")) > 0,{|| CC7->CC7_TPREG == "NA" },NIL)
	Local aCmpsCC7  := {"CC7_CODLAN"}
	Local bCampoSF4 := { |x| SF4->(Field(x)) }
	Local aCmps     := {}
	Local lAlt      := .F.
	Local oFolTES	:= NIL
	Local aAutoCab  :={}
	
	PRIVATE oGetd
	PRIVATE aTELA[0][0],aGETS[0]
	PRIVATE cAlias := Alias()
	PRIVATE nReg   := (cAlias)->( Recno() )
	PRIVATE nOpc   := 3
	PRIVATE INCLUI := .T.
	
	If SoftLock("SF4") .And. SF4->F4_FILIAL == xFilial("SF4")
	
		aHeader := {}
		aCols	:= {}
	
		If lCalcImpV
			aAdd(aFolders,"Impostos variáveis")
	
			dbSelectArea("SFC")
			dbSetOrder(1)
			If dbSeek(xFilial("SFC")+SF4->F4_CODIGO)
				cSeek    := xFilial("SFC")+SF4->F4_CODIGO
				cWhile   := "SFC->FC_FILIAL+SFC->FC_TES"
				bCondicao:= {|| If( SoftLock("SFC") , .T. , .F. ) }
				FillGetDados(nOpc,"SFC",1,cSeek,{|| &cWhile },bCondicao,aNoFields,,,,,,,,,,,)
			Else
				FillGetDados(nOpc,"SFC",1,,,,aNoFields,,,,,.T.,,,,,)
				aCols[1][aScan(aHeader,{|x| Trim(x[2])=="FC_SEQ"})] := StrZero(1,Len(SFC->FC_SEQ))
			EndIf
		EndIf
		
		If lAjICMS
			Private	oNewGetDad
			
			aAdd(aFolders,"Lançamentos da Apuração de ICMS"	)
			aMHead("CC7","CC7_TES/",@aHeadCC7)
			CC7->(dbSeek(xFilial("CC7")+SF4->F4_CODIGO))
			aMAcols(nOpc,"CC7",@aColsCC7,aHeadCC7,{||CC7->CC7_TES==SF4->F4_CODIGO},bSkip)
			
			If CC7->(FieldPos("CC7_IFCOMP"))>0
				aAdd(aCmpsCC7,"CC7_IFCOMP")
			EndIf
			If CC7->(FieldPos("CC7_CLANAP"))>0
				aAdd(aCmpsCC7,"CC7_CLANAP")
			EndIf
			If CC7->(FieldPos("CC7_CODREF"))>0
				aAdd(aCmpsCC7,"CC7_CODREF")
			EndIf
		EndIf
		
		dbSelectArea("SF4")
		For nX := 1 to FCount()
			nPosX := aScan(aAutoCab,{|aX|AllTrim(Eval(bCampo,nX))$aX[1]})
			If nPosX<>0
				M->&(Eval(bCampo,nX)) := aAutoCab[nPosX,2]
			Else
				M->&(Eval(bCampo,nX)) := FieldGet(nX)
			EndIf
		Next nX
	
		aCmps :=  RetCmps("SF4",bCampoSF4)	
		AAdd( aObjects, { 100, 100, .T., .T. } )
		AAdd( aObjects, { 100,  60, .T., .T. } )
		aInfo := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 }
		aObj  := MsObjSize( aInfo, aObjects, .T. )
		
		DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
		
		EnChoice( "SF4", nReg, nOpc, , , , , aObj[1], , 3 )
		
		oFolTES := TFolder():New(aObj[2,1],aObj[2,2],aFolders,{},oDlg,,,,.t.,.f.,aObj[2,4],aObj[2,3],)
	
		cOk	:=	"{||nOpcA:=1"
		If lCalcImpV
			A081Cab(nOpc)
			oGetd:=MsGetDados():New(0,0,aObj[2,3]-aObj[2,1]-13,aObj[2,4],nOpc,"A081LinOk","A081TudOk","+FC_SEQ",.T.,,,,,,,,,oFolTES:aDialogs[1])
			oGetd:oBrowse:bGotFocus:={|| A081Cab(nOpc)}
			If lAjICMS
				cOk	+=	",if(A081TudOk(,nOpc).And.AjusteLOK(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)"
			Else
				cOk	+=	",if(A081TudOk(,nOpc),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)"
			EndIf
		EndIf
		
		If lAjICMS
			oNewGetDad := MsNewGetDados():New(0,0,aObj[2,3]-aObj[2,1]-13,aObj[2,4],GD_UPDATE+GD_INSERT+GD_DELETE,"AjusteLOK","AllwaysTrue","+CC7_SEQ",aCmpsCC7,/*freeze*/,990,/*fieldok*/,/*superdel*/,/*delok*/,oFolTES:aDialogs[Iif(lCalcImpV,2,1)],@aHeadCC7,@aColsCC7)
			cOk	+=	Iif(lCalcImpV,"",",Iif(A081TudOk(,nOpc).And.AjusteLOK(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca:=0)")
		Else
			cOk	+=	Iif(lCalcImpV,"",",Iif(A081TudOk(,nOpc),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)")
		EndIf
		cOk	+=	"}"
	    
		M->F4_CODIGO := Space( 3 )
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,&(cOk),{||oDlg:End()},,aButtons)
		
		If nOpcA == 1

			Begin Transaction
				lGravaOk := A081Grava()
				If lGravaOk
					If lAjICMS
						GrvAjuste()
					Endif
					EvalTrigger()
				EndIf
			End Transaction
		
			If lGravaOk
				MT080AltOk()			
			EndIf
	
			
		EndIf
	Else
		IF SF4->F4_FILIAL <> xFilial("SF4")
			Help(" ",1,"A000FI")
		Endif
	EndIf
	
	INCLUI := .F.
	ALTERA := .F.
	VISUAL := .T.
	nReg   := (cAlias)->( Recno() )
	nOpc   := 2

Return( 2 )

Static Function aMHead(cAlias,cNCmps,aH)

	Local	lRet	:=	.T.
	Local _cSX3     := GetNextAlias()
	
	OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX3,"SX3",Nil,.F.)
	lOpen := Select(_cSX3) > 0
	If (lOpen)
	  
		dbSelectArea(_cSX3)
		(_cSX3)->(dbSetOrder(1)) //X3_CAMPO
		(_cSX3)->(dbSeek(cAlias))
		While ( !(_cSX3)->(Eof()) .And. &("(_cSX3)->X3_ARQUIVO") == cAlias )
			If X3USO(&("(_cSX3)->X3_USADO")) .And. cNivel >= &("(_cSX3)->X3_NIVEL") .and. !(AllTrim(&("(_cSX3)->X3_CAMPO"))+"/"$cNCmps)
				AADD(aH,{Trim(X3Titulo()),;
						AllTrim( &("(_cSX3)->X3_CAMPO ")),;
						&("(_cSX3)->X3_PICTURE"),;
						&("(_cSX3)->X3_TAMANHO"),;
						&("(_cSX3)->X3_DECIMAL"),;
						&("(_cSX3)->X3_VALID"),;
						&("(_cSX3)->X3_USADO"),;
						&("(_cSX3)->X3_TIPO"),;
						&("(_cSX3)->X3_F3"),;
						&("(_cSX3)->X3_CONTEXT"),;
						&("(_cSX3)->X3_CBOX"),;
						&("(_cSX3)->X3_RELACAO")})
			EndIf
			(_cSX3)->(DBSkip())
		EndDo
	
	Endif
	
	(_cSX3)->(dbCloseArea())
	/*
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cAlias)
	While !Eof() .And. (X3_ARQUIVO==cAlias)
		IF X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .and. !(AllTrim(X3_CAMPO)+"/"$cNCmps)
			AADD(aH,{ Trim(X3Titulo()), ;
				AllTrim(X3_CAMPO),;
				X3_PICTURE,;
				X3_TAMANHO,;
				X3_DECIMAL,;
				X3_VALID,;
				X3_USADO,;
				X3_TIPO,;
				X3_F3,;
				X3_CONTEXT,;
				X3_CBOX,;
				X3_RELACAO})
		Endif
		dbSkip()
	Enddo
	*/

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³Descri‡…o ³ Funcao para montagem do HEADER do GETDADOS                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias da tabela base para montagem do HEADER      ³±±
±±³          ³cNCmps -> Campos que nao serao considerados no HEADER       ³±±
±±³          ³aH -> array no qual o HEADER serah montado                  ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function aMAcols(cOpc,cAlias,aC,aH,bCond,bSkip)
Local	lRet	:=	.T.
Local	nI		:=	0

DEFAULT bSkip 	:= {|| .F. }

dbSelectArea(cAlias)
dbSetOrder(1)
If cOpc == 3 .And. !Eof()
	aC	:=	{}
	While !Eof() .And. Eval(bCond)
		IF Eval(bSkip)
			dbSkip()
			Loop
		EndIf
		aAdd(aC,Array(Len(aH)+1))
		For nI := 1 To Len(aH)
			aC[Len(aC),nI] := FieldGet(FieldPos(aH[nI,2]))
		Next
		aC[Len(aC),Len(aH)+1] := .F.
		dbSkip()
	End	
Else
	aC				:=	{Array(Len(aH)+1)}
	aC[1,Len(aH)+1]	:=	.F.
	For nI := 1 To Len(aH)
		If aH[nI,10]#"V"
			aC[1,nI]	:=	CriaVar(aH[nI,2])
		EndIf

		If "_SEQ"$aH[nI,2]
			aC[1,nI]	:=	StrZero(1,aH[nI,4])
		EndIf
	Next	
EndIf
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de gravacao das informacoes do acols do GETDADOS na ³±±
±±³          ³  tabela CC7.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GrvAjuste()

	Local	lRet		:=	.T.
	Local	aColsNew	:=	aClone(oNewGetDad:aCols)
	Local	aHeadNew	:=	aClone(oNewGetDad:aHeader)
	Local	nPosSeq		:=	aScan(aHeadNew,{|aX| aX[2]=="CC7_SEQ"})
	Local	nPosCA		:=	aScan(aHeadNew,{|aX| aX[2]=="CC7_CODLAN"})
	Local	nPosDR		:=	aScan(aHeadNew,{|aX| aX[2]=="CC7_DESCR"})
	Local	nPosIFCOMP	:=	aScan(aHeadNew,{|aX| aX[2]=="CC7_IFCOMP"})
	Local	nPosClan	:=	aScan(aHeadNew,{|aX| aX[2]=="CC7_CLANAP"})
	Local	nPosCodRef	:=	aScan(aHeadNew,{|aX| aX[2]=="CC7_CODREF"})
	Local	nI			:=	0
	Local	lAchouCC7	:=	.F.
	
	dbSelectArea("CC7")
	dbSetOrder(1)
	
	For nI := 1 To Len(aColsNew)
		If !Empty(aColsNew[nI,nPosCA]) .Or.  IIf( CC7->(FieldPos("CC7_CLANAP")) > 0 .And. nPosClan > 0, !Empty(aColsNew[nI,nPosClan]) , .T. )  
	
			If aColsNew[nI,Len(aColsNew[nI])]
				Loop
			Else
				RecLock("CC7",.T.)
				CC7->CC7_FILIAL	:=	xFilial("CC7")
				CC7->CC7_TES	:=	SF4->F4_CODIGO
				CC7->CC7_SEQ	:=	aColsNew[nI,nPosSeq]
				CC7->CC7_CODLAN	:=	aColsNew[nI,nPosCA]
				CC7->CC7_DESCR	:=	aColsNew[nI,nPosDR]
				If CC7->(FieldPos("CC7_IFCOMP"))>0
					CC7->CC7_IFCOMP	:=	aColsNew[nI,nPosIFCOMP]
				EndIf
				If CC7->(FieldPos("CC7_CLANAP"))>0 .And. nPosClan > 0
					CC7->CC7_CLANAP	:= aColsNew[nI,nPosClan]
				EndIf
				If CC7->(FieldPos("CC7_CODREF"))>0 .And. nPosCodRef > 0
					CC7->CC7_CODREF	:= aColsNew[nI,nPosCodRef]
				EndIf
				MsUnLock()
				CC7->(FKCommit())			
			EndIf
		EndIf
	Next nI

Return lRet
