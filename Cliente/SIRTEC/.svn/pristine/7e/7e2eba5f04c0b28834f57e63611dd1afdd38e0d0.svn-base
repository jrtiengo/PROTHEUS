/*
 * Ponto de entrada após a alteração 
 */

user function MNTA470C    
	
	dbselectArea("AA1")
	dbOrdernickName("CODBEM")
	IF dbseek(xFilial("AA1")+M->TPN_CODBEM)
		
		reclock("AA1", .F.)
			AA1->AA1_CC := M->TPN_CCUSTO
		msunlock()
	ENDIF 

return 