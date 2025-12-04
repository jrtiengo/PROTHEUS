#INCLUDE "apwebsrv.ch"
#Include "totvs.ch"
#Include "TopConn.ch"
#Include "TBIConn.ch"
#Include "Protheus.ch"
//#Include "tlpp-core.th"
//#Include "tlpp-rest.th"

/*/{Protheus.doc} xStsRental
description Buscar titulos em aberto e vencidos para atualizar o campo CN9_XSTSREN
@type function
@version  
@author Tiengo Junior
@since 11/10/2025
@return variant, return_description
/*/
User Function xStsRent()

	Local	lSchedule	:= FWGetRunSchedule()
	Local 	cFunction	:= "xStsRent"
	Local	cTitle		:= "Atualizacao Status Rental"
	Local	cObs		:= ""
	Local	oProcess	:= Nil
	Local	cHInicio	:= Time()

	Private CTITAPP  	:= "xStsRental - Atualizacao Status Rental"

	If !lSchedule
		cObs := "Essa rotina tem a finalidade de realizar a atualizacao de Status de Pagamento "
		oProcess := TNewProcess():New(cFunction, cTitle, {|oSelf, lSchedule| xStsProc(oSelf, lSchedule, 0)}, cObs)
		Aviso("Aviso - " + cTitle + " - " + cHInicio + " - " + Time() , "Fim do processamento! ", {"OK"})
	Else
		xStsProc(Nil, lSchedule, 0)
		Conout(cFunction +": " + cTitle + " - " + cHInicio + " - " + Time() +" - Fim do processamento!")
	EndIf

	If ValType(oProcess) == "O"
		FreeObj(oProcess)
	EndIf

Return(.T.)

/*/{Protheus.doc} xStsProc
description Processamento para atualização Status Rental
@type function
@version  
@author Tiengo Junior
@since 11/10/2025
@param oSelf, object, param_description
@param lSchedule, logical, param_description
@param nRecno, numeric, param_description
@return variant, return_description
/*/
Static Function xStsProc(oSelf, lSchedule, nRecno)

	Local cQuery    := ""
	Local cAlias 	:= ""
	Local nDiasTol  := SuperGetMV('MV_BLIINAD', .F., 5)

	Default oSelf := Nil
	Default lSchedule := FWGetRunSchedule()

	cQuery := "SELECT DISTINCT " + CRLF
	cQuery += "    E1_PREFIXO," + CRLF
	cQuery += "    E1_NUM," + CRLF
	cQuery += "    E1_PARCELA," + CRLF
	cQuery += "    E1_TIPO," + CRLF
	cQuery += "    E1_MDCONTR," + CRLF
	cQuery += "    E1_MDREVIS," + CRLF
	cQuery += "    E1_XRENTA" + CRLF
	cQuery += "FROM SE1010 SE1" + CRLF
	cQuery += "WHERE SE1.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  AND E1_FILIAL = '" + FWxFilial("SE1") + "'" + CRLF
	cQuery += "  AND E1_SALDO > 0" + CRLF
	cQuery += "  AND E1_BAIXA = ''" + CRLF
	cQuery += "  AND E1_VENCTO < '" + DtoS(dDatabase - nDiasTol) + "'" + CRLF
	cQuery += "  AND E1_XRENTA <> ''"

	cQuery := ChangeQuery(cQuery)
	cAlias := MPSysOpenQuery(cQuery)

	If (cAlias)->(Eof())
		If lSchedule
			Conout("Nenhum titulo Encontrado")
			Return()
		Else
			FWAlertWarning("Nenhum titulo Encontrado")
			Return()
		Endif
	Endif

	While ! (cAlias)->(Eof())

		CN9->(dbOrderNickName("NRENTAL")) //CN9_FILIAL+CN9_XRENTA

		If CN9->(MSseek(FWxFilial("CN9") + (cAlias)->E1_XRENTA))
			CN9->(RecLock("CN9", .F.))
			CN9->CN9_XSTSRE := "4" //Inadimplente
			CN9->(Msunlock())
		Endif

		(cAlias)->(dbSkip())
	Enddo

	(cAlias)->(dbCloseArea())

Return()

/*/{Protheus.doc} SchedDef
description Função para utilização no Schedule
@type function
@version  
@author Tiengo Junior
@since 11/10/2025
@return variant, return_description
/*/
Static Function SchedDef()

	Local _aPar 	:= {}		//array de retorno
	Local _cFunc	:= "xStsRent"
	Local _cPerg	:= PadR(_cFunc, 10)

	_aPar := { 	"P"		,;	//Tipo R para relatorio P para processo
	_cPerg	,;	//Nome do grupo de perguntas (SX1)
	Nil		,;	//cAlias (para Relatorio)
	Nil		,;	//aArray (para Relatorio)
	Nil		}	//Titulo (para Relatorio)

Return(_aPar)
