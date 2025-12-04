#Include "TOTVS.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"

#Include "TOTVS.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} UsrTrac
Consumo de API Tranction Saldos de Produtos
@version 1.0 
@author Tiengo Junior
@since 21/08/2025
@type function
SB2->B2_XDTULTE -> Gravar o ultimo envio no formato YYYY-MM-DD HH:MM:SS.MMM
/*/

User Function UsrEnv()

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

Return(lRet)
