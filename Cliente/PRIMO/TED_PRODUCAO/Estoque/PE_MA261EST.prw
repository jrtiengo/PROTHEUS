/*/{Protheus.doc} MA261EST
Valida se pode ou não estornar Transferência Interna (SD3)
@type function
@version  
@author solutio
@since 17/05/2021
@param , param_type, param_description
@return return_type, return_description
/*/
User Function MA261EST( )
	//Local nX := ParamIXB[1]
	Local lRet := .T.//-- Validações adicionais do usuario
	Local cSql := ""
	local cTRB := GetNextAlias()


//Validação Etiqueta ACD
	If !FwIsInCallStack("U_XCADZZ1")
		cSql := " SELECT 1 AS FOUNDZZ1  FROM " + RetSqlName("ZZ1") + " WHERE ZZ1_FILIAL = '" + xFilial("ZZ1")+"' AND ZZ1_DOCSD3 = '" + SD3->D3_DOC + "' AND D_E_L_E_T_  <> '*'"

		MPSysOpenQuery( cSql, cTRB )

		IF !Empty((cTRB)->FOUNDZZ1)
			MsgAlert("Transferência feita com Etiqueta ACD. Utilize rotina de Romaneio(Expedição) para Excluir movimento. !","# Bloqueio de Estorno")
			lRet := .F.
		ENDIF

		(cTRB)->( DbCloseArea() )
	Endif

Return lRet
