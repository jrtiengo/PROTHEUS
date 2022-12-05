#Include "Rwmake.ch"
#Include "Topconn.ch"
#Include "AP5Mail.ch"
#Include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEnvia_Email บAutor ณLucas Moresco      บ Data ณ  01/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao Generica para envio de email                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus - Automatech                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function Envia_Email(_Men, _Email, _Arquivo, _Titulo)

Local lResult   := .F.								//Resultado da tentativa de comunicacao com servidor de E-Mail.
Local cTitulo1  := ""								//Titulo.
Local lRelauth  := GetNewPar("MV_RELAUTH",.F.)		//Parametro que indica se existe autenticacao no E-mail.
Local cEmailTo  := ""
Local cEmailBcc := ""                                                                             
Local cError    := ""
Local lRelauth  := GetNewPar("MV_RELAUTH",.F.)		//Parametro que indica se existe autenticacao no E-mail.
Local lRet	    := .F.
Local cFrom	    := GetMV("MV_RELACNT")
Local cConta    := GetMV("MV_RELACNT")
Local cSenhaUsr := GetMV("MV_RELPSW")
Local cNomeArq  := Alltrim(_Arquivo)
Local cAnexo    := cNomeArq

cEmailTo  := _Email
cTitulo1  := _Titulo
cMensagem := _Men

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Tenta conexao com o servidor de E-Mail ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

CONNECT SMTP                ;
SERVER 	 GetMV("MV_RELSERV"); 	//Nome do servidor de e-mail
ACCOUNT  GetMV("MV_RELACNT"); 	//Nome da conta a ser usada no e-mail
PASSWORD GetMV("MV_RELPSW"); 	//Senha
TIMEOUT  GetMV("MV_RELTIME");   // Time-out da autentica็ใo
RESULT   lResult             	//Resultado da tentativa de conexใo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe a conexao estiver correta ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If lResult
	
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe existe autenticacao para envio valida pela funcao MAILAUTHณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

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
			
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณErro no envio do emailณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

			GET MAIL ERROR cError
			Help(" ",1,"ATENCAO",,cError+ " " + cEmailTo,4,5)	//STR0006
		
		Endif
		
	Else
		GET MAIL ERROR cError
		Help(" ",1,"Autenticacao",,cError,4,5)
		MsgStop("Erro de autentica็ใo","Verifique a conta e a senha para envio")
	Endif
	
	DISCONNECT SMTP SERVER
Else
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณErro na conexao com o SMTP Serverณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	GET MAIL ERROR cError
	Help(" ",1,"Atencao",,cError,4,5)

Endif

Return()