#include "protheus.ch"
#include "apwebsrv.ch"
#include "topconn.ch"

/*/{Protheus.doc} RetSPMToken
Retorna o token para acesso a API SPM GAP-29
@type function
@version  V 1.0
@author Marcio Martins  Pereira
@since 8/20/2024
@return character, Token gerado
/*/

User Function RetSPMToken()

    Local cRetorno        := ""
    Local cUrl            := SuperGetMV("UB_URLSPM",.F.,"https://appdmz-dev.unimedcampinas.com.br/gesfinspmapi")
    Local oRest           := Nil
    Local oJson           := JsonObject():New()
    Local aHeader         := {}
    Local oRequest        := JsonObject():New()										

    oRest := FWRest():New(cUrl)

    oRest:SetPath("/autenticacao/v1/gerartoken")

	aAdd(aHeader, "Accept: application/json")
	aAdd(aHeader, "Content-Type: application/json; charset=UTF-8")

    //Monta o JSON de autenticação
	oRequest["clientID"]        := SuperGetMV( "UB_CIDSPM",.F., "TOTVS-PROTHEUS" )
	oRequest["clientSecret"]    := SuperGetMV( "UB_SIDSPM",.F., "5f73375c-ae3f-4e53-ae7d-20708def4859" )

	//Converte o JSON para string em formato Json
	oBody := EncodeUtf8(oRequest:ToJson())

    oRest:SetPostParams(oBody)
    oRest:Post(aHeader)

    If oRest:oResponseh:cReason == "Created"
        oJson:FromJson(oRest:cResult)
        cRetorno := oJson['resultado']['token']
    Endif 

Return(cRetorno)
