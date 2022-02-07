#Include 'Protheus.ch'
#Include "RWMAKE.CH"
#Include "TOPCONN.CH"
#include "tbiconn.ch"

/*/{Protheus.doc} GPE10BTN
PE para inclusão de rotina no menu.
@type function
@author Mauro Silva
@since 21/07/2021
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function GPE10BTN()

    Local aRet := {}
	
	aAdd( aRet, { "S4WB005N", {|| U_SIRA011(1) }, "Abre Arquivo Treinamento", "Abre Arquivo" } )
    aAdd( aRet, { "S4WB005N", {|| U_SIRA011(2) }, "Apaga Arquivo Treinamento", "Apaga Arquivo" } )

	
Return  (aRet)
