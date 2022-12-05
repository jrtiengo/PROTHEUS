#Include "Rwmake.ch"
#Include "Topconn.ch"
#Include "AP5Mail.ch"
#Include "Protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR20.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 01/07/2011                                                          *
// Objetivo..: Programa que envia e-mail no Protheus                               *
//**********************************************************************************

User Function AUTOMR20(_Men, _Email, _Arquivo, _Titulo)

   Local lResult   := .F.								//Resultado da tentativa de comunicacao com servidor de E-Mail.
   Local cTitulo1  := ""								//Titulo.
   Local lRelauth  := GetNewPar("MV_RELAUTH",.F.)		//Parametro que indica se existe autenticacao no E-mail.
   Local cEmailTo  := ""
   Local cEmailBcc := ""                                                                             
   Local cError    := ""
   Local lRelauth  := GetNewPar("MV_RELAUTH",.F.)		//Parametro que indica se existe autenticacao no E-mail.
   Local lRet	   := .F.
   Local cFrom	   := GetMV("MV_RELACNT")
   Local cConta    := GetMV("MV_RELACNT")
   Local cSenhaUsr := GetMV("MV_RELPSW")
   Local cNomeArq  := Alltrim(_Arquivo)
   Local cAnexo    := cNomeArq
   Local nMaxTent  := 10
   Local nTent     := 0
   Local nRet

   U_AUTOM628("AUTOMR20")
   
   cEmailTo  := lower(_Email)
   cTitulo1  := _Titulo
   cMensagem := _Men

   // Tenta conexao com o servidor de E-Mail
   //CONNECT SMTP                
   cServer   := GetMV("MV_RELSERV")	//Nome do servidor de e-mail
   cAccount  := GetMV("MV_RELACNT")	//Nome da conta a ser usada no e-mail
   cPassword := GetMV("MV_RELPSW") 	//Senha
   cTimeout  := GetMV("MV_RELTIME") // Time-out da autenticação
   //RESULT   lResult             	//Resultado da tentativa de conexão

   // Se a conexao estiver correta
   For nTent := 1  To nMaxTent
	
       // Conout(Replicate("*",5))
       // Conout("Tentativa "+Strzero(nTent,2)+" de "+Strzero(nMaxTent,2)+", de envio do email.")
		
  	   // Cria a conexão com o server SMTP ( Envio de e-mail ).
	   oServer := TMailManager():New()
   	   oServer:setUseSSL(.T.)
	   oServer:setUseTLS(.T.)
		
	   oServer:Init( "", SubStr(cServer,0,At(":",cServer) -1), cAccount, cPassword, 0, 587 )
 		
 	   // Seta um tempo de time out com servidor de 1min.
	   If oServer:SetSmtpTimeOut( cTimeOut ) != 0
		  Conout( "Falha ao setar o time out" )
		  Return .F.
	   EndIf
   
	   // Realiza a conexão SMTP.
	   If oServer:SmtpConnect() != 0
	  	  Conout( "Falha ao conectar" )
		  //nTent++
		  Loop
		  // Return .F.
	   EndIf
   
	   // Realiza autenticacao no servidor
	   nErr := oServer:smtpAuth(cAccount, cPassword)
	   If nErr <> 0 
	   	  conOut("[ERROR]Falha ao autenticar: " + oServer:getErrorString(nErr)) 
	   	  oServer:smtpDisconnect() 
	   	  Loop
	   Endif
   
 	   // Após a conexão, cria o objeto da mensagem.
	   oMessage := TMailMessage():New()
   
	   // Limpa o objeto
	   oMessage:Clear()

	   // Popula com os dados de envio.
	   oMessage:cFrom              := cFrom
	   oMessage:cTo                := alltrim(lower(cEmailTo))
	   oMessage:cCc                := ""
	   oMessage:cBcc               := ""      && cEmailBcc
	   oMessage:cSubject           := cTitulo1
	   oMessage:cBody              := cMensagem

       // Anexa o arquivo ao e-mail
       If !Empty(Alltrim(cAnexo))
          nRet := oMessage:AttachFile(cAnexo)
          // Verifica se foi possível anexar o arquivo ao e-mail
          If nRet < 0
             MsgAlert("Erro ao anexar o arquivo de XML " + Alltrim(cAnexo))
             Return(.T.)
          endif
       Endif

	   //Envia o e-mail.
	   If oMessage:Send( oServer ) != 0
	   	  Conout( "Erro ao enviar o e-mail" )
	   	  //nTent++
	   	  Loop
	   	  //Return .F.
	   Else
	   	  Conout("E-mail enviado com sucesso!")
	   	  nTent := nMaxTent
	   	  lReturn := .T.
	   EndIf
   
		//Desconecta do servidor.
  		/*
		If oServer:SmtpDisconnect() != 0
			Conout( "Erro ao disconectar do servidor SMTP" )
			Return .F.
		EndIf
		*/

		If oServer:SmtpDisconnect() != 0
			Conout( "Erro ao desconectar do servidor SMTP." )
		Else
			Conout( "Servidor SMTP desconectado." )
		EndIf
	
		//nTent++
	
	Next nTent

Return(.T.)








// Rotian abaixo é a rotina antiga
// -------------------------------
/*
   If lResult
	
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se existe autenticacao para envio valida pela funcao MAILAUTH³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If lRelauth
		lRet := Mailauth(Alltrim(cConta),Alltrim(cSenhaUsr))
	Else
		lRet := .T.
	Endif
	
	If lRet

		SEND MAIL FROM 	cFrom    ;
		TO 				cEmailTo ;
		BCC     		cEmailBcc;
		SUBJECT 		cTitulo1 ;
		BODY 			cMensagem;
        ATTACHMENT      cAnexo   ;
		RESULT lResult
		
		If !lResult
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Erro no envio do email³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			GET MAIL ERROR cError
			Help(" ",1,"ATENCAO",,cError+ " " + cEmailTo,4,5)	//STR0006
		
		Endif
		
	Else
		GET MAIL ERROR cError
		Help(" ",1,"Autenticacao",,cError,4,5)
		MsgStop("Erro de autenticação","Verifique a conta e a senha para envio")
	Endif
	
	DISCONNECT SMTP SERVER
Else
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Erro na conexao com o SMTP Server³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	GET MAIL ERROR cError
	Help(" ",1,"Atencao",,cError,4,5)

Endif

Return()
*/