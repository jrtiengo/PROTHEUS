#INCLUDE "PROTHEUS.CH"
/*/

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³MATR990   ³ Autor ³ Juan Jose Pereira     ³ Data ³ 01.06.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Emiss„o do Livro de Registro de ISS mod.51 do Mun. Sao Paulo³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MATR990(void)                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Jean Rehermann - SOlutio IT - 14/05/2015 - Implementada versão com impressão do número da NFE ao invés da RPS
/*/
User Function SOLMR990

	Local aArea		:= GetArea()
	Local titulo	:=	""
	Local cDesc1	:=	""
	Local cDesc2	:=	""
	Local cDesc3	:=	""
	Local aLinha	:=	{}
	Local nomeprog	:=	"MATR990"
	Local cPerg   	:=	"MTR990"
	Local cNrLivro	:=	""
	Local cString  :=	"SF3"
	Local cabec1   :=	""
	Local cabec2   :=	""
	Local wnrel    :=   "MTR990" // Nome do Arquivo utilizado no Spool

	Local nPosFil		:= 0
	Local nForFilial	:= 0
	Private lAglFil		:= .F.
	Private lSelFil		:= .F.   
	Private aFilsCalc	:= {}
	Private aFilAtiv	:= {}
	Private cFilSF6		:= ''
	Private cFilSF3		:= ''
	Private cFilBack	:= cFilAnt

	Private Limite 		:= 220
	Private Tamanho		:=	"M"
	Private nPagina		:= 1
	Private lEnd    	:= .F.// Controle de cancelamento do relatorio
	Private m_pag   	:= 1  // Contador de Paginas
	Private nLastKey	:= 0  // Controla o cancelamento da SetPrint e SetDefault
	Private aOrdem  	:= {}  // Ordem do Relatorio
	Private aReturn 	:= { "Zebrado", 1,"Administracao", 2, 2, 1, "",0 }

	AjustaSx1()
	Pergunte(cPerg,.f.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                                ³
	//³ mv_par01             // da Data                                     ³
	//³ mv_par02             // ate a Data                                  ³
	//³ mv_par03             // Pagina Inicial                              ³
	//³ mv_par04             // Nr do Livro                                 ³
	//³ mv_par05             // Livro ou Livro+termos ou Termos             ³
	//³ mv_par06             // Livro Selecionado                           ³
	//³ mv_par07             // Nro do CCM                                  ³
	//³ mv_par08             // Total Diario                                ³
	//³ mv_par09             // Tipo Totalizacao(Decendial/Quinzenal/Mensal ³
	//³ mv_par10             // Imprime Guias de Recolhimento ?		        ³
	//³ mv_par11             // Modelo do Registro (Modelo 51)              ³
	//³ mv_par12             // Nro Processo Reg. Esp.                      ³
	//³ ...                                                                 ³
	//³ mv_par16             // Seleciona Filiais? S/N                      ³
	//³ mv_par17             // Algutina por CNPJ? S/N                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cDesc1	:=	"Emissao dos Registros de ISS Mod. 51.
	cDesc2	:=	"Ira imprimir os lancamentos fiscais referentes a Imposto Sobre "
	cDesc3	:=	"Servicos, conforme o periodo informado."
	Titulo  :=	"** REGISTRO NOTAS FISCAIS DE SERVICOS PRESTADOS MOD.51 **"
	wnrel	:=	SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrdem,,Tamanho)

	//³ Impressao de Termo / Livro                                   ³
	Do Case
	Case mv_par05==1
		lImpLivro:=.T.
		lImpTermos:=.F.
	Case mv_par05==2
		lImpLivro:=.T.
		lImpTermos:=.T.
	Case mv_par05==3
		lImpLivro:=.F.
		lImpTermos:=.T.
	EndCase

	nPagina	:=	IIF(mv_par03<2, 2, mv_par03)
	
	If nLastKey==27
		dbClearFilter()
		cFilAnt	:= cFilBack
		Return
	EndIf
	
	If mv_par11==2
		MSGINFO("MV_PAR11","mv_par11==2")
		cFilAnt	:= cFilBack
		Return
	Endif
	
	SetDefault(aReturn,cString)
	If nLastKey==27
		dbClearFilter()
		cFilAnt	:= cFilBack
		Return
	EndIf

	//³ Recebe filtro definido pelo usuario                          ³
	cFilterUser	:=	aReturn[7]
	
	// Variáveis para gestão corporativa 
	lSelFil		:= ( mv_par16 == 1 ) 
	lAglFil		:= ( mv_par17 == 1 )  
	aFilsCalc	:= MatFilCalc( lSelFil, , , (lSelFil .and. lAglFil), , 4 )
	
	If Empty(aFilsCalc)
		cFilAnt	:= cFilBack
		Return
	EndIf

	// Se Seleciona Filiais, guarda as filiais dos arquivos para uso posterior
	If lSelFil
		For nForFilial := 1 to Len( aFilsCalc )
			If aFilsCalc[ nForFilial, 1 ]
				cFilAnt := aFilsCalc[ nForFilial, 2 ]
				aAdd( aFilAtiv, { cFilAnt, xFilial('SF3'), xFilial('SF6'), xFilial('SA1'), xFilial('SA2') } )
			EndIf
		Next
	
		// Se aglutina filiais, monta a string conforme as filiais de cada tabela envolvida
		If lAglFil
			cFilAnt	:= aFilAtiv[1,1]
			For nPosFil := 1 to Len(aFilAtiv)
				cFilSF6	+= IIf(nPosFil==1,"('","'")+aFilAtiv[nPosFil,3]+IIf(nPosFil==Len(aFilAtiv),"')","',")	
				cFilSF3	+= IIf(nPosFil==1,"('","'")+aFilAtiv[nPosFil,2]+IIf(nPosFil==Len(aFilAtiv),"')","',")
			Next
		EndIf
	
	// Se não seleciona Filiais, não irá aglutinar CNPJ
	Else
		aAdd( aFilAtiv, { cFilAnt, xFilial('SF3'), xFilial('SF6'), xFilial('SA1'), xFilial('SA2') } )
		cFilSF3	:= "('"+aFilAtiv[1,2]+"')" 
		cFilSF6	:= "('"+aFilAtiv[1,3]+"')"
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa relatorio                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lImpLivro // Impressao do Livro
		Tamanho := IIf(mv_par11<3, 'M', 'G')
		Limite	:= IIf(mv_par11<3, 132, 220)
		RptStatus({|lEnd| R990Livro(@lEnd,wnRel,cString,Tamanho,cPerg)},titulo)
	
	ElseIf lImpTermos .and. !lImpLivro	// Impressao somente dos Termos
		If !lAglFil
			SM0->(dbSetOrder(1))
			For nForFilial := 1 to Len(aFilAtiv)
				cFilAnt	:= aFilAtiv[nForFilial,1]
				SM0->(dbSeek(cEmpAnt+cFilAnt))
				R990ImpTerm(cPerg)
			Next	
		Else
			R990ImpTerm(cPerg)
		EndIf
	
	EndIf

	//³ Restaura Ambiente                                            ³

	If aReturn[5] == 1
		Set Printer TO
		dbCommitAll()
		Ourspool(wnrel)
	EndIf
	
	cFilAnt	:= cFilBack
	RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcion   ³R990Livro ³ Autor ³ Thiago Galvao Silveira³ Data ³ 01/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do Livro de Registro de ISS                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR990()                                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function R990Livro(lEnd,wnRel,cString,Tamanho,cPerg)

	Local cAliasSF3 := "SF3"
	Local cAliasTS3 := ""		
	Local cAliasSF6 := "SF6"
	Local lQuery    :=	.F.
	Local nX        := 0
	Local nY        := 0
	Local nZ        := 0
	Local aLay      := Array(40)
	Local nLin		:= 0
	Local nMes      := ""
	Local cMesAno   := ""
	Local nPos      := 0
	Local nApuracao := mv_par09
	Local nMesRec   := ""
	Local lF3_Reciss := SF3->(FieldPos ("F3_RECISS"))>0
	Local lControle := .F. 
	Local cDFim     := ""
	Local nMfim     := ""
	Local nTam		:= 0
	Local lJoiSC		:=	SM0->M0_ESTENT == "SC" .And. "JOINVILLE" $ Upper(SM0->M0_CIDENT)
	Local nMinRetISS	:=	GetNewPar("MV_VRETISS",0)

	Local lMapResumo	:= IIF((SuperGetMV("MV_LJLVFIS",,1) == 2) .AND. mv_par15 == 1,.T.,.F.)
	Local aMapaResumo	:= 	{}
	Local aGravaMapRes	:= 	{}
	Local cArqBkpQry	:= 	""
	Local cArqTmpMP		:= 	""
	Local aCposTemp		:=	{}
	Local nFeixe	    := 0
	Local nForFilial	:= 0			// Loop para gestão corporativa
	Local nPosFil		:= 0
	Local cTipoMov := ""
	Local cF4FRetISS := ""
	Local cA1FRetISS := ""


	#IFDEF TOP
		Local nSF6		:=	0
	#ENDIF	

	cNome	:=	SM0->M0_NOMECOM
	cInscr  :=	InscrEst()
	cEnd	:=	ALLTRIM(SM0->M0_ENDENT)
	cEnd	+= 	iif(len(ALLTRIM(SM0->M0_ENDENT))>0 .and. len(ALLTRIM(SM0->M0_BAIRENT))>0," - ","")
	cEnd	+=	ALLTRIM(SM0->M0_BAIRENT)
	cEnd	+=	iIf(len(cEnd)>0 .and. len(ALLTRIM(SM0->M0_CIDENT))>0," - ","")
	cEnd	+=	ALLTRIM(SM0->M0_CIDENT)
	cEnd	+=	iIf(len(cEnd)>0 .AND. len(ALLTRIM(SM0->M0_ESTENT))>0,"/","")
	cEnd	+=	ALLTRIM(SM0->M0_ESTENT)
	cCGC	:=	TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99")
	cCCM	:=	mv_par07
	cCodISS := ""
	cNproc  := mv_par12

	nDia        := 01
	cDia        := ""
	nSerie      := 0
	nNumNota    := 0
	nBaseCalc   := 0.00
	nAliq       := ""
	nImpIncid   := 0.00
	nImpRet     := 0.00
	nValIsen    := 0.00
	nValDev     := 0.00
	cObserv     := ""
	cCNPJ       := ""
	cRecISS	  := ""

	nBaseCalcT  := 0.00
	nImpIncidT  := 0.00
	nImpRetT    := 0.00
	nValIsenT   := 0.00
	nValDevT    := 0.00

	nSBaseCalcT := 0.00
	nSImpIncidT := 0.00
	nSImpRetT   := 0.00
	nSValIsenT  := 0.00
	nSValDevT   := 0.00

	aDia        := {}
	aApurI      := {0,0,0,0,0}
	aApurII     := {0,0,0,0,0}
	aApurIII    := {0,0,0,0,0}
	aTotMes     := {0,0,0,0,0}
	aResumo     := {}
	nTotImpDev  := 0.00

	lResumo      := .F.
	lApuracao    := .T.
	lApurI       := .F.
	lApurII      := .F.
	lApurIII     := .F.
	lMudouPag    := .F.
	lHouveMov    := .F.
	nNumAliq     := 0
	nNumDia      := 1
	nContrRes    := 1

SM0->(dbSetOrder(1))
For nForFilial := 1 to Len(aFilAtiv)
	
	cFilAnt	:= aFilAtiv[nForFilial,1]
	SM0->(dbSeek(cEmpAnt+cFilAnt))
	If !lAglFil
		nNumDia      := 1
		nPagina	:=	IIF(MV_PAR03<2, 2, MV_PAR03)
		nDia        := 01
		cDia        := ""
		nSerie      := 0
		nNumNota    := 0
		nBaseCalc   := 0.00
		nAliq       := ""
		nImpIncid   := 0.00
		nImpRet     := 0.00
		nValIsen    := 0.00
		nValDev     := 0.00
		cObserv     := ""
		cCNPJ       := ""
		cRecISS	  := ""
		nBaseCalcT  := 0.00
		nImpIncidT  := 0.00
		nImpRetT    := 0.00
		nValIsenT   := 0.00
		nValDevT    := 0.00
		nSBaseCalcT := 0.00
		nSImpIncidT := 0.00
		nSImpRetT   := 0.00
		nSValIsenT  := 0.00
		nSValDevT   := 0.00
		aDia        := {}
		aApurI      := {0,0,0,0,0}
		aApurII     := {0,0,0,0,0}
		aApurIII    := {0,0,0,0,0}
		aTotMes     := {0,0,0,0,0}
		aResumo     := {}
		nTotImpDev  := 0.00  
		cNome	:=	SM0->M0_NOMECOM
		cInscr  :=	InscrEst()
		cEnd	:=	ALLTRIM(SM0->M0_ENDENT)
		cEnd	+= 	iif(len(ALLTRIM(SM0->M0_ENDENT))>0 .and. len(ALLTRIM(SM0->M0_BAIRENT))>0," - ","")
		cEnd	+=	ALLTRIM(SM0->M0_BAIRENT)
		cEnd	+=	iIf(len(cEnd)>0 .and. len(ALLTRIM(SM0->M0_CIDENT))>0," - ","")
		cEnd	+=	ALLTRIM(SM0->M0_CIDENT)
		cEnd	+=	iIf(len(cEnd)>0 .AND. len(ALLTRIM(SM0->M0_ESTENT))>0,"/","")
		cEnd	+=	ALLTRIM(SM0->M0_ESTENT)
		cCGC	:=	TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99")
		cCCM	:=	mv_par07
		cCodISS := ""
		cNproc  := mv_par12
		cFilSF3	:= "('"+aFilAtiv[nForFilial,2]+"')" 
		cFilSF6	:= "('"+aFilAtiv[nForFilial,3]+"')"
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Indice Condicional                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea('SF3')	

	#IFDEF TOP
	If TcSrvType()<>"AS/400"
		lQuery := .T.
		cAliasSF3 := "TF3"		
		aStru  := SF3->(dbStruct())
			cQuery := "SELECT F3_ENTRADA,F3_DTCANC,F3_CODISS,F3_ALIQICM,F3_NFISCAL,F3_SERIE, F3_BASEICM,F3_ISENICM,F3_OUTRICM,F3_FORMULA,"
			cQuery += "F3_OBSERV,F3_CLIEFOR,F3_LOJA,F3_TIPO,F3_CFO,F3_ESPECIE,F3_FILIAL,F3_NRLIVRO,F3_VALICM,F3_NFELETR,R_E_C_N_O_ SF3RECNO,F3_IDENTFT"

		If lF3_Reciss
			cQuery += ", F3_RECISS "
		EndIf

	 	If lMapResumo
	 		aCposTemp := MaXRCposQry(cQuery)
	 	EndIf

		cQuery += "FROM "+RetSqlName("SF3")+" "
			cQuery += "WHERE F3_FILIAL IN "+cFilSF3+" AND "
		cQuery += "(F3_TIPO = 'S' OR (F3_TIPO = 'L' AND "
		cQuery += "F3_CODISS <> '" + SPACE(LEN(F3_CODISS)) + "'))  AND "
		cQuery += "F3_CFO >'5"+SPACE(LEN(F3_CFO)-1)+"'AND "
			cQuery += "F3_ENTRADA BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' AND "
		If mv_par06<>"*"
			cQuery	+=	"F3_NRLIVRO='"+mv_par06+"' AND "
		EndIf
		cQuery += "D_E_L_E_T_ = ' ' "
		CQuery += "ORDER BY F3_CODISS,F3_ENTRADA,F3_SERIE,F3_NFISCAL,F3_ALIQICM"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)
		For nX := 1 To len(aStru)
			If aStru[nX][2] <> "C" .And. FieldPos(aStru[nX][1])<>0
				TcSetField(cAliasSF3,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
			EndIf
		Next nX
		dbSelectArea(cAliasSF3)	
	Else

	#ENDIF

		cArqInd	:=	CriaTrab(NIL,.F.)
		cChave	:=	"F3_CODISS+DTOS(F3_ENTRADA)+F3_SERIE+F3_NFISCAL+STR(F3_ALIQICM)"
		cFiltro :=  " F3_FILIAL $ "+cFilSF3+" .AND. ( F3_TIPO=='S' .OR. (F3_TIPO=='L' .AND. F3_CODISS<>'"+Space (Len (SF3->F3_CODISS))+"'))"
		cFiltro	+=	" .AND. F3_CFO >='5'"
		cFiltro	+=	" .AND. dtos(F3_ENTRADA) >='"+dtos(mv_par01)+"' .and. dtos(F3_ENTRADA)<='"+dtos(mv_par02)+"'"
	
		If mv_par06<>"*"
			cFiltro	+=	".AND.F3_NRLIVRO=='"+mv_par06+"'"
		EndIf
	
		If lMapResumo
			cFiltro	+=	" .AND. Alltrim(F3_ESPECIE) <> 'CF' "
		EndIf
	
		IndRegua(cAliasSF3,cArqInd,cChave,,cFiltro,"Selecionando Registros...")
	
		#IFNDEF TOP
			DbSetIndex(cArqInd+OrdBagExt())
		#ENDIF
	
		(cAliasSF3)->(dbGotop())
		SetRegua(LastRec())

	#IFDEF TOP
	EndIf
	#ENDIF

	R990LayOut(@aLay)


//³Inclui informacoes do Mapa Resumo³
If lMapResumo
		cChave			:=	"F3_CODISS+DTOS(F3_ENTRADA)+F3_FILIAL+F3_SERIE+F3_NFISCAL+STR(F3_ALIQICM)"
	cArqBkpQry 		:= 	cAliasSf3

		// Processar para todas as filiais selecionadas
		If lAglFil
			cFilBack	:= cFilAnt
			For nPosFil := 1 to Len(aFilAtiv)
				cFilAnt	:= aFilAtiv[nPosFil,1]
				aMapaResumo		:= MaxRMapRes( MV_PAR01, MV_PAR02, aMapaResumo )
				aGravaMapRes	:= 	MaXRAgrupF3(/*cFilAnt*/,aMapaResumo,"MATR990")
			Next
			cFilAnt	:= cFilBack
		Else
			aMapaResumo		:= MaxRMapRes( MV_PAR01, MV_PAR02 )
			aGravaMapRes	:= MaXRAgrupF3(/*cFilAnt*/,aMapaResumo,"MATR914")
		EndIf			
		cArqTmpMP		:= 	MaXRExecArq(1)
		cAliasSf3		:= MaXRAddArq(	1, cArqTmpMP, cAliasSf3, aCposTemp, aGravaMapRes, cChave )
	EndIf

	// Posiciona arquivos para uso no loop
	SA1->(dbSetOrder(1))
	SA2->(dbSetOrder(2))
	SF2->(dbSetOrder(1))
	SFT->(dbSetOrder(3))   
	SD1->(dbSetOrder(1))
	SD2->(dbSetOrder(3))
	SF4->(dbSetOrder(1))

While !(cAliasSF3)->(Eof())
	
	nLin      := 0
	nMes      := Month((cAliasSF3)->F3_ENTRADA)
	nMesRec   := Month((cAliasSF3)->F3_ENTRADA)	
	cMesAno   := (MesExtenso(Month((cAliasSF3)->F3_ENTRADA)))+"/"+STRZERO(year((cAliasSF3)->F3_ENTRADA),4)
	cCodISS   := (cAliasSF3)->F3_CODISS
	
	lHouveMov := .T.
	
	If !lQuery
		IncRegua()
	Endif

	If Interrupcao(@lEnd)
		Exit
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Considera filtro do usuario                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If !Empty(cFilterUser)
		If (cAliasSF3)->(!(&cFilterUser))
			(cAliasSF3)->(DbSkip ())
			Loop
		EndIf
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cabecalho                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If ( nLin > 60 .Or. nLin == 0 )
		lResumo := .F.
		nFeixe++
		CabM51(@nLin,aLay,@nPagina,cNome,cInscr,cCCM,cEnd,cMesAno,cCodISS,lResumo,cNproc,@nFeixe)
	EndIf
	// FAZ O TRATAMENTO PARA IMPRESSAO DO TOTALIZADOR POR DIA QDO OS LANCAMENTOS DIARIOS SAO LANCADOS NA PAGINA ANTERIOR  
	If (cDFim <> StrZero(Day((cAliasSF3)->F3_ENTRADA),2) .AND. cDFim <> "" .AND. nMFim == Month((cAliasSF3)->F3_ENTRADA))  .OR. cCodISS <> (cAliasSF3)->F3_CODISS .Or. nMes<>Month((cAliasSF3)->F3_ENTRADA)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Armazena Totais Diarios                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AADD(aDia,{cDia,nBaseCalcT,nImpIncidT,nImpRetT,nValIsenT,nValDevT})

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Armazena Totais Decendiais ou Quinzenais                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nApuracao == 1
				If nDia <= 10
					aApurI := {aApurI[1]+nBaseCalcT,aApurI[2]+nImpIncidT,aApurI[3]+nImpRetT,aApurI[4]+nValIsenT,aApurI[5]+nValDevT}
				ElseIf nDia >= 11 .AND. nDia <= 20
					aApurII := {aApurII[1]+nBaseCalcT,aApurII[2]+nImpIncidT,aApurII[3]+nImpRetT,aApurII[4]+nValIsenT,aApurII[5]+nValDevT}
				ElseIf nDia >= 21
					aApurIII := {aApurIII[1]+nBaseCalcT,aApurIII[2]+nImpIncidT,aApurIII[3]+nImpRetT,aApurIII[4]+nValIsenT,aApurIII[5]+nValDevT}
				EndIf
			ElseIf nApuracao == 2
				If nDia <= 15
					aApurI := {aApurI[1]+nBaseCalcT,aApurI[2]+nImpIncidT,aApurI[3]+nImpRetT,aApurI[4]+nValIsenT,aApurI[5]+nValDevT}
				ElseIf nDia >= 16
					aApurII := {aApurII[1]+nBaseCalcT,aApurII[2]+nImpIncidT,aApurII[3]+nImpRetT,aApurII[4]+nValIsenT,aApurII[5]+nValDevT}
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Armazena Totais Mensais                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aTotMes := {aTotMes[1]+nBaseCalcT,aTotMes[2]+nImpIncidT,aTotMes[3]+nImpRetT,aTotMes[4]+nValIsenT,aTotMes[5]+nValDevT}
           
	   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Controle de fim de pagina                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nLin >= 57  .or. (mv_par08 == 1 .And. nLin >= 50) 
				If cCodISS == (cAliasSF3)->F3_CODISS
					lMudouPag := .T.
				EndIf
				If nLin == 58
					FmtLin(,aLay[16],,,@nLin)
					If !lMudouPag
						FmtLin({TransForm(aTotMes[1],"@e 9,999,999,999.99"),TransForm(aTotMes[2],"@e 99,999,999.99"),TransForm(aTotMes[3],"@e 99,999,999.99"),TransForm(aTotMes[4],"@e 99,999,999.99"),TransForm(aTotMes[5],"@e 99,999,999.99")},aLay[17],,,@nLin)
					Else
						FmtLin({TransForm(nSBaseCalcT,"@e 9,999,999,999.99"),TransForm(nSImpIncidT,"@e 99,999,999.99"),TransForm(nSImpRetT,"@e 99,999,999.99"),TransForm(nSValIsenT,"@e 999,999,999.99"),TransForm(nSValDevT,"@e 999,999,999.99")},aLay[27],,,@nLin)
						lMudouPag := .F.
					EndIf
					FmtLin(,aLay[18],,,@nLin)
				EndIf
				nLin:= 0
				nFeixe++
				CabM51(@nLin,aLay,@nPagina,cNome,cInscr,cCCM,cEnd,cMesAno,cCodISS,lResumo,cNproc,@nFeixe)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Imprime Totais Diarios                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If mv_par08 == 1  
					FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
				FmtLin({TransForm(aDia[nNumDia][1],"@e 99"),Transform((aDia[nNumDia][2]),"@e 9,999,999,999.99"),TransForm((aDia[nNumDia][3]),"@e 99,999,999.99"),TransForm((aDia[nNumDia][4]),"@e 99,999,999.99"),TransForm((aDia[nNumDia][5]),"@e 99,999,999.99"),TransForm((aDia[nNumDia][6]),"@e 99,999,999.99")},aLay[26],,,@nLin)
					FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)

			ElseIf nApuracao <> 3

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Imprime Totais Decendiais ou Quinzenais                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If nApuracao == 1
					If aApurI[1]+aApurI[2]+aApurI[3]+aApurI[4]+aApurI[5] > 0 .AND. lApurI
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						FmtLin({TransForm(aApurI[1],"@e 9,999,999,999.99"),TransForm(aApurI[2],"@e 99,999,999.99"),TransForm(aApurI[3],"@e 99,999,999.99"),TransForm(aApurI[4],"@e 99,999,999.99"),TransForm(aApurI[5],"@e 99,999,999.99")},aLay[29],,,@nLin)
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						aApurI   := {0,0,0,0,0}
					EndIf
					If aApurII[1]+aApurII[2]+aApurII[3]+aApurII[4]+aApurII[5] > 0 .AND. lApurII
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						FmtLin({TransForm(aApurII[1],"@e 9,999,999,999.99"),TransForm(aApurII[2],"@e 99,999,999.99"),TransForm(aApurII[3],"@e 99,999,999.99"),TransForm(aApurII[4],"@e 99,999,999.99"),TransForm(aApurII[5],"@e 99,999,999.99")},aLay[30],,,@nLin)
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						aApurII  := {0,0,0,0,0}
					EndIf
					If aApurIII[1]+aApurIII[2]+aApurIII[3]+aApurIII[4]+aApurIII[5] > 0 .AND. lApurIII
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						FmtLin({TransForm(aApurIII[1],"@e 9,999,999,999.99"),TransForm(aApurIII[2],"@e 99,999,999.99"),TransForm(aApurIII[3],"@e 99,999,999.99"),TransForm(aApurIII[4],"@e 99,999,999.99"),TransForm(aApurIII[5],"@e 99,999,999.99")},aLay[31],,,@nLin)
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						aApurIII   := {0,0,0,0,0}
					EndIf
				Else
					If aApurI[1]+aApurI[2]+aApurI[3]+aApurI[4]+aApurI[5] > 0 .AND. lApurI
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						FmtLin({TransForm(aApurI[1],"@e 9,999,999,999.99"),TransForm(aApurI[2],"@e 99,999,999.99"),TransForm(aApurI[3],"@e 99,999,999.99"),TransForm(aApurI[4],"@e 99,999,999.99"),TransForm(aApurI[5],"@e 99,999,999.99")},aLay[32],,,@nLin)
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						aApurI   := {0,0,0,0,0}
					EndIf
					If aApurII[1]+aApurII[2]+aApurII[3]+aApurII[4]+aApurII[5] > 0 .AND. lApurII
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						FmtLin({TransForm(aApurII[1],"@e 9,999,999,999.99"),TransForm(aApurII[2],"@e 99,999,999.99"),TransForm(aApurII[3],"@e 99,999,999.99"),TransForm(aApurII[4],"@e 99,999,999.99"),TransForm(aApurII[5],"@e 99,999,999.99")},aLay[33],,,@nLin)
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						aApurII  := {0,0,0,0,0}
					EndIf
				EndIf
			EndIf
			cDia := StrZero(Day((cAliasSF3)->F3_ENTRADA),2)
			nNumDia    += 1
			nBaseCalcT  := 0.00
			nImpIncidT  := 0.00
			nImpRetT    := 0.00
			nValIsenT   := 0.00
			nValDevT    := 0.00
		EndIf


		#IFDEF TOP
			SF3->(dbSetOrder(4))
		#ENDIF

		While !((cAliasSF3)->(Eof())) .And. cCodISS == (cAliasSF3)->F3_CODISS .AND. nMes==Month((cAliasSF3)->F3_ENTRADA) .And. nLin <= 57

			#IFDEF TOP
				SF3->(dbSeek((cAliasSF3)->F3_FILIAL+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
			#ENDIF
		
			cTipoMov:=  Iif(Substr((cAliasSF3)->F3_CFO,1,1) >= "5","S","E")
			cF4FRetISS := ""
			cA1FRetISS := ""
			
			If cTipoMov == "S"
				
				If SFT->(dbSeek(xFilial("SF3")+cTipoMov+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_IDENTFT))			
					If SD2->(DbSeek(xFilial("SD2")+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_PRODUTO+SFT->FT_ITEM))
						If SF4->(MsSeek(xFilial("SF4")+SD2->D2_TES))
							cF4FRetISS	:=	SF4->F4_FRETISS
				     	EndIf
					EndIf		
				EndIf
				
				If SA1->(MsSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
					cA1FRetISS := SA1->A1_FRETISS	
				EndIf
				
			EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Considera filtro do usuario                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cFilterUser)
		 //	If lQuery
		  //		SF3->(MsGoto((cAliasSF3)->SF3RECNO))
		  //	EndIf
			If SF3->(!(&cFilterUser))
				(cAliasSF3)->(DbSkip ())
				Loop
			EndIf
		Endif

		nDia := Day((cAliasSF3)->F3_ENTRADA)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Armazena e Totaliza as Informacoes                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty((cAliasSF3)->F3_dtcanc)

			cCNPJ		:= Mtr990Cnpj( (cAliasSF3)->F3_CLIEFOR, (cAliasSF3)->F3_LOJA, (cAliasSF3)->F3_TIPO, (cAliasSF3)->F3_CFO)

			If (lF3_Reciss) .And. !Empty  ((cAliasSF3)->F3_RECISS)
				cRecIss :=If((cAliasSF3)->F3_RECISS$"12",If((cAliasSF3)->F3_RECISS=="1","S","N"),(cAliasSF3)->F3_RECISS)
			Else
				cRecIss	:= Mtr990ISS( (cAliasSF3)->F3_CLIEFOR, (cAliasSF3)->F3_LOJA, (cAliasSF3)->F3_TIPO, (cAliasSF3)->F3_CFO)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Para o municipio de Joinville/SC, caso o movimento seja classificado  ³
			//³como ISSQN retido:                                                    ³
			//³ENTRADAS: somente devera ser apresentado no relatorio                 ³
			//³          se o valor realmente tiver sido retido, ou seja,            ³
			//³          caso o valor do ISSQN seja maior que o contido              ³
			//³          no parametro MV_VRETISS                                     ³
			//³SAIDAS:   Quando o valor do ISSQN nao alcancar o minimo               ³
			//³          para retencao (definido no parametro MV_VRETISS),           ³
			//³          devera ser lancado como imposto a pagar, visto que e        ³
			//³          dispensada a retencao de valores menores que R$ 25,00       ³
			//³          para quem esta adquirindo o servico.                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lJoiSC .And. (cAliasSF3)->F3_VALICM < nMinRetISS              
				If cRecIss == "S"
					cRecIss := "N"
				Endif
			Endif
			
			cDia         := StrZero(Day((cAliasSF3)->F3_ENTRADA),2)
			nSerie       := (cAliasSF3)->F3_SERIE
	   		
	   		If (SF3->(FieldPos("F3_NFELETR")) > 0  .and. !Empty((cAliasSF3)->F3_NFELETR))
				nNumNota:= (cAliasSF3)->F3_NFELETR
			Else
				nNumNota:= (cAliasSF3)->F3_NFISCAL
			EndIf
		 	
		 	nBaseCalc    := (cAliasSF3)->F3_BASEICM
			nAliq        := (cAliasSF3)->F3_ALIQICM
			
			// Adicionado tratamento para opcoes "Sempre Retem" no Cliente e TES
			// Condição conforme MATXFIS, funcão MaFisVTot.
			If cRecIss == "S" .And.	((cAliasSF3)->F3_VALICM >= nMinRetISS .Or. (cF4FRetISS == "2" .And. cA1FRetISS == "2")) 
				nImpRet   := (cAliasSF3)->F3_VALICM
				nImpIncid := 0.00
			Else
				nImpRet   := 0.00
				nImpIncid := IIF(subs((cAliasSF3)->F3_CFO,1,1)>="5",(cAliasSF3)->F3_VALICM,0.00)
			EndIf
				
			nValIsen     := (cAliasSF3)->F3_ISENICM
			nValDev      := (cAliasSF3)->F3_OUTRICM
			cObserv      := Alltrim(IIF (!Empty((cAliasSF3)->F3_FORMULA),Formula((cAliasSF3)->F3_FORMULA),(cAliasSF3)->F3_OBSERV))	
			nBaseCalcT   += (cAliasSF3)->F3_BASEICM
			
			// Adicionado tratamento para opcoes "Sempre Retem" no Cliente e TES
			// Condição conforme MATXFIS, funcão MaFisVTot.
			If cRecIss == "S" .And.	((cAliasSF3)->F3_VALICM >= nMinRetISS .Or. (cF4FRetISS == "2" .And. cA1FRetISS == "2")) 
				nImpIncidT   += 0.00
				nImpRetT     += (cAliasSF3)->F3_VALICM
				nSImpIncidT  += 0.00
				nSImpRetT    += (cAliasSF3)->F3_VALICM
			Else
				nImpIncidT   += IIF(subs((cAliasSF3)->F3_CFO,1,1)>="5",(cAliasSF3)->F3_VALICM,0.00)
				nImpRetT     += 0.00
				nSImpIncidT  += IIF(subs((cAliasSF3)->F3_CFO,1,1)>="5",(cAliasSF3)->F3_VALICM,0.00)
				nSImpRetT    += 0.00
			EndIf
			
			nValIsenT    += (cAliasSF3)->F3_ISENICM
			nValDevT     += (cAliasSF3)->F3_OUTRICM
			nSBaseCalcT  += (cAliasSF3)->F3_BASEICM
			nSValIsenT   += (cAliasSF3)->F3_ISENICM
			nSValDevT    += (cAliasSF3)->F3_OUTRICM

		Else

			cCNPJ		 := Mtr990Cnpj( (cAliasSF3)->F3_CLIEFOR, (cAliasSF3)->F3_LOJA, (cAliasSF3)->F3_TIPO, (cAliasSF3)->F3_CFO)
			
			cDia         := StrZero(Day((cAliasSF3)->F3_ENTRADA),2)
			nSerie       := (cAliasSF3)->F3_SERIE
			
		   	If (SF3->(FieldPos("F3_NFELETR")) > 0  .and. !Empty((cAliasSF3)->F3_NFELETR))
				nNumNota:= (cAliasSF3)->F3_NFELETR
			Else
				nNumNota:= (cAliasSF3)->F3_NFISCAL
			EndIf
			
			nBaseCalc    := 0.00
			nAliq        := 0.00
			nImpIncid    := 0.00
			nImpRet      := 0.00
			nValIsen     := 0.00
			nValDev      := 0.00
			cObserv      := Alltrim((cAliasSF3)->F3_OBSERV)

			nBaseCalcT   += 0.00
			nImpIncidT   += 0.00
			nImpRetT     += 0.00
			nValIsenT    += 0.00
			nValDevT     += 0.00

			nSImpIncidT  += 0.00
			nSImpRetT    += 0.00
			nSBaseCalcT  += 0.00
			nSValIsenT   += 0.00
			nSValDevT    += 0.00

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime as Informacoes                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If mv_par11 == 1 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para quebra de linha qdo o campo obs for muito extenso ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			cObserv:= Iif(!Empty(cObserv),cObserv," ")
		//	nlinha := Mlcount(cObserv,30)
			nlinha := Mlcount(cObserv,27)
		    For nZ := 1 To nLinha 
		    //	nTam:= Iif(nZ=1,30,(nZ-1)*30)
		    	nTam:= Iif(nZ=1,27,(nZ-1)*27)
		    	If nLin == 58 .And. nZ<=nLinha  
		       		lControle := .T.  
			   		cDFim := StrZero(Day((cAliasSF3)->F3_ENTRADA),2) 
		   			nMFim := Month((cAliasSF3)->F3_ENTRADA)
					Exit
				EndIf
				If nZ == 1 
					//Imprime a primeira linha com todos s campos
					FmtLin({cDia,nSerie,nNumNota,TransForm(nBaseCalc,"@e 9,999,999,999.99"),Transform(nAliq,"@e 99.99"),TransForm(nImpIncid,"@e 99,999,999.99"),TransForm(nImpRet,"@e 99,999,999.99"),TransForm(nValisen,"@e 99,999,999.99"),TransForm(nValDev,"@e 99,999,999.99"),Substr(cObserv,1,nTam)},aLay[15],,,@nLin)
		   		Else
					FmtLin({"","","","","","","","","",Substr(cObserv,nTam+1,30)},aLay[15],,,@nLin)					
				Endif					
		    Next nZ
		Else
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para quebra de linha qdo o campo obs for muito extenso ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			cObserv:= Iif(!Empty(cObserv),cObserv," ")
			nlinha := Mlcount(cObserv,74)
		    For nZ := 1 To nLinha 
		    	nTam:= Iif(nZ=1,74,(nZ-1)*74)
		    	If nLin == 58 .And. nZ<=nLinha  
		       		lControle := .T.  
			   		cDFim := StrZero(Day((cAliasSF3)->F3_ENTRADA),2) 
		   			nMFim := Month((cAliasSF3)->F3_ENTRADA)
				  	Exit
				EndIf
				If nZ == 1 
					//Imprime a primeira linha com todos os campos
			        FmtLin({cDia,nSerie,nNumNota,cCNPJ,TransForm(nBaseCalc,"@e 9,999,999,999.99"),Transform(nAliq,"@e 99.99"),TransForm(nImpIncid,"@e 99,999,999.99"),TransForm(nImpRet,"@e 99,999,999.99"),TransForm(nValisen,"@e 99,999,999.99"),TransForm(nValDev,"@e 99,999,999.99"),Substr(cObserv,1,nTam)},aLay[15],,,@nLin)
				Else
					FmtLin({"","","","","","","","","","",Substr(cObserv,nTam+1,74)},aLay[15],,,@nLin)					
				Endif					
		    Next nZ
			
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Armazena Valores para Resumo por Aliquota                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If (nAliq <> 0 .And. cRecIss <> "S") .Or. nImpIncid > 0
			nPos :=Ascan(aResumo,{|x|x[2]==nAliq})
			If nPos==0
				AADD(aResumo,{nBaseCalc,nAliq,nImpIncid})
				nNumAliq     += 1
			Else
				aResumo[nPos,1] +=nBaseCalc
				aResumo[nPos,3] +=nImpIncid
			Endif
		EndIf

		If nLin == 58 .And. nZ<>nlinha
			lControle := .T.  
			cDFim := StrZero(Day((cAliasSF3)->F3_ENTRADA),2) 
			nMFim := Month((cAliasSF3)->F3_ENTRADA)
			(cAliasSF3)->(DbSkip())
			Exit
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Faz a Impressao do registro na proxima pagina                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nLin == 58
				FmtLin(,aLay[16],,,@nLin)
				If nMes <> Month((cAliasSF3)->F3_ENTRADA) //.Or. cCodISS == (cAliasSF3)->F3_CODISS
					FmtLin({TransForm(aTotMes[1],"@e 9,999,999,999.99"),TransForm(aTotMes[2],"@e 99,999,999.99"),TransForm(aTotMes[3],"@e 99,999,999.99"),TransForm(aTotMes[4],"@e 99,999,999.99"),TransForm(aTotMes[5],"@e 99,999,999.99")},aLay[17],,,@nLin)
				Else
					FmtLin({TransForm(nSBaseCalcT,"@e 9,999,999,999.99"),TransForm(nSImpIncidT,"@e 99,999,999.99"),TransForm(nSImpRetT,"@e 99,999,999.99"),TransForm(nSValIsenT,"@e 999,999,999.99"),TransForm(nSValDevT,"@e 999,999,999.99")},aLay[27],,,@nLin)
					lMudouPag := .F.
				EndIf
				FmtLin(,aLay[18],,,@nLin)
				nLin:= 0
				nFeixe++
				CabM51(@nLin,aLay,@nPagina,cNome,cInscr,cCCM,cEnd,cMesAno,cCodISS,lResumo,cNproc,@nFeixe) 
    			
    			If mv_par11 == 1
    			   If nZ == 1 
						//Imprime a primeira linha com todos s campos
    			   		FmtLin({cDia,nSerie,nNumNota,TransForm(nBaseCalc,"@e 9,999,999,999.99"),Transform(nAliq,"@e 99.99"),TransForm(nImpIncid,"@e 99,999,999.99"),TransForm(nImpRet,"@e 99,999,999.99"),TransForm(nValisen,"@e 99,999,999.99"),TransForm(nValDev,"@e 99,999,999.99"),Substr(cObserv,1,nTam)},aLay[15],,,@nLin)  
    				Else  
						FmtLin({"","","","","","","","","","",Substr(cObserv,nTam+1,74)},aLay[15],,,@nLin)					
					Endif					
    			Else          
    				If nZ == 1 
	    		   		FmtLin({cDia,nSerie,nNumNota,cCNPJ,TransForm(nBaseCalc,"@e 9,999,999,999.99"),Transform(nAliq,"@e 99.99"),TransForm(nImpIncid,"@e 99,999,999.99"),TransForm(nImpRet,"@e 99,999,999.99"),TransForm(nValisen,"@e 99,999,999.99"),TransForm(nValDev,"@e 99,999,999.99"),Substr(cObserv,1,nTam)},aLay[15],,,@nLin)
		    		Else
			    		FmtLin({"","","","","","","","","","",Substr(cObserv,nTam+1,74)},aLay[15],,,@nLin)					
					Endif					
	    		Endif  
	    			
 			EndIf
		EndIf

		(cAliasSF3)->(DbSkip())
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³O While abaixo tem como finalidade caso a rotina possua filtro, garantir que os totalizadores finais sejam gerados com valores.          ³
		//³Ocorria que quando possuiamos 3 notas ficais de prestacao de servico no mesmo periodo para o mesmo produto/cliente com series diferentes,³
		//³ e emitissemos o relatorio utilizando filtro para gerar somente 2 dessas 3 notas, os totalizadores sairiam zerados.                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Do While !(cAliasSF3)->(Eof ())
			If !(Empty (cFilterUser))
		  //		If (lQuery)
		  //			SF3->(MsGoto ((cAliasSF3)->SF3RECNO))
		  //		EndIf
				If SF3->(!(&cFilterUser))
					(cAliasSF3)->(DbSkip ())
					Loop
				Else
					Exit
				EndIf
			Else
				Exit
			EndIf
			//
			(cAliasSF3)->(DbSkip ())
		EndDo
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Controle do periodo da Apuracao                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If nApuracao == 1
			IF Day((cAliasSF3)->F3_ENTRADA) >= 11 .OR. (cCodISS <> (cAliasSF3)->F3_CODISS) .Or. nMes<>Month((cAliasSF3)->F3_ENTRADA)
				lApurI   := .T.
			EndIf
			If Day((cAliasSF3)->F3_ENTRADA) >= 21 .OR. (cCodISS <> (cAliasSF3)->F3_CODISS) .Or. nMes<>Month((cAliasSF3)->F3_ENTRADA)
				lApurII  := .T.
			EndIf
			If cCodISS <> (cAliasSF3)->F3_CODISS .Or. nMes<>Month((cAliasSF3)->F3_ENTRADA)
				lApurIII := .T.
			EndIF
		EndIf
		
		If nApuracao == 2
			IF Day((cAliasSF3)->F3_ENTRADA) >= 16 .OR. (cCodISS <> (cAliasSF3)->F3_CODISS) .Or. nMes<>Month((cAliasSF3)->F3_ENTRADA)
				lApurI   := .T.
			EndIf
			If cCodISS <> (cAliasSF3)->F3_CODISS .Or. nMes<>Month((cAliasSF3)->F3_ENTRADA)
				lApurII  := .T.
			EndIF
		EndIf

		If cDia <> StrZero(Day((cAliasSF3)->F3_ENTRADA),2) .OR. cCodISS <> (cAliasSF3)->F3_CODISS .Or. nMes<>Month((cAliasSF3)->F3_ENTRADA)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Armazena Totais Diarios                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AADD(aDia,{cDia,nBaseCalcT,nImpIncidT,nImpRetT,nValIsenT,nValDevT})

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Armazena Totais Decendiais ou Quinzenais                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nApuracao == 1
				If nDia <= 10
					aApurI := {aApurI[1]+nBaseCalcT,aApurI[2]+nImpIncidT,aApurI[3]+nImpRetT,aApurI[4]+nValIsenT,aApurI[5]+nValDevT}
				ElseIf nDia >= 11 .AND. nDia <= 20
					aApurII := {aApurII[1]+nBaseCalcT,aApurII[2]+nImpIncidT,aApurII[3]+nImpRetT,aApurII[4]+nValIsenT,aApurII[5]+nValDevT}
				ElseIf nDia >= 21
					aApurIII := {aApurIII[1]+nBaseCalcT,aApurIII[2]+nImpIncidT,aApurIII[3]+nImpRetT,aApurIII[4]+nValIsenT,aApurIII[5]+nValDevT}
				EndIf
			ElseIf nApuracao == 2
				If nDia <= 15
					aApurI := {aApurI[1]+nBaseCalcT,aApurI[2]+nImpIncidT,aApurI[3]+nImpRetT,aApurI[4]+nValIsenT,aApurI[5]+nValDevT}
				ElseIf nDia >= 16
					aApurII := {aApurII[1]+nBaseCalcT,aApurII[2]+nImpIncidT,aApurII[3]+nImpRetT,aApurII[4]+nValIsenT,aApurII[5]+nValDevT}
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Armazena Totais Mensais                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aTotMes := {aTotMes[1]+nBaseCalcT,aTotMes[2]+nImpIncidT,aTotMes[3]+nImpRetT,aTotMes[4]+nValIsenT,aTotMes[5]+nValDevT}

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Controle de fim de pagina                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nLin >= 57   .or. (mv_par08 == 1 .And. nLin >= 50)
				While nLin <= 57
					FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
				EndDo
				If cCodISS == (cAliasSF3)->F3_CODISS
					lMudouPag := .T.
				EndIf
				If nLin == 58
					FmtLin(,aLay[16],,,@nLin)
					If !lMudouPag
						FmtLin({TransForm(aTotMes[1],"@e 9,999,999,999.99"),TransForm(aTotMes[2],"@e 99,999,999.99"),TransForm(aTotMes[3],"@e 99,999,999.99"),TransForm(aTotMes[4],"@e 99,999,999.99"),TransForm(aTotMes[5],"@e 99,999,999.99")},aLay[17],,,@nLin)
					Else
						FmtLin({TransForm(nSBaseCalcT,"@e 9,999,999,999.99"),TransForm(nSImpIncidT,"@e 99,999,999.99"),TransForm(nSImpRetT,"@e 99,999,999.99"),TransForm(nSValIsenT,"@e 999,999,999.99"),TransForm(nSValDevT,"@e 999,999,999.99")},aLay[27],,,@nLin)
						lMudouPag := .F.
					EndIf
					FmtLin(,aLay[18],,,@nLin)
				EndIf
				nLin:= 0
				nFeixe++
				CabM51(@nLin,aLay,@nPagina,cNome,cInscr,cCCM,cEnd,cMesAno,cCodISS,lResumo,cNproc,@nFeixe)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Imprime Totais Diarios                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If mv_par08 == 1
				FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
				FmtLin({TransForm(aDia[nNumDia][1],"@e 99"),Transform((aDia[nNumDia][2]),"@e 9,999,999,999.99"),TransForm((aDia[nNumDia][3]),"@e 99,999,999.99"),TransForm((aDia[nNumDia][4]),"@e 99,999,999.99"),TransForm((aDia[nNumDia][5]),"@e 99,999,999.99"),TransForm((aDia[nNumDia][6]),"@e 99,999,999.99")},aLay[26],,,@nLin)
				FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)

			ElseIf nApuracao <> 3

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Imprime Totais Decendiais ou Quinzenais                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If nApuracao == 1
					If aApurI[1]+aApurI[2]+aApurI[3]+aApurI[4]+aApurI[5] > 0 .AND. lApurI
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						FmtLin({TransForm(aApurI[1],"@e 9,999,999,999.99"),TransForm(aApurI[2],"@e 99,999,999.99"),TransForm(aApurI[3],"@e 99,999,999.99"),TransForm(aApurI[4],"@e 99,999,999.99"),TransForm(aApurI[5],"@e 99,999,999.99")},aLay[29],,,@nLin)
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						aApurI   := {0,0,0,0,0}
					EndIf
					If aApurII[1]+aApurII[2]+aApurII[3]+aApurII[4]+aApurII[5] > 0 .AND. lApurII
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						FmtLin({TransForm(aApurII[1],"@e 9,999,999,999.99"),TransForm(aApurII[2],"@e 99,999,999.99"),TransForm(aApurII[3],"@e 99,999,999.99"),TransForm(aApurII[4],"@e 99,999,999.99"),TransForm(aApurII[5],"@e 99,999,999.99")},aLay[30],,,@nLin)
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						aApurII  := {0,0,0,0,0}
					EndIf
					If aApurIII[1]+aApurIII[2]+aApurIII[3]+aApurIII[4]+aApurIII[5] > 0 .AND. lApurIII
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						FmtLin({TransForm(aApurIII[1],"@e 9,999,999,999.99"),TransForm(aApurIII[2],"@e 99,999,999.99"),TransForm(aApurIII[3],"@e 99,999,999.99"),TransForm(aApurIII[4],"@e 99,999,999.99"),TransForm(aApurIII[5],"@e 99,999,999.99")},aLay[31],,,@nLin)
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						aApurIII   := {0,0,0,0,0}
					EndIf
				Else
					If aApurI[1]+aApurI[2]+aApurI[3]+aApurI[4]+aApurI[5] > 0 .AND. lApurI
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						FmtLin({TransForm(aApurI[1],"@e 9,999,999,999.99"),TransForm(aApurI[2],"@e 9,999,999,999.99"),TransForm(aApurI[3],"@e 9,999,999,999.99"),TransForm(aApurI[4],"@e 9,999,999,999.99"),TransForm(aApurI[5],"@e 9,999,999,999.99")},aLay[32],,,@nLin)
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						aApurI   := {0,0,0,0,0}
					EndIf
					If aApurII[1]+aApurII[2]+aApurII[3]+aApurII[4]+aApurII[5] > 0 .AND. lApurII
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						FmtLin({TransForm(aApurII[1],"@e 9,999,999,999.99"),TransForm(aApurII[2],"@e 9,999,999,999.99"),TransForm(aApurII[3],"@e 9,999,999,999.99"),TransForm(aApurII[4],"@e 9,999,999,999.99"),TransForm(aApurII[5],"@e 9,999,999,999.99")},aLay[33],,,@nLin)
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						aApurII  := {0,0,0,0,0}
					EndIf
				EndIf
			EndIf
			cDia := StrZero(Day((cAliasSF3)->F3_ENTRADA),2)
			nNumDia    += 1
			nBaseCalcT  := 0.00
			nImpIncidT  := 0.00
			nImpRetT    := 0.00
			nValIsenT   := 0.00
			nValDevT    := 0.00
		EndIf
	EndDo
	lApurI    := .F.
	lApurII   := .F.
	lApurIII  := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime Total Mensal                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While nLin <= 57
		FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
	EndDo
	If nLin == 58
		FmtLin(,aLay[16],,,@nLin)
		If cCodISS == (cAliasSF3)->F3_CODISS
			// Para controlar a impressao de um mesmo codigo ISS em meses distintos
			If nMes <> Month((cAliasSF3)->F3_ENTRADA)
				lMudouPag := .F.
			Else
				lMudouPag := .T.
			Endif
		Else
			lMudouPag := .F.				
		EndIf		
		If !lMudouPag
			If lControle 
				aTotMes := {aTotMes[1]+nBaseCalcT,aTotMes[2]+nImpIncidT,aTotMes[3]+nImpRetT,aTotMes[4]+nValIsenT,aTotMes[5]+nValDevT}	
				nBaseCalcT	:= 0.00
				nImpIncidT	:= 0.00
				nImpRetT	:= 0.00
				nValIsenT	:= 0.00
				nValDevT	:= 0.00
				lControle	:= .F.
			Endif
			FmtLin({TransForm(aTotMes[1],"@e 9,999,999,999.99"),TransForm(aTotMes[2],"@e 99,999,999.99"),TransForm(aTotMes[3],"@e 99,999,999.99"),TransForm(aTotMes[4],"@e 99,999,999.99"),TransForm(aTotMes[5],"@e 99,999,999.99")},aLay[17],,,@nLin)
			aTotMes  := {0,0,0,0,0}
		Else
			FmtLin({TransForm(nSBaseCalcT,"@e 9,999,999,999.99"),TransForm(nSImpIncidT,"@e 99,999,999.99"),TransForm(nSImpRetT,"@e 99,999,999.99"),TransForm(nSValIsenT,"@e 999,999,999.99"),TransForm(nSValDevT,"@e 999,999,999.99")},aLay[27],,,@nLin)
			lMudouPag := .F.
		EndIf
		FmtLin(,aLay[18],,,@nLin)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime Resumo                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If cCodISS <> (cAliasSF3)->F3_CODISS
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando mudar o codigo de ISS, os totalizadores de saldo a transportar deverao ser zerados.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nSBaseCalcT	:= 0
		nSImpIncidT	:= 0
		nSImpRetT	:= 0
		nSValIsenT	:= 0
		nSValDevT	:= 0
		cCodISS 	:= ""
	
		If nMes <> Month((cAliasSF3)->F3_ENTRADA)
			lResumo := .T.
			nMes    := Month((cAliasSF3)->F3_ENTRADA)
			nLin    := 0
			@ nLin,000 Psay aValImp(Limite)
			nFeixe++
			CabM51(@nLin,aLay,@nPagina,cNome,cInscr,cCCM,cEnd,cMesAno,cCodISS,lResumo,cNproc,@nFeixe)
			FmtLin(,aLay[19],,,@nLin)
			FmtLin(,aLay[20],,,@nLin)
			FmtLin(,aLay[21],,,@nLin)
			FmtLin(,aLay[22],,,@nLin)
	
			ASort(aResumo,,,{|x,y|x[2]<y[2]})
	
			While nNumAliq >= nContrRes
				FmtLin({TransForm(aResumo[nContrRes][1],"@e 9,999,999,999.99"),Transform(aResumo[nContrRes][2],"@e 99.99"),TransForm(aResumo[nContrRes][3],"@e 9,999,999,999.99")},aLay[23],,,@nLin)
				nTotImpDev += aResumo[nContrRes][3]
				nContrRes  += 1
			EndDo
			FmtLin(,aLay[24],,,@nLin)
			FmtLin({TransForm(nTotImpDev,"@e 9,999,999,999.99")},aLay[39],,,@nLin)
			FmtLin(,aLay[24],,,@nLin)
			lResumo    := .F.
			nNumAliq   := 0
			nContrRes  := 1
			nTotImpDev := 0.00
			aResumo    := {}
	
			If mv_par10 == 1
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Guia de Recolhimentos                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				#IFDEF TOP
					If TcSrvType() <> "AS/400"
						cAliasSF6:= "GuiaSF6"
						lQuery    := .T.
						aStruSF6  := SF6->(dbStruct())		
						cQuery := "SELECT *"
						cQuery += "FROM "
						cQuery += RetSqlName("SF6") + " SF6 "
						cQuery += "WHERE "
							cQuery += "SF6.F6_FILIAL IN "+cFilSF6+" AND "
							cQuery += "SF6.F6_DTARREC BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"' AND "
						cQuery += "SF6.F6_TIPOIMP = '2' AND "
					    cQuery += "SF6.D_E_L_E_T_=' ' "
							cQuery += "Order BY SF6.F6_DTVENC,SF6.F6_FILIAL,SF6.F6_NUMERO"
						cQuery := ChangeQuery(cQuery)
	
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF6,.T.,.T.)
	
						For nSF6 := 1 To Len(aStruSF6)
							If aStruSF6[nSF6][2] <> "C" .and. FieldPos(aStruSF6[nSF6][1]) > 0
								TcSetField(cAliasSF6,aStruSF6[nSF6][1],aStruSF6[nSF6][2],aStruSF6[nSF6][3],aStruSF6[nSF6][4])
							EndIf
						Next nSF6
					Else
				#ENDIF  	
					cIndSF6	:=	CriaTrab(NIL,.F.)
					cChave	:=	"F6_FILIAL+Dtos(F6_DTVENC)+F6_NUMERO"
						cFiltro	:=	"SF6->F6_FILIAL $ '"+cFilSF6+"'"
					cFiltro	+=	" .And. Dtos(SF6->F6_DTARREC) >='"+Dtos(mv_par01)+"' .AND. Dtos(SF6->F6_DTARREC) <='"+Dtos(mv_par02)+"'"
					cFiltro	+=	" .And. SF6->F6_TIPOIMP=='2'"
					IndRegua(cAliasSF6,cIndSF6,cChave,,cFiltro)
					#IFDEF TOP
					EndIf
					#ENDIF	
	
				FmtLin(,aLay[34],,,@nLin)
				FmtLin(,aLay[35],,,@nLin)
				FmtLin(,aLay[36],,,@nLin)
				FmtLin(,aLay[37],,,@nLin)
	
					SA6->(dbSetOrder(1))
				While !(cAliasSF6)->(Eof())
	
					If nLin == 60
						FmtLin(,aLay[37],,,@nLin)
						nLin    := 0
						lResumo := .T.
						@ nLin,000 Psay aValImp(Limite)
						nFeixe++
						CabM51(@nLin,aLay,@nPagina,cNome,cInscr,cCCM,cEnd,cMesAno,cCodISS,lResumo,cNproc,@nFeixe)
						FmtLin(,aLay[34],,,@nLin)
						FmtLin(,aLay[35],,,@nLin)
						FmtLin(,aLay[36],,,@nLin)
						FmtLin(,aLay[37],,,@nLin)
					EndIf
	
					If nMesRec == (cAliasSF6)->F6_MESREF
							nPosFil := aScan( aFilAtiv, { |x| x[3]== (cAliasSF3)->F6_FILIAL } )
							If nPosFil > 0 .and. SF6->( MsSeek(xFilial("SA6")+(cAliasSF6)->F6_BANCO+(cAliasSF6)->F6_AGENCIA) )
							FmtLin({(cAliasSF6)->F6_NUMERO,(cAliasSF6)->F6_DTVENC,SA6->A6_COD+" "+SA6->A6_NREDUZ,Substr((cAliasSF6)->F6_OBSERV,1,30)},aLay[38],,,@nLin)
						EndIf
					EndIf
					(cAliasSF6)->(dbSkip())
	
				EndDo
				FmtLin(,aLay[37],,,@nLin)
				nLin := 0
				lResumo := .F.
				If lQuery
					dbSelectArea(cAliasSF6)
					dbCloseArea()
				EndIf
					SF6->( RetIndex("SF6") )
			EndIf
			
		EndIf
		
	EndIf
	
EndDo

//³Exclui o arquivo temporario³
If lMapResumo
	MaXRExecArq(2,cArqTmpMP)
	cAliasSf3 := cArqBkpQry
	DbSelectArea(cAliasSF3)
EndIf		

//³ Imprime informacao que nao houve movimento                   ³
If !lHouveMov
	nlin    := 0
	cCodIss := ""
	cMesAno := (MesExtenso(Month(mv_par02)))+"/"+STRZERO(year(mv_par02),4)
	nFeixe++
	CabM51(@nLin,aLay,@nPagina,cNome,cInscr,cCCM,cEnd,cMesAno,cCodISS,lResumo,cNproc,@nFeixe)
	FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
	FmtLin(,aLay[40],,,@nLin)
	While nLin <= 57
		FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
	EndDo
	FmtLin(,aLay[16],,,@nLin)
	FmtLin({TransForm(aTotMes[1],"@e 9,999,999,999.99"),TransForm(aTotMes[2],"@e 99,999,999.99"),TransForm(aTotMes[3],"@e 99,999,999.99"),TransForm(aTotMes[4],"@e 99,999,999.99"),TransForm(aTotMes[5],"@e 99,999,999.99")},aLay[17],,,@nLin)
	FmtLin(,aLay[18],,,@nLin)
EndIf

RetIndex("SF3")
	SF3->(dbSetOrder(1))
	SF3->(dbClearFilter())

	If lImpTermos .and. !lEnd
	R990ImpTerm(cPerg)
EndIf

If lQuery
	dbSelectArea(cAliasSF3)
	dbCloseArea()
EndIf
	If lAglFil
		Exit
	EndIf
	
Next
	
cFilAnt	:= cFilBack
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcion   ³R990LayOut³ Autor ³ Thiago Galvao Silveira³ Data ³ 13/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ LayOut do Registro de Apuração do ISS Modelo 51 e Modelo 3 ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R990LayOut(aLay)

	Local cEstad := GetMv("MV_ESTADO")
	
	If mv_par11==1 // Modelo 51 - 132 colunas (Sem CNPJ)
	
		aLay[01] := "+----------------------------------------------------------------------------------------------------------------------------------+"
		aLay[02] := "| REGISTRO DE NOTAS FISCAIS DE SERVICOS PRESTADOS (mod.51)                                                              FOLHA #####|"
		If cEstad == "GO"
			aLay[02] := "| LIVRO REGISTRO DE PRESTAÇÃO DE SERVIÇOS  - Modelo 1                                                                   FOLHA #####|"
		EndIf
		aLay[03] := "| IMPOSTO SOBRE SERVICOS                                                                                                           |"
		If Empty(mv_par12)
			aLay[04] := "|                                                                                                                                  |"
		Else
			aLay[04] := "| REGIME ESPECIAL AUTORIZADO PELO PROCESSO No. ##################                                                                  |"
		Endif
		aLay[05] := "| ###############################################                                                   +----------------+-------------+"
		aLay[06] := "| C.N.P.J.: ##################                                                                      |   Incidência   |Cód Serviço  |"
		aLay[07] := "| I.E.: ############## C.C.M.: ##################                                                   +----------------+-------------+"
		aLay[08] := "| ###############################################                                                   |############### |############ |"
		aLay[09] := "+-------------------+------------------------------------------------+---------------+--------------+----------------+-------------+"
		aLay[10] := "|  NOTA FISCAL      |                 SERIES 'A' E 'E'               |   SERIE 'C'   |  SERIE 'D'   |                              |"
		aLay[11] := "|  DE SERVICO       +--------------+-----+-------------+-------------+---------------+--------------+------------------------------+"
		aLay[12] := "+---+-----+---------+   BASE DE    |ALI- |   IMPOSTO   |   IMPOSTO   |ISENTAS OU     |  REMESSA OU  |                              |"
		aLay[13] := "|DIA|SERIE| NUMERO  |   CALCULO    |QUOTA|   DEVIDO    |   RETIDO    |NAO TRIBUTAVEIS|  DEVOLUCAO   |         OBSERVACOES          |"
		aLay[14] := "+---+-----+---------+--------------+-----+-------------+-------------+---------------+--------------+------------------------------+"
		aLay[15] := "| ##| ### |#########|##############|#####|#############|#############| ##############|##############|##############################|"
		aLay[16] := "+---+-----+---------+--------------+-----+-------------+-------------+---------------+--------------+------------------------------+"
		aLay[17] := "| TOTAL DO MES      |##############|     |#############|#############| ##############|##############|                              |"
		aLay[18] := "+-------------------+--------------+-----+-------------+-------------+---------------+--------------+------------------------------+"
		aLay[19] := "| RESUMO DO MES POR ALIQUOTA                                                                                                       |"
		aLay[20] := "+-----------------+--------+------------------+------------------------------------------------------------------------------------+"
		aLay[21] := "| BASE DE CALCULO |ALIQUOTA|  IMPOSTO DEVIDO  |                                                                                    |"
		aLay[22] := "+-----------------+--------+------------------+------------------------------------------------------------------------------------+"
		aLay[23] := "| ##############  |   #####|  ##############  |                                                                                    |"
		aLay[24] := "+-----------------+--------+------------------+------------------------------------------------------------------------------------+"
		aLay[25] := "+---------------------------------------------------------------------------------------------------+----------------+-------------+"
		aLay[26] := "|TOTAIS DO DIA ##   |##############|     |#############|#############| ##############|##############|                              |"
		aLay[27] := "| A TRANSPORTAR     |##############|     |#############|#############| ############# |############# |                              |"
		alay[28] := "|                                                                                                                                  |"
		aLay[29] := "|Tot 1º Decendio    |##############|     |#############|#############| ##############|##############|                              |"
		aLay[30] := "|Tot 2º Decendio    |##############|     |#############|#############| ##############|##############|                              |"
		aLay[31] := "|Tot 3º Decendio    |##############|     |#############|#############| ##############|##############|                              |"
		aLay[32] := "|Tot 1º Quinzenio   |##############|     |#############|#############| ##############|##############|                              |"
		aLay[33] := "|Tot 2º Quinzenio   |##############|     |#############|#############| ##############|##############|                              |"
		aLay[34] := "| Recolhimentos                                                                                                                    |"
		aLay[35] := "+--------------+-----------------+---------------------+---------------------------------------------------------------------------+"
		aLay[36] := "| Guia N.      |Data de Pagamento| Banco               | Informacoes Complementares                                                |"
		aLay[37] := "+--------------+-----------------+---------------------+---------------------------------------------------------------------------+"
		aLay[38] := "| ############ |#################| ################### | #######################################################################   |"
		aLay[39] := "|                 | TOTAL  |  ##############  |                                                                                    |"
		aLay[40] := "|  *** NAO HOUVE MOVIMENTO ***     |     |             |             |               |              |                              |"
	
	ElseIf mv_par11==3  // Modelo 51 - 220 colunas
	
		aLay[01] := "+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
		aLay[02] := "| REGISTRO DE NOTAS FISCAIS DE SERVICOS PRESTADOS (mod.51)                                                                                                                                                      FOLHA #####|"
		If cEstad == "GO"
			aLay[02] := "| LIVRO REGISTRO DE PRESTAÇÃO DE SERVIÇOS  - Modelo 1                                                                                                                                                           FOLHA #####|"
		EndIf
		aLay[03] := "| IMPOSTO SOBRE SERVICOS                                                                                                                                                                                                   |"
		If Empty(mv_par12)
			aLay[04] := "|                                                                                                                                                                                                                          |"
		Else
			aLay[04] := "| REGIME ESPECIAL AUTORIZADO PELO PROCESSO No.: ##################                                                                                                                                                         |"
		Endif
		aLay[05] := "| ###############################################                                                                                                                                  +-------------------+-------------------+"
		aLay[06] := "| C.N.P.J.: ##################                                                                                                                                                     | Mês de Incidência | Código de Serviço |"
		aLay[07] := "| I.E.: ############## C.C.M.: ##################                                                                                                                                  +-------------------+-------------------+"
		aLay[08] := "| ###############################################                                                                                                                                  |  ###############  |      ############ |"
		aLay[09] := "+----------------+--------------------+-----------------------------------------------------------------+------------------+------------------+------------------------------------+-------------------+-------------------+"
		aLay[10] := "|  NOTA FISCAL   |                    |                       SERIES 'A' E 'E'                          |     SERIE 'C'    |     SERIE 'D'    |                                                                            |"
		aLay[11] := "|  DE SERVICO    |                    +------------------+--------+------------------+------------------+------------------+------------------+----------------------------------------------------------------------------+"
		aLay[12] := "+---+-----+------+                    |     BASE DE      |        |     IMPOSTO      |     IMPOSTO      | ISENTAS OU       |    REMESSA OU    |                                                                            |"
		aLay[13] := "|DIA|SERIE|NUMERO|        CNPJ        |     CALCULO      |ALIQUOTA|     DEVIDO       |     RETIDO       | NAO TRIBUTAVEIS  |    DEVOLUCAO     |                       OBSERVACOES                                          |"
		aLay[14] := "+---+-----+------+--------------------+------------------+--------+------------------+------------------+------------------+------------------+----------------------------------------------------------------------------+"
		aLay[15] := "| ##| ### |######| ################## | ##############   |   #####| ##############   | ##############   | ##############   | ##############   | ###############################################                            |"
		aLay[16] := "+---+-----+------+--------------------+------------------+--------+------------------+------------------+------------------+------------------+----------------------------------------------------------------------------+"
		aLay[17] := "| TOTAL DO MES   |                    | ##############   |        | ##############   | ##############   | ##############   | ##############   |                                                                            |"
		aLay[18] := "+----------------+--------------------+------------------+--------+------------------+------------------+------------------+------------------+----------------------------------------------------------------------------+"
		aLay[19] := "| RESUMO DO MES POR ALIQUOTA                                                                                                                                                                                               |"
		aLay[20] := "+-----------------+--------+------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
		aLay[21] := "| BASE DE CALCULO |ALIQUOTA|  IMPOSTO DEVIDO  |                                                                                                                                                                            |"
		aLay[22] := "+-----------------+--------+------------------+                                                                                                                                                                            |"
		aLay[23] := "| ##############  |   #####|  ##############  |                                                                                                                                                                            |"
		aLay[24] := "+-----------------+--------+------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
		aLay[25] := "+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-------------------+-------------------+"
		aLay[26] := "|TOTAIS DO DIA ##|                    | ##############   |        | ##############   | ##############   | ##############   | ##############   |                                                                            |"
		aLay[27] := "| A TRANSPORTAR  |                    | ##############   |        | ##############   | ##############   | ##############   | ##############   |                                                                            |"
		alay[28] := "|                                                                                                                                                                                                                          |"
		aLay[29] := "|Tot 1º Decendio |                    | ##############   |        | ##############   | ##############   | ##############   | ##############   |                                                                            |"
		aLay[30] := "|Tot 2º Decendio |                    | ##############   |        | ##############   | ##############   | ##############   | ##############   |                                                                            |"
		aLay[31] := "|Tot 3º Decendio |                    | ##############   |        | ##############   | ##############   | ##############   | ##############   |                                                                            |"
		aLay[32] := "|Tot 1º Quinzenio|                    | ##############   |        | ##############   | ##############   | ##############   | ##############   |                                                                            |"
		aLay[33] := "|Tot 2º Quinzenio|                    | ##############   |        | ##############   | ##############   | ##############   | ##############   |                                                                            |"
		aLay[34] := "| Recolhimentos                                                                                                                                                                                                            |"
		aLay[35] := "+--------------+-----------------+---------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
		aLay[36] := "| Guia N.      |Data de Pagamento| Banco               | Informacoes Complementares                                                                                                                                        |"
		aLay[37] := "+--------------+-----------------+---------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
		aLay[38] := "| ############ |#################| ################### | #######################################################################                                                                                           |"
		aLay[39] := "|                 | TOTAL  |  ##############  |                                                                                                                                                                            |"
		aLay[40] := "|     *** NAO HOUVE MOVIMENTO ***     |                  |        |                  |                  |                  |                  |                                                                            |"
	EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³Mtr990Cnpj³ Autor ³ Henry Fila            ³ Data ³20/03/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorno do Cnpj do F3                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ExpC1 : Codigo do Cliente no F3                             ³±±
±±³          ³ExpC2 : Loja do Cliente no F3                               ³±±
±±³          ³ExpC3 : Tipo do F3                                          ³±±
±±³          ³ExpC4 : CFO do F3                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Mtr990Cnpj(cCliFor, cLoja, cTipo, cCfo)

Local aArea   := GetArea()
Local aAreaSA1:= SA1->(GetArea())
Local aAreaSA2:= SA2->(GetArea())
Local cAliasB := ""
Local cCampo  := ""

If Left( cCfo, 1) >= "5"
	cAliasB := Iif( cTipo $ "DB", "SA2", "SA1" )
	cCampo  := Iif( cTipo $ "DB", "A2_CGC", "A1_CGC" )
Else	
	cAliasB := Iif( cTipo $ "DB", "SA1", "SA2" )
	cCampo  := Iif( cTipo $ "DB", "A1_CGC", "A2_CGC" )
EndIf	

(cAliasB)->(dbSetOrder(1))
If (cAliasB)->(MsSeek(xFilial(cAliasB)+cCliFor+cLoja))
	cCnpj   :=(cAliasB)->(FieldGet(FieldPos(cCampo)))
EndIf

RestArea(aAreaSA1)
RestArea(aAreaSA2)
RestArea(aArea)

Return(cCnpj)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³Mtr990ISS ³ Autor ³ Henry Fila            ³ Data ³20/03/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorno da opcao de Recolhe ISS                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ExpC1 : Codigo do Cliente no F3                             ³±±
±±³          ³ExpC2 : Loja do Cliente no F3                               ³±±
±±³          ³ExpC3 : Tipo do F3                                          ³±±
±±³          ³ExpC4 : CFO do F3                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Mtr990ISS(cCliFor, cLoja, cTipo, cCfo)

	Local aArea   := GetArea()
	Local aAreaSA1:= SA1->(GetArea())
	Local aAreaSA2:= SA2->(GetArea())
	Local cAliasB := ""
	Local cCampo2 := ""
	
	If Left( cCfo, 1) >= "5"
		cAliasB := Iif( cTipo $ "DB", "SA2", "SA1" )
		cCampo2 := Iif( cTipo $ "DB", "A2_RECISS", "A1_RECISS" )	
	Else	
		cAliasB := Iif( cTipo $ "DB", "SA1", "SA2" )
		cCampo2 := Iif( cTipo $ "DB", "A1_RECISS", "A2_RECISS" )
	EndIf	
	
	(cAliasB)->(dbSetOrder(1))
	If (cAliasB)->(MsSeek(xFilial(cAliasB)+cCliFor+cLoja))
		cRecIss :=(cAliasB)->(FieldGet(FieldPos(cCampo2)))
		cRecIss :=If(cRecIss$"12",If(cRecIss=="1","S","N"),cRecIss)
	EndIf
	
	RestArea(aAreaSA1)
	RestArea(aAreaSA2)
	RestArea(aArea)

Return(cRecISS)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ CabM51      ³ Autor ³ Thiago Galvao      ³ Data ³25/07/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Imp do Cabecaçho do Reg de Apur de ISS Mod 51     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR990()                                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CabM51(nLin,aLay,nPagina,cNome,cInscr,cCCM,cEnd,cMesAno,cCodISS,lResumo,cNproc,nFeixe)

	If ( nLin == 60 )
		FmtLin(,aLay[14],,,@nLin)
	EndIf
	
	nLin := 0
	
	@ nLin,000 Psay aValImp(Limite)
	
	nLin++
	
	FmtLin(,aLay[01],,,@nLin)
	FmtLin({StrZero(nPagina,5)},aLay[02],,,@nLin)
	FmtLin(,aLay[03],,,@nLin)
	FmtLin({cNproc},aLay[04],,,@nLin)
	FmtLin({cNome},aLay[05],,,@nLin)
	FmtLin({Transf(SM0->M0_CGC,"@R 99.999.999/9999-99")},aLay[06],,,@nLin)
	FmtLin({cInscr,cCCM},aLay[07],,,@nLin)
	FmtLin({cEnd,cMesAno,cCodISS},aLay[08],,,@nLin)

	IIF(!lResumo,FmtLin(,aLay[09],,,@nLin),FmtLin(,aLay[25],,,@nLin))

	If !lResumo
		FmtLin(,aLay[10],,,@nLin)
		FmtLin(,aLay[11],,,@nLin)
		FmtLin(,aLay[12],,,@nLin)
		FmtLin(,aLay[13],,,@nLin)
		FmtLin(,aLay[14],,,@nLin)
	EndIf

	If (nFeixe==MV_PAR14)
		nPagina	:=	MV_PAR03
		nFeixe  :=	0
	Else
		nPagina +=1
	Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ R990ImpTerm() ³ Autor ³ Juan Jose Pereira  ³ Data ³20/10/95³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime termos de Abertura e Encerramento                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR990, MATRISS                                           ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R990ImpTerm(cPerg, nOpcaoT)

	Local cArqAbert	:=	GetMv("MV_LISSAB")
	Local cArqEncer	:=	GetMv("MV_LISSEN"), aDriver := ReadDriver()
	Local aDados    := {}
	DEFAULT nOpcaoT := 3
	
	AADD(aDados,{"D_I_A",Day(dDatabase)})
	AADD(aDados,{"M_E_S",MesExtenso(Month(dDatabase))})
	AADD(aDados,{"A_N_O",Year(dDatabase)})
	
	If nOpcaoT == 1
		TERMGO(cArqAbert,,cPerg,aDriver[4],aDados)
	ElseIf nOpcaoT ==2
		TERMGO( ,cArqEncer,cPerg,aDriver[4],aDados)
	Else
		TERMGO(cArqAbert,cArqEncer,cPerg,aDriver[4],aDados)
	EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ TERMGO      ³ Autor ³ Thiago Galvao      ³ Data ³ 13/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime termos de abertura e encerramento                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA990                                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TERMGO(cArqAbert,cArqEncer,cPerg,cDriver,aOutDad)

	Local cSvAlias:=Alias(), aVariaveis:={},i,uConteudo,cConteudo

	aadd(aVariaveis,{"VAR_IXB",If(!(Type('VAR_IXB')=='U'),VAR_IXB,'')})

	dbSelectArea("SM0")

	For i:=1 to FCount()
		
		If FieldName(i)=="M0_CGC"
			AADD(aVariaveis,{FieldName(i),Transform(FieldGet(i),"@R 99.999.999/9999-99")})
		ElseIf FieldName(i)=="M0_INSC"
			AADD(aVariaveis,{FieldName(i),InscrEst()})
		Else
			If FieldName(i)=="M0_NOME"
				Loop
			Endif	
			AADD(aVariaveis,{FieldName(i),FieldGet(i)})
		Endif
	
	Next

	If AliasIndic( "CVB" )
		dbSelectArea( "CVB" )
		CVB->(dbSeek( xFilial( "CVB" ) ))
		For i:=1 to FCount()
			If FieldName(i)=="CVB_CGC"
				AADD(aVariaveis,{FieldName(i),Transform(FieldGet(i),"@R 99.999.999/9999-99")})
			ElseIf FieldName(i)=="CVB_CPF"
				AADD(aVariaveis,{FieldName(i),Transform(FieldGet(i),"@R 999.999.999-99")})
			Else
				AADD(aVariaveis,{FieldName(i),FieldGet(i)})
			Endif
		Next
	EndIf

	dbSelectArea("SX1")
	dbSeek( padr( cPerg , Len( X1_GRUPO ) , ' ' ) + "01" )
	While ! Eof() .And. SX1->X1_GRUPO  == padr( cPerg , Len( X1_GRUPO ) , ' ' )
		uConteudo:=&(X1_VAR01)
		If Valtype(uConteudo)=="N"
			cConteudo:=Alltrim(Str(uConteudo))
		Else
			If Valtype(uConteudo)=="C"
				cConteudo:=Alltrim(uConteudo)
			Else
				cConteudo:=uConteudo
			EndIf
		Endif		
		AADD(aVariaveis,{Rtrim(Upper(X1_VAR01)),cConteudo})
		dbSkip()
	End
	
	For i:=1 to Len(aOutDad)
		AADD(aVariaveis,{aOutDad[i][1],aOutDad[i][2]})
	Next
	
	If cArqAbert#NIL .and. File(cArqAbert)
		ImpTerm(cArqAbert,aVariaveis,&cDriver)
	Endif

	If cArqEncer#NIL .and. File(cArqEncer)
		ImpTerm(cArqEncer,aVariaveis,&cDriver)
	Endif	

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³AjustaSX1 ³ Autor ³Microsiga              ³ Data ³09/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Acerta o arquivo de perguntas                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function AjustaSx1()

	Local aAlias	:= GetArea()
	Local aHelpPor	:= {}		// Help Portugues
	Local aHelpSpa	:= {}		// Help Espanhol
	Local aHelpEng	:= {}		// Help Ingles
	
	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Portugues³
	//ÀÄÄÄÄÄÄÄÄÄÙ
	Aadd( aHelpPor, "Na obrigação da escrituracão do livro ")
	Aadd( aHelpPor, "de acordo com o Mapa Resumo.  ")
	Aadd( aHelpPor, "Somente tem validade esta pergunta, se  ")
	Aadd( aHelpPor, "o parâmetro MV_LJLVFIS for igual a 2. ")
	
	//ÚÄÄÄÄÄÄÄÄ¿
	//³Espanhol³
	//ÀÄÄÄÄÄÄÄÄÙ
	Aadd( aHelpSpa, "En la obrigación de la escrituración del libro ")
	Aadd( aHelpSpa, "de acuerdo con el Mapa Resumo.  ") 
	Aadd( aHelpSpa, "Solamente tienda validad la pregunta,  ") 
	Aadd( aHelpSpa, "con el parametro MV_LJLVFIS iqual a 2. ") 
	
	//ÚÄÄÄÄÄÄ¿
	//³Ingles³
	//ÀÄÄÄÄÄÄÙ
	Aadd( aHelpEng, "In the obligation of the bookkeeping of the book ") 
	Aadd( aHelpEng, "in accordance with the Map Summary. ") 
	Aadd( aHelpEng, "This question only has validity, if ") 
	Aadd( aHelpEng, "equal parameter MV_LJLVFIS the 2. ") 
	
	PutSx1("MTR990","15","Imprime Mapa Resumo ?","Emite Mapa Resumo ?","Printed Map Summary ?","mv_chf","N",01,0,2,"C","MatxRValPer(mv_par15)","","","","mv_par15","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	
	aHelpPor := aHelpEng := aHelpSpa	:=	{}
	
	Aadd( aHelpPor	, "Informe se deseja selecionar as filiais " )
	Aadd( aHelpPor	, "que serão impressas ou imprimir somente " )
	Aadd( aHelpPor  , "a filial logada." )
	
	aHelpEng := aHelpSpa := aHelpPor	
	
	PutSx1( "MTR990", "16", "Seleciona Filiais?", "Seleciona Filiais?", "Seleciona Filiais?",;
				"mv_chg", "N", 1, 0, 2,"C", "","","","","mv_par16", "Sim", "Si",  "Yes", "","Nao", "No", "No",;
				"", "", "", "", "", "","","","",aHelpPor,aHelpEng,aHelpSpa)			
				
	
	aHelpPor := aHelpEng := aHelpSpa	:=	{}
	
	Aadd( aHelpPor	, "Informe se os registros devem ser agluti" )
	Aadd( aHelpPor	, "nados  e gerados  por  CNPJ e  Inscrição " )
	Aadd( aHelpPor	, "Municipal. " )
	
	aHelpEng := aHelpSpa := aHelpPor	
	
	PutSx1( "MTR990", "17", "Aglutina por CNPJ+IM?", "Aglutina por CNPJ+IM?", "Aglutina por CNPJ+IM?",;
				"mv_chh", "N", 1, 0, 2,"C", "","","","","mv_par17", "Sim", "Si",  "Yes", "","Nao", "No", "No",;
				"", "", "", "", "", "","","","",aHelpPor,aHelpEng,aHelpSpa)
	
	RestArea(aAlias)

Return
