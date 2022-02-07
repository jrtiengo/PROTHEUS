#Include "TOTVS.CH"

User Function MT120GRV()
	Local lRet		   := .T.

	Local cNumPC      := PARAMIXB[1]
	Local lInclusao   := PARAMIXB[2]
	Local lAlteracao  := PARAMIXB[3]
	Local aOrcFut     := {} //Array Orçamento provisionado
	Local nX          := 0
	//Local lExclusao   := PARAMIXB[4]

	If lInclusao .or. lAlteracao

		For nX := 1 To Len( aCols )
			//Carrega somatórios por Item Contábil de pedido de compra que NÃO seja de entrega futura

			cC7_ITEMCTA :=  GDFieldGet("C7_ITEMCTA",nx)
			IF !Empty(cC7_ITEMCTA) .AND. GDFieldGet("C7_ENTFUT",nx) <> 'S'


				aOrc := u_TDVlrOrc(cC7_ITEMCTA, dDatabase,cNumPC,GDFieldGet("C7_ITEM",nx))
			
				nVlRealizado := aOrc[1] + GDFieldGet("C7_TOTAL",nx)  + MaFisRet(nx,"IT_IPI")[2] + MaFisRet(nx,"IT_FRETE") + MaFisRet(nx,"IT_DESPESA") - MaFisRet(nx,"IT_DESCONTO")
				nVlOrcIni    := aOrc[2]
				nVlOrcado    := aOrc[3]
				nMargemBlq   := aOrc[4]

				//Controla Acumulador por Item Contábil: a Cada nova linha se já existir acumulador para o item, agrega valor. Senão cria registro no array
				nPos := aScan(aOrcFut,{|x| x[1] == cC7_ITEMCTA })
				If  nPos == 0
					//posição----:[-------1------],[---2 -----],[---3---],[---4---],[---5----]
					AADD(aOrcFut,{cC7_ITEMCTA,nVlRealizado,nVlOrcIni,nVlOrcado,nMargemBlq})
					nPos := Len(aOrcFut)
				Else
					aOrcFut[nPos][2] += nVlRealizado
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
