#include "rwmake.ch"
#include "topconn.ch"

#DEFINE IMP_SPOOL 2

// ----------------------------------------------------------------------------------------------------------*
// Fonte.....: AUTR002                                                                                       *
// Autor.....: Samuel Schneider                                                                              *
// Data......: 22/01/2011                                                                                    *
// Descrição.: Relatorio grafico de Proposta de venda                                                        *
// Alteração.: 07/11/2011 - Alteração da impressão da descrição dos produtos + B1_DAUX                       *
// ----------------------------------------------------------------------------------------------------------*
// Alteração: Jean Rehermann | JPC                                                                           *
// -------------------------------                                                                           *
// 1 - Adicionado novos elementos ao relatório                                                               *
// 2 - Ajustado as posições de campos numéricos (alinhamento)                                                *
// 3 - Modificado para permitir impressão diretamente da tela de Oportunidades (sem preencher parâmetros)    *
// 4 - Modificado tamanhos de fontes                                                                         *
// ----------------------------------------------------------------------------------------------------------*

User Function AUTR002(cPar1, cPar2)

	Local   lAutoPar   := .F.
	Private Li         := 0
	Private _nLin      := 0
    Private nPosicao   := 0
	Private oPrint
	Private cPerg      :="AUTOMAR02"
	Private cStrSql    := ""
	Private cConsulta  := ""
	Private nLastKey   := 0
	Private cLoja      := ""
	Private cTaxa      := 0
	Private cNome      := ""
	Private cNumJ      := ""
	Private cNropor	   := ""
	Private cRevisa    := ""
	Private cVend      := ""
	Private cProp      := ""
	Private lInicio    := .T.
	Private cNumPar    := ""
	Private cProp1     := ""
	Private cMoedaDia  := ""
	Private Totger     := ""
	Private cComple    := ""
	Private cData      := ""
	Private _aEntidade := {}
	Private _cProdNCM  := ""
	Private _cCondPag  := ""
	Private _cValidade := ""
	Private _aObserv   := {}
    Private cSql       := ""
    Private aDiferenca := {}
    Private nDifeReal  := 0
    Private nDifeDolar := 0

    Private xRetiR     := 0
    Private xRetiD     := 0
	
	lAutoPar := ( cPar1 != Nil .And. cPar2 != Nil )
	
	GeraPerg( cPerg ) // Cria as perguntas
	
	If lAutoPar
		Pergunte( cPerg, .F. )
		mv_par01 := cPar1
		mv_par02 := cPar1
		mv_par03 := cPar2
		mv_par04 := cPar2
		mv_par05 := CtoD("//")
		mv_par06 := dDataBase + 365
	Else
		If !Pergunte( cPerg, .T. ) // Exibe a tela de parâmetros
			Return
		EndIf
	EndIf

	// Executa a query e cria a área de trabalho
	cStrSql := " SELECT ADY.*        , "
	cStrSql += "        ADZ.*        , "
	cStrSql += "        SB1.B1_GARANT, "
	cStrSql += "        SB1.B1_DESC  , "
	cStrSql += "        SB1.B1_DAUX    "
	cStrSql += "    FROM " + RetSqlName("ADZ") + " ADZ , "
	cStrSql += "         " + RetSqlName("ADY") + " ADY , "
	cStrSql += "         " + RetSqlName("SB1") + " SB1   "
	cStrSql += "  WHERE ADY.ADY_OPORTU  >= '" + MV_PAR01 + "' "
	cStrSql += "    AND ADY.ADY_OPORTU  <= '" + MV_PAR02 + "' "
	cStrSql += "    AND ADY.ADY_PROPOS  >= '" + MV_PAR03 + "' "
	cStrSql += "    AND ADY.ADY_PROPOS  <= '" + MV_PAR04 + "' "
	cStrSql += "    AND ADY.ADY_DATA BETWEEN '" + DtoS( MV_PAR05 ) + "' AND '" + DtoS( MV_PAR06 ) + "'"
	cStrSql += "    AND ADY.ADY_PROPOS   = ADZ.ADZ_PROPOS "
	cStrSql += "    AND ADY.D_E_L_E_T_   = ' ' "
	cStrSql += "    AND ADZ.D_E_L_E_T_   = ' ' "
	cStrSql += "    AND ADY.ADY_FILIAL   = '" + xFilial("ADY") + "' "
	cStrSql += "    AND ADZ.ADZ_FILIAL   = '" + xFilial("ADZ") + "' "
	cStrSql += "    AND ADZ.ADZ_PRODUT   = SB1.B1_COD "
	cStrSql += "  ORDER BY ADY.ADY_FILIAL, ADZ.ADZ_PROPOS , ADZ.ADZ_ITEM"

	If( Select( "TMPO" ) != 0 )
		TMPO->( DbCloseArea() )
	EndIf

    // Função que calcula o valor do diferencial de Alíquotas para impressão
    xRetiR := 0
    xRetiD := 0

    XDIFE_ICMS(mv_par01, mv_par02, mv_par03, mv_par04, mv_par05, mv_par06)

	cStrSql := ChangeQuery( cStrSql )
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrSql),"TMPO",.T.,.T.)

 	oPrint := TMSPrinter():New()

	oPrint:SetPaperSize(9)
	oPrint:SetPortrait()
	oPrint:StartPage()

    oPrint:SaveAllAsJpeg("d:\relatorios\proposta",1180,1600,180)

	// Cria os objetos de fontes que serao utilizadas na impressao do relatorio
	oFont06   := TFont():New( "Arial",,06,,.f.,,,,.f.,.f. )
	oFont08   := TFont():New( "Arial",,08,,.f.,,,,.f.,.f. )
	oFont08b  := TFont():New( "Arial",,08,,.t.,,,,.f.,.f. )
	oFont09   := TFont():New( "Arial",,09,,.f.,,,,.f.,.f. )
	oFont09b  := TFont():New( "Arial",,09,,.t.,,,,.f.,.f. )
	oFont09n  := TFont():New( "Arial",, 9,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10   := TFont():New( "Arial",,10,,.f.,,,,.f.,.f. )
	oFont10b  := TFont():New( "Arial",,10,,.t.,,,,.f.,.f. )
	oFont11   := TFont():New( "Arial",,11,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont12   := TFont():New( "Arial",,12,,.f.,,,,.f.,.f. )
	oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )
	oFont12n  := TFont():New( "Arial",,12,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont14b  := TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
	oFont16b  := TFont():New( "Arial",,16,,.t.,,,,.f.,.f. )
	oFont20b  := TFont():New( "Arial",,20,,.t.,,,,.f.,.f. )
	oFont25   := TFont():New( "Courier New",,09,,.f.,,,,.f.,.f. )
	oFont25b  := TFont():New( "Courier New",,09,,.t.,,,,.f.,.f. )
	oFont30   := TFont():New( "Courier New",,08,,.t.,,,,.f.,.f. )

	DbSelectArea("SM2")
	dbSetOrder(1)
	If dbSeek( DtoS( dDataBase ) )
		cMoedaDia := M2_MOEDA2
	Else
		MsgAlert("Valores cambiais não encontrados para o dia "+ DtoC( dDataBase ) )
		cMoedaDia := 1
	EndIf

	cNumPar := MV_PAR03
	
	Do While cNumPar <= MV_PAR04
		
		_cEntidade := {}
		_cProdNCM  := ""
		_cCondPag  := ""
		_cValidade := ""
		_aObserv   := {}

		
		cEnt := Iif( TMPO->ADY_ENTIDA == "1", "SA1", "SUS" )
		dbSelectArea( cEnt )
		dbSetOrder(1)
		dbSeek( xFilial(cEnt) + TMPO->ADY_CODIGO + TMPO->ADY_LOJA )
		
		If cEnt == "SA1"
		   aAdd( _cEntidade, { AllTrim( SA1->A1_NOME ), SA1->A1_COD, AllTrim( SA1->A1_END ), AllTrim( SA1->A1_BAIRRO ), Transform( SA1->A1_CEP, "@R 99999-999" ), AllTrim( SA1->A1_MUN ), SA1->A1_EST, Transform(SA1->A1_TEL, "@R 9999-9999"), AllTrim( SA1->A1_EMAIL ), SA1->A1_CGC, SA1->A1_INSCR, ADY->ADY_PARAQ, ADY->ADY_TPFRET, ADY->ADY_ENTREG } )
		ElseIf cEnt == "SUS"
		   aAdd( _cEntidade, { AllTrim( SUS->US_NOME ), SUS->US_COD, AllTrim( SUS->US_END ), AllTrim( SUS->US_BAIRRO ), Transform( SUS->US_CEP, "@R 99999-999" ), AllTrim( SUS->US_MUN ), SUS->US_EST, Transform(SUS->US_TEL, "@R 9999-9999"), AllTrim( SA1->A1_EMAIL ), SA1->A1_CGC, SA1->A1_INSCR, ADY->ADY_PARAQ, ADY->ADY_TPFRET, ADY->ADY_ENTREG } )
		EndIf

	    // Pesquisa a condição de pagamento a ser impressa
		DbSelectArea("TMPO")
        _cCondPag  := TMPO->ADZ_CONDPG
		
		Cabecalho()

        _nLin := _nLin - 20
		
		DbSelectArea("TMPO")
		Store 0 to tValorR, tValorU, Totger
		Do while !eof() .And. cProp1 == TMPO->ADZ_PROPOS .AND. cNropor == ADY_OPORTU
			
			DbSelectArea("TMPO")
			
//			oPrint:Say ( _nLin, 0110, TMPO->ADZ_ITEM   , oFont08 )

			oPrint:Say ( _nLin, 0110, TMPO->ADZ_PRODUTO, oFont08 )

            If Alltrim(TMPO->ADZ_PRODUTO) == "002043"
               cDescricao := Alltrim(TMPO->ADZ_DESCRI)
            Else   
               cDescricao := Alltrim(TMPO->B1_DESC) + " " + Alltrim(TMPO->B1_DAUX)
            Endif

            If Len(cDescricao) > 45
   			   oPrint:Say ( _nLin, 0400, Substr(cDescricao,01,45), oFont30 )
   			Else
   			   oPrint:Say ( _nLin, 0400, cDescricao, oFont30 )   			   
   			Endif

			oPrint:Say ( _nLin, 1215, PadC( Iif( TMPO->ADZ_MOEDA == "1", "R$", "US$" ), 10 ), oFont08 )

			If (TMPO->ADZ_QTDVEN - INT(TMPO->ADZ_QTDVEN)) == 0
   			   oPrint:Say ( _nLin, 1380, PadL( Transform( TMPO->ADZ_QTDVEN , "@E 99,999,999"), 14 ), oFont08,,,,1 )
   			Else
   			   oPrint:Say ( _nLin, 1380, PadL( Transform( TMPO->ADZ_QTDVEN , "@E 99,999,999.99"), 14 ), oFont08,,,,1 )
   			Endif   

//			oPrint:Say ( Li + 0550, 1510, PadL( Transform( TMPO->ADZ_QTDVEN , "@E 99,999,999.99"), 14 ), oFont08,,,,1 )
			oPrint:Say ( _nLin, 1470, PadC( TMPO->ADZ_UM, 02 ), oFont08 )
			oPrint:Say ( _nLin, 1655, PadL( Transform( TMPO->ADZ_PRCVEN , "@E 99,999,999.99"), 14 ), oFont08,,,,1 )
			oPrint:Say ( _nLin, 1845, PadL( Transform( TMPO->ADZ_TOTAL  , "@E 99,999,999.99"), 14 ), oFont08,,,,1 )

            // Verifica se existe diferencial para o item/produto lido
            nDiferencial := 0
            For nContar = 1 to Len(aDiferenca)
                If Alltrim(aDiferenca[nContar,01]) == Alltrim(TMPO->ADZ_ITEM) .And. Alltrim(aDiferenca[nContar,02]) == Alltrim(TMPO->ADZ_PRODUTO)
                   If TMPO->ADZ_MOEDA == "1"
                      nDiferencial := aDiferenca[nContar,03]
                   Else
                      nDiferencial := aDiferenca[nContar,04]
                   Endif
                   Exit
                Endif
            Next nContar

        	oPrint:Say ( _nLin, 1990, PadL( Transform( nDiferencial  , "@E 999,999.99"), 14 )   , oFont08,,,,1 )

            If TMPO->ADZ_MOEDA == "1"
   	 		   oPrint:Say ( _nLin, 2175, PadL( Transform( TMPO->ADZ_TOTAL  + nDiferencial , "@E 99,999,999.99"), 14 ), oFont08,,,,1 )
   	 		Else
   	 		   oPrint:Say ( _nLin, 2175, PadL( Transform( TMPO->ADZ_TOTAL  + nDiferencial, "@E 99,999,999.99"), 14 ), oFont08,,,,1 )   	 		   
   	 		Endif

			oPrint:Say ( _nLin, 2240, Alltrim(TMPO->B1_GARANT), oFont08 )

            If Len(cDescricao) > 45
               _nLin += 50
               If Len(cDescricao) < 90
                  oPrint:Say( _nLin, 0400, Substr(cDescricao,46,45), oFont30)
                  _nLin += 50
               Else
                  oPrint:Say( _nLin, 0400, Substr(cDescricao,46,45), oFont30)
                  _nLin += 50
                  oPrint:Say( _nLin, 0400, Substr(cDescricao,91), oFont30)              
                  _nLin += 50
               Endif
            Endif   
			
			_cProdNCM += AllTrim( TMPO->ADZ_PRODUTO ) +" / "+ Transform( Posicione( "SB1", 1, xFilial("SB1") + TMPO->ADZ_PRODUTO, "B1_POSIPI" ), "@R 9999.99.99" ) +" - "
		    _cCondPag  := TMPO->ADZ_CONDPG
			_cValidade := DtoC( StoD( TMPO->ADY_VAL ) )
			
			If TMPO->ADZ_MOEDA == "2"
				tValorU += TMPO->ADZ_TOTAL + nDiferencial
			Else
				tValorR += TMPO->ADZ_TOTAL + nDiferencial
			EndIf
			
			_nLin := _nLin + 50
			
			TMPO->( dbSkip() )
			
		EndDo

        // Desenhas os traços verticais dos produtos
		oPrint:Line(_nLin,0100, _nLin, 2330)

//		oPrint:Line(nPosicao,0195, _nLin, 0195)
		oPrint:Line(nPosicao,0395, _nLin, 0395)
		oPrint:Line(nPosicao,1195, _nLin, 1195)
		oPrint:Line(nPosicao,1315, _nLin, 1315)
		oPrint:Line(nPosicao,1455, _nLin, 1455)
		oPrint:Line(nPosicao,1520, _nLin, 1520)
		oPrint:Line(nPosicao,1675, _nLin, 1675)
		oPrint:Line(nPosicao,1865, _nLin, 1865)

		oPrint:Line(nPosicao,2000, _nLin, 2000)

		oPrint:Line(nPosicao,2190, _nLin, 2190)

        _nLin := _nLin + 30
		oPrint:Say (_nLin,110 ,"TOTAIS",oFont11)

        If tValorR <> 0
   		   oPrint:Say (_nLin,1900,"R$",oFont11)
		   oPrint:Say (_nLin,2300,transform(tValorR,"@E 9,999,999,999,999.99"),oFont11,,,,1)
           _nLin := _nLin + 50
        Endif
           
		If tValorU <> 0
 		   oPrint:Say (_nLin,1900,"US$",oFont11)
		   oPrint:Say (_nLin,2300,transform(tValorU,"@E 9,999,999,999,999.99"),oFont11,,,,1)
           _nLin := _nLin + 50
        Endif

     	oPrint:Line ( _nLin, 0100, _nLin, 2330 )
        _nLin := _nLin + 50

        If tValorR <> 0
   		   oPrint:Say (_nLin,0800,"SUB-TOTAL EM R$" ,oFont11)
 		   oPrint:Say (_nLin,1600,"SUB-TOTAL EM US$",oFont11)
		   oPrint:Say (_nLin,1400,transform((tValorR - xRetiR),"@E 9,999,999,999,999.99"),oFont11,,,,1)
		   oPrint:Say (_nLin,2300,transform((tValorU - xRetiD),"@E 9,999,999,999,999.99"),oFont11,,,,1)
           _nLin := _nLin + 50

   		   oPrint:Say (_nLin,0800,"DIF. ALIQUOTA EM R$" ,oFont11)
   		   oPrint:Say (_nLin,1600,"DIF. ALIQUOTA EM US$",oFont11)
		   oPrint:Say (_nLin,1400,transform(xRetiR,"@E 9,999,999,999,999.99"),oFont11,,,,1)
		   oPrint:Say (_nLin,2300,transform(xRetiD,"@E 9,999,999,999,999.99"),oFont11,,,,1)
           _nLin := _nLin + 50

   		   oPrint:Say (_nLin,0800,"TOTAL EM R$" ,oFont11)
   		   oPrint:Say (_nLin,1600,"TOTAL EM US$",oFont11)
//		   oPrint:Say (_nLin,1400,transform(tValorR + xRetiR,"@E 9,999,999,999,999.99"),oFont11,,,,1)
//		   oPrint:Say (_nLin,2300,transform(tValorU + xRetiD,"@E 9,999,999,999,999.99"),oFont11,,,,1)
		   oPrint:Say (_nLin,1400,transform(tValorR,"@E 9,999,999,999,999.99"),oFont11,,,,1)
		   oPrint:Say (_nLin,2300,transform(tValorU,"@E 9,999,999,999,999.99"),oFont11,,,,1)
           _nLin := _nLin + 50
        Endif

//		If tValorU <> 0
// 		   oPrint:Say (_nLin,1900,"US$",oFont11)
//		   oPrint:Say (_nLin,2300,transform(tValorU,"@E 9,999,999,999,999.99"),oFont11,,,,1)
//           _nLin := _nLin + 50
//        Endif


		oPrint:Line(nPosicao,0100, _nLin, 0100)        
		oPrint:Line(nPosicao,2330, _nLin, 2330)        
		oPrint:Line(_nLin,100,_nLin,2330)
        _nLin := _nLin + 30

		// Gera as linhas para as NCMs
		_aObserv := MemoObs( SubStr( _cProdNCM, 1, Len( _cProdNCM ) - 2 ), 180 )

		oPrint:Say (_nLin,0110 ,"[ Código Produto / NCM ]",oFont08)

        _nLin := _nLin + 50
		
		oPrint:Say (_nLin,0110,_aObserv[1],oFont08)

        _nLin := _nLin + 50

		For nX := 2 To Len( _aObserv )
			oPrint:Say (_nLin,0110,_aObserv[nX],oFont08)
            _nLin := _nLin + 50
		Next

        _nLin := _nLin + 50

		oPrint:Line(nPosicao,0100, _nLin, 0100)        
		oPrint:Line(nPosicao,2330, _nLin, 2330)        
		oPrint:Line(_nLin,0100,_nLin,2330)

        // Imprime as Observações do Pedido
        _nLin := _nLin + 30
		oPrint:Say (_nLin,0110,"Observações: ",oFont09n)
		_nLin := _nLin + 50

		// Gera as linhas para as observações
		_cObs := AllTrim( ADY->ADY_OBSP )
		_aObserv := MemoObs( _cObs, 100 )
		For nX := 1 To Len( _aObserv )
			oPrint:Say (_nLin,0110,_aObserv[nX],oFont08)
			_nLin := _nLin + 50
		Next
  
		oPrint:Line(nPosicao,0100, _nLin, 0100)        
		oPrint:Line(nPosicao,2330, _nLin, 2330)        
		oPrint:Line(_nLin,0100,_nLin,2330)

        _nLin := _nLin + 30

        oPrint:Say( _nLin, 0110, "Os valores cotados em dólar serão convertidos em real de acordo com a taxa do dólar comercial (PTAX venda) do dia do faturamento.", oFont09b)

        _nLin := _nLin + 100

        oPrint:Say( _nLin, 0110, "Sem mais para o momento nos colocamos à disposição para auxiliá-los no que for preciso.", oFont09b)

        _nLin := _nLin + 100
        oPrint:Say( _nLin, 0110, "Atenciosamente", oFont09b)    
        oPrint:Line( _nLin, 1800, _nLin, 2300 )

        _nLin := _nLin + 50
        oPrint:Say (_nLin,0110, Upper( Posicione( "SA3", 1, xFilial("SA3") + cVend, "A3_NOME" ) ),oFont10b)

        oPrint:Say( _nLin, 1900, "Aceite do Cliente", oFont09b)    
        _nLin := _nLin + 100

        oPrint:Line( _nLin, 0100, _nLin, 2330 )
        oPrint:Line( 0060, 0100, _nLin, 0100 )
        oPrint:Line( 0060, 2330, _nLin, 2330 )

        _nLin := _nLin + 050
        oPrint:Say( _nLin, 0110, "AUTR002.PRW", oFont06)        

		If !Eof()
			cNumPar := ADY->ADY_PROPOS
			oPrint:EndPage()
			oPrint:StartPage()
			li:=0
		Else
			Exit
		Endif
		
	Enddo
	
	TMPO->( DbCloseArea() )

	// oPrint:Setup()
	oPrint:Preview()

	DbCommitAll()
	MS_FLUSH()

Return()

// Monta o cabeçalho da página
Static Function Cabecalho()

    _nLin := 0060

    oPrint:Line( _nLin, 0100, _nLin, 2330 )

    _nLin := _nLin + 50

    // Logotipo e identificação do pedido
//  oPrint:SayBitmap( _nLin, 0110, "logoautoma.bmp", 0700, 0200 )
    oPrint:Say( _nLin, 1000, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont12b  )
    _nLin := _nLin + 70
    oPrint:SayBitmap( _nLin, 0110, "logoautoma.bmp", 0700, 0200 )
    oPrint:Say( _nLin, 1000, "Matriz:", oFont08  )    
    oPrint:Say( _nLin, 1100, "RUA JOÃO INÁCIO, 1110 - CEP 90.230-181 - PORTO ALEGRE - RS Fone: (51)30178300", oFont08  )    
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1100, "CNPJ: 03.385.913/0001-61    Insc. Estadual: 096/27777447", oFont08  )    
    
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1000, "Filial:", oFont08  )
    oPrint:Say( _nLin, 1100, "RUA JOÃO INÁCIO, 1162 - CEP 90.230-181 - PORTO ALEGRE - RS Fone: (51)30178300", oFont08  )    
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1100, "CNPJ: 03.385.913/0005-95    Insc. Estadual: 096/3531158", oFont08  )    

    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1000, "Filial:", oFont08  )
    oPrint:Say( _nLin, 1100, "RUA SÃO JOSÉ, 1767 - CEP: 95.020-270 - CAXIAS DO SUL - RS Fone: (54)32272333", oFont08  )
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1100, "CNPJ: 03.385.913/0002-42    Insc. Estadual: 029/0448913", oFont08  )    

    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1000, "Filial:", oFont08  )
    oPrint:Say( _nLin, 1100, "RUA GENERAL NETO, 618 - CEP: 96.015-250 - PELOTAS - RS Fone: (53)30262802", oFont08  )
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 0110, "www.automatech.com.br", oFont10  )
    oPrint:Say( _nLin, 1100, "CNPJ: 03.385.913/0004-04    Insc. Estadual: 093/0410289", oFont08  )    

    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1000, "Filial:", oFont08  )
    oPrint:Say( _nLin, 1100, "TI AUTOMAÇÃO E SERVIÇOS LTDA", oFont08  )
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1100, "RUA FERNANDO AMARO, 1600 - CEP: 80.050-432 - CURITIBA - PR Fone: (41)30246675", oFont08  )
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1100, "CNPJ: 12.757.071/0001-12    Insc. Estadual: 9053742146", oFont08  )    

    _nLin := _nLin + 50
    
    oPrint:Line( _nLin, 0100, _nLin, 2330 )

    _nLin := _nLin + 20

    // Pesquisa Nº da Oprtunidade, Proposta Comercial e Data de Emissão para Impressão
    DbSelectArea("AD1")
	DbSetOrder(1)
	DbSeek( xFilial("AD1") + TMPO->ADY_OPORTU )
		
	cNropor := AD1->AD1_NROPOR
	cRevisa := AD1->AD1_REVISA
	cVend   := AD1->AD1_VEND
    oPrint:Say( _nLin, 0110, "Nº Oportunidade: " + cNropor + "/" + cRevisa, oFont12b)
		
	DbSelectArea("ADY")
	DbSetOrder(1)
	DbSeek( xFilial("ADY") + TMPO->ADZ_PROPOS )
		
	cProp1 := ADY_PROPOS
    oPrint:Say( _nLin, 0750, "Nº Proposta: " + cProp1, oFont12b)
    oPrint:Say( _nLin, 1275, "Emissão: "     + DtoC( StoD( TMPO->ADY_DATA ) ), oFont12b)
    oPrint:Say( _nLin, 1800, "Validade: "    + DtoC( StoD( TMPO->ADY_VAL ) ) , oFont12b)


//    oPrint:Say( _nLin, 1000, "Nº Proposta: " + cProp1, oFont12b)
//    oPrint:Say( _nLin, 1750, "Emissão: " + DtoC( StoD( TMPO->ADY_DATA ) ), oFont12b)

    _nLin := _nLin + 70
	oPrint:Line ( _nLin, 0100, _nLin, 2330 )
    _nLin := _nLin + 50

    // Pesquisa dados complementares para impressão
	If( Select( "T_DETALHES" ) != 0 )
		T_DETALHES->( DbCloseArea() )
	EndIf

    cSql := ""
    cSql := "SELECT ADY_FILIAL, "
    cSql += "       ADY_PROPOS, "
    cSql += "       ADY_PARAQ , "
    cSql += "       ADY_ENTREG, "
    cSql += "       ADY_TPFRET  "
    cSql += "  FROM " + RetSqlName("ADY010")
    cSql += " WHERE ADY_PROPOS = '" + Alltrim(cProp1) + "'"
    cSql += "   AND ADY_FILIAL = '" + Alltrim(cEnt)   + "'"

	cStrSql := ChangeQuery( cStrSql )
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrSql),"T_DETALHES",.T.,.T.)

    If !Empty(Alltrim(T_DETALHES->ADY_PARAQ))
       oPrint:Say( _nLin, 0110, "A/C" , oFont10)
       oPrint:Say( _nLin, 0400, Alltrim(T_DETALHES->ADY_PARAQ), oFont10b )
       _nLin := _nLin + 50
    Endif

    oPrint:Say( _nLin, 0110, "Cliente:" , oFont10)
	oPrint:Say( _nLin, 0400, _cEntidade[ 1, 1 ] +" ["+ _cEntidade[ 1, 2 ] +"]", oFont10b )

    oPrint:Say( _nLin, 1500, "Telefone:", oFont10)
    oPrint:Say( _nLin, 1730, _cEntidade[ 1, 8 ], oFont10b)

    _nLin := _nLin + 50

    oPrint:Say( _nLin, 0110, "Endereço:", oFont10)
    oPrint:Say( _nLin, 0400, Alltrim(_cEntidade[ 1, 3 ]), oFont10b)

    oPrint:Say( _nLin, 1500, "Cidade:"  , oFont10)
    oPrint:Say( _nLin, 1730, Alltrim(_cEntidade[ 1, 6 ]) + " - " + AllTrim(_cEntidade[ 1, 5 ]), oFont10b)

    _nLin := _nLin + 50

    oPrint:Say( _nLin, 0110, "Bairro:"  , oFont10)
    oPrint:Say( _nLin, 0400, Alltrim(_cEntidade[ 1, 4 ]), oFont10b)

    oPrint:Say( _nLin, 1500, "Estado:"  , oFont10)
    oPrint:Say( _nLin, 1730, Alltrim(_cEntidade[ 1, 7 ]), oFont10b)

    _nLin := _nLin + 50
    
    oPrint:Say( _nLin, 0110, "E-mail:"  , oFont10)
    oPrint:Say( _nLin, 0400, Alltrim(_cEntidade[ 1, 9 ]), oFont10b)

    _nLin := _nLin + 50
        
    oPrint:Say( _nLin, 0110, "CNPJ/CPF:", oFont10)

    If Len(AllTrim(_cEntidade[ 1, 10 ])) == 14
       oPrint:Say( _nLin, 0400, Substr(_cEntidade[ 1, 10 ],01,02) + "." + Substr(_cEntidade[ 1, 10 ],03,03) + "." + Substr(_cEntidade[ 1, 10 ],06,03) + "/" + Substr(_cEntidade[ 1, 10 ],09,04) + "-" + Substr(_cEntidade[ 1, 10 ],13,02), oFont10b)
    Else
       oPrint:Say( _nLin, 0400, Substr(_cEntidade[ 1, 10 ],01,03) + "." + Substr(_cEntidade[ 1, 10 ],04,03) + "." + Substr(_cEntidade[ 1, 10 ],07,03) + "-" + Substr(_cEntidade[ 1, 10 ],10,02), oFont10b)       
    Endif

    _nLin := _nLin + 50

    oPrint:Say( _nLin, 0110, "I.E.:"    , oFont10)    
    oPrint:Say( _nLin, 0400, AllTrim( _cEntidade[ 1, 11 ] ), oFont10b)    

    _nLin := _nLin + 50
	oPrint:Line ( _nLin, 0100, _nLin, 2330 )
    _nLin := _nLin + 50

    oPrint:Say( _nLin - 20, 0110, "Conforme combinado, apresentamos abaixo a proposta para fornecimento de equipamentos e serviços:"    , oFont10b)        

    _nLin := _nLin + 50
    oPrint:Line( _nLin, 0100, _nLin, 2330 )
    _nLin := _nLin + 30    

    cNomeTranspo := ""

    oPrint:Say( _nLin,0110, "Vendedor:"       , oFont10)
    oPrint:Say (_nLin,0400, Upper( Posicione( "SA3", 1, xFilial("SA3") + cVend, "A3_NOME" ) ),oFont10b)
    _nLin := _nLin + 50

    oPrint:Say( _nLin, 0110, "Condição Pgtº:"  , oFont10)
    oPrint:Say (_nLin,0400, AllTrim( Posicione( "SE4", 1, xFilial("SE4") + _cCondPag, "E4_DESCRI" )),oFont10b)
    _nLin := _nLin + 50

    If !Empty(Alltrim(T_DETALHES->ADY_TPFRET))
       oPrint:Say( _nLin, 0110, "Frete:"  , oFont10)
       If Alltrim(T_DETALHES->ADY_TPFRET) == "C"
          oPrint:Say (_nLin,0400, "C I F",oFont10b)
       Endif
       If Alltrim(T_DETALHES->ADY_TPFRET) == "F"
          oPrint:Say (_nLin,0400, "F O B",oFont10b)
       Endif
       If Alltrim(T_DETALHES->ADY_TPFRET) == "T"
          oPrint:Say (_nLin,0400, "Por Conta de Terceirtos",oFont10b)
       Endif
       If Alltrim(T_DETALHES->ADY_TPFRET) == "S"
          oPrint:Say (_nLin,0400, "Sem Frete",oFont10b)
       Endif

       // Se for informado valor do Frete, imprime na mesma linha do tipo de Frete
       If T_DETALHES->ADY_FRETE <> 0
          oPrint:Say (_nLin,0700, "Valor Frete:",oFont10b)           
          oPrint:Say (_nLin,0900, Str(T_DETALHES->ADY_FRETE,10,02), oFont10b)
       Endif

       _nLin := _nLin + 50
    Else

       // Se for informado valor do Frete, imprime na mesma linha do tipo de Frete
       If T_DETALHES->ADY_FRETE <> 0
          oPrint:Say (_nLin,0110, "Valor Frete:",oFont10b)           
          oPrint:Say (_nLin,0400, Str(T_DETALHES->ADY_FRETE,10,02), oFont10b)
       Endif
    
    Endif

    If !Empty(Alltrim(T_DETALHES->ADY_ENTREG))
       oPrint:Say( _nLin, 0110, "Prazo Entrega:"  , oFont10)
       oPrint:Say (_nLin,0400, AllTrim(T_DETALHES->ADY_ENTREG),oFont10b)
       _nLin := _nLin + 50
    Endif   

	If( Select( "T_DETALHES" ) != 0 )
		T_DETALHES->( DbCloseArea() )
	EndIf

    oPrint:Line( _nLin, 0100, _nLin, 2330 )
    _nLin := _nLin + 50
    oPrint:Say(  _nLin - 20, 1000, "P R O D U T O S"  , oFont12b)
    _nLin := _nLin + 50
	oPrint:Line ( _nLin, 0100, _nLin, 2330 )

    nPosicao := _nLin

    _nLin := _nLin + 30

    // Cabeçalho dos Produtos
//	oPrint:Say ( _nLin - 20, 0120, "ITEM"      , oFont08 )
//	oPrint:Say ( _nLin - 20, 0235, "PRODUTO"   , oFont08 )

  	oPrint:Say ( _nLin - 20, 0120, "PRODUTO"   , oFont08 )
	oPrint:Say ( _nLin - 20, 0650, "DESCRICAO" , oFont08 )
	oPrint:Say ( _nLin - 20, 1205, "MOEDA"     , oFont08 )
	oPrint:Say ( _nLin - 20, 1355, "QTD"      Î, oFont08 )
	oPrint:Say ( _nLin - 20, 1470, "UN"        , oFont08 )
	oPrint:Say ( _nLin - 20, 1530, "VLR. UNIT.", oFont08 )
	oPrint:Say ( _nLin - 20, 1705, "SUB-TOTAL" , oFont08 )
	oPrint:Say ( _nLin - 20, 1875, "DIF.ICMS"  , oFont08 )
	oPrint:Say ( _nLin - 20, 2025, "VLR. TOTAL", oFont08 )
	oPrint:Say ( _nLin - 20, 2205, "Garantia"  , oFont08 )

    _nLin := _nLin + 30
	oPrint:Line ( _nLin, 0100, _nLin, 2330 )
    _nLin := _nLin + 50

Return

// Cria as perguntas
Static Function GeraPerg( cPerg )

	PutSx1( cPerg, "01","OPORTUNIDADE DE?" ,"OPORTUNIDADE DE?" ,"OPORTUNIDADE DE?" ,"mv_ch1","C",6,0,0,"G","","AD1","","","mv_par01"," ","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "02","OPORTUNIDADE ATE?","OPORTUNIDADE ATE?","OPORTUNIDADE ATE?","mv_ch2","C",6,0,0,"G","","AD1","","","mv_par02"," ","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "03","PROPOSTA DE?"     ,"PROPOSTA DE?"     ,"PROPOSTA DE?"     ,"mv_ch3","C",6,0,0,"G","","ADY","","","mv_par03"," ","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "04","PROPOSTA ATE?"    ,"PROPOSTA ATE?"    ,"PROPOSTA ATE?"    ,"mv_ch4","C",6,0,0,"G","","ADY","","","mv_par04"," ","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "05","DATA INICIAL?"    ,"DATA INICIAL?"    ,"DATA INICIAL?"    ,"mv_ch5","D",8,0,2,"G","",""   ,"","","mv_par05"," ","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "06","DATA FIM?"        ,"DATA FIM?"        ,"DATA FIM?"        ,"mv_ch6","D",8,0,2,"G","",""   ,"","","mv_par06"," ","","","","","","","","","","","","","","","")

Return()

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

// Imprime uma régua horizontal numerada de 100 em 100 e uma régua vertical numerada de 50 em 50
Static Function PrtRegua()

	For xxx = 100 to 2400 step 100
		oPrint:Line( 0010, xxx, 0030, xxx )
		oPrint:Say( 0010, xxx + 10, AllTrim( Str(xxx) ), oFont08 )
		If xxx > 2400
			Exit
		EndIf
	Next

	For xxx = 50 to 3600 step 50
		oPrint:Line( xxx, 0020, xxx, 0040 )
		oPrint:Say( xxx - 20, 0050, AllTrim( Str( xxx ) ), oFont08 )
		If xxx > 3600
			Exit
		EndIf
	Next

Return

// Função que mostra o total da proposta comercial quando existir diferencial de alíquota
Static Function XDIFE_ICMS(_mv_par01, _mv_par02, _mv_par03, _mv_par04, _mv_par05, _mv_par06)

   Local cSql    := ""
   Local lChumba := .F.
   Local nContar := 0

   Local _PRO_POSICAO := 0
   Local _TES_POSICAO := 0
   Local _TOT_POSICAO := 0
   Local _TOT_MOEDA   := 0

   Local _ICMBASED    := 0
   Local _ALIBASED    := 0
   Local _VALBASED    := 0
   Local _ICMRETID    := 0
   Local _ALIRETID    := 0
   Local _VALRETID    := 0
   Local _DIFICMSD    := 0
   Local _PROICMSR    := 0
   Local _TOTDIFER    := 0
   Local _PROICMSD    := 0
   Local _TOTDIFED    := 0

   Local cGet1	 := Space(25)
   Local cGet2	 := Space(25)
   Local cGet3	 := Space(25)
   Local cGet4	 := Space(25)
   Local cGet5	 := Space(25)
   Local cGet6	 := Space(25)
   Local cMemo1	 := ""

   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5
   Local oGet6
   Local oMemo1

   Private oDlgP

   // Pesquisa os dados da proposta comercial ára cálculo
   If Select("T_PROPOSTA") > 0
       T_PROPOSTA->( dbCloseArea() )
    EndIf

   cSql := ""
   cSql := " SELECT ADY.*        , "
   cSql += "        ADZ.*        , "
   cSql += "        SB1.B1_GARANT, "
   cSql += "        SB1.B1_DESC  , "
   cSql += "        SB1.B1_DAUX  , "
   cSql += "        SB1.B1_GRTRIB, "
   cSql += "        SB1.B1_ORIGEM  "
   cSql += "    FROM " + RetSqlName("ADZ") + " ADZ , "
   cSql += "         " + RetSqlName("ADY") + " ADY , "
   cSql += "         " + RetSqlName("SB1") + " SB1   "
   cSql += "  WHERE ADY.ADY_OPORTU  >= '" + _MV_PAR01 + "' "
   cSql += "    AND ADY.ADY_OPORTU  <= '" + _MV_PAR02 + "' "
   cSql += "    AND ADY.ADY_PROPOS  >= '" + _MV_PAR03 + "' "
   cSql += "    AND ADY.ADY_PROPOS  <= '" + _MV_PAR04 + "' "
   cSql += "    AND ADY.ADY_DATA BETWEEN '" + DtoS( _MV_PAR05 ) + "' AND '" + DtoS( _MV_PAR06 ) + "'"
   cSql += "    AND ADY.ADY_PROPOS   = ADZ.ADZ_PROPOS "
   cSql += "    AND ADY.D_E_L_E_T_   = ' ' "
   cSql += "    AND ADZ.D_E_L_E_T_   = ' ' "
   cSql += "    AND ADY.ADY_FILIAL   = '" + xFilial("ADY") + "' "
   cSql += "    AND ADZ.ADZ_FILIAL   = '" + xFilial("ADZ") + "' "
   cSql += "    AND ADZ.ADZ_PRODUT   = SB1.B1_COD "
   cSql += "  ORDER BY ADY.ADY_FILIAL, ADZ.ADZ_PROPOS , ADZ.ADZ_ITEM"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROPOSTA", .T., .T. )

   If T_PROPOSTA->( EOF() )
      Return(.T.)
   Endif

   // Captura o estado do cliente da proposta comercial
   If Select("T_ESTADO") > 0
      T_ESTADO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A1_EST    ,"
   cSql += "       A1_TIPO   ,"
   cSql += "       A1_GRPTRIB "
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += " WHERE A1_COD  = '" + Alltrim(T_PROPOSTA->ADY_CODIGO) + "'"
   cSql += "   AND A1_LOJA = '" + Alltrim(T_PROPOSTA->ADY_LOJA)   + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ESTADO", .T., .T. )

   If T_ESTADO->( EOF() )
      Return(.T.)
   Endif
   
   // Verifica se o Estado da Empresa Logada é diferente do estado do cadastro de clientes
   If Alltrim(T_ESTADO->A1_EST) == Alltrim(SM0->M0_ESTENT)
      Return(.T.)
   Endif

   // Verifica se cliente é F = Consumidor Final
   If Alltrim(T_ESTADO->A1_TIPO) <> "F"
      Return(.T.)
   Endif

   // Calcula os valores para os produtos da proposta comercial                        
   T_PROPOSTA->( dbGoTop() )
   
   WHILE !T_PROPOSTA->( EOF() )

       // Verifica se o TES indicado no produto deve utilizar a excesão fiscal
       If Select("T_TES") > 0
          T_TES->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT F4_INCSOL, "
       cSql += "       F4_ICM     "
       cSql += "  FROM " + RetSqlName("SF4")
       cSql += " WHERE F4_CODIGO  = '" + Alltrim(T_PROPOSTA->ADZ_TES) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"
      
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TES", .T., .T. )

       // Verifica o ICM Solidário
       If T_TES->F4_INCSOL <> "S"
          T_PROPOSTA->( DbSkip() )          
          Loop
       Endif

       // Verifica se TES permite calcular ICMS
       If T_TES->F4_ICM <> "S"
          T_PROPOSTA->( DbSkip() )
          Loop
       Endif

       // Pesquisa a excesão fiscal para calculo do produto
       If Select("T_FISCAL") > 0
          T_FISCAL->( dbCloseArea() )
       EndIf
       
       cSql := ""
       cSql := "SELECT F7_EST    ,"
       cSql += "       F7_TIPOCLI," 
       cSql += "       F7_ALIQINT,"
       cSql += "       F7_ALIQEXT,"
       cSql += "       F7_MARGEM ,"
       cSql += "       F7_ALIQDST "
       cSql += "  FROM " + RetSqlName("SF7")
       cSql += " WHERE F7_GRTRIB  = '" + Alltrim(T_PROPOSTA->B1_GRTRIB) + "'"
       cSql += "   AND F7_EST     = '" + Alltrim(T_ESTADO->A1_EST)      + "'"
       cSql += "   AND F7_TIPOCLI = '" + Alltrim(T_ESTADO->A1_TIPO)     + "'"
       cSql += "   AND F7_GRPCLI  = '" + Alltrim(T_ESTADO->A1_GRPTRIB)  + "'"
       cSql += "   AND D_E_L_E_T_ = ''"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FISCAL", .T., .T. )

       If T_FISCAL->( EOF() )
          T_PROPOSTA->( DbSkip() )
          Loop
       Endif
       
       // Calcula o ICMS ST do produto lido
       If Alltrim(T_PROPOSTA->ADZ_MOEDA) == "1"

          _ICMBASER := T_PROPOSTA->ADZ_TOTAL

          If T_FISCAL->F7_ALIQINT >= T_FISCAL->F7_ALIQDST
             _ALIBASER := T_FISCAL->F7_ALIQINT - T_FISCAL->F7_ALIQDST
          Else
             _ALIBASER := T_FISCAL->F7_ALIQDST - T_FISCAL->F7_ALIQINT
          Endif

          _VALBASER := (_ICMBASER * _ALIBASER) / 100

          _ICMRETIR := T_PROPOSTA->ADZ_TOTAL

          If T_FISCAL->F7_ALIQINT >= T_FISCAL->F7_ALIQDST
             _ALIRETIR := (T_FISCAL->F7_ALIQINT - T_FISCAL->F7_ALIQDST)
          Else
             _ALIRETIR := (T_FISCAL->F7_ALIQDST - T_FISCAL->F7_ALIQINT)
          Endif             

          _VALRETIR := (_ICMRETIR * _ALIRETIR) / 100

          _PROICMSR := _PROICMSR + T_PROPOSTA->ADZ_TOTAL
          _TOTDIFER := _TOTDIFER + _VALRETIR

          aAdd( aDiferenca, { T_PROPOSTA->ADZ_ITEM   ,;
                              T_PROPOSTA->ADZ_PRODUTO,;
                              _VALRETIR              ,;
                              0                      })
       Else   

          _ICMBASED := T_PROPOSTA->ADZ_TOTAL

          If T_FISCAL->F7_ALIQINT >= T_FISCAL->F7_ALIQDST
             _ALIBASED := T_FISCAL->F7_ALIQINT - T_FISCAL->F7_ALIQDST
          Else
             _ALIBASED := T_FISCAL->F7_ALIQDST - T_FISCAL->F7_ALIQINT
          Endif

          _VALBASED := (_ICMBASED * _ALIBASED) / 100

          _ICMRETID := T_PROPOSTA->ADZ_TOTAL

          If T_FISCAL->F7_ALIQINT >= T_FISCAL->F7_ALIQDST
             _ALIRETID := (T_FISCAL->F7_ALIQINT - T_FISCAL->F7_ALIQDST)
          Else   
             _ALIRETID := (T_FISCAL->F7_ALIQDST - T_FISCAL->F7_ALIQINT)
          Endif

          _VALRETID := (_ICMRETID * _ALIRETID) / 100

          _PROICMSD := _PROICMSD + T_PROPOSTA->ADZ_TOTAL
          _TOTDIFED := _TOTDIFED + _VALRETID

          aAdd( aDiferenca, { T_PROPOSTA->ADZ_ITEM   ,;
                              T_PROPOSTA->ADZ_PRODUTO,;
                              0                      ,;
                              _VALRETID              })
       Endif

       T_PROPOSTA->( DbSkip() )

   Enddo

   xRetiR := _TOTDIFER
   xRetiD := _TOTDIFED

/*
   msgalert("Total dos Produtos R$ " + transform(_proicmsr,"9999999.99") + chr(13) + ;
            "Total Diferença R$    " + transform(_totdifer,"9999999.99") + chr(13) + ;
            "Total da Proposta R$  " + transform(_proicmsr+_totdifer,"9999999.99") + chr(13) + ;
            "-------------------------------------------" + chr(13) + ;
            "Total dos Produtos US$$ " + transform(_proicmsd,"9999999.99") + chr(13) + ;
            "Total Diferença US$     " + transform(_totdifed,"9999999.99") + chr(13) + ;
            "Total da Proposta US$   " + transform(_proicmsd+_totdifed,"9999999.99"))
*/

Return(.T.)