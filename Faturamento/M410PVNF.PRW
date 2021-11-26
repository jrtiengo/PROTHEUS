#include 'protheus.ch'

/*{Protheus.doc}
@Objetivo PE Validação No campo C5_DATA1 e C5_EMISSAO
@author Junior Tiengo
@since 2909;2021
@version 1.0
@type function/*/

user function M410PVNF()

Local lret  := .T.
Local dVenc1 := SC5->C5_DATA1
Local dVenc2 := SC5->C5_DATA2
Local dVenc3 := SC5->C5_DATA3
Local dVenc4 := SC5->C5_DATA4
//Local dVenc5 := SC5->C5_DATA5
//Local dVenc6 := SC5->C5_DATA6
//Local dVenc7 := SC5->C5_DATA7
//Local dVenc8 := SC5->C5_DATA8
//Local dVenc9 := SC5->C5_DATA9
Local dEmis  := Database()
Local cMsg   := ''

    If !empty(dVenc1) .And. (dVenc1 < dEmis)
        cMsg	+= ' Vencimento1, '
		lret	:= .F.
	EndIf
    
    If !empty(dVenc2) .And. (dVenc2 < dEmis)
        cMsg	+= ' Vencimento2, '
		lret	:= .F.
	EndIf

    If !empty(dVenc3) .And. (dVenc3 < dEmis)
        cMsg	+= ' Vencimento3, '
		lret	:= .F.
	EndIf

    If !empty(dVenc4) .And. (dVenc4 < dEmis)
        cMsg	+= ' Vencimento4, '
		lret	:= .F.
	EndIf
/*
    If !empty(dVenc5) .And. (dVenc5 < dEmis)
        cMsg	+= ' Vencimento5, '
		lret	:= .F.
	EndIf

    If !empty(dVenc6) .And. (dVenc6 < dEmis)
        cMsg	+= ' Vencimento6, '
		lret	:= .F.
	EndIf

    If !empty(dVenc7) .And. (dVenc7 < dEmis)
        cMsg	+= ' Vencimento7, '
		lret	:= .F.
	EndIf

    If !empty(dVenc8) .And. (dVenc8 < dEmis)
        cMsg	+= ' Vencimento8, '
		lret	:= .F.
	EndIf

    If !empty(dVenc9) .And. (dVenc9 < dEmis)
        cMsg	+= ' Vencimento9, '
		lret	:= .F.
	EndIf
    */
    
    If !lret
        MsgAlert("Data de Vencimento Menor que a Data de Emissão! Campos:" + cMsg, "Vencimento de Títulos")
    ENDIF

return (lret)
