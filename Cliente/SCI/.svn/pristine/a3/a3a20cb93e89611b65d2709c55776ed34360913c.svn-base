#Include 'Totvs.ch'
#Include 'FWMVCDef.ch'

/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    | SCIA215 | Autor | Joao Mattos            | Data |05/03/2020|||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao | Entrega de Pedido de Compra                                |||
|||           |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | U_SCIA215()                                                |||
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
User Function SCIA215()

	Local aArea       := GetArea()
	Local lReturn     := .T.
	Local oBrowse     := Nil

	Private cCadastro := "Entrega Pedido de Compra"

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("SZF")
    oBrowse:SetDescription(cCadastro)
    oBrowse:Activate()
     
    RestArea(aArea)

Return ( lReturn ) 

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |MenuDef   | Autor | Joao Mattos           | Data |05/03/2020|||
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
	Aadd( aRotina,	{ "Visualizar"	,	"U_A215Manute(2)"	, 0, 2	})
	Aadd( aRotina,	{ "Incluir"		,	"U_A215Manute(3)"	, 0, 3	})
	Aadd( aRotina,	{ "Excluir"		,	"U_A215Manute(5)"	, 0, 5	})

Return ( aRotina )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |A215Manute| Autor | Joao Mattos           | Data |06/03/2020|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Manutencao da Entrega do Pedido de Compra                  |||
|||------------------------------------------------------------------------|||
||| Sintaxe   | A215Manute( opcao )                                        |||
|||-----------+------------------------------------------------------------|||
||| Parametros| Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpO1 - Objeto modelo de dados                             |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
User Function A215Manute( nOpcao )

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

	//--< Cabecalho da Entrega do Pedido de Compra >--\\
	Private oSeqEntreg := Nil
	Private cSeqEntreg := Space(TamSX3("ZF_SEQENTR")[1])

	Private oPedCompra := Nil
	Private cPedCompra := Space(TamSX3("C7_NUM")[1])

	Private oData      := Nil
	Private dData      := Date()

	Private oQuemReceb := Nil
	Private cQuemReceb := Space(TamSX3("ZF_QUEMREC")[1])

	Private oDataReceb := Nil
	Private dDataReceb := CToD('  /  /  ')

	Private oHoraReceb := Nil
	Private cHoraReceb := Space(TamSX3("ZF_HRREC")[1])

	Private oCodFornec := Nil
	Private cCodFornec := Space(TamSX3("ZF_CODFOR")[1])

	Private oLojFornec := Nil
	Private cLojFornec := Space(TamSX3("ZF_LOJFOR")[1])

	Private oNomFornec := Nil
	Private cNomFornec := Space(TamSX3("ZF_NOMFOR")[1])

	Private aCabecEntr := { "", "Item", "Código Produto", "Descrição Produto", "Unidade", "Qtde Pedido", "Saldo","Qtde Entregue" }
	Private oBrowseEnt := Nil
	Private aBrowseEnt := {}
	Private oOk        := Loadbitmap(GetResources(), "LBOK")
	Private oNo        := Loadbitmap(GetResources(), "LBNO")

	If nOpcao <> 3

		SA2->( dbSetOrder(1))	// A2_FILIAL + A2_COD + A2_LOJA
		SA2->( dbSeek(xFilial("SA2") + SZF->ZF_CODFOR + SZF->ZF_LOJFOR ))

		cSeqEntreg := SZF->ZF_SEQENTR
		cPedCompra := SZF->ZF_PEDIDO
		cQuemReceb := SZF->ZF_QUEMREC
		dData      := SZF->ZF_DATA
		dDataReceb := SZF->ZF_DTREC
		cHoraReceb := SZF->ZF_HRREC
		cCodFornec := SZF->ZF_CODFOR
		cLojFornec := SZF->ZF_LOJFOR
		cNomFornec := SA2->A2_NOME
	EndIf

	If nOpcao == 3
	
		bGravar := {|| A215GRAVA(),oDlg:End()}
		
		_INCLUI := .T.

		cSeqEntreg := GetSXENum( "SZF", "ZF_SEQENTR" )	// sequencial
		dDataReceb := dDataBase
		cHoraReceb := Left(Time(),5)

		A215INICIA()
	ElseIf nOpcao == 5 // Excluir
	
		bGravar := {|| A215EXCLUI(),oDlg:End()}
		
		_EXCLUI := .T.

		A215MONPED()
	Else // Outras
	
		bGravar := {|| oDlg:End()}

		_VISUAL := .T.
		
		A215MONPED()
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
	@ aDimTop[1]+06,aDimTop[2]+060 MSGET oSeqEntreg VAR cSeqEntreg Picture PesqPict("SZF","ZF_SEQENTR") WHEN .F. SIZE 60,10 OF oDlg PIXEL

	@ aDimTop[1]+10,aDimTop[2]+140 Say OemToAnsi("Pedido Compra") OF oDlg PIXEL
	@ aDimTop[1]+06,aDimTop[2]+190 MSGET oPedCompra VAR cPedCompra Picture PesqPict("SC7","C7_NUM") F3 "SC7" VALID (A215PEDCOM(cPedCompra)) WHEN _INCLUI SIZE 60,10 OF oDlg PIXEL

	@ aDimTop[1]+10,aDimTop[2]+270 Say OemToAnsi("Data?") OF oDlg PIXEL
	@ aDimTop[1]+06,aDimTop[2]+290 MSGET oData VAR dData Picture PesqPict("SZF","ZF_DATA") WHEN _INCLUI SIZE 60,10 OF oDlg PIXEL

	@ aDimTop[1]+10,aDimTop[2]+380 Say OemToAnsi("Quem Pegou?") OF oDlg PIXEL
	@ aDimTop[1]+06,aDimTop[2]+420 MSGET oQuemReceb VAR cQuemReceb Picture PesqPict("SZF","ZF_QUEMREC") WHEN _INCLUI SIZE 60,10 OF oDlg PIXEL

	// linha 2
	@ aDimTop[1]+30,aDimTop[2]+010 Say OemToAnsi("Data Recebimento") OF oDlg PIXEL
	@ aDimTop[1]+26,aDimTop[2]+060 MSGET oDataReceb VAR dDataReceb Picture PesqPict("SZF","ZF_DTREC") WHEN _INCLUI SIZE 60,10 OF oDlg PIXEL

	@ aDimTop[1]+30,aDimTop[2]+140 Say OemToAnsi("Hora Recebimento") OF oDlg PIXEL
	@ aDimTop[1]+26,aDimTop[2]+190 MSGET oHoraReceb VAR cHoraReceb Picture PesqPict("SZF","ZF_HRREC") WHEN _INCLUI SIZE 60,10 OF oDlg PIXEL

	// linha 3
	@ aDimTop[1]+50,aDimTop[2]+010 Say OemToAnsi("Código Fornecedor") OF oDlg PIXEL
	@ aDimTop[1]+46,aDimTop[2]+060 MSGET oCodFornec VAR cCodFornec Picture PesqPict("SZF","ZF_CODFOR") WHEN .F. SIZE 60,10 OF oDlg PIXEL

	@ aDimTop[1]+50,aDimTop[2]+140 Say OemToAnsi("Loja Fornecedor") OF oDlg PIXEL
	@ aDimTop[1]+46,aDimTop[2]+190 MSGET oLojFornec VAR cLojFornec Picture PesqPict("SZF","ZF_LOJFOR") WHEN .F. SIZE 60,10 OF oDlg PIXEL

	@ aDimTop[1]+50,aDimTop[2]+270 Say OemToAnsi("Nome Fornecedor") OF oDlg PIXEL
	@ aDimTop[1]+46,aDimTop[2]+330 MSGET oNomFornec VAR cNomFornec Picture PesqPict("SZF","ZF_NOMFOR") WHEN .F. SIZE 150,10 OF oDlg PIXEL

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
||| Funcao    |EntLine   | Autor | Joao Mattos           | Data |06/03/2020|||
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
	AADD( aReturn, aBrowseEnt[oBrowseEnt:nAt,02] 				)	// 02 - Item do Pedido de Compra
	AADD( aReturn, aBrowseEnt[oBrowseEnt:nAt,03] 				)	// 03 - Codigo do Produto
	AADD( aReturn, aBrowseEnt[oBrowseEnt:nAt,04] 				)	// 04 - Descricao do Produto
	AADD( aReturn, aBrowseEnt[oBrowseEnt:nAt,05] 				)	// 05 - Unidade de Medida
	AADD( aReturn, Transform(aBrowseEnt[oBrowseEnt:nAt,06], "@E 99,999,999,999.99")	)	// 06 - Quantidade do Pedido de Compra
	AADD( aReturn, Transform(aBrowseEnt[oBrowseEnt:nAt,07], "@E 99,999,999,999.99")	)	// 07 - Saldo
	AADD( aReturn, Transform(aBrowseEnt[oBrowseEnt:nAt,08], "@E 99,999,999,999.99")	)	// 08 - Quantidade Entregue

Return ( aReturn )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |EntdbClick| Autor | Joao Mattos           | Data |06/03/2020|||
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

	Local nSaldoPC  := aBrowseEnt[oBrowseEnt:nAt][7]
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

			lOk := ValEntrega(nSaldoPC,nQtdeEntr)
			
			If lOk

				// Grava o novo valor
				aBrowseEnt[oBrowseEnt:nAt][oBrowseEnt:ColPos()] := nQtdeEntr
			Else

				// Grava o novo valor
				aBrowseEnt[oBrowseEnt:nAt][oBrowseEnt:ColPos()] := nSaldoPC
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
||| Funcao    |ValEntrega| Autor | Joao Mattos           | Data |10/03/2020|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Validacao da Quantidade Entregue                           |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | ValEntrega(nSaldoPC,nQtdeEntr)                             |||
|||-----------+------------------------------------------------------------|||
||| Parametros| ExpN1 - Saldo do Pedido de Compra                          |||
|||           | ExpN2 - Quantidade Entregue                                |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpL1 - Verdadeiro ou Falso                                |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function ValEntrega( _nSaldoPCO, _nQtdeEntr )

	Local lReturn   := .T.
	Local cProblema := ""
	Local aSolucao  := {}

	If _nQtdeEntr > _nSaldoPCO

		cProblema := "Quantidade Entregue maior que o saldo de quantidade do pedido de compra."
		aSolucao  := {}
		AADD ( aSolucao, "Informe quantidade entregue até " + AllTrim(Transform(_nSaldoPCO,"@E 999,999,999.99")) + "." )
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
||| Funcao    |DesAllClic| Autor | Joao Mattos           | Data |10/03/2020|||
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
||| Funcao    |A215PEDCOM| Autor | Joao Mattos           | Data |06/03/2020|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Validacao do Pedido de Compra                              |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | A215PEDCOM(cPedCompra)                                     |||
|||-----------+------------------------------------------------------------|||
||| Parametros| ExpC1 - Numero da Solicitacao                              |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpL1 - Verdadeiro ou Falso                                |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function A215PEDCOM(cPedCompra)

	Local lReturn   := .T.
	Local cProblema := ""
	Local aSolucao  := {}
	Local cQuery    := ""
	Local cAliasSC7 := GetNextAlias()
	Local cAliasSZF := GetNextAlias()
	Local nSaldo    := 0

	SC7->( dbSetOrder(1) )	// C7_FILIAL + C7_NUM + C7_ITEM + C7_SEQUEN
	If !SC7->( MsSeek( xFilial("SC7") + cPedCompra ))
	
		cProblema := "Pedido de Compra não cadastrado!"
		aSolucao  := {}
		AADD ( aSolucao, "Informe um número de Pedido de Compra válido." )
		Help( Nil, Nil, FunName()+"_01", Nil, cProblema, 1, 0, Nil, Nil, Nil, Nil, Nil, aSolucao ) 	
		lReturn := .F.
	Else // Verificar o que ja foi entregue
	
		SA2->( dbSetOrder(1))	// A2_FILIAL + A2_COD + A2_LOJA
		SA2->( dbSeek(xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA ))

		cCodFornec := SC7->C7_FORNECE
		cLojFornec := SC7->C7_LOJA
		cNomFornec := SA2->A2_NOME

		aBrowseEnt := {}
		oBrowseEnt:SetArray(aBrowseEnt)
		oBrowseEnt:bLine := {|| EntLine() }
		oBrowseEnt:Refresh ()

		cQuery := " SELECT C7_NUM, C7_ITEM, C7_PRODUTO, B1_DESC, B1_UM, C7_QUANT "
		cQuery += " FROM " + RetSQLName("SC7") + " SC7 "
		cQuery += " INNER JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD  = SC7.C7_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE SC7.C7_FILIAL  = '" + xFilial("SC7") + "' "
		cQuery += "   AND SC7.C7_NUM     = '" + cPedCompra     + "' "
		cQuery += "   AND SC7.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY C7_FILIAL, C7_NUM "
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSC7,.F.,.T.)
		While !Eof()

			cQuery := " SELECT SUM(ZF_QUANT) ZF_QUANT "
			cQuery += " FROM " + RetSQLName("SZF") + " SZF "
			cQuery += " WHERE SZF.ZF_FILIAL  = '" + xFilial("SZF")       + "' "
			cQuery += "   AND SZF.ZF_PEDIDO  = '" + (cAliasSC7)->C7_NUM  + "' "
			cQuery += "   AND SZF.ZF_ITPD    = '" + (cAliasSC7)->C7_ITEM + "' "
			cQuery += "   AND SZF.D_E_L_E_T_ = ' '"
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSZF,.F.,.T.)
			If !Eof()

				If (cAliasSZF)->ZF_QUANT < (cAliasSC7)->C7_QUANT

					nSaldo := (cAliasSC7)->C7_QUANT - (cAliasSZF)->ZF_QUANT

					Aadd( aBrowseEnt, {} )
					Aadd( Atail (aBrowseEnt), .T.						)	// 01 - Marcado ou Desmarcado
					Aadd( Atail (aBrowseEnt), (cAliasSC7)->C7_ITEM		)	// 02 - Item do Pedido de Compra
					Aadd( Atail (aBrowseEnt), (cAliasSC7)->C7_PRODUTO	)	// 03 - Codigo do Produto
					Aadd( Atail (aBrowseEnt), (cAliasSC7)->B1_DESC		)	// 04 - Descricao do Produto
					Aadd( Atail (aBrowseEnt), (cAliasSC7)->B1_UM		)	// 05 - Unidade de Medida
					Aadd( Atail (aBrowseEnt), (cAliasSC7)->C7_QUANT		)	// 06 - Quantidade do Pedido de Compra
					Aadd( Atail (aBrowseEnt), nSaldo				 	)	// 07 - Saldo
					Aadd( Atail (aBrowseEnt), nSaldo				 	)	// 08 - Quantidade Entrega
				EndIf
			EndIf
			dbSelectArea(cAliasSZF)
			dbCloseArea()

			dbSelectArea(cAliasSC7)
			dbSkip()
		EndDo
		dbSelectArea(cAliasSC7)
		dbCloseArea()

		oBrowseEnt:SetArray(aBrowseEnt)
		oBrowseEnt:bLine := {|| EntLine() }
		oBrowseEnt:Refresh ()

		If Len(aBrowseEnt) == 0

			cProblema := "Não existe saldo de entrega para este pedido de compra!"
			aSolucao  := {}
			AADD ( aSolucao, "Informe outro número de Pedido de Compra." )
			Help( Nil, Nil, FunName()+"_02", Nil, cProblema, 1, 0, Nil, Nil, Nil, Nil, Nil, aSolucao ) 	
			lReturn := .F.
		
			A215INICIA()		
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
||| Funcao    |A215GRAVA | Autor | Joao Mattos           | Data |11/03/2020|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Gravacao das Entregas do Pedido de Compra                  |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | A215GRAVA()                                                |||
|||-----------+------------------------------------------------------------|||
||| Parametros| ExpC1 - Numero da Solicitacao                              |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpL1 - Verdadeiro ou Falso                                |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function A215GRAVA()

	Local lReturn := .T.
	Local nJ      := 0

	If _INCLUI
	
		For nJ:= 1 to Len(aBrowseEnt)

			If aBrowseEnt[nJ][1] // Se esta marcado
			
				dbSelectArea("SZF")
				RecLock("SZF",.T.)

					SZF->ZF_FILIAL  := xFilial("SZF")
					SZF->ZF_SEQENTR := cSeqEntreg
					SZF->ZF_QUEMREC := cQuemReceb
					SZF->ZF_DATA    := dData
					SZF->ZF_DTREC   := dDataReceb
					SZF->ZF_HRREC   := cHoraReceb
					SZF->ZF_PEDIDO  := cPedCompra
					SZF->ZF_ITPD    := aBrowseEnt[nJ][2]
					SZF->ZF_PROD    := aBrowseEnt[nJ][3]
					SZF->ZF_CODFOR  := cCodFornec
					SZF->ZF_LOJFOR  := cLojFornec
					SZF->ZF_QUANT   := aBrowseEnt[nJ][8]
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
||| Funcao    |A215EXCLUI| Autor | Joao Mattos           | Data |11/03/2020|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Validacao do Numero da Solicitacao                         |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | A215EXCLUI()                                               |||
|||-----------+------------------------------------------------------------|||
||| Parametros| Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function A215EXCLUI()

	Local nJ      := 0

	If _EXCLUI
	
		Begin Transaction

			SZF->( dbSetOrder(1) )	// ZF_FILIAL + ZF_SEQENTR + ZF_ITPD
			For nJ:= 1 to Len(aBrowseEnt)

				If aBrowseEnt[nJ][1] // Se esta marcado

					If SZF->( dbSeek(xFilial("SZF") + cSeqEntreg + aBrowseEnt[nJ][2] ))

						dbSelectArea("SZF")
						RecLock("SZF",.F.)

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
||| Funcao    |A215INICIA| Autor | Joao Mattos           | Data |10/03/2020|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Inicializa o browse                                        |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | A215INICIA()                                               |||
|||-----------+------------------------------------------------------------|||
||| Parametros| Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static function A215INICIA()

	Local lReturn    := .F.

	Aadd( aBrowseEnt, {} )
	Aadd( Atail (aBrowseEnt), .F.	)	// 01 - Marcado ou Desmarcado
	Aadd( Atail (aBrowseEnt), ""	)	// 02 - Item do Pedido de Compra
	Aadd( Atail (aBrowseEnt), ""	)	// 03 - Codigo do Produto
	Aadd( Atail (aBrowseEnt), ""	)	// 04 - Descricao do Produto
	Aadd( Atail (aBrowseEnt), ""	)	// 05 - Unidade de Medida
	Aadd( Atail (aBrowseEnt), 0		)	// 06 - Quantidade do Pedido de Compra
	Aadd( Atail (aBrowseEnt), 0		)	// 07 - Saldo
	Aadd( Atail (aBrowseEnt), 0		)	// 08 - Quantidade Entregue
Return( lReturn )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |A215MONPED| Autor | Joao Mattos           | Data |11/03/2020|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Monta dados do pedido de compra                            |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | A215MONPED()                                               |||
|||-----------+------------------------------------------------------------|||
||| Parametros| Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function A215MONPED()

	Local cQuery     := ""
	Local cAliasSZF  := GetNextAlias()
	Local cAliasSZFS := GetNextAlias()
	Local nSaldo     := 0

	SA2->( dbSetOrder(1))	// A2_FILIAL + A2_COD + A2_LOJA
	SA2->( dbSeek(xFilial("SA2") + SZF->ZF_CODFOR + SZF->ZF_LOJFOR ))

	cCodFornec := SZF->ZF_CODFOR
	cLojFornec := SZF->ZF_LOJFOR
	cNomFornec := SA2->A2_NOME

	aBrowseEnt := {}

	cQuery := " SELECT * "
	cQuery += " FROM " + RetSQLName("SZF") + " SZF "
	cQuery += " WHERE SZF.ZF_FILIAL  = '" + xFilial("SZF")   + "' "
	cQuery += "   AND SZF.ZF_SEQENTR = '" + SZF->ZF_SEQENTR  + "' "
	cQuery += "   AND SZF.D_E_L_E_T_ = ' '"
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSZF,.F.,.T.)
	While !Eof()

		SC7->( dbSetOrder(1) )	// C7_FILIAL + C7_NUM + C7_ITEM + C7_SEQUEN
		SC7->( dbSeek(xFilial("SC7") + (cAliasSZF)->ZF_PEDIDO + (cAliasSZF)->ZF_ITPD ) )

		SB1->( dbSetOrder(1) )	// B1_FILIAL + B1_COD
		SB1->( dbSeek(xFilial("SB1") + (cAliasSZF)->ZF_PROD ) )

		nSaldo := 0
		
		cQuery := " SELECT SUM(ZF_QUANT) ZF_QUANT "
		cQuery += " FROM " + RetSQLName("SZF") + " SZF "
		cQuery += " WHERE SZF.ZF_FILIAL  = '" + xFilial("SZF") + "' "
		cQuery += "   AND SZF.ZF_PEDIDO  = '" + SC7->C7_NUM    + "' "
		cQuery += "   AND SZF.ZF_ITPD    = '" + SC7->C7_ITEM   + "' "
		cQuery += "   AND SZF.D_E_L_E_T_ = ' '"
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSZFS,.F.,.T.)
		If !Eof()

			nSaldo := SC7->C7_QUANT - (cAliasSZFS)->ZF_QUANT
		EndIf
		dbSelectArea(cAliasSZFS)
		dbCloseArea()

		Aadd( aBrowseEnt, {} )
		Aadd( Atail (aBrowseEnt), .T.						)	// 01 - Marcado ou Desmarcado
		Aadd( Atail (aBrowseEnt), (cAliasSZF)->ZF_ITPD		)	// 02 - Item do Pedido de Compra
		Aadd( Atail (aBrowseEnt), (cAliasSZF)->ZF_PROD		)	// 03 - Codigo do Produto
		Aadd( Atail (aBrowseEnt), SB1->B1_DESC				)	// 04 - Descricao do Produto
		Aadd( Atail (aBrowseEnt), SB1->B1_UM				)	// 05 - Unidade de Medida
		Aadd( Atail (aBrowseEnt), SC7->C7_QUANT				)	// 06 - Quantidade do Pedido de Compra
		Aadd( Atail (aBrowseEnt), nSaldo				 	)	// 07 - Saldo
		Aadd( Atail (aBrowseEnt), (cAliasSZF)->ZF_QUANT		)	// 08 - Quantidade Entregue
	
		dbSelectArea(cAliasSZF)
		dbSkip()
	EndDo
	dbSelectArea(cAliasSZF)
	dbCloseArea()

	If Len(aBrowseEnt) == 0

		A215INICIA()
	EndIf
Return ( Nil )
