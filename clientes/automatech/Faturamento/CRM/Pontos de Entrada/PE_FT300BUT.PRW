#INCLUDE "protheus.ch"

/*
Jean rehermann - 08/04/2011
Ponto de entrada para adicionar botões na enchoice bar da oportunidade de venda
*/
User Function FT300BUT()

	
	Local aBotao := {}

    U_AUTOM628("PE_FT300BUT")

// Em função do cálculo do Diferencial de Alíquota de ICMS, esta opção teve que ser retirada daqui e foi colocada dentro das
// Ações Relacionadas da Proposta Comercial.(Para o cálculo do diferencial, é necessário que o aCols  da  Proposta Comercial 
// esteja ativo.)
//  AAdd( aBotao, { "PRODUTO", { || U_AUTA001() }, "Impr.Prop.Venda" } )

	AAdd( aBotao, { "PRODUTO", { || U_AUTOMR60() }, "Contatos", "Contatos" } )
	AAdd( aBotao, { "PRODUTO", { || U_AUTOMR61( M->AD1_CODCLI, M->AD1_LOJCLI ) }, "Vínculo Cliente X Contatos", "Vínculo Cliente X Contatos" } )   
	AAdd( aBotao, { "PRODUTO", { || U_AUTOMR80( M->AD1_FILIAL, M->AD1_NROPOR ) }, "Tracker Automatech", "Tracker Automatech" } )   
	AAdd( aBotao, { "PRODUTO", { || U_AUTOMR83( M->AD1_FILIAL, M->AD1_NROPOR ) }, "Observações", "Observações" } )   
	AAdd( aBotao, { "PRODUTO", { || U_AUTOM125( M->AD1_FILIAL, M->AD1_NROPOR ) }, "Solicitação de Reservas", "Solicitação de Reservas" } )   

//  Saiu devido ao novo cálculo do diferencial de aliquota
//	AAdd( aBotao, { "PRODUTO", { || U_AUTOM169( M->AD1_FILIAL, M->AD1_NROPOR, M->AD1_CODCLI, M->AD1_LOJCLI ) }, "Totais Proposta Comercial", "Totais Proposta Comercial" } )   
	
Return( aBotao )