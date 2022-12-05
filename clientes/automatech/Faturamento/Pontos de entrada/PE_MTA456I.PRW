#INCLUDE "PROTHEUS.CH"

/*
Jean Rehermann | JPC - 20/09/2011
Ponto de entrada MTA456I - Liberação de crédito / estoque
*/

User Function MTA456I()

   U_AUTOM628("PE_MTA456I")

	_aArea := GetArea()
	
	U_GravaSts("PE_MTA456I")
	
	RestArea( _aArea )

Return()