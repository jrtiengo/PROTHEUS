#include "rwmake.ch"
#include "topconn.ch"

#DEFINE IMP_SPOOL 2

// #############################################################################################################
// Fonte.....: AUTR002                                                                                        ##
// Autor.....: Samuel Schneider                                                                               ##
// Data......: 22/01/2011                                                                                     ##
// Descri��o.: IMPRESS�O PROPOSTA COMERCIAL                                                                   ##
// Altera��o.: 07/11/2011 - Altera��o da impress�o da descri��o dos produtos + B1_DAUX                        ##
// ---------------------------------------------------------------------------------------------------------- ##
// Altera��o: Jean Rehermann | JPC                                                                            ##
// -------------------------------                                                                            ##
// 1 - Adicionado novos elementos ao relat�rio                                                                ##
// 2 - Ajustado as posi��es de campos num�ricos (alinhamento)                                                 ##
// 3 - Modificado para permitir impress�o diretamente da tela de Oportunidades (sem preencher par�metros)     ##
// 4 - Modificado tamanhos de fontes                                                                          ##
// #############################################################################################################

User Function AUTR002(cPar1, cPar2, k___Filial, k___Observa)

	Local   lAutoPar     := .F.
	Private Li           := 0
	Private _nLin        := 0
    Private nPosicao     := 0
	Private oPrint
	Private cPerg        :="AUTOMAR02"
	Private cStrSql      := ""
	Private cConsulta    := ""
	Private nLastKey     := 0
	Private cLoja        := ""
	Private cTaxa        := 0
	Private cNome        := ""
	Private cNumJ        := ""
	Private cNropor	     := ""
	Private cRevisa      := ""
	Private cVend        := ""
	Private cProp        := ""
	Private lInicio      := .T.
	Private cNumPar      := ""
	Private cProp1       := ""
	Private cMoedaDia    := ""
	Private Totger       := ""
	Private cComple      := ""
	Private cData        := ""
	Private _aEntidade   := {}
	Private _cProdNCM    := ""
	Private _cCondPag    := ""
	Private _cValidade   := ""
	Private _aObserv     := {}
    Private cSql         := ""
    Private aDiferenca   := {}
    Private nDifeReal    := 0
    Private nDifeDolar   := 0
    Private y___Filial   := k___Filial
    Private y___NovaOp   := k___Filial
    Private lPrimeiraImp := .T.
    Private lGarantia    := .F.
    
    // ###################################
    // Jean Rehermann - ICMS Solidario  ##
    // ###################################
    Private aPrdSol  := {}  // Array com os produtos: {PRODUTO, TOTAL_DO_ITEM, TES, MOEDA}
    Private aPSolic  := {}  // Array com os produtos: {PRODUTO, TOTAL_DO_ITEM, TES, MOEDA}
    Private cEntCod  := ""  // C�digo da entidade (cliente ou prospect)
    Private cLojEnt  := ""  // Loja da entidade
    Private nFrtVal  := 0   // Valor do frete para ser rateado proporcionalmente nos itens antes do calculo do icms
    Private nSolRet  := 0   // Valor de imposto retido calculado e retornado na fun��o AUTOM208
    Private aDifIcm  := {}  // Array transit�rio que cont�m os valores do diferencial de icms por moeda (R$/U$)
    Private nContarx := 0   // Contador do Array aDifIcm
    Private aResumoV := {}  // Array que guarda os resultados para display da Planilha de C�lculo

    Private xRetiR     := 0
    Private xRetiD     := 0

    Private aImpostos  := {}

    U_AUTOM628("AUTR002")
	
	lAutoPar := ( cPar1 != Nil .And. cPar2 != Nil )
	
	GeraPerg( cPerg ) // Cria as perguntas

    // #################################################################
    // y___FIlial Cont�m a filial vinda da nova tela de oportunidades ##
    // #################################################################
    If y___Filial == Nil
       y___Filial := cFilAnt
    Endif   

    If k___Observa == Nil
       k___Observa := 1
    Endif
	
	If lAutoPar
		Pergunte( cPerg, .F. )
		mv_par01 := cPar1
		mv_par02 := cPar1
		mv_par03 := cPar2
		mv_par04 := cPar2
		mv_par05 := CtoD("//")
		mv_par06 := dDataBase + 365
	Else
		If !Pergunte( cPerg, .T. ) // Exibe a tela de par�metros
			Return
		EndIf
	EndIf

    // #############################################
    // Pesquisa a �ltima revis�o a ser pesquisada ##
    // #############################################
    If Select("T_REVISAO") > 0
       T_REVISAO->( dbCloseArea() )
    EndIf

    cSql := "SELECT TOP(1) ADZ_REVISA"
    cSql += "  FROM " + RetSqlName("ADZ")
    cSql += " WHERE ADZ_FILIAL  = '" + alltrim(y___Filial) + "'"
	cSql += "   AND ADZ_PROPOS >= '" + MV_PAR03 + "' "
	cSql += "   AND ADZ_PROPOS <= '" + MV_PAR04 + "' "
    cSql += "   AND D_E_L_E_T_ = '' 
    cSql += " ORDER BY ADZ_REVISA DESC

    cSql := ChangeQuery( cSql )
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_REVISAO", .T., .T. )

    If T_REVISAO->( EOF() )
       MsgStop("Produtos da proposta comercial n�o localizados. Entre em contato com o administrador do sistema informando esta mensagem juntamente com o n� da proposta comercial para an�lise.")
       Return(.T.)
    Else
       cRevisao := T_REVISAO->ADZ_REVISA
    Endif   

    // ########################################################
    // Carrega o array aImpostos com os Impostos calculados  ##
    // ########################################################
    aImpostos := U_AUTOM346(k___Filial, CPAR2, cRevisao)

    // ############################################
	// Executa a query e cria a �rea de trabalho ##
	// ############################################
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

    If y___NovaOp == Nil
       cStrSql += "    AND ADY.ADY_FILIAL   = '" + xFilial("ADY") + "' "
	   cStrSql += "    AND ADZ.ADZ_FILIAL   = '" + xFilial("ADZ") + "' "
	Else
       cStrSql += "    AND ADY.ADY_FILIAL   = '" + alltrim(y___Filial) + "'"
	   cStrSql += "    AND ADZ.ADZ_FILIAL   = '" + alltrim(y___Filial) + "'"
    Endif	

	cStrSql += "    AND ADZ.ADZ_REVISA = '" + Alltrim(cRevisao) + "'"
	cStrSql += "    AND ADZ.ADZ_PRODUT   = SB1.B1_COD "
	cStrSql += "    AND SB1.D_E_L_E_T_   = ''"	
	cStrSql += "  ORDER BY ADY.ADY_FILIAL, ADZ.ADZ_PROPOS , ADZ.ADZ_ITEM"


	If( Select( "TMPO" ) != 0 )
		TMPO->( DbCloseArea() )
	EndIf

    // ########################################################################
    // Fun��o que calcula o valor do diferencial de Al�quotas para impress�o ##
    // ########################################################################
    xRetiR := 0
    xRetiD := 0

    // ##############################################################################################
    // Jean Rehermann - 06/02/2014 - Desabilitei esta chamada pois sera calculado por outra funcao ##
    // XDIFE_ICMS(mv_par01, mv_par02, mv_par03, mv_par04, mv_par05, mv_par06)                      ##
    // ##############################################################################################    

	cStrSql := ChangeQuery( cStrSql )
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrSql),"TMPO",.T.,.T.)

 	oPrint := TMSPrinter():New()

	oPrint:SetPaperSize(9)
	oPrint:SetPortrait()
	oPrint:StartPage()

    oPrint:SaveAllAsJpeg("d:\relatorios\proposta",1180,1600,180)

    // ###########################################################################
	// Cria os objetos de fontes que ser�o utilizadas na impress�o do relatorio ##
	// ###########################################################################
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

    // ##########################################################################################
    // Carrega o Array aImpostos com o c�lculo do Difal para os produtos da proposta comercial ##
    // ##########################################################################################
    aImpostos := U_AUTOM346(k___Filial, cPar2, cRevisao)

	DbSelectArea("SM2")
	dbSetOrder(1)
	If dbSeek( DtoS( dDataBase ) )
		cMoedaDia := M2_MOEDA2
	Else
		MsgAlert("Valores cambiais n�o encontrados para o dia "+ DtoC( dDataBase ) )
		cMoedaDia := 1
	EndIf

	cNumPar      := MV_PAR03
    lPrimeiraImp := .T.
	
	Do While cNumPar <= MV_PAR04
		
         If lPrimeiraImp == .T.
         Else
            Exit
         Endif

		_cEntidade := {}
		_cProdNCM  := ""
		_cCondPag  := ""
		_cValidade := ""
		_aObserv   := {}
		
		cEnt := Iif( TMPO->ADY_ENTIDA == "1", "SA1", "SUS" )
		dbSelectArea( cEnt )
		dbSetOrder(1)
		dbSeek( xFilial(cEnt) + TMPO->ADY_CODIGO + TMPO->ADY_LOJA )
		
        // ###################################################################################################################
		// Jean Rehermann - Guardo entidade + loja e frete, se houver, para enviar para funcao de calculo do icms solidario ##
		// ###################################################################################################################
		cEntCod := TMPO->ADY_CODIGO
		cLojEnt := TMPO->ADY_LOJA
		
		If cEnt == "SA1"
		   aAdd( _cEntidade, { AllTrim( SA1->A1_NOME ), SA1->A1_COD, AllTrim( SA1->A1_END ), AllTrim( SA1->A1_BAIRRO ), Transform( SA1->A1_CEP, "@R 99999-999" ), AllTrim( SA1->A1_MUN ), SA1->A1_EST, Transform(SA1->A1_TEL, "@R 9999-9999"), AllTrim( SA1->A1_EMAIL ), SA1->A1_CGC, SA1->A1_INSCR, ADY->ADY_PARAQ, ADY->ADY_TPFRET, ADY->ADY_ENTREG } )
		ElseIf cEnt == "SUS"
		   aAdd( _cEntidade, { AllTrim( SUS->US_NOME ), SUS->US_COD, AllTrim( SUS->US_END ), AllTrim( SUS->US_BAIRRO ), Transform( SUS->US_CEP, "@R 99999-999" ), AllTrim( SUS->US_MUN ), SUS->US_EST, Transform(SUS->US_TEL, "@R 9999-9999"), AllTrim( SA1->A1_EMAIL ), SA1->A1_CGC, SA1->A1_INSCR, ADY->ADY_PARAQ, ADY->ADY_TPFRET, ADY->ADY_ENTREG } )
		EndIf

        // ##################################################
	    // Pesquisa a condi��o de pagamento a ser impressa ##
	    // ##################################################
		DbSelectArea("TMPO")
        _cCondPag  := TMPO->ADZ_CONDPG
		
		Cabecalho()

        _nLin := _nLin - 20
		
		DbSelectArea("TMPO")

		Store 0 to tValorR, tValorU, Totger

		Do while !eof() .And. cProp1 == TMPO->ADZ_PROPOS .AND. cNropor == ADY_OPORTU
			
			aAdd( aPrdSol, { TMPO->ADZ_PRODUTO, TMPO->ADZ_TOTAL, TMPO->ADZ_TES, TMPO->ADZ_MOEDA, TMPO->ADZ_ITEM, TMPO->ADZ_DESCRI } )
			
			DbSelectArea("TMPO")
			
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

            // ########
            // Moeda ##
            // ########
			oPrint:Say ( _nLin, 1215, PadC( Iif( TMPO->ADZ_MOEDA == "1", "R$", "US$" ), 10 ), oFont08 )

			If (TMPO->ADZ_QTDVEN - INT(TMPO->ADZ_QTDVEN)) == 0
   			   oPrint:Say ( _nLin, 1380, PadL( Transform( TMPO->ADZ_QTDVEN , "@E 99,999,999"), 14 ), oFont08,,,,1 )
   			Else
   			   oPrint:Say ( _nLin, 1380, PadL( Transform( TMPO->ADZ_QTDVEN , "@E 99,999,999.99"), 14 ), oFont08,,,,1 )
   			Endif   

			oPrint:Say ( _nLin, 1470, PadC( TMPO->ADZ_UM, 02 ), oFont08 )
			oPrint:Say ( _nLin, 1655, PadL( Transform( TMPO->ADZ_PRCVEN , "@E 99,999,999.99"), 14 ), oFont08,,,,1 )

			oPrint:Say ( _nLin, 1805, PadL( Transform( TMPO->ADZ_TOTAL  , "@E 99,999,999.99"), 14 ), oFont08,,,,1 )

            // #########@@##############################################################
            // Pesquisa o Valor do Diferencial de Aliquota para o Produto selecionado ##
            // #########################################################################
            aPSolic := {}
			aAdd( aPSolic, { TMPO->ADZ_PRODUTO, TMPO->ADZ_TOTAL, TMPO->ADZ_TES, TMPO->ADZ_MOEDA, TMPO->ADZ_ITEM, TMPO->ADZ_DESCRI } )

            // ####################################################################
            // Pesquisa no array aImpostos, o valor do DIFAL para o produto lido ##
            // ####################################################################
            For nContar = 1 to Len(aImpostos)
                If aImpostos[nContar,02] == TMPO->ADZ_ITEM .And. aImpostos[nContar,03] == TMPO->ADZ_PRODUTO
                   nDiferencial := aImpostos[nContar,43]
                   Exit
                Endif
            Next nContar

        	oPrint:Say ( _nLin, 1955, PadL( Transform( nDiferencial  , "@E 999,999.99"), 14 )   , oFont08,,,,1 )                                                                                                       

            If lGarantia == .T.       
               If TMPO->ADZ_MOEDA == "1"
      	 		  oPrint:Say ( _nLin, 2120, PadL( Transform( (TMPO->ADZ_TOTAL + nDiferencial), "@E 99,999,999.99"), 14 ), oFont08,,,,1 )
   	     	   Else
   	 	  	      oPrint:Say ( _nLin, 2120, PadL( Transform( (TMPO->ADZ_TOTAL + nDiferencial), "@E 99,999,999.99"), 14 ), oFont08,,,,1 )   	 		   
    	 	   Endif
    	 	Else
               If TMPO->ADZ_MOEDA == "1"
      	 		  oPrint:Say ( _nLin, 2220, PadL( Transform( (TMPO->ADZ_TOTAL + nDiferencial), "@E 99,999,999.99"), 14 ), oFont08,,,,1 )
   	     	   Else
   	 	  	      oPrint:Say ( _nLin, 2220, PadL( Transform( (TMPO->ADZ_TOTAL + nDiferencial), "@E 99,999,999.99"), 14 ), oFont08,,,,1 )   	 		   
    	 	   Endif
            Endif    	 	   

            // ##################################################################################
            // Imprime a Garantia do produtos se assim estiver parametrizado para ser impresso ##
            // ##################################################################################
            If lGarantia == .T.       
   			   oPrint:Say ( _nLin, 2230, Alltrim(TMPO->B1_GARANT), oFont08 )
   			Endif   

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
				tValorU += TMPO->ADZ_TOTAL &&+ nDiferencial
			Else
				tValorR += TMPO->ADZ_TOTAL &&+ nDiferencial
			EndIf
			
			_nLin := _nLin + 50
			
    		DbSelectArea("TMPO")
			TMPO->( dbSkip() )                                   
			
		EndDo

        // #####################################################
        // Pesquisa o Diferencial de ICMS para Valor em Reais ##
        // #####################################################
        nSolRet := 0

        For nContar = 1 to Len(aImpostos)
            If aImpostos[nContar,10] == '1'
               nSolRet := nSolRet + aImpostos[nContar,43]
            Endif
        Next nContar

	    xRetiR := nSolRet

        // ####################################################
        // Pesqusa o Diferencial de ICMS para Valor em Dolar ##
        // ####################################################
        nSolRet := 0

        For nContar = 1 to Len(aImpostos)
            If aImpostos[nContar,10] == '2'
               nSolRet := nSolRet + aImpostos[nContar,43]
            Endif
        Next nContar

 	    xRetiD := nSolRet

        // ############################################
        // Desenhas os tra�os verticais dos produtos ##
        // ############################################
		oPrint:Line(_nLin,0100, _nLin, 2330)
		oPrint:Line(nPosicao,0395, _nLin, 0395)
		oPrint:Line(nPosicao,1195, _nLin, 1195)
		oPrint:Line(nPosicao,1315, _nLin, 1315)
		oPrint:Line(nPosicao,1455, _nLin, 1455)
		oPrint:Line(nPosicao,1520, _nLin, 1520)
		oPrint:Line(nPosicao,1660, _nLin, 1660)
		oPrint:Line(nPosicao,1835, _nLin, 1835)
		oPrint:Line(nPosicao,1970, _nLin, 1970)

        If lGarantia == .T.
   		   oPrint:Line(nPosicao,2140, _nLin, 2140)
   		Endif   

        _nLin := _nLin + 30
		oPrint:Say (_nLin,110 ,"TOTAIS",oFont11)

         If (tValorR + tValorU) <> 0

            // ############################################
            // Imprime o Sub-Total da Proposta Comercial ##
            // ############################################
   		    oPrint:Say (_nLin,0800,"SUB-TOTAL EM R$" ,oFont11)
 		    oPrint:Say (_nLin,1600,"SUB-TOTAL EM US$",oFont11)

 		    oPrint:Say (_nLin,1400,transform((tValorR),"@E 9,999,999,999,999.99"),oFont11,,,,1)
		    oPrint:Say (_nLin,2300,transform((tValorU),"@E 9,999,999,999,999.99"),oFont11,,,,1)

            // ###########################
            // Imprime o Valor do Frete ##
            // ###########################
            _nLin := _nLin + 50
   		    oPrint:Say (_nLin,0800,"FRETE EM R$" ,oFont11)
		    oPrint:Say (_nLin,1400,transform(nFrtVal,"@E 9,999,999,999,999.99"),oFont11,,,,1)

            _nLin := _nLin + 50
            
            // #########################################
            // Imprime o Valor do Diferencial do ICMS ##
            // #########################################
   		    oPrint:Say (_nLin,0800,"DIF. ALIQUOTA EM R$" ,oFont11)
   		    oPrint:Say (_nLin,1600,"DIF. ALIQUOTA EM US$",oFont11)
		    oPrint:Say (_nLin,1400,transform(xRetiR,"@E 9,999,999,999,999.99"),oFont11,,,,1)
		    oPrint:Say (_nLin,2300,transform(xRetiD,"@E 9,999,999,999,999.99"),oFont11,,,,1)
            _nLin := _nLin + 50

            // ##############################################
            // Imprime o Valor Total da Proposta Comercial ##
            // ##############################################
   		    oPrint:Say (_nLin,0800,"TOTAL EM R$" ,oFont11)
   		    oPrint:Say (_nLin,1600,"TOTAL EM US$",oFont11)
		    oPrint:Say (_nLin,1400,transform(tValorR + xRetiR + nFrtVal,"@E 9,999,999,999,999.99"),oFont11,,,,1)
		    oPrint:Say (_nLin,2300,transform(tValorU + xRetiD,"@E 9,999,999,999,999.99"),oFont11,,,,1)

            _nLin := _nLin + 50

        Endif

		oPrint:Line(nPosicao,0100, _nLin, 0100)        
		oPrint:Line(nPosicao,2330, _nLin, 2330)        
		oPrint:Line(_nLin,100,_nLin,2330)
        _nLin := _nLin + 30

        // ##############################
		// Gera as linhas para as NCMs ##
		// ##############################
		_aObserv := MemoObs( SubStr( _cProdNCM, 1, Len( _cProdNCM ) - 2 ), 180 )

        If Len( _aObserv ) == 0
           _aObserv := {" " }
        Endif

		oPrint:Say (_nLin,0110 ,"[ C�digo Produto / NCM ]",oFont08)

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

        // ##################################################################################
        // Se estado do cliente diferente do estado da empresa logada, imprime observa��es ##
        // ##################################################################################
        If Alltrim(_cEntidade[ 1, 7 ]) == Alltrim(SM0->M0_ESTENT)
        Else
           _nLin := _nLin + 30
           oPrint:Say( _nLin, 0110, "Conforme previsto na legisla��o, as mercadorias vendidas para fora do estado do " + Alltrim(SM0->M0_ESTENT) + " que n�o possuem protocolo de ICMS/ST dever�o ter", oFont09b)        
           _nLin := _nLin + 50
           oPrint:Say( _nLin, 0110, "a guia do imposto do diferencial de al�quota paga pelo adquirente na entrada do produto no Estado destino. Por favor consulte nossa", oFont09b)         
           _nLin := _nLin + 50
           oPrint:Say( _nLin, 0110, "equipe para eventuais d�vidas.", oFont09b)         
           _nLin := _nLin + 50

	       oPrint:Line(nPosicao,0100, _nLin, 0100)        
		   oPrint:Line(nPosicao,2330, _nLin, 2330)        
		   oPrint:Line(_nLin,0100,_nLin,2330)
		Endif

        // ###################################
        // Imprime as Observa��es do Pedido ##
        // ###################################
        _nLin := _nLin + 30
		oPrint:Say (_nLin,0110,"Observa��es: ",oFont09n)
		_nLin := _nLin + 50

        // #####################################
		// Gera as linhas para as observa��es ##
		// #####################################
        Do Case
           Case k___observa == 1

                If Select("T_OBSERVA") > 0
                   T_OBSERVA->( dbCloseArea() )
                EndIf

                cSql := ""
                cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ADY_OBSP)) AS OBSERVA"
                cSql += "  FROM " + RetSqlName("ADY")   
                cSql += " WHERE ADY_FILIAL = '" + Alltrim(k___Filial) + "'" 
                cSql += "   AND ADY_PROPOS = '" + Alltrim(cProp1)     + "'" 
                cSql += "   AND D_E_L_E_T_ = ''"

                cSql := ChangeQuery( cSql )
                dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OBSERVA", .T., .T. )

                If T_OBSERVA->( EOF() )
                   _cObs := ""
                Else
                   _cObs := Strtran(Alltrim(T_OBSERVA->OBSERVA), chr(13), " ")
                   _cObs := Strtran(Alltrim(T_OBSERVA->OBSERVA), chr(10), " ")
                Endif

           Case k___observa == 2

                If Select("T_OBSERVA") > 0
                   T_OBSERVA->( dbCloseArea() )
                EndIf

                cSql := ""
                cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ADY_OBSI)) AS OBSERVA"
                cSql += "  FROM " + RetSqlName("ADY")   
                cSql += " WHERE ADY_FILIAL = '" + Alltrim(k___Filial) + "'" 
                cSql += "   AND ADY_PROPOS = '" + Alltrim(cProp1)     + "'" 
                cSql += "   AND D_E_L_E_T_ = ''"

                cSql := ChangeQuery( cSql )
                dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OBSERVA", .T., .T. )
                
                If T_OBSERVA->( EOF() )
                   _cObs := ""
                Else
                   _cObs := Strtran(Alltrim(T_OBSERVA->OBSERVA), chr(13), " ")
                   _cObs := Strtran(Alltrim(T_OBSERVA->OBSERVA), chr(10), " ")
                Endif

           Otherwise
   		        _cObs := "          "
   		EndCase

 		_aObserv := MemoObs( _cObs, 100 )

		For nX := 1 To Len( _aObserv )
        	oPrint:Say (_nLin,0110,_aObserv[nX],oFont08)
			_nLin := _nLin + 50
		Next
  
		oPrint:Line(nPosicao,0100, _nLin, 0100)        
		oPrint:Line(nPosicao,2330, _nLin, 2330)        
		oPrint:Line(_nLin,0100,_nLin,2330)

        _nLin := _nLin + 30

        oPrint:Say( _nLin, 0110, "Os valores cotados em d�lar ser�o convertidos em real de acordo com a taxa do d�lar comercial (PTAX venda) do dia do faturamento.", oFont09b)

        // ###########################################################
        // Verifica se existe mensagem parametrizada para impress�o ##
        // ###########################################################
        If Select("T_PARAMETROS") > 0
           T_PARAMETROS->( dbCloseArea() )
        EndIf
   
        cSql := ""
        cSql := "SELECT ZZ4_MP01,"
        cSql += "       ZZ4_MP02,"
        cSql += "       ZZ4_MP03 "
        cSql += "  FROM " + RetSqlName("ZZ4")

        cSql := ChangeQuery( cSql )
        dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

        IF T_PARAMETROS->( EOF() )
           cMens01 := ""
           cMens02 := ""
           cMens03 := ""
        Else
           cMens01:= Alltrim(T_PARAMETROS->ZZ4_MP01)
           cMens02:= Alltrim(T_PARAMETROS->ZZ4_MP02)
           cMens03:= Alltrim(T_PARAMETROS->ZZ4_MP03)                      
        Endif
        
        If Empty(Alltrim(cMens01) + Alltrim(cMens02) + Alltrim(cMens03))
        Else
           _nLin := _nLin + 100
           oPrint:Say( _nLin, 0110, cMens01, oFont09b)
           _nLin := _nLin + 50
           oPrint:Say( _nLin, 0110, cMens02, oFont09b)
           _nLin := _nLin + 50
           oPrint:Say( _nLin, 0110, cMens03, oFont09b)
        Endif

        _nLin := _nLin + 100

        oPrint:Say( _nLin, 0110, "Sem mais para o momento nos colocamos � disposi��o para auxili�-los no que for preciso.", oFont09b)

        _nLin := _nLin + 100
        oPrint:Say( _nLin, 0110, "Atenciosamente", oFont09b)    

        // #########################################
        // Veririca se vendedor possui assinatura ##
        // #########################################
        cAssinatura := Posicione( "SA3", 1, xFilial("SA3") + cVend, "A3_ASSI" )
        
        If Empty(Alltrim(cAssinatura))
        Else
           If File(Alltrim(cAssinatura))
              _nLin := _nLin + 50
              oPrint:SayBitmap( _nLin, 0100, Alltrim(cAssinatura), 0700, 0200 )
              _nLin := _nLin + 100
           Endif   
        Endif   

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

        lPrimeiraImp := .F.

		If !Eof()
			cNumPar := ADY->ADY_PROPOS
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

// ###################################
// Imprime o cabe�alho do relat�rio ##
// ###################################
Static Function Cabecalho()

    _nLin := 0060

    oPrint:Line( _nLin, 0100, _nLin, 2330 )

    _nLin := _nLin + 50

    // ####################################
    // Imprime a logomarca da Automatech ##
    // ####################################
    oPrint:Say( _nLin, 1000, "AUTOMATECH SISTEMAS DE AUTOMA��O LTDA", oFont12b  )
    _nLin := _nLin + 70
    oPrint:SayBitmap( _nLin, 0151, "pclogoautoma.bmp", 0700, 0150 )

    // ###########################################
    // Identifica��o das Empresas da Automatech ##
    // ###########################################
    oPrint:Say( _nLin, 1000, "Matriz:", oFont08  )    
    oPrint:Say( _nLin, 1100, "RUA JO�O IN�CIO, 1110 - CEP 90.230-181 - PORTO ALEGRE - RS Fone: (51)30178300", oFont08  )    
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1100, "CNPJ: 03.385.913/0001-61    Insc. Estadual: 096/27777447", oFont08  )    
    
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1000, "Filial:", oFont08  )
    oPrint:Say( _nLin, 1100, "RUA JO�O IN�CIO, 1162 - CEP 90.230-181 - PORTO ALEGRE - RS Fone: (51)30178300", oFont08  )    
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1100, "CNPJ: 03.385.913/0005-95    Insc. Estadual: 096/3531158", oFont08  )    

    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1000, "Filial:", oFont08  )
    oPrint:Say( _nLin, 1100, "RUA S�O JOS�, 1767 - CEP: 95.020-270 - CAXIAS DO SUL - RS Fone: (54)32272333", oFont08  )
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
    oPrint:Say( _nLin, 1100, "TI AUTOMA��O E SERVI�OS LTDA", oFont08  )
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1100, "RUA FERNANDO AMARO, 1600 - CEP: 80.050-432 - CURITIBA - PR Fone: (41)30246675", oFont08  )
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1100, "CNPJ: 12.757.071/0001-12    Insc. Estadual: 9053742146", oFont08  )    

    _nLin := _nLin + 50
    
    oPrint:Line( _nLin, 0100, _nLin, 2330 )

    _nLin := _nLin + 20

    // ###################################################################################
    // Pesquisa N� da Oportunidade, Proposta Comercial e Data de Emiss�o para Impress�o ##
    // ###################################################################################
    DbSelectArea("AD1")
	DbSetOrder(1)
    
    If y___NovaOp == Nil    
   	   DbSeek( xFilial("AD1") + TMPO->ADY_OPORTU )
   	Else
   	   DbSeek( y___Filial + TMPO->ADY_OPORTU )
   	Endif      	   
		
	cNropor := AD1->AD1_NROPOR
	cRevisa := AD1->AD1_REVISA
	cVend   := AD1->AD1_VEND
    oPrint:Say( _nLin, 0110, "N� Oportunidade: " + cNropor + "/" + cRevisa, oFont12b)
		
	DbSelectArea("ADY")
	DbSetOrder(1)
    If y___NovaOp == Nil    
   	   DbSeek( xFilial("ADY") + TMPO->ADZ_PROPOS )
   	Else
   	   DbSeek( y___Filial + TMPO->ADZ_PROPOS )   	   
   	Endif   
		
	cProp1 := ADY_PROPOS
    oPrint:Say( _nLin, 0750, "N� Proposta: " + cProp1, oFont12b)

    // #############################################################
    // Pesquisa o n� do Pedido de Venda. Se encontrar, o imprime  ##
    // #############################################################
    If y___Filial == "04"

       If Select("T_RETPEDIDO") > 0
          T_RETPEDIDO->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT CK_FILIAL ,"
       cSql += "       CK_NUMPV  ,"
       cSql += "       CK_PROPOST "
       cSql += "  FROM " + RetSqlName("SCK")
       cSql += " WHERE CK_FILIAL  = '" + Alltrim(y___Filial) + "'"
       cSql += "   AND CK_PROPOST = '" + Alltrim(cProp1)     + "'"
       cSql += "   AND D_E_L_E_T_ = ''"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RETPEDIDO", .T., .T. )

       T_RETPEDIDO->( DbGoTop() )

       If !T_RETPEDIDO->( EOF() )
          oPrint:Say( _nLin, 1275, "Pedido Venda: " + T_RETPEDIDO->CK_NUMPV, oFont12b)
       Endif
    Endif

    oPrint:Say( _nLin, 1800, "Emiss�o: "     + DtoC( StoD( TMPO->ADY_DATA ) ), oFont12b)
    _nLin := _nLin + 70
    oPrint:Say( _nLin, 1800, "Validade: "    + DtoC( StoD( TMPO->ADY_VAL ) ) , oFont12b)

    _nLin := _nLin + 70
	oPrint:Line ( _nLin, 0100, _nLin, 2330 )
    _nLin := _nLin + 50

    // ###############################################
    // Pesquisa dados complementares para impress�o ##
    // ###############################################
	If( Select( "T_DETALHES" ) != 0 )
		T_DETALHES->( DbCloseArea() )
	EndIf

    cSql := ""
    cSql := "SELECT ADY_FILIAL, "
    cSql += "       ADY_PROPOS, "
    cSql += "       ADY_PARAQ , "
    cSql += "       ADY_ENTREG, "
    cSql += "       ADY_TPFRET, "
    cSql += "       ADY_FRETE   "
    cSql += "  FROM " + RetSqlName("ADY")
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

    oPrint:Say( _nLin, 0110, "Endere�o:", oFont10)
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

    oPrint:Say( _nLin - 20, 0110, "Conforme combinado, apresentamos abaixo a proposta para fornecimento de equipamentos e servi�os:"    , oFont10b)        

    _nLin := _nLin + 50
    oPrint:Line( _nLin, 0100, _nLin, 2330 )
    _nLin := _nLin + 30    

    cNomeTranspo := ""

    oPrint:Say( _nLin,0110, "Vendedor:"       , oFont10)
    oPrint:Say (_nLin,0400, Upper( Posicione( "SA3", 1, xFilial("SA3") + cVend, "A3_NOME" ) ),oFont10b)
    _nLin := _nLin + 50

    oPrint:Say( _nLin, 0110, "Condi��o Pgt�:"  , oFont10)
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

       // ###########################################################################
       // Se for informado valor do Frete, imprime na mesma linha do tipo de Frete ##
       // ###########################################################################
       If T_DETALHES->ADY_FRETE <> 0
          // ################################################################################################
          // Jean Rehermann - 07/02/2014 - Para uso no AUTOM208 (ICMS Solid�rio - Diferencial de al�quota) ##
          // ################################################################################################
          nFrtVal := TMPO->ADY_FRETE 
       Endif

       _nLin := _nLin + 50

    Else

       // ###########################################################################      
       // Se for informado valor do Frete, imprime na mesma linha do tipo de Frete ##
       // ###########################################################################
       If T_DETALHES->ADY_FRETE <> 0
          oPrint:Say (_nLin,0110, "Valor Frete:",oFont10b)           
          oPrint:Say (_nLin,0400, Str(T_DETALHES->ADY_FRETE,10,02), oFont10b)
          // ################################################################################################
          // Jean Rehermann - 07/02/2014 - Para uso no AUTOM208 (ICMS Solid�rio - Diferencial de al�quota) ##
          // ################################################################################################
          nFrtVal := TMPO->ADY_FRETE 
       Endif
    
    Endif
  
    // ################################################################################
    // Imprime a Transportadora csso esta tenha sido informada na proposta comercial ##
    // ################################################################################
    If T_DETALHES->ADY_TRANSP <> ''
       oPrint:Say( _nLin,0110, "Transportadora:"  , oFont10)
       oPrint:Say (_nLin,0400, AllTrim( Posicione( "SA4", 1, xFilial("SA4") + T_DETALHES->ADY_TRANSP, "A4_NOME" )),oFont10b)
       _nLin := _nLin + 50
    Endif

    If !Empty(Alltrim(T_DETALHES->ADY_ENTREG))
       oPrint:Say( _nLin, 0110, "Prazo Entrega:"  , oFont10)
       oPrint:Say (_nLin,0400, AllTrim(T_DETALHES->ADY_ENTREG),oFont10b)
       _nLin := _nLin + 50
    Endif   

    oPrint:Line( _nLin, 0100, _nLin, 2330 )
    _nLin := _nLin + 50
    oPrint:Say(  _nLin - 20, 1000, "P R O D U T O S"  , oFont12b)

    If y___Filial == "04"
       If T_DETALHES->ADY_QEXAT == "S"
          oPrint:Say(  _nLin - 20, 1800, "QTD EXATA = SIM"  , oFont12b)          
       Endif
    Endif

	If( Select( "T_DETALHES" ) != 0 )
		T_DETALHES->( DbCloseArea() )
	EndIf

    _nLin := _nLin + 50
	oPrint:Line ( _nLin, 0100, _nLin, 2330 )

    nPosicao := _nLin

    _nLin := _nLin + 30

    // #########################################################################
    // Imprime o cabe�alho do relat�rio conforme o par�metro Imprime Garantia ##
    // #########################################################################
    If lGarantia == .T.
   	   oPrint:Say ( _nLin - 20, 0120, "PRODUTO"   , oFont08 )
 	   oPrint:Say ( _nLin - 20, 0650, "DESCRICAO" , oFont08 )
 	   oPrint:Say ( _nLin - 20, 1205, "MOEDA"     , oFont08 )
	   oPrint:Say ( _nLin - 20, 1355, "QTD"       , oFont08 )
	   oPrint:Say ( _nLin - 20, 1470, "UN"        , oFont08 )
	   oPrint:Say ( _nLin - 20, 1530, "UNIT�RIO"  , oFont08 )
	   oPrint:Say ( _nLin - 20, 1685, "SUB-TOTAL" , oFont08 )
	   oPrint:Say ( _nLin - 20, 1850, "DIF.ICMS"     , oFont08 )
	   oPrint:Say ( _nLin - 20, 1990, "VLR. TOTAL"   , oFont08 )
  	   oPrint:Say ( _nLin - 20, 2153, "Garantia-Dias", oFont08 )
  	Else
   	   oPrint:Say ( _nLin - 20, 0120, "PRODUTO"   , oFont08 )
 	   oPrint:Say ( _nLin - 20, 0650, "DESCRICAO" , oFont08 )
 	   oPrint:Say ( _nLin - 20, 1205, "MOEDA"     , oFont08 )
	   oPrint:Say ( _nLin - 20, 1355, "QTD"       , oFont08 )
	   oPrint:Say ( _nLin - 20, 1470, "UN"        , oFont08 )
	   oPrint:Say ( _nLin - 20, 1530, "UNIT�RIO"  , oFont08 )
	   oPrint:Say ( _nLin - 20, 1685, "SUB-TOTAL" , oFont08 )
	   oPrint:Say ( _nLin - 20, 1850, "DIF.ICMS"     , oFont08 )
	   oPrint:Say ( _nLin - 20, 2090, "VLR. TOTAL"   , oFont08 )
    Endif  	   

    _nLin := _nLin + 30
	oPrint:Line ( _nLin, 0100, _nLin, 2330 )
    _nLin := _nLin + 50

Return

// ####################
// Cria as perguntas ##
// ####################
Static Function GeraPerg( cPerg )

	PutSx1( cPerg, "01","OPORTUNIDADE DE?" ,"OPORTUNIDADE DE?" ,"OPORTUNIDADE DE?" ,"mv_ch1","C",6,0,0,"G","","AD1","","","mv_par01"," ","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "02","OPORTUNIDADE ATE?","OPORTUNIDADE ATE?","OPORTUNIDADE ATE?","mv_ch2","C",6,0,0,"G","","AD1","","","mv_par02"," ","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "03","PROPOSTA DE?"     ,"PROPOSTA DE?"     ,"PROPOSTA DE?"     ,"mv_ch3","C",6,0,0,"G","","ADY","","","mv_par03"," ","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "04","PROPOSTA ATE?"    ,"PROPOSTA ATE?"    ,"PROPOSTA ATE?"    ,"mv_ch4","C",6,0,0,"G","","ADY","","","mv_par04"," ","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "05","DATA INICIAL?"    ,"DATA INICIAL?"    ,"DATA INICIAL?"    ,"mv_ch5","D",8,0,2,"G","",""   ,"","","mv_par05"," ","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "06","DATA FIM?"        ,"DATA FIM?"        ,"DATA FIM?"        ,"mv_ch6","D",8,0,2,"G","",""   ,"","","mv_par06"," ","","","","","","","","","","","","","","","")

Return()

// ########################################################
// Retorna um array com as linhas de texto do campo memo ##
// ########################################################
Static Function MemoObs( cTexto, nTam )

	Local aObserv := {}
	Local nPos := 1
	Local nLinhas := nResto := 0
	
	nLinhas := MlCount( cTexto, nTam )
	
	For nX := 1 To nLinhas
		aAdd( aObserv, MemoLine( cTexto, nTam, nX ) )
	Next

Return( aObserv )

// #################################################################################################
// Imprime uma r�gua horizontal numerada de 100 em 100 e uma r�gua vertical numerada de 50 em 50  ##
// #################################################################################################
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

// ############################################################################################
// Fun��o que mostra o total da proposta comercial quando existir diferencial de al�quota    ##
// Jean Rehermann | Solutio IT | Desabilitei esta fun��o pois ser� substitu�da pela AUTOM208 ##
// ############################################################################################
//Static Function XDIFE_ICMS(_mv_par01, _mv_par02, _mv_par03, _mv_par04, _mv_par05, _mv_par06)
//
//   Local aRetDif := {}
//
//   aRetDif := U_MaVerImpos( 2, .F. )   
//    
//   xRetiR := aRetDif[08]
//   xRetiD := aRetDif[09]
//
//Return(.T.)