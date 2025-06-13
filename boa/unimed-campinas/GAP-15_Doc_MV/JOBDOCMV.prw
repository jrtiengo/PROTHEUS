#INCLUDE "apwebsrv.ch"
#Include "totvs.ch"
#Include "TopConn.ch"
#Include "TBIConn.ch"
#Include "Protheus.ch"

/*/{Protheus.doc} DocMVProc
JOB Integração de documento entrada para o MV
@type function
@version  
@author Tiengo Junior
@since 30/05/2025
@return variant, return_description
/*/
User Function JOBDOCMV()

	Local	lSchedule	:= FWGetRunSchedule()
	Local 	cFunction	:= "JOBDOCMV"
	Local	cTitle		:= "Integração de Documento Entrada para o MV"
	Local	cObs		:= ""
	Local	oProcess	:= Nil
	Local	cHInicio	:= Time()

	Private CTITAPP  	:= "JOBDOCMV - Integração de Documento de Entrada para o MV"

	If ! lSchedule
		cObs := "Essa rotina tem a finalidade de realizar Integração de Documento de Entrada para o MV"
		oProcess := TNewProcess():New(cFunction, cTitle, {|oSelf, lSchedule| u_DocMVProc(oSelf, lSchedule, 0)}, cObs)
		Aviso("Aviso - " + cTitle + " - " + cHInicio + " - " + Time() , "Fim do processamento! ", {"OK"})
	Else
		u_DocMVProc(Nil, lSchedule, 0)
		Conout(cFunction +": " + cTitle + " - " + cHInicio + " - " + Time() +" - Fim do processamento!")
	EndIf

	If ValType(oProcess) == "O"
		FreeObj(oProcess)
	EndIf

Return(.T.)

/*/{Protheus.doc} DocMVProc
JOB Integração de documento entrada para o MV
@type function
@version  
@author Tiengo Junior
@since 30/05/2025
@return variant, return_description
/*/
User Function DocMVProc(oSelf, lSchedule, nN)

	Local cQuery    := ""
	Local cMsgErr 	:= ""

	Private cAliasTRB := GetNextAlias()

	Default oSelf := Nil
	Default lSchedule := FWGetRunSchedule()

	oLog := CtrlLOG():New()
	jAuxLog := Jsonobject():New()

	If !oLog:SetTab("SZL")
		U_AdminMsg("[JOBDOCMV] " + DToC(dDataBase) + " - " + Time() + " -> " + oLog:GetError(), IsBlind())
		Return .T.
	EndIf

	cQuery := " SELECT R_E_C_N_O_ RECSF1, F1_XTPREQ TPREQ, *" + CRLF
	cQuery += " FROM " + RetSqlName("SF1") + " SF1 " + CRLF
	cQuery += " WHERE D_E_L_E_T_ = ' ' AND F1_XSTREQ <> '1'  " + CRLF

	DBUseArea(.T., "TOPCONN", TCGenQry( , , cQuery), (cAliasTRB), .T., .T.)

	If (cAliasTRB)->(Eof())
		While !(cAliasTRB)->(Eof())
			SF1->(dbtoto((cAliasTRB)->RECSF1))
			U_IntDocMV(Val(TPREQ),@cMsgErr)
			(cAliasTRB)->(dbSkip())
		Enddo
	Endif

	(cAliasTRB)->(dbCloseArea())

Return()

/*/{Protheus.doc} SchedDef
description Função para utilização no Schedule
@type function
@version  
@author Tiengo Junior
@since 30/05/2025
@return variant, return_description
/*/
Static Function SchedDef()

	Local _aPar 	:= {}
	Local _cFunc	:= "JOBDOCMV"
	Local _cPerg	:= PadR(_cFunc, 10)


	_aPar := { 	"P"		,;	//Tipo R para relatorio P para processo
	_cPerg	,;	//Nome do grupo de perguntas (SX1)
	Nil		,;	//cAlias (para Relatorio)
	Nil		,;	//aArray (para Relatorio)
	Nil		}	//Titulo (para Relatorio)

Return(_aPar)
