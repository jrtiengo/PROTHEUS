#Include "protheus.ch"

/*/{Protheus.doc} MA410COR
PE para substituir a avaliacao de credito padrao do sistema
@type classe
@version  1.0
@author tiengo
@since 28/09/2022
@return variant, null 
/*/

User Function MA410COR()

    Local aCoresPE := ParamIXB

    aAdd(aCoresPE, NIL)
    aIns(aCoresPE, 6)
    aCoresPE[06] := {"C5_BLQ == '6'", "BR_PRETO", "Bloqueio de Credito "}

Return aCoresPE
