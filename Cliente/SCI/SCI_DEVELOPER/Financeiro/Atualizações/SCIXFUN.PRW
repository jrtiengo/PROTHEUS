#Include "Protheus.ch"
#INCLUDE "TBICONN.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณARTXFUN   บAutor  ณMicrosiga           บ Data ณ  26/06/2009 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcoes genericas                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Artmed Editora / Artmed Panamericana                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function InSqlSep( StrIn, Separa, SepUni )

	Local _cInSql := ""
	Local _nCont
	Local _nChar := ''
	Local Separa := Iif( SepUni == Nil, Separa, SepUni )
	Separa := Iif( !ValType( Separa ) == "C", "/", Separa )
	
	If( !Empty( StrIn ) )
		_cInSql := "('"
		For _nCont := 1 To Len( LTrim( StrIn ) )
			_nChar := SubStr( StrIn, _nCont, 1 )
			If !( _nChar $ Separa )
				_cInSql += _nChar
				If( Separa == "" .And. _nCont < Len( LTrim( StrIn ) ) )
					_cInSql += "','"
				EndIf
			Else
				If( _nCont > 1 .And. _nCont < Len( AllTrim( StrIn ) ) )
					_cInSql += "','"
				EndIf
			EndIf
		Next _nCont
		_cInSql += "')"
	EndIf

Return( _cInSql )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณ EnvMail     ณAutor  ณExpedito Mendonca Jrณ Data ณ21/10/2004ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณFaz o envio do e-mail                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso 	 	 ณEspecifico para o cliente Artmed 			                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
USER Function EnvMail(cAccount,cPassword,cFrom,cDest,cCc,cSubj,cMens,cAttach)

Local cAccount	:= GetMv("MV_RELACNT")
Local cPassword := GetMv("MV_RELPSW")
Local cFrom     := GetMv("MV_RELFROM")
Local cServer	:= GetMV("MV_RELSERV" )
Local lAuth	    := Getmv("MV_RELAUTH")
Local lResult	:= .F.
Local cError	:= ""

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
			Alert("Erro de autenticacao no envio de e-mail "+cError)
		Endif
		Return lResult
	Endif
Else
	If !lResult
		//Erro na conexao com o SMTP Server
		If lMsgError
			GET MAIL ERROR cError
			Alert("Erro de conexao com servidor SMTP "+cError)
		else
			FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", "nao consegui conexao"  , 0, 0, {}) 

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
	RESULT lResult
	If !lResult
		//Erro no envio do email
		GET MAIL ERROR cError
		Alert("Erro no envio do e-mail "+cError)

		FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", "problema...."+cDest  , 0, 0, {}) 
	else
		FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", "mandei e-mail para "+cDest  , 0, 0, {}) 
	EndIf
	DISCONNECT SMTP SERVER
EndIf

Return lResult

//--------------------------------------------------------
User Function POSCLI
//--------------------------------------------------------   

If !EMPTY(CN9->CN9_CLIENT)
	//Posicione('SA1',1,xFilial('SA1')+CN9->CN9_FILIAL+CN9->CN9_LOJACL,'A1_NOME') 
	dbSelectArea("SA1")
	dbSeek(xFilial('SA1')+CN9->CN9_CLIENT+CN9->CN9_LOJACL)
	FC010CON("SA1",SA1->(RECNO()),2)
ELSE
	Alert('Contrato a Pagar. Posi็ใo de Cliente nใo pode ser exibido')
END

Return .t.
