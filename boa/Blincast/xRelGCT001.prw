#Include 'TOTVS.ch'
#Include 'TopConn.ch'
#Include 'Protheus.ch'

/*/{Protheus.doc} xRelGCT001
Relatorio para Rastreabilidade Rental x Gestão de Contratos x Financeiro x Faturamento
@type function
@version V 1.00
@author Tiengo Junior
@since 14/10/2025
/*/

User Function xRelGCT001()

	Local oReport   := Nil
	Local cPerg     := Padr("xRelGCT001", 10)

	Pergunte(cPerg, .F.)

	oReport := RPTStruc(cPerg)
	oReport:PrintDialog()

Return()

Static Function RPTPrint(oReport)

	Local oSection1     := oReport:Section(1)
	Local oSection2     := oReport:Section(2)
	Local cQuery        := ""
	Local cContrato     := ""
	Local cAlias        := ""

	cQuery := "SELECT "
	cQuery += "    CN9.CN9_NUMERO, "
	cQuery += "    CN9.CN9_REVISA, "
	cQuery += "    CN9.CN9_XRENTA, "
	cQuery += "    CASE  "
	cQuery += "        WHEN CN9.CN9_XSTSRE = '1' THEN 'Aberto' "
	cQuery += "        WHEN CN9.CN9_XSTSRE = '2' THEN 'Faturado' "
	cQuery += "        WHEN CN9.CN9_XSTSRE = '3' THEN 'Adimplente' "
	cQuery += "        WHEN CN9.CN9_XSTSRE = '4' THEN 'Inadimplente' "
	cQuery += "    END STATUS_CONTRATO, "
	cQuery += "    CNC.CNC_CLIENT, "
	cQuery += "    CNC.CNC_LOJACL, "
	cQuery += "    CND.CND_NUMMED, "
	cQuery += "    CND.CND_COMPET, "
	cQuery += "    CND.CND_VLTOT, "
	cQuery += "    SE1.E1_BAIXA "
	cQuery += "FROM CN9010 CN9 "
	cQuery += "INNER JOIN ( "
	cQuery += "    SELECT CN9_FILIAL, CN9_NUMERO, MAX(CN9_REVISA) AS CN9_REVISA "
	cQuery += "    FROM CN9010 "
	cQuery += "    WHERE D_E_L_E_T_ = '' "
	cQuery += "    GROUP BY CN9_FILIAL, CN9_NUMERO "
	cQuery += ") CN9_MAX ON CN9_MAX.CN9_FILIAL = CN9.CN9_FILIAL "
	cQuery += "AND CN9_MAX.CN9_NUMERO = CN9.CN9_NUMERO "
	cQuery += "AND CN9_MAX.CN9_REVISA = CN9.CN9_REVISA "
	cQuery += "INNER JOIN CNC010 CNC "
	cQuery += "    ON CNC.CNC_FILIAL = CN9.CN9_FILIAL "
	cQuery += "    AND CNC.CNC_NUMERO = CN9.CN9_NUMERO "
	cQuery += "    AND CNC.CNC_REVISA = CN9.CN9_REVISA "
	cQuery += "    AND CNC.D_E_L_E_T_ = '' "
	cQuery += "LEFT JOIN CND010 CND "
	cQuery += "    ON CND.CND_FILIAL = CN9.CN9_FILIAL "
	cQuery += "    AND CND.CND_CONTRA = CN9.CN9_NUMERO "
	cQuery += "    AND CND.D_E_L_E_T_ = '' "
	cQuery += "LEFT JOIN SE1010 SE1 "
	cQuery += "    ON SE1.E1_FILIAL = CND.CND_FILIAL "
	cQuery += "    AND SE1.E1_MEDNUME = CND.CND_NUMMED "
	cQuery += "    AND SE1.D_E_L_E_T_ = '' "
	cQuery += "WHERE CN9.D_E_L_E_T_ = '' "
	cQuery += "  AND CN9.CN9_XRENTA <> '' "
	cQuery += "  AND CN9.CN9_FILIAL = '" + FWxFilial("CN9") + "' "
	cQuery += "ORDER BY CN9.CN9_NUMERO"

	cQuery := ChangeQuery(cQuery)
	cAlias := MPSysOpenQuery(cQuery)

	(cAlias)->(dbGoTop())

	oReport:SetMeter((cAlias)->(LastRec()))

	While ! (cAlias)->(Eof())

		If oReport:Cancel()
			Exit
		EndIF
		// Iniciando a primeira seção
		oSection1:Init()
		oReport:IncMeter()

		cContrato := Alltrim((cAlias)->CN9_NUMERO)
		IncProc("Imprimindo Contrato " + cContrato)

		// Imprimindo a primeira seção
		oSection1:Cell("CN9_NUMERO"):SetValue((cAlias)->CN9_NUMERO)
		oSection1:Cell("CN9_REVISA"):SetValue((cAlias)->CN9_REVISA)
		oSection1:Cell("CN9_XRENTA"):SetValue((cAlias)->CN9_XRENTA)
		oSection1:Cell("STATUS_CONTRATO"):SetValue((cAlias)->STATUS_CONTRATO)
		oSection1:Cell("CNC_CLIENT"):SetValue((cAlias)->CNC_CLIENT)
		oSection1:Cell("CNC_LOJACL"):SetValue((cAlias)->CNC_LOJACL)
		oSection1:PrintLine()

		// Iniciando a segunda seção
		oSection2:Init()

		// Verifica se o contrato é o mesmo, se sim, imprime o dados
		While (cAlias)->CN9_NUMERO == cContrato

			oReport:IncMeter()

			IncProc("Imprimindo Historico " + Alltrim((cAlias)->CND_NUMMED))
			oSection2:Cell("CND_NUMMED"):SetValue((cAlias)->CND_NUMMED)
			oSection2:Cell("CND_COMPET"):SetValue((cAlias)->CND_COMPET)
			oSection2:Cell("CND_VLTOT"):SetValue((cAlias)->CND_VLTOT)
			oSection2:Cell("E1_BAIXA"):SetValue((cAlias)->E1_BAIXA)

			oSection2:PrintLine()

			(cAlias)->(dbSkip())

		endDo

		oSection2:FInish()
		oReport:ThinLine()

		oSection1:FInish()

	EndDo

Return()

Static Function RPTStruc(cNome)

	Local oReport       := NIL
	Local oSection1     := NIL
	Local oSection2     := NIL

	oReport := Treport():New(cNome, "Relatório rastreio de contratos", cNome, {|oReport| RPTPrint(oReport)},"Relatório para Rastreabilidade Rental x Gestão de Contratos x Financeiro x Faturamento")

	//Defininindo a orientação como retrato
	oReport:SetPortrait()

	oSection1 := TRSection():New(oReport, "Contratos", {"CN9"}, NIL, .F., .T.)

	//Dados do Contrato
	TRCell():New(oSection1, "CN9_NUMERO",       "CN9", "Contrato GCT", "@!"       , TamSx3("CN9_NUMERO")[1])
	TRCell():New(oSection1, "CN9_REVISA",       "CN9", "Revisão", "@!"            , TamSx3("CN9_REVISA")[1])
	TRCell():New(oSection1, "CN9_XRENTA",       "CN9", "Contrato Rental" , "@!"   , TamSx3("CN9_XRENTA")[1])
	TRCell():New(oSection1, "STATUS_CONTRATO",  "CN9", "Status Rental" , "@!"     , 30)
	TRCell():New(oSection1, "CNC_CLIENT",       "CNC", "Cliente", "@!"            , TamSx3("CNC_CLIENT")[1])
	TRCell():New(oSection1, "CNC_LOJACL",       "CNC", "Loja", "@!"               , TamSx3("CNC_LOJACL")[1])

	oSection2 := TRSection():New(oReport, "Medições e Títulos", {"CND", "SE1"}, NIL, .F., .T.)

	//Dados da Medição
	TRCell():New(oSection2, "CND_NUMMED", "CND", "Nº Medição", "@!", TamSx3("CND_NUMMED")[1])
	TRCell():New(oSection2, "CND_COMPET", "CND", "Competência", "@!", TamSx3("CND_COMPET")[1])
	TRCell():New(oSection2, "CND_VLTOT", "CND", "Valor Medido", "@E 999,999,999.99", 15)

	//Dados Financeiro
	TRCell():New(oSection2, "E1_BAIXA", "SE1", "Data Baixa", "@!", TamSx3("E1_BAIXA")[1])

	oSection1:SetPageBreak(.F.) //Quebra de Seção

Return(oReport)
