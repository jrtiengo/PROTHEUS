#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTA006.PRW                                                         ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 08/12/2016 - Manutenção                                             ##
// Objetivo..: Lib. de Pedidos de venda Bloqueados pelo Quoting ou Frete Gratuito. ##  
// Parâmetros: Sem Parâmetros                                                      ##
// Retorno...: .T.                                                                 ##
// ##################################################################################

User Function AUTA006

   Private cCadastro := "Liberação de Pedidos de venda Bloqueados pelo Quoting"
	
   Private aRotina := { {"Pesquisar"	,"AxPesqui"  ,0,1},;
   	        	        {"Visualizar"	,"U_VISQTG"  ,0,2},;
	    		        {"Liberar"		,"U_LIBQTG"  ,0,3},;
	    		        {"Margem/Pedido","U_AUTOM529",0,4},;
	    		        {"Legenda Tipo Bloqueio", "U_NomeLegendas",0,5} }

   //      		        {"Margem/Pedido","U_AUTOM164",0,4} }
   // Private cDelFunc := ".F." // Validacao para a exclusao. Pode-se utilizar ExecBlock
	
   Private cString := "SC6"

   U_AUTOM628("AUTA006")
	
   dbSelectArea("SC6")
   dbSetOrder(1)
	
   aCampos := {{"PedVenda"		,"C6_NUM" 	  },;
 			  {"Tipo Blq."		,"C6_ZTBL"	  },;
  			  {"Vendedor"		,"C6_VEND1"	  },;
  			  {"Nome Vendedor"	,"C6_NVEN"	  },;
  			  {"Itm"			,"C6_ITEM"	  },;
			  {"Codigo"			,"C6_PRODUTO" },;
			  {"Descricao"		,"C6_DESCRI"  },;
			  {"Unid"			,"C6_UM"	  },;
			  {"QtdVend"		,"C6_QTDVEN"  },;
			  {"R$_Unid"		,"C6_PRCVEN"  },;
			  {"R$_Total"		,"C6_VALOR"	  },;
			  {"Margem_Perc. "	,"C6_VALOR"	  },;
			  {"BloqQTG"  		,"C6_BLQ"	  }	}

// 			  {"Tipo Blq."		,"C6_ZTBL"	  },;
//     		  {"Blq.Frete"		,"C6_ZGRA"	  },;

   dbSelectArea(cString)
   Set Filter to C6_BLQ = 'S' && .OR. C6_ZGRA = 'S'
   dbGoTop()
   mBrowse( 6,1,22,75,cString,aCampos)

Return(.T.)

// ################################################################
// Função que realiza a liberação do pedido de venda selecionado ##
// ################################################################
User Function LibQtg()

   Local cCodped  := SC6->C6_NUM
   Local _lBlqItm := .f.
   Local _aArea   := GetArea()
   Local _cFil    := SC6->C6_FILIAL
	
   Reclock("SC6",.f.)
   SC6->C6_BLQ  := ""

   // #######################################################################
   // Seta o campo de indicação de frete gratuíto como N - Não liberando-o ##
   // #######################################################################
   SC6->C6_ZGRA := "L"
	
   // ################################
   // Limpa o campo Tip de Bloqueio ##
   // ################################
   SC6->C6_ZTBL := ""                                      

   // #################################################
   // Jean Rehermann | JPC - Altera o status do item ##
   // #################################################
   SC6->C6_STATUS := "01" //Aguardando Liberação
   //U_GrvLogSts(xFilial("SC6"),SC6->C6_NUM, SC6->C6_ITEM, "01", "AUTA006") // Gravo o log de atualização de status na tabela ZZ0
   U_GrvLogSts(_cFil, SC6->C6_NUM, SC6->C6_ITEM, "01", "AUTA006") // Alterado em 18/12/2012 - Filial não estava gravando corretamente no log - Jean Rehermann
	
   Msunlock()         
	
   DbSelectArea("SC6")
   DbSetOrder(1)
   //DbSeek(xFilial("SC6")+cCodPed) // Jean Rehermann - 18/12/2012 - Alterado para posicionar na filial correta
   DbSeek(_cFil + cCodPed)
	
   //Do While SC6->C6_NUM = cCodPed // Jean Rehermann - 18/12/2012 - Alterado para posicionar na filial correta
   Do While SC6->C6_NUM = cCodPed .And. SC6->C6_FILIAL == _cFil
	   
      IF SC6->C6_BLQ == "S"
   	     _lBlqItm := .T.
	  ENDIF
	
	  DbSelectArea("SC6")
	  DbSkip()
   Enddo
	
   DbSelectArea("SC5")
   DbSetOrder(1)
   //DbSeek(xfilial("SC5")+cCodPed) // Jean Rehermann - 18/12/2012 - Alterado para posicionar na filial correta
   DbSeek( _cFil + cCodPed )
   Reclock("SC5",.f.)
   C5_BLQ := IIF( _lBlqItm , "3", " " )
   Msunlock()

   Alert( Iif( _lBlqItm , "Pedido com itens ainda Bloqueados!", "Pedido Liberado!") )
	
   RestArea( _aArea )

   SYSREFRESH() 

Return(.T.)

// ###################################################
// Função que permite visualizar o custo do produto ##
// ###################################################
User Function VisQtg

   Local aArea 	  := Getarea()
   Local aAreaSB1 := SB1->(GetArea())

   Private lclose := .T.

   Define MsDialog oDlgCab Title "Detalhamento" From 10,0 to 340,630 OF oMainWnd Pixel

   @ 010,020 SAY "Custo Atual " SIZE 60,10  OF oDlgCab Pixel
   @ 010,090 SAY Posicione("SB2",1,xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL,"B2_CM1")	Picture("@E 9,999,999.99") SIZE 100,10  OF oDlgCab Pixel

   ACtivate MsDialog oDlgcab Valid lClose

   RestArea(aAreaSB1)
   RestArea(aArea)

Return(.T.)

// ###########################################################
// Função que calcula o Quoting Tools na Proposta Comercial ##
// ###########################################################
User Function QtgProp()

   Local _nMargem  := 0
   Local _cMargem  := ""
   Local _cTxt     := ""
   Local _aArea    := GetArea()
   Local _aAreaSF4 := GetArea("SF4")
   Local _aAreaSB1 := GetArea("SB1")
   Local _aAreaSB2 := GetArea("SB2")
   Local _nMargem  := 0

   Local nADZTES 	:= ascan(aHeader,{ |x| x[2] == 'ADZ_TES   ' } )
   Local nADZCOND 	:= ascan(aHeader,{ |x| x[2] == 'ADZ_CONDPG' } )
   Local nADZITEM	:= ascan(aHeader,{ |x| x[2] == 'ADZ_ITEM  ' } )
   Local nADZPROD	:= ascan(aHeader,{ |x| x[2] == 'ADZ_PRODUT' } )
   Local nADZMOED	:= ascan(aHeader,{ |x| x[2] == 'ADZ_MOEDA ' } )
   Local nADZPRC 	:= ascan(aHeader,{ |x| x[2] == 'ADZ_PRCVEN' } )
// Local nADZMIN 	:= ascan(aHeader,{ |x| x[2] == 'ADZ_QTGMIN' } )
   Local nPosMrg 	:= ascan(aHeader,{ |x| x[2] == 'ADZ_MARGEM' } )
   Local nADZMRG 	:= ascan(aHeader,{ |x| x[2] == 'ADZ_QTGMRG' } )
   Local nADZTOT 	:= ascan(aHeader,{ |x| x[2] == 'ADZ_TOTAL ' } )
   Local nADZCM1 	:= ascan(aHeader,{ |x| x[2] == 'ADZ_COMIS1' } )
   Local nADZCM2 	:= ascan(aHeader,{ |x| x[2] == 'ADZ_COMIS2' } )
   Local nADZQTD 	:= ascan(aHeader,{ |x| x[2] == 'ADZ_QTDVEN' } )
	
   Local cMsg01     := GetMv("AUT_QTGM01") // Mensagem para margem negativa
   Local cMsg02     := GetMv("AUT_QTGM02") // Mensagem para margem entre 0 e o limite definido em AUT_QTG002
   Local cMsg03     := GetMv("AUT_QTGM03") // Mensagem para margem acima do limite definido em AUT_QTG002
   Local nLimite    := GetMv("AUT_QTG002") // Delimitador de % da margem

   Local nValImp    := 0
   Local _nPrcVen   := 0
   Local _nTotItm   := 0
   Local nPpis 	    := GetMv("MV_TXPIS")  			// Percentual de PIS
   Local nPcof 	    := GetMv("MV_TXCOF")			// Percentual de COFINS
   Local nPAdm 	    := GetMv("MV_CUSTADM")			// Percentual de Custo Administrativo
   Local nPFre 	    := GetMv("MV_CUSTFRE")			// Percentual de Frete

   // #############################################
   // Jean Rehermann - 23/01/2014 - Tarefa #8459 ##
   // #############################################
   Local nPCCC := GetMv("MV_CUSTCC") //  Parâmetro que define o percentual de custo com cartão de crédito
   Local cCPCC := GetMv("MV_CONPGCC") // Condições de pagamento com cartão de credito
   Local cCond := Iif( !Empty( aCols[ n, nADZCOND ] ), aCols[ n, nADZCOND ], Space(3) ) // Condição de pagamento
			
   Local _nSumCust     := 0                          // Soma dos custos que compoe o valor de venda
   Local nCustTotFin   := 0                          // Custo financeiro total de aquisicao
   Local _nValorTot    := 0

   Private _QnAliqIcm  := 0
   Private _QnValIcm   := 0
   Private _QnBaseIcm  := 0
   Private _QnValIpi   := 0
   Private _QnBaseIpi  := 0
   Private _QnValMerc  := 0
   Private _QnValSol   := 0
   Private _QnValDesc  := 0
   Private _QnPrVen    := 0

   // ###############################################################################################################################
   // Conforme orientação do Sr. Roger no dia 03/01/2017, esta rotina de cálculo de margem foi substituida pelo programa AUTOM524. ##
   // ###############################################################################################################################

   /*

	IF !Empty( aCols[ n, nADZTES ] ) .And. aCols[ n, nADZPRC ] > 0 .And. aCols[ n, nADZQTD ] > 0 .And. !Empty( aCols[ n, nADZPROD ] )
	
		DbSelectArea("SF4")
		DbSetOrder(1)
		DbSeek(xfilial("SF4") + aCols[ n, nADZTES ] )
		
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xfilial("SB1") + aCols[ n, nADZPROD ] )
		
		DbSelectArea("SB2")
		DbSetOrder(1)
		DbSeek(xfilial("SB2") + aCols[ n, nADZPROD ] )
		
		IF SF4->F4_DUPLIC = "S" .AND. SF4->F4_ESTOQUE == "S"

			// Abaixo pego os valores base para o custo de aquisicao e para o custo de venda
			
			// Custo Medio
			nCustTotFin := SB2->B2_CM1
			// Preco de venda
			_nMoedCalc := Val( aCols[ n, nADZMOED ] )
			_nPrcVen := Iif( _nMoedCalc == 1, aCols[ n, nADZPRC ], xMoeda( aCols[ n, nADZPRC ], _nMoedCalc, 1, dDataBase, 2 ) )
			_nTotItm := Iif( _nMoedCalc == 1, aCols[ n, nADZTOT ], xMoeda( aCols[ n, nADZTOT ], _nMoedCalc, 1, dDataBase, 2 ) )
		
			// A partir daqui o valor base eh o custo medio, e calculados os custos de aquisicao ************************************************
			
			// Agrego Custo administrativo
			nCustAdm := nCustTotFin * ( nPAdm / 100 )
			nCustTotFin += nCustAdm

			// Chama o cálculo do diferencial e créditos
//			aRetDife := U_CalcST( aCols[ n, nADZPROD ], M->ADY_CLIENT, M->ADY_LOJA, _nPrcVen, aCols[ n, nADZTES ] )

            aRetDife := U_AUTOM232( M->ADY_FILIAL, M->ADY_PROPOS, aCols[ n, nADZITEM ], aCols[ n, nADZPROD ], 0, "PC", aCols[ n, nADZPRC ], aCols[ n, nADZTES ])

			_nValICMST := aRetDife[ 1 ]
			_xCustoEnt := aRetDife[ 2 ]
			_xMVA      := aRetDife[ 3 ]
			_xAliquota := aRetDife[ 4 ]
			_xReducao  := aRetDife[ 5 ]

			// Crédito Adjudicado
		    _nAdjudic := 0
            _nAdjudic := U_AUTOM231(M->ADY_FILIAL, M->ADY_PROPOS, aCols[ n, nADZITEM ], aCols[ n, nADZPROD ], 0, "PC", aCols[ n, nADZTES ], aCols[ n, nADZQTD ])

//			_nAdjudic := 0
//			If _xReducao == 0
//				_nAdjudic := ( ( ( _xCustoEnt * _xMVA ) / 100 ) * _xAliquota ) / 100
//			Else
//		   		_nAdjudic := ( ( ( ( _xCustoEnt - ( ( _xCustoEnt * _xReducao ) / 100 ) ) * _xMVA ) / 100 ) * _xAliquota ) / 100
//			Endif   

			nCustTotFin -= _nAdjudic // Subtraio valor de custo
                
			// Jean Rehermann - 23/01/2014 - Tarefa #8459 - Se condição estiver no parâmetro é com cartão de crédito
			If !Empty( AllTrim( cCPCC ) )
				If cCond $ cCPCC
					nCustCC := _nPrcVen * ( nPCCC / 100 )
					_nSumCust += nCustCC // Agrego valor de custo (Cartão de Crédito)
				EndIf
	        Else // Se parametro não for utilizado, verifico campo de forma de pagamento
	        	If M->ADY_FORMA == "2"
	        		aAreaA := GetArea()
	        		dbSelectArea("SAE")
	        		dbSetOrder(1)
	        		If dbSeek( xFilial("SAE") + M->ADY_ADM )
						nCustCC := _nPrcVen * ( SAE->AE_TAXA / 100 )
						_nSumCust += nCustCC // Agrego valor de custo (Cartão de Crédito)
	        		EndIf
	        		RestArea( aAreaA )
	        	EndIf
	        EndIf

	        // Subtraio o custo do frete
			nCustFrt := _nPrcVen * ( nPFre / 100 )
			nCustFrt := Iif( M->ADY_TPFRET == "C", nCustFrt, 0 )
			_nSumCust += nCustFrt // Agrego valor de custo (Frete)

			// Calculo os impostos
			U_MA410QTG( 1, 2, nCustFrt, _nMoedCalc )
	        
			// Subtraio PIS + COFINS
			nValImp := _nPrcVen * ( ( nPpis + nPcof ) / 100 )
			_nSumCust += nValImp // Agrego valor de custo (PIS e COFINS)
			
			// Subtraio ICMS
			nValImp := ( _QnValIcm / aCols[ n, nADZQTD ] )
			_nSumCust += nValImp // Agrego valor de custo (ICMS)

			// Diferencial Alíquota
			If _nValICMST > 0
				nValImp := ( _nValICMST / aCols[ n, nADZQTD ] )
				_nSumCust -= nValImp // Subtraio valor de custo (ICMS ST)
			EndIf
			
			// Subtraio Comissao
			nPerCom := aCols[ n, nADZCM1 ] + aCols[ n, nADZCM2 ]
			nValCom := 0

			If nPerCom > 0
				nValCom := ( _nTotItm * ( nPerCom / 100 ) ) / aCols[ n, nADZQTD ]
				_nSumCust += nValCom // Agrego valor de custo (% de Comissao)
			EndIf
			
			If !Empty( aCols[ n, nADZCOND ] )
			
				_TpCond := Posicione( "SE4", 1, xFilial("SE4") + aCols[ n, nADZCOND ], "E4_TIPO" ) //Verifico o tipo da condicao de pagamento
	
				If _TpCond != "9" // Se for tipo 9 não tenho como calcular
	
					_nValjur := 0
					_aParc := Condicao( _nPrcVen, aCols[ n, nADZCOND ], , M->ADY_DATA )
	
					For _nX := 1 To Len( _aParc )
						
						_dVenc  := _aParc[ _nX, 1 ]
						_nValor := _aParc[ _nX, 2 ]
						_nDias  := DateDiffDay( M->ADY_DATA, _dVenc )
						
						_nValjur += _nValor / ( ( 1 + ( Getmv("MV_JUROS") / 100 ) ) ** ( _nDias / 30 ) )
						
					Next
	
					_nPorJur := 1 - ( _nValJur / _nPrcVen )
					_nValJur := _nPorJur * _nPrcVen
					_nSumCust += _nValJur // Agrego valor liquido presente (% de Juros)
	
				EndIf
			
			EndIf			

			// A partir daqui comeca o calculo da margem
			_nMargem := ( ( _nPrcVen - _nSumCust ) - nCustTotFin ) // Subtraio do preco de venda, todo o custo referente o mesmo 
			_nMargem := ( _nMargem / _nPrcVen ) * 100              // % da Margem

			IF nADZMRG > 0// .And. nADZMIN > 0
				aCols[ n, nADZMRG ] := IIF( _nMargem > 999, 0, _nMargem )
			ENDIF
			
			Do Case
				Case _nMargem <= 0
					_cMargem := cMsg01
				Case _nMargem > 0 .And. _nMargem <= nLimite
					_cMargem := cMsg02
				Case _nMargem > nLimite
					_cMargem := cMsg03
			EndCase
	    ELSE
	       _cMargem := " "
		ENDIF

		If nPosMrg > 0
			aCols[ n, nPosMrg ] := _cMargem
		EndIf
		
	ENDIF

    */
	
	RestArea(_aAreaSB2)
	RestArea(_aAreaSB1)
	RestArea(_aAreaSF4)
	RestArea(_aArea)

Return(_cMargem)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ QTGTMK   ºAutor  ³Microsiga           º Data ³  10/29/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calculo do Quoting Tools no Tele Vendas                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function QtgTmk()

	Local _nMargem := 0
	Local _cMargem := "" 
	Local _cTxt    := ""
	Local _aArea    := GetArea()
	Local _aAreaSF4 := GetArea("SF4")
	Local _aAreaSB1 := GetArea("SB1")
	Local _aAreaSB2 := GetArea("SB2")

//	Local nUBFIL 	:= ascan(aHeader,{ |x| x[2] == 'UB_FILIAL '	} )

	Local nUBTES 	:= ascan(aHeader,{ |x| x[2] == 'UB_TES    '	} )
	Local nUBOPER 	:= ascan(aHeader,{ |x| x[2] == 'UB_OPER   '	} )

	Local nUBITEM	:= ascan(aHeader,{ |x| x[2] == 'UB_ITEM   ' } )

	Local nUBPROD	:= ascan(aHeader,{ |x| x[2] == 'UB_PRODUTO' } )
	Local nUBPRC 	:= ascan(aHeader,{ |x| x[2] == 'UB_VRUNIT '	} )
	//Local nUBMIN 	:= ascan(aHeader,{ |x| x[2] == 'UB_QTGMIN '	} )
	Local nPosMrg 	:= ascan(aHeader,{ |x| x[2] == 'UB_MARGEM' } )
	Local nUBMRG 	:= ascan(aHeader,{ |x| x[2] == 'UB_QTGMRG '	} )
	Local nUBTOT 	:= ascan(aHeader,{ |x| x[2] == 'UB_VLRITEM'	} )
	Local nUBQTD 	:= ascan(aHeader,{ |x| x[2] == 'UB_QUANT  '	} )

	Local cMsg01    := GetMv("AUT_QTGM01") // Mensagem para margem negativa
	Local cMsg02    := GetMv("AUT_QTGM02") // Mensagem para margem entre 0 e o limite definido em AUT_QTG002
	Local cMsg03    := GetMv("AUT_QTGM03") // Mensagem para margem acima do limite definido em AUT_QTG002
	Local nLimite   := GetMv("AUT_QTG002") // Delimitador de % da margem
	
	Local nValImp 	:= 0
	Local _nPrcVen  := 0
	Local _nTotItm  := 0
	Local nPpis 	:= GetMv("MV_TXPIS")  			// Percentual de PIS
	Local nPcof 	:= GetMv("MV_TXCOF")			// Percentual de COFINS
	Local nPAdm 	:= GetMv("MV_CUSTADM")			// Percentual de Custo Administrativo
	Local nPFre 	:= GetMv("MV_CUSTFRE")			// Percentual de Frete

	// Jean Rehermann - 23/01/2014 - Tarefa #8459 
	Local nPCCC := GetMv("MV_CUSTCC") // Parâmetro que define o percentual de custo com cartão de crédito: nPCCC
	Local cCPCC := GetMv("MV_CONPGCC") // Condições de pagamento com cartão de credito
	Local cCond := M->UA_CONDPG       // Condição de pagamento

	Local _nSumCust   := 0                          // Soma dos custos que compoe o valor de venda
	Local nCustTotFin := 0                          // Custo financeiro total de aquisicao
	Local _nValorTot  := 0

	Private _QnAliqIcm  := 0
	Private _QnValIcm   := 0
	Private _QnBaseIcm  := 0
	Private _QnValIpi   := 0
	Private _QnBaseIpi  := 0
	Private _QnValMerc  := 0
	Private _QnValSol   := 0
	Private _QnValDesc  := 0
	Private _QnPrVen    := 0

	IF !Empty( aCols[ n, nUBTES ] ) .And. aCols[ n, nUBQTD ] > 0 .And. !Empty( aCols[ n, nUBPROD ] ) .And. aCols[ n, nUBPRC ] > 0

		DbSelectArea("SF4")
		DbSetOrder(1)
		DbSeek(xfilial("SF4") + aCols[ n, nUBTES ] )
		
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xfilial("SB1") + aCols[ n, nUBPROD ] )
		
		DbSelectArea("SB2")
		DbSetOrder(1)
		DbSeek(xfilial("SB2") + aCols[ n, nUBPROD ] + SB1->B1_LOCPAD )
		
		IF SF4->F4_DUPLIC == "S" .AND. SF4->F4_ESTOQUE == "S"
			
			// Abaixo pego os valores base para o custo de aquisicao e para o custo de venda
			
			// Custo Medio
			nCustTotFin := SB2->B2_CM1
			// Preco de venda
			_nMoedCalc := M->UA_MOEDA
			_nPrcVen := Iif( _nMoedCalc == 1, aCols[ n, nUBPRC ], xMoeda( aCols[ n, nUBPRC ], _nMoedCalc, 1, dDataBase, 2 ) )
			_nTotItm := Iif( _nMoedCalc == 1, aCols[ n, nUBTOT ], xMoeda( aCols[ n, nUBTOT ], _nMoedCalc, 1, dDataBase, 2 ) )

			// A partir daqui o valor base eh o custo medio, e calculados os custos de aquisicao ************************************************

			// Agrego Custo administrativo
			nCustAdm := nCustTotFin * ( nPAdm / 100 )
			nCustTotFin += nCustAdm

			// Chama o cálculo do diferencial e créditos
//			aRetDife := U_CalcST( aCols[ n, nUBPROD ], M->UA_CLIENT, M->UA_LOJA, _nPrcVen, aCols[ n, nUBTES ] )

            aRetDife := U_AUTOM232( cFilAnt, M->UA_NUM, aCols[ n, nUBITEM ], aCols[ n, nUBPROD ], 0, "CC", aCols[ n, nUBPRC ], aCols[ n, nUBTES ])

			_nValICMST := aRetDife[ 1 ]
			_xCustoEnt := aRetDife[ 2 ]
			_xMVA      := aRetDife[ 3 ]
			_xAliquota := aRetDife[ 4 ]
			_xReducao  := aRetDife[ 5 ]

			// Crédito Adjudicado
		    _nAdjudic := 0
            _nAdjudic := U_AUTOM231( cFilAnt, M->UA_NUM, aCols[ n, nUBITEM ], aCols[ n, nUBPROD ], 0, "CC", aCols[ n, nUBTES ], aCols[ n, nUBQTD ])

//			_nAdjudic := 0
//			If _xReducao == 0
//				_nAdjudic := ( ( ( _xCustoEnt * _xMVA ) / 100 ) * _xAliquota ) / 100
//			Else
//		   		_nAdjudic := ( ( ( ( _xCustoEnt - ( ( _xCustoEnt * _xReducao ) / 100 ) ) * _xMVA ) / 100 ) * _xAliquota ) / 100
//			Endif   

			nCustTotFin -= _nAdjudic // Subtraio valor de custo
                
			// A partir daqui o valor base eh o preco de venda, e calculados os custos sobre a venda *********************************************

			// Jean Rehermann - 23/01/2014 - Tarefa #8459 - Se condição estiver no parâmetro é com cartão de crédito
			nCustCC := 0
			If cCond $ cCPCC
				nCustCC := _nPrcVen * ( nPCCC / 100 )
				_nSumCust += nCustCC // Agrego valor de custo (Cartão de Crédito)
			EndIf

	        // Subtraio o custo do frete
			nCustFrt := _nPrcVen * ( nPFre / 100 )
			nCustFrt := Iif( M->UA_TPFRETE == "C", nCustFrt, 0 )
			_nSumCust += nCustFrt // Agrego valor de custo (Frete)

			// Calculo os impostos
			U_MA410QTG( 1, 3, nCustFrt, _nMoedCalc )
	        
			// Subtraio PIS + COFINS
			nValImp := _nPrcVen * ( ( nPpis + nPcof ) / 100 )
			_nSumCust += nValImp // Agrego valor de custo (PIS e COFINS)
			
			// Subtraio ICMS
			nValImp := ( _QnValIcm / aCols[ n, nUBQTD ] )
			_nSumCust += nValImp // Agrego valor de custo (ICMS)

			// Diferencial Alíquota
			If _nValICMST > 0
				nValImp := ( _nValICMST / aCols[ n, nUBQTD ] )
				_nSumCust -= nValImp // Subtraio valor de custo
			EndIf
			
			// Subtraio Comissao
			nPerCom := M->UA_COMIS + M->UA_COMIS2
			nValCom := 0

			If nPerCom > 0
				nValCom := ( _nTotItm * ( nPerCom / 100 ) ) / aCols[ n, nUBQTD ]
				_nSumCust += nValCom // Agrego valor de custo (% de Comissao)
			EndIf
			
			If !Empty( M->UA_CONDPG )

				_TpCond := Posicione( "SE4", 1, xFilial("SE4") + M->UA_CONDPG, "E4_TIPO" ) //Verifico o tipo da condicao de pagamento
	
				If _TpCond != "9" // Se for tipo 9 não tenho como calcular
	
					_nValjur := 0
					_aParc := Condicao( _nPrcVen, M->UA_CONDPG, , M->UA_EMISSAO )
	
					For _nX := 1 To Len( _aParc )

						_dVenc  := _aParc[ _nX, 1 ]
						_nValor := _aParc[ _nX, 2 ]
						_nDias  := DateDiffDay( M->UA_EMISSAO, _dVenc )
						
						_nValjur += _nValor / ( ( 1 + ( Getmv("MV_JUROS") / 100 ) ) ** ( _nDias / 30 ) )

					Next
	
					_nPorJur := 1 - ( _nValJur / _nPrcVen )
					_nValJur := _nPorJur * _nPrcVen
					_nSumCust += _nValJur // Agrego valor liquido presente (% de Juros)
	
				EndIf
			
            EndIf
            
			// A partir daqui comeca o calculo da margem
			_nMargem := ( ( _nPrcVen - _nSumCust ) - nCustTotFin )// Subtraio do preco de venda, todo o custo referente o mesmo 
			_nMargem := ( _nMargem / _nPrcVen ) * 100 // % da Margem
			
			IF nUBMRG > 0// .And. nUBMIN > 0
				//aCols[ n, nUBMIN ] := 0
				aCols[ n, nUBMRG ] := IIF( _nMargem > 999, 0, _nMargem )
			ENDIF
			
			Do Case
				Case _nMargem <= 0
					_cMargem := cMsg01
				Case _nMargem > 0 .And. _nMargem <= nLimite
					_cMargem := cMsg02
				Case _nMargem > nLimite
					_cMargem := cMsg03
			EndCase
	    ELSE
	       _cMargem := " "
		ENDIF

		If nPosMrg > 0
			aCols[ n, nPosMrg ] := _cMargem
		EndIf
		
	ENDIF
	
	RestArea(_aAreaSB2)
	RestArea(_aAreaSB1)
	RestArea(_aAreaSF4)
	RestArea(_aArea)

Return(_cMargem)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ QTGPED   ºAutor  ³Microsiga           º Data ³  10/29/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calculo do Quoting Tools no Pedido de Vendas               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function QtgPed()

	Local _cMargem := ""
	Local _nMargem := 0
	Local _cTxt    := ""
	Local _aArea    := GetArea()
	Local _aAreaSF4 := GetArea("SF4")
	Local _aAreaSB1 := GetArea("SB1")
	Local _aAreaSB2 := GetArea("SB2")

	Local nPosItem := aScan( aHeader, { |x| x[2] == 'C6_ITEM   ' } )
	Local nPosProd := aScan( aHeader, { |x| x[2] == 'C6_PRODUTO' } )
	Local nPosTes  := aScan( aHeader, { |x| x[2] == 'C6_TES    ' } )
	Local nPosQtde := aScan( aHeader, { |x| x[2] == 'C6_QTDVEN ' } )
	Local nPosTot  := aScan( aHeader, { |x| x[2] == 'C6_VALOR  ' } )
	Local nPosPrc  := aScan( aHeader, { |x| x[2] == 'C6_PRCVEN ' } )
	Local nPosBlq  := aScan( aHeader, { |x| x[2] == 'C6_BLQ    ' } )
	Local nPosCm1  := aScan( aHeader, { |x| x[2] == 'C6_COMIS1 ' } )
	Local nPosCm2  := aScan( aHeader, { |x| x[2] == 'C6_COMIS2 ' } )
	Local nPosCm3  := aScan( aHeader, { |x| x[2] == 'C6_COMIS3 ' } )
	Local nPosCm4  := aScan( aHeader, { |x| x[2] == 'C6_COMIS4 ' } )
	Local nPosCm5  := aScan( aHeader, { |x| x[2] == 'C6_COMIS5 ' } )
//  Local nPosMin  := aScan( aHeader, { |x| x[2] == 'C6_QTGMIN ' } )
	Local nPosMar  := aScan( aHeader, { |x| x[2] == 'C6_QTGMRG ' } )
	Local nPosMrg  := aScan( aHeader, { |x| x[2] == 'C6_MARGEM ' } )

	Local cMsg01    := GetMv("AUT_QTGM01") // Mensagem para margem negativa
	Local cMsg02    := GetMv("AUT_QTGM02") // Mensagem para margem entre 0 e o limite definido em AUT_QTG002
	Local cMsg03    := GetMv("AUT_QTGM03") // Mensagem para margem acima do limite definido em AUT_QTG002
	Local nLimite   := GetMv("AUT_QTG002") // Delimitador de % da margem
	
	Local nValImp 	:= 0
	Local _nPrcVen  := 0
	Local _nTotItm  := 0
	Local nPpis 	:= GetMv("MV_TXPIS")  			// Percentual de PIS
	Local nPcof 	:= GetMv("MV_TXCOF")			// Percentual de COFINS
	Local nPAdm 	:= GetMv("MV_CUSTADM")			// Percentual de Custo Administrativo
	Local nPFre 	:= GetMv("MV_CUSTFRE")			// Percentual de Frete

	// Jean Rehermann - 23/01/2014 - Tarefa #8459 
	Local nPCCC := GetMv("MV_CUSTCC") // Parâmetro que define o percentual de custo com cartão de crédito: nPCCC
	Local cCPCC := GetMv("MV_CONPGCC") // Condições de pagamento com cartão de credito
	Local cCond := M->C5_CONDPAG      // Condição de pagamento

	Local _nSumCust   := 0                          // Soma dos custos que compoe o valor de venda
	Local nCustTotFin := 0                          // Custo financeiro total de aquisicao
	Local _nValorTot  := 0

	Private _QnAliqIcm  := 0
	Private _QnValIcm   := 0
	Private _QnBaseIcm  := 0
	Private _QnValIpi   := 0
	Private _QnBaseIpi  := 0
	Private _QnValMerc  := 0
	Private _QnValSol   := 0
	Private _QnValDesc  := 0
	Private _QnPrVen    := 0

    // ###################################################################################################################
    // 03/01/2017                                                                                                       ##
    // Conforme orientações do Sr. Roger, nesta data, este processo não deve ser executado.                             ##
    // Este processo foi subtituído pelo programa customizado AUTOM524 (Novo programa de cálculo de margem dos produtos ##
    // ###################################################################################################################                                                                                                                        

    /*

	If M->C5_TIPO == "N"

		If !Empty( aCols[ n, nPosTES ] ) .And. aCols[ n, nPosQtde ] > 0 .And. !Empty( aCols[ n, nPosProd ] ) .And. aCols[ n, nPosPrc ] > 0
	
			DbSelectArea("SF4")
			DbSetOrder(1)
			DbSeek(xfilial("SF4") + aCols[ n, nPosTES ] )
			
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xfilial("SB1") + aCols[ n, nPosProd ] )
			
			DbSelectArea("SB2")
			DbSetOrder(1)
			DbSeek(xfilial("SB2") + aCols[ n, nPosProd ] + SB1->B1_LOCPAD )
			
			If SF4->F4_DUPLIC == "S" .AND. SF4->F4_ESTOQUE == "S"
				
				// Abaixo pego os valores base para o custo de aquisicao e para o custo de venda
				
				// Custo Medio
				nCustTotFin := SB2->B2_CM1
				// Preco de venda
				_nMoedCalc := M->C5_MOEDA
				_nPrcVen := Iif( _nMoedCalc == 1, aCols[ n, nPosPrc ], xMoeda( aCols[ n, nPosPrc ], _nMoedCalc, 1, dDataBase, 2 ) )
				_nTotItm := Iif( _nMoedCalc == 1, aCols[ n, nPosTot ], xMoeda( aCols[ n, nPosTot ], _nMoedCalc, 1, dDataBase, 2 ) )


				// A partir daqui o valor base eh o custo medio, e calculados os custos de aquisicao ************************************************
	
				// Agrego Custo administrativo
				nCustAdm := nCustTotFin * ( nPAdm / 100 )
				nCustTotFin += nCustAdm
	
				// Chama o cálculo do diferencial e créditos
//				aRetDife := U_CalcST( aCols[ n, nPosProd ], M->C5_CLIENTE, M->C5_LOJACLI, _nPrcVen, aCols[ n, nPosTes ] )
				
                aRetDife := U_AUTOM232( M->C5_FILIAL, M->C5_NUM, aCols[ n, nPosItem ], aCols[ n, nPosProd ], 0, "PV", aCols[ n, nPosPrc ], aCols[ n, nPosTes ])

				_nValICMST := aRetDife[ 1 ]
				_xCustoEnt := aRetDife[ 2 ]
				_xMVA      := aRetDife[ 3 ]
				_xAliquota := aRetDife[ 4 ]
				_xReducao  := aRetDife[ 5 ]
	
				// Crédito Adjudicado
   		        _nAdjudic := 0
                _nAdjudic := U_AUTOM231(M->C5_FILIAL, M->C5_NUM, aCols[ n, nPosItem ], aCols[ n, nPosProd ], 0, "PV", aCols[ n, nPosTes ], aCols[ n, nPosQtde ])

//			    _nAdjudic := 0
// 			    If _xReducao == 0
//			       _nAdjudic := ( ( ( _xCustoEnt * _xMVA ) / 100 ) * _xAliquota ) / 100
//			    Else
//			       _nAdjudic := ( ( ( ( _xCustoEnt - ( ( _xCustoEnt * _xReducao ) / 100 ) ) * _xMVA ) / 100 ) * _xAliquota ) / 100
//			    Endif   

				nCustTotFin -= _nAdjudic // Subtraio valor de custo
                
				// A partir daqui o valor base eh o preco de venda, e calculados os custos sobre a venda
	
				// Jean Rehermann - 23/01/2014 - Tarefa #8459 - Se condição estiver no parâmetro é com cartão de crédito
				If !Empty( AllTrim( cCPCC ) )
					If cCond $ cCPCC
						nCustCC := _nPrcVen * ( nPCCC / 100 )
						_nSumCust += nCustCC // Agrego valor de custo (Cartão de Crédito)
					EndIf
		        Else // Se parametro não for utilizado, verifico campo de forma de pagamento
		        	If M->C5_FORMA == "2"
		        		aAreaA := GetArea()
		        		dbSelectArea("SAE")
		        		dbSetOrder(1)
		        		If dbSeek( xFilial("SAE") + M->C5_ADM )
							nCustCC := _nPrcVen * ( SAE->AE_TAXA / 100 )
							_nSumCust += nCustCC // Agrego valor de custo (Cartão de Crédito)
		        		EndIf
		        		RestArea( aAreaA )
		        	EndIf
		        EndIf
	
		        // Subtraio o custo do frete
				nCustFrt := _nPrcVen * ( nPFre / 100 )
				nCustFrt := Iif( M->C5_TPFRETE == "C", nCustFrt, 0 )
				_nSumCust += nCustFrt // Agrego valor de custo (Frete)
				
				// Calculo os impostos
				U_MA410QTG( 1, 1, nCustFrt, _nMoedCalc )
		        
				// Subtraio PIS + COFINS
				nValImp := _nPrcVen * ( ( nPpis + nPcof ) / 100 )
				_nSumCust += nValImp // Agrego valor de custo (PIS e COFINS)
				
				// Subtraio ICMS
				nValImp := ( _QnValIcm / aCols[ n, nPosQtde ] )
				_nSumCust += nValImp // Agrego valor de custo (ICMS)
	
				// Diferencial Alíquota
				If _nValICMST > 0
					nValImp := ( _nValICMST / aCols[ n, nPosQtde ] )
					_nSumCust -= nValImp // Subtraio valor de custo
				EndIf
				
				// Subtraio Comissao
				nPerCom := aCols[ n, nPosCm1 ] + aCols[ n, nPosCm2 ] + aCols[ n, nPosCm3 ] + aCols[ n, nPosCm4 ] + aCols[ n, nPosCm5 ]
				nValCom := 0
	
				If nPerCom > 0
					nValCom := ( _nTotItm * ( nPerCom / 100 ) ) / aCols[ n, nPosQtde ]
					_nSumCust += nValCom // Agrego valor de custo (% de Comissao)
				EndIf
				
				If !Empty( M->C5_CONDPAG )
	
					_TpCond := Posicione( "SE4", 1, xFilial("SE4") + M->C5_CONDPAG, "E4_TIPO" ) //Verifico o tipo da condicao de pagamento
		
					If _TpCond != "9" // Se for tipo 9 não tenho como calcular
		
						_nValjur := 0
						_aParc := Condicao( _nPrcVen, M->C5_CONDPAG, , M->C5_EMISSAO )
		
						For _nX := 1 To Len( _aParc )

							_dVenc  := _aParc[ _nX, 1 ]
							_nValor := _aParc[ _nX, 2 ]
							_nDias  := DateDiffDay( M->C5_EMISSAO, _dVenc )
							
							_nValjur += _nValor / ( ( 1 + ( Getmv("MV_JUROS") / 100 ) ) ** ( _nDias / 30 ) )

						Next
		
						_nPorJur := 1 - ( _nValJur / _nPrcVen )
						_nValJur := _nPorJur * _nPrcVen
						_nSumCust += _nValJur // Agrego valor liquido presente (% de Juros)
		
					EndIf
				
	            EndIf
	            
	            
				// A partir daqui comeca o calculo da margem
				_nMargem := ( ( _nPrcVen - _nSumCust ) - nCustTotFin )// Subtraio do preco de venda, todo o custo referente o mesmo 
				_nMargem := ( _nMargem / _nPrcVen ) * 100 // % da Margem
				
				If nPosMar > 0 //.And. nPosMin > 0
					//aCols[ n, nPosMin ] := 0
					aCols[ n, nPosMar ] := Iif( _nMargem > 999, 0, _nMargem )
				EndIf
				
				Do Case
					Case _nMargem <= 0
						_cMargem := cMsg01
					Case _nMargem > 0 .And. _nMargem <= nLimite
						_cMargem := cMsg02
					Case _nMargem > nLimite
						_cMargem := cMsg03
				EndCase
		    Else
		       _cMargem := " "
			EndIf
			
			If nPosMrg > 0
				aCols[ n, nPosMrg ] := _cMargem
			EndIf
					
		EndIf
	
	EndIf

    */
	
	RestArea(_aAreaSB2)
	RestArea(_aAreaSB1)
	RestArea(_aAreaSF4)
	RestArea(_aArea)

Return( _cMargem )

Static Function Mostra(cTxt)

	Local oDlg
	Local cMemo    := cTxt
	Local cFile    := ""
	Local cMask    := "Arquivos Texto (*.TXT) |*.txt|"
	Local oFont 
	
	DEFINE FONT oFont NAME "Courier New" SIZE 5,0

	DEFINE MSDIALOG oDlg TITLE "Cálculo da Margem" From 3,0 to 340,417 PIXEL

	@ 5,5 GET oMemo  VAR cMemo MEMO SIZE 200,145 OF oDlg PIXEL 
	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:=oFont

	DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTER

Return

User Function MargemBut(nTipo)
	
	Local nTipo  := Iif( ValType( nTipo ) <> "N", 1, nTipo )
	Local nTotI  := Len( aCols )
	Local _nX    := 0
	Local _nAnt  := n    

	For _nX := 1 To nTotI

		n := _nX
		
		Do Case
			Case nTipo == 1
				U_QtgPed()
			Case nTipo == 2
				U_QtgProp()
			Case nTipo == 3
				U_QtgTmk()
		EndCase
	
	Next
	
	n := _nAnt
	
Return

// #####################################################################################
// Função que abre mensagem informando a descrição das legendas dos tipos de bloqueio ##
// #####################################################################################
User Function NomeLegendas()

   MsgAlert("Descrição das Legendas de Tipos de Bloqueios"          + chr(13) + chr(10) + chr(13) + chr(10) + ;
            "MRG - Bloqueio por Margem"                             + chr(13) + chr(10) + ;
            "SIM - Bloqueio por Frete Gratuito"                     + chr(13) + chr(10) + ;
            "TES - Bloqueio por TES (Financeiro=NÃO e Estoque=SIM)" + chr(13) + chr(10) + ;
            "DOA - Bloqueio por Doação"                             + chr(13) + chr(10) + ;
            "PAG - Bloqueio por Condição de Pagamento"              + chr(13) + chr(10) + ;
            "FRT - Bloqueio por Frete (Regra Proposta Comercial)")

Return(.T.)