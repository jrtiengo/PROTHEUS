#INCLUDE "protheus.ch"
/*
Jean Rehermann | JPC - 18/06/2011 - Ponto de entrada M460FIM
Ponto de entrada ap�s a grava��o dos documentos de sa�da e fora da transa��o
*/

Static Function M460FIM()

	// Jean Rehermann | JPC - 18/06/2011 - Programa que efetua a cria��o de pedido de vendas de comiss�o quando o pedido referente a este faturamento
	// for do tipo externo (pedido de intermedia��o) referente � tarefa #1065 do portf�lio.
	U_AUTA004()

Return( Nil )