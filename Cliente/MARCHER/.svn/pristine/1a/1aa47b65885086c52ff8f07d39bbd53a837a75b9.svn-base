#INCLUDE "Protheus.ch"

// Indicará se o vendedor em questão deverá // ser considerado nos cálculos de // comissões do título em questão.
User Function F440VEND()

	Local cVendedor := ParamIXB[1]
	Local cTit := ParamIXB[2]
	Local lRet := .F.

	lRet := MsgYESNO("Confirma comissão do(a) vendedor(a): " + cVendedor + Chr(10) + Chr(13) +;
	 				 "para o título n° " + cTit + " ?")

Return lRet
