#Include "Totvs.ch"

/*
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
|| Programa  | TEDA021 | Autor | Leandro Marquardt       | Data | 29/06/2020 ||
||---------------------------------------------------------------------------||
|| Descricao | Tela para gravar as Ref NFe para aidicionar ao XML da nota    ||
||           | de exportacao                                                 ||
||---------------------------------------------------------------------------||
|| Parametros|                                                               ||
||---------------------------------------------------------------------------||
|| Retorno   |                                                               ||
||---------------------------------------------------------------------------||
||  Uso      | Especifico Primo Tedesco                                      ||
||---------------------------------------------------------------------------||
||                             ULTIMAS ALTERACOES                            ||
||---------------------------------------------------------------------------||
|| Programador  |  Data  | Motivo da Alteracao                               ||
||---------------------------------------------------------------------------||
||              |        |                                                   ||
||              |        |                                                   ||
||---------------------------------------------------------------------------||
-------------------------------------------------------------------------------*/
User Function TEDA021(cFilSC5,cPedido)

    Local aArea  := GetArea()
    Local aAlter := {"ZA2_REFNFE"}

    //Objetos da Janela
    Private oDlgPvt
    Private oMsGetZA2
    Private aHeadZA2 := {}
    Private aColsZA2 := {}
    Private aColsAux := {}
    Private oBtnSalv
    Private oBtnFech
    Private bLinOk   := {|| A020VALID()}
    Private lLinhaOk := .T.

    //Tamanho da Janela
    Private    nJanLarg    := 900
    Private    nJanAltu    := 500
    //Fontes
    Private    cFontUti   := "Tahoma"
    Private    oFontAno   := TFont():New(cFontUti,,-38)
    Private    oFontSub   := TFont():New(cFontUti,,-20)
    Private    oFontSubN  := TFont():New(cFontUti,,-20,,.T.)
    Private    oFontBtn   := TFont():New(cFontUti,,-14)

    //Criando o cabeçalho da Grid
    //              Título         Campo         Máscara                        Tamanho                    Decimal  Valid   Usado  Tipo F3  Combo
    aAdd(aHeadZA2, {" Chave NFe",  "ZA2_REFNFE", "",                            TamSX3("ZA2_REFNFE")[01],  0,       ".T.",  ".T.", "C", "", ""} )
    aAdd(aHeadZA2, {" Recno",      "XX_RECNO",   "@E 999,999,999,999,999,999",  005,                       0,       ".T.",  ".T.", "N", "", ""} )
    Processa({|| A020Acols(cFilSC5,cPedido)}, "Processando")

    //Criação da tela com os dados que serão informados
    DEFINE MSDIALOG oDlgPvt TITLE "XML Exportação" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

    // Labels gerais
    @ 004, 005 SAY "Filial"    SIZE 200, 030 FONT oFontSub  OF oDlgPvt COLORS RGB(031,073,125) PIXEL
    @ 014, 005 SAY cFilSC5     SIZE 200, 030 FONT oFontSubN OF oDlgPvt COLORS RGB(031,073,125) PIXEL
    @ 004, 050 SAY "Pedido"    SIZE 200, 030 FONT oFontSub  OF oDlgPvt COLORS RGB(031,073,125) PIXEL
    @ 014, 050 SAY cPedido     SIZE 200, 030 FONT oFontSubN OF oDlgPvt COLORS RGB(031,073,125) PIXEL
    // Botões
    @ 006, (nJanLarg/2-001)-(0052*04) BUTTON oBtnSalv  PROMPT "Imp.Lista Chaves"  SIZE 080, 018 OF oDlgPvt ACTION (A020LoadFile())   FONT oFontBtn PIXEL
    @ 006, (nJanLarg/2-001)-(0052*02) BUTTON oBtnSalv  PROMPT "Salvar"  SIZE 050, 018 OF oDlgPvt ACTION (A020Salvar(cFilSC5,cPedido))   FONT oFontBtn PIXEL
    @ 006, (nJanLarg/2-001)-(0052*01) BUTTON oBtnFech  PROMPT "Fechar"  SIZE 050, 018 OF oDlgPvt ACTION (oDlgPvt:End())                 FONT oFontBtn PIXEL
    
    
    

    // Carrega a grid
    oMsGetZA2 := MsNewGetDados():New(   029,;                //nTop      - Linha Inicial
                                        003,;                //nLeft     - Coluna Inicial
                                        (nJanAltu/2)-3,;     //nBottom   - Linha Final
                                        (nJanLarg/2)-3,;     //nRight    - Coluna Final
                                        GD_INSERT + GD_UPDATE + GD_DELETE,; //nStyle    - Estilos para edição da Grid (GD_INSERT = Inclusão de Linha; GD_UPDATE = Alteração de Linhas; GD_DELETE = Exclusão de Linhas)
                                        "Eval(bLinOk)",;     //cLinhaOk  - Validação da linha
                                        ,;                   //cTudoOk   - Validação de todas as linhas
                                        "",;                 //cIniCpos  - Função para inicialização de campos
                                        aAlter,;             //aAlter    - Colunas que podem ser alteradas
                                        ,;                   //nFreeze   - Número da coluna que será congelada
                                        9999,;               //nMax      - Máximo de Linhas
                                        ,;                   //cFieldOK  - Validação da coluna
                                        ,;                   //cSuperDel - Validação ao apertar '+'
                                        ,;                   //cDelOk    - Validação na exclusão da linha
                                        oDlgPvt,;            //oWnd      - Janela que é a dona da grid
                                        aHeadZA2,;           //aHeader   - Cabeçalho da Grid
                                        aColsZA2)            //aCols     - Dados da Grid
    ACTIVATE MSDIALOG oDlgPvt CENTERED

    RestArea(aArea)

Return

/*
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
|| Funcao    | A020Salvar | Autor | Leandro Marquardt   | Data |30/06/2020 ||
||-------------------------------------------------------------------------||
|| Descricao | Função que carrega o aCols                                  ||
||           |                                                             ||
||-------------------------------------------------------------------------||
|| Parametros|                                                             ||
||-------------------------------------------------------------------------||
|| Retorno   |                                                             ||
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------*/
Static Function A020Acols(cFilSC5,cPedido)

    Local aArea  := GetArea()

    dbSelectArea("ZA2")
    dbSetOrder(1)
	If dbSeek( cFilSC5 + cPedido)
        
		While !Eof() .And. ZA2->ZA2_FILIAL == cFilSC5 .And. ZA2->ZA2_NUM == cPedido

            //Adiciona o item no aCols
            aAdd(aColsZA2, { ZA2->ZA2_REFNFE,ZA2->(Recno()),.F. })
            
            ZA2->(dbSkip())

		EndDo

	EndIf

    RestArea(aArea)

Return

/*
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
|| Funcao    | A020Salvar | Autor | Leandro Marquardt   | Data |30/06/2020 ||
||-------------------------------------------------------------------------||
|| Descricao | Salva as manipulacoes dos registros                         ||
||           |                                                             ||
||-------------------------------------------------------------------------||
|| Parametros|                                                             ||
||-------------------------------------------------------------------------||
|| Retorno   |                                                             ||
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------*/
Static Function A020Salvar(cFilSC5,cPedido)

    Local aColsAux := oMsGetZA2:aCols
    Local nPosZA2  := aScan(aHeadZA2, {|x| Alltrim(x[2]) == "ZA2_REFNFE"})
    Local nPosRec  := aScan(aHeadZA2, {|x| Alltrim(x[2]) == "XX_RECNO"})
    Local nPosDel  := Len(aHeadZA2) + 1
    Local nLinha   := 0
    Local lGravou  := .T.

	If lLinhaOk

        dbSelectArea("ZA2")
        
		For nLinha := 1 To Len(aColsAux)
        
            //Posiciona no registro
			If aColsAux[nLinha][nPosRec] != 0
                ZA2->(DbGoTo(aColsAux[nLinha][nPosRec]))
			EndIf
            
            //Se a linha estiver excluída
			If aColsAux[nLinha][nPosDel]
                
                //Se não for uma linha nova
				If aColsAux[nLinha][nPosRec] != 0
                    
                    RecLock("ZA2", .F.)
                        DbDelete()
                    ZA2->(MsUnlock())

				EndIf
                
            //Se a linha for incluída
			ElseIf aColsAux[nLinha][nPosRec] == 0 .And. !Empty(aColsAux[nLinha][nPosZA2])
            
                RecLock("ZA2", .T.)
                    ZA2->ZA2_FILIAL := cFilSC5
                    ZA2->ZA2_NUM    := cPedido
                    ZA2->ZA2_REFNFE := aColsAux[nLinha][nPosZA2]
                ZA2->(MsUnlock())
            
            //Senão, será alteração
			Else

				If !Empty(aColsAux[nLinha][nPosZA2])

                    RecLock("ZA2", .F.)
                        ZA2->ZA2_REFNFE  := aColsAux[nLinha][nPosZA2]
                    ZA2->(MsUnlock())

				Else
                    Alert("Chave não preenchida, verifique.")
                    lGravou := .F.
				EndIf
            
			EndIf

		Next nX

		If lGravou
            MsgInfo("Registro salvo com sucesso.", "XML Exportação")
            oDlgPvt:End()
		EndIf

	Else
        Alert("Verifique a inconsistência nas linhas.")
	EndIf

Return

/*
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
|| Funcao    | A020VALID   | Autor | Leandro Marquardt   | Data |06/07/2020 ||
||-------------------------------------------------------------------------||
|| Descricao | Função para validar a linha adicionada                      ||
||           |                                                             ||
||-------------------------------------------------------------------------||
|| Parametros|                                                             ||
||-------------------------------------------------------------------------||
|| Retorno   |                                                             ||
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------*/
Static Function A020VALID()

    Local aColsAux := oMsGetZA2:aCols
    Local nPosZA2  := aScan(aHeadZA2, {|x| Alltrim(x[2]) == "ZA2_REFNFE"})
    Local nPosDel  := Len(aHeadZA2) + 1

    lRet := .T.

    // Se a linha não estiver excluída
	If !aColsAux[n][nPosDel]

		If ( nPos := aScan( aColsAux, {|x| Upper(x[nPosZA2]) == Upper(aColsAux[n][nPosZA2])} ) ) > 0 .And. nPos <> n

            Alert("Já existe um registro com chave igual a " + AllTrim(aColsAux[n][nPosZA2]))
            lRet := .F.

		EndIf

	EndIf

Return lRet

/*
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
|| Funcao    | A020RNFE   | Autor | Leandro Marquardt   | Data |06/07/2020 ||
||-------------------------------------------------------------------------||
|| Descricao | Função chamada no nfesefaz.prw para buscar as chaves de     ||
||           | referencia da nota de exportacao e adicionar ao XML         ||
||-------------------------------------------------------------------------||
|| Parametros|                                                             ||
||-------------------------------------------------------------------------||
|| Retorno   |                                                             ||
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------*/

/*/{Protheus.doc} A020RNFE
Localizar no fonte NFESEFAZ>PRW o bloco que consta "*SEM INTEGRAÇÃO COM EEC" e adicionar instrução  String += U_A020RNFE(aNota[1],aNota[2],cChaveRef) //Chaves de referência nota fiscal de Exportação
@type function
@version  2.0
@author solutio
@since 08/12/2021
@param cSerie, character, Série da Nota fiscal 
@param cNota, character, Número do documento 
@param cChaveRef, character, Chave de referência para evitar duplicidade
@return variant, Texto de tag <refNFe> adicionado
/*/
User Function A020RNFE(cSerie,cNota,cChaveRef)

    Local cChave := ""

    dbSelectArea("SD2")
    dbSetOrder(3) // D2_FILIAL+D2_DOC+D2_SERIE
	If dbSeek( xFilial("SD2") + cNota + cSerie )

        dbSelectArea("ZA2")
        dbSetOrder(1)
		If dbSeek( SD2->D2_FILIAL + SD2->D2_PEDIDO )
            
			While !ZA2->(Eof()) .And. ZA2->ZA2_FILIAL == SD2->D2_FILIAL .And. ZA2->ZA2_NUM == SD2->D2_PEDIDO
				If !AllTrim(ZA2->ZA2_REFNFE) $ cChaveRef
                    cChave += "<refNFe>" + AllTrim(ZA2->ZA2_REFNFE) + "</refNFe>"
				EndIf
                ZA2->(dbSkip())
			EndDo

		EndIf

	EndIf

Return cChave

/*
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
|| Funcao    | A020GAT    | Autor | Leandro Marquardt   | Data |06/07/2020 ||
||-------------------------------------------------------------------------||
|| Descricao | Função chamada no gatilho para preencher os campos do       ||
||           | complemento da exportação                                   ||
||-------------------------------------------------------------------------||
|| Parametros|                                                             ||
||-------------------------------------------------------------------------||
|| Retorno   |                                                             ||
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------*/
User Function A020GAT(nOpc)

    Local cRet := ""
    
	If nOpc = 1
        cRet := aCols[1][7]
	ElseIf nOpc = 2
        cRet := aCOls[1][27]
	ElseIf nOpc = 3
        cRet := aCols[1][28]
	EndIf

Return cRet




/*/{Protheus.doc} A020LoadFile
Escolhe arquivo para carga
@type function
@version 25
@author solutio
@since 09/07/2020
/*/
Static Function A020LoadFile()

	Local cEscolheuFile := .F.
	Local nHdl

	Private cDirDocs := MsDocPath() //"\dirdoc\co01\shared"
	Private cSPatch := "" //Patch do Servidor - Full
	Private cTPatch := "" //Patch do Terminal - Full

	WHILE !cEscolheuFile

		CTIPO := " "
		CTIPO += "Todos os arquivos   (*.txt)    | *.txt   | "
		cTPatch  := CGETFILE( CTIPO , "Seleção do arquivo .TXT para importação das Chaves NF-e",,"C:\" ) //,.T.,GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY+GETF_LOCALFLOPPY)
		cTPatch  := LOWER(ALLTRIM(cTPatch))


		If File(cTPatch)

			nHdl    := FT_FUSE(cTPatch)
			If nHdl == -1
				MsgAlert("O arquivo de nome "+ cTPatch +" nao pôde ser aberto! Verifique os parametros.","Atencao!")
				Return
			Else
				FT_FUSE() //desbloqueia o arquivo
			Endif

            cEscolheuFile := .T. 
			Processa({|| CopyToServer(cTPatch)},"Aguarde","Copiando Arquivo para o Servidor...",.f. )
			Processa({|| RunFile(cSPatch)},"Aguarde","Processando Arquivo...",.f.)

		ELSE

			IF !IW_MSGBOX("Não foi possível localizar o arquivo. Deseja Tentar novamente?",OemToAnsi("Arquivo..."),"YESNO")
				Return
			Endif

		ENDIF

	Enddo


Return

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºFun‡„o    ³CopyToServerº Autor MarcioQuevedoBorgesº Data ³  03/07/11   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescri‡„o ³ Funcao auxiliar chamada pela PROCESSA.  Copia arquivo para º±±
	±±º          ³ o servidor e armazena os caminhos                          º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ Programa principal                                         º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CopyToServer()

// cDirDocs := MsDocPath() //\dirdoc\co01\shared
	//Local aArq := {}
	Local cDrive, cDir, cNome, cExt
	SplitPath( cTPatch, @cDrive, @cDir, @cNome, @cExt )  //busca dados do endereço do arquivo

	cSPatch := cDirDocs +"\"+ cNome + cExt

	//Apaga arquivo no Servidor se já exsitir.
	IF FILE(cSPatch)
		FERASE(cSPatch)
	ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Coloca o Ponteiro do Cursos do Mouse em estado de Espera	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CursorWait()
	CpyT2S(cTPatch, cDirDocs, .T. )
	CursorArrow()	  	// Libera o Cursor

Return


Static Function RunFile()
	Local aColsAux := oMsGetZA2:aCols
	Local nHandle
	Local X_CHAVE := 1  // POSIÇÃO CHAVE
	Local nPos
	Local nLinha := 0
	Local nTamSx3 := TamSX3("ZA2_REFNFE")[1]
    Local nLenAcols  := 0 // tamanho array

	nHandle := FT_FUSE(cSPatch)

	if nHandle = -1
		MSGAlert("Erro abertura arquivo")
		lValidArq := .F.
		return
	endif

	nTamFile := FT_FLastRec()
	ProcRegua(nTamFile)


    //Apaga ultimo registro se estiver se chave não estiver preenchida
    nLenAcols := Len(aColsAux)

    If Empty(aColsAux[nLenAcols][X_CHAVE])
        ASIZE(aColsAux,nLenAcols-1)
    Endif 

	FT_FGOTOP()
	While !FT_FEOF()

		nLinha++
		IncProc("Importando  registro  " + STR(nLinha))

		cLinha := FT_FREADLN()
		cLinha := PADR(cLinha,nTamSx3)
		//oMsGetZA2
		nPos := aScan( aColsAux, {|x| Upper(x[X_CHAVE]) == Upper(cLinha)} )

		If Empty(nPos) .and. !Empty(cLinha)
			aAdd(aColsAux, { cLinha,0,.F. })
		Endif


		FT_FSKIP()
	EndDo
	FT_FUSE()

	oMsGetZA2:aCols := aColsAux
	oMsGetZA2:Refresh()

Return
