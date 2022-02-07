#Include 'Protheus.ch'
#Include "Tbiconn.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} ACERTAIR
Reprocessa base e valor do IR.
@type function
@author Mauro Silva
@since 15/10/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

User Function ACERTAIR()

	Local cQuery	:= {}
	Local cData		:= "201809" // Período da folha.
	Local cBASIR	:= "703"	// Verba da base do IR.
	Local cVLAB1	:= "711"	// Verba para abatimento 1.
	Local cVLAB2	:= "740"	// Verba para abatimento 2.
	Local cVALIR	:= "404"	// Verba do percentual e valor do IR.
	Local nValBs	:= 0		// Valor da base.
	Local nNVlBs	:= 0		// Novo valor da base.
	Local nValAb	:= 0		// Valor de abatimento.
	Local nVlAbD	:= 0		// Valor de abatimento de dependentes.
	Local nPrcIR	:= 0		// Novo percentual.
	Local nValIr	:= 0		// Novo valor do IR.
		
	
	// Localiza os registros da verba do IR, dentro do período informado.
	cQuery := " SELECT RD_MAT, RD_PD, RD_VALOR "
	cQuery += " FROM "+ RETSQLNAME("SRD") +" SRD "
	cQuery += " WHERE SRD.RD_DATARQ = '"+ cData +"' "
	cQuery += " AND SRD.RD_PD = '"+ cBASIR +"' "
	cQuery += " AND SRD.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY SRD.RD_MAT "
	
	If Select("T_SRD1") <>  0
		T_SRD1->(DbCloseArea())
	EndIf

	TcQuery cQuery New Alias "T_SRD1"
	cQuery := ""
	
	DbSelectArea("T_SRD1")

	Do While T_SRD1->(!Eof())
	
		// Valor original da base.
		nValBs := T_SRD1->RD_VALOR
	
		// Com a verba da base listada, pega o abatimento do funcionário.
		cQuery := " SELECT SUM(RD_VALOR) AS ABATIMENTO "
		cQuery += " FROM "+ RETSQLNAME("SRD") +" SRD "
		cQuery += " WHERE SRD.RD_DATARQ = '"+ cData +"' "
		cQuery += " AND SRD.RD_MAT = '"+ T_SRD1->RD_MAT +"' "
		cQuery += " AND SRD.RD_PD = '"+ cVLAB1 +"' "
		cQuery += " AND SRD.D_E_L_E_T_ <> '*' "
		
		If Select("T_SRD2") <>  0
			T_SRD2->(DbCloseArea())
		EndIf

		TcQuery cQuery New Alias "T_SRD2"
		nValAb := T_SRD2->ABATIMENTO // Abatimento da base.
		T_SRD2->(DbCloseArea())
		cQuery := ""
		
		// Com a verba da base listada, pega o abatimentos de dependentes do funcionário.
		cQuery := " SELECT SUM(RD_VALOR) AS ABATIMENTO "
		cQuery += " FROM "+ RETSQLNAME("SRD") +" SRD "
		cQuery += " WHERE SRD.RD_DATARQ = '"+ cData +"' "
		cQuery += " AND SRD.RD_MAT = '"+ T_SRD1->RD_MAT +"' "
		cQuery += " AND SRD.RD_PD = '"+ cVLAB2 +"' "
		cQuery += " AND SRD.D_E_L_E_T_ <> '*' "
		
		If Select("T_SRD3") <>  0
			T_SRD3->(DbCloseArea())
		EndIf

		TcQuery cQuery New Alias "T_SRD3"
		nVlAbD := T_SRD3->ABATIMENTO // Abatimento de dependente.
		T_SRD3->(DbCloseArea())
		cQuery := ""

		// Posiciona novamente na primeira tabela.
		DbSelectArea("T_SRD1")		
		
		// Novo valor da base.
		nNVlBs := nValBs - nValAb
		
		// Faz update na tabela, com novo valor da base.
		cQuery := " UPDATE "+ RETSQLNAME("SRD") +" "
		cQuery += " SET RD_VALOR = "+ ALLTRIM(STR(nNVlBs)) +" "
		cQuery += " WHERE RD_DATARQ = '"+ cData +"' "
		cQuery += " AND RD_MAT = '"+ T_SRD1->RD_MAT +"' "
		cQuery += " AND RD_PD = '"+ cBASIR +"' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		TcSqlExec(cQuery)
		cQuery := ""  		

		// Define valor da aliquota e do IR.
		/*
		Base de cálculo mensal em R$	Alíquota %	Parcela a deduzir do imposto em R$
		De 1.903,99 até 2.826,65		7,5			142,80
		De 2.826,66 até 3.751,05		15,0		354,80
		De 3.751,06 até 4.664,68		22,5		636,13
		Acima de 4.664,68				27,5		869,36
		*/			
		Do Case
			Case (nNVlBs - nVlAbD) >= 1903.99 .And. (nNVlBs - nVlAbD) <= 2826.65
				nPrcIR	:= 7.5
				nValIr	:= ((nNVlBs - nVlAbD) * 0.075) - 142.80  
			Case (nNVlBs - nVlAbD) >= 2826.66 .And. (nNVlBs - nVlAbD) <= 3751.05
				nPrcIR	:= 15
				nValIr	:= ((nNVlBs - nVlAbD) * 0.15) - 354.80
			Case (nNVlBs - nVlAbD) >= 3751.06 .And. (nNVlBs - nVlAbD) <= 4664.68
				nPrcIR := 22.5
				nValIr	:= ((nNVlBs - nVlAbD) * 0.225) - 636.13
			Case (nNVlBs - nVlAbD) >= 4664.69 
				nPrcIR	:= 27.5
				nValIr	:= ((nNVlBs - nVlAbD) * 0.275) - 869.36
		EndCase
	
		// Faz update na tabela, com as novas aliquota e valor do IR.
		If nValIr > 0
			cQuery := " UPDATE "+ RETSQLNAME("SRD") +" "
			cQuery += " SET RD_HORAS = "+ ALLTRIM(STR(nPrcIR)) +", "
			cQuery += " RD_VALOR = "+ ALLTRIM(STR(nValIr)) +" "
			cQuery += " WHERE RD_DATARQ = '"+ cData +"' "
			cQuery += " AND RD_MAT = '"+ T_SRD1->RD_MAT +"' "
			cQuery += " AND RD_PD = '"+ cVALIR +"' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
			TcSqlExec(cQuery)
			cQuery := ""
		EndIf
		
		// Zero as variáveis.
		nValBs	:= 0
		nNVlBs	:= 0
		nValAb	:= 0
		nVlAbD	:= 0
		nPrcIR	:= 0
		nValIr	:= 0
		
		DbSelectArea("T_SRD1")
		DbSkip()
	
	EndDo
	
	T_SRD1->(DbCloseArea())

Return()

