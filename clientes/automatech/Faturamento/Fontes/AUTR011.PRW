#INCLUDE "rwmake.ch"

/*/
Jean Rehermann - 09-02-12 - Relatorio de margens
AUTR011 - Relaciona os itens das notas fiscais de saida
/*/

User Function AUTR011

	Local cDesc1  := "Relatório com as margens de venda"
	Local cDesc2  := ""
	Local cDesc3  := ""
	Local cPict   := ""
	Local titulo  := "Relatório de Margens"
	Local Cabec1  := ""
	Local Cabec2  := ""
	Local imprime := .T.
	Local cPerg   := "AUTR011   "
	Local aOrd    := {}
	Local nLin    := 132	
	
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 132
	Private tamanho     := "G"
	Private nomeprog    := "AUTR011"
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1 }
	Private nLastKey    := 0
	Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "AUTR011"
	Private _cOrdem     := ""
	
   U_AUTOM628("AUTR011")

	// Tratamento das perguntas
	AjustaSX1( cPerg )
	If !Pergunte( cPerg, .T. )
		Return
	EndIf
	
	// Define o cabeçalho de acordo com o agrupamento
	Do Case
		Case mv_par19 == 1
			Cabec1 := "  Produto  Descrição                          |  Grupo  Descrição"
			Cabec2 := "  N. Fiscal  Série Item Pedido Item Cliente Loja Vendedor 1                Vendedor 2                Data Emissão  Margem"
			_cOrdem := " D2_COD"
		Case mv_par19 == 2
			Cabec1 := "  Grupo Descrição"
			Cabec2 := "  Produto               Descrição                       N. Fiscal  Série Item Pedido Item Cliente Loja Vendedor 1                Vendedor 2                Data Emissão  Margem"
			_cOrdem := " D2_GRUPO"
		Case mv_par19 == 3
			Cabec1 := "  Cliente  Loja  Nome"
			Cabec2 := "  Produto               Descrição                       Grupo N. Fiscal  Série Item Pedido Item  Vendedor 1                Vendedor 2                Data Emissão  Margem"
			_cOrdem := " D2_CLIENTE, D2_LOJA"
		Case mv_par19 == 4
			Cabec1 := "  N. Fiscal Série    Cliente  Loja  Nome"
			Cabec2 := "  Item Produto               Descrição                       Grupo Pedido Item  Vendedor 1                Vendedor 2                Data Emissão  Margem"
			_cOrdem := " D2_DOC, D2_SERIE, D2_ITEM"
		Case mv_par19 == 5
			Cabec1 := "  Vendedor Nome"
			Cabec2 := "  Produto               Descrição                       Grupo N. Fiscal  Série Item Pedido Item Cliente Loja Data Emissão  Margem"
			_cOrdem := " F2_VEND1"
	EndCase
	
	wnrel := SetPrint( "", NomeProg, "", @titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T. )

	If nLastKey == 27
		Return
	Endif

	SetDefault( aReturn, "" )

	If nLastKey == 27
	   Return
	Endif

	nTipo := If( aReturn[ 4 ] == 1, 15, 18 )

	RptStatus( {|| RunReport( Cabec1, Cabec2, Titulo, nLin ) }, Titulo )
	
Return

/* Função principal */
Static Function RunReport( Cabec1, Cabec2, Titulo, nLin )

	Local _cSql := ""
	

	_cSql := "SELECT D2_COD, D2_GRUPO, D2_CLIENTE, D2_LOJA, D2_PEDIDO, D2_ITEMPV, D2_ITEM, D2_DOC, D2_SERIE, D2_EMISSAO, D2_QTGMRG, "
	_cSql += " F2_VEND1, F2_VEND2, F2_TIPO, B1_DESC, BM_DESC, A1_NOME FROM "
	
	_cSql += RetSqlName("SD2") +" SD2, "
	_cSql += RetSqlName("SF2") +" SF2, "
	_cSql += RetSqlName("SB1") +" SB1, "
	_cSql += RetSqlName("SBM") +" SBM, "
	_cSql += RetSqlName("SA1") +" SA1, "
	_cSql += RetSqlName("SF4") +" SF4 "
	
	_cSql += "WHERE "
	
	_cSql += "D2_COD     BETWEEN '"+ mv_par01 +"' AND '"+ mv_par02 +"' AND "
	_cSql += "D2_GRUPO   BETWEEN '"+ mv_par03 +"' AND '"+ mv_par04 +"' AND "
	_cSql += "D2_CLIENTE BETWEEN '"+ mv_par05 +"' AND '"+ mv_par07 +"' AND "
	_cSql += "D2_LOJA    BETWEEN '"+ mv_par06 +"' AND '"+ mv_par08 +"' AND "
	_cSql += "D2_PEDIDO  BETWEEN '"+ mv_par09 +"' AND '"+ mv_par10 +"' AND "
	_cSql += "D2_DOC     BETWEEN '"+ mv_par11 +"' AND '"+ mv_par13 +"' AND "
	_cSql += "D2_SERIE   BETWEEN '"+ mv_par12 +"' AND '"+ mv_par14 +"' AND "
	_cSql += "D2_EMISSAO BETWEEN '"+ DtoS( mv_par15 ) +"' AND '"+ DtoS( mv_par16 ) +"' AND "
	_cSql += "( F2_VEND1 BETWEEN '"+ mv_par17 +"' AND '"+ mv_par18 +"' OR "
	_cSql += " F2_VEND2  BETWEEN '"+ mv_par17 +"' AND '"+ mv_par18 +"' ) AND "
	_cSql += " F4_DUPLIC = 'S' AND "
	_cSql += " F2_TIPO   = 'N' AND " // Jean Rehermann | Solutio - 08/01/2013 - Ajuste feito para zerados

	_cSql += " D2_FILIAL  = F2_FILIAL   AND "
	_cSql += " D2_DOC     = F2_DOC      AND "
	_cSql += " D2_SERIE   = F2_SERIE    AND "
	_cSql += " D2_CLIENTE = F2_CLIENTE  AND "
	_cSql += " D2_LOJA    = F2_LOJA     AND "
	_cSql += " D2_COD     = B1_COD      AND "
	_cSql += " D2_TES     = F4_CODIGO   AND "
	_cSql += " D2_GRUPO   = BM_GRUPO    AND "
	_cSql += " F2_CLIENTE = A1_COD      AND "
	_cSql += " F2_LOJA    = A1_LOJA     AND "

	_cSql += " D2_FILIAL  = '"+ xFilial("SD2") +"' AND "
	_cSql += " B1_FILIAL  = '"+ xFilial("SB1") +"' AND "
	_cSql += " BM_FILIAL  = '"+ xFilial("SBM") +"' AND "
	_cSql += " A1_FILIAL  = '"+ xFilial("SA1") +"' AND "

	_cSql += " SD2.D_E_L_E_T_ = '' AND "
	_cSql += " SF2.D_E_L_E_T_ = '' AND "
	_cSql += " SB1.D_E_L_E_T_ = '' AND "
	_cSql += " SBM.D_E_L_E_T_ = '' AND "
	_cSql += " SA1.D_E_L_E_T_ = '' "
	
	_cSql += " GROUP BY D2_COD, D2_GRUPO, D2_CLIENTE, D2_LOJA, D2_PEDIDO, D2_ITEMPV, D2_ITEM, D2_DOC, D2_SERIE, D2_EMISSAO, D2_QTGMRG, "
	_cSql += " F2_VEND1, F2_VEND2, F2_TIPO, B1_DESC, BM_DESC, A1_NOME "

	// Define a ordem dos registros
	Do Case
		Case mv_par20 == 1
			If mv_par19 != 1
				_cOrdem += ", D2_COD"
			EndIf
		Case mv_par20 == 2
			If mv_par19 != 2
				_cOrdem += ", D2_GRUPO"
			EndIf
		Case mv_par20 == 3
			If mv_par19 != 3
				_cOrdem += ", D2_CLIENTE, D2_LOJA"
			EndIf
		Case mv_par20 == 4
			If mv_par19 != 4
				_cOrdem += ", D2_DOC, D2_SERIE, D2_ITEM"
			EndIf
		Case mv_par20 == 5
			If mv_par19 != 5
				_cOrdem += ", F2_VEND1"
			EndIf
	EndCase

	_cSql += " ORDER BY "+ _cOrdem
	
	MemoWrite( "AUTR011.TXT", _cSql )
	
	If Select("TRBQTN") > 0
		TRBQTN->( dbCloseArea() )
	EndIf

	_cSql := ChangeQuery( _cSql )
	dbUseArea(.T.,"TOPCONN", TCGenQry(,,_cSql),"TRBQTN", .F., .T.)

	// Direciona para o programa de acordo com o agrupamento selecionado
	Do Case
		Case mv_par19 == 1
			Aut11Pro( Cabec1, Cabec2, Titulo, nLin ) // Produto
		Case mv_par19 == 2
			Aut11Gru( Cabec1, Cabec2, Titulo, nLin ) // Grupo de Produto
		Case mv_par19 == 3
			Aut11Cli( Cabec1, Cabec2, Titulo, nLin ) // Cliente
		Case mv_par19 == 4
			Aut11Not( Cabec1, Cabec2, Titulo, nLin ) // Nota + Série
		Case mv_par19 == 5
			Aut11Ven( Cabec1, Cabec2, Titulo, nLin ) // Vendedor
	EndCase
	
	TRBQTN->( dbCloseArea() )
	
	SET DEVICE TO SCREEN

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

// Agrupa por Produto
Static Function Aut11Pro( Cabec1, Cabec2, Titulo, nLin ) // Produto
    
	Local _cProd    := ""
	Local _cCabPro  := ""
	Local _cItemPro := ""
	Local _lPrim    := .T.
	
	While !TRBQTN->( EoF() )
		
		_cCabPro  := ""
		_cItemPro := ""
		
		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
			nLin := 9
		Endif

		If TRBQTN->D2_COD != _cProd
			
			_cCabPro := AllTrim( TRBQTN->D2_COD )
			_cCabPro += " "+ TRBQTN->B1_DESC
			_cCabPro += "  | "+ TRBQTN->D2_GRUPO
			_cCabPro += " "+ TRBQTN->BM_DESC
			
			If !_lPrim
				nLin += 3
			EndIf

			@nLin, 02 PSAY _cCabPro

			_cProd := TRBQTN->D2_COD
			_lPrim := .F.
			nLin++
		EndIf
		
		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
			nLin := 9
		Endif

		_cItemPro := TRBQTN->D2_DOC
		_cItemPro += "    "+ TRBQTN->D2_SERIE
		_cItemPro += "  "+ TRBQTN->D2_ITEM
		_cItemPro += "  "+ TRBQTN->D2_PEDIDO
		_cItemPro += "  "+ TRBQTN->D2_ITEMPV
		_cItemPro += "   "+ TRBQTN->D2_CLIENTE
		_cItemPro += "  "+ TRBQTN->D2_LOJA
		_cItemPro += " "+ Posicione( "SA3", 1, xFilial("SA3") + TRBQTN->F2_VEND1, "A3_NREDUZ" )
		_cItemPro += " "+ Posicione( "SA3", 1, xFilial("SA3") + TRBQTN->F2_VEND2, "A3_NREDUZ" )
		_cItemPro += "  "+ DtoC( StoD( TRBQTN->D2_EMISSAO ) )
		_cItemPro += "   "+ Transform( TRBQTN->D2_QTGMRG, PesqPict("SD2", "D2_QTGMRG") )

		nLin++
		
		@nLin, 02 PSAY _cItemPro
		
		TRBQTN->( dbSkip() )
	End
	
Return

// Agrupa por Grupo de Produto
Static Function Aut11Gru( Cabec1, Cabec2, Titulo, nLin ) // Grupo de Produto

	Local _cGrupo   := ""
	Local _cCabGru  := ""
	Local _cItemGru := ""
	Local _lPrim    := .T.
	
	While !TRBQTN->( EoF() )
		
		_cCabGru  := ""
		_cItemGru := ""
		
		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
			nLin := 9
		Endif

		If TRBQTN->D2_GRUPO != _cGrupo
			
			_cCabGru := TRBQTN->D2_GRUPO
			_cCabGru += " "+ TRBQTN->BM_DESC
			
			If !_lPrim
				nLin += 3
			EndIf

			@nLin, 02 PSAY _cCabGru

			_cGrupo := TRBQTN->D2_GRUPO
			_lPrim := .F.
			nLin++
		EndIf
		
		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
			nLin := 9
		Endif

		_cItemGru := SubStr( TRBQTN->D2_COD, 1, 20 )
		_cItemGru += "  "+ TRBQTN->B1_DESC
		_cItemGru += "  "+ TRBQTN->D2_DOC
		_cItemGru += "    "+ TRBQTN->D2_SERIE
		_cItemGru += "  "+ TRBQTN->D2_ITEM
		_cItemGru += "  "+ TRBQTN->D2_PEDIDO
		_cItemGru += "  "+ TRBQTN->D2_ITEMPV
		_cItemGru += "   "+ TRBQTN->D2_CLIENTE
		_cItemGru += "  "+ TRBQTN->D2_LOJA
		_cItemGru += " "+ Posicione( "SA3", 1, xFilial("SA3") + TRBQTN->F2_VEND1, "A3_NREDUZ" )
		_cItemGru += " "+ Posicione( "SA3", 1, xFilial("SA3") + TRBQTN->F2_VEND2, "A3_NREDUZ" )
		_cItemGru += "  "+ DtoC( StoD( TRBQTN->D2_EMISSAO ) )
		_cItemGru += "   "+ Transform( TRBQTN->D2_QTGMRG, PesqPict("SD2", "D2_QTGMRG") )

		nLin++
		
		@nLin, 02 PSAY _cItemGru
		
		TRBQTN->( dbSkip() )
	End

Return

// Agrupa por Cliente + Loja
Static Function Aut11Cli( Cabec1, Cabec2, Titulo, nLin ) // Cliente

	Local _cCli     := ""
	Local _cCabCli  := ""
	Local _cItemCli := ""
	Local _lPrim    := .T.
	
	While !TRBQTN->( EoF() )
		
		_cCabCli  := ""
		_cItemCli := ""
		
		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
			nLin := 9
		Endif

		If TRBQTN->D2_CLIENTE + TRBQTN->D2_LOJA != _cCli
			
			_cCabCli := TRBQTN->D2_CLIENTE
			_cCabCli += " / "+ TRBQTN->D2_LOJA
			_cCabCli += " - "+ TRBQTN->A1_NOME
			
			If !_lPrim
				nLin += 3
			EndIf

			@nLin, 02 PSAY _cCabCli

			_cCli := TRBQTN->D2_CLIENTE + TRBQTN->D2_LOJA
			_lPrim := .F.
			nLin++
		EndIf
		
		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
			nLin := 9
		Endif

		_cItemCli := SubStr( TRBQTN->D2_COD, 1, 20 )
		_cItemCli += "  "+ TRBQTN->B1_DESC
		_cItemCli += "   "+ TRBQTN->D2_GRUPO
		_cItemCli += " "+ TRBQTN->D2_DOC
		_cItemCli += "    "+ TRBQTN->D2_SERIE
		_cItemCli += "  "+ TRBQTN->D2_ITEM
		_cItemCli += "  "+ TRBQTN->D2_PEDIDO
		_cItemCli += "  "+ TRBQTN->D2_ITEMPV
		_cItemCli += "   "+ Posicione( "SA3", 1, xFilial("SA3") + TRBQTN->F2_VEND1, "A3_NREDUZ" )
		_cItemCli += " "+ Posicione( "SA3", 1, xFilial("SA3") + TRBQTN->F2_VEND2, "A3_NREDUZ" )
		_cItemCli += "  "+ DtoC( StoD( TRBQTN->D2_EMISSAO ) )
		_cItemCli += "   "+ Transform( TRBQTN->D2_QTGMRG, PesqPict("SD2", "D2_QTGMRG") )

		nLin++
		
		@nLin, 02 PSAY _cItemCli
		
		TRBQTN->( dbSkip() )
	End

Return

// Agrupa por Nota + Série
Static Function Aut11Not( Cabec1, Cabec2, Titulo, nLin ) // Nota + Série

	Local _cNota   := ""
	Local _cCabNf  := ""
	Local _cItemNf := ""
	Local _lPrim   := .T.
	
	While !TRBQTN->( EoF() )
		
		_cCabNf  := ""
		_cItemNf := ""
		
		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
			nLin := 9
		Endif

		If TRBQTN->D2_DOC + TRBQTN->D2_SERIE + TRBQTN->D2_CLIENTE + TRBQTN->D2_LOJA != _cNota
			
			_cCabNf := TRBQTN->D2_DOC
			_cCabNf += "    "+ TRBQTN->D2_SERIE
			_cCabNf += " | "+ TRBQTN->D2_CLIENTE
			_cCabNf += " / "+ TRBQTN->D2_LOJA
			_cCabNf += " - "+ TRBQTN->A1_NOME
			
			If !_lPrim
				nLin += 3
			EndIf

			@nLin, 02 PSAY _cCabNf

			_cNota := TRBQTN->D2_DOC + TRBQTN->D2_SERIE + TRBQTN->D2_CLIENTE + TRBQTN->D2_LOJA
			_lPrim := .F.
			nLin++
		EndIf
		
		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
			nLin := 9
		Endif

		_cItemNf := TRBQTN->D2_ITEM
		_cItemNf += "  "+ SubStr( TRBQTN->D2_COD, 1, 20 )
		_cItemNf += "  "+ TRBQTN->B1_DESC
		_cItemNf += "   "+ TRBQTN->D2_GRUPO
		_cItemNf += "  "+ TRBQTN->D2_PEDIDO
		_cItemNf += "  "+ TRBQTN->D2_ITEMPV
		_cItemNf += "   "+ Posicione( "SA3", 1, xFilial("SA3") + TRBQTN->F2_VEND1, "A3_NREDUZ" )
		_cItemNf += " "+ Posicione( "SA3", 1, xFilial("SA3") + TRBQTN->F2_VEND2, "A3_NREDUZ" )
		_cItemNf += "  "+ DtoC( StoD( TRBQTN->D2_EMISSAO ) )
		_cItemNf += "   "+ Transform( TRBQTN->D2_QTGMRG, PesqPict("SD2", "D2_QTGMRG") )

		nLin++
		
		@nLin, 02 PSAY _cItemNf
		
		TRBQTN->( dbSkip() )
	End

Return

// Agrupa por Vendedor
Static Function Aut11Ven( Cabec1, Cabec2, Titulo, nLin ) // Vendedor

	Local _cVend    := "XXXX"
	Local _cCabVen  := ""
	Local _cItemVen := ""
	Local _lPrim    := .T.
	Local _aVend    := {}
	
	While !TRBQTN->( EoF() )
		
		If !Empty( AllTrim( TRBQTN->F2_VEND1 + TRBQTN->F2_VEND2 ) )
			
			If !Empty( AllTrim( TRBQTN->F2_VEND1 ) )
				aAdd( _aVend, { TRBQTN->F2_VEND1, TRBQTN->D2_COD, TRBQTN->B1_DESC, TRBQTN->D2_GRUPO, TRBQTN->D2_DOC, TRBQTN->D2_SERIE, TRBQTN->D2_ITEM, TRBQTN->D2_PEDIDO, TRBQTN->D2_ITEMPV, TRBQTN->D2_EMISSAO, TRBQTN->D2_QTGMRG, TRBQTN->D2_CLIENTE, TRBQTN->D2_LOJA } )
			EndIf
			
			If !Empty( AllTrim( TRBQTN->F2_VEND2 ) )
				aAdd( _aVend, { TRBQTN->F2_VEND2, TRBQTN->D2_COD, TRBQTN->B1_DESC, TRBQTN->D2_GRUPO, TRBQTN->D2_DOC, TRBQTN->D2_SERIE, TRBQTN->D2_ITEM, TRBQTN->D2_PEDIDO, TRBQTN->D2_ITEMPV, TRBQTN->D2_EMISSAO, TRBQTN->D2_QTGMRG, TRBQTN->D2_CLIENTE, TRBQTN->D2_LOJA } )
			EndIf
			
		Else
			aAdd( _aVend, { "", TRBQTN->D2_COD, TRBQTN->B1_DESC, TRBQTN->D2_GRUPO, TRBQTN->D2_DOC, TRBQTN->D2_SERIE, TRBQTN->D2_ITEM, TRBQTN->D2_PEDIDO, TRBQTN->D2_ITEMPV, TRBQTN->D2_EMISSAO, TRBQTN->D2_QTGMRG, TRBQTN->D2_CLIENTE, TRBQTN->D2_LOJA } )
		EndIf
		
		TRBQTN->( dbSkip() )
	End
	
	If Len( _aVend ) > 0
	
		// Define a ordem dos registros
		// Ordenando por vendedor + Ordem
		Do Case
			Case mv_par20 == 1
				aSort( _aVend,,,{ |x,y| x[ 1 ] + x[ 2 ] < y[ 1 ] + y[ 2 ] } )
			Case mv_par20 == 2
				aSort( _aVend,,,{ |x,y| x[ 1 ] + x[ 4 ] < y[ 1 ] + y[ 4 ] } )
			Case mv_par20 == 3
				aSort( _aVend,,,{ |x,y| x[ 1 ] + x[ 12 ] + x[ 13 ] < y[ 1 ]  + x[ 12 ] + x[ 13 ] } )
			Case mv_par20 == 4
				aSort( _aVend,,,{ |x,y| x[ 1 ] + x[ 5 ] + x[ 6 ] < y[ 1 ]  + x[ 5 ] + x[ 6 ] } )
			Case mv_par20 == 5
				aSort( _aVend,,,{ |x,y| x[ 1 ] < y[ 1 ] } )
		EndCase

		For _nX := 1 To Len( _aVend )
	
			_cCabVen  := ""
			_cItemVen := ""
			
			If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
				nLin := 9
			Endif
	
			If _aVend[ _nX, 1 ] != _cVend
				
				If Empty( AllTrim( _aVend[ _nX, 1 ] ) )
					_cCabVen := "Sem Vendedor Informado"
				Else
					_cCabVen := _aVend[ _nX, 1 ]
					_cCabVen += " - "+ Posicione( "SA3", 1, xFilial("SA3") + _aVend[ _nX, 1 ], "A3_NOME" )
				EndIf
				
				If !_lPrim
					nLin += 3
				EndIf
	
				@nLin, 02 PSAY _cCabVen
	
				_cVend := _aVend[ _nX, 1 ]
				_lPrim := .F.
				nLin++
			EndIf
			
			If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo )
				nLin := 9
			Endif
	
			_cItemVen := SubStr( _aVend[ _nX, 2 ], 1, 20 )
			_cItemVen += "  "+ _aVend[ _nX, 3 ]
			_cItemVen += "   "+ _aVend[ _nX, 4 ]
			_cItemVen += " "+ _aVend[ _nX, 5 ]
			_cItemVen += "    "+ _aVend[ _nX, 6 ]
			_cItemVen += "  "+ _aVend[ _nX, 7 ]
			_cItemVen += "  "+ _aVend[ _nX, 8 ]
			_cItemVen += "  "+ _aVend[ _nX, 9 ]
			_cItemVen += "   "+ _aVend[ _nX, 12 ]
			_cItemVen += "  "+ _aVend[ _nX, 13 ]
			_cItemVen += "  "+ DtoC( StoD( _aVend[ _nX, 10 ] ) )
			_cItemVen += "   "+ Transform( _aVend[ _nX, 11 ], PesqPict("SD2", "D2_QTGMRG") )
			
			nLin++
			
			@nLin, 02 PSAY _cItemVen
			
		Next
	
	EndIf
	
Return


// Cria as perguntas para o relatório
Static Function AjustaSX1( cPerg )

	PutSx1( cPerg,"01","Do Produto ?    ","","","mv_ch1","C",30,00,00,"G","","SB1"   ,"","","MV_PAR01","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg,"02","Até o Produto ? ","","","mv_ch2","C",30,00,00,"G","","SB1"   ,"","","MV_PAR02","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg,"03","Do Grupo ?      ","","","mv_ch3","C",04,00,00,"G","","SBM"   ,"","","MV_PAR03","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg,"04","Até o Grupo ?   ","","","mv_ch4","C",04,00,00,"G","","SBM"   ,"","","MV_PAR04","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg,"05","Do Cliente ?    ","","","mv_ch5","C",06,00,00,"G","","SA1"   ,"","","MV_PAR05","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg,"06","Da Loja ?       ","","","mv_ch6","C",03,00,00,"G","",""      ,"","","MV_PAR06","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg,"07","Até o Cliente ? ","","","mv_ch7","C",06,00,00,"G","","SA1"   ,"","","MV_PAR07","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg,"08","Até a loja ?    ","","","mv_ch8","C",03,00,00,"G","",""      ,"","","MV_PAR08","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg,"09","Do Pedido ?     ","","","mv_ch9","C",06,00,00,"G","","SC5"   ,"","","MV_PAR09","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg,"10","Até o Pedido ?  ","","","mv_chA","C",06,00,00,"G","","SC5"   ,"","","MV_PAR10","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg,"11","Da Nota ?       ","","","mv_chB","C",09,00,00,"G","","SF2EMB","","","MV_PAR11","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg,"12","Da Série Nf ?   ","","","mv_chC","C",03,00,00,"G","",""      ,"","","MV_PAR12","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg,"13","Até a Nota ?    ","","","mv_chD","C",09,00,00,"G","","SF2EMB","","","MV_PAR13","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg,"14","Até a Série Nf ?","","","mv_chE","C",03,00,00,"G","",""      ,"","","MV_PAR14","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg,"15","Da Emissão ?    ","","","mv_chF","D",08,00,00,"G","",""      ,"","","MV_PAR15","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg,"16","Até a Emissão ? ","","","mv_chG","D",08,00,00,"G","",""      ,"","","MV_PAR16","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg,"17","Do Vendedor ?   ","","","mv_chH","C",06,00,00,"G","","SA3"   ,"","","MV_PAR17","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg,"18","Até o Vendedor ?","","","mv_chI","C",06,00,00,"G","","SA3"   ,"","","MV_PAR18","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg,"19","Agrupar Por ?   ","","","mv_chJ","C",01,00,00,"C","",""      ,"","","MV_PAR19","Produto" ,"","","","Grupo de Produto","","","Cliente/Loja","","","Nota Fiscal","","","Vendedor","","","","","","")
	PutSx1( cPerg,"20","Ordenar Por ?   ","","","mv_chK","C",01,00,00,"C","",""      ,"","","MV_PAR20","Produto" ,"","","","Grupo de Produto","","","Cliente/Loja","","","Nota Fiscal","","","Vendedor","","","","","","")

Return
