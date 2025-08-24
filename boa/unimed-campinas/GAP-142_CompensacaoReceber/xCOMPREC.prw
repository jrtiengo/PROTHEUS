#Include "TOTVS.ch"
#Include "PROTHEUS.ch"
#Include "TOPCONN.ch"

/*/{Protheus.doc} xCOMPREC
Este programa tem como objetivo gerar compesações em massa para os clientes selecionados
@type  Function
@author Tiengo Junior
@since 20/08/2025
@version version
@param  
	MV_PAR03 = lContabiliza
	MV_PAR04 = lAglutina
	MV_PAR05 = lDigita
@See https://centraldeatendimento.totvs.com/hc/pt-br/articles/7974002547607-Cross-Segmentos-Backoffice-Linha-Protheus-SIGAFIN-FINA330-Documenta%C3%A7%C3%A3o-execauto
/*/

User Function xCOMPREC()

	Local aArea         := FWGetArea()
	Local bProcess      := {|oSelf| fBusca(oSelf)}
	//Local cPerg         := "xCOMPREC"
	Local cTitulo       := "Compensação a Receber"
	Local cDesc         := "Este programa tem como objetivo realizar a compensação a receber em massa para os clientes selecionados."

	If ! IsBlind()
		tNewProcess():New( "xCOMPREC", cTitulo, bProcess, cDesc )
	Endif

	FwRestArea(aArea)

Return()

//Consulta com base nos parametros informados
Static Function fBusca(oSelf)

	Local aArea             := fWGetArea()
	Local cQuery            := ''
	Local cAlias            := ''
	Local aRecSE1           := {}

	cQuery := " SELECT DISTINCT									"
	cQuery += "     SE1.E1_EMISSAO,                    			"
	cQuery += "     SE1.E1_PREFIXO,                    			"
	cQuery += "     SE1.E1_NUM,                        			"
	cQuery += "     SE1.E1_PARCELA,                    			"
	cQuery += "     SE1.E1_TIPO,                       			"
	cQuery += "     SE1.E1_CLIENTE,                    			"
	cQuery += "     SE1.E1_LOJA,                       			"
	cQuery += "     SE1.E1_SALDO,                      			"
	cQuery += "     SE1.E1_FILORIG,                    			"
	cQuery += "     SE1.R_E_C_N_O_            					"
	cQuery += " FROM " + RetSqlName("SE1") + " SE1 	       		"
	cQuery += " WHERE  SE1.D_E_L_E_T_ = ' '                 	"
	cQuery += "     AND SE1.E1_FILIAL = '"+FWxFilial('SE1')+"'  "
	cQuery += "     AND SE1.E1_TIPO IN ('NF')          			"
	cQuery += "     AND SE1.E1_BAIXA = ' '             			"
	cQuery += "     AND SE1.E1_SALDO > 0               			"
	cQuery += " ORDER BY                               			"
	cQuery += "     SE1.E1_EMISSAO,                    			"
	cQuery += "     SE1.E1_PREFIXO,                    			"
	cQuery += "     SE1.E1_NUM,                        			"
	cQuery += "     SE1.E1_PARCELA,                    			"
	cQuery += "     SE1.E1_TIPO,                       			"
	cQuery += "     SE1.E1_CLIENTE                     			"

	cQuery := ChangeQuery(cQuery)
	cAlias := MPSysOpenQuery(cQuery)

	If (cAlias)->(EoF())
		If ! IsBlind()
			FWAlertWarning('Atenção não foram encontrados registros','Atenção')
			Return()
		Endif
	Endif

	While ! (cAlias)->(EoF())

		aRecSE1 	:= {(cAlias)->R_E_C_N_O_}

		fExecAuto(aRecSE1, (cAlias)->SE1.E1_NUM, (cAlias)->E1_CLIENTE, (cAlias)->E1_LOJA)

		aRecSE1 	:= {}

		(cAlias)->(dbSkip())
	Enddo

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf

	FwRestArea(aArea)

	If ! IsBlind()
		FWAlertInfo('Processamento finalizado!','Processamento')
	Endif

Return()

Static Function fExecAuto(aRecSE1, cTitulo, cCodCli, cLoja)

	Local cQuery            := ''
	Local cAliasCP          := ''
	Local aRecRA            := {}

	cQuery += " SELECT SE1CP.E1_EMISSAO, 							"
	cQuery += "        SE1CP.R_E_C_N_O_ 							"
	cQuery += " FROM " + RetSqlName("SE1") + " SE1CP 				"
	cQuery += " WHERE SE1CP.D_E_L_E_T_ = ' '       	 				"
	cQuery += "   AND SE1CP.E1_FILIAL = '"+FWxFilial('SE1')+"'      "
	cQuery += "	  AND SE1CP.E1_CLIENTE = '" + cCodCli + "' 			"
	cQuery += "	  AND SE1CP.E1_LOJA = '" + cLoja + "'  				"
	cQuery += "   AND SE1CP.E1_TIPO IN('RA')        				"
	cQuery += "   AND SE1CP.E1_BAIXA = ' '          				"
	cQuery += "   AND SE1CP.E1_SALDO > 0            				"
	cQuery += " ORDER BY SE1CP.E1_EMISSAO             				"

	cQuery 		:= ChangeQuery(cQuery)
	cAliasCP 	:= MPSysOpenQuery(cQuery)

	If (cAliasCP)->(EoF())
		Return()
	Endif

	PERGUNTE("FIN330",.F.)
	lContabiliza    := (MV_PAR09 == 1)
	lDigita         := (MV_PAR07 == 1)
	lAglutina       := .F.

	While ! (cAliasCP)->(EoF())

		Aadd(aRecRA,(cAliasCP)->R_E_C_N_O_ )

		(cAliasCP)->(dbSkip())
	Enddo

	If Select(cAliasCP) > 0
		(cAliasCP)->(DbCloseArea())
	EndIf

	If ! MaIntBxCR(3, aRecSE1,,aRecRA,,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,,,,Nil,,,,,)
		FWAlertError("Não foi possível executar a compensação a receber do cliente: " + cCodCli + cLoja, "Erro Titulo" + cTitulo)
	Endif

Return()
