#include 'protheus.ch' 

// ######################################################################################### 
// Projeto: Comissões 
// Modulo : Financeiro 
// Fonte  : PE_M410PVNF.prw 
// -----------+-------------------+--------------------------------------------------------- 
// Data       | Autor             | Descricao 
// -----------+-------------------+--------------------------------------------------------- 
// 03/10/2017 | Jorge Alberto     | Criado o PE para inicializar a variável que será utili- 
//            |                   | zada no PE FA440VLD().  
// -----------+-------------------+--------------------------------------------------------- 
User Function M410PVNF() 

	// Array será utilizado no PE FA440VLD 
	Public aBaixaSE1 := {} 

Return( .T. ) 