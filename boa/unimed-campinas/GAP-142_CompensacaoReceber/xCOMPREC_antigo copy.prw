#Include "TOTVS.ch"
#Include "PROTHEUS.ch"
#Include "TOPCONN.ch"
//142
/*/{Protheus.doc} xCOMPREC
Este programa tem como objetivo gerar compesações em massa para os clientes selecionados
@type  Function
@author Tiengo Junior
@since 20/08/2025
@version version
@param  cliente/cliente
	MV_PAR03 = lContabiliza
	MV_PAR04 = lAglutina
	MV_PAR05 = lDigita
@See https://centraldeatendimento.totvs.com/hc/pt-br/articles/7974002547607-Cross-Segmentos-Backoffice-Linha-Protheus-SIGAFIN-FINA330-Documenta%C3%A7%C3%A3o-execauto
/*/

User Function xCOMPREC()

	Local aArea 	:= FWGetArea()
	Local aPergs  	:= {}

	//Adicionando os parametros do ParamBox
	aAdd(aPergs, {1, "Cliente De",  Space(TamSX3('A1_CLIENTE')[1]), "", ".T.", "SA1", ".T.", 80,  .T.})
	aAdd(aPergs, {1, "Cliente Até", Space(TamSX3('A1_LOJA')[1]),  	"", ".T.", "SB1", ".T.", 80,  .T.})

	//Se a pergunta for confirma, chama a tela
	If ParamBox(aPergs, 'Informe os parâmetros', /*aRet*/, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosx*/, /*nPosy*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
		fMontaTela()
	EndIf

	FWRestArea(aArea)
Return()

//Consulta com base nos parametros informados
Static Function fMontaTela()

	Local aArea             := fWGetArea()
	Local cQueryRA          := ''
	Local cQuery          	:= ''
	Local cAliasRA          := ''
	Local cAlias          	:= ''
	Local aRecSE1           := {}

	// Query para buscar clientes que possuem adiantamentos (RA) em aberto
	cQueryRA := " SELECT SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_EMISSAO, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.R_E_C_N_O_ "
	cQueryRA += " FROM " + RetSqlName("SE1") + " SE1 "
	cQueryRA += " WHERE SE1.D_E_L_E_T_ = ' ' "
	cQueryRA += "   AND SE1.E1_FILIAL = '" + FWxFilial('SE1') + "' "
	cQueryRA += "   AND SE1.E1_TIPO = 'RA' "
	cQueryRA += "   AND SE1.E1_SALDO > 0 "
	cQueryRA += "   AND SE1.E1_BAIXA = ' ' "
	cQueryRA += "   AND SE1.E1_CLIENTE BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	cQueryRA += " ORDER BY E1_CLIENTE, E1_LOJA, SE1.E1_NUM "

	cQueryRA := ChangeQuery(cQueryRA)
	cAliasRA := MPSysOpenQuery(cQueryRA)

	If (cAliasRA)->(EoF())
		If ! IsBlind()
			FWAlertWarning('Não foram encontrados nenhum título para compensação','Atenção')
			Return()
		Endif
	Endif







	cQuery := " SELECT  SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_EMISSAO, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.R_E_C_N_O_ "
	cQuery += " FROM " + RetSqlName("SE1") + " SE1 	       		"
	cQuery += " WHERE  SE1.D_E_L_E_T_ = ' '                 	"
	cQuery += "     AND SE1.E1_FILIAL = '"+FWxFilial('SE1')+"'  "
	cQuery += "     AND SE1.E1_TIPO <> 'RA'       				"
	//cQuery += "     AND SE1.E1_TIPO IN ('NF')          			"
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

	If Select(cAliasRA) > 0
		(cAlias)->(DbCloseArea())
	EndIf

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

	// Query para buscar clientes que possuem adiantamentos (RA) em aberto
	cQuery := " SELECT E1_CLIENTE, E1_LOJA "
	cQuery += " FROM " + RetSqlName("SE1") + " SE1 "
	cQuery += " WHERE SE1.D_E_L_E_T_ = ' ' "
	cQuery += "   AND SE1.E1_FILIAL = '" + FWxFilial('SE1') + "' "
	cQuery += "   AND SE1.E1_TIPO = 'RA' "
	cQuery += "   AND SE1.E1_SALDO > 0 "
	cQuery += "   AND SE1.E1_BAIXA = ' ' "
	cQuery += "   AND SE1.E1_CLIENTE BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	cQuery += " ORDER BY E1_CLIENTE, E1_LOJA "

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

//Bibliotecas
	#Include "TOTVS.ch"

 /*/{Protheus.doc} OMSCS003
	Tela para exclusão de conferência
	@type user function, static
	@version 1.0
	@author Ubirajara Tiengo Júnior
	@since 04/11/2024
	@param cGetPed
	@return variant, return_description
	@example
	@see https://tdn.totvs.com/display/public/framework/FwBrowse
/*/

User Function OMSCS003(cGetPed)

	Local aArea := GetArea()
	//Fontes
	Local cFontUti    := "Tahoma"
	Local oFontAno    := TFont():New(cFontUti,,-38)
	Local oFontSub    := TFont():New(cFontUti,,-20)
	Local oFontSubN   := TFont():New(cFontUti,,-20,,.T.)
	Local oFontBtn    := TFont():New(cFontUti,,-14)
	//Janela e componentes
	Private oDlgGrp
	Private oPanGrid
	Private oGetGrid
	Private aColunas := {}
	Private cAliasTab := "TMP"
	//Tamanho da janela
	Private    aTamanho := MsAdvSize()
	Private    nJanLarg := aTamanho[5]
	Private    nJanAltu := aTamanho[6]

	//Cria a temporária
	oTempTable := FWTemporaryTable():New(cAliasTab)

	//Adiciona no array das colunas as que serão incluidas (Nome do Campo, Tipo do Campo, Tamanho, Decimais)
	aFields := {}
	aAdd(aFields, {"XXPREFIXO",  "C", TamSX3('E1_PREFIXO')[01],     0})
	aAdd(aFields, {"XXNUMERO",   "C", TamSX3('E1_NUM') [01],    	0})
	aAdd(aFields, {"XXEMISSAO",  "D", TamSX3('E1_EMISSAO')[01],    	0})
	aAdd(aFields, {"XXCLIENTE",  "C", TamSX3('E1_CLIENTE')[01],    	0})
	aAdd(aFields, {"XXLOJA",   	 "C", TamSX3('E1_LOJA') [01],    	0})

	//Define as colunas usadas, adiciona indice e cria a temporaria no banco
	oTempTable:SetFields( aFields )
	oTempTable:AddIndex("1", {"XXCLIENTE"} )
	oTempTable:Create()

	//Monta o cabecalho
	fMontaHead()

	//Montando os dados, eles devem ser montados antes de ser criado o FWBrowse
	FWMsgRun(, {|oSay| fMontDados(oSay) }, "Processando", "Buscando itens")

	//Criando a janela
	DEFINE MSDIALOG oDlgGrp TITLE "Consulta" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	//Labels gerais
	@ 004, 003 SAY "EST"                     SIZE 200, 030 FONT oFontAno  OF oDlgGrp COLORS RGB(149,179,215) PIXEL
	@ 004, 050 SAY "Consulta Genérica de"    SIZE 200, 030 FONT oFontSub  OF oDlgGrp COLORS RGB(031,073,125) PIXEL
	@ 014, 050 SAY "Dados para conferência"  SIZE 200, 030 FONT oFontSubN OF oDlgGrp COLORS RGB(031,073,125) PIXEL

	//Botões
	@ 006, (nJanLarg/2-001)-(0052*01) BUTTON oBtnFech  PROMPT "Fechar"        SIZE 050, 018 OF oDlgGrp ACTION (oDlgGrp:End())   FONT oFontBtn PIXEL

	//Dados
	@ 024, 003 GROUP oGrpDad TO (nJanAltu/2-003), (nJanLarg/2-003) PROMPT "Browse" OF oDlgGrp COLOR 0, 16777215 PIXEL
	oGrpDad:oFont := oFontBtn
	oPanGrid := tPanel():New(033, 006, "", oDlgGrp, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2 - 13),     (nJanAltu/2 - 45))
	oGetGrid := FWBrowse():New()
	oGetGrid:DisableFilter()
	//oGetGrid:SetUseFilter()
	//oGetGrid:SetDBFFilter()
	oGetGrid:DisableConfig()
	oGetGrid:DisableReport()
	oGetGrid:DisableSeek()
	oGetGrid:DisableSaveConfig()
	oGetGrid:SetFontBrowse(oFontBtn)
	oGetGrid:SetAlias(cAliasTab)
	oGetGrid:SetDataTable()
	//oGetGrid:SetEditCell(.T., {|| .T.})
	oGetGrid:lHeaderClick := .F.
	oGetGrid:SetColumns(aColunas)
	oGetGrid:SetOwner(oPanGrid)
	oGetGrid:Activate()

	ACTIVATE MsDialog oDlgGrp CENTERED

	//Deleta a temporaria
	oTempTable:Delete()

	RestArea(aArea)
Return

Static Function fMontaHead()

	Local nAtual
	Local aHeadAux := {}

	aAdd(aHeadAux, {"XXPREFIXO",  "Prefixo",           	"C", TamSX3('E1_PREFIXO') [01], 0, "",  .F.})
	aAdd(aHeadAux, {"XXNUMERO",   "Numero",          	"C", TamSX3('E1_NUM') [01], 	0, "",  .F.})
	aAdd(aHeadAux, {"XXEMISSAO",  "Data Emissao",       "D", TamSX3('E1_EMISSAO')[01],	0, "",  .F.})
	aAdd(aHeadAux, {"XXCLIENTE",  "Cliente",     		"C", TamSX3('E1_CLIENTE')[01], 	0, "",  .F.})
	aAdd(aHeadAux, {"XXLOJA",     "Loja",     			"C", TamSX3('E1_LOJA')  [01], 	0, "",  .F.})

	//Percorrendo e criando as colunas
	For nAtual := 1 To Len(aHeadAux)
		oColumn := FWBrwColumn():New()
		oColumn:SetData(&("{|| " + cAliasTab + "->" + aHeadAux[nAtual][1] +"}"))
		oColumn:SetTitle(aHeadAux[nAtual][2])
		oColumn:SetType(aHeadAux[nAtual][3])
		oColumn:SetSize(aHeadAux[nAtual][4])
		oColumn:SetDecimal(aHeadAux[nAtual][5])
		oColumn:SetPicture(aHeadAux[nAtual][6])

		aAdd(aColunas, oColumn)
	Next

Return()

Static Function fMontDados(oSay)
	Local aArea   := GetArea()
	Local nAtual  := 0
	Local nTotal  := 50

	//Zera a grid
	aColsGrid := {}

	//Montando a query
	oSay:SetText("Montando a consulta")

	cQuery	:= " SELECT C9_PRODUTO AS PRODUTO,								"
	cQuery	+= "        SB1.B1_UPOSLOG AS POSICAO,                          "
	cQuery	+= "        SB1.B1_DESC AS DESCRICAO,                           "
	cQuery	+= "        SUM(C9_QTDLIB) AS QtdPedido,                        "
	cQuery	+= "        MAX(                                                "
	cQuery	+= "              (SELECT SUM(Z53_QTDCON) AS QtdLida            "
	cQuery	+= "               FROM Z53010 Z53                              "
	cQuery	+= "               WHERE Z53_PEDIDO = SC9.C9_PEDIDO             "
	cQuery	+= "                 AND Z53_FILIAL = SC9.C9_FILIAL             "
	cQuery	+= "                 AND Z53_CODPRO = SC9.C9_PRODUTO            "
	cQuery	+= "                 AND Z53.D_E_L_E_T_ = ' '))AS QtdLida       "
	cQuery	+= " FROM SC9010 SC9                                            "
	cQuery	+= " INNER JOIN SB1010 SB1 ON SC9.C9_PRODUTO = SB1.B1_COD       "
	cQuery	+= " AND SB1.D_E_L_E_T_ = ' '                                   "
	cQuery	+= " WHERE C9_PEDIDO = '"+Alltrim(cGetPed)+"'                   "
	cQuery	+= "   AND C9_FILIAL = '"+FWxFilial('SC9')+"'                   "
	cQuery	+= "   AND C9_CARGA <> ''                                       "
	cQuery	+= "   AND C9_NFISCAL = ''                                      "
	cQuery	+= "   AND SC9.D_E_L_E_T_ = ' '                                 "
	cQuery	+= " GROUP BY C9_PRODUTO,                                       "
	cQuery	+= "          B1_UPOSLOG,                                       "
	cQuery	+= "          B1_DESC                                           "

	//Executando a query
	oSay:SetText("Executando a consulta")

	cQuery := ChangeQuery(cQuery)
	PLSQuery(cQuery, "cQryTMP")

	//Se houve dados
	If ! cQryTMP->(EoF())

		//Pegando o total de registros
		DbSelectArea("cQryTMP")
		Count To nTotal
		cQryTMP->(DbGoTop())

		//Enquanto houver dados
		While ! cQryTMP->(EoF())

			//Muda a mensagem na regua
			nAtual++
			oSay:SetText("Adicionando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")

			If cQryTMP->QtdLida == cQryTMP->QtdPedido
				cQryTMP->(DbSkip())
			Else
				RecLock(cAliasTab, .T.)
				(cAliasTab)->XXPRODUTO  := cQryTMP->PRODUTO
				(cAliasTab)->XXPOSICAO  := cQryTMP->POSICAO
				(cAliasTab)->XXDESCRI   := cQryTMP->DESCRICAO
				(cAliasTab)->XXQTDPED   := cQryTMP->QtdPedido
				(cAliasTab)->XXQTDCON   := cQryTMP->QtdLida

				(cAliasTab)->(MsUnlock())

				cQryTMP->(DbSkip())

			Endif
		EndDo

	Else
		MsgStop("Não foram encontrados itens conferidos para esse pedido!", "Atencao")

		RecLock(cAliasTab, .T.)
		(cAliasTab)->XXPRODUTO := ""
		(cAliasTab)->XXPOSICAO := ""
		(cAliasTab)->XXDESCRI  := ""
		(cAliasTab)->XXQTDPED  := 0
		(cAliasTab)->XXQTDCON  := 0

		(cAliasTab)->(MsUnlock())
	EndIf

	cQryTMP->(DbCloseArea())
	(cAliasTab)->(DbGoTop())

	RestArea(aArea)
Return
