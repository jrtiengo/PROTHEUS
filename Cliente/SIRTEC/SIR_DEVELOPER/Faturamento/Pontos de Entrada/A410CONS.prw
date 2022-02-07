#include 'totvs.ch'


//É chamada no momento de montar a enchoicebar do pedido de vendas, e serve para incluir mais botões com rotinas de usuário.

User Function A410CONS()
	
	local aBotoes := {}	
	
	If ALTERA
		Aadd(aBotoes, {'PEDIDO',{||U_FB101FAT()}, "Complementar Produto"})
		Aadd(aBotoes, {'PEDIDO',{||U_FB103FAT()}, "Atualizar Dados OS"})		
	EndIf
	
	
Return(aBotoes)
