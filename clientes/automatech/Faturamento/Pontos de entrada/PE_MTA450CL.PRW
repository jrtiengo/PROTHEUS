#INCLUDE "protheus.ch"

/* Jean Rehermann | JPC - 26/09/2011
Ponto de entrada MTA450CL - Liberação de crédito
Ponto de entrada na liberação de crédito por cliente quando tipo de liberação for por pedido (C5_TPLIB = 2)
*/
User Function MTA450CL()
	
	Local aItens := Paramixb[ 2 ]
	Local aAreaSC6 := SC6->( GetArea() )
	Local aAreaSC9 := SC9->( GetArea() )

   U_AUTOM628("PE_MTA450CL")
	
	If Len( aItens ) > 0
	
		For nX := 1 To Len( aItens )
		
			dbSelectArea("SC6")
			dbGoTo( aItens[ nX ] )
			
			U_GravaSts("PE_MTA450CL")
			
		Next
		
	EndIf
	
	RestArea(aAreaSC9)
	RestArea(aAreaSC6)
	
Return()