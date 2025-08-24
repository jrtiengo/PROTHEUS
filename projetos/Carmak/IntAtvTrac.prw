#Include "TOTVS.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} IntStatusSE1
Consumo de API Tranction Usuarios
@version 1.0 
@author Tiengo Junior
@since 21/08/2025
@type function
/*/

User Function IntAtvTrac()

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

	oJson['name']			        := Alltrim(SRA->RA_MAT + ' ' + '-' + ' ' + 	SRA->RA_NOME)
	oJson['email']			        := Alltrim(SRA->RA_EMAIL)
	//oJson['telefone']              := SRA->RA_TELEFON //Tracnian precisa criar o objeto na API
	oJson['profileId']              := "689cf6ffa100173842043933" //Acessos ser� fixo
	oJson["companyId"]              := "ff2ba000a561cea6bab088bc" //base testes
	oJson['language']	            := "pt-BR"
	oJson['hourlyRate']             := ""  //Taxa hor�ria do usu�rio para c�lculos de custos e controle de tempo
	oJSon["deleted"]                := JsonObject():New()
	oJSon["deleted"]["value"]       := Iif(SRA->RA_SITFOLH == 'D' .or. SRA->RA_MSBLQL == '1', .T., .F.)

	cJson 	:= oJson:toJson()
	oRest   := FWRest():New(cUrl)

	//Caso n�o tenha ID, eu devo realizar um POST para criar o usu�rio no TracOS
	If Empty(SRA->RA_XIDTRAC)
		oRest:SetPath( "/users" )
		oRest:SetPostParams(cJson)

		If oResponse := oRest:post(aHeader)

			//converte o retorno para Json para manipula��o
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

//RpcClearEnv() //Encerra o ambiente, fechando as devidas conex�es

Return(lRet)

User Function IntAtvJob()

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
