#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MTA650AlT
PE usado para carregar os campos que serão Alterados na tela de OP.
@type function
@version 
@author Jorge Alberto - Solutio
@since 03/08/2020
@return array, Array com os demais campos que poderão ser alterados pelo usuário.
/*/
User Function MTA650AlT()

    Local aCampos := PARAMIXB[1]

    AADD( aCampos, "C2_HORAJI"  )
    AADD( aCampos, "C2_RECURSO" )

Return( aCampos )
