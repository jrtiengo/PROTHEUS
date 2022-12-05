#INCLUDE "rwmake.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: PE_MTA455E.PRW                                                      ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: ( ) Programa  ( ) Gatilho (X) Ponte de Entrada                      ##                       
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 16/10/2017                                                          ##
// Objetivo..: VALIDA LIBERACAO DE ESTOQUE, Executado apos liberacao do estoque, e ##
//             impede a liberacao dependendo do retorno.                           ##
// ##################################################################################

User Function MTA455E

   Local _Ret := 1
   
Return(_Ret)   

/*

   Local _Ret 		:= 2
   Local _cLog		:= "" 
   Local _cNomArq	:= "LOG_LIB_"+DtoS(Date())+"_"+Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2)+".LOG"

   U_AUTOM628("PE_MTA455P")

   If Transform(cNivel,'9') >= Transform(7,'9')
 
      If Select("T_ENVOLVIDOS") > 0
         T_ENVOLVIDOS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SC5.C5_FILIAL ,"
      cSql += "       SC5.C5_NUM    ,"
      cSql += "       SC6.C6_NUM    ,"
      cSql += "		  SC6.C6_ITEM   ,"
      cSql += "		  SC6.C6_PRODUTO,"
      cSql += "       SC6.C6_NOTA   ,"
      cSql += "       SC6.C6_NUMOP   "
      cSql += "   FROM " + RetSqlName("SC5") + " SC5, "
      cSql += "        " + RetSqlName("SC6") + " SC6  "
      cSql += "  WHERE SC5.C5_FILIAL  = '" + Alltrim(cFilAnt) + "'"
      cSql += "    AND SC5.C5_NUM    >= '" + Alltrim(MV_PAR01) + "'"
      cSql += "	AND SC5.C5_NUM       <= '" + Alltrim(MV_PAR02) + "'"
      cSql += "	AND SC5.D_E_L_E_T_ = ''"
      cSql += "	AND SC6.C6_FILIAL  = SC5.C5_FILIAL"
      cSql += "	AND SC6.C6_NUM     = SC5.C5_NUM   "
      cSql += "	AND SC6.D_E_L_E_T_ = ''           "
  
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ENVOLVIDOS", .T., .T. )
      
      T_ENVOLVIDOS->( DbGoTop() )
      
      WHILE !T_ENVOLVIDOS->( EOF() )

         // #####################################################################################
         // Veririca se a Empresa logada é a ATECH. Se for , verifica se o produto é etiqueta. ##
         // #####################################################################################
         If cEmpAnt == "03" .Or. (cEmpAnt == "01" .And. cFilAnt == "07")

            // ###########################################
            // Posiciona o cabeçalho do pedido de venda ##
            // ###########################################
            DbSelectArea("SC5")
            DbSetOrder(1)
            DbSeek( T_ENVOLVIDOS->C5_FILIAL + T_ENVOLVIDOS->C5_NUM )

            // ######################################
            // Posiciona o item do pedido de venda ##
            // ######################################
            DbSelectArea("SC6")
            DbSetOrder(1)
            DbSeek( T_ENVOLVIDOS->C5_FILIAL + T_ENVOLVIDOS->C5_NUM + T_ENVOLVIDOS->C6_ITEM + T_ENVOLVIDOS->C6_PRODUTO )

            _cLog := "Liberacao de estoque pelo usuario "+Substr(cUsuario,7,7)+" - "+DtoC(Date())+" - "+Time()+" / "+ProcName()+" - "+FunName()+" - Pedido: "+T_ENVOLVIDOS->C6_NUM+"/ Item: "+T_ENVOLVIDOS->C6_ITEM
            MemoWrite(_cNomArq,_cLog)
            //MsgStop("Liberado - "+_cLog+" - "+_cNomArq)

            // ###########################################
            // Pesquisa o pedido de venda na tabela SC9 ##
            // ###########################################                                                 
            _cSql := ""
            _cSql := "SELECT C9_PEDIDO, "
            _cSql += "       C9_ITEM  , "
            _cSql += "       C9_BLCRED, "          
            _cSql += "		 C9_BLEST   "
            _cSql += "  FROM " + RetSqlName("SC9") 
            _cSql += " WHERE C9_PEDIDO  = '" + Alltrim(T_ENVOLVIDOS->C5_NUM)     + "'"
            _cSql += "   AND C9_FILIAL  = '" + Alltrim(T_ENVOLVIDOS->C5_FILIAL)  + "'"
            _cSql += "   AND C9_PRODUTO = '" + Alltrim(T_ENVOLVIDOS->C6_PRODUTO) + "'"
            _cSql += "   AND C9_ITEM    = '" + Alltrim(T_ENVOLVIDOS->C6_ITEM)    + "'"
            _cSql += "   AND D_E_L_E_T_ = ''"
           
            dbUseArea(.T.,"TOPCONN", TCGenQry(,,_cSql),"T_C9", .F., .T.)

            While !T_C9->( Eof() )
	
               dbSelectArea("SC6")
    	       dbSetOrder(1)
    	       dbSeek( xFilial("SC6") + T_C9->C9_PEDIDO + T_C9->C9_ITEM )
	     
	           // ###################################################################################
               // Validação para não alterar o status de itens de um mesmo pedido faturado parcial ##
               // ###################################################################################
      	        If Empty( T_ENVOLVIDOS->C6_NOTA )

	               // ############################################ 
   		           //                Projeto PCP                ##
		           // Geraçao da OP após a liberação de estoque ##
		           // ############################################
				   IF Empty(T_ENVOLVIDOS->C6_NUMOP) .AND. Empty(T_C9->C9_BLCRED) .AND. (LEFT(T_ENVOLVIDOS->C6_PRODUTO,2) == "02" .Or. LEFT(T_ENVOLVIDOS->C6_PRODUTO,2) == "03")      
   		 	          U_GeraOP()
  			       EndIf		   

   		       Endif

               U_GravaSts("PE_MT450FIM")
		    
  	           DbSelectArea("T_C9")
   	           T_C9->( dbSkip() )
	
            Enddo

            T_C9->( dbCloseArea() )

            _Ret := 1
         
         Endif
         
         T_ENVOLVIDOS->( DbSkip() )
         
      ENDDO   

   Else
   
      _cLog 	:= "Liberacao de estoque bloqueada para o usuario "+Substr(cUsuario,7,7)+" - "+DtoC(Date())+" - "+Time()+" / "+ProcName()+" - "+FunName()+" - Erro na Geração Automática"
      _cNomArq:= "LOG_BLOQ_"+DtoS(Date())+"_"+Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2)+".LOG"	
      MemoWrite(_cNomArq,_cLog)
      _Ret 	:= 2
      ApMsgInfo("Seu usuário não possui permissão para a utilização desta rotina!!!","Atenção")

   Endif

*/

Return _Ret