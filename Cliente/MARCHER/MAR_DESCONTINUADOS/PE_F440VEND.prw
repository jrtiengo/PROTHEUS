#INCLUDE "Protheus.ch"

// Indicar� se o vendedor em quest�o dever� // ser considerado nos c�lculos de // comiss�es do t�tulo em quest�o.
User Function F440VEND()

	Local cVendedor := ParamIXB[1]
	Local cTit := ParamIXB[2]
	Local lRet := .F.

	lRet := MsgYESNO("Confirma comiss�o do(a) vendedor(a): " + cVendedor + Chr(10) + Chr(13) +;
	 				 "para o t�tulo n� " + cTit + " ?")

Return lRet
