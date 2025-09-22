#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MT100TOK
Este P.E. é chamado na função A103Tudok() Pode ser usado para validar a inclusao da NF.
Esse Ponto de Entrada é chamado 2 vezes dentro da rotina A103Tudok().
Para o controle do número de vezes em que ele é chamado foi criada a variável
lógica lMT100TOK, que quando for definida como (.F.) o ponto de entrada será chamado somente uma vez.
@type function
@version 1.0
@author Tiengo Junior
@since 09/2025
@return logical, lRet - (LÓGICO) .T. se todas as validações OK ou .F. se houver problema
/*/

User Function MT100TOK()

	Local lRet          := PARAMIXB[1]
	Local nX            := 0
	Local nPosCod       := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_COD"})
	Local nPosTes       := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_TES"})
	Local nPosCC        := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_CC"})
	Local nPosTotal     := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_TOTAL"})
	Local nPosItem      := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_ITEM"})
	Local cMsgErro      := ""

	If Len(aCols) > 0

		SB1->(DbSetOrder(1))
		SF4->(DbSetOrder(1))
		CTT->(DbSetOrder(1))

		For nX := 1 To Len( aCols )

			If LinDelet(aCols[nX])
				Loop
			Endif

			cProduto := aCols[nX,nPosCod]
			cTes     := aCols[nX,nPosTes]
			cCCusto  := aCols[nX,nPosCC]
			nValor   := aCols[nX,nPosTotal]
			cItem    := cValtochar(aCols[nX,nPosItem])

			If SB1->(MSSeek(FWxFilial("SB1") + cProduto))
				If SF4->(MSSeek(FWxFilial("SF4") + cTes))

					//Busca o campo B1_XNATATF
					If SF4->F4_ATUATF == 'S'
						cNatureza := AllTrim(SB1->B1_XNATATF)
						If Empty(cNatureza)
							lRet := .F.
							cMsgErro += "- Item " + cItem + ": Campo B1_XNATATF vazio (TES gera ativo)" + CRLF
						Endif

						//Busca o campo B1_XNATUREZA
					Elseif SF4->F4_DUPLIC == 'S' .And. SF4->F4_ESTOQUE == 'S'
						cNatureza := AllTrim(SB1->B1_XNATUREZA)
						If Empty(cNatureza)
							lRet := .F.
							cMsgErro += "- Item " + cItem + ": Campo B1_XNATUREZA vazio (TES gera Estoque)" + CRLF
						Endif

						//Busca o campo B1_XNATDES
					Elseif ! Empty(cCCusto)
						If CTT->(MSSeek(FWxFilial("CTT") + cCCusto))
							If CTT->CTT_XTIPOC == '1'
								cNatureza := AllTrim(SB1->B1_XNATDES)
								If Empty(cNatureza)
									lRet := .F.
									cMsgErro += "- Item " + cItem + ": Campo B1_XNATDES vazio (CC tipo despesa)" + CRLF
								Endif
							Endif
						EndIf
					EndIf
				Endif
			Endif

		Next nX
	Endif

	If ! lRet .Or.! Empty(cMsgErro)
		Aviso("MT100TOK", cMsgErro, {"OK"}, 3, "Validação Multi-Natureza")
	Endif

Return(lRet)
