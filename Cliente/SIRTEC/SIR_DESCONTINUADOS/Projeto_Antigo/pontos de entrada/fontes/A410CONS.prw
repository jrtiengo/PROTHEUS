#include 'totvs.ch'


//� chamada no momento de montar a enchoicebar do pedido de vendas, e serve para incluir mais bot�es com rotinas de usu�rio.

User Function A410CONS()
	
	local aBotoes := {}	
	
	If ALTERA
		Aadd(aBotoes, {'PEDIDO',{||U_FB101FAT()}, "Complementar Produto"})
		Aadd(aBotoes, {'PEDIDO',{||U_FB103FAT()}, "Atualizar Dados OS"})		
	EndIf
	
	
Return(aBotoes)
