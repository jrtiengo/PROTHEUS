#Include "PROTHEUS.CH"
#Include "Totvs.ch"
#Include "Topconn.ch"
#Include "rwmake.ch"


/*/{Protheus.doc} fBuscaCep
Valida CEP
@version 1.0 
@author Luiz Neves / Celso Rene
@since 19/01/2023
@type function
@param _cCep, variant, string
@param _aRetCep, variant, array
@return variant, lRet boolean
/*/
User Function fBuscaCep( _cCep, _aRetCep) 
	Local cCEP       := _cCep
	Local cJsonCEP
	Local oJsonObj
	Local aJsonFields := {}
	Local nRetParser  := 0
	Local oJHashMap
	Local lOk
	Local cCEPEnder   := ''
	Local cCEPBairro  := ''
	Local cCepCidade  := ''
	Local cCEPUF      := ''
	Local cIBGE      := ''
	Local lCEPERRO    := .F.
	Local nCode
	Local cMsg        := ''
	Local cUrl        := 'http://viacep.com.br/ws/' + _cCep + '/json/'
	Local lRet        := .T.
	default _aRetCep  := {}

	IF len(_cCEp) < 8
		MsgStop("Digite o número do CEP completo para a busca.","CEP Inválido ou incompleto")
		Return( .F. )
	Endif

	cJsonCEP := httpget(cUrl)

	If Empty(cJsonCEP) .or. ("erro" $ Alltrim(cJsonCEP) .and. "true" $ Alltrim(cJsonCEP))   
		nCode := HTTPGETSTATUS(@cMsg)
		MsgStop(cMsg+" ( HTTP STATUS = " + cValToChar(nCode) +" )","Falha na Busca de CEP")
		lRet := .F.
	Else
		oJsonObj := tJsonParser():New()
		lOk := oJsonObj:Json_Hash(cJsonCEP, len(cJsonCEP), @aJsonfields, @nRetParser, @oJHashMap)
		If ( !Lok )
			MsgStop(cJsonCEP,"Falha ao identificar CEP",cCEP)
			lRet := .F.
		Else
			// Obtem o valor dos campos usando o Hashmap gerado
			HMGet(oJHashMap, "erro", @lCEPERRO)
			If cValtochar(lCEPERRO) = ".T." .or. cValtochar(lCEPERRO) == "true" //tratamento retorno
				MsgStop("CEP Inexistente na Base de Dados","Falha ao buscar CEP " + cCEP)
				lRet := .F.
			Else
				HMGet(oJHashMap, "logradouro", @cCEPEnder)
				HMGet(oJHashMap, "bairro", @cCEPBairro)
				HMGet(oJHashMap, "localidade", @cCepCidade)
				HMGet(oJHashMap, "uf", @cCEPUF)
				HMGet(oJHashMap, "ibge", @cIBGE)
				cCEPEnder  := padr(upper(DecodeUTF8(cCEPEnder)) ,50)
				cCEPBairro := padr(upper(DecodeUTF8(cCEPBairro)),30) ////cCEPEnder  := padr(upper(DecodeUTF8(cCEPEnder,"cp1252")) ,50)
				cCepCidade := padr(upper(DecodeUTF8(cCepCidade)),40)
				cCEPUF     := padr(Upper(DecodeUTF8(cCEPUF)) ,2)
				cIBGE      := right(padr(Upper(DecodeUTF8(cIBGE)) ,7),5)
				
					_cGetRua 	:= cCEPEnder
					_cGetBai	:= cCEPBairro
					_cGetMun	:= cCepCidade
					_cGetEst	:= cCEPUF
					_cGetCMun 	:= cIBGE
				
					_aRetCep  := {cCEPEnder,DecodeUTF8(cCEPBairro,"cp1252"),cIBGE,cCEPCidade,cCepUF}

			Endif
		Endif

		FreeObj(oJsonObj)
		FreeObj(oJHashMap)

	EndIf

Return( lRet )

