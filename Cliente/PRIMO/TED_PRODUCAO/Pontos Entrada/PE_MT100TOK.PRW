#INCLUDE "PROTHEUS.CH"

#define ENTER Chr(13)+Chr(10)

/*/-----------------------------------------------------------------------------------/
{Protheus.doc} MT100TOK
Este P.E. é chamado na função A103Tudok()
Pode ser usado para validar a inclusao da NF.
Esse Ponto de Entrada é chamado 2 vezes dentro da rotina A103Tudok().
Para o controle do número de vezes em que ele é chamado foi criada a variável
lógica lMT100TOK, que quando for definida como (.F.) o ponto de entrada será
chamado somente uma vez.
@obs Programa Fonte: MATA103.PRW
@type  Function
@author Jean Rehermann - Solutio IT
@since 11/09/2020
@return logical, lRet - (LÓGICO) .T. se todas as validações OK ou .F. se houver problema
/-----------------------------------------------------------------------------------/*/
User Function MT100TOK()

	Local lRet        := PARAMIXB[ 1 ]
	Local nPosProd    := aScan( aHeader, { |x| AllTrim(x[2]) == 'D1_COD' } )
	Local nPosCC      := aScan( aHeader, { |x| AllTrim(x[2]) == 'D1_CC' } )
	Local nPosConta   := aScan( aHeader, { |x| AllTrim(x[2]) == 'D1_CONTA' } )
	Local cPctF2Liq   := X3Picture("F2_PLIQUI")
	Local nX          := 0
	Local cAreaAtu    := Alias()
	Local aAreaSD2    := SD2->(GetArea())
	Local aArea       := GetArea()
	Local cProd       := ""
	Local cCC         := ""
	Local cTP         := ""
	Local cConta      := ""
	Local cRet        := ""
	Local cMensagem   := ""
	Local cXCDFIL     := ""
	Local aOrcFut     := {} //Array de Orçamento por Item Contabil
	//Local aOrcPRD	  := {} // Array de Orçamento por Produto
	Local cC7_ITEMCTA := ""


	Local aOrc		:= {} //Valor Orçamento PC

	Local nDiasPag  := SuperGetMV("ES_MT100PG",.F.,0) // Minimo de dias entre Duplicatas e Emissão da NF

	lMT100TOK := .F.

	//Não processa validações DE INUTILIZAÇÕES chamada na rotina MATA920 s
	IF IsInCallStack("SPEDINUT")
		Return( lRet )
	Endif

	//Validação Quantidade Caracteres Documento de Entrada
	If INCLUI .AND.  !(cTipo $ "D") .AND. cFormul<>"S"
		If !U_TEDA030(cNFiscal)
			lRet := .F.
			Return( lRet )
		Endif
	EndIf


	//Validações Condição de Pagamento
	IF  !(Type("lValidCondPag") == "U") .AND.  !lValidCondPag // Necessário PE_MTCOLSE2 para criar variável correta validação.
		cMensagem := "Prazo para vencimento da primeira deve ser de pelo menos " + AllTrim(Str(nDiasPag)) + " dias."
		If SA2->A2_YCND5FE == 'S'
			cMensagem += " E deve cair em Quinta-Feira."
		Endif
		MsgAlert( cMensagem , "Inconsistência (PE_MT100TOK)")

		lRet := .F.
		Return( lRet )
	Endif

	// Jorge Alberto - Solutio - 05/11/2020 - #28532 - Ajuste para não dar erro.
	If( nPosProd <= 0 .Or. nPosConta <= 0 .Or. nPosCC <= 0 )
		Return( lRet )
	EndIf




	For nX := 1 To Len( aCols )

		cProd  := GDFieldGet("D1_COD",nX)
		cConta := GDFieldGet("D1_CONTA",nX)
		cCC    := Left( aCols[ nX, nPosCC ], 2 )
		cTP    := Posicione( "SB1", 1, FWxFilial("SB1") + cProd, "SB1->B1_TIPO" )


		//Posiciona TES:
		DBSelectArea("SF4")
		DBSetOrder(1)
		SF4->(MSSeek(FWxFilial("SF4") +  GDFieldGet("D1_TES",nX)))

		If !GDDeleted(nX) // Não consiste linha deletada
			If !Empty( cProd ) .And. !Empty( cCC )
				If "SV" == cTP
					// O índice é Z2_FILIAL + Z2_PRODUTO + Z2_GRUPO, porém os 2 primeiros caracteres do Centro de Custo, fazem parte do Grupo lá no cadastro da SZ2.
					cRet := Posicione( "SZ2", 1, FWxFilial("SZ2") + cProd + cCC, "SZ2->Z2_CONTA" )
					If !Empty( cRet ) .And. cConta != cRet
						GDFieldPut("D1_CONTA",cRet, nX)
					EndIf
				EndIf
			EndIf

			//Permite CLVL vazio quando for registro de RATEIO (no rateio CLVL é obrigatório)
			IF GDFieldGet("D1_RATEIO",nX) <> '1' .AND. Empty(GDFieldGet("D1_CLVL",nX)) //Se não for Rateio,
				MsgAlert( "Obrigatório preenchimento de Classe de Valor! Item: " + GDFieldGet("D1_ITEM",nX) , "Inconsistência (PE_MT100TOK)")
				lRet := .F.
				Exit
			ENDIF

			//Validação: Não permite Produto de Serviço movimentando estoque
			IF  cTP == "SV"  .AND. SF4->F4_ESTOQUE == 'S'
				MsgAlert( "Não é permitida TES que movimente estoque em produto do tipo SERVIÇO (SV) ! Item: " + GDFieldGet("D1_ITEM",nX) , "Inconsistência (PE_MT100TOK)")
				lRet := .F.
				Exit
			ENDIF


			// Jorge Oliveira - Solutio - 15/10/2020 - Incluida a validação do peso nas Devoluções.
			If cTipo == "D"
				dbSelectArea('SF2')
				dbSetOrder(1) //FILIAL + DOC + SERIE + CLIENTE + LOJA
				If !SF2->( DbSeek(xFilial('SF2') + GDFieldGet("D1_NFORI",nX) + GDFieldGet("D1_SERIORI",nX) + cA100For + cLoja, .F. ) )
					MsgAlert( "NF origem não encontrada! Verifique os dados digitados! Item: " + cValToChar(nX) , "Inconsistência (PE_MT100TOK)")
					lRet := .F.
					Exit
				EndIf

				// Jorge Oliveira - Solutio - 22/10/2020 - Em conversa com a Cristiane ficou definido que se
				// o Peso da NF de origem for zero, então não terá validação do peso na NF de Devolução.
				If SF2->F2_PLIQUI > 0
					If GDFieldGet("D1_PESO",nX) <= 0
						MsgAlert( "O campo 'Peso Total' informado no item " + cValToChar(nX) +" deve ser Positivo !" , "Inconsistência (PE_MT100TOK)")
						lRet := .F.
						Exit
					ElseIf GDFieldGet("D1_PESO",nX) > SF2->F2_PLIQUI
						MsgAlert( "O campo 'Peso Total' informado no item " + cValToChar(nX) +" é maior do que o peso total da NF de Origem " + AllTrim(Transform(SF2->F2_PLIQUI,cPctF2Liq)) , "Inconsistência (PE_MT100TOK)")
						lRet := .F.
						Exit
					EndIf
				EndIf
			EndIf
			// #29848 Validação CC. Mauro - Solutio.
			// CTT_XCDFIL deve ser branco, ou preenchido com conteúdo igual a filial logada.
			cXCDFIL := Posicione( "CTT", 1, FWxFilial("CTT") + cCC, "CTT->CTT_XCDFIL" )
			If !Empty(Alltrim(cXCDFIL))
				If cXCDFIL <> cFilAnt
					MsgAlert("Campo CTT_XCDFIL do centro de custo informado, deve ser igual a branco, ou preenchido com a filial logada. Conteúdo atual: "+Alltrim(cXCDFIL))
					lRet := .F.
					Exit
				EndIf
			EndIf
			// Se TES movimenta estoque, não permite a inclusão.
			If SF4->F4_ESTOQUE == "S" .And. !Empty(Alltrim(cCC))
				MsgAlert("O TES informado, atualiza estoque. O Centro de Custo não pode ser informado nesse caso.")
				lRet := .F.
				Exit
			EndIf
			//--- Fim validação Centro de Custo

			/*
			//----------- Validação Orçamento por Produto
			IF lRet .and. !(cTipo $ "D/B") .AND. !Empty(GDFieldGet("D1_PEDIDO",nx))

				aOrc := u_TDOrcPRD(cProd, dDatabase,GDFieldGet("D1_PEDIDO",nx),GDFieldGet("D1_ITEMPC",nx))

				//Controla Acumulador : a Cada nova linha se já existir acumulador para o item, agrega valor. Senão cria registro no array
				nPos := aScan(aOrcPRD,{|x| x[1] == cProd })
				If  nPos == 0

					nVlRealizado := aOrc[1] + GDFieldGet("D1_TOTAL",nx)
					nVlOrcIni    := aOrc[2]
					nVlOrcado    := aOrc[3]
					nMargemBlq   := aOrc[4]

					//posição----:[-------1------],[---2 -----],[---3---],[---4---],[---5----]
					AADD(aOrcPRD,{cProd,nVlRealizado,nVlOrcIni,nVlOrcado,nMargemBlq})
					nPos := Len(aOrcPRD)
				Else
					aOrcPRD[nPos][2] += GDFieldGet("D1_TOTAL",nx)
				Endif

				nVlRealizado := aOrcPRD[nPos][2]
				nVlOrcado    := aOrcPRD[nPos][4]
				IF nVlRealizado > nVlOrcado
					If !IsBlind()
						MsgAlert("Item: " + GDFieldGet("D1_ITEM",nX) + ". Entrada extrapola orçamento para o PRODUTO " + cProd + " ! Disponível R$ " + STR(nVlOrcado - nVlRealizado), "Orçamento por Produto (SZ3)")
					Endif
					lRet := .F.
				Endif
			Endif
			*/
			//----------- Validação Orçamento por Item Contábil

			//Validação de Orçamento de Compras por Item contábil (Entradas de Entrega Futura)

			IF lRet .and. !(cTipo $ "D/B") .AND. !Empty(GDFieldGet("D1_PEDIDO",nx)) .AND. !Empty(GDFieldGet("D1_ITEMPC",nx))

				//Carrega somatórios por Item Contábil de pedido de compra que seja de entrega futura

				cQuery:= "SELECT C7_ITEMCTA FROM " + RetSqlName("SC7") + " WHERE C7_FILIAL = '" + xFilial("SC7") + "' AND  C7_NUM = '"+ GDFieldGet("D1_PEDIDO",nx) +"' AND C7_ITEM = '"+ GDFieldGet("D1_ITEMPC",nx) +"' AND C7_ENTFUT = 'S' AND D_E_L_E_T_ = ' '"
				cC7_ITEMCTA	:= MpSysExecScalar( cQuery, "C7_ITEMCTA" )

				If !Empty(cC7_ITEMCTA) .AND. cC7_ITEMCTA <> GDFieldGet("D1_ITEMCTA",nx)
					If !IsBlinid()
						MsgAlert("Item Contábil da Nota fiscal difere do informado no Pedido de Compra", "Orçamento por Item Contábil")
					Endif
					lRet := .F.
				Endif

				IF !Empty(cC7_ITEMCTA)


					aOrc := u_TDVlrOrc(cC7_ITEMCTA, dDatabase,GDFieldGet("D1_PEDIDO",nx),GDFieldGet("D1_ITEMPC",nx))

					//Controla Acumulador por Item Contábil: a Cada nova linha se já existir acumulador para o item, agrega valor. Senão cria registro no array
					nPos := aScan(aOrcFut,{|x| x[1] == cC7_ITEMCTA })
					If  nPos == 0

						nVlRealizado := aOrc[1] + GDFieldGet("D1_TOTAL",nx)
						nVlOrcIni    := aOrc[2]
						nVlOrcado    := aOrc[3]
						nMargemBlq   := aOrc[4]

						//posição----:[-------1------],[---2 -----],[---3---],[---4---],[---5----]
						AADD(aOrcFut,{cC7_ITEMCTA,nVlRealizado,nVlOrcIni,nVlOrcado,nMargemBlq})
						nPos := Len(aOrcFut)
					Else
						aOrcFut[nPos][2] += GDFieldGet("D1_TOTAL",nx)
					Endif

					nVlRealizado := aOrcFut[nPos][2]
					nVlOrcado    := aOrcFut[nPos][4]
					IF nVlRealizado > nVlOrcado
						If !IsBlind()
							//MsgAlert("Item: " + GDFieldGet("D1_ITEM",nX) + ". Entrada extrapola orçamento para o Item Contábil informado no PC ! Disponível R$ " + STR(nVlOrcado - nVlRealizado), "Orçamento por Item Contábil")
							MsgAlert("Item: " + GDFieldGet("D1_ITEM",nX) + ". Falta de Saldo no Item conta " + cC7_ITEMCTA + ENTER + "Saldo Atual: R$ " + AllTrim(STR(aOrc[3]-aOrc[1])) + ENTER + "Vlr Item/PC " + GDFieldGet("D1_PEDIDO",nx) + "/" + GDFieldGet("D1_ITEMPC",nx) + " | R$ " + AllTrim(STR(nVlOrcado - nVlRealizado)), "Orçamento por Item Contábil")
						Endif
						lRet := .F.
					Endif
				Endif
			ENDIF

		Endif
	Next nX

	RestArea( aAreaSD2 )
	RestArea( aArea )

	If !Empty( cAreaAtu )
		dbSelectArea( cAreaAtu )
	EndIf

Return( lRet )
