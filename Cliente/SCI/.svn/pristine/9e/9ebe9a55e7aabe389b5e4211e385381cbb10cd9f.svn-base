#Include 'Totvs.ch'
#Include 'FWMVCDef.ch'

/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    | SCIA216 | Autor | Joao Mattos            | Data |12/03/2020|||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao | Entrega de Pedido de Compra                                |||
|||           |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | U_SCIA216()                                                |||
|||-----------+------------------------------------------------------------|||
||| Parametros| Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
|||  Uso      | Especifico Cliente Sport Clube Internacional               |||
|||-----------+------------------------------------------------------------|||
|||                           ULTIMAS ALTERACOES                           |||
|||-------------+--------+-------------------------------------------------|||
||| Programador | Data   | Motivo da Alteracao                             |||
|||-------------+--------+-------------------------------------------------|||
|||             |        |                                                 |||
|||-------------+--------+-------------------------------------------------|||
|============================================================================|
|============================================================================|*/
User Function SCIA216()

	Local aArea       := GetArea()
	Local lReturn     := .T.
	Local oBrowse     := Nil

	Private cCadastro := "Entrega Nota Fiscal Entrada"

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("SZE")
    oBrowse:SetDescription(cCadastro)
    oBrowse:Activate()
     
    RestArea(aArea)

Return ( lReturn ) 

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |MenuDef   | Autor | Joao Mattos           | Data |12/03/2020|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Menu Def                                                   |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | MenuDef()                                                  |||
|||-----------+------------------------------------------------------------|||
||| Parametros| Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpA1 - Array contendo as rotinas deste programa           |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function MenuDef()

	Local aRotina := {}

	Aadd( aRotina,	{ "Pesquisar"	,	"AxPesqui" 	    	, 0, 1	})
	Aadd( aRotina,	{ "Visualizar"	,	"U_A216Manute(2)"	, 0, 2	})
	Aadd( aRotina,	{ "Incluir"		,	"U_A216Manute(3)"	, 0, 3	})
	Aadd( aRotina,	{ "Excluir"		,	"U_A216Manute(5)"	, 0, 5	})

Return ( aRotina )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |A216Manute| Autor | Joao Mattos           | Data |12/03/2020|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Manutencao da Entrega da Nota Fiscal de Entrada                  |||
|||------------------------------------------------------------------------|||
||| Sintaxe   | A216Manute( opcao )                                        |||
|||-----------+------------------------------------------------------------|||
||| Parametros| Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpO1 - Objeto modelo de dados                             |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
User Function A216Manute( nOpcao )

	Local aDimTop      := {}	// Array de dimensoes do topo
	Local aDimMid      := {}	// Array de dimensoes do meio
	Local oGrpTop      := Nil	// Grupo do Topo
	Local oGrpMid      := Nil	// Grupo do Meio
	Local nTop         := 0
	Local nLeft        := 0
	Local nBottom      := 0
	Local nRight       := 0
	Local bGravar      := Nil
	Local oSize        := Nil
	Local lOk          := .T.

	Private _nStack    := GetSX8Len()

	Private _INCLUI    := .F.
	Private _EXCLUI    := .F.
	Private _VISUAL    := .F.

	Private oDlg       := Nil

	//--< Cabecalho da Entrega da Nota Fiscal de Entrada >--\\
	Private oSeqEntreg := Nil
	Private cSeqEntreg := Space(TamSX3("ZE_SEQENTR")[1])

	Private oNFEntrada := Nil
	Private cNFEntrada := Space(TamSX3("F1_DOC")[1])

	Private oSerieNFEn := Nil
	Private cSerieNFEn := Space(TamSX3("F1_SERIE")[1])

	Private oData := Nil
	Private dData := Date()

	Private oQuemReceb := Nil
	Private cQuemReceb := Space(TamSX3("ZE_QUEMREC")[1])

	Private oDataReceb := Nil
	Private dDataReceb := CToD('  /  /  ')

	Private oHoraReceb := Nil
	Private cHoraReceb := Space(TamSX3("ZE_HRREC")[1])

	Private oCodFornec := Nil
	Private cCodFornec := Space(TamSX3("ZE_CODFOR")[1])

	Private oLojFornec := Nil
	Private cLojFornec := Space(TamSX3("ZE_LOJFOR")[1])

	Private oNomFornec := Nil
	Private cNomFornec := Space(TamSX3("ZE_NOMFOR")[1])

	Private aCabecEntr := { "", "Item", "Código Produto", "Descrição Produto", "Unidade", "Qtde Nota", "Saldo","Qtde Entregue" }
	Private oBrowseEnt := Nil
	Private aBrowseEnt := {}
	Private oOk        := Loadbitmap(GetResources(), "LBOK")
	Private oNo        := Loadbitmap(GetResources(), "LBNO")

	If nOpcao <> 3

		SA2->( dbSetOrder(1))	// A2_FILIAL + A2_COD + A2_LOJA
		SA2->( dbSeek(xFilial("SA2") + SZE->ZE_CODFOR + SZE->ZE_LOJFOR ))

		cSeqEntreg := SZE->ZE_SEQENTR
		cNFEntrada := SZE->ZE_NF
		cQuemReceb := SZE->ZE_QUEMREC
		dDataReceb := SZE->ZE_DTREC
		dData      := SZE->ZE_DATA
		cHoraReceb := SZE->ZE_HRREC
		cCodFornec := SZE->ZE_CODFOR
		cLojFornec := SZE->ZE_LOJFOR
		cNomFornec := SA2->A2_NOME
	EndIf

	If nOpcao == 3
	
		bGravar := {|| A216GRAVA(),oDlg:End()}
		
		_INCLUI := .T.

		cSeqEntreg := GetSXENum( "SZE", "ZE_SEQENTR" )	// sequencial
		dDataReceb := dDataBase
		cHoraReceb := Left(Time(),5)

		A216INICIA()
	ElseIf nOpcao == 5 // Excluir
	
		bGravar := {|| A216EXCLUI(),oDlg:End()}
		
		_EXCLUI := .T.

		A216MONNFE()
	Else // Outras
	
		bGravar := {|| oDlg:End()}

		_VISUAL := .T.
		
		A216MONNFE()
	EndIf

	//|===========================================|
	//| Calculo de dimensionamento da tela        |
	//|===========================================|
	oSize := FwDefSize():New(.T.)
	oSize:AddObject( "TOP"		,100, 30, .T., .T. ) // 18% do topo da tela
	oSize:AddObject( "MIDDLE"	,100, 70, .T., .T. ) // 82% do meio da tela
	oSize:lProp := .T.
	oSize:Process()	

	// Dimensoes das areas da tela
	aAdd( aDimTop, oSize:GetDimension("TOP","LININI") )
	aAdd( aDimTop, oSize:GetDimension("TOP","COLINI") )
	aAdd( aDimTop, oSize:GetDimension("TOP","LINEND") )
	aAdd( aDimTop, oSize:GetDimension("TOP","COLEND") )

	aAdd( aDimMid, oSize:GetDimension("MIDDLE","LININI") )
	aAdd( aDimMid, oSize:GetDimension("MIDDLE","COLINI") )
	aAdd( aDimMid, oSize:GetDimension("MIDDLE","LINEND") )
	aAdd( aDimMid, oSize:GetDimension("MIDDLE","COLEND") )

	// Dimensoes da tela
	nTop 	:= oSize:aWindSize[1]
	nLeft 	:= oSize:aWindSize[2]
	nBottom	:= oSize:aWindSize[3]
	nRight	:= oSize:aWindSize[4]

	oDlg := MSDialog():New(	nTop,; //nTop Numérico Indica a coordenada vertical superior em pixels ou caracteres.
							nLeft,; //nLeft numérico Indica a coordenada horizontal esquerda em pixels ou caracteres.
							nBottom,; //nBottom numérico Indica a coordenada vertical inferior em pixels ou caracteres.
							nRight,; // nRight numérico Indica a coordenada horizontal direita em pixels ou caracteres.
							cCadastro,; // cCaption caractere Indica o título da janela.
							Nil,; // uParam6 caractere Compatibilidade.
							Nil,; // uParam7 numérico Compatibilidade.
							Nil,; // uParam8 lógico Compatibilidade.
							Nil,; // uParam9 qualquer Compatibilidade.
							CLR_BLACK,; // nClrText numérico Indica a cor do texto.
							CLR_WHITE,; // nClrBack numérico Indica a cor de fundo.
							Nil,; // uParam12 objeto Compatibilidade.
							Nil,; // oWnd objeto Indica a janela mãe (principal) da janela que será criada. O padrão é a janela principal do programa.
							.T.,; // lPixel lógico Indica se considera as coordenadas passadas em pixels (.T.) ou caracteres (.F.).
							Nil,; // uParam15 qualquer Compatibilidade.
							Nil,; // uParam16 qualquer Compatibilidade.
							Nil,; // uParam17 qualquer Compatibilidade.
							.T.) // lTransparent lógico Se .T. permitira que a Dialog receba um fundo transparente.

	//>----- INICIO TOPO -----<	
	oGrpTop := TGroup():New( aDimTop[1],aDimTop[2],aDimTop[3],aDimTop[4],"",oDlg,,,.T. )

	// linha 1
	@ aDimTop[1]+10,aDimTop[2]+010 Say OemToAnsi("Sequencia Entrega") OF oDlg PIXEL
	@ aDimTop[1]+06,aDimTop[2]+060 MSGET oSeqEntreg VAR cSeqEntreg Picture PesqPict("SZE","ZE_SEQENTR") WHEN .F. SIZE 60,10 OF oDlg PIXEL

	@ aDimTop[1]+10,aDimTop[2]+140 Say OemToAnsi("Nota Fiscal Entrada") OF oDlg PIXEL
	@ aDimTop[1]+06,aDimTop[2]+190 MSGET oNFEntrada VAR cNFEntrada Picture PesqPict("SF1","F1_DOC") F3 "SF1INT" VALID (A216PEDCOM(cNFEntrada)) WHEN _INCLUI SIZE 60,10 OF oDlg PIXEL

	@ aDimTop[1]+10,aDimTop[2]+270 Say OemToAnsi("Série N.Fiscal Entrada") OF oDlg PIXEL
	@ aDimTop[1]+06,aDimTop[2]+330 MSGET oSerieNFEn VAR cSerieNFEn Picture PesqPict("SF1","F1_SERIE") WHEN .F. SIZE 60,10 OF oDlg PIXEL

	@ aDimTop[1]+10,aDimTop[2]+400 Say OemToAnsi("Data?") OF oDlg PIXEL
	@ aDimTop[1]+06,aDimTop[2]+420 MSGET oData VAR dData Picture PesqPict("SZE","ZE_DATA") WHEN _INCLUI SIZE 60,10 OF oDlg PIXEL

	@ aDimTop[1]+10,aDimTop[2]+510 Say OemToAnsi("Quem Pegou?") OF oDlg PIXEL
	@ aDimTop[1]+06,aDimTop[2]+550 MSGET oQuemReceb VAR cQuemReceb Picture PesqPict("SZE","ZE_QUEMREC") WHEN _INCLUI SIZE 60,10 OF oDlg PIXEL

	// linha 2
	@ aDimTop[1]+30,aDimTop[2]+010 Say OemToAnsi("Data Recebimento") OF oDlg PIXEL
	@ aDimTop[1]+26,aDimTop[2]+060 MSGET oDataReceb VAR dDataReceb Picture PesqPict("SZE","ZE_DTREC") WHEN _INCLUI SIZE 60,10 OF oDlg PIXEL

	@ aDimTop[1]+30,aDimTop[2]+140 Say OemToAnsi("Hora Recebimento") OF oDlg PIXEL
	@ aDimTop[1]+26,aDimTop[2]+190 MSGET oHoraReceb VAR cHoraReceb Picture PesqPict("SZE","ZE_HRREC") WHEN _INCLUI SIZE 60,10 OF oDlg PIXEL

	// linha 3
	@ aDimTop[1]+50,aDimTop[2]+010 Say OemToAnsi("Código Fornecedor") OF oDlg PIXEL
	@ aDimTop[1]+46,aDimTop[2]+060 MSGET oCodFornec VAR cCodFornec Picture PesqPict("SZE","ZE_CODFOR") WHEN .F. SIZE 60,10 OF oDlg PIXEL

	@ aDimTop[1]+50,aDimTop[2]+140 Say OemToAnsi("Loja Fornecedor") OF oDlg PIXEL
	@ aDimTop[1]+46,aDimTop[2]+190 MSGET oLojFornec VAR cLojFornec Picture PesqPict("SZE","ZE_LOJFOR") WHEN .F. SIZE 60,10 OF oDlg PIXEL

	@ aDimTop[1]+50,aDimTop[2]+270 Say OemToAnsi("Nome Fornecedor") OF oDlg PIXEL
	@ aDimTop[1]+46,aDimTop[2]+330 MSGET oNomFornec VAR cNomFornec Picture PesqPict("SZE","ZE_NOMFOR") WHEN .F. SIZE 150,10 OF oDlg PIXEL

	//>----- INICIO MEIO -----<	
	oGrpTop := TGroup():New( aDimMid[1],aDimMid[2],aDimMid[3],aDimMid[4],"",oDlg,,,.T. )

	oBrowseEnt := TCBrowse():New( 	aDimMid[1]+8,;
									aDimMid[2]+4,;
									aDimMid[4]-10,;
									aDimMid[3]-aDimMid[1]-10,;
									,;
									aCabecEntr,;
									{20,50,50,60,20,50,50},;
									oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	oBrowseEnt:SetArray(aBrowseEnt)
	oBrowseEnt:bLine := {|| EntLine() }
	oBrowseEnt:bHeaderClick := {|| DesAllClic() }
	oBrowseEnt:bLDblClick := {|| EntdbClick() }
	
	oDlg:Activate(,,,.T.,,,EnchoiceBar(oDlg,bGravar,{||oDlg:End()}))

	While GetSX8Len() > _nStack

		RollBackSX8()
	EndDo

Return ( Nil )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |EntLine   | Autor | Joao Mattos           | Data |12/03/2020|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Bloco Line do TWBrowse das Entregas                        |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | EntLine()                                                  |||
|||-----------+------------------------------------------------------------|||
||| Parametros| Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpA1 - Line das Entregas                                  |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function EntLine()

	Local aReturn := {}
	
	AADD( aReturn, Iif(aBrowseEnt[oBrowseEnt:nAt,01],oOK,oNO)	)	// 01 - Marcado ou Desmarcado
	AADD( aReturn, aBrowseEnt[oBrowseEnt:nAt,02] 				)	// 02 - Item da Nota Fiscal de Entrada
	AADD( aReturn, aBrowseEnt[oBrowseEnt:nAt,03] 				)	// 03 - Codigo do Produto
	AADD( aReturn, aBrowseEnt[oBrowseEnt:nAt,04] 				)	// 04 - Descricao do Produto
	AADD( aReturn, aBrowseEnt[oBrowseEnt:nAt,05] 				)	// 05 - Unidade de Medida
	AADD( aReturn, Transform(aBrowseEnt[oBrowseEnt:nAt,06], "@E 99,999,999,999.99")	)	// 06 - Quantidade do Item da Nota Fiscal de Entrada
	AADD( aReturn, Transform(aBrowseEnt[oBrowseEnt:nAt,07], "@E 99,999,999,999.99")	)	// 07 - Saldo
	AADD( aReturn, Transform(aBrowseEnt[oBrowseEnt:nAt,08], "@E 99,999,999,999.99")	)	// 08 - Quantidade Entregue

Return ( aReturn )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |EntdbClick| Autor | Joao Mattos           | Data |12/03/2020|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Duplo Clic do TWBrowse das Entregas                        |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | EntdbClick()                                               |||
|||-----------+------------------------------------------------------------|||
||| Parametros| Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function EntdbClick()

	Local nSaldoNFE := aBrowseEnt[oBrowseEnt:nAt][7]
	Local nQtdeEntr := Nil
	Local lOk       := .T.

	If _INCLUI

		If oBrowseEnt:ColPos() == 1	// 01 - Marcado ou Desmarcado
			
			aBrowseEnt[oBrowseEnt:nAt][1] := !aBrowseEnt[oBrowseEnt:nAt][1]
			oBrowseEnt:DrawSelect()
			ObjectMethod(oBrowseEnt,"Refresh()")
		ElseIf oBrowseEnt:ColPos() == 8 // 08 - Quantidade Entregue

			nQtdeEntr  := aBrowseEnt[oBrowseEnt:nAt][oBrowseEnt:ColPos()]

			// Obtem as coordenadas da celula (lugar onde a janela de edicao deve ficar)
			oRect := tRect():New(0,0,0,0)            
			oBrowseEnt:GetCellRect(oBrowseEnt:ColPos(),,oRect)
			aDim := {oRect:nTop,oRect:nLeft,oRect:nBottom,oRect:nRight}

			// Monta dialogo de tamanho 0, para ter onde colocar o get.
			DEFINE MSDIALOG _oDlg OF oDlg FROM 0, 0 TO 0, 0 STYLE nOR( WS_VISIBLE, WS_POPUP ) PIXEL

				// Gera get sobre a celula, dando a impressao que a mesma estah sendo editada.
				@ 0,0 MSGET oGet1 VAR nQtdeEntr picture "@E 99,999,999,999.99"  WHEN .T. SIZE 60,10 OF _oDlg  PIXEL

				oGet1:Move(-2,-2, (aDim[ 4 ] - aDim[ 2 ]) + 4, aDim[ 3 ] - aDim[ 1 ] + 4 )

				// Botao de tamanho 0 para pegar o 'enter'.
				@ 0, 0 BUTTON _oBtn PROMPT "ze" SIZE 0,0 OF _oDlg
				_oBtn:bGotFocus := {|| _oDlg:nLastKey := VK_RETURN, _oDlg:End(0)}
			ACTIVATE MSDIALOG _oDlg ON INIT _oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1])

			lOk := ValEntrega(nSaldoNFE,nQtdeEntr)
			
			If lOk

				// Grava o novo valor
				aBrowseEnt[oBrowseEnt:nAt][oBrowseEnt:ColPos()] := nQtdeEntr
			Else

				// Grava o novo valor
				aBrowseEnt[oBrowseEnt:nAt][oBrowseEnt:ColPos()] := nSaldoNFE
			EndIf

			// Atualiza o browse em tela.
			oBrowseEnt:Refresh ()
		EndIf
	ElseIf _EXCLUI

		aBrowseEnt[oBrowseEnt:nAt][1] := !aBrowseEnt[oBrowseEnt:nAt][1]
		oBrowseEnt:DrawSelect()
		ObjectMethod(oBrowseEnt,"Refresh()")
	EndIf

Return ( Nil )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |ValEntrega| Autor | Joao Mattos           | Data |12/03/2020|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Validacao da Quantidade Entregue                           |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | ValEntrega(nSaldoNFE,nQtdeEntr)                            |||
|||-----------+------------------------------------------------------------|||
||| Parametros| ExpN1 - Saldo do Item da Nota Fiscal de Entrada            |||
|||           | ExpN2 - Quantidade Entregue                                |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpL1 - Verdadeiro ou Falso                                |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function ValEntrega( nSaldoNFE, _nQtdeEntr )

	Local lReturn   := .T.
	Local cProblema := ""
	Local aSolucao  := {}

	If _nQtdeEntr > nSaldoNFE

		cProblema := "Quantidade Entregue maior que o saldo de Quantidade do Item da Nota Fiscal de Entrada."
		aSolucao  := {}
		AADD ( aSolucao, "Informe quantidade entregue até " + AllTrim(Transform(nSaldoNFE,"@E 999,999,999.99")) + "." )
		Help( Nil, Nil, FunName()+"_03", Nil, cProblema, 1, 0, Nil, Nil, Nil, Nil, Nil, aSolucao ) 	
		lReturn := .F.
	ElseIf _nQtdeEntr == 0 .Or. _nQtdeEntr < 0

		cProblema := "Quantidade Entregue menor ou igual a zero."
		aSolucao  := {}
		AADD ( aSolucao, "Informe quantidade entregue maior que zero" )
		Help( Nil, Nil, FunName()+"_04", Nil, cProblema, 1, 0, Nil, Nil, Nil, Nil, Nil, aSolucao ) 	
		lReturn := .F.
	EndIf

Return ( lReturn )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |DesAllClic| Autor | Joao Mattos           | Data |12/03/2020|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Marcacao de tudo das Despesas                              |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | DesAllClic()                                               |||
|||-----------+------------------------------------------------------------|||
||| Parametros| Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function DesAllClic()

	Local nJ := 0

	If !_VISUAL

		For nJ := 1 to Len(aBrowseEnt)
		
			aBrowseEnt[nJ][1] := .T.
		Next nJ
		ObjectMethod(oBrowseEnt,"Refresh()")
	EndIf

Return ( Nil)

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |A216PEDCOM| Autor | Joao Mattos           | Data |12/03/2020|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Validacao da Nota Fiscal de Entrada                        |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | A216PEDCOM()                                               |||
|||-----------+------------------------------------------------------------|||
||| Parametros| Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpL1 - Verdadeiro ou Falso                                |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function A216PEDCOM(cNFEntrada)

	Local lReturn   := .T.
	Local cProblema := ""
	Local aSolucao  := {}
	Local cQuery    := ""
	Local cAliasSD1 := GetNextAlias()
	Local cAliasSZE := GetNextAlias()
	Local nSaldo    := 0

	If cNFEntrada <> SF1->F1_DOC

		cProblema := "Nota Fiscal de Entrada não selecionada."
		aSolucao  := {}
		AADD ( aSolucao, "Selecione a Nota Fiscal de Entrada pela Consulta Padrão, ou seja, pela tecla padrão F3." )
		Help( Nil, Nil, FunName()+"_01", Nil, cProblema, 1, 0, Nil, Nil, Nil, Nil, Nil, aSolucao ) 	
		lReturn := .F.

	Else // Verificar o que ja foi entregue

		SA2->( dbSetOrder(1))	// A2_FILIAL + A2_COD + A2_LOJA
		SA2->( dbSeek(xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA ))

		cSerieNFEn := SF1->F1_SERIE
		cCodFornec := SF1->F1_FORNECE
		cLojFornec := SF1->F1_LOJA
		cNomFornec := SA2->A2_NOME

		aBrowseEnt := {}
		oBrowseEnt:SetArray(aBrowseEnt)
		oBrowseEnt:bLine := {|| EntLine() }
		oBrowseEnt:Refresh ()

		cQuery := " SELECT D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_ITEM, D1_COD, B1_DESC, B1_UM, D1_QUANT "
		cQuery += " FROM " + RetSQLName("SD1") + " SD1 "
		cQuery += " INNER JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = SD1.D1_COD AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE SD1.D1_FILIAL  = '" + xFilial("SD1")  + "' "
		cQuery += "   AND SD1.D1_DOC     = '" + SF1->F1_DOC     + "' "
		cQuery += "   AND SD1.D1_SERIE   = '" + SF1->F1_SERIE   + "' "
		cQuery += "   AND SD1.D1_FORNECE = '" + SF1->F1_FORNECE + "' "
		cQuery += "   AND SD1.D1_LOJA    = '" + SF1->F1_LOJA    + "' "
		cQuery += "   AND SD1.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY D1_ITEM "
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSD1,.F.,.T.)
		While !Eof()

			cQuery := " SELECT SUM(ZE_QUANT) ZE_QUANT "
			cQuery += " FROM " + RetSQLName("SZE") + " SZE "
			cQuery += " WHERE SZE.ZE_FILIAL  = '" + xFilial("SZE")          + "' "
			cQuery += "   AND SZE.ZE_NF      = '" + (cAliasSD1)->D1_DOC     + "' "
			cQuery += "   AND SZE.ZE_SERIE   = '" + (cAliasSD1)->D1_SERIE   + "' "
			cQuery += "   AND SZE.ZE_ITNF    = '" + (cAliasSD1)->D1_ITEM    + "' "
			cQuery += "   AND SZE.ZE_CODFOR  = '" + (cAliasSD1)->D1_FORNECE + "' "
			cQuery += "   AND SZE.ZE_LOJFOR  = '" + (cAliasSD1)->D1_LOJA    + "' "
			cQuery += "   AND SZE.D_E_L_E_T_ = ' '"
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSZE,.F.,.T.)
			If !Eof()

				If (cAliasSZE)->ZE_QUANT < (cAliasSD1)->D1_QUANT

					nSaldo := (cAliasSD1)->D1_QUANT - (cAliasSZE)->ZE_QUANT

					Aadd( aBrowseEnt, {} )
					Aadd( Atail (aBrowseEnt), .T.						)	// 01 - Marcado ou Desmarcado
					Aadd( Atail (aBrowseEnt), (cAliasSD1)->D1_ITEM		)	// 02 - Item da Nota Fiscal de Entrada
					Aadd( Atail (aBrowseEnt), (cAliasSD1)->D1_COD		)	// 03 - Codigo do Produto
					Aadd( Atail (aBrowseEnt), (cAliasSD1)->B1_DESC		)	// 04 - Descricao do Produto
					Aadd( Atail (aBrowseEnt), (cAliasSD1)->B1_UM		)	// 05 - Unidade de Medida
					Aadd( Atail (aBrowseEnt), (cAliasSD1)->D1_QUANT		)	// 06 - Quantidade do Item da Nota Fiscal de Entrada
					Aadd( Atail (aBrowseEnt), nSaldo				 	)	// 07 - Saldo
					Aadd( Atail (aBrowseEnt), nSaldo				 	)	// 08 - Quantidade Entrega
				EndIf
			EndIf
			dbSelectArea(cAliasSZE)
			dbCloseArea()

			dbSelectArea(cAliasSD1)
			dbSkip()
		EndDo
		dbSelectArea(cAliasSD1)
		dbCloseArea()

		oBrowseEnt:SetArray(aBrowseEnt)
		oBrowseEnt:bLine := {|| EntLine() }
		oBrowseEnt:Refresh ()

		If Len(aBrowseEnt) == 0

			cProblema := "Não existe saldo de entrega para esta Nota Fiscal de Entrada!"
			aSolucao  := {}
			AADD ( aSolucao, "Selecione outra Nota Fiscal de Entrada." )
			Help( Nil, Nil, FunName()+"_02", Nil, cProblema, 1, 0, Nil, Nil, Nil, Nil, Nil, aSolucao ) 	
			lReturn := .F.
		
			A216INICIA()		
			oBrowseEnt:SetArray(aBrowseEnt)
			oBrowseEnt:bLine := {|| EntLine() }
			oBrowseEnt:Refresh ()
		EndIf
	EndIf

Return ( lReturn )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |A216GRAVA | Autor | Joao Mattos           | Data |12/03/2020|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Gravacao das Entregas da Nota Fiscal de Entrada            |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | A216GRAVA()                                                |||
|||-----------+------------------------------------------------------------|||
||| Parametros| ExpC1 - Numero da Solicitacao                              |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpL1 - Verdadeiro ou Falso                                |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function A216GRAVA()

	Local lReturn := .T.
	Local nJ      := 0

	If _INCLUI
	
		For nJ:= 1 to Len(aBrowseEnt)

			If aBrowseEnt[nJ][1] // Se esta marcado
			
				dbSelectArea("SZE")
				RecLock("SZE",.T.)

					SZE->ZE_FILIAL  := xFilial("SZE")
					SZE->ZE_SEQENTR := cSeqEntreg
					SZE->ZE_QUEMREC := cQuemReceb
					SZE->ZE_DTREC   := dDataReceb
					SZE->ZE_DATA    := dData
					SZE->ZE_HRREC   := cHoraReceb
					SZE->ZE_NF      := cNFEntrada
					SZE->ZE_SERIE   := cSerieNFEn
					SZE->ZE_ITNF    := aBrowseEnt[nJ][2]
					SZE->ZE_PROD    := aBrowseEnt[nJ][3]
					SZE->ZE_CODFOR  := cCodFornec
					SZE->ZE_LOJFOR  := cLojFornec
					SZE->ZE_QUANT   := aBrowseEnt[nJ][8]
				MsUnLock()
			EndIf
		Next nJ
	EndIf

	While GetSX8Len() > _nStack

		ConfirmSX8()
	EndDo

Return ( lReturn )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |A216EXCLUI| Autor | Joao Mattos           | Data |12/03/2020|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Validacao do Numero da Solicitacao                         |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | A216EXCLUI()                                               |||
|||-----------+------------------------------------------------------------|||
||| Parametros| Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function A216EXCLUI()

	Local nJ      := 0

	If _EXCLUI
	
		Begin Transaction

			SZE->( dbSetOrder(1) )	// ZE_FILIAL + ZE_SEQENTR + ZE_ITNF
			For nJ:= 1 to Len(aBrowseEnt)

				If aBrowseEnt[nJ][1] // Se esta marcado

					If SZE->( dbSeek(xFilial("SZE") + cSeqEntreg + aBrowseEnt[nJ][2] ))

						dbSelectArea("SZE")
						RecLock("SZE",.F.)

							dbDelete()
						MsUnLock()
					EndIf
				EndIf
			Next nJ
		End Transaction
	EndIf

Return ( Nil )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |A216INICIA| Autor | Joao Mattos           | Data |12/03/2020|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Inicializa o browse                                        |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | A216INICIA()                                               |||
|||-----------+------------------------------------------------------------|||
||| Parametros| Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static function A216INICIA()

	Local lReturn    := .F.

	Aadd( aBrowseEnt, {} )
	Aadd( Atail (aBrowseEnt), .F.	)	// 01 - Marcado ou Desmarcado
	Aadd( Atail (aBrowseEnt), ""	)	// 02 - Item da Nota Fiscal de Entrada
	Aadd( Atail (aBrowseEnt), ""	)	// 03 - Codigo do Produto
	Aadd( Atail (aBrowseEnt), ""	)	// 04 - Descricao do Produto
	Aadd( Atail (aBrowseEnt), ""	)	// 05 - Unidade de Medida
	Aadd( Atail (aBrowseEnt), 0		)	// 06 - Quantidade do Item da Nota Fiscal de Entrada
	Aadd( Atail (aBrowseEnt), 0		)	// 07 - Saldo
	Aadd( Atail (aBrowseEnt), 0		)	// 08 - Quantidade Entregue
Return( lReturn )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |A216MONNFE| Autor | Joao Mattos           | Data |12/03/2020|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Monta dados da Nota Fiscal de Entrada                      |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | A216MONNFE()                                               |||
|||-----------+------------------------------------------------------------|||
||| Parametros| Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function A216MONNFE()

	Local cQuery     := ""
	Local cAliasSZE  := GetNextAlias()
	Local cAliasSZES := GetNextAlias()
	Local nSaldo     := 0

	SA2->( dbSetOrder(1))	// A2_FILIAL + A2_COD + A2_LOJA
	SA2->( dbSeek(xFilial("SA2") + SZE->ZE_CODFOR + SZE->ZE_LOJFOR ))

	cCodFornec := SZE->ZE_CODFOR
	cLojFornec := SZE->ZE_LOJFOR
	cNomFornec := SA2->A2_NOME

	aBrowseEnt := {}

	cQuery := " SELECT * "
	cQuery += " FROM " + RetSQLName("SZE") + " SZE "
	cQuery += " WHERE SZE.ZE_FILIAL  = '" + xFilial("SZE")   + "' "
	cQuery += "   AND SZE.ZE_SEQENTR = '" + SZE->ZE_SEQENTR  + "' "
	cQuery += "   AND SZE.D_E_L_E_T_ = ' '"
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSZE,.F.,.T.)
	While !Eof()

		SD1->( dbSetOrder(1) )	// D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_COD + D1_ITEM
		SD1->( dbSeek(xFilial("SD1") + PadR((cAliasSZE)->ZE_NF,TamSx3("F1_DOC")[1]) + PadR((cAliasSZE)->ZE_SERIE,TamSx3("F1_SERIE")[1]) + PadR((cAliasSZE)->ZE_CODFOR,TamSx3("F1_FORNECE")[1]) + PadR((cAliasSZE)->ZE_LOJFOR,TamSx3("F1_LOJA")[1]) + PadR((cAliasSZE)->ZE_PROD,TamSx3("D1_COD")[1]) + PadR((cAliasSZE)->ZE_ITNF,TamSx3("D1_ITEM")[1]) ) )

		SB1->( dbSetOrder(1) )	// B1_FILIAL + B1_COD
		SB1->( dbSeek(xFilial("SB1") + (cAliasSZE)->ZE_PROD ) )

		nSaldo := 0

		cQuery := " SELECT SUM(ZE_QUANT) ZE_QUANT "
		cQuery += " FROM " + RetSQLName("SZE") + " SZE "
		cQuery += " WHERE SZE.ZE_FILIAL  = '" + xFilial("SZE")          + "' "
		cQuery += "   AND SZE.ZE_NF      = '" + SD1->D1_DOC     + "' "
		cQuery += "   AND SZE.ZE_SERIE   = '" + SD1->D1_SERIE   + "' "
		cQuery += "   AND SZE.ZE_ITNF    = '" + SD1->D1_ITEM    + "' "
		cQuery += "   AND SZE.ZE_CODFOR  = '" + SD1->D1_FORNECE + "' "
		cQuery += "   AND SZE.ZE_LOJFOR  = '" + SD1->D1_LOJA    + "' "
		cQuery += "   AND SZE.D_E_L_E_T_ = ' '"
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSZES,.F.,.T.)
		If !Eof()

			nSaldo := SD1->D1_QUANT - (cAliasSZES)->ZE_QUANT
		EndIf
		dbSelectArea(cAliasSZES)
		dbCloseArea()

		Aadd( aBrowseEnt, {} )
		Aadd( Atail (aBrowseEnt), .T.						)	// 01 - Marcado ou Desmarcado
		Aadd( Atail (aBrowseEnt), (cAliasSZE)->ZE_ITNF		)	// 02 - Item da Nota Fiscal de Entrada
		Aadd( Atail (aBrowseEnt), (cAliasSZE)->ZE_PROD		)	// 03 - Codigo do Produto
		Aadd( Atail (aBrowseEnt), SB1->B1_DESC				)	// 04 - Descricao do Produto
		Aadd( Atail (aBrowseEnt), SB1->B1_UM				)	// 05 - Unidade de Medida
		Aadd( Atail (aBrowseEnt), SD1->D1_QUANT				)	// 06 - Quantidade do Item da Nota Fiscal de Entrada
		Aadd( Atail (aBrowseEnt), nSaldo				 	)	// 07 - Saldo
		Aadd( Atail (aBrowseEnt), (cAliasSZE)->ZE_QUANT		)	// 08 - Quantidade Entregue
	
		dbSelectArea(cAliasSZE)
		dbSkip()
	EndDo
	dbSelectArea(cAliasSZE)
	dbCloseArea()

	If Len(aBrowseEnt) == 0

		A216INICIA()
	EndIf
Return ( Nil )
