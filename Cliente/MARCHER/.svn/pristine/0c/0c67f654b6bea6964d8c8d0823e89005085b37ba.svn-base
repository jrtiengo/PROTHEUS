#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

User Function FORNSC1()

	Local oDlg
	Local nLin     := 0
	Local nOption  := 0
	Local cQuery   := ""
	Local cAlias   := ""
	Local cFornece := ""
	Local cLojaFor := ""
	Local cNomeFor := ""
	Local aHead1   := {}
	Local aObjects := {}
	Local aCols1   := {}
	Local aAlter   := {"C1_FORNECE"}
	Local aSize    := MsAdvSize()
	Local oGreen   := LoadBitmap( GetResources(), "BR_VERDE"  )
	Local oYellow  := LoadBitmap( GetResources(), "BR_AMARELO")

	Private oBrw

	cQuery := "SELECT C1_FILIAL, C1_NUM, C1_ITEM, C1_PRODUTO, C1_DESCRI, C1_QUANT, C1_SOLICIT, "
	cQuery += "	   ISNULL( (SELECT TOP 1 AIB_CODFOR + AIB_LOJFOR "
	cQuery += "					FROM  "+ RetSqlName("AIB") +" AIB, "+ RetSqlName("AIA") +" AIA "
	cQuery += "					WHERE AIA.D_E_L_E_T_ = ' ' "
	cQuery += "					  AND AIB.D_E_L_E_T_ = ' ' "
	cQuery += "					  AND AIA_FILIAL = AIB_FILIAL "
	cQuery += "					  AND AIA_CODFOR = AIB_CODFOR "
	cQuery += "					  AND AIA_CODTAB = AIB_CODTAB "
	cQuery += "					  AND AIB_FILIAL = '"+ xFilial("AIB") +"' "
	cQuery += "					  AND '"+ DtoS( dDataBase ) +"' > AIB_DATVIG "
	cQuery += "					  AND '"+ DtoS( dDataBase ) +"' BETWEEN AIA_DATDE AND AIA_DATATE "
	cQuery += "					  AND AIB_CODPRO = SC1.C1_PRODUTO), ' ') FORLOJ "
	cQuery += "	FROM "+ RetSqlName("SC1") +" SC1 "
	cQuery += "	WHERE SC1.D_E_L_E_T_ = ' ' "
	cQuery += "	  AND C1_EMISSAO >= '20200101' "
	cQuery += "	  AND C1_QUJE < C1_QUANT "
	cQuery += "	  AND C1_PEDIDO = ' ' "
	cQuery += "	  AND C1_ITEMPED = ' ' "
	cQuery += "	  AND C1_FORNECE = ' ' "
	cQuery += "	  AND C1_LOJA = ' ' "
	cQuery += "	ORDER BY FORLOJ DESC"

	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )

	If !(cAlias)->( Eof() )

		AAdd( aObjects, { 100, 100, .t., .t. } )
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects )
		aHead1 := MontHead()

		While !(cAlias)->( Eof() )

			aAdd( aCols1, Array(12) )
			nLin := Len( aCols1 )

			If !Empty( (cAlias)->FORLOJ )
				cFornece := Left( (cAlias)->FORLOJ, 6 )
				cLojaFor := Right( (cAlias)->FORLOJ, 2 )
				cNomeFor := Posicione("SA2",1,xFilial("SA2") + cFornece + cLojaFor,"SA2->A2_NOME")
				aCols1[nLin][01] := oGreen
				aCols1[nLin][11] := .T.
			Else
				cFornece := Space(6)
				cLojaFor := Space(2)
				cNomeFor := Space(40)
				aCols1[nLin][01] := oYellow
				aCols1[nLin][11] := .F.
			EndIf

			aCols1[nLin][02] := (cAlias)->C1_NUM
			aCols1[nLin][03] := (cAlias)->C1_ITEM
			aCols1[nLin][04] := (cAlias)->C1_PRODUTO
			aCols1[nLin][05] := (cAlias)->C1_DESCRI
			aCols1[nLin][06] := (cAlias)->C1_QUANT
			aCols1[nLin][07] := (cAlias)->C1_SOLICIT
			aCols1[nLin][08] := cFornece
			aCols1[nLin][09] := cLojaFor
			aCols1[nLin][10] := cNomeFor

			aCols1[nLin][12] := .F.

			(cAlias)->( dbSkip() )

		End

		(cAlias)->( DbCloseArea() )

		DEFINE MSDIALOG oDlg TITLE "Selecionar Fornecedor da Tabela de Preços" From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
			oBrw := MsNewGetDados():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4],3,'AllwaysTrue()','AllwaysTrue()','',aAlter,0,Len(aCols1),'AllwaysTrue()','','',oDlg,aHead1,aCols1 )
			oDlg:lMaximized := .T.
		ACTIVATE MSDIALOG oDlg On INIT CriaBut( oDlg, {||nOption:=1,oDlg:End()}, {||nOption:=0,oDlg:End() } )

		If nOption == 1

			For nLin := 1 To Len(oBrw:aCols)

				XActSC1( nLin, oBrw:aCols[nLin] )

			Next

		EndIf

	Else
		MsgAlert("Não foram econtradas solicitações de compras sem fornecedor!")
	EndIf

Return

//---------------------------------------
// Cria a estrutura de dados
//---------------------------------------
Static Function MontHead()

	Local aHead := {}

	/*------------------------------------------*\
	| Estrutura do array com o cabeçalho da Grid |
	|--------------------------------------------|
	|   aHead[01] - X3_TITULO  | Título          |
	|   aHead[02] - X3_CAMPO   | Campo           |
	|   aHead[03] - X3_PICTURE | Picture         |
	|   aHead[04] - X3_TAMANHO | Tamanho         |
	|   aHead[05] - X3_DECIMAL | Decimal         |
	|   aHead[06] - X3_VALID   | Validação       |
	|   aHead[07] - X3_USADO   | Usado           |
	|   aHead[08] - X3_TIPO    | Tipo            |
	|   aHead[09] - X3_F3      | F3              |
	|   aHead[10] - X3_CONTEXT | Contexto (R,V)  |
	|   aHead[11] - X3_CBOX    | Combobox        |
	|   aHead[12] - X3_RELACAO | Inicial. Padrao |
	|   aHead[13] - X3_WHEN    | Habilita edicao |
	|   aHead[14] - X3_VISUAL  | Alteravel (A,V) |
	|   aHead[15] - X3_VLDUSER | Valid de User   |
	|   aHead[16] - X3_PICTVAR | Picture         |
	|   aHead[17] - X3_OBRIGAT | Obrigatorio     |
	\*------------------------------------------*/

	aAdd( aHead, {""               ,"COR"       ,"@BMP"                ,02,0,"",,"C"})
	aAdd( aHead, {"Numero"         ,"C1_NUM"    ,"@!"                  ,06,0,"",,"C"})
	aAdd( aHead, {"Item"           ,"C1_ITEM"   ,"@!"                  ,04,0,"",,"C"})
	aAdd( aHead, {"Produto"        ,"C1_PRODUTO","@!"                  ,30,0,"",,"C"})
	aAdd( aHead, {"Descrição"      ,"C1_DESCRI" ,"@!"                  ,80,0,"",,"C"})
	aAdd( aHead, {"Quantidade"     ,"C1_QUANT"  ,"@E 999,999,999.99"   ,12,2,"",,"N"})
	aAdd( aHead, {"Solicitante"    ,"C1_SOLICIT","@!"                  ,25,0,"",,"C"})
	aAdd( aHead, {"Fornecedor"     ,"C1_FORNECE","@!"                  ,06,0,"U_xForPop()",,"C","SA2"})
	aAdd( aHead, {"Loja"           ,"C1_LOJA"   ,"@!"                  ,02,0,"",,"C"})
	aAdd( aHead, {"Nome"           ,"C1_NOMEFOR","@!"                  ,40,0,"",,"C"})

	//aAdd( aHead, {"Cód.Rejeição"   ,"CR_CODREJ" ,"@!"                  ,06,0,"",,"C","SZ",,,,'oBrw:aCols[oBrw:nAt,3]=="2"',"",'U_VldRejLib()'})

Return( aHead )

//---------------------------------------
// Cria opções no menu Ações Relacionadas
//---------------------------------------
Static Function CriaBut( oDlg, bOk, bCancel )

	Local aButtons := {}
	Local bOk1     := bOk
	Local bCancel1 := bCancel

	aAdd( aButtons, { "S4WB004N", { || BrwLegSC1() }, "&Legenda" , "Legenda"  } )
	aAdd( aButtons, { "S4WB004N", { || ImpList()   }, "&Imprimir", "Imprimir" } )

Return( EnchoiceBar( oDlg, bOk1, bCancel1,, aButtons ) )

//---------------------------------------
// Legenda dos registros
//---------------------------------------
Static Function BrwLegSC1()

	Local aLegenda := {}

	// Definição da legenda
	aAdd( aLegenda, { "BR_VERDE"  , "Encontrado na tabela de preços" } )
	aAdd( aLegenda, { "BR_AMARELO", "Não encontrado na tabela de preços" } )

	BrwLegenda("Legenda","Situação",aLegenda)

Return

//---------------------------------------
// Valida a alteração do fornecedor
//---------------------------------------
User Function xForPop()

	Local lRet  := .F.
	Local nAtua := 11 // Posição no array do flag de alteração
	Local aArea := GetArea()
	Local nLoja := Max( aScan( oBrw:aHeader, {|o| AllTrim( o[2] ) == "C1_LOJA"  } ), 0 )
	Local nNome := Max( aScan( oBrw:aHeader, {|o| AllTrim( o[2] ) == "C1_NOMEFOR" } ), 0 )

	If Empty( M->C1_FORNECE )

		If nLoja > 0 .And. nNome > 0

			oBrw:aCols[ oBrw:nAt, nLoja ] := Space(2)
			oBrw:aCols[ oBrw:nAt, nNome ] := Space(40)
			oBrw:aCols[ oBrw:nAt, nAtua ] := .F.
			oBrw:Refresh()
			lRet := .T.

		EndIf

	Else

		If nLoja > 0 .And. nNome > 0 .And. ExistCpo("SA2", M->C1_FORNECE)

			If SA2->A2_COD != M->C1_FORNECE
				dbSelectArea("SA2")
				dbSetOrder(1)
				dbSeek( xFilial("SA2") + M->C1_FORNECE )
			EndIf

			oBrw:aCols[ oBrw:nAt, nLoja ] := SA2->A2_LOJA
			oBrw:aCols[ oBrw:nAt, nNome ] := SA2->A2_NOME
			oBrw:aCols[ oBrw:nAt, nAtua ] := .T.
			oBrw:Refresh()
			lRet := .T.

		EndIf

	EndIf

	RestArea( aArea )

Return( lRet )

//---------------------------------------
// Grava a alteração na SC1
//---------------------------------------
Static Function XActSC1( nLin, aLinha )

	Local nAtualiza := 11 // Posição no array do flag de alteração
	Local nNumSC    := Max( aScan( oBrw:aHeader, {|o| AllTrim( o[2] ) == "C1_NUM"      } ), 0 )
	Local nItemSC   := Max( aScan( oBrw:aHeader, {|o| AllTrim( o[2] ) == "C1_ITEM"     } ), 0 )
	Local nCodFor   := Max( aScan( oBrw:aHeader, {|o| AllTrim( o[2] ) == "C1_FORNECE"  } ), 0 )
	Local nLojFor   := Max( aScan( oBrw:aHeader, {|o| AllTrim( o[2] ) == "C1_LOJA"     } ), 0 )

	If aLinha[ nAtualiza ] .And. nNumSC > 0 .And. nItemSC > 0 .And. nCodFor > 0 .And. nLojFor > 0 .And. !Empty( aLinha[ nCodFor ] ) .And. !Empty( aLinha[ nLojFor ] )

		dbSelectArea("SC1")
		dbSetOrder(1)
		dbSeek( xFilial("SC1") + aLinha[ nNumSC ] + aLinha[ nItemSC ] )

		If Found()

			SC1->( RecLock("SC1",.F.) )
				SC1->C1_FORNECE := aLinha[ nCodFor ]
				SC1->C1_LOJA    := aLinha[ nLojFor ]
			SC1->( MsUnLock() )

		EndIf

	EndIf

Return

//---------------------------------------
// Imprime a lista de SCs sem fornecedor
//---------------------------------------
Static Function ImpList()

	Local nRecs   := 0
	Local nCodFor := Max( aScan( oBrw:aHeader, {|o| AllTrim( o[2] ) == "C1_FORNECE"  } ), 0 )

	Private aOrd        := {}
	Private titulo      := "SCs sem fornecedor"
	Private cDesc1      := "Este programa tem como objetivo imprimir relatorio     "
	Private cDesc2      := "com a lista de solicitações sem o código do fornecedor."
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private limite      := 132
	Private m_pag       := 01
	Private cbTxt       := Space(10)
	Private tamanho     := "G"
	Private nomeprog    := "FORNSC1"
	Private nTipo       := 18
	Private nLin        := 80
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}

	aEval( oBrw:aCols, {|o| nRecs += Iif( Empty( o[nCodFor] ), 1, 0 ) } )

	If nRecs == 0
		MsgAlert("Não há registros no browse sem código de fornecedor!")
		Return()
	EndIf

	wnrel := SetPrint("",nomeprog,"",@titulo,cDesc1,cDesc2,"",.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault( aReturn, "" )

	If nLastKey == 27
		Return
	Endif

	nTipo := Iif( aReturn[4] == 1, 15, 18 )

	Processa( {|| RunReport( nRecs ) } )

Return

Static Function RunReport( nRecs )

	Local nX      := 0
	Local cabec1  := " "
	Local nNumSol := Max( aScan( oBrw:aHeader, {|o| AllTrim( o[2] ) == "C1_NUM"     } ), 0 )
	Local nItemSC := Max( aScan( oBrw:aHeader, {|o| AllTrim( o[2] ) == "C1_ITEM"    } ), 0 )
	Local nProdut := Max( aScan( oBrw:aHeader, {|o| AllTrim( o[2] ) == "C1_PRODUTO" } ), 0 )
	Local nDescri := Max( aScan( oBrw:aHeader, {|o| AllTrim( o[2] ) == "C1_DESCRI"  } ), 0 )
	Local nQuanti := Max( aScan( oBrw:aHeader, {|o| AllTrim( o[2] ) == "C1_QUANT"   } ), 0 )
	Local nSolici := Max( aScan( oBrw:aHeader, {|o| AllTrim( o[2] ) == "C1_SOLICIT" } ), 0 )
	Local nCodFor := Max( aScan( oBrw:aHeader, {|o| AllTrim( o[2] ) == "C1_FORNECE" } ), 0 )

	ProcRegua( nRecs )

	cabec1 += PadR( oBrw:aHeader[ nNumSol, 1 ], oBrw:aHeader[ nNumSol, 4 ] ) + Space(2)
	cabec1 += PadR( oBrw:aHeader[ nItemSC, 1 ], oBrw:aHeader[ nItemSC, 4 ] ) + Space(2)
	cabec1 += PadR( oBrw:aHeader[ nProdut, 1 ], oBrw:aHeader[ nProdut, 4 ] ) + Space(2)
	cabec1 += PadR( oBrw:aHeader[ nDescri, 1 ], oBrw:aHeader[ nDescri, 4 ] ) + Space(4)
	cabec1 += PadL( oBrw:aHeader[ nQuanti, 1 ], oBrw:aHeader[ nQuanti, 4 ] ) + Space(2)
	cabec1 += PadR( oBrw:aHeader[ nSolici, 1 ], oBrw:aHeader[ nSolici, 4 ] )

	For nX := 1 To Len( oBrw:aCols )

		If Empty( oBrw:aCols[ nX, nCodFor ] )

			If lAbortPrint
				@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				Exit
			Endif

			If nLin > 65
				nLin := Cabec( Titulo, Cabec1, "", NomeProg, Tamanho, nTipo ) + 1
			Endif

			@ nLin,      001 PSAY oBrw:aCols[ nX, nNumSol ] Picture oBrw:aHeader[ nNumSol, 3 ]
			@ nLin, PCol()+2 PSAY oBrw:aCols[ nX, nItemSC ] Picture oBrw:aHeader[ nItemSC, 3 ]
			@ nLin, PCol()+2 PSAY oBrw:aCols[ nX, nProdut ] Picture oBrw:aHeader[ nProdut, 3 ]
			@ nLin, PCol()+2 PSAY oBrw:aCols[ nX, nDescri ] Picture oBrw:aHeader[ nDescri, 3 ]
			@ nLin, PCol()+2 PSAY oBrw:aCols[ nX, nQuanti ] Picture oBrw:aHeader[ nQuanti, 3 ]
			@ nLin, PCol()+2 PSAY oBrw:aCols[ nX, nSolici ] Picture oBrw:aHeader[ nSolici, 3 ]

			nLin := nLin + 1

		EndIf

	Next

	If aReturn[5] == 1
		dbCommitAll()
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return
