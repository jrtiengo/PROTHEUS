#Include "Totvs.ch"

/*
-----------------------------------------------------------------------------
| Programa  | MA410LEG  | Autor | Call System           | Data | 29/05/2017 |
-----------------------------------------------------------------------------
| Desc.     | PE acionado para manutencao das legendas.                     |
-----------------------------------------------------------------------------
*/
User Function MA410LEG()
Local aLegenda := {}
If cEmpAnt == "01"
    aLegenda := {	{ "ENABLE",		"Pedido de Venda em aberto"},;		// Pedido em aberto
				    { "DISABLE",	"Pedido de Venda encerrado"},;	    // Pedido encerrado
				    { "BR_AMARELO",	"Pedido liberado"},;				// Pedido Liberado
				    { "BR_MARROM",	"Liberado para Expedição"},;
				    { "BR_PRETO",	"Liberado para Expedição e Pedido Aglutinador ainda não"},;
				    { "BR_LARANJA",	"Recepção/Expedição"},;
				    { "BR_AZUL",	"Em Separação"},;
	                { "BR_PINK",	"Liberado para Expedição porém Pendente"},;
					{ "BR_CINZA",   "PV Eliminado Residuo Por Completo"},;
	                { "BR_BRANCO",	"Aguardando faturamento"},;
					{ "BR_PRETO_1", "Aguardando Cancelamento"},;                                                 
					{ "BR_PRETO_2", "Cancelamento Autorizado"},;
					{ "BR_PRETO_3", "Cancelamento Negado"};
					}
EndIf

If cEmpAnt == "03"
    aLegenda := {	{ "ENABLE",		"Pedido de Venda em aberto"},;		// Pedido em aberto
				    { "BR_AMARELO",	"Pedido liberado"},;				// Pedido Liberado
	                { "BR_BRANCO",	"Aguardando Produção"},;            // Aguardando Producao
	                { "BR_PINK",	"Em Produção" },; 					// Em producao
	                { "PCOFXOK",	"Produção Finalizada" },; 			// Producao Finalizado
				    { "BR_MARROM",	"Liberado para Expedição"},;
				    { "BR_PRETO",	"Liberado para Expedição e Pedido Aglutinador ainda não"},;
				    { "BR_LARANJA",	"Recepção/Expedição"},;
				    { "BR_AZUL",	"Em Separação"},;
				    { "DISABLE",	"Pedido de Venda encerrado"} }	// Pedido encerrado
EndIf

Return aLegenda
