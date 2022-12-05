#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � AUTG009  � Autor � Cesar Mussi           � Data � 06/07/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Recalcula o Custo Unitario atraves do Total / Qtde         ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Gatilho no campo D1_TOTAUT                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Sigaest                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
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