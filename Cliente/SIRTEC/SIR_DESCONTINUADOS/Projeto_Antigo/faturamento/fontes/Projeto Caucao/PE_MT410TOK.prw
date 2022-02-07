#INCLUDE "Totvs.ch"

/*---------------------------------------------------------------------------
-----------------------------------------------------------------------------
|| Funcao    | MT410TOK | Autor | Gregory Araujo     | Data 12/02/2019     ||
||-------------------------------------------------------------------------||
|| Descricao | Ponto de entrada na geraÃ§Ã£o do pedido de venda para informar||
||           | sobre a condiÃ§Ã£o de pagamento.                              ||
||-------------------------------------------------------------------------||
|| Parametros|                                                             ||
||-------------------------------------------------------------------------||
|| Retorno   |                                                             ||
-----------------------------------------------------------------------------
---------------------------------------------------------------------------*/     
User Function MT410TOK()

	//Posiciona-se na tabela de condiÃ§Ãµes de pagamento, pois PE sÃ³ serÃ¡ executado para condiÃ§Ãµes do tipo 8.
	dbSelectArea("SE4")
	dbSetOrder(1)
	dbSeek(xFilial("SE4")+M->C5_CONDPAG)
	cCondTp := SE4->E4_TIPO
	 
	If cCondTp == '8'
		MsgInfo("A condição de pagamento utilizada irá gerar uma parcela de caução referente à 5% do valor total para a data final do contrato.",;
				"MT410TOK")
		
	EndIf
	
Return(.T.)