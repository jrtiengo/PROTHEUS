#INCLUDE "TOTVS.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} MARA030
Cadastro de Ordens de Separação. Chamado em SIGAPCP -> Atualizacoes -> Específico -> #Ordens Separacao
Documentação em https://tdn.totvs.com/pages/releaseview.action?pageId=347470277
Rotina padrão ACDA100
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 14/02/2022
/*/
User Function MARA030()

	Local cArqInd    := ""
	Local cChaveInd  := ""
	Local cCondicao  := ""

	Private aRotina     := {}
	Private cTitulo     := "Ordens de Separação"
	Private nOrigExp   	:= ""
	Private cUsrCB1   	:= ""
	Private cSeparador 	:= Space(6)

	/*
	MV_PAR01 - Kit 
	MV_PAR02 - OP De -> Número da OP
	MV_PAR03 - OP Ate -> Número da OP
    MV_PAR04 - Separador -> Código 
	MV_PAR05 - Emissão De -> Data da Emissão da OP
	MV_PAR06 - Emissão Ate -> Data da Emissão da OP
	*/
	If .NOT. Pergunte( "MARA030", .T. )
		Return
	EndIf

	aRotina     := {;
		{"Gerar","U_MA030Gera",0,1},;
		{"Imprimir","U_MA030Imp",0,3},;
		{"Consultar Logs","ProcLogView( xFilial('CV8'), 'MARA030' )",0,3};
		}

	cSeparador  := MV_PAR04
	cUsrCB1     := Posicione( "CB1", 1, xFilial("CB1") + cSeparador, "CB1_CODUSR" )

	dbSelectArea("SC2")
	dbSetOrder(1)
	cArqInd   := CriaTrab(, .F.)
	cChaveInd := IndexKey()
	cCondicao := 'C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD >="'    +MV_PAR02+'".And.C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD <="'+MV_PAR03+'"'
	cCondicao += '.And. DTOS(C2_EMISSAO)>="'+DTOS(MV_PAR05)+'".And.DTOS(C2_EMISSAO)<="'+DTOS(MV_PAR06)+'"'
	cCondicao += '.And. Empty(C2_ORDSEP)'
	cCondicao += '.And. Empty(C2_DATRF) .And. '
	cCondicao += ' C2_FILIAL = xFilial("SC2") '

	IndRegua("SC2", cArqInd, cChaveInd, , cCondicao, "Criando indice de trabalho" )
	dbSetOrder(1)
	SC2->(MsSeek(xFilial("SC2")))
	MarkBrow("SC2","C2_OK",'C2_ORDSEP',,.F./*lMark*/, GetMark(,"SC2","C2_OK"))
	SC2->(DbClearFil())
	RetIndex("SC2")

Return


/*/{Protheus.doc} MA030Gera
Gerar as Ordens de Separação nas tabelas padrões CB7 e CB8.
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 14/02/2022
/*/
User Function MA030Gera()

	Local aRecSC2   := {}
	Local aItemCB8  := {}
	Local aSaldoSBF := {}
	Local aSaldoSDC := {}
	// Local aMATA241  := {}
	// Local aItens    := {}
	// Local aMsg 		:= {}
	// Local cFilSD3   := xFilial("SD3")
	Local cSubProc  := StrTran(DtoC(dDataBase),"/","") + "_" + StrTran( Time(), ":", "")
	Local cOrdSep	:= ""
	Local cTipExp	:= ""
	// Local cDoc		:= ""
	Local cStatus	:= "0" // Início
	Local cArm      := Space(Tamsx3("B1_LOCPAD")[1])
	Local cTM	    := GetMV("MV_CBREQD3")
	Local lConsEst  := SuperGetMV("MV_CBRQEST",,.F.)  //Considera a Estrutura do Produto x Saldo na geracao da Ordem de Separacao
	Local lParcial  := SuperGetMV("MV_CBOSPRC",,.F.)  //Permite ou nao gerar Ordens de Separacoes parciais
	Local lBlkPApInd:= SuperGetMv( "MV_PAPRIND", .F., .F. ) //Parametro que Indica se Pode Ser Gerada Ordem de Separacao para Produto de Aprop. Indireta.
	Local lGroupLoc	:= .F.
	Local lSai      := .F.
	Local lGera		:= .T.
	Local nI		:= 0
	Local nSalTotIt := 0
	Local nSaldoEmp := 0
	Local nSldGrv   := 0
	Local nRetSldEnd:= 0
	Local nRetSldSDC:= 0
	Local nSldAtu   := 0
	Local nQtdEmpOS := 0
	Local nPosEmp	:= 0
	Local nX		:= 0
	// Local nPosOS	:= 0
	Local nPosPrdOS := 0
	
	Private aEmp			:= {}
	Private cProdPA			:= ""
	Private cArmPA			:= ""
	Private lMSHelpAuto 	:= .T.
	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile	:= .T.
	

	ProcLogIni({}, "MARA030", cSubProc )

	ProcLogAtu("INICIO")

	// '00-Separcao,01-Separacao/Embalagem,02-Embalagem,03-Gera Nota,04-Imp.Nota,05-Imp.Volume,06-embarque,07-Requisita'
	cTipExp := "00*"

	SC2->( dbGoTop() )
	ProcRegua( SC2->( LastRec() ), "oook" )

	SB2->(DbSetOrder(1))
	SD4->(DbSetOrder(2))
	SDC->(dbSetOrder(2))
	CB7->(DbSetOrder(1))
	NNR->(dbSetOrder(1)) //NNR_FILIAL + NNR_CODIGO
	SG1->(dbSetOrder(1)) //G1_FILIAL + G1_COD + G1_COMP + G1_TRT
	While !SC2->( Eof() )

		If ! SC2->(IsMark("C2_OK",ThisMark(),ThisInv()))
			IncProc()
			SC2->(dbSkip())
			Loop
		EndIf
		
		cOrdSep   := ""
		// nPosOS    := 0
		nPosPrdOS := 0
		cProdPA	  := SC2->C2_PRODUTO
		cArmPA	  := SC2->C2_LOCAL

		CB8->(DbSetOrder(6))
		If CB8->(DbSeek(xFilial("CB8")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN))
			If CB7->(DbSeek(xFilial("CB7")+CB8->CB8_ORDSEP)) .and. CB7->CB7_STATUS # "9" // Ordem em aberto
				//Grava o historico das geracoes:
				ProcLogAtu("ERRO", "OP " + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN) + " ja existe uma Ordem de Separacao em aberto para esta Ordem de Producao" )
				IncProc()
				SC2->(dbSkip())
				Loop
			Endif
		EndIf

		lSai := .f.
		aEmp := {}
		SD4->(DbSeek(xFilial('SD4')+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN))
		While SD4->(! Eof() .And. D4_FILIAL+Left(D4_OP,11) == xFilial('SD4')+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN)

			If SD4->D4_QUANT <= 0
				SD4->(DbSkip())
				Loop
			Endif

			If !NNR->( dbSeek( FWxFilial( 'NNR' ) + SD4->D4_LOCAL ) ) //NNR_FILIAL, NNR_CODIGO
				SD4->( dbSkip() )
				Loop
			EndIf

			If lParcial .And. Localiza(SD4->D4_COD)// Se permitir parcial, controlar localização e nao existir composição de empenho, passa para o proximo.
				If !CBArmProc(SD4->D4_COD,cTM)
					aSaldoSDC := RetSldSDC(SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_OP,.F.,"","",SD4->D4_TRT)
					If Empty(aSaldoSDC)
						SD4->(DbSkip())
						Loop
					EndIf
				Else
					aSaldoSBF := RetSldEnd( SD4->D4_COD, .f.,, IIf( lGroupLoc, SD4->D4_LOCAL, Nil ), lGroupLoc, cArmPA )
					If Empty(aSaldoSBF)
						SD4->(DbSkip())
						Loop
					EndIf
				EndIf
			EndIf
			SB1->(DBSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1")+SD4->D4_COD)) .And. IsProdMOD(SD4->D4_COD)
				SD4->(DbSkip())
				Loop
			Endif

			If IsPrdApInd( SD4->D4_COD ) .And. lBlkPApInd
				SD4->( dbSkip() )
				Loop
			EndIf

			If SG1->( DbSeek( xFilial("SG1") + cProdPA + SD4->D4_COD ) )
				If SG1->G1_TPKIT <> MV_PAR01
					SD4->(DbSkip())
					Loop
				EndIf
			EndIf

			If !Localiza(SD4->D4_COD) // Nao controla endereco
				SB2->(DbSeek(xFilial("SB2")+SD4->(D4_COD+D4_LOCAL)))
				nSldAtu := If(CBArmProc(SD4->D4_COD,cTM),SB2->B2_QATU,SaldoSB2())
				nPosEmp := Ascan(aEmp,{|x| x[02] == SD4->D4_COD})
				If nPosEmp == 0
					aadd(aEmp,{SD4->D4_OP,SD4->D4_COD,SD4->D4_QUANT,nSldAtu,0,0,0})
				Else
					aEmp[nPosEmp,03] += SD4->D4_QUANT
				Endif
				SD4->(DbSkip())
				Loop
			Endif
			If !CBArmProc(SD4->D4_COD,cTM) .AND. If(!lParcial,(SD4->D4_QUANT > (nRetSldSDC := RetSldSDC(SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_OP,.t.,"","",SD4->D4_TRT))),.F.) .AND. !lConsEst
				//Grava o historico das geracoes:
				ProcLogAtu("ERRO", "O produto "+Alltrim(SD4->D4_COD)+" nao encontra-se empenhado (SD4 x SDC)" )
				lSai := .t.
			ElseIf CBArmProc(SD4->D4_COD,cTM) .AND. If(!lParcial,(SD4->D4_QUANT > (nRetSldEnd := RetSldEnd( SD4->D4_COD,.t.,, IIf( lGroupLoc, SD4->D4_LOCAL, Nil ), lGroupLoc, cArmPA ))),.F.) .AND. !lConsEst
				//Grava o historico das geracoes:
				ProcLogAtu("ERRO", "O produto "+Alltrim(SD4->D4_COD)+" nao possui saldo enderecado suficiente ou existem Ordens de Separacao ainda nao requisitadas" )
				lSai := .t.
			EndIf
			nPosEmp := Ascan(aEmp,{|x| x[02] == SD4->D4_COD})
			If nPosEmp == 0
				aadd(aEmp,{SD4->D4_OP,SD4->D4_COD,SD4->D4_QUANT,If(CBArmProc(SD4->D4_COD,cTM),nRetSldEnd,nRetSldSDC),0,0,0})
			Else
				aEmp[nPosEmp,03] += SD4->D4_QUANT
			Endif
			SD4->(DbSkip())
			Loop
		EndDo
		If lConsEst  //Considera a Estrutura do Produto x Saldo na geracao da Ordem de Separacao
			If SemSldOS()
				//Grava o historico das geracoes:
				ProcLogAtu("ERRO", "OP " + SD4->D4_OP + " os itens empenhados nao possuem saldo em estoque suficiente para a producao de uma unidade do produto da OP" )
				lSai := .t.
			Endif
		Endif
		If lSai
			IncProc()
			SC2->(dbSkip())
			Loop
		EndIf

		SD4->(DbSeek(xFilial('SD4')+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN))
		While SD4->(!Eof() .And. D4_FILIAL+Left(D4_OP,11) == xFilial('SD4')+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN)
			If SD4->D4_QUANT <= 0
				SD4->(DbSkip())
				Loop
			EndIf

			If !NNR->( dbSeek( FWxFilial( 'NNR' ) + SD4->D4_LOCAL ) ) //NNR_FILIAL, NNR_CODIGO
				SD4->( dbSkip() )
				Loop
			EndIf

			If lParcial .And. Localiza(SD4->D4_COD)// Se permitir parcial, controlar localização e nao existir composição de empenho, passa para o proximo.
				If !CBArmProc(SD4->D4_COD,cTM)
					aSaldoSDC := RetSldSDC(SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_OP,.F.,SD4->D4_LOTECTL,SD4->D4_NUMLOTE,SD4->D4_TRT)
					If Empty(aSaldoSDC)
						ProcLogAtu("ERRO", "OP " + SD4->D4_OP + " o produto "+Alltrim(SD4->D4_COD)+" nao encontra-se empenhado (SD4 x SDC)" )
						SD4->(DbSkip())
						Loop
					EndIf
				Else
					aSaldoSBF := RetSldEnd(SD4->D4_COD, .f.,, IIf( lGroupLoc, SD4->D4_LOCAL, Nil ), lGroupLoc, cArmPA )
					If Empty(aSaldoSBF)
						ProcLogAtu("ERRO", "OP " + SD4->D4_OP + "O produto "+Alltrim(SD4->D4_COD)+" nao possui saldo enderecado suficiente ou existem Ordens de Separacao ainda nao requisitadas" )
						SD4->(DbSkip())
						Loop
					EndIf
				EndIf
			EndIf
			SB1->(DBSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1")+SD4->D4_COD)) .And. IsProdMOD(SD4->D4_COD)
				SD4->(DbSkip())
				Loop
			Endif

			If IsPrdApInd( SD4->D4_COD ) .And. lBlkPApInd
				SD4->( dbSkip() )
				Loop
			EndIf

			If SG1->( DbSeek( xFilial("SG1") + cProdPA + SD4->D4_COD ) )
				If SG1->G1_TPKIT <> MV_PAR01
					SD4->(DbSkip())
					Loop
				EndIf
			EndIf

			cOP := SD4->D4_OP
			cArm := If( CBArmProc(SD4->D4_COD,cTM), SB1->B1_LOCPAD, SD4->D4_LOCAL )
			//cStatus := "0"  // Início

			CB7->(DbSetOrder(5)) // CB7_FILIAL + CB7_OP + CB7_LOCAL + CB7_STATUS
			If ! CB7->(DbSeek(xFilial("CB7")+cOP+cArm+cStatus))
				cOrdSep   := GetSX8Num( "CB7", "CB7_ORDSEP" )
				CB7->(RecLock( "CB7", .T. ))
				CB7->CB7_FILIAL := xFilial( "CB7" )
				CB7->CB7_ORDSEP := cOrdSep
				CB7->CB7_OP     := cOP
				CB7->CB7_LOCAL  := cArm
				CB7->CB7_DTEMIS := dDataBase
				CB7->CB7_HREMIS := Time()
				CB7->CB7_STATUS := cStatus
				CB7->CB7_CODOPE := cSeparador
				CB7->CB7_PRIORI := "1"
				CB7->CB7_ORIGEM := "3"
				CB7->CB7_TIPEXP := cTipExp
				CB7->(MsUnLock())
				ConfirmSX8()
				//Grava o historico das geracoes:
				ProcLogAtu("MENSAGEM", "Ordem Separacao " + cOrdSep + " incluida com sucesso", "OP " + AllTrim(CB7->CB7_OP)+CRLF;
																							+ "Amazem " + cArm + CRLF;
																							+ "usuário " + CB7->CB7_CODOPE )

			EndIf

			// nPosOS := aScan( aMATA241, {|x| x[1] == cOrdSep } )
			// If nPosOS <= 0
			// 	AADD( aMATA241, { cOrdSep, {} } )
			// 	nPosOS := Len( aMATA241 )
			// EndIf

			If Localiza(SD4->D4_COD) //controla endereco
				If !CBArmProc(SD4->D4_COD,cTM)
					aSaldoSDC := RetSldSDC(SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_OP,.F.,SD4->D4_LOTECTL,SD4->D4_NUMLOTE,SD4->D4_TRT)
					nSalTotIt := 0
					For nX:=1 to Len(aSaldoSDC)
						nSalTotIt+=aSaldoSDC[nX,7]
					Next
					If lConsEst
						nSaldoEmp := RetEmpOS(lConsEst,SD4->D4_COD,SD4->D4_QUANT)
					EndIf

					// Separacoes sao geradas conf. empenhos nos enderecos (SDC)
					For nX:=1 to Len(aSaldoSDC)
						lGera := .T.
						If !lConsEst
							nSaldoEmp := RetEmpOS(lConsEst,SD4->D4_COD,aSaldoSDC[nX,7])
						EndIf
						If (!lConsEst .And. !lParcial) .And. SD4->D4_QTDEORI <> nSalTotIt
							Exit
						ElseIf lConsEst .And. nSaldoEmp == 0
							lGera := .F.
						Else
							nSldGrv   := aSaldoSDC[nX,7]
							nSaldoEmp -= aSaldoSDC[nX,7]
						EndIf
						If lGera
							cOrdSep := CB7->CB7_ORDSEP
							CB8->(RecLock( "CB8", .T. ))
							CB8->CB8_FILIAL := xFilial( "CB8" )
							CB8->CB8_ORDSEP := cOrdSep
							CB8->CB8_OP     := SD4->D4_OP
							CB8->CB8_ITEM   := RetItemCB8(cOrdSep,aItemCB8)
							CB8->CB8_PROD   := SD4->D4_COD
							CB8->CB8_LOCAL  := aSaldoSDC[nX,2]
							CB8->CB8_QTDORI := nSldGrv
							CB8->CB8_SALDOS := nSldGrv
							CB8->CB8_SALDOE := nSldGrv
							CB8->CB8_LCALIZ := aSaldoSDC[nX,3]
							CB8->CB8_SEQUEN := ""
							CB8->CB8_LOTECT := aSaldoSDC[nX,4]
							CB8->CB8_NUMLOT := aSaldoSDC[nX,5]
							CB8->CB8_NUMSER := aSaldoSDC[nX,6]
							CB8->CB8_CFLOTE := "1"

							CB8->(MsUnLock())

							// nPosPrdOS := AScan( aMATA241[nPosOS,2], {|x| x[1] == SD4->D4_COD })
							// If nPosPrdOS <= 0
							// 	AADD( aMATA241[nPosOS,2], { cFilSD3,;
							// 								SD4->D4_OP,;
							// 								SD4->D4_COD,;
							// 								CB8->CB8_LOCAL,;
							// 								SB1->B1_UM,;
							// 								CB8->CB8_QTDORI,;
							// 								cUsrCB1,;
							// 								"RE0",;
							// 								"E0",;
							// 								"Ordem Separacao "+cOrdSep;
							// 							} )
							// Else
							// 	aMATA241[ nPosOS, 2, nPosPrdOS, 6 ] += CB8->CB8_QTDORI
							// EndIf
							
						EndIf
					Next
					SD4->(DbSkip())
					Loop
				Else
					aSaldoSBF := RetSldEnd(SD4->D4_COD, .f.,, IIf( lGroupLoc, SD4->D4_LOCAL, Nil ), lGroupLoc, cArmPA )
					If lConsEst
						nSaldoEmp := RetEmpOS(lConsEst,SD4->D4_COD,SD4->D4_QUANT)
					EndIf
					For nX:=1 to Len(aSaldoSBF)
						If !lConsEst .and. nX==1
							nSaldoEmp := RetEmpOS(lConsEst,SD4->D4_COD,SD4->D4_QUANT)
						EndIf
						If nSaldoEmp < 1
							Loop
						EndIf

						If lConsEst .And. nSaldoEmp == 0
							SD4->(DbSkip())
							Exit
							nSaldoEmp -= aSaldoSDC[nX,7]
						EndIf
						cOrdSep := CB7->CB7_ORDSEP
						CB8->(RecLock( "CB8", .T. ))
						CB8->CB8_FILIAL := xFilial( "CB8" )
						CB8->CB8_ORDSEP := cOrdSep
						CB8->CB8_OP     := SD4->D4_OP
						CB8->CB8_ITEM   := RetItemCB8(cOrdSep,aItemCB8)
						CB8->CB8_PROD   := aSaldoSBF[nX,1]
						CB8->CB8_LOCAL  := aSaldoSBF[nX,2]
						CB8->CB8_QTDORI := nSaldoEmp
						CB8->CB8_SALDOS := Iif (!aSaldoSBF[nX,7] > nSaldoEmp,aSaldoSBF[nX,7],nSaldoEmp)
						CB8->CB8_SALDOE := nSaldoEmp
						CB8->CB8_LCALIZ := aSaldoSBF[nX,3]
						CB8->CB8_SEQUEN := ""
						CB8->CB8_LOTECT := aSaldoSBF[nX,4]
						CB8->CB8_NUMLOT := aSaldoSBF[nX,5]
						CB8->CB8_NUMSER := aSaldoSBF[nX,6]
						CB8->CB8_CFLOTE := "1"

						CB8->(MsUnLock())

						// nPosPrdOS := AScan( aMATA241[nPosOS,2], {|x| x[1] == SD4->D4_COD })
						// If nPosPrdOS <= 0
						// 	AADD( aMATA241[nPosOS,2], { cFilSD3,;
						// 								SD4->D4_OP,;
						// 								SD4->D4_COD,;
						// 								CB8->CB8_LOCAL,;
						// 								SB1->B1_UM,;
						// 								CB8->CB8_QTDORI,;
						// 								cUsrCB1,;
						// 								"RE0",;
						// 								"E0",;
						// 								"Ordem Separacao "+cOrdSep;
						// 							} )
						// Else
						// 	aMATA241[ nPosOS, 2, nPosPrdOS, 6 ] += CB8->CB8_QTDORI
						// EndIf

						nSaldoEmp -= aSaldoSBF[nX,7]
					Next Nx
					SD4->(DbSkip())
				Endif
			Else
				cOrdSep   := CB7->CB7_ORDSEP
				nQtdEmpOS := RetEmpOS(lConsEst,SD4->D4_COD,SD4->D4_QUANT)
				CB8->(RecLock( "CB8", .T. ))
				CB8->CB8_FILIAL := xFilial( "CB8" )
				CB8->CB8_ORDSEP := cOrdSep
				CB8->CB8_OP     := SD4->D4_OP
				CB8->CB8_ITEM   := RetItemCB8(cOrdSep,aItemCB8)
				CB8->CB8_PROD   := SD4->D4_COD
				CB8->CB8_LOCAL  := If(CBArmProc(SD4->D4_COD,cTM), Posicione( 'SB1', 1, FWxFilial( 'SB1' ) + SD4->D4_COD, 'B1_LOCPAD' ), SD4->D4_LOCAL )
				CB8->CB8_QTDORI := nQtdEmpOS
				CB8->CB8_SALDOS := nQtdEmpOS
				CB8->CB8_SALDOE := nQtdEmpOS
				CB8->CB8_LCALIZ := Space(15)
				CB8->CB8_SEQUEN := ""
				CB8->CB8_LOTECT := SD4->D4_LOTECTL
				CB8->CB8_NUMLOT := SD4->D4_NUMLOTE
				CB8->CB8_CFLOTE := "1"

				CB8->(MsUnLock())

				// nPosPrdOS := AScan( aMATA241[nPosOS,2], {|x| x[1] == SD4->D4_COD })
				// If nPosPrdOS <= 0
				// 	AADD( aMATA241[nPosOS,2], { cFilSD3,;
				// 								SD4->D4_OP,;
				// 								SD4->D4_COD,;
				// 								CB8->CB8_LOCAL,;
				// 								SB1->B1_UM,;
				// 								CB8->CB8_QTDORI,;
				// 								cUsrCB1,;
				// 								"RE0",;
				// 								"E0",;
				// 								"Ordem Separacao "+cOrdSep;
				// 							} )
				// Else
				// 	aMATA241[ nPosOS, 2, nPosPrdOS, 6 ] += CB8->CB8_QTDORI
				// EndIf
				
				SD4->(DbSkip())
			EndIf
		EndDo

		aadd(aRecSC2,SC2->(Recno()))

		IncProc()
		SC2->( dbSkip() )
	EndDo

	For nI := 1 To Len( aRecSC2 )

		SC2->( DbGoto( aRecSC2[nI] ) )
		SC2->( RecLock("SC2", .F.) )
			SC2->C2_ORDSEP := cOrdSep
		SC2->( MsUnlock() )

	Next

	ProcLogAtu("FIM")

	If Len( aRecSC2 ) > 0
		// Abre a tela para a visualização de todos os logs gravados conforme cada chamada da função ProcLogAtu()
		ProcLogView( xFilial("CV8"), "MARA030", cSubProc )

		If MsgYesNo( "Deseja realizar a impressão da(s) Ordem(ns) gerada(s) ?", cTitulo )
			U_MA030Imp()
		EndIf
	Else
		MsgAlert( "Não foi gerada Ordem de Separação ! Verifique se um ou mais Empenhos (produtos) estão "+;
				"configurados como Apropriação Indireta, pois nesse caso pode não ser gerada a ordem.", cTitulo )
	EndIf

Return


/*/{Protheus.doc} RetItemCB8
Retorna o item conforme o CB8
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 21/02/2022
@param cOrdSep, character, Código da Ordem de Separação
@param aItemCB8, array, Array de itens
@return character, Item localizado
/*/
Static Function RetItemCB8(cOrdSep,aItemCB8)

	Local nPos  := Ascan(aItemCB8,{|x| x[1] == cOrdSep})
	Local cItem := ' '

	If Empty(nPos )
		AAdd(aItemCB8,{cOrdSep,'00'})
		nPos := len(aItemCB8)
	EndIF

	cItem := Soma1(aItemcb8[nPos,2])
	aItemcb8[nPos,2]:= cItem

Return( cItem )


/*/{Protheus.doc} RetEmpOS
Retornar a quantidade Empenhada
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 14/02/2022
@param lConsEst, logical, Consulta estrutura
@param cProdEmp, character, Produto empenhado
@param nQtdEmp, numeric, Quantidade
@return numeric, Quantidade
/*/
Static Function RetEmpOS(lConsEst,cProdEmp,nQtdEmp)

	Local nPos := 0

	If !lConsEst
		Return nQtdEmp
	Endif

	nPos := Ascan(aEmp,{|x| x[02] == cProdEmp})

Return( aEmp[nPos,07] )


/*/{Protheus.doc} MA030Imp
Impressão da Ordem de Separação
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 21/02/2022
/*/
User Function MA030Imp()

	Local aOrdem		:= {"Ordem de Separação"}
	Local aDevice		:= {"DISCO","SPOOL","EMAIL","EXCEL","HTML","PDF"}
	Local bParam		:= {|| Pergunte("ACD100", .T.)}
	Local cDevice		:= ""
	Local cRelName		:= "MA030IMP"
	Local cSession		:= GetPrinterSession()
	Local lAdjust		:= .F.
	Local nFlags		:= PD_ISTOTVSPRINTER+PD_DISABLEORIENTATION
	Local nLocal		:= 1
	Local nOrdem		:= 1
	Local nOrient		:= 1
	Local nPrintType	:= 6
	Local oPrinter		:= Nil
	Local oSetup		:= Nil

	Private nMaxLin		:= 600
	Private nMaxCol		:= 800

	cSession	:= GetPrinterSession()
	cDevice	:= If(Empty(fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)),"PDF",fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.))
	nOrient	:= If(fwGetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
	nLocal		:= If(fwGetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
	nPrintType	:= aScan(aDevice,{|x| x == cDevice })

	oPrinter	:= FWMSPrinter():New(cRelName, nPrintType, lAdjust, /*cPathDest*/, .T.)
	oSetup		:= FWPrintSetup():New (nFlags,cRelName)

	oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
	oSetup:SetPropert(PD_ORIENTATION , nOrient)
	oSetup:SetPropert(PD_DESTINATION , nLocal)
	oSetup:SetPropert(PD_MARGIN      , {0,0,0,0})
	oSetup:SetOrderParms(aOrdem,@nOrdem)
	oSetup:SetUserParms(bParam)

	If oSetup:Activate() == PD_OK
		fwWriteProfString(cSession, "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )
		fwWriteProfString(cSession, "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==2   ,"SPOOL"     ,"PDF"       ), .T. )
		fwWriteProfString(cSession, "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )

		oPrinter:lServer := oSetup:GetProperty(PD_DESTINATION) == AMB_SERVER
		oPrinter:SetDevice(oSetup:GetProperty(PD_PRINTTYPE))
		oPrinter:SetLandscape()
		oPrinter:SetPaperSize(oSetup:GetProperty(PD_PAPERSIZE))
		oPrinter:setCopies(Val(oSetup:cQtdCopia))

		If oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
			oPrinter:nDevice := IMP_SPOOL
			fwWriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
			oPrinter:cPrinter := oSetup:aOptions[PD_VALUETYPE]
		Else
			oPrinter:nDevice := IMP_PDF
			oPrinter:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
			oPrinter:SetViewPDF(.T.)
		Endif

		RptStatus({|lEnd| ACD100Imp(@lEnd,@oPrinter)},"Imprimindo Relatorio...")
	Else
		MsgInfo("Relatório cancelado pelo usuário.")
		oPrinter:Cancel()
	EndIf

	oSetup		:= Nil
	oPrinter	:= Nil

Return


/*/{Protheus.doc} ACD100Imp
Imprime o corpo do relatorio
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 21/02/2022
@param lEnd, logical, Cancelamento do relatório
@param oPrinter, object, Objeto da impressao
/*/
Static Function ACD100Imp(lEnd,oPrinter)

	Local nMaxLinha	:= 40
	Local nLinCount	:= 0
	Local aArea		:= GetArea()
	Local cQry		:= ""
	Local cOrdSep	:= ""

	Private cAliasOS	:= GetNextAlias()
	Private nMargDir	:= 15
	Private nMargEsq	:= 20
	Private nColAmz		:= nMargEsq+155
	Private nColEnd		:= nColAmz+45
	Private nColLot		:= nColEnd+85
	Private nColSLt		:= nColLot+85
	Private nSerie		:= nColSLt+40
	Private nQtOri		:= nSerie+110
	Private nQtSep		:= nQtOri+85
	Private nQtEmb		:= nQtSep+85
	Private oFontA7		:= TFont():New('Arial',,7,.T.)
	Private oFontA12	:= TFont():New('Arial',,12,.T.)
	Private oFontC8		:= TFont():New('Courier new',,8,.T.)
	Private li			:= 10
	Private nLiItm		:= 0
	Private nPag		:= 0

	Pergunte("ACD100",.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o arquivo temporario ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQry := "SELECT CB7_ORDSEP,CB7_PEDIDO,CB7_CLIENT,CB7_LOJA,CB7_NOTA,"+SerieNfId('CB7',3,'CB7_SERIE')+",CB7_OP,CB7_STATUS,CB7_ORIGEM, "
	cQry += "CB8_PROD,CB8_ORDSEP,CB8_LOCAL,CB8_LCALIZ,CB8_LOTECT,CB8_NUMLOT,CB8_NUMSER,CB8_QTDORI,CB8_SALDOS,CB8_SALDOE"
	cQry += " FROM "+RetSqlName("CB7")+","+RetSqlName("CB8")
	cQry += " WHERE CB7_FILIAL = '"+xFilial("CB7")+"' AND"
	cQry += " CB7_ORDSEP >= '"+MV_PAR01+"' AND"
	cQry += " CB7_ORDSEP <= '"+MV_PAR02+"' AND"
	cQry += " CB7_DTEMIS >= '"+DTOS(MV_PAR03)+"' AND"
	cQry += " CB7_DTEMIS <= '"+DTOS(MV_PAR04)+"' AND"
	cQry += " CB8_FILIAL = CB7_FILIAL AND"
	cQry += " CB8_ORDSEP = CB7_ORDSEP AND"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao Considera as Ordens ja finalizadas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQry += " "+RetSqlName("CB8")+".D_E_L_E_T_ = '' AND"
	cQry += " "+RetSqlName("CB7")+".D_E_L_E_T_ = ''"
	cQry += " ORDER BY CB7_ORDSEP,CB8_PROD"
	cQry := ChangeQuery(cQry)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasOS,.T.,.T.)

	SetRegua((cAliasOS)->(LastRec()))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia a impressao do relatorio ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !(cAliasOS)->(Eof())
		IncRegua()
		nLiItm		:= 110
		nLinCount	:= 0
		nPag++
		oPrinter:StartPage()
		CabPagina(@oPrinter)
		CabItem(@oPrinter,(cAliasOS)->CB7_ORIGEM)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime os titulos das colunas dos itens ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrinter:SayAlign(li+100,nMargDir,"Produto",oFontC8,200,200,,0)
		oPrinter:SayAlign(li+100,nColAmz,"Armazem",oFontC8,200,200,,0)
		oPrinter:SayAlign(li+100,nColEnd,"Endereço",oFontC8,200,200,,0)
		oPrinter:SayAlign(li+100,nColLot,"Lote",oFontC8,200,200,,0)
		oPrinter:SayAlign(li+100,nColSLt,"SubLt.",oFontC8,200,200,,0)
		oPrinter:SayAlign(li+100,nSerie,"Num. Série",oFontC8,200,200,,0)
		oPrinter:SayAlign(li+100,nQtOri,"Qtde. Original",oFontC8,200,200,,0)
		oPrinter:SayAlign(li+100,nQtSep,"Qtd. a Separar",oFontC8,200,200,,0)
		oPrinter:SayAlign(li+100,nQtEmb,"Qtd. a Embalar",oFontC8,200,200,,0)
		oPrinter:Line(li+110,nMargDir, li+110, nMaxCol-nMargEsq,, "-2")

		cOrdSep := (cAliasOS)->CB7_ORDSEP

		While !(cAliasOS)->(Eof()) .and. (cAliasOS)->CB8_ORDSEP == cOrdSep
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicia uma nova pagina caso nao estiver em EOF ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nLinCount == nMaxLinha
				oPrinter:StartPage()
				nPag++
				CabPagina(@oPrinter)
				nLiItm		:= li+50
				nLinCount	:= 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Imprime os titulos das colunas dos itens ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oPrinter:SayAlign(nLiItm,nMargDir,"Produto",oFontC8,200,200,,0)
				oPrinter:SayAlign(nLiItm,nColAmz,"Armazem",oFontC8,200,200,,0)
				oPrinter:SayAlign(nLiItm,nColEnd,"Endereço",oFontC8,200,200,,0)
				oPrinter:SayAlign(nLiItm,nColLot,"Lote",oFontC8,200,200,,0)
				oPrinter:SayAlign(nLiItm,nColSLt,"SubLt.",oFontC8,200,200,,0)
				oPrinter:SayAlign(nLiItm,nSerie,"Num. Série",oFontC8,200,200,,0)
				oPrinter:SayAlign(nLiItm,nQtOri,"Qtde. Original",oFontC8,200,200,,0)
				oPrinter:SayAlign(nLiItm,nQtSep,"Qtd. a Separar",oFontC8,200,200,,0)
				oPrinter:SayAlign(nLiItm,nQtEmb,"Qtd. a Embalar",oFontC8,200,200,,0)

				oPrinter:Line(li+nLiItm,nMargDir, li+nLiItm, nMaxCol-nMargEsq,, "-2")
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime os itens da ordem de separacao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oPrinter:SayAlign(li+nLiItm,nMargDir,(cAliasOS)->CB8_PROD,oFontC8,200,200,,0)
			oPrinter:SayAlign(li+nLiItm,nColAmz,(cAliasOS)->CB8_LOCAL,oFontC8,200,200,,0)
			oPrinter:SayAlign(li+nLiItm,nColEnd,(cAliasOS)->CB8_LCALIZ,oFontC8,200,200,,0)
			oPrinter:SayAlign(li+nLiItm,nColLot,(cAliasOS)->CB8_LOTECT,oFontC8,200,200,,0)
			oPrinter:SayAlign(li+nLiItm,nColSLt,(cAliasOS)->CB8_NUMLOT,oFontC8,200,200,,0)
			oPrinter:SayAlign(li+nLiItm,nSerie,(cAliasOS)->CB8_NUMSER,oFontC8,200,200,,0)
			oPrinter:SayAlign(li+nLiItm,nQtOri+li,Transform((cAliasOS)->CB8_QTDORI,PesqPictQt("CB8_QTDORI",20)),oFontC8,200,200,1,0)
			oPrinter:SayAlign(li+nLiItm,nQtSep+li,Transform((cAliasOS)->CB8_SALDOS,PesqPictQt("CB8_QTDORI",20)),oFontC8,200,200,1,0)
			oPrinter:SayAlign(li+nLiItm,nQtEmb+li,Transform((cAliasOS)->CB8_SALDOE,PesqPictQt("CB8_QTDORI",20)),oFontC8,200,200,1,0)

			nLinCount++
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza a pagina quando atingir a quantidade maxima de itens ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nLinCount == nMaxLinha
				oPrinter:Line(550,nMargDir, 550, nMaxCol-nMargEsq,, "-2")
				oPrinter:EndPage()
			Else
				nLiItm += li
			EndIf

			(cAliasOS)->(dbSkip())
			Loop
		EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Finaliza a pagina se a quantidade de itens for diferente da quantidade ³
		//³ maxima, para evitar que a pagina seja finalizada mais de uma vez.      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nLinCount <> nMaxLinha
			oPrinter:Line(550,nMargDir, 550, nMaxCol-nMargEsq,, "-2")
			oPrinter:EndPage()
		EndIf
	EndDo

	oPrinter:Print()

	(cAliasOS)->(dbCloseArea())
	RestArea(aArea)

Return


/*/{Protheus.doc} CabPagina
Imprime o cabecalho do relatorio
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 21/02/2022
@param oPrinter, object, Objeto da impressao
/*/
Static Function CabPagina(oPrinter)

	Private nCol1Dir	:= 720-nMargDir
	Private nCol2Dir	:= 760-nMargDir

	oPrinter:Line(li+5, nMargDir, li+5, nMaxCol-nMargEsq,, "-8")

	oPrinter:SayAlign(li+10,nMargDir,"SIGA/MARA030/v12",oFontA7,200,200,,0)
	oPrinter:SayAlign(li+20,nMargDir,"Hora: "+Time(),oFontA7,200,200,,0)
	oPrinter:SayAlign(li+30,nMargDir,"Empresa: "+FWFilialName(,,2) ,oFontA7,300,200,,0)

	oPrinter:SayAlign(li+20,340,"Impressão das Ordens de Separação",oFontA12,nMaxCol-nMargEsq,200,2,0)

	oPrinter:SayAlign(li+10,nCol1Dir,"Folha   : ",oFontA7,200,200,,0)
	oPrinter:SayAlign(li+20,nCol1Dir,"Dt. Ref.: ",oFontA7,200,200,,0)
	oPrinter:SayAlign(li+30,nCol1Dir,"Emissão : ",oFontA7,200,200,,0)

	oPrinter:SayAlign(li+10,nCol2Dir,AllTrim(STR(nPag)),oFontA7,200,200,,0)
	oPrinter:SayAlign(li+20,nCol2Dir,DTOC(ddatabase),oFontA7,200,200,,0)
	oPrinter:SayAlign(li+30,nCol2Dir,DTOC(ddatabase),oFontA7,200,200,,0)

	oPrinter:Line(li+40,nMargDir, li+40, nMaxCol-nMargEsq,, "-8")

Return


/*/{Protheus.doc} CabItem
Imprime o cabeçalho do Item
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 21/02/2022
@param oPrinter, object, Objeto da impressão
@param cOrigem, character, Origem
/*/
Static Function CabItem(oPrinter,cOrigem)

	Local cOrdSep	:= AllTrim((cAliasOS)->CB7_ORDSEP)
	Local cPedVen	:= AllTrim((cAliasOS)->CB7_PEDIDO)
	Local cClient	:= AllTrim((cAliasOS)->CB7_CLIENT)+"-"+AllTrim((cAliasOS)->CB7_LOJA)
	Local cNFiscal	:= AllTrim((cAliasOS)->CB7_NOTA)+"-"+AllTrim((cAliasOS)->&(SerieNfId('CB7',3,'CB7_SERIE')))
	Local cOP		:= AllTrim((cAliasOS)->CB7_OP)
	Local cStatus	:= RetStatus((cAliasOS)->CB7_STATUS)

	oPrinter:SayAlign(li+60,nMargDir,"Ordem de Separação:",oFontC8,200,200,,0)
	oPrinter:SayAlign(li+60,nMargDir+105,cOrdSep,oFontC8,200,200,,0)

	If Alltrim(cOrigem) == "1" // Pedido venda
		oPrinter:SayAlign(li+60,nMargDir+160,"Pedido de Venda:",oFontC8,200,200,,0)//
		If Empty(cPedVen) .And. (cAliasOS)->CB7_STATUS <> "9"
			oPrinter:SayAlign(li+60,nMargDir+245,"Aglutinado",oFontC8,200,200,,0)
			oPrinter:SayAlign(li+72,nMargDir,"PV's Aglutinados:",oFontC8,200,200,,0)
			oPrinter:SayAlign(li+72,nMargDir+105,A100AglPd(cOrdSep),oFontC8,550,200,,0)
		Else
			oPrinter:SayAlign(li+60,nMargDir+245,cPedVen,oFontC8,200,200,,0)
		EndIf
		oPrinter:SayAlign(li+60,nMargDir+310,"Cliente:",oFontC8,200,200,,0)
		oPrinter:SayAlign(li+60,nMargDir+355,cClient,oFontC8,200,200,,0)
	ElseIf Alltrim(cOrigem) == "2" // Nota Fiscal
		oPrinter:SayAlign(li+60,nMargDir+160,"Nota Fiscal:",oFontC8,200,200,,0)
		oPrinter:SayAlign(li+60,nMargDir+230,cNFiscal,oFontC8,200,200,,0)
		oPrinter:SayAlign(li+60,nMargDir+310,"Cliente:",oFontC8,200,200,,0)
		oPrinter:SayAlign(li+60,nMargDir+355,cClient,oFontC8,200,200,,0)
	ElseIf Alltrim(cOrigem) == "3" // Ordem de Producao
		oPrinter:SayAlign(li+60,nMargDir+160,"Ordem de Produção:",oFontC8,200,200,,0)
		oPrinter:SayAlign(li+60,nMargDir+255,cOP,oFontC8,200,200,,0)
	EndIf

	oPrinter:SayAlign(li+60,nMargDir+430,"Status:",oFontC8,200,200,,0)
	oPrinter:SayAlign(li+60,nMargDir+470,cStatus,oFontC8,200,200,,0)
	oPrinter:Line(li+90,nMargDir, li+90, nMaxCol-nMargEsq,, "-2")

	If MV_PAR06 == 1
		oPrinter:FWMSBAR("CODE128",5/*nRow*/,60/*nCol*/,AllTrim(cOrdSep),oPrinter,,,, 0.049,1.0,,,,.F.,,,)
	EndIf

Return


/*/{Protheus.doc} RetStatus
Retorna o Status da Ordem de Separacao
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 21/02/2022
@param cStatus, character, Código do Status
@return character, Descrição do Status
/*/
Static Function RetStatus(cStatus)

	Local cDescri	:= ""

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
		cDescri:= "Em processo de embarque"
	ElseIf cStatus == "9"
		cDescri:= "Finalizado"
	EndIf

Return(cDescri)


/*/{Protheus.doc} A100AglPd
Retorna String com os Pedidos de Venda aglutinados na OS
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 21/02/2022
@param cOrdSep, character, Código da OS
@return character, Pedidos
/*/
Static Function A100AglPd(cOrdSep)

	Local cAliasPV	:= GetNextAlias()
	Local cQuery		:= ""
	Local cPedidos	:= ""
	Local aArea		:= GetArea()

	cQuery := "SELECT C9_PEDIDO FROM "+RetSqlName("SC9")+" WHERE C9_ORDSEP = '"+cOrdSep+"' AND "
	cQuery += "C9_FILIAL = '"+xFilial("SC9")+"' AND D_E_L_E_T_ = '' ORDER BY C9_PEDIDO"

	cQuery := ChangeQuery(cQuery)                  
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasPV,.T.,.T.)

	While !(cAliasPV)->(EOF())
		cPedidos += (cAliasPV)->C9_PEDIDO+"/"
		(cAliasPV)->(dbSkip())
	EndDo

	(cAliasPV)->(dbCloseArea())
	RestArea(aArea)

	If Len(cPedidos) > 119
		cPedidos := SubStr(cPedidos,1,119)+"..."
	EndIf

Return( cPedidos )


/*/{Protheus.doc} ValidKIT
Função chamada do campo G1_TPKIT para validar se o Produto é de Apropriação Indireta e nesse caso não pode ter KIT.
Validação existente no campo G1_TPKIT: IIF( Vazio(), .T., U_ValidKIT() )
@type  Function
@author Jorge Alberto - Solutio
@since 25/02/2022
@version 12.1.25
@return logical, .T. se pode usar KIT ou .F. caso contrário
/*/
User Function ValidKIT()
	
	Local lOk        := .T.
	Local lBlkPApInd := SuperGetMv( "MV_PAPRIND", .F., .F. )
	Local cProd      := FwFldGet("G1_COMP")
	Local cTpKIT     := FwFldGet("G1_TPKIT")

	If IsPrdApInd( cProd ) .And. lBlkPApInd
		MsgStop("Produto está configurado como Apropriação Indireta !"+CRLF+"Por isso não pode ser informado um KIT", "Produto sem KIT" )
		lOk := .F.
	ElseIf .NOT. ExistCpo( "SX5", "SZ" + cTpKIT )
		lOk := .F.
	EndIf

Return( lOk )
