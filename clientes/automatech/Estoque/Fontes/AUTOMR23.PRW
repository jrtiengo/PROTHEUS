#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR23.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 21/03/2012                                                          *
// Objetivo..: Impress�o Listagem de Separa��o         	                           *
//**********************************************************************************

User Function AUTOMR23(_Pedido)

    Local cQuery       := ""
	Local aStru        := {}
	Local _cPedAtu     := ""
	Local _lPrimeiro   := .T.
    Local cSql         := ""
    Local nContador    := 0
    Local xLinhas      := 0
    Local cTexto1 	   := ""
    Local cTexto2      := ""
    Local dData        := ""
    Local cComentario  := ""
    Local nProdutos    := 0
    Local nServicos    := 0
    Local cCondicao    := ""
    Local nFonte       := 0
    Local lExiste      := .F.
    Local cCodigos     := ""
    Local cNomeCliente := ""
    Local cEndereco    := ""
    Local cCidade      := ""
    Local cEstado      := ""
    Local cNomeTransp  := ""
    Local cAtendimento := ""
    Local nAdicional   := 15
    Local cEntresi     := ""
    Local _nLin        := 0
    Local nDifLinha    := 0
    
	Private aObs       := {}
	Private cObs       := ""
	Private _nQuant    := 0
	Private _nTot      := 0
	Private _nIpi      := 0
	Private _nTamLin   := 80
	Private _nLimVert  := 3500
	Private _nVia      := 1
	Private _nPagina   := 1
	Private _nIniLin   := 0
	Private _nLin      := 0
	Private _nCotDia   := 1
	Private _dCotDia   := DtoS( dDataBase )
	Private _cPrevisao := ""
	Private _cPrazoPag := ""
	Private _nMoeda    := 1
	Private oPrint, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont30

    U_AUTOM628("AUTOMR23")

    // Pesquisa o Nome do Cliente do Pedido de Venda
    If Select("T_CLIENTE") > 0
       T_CLIENTE->( dbCloseArea() )
    EndIf

    cSql := ""
    cSql := "SELECT A.C5_CLIENTE, "
    cSql += "       A.C5_LOJACLI, "
    cSql += "       B.A1_NOME   , "
    cSql += "       B.A1_END    , "
    cSql += "       B.A1_MUN    , "
    cSql += "       B.A1_EST      "
    cSql += "  FROM " + RetSqlName("SC5") + " A, "
    cSql += "       " + RetSqlName("SA1") + " B  "
    cSql += " WHERE A.C5_NUM       = '" + Alltrim(_Pedido)   + "'"
    cSql += "   AND A.R_E_C_D_E_L_ = ''"
    cSql += "   AND A.C5_CLIENTE   = B.A1_COD "
    cSql += "   AND A.C5_LOJACLI   = B.A1_LOJA"
    
    cSql := ChangeQuery( cSql )
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )

    cNomeCliente := T_CLIENTE->A1_NOME
    cEndereco    := T_CLIENTE->A1_END
    cCidade      := T_CLIENTE->A1_MUN
    cEstado      := T_CLIENTE->A1_EST

	// Cria o objeto de impressao
	oPrint := TmsPrinter():New()
	
	// Orienta��o da p�gina
	//oPrint:SetLandScape() // Para Paisagem
	oPrint:SetPortrait()    // Para Retrato
	
	// Tamanho da p�gina na impress�o
	//oPrint:SetPaperSize(8) // A3
	//oPrint:SetPaperSize(1) // Carta
	oPrint:SetPaperSize(9)   // A4
	
	// Cria os objetos de fontes que serao utilizadas na impressao do relatorio
	oFont06   := TFont():New( "Arial",,06,,.f.,,,,.f.,.f. )
	oFont08   := TFont():New( "Arial",,08,,.f.,,,,.f.,.f. )
	oFont08b  := TFont():New( "Arial",,08,,.t.,,,,.f.,.f. )
	oFont09   := TFont():New( "Arial",,09,,.f.,,,,.f.,.f. )
	oFont09b  := TFont():New( "Arial",,09,,.t.,,,,.f.,.f. )
	oFont10   := TFont():New( "Arial",,10,,.f.,,,,.f.,.f. )
	oFont10b  := TFont():New( "Arial",,10,,.t.,,,,.f.,.f. )
	oFont12   := TFont():New( "Arial",,12,,.f.,,,,.f.,.f. )
	oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )
	oFont14b  := TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
	oFont16b  := TFont():New( "Arial",,16,,.t.,,,,.f.,.f. )
	oFont20b  := TFont():New( "Arial",,20,,.t.,,,,.f.,.f. )
	oFont30   := TFont():New( "Courier New",,8,,.t.,,,,.f.,.f. )   

	// Pesquisa o nome da Empresa/Filial para o cabecalho
	SM0->( DbSeek( cEmpAnt + cFilAnt ) )

    _nLin := 60

    // In�cio do relat�rio
    oPrint:StartPage()
	
    oPrint:Line( _nLin, 0100, _nLin, 2300 )   
    _nLin += 30

    // Logotipo e identifica��o do pedido
    oPrint:SayBitmap( _nLin, 0150, "logoautoma.bmp", 0700, 0200 )
    _nLin += 90
    
    oPrint:Say( _nLin, 0990, "LISTA DE SEPARA��O", oFont20b  )
    _nLin += 120

    oPrint:Line( _nLin, 0100, _nLin, 2300 )

    _nLin += 50
        
    oPrint:Say( _nLin, 0150, "PEDIDO N�", oFont12  )
    oPrint:Say( _nLin, 0690, "Cliente:" , oFont12  )

    _nLin -= 20

    oPrint:Say( _nLin, 0380, _Pedido     , oFont20b )
    oPrint:Say( _nLin, 0870, cNomeCliente, oFont16b )

    _nLin += 90
    oPrint:Say( _nLin, 0870, cEndereco, oFont16b )

    _nLin += 90
    oPrint:Say( _nLin, 0870, Alltrim(cCidade) + "/" + Alltrim(cEstado), oFont16b )

    _nLin += 90
    oPrint:Line( _nLin, 0100, _nLin, 2300 )
    _nLin += 30    

    oPrint:Say( _nLin, 0990, "P R O D U T O S", oFont16b  )
    _nLin += 90
    oPrint:Line( _nLin, 0100, _nLin, 2300 )

    nVertical := _nLin

    _nLin += 50    

    oPrint:Say( _nLin, 0125, "C�digo"                , oFont12b  )
    oPrint:Say( _nLin, 0500, "Descri��o dos Produtos", oFont12b  )
    oPrint:Say( _nLin, 1700, "Qtd"                   , oFont12b  )
    oPrint:Say( _nLin, 1890, "Lote"                  , oFont12b  )
    oPrint:Say( _nLin, 2090, "N� S�rie"              , oFont12b  )

    _nLin += 90
    oPrint:Line( _nLin, 0100, _nLin, 2300 )
    _nLin += 30    

    // Seleciona os produtos do pedido de venda informado
    If Select("T_PRODUTOS") > 0
       T_PRODUTOS->( dbCloseArea() )
    EndIf

    cSql := ""    
    cSql := "SELECT A.C6_PRODUTO, "
    cSql += "       A.C6_QTDVEN , "
    cSql += "       A.C6_UM     , "
    cSql += "       B.B1_DESC   , "
    cSql += "       B.B1_DAUX     "
    cSql += "  FROM " + RetSqlName("SC6") + " A, "
    cSql += "       " + RetSqlName("SB1") + " B  "
    cSql += "  WHERE A.C6_NUM       = '" + Alltrim(_Pedido) + "'"
    cSql += "    AND A.R_E_C_D_E_L_ = ''"
    cSql += "    AND A.C6_PRODUTO   = B.B1_COD"
    
    cSql := ChangeQuery( cSql )
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )
    
    T_PRODUTOS->( DbGoTop() )

    nDifLinha := 2150
    
    WHILE !T_PRODUTOS->( EOF() )
       oPrint:Say( _nLin, 0125, T_PRODUTOS->C6_PRODUTO  , oFont10  )
       oPrint:Say( _nLin, 0500, Alltrim(T_PRODUTOS->B1_DESC) + " " + Alltrim(T_PRODUTOS->B1_DAUX), oFont10  )    
       oPrint:Say( _nLin, 1570, STR(T_PRODUTOS->C6_QTDVEN) + "   " + T_PRODUTOS->C6_UM , oFont10  )    
       _nLin     += 60
       nDifLinha := nDifLinha - 60
       T_PRODUTOS->( DbSkip() )
    ENDDO   

    _nLin := _nLin + 30

    oPrint:Line( _nLin, 0100, _nLin, 2300 )
    oPrint:Line( nVertical, 0480, _nLin, 0480 )
    oPrint:Line( nVertical, 1600, _nLin, 1600 )
    oPrint:Line( nVertical, 1850, _nLin, 1850 )
    oPrint:Line( nVertical, 2000, _nLin, 2000 )

    _nLin := _nLin + 30

    // Pesquisa e imprime a observa��o do atendimento do Call Center
    If Select("T_OBSERVA") > 0
       T_OBSERVA->( dbCloseArea() )
    EndIf

    cSql := ""
    cSql := "SELECT A.UA_CODOBS, "
    cSql += "       B.YP_TEXTO   "
    cSql += "  FROM " + RetSqlName("SUA") + " A, "
    cSql += "       " + RetSqlName("SYP") + " B  "
    cSql += " WHERE A.UA_NUMSC5 = '" + Alltrim(_Pedido) + "'"
    cSql += "   AND A.UA_CODOBS = B.YP_CHAVE"
    
    cSql := ChangeQuery( cSql )
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OBSERVA", .T., .T. )

    If !T_OBSERVA->( EOF() )
       WHILE !T_OBSERVA->( EOF() )
          oPrint:Say( _nLin, 0150, Strtran(T_OBSERVA->YP_TEXTO, "\13\10", "")  , oFont10  )
          _nLin     += 60
          nDifLinha := nDifLinha - 60
          T_OBSERVA->( DbSkip() )
       ENDDO   
    Endif

    _nLin := _nLin + nDifLinha

    // Imprime o quadro de Peso/Qtd Caixas e Experdido Por
    oPrint:Line( _nLin, 0100, _nLin, 2300 )
    _nLin := _nLin + 50
    oPrint:Say( _nLin, 0130, "Data                        Hora                 Peso           Qtd CX         Embalado por", oFont16b)
    _nLin := _nLin + 100
    oPrint:Say( _nLin, 0130, "___/___/____         ____:____        ________     ________     ______________", oFont16b)
    _nLin += 100

    oPrint:Line( _nLin, 0100, _nLin, 2300 )

    oPrint:Line( 060, 0100, _nLin, 0100 )
    oPrint:Line( 060, 2300, _nLin, 2300 )

 	oPrint:Preview()
	
	MS_FLUSH()

Return .T.