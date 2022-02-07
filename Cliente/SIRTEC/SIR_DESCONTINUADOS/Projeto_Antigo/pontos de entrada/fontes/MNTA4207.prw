#Include 'Protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MNTA4207 ³ Autor ³ Jorge Alberto-Solutio ³ Data ³19/07/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ PE chamado na confirmacao da Ordem de Servico Corretiva    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_MNTA4207()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
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
User Function MNTA4207()

	Local lRet		:= .T.
	Local aDados	:= {}
	Local nInsumo	:= 0
	Local nPos		:= 0
	Local nDados	:= 0
	Local nPosVlTot	:= 0
	Local nPosFor 	:= 0
	Local nPosLoja	:= 0
	Local nPosPC	:= 0
	Local nPosProd	:= 0
	Local nValDesc	:= 0

	If M->TJ_VALDESC <= 0
		Return( lRet )
	EndIf
	
	nPosVlTot	:= aSCAN( aHeaIns, {|x| AllTrim(Upper(x[2])) == "TL_VLTOTAL" })
	nPosFor 	:= aSCAN( aHeaIns, {|x| AllTrim(Upper(X[2])) == "TL_FORNEC"  })
	nPosLoja	:= aSCAN( aHeaIns, {|x| AllTrim(Upper(X[2])) == "TL_LOJA"    })
	nPosPC		:= aScan( aHeaIns, {|x| AllTrim(Upper(x[2])) == "TL_NUMPC"   })
	nPosProd	:= aScan( aHeaIns, {|x| AllTrim(Upper(X[2])) == "TL_CODIGO"  })
		
	For nInsumo := 1 To Len( aGetIns )
		
		// Se está deletado OU
		// Se já tem PC OU
		// Se não tem Fornecedor
		If ( aGetIns[nInsumo][Len(aGetIns[nInsumo])] .Or.;
			!Empty( aGetIns[nInsumo][nPosPC] ) .Or.;
			Empty( aGetIns[nInsumo][nPosFor] );
			)

			Loop // passa para o proximo insumo
		EndIf
		
		// Se já tem Fornecedor e Loja, então vai somar o valor total de cada Produto ( valor unitário * quantidade ).
		nPos := aScan( aDados, {|x| x[1] == aGetIns[ nInsumo, nPosFor ] .And. x[2] == aGetIns[ nInsumo, nPosLoja ] } )
		If nPos > 0
			// aDados[ nPos, 1 ] codigo do fornecedor
			// aDados[ nPos, 4 ] loja do fornecedor
			// aDados[ nPos, 3 ] codigo do insumo (produto)
			aDados[ nPos, 4 ] := aDados[ nPos, 4 ] + aGetIns[ nInsumo, nPosVlTot ] // soma o valor total de cada insumo (produto)
			// aDados[ nPos, 5 ] valor total de cada insumo (produto)
			aDados[ nPos, 6 ] := aDados[ nPos, 6 ] + 1 // Quantidade de Itens para um mesmo PC
		Else
			AADD( aDados, { aGetIns[ nInsumo, nPosFor ], aGetIns[ nInsumo, nPosLoja ], aGetIns[ nInsumo, nPosProd ], aGetIns[ nInsumo, nPosVlTot ], aGetIns[ nInsumo, nPosVlTot ], 1 } )
		EndIf
		
	Next
	
	// Aqui vai validar para cada Fornecedor e Loja ( que depois irá virar um unico PC ) se o 
	// valor do Desconto da O.S. é maior ou igual do que a soma dos Insumos ( produtos ).
	For nDados := 1 To Len( aDados )
	
		// Desconto por Produto
		nValDesc  := Round( M->TJ_VALDESC / aDados[ nDados, 6 ], 2 )
		
		If M->TJ_VALDESC >= aDados[ nDados, 4 ]
			MsgAlert( "O valor do desconto da O.S. deve ser menor do que o valor total dos Insumos para o Fornecedor " + aDados[ nDados, 1 ], "Validação do Desconto" )
			lRet := .F.
			Exit
		ElseIf nValDesc >= aDados[ nDados, 5 ]
			MsgAlert( "O valor do desconto "+ cValToChar(M->TJ_VALDESC)+" da O.S. dividido pela quantidade de Insumos "+cValToChar(aDados[ nDados, 6 ])+" do Fornecedor " + aDados[ nDados, 1 ] + " é igual a "+cValToChar(nValDesc)+", e esse valor deverá ser menor do que "+cValToChar(aDados[ nDados, 5 ])+" do insumo "+aDados[ nDados, 3 ], "Validação do Desconto" )
			lRet := .F.
			Exit
		EndIf
		
	Next
	
Return( lRet )

