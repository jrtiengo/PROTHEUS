#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} fAtuDtRJE
Programa para atualizaÃ§Ã£o dos campos RJE_DTEVE e RJE_TPAFA
@type  user Function
@version 1.0
/*/
User Function AtuDtRJE()

    Local cTitle        := "Preenchimento dos campos RJE_DTEVE e RJE_TPAFA"
    Local aObjCoords	:= {}
    Local aItens 		:= {}
    Local bFecha		:= {||oDlg:End()}   
    Local bProc			:= {||Iif( fTdOk1(nRadio), (fProc(nRadio, aItens), nOpcA := 1), Nil)}
    Local bDoc  		:= {|| ShellExecute("open","https://tdn.totvs.com/x/yEpYJw","","",1) }
    Local cMsg          := ""
    Local oCheck1

    //Habilitar conforme cada evento seja ajustado para ler os novos campos
    Local lInt2200	    := .F.
    Local lInt2205      := .F.
    Local lInt2206      := .F.
    Local lInt2230      := .T.
    Local lInt2299      := .F.
    Local lInt2300      := .F.
    Local lInt2306      := .F.
    Local lInt2399      := .F.

    Private aTitle		:= {}
    Private aLog        := {} 
    Private nRadio		:= 1
    Private oDlg

    If !(RJE->(ColumnPos("RJE_DTEVE")) > 0 .And. RJE->(ColumnPos("RJE_TPAFA")) > 0)
		MsgInfo("Os campos RJE_DTEVE e RJE_TPAFA não foram encontrados no ambiente. Execute o UPDDISTR com a última liberação da expedição contínua do RH.")
        Return
	EndIf

    cMsg := CRLF + "Esta rotina tem por objetivo preencher os campos 'RJE_DTEVE' e 'RJE_TPAFA' para os eventos não periódicos, "
    cMsg += "com isto haverá a possilidade de execução de filtro por data para estes eventos no Monitor Middleware." + CRLF + CRLF
    cMsg += "Consulte nossa documentação para melhor entendimento."  + CRLF
    cMsg := OemToAnsi(cMsg)

    //------------------------------
    //| Criação das medidas da tela 
    //------------------------------
    aAdvSize		:= MsAdvSize( .F.,.F.,480)
    aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 15 }
        
    aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
    aObjSize			:= MsObjSize( aInfoAdvSize , aObjCoords )

    //----------------------------------
    //| Criação da tela de Apresentação 
    //------------------------------------------------
    Define MsDialog oDlg FROM 0, 0 To 360, 720 Title cTitle Pixel

	//Cria o conteiner onde serão colocados os paineis
	oTela1	:= FWFormContainer():New( oDlg )
	cIdTel1	:= oTela1:CreateHorizontalBox( 30 )
	cIdTel2	:= oTela1:CreateHorizontalBox( 70 )

    oTela1:Activate( oDlg, .F. )

    //Cria os paineis onde serao colocados os browses
    oPanel1	:= oTela1:GeTPanel(cIdTel1)
    oPanel2	:= oTela1:GeTPanel(cIdTel2)

    //------------------
    //| Primeiro Painel
    //| Descrição da rotina
    //---------------------------------
    @ 0, aObjSize[1,2] GROUP oGroup TO 50 ,aObjSize[1,4]*0.50 LABEL OemToAnsi("Sobre este ajuste") OF oPanel1  PIXEL

    @ aObjSize[1,1]*0.5, aObjSize[1,2]+2 SAY cMsg SIZE 300,300 OF oPanel1 PIXEL

    //-----------------
    //| Segundo Painel
    //| Armazena os checkbox com todos os eventos
    //-----------------------------------------------------
    @ 0, aObjSize[1,2] GROUP oGroup TO 90 ,aObjSize[1,4]*0.50 LABEL OemToAnsi("Selecione o evento") OF oPanel2  PIXEL

    Iif(lInt2200, Aadd(aItens, OemToAnsi("S-2200 - Cadastramento Inicial do vínculo e Admissão/Ingresso de Trabalhador") ),"")
    Iif(lInt2205, Aadd(aItens, OemToAnsi("S-2205 - Alteração de Dados Cadastrais do Trabalhador") ),"")
    Iif(lInt2206, Aadd(aItens, OemToAnsi("S-2206 - Alteração de Contrato de Trabalho") ),"")
    Iif(lInt2230, Aadd(aItens, OemToAnsi("S-2230 - Afastamento Temporário") ),"")
    Iif(lInt2299, Aadd(aItens, OemToAnsi("S-2299 - Desligamento") ),"")
    Iif(lInt2300, Aadd(aItens, OemToAnsi("S-2300 - Trabalhador Sem Vínculo de Emprego/Estatutário - Início") ),"")
    Iif(lInt2306, Aadd(aItens, OemToAnsi("S-2306 - Trabalhador Sem Vínculo de Emprego/Estatutário - Alteração Contratual") ),"")
    Iif(lInt2399, Aadd(aItens, OemToAnsi("S-2399 - Trabalhador Sem Vínculo de Emprego/Estatutário - Término") ),"")
            
    //Cria o RadioButton		
    oCheck1 := TRadMenu():New ( aObjSize[1,1]*0.750, aObjSize[1,2]+005, aItens, /*4*/,oPanel2,/*6*/,/*7*/,/*8*/,/*9*/,/*10*/,/*11*/,/*12*/,250,060,/*15*/,/*16*/,/*17*/,.T.)
    oCheck1:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)} 

	//-------------------
	//| Criação dos botões
	//| Realiza a criação das ações dos botões
	//-----------------------------------------------------
	oBtDoc  	:= TButton():New( aObjSize[1,1]*11.000, aObjSize[1,2]+15+45, "&" + OemToAnsi("Documentação"),NIL,bDoc	, 080 , 012 , NIL , NIL , NIL , .T. )
    oBtProc 	:= TButton():New( aObjSize[1,1]*11.000, aObjSize[1,2]+15+145, "&" + OemToAnsi("Processar"),NIL,bProc	, 060 , 012 , NIL , NIL , NIL , .T. )
	oBtFechar	:= TButton():New( aObjSize[1,1]*11.000, aObjSize[1,2]+15+225, "&" + OemToAnsi("Fechar"),NIL,bFecha , 040 , 012 , NIL , NIL , NIL , .T. )

    ACTIVATE MSDIALOG oDlg CENTERED

Return


/*/{Protheus.doc} fTdOk1
Valida se há eventos selecionados
@type  static Function
@version 1.0
/*/
Static Function fTdOk1(nRadio)

    Local lRet  := .F.

    Default nRadio := 0

    If nRadio > 0
        lRet := .T.
    EndIf

Return lRet


/*/{Protheus.doc} fProc
Processa o evento selecionado
@type  static Function
@version 1.0
/*/
Static Function fProc(nRadio, aItens)

    Local cEvent    := ""

    Default nRadio  := 0
    Default nRadio  := 0

    aLog := {} 
    
    If nRadio > 0 .And. !Empty(aItens)
        cEvent := STRTRAN(SUBSTR(aItens[nRadio],1,6), "-")
    EndIf

    //Efetua o processamento de geração
    Aadd( aTitle, OemToAnsi( "Registros Ajustados:" ) )
    Aadd( aLog, {} )
    ProcGpe( {|lEnd| fProcessa(cEvent)},,,.T. )
    fMakeLog(aLog,aTitle,,,"ATUDTRJE",OemToAnsi("Log de Ocorrências"),"M","P",,.F.)

Return 


/*/{Protheus.doc} fProcessa
Processa o evento selecionado
@type  static Function
@version 1.0
/*/
Static Function fProcessa(cEvento)

    Local aArea		:= GetArea()
    Local cAliasQry := GetNextAlias()
    Local cTpAfa    := ""
    Local cWhere    := ""
    Local dDtEve	:= CTOD("//")
    Local lProc     := .F.

    Default cEvento := ""

    If !Empty(cEvento)

        cWhere += "RJE_EVENTO = '" + cEvento + "' "

        //Prepara a variável para uso no BeginSql
        cWhere := "%" + cWhere + "%"

        //Processa a query e cria a tabela temporária com os resultados
        BeginSql alias cAliasQry
            SELECT RJE_FIL, RJE_TPINSC, RJE_INSCR, RJE_EVENTO, RJE_KEY, RJE_XML, R_E_C_N_O_
            FROM %table:RJE% RJE
            WHERE %exp:cWhere% 
            AND RJE.%NotDel%
        EndSql 

        While (cAliasQry)->( !EoF() )

            lProc   := .T.
            dDtEve  := CTOD("//")
            cTpAfa  := ""

            RJE->( dbGoTo((cAliasQry)->R_E_C_N_O_) )

            //Não processa registros que tenham o campo RJE_XML vazio
            If Empty(RJE->RJE_XML)
                (cAliasQry)->(dbSkip())
                Loop
            EndIf

            fGetAltXML(RJE->RJE_EVENTO, RJE->RJE_XML, @cTpAfa, @dDtEve, alltrim(RJE->RJE_KEY))

            If RecLock("RJE",.F.)
                RJE->RJE_DTEVE	:= dDtEve
                RJE->RJE_TPAFA	:= cTpAfa	
                RJE->(MsUnlock())

                //Adiciona no log de ocorrências
                 aAdd( aLog[1], "Registro (RJE_KEY) de chave: " + (cAliasQry)->RJE_KEY + " Processado com sucesso")
            EndIf

            (cAliasQry)->(dbSkip())
        EndDo

        If !lProc
            aAdd( aLog[1], OemToAnsi("Não foram encontrados registros do evento para processamento."))
        EndIf

        //Fecha a tabela temporária da query
        (cAliasQry)->( dbCloseArea() )

    EndIf

    RestArea(aArea)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fGetAltXML()
FunÃ§Ã£o utilizda para retornar os dados do XML
@version V 1.0
@param cEvent		= Evento
@param cXML			= XML
@param cTpAfa		= Tipo do Afastamento
@param dDtEve		= Data de alteraÃ§Ã£o do evento
@param cKeyAfaFim	= Chave do fim do afastamento
/*/
//-------------------------------------------------------------------
Static Function fGetAltXML(cEvent, cXML, cTpAfa, dDtEve, cKeyAfaFim)

	Local aArea			:= GetArea()
	Local aAreaRJE      := RJE->(GetArea())
	Local oXml 			:= tXmlManager():New()
	Local aPathXML		:= {}
	Local cTpS2230		:= "/eSocial/evtAfastTemp/infoAfastamento/iniAfastamento/codMotAfast"
	Local cFimS2230		:= "/eSocial/evtAfastTemp/infoAfastamento/fimAfastamento/dtTermAfast"
	Local nPos 			:= 0
	Local nRecAfaI		:= 0
	Local cKeyAfaIni	:= ""

	Default	cEvent		:= ""
	Default cXML		:= ""
	Default cTpAfa		:= ""
	Default dDtEve		:= CTOD("//")
	Default cKeyAfaFim	:= ""

	//Adiciona no array os diretório para cada evento
	aAdd(aPathXML, {"S2200", "/eSocial/evtAdmissao/vinculo/infoRegimeTrab/infoCeletista/dtAdm"})
	aAdd(aPathXML, {"S2205", "/eSocial/evtAltCadastral/alteracao/dtAlteracao"})
	aAdd(aPathXML, {"S2236", "/eSocial/evtAltContratual/altContratual/dtAlteracao"})
	aAdd(aPathXML, {"S2230", "/eSocial/evtAfastTemp/infoAfastamento/iniAfastamento/dtIniAfast"})
	aAdd(aPathXML, {"S2299", "/eSocial/evtDeslig/infoDeslig/dtDeslig"})
	aAdd(aPathXML, {"S2300", "/eSocial/evtTSVInicio/infoTSVInicio/dtInicio"})
	aAdd(aPathXML, {"S2306", "/eSocial/evtTSVAltContr/infoTSVAlteracao/dtAlteracao"})
	aAdd(aPathXML, {"S2399", "/eSocial/evtTSVTermino/infoTSVTermino/dtTerm"})

	//Localiza no array o diretório conforme o evento
	nPos := aScan(aPathXML, {|x| x[1] == cEvent})

	//Verifica se o XML possui início e fim para pesquisar os dados
	If oXml:Parse( fMidTrPath(cXML,"eSocial") ) .And. nPos > 0
		dDtEve	:= sToD(STRTRAN(oXml:XPathGetNodeValue( aPathXML[nPos,2] ), "-"))
		
		//Apenas para o evento S2230 retorna o tipo de afastamento e pesquisa pela data final.
		If cEvent == "S2230"
			//Se a data continuar vazia utiliza o evento inicial para retornar o tipo de afastamento
			If Empty(dDtEve)
				dDtEve	:= sToD(STRTRAN(oXml:XPathGetNodeValue( cFimS2230 ), "-"))
				
				//Ajusta a chave e encontra o RECNO do registro inicio do afastamento
				cKeyAfaIni := "S2230" + SUBSTR(cKeyAfaFim, 1, LEN(cKeyAfaFim) -1 ) + "I"
				GetInfRJE( 4, cKeyAfaIni, Nil, Nil, Nil, @nRecAfaI, Nil, Nil, Nil, Nil, .F.)
				If nRecAfaI > 0
					//Posiciona no registro e obtem do XML de InÃ­cio o motivo de afastamento
					RJE->( dbGoTo(nRecAfaI) )
					cTpAfa	:= fGetXML("codMotAfast", RJE->RJE_XML)
				EndIf
			Else
				cTpAfa	:= oXml:XPathGetNodeValue( cTpS2230 )
			EndIf
		EndIf
	EndIf

	oXml := Nil

	RestArea(aAreaRJE)
	RestArea(aArea)

Return


/*/{Protheus.doc} function fGetXML
Retorna o valor de uma TAG do XML informado
@version 1.0
/*/
Static Function fGetXML( cTAG, cXML )
	Local nIni 	:= 0
	Local nFim 	:= 0
	Local cData := ""

	nIni 	:= AT("<" + cTAG + ">",  cXML )
	nFim 	:= AT("</" + cTAG + ">", cXML )
	cData 	:= ALLTRIM( STRTRAN(  SUBSTR( cXML, nIni, nFim-nIni ), "<" + cTAG + ">","" ) )

Return cData
