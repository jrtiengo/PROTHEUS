#INCLUDE "protheus.ch"
/*
Jean Rehermann | JPC - 18/06/2011 - Ponto de entrada M460FIM
Ponto de entrada após a gravação dos documentos de saída e fora da transação
*/

Static Function M460FIM()

	// Jean Rehermann | JPC - 18/06/2011 - Programa que efetua a criação de pedido de vendas de comissão quando o pedido referente a este faturamento
	// for do tipo externo (pedido de intermediação) referente à tarefa #1065 do portfólio.
	U_AUTA004()

Return( Nil )