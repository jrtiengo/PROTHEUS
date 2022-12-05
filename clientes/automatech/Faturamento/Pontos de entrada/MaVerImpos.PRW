#INCLUDE "PROTHEUS.CH"

/*
nOrig
1 = Pedido de vendas
2 = Proposta
3 = Televendas
Nada = Pedido de Vendas (padrao)                             ad
*/

User Function MaVerImpos( nOrig, lTela )

	Local aArea		:= GetArea()
	Local aAreaSA1	:= SA1->(GetArea())
	Local aFisGet	:= {}
	Local aFisGetCab:= {}
	Local aTitles   := {"Nota Fiscal","Duplicatas","Rentabilidade"}
	Local aDupl     := {}
	Local aVencto   := {}
	Local aFlHead   := {"Vencimento","Valor","OOOOO"}
	Local aEntr     := {}
	Local aDuplTmp  := {}
	Local aRFHead   := { RetTitle("C6_PRODUTO"),RetTitle("C6_VALOR"),"C.M.V","Vlr.Presente","Lucro Bruto","Margem de Contribuição(%)"}
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
	Local nPItem    := 0
	Local nPProvEnt := 0
	Local nPosCfo	:= 0
    Local nPMoeda   := 0
	Local nPSuframa := 0
	Local nUsado    := Len(aHeader)
	Local nX        := 0
	Local nX1       := 0
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
	Local nPropLot  := 0
	Local lDtEmi    := SuperGetMv("MV_DPDTEMI",.F.,.T.)
	Local dDataCnd  := Iif( nOrig == 2, M->ADY_DATA, Iif( nOrig == 3, M->UA_EMISSAO, M->C5_EMISSAO ) )
	Local oDlg
	Local oDupl
	Local oFolder
	Local oRentab
	Local aRentabil := {}
	Local cProduto  := ""
	Local nTotDesc  := 0
	Local lSaldo    := nOrig == 1 .Or. nOrig == Nil
	Local nQtdEnt   := 0
	Local lM410Ipi	:= ExistBlock("M410IPI")
	Local lM410Icm	:= ExistBlock("M410ICM")
	Local lM410Soli	:= ExistBlock("M410SOLI")
	Local lUsaVenc  := .F.
	Local lIVAAju   := .F.
	Local lRastro	 := ExistBlock("MAFISRASTRO")
	Local lRastroLot := .F.
	Local aSolid	:= {}
	Local nLancAp	:=	0
	Local aHeadCDA		:=	{}
	Local aColsCDA		:=	{}
	Local aTransp	:= {"",""}
	Local aSaldos	:= {}
	Local aInfLote	:= {}
	Local aNfOri	:= {}
	Local nAcresUnit:= 0	// Valor do acrescimo financeiro do valor unitario
	Local nAcresTot := 0	// Somatoria dos Valores dos acrescimos financeiros dos itens
	Local dIni		:= Ctod("//") 
	Local cEstado	:= SuperGetMv("MV_ESTADO") 
	Local cTesVend  :=  SuperGetMv("MV_TESVEND",,"")
	Local cCliPed   := "" 
	Local lCfo      := .F.
	Local nlValor	:= 0
	Local nValRetImp := 0
	Local cImpRet 	 := ""
	Local _QnAliqIcm := 0
	Local _QnAliqSol := 0
	Local _QnValIcm  := 0
	Local _QnBaseIcm := 0
	Local _QnValIpi  := 0
	Local _QnBaseIpi := 0
	Local _QnValMerc := 0
	Local _QnValDesc := 0
	Local _QnValSol  := 0
	Local _RQnValSol := 0
	Local _DQnValSol := 0	
    Local _QnBaseSol := 0
	Local _aRet
	
	PRIVATE oLancApICMS
	PRIVATE _nTotOper_ := 0		//total de operacoes (vendas) realizadas com um cliente - calculo de IB - Argentina
	Private _aValItem_ := {}

    U_AUTOM628("MAVERIMPOS")

	If nOrig == 2 //Proposta Comercial
		nPTotal   := aScan(aHeader,{|x| AllTrim(x[2])=="ADZ_TOTAL"})
		nPValDesc := aScan(aHeader,{|x| AllTrim(x[2])=="ADZ_VALDES"})
		nPPrUnit  := aScan(aHeader,{|x| AllTrim(x[2])=="ADZ_PRCTAB"})
		nPPrcVen  := aScan(aHeader,{|x| AllTrim(x[2])=="ADZ_PRCVEN"})
		nPQtdVen  := aScan(aHeader,{|x| AllTrim(x[2])=="ADZ_QTDVEN"})
		nPProduto := aScan(aHeader,{|x| AllTrim(x[2])=="ADZ_PRODUT"})
		nPTES     := aScan(aHeader,{|x| AllTrim(x[2])=="ADZ_TES"})
		nPItem    := aScan(aHeader,{|x| AllTrim(x[2])=="ADZ_ITEM"})
		nPMoeda   := aScan(aHeader,{|x| AllTrim(x[2])=="ADZ_MOEDA"})
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
		nPItem    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})
		nPProvEnt := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PROVENT"})
		nPosCfo   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_CF"})
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca referencias nos Itens                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aFisGet	:= {}
	cAlias2 := Iif( nOrig == 2, "ADZ", Iif( nOrig == 3, "SUB", "SC6" ) )
	/*
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
	*/
	aAdd(aFisGet,{"IT_VALSOL","ADZ_VALDES",U_MaFisOrdem("IT_VALSOL")})
	aSort(aFisGet,,,{|x,y| x[3]<y[3]})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca referencias no cabecalho               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aFisGetCab	:= {}
	cAlias1 := Iif( nOrig == 2, "ADY", Iif( nOrig == 3, "SUA", "SC5" ) )
	/*
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek(cAlias1)
	While !Eof().And.X3_ARQUIVO==cAlias1
		cValid := UPPER(X3_VALID+X3_VLDUSER)
		If 'MAFISGET("'$cValid
			nPosIni 	:= AT('MAFISGET("',cValid)+10
			nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
			cReferencia := Substr(cValid,nPosIni,nLen)
			aAdd(aFisGetCab,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
		EndIf
		If 'MAFISREF("'$cValid
			nPosIni		:= AT('MAFISREF("',cValid) + 10
			cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
			aAdd(aFisGetCab,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
		EndIf
		dbSkip()
	EndDo
	*/
	aAdd(aFisGetCab,{"NF_FRETE","ADY_FRETE",U_MaFisOrdem("NF_FRETE")})
	aSort(aFisGetCab,,,{|x,y| x[3]<y[3]})

	If nOrig == 2 // Proposta comercial (FATA600)
		aCols := ___aColsADZ // Variavel publica preenchida no ponto de entrada FT600TOT
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa a funcao fiscal                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³A Consultoria Tributária, por meio da Resposta à Consulta nº 268/2004, determinou a aplicação das seguintes alíquotas nas Notas Fiscais de venda emitidas pelo vendedor remetente:                                                                         ³
	//³1) no caso previsto na letra "a" (venda para SP e entrega no PR) - aplicação da alíquota interna do Estado de São Paulo, visto que a operação entre o vendedor remetente e o adquirente originário é interna;                                              ³
	//³2) no caso previsto na letra "b" (venda para o DF e entrega no PR) - aplicação da alíquota interestadual prevista para as operações com o Paraná, ou seja, 12%, visto que a circulação da mercadoria se dá entre os Estado de São Paulo e do Paraná.       ³
	//³3) no caso previsto na letra "c" (venda para o RS e entrega no SP) - aplicação da alíquota interna do Estado de São Paulo, uma vez que se considera interna a operação, quando não se comprovar a saída da mercadoria do território do Estado de São Paulo,³
	//³ conforme previsto no art. 36, § 4º do RICMS/SP                                                                                                                                                                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If len(aCols) > 0 .And. ( nOrig == 1 .Or. nOrig == Nil )
		If cEstado == 'SP'
			If !Empty(M->C5_CLIENT) .And. M->C5_CLIENT <> M->C5_CLIENTE
				For nX := 1 To Len(aCols)
			   		If Alltrim(aCols[nX][nPTES])$ Alltrim(cTesVend)
			 			lCfo:= .T.
			 		EndIf
			   	Next		   	
			   	If lCfo		
					dbSelectArea(IIF(M->C5_TIPO$"DB","SA2","SA1"))
					dbSetOrder(1)           
					MsSeek(xFilial()+M->C5_CLIENTE+M->C5_LOJAENT)
					If Iif(M->C5_TIPO$"DB", SA2->A2_EST,SA1->A1_EST) == 'SP'
						cCliPed := M->C5_CLIENTE
					Else
						cCliPed := M->C5_CLIENT
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
//	U_MaFisSave()
//	U_MaFisEnd()

	If nOrig == 2 //Proposta Comercial
		U_MaFisIni(M->ADY_CODIGO,;// 1-Codigo Cliente
			M->ADY_LOJA,;		// 2-Loja do Cliente
			"C",;				// 3-C:Cliente
			"N",;		// 4-Tipo da NF
			Posicione("SA1", 1, xFilial("SA1") + M->ADY_CODIGO + M->ADY_LOJA, "A1_PESSOA"),;// 5-Tipo do Cliente
			Nil,;
			Nil,;
			Nil,;
			"SB1",;
			"MATA461",;
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			aTransp)
	
	ElseIf nOrig == 3 // Televendas
		U_MaFisIni(M->UA_CLIENTE,;// 1-Codigo Cliente
			M->UA_LOJA,;		// 2-Loja do Cliente
			"C",;				// 3-C:Cliente
			"N",;		// 4-Tipo da NF
			Posicione("SA1", 1, xFilial("SA1") + M->UA_CLIENTE + M->UA_LOJA, "A1_PESSOA"),;// 5-Tipo do Cliente
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			"TMKA271",;
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			aTransp)
	
	Else // Pedido de Vendas
		U_MaFisIni(IIf(!Empty(cCliPed),cCliPed,Iif(Empty(M->C5_CLIENT),M->C5_CLIENTE,M->C5_CLIENT)),;// 1-Codigo Cliente/Fornecedor
			M->C5_LOJAENT,;		// 2-Loja do Cliente/Fornecedor
			IIf(M->C5_TIPO$'DB',"F","C"),;				// 3-C:Cliente , F:Fornecedor
			M->C5_TIPO,;				// 4-Tipo da NF
			M->C5_TIPOCLI,;		// 5-Tipo do Cliente/Fornecedor
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			"MATA461",;
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			aTransp)
	
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Agrega os itens para a funcao fiscal         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nPTotal > 0 .And. nPValDesc > 0 .And. nPPrUnit > 0 .And. nPProduto > 0 .And. nPQtdVen > 0 .And. nPTes > 0
		For nX := 1 To Len(aCols)
			nQtdPeso := 0
			If Len(aCols[nX])==nUsado .Or. !aCols[nX][nUsado+1]
				nItem++
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Posiciona Registros                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lSaldo .And. nPItem > 0
					dbSelectArea("SC6")
					dbSetOrder(1)
					MsSeek(xFilial("SC6")+M->C5_NUM+aCols[nX][nPItem]+aCols[nX][nPProduto])
					nQtdEnt := IIf(!SubStr(SC6->C6_BLQ,1,1)$"RS" .And. Empty(SC6->C6_BLOQUEI),SC6->C6_QTDENT,SC6->C6_QTDVEN)
				Else
					lSaldo := .F.
				EndIf
				
				cProduto := aCols[nX][nPProduto]
				MatGrdPrRf(@cProduto)
				SB1->(dbSetOrder(1))
				If SB1->(MsSeek(xFilial("SB1")+cProduto))
					nQtdPeso := If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen])*SB1->B1_PESO
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
	            SB2->(MsSeek(xFilial("SB2")+SB1->B1_COD+Iif( nOrig == 2, "01", aCols[nX][nPLocal] )))
	            SF4->(dbSetOrder(1))
	            SF4->(MsSeek(xFilial("SF4")+aCols[nX][nPTES]))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Calcula o preco de lista                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nValMerc  := If(aCols[nX][nPQtdVen]==0,aCols[nX][nPTotal],If(lSaldo,(aCols[nX][nPQtdVen]-nQtdEnt)*aCols[nX][nPPrcVen],aCols[nX][nPTotal]))
				nPrcLista := aCols[nX][nPPrUnit]
				If ( nPrcLista == 0 )
					nValMerc  := If(aCols[nX][nPQtdVen]==0,aCols[nX][nPTotal],If(lSaldo,(aCols[nX][nPQtdVen]-nQtdEnt)*aCols[nX][nPPrcVen],aCols[nX][nPTotal]))
				EndIf
				If nOrig == 1 .Or. nOrig == Nil
					nAcresUnit:= A410Arred(aCols[nX][nPPrcVen]*M->C5_ACRSFIN/100,"D2_PRCVEN")
					nAcresFin := A410Arred(If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen])*nAcresUnit,"D2_TOTAL")
				EndIf
				nAcresTot += nAcresFin
				nValMerc  += nAcresFin
				nDesconto := a410Arred(nPrcLista*If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen]),"D2_DESCON")-nValMerc
				nDesconto := IIf(nDesconto<=0,aCols[nX][nPValDesc],nDesconto)
				nDesconto := Max(0,nDesconto)
				nPrcLista += nAcresUnit
				nValMerc  += nDesconto

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
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Tratamento do IVA Ajustado - Apenas para pedidos de venda
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
				If nOrig == 1 .Or. nOrig == Nil
				
					SB1->(dbSetOrder(1))
					If SB1->(MsSeek(xFilial("SB1")+cProduto))
		               lIVAAju := IIF(SB1->(FieldPos("B1_IVAAJU")) > 0 .And. SB1->B1_IVAAJU == '1' .And. (IIF(lRastro,lRastroLot := ExecBlock("MAFISRASTRO",.F.,.F.),Rastro(cProduto,"S"))),.T.,.F.)
					EndIf
					dbSelectArea("SC6")
					dbSetOrder(1)
					MsSeek(xFilial("SC6")+M->C5_NUM)
					If lIVAAju
						dbSelectArea("SC9")
						dbSetOrder(1)
						If MsSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM)
							If ( SC9->C9_BLCRED $ "  10"  .And. SC9->C9_BLEST $ "  10")
								While ( !Eof() .And. SC9->C9_FILIAL == xFilial("SC9") .And.;
										SC9->C9_PEDIDO == SC6->C6_NUM .And.;
										SC9->C9_ITEM   == SC6->C6_ITEM )
						
									aadd(aSaldos,{SC9->C9_LOTECTL,SC9->C9_NUMLOTE,,,SC9->C9_QTDLIB})	
				
									dbSelectArea("SC9")
									dbSkip()
								EndDo
							Else
								dbSelectArea("SC6")
								dbSetOrder(1)
								MsSeek(xFilial("SC6")+M->C5_NUM)
								lUsaVenc:= If(!Empty(SC6->C6_LOTECTL+SC6->C6_NUMLOTE),.T.,(SuperGetMv('MV_LOTVENC')=='S'))
								aSaldos := SldPorLote(aCols[nX][nPProduto],aCols[nX][nPLocal],aCols[nX][nPQtdVen]/* nQtdLib*/,0/*nQtdLib2*/,SC6->C6_LOTECTL,SC6->C6_NUMLOTE,SC6->C6_LOCALIZ,SC6->C6_NUMSERI,NIL,NIL,NIL,lUsaVenc,nil,nil,dDataBase)					
							EndIf
						Else
							dbSelectArea("SC6")
							dbSetOrder(1)
							MsSeek(xFilial("SC6")+M->C5_NUM)
							lUsaVenc:= If(!Empty(SC6->C6_LOTECTL+SC6->C6_NUMLOTE),.T.,(SuperGetMv('MV_LOTVENC')=='S'))
							aSaldos := SldPorLote(aCols[nX][nPProduto],aCols[nX][nPLocal],aCols[nX][nPQtdVen]/* nQtdLib*/,0/*nQtdLib2*/,SC6->C6_LOTECTL,SC6->C6_NUMLOTE,SC6->C6_LOCALIZ,SC6->C6_NUMSERI,NIL,NIL,NIL,lUsaVenc,nil,nil,dDataBase)									
						EndIf
						For nX1 := 1 to Len(aSaldos)
							nPropLot := aSaldos[nX1][5]
							If lRastroLot
								dbSelectArea("SB8")
								dbSetOrder(5)
								If MsSeek(xFilial("SB8")+cProduto+aSaldos[nX][01])
									aadd(aInfLote,{SB8->B8_DOC,SB8->B8_SERIE,SB8->B8_CLIFOR,SB8->B8_LOJA,nPropLot})
								EndIf		
							Else				
								dbSelectArea("SB8")
								dbSetOrder(2)
								If MsSeek(xFilial("SB8")+aSaldos[nX][02]+aSaldos[nX][01])
									aadd(aInfLote,{SB8->B8_DOC,SB8->B8_SERIE,SB8->B8_CLIFOR,SB8->B8_LOJA,nPropLot})
								EndIf
							EndIf
							dbSelectArea("SF3")
							dbSetOrder(4)
							If !Empty(aInfLote)
								If MsSeek(xFilial("SF3")+aInfLote[nX1][03]+aInfLote[nX1][04]+aInfLote[nX1][01]+aInfLote[nX1][02])
									aadd(aNfOri,{SF3->F3_ESTADO,SF3->F3_ALIQICM,aInfLote[nX1][05],0})
								EndIf
							EndIf
						Next nX1
					EndIf						
				
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Agrega os itens para a funcao fiscal         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				U_MaFisAdd(cProduto,;   	// 1-Codigo do Produto ( Obrigatorio )
					aCols[nX][nPTES],;	   	// 2-Codigo do TES ( Opcional )
					If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen]),;  	// 3-Quantidade ( Obrigatorio )
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
					0,;					// 14-Valor da Embalagem ( Opiconal )	
					,;					// 15
					,;					// 16
					Iif(nPItem>0,aCols[nX,nPItem],""),; //17
					0,;					// 18-Despesas nao tributadas - Portugal
					0,;					// 19-Tara - Portugal
					Iif( nOrig == 1 .Or. nOrig == Nil, aCols[nX,nPosCfo], Posicione( "SF4", 1, xFilial("SF4")+aCols[nX][nPTES], "F4_CF" ) ) )	// 20-CFO 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Tratamento do IVA Ajustado                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lIVAAju .And. ( nOrig == 1 .Or. nOrig == Nil )
					For nX1 := 1 To Len(aNfOri)
						U_MaFisAddIT("IT_ANFORI2",{aNfOri[nX1][__UFORI],aNfOri[nX1][__ALQORI],aNfOri[nX1][__PROPOR],0},nItem,nX1==1)
					Next nX1			
					aSaldos :={}
					aNfOri  :={}
				EndIf				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Calculo do ISS                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SF4->(dbSetOrder(1))
				SF4->(MsSeek(xFilial("SF4")+aCols[nX][nPTES]))
				If nOrig == 2
					If ( Posicione("SA1", 1, xFilial("SA1") + M->ADY_CODIGO + M->ADY_LOJA, "A1_INCISS") == "N" )
						If ( SF4->F4_ISS=="S" )
							nPrcLista := a410Arred(nPrcLista/(1-(U_MaAliqISS(nItem)/100)),"D2_PRCVEN")
							nValMerc  := a410Arred(nValMerc/(1-(U_MaAliqISS(nItem)/100)),"D2_PRCVEN")
							U_MaFisAlt("IT_PRCUNI",nPrcLista,nItem)
							U_MaFisAlt("IT_VALMERC",nValMerc,nItem)
						EndIf
					EndIf
				ElseIf nOrig == 3
					If ( Posicione("SA1", 1, xFilial("SA1") + M->UA_CLIENTE + M->UA_LOJA, "A1_INCISS") == "N" )
						If ( SF4->F4_ISS=="S" )
							nPrcLista := a410Arred(nPrcLista/(1-(U_MaAliqISS(nItem)/100)),"D2_PRCVEN")
							nValMerc  := a410Arred(nValMerc/(1-(U_MaAliqISS(nItem)/100)),"D2_PRCVEN")
							U_MaFisAlt("IT_PRCUNI",nPrcLista,nItem)
							U_MaFisAlt("IT_VALMERC",nValMerc,nItem)
						EndIf
					EndIf
				Else
					If ( M->C5_INCISS == "N" .And. M->C5_TIPO == "N")
						If ( SF4->F4_ISS=="S" )
							nPrcLista := a410Arred(nPrcLista/(1-(U_MaAliqISS(nItem)/100)),"D2_PRCVEN")
							nValMerc  := a410Arred(nValMerc/(1-(U_MaAliqISS(nItem)/100)),"D2_PRCVEN")
							U_MaFisAlt("IT_PRCUNI",nPrcLista,nItem)
							U_MaFisAlt("IT_VALMERC",nValMerc,nItem)
						EndIf
					EndIf
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Altera peso para calcular frete              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				U_MaFisAlt("IT_PESO",nQtdPeso,nItem)
				U_MaFisAlt("IT_PRCUNI",nPrcLista,nItem)
				U_MaFisAlt("IT_VALMERC",nValMerc,nItem)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Analise da Rentabilidade                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SF4->F4_DUPLIC=="S"
					nTotDesc += U_MaFisRet(nItem,"IT_DESCONTO")
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
					aRentab[nY][3] += If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen])*SB2->B2_CM1
				Else
					If GetNewPar("MV_TPDPIND","1")=="1"
						nTotDesc += U_MaFisRet(nItem,"IT_DESCONTO")
					EndIf
				EndIf
			EndIf
		Next nX
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza alteracoes de referencias do Cabecalho   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aFisGetCab) > 0
		dbSelectArea(cAlias1)
		For nY := 1 to Len(aFisGetCab)
			If !Empty(&("M->"+Alltrim(aFisGetCab[ny][2])))
				U_MaFisAlt(aFisGetCab[ny][1],&("M->"+Alltrim(aFisGetCab[ny][2])),,.F.)
			EndIf
		Next nY
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Indica os valores do cabecalho               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	U_MaFisAlt("NF_VLR_FRT" , Iif( nOrig == 1 .Or. nOrig == Nil, M->C5_VLR_FRT, 0 ) )
	U_MaFisAlt("NF_SEGURO"  , Iif( nOrig == 1 .Or. nOrig == Nil, M->C5_SEGURO , 0 ) )
	U_MaFisAlt("NF_AUTONOMO", Iif( nOrig == 1 .Or. nOrig == Nil, M->C5_FRETAUT, 0 ) )
	U_MaFisAlt("NF_DESPESA" , Iif( nOrig == 1 .Or. nOrig == Nil, M->C5_DESPESA, 0 ) )                 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Indenizacao por valor                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOrig == 1 .Or. nOrig == Nil
		If M->C5_DESCONT > 0
			U_MaFisAlt("NF_DESCONTO",Min(U_MaFisRet(,"NF_VALMERC")-0.01,nTotDesc+M->C5_DESCONT),/*nItem*/,/*lNoCabec*/,/*nItemNao*/,GetNewPar("MV_TPDPIND","1")=="2" )
		EndIf
		
		If M->C5_PDESCAB > 0
			U_MaFisAlt("NF_DESCONTO",A410Arred(U_MaFisRet(,"NF_VALMERC")*M->C5_PDESCAB/100,"C6_VALOR")+U_MaFisRet(,"NF_DESCONTO"))
		EndIf
	EndIf
		
	If ( lM410Ipi .Or. lM410Icm .Or. lM410Soli ) .And. ( nOrig == 1 .Or. nOrig == Nil )
		nItem := 0
		For nX := 1 To Len(aCols)
			If Len(aCols[nX])==nUsado .Or. !aCols[nX][nUsado+1]
				nItem++
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ponto de Entrada M410IPI para alterar os valores do IPI referente a palnilha financeira           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lM410Ipi 
					VALORIPI    := U_MaFisRet(nItem,"IT_VALIPI")
					BASEIPI     := U_MaFisRet(nItem,"IT_BASEIPI")
					QUANTIDADE  := U_MaFisRet(nItem,"IT_QUANT")
					ALIQIPI     := U_MaFisRet(nItem,"IT_ALIQIPI")
					BASEIPIFRETE:= U_MaFisRet(nItem,"IT_FRETE")
					U_MaFisAlt("IT_VALIPI",ExecBlock("M410IPI",.F.,.F.,{ nItem }),nItem,.T.)
					U_MaFisLoad("IT_BASEIPI",BASEIPI ,nItem)
					U_MaFisLoad("IT_ALIQIPI",ALIQIPI ,nItem)
					U_MaFisLoad("IT_FRETE"  ,BASEIPIFRETE,nItem,"11")
					U_MaFisEndLoad(nItem,1)
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ponto de Entrada M410ICM para alterar os valores do ICM referente a palnilha financeira           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lM410Icm
					_BASEICM    := U_MaFisRet(nItem,"IT_BASEICM")
					_ALIQICM    := U_MaFisRet(nItem,"IT_ALIQICM")
					_QUANTIDADE := U_MaFisRet(nItem,"IT_QUANT")
					_VALICM     := U_MaFisRet(nItem,"IT_VALICM")
					_FRETE      := U_MaFisRet(nItem,"IT_FRETE")
					_VALICMFRETE:= U_MaFisRet(nItem,"IT_ICMFRETE")
					_DESCONTO   := U_MaFisRet(nItem,"IT_DESCONTO")
					ExecBlock("M410ICM",.F.,.F., { nItem } )
					U_MaFisLoad("IT_BASEICM" ,_BASEICM    ,nItem)
					U_MaFisLoad("IT_ALIQICM" ,_ALIQICM    ,nItem)
					U_MaFisLoad("IT_VALICM"  ,_VALICM     ,nItem)
					U_MaFisLoad("IT_FRETE"   ,_FRETE      ,nItem)
					U_MaFisLoad("IT_ICMFRETE",_VALICMFRETE,nItem)
					U_MaFisLoad("IT_DESCONTO",_DESCONTO   ,nItem)
					U_MaFisEndLoad(nItem,1)
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ponto de Entrada M410SOLI para alterar os valores do ICM Solidario referente a palnilha financeira³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lM410Soli
					ICMSITEM    := U_MaFisRet(nItem,"IT_VALICM")		// variavel para ponto de entrada
					QUANTITEM   := U_MaFisRet(nItem,"IT_QUANT")		// variavel para ponto de entrada
					BASEICMRET  := U_MaFisRet(nItem,"IT_BASESOL")	    // criado apenas para o ponto de entrada
					MARGEMLUCR  := U_MaFisRet(nItem,"IT_MARGEM")		// criado apenas para o ponto de entrada
					aSolid := ExecBlock("M410SOLI",.f.,.f.,{nItem}) 
					aSolid := IIF(ValType(aSolid) == "A" .And. Len(aSolid) == 2, aSolid,{})
					If !Empty(aSolid)
						U_MaFisLoad("IT_BASESOL",NoRound(aSolid[1],2),nItem)
						U_MaFisLoad("IT_VALSOL" ,NoRound(aSolid[2],2),nItem)
						U_MaFisEndLoad(nItem,1)
					Endif
				EndIf
			EndIf
		Next
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza alteracoes de referencias dos itens      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAlias2)
	If Len(aFisGet) > 0
		For nX := 1 to Len(aCols)
			If Len(aCols[nX])==nUsado .Or. !aCols[nX][Len(aHeader)+1]
				For nY := 1 to Len(aFisGet)
					nPosCpo := aScan(aHeader,{|x| AllTrim(x[2])==Alltrim(aFisGet[ny][2])})
					If nPosCpo > 0
						If !Empty(aCols[nX][nPosCpo])
							U_MaFisAlt(aFisGet[ny][1],aCols[nX][nPosCpo],nX,.F.)
						Endif
					EndIf
				Next
			Endif
			
			U_MaFisRecal("IT_BASEICM",nX)
			U_MaFisRecal("IT_ALIQICM",nX)
			U_MaFisRecal("IT_VALICM",nX)

			U_MaFisLoad("IT_BASESOL",NoRound(U_MaFisRet(nX,"IT_BASEICM"),2),nX)
			U_MaFisRecal("IT_BASESOL",nX)
			U_MaFisRecal("IT_ALIQSOL",nX)
			U_MaFisRecal("IT_VALSOL",nX)

			_QnAliqIcm  := U_MaFisRet(nX,"IT_ALIQICM")
			_QnAliqSol  := U_MaFisRet(nX,"IT_ALIQSOL")
			_QnValIcm   += U_MaFisRet(nX,"IT_VALICM" )
			_QnBaseIcm  += U_MaFisRet(nX,"IT_BASEICM")
			_QnValSol   += U_MaFisRet(nX,"IT_VALSOL")
			_QnValIpi   += U_MaFisRet(nX,"IT_VALIPI" )
			_QnBaseIpi  += U_MaFisRet(nX,"IT_BASEICM")
			_QnValMerc  += U_MaFisRet(nX,"IT_VALMERC")
			_QnValDesc  += U_MaFisRet(nX,"IT_DESCONTO" )
			
			//U_MaFisLoad("IT_VALSOL" ,NoRound(( U_MaFisRet(nX,"IT_BASEICM") * ( _QnAliqSol / 100 ) ) - U_MaFisRet(nX,"IT_VALICM" ),2),nX)
			//U_MaFisEndLoad(nItem,1)

 			_QnValSol   += U_MaFisRet(nX,"IT_VALSOL")

            If aCols[nX][nPmoeda] == "1"
   			   _RQnValSol   += U_MaFisRet(nX,"IT_VALSOL")
   			Else
   			   _DQnValSol   += U_MaFisRet(nX,"IT_VALSOL")
            Endif

		    _QnBaseSol  += U_MaFisRet(nX,"IT_BASESOL")

		Next
	EndIf

	// 1 = Valor do ICMS (Diferencial Aliquota) 
	// 2 = Base do ICMS 
	// 3 = Valor do IPI 
	// 4 = Base do IPI 
	// 5 = Valor Mercadoria 
	// 6 = Desconto 
	// 7 = ICMS Interno 
	// 8 = ICMS Interno em Reais
	// 9 = ICMS Interno em Dolar
	
	_aRet := {_QnValIcm, _QnBaseIcm, _QnValIpi, _QnBaseIpi, _QnValMerc, _QnValDesc, _QnValSol, _RQnValSol, _DQnValSol }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza alteracoes de referencias do SC5 Suframa ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPSuframa:=aScan(aFisGetCab,{|x| x[1] == "NF_SUFRAMA"})
	If !Empty(nPSuframa)
		dbSelectArea(cAlias1)
		If !Empty(&("M->"+Alltrim(aFisGetCab[nPSuframa][2])))
			U_MaFisAlt(aFisGetCab[nPSuframa][1],Iif(&("M->"+Alltrim(aFisGetCab[nPSuframa][2])) == "1",.T.,.F.),nItem,.F.)
		EndIf
	Endif
	If ExistBlock("M410PLNF") .And. ( nOrig == 1 .Or. nOrig == Nil )
		ExecBlock("M410PLNF",.F.,.F.)
	EndIf
	//U_MaFisWrite(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula os venctos conforme a condicao de pagto  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOrig == 1 .Or. nOrig == Nil
		If !M->C5_TIPO == "B"
			If lDtEmi
				dbSelectarea("SE4")
				dbSetOrder(1)
				MsSeek(xFilial("SE4")+M->C5_CONDPAG)
				If ((SE4->E4_TIPO=="9".AND.!(INCLUI.OR.ALTERA)).OR.SE4->E4_TIPO<>"9")				
				
					If SFB->FB_JNS == 'J' .And. cPaisLoc == 'COL'
					    dbSelectArea("SFC")
						dbSetOrder(2)
						If dbSeek(xFilial("SFC") + SF4->F4_CODIGO + "RV0" )
							nValRetImp 	:= U_MaFisRet(,"NF_VALIV2")
							If FC_INCDUPL == '1'
								nlValor := U_MaFisRet(,"NF_BASEDUP") - nValRetImp
							ElseIf FC_INCDUPL == '2'
								nlValor := U_MaFisRet(,"NF_BASEDUP") + nValRetImp
							EndIf
						Elseif dbSeek(xFilial("SFC") + SF4->F4_CODIGO + "RF0" )
							nValRetImp 	:= U_MaFisRet(,"NF_VALIV4")
							If FC_INCDUPL == '1'
								nlValor := U_MaFisRet(,"NF_BASEDUP") - nValRetImp
							ElseIf FC_INCDUPL == '2'
								nlValor := U_MaFisRet(,"NF_BASEDUP") + nValRetImp
							EndIf
						Elseif dbSeek(xFilial("SFC") + SF4->F4_CODIGO + "RC0" )
							nValRetImp 	:= U_MaFisRet(,"NF_VALIV7")
							If FC_INCDUPL == '1'
								nlValor := U_MaFisRet(,"NF_BASEDUP") - nValRetImp
							ElseIf FC_INCDUPL == '2'
								nlValor := U_MaFisRet(,"NF_BASEDUP") + nValRetImp
							EndIf
						Endif
					Else
						nlValor := U_MaFisRet(,"NF_BASEDUP")
					EndIf				
				
					aDupl := Condicao(nlValor,M->C5_CONDPAG,U_MaFisRet(,"NF_VALIPI"),dDataCnd,U_MaFisRet(,"NF_VALSOL"),,,nAcresTot)
					If Len(aDupl) > 0
						For nX := 1 To Len(aDupl)
							nAcerto += aDupl[nX][2]
						Next nX
						aDupl[Len(aDupl)][2] += U_MaFisRet(,"NF_BASEDUP") - nAcerto
			
						aVencto := aClone(aDupl)
						For nX := 1 To Len(aDupl)
							aDupl[nX][2] := TransForm(aDupl[nX][2],PesqPict("SE1","E1_VALOR"))
						Next nX
					Endif
				Else
					aDupl := {{Ctod(""),TransForm(U_MaFisRet(,"NF_BASEDUP"),PesqPict("SE1","E1_VALOR"))}}
					aVencto := {{dDataBase,U_MaFisRet(,"NF_BASEDUP")}}
				EndIf
			Else
				nItem := 0	
				For nX := 1 to Len(aCols)
					If Len(aCols[nX])==nUsado .Or. !aCols[nX][nUsado+1]
						If nPDtEntr > 0
							nItem++
							nPosEntr := Ascan(aEntr,{|x| x[1] == aCols[nX][nPDtEntr]})
			 				If nPosEntr == 0
								Aadd(aEntr,{aCols[nX][nPDtEntr],U_MaFisRet(nItem,"IT_BASEDUP"),U_MaFisRet(nItem,"IT_VALIPI"),U_MaFisRet(nItem,"IT_VALSOL")})
							Else    
								aEntr[nPosEntr][2]+= U_MaFisRet(nItem,"IT_BASEDUP")
								aEntr[nPosEntr][3]+= U_MaFisRet(nItem,"IT_VALIPI")
								aEntr[nPosEntr][4]+= U_MaFisRet(nItem,"IT_VALSOL")
							EndIf
						Endif
					Endif
			    Next
				dbSelectarea("SE4")
				dbSetOrder(1)
				MsSeek(xFilial("SE4")+M->C5_CONDPAG)
				If !(SE4->E4_TIPO=="9")
					For nY := 1 to Len(aEntr)
						nAcerto  := 0
						
						If SFB->FB_JNS $ 'J/S' .And. cPaisLoc == 'COL'
						    
						    dbSelectArea("SFC")
							dbSetOrder(2)
							If dbSeek(xFilial("SFC") + SF4->F4_CODIGO + "RV0" )
								nValRetImp 	:= U_MaFisRet(,"NF_VALIV2")
								If FC_INCDUPL == '1'
									nlValor := aEntr[nY][2] - nValRetImp
								ElseIf FC_INCDUPL == '2'
									nlValor :=aEntr[nY][2] + nValRetImp
								EndIf
							Elseif dbSeek(xFilial("SFC") + SF4->F4_CODIGO + "RF0" )
								nValRetImp 	:= U_MaFisRet(,"NF_VALIV4")
								If FC_INCDUPL == '1'
									nlValor := aEntr[nY][2] - nValRetImp
								ElseIf FC_INCDUPL == '2'
									nlValor := aEntr[nY][2] + nValRetImp
								EndIf
							Elseif dbSeek(xFilial("SFC") + SF4->F4_CODIGO + "RC0" )
								nValRetImp 	:= U_MaFisRet(,"NF_VALIV7")
								If FC_INCDUPL == '1'
									nlValor := aEntr[nY][2] - nValRetImp
								ElseIf FC_INCDUPL == '2'
									nlValor := aEntr[nY][2] + nValRetImp
								EndIf
							Endif
						Else
							nlValor := aEntr[nY][2]
						EndIf
						
						
						aDuplTmp := Condicao(nlValor,M->C5_CONDPAG,aEntr[nY][3],aEntr[nY][1],aEntr[nY][4],,,nAcresTot)
						If Len(aDuplTmp) > 0
							For nX := 1 To Len(aDuplTmp)
								nAcerto += aDuplTmp[nX][2]
							Next nX
							aDuplTmp[Len(aDuplTmp)][2] += aEntr[nY][2] - nAcerto
			
							aVencto := aClone(aDuplTmp)
							For nX := 1 To Len(aDuplTmp)
								aDuplTmp[nX][2] := TransForm(aDuplTmp[nX][2],PesqPict("SE1","E1_VALOR"))
							Next nX
							aEval(aDuplTmp,{|x| Aadd(aDupl,{aEntr[nY][1],x[1],x[2]})})
						EndIf
					Next
				Else
					aDupl := {{Ctod(""),TransForm(U_MaFisRet(,"NF_BASEDUP"),PesqPict("SE1","E1_VALOR"))}}
					aVencto := {{dDataBase,U_MaFisRet(,"NF_BASEDUP")}}
				EndIf
			EndIf
		Else
			aDupl := {{Ctod(""),TransForm(0,PesqPict("SE1","E1_VALOR"))}}
			aVencto := {{dDataBase,0}}
		EndIf
	EndIf

	If Len(aDupl) == 0
		aDupl := {{Ctod(""),TransForm(U_MaFisRet(,"NF_BASEDUP"),PesqPict("SE1","E1_VALOR"))}}
		aVencto := {{dDataBase,U_MaFisRet(,"NF_BASEDUP")}}
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Analise da Rentabilidade - Valor Presente    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//aRentabil := a410RentPV( aCols ,nUsado ,@aRenTab ,@aVencto ,nPTES,nPProduto,nPLocal,nPQtdVen )
	
	If cPaisLoc=="BRA" .And. AliasIndic("CDA")
		aAdd(aTitles,"Lançamentos da Apuração de ICMS")
		nLancAp	:=	Len(aTitles)
	EndIf
	
	If lTela
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a tela de exibicao dos valores fiscais ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE MSDIALOG oDlg TITLE OemToAnsi("Planilha Financeira") FROM 09,00 TO 28,80
		oFolder := TFolder():New(001,001,aTitles,{"HEADER"},oDlg,,,, .T., .F.,315,140)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Folder 1                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		U_MaFisRodape(1,oFolder:aDialogs[1],,{005,001,310,60},Nil,.T.)
		@ 070,005 SAY RetTitle("F2_FRETE")		SIZE 40,10 PIXEL OF oFolder:aDialogs[1]
		@ 070,105 SAY RetTitle("F2_SEGURO")		SIZE 40,10 PIXEL OF oFolder:aDialogs[1]
		@ 070,205 SAY RetTitle("F2_DESCONT")	SIZE 40,10 PIXEL OF oFolder:aDialogs[1]
		@ 085,005 SAY RetTitle("F2_FRETAUT")	SIZE 40,10 PIXEL OF oFolder:aDialogs[1]
		@ 085,105 SAY RetTitle("F2_DESPESA")	SIZE 40,10 PIXEL OF oFolder:aDialogs[1]
		@ 085,205 SAY RetTitle("F2_VALFAT")		SIZE 40,10 PIXEL OF oFolder:aDialogs[1]
		@ 070,050 MSGET U_MaFisRet(,"NF_FRETE")		PICTURE PesqPict("SF2","F2_FRETE",16,2)		SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
		@ 070,150 MSGET U_MaFisRet(,"NF_SEGURO")  	PICTURE PesqPict("SF2","F2_SEGURO",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
		@ 070,250 MSGET U_MaFisRet(,"NF_DESCONTO")	PICTURE PesqPict("SF2","F2_DESCONTO",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
		@ 085,050 MSGET U_MaFisRet(,"NF_AUTONOMO")	PICTURE PesqPict("SF2","F2_FRETAUT",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
		@ 085,150 MSGET U_MaFisRet(,"NF_DESPESA")		PICTURE PesqPict("SF2","F2_DESPESA",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
		@ 085,250 MSGET U_MaFisRet(,"NF_BASEDUP")		PICTURE PesqPict("SF2","F2_VALFAT",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
		@ 105,005 TO 106,310 PIXEL OF oFolder:aDialogs[1]
		@ 110,005 SAY OemToAnsi("Total da Nota")   SIZE 40,10 PIXEL OF oFolder:aDialogs[1]
		@ 110,050 MSGET U_MaFisRet(,"NF_TOTAL")      PICTURE Iif(cPaisLoc=="CHI",TM(0,16,NIL),PesqPict("SF2","F2_VALBRUT",16,2))                   	SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[1]
		@ 110,270 BUTTON OemToAnsi("Sair")			SIZE 040,11 FONT oFolder:aDialogs[1]:oFont ACTION oDlg:End() OF oFolder:aDialogs[1] PIXEL
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Folder 2                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                                                                      
		If lDtEmi
			@ 005,001 LISTBOX oDupl FIELDS TITLE aFlHead[1],aFlHead[2] SIZE 310,095 	OF oFolder:aDialogs[2] PIXEL
		Else	
			@ 005,001 LISTBOX oDupl FIELDS TITLE aFlHead[3],aFlHead[1],aFlHead[2] SIZE 310,095 	OF oFolder:aDialogs[2] PIXEL
		Endif	
		oDupl:SetArray(aDupl)
		oDupl:bLine := {|| aDupl[oDupl:nAt] }
		@ 105,005 TO 106,310 PIXEL OF oFolder:aDialogs[2]
		@ 110,005 SAY RetTitle("F2_VALFAT")		SIZE 40,10 PIXEL OF oFolder:aDialogs[2]
		@ 110,050 MSGET U_MaFisRet(,"NF_BASEDUP")		PICTURE PesqPict("SF2","F2_VALFAT",16,2)	SIZE 50,07 PIXEL WHEN .F. OF oFolder:aDialogs[2]
		@ 110,270 BUTTON OemToAnsi("Sair")			SIZE 040,11 FONT oFolder:aDialogs[1]:oFont ACTION oDlg:End() OF oFolder:aDialogs[2] PIXEL
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Folder 3                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 005,001 LISTBOX oRentab FIELDS TITLE aRFHead[1],aRFHead[2],aRFHead[3],aRFHead[4],aRFHead[5],aRFHead[6] SIZE 310,095 	OF oFolder:aDialogs[3] PIXEL
		@ 110,270 BUTTON OemToAnsi("Sair")			SIZE 040,11 FONT oFolder:aDialogs[3]:oFont ACTION oDlg:End() OF oFolder:aDialogs[3] PIXEL
		If Empty(aRentabil)
			aRentabil   := {{"",0,0,0,0,0}}
		EndIf
		oRentab:SetArray(aRentabil)
		oRentab:bLine := {|| aRentabil[oRentab:nAt] }
		
		If cPaisLoc=="BRA" .And. AliasIndic("CDA")
			oLancApICMS := A410LAICMS(oFolder:aDialogs[nLancAp],{005,001,310,095},@aHeadCDA,@aColsCDA,.T.,.F.)
			@ 110,270 BUTTON OemToAnsi("Sair")			SIZE 040,11 FONT oFolder:aDialogs[nLancAp]:oFont ACTION oDlg:End() OF oFolder:aDialogs[nLancAp] PIXEL		//"Sair"
		EndIf
		
		ACTIVATE MSDIALOG oDlg CENTERED

	EndIf
	
	//U_MaFisEnd()
	//U_MaFisRestore()
	
	RestArea(aAreaSA1)
	RestArea(aArea)

Return(_aRet)

Static Function A410LAICMS(oDlg,aPos,aHeadCDA,aColsCDA,lVisual,lInclui)

	Local	oLancApICMS
	Local	aCmps		:=	{}
	Local	nI			:=	0
	Local	aLAp		:=	A410LancAp()
	Local	cMaskBs		:=	""
	Local	cMaskAlq	:=	""
	Local	cMaskVlr	:=	""
	
	aMHead("CDA","CDA_TPMOVI/CDA_ESPECI/CDA_FORMUL/CDA_NUMERO/CDA_SERIE/CDA_CLIFOR/CDA_LOJA/",@aHeadCDA)
	For nI := 1 To Len(aHeadCDA)
		aAdd(aCmps,aHeadCDA[nI,1])
		
		If "CDA_BASE"==AllTrim(aHeadCDA[nI,2])
			cMaskBs		:=	AllTrim(aHeadCDA[nI,3])
			
		ElseIf "CDA_ALIQ"==AllTrim(aHeadCDA[nI,2])
			cMaskAlq	:=	AllTrim(aHeadCDA[nI,3])
			
		ElseIf "CDA_VALOR"==AllTrim(aHeadCDA[nI,2])
			cMaskVlr	:=	AllTrim(aHeadCDA[nI,3])
		EndIf
	Next nI
	
	If Len(aLAp)==0
		aLAp	:=	{{"","","1",0,0,0,""}}
	EndIf
	
	oLancApICMS	:=	TWBrowse():New( aPos[1],aPos[2],aPos[3],aPos[4],,aCmps,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
	oLancApICMS:SetArray(aLAp)
	oLancApICMS:bLine := {|| {aLAp[oLancApICMS:nAT,1],aLAp[oLancApICMS:nAT,7],aLAp[oLancApICMS:nAT,2],Iif(aLAp[oLancApICMS:nAT,3]=="1","Sim","Não"),Transform(aLAp[oLancApICMS:nAT,4],cMaskBs),Transform(aLAp[oLancApICMS:nAT,5],cMaskAlq),Transform(aLAp[oLancApICMS:nAT,6],cMaskVlr)} }

Return oLancApICMS                

Static Function aMHead(cAlias,cNCmps,aH)

	Local	lRet	:=	.T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva a Integridade dos campos de Bancos de Dados            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cAlias)
	While !Eof() .And. (X3_ARQUIVO==cAlias)
		IF X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .and. !(AllTrim(X3_CAMPO)+"/"$cNCmps)
			AADD(aH,{ Trim(X3Titulo()), ;
				AllTrim(X3_CAMPO),;
				X3_PICTURE,;
				X3_TAMANHO,;
				X3_DECIMAL,;
				X3_VALID,;
				X3_USADO,;
				X3_TIPO,;
				X3_F3,;
				X3_CONTEXT,;
				X3_CBOX,;
				X3_RELACAO})
		Endif
		dbSkip()
	Enddo

Return lRet

Static Function A410LancAp()
	Local	aLancAp	:=	U_MaFisAjIt(,2)
Return aLancAp

