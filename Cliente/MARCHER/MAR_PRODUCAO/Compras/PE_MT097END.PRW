#INCLUDE "TOPCONN.ch"
#include "protheus.ch"
#include "apwizard.ch"
#include "tbiconn.ch" // include do wf
#include "TbiCode.ch" // include do wf


//**********************************************************************************
// MARCHER                                                                         *
// ------------------------------------------------------------------------------- *
// Referencia: PE_MT097END.PRW                                                     *
// Parโmetros: [cPedido,cTipo,nOpc,cFilDoc]                                        *
// Tipo......: ( ) Programa  ( ) Gatilho (x)Ponto de Entrada                       *
// ------------------------------------------------------------------------------- *
// Autor.....: Mแrcio Borges                                                       *
// Data......: 02/10/2018                                                          *
// Objetivo..: PE para enviar PDF do pedido no momento da libera็ใo alcada         *
//**********************************************************************************
// Documenta็ใo do Ponto de Entrada: http://tdn.totvs.com/pages/releaseview.action?pageId=6085377
// acesso em 02/10/2018.

User Function MT097END() 
	/*
	ParamIXB = {cPedido,cTipo,nOpc,cFilDoc} onde :
	cPedido == Numero do Documento/Pedido
	cTipo == Tipo do Documento "PC" "AE" "CP"
	Quando o ponto ?acionado pela rotina de Libera?o e Superior:
	nOpc == 1 --> Cancela
	nOpc == 2 --> Libera
	nOpc == 3 --> Bloqueia
	Quando o ponto ?acionado pela rotina de Transf.	Superior
	nOpc == 1 --> Transfere
	nOpc == 2 --> Cancela
	Obs.: Para esta rotina, caso nใo exista o superior cadastrado, a vari?el serแ enviada como Nil. Deve ser tratado no ponto de entrada. 
	cFilDoc == Filial do Documento
	*/

	Local cPedido   := PARAMIXB[1] 
	Local cTipoDoc  := PARAMIXB[2]
	Local nOpcao    := PARAMIXB[3]
	Local cFilDoc   := PARAMIXB[4]
	//Local aArray := {}
	Local cAssunto := ""
	Local cCorpo := ""
	Local cFil := ""
	Local cFornec := ""
	Local cNomeFor  :=""
	Local cLocalPDF := ""
	Local lExistePDF := .F.             
	Private  lMsgBox :=  (FunName() =='MATA121') //Se for chamado pela Rotina pedido de venda mostra na tela mensagens, senใo apenas no console


	DBSelectArea("SCR");DBSetOrder(1)
	//pOSICIONA NO SCR
	If !(cFilDoc + cTipoDoc + cPedido  ==  SCR->CR_FILIAL + SCR->CR_TIPO + SCR->CR_NUM )
		SCR->(MsSeek(cFilDoc + cTipoDoc + cPedido,.f.)) //Verifica se existe libera็ใo por controle de al็ada.
		lFoundSCR := SCR->(FOUND())
	Else
		lFoundSCR := .T.
	Endif

	If (cTipoDoc == "PC" .Or. cTipoDoc == "AE") .AND. IIF(lFoundSCR,!Empty(SCR->CR_DATALIB) .And. SCR->CR_STATUS$"03#05",.T.)

		//pOSICIONA NO SC7
		DBSelectArea("SC7");DBSetOrder(1)
		If !(cFilDoc + cPedido  ==  SC7->C7_FILIAL + SC7->C7_NUM )
			SC7->(MsSeek(cFilDoc + cPedido,.f.))
		Endif

		// Envia email para A2_EMAIL
		cFil := SCR->CR_FILIAL

		cFornec := SC7->C7_FORNECE
		cNomeFor:= trim( POSICIONE("SA2",1,XFILIAL("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA, "SA2->A2_NOME" ) )


		//Tratamento para Medi็ใo de Contrato

		cTo := SA2->A2_EMAIL    
		cEmComprador := BuscCompra(cPedido)

		If Empty(cTo) // Se estiver vazio email do fornecedor, envia somente para compras
			cTo:= cEmComprador
			cCC := ""
		Else
			cCC := cEmComprador
		Endif

		//--> Gera ANEXO e Carrega BODY----
		cLocalPDF := u_MARR003(cPedido,.T.) // Gera Pedido em Pdf e retorna o local gerado

		cLocalPDF := CopyTServer(cLocalPDF)//| Valida exist๊ncia de Anexo e Copia para o Server caso necessario... |

		lExistePDF := FILE(cLocalPDF)
		cAssunto := "Marcher - Ordem de Compra '" + cPedido + "'"


		//If !lExistePDF
		//Se nใo gerou o PDF, ou se ele nใo foi encontrado envia email para Comprador
		//	cCorpo := "Nใo foi possํvel gerar o PDF  referente a Ordem de compra '" + cPedido + "' do Fornecedor '" + cNomeFor + "' . O email nใo foi enviado para o Fornecedor. Gere e envie manutalmente""
		//	cTo:=  cEmComprador // borges - trocar este email
		//	cCC := ""
		//Else
		//	cCorpo := LoadFile(cFileHtmlBody) // Carrega o Corpo do HTML do arquivo do parโmetro especํficado: MA_HTMLBPC
		//Endif	

	ElseIf (cTipoDoc == "MD") .AND. nOpcao == 2 .AND. CND->CND_ALCAPR=="L" 
		If lMsgBox
			IW_MsgBox("Envio de email de Or็amento de Compra para com Medi็ใo de contrato nใo disponํvel. Entre em Contato com Solutio I.T para customiza็ใo!",OemToAnsi("Informativo"),"INFO" )
		Else
			Conout(Funname() + " - Envio de email de Or็amento de Compra para com Medi็ใo de contrato nใo disponํvel. Entre em Contato com Solutio I.T para customiza็ใo!")
		Endif
		// NAO TRATADO PARA MEDICAO DE CONTRATO - SUGERIDO A SEGUIR TRATATIVA
		Return 
		
		/*



		dbSelectArea("CND")
		dbSetOrder(4)
		If dbSeek(xFilial("CND")+cPedido)	

		Begin Transaction
		aAdd(aArray,{"CND_CONTRA",CND->CND_CONTRA,NIL})
		aAdd(aArray,{"CND_REVISA",CND->CND_REVISA,NIL})
		aAdd(aArray,{"CND_COMPET",CND->CND_COMPET,NIL})
		aAdd(aArray,{"CND_NUMERO",CND->CND_NUMERO,NIL})
		aAdd(aArray,{"CND_NUMMED",CND->CND_NUMMED,NIL})
		aAdd(aArray,{"CND_PARCEL",CND->CND_PARCEL,NIL})


		CNTA120(aArray,{},6,.F.) //CNTA120 - Medi็ใo do contrato - http://tdn.totvs.com/pages/releaseview.action?pageId=6089667

		If lMsErroAuto
		cMemo := MostraErro()	
		Else
		cFil := CND->CND_FILIAL
		cusu := alltrim(CND->CND_YUSER)
		cEmUs := alltrim(CND->CND_YEMAIL) 
		cMedic:= CND->CND_NUMMED
		cfornec := CND->CND_FORNEC
		cNomeFor:= trim( POSICIONE("SA2",1,XFILIAL("SA2") + CND->CND_FORNEC + CND->CND_LJFORN, "SA2->A2_NOME" ) )
		cpedid := CND->CND_PEDIDO
		cContra:= CND->CND_CONTRA

		cTo:= cUsu + cEmUs


		Endif



		End Transaction
		*/
	Else
		If lMsgBox
			IW_MsgBox("Condi็ใo de Pedido NรO permite envio de PDF",OemToAnsi("Informativo"),"INFO" )
		Else
			Conout(Funname() + " - Condi็ใo de Pedido nใo permite envio de PDF.")
		Endif
		Return
	Endif



	If lExistePDF
		SendWFMail(cEmComprador,cTo,cCC,cAssunto,cCorpo,cLocalPDF) 
	Else
		//Se nใo gerou o PDF, ou se ele nใo foi encontrado envia email para Comprador
		cTo:=  cEmComprador // borges - trocar este email
		cCC := ""
		cCorpo := "Nใo foi possํvel gerar o PDF  referente a Ordem de compra '" + cPedido + "' do Fornecedor '" + cNomeFor + "' . O email nใo foi enviado para o Fornecedor. Gere e envie manutalmente""
		SendWFMail(cEmComprador,cTo,cCC,cAssunto,cCorpo,cLocalPDF)
	Endif
Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ LOADFILE บ Autor ณMARCIOQUEVEDOBORGES บ Data ณ  02/105/2018บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA  บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function LoadFile(cSPatch)

	Local cRet := ""

	//Abre e posiciona arquivo
	If FT_FUSE(cSPatch) < 0 //-1 = falha na abertura
		If lMsgBox
			IW_MsgBox("Falha na Abertura do arquivo"+ cSPatch,OemToAnsi("Informativo"),"ALERT" )
		Else
			Conout(Funname() + " - Falha na Abertura do arquivo"+ cSPatch)
		Endif	
	Else
		//nTamFile := FT_FLastRec()
		FT_FGOTOP()

		While !FT_FEOF()
			cRet += FT_FREADLN()
			FT_FSKIP()
		EndDo
	Endif

	FT_FUSE()
Return cRet

/*
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar para buscar os compradores da ordem de     บฑฑ
ฑฑบ          ณ compra.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
*/
Static Function BuscCompra(cPedido)
	Local cEmails := ""
	Local cSql := " " 

	//Localiza็ใo dos compradores
	cSql := cSql + "SELECT Y1_EMAIL  FROM " + RetSqlName("SY1") + " Y WHERE Y1_FILIAL = '" + xFilial("SY1") + "' AND Y.D_E_L_E_T_ = ' ' AND  Y1_USER IN ( "
	cSql += "  SELECT DISTINCT C7_USER  from " + RetSqlName("SC7") + " where C7_FILIAL = '" + xFilial("SC7") + "' AND C7_NUM = '"+ cPedido +"' AND D_E_L_E_T_ = ' '"
	cSql += "         UNION ALL "
	cSql += "  SELECT DISTINCT AJ_USER from " + RetSqlName("SAJ") + " where AJ_FILIAL = '" + xFilial("SAJ") + "' AND AJ_GRCOM IN (SELECT DISTINCT C7_GRUPCOM from " + RetSqlName("SC7") + " where C7_FILIAL = '" + xFilial("SC7") + "' AND C7_NUM = '"+ cPedido +"' AND D_E_L_E_T_ = ' ' ) AND D_E_L_E_T_ = ' ' "
	cSql += ")"

	MyQuery(cSql, "TMPCMP")

	If TMPCMP->(!EOF())

		while ( TMPCMP->(!Eof()) )
			cEmails += TMPCMP->Y1_EMAIL
			TMPCMP->(DBSkip())
		Enddo

	Else
		cEmails := "almoxarifado@marhcer.com.br"
	Endif

Return cEmails

Static Function SendWFMail(_cMailFrom,_cMailTo,_cCC,_cSubject,_cBody,_cAnexo)
	Local _cProdAmb		:= SuperGetMV("MV_AMBPROD",,"PRODUCAO") // Ambientes para considerar como producao
	Local cFileHtmlBody := SuperGetMV("MA_HTMLBPC",,"\workflow\body_ordem_compra.html")
	Private cPathInServer	 	:= "\dirdoc\pdf\"

	DEFAULT _cSubject 			:= "[sem assunto]"
	DEFAULT _cAnexo   	:= ""	
	DEFAULT _cBody 	   	:= ""
	DEFAULT _cAnexo		:= ""
	DEFAULT _cMailFrom := SuperGetMV("MA_EMLCOM",,"compras@marcher.com.br") // Se nใo vier preenchido o email usarแ o do compras

	// ####################
	// Assunto do E-mail ##
	// ####################
	// Se nใo for ambientes de producao, adiciona mensagem de teste no assunto
	If !(UPPER(Alltrim(GetEnvServer())) $ UPPER(_cProdAmb ))
		_cSubject := "TESTE - FAVOR DESCONSIDERAR: " + _cSubject
	Endif

	// ####################################################################
	// Caminho e Arquivo HTML                                            ##
	// ####################################################################
	cArqHtml := "\workflow\body_ordem_compra.html" //cFileHtmlBody
	// #####################################################
	// Inicia o Processo de WorkFlow de Cota็ใo de Pre็os ##
	// #####################################################
	o2Process := TWFProcess():New( "FLWCOM2", _cSubject )
	o2Process:NewVersion(.T.)
	
	// #########################################################
	// Cria uma Nova Tarefa Informando o HTML do Link de Envio ##
	// ##########################################################
	o2Process:NewTask( "Envio", cArqHtml )

	// ################################################################
	// Cria Objeto HTML do Processo de WorkFlow                      ##
	// ################################################################
	//oHtml := o2Process:oHTML


	// ###################
	// ## Anexa arquivo ##
	// ###################
	If FILE(_cAnexo)
		o2Process:AttachFile(_cAnexo)
	Endif

	// #####################################################################################
	// E-mail que Ira Receber a Notificacao de Aprovacao/Rejeicao do Processo de WorkFlow ##
	// #####################################################################################
	o2Process:cTo      := _cMailTo
	o2Process:cCC      := _cCC

	// ################################################################################################
	// Assunto do E-mail que Ira Receber a Notificacao de Aprovacao/Rejeicao do Processo de WorkFlow ##
	// ################################################################################################
	o2Process:cSubject := _cSubject


	// ####################################################
	// Carrega a Data de Refer๊ncia para display no HTML ##
	// ####################################################
	cTurno := "Bom Dia" // tratamento do turno "Bom Dia/ Boa Tarde/ Boa Noite" 
	oHtml   := o2Process:oHTML
	oHtml:ValByName("TURNO", cTurno)


	// #############################################################################
	// Cria e Inicia o Processo de Envio de E-mail do WorkFlow de Ordem de Compra ##
	// #############################################################################
	o2Process:Start()

	// #######################
	// Finaliza o Processo  ##
	// #######################
	o2Process:Finish()  

Return

Static Function CopyTServer(_cAnexo)
	Local lPula 				:= .F.
	Private cPathInServer	 	:= "\dirdoc\pdf\"
	Private cDrive				:= ""
	Private cDiretorio			:= ""
	Private cNome				:= ""
	Private cExtensao			:= ""

	
	//--------------------------------------------------------------------
	//| Valida exist๊ncia de Anexo e Copia para o Server caso necessario... |
	If !Empty( Alltrim( _cAnexo ) ) // Divide ecaminho e nome do arquivo....anexo

		SplitPath( _cAnexo, @cDrive, @cDiretorio, @cNome, @cExtensao )

		//|  Valida se o Endere็o do anexo eh Cliente...
		If At(":",_cAnexo) > 0

			If File(cPathInServer+cNome+cExtensao)
				If fErase(cPathInServer+cNome+cExtensao) == -1
					Iw_MsGbox("Nใo pode copiar o arquivo "+ _cAnexo+" para o servidor "+ cPathInServer+cNome+cExtensao+", jแ existe um arquivo no destino com o mesmo nome e nเo pode ser deletado!!! " )
					lPula := .T.
				EndIf
			EndIf

			If !lPula
				If _CopyFile( _cAnexo , cPathInServer+cNome+cExtensao )
					_cAnexo := cPathInServer+cNome+cExtensao
				Else
					Iw_MsGbox("Nใo pode copiar o arquivo "+ _cAnexo +" para o servidor "+ cPathInServer+cNome+cExtensao+"!!! " )
					lResult := .F.
				EndIf
			EndIf
		EndIf
	EndIf

Return _cAnexo

//*******************************************************************************
Static Function EnviaEmail(_cMailFrom,_cMailTo,_cCC,_cSubject,_cBody,_cAnexo)
//*******************************************************************************
	Local _cProdAmb		:= SuperGetMV("MV_AMBPROD",,"PRODUCAO") // Ambientes para considerar como producao
	Local lResult
	Local cError
	Local cServer 		:= GetMV("MV_RELSERV" )//"mail.solutio.inf.br:587"//
	Local cAccount 		:= Alltrim(GETMV("MV_RELACNT"))//'marcio.borges@solutio.inf.br'//"cobranca@marcher.com.br" //
	Local cPassword 	:= Alltrim(GETMV("MV_RELPSW"))//'10203'//'Xa&=p6afrakA'//
	Local lAuth 		:= Getmv("MV_RELAUTH")

	Local lPula 		:= .F.

	Private cPathInServer	 	:= "\dirdoc\pdf\"
	Private cDrive				:= ""
	Private cDiretorio			:= ""
	Private cNome				:= ""
	Private cExtensao			:= ""
	DEFAULT _cCC      			:= ""
	DEFAULT _cSubject 			:= "[sem assunto]"
	DEFAULT _cAnexo   	:= ""	
	DEFAULT _cBody 	   	:= ""
	DEFAULT _cAnexo		:= ""
	DEFAULT _cMailFrom := cAccount // Se nใo vier preenchido o email que estแ enviando, serแ o mesmo da conexใo smtp

	// Se nใo for ambientes de producao, adiciona mensagem de teste no assunto
	If !(UPPER(Alltrim(GetEnvServer())) $ UPPER(_cProdAmb ))
		_cSubject := "TESTE - FAVOR DESCONSIDERAR: " + _cSubject
	Endif

	Conout(Funname()  + " - Conectando com o Servidor de Email")
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult


	If lResult .And. lAuth
		lResult := MailAuth(cAccount,cPassword)
		If !lResult
			lResult := QADGetMail() // Funcao que abre uma janela perguntando o usuario e senha para fazer autenticacao
		EndIf
		If !lResult
			//Erro na conexao com o SMTP Server
			GET MAIL ERROR cError
			Conout(Funname() +  " -  Erro de Autenticacao")
			If lMsgBox
				IW_MsgBox("Erro de Autentica็ใo no emvio do Email: " + cError,OemToAnsi("Informativo"),"ALERT" )
			Endif
			//			MsgInfo(cError,OemToAnsi("Erro de Autenticacao"))
			Return Nil
		Endif
	Else
		If !lResult
			//Erro na conexao com o SMTP Server
			GET MAIL ERROR cError
			Conout(Funname() +  " - Erro de Conexao")
			If lMsgBox
				IW_MsgBox("Erro de Conexใo no Envio do Email: " + cError,OemToAnsi("Informativo"),"ALERT" )
			Endif
			//			MsgInfo(cError,OemToAnsi("Erro de Conexao"))
			Return Nil
		Endif
	EndIf
	//--------------------------------------------------------------------
	//| Valida exist๊ncia de Anexo e Copia para o Server caso necessario... |
	If !Empty( Alltrim( _cAnexo ) ) // Divide ecaminho e nome do arquivo....anexo

		SplitPath( _cAnexo, @cDrive, @cDiretorio, @cNome, @cExtensao )

		//|  Valida se o Endere็o do anexo eh Cliente...
		If At(":",_cAnexo) > 0

			If File(cPathInServer+cNome+cExtensao)
				If fErase(cPathInServer+cNome+cExtensao) == -1
					Iw_MsGbox("Nใo pode copiar o arquivo "+ _cAnexo+" para o servidor "+ cPathInServer+cNome+cExtensao+", jแ existe um arquivo no destino com o mesmo nome e nเo pode ser deletado!!! " )
					lPula := .T.
				EndIf
			EndIf

			If !lPula
				If _CopyFile( _cAnexo , cPathInServer+cNome+cExtensao )
					_cAnexo := cPathInServer+cNome+cExtensao
				Else
					Iw_MsGbox("Nใo pode copiar o arquivo "+ _cAnexo +" para o servidor "+ cPathInServer+cNome+cExtensao+"!!! " )
					lResult := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	// enviando e-mail
	If lResult
		Conout(Funname() +  " - Enviando Email para " + _cMailTo +"/"+ _cCC+"; Assunto:" + _cSubject  )

		ConfirmMailRead( .T. ) // Solicita confirma็ใo de leitura

		SEND MAIL FROM _cMailFrom ;
		TO			_cMailTo ; //		BCC     	cEmailBcc ;
		CC     		_cCC;
		SUBJECT 	_cSubject ;
		BODY    	_cBody ;
		ATTACHMENT  _cAnexo ;
		RESULT lResult

		If !lResult
			//Erro no envio do email
			GET MAIL ERROR cError
			Conout(Funname() + " - Erro no Envio do Email - " + cError)
			If lMsgBox
				IW_MsgBox("Erro no Envio do Email: " + cError,OemToAnsi("Informativo"),"ALERT" )
			Endif
		Else 
			Conout(Funname() + " - Email Enviado com Sucesso para Fornecedor!" )
			If lMsgBox
				IW_MsgBox("Email Enviado com Sucesso para Fornecedor!",OemToAnsi("Informativo"),"INFO" )
			Endif
		EndIf
	Endif
	DISCONNECT SMTP SERVER


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMYQUERY   บAutor  ณMarcioQuevedo Borgesบ Data ณ  12/17/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecuta Query de Consulta                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MyQuery( cQuery , cursor )

	IF SELECT( cursor ) <> 0
		dbSelectArea(cursor)
		DbCloseArea(cursor)
	Endif

	TCQUERY cQuery NEW ALIAS (cursor)

Return
