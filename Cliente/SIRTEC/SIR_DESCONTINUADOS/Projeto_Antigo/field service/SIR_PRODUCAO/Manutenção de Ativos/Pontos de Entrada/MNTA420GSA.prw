#INCLUDE 'PROTHEUS.CH'

// Posi�es do Array aInsumos
#DEFINE POS_INS_OK		1
#DEFINE POS_INS_PROD	2
#DEFINE POS_INS_DESC	3
#DEFINE POS_INS_TIPO	4
#DEFINE POS_INS_UM		5
#DEFINE POS_INS_LOCAL	6
#DEFINE POS_INS_VALDESC	7
#DEFINE POS_INS_VALUNIT	8
#DEFINE POS_INS_QUANT	9
#DEFINE POS_INS_CODFOR	10
#DEFINE POS_INS_LOJFOR	11
#DEFINE POS_INS_NOME	12

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �MNTA420GSA� Autor � Jorge Alberto-Solutio � Data �14/02/2019���
�������������������������������������������������������������������������Ĵ��
���Descricao � PE para que seja adicionada nova op��o em "Outras A��es"   ���
���          � dentro da tela "Insumos", na Ordem de Servi�o Corretiva.   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � U_MNTA420GSA()                                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� NIL                                                        ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRet -> Array com as novas op��es de rotinas.              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico para a empresa Sirtec                           ���
�������������������������������������������������������������������������Ĵ��
���                          ULTIMAS ALTERACOES                           ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
User Function MNTA420GSA()

	Local aRet := {}

	aAdd(aRet, { "BMPALTERAR", {|| U_GSA420IN() }, "Filtrar Produto" } )

Return( aRet )



/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � GSA420IN � Autor �Jorge Alberto - Solutio� Data �14/02/2019���
�������������������������������������������������������������������������Ĵ��
���Descricao � Filtrar produtos										      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                               			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PE_MNTA420GSA                                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function GSA420IN()

	Local aArea     := GetArea()
	Local aAreaST9  := ST9->( GetArea() )
	Local aInsumos  := {}
	Local nOpcao    := 0
	Local nReg      := 0
	Local nColHead  := 0
	Local nTotHead  := 0
	Local nPosFor	:= 0
	Local nPosLoja	:= 0
	Local nPosPro	:= 0
	Local nPosCodI	:= 0
	Local nPosNome	:= 0
	Local nPosCale	:= 0
	Local nPosQtRe	:= 0
	Local nQTDHEA	:= 0
	Local nDestino	:= 0
	Local nDtInici	:= 0
	Local nHrInici	:= 0
	Local nUnidade	:= 0
	Local nAlmox	:= 0
	Local nPosRecWT	:= 0
	Local nInsumo	:= 0
	Local nPosPlan  := 0
	Local nPosTaref := 0
	Local nPosOrdem := 0
	Local nPosSeqRe := 0
	Local nPosDesc  := 0
	Local nPosPrUn  := 0
	Local nPosVlTot := 0
	Local cAliAtu   := Alias()
	Local cQuery    := ""
	Local cAliB1    := ""
	Local cGetFiltro := Space(50)
	Local oDlg, oSayFiltro, oGetFiltro, oListInsum, oBtnOk, oBtnCancel

	Private oOk
	Private oNo
	Private aInsOrig := {}

	cAliB1 := GetNextAlias()
	oOk := Loadbitmap( GetResources(), 'LBOK' )
	oNo := Loadbitmap( GetResources(), 'LBNO' )

	cQuery := "SELECT B1_COD, B1_DESC, B1_TIPO, B1_UM, B1_LOCPAD, CASE B1_TIPO WHEN 'MO' THEN '2' ELSE '1' END ORDEM "
	cQuery += "  FROM " + RetSqlName("SB1") + " "
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += "   AND B1_MSBLQL <> '1' "
	cQuery += " ORDER BY ORDEM, B1_COD "

	cQuery := ChangeQuery(cQuery)
	//MemoWrit( "c:\temp\PE_MNTA450GSA.sql ", cQuery )

	DbUseArea(.T.,"TOPCONECT",TcGenQry(,,cQuery),cAliB1,.F.,.F.)

	// Se para o Bem informado, existe algum Produto relacionado, ir� carregar no array
	While (cAliB1)->( !EOF() )
		/*
		// Posi�es do Array aInsumos
		POS_INS_OK		1
		POS_INS_PROD	2
		POS_INS_DESC	3
		POS_INS_TIPO	4
		POS_INS_UM		5
		POS_INS_LOCAL	6
		POS_INS_VALDESC	7
		POS_INS_VALUNIT	8
		POS_INS_QUANT   9
		POS_INS_CODFOR	10
		POS_INS_LOJFOR	11
		POS_INS_NOME	12
		*/
		AADD( aInsumos, { .F., (cAliB1)->B1_COD, (cAliB1)->B1_DESC, (cAliB1)->B1_TIPO, (cAliB1)->B1_UM, (cAliB1)->B1_LOCPAD, 0, 0, 0, '', '', '' } )

		(cAliB1)->( DbSkip() )
	EndDo
	(cAliB1)->( DbCloseArea() )

	If Len( aInsumos ) <= 0

		MsgInfo( "N�o foram localizados Insumos para sele��o." )

		RestArea( aArea )
		RestArea( aAreaST9 )

		If !Empty( cAliAtu )
			DbSelectArea( cAliAtu )
		EndIf

		Return
	EndIf

	// Aqui mantem o array original com todos os insumos
	aInsOrig := aClone( aInsumos )

	oDlg := MSDialog():New( 095,169,603/*Altura*/,1365/*Largura*/,"Filtrar Insumos",,,.F.,,,,,,.T.,,,.T. )

	oSayFiltro := TSay():New( 008,008,{||"Filtro"},oDlg,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)
	oGetFiltro := TGet():New( 006,037,{|u| If(PCount()>0,cGetFiltro:=u,cGetFiltro)},oDlg,075,008,'',{|| Filtra( cGetFiltro, @aInsumos, oListInsum ) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGetFiltro",,)

	@028,008 ListBox oListInsum Fields HEADERS '  ','C�digo','Descri��o','Tipo','UM', 'Local', 'Desconto', 'Prc. Unit.', 'Quant', 'Cod. Forn', 'Loja Forn', 'Nome' Size 586,188 Pixel Of oDlg ;
	On dblClick( Marca( @aInsumos, oListInsum:nAt ), oListInsum:Refresh() )

	oBtnOk     := TButton():New( 224,020,"Confirmar",oDlg,{|| nOpcao := 1, oDlg:End() },037,012,,,,.T.,,"",,,,.F. )
	oBtnCancel := TButton():New( 224,092,"Cancelar",oDlg,{|| nOpcao := 0, oDlg:End() },037,012,,,,.T.,,"",,,,.F. )

	// Antes de abrir a tela, carrega os registros
	Filtra( "", @aInsumos, oListInsum )

	oDlg:Activate(,,,.T.)

	If nOpcao == 1

		RestArea( aArea )
		RestArea( aAreaST9 )

		If !Empty( cAliAtu )
			DbSelectArea( cAliAtu )
		EndIf

		// Carrega as posi��es de cada coluna que ser� atualizada
		nTotHead  := Len( oGet:aHeader )
		nPosOrdem := aSCAN( oGet:aHeader, {|x| AllTrim(Upper(X[2])) == "TL_ORDEM"   })
		nPosPlan  := aSCAN( oGet:aHeader, {|x| AllTrim(Upper(X[2])) == "TL_PLANO"   })
		nPosSeqRe := aSCAN( oGet:aHeader, {|x| AllTrim(Upper(X[2])) == "TL_SEQRELA" })
		nPosTaref := aSCAN( oGet:aHeader, {|x| AllTrim(Upper(X[2])) == "TL_TAREFA"  })
		nPosPro	  := aSCAN( oGet:aHeader, {|x| AllTrim(Upper(X[2])) == "TL_TIPOREG" })
		nPosCodI  := aSCAN( oGet:aHeader, {|x| AllTrim(Upper(X[2])) == "TL_CODIGO"  })
		nPosNome  := aSCAN( oGet:aHeader, {|x| AllTrim(Upper(X[2])) == "TL_NOMCODI" })
		nPosCale  := aSCAN( oGet:aHeader, {|x| AllTrim(Upper(X[2])) == "TL_USACALE" })
		nPosQtRe  := aSCAN( oGet:aHeader, {|x| AllTrim(Upper(X[2])) == "TL_QUANREC" })
		nQTDHEA	  := aSCAN( oGet:aHeader, {|x| AllTrim(Upper(X[2])) == "TL_QUANTID" })
		nUnidade  := aSCAN( oGet:aHeader, {|x| AllTrim(Upper(X[2])) == "TL_UNIDADE" })
		nDestino  := aSCAN( oGet:aHeader, {|x| AllTrim(Upper(X[2])) == "TL_DESTINO" })
		nPosFor   := aSCAN( oGet:aHeader, {|x| AllTrim(Upper(X[2])) == "TL_FORNEC"  })
		nPosLoja  := aSCAN( oGet:aHeader, {|x| AllTrim(Upper(X[2])) == "TL_LOJA"    })
		nDtInici  := aSCAN( oGet:aHeader, {|x| AllTrim(Upper(X[2])) == "TL_DTINICI" })
		nHrInici  := aSCAN( oGet:aHeader, {|x| AllTrim(Upper(X[2])) == "TL_HOINICI" })
		nAlmox    := aSCAN( oGet:aHeader, {|x| AllTrim(Upper(X[2])) == "TL_LOCAL"   })
		nPosDesc  := aSCAN( oGet:aHeader, {|x| AllTrim(Upper(X[2])) == "TL_DESCPRD" })
		nPosPrUn  := aSCAN( oGet:aHeader, {|x| AllTrim(Upper(X[2])) == "TL_PRCUNIT" })
		nPosVlTot := aSCAN( oGet:aHeader, {|x| AllTrim(Upper(X[2])) == "TL_VLTOTAL" })
		nPosRecWT := aSCAN( oGet:aHeader, {|x| AllTrim(Upper(X[2])) == "TL_REC_WT"  })

		M->TJ_VTOTPRD := 0

		// Tem que fazer o loop do array original, pois o array aInsumos pode estar FILTRADO e assim n�o vai ter todos
		// os registros selecionados pelo usu�rio na tela do filtro.
		For nInsumo := 1 To Len( aInsOrig )

			// Se deletou a linha ent�o passa para o pr�ximo registro
			If !aInsOrig[ nInsumo, POS_INS_OK ]
				Loop
			EndIf

			// N�o pode carregar o mesmo produto caso j� exista na tela padr�o dos Insumos.
			If aScan( oGet:aCols, { |u| u[nPosPro] == "P" .And. u[nPosCodI] == aInsOrig[ nInsumo, POS_INS_PROD ] } ) <= 0

				// Caso tenha apenas uma linha e sem Produto, n�o precisa adicionar outra linha, ir� usar essa
				If !( Len( oGet:aCols ) == 1 .And. Empty( oGet:aCols[ 1, nPosCodI ] ) )
					AADD( oGet:aCols, Array( nTotHead + 1 ) )
				EndIf

				nReg := Len( oGet:aCols )

				// Loop em todos os campos para atualizar conforme o inicializador padr�o de cada campo.
				For nColHead := 1 To nTotHead

					// N�o pode ter o nome do Recno e Alias tempor�rio da tabela
					If ! ( AllTrim( oGet:aHeader[nColHead][2] ) $ "TL_ALI_WT/TL_REC_WT" )

						If oGet:aHeader[nColHead][10] <> "V" // Campo diferente de virtual
							oGet:aCols[nReg][nColHead] := CriaVar( oGet:aHeader[nColHead][2], .T. )
						EndIf
					EndIf

				Next nColHead

				// Atualizo a coluna na tela de Insumos conforme o que o usu�rio selecionou
				If nPosOrdem > 0
					oGet:aCols[ nReg, nPosOrdem] := M->TJ_ORDEM
				EndIf
				If nPosPlan > 0
					oGet:aCols[ nReg, nPosPlan ] := "000000"
				EndIf
				If nPosSeqRe > 0
					oGet:aCols[ nReg, nPosSeqRe] := "0  "
				EndIf
				If nPosTaref > 0
					oGet:aCols[ nReg, nPosTaref] := "0     "
				EndIf
				oGet:aCols[ nReg, nPosPro  ] := "P"	// Produto
				oGet:aCols[ nReg, nPosCodI ] := aInsOrig[ nInsumo, POS_INS_PROD ]
				oGet:aCols[ nReg, nPosNome ] := aInsOrig[ nInsumo, POS_INS_DESC ]
				oGet:aCols[ nReg, nPosCale ] := "N"
				oGet:aCols[ nReg, nPosQtRe ] := 0
				oGet:aCols[ nReg, nQTDHEA  ] := aInsOrig[ nInsumo, POS_INS_QUANT ]
				oGet:aCols[ nReg, nUnidade ] := aInsOrig[ nInsumo, POS_INS_UM ]
				oGet:aCols[ nReg, nDestino ] := "T" // Troca
				oGet:aCols[ nReg, nPosFor  ] := aInsOrig[ nInsumo, POS_INS_CODFOR ]
				oGet:aCols[ nReg, nPosLoja ] := aInsOrig[ nInsumo, POS_INS_LOJFOR ]
				oGet:aCols[ nReg, nDtInici ] := dDataBase
				oGet:aCols[ nReg, nHrInici ] := ""
				oGet:aCols[ nReg, nAlmox   ] := aInsOrig[ nInsumo, POS_INS_LOCAL ]
				oGet:aCols[ nReg, nPosPrUn ] := aInsOrig[ nInsumo, POS_INS_VALUNIT ]
				oGet:aCols[ nReg, nPosDesc ] := aInsOrig[ nInsumo, POS_INS_VALDESC ]
				oGet:aCols[ nReg, nPosVlTot] := Round( ( oGet:aCols[ nReg, nQTDHEA  ] * oGet:aCols[ nReg, nPosPrUn ] ) - oGet:aCols[ nReg, nPosDesc ], 4 )
				oGet:aCols[ nReg, nPosRecWT] := 0
				oGet:aCols[ nReg, nTotHead+1 ] := .F.

			EndIf

		Next

		// Atualizar a tela dos Insumos ( rotina padr�o )
		oGet:oBrowse:Refresh()

	EndIf

	RestArea( aArea )
	RestArea( aAreaST9 )

	If !Empty( cAliAtu )
		DbSelectArea( cAliAtu )
	EndIf

Return



/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Marca  � Autor �Jorge Alberto - Solutio� Data �14/02/2019  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Marca/Desmarca o produto informado na tela.                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aInsumos -> Array com TODOS os insumos        			  ���
���          � oListInsum -> ListBox com os insumos						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PE_MNTA420GSA                                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Marca( aInsumos, nLin )

	Local nValZero := 0.0000
	Local nPos := 0
	Local nQuant := 0
	Local nValUnit := nValZero
	Local nValDesc := nValZero
	Local cProd := ""
	Local cNome := ""
	Local cForn := Space(6)
	Local cLoja := Space(2)
	Local aRet := {}
	Local lConf := .F.
	
	If Len( aInsumos ) <= 0
		Return
	Endif

	// Pego o Produto que ser� marcado
	cProd := aInsumos[ nLin, POS_INS_PROD ]

	If Empty( cProd )
		Return
	EndIf
	
	// Se est� desmarcado e o usu�rio clicou para marcar, ent�o ir� solicitar o Fornecedor
	If !aInsumos[ nLin, POS_INS_OK ]

		cForn := Space(6)
		cLoja := Space(2)
		nValUnit := nValZero
		nValDesc := nValZero
		nQuant   := 0
		cNome := ""

		While .T.
			// Somente poder� informar um Desconto, se o campo de Desconto da O.S. estiver zerado
			If ParamBox( {	{ 1,"Fornecedor:"		, cForn		,"","","SA2","",40,.T. },;
							{ 1,"Loja:"		 		, cLoja		,"","",""   ,"",40,.T. },;
						  	{ 1,"Valor Unit�rio:"	, nValUnit	,PesqPict("STL","TL_PRCUNIT"),"",""   ,"",40,.T. },;
						  	{ 1,"Valor Desconto:"	, nValDesc	,PesqPict("STL","TL_DESCPRD"),"",""   ,"M->TJ_VALDESC <= 0",40,.F. },;
						    { 1,"Quantidade:"		, nQuant	,PesqPict("STL","TL_QUANTID"),"",""   ,"",40,.T. };
						  }, "Dados adicionais", @aRet, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosX*/, /*nPosy*/, /*oDlgWizard*/, /*cLoad*/, .F./*lCanSave*/, /*lUserSave*/ )

				cForn := aRet[1]
				cLoja := aRet[2]
				nValUnit := aRet[3]
				nValDesc := aRet[4]
				nQuant := aRet[5]
				cNome := Posicione( "SA2", 1, xFilial("SA2") + cForn + cLoja, "A2_NOME" )

				If Empty( cNome )
					MsgAlert( "N�o foi poss�vel localizar o Fornecedor com os dados informados, favor informar os dados de um Fornecedor existente." )
				ElseIf aRet[3] <= 0
					MsgAlert( "� obrigat�rio que seja inforamdo um Valor Unit�rio." )
				ElseIf aRet[5] <= 0
					MsgAlert( "� obrigat�rio que seja inforamdo uma Quantidade." )
				ElseIf nValDesc >= nValUnit
					MsgAlert( "O Desconto deve ser menor do que o valor Unit�rio." )
				Else
					lConf := .T.
					Exit // Os dados s�o v�lidos, ent�o sai do loop
				EndIf
			Else
				lConf := .F.
				Exit // Se n�o confirmou, deixa passar
			EndIf
		EndDo

		If !lConf
			Return
		EndIf

		// Conforme o Produto marcado, vou atualizar no array original com todos os insumos ( aInsOrig )
		nPos := aScan( aInsOrig, { |u| u[POS_INS_PROD] == cProd } )
		If ( nPos > 0 .And. !Empty( cForn ) ) // S� poder� marcar se o usu�rio informou/selecionou um Fornecedor
			aInsOrig[ nPos, POS_INS_OK     ] := !aInsOrig[ nPos, POS_INS_OK ]
			aInsOrig[ nPos, POS_INS_CODFOR ] := cForn
			aInsOrig[ nPos, POS_INS_LOJFOR ] := cLoja
			aInsOrig[ nPos, POS_INS_VALDESC] := nValDesc
			aInsOrig[ nPos, POS_INS_VALUNIT] := nValUnit
			aInsOrig[ nPos, POS_INS_QUANT  ] := nQuant
			aInsOrig[ nPos, POS_INS_NOME   ] := cNome
		EndIf

		// Conforme o Produto marcado, vou atualizar no array dos insumos mostrados na tela e que pode estar filtrado ( aInsumos )
		nPos := aScan( aInsumos, { |u| u[POS_INS_PROD] == cProd } )
		If ( nPos > 0 .And. !Empty( cForn ) ) // S� poder� marcar se o usu�rio informou/selecionou um Fornecedor
			aInsumos[ nPos, POS_INS_OK     ] := !aInsumos[ nPos, POS_INS_OK ]
			aInsumos[ nPos, POS_INS_CODFOR ] := cForn
			aInsumos[ nPos, POS_INS_LOJFOR ] := cLoja
			aInsumos[ nPos, POS_INS_VALDESC] := nValDesc
			aInsumos[ nPos, POS_INS_VALUNIT] := nValUnit
			aInsumos[ nPos, POS_INS_QUANT  ] := nQuant
			aInsumos[ nPos, POS_INS_NOME   ] := cNome
		EndIf

	Else // Se a linha est� marcada e o usu�rio quer desmarcar, ent�o dever� limpar os dados dos arrays

		// Desmarca conforme o Produto selecionado
		nPos := aScan( aInsOrig, { |u| u[POS_INS_PROD] == cProd } )
		If nPos > 0
			aInsOrig[ nPos, POS_INS_OK     ] := !aInsOrig[ nPos, POS_INS_OK ]
			aInsOrig[ nPos, POS_INS_CODFOR ] := ""
			aInsOrig[ nPos, POS_INS_LOJFOR ] := ""
			aInsOrig[ nPos, POS_INS_VALDESC] := nValZero
			aInsOrig[ nPos, POS_INS_VALUNIT] := nValZero
			aInsOrig[ nPos, POS_INS_QUANT  ] := 0
			aInsOrig[ nPos, POS_INS_NOME   ] := ""
		EndIf

		nPos := aScan( aInsumos, { |u| u[POS_INS_PROD] == cProd } )
		If nPos > 0
			aInsumos[ nPos, POS_INS_OK     ] := !aInsumos[ nPos, POS_INS_OK ]
			aInsumos[ nPos, POS_INS_CODFOR ] := ""
			aInsumos[ nPos, POS_INS_LOJFOR ] := ""
			aInsumos[ nPos, POS_INS_VALDESC] := nValZero
			aInsumos[ nPos, POS_INS_VALUNIT] := nValZero
			aInsumos[ nPos, POS_INS_QUANT  ] := 0
			aInsumos[ nPos, POS_INS_NOME   ] := ""
		EndIf
	EndIf // If aInsumos[ nPos, POS_INS_OK ] // Se o usu�rio marcou a linha

Return



/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Filtra � Autor �Jorge Alberto - Solutio� Data �14/02/2019  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Filtra o texto informado pelo usu�rio conforme os Insumos  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cGetFiltro -> Texto com o filtro informado pelo usuoario   ���
���          � aInsumos -> Array com os insumos que ser�o filtrados       ���
���          � oListInsum -> ListBox com os insumos                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PE_MNTA420GSA                                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Filtra( cGetFiltro, aInsumos, oListInsum )

	Local nReg := 0
	Local aNewInsumos := {}
	Local nPctPrUn := PesqPict("STL","TL_PRCUNIT")
	Local nPctDesc := PesqPict("STL","TL_DESCPRD")
	Local nPctQuant := PesqPict("STL","TL_QUANTID")
	
	// Limpo para que possa receber o que ser� filtrado ou os insumos originalmente carregados na entrada do PE.
	aInsumos := {}

	If !Empty( cGetFiltro )

		For nReg := 1 To Len( aInsOrig )

			// Filtra o que o usu�rio digitou na tela com o que est� no array aInsOrig que � o conteudo original
			If ( Upper( AllTrim( cGetFiltro ) ) $ Upper( AllTrim( aInsOrig[ nReg, POS_INS_PROD ] ) ) .Or.;
				 Upper( AllTrim( cGetFiltro ) ) $ Upper( AllTrim( aInsOrig[ nReg, POS_INS_DESC ] ) );
			   )

				// Carrego no array tempor�rio os insumos filtrados
				AADD( aNewInsumos, { aInsOrig[ nReg, POS_INS_OK    ],;
									 aInsOrig[ nReg, POS_INS_PROD  ],;
									 aInsOrig[ nReg, POS_INS_DESC  ],;
									 aInsOrig[ nReg, POS_INS_TIPO  ],;
									 aInsOrig[ nReg, POS_INS_UM    ],;
									 aInsOrig[ nReg, POS_INS_LOCAL ],;
									 aInsOrig[ nReg, POS_INS_VALDESC ],;
									 aInsOrig[ nReg, POS_INS_VALUNIT ],;
									 aInsOrig[ nReg, POS_INS_QUANT   ],;
									 aInsOrig[ nReg, POS_INS_CODFOR],;
									 aInsOrig[ nReg, POS_INS_LOJFOR],;
									 aInsOrig[ nReg, POS_INS_NOME  ] } )
			EndIf
		Next
		aInsumos := aClone( aNewInsumos )
	Else
		aInsumos := aClone( aInsOrig )
	EndIf
	
	If Len( aInsumos ) <= 0
		aInsumos := Array( 1, { .F., "", "", "", "", "", 0, 0, 0, "", "", "" } )
	EndIf 

	// Ordena pelos registros marcados e depois por C�digo
	aSort( aInsumos,,, {|x,y| IIF( x[POS_INS_OK], '1', '0' ) + x[POS_INS_PROD] < IIF( y[POS_INS_OK], '1', '0' ) + y[POS_INS_PROD] } )

	oListInsum:SetArray( aInsumos )
	If Len( aInsumos ) > 0
		oListInsum:bLine:={||{If(aInsumos[ oListInsum:nAt, POS_INS_OK ],oOk,oNo),;
							 aInsumos[ oListInsum:nAt, POS_INS_PROD  ],;
							 aInsumos[ oListInsum:nAt, POS_INS_DESC  ],;
							 aInsumos[ oListInsum:nAt, POS_INS_TIPO  ],;
							 aInsumos[ oListInsum:nAt, POS_INS_UM    ],;
							 aInsumos[ oListInsum:nAt, POS_INS_LOCAL ],;
							 Transform( aInsumos[ oListInsum:nAt, POS_INS_VALDESC ], nPctDesc ),;
							 Transform( aInsumos[ oListInsum:nAt, POS_INS_VALUNIT ], nPctPrUn ),;
							 Transform( aInsumos[ oListInsum:nAt, POS_INS_QUANT ], nPctQuant ),;
							 aInsumos[ oListInsum:nAt, POS_INS_CODFOR],;
							 aInsumos[ oListInsum:nAt, POS_INS_LOJFOR],;
							 aInsumos[ oListInsum:nAt, POS_INS_NOME  ] } }
	EndIf
	oListInsum:nAt := 1
	oListInsum:Refresh()

Return
