#INCLUDE "PROTHEUS.CH"

// ###############################################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                                        ##
// ------------------------------------------------------------------------------------------------------------ ##
// Referencia: MTA455I.PRW                                                                                      ##
// Parâmetros: Nenhum                                                                                           ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                                                  ##
// ------------------------------------------------------------------------------------------------------------ ##
// Autor.....: Jean Rehermann                                                                                   ##
// Data......: 20/09/2011                                                                                       ##
// Objetivo..: Liberação de Estoque                                                                             ##
//                                                                                                              ##
//             Jean Rehermann | JPC - 20/09/2011                                                                ##
//             Ponto de entrada MTA455I - Liberação de estoque                                                  ##
//                                                                                                              ##
// Parâmetros: Sem Parâmetros                                                                                   ##
// ###############################################################################################################

User Function MTA455I()

   U_AUTOM628("PE_MTA455I")
   
   _aArea := GetArea()       
   
// If (cEmpAnt == "01" .And. SC9->C9_FILIAL == "04") .Or. ; 
//    (cEmpAnt == "03" .And. SC9->C9_FILIAL == "01") .Or. ;
//    (cEmpAnt == "01" .And. SC9->C9_FILIAL == "07")
    
   If (LEFT(SC9->C9_PRODUTO,2) == "02" .Or. LEFT(SC9->C9_PRODUTO,2) == "03")

      //ELSE
                                
      dbSelectArea("SC6")
      dbSetOrder(1)
      
      If dbSeek( SC9->C9_FILIAL + SC9->C9_PEDIDO + SC9->C9_ITEM )

         If Empty(Alltrim(SC6->C6_NUMOP))

            //---                Reclock("SC6",.f.)
            //---                SC6->C6_STATUS := "08"
            //---                MsUnlock()
            //---            
            //---  		        // Gravo o log de atualização de status na tabela ZZ0
            //---		        U_GrvLogSts( xFilial("SC9"), SC9->C9_PEDIDO, SC9->C9_ITEM, "08", "PE_MTA455I", 0 )
          
            // ##############################################################################################################
            // Verifica aqui se o produto possui saldo.                                                                    ##
            // Se não tiver saldo, altera o status do pedido para 04 - Aguardando Liberação de Estoque.                    ##
            // Se tem saldo, verifica a data de entrega do produto.                                                        ##
            // - Se data de entrega <= Data Atual, Status 08 - Aguardando Separação, senão 05 - Aguardando Data de entrega ##
            // ##############################################################################################################
			DbSelectArea("SB2")
			DbSetOrder(1)
			
			If DbSeek(xFilial("SB2") + SC6->C6_PRODUTO + SC6->C6_LOCAL)
   	            _nSldProduto := SaldoSB2()
			Else
   	            _nSldProduto := 0
			EndIf

            If (_nSldProduto) >= ( SC6->C6_QTDVEN )

               If SC6->C6_ENTREG <= Date()

                  // #########################################
                  // Grava Status 08 - Aguardando Separação ##
                  // #########################################
                  Reclock("SC6",.f.)
                  SC6->C6_STATUS := "08"
                  MsUnlock()
            
                  // #####################################################
       		      // Gravo o log de atualização de status na tabela ZZ0 ##
    		      // #####################################################
		          U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "08", "PE_MT450FIM", 0 )
		
                  // ########################
 		          // Atualiza a tabela SC9 ##
 		          // ########################
                  dbSelectArea("SC9")
                  dbSetOrder(1)
                  If dbSeek( xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM)
	  	             RecLock("SC9",.F.)
	  	             SC9->C9_BLCRED := "" 

                     //If cEmpAnt == "03" .Or. (cEmpAnt == "01" .And. cFilant == "07")

                     If (LEFT(SC6->C6_PRODUTO,2) == "02" .Or. LEFT(SC6->C6_PRODUTO,2) == "03")
   		                SC9->C9_BLEST  := ""
	                 Else  	             
 		                SC9->C9_BLEST  := "03"
  		             Endif   
   		             MsUnLock()
		          Endif
		          
		       Else
		          
                  // #########################################
                  // Grava Status 08 - Aguardando Separação ##
                  // #########################################
                  Reclock("SC6",.f.)
                  SC6->C6_STATUS := "05"
                  MsUnlock()
            
                  // #####################################################
       		      // Gravo o log de atualização de status na tabela ZZ0 ##
    		      // #####################################################
		          U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "05", "PE_MT450FIM", 0 )
		
                  // ########################
 		          // Atualiza a tabela SC9 ##
 		          // ########################
                  dbSelectArea("SC9")
                  dbSetOrder(1)
                  If dbSeek( xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM )
	  	             RecLock("SC9",.F.)
	  	             SC9->C9_BLCRED := ""

                     //If cEmpAnt == "03" .Or. (cEmpAnt == "01" .And. cFilAnt == "07")

                     If (LEFT(SC6->C6_PRODUTO,2) == "02" .Or. LEFT(SC6->C6_PRODUTO,2) == "03")
   		                SC9->C9_BLEST  := ""                                                   
   		             Else   
  		                SC9->C9_BLEST  := "02"
  		             Endif   

   		             MsUnLock()
		          Endif
		          
		       Endif   

            Else
                                      
               // #########################
               // Posiciona a tabela SC9 ##
               // #########################
               dbSelectArea("SC9")
               dbSetOrder(1)
               dbSeek( xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM )

   		       IF Empty(SC6->C6_NUMOP) .AND. Empty(SC9->C9_BLCRED) .AND. (LEFT(SC6->C6_PRODUTO,2) == "02" .Or. LEFT(SC6->C6_PRODUTO,2) == "03")      
   		 	   Else   
           
                  If Alltrim(SC6->C6_PCS) == "S"

                     Reclock("SC6",.f.)
                     SC6->C6_STATUS := "06" &&04
                     MsUnlock()
            
                     // #####################################################
    		         // Gravo o log de atualização de status na tabela ZZ0 ##
    		         // #####################################################
		             U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "06", "PE_MTA455I", 0 ) &&04
		             
                     // ################################
                     // Atualiza a hora na tabela SC9 ##
  	                 // ################################
                     dbSelectArea("SC9")
                     dbSetOrder(1)
                     If dbSeek( xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM )
   	                    RecLock("SC9",.F.)
  // 	                SC9->C9_BLCRED := "03"
  //                    SC9->C9_BLEST  := "03"
  
    	                SC9->C9_BLCRED := ""

//                      If cEmpAnt == "03" .Or. (cEmpAnt == "01" .And. cFilAnt == "07")


                        If (LEFT(SC6->C6_PRODUTO,2) == "02" .Or. LEFT(SC6->C6_PRODUTO,2) == "03")
    	                   SC9->C9_BLEST  := ""
    	                Else   
       	                   SC9->C9_BLEST  := "03"
       	                Endif   
  	                    MsUnLock()

  	                 Endif   

		          Else
		          
                     If SC6->C6_ENTREG <= Date()

                        // #########################################
                        // Grava Status 08 - Aguardando Separação ##
                        // #########################################
                        Reclock("SC6",.f.)
                        SC6->C6_STATUS := "08"
                        MsUnlock()
            
                        // #####################################################
        		        // Gravo o log de atualização de status na tabela ZZ0 ##
       		            // #####################################################
	   	                U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "08", "PE_MT450FIM", 0 )
		
                        // ########################
 		                // Atualiza a tabela SC9 ##
 		                // ########################
                        dbSelectArea("SC9")
                        dbSetOrder(1)
                        If dbSeek( xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM)
	  	                   RecLock("SC9",.F.)
	  	                   SC9->C9_BLCRED := "" 

//                         If cEmpAnt == "03" .Or. (cEmpAnt == "01" .And. cFilAnt == "07")
        


                           If (LEFT(SC6->C6_PRODUTO,2) == "02" .Or. LEFT(SC6->C6_PRODUTO,2) == "03")
   		                      SC9->C9_BLEST  := ""
	                       Else  	             
  		                      SC9->C9_BLEST  := "03"
  		                   Endif   
   		                   MsUnLock()
		                Endif
		          
		             Else
		          
                        // #########################################
                        // Grava Status 08 - Aguardando Separação ##
                        // #########################################
                        Reclock("SC6",.f.)
                        SC6->C6_STATUS := "05"
                        MsUnlock()
            
                        // #####################################################
       		            // Gravo o log de atualização de status na tabela ZZ0 ##
    		            // #####################################################
		                U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "05", "PE_MT450FIM", 0 )
		
                        // ########################
 		                // Atualiza a tabela SC9 ##
 		                // ########################
                        dbSelectArea("SC9")
                        dbSetOrder(1)
                        If dbSeek( xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM )
	  	                   RecLock("SC9",.F.)
	  	                   SC9->C9_BLCRED := ""
                        
//                         If cEmpAnt == "03" .Or. (cEmpAnt == "01" .And. cFilAnt == "07")



                           If (LEFT(SC6->C6_PRODUTO,2) == "02" .Or. LEFT(SC6->C6_PRODUTO,2) == "03")
   		                      SC9->C9_BLEST  := ""                                                   
   		                   Else   
  		                      SC9->C9_BLEST  := "02"
  		                   Endif   
                        
   		                   MsUnLock()
		                Endif
		          
  		             Endif   
		          
		          Endif
		          
               Endif		

//               // ################################
//               // Atualiza a hora na tabela SC9 ##
//	           // ################################
//               dbSelectArea("SC9")
//               dbSetOrder(1)
//               If dbSeek( xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM )
// 	             RecLock("SC9",.F.)
//// 	             SC9->C9_BLCRED := "03"
////               SC9->C9_BLEST  := "03"
//
//  	             SC9->C9_BLCRED := ""
//                 If cEmpAnt == "03" .Or. (cEmpAnt == "01" .And. cFilAnt == "07")
//  	                SC9->C9_BLEST  := ""
//  	             Else   
//     	            SC9->C9_BLEST  := "03"
//     	         Endif   
//	             MsUnLock()
//	          
//  		      Endif   
  		      
  		    Endif   

        Else
         
            // ################################################################################
            // Atualiza o Status do Pedido de Venda com 04 = Aguardando Liberação de Estoque ##
            // ################################################################################
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

//               If (cEmpAnt == "01" .And. SC9->C9_FILIAL == "04") .Or. ;
//                  (cEmpAnt == "03" .And. SC9->C9_FILIAL == "01") .Or. ;
//                  (cEmpAnt == "01" .And. SC9->C9_FILIAL == "07")

               If (LEFT(SC9->C9_PRODUTO,2) == "02" .Or. LEFT(SC9->C9_PRODUTO,2) == "03")
                  SC6->C6_STATUS := "07"
               Else   
    	         SC6->C6_STATUS := "03"
                 MsUnlock()
               Endif   

               // ################################
               // Atualiza a hora na tabela SC9 ##
	           // ################################
               dbSelectArea("SC9")
               dbSetOrder(1)
               If dbSeek( xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM )
       	          Reclock("SC9",.f.)
		          SC9->C9_BLEST := ""
		          MsUnlock()
		       Endif   
            
               //	U_GravaSts( "PE_M440STTS(BlqCrd)" )
               		       
     	       // ########################################################
    	       // Atualiza o log de atualização de status na tabela ZZ0 ##
    	       // ########################################################
		       U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "03", "PE_MTA455I", 0 )

            Endif   

         Endif

      Endif

//       Endif       
       
    Else   
	   U_GravaSts("PE_MTA455I")  
	Endif   
	
	RestArea( _aArea )

Return()