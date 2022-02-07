#include "protheus.ch"

/*
-----------------------------------------------------------------------------------------------------------------------------------------------
Fun��o: MT150LOK

Autor: TOTVS

Data: 08/08/2009

Descri��o: Valida��o da linha na rotina de atualiza��o das cota��es MATA150

Par�mentos:

Retorno:
	- L�gico
-----------------------------------------------------------------------------------------------------------------------------------------------
*/

User function MT150LOK

Local lRet := .T.

//Valida se campo total foi preenchido
If GdFieldGet("C8_YTOT",n) <> "S" .and.  !((aCols[n,Len(aHeader)+1]))
	lRet := .F.
	MsgInfo("Tecle enter no campo TOTAL ITEM.","SIRTEC - MT150LOK")
EndIf

Return lRet 
