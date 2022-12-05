#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTR001.PRW                                                         *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Jean - JPC e Harald Hans Löschenkohl                                *
// Data......: 27/10/2011                                                          *
// Objetivo..: Impressão do Pedido de Compra	                                   *
//**********************************************************************************

User Function AUTR001(_Codigo, kAdicional)

	Local cPerg    := "AUTR001"
	Local cQuery   := ""
	Local aStru    := {}
	Local _cPedAtu := ""
	Local _lPrimeiro := .T.
	
	Private aObs        := {}
	Private cObs        := ""
	Private _nQuant     := 0
	Private _nTot       := 0
	Private _nIpi       := 0
    Private _nRetido    := 0
    Private _nFrete     := 0
    Private _nDfinan    := 0
    Private nNumeroPro  := 10
    Private __Vertical  := 0
    Private nContar     := 0
	Private _nTamLin    := 80
	Private _nLimVert   := 3500
	Private _nVia       := 1
	Private _nPagina    := 1
	Private _nIniLin    := 0
	Private _nLin       := 0
	Private _nCotDia    := 1
	Private _dCotDia    := DtoS( dDataBase )
	Private _cPrevisao  := ""
    Private _TpFrete    := ""
    Private _Transporte := ""
	Private _cPrazoPag  := ""
	Private _nMoeda     := 1
	Private oPrint, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b
    Private kEmpresa    := ""
    Private kFilial     := ""

    Private cLogoD := ""

    U_AUTOM628("AUTR001")    

	// Tratamento das perguntas
    If _Codigo == Nil
   	   AjustaSX1( cPerg )
	   If !Pergunte( cPerg, .T. )
	      Return
  	   EndIf
    Endif

    If kAdicional == Nil
       kEmpresa := cEmpAnt
       kFilial  := cFilAnt
    Else
       kEmpresa := U_P_CORTA(kAdicional,"|",1)
       kFilial  := U_P_CORTA(kAdicional,"|",2)
    Endif       

	// Cria o objeto de impressao
	oPrint := TmsPrinter():New()
	
	// Orientação da página
	oPrint:SetLandScape() // Para Paisagem
	//oPrint:SetPortrait()    // Para Retrato
	
	// Tamanho da página na impressão
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

	oFont06c   := TFont():New( "Courier New",,06,,.f.,,,,.f.,.f. )
	oFont08c   := TFont():New( "Courier New",,08,,.f.,,,,.f.,.f. )
	oFont08cb  := TFont():New( "Courier New",,08,,.t.,,,,.f.,.f. )
	oFont09c   := TFont():New( "Courier New",,09,,.f.,,,,.f.,.f. )
	oFont09b   := TFont():New( "Courier New",,09,,.t.,,,,.f.,.f. )
    oFont09c   := TFont():New( "Courier New",,09,,.f.,,,,.f.,.f. )
	oFont09cb  := TFont():New( "Courier New",,09,,.t.,,,,.f.,.f. )
	oFont10c   := TFont():New( "Courier New",,10,,.f.,,,,.f.,.f. )
	oFont10cb  := TFont():New( "Courier New",,10,,.t.,,,,.f.,.f. )
	oFont12c   := TFont():New( "Courier New",,12,,.f.,,,,.f.,.f. )
	oFont12cb  := TFont():New( "Courier New",,12,,.t.,,,,.f.,.f. )
	oFont14cb  := TFont():New( "Courier New",,14,,.t.,,,,.f.,.f. )
	oFont16cb  := TFont():New( "Courier New",,16,,.t.,,,,.f.,.f. )

	// Nome da Empresa/Filial para o cabecalho
	SM0->( DbSeek( cEmpAnt + cFilAnt ) )
	
	cQuery := "SELECT C7_NUM    , "
	cQuery += "       C7_FILIAL , "
	cQuery += "       C7_ITEM   , "
	cQuery += "       C7_PRODUTO, "
	cQuery += "       C7_UM     , "
	cQuery += "       C7_QUANT  , "
	cQuery += "       C7_PRECO  , "
	cQuery += "       C7_TOTAL  , "
    cQuery += "       C7_VALFRE , "
    cQuery += "       C7_ZCUSTO , "
    cQuery += "       C7_ICMSRET, "
	cQuery += "       C7_IPI    , "
    cQuery += "       C7_BASEICM, "
    cQuery += "       C7_VALICM , "
    cQuery += "       C7_PICM   , "
    cQuery += "       C7_IPI    , "
    cQuery += "       C7_VALIPI , "
    cQuery += "       C7_DFIN   , "
	cQuery += "       C7_DATPRF , "
	cQuery += "       C7_OBS    , "
	cQuery += "       C7_FORNECE, "
	cQuery += "       C7_LOJA   , "
	cQuery += "       C7_COND   , "
	cQuery += "       C7_CONTATO, "
	cQuery += "       C7_EMISSAO, "
	cQuery += "       C7_EMITIDO, "
	cQuery += "       C7_DESCRI , "
	cQuery += "       C7_TPFRETE, "
	cQuery += "       C7_VALIPI , "
	cQuery += "       C7_MOEDA  , "
	cQuery += "       C7_PARTNUM, "
	cQuery += "       C7_TRANSP , "	
	cQuery += "       C7_LARG   , "	
	cQuery += "       C7_METR   , "	
	cQuery += "       C7_QBOB   , "			
	cQuery += "       A2_COD    , "
	cQuery += "       A2_NOME   , "
	cQuery += "       A2_END    , "
	cQuery += "       A2_BAIRRO , "
	cQuery += "       A2_EST    , "
	cQuery += "       A2_MUN    , "
	cQuery += "       A2_CEP    , "
 	cQuery += "       A2_DDD    , "
	cQuery += "       A2_TEL    , "
	cQuery += "       A2_FAX    , "
	cQuery += "       A2_EMAIL    "
    cQuery += "  FROM SC7" + kEmpresa + "0 C7, "

	cQuery += "       " + RetSqlName("SA2") + " A2  "
	cQuery += " WHERE C7_FORNECE = A2_COD  "
	cQuery += "   AND C7_LOJA    = A2_LOJA "

    If _Codigo == Nil
       cQuery += "   AND C7_NUM     BETWEEN '" + MV_PAR01         + "' AND '" + MV_PAR02         + "'"
    Else
       cQuery += "   AND C7_NUM = '" + Alltrim(_Codigo) + "'"
    Endif
    
    If _Codigo == Nil
   	   cQuery += "   AND C7_EMISSAO BETWEEN '" + DtoS( MV_PAR03 ) + "' AND '" + DtoS( MV_PAR04 ) + "'"
   	Endif
   	   
    cQuery += "   AND C7_FILIAL      = '" + Alltrim(kFilial) + "'"
	cQuery += "   AND C7.D_E_L_E_T_ <> '*'"
	cQuery += "   AND A2.D_E_L_E_T_ <> '*'"
	cQuery += "   AND A2_MSBLQL     <> '1'"
	cQuery += " ORDER BY C7_NUM, C7_ITEM ASC "

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "T_PED", .T., .T. )
	
	// Formatar os campos para uso
	aStru := T_PED->( dbStruct() )
	aEval( aStru, { |e| If( e[ 2 ] != "C" .And. T_PED->( FieldPos( Alltrim( e[ 1 ] ) ) ) > 0, TCSetField( "T_PED", e[ 1 ], e[ 2 ],e [ 3 ], e[ 4 ] ), Nil ) } )
	
//	nVias := Iif( mv_par06 == 0 .Or. mv_par06 == Nil, 1, mv_par06 )
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

    If !T_PED->( Eof() )
       _nDfinan := T_PED->C7_DFIN
    Else
       _nDfinan := T_PED->C7_DFIN
    Endif       

	For nViasImp := 1 To nVias
	
		_nQuant  := 0
		_nTot    := 0
		_nIpi    := 0
		_nRetido := 0
		_nFrete  := 0
		aObs     := {}
		cObs     := ""

        nNumeroPro := 10
		
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
				_cPrevisao := T_PED->C7_DATPRF
				_cPrazoPag := Posicione( "SE4", 1, xFilial("SE4") + T_PED->C7_COND, "E4_DESCRI" )

                Do Case
                   Case Alltrim(T_PED->C7_TPFRETE) == "C"
   				        _TpFrete   := "C I F"
                   Case Alltrim(T_PED->C7_TPFRETE) == "F"
   				        _TpFrete   := "F O B"
                   OtherWise 
   				        _TpFrete   := ""
   			    EndCase	        
              
                // Pesquisa a Transportadora
                If Empty(Alltrim(T_PED->C7_TRANSP))
                   _Transporte := ""
                Else
    			   _Transporte := Posicione( "SA4", 1, xFilial("SA4") + T_PED->C7_TRANSP, "A4_NOME" )                   
    			Endif

				If _nMoeda > 1
					_dCotDia := Iif( mv_par07 == 1, T_PED->C7_EMISSAO, _dCotDia )
					_nCotDia := Posicione( "SM2", 1, _dCotDia, "M2_MOEDA2" )
				Else
					_nCotDia := 1
				EndIf

				// Imprime o cabeçalho da pagina
			    PrintCabec()

			EndIf
	
			cObs += " "+ AllTrim( T_PED->C7_OBS )

           // Verifica se existe execeção fiscal
   	       If (Select( "T_DETALHES" ) != 0 )
		      T_DETALHES->( DbCloseArea() )
	       EndIf

           cSql := ""
           cSql := "SELECT F7_ALIQDST,"
           cSql += "       F7_MARGEM  "
           cSql += "  FROM SF7" + kEmpresa + "0"
           cSql += " WHERE F7_GRTRIB  = '" + Alltrim(Posicione("SB1", 1, xFilial("SB1") + T_PED->C7_PRODUTO, "B1_GRTRIB")) + "'"
           cSql += "   AND F7_EST     = '" + Alltrim(Posicione("SA1", 1, xFilial("SA1") + T_PED->C7_FORNECE + T_PED->C7_LOJA, "A1_EST"))     + "'"
           cSql += "   AND F7_TIPOCLI = '" + Alltrim(Posicione("SA1", 1, xFilial("SA1") + T_PED->C7_FORNECE + T_PED->C7_LOJA, "A1_TIPO"))    + "'"
           cSql += "   AND F7_GRPCLI  = '" + Alltrim(Posicione("SA1", 1, xFilial("SA1") + T_PED->C7_FORNECE + T_PED->C7_LOJA, "A1_GRPTRIB")) + "'"
           cSql += "   AND D_E_L_E_T_ = ''"
           cSql += "   AND F7_FILIAL  = '" + Alltrim(kFilial) + "'"
                   
  	       cSql := ChangeQuery( cSql )
 	       dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_DETALHES",.T.,.T.)

           _MVA     := 0
           _ALIQINT := 0

           If T_DETALHES->( EOF() )
              _MVA     := 0
              _ALIQINT := 0
           Else
              If T_DETALHES->F7_ALIQDST == 0
              Else
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

           IF (T_PED->C7_QUANT - INT(T_PED->C7_QUANT)) == 0

              xx_zCusto := (T_PED->C7_PRECO   * Iif( mv_par08 == 2, _nCotDia, 1 )) + ;
                           (T_PED->C7_VALIPI  * Iif( mv_par08 == 2, _nCotDia, 1 )) + ;
                           (T_PED->C7_ICMSRET * Iif( mv_par08 == 2, _nCotDia, 1 )) 

              // Transform( T_PED->C7_ZCUSTO  * Iif( mv_par08 == 2, _nCotDia, 1 ), "@E 999,999.99") + " " + ;

              cStringProduto := T_PED->C7_ITEM                  + " " + ;
                                Substr(T_PED->C7_PRODUTO,01,06) + " " + ;
                                Substr(T_PED->C7_PARTNUM,01,20) + " " + ;
                                IIF( mv_par05 == 2, T_PED->C7_DESCRI, Posicione( "SB1", 1, xFilial("SB1") + T_PED->C7_PRODUTO, "B1_DESC" )) + " " + ;
                                T_PED->C7_UM                    + " " + ;
                                Transform( T_PED->C7_QUANT, "@E 9999999") + " " + ;
                                Transform( T_PED->C7_PRECO   * Iif( mv_par08 == 2, _nCotDia, 1 ), "@E 999,999.99") + " " + ;
                                Transform( T_PED->C7_TOTAL   * Iif( mv_par08 == 2, _nCotDia, 1 ), "@E 999,999.99") + " " + ;
                                Transform( T_PED->C7_IPI, "@E 999.99")                                             + " " + ;
                                Transform( T_PED->C7_VALIPI  * Iif( mv_par08 == 2, _nCotDia, 1 ), "@E 999,999.99") + " " + ;
                                Transform( T_PED->C7_ICMSRET * Iif( mv_par08 == 2, _nCotDia, 1 ), "@E 999,999.99") + " " + ;
                                Transform( xx_zCusto, "@E 999,999.99")                                             + " " + ;
                                Transform( T_PED->C7_BASEICM * Iif( mv_par08 == 2, _nCotDia, 1 ), "@E 999,999.99") + " " + ;
                                Transform( T_PED->C7_PICM, "@E 999.99")                                            + " " + ;
                                Transform( T_PED->C7_VALICM  * Iif( mv_par08 == 2, _nCotDia, 1 ), "@E 999,999.99") + " " + ;
                                Transform( _ALIQINT, "@E 999.99")                                                  + " " + ;
                                Transform( _MVA    , "@E 999.99")                                                  + " " + ;
                                Substr(T_PED->C7_DATPRF,07,02) + "/" + Substr(T_PED->C7_DATPRF,05,02) + "/" + Substr(T_PED->C7_DATPRF,01,04)
           Else

              xx_zCusto := (T_PED->C7_PRECO   * Iif( mv_par08 == 2, _nCotDia, 1 )) + ;
                           (T_PED->C7_VALIPI  * Iif( mv_par08 == 2, _nCotDia, 1 )) + ;
                           (T_PED->C7_ICMSRET * Iif( mv_par08 == 2, _nCotDia, 1 )) 

              // Transform( T_PED->C7_ZCUSTO  * Iif( mv_par08 == 2, _nCotDia, 1 ), "@E 999,999.99") + " " + ;

              cStringProduto := T_PED->C7_ITEM                  + " " + ;
                                Substr(T_PED->C7_PRODUTO,01,06) + " " + ;
                                Substr(T_PED->C7_PARTNUM,01,20) + " " + ;
                                IIF( mv_par05 == 2, T_PED->C7_DESCRI, Posicione( "SB1", 1, xFilial("SB1") + T_PED->C7_PRODUTO, "B1_DESC" )) + " " + ;
                                T_PED->C7_UM                    + " " + ;
                                Transform( T_PED->C7_QUANT, "@E 9999.99") + " " + ;
                                Transform( T_PED->C7_PRECO   * Iif( mv_par08 == 2, _nCotDia, 1 ), "@E 999,999.99") + " " + ;
                                Transform( T_PED->C7_TOTAL   * Iif( mv_par08 == 2, _nCotDia, 1 ), "@E 999,999.99") + " " + ;
                                Transform( T_PED->C7_IPI, "@E 999.99")                                             + " " + ;
                                Transform( T_PED->C7_VALIPI  * Iif( mv_par08 == 2, _nCotDia, 1 ), "@E 999,999.99") + " " + ;
                                Transform( T_PED->C7_ICMSRET * Iif( mv_par08 == 2, _nCotDia, 1 ), "@E 999,999.99") + " " + ;
                                Transform( xx_zCusto                                            , "@E 999,999.99") + " " + ;
                                Transform( T_PED->C7_BASEICM * Iif( mv_par08 == 2, _nCotDia, 1 ), "@E 999,999.99") + " " + ;
                                Transform( T_PED->C7_PICM, "@E 999.99")                                            + " " + ;
                                Transform( T_PED->C7_VALICM  * Iif( mv_par08 == 2, _nCotDia, 1 ), "@E 999,999.99") + " " + ;
                                Transform( _ALIQINT, "@E 999.99")                                                  + " " + ;
                                Transform( _MVA    , "@E 999.99")                                                  + " " + ;
                                Substr(T_PED->C7_DATPRF,07,02) + "/" + Substr(T_PED->C7_DATPRF,05,02) + "/" + Substr(T_PED->C7_DATPRF,01,04)
           Endif           
                                                  
           oPrint:Say( _nLin, 060, cStringProduto, oFont08c )
           
           // ###################################################################################################
           // Verifica se existe a informação de Largura, Metragem e Quantidade de Bobina. Se existir, imprime ##
           // ###################################################################################################
           If (T_PED->C7_LARG + T_PED->C7_METR + T_PED->C7_QBOB) <> 0 

  			  SomaLinha(40)
           
              cStringProduto := "    "                 + " " + ;
                                "      "               + " " + ;
                                "                    " + " " + ;
                                "Largura: " + Alltrim(Str(T_PED->C7_LARG)) + "  Metragem: " + Alltrim(Str(T_PED->C7_METR,10,03)) +  "  Qtd.Bobinas: " + Alltrim(Str(T_PED->C7_QBOB))

              oPrint:Say( _nLin, 060, cStringProduto, oFont08c )
              
           Endif

//			oPrint:Say( _nLin, 0100, T_PED->C7_ITEM   , oFont09 )
//			oPrint:Say( _nLin, 0200, T_PED->C7_PRODUTO, oFont09 )
//			oPrint:Say( _nLin, 0350, T_PED->C7_PARTNUM, oFont09 )
//			oPrint:Say( _nLin, 0890, Iif( mv_par05 == 2, T_PED->C7_DESCRI, Posicione( "SB1", 1, xFilial("SB1") + T_PED->C7_PRODUTO, "B1_DESC" ) ), oFont09 )
//			oPrint:Say( _nLin, 1470, PadC( T_PED->C7_UM, 2 ), oFont09 )
//			oPrint:Say( _nLin, 1620, PadL( Transform( T_PED->C7_QUANT, "@E 999,999.99"), 11 ), oFont09,,,,1 )
// 			oPrint:Say( _nLin, 1810, PadL( Transform( T_PED->C7_PRECO * Iif( mv_par08 == 2, _nCotDia, 1 ), "@E 999,999,999.99"), 15 ), oFont09,,,,1 )
//			oPrint:Say( _nLin, 2010, PadL( Transform( T_PED->C7_TOTAL * Iif( mv_par08 == 2, _nCotDia, 1 ), "@E 999,999,999.99"), 15 ), oFont09,,,,1 )
//			oPrint:Say( _nLin, 2200, PadL( Transform( T_PED->C7_ZCUSTO * Iif( mv_par08 == 2, _nCotDia, 1 ), "@E 999,999,999.99"), 15 ), oFont09,,,,1 )
//			oPrint:Say( _nLin, 2210, Substr(T_PED->C7_DATPRF,07,02) + "/" + Substr(T_PED->C7_DATPRF,05,02) + "/" + Substr(T_PED->C7_DATPRF,01,04), oFont09)

			SomaLinha(50)
			
			_nQuant  += T_PED->C7_QUANT
			_nTot    += T_PED->C7_TOTAL   * Iif( mv_par08 == 2, _nCotDia, 1 )
			_nIpi    += T_PED->C7_VALIPI  * Iif( mv_par08 == 2, _nCotDia, 1 )
			_nRetido += T_PED->C7_ICMSRET * Iif( mv_par08 == 2, _nCotDia, 1 )
            _nFrete  += T_PED->C7_VALFRE  * Iif( mv_par08 == 2, _nCotDia, 1 )
			
			_cPedAtu := T_PED->C7_NUM
	
            nNumeroPro := nNumeroPro - 1

			T_PED->( dbSkip() )
			
		End

        // Abre o espaço total destinado aos produtos
        If nNumeroPro <> 0
           For nContar = 1 to nNumeroPro
 		       SomaLinha(50)           
 		   Next nContar
 		Endif       

        // Desenhas os traços verticais no bloco de produtos
        For nContar = 1 to 41
        	oPrint:Say( __Vertical, 060, "    |      |                    |                              |  |       |          |          |      |          |          |          |          |      |          |      |      |", oFont08c )
	        __Vertical := __Vertical + 14
        Next nContar

        // Imprime o Rodapé do Pedido de Compra
		PrintRodape()
		
	Next
	
	T_PED->( dbCloseArea() )

	oPrint:Preview()
	
	MS_FLUSH()

Return                                               

// Retorna um array com as linhas de texto do campo memo
Static Function MemoObs( cTexto, nTam )

	Local aObserv := {}
	Local nPos := 1
	Local nLinhas := nResto := 0
	
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

	oPrint:Line( _nLin, 0050, _nLin, 3300 )

	SomaLinha(50)
	oPrint:Line( _nLin, 1420, _nLin + 300, 1420 )

	oPrint:Say( _nLin, 0100, "Condição de Pagamento", oFont10b )

    // Imprime a quantidade total e o sub-total do pedido de compra
	oPrint:Say( _nLin, 1470, "Valor Total dos Produtos", oFont10b )
	oPrint:Say( _nLin, 2430, PadL( Transform( _nQuant, "@E 999,999,999.99"), 15 ), oFont12b,,,,1 )
	oPrint:Say( _nLin, 3020, PadL( Transform( _nTot  , "@E 999,999,999.99"), 15 ), oFont12b,,,,1 )

    // Imprime a prazo de pagamento (Condição de Pagamento)
	SomaLinha(50)
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
	oPrint:Line( _nLin - 5, 1420, _nLin - 5, 3300 )
	oPrint:Say( _nLin, 1470, "Valor Total do Pedido", oFont12b )

	oPrint:Say( _nLin, 3020, PadL( Transform( _nTot + _nIpi + _nRetido + _nFrete - _nDfinan, "@E 999,999,999.99"), 15 ), oFont12b,,,,1 )

    // Imprime o noe da transportadora se informado
    If !Empty(Alltrim(_Transporte))
   	   SomaLinha(50)
	   oPrint:Say( _nLin, 0100, "Transportadora", oFont10b )
	   SomaLinha(50)
	   oPrint:Say( _nLin, 0100, _Transporte, oFont10 )
	Endif

	SomaLinha(60)
	If _nMoeda > 1
		oPrint:Say( _nLin, 0100, "Cotação US$", oFont10b )
		oPrint:Say( _nLin + 50, 0100, "R$ "+ AllTrim( Transform( _nCotDia, "@E 99.9999") ) +" - "+ DtoC( StoD( _dCotDia ) ), oFont10 )
	EndIf

	SomaLinha(110)
	oPrint:Line( _nLin, 1470, _nLin, 2320 )
	oPrint:Line( _nLin, 2520, _nLin, 3250 )
	oPrint:Say( _nLin, 1470, "Assinatura do Cliente"  , oFont08 )
	oPrint:Say( _nLin, 2520, "Assinatura do Comprador", oFont08 )
	SomaLinha(50)
	oPrint:Say( _nLin + 40, 0100, "Observações: ", oFont10b )

	aObs := MemoObs( cObs, 100 )

	If Len( aObs ) >= 1
		For nX := 1 To Len( aObs )
			SomaLinha(40)
			oPrint:Say( _nLin, 0350, aObs[ nX ], oFont10 )
		Next
	EndIf

    // Imprime Observações ref, solicitação na tarefa 
	SomaLinha(75)    
    oPrint:Say( _nLin,0080, "* * * A partir do dia 10/07/2016 o horário de recebimento de mercadorias será somente no turno da manhã das 8:15 às 12:00 Hrs.", oFont14b )

	SomaLinha(100)    
    oPrint:Say( _nLin, 0060, "Os valores descritos no pedido incluem todos os impostos para o RS.", oFont08 )
	SomaLinha(50)    
    oPrint:Say( _nLin, 0060, "O fornecedor é integralmente responsável por possíveis valores adicionais de ICMS não destacados na nota fiscal, bem como por qualquer tipo de multa ou penalização sofrida pela Automatech devido ao destaque incorreto de impostos.", oFont08 )

//  oPrint:Say( _nLin, 0060, "O fornecedor é integralmente responsável por possíveis valores adicionais de ICMS não destacados na nota fiscal,", oFont10 )
//	SomaLinha(50)    
//  oPrint:Say( _nLin, 0060, "bem como por qualquer tipo de multa ou penalização sofrida pela Automatech devido ao destaque incorreto de impostos.", oFont10 )

    SomaLinha(50)

	oPrint:Line( 060, 0050, _nLin, 0050 )    
	oPrint:Line( 060, 3300, _nLin, 3300 )    
	oPrint:Line( _nLin, 0050, _nLin, 3300 )    

	oPrint:EndPage()
	
	_nQuant := 0
	_nTot   := 0
	_nIpi   := 0
	aObs    := {}
	cObs    := ""

Return

// Inicia nova página e imprime o cabeçalho, ajustando a linha para impressão
Static Function PrintCabec()

	oPrint:StartPage()

    _nLin := 60
	oPrint:Line( _nLin, 050, _nLin, 3300 )    
    _nLin := 70	

	dbSelectArea("SM0")
	SM0->( DbSeek( cEmpAnt + cFilAnt ) )
	
	// Dados de cadastro
    Do Case
       Case cEmpAnt == "01"
    	    oPrint:Say( _nLin, 1000, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont10b )
       Case cEmpAnt == "02"
    	    oPrint:Say( _nLin, 1000, "TI AUTOMAÇÃO E SERVIÇOS LTDA", oFont10b )
       Case cEmpAnt == "03"
    	    oPrint:Say( _nLin, 1000, "ATECH SERVIÇOS DE AUTOMAÇÃO LTDA", oFont10b )
    	    
    EndCase
    	    
    _nLin += 50

	// Logotipo e identificação do pedido
	oPrint:SayBitmap( _nLin, 0100, "pclogoautoma.bmp", 0700, 0200 )

    // Endereço da Automatech
	oPrint:Say( _nLin, 1000, AllTrim( SM0->M0_ENDENT ) +" "+ AllTrim( SM0->M0_COMPENT ), oFont10b )
	oPrint:Say( _nLin, 2725, "ORDEM DE COMPRA", oFont14b )
    _nLin += 50

    // Cidade / Estado / CEP
	oPrint:Say( _nLin, 1000, Alltrim(SM0->M0_CIDENT) + "/" + Alltrim(SM0->M0_ESTENT), oFont10b )
    _nLin += 50

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

    // E-Mail
    oPrint:Say( _nLin, 1000, "automatech@automatech.com.br", oFont10b )
	_nLin += 50

	oPrint:Line( 060, 2650, _nLin, 2650 )
	oPrint:Line( _nLin, 0050, _nLin, 3300 )

    __Vertical := _nLin

    _nLin += 50

	// Dados do fornecedor
	oPrint:Say( _nLin, 0100, "Fornecedor:", oFont10 )
	oPrint:Say( _nLin, 0330, "["+ T_PED->A2_COD +"] "+ T_PED->A2_NOME, oFont10b )
	oPrint:Say( _nLin, 1500, "Fone/Fax:", oFont10 )
	oPrint:Say( _nLin, 1730, Transform( AllTrim( T_PED->A2_DDD ) + T_PED->A2_TEL, "@R (99) 9999-9999" )+"/"+Transform( AllTrim( T_PED->A2_DDD ) + T_PED->A2_FAX, "@R (99) 9999-9999" ), oFont10b )
	oPrint:Say( _nLin, 2470, "Emissão:", oFont10 )
	oPrint:Say( _nLin, 2700, DtoC( dDataBase ) +" "+ Time(), oFont10b )

    _nLin += 50	
	
	oPrint:Say( _nLin, 0100, "Endereço:", oFont10 )
	oPrint:Say( _nLin, 0330, AllTrim( T_PED->A2_END ) +" "+ AllTrim( T_PED->A2_BAIRRO ) +" "+ Transform( AllTrim( T_PED->A2_CEP ), "@R 99999-999"), oFont10b )
	oPrint:Say( _nLin, 1500, "Cidade:", oFont10 )
	oPrint:Say( _nLin, 1730, T_PED->A2_MUN, oFont10b )
	oPrint:Say( _nLin, 2470, "Comprador:", oFont10 )
	oPrint:Say( _nLin, 2700, T_PED->C7_CONTATO, oFont10b )

    _nLin += 50	
    	
	oPrint:Say( _nLin, 0100, "E-mail:", oFont10 )
	oPrint:Say( _nLin, 0330, AllTrim( T_PED->A2_EMAIL ), oFont10b )
	oPrint:Say( _nLin, 1500, "Estado:", oFont10 )
	oPrint:Say( _nLin, 1730, T_PED->A2_EST, oFont10b )

    _nLin += 50	
 
    // Desenha a linha vertical
	oPrint:Line( __Vertical, 2420, _nLin, 2420 )

	oPrint:Line( _nLin, 0050, _nLin, 3300 )

    __Vertical := _nLin

    _nLin += 20	

    // Imprime o título dos produtos
    If T_PED->C7_MOEDA == 1 
       oPrint:Say( _nLin, 1200, "P R O D U T O S - Valores expressos em R$", oFont12b )    
    Else
       oPrint:Say( _nLin, 1200, "P R O D U T O S - Valores expressos em US$", oFont12b )    
    Endif       

    _nLin += 70	
	oPrint:Line( _nLin, 0050, _nLin, 3300 )

    __Vertical := _nLin

    _nLin += 20	

	// Cabeçalhos dos itens
	oPrint:Say( _nLin, 0060, "ITEM CÓDIGO PART NUMBER          DESCRIÇÃO DOS PRODUTOS         UN     QTD   UNITÁRIO  VLR.TOTAL  % IPI    VLR.IPI    ICMS ST CUSTO UNT.  BASE ICMS % ICMS   VLR.ICMS  % MVA ICMS I ENTREGA", oFont08cb )
    _nLin += 50	
	oPrint:Line( _nLin, 0050, _nLin, 3300 )
    _nLin += 30	

//  _nLin += 50	
//	oPrint:Say( _nLin, 0100, "Item", oFont09b )
//	oPrint:Say( _nLin, 0200, "Código", oFont09b )
//	oPrint:Say( _nLin, 0350, "Part Number", oFont09b )
//	oPrint:Say( _nLin, 0890, "Descrição", oFont09b )
//	oPrint:Say( _nLin, 1470, "UN.", oFont09b )
//	oPrint:Say( _nLin, 1630, PadL( "QTD", 11 ), oFont09b,,,,1 )
// 	oPrint:Say( _nLin, 1810, PadL( "Unit. "   + Iif( T_PED->C7_MOEDA == 1 .Or. mv_par08 == 2, "R$", "US$" ), 15 ), oFont09b,,,,1 )
//	oPrint:Say( _nLin, 2010, PadL( "V.Total "   + Iif( T_PED->C7_MOEDA == 1 .Or. mv_par08 == 2, "R$", "US$" ), 15 ), oFont09b,,,,1 )
//	oPrint:Say( _nLin, 2200, PadL( "C.Total " + Iif( T_PED->C7_MOEDA == 1 .Or. mv_par08 == 2, "R$", "US$" ), 15 ), oFont09b,,,,1 )
//	oPrint:Say( _nLin, 2210, "Entrega", oFont09b)

//    _nLin += 50
//	oPrint:Line( _nLin, 0100, _nLin, 3300 )
//    _nLin += 50

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

	For xxx = 100 to 2400 step 100
		oPrint:Line( 0010, xxx, 0030, xxx )
		oPrint:Say( 0010, xxx+10, AllTrim( Str(xxx) ), oFont08 )
		If xxx > 2400
			Exit
		EndIf
	Next

	For xxx = 50 to 3600 step 50
		oPrint:Line( xxx, 0020, xxx, 0040 )
		oPrint:Say( xxx - 25, 0020, AllTrim( Str( xxx ) ), oFont06 )
		If xxx > 3600
			Exit
		EndIf
	Next

Return