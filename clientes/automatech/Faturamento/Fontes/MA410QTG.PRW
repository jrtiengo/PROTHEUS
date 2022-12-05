/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MA410Impos³ Autor ³ Eduardo Riera         ³ Data ³06.12.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Ma410Impos( nOpc)                                            ³±±
±±³          ³Funcao de calculo dos impostos contidos no pedido de venda   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpc                                                        ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta funcao efetua os calculos de impostos (ICMS,IPI,ISS,etc)³±±
±±³          ³com base nas funcoes fiscais, a fim de possibilitar ao usua- ³±±
±±³          ³rio o valor de desembolso financeiro.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

// Na venda com ST buscar o valor da última compra do produto | ICMS próprio (soma como custo no final do calculo)
// Buscar na CDM | Crédito Adjudicado (subtrai do valor final)
// FISR0178 - Relatório que faz o cálculo

User Function Ma410Qtg( nOpc, nOrig, nFreteRat, nMoedCalc )

	Local aArea		:= GetArea()
	Local aAreaSA1	:= SA1->(GetArea())
	Local aFisGet	:= {}
	Local aFisGetSC5:= {}
	//Local aTitles   := {"Nota Fiscal","Duplicatas","Rentabilidade"} //"Nota Fiscal"######
	Local aDupl     := {}
	Local aVencto   := {}
	//Local aFlHead   := { STR0046,STR0047,STR0063 } //"Vencimento"###"Valor"
	Local aEntr     := {}
	Local aDuplTmp  := {}
	//Local aRFHead   := { RetTitle("C6_PRODUTO"),RetTitle("C6_VALOR"),STR0081,STR0082,STR0083,STR0084} //"C.M.V"###"Vlr.Presente"###"Lucro Bruto"###"Margem de Contribuição(%)"
	Local aRentab   := {}
	Local nPLocal   := 0
	Local nPTotal   := 0
	Local nPValDesc := 0
	Local nPPrUnit  := 0
	Local nPPrcVen  := 0
	Local nPQtdVen  := 0
	Local nPDtEntr  := 0
	Local nPProduto := 0
	Local nPTES     := 0
	Local nPNfOri   := 0
	Local nPSerOri  := 0
	Local nPItemOri := 0
	Local nPIdentB6 := 0
	Local nPSuframa := 0
	Local nUsado    := Len(aHeader)
	Local nX        := 0
	Local nAcerto   := 0
	Local nPrcLista := 0
	Local nValMerc  := 0
	Local nDesconto := 0
	Local nAcresFin := 0
	Local nQtdPeso  := 0
	Local nRecOri   := 0
	Local nPosEntr  := 0
	Local nItem     := 0
	Local nY        := 0 
	Local nPosCpo   := 0
	Local lDtEmi    := SuperGetMv("MV_DPDTEMI",.F.,.T.)
	Local dDataCnd  := Iif( nOrig == 2, M->ADY_DATA, Iif( nOrig == 3, M->UA_EMISSAO, M->C5_EMISSAO ) )
	Local oDlg
	Local oDupl
	Local oFolder
	Local oRentab
	Local lCondVenda := .F. // Template GEM
	Local aRentabil := {}
	Local cProduto  := ""
	Local nTotDesc  := 0
	
    U_AUTOM628("MA410QTG")

	_nDel := Len( aHeader ) + 1 

	If _nDel == Nil
	   Return(.T.)
	Endif

	_lDel := aCols[ n, _nDel ] // Verificando última posição do acols para verificar deleção da linha
	
	If _nDel == Nil
	   Return(.T.)
	Endif

	If _lDel // Se estiver deletado
		Return( .T. )
	EndIf

	If nOrig == 2 //Proposta Comercial
		nPTotal   := aScan(aHeader,{|x| AllTrim(x[2])=="ADZ_TOTAL"})
		nPValDesc := aScan(aHeader,{|x| AllTrim(x[2])=="ADZ_VALDES"})
		nPPrUnit  := aScan(aHeader,{|x| AllTrim(x[2])=="ADZ_PRCTAB"})
		nPPrcVen  := aScan(aHeader,{|x| AllTrim(x[2])=="ADZ_PRCVEN"})
		nPQtdVen  := aScan(aHeader,{|x| AllTrim(x[2])=="ADZ_QTDVEN"})
		nPProduto := aScan(aHeader,{|x| AllTrim(x[2])=="ADZ_PRODUT"})
		nPTES     := aScan(aHeader,{|x| AllTrim(x[2])=="ADZ_TES"})
	ElseIf nOrig == 3 // Televendas
		nPLocal   := aScan(aHeader,{|x| AllTrim(x[2])=="UB_LOCAL"})
		nPTotal   := aScan(aHeader,{|x| AllTrim(x[2])=="UB_VLRITEM"})
		nPValDesc := aScan(aHeader,{|x| AllTrim(x[2])=="UB_VALDESC"})
		nPPrUnit  := aScan(aHeader,{|x| AllTrim(x[2])=="UB_PRCTAB"})
		nPPrcVen  := aScan(aHeader,{|x| AllTrim(x[2])=="UB_VRUNIT"})
		nPQtdVen  := aScan(aHeader,{|x| AllTrim(x[2])=="UB_QUANT"})
		nPDtEntr  := aScan(aHeader,{|x| AllTrim(x[2])=="UB_DTENTRE"})
		nPProduto := aScan(aHeader,{|x| AllTrim(x[2])=="UB_PRODUTO"})
		nPTES     := aScan(aHeader,{|x| AllTrim(x[2])=="UB_TES"})
	Else // Pedido de Vendas
		nPLocal   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCAL"})
		nPTotal   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
		nPValDesc := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALDESC"})
		nPPrUnit  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRUNIT"})
		nPPrcVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
		nPQtdVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
		nPDtEntr  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ENTREG"})
		nPProduto := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
		nPTES     := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
		nPNfOri   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NFORI"}) 
		nPSerOri  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_SERIORI"})
		nPItemOri := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMORI"})
		nPIdentB6 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_IDENTB6"})
	EndIf
    /*
	If nOrig == 2 //Proposta Comercial
	ElseIf nOrig == 3 // Televendas
	Else // Pedido de Vendas
	EndIf
    */
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca referencias nos itens                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aFisGet	:= {}
	cAlias2 := Iif( nOrig == 2, "ADZ", Iif( nOrig == 3, "SUB", "SC6" ) )
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek(cAlias2)
	While !Eof().And.X3_ARQUIVO==cAlias2
		cValid := UPPER(X3_VALID+X3_VLDUSER)
		If 'MAFISGET("'$cValid
			nPosIni 	:= AT('MAFISGET("',cValid)+10
			nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
			cReferencia := Substr(cValid,nPosIni,nLen)
			aAdd(aFisGet,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
		EndIf
		If 'MAFISREF("'$cValid
			nPosIni		:= AT('MAFISREF("',cValid) + 10
			cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
			aAdd(aFisGet,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
		EndIf
		dbSkip()
	EndDo
	aSort(aFisGet,,,{|x,y| x[3]<y[3]})
	
	cAlias1 := Iif( nOrig == 2, "ADY", Iif( nOrig == 3, "SUA", "SC5" ) )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca referencias no cabecalho               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aFisGetSC5	:= {}
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek(cAlias1)
	While !Eof().And.X3_ARQUIVO==cAlias1
		cValid := UPPER(X3_VALID+X3_VLDUSER)
		If 'MAFISGET("'$cValid
			nPosIni 	:= AT('MAFISGET("',cValid)+10
			nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
			cReferencia := Substr(cValid,nPosIni,nLen)
			aAdd(aFisGetSC5,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
		EndIf
		If 'MAFISREF("'$cValid
			nPosIni		:= AT('MAFISREF("',cValid) + 10
			cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
			aAdd(aFisGetSC5,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
		EndIf
		dbSkip()
	EndDo
	aSort(aFisGetSC5,,,{|x,y| x[3]<y[3]})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa a funcao fiscal                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisSave()
	MaFisEnd()

	If nOrig == 2 //Proposta Comercial
		MaFisIni(M->ADY_CODIGO,;// 1-Codigo Cliente
			M->ADY_LOJA,;		// 2-Loja do Cliente
			"C",;				// 3-C:Cliente
			"N",;		// 4-Tipo da NF
			Posicione("SA1", 1, xFilial("SA1") + M->ADY_CODIGO + M->ADY_LOJA, "A1_PESSOA"),;// 5-Tipo do Cliente
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			"FATA300")
	
	ElseIf nOrig == 3 // Televendas
		MaFisIni(M->UA_CLIENTE,;// 1-Codigo Cliente
			M->UA_LOJA,;		// 2-Loja do Cliente
			"C",;				// 3-C:Cliente
			"N",;		// 4-Tipo da NF
			Posicione("SA1", 1, xFilial("SA1") + M->UA_CLIENTE + M->UA_LOJA, "A1_PESSOA"),;// 5-Tipo do Cliente
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			"TMKA271")
	
	Else // Pedido de Vendas
		MaFisIni(Iif(Empty(M->C5_CLIENT),M->C5_CLIENTE,M->C5_CLIENT),;// 1-Codigo Cliente/Fornecedor
			M->C5_LOJAENT,;		// 2-Loja do Cliente/Fornecedor
			IIf(M->C5_TIPO$'DB',"F","C"),;				// 3-C:Cliente , F:Fornecedor
			M->C5_TIPO,;				// 4-Tipo da NF
			M->C5_TIPOCLI,;		// 5-Tipo do Cliente/Fornecedor
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			"MATA461")
	
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza alteracoes de referencias do cabecalho   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aFisGetSC5) > 0
		dbSelectArea(cAlias1)
		For nY := 1 to Len(aFisGetSC5)
			If !Empty(&("M->"+Alltrim(aFisGetSC5[ny][2])))
				MaFisAlt(aFisGetSC5[ny][1],&("M->"+Alltrim(aFisGetSC5[ny][2])),,.F.)
			EndIf
		Next nY
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Agrega os itens para a funcao fiscal         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nPTotal > 0 .And. nPValDesc > 0 .And. nPPrUnit > 0 .And. nPProduto > 0 .And. nPQtdVen > 0 .And. nPTes > 0
		nX := n
			nQtdPeso := 0
			If Len(aCols[nX])==nUsado .Or. !aCols[nX][nUsado+1]
				nItem := n
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Posiciona Registros                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cProduto := aCols[nX][nPProduto]
				MatGrdPrRf(@cProduto)
				SB1->(dbSetOrder(1))
				If SB1->(MsSeek(xFilial("SB1")+cProduto))
					nQtdPeso := aCols[nX][nPQtdVen]*SB1->B1_PESO
				EndIf
	
	        	If nPIdentB6 <> 0 .And. !Empty(aCols[nX][nPIdentB6])
					SD1->(dbSetOrder(4))
					If SD1->(MSSeek(xFilial("SD1")+aCols[nX][nPIdentB6]))
						nRecOri := SD1->(Recno())
					EndIf
	        	ElseIf nPNfOri > 0 .And. nPSerOri > 0 .And. nPItemOri > 0
					If !Empty(aCols[nX][nPNfOri]) .And. !Empty(aCols[nX][nPItemOri])
						SD1->(dbSetOrder(1))
						If SD1->(MSSeek(xFilial("SD1")+aCols[nX][nPNfOri]+aCols[nX][nPSerOri]+M->C5_CLIENTE+M->C5_LOJACLI+aCols[nX][nPProduto]+aCols[nX][nPItemOri]))
							nRecOri := SD1->(Recno())
						EndIf
					EndIf
				EndIf
	            SB2->(dbSetOrder(1))
	            If nOrig == 2 .Or. nOrig == 3
		            SB2->(MsSeek(xFilial("SB2")+SB1->B1_COD+"01"))
	            Else
		            SB2->(MsSeek(xFilial("SB2")+SB1->B1_COD+aCols[nX][nPLocal]))
		  		EndIf
	            SF4->(dbSetOrder(1))
	            SF4->(MsSeek(xFilial("SF4")+aCols[nX][nPTES]))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Calcula o preco de lista                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nValMerc  := Iif( nMoedCalc == 1, aCols[nX][nPTotal], xMoeda( aCols[nX][nPTotal], nMoedCalc, 1, dDataBase, 2 ) )
				nPrcLista := Iif( nMoedCalc == 1, aCols[nX][nPPrUnit], xMoeda( aCols[nX][nPPrUnit], nMoedCalc, 1, dDataBase, 2 ) )
				If ( nPrcLista == 0 )
					nPrcLista := NoRound(nValMerc/aCols[nX][nPQtdVen],TamSX3("C6_PRCVEN")[2])
				EndIf
				If nOrig == 1 .Or. nOrig == Nil
					nAcresFin := A410Arred(aCols[nX][nPPrcVen]*M->C5_ACRSFIN/100,"D2_PRCVEN")
				EndIf
				nValMerc  += A410Arred(aCols[nX][nPQtdVen]*nAcresFin,"D2_TOTAL")
				nDesconto := a410Arred(nPrcLista*aCols[nX][nPQtdVen],"D2_DESCON")-nValMerc
				nDesconto := IIf(nDesconto==0,aCols[nX][nPValDesc],nDesconto)
				nDesconto := Max(0,nDesconto)
				nPrcLista += nAcresFin
	
				//Para os outros paises, este tratamento e feito no programas que calculam os impostos.
				If cPaisLoc=="BRA"
					nValMerc  += nDesconto
				Endif
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica a data de entrega para as duplicatas³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ( nPDtEntr > 0 )
					If ( dDataCnd > aCols[nX][nPDtEntr] .And. !Empty(aCols[nX][nPDtEntr]) )
						dDataCnd := aCols[nX][nPDtEntr]
					EndIf
				Else
					dDataCnd  := Iif( nOrig == 2, M->ADY_DATA, Iif( nOrig == 3, M->UA_EMISSAO, M->C5_EMISSAO ) )
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Agrega os itens para a funcao fiscal         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MaFisAdd(cProduto,;   	// 1-Codigo do Produto ( Obrigatorio )
					aCols[nX][nPTes],;	   	// 2-Codigo do TES ( Opcional )
					aCols[nX][nPQtdVen],;  	// 3-Quantidade ( Obrigatorio )
					nPrcLista,;		  	// 4-Preco Unitario ( Obrigatorio )
					nDesconto,; 	// 5-Valor do Desconto ( Opcional )
					"",;	   			// 6-Numero da NF Original ( Devolucao/Benef )
					"",;				// 7-Serie da NF Original ( Devolucao/Benef )
					nRecOri,;					// 8-RecNo da NF Original no arq SD1/SD2
					0,;					// 9-Valor do Frete do Item ( Opcional )
					0,;					// 10-Valor da Despesa do item ( Opcional )
					0,;					// 11-Valor do Seguro do item ( Opcional )
					0,;					// 12-Valor do Frete Autonomo ( Opcional )
					nValMerc,;			// 13-Valor da Mercadoria ( Obrigatorio )
					0)					// 14-Valor da Embalagem ( Opiconal )	
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Calculo do ISS                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SF4->(dbSetOrder(1))
				SF4->(MsSeek(xFilial("SF4")+aCols[nX][nPTES]))
				If nOrig == 2
					If ( Posicione("SA1", 1, xFilial("SA1") + M->ADY_CODIGO + M->ADY_LOJA, "A1_INCISS") == "N" )
						If ( SF4->F4_ISS=="S" )
							nPrcLista := a410Arred(nPrcLista/(1-(MaAliqISS(nItem)/100)),"D2_PRCVEN")
							nValMerc  := a410Arred(nValMerc/(1-(MaAliqISS(nItem)/100)),"D2_PRCVEN")
							MaFisAlt("IT_PRCUNI",nPrcLista,nItem)
							MaFisAlt("IT_VALMERC",nValMerc,nItem)
						EndIf
					EndIf
				ElseIf nOrig == 3
					If ( Posicione("SA1", 1, xFilial("SA1") + M->UA_CLIENTE + M->UA_LOJA, "A1_INCISS") == "N" )
						If ( SF4->F4_ISS=="S" )
							nPrcLista := a410Arred(nPrcLista/(1-(MaAliqISS(nItem)/100)),"D2_PRCVEN")
							nValMerc  := a410Arred(nValMerc/(1-(MaAliqISS(nItem)/100)),"D2_PRCVEN")
							MaFisAlt("IT_PRCUNI",nPrcLista,nItem)
							MaFisAlt("IT_VALMERC",nValMerc,nItem)
						EndIf
					EndIf
				Else
					If ( M->C5_INCISS == "N" .And. M->C5_TIPO == "N")
						If ( SF4->F4_ISS=="S" )
							nPrcLista := a410Arred(nPrcLista/(1-(MaAliqISS(nItem)/100)),"D2_PRCVEN")
							nValMerc  := a410Arred(nValMerc/(1-(MaAliqISS(nItem)/100)),"D2_PRCVEN")
							MaFisAlt("IT_PRCUNI",nPrcLista,nItem)
							MaFisAlt("IT_VALMERC",nValMerc,nItem)
						EndIf
					EndIf
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Altera peso para calcular frete              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MaFisAlt("IT_PESO",nQtdPeso,nItem)
				MaFisAlt("IT_PRCUNI",nPrcLista,nItem)
				MaFisAlt("IT_VALMERC",nValMerc,nItem)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Analise da Rentabilidade                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SF4->F4_DUPLIC=="S"
					//nTotDesc += MaFisRet(nItem,"IT_DESCONTO")
					nTotDesc += MaFisRet(1,"IT_DESCONTO")
					nY := aScan(aRentab,{|x| x[1] == aCols[nX][nPProduto]})
					If nY == 0
						aadd(aRenTab,{aCols[nX][nPProduto],0,0,0,0,0})
						nY := Len(aRenTab)
					EndIf
					If cPaisLoc=="BRA"
						aRentab[nY][2] += (nValMerc - nDesconto)
					Else
						aRentab[nY][2] += nValMerc
					Endif
					aRentab[nY][3] += aCols[nX][nPQtdVen]*SB2->B2_CM1
				Else
					If GetNewPar("MV_TPDPIND","1")=="1"
						nTotDesc += MaFisRet(nItem,"IT_DESCONTO")
						//nTotDesc += MaFisRet(1,"IT_DESCONTO")
					EndIf
				EndIf
			EndIf
		//Next nX
	EndIf

	// Frete
	//MaFisAlt("NF_FRETE",nFreteRat)
	MaFisAlt("NF_FRETE",0)

	If nOrig == 1 .Or. nOrig == Nil
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Indica os valores do cabecalho               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(SC5->(FieldPos("C5_VLR_FRT")))
			MaFisAlt("NF_VLR_FRT",M->C5_VLR_FRT)
		EndIf	
		MaFisAlt("NF_SEGURO",M->C5_SEGURO)
		MaFisAlt("NF_AUTONOMO",M->C5_FRETAUT)
		MaFisAlt("NF_DESPESA",M->C5_DESPESA)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Indenizacao por valor                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If M->C5_DESCONT > 0
			MaFisAlt("NF_DESCONTO",Min(MaFisRet(,"NF_VALMERC")-0.01,nTotDesc+M->C5_DESCONT),/*nItem*/,/*lNoCabec*/,/*nItemNao*/,GetNewPar("MV_TPDPIND","1")=="2" )
		EndIf
		
		If M->C5_PDESCAB > 0
			MaFisAlt("NF_DESCONTO",A410Arred(MaFisRet(,"NF_VALMERC")*M->C5_PDESCAB/100,"C6_VALOR")+MaFisRet(,"NF_DESCONTO"))
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza alteracoes de referencias do SC6         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAlias2)
	If Len(aFisGet) > 0
		nX := n
		If Len(aCols[nX])==nUsado .Or. !aCols[nX][Len(aHeader)+1]
			For nY := 1 to Len(aFisGet)
				nPosCpo := aScan(aHeader,{|x| AllTrim(x[2])==Alltrim(aFisGet[ny][2])})
				If nPosCpo > 0
					If !Empty(aCols[nX][nPosCpo])
						MaFisAlt(aFisGet[ny][1],aCols[nX][nPosCpo],nX,.F.)
					Endif
				EndIf
			Next ny
		Endif
	EndIf
	
	//MaFisWrite(1)
	
	_QnAliqIcm   := MaFisRet(1,"IT_ALIQICM")
	_QnValIcm    := MaFisRet(1,"IT_VALICM" )
	_QnBaseIcm   := MaFisRet(1,"IT_BASEICM")
	_QnValIpi    := MaFisRet(1,"IT_VALIPI" )
	_QnBaseIpi   := MaFisRet(1,"IT_BASEICM")
	_QnValMerc   := MaFisRet(1,"IT_VALMERC")
	_QnValSol    := MaFisRet(1,"IT_VALSOL" )
	_QnValDesc   := MaFisRet(1,"IT_DESCONTO" )
	_QnPrVen     := MaFisRet(1,"IT_PRCUNI")
	
	//MaFisSave()
	//MaFisEnd()
	//MaFisRestore()
	
	RestArea(aAreaSA1)
	RestArea(aArea)

Return(.T.)

/* Programa para calcular o ICMS ST, adjudicação fiscal e diferencial de alíquota */
User Function CalcST( cProd, cCli, cLoja, nValor, cTes )

	Local _ICMBASE := 0
	Local _ALIBASE := 0
	Local _ICMRETI := 0
	Local _VALBASE := 0
	Local _ALIRETI := 0
	Local _VALRETI := 0
	Local _CUSTENT := 0
	Local _MVA     := 0
	Local _ALIQINT := 0
	Local _BASERED := 0
	Local _TES     := ""
	
	// Campos do Cliente
	Local cEst := Posicione("SA1", 1, xFilial("SA1") + cCli + cLoja, "A1_EST")
	Local cTip := Posicione("SA1", 1, xFilial("SA1") + cCli + cLoja, "A1_TIPO")
	Local cGrp := Posicione("SA1", 1, xFilial("SA1") + cCli + cLoja, "A1_GRPTRIB")

	// Campos da TES
	Local cSol := Posicione("SF4", 1, xFilial("SF4") + cTes, "F4_INCSOL")
	Local cIcm := Posicione("SF4", 1, xFilial("SF4") + cTes, "F4_ICM")
	
	// Campo do Produto
	Local cGtp := Posicione("SB1", 1, xFilial("SB1") + cProd, "B1_GRTRIB")

	// Verifica se o Estado da Empresa Logada é diferente do estado do cliente
	If Alltrim(cEst) == Alltrim(SM0->M0_ESTENT)
		Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _BASERED } )
	Endif
 
	// Verifica se cliente é F = Consumidor Final
	If Alltrim(cTip) <> "F"
		Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _BASERED } )
	Endif

	// Verifica o ICM Solidário
	If cSol <> "S"
		Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _BASERED } )
	Endif

	// Verifica se TES permite calcular ICMS
	If cIcm <> "S"
		Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _BASERED } )
	Endif

	// Pesquisa a excesão fiscal para calculo do produto
	If Select("T_FISCAL") > 0
		T_FISCAL->( dbCloseArea() )
	EndIf

	cSql := ""
	cSql := "SELECT F7_EST    ,"
	cSql += "       F7_TIPOCLI," 
	cSql += "       F7_ALIQINT,"
	cSql += "       F7_ALIQEXT,"
	cSql += "       F7_MARGEM ,"
	cSql += "       F7_ALIQDST "
	cSql += "  FROM " + RetSqlName("SF7")
	cSql += " WHERE F7_GRTRIB  = '" + Alltrim(cGtp) + "'"
	cSql += "   AND F7_EST     = '" + Alltrim(cEst) + "'"
	cSql += "   AND F7_TIPOCLI = '" + Alltrim(cTip) + "'"
	cSql += "   AND F7_GRPCLI  = '" + Alltrim(cGrp) + "'"
	cSql += "   AND D_E_L_E_T_ = ''"
 
	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FISCAL", .T., .T. )
 
	If T_FISCAL->( EOF() )
		If Select("T_FISCAL") > 0
			T_FISCAL->( dbCloseArea() )
		EndIf
		Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _BASERED } )
	Endif

	// Calcula o ICMS ST do produto lido

	_ICMBASE := nValor // Valor passado por parâmetro

    If T_FISCAL->F7_ALIQINT >= T_FISCAL->F7_ALIQDST
   	   _ALIBASE := T_FISCAL->F7_ALIQINT - T_FISCAL->F7_ALIQDST
   	Else
   	   _ALIBASE := T_FISCAL->F7_ALIQDST - T_FISCAL->F7_ALIQINT
   	Endif

	_VALBASE := (_ICMBASE * _ALIBASE) / 100
	 
	_ICMRETI := nValor // Valor passado por parâmetro

    If T_FISCAL->F7_ALIQINT >= T_FISCAL->F7_ALIQDST
   	   _ALIRETI := (T_FISCAL->F7_ALIQINT - T_FISCAL->F7_ALIQDST)
   	Else
   	   _ALIRETI := (T_FISCAL->F7_ALIQDST - T_FISCAL->F7_ALIQINT)
    Endif

	_VALRETI := (_ICMRETI * _ALIRETI) / 100
	
	cSql := ""
	cSql := "SELECT TOP 1 ROUND( ( D1_TOTAL + D1_VALIPI ) / D1_QUANT, 2 ) BASE1, D1_TES "
	cSql += " FROM "+ RetSqlName("SD1")
	cSql += " WHERE " 
	cSql += " D_E_L_E_T_ = '' AND " 
	cSql += " D1_PEDIDO <> '' AND " 
	cSql += " D1_TIPO = 'N' AND " 
	cSql += " D1_COD = '"+ cProd +"' " 
	cSql += " ORDER BY D1_EMISSAO DESC" 
	
	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CUSENT", .T., .T. )

	If T_CUSENT->( EOF() )

		If Select("T_FISCAL") > 0
			T_FISCAL->( dbCloseArea() )
		EndIf

		If Select("T_CUSENT") > 0
			T_CUSENT->( dbCloseArea() )
		EndIf

		Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _BASERED } )

	Endif

	If T_FISCAL->F7_MARGEM > 0

		_CUSTENT := T_CUSENT->BASE1      // Base de cálculo conforme ultimo custo de entrada (preço + ipi)
		_MVA     := T_FISCAL->F7_MARGEM  // Margem (MVA)
		_ALIQINT := T_FISCAL->F7_ALIQINT // Alíquota interna do produto no estado do cliente
        _TES     := T_CUSENT->D1_TES     // Tipo de entrada
        _BASERED := Posicione( "SF4", 1, xFilial("SF4") + _TES, "F4_BASEICM" ) // Percentual de redução da base de ICMS

	EndIf
	
	If Select("T_FISCAL") > 0
		T_FISCAL->( dbCloseArea() )
	EndIf

	If Select("T_CUSENT") > 0
		T_CUSENT->( dbCloseArea() )
	EndIf

Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _BASERED } )
