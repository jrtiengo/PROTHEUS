#INCLUDE "ap5mail.ch"
#INCLUDE "protheus.ch"
#INCLUDE "tbiconn.ch"

// Jean Rehermann | JPC - Efetua a gravação do log logo após alteração de status do item do PV
User Function GrvLogSts( cFilOrig, cPedido, cItem, cStatus, cOrigem )
	
   U_AUTOM628("GRVLOGSTS")

	_cOrigem := Iif( Empty( AllTrim( cOrigem ) ) .Or. cOrigem == Nil, "", cOrigem ) // Qual fonte está gravando
	_aArea := GetArea()
	
	dbSelectArea("ZZ0")
	RecLock("ZZ0",.T.)
		ZZ0->ZZ0_FILIAL := cFilOrig
		ZZ0->ZZ0_PEDIDO := cPedido
		ZZ0->ZZ0_ITEMPV := cItem
		ZZ0->ZZ0_STATUS := cStatus
		ZZ0->ZZ0_USER   := RetCodUsr()
		ZZ0->ZZ0_DATA   := dDataBase
		ZZ0->ZZ0_HORA   := Time()
		ZZ0->ZZ0_ORIGEM := _cOrigem
	MsUnlock()
	
	RestArea( _aArea )
	
Return Nil

// Jean Rehermann | JPC - Efetua o envio de e-mail para o cliente e o vendedor do pedido
// Jean Rehermann | Solutio - 09/01/2012 - Inclui o terceiro parametro da função (aitens) que contera os itens que forem fat. ou exp.
User Function MailSts( cPedido, cItens, cTipo )

	Local _lMailSrv   := .F.
	Local _cQuery     := ""
	Local _cCodTransp := AllTrim( GetMv("MV_TRANSTS") ) // Parâmetro com código de transportadora quando for O PRÓPRIO
	Local _lEnviaCli  := AllTrim( GetMv("MV_STSEMCL") ) == "S" // Parâmetro que indica se envia e-mail para os clientes
	Local _lEnviaVnd  := AllTrim( GetMv("MV_STSEMVN") ) == "S" // Parâmetro que indica se envia e-mail para os vendedores
	Local _nTotal     := 0
	Local _cLinhas    := ""
	Local _cTpSaida   := ""
	Local _cCliente   := ""
	Local _cMailCli   := ""
	Local _cNota      := ""
	Local _cTransp    := ""
	Local _cCodTran   := ""
	Local _aMailVend  := {}
	Private _cBody    := "<html><head><title>Pedido de Venda #C5_NUM#</title></head><body><center><table><tr><td><img width='722' height='150' src='http://www.automatech.com.br/images/automatech_mail_img_1.jpg'></td></tr><tr><td style='font-family:Arial;padding-left: 30pt;'>O seu pedido número <big><b>#C5_NUM#</b></big> está disponível.<br /><br />Muito obrigado por utilizar nossos produtos e serviços, #A1_NOME#<br /><br />Abaixo seguem as informações de seu pedido,<br /><br />N. Pedido: <b>#C5_NUM#</b><br />Tipo de Saída: <b>#SX5_13#</b><br />Cliente: <b>#A1_NOME#</b><br />Total Pedido: <b>R$ #TOTAL#</b><br />N. Nota Fiscal: <b>#F1_DOC#</b><br />Transportadora: <b>#A4_NOME#</b><br /><br /><table border='1' cellspacing='0' cellpadding='5' width='100%'><tr><th>Cód. Produto</th><th>Descrição</th><th>Nº Série</th><th>Valor Unit.</th><th>Quantidade</th><th>Total</th></tr>#ITENS#</table><br /></td></tr><tr><td><img width='722' height='144' src='http://www.automatech.com.br/images/automatech_mail_img_2.jpg'></td></tr></table></center></body></html>"

   U_AUTOM628("GRVLOGSTS")

    // Retorno colocado em função dos vendedores estarem recebendo aviso de faturamento
    // Conforme e-mail do Roger do dia 06/04/2015, este aviso não é para ser mais disparado.
    Return(.T.)
 	
	// Se o pedido não for informado ou se ambos parametros forem falsos
	If Empty( AllTrim( cPedido ) ) .Or. !( _lEnviaCli .Or. _lEnviaVnd )
		Return
	EndIf
	
	// Cria conexão com o servidor de e-mails conforme parâmetros de conexão do sistema. Retorna .T. ou .F.
	_lMailSrv := SmtpConn()
	
	If !_lMailSrv
		Return
	EndIf
	
/*
	_cQuery := " SELECT C5_TRANSP, C5_CLIENTE, C5_LOJACLI, C5_VEND1, C5_VEND2, C5_VEND3, C5_VEND4, C5_VEND5, C5_NOTA, C5_SERIE, "
	_cQuery += " C6_PRODUTO, C6_DESCRI, C6_PRCVEN, C6_QTDVEN, C6_VALOR, C6_TES, C6_STATUS, C6_FILIAL "
	_cQuery += " FROM "+ RetSqlName("SC5") +" SC5, "+ RetSqlName("SC6") +" SC6 "
	_cQuery += " WHERE SC5.C5_FILIAL = SC6.C6_FILIAL "
	_cQuery += " AND SC5.C5_NUM = SC6.C6_NUM "
	_cQuery += " AND SC6.C6_ITEM IN "+ InSqlSep( cItens, , "|" ) // Jean Rehermann | Solutio - 09/01/2012 - Inclui esta condição, novo parametro da função
	_cQuery += " AND SC5.D_E_L_E_T_ = ' ' "
	_cQuery += " AND SC6.D_E_L_E_T_ = ' ' "
	_cQuery += " AND SC5.C5_FILIAL = '"+ xFilial("SC5") +"' "
	_cQuery += " AND SC5.C5_NUM = '"+ cPedido +"' "

	If !T_C5C6->( Eof() )

		_cCliente := Posicione( "SA1", 1, xFilial("SA1") + T_C5C6->C5_CLIENTE + T_C5C6->C5_LOJACLI, "A1_NOME" )
		_cMailCli := Posicione( "SA1", 1, xFilial("SA1") + T_C5C6->C5_CLIENTE + T_C5C6->C5_LOJACLI, "A1_EMAIL" )
		_cTransp  := Posicione( "SA4", 1, xFilial("SA4") + T_C5C6->C5_TRANSP, "A4_NOME" )
		_cNota    := AllTrim( T_C5C6->C5_NOTA ) +" / "+ T_C5C6->C5_SERIE
		_cCodTran := T_C5C6->C5_TRANSP
		
		If !Empty( AllTrim( T_C5C6->C5_VEND1 ) )
			aAdd( _aMailVend, Posicione( "SA3", 1, xFilial("SA3") + T_C5C6->C5_VEND1, "A3_EMAIL" ) )
		EndIf
		If !Empty( AllTrim( T_C5C6->C5_VEND2 ) )
			aAdd( _aMailVend, Posicione( "SA3", 1, xFilial("SA3") + T_C5C6->C5_VEND2, "A3_EMAIL" ) )
		EndIf
		If !Empty( AllTrim( T_C5C6->C5_VEND3 ) )
			aAdd( _aMailVend, Posicione( "SA3", 1, xFilial("SA3") + T_C5C6->C5_VEND3, "A3_EMAIL" ) )
		EndIf
		If !Empty( AllTrim( T_C5C6->C5_VEND4 ) )
			aAdd( _aMailVend, Posicione( "SA3", 1, xFilial("SA3") + T_C5C6->C5_VEND4, "A3_EMAIL" ) )
		EndIf
		If !Empty( AllTrim( T_C5C6->C5_VEND5 ) )
			aAdd( _aMailVend, Posicione( "SA3", 1, xFilial("SA3") + T_C5C6->C5_VEND5, "A3_EMAIL" ) )
		EndIf
		
		While !T_C5C6->( Eof() )
		
			_cNroSerie := PegaSerie( T_C5C6->C6_FILIAL + T_C5C6->C6_PRODUTO + T_C5C6->C5_NOTA + T_C5C6->C5_SERIE + T_C5C6->C5_CLIENTE + T_C5C6->C5_LOJACLI )
			
			_cLinhas += "<tr>"
			_cLinhas += "<td>"+ T_C5C6->C6_PRODUTO +"</td>"
			_cLinhas += "<td>"+ T_C5C6->C6_DESCRI +"</td>"
			_cLinhas += "<td>"+ _cNroSerie +"</td>"
			_cLinhas += "<td>"+ Transform( T_C5C6->C6_PRCVEN, "@E 999,999,999.99" ) +"</td>"
			_cLinhas += "<td>"+ Transform( T_C5C6->C6_QTDVEN, "@E 999,999.99" ) +"</td>"
			_cLinhas += "<td>"+ Transform( T_C5C6->C6_VALOR , "@E 999,999,999.99" ) +"</td>"
			_cLinhas += "</tr>"
			
			_nTotal += T_C5C6->C6_VALOR
			_cTpSaida += Posicione( "SF4", 1, xFilial("SF4") + T_C5C6->C6_TES, "F4_TEXTO" ) + ","
			T_C5C6->( dbSkip() )
		End

	EndIf

	T_C5C6->( dbCloseArea() )

	_cBody := StrTran( _cBody, "#C5_NUM#", cPedido )
	_cBody := StrTran( _cBody, "#A1_NOME#", _cCliente )
	_cBody := StrTran( _cBody, "#SX5_13#", _cTpSaida )
	_cBody := StrTran( _cBody, "#TOTAL#", Transform( _nTotal, "@E 999,999,999.99" ) )
	_cBody := StrTran( _cBody, "#F1_DOC#", _cNota )
	_cBody := StrTran( _cBody, "#A4_NOME#", _cTransp )
	_cBody := StrTran( _cBody, "#ITENS#", _cLinhas )
	
	If cTipo == "E"
		_cBody := StrTran( _cBody, "está disponível", "foi expedido" )
	ElseIf cTipo == "F" .And. _cCodTransp != _cCodTran
		_lEnviaCli := .F.
		//_lEnviaVnd := .F.
	EndIf
	
	If !Empty( AllTrim( _cMailCli ) ) .And. _lEnviaCli
		xEnvMail( _cMailCli, "Aviso de "+ Iif( cTipo == "E", "Entrega", Iif( cTipo == "F", "Faturamento", "Entrega ou Faturamento" ) ) )
	EndIf
	
	If Len( _aMailVend ) > 0 .And. _lEnviaVnd
		For nX := 1 To Len( _aMailVend )
			xEnvMail( _aMailVend[ nX ], "Aviso de "+ Iif( cTipo == "E", "Entrega", Iif( cTipo == "F", "Faturamento", "Entrega ou Faturamento" ) ) )
		Next
	EndIf
	
	DISCONNECT SMTP SERVER

*/

    _cQuery := "SELECT A.F2_TRANSP ,"
    _cQuery += "       A.F2_CLIENTE,"
    _cQuery += "       A.F2_LOJA   ,"
    _cQuery += "       A.F2_VEND1  ,"
    _cQuery += "       A.F2_VEND2  ,"
    _cQuery += "       A.F2_VEND3  ,"
    _cQuery += "       A.F2_VEND4  ,"
    _cQuery += "       A.F2_VEND5  ,"
    _cQuery += "       A.F2_DOC    ,"
    _cQuery += "       A.F2_SERIE  ,"
    _cQuery += "       B.D2_COD    ,"
    _cQuery += "       C.B1_DESC   ,"
    _cQuery += "       B.D2_PRCVEN ,"
    _cQuery += "       B.D2_QUANT  ,"
    _cQuery += "       B.D2_TOTAL  ,"
    _cQuery += "       B.D2_TES    ,"
    _cQuery += "       B.D2_ITEMPV ,"
    _cQuery += "       B.D2_FILIAL ,"
    _cQuery += "       B.D2_PEDIDO  "
    _cQuery += "  FROM SF2010 A, "
    _cQuery += "       SD2010 B, "
    _cQuery += "       SB1010 C  "
    _cQuery += " WHERE A.F2_FILIAL    = B.D2_FILIAL"
    _cQuery += "   AND A.F2_DOC       = B.D2_DOC   "
    _cQuery += "   AND A.F2_SERIE     = B.D2_SERIE "
    _cQuery += "   AND A.F2_FILIAL    = B.D2_FILIAL"
	_cQuery += "   AND B.D2_ITEMPV IN "+ InSqlSep( cItens, , "|" ) // Jean Rehermann | Solutio - 09/01/2012 - Inclui esta condição, novo parametro da função
    _cQuery += "   AND A.R_E_C_D_E_L_ = '' "
    _cQuery += "   AND C.B1_COD       = B.D2_COD "
    _cQuery += "   AND A.F2_FILIAL    = '"+ xFilial("SC5") + "'"
    _cQuery += "   AND B.D2_PEDIDO    = '"+ cPedido        + "'"
    _cQuery += " ORDER BY B.D2_ITEMPV "
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"T_C5C6",.T.,.T.)
	
	If !T_C5C6->( Eof() )

		_cCliente := Posicione( "SA1", 1, xFilial("SA1") + T_C5C6->F2_CLIENTE + T_C5C6->F2_LOJA, "A1_NOME" )
		_cMailCli := Posicione( "SA1", 1, xFilial("SA1") + T_C5C6->F2_CLIENTE + T_C5C6->F2_LOJA, "A1_EMAIL" )
		_cTransp  := Posicione( "SA4", 1, xFilial("SA4") + T_C5C6->F2_TRANSP, "A4_NOME" )
		_cNota    := AllTrim( T_C5C6->F2_DOC ) +" / "+ T_C5C6->F2_SERIE
		_cCodTran := T_C5C6->F2_TRANSP
		
		If !Empty( AllTrim( T_C5C6->F2_VEND1 ) )
			aAdd( _aMailVend, Posicione( "SA3", 1, xFilial("SA3") + T_C5C6->F2_VEND1, "A3_EMAIL" ) )
		EndIf
		If !Empty( AllTrim( T_C5C6->F2_VEND2 ) )
			aAdd( _aMailVend, Posicione( "SA3", 1, xFilial("SA3") + T_C5C6->F2_VEND2, "A3_EMAIL" ) )
		EndIf
		If !Empty( AllTrim( T_C5C6->F2_VEND3 ) )
			aAdd( _aMailVend, Posicione( "SA3", 1, xFilial("SA3") + T_C5C6->F2_VEND3, "A3_EMAIL" ) )
		EndIf
		If !Empty( AllTrim( T_C5C6->F2_VEND4 ) )
			aAdd( _aMailVend, Posicione( "SA3", 1, xFilial("SA3") + T_C5C6->F2_VEND4, "A3_EMAIL" ) )
		EndIf
		If !Empty( AllTrim( T_C5C6->F2_VEND5 ) )
			aAdd( _aMailVend, Posicione( "SA3", 1, xFilial("SA3") + T_C5C6->F2_VEND5, "A3_EMAIL" ) )
		EndIf
		
		While !T_C5C6->( Eof() )
		
			_cNroSerie := PegaSerie( T_C5C6->D2_FILIAL + T_C5C6->D2_COD + T_C5C6->F2_DOC + T_C5C6->F2_SERIE + T_C5C6->F2_CLIENTE + T_C5C6->F2_LOJA )
			                                                                                                           
            _cLinhas += "<tr>"
			_cLinhas += "<td>"+ T_C5C6->D2_COD  + "</td>"
			_cLinhas += "<td>"+ T_C5C6->B1_DESC + "</td>"
			_cLinhas += "<td>"+ _cNroSerie +"</td>"
			_cLinhas += "<td>"+ Transform( T_C5C6->D2_PRCVEN, "@E 999,999,999.99" ) + "</td>"
			_cLinhas += "<td>"+ Transform( T_C5C6->D2_QUANT , "@E 999,999.99" )     + "</td>"
			_cLinhas += "<td>"+ Transform( T_C5C6->D2_TOTAL , "@E 999,999,999.99" ) + "</td>"
			_cLinhas += "</tr>"
			
			_nTotal += T_C5C6->D2_TOTAL

            If Empty(_cTpSaida)
   			   _cTpSaida += Posicione( "SF4", 1, xFilial("SF4") + T_C5C6->D2_TES, "F4_TEXTO" ) + ","
   			Endif

			T_C5C6->( dbSkip() )
		End

	EndIf

	T_C5C6->( dbCloseArea() )

	_cBody := StrTran( _cBody, "#C5_NUM#" , cPedido )
	_cBody := StrTran( _cBody, "#A1_NOME#", _cCliente )
	_cBody := StrTran( _cBody, "#SX5_13#" , _cTpSaida )
	_cBody := StrTran( _cBody, "#TOTAL#"  , Transform( _nTotal, "@E 999,999,999.99" ) )
	_cBody := StrTran( _cBody, "#F1_DOC#" , _cNota )
	_cBody := StrTran( _cBody, "#A4_NOME#", _cTransp )
	_cBody := StrTran( _cBody, "#ITENS#"  , _cLinhas )

	If cTipo == "E"                    
		_cBody := StrTran( _cBody, "está disponível", "foi expedido" )
    Endif

//	ElseIf cTipo == "F" .And. _cCodTransp != _cCodTran
//		_lEnviaCli := .F.
//		//_lEnviaVnd := .F.
//	EndIf
	
	If !Empty( AllTrim( _cMailCli ) ) .And. _lEnviaCli
		xEnvMail( _cMailCli, "Aviso de "+ Iif( cTipo == "E", "Entrega", Iif( cTipo == "F", "Faturamento", "Entrega ou Faturamento" ) ) )
	EndIf
	
	If Len( _aMailVend ) > 0 .And. _lEnviaVnd
		For nX := 1 To Len( _aMailVend )
			xEnvMail( _aMailVend[ nX ], "Aviso de "+ Iif( cTipo == "E", "Entrega", Iif( cTipo == "F", "Faturamento", "Entrega ou Faturamento" ) ) )
		Next
	EndIf
	
	DISCONNECT SMTP SERVER

Return

/*
	Jean Rehermann | JPC - Função SmtpConn - Conecta ao servidor de e-mails
*/
Static Function SmtpConn()

	Local _cServer := GETMV("MV_RELSERV") // Servidor de email.
	Local _cPass   := GETMV("MV_RELPSW")  // Senha para acessar o e-mail.
	Local _cUser   := GETMV('MV_RELACNT') // Usuário para acessar o e-mail.
	Local _lAuth   := GETMV("MV_RELAUTH") // Flag se precisa autenticar ou não.
	Local _nTime   := GETMV("MV_RELTIME")
	Local _cErro   := ""  // Conterá o erro retornado, caso ocorra.
	Local _lResult := .T. // Conterá o resultado da conexão.

   U_AUTOM628("GRVLOGSTS")

	CONNECT SMTP SERVER _cServer ACCOUNT _cUser PASSWORD _cPass TIMEOUT _nTime RESULT _lResult

	IF _lResult .AND. _lAuth
		_lResult := MAILAUTH( _cUser, _cPass )
		IF !_lResult
			_lResult := MAILAUTH( _cUser, _cPass )
		ENDIF
		IF !_lResult
			GET MAIL ERROR _cErro
	    	MsgAlert( "ERRO DE AUTENTICACAO DE E-MAIL: "+ _cErro )
		ENDIF
	ELSE
		IF !_lResult
			GET MAIL ERROR _cErro
	    	MsgAlert( "ERRO DE CONEXAO NO ENVIO DE E-MAIL: "+ _cErro )
		ENDIF
	ENDIF

Return _lResult

/*
Jean Rehermann | JPC - Busca os números de série utilizados no item
*/
Static Function PegaSerie( cChave )

	Local _cRet := ""
	Local _aArea := GetArea()
	
   U_AUTOM628("GRVLOGSTS")

	dbSelectArea("SDB") // Movimentos de Distribuição
	dbSetOrder(7) // DB_FILIAL+DB_PRODUTO+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_SERVIC+DB_TAREFA+DB_ATIVID
	If dbSeek( cChave )
	
		While !SDB->( Eof() ) .And. SDB->DB_FILIAL + SDB->DB_PRODUTO + SDB->DB_DOC + SDB->DB_SERIE + SDB->DB_CLIFOR + SDB->DB_LOJA == cChave
			
			If SDB->DB_ESTORNO == ' ' // Apenas o que não está estornado
				_cRet += SDB->DB_NUMSERI + "<br>"
			EndIf
			
			SDB->( dbSkip() )
		End

	EndIf
	
	RestArea( _aArea )
	
Return( _cRet )

/*
	Função xEnvMail - Envia o email para o destinatário no parâmetro
*/
Static Function xEnvMail( cDest, cAssunto )

	Local _cConta  := "protheus@automatech.com.br"
	Local _lResult := .T.   // Resultado do envio
	Local _cErro   := ""    // Erro caso ocorra

	If !Empty( cDest ) // Envia o e-mail caso o destinatário não esteja vazio
	
		SEND MAIL FROM _cConta;
		TO cDest;
		SUBJECT cAssunto;
		BODY _cBody;
		RESULT _lResult
               
		If !_lResult
			//Erro no envio do email
			GET MAIL ERROR _cErro
	    	MsgAlert( "ERRO NO ENVIO DE E-MAIL PARA "+ cDest +": "+ _cErro )
		Endif	

	Else
		_lResult := .F.	// E-mail não foi enviado pois não foi passado o endereço por parametro para a função
    	MsgAlert( "Não foi encontrado e-mail para ser enviado!" )
	EndIf
		
Return _lResult

// Função para adequar uma string ao comando IN do SQL
// (String a ser adequada, String com possíveis caracteres de separação, Caracter de separação conhecido)
Static Function InSqlSep( StrIn, Separa, SepUni )

	Local _cInSql := ""
	Local _nCont
	Local _nChar := ''
	Local Separa := Iif( SepUni == Nil, Separa, SepUni )
	Separa := Iif( !ValType( Separa ) == "C", ",", Separa )
	
	If( !Empty( StrIn ) )
		_cInSql := "('"
		For _nCont := 1 To Len( AllTrim( StrIn ) )
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
	Else
		_cInSql := "('')"
	EndIf

Return( _cInSql )
