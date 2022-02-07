//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"

//Constantes
#Define STR_PULA		Chr(13)+Chr(10)

/*/{Protheus.doc} TEDR008
Relatório de Produção      
@author zReport
@since 17/09/2020
@version 1.0
	@example
	u_TEDR006()
/*/

User Function TEDR008()
	//Local cPerg := "004       "

	Private cVersao	  := "1" // a cada alteração modificar a versão
	Private aParamBox := {}
	Private aRet      := {}

	Private aCombo1	:= {'1=Turma A','2=Turma B','3=Turma C','4=Turma D'}
	Private aCombo2	:= {'1=Turno1','2=Turno2','3=Turno3','4=Turno4' }

	Private lExcel	:= ApOleClient("MSExcel")
	Private cArquivo := ""
	Private cTRB := GetNextAlias()
	Private aHeader := {}
	Private aCols:= {}
	Private aX3Combos :={}



	//If Pergunte(cPerg,.T.)

    
	//cArquivo := GetTempPath()+'superqry-temp-' + SUBSTR(cTime,1,2) + "H" + SUBSTR(cTime,4,2) + '.xml'

	aAdd(aParamBox,{1,"Período  De"  ,Ctod(Space(8)),"","","","",50,.F.}) // Tipo data
	aAdd(aParamBox,{1,"Período Até"  ,Ctod(Space(8)),"","","","",50,.F.}) // Tipo data
	aAdd(aParamBox,{1,"Máquina De ",Space(Tamsx3("H6_RECURSO")[1]),"","","SH1","",0,.F.})
	aAdd(aParamBox,{1,"Máquina Até",Space(Tamsx3("H6_RECURSO")[1]),"","","SH1","",0,.F.})
	aAdd(aParamBox,{2,"Turma  De ",1,aCombo1,50,"",.F.})//1=Turma A;2=Turma B;3=Turma C;4=Turma D 
	aAdd(aParamBox,{2,"Turma  Até",4,aCombo1,50,"",.F.})//1=Turma A;2=Turma B;3=Turma C;4=Turma D 
	aAdd(aParamBox,{2,"Turno  De ",1,aCombo2,50,"",.F.}) //1=Turno1;2=Turno2;3=Turno3;4=Turno4 
	aAdd(aParamBox,{2,"Turno  Até",4,aCombo2,50,"",.F.}) //1=Turno1;2=Turno2;3=Turno3;4=Turno4 
	*/
	/*
	aAdd(aParamBox,{2,"Tipo de Relatório","Sintético",aCombo1,50,"",.F.})
	aAdd(aParamBox,{1,"Filial  De",Space(4),"0102","","SM0","",0,.F.})
	aAdd(aParamBox,{1,"Filial Até",Space(4),"0102","","SM0","",0,.F.})
	
	

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

*/
	If ParamBox(aParamBox ,"Parametros ",aRet)

		Processa({|| GeraDados() }," Processando Consulta de Dados...")
		Processa({|| GeraPlanilha()}," Gerando Planilha...")

	EndIf



Return


Static Function GeraDados()

	Local cSql := ""
	Local aFieldFill := {}
	Local aStru := {}
	Local nX


	cSql += " SELECT H6_FILIAL, C2_CLIENTE, H6_OP, C2_EMISSAO,H6_PRODUTO, B1_DESC, H6_RECURSO AS MAQUINA, H6_NRJUMBO ,H6_POSBOBI ,H6_DTAPONT, H6_LOTECTL ,H6_TURNO,H6_TURMA,H6_XETIQ ,H6_QTDPROD "  + STR_PULA
	cSql += " FROM " + RetSqlName("SH6") + " SH6 " + STR_PULA
	cSql += " 						INNER JOIN " + RetSqlName("SC2") + " C2 "+ STR_PULA
	cSql += " 							ON  C2_FILIAL = H6_FILIAL "+ STR_PULA
	cSql += " 							AND C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD = H6_OP "+ STR_PULA
	cSql += " 							AND C2.D_E_L_E_T_  <> '*' "+ STR_PULA
	cSql += " 						INNER JOIN " + RetSqlName("SB1") + " B1 "+ STR_PULA
	cSql += " 							ON B1_FILIAL = H6_FILIAL "+ STR_PULA
	cSql += " 							AND B1_COD = H6_PRODUTO "+ STR_PULA
	cSql += " 							AND B1.D_E_L_E_T_  <> '*' "+ STR_PULA
	cSql += " 	WHERE   "+ STR_PULA
	cSql += " 		H6_FILIAL = '" + xFilial("SH6")+ "'	"+ STR_PULA
	cSql += " 	AND H6_DTAPONT BETWEEN '"+ DTOS(MV_PAR01) +"' AND '" + DTOS(MV_PAR02) +"' "+ STR_PULA //--SH6->Apontamento Maior ou igual a  MV_PAR01    E   SH6->Apontamento Menor ou igual a   MV_PAR02
	cSql += "  	AND H6_RECURSO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "+ STR_PULA//  --//E   SH6->Recurso Maior ou igual a  MV_PAR03    E   SH6->Recurso Menor ou igual a   MV_PAR04
	cSql += " 	AND H6_TURMA BETWEEN '"+ AllTrim(str(MV_PAR05)) + "' AND '" + AllTrim(str(MV_PAR06))+ "' "+ STR_PULA //		--//E   SH6->Turma Maior ou igual a  MV_PAR05 E   SH6->Turma Menor ou igual a   MV_PAR06
	cSql += " 	AND H6_TURNO BETWEEN '"+ AllTrim(str(MV_PAR07)) + "' AND '"+ AllTrim(str(MV_PAR08)) + "' "+ STR_PULA //--		// E   SH6->Turno Maior ou igual a  MV_PAR07 E   SH6->Turno Menor ou igual a   MV_PAR08
	cSql += " 	AND SH6.D_E_L_E_T_  <> '*'"



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

		If Empty(GetSX3Cache(cCampo, "X3_CBOX"))
			Aadd(aX3Combos,"")
		Else 
			Aadd(aX3Combos,RetSX3Box(GetSX3Cache(cCampo, "X3_CBOX"),,,1)) 
		Endif 
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
	Local nAlign := 1 //Alinhamento da coluna ( 1-Left,2-Center,3-Right )
	Local nFormat := 1 //Codigo de formatação ( 1-General,2-Number,3-Monetário,4-DateTime )	 //Modo do Tipo do Campo| 1 = Modo Texto ou data | 2 = Valor sem R$ | 3 = Valor com R$
	Local ltotal := .F. //Indica se a coluna deve ser totalizada
	Local cPicture // Mascara de picture a ser aplicada. Somente para campos numéricos

	Local aLinha
	Local aArea := {}
	Local cAba01
	Local cTitTabela01
	Local cTmp := ""
	Local X_TIPO := 8
	Local X_TITULO := 1
	Local X_CAMPO := 2
	Local oFWMsExcel
	Local oExcel
	Local cTime := ""

	Local nPos := 0 
	//cArquivo := AllTrim(MV_PAR08)


	/*
	IF FILE(cArquivo)
		IF IW_MSGBOX("Arquivo '" + cArquivo + "' já existe. Deseja Substituir?","Arquivo", "YESNO")
			FERASE(cArquivo)
		else
			cArquivo := ""
		ENDIF
	ENDIF
*/
	aArea    := GetArea()
	cTime    := time()
	If Empty(cArquivo)
		cArquivo := GetTempPath()+'tedr008-' + SUBSTR(cTime,1,2) + "h" + SUBSTR(cTime,4,2) + "s"+ SUBSTR(cTime,7,2) + '-'+ cVersao + '.xlsx'
	Endif

	If lExcel

		//Criando o objeto que irá gerar o conteúdo do Excel
		//oFWMsExcel := FWMsExcel():New()
		oFWMsExcel := FWMsExcelXlsx():New()
		//oFWMsExcel:SetTitleBold(.T.) //Título Negrito

		//Aba 01 - Dados
		cAba01 := "Dados"
		cTitTabela01 := "Relatório de Produção  - versão " + cVersao
		oFWMsExcel:AddworkSheet(cAba01) //Não utilizar número junto com sinal de menos. Ex.: 1-
		//Criando a Tabela
		oFWMsExcel:AddTable(cAba01,cTitTabela01)
		//Criando Colunas
		//nModo :=
		For nX := 1 to Len(aHeader)
			DO CASE
			CASE  aHeader[nx,X_TIPO] $ 'C'

				nAlign := 1
				cPicture := ""
				nFormat := 1 //GERAL
			CASE  aHeader[nx,X_TIPO] $ 'D'
				nAlign := 3
				cPicture := ""
				nFormat := 4 //datetime
			CASE  aHeader[nx,X_TIPO] $ 'N'

				nAlign := 3
				cPicture := GetSX3Cache(aHeader[nx,X_CAMPO], "X3_PICTURE") 
				nFormat := 2 //Number
			OTHERWISE
				nAlign := 3
				cPicture := ""
				nModo := 1
			END CASE

			oFWMsExcel:AddColumn(cAba01,cTitTabela01,aHeader[nx,X_TITULO],nAlign,nFormat,lTotal,cPicture)


		Next nX
		//Criando as Linhas


		For nX := 1 to Len(aCols)
			aLinha := {}
			For nY := 1 to LEN(aCols[nX])-1
				If !Empty(aX3Combos[nY])
					nPos := aScan(aX3Combos[nY],{|x| x[2] == aCols[nX][nY] })
					cConteudo := aX3Combos[nY][npos][3]
				Else
					cConteudo := aCols[nX][nY]
				Endif  
				

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
		oFWMsExcel:AddRow(cAba02,cTitTabela02, { "Filial Corrente",  cFilAnt })
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
			fWrite( nHdr, "Relatório TEDR008 - "  + CRLF)

			FClose( nHdr )
			ShellExecute("open", cArquivo, "", GetTempPath(), 1)
		EndIf
	EndIf

	RestArea(aArea)
Return
