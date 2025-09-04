#Include "TOTVS.ch"
#Include "PROTHEUS.ch"
#Include "TOPCONN.ch"
#Include 'FWMVCDEF.CH'

/*/{Protheus.doc} xCompRec
Este programa tem como objetivo gerar compensação em massa para os clientes selecionados
GAP 142 - Compensação a Receber
@type  Function
@author Tiengo Junior
@since 20/08/2025
@version version
@See https://centraldeatendimento.totvs.com/hc/pt-br/articles/7974002547607-Cross-Segmentos-Backoffice-Linha-Protheus-SIGAFIN-FINA330-Documenta%C3%A7%C3%A3o-execauto
/*/

User Function xCompRec()

	Local aArea 		:= FWGetArea()
	Local cClide    	:= ""
	Local cCliAte   	:= ""
	Local aAuxE1  		:= {}
	Local aAuxRA  		:= {}
	Local aRecE1  		:= {}
	Local aRecRA  		:= {}
	Local aPergs  		:= {}
	Local aClientes		:= {}
	Local cCliAtual		:= ""
	Local cLojAtual		:= ""
	Local nX			:= 0
	Local nY			:= 0
	Local nZ			:= 0

	Private aTitulos  	:= {}
	Private lok    		:= .F.

	//Adicionando os parametros do ParamBox
	aAdd(aPergs, {1, "Cliente De",  Space(TamSX3('A1_COD')[1]), "", "", "SA1CLI", 	"", 060,	.F.})
	aAdd(aPergs, {1, "Cliente Até", Space(TamSX3('A1_COD')[1]), "", "", "SA1CLI", 	"", 060,	.T.})
	aAdd(aPergs, {1, "Emissão de",	FirstDay(Date()), 			"", "", "",			"", 050,	.F.})
	aAdd(aPergs, {1, "Emissão até", LastDay(Date()), 			"", "", "",			"", 050,	.F.})

	//Se a pergunta for confirma, chama a tela
	If ParamBox(aPergs, 'Informe os parâmetros', /*aRet*/, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosx*/, /*nPosy*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
		cClide  	:= MV_PAR01
		cCliAte 	:= MV_PAR02
		dEmisIni 	:= MV_PAR03
		dEmisFim 	:= MV_PAR04
	EndIf

	If ! Empty(cCliAte)

		Processa({|| fBusca('RA', cClide, cCliAte, dEmisIni, dEmisFim)}, "Buscando...", , , , )

		aAuxRA := aTitulos

		If Len(aAuxRA) == 0 .or. ! lok
			Return()
		Endif

		//Limpa a variavel atitulos  e seta a variavel lOk para controlar se o usuário passou ou não pela função ProcRecno
		lok 		:= .F.
		aTitulos 	:= {}

		Processa({|| fBusca('E1', cClide, cCliAte, dEmisIni, dEmisFim)}, "Buscando...", , , , )

		aAuxE1 := aTitulos

		If Len(aAuxE1) == 0 .or. ! lok
			Return()
		Endif

		//faço a ordenação dos arrays para facilitar a busca dos clientes
		aSort(aAuxE1, , , {|x, y| x[1] + x[2] < y[1] + y[2]})
		aSort(aAuxRA, , , {|x, y| x[1] + x[2] < y[1] + y[2]})

		//Cria um array com os clientes únicos
		For nX := 1 To Len(aAuxE1)
			If nX == 1 .Or. (aAuxE1[nX][1] + aAuxE1[nX][2] <> aAuxE1[nX-1][1] + aAuxE1[nX-1][2])
				AAdd(aClientes, { aAuxE1[nX][1], aAuxE1[nX][2] })
			Endif
		Next nX

		//Carrega os parâmetros da FINA330 uma única vez
		Pergunte("FIN330", .F.)
		lContabiliza := (MV_PAR09 == 1)
		lDigita      := (MV_PAR07 == 1)
		lAglutina    := .F.

		For nY := 1 To Len(aClientes)

			cCliAtual    := aClientes[nY][1]
			cLojAtual    := aClientes[nY][2]

			aRecE1 := {}
			aRecRA := {}

			// Filtra os RECNOs dos títulos para o cliente atual.
			For nX := 1 To Len(aAuxE1)
				If aAuxE1[nX][1] == cCliAtual .And. aAuxE1[nX][2] == cLojAtual
					AAdd(aRecE1, aAuxE1[nX][3])
				Endif
			Next nX

			// Filtra os RECNOs dos adiantamentos (RA) para o cliente atual.
			For nZ := 1 To Len(aAuxRA)
				If aAuxRA[nZ][1] == cCliAtual .And. aAuxRA[nZ][2] == cLojAtual
					AAdd(aRecRA, aAuxRA[nZ][3])
				Endif
			Next nZ

			If Len(aRecE1) > 0 .And. Len(aRecRA) > 0

				If !MaIntBxCR(3, aRecE1, , aRecRA, , {lContabiliza, lAglutina, lDigita, .F., .F., .F.}, , , , , Nil, , , , ,)
					If ! IsBlind()
						FWAlertError("Não foi possível executar a compensação a receber do cliente: " + cCliAtual + "-" + cLojAtual)
					Endif
					Return()
				Endif
			Endif
		Next nY

		If ! IsBlind()
			FWAlertWarning("Processamento finalizado!", "Atenção")
		Endif
	Endif

	FWRestArea(aArea)

Return()

Static Function fBusca(cTipo, cClide, cCliAte, dEmisIni, dEmisFim, lOk)

	Local aArea      		:= FWGetArea()
	Local cQuery     		:= ""
	Local cAlias     		:= ""
	Local cTitulo 			:= ""
	Local aFields           := {}
	Local aColunas          := {}
	Local cTpQuery   		:= ""

	Private oMarkBrowse
	Private oTempTable
	Private aRotina   		:= MenuDef()
	Private cAliasTmp       := GetNextAlias()

	// Define o título da tela e o filtro de tipo para a query
	If cTipo == "RA"
		cTitulo := "Selecione os Adiantamentos (RA) para Compensar"
		cTpQuery  := " = 'RA' "
	Else
		cTitulo := "Selecione os Títulos a serem Compensados"
		cTpQuery  := " <> 'RA' "
	Endif

	//Adiciona no array das colunas as que serão incluidas (Nome do Campo, Tipo do Campo, Tamanho, Decimais)
	aAdd(aFields, { 'OK', 'C', 1, 0})
	aAdd(aFields, {"XXCLIENTE",  "C", TamSX3('E1_CLIENTE')[01],    	0})
	aAdd(aFields, {"XXLOJA",   	 "C", TamSX3('E1_LOJA') [01],    	0})
	aAdd(aFields, {"XXPREFIXO",  "C", TamSX3('E1_PREFIXO')[01],     0})
	aAdd(aFields, {"XXNUMERO",   "C", TamSX3('E1_NUM') [01],    	0})
	aAdd(aFields, {"XXPARCELA",  "C", TamSX3('E1_PARCELA')[01],    	0})
	aAdd(aFields, {"XXEMISSAO",  "D", TamSX3('E1_EMISSAO')[01],    	0})
	aAdd(aFields, {"XXSALDO",    "N", TamSX3('E1_SALDO')[01],    	0})
	aAdd(aFields, {"XXRECNO",    "N", 10,    						0})

	oTempTable:= FWTemporaryTable():New(cAliasTmp)
	oTempTable:SetFields(aFields)
	oTempTable:Create()

	//Monta o cabecalho
	aColunas :=fMontaHead()

	// Monta a query para buscar os títulos em aberto
	cQuery := " SELECT 	SE1.E1_CLIENTE, 		 												"
	cQuery += "        	SE1.E1_LOJA, 															"
	cQuery += "		   	SE1.E1_PREFIXO, 														"
	cQuery +=  "		SE1.E1_NUM, 															"
	cQuery +=  "		SE1.E1_PARCELA, 														"
	cQuery +=  "		SE1.E1_EMISSAO, 														"
	cQuery +=  "		SE1.E1_SALDO,   														"
	cQuery +=  "		SE1.R_E_C_N_O_  														"
	cQuery += " FROM " + RetSqlName("SE1") + " SE1 												"
	cQuery += " WHERE SE1.D_E_L_E_T_ = ' ' 														"
	cQuery += "   AND SE1.E1_FILIAL = '" + FWxFilial('SE1') + "' 								"
	cQuery += "   AND SE1.E1_CLIENTE >= '" + cClide + "'										"
	cQuery += "   AND SE1.E1_CLIENTE <= '" + cCliAte + "'										"
	cQuery += "   AND SE1.E1_EMISSAO >= '" + DtoS(dEmisIni) + "'								"
	cQuery += "   AND SE1.E1_EMISSAO <= '" + DtoS(dEmisFim) + "'								"
	cQuery += "   AND SE1.E1_TIPO " + cTpQuery + "												"
	cQuery += "   AND SE1.E1_SALDO > 0 															"
	cQuery += "   AND SE1.E1_BAIXA = ' ' 														"
	cQuery += " ORDER BY E1_CLIENTE, E1_LOJA, E1_EMISSAO 										"

	cQuery := ChangeQuery(cQuery)
	cAlias := MPSysOpenQuery(cQuery)

	If (cAlias)->(EoF())
		If ! IsBlind()
			FWAlertWarning("Nenhum titulo foi encontrado para compensação!", "Atenção")
		Endif
		Return()
	Endif

	// Prepara o array para o FWMarkBrowse
	While ! (cAlias)->(EoF())

		RecLock(cAliasTmp, .T.)

		(cAliasTmp)->XXCLIENTE    	:= (cAlias)->E1_CLIENTE
		(cAliasTmp)->XXLOJA       	:= (cAlias)->E1_LOJA
		(cAliasTmp)->XXPREFIXO    	:= (cAlias)->E1_PREFIXO
		(cAliasTmp)->XXNUMERO     	:= (cAlias)->E1_NUM
		(cAliasTmp)->XXPARCELA    	:= (cAlias)->E1_PARCELA
		(cAliasTmp)->XXEMISSAO    	:= StoD((cAlias)->E1_EMISSAO)
		(cAliasTmp)->XXSALDO      	:= (cAlias)->E1_SALDO
		(cAliasTmp)->XXRECNO		:= (cAlias)->R_E_C_N_O_

		(cAliasTmp)->(MsUnlock())

		(cAlias)->(DbSkip())
	Enddo

	(cAlias)->(DbCloseArea())

	oMarkBrowse := FWMarkBrowse():New()
	oMarkBrowse:SetAlias(cAliasTmp)
	oMarkBrowse:SetDescription(cTitulo)
	oMarkBrowse:SetFieldMark('OK')
	oMarkBrowse:SetTemporary(.T.)
	oMarkBrowse:SetColumns(aColunas)

	oMarkBrowse:Activate()

	//Deleta a temporária e desativa a tela de marcação
	oTempTable:Delete()
	oMarkBrowse:DeActivate()

	FwRestArea(aArea)

Return()

Static Function fMontaHead()

	Local nAtual
	Local aHeadAux := {}
	Local aColunas := {}
	Local oColumn

	AAdd(aHeadAux, {"OK"           , "C", 1 , 0})
	aAdd(aHeadAux, {"XXCLIENTE",  "Cliente",     		"C", TamSX3('E1_CLIENTE')[01], 	0, "",  .F.})
	aAdd(aHeadAux, {"XXLOJA",     "Loja",     			"C", TamSX3('E1_LOJA')[01], 	0, "",  .F.})
	aAdd(aHeadAux, {"XXPREFIXO",  "Prefixo",           	"C", TamSX3('E1_PREFIXO')[01],  0, "",  .F.})
	aAdd(aHeadAux, {"XXNUMERO",   "Numero",          	"C", TamSX3('E1_NUM')[01], 	    0, "",  .F.})
	aAdd(aHeadAux, {"XXPARCELA",  "Parcela",          	"C", TamSX3('E1_PARCELA')[01],  0, "",  .F.})
	aAdd(aHeadAux, {"XXEMISSAO",  "Data Emissao",       "D", TamSX3('E1_EMISSAO')[01],	0, "",  .F.})
	aAdd(aHeadAux, {"XXSALDO",    "Saldo",         	    "N", TamSX3('E1_SALDO')[01],	2, "",  .F.})

	//Percorrendo e criando as colunas
	For nAtual := 2 To Len(aHeadAux)
		oColumn := FWBrwColumn():New()
		oColumn:SetData(&("{|| " + cAliasTmp + "->" + aHeadAux[nAtual][1] +"}"))
		oColumn:SetTitle(aHeadAux[nAtual][2])
		oColumn:SetType(aHeadAux[nAtual][3])
		oColumn:SetSize(aHeadAux[nAtual][4])
		oColumn:SetDecimal(aHeadAux[nAtual][5])
		oColumn:SetPicture(aHeadAux[nAtual][6])

		aAdd(aColunas, oColumn)
	Next

Return(aColunas)

Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Processar' ACTION 'u_ProcRecno()' OPERATION 2 ACCESS 0

Return(aRotina)

User Function ProcRecno()

	Local aArea  	:= FWGetArea()
	Local cMarca 	:= oMarkBrowse:Mark()

	aTitulos := {}

	(cAliasTmp)->( dbGoTop() )

	While ! (cAliasTmp)->( EOF() )
		If oMarkBrowse:IsMark(cMarca)
			AAdd(aTitulos, { (cAliasTmp)->XXCLIENTE, (cAliasTmp)->XXLOJA, (cAliasTmp)->XXRECNO })
		EndIf
		(cAliasTmp)->( dbSkip() )
	Enddo

	lok := .T.

	FWRestArea(aArea)
	CloseBrowse()

Return()
