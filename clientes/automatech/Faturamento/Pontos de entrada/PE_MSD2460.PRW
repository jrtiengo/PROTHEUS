#include "rwmake.ch"

// ###############################################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                                        ##
// ------------------------------------------------------------------------------------------------------------ ##
// Referencia: PE_MSD2460.PRW                                                                                   ##
// Parâmetros: Nenhum                                                                                           ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                                                  ##
// ------------------------------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                                          ##
// Data......: 02/01/2017                                                                                       ##
// Objetivo..: Jean Rehermann | Solutio - 06/02/2012 - Grava os novos campos da margem, para gerar relatorio.   ##
//      	   MSD2460 - Ponto de entrada executado apos a gravacao de cada item no SD2                         ##
//  	       Esta posicionado tanto no SC6 quanto no SD2 e o registro do D2 esta em lock                      ##
// ###############################################################################################################

User Function MSD2460

   Local K_Margem := 0

   U_AUTOM628("PE_MSD2460")

   // #####################################################
   // Calcula as margens dos produtos do pedido de venda ##
   // #####################################################
   K_Margem := 0
   K_Margem := U_AUTOM524(3                                                ,; // 01 - Indica a chamada pelo Pedido de Venda
               IIF(Empty(Alltrim(SC5->C5_FILIAL)), cFilAnt, SC5->C5_FILIAL),; // 02 - Filial
               SC6->C6_NUM                                                 ,; // 03 - Nº do Pedido de Venda
               SC6->C6_ITEM                                                ,; // 04 - Posição do Item no Pedido de Venda
               SC6->C6_PRODUTO                                             ,; // 05 - Código do Produto
               0                                                           ,; // 06 - Posição do Produto no aAcols( Só para o cálculo do tiop 2 )
               "R")                                                           // 07 - Indica retorno de valor
Return(.T.)



// #######################################################################################

    // ##############################################################################
    // Conforme o Sr. Roger, a rotina abaixo foi substituída pela rotina AUTOM524. ##
    // Solicitação realizada em 03/01/2017.                                        ##
    // ##############################################################################

    /*
	Local aAreaAtu := GetArea()
	Local aAreaSC5 := SC5->(GetArea())
	Local aAreaSC6 := SC6->(GetArea())
	Local aAreaSD2 := SD2->(GetArea())
	Local aAreaSF2 := SF2->(GetArea())
	Local aAreaSF4 := SF4->(GetArea())
	Local aAreaSC9 := SC9->(GetArea())
	
	Local nValImp 	:= 0
	Local _nPrcVen  := 0
	Local nPpis 	:= GetMv("MV_TXPIS")   // Percentual de PIS
	Local nPcof 	:= GetMv("MV_TXCOF")   // Percentual de COFINS
	Local nPAdm 	:= GetMv("MV_CUSTADM") // Percentual de Custo Administrativo
	Local nPFre 	:= GetMv("MV_CUSTFRE") // Percentual de Frete
	Local nLimite   := GetMv("AUT_QTG002") // Delimitador de % da margem

	// Jean Rehermann - 23/01/2014 - Tarefa #8459 
	Local nPCCC := GetMv("MV_CUSTCC")  // Parâmetro que define o percentual de custo com cartão de crédito: nPCCC
	Local cCPCC := GetMv("MV_CONPGCC") // Condições de pagamento com cartão de credito
	Local cCond := Space(3)            // Condição de pagamento
	
	Local _nSumCust   := 0                 // Soma dos custos que compoe o valor de venda
	Local nCustTotFin := 0                 // Custo financeiro total de aquisicao
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

	DbSelectArea("SF4")
	DbSetOrder(1)
	DbSeek(xfilial("SF4")+SC6->C6_TES)
	
	IF SF4->F4_DUPLIC = "S" .AND. SF4->F4_ESTOQUE == "S"
		
		DbSelectArea("SC5")
		DbSetOrder(1)
		DbSeek(xfilial("SC5")+SC6->C6_NUM)
		
		cCond := SC5->C5_CONDPAG // Jean Rehermann - 23/01/2014 - Tarefa #8459
		
		dbSelectArea("SC6")

		// Abaixo pego os valores base para o custo de aquisicao e para o custo de venda

		// Custo
		nCustTotFin := Posicione( "SB2", 1, xFilial("SB2") + SC6->C6_PRODUTO + SC6->C6_LOCAL, "B2_CM1" )
		// Preco de venda
		_nPrcVen := Iif( AllTrim( SC5->C5_MOEDA ) == "1", SC6->C6_PRCVEN, xMoeda( SC6->C6_PRCVEN, SC5->C5_MOEDA, 1, dDataBase, 2 ) )

		// A partir daqui o valor base eh o custo medio, e calculados os custos de aquisicao ************************************************

		// Agrego Custo administrativo
		nCustAdm := nCustTotFin * ( nPAdm / 100 )
		nCustTotFin += nCustAdm
        
		// A partir daqui o valor base eh o preco de venda, e calculados os custos sobre a venda *********************************************
        
		// Jean Rehermann - 23/01/2014 - Tarefa #8459 - Se condição estiver no parâmetro é com cartão de crédito
		If !Empty( AllTrim( cCPCC ) )
			If cCond $ cCPCC
				nCustCC := _nPrcVen * ( nPCCC / 100 )
				_nSumCust += nCustCC // Agrego valor de custo (Cartão de Crédito)
			EndIf
        Else // Se parametro não for utilizado, verifico campo de forma de pagamento
        	If SC5->C5_FORMA == "2"
        		aAreaA := GetArea()
        		dbSelectArea("SAE")
        		dbSetOrder(1)
        		If dbSeek( xFilial("SAE") + SC5->C5_ADM )
					nCustCC := _nPrcVen * ( SAE->AE_TAXA / 100 )
					_nSumCust += nCustCC // Agrego valor de custo (Cartão de Crédito)
        		EndIf
        		RestArea( aAreaA )
        	EndIf
        EndIf
        
		// Subtraio o custo do frete
		nCustFrt := _nPrcVen * ( nPFre / 100 )
		nCustFrt := Iif( SC5->C5_TPFRETE == "C", nCustFrt, 0 )
		_nSumCust += nCustFrt // Agrego valor de custo (Frete)

		// Subtraio PIS + COFINS
		nValImp := _nPrcVen * ( ( nPpis + nPcof ) / 100 )
		_nSumCust += nValImp // Agrego valor de custo (PIS e COFINS)

		// Subtraio ICMS
		nValImp := ( SD2->D2_VALICM / SC6->C6_QTDVEN )
		_nSumCust += nValImp // Agrego valor de custo (ICMS)

		// Agrego ICMS ST
		nValImp := ( SD2->D2_ICMSRET / SC6->C6_QTDVEN )
		_nSumCust -= nValImp // Subtraio valor de custo (ICMS ST)

		// Subtraio Comissao
		nPerCom := SC6->C6_COMIS1 + SC6->C6_COMIS2 + SC6->C6_COMIS3 + SC6->C6_COMIS4 + SC6->C6_COMIS5
		nValCom := 0

		If nPerCom > 0
			nValCom := ( SC6->C6_VALOR * ( nPerCom / 100 ) ) / SC6->C6_QTDVEN
			_nSumCust += nValCom // Agrego valor de custo (% de Comissao)
		EndIf

		If !Empty( SC5->C5_CONDPAG )

			_TpCond := Posicione( "SE4", 1, xFilial("SE4") + SC5->C5_CONDPAG, "E4_TIPO" ) //Verifico o tipo da condicao de pagamento

			If _TpCond != "9" // Se for tipo 9 nao tenho como calcular

				_nValjur := 0
				_aParc := Condicao( _nPrcVen, SC5->C5_CONDPAG, , SC5->C5_EMISSAO )

				For _nX := 1 To Len( _aParc )

					_dVenc  := _aParc[ _nX, 1 ]
					_nValor := _aParc[ _nX, 2 ]
					_nDias  := DateDiffDay( SC5->C5_EMISSAO, _dVenc )
					
					_nValjur += _nValor / ( ( 1 + ( Getmv("MV_JUROS") / 100 ) ) ** ( _nDias / 30 ) )

				Next

				_nPorJur := 1 - ( _nValJur / _nPrcVen )
				_nValJur := _nPorJur * _nPrcVen
				_nSumCust += _nValJur // Agrego valor liquido presente (% de Juros)

			EndIf
		
		EndIf

		// A partir daqui comeca o calculo da margem  ***************************************************************************
		
		_nMargem := ( ( _nPrcVen - _nSumCust ) - nCustTotFin )// Subtraio do preco de venda, todo o custo referente o mesmo 
		
		_nMargem := ( _nMargem / _nPrcVen ) * 100 // % da Margem

		Reclock("SC6",.F.)
			//SC6->C6_QTGMIN := 0
			SC6->C6_QTGMRG := IIF( Abs(_nMargem) > 999, 0, Round( _nMargem, 2 ) )
 		MsUnLock()

	EndIf
	
	RestArea(aAreaSC9)
	RestArea(aAreaSF4)
	RestArea(aAreaSF2)
	RestArea(aAreaSD2)
	RestArea(aAreaSC6)
	RestArea(aAreaSC5)
	RestArea(aAreaAtu)

	//SD2->D2_QTGMIN := SC6->C6_QTGMIN
	SD2->D2_QTGMRG := Round( SC6->C6_QTGMRG, 2 )
      
    */
    
Return