#Include "Protheus.ch"
#INCLUDE "jpeg.ch"    
#Include "restful.ch"
#Include "totvs.ch"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"

// #####################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                              ##
// ---------------------------------------------------------------------------------- ##
// Referencia: AUTOM577.PRW                                                           ##
// Par�metros: Nenhum                                                                 ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                        ##
// ---------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                                ##
// Data......: 24/01/2012                                                             ##
// Objetivo..: Jean Rehermann | SOLUTIO - 24/01/2012 - Delecao apos retirar amarracao ##
//             PV x OP Registro SC6 selecionado e posicionado, mas sem lock.          ##
//             Posicionar no SC5 e no SC9, salvar e restaurar as areas.               ##
// Altera��es:                                                                        ##
// Tarefa #2789 - Alterar Status do Pedido de Venda para 01 - Aguardando Libera��o de ##
//                Pedido de Venda sempre quando uma ordem de produ��o vinculada a  PV ##
//                for exclu�da. Este processo foi necess�rio  em  raz�o das RESERVAS, ##
//                ou seja, para que o padr�o do Protheus possa gerenciar corretamente ##
//                as Reservas, � necess�rio que o mesmo volte ao status inicial.      ## 
// #####################################################################################

User Function MA650DC6()

   // ######################################################################################
   // Harald Hans L�schenkohl - 17/01/2018 - 11:51                                        ##
   // O trexo do programa abaixo foi comentado porque este � o processo que era executado ##
   // antes da altera��o da taerfa #2789.                                                 ##
   // N�o apagar pois isso dever� ficar como hist�rico.                                   ##
   // ######################################################################################
   //                                                                                     ##
   //   U_AUTOM628("PE_MA650DC6")                                                         ##
   //                                                                                     ##
   //   _aArea := GetArea()                                                               ##
   //   	                                                                              ##
   //   dbSelectArea("SC5")                                                               ##
   //   dbSetOrder(1)                                                                     ##
   //                                                                                     ##
   //   If dbSeek( SC6->C6_FILIAL + SC6->C6_NUM )                                         ##
   //      dbSelectArea("SC9")                                                            ##
   //      dbSetOrder(1)                                                                  ##
   //      If dbSeek( SC6->C6_FILIAL + SC6->C6_NUM + SC6->C6_ITEM )                       ##
   //         RecLock("SC6", .F.)                                                         ##
   //   	     U_GravaSts("PE_MA650DC6")                                                ## 
   //   	     MsUnLock()                                                               ##
   //      EndIf                                                                          ##
   //   EndIf                                                                             ##
   //   	                                                                              ## 
   //   RestArea( _aArea )                                                                ##
   // ######################################################################################

   U_AUTOM628("PE_MA650DC6")

   _aArea := GetArea()
	
   // ######################################
   // Guarda a Filial e o Pedido de Venda ##
   // ######################################
   kFilial  := SC6->C6_FILIAL
   kPedido  := SC6->C6_NUM
   kProduto := SC6->C6_PRODUTO
   kItemPV  := SC6->C6_ITEM

   // #############################################################################################
   // Da mensagem ao usu�rio informando que o pedido de venda ser� aberto para acertar a reserva ##
   // #############################################################################################
   If Empty(Alltrim(kPedido))
   Else
      MsgAlert("ATEN��O!"                                                             + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Esta Ordem de Produ��o est� vinculada ao Pedido de Venda n� "         + Alltrim(kPedido) + chr(13)  + chr(10) + ;
               "No final da exclus�o desta OP, voc� dever� alterar o Pedido de Venda" + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "e selecionar o bot�o CONFIRMA para que o  c�lculo  da  Reserva  seja" + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "recalculado e libere-o corretamente.") 
   Endif
   
   // #######################################
   // Limpa o conte�do do campo C5_LIBEROK ##
   // #######################################
   dbSelectArea("SC5")
   dbSetOrder(1)
 
   If dbSeek( kFilial + kPedido )

	  RecLock("SC5", .F.)
      SC5->C5_LIBEROK := ""
	  MsUnLock()

   Endif
   
   // ##############################################################################
   // Altera o Status do campo C6_STATUS para 01 - Aguardando Libera��o de Pedido ##
   // ##############################################################################
   dbSelectArea("SC6")
   dbSetOrder(1)
 
   If DbSeek( kFilial + kPedido + kItemPV + kProduto)

      RecLock("SC6", .F.)
      SC6->C6_STATUS := "01"
	  MsUnLock()

      // ########################################################
      // Atualiza o log de atualiza��o de status na tabela ZZ0 ##
      // ########################################################
      U_GrvLogSts( kFilial, kPedido, kItemPV, "01", "PE_MA650DC6", 0 )

   Endif   

   // ####################################################################
   // Elimina os lan�amentos da tabela SC9 referente ao pedido de venda ##
   // ####################################################################
   dbSelectArea("SC9")
   dbSetOrder(1)
	  
   If DbSeek( kFilial + kPedido + kItemPV)

	  RecLock("SC9",.F.)
      SC9->C9_BLEST  := ""
      SC9->C9_BLCRED := ""
	  MsUnLock()

   EndIf
	
   RestArea( _aArea )
   
   // ################################################################################################
   // Abre o pedido de venda permitindo o usu�rio gravar o pedido para acertar o c�lculo da Reserva ##
   // ################################################################################################
   If Empty(Alltrim(kPedido))
   Else
//      xAbrePVPAR(kFilial, kPedido)
   Endif   

Return(.T.)

// ###################################################
// Fun��o que abre o pedido de venda para aletra��o ##
// ###################################################
Static Function xAbrePVPAR(kFilial, kPedido)

   Local aArea       := GetArea() //Irei gravar a are3a atual

   Private Inclui    := .F.
   Private Altera    := .T.
   Private VISUAL    := .F.
   Private nOpca     := 1                  
   Private cCadastro := "Pedido de Vendas" 
   Private aRotina   := {}                 

   // #################################################
   // Posiciona o pedido a ser aberto para altera��o ##
   // #################################################
   DbSelectArea("SC5")
   DbSetorder(1)
   If DbSeek(Substr(kFilial,01,02) + kPedido)
  	  MatA410(Nil, Nil, Nil, Nil, "A410Altera")
   Endif

   RestArea(aArea)

Return(.T.)