#include 'totvs.ch'

/*/{Protheus.doc} FB101FAT
Funcção que complementa inclusão do produto nos pedidos de venda.
Adiciona ao linha posicionada no aCols a quantidade 1 o valor unitário e lista o total dos itens acima
@type function
@author Bruno Silva
@since 27/01/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/User Function FB101FAT()
	Local _aCols := aClone(aCols)
	Local nI
	Local nItem	  := aScan(aHeader,{|x| Alltrim(x[02]) == "C6_ITEM" })
	Local nProd	  := aScan(aHeader,{|x| Alltrim(x[02]) == "C6_PRODUTO" })
	Local nQtdVen := aScan(aHeader,{|x| Alltrim(x[02]) == "C6_QTDVEN" })
	Local nPrcVen := aScan(aHeader,{|x| Alltrim(x[02]) == "C6_PRCVEN" })
	Local nValor  := aScan(aHeader,{|x| Alltrim(x[02]) == "C6_VALOR" })
	Local nPrUnit := aScan(aHeader,{|x| Alltrim(x[02]) == "C6_PRUNIT" })
	Local nTES    := aScan(aHeader,{|x| Alltrim(x[02]) == "C6_TES" })
	Local nCF     := aScan(aHeader,{|x| Alltrim(x[02]) == "C6_CF" })		
	Local nPrcTot := 0
	LOcal _cTit := "Complementar Produto"
	
	If ! N == Len(_aCols)
		MsgAlert("Você deve estar posicionado no último item adicionado.",_cTit)
		Return	
	EndIf	
	If Empty(_aCols[N, nProd]) 
		MsgAlert("Preencha o código do produto.",_cTit)
		Return
	EndIf			
	If ! MsgYesNo("Confirmar o complemento do produto "+ Alltrim(_aCols[N, nProd])+"?")
		Return
	EndIf	
		
	For nI := 1 To Len(_aCols)-1
		If ! _aCols[nI,Len(aHeader)+1] // Desconsidera deletados
			nPrcTot += _aCols[nI, nValor]
		EndIf	 
	Next
	
	// Atualiza aCols
	aCols[N, nQtdVen ] := 1
	aCols[N, nPrcVen ] := nPrcTot
	aCols[N, nPrUnit ] := nPrcTot
	aCols[N, nValor ]  := nPrcTot
	aCols[N, nTES ]    := GetMV("MV_YTES   ")//"507"
	aCols[N, nCF ]     := Posicione("SF4",1,xFilial("SF4") + GetMV("MV_YTES   "),"F4_CF")

Return