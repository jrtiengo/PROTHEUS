#INCLUDE "rwmake.ch" 

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: AUTOM612.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                         ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Jean Rehermann | JPC                                                    ##
// Data......: 14/08/2017                                                              ##
// Objetivo..: Programa executado no início do módulo Estoque (SIGAEST). Este verifica ##
//             se existem produtos do pedido de venda no status 05. Se a  data  destes ##
//             pedidos tiverem sua data de entrega = a data do sistema (Dia), altera o ##
//             status para 08 - Aguardando Separação de Estoque.                       ##
// Parâmetros: Sem Parâmetros                                                          ##
// ######################################################################################

User Function AUTOM612()
	
   Local cSql  := ""
   Local dData := Date()

   U_AUTOM628("AUTOM612")

   _DataEntrega := .T.

   If cEmpAnt <> "03"
      Return(.T.)
   Endif      
   
   If Select("T_PEDIDOS") > 0
      T_PEDIDOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC6.C6_FILIAL ,"
   cSql += "       SC6.C6_NUM    ,"
   cSql += "       SC6.C6_ENTREG ,"
   cSql += "	   SC6.C6_STATUS ,"
   cSql += "       SC6.C6_ITEM   ,"
   cSql += "       SC6.C6_PRODUTO "
   cSql += "  FROM " + rETsQLnAME("SC6") + " SC6 "
   cSql += " WHERE SC6.C6_FILIAL = '" + Alltrim(cFilAnt) + "'"
   cSql += "   AND SC6.C6_ENTREG = CONVERT(DATETIME,'" + Dtoc(dData) + "', 103)"
   cSql += "   AND SC6.C6_STATUS = '05'"
   cSql += "   AND D_E_L_E_T_    = ''  "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDOS", .T., .T. )
   
   If T_PEDIDOS->( EOF() )
      Return(.T.)
   Endif
      
   T_PEDIDOS->( DbGoTop() )
   
   WHILE !T_PEDIDOS->( EOF() )

      dbSelectArea("SC6")
	  dbSetOrder(1)

	  If dbSeek( T_PEDIDOS->C6_FILIAL + T_PEDIDOS->C6_NUM + T_PEDIDOS->C6_ITEM )
			   
         // #################################################################
	     // Prende o registro do produto do pedido de venda para alteração ##
	     // #################################################################
	     RecLock("SC6", .F.)           

         // ################################################################
         // Grava 03 no campo C9_BLEST liberando o produto para separação ##
         // ################################################################
         dbSelectArea("SC9")
         dbSetOrder(1)
   
         If dbSeek( T_PEDIDOS->C6_FILIAL + T_PEDIDOS->C6_NUM )
	
            Do While !SC9->( Eof() )                          .And. ;
                     SC9->C9_PEDIDO  == T_PEDIDOS->C6_NUM     .And. ;
                     SC9->C9_PRODUTO == T_PEDIDOS->C6_PRODUTO .And. ;
                     SC9->C9_ITEM    == T_PEDIDOS->C6_ITEM    .And. ;
                     SC9->C9_FILIAL  == T_PEDIDOS->C6_FILIAL
               RecLock("SC9",.F.)
			   SC9->C9_BLEST := "03"
			   MsUnLock()
			   SC9->( DbSkip() )
			Enddo
			            
         Endif      

         // #####################################################
         // Gravo o log de atualização de status na tabela ZZ0 ##
         // #####################################################
         SC6->C6_STATUS := "08"
		 U_GrvLogSts(SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "08", "PE_SD3250I") 

         // ############################################
         // Desbloqueia o registro do pedido de venda ##
 		 // ############################################
		 MsUnLock()

      EndIf
      
      T_PEDIDOS->( DbSkip() )
      
   Enddo    

Return(.T.)