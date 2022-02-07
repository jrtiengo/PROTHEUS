#Include 'Protheus.ch'
#Include "Tbiconn.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} FR170PSQ
Pesquisa para layout personalizado do
relatório FINR170.
@author Mauro - Solutio
@since 26/01/2021
@version 1.0
@return ${return}, ${return_description}
@param _cPesq, , descricao
@param _cFor, , descricao
@param nOpc, numeric, descricao
@type function
/*/
User function FR170PSQ(_cPesq,_cCliFor,cVecto,nOpc)

	Local _cRet		:= ""
	Local cQuery	:= ""
	
	If MV_PAR01 == 2 // Pagar.
		If nOpc == 1 .Or. nOpc == 2 .Or. nOpc == 4 .Or. nOpc == 5
			cQuery := " SELECT E2_CODBAR, E2_DATAAGE, E2_NUMBOR AS NUMBOR "
			cQuery += " FROM "+ RETSQLNAME("SE2") +" "
			cQuery += " WHERE E2_PREFIXO + E2_NUM + E2_PARCELA = '"+ _cPesq +"' "
			cQuery += " AND E2_FORNECE = '"+ _cCliFor +"' "
			cQuery += " AND E2_VENCTO = '"+ Dtos(cVecto) +"' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
		EndIf
	ElseIf MV_PAR01 == 1 // Receber.
		If nOpc == 3
			cQuery := " SELECT E1_EMISSAO, E1_NUMBOR AS NUMBOR "
			cQuery += " FROM "+ RETSQLNAME("SE1") +" "
			cQuery += " WHERE E1_PREFIXO + E1_NUM + E1_PARCELA = '"+ _cPesq +"' "
			cQuery += " AND E1_CLIENTE = '"+ _cCliFor +"' "
			cQuery += " AND E1_VENCTO = '"+ Dtos(cVecto) +"' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
		EndIf
	EndIf
	
	If Select("TMP") <>  0
		TMP->(DbCloseArea())
	EndIf

	TcQuery cQuery New Alias "TMP"
	cQuery := ""
	
	DbSelectArea("TMP")
	If nOpc == 1
		_cRet := DTOC(STOD(TMP->E2_DATAAGE))
	ElseIf nOpc == 2
		_cRet := TMP->E2_CODBAR
	ElseIf nOpc == 3
		_cRet := DTOC(STOD(TMP->E1_EMISSAO)) 
	ElseIf nOpc == 4 .Or. nOpc == 5

		cQuery := " SELECT EA_MODELO, EA_TIPOPAG
		cQuery += " FROM "+ RETSQLNAME("SEA") +" "
		cQuery += " WHERE EA_NUMBOR = '"+ TMP->NUMBOR  +"' "
		cQuery += " AND EA_PREFIXO + EA_NUM + EA_PARCELA = '"+ _cPesq +"' "
		cQuery += " AND D_E_L_E_T_ <> '*' "

		If Select("TMP1") <>  0
		TMP1->(DbCloseArea())
		EndIf

		TcQuery cQuery New Alias "TMP1"
		DbSelectArea("TMP1")
		If nOpc == 4
			_cRet := TMP1->EA_MODELO
		ElseIf nOpc == 5
			_cRet := TMP1->EA_TIPOPAG
		EndIf
		TMP1->(DbCloseArea())
	EndIf
	TMP->(DbCloseArea())

	_cPesq		:= ""
	_cCliFor	:= ""
	cVecto		:= ""
	nOpc		:= 0
	 
	
Return(_cRet)
