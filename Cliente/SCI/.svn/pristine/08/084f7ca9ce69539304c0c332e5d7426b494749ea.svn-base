#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://200.215.222.79/society-ws-totvs/society-ws-139-totvs.WSDL
Gerado em        01/20/15 11:44:41
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function SCIM004 ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSsociety-ws-139-totvs
------------------------------------------------------------------------------- */

WSCLIENT WSsociety_ws_139_totvs

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ConsultaMovimentoRealizado
	WSMETHOD ConsultaStatusWs
	WSMETHOD VersaoBiblioteca

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   ctcTokenParceiro          AS string
	WSDATA   cttDataInicial            AS dateTime
	WSDATA   cttDataFinal              AS dateTime
	WSDATA   ltlBuscarJaImportados     AS boolean
	WSDATA   cResult                   AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSsociety_ws_139_totvs
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20140829] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSsociety_ws_139_totvs
Return

WSMETHOD RESET WSCLIENT WSsociety_ws_139_totvs
	::ctcTokenParceiro   := NIL 
	::cttDataInicial     := NIL 
	::cttDataFinal       := NIL 
	::ltlBuscarJaImportados := NIL 
	::cResult            := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSsociety_ws_139_totvs
Local oClone := WSsociety_ws_139_totvs():New()
	oClone:_URL          := ::_URL 
	oClone:ctcTokenParceiro := ::ctcTokenParceiro
	oClone:cttDataInicial := ::cttDataInicial
	oClone:cttDataFinal  := ::cttDataFinal
	oClone:ltlBuscarJaImportados := ::ltlBuscarJaImportados
	oClone:cResult       := ::cResult
Return oClone

// WSDL Method ConsultaMovimentoRealizado of Service WSsociety_ws_139_totvs

WSMETHOD ConsultaMovimentoRealizado WSSEND ctcTokenParceiro,cttDataInicial,cttDataFinal,ltlBuscarJaImportados WSRECEIVE cResult WSCLIENT WSsociety_ws_139_totvs
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:ConsultaMovimentoRealizado xmlns:q1="http://tempuri.org/society-ws-139-totvs/message/">'
cSoap += WSSoapValue("tcTokenParceiro", ::ctcTokenParceiro, ctcTokenParceiro , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("ttDataInicial", ::cttDataInicial, cttDataInicial , "dateTime", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("ttDataFinal", ::cttDataFinal, cttDataFinal , "dateTime", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("tlBuscarJaImportados", ::ltlBuscarJaImportados, ltlBuscarJaImportados , "boolean", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:ConsultaMovimentoRealizado>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/society-ws-139-totvs/action/SocietyWSTotvs.ConsultaMovimentoRealizado",; 
	"RPCX","http://tempuri.org/society-ws-139-totvs/wsdl/",,,; 
	"http://200.215.222.79/society-ws-totvs/society-ws-139-totvs.WSDL")

::Init()
::cResult            :=  WSAdvValue( oXmlRet,"_RESULT","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaStatusWs of Service WSsociety_ws_139_totvs

WSMETHOD ConsultaStatusWs WSSEND NULLPARAM WSRECEIVE oWSResult WSCLIENT WSsociety_ws_139_totvs
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:ConsultaStatusWs xmlns:q1="http://tempuri.org/society-ws-139-totvs/message/">'
cSoap += "</q1:ConsultaStatusWs>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/society-ws-139-totvs/action/SocietyWSTotvs.ConsultaStatusWs",; 
	"RPCX","http://tempuri.org/society-ws-139-totvs/wsdl/",,,; 
	"http://200.215.222.79/society-ws-totvs/society-ws-139-totvs.WSDL")

::Init()
::oWSResult          :=  WSAdvValue( oXmlRet,"_RESULT","anyType",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method VersaoBiblioteca of Service WSsociety_ws_139_totvs

WSMETHOD VersaoBiblioteca WSSEND NULLPARAM WSRECEIVE oWSResult WSCLIENT WSsociety_ws_139_totvs
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:VersaoBiblioteca xmlns:q1="http://tempuri.org/society-ws-139-totvs/message/">'
cSoap += "</q1:VersaoBiblioteca>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/society-ws-139-totvs/action/SocietyWSTotvs.VersaoBiblioteca",; 
	"RPCX","http://tempuri.org/society-ws-139-totvs/wsdl/",,,; 
	"http://200.215.222.79/society-ws-totvs/society-ws-139-totvs.WSDL")

::Init()
::oWSResult          :=  WSAdvValue( oXmlRet,"_RESULT","anyType",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



