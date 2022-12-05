#INCLUDE "PROTHEUS.CH"

/* Programa para calcular o ICMS ST, adjudicação fiscal e diferencial de alíquota
aProd = {PRODUTO, TOTAL_DO_ITEM, TES}
_tCalculo == "T" - Total, "I" - Individual
_Proposta == Código da Proposta Comercial
*/
User Function AUTOM208( aProd, cCli, cLoja, nFrete, _Moeda, _tCalculo, _Proposta, _TProduto, _KFilial )

    Local cSql       := ""
    Local nContar    := 0
	Local nRet       := 0
	Local nTotal     := 0
	Local nTConf     := 0
    Local cItem      := ""
	Local cProd      := ""
	Local cTes       := ""
    Local cOri       := ""
    lOCAL cNcm       := ""
    Local cCFOP      := ""
    Local xCNPJ      := ""
	Local _ALQINTEST := 0
	Local _ALQINT    := 0
	Local MV_ESTICM  := SuperGetMV("MV_ESTICM")
	
	// Campos do Cliente
	Local cEst  := Posicione("SA1", 1, xFilial("SA1") + cCli + cLoja, "A1_EST")
	Local cTip  := Posicione("SA1", 1, xFilial("SA1") + cCli + cLoja, "A1_TIPO")
	Local cGrp  := Posicione("SA1", 1, xFilial("SA1") + cCli + cLoja, "A1_GRPTRIB")
	Local xCNPJ := Posicione("SA1", 1, xFilial("SA1") + cCli + cLoja, "A1_CGC")

	// Campos da TES
	Local cSol := ""
	Local cIcm := ""
	
	// Campo do Produto
	Local cGtp := ""
	//Local cOri := ""

    U_AUTOM628("AUTOM208")

    // Pesquisa o valor total da proposta comercial
    If (Select( "T_CALTOTAL" ) != 0 )
       T_CALTOTAL->( DbCloseArea() )
    EndIf

    cSql := "SELECT SUM(ADZ_TOTAL) AS TTOTAL"
    cSql += "  FROM " + RetSqlName("ADZ")
    cSql += " WHERE ADZ_FILIAL = '" + Alltrim(_KFilial)  + "'"
    cSql += "   AND ADZ_PROPOS = '" + Alltrim(_Proposta) + "'"
    cSql += "   AND D_E_L_E_T_ = ''"

    cSql := ChangeQuery( cSql )
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_CALTOTAL",.T.,.T.)
    
    If nFrete > 0

       aEval( aProd, { |o| nTotal += o[2] } )                                            // Somo o total de cada item para obter o total da mercadoria
       aEval( aProd, { |o| o[2] := Round( o[2] + ( ( o[2] / nTotal ) * nFrete ), 2 ) } ) // Rateio o valor do frete para cada item
       aEval( aProd, { |o| nTConf += o[2] } )                                            // Somo o total de cada item com frete para verificar se valor está correto (arredondamentos)

       If _tCalculo == "I"
          aProd[1,2] := _TProduto + Round((nFrete * Round(((_TProduto / T_CALTOTAL->TTOTAL) * 100),2) / 100),2)
       Else
          If nTConf <> ( nTotal + nFrete )                                                  // Em caso de diferença ajusto os centavos no primeiro item
       	     nDif := Abs( ( nTotal + nFrete ) - nTConf )
    	     If nTConf >( nTotal + nFrete )
    	 	    aProd[1,2] -= nDif
   		     Else
    	 	    aProd[1,2] += nDif
   		     EndIf
   	      EndIf
       EndIf
       
    Endif   

	// Verifica se o Estado da Empresa Logada é diferente do estado do cliente
	If Alltrim(cEst) == Alltrim(SM0->M0_ESTENT)
		Return( nRet )
	Endif
 
	// Verifica se cliente é F = Consumidor Final
	If Alltrim(cTip) <> "F"
		Return( nRet )
	Endif

	// Verifica se IE do Cliente está Ativa
	If Alltrim(cGrp) <> "002"
       Return( nRet )
	Endif
 
	For nContar := 1 To Len( aProd )
	    
        If _tCalculo = "I"
           If _Moeda == 1
              If aProd[ nContar ][ 4 ] <> '1'
                 Loop
              Endif
           Else
              If aProd[ nContar ][ 4 ] <> '2'
                 Loop
              Endif
           Endif
        Else
           
           If ValType(aProd[ nContar ][ 4 ]) == "C"
              If aProd[ nContar ][ 4 ] <> IIF(Type("_Moeda") == "U", Alltrim(Str(_Moeda)), _Moeda)
                 Loop
              Endif
           Else
              If aProd[ nContar ][ 4 ] <> _Moeda
                 Loop
              Endif
           Endif
        Endif

        cItem := aProd[ nContar ][ 5 ]
		cProd := aProd[ nContar ][ 1 ]
		cTes  := aProd[ nContar ][ 3 ]

		cSol  := Posicione("SF4", 1, xFilial("SF4") + cTes, "F4_INCSOL")
		cIcm  := Posicione("SF4", 1, xFilial("SF4") + cTes, "F4_ICM")
		cCFOP := Posicione("SF4", 1, xFilial("SF4") + cTes, "F4_CF")

        If cEst <> "CE"
           If Alltrim(cCfop) == "5102" .Or. Alltrim(cCfop) == "6102" .Or. Alltrim(cCfop) == ""
              If _tCalculo == "I"
                 Return( nRet )
              Else
                 Loop
              Endif
           Endif   
        Endif

		cGtp := Posicione("SB1", 1, xFilial("SB1") + cProd, "B1_GRTRIB")
		cOri := Posicione("SB1", 1, xFilial("SB1") + cProd, "B1_ORIGEM")
		cNcm := Alltrim(Posicione("SB1", 1, xFilial("SB1") + cProd, "B1_POSIPI"))

		// Verifica o ICM Solidário
		If !(cSol <> "S") .And. !(cIcm <> "S") .And. !(AllTrim( cGtp ) == "017")
            
           // Carrega a alíquota interestadual pela origem do produto
           Do Case
              Case cOri = "0"
     		       If cEst $ "MG/PR/RJ/SC/SP"
			          _ALQINTEST := 12
                      
                      If cEst $ "RJ"			          
			             _ALQINTEST := 13
			          Endif   
			          			          
			       ElseIf cEst $ "AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RO/RR/SE/TO"
				      _ALQINTEST := 7
			       Endif
              Case cOri = "1"
		           _ALQINTEST := 4
              Case cOri = "2"
		           _ALQINTEST := 4
              Case cOri = "3"
		           _ALQINTEST := 4
              Case cOri = "4"
     		       If cEst $ "MG/PR/RJ/SC/SP"
			          _ALQINTEST := 12
			       ElseIf cEst $ "AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RO/RR/SE/TO"
				      _ALQINTEST := 7
			       Endif
              Case cOri = "5"
     		       If cEst $ "MG/PR/RJ/SC/SP"
			          _ALQINTEST := 12
			       ElseIf cEst $ "AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RO/RR/SE/TO"
				      _ALQINTEST := 7
			       Endif
              Case cOri = "6"
     		       If cEst $ "MG/PR/RJ/SC/SP"
			          _ALQINTEST := 12
			       ElseIf cEst $ "AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RO/RR/SE/TO"
				      _ALQINTEST := 7
			       Endif
              Case cOri = "7"
     		       If cEst $ "MG/PR/RJ/SC/SP"
			          _ALQINTEST := 12
			       ElseIf cEst $ "AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RO/RR/SE/TO"
				      _ALQINTEST := 7
			       Endif
		   EndCase        
		
		   If cEst $ "MG/PR/SP"
		   	  _ALIQINT := 18
		   ElseIf cEst $ "RJ"

		      _ALIQINT := 19

              If Substr(cNcm,01,04) == "8471"
    		     _ALIQINT := 13
    		  Endif                               

              If Substr(cNcm,01,06) == "847130"
    		     _ALIQINT := 19
    		  Endif                               

		   ElseIf cEst $ "AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RS/RO/RR/SC/SE/TO"
		   	  _ALIQINT := 17
		   EndIf

           // Verifica se existe execeção fiscal
   	       If (Select( "T_DETALHES" ) != 0 )
		      T_DETALHES->( DbCloseArea() )
	       EndIf

           cSql := ""
           cSql := "SELECT F7_ALIQDST"
           cSql += "  FROM " + RetSqlName("SF7")
           cSql += " WHERE F7_GRTRIB  = '" + Alltrim(cGtp) + "'"
           cSql += "   AND F7_EST     = '" + Alltrim(cEst) + "'"
           cSql += "   AND F7_TIPOCLI = '" + Alltrim(cTip) + "'"
           cSql += "   AND F7_GRPCLI  = '" + Alltrim(cGrp) + "'"
           cSql += "   AND D_E_L_E_T_ = ''"
                   
  	       cSql := ChangeQuery( cSql )
 	       dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_DETALHES",.T.,.T.)

           If T_DETALHES->( EOF() )
           Else
              If T_DETALHES->F7_ALIQDST == 0
              Else
    		     If cEst == "RJ"
                    _ALIQINT := T_DETALHES->F7_ALIQDST + 1
                 Else
                    _ALIQINT := T_DETALHES->F7_ALIQDST
                 Endif   
              Endif
           Endif

		   If cEst == "RJ"
              If Substr(cNcm,01,04) == "8471"
    		     _ALIQINT := 13
    		  Endif                               
              If Substr(cNcm,01,06) == "847130"
    		     _ALIQINT := 19
    		  Endif                               
    	   Endif

           // Aplica o cálculo e acumula (item)
           If _tCalculo == "T"      
   		      nRet += ( aProd[ nContar ][ 2 ] * ( _ALIQINT / 100 ) ) - ( aProd[ nContar ][ 2 ] * ( _ALQINTEST / 100 ) ) 
   		   Else
   		      nRet := ( aProd[ nContar ][ 2 ] * ( _ALIQINT / 100 ) ) - ( aProd[ nContar ][ 2 ] * ( _ALQINTEST / 100 ) )
           Endif

		EndIf

	Next

    If _tCalculo == "I"
   	   If Alltrim(cEst) == "CE"
          nRet := 0
       Endif
    Endif

	// Verifica se o Estado do Cliente é CE.
	// Se for, calcula o diferencial mas não imprime na proposta comercial, somente avise o vendedor do valor que deverá ser necegociado separadamente.
    If _tCalculo == "T"
   	   If Alltrim(cEst) == "CE"
          If nRet <> 0
//           MsgAlert("Atenção! O estado do Cliente é CE - Ceará. Conforme protocolo de ICMSST, o valor do Diferencial de ICMS deverá ser negociado separadamente em um Acordo Comercial no Valor de R$ " + Transform(nRet, "9999999.99") + ".")
             nRet := 0
          Endif   
       Endif
    Endif


//    TelaConfere()
    
Return( nRet )

// Tela de visualização dos valores das variáveis do cálculo do Diferencial de Alíquota
Static Function TelaConfere()

   Local nBase1	   := 0
   Local nBase2	   := 0
   Local nPerc1    := 0
   Local nPerc2	   := 0
   Local nIcms1	   := 0
   Local nIcms2    := 0
   Local nSubtotal := 0
   Local nFrete    := 0
   Local nRetido   := 0
   Local nTotal    := 0

   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5
   Local oGet6
   Local oGet7                                 
   Local oGet8
   Local oGet9
   Local oGet10

   Private oDlgD

   DEFINE MSDIALOG oDlgD TITLE "Variáveis de Cálculo Diferencial de Alíquota" FROM C(178),C(181) TO C(569),C(960) PIXEL

   @ C(005),C(005) Say "Ítens da Proposta Comercial" Size C(068),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(141),C(015) Say "ICMS"                        Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(141),C(187) Say "Sub-Total"                   Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(154),C(015) Say "ICMS Retido"                 Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(154),C(187) Say "Frete"                       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(168),C(187) Say "ICM Retido"                  Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(181),C(187) Say "Total Proposta"              Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlgD

   @ C(139),C(053) MsGet oGet1  Var nBase1    When lChumba Size C(043),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgD
   @ C(153),C(053) MsGet oGet2  Var nBase2    When lChumba Size C(043),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgD
   @ C(139),C(100) MsGet oGet3  Var nPerc1    When lChumba Size C(021),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgD
   @ C(153),C(100) MsGet oGet4  Var nPerc2    When lChumba Size C(021),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgD
   @ C(139),C(125) MsGet oGet5  Var nIcms1    When lChumba Size C(043),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgD
   @ C(153),C(125) MsGet oGet6  Var nIcms2    When lChumba Size C(043),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgD
   @ C(139),C(228) MsGet oGet7  Var nSubTotal When lChumba Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgD
   @ C(153),C(228) MsGet oGet8  Var nFrete    When lChumba Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgD
   @ C(166),C(228) MsGet oGet9  Var nRetido   When lChumba Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgD
   @ C(180),C(228) MsGet oGet10 Var nTotal    When lChumba Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgD

   @ C(157),C(317) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgD ACTION( oDlgD:End() )

   ACTIVATE MSDIALOG oDlgD CENTERED

Return(.T.)