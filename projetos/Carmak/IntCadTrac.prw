#Include "TOTVS.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} UsrTrac
Consumo de API Tranction Usuarios
@version 1.0 
@author Tiengo Junior
@since 21/08/2025
@type function
SRA->RA_XIDTRAC -> Receber o ID do retorno 
Quando realizado uma alteração onde o usuario foi bloqueado ou demitido
ele bloqueia no Trac, mas, não é possível depois desfazer o bloqueio. 
Quando faz pelo DEL, consegue desfazer.
/*/

User Function UsrTrac()

	Local aHeader		:= {}																					as array
	Local oRest			:= Nil																					as Object
	Local oResponse     := Nil																					as Object
	Local cUrl          := SuperGetMV("CK_URLTRAC",.F.,"https://integrations-service.tractian.com/tractian")	as Character
	Local cEnvCarg      := SuperGetMV("CK_ENVCARG",.F.,"")														as Character
	Local oJson         := JsonObject():New()                                                                   as Object
	Local oJsonRet      := JsonObject():New()	                                                                as Object
	Local lRet          := .T.                                                                                  as Logical
	Local cIDTrac       := ""                                                                                   as Character
	Local cToken        := ""                                                                                   as Character
	Local cJson         := ""                                                                                   as Character
	Local nCustoFun	    := 0                                                                                    as Numeric

	//Só irá enviar se estiver na lista de cargo e o campo email estiver preenchido
	If SRA->RA_CARGO $ cEnvCarg .and. ! Empty(SRA->RA_EMAIL)

		nCustoFun := SRA->RA_SALARIO * 1.8 / 220

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
	Endif

Return(lRet)

/*/{Protheus.doc} AtivoTrac
Consumo de API Tranction Ativo
@version 1.0 
@author Tiengo Junior
@since 21/08/2025
@type function
/*/

User Function AtivoTrac()

	Local aHeader		:= {}																					as array
	Local oRest			:= Nil																					as Object
	Local oResponse     := Nil																					as Object
	Local cUrl          := ""	                                                                                as Character
	Local oJson         := JsonObject():New()                                                                   as Object
	Local oJsonRet      := JsonObject():New()	                                                                as Object
	Local lRet          := .T.                                                                                  as Logical
	Local cIDTrac       := ""                                                                                   as Character
	Local cToken        := ""                                                                                   as Character
	Local cJson         := ""                                                                                   as Character

	cToken              := "external-eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJleHRlcm5hbCIsImlzcyI6Imh"+;
		"0dHBzOi8vdHJhY3RpYW4uY29tIiwiaWF0IjoxNzU1MTIyNzc1LCJleHAiOjIwNzA0ODI3NzUsI"+;
		"mNvbXBhbnlJZHMiOlsiNjg1ZDk1MGY1ZDQ3ZDgwODY5OWJmZTQzIiwiZmYyYmEwMDBhNTYxY2V"+;
		"hNmJhYjA4OGJjIl0sImN1c3RvbUNsYWltcyI6eyJhbGxvd2VkUGF0aHMiOlt7InBhdHRlcm4iO"+;
		"iJeL3RyYWN0aWFuLy4qJCIsIm1ldGhvZHMiOlsiR0VUIiwiUE9TVCIsIlBBVENIIiwiUFVUIiw"+;
		"iREVMRVRFIl19XSwicm9sZXMiOlsidXNlciJdfX0.uHuL4OC3gcKlY3J8bq_JSL1AaG7lkZr-M"+;
		"BC3aRcXZILOotD60tz7WRPduiIs-ErQPyv3AkVi1VoakfLERgT1qg"

	//RPCSetEnv("99" , "01",,,"GPE",,,,,,)

	cUrl          := SuperGetMV("CK_URLTRAC",.F.,"https://integrations-service.tractian.com/tractian")

	//Adiciona o header com a autenticacao
	aAdd( aHeader, 'Content-Type: application/json' )
	aAdd( aHeader, "Accept: application/json" )
	Aadd( aHeader, "Authorization: Bearer "+ cToken )

	oJson['name']			        := Alltrim(ST9->T9_NOME)
	oJson["companyId"]              := "ff2ba000a561cea6bab088bc" 	//base testes
	oJson['locationId']             := Alltrim(Posicione("SA1",1,FWxFilial("SA1")+ST9->T9_CLIENTE + ST9->T9_LOJA,"A1_XIDTRAC"))
	oJson['manufacturer']			:= Alltrim(Posicione("SB1",1,FWxFilial("SB1")+ST9->T9_CODESTO,"B1_FABRIC"))
	oJson['code']			        := Alltrim(ST9->T9_CODBEM)
	oJson['year']			        := Val(ST9->T9_XANO)
	oJson['serialNumber']			:= Alltrim(ST9->T9_SERIE)
	oJson['Nº Frota ']			    := ST9->T9_XNFROTA
	oJson['codProd']			    := ST9->T9_CODESTO
	oJson['Capacidade']			    := ST9->T9_XCAPACI
	oJson['Combustível']			:= ST9->T9_XCOMBUS
	oJson['Altura da Torre']		:= ST9->T9_XALTTOR
	oJson['Pé-direito']			    := ST9->T9_XPEDIRE
	oJson['weight']			    	:= ST9->T9_XPESO

	cJson 	:= oJson:toJson()
	oRest   := FWRest():New(cUrl)

	//Caso não tenha ID, eu devo realizar um POST para criar o usuário no TracOS
	If Empty(SRA->RA_XIDTRAC)
		oRest:SetPath( "/assets" )
		oRest:SetPostParams(cJson)

		If oResponse := oRest:post(aHeader)

			//converte o retorno para Json para manipulação
			oJsonRet:FromJson(oRest:cResult)

			cIDTrac := oJsonRet['id']

			RecLock("ST9", .F.)
			ST9->T9_XIDTRAC    := cIDTrac
			ST9->(MsUnlock())
		Else
			cMsgErro := oRest:GetLastError() + ' ' + oRest:cResult
			lRet := .F.
		Endif
	Else
		oRest:SetPath( "/assets/"+Alltrim(ST9->T9_XIDTRAC))
		If oResponse := oRest:put(aHeader,cJson)
			ConOut('PUT realizado com sucesso')
		Else
			cMsgErro := oRest:GetLastError() + oRest:cResult
			lRet := .F.
		Endif
	Endif

Return(lRet)

/*/{Protheus.doc} LocalTrac
Consumo de API Tranction LocalTrac - Clientes
@version 1.0 
@author Tiengo Junior
@since 21/08/2025
@type function
/*/

User Function LocalTrac()

	Local aHeader		:= {}																					as array
	Local oRest			:= Nil																					as Object
	Local oResponse     := Nil																					as Object
	Local cUrl          := ""	                                                                                as Character
	Local oJson         := JsonObject():New()                                                                   as Object
	Local oJsonRet      := JsonObject():New()	                                                                as Object
	Local lRet          := .T.                                                                                  as Logical
	Local cIDTrac       := ""                                                                                   as Character
	Local cToken        := ""                                                                                   as Character
	Local cJson         := ""                                                                                   as Character
	Local cNome         := ""                                                                                   as Character

	cToken              := "external-eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJleHRlcm5hbCIsImlzcyI6Imh"+;
		"0dHBzOi8vdHJhY3RpYW4uY29tIiwiaWF0IjoxNzU1MTIyNzc1LCJleHAiOjIwNzA0ODI3NzUsI"+;
		"mNvbXBhbnlJZHMiOlsiNjg1ZDk1MGY1ZDQ3ZDgwODY5OWJmZTQzIiwiZmYyYmEwMDBhNTYxY2V"+;
		"hNmJhYjA4OGJjIl0sImN1c3RvbUNsYWltcyI6eyJhbGxvd2VkUGF0aHMiOlt7InBhdHRlcm4iO"+;
		"iJeL3RyYWN0aWFuLy4qJCIsIm1ldGhvZHMiOlsiR0VUIiwiUE9TVCIsIlBBVENIIiwiUFVUIiw"+;
		"iREVMRVRFIl19XSwicm9sZXMiOlsidXNlciJdfX0.uHuL4OC3gcKlY3J8bq_JSL1AaG7lkZr-M"+;
		"BC3aRcXZILOotD60tz7WRPduiIs-ErQPyv3AkVi1VoakfLERgT1qg"
		
	cUrl          := SuperGetMV("CK_URLTRAC",.F.,"https://integrations-service.tractian.com/tractian")

	//Adiciona o header com a autenticacao
	aAdd( aHeader, 'Content-Type: application/json' )
	aAdd( aHeader, "Accept: application/json" )
	Aadd( aHeader, "Authorization: Bearer "+ cToken )

	cNome := Alltrim(Posicione("SA1",1,FWxFilial("SA1")+ST9->T9_CLIENTE + ST9->T9_LOJA,"A1_NOME"))

	oJson['name']			        := Alltrim(ST9->T9_CLIENTE + ' ' + ST9->T9_LOJA + '-' + cNome)
	oJson['companyId']              := "ff2ba000a561cea6bab088bc" 	//base testes
	oJson['parentId']               := Alltrim(Posicione("SA1",1,FWxFilial("SA1")+ST9->T9_CLIENTE + ST9->T9_LOJA,"A1_XIDTRAC"))
	oJSon["deleted"]                := JsonObject():New()
	oJSon["deleted"]["value"]       := Iif(SRA->RA_MSBLQL == '1', .T., .F.)

	cJson 	:= oJson:toJson()
	oRest   := FWRest():New(cUrl)

	//Caso não tenha ID, eu devo realizar um POST para criar o usuário no TracOS
	If Empty(SA1->A1_XIDTRAC)
		oRest:SetPath( "/locations" )
		oRest:SetPostParams(cJson)

		If oResponse := oRest:post(aHeader)

			//converte o retorno para Json para manipulação
			oJsonRet:FromJson(oRest:cResult)

			cIDTrac := oJsonRet['id']

			RecLock("SA1", .F.)
			SA1->A1_XIDTRAC    := cIDTrac
			SA1->(MsUnlock())
		Else
			cMsgErro := oRest:GetLastError() + ' ' + oRest:cResult
			lRet := .F.
		Endif
	Else
		oRest:SetPath( "/locations/"+Alltrim(SA1->A1_XIDTRAC))
		If oResponse := oRest:put(aHeader,cJson)
			ConOut('PUT realizado com sucesso')
		Else
			cMsgErro := oRest:GetLastError() + oRest:cResult
			lRet := .F.
		Endif
	Endif

Return(lRet)
