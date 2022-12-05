#Include "Rwmake.ch"
#Include "Topconn.ch"
#Include "AP5Mail.ch"
#Include "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Envia_Email �Autor �Lucas Moresco      � Data �  01/07/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao Generica para envio de email                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus - Automatech                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

//����������������������������������������Ŀ
//� Tenta conexao com o servidor de E-Mail �
//������������������������������������������

CONNECT SMTP                ;
SERVER 	 GetMV("MV_RELSERV"); 	//Nome do servidor de e-mail
ACCOUNT  GetMV("MV_RELACNT"); 	//Nome da conta a ser usada no e-mail
PASSWORD GetMV("MV_RELPSW"); 	//Senha
TIMEOUT  GetMV("MV_RELTIME");   // Time-out da autentica��o
RESULT   lResult             	//Resultado da tentativa de conex�o

//�����������������������������Ŀ
//�Se a conexao estiver correta �
//�������������������������������

If lResult
	
	
//�������������������������������������������������������������Ŀ
//�Se existe autenticacao para envio valida pela funcao MAILAUTH�
//���������������������������������������������������������������

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
			
		//����������������������Ŀ
		//�Erro no envio do email�
		//������������������������

			GET MAIL ERROR cError
			Help(" ",1,"ATENCAO",,cError+ " " + cEmailTo,4,5)	//STR0006
		
		Endif
		
	Else
		GET MAIL ERROR cError
		Help(" ",1,"Autenticacao",,cError,4,5)
		MsgStop("Erro de autentica��o","Verifique a conta e a senha para envio")
	Endif
	
	DISCONNECT SMTP SERVER
Else
	
	//���������������������������������Ŀ
	//�Erro na conexao com o SMTP Server�
	//�����������������������������������

	GET MAIL ERROR cError
	Help(" ",1,"Atencao",,cError,4,5)

Endif

Return()