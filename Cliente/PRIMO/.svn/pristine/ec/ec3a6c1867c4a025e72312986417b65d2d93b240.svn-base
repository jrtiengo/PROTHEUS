#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/-----------------------------------------------------------------------------------/
{Protheus.doc} TEDR007
Relatório de Faturamento com comparativo de períodos diferentes

@type  User Function
@author Jean Rehermann - Solutio IT
@since 29/09/2020
@return Nil
/-----------------------------------------------------------------------------------/*/

User Function TEDR007()

	Private aRetPar   := {}
	Private aParamBox := {}
	Private aOrdem    := {"Notas","Clientes"}

	aAdd( aParamBox, { 4, "Selecione os tipos de produtos", .F., "Caixas       ", 90, "", .F. } )
	aAdd( aParamBox, { 4, "", .F., "Chapas       ", 90, "", .F. } )
	aAdd( aParamBox, { 4, "", .F., "Exportação   ", 90, "", .F. } )
	aAdd( aParamBox, { 4, "", .F., "Outras Vendas", 90, "", .F. } )
	aAdd( aParamBox, { 1, "Do Cliente  ", Space(6), "", "", "SA1", "", 50, .F. } )
	aAdd( aParamBox, { 1, "Da Loja     ", Space(4), "", "", "", "", 30, .F. } )
	aAdd( aParamBox, { 1, "Até Cliente ", Space(6), "", "", "SA1", "", 50, .F. } )
	aAdd( aParamBox, { 1, "Até Loja    ", Space(4), "", "", "", "", 30, .F. } )
	aAdd( aParamBox, { 1, "Emissão De  ", Ctod("//"), "", "", "", "", 50, .F. } )
	aAdd( aParamBox, { 1, "Emissão Até ", Ctod("//"), "", "", "", "", 50, .F. } )
	aAdd( aParamBox, { 1, "Comparar de ", Ctod("//"), "", "", "", "", 50, .F. } )
	aAdd( aParamBox, { 1, "Comparar Até", Ctod("//"), "", "", "", "", 50, .F. } )
	aAdd( aParamBox, { 2, "Ordenar Por ", "Notas", aOrdem, 60, "", .F. } )

	If ParamBox( aParamBox, "Parâmetros ", aRetPar )
		If !aRetPar[ 01 ] .And. !aRetPar[ 02 ] .And. !aRetPar[ 03 ] .And. !aRetPar[ 04 ]
			MsgAlert("É necessário escolher pelo menos uma opção entre caixas, chapas, exportação ou outras vendas")
		Else
			Processa( {|| GeraPrt() }, "Gerando o relatório..." )
		EndIf
	EndIf

Return()

/*/-----------------------------------------------------------------/
	{Protheus.doc} GeraPrt
	Geração dos dados para impressão e preparação do relatório
	@type  Static Function
	@author Jean Rehermann - Solutio IT
	@since 30/09/2020
	@return Nil
/-----------------------------------------------------------------/*/
Static Function GeraPrt()

	Local cDesc1  := "Este programa irá emitir o relatório de faturamento de "
	Local cDesc2  := "caixas e chapas podendo ser comparado com outro período."
	Local cDesc3  := ""

	Private nomeprog :="TEDR007"
	Private cabec1,cabec2,nLastKey:=0,titulo,wnrel,tamanho:="G",m_pag:=1
	Private aReturn:={"Zebrado",1,"Administracao",1,2,1,"",1}
	Private cAlias1 := ""
	Private cQuery1 := ""

	titulo:= "Faturamento comparativo - "+ Iif( aRetPar[ 13 ] == "Clientes", "por Clientes + Notas", "por Notas" )
	If aRetPar[ 13 ] == "Clientes"
		cabec1:= " Cliente  Loja   Nome"
		cabec2:= " Tipo    Nro NF    Ser. Emissão        Valor Nota        IPI  Peso(Kg)  Área Total    Un.C/IPI   PM.C/IPI   Total C/IPI   Gramatura"
	Else
		cabec1:= " Tipo    Nro NF    Ser. Clie./Loja Nome Cliente                   Emissão       Valor Nota        IPI     Peso(Kg)  Área Total   Un.C/IPI   PM.C/IPI   Total C/IPI   Gramatura"
		cabec2:= ""
	EndIf

	wnrel:="TEDR007"
	wnrel:=SetPrint(cAlias1,wnrel,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho,,.F.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn)

	If nLastKey == 27
		Return
	Endif

	cQuery1 := "SELECT TIPO_PROD, "
	cQuery1 += "       DOCUMENTO, "
	cQuery1 += "       SERIE, "
	cQuery1 += "       CLIENTE, "
	cQuery1 += "       LOJA, "
	cQuery1 += "       NOME, "
	cQuery1 += "       EMISSAO, "
	cQuery1 += "       MERCADORIA      VAL_MERC, "
	cQuery1 += "       SUM(IPI)        VAL_IPI, "
	cQuery1 += "       PESO            PESO_LIQ, "
	cQuery1 += "       SUM(AREA)       AREA_TOT, "
	cQuery1 += "       SUM(QUANTIDADE) QTD_TOT "
	cQuery1 += "FROM  (SELECT D2_DOC                     DOCUMENTO, "
	cQuery1 += "              D2_SERIE                   SERIE, "
	cQuery1 += "              D2_CLIENTE                 CLIENTE, "
	cQuery1 += "              D2_LOJA                    LOJA, "
	cQuery1 += "              A1_NOME                    NOME, "
	cQuery1 += "              D2_EMISSAO                 EMISSAO, "
	cQuery1 += "              F2_PLIQUI                  PESO, "
	cQuery1 += "              F2_VALMERC                 MERCADORIA, "
	cQuery1 += "              D2_VALIPI                  IPI, "
	cQuery1 += "              SD2.D2_QUANT * SB1.B1_AREA AREA, "
	cQuery1 += "              SD2.D2_QUANT               QUANTIDADE, "
	cQuery1 += "              CASE "
	If aRetPar[ 03 ] // Com Exportação
		cQuery1 += "                WHEN LEFT(SB1.B1_POSIPI, 8) = '48191000' AND LEFT(SD2.D2_CF, 1) <> '7' THEN 'CAIXA' "
		cQuery1 += "                WHEN LEFT(SB1.B1_POSIPI, 8) = '48081000' AND LEFT(SD2.D2_CF, 1) <> '7' THEN 'CHAPA' "
		cQuery1 += "                WHEN LEFT(SD2.D2_CF, 1) = '7' THEN 'EXPORT' "
	Else // Sem exportação
		cQuery1 += "                WHEN LEFT(SB1.B1_POSIPI, 8) = '48191000' THEN 'CAIXA' "
		cQuery1 += "                WHEN LEFT(SB1.B1_POSIPI, 8) = '48081000' THEN 'CHAPA' "
	Endif
	cQuery1 += "                ELSE 'OUTROS' "
	cQuery1 += "              END                        AS TIPO_PROD "
	cQuery1 += "       FROM   "+ RetSqlName("SD2") +" SD2 "
	cQuery1 += "              INNER JOIN "+ RetSqlName("SB1") +" SB1 "
	cQuery1 += "                      ON SD2.D2_COD = SB1.B1_COD "
	cQuery1 += "              INNER JOIN "+ RetSqlName("SA1") +" SA1 "
	cQuery1 += "                      ON SD2.D2_CLIENTE = SA1.A1_COD "
	cQuery1 += "                         AND SD2.D2_LOJA = SA1.A1_LOJA "
	cQuery1 += "              INNER JOIN "+ RetSqlName("SF2") +" SF2 "
	cQuery1 += "                      ON SD2.D2_FILIAL = SF2.F2_FILIAL "
	cQuery1 += "                         AND SD2.D2_DOC = SF2.F2_DOC "
	cQuery1 += "                         AND SD2.D2_SERIE = SF2.F2_SERIE "
	cQuery1 += "                         AND SD2.D2_CLIENTE = SF2.F2_CLIENTE "
	cQuery1 += "                         AND SD2.D2_LOJA = SF2.F2_LOJA "
	cQuery1 += "       WHERE  SD2.D_E_L_E_T_ <> '*' "
	cQuery1 += "              AND SF2.D_E_L_E_T_ <> '*' "
	cQuery1 += "              AND SB1.D_E_L_E_T_ <> '*' "
	cQuery1 += "              AND SA1.D_E_L_E_T_ <> '*' "
	cQuery1 += "              AND SD2.D2_FILIAL = '"+ xFilial("SD2") +"'"
	cQuery1 += "              AND SF2.F2_FILIAL = '"+ xFilial("SF2") +"'"
	cQuery1 += "              AND SD2.D2_CLIENTE BETWEEN '"+ aRetPar[ 05 ] +"' AND '"+ aRetPar[ 07 ] +"' "
	cQuery1 += "              AND SD2.D2_LOJA BETWEEN '"+ aRetPar[ 06 ] +"' AND '"+ aRetPar[ 08 ] +"' "
	cQuery1 += "              AND SD2.D2_EMISSAO BETWEEN '"+ DtoS( aRetPar[ 09 ] ) +"' AND '"+ DtoS( aRetPar[ 10 ] ) +"' "

	If ( aRetPar[ 01 ] .And. aRetPar[ 02 ] ) // Caixas e Chapas marcados
		If !aRetPar[ 04 ]
			cQuery1 += "              AND ( LEFT(SB1.B1_POSIPI, 8) = '48191000' OR LEFT(SB1.B1_POSIPI, 8) = '48081000' )"
		EndIf
	ElseIf ( !aRetPar[ 01 ] .And. !aRetPar[ 02 ] ) // Nem caixas nem Chapas marcadaos
		cQuery1 += "              AND ( LEFT(SB1.B1_POSIPI, 8) <> '48191000' AND LEFT(SB1.B1_POSIPI, 8) <> '48081000' )"
	Else // Se Caixa ou Chapa marcado (um OU outro)
		If !aRetPar[ 04 ]
			If aRetPar[ 01 ] // Caixa
				cQuery1 += "              AND LEFT(SB1.B1_POSIPI, 8) = '48191000' "
			EndIf
			If aRetPar[ 02 ] // Chapa
				cQuery1 += "              AND LEFT(SB1.B1_POSIPI, 8) = '48081000' "
			EndIf
		EndIf
	EndIf

	cQuery1 += "              AND SD2.D2_CF NOT IN ( '5924', '6151', '5949', '6922', "
	cQuery1 += "                                     '5911', '6911' )) TABELAO "
	cQuery1 += "GROUP  BY TIPO_PROD, "
	cQuery1 += "          DOCUMENTO, "
	cQuery1 += "          SERIE, "
	cQuery1 += "          CLIENTE, "
	cQuery1 += "          LOJA, "
	cQuery1 += "          NOME, "
	cQuery1 += "          EMISSAO, "
	cQuery1 += "          PESO, "
	cQuery1 += "          MERCADORIA "

	If aRetPar[ 13 ] == "Clientes"
		cQuery1 += "ORDER  BY NOME ASC, "
		cQuery1 += "          DOCUMENTO ASC "
	Else
		cQuery1 += "ORDER  BY DOCUMENTO ASC "
	EndIf

	//MemoWrite("c:\temp\query_ted.txt",cQuery1)
	TCQuery cQuery1 New Alias ( cAlias1 := GetNextAlias() )

	RptStatus( { || TR007IMP() }, Titulo, "Gerando o relatório" )

	(cAlias1)->( dbCloseArea() )

	RptStatus( { || DevFatPrt() }, Titulo, "Gerando o relatório" ) // Imprime as devoluções ao final

	If aReturn[5] == 1
		Set Printer TO
		dbCommitAll()
		ourspool(wnrel)
	Endif

	MS_FLUSH()

Return()

/*/-----------------------------------------------------------------/
	{Protheus.doc} TR007IMP
	Função que realiza a impressão do detalhe.
	@type  Static Function
	@author Jean Rehermann - Solutio IT
	@since 30/09/2020
	@return Nil
/-----------------------------------------------------------------/*/
Static Function TR007IMP()

	Local nRecs     := 0
	Local cCliAtu   := ""
	Local cCodCli   := ""
	Local lFirst    := .T.

	Local nVlrUnIpi := 0
	Local nPrcMdIpi := 0
	Local nVlTotIpi := 0
	Local nGrmtrMed := 0

	Local nTCLiNF  := 0
	Local nTClIPI  := 0
	Local nTCliPL  := 0
	Local nTCliM2  := 0
	Local nTCliQt  := 0

	Local nTCLiNFG := 0
	Local nTClIPIG := 0
	Local nTCliPLG := 0
	Local nTCliM2G := 0
	Local nTCliQtG := 0

	Private li := 8

	Count To nRecs
	(cAlias1)->( dbGotop() )

	SetRegua( nRecs )
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18);li:=9

	While !(cAlias1)->( Eof() )

		If aRetPar[ 13 ] == "Clientes"

			If cCliAtu <> (cAlias1)->NOME

				If lFirst // Não precisa finalizar
					lFirst := .F.
				Else // Finaliza com o total do cliente anterior
					li++
					If li >= 65
						cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18);li:=9
					Endif

					nVlTotIpi := Round( nTCLiNF + nTClIPI, 2 )
					nVlrUnIpi := Round( nVlTotIpi / nTCliQt, 2 )
					nPrcMdIpi := Round( nVlTotIpi / nTCliPL, 2 )
					nGrmtrMed := Round( nTCliPL / nTCliM2, 2 )

					@li,001 PSAY "Total do Cliente:"
					@li,033 PSAY TransForm( nTCLiNF, "@E 999,999,999.99" ) + Space(3) +;
					TransForm( nTClIPI  , "@E 999,999.99"   ) + Space(3) +;
					TransForm( nTCliPL  , "@E 999,999"      ) + Space(3) +;
					TransForm( nTCliM2  , "@E 999,999.99"   ) + Space(3) +;
					TransForm( nVlrUnIpi, "@E 9,999.99"     ) + Space(3) +;
					TransForm( nPrcMdIpi, "@E 9,999.99"     ) + Space(3) +;
					TransForm( nVlTotIpi, "@E 9,999,999.99" ) + Space(3) +;
					TransForm( nGrmtrMed, "@E 9,999.99"     )
					nTCLiNF := 0
					nTClIPI := 0
					nTCliPL := 0
					nTCliM2 := 0

					li++
					If li >= 65
						cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18);li:=9
					Endif

					aCompara := CalcComp( cCodCli )

					@li,001 PSAY "Comparar com período:"
					@li,033 PSAY TransForm( aCompara[ 1 ], "@E 999,999,999.99" ) + Space(3) +;
					TransForm( aCompara[ 2 ], "@E 999,999.99"   ) + Space(3) +;
					TransForm( aCompara[ 3 ], "@E 999,999"      ) + Space(3) +;
					TransForm( aCompara[ 4 ], "@E 999,999.99"   ) + Space(3) +;
					TransForm( aCompara[ 5 ], "@E 9,999.99"     ) + Space(3) +;
					TransForm( aCompara[ 6 ], "@E 9,999.99"     ) + Space(3) +;
					TransForm( aCompara[ 7 ], "@E 9,999,999.99" ) + Space(3) +;
					TransForm( aCompara[ 8 ], "@E 9,999.99"     )

					li++
					If li < 65
						@li,000 PSAY Replicate("-",160)
						li += 2
					EndIf
					If li >= 65
						cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18);li:=9
					Endif

				EndIf

				cCliAtu := (cAlias1)->NOME
				cCodCli := (cAlias1)->CLIENTE + (cAlias1)->LOJA
				@li,001 PSAY (cAlias1)->CLIENTE +"/"+ (cAlias1)->LOJA +" - "+ (cAlias1)->NOME

				li += 2
				If li >= 65
					cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18);li:=9
				Endif

			EndIf

			nVlTotIpi := Round( ( (cAlias1)->VAL_MERC + (cAlias1)->VAL_IPI ), 2 )
			nVlrUnIpi := Round( nVlTotIpi / (cAlias1)->QTD_TOT, 2 )
			nPrcMdIpi := Round( nVlTotIpi / (cAlias1)->PESO_LIQ, 2 )
			nGrmtrMed := Round( (cAlias1)->PESO_LIQ / (cAlias1)->AREA_TOT, 2 )

			@li,001 PSAY (cAlias1)->TIPO_PROD
			@li,008 PSAY (cAlias1)->DOCUMENTO
			@li,018 PSAY (cAlias1)->SERIE
			@li,022 PSAY DtoC( StoD( (cAlias1)->EMISSAO ) )
			@li,033 PSAY TransForm( (cAlias1)->VAL_MERC, "@E 999,999,999.99" ) + Space(3) +;
			TransForm( (cAlias1)->VAL_IPI , "@E 999,999.99"   ) + Space(3) +;
			TransForm( (cAlias1)->PESO_LIQ, "@E 999,999"      ) + Space(3) +;
			TransForm( (cAlias1)->AREA_TOT, "@E 999,999.99"   ) + Space(3) +;
			TransForm( nVlrUnIpi          , "@E 9,999.99"     ) + Space(3) +;
			TransForm( nPrcMdIpi          , "@E 9,999.99"     ) + Space(3) +;
			TransForm( nVlTotIpi          , "@E 9,999,999.99" ) + Space(3) +;
			TransForm( nGrmtrMed          , "@E 9,999.99"     )

			nTCLiNF += (cAlias1)->VAL_MERC
			nTClIPI += (cAlias1)->VAL_IPI
			nTCliPL += (cAlias1)->PESO_LIQ
			nTCliM2 += (cAlias1)->AREA_TOT
			nTCliQt += (cAlias1)->QTD_TOT

			nTCLiNFG += (cAlias1)->VAL_MERC
			nTClIPIG += (cAlias1)->VAL_IPI
			nTCliPLG += (cAlias1)->PESO_LIQ
			nTCliM2G += (cAlias1)->AREA_TOT
			nTCliQtG += (cAlias1)->QTD_TOT

			li++

		Else

			nVlTotIpi := Round( ( (cAlias1)->VAL_MERC + (cAlias1)->VAL_IPI ), 2 )
			nVlrUnIpi := Round( nVlTotIpi / (cAlias1)->QTD_TOT, 2 )
			nPrcMdIpi := Round( nVlTotIpi / (cAlias1)->PESO_LIQ, 2 )
			nGrmtrMed := Round( (cAlias1)->PESO_LIQ / (cAlias1)->AREA_TOT, 2 )

			@li,001 PSAY (cAlias1)->TIPO_PROD
			@li,008 PSAY (cAlias1)->DOCUMENTO
			@li,018 PSAY (cAlias1)->SERIE
			@li,022 PSAY (cAlias1)->CLIENTE +"-"+ Left( (cAlias1)->NOME, 35 )
			@li,065 PSAY DtoC( StoD( (cAlias1)->EMISSAO ) )
			@li,076 PSAY TransForm( (cAlias1)->VAL_MERC, "@E 999,999,999.99" ) + Space(3) +;
			TransForm( (cAlias1)->VAL_IPI , "@E 999,999.99"   ) + Space(3) +;
			TransForm( (cAlias1)->PESO_LIQ, "@E 999,999"      ) + Space(3) +;
			TransForm( (cAlias1)->AREA_TOT, "@E 999,999.99"   ) + Space(3) +;
			TransForm( nVlrUnIpi          , "@E 9,999.99"     ) + Space(3) +;
			TransForm( nPrcMdIpi          , "@E 9,999.99"     ) + Space(3) +;
			TransForm( nVlTotIpi          , "@E 9,999,999.99" ) + Space(3) +;
			TransForm( nGrmtrMed          , "@E 9,999.99"     )

			nTCLiNFG += (cAlias1)->VAL_MERC
			nTClIPIG += (cAlias1)->VAL_IPI
			nTCliPLG += (cAlias1)->PESO_LIQ
			nTCliM2G += (cAlias1)->AREA_TOT
			nTCliQtG += (cAlias1)->QTD_TOT

			li++
		EndIf

		If li >= 65
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18);li:=9
		Endif

		(cAlias1)->( dbSkip() )
	End

	// Total do último cliente impresso (depois de sair do loop)
	If aRetPar[ 13 ] == "Clientes" .And. nTCLiNF > 0

		li++
		If li >= 65
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18);li:=9
		Endif

		nVlTotIpi := Round( nTCLiNF + nTClIPI, 2 )
		nVlrUnIpi := Round( nVlTotIpi / nTCliQt, 2 )
		nPrcMdIpi := Round( nVlTotIpi / nTCliPL, 2 )
		nGrmtrMed := Round( nTCliPL / nTCliM2, 2 )

		@li,001 PSAY "Total do Cliente:"
		@li,033 PSAY TransForm( nTCLiNF, "@E 999,999,999.99" ) + Space(3) +;
		TransForm( nTClIPI  , "@E 999,999.99"   ) + Space(3) +;
		TransForm( nTCliPL  , "@E 999,999"      ) + Space(3) +;
		TransForm( nTCliM2  , "@E 999,999.99"   ) + Space(3) +;
		TransForm( nVlrUnIpi, "@E 9,999.99"     ) + Space(3) +;
		TransForm( nPrcMdIpi, "@E 9,999.99"     ) + Space(3) +;
		TransForm( nVlTotIpi, "@E 9,999,999.99" ) + Space(3) +;
		TransForm( nGrmtrMed, "@E 9,999.99"     )

		li++
		If li >= 65
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18);li:=9
		Endif

		aCompara := CalcComp( cCodCli )

		@li,001 PSAY "Comparar com período:"
		@li,033 PSAY TransForm( aCompara[ 1 ], "@E 999,999,999.99" ) + Space(3) +;
		TransForm( aCompara[ 2 ], "@E 999,999.99"   ) + Space(3) +;
		TransForm( aCompara[ 3 ], "@E 999,999"      ) + Space(3) +;
		TransForm( aCompara[ 4 ], "@E 999,999.99"   ) + Space(3) +;
		TransForm( aCompara[ 5 ], "@E 9,999.99"     ) + Space(3) +;
		TransForm( aCompara[ 6 ], "@E 9,999.99"     ) + Space(3) +;
		TransForm( aCompara[ 7 ], "@E 9,999,999.99" ) + Space(3) +;
		TransForm( aCompara[ 8 ], "@E 9,999.99"     )

		li++
		If li < 65
			@li,000 PSAY Replicate("-",160)
			li += 2
		EndIf
		If li >= 65
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18);li:=9
		Endif

	Endif

	// Impressão do total geral do relatório
	li++
	If li >= 65
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18);li:=9
	Endif

	// Calcular a média dos totais
	nVlTotIpi := Round( nTCLiNFG + nTClIPIG, 2 )
	nVlrUnIpi := Round( nVlTotIpi / nTCliQtG, 2 )
	nPrcMdIpi := Round( nVlTotIpi / nTCliPLG, 2 )
	nGrmtrMed := Round( nTCliPLG / nTCliM2G, 2 )


	If aRetPar[ 13 ] == "Clientes"

		@li,001 PSAY "Total Geral:"
		@li,033 PSAY TransForm( nTCLiNFG , "@E 999,999,999.99" ) + Space(3) +;
		TransForm( nTClIPIG , "@E 999,999.99"     ) + Space(3) +;
		TransForm( nTCliPLG , "@E 999,999"        ) + Space(3) +;
		TransForm( nTCliM2G , "@E 999,999.99"     ) + Space(3) +;
		TransForm( nVlrUnIpi, "@E 9,999.99"       ) + Space(3) +;
		TransForm( nPrcMdIpi, "@E 9,999.99"       ) + Space(3) +;
		TransForm( nVlTotIpi, "@E 9,999,999.99"   ) + Space(3) +;
		TransForm( nGrmtrMed, "@E 9,999.99"       )

		li++
		If li >= 65
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18);li:=9
		Endif

		aCompara := CalcComp("")

		@li,001 PSAY "Comparar com período:"
		@li,033 PSAY TransForm( aCompara[ 1 ], "@E 999,999,999.99" ) + Space(3) +;
		TransForm( aCompara[ 2 ], "@E 999,999.99"   ) + Space(3) +;
		TransForm( aCompara[ 3 ], "@E 999,999"      ) + Space(3) +;
		TransForm( aCompara[ 4 ], "@E 999,999.99"   ) + Space(3) +;
		TransForm( aCompara[ 5 ], "@E 9,999.99"     ) + Space(3) +;
		TransForm( aCompara[ 6 ], "@E 9,999.99"     ) + Space(3) +;
		TransForm( aCompara[ 7 ], "@E 9,999,999.99" ) + Space(3) +;
		TransForm( aCompara[ 8 ], "@E 9,999.99"     )

	Else

		@li,001 PSAY "Total Geral:"
		@li,076 PSAY TransForm( nTCLiNFG , "@E 999,999,999.99" ) + Space(3) +;
		TransForm( nTClIPIG , "@E 999,999.99"     ) + Space(3) +;
		TransForm( nTCliPLG , "@E 999,999"        ) + Space(3) +;
		TransForm( nTCliM2G , "@E 999,999.99"     ) + Space(3) +;
		TransForm( nVlrUnIpi, "@E 9,999.99"       ) + Space(3) +;
		TransForm( nPrcMdIpi, "@E 9,999.99"       ) + Space(3) +;
		TransForm( nVlTotIpi, "@E 9,999,999.99"   ) + Space(3) +;
		TransForm( nGrmtrMed, "@E 9,999.99"       )

		li++
		If li >= 65
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18);li:=9
		Endif

		aCompara := CalcComp("")

		@li,001 PSAY "Comparar com período:"
		@li,076 PSAY TransForm( aCompara[ 1 ], "@E 999,999,999.99" ) + Space(3) +;
		TransForm( aCompara[ 2 ], "@E 999,999.99" ) + Space(3) +;
		TransForm( aCompara[ 3 ], "@E 999,999" ) + Space(3) +;
		TransForm( aCompara[ 4 ], "@E 999,999.99" ) + Space(3) +;
		TransForm( aCompara[ 5 ], "@E 9,999.99" ) + Space(3) +;
		TransForm( aCompara[ 6 ], "@E 9,999.99" ) + Space(3) +;
		TransForm( aCompara[ 7 ], "@E 9,999,999.99" ) + Space(3) +;
		TransForm( aCompara[ 8 ], "@E 9,999.99" )

	EndIf

Return()

// Faz o cálculo de comparação de períodos
Static Function CalcComp( cCliLoj )

	Local aRet      := {}
	Local cAlias1   := ""
	Local cQuery1   := ""
	Local nVlrUnIpi := 0
	Local nPrcMdIpi := 0
	Local nVlTotIpi := 0
	Local nGrmtrMed := 0

	cQuery1 := "SELECT ISNULL( MERCADORIA, 0 )      VAL_MERC, "
	cQuery1 += "       ISNULL( SUM(IPI), 0 )        VAL_IPI, "
	cQuery1 += "       ISNULL( PESO, 0 )            PESO_LIQ, "
	cQuery1 += "       ISNULL( SUM(AREA), 0 )       AREA_TOT, "
	cQuery1 += "       ISNULL( SUM(QUANTIDADE), 0 ) QTD_TOT "
	cQuery1 += "FROM  (SELECT D2_DOC                     DOCUMENTO, "
	cQuery1 += "              D2_SERIE                   SERIE, "
	cQuery1 += "              D2_CLIENTE                 CLIENTE, "
	cQuery1 += "              D2_LOJA                    LOJA, "
	cQuery1 += "              A1_NOME                    NOME, "
	cQuery1 += "              D2_EMISSAO                 EMISSAO, "
	cQuery1 += "              F2_PLIQUI                  PESO, "
	cQuery1 += "              F2_VALMERC                 MERCADORIA, "
	cQuery1 += "              D2_VALIPI                  IPI, "
	cQuery1 += "              SD2.D2_QUANT * SB1.B1_AREA AREA, "
	cQuery1 += "              SD2.D2_QUANT               QUANTIDADE, "
	cQuery1 += "              CASE "
	If aRetPar[ 03 ] // Com Exportação
		cQuery1 += "                WHEN LEFT(SB1.B1_POSIPI, 8) = '48191000' AND LEFT(SD2.D2_CF, 1) <> '7' THEN 'CAIXA' "
		cQuery1 += "                WHEN LEFT(SB1.B1_POSIPI, 8) = '48081000' AND LEFT(SD2.D2_CF, 1) <> '7' THEN 'CHAPA' "
		cQuery1 += "                WHEN LEFT(SD2.D2_CF, 1) = '7' THEN 'EXPORT' "
	Else // Sem exportação
		cQuery1 += "                WHEN LEFT(SB1.B1_POSIPI, 8) = '48191000' THEN 'CAIXA' "
		cQuery1 += "                WHEN LEFT(SB1.B1_POSIPI, 8) = '48081000' THEN 'CHAPA' "
	Endif
	cQuery1 += "                ELSE 'OUTROS' "
	cQuery1 += "              END                        AS TIPO_PROD "
	cQuery1 += "       FROM   "+ RetSqlName("SD2") +" SD2 "
	cQuery1 += "              INNER JOIN "+ RetSqlName("SB1") +" SB1 "
	cQuery1 += "                      ON SD2.D2_COD = SB1.B1_COD "
	cQuery1 += "              INNER JOIN "+ RetSqlName("SA1") +" SA1 "
	cQuery1 += "                      ON SD2.D2_CLIENTE = SA1.A1_COD "
	cQuery1 += "                         AND SD2.D2_LOJA = SA1.A1_LOJA "
	cQuery1 += "              INNER JOIN "+ RetSqlName("SF2") +" SF2 "
	cQuery1 += "                      ON SD2.D2_FILIAL = SF2.F2_FILIAL "
	cQuery1 += "                         AND SD2.D2_DOC = SF2.F2_DOC "
	cQuery1 += "                         AND SD2.D2_SERIE = SF2.F2_SERIE "
	cQuery1 += "                         AND SD2.D2_CLIENTE = SF2.F2_CLIENTE "
	cQuery1 += "                         AND SD2.D2_LOJA = SF2.F2_LOJA "
	cQuery1 += "       WHERE  SD2.D_E_L_E_T_ <> '*' "
	cQuery1 += "              AND SF2.D_E_L_E_T_ <> '*' "
	cQuery1 += "              AND SB1.D_E_L_E_T_ <> '*' "
	cQuery1 += "              AND SA1.D_E_L_E_T_ <> '*' "
	cQuery1 += "              AND SD2.D2_FILIAL = '"+ xFilial("SD2") +"'"
	cQuery1 += "              AND SF2.F2_FILIAL = '"+ xFilial("SF2") +"'"
	If cCliLoj <> ""
		cQuery1 += "              AND SD2.D2_CLIENTE + SD2.D2_LOJA = '"+ cCliLoj +"' "
	Else
		cQuery1 += "              AND SD2.D2_CLIENTE BETWEEN '"+ aRetPar[ 05 ] +"' AND '"+ aRetPar[ 07 ] +"' "
		cQuery1 += "              AND SD2.D2_LOJA BETWEEN '"+ aRetPar[ 06 ] +"' AND '"+ aRetPar[ 08 ] +"' "
	EndIf
	cQuery1 += "              AND SD2.D2_EMISSAO BETWEEN '"+ DtoS( aRetPar[ 11 ] ) +"' AND '"+ DtoS( aRetPar[ 12 ] ) +"' "

	If ( aRetPar[ 01 ] .And. aRetPar[ 02 ] ) // Caixas e Chapas marcados
		If !aRetPar[ 04 ]
			cQuery1 += "              AND ( LEFT(SB1.B1_POSIPI, 8) = '48191000' OR LEFT(SB1.B1_POSIPI, 8) = '48081000' )"
		EndIf
	ElseIf ( !aRetPar[ 01 ] .And. !aRetPar[ 02 ] ) // Nem caixas nem Chapas marcadaos
		cQuery1 += "              AND ( LEFT(SB1.B1_POSIPI, 8) <> '48191000' AND LEFT(SB1.B1_POSIPI, 8) <> '48081000' )"
	Else // Se Caixa ou Chapa marcado (um OU outro)
		If !aRetPar[ 04 ]
			If aRetPar[ 01 ] // Caixa
				cQuery1 += "              AND LEFT(SB1.B1_POSIPI, 8) = '48191000' "
			EndIf
			If aRetPar[ 02 ] // Chapa
				cQuery1 += "              AND LEFT(SB1.B1_POSIPI, 8) = '48081000' "
			EndIf
		EndIf
	EndIf

	cQuery1 += "              AND SD2.D2_CF NOT IN ( '5924', '6151', '5949', '6922', "
	cQuery1 += "                                     '5911', '6911' )) TABELAO "
	cQuery1 += " GROUP BY MERCADORIA, PESO"
	MemoWrite("c:\temp\query_ted_comp.txt",cQuery1)
	TCQuery cQuery1 New Alias ( cAlias1 := GetNextAlias() )

	While !(cAlias1)->( EoF() )

		nVlrUnIpi := Round( ( (cAlias1)->VAL_MERC + (cAlias1)->VAL_IPI ) / (cAlias1)->QTD_TOT, 2 )
		nPrcMdIpi := Round( ( (cAlias1)->VAL_MERC + (cAlias1)->VAL_IPI ) / (cAlias1)->PESO_LIQ, 2 )
		nVlTotIpi := Round( ( (cAlias1)->VAL_MERC + (cAlias1)->VAL_IPI ), 2 )
		nGrmtrMed := Round( (cAlias1)->PESO_LIQ / (cAlias1)->AREA_TOT, 2 )

		aAdd( aRet, (cAlias1)->VAL_MERC )
		aAdd( aRet, (cAlias1)->VAL_IPI )
		aAdd( aRet, (cAlias1)->PESO_LIQ )
		aAdd( aRet, (cAlias1)->AREA_TOT )
		aAdd( aRet, nVlrUnIpi )
		aAdd( aRet, nPrcMdIpi )
		aAdd( aRet, nVlTotIpi )
		aAdd( aRet, nGrmtrMed )

		(cAlias1)->( dbSkip() )
	End

	If Len( aRet ) == 0
		aRet := { 0, 0, 0, 0, 0, 0, 0, 0 }
	EndIf

	(cAlias1)->( dbCloseArea() )

Return( aRet )

// Mostra as devoluções realizadas no período
Static Function DevFatPrt()

	Local cAlias1   := ""
	Local cQuery1   := ""
	Local cCliAtu   := ""
	Local cCodCli   := ""
	Local lFirst    := .T.

	Local nVlrUnIpi := 0
	Local nPrcMdIpi := 0
	Local nVlTotIpi := 0
	Local nGrmtrMed := 0

	Local nTCLiNF  := 0
	Local nTClIPI  := 0
	Local nTCliPL  := 0
	Local nTCliM2  := 0
	Local nTCliQt  := 0

	Local nTCLiNFG := 0
	Local nTClIPIG := 0
	Local nTCliPLG := 0
	Local nTCliM2G := 0
	Local nTCliQtG := 0

	cQuery1 := "SELECT TIPO_PROD, "
	cQuery1 += "       DOCUMENTO, "
	cQuery1 += "       SERIE, "
	cQuery1 += "       CLIENTE, "
	cQuery1 += "       LOJA, "
	cQuery1 += "       NOME, "
	cQuery1 += "       EMISSAO, "
	cQuery1 += "       MERCADORIA      VAL_MERC, "
	cQuery1 += "       SUM(IPI)        VAL_IPI, "
	cQuery1 += "       PESO            PESO_LIQ, "
	cQuery1 += "       SUM(AREA)       AREA_TOT, "
	cQuery1 += "       SUM(QUANTIDADE) QTD_TOT "
	cQuery1 += "FROM  (SELECT D1_DOC                     DOCUMENTO, "
	cQuery1 += "              D1_SERIE                   SERIE, "
	cQuery1 += "              D1_FORNECE                 CLIENTE, "
	cQuery1 += "              D1_LOJA                    LOJA, "
	cQuery1 += "              A1_NOME                    NOME, "
	cQuery1 += "              D1_DTDIGIT                 EMISSAO, "
	cQuery1 += "              F1_PLIQUI                  PESO, "
	cQuery1 += "              F1_VALMERC                 MERCADORIA, "
	cQuery1 += "              D1_VALIPI                  IPI, "
	cQuery1 += "              SD1.D1_QUANT * SB1.B1_AREA AREA, "
	cQuery1 += "              SD1.D1_QUANT               QUANTIDADE, "
	cQuery1 += "              CASE "
	If aRetPar[ 03 ] // Com Exportação
		cQuery1 += "                WHEN LEFT(SB1.B1_POSIPI, 8) = '48191000' AND LEFT(SD1.D1_CF, 1) <> '7' THEN 'CAIXA' "
		cQuery1 += "                WHEN LEFT(SB1.B1_POSIPI, 8) = '48081000' AND LEFT(SD1.D1_CF, 1) <> '7' THEN 'CHAPA' "
		cQuery1 += "                WHEN LEFT(SD1.D1_CF, 1) = '7' THEN 'EXPORT' "
	Else // Sem exportação
		cQuery1 += "                WHEN LEFT(SB1.B1_POSIPI, 8) = '48191000' THEN 'CAIXA' "
		cQuery1 += "                WHEN LEFT(SB1.B1_POSIPI, 8) = '48081000' THEN 'CHAPA' "
	Endif
	cQuery1 += "                ELSE 'OUTROS' "
	cQuery1 += "              END                        AS TIPO_PROD "
	cQuery1 += "       FROM   "+ RetSqlName("SD1") +" SD1 "
	cQuery1 += "              INNER JOIN "+ RetSqlName("SB1") +" SB1 "
	cQuery1 += "                      ON SD1.D1_COD = SB1.B1_COD "
	cQuery1 += "              INNER JOIN "+ RetSqlName("SA1") +" SA1 "
	cQuery1 += "                      ON SD1.D1_FORNECE = SA1.A1_COD "
	cQuery1 += "                         AND SD1.D1_LOJA = SA1.A1_LOJA "
	cQuery1 += "              INNER JOIN "+ RetSqlName("SF1") +" SF1 "
	cQuery1 += "                      ON SD1.D1_FILIAL = SF1.F1_FILIAL "
	cQuery1 += "                         AND SD1.D1_DOC = SF1.F1_DOC "
	cQuery1 += "                         AND SD1.D1_SERIE = SF1.F1_SERIE "
	cQuery1 += "                         AND SD1.D1_FORNECE = SF1.F1_FORNECE "
	cQuery1 += "                         AND SD1.D1_LOJA = SF1.F1_LOJA "
	cQuery1 += "       WHERE  SD1.D_E_L_E_T_ <> '*' "
	cQuery1 += "              AND SF1.D_E_L_E_T_ <> '*' "
	cQuery1 += "              AND SB1.D_E_L_E_T_ <> '*' "
	cQuery1 += "              AND SA1.D_E_L_E_T_ <> '*' "
	cQuery1 += "              AND SD1.D1_FILIAL = '"+ xFilial("SD1") +"'"
	cQuery1 += "              AND SF1.F1_FILIAL = '"+ xFilial("SF1") +"'"
	cQuery1 += "              AND SD1.D1_FORNECE BETWEEN '"+ aRetPar[ 05 ] +"' AND '"+ aRetPar[ 07 ] +"' "
	cQuery1 += "              AND SD1.D1_LOJA BETWEEN '"+ aRetPar[ 06 ] +"' AND '"+ aRetPar[ 08 ] +"' "
	cQuery1 += "              AND SD1.D1_DTDIGIT BETWEEN '"+ DtoS( aRetPar[ 09 ] ) +"' AND '"+ DtoS( aRetPar[ 10 ] ) +"' "
	cQuery1 += "              AND SF1.F1_TIPO   = 'D' "

	If ( aRetPar[ 01 ] .And. aRetPar[ 02 ] ) // Caixas e Chapas marcados
		If !aRetPar[ 04 ]
			cQuery1 += "              AND ( LEFT(SB1.B1_POSIPI, 8) = '48191000' OR LEFT(SB1.B1_POSIPI, 8) = '48081000' )"
		EndIf
	ElseIf ( !aRetPar[ 01 ] .And. !aRetPar[ 02 ] ) // Nem caixas nem Chapas marcadaos
		cQuery1 += "              AND ( LEFT(SB1.B1_POSIPI, 8) <> '48191000' AND LEFT(SB1.B1_POSIPI, 8) <> '48081000' )"
	Else // Se Caixa ou Chapa marcado (um OU outro)
		If !aRetPar[ 04 ]
			If aRetPar[ 01 ] // Caixa
				cQuery1 += "              AND LEFT(SB1.B1_POSIPI, 8) = '48191000' "
			EndIf
			If aRetPar[ 02 ] // Chapa
				cQuery1 += "              AND LEFT(SB1.B1_POSIPI, 8) = '48081000' "
			EndIf
		EndIf
	EndIf

	cQuery1 += "              AND SD1.D1_CF IN ( '1201', '2201' ) ) TABELAO "
	cQuery1 += "GROUP  BY TIPO_PROD, "
	cQuery1 += "          DOCUMENTO, "
	cQuery1 += "          SERIE, "
	cQuery1 += "          CLIENTE, "
	cQuery1 += "          LOJA, "
	cQuery1 += "          NOME, "
	cQuery1 += "          EMISSAO, "
	cQuery1 += "          PESO, "
	cQuery1 += "          MERCADORIA "

	If aRetPar[ 13 ] == "Clientes"
		cQuery1 += "ORDER  BY NOME ASC, "
		cQuery1 += "          DOCUMENTO ASC "
	Else
		cQuery1 += "ORDER  BY DOCUMENTO ASC "
	EndIf

	MemoWrite("c:\temp\query_ted_dev.txt",cQuery1)
	TCQuery cQuery1 New Alias ( cAlias1 := GetNextAlias() )

	Count To nRecs
	(cAlias1)->( dbGotop() )

	SetRegua( nRecs )
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18);li:=9

	While !(cAlias1)->( Eof() )

		If aRetPar[ 13 ] == "Clientes"

			If cCliAtu <> (cAlias1)->NOME

				If lFirst // Não precisa finalizar
					lFirst := .F.
				Else // Finaliza com o total do cliente anterior
					li++
					If li >= 65
						cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18);li:=9
					Endif

					nVlTotIpi := Round( nTCLiNF + nTClIPI, 2 )
					nVlrUnIpi := Round( nVlTotIpi / nTCliQt, 2 )
					nPrcMdIpi := Round( nVlTotIpi / nTCliPL, 2 )
					nGrmtrMed := Round( nTCliPL / nTCliM2, 2 )

					@li,001 PSAY "Total do Cliente:"
					@li,033 PSAY TransForm( nTCLiNF, "@E 999,999,999.99" ) + Space(3) +;
					TransForm( nTClIPI  , "@E 999,999.99"   ) + Space(3) +;
					TransForm( nTCliPL  , "@E 999,999"      ) + Space(3) +;
					TransForm( nTCliM2  , "@E 999,999.99"   ) + Space(3) +;
					TransForm( nVlrUnIpi, "@E 9,999.99"     ) + Space(3) +;
					TransForm( nPrcMdIpi, "@E 9,999.99"     ) + Space(3) +;
					TransForm( nVlTotIpi, "@E 9,999,999.99" ) + Space(3) +;
					TransForm( nGrmtrMed, "@E 9,999.99"     )
					nTCLiNF := 0
					nTClIPI := 0
					nTCliPL := 0
					nTCliM2 := 0

					li++
					If li >= 65
						cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18);li:=9
					Endif

					aCompara := DevComp( cCodCli )

					@li,001 PSAY "Comparar com período:"
					@li,033 PSAY TransForm( aCompara[ 1 ], "@E 999,999,999.99" ) + Space(3) +;
					TransForm( aCompara[ 2 ], "@E 999,999.99"   ) + Space(3) +;
					TransForm( aCompara[ 3 ], "@E 999,999"      ) + Space(3) +;
					TransForm( aCompara[ 4 ], "@E 999,999.99"   ) + Space(3) +;
					TransForm( aCompara[ 5 ], "@E 9,999.99"     ) + Space(3) +;
					TransForm( aCompara[ 6 ], "@E 9,999.99"     ) + Space(3) +;
					TransForm( aCompara[ 7 ], "@E 9,999,999.99" ) + Space(3) +;
					TransForm( aCompara[ 8 ], "@E 9,999.99"     )

					li++
					If li < 65
						@li,000 PSAY Replicate("-",160)
						li += 2
					EndIf
					If li >= 65
						cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18);li:=9
					Endif

				EndIf

				cCliAtu := (cAlias1)->NOME
				cCodCli := (cAlias1)->CLIENTE + (cAlias1)->LOJA
				@li,001 PSAY (cAlias1)->CLIENTE +"/"+ (cAlias1)->LOJA +" - "+ (cAlias1)->NOME

				li += 2
				If li >= 65
					cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18);li:=9
				Endif

			EndIf

			nVlTotIpi := Round( ( (cAlias1)->VAL_MERC + (cAlias1)->VAL_IPI ), 2 )
			nVlrUnIpi := Round( nVlTotIpi / (cAlias1)->QTD_TOT, 2 )
			nPrcMdIpi := Round( nVlTotIpi / (cAlias1)->PESO_LIQ, 2 )
			nGrmtrMed := Round( (cAlias1)->PESO_LIQ / (cAlias1)->AREA_TOT, 2 )

			@li,001 PSAY (cAlias1)->TIPO_PROD
			@li,008 PSAY (cAlias1)->DOCUMENTO
			@li,018 PSAY (cAlias1)->SERIE
			@li,022 PSAY DtoC( StoD( (cAlias1)->EMISSAO ) )
			@li,033 PSAY TransForm( (cAlias1)->VAL_MERC, "@E 999,999,999.99" ) + Space(3) +;
			TransForm( (cAlias1)->VAL_IPI , "@E 999,999.99"   ) + Space(3) +;
			TransForm( (cAlias1)->PESO_LIQ, "@E 999,999"      ) + Space(3) +;
			TransForm( (cAlias1)->AREA_TOT, "@E 999,999.99"   ) + Space(3) +;
			TransForm( nVlrUnIpi          , "@E 9,999.99"     ) + Space(3) +;
			TransForm( nPrcMdIpi          , "@E 9,999.99"     ) + Space(3) +;
			TransForm( nVlTotIpi          , "@E 9,999,999.99" ) + Space(3) +;
			TransForm( nGrmtrMed          , "@E 9,999.99"     )

			nTCLiNF += (cAlias1)->VAL_MERC
			nTClIPI += (cAlias1)->VAL_IPI
			nTCliPL += (cAlias1)->PESO_LIQ
			nTCliM2 += (cAlias1)->AREA_TOT
			nTCliQt += (cAlias1)->QTD_TOT

			nTCLiNFG += (cAlias1)->VAL_MERC
			nTClIPIG += (cAlias1)->VAL_IPI
			nTCliPLG += (cAlias1)->PESO_LIQ
			nTCliM2G += (cAlias1)->AREA_TOT
			nTCliQtG += (cAlias1)->QTD_TOT

			li++

		Else

			nVlTotIpi := Round( ( (cAlias1)->VAL_MERC + (cAlias1)->VAL_IPI ), 2 )
			nVlrUnIpi := Round( nVlTotIpi / (cAlias1)->QTD_TOT, 2 )
			nPrcMdIpi := Round( nVlTotIpi / (cAlias1)->PESO_LIQ, 2 )
			nGrmtrMed := Round( (cAlias1)->PESO_LIQ / (cAlias1)->AREA_TOT, 2 )

			@li,001 PSAY (cAlias1)->TIPO_PROD
			@li,008 PSAY (cAlias1)->DOCUMENTO
			@li,018 PSAY (cAlias1)->SERIE
			@li,022 PSAY (cAlias1)->CLIENTE +"-"+ Left( (cAlias1)->NOME, 35 )
			@li,065 PSAY DtoC( StoD( (cAlias1)->EMISSAO ) )
			@li,076 PSAY TransForm( (cAlias1)->VAL_MERC, "@E 999,999,999.99" ) + Space(3) +;
			TransForm( (cAlias1)->VAL_IPI , "@E 999,999.99"   ) + Space(3) +;
			TransForm( (cAlias1)->PESO_LIQ, "@E 999,999"      ) + Space(3) +;
			TransForm( (cAlias1)->AREA_TOT, "@E 999,999.99"   ) + Space(3) +;
			TransForm( nVlrUnIpi          , "@E 9,999.99"     ) + Space(3) +;
			TransForm( nPrcMdIpi          , "@E 9,999.99"     ) + Space(3) +;
			TransForm( nVlTotIpi          , "@E 9,999,999.99" ) + Space(3) +;
			TransForm( nGrmtrMed          , "@E 9,999.99"     )

			nTCLiNFG += (cAlias1)->VAL_MERC
			nTClIPIG += (cAlias1)->VAL_IPI
			nTCliPLG += (cAlias1)->PESO_LIQ
			nTCliM2G += (cAlias1)->AREA_TOT
			nTCliQtG += (cAlias1)->QTD_TOT

			li++
		EndIf

		If li >= 65
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18);li:=9
		Endif

		(cAlias1)->( dbSkip() )
	End

	// Total do último cliente impresso (depois de sair do loop)
	If aRetPar[ 13 ] == "Clientes" .And. nTCLiNF > 0

		li++
		If li >= 65
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18);li:=9
		Endif

		nVlTotIpi := Round( nTCLiNF + nTClIPI, 2 )
		nVlrUnIpi := Round( nVlTotIpi / nTCliQt, 2 )
		nPrcMdIpi := Round( nVlTotIpi / nTCliPL, 2 )
		nGrmtrMed := Round( nTCliPL / nTCliM2, 2 )

		@li,001 PSAY "Total do Cliente:"
		@li,033 PSAY TransForm( nTCLiNF, "@E 999,999,999.99" ) + Space(3) +;
		TransForm( nTClIPI  , "@E 999,999.99"   ) + Space(3) +;
		TransForm( nTCliPL  , "@E 999,999"      ) + Space(3) +;
		TransForm( nTCliM2  , "@E 999,999.99"   ) + Space(3) +;
		TransForm( nVlrUnIpi, "@E 9,999.99"     ) + Space(3) +;
		TransForm( nPrcMdIpi, "@E 9,999.99"     ) + Space(3) +;
		TransForm( nVlTotIpi, "@E 9,999,999.99" ) + Space(3) +;
		TransForm( nGrmtrMed, "@E 9,999.99"     )

		li++
		If li >= 65
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18);li:=9
		Endif

		aCompara := DevComp( cCodCli )

		@li,001 PSAY "Comparar com período:"
		@li,033 PSAY TransForm( aCompara[ 1 ], "@E 999,999,999.99" ) + Space(3) +;
		TransForm( aCompara[ 2 ], "@E 999,999.99"   ) + Space(3) +;
		TransForm( aCompara[ 3 ], "@E 999,999"      ) + Space(3) +;
		TransForm( aCompara[ 4 ], "@E 999,999.99"   ) + Space(3) +;
		TransForm( aCompara[ 5 ], "@E 9,999.99"     ) + Space(3) +;
		TransForm( aCompara[ 6 ], "@E 9,999.99"     ) + Space(3) +;
		TransForm( aCompara[ 7 ], "@E 9,999,999.99" ) + Space(3) +;
		TransForm( aCompara[ 8 ], "@E 9,999.99"     )

		li++
		If li < 65
			@li,000 PSAY Replicate("-",160)
			li += 2
		EndIf
		If li >= 65
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18);li:=9
		Endif

	Endif

	// Impressão do total geral do relatório
	li++
	If li >= 65
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18);li:=9
	Endif

	// Calcular a média dos totais
	nVlTotIpi := Round( nTCLiNFG + nTClIPIG, 2 )
	nVlrUnIpi := Round( nVlTotIpi / nTCliQtG, 2 )
	nPrcMdIpi := Round( nVlTotIpi / nTCliPLG, 2 )
	nGrmtrMed := Round( nTCliPLG / nTCliM2G, 2 )


	If aRetPar[ 13 ] == "Clientes"

		@li,001 PSAY "Total Geral:"
		@li,033 PSAY TransForm( nTCLiNFG , "@E 999,999,999.99" ) + Space(3) +;
		TransForm( nTClIPIG , "@E 999,999.99"     ) + Space(3) +;
		TransForm( nTCliPLG , "@E 999,999"        ) + Space(3) +;
		TransForm( nTCliM2G , "@E 999,999.99"     ) + Space(3) +;
		TransForm( nVlrUnIpi, "@E 9,999.99"       ) + Space(3) +;
		TransForm( nPrcMdIpi, "@E 9,999.99"       ) + Space(3) +;
		TransForm( nVlTotIpi, "@E 9,999,999.99"   ) + Space(3) +;
		TransForm( nGrmtrMed, "@E 9,999.99"       )

		li++
		If li >= 65
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18);li:=9
		Endif

		aCompara := DevComp("")

		@li,001 PSAY "Comparar com período:"
		@li,033 PSAY TransForm( aCompara[ 1 ], "@E 999,999,999.99" ) + Space(3) +;
		TransForm( aCompara[ 2 ], "@E 999,999.99"   ) + Space(3) +;
		TransForm( aCompara[ 3 ], "@E 999,999"      ) + Space(3) +;
		TransForm( aCompara[ 4 ], "@E 999,999.99"   ) + Space(3) +;
		TransForm( aCompara[ 5 ], "@E 9,999.99"     ) + Space(3) +;
		TransForm( aCompara[ 6 ], "@E 9,999.99"     ) + Space(3) +;
		TransForm( aCompara[ 7 ], "@E 9,999,999.99" ) + Space(3) +;
		TransForm( aCompara[ 8 ], "@E 9,999.99"     )

	Else

		@li,001 PSAY "Total Geral:"
		@li,076 PSAY TransForm( nTCLiNFG , "@E 999,999,999.99" ) + Space(3) +;
		TransForm( nTClIPIG , "@E 999,999.99"     ) + Space(3) +;
		TransForm( nTCliPLG , "@E 999,999"        ) + Space(3) +;
		TransForm( nTCliM2G , "@E 999,999.99"     ) + Space(3) +;
		TransForm( nVlrUnIpi, "@E 9,999.99"       ) + Space(3) +;
		TransForm( nPrcMdIpi, "@E 9,999.99"       ) + Space(3) +;
		TransForm( nVlTotIpi, "@E 9,999,999.99"   ) + Space(3) +;
		TransForm( nGrmtrMed, "@E 9,999.99"       )

		li++
		If li >= 65
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18);li:=9
		Endif

		aCompara := DevComp("")

		@li,001 PSAY "Comparar com período:"
		@li,076 PSAY TransForm( aCompara[ 1 ], "@E 999,999,999.99" ) + Space(3) +;
		TransForm( aCompara[ 2 ], "@E 999,999.99" ) + Space(3) +;
		TransForm( aCompara[ 3 ], "@E 999,999" ) + Space(3) +;
		TransForm( aCompara[ 4 ], "@E 999,999.99" ) + Space(3) +;
		TransForm( aCompara[ 5 ], "@E 9,999.99" ) + Space(3) +;
		TransForm( aCompara[ 6 ], "@E 9,999.99" ) + Space(3) +;
		TransForm( aCompara[ 7 ], "@E 9,999,999.99" ) + Space(3) +;
		TransForm( aCompara[ 8 ], "@E 9,999.99" )

	EndIf

	(cAlias1)->( dbCloseArea() )

Return()

// Faz o cálculo de comparação de períodos das devoluções
Static Function DevComp( cCliLoj )

	Local aRet      := {}
	Local cAlias1   := ""
	Local cQuery1   := ""
	Local nVlrUnIpi := 0
	Local nPrcMdIpi := 0
	Local nVlTotIpi := 0
	Local nGrmtrMed := 0

	cQuery1 := "SELECT ISNULL( MERCADORIA, 0 )      VAL_MERC, "
	cQuery1 += "       ISNULL( SUM(IPI), 0 )        VAL_IPI, "
	cQuery1 += "       ISNULL( PESO, 0 )            PESO_LIQ, "
	cQuery1 += "       ISNULL( SUM(AREA), 0 )       AREA_TOT, "
	cQuery1 += "       ISNULL( SUM(QUANTIDADE), 0 ) QTD_TOT "
	cQuery1 += "FROM  (SELECT D1_DOC                     DOCUMENTO, "
	cQuery1 += "              D1_SERIE                   SERIE, "
	cQuery1 += "              D1_FORNECE                 CLIENTE, "
	cQuery1 += "              D1_LOJA                    LOJA, "
	cQuery1 += "              A1_NOME                    NOME, "
	cQuery1 += "              D1_DTDIGIT                 EMISSAO, "
	cQuery1 += "              F1_PLIQUI                  PESO, "
	cQuery1 += "              F1_VALMERC                 MERCADORIA, "
	cQuery1 += "              D1_VALIPI                  IPI, "
	cQuery1 += "              SD1.D1_QUANT * SB1.B1_AREA AREA, "
	cQuery1 += "              SD1.D1_QUANT               QUANTIDADE, "
	cQuery1 += "              CASE "
	If aRetPar[ 03 ] // Com Exportação
		cQuery1 += "                WHEN LEFT(SB1.B1_POSIPI, 8) = '48191000' AND LEFT(SD1.D1_CF, 1) <> '7' THEN 'CAIXA' "
		cQuery1 += "                WHEN LEFT(SB1.B1_POSIPI, 8) = '48081000' AND LEFT(SD1.D1_CF, 1) <> '7' THEN 'CHAPA' "
		cQuery1 += "                WHEN LEFT(SD1.D1_CF, 1) = '7' THEN 'EXPORT' "
	Else // Sem exportação
		cQuery1 += "                WHEN LEFT(SB1.B1_POSIPI, 8) = '48191000' THEN 'CAIXA' "
		cQuery1 += "                WHEN LEFT(SB1.B1_POSIPI, 8) = '48081000' THEN 'CHAPA' "
	Endif
	cQuery1 += "                ELSE 'OUTROS' "
	cQuery1 += "              END                        AS TIPO_PROD "
	cQuery1 += "       FROM   "+ RetSqlName("SD1") +" SD1 "
	cQuery1 += "              INNER JOIN "+ RetSqlName("SB1") +" SB1 "
	cQuery1 += "                      ON SD1.D1_COD = SB1.B1_COD "
	cQuery1 += "              INNER JOIN "+ RetSqlName("SA1") +" SA1 "
	cQuery1 += "                      ON SD1.D1_FORNECE = SA1.A1_COD "
	cQuery1 += "                         AND SD1.D1_LOJA = SA1.A1_LOJA "
	cQuery1 += "              INNER JOIN "+ RetSqlName("SF1") +" SF1 "
	cQuery1 += "                      ON SD1.D1_FILIAL = SF1.F1_FILIAL "
	cQuery1 += "                         AND SD1.D1_DOC = SF1.F1_DOC "
	cQuery1 += "                         AND SD1.D1_SERIE = SF1.F1_SERIE "
	cQuery1 += "                         AND SD1.D1_FORNECE = SF1.F1_FORNECE "
	cQuery1 += "                         AND SD1.D1_LOJA = SF1.F1_LOJA "
	cQuery1 += "       WHERE  SD1.D_E_L_E_T_ <> '*' "
	cQuery1 += "              AND SF1.D_E_L_E_T_ <> '*' "
	cQuery1 += "              AND SB1.D_E_L_E_T_ <> '*' "
	cQuery1 += "              AND SA1.D_E_L_E_T_ <> '*' "
	cQuery1 += "              AND SD1.D1_FILIAL = '"+ xFilial("SD1") +"'"
	cQuery1 += "              AND SF1.F1_FILIAL = '"+ xFilial("SF1") +"'"
	cQuery1 += "              AND SF1.F1_TIPO   = 'D' "
	If cCliLoj <> ""
		cQuery1 += "              AND SD1.D1_FORNECE + SD1.D1_LOJA = '"+ cCliLoj +"' "
	Else
		cQuery1 += "              AND SD1.D1_FORNECE BETWEEN '"+ aRetPar[ 05 ] +"' AND '"+ aRetPar[ 07 ] +"' "
		cQuery1 += "              AND SD1.D1_LOJA BETWEEN '"+ aRetPar[ 06 ] +"' AND '"+ aRetPar[ 08 ] +"' "
	EndIf
	cQuery1 += "              AND SD1.D1_DTDIGIT BETWEEN '"+ DtoS( aRetPar[ 11 ] ) +"' AND '"+ DtoS( aRetPar[ 12 ] ) +"' "

	If ( aRetPar[ 01 ] .And. aRetPar[ 02 ] ) // Caixas e Chapas marcados
		If !aRetPar[ 04 ]
			cQuery1 += "              AND ( LEFT(SB1.B1_POSIPI, 8) = '48191000' OR LEFT(SB1.B1_POSIPI, 8) = '48081000' )"
		EndIf
	ElseIf ( !aRetPar[ 01 ] .And. !aRetPar[ 02 ] ) // Nem caixas nem Chapas marcadaos
		cQuery1 += "              AND ( LEFT(SB1.B1_POSIPI, 8) <> '48191000' AND LEFT(SB1.B1_POSIPI, 8) <> '48081000' )"
	Else // Se Caixa ou Chapa marcado (um OU outro)
		If !aRetPar[ 04 ]
			If aRetPar[ 01 ] // Caixa
				cQuery1 += "              AND LEFT(SB1.B1_POSIPI, 8) = '48191000' "
			EndIf
			If aRetPar[ 02 ] // Chapa
				cQuery1 += "              AND LEFT(SB1.B1_POSIPI, 8) = '48081000' "
			EndIf
		EndIf
	EndIf

	cQuery1 += "              AND SD1.D1_CF IN ( '1201', '2201' ) ) TABELAO "
	cQuery1 += " GROUP BY PESO, MERCADORIA "

	MemoWrite("c:\temp\query_ted_comp_dev.txt",cQuery1)
	TCQuery cQuery1 New Alias ( cAlias1 := GetNextAlias() )

	While !(cAlias1)->( EoF() )

		nVlrUnIpi := Round( ( (cAlias1)->VAL_MERC + (cAlias1)->VAL_IPI ) / (cAlias1)->QTD_TOT, 2 )
		nPrcMdIpi := Round( ( (cAlias1)->VAL_MERC + (cAlias1)->VAL_IPI ) / (cAlias1)->PESO_LIQ, 2 )
		nVlTotIpi := Round( ( (cAlias1)->VAL_MERC + (cAlias1)->VAL_IPI ), 2 )
		nGrmtrMed := Round( (cAlias1)->PESO_LIQ / (cAlias1)->AREA_TOT, 2 )

		aAdd( aRet, (cAlias1)->VAL_MERC )
		aAdd( aRet, (cAlias1)->VAL_IPI  )
		aAdd( aRet, (cAlias1)->PESO_LIQ )
		aAdd( aRet, (cAlias1)->AREA_TOT )
		aAdd( aRet, nVlrUnIpi )
		aAdd( aRet, nPrcMdIpi )
		aAdd( aRet, nVlTotIpi )
		aAdd( aRet, nGrmtrMed )

		(cAlias1)->( dbSkip() )
	End

	If Len( aRet ) == 0
		aRet := { 0, 0, 0, 0, 0, 0, 0, 0 }
	EndIf

	(cAlias1)->( dbCloseArea() )

Return( aRet )
