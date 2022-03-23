#INCLUDE "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "PARMTYPE.CH"

/*/-----------------------------------------------------------------/
{Protheus.doc} MARA040
Tela de gerencimento das divergências da importação do XML com pré-nota

@type  User Function
@author Jean Rehermann - Solutio IT
@since 26/01/2021
@return Nil
/-----------------------------------------------------------------/*/
User Function MARA040()

	Local aCores  := {}
	Local cFilQry := ""

	Private cCadastro  := "Divergências XML"
	Private aRotina    := MenuDef()
	Private aLegenda   := {}

	aCores := {;
		{ ' ZX1_BLOQ == "0" ','BR_PRETO'   },; // Sem Divergências
		{ ' ZX1_BLOQ == "1" ','BR_LARANJA' },; // Com Divergências (e pedido)
		{ ' ZX1_BLOQ == "9" ','BR_VERMELHO'},; // Data de Entrega
		{ ' ZX1_BLOQ == "2" ','BR_AZUL'    },; // Sem pedido
		{ ' ZX1_BLOQ == "3" ','BR_PINK'    };  // Sem amarração Prod x Forn
	}

	aLegenda := {;
		{'BR_PRETO'   ,"Sem Divergências"           },;
		{'BR_LARANJA' ,"Com Divergências (e pedido)"},;
		{'BR_VERMELHO',"Aviso - Data de Entrega"    },;
		{"BR_AZUL"    ,"Sem pedido"                 },;
		{'BR_PINK'    ,"Sem amarração Prod x Forn"  };
	}

	dbSelectArea("ZX1")
	dbSetOrder(1)

	cFilQry := "R_E_C_N_O_ IN ( "
	/*
	// XML com pré nota cadastrada
	cFilQry += "  SELECT ZX1.R_E_C_N_O_ R_E_C_N_O_ "
	cFilQry += "    FROM "+ RetSqlName("SF1") +" SF1, "+ RetSqlName("ZX1") +" ZX1 "
	cFilQry += "   WHERE ZX1_CHVNFE = F1_CHVNFE "
	cFilQry += "     AND ZX1.D_E_L_E_T_ = ' ' "
	cFilQry += "     AND SF1.D_E_L_E_T_ = ' ' "
	cFilQry += "     AND ZX1_STATUS = '1' "
	cFilQry += "     AND F1_STATUS = ' ' "
	cFilQry += "     AND ZX1_TPDOC = 'NFE' "

	cFilQry += "  UNION ALL "

	// XML sem pré nota cadastrada por ocasião de não ter PC ou não ter amarração do Produto
	cFilQry += "  SELECT ZX1.R_E_C_N_O_ R_E_C_N_O_ "
	cFilQry += "    FROM "+ RetSqlName("ZX1") +" ZX1 "
	cFilQry += "   WHERE ZX1.D_E_L_E_T_ = ' ' "
	cFilQry += "     AND ZX1_BLOQ IN ('1','2','3','9') "
	cFilQry += "     AND ZX1_STATUS IN ('0','1','3') "
	cFilQry += "     AND ZX1_TPDOC = 'NFE' "
	cFilQry += ")"
	*/

	cFilQry += "  SELECT ZX1.R_E_C_N_O_ R_E_C_N_O_ "
	cFilQry += "    FROM "+ RetSqlName("ZX1") +" ZX1 "
	cFilQry += "   WHERE ZX1.D_E_L_E_T_ = ' ' "
	cFilQry += "     AND ZX1_STATUS <> '5' "
	cFilQry += "     AND ZX1_TPDOC = 'NFE' "
	cFilQry += ")"

	mBrowse(006,001,022,075,"ZX1",,,,,,aCores,,,,,,,,cFilQry)

Return()


// Rotina para criar as opções da rotina
Static Function Menudef()

	Local aRotina	:= {}

	aAdd( aRotina,{"Pesquisar"         ,"AxPesqui"  ,0,1} )
	aAdd( aRotina,{"Informar PC"       ,"U_MRA40IPC",0,4} )
	aAdd( aRotina,{"Alterar PC"        ,"U_MRA40APC",0,4} )
	aAdd( aRotina,{"Produto x Fornec." ,"U_MRA40PXF",0,4} )
	aAdd( aRotina,{"Reprocessar Nota"  ,"U_MRA40REP",0,4} )
	aAdd( aRotina,{"Liberação Manual"  ,"U_MRA40LIB",0,4} )
	aAdd( aRotina,{"Visualizar"        ,"U_MRA40VIS",0,2} )
	aAdd( aRotina,{"Divergencias"      ,"U_MRA40DIV",0,2} )
	aAdd( aRotina,{"Relatório Pre Nota","U_MARR005" ,0,2} )
	aAdd( aRotina,{"Legenda"           ,"U_MRA40LEG",0,2} )

Return( aRotina )


// Chama a função de pedidos de compra para informar PC
User Function MRA40IPC()
	If ZX1->ZX1_BLOQ $ "019"
		MsgAlert("Documento com pedido associado, selecione a opção de Alterar Pedido de Compras")
		Return
	Else
		PedComDiv("I")
	EndIf
Return


// Chama a função de pedidos de compra para alterar PC
User Function MRA40APC()
	If ZX1->ZX1_BLOQ == "2"
		MsgAlert("Não há pedido para alterar, selecione a opção de Informar Pedido de Compras")
		Return
	Else
		PedComDiv("A")
	EndIf
Return


// Função de exibição da legenda
User Function MRA40LEG()

	BrwLegenda( cCadastro, "Legenda", aLegenda )

Return(.T.)


// Função que cria a interface de visualização
User Function MRA40VIS( cAlias, nReg, nOpcx )

	Local oDlg
	Private	aHeader := {}
	Private aCols   := {}

	FillGetDados(nOpcx,"ZX2",1,,,,{"ZX2_FILIAL","ZX2_CHVNFE"},,,,{|| GetCampos() },.F.,,,,,,)

	aSize := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 100, 050, .t., .t. } )
	AAdd( aObjects, { 100, 050, .t., .t. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oDlg TITLE "Documento Fiscal" From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
		EnChoice( cAlias, nReg, nOpcx, , , , , aPosObj[1],,3,,,,,,,,,,)
		MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,,,"",,,,,,,,,,,)
		oDlg:lMaximized := .T.
	ACTIVATE MSDIALOG oDlg On INIT GetEnch( oDlg,{||oDlg:End()},{||oDlg:End()},nOpcx)

Return( nOpcx )


// Cria opções no menu Ações Relacionadas
Static Function GetEnch( oDlg, bOk, bCancel, nOpc )

	Local aButtons   := {}
	/*
	If nOpc == 1
		AAdd( aButtons, { "S4WB004N", { || ZeraTudo() }, "&Zerar", "ZERAR TELA" } )
	EndIf
    */
Return( EnchoiceBar( oDlg, bOK, bcancel,, aButtons ) )


// Monta o array aCols com os itens na visualização de NFE
Static Function GetCampos()

	Local _nI    := 0
	Local nUsado := Len( aHeader )

	aCols := {}

	dbSelectArea("ZX2")
	dbSetOrder(1)
	dbSeek( xFilial("ZX2") + ZX1->ZX1_CHVNFE )

	While !ZX2->( Eof() ) .And. ZX2->ZX2_FILIAL + ZX2->ZX2_CHVNFE == xFilial("ZX2") + ZX1->ZX1_CHVNFE

		aAdd( aCols, Array( nUsado + 1 ) )

		For _ni := 1 to nUsado - 2
			If AllTrim( aHeader[ _ni, 2 ] ) == "ZX2_OPER"
				aCols[ Len( aCols ), _ni ] := Space(2)
			Else
				aCols[ Len( aCols ), _ni ] := FieldGet( FieldPos( aHeader[ _ni, 2 ] ) )
			EndIf
		Next
		aCols[ Len( aCols ) ][ nUsado - 1 ] := "ZX2"
		aCols[ Len( aCols ) ][ nUsado     ] := ZX2->( Recno() )
		aCols[ Len( aCols ) ][ nUsado + 1 ] := .F.

  	  	ZX2->( dbSkip() )
	End

Return


// Faz a avaliação dos produtos sem amarração no SA5/SA7
User Function MRA40PXF()

	Local cQuery  := ""
	Local cAlias  := ""
	Local nSemPrd := 0
	Local nStsNOk := 0
	Local cTpNf   := ZX1->ZX1_TIPO

	If ZX1->ZX1_BLOQ != "3"
		MsgAlert("Funcionalidade não disponível")
		Return
	EndIf

	// Inicia o processo de verificação dos produtos
	cQuery := "SELECT ZX2_COD, ZX2_CODFOR, ZX2_DESCF, R_E_C_N_O_, ZX2_TES FROM "+ RetSqlName("ZX2") +" WHERE ZX2_CHVNFE = '"+ ZX1->ZX1_CHVNFE +"' AND D_E_L_E_T_ = ' '"
	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )

	While !(cAlias)->( Eof() )

		If Empty( (cAlias)->ZX2_COD )

			cCodProd := Space( TamSX3("B1_COD")[1] )

			If !Empty( (cAlias)->ZX2_CODFOR )

				If cTpNf $ "CN"
					SA5->( dbSetOrder(14) )
				Else
					SA7->( dbSetOrder(3) )
				EndIf

				If ( cTpNf $ "CN" .And. SA5->( dbSeek( xFilial("SA5") + ZX1->ZX1_CLIFOR + ZX1->ZX1_LOJA + (cAlias)->ZX2_CODFOR ) ) ) .Or.;
					( cTpNf $ "DB" .And. SA7->( dbSeek( xFilial("SA7") + ZX1->ZX1_CLIFOR + ZX1->ZX1_LOJA + (cAlias)->ZX2_CODFOR ) ) )
					// Usa o código cadastrado na tabela SA5 ou SA7
					cCodProd := Iif( cTpNf $ "CN", SA5->A5_PRODUTO, SA7->A7_PRODUTO )
				Else
					// Incluir item no cadastro Produto x Fornecedor (SA5) ou Produto x Cliente (SA7)
					cCodProd := IncPrdA5A7( (cAlias)->ZX2_CODFOR, (cAlias)->ZX2_DESCF, .T., cTpNf )
				EndIf

			EndIf

			If !Empty( cCodProd )
				SB1->( dbSetOrder(1) )
				SB1->( dbSeek( xFilial("SB1") + cCodProd ) )

				ZX2->( dbGoTo( (cAlias)->R_E_C_N_O_ ) )
				ZX2->( RecLock("ZX2",.F.) )
					ZX2->ZX2_COD := cCodProd
				ZX2->( MsUnLock() )
			EndIf

		EndIf

		(cAlias)->( dbSkip() )
	End

	(cAlias)->( DbCloseArea() )

	// Verifica se pode mudar de status (preenchidos todos os produtos e todos os tipos de entrada)
	cQuery := "SELECT COUNT(*) TOT FROM "+ RetSqlName("ZX2") +" WHERE ZX2_CHVNFE = '"+ ZX1->ZX1_CHVNFE +"' AND D_E_L_E_T_ = ' ' AND ( ZX2_COD = ' ' OR ZX2_TES = ' ' )"
	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )
	nStsNOk := (cAlias)->TOT
	(cAlias)->( dbCloseArea() )

	// Verifica se pode mudar de código de bloqueio apenas para o produto, sem considerar o TES
	cQuery := "SELECT COUNT(*) TOT FROM "+ RetSqlName("ZX2") +" WHERE ZX2_CHVNFE = '"+ ZX1->ZX1_CHVNFE +"' AND D_E_L_E_T_ = ' ' AND ZX2_COD = ' ' "
	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )
	nSemPrd := (cAlias)->TOT
	(cAlias)->( dbCloseArea() )

	ZX1->( RecLock("ZX1",.F.) )
		ZX1->ZX1_STATUS := Iif( nStsNOk == 0, "0", "3" )
		ZX1->ZX1_BLOQ   := Iif( nSemPrd == 0, "2", "3" )
	ZX1->( MsUnLock() )

Return


// Função para inclusão do produto no cadastro SA5 - Produto x Fornecedor ou SA7 - Produto x Cliente
Static Function IncPrdA5A7( cProdFor, cDescFor, lMenu, cTpNf )

	Local cCodFor   := cProdFor
	Local cNomFor   := cDescFor
	Local cCodPro   := Space( TamSX3("B1_COD")[ 1 ] )
	Local _lRetorno := .F.
	Local aRet      := {}
	Local _nOpca    := 0
	Local _nLin     := 24
	Local cForn     := Iif( lMenu, ZX1->ZX1_CLIFOR, aRetEnt[ 1 ][ 1 ] )
	Local cLoja     := Iif( lMenu, ZX1->ZX1_LOJA  , aRetEnt[ 1 ][ 2 ] )
	Local cTipoNf   := cTpNf
	Local bOk       := { || _nOpca := 1, aRet := ValPrdA5A7( cCodPro, cCodFor, cForn, cLoja, cTipoNf ), _lRetorno := aRet[1].Or.aRet[2], oDlgSA5:End() }
	Local bCancel   := { || cCodPro := "", oDlgSA5:End() }
	Local oGet1
	Local oGet2
	Local oGet3

	Private oGet4
	Private cNomPro := Space( TamSX3("B1_DESC")[ 1 ] )

	Private oDlgSA5

	Define MsDialog oDlgSA5 Title "Cadastro Produto X "+ Iif( cTipoNf $ "CN", "Fornecedor", "Cliente" ) From 178,181 To 475,695 Pixel

		@011+_nLin,002 TO 064+_nLin,250 LABEL "[ Produto do "+ Iif( cTipoNf $ 'CN', 'Fornecedor', 'Cliente' ) +" ]" Pixel Of oDlgSA5
		@070+_nLin,002 TO 122+_nLin,250 LABEL "[     Nosso Produto     ]" COLOR CLR_BLUE Pixel Of oDlgSA5

		@021+_nLin,006 Say "Codigo do Produto"          Size 060,008 COLOR CLR_BLACK Pixel Of oDlgSA5
		@029+_nLin,006 MsGet oGet1 Var cCodFor When .F. Size 100,009 COLOR CLR_BLUE Picture "@!" Pixel Of oDlgSA5
		@042+_nLin,006 Say "Descrição do Produto"       Size 070,008 COLOR CLR_BLACK Pixel Of oDlgSA5
		@050+_nLin,006 MsGet oGet2 Var cNomFor When .F. Size 240,009 COLOR CLR_BLUE Picture "@!" Pixel Of oDlgSA5

		@079+_nLin,006 Say "Código do Produto" Size 060,008 COLOR CLR_BLUE Pixel Of oDlgSA5
		@087+_nLin,006 MsGet oGet3 Var cCodPro Size 100,009 COLOR CLR_BLUE Picture "@!" Pixel Of oDlgSA5 F3("SB1") Valid( ExistCpo( "SB1", cCodPro ) ) On Change ( cNomPro := Posicione("SB1", 1, xFilial("SB1") + cCodPro, "B1_DESC"), oGet4:Refresh() )
		@100+_nLin,006 Say "Descrição Produto" Size 060,008 COLOR CLR_BLUE Pixel Of oDlgSA5
		@108+_nLin,006 MsGet oGet4 Var cNomPro When .F. Size 240,009 COLOR CLR_BLUE Picture "@!" Pixel Of oDlgSA5

	Activate MsDialog oDlgSA5 On Init ( EnchoiceBar( oDlgSA5, bOk, bCancel,, ) ) Centered Valid _lRetorno

	If _nOpca == 1 .And. aRet[1]
		If cTipoNf $ "CN"
			dbSelectArea("SA5")
			RecLock( "SA5", .T. )
				A5_FILIAL  := xFilial("SA5")
				A5_FORNECE := cForn
				A5_LOJA    := cLoja
				A5_NOMEFOR := Posicione("SA2", 1, xFilial("SA2") + cForn + cLoja, "A2_NREDUZ")
				A5_PRODUTO := cCodPro
				A5_NOMPROD := cNomPro
				A5_CODPRF  := cCodFor
			MsUnLock()
		Else
			dbSelectArea("SA7")
			RecLock( "SA7", .T. )
				A7_FILIAL  := xFilial("SA7")
				A7_CLIENTE := cForn
				A7_LOJA    := cLoja
				A7_PRODUTO := cCodPro
				A7_DESCCLI := cNomPro
				A7_CODCLI  := cCodFor
			MsUnLock()
		EndIf
	EndIf

Return( cCodPro )

// Valida o produto selecionado no cadastro do Produto x Fornecedor ou Produto x Cliente
Static Function ValPrdA5A7( cCodPro, cProFor, cForn, cLoja, cTipNf )

	Local _lInclui := .T.
	Local _lAltera := .F.
	Local _cCodEnt := ""
	Local _cAlias  := Iif( cTipNf $ "CN", "SA5", "SA7" )

	dbSelectArea(_cAlias)
	dbSetOrder(1)
	If !( (_cAlias)->( dbSeek( xFilial(_cAlias) + cForn + cLoja + cCodPro ) ) )
		_lInclui := .T.
	Else
		_lInclui := .F.
		_cCodEnt := Iif( cTipNf $ "CN", SA5->A5_CODPRF, SA7->A7_CODCLI )
		If Empty( _cCodEnt )
			_lAltera := .T.
			RecLock(_cAlias,.F.)
				If cTipNf $ "CN"
					SA5->A5_CODPRF := cProFor
				Else
					SA7->A7_CODCLI := cProFor
				EndIf
			MsUnLock()
			Aviso( "Atenção", "Este produto já foi utilizado para este "+ Iif( cTipNf $ "CN", "fornecedor", "cliente" ) +", mas o código do produto do "+ Iif( cTipNf $ "CN", "fornecedor", "cliente" ) +" estava em branco e foi atualizado.", { "Ok" } )

		ElseIf !Empty( _cCodEnt ) .And. AllTrim( cProFor ) != AllTrim( _cCodEnt )

			Aviso( "Atenção", "Este produto já foi utilizado para este "+ Iif( cTipNf $ "CN", "fornecedor", "cliente" ) +" com o código "+ AllTrim( _cCodEnt ) +".", { "Ok" } )
			_lInclui := .F.
			_lAltera := .F.
		Else
			_lAltera := .T.
		EndIf
	EndIf

Return( { _lInclui, _lAltera } )

// Abre a janela com os itens para associar o pedido de compras
Static Function PedComDiv( cTpOp )

	Local oSize
	Local aDimen := {}
	Local aCols  := {}
	Local aHead  := {}
	Local aButt  := {}
	Local aStru  := {}
	Local nOpcA  := 0
	Local nItem  := 0
	Local _nP    := 0
	Local _nPPc  := 0
	Local _nPPIt := 0
	Local _nPTES := 0
	Local cAlias := "ZX2TMP"

	Local nX 	 := 0
	Local nY 	 := 0
	Local aHeadT := {}
	Local _cSX3  := GetNextAlias()

	Private oGetDad

	If ZX1->ZX1_STATUS == "9"
		MsgAlert("Documento cancelado no Sefaz")
		Return( .F. )
	ElseIf ZX1->ZX1_STATUS == "8"
		MsgAlert("Esta nota já foi recusada, não pode mais ser alterada")
		Return( .F. )
	ElseIf ZX1->ZX1_STATUS == "5"
		MsgAlert("Este documento é um resumo, ainda não foi realizado o download do XML")
		Return( .F. )
	ElseIf ZX1->ZX1_STATUS == "2"
		MsgAlert("Esta nota já foi classificada")
		Return( .F. )
	EndIf

	SetKey( VK_F5, { || SelPcFor(0) } )
	SetKey( VK_F6, { || SelPcFor(1) } )
	SetKey( VK_F9, { || DUPLITEM() } )

	aAdd( aButt, { "PEDIDO", {|| SelPcFor(0) }, "F5 - Pedido de Compra" } )
	aAdd( aButt, { "PEDIDO", {|| SelPcFor(1) }, "F6 - Item Pedido Compra" } )
	aAdd( aButt, { "PEDIDO", {|| LimparPc(0) }, "Limpar Pedidos" } )
	aAdd( aButt, { "PEDIDO", {|| LimparPc(1) }, "Limpar Pedido Item" } )
	aAdd( aButt, { "PEDIDO", {|| DUPLITEM()  }, "F9 - Duplicar Item" } )

	OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX3,"SX3",Nil,.F.)

	lOpen := Select(_cSX3) > 0
	If (lOpen)
		dbSelectArea(_cSX3)
		(_cSX3)->(dbSetOrder(1)) //X3_CAMPO
		(_cSX3)->(dbSeek("ZX2"))
		While ( !(_cSX3)->(Eof()) .And. &("(_cSX3)->X3_ARQUIVO") == "ZX2" )
			If (X3USO(&("(_cSX3)->X3_USADO")) .AND. cNivel >= &("(_cSX3)->X3_NIVEL") .And. !AllTrim(&("(_cSX3)->X3_CAMPO"))$"ZX2_FILIAL#ZX2_CHVNFE")
				aAdd(aHead,{ TRIM(&("(_cSX3)->X3_Titulo")),&("(_cSX3)->X3_CAMPO"),&("(_cSX3)->X3_PICTURE"),&("(_cSX3)->X3_TAMANHO"),;
				&("(_cSX3)->X3_DECIMAL"),&("(_cSX3)->X3_VALID"),&("(_cSX3)->X3_USADO"),&("(_cSX3)->X3_TIPO"),&("(_cSX3)->X3_F3"),&("(_cSX3)->X3_CONTEXT")})
			EndIf
		(_cSX3)->(DBSkip())
		EndDo
	Endif
	(_cSX3)->(dbCloseArea())

	ADHeadRec( "ZX2", aHead ) // Campos adicionais

	_nPPc  := aScan( aHead, {|o| AllTrim( o[2] ) == "ZX2_PC"     } )
	_nPPIt := aScan( aHead, {|o| AllTrim( o[2] ) == "ZX2_ITEMPC" } )
	_nPPrd := aScan( aHead, {|o| AllTrim( o[2] ) == "ZX2_COD"    } )
	_nPItm := aScan( aHead, {|o| AllTrim( o[2] ) == "ZX2_ITEM"   } )
	_nPTES := aScan( aHead, {|o| AllTrim( o[2] ) == "ZX2_TES"    } )

	// Alterar a ordem do ZX2 que vem do SX3
	For nX := 1 To Len( aHead )

		If nX == 2
			aAdd( aHeadT, Nil )
			aAdd( aHeadT, Nil )
		EndIf

		If nX != _nPPc .And. nX != _nPPIt
			aAdd( aHeadT, aHead[ nX ] )
		EndIf

	Next

	aHeadT[ 2 ] := aHead[ _nPPc  ]
	aHeadT[ 3 ] := aHead[ _nPPIt ]

	aHead := aHeadT // Atualiza o aHead já com as posições da coluna alteradas

	_nPPc  := aScan( aHead, {|o| AllTrim( o[2] ) == "ZX2_PC"     } )
	_nPPIt := aScan( aHead, {|o| AllTrim( o[2] ) == "ZX2_ITEMPC" } )
	_nPPrd := aScan( aHead, {|o| AllTrim( o[2] ) == "ZX2_COD"    } )
	_nPItm := aScan( aHead, {|o| AllTrim( o[2] ) == "ZX2_ITEM"   } )
	_nPTES := aScan( aHead, {|o| AllTrim( o[2] ) == "ZX2_TES"    } )

	aStru  := ZX2->( dbStruct() )

	cQuery := "SELECT ZX2.*,ZX2.R_E_C_N_O_ ZX2RECNO "
	cQuery += "FROM "+RetSqlName("ZX2")+" ZX2 "
	cQuery += "WHERE ZX2_FILIAL='"+xFilial("ZX2")+"' AND "
	cQuery += "ZX2.ZX2_CHVNFE='"+ZX1->ZX1_CHVNFE+"' AND "
	cQuery += "ZX2.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY ZX2.ZX2_ITEM "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	For nX := 1 To Len(aStru)
		If aStru[ nX, 2 ] <> "C"
			TcSetField( cAlias, aStru[ nX, 1 ], aStru[ nX, 2 ], aStru[ nX, 3 ], aStru[ nX, 4 ] )
		EndIf
	Next nX

	dbSelectArea(cAlias)
	While (cAlias)->( !Eof() )

		nItem++
		aAdd( aCols, Array( Len( aHead ) + 1 ) )

		For nY := 1 to Len( aHead )
			If IsHeadRec( aHead[ nY ][ 2 ] )
				aCols[ nItem ][ nY ] := (cAlias)->ZX2RECNO
			ElseIf IsHeadAlias( aHead[ nY ][ 2 ] )
				aCols[ nItem ][ nY ] := "ZX2"
			ElseIf ( aHead[ nY ][ 10 ] <> "V" )
				aCols[ nItem ][ nY ] := (cAlias)->( FieldGet( FieldPos( aHead[nY][2] ) ) )
			Else
				If AllTrim(aHead[nY][2]) == "ZX2_DESCRI"
					If !Empty( (cAlias)->ZX2_COD )
						aCols[ nItem ][ nY ] := Posicione("SB1",1,xFilial("SB1") + AllTrim((cAlias)->ZX2_COD),"B1_DESC")
					Else
						aCols[ nItem ][ nY ] := Space(30)
					EndIf
				Else
					aCols[ nItem ][ nY ] := (cAlias)->( CriaVar( aHead[nY][2] ) )
				EndIf
			EndIf
			aCols[ nItem ][ Len( aHead ) + 1 ] := .F.
		Next nY
		(cAlias)->( dbSkip() )
	EndDo
	(cAlias)->( dbCloseArea() )

	oSize := FwDefSize():New()
	oSize:aMargins  := { 3, 3, 3, 3 }
	oSize:aWorkArea := {000,000, 350, 160 }
	oSize:AddObject( "CAB", 100, 10, .T., .T. )
	oSize:AddObject( "GET", 100, 80, .T., .T. )
	oSize:AddObject( "ROD", 100, 10, .T., .T. )
	oSize:lProp := .T.
	oSize:Process()

	aAdd( aDimen, { oSize:GetDimension("CAB","LININI")+30, oSize:GetDimension("CAB","COLINI"), 0, 0 } )
	aAdd( aDimen, { oSize:GetDimension("GET","LININI")+28, oSize:GetDimension("GET","COLINI"), oSize:GetDimension("GET","LINEND")+50, oSize:GetDimension("GET","COLEND")+100 } )
	aAdd( aDimen, { oSize:GetDimension("ROD","LININI"), oSize:GetDimension("ROD","COLINI"), 0, 0 } )

	DEFINE MSDIALOG oDlg FROM 000,000 TO 400,900 TITLE "Associar Pedido de Compras aos Itens" Of oMainWnd PIXEL

	@aDimen[1][1],aDimen[1][2]    SAY "Documento: "+ ZX1->ZX1_DOC +"/"+ ZX1->ZX1_SERIE Of oDlg PIXEL SIZE 90 ,9
	@aDimen[1][1],aDimen[1][2]+120 SAY Posicione("SA2", 1, xFilial("SA2")+ZX1->ZX1_CLIFOR+ZX1->ZX1_LOJA,"A2_NREDUZ") Of oDlg PIXEL SIZE 250,009

	oGetDad := MsNewGetDados():New(aDimen[2][1],aDimen[2][2],aDimen[2][3],aDimen[2][4],0,"","","",,,Len(aCols),,,,oDlg,aHead,aCols)

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg,{|| Iif( oGetDad:TudoOk(),( nOpcA:=1,oDlg:End() ),( nOpcA:=0 ) ) },{|| oDlg:End() },,aButt )

	If nOpcA == 1

		For _nP := 1 To Len( aCols )

			If _nPPc > 0 .And. _nPPIt > 0 .And. _nPPrd > 0 .And. _nPItm > 0 .And. _nPTES > 0

				ZX2->( dbSetOrder(3) )
				If ZX2->( dbSeek( xFilial("ZX2") + ZX1->ZX1_CHVNFE + oGetDad:aCols[ _nP, _nPPrd ] + oGetDad:aCols[ _nP, _nPItm ] ) )
					ZX2->( RecLock( "ZX2", .F. ) )
						ZX2->ZX2_PC     := oGetDad:aCols[ _nP, _nPPc  ]
						ZX2->ZX2_ITEMPC := oGetDad:aCols[ _nP, _nPPIt ]
						ZX2->ZX2_TES    := oGetDad:aCols[ _nP, _nPTES ]
					ZX2->( MsUnLock() )
				EndIf
			EndIf
		Next

		// Avalia as divergências
		Processa({|| AvalPcIt(ZX1->ZX1_CHVNFE,.T.) },"Aguarde","Avaliando se há divergências...",.T.)

	EndIf

	SetKey( VK_F5, Nil )
	SetKey( VK_F6, Nil )
	SetKey( VK_F9, Nil )

Return

// Seleciona o pedido de compras
Static Function SelPcFor( nOp )

	Local cQuery    := ""
	Local _nOpca    := 0
	Local nItem     := 0
	Local bOk       := { || _nOpca:=1, _lRetorno:=.T., oDlgF5:End() }
	Local bCancel   := { || _nOpca:=0, oDlgF5:End() }
	Local aButtons  := {}
	Local _aStruTrb := {}  //Estrutura do temporario
	Local _aBrowse  := {}  //Array do Browse para seleção dos pedidos
	Local cMarca    := ""  //Variaveis para o MsSelect
	Local _cArqEmp  := ""  //Arquivo temporário
	Local lInverte  := .F. //Variaveis para o MsSelect
	Local _lRetorno := .F.
	Local nPIte     := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_ITEM" } )
	Local nPPco     := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_PC" } )
	Local nPPit     := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_ITEMPC" } )
	Local nPTES     := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_TES" } )

	Private oBrwF5 //Objeto do MsSelect
	Private oDlgF5

	Private TRB := GetNextAlias() //Alias Tabela Temporária

	aAdd( aButtons, { "HISTORIC", { || VisPedCom() }, "Visualizar Pedido", "Visualizar Pedido" , { || .T. } } )
	aAdd( aButtons, { "HISTORIC", { || AltPedCom() }, "Alterar Pedido", "Alterar Pedido" , { || .T. } } )

	If nOp == 0

		aAdd( _aStruTrb, { "PC_OK"     , "C", 02, 0 } )
		aAdd( _aStruTrb, { "PC_NUM"    , "C", TamSX3("C7_NUM" )[1], 0 } )
		aAdd( _aStruTrb, { "PC_EMISSAO", "D", 08, 0 } )
		aAdd( _aStruTrb, { "PC_COND"   , "C", 03, 0 } )
		aAdd( _aStruTrb, { "PC_CONTATO", "C", 20, 0 } )
		aAdd( _aStruTrb, { "PC_TOTAL"  , "C", 03, 0 } )

		aAdd( _aBrowse, { "PC_OK"     , "", ""        } )
		aAdd( _aBrowse, { "PC_NUM"    , "", "Número"  } )
		aAdd( _aBrowse, { "PC_EMISSAO", "", "Emissão" } )
		aAdd( _aBrowse, { "PC_COND"   , "", "Condição"} )
		aAdd( _aBrowse, { "PC_CONTATO", "", "Contato" } )
		aAdd( _aBrowse, { "PC_TOTAL"  , "", "Itens"   } )

	Else

		aAdd( _aStruTrb, { "PC_OK"     , "C", 02                     , 0 } )
		aAdd( _aStruTrb, { "PC_NUM"    , "C", TamSX3("C7_NUM")[1]    , 0 } )
		aAdd( _aStruTrb, { "PC_ITEM"   , "C", TamSX3("C7_ITEM")[1]   , 0 } )
		aAdd( _aStruTrb, { "PC_PRODUTO", "C", TamSX3("C7_PRODUTO")[1], 0 } )
		aAdd( _aStruTrb, { "PC_DESCRI" , "C", TamSX3("C7_DESCRI")[1] , 0 } )
		aAdd( _aStruTrb, { "PC_PRECO"  , "N", TamSX3("C7_PRECO")[1]  , TamSX3("C7_PRECO")[2] } )
		aAdd( _aStruTrb, { "PC_SALDO"  , "N", TamSX3("C7_QUANT")[1]  , TamSX3("C7_QUANT")[2] } )
		aAdd( _aStruTrb, { "PC_DATPRF" , "D", 08                     , 0 } )

		aAdd( _aBrowse, { "PC_OK"     , "", ""             , "" } )
		aAdd( _aBrowse, { "PC_NUM"    , "", "Número"       , "" } )
		aAdd( _aBrowse, { "PC_ITEM"   , "", "Item"         , "" } )
		aAdd( _aBrowse, { "PC_PRODUTO", "", "Produto"      , "" } )
		aAdd( _aBrowse, { "PC_DESCRI" , "", "Descrição"    , "" } )
		aAdd( _aBrowse, { "PC_PRECO"  , "", "Preço Unit."  , "@E 99,999,999,999.9999" } )
		aAdd( _aBrowse, { "PC_SALDO"  , "", "Saldo do Item", "@E 999,999,999.9999" } )
		aAdd( _aBrowse, { "PC_DATPRF" , "", "Prev.Entrega" , "" } )

	EndIf

	If Select("TRB") > 0
		TRB->(DbCloseArea())
	Endif

	//Criação do objeto
	If (Select(TRB) > 0)
		oTRB:Delete()
	EndIf

	oTRB := FWTemporaryTable():New( TRB, _aStruTrb )
	oTRB:AddIndex("01", { "PC_NUM" } )
	oTRB:Create()

	If nOp == 1
		cQuery := "SELECT C7_NUM, C7_ITEM, C7_PRODUTO, C7_DESCRI, C7_PRECO, ( C7_QUANT - C7_QUJE - C7_QTDACLA ) SALDO, C7_DATPRF "
    Else
	    cQuery := "SELECT C7_NUM, C7_EMISSAO, C7_COND, C7_CONTATO, COUNT(*) TOTAL "
    EndIf
    cQuery += " FROM "+ RetSqlName("SC7")
	cQuery += " WHERE "
	cQuery += " C7_FORNECE = '"+ ZX1->ZX1_CLIFOR +"' AND C7_LOJA = '"+ ZX1->ZX1_LOJA +"' AND "
	cQuery += " ( C7_QUANT - C7_QUJE - C7_QTDACLA ) > 0 AND "
	cQuery += " C7_RESIDUO = ' ' AND "
	cQuery += " C7_TPOP <> 'P' AND "
	cQuery += " C7_FILIAL = '"+ xFilial("SC7") +"' AND "
	If nOp == 1
		cQuery += " C7_PRODUTO = '"+ oGetDad:aCols[ oGetDad:nAt ][ aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_COD" } ) ] +"' AND "
	EndIf
	cQuery += " D_E_L_E_T_ = ' ' "
	If nOp != 1
		cQuery += "GROUP BY C7_NUM, C7_EMISSAO, C7_COND, C7_CONTATO "
	EndIf
	If nOp == 1
		cQuery += "ORDER BY C7_DATPRF "
    Else
		cQuery += "ORDER BY C7_NUM "
    EndIf

	TCQuery cQuery new Alias ( cAlias:=GetNextAlias() )

	If (cAlias)->( Eof() )
		If nOp == 0
			Aviso( "Atenção", "Não há pedidos com saldo para este fornecedor!", { "Ok" } )
		Else
			Aviso( "Atenção", "Não há pedidos com saldo para este fornecedor e produto!", { "Ok" } )
		EndIf
	Else

		While (cAlias)->( !Eof() )

			(TRB)->(DBAppend()) //RecLock("TRB",.T.)

			If nOp == 0

				(TRB)->PC_OK      := " "
				(TRB)->PC_NUM     := (cAlias)->C7_NUM
				(TRB)->PC_EMISSAO := StoD( (cAlias)->C7_EMISSAO )
				(TRB)->PC_COND    := (cAlias)->C7_COND
				(TRB)->PC_CONTATO := (cAlias)->C7_CONTATO
				(TRB)->PC_TOTAL   := StrZero( (cAlias)->TOTAL, 3 )

			Else

				(TRB)->PC_OK      := " "
				(TRB)->PC_NUM     := (cAlias)->C7_NUM
				(TRB)->PC_ITEM    := (cAlias)->C7_ITEM
				(TRB)->PC_PRODUTO := (cAlias)->C7_PRODUTO
				(TRB)->PC_DESCRI := (cAlias)->C7_DESCRI
				(TRB)->PC_PRECO   := (cAlias)->C7_PRECO
				(TRB)->PC_SALDO   := (cAlias)->SALDO
				(TRB)->PC_DATPRF  := StoD( (cAlias)->C7_DATPRF )

			EndIf
			(TRB)->(DBCommit()) //MsUnlock()

			(cAlias)->( DbSkip() )

		Enddo

		cMarca := GetMark(.F.,TRB,"PC_OK") // Define a marca para o campo

		Define MsDialog oDlgF5 Title Iif( nOp == 1, "Item do ", "" ) +"Pedido de Compra" From C(001),C(001) To C(300),C(600) Pixel

			@ 2.5,002 SAY OemToAnsi("Selecione o pedido que deseja utilizar")
			oBrwF5 := MsSelect():New( (TRB),"PC_OK","",_aBrowse,@lInverte,@cMarca,{042,001,190,380} )
			oBrwF5:bMark := { || Nil }
			Eval( oBrwF5:oBrowse:bGoTop )
			oBrwF5:oBrowse:Refresh()

		Activate MsDialog oDlgF5 On Init ( EnchoiceBar( oDlgF5, bOk, bCancel,, aButtons ) ) Centered Valid _lRetorno

		(TRB)->( DbGotop() )

	EndIf

	If Select(cAlias) > 0
		DbSelectArea(cAlias)
		(cAlias)->(DbCloseArea())
	Endif

	If _nOpca == 1

		dbSelectArea(TRB)
		(TRB)->(dbGoTop())
		Do While (TRB)->( !Eof() )

			If !Empty( (TRB)->PC_OK )//se usuario marcou o registro

				aArea1 := GetArea()

				dbSelectArea("SC7")
				dbSetOrder(1)
				If dbSeek( xFilial("SC7") + (TRB)->PC_NUM + Iif( nOp == 1, (TRB)->PC_ITEM, "" ) )

					If nOp != 1

						While !SC7->( Eof() ) .And. SC7->C7_FILIAL + SC7->C7_NUM == xFilial("SC7") + (TRB)->PC_NUM

								aItpc := VerItPcNf( oGetDad:aCols, oGetDad:aHeader )

								If aItpc[ 1 ] .And. ( SC7->C7_QUANT - SC7->C7_QUJE - SC7->C7_QTDACLA ) > 0 .And. SC7->C7_RESIDUO = ' '

									nItem := aScan( oGetDad:aCols,{|o| AllTrim( o[ nPIte ] ) == aItpc[ 2 ] } )

									If Empty( oGetDad:aCols[ nItem ][ nPPco ] )
										oGetDad:aCols[ nItem ][ nPPco ] := SC7->C7_NUM
										oGetDad:aCols[ nItem ][ nPPit ] := SC7->C7_ITEM
										oGetDad:aCols[ nItem ][ nPTES ] := SC7->C7_TES
									EndIf

								EndIf

								oGetDad:Refresh() // Atualiza o browse dos itens

							SC7->( dbSkip() )
						End
					Else

						If ( SC7->C7_QUANT - SC7->C7_QUJE - SC7->C7_QTDACLA ) > 0 .And. SC7->C7_RESIDUO = ' '

							oGetDad:aCols[ oGetDad:nAt ][ nPPco ] := SC7->C7_NUM
							oGetDad:aCols[ oGetDad:nAt ][ nPPit ] := SC7->C7_ITEM
							oGetDad:aCols[ oGetDad:nAt ][ nPTES ] := SC7->C7_TES

						EndIf

						oGetDad:Refresh() // Atualiza o browse dos itens

					EndIf
				EndIf

				RestArea( aArea1 )

			EndIf

			(TRB)->( DbSkip() )

		EndDo

	Endif

	If Select(TRB) > 0
		DbSelectArea(TRB)
		(TRB)->(DbCloseArea())
		fErase( _cArqEmp + OrdBagExt() )
	Endif

Return

// Verifica a cada item do pedido selecionado, se existe produto correspondente na nota
Static Function VerItPcNf( aProdutos, aCabec )

	Local _lRet := .F.
	Local _cIte := ""
	Local nPIte := aScan( aCabec, { |o| AllTrim( o[2] ) == "ZX2_ITEM" } )
	Local nPPro := aScan( aCabec, { |o| AllTrim( o[2] ) == "ZX2_COD" } )
	Local nX    := 0

	For nX := 1 To Len( aProdutos )
		If AllTrim( aProdutos[ nX, nPPro ] ) == AllTrim( SC7->C7_PRODUTO )
			_lRet := .T.
			_cIte := aProdutos[ nX, nPIte ]
			Exit
		EndIf
	Next

Return { _lRet, _cIte }

//---------------------------------------------------------------------------
// Função que vizualiza o pedido de compras na caixa de seleção de pedidos
//---------------------------------------------------------------------------
Static Function VisPedCom()

	Local aArea := GetArea()

	dbSelectArea("SC7")
	dbSetOrder(1)
	If dbSeek( xFilial("SC7") + (TRB)->PC_NUM )
		Mata120( 1, Nil, Nil, 2, .T. )
	Else
		MsgAlert("Não foi possível encontrar o pedido solicitado para visualização!")
	EndIf

	RestArea( aArea )

	SetKey( VK_F5, { || SelPcFor(0) } )
	SetKey( VK_F6, { || SelPcFor(1) } )

Return

//---------------------------------------------------------------------------
// Função que altera o pedido de compras na caixa de seleção de pedidos
//---------------------------------------------------------------------------
Static Function AltPedCom()

	Local aArea := GetArea()

	dbSelectArea("SC7")
	dbSetOrder(1)
	If dbSeek( xFilial("SC7") + (TRB)->PC_NUM )
		Mata120( 1, Nil, Nil, 4, .T. )
	Else
		MsgAlert("Não foi possível encontrar o pedido solicitado para visualização!")
	EndIf

	RestArea( aArea )

	SetKey( VK_F5, { || SelPcFor(0) } )
	SetKey( VK_F6, { || SelPcFor(1) } )

Return

// Remove um pedido de compras anteriormente associado
Static Function LimparPc( nTipo )

	Local _nV   := 0
	Local nPPco := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_PC" } )
	Local nPPit := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_ITEMPC" } )

	If nTipo == 1
		oGetDad:aCols[ oGetDad:nAt ][ nPPco ] := Space( Len( SC7->C7_NUM ) )
		oGetDad:aCols[ oGetDad:nAt ][ nPPit ] := Space( Len( SC7->C7_ITEM ) )
	Else
		For _nV := 1 To Len( oGetDad:aCols )
			oGetDad:aCols[ _nV ][ nPPco ] := Space( Len( SC7->C7_NUM ) )
			oGetDad:aCols[ _nV ][ nPPit ] := Space( Len( SC7->C7_ITEM ) )
		Next
	EndIf

	oGetDad:Refresh()

Return


// Realiza o reprocessamento das divergências do documento
User Function MRA40REP()

	// Avalia as divergências
	Processa({|| AvalPcIt(ZX1->ZX1_CHVNFE,.T.) },"Aguarde","Avaliando se há divergências...",.T.)

Return


// Exibe as divergências do documento
User Function MRA40DIV()

	Local cQuery  := ""
	Local cAlias  := ""
	Local aItens  := {}

	cQuery := "SELECT * FROM "+ RetSqlName("ZX3")
	cQuery += " WHERE D_E_L_E_T_ = ' ' AND ZX3_FILIAL = '"+ xFilial("ZX3") +"' AND ZX3_CHVNFE = '"+ ZX1->ZX1_CHVNFE +"'"
	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )

	While !(cAlias)->( Eof() )
		aAdd( aItens, { (cAlias)->ZX3_ITEM, (cAlias)->ZX3_PEDIDO, (cAlias)->ZX3_ITEMPC, (cAlias)->ZX3_DESCRI, Iif( (cAlias)->ZX3_STATUS=="1","Pendente","Resolvida" ), StoD( (cAlias)->ZX3_DTINCL ) } )
		(cAlias)->( dbSkip() )
	EndDo

	If Len( aItens ) > 0
		DEFINE MSDIALOG oDlg TITLE "DIVERGENCIAS" From 003,000 To 030,120 OF oMainWnd
			@ 0.3, 0.4 LISTBOX oDiver VAR cVar Fields HEADER "Item NF","Pedido","Item","Descrição","Status","Data Diverg." SIZE 430,192
			oDiver:SetArray(aItens)
			oDiver:bLine := { || {aItens[oDiver:nAT][1],aItens[oDiver:nAT][2],aItens[oDiver:nAT][3],aItens[oDiver:nAT][4],aItens[oDiver:nAT][5],aItens[oDiver:nAT][6]}}
			DEFINE SBUTTON FROM 010,440  TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg
	Else
		MsgAlert("Não existem divergências para esta nota")
	EndIf

Return

// Analisa as divergencias entre a nota e o pedido de compras
Static Function AvalPcIt( cChvNfDiv, lReproc )

	Local aDiverg := {} // -- { PEDIDO, ITEM, COD. DIV, #NF, #PEDIDO, ITEM NF, PRODUTO, PROD.FORN, UM, R$TOTAL }
	Local aPedido := {} // -- { PEDIDO, ITEM, SALDO, QUANT.NF, PREÇO PC, PREÇO NF, ITEM NF, PRODUTO, PROD.FORN, UM, %TOL.QTD, %TOL.PRECO, TOL. ENTREGA, % IPI, % ICMS, TES, RECNO ZX2 }
	Local nPosPC  := 0
	Local nX      := 0
	LOcal lDivCFO := .F.

	Default lReproc := .F.

	dbSelectArea("ZX2")
	dbSetOrder(1)
	dbSeek( xFilial("ZX2") + cChvNfDiv )

	While !ZX2->( Eof() ) .And. ZX2->ZX2_CHVNFE == cChvNfDiv

		If !Empty( ZX2->ZX2_PC ) .And. !Empty( ZX2->ZX2_ITEMPC )

			nPosPC := aScan( aPedido, {|o| o[1] == ZX2->ZX2_PC .And. o[2] == ZX2->ZX2_ITEMPC } )

			If nPosPC == 0
				aAdd( aPedido, { ZX2->ZX2_PC, ZX2->ZX2_ITEMPC, 0, ZX2->ZX2_QUANT, 0, ZX2->ZX2_VUNIT, ZX2->ZX2_ITEM, ZX2->ZX2_COD, AllTrim(ZX2->ZX2_CODFOR), AllTrim(ZX2->ZX2_UM), 0, 0, 0, 0, 0, "", ZX2->( Recno() ) } )
			Else
				aPedido[ nPosPC, 4 ] += ZX2->ZX2_QUANT
			EndIf

		EndIf

		ZX2->( dbSkip() )
	End

	For nX := 1 To Len( aPedido )

		dbSelectArea("SC7")
		dbSetOrder(1)
		If dbSeek( xFilial("SC7") + aPedido[ nX, 1 ] + aPedido[ nX, 2 ] )

			dbSelectArea("AIC")
			dbSetOrder(1)
			If dbSeek( xFilial("AIC") + SC7->C7_FORNECE + SC7->C7_LOJA + SC7->C7_PRODUTO )
				aPedido[ nX, 11 ] := AIC->AIC_PQTDE
				aPedido[ nX, 12 ] := AIC->AIC_PPRECO
				aPedido[ nX, 13 ] := AIC->AIC_TOLENT
			EndIf

			aPedido[ nX, 3 ] := ( SC7->C7_QUANT - SC7->C7_QUJE )
			aPedido[ nX, 5 ] := SC7->C7_PRECO

			aPedido[ nX, 14 ] := SC7->C7_IPI
			aPedido[ nX, 15 ] := SC7->C7_PICM
			aPedido[ nX, 16 ] := SC7->C7_TES

		Else
			aPedido[ nX, 3 ] := 0
			aPedido[ nX, 4 ] := 0
			aPedido[ nX, 5 ] := 0
			aPedido[ nX, 6 ] := 0
		EndIf

	Next

	// Realiza as validações de quantidade e valor, impostos e CFOP
	For nX := 1 To Len( aPedido )

		lDivCFO := .F.

		// AValia a quantidade entre o produto na nota e o pedido
		If aPedido[ nX, 4 ] > aPedido[ nX, 3 ]
			If aPedido[ nX, 11 ] > 0 // Se tem tolerância cadastrada para a quantidade
				If aPedido[ nX, 4 ] > ( aPedido[ nX, 3 ] + ( aPedido[ nX, 3 ] * ( aPedido[ nX, 11 ] / 100 ) ) )
					aAdd( aDiverg, { aPedido[ nX, 1 ], aPedido[ nX, 2 ], "1", aPedido[ nX, 4 ], aPedido[ nX, 3 ], aPedido[ nX, 7 ], aPedido[ nX, 8 ], aPedido[ nX, 9 ], aPedido[ nX, 10 ], ( aPedido[ nX, 5 ] * ( aPedido[ nX, 4 ] - aPedido[ nX, 3 ] ) ) } )
				EndIf
			Else // Se nao tem tolerância já considera como divergência
				aAdd( aDiverg, { aPedido[ nX, 1 ], aPedido[ nX, 2 ], "1", aPedido[ nX, 4 ], aPedido[ nX, 3 ], aPedido[ nX, 7 ], aPedido[ nX, 8 ], aPedido[ nX, 9 ], aPedido[ nX, 10 ], ( aPedido[ nX, 5 ] * ( aPedido[ nX, 4 ] - aPedido[ nX, 3 ] ) ) } )
			EndIf
		Endif

		// Avalia o valor entre o produto na nota e o pedido
		If aPedido[ nX, 6 ] > aPedido[ nX, 5 ]
			If aPedido[ nX, 12 ] > 0 // Se tem tolerância cadastrada para o valor
				If aPedido[ nX, 6 ] > ( aPedido[ nX, 5 ] + ( aPedido[ nX, 5 ] * ( aPedido[ nX, 12 ] / 100 ) ) )
					aAdd( aDiverg, { aPedido[ nX, 1 ], aPedido[ nX, 2 ], "2", aPedido[ nX, 6 ], aPedido[ nX, 5 ], aPedido[ nX, 7 ], aPedido[ nX, 8 ], aPedido[ nX, 9 ], aPedido[ nX, 10 ], ( aPedido[ nX, 4 ] * ( aPedido[ nX, 6 ] - aPedido[ nX, 5 ] ) ) } )
				EndIf
			Else
				aAdd( aDiverg, { aPedido[ nX, 1 ], aPedido[ nX, 2 ], "2", aPedido[ nX, 6 ], aPedido[ nX, 5 ], aPedido[ nX, 7 ], aPedido[ nX, 8 ], aPedido[ nX, 9 ], aPedido[ nX, 10 ], ( aPedido[ nX, 4 ] * ( aPedido[ nX, 6 ] - aPedido[ nX, 5 ] ) ) } )
			EndIf

		Endif

		If !Empty( aPedido[ nX, 16 ] ) // Se a TES foi informada no PEDIDO

			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek( xFilial("SF4") + aPedido[ nX, 16 ] )

			dbSelectArea("ZX2")
			ZX2->( dbGoTo( aPedido[ nX, 17 ] ) )

			// Verifa CFOP
			If SubStr( AllTrim( ZX2->ZX2_CF ), 2, 3 ) != SubStr( AllTrim( SF4->F4_CF ), 2, 3 )
				If lReproc
					// Quando é reprocessamento preciso verificar se existe divergencia de CFOP anterior liberada manualmente
					lDivCFO := VerCfoAnt()
					
					// Caso já houve divergÊncia de CFOP anterior liberada manualmente, não gera nova divergência
					If !lDivCFO
						aAdd( aDiverg, { aPedido[ nX, 1 ], aPedido[ nX, 2 ], "5", aPedido[ nX, 6 ], aPedido[ nX, 5 ], aPedido[ nX, 7 ], aPedido[ nX, 8 ], aPedido[ nX, 9 ], aPedido[ nX, 10 ] } )
					EndIf
				Else
					aAdd( aDiverg, { aPedido[ nX, 1 ], aPedido[ nX, 2 ], "5", aPedido[ nX, 6 ], aPedido[ nX, 5 ], aPedido[ nX, 7 ], aPedido[ nX, 8 ], aPedido[ nX, 9 ], aPedido[ nX, 10 ] } )
				EndIf
			EndIf

			If aPedido[ nX, 14 ] <> ZX2->ZX2_PERIPI
				aAdd( aDiverg, { aPedido[ nX, 1 ], aPedido[ nX, 2 ], "4", aPedido[ nX, 6 ], aPedido[ nX, 5 ], aPedido[ nX, 7 ], aPedido[ nX, 8 ], aPedido[ nX, 9 ], aPedido[ nX, 10 ] } )
			EndIf

			If aPedido[ nX, 15 ] <> ZX2->ZX2_PERICM
				aAdd( aDiverg, { aPedido[ nX, 1 ], aPedido[ nX, 2 ], "4", aPedido[ nX, 6 ], aPedido[ nX, 5 ], aPedido[ nX, 7 ], aPedido[ nX, 8 ], aPedido[ nX, 9 ], aPedido[ nX, 10 ] } )
			EndIf

		EndIf

	Next

	If Len( aDiverg ) > 0

		GravaDiv( aDiverg, lReproc, cChvNfDiv )

		dbSelectArea("ZX1")
		dbSetOrder(1)
		dbSeek( xFilial("ZX1") + cChvNfDiv )
		RecLock("ZX1",.F.)
			ZX1->ZX1_STATUS := "0"
			ZX1->ZX1_BLOQ   := "1"
		MsUnLock()

	Else
		If lReproc
			dbSelectArea("ZX3")
			dbSetOrder(2)
			dbSeek( xFilial("ZX3") + cChvNfDiv )

			// Jean Rehermann - 09/09/2021 - Tratamento para reprocessamento de divergência liberada manualmente (Para não perder justificativa manual)
			While !ZX3->( Eof() ) .And. xFilial("ZX3") + cChvNfDiv == ZX3->ZX3_FILIAL + ZX3->ZX3_CHVNFE
				RecLock("ZX3",.F.)
					ZX3->ZX3_STATUS := "0"
					ZX3->ZX3_DTLIBE := dDataBase
					ZX3->ZX3_USER   := UsrRetName( RetCodUsr() )
					If Empty(ZX3->ZX3_JUSTIF)
						ZX3->ZX3_JUSTIF := "LIBERADO POR REPROCESSAMENTO AUTOMÁTICO"
					Else
						If At( "LIBERADO POR REPROCESSAMENTO AUTOMÁTICO", ZX3->ZX3_JUSTIF ) == 0

							If At( "LIBERADO MANUALMENTE E POR REPROCESSAMENTO AUTOMÁTICO", ZX3->ZX3_JUSTIF ) == 0
								ZX3->ZX3_JUSTIF += " - LIBERADO MANUALMENTE E POR REPROCESSAMENTO AUTOMÁTICO"
							EndIf

						EndIf
					EndIf
				MsUnLock()
				ZX3->( dbSkip() )
			End
		EndIf

		If Len( aPedido ) > 0
			// Gera a pré-nota após liberação das divergências
			xGerPreN(lReproc)

			dbSelectArea("ZX1")
			dbSetOrder(1)
			dbSeek( xFilial("ZX1") + cChvNfDiv )
			RecLock("ZX1",.F.)
				ZX1->ZX1_BLOQ := "0"
			MsUnLock()
		Else
			dbSelectArea("ZX1")
			dbSetOrder(1)
			dbSeek( xFilial("ZX1") + cChvNfDiv )
			RecLock("ZX1",.F.)
				ZX1->ZX1_BLOQ := "2"
			MsUnLock()

		EndIf

	EndIf

Return()


// Grava divergências
Static Function GravaDiv( aDiverg, lReproc, cChvNfDiv )

	Local nX      := 0
	Local cDescri := ""
	Local cCodDiv := 0

	If lReproc

		dbSelectArea("ZX3")
		dbSetOrder(2)
		dbSeek( xFilial("ZX3") + cChvNfDiv )

		While !ZX3->( Eof() ) .And. xFilial("ZX3") + cChvNfDiv == ZX3->ZX3_FILIAL + ZX3->ZX3_CHVNFE
			RecLock("ZX3",.F.)
				ZX3->ZX3_STATUS := "0"
				ZX3->ZX3_DTLIBE := dDataBase
				ZX3->ZX3_USER   := UsrRetName( RetCodUsr() )
				ZX3->ZX3_JUSTIF := "LIBERADO POR REPROCESSAMENTO AUTOMÁTICO"
			MsUnLock()
			ZX3->( dbSkip() )
		End

	EndIf

	For nX := 1 To Len( aDiverg )

		cCodDiv := aDiverg[ nX, 3 ]

		cDescri := "Divergencia item "+ AllTrim( aDiverg[ nX, 6 ] ) +", referente "
		If cCodDiv == "1"
			cDescri += "quantidade"
		ElseIf cCodDiv == "2"
			cDescri += "valor"
		ElseIf cCodDiv == "3"
			cDescri += "condicao"
		ElseIf cCodDiv == "4"
			cDescri += "imposto"
		ElseIf cCodDiv == "5"
			cDescri += "CFOP"
		ElseIf cCodDiv == "6"
			cDescri += "fornecedor"
		ElseIf cCodDiv == "9"
			cDescri += "data de entrega"
		EndIf

		RecLock("ZX3", .T.)
			ZX3_FILIAL := xFilial("ZX3")
			ZX3_CODIGO := cCodDiv
			ZX3_CHVNFE := ZX1->ZX1_CHVNFE
			ZX3_ITEM   := aDiverg[ nX, 6 ]
			ZX3_PEDIDO := aDiverg[ nX, 1 ]
			ZX3_ITEMPC := aDiverg[ nX, 2 ]
			ZX3_STATUS := "1"
			ZX3_DTINCL := dDataBase
			ZX3_DESCRI := cDescri
		MsUnLock()

		RecLock("ZX1",.F.)
			ZX1->ZX1_BLOQ := Iif( cCodDiv == "9", "9", "1")
		MsUnLock()

		cSql := "UPDATE "+ RetSqlName("ZX2")
		cSql += " SET ZX2_BLOQ = '"+ Iif( cCodDiv == "9", "9", "1") +"' "
		cSql += " WHERE ZX2_CHVNFE = '"+ ZX1->ZX1_CHVNFE +"' "
		cSql += "   AND ZX2_ITEM = '"+ aDiverg[ nX, 6 ] +"' "
		cSql += "   AND D_E_L_E_T_ = ' ' "

		TcSqlExec( cSql )

	Next

Return


// Realiza a liberação manual do documento, com a baixa de todas as divergências.
User Function MRA40LIB()

	Local cGetJust := Space(250)
	Local nOpc     := 0

	If ZX1->ZX1_BLOQ <> "1"
		MsgAlert("Documento sem divergências para liberar")
		Return
	EndIf

	oDlgJ   := MSDialog():New( 309,384,401,990,"Justificar Liberação",,,.F.,,,,,,.T.,,,.T. )
	oSayJ   := TSay():New( 004,008,{||"Informar no campo abaixo a justificativa para a liberação emergencial do documento (campo obrigatório)"},oDlgJ,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,244,008)
	oGetJ   := TGet():New( 020,004,{|u| If(Pcount()>0,cGetJust:=u,cGetJust)},oDlgJ,248,012,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGetJust",,,,.F.,.F.)
	oSBtnJ1 := SButton():New( 008,268,1,{|| nOpc := 1, oDlgJ:End() },oDlgJ,,"Realizar a liberação com justificativa" )
	oSBtnJ2 := SButton():New( 024,268,2,{|| nOpc := 2, oDlgJ:End() },oDlgJ,,"Desistir da liberação" )
	oDlgJ:Activate(,,,.T.,{|| !Empty(cGetJust) } )

	If nOpc == 1 .And. !Empty(cGetJust)

		dbSelectArea("ZX3")
		dbSetOrder(2)
		dbSeek( xFilial("ZX3") + ZX1->ZX1_CHVNFE )

		While !ZX3->( Eof() ) .And. xFilial("ZX3") + ZX1->ZX1_CHVNFE == ZX3->ZX3_FILIAL + ZX3->ZX3_CHVNFE

			ZX3->( RecLock("ZX3",.F.) )
				ZX3->ZX3_STATUS := "0"
				ZX3->ZX3_DTLIBE := dDataBase
				ZX3->ZX3_USER   := UsrRetName(RetCodUsr())
				ZX3->ZX3_JUSTIF := cGetJust
			ZX3->( MsUnLock() )

			ZX3->( dbSkip() )
		End

		dbSelectArea("ZX2")
		dbSetOrder(1)
		dbSeek( xFilial("ZX2") + ZX1->ZX1_CHVNFE )

		While !ZX2->( Eof() ) .And. xFilial("ZX2") + ZX1->ZX1_CHVNFE == ZX2->ZX2_FILIAL + ZX2->ZX2_CHVNFE

			ZX2->( RecLock("ZX2",.F.) )
				ZX2->ZX2_BLOQ := "0"
			ZX2->( MsUnLock() )

			ZX2->( dbSkip() )
		End

		ZX1->( RecLock("ZX1",.F.) )
			ZX1->ZX1_BLOQ := "0"
		ZX1->( MsUnLock() )

	EndIf

Return


//-------------------------
// Gera pré-nota de NF-e
//-------------------------
Static Function xGerPreN(lReproc)

	Local cTipDoc := ZX1->ZX1_TPDOC  // Tipo de documento (NF-e ou CT-e)
	Local lNoOk   := .F.
	Local cAlias  := ""
	Local cQuery  := ""
	Local aCabec    := {}
	Local aLinha    := {}
	Local aItens    := {}

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .F.

	If cTipDoc != "NFE"
		Return(.F.)
	EndIf

	SF1->( dbSetOrder(8) )
	If SF1->( dbSeek( xFilial("SF1") + ZX1->ZX1_CHVNFE ) )
		If lReproc
			MsgAlert("Documento já existe na tabela de Documentos Fiscais (SF1)")
		EndIf
		Return(.F.)
	EndIf

	// Verifica se o código de produto foi informado (a tes não é necessária para a pré-nota
	cQuery := "SELECT COUNT(*) AS TOT FROM " + RetSqlName("ZX2")
	cQuery += " WHERE ZX2_COD  = ' '"
	cQuery += " AND ZX2_CHVNFE = '"+ ZX1->ZX1_CHVNFE +"' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )
	lNoOk := (cAlias)->TOT > 0
	(cAlias)->( DbCloseArea() )

	If lNoOk // Tem itens a serem revisados, ajusta o status
		ZX1->( RecLock("ZX1",.F.) )
			ZX1->ZX1_STATUS := "3"
		ZX1->( MsUnLock() )
		Return(.F.)
	EndIf

	cQuery := "SELECT * FROM "+ RetSqlName("ZX2")
	cQuery += " WHERE ZX2_CHVNFE = '"+ ZX1->ZX1_CHVNFE +"' "
	cQuery += " AND D_E_L_E_T_ = ' ' "

	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )

	While !(cAlias)->( Eof() )

		aLinha := {}

		aAdd( aLinha, { "D1_ITEM"   , Strzero( Len( aItens ) + 1, TamSX3("D1_ITEM")[1] ), Nil, Nil } )
		aAdd( aLinha, { "D1_COD"    , (cAlias)->ZX2_COD   , Nil, Nil } )
		aAdd( aLinha, { "D1_QUANT"  , (cAlias)->ZX2_QUANT , Nil, Nil } )
		aAdd( aLinha, { "D1_VUNIT"  , (cAlias)->ZX2_VUNIT , Nil, Nil } )
		aAdd( aLinha, { "D1_TOTAL"  , (cAlias)->ZX2_TOTAL , Nil, Nil } )

		If !Empty( (cAlias)->ZX2_PERICM )
			aAdd( aLinha, { "D1_VALICM" , (cAlias)->ZX2_VALICM, Nil, Nil } )
			aAdd( aLinha, { "D1_PICM"   , (cAlias)->ZX2_PERICM, Nil, Nil } )
			aAdd( aLinha, { "D1_BASEICM", (cAlias)->ZX2_BASICM, Nil, Nil } )
		EndIf

		If !Empty( (cAlias)->ZX2_VICMST )
			aAdd( aLinha, { "D1_ICMSRET", (cAlias)->ZX2_VICMST, Nil, Nil } )
		EndIf

		If !Empty( (cAlias)->ZX2_PERIPI )
			aAdd( aLinha, { "D1_VALIPI" , (cAlias)->ZX2_VALIPI, Nil, Nil } )
			aAdd( aLinha, { "D1_IPI"    , (cAlias)->ZX2_PERIPI, Nil, Nil } )
			aAdd( aLinha, { "D1_BASEIPI", (cAlias)->ZX2_BASIPI, Nil, Nil } )
		EndIf

		If !Empty( (cAlias)->ZX2_PC )
			aAdd( aLinha, { "D1_PEDIDO", (cAlias)->ZX2_PC    , Nil, Nil } )
			aAdd( aLinha, { "D1_ITEMPC", (cAlias)->ZX2_ITEMPC, Nil, Nil } )
		EndIf

		If !Empty( (cAlias)->ZX2_LOTECT )
			aAdd( aLinha, { "D1_LOTECTL", (cAlias)->ZX2_LOTECT, Nil, Nil } )
			aAdd( aLinha, { "D1_LOTEFOR", (cAlias)->ZX2_LOTECT, Nil, Nil } )
			aAdd( aLinha, { "D1_DTVALID", StoD( (cAlias)->ZX2_DTVLOT ), Nil, Nil } )
			aAdd( aLinha, { "D1_DFABRIC", Iif( Empty( (cAlias)->ZX2_DTFLOT ), dDataBase, StoD( (cAlias)->ZX2_DTFLOT ) ), Nil, Nil } )
		EndIf

		aAdd( aItens, aLinha )

		(cAlias)->( dbSkip() )
	End
	(cAlias)->( dbCloseArea() )

	aAdd( aCabec, { "F1_TIPO"   , ZX1->ZX1_TIPO  , Nil, Nil } )
	aAdd( aCabec, { "F1_FORMUL" , "N"            , Nil, Nil } )
	aAdd( aCabec, { "F1_DOC"    , ZX1->ZX1_DOC   , Nil, Nil } )
	aAdd( aCabec, { "F1_CHVNFE" , ZX1->ZX1_CHVNFE, Nil, Nil } )
	aAdd( aCabec, { "F1_SERIE"  , ZX1->ZX1_SERIE , Nil, Nil } )
	aAdd( aCabec, { "F1_EMISSAO", ZX1->ZX1_EMISSA, Nil, Nil } )
	aAdd( aCabec, { "F1_FORNECE", ZX1->ZX1_CLIFOR, Nil, Nil } )
	aAdd( aCabec, { "F1_LOJA"   , ZX1->ZX1_LOJA  , Nil, Nil } )
	aAdd( aCabec, { "F1_ESPECIE", ZX1->ZX1_ESPECI, Nil, Nil } )

	Begin Transaction

		MSExecAuto( { | v,w,x,y,z | MATA140( v,w,x,y,z ) }, aCabec, aItens, 3, .F., 0 )

		If lMsErroAuto
			DisarmTran()
		Else
			SF1->( dbSetOrder(1) )
			If SF1->( dbSeek( xFilial("SF1") + ZX1->ZX1_DOC + ZX1->ZX1_SERIE + ZX1->ZX1_CLIFOR + ZX1->ZX1_LOJA ) )
				ZX1->( RecLock("ZX1",.F.) )
					ZX1->ZX1_STATUS := "1" // Pré-Nota incluída
				ZX1->( MsUnLock() )
				SF1->( RecLock("SF1",.F.) )
					SF1->F1_CHVNFE := ZX1->ZX1_CHVNFE
				SF1->( MsUnLock() )
			EndIf
		EndIf

	End Transaction

Return

// Na tela de seleção de pedido de compras, permite criar itens baseado em item existente para
// amarrar mais pedidos e selecionar a quantidade em cada item
Static Function DUPLITEM()

	Local oDlgSpl,oSay1,oSay2,oSay3,oSay4,oGet1,oGet2,oSBtn1,oSBtn2
	Local cProduto := ""
	Local nQtdOri  := 0
	Local nQtdNew  := 0
	Local nQtdAtu  := 0
	Local nY       := 0
	Local nItemAtu := oGetDad:nAt
	Local lOk      := .F.
	Local aNewLin  := {}
	Local nPProd   := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_COD"    } )
	Local nPQtdd   := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_QUANT"  } )
	Local nPItem   := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_ITEM"   } )
	Local nPVUni   := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_VUNIT"  } )
	Local nPVTot   := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_TOTAL"  } )
	Local nPVIcm   := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_VALICM" } )
	Local nPVIpi   := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_VALIPI" } )
	Local nPBIcm   := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_BASICM" } )
	Local nPBIpi   := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_BASIPI" } )
	Local nPVIcS   := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_VICMST" } )
	Local nPBIcS   := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_BICMST" } )

	If nPProd > 0 .And. nPQtdd > 0
		cProduto := oGetDad:aCols[ nItemAtu ][ nPProd ]
		nQtdOri  := oGetDad:aCols[ nItemAtu ][ nPQtdd ]
	EndIf

	If !Empty( cProduto )
		cProduto := AllTrim( cProduto ) +" - "+ AllTrim( Posicione("SB1",1,xFilial("SB1")+cProduto,"SB1->B1_DESC") )
	EndIf

	oDlgSpl:= MSDialog():New( 191,301,310,727,"Duplicar Item",,,.F.,,,,,,.T.,,,.T. )
	oSay1  := TSay():New( 004,004,{||"Produto"},oDlgSpl,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
	oSay2  := TSay():New( 004,032,{|| cProduto },oDlgSpl,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,168,008)
	oSay3  := TSay():New( 020,004,{||"Quantidade Original"},oDlgSpl,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,056,008)
	oSay4  := TSay():New( 037,004,{||"Quantidade Novo Item"},oDlgSpl,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,056,008)
	oGet2  := TGet():New( 036,068,{|u| If(Pcount()>0, nQtdNew:=u, nQtdNew)},oDlgSpl,052,008,'@E 999,999,999.99',{|| VldNewQtd(nQtdOri,nQtdNew)},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nQtdNew")
	oSBtn1 := SButton():New( 036,176,1,{|| lOk := .T., oDlgSpl:End() },oDlgSpl,,"", )
	oGet1  := TGet():New( 020,068,{|| nQtdOri },oDlgSpl,052,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nQtdOri")
	oSBtn2 := SButton():New( 036,144,2,{|| lOk := .F., oDlgSpl:End() },oDlgSpl,,"", )
	oDlgSpl:Activate(,,,.T.)

	If lOk

		aAdd( aNewLin, Array( Len( oGetDad:aHeader ) + 1 ) )

		For nY := 1 to Len( aNewLin[ 1 ] )
			aNewLin[ 1, nY ] := oGetDad:aCols[ nItemAtu, nY ]
		Next nY

		// Aqui atualizar o item, as quantidades, valores e gravar nos registros da ZX2 e atualizar o recno do novo registro
		
		nQtdAtu := nQtdOri - nQtdNew // Quantidade do item alterada

		oGetDad:aCols[ nItemAtu, nPQtdd ] := nQtdAtu // Atualizar quantidade do item que foi alterado
		oGetDad:aCols[ nItemAtu, nPVTot ] := nQtdAtu * oGetDad:aCols[ nItemAtu ][ nPVUni ] // Valor total 
		oGetDad:aCols[ nItemAtu ][ nPBIcm ] := Iif( oGetDad:aCols[ nItemAtu, nPBIcm ] > 0, Round( ( oGetDad:aCols[ nItemAtu ][ nPBIcm ] / nQtdOri ) * nQtdAtu, 2 ), 0 )
		oGetDad:aCols[ nItemAtu ][ nPBIpi ] := Iif( oGetDad:aCols[ nItemAtu, nPBIpi ] > 0, Round( ( oGetDad:aCols[ nItemAtu ][ nPBIpi ] / nQtdOri ) * nQtdAtu, 2 ), 0 )
		oGetDad:aCols[ nItemAtu ][ nPVIcm ] := Iif( oGetDad:aCols[ nItemAtu, nPVIcm ] > 0, Round( ( oGetDad:aCols[ nItemAtu ][ nPVIcm ] / nQtdOri ) * nQtdAtu, 2 ), 0 )
		oGetDad:aCols[ nItemAtu ][ nPVIpi ] := Iif( oGetDad:aCols[ nItemAtu, nPVIpi ] > 0, Round( ( oGetDad:aCols[ nItemAtu ][ nPVIpi ] / nQtdOri ) * nQtdAtu, 2 ), 0 )
		oGetDad:aCols[ nItemAtu ][ nPVIcS ] := Iif( oGetDad:aCols[ nItemAtu, nPVIcS ] > 0, Round( ( oGetDad:aCols[ nItemAtu ][ nPVIcS ] / nQtdOri ) * nQtdAtu, 2 ), 0 )
		oGetDad:aCols[ nItemAtu ][ nPBIcS ] := Iif( oGetDad:aCols[ nItemAtu, nPBIcS ] > 0, Round( ( oGetDad:aCols[ nItemAtu ][ nPBIcS ] / nQtdOri ) * nQtdAtu, 2 ), 0 )

		// Atualiza o registro no ZX2 atual, diminuindo a quantidade que foi colocada em outro item e atualizando os valores
		ZX2->( dbSetOrder(3) )
		If ZX2->( dbSeek( xFilial("ZX2") + ZX1->ZX1_CHVNFE + oGetDad:aCols[ nItemAtu, nPProd ] + oGetDad:aCols[ nItemAtu, nPItem ] ) )
			ZX2->( RecLock( "ZX2", .F. ) )

			For nY := 1 to Len( oGetDad:aHeader )
				If !IsHeadRec( oGetDad:aHeader[ nY ][ 2 ] ) .And. !IsHeadAlias( oGetDad:aHeader[ nY ][ 2 ] ) .And. oGetDad:aHeader[ nY ][ 10 ] <> "V"
					ZX2->&(oGetDad:aHeader[ nY ][ 2 ]) := oGetDad:aCols[ nItemAtu ][ aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == AllTrim(oGetDad:aHeader[ nY ][ 2 ]) } ) ]
				EndIf
			Next nY

			ZX2->( MsUnLock() )
		EndIf

		aNewLin[ 1, nPItem ] := Soma1( oGetDad:aCols[ Len( oGetDad:aCols ), nPItem ] ) // Item
		aNewLin[ 1, nPQtdd ] := nQtdNew // Quantidade do novo item
		aNewLin[ 1, nPVTot ] := nQtdNew * oGetDad:aCols[ nItemAtu ][ nPVUni ] // Valor total 
		aNewLin[ 1, nPBIcm ] := Iif( aNewLin[ 1, nPBIcm ] > 0, Round( ( oGetDad:aCols[ nItemAtu ][ nPBIcm ] / nQtdOri ) * nQtdNew, 2 ), 0 )
		aNewLin[ 1, nPBIpi ] := Iif( aNewLin[ 1, nPBIpi ] > 0, Round( ( oGetDad:aCols[ nItemAtu ][ nPBIpi ] / nQtdOri ) * nQtdNew, 2 ), 0 )
		aNewLin[ 1, nPVIcm ] := Iif( aNewLin[ 1, nPVIcm ] > 0, Round( ( oGetDad:aCols[ nItemAtu ][ nPVIcm ] / nQtdOri ) * nQtdNew, 2 ), 0 )
		aNewLin[ 1, nPVIpi ] := Iif( aNewLin[ 1, nPVIpi ] > 0, Round( ( oGetDad:aCols[ nItemAtu ][ nPVIpi ] / nQtdOri ) * nQtdNew, 2 ), 0 )
		aNewLin[ 1, nPVIcS ] := Iif( aNewLin[ 1, nPVIcS ] > 0, Round( ( oGetDad:aCols[ nItemAtu ][ nPVIcS ] / nQtdOri ) * nQtdNew, 2 ), 0 )
		aNewLin[ 1, nPBIcS ] := Iif( aNewLin[ 1, nPBIcS ] > 0, Round( ( oGetDad:aCols[ nItemAtu ][ nPBIcS ] / nQtdOri ) * nQtdNew, 2 ), 0 )

		// Inclui um novo registro na ZX2 com a quantidade que foi retirada do item original
		ZX2->( RecLock( "ZX2", .T. ) )

		ZX2->ZX2_FILIAL := xFilial("ZX2")
		ZX2->ZX2_CHVNFE := ZX1->ZX1_CHVNFE

		For nY := 1 to Len( oGetDad:aHeader )

			If IsHeadRec( oGetDad:aHeader[ nY ][ 2 ] )
				aNewLin[ 1 ][ nY ] := ZX2->( Recno() )
			ElseIf IsHeadAlias( oGetDad:aHeader[ nY ][ 2 ] )
				ZX2->&( oGetDad:aHeader[ nY ][ 2 ] ) := "ZX2"
				//aNewLin[ 1 ][ nY ] := "ZX2"
			ElseIf ( oGetDad:aHeader[ nY ][ 10 ] <> "V" )
				ZX2->&( oGetDad:aHeader[ nY ][ 2 ] ) := aNewLin[ 1, nY ]
			Else
				ZX2->&( oGetDad:aHeader[ nY ][ 2 ] ) := CriaVar( oGetDad:aHeader[ nY, 2 ] )
			EndIf
			
		Next nY

		ZX2->( MsUnLock() )

		// Atualiza o browse dos itens
		aColsTmp := oGetDad:aCols
		aAdd( aColsTmp, aNewLin[ 1 ] )
		oGetDad:nMax  := Len( aColsTmp )
		oGetDad:aCols := aColsTmp
		oGetDad:nAt := nItemAtu
		oGetDad:Refresh()

	EndIf

Return

// Valida a quantidade a ser dividida do item original para amarrar mais de um pedido de compras
Static Function VldNewQtd( nOri, nNew )

	Local _lRet := .T.

	If nNew >= nOri
		MsgAlert("Nova quantidade precisa ser menor que a quantidade do item original")
		_lRet := .F.
	EndIf

	If nNew <= 0
		MsgAlert("Nova quantidade precisa ser positiva")
		_lRet := .F.
	EndIf

Return( _lRet )

// Verifica se existe divergência de CFOP anterior liberada manualmente
Static Function VerCfoAnt()

	Local lRet   := .F.
	Local cQuery := ""
	Local cAlias := ""
	Local nCont  := 0
	Local aArea  := GetArea()
	
	cQuery := "SELECT COUNT(*) TOTAL "
	cQuery += "FROM "+ RetSqlName("ZX3") +" ZX3 "
	cQuery += "WHERE D_E_L_E_T_ = ' ' "
	cQuery += "AND ZX3_CHVNFE = '"+ ZX2->ZX2_CHVNFE +"' "
	cQuery += "AND ZX3_ITEM = '"+ ZX2->ZX2_ITEM +"' "
	cQuery += "AND ZX3_CODIGO = '5' "
	cQuery += "AND ZX3_STATUS = '0' "
	cQuery += "AND ZX3_JUSTIF <> ' ' "

	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )
	nCont := (cAlias)->TOTAL
	(cAlias)->( dbCloseArea() )

	lRet := nCont > 0

	RestArea( aArea )

Return( lRet )
