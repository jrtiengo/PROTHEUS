#INCLUDE "Protheus.ch"

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐?
北篜rograma  矯M010BUT  篈utor  矼arcioQuevedoBorges ? Data ? 10/10/2018  罕?
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡?
北篋esc.     ? Adiciona bot鉶 na Rotina de Tabela de Pre鏾 para importar  罕?
北?          ? pre鏾s dos fornecedores.                                   罕?
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡?
北篣so       ? COMA010 - Cadatro de Tabela de Pre鏾                       罕?
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急?
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北?
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌?
*/
User Function CM010BUT()
Local aButtons := {}
	If ExistBlock( "MARR004" ) .and. (INCLUI .or. ALTERA)
		aAdd( aButtons, { 'COMPREL', {|| ExecBlock('MARR004',.F.,.F.,{M->AIA_CODFOR,M->AIA_LOJFOR,M->AIA_CODTAB,M->AIA_CONDPAG}) }, 'Importa/Atualiza Tab.Pre鏾', 'Importa/Atualiza Tab.Pre鏾' } )
		//aAdd( aButtons, {"Liberar Tabela",{|| u_LibAIA() }, "Liberar Tabela "  , "Liberar Tabela " })
		
	Endif
	//aadd(aButtons,{'BUDGETY',{|| U_MyProgram()},'Botao 1','But1'})
	//aadd(aButtons,{ 'NOTE'      ,{||  U_Myprogram2()},'Botao 2','But2' } )
Return  aButtons