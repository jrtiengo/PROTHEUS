#Include 'Protheus.ch'

User Function CN120NAT()

Local cFilial := PARAMIXB[1]

Local cNumMed := PARAMIXB[2]

Local cRetNat := ""


 dbSelectArea("CNB")
	dbSetOrder(1)          
	dbSeek(CND->(CND_FILIAL+CND_CONTRA+CND_REVISA+CND_NUMERO),.T. )

	cRetNat:=CNB->CNB_NATURE 
	
 
Return cRetNat