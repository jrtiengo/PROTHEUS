#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
-------------------------------------------------------------------------------------------------------------------------------------------------
	Programa: STCP001

	Descrição: Cadastro de Pendências
	
	Data: 21/11/2008
	
	Parâmetros:
	
	Retorno:
	
	Uso: Sirtec -> Configurador
-------------------------------------------------------------------------------------------------------------------------------------------------
	Atualizações sofridas:
-------------------------------------------------------------------------------------------------------------------------------------------------
*/                    

User Function STCP001

Private cAlias    := "ZZA"
Private cCadastro := "Cadastro de Pendências"

// Array com os botões do Browse
Private aRotina   := {	{OemToAnsi("Pesquisar"),	"AxPesqui",		0, 1, 0, .F.},;
                     	{OemToAnsi("Visualizar"),	"AxVisual",		0, 2, 0, NIL},;
                     	{OemToAnsi("Incluir"),		"AxInclui",		0, 3, 0, NIL},;
						{OemToAnsi("Alterar"),		"AxAltera",		0, 4, 0, NIL},;
						{OemToAnsi("Excluir"), 		"AxDeleta",		0, 5, 0, NIL},;
						{OemToAnsi("Legenda"),		"U_STCP001A",	0, 2, 0, NIL}}

//Cores da legenda
Private aCores := {	{ "ZZA_STATUS == '1'", "BR_BRANCO"	 },; // Digitada    
					{ "ZZA_STATUS == '2'", "BR_VERDE"	 },; // Aprovada        
					{ "ZZA_STATUS == '3'", "BR_LARANJA"	 },; // Iniciada       
					{ "ZZA_STATUS == '4'", "BR_VERMELHO" },; // Encerrada       
					{ "ZZA_STATUS == '5'", "BR_AZUL"     },; // Aguardo         
					{ "ZZA_STATUS == '6'", "BR_PRETO"	 }}  // Rejeitada       

DbSelectArea(cAlias)
DbSetOrder(1)
DbGoTop()

mBrowse(6,1,22,75,cAlias,,,,,,aCores)

Return

/*
-------------------------------------------------------------------------------------------------------------------------------------------------
	Programa: STCP001A

	Descrição: Legenda do cadastro de pendências
	
	Data: 21/11/2008
	
	Parâmetros:
	
	Retorno:
	
	Uso: Sirtec -> Configurador
-------------------------------------------------------------------------------------------------------------------------------------------------
	Atualizações sofridas:
-------------------------------------------------------------------------------------------------------------------------------------------------
*/                    

User Function STCP001A

BrwLegenda("Status da pendência","Pendência:",{{ "BR_BRANCO"   , "Digitada" },;  
                                               { "BR_VERDE"    , "Aprovada" },;  
                                               { "BR_LARANJA"  , "Iniciada" },;  
                                               { "BR_VERMELHO" , "Encerrada"},;  
                                               { "BR_AZUL"     , "Aguardo"  },;  
                                               { "BR_PRETO"    , "Rejeitada"}})  
Return