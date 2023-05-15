#include "Totvs.ch"
#Include "XmlXFun.ch"
#Include "protheus.ch"
#Include "rwmake.ch"
#INCLUDE "TBICONN.CH"

/*
+---------+-----------+-------+-------------------------------------+------+----------+
| Funcao    | EVOXFUN   | Autor | Manoel M Mariante                   | Data |out/2020  |
|-----------+-----------+-------+-------------------------------------+------+----------|
| Descricao | funÃ§Ãµes diversas                                                          |
|           |                                                                           |
|           |                                                                           |
|-----------+---------------------------------------------------------------------------|
| Sintaxe   | executado dentro de outras personalizaÃ§Ãµes                                |
+-----------+---------------------------------------------------------------------------+
*/
USER Function SendMail(cAccount1,cPassword1,cFrom1,cDest,cCc,cSubj,cMens,aAttach)
	Local lResult	:= .F.
	Local cError	:= ""
	Local cAccount	:= GetMv("MV_RELACNT")
	Local cPassword := GetMv("MV_RELPSW")
	Local cFrom     := GetMv("MV_RELFROM")
	Local cServer	:= GetMV("MV_RELSERV" )
	Local lAuth	    := Getmv("MV_RELAUTH")
	cDest:='manoel.mariante@gmail.com'

	Private lMsgError := .T.

// conectando-se com o servidor de e-mail
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

// fazendo autenticacao
	If lResult .And. lAuth
		lResult := MailAuth(cAccount,cPassword)
		If !lResult
			//Erro na conexao com o SMTP Server
			If lMsgError
				GET MAIL ERROR cError
				u_fMyAlert("Erro de autenticacao no envio de e-mail "+cError)
			Endif
			Return lResult
		Endif
	Else
		If !lResult
			//Erro na conexao com o SMTP Server
			If lMsgError
				GET MAIL ERROR cError
				u_fMyAlert("Erro de conexao com servidor SMTP "+cError)
			else
				u_fMyAlert("nao consegui conexao")
			Endif
			Return lResult
		Endif
	EndIf

// enviando e-mail
	If lResult
		SEND MAIL FROM cFrom ;
			TO			 cDest;
			CC    	 	cCc;
			SUBJECT 	cSubj;
			BODY    	cMens;
			ATTACHMENT aAttach;
			RESULT lResult
		If !lResult
			//Erro no envio do email
			GET MAIL ERROR cError
			u_fMyAlert("Erro no envio do e-mail "+cError+chr(13)+chr(10)+"Problema: "+cDest)
			//u_fMyAlert("problema...."+cDest)
		else
			u_fMyAlert("Email enviado para: "+chr(13)+chr(10)+cDest)
		EndIf
		DISCONNECT SMTP SERVER
	EndIf

Return lResult

//---------------------------------------------------------
User Function fMyAlert(cTexto,lConsole)
//---------------------------------------------------------
	DEFAULT lConsole:=.f.
	
	If 'RPC'$UPPER(funname())
		//conout('PRJ PAPER |'+SM0->M0_CODIGO+'-'+SM0->M0_CODFIL+"|"+Dtoc(msdate())+" | "+time()+' | '+cTexto)
		FWLogMsg("INFO"																                				,;	//cSeverity      - Informe a severidade da mensagem de log. As opções possíveis são: INFO, WARN, ERROR, FATAL, DEBUG
        			  																                				,;	//cTransactionId - Informe o Id de identificação da transação para operações correlatas. Informe "LAST" para o sistema assumir o mesmo id anterior
        		"EVOA600"															                				,;	//cGroup         - Informe o Id do agrupador de mensagem de Log
        																			                				,;	//cCategory      - Informe o Id da categoria da mensagem
																					               					,; 	//cStep          - Informe o Id do passo da mensagem
																					               					,;	//cMsgId         - Informe o Id do código da mensagem
				'PRJ PAPER |'+SM0->M0_CODIGO+'-'+SM0->M0_CODFIL+"|"+Dtoc(msdate())+" | "+time()+' | '+cTexto	    ,;	//cMessage       - Informe a mensagem de log. Limitada à 10K
																													,; 	//nMensure       - Informe a uma unidade de medida da mensagem
																													,;	//nElapseTime    - Informe o tempo decorrido da transação
																													;  	//aMessage       - Informe a mensagem de log em formato de Array - Ex: { {"Chave" ,"Valor"} } 
				)
		
	Else
		IF lConsole
			//conout('PRJ PAPER |'+SM0->M0_CODIGO+'-'+SM0->M0_CODFIL+"|"+Dtoc(msdate())+" | "+time()+' | '+cTexto)
			FWLogMsg("INFO"																                			,;	//cSeverity      - Informe a severidade da mensagem de log. As opções possíveis são: INFO, WARN, ERROR, FATAL, DEBUG
        			  																                				,;	//cTransactionId - Informe o Id de identificação da transação para operações correlatas. Informe "LAST" para o sistema assumir o mesmo id anterior
        		"EVOA600"															                				,;	//cGroup         - Informe o Id do agrupador de mensagem de Log
        																			                				,;	//cCategory      - Informe o Id da categoria da mensagem
																					               					,; 	//cStep          - Informe o Id do passo da mensagem
																					               					,;	//cMsgId         - Informe o Id do código da mensagem
				'PRJ PAPER |'+SM0->M0_CODIGO+'-'+SM0->M0_CODFIL+"|"+Dtoc(msdate())+" | "+time()+' | '+cTexto	    ,;	//cMessage       - Informe a mensagem de log. Limitada à 10K
																													,; 	//nMensure       - Informe a uma unidade de medida da mensagem
																													,;	//nElapseTime    - Informe o tempo decorrido da transação
																													;  	//aMessage       - Informe a mensagem de log em formato de Array - Ex: { {"Chave" ,"Valor"} } 
					)
			
		ELSE
			MsgInfo(cTexto)
		End
		
	End
Return


//---------------------------------------------------------------------------------------------------------------------
User Function MySendMail(cTo,cCC,cOculto,cSubj,cMens,aAttach)
//------------------------------------------------------------------------------------------------------------------
	Local oServer
	Local oMessage, nA

	cAccount	:= alltrim(GetMv("MV_RELACNT"))
	cPassword 	:= alltrim(GetMv("MV_RELPSW"))
	cFrom     	:= alltrim( GetMv("MV_RELFROM"))
	cServer		:= 'email-ssl.com.br' //alltrim(GetMV("MV_RELSERV" ))
	lAuth	    := Getmv("MV_RELAUTH")
	lTls        := Getmv("MV_RELTLS")

	//Local cAccount	:= GetMv("MV_RELACNT")
	///Local cPassword := GetMv("MV_RELPSW")
	//Local cFrom     := GetMv("MV_RELFROM")
	//Local cServer	:= GetMV("MV_RELSERV" )
	//Local lAuth	    := Getmv("MV_RELAUTH")

	//Cria a conexão com o server STMP ( Envio de e-mail )
	oServer := TMailManager():New()
	//oServer:SetUseTLS( lTls )
	oServer:Init( "", cServer, cAccount, cPassword, 0 , 587 )

//seta um tempo de time out com servidor de 1min
	If oServer:SetSmtpTimeOut( 120 ) <> 0
		u_fMyAlert( "Falha ao setar o time out" )
		Return .F.
	EndIf

//realiza a conexão SMTP
	nRet:=oServer:SmtpConnect()

	If nRet <> 0
		u_fMyAlert( "Falha ao conectar : " + oServer:GetErrorString( nRet ) )
		Return .F.
	EndIf

	nRet := oServer:SMTPAuth( cAccount, cPassword )

	IF nRet <> 0
		u_fMyAlert('não consegui autenticar' + oServer:GetErrorString( nRet ))
		return .f.
	end

	//Apos a conexão, cria o objeto da mensagem
	oMessage := TMailMessage():New()

	//Limpa o objeto
	oMessage:Clear()

	//Popula com os dados de envio
	oMessage:cFrom              := cFrom
	oMessage:cTo                := cTo 
	oMessage:cCc                := cCc 
	oMessage:cBcc               := cOculto  
	oMessage:cSubject           := cSubj
	oMessage:cBody              := cMens
	//oMessage:cReplyTo 		  := usrretmail(retcodusr())//SA3->A3_EMAIL

	For nA:=1 to Len(aAttach)
		//Adiciona um attach
		u_fMyAlert( "VOU atachar o arquivo "+ aAttach[nA])
		If oMessage:AttachFile( alltrim(aAttach[nA]) ) < 0
			u_fMyAlert( "Erro ao atachar o arquivo "+ aAttach[nA])
			Return .F.
		Else
			//adiciona uma tag informando que é um attach e o nome do arq
			oMessage:AddAtthTag( 'Content-Disposition: attachment; filename='+ aAttach[nA])
		EndIf
	Next

	//Envia o e-mail
	xRet:=oMessage:Send( oServer )
	If xRet<>0
		cMsg := oServer:GetErrorString( xRet )
		u_fMyAlert( "Erro ao enviar o e-mail"+cMsg )
		//conout( cMsg )
		FwLogMsg("INFO", /**/, "EVOA602", "", "", "", "Msg", , , )
		Return .F.
	EndIf

	//Desconecta do servidor
	If oServer:SmtpDisconnect() != 0
		u_fMyAlert( "Erro ao disconectar do servidor SMTP" )
		Return .F.
	EndIf

Return .t.
