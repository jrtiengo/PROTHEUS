#INCLUDE "protheus.ch"

/*
Jean rehermann - 08/04/2011
Ponto de entrada para adicionar bot�es na enchoice bar da oportunidade de venda
*/
User Function FT300BUT()

	
	Local aBotao := {}

    U_AUTOM628("PE_FT300BUT")

// Em fun��o do c�lculo do Diferencial de Al�quota de ICMS, esta op��o teve que ser retirada daqui e foi colocada dentro das
// A��es Relacionadas da Proposta Comercial.(Para o c�lculo do diferencial, � necess�rio que o aCols  da  Proposta Comercial 
// esteja ativo.)
//  AAdd( aBotao, { "PRODUTO", { || U_AUTA001() }, "Impr.Prop.Venda" } )

	AAdd( aBotao, { "PRODUTO", { || U_AUTOMR60() }, "Contatos", "Contatos" } )
	AAdd( aBotao, { "PRODUTO", { || U_AUTOMR61( M->AD1_CODCLI, M->AD1_LOJCLI ) }, "V�nculo Cliente X Contatos", "V�nculo Cliente X Contatos" } )   
	AAdd( aBotao, { "PRODUTO", { || U_AUTOMR80( M->AD1_FILIAL, M->AD1_NROPOR ) }, "Tracker Automatech", "Tracker Automatech" } )   
	AAdd( aBotao, { "PRODUTO", { || U_AUTOMR83( M->AD1_FILIAL, M->AD1_NROPOR ) }, "Observa��es", "Observa��es" } )   
	AAdd( aBotao, { "PRODUTO", { || U_AUTOM125( M->AD1_FILIAL, M->AD1_NROPOR ) }, "Solicita��o de Reservas", "Solicita��o de Reservas" } )   

//  Saiu devido ao novo c�lculo do diferencial de aliquota
//	AAdd( aBotao, { "PRODUTO", { || U_AUTOM169( M->AD1_FILIAL, M->AD1_NROPOR, M->AD1_CODCLI, M->AD1_LOJCLI ) }, "Totais Proposta Comercial", "Totais Proposta Comercial" } )   
	
Return( aBotao )