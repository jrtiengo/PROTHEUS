#include 'protheus.ch'
#include 'parmtype.ch'
#Include "totvs.ch"
#include 'PRTOPDEF.ch'


//teste Post
User Function tstpost2()

	Local cPostUrl      := "https://tpall2.2wglobal.com:6443/WWLRestService"
	Local nTimeOut      := 200
	Local aHeadOut      := {}
	Local cHeaderRet  	:= ""
	Local sPostRet      := ""
	Local cPostData  	:=""
	Local cMens      	:= 'Message_Identifier=JD&Message_Type=TruckPostion'


	RpcSetEnv("99","01","admin","102030","FIN",  ,{"SM0","SE2","SA2","SED"}) //

	Aadd(aHeadOut,'Accept: */*')
	Aadd(aHeadOut,'Content-Type: application/json')

	//formatado em JSON pelo link https://jsonformatter.curiousconcept.com/
	cPostData := '{'
	cPostData +=  ' "truckLocation":{'
	cPostData +=      '"header":{'
	cPostData +=          '"partner":"JD",'
	cPostData +=          '"carrier":"TRAN",'
	cPostData +=          '"ediControlNo":"267753039",'
	cPostData +=          '"timestamp":"201804170905210"'
	cPostData +=      '},'
	cPostData +=      '"eventDetail":['
	cPostData +=          '{'
	cPostData +=            '"licensePlate":"HKE5865",'
	cPostData +=            '"latitude":"14.143777913430046",'
	cPostData +=            '"longitude":"100.91526948374563",'
	cPostData +=            '"updateDate":"201804170905210"'
	cPostData +=          '}'
	cPostData +=      ']'
	cPostData +=    '}'
	cPostData += '}'

	cPostData := EncodeUTF8(cPostData)

	sPostRet := HttpPost(cPostUrl,cMens,cPostData,nTimeOut,aHeadOut,@cHeaderRet)

	if !empty(sPostRet)
		conout("HttpPost Ok")
		varinfo("WebPage", sPostRet)
	else
		conout("HttpPost Failed.")
		varinfo("Header", cHeaderRet)
	Endif


	RpcClearEnv() //


Return()
