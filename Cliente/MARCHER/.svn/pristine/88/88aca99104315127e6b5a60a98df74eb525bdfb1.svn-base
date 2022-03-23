#INCLUDE "Protheus.ch"

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CM010BUT  ºAutor  ³MarcioQuevedoBorges º Data ³ 10/10/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Adiciona botão na Rotina de Tabela de Preço para importar  º±±
±±º          ³ preços dos fornecedores.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ COMA010 - Cadatro de Tabela de Preço                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CM010BUT()
Local aButtons := {}
	If ExistBlock( "MARR004" ) .and. (INCLUI .or. ALTERA)
		aAdd( aButtons, { 'COMPREL', {|| ExecBlock('MARR004',.F.,.F.,{M->AIA_CODFOR,M->AIA_LOJFOR,M->AIA_CODTAB,M->AIA_CONDPAG}) }, 'Importa/Atualiza Tab.Preço', 'Importa/Atualiza Tab.Preço' } )
		//aAdd( aButtons, {"Liberar Tabela",{|| u_LibAIA() }, "Liberar Tabela "  , "Liberar Tabela " })
		
	Endif
	//aadd(aButtons,{'BUDGETY',{|| U_MyProgram()},'Botao 1','But1'})
	//aadd(aButtons,{ 'NOTE'      ,{||  U_Myprogram2()},'Botao 2','But2' } )
Return  aButtons