#INCLUDE "Totvs.ch"

/*---------------------------------------------------------------------------
-----------------------------------------------------------------------------
|| Funcao    | MT410TOK | Autor | Gregory Araujo     | Data 12/02/2019     ||
||-------------------------------------------------------------------------||
|| Descricao | Ponto de entrada na geração do pedido de venda para informar||
||           | sobre a condição de pagamento.                              ||
||-------------------------------------------------------------------------||
|| Parametros|                                                             ||
||-------------------------------------------------------------------------||
|| Retorno   |                                                             ||
-----------------------------------------------------------------------------
---------------------------------------------------------------------------*/     
User Function MT410TOK()

	//Posiciona-se na tabela de condições de pagamento, pois PE só será executado para condições do tipo 8.
	dbSelectArea("SE4")
	dbSetOrder(1)
	dbSeek(xFilial("SE4")+M->C5_CONDPAG)
	cCondTp := SE4->E4_TIPO
	 
	If cCondTp == '8'
		MsgInfo("A condi��o de pagamento utilizada ir� gerar uma parcela de cau��o referente � 5% do valor total para a data final do contrato.",;
				"MT410TOK")
		
	EndIf
	
Return(.T.)