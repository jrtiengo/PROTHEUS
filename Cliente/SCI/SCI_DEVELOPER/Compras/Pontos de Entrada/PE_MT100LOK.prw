#include "protheus.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT100LOK       ºAutor  ³Ary Andrade              01/12/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. Permite validar a linha do Pedido de Compra exigindo os campos    ±±
±±º      referente ao contabil                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function MT100LOK()

Local aArea      := GetArea()
Local aAreaCT1   := CT1->( GetArea() )
Local cConta     := ""
Local lReturn    := .t.
Local nPosCc     := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_CC"})
Local nPosICta   := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_ITEMCTA"})
Local nPosConta  := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_CONTA"})
Local nPosClvl   := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_CLVL"})
Local nPosOper   := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_OPER"})

cConta := aCols[n,nPosConta]  // n=linha      nPosTes=Coluna

If INCLUI
	
	IF Alltrim(aCols[n,nPosOper]) $ '07/08' //cota cortesia e marketing
		IF Empty(aCols[n,nPosCc])
			Alert("Obrigatório informar o Centro de Custo!")
			lReturn := .f.
			
		END
	ELSE
		// posiciona no CT1 para verificar obrigatoriedades
		CT1->( dbSetOrder(1) )
		If CT1->( dbSeek(xFilial('CT1')+cConta) )
			
			If CT1->CT1_CCOBRG == '1' .and. Empty(aCols[n,nPosCc])
				
				Alert("Obrigatório informar o Centro de Custo!")
				lReturn := .f.
				
			EndIf
			
			// CC nao obrig. e nao aceita e o usuario preencheu, nao deixo!
			If CT1->CT1_CCOBRG <> '1' .and. CT1->CT1_ACCUST == '2' .and. ! Empty(aCols[n,nPosCc])
				
				Alert("Centro de Custo não é aceito neste lançamento!")
				lReturn := .f.
				
			EndIf
			
			If CT1->CT1_ITOBRG == '1' .and. Empty(aCols[n,nPosICta])
				
				Alert("Obrigatório informar o Item Contábil!")
				lReturn := .f.
				
			EndIf
			
			// Item nao obrig. e nao aceita e o usuario preencheu, nao deixo!
			If CT1->CT1_ITOBRG <> '1' .and. CT1->CT1_ACITEM == '2' .and. !Empty(aCols[n,nPosICta])
				
				Alert("Item Contabil não é aceito neste lançamento!")
				lReturn := .f.
				
			EndIf
			
		EndIf
	End
EndIf

// reposiciona alias
RestArea(aAreaCT1)
RestArea(aArea)

Return(lReturn)
