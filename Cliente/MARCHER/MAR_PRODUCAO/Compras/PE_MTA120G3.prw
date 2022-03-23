#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MTA120G3 ºAutor  ³ Jorge Alberto       º Data ³ 17/08/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Utiliza o array que foi atualizado no PE MTA120G1, sendo   º±±
±±º          ³ que nesse PE irá atualizar os itens do Pedido de Compras.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Marcher do Brasil                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MTA120G3()

	Local aProdutos    := PARAMIXB[1]
	Local nPosItem     := 0
	Local nPosAprov    := 0
	Local nProd		    := 0
	
	// Se tem alguma coisa no array E se for inclusão, então atualiza o registro conforme o conteúdo do array.
	If Len( aProdutos ) > 0 .And. INCLUI

		nPosItem  := aScan(aHeader, {|x| AllTrim( X[2] ) == "C7_ITEM" } )
		nPosAprov := aScan(aHeader, {|x| AllTrim( X[2] ) == "C7_APROV" } )
		
		For nProd := 1 To Len( aProdutos )

			// Somente atualiza o Aprovador se o item do PC é o mesmo do array.
			If SC7->C7_ITEM == aProdutos[ nProd, nPosItem ]

				If RecLock("SC7",.F.)
					SC7->C7_APROV   := aProdutos[ nProd, nPosAprov ]
					MsUnlock()
				EndIf

			EndIf
		Next

	EndIf
	
Return
