#Include 'Protheus.ch'
#Include "Tbiconn.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} ACERTA774
Reprocessa base e valor da verba 774 da tabela SRR, para o ano/mes 2019/02.
@type function
@author Mauro Silva
@since 01/03/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

User Function ACERTA774()

	Local cQuery	:= {}
	Local cData		:= "201902" // Período da folha.
	Local cVerb1	:= "701"	// Verba 1.
	Local cVerb2	:= "702"	// Verba 2.
	Local cVerb3	:= "774"	// Verba a ser atualizado o valor.
	Local nPerc		:= 0.032466	// Percentual a ser aplicado nos valores das verbas 701 e 702.
	Local nNVvalor	:= 0		// Novo valor da verba 774.
			
	
	// Filtra matrículas dentro do período.
	cQuery := " SELECT DISTINCT(RR_MAT) "
	cQuery += " FROM "+ RETSQLNAME("SRR") +" SRR "
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND RR_ROTEIR = 'RES' "
	cQuery += " AND RR_PERIODO = '"+ cData +"' "
	cQuery += " ORDER BY RR_MAT "
	
	If Select("T_SRR1") <>  0
		T_SRR1->(DbCloseArea())
	EndIf

	TcQuery cQuery New Alias "T_SRR1"
	cQuery := ""
	
	DbSelectArea("T_SRR1")
	Do While !EOF()
	
		// Filtra por funcionário, a soma das alíquotas 701 e 702.
		cQuery := " SELECT SUM(RR_VALOR) AS VTOTAL"
		cQuery += " FROM "+ RETSQLNAME("SRR") +" SRR "
		cQuery += " WHERE D_E_L_E_T_ <> '*' "
		cQuery += " AND RR_ROTEIR = 'RES' "
		cQuery += " AND RR_PERIODO = '"+ cData +"' "
		cQuery += " AND RR_MAT = '"+ T_SRR1->RR_MAT +"' "
		cQuery += " AND (RR_PD = '"+ cVerb1 +"' OR RR_PD = '"+ cVerb2 +"') "
		
		If Select("T_SRR2") <>  0
			T_SRR2->(DbCloseArea())
		EndIf

		TcQuery cQuery New Alias "T_SRR2"
		cQuery := ""
		
		DbSelectArea("T_SRR2")
		
		// Update do novo valor nas verbas 774.
		If T_SRR2->VTOTAL > 0
			nNVvalor := Round((T_SRR2->VTOTAL * nPerc),2)
			
			cQuery := " UPDATE "+ RETSQLNAME("SRR") +" "
			cQuery += " SET RR_VALOR = "+ ALLTRIM(STR(nNVvalor)) +" "
			cQuery += " WHERE RR_PERIODO = '"+ cData +"' "
			cQuery += " AND RR_ROTEIR = 'RES' "
			cQuery += " AND RR_MAT = '"+ T_SRR1->RR_MAT +"' "
			cQuery += " AND RR_PD = '"+ cVerb3 +"' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
			TcSqlExec(cQuery)
			cQuery := ""  	
			
			nNVvalor := 0
		EndIf
		DbSelectArea("T_SRR2")
		T_SRR2->(DbCloseArea())
	
	
		DbSelectArea("T_SRR1")
		DbSkip()
	EndDo
	T_SRR1->(DbCloseArea())
	

Return()

