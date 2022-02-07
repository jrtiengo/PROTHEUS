#include 'totvs.ch'


/*/{Protheus.doc} STCGTSCP
//Rotina - Gatilho chamado no campo de Produto - SCP - Filtro
@author Gregory Araujo
@since 02/04/2019
@version 1.0
@type function
/*/
User Function STCGTSCP(cProduto, cEquip)
		
	dbSelectArea("AA1")
	dbSetOrder(1)
	If dbSeek(xFilial("AA1")+cEquip)
	
		dbSelectArea("ZZ4")
		dbSetOrder(1)
		If dbSeek(xFilial("ZZ4")+cEquip)
			
			dbSelectArea("ZZD")
			dbSetOrder(1)
			If dbSeek(xFilial("ZZD")+cEquip)
		 		cRet := "3"
		 	EndIf
		 	
		EndIf
		
	EndIF
	
Return(cRet)


