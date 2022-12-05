#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// #######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                ##
// ------------------------------------------------------------------------------------ ##
// Referencia: AUTOM664.PRW                                                             ##
// Parâmetros: Nenhum                                                                   ##
// Tipo......: (X) Programa  ( ) Gatilho ( ) Ponto de Entrada                           ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                  ##
// Data......: 27/12/2017                                                               ##
// Objetivo..: Programa que verifica se as TES do pedido de venda pertence ao parâmetro ##
//             que  indica  as  TES  que deverão ser direcionadas diretamente ao Status ##
//             10 - Aguardando Faturamento                                              ##
// Parâmetros: K_Filial -> Código da Filial do Pedido de Venda                          ##
//             K_Pedido -> Número do Pedido de Venda                                    ##
// #######################################################################################

User Function AUTOM664(K_Filial, K_Pedido)
 
   Local cSql := ""

   U_AUTOM628("AUTOM526")

   // ###########################################################################################################
   // Pesquisa as TES que possuem indicação de direcionamento direto para o Status 10 - Aguardando Faturamento ##
   // ###########################################################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_TFAT"
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   // ###############################################################
   // Pesquisa os produtos do pedido de venda passado no parâmetro ##
   // ###############################################################
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := "SELECT SC6.C6_FILIAL ,"
   cSql += "       SC6.C6_NUM    ,"
   cSql += "       SC6.C6_ITEM   ,"
   cSql += "  	   SC6.C6_ITEM   ,"
   cSql += "       SC6.C6_PRODUTO,"
   cSql += "       SC6.C6_CLI    ,"
   cSql += "       SC6.C6_LOJA   ,"
   cSql += "       SC6.C6_QTDVEN ,"
   cSql += "       SC6.C6_PRCVEN ,"
   cSql += "       SC6.C6_LOCAL  ,"
   cSql += "       SC6.C6_ENTREG ,"
   cSql += "       SB1.B1_GRUPO  ,"
   cSql += "       SC6.C6_TES    ,"
   cSql += "       SC5.C5_CONDPAG "
   cSql += "  FROM " + RetSqlName("SC6") + " SC6 (Nolock),"
   cSql += "       " + RetSqlName("SC5") + " SC5 (Nolock),"
   cSql += "       " + RetSqlName("SB1") + " SB1 (Nolock) "
   cSql += "  WHERE SC6.C6_FILIAL  = '" + Alltrim(K_Filial) + "'"
   cSql += "    AND SC6.C6_NUM     = '" + Alltrim(K_Pedido) + "'"
   cSql += "    AND SC6.D_E_L_E_T_ = ''            "
   cSql += "    AND SB1.B1_COD     = SC6.C6_PRODUTO"
   cSql += "    AND SB1.D_E_L_E_T_ = ''            "
   cSql += "    AND SC5.C5_FILIAL  = SC6.C6_FILIAL "
   cSql += "    AND SC5.C5_NUM     = SC6.C6_NUM    "
   cSql += "    AND SC5.D_E_L_E_T_ = ''            "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )
   
   T_PRODUTOS->( DbGoTop() )
   
   WHILE !T_PRODUTOS->( EOF() )
   
      If U_P_OCCURS(T_PARAMETROS->ZZ4_TFAT, T_PRODUTOS->C6_TES, 1) <> 0

         // ###################################
         // Inclui o registro na tabelqa SC9 ##
         // ###################################
         dbSelectArea("SC9")
         RecLock("SC9",.T.)
         C9_FILIAL	 := T_PRODUTOS->C6_FILIAL
         C9_PEDIDO	 := T_PRODUTOS->C6_NUM
         C9_ITEM	 := T_PRODUTOS->C6_ITEM
         C9_CLIENTE  := T_PRODUTOS->C6_CLI
         C9_LOJA	 := T_PRODUTOS->C6_LOJA
         C9_PRODUTO  := T_PRODUTOS->C6_PRODUTO
         C9_QTDLIB	 := T_PRODUTOS->C6_QTDVEN
         C9_DATALIB  := Date()
         C9_SEQUEN	 := "01"
         C9_GRUPO	 := T_PRODUTOS->B1_GRUPO
         C9_PRCVEN	 := T_PRODUTOS->C6_PRCVEN
         C9_AGREG	 := T_PRODUTOS->C5_CONDPAG
         C9_CODPG    := T_PRODUTOS->C5_CONDPAG
         C9_LOCAL	 := T_PRODUTOS->C6_LOCAL
         C9_TPCARGA  := "2"
         C9_RETOPER  := "2"
         C9_TPOP	 := "1"
         C9_DATENT	 := Date()
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
         // Atualiza o campo C5_LIBEROK para liberar o pedio de Intermediação ##
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
	     U_GrvLogSts(xFilial("SC6"),T_PRODUTOS->C6_NUM, T_PRODUTOS->C6_ITEM, "10", "AUTOM664")
	     
	  Endif

      T_PRODUTOS->( DbSkip() )
      
   ENDDO

Return(.T.)