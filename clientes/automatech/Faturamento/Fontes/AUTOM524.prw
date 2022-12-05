#include "rwmake.ch"

// ###############################################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                                        ##
// ------------------------------------------------------------------------------------------------------------ ##
// Referencia: AUTOM524.PRW                                                                                     ##
// Parâmetros: Nenhum                                                                                           ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                                                  ##
// ------------------------------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                                          ##
// Data......: 02/01/2017                                                                                       ##
// Objetivo..: Programa que gera o cálculo da margem.                                                           ##
//             Este pode ser chamado por três ponto (Proposta Comercial, Pedido de Venda e Nota Fiscal de Saída ##
// Parâmetros: Processo que chamou o cálculo                                                                    ##
//             1 - Tela de Liberação de Quoting                                                                 ##
//             2 - Pedido de Venda                                                                              ##
//             3 - Nota Fiscal de Saída                                                                         ##
//             Filial       -> Filial que chamou a função                                                       ## 
//             Documento    -> Nº do Documento que chamou a Função                                              ##
//             Item         -> Item do Grid de Produtos                                                         ##
//             Produto      -> Código do Produto a ser calculado                                                ##
//             Posição      -> Posição do item na aCols (Somente para o tipo de cálculo 2)                      ##
//             Tipo Retorno -> "R" -> Retorna o valor da margem                                                 ##
//                             "V" -> Retorna Stirng com valores calculados para a tela de liberação de margem  ##
// Para rodar individual    -> 3, "04", "019331", "02", "03040436640002555             ", 0, "R")               ##
// ###############################################################################################################

User Function AUTOM524(_ChamadoPor, _Filial, _Documento, _Item, _Produto, _Posicao, _TipoRetorno)

   Local aAreaAtu      := GetArea()
   Local aAreaSC5      := SC5->(GetArea())
   Local aAreaSC6      := SC6->(GetArea())
   Local aAreaSD2      := SD2->(GetArea())
   Local aAreaSF2      := SF2->(GetArea())
   Local aAreaSF4      := SF4->(GetArea())
   Local aAreaSC9      := SC9->(GetArea())
	
   // ###############################################################
   // Inicializa variáveis de trabalho para gravação na tabela ZSA ##
   // ###############################################################
   Local K_Condicao   := sPACE(03)
   Local K_Moeda      := 0
   Local k_GrpTrib    := Space(03) 
   Local k_Estado     := Space(02)
   Local K_Emissao    := Ctod("  /  /    ")
   Local K_Externo    := Space(01) 
   Local K_TPFrete    := Space(01) 
   Local K_VFrete     := 0
   Local k_Materia    := Space(30)
   Local k_QtdConsumo := 0
   Local N_CmInicial  := 0
   Local N_PIS        := 0
   Local N_COFINS     := 0
   Local N_ICMS       := 0
   Local N_CADJU      := 0
   Local N_DIFAL      := 0
   Local N_CMFinal    := 0
   Local _nPrcVen     := 0
   Local nCustAdm     := 0
   Local nPAdm        := 0   
   Local nCustCC      := 0
   Local nPCCC        := 0
   Local nCustFrt     := 0
   Local nPfre        := 0
   Local nValCom      := 0
   Local nPerCom      := 0
   Local _nValJur     := 0
   Local _nPorJur     := 0
   Local nPCustoP     := 0
   Local nCustTotFin  := 0
   Local _nPassaVal   := 0
   Local _nPassaPCT   := 0
   Local K_VlrComis   := 0

   Local nValImp       := 0
   Local _nPrcVen      := 0
   Local nPpis 	       := GetMv("MV_TXPIS")   // Percentual de PIS
   Local nPcof 	       := GetMv("MV_TXCOF")   // Percentual de COFINS
   Local nPAdm 	       := GetMv("MV_CUSTADM") // Percentual de Custo Administrativo
   Local nPFre 	       := GetMv("MV_CUSTFRE") // Percentual de Frete
   Local nLimite       := GetMv("AUT_QTG002") // Delimitador de % da margem
   Local nPCCC         := GetMv("MV_CUSTCC")  // Parâmetro que define o percentual de custo com cartão de crédito: nPCCC
   Local cCPCC         := GetMv("MV_CONPGCC") // Condições de pagamento com cartão de credito
   Local cCustCar      := GetMv("MV_CUSTCAR") // % de Custo Venda Cartão
   Local nPCustoP      := GetMv("MV_CPRODU")  // % Custo de Produção
   Local cCond         := Space(3)            // Condição de pagamento
   Local _nSumCust     := 0                   // Soma dos custos que compoe o valor de venda
   Local nCustTotFin   := 0                   // Custo financeiro total de aquisicao
   Local _nValorTot    := 0

   Local nPosTes       := 0
   Local nPosLocal     := 0
   Local nPosPrc       := 0
   Local nPosQtde      := 0
   Local nPosCm1       := 0
   Local nPosCm2       := 0
   Local nPosCm3       := 0
   Local nPosCm4       := 0
   Local nPosCm5       := 0
   Local nPosTot       := 0

   Local cString       := ""

   U_AUTOM628("AUTOM524")

   If _ChamadoPor == 2                            
      nPosTes   := aScan( aHeader, { |x| x[2] == 'C6_TES    ' } )
      nPosLocal := aScan( aHeader, { |x| x[2] == 'C6_LOCAL  ' } )
      nPosPrc   := aScan( aHeader, { |x| x[2] == 'C6_PRCVEN ' } )
      nPosQtde  := aScan( aHeader, { |x| x[2] == 'C6_QTDVEN ' } )
      nPosCm1   := aScan( aHeader, { |x| x[2] == 'C6_COMIS1 ' } )
      nPosCm2   := aScan( aHeader, { |x| x[2] == 'C6_COMIS2 ' } )
      nPosCm3   := aScan( aHeader, { |x| x[2] == 'C6_COMIS3 ' } )
      nPosCm4   := aScan( aHeader, { |x| x[2] == 'C6_COMIS4 ' } )
      nPosCm5   := aScan( aHeader, { |x| x[2] == 'C6_COMIS5 ' } )
      nPosTot   := aScan( aHeader, { |x| x[2] == 'C6_VALOR  ' } )
      nPosCInt  := aScan( aHeader, { |x| x[2] == 'C6_COMIAUT' } )
   Endif

   // #####################################################################
   // Variáveis que receberão os valores do cálculo da margem do produto ##
   // #####################################################################
   Private _QnAliqIcm  := 0
   Private _QnValIcm   := 0
   Private _QnBaseIcm  := 0
   Private _QnValIpi   := 0
   Private _QnBaseIpi  := 0
   Private _QnValMerc  := 0
   Private _QnValSol   := 0
   Private _QnValDesc  := 0
   Private _QnPrVen    := 0

   // ###################################
   // Pesquisa a Condição de Pagamento ##
   // ###################################
   Do Case

      Case _ChamadoPor == 1
           // #########################################
           // Posiciona cabeçalho do Pedido de Venda ##
           // #########################################
    	   DbSelectArea("SC5")
	       DbSetOrder(1)
	       DbSeek( _Filial + _Documento )
   	       K_Condicao := SC5->C5_CONDPAG
           K_Moeda    := SC5->C5_MOEDA
           K_TPFrete  := SC5->C5_TPFRETE
           K_Cliente  := SC5->C5_CLIENTE
           K_Loja     := SC5->C5_LOJACLI
           k_Estado   := Posicione( "SA1", 1, xFilial("SA1") + k_Cliente + K_Loja, "A1_EST"     )
           k_GrpTrib  := Posicione( "SA1", 1, xFilial("SA1") + k_Cliente + K_Loja, "A1_GRPTRIB" )
           K_Emissao  := SC5->C5_EMISSAO
           K_Forma    := SC5->C5_FORMA
           K_Adm      := SC5->C5_ADM
           K_Externo  := SC5->C5_EXTERNO
           
           // ######################################
           // Posiciona o item do Pedido de Venda ##
           // ######################################
    	   DbSelectArea("SC6")
	       DbSetOrder(1)
	       DbSeek( _Filial + _Documento + _Item + _Produto)
           k_TES      := SC6->C6_TES
           K_Local    := SC6->C6_LOCAL
           k_Unitario := SC6->C6_PRCVEN
           K_QtdVenda := SC6->C6_QTDVEN
           k_Comis1   := SC6->C6_COMIS1
           k_Comis2   := SC6->C6_COMIS2
           k_Comis3   := SC6->C6_COMIS3
           k_Comis4   := SC6->C6_COMIS4
           k_Comis5   := SC6->C6_COMIS5
           K_Valor    := SC6->C6_VALOR
           K_VlrComis := SC6->C6_COMIAUT
              
      Case _ChamadoPor == 2
           // #########################################
           // Posiciona cabeçalho do Pedido de Venda ##
           // #########################################
   	       K_Condicao := M->C5_CONDPAG
           K_Moeda    := M->C5_MOEDA
           K_TPFrete  := M->C5_TPFRETE
           K_Cliente  := M->C5_CLIENTE
           K_Loja     := M->C5_LOJACLI
           k_Estado   := Posicione( "SA1", 1, xFilial("SA1") + k_Cliente + K_Loja, "A1_EST"     )
           k_GrpTrib  := Posicione( "SA1", 1, xFilial("SA1") + k_Cliente + K_Loja, "A1_GRPTRIB" )
           K_Emissao  := M->C5_EMISSAO
           K_Forma    := M->C5_FORMA
           K_Adm      := M->C5_ADM
           K_Externo  := M->C5_EXTERNO

           // ###########################################################
           // Carrega as variáveis do produto selecionado para cálculo ##
           // ###########################################################
           k_TES      := aCols[ _Posicao, nPostES   ] 
           K_Local    := aCols[ _Posicao, nPosLocal ] 
           k_Unitario := aCols[ _Posicao, nPosPrc   ] 
           K_QtdVenda := aCols[ _Posicao, nPosQtde  ] 
           k_Comis1   := aCols[ _Posicao, nPosCm1   ] 
           k_Comis2   := aCols[ _Posicao, nPosCm2   ] 
           k_Comis3   := aCols[ _Posicao, nPosCm3   ] 
           k_Comis4   := aCols[ _Posicao, nPosCm4   ] 
           k_Comis5   := aCols[ _Posicao, nPosCm5   ] 
           K_Valor    := aCols[ _Posicao, nPosTot   ] 
           K_VlrComis := aCols[ _Posicao, nPosCInt  ] 
           
      Case _ChamadoPor == 3
           // #########################################
           // Posiciona cabeçalho do Pedido de Venda ##
           // #########################################
    	   DbSelectArea("SC5")
	       DbSetOrder(1)
	       If DbSeek( _Filial + _Documento )
   	          K_Condicao := SC5->C5_CONDPAG
              K_Moeda    := SC5->C5_MOEDA
              K_TPFrete  := SC5->C5_TPFRETE
              K_Vfrete   := SC5->C5_FRETE
              K_Cliente  := SC5->C5_CLIENTE
              K_Loja     := SC5->C5_LOJACLI
              k_Estado   := Posicione( "SA1", 1, xFilial("SA1") + k_Cliente + K_Loja, "A1_EST"     )
              k_GrpTrib  := Posicione( "SA1", 1, xFilial("SA1") + k_Cliente + K_Loja, "A1_GRPTRIB" )
              K_Emissao  := SC5->C5_EMISSAO
              K_Forma    := SC5->C5_FORMA
              K_Adm      := SC5->C5_ADM
              K_Externo  := SC5->C5_EXTERNO
           Else
              MsgAlert("Pedido de venda não localizado.")
              Return(.T.)
           Endif   
           
           // ######################################
           // Posiciona o item do Pedido de Venda ##
           // ######################################
    	   DbSelectArea("SC6")
	       DbSetOrder(1)
	       DbSeek( _Filial + _Documento + _Item + _Produto)
           k_TES      := SC6->C6_TES
           K_Local    := SC6->C6_LOCAL
           k_Unitario := SC6->C6_PRCVEN
           K_QtdVenda := SC6->C6_QTDVEN
           k_Comis1   := SC6->C6_COMIS1
           k_Comis2   := SC6->C6_COMIS2
           k_Comis3   := SC6->C6_COMIS3
           k_Comis4   := SC6->C6_COMIS4
           k_Comis5   := SC6->C6_COMIS5
           K_Valor    := SC6->C6_VALOR
           K_VlrComis := SC6->C6_COMIAUT
           
   EndCase
   
   N_CmInicial := 0
   N_PIS       := 0
   N_COFINS    := 0
   N_ICMS      := 0
   N_CADJU     := 0
   N_DIFAL     := 0
   N_CMFinal   := 0  
   N_IMPOSTOS  := 0
   
   k_Materia    := Space(30)
   k_QtdConsumo := 0         
                  
   // ##########################################################
   // Posiciona o cadastro de TES - Tipo de Entradas e Saídas ##
   // ##########################################################
   DbSelectArea("SF4")
   DbSetOrder(1)
   DbSeek(xfilial("SF4") + k_TES)
	
   IF SF4->F4_DUPLIC = "S" .AND. SF4->F4_ESTOQUE == "S"
		
      // ################################################################################
      // Abaixo pego os valores base para o custo de aquisicao e para o custo de venda ##
	  // ################################################################################

      // ##########################################
	  // Captura o custo inicial pela tabela ZTP ##
	  // ##########################################
      If Select("T_SALEMACHINE") > 0
         T_SALEMACHINE->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZTP_FILIAL,"
      cSql += "       ZTP_EMPR  ,"
	  cSql += "       ZTP_PROD  ,"
	  cSql += "       ZTP_ESTA  ,"
      cSql += "       ZTP_CM01  ,"
	  cSql += "       ZTP_PIS1  ,"
	  cSql += "       ZTP_COF1  ,"
	  cSql += "       ZTP_ICM1  ,"
	  cSql += "       ZTP_CAJ1  ,"
	  cSql += "       ZTP_DIFA1 ,"
      cSql += "       ZTP_CUS1  ,"
      cSql += "       ZTP_CM02  ,"
	  cSql += "       ZTP_PIS2  ,"
	  cSql += "       ZTP_COF2  ,"
	  cSql += "       ZTP_ICM2  ,"
	  cSql += "       ZTP_CAJ2  ,"
	  cSql += "       ZTP_DIFA2 ,"
      cSql += "       ZTP_CUS2   "
      cSql += "  FROM ZTP010 (Nolock)"
      cSql += " WHERE ZTP_EMPR   = '" + Alltrim(cEmpAnt)  + "'"
      cSql += "   AND ZTP_FILIAL = '" + Alltrim(cFilAnt)  + "'"
      cSql += "   AND ZTP_PROD   = '" + Alltrim(_Produto) + "'"
      cSql += "   AND ZTP_ESTA   = '" + Alltrim(k_Estado) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SALEMACHINE", .T., .T. )

      If T_SALEMACHINE->( EOF() )
         Return(0)
      Else
         If k_GrpTrib == "002"

       	    nCustTotFin := T_SALEMACHINE->ZTP_CUS1
            
            N_CmInicial := T_SALEMACHINE->ZTP_CM01
            N_PIS       := T_SALEMACHINE->ZTP_PIS1
	        N_COFINS    := T_SALEMACHINE->ZTP_COF1
            N_ICMS      := T_SALEMACHINE->ZTP_ICM1
	        N_CADJU     := T_SALEMACHINE->ZTP_CAJ1
	        N_DIFAL     := T_SALEMACHINE->ZTP_DIFA1
            N_CMFinal   := T_SALEMACHINE->ZTP_CUS1

            cString := cString + Str(T_SALEMACHINE->ZTP_CM01,10,02)  + "|" + ;
                                 Str(T_SALEMACHINE->ZTP_PIS1,06,02)  + "|" + ;
	                             Str(T_SALEMACHINE->ZTP_COF1,06,02)  + "|" + ;
                         	     Str(T_SALEMACHINE->ZTP_ICM1,06,02)  + "|" + ;
	                             Str(T_SALEMACHINE->ZTP_CAJ1,10,02)  + "|" + ;
	                             Str(T_SALEMACHINE->ZTP_DIFA1,10,02) + "|" + ;
                                 Str(T_SALEMACHINE->ZTP_CUS1,10,02)  + "|"

       	 Else   

       	    nCustTotFin := T_SALEMACHINE->ZTP_CUS2

            N_CmInicial := T_SALEMACHINE->ZTP_CM02
            N_PIS       := T_SALEMACHINE->ZTP_PIS2
	        N_COFINS    := T_SALEMACHINE->ZTP_COF2
            N_ICMS      := T_SALEMACHINE->ZTP_ICM2
	        N_CADJU     := T_SALEMACHINE->ZTP_CAJ2
	        N_DIFAL     := T_SALEMACHINE->ZTP_DIFA2
            N_CMFinal   := T_SALEMACHINE->ZTP_CUS2

            cString := cString + Str(T_SALEMACHINE->ZTP_CM02,10,02)  + "|" + ;
                                 Str(T_SALEMACHINE->ZTP_PIS2,06,02)  + "|" + ;
	                             Str(T_SALEMACHINE->ZTP_COF2,06,02)  + "|" + ;
                         	     Str(T_SALEMACHINE->ZTP_ICM2,06,02)  + "|" + ;
	                             Str(T_SALEMACHINE->ZTP_CAJ2,10,02)  + "|" + ;
	                             Str(T_SALEMACHINE->ZTP_DIFA2,10,02) + "|" + ;
                                 Str(T_SALEMACHINE->ZTP_CUS2,10,02)  + "|"

       	 Endif

      Endif // T_SALEMACHINE->( EOF() )	           	    

      // ################# 
 	  // Preco de venda ##
 	  // #################
	  _nPrcVen := Iif( AllTrim( K_Moeda ) == "1", k_Unitario, xMoeda( k_Unitario, K_Moeda, 1, dDataBase, 2 ) )

      cString := cString + Str(_nPrcVen,10,02) + "|"

      // ####################################################################################
	  // A partir daqui o valor base eh o custo medio, e calculados os custos de aquisicao ##
	  // ####################################################################################

  	  // ##############################
  	  // Agrego Custo administrativo ##
  	  // ##############################
 	  nCustAdm := nCustTotFin * ( nPAdm / 100 )
	  nCustTotFin += nCustAdm
        
      cString := cString + Str(nCustAdm,10,02) + "|"
      cString := cString + Str(nPAdm,06,02)    + "|"

	  // ###########################################################
	  // Se condição estiver no parâmetro é com cartão de crédito ##
	  // ###########################################################
	  If !Empty( AllTrim( cCPCC ) )

		 If K_Condicao $ cCPCC

			nCustCC := _nPrcVen * ( nPCCC / 100 )
			_nSumCust += nCustCC // Agrego valor de custo (Cartão de Crédito)

            cString := cString + Str(nCustCC,10,02) + "|"
            cString := cString + Str(nPCCC,06,02)   + "|"

		 Else
		 
            nCustCC := 0
            nPCCC   := 0

            cString := cString + Str(0,10,02) + "|"
            cString := cString + Str(0,06,02)   + "|"
		 
		 EndIf

      Else // Se parametro não for utilizado, verifico campo de forma de pagamento

       	 If K_Forma == "2"

 		    nCustCC := _nPrcVen * ( cCustCar / 100 )
			_nSumCust += nCustCC // Agrego valor de custo (Cartão de Crédito)

            nCustCC := nCustCC
            nPCCC   := cCustCar

            cString := cString + Str(nCustCC,10,02)  + "|"
            cString := cString + Str(cCustCar,06,02) + "|"

         Else

            nCustCC := 0
            nPCCC   := 0

            cString := cString + Str(0,10,02) + "|"
            cString := cString + Str(0,06,02)   + "|"
         
         EndIf

      EndIf // !Empty( AllTrim( cCPCC ) )
      
      // ###########################
  	  // Subtrai o custo do frete ##
  	  // ###########################
      If K_TPFRETE == "F"

         nCustFrt := 0
         nPFre    := 0

         cString := cString + Str(0,10,02) + "|"
         cString := cString + Str(0,06,02) + "|"

      Else  

         nCustFrt := _nPrcVen * ( nPFre / 100 )                 

         cString := cString + Str(nCustFrt,10,02) + "|"
         cString := cString + Str(nPFre,06,02)    + "|"

      Endif   

	  _nSumCust += nCustFrt // Agrego valor de custo (Frete)

      // ##################################################################
      // Cálculo realizado antes do SalesMachine                         ##
      //    // #########################                                 ##
      //    // Subtrai o PIS + COFINS ##                                 ##
      //    // #########################                                 ##
      //    nValImp := _nPrcVen * ( ( nPpis + nPcof ) / 100 )            ##
      //    _nSumCust += nValImp // Agrego valor de custo (PIS e COFINS) ##
      //                                                                 ##
      //    // #################                                         ##
      //    // Subtrai o ICMS ##                                         ##
      //    // #################                                         ##
      //    nValImp := ( SD2->D2_VALICM / K_QtdVenda )                   ##
      //    _nSumCust += nValImp // Agrego valor de custo (ICMS)         ##
      //                                                                 ##
      //    // ###################                                       ##
      //    // Agrego o ICMS ST ##                                       ##
      //    // ###################                                       ##
      //    nValImp := ( SD2->D2_ICMSRET / SC6->C6_QTDVEN )              ##
      //    _nSumCust -= nValImp // Subtraio valor de custo (ICMS ST)    ##
      // ##################################################################
      
      // #####################
	  // Subtrai a Comissao ##
	  // #####################
	  nPerCom := K_Comis1 + K_Comis2 + K_Comis3 + K_Comis4 + K_Comis5
	  nValCom := 0

 	  If nPerCom > 0
	  
	   	 nValCom := ( K_Valor * ( nPerCom / 100 ) ) / K_QtdVenda
		 _nSumCust += nValCom // Agrego valor de custo (% de Comissao)

         cString := cString + Str(nValCom,10,02) + "|"
         cString := cString + Str(nPerCom,06,02) + "|"
   
	  Else

         nValCom := 0
         nPerCom := 0

         cString := cString + Str(0,10,02) + "|"
         cString := cString + Str(0,06,02) + "|"

      EndIf
      
      // ################################
      // Trata a Condição de Pagamento ##
      // ################################
	  If !Empty( K_Condicao )

         // ###########################################
         // Pesquisa o tipo de condição de pagamento ##
         // ###########################################
		 _TpCond := Posicione( "SE4", 1, xFilial("SE4") + K_Condicao, "E4_TIPO" ) 

		 If _TpCond != "9" // Se for tipo 9 nao tenho como calcular

			_nValjur := 0
			_aParc := Condicao( _nPrcVen, K_Condicao, , K_Emissao )

			For _nX := 1 To Len( _aParc )
				_dVenc  := _aParc[ _nX, 1 ]
				_nValor := _aParc[ _nX, 2 ]
				_nDias  := DateDiffDay( K_Emissao, _dVenc )
				_nValjur += _nValor / ( ( 1 + ( Getmv("MV_JUROS") / 100 ) ) ** ( _nDias / 30 ) )
			Next _nX

			_nPorJur := 1 - ( _nValJur / _nPrcVen )
			_nValJur := _nPorJur * _nPrcVen
			_nSumCust += _nValJur // Agrego valor liquido presente (% de Juros)

            cString := cString + Str(_nValJur,10,02) + "|"
            cString := cString + Str((_nPorJur * 100),06,02) + "|"

		 Else
		 
            _nValJur := 0
            _nPorJur := 0

            cString := cString + Str(0,10,02) + "|"
            cString := cString + Str(0,06,02) + "|"
		 
		 EndIf
		
 	  Else // !Empty( K_Condicao )
 	  
         _nValJur := 0
         _nPorJur := 0

         cString := cString + Str(0,10,02) + "|"
         cString := cString + Str(0,06,02) + "|"

 	  EndIf // !Empty( K_Condicao )

      // ##############################
      // Calcula a Margem do Produto ##
      // ##############################
      If Len(Alltrim(_Produto)) == 17

         k_Materia    := Space(30)
         k_QtdConsumo := 0

         // #######################################
         // Pesquisa a matéria-prima da etiqueta ##
         // #######################################
         If (Select( "T_MATERIAPRIMA" ) != 0 )
            T_MATERIAPRIMA->( DbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT G1_COD ,"
         cSql += "       G1_COMP,"
		 cSql += "       G1_QUANT"
         cSql += "  FROM " + RetSqlName("SG1") 
	     cSql += " WHERE G1_COD     = '" + Alltrim(_Produto) + "'"
         cSql += "   AND D_E_L_E_T_ = ''"   

         cSql := ChangeQuery( cSql )
         dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_MATERIAPRIMA",.T.,.T.)

         If Substr(_Produto,01,02) == "02"
   
            k_Materia    := T_MATERIAPRIMA->G1_COMP
            k_QtdConsumo := (T_MATERIAPRIMA->G1_QUANT * 1.05)         
            
         Else

            k_Materia    := T_MATERIAPRIMA->G1_COMP
            k_Consumo    := T_MATERIAPRIMA->G1_QUANT
            k_EtqRolo    := U_CALCMETR(_Produto)

            If k_EtqRolo[2] == 1
               k_Resultado  := (k_Consumo * k_EtqRolo[2])  &&& * K_QtdVenda
            Else
//               k_Resultado  := ((k_Consumo * k_EtqRolo[2]) * K_QtdVenda) / 1000
               k_Resultado  := (k_Consumo * k_EtqRolo[2]) / 1000
            Endif

            If (k_Resultado * K_QtdVenda) < 50
 
               cDesc       := Alltrim(Posicione('SB1', 1, xFilial('SB1') + _Produto,'B1_DESC'))
               nPos        := AT("/",cDesc)
               nMult       := Val(Substr(cDesc,nPos + 1,3))
               k_Adicional := (50 / nMult) && * K_QtdVenda

               k_Resultado := k_Resultado + k_Adicional

            Else   

               k_Resultado := k_Resultado + ((k_Resultado * 10)/100)
               
            Endif

            k_QtdConsumo := k_Resultado
            
         Endif //Substr(_Produto,01,02) == "02"

         // ###############################################################
         // Captura o custo inicial pela tabela ZTP para a matéria-prima ##
         // ###############################################################
         If Select("T_SALEMACHINE") > 0
            T_SALEMACHINE->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT ZTP_FILIAL,"
         cSql += "       ZTP_EMPR  ,"
    	 cSql += "       ZTP_PROD  ,"
    	 cSql += "       ZTP_ESTA  ,"
         cSql += "       ZTP_CM01  ,"
    	 cSql += "       ZTP_PIS1  ,"
 	     cSql += "       ZTP_COF1  ,"
 	     cSql += "       ZTP_ICM1  ,"
 	     cSql += "       ZTP_CAJ1  ,"
 	     cSql += "       ZTP_DIFA1 ,"
         cSql += "       ZTP_CUS1  ,"
         cSql += "       ZTP_CM02  ,"
	     cSql += "       ZTP_PIS2  ,"
	     cSql += "       ZTP_COF2  ,"
	     cSql += "       ZTP_ICM2  ,"
	     cSql += "       ZTP_CAJ2  ,"
	     cSql += "       ZTP_DIFA2 ,"
         cSql += "       ZTP_CUS2   "
         cSql += "  FROM ZTP010 (Nolock)"
         cSql += " WHERE ZTP_EMPR   = '" + Alltrim(cEmpAnt)   + "'"
         cSql += "   AND ZTP_FILIAL = '" + Alltrim(cFilAnt)   + "'"
         cSql += "   AND ZTP_PROD   = '" + Alltrim(k_Materia) + "'"
         cSql += "   AND ZTP_ESTA   = '" + Alltrim(k_Estado)  + "'"
         cSql += "   AND D_E_L_E_T_ = ''"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SALEMACHINE", .T., .T. )

         If T_SALEMACHINE->( EOF() )
            nCustTotFin := 0
            N_CmInicial := 0
            N_PIS       := 0
	        N_COFINS    := 0
            N_ICMS      := 0
	        N_CADJU     := 0
	        N_DIFAL     := 0
            N_CMFinal   := 0
         Else
            If k_GrpTrib == "002"

         	   nCustTotFin := (T_SALEMACHINE->ZTP_CM01 * k_QtdConsumo)

               N_CmInicial := T_SALEMACHINE->ZTP_CM01
               N_PIS       := T_SALEMACHINE->ZTP_PIS1
	           N_COFINS    := T_SALEMACHINE->ZTP_COF1
               N_ICMS      := T_SALEMACHINE->ZTP_ICM1
	           N_CADJU     := T_SALEMACHINE->ZTP_CAJ1
	           N_DIFAL     := T_SALEMACHINE->ZTP_DIFA1
               N_CMFinal   := T_SALEMACHINE->ZTP_CUS1
               N_IMPOSTOS  := (_nPrcVen * (N_ICMS /100)) + (_nPrcVen * (N_PIS /100)) + (_nPrcVen * (N_COFINS /100))

               cString := cString + Str(T_SALEMACHINE->ZTP_CM01,10,02)  + "|" + ;
                                    Str(T_SALEMACHINE->ZTP_PIS1,06,02)  + "|" + ;
	                                Str(T_SALEMACHINE->ZTP_COF1,06,02)  + "|" + ;
                            	    Str(T_SALEMACHINE->ZTP_ICM1,06,02)  + "|" + ;
	                                Str(T_SALEMACHINE->ZTP_CAJ1,10,02)  + "|" + ;
	                                Str(T_SALEMACHINE->ZTP_DIFA1,10,02) + "|" + ;
                                    Str(T_SALEMACHINE->ZTP_CUS1,10,02)  + "|"

       	    Else   

       	       nCustTotFin := (T_SALEMACHINE->ZTP_CM02 * k_QtdConsumo)

               N_CmInicial := T_SALEMACHINE->ZTP_CM02
               N_PIS       := T_SALEMACHINE->ZTP_PIS2
	           N_COFINS    := T_SALEMACHINE->ZTP_COF2
               N_ICMS      := T_SALEMACHINE->ZTP_ICM2
	           N_CADJU     := T_SALEMACHINE->ZTP_CAJ2
	           N_DIFAL     := T_SALEMACHINE->ZTP_DIFA2
               N_CMFinal   := T_SALEMACHINE->ZTP_CUS2
               N_IMPOSTOS  := (_nPrcVen * (N_ICMS /100)) + (_nPrcVen * (N_PIS /100)) + (_nPrcVen * (N_COFINS /100))

               cString := cString + Str(T_SALEMACHINE->ZTP_CM02,10,02)  + "|" + ;
                                    Str(T_SALEMACHINE->ZTP_PIS2,06,02)  + "|" + ;
	                                Str(T_SALEMACHINE->ZTP_COF2,06,02)  + "|" + ;
                            	    Str(T_SALEMACHINE->ZTP_ICM2,06,02)  + "|" + ;
	                                Str(T_SALEMACHINE->ZTP_CAJ2,10,02)  + "|" + ;
	                                Str(T_SALEMACHINE->ZTP_DIFA2,10,02) + "|" + ;
                                    Str(T_SALEMACHINE->ZTP_CUS2,10,02)  + "|"

        	Endif

         Endif // T_SALEMACHINE->( EOF() )

         // ###################
         // Calcula a margem ##
         // ###################
     	 _nMargem := ( ( _nPrcVen - _nSumCust ) - nCustTotFin ) - (k_QtdConsumo * nPCustoP) - N_IMPOSTOS  // Subtraio do preco de venda, todo o custo referente o mesmo 
         _nPassaVAL := _nMargem
 	     _nMargem := ( _nMargem / _nPrcVen ) * 100                                                        // % da Margem
 	     _nPassaPCT := _nMargem

         If _nMargem < 0
            If (_nMargem * -1) > 999
               _nMargem   := -999.99
               _nPassaPCT := -999.99
            Endif
         Else
            If _nMargem > 999
               _nMargem   := 999.99
               _nPassaPCT := 999.99
            Endif
         Endif

         cString := cString + Str(((_nPrcVen - _nSumCust ) - nCustTotFin) - (k_QtdConsumo * nPCustoP),10,02) + "|"
         cString := cString + Str(_nMargem,06,02) + "|"

      Else //Len(Alltrim(_Produto)) == 17

         k_Materia    := Space(30)
         k_QtdConsumo := 0

  	 	 _nMargem := ( ( _nPrcVen - _nSumCust ) - nCustTotFin ) // Subtraio do preco de venda, todo o custo referente o mesmo 
         _nPassaVAL := _nMargem
   	     _nMargem := ( _nMargem / _nPrcVen ) * 100              // % da Margem
 	     _nPassaPCT := _nMargem

         If _nMargem < 0
            If (_nMargem * -1) > 999
               _nMargem := -999.99
            Endif
         Else
            If _nMargem > 999
               _nMargem := 999.99
            Endif
         Endif

         cString := cString + Str(((_nPrcVen - _nSumCust ) - nCustTotFin),10,02) + "|"
         cString := cString + Str(_nMargem,06,02) + "|"
   	     
   	  Endif //Len(Alltrim(_Produto)) == 17

      // ##################################################################
      // Atualiza a Margem do campo C6_QTGMRG em caso de chamada por = 3 ##
      // ##################################################################
 	  If _ChamadoPor == 3
   	     DbSelectArea("SC6")
	     DbSetOrder(1)
	     DbSeek( _Filial + _Documento + _Item + _Produto)

	     Reclock("SC6",.F.)
	     //SC6->C6_QTGMIN := 0
         //SC6->C6_MARGEM := IIF( Abs(_nMargem) > 999, 0, Round( _nMargem, 2 ) )
         //SC6->C6_QTGMRG := IIF( Abs(_nMargem) > 999, 0, Round( _nMargem, 2 ) )

	     SC6->C6_QTGMRG := IIF( Abs(_nPassaPCT) > 999, 0, Round( _nPassaPCT, 2 ) )

 	     MsUnLock()

 	  Endif   

   Else // SF4->F4_DUPLIC = "S" .AND. SF4->F4_ESTOQUE == "S"
   
      // ########################################################################################
      // Se pedido de venda for um pedido de intermediação, calcula a margem senão, margem = 0 ##
      // ########################################################################################
      If K_Externo == "1"

 	     _nPassaVAL := 0
         _nMargem   := (K_VlrComis / K_Valor) * 100
 	     _nPassaPCT := _nMargem
         
         cString := cString + Str(0,10,02) + "|"
         cString := cString + Str(((K_VlrComis / K_Valor) * 100),06,02) + "|"

      Else
         
 	     _nPassaVAL := 0
         _nMargem   := 0
 	     _nPassaPCT := 0
 	     
         cString := cString + Str(0,10,02) + "|"
         cString := cString + Str(0,06,02) + "|"
        
      Endif
   
   EndIf // SF4->F4_DUPLIC = "S" .AND. SF4->F4_ESTOQUE == "S"
	
   RestArea(aAreaSC9)
   RestArea(aAreaSF4)
   RestArea(aAreaSF2)
   RestArea(aAreaSD2)
   RestArea(aAreaSC6)
   RestArea(aAreaSC5)
   RestArea(aAreaAtu)

   // ##################################################################
   // Atualiza a Margem do campo D2_QTGMRG em caso de chamada por = 3 ##
   // ##################################################################
   If _ChamadoPor == 3

	  //SD2->D2_QTGMIN := SC6->C6_QTGMIN
      //SD2->D2_MARGEM := Round( _nMargem, 2 )
      //SD2->D2_QTGMRG := Round( _nMargem, 2 )
 	  
 	  DbSelectArea("SD2")
	  DbSetOrder(8)
	  If DbSeek( _Filial + _Documento + _Item)
	     Reclock("SD2",.F.)
   	     SD2->D2_QTGMRG := IIF( Abs(_nPassaPCT) > 999, 0, Round( _nPassaPCT, 2 ) )
 	     MsUnLock()
 	  Endif   
 	     
//      SD2->D2_QTGMRG := IIF( Abs(_nPassaPCT) > 999, 0, Round( _nPassaPCT, 2 ) )

      If N_DIFAL > 999.99
         N_DIFAL := 999.99
      Endif

      // ###############################################################################
      // Atualiza os valores da tabelA ZSA. Somente no faturamento do pedido de venda ##
      // ###############################################################################
   	  dbSelectArea("ZSA")
	  dbSetOrder(1)
      RecLock("ZSA",.T.)
      ZSA->ZSA_EMPR   := cEmpAnt 
      ZSA->ZSA_FILIAL := cFilAnt
      ZSA->ZSA_PVEN   := SD2->D2_PEDIDO
      ZSA->ZSA_NOTA   := SD2->D2_DOC
      ZSA->ZSA_SERI   := SD2->D2_SERIE
      ZSA->ZSA_CLIE   := SD2->D2_CLIENTE
      ZSA->ZSA_LOJA   := SD2->D2_LOJA
      ZSA->ZSA_TES    := SD2->D2_TES
      ZSA->ZSA_COND   := K_Condicao
      ZSA->ZSA_MOED   := K_Moeda
      ZSA->ZSA_GTRI   := k_GrpTrib
      ZSA->ZSA_ESTA   := k_Estado
      ZSA->ZSA_EMPV   := K_Emissao
      ZSA->ZSA_EMNF   := SD2->D2_EMISSAO         
      ZSA->ZSA_EXTE   := IIF(K_Externo == "1", "S", "N")
      ZSA->ZSA_TPFR   := K_TPFrete
      ZSA->ZSA_VFRE   := K_VFrete
      ZSA->ZSA_PROD   := SD2->D2_COD
      ZSA->ZSA_ITEM   := SD2->D2_ITEMPV
      ZSA->ZSA_DESC   := Posicione( "SB1", 1, xFilial("SB1") + SD2->D2_COD, "B1_DESC")
      ZSA->ZSA_PRIM   := k_Materia
      ZSA->ZSA_CONS   := k_QtdConsumo
      ZSA->ZSA_CMIN   := N_CmInicial
      ZSA->ZSA_PIS    := N_PIS
      ZSA->ZSA_COFI   := N_COFINS
      ZSA->ZSA_ICMS   := N_ICMS
      ZSA->ZSA_CADJ   := N_CADJU
      ZSA->ZSA_DIFA   := Round(N_DIFAL,02)
      ZSA->ZSA_CMTO   := N_CMFinal
      ZSA->ZSA_UNIT   := _nPrcVen
      ZSA->ZSA_CADM   := nCustAdm
      ZSA->ZSA_PADM   := nPAdm         
      ZSA->ZSA_CCON   := nCustCC
      ZSA->ZSA_PCON   := nPCCC
      ZSA->ZSA_CFRE   := nCustFrt
      ZSA->ZSA_PFRE   := nPfre
      ZSA->ZSA_CCOM   := nValCom
      ZSA->ZSA_PCOM   := nPerCom
      ZSA->ZSA_CJUR   := _nValJur
      ZSA->ZSA_PJUR   := _nPorJur
      ZSA->ZSA_CPRO   := nPCustoP
      ZSA->ZSA_CTFI   := nCustTotFin
      ZSA->ZSA_MARG   := _nPassaVal
      ZSA->ZSA_PMAR   := IIF( Abs(_nPassaPCT) > 999, 0, Round( _nPassaPCT, 2 ) )
      ZSA->ZSA_ITNF   := SD2->D2_ITEM
      ZSA->ZSA_CPEX   := K_VlrComis
      MsUnLock()              

   Endif

   // ########################################################
   // Retorna valor conforme parâmetro informado de retorno ##
   // "R" -> Retorna Valor                                  ##
   // "V" -> Retorna String                                 ##
   // ########################################################
   If _TipoRetorno == "R"
      Return(_nMargem)   
   Else
      Return(cString)         
   Endif
   	  
Return(_nMargem)