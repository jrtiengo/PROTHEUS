#INCLUDE "PROTHEUS.CH"

/*
Jean Rehermann | JPC - 20/09/2011
Ponto de entrada MTA450I - Libera��o de cr�dito
Ponto de entrada na libera��o de cr�dito por Pedido e por cliente quando tipo de libera��o for por itens (C5_TPLIB = 1)
*/

User Function MTA450I()

Local _nOpcA := Paramixb[ 1 ]
Local _aArea := GetArea()

   U_AUTOM628("PE_MTA450I")

If _nOpcA == 1
	
	U_GravaSts("PE_MTA450I")
	
EndIf

RestArea( _aArea )
Return()

