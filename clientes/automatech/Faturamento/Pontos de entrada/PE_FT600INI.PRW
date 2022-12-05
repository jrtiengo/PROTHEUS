#INCLUDE "protheus.ch"

// Ponto de entrada para ativar a tecla F11 na tela do da proposta de venda

User Function FT600INI()

public aRotina := {	{ "Pesquisar"	,"AxPesqui"		,0,1,0,.F.},; //"Pesquisar"
						{ "Visualizar"	,"A600Mnt"		,0,2,,.T.},;  //"Visualizar"
						{ "Incluir"  	,"A600Mnt"		,0,3,,.T.},;  //"Incluir"
						{ "Alterar"	    ,"A600Mnt"		,0,4,,.T.},;  //"Alterar"
						{ "Impressao"	,"A600Impr"		,0,5,,.T.},;  //"Impressao"
						{ "Legenda" 	,"A600Lgd"		,0,2,,.T.} }  //"Legenda"

	If RetCodUsr() $ "000000"
		SetKey( VK_F11, { || Iif( "ADZ" $ AllTrim( ReadVar() ), U_MargemBut(2), ) } )
    EndIf

    U_AUTOM628("PE_FT600INI")

Return