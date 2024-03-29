#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// #########################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                                  ##
// -------------------------------------------------------------------------------------- ##
// Referencia: AUTOM618.PRW                                                               ##
// Par�metros: Nenhum                                                                     ##
// Tipo......: (X) Programa  ( ) Gatilho                                                  ##
// -------------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                                    ##
// Data......: 18/08/2017                                                                 ##
// Objetivo..: Programa que gera automaticamente a libera��o de pedido de venda dos tipos ##
//             Pedido de Intermedia��o.                                                   ##
// Par�metros: K_Filial -> C�digo da Filial do Pedido de Venda                            ##
//             K_Pedido -> N�mero do Pedido de Venda                                      ##
//             K_Tipo   -> Indica o tipo de Pedido de Venda a ser liberado                ##
//                         1 - Pedidos de Servi�os (Assist�ncia T�cnica)                  ##
//                         2 - Pedidos de Remessa para Conserto                           ##
//                         3 - Pedidos de AT com TES 766 - (DEV TROCA GARANTIA)           ##
// #########################################################################################

User Function AUTOM618(K_Filial, K_Pedido, K_Tipo)
 
   Local cSql := ""

   U_AUTOM628("AUTOM618")

   // ####################################################
   // Libera produtos/servi�os na efetiva��o de OS (AT) ##
   // ####################################################
   If K_Tipo == 1

      // ###############################################################
      // Pesquisa os produtos do pedido de venda passado no par�metro ##
      // ###############################################################
      If Select("T_PRODUTOS") > 0
         T_PRODUTOS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SC6.C6_FILIAL ,"
      cSql += "       SC6.C6_NUM    ,"
      cSql += "       SC6.C6_ITEM   ,"
      cSql += "       SC6.C6_PRODUTO,"
      cSql += "	      SB1.B1_TIPO   ,"
      cSql += "	      SC6.C6_TES    ,"
      cSql += "       SF4.F4_DUPLIC ,"
      cSql += "       SC6.C6_CLI    ,"
      cSql += "       SC6.C6_LOJA   ,"
      cSql += "       SC6.C6_QTDVEN ,"
      cSql += "       SC6.C6_PRCVEN ,"
      cSql += "       SC6.C6_LOCAL  ,"
      cSql += "       SC6.C6_ENTREG ,"
      cSql += "       SC6.C6_TES    ,"
      cSql += "       SB1.B1_GRUPO  ,"
      cSql += "       SC5.C5_CONDPAG,"
      cSql += "       SC5.C5_CLIENTE,"
      cSql += "       SC5.C5_LOJACLI "
      cSql += "  FROM " + RetSqlName("SC6") + " SC6 (Nolock), "
      cSql += "       " + RetSqlName("SB1") + " SB1 (Nolock), "
      cSql += "	      " + RetSqlName("SF4") + " SF4 (Nolock), "
	  cSql += "       " + RetSqlName("SC5") + " SC5 (Nolock)  "
      cSql += " WHERE SC6.C6_FILIAL  = '" + Alltrim(K_Filial) + "'"
      cSql += "   AND SC6.C6_NUM     = '" + Alltrim(K_Pedido) + "'"
      cSql += "   AND SC6.D_E_L_E_T_ = ''"
      cSql += "   AND SB1.B1_COD     = SC6.C6_PRODUTO"
      cSql += "   AND SB1.D_E_L_E_T_ = ''"
      cSql += "	  AND SF4.F4_CODIGO  = SC6.C6_TES"
      cSql += "	  AND SF4.D_E_L_E_T_ = ''"
	  cSql += "	  AND SC5.C5_FILIAL  = SC6.C6_FILIAL"
	  cSql += "	  AND SC5.C5_NUM     = SC6.C6_NUM"
	  cSql += "	  AND SC5.D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

      T_PRODUTOS->( DbGoTop() )
   
      WHILE !T_PRODUTOS->( EOF() )

         // ###################################
         // Inclui o registro na tabelqa SC9 ##
         // ###################################
         dbSelectArea("SC9")
         RecLock("SC9",.T.)
         SC9->C9_FILIAL	 := T_PRODUTOS->C6_FILIAL
         SC9->C9_PEDIDO	 := T_PRODUTOS->C6_NUM
         SC9->C9_ITEM	 := T_PRODUTOS->C6_ITEM
         SC9->C9_CLIENTE := T_PRODUTOS->C5_CLIENTE
         SC9->C9_LOJA	 := T_PRODUTOS->C5_LOJACLI
         SC9->C9_PRODUTO := T_PRODUTOS->C6_PRODUTO
         SC9->C9_QTDLIB	 := T_PRODUTOS->C6_QTDVEN
         SC9->C9_DATALIB := Date()
         SC9->C9_SEQUEN	 := "01"
         SC9->C9_GRUPO	 := T_PRODUTOS->B1_GRUPO
         SC9->C9_PRCVEN	 := T_PRODUTOS->C6_PRCVEN
         SC9->C9_AGREG	 := T_PRODUTOS->C5_CONDPAG
         SC9->C9_LOCAL	 := T_PRODUTOS->C6_LOCAL
         SC9->C9_TPCARGA := "2"
         SC9->C9_RETOPER := "2"
         SC9->C9_TPOP	 := "1"
         SC9->C9_DATENT	 := Date()

         // #########################################################
         // Se TES Gera duplicata, envia para a an�lise de cr�dito ##
         // #########################################################
         If T_PRODUTOS->F4_DUPLIC == "S"        
            SC9->C9_BLEST  := "03"
//          SC9->C9_BLCRED := "06"             
//          SC9->C9_BLCRED := "09"             
            SC9->C9_BLCRED := "01"
            SC9->C9_BLWMS  := "05"
         Endif

         MsUnLock()

         // ###########################################################
         // Altera o Stataus do produto nos itens do pedido de venda ##
         // ###########################################################
         dbSelectArea("SC6")
         DBSetOrder(1)
         DbSeek ( T_PRODUTOS->C6_FILIAL + T_PRODUTOS->C6_NUM + T_PRODUTOS->C6_ITEM + T_PRODUTOS->C6_PRODUTO)
         RecLock("SC6",.F.)
         If T_PRODUTOS->F4_DUPLIC == "S"
     	    SC6->C6_STATUS := "03"
     	 Else   
    	     SC6->C6_STATUS := "10"
//     	     SC6->C6_STATUS := "03"
      	 Endif    
         MsUnLock()
      
         // ############################################################
         // Atualiza o campo C5_LIBEROK para liberar o pedio de venda ##
         // ############################################################
         dbSelectArea("SC5")
         DBSetOrder(1)
         DbSeek ( T_PRODUTOS->C6_FILIAL + T_PRODUTOS->C6_NUM )
         RecLock("SC5",.F.)
  	     SC5->C5_LIBEROK := "S"
         MsUnLock()

         // ##############################################################  
         // Atualiza a tabela ZZ0 (Tabela de Status de Pedido de Venda) ##
         // ##############################################################
         U_GrvLogSts(xFilial("SC6"),SC6->C6_NUM, SC6->C6_ITEM, "10", "AUTOM618 (AT)") // Gravo o log de atualiza��o de status na tabela ZZ0

         T_PRODUTOS->( DbSkip() )
      
      Enddo   
      
   Endif   

   // ###################################################
   // Libera produtos com TES de Remessa para Conserto ##
   // ###################################################
   If K_Tipo == 2

      // ###############################################################
      // Pesquisa os produtos do pedido de venda passado no par�metro ##
      // ###############################################################
      If Select("T_PRODUTOS") > 0
         T_PRODUTOS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SC6.C6_FILIAL ,"
      cSql += "       SC6.C6_NUM    ,"
      cSql += "       SC6.C6_ITEM   ,"
      cSql += "       SC6.C6_PRODUTO,"
      cSql += "       SC6.C6_CLI    ,"
      cSql += "       SC6.C6_LOJA   ,"
      cSql += "       SC6.C6_QTDVEN ,"
      cSql += "       SC6.C6_PRCVEN ,"
      cSql += "       SC6.C6_LOCAL  ,"
      cSql += "       SC6.C6_ENTREG ,"
      cSql += "       SC6.C6_TES    ,"
      cSql += "       SB1.B1_GRUPO  ,"
      cSql += "       SC5.C5_CONDPAG "
      cSql += "  FROM " + RetSqlName("SC6") + " SC6 (Nolock),"
      cSql += "       " + RetSqlName("SB1") + " SB1 (Nolock),"
      cSql += "       " + RetSqlName("SC5") + " SC5 (Nolock) "
      cSql += "  WHERE SC6.C6_FILIAL  = '" + Alltrim(K_Filial) + "'"
      cSql += "    AND SC6.C6_NUM     = '" + Alltrim(K_Pedido) + "'"
      cSql += "    AND SC6.C6_TES IN ('722', '730', '713')"
      cSql += "    AND SC6.D_E_L_E_T_ = ''"
      cSql += "    AND SB1.B1_COD     = SC6.C6_PRODUTO"
      cSql += "    AND SB1.D_E_L_E_T_ = ''"
	  cSql += "	   AND SC5.C5_FILIAL  = SC6.C6_FILIAL"
	  cSql += "	   AND SC5.C5_NUM     = SC6.C6_NUM"
	  cSql += "	   AND SC5.D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

      T_PRODUTOS->( DbGoTop() )
   
      WHILE !T_PRODUTOS->( EOF() )

         // ###################################
         // Inclui o registro na tabelqa SC9 ##
         // ###################################
         dbSelectArea("SC9")
         RecLock("SC9",.T.)
         SC9->C9_FILIAL	 := T_PRODUTOS->C6_FILIAL
         SC9->C9_PEDIDO	 := T_PRODUTOS->C6_NUM
         SC9->C9_ITEM	 := T_PRODUTOS->C6_ITEM
         SC9->C9_CLIENTE := T_PRODUTOS->C6_CLI
         SC9->C9_LOJA	 := T_PRODUTOS->C6_LOJA
         SC9->C9_PRODUTO := T_PRODUTOS->C6_PRODUTO
         SC9->C9_QTDLIB	 := T_PRODUTOS->C6_QTDVEN
         SC9->C9_DATALIB := Date()
         SC9->C9_SEQUEN	 := "01"
         SC9->C9_GRUPO	 := T_PRODUTOS->B1_GRUPO
         SC9->C9_PRCVEN	 := T_PRODUTOS->C6_PRCVEN
         SC9->C9_AGREG	 := T_PRODUTOS->C5_CONDPAG
         SC9->C9_LOCAL	 := T_PRODUTOS->C6_LOCAL
         SC9->C9_TPCARGA := "2"
         SC9->C9_RETOPER := "2"
         SC9->C9_TPOP	 := "1"
         SC9->C9_DATENT	 := Date()
         MsUnLock()

         // ###########################################################
         // Altera o Stataus do produto nos itens do pedido de venda ##
         // ###########################################################
         dbSelectArea("SC6")
         DBSetOrder(1)
         DbSeek ( T_PRODUTOS->C6_FILIAL + T_PRODUTOS->C6_NUM + T_PRODUTOS->C6_ITEM + T_PRODUTOS->C6_PRODUTO)
         RecLock("SC6",.F.)
   	     SC6->C6_STATUS := "10"
         MsUnLock()
      
         // ####################################################################
         // Atualiza o campo C5_LIBEROK para liberar o pedio de Intermedia��o ##
         // ####################################################################
         dbSelectArea("SC5")
         DBSetOrder(1)
         DbSeek ( T_PRODUTOS->C6_FILIAL + T_PRODUTOS->C6_NUM )
         RecLock("SC5",.F.)
  	     SC5->C5_LIBEROK := "S"
         MsUnLock()

         // ##############################################################  
         // Atualiza a tabela ZZ0 (Tabela de Status de Pedido de Venda) ##
         // ##############################################################
         U_GrvLogSts(xFilial("SC6"),SC6->C6_NUM, SC6->C6_ITEM, "10", "AUTOM618 (CONSERTO)") // Gravo o log de atualiza��o de status na tabela ZZ0

         T_PRODUTOS->( DbSkip() )
      
      Enddo   
      
   Endif   
                                   
   // ###################################################
   // Libera produtos com TES 766 (DEV TROCA GARANTIA) ##
   // ###################################################
   If K_Tipo == 3

      // ###############################################################
      // Pesquisa os produtos do pedido de venda passado no par�metro ##
      // ###############################################################
      If Select("T_PRODUTOS") > 0
         T_PRODUTOS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SC6.C6_FILIAL ,"
      cSql += "       SC6.C6_NUM    ,"
      cSql += "       SC6.C6_ITEM   ,"
      cSql += "       SC6.C6_PRODUTO,"
      cSql += "       SC6.C6_CLI    ,"
      cSql += "       SC6.C6_LOJA   ,"
      cSql += "       SC6.C6_QTDVEN ,"
      cSql += "       SC6.C6_PRCVEN ,"
      cSql += "       SC6.C6_LOCAL  ,"
      cSql += "       SC6.C6_ENTREG ,"
      cSql += "       SC6.C6_TES    ,"
      cSql += "       SB1.B1_GRUPO  ,"
      cSql += "       SC5.C5_CONDPAG "
      cSql += "  FROM " + RetSqlName("SC6") + " SC6 (Nolock),"
      cSql += "       " + RetSqlName("SB1") + " SB1 (Nolock),"
      cSql += "       " + RetSqlName("SC5") + " SC5 (Nolock) "
      cSql += "  WHERE SC6.C6_FILIAL  = '" + Alltrim(K_Filial) + "'"
      cSql += "    AND SC6.C6_NUM     = '" + Alltrim(K_Pedido) + "'"
      cSql += "    AND SC6.C6_TES IN ('766')"
      cSql += "    AND SC6.D_E_L_E_T_ = ''"
      cSql += "    AND SB1.B1_COD     = SC6.C6_PRODUTO"
      cSql += "    AND SB1.D_E_L_E_T_ = ''"
	  cSql += "	   AND SC5.C5_FILIAL  = SC6.C6_FILIAL"
	  cSql += "	   AND SC5.C5_NUM     = SC6.C6_NUM"
	  cSql += "	   AND SC5.D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

      T_PRODUTOS->( DbGoTop() )
   
      WHILE !T_PRODUTOS->( EOF() )

         // ###################################
         // Inclui o registro na tabelqa SC9 ##
         // ###################################
         dbSelectArea("SC9")
         RecLock("SC9",.T.)
         SC9->C9_FILIAL	 := T_PRODUTOS->C6_FILIAL
         SC9->C9_PEDIDO	 := T_PRODUTOS->C6_NUM
         SC9->C9_ITEM	 := T_PRODUTOS->C6_ITEM
         SC9->C9_CLIENTE := T_PRODUTOS->C6_CLI
         SC9->C9_LOJA	 := T_PRODUTOS->C6_LOJA
         SC9->C9_PRODUTO := T_PRODUTOS->C6_PRODUTO
         SC9->C9_QTDLIB	 := T_PRODUTOS->C6_QTDVEN
         SC9->C9_DATALIB := Date()
         SC9->C9_SEQUEN	 := "01"
         SC9->C9_GRUPO	 := T_PRODUTOS->B1_GRUPO
         SC9->C9_PRCVEN	 := T_PRODUTOS->C6_PRCVEN
         SC9->C9_AGREG	 := T_PRODUTOS->C5_CONDPAG
         SC9->C9_LOCAL	 := T_PRODUTOS->C6_LOCAL
         SC9->C9_TPCARGA := "2"
         SC9->C9_RETOPER := "2"
         SC9->C9_TPOP	 := "1"
         SC9->C9_DATENT	 := Date()
         MsUnLock()

         // ###########################################################
         // Altera o Stataus do produto nos itens do pedido de venda ##
         // ###########################################################
         dbSelectArea("SC6")
         DBSetOrder(1)
         DbSeek ( T_PRODUTOS->C6_FILIAL + T_PRODUTOS->C6_NUM + T_PRODUTOS->C6_ITEM + T_PRODUTOS->C6_PRODUTO)
         RecLock("SC6",.F.)
   	     SC6->C6_STATUS := "10"
         MsUnLock()
      
         // #####################################################################
         // Atualiza o campo C5_LIBEROK para liberar o pedido de Intermedia��o ##
         // #####################################################################
         dbSelectArea("SC5")
         DBSetOrder(1)
         DbSeek ( T_PRODUTOS->C6_FILIAL + T_PRODUTOS->C6_NUM )
         RecLock("SC5",.F.)
  	     SC5->C5_LIBEROK := "S"
         MsUnLock()

         // ##############################################################  
         // Atualiza a tabela ZZ0 (Tabela de Status de Pedido de Venda) ##
         // ##############################################################
         U_GrvLogSts(xFilial("SC6"),SC6->C6_NUM, SC6->C6_ITEM, "10", "AUTOM618 (TES 766: DEV TROCA GARANTIA)") // Gravo o log de atualiza��o de status na tabela ZZ0

         T_PRODUTOS->( DbSkip() )
      
      Enddo   
      
   Endif   

Return(.T.)