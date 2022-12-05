#INCLUDE "PROTHEUS.CH"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: M440STTS.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data Ini..: 31/08/2011 por Jean Rehermann - Solutio                             ##
// Data......: 31/01/2017                                                          ##
// Objetivo..: Ponto de entrada M440STTS - Liberação manual de pedido de venda     ##
//             Verifico se existe registro de liberação e o código do mesmo para   ##
//             estoque e crédito.                                                  ##   
// ##################################################################################

User Function M440STTS()

   Local _aArea    := GetArea()
   Local _aAreaSC9 := SC9->( GetArea() )
   Local _cRisco   := IIF(SA1->A1_COD+SA1->A1_LOJA == SC5->C5_CLIENTE+SC5->C5_LOJACLI,  SA1->A1_RISCO,  Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_RISCO")   )

   Private _lTipoN   := SC5->C5_TIPO == "N" // Jean Rehermann - Solutio IT - 23/11/15 - Verificar se tipo do pedido é venda     ·

   U_AUTOM628("PE_M440STTS")

   // #####################################################################################################################################################
   // IMPORTANTE : Cesar 19.08.2015 - Quando o sistema entra neste ponto de entrada as tabelas SC6 e SC9 estão desposicionadas (primeiro item do proximo ##
   // pedido de venda) somente o SC5 continua posicionado.                                                                                               ##
   // #####################################################################################################################################################
   dbSelectArea("SC9")
   dbSetOrder(1)
   If dbSeek( xFilial("SC9") + SC5->C5_NUM )
	
      Do While !SC9->( Eof() ) .And. SC9->C9_PEDIDO == SC5->C5_NUM .And. SC9->C9_FILIAL = xFilial("SC9")
		
		 If AllTrim(SC9->C9_NFISCAL) == "" .And. SC9->C9_BLEST != '10' .And. SC9->C9_BLCRED != '10' // Jean Rehermann - 31/07/2012 | Incluida a validacao
			
			dbSelectArea("SC6")
			dbSetOrder(1)
			If dbSeek( SC9->C9_FILIAL + SC9->C9_PEDIDO + SC9->C9_ITEM )

	           _lGeraDup := Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_DUPLIC") == "S"
	            
			   IF _cRisco <> "A" .and. empty(SC9->C9_BLCRED) .and. _lGeraDup .And. _lTipoN
                                                                                          
			  	  // ###########################################################################
			  	  // VAlidacao de protecao.Nao deixa passar pedidos com RISCO do cliente <> A ##
				  // Clientes com RISCO <> A, mas liberados de credito                        ##
				  // Bloqueia o credito                                                       ##
				  // ###########################################################################

// Nova analise de crédito
//-#	       	      Reclock("SC9",.f.)
//-#				  C9_BLCRED := "06"
//-#				  MsUnlock()

	       	      Reclock("SC9",.f.)
				  C9_BLCRED := "06"
				  MsUnlock()


				  U_GravaSts( "PE_M440STTS(BlqCrd)" )
			   
       	       ElseIF (LEFT(SC6->C6_PRODUTO,2) == "02" .Or. LEFT(SC6->C6_PRODUTO,2) == "03") .And. Empty(SC6->C6_NUMOP)                                                   && .And. empty(SC9->C9_BLCRED)



			      // #################################################################################################################
			      // Analiso aqui a situação para tratar problemas de liberação de credito, sem o cliente estar como A1_RISCO # 'A' ##
				  // e a geração automatica da OP, quando o A1_RISCO = 'A' e o item do pv estiver liberado de credito               ##
				  // #################################################################################################################

                  // #############################################################################################################################
                  // A Geração de OP foi retirada deste ponto de entrada e inserida no ponto de entrada da liberação de estoque em razão do PCP ##
                  // #############################################################################################################################
                  // U_GeraOP()
                  // U_GravaSts( "PE_M440STTS(OP)" )

                  // #########################################################################################################################
                  // Tarefa #4592. Quando o Cliente for Risco = A, deve estar com o Status do Pedido = 04 - Agaurdando Liberação de Estoque ##
                  // #########################################################################################################################
                  If _cRisco == "A"
                     
                     // ###############################################################################
                     // Atualiza a tabela SC9 bloqueando o pedido em Aguardando liberação de estoque ##
                     // ###############################################################################

                     // ###################################################################
                     // No dia 05/02/2018, o Juan pediu para limpar o BLCRED neste ponto ##
                     // ###################################################################

// Nova analise de crédito
//-#     				 Reclock("SC9",.f.)
//-#			         //SC9->C9_BLCRED := "03"
//-#				     SC9->C9_BLCRED := "  "
//-#				     MsUnlock()

     				 Reclock("SC9",.f.)
			         SC9->C9_BLCRED := "03"
				     SC9->C9_BLCRED := "  "
				     MsUnlock()

                     // #################################################################
                     // Altera o status do pedido para aguardando liberação de estoque ##
                     // Caso o pedido de venda é um pedido de contrato, o  status será ##
                     // direcionado para Aguardando Análise de Crédito.                ##
                     // #################################################################
                     If Empty(Alltrim(SC5->C5_MDCONTR))

                        If SC6->C6_TES == "717"

                           // ###################################################################
                           // Atualiza a tabela SC9 enviando o produto para análise de crédito ##
                           // ###################################################################
    	    			   Reclock("SC9",.f.)

// Nova análise de crédito
//-#			 	           SC9->C9_BLCRED := "03"   // Era 01 - Tarefa #3729

			 	           SC9->C9_BLCRED := "03"   // Era 01 - Tarefa #3729


                           If Posicione("SF4",1,xFilial("SF4") + SC6->C6_TES, "F4_ESTOQUE") == "S"
				              SC9->C9_BLEST  := "03"                                                                                         
				           Else   
				              SC9->C9_BLEST  := "  "                                                                                         
                           Endif
				           
				           MsUnlock()
                           // U_GravaSts( "PE_M440STTS(BlqCrd)" )

                           // ##############################################################################
                           // Atualiza o Status do Pedido de Venda com 03 = Aguardando Análise de Crédito ##
                           // ##############################################################################
          		           RecLock( "SC6", .F. )
    		               SC6->C6_STATUS := "03"
               		       MsUnlock()

    		               // ########################################################
    		               // Atualiza o log de atualização de status na tabela ZZ0 ##
    		               // ########################################################
		                   U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "03", "PE_M440STTS", 0 )
		                   
		                Else

       	    	           RecLock( "SC6", .F. )
    		               SC6->C6_STATUS := "04"
               	           MsUnlock()

     		               // ########################################################
    		               // Atualiza o log de atualização de status na tabela ZZ0 ##
    		               // ########################################################
		                   U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "04", "PE_M440STTS", 0 )

				           //U_GravaSts( "PE_M440STTS(BlqCrd)" )
				           
				        Endif   

				     Else
				        
     	    	        RecLock( "SC6", .F. )
    		            SC6->C6_STATUS := "03"
             	        MsUnlock()

     		            // ########################################################
    		            // Atualiza o log de atualização de status na tabela ZZ0 ##
    		            // ########################################################
		                U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "03", "PE_M440STTS", 0 )
		                
		             Endif   
				     
				  Else

       		         RecLock( "SC6", .F. )
    		         SC6->C6_STATUS := "03" 
               		 MsUnlock()           

     		         // ########################################################
    		         // Atualiza o log de atualização de status na tabela ZZ0 ##
    		         // ########################################################
		             U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "03", "PE_M440STTS", 0 )

                  Endif

//                  // #################################################################
//                  // Altera o status do pedido para aguardando liberação de estoque ##
//                  // #################################################################
//       		      RecLock( "SC6", .F. )
//    		      SC6->C6_STATUS := "04"
//               	  MsUnlock()
               		       
//     		      // ########################################################
//    		      // Atualiza o log de atualização de status na tabela ZZ0 ##
//    		      // ########################################################
//		          U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "04", "PE_M440STTS", 0 )
  
                  // ##############################
                  // Atualiza o campo C5_LIBEROK ##
                  // ############################## 
    		      dbSelectArea("SC5")
 		          dbSetOrder(1)
 		          DbSeek( xfilial("SC5") + SC6->C6_NUM )
 		          Reclock("SC5",.F.)
 		          SC5->C5_LIBEROK := IIF(Empty(Alltrim(SC5->C5_LIBEROK)), "S", SC5->C5_LIBEROK)
		          Msunlock()

       	       ElseIF (LEFT(SC6->C6_PRODUTO,2) == "02" .Or. LEFT(SC6->C6_PRODUTO,2) == "03") .And. !Empty(SC6->C6_NUMOP) 


			      // #################################################################################################################
			      // Analiso aqui a situação para tratar problemas de liberação de credito, sem o cliente estar como A1_RISCO # 'A' ##
				  // e a geração automatica da OP, quando o A1_RISCO = 'A' e o item do pv estiver liberado de credito               ##
				  // #################################################################################################################

                  // #############################################################################################################################
                  // A Geração de OP foi retirada deste ponto de entrada e inserida no ponto de entrada da liberação de estoque em razão do PCP ##
                  // #############################################################################################################################
                  // U_GeraOP()
                  // U_GravaSts( "PE_M440STTS(OP)" )

                  // #########################################################################################################################
                  // Tarefa #4592. Quando o Cliente for Risco = A, deve estar com o Status do Pedido = 04 - Agaurdando Liberação de Estoque ##
                  // #########################################################################################################################
                  If _cRisco == "A"
                     
                     // ###############################################################################
                     // Atualiza a tabela SC9 bloqueando o pedido em Aguardando liberação de estoque ##
                     // ###############################################################################
    				 Reclock("SC9",.f.)

// Nova análise de crédito
// 03
//-#				     SC9->C9_BLCRED := "  "

// 03
				     SC9->C9_BLCRED := "  "


				     MsUnlock()

				     U_GravaSts( "PE_M440STTS(BlqCrd)" )

				  Else
				  
       		         RecLock( "SC6", .F. )
// 03

    		         SC6->C6_STATUS := "04" 
               		 MsUnlock()           

    				 Reclock("SC9",.f.)
				     SC9->C9_BLEST := "03"
				     MsUnlock()

				     U_GravaSts( "PE_M440STTS(BlqCrd)" )

				  
				  Endif   
                  
                  // ################################################################################
                  // Atualiza o Status do Pedido de Venda com 04 = Aguardando Liberação de Estoque ##
                  // ################################################################################
                  If !Empty(Alltrim(SC6->C6_NUMOP))

                     If Select("T_PRODUCAO") > 0
                        T_PRODUCAO->( dbCloseArea() )
                     EndIf

                     cSql := ""
                     cSql := "SELECT SC6.C6_FILIAL ,"
                     cSql += "       SC6.C6_NUM    ,"
 	                 cSql += "       SC6.C6_ITEM   ,"
                     cSql += "       SC6.C6_PRODUTO,"
                     cSql += "       SC6.C6_NUMOP  ,"
       	             cSql += "       SC6.C6_ITEMOP ,"
                     cSql += "       SC2.C2_QUANT  ,"         
                     cSql += "       SC2.C2_QUJE   ,"
                     cSql += "      (SC2.C2_QUJE + SC2.C2_PERDA) AS PRODUZIDO, "
                     cSql += "       SC6.C6_ENTREG  "
                     cSql += "  FROM " + RetSqlName("SC6") + " SC6, "
                     cSql += "       " + RetSqlName("SC2") + " SC2  "
                     cSql += " WHERE SC6.C6_FILIAL  = '" + Alltrim(SC6->C6_FILIAL)  + "'"
                     cSql += "   AND SC6.C6_NUM     = '" + Alltrim(SC6->C6_NUM)     + "'"
                     cSql += "   AND SC6.C6_ITEM    = '" + Alltrim(SC6->C6_ITEM)    + "'"
                     cSql += "   AND SC6.C6_PRODUTO = '" + Alltrim(SC6->C6_PRODUTO) + "'"
                     cSql += "   AND SC6.D_E_L_E_T_ = ''            "
                     cSql += "   AND SC2.C2_FILIAL  = SC6.C6_FILIAL "
                     cSql += "   AND SC2.C2_NUM     = SC6.C6_NUMOP  "
                     cSql += "   AND SC2.C2_ITEM    = SC6.C6_ITEMOP "
                     cSql += "   AND SC2.C2_PRODUTO = SC6.C6_PRODUTO"
                     cSql += "   AND SC2.D_E_L_E_T_ = ''            "

                     cSql := ChangeQuery( cSql )
                     dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUCAO", .T., .T. )
                                                                                                          
                     If T_PRODUCAO->C2_QUANT == T_PRODUCAO->PRODUZIDO
                           
                        If T_PRODUCAO->C6_ENTREG > Dtos(DATE())

           		           RecLock( "SC6", .F. )
    		               SC6->C6_STATUS := "05" 
               		       MsUnlock()           

       		               // ########################################################
    		               // Atualiza o log de atualização de status na tabela ZZ0 ##
    		               // ########################################################
		                   U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "05", "PE_M440STTS", 0 )

               		    Else

           		           RecLock( "SC6", .F. )
    		               SC6->C6_STATUS := "08" 
               		       MsUnlock()           

       		               // ########################################################
    		               // Atualiza o log de atualização de status na tabela ZZ0 ##
    		               // ########################################################
		                   U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "08", "PE_M440STTS", 0 )

               		    Endif

               		 Else

          		        RecLock( "SC6", .F. )

//                      If (cEmpAnt == "01" .And. SC9->C9_FILIAL == "04") .Or. ;
//                         (cEmpAnt == "01" .And. SC9->C9_FILIAL == "07") .Or. ;
//                         (cEmpAnt == "03" .And. SC9->C9_FILIAL == "01")

            	        IF (LEFT(SC6->C6_PRODUTO,2) == "02" .Or. LEFT(SC6->C6_PRODUTO,2) == "03")
// 07
         		           SC6->C6_STATUS := "04"
         		        Else   
    		               SC6->C6_STATUS := "03"
               		       MsUnlock()

       				       Reclock("SC9",.f.)
				           SC9->C9_BLEST := ""
				           MsUnlock()
                           //U_GravaSts( "PE_M440STTS(BlqCrd)" )
               		       
     		               // ########################################################
    		               // Atualiza o log de atualização de status na tabela ZZ0 ##
    		               // ########################################################
		                   U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "03", "PE_M440STTS", 0 )

               		    Endif   


               	     Endif   

                  Endif

   		          dbSelectArea("SC5")
		          dbSetOrder(1)
		          DbSeek( xfilial("SC5") + SC6->C6_NUM )
		          Reclock("SC5",.F.)
		          SC5->C5_LIBEROK := IIF(Empty(Alltrim(SC5->C5_LIBEROK)), "S", SC5->C5_LIBEROK)
		          Msunlock()

			   Else

           	      IF (LEFT(SC6->C6_PRODUTO,2) == "02" .Or. LEFT(SC6->C6_PRODUTO,2) == "03") .And. _cRisco  == "A"

                     // #################################################################################
                     // # 4416 - Ped. de contrato ATECH não deve cai em Ag. data de entrega            ##
                     //          Produtos com TES = 717, enviar produto direto para análise de crédito ##
                     // #################################################################################
                     If SC6->C6_TES == "717"
                     
                        // ###################################################################
                        // Atualiza a tabela SC9 enviando o produto para análise de crédito ##
                        // ###################################################################
    	    			Reclock("SC9",.f.)


// Nova análise de crédito
//-#			 	        SC9->C9_BLCRED := "03"   // Era 01 - Tarefa #3729


			 	        SC9->C9_BLCRED := "03"   // Era 01 - Tarefa #3729


                        If Posicione("SF4",1,xFilial("SF4") + SC6->C6_TES, "F4_ESTOQUE") == "S"
  		                   SC9->C9_BLEST  := "03"                                                                                         
				        Else   
				           SC9->C9_BLEST  := "  "                                                                                         
                        Endif

				        MsUnlock()

                        // U_GravaSts( "PE_M440STTS(BlqCrd)" )

                        // ##############################################################################
                        // Atualiza o Status do Pedido de Venda com 03 = Aguardando Análise de Crédito ##
                        // ##############################################################################
          		        RecLock( "SC6", .F. )
    		            SC6->C6_STATUS := "03"
               		    MsUnlock()

    		            // ########################################################
    		            // Atualiza o log de atualização de status na tabela ZZ0 ##
    		            // ########################################################
		                U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "03", "PE_M440STTS", 0 )

		             Else   

                        // ###############################################################################
                        // Atualiza a tabela SC9 bloqueando o pedido em Aguardando liberação de estoque ##
                        // ###############################################################################
    				    Reclock("SC9",.f.)

// Nova analise de crédito
//-#				        SC9->C9_BLCRED := ""

				        SC9->C9_BLCRED := ""

				        SC9->C9_BLEST  := "03"
				        MsUnlock()
                        //	U_GravaSts( "PE_M440STTS(BlqCrd)" )

                        // ################################################################################
                        // Atualiza o Status do Pedido de Venda com 04 = Aguardando Liberação de Estoque ##
                        // ################################################################################
          		        RecLock( "SC6", .F. )
    		            SC6->C6_STATUS := "04"
               		    MsUnlock()

    		            // ########################################################
    		            // Atualiza o log de atualização de status na tabela ZZ0 ##
    		            // ########################################################
		                U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "04", "PE_M440STTS", 0 )
		                
		             Endif   
		             
		          Else   

  			   	     If !( SC6->C6_STATUS $ "08,09,10,11,12,13,14" )  // Jean Rehermann - 31/07/2012 | Incluida a validacao
					    U_GravaSts("PE_M440STTS")
				     EndIf
				     
				  Endif   

			   ENDIF

			EndIf                                                                                             

		 EndIf
		
		 SC9->( dbSkip() )
		
	  Enddo
	
   EndIf

   RestArea( _aArea )
   RestArea( _aAreaSC9 )

Return

// #######################################################################
// Verifica se existe pedido de compra em aberto para o pedido de venda ##
// #######################################################################
User Function Compra()

   Local _lTem := !Empty( AllTrim( SC6->C6_PCOMPRA + SC6->C6_ITPCSTS ) )
   Local _lRet := _lTem .And. SC6->C6_SLDPCOM > 0  // Status será verificado pelo saldo de compras entregue (calculado no PV)

   /*
   If !Empty( AllTrim( SC6->C6_PCOMPRA + SC6->C6_ITPCSTS ) )
      _lTem := .T.

      dbSelectArea("SC7")
      dbSetOrder(1)
      If (dbSeek( SC6->C6_FILIAL + SC6->C6_PCOMPRA + SC6->C6_ITPCSTS ) )
         _lRet := ( SC7->C7_QUJE < SC7->C7_QUANT .And. SC7->C7_RESIDUO == ' ' .And. SC7->C7_ENCER == ' ' )
      EndIf

   EndIf
   */
   
Return( { _lRet, _lTem } )

// #########################################################################################
// Jean Rehermann - Verifica se existe ordem de produção em aberto para o pedido de venda ##
// #########################################################################################
User Function Produz()

   Local _lRet := .F.
   Local _lTem := .F.

   If !Empty( AllTrim( SC6->C6_NUMOP + SC6->C6_ITEMOP ) ) .And. SC6->C6_OP $ "0103"
	
	  _lTem := .T.
	
	  dbSelectArea("SC2")
	  dbSetOrder(1)
	  If dbSeek( xFilial("SC2") + SC6->C6_NUMOP + SC6->C6_ITEMOP )
	     _lRet := ( SC2->C2_QUJE < SC2->C2_QUANT ) .And. Empty( SC2->C2_DATRF )
	  EndIf
	
   EndIf

Return( { _lRet, _lTem } )

// #########################################################################################
// Jean Rehermann | JPC - Efetua a avaliação dos status em cascata, em caso de retroação. ##
// #########################################################################################
User Function GravaSts( cOrig )

   Local _cFlagSts   := ""
   Local _cOrigem    := Iif( cOrig == Nil .Or. Empty( cOrig ), "GRAVASTS", cOrig )
   Local _nRecC9     := 0
   Local _nRecC5     := 0
   Local _Transporte := ""
   Local _lCont      := .t.	//Flag Continuacao do processo
   Local _lTipoN     := .F.
   Local kRisco      := Posicione("SA1",1,xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI, "A1_RISCO")

   // ##################################
   // Garanto o posicionamento no SC9 ##
   // ##################################
   cQuery := "SELECT R_E_C_N_O_ "
   cQuery += "  FROM " + RetSqlName("SC9") 
   cQuery += " WHERE C9_PEDIDO  = '" + Alltrim(SC6->C6_NUM)    + "' "
   cQuery += "   AND C9_ITEM    = '" + Alltrim(SC6->C6_ITEM)   + "' "
   cQuery += "   AND C9_FILIAL  = '" + Alltrim(SC6->C6_FILIAL) + "' "
   cQuery += "   AND D_E_L_E_T_ = ' '"

   dbUseArea( .T., "TOPCONN", TCGenQry( ,,cQuery ), "SC9REC", .F., .T. )

   // ###########################
   // Guardo o registro do SC9 ##
   // ###########################
   _nRecC9 := SC9REC->R_E_C_N_O_
   SC9REC->( dbCloseArea() )
   dbSelectArea("SC9")
   dbGoTo( _nRecC9 )

   //dbSelectArea("SC9")
   //dbSetOrder(1)
   //dbSeek( xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM )

   // Guardo o registro do SC9
   //_nRecC9 := SC9->( Recno() )

   // ##################################
   // Garanto o posicionamento no SC5 ##
   // ##################################
   dbSelectArea("SC5")
   dbSetOrder(1)
   dbSeek( xFilial("SC5") + SC9->C9_PEDIDO )

   // #########################################################################################################################################
   // Foi colocado aqui a carga desta variável pois quando função chamada pela análise de crédito, a variável lTipoN não estava inicializada ##
   // Esta variável foi criada pelo Jean da Solutio                                                                                          ##
   // #########################################################################################################################################
   _lTipoN := SC5->C5_TIPO == "N"

   // ###########################
   // Guardo o registro do SC5 ##
   // ###########################
   _nRecC5 := SC5->( Recno() )
   _Transporte := SC5->C5_TRANSP

   // ##############################
   // Avalia se item é de serviço ##
   // ##############################
   _lServ := U_Servico() // Verifico se o item é serviço

   // ##################################
   // Avalia se item atualiza estoque ##
   // ##################################
   _aAreaX := GetArea()
   _lStok := U_AtuEstok()
   RestArea( _aAreaX )

   // ################################
   // Avalia se item está em compra ##
   // ################################
   _aAreaSC6 := SC6->( GetArea() )
   _aCompra := U_Compra()
   _lCompra := _aCompra[ 1 ]
   _lOkComp := _aCompra[ 2 ]
   RestArea( _aAreaSC6 )

   // ##################################
   // Avalia se item está em produção ##
   // ##################################
   _aAreaSC6 := SC6->( GetArea() )
   _aProduz := U_Produz()
   _lProduz := _aProduz[ 1 ]
   _lOkProd := _aProduz[ 2 ]
   RestArea( _aAreaSC6 )

   // #####################
   // Reposiciono no SC9 ##
   // #####################
   dbSelectArea("SC9")
   dbGoTo( _nRecC9 )
   
   // #####################
   // Reposiciono no SC5 ##
   // #####################
   dbSelectArea("SC5")
   dbGoTo( _nRecC5 )

   dbSelectArea("SC6")

   // ###############################
   // Tratamento de Exceçoes       ##
   // 001 - PCP - Exclusao de OP´s ##
   // ###############################
   IF ALLTRIM(_cOrigem) == "PE_MA650DC6"
      IF !empty(SC6->C6_NOTA)
	     // ############################################################################
	     // Excluindo uma OP de um PV que ja foi faturado, nao precisa mudar o Status ##
	     // ############################################################################
		 _lCont := .f.
	  ENDIF
   ENDIF

   IF _lCont
     
      // ###############################################
      // Avalia se o pedido é Externo (intermediação) ##
      // ###############################################
	  _lPExt := SC5->C5_EXTERNO == "1"

	  If SC6->C6_BLQ == "R" .And. SC6->C6_STATUS != "14"
		 _cFlagSts := "14" // Pedido Cancelado
		
	  ElseIf _lPExt // Pedido Externo (intermediação)
		
		 _cNfFor := SC5->C5_NFDISTR // Busco conteudo do campo Nota Fiscal do Fornecedor
		
		 If Empty( _cNfFor ) .And. !( SC6->C6_STATUS $ "11,12,13,14" )
			_cFlagSts := "13" // Aguardando distribuidor
			
		 ElseIf !Empty( _cNfFor ) .And. !( SC6->C6_STATUS $ "10,11,12,13,14" )
			RecLock("SC9",.F.)
			SC9->C9_BLEST := "  " // Libero o estoque para faturar o pedido externo
			MsUnLock()
			_cFlagSts := "10" // Aguardando faturamento
			
		 EndIf

		 // Jean Rehermann - 23/01/2015 - Tarefa #11013 - Apenas na inclusão ou alteração do pedido deve validar margem para doação
		 /*
		 // Jean Rehermann - 27/02/2014 - Tarefa #8453
		 ElseIf SC6->C6_TES $ SuperGetMv("MV_TESDOAC",,"") // Pedido referente a doação
		 _cFlagSts := "02" // Bloqueia na margem os pedidos de doação
		 */

	ElseIf !_lStok .And. !_lServ // Não atualiza estoque (apenas remessas, serviço é tratado logo mais abaixo)
		If SC6->C6_STATUS != "10"
		   _cFlagSts := "10" // Aguardando faturamento
		EndIf
		
    ElseIf !( SC9->C9_BLCRED $ "  10" ) .And. SC6->C6_STATUS != "03" .And. _lTipoN // Bloqueado por crédito
		  _cFlagSts := "03" // Bloqueio de crédito
		
    ElseIf SC6->C6_ENTREG > ( dDataBase + 1 ) .And. !( SC6->C6_STATUS $ "05,07,11,12,13,14" ) .And. _lTipoN
		_cFlagSts := "05" // Aguardando programação de entrega

        // ######################################################################################################################
        // Observação: Foi incçuído no dia 05/04/2017 por Harald 0 Status 07 no if acima. Esta alteração foi acompanhada       ##
        // juntamente com o Sr. Fernando na mesma data. O Status do pedido de venda não pode ser alterado para 05 - Aguardando ##
        // Data de Entrega neste momento. Este Status somente poderá ser utilizado no encerramento da OP.                      ##
        // ######################################################################################################################
		
	ElseIf _lServ
		RecLock("SC9",.F.)
		
		SC9->C9_BLEST := "  " // Sempre libero o estoque quando for serviço
		
		// ######################################################################################################################
		// Em razão da implantação da nota fiscal de serviço eletrônica em 27/02/2015, esta variável não deve mais ser         ##
		// preenchida com o conteúdo SRV. Esta determinação foi aprovada via e-mail recebido da Contratoladoria em 27/02/2015. ##
		// SC9->C9_AGREG := "SRV" //Comentado Michel Aoki - Não haverá mais quebra da nota em serviço e produto.               ##
		// ######################################################################################################################
		SC9->C9_AGREG := ""
		
		MsUnLock()
		If SC6->C6_STATUS != "10"
			_cFlagSts := "10" // Aguardando faturamento
		EndIf
		
	ElseIf _lCompra .And. SC6->C6_STATUS != "06" // Tem pedido de compra e ainda não foi recebido
		_cFlagSts := "06" // Em compra
		
	ElseIf _lProduz .And. SC6->C6_STATUS != "07" // Tem amarração com ordem de produção
		_cFlagSts := "07" // Em produção
		
	ElseIf SC9->C9_BLEST $ "0203" // Bloqueado por estoque
		
//      If (cEmpAnt == "01" .And. SC9->C9_FILIAL == "04") .Or. ;
//         (cEmpAnt == "01" .And. SC9->C9_FILIAL == "07") .Or. ;
//         (cEmpAnt == "03" .And. SC9->C9_FILIAL == "01")

      	IF (LEFT(SC9->C9_PRODUTO,2) == "02" .Or. LEFT(SC9->C9_PRODUTO,2) == "03")
        Else
    	   If SC9->C9_BLEST == "02"
		      RecLock("SC9",.F.)
			  SC9->C9_BLEST := "03" // Sempre libero o estoque no padrão, mas bloqueio no status se não tiver saldo
			  MsUnLock()
		   EndIf
		Endif   
		
        // ##########################################
		// Verifico se existe saldo para o produto ##
		// ##########################################
		_aAreaSC6 := SC6->( GetArea() )
		_lSaldo := SaldoB2( SC6->C6_PRODUTO, SC6->C6_QTDVEN, SC6->C6_LOCAL )
		RestArea( _aAreaSC6 )
		
        // #####################
		// Reposiciono no SC9 ##
		// #####################
		dbSelectArea("SC9")
		dbGoTo( _nRecC9 )
		
        // #####################
 		// Reposiciono no SC5 ##
 		// #####################
		dbSelectArea("SC5")
		dbGoTo( _nRecC5 )
		
		dbSelectArea("SC6")
		
		If !_lServ .And. !_lOkComp .And. !_lOkProd .And. !_lSaldo // Não é servico, nao existe PC nem OP e nao tem saldo disponivel (SB2)
			If SC6->C6_STATUS != "04"
				_cFlagSts := "04" // Bloqueio de estoque
			EndIf
		Else
			If !( SC6->C6_STATUS $ "08,11,12,13,14" ) .And. !_lServ .And. !_lCompra .And. !_lProduz
				_cFlagSts := "08" // Aguardando separacao
			EndIf
		EndIf
		
	ElseIf SC6->C6_TEMDOC == "S"// .Or. SC6->C6_LACRE == "S" // Jean Rehermann - 16/07/2012 - Validar se está aguardando o cliente
		If SC6->C6_STATUS != "09"  // Aguardando Documentação cliente
			_cFlagSts := "09"
		End If
		
	ElseIf !( SC6->C6_STATUS $ "08,09,11,12,13,14" ) .And. !_lServ .And. SC5->C5_TIPO != "B"
   		   _cFlagSts := "08" // Aguardando separacao
		
	ElseIf SC6->C6_STATUS == "09" // Jean Rehermann - 17/07/2012 - Se chegou até aqui é porque ou vai separar ou vai faturar
		If SC6->C6_TEMDOC != "S"// .And. SC6->C6_LACRE != "S"
			If SC5->C5_JPCSEP == "T" // Verifico se já foi separado
				_cFlagSts := "10" // Aguardando Faturamento
			Else
				_cFlagSts := "08" // Aguardando separacao
			EndIf
		EndIf
		
	ElseIf AllTrim( FunName() ) == "MATA410" .Or. SC5->C5_TIPO != "B"
        // ################################################################################################################################
		// Jean - Alterado em 03-09-12 - Quando for emitida a nf diretamente da rotina de PV (MATA410) Prep. Docs., e quando tipo PV = B ##
		// ################################################################################################################################
		_cFlagSts := "10" // Aguardando Faturamento
	EndIf

	If !Empty( _cFlagSts )
		
		RecLock( "SC6", .F. )
		SC6->C6_STATUS := _cFlagSts //Gravo o novo status do item
		// Jean Rehermann - 23/01/2015 - Tarefa #11013 - Apenas na inclusão ou alteração do pedido deve validar margem para doação
		/*
		If _cFlagSts == "02"
		SC6->C6_BLQ := "S" // Quando for bloqueio de margem POR PEDIDO DE DOACAO - Tarefa #8453
		EndIf
		*/
		MsUnlock()
		
		// Jean Rehermann - 23/01/2015 - Tarefa #11013 - Apenas na inclusão ou alteração do pedido deve validar margem para doação
		/*
		If _cFlagSts == "02"
		dbSelectArea("SC5")
		dbSetOrder(1)
		DbSeek( xfilial("SC5") + SC6->C6_NUM )
		Reclock("SC5",.F.)
		SC5->C5_BLQ := "3"
		Msunlock()
		dbSelectArea("SC6")
		EndIf
		*/
		
		// Gravo o log de atualização de status na tabela ZZ0
		U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, _cFlagSts, _cOrigem, 0 )
		
		// Atualiza a hora na tabela SC9
		dbSelectArea("SC9")
		dbGoTo( _nRecC9 )
		RecLock("SC9",.F.)
		SC9->C9_HORA   := Time()
		SC9->C9_TRANSP := _Transporte
        SC9->C9_CODPG  := SC5->C5_CONDPAG
		MsUnLock()
		
        // ##############################################################################################################################
        // Verifica se o pedido de venda é um pedido de Locação. Se for, neste ponto dispara a inclusão do contrato do pedido de venda ##
        // ##############################################################################################################################
        U_AUTOM626(SC6->C6_FILIAL, SC6->C6_NUM)

	EndIf
	
  Endif

Return

// ################################################
// Jean Rehermann - Verifico se o item é serviço ##
// ################################################
User Function Servico()

   Local _lRet  := .F.

   _lRet := AllTrim( SC6->C6_CF ) $ "5933|6933"

Return( _lRet )

// ###########################################################################
// Jean Rehermann - 01-02-2012 - Consulta o saldo disponível para o produto ##
// ###########################################################################
Static Function SaldoB2( cProd, nQtd, cLoc )

   Local _aAreaSB2 := SB2->( GetArea() )
   Local _nSld     := 0
   Local _nSadPV   := 0
   Local _lRet     := .F.

   dbSelectArea("SB2")
   dbSetOrder(1)
   If dbSeek( xFilial("SB2") + cProd + cLoc )  // Jean Rehermann - 21/08/2014 - Nesta data adicionei o parâmetro cLoc para considerar o LOCAL no seek no SB2
	  
	  // #########################################
      // Pesquisa o saldo disponível do produto ##
      // #########################################
	  _nSld := SaldoSB2()
	
      // ################################
      // Quantidade em Pedido de Venda ##
      // ################################
//    _nSldPV := SB2->B2_QPEDVEN

//    _lRet := (_nSld - _nSldPV) >= ( nQtd )

      _lRet := (_nSld) >= ( nQtd )

   EndIf

   RestArea( _aAreaSB2 )

Return _lRet

// ##################
// Função AtuEstok ##
// ##################
User Function AtuEstok()

   Local _aAreaSF4 := SF4->( GetArea() )

   DbSelectArea("SF4")
   DbSetOrder(1)
   DbSeek( xFilial("SF4") + SC6->C6_TES )

   _lRet := SF4->F4_ESTOQUE == "S" // .And. ( Posicione("SC5", 1, SC6->C6_FILIAL + SC6->C6_NUM, "C5_TIPO") != "B" )

   RestArea( _aAreaSF4 )

Return _lRet