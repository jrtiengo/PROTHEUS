#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
/*
{Protheus.doc} MARA060
Programa que fará a atualização das tabelas na Mercos via WebService
@type User function
@author Jean Rehermann - Solutio
@since 15/11/2021
*/
User Function MARA060()

	Private lBlind   := IsBlind()
	Private bProcInc := {|| Iif( !lBlind, IncProc(), 0 ) }
	Private aLogMerc := {}

	If lBlind
		EnvMercos() // Criar o ambiente de execução
	Else
		ProcRegua(0) // Atualizar a régua de processamento
	EndIf

	Eval( bProcInc )

	// Atualizar os produtos
	ApiProdMerc()

	// Atualizar os clientes
	//ApiCliMerc()

Return

/*
Cria o ambiente para a execução do processo no schedule
*/
Static Function EnvMercos()

	Local cRpcEmp		:= "01"	     // Empresa
	Local cRpcFil		:= "01"	     // Filial Principal
	Local cEnvUser		:= "solutio.jean"
	Local cEnvPass		:= "102030"
	Local cEnvMod		:= "FAT"     // Modulo
	Local cFunName		:= "MARA060" // Funcao
    Local aTables 		:= {"SB1","SA1"}


	RpcSetEnv( cRpcEmp , cRpcFil , cEnvUser, cEnvPass, cEnvMod, cFunName , aTables, , , ,  )

Return Nil

/*
Efetua a atualização dos produtos no site da Mercos
*/
Static Function ApiProdMerc()

	Local cSql      := ""
	Local aRet      := ""
	Local cJson     := ""
	Local nPos      := 0
	Local cAliasSB1 := GetNextAlias()

	// https://mercos.docs.apiary.io/#reference/0/produtos/incluir-um-produto?console=1

	cSql := "SELECT TOP 1 DA1_PRCVEN, B1_COD, B1_DESC, B1_IDMERCO, SB1.R_E_C_N_O_ RECNO "
	cSql += " FROM "+ RetSqlName("DA1") +" DA1, "+ RetSqlName("SB1") +" SB1 "
	cSql += " WHERE DA1_CODPRO = B1_COD "
	cSql += " AND DA1_CODTAB = '504' "
	cSql += " AND B1_DTMERCO = ' ' "
	cSql += " AND DA1.D_E_L_E_T_ = ' ' "
	cSql += " AND SB1.D_E_L_E_T_ = ' ' "

	dbUseArea( .T., "TOPCONN", TCGenQry( NIL, NIL, cSql ), cAliasSB1, .F., .T. )

	While !(cAliasSB1)->( Eof() )

		cJson := '{'
		cJson += '"codigo": "'+ AllTrim( (cAliasSB1)->B1_COD ) +'",'
		cJson += '"nome": "'+ AllTrim( FwNoAccent( (cAliasSB1)->B1_DESC ) ) +'",'
		cJson += '"preco_tabela": '+ cValToChar( (cAliasSB1)->DA1_PRCVEN )
		cJson += '}'

		aRet := U_SndJSON( "POST", "/api/v1/produtos", cJson )
		Sleep(500)

		If aRet[ 1 ] == "201" .And. Len( aRet[ 2 ] ) > 0

			nPos := aScan( aRet[2], {|o| Upper( o[ 1 ] ) == "MEUSPEDIDOSID"} )

			If nPos > 0

				SB1->( dbGoTo( (cAliasSB1)->RECNO ) )
				SB1->( RecLock("SB1", .F.) )
				SB1->B1_IDMERCO := aRet[2, nPos, 2 ]
				SB1->B1_DTMERCO := cValToChar( Year( Date ) ) +'-'+ StrZero( Month( Date ), 2 ) +'-'+ StrZero( Day( Date ), 2 ) +' '+ Time()
				SB1->( MsUnLock() )

			EndIf

		EndIf

		(cAliasSB1)->( dbSkip() )

	End

	(cAliasSB1)->( dbCloseArea() )

Return

/*
Efetua a atualização dos clientes no site da Mercos
*/
Static Function ApiCliMerc()

	Local cSql      := ""
	Local aRet      := {}
	Local nPosId    := 0
	Local nIdReg    := 0
	Local cAliasSA1 := GetNextAlias()

	cSql := "SELECT * FROM "+ RetSqlName("SA1")
	cSql += " WHERE D_E_L_E_T_ = ' ' "
	cSql += "   AND A1_DTMERCO = ' ' "

	dbUseArea( .T., "TOPCONN", TCGenQry( NIL, NIL, cSql ), cAliasSA1, .F., .T. )

	While !(cAliasSA1)->( Eof() )

		// Obtem a estrutura do endereço [ RUA, nNUMERO, cNUMERO, COMPLEMENTO ]
		aEndStr := FisGetEnd( (cAliasSA1)->A1_END, (cAliasSA1)->A1_EST )

		cJson := '{'
		cJson += '"razao_social": "'+  AllTrim( (cAliasSA1)->A1_NOME ) +'",'
		cJson += '"nome_fantasia": "'+ AllTrim( (cAliasSA1)->A1_NREDUZ ) +'",'
		cJson += '"tipo": "'+          (cAliasSA1)->A1_PESSOA +'",'
		cJson += '"cnpj": "'+          (cAliasSA1)->A1_CGC +'",'

		If !Empty( (cAliasSA1)->A1_INSCR )
			cJson += '"inscricao_estadual": "'+ AllTrim( (cAliasSA1)->A1_INSCR ) +'",'
		EndIf

		cJson += '"rua": "'+ AllTrim( aEndStr[ 1 ] ) +'",'
		cJson += '"numero": "'+ Iif( !Empty( aEndStr[ 3 ]), AllTrim( aEndStr[ 3 ] ), "SN" ) +'",'

		If !Empty( aEndStr[ 4 ] )
			cJson += '"complemento": "'+ AllTrim( aEndStr[ 4 ] ) +'",'
		EndIf

		cJson += '"cep": "'+    (cAliasSA1)->A1_CEP +'",'
		cJson += '"bairro": "'+ AllTrim( (cAliasSA1)->A1_BAIRRO ) +'",'
		cJson += '"cidade": "'+ AllTrim( (cAliasSA1)->A1_MUN ) +'",'
		cJson += '"estado": "'+ (cAliasSA1)->A1_EST +'",'

		If !Empty( (cAliasSA1)->A1_EMAIL )
			cJson += '"emails": "[{"email": "'+ (cAliasSA1)->A1_EMAIL +'"}]",'
		EndIf

		If !Empty( (cAliasSA1)->A1_TEL )
			cJson += '"telefones": ['
			cJson += '{"numero": "('+ AllTrim((cAliasSA1)->A1_DDD) +')'+ AllTrim((cAliasSA1)->A1_TEL) +'"}'
			If !Empty( (cAliasSA1)->A1_FAX )
				cJson += ','
				cJson += '{"numero": "('+ AllTrim((cAliasSA1)->A1_DDD) +')'+ AllTrim((cAliasSA1)->A1_FAX) +'"}'
			EndIf
			cJson += '],'
		EndIf
		cJson += '"excluido": false'
		cJson += '}'

		aRet := U_SndJSON( "POST", "/api/v1/clientes", cJson )

		If Len( aResult ) > 0
			nPosId := aScan( aResult, {|o| o[1] == "MeusPedidosID" } )
			nIdReg := Iif( nPosId > 0, aResult[ nPosId, 2 ], 0 )
		EndIf


		(cAliasSA1)->( dbSkip() )

	End

	(cAliasSA1)->( dbCloseArea() )

Return

/*
Faz o envio do Json para o webservice e resebe o retorno
*/
User Function SndJSON( cMetodo, cUri, cJson )

	Local oResult
	Local lOk       := .T.
	Local cResult   := ""
	Local cHttpCode := ""
	Local cJsonTxt  := ""
	Local cMsgErr   := "Integração Mercos / Marcher - "
	Local aHeader   := {}
	Local aResult   := {}
	Local cUrl      := SuperGetMv("ES_MURLAPI", .F., "") // URL da API da Mercos para WebServices
	Local cTokenApp := SuperGetMv("ES_MAPPTOK", .F., "") // ApplicationToken – Em Base64
	Local cTokenCpn := SuperGetMv("ES_MCPNTOK", .F., "") // CompanyToken – Em Base64

	Private oRest
	Private oJson

	DEFAULT cMetodo := ""
	DEFAULT cUri    := ""
	DEFAULT cJson   := ""

	// Validações dos parâmetros
	If Empty( cUrl )
		cMsgErr += "URL não informada, parâmetro ES_MURLAPI"
		lOk := .F.
	EndIf

	If lOk .And. Empty( cJson )
		cMsgErr += "JSON não passado para a função"
		lOk := .F.
	EndIf

	If lOk .And. Empty( cMetodo )
		cMsgErr += "Método da requisição não passado para a função (PUT/POST/GET)"
		lOk := .F.
	EndIf

	If lOk .And. Empty( cTokenApp )
		cMsgErr += "ApplicationToken não informado, parâmetro ES_MAPPTOK"
		lOk := .F.
	Else
		// Decodifica o ApplicationToken
		cTokenApp := Decode64( cTokenApp )
	EndIf

	If lOk .And. Empty( cTokenCpn )
		cMsgErr += "CompanyToken não informado, parâmetro ES_MCPNTOK"
		lOk := .F.
	Else
		// Decodifica o CompanyToken
		cTokenCpn := Decode64( cTokenCpn )
	EndIf

	If lOk

		// Cria o objeto Rest que fará a interação com o webservice
		oRest := FWRest():New( cUrl )

		// Cria o objeto Json para receber o texto e validar as sintaxes
		oJson := JsonObject():New()

		// Efetua a validação do Json que foi passado
		cResult := oJson:FromJson( cJson )

		// Verifico erros
		If ValType( cResult ) <> "U"
			cMsgErr += "Erro na validação do Json: "+ cResult
			lOk := .F.
		Else
			// Recupero o JSON validado e formatado
			cJsonTxt := oJson:toJson()
		EndIf

	EndIf

	If lOk

		// Setar o caminho da requisição
		oRest:setPath( cUri )

		// Definir os cabeçalhos
		aAdd( aHeader, "Content-Type:application/json" )
		aAdd( aHeader, "ApplicationToken:"+ cTokenApp )
		aAdd( aHeader, "CompanyToken:"+ cTokenCpn )

		// Definir o método: POST (inclusão), GET (requisição), PUT (alteração)
		If cMetodo == "POST"

			oRest:SetPostParams( cJsonTxt )  // Seto o JSON para o POST
			lOk := oRest:Post( aHeader )     // Executo o POST no serviço
			cHttpCode := oRest:GetHTTPCode() // Verifica o código de retorno da requisição HTTP

			If !lOk
				cMsgErr += "Erro no POST : "+ oRest:getLastError() // Quando dá certo retorna '201 Created'
			Else
				// Obtem o Response da requisição realizada
				oResult := Iif( ValType( oRest:oResponseH ) == "O", oRest:oResponseH, Nil )
				aResult := Iif( oResult != Nil, oRest:oResponseH:aHeaderFields, {} )
				cResult := AllTrim( oRest:getResult() )
			EndIf

		Elseif cMetodo == "GET"

		ElseIf cMetodo == "PUT"

		Else
			cMsgErr := "O método enviado não é suportado: "+ cMetodo
			lOk := .F.
		EndIf

	EndIf

	// Em caso de erro exibe a mensagem, no console ou popup
	If !lOk
		If lBlind
			ConOut( cMsgErr )
		Else
			MsgInfo( cMsgErr, "Integração Mercos / Marcher" )
		EndIf
	Else
		ConOut( cResult )
	EndIf

	FreeObj( oRest )

Return( { cHttpCode, aResult, cResult } )
