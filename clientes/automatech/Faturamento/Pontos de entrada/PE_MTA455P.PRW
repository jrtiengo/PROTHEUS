#INCLUDE "rwmake.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: PE_MTA455P.PRW                                                      ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: ( ) Programa  ( ) Gatilho (X) Ponte de Entrada                      ##                       
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 16/10/2017                                                          ##
// Objetivo..: VALIDA LIBERACAO DE ESTOQUE, Executado apos liberacao do estoque, e ##
//             impede a liberacao dependendo do retorno.                           ##
// ##################################################################################

User Function MTA455P

   Local cSql       := ""
   Local _Ret 		:= .F.
   Local _cLog		:= "" 
   Local _cNomArq	:= "LOG_LIB_"+DtoS(Date())+"_"+Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2)+".LOG"

   U_AUTOM628("PE_MTA455P")                                          
   
   If Transform(cNivel,'9') >= Transform(7,'9')
      _cLog := "Liberacao de estoque pelo usuario "+Substr(cUsuario,7,7)+" - "+DtoC(Date())+" - "+Time()+" / "+ProcName()+" - "+FunName()+" - Pedido: "+SC9->C9_PEDIDO+"/ Item: "+SC9->C9_ITEM
      MemoWrite(_cNomArq,_cLog)
      //MsgStop("Liberado - "+_cLog+" - "+_cNomArq)

      // #####################################################################################
      // Veririca se a Empresa logada é a ATECH. Se for , verifica se o produto é etiqueta. ##
      // #####################################################################################
//    If cEmpAnt == "03" .Or. (cEmpAnt == "01" .And. cFilAnt == "07") .Or. Len(Alltrim(SC6->C6_PRODUTO)) = 17

   	  If (LEFT(SC6->C6_PRODUTO,2) == "02" .Or. LEFT(SC6->C6_PRODUTO,2) == "03")
         // ###########################################
         // Pesquisa o pedido de venda na tabela SC9 ##
         // ###########################################                                                 
         If (Select( "T_C9" ) != 0 )
            T_C9->( DbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT C9_PEDIDO, "
         cSql += "       C9_ITEM  , "
         cSql += "       C9_BLCRED, "          
         cSql += "		  C9_BLEST   "
         cSql += "  FROM " + RetSqlName("SC9") 
         cSql += " WHERE C9_PEDIDO  = '" + Alltrim(SC5->C5_NUM)     + "'"
         cSql += "   AND C9_FILIAL  = '" + Alltrim(cFilAnt)         + "'"
         cSql += "   AND C9_PRODUTO = '" + Alltrim(SC6->C6_PRODUTO) + "'"
         cSql += "   AND C9_ITEM    = '" + Alltrim(SC6->C6_ITEM)    + "'"
         cSql += "   AND D_E_L_E_T_ = ''"
          
         cSql := ChangeQuery( cSql )
         dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_C9",.T.,.T.)

         While !T_C9->( Eof() )
	
            dbSelectArea("SC6")
	        dbSetOrder(1)
    	    dbSeek( xFilial("SC6") + T_C9->C9_PEDIDO + T_C9->C9_ITEM )
	     
	        // ###################################################################################
            // Validação para não alterar o status de itens de um mesmo pedido faturado parcial ##
            // ###################################################################################
	        If Empty( SC6->C6_NOTA )

	           // ############################################ 
   		       //                Projeto PCP                ##
		       // Geraçao da OP após a liberação de estoque ##
		       // ############################################
			   IF Empty(SC6->C6_NUMOP) .AND. Empty(T_C9->C9_BLCRED) .AND. (LEFT(SC6->C6_PRODUTO,2) == "02" .Or. LEFT(SC6->C6_PRODUTO,2) == "03")      
   		 	      U_GeraOP()
    		   Else
                  U_GravaSts("PE_MT450FIM")    		   
    		   Endif      
    		   
    		Endif

//          U_GravaSts("PE_MT450FIM")
		    
  	        DbSelectArea("T_C9")
   	        T_C9->( dbSkip() )
	
         Enddo

         T_C9->( dbCloseArea() )

         _Ret := .T.
         
      Endif

   Else
   
      _cLog 	:= "Liberacao de estoque bloqueada para o usuario "+Substr(cUsuario,7,7)+" - "+DtoC(Date())+" - "+Time()+" / "+ProcName()+" - "+FunName()+" - Pedido: "+SC9->C9_PEDIDO+"/ Item: "+SC9->C9_ITEM
      _cNomArq:= "LOG_BLOQ_"+DtoS(Date())+"_"+Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2)+".LOG"	
      MemoWrite(_cNomArq,_cLog)
      _Ret 	:= .F.
      ApMsgInfo("Seu usuário não possui permissão para a utilização desta rotina!!!","Atenção")
   Endif

Return _Ret