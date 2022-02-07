#INCLUDE 'PROTHEUS.CH'

// Posição dos campos do array aDados
#DEFINE POS_CODFOR		1
#DEFINE POS_LOJAFOR		2
#DEFINE POS_CONDPGTO	3
#DEFINE POS_VALFRETE	4
#DEFINE POS_VDESC_TOT	5
#DEFINE POS_ITENS_PC	6
#DEFINE TAM_DADOS		6 // Tamanho do array com os dados do PC

// Posição dos ITENS do array aDados
#DEFINE POS_IT_ITEMSC7	1
#DEFINE POS_IT_CODPRO	2
#DEFINE POS_IT_LOCAL	3
#DEFINE POS_IT_QUANT	4
#DEFINE POS_IT_PRECO	5
#DEFINE POS_IT_VALDESC	6
#DEFINE POS_IT_OBS		7
#DEFINE POS_IT_CC		8
#DEFINE POS_IT_ITEMCTA	9
#DEFINE POS_IT_KEYSTL	10
#DEFINE TAM_ITENS_DADOS	10 // Tamanho do array dos Itens

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MNTA420P ³ Autor ³ Jorge Alberto-Solutio ³ Data ³18/02/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ PE chamado no final da Inclusao, Alteração e Cancelamento  ³±±
±±³          ³ de uma Ordem de Serviço.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_MNTA420P()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpcx -> 3 = Inclusão ou 4 = Alteração ou 5 = Cancelamento ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL											              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico para a empresa Sirtec                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
User Function MNTA420P()
	Processa( {|| GeraPC()}, "Aguarde... Gerando Pedido de Compra...")
Return

Static Function GeraPC()

	Local nOpcx := PARAMIXB[1]
	Local nPos := 0
	Local nPosPC := 0
	Local nPosFor := 0
	Local nPosLoja := 0
	Local nPosTpReg := 0
	Local nPosProd := 0
	Local nPosQtd := 0
	Local nPosQRec := 0
	Local nPosLocal := 0
	Local nX := 0
	Local nTamC7Total := 0
	Local nTamC7Desc := 0
	Local nTotal := 0
	Local nInsumo := 0
	Local nPosPlano := 0
	Local nPosTaref := 0
	Local nPosSqRel := 0
	Local nValDesc := 0
	Local nTotDesc := 0
	Local nPosDesc := 0
	Local nPosPrUn := 0
	Local aArea := GetArea()
	Local aAreaSTL := STL->( GetArea() )
	Local aCabec := {}
	Local aLinha := {}
	Local aItens := {}
	Local aDados := {}
	Local cAliAtu := Alias()
	Local cNumPc := ""
	Local cMens := ""
	Local cItemCTA := ""
	Local cObs := ""
	Local cChaveSTL := ""
	
	ProcRegua( Len(aGETINS) )

	// Somente Inclusão ou Alteração. No cancelamento não faz nada.
	If ( nOpcx == 3 .Or. nOpcx == 4 )

		Begin Sequence

			// Validar se os campos novos na STJ ( Ordens de Serviço ) estão preenchidos !
			If Empty( STJ->TJ_CONDPAG )
				MsgAlert( "O campo da Condição de Pagamento está vazio, por esse motivo não será gerado o PC." )
				Break
			EndIf

			If Empty( STJ->TJ_VEICULO )
				MsgAlert( "O campo do Veículo está vazio, por esse motivo não será gerado o PC." )
				Break
			EndIf

			nTamC7Total := TamSx3("C7_TOTAL")[2]
			nTamC7Desc := TamSx3("C7_DESC")[2]
			cItemCTA := AllTrim( Posicione( "CTD", 4, xFilial("CTD") + PadR( AllTrim( STJ->TJ_CODBEM ), 40, " " ), "CTD_ITEM" ) )

			// Pega as posições das colunas conforme o cabeçalho
			// Array private aHEAINS criado no padrão da rotina de OS ( MNTA420 )
			nPosPlano := aScan( aHEAINS,{|x| AllTrim(Upper(x[2])) == "TL_PLANO" })
			nPosTaref := aScan( aHEAINS,{|x| AllTrim(Upper(x[2])) == "TL_TAREFA" })
			nPosTpReg := aScan( aHEAINS,{|x| AllTrim(Upper(x[2])) == "TL_TIPOREG" })
			nPosProd  := aScan( aHEAINS,{|x| AllTrim(Upper(X[2])) == "TL_CODIGO" })
			nPosSqRel := aScan( aHEAINS,{|x| AllTrim(Upper(x[2])) == "TL_SEQRELA" })
			nPosFor   := aScan( aHEAINS,{|x| AllTrim(Upper(x[2])) == "TL_FORNEC" })
			nPosLoja  := aScan( aHEAINS,{|x| AllTrim(Upper(x[2])) == "TL_LOJA"   })
			nPosPC    := aScan( aHEAINS,{|x| AllTrim(Upper(x[2])) == "TL_NUMPC"  })
			nPosQtd   := aScan( aHEAINS,{|x| AllTrim(Upper(X[2])) == "TL_QUANTID"})
			nPosQRec  := aScan( aHEAINS,{|x| AllTrim(Upper(X[2])) == "TL_QUANREC"})
			nPosDesc  := aSCAN( aHEAINS,{|x| AllTrim(Upper(X[2])) == "TL_DESCPRD" })
			nPosPrUn  := aSCAN( aHEAINS,{|x| AllTrim(Upper(X[2])) == "TL_PRCUNIT" })
			nPosLocal := aScan( aHEAINS,{|x| AllTrim(Upper(X[2])) == "TL_LOCAL"  })

			If nPosPC <= 0
				MsgAlert( "O campo 'Número do PC' não existe na tabela de Insumos, por esse motivo não será gerado o PC." )
				Break
			EndIf

			// Array private aGETINS criado no padrão da rotina de OS ( MNTA420 )
			For nInsumo := 1 To Len( aGETINS )

				IncProc()

				// Se está deletado OU
				// Se já tem PC OU
				// Se não tem Fornecedor
				If ( aGETINS[nInsumo][Len(aGETINS[nInsumo])] .Or.;
					!Empty( aGETINS[nInsumo][nPosPC] ) .Or.;
					Empty( aGETINS[nInsumo][nPosFor] );
					)

					Loop // passa para o proximo insumo
				EndIf

				If ( STJ->TJ_VALDESC > 0 .And. aGETINS[nInsumo,nPosDesc] > 0 )
					MsgAlert( "Existes descontos na O.S. e no Produto " + AllTrim( aGETINS[nInsumo,nPosProd] ) + ", por esse motivo não será gerado o PC." )
					Loop // passa para o proximo insumo
				EndIf

				// Pega a linha do Fornecedor e Loja
				nPos := aScan( aDados,{ |u| AllTrim(u[POS_CODFOR]) + AllTrim(u[POS_LOJAFOR]) == AllTrim(aGETINS[nInsumo,nPosFor]) + AllTrim(aGETINS[nInsumo,nPosLoja]) } )

				If nPos <= 0
					// Cria um array com as posições conforme o TAM_DADOS
					AADD( aDados, Array(TAM_DADOS) )
					nPos := Len( aDados )

					// Carrega os dados do Cabaçalho do PC
					aDados[ nPos, POS_CODFOR 	] := aGETINS[nInsumo,nPosFor]
					aDados[ nPos, POS_LOJAFOR 	] := aGETINS[nInsumo,nPosLoja]
					aDados[ nPos, POS_CONDPGTO	] := STJ->TJ_CONDPAG
					aDados[ nPos, POS_VALFRETE	] := STJ->TJ_VALFRET
					aDados[ nPos, POS_VDESC_TOT	] := STJ->TJ_VALDESC
					aDados[ nPos, POS_ITENS_PC	] := {}
				EndIf

				// Verifica se o Produto já foi carregado
				nX := aScan( aDados[ nPos, POS_ITENS_PC ], { |u| u[POS_IT_CODPRO] == aGETINS[nInsumo,nPosProd] } )

				If nX <= 0
					// Cria um subarray para os ITENS conforme o TAM_ITENS_DADOS
					AADD( aDados[ nPos, POS_ITENS_PC ], Array(TAM_ITENS_DADOS) )
					nX := Len( aDados[ nPos, POS_ITENS_PC ] )
				EndIf

				cObs := IIF( !Empty(STJ->TJ_OBSERVA), AllTrim( STJ->TJ_OBSERVA ) + ". ", "" )+;
						"Gerado automaticamente a partir da OS " + STJ->TJ_ORDEM + " e Bem " + STJ->TJ_CODBEM

				// Adiciona os itens do PC
				aDados[ nPos, POS_ITENS_PC, nX, POS_IT_ITEMSC7] := StrZero( nX, 4 )
				aDados[ nPos, POS_ITENS_PC, nX, POS_IT_CODPRO ] := aGETINS[nInsumo,nPosProd]
				aDados[ nPos, POS_ITENS_PC, nX, POS_IT_LOCAL  ] := aGETINS[nInsumo,nPosLocal]
				aDados[ nPos, POS_ITENS_PC, nX, POS_IT_QUANT  ] := aGETINS[nInsumo,nPosQtd]
				aDados[ nPos, POS_ITENS_PC, nX, POS_IT_PRECO  ] := aGETINS[nInsumo,nPosPrUn]
				aDados[ nPos, POS_ITENS_PC, nX, POS_IT_VALDESC] := aGETINS[nInsumo,nPosDesc]
				aDados[ nPos, POS_ITENS_PC, nX, POS_IT_OBS 	  ] := cObs
				aDados[ nPos, POS_ITENS_PC, nX, POS_IT_CC 	  ] := STJ->TJ_CCUSTO
				aDados[ nPos, POS_ITENS_PC, nX, POS_IT_ITEMCTA] := cItemCTA

				// Monta uma string com a chave do registro da STL (novo/alterdo)
				cChaveSTL := xFilial("STL")
				cChaveSTL += STJ->TJ_ORDEM

				If nPosPlano > 0
					cChaveSTL += aGETINS[nInsumo,nPosPlano]
				Else
					cChaveSTL += "000000"
				EndIf

				If nPosTaref > 0
					cChaveSTL += aGETINS[nInsumo,nPosTaref]
				Else
					cChaveSTL += "0     "
				EndIf

				cChaveSTL += aGETINS[nInsumo,nPosTpReg]

				cChaveSTL += aGETINS[nInsumo,nPosProd]

				If nPosSqRel > 0
					cChaveSTL += aGETINS[nInsumo,nPosSqRel]
				Else
					cChaveSTL += "0  "
				EndIf

				aDados[ nPos, POS_ITENS_PC, nX, POS_IT_KEYSTL ] := cChaveSTL
										
			Next

			For nPos := 1 To Len( aDados )

				// Aqui faz o cálculo do desconto rateando por todos os itens
				If aDados[ nPos, POS_VDESC_TOT ] > 0

					nTotDesc  := 0
					nValDesc  := Round( aDados[ nPos, POS_VDESC_TOT ] / Len( aDados[ nPos, POS_ITENS_PC ] ), 2 ) // Valor por Produto

					For nX := 1 To Len( aDados[ nPos, POS_ITENS_PC ] )

						aDados[ nPos, POS_ITENS_PC, nX, POS_IT_VALDESC ] := nValDesc
						nTotDesc  := nTotDesc + nValDesc // vai somando o desconto de cada produto

						// Se está no último Produto e tem diferença, deverá pegar o valor do desconto do Produto e somar a diferença.
						If ( nX == Len( aDados[ nPos, POS_ITENS_PC ] ) .And. aDados[ nPos, POS_VDESC_TOT ] <> nTotDesc )
							aDados[ nPos, POS_ITENS_PC, nX, POS_IT_VALDESC ] := nValDesc + ( aDados[ nPos, POS_VDESC_TOT ] - nTotDesc )
						EndIf
						/*
						Desconto total	  Quantidade Prod		Valor desconto por Produto
						13,00			/ 3 				 =	4,33333333333333333
						Produto 1 = 4,33 Valor por produto com arredondamento
						Produto 2 = 4,33 Valor por produto com arredondamento
						Produto 3 = 4,33 Valor por produto com arredondamento
						Total Desconto somando por Produto = 12,99
						Então na última parcela deverá somar a Diferença ou seja 0,01
						*/
					Next
				EndIf
				
			Next

			// Faz a leitura dos registros para a inclusão automática do PC
			For nPos := 1 To Len( aDados )

				Begin Transaction

					cNumPc := GetNumSC7() //GetSXENum( "SC7", "C7_NUM" )
					//ConfirmSX8()

					aCabec := {}
					aItens := {}
					aLinha := {}
					aAdd( aCabec, {"C7_NUM" 	, cNumPc						, Nil })
					//aAdd( aCabec, {"C7_TIPO"	, "1"							, Nil }) // PC
					aAdd( aCabec, {"C7_EMISSAO" , dDataBase						, Nil })
					aAdd( aCabec, {"C7_FORNECE" , aDados[ nPos, POS_CODFOR ]	, Nil })
					aAdd( aCabec, {"C7_LOJA"    , aDados[ nPos, POS_LOJAFOR ]	, Nil })
					aAdd( aCabec, {"C7_TXMOEDA" , 0								, Nil })
					aAdd( aCabec, {"C7_MOEDA"   , 1								, Nil })
					aAdd( aCabec, {"C7_TPFRETE" , "C"						 	, Nil })
					aAdd( aCabec, {"C7_DESPESA"	, CriaVar("C7_DESPESA",.F.)		, NIL })
					aAdd( aCabec, {"C7_SEGURO"	, CriaVar("C7_SEGURO",.F.)		, NIL })
					aAdd( aCabec, {"C7_FRETE"	, aDados[ nPos, POS_VALFRETE]	, Nil })
					aAdd( aCabec, {"C7_COND"    , aDados[ nPos, POS_CONDPGTO ]	, Nil })
					aAdd( aCabec, {"C7_CONTATO" , CriaVar("C7_CONTATO",.F.)		, Nil })
					aAdd( aCabec, {"C7_FILENT"  , cFilAnt						, Nil })

					For nX := 1 To Len( aDados[ nPos, POS_ITENS_PC ] )

						nTotal := NoRound( (aDados[ nPos, POS_ITENS_PC, nX, POS_IT_QUANT ] *;
										   aDados[ nPos, POS_ITENS_PC, nX, POS_IT_PRECO ]);
										 , nTamC7Total )
						
						nPercDesc := NoRound( (aDados[ nPos, POS_ITENS_PC, nX, POS_IT_VALDESC]/nTotal)*100, nTamC7Desc )
						IIF( nPercDesc < 0 .Or. nPercDesc >= 100, nPercDesc := 0, NIL )
							
						aLinha := {}
						aAdd( aLinha, {"C7_ITEM"	, aDados[ nPos, POS_ITENS_PC, nX, POS_IT_ITEMSC7], Nil })
						aAdd( aLinha, {"C7_PRODUTO"	, aDados[ nPos, POS_ITENS_PC, nX, POS_IT_CODPRO ], Nil })
						aAdd( aLinha, {"C7_LOCAL"	, aDados[ nPos, POS_ITENS_PC, nX, POS_IT_LOCAL ] , Nil })
						aAdd( aLinha, {"C7_QUANT"	, aDados[ nPos, POS_ITENS_PC, nX, POS_IT_QUANT ] , Nil })
						aAdd( aLinha, {"C7_PRECO"	, aDados[ nPos, POS_ITENS_PC, nX, POS_IT_PRECO ] , Nil })
						aAdd( aLinha, {"C7_TOTAL"	, nTotal										 , Nil })
						aAdd( aLinha, {"C7_VLDESC"	, aDados[ nPos, POS_ITENS_PC, nX, POS_IT_VALDESC], Nil })
						//aAdd( aLinha, {"C7_DESC"	, nPercDesc										 , Nil })
						aAdd( aLinha, {"C7_OBS"		, aDados[ nPos, POS_ITENS_PC, nX, POS_IT_OBS ]	 , Nil })
						aAdd( aLinha, {"C7_ITEMCTA"	, aDados[ nPos, POS_ITENS_PC, nX, POS_IT_ITEMCTA], Nil })
						aAdd( aLinha, {"C7_CC"		, aDados[ nPos, POS_ITENS_PC, nX, POS_IT_CC ]	 , Nil })
						aAdd( aLinha, {"C7_DATPRF"	, dDataBase										 , Nil })

						aAdd(aItens,aLinha)
						
					Next nX

					lMsErroAuto := .F.
					MSExecAuto( {|v,x,y,z| MATA120(v,x,y,z)}, 1/*Pedido de Compra*/, aCabec, aItens, 3/*Inclusão*/ )

					If lMsErroAuto
						MostraErro()
						DisarmTransaction()
					Else

						DbSelectArea("STL")
						DbSetOrder(1)

						// Processa novamente os ITENS, para atualizar os Insumos(STL) com o Número do PC
						For nX := 1 To Len( aDados[ nPos, POS_ITENS_PC ] )
							If DbSeek( aDados[ nPos, POS_ITENS_PC, nX, POS_IT_KEYSTL ] )
								RecLock("STL",.F.)
									STL->TL_NUMPC := cNumPc
								MsUnLock()
							Else
								MsgAlert( "Não foi possível atualizar o Insumo " + aDados[ nPos, POS_ITENS_PC, nX, POS_IT_CODPRO ] + " com o Pedido gerado." )
							EndIf
						Next
						cMens += "Foi gerado o PC: " + cNumPc + CRLF
					EndIf
				End Transaction
			Next

		End Sequence

	EndIf

	If !Empty( cMens )
		MsgInfo( cMens )
	EndIf

	RestArea( aArea )
	RestArea( aAreaSTL )
	If !Empty( cAliAtu )
		DbSelectArea( cAliAtu )
	EndIf

Return
