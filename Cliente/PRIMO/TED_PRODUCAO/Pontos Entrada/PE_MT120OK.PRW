#Include "TOTVS.CH"

User Function MT120OK()
	Local lRet		   := .T.

	Local cNumPC      := cA120Num
	Local aOrcFut     := {} //Array de Orçamento por Item Contabil
	Local aOrcPRD	  := {} // Array de Orçamento por Produto
	Local nX          := 0

	Local cC7_ITEMCTA := ""
	Local cC7_PRODUTO := ""

	If inclui .or. isInCallStack("A120COPIA") .or.  altera
		//----------- Validação Orçamento por Produto
		/*
		For nX := 1 To Len( aCols )

			// Sai do Laço se PC já foi bloqueado
			If !lRet
				EXIT
			Endif
			//Carrega somatórios por Item Contábil de pedido de compra que NÃO seja de entrega futura

			cC7_PRODUTO :=  GDFieldGet("C7_PRODUTO",nx)
			IF !Empty(cC7_PRODUTO) .AND. GDFieldGet("C7_ENTFUT",nx) <> 'S'


				aOrc := u_TDOrcPRD(cC7_PRODUTO, dDatabase,cNumPC,GDFieldGet("C7_ITEM",nx))


				//Controla Acumulador por Item Contábil: a Cada nova linha se já existir acumulador para o item, agrega valor. Senão cria registro no array
				nPos := aScan(aOrcPRD,{|x| x[1] == cC7_PRODUTO })
				If  nPos == 0
					nVlRealizado := aOrc[1] + GDFieldGet("C7_TOTAL",nx)  + MaFisRet(nx,"IT_IPI")[2] + MaFisRet(nx,"IT_FRETE") + MaFisRet(nx,"IT_DESPESA") - MaFisRet(nx,"IT_DESCONTO")
					nVlOrcIni    := aOrc[2]
					nVlOrcado    := aOrc[3]
					nMargemBlq   := aOrc[4]

					//posição----:[-------1------],[---2 -----],[---3---],[---4---],[---5----]
					AADD(aOrcPRD,{cC7_PRODUTO,nVlRealizado,nVlOrcIni,nVlOrcado,nMargemBlq})
					nPos := Len(aOrcPRD)
				Else
					aOrcPRD[nPos][2] +=  GDFieldGet("C7_TOTAL",nx)  + MaFisRet(nx,"IT_IPI")[2] + MaFisRet(nx,"IT_FRETE") + MaFisRet(nx,"IT_DESPESA") - MaFisRet(nx,"IT_DESCONTO")
				Endif

				nVlRealizado := aOrcPRD[nPos][2]
				nVlOrcado    := aOrcPRD[nPos][4]
				IF nVlRealizado > nVlOrcado
					If !IsBlind()
						MsgAlert("Item: " + GDFieldGet("C7_ITEM",nX) + ". Entrada extrapola orçamento para o PRODUTO " + cC7_PRODUTO + " ! Disponível R$ " + STR(nVlOrcado - nVlRealizado), "Orçamento por Produto (SZ3)")
					Endif
					lRet := .F.
				Endif
			Endif

		Next nX
		*/

		//----------- Validação Orçamento por Item Contábil
		For nX := 1 To Len( aCols )

			// Sai do Laço se PC já foi bloqueado
			If !lRet
				EXIT
			Endif
			//Carrega somatórios por Item Contábil de pedido de compra que NÃO seja de entrega futura

			cC7_ITEMCTA :=  GDFieldGet("C7_ITEMCTA",nx)
			IF !Empty(cC7_ITEMCTA) .AND. GDFieldGet("C7_ENTFUT",nx) <> 'S'


				aOrc := u_TDVlrOrc(cC7_ITEMCTA, dDatabase,cNumPC,GDFieldGet("C7_ITEM",nx))


				//Controla Acumulador por Item Contábil: a Cada nova linha se já existir acumulador para o item, agrega valor. Senão cria registro no array
				nPos := aScan(aOrcFut,{|x| x[1] == cC7_ITEMCTA })
				If  nPos == 0
					nVlRealizado := aOrc[1] + GDFieldGet("C7_TOTAL",nx)  + MaFisRet(nx,"IT_IPI")[2] + MaFisRet(nx,"IT_FRETE") + MaFisRet(nx,"IT_DESPESA") - MaFisRet(nx,"IT_DESCONTO")
					nVlOrcIni    := aOrc[2]
					nVlOrcado    := aOrc[3]
					nMargemBlq   := aOrc[4]

					//posição----:[-------1------],[---2 -----],[---3---],[---4---],[---5----]
					AADD(aOrcFut,{cC7_ITEMCTA,nVlRealizado,nVlOrcIni,nVlOrcado,nMargemBlq})
					nPos := Len(aOrcFut)
				Else
					aOrcFut[nPos][2] +=  GDFieldGet("C7_TOTAL",nx)  + MaFisRet(nx,"IT_IPI")[2] + MaFisRet(nx,"IT_FRETE") + MaFisRet(nx,"IT_DESPESA") - MaFisRet(nx,"IT_DESCONTO")
				Endif

				nVlRealizado := aOrcFut[nPos][2]
				nVlOrcado    := aOrcFut[nPos][4]
				IF nVlRealizado > nVlOrcado
					If !IsBlind()
						MsgAlert("Item: " + GDFieldGet("C7_ITEM",nX) + ". Entrada extrapola orçamento para o Item Contábil informado no PC ! Disponível R$ " + STR(nVlOrcado - nVlRealizado), "Orçamento por Item Contábil")
					Endif
					lRet := .F.
				Endif
			Endif

		Next nX
	Endif
Return lRet
