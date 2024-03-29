#Include "Rwmake.ch"
#Include "Topconn.ch"
#Include "AP5Mail.ch"
#Include "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AUTA007	�Autor  �Lucas Moresco       � Data �  01/07/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao Generica para envio de email                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus - Automatech                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function AUTA007(cMen,cEmail)

Local lResult   := .F.								//Resultado da tentativa de comunicacao com servidor de E-Mail.
Local cTitulo1  := ""								//Titulo.
Local lRelauth  := GetNewPar("MV_RELAUTH",.F.)		//Parametro que indica se existe autenticacao no E-mail.
Local cEmailTo  := ""
Local cEmailBcc := "administrativo@automatech.com.br"                                                                             
Local cError    := ""
Local lRelauth  := GetNewPar("MV_RELAUTH",.F.)		//Parametro que indica se existe autenticacao no E-mail.
Local lRet	    := .F.
Local cFrom	    := GetMV("MV_RELACNT")
Local cConta    := GetMV("MV_RELACNT")
Local cSenhaUsr := GetMV("MV_RELPSW")

cEmailTo  := Iif(Len(AllTrim(cEmail)) == 0,"administrativo@automatech.com.br",cEmail+";"+"administrativo@automatech.com.br")
cTitulo1  := "Or�amento de Assist�ncia T�cnica "
cMensagem := cMen

//����������������������������������������Ŀ
//� Tenta conexao com o servidor de E-Mail �
//������������������������������������������

CONNECT SMTP                ;
SERVER 	 GetMV("MV_RELSERV"); 	//Nome do servidor de e-mail
ACCOUNT  GetMV("MV_RELACNT"); 	//Nome da conta a ser usada no e-mail
PASSWORD GetMV("MV_RELPSW"); 	//Senha
RESULT   lResult             	//Resultado da tentativa de conex�o


//�����������������������������Ŀ
//�Se a conexao estiver correta �
//�������������������������������

If lResult
	
	
//�������������������������������������������������������������Ŀ
//�Se existe autenticacao para envio valida pela funcao MAILAUTH�
//���������������������������������������������������������������

	If lRelauth
		lRet := Mailauth(cConta,cSenhaUsr)
	Else
		lRet := .T.
	Endif
	
	If lRet
		SEND MAIL FROM 	cFrom ;
		TO 				cEmailTo;
		BCC     		cEmailBcc;
		SUBJECT 		cTitulo1;
		BODY 			cMensagem;
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