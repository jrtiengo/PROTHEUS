#Include "PROTHEUS.CH"

/*/{Protheus.doc} MT103MNT
Ponto de entrada MT103MNT que permite permitir carregar o aCols de Múltiplas Naturezas,localizado na pasta Duplicatas.
Sempre será executado logo após a inserção de um Produto no Documento de Entrada, ou seja, sempreapós a linhaok do item da NF.
@type function
@version 1.0
@author Tiengo Junior
@since 09/2025
@Param aHeadSev Array contendo os campos da GetDados de Múltiplas naturezas
@Param aColsSev Array contendo os valores da GetDados de Múltiplas naturezas
@return array, Array com os dados do rateio das naturezas para o aCols
/*/
User Function MT103MNT()

	Local aArea         := FWGetArea()
	Local aHeadSev      := PARAMIXB[1]
	Local aColsSev      := PARAMIXB[2]
	Local nPosCod       := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_COD"})
	Local nPosTes       := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_TES"})
	Local nPosCC        := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_CC"})
	Local nPosTotal     := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_TOTAL"})
	Local nPosItem      := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_ITEM"})
	Local nPosNat       := aScan(aHeadSev, {|x| AllTrim(x[2]) == "EV_NATUREZ"})
	Local nPosPerc      := aScan(aHeadSev, {|x| AllTrim(x[2]) == "EV_PERC"})
	Local nX            := 0
	Local cProduto      := ""
	Local cTes          := ""
	Local cCCusto       := ""
	Local nValor        := 0
	Local cItem         := ""
	Local cNatureza     := ""
	Local nPos          := 0
	Local nI            := 0
	Local aNaturezas    := {}
	Local nTotalDoc     := 0
	Local nSomaPerc     := 0
	Local nDiff         := 0
	Local nMaiorValor   := 0
	Local nPosMaior     := 0
	Local aLinha        := {}
	Local cNatmaior		:= ""

	If Len(aCols) > 0

		aLinha := aClone(aColsSev[1])

		SB1->(DbSetOrder(1))
		SF4->(DbSetOrder(1))
		CTT->(DbSetOrder(1))

		For nX := 1 To Len(aCols)

			If LinDelet(aCols[nX])
				Loop
			Endif

			cProduto := aCols[nX,nPosCod]
			cTes     := aCols[nX,nPosTes]
			cCCusto  := aCols[nX,nPosCC]
			nValor   := aCols[nX,nPosTotal]
			cItem    := cValtochar(aCols[nX,nPosItem])

			nTotalDoc += nValor

			If SB1->(MSSeek(FWxFilial("SB1") + cProduto))
				If SF4->(MSSeek(FWxFilial("SF4") + cTes))

					//Busca o campo B1_XNATATF
					If SF4->F4_ATUATF == 'S'
						cNatureza := AllTrim(SB1->B1_XNATATF)

						//Busca o campo B1_XNATUREZA
					Elseif SF4->F4_DUPLIC == 'S' .And. SF4->F4_ESTOQUE == 'S'
						cNatureza := AllTrim(SB1->B1_XNATUREZA)

						//Busca o campo B1_XNATDES
					Elseif ! Empty(cCCusto)
						If CTT->(MSSeek(FWxFilial("CTT") + cCCusto))
							If CTT->CTT_XTIPOC == '1'
								cNatureza := AllTrim(SB1->B1_XNATDES)
							Endif
						EndIf
					EndIf
				Endif
			Endif

			If ! Empty(cNatureza)
				//Faz uma busca no array para verificar se já existe a natureza em algum item
				nPos := AScan(aNaturezas, {|x| x[1] == cNatureza})
				If nPos > 0
					aNaturezas[nPos][2] += nValor
				Else
					aAdd(aNaturezas, {cNatureza, nValor})
				Endif
			Endif
		Next nX

		If Len(aNaturezas) > 0

			aColsSev := {}

			//Percorre o array de naturezas e calcula o percentual
			For nI := 1 To Len(aNaturezas)

				aAdd(aColsSev, aClone(aLinha))

				cNatureza := aNaturezas[nI][1]
				nValor    := aNaturezas[nI][2]
				nPerc     := (nValor / nTotalDoc) * 100

				aColsSev[Len(aColsSev),nPosNat]      := cNatureza
				aColsSev[Len(aColsSev),nPosPerc]     := nPerc

				nSomaPerc += nPerc

				// Guarda a posição da natureza de maior valor para ajuste de arredondamento
				If nValor > nMaiorValor
					nMaiorValor := nValor
					nPosMaior   := nI
					cNatmaior   := cNatureza
				EndIf
			Next nI

			//Ajuste de Arredondamento
			nDiff := 100 - nSomaPerc
			If nDiff <> 0 .And. nPosMaior > 0 .And. Len(aColsSev) >= nPosMaior
				aColsSev[nPosMaior, nPosPerc] += nDiff
			EndIf
		Endif
	Endif

	//Atualiza a natureza com a natureza de maior valor.
	If ! Empty(cNatmaior)
		MaFisAlt("NF_NATUREZA", cNatmaior)
		GetDRefresh()
	Endif

	FWRestArea(aArea)

Return(aColsSev)

