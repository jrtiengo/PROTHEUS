#include "rwmake.ch"
#include "protheus.ch"
/*=================================================================================================
* Função.....: MTA440C9.PRW  -  chamado pelo MATA440 - Liberacao de Pedidos
* Descricao..: - Ponto de Entrada chamado pela funcao MaGravaSC9() que esta no FATXFUN.PRX
*            :   customizados do SC5 que poderão ser alterados nesta tela.
* Autor......: Cesar Mussi
* Data.......: Abril/2011
*--------------------------------------------------------------------------------------------------
* Autor      |   Data   | Alteracao
*------------|----------|--------------------------------------------------------------------------
*            |          |
*================================================================================================*/

User Function MTA440C9()

   Local aAreaIni := GetArea()
   Local aAreaSC5 := SC5->(GetArea())
   Local aAreaSC6 := SC6->(GetArea())
   Local aAreaSF4 := SF4->(GetArea())
   Local lServ    := .f.
   Local _cNum    := SC9->C9_PEDIDO
   Local _cItem   := SC9->C9_ITEM

   U_AUTOM628("PEMATA440")
   
   DbSelectArea("SC5")
   DbSetOrder(1)  //C5_FILIAL+C5_NUM
   
   If DbSeek(xFilial("SC5")+_cNum)
	  
	  If SC5->C5_Tipo $ "N"
		 
		 DbSelectArea("SC6")
		 DbSetOrder(1)  //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		 DbSeek(xFilial("SC6")+_cNum+_cItem)

		 IF alltrim(SC6->C6_CF) $ "5933|6933"
			lServ := .t.
		 ENDIF

		 DbSelectArea("SF4")
		 DbSetOrder(1)  //F4_FILIAL+F4_CODIGO
		
		 If DbSeek(xFilial("SF4")+SC6->C6_TES)
			
			If "S" $ SF4->F4_Estoque   // Tes atualiza estoque
			   // ###################################################################################
			   // Neste ponto de entrada o SC9 esta posicionado e o registro corrente esta em lock ##
			   // ###################################################################################
			   SC9->C9_BlEst := '03'
			   SC9->C9_BlWms := '05'
			Else
			   If lServ
                  // ######################################################################################################################
				  // Em razão da implantação da nota fiscal de serviço eletrônica em 27/02/2015, esta variável não deve mais ser         ##
				  // preenchida com o conteúdo SRV. Esta determinação foi aprovada via e-mail recebido da Contratoladoria em 27/02/2015. ##
				  // SC9->C9_AGREG := "SRV" //Comentado Michel Aoki - Não haverá mais quebra da nota em serviço e produto.               ##
                  // ######################################################################################################################
				  SC9->C9_AGREG := ""
			   Endif
			EndIf

		 EndIf

 	  EndIf

   EndIf

   RestArea(aAreaSF4)
   RestArea(aAreaSC6)
   RestArea(aAreaSC5)
   RestArea(aAreaIni)

Return