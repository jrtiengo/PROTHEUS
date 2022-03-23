#INCLUDE "Protheus.ch"

/*/{Protheus.doc} MT131FIL
//TODO ROTINA DE FILTRO GERAÇÃO DE COTAÇÃO 
@author Márcio Borges
@since 23/10/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function MT131FIL()

Local aFiltroSC1 := {}
			
	aAdd(aFiltroSC1,"") //Filtro ADVPL C1_FILIAL >= '  '
	aAdd(aFiltroSC1,"C1_PRODUTO IN (SELECT B1_COD FROM " + RetSqlName("SB1") + " B1 WHERE B1_FILIAL = '"+ xFilial("SB1")+"' AND B1.D_E_L_E_T_ <> '*' AND  B1_PROC = '"+ CriaVar("B1_PROC")+"')") //Filtro em SQL
	//Alert ('Ponto de Entrada MT131FIL') //Valida??es do usu¨¢rio

Return aFiltroSC1