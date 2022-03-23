#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} METRICA1
Retorna certas métricas para os RATEIOS OFF-LINE
@type function
@version QUANTUM 1.0
@author cesar
@since 12/08/2020
@param cTipo, character, 'HORAS' retorna as SOMA das HORAS apontadas no CCusto <.cDest.> no mês de rateio
@                        'NOPS'  retorna a CONTAGEM de OPs apontadas no CCusto <.cDest.> no mês de rateio
@param cDest, character, param_description
@return return_type, return_description
/*/
User Function Metrica1( cTipo, cDest )

	Local aArea		:= GetArea()
	Local cAliAtu	:= Alias()
	Local nRet		:= 0
	Local cAnoMes	:= Right(Str(Year(dDataBase)),4)+StrZero(Month(dDataBase),2)
	Local cQuery	:= ""

	If cTipo == "HORAS"
		cQuery := " SELECT CAST(SUM(D3_QUANT) AS NUMERIC(8,2)) AS 'TOTAL' FROM "+RetSqlname("SD3")
		cQuery += "    WHERE D3_FILIAL = '"+xFilial("SD3")+"' AND LEFT(D3_EMISSAO,6) = '"+cAnoMes+"' "
		cQuery += "    AND D3_COD = 'MOD"+cDest+"' "
		cQuery += "    AND D_E_L_E_T_ = ' ' "
	ElseIf cTipo == "NOPS"
		cQuery := " SELECT COUNT(TAB.D3_OP) AS 'TOTAL' FROM ( "
		cQuery += " SELECT DISTINCT D3_OP  FROM "+RetSqlname("SD3")
		cQuery += "    WHERE D3_FILIAL = '"+xFilial("SD3")+"' AND LEFT(D3_EMISSAO,6) = '"+cAnoMes+"' "
		cQuery += "    AND D3_COD = 'MOD"+cDest+"' "
		cQuery += "    AND D_E_L_E_T_ = ' ' ) AS TAB"
	Endif
		
	If Select("TMPZ01") <>  0
		TMPZ01->(DbCloseArea())
	EndIf

	IF !Empty(cQuery)
		TcQuery cQuery New Alias "TMPZ01"
		DbSelectArea("TMPZ01")
		nRet := TMPZ01->TOTAL
		TMPZ01->(DbCloseArea())
	EndIf

	If !Empty(cAliAtu)
		DbSelectArea(cAliAtu)
	EndIf
	RestArea(aArea)

Return(nRet)
