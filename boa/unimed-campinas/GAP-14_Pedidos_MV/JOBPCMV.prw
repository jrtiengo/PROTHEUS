#INCLUDE "apwebsrv.ch"
#Include "totvs.ch"
#Include "TopConn.ch"
#Include "TBIConn.ch"
#Include "Protheus.ch"

/*/{Protheus.doc} JOBPCMV
JOB Integração de PC para o MV
@type function
@version  
@author Tiengo Junior
@since 30/05/2025
@return variant, return_description
/*/
User Function JOBPCMV()

	Local	lSchedule	:= FWGetRunSchedule()
	Local 	cFunction	:= "JOBDOCMV"
	Local	cTitle		:= "Integração de PC para o MV"
	Local	cObs		:= ""
	Local	oProcess	:= Nil
	Local	cHInicio	:= Time()

	Private CTITAPP  	:= "JOBPCMV - Integração de PC para o MV"

	If ! lSchedule
		cObs := "Essa rotina tem a finalidade de realizar Integração de PC para o MV"
		oProcess := TNewProcess():New(cFunction, cTitle, {|oSelf, lSchedule| u_PCMVProc(oSelf, lSchedule, 0)}, cObs)
		Aviso("Aviso - " + cTitle + " - " + cHInicio + " - " + Time() , "Fim do processamento! ", {"OK"})
	Else
		u_PCMVProc(Nil, lSchedule, 0)
		Conout(cFunction +": " + cTitle + " - " + cHInicio + " - " + Time() +" - Fim do processamento!")
	EndIf

	If ValType(oProcess) == "O"
		FreeObj(oProcess)
	EndIf

Return(.T.)

/*/{Protheus.doc} DocMVProc
JOB Integração de PC para o MV
@type function
@version  
@author Tiengo Junior
@since 30/05/2025
@return variant, return_description
/*/
User Function PCMVProc(oSelf, lSchedule, nN)

	Local cQuery    := ""
	Local cMsgErr 	:= ""

	Private cAliasTRB := GetNextAlias()

	Default oSelf := Nil
	Default lSchedule := FWGetRunSchedule()

	oLog := CtrlLOG():New()
	jAuxLog := Jsonobject():New()

	If !oLog:SetTab("SZL")
		U_AdminMsg("[JOBPCMV] " + DToC(dDataBase) + " - " + Time() + " -> " + oLog:GetError(), IsBlind())
		Return .T.
	EndIf

	cQuery := " SELECT R_E_C_N_O_ RECSC7, C7_XTPREQ TPREQ, *" + CRLF
	cQuery += " FROM " + RetSqlName("SC7") + " SC7 " + CRLF
	cQuery += " WHERE D_E_L_E_T_ = ' ' AND C7_XSTREQ = '0'  " + CRLF
	cQuery += " GROUP BY C7_FILIAL, C7_NUM " + CRLF

	cQuery 	  := ChangeQuery(cQuery)
	cAliasTRB := MPSysOpenQuery(cQuery)

	If (cAliasTRB)->(EoF())
		If IsBlind()
			Conout('Atenção não foram encontrados registros','Atenção')
			Return()
		Endif
	Endif

	While !(cAliasTRB)->(Eof())
		SC7->(dbtoto((cAliasTRB)->RECSC7))
		U_IntDocMV(Val(TPREQ),@cMsgErr)
		(cAliasTRB)->(dbSkip())
	Enddo

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
	Local _cFunc	:= "JOBPCMV"
	Local _cPerg	:= PadR(_cFunc, 10)


	_aPar := { 	"P"		,;	//Tipo R para relatorio P para processo
	_cPerg	,;	//Nome do grupo de perguntas (SX1)
	Nil		,;	//cAlias (para Relatorio)
	Nil		,;	//aArray (para Relatorio)
	Nil		}	//Titulo (para Relatorio)

Return(_aPar)
