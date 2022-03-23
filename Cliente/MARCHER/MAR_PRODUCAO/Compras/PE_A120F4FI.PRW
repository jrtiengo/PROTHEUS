#INCLUDE "Protheus.ch"
/*
aRetArray
(vetor)
O retorno é um array contendo a seguinte estrutura:

1 - String - Filtro no SC1 para ISAM ( Sintaxe xBase ) 
2 - String - Filtro no SC1 para SQL ( Sintaxe SQL ) 
3 - String - Filtro no SC3 para ISAM ( Sintaxe xBase ) 
4 - String - Filtro no SC3 para SQL ( Sintaxe SQL ) 
Não é necessário definir todos os elementos do array.

Este ponto atua por Item, o PE_A120PIDF atua para importar todos os itens da SC 
*/

/*/{Protheus.doc} A120F4FI
//TODO Filtro SC's no pedido de compra por item
@author Phoenix
@since 11/12/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function  A120F4FI()  
	Local lFiltra := .F.
	Local aRetFiltro := nil


	If !Empty(CA120FORN)
		lFiltra :=MSGYESNO("Deseja Filtrar somente as SC's para o Fornecedor vigente?" ,"Filtro de SC's")
	Endif
	If lFiltra
		aRetFiltro := { ," C1_FORNECE = '" + CA120FORN + "'",,}
	Else
		////Sem filtro. � utilizado filtro com campo Filial pois ao entrar no PE e precisa retornar algo para a query
		//aRetFiltro := { ," C1_FILIAL = '" + xFilial("SC1") + "'",,} 
	Endif
Return( aRetFiltro )

