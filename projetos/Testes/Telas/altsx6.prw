#Include "Totvs.ch"
#INCLUDE "FWmvcdef.ch"

/*/{Protheus.doc} User Function zVid0039
Função para atualizar os parametros do SX6
@type  Function
@author Tiengo/Bruno Sperb
@since  27/02/2025
@version version
/*/

User Function altsx6()

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
	Private aColunas 	:= {}
	Private cAliasTab 	:= "TMP"
	//Tamanho da janela
	Private    aTamanho := MsAdvSize()
	Private    nJanLarg := aTamanho[5]
	Private    nJanAltu := aTamanho[6]

	//Cria a temporária
	oTempTable := FWTemporaryTable():New(cAliasTab)

	//Adiciona no array das colunas as que serão incluidas (Nome do Campo, Tipo do Campo, Tamanho, Decimais)
	aFields := {}

	aAdd(aFields, {"XXNOME",        "C", 10,    0,})
	aAdd(aFields, {"XXTIPO",        "C", 1,     0,})
	aAdd(aFields, {"XXDESCRI",      "C", 250,   0,})
	aAdd(aFields, {"XXCONTEUD",     "C", 250,   0,})

	//Define as colunas usadas, adiciona indice e cria a temporaria no banco
	oTempTable:SetFields( aFields )
	oTempTable:AddIndex("1", {"XXNOME"} )
	oTempTable:Create()

	//Monta o cabecalho
	fMontaHead()

	//Montando os dados, eles devem ser montados antes de ser criado o FWBrowse
	FWMsgRun(, {|oSay| fMontDados(oSay) }, "Processando", "Buscando Conferência")

	//Criando a janela
	DEFINE MSDIALOG oDlgGrp TITLE "Alterar Parâmetros" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	//Labels gerais
	@ 004, 003 SAY "SX6"      		 	SIZE 200, 030 FONT oFontAno  OF oDlgGrp COLORS RGB(149,179,215) PIXEL
	@ 004, 050 SAY "Listagem de"     	SIZE 200, 030 FONT oFontSub  OF oDlgGrp COLORS RGB(031,073,125) PIXEL
	@ 014, 050 SAY "Parâmetros"     	SIZE 200, 030 FONT oFontSubN OF oDlgGrp COLORS RGB(031,073,125) PIXEL

	//Botões
	@ 006, (nJanLarg/2-001)-(0052*01) BUTTON oBtnFech  PROMPT "Fechar" SIZE 050, 018 OF oDlgGrp ACTION (oDlgGrp:End())   FONT oFontBtn PIXEL
	@ 006, (nJanLarg/2-001)-(0110*01) BUTTON oBtnFech  PROMPT "Confirmar" SIZE 050, 018 OF oDlgGrp ACTION (fGrava())   FONT oFontBtn PIXEL

	//Dados
	@ 024, 003 GROUP oGrpDad TO (nJanAltu/2-003), (nJanLarg/2-003) PROMPT "Browse" OF oDlgGrp COLOR 0, 16777215 PIXEL
	oGrpDad:oFont := oFontBtn
	oPanGrid := tPanel():New(033, 006, "", oDlgGrp, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2 - 13),     (nJanAltu/2 - 45))
	oGetGrid := FWBrowse():New()

	//oGetGrid:DisableFilter()
	oGetGrid:DisableConfig()
	oGetGrid:DisableReport()
	oGetGrid:DisableSeek()
	oGetGrid:DisableSaveConfig()
	oGetGrid:SetFontBrowse(oFontBtn)
	oGetGrid:SetAlias(cAliasTab)
	oGetGrid:SetDataTable()
	oGetGrid:SetEditCell(.T., {|| .T.})
	oGetGrid:lHeaderClick := .F.
	oGetGrid:SetColumns(aColunas)
	oGetGrid:SetOwner(oPanGrid)
	oGetGrid:Activate()

	ACTIVATE MsDialog oDlgGrp CENTERED

	//Deleta a temporaria
	oTempTable:Delete()
	oGetGrid:DeActivate()

	RestArea(aArea)
Return

Static Function fMontaHead()

	Local nAtual
	Local aHeadAux := {}

	//Adicionando colunas [1] - Campo da Temporaria [2] - Titulo [3] - Tipo [4] - Tamanho [5] - Decimais [6] - Máscara
	aAdd(aHeadAux, {"XXNOME",       "Nome",           "C", 10,    0, "",    .F.})
	aAdd(aHeadAux, {"XXTIPO",       "Tipo",           "C", 1,     0, "",    .F.})
	aAdd(aHeadAux, {"XXDESCRI",     "Descricao",      "C", 250,   0, "",    .F.})
	aAdd(aHeadAux, {"XXCONTEUD",    "Conteudo",       "C", 250,   0, "",    .T.})

	//Percorrendo e criando as colunas
	For nAtual := 1 To Len(aHeadAux)
		oColumn := FWBrwColumn():New()
		oColumn:SetData(&("{|| " + cAliasTab + "->" + aHeadAux[nAtual][1] +"}"))
		oColumn:SetTitle(aHeadAux[nAtual][2])
		oColumn:SetType(aHeadAux[nAtual][3])
		oColumn:SetSize(aHeadAux[nAtual][4])
		oColumn:SetDecimal(aHeadAux[nAtual][5])
		oColumn:SetPicture(aHeadAux[nAtual][6])

		//Se for ser possível ter o duplo clique
		If aHeadAux[nAtual][7]
			oColumn:SetEdit(.T.)
			oColumn:SetReadVar(aHeadAux[nAtual][1])
		EndIf

		aAdd(aColunas, oColumn)
	Next
Return

Static Function fMontDados(oSay)

	Local aArea := FWGetArea()
	Local cQuery  := ""
	Local nAtual := 0
	Local nTotal := 0

	//Zera a grid
	aColsGrid := {}

	//Montando a query
	oSay:SetText("Montando a consulta")

	If FWSX6Util():ExistsParam("MV_ZALTPAR")
		cParam := GetMV("MV_ZALTPAR")
	Else
		cParam := SuperGetMV("MV_ZALTPAR", .F., "")
	Endif

	If ! Empty(cParam)

		cParam := "'"+Alltrim(cParam)
		cParam := StrTran(cParam ,"," ,"','")
		cParam := cParam + "'"
		cParam := StrTran(cParam ," " ,"")

	Endif

	cQuery	:= "SELECT X6_VAR AS Nome,			                                                    "
	cQuery	+= "       X6_TIPO AS Tipo,                                                             "
	cQuery	+= "       RTRIM(X6_DESCRIC) +''+ RTRIM(X6_DESC1) +''+ RTRIM(X6_DESC2) AS Descricao,    "
	cQuery	+= "       X6_CONTEUD AS Conteudo                                                       "
	cQuery	+= "FROM  "+RetSqlName("SX6") + " "                                                     "
	cQuery	+= "WHERE D_E_L_E_T_ = ' '                                                              "
	cQuery	+= "  AND X6_VAR IN ("+Alltrim(cParam)+")                                                "													   "

	//Executando a query
	oSay:SetText("Executando a consulta")

	cQuery := ChangeQuery(cQuery)
	PLSQuery(cQuery, "cQrySX6")

	//Se houve dados
	If ! cQrySX6->(EoF())

		//Pegando o total de registros
		DbSelectArea("cQrySX6")
		Count To nTotal
		cQrySX6->(DbGoTop())

		//Enquanto houver dados
		While ! cQrySX6->(EoF())

			//Muda a mensagem na regua
			nAtual++
			oSay:SetText("Adicionando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")

			RecLock(cAliasTab, .T.)

			(cAliasTab)->XXNOME     := cQrySX6->Nome
			(cAliasTab)->XXTIPO     := cQrySX6->Tipo
			(cAliasTab)->XXDESCRI   := cQrySX6->Descricao
			(cAliasTab)->XXCONTEUD  := cQrySX6->Conteudo

			(cAliasTab)->(MsUnlock())

			cQrySX6->(DbSkip())
		EndDo

	Else
		MsgStop("Não foram encontrados registros!", "Atencao")

		RecLock(cAliasTab, .T.)

		(cAliasTab)->XXNOME     := ""
		(cAliasTab)->XXTIPO     := ""
		(cAliasTab)->XXDESCRI   := ""
		(cAliasTab)->XXCONTEUD  := ""

		(cAliasTab)->(MsUnlock())
	EndIf

	cQrySX6->(DbCloseArea())
	(cAliasTab)->(DbGoTop())

	FWRestArea(aArea)

Return()

Static Function fGrava()

	Local aArea     := FWGetArea()

    (cAliasTab)->(DbGoTop())

    If ! (cAliasTab)->(EoF())

        While ! (cAliasTab)->(EoF())

            PutMV((cAliasTab)->XXNOME, (cAliasTab)->XXCONTEUD )

            (cAliasTab)->(DbSkip())

        Enddo
        
        FWAlertSuccess("Registros alterados com sucesso!", "SX6 - Parâmetros")
    
    Endif

	FWRestArea(aArea)
	oGetGrid:GoTop(.T.)
	oGetGrid:Refresh()

Return()
