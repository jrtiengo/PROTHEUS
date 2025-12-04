//Função para enviar em massa os cadastros
User Function IntUsrJob()

	Local cQuery		:= ""       as Character
	Local cAlias        := ""       as Character

	RPCSetEnv("03" , "0101",,,"GPE",,,,,,)

	//Query para trazer os tecnicos pela SRA para enviar ao TracOS
	cQuery := " SELECT  SRA.RA_NOME, 												"
	cQuery += "			SRA.RA_EMAIL, 												"
	cQuery += "			SRA.R_E_C_N_O_												"
	cQuery += "	FROM "+ RetSqlName("SRA") +" SRA                                    "
	cQuery += "	WHERE SRA.D_E_L_E_T_ = ''                                           "
	cQuery += "	  AND SRA.RA_FILIAL = '0101'              							"
	cQuery += "   AND SRA.RA_SITFOLH IN (' ', 'A', 'F')                          	"
	cQuery += "	  AND SRA.RA_MSBLQL <> '1'                                          "
	cQuery += "   AND SRA.RA_XIDTRAC = '' <>										"

	cQuery := ChangeQuery(cQuery)
	cAlias := MPSysOpenQuery(cQuery)

	If (cAlias)->(EoF())
		ConOut('Nenhum registro encontrado na consulta')
		Return()
	EndIf

	While ! (cAlias)->(EoF())

		SRA->(DbGoTo((cAlias)->R_E_C_N_O_))

		U_IntUsr()

		(cAlias)->(dbSkip())
	EndDo

	RpcClearEnv()

Return()

//Função para enviar em massa os cadastros
User Function IntAtvJob()

	Local cQuery		:= ""       as Character
	Local cAlias        := ""       as Character

	RPCSetEnv("03" , "0101",,,"GPE",,,,,,)

	//Query para trazer os tecnicos pela ST9 para enviar ao TracOS
	cQuery := " SELECT  ST9.CODBEM, 												"
	cQuery += "			ST9.R_E_C_N_O_												"
	cQuery += "	FROM "+ RetSqlName("ST9") +" ST9                                    "
	cQuery += "	WHERE ST9.D_E_L_E_T_ = ''                                           "

	cQuery := ChangeQuery(cQuery)
	cAlias := MPSysOpenQuery(cQuery)

	If (cAlias)->(EoF())
		ConOut('Nenhum registro encontrado na consulta')
		Return()
	EndIf

	While ! (cAlias)->(EoF())

		ST9->(DbGoTo((cAlias)->R_E_C_N_O_))

		U_IntUsr()

		(cAlias)->(dbSkip())
	EndDo

	RpcClearEnv()

Return()

//Função para enviar em massa os cadastros
User Function IntCliJob()

	Local cQuery		:= ""       as Character
	Local cAlias        := ""       as Character

	RPCSetEnv("03" , "0101",,,"GPE",,,,,,)

	//Query para trazer os locais pela SA1 para enviar ao TracOS
	cQuery := " SELECT  SA1.A1_COD, 												"
	cQuery += "			SA1.A1_LOJA, 												"
	cQuery += "			SA1.R_E_C_N_O_												"
	cQuery += "	FROM "+ RetSqlName("SA1") +" SA1                                    "
	cQuery += "	WHERE SA1.D_E_L_E_T_ = ''                                           "
	cQuery += "	  AND SRA.RA_MSBLQL <> '1'                                          "

	cQuery := ChangeQuery(cQuery)
	cAlias := MPSysOpenQuery(cQuery)

	If (cAlias)->(EoF())
		ConOut('Nenhum registro encontrado na consulta')
		Return()
	EndIf

	While ! (cAlias)->(EoF())

		SA1->(DbGoTo((cAlias)->R_E_C_N_O_))

		U_IntUsr()

		(cAlias)->(dbSkip())
	EndDo

	RpcClearEnv()

Return()

User Function IntSaldos()

	Local cQuery		:= ""       as Character
	Local cAlias        := ""       as Character

	RPCSetEnv("03" , "0101",,,"GPE",,,,,,)

	cQuery := " SELECT *
	cQuery += "FROM SB2990 SB2
	cQuery += "INNER JOIN SB1990 SB1 ON SB1.B1_COD = SB2.B2_COD AND SB1.D_E_L_E_T_ = ''
	cQuery += "WHERE SB2.D_E_L_E_T_ = ''

	cQuery := ChangeQuery(cQuery)
	cAlias := MPSysOpenQuery(cQuery)

	If (cAlias)->(EoF())
		ConOut('Nenhum registro encontrado na consulta')
		Return()
	EndIf

	While ! (cAlias)->(EoF())

		SB2->(DbGoTo((cAlias)->R_E_C_N_O_))

		fEnviasaldos()

		(cAlias)->(dbSkip())
	EndDo

	RpcClearEnv()

Return()

Static Function fEnviasaldos()

	Local aHeader		:= {}																					as array
	Local oRest			:= Nil																					as Object
	Local oResponse     := Nil																					as Object
	Local cUrl          := SuperGetMV("CK_URLTRAC",.F.,"https://integrations-service.tractian.com/tractian")	as Character
	Local oJson         := JsonObject():New()                                                                   as Object
	Local oJsonRet      := JsonObject():New()	                                                                as Object
	Local lRet          := .T.                                                                                  as Logical
	Local cIDTrac       := ""                                                                                   as Character
	Local cToken        := ""                                                                                   as Character
	Local cJson         := ""                                                                                   as Character
	Local nCustoFun	    := 0                                                                                    as Numeric

	cToken              := "external-eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJleHRlcm5hbCIsImlzcyI6Imh"+;
		"0dHBzOi8vdHJhY3RpYW4uY29tIiwiaWF0IjoxNzU1MTIyNzc1LCJleHAiOjIwNzA0ODI3NzUsI"+;
		"mNvbXBhbnlJZHMiOlsiNjg1ZDk1MGY1ZDQ3ZDgwODY5OWJmZTQzIiwiZmYyYmEwMDBhNTYxY2V"+;
		"hNmJhYjA4OGJjIl0sImN1c3RvbUNsYWltcyI6eyJhbGxvd2VkUGF0aHMiOlt7InBhdHRlcm4iO"+;
		"iJeL3RyYWN0aWFuLy4qJCIsIm1ldGhvZHMiOlsiR0VUIiwiUE9TVCIsIlBBVENIIiwiUFVUIiw"+;
		"iREVMRVRFIl19XSwicm9sZXMiOlsidXNlciJdfX0.uHuL4OC3gcKlY3J8bq_JSL1AaG7lkZr-M"+;
		"BC3aRcXZILOotD60tz7WRPduiIs-ErQPyv3AkVi1VoakfLERgT1qg"

	//Adiciona o header com a autenticacao
	aAdd( aHeader, 'Content-Type: application/json' )
	aAdd( aHeader, "Accept: application/json" )
	Aadd( aHeader, "Authorization: Bearer "+ cToken )

	oJson['name']			        := Alltrim(SRA->RA_MAT + ' ' + '-' + ' ' + 	SRA->RA_NOME)
	oJson['email']			        := Alltrim(SRA->RA_EMAIL)
	oJson['phone']              	:= Alltrim('+55' + SRA->RA_DDDFONE + StrTran(SRA->RA_TELEFON, "-", " "))
	oJson['profileId']              := "689cf6ffa100173842043933" //Acessos será fixo
	oJson["companyId"]              := "ff2ba000a561cea6bab088bc" //base testes
	oJson['language']	            := "pt-BR"
	oJson['hourlyRate']             := nCustoFun //Taxa horária do usuário para cálculos de custos e controle de tempo
	oJSon["deleted"]                := JsonObject():New()
	oJSon["deleted"]["value"]       := Iif(SRA->RA_SITFOLH == 'D' .or. SRA->RA_MSBLQL == '1', .T., .F.)

	cJson 	:= oJson:toJson()
	oRest   := FWRest():New(cUrl)

	//Caso não tenha ID, eu devo realizar um POST para criar o usuário no TracOS
	If Empty(SRA->RA_XIDTRAC)
		oRest:SetPath( "/users" )
		oRest:SetPostParams(cJson)

		If oResponse := oRest:post(aHeader)

			ConOut('POST realizado com sucesso')
			//converte o retorno para Json para manipulação
			oJsonRet:FromJson(oRest:cResult)

			cIDTrac := oJsonRet['id']

			RecLock("SRA", .F.)
			SRA->RA_XIDTRAC    := cIDTrac
			SRA->(MsUnlock())
		Else
			cMsgErro := oRest:GetLastError() + ' ' + oRest:cResult
			lRet := .F.
		Endif
	Else
		oRest:SetPath( "/users/"+Alltrim(SRA->RA_XIDTRAC))
		If oResponse := oRest:put(aHeader,cJson)
			ConOut('PUT realizado com sucesso')
		Else
			cMsgErro := oRest:GetLastError() + oRest:cResult
			lRet := .F.
		Endif
	Endif

Return()

User Function ustamp()

	//Local nI, cConfig, aConfig

	//Cria uma nova conexão com um banco (SGBD) através do DBAccess
	TCLink()

	//Habilita o Dbaccess e acrescentar o campo STAMP nas novas tabelas
	TCConfig('SETUSEROWSTAMP=ON')

	// Habilita criar o campo para tabelas já existentes (Para usar esse segundo comando ( AUTOSTAMP ) , você deve primeiro habilitar o primeiro (USEROWSTAMP)
	TCCONfig("SETAUTOSTAMP=ON")

	// Faz o Dbaccess acrescentar a coluna sem precisar recriar a tabela
	TCRefresh("SB2990")

	//Após execução desligar as chaves para não criar em outras tabelas do sistema desnecessárias
	TCCONfig("SETUSEROWSTAMP=OFF")
	TCCONfig("SETAUTOSTAMP=OFF")

	//Encerra a conexão especificada com o DBAccess
	TCUnlink()

Return
