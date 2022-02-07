#include "protheus.ch"

/*
-----------------------------------------------------------------------------------------------------------------------------------------------
Função: MT150LOK

Autor: TOTVS

Data: 08/08/2009

Descrição: Validação da linha na rotina de atualização das cotações MATA150

Parâmentos:

Retorno:
	- Lógico
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
