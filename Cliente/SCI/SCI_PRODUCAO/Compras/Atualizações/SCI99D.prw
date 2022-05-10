#Include "Totvs.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SCI99D ³ Autor ³  Ednei Silva         ³ Data ³ 29/06/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que envia o E-mail de Workflow na inclusao de       ³±±
±±³          ³ Pedido de Compra - Essa funcao e chamada pelo Ponto		 ³±±
±±³          ³ de Entrada MT120GRV                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_SCI99D( nOpcao,oProcess )                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpcao = Opcao chamada pelo Retorno do Workflow            ³±±
±±³          ³ oProcess = Objeto utilizado pelas funcoes de Workflow      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente Internacional                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function SCI99D( nOpcao,oProcess )

//Private cNMED:=CND->CND_NUMMED
Default nOpcao := 0


Do Case
	Case nOpcao == 0
		A040Inicio( CND->CND_NUMMED )
	Case nOpcao == 1
		A040Retorno( oProcess )
	Case nOpcao == 2
		A040TimeOut( oProcess )
EndCase

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A040INICIO ³ Autor ³ Ednei Silva ³ Data ³       29/06/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Esta funcao e responsavel por iniciar a criacao do         ³±±
±±³          ³ processo e por enviar a mensagem para o destinatario       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040INICIO( cNumMed )                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cNumMed = Numero da Filial e Pedido posicionado no PE       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente Internacional                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A040Inicio( cNumMed )

Local nDias		 := 0
Local nHoras	 := 0
Local nMinutos	 := 10
Local cCodProc   := "000002"
Local cCodStatus := ""
Local cAssunto   := AllTrim( GetMV("ES_WFTITPC") ) + " " + cNumMed
Local cHtmlMod 	 := AllTrim( GetMV("ES_WFHTMLC") )
Local cUsuSiga	 := __CUSERID
Local cTitulo	 := ""
Local cMailID	 := ""
Local cRet		 := ""
Local cTexto 	 := ""
Local cQuery	 := ""
Local cAliasT	 := GetNextAlias()
Local lIsAPW 	 := HttpIsAPW()
Local nValTotal	 := 0
Local aRet		 := {}

If (lIsAPW)
	cRet := "Iniciado com StartWebEX ou StartWeb"
Else
	cRet := "Chamado Via APL"
EndIf


aRet := A040WfMail( cNumMed )//Funcao para retornar o e-mail e o nivel do usuario aprovador

If !aRet[1] == "OK"// Se nao tiver aprovadores nao gera o formulario
	
	oProcess := TWFProcess():New(cCodProc, cAssunto)
	oProcess:NewTask(cTitulo, cHtmlMod)
	oHtml	:= oProcess:oHtml
	
	cCodStatus := "002100"
	cTexto := "Iniciando o processamento da " + cAssunto + " do Codigo: " + cNumMed
	oProcess:Track(cCodStatus, cTexto, cUsuSiga)
	
	cTexto := "Gerando medicao para envio..."
	cCodStatus := "002110"
	oProcess:Track(cCodStatus, cTexto, cUsuSiga)
	
	dbSelectArea("CND")
	dbSetOrder(4)//C7_FILIAL+C7_NUM+C7_ITEM+C1_SEQUEN
	If dbSeek( xFilial("CND") + cNumMed )
		
		oProcess:oHtml:ValByName( "C7_NUM"		, CND->CND_NUMMED )
		oProcess:oHtml:ValByName( "C7_EMISSAO"	, CND->CND_DTINIC )
		oProcess:oHtml:ValByName( "C7_FORNECE"	, CND->CND_FORNEC + " / " + CND->CND_LJFORN )
		
		dbSelectArea("SA2")
		dbSetOrder(1)//A2_FILIAL+A2_COD+A2_LOJA
		If dbSeek( xFilial("SA2") + CND->CND_FORNEC + CND->CND_LJFORN )
			oProcess:oHtml:ValByName( "C7_NOME"	, SA2->A2_NOME )
		EndIf
		
		oProcess:oHtml:ValByName( "C7_MOEDA"	, GetMV("MV_MOEDA" + cValToChar( CND->CND_MOEDA ) ) )
		
		dbSelectArea("CN9")
		dbSetOrder(1)//A2_FILIAL+A2_COD+A2_LOJA
		If dbSeek( xFilial("CN9") + CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMERO+CND->CND_NUMMED)
			oProcess:oHtml:ValByName( "C7_USER"		, Capital( RtFullName( CN9->CN9_CODUSU ) ) )
		EndIf
		oProcess:oHtml:ValByName( "C7_NUMSC"	, 'GCT' )
		oProcess:oHtml:ValByName( "C7_FILENT"	, CND->CND_FILCTR )
		
		dbSelectArea("SM0")
		oProcess:oHtml:ValByName( "C7_FILIAL" 	, AllTrim( SM0->M0_CODFIL ) )
		
		cQuery := " SELECT CNE_ITEM,"
		cQuery += "        CNE_PRODUT,"
		cQuery += "        CNE_QUANT,"
		cQuery += "        CNE_VLUNIT,"
		cQuery += "        CNE_VLTOT,"
		cQuery += "        CNE_DTENT,"
		cQuery += "        CNE_CC"
		cQuery += " FROM " + RetSQLName("CNE")
		cQuery += " WHERE CNE_FILIAL = '" + xFilial("CNE") + "'"
		cQuery += "   AND CNE_NUMMED = '" + cNumMed + "'"
		cQuery += "   AND D_E_L_E_T_<>'*'"
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery ),cAliasT,.F.,.T. )
		
		While ( cAliasT )->( !Eof() )
			
			aAdd( ( oProcess:oHtml:ValByName( "A.C7_ITEM" ) ) 		, ( cAliasT )->CNE_ITEM )
			aAdd( ( oProcess:oHtml:ValByName( "A.C7_PRODUTO" ) ) 	, ( cAliasT )->CNE_PRODUT )
			dbSelectArea("SB1")
			dbSetOrder(1)//A2_FILIAL+A2_COD+A2_LOJA
			If dbSeek( xFilial("SB1") + CNE->CNE_PRODUT)
				aAdd( ( oProcess:oHtml:ValByName( "A.C7_DESCRI" ) ) 	, AllTrim( SB1->B1_DESC ) )
				aAdd( ( oProcess:oHtml:ValByName( "A.C7_UM" ) ) 		, SB1->B1_UM)
			EndIf
			aAdd( ( oProcess:oHtml:ValByName( "A.C7_QUANT" ) ) 	, ( cAliasT )->CNE_QUANT )
			aAdd( ( oProcess:oHtml:ValByName( "A.C7_PRECO" ) ) 	, Transform( ( cAliasT )->CNE_VLUNIT , PesqPict("CNE","CNE_VLUNIT") ) )
			aAdd( ( oProcess:oHtml:ValByName( "A.C7_TOTAL" ) ) 	, Transform( ( cAliasT )->CNE_VLTOT , PesqPict("CNE","CNE_VLTOT") ) )
			aAdd( ( oProcess:oHtml:ValByName( "A.C7_DATPRF" ) ) 	, DtoC( StoD( ( cAliasT )->CNE_DTENT ) ) )
			aAdd( ( oProcess:oHtml:ValByName( "A.C7_CC" ) ) 		, ( cAliasT )->CNE_CC )
			
			dbSelectArea("CTT")
			dbSetOrder(1)//CTT_FILIAL+CTT_CUSTO
			If dbSeek( xFilial("CTT") + ( cAliasT )->CNE_CC )
				aAdd( ( oProcess:oHtml:ValByName( "A.C7_DESCCC" ) ) 	, AllTrim( CTT->CTT_DESC01 ) )
			Else
				aAdd( ( oProcess:oHtml:ValByName( "A.C7_DESCCC" ) ) 	, "" )
			EndIf
			
			nValTotal += ( cAliasT )->CNE_VLTOT
			
			( cAliasT )->( dbSkip() )
			
		EndDo
		
		( cAliasT )->( dbCloseArea() )
		
		oProcess:oHtml:ValByName( "C7_PCTOTAL"	 , Transform( nValTotal, PesqPict("CND","CND_VLTOT") ) )
		oProcess:oHtml:ValByName( "C7_NIVEL"	 , aRet[2] )
		oProcess:oHtml:ValByName( "C7_CODUSR"	 , cUsuSiga )
		oProcess:oHtml:ValByName( "C7_APROVADOR" , aRet[3] )
		
	EndIf
	
	oProcess:cSubject := cAssunto
	oProcess:cTo := "siga"
	oProcess:UserSiga := WFCodUser("BI")
	
	oProcess:bReturn := "U_SCI99D(1)"
	oProcess:bTimeOut := {"U_SCI99D(2)", nDias, nHoras, nMinutos}
	cTexto := "Enviando Medicao Contrato..."
	cCodStatus := "002120"
	oProcess:Track(cCodStatus, cTexto , cUsuSiga)
	cMailID := oProcess:Start()
	
	// Envia o Numero do Processo para o formulario para ser solicitado no retorno
	oProcess:oHtml:ValByName( "C7_NUMPROC" , cMailID )
	
	oProcess :NewTask(cTitulo, AllTrim( GetMV("ES_WFLHTML") ) )
	oProcess :ohtml:ValByName("titulo", "Aprovação de Medicao de Contrato - Internacional" )
	oProcess :ohtml:ValByName("paragrafo", "Medicao de contrato incluída pelo usuário" )
	oProcess :ohtml:ValByName("nome_usuario", Capital( RtFullName( cUsuSiga ) ) )
	oProcess :ohtml:ValByName("frase_link", "Clique no número da medicao do contrato para mais detalhes: " )
	oProcess :ohtml:ValByName("cod_sc", cNumMed )
	oProcess :ohtml:ValByName("proc_link", AllTrim( GetMV("ES_WFLINK") ) + "messenger/emp" +cEmpAnt + "/siga/" + cMailID + ".htm" )
	
	oProcess :cTo := aRet[1] //Array com o e-mail do aprovador
	oProcess :csubject := AllTrim( GetMV("ES_WFTITPC") ) + " " + cNumMed
	oProcess :Start()
	
	cTexto := "Enviando o E-mail WF."
	cCodStatus := "002130"
	oProcess:Track(cCodStatus, cTexto , cUsuSiga)
	
	cTexto := "Aguarde retorno..."
	cCodStatus := "002140"
	oProcess:Track(cCodStatus, cTexto , cUsuSiga)
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A040RETORNO ³ Autor ³ Ednei Silva ³ Data ³      29/06/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Esta funcao e executada no retorno da mensagem enviada     ³±±
±±³          ³ pelo destinatario. O Workflow recria o processo em que     ³±±
±±³          ³ parou anteriormente na funcao A040Inicio e repassa a       ³±±
±±³          ³ variavel objeto oProcess por parametro.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  A040Retorno(oProcess)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oProcess = Objeto do Workflow                              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ String 		                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente Internacional  						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A040Retorno(oProcess)

Local cNumMed		:= oProcess:oHtml:RetByName("C7_NUM")
Local cObs			:= oProcess:oHtml:RetByName("C7_OBS")
Local cOpcao		:= oProcess:oHtml:RetByName("opcao")
Local cNivelUsr		:= oProcess:oHtml:RetByName("C7_NIVEL")
Local cUsuSiga		:= oProcess:oHtml:RetByName("C7_CODUSR")
Local cUsuAprov		:= oProcess:oHtml:RetByName("C7_APROVADOR")
Local cCodStatus	:= ""
Local cTexto		:= ""
Local cSeek			:= ""
Local cTitulo 		:= "Aprovacao da Medicao de Contrato"
Local cMailID		:= oProcess:oHtml:RetByName("C7_NUMPROC")
Local aRet			:= {}
Local lResid        :=.F.
Local cTipo			:= ""
Local cPc  			:= ""
Local cNivel		:= ""


cTexto := "Executando funcao de retorno"
cCodStatus := "002150"
oProcess:Track(cCodStatus, cTexto , cUsuSiga)

//+-----------------------------------------------------+
//| Verifica a alcada de Compras para reenviar o e-mail |
//| de acordo com a selecao do usuario no retorno do    |
//| formulario                                          |
//+-----------------------------------------------------+
If AllTrim( cOpcao ) == "1"//Se o usuario liberou o Pedido
	
	cSeek := xFilial("SCR")
	cSeek += PadR( "MD", TamSX3("CR_TIPO")[01] )
	cSeek += PadR( cNumMed, TamSX3("CR_NUM")[01] )
	cSeek += PadR( cNivelUsr, TamSX3("CR_NIVEL")[01] )
	
	cTipo		:= PadR( "MD", TamSX3("CR_TIPO")[01] )
	cPc  		:= PadR( cNumMed, TamSX3("CR_NUM")[01] )
	cNivel		:= PadR( cNivelUsr, TamSX3("CR_NIVEL")[01] )
	
	dbSelectArea("SCR")
	dbSetOrder(1)//CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
	If dbSeek( cSeek )
		While SCR->( !Eof() ) .and. SCR->CR_FILIAL	== xFilial( 'SCR' );
			.and. SCR->CR_NUM == cPc .and. SCR->CR_TIPO == cTipo .and. SCR->CR_NIVEL == cNivel
			RecLock("SCR",.F.)
			SCR->CR_STATUS	:= "03"
			SCR->CR_DATALIB	:= Date()
			SCR->CR_USERLIB	:= cUsuAprov
			SCR->CR_LIBAPRO	:= cUsuAprov
			
			MsUnLock()
			SCR->( dbSkip() )
		Enddo
		
	EndIf
	
	//+----------------------------------+
	//| Altera o status do proximo nivel |
	//+----------------------------------+
	cNivelUsr := Soma1( cNivelUsr )
	cSeek := xFilial("SCR")
	cSeek += PadR( "MD", TamSX3("CR_TIPO")[01] )
	cSeek += PadR( cNumMed, TamSX3("CR_NUM")[01] )
	cSeek += PadR( cNivelUsr, TamSX3("CR_NIVEL")[01] )
	
	dbSelectArea("SCR")
	dbSetOrder(1)//CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
	If dbSeek( cSeek )
		
		RecLock("SCR",.F.)
		SCR->CR_STATUS	:= "01"
		MsUnLock()
		
	EndIf
	
	
	//+---------------------------------------------------+
	//| Funcao para retornar o e-mail e o nivel do usuario|
	//| aprovador caso ainda existam niveis a aprovar     |
	//+---------------------------------------------------+
	aRet := A040WfMail( cNumMed )
	
Else// Se nao liberou
	
	cSeek := xFilial("SCR")
	cSeek += PadR( "MD", TamSX3("CR_TIPO")[01] )
	cSeek += PadR( cNumMed, TamSX3("CR_NUM")[01] )
	cSeek += PadR( cNivelUsr, TamSX3("CR_NIVEL")[01] )
	
	dbSelectArea("SCR")
	dbSetOrder(1)//CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
	If dbSeek( cSeek )
		
		RecLock("SCR",.F.)
		SCR->CR_STATUS	:= "04"
		SCR->CR_DATALIB	:= Date()
		SCR->CR_OBSERV	:= cObs
		MsUnLock()
		
	EndIf
	
	aAdd( aRet, "OK")
	aAdd( aRet, "")
	aAdd( aRet, "")
	
EndIf

If AllTrim( aRet[1] ) == "OK"
	nCount:=0
	
	dbSelectArea("CND")
	dbSetOrder(4)// C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
	If dbSeek( xFilial("CND") + cNumMed )
		
		While CND->( !Eof() ) .And. AllTrim( CND->CND_NUMMED ) == AllTrim( cNumMed )
			
			If AllTrim( cOpcao ) == "1"
				
				RecLock( "CND", .F. )
				CND->CND_ALCAPR := "L"
				MsUnLock()
				if nCount=0
					U_StEmailMD(CND->CND_NUMMED,"L")
					nCount=nCount+1
				endif
				
			Else
				
				RecLock( "CND", .F. )
				CND->CND_ALCAPR	:= "B"
				CND->CND_MOTREJ	:=  cObs
				MsUnLock()
				
				if nCount=0
					U_StEmailMD(CND->CND_NUMMED,"B")
					nCount=nCount+1
				endif
				
			EndIf
			
			CND->( dbSkip() )
			
		EndDo
		
		cTexto := "Atualizando Medicao: " + cNumMed
		cCodStatus := "002160"
		oProcess:Track(cCodStatus, cTexto, oProcess:cRetFrom)
		
	Else
		
		cTexto := "Não foi possível encontrar a Medicao: " + cNumMed
		cCodStatus := "002170"
		oProcess:Track(cCodStatus, cTexto, oProcess:cRetFrom)
		
	EndIf
	
Else
	
	//+---------------------------------------+
	//| Executa novamente o envio do Workflow |
	//+---------------------------------------+
	A040Alcada( cNumMed,cUsuSiga )
	
EndIf

cTexto := "Processo Finalizado"
cCodStatus := "002180"
oProcess:Track(cCodStatus, cTexto, oProcess:cRetFrom)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A040TIMEOUT ³ Autor ³ Ednei Silva ³ Data ³      29/06/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Esta funcao sera executada a partir do Scheduler no tempo  ³±±
±±³          ³ estipulado pela propriedade :bTimeout da classe TWFProcess.³±±
±±³          ³ Caso o processo tenha sido respondido em tempo habil, essa ³±±
±±³          ³ execucao sera descartada automaticamente.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente Interncaional                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A040TimeOut(oProcess)

Local nDias  		:= 0
Local nHoras 		:= 0
Local nMinutos	    := 10
Local cCodStatus	:= ""
Local cHtmlMod	    := ""
Local cTexto		:= ""
Local cTitulo		:= ""
//Local cNumMed       :=cNMED
Local aRet		    := A040WfMail( cNumMed )

cHtmlMod := AllTrim( GetMV("ES_WFHTMLC") )
cTitulo := "Aprovação do Medicao de contrato"

cTexto := "Executando Funcao de TIMEOUT..."
cCodStatus := "002190"
oProcess:Track(cCodStatus, cTexto)

cNumMed := oProcess:oHtml:ValByName("C7_NUM")
oProcess:Finish()

dbSelectArea("CND")
dbSetOrder(4)// C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
If dbSeek( xFilial("CND") + cNumMed )
	
	oProcess:NewTask(cTitulo, cHtmlMod, .T.)
	
	If (Left(oProcess:cSubject,9) != "(REENVIO)")
		oProcess:cSubject := "(REENVIO)" + oProcess:cSubject
	EndIf
	
	oProcess:cTo 		:= aRet[1]
	oProcess:UserSiga	:= WFCodUser("BI")
	oProcess:bReturn 	:= "U_SCI99D(1)"
	oProcess:bTimeOut	:= {"U_SCI99D(2)", nDias, nHoras, nMinutos}// Redefina a funcao de timeout a ser executada.
	
	cTexto := "Reenviando a Medicao..."
	cCodStatus := "002200"
	oProcess:Track(cCodStatus, cTexto)
	oProcess:Start()		// Inicie o processo
	
Else
	
	cTexto := "Não foi possível encontrar a Medicao: " + cNumMed
	cCodStatus := "002170" // Codigo do cadastro de status de processo
	oProcess:Track(cCodStatus, cTexto)
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A040WfMail ³ Autor ³ Ednei Silva  ³ Data ³  		29/06/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Envia o e-mail Workflow conforme alcada de aprovacao       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040WfMail( ExpC01 )                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC01 = Codigo do Pedido de Compra                        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente Internacional                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function  A040WfMail( cNumMed  )
Local aRet		:= {}
Local cQuery		:= ""
Local cAliasT		:= GetNextAlias()


cQuery := " SELECT CR_NUM,"
cQuery += "        CR_USER,"
cQuery += "        CR_APROV,"
cQuery += "        CR_NIVEL,"
cQuery += "        CR_STATUS"
cQuery += " FROM " + RetSQLName("SCR")
cQuery += " WHERE CR_FILIAL	  = '" + xFilial("SCR") + "'"
cQuery += "   AND CR_TIPO	  = 'MD'"
cQuery += "   AND CR_NUM     = '" + cNumMed + "'"
cQuery += "   AND CR_DATALIB = ''"
cQuery += "   AND CR_USERLIB = ''"
cQuery += "   AND D_E_L_E_T_ <>'*'"
cQuery += " ORDER BY CR_NIVEL"
cQuery := ChangeQuery( cQuery )
dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )

If ( cAliasT )->( !Eof() )
	aAdd( aRet, AllTrim( UsrRetMail( ( cAliasT )->CR_USER ) ) )
	aAdd( aRet, ( cAliasT )->CR_NIVEL )
	aAdd( aRet, ( cAliasT )->CR_USER )
	
Else
	aAdd( aRet, "OK" )
	aAdd( aRet, "" )
	aAdd( aRet, "" )
	
EndIf
( cAliasT )->( dbCloseArea() )

Return( aRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A040Alcada ³ Autor ³ Ednei Silva       ³ Data ³  29/06/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao de envio do Workflow com alcada                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040Alcada(ExpC01,ExpC02)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC01 = Numero do Pedido de Compra                        ³±±
±±³          ³ ExpC02 = Codigo do Usuario que inclui do Pedido            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente Internacional                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function  A040Alcada( cNumMed,cUsuSiga )

Local nDias		:= 0
Local nHoras		:= 0
Local nMinutos	:= 10
Local cCodProc 	:= "000002"
Local cCodStatus 	:= ""
Local cAssunto 	:= AllTrim( GetMV("ES_WFTITPC") ) + " " + cNumMed
Local cHtmlMod 	:= AllTrim( GetMV("ES_WFHTMLC") )
Local cTitulo	:= ""
Local cMailID	:= ""
Local cRet		:= ""
Local cTexto 	:= ""
Local cQuery	:= ""
Local cQaprovou := ""
Local cAliasT	:= GetNextAlias()
Local cAliasL	:= GetNextAlias()
Local nValTotal	:= 0
Local aRet 		  := {}
Local lSetCentury := __SetCentury()
Local cQuery1   :=""

Local cVarAux1 := GetMV("MV_MOEDA" + cValToChar( CND->CND_MOEDA ) )

If	!lSetCentury
	__SetCentury("ON")
EndIf


aRet := A040WfMail( cNumMed )//Funcao para retornar o e-mail e o nivel do usuario aprovador

If !aRet[1] == "OK"// Se houver aprovadores envia o formulario
	
	cQuery1 := " SELECT CR_NUM,"
	cQuery1 += "        CR_USER,"
	cQuery1 += "        CR_APROV,"
	cQuery1 += "        CR_NIVEL,"
	cQuery1 += "        CR_STATUS"
	cQuery1 += " FROM " + RetSQLName("SCR")
	cQuery1 += " WHERE CR_FILIAL	  = '" + xFilial("SCR") + "'"
	cQuery1 += "   AND CR_TIPO	  = 'MD'"
	cQuery1 += "   AND CR_NUM     = '" + cNumMed + "'"
	cQuery1 += "   AND CR_NIVEL   = '" + aRet[2] + "'"
	cQuery1 += "   AND CR_DATALIB = ''"
	cQuery1 += "   AND CR_USERLIB = ''"
	cQuery1 += "   AND D_E_L_E_T_ <>'*'"
	cQuery1 += " ORDER BY CR_NIVEL"
	cQuery1 := ChangeQuery( cQuery1 )
	MemoWrite("testeEdy.SQL",cQuery1)
	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery1),cAliasL,.F.,.T. )
	
	cAju := AllTrim( GetMV("ES_WFLHTML") )
	cCapi:= Capital( RtFullName( cUsuSiga ) )	
	cAjuLin := AllTrim( GetMV("ES_WFLINK") )	
	cAjuSub := AllTrim( GetMV("ES_WFTITPC") )	
	While ( cAliasL )->( !Eof() )
		
		
		cTitulo		:= ""
		cMailID		:= ""
		cRet		:= ""
		cTexto 		:= ""
		cQuery		:= ""
		cQaprovou	:= ""
		nValTotal	:= 0
		cCodStatus 	:= ""
		
		
		oProcess := TWFProcess():New(cCodProc, cAssunto)
		oProcess:NewTask(cTitulo, cHtmlMod)
		oHtml	:= oProcess:oHtml
		
		cCodStatus := "002100"
		cTexto := "Iniciando o processamento da " + cAssunto + " do Código: " + cNumMed
		oProcess:Track(cCodStatus, cTexto, cUsuSiga)
		
		cTexto := "Gerando Medicao de contrato..."
		cCodStatus := "002110"
		oProcess:Track(cCodStatus, cTexto, cUsuSiga)
		
		dbSelectArea("CND")
		dbSetOrder(4)//C7_FILIAL+C7_NUM+C7_ITEM+C1_SEQUEN
		If dbSeek( xFilial("CND") + cNumMed )
			
			oProcess:oHtml:ValByName( "C7_NUM"		, CND->CND_NUMMED )
			oProcess:oHtml:ValByName( "C7_EMISSAO"	, CND->CND_DTINIC )
			oProcess:oHtml:ValByName( "C7_FORNECE"	, CND->CND_FORNEC + " / " + CND->CND_LJFORN )
			
			dbSelectArea("SA2")
			dbSetOrder(1)//A2_FILIAL+A2_COD+A2_LOJA
			If dbSeek( xFilial("SA2") + CND->CND_FORNEC + CND->CND_LJFORN )
				oProcess:oHtml:ValByName( "C7_NOME"	, SA2->A2_NOME )
			EndIf
			
			oProcess:oHtml:ValByName( "C7_MOEDA"	, cVarAux1 )
			
			dbSelectArea("CN9")
			dbSetOrder(1)//A2_FILIAL+A2_COD+A2_LOJA
			If dbSeek( xFilial("CN9") + CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMERO+CND->CND_NUMMED)
				oProcess:oHtml:ValByName( "C7_USER"		, Capital( RtFullName( CN9->CN9_CODUSU ) ) )
			EndIf
			oProcess:oHtml:ValByName( "C7_NUMSC"	, 'GCT' )
			oProcess:oHtml:ValByName( "C7_FILENT"	, CND->CND_FILCTR )
			
			dbSelectArea("SM0")
			oProcess:oHtml:ValByName( "C7_FILIAL" 	, AllTrim( SM0->M0_CODFIL ) )
			
			cQuery := " SELECT CNE_ITEM,"
			cQuery += "        CNE_PRODUT,"
			cQuery += "        CNE_QUANT,"
			cQuery += "        CNE_VLUNIT,"
			cQuery += "        CNE_VLTOT,"
			cQuery += "        CNE_DTENT,"
			cQuery += "        CNE_CC"
			cQuery += " FROM " + RetSQLName("CNE")
			cQuery += " WHERE CNE_FILIAL = '" + xFilial("CNE") + "'"
			cQuery += "   AND CNE_NUMMED = '" + cNumMed + "'"
			cQuery += "   AND D_E_L_E_T_<>'*'"
			cQuery := ChangeQuery( cQuery )
			dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery ),cAliasT,.F.,.T. )
			
			While ( cAliasT )->( !Eof() )
				
				aAdd( ( oProcess:oHtml:ValByName( "A.C7_ITEM" ) ) 		, ( cAliasT )->CNE_ITEM )
				aAdd( ( oProcess:oHtml:ValByName( "A.C7_PRODUTO" ) ) 	, ( cAliasT )->CNE_PRODUT )
				dbSelectArea("SB1")
				dbSetOrder(1)//A2_FILIAL+A2_COD+A2_LOJA
				If dbSeek( xFilial("SB1") + CNE->CNE_PRODUT)
					aAdd( ( oProcess:oHtml:ValByName( "A.C7_DESCRI" ) ) 	, AllTrim( SB1->B1_DESC ) )
					aAdd( ( oProcess:oHtml:ValByName( "A.C7_UM" ) ) 		, SB1->B1_UM)
				EndIf
				aAdd( ( oProcess:oHtml:ValByName( "A.C7_QUANT" ) ) 	, ( cAliasT )->CNE_QUANT )
				aAdd( ( oProcess:oHtml:ValByName( "A.C7_PRECO" ) ) 	, Transform( ( cAliasT )->CNE_VLUNIT , PesqPict("CNE","CNE_VLUNIT") ) )
				aAdd( ( oProcess:oHtml:ValByName( "A.C7_TOTAL" ) ) 	, Transform( ( cAliasT )->CNE_VLTOT , PesqPict("CNE","CNE_VLTOT") ) )
				aAdd( ( oProcess:oHtml:ValByName( "A.C7_DATPRF" ) ) 	, DtoC( StoD( ( cAliasT )->CNE_DTENT ) ) )
				aAdd( ( oProcess:oHtml:ValByName( "A.C7_CC" ) ) 		, ( cAliasT )->CNE_CC )
				
				dbSelectArea("CTT")
				dbSetOrder(1)//CTT_FILIAL+CTT_CUSTO
				If dbSeek( xFilial("CTT") + ( cAliasT )->CNE_CC )
					aAdd( ( oProcess:oHtml:ValByName( "A.C7_DESCCC" ) ) 	, AllTrim( CTT->CTT_DESC01 ) )
				Else
					aAdd( ( oProcess:oHtml:ValByName( "A.C7_DESCCC" ) ) 	, "" )
				EndIf
				
				nValTotal += ( cAliasT )->CNE_VLTOT
				
				( cAliasT )->( dbSkip() )
				
			EndDo
			
			( cAliasT )->( dbCloseArea() )
			
			
			oProcess:oHtml:ValByName( "C7_PCTOTAL"	 , Transform( nValTotal, PesqPict("CND","CND_VLTOT") ) )
			oProcess:oHtml:ValByName( "C7_NIVEL"	 , ( cAliasL )->CR_NIVEL )
			oProcess:oHtml:ValByName( "C7_CODUSR"	 , cUsuSiga )
			oProcess:oHtml:ValByName( "C7_APROVADOR" , ( cAliasL )->CR_USER )
			
			
		EndIf
		
		oProcess:cSubject := cAssunto
		oProcess:cTo := "siga"
		oProcess:UserSiga	:= WFCodUser("BI")
		
		oProcess:bReturn	:= "U_SCI99D(1)"
		oProcess:bTimeOut	:= {"U_SCI99D(2)", nDias, nHoras, nMinutos}
		cTexto := "Enviando Medicao de contrato..."
		cCodStatus := "002120"
		oProcess:Track(cCodStatus, cTexto , cUsuSiga)
		cMailID := oProcess:Start()
		
		// Envia o Numero do Processo para o formulario para ser solicitado no retorno
		oProcess:oHtml:ValByName( "C7_NUMPROC" , cMailID )
		
		oProcess :NewTask(cTitulo, cAju )
		//oProcess :NewTask(cTitulo, AllTrim( GetMV("ES_WFLHTML") ) )
		oProcess :ohtml:ValByName("titulo", "Aprovação de Medicao de Contrato - Internacional" )
		oProcess :ohtml:ValByName("paragrafo", "Medicao de contrato incluida pelo usuário" )
		oProcess :ohtml:ValByName("nome_usuario", cCapi )
		oProcess :ohtml:ValByName("frase_link", "Clique no número da medicao de contrato para mais detalhes: " )
		oProcess :ohtml:ValByName("cod_sc", cNumMed )
		oProcess :ohtml:ValByName("proc_link", cAjuLin + "messenger/emp" +cEmpAnt + "/siga/" + cMailID + ".htm" )
		//oProcess :ohtml:ValByName("proc_link", AllTrim( GetMV("ES_WFLINK") ) + "messenger/emp" +cEmpAnt + "/siga/" + cMailID + ".htm" )
		cQliberou:=""
		cQliberou:=Alltrim(cQLibMed( cNumMed ))
		if cQliberou<>""
			oProcess :ohtml:ValByName("liberadopor","Quem já aprovou esta medicao: "+cQliberou)
		endif
		oProcess :cTo := AllTrim( UsrRetMail(( cAliasL )->CR_USER ) ) //Array com o e-mail do aprovador
		oProcess :csubject := cAjuSub + " " + cNumPC
		//oProcess :csubject := AllTrim( GetMV("ES_WFTITPC") ) + " " + cNumPC
		oProcess :Start()
		
		cTexto := "Enviando o E-mail WF."
		cCodStatus := "002130"
		oProcess:Track(cCodStatus, cTexto , cUsuSiga)
		
		cTexto := "Aguarde retorno..."
		cCodStatus := "002140"
		oProcess:Track(cCodStatus, cTexto , cUsuSiga)
		
		( cAliasL )->( dbSkip() )
	Enddo
	
	( cAliasL )->( dbCloseArea() )
	
EndIf

Return

Static Function  cQLibMed( cNumMed )

Local cUsers		:= ""
Local cQuery		:= ""
Local cAliasZ		:= GetNextAlias()


cQuery := " SELECT CR_NUM,"
cQuery += "        CR_USER,"
cQuery += "        CR_APROV,"
cQuery += "        CR_NIVEL,"
cQuery += "        CR_STATUS"
cQuery += " FROM " + RetSQLName("SCR")
cQuery += " WHERE CR_FILIAL	  = '" + xFilial("SCR") + "'"
cQuery += "   AND CR_TIPO	  = 'MD'"
cQuery += "   AND CR_NUM      = '" + cNumMed + "'"
cQuery += "   AND CR_DATALIB <> ''"
cQuery += "   AND CR_USERLIB <> ''"
cQuery += "   AND D_E_L_E_T_ <> '*'"
cQuery += " ORDER BY CR_NIVEL"
cQuery := ChangeQuery( cQuery )
dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZ,.F.,.T. )
While ( cAliasZ )->( !Eof() )
	
	If cUsers=""
		
		cUsers:=Capital( RtFullName( ( cAliasZ )->CR_USER ) )
		
	else
		cUsers:=cUsers+';'+Capital( RtFullName( ( cAliasZ )->CR_USER ) )
	endif
	
	( cAliasZ )->( dbSkip() )
Enddo
( cAliasZ )->( dbCloseArea() )

Return( cUsers ) 


//+-------------------------------------------------+
//| Funcao para retornar o nome completo do usuario |
//| Denis - 02/12/2019                              |
//+-------------------------------------------------+
Static Function RtFullName( cCodUser )
	
	Local cRet := ""
	
	cRet := UsrFullName( cCodUser  )
	
Return( cRet )





