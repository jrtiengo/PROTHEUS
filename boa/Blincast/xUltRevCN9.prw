#Include "totvs.ch"
#Include "TopConn.ch"
#Include "TBIConn.ch"
#Include "Protheus.ch"

/*/{Protheus.doc} Ultrevcn9
description Busca a ultima revisão do contrato
@type function
@version  
@author Tiengo Junior
@since 11/10/2025
@return variant, return_description
/*/
User Function Ultrevcn9(cNRental)

	Local cQuery		:= ""
	Local cAlias		:= ""
	Local aRet          := {}

	cQuery := " SELECT CN9_NUMERO, NVL(MAX(CN9_REVISA),'   ') REVISA	"
	cQuery += " FROM "+ RetSqlName("CN9") + " CN9 						"
	cQuery += " WHERE  AND D_E_L_E_T_ = ''  							"
	cQuery += " AND CN9_XRENTA = '"+cNRental+"' 						"

	cQuery := ChangeQuery(cQuery)
	cAlias := MPSysOpenQuery(cQuery)

	If (cAlias)->(!EoF())
		aRet := {(cAlias)->CN9_NUMERO, IIf(Empty(AllTrim((cAlias)->REVISA)), "", AllTrim((cAlias)->REVISA))}
	EndIf

	(cAlias)->(DbCloseArea())

Return(aRet)
