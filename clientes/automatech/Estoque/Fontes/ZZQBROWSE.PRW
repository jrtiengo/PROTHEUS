#INCLUDE "protheus.ch"

/*/
Jean Rehermann - Solutio IT - 25/07/2012 | Browse de Log de Separa��o
/*/
User Function ZZQBROWSE()

	Private cCadastro := "Log de Separa��o"
	Private cString := "ZZQ"
	Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
    			         {"Visualizar","AxVisual",0,2} }

	dbSelectArea("ZZQ")
	dbSetOrder(1)
	
	mBrowse( 6, 1, 22, 75, "ZZQ" )

Return
