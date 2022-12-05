#INCLUDE "protheus.ch"
/*
Jean Rehermann | JPC - 18/06/2011 - Gravação do pedido de comissionamento
Programa que efetua a criação de pedido de vendas de comissão quando o pedido referente a este faturamento
for do tipo externo (pedido de intermediação) referente à tarefa #1065 do portfólio.
Chamado pelo ponto de entrada M460FIM (fonte PE_M460FIM.PRW)
*/

User Function AUTA004

	Local _cNewNumPV   := ""
	Local _cProduto    := ""
	Local _lMsErroAuto := .F.
	Local _cPedido := SC5->C5_NUM
	Local _nTotFat := _nTotCom := 0
	Local _aCabec  := {}
	Local _aItens  := {}
	Local _aItem   := {}
	Local _aVend   := {}
	Local _cProd   := SuperGetMV("AUT_PROINT", ,"004604") // Produto referente à comissão
	Local _cTes    := SuperGetMV("AUT_TESINT", ,"508") // Tes de serviço

	Private	_aAreaXXX := GetArea()
	Private _aAreaSC5 := SC5->( GetArea() )
	Private _aAreaSC6 := SC6->( GetArea() )
	
	If SC5->C5_EXTERNO == "1"
	
		_cNewNumPV := GetSxeNum( "SC5", "C5_NUM" )

		For _nX := 1 To 5
			
			// [1] Código do Vendedor  [2] Percentual Original   [3] Novo Percentual
			aAdd( _aVend, { &("SC5->C5_VEND" + AllTrim( Str( _nX ) ) ), &("SC5->C5_COMIS" + AllTrim( Str( _nX ) ) ), 0 } )
			
			If !Empty( AllTrim( aTail( _aVend )[ 1 ] ) ) .And. aTail( _aVend )[ 2 ] == 0
				
				// Se o percentual no pedido estiver zerado para o vendedor, busco no cadastro deste vendedor.
				aTail( _aVend )[ 2 ] := Posicione( "SA3", 1, xFilial("SA3") + aTail( _aVend )[ 1 ], "A3_COMIS" )
			
			EndIf
	
		Next
		
		dbSelectArea("SC6")
		dbSetOrder(1)
		If dbSeek( xFilial("SC6") + SC5->C5_NUM )
		
			While !SC6->( Eof() ) .And. SC6->C6_FILIAL + SC6->C6_NUM == xFilial("SC6") + SC5->C5_NUM
				
				_aItem := {}
				_cProduto := IIf( Empty( _cProd ), SC6->C6_PRODUTO, _cProd )
	
				aAdd( _aItem, { "C6_FILIAL" , xFilial("SC6") , NIL } ) // Filial
				aAdd( _aItem, { "C6_NUM"    , _cNewNumPV     , NIL } ) // Número do Pedido
				aAdd( _aItem, { "C6_ITEM"   , SC6->C6_ITEM   , NIL } ) // Número do Item no Pedido
				aAdd( _aItem, { "C6_PRODUTO", _cProduto      , NIL } ) // Código do Produto
				aAdd( _aItem, { "C6_QTDVEN" , 1              , NIL } ) // Quantidade Vendida
				aAdd( _aItem, { "C6_PRCVEN" , SC6->C6_COMIAUT, NIL } ) // Preço Unitário Líquido
				aAdd( _aItem, { "C6_VALOR"  , SC6->C6_COMIAUT, NIL } ) // Valor Total do Item
				aAdd( _aItem, { "C6_ENTREG" , dDataBase      , NIL } ) // Data da Entrega
				aAdd( _aItem, { "C6_UM"     , SC6->C6_UM     , NIL } ) // Unidade de Medida Primária
				aAdd( _aItem, { "C6_TES"    , _cTes          , NIL } ) // Tipo de Entrada/Saida do Item
				aAdd( _aItem, { "C6_CLI"    , SC5->C5_FORNEXT, NIL } ) // Cliente
				aAdd( _aItem, { "C6_LOJA"   , SC5->C5_LOJAEXT, NIL } ) // Loja do Cliente
	
				_nTotCom += SC6->C6_COMIAUT  // Valor total da comissão da Automatech, ou seja, do pedido que será gerado.
				_nTotFat += SC6->C6_VALOR    // Valor total faturado contra o cliente, neste faturamento.
				
				aAdd( _aItens, _aItem )
				
				SC6->( dbSkip() )
			EndDo
		
		EndIf
		
		For _nX := 1 To 5
			If !Empty( AllTrim( _aVend[ _nX, 1 ] ) ) .And. _aVend[ _nX, 2 ] > 0
				// Calculando o valor de comissão devido, que é o percentual do vendedor sobre o total faturado.
				_ValComOrig :=  _nTotFat * (_aVend[ _nX, 2 ] / 100)
				// Calculando o novo percentual sobre a base deste pedido
				_nComis := ( _ValComOrig / _nTotCom ) * 100
				
				_aVend[ _nX, 3 ] := Round( _nComis, TamSX3("A3_COMIS")[ 2 ] )
			EndIf
		Next
		
		// Monta os dados para o cabeçalho do pedido
		aAdd( _aCabec, { "C5_FILIAL" , xFilial("SC5") , NIL } )
		aAdd( _aCabec, { "C5_NUM"    , _cNewNumPV     , NIL } )
		aAdd( _aCabec, { "C5_TIPO"   , "N"            , NIL } )
		aAdd( _aCabec, { "C5_CLIENTE", SC5->C5_FORNEXT, NIL } )
		aAdd( _aCabec, { "C5_LOJACLI", SC5->C5_LOJAEXT, NIL } )
		aAdd( _aCabec, { "C5_TIPOCLI", "F"            , NIL } )
		aAdd( _aCabec, { "C5_CONDPAG", SC5->C5_CONDPAG, NIL } )
		aAdd( _aCabec, { "C5_VEND1"  , _aVend[ 1, 1 ] , NIL } )
		aAdd( _aCabec, { "C5_VEND2"  , _aVend[ 2, 1 ] , NIL } )
		aAdd( _aCabec, { "C5_VEND3"  , _aVend[ 3, 1 ] , NIL } )
		aAdd( _aCabec, { "C5_VEND4"  , _aVend[ 4, 1 ] , NIL } )
		aAdd( _aCabec, { "C5_VEND5"  , _aVend[ 5, 1 ] , NIL } )
		aAdd( _aCabec, { "C5_COMIS1" , _aVend[ 1, 3 ] , NIL } )
		aAdd( _aCabec, { "C5_COMIS2" , _aVend[ 2, 3 ] , NIL } )
		aAdd( _aCabec, { "C5_COMIS3" , _aVend[ 3, 3 ] , NIL } )
		aAdd( _aCabec, { "C5_COMIS4" , _aVend[ 4, 3 ] , NIL } )
		aAdd( _aCabec, { "C5_COMIS5" , _aVend[ 5, 3 ] , NIL } )
		aAdd( _aCabec, { "C5_EMISSAO", dDataBase      , NIL } )
		aAdd( _aCabec, { "C5_TIPLIB" , "2"            , NIL } )
		aAdd( _aCabec, { "C5_TPFRETE", "C"            , NIL } )
	
		// Rotina automática para inclusão do pedido de vendas.
		MsExecAuto( { |x,y,z| Mata410( x, y, z ) }, _aCabec, _aItens, 3 ) 
	
		If !_lMsErroAuto
			ConfirmSX8() // Confirma o número do pedido
		Else
			If MsgYesNo("Ocorreu um problema na criação do pedido de comissão. Deseja exibir o erro?")
				MostraErro() // Exibe tela indicando qual o erro ocorrrido
			EndIf
			RollBackSX8() // Retorna o número para o controle do SXE
		EndIf
	
	EndIf
	
	RestArea( _aAreaSC6 )
	RestArea( _aAreaSC5 )
	RestArea( _aAreaXXX )

Return( Nil )