#include 'protheus.ch'


/*/{Protheus.doc} MDTA6955
//Ponto de entrada para gravação de campos específicos na
@author Celso Rene
@since 29/01/2019
@version 1.0
@type function
/*/
User Function MDTA6955()

/*If ( Funname() == "U_XZNF" )
	
	dbSelectARea("ZNF")
	RecLock("ZNF", .F.)
	ZNF->ZNF_NUMSA  := cNumSA 
	ZNF->ZNF_ITEMSA := StrZero(nItemSA,2)
	ZNF->(MsUnLock())
	
	dbSelectARea("TNF")
	RecLock("TNF", .F.)
	TNF->TNF_ZNF := ZNF->ZNF_NUM
	TNF->(MsUnLock())
	
EndIf*/
	
Return()
