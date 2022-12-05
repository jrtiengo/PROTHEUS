#INCLUDE "protheus.ch"

User Function AUTA800

	Private cString := "EL0"

    U_AUTOM628("AUTA800")
   	
	dbSelectArea("EL0")
	dbSetOrder(1)
	
	AxCadastro(cString,"Cadastro de Alíquotas NCM",.T.,.T.)

Return
