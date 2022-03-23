#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "Totvs.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"


//**********************************************************************************
// MARCHER                                                                         *
// ------------------------------------------------------------------------------- *
// Referencia: MARR003.PRW                                                         *
// Parâmetros: [_NumPed = NumPedido];[lPDF = gerapdf]                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Márcio Borges                                                       *
// Data......: 27/10/2011                                                          *
// Objetivo..: Impressão do Pedido de Compra em PDF e envio por email para Fornec. *
//**********************************************************************************
User Function MARR003(_NumPed,lPDF)

	Local lAdjustToLegacy := .T. // Se .T. recalcula as coordenadas para manter o legado de proporções com a classe TMSPrinter. Default é .T.IMPORTANTE: Este cálculos não funcionam corretamente quando houver retângulos do tipo BOX e FILLRECT no relatório, podendo haver distorções de algumas pixels o que acarretará no encavalamento dos retângulos no momento da impressão.
	Local lDisableSetup  := .T.
	Local cLocal         := GetTempPath()
	Local cFilePrint 	 := ""
	Local lTReport 		 := .T.


	Local cPerg    := "MARR003"
	Local cQuery   := ""
	Local aStru    := {}
	Local _cPedAtu := ""
	Local _lPrimeiro := .T.

	///////
	Local nViasImp 	:= 0
	Local x 		:= 0

	Private aObs        := {}
	Private cObs        := ""
	Private _nQuant     := 0
	Private _nTot       := 0
	Private _nIpi       := 0
	Private _nRetido    := 0
	Private _nFrete     := 0
	Private _nDfinan    := 0
	Private nNumeroPro  := 0  //Quantidade de produtos a serem impressos no pedido atual
	Private nMaxQtdProd := 45
	Private __Vertical  := 0
	Private nContar     := 0
	Private _nTamLin    := 50 // Tamanho da Linha Em Pixel
	Private _nLimVert   := 3900//3500
	Private _nVia       := 1
	Private _nPagina    := 1
	Private _nIniLin    := 0
	Private _nLin       := 0
	Private _nCotDia    := 1
	Private _dCotDia    := DtoS( dDataBase )
	Private _TpFrete    := ""
	Private _Transporte := ""
	Private _cPrazoPag  := ""
	Private _nMoeda     := 1
	Private oPrint, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b
	Private lLiberado	:= .F.

	Private cLogoD := ""
	Private nDescProd := 45
	Private nDescProdN:= 30
	Private nRetira := 0

	DEFAULT lPDF := .F.
	DEFAULT _NumPed := ""

	If Empty(_NumPed)
		IW_MsgBox("Sem número do pedido para gerar relatório. Aborando.",OemToAnsi("Informativo"),"INFO" )
		Return ""
	Endif

	//U_AUTOM628("AUTR001")

	// Tratamento das perguntas
	If _NumPed == Nil
		AjustaSX1( cPerg )
		If !Pergunte( cPerg, .T. )
			Return
		EndIf
	Endif

	// Cria o objeto de impressao

	If lPDF
		oPrint := FWMSPrinter():New('MARR003_' + _NumPed + '.PD_',IMP_PDF, lAdjustToLegacy,cLocal, lDisableSetup,lTReport , , , , , .f., )
	Else
		oPrint := TmsPrinter():New()
	Endif

	// Orientação da página
	//oPrint:SetLandScape() // Para Paisagem
	oPrint:SetPortrait()    // Para Retrato

	// Tamanho da página na impressão
	oPrint:SetPaperSize(8) // A3
	//oPrint:SetPaperSize(1) // Carta
	//oPrint:SetPaperSize(9)   // A4

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

	oFont06c   := TFont():New( "Courier New",,06,,.f.,,,,.f.,.f. )
	oFont08c   := TFont():New( "Courier New",,08,,.f.,,,,.f.,.f. )
	oFont08cb  := TFont():New( "Courier New",,08,,.t.,,,,.f.,.f. )
	oFont09c   := TFont():New( "Courier New",,09,,.f.,,,,.f.,.f. )
	oFont09b   := TFont():New( "Courier New",,09,,.t.,,,,.f.,.f. )
	oFont09c   := TFont():New( "Courier New",,09,,.f.,,,,.f.,.f. )
	oFont09cb  := TFont():New( "Courier New",,09,,.t.,,,,.f.,.f. )
	oFont10c   := TFont():New( "Courier New",,10,,.f.,,,,.f.,.f. )
	oFont11cb  := TFont():New( "Courier New",,11,,.T.,,,,.f.,.f. )
	oFont12c   := TFont():New( "Courier New",,12,,.f.,,,,.f.,.f. )
	oFont12cb  := TFont():New( "Courier New",,12,,.t.,,,,.f.,.f. )
	oFont14cb  := TFont():New( "Courier New",,14,,.t.,,,,.f.,.f. )
	oFont16cb  := TFont():New( "Courier New",,16,,.t.,,,,.f.,.f. )

	SM0->( DbSeek( cEmpAnt + cFilAnt ) )

	cQuery := "SELECT C7_NUM    , " + chr(13)
	cQuery += "       C7_FILIAL , " + chr(13)
	cQuery += "       C7_ITEM   , " + chr(13)
	cQuery += "       C7_PRODUTO, " + chr(13)
	cQuery += "       C7_UM     , " + chr(13)
	cQuery += "       C7_QUANT  , " + chr(13)
	cQuery += "       C7_SEGUM  , " + chr(13)
	cQuery += "       C7_QTSEGUM, " + chr(13)
	cQuery += "       C7_PRECO  , " + chr(13)
	cQuery += "       C7_TOTAL  , " + chr(13)
	cQuery += "       C7_VALFRE , " + chr(13)
	cQuery += "       C7_ICMSRET, " + chr(13)
	cQuery += "       C7_IPI    , " + chr(13)
	cQuery += "       C7_BASEICM, " + chr(13)
	cQuery += "       C7_VALICM , " + chr(13)
	cQuery += "       C7_PICM   , " + chr(13)
	cQuery += "       C7_IPI    , " + chr(13)
	cQuery += "       C7_VALIPI , " + chr(13)
	cQuery += "       C7_DATPRF , " + chr(13)
	cQuery += "       C7_DTFOLOW, " + chr(13)
	cQuery += "       C7_OBS    , " + chr(13)
	cQuery += "       C7_FORNECE, " + chr(13)
	cQuery += "       C7_LOJA   , " + chr(13)
	cQuery += "       C7_COND   , " + chr(13)
	cQuery += "       C7_CONTATO, " + chr(13)
	cQuery += "       C7_EMISSAO, " + chr(13)
	cQuery += "       C7_EMITIDO, " + chr(13)
	cQuery += "       C7_DESCRI , " + chr(13)
	cQuery += "       C7_TPFRETE, " + chr(13)
	cQuery += "       C7_VALIPI , " + chr(13)
	cQuery += "       C7_MOEDA  , " + chr(13)
	cQuery += "       C7_USER   , "	+ chr(13)
	cQuery += "       A2_COD    , " + chr(13)
	cQuery += "       A2_LOJA   , " + chr(13)
	cQuery += "       A2_CGC    , " + chr(13)
	cQuery += "       A2_NOME   , " + chr(13)
	cQuery += "       A2_END    , " + chr(13)
	cQuery += "       A2_BAIRRO , " + chr(13)
	cQuery += "       A2_EST    , " + chr(13)
	cQuery += "       A2_MUN    , " + chr(13)
	cQuery += "       A2_CEP    , " + chr(13)
	cQuery += "       A2_DDD    , " + chr(13)
	cQuery += "       A2_TEL    , " + chr(13)
	cQuery += "       A2_FAX    , " + chr(13)
	cQuery += "       A2_EMAIL  , " + chr(13)
	cQuery += " (SELECT DISTINCT 'PEDIDO NÃO LIBERADO'"       + chr(13)
	cQuery += "    FROM " + RetSqlName("SCR") + " CR "        + chr(13)
	cQuery += "   WHERE CR_NUM    = C7_NUM"                   + chr(13)
	cQuery += "     AND CR_STATUS NOT IN ('03','05')"         + chr(13)
	cQuery += "     AND CR_FILIAL = '" + xFilial("SCR") + "'" + chr(13)
	cQuery += "     AND CR.D_E_L_E_T_ <> '*' ) STATUS "       + chr(13)
	cQuery += "  FROM " + RetSqlName("SC7") + " C7, "         + chr(13)
	cQuery += "       " + RetSqlName("SA2") + " A2  "         + chr(13)
	cQuery += " WHERE C7_FORNECE = A2_COD  "                  + chr(13)
	cQuery += "   AND C7_LOJA    = A2_LOJA "                  + chr(13)

	If _NumPed == Nil
		cQuery += "   AND C7_NUM BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'" + chr(13)
	Else
		cQuery += "   AND C7_NUM = '" + Alltrim(_NumPed) + "'" + chr(13)
	Endif

	If _NumPed == Nil
		cQuery += "   AND C7_EMISSAO BETWEEN '" + DtoS( MV_PAR03 ) + "' AND '" + DtoS( MV_PAR04 ) + "'" + chr(13)
	Endif

	cQuery += "   AND C7_FILIAL      = '" + Alltrim(xFilial("SC7")) + "'" + chr(13)
	cQuery += "   AND C7.D_E_L_E_T_ <> '*'"                               + chr(13)
	cQuery += "   AND A2.D_E_L_E_T_ <> '*'"                               + chr(13)
	cQuery += "   AND A2_MSBLQL     <> '1'"                               + chr(13)
	cQuery += " ORDER BY C7_NUM, C7_ITEM ASC "                            + chr(13)

	cQuery := ChangeQuery( cQuery )
	//MemoWrite( "c:\tds\MARR003-query-sc7.sql" , cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "T_PED", .T., .T. )

	// Formatar os campos para uso
	aStru := T_PED->( dbStruct() )
	aEval( aStru, { |e| If( e[ 2 ] != "C" .And. T_PED->( FieldPos( Alltrim( e[ 1 ] ) ) ) > 0, TCSetField( "T_PED", e[ 1 ], e[ 2 ],e [ 3 ], e[ 4 ] ), Nil ) } )
	// A função dbStruct() não reconheçe campos Data, então ela retorna como Caracter e não formata de forma correta.
	TCSetField( "T_PED", "C7_DTFOLOW", "D", 8, 0 )
	TCSetField( "T_PED", "C7_DATPRF", "D", 8, 0 )

	nVias := 1

	If Empty(Alltrim(mv_par08))
		mv_par08 := T_PED->C7_MOEDA
	Endif

	If Empty(Alltrim(mv_par05))
		mv_par05 := 1
	Endif

	If Empty(Alltrim(mv_par05))
		mv_par07 := T_PED->C7_MOEDA
	Endif


	For nViasImp := 1 To nVias

		_nQuant  := 0
		_nTot    := 0
		_nIpi    := 0
		_nRetido := 0
		_nFrete  := 0
		aObs     := {}
		cObs     := ""


		DbSelectArea("T_PED")
		Count to nNumeroPro // Busca quantidade de produtos a imprimir
		// Volta para o primeiro registro
		T_PED->( dbGoTop() )

		While !T_PED->( Eof() )

			// Quando o número do pedido de compras mudar
			If _cPedAtu != T_PED->C7_NUM

				// Se for o primeiro pedido não tem rodapé, pois não tem pedido anterior para imprimir rodapé
				If !_lPrimeiro
					PrintRodape()
				Else
					_lPrimeiro := .F.
				EndIf

				_nMoeda    := T_PED->C7_MOEDA
				_cPrazoPag := Posicione( "SE4", 1, xFilial("SE4") + T_PED->C7_COND, "E4_DESCRI" )

				Do Case
				Case Alltrim(T_PED->C7_TPFRETE) == "C"
					_TpFrete   := "C I F"
				Case Alltrim(T_PED->C7_TPFRETE) == "F"
					_TpFrete   := "F O B"
				OtherWise
					_TpFrete   := " --- "
				EndCase

				If _nMoeda > 1
					_dCotDia := Iif( mv_par07 == 1, T_PED->C7_EMISSAO, _dCotDia )
					_nCotDia := Posicione( "SM2", 1, _dCotDia, "M2_MOEDA2" )
				Else
					_nCotDia := 1
				EndIf

				// Imprime o cabeçalho da pagina
				PrintCabec()

			EndIf
			//Só adiciona na obserbação se tiver conteúdo novo.
			If !Empty(AllTrim( T_PED->C7_OBS )) .and.  !((AllTrim( T_PED->C7_OBS )+ "; ") $ cObs)
				cObs += AllTrim( T_PED->C7_OBS )+ "; "
			Endif

			// Verifica se existe execeção fiscal
			If (Select( "T_DETALHES" ) != 0 )
				T_DETALHES->( DbCloseArea() )
			EndIf

			cSql := ""
			cSql := "SELECT F7_ALIQDST,"
			cSql += "       F7_MARGEM  "
			cSql += "  FROM " + RetSqlName("SF7") + " "
			cSql += " WHERE F7_GRTRIB  = '" + Alltrim(Posicione("SB1", 1, xFilial("SB1") + T_PED->C7_PRODUTO, "B1_GRTRIB")) + "'"
			cSql += "   AND F7_EST     = '" + Alltrim(Posicione("SA1", 1, xFilial("SA1") + T_PED->C7_FORNECE + T_PED->C7_LOJA, "A1_EST"))     + "'"
			cSql += "   AND F7_TIPOCLI = '" + Alltrim(Posicione("SA1", 1, xFilial("SA1") + T_PED->C7_FORNECE + T_PED->C7_LOJA, "A1_TIPO"))    + "'"
			cSql += "   AND F7_GRPCLI  = '" + Alltrim(Posicione("SA1", 1, xFilial("SA1") + T_PED->C7_FORNECE + T_PED->C7_LOJA, "A1_GRPTRIB")) + "'"
			cSql += "   AND D_E_L_E_T_ = ''"
			cSql += "   AND F7_FILIAL  = '" + Alltrim(xFilial("SF7")) + "'"

			cSql := ChangeQuery( cSql )
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_DETALHES",.T.,.T.)

			_MVA     := 0
			_ALIQINT := 0

			If T_DETALHES->( EOF() )
				_MVA     := 0
				_ALIQINT := 0
			Else
				If T_DETALHES->F7_ALIQDST > 0
					_MVA := T_DETALHES->F7_MARGEM
					If Alltrim(Posicione("SA1", 1, xFilial("SA1") + T_PED->C7_FORNECE + T_PED->C7_LOJA, "A1_EST")) == "RJ"
						_ALIQINT := T_DETALHES->F7_ALIQDST + 1
					Else
						_ALIQINT := T_DETALHES->F7_ALIQDST
					Endif
				Endif
			Endif

			If Alltrim(Posicione("SA1", 1, xFilial("SA1") + T_PED->C7_FORNECE + T_PED->C7_LOJA, "A1_EST")) == "RJ"
				If Substr(Posicione( "SB1", 1, xFilial("SB1") + T_PED->C7_PRODUTO, "B1_DESC" ),01,04) == "8471"
					_ALIQINT := 13
				Endif
				If Substr(Posicione( "SB1", 1, xFilial("SB1") + T_PED->C7_PRODUTO, "B1_DESC" ),01,04) == "847130"
					_ALIQINT := 19
				Endif
			Endif

			lInteiro := !((T_PED->C7_QUANT - INT(T_PED->C7_QUANT)) == 0)


			xx_zCusto := (T_PED->C7_PRECO   * Iif( mv_par08 == 2, _nCotDia, 1 )) + ;
				(T_PED->C7_VALIPI  * Iif( mv_par08 == 2, _nCotDia, 1 )) + ;
				(T_PED->C7_ICMSRET * Iif( mv_par08 == 2, _nCotDia, 1 ))

			// Transform( T_PED->C7_ZCUSTO  * Iif( mv_par08 == 2, _nCotDia, 1 ), "@E 999,999.99") + " " + ;

			cDescrProd := AllTrim(IIF( mv_par05 == 2, T_PED->C7_DESCRI, Posicione( "SB1", 1, xFilial("SB1") + T_PED->C7_PRODUTO, "B1_DESC" )))


			If Len(cDescrProd) > nDescProd
				nLinDesc:= MLCount(cDescrProd,nDescProd)
			Else
				nLinDesc := 1
			EndIf

          /*cStringProduto := T_PED->C7_ITEM                  + " | " + ; // ITEM
                            T_PED->C7_PRODUTO + " | " + ; // PRODUTO
                            ""+;//Borges // Substr(T_PED->C7_PARTNUM,01,20) + " " + ;  //BORGES  //
                            PADR(MemoLine(cDescrProd,nDescProd,1),nDescProd) + " | " + ;  //DESCRICAO PRODUTO
                            Substr(Posicione( "SB1", 1, xFilial("SB1") + T_PED->C7_PRODUTO, "B1_POSIPI" ),1,10) + " | " + ;  //NCM/posipi
                            PADR(T_PED->C7_UM,4)                    + " | " + ; // 1 UM
                            PADL(AllTrim(Transform( T_PED->C7_QUANT  , iif(lInteiro,STRTRAN(X3Picture("C7_QUANT"),".","9"),X3Picture("C7_QUANT")))),TamSX3("C7_QUANT")[1]) + " | " + ; // QTD 1 UM
                            PADR(T_PED->C7_SEGUM,4)                    + " | " + ; // 2 UM
                            PADL(AllTrim(Transform( T_PED->C7_QTSEGUM, iif(lInteiro,STRTRAN(X3Picture("C7_QTSEGUM"),".","9"),X3Picture("C7_QTSEGUM")))),TamSX3("C7_QTSEGUM")[1])  + " | " + ; //QTD 2 UM
                            PADL(AllTrim(Transform( T_PED->C7_PRECO   * Iif( mv_par08 == 2, _nCotDia, 1 ), X3Picture("C7_PRECO"))),TamSX3("C7_PRECO")[1]) + " | " + ;
                            PADL(AllTrim(Transform( T_PED->C7_IPI, X3Picture("C7_IPI"))),TamSX3("C7_IPI")[1])                                             + " | " + ;
                            PADL(AllTrim(Transform( T_PED->C7_TOTAL   * Iif( mv_par08 == 2, _nCotDia, 1 ),  X3Picture("C7_TOTAL"))),TamSX3("C7_TOTAL")[1]) + " | " + ;
                            ""+;//Borges // Transform( T_PED->C7_VALIPI  * Iif( mv_par08 == 2, _nCotDia, 1 ), "@E 999,999.99") + " " + ;
                            ""+;//Borges // Transform( T_PED->C7_ICMSRET * Iif( mv_par08 == 2, _nCotDia, 1 ), "@E 999,999.99") + " " + ;
                            ""+;//Borges // Transform( xx_zCusto, "@E 999,999.99")                                             + " " + ;
                            ""+;//Borges // Transform( T_PED->C7_BASEICM * Iif( mv_par08 == 2, _nCotDia, 1 ), "@E 999,999.99") + " " + ;
                            ""+;//Borges // Transform( T_PED->C7_PICM, "@E 999.99")                                            + " " + ;
                            ""+;//Borges // Transform( T_PED->C7_VALICM  * Iif( mv_par08 == 2, _nCotDia, 1 ), "@E 999,999.99") + " " + ;
                            ""+;//Borges // Transform( _ALIQINT, "@E 999.99")                                                  + " " + ;
                            ""+;//Transform( _MVA    , "@E 999.99")                                                  + " " + ;
                            DTOC(STOD(T_PED->C7_DATPRF)) + " | " + ;// D.ENTREGA
                            PADR(SB1->B1_CODREV,8)+ " | " + ;//COD.REV
                             // Dt.Aual.Des
                            
                            
           oPrint:Say( _nLin, 060, cStringProduto, oFont08c )*/

		   //impressao itens - novo
			oPrint:Say( _nLin, 0055,  STRZERO(Val(T_PED->C7_ITEM), 3, 0)  										        	, oFont12c)
			oPrint:Say( _nLin, 0150,  T_PED->C7_PRODUTO																		, oFont12c)
			oPrint:Say( _nLin, 0580,  PADR(MemoLine(cDescrProd,nDescProd,1),nDescProdN)										, oFont12c) 
			oPrint:Say( _nLin, 1210,  Substr(Posicione( "SB1", 1, xFilial("SB1") + T_PED->C7_PRODUTO, "B1_POSIPI" ),1,10)	, oFont12c)			
			oPrint:Say( _nLin, 1380,  PADR(T_PED->C7_UM,4)																	, oFont12c)
			oPrint:Say( _nLin, 1415,  PADL(AllTrim(Transform( T_PED->C7_QUANT  , iif(lInteiro,STRTRAN(X3Picture("C7_QUANT"),".","9"),X3Picture("C7_QUANT")))),TamSX3("C7_QUANT")[1])		, oFont12c)
			oPrint:Say( _nLin, 1700,  PADR(T_PED->C7_SEGUM,4)																, oFont12c)
			oPrint:Say( _nLin, 1740,  PADL(AllTrim(Transform( T_PED->C7_QTSEGUM, iif(lInteiro,STRTRAN(X3Picture("C7_QTSEGUM"),".","9"),X3Picture("C7_QTSEGUM")))),TamSX3("C7_QTSEGUM")[1]) 	, oFont12c)
			oPrint:Say( _nLin, 1935,  PADL(AllTrim(Transform( T_PED->C7_PRECO   * Iif( mv_par08 == 2, _nCotDia, 1 ), X3Picture("C7_PRECO"))),TamSX3("C7_PRECO")[1])							, oFont12c)
			oPrint:Say( _nLin, 2250,  PADL(AllTrim(Transform( T_PED->C7_IPI, X3Picture("C7_IPI"))),TamSX3("C7_IPI")[1])		, oFont12c)
			oPrint:Say( _nLin, 2290,  PADL(AllTrim(Transform( T_PED->C7_TOTAL   * Iif( mv_par08 == 2, _nCotDia, 1 ),  X3Picture("C7_TOTAL"))),TamSX3("C7_TOTAL")[1])						, oFont12c)
			oPrint:Say( _nLin, 2630,  DtoC(IIF( Empty( T_PED->C7_DTFOLOW ), T_PED->C7_DATPRF, T_PED->C7_DTFOLOW ) )		    , oFont12c)
			oPrint:Say( _nLin, 2880,  PADR(SB1->B1_CODREV,8)																, oFont12c)
			oPrint:Say( _nLin, 3020,  Right(DtoS(SB1->B1_DTATDES),2) +"/"+Substring(DtoS(SB1->B1_DTATDES),5,2) +"/"+ Substring(DtoS(SB1->B1_DTATDES),3,2)									, oFont12c) //DTOC(SB1->B1_DTATDES)
						
			SomaLinha(_nTamLin)
			
			If nLinDesc > 1
	           	For x:= 2 to nLinDesc
	           		
					oPrint:Say( _nLin, 0580,  PADR(MemoLine(cDescrProd,nDescProdN,x),nDescProdN)										, oFont12c) 
	           		SomaLinha(_nTamLin)
	           	Next x 
           	Endif

			_nQuant  += T_PED->C7_QUANT
			_nTot    += T_PED->C7_TOTAL   * Iif( mv_par08 == 2, _nCotDia, 1 )
			_nIpi    += T_PED->C7_VALIPI  * Iif( mv_par08 == 2, _nCotDia, 1 )
			_nRetido += T_PED->C7_ICMSRET * Iif( mv_par08 == 2, _nCotDia, 1 )
            _nFrete  += T_PED->C7_VALFRE  * Iif( mv_par08 == 2, _nCotDia, 1 )
			
			_cPedAtu := T_PED->C7_NUM
	
            nNumeroPro := nNumeroPro - 1

			T_PED->( dbSkip() )
			
		EndDo

		// Desenhas os traços verticais no bloco de produtos

		If  __Vertical + (nMaxQtdProd * _nTamLin) > _nLin
			_nLin := __Vertical + (nMaxQtdProd * _nTamLin)
		Endif


		nContar := __Vertical
		While nContar < _nLin - 10 //-diminui  para não ultrapassar a barra da inha de baixo
			oPrint:Say( nContar, 0060,    PADR("    "					,TamSX3("C7_ITEM")[1])+;
				" | " +  PADR("      "					,TamSX3("C7_PRODUTO")[1])+;
				" | " +	 PADR(""                        ,nDescProd)+;
				" | " +	 PADR("   "						,TamSX3("B1_POSIPI")[1])+;
				" | " +	 PADR("    "					,4)+;//UM
				" | " +	 PADR("        "				,TamSX3("C7_QUANT")[1])+;
				" | " +	 PADR("    "					,4)+;//2 UM
				" | " +	 PADR("        "				,TamSX3("C7_QTSEGUM")[1])+;
				" | " +	 PADR("           "				,TamSX3("C7_PRECO")[1])+;
				" | " +	 PADR("     "					,TamSX3("C7_IPI")[1])+;
				" | " +	 PADR("         "				,TamSX3("C7_TOTAL")[1]+1)+;
				" | " +	 PADR("           "				,16)+;//Dt.Entrega
				" | " +	 PADR("        "				,8)+; // Cod.Rev
				" | " +	 PADR("             "			,13), oFont08c )

			nContar := nContar + 10
			//Next nContar
		Enddo

		// Imprime o Rodapé do Pedido de Compra
		PrintRodape()

	Next

	T_PED->( dbCloseArea() )

	If lPDF
		cFilePrint := cLocal+'MARR003_' + _NumPed + '.PDF'
		File2Printer( cFilePrint, "PDF" )
		oPrint:cPathPDF:= cLocal
	Endif

	oPrint:Preview()
	MS_FLUSH()

Return (cFilePrint)


// Retorna um array com as linhas de texto do campo memo
Static Function MemoObs( cTexto, nTam )

	Local aObserv := {}
	Local nLinhas := 0
	Local nX      := 0

	nLinhas := MlCount( cTexto, nTam )

	For nX := 1 To nLinhas
		aAdd( aObserv, MemoLine( cTexto, nTam, nX ) )
	Next

Return( aObserv )

// Verifica se a soma de linhas não ultrapassa o limite
Static Function SomaLinha(nLinhas)

	_nLin += nLinhas

	// Se ultrapassar o limite encerra a página e inicia outra com o cabeçalho
	If _nLin >= _nLimVert
		oPrint:EndPage()
		PrintCabec()
	EndIf

Return

// Imprime o rodapé e finaliza a página
Static Function PrintRodape()

	Local nX  := 0
	Local n   := 0
	Local L   := 0

	//Linha horizontal divisão parte produtos para o rodapé.
	oPrint:Line( _nLin, 0050, _nLin, 3300 )
	SomaLinha(15)
	// Imprime local de Entrega e Cobrança
	//cCident := IIF(len(SM0->M0_CIDENT)>20,Substr(SM0->M0_CIDENT,1,15),SM0->M0_CIDENT)
	//cCidcob := IIF(len(SM0->M0_CIDCOB)>20,Substr(SM0->M0_CIDCOB,1,15),SM0->M0_CIDCOB)

	oPrint:Say(_nLin, 0100,"End. Entrega:",oFont10)
	oPrint:Say(_nLin, 0320, SM0->M0_ENDENT+"  "+Rtrim(SM0->M0_CIDENT)+"  - "+SM0->M0_ESTENT+" - " + Trans(Alltrim(SM0->M0_CEPENT),X3Picture("A2_CEP")),oFont10)
	SomaLinha(30)
	oPrint:Say(_nLin, 0100,"End.Cobrança:",oFont10)
	oPrint:Say(_nLin, 0320, SM0->M0_ENDCOB+"  "+Rtrim(SM0->M0_CIDCOB)+"  - "+SM0->M0_ESTCOB+" - " + Trans(Alltrim(SM0->M0_CEPCOB),X3Picture("A2_CEP")),oFont10)
	SomaLinha(40)

	//Inicio linha horizontal dos totalizadores
	oPrint:Line( _nLin, 0050, _nLin, 3300 )

	oPrint:Line( _nLin, 1420, _nLin + 800, 1420 ) // Linha Vertical  ///////////////////////////// 300
	SomaLinha(15)

	oPrint:Say( _nLin, 0100, "Condição de Pagamento", oFont10b )

	// Imprime a quantidade total e o sub-total do pedido de compra
	oPrint:Say( _nLin, 1470, "Valor Total dos Produtos", oFont10b )
	oPrint:Say( _nLin, 2430, PadL( Transform( _nQuant, "@E 999,999,999.99"), 15 ), oFont12b,,,,1 )
	oPrint:Say( _nLin, 3020, PadL( Transform( _nTot  , "@E 999,999,999.99"), 15 ), oFont12b,,,,1 )

	// Imprime a prazo de pagamento (Condição de Pagamento)
	SomaLinha(_nTamLin)
	oPrint:Say( _nLin, 0100, _cPrazoPag, oFont10 )

	// Imprime o Valor Total do IPI
	oPrint:Say( _nLin, 1470, "Valor do IPI", oFont10b )
	oPrint:Say( _nLin, 3020, PadL( Transform( _nIpi, "@E 999,999,999.99"), 15 ), oFont12b,,,,1 )

	// Imprime o Tipo de Frete
	SomaLinha(60)
	oPrint:Say( _nLin, 0100, "Tipo de Frete", oFont10b )

	// Imprime o Valor Total do ICMS Retido do Pedido de Compra
	oPrint:Say( _nLin, 1470, "Valor ICMS ST", oFont10b )
	oPrint:Say( _nLin, 3020, PadL( Transform( _nRetido, "@E 999,999,999.99"), 15 ), oFont12b,,,,1 )

	// Imprime o Tipo de Frete
	SomaLinha(60)

	If !Empty(Alltrim(_TpFrete))
		oPrint:Say( _nLin, 0100, _Tpfrete, oFont10 )
	Endif

	//oPrint:Line( _nLin+15, 0050, _nLin+15, 1420 )// Linha embaixo do frete e condpag

	// Imprime o Sub-Total dos Produtos
	oPrint:Say( _nLin, 1470, "Sub-Total", oFont10b )
	oPrint:Say( _nLin, 3020, PadL( Transform( (_nTot + _nIpi + _nRetido), "@E 999,999,999.99"), 15 ), oFont12b,,,,1 )

	SomaLinha(60)


	// Imprime o Valor Total do Frete
	oPrint:Say( _nLin, 1470, "Valor do Frete", oFont10b )
	oPrint:Say( _nLin, 3020, PadL( Transform( _nFrete, "@E 999,999,999.99"), 15 ), oFont12b,,,,1 )

	// Imprime o Desconto Financeiro
	SomaLinha(60)
	oPrint:Say( _nLin, 1470, "Desconto Financeiro (-)", oFont10b )
	oPrint:Say( _nLin, 3020, PadL( Transform( _nDfinan, "@E 999,999,999.99"), 15 ), oFont12b,,,,1 )

	// Imprime o Valor Total do Pedido de Compra
	SomaLinha(60)
	oPrint:Line( _nLin - 15, 1420, _nLin - 15, 3300 )
	oPrint:Say( _nLin, 1470, "Valor Total do Pedido", oFont12b )

	oPrint:Say( _nLin, 3020, PadL( Transform( _nTot + _nIpi + _nRetido + _nFrete - _nDfinan, "@E 999,999,999.99"), 15 ), oFont12b,,,,1 )

	// Imprime o noe da transportadora se informado
	If !Empty(Alltrim(_Transporte))
		SomaLinha(_nTamLin)
		oPrint:Say( _nLin, 0100, "Transportadora", oFont10b )
		SomaLinha(_nTamLin)
		oPrint:Say( _nLin, 0100, _Transporte, oFont10 )
	Endif

	SomaLinha(60)
	If _nMoeda > 1
		oPrint:Say( _nLin, 0100, "Cotação US$", oFont10b )
		oPrint:Say( _nLin + _nTamLin, 0100, "R$ "+ AllTrim( Transform( _nCotDia, "@E 99.9999") ) +" - "+ DtoC( StoD( _dCotDia ) ), oFont10 )
	EndIf

	SomaLinha(110)

	SomaLinha(_nTamLin)
	//Linha horizontal Divisão Notas
	oPrint:Line( _nLin, 0050, _nLin, 3300 )
	nLinIni := _nLin //Controla o posicionamento da Linha inicial Notas e Observações
	nLinMax := _nLin// Contrlla o posicionamento da Linha Máxima das Notas e Observações
	SomaLinha(15)

	oPrint:Say( _nLin, 0100, "Observações: ", oFont10b )

	aObs := MemoObs( cObs, 80 )
	If Len( aObs ) >= 1
		For nX := 1 To Len( aObs )
			SomaLinha(40)
			oPrint:Say( _nLin, 0150, aObs[ nX ], oFont10 )
		Next
	EndIf
	nLinMax := _nLin //Grava posição maxima da posição das observações

	//Reinicializa nLin com o valor inicial e Imprime Mensagens
	_nLin := nLinIni
	SomaLinha(15)
	oPrint:Say( _nLin, 1470, "NOTAS: ", oFont10b )
	SomaLinha(40)

	aNotas := {}
	AADD(aNotas,"- So aceitaremos a mercadoria se na sua NOTA FISCAL constar o numero do nosso PEDIDO DE COMPRAS;")
	AADD(aNotas,"- A Marcher efetua pagamentos somente nas tercas feiras. Nao sera permitido antecipacao de vencimentos.")
	AADD(aNotas,"- Favor enviar espelho da nota fiscal sempre que emitirem notas fiscais, para os seguintes enderecos: compras@marcher.com.br; almoxarifado@marcher.com.br; dmachado@marcher.com.br;")

	For n:= 1 TO Len(aNotas)
		nBuffer:= 115
		nX := mlcount(aNotas[n],nBuffer)
		For L:=1  to nX
			oPrint:Say( _nLin, 1500,memoline(aNotas[n],nBuffer,L), oFont10 )
			SomaLinha(40)
		Next L
	Next n

	nLinMax := MAX(_nLin,nLinMax) //Seta o maior valor para compatibilizar as duas colunas a fim de imprimir a linha orizintal depois do a impressão do maior conteúdo entre Observações e Notas.

	oPrint:Line( nLinIni, 1420, nLinMax, 1420 ) // Linha Vertical
	_nLin:= nLinMax
	//Inicio linha horizontal Após Notas e Observações
	oPrint:Line( _nLin, 0050, _nLin, 3300 )
	SomaLinha(15)

	SomaLinha(_nTamLin)

	oPrint:Line( 060, _nTamLin, _nLin, 0050 )
	oPrint:Line( 060, 3300, _nLin, 3300 )
	oPrint:Line( _nLin, _nTamLin, _nLin, 3300 )

	oPrint:EndPage()

	_nQuant := 0
	_nTot   := 0
	_nIpi   := 0
	aObs    := {}
	cObs    := ""

Return


// Inicia nova página e imprime o cabeçalho, ajustando a linha para impressão
Static Function PrintCabec()

	Local __LVert_0 := 0

	oPrint:StartPage()

	_nLin := 60
	oPrint:Line( _nLin, 050, _nLin, 3300 )
	_nLin := 70

	dbSelectArea("SM0")
	SM0->( DbSeek( cEmpAnt + cFilAnt ) )

	// Dados de cadastro
	oPrint:Say( _nLin, 1000,Substr(SM0->M0_NOMECOM,1,42), oFont10b )

	_nLin += _nTamLin

	// Logotipo e identificação do pedido
	cBitmap := RetLogo()
	_cFileLogo	:= GetSrvProfString('Startpath','') + cBitmap
	oPrint:SayBitmap( _nLin, 0200, _cFileLogo, 0600, 0200 )

	// Endereço da Empresa
	oPrint:Say( _nLin, 1000, AllTrim( SM0->M0_ENDENT ) +" "+ AllTrim( SM0->M0_COMPENT ), oFont10b )
	oPrint:Say( _nLin, 2725, "ORDEM DE COMPRA", oFont14b )
	_nLin += _nTamLin

	// Cidade / Estado / CEP
	oPrint:Say( _nLin, 1000, Alltrim(SM0->M0_CIDENT) + "/" + Alltrim(SM0->M0_ESTENT), oFont10b )
	_nLin += _nTamLin

	// Telfone/Fax
	Do Case
	Case SM0->M0_CODIGO == '01'
		oPrint:Say( _nLin, 1000, Transform( SM0->M0_TEL, "@R (99) 9999-9999" ) + " / " + Transform( SM0->M0_FAX, "@R (99) 9999-9999" ), oFont10b )
	Case SM0->M0_CODIGO == '02'
		oPrint:Say( _nLin, 1000, "(41) 3024-6675 / (41) 3024-6675", oFont10b )
	Otherwise
		oPrint:Say( _nLin, 1000, Transform( SM0->M0_TEL, "@R (99) 9999-9999" ) + " / " + Transform( SM0->M0_FAX, "@R (99) 9999-9999" ), oFont10b )
	EndCase

	// Imprime nº da Ordem de Compra
	oPrint:Say( _nLin, 2840, "Nº " + Alltrim(T_PED->C7_NUM), oFont20b )

	_nLin += 50

	// CNPJ
	oPrint:Say( _nLin, 1000, Transform(SM0->M0_CGC, "@R 99.999.999/9999-99"), oFont10b )
	_nLin += 50

	// IE
	oPrint:Say( _nLin, 1000, "IE:" + InscrEst(), oFont10b )
	_nLin += _nTamLin

	oPrint:Line( 060, 2650, _nLin, 2650 )
	oPrint:Line( _nLin, 0050, _nLin, 3300 )

	__LVert_0 := _nLin

	_nLin += _nTamLin

	// Dados do fornecedor
	oPrint:Say( _nLin, 0060, "Fornecedor:", oFont10 )
	// Jorge Alberto - Solutio - #25661 - Inclusão do CNPJ ao lado do Nome do Fornecedor.
	oPrint:Say( _nLin, 0250, "["+ T_PED->A2_COD + "/" + T_PED->A2_LOJA + "] "+ AllTrim( T_PED->A2_NOME ) + " - " + Transform(T_PED->A2_CGC, "@R 99.999.999/9999-99"), oFont10b )
	oPrint:Say( _nLin, 1500+150, "Fone/Fax:", oFont10 )
	oPrint:Say( _nLin, 1730+150, Transform( AllTrim( T_PED->A2_DDD ) + T_PED->A2_TEL, "@R (99) 9999-9999" )+"/"+Transform( AllTrim( T_PED->A2_DDD ) + T_PED->A2_FAX, "@R (99) 9999-9999" ), oFont10b )
	oPrint:Say( _nLin, 2470, "Emissão:", oFont10 )
	oPrint:Say( _nLin, 2700, DtoC( dDataBase ) +" "+ Time(), oFont10b )

	_nLin += _nTamLin

	oPrint:Say( _nLin, 0060, "Endereço:", oFont10 )
	oPrint:Say( _nLin, 0250, AllTrim( T_PED->A2_END ) +" "+ AllTrim( T_PED->A2_BAIRRO ) +" "+ Transform( AllTrim( T_PED->A2_CEP ), "@R 99999-999"), oFont10b )
	oPrint:Say( _nLin, 1500+ 150, "Cidade:", oFont10 )
	oPrint:Say( _nLin, 1730+150, T_PED->A2_MUN, oFont10b )
	oPrint:Say( _nLin, 2470, "Comprador:", oFont10 )
	oPrint:Say( _nLin, 2700, UsrFullName(T_PED->C7_USER), oFont10b )

	_nLin += _nTamLin

	oPrint:Say( _nLin, 0060, "E-mail:", oFont10 )
	oPrint:Say( _nLin, 0250, AllTrim( T_PED->A2_EMAIL ), oFont10b )
	oPrint:Say( _nLin, 1500+150, "Estado:", oFont10 )
	oPrint:Say( _nLin, 1730+150, T_PED->A2_EST, oFont10b )
	// Status do pedido
	lLiberado := Empty(T_PED->STATUS)
	oPrint:Say( _nLin, 2470, IIF(lLiberado,"PEDIDO LIBERADO","PEDIDO NÃO LIBERADO"), oFont20b )

	_nLin += _nTamLin

	// Desenha a linha vertical entre dados do Fornecedor e Comprador
	oPrint:Line( __LVert_0, 2420, _nLin, 2420 ) //Barra Vertical 0

	oPrint:Line( _nLin, 0050, _nLin, 3300 )

	_nLin += 20

	// Imprime o título dos produtos
	If T_PED->C7_MOEDA == 1
		oPrint:Say( _nLin, 1200, "P R O D U T O S - Valores expressos em R$", oFont12b )
	Else
		oPrint:Say( _nLin, 1200, "P R O D U T O S - Valores expressos em US$", oFont12b )
	Endif

	_nLin += 70
	oPrint:Line( _nLin, 0050, _nLin, 3300 )
	__Vertical := _nLin //Seta o inicio das linhas verticais para produtos

	If !Empty(nNumeroPro) // Só imprime o cabeçalho de produtos se falta produtos a imprimir.

		_nLin += 20

		// Cabeçalhos dos itens
		//oPrint:Say( _nLin, 0060, "ITEM CÓDIGO PART NUMBER          DESCRIÇÃO DOS PRODUTOS         UN     QTD   UNITÁRIO  VLR.TOTAL  % IPI    VLR.IPI    ICMS ST CUSTO UNT.  BASE ICMS % ICMS   VLR.ICMS  % MVA ICMS I ENTREGA", oFont08cb )
		/*oPrint:Say( _nLin, 0060, PADR("ITEM"		,TamSX3("C7_ITEM")[1])+;
						" | " +  PADR("CÓDIGO"	,TamSX3("C7_PRODUTO")[1])+;
						" | " +	 PADR("DESCRIÇÃO DO PRODUTO"	,nDescProd)+;
						" | " +	 PADR("NCM"						,TamSX3("B1_POSIPI")[1])+;
						" | " +	 PADR("1 UM"					,4)+;
						" | " +	 PADR("QTD 1 UM"				,TamSX3("C7_QUANT")[1])+;
						" | " +	 PADR("2 UM"					,4)+;
						" | " +	 PADR("QTD 2 UM"				,TamSX3("C7_QTSEGUM")[1])+;							 
						" | " +	 PADR("PREÇO UNIT."				,TamSX3("C7_PRECO")[1])+;
						" | " +	 PADR("% IPI"					,TamSX3("C7_IPI")[1])+;
						" | " +	 PADR("VLR.TOTAL"				,TamSX3("C7_TOTAL")[1])+;
						" |" +	 PADR("DT. ENTREGA"				,11)+;
						" | " +	 PADR("COD. REV"				,8)+;
						" | " +	 PADR("DT. ATUAL.DES"				,13), oFont08cb )*/
						
		//impressao cabec - novo
		oPrint:Say( _nLin, 0060,  PADR("ITEM"					,TamSX3("C7_ITEM")[1])			, oFont09cb)
		oPrint:Say( _nLin, 0150,  PADR("CÓDIGO"					,TamSX3("C7_PRODUTO")[1])		, oFont09cb)
		oPrint:Say( _nLin, 0580,  PADR("DESCRIÇÃO DO PRODUTO"	,nDescProd)						, oFont09cb)
		oPrint:Say( _nLin, 1210,  PADR("NCM"					,TamSX3("B1_POSIPI")[1])		, oFont09cb)
		oPrint:Say( _nLin, 1380,  PADR("1 UM"					,4)								, oFont09cb)
		oPrint:Say( _nLin, 1480,  PADR("QTD 1 UM"				,TamSX3("C7_QUANT")[1])			, oFont09cb)
		oPrint:Say( _nLin, 1700,  PADR("2 UM"					,4)								, oFont09cb)
		oPrint:Say( _nLin, 1790,  PADR("QTD 2 UM"				,TamSX3("C7_QUANT")[1])			, oFont09cb)
		oPrint:Say( _nLin, 2000,  PADR("PREÇO UNIT."			,TamSX3("C7_PRECO")[1])			, oFont09cb)
		oPrint:Say( _nLin, 2250,  PADR("% IPI"					,TamSX3("C7_IPI")[1]) 			, oFont09cb)
		oPrint:Say( _nLin, 2360,  PADR("VLR.TOTAL"				,TamSX3("C7_TOTAL")[1])			, oFont09cb)
		oPrint:Say( _nLin, 2640,  PADR("DT. ENTREG" 			,11)							, oFont09cb)
		oPrint:Say( _nLin, 2860,  PADR("COD. REV"				,8)								, oFont09cb)
		oPrint:Say( _nLin, 3020,  PADR("DT. ATUAL.DES"			,13)							, oFont09cb)
	    
		_nLin += _nTamLin
	     	
		oPrint:Line( _nLin, 0050, _nLin, 3300 )
	Endif	

    _nLin += 30	

Return


// Cria as perguntas para o relatório
Static Function AjustaSX1( cPerg )

	PutSx1( cPerg, "01", "Do Pedido ?          ","","","mv_ch1","C",06,00,00,"G" ,""  ,"SC7",""     ,""   ,"MV_PAR01",""            ,""      ,""      ,""    ,""            ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
	PutSx1( cPerg, "02", "Até o Pedido ?       ","","","mv_ch2","C",06,00,00,"G" ,""  ,"SC7",""     ,""   ,"MV_PAR02",""            ,""      ,""      ,""    ,""            ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
	PutSx1( cPerg, "03", "Da Emissão ?         ","","","mv_ch3","D",08,00,00,"G" ,""  ,""   ,""     ,""   ,"MV_PAR03",""            ,""      ,""      ,""    ,""            ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
	PutSx1( cPerg, "04", "Até Emisão ?         ","","","mv_ch4","D",08,00,00,"G" ,""  ,""   ,""     ,""   ,"MV_PAR04",""            ,""      ,""      ,""    ,""            ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
	PutSx1( cPerg, "05", "Descrição Produto ?  ","","","mv_ch5","N",01,00,00,"C" ,""  ,""   ,""     ,""   ,"MV_PAR05","Do Cadastro" ,""      ,""      ,""    ,"Do Pedido"   ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
	PutSx1( cPerg, "06", "Nº de Vias ?         ","","","mv_ch6","N",02,00,00,"G" ,""  ,""   ,""     ,""   ,"MV_PAR06",""            ,""      ,""      ,""    ,""            ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
	PutSx1( cPerg, "07", "Data da Cotação ?    ","","","mv_ch7","N",01,00,00,"C" ,""  ,""   ,""     ,""   ,"MV_PAR07","Da Emissão"  ,""      ,""      ,""    ,"Da Impressão",""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
	PutSx1( cPerg, "08", "Moeda ?              ","","","mv_ch8","N",01,00,00,"C" ,""  ,""   ,""     ,""   ,"MV_PAR08","Do Pedido"   ,""      ,""      ,""    ,"Corrente"    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")

Return

// Imprime uma régua horizontal numerada de 100 em 100 e uma régua vertical numerada de 50 em 50
Static Function PrtRegua()

	Local xxx 

	For xxx := 100 to 2400 step 100
		oPrint:Line( 0010, xxx, 0030, xxx )
		oPrint:Say( 0010, xxx+10, AllTrim( Str(xxx) ), oFont08 )
		If xxx > 2400
			Exit
		EndIf
	Next

	For xxx := 50 to 3600 step 50
		oPrint:Line( xxx, 0020, xxx, 0040 )
		oPrint:Say( xxx - 25, 0020, AllTrim( Str( xxx ) ), oFont06 )
		If xxx > 3600
			Exit
		EndIf
	Next

Return

//Busca Logo Bitmap Padrão
Static Function RetLogo()

	Local cBitmap := "LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP" // Empresa+Filial

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se nao encontrar o arquivo com o codigo do grupo de empresas ³
	//³ completo, retira os espacos em branco do codigo da empresa   ³
	//³ para nova tentativa.                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File( cBitmap )
		cBitmap := "LGRL" + AllTrim(SM0->M0_CODIGO) + SM0->M0_CODFIL+".BMP" // Empresa+Filial
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se nao encontrar o arquivo com o codigo da filial completo,  ³
	//³ retira os espacos em branco do codigo da filial para nova    ³
	//³ tentativa.                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File( cBitmap )
		cBitmap := "LGRL"+SM0->M0_CODIGO + AllTrim(SM0->M0_CODFIL)+".BMP" // Empresa+Filial
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se ainda nao encontrar, retira os espacos em branco do codigo³
	//³ da empresa e da filial simultaneamente para nova tentativa.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File( cBitmap )
		cBitmap := "LGRL" + AllTrim(SM0->M0_CODIGO) + AllTrim(SM0->M0_CODFIL)+".BMP" // Empresa+Filial
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se nao encontrar o arquivo por filial, usa o logo padrao     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File( cBitmap )
		cBitmap := "LGRL"+SM0->M0_CODIGO+".BMP" // Empresa
	EndIf

Return cBitmap
