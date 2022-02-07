//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"

//Constantes
#Define STR_PULA		Chr(13)+Chr(10)

/*/{Protheus.doc} TEDR006
Relatório - Relatorio Faturamento OF      
@author zReport
@since 17/09/2020
@version 1.0
	@example
	u_TEDR006()
/*/

User Function TEDR006()
	Private cVersao	  := "3.1" // a cada alteração modificar a versão 
	Private aParamBox := {}
	Private aRet      := {}

	Private aCombo1	:= {"Sintético","Analítico"}

	Private lExcel	:= ApOleClient("MSExcel")
	Private cArquivo := ""
	Private cTRB := GetNextAlias()
	Private aHeader := {}
	Private aCols:= {}


	//cArquivo := GetTempPath()+'superqry-temp-' + SUBSTR(cTime,1,2) + "H" + SUBSTR(cTime,4,2) + '.xml'

	aAdd(aParamBox,{2,"Tipo de Relatório","Sintético",aCombo1,50,"",.F.})
	aAdd(aParamBox,{1,"Filial  De",Space(4),"0102","","SM0","",0,.F.})
	aAdd(aParamBox,{1,"Filial Até",Space(4),"0102","","SM0","",0,.F.})
	aAdd(aParamBox,{1,"Data  De"  ,Ctod(Space(8)),"","","","",50,.F.}) // Tipo data
	aAdd(aParamBox,{1,"Data Até"  ,Ctod(Space(8)),"","","","",50,.F.}) // Tipo data
	aAdd(aParamBox,{1,"Produto  De",Space(15),"","","SB1","",0,.F.})
	aAdd(aParamBox,{1,"Produto Até",Space(15),"","","SB1","",0,.F.})

// Tipo 2 -> Combo
//           [2]-Descricao
//           [3]-Numerico contendo a opcao inicial do combo
//           [4]-Array contendo as opcoes do Combo
//           [5]-Tamanho do Combo
//           [6]-Validacao
//           [7]-Flag .T./.F. Parametro Obrigatorio ?

	aAdd(aParamBox,{6,"Arquivo de Salvamento ",Space(50),"","","",50,.F.,"Arquivo *.xml |*.xml"})
// Tipo 6 -> File
//           [2]-Descricao
//           [3]-String contendo o inicializador do campo
//           [4]-String contendo a Picture do campo
//           [5]-String contendo a validacao
//           [6]-String contendo a validacao When
//           [7]-Tamanho do MsGet
//           [8]-Flag .T./.F. Parametro Obrigatorio ?
//           [9]-Texto contendo os tipos de arquivo, exemplo: "Arquivos .CSV |*.CSV"
//           [10]-Diretorio inicial do cGetFile
// 			 [11]-Número relativo a visualização, podendo ser por diretório ou por arquivo (0,1,2,4,8,16,32,64,128)


	If ParamBox(aParamBox ,"Parametros ",aRet)

		Processa({|| GeraDados() }," Processando Consulta de Dados...")
		Processa({|| GeraPlanilha()}," Gerando Planilha...")

	EndIf



Return


Static Function GeraDados()

	Local cTDR006A 	:= SuperGetMV("ES_TDR006A",.F.,"'5122','5922','6122','5911','6911','5949','6151'")
	Local cSql := ""
	Local aFieldFill := {}
	Local aStru := {}
	Local nX


	IF MV_PAR01 ==  "Sintético"

		cSql += " With FATURAMENTO as (" + STR_PULA
	Endif
	cSql += " SELECT   D2_ITEM, D2_CF, D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA, A1_NOME, A1_NREDUZ," + STR_PULA
	cSql += "    CASE WHEN SUBSTRING(D2_CF,1,1) = '7' THEN 'EXPORT' ELSE 'NACIONAL' END AS DESTINO," + STR_PULA
	cSql += " 	CASE "+ STR_PULA
	cSql += " 	WHEN B1_POSIPI IN ('48191000') THEN 'CAIXA' "+ STR_PULA
	cSql += " 	WHEN B1_POSIPI LIKE '482390%'  THEN 'CAIXA' "+ STR_PULA
	cSql += " 	ELSE 'CHAPA' END AS TIPO_PROD,"+ STR_PULA
	cSql += " 	D2_EMISSAO, "+ STR_PULA
	cSql += " 	D2_QUANT, "+ STR_PULA
	cSql += " 	D2_QUANT*B1_AREA M2TOTAL, "+ STR_PULA
	cSql += " 	CASE WHEN D2_ITEM = '01' THEN (SELECT F2_PLIQUI FROM SF2980 WHERE F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA AND  D_E_L_E_T_<> '*') ELSE 0 END  AS    PESONOTA, -- INFORMA NO PRIMEIRO ITEM PARA NÃO DUPLICAR "+ STR_PULA
	cSql += " 	D2_COD, " + STR_PULA
	cSql += " 	B1_DESC, " + STR_PULA
	cSql += " 	B1_PESO, " + STR_PULA
	cSql += " 	B1_AREA," + STR_PULA
	cSql += " 	D2_VALBRUT + ISNULL( (SELECT SUM(DC.D2_VALBRUT) FROM "+ RetSqlName("SD2") + " DC WHERE DC.D2_TIPO= 'C' AND DC.D2_FILIAL = D2.D2_FILIAL AND DC.D2_NFORI = D2.D2_DOC AND DC.D2_SERIORI = D2.D2_SERIE AND DC.D2_ITEMORI = D2.D2_ITEM  AND DC.D2_CLIENTE = D2.D2_CLIENTE AND DC.D2_LOJA = D2.D2_LOJA AND  DC.D_E_L_E_T_<> '*') ,0) D2_VALBRUT," + STR_PULA
	cSql += " 	D2_VALIPI + ISNULL( (SELECT SUM(DC.D2_VALIPI) FROM "+ RetSqlName("SD2") + " DC WHERE DC.D2_TIPO= 'C' AND DC.D2_FILIAL = D2.D2_FILIAL AND DC.D2_NFORI = D2.D2_DOC AND DC.D2_SERIORI = D2.D2_SERIE AND DC.D2_ITEMORI = D2.D2_ITEM  AND DC.D2_CLIENTE = D2.D2_CLIENTE AND DC.D2_LOJA = D2.D2_LOJA AND  DC.D_E_L_E_T_<> '*') ,0) D2_VALIPI , " + STR_PULA
	cSql += " 	AVG(D2_VALIPI + ISNULL( (SELECT SUM(DC.D2_VALIPI) FROM "+ RetSqlName("SD2") + " DC WHERE DC.D2_TIPO= 'C' AND DC.D2_FILIAL = D2.D2_FILIAL AND DC.D2_NFORI = D2.D2_DOC AND DC.D2_SERIORI = D2.D2_SERIE AND DC.D2_ITEMORI = D2.D2_ITEM  AND DC.D2_CLIENTE = D2.D2_CLIENTE AND DC.D2_LOJA = D2.D2_LOJA AND  DC.D_E_L_E_T_<> '*') ,0)) OVER( PARTITION BY D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA  ) as IPI_MEDIO," + STR_PULA
	cSql += " 	D2_VALBRUT + ISNULL( (SELECT SUM(DC.D2_VALBRUT) FROM "+ RetSqlName("SD2") + " DC WHERE DC.D2_TIPO= 'C' AND DC.D2_FILIAL = D2.D2_FILIAL AND DC.D2_NFORI = D2.D2_DOC AND DC.D2_SERIORI = D2.D2_SERIE AND DC.D2_ITEMORI = D2.D2_ITEM  AND DC.D2_CLIENTE = D2.D2_CLIENTE AND DC.D2_LOJA = D2.D2_LOJA AND  DC.D_E_L_E_T_<> '*') ,0) - D2_VALIPI + ISNULL( (SELECT SUM(DC.D2_VALIPI) FROM "+ RetSqlName("SD2") + " DC WHERE DC.D2_TIPO= 'C' AND DC.D2_FILIAL = D2.D2_FILIAL AND DC.D2_NFORI = D2.D2_DOC AND DC.D2_SERIORI = D2.D2_SERIE AND DC.D2_ITEMORI = D2.D2_ITEM  AND DC.D2_CLIENTE = D2.D2_CLIENTE AND DC.D2_LOJA = D2.D2_LOJA AND  DC.D_E_L_E_T_<> '*') ,0) VLRSEMIPI" + STR_PULA
	cSql += " 	FROM " + RetSqlName("SD2") + " D2 " + STR_PULA
	cSql += " 		INNER JOIN "+ RetSqlName("SB1") + " B1" + STR_PULA
	cSql += " 			ON  B1_FILIAL = D2_FILIAL " + STR_PULA
	cSql += " 			AND B1_COD = D2_COD " + STR_PULA
	cSql += " 			AND B1.D_E_L_E_T_ <> '*' " + STR_PULA
	cSql += " 		INNER JOIN " + RetSqlName("SA1") + " A1 " + STR_PULA
	cSql += " 			ON  A1_FILIAL =  '" + xFilial("SA1") + "'" + STR_PULA
	cSql += " 			AND A1_COD = D2_CLIENTE " + STR_PULA
	cSql += " 			AND A1_LOJA = D2_LOJA " + STR_PULA
	cSql += " 			AND A1.D_E_L_E_T_ <> '*' " + STR_PULA
	//Classificação Fiscal Que estão sendo desconsideradas
	// 6151 - transferência
	// 5949 - Simples Remessa de Transporte (por falhas de envio de carragamento de transporte)
	// 5911 e 6911  - Amostras 
	// 6122 - Venda de Faturamento de operação triangular

	cSql += " 		WHERE D2_QUANT > 0 AND D2_CF NOT IN (" + cTDR006A + ") " + STR_PULA 
	// Filtro de Grupo através do NCM
	cSql += " AND (B1_POSIPI IN ('48191000','48081000') OR B1_POSIPI LIKE '482390%' ) "  + STR_PULA

	If EMPTY(MV_PAR02 + MV_PAR03)
		cSql += " 			 AND D2_FILIAL = '0102' "  + STR_PULA
	else
		cSql += " 			 AND D2_FILIAL BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "' "  + STR_PULA
	Endif
	If EMPTY(MV_PAR04 + MV_PAR05)
		cSql += "  AND  D2_EMISSAO LIKE '" + SUBSTR(DTOS(dDatabase),1,6) + "%' " + STR_PULA
	else
		cSql += "  AND  D2_EMISSAO BETWEEN '" + DTOS(MV_PAR04) + "' AND '" + DTOS(MV_PAR05) + "' "  + STR_PULA
	eNDIF
	If !EMPTY(MV_PAR06 + MV_PAR07)
		cSql += "  AND  D2_COD BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "' "  + STR_PULA
	Endif


	cSql += "  AND D2.D_E_L_E_T_ <> '*' " + STR_PULA

	IF MV_PAR01 ==  "Sintético"
		cSql += " )" + STR_PULA

		cSql += " SELECT  D2_EMISSAO, TIPO_PROD, SUM(D2_QUANT) QTD, SUM(M2TOTAL) M2_TOTAL, SUM(PESONOTA) PESONOTA, SUM(VLRSEMIPI) FAT_SEMIPI, SUM(D2_VALIPI) IPI_TOTAL, SUM(D2_VALBRUT) FAT_TOTAL, AVG(CASE WHEN IPI_MEDIO = 0 THEN NULL ELSE IPI_MEDIO END ) IPI_MEDIO," + STR_PULA
		cSql += " AVG(D2_VALBRUT/D2_QUANT) RS_KG_COM_IPI, AVG(VLRSEMIPI / D2_QUANT) RS_KG_SEM_IPI" + STR_PULA

		cSql += "  FROM FATURAMENTO " + STR_PULA
		cSql += " GROUP BY D2_EMISSAO, TIPO_PROD" + STR_PULA
	Endif
	cSql += " ORDER BY D2_EMISSAO, TIPO_PROD" + STR_PULA


	// Função padrão que executa a consulta e carrega na tabela cTRB
	MPSysOpenQuery( cSql, cTRB )

	aStru := (cTRB)->(DBSTRUCT())

	//Ajusta Tipo de Dados campos
	For nX := 1 to Len(aStru)
		cCampo := aStru[nX][1]
		aCampo := TamSX3(cCampo)
		If !Empty(aCampo)
			If aCampo[3] $'D/N'
				TCSetField(cTRB,cCampo,aCampo[3],aCampo[1],aCampo[2])
			Endif
		Endif

	Next nX

	aStru := (cTRB)->(DBSTRUCT())


	//Monta Cabeçalho de Campos
	For nX := 1 to Len(aStru)
		cCampo := aStru[nX][1]

		//If cTipo == "Titulo"
		cTitulo := AllTrim(FWX3Titulo(cCampo) )
		If Empty(cTitulo)
			cTitulo := cCampo
		Endif
		//Else
		//	cTitulo := cCampo
		//EndIf

		Aadd(aHeader,{ cTitulo, cCampo, "", aStru[nX][3], aStru[nX][4], ".T.", ".T.", aStru[nX][2] , "", "", "", ""} )
	Next nX

	// Se não tem dados, cria uma linha vazia
	If (cTRB)->( EOF() )
		Aadd(aCols, Array( Len(aStru) ) )
	Else
		// Faz a Leitura dos dados
		While  !(cTRB)->(EOF())

			For nX := 1 to Len(aStru)
				cCampo := aStru[nX][1]
				Aadd(aFieldFill,  &('(cTRB)->' + cCampo ))
			Next nX
			Aadd(aFieldFill, .F.) //Delete

			Aadd(aCols, aFieldFill)
			aFieldFill := {}


			(cTRB)->(DBSkip())
		Enddo
	EndIf
	(cTRB)->( DbCloseArea() )


Return

Static Function GeraPlanilha( )

	Local nX, nY
	Local nHdr := 0
	Local nModo //Modo do Tipo do Campo| 1 = Modo Texto ou data | 2 = Valor sem R$ | 3 = Valor com R$
	Local aLinha
	Local aArea := {}
	Local cAba01
	Local cTitTabela01
	Local cTmp := ""
	Local X_TIPO := 8
	Local X_TITULO := 1
	Local oFWMsExcel
	Local oExcel
	Local cTime := ""
	cArquivo := AllTrim(MV_PAR08)


	IF FILE(cArquivo)
		IF IW_MSGBOX("Arquivo '" + cArquivo + "' já existe. Deseja Substituir?","Arquivo", "YESNO")
			FERASE(cArquivo)
		else
			cArquivo := ""
		ENDIF
	ENDIF

	aArea    := GetArea()
	cTime    := time()
	If Empty(cArquivo)
		cArquivo := GetTempPath()+'tedr006-' + SUBSTR(cTime,1,2) + "h" + SUBSTR(cTime,4,2) + "s"+ SUBSTR(cTime,7,2) + '-'+ cVersao + '.xml'
	Endif

	If lExcel

		//Criando o objeto que irá gerar o conteúdo do Excel
		oFWMsExcel := FWMsExcel():New()
		oFWMsExcel:SetTitleBold(.T.) //Título Negrito

		//Aba 01 - Dados
		cAba01 := "Dados"
		cTitTabela01 := "Relatório de Faturamento - " + MV_PAR01  + " - versão " + cVersao
		oFWMsExcel:AddworkSheet(cAba01) //Não utilizar número junto com sinal de menos. Ex.: 1-
		//Criando a Tabela
		oFWMsExcel:AddTable(cAba01,cTitTabela01)
		//Criando Colunas
		//nModo :=
		For nX := 1 to Len(aHeader)
			DO CASE
			CASE  aHeader[nx,X_TIPO] $ 'C'
				nModo := 1 //1 = Modo Texto

			CASE  aHeader[nx,X_TIPO] $ 'D'
				nModo := 1
			CASE  aHeader[nx,X_TIPO] $ 'N'
				nModo := 2 //2 = Valor sem R$ | 3 = Valor com R$
			OTHERWISE
				nModo := 1
			END CASE

			oFWMsExcel:AddColumn(cAba01,cTitTabela01,aHeader[nx,X_TITULO],nModo)


		Next nX
		//Criando as Linhas


		For nX := 1 to Len(aCols)
			aLinha := {}
			For nY := 1 to LEN(aCols[nX])-1

				cConteudo := aCols[nX][nY]

				AADD(aLinha, cConteudo )

			Next nY
			oFWMsExcel:AddRow(cAba01,cTitTabela01,aLinha)


		Next nX

		//Aba 02 - Sql
		cAba02 := "Parâmetros"
		cTitTabela02 := 'Parâmetros do Relatório'

		oFWMsExcel:AddworkSheet(cAba02)
		//Criando a Tabela
		oFWMsExcel:AddTable(cAba02,cTitTabela02)
		oFWMsExcel:AddColumn(cAba02,cTitTabela02,"Parâmetro",1)
		oFWMsExcel:AddColumn(cAba02,cTitTabela02,"Conteúdo",1)

		// //Criando as Linhas... Enquanto não for fim da query
		For nX := 1 TO Len(aRet)
			//oFWMsExcel:AddRow(cAba02,cTitTabela02, { "Tipo de Relat.", aCombo1[MV_PAR01] })
			cConteudo := &("MV_PAR"+AllTrim(Strzero(nX,2)))
			DO CASE
				//CASE aParamBox[nX][1] == 2 //Combobox
				//	aCombo := aParamBox[nX][4]
				//	oFWMsExcel:AddRow(cAba02,cTitTabela02, { aParambox[nX][2],  aCombo[cConteudo] })
			CASE aParamBox[nX][1] == 2 .and. ValType("aParamBox[nx][3]") == 'D'
				oFWMsExcel:AddRow(cAba02,cTitTabela02, { aParambox[nX][2],  DTOC(cConteudo) })
			CASE aParamBox[nX][1] == 2 .and. ValType("aParamBox[nx][3]") == 'N'
				oFWMsExcel:AddRow(cAba02,cTitTabela02, { aParambox[nX][2],  STR(cConteudo) })
			OTHERWISE
				oFWMsExcel:AddRow(cAba02,cTitTabela02, { aParambox[nX][2],  cConteudo})
			END CASE
		Next nX
		oFWMsExcel:AddRow(cAba02,cTitTabela02, { "Data de Geração:",  DTOC(dDatabase) + " " + cTime })
		//Ativando o arquivo e gerando o xml
		oFWMsExcel:Activate()
		oFWMsExcel:GetXMLFile(cArquivo)
		oFWMsExcel:DeActivate()

		//Abrindo o excel e abrindo o arquivo xml
		oExcel := MsExcel():New()       //Abre uma nova conexão com Excel
		oExcel:WorkBooks:Open(cArquivo) //Abre uma planilha
		oExcel:SetVisible(.T.)          //Visualiza a planilha
		oExcel:Destroy()                //Encerra o processo do gerenciador de tarefas

		//--------------------------
		Sleep(2000) //espera 2 segundos para abrir arquivo
		IF IW_MSGBOX("Se o arquivo não abriu automaticamente, deseja tentar Reabrir?","Arquivo", "RETRYCANCEL")
			If !File(cArquivo)
				IW_MsgBox("Não foi possível localizar o arquivo: " + cArquivo,OemToAnsi("Arquivo..."),"INFO" )
			Else
				ShellExecute("open", cArquivo, "", GetTempPath(), 1)
			Endif
		Endif

	Else// Não tem Excel instalado

		// Pega o nome do arquivo, mas sem a extensão XML para usar o CSV
		cArquivo := Left( cArquivo, Len(cArquivo)-3 ) + "csv"

		nHdr := FCreate( cArquivo )
		If nHdr <= 0
			MsgInfo( 'Não foi possível criar o arquivo "' + cArquivo + '"'+CRLF+'Verifique se o arquivo está em uso.')
		Else
			// Carrega o Cabeçalho das colunas
			For nX := 1 to Len(aHeader)
				cTmp += cValToChar( aHeader[ nX, 1 ] ) + ";"
			Next nX
			FWrite( nHdr, cTmp + CRLF )

			// Carrega os dados para gerar cada Linha
			For nX := 1 to Len(aCols)

				cTmp := ""
				For nY := 1 to LEN(aCols[nX])-1
					cTmp += cValToChar( aCols[ nX, nY ] ) + ";"
				Next nY
				FWrite( nHdr, cTmp + CRLF )

			Next nX

			// No final gera uma linha com o SQL executado
			fWrite( nHdr, "Relatório TEDR006 - " + MV_PAR01 + CRLF)

			FClose( nHdr )
			ShellExecute("open", cArquivo, "", GetTempPath(), 1)
		EndIf
	EndIf

	RestArea(aArea)
Return
