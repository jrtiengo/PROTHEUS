#include "rwmake.ch"

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    � AUTG009  � Autor � Cesar Mussi           � Data � 06/07/11 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Recalcula o Custo Unitario atraves do Total / Qtde         潮�
北�          �                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � Gatilho no campo D1_TOTAUT                                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Sigaest                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/

// Criar o Campo D1_TOTAUT   N 14,2   VIRTUAL e colocar logo apos o capo D1_QUANT.
// Optamos por criar um campo novo e virtual por causa das novas validacoes do campos D1_TOTAL       


User Function AUTG009()

Local nUnitario, nQuant, nTotal

   U_AUTOM628("AUTG0093")

For i1 := 1 to Len(aHeader)
	If alltrim(aHeader[i1,2])     == "D1_TOTAL"
		nD1_TOTAL   := i1
	Elseif alltrim(aHeader[i1,2]) == "D1_TOTAUT"
		nD1_TOTAUT  := i1
	Elseif alltrim(aHeader[i1,2]) == "D1_VUNIT"
		nD1_VUNIT   := i1
	Elseif alltrim(aHeader[i1,2]) == "D1_QUANT"
		nD1_QUANT   := i1
    Endif
Next

If cTipo $ "NDB"
	aCols[n, nD1_VUNIT] := aCols[n, nD1_TOTAUT] / aCols[n, nD1_QUANT]
	MaFisRef("IT_PRCUNI","MT100",aCols[n, nD1_VUNIT])
	//MaFisRef("IT_PRCUNI","MT100",aCols[n, nD1_TOTAUT] / aCols[n, nD1_QUANT])
	MaFisRef("IT_VALMERC","MT100",aCols[n, nD1_TOTAUT])
	aCols[n, nD1_TOTAL] := aCols[n, nD1_TOTAUT]
EndIf

Return(aCols[n, nD1_VUNIT])