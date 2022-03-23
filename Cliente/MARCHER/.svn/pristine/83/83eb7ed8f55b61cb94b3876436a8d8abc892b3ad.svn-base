#INCLUDE "Protheus.ch"
/*
aRetArray
(vetor)
O retorno Ã© um array contendo a seguinte estrutura:

1 - String - Filtro no SC1 para ISAM ( Sintaxe xBase ) 
2 - String - Filtro no SC1 para SQL ( Sintaxe SQL ) 
3 - String - Filtro no SC3 para ISAM ( Sintaxe xBase ) 
4 - String - Filtro no SC3 para SQL ( Sintaxe SQL ) 
NÃ£o Ã© necessÃ¡rio definir todos os elementos do array.

Este PE atua no filtro de importação das SC's via F4, porém o PE_A120F4FI atua por item quando o produto foi digitado.
*/

/*/{Protheus.doc} A120PIDF
//TODO Filtro SC's no pedido de compra, chamado via F4'
@author Phoenix
@since 11/12/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function  A120PIDF()  
	Local lFiltra 	 := .F.
	Local aRetFiltro := nil
	Local cFilSC1 	 := 'C1_FILIAL == "'+xFilial('SC1')+'".And. C1_QUJE < C1_QUANT .And. C1_TPOP<>"P" .And. C1_APROV$" ,L" .And.( C1_COTACAO == "'+Space(Len(SC1->C1_COTACAO))+'" .Or. C1_COTACAO == "'+Replicate("X",Len(SC1->C1_COTACAO))+'") .And. C1_FLAGGCT <> "1"'

	If !Empty(CA120FORN)
		lFiltra :=MSGYESNO("Deseja Filtrar somente as SC's para o Fornecedor vigente?" ,"Filtro de SC's")
	Endif
	If lFiltra
		aRetFiltro := { cFilSC1 + " .and. C1_FORNECE = '" + CA120FORN + "'"}
	Else
		aRetFiltro := {cFilSC1} //filtro padrão
	Endif
Return( aRetFiltro )

