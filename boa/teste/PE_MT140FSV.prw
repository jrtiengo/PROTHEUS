#include "Protheus.ch"

/*/{Protheus.doc} MT140FSV
description Implemento no filtro da query do fonte MATA140I
@type function
@version  V 1.0
@author Marcio Martins / Mariana Cardoso / Wagner Nunes
@since 8/20/2024
@return variant, return_description
/*/

User Function MT140FSV() 

    Local cCodServ := ParamIXB[1]
    Local cRet := ""

    cRet := " OR A5_CODPRF = '" + cCodServ + "' "
    
Return cRet
