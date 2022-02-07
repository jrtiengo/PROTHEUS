#Include 'Protheus.ch'
#Include "Topconn.ch"

/*/{Protheus.doc} F260LJCON
Permite alterar o campo FIG_LOJA na rotina de Conciliacao DDA.
@author Mauro - Solutio.
@since 20/05/2021
@version 6
@return ${return}, ${return_description}
@param _cCliFor, , descricao
@param _cLoj, , descricao
@param _cTpCF, , descricao
@type function
/*/
User Function F260LJCON()
	
	Local aArea		:= GetArea()
	Local cLojaFIG	:= PARAMIXB[2]
	Local cQuery	:= ""
	
	FIG->(DbGoto(PARAMIXB[1]))
	
	cQuery := " SELECT TOP 1 E2_LOJA "
	cQuery += " FROM "+ RETSQLNAME("SE2") +" SE2 "
	cQuery += " WHERE SE2.E2_FORNECE = '"+ FIG->FIG_FORNEC +"' "
	cQuery += " AND SE2.E2_LOJA <> '"+ FIG->FIG_LOJA +"' "
	cQuery += " AND SE2.E2_VALOR = " + ALLTRIM(STR(FIG->FIG_VALOR)) + " "
	cQuery += " AND SE2.D_E_L_E_T_ <> '*' "
	cQuery += " AND ( SE2.E2_VENCREA = '"+ DTOS(FIG->FIG_VENCTO) +"' OR SE2.E2_VENCREA = '"+ DTOS(FIG->FIG_VENCTO) +"' ) "
	
	If Select("TMP1") <>  0
		TMP1->(DbCloseArea())
	EndIf

	TcQuery cQuery New Alias "TMP1"
	DbSelectArea("TMP1")
	If !EOF("TMP1") .And. TMP1->E2_LOJA <> cLojaFIG
	
		cLojaFIG := TMP1->E2_LOJA
		
		RecLock("FIG",.F.)
		FIG->FIG_LOJA := cLojaFIG
		FIG->(MsUnlock())
		
	EndIf
	
	TMP1->(DbCloseArea())
	
	RestArea(aArea)

Return(cLojaFIG)
