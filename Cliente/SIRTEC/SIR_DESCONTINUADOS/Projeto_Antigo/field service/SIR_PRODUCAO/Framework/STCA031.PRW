#include "rwmake.ch"
#include "topconn.ch"
#include "ap5mail.ch"

#define STR0001 'STCA031'
#define STR0002 'Nao existem e-mails a serem enviados. '
#define STR0003 'Nao foi possivel estabelecer conexao com servidor. '
#define STR0004 'Mensagem enviada corretamente. '
#define STR0005 'Erro no envio da mensagem. '

/*
+----------+----------+-------+-----------------------+------+------------+
|Função    |STCA031   | Autor |RAFAEL COSTA LEITE     | Data |  .  .2006  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |ENVIO DE EMAILS                                               |
+----------+--------------------------------------------------------------+
|Retorno   |Logico                                                        |
+----------+--------------------------------------------------------------+
|Parâmetros|                                                              |
+----------+--------------------------------------------------------------+
|Uso       |GRUPO ALIANÇA                                                 |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+----------+--------------------------------------------------------------+
| Data     | Descrição                                                    |
+----------+--------------------------------------------------------------+
|          |                                                              |
+----------+--------------------------------------------------------------+
*/

User Function STCA031(aEmails,nLog)

Local nInd := 0											// Controle de execucao do "FOR" 
Local lRet := .T.										// Resultado esperado, caso algum e-mail nao seja enviado corretamente, retorna F
Local lResult := .F. 									// Controle da conexao com servidor
Local lSendOk := .F. 									// Controle de envio da mensagem
Local cError  := '' 									// Log de erro no envio da mensagem
Local MV_RELSERV := GetMV("MV_RELSERV")					// Nome do servidor de e-mail
Local MV_RELACNT := GetMV("MV_RELACNT")					// Nome da conta a ser usada no e-mail
Local MV_RELPSW  := GetMV("MV_RELPSW")					// Senha 
Local MV_RELAUTH := GetMV("MV_RELAUTH")                 // Servidor com autenticacao   
Local MV_RELAUSR := GetMV("MV_RELAUSR")					//Usuario para autenticacao
Local MV_RELAPSW := GetMV("MV_RELAPSW")					//Senha para autenticacao        
Local cFrom       := ''									//Remetente
Local cTo         := ''		                            //Destinatario
Local cSubject    := ''                                 //Assunto
Local cBody       := ''                                 //Mensagem
Local lFormat     := .F.                                //Arquivo texto ou html
Local cAttachment := ''                                 //Anexos

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Layout do array aEmails                                                                                                         //
//----------------------------------------------------------------------------------------------------------------------------------//
//aEmails[1] - array contendo as informacoes de uma mensagem                                                                        //
//aEmails[1][1] - cDe - Remetente da mensage, caso esteja em branco assume o valor de MV_RELACNT                                    //
//aEmails[1][2] - cPara - Destinatarios do e-mail, caso exista mais de um separe com ;                                              //
//aEmails[1][3] - cAssunt0 - Assunto do e-mail                                                                                      //
//aEmails[1][4] - cMensagem - Mensagem do e-mail                                                                                    //
//aEmails[1][5] - cAnexos - Anexos a serem envidos na mensagem                                                                      //
//aEmails[1][6] - cTexto - Mensagem em formato texto? S/N                                                                           //
//                                                                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Verifica se existe conteudo no array de e-mails
If Empty(aEmails[1][2])
	
	//Envia mensagem de erro
	f_STC01(STR0002,STR0001,nLog) //'Nao existem e-mails a serem enviados. ' 
	Return  
Endif

//////////////////////////////////////////////////////////
//  Envia todos os e-mails existentes no array aEmails  //
//////////////////////////////////////////////////////////
For nInd:=1 To Len(aEmails)
			
	///////////////////////////////////////
	//  Carrega informacoes da mensagem  //
	///////////////////////////////////////
    cFrom       := If(Empty(aEmails[nInd][1]),MV_RELACNT,aEmails[nInd][1])
    cTo         := aEmails[nInd][2]
    cSubject    := aEmails[nInd][3]
    cBody       := aEmails[nInd][4]
    cAttachment := aEmails[nInd][5]
    lFormat     := aEmails[nInd][6] == 'S'
    
	//////////////////////////////////////////////
	//  Tenta conexao com o servidor de E-Mail  //
	//////////////////////////////////////////////
	CONNECT SMTP          ;
	SERVER   MV_RELSERV   ; 	// Nome do servidor de e-mail
	ACCOUNT  MV_RELACNT   ; 	// Nome da conta a ser usada no e-mail
	PASSWORD MV_RELPSW    ; 	// Senha
	RESULT   lResult           	// Resultado da tentativa de conexão
	
	/////////////////////////////////////////////////////////////////
	//  Verifica se o Servidor de EMAIL necessita de Autenticacao  //
	/////////////////////////////////////////////////////////////////
	If lResult .and. MV_RELAUTH
		
		//Primeiro tenta fazer a Autenticacao de E-mail utilizando o e-mail completo
		lResult := MailAuth(MV_RELAUSR,MV_RELAPSW)
		
		//Se nao conseguiu fazer a Autenticacao usando o E-mail completo, tenta fazer a autenticacao usando apenas o nome de usuario do E-mail
		if !lResult
			nA 		:= At("@",MV_RELAUSR)
			cUser 	:= If(nA>0,Subs(MV_RELAUSR,1,nA-1),MV_RELAUSR)
			lResult := MailAuth(cUser,MV_RELAPSW)
		endif
	endif
	
	If !lResult
		
		///////////////////////////////////////////////////////////
		//  Nao foi possivel estabelecer conexao com o servidor  //
		///////////////////////////////////////////////////////////
		
		//Envia mensagem de erro
		f_STC01(STR0003,STR0001,nLog) //'Nao foi possivel estabelecer conexao com servidor. '
		
	Else
		
		//Mensagem em formato TEXTO
		If lFormat
			SEND MAIL 				            ;  // Inicia e-mail		
			FROM 		 cFrom                  ;  // Remetente
			TO 		     cTo  			  	    ;  // Destinatario
			SUBJECT 	 cSubject          	    ;  // Assunto
			BODY 		 cBody  FORMAT TEXT     ;  // Mensagem
			ATTACHMENT   cAttachment            ;  // Anexos
			RESULT 	lSendOk                        // Resultado 
		
		//Mensagem em formato HTML
		Else
			SEND MAIL 				            ;  // Inicia e-mail		
			FROM 		 cFrom                  ;  // Remetente
			TO 		     cTo  			  	    ;  // Destinatario
			SUBJECT 	 cSubject          	    ;  // Assunto
			BODY 		 cBody  FORMAT TEXT     ;  // Mensagem
			ATTACHMENT   cAttachment            ;  // Anexos
			RESULT 	lSendOk                        // Resultado	
		Endif
			
		If !lSendOk
			///////////////////////////////
			//  Erro no Envio do e-mail  //                                                
			///////////////////////////////
                    
			//Captura erro
			GET MAIL ERROR cError
		EndIf

		
		/////////////////////////////////////////////////
		//  Finaliza conexao com o servidor de E-Mail  //
		/////////////////////////////////////////////////
		DISCONNECT SMTP SERVER 
		
		If !lSendOk
			///////////////////////////////
			//  Erro no Envio do e-mail  //                                                
			///////////////////////////////
            
            //Envia mensagem de erro
			f_STC01(cError,STR0001,nLog)
			
			lRet := .F.
		Else
			//Envia mensagem de aviso
			f_STC01(STR0004,STR0001,nLog)
		EndIf
	EndIf
			
Next nInd
			
Return lRet

/*
+----------+----------+-------+-----------------------+------+------------+
|Função    |STCA031   | Autor |RAFAEL COSTA LEITE     | Data |  .  .2006  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |TESTE DE ENVIO DE EMAILS                                      |
+----------+--------------------------------------------------------------+
|Retorno   |#                                                             |
+----------+--------------------------------------------------------------+
|Parâmetros|                                                              |
+----------+--------------------------------------------------------------+
|Uso       |GRUPO ALIANCA                                                 |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+----------+--------------------------------------------------------------+
| Data     | Descrição                                                    |
+----------+--------------------------------------------------------------+
|          |                                                              |
+----------+--------------------------------------------------------------+
*/
User Function STCA031A

Local cPerg := PADR('STCA031', 10 , " ")  //PADR('STCA031', len(SX1->X1_GRUPO), " ")
Local aInfo := {}
Local cInfRem := ''
Local cInfDes := ''
Local cInfAst := ''
Local cInfMen := ''
Local cInfAne := ''
Local cInfFor := 'S'			//Fixo formato de texto 

//Ajusta grupo de perguntas
f_STC02()

If Pergunte(cPerg,.T.)
	
	cInfDes := MV_PAR01
	cInfAst := MV_PAR02
	cInfMen := MV_PAR03
	cInfAne := MV_PAR04
	
	aInfo := {{cInfRem,cInfDes,cInfAst,cInfMen,cInfAne,cInfFor}}
	
	If! U_STCA031(aInfo,2)
    	Alert("Erro")
	Endif
Endif

Return

/*
+----------+----------+-------+-----------------------+------+------------+
|Função    |f_STC01   | Autor |RAFAEL COSTA LEITE     | Data |  .  .2006  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Mensagem de controle da rotina                                |
+----------+--------------------------------------------------------------+
|Retorno   |#                                                             |
+----------+--------------------------------------------------------------+
|Parâmetros|cMensagem - mensagem a ser exibida                            |
|          |cTitulo   - titulo da mensagem                                |
|          |nTipo     - 1 - uso de conout()                               |
|          |            2 - uso de MsgAlert()                             |
+----------+--------------------------------------------------------------+
|Uso       |GRUPO ALIANCA                                                 |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+----------+--------------------------------------------------------------+
| Data     | Descrição                                                    |
+----------+--------------------------------------------------------------+
|          |                                                              |
+----------+--------------------------------------------------------------+
*/
Static Function f_STC01(cMensagem,cTitulo,nTipo)

//Uso de log com conout
If nTipo == 1
	//ConOut(cMensagem+cTitulo)
	FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , cMensagem+cTitulo)

//Uso de log com mensagem para o usuario
Elseif nTipo == 2

	MsgAlert(cMensagem,cTitulo)
Endif

Return

/*
+----------+----------+-------+-----------------------+------+------------+
|Função    |f_STC02   | Autor |RAFAEL COSTA LEITE     | Data |  .  .2006  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Cria grupo de perguntas                                       |
+----------+--------------------------------------------------------------+
|Retorno   |#                                                             |
+----------+--------------------------------------------------------------+
|Parâmetros|#                                                             |
+----------+--------------------------------------------------------------+
|Uso       |GRUPO ALIANCA                                                 |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+----------+--------------------------------------------------------------+
| Data     | Descrição                                                    |
+----------+--------------------------------------------------------------+
|          |                                                              |
+----------+--------------------------------------------------------------+
*/
Static Function f_STC02(cMensagem,cTitulo,nTipo)

Local aArea	:= GetArea()
Local cVar	:= 'MV_CH0'
Local cGSC	:= 'G'
Local cTipo	:= 'C' 
Local cOrdem:= '00'
Local cVar01:= 'MV_PAR00'
Local cGrupo:= 'STCA031'
Local cPerSpa	:= cPerSpa	:= cPerEng	:= '.'
Local nDecimal	:= nPresel := 0
Local cValid:=cF3:=cGrpSxg:=cPyme:=cDef01:=cDefSpa1:=cDefEng1:=cCnt01:=cDef02:=cDefSpa2:=cDefEng2:=cDef03:=cDefSpa3:=cDefEng3:=cDef04:=cDefSpa4:=cDefEng4:=cDef05:=cDefSpa5:=cDefEng5:=cHelp:=''
Local aHelpPor:=aHelpEng:=aHelpSpa:={}

/*
PutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,cTipo,nTamanho,nDecimal,nPresel,cGSC,cValid,cF3,cGrpSxg,cPyme,cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp)
*/

/*
//Destinatario
cOrdem  := SOMA1(cOrdem,2)
cVar01  := SOMA1(cVar01,2)
aHelpPor:={}


PutSx1(cGrupo,cOrdem,'Destinatario ',cPerSpa,cPerEng,cVar,cTipo,99,nDecimal,nPresel,cGSC,cValid,cF3,cGrpSxg,cPyme,cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp)

//Assunto
cOrdem  := SOMA1(cOrdem,2)
cVar01  := SOMA1(cVar01,2)
aHelpPor:={}

PutSx1(cGrupo,cOrdem,'Assunto ',cPerSpa,cPerEng,cVar,cTipo,99,nDecimal,nPresel,cGSC,cValid,cF3,cGrpSxg,cPyme,cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp)

//Mensagem
cOrdem  := SOMA1(cOrdem,2)
cVar01  := SOMA1(cVar01,2)
aHelpPor:={}

PutSx1(cGrupo,cOrdem,'Mensagem ',cPerSpa,cPerEng,cVar,cTipo,99,nDecimal,nPresel,cGSC,cValid,cF3,cGrpSxg,cPyme,cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp)

//Anexo
cOrdem  := SOMA1(cOrdem,2)
cVar01  := SOMA1(cVar01,2)
aHelpPor:={}

PutSx1(cGrupo,cOrdem,'Anexos ',cPerSpa,cPerEng,cVar,cTipo,99,nDecimal,nPresel,'F',cValid,cF3,cGrpSxg,cPyme,cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp)

*/

RestArea(aArea)

Return