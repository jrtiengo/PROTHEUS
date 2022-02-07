#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} TEDA015
Consulta a chave da NFe.
Para uso em cnabs.
@author Mauro - Solutio.
@since 16/10/2020
@version 1.0
@return ${return}, ${return_description}
@param _cNum, , descricao
@type function
/*/

User function TEDA015(_cNum,_cCli,_cLoja)

	Local _cRet		:= ""
	Local cQuery	:= ""
	
	// _cRet := Posicione("SF2",1,xFilial("SF2")+_cNum,"F2_CHVNFE")

	cQuery := "" 
	cQuery += " SELECT F2_CHVNFE "
	cQuery += " FROM "+ RETSQLNAME("SF2") +" SF2 "
	cQuery += " WHERE SF2.F2_DOC = '"+ _cNum +"' "
	cQuery += " AND SF2.F2_CLIENTE = '"+ _cCli +"' "
	cQuery += " AND SF2.F2_LOJA = '"+ _cLoja +"' "

	If Select("TMP1") <>  0
		TMP1->(DbCloseArea())
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP1",.T.,.T.)

	DbSelectArea("TMP1")
	_cRet := TMP1->F2_CHVNFE
	TMP1->(DbCloseArea())
	
Return(_cRet)
