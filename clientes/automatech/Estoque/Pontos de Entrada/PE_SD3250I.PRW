#INCLUDE "rwmake.ch" 


// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: PE_SD3250I.PRW                                                          ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                         ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Jean Rehermann | JPC                                                    ##
// Data......: 04/01/2017                                                              ##
// Objetivo..: No apontamento da OP verifica se está encerrado e altera o status do PV ##
// Parâmetros: Sem Parâmetros                                                          ##
// ######################################################################################

User Function SD3250I()
	
   Local _aAreaSD3 := SD3->( GetArea() )
   Local _aAreaSC2 := SC2->( GetArea() )
   Local _aAreaSC6 := SC6->( GetArea() )
   Local _aAreaSC9 := SC9->( GetArea() )
   Local cSts      := "08"

   // #####################################
   // Apontamento total, encerrando a OP ##
   // #####################################
   If SD3->D3_PARCTOT == "T" .Or. ( SC2->C2_QUJE - SC2->C2_PERDA ) >= SC2->C2_QUANT
		
      dbSelectArea("SC2")
	  dbSetOrder(1)
	  
	  If dbSeek( xFilial("SC2") + SD3->D3_OP )
		 
         // ###############################
         // Amarrado com pedido de venda ##
		 // ###############################
		 If !Empty( AllTrim( SC2->C2_PEDIDO + SC2->C2_ITEMPV ) ) 

		    dbSelectArea("SC6")
			dbSetOrder(1)

			If dbSeek( xFilial("SC6") + SC2->C2_PEDIDO + SC2->C2_ITEMPV )
			   
               // #############################################################################################
               // Jean Rehermann | Solutio - 30/10/2012 - Só permite alterar o status se estiver em produção ##
               // #############################################################################################
			   If SC6->C6_STATUS == "07" 

				  RecLock("SC6", .F.)           

				  If SC6->C6_ENTREG > ( dDataBase + 1 ) .And. !( SC6->C6_STATUS $ "05,11,12,13,14" ) // Jean Rehermann - 04/12/13
                     // ######################################
                     // Aguardando data prevista de entrega ##
                     // ######################################
					 cSts := "05" 

				  Else
                     // ##################################
                     // Aguardando separação de estoque ##
                     // ##################################
					 cSts := "08" 

                     // ################################################################
                     // Grava 03 no campo C9_BLEST liberando o produto para separação ##
                     // ################################################################
                     dbSelectArea("SC9")
                     dbSetOrder(1)
                     If dbSeek( xFilial("SC9") + SC2->C2_PEDIDO + SC2->C2_ITEMPV )
	
                        // ###############################################################################
                        // Tarefa: #4949                                                                ##
                        // Versão 3                                                                     ##
                        // Pedido 148771 (Plimor) não caiu totalmente na separação (#4612 (TomTicket) ) ##
                        // Este teste deverá entrar em produção na versão 3.                            ##
                        // Foi eliminado na versão 1 porque no fechamento de OP manual este processo    ##
                        // não está funcionando. Assim que o processo manual for corrigido,este entrará ##
                        // em produção.                                                                 ##
                        // ###############################################################################  
                        // Do While !SC9->( Eof() )                    .And. ;
                        //          SC9->C9_PEDIDO  == SC2->C2_PEDIDO  .And. ;
                        //          SC9->C9_PRODUTO == SC2->C2_PRODUTO .And. ;
                        //          SC9->C9_ITEM    == SC2->C2_ITEMPV  .And. ;
                        //          SC9->C9_FILIAL  == xFilial("SC9")
                        // 
         			    //          RecLock("SC9",.F.)
			            //          SC9->C9_BLEST := "03"
			            //          MsUnLock()
                        // 
			            //    SC9->( DbSkip() )
			            // Enddo
			            
			         Endif      

				  EndIf

                  // #####################################################
                  // Gravo o log de atualização de status na tabela ZZ0 ##
                  // #####################################################
				  SC6->C6_STATUS := cSts
				  U_GrvLogSts(SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, cSts, "PE_SD3250I") 

                  // #################################################################################################################
				  // Jean Rehermann | Solutio - 15/10/2012 - Tarefa #5588 - Altera no PV a quantidade para ficar igual a produzida  ##
				  // #################################################################################################################
				  If ( SC2->C2_QUJE - SC2->C2_PERDA ) >= SC2->C2_QUANT
//					 SC6->C6_QTDVEN := SC2->C2_QUJE
//					 SC6->C6_VALOR  := Round( SC2->C2_QUJE * SC6->C6_PRCVEN, TamSX3("C6_VALOR")[2] )
				  EndIf

                  // ###################
 				  // Fim tarefa #5588 ##
 				  // ###################
				  MsUnLock()
				  
                  // ##################################################
 				  // Envia para a rotina de cálculo do Sales Machine ##
 				  // ##################################################       
                  ReorgProduto(SC6->C6_PRODUTO)
			   
                  // ##################################################
 				  // Envia para a rotina de corrige a reserva na SB2 ##
 				  // ##################################################
                  U_AUTOM597(SC6->C6_NUM, SC6->C6_FILIAL, SC6->C6_PRODUTO, SC6->C6_ITEM)

			   Else

                  // ##################################################
 				  // Envia para a rotina de cálculo do Sales Machine ##
 				  // ##################################################
                  ReorgProduto(SC6->C6_PRODUTO)
			   
                  // ##################################################
 				  // Envia para a rotina de corrige a reserva na SB2 ##
 				  // ##################################################
                  U_AUTOM597(SC6->C6_NUM, SC6->C6_FILIAL, SC6->C6_PRODUTO, SC6->C6_ITEM)

			   EndIf

			EndIf

  		 EndIf

	  EndIf
		
   EndIf
	
   // ######################################################################################
   // Envia para a função que libera demais produtos do pedido de venda (Exemplo: Ribbon) ##
   // ######################################################################################
/////   LibRestante()

   RestArea( _aAreaSC6 )
   RestArea( _aAreaSC2 )
   RestArea( _aAreaSD3 )
   RestArea( _aAreaSC9 )
   	
Return()

// ###############################################################################
// Função que dispara a rotina de cálculo do Sales Mechine para o produto da OP ##
// ###############################################################################
Static Function ReorgProduto(_Produto)

   MsgRun("Favor Aguarde! Calculando Custo Sales Machine ...", "Sales Machine",{|| xReorgProduto(_Produto) })
   
Return(.T.)
   
// ###############################################################################################
// Função que dispara a rotina de cálculo do Sales Mechine para o produto informado/selecionado ##
// ###############################################################################################
Static Function xReorgProduto(_Produto)

   U_AUTOM525(_Produto, 0, "", 1)

Return(.T.)

// #################################################################################
// Função que libera os demais itens do pedido de venda (Diferentes de Etiquetas) ##
// #################################################################################
Static Function LibRestante()

   Local cSql := ""

   // ##########################################
   // Pesquisa os produtos do pedido de venda ##
   // ##########################################
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT C6_FILIAL ,"
   cSql += "       C6_NUM    ,"
   cSql += "       C6_ITEM   ,"
   cSql += "       C6_PRODUTO,"
   cSql += "       C6_NUMOP  ,"
   cSql += "   	   C6_STATUS  "
   cSql += "  FROM " + RetSqlName("SC6")
   cSql += " WHERE C6_FILIAL  = '" + Alltrim(SC2->C2_FILIAL) + "'"
   cSql += "   AND C6_NUM     = '" + Alltrim(SC2->C2_PEDIDO) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   T_PRODUTOS->( DbGoTop() )
   
   WHILE !T_PRODUTOS->( EOF() )
   
      If T_PRODUTOS->C6_STATUS == "08"
         T_PRODUTOS->( DbSkip() )
         Loop
      Endif

      If T_PRODUTOS->C6_STATUS == "07"
         T_PRODUTOS->( DbSkip() )
         Loop
      Endif

      If Len(Alltrim(T_PRODUTOS->C6_STATUS)) == 17
         T_PRODUTOS->( DbSkip() )
         Loop
      Endif

      // ##########################################################################################
      // Altera o status do pedido de venda e grava o log de atualização de status na tabela ZZ0 ##
      // ##########################################################################################
      dbSelectArea("SC6")
	  dbSetOrder(1)
	  If dbSeek( T_PRODUTOS->C6_FILIAL + T_PRODUTOS->C6_NUM + T_PRODUTOS->C6_ITEM )
		 RecLock("SC6",.F.)
	     SC6->C6_STATUS := "08"
		 U_GrvLogSts(T_PRODUTOS->C6_FILIAL, T_PRODUTOS->C6_NUM, T_PRODUTOS->C6_ITEM, "08", "PE_SD3250I") 
		 MsUnLock()
      Endif		 
      
      // ################################################################
      // Grava 03 no campo C9_BLEST liberando o produto para separação ##
      // ################################################################
      dbSelectArea("SC9")
      dbSetOrder(1)
      If dbSeek( T_PRODUTOS->C6_FILIAL + T_PRODUTOS->C6_NUM )
	
         Do While !SC9->( Eof() )                     .And. ;
            SC9->C9_PEDIDO  == T_PRODUTOS->C6_NUM     .And. ;
            SC9->C9_PRODUTO == T_PRODUTOS->C6_PRODUTO .And. ;
            SC9->C9_ITEM    == T_PRODUTOS->C6_ITEM    .And. ;
            SC9->C9_FILIAL  == T_PRODUTOS->C6_FILIAL
            RecLock("SC9",.F.)
			SC9->C9_BLEST := "03"
			MsUnLock()
			SC9->( DbSkip() )
		 Enddo
		 
	  Endif

      T_PRODUTOS->( DbSkip() )
      
   ENDDO
   
Return(.T.)