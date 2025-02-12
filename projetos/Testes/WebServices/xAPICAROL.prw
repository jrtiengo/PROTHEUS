#include 'protheus.ch'
#include 'PRTOPDEF.ch'
#include 'TOPCONN.CH'
#include 'FWMVCDEF.CH'


/*/{Protheus.doc} xAPICAROL
Api CARLOL TOTVS
@type function
@version 1.0  
@author Celso Rene
@since 18/07/2024
@param _cCGC, variant, sting
@return variant, return array
/*/
User Function xAPICAROL(_cCGC)

	Local aRetJson      := {}
	Local _oRet
	Local oJson
	Local _cNome,_cNomeRed,_cEst,_cCep,_cBairro,_cEnd,_cTipoP,_cCnae,_cPais,_cTel := ""
	Local aTel			:= {}
    Default _cCGC := "03556592000110"


    RpcSetEnv("99","01","admin","102030","FIN",  ,{"SM0"})

	oJson  	 	:= JsonObject():New()
	aRetJson 	:= APIFORCLI(_cCGC)
	oJson:FromJson(aRetJson[2])
	_oRet 		:= oJson:GetJsonObject("hits")

	//verificando se retornou dados a consulta APi Carol
	if  (!ValType(_oRet) == "U" .OR. Len(_oRet) == 0)

		_cNome      := Upper(DecodeUTF8(oJson["hits"][1]["mdmGoldenFieldAndValues"]["mdmname"]))
		_cNomeRed   := Left(Upper(oJson["hits"][1]["mdmGoldenFieldAndValues"]["mdmdba"]),20)
		_cEst       := oJson["hits"][1]["mdmGoldenFieldAndValues"]["mdmaddress"][1]["mdmstate"]
		_cCep       := oJson["hits"][1]["mdmGoldenFieldAndValues"]["mdmaddress"][1]["mdmzipcode"]

		//bairro
		if (VALTYPE(oJson["hits"][1]["mdmGoldenFieldAndValues"]["mdmaddress"][1]["mdmaddress3"]) == "C")
			_cBairro    := Upper(oJson["hits"][1]["mdmGoldenFieldAndValues"]["mdmaddress"][1]["mdmaddress3"])
		endif

		//endereco
		if (VALTYPE(oJson["hits"][1]["mdmGoldenFieldAndValues"]["mdmaddress"][1]["mdmaddress1"]) == "C")
			_cEnd       := Upper(oJson["hits"][1]["mdmGoldenFieldAndValues"]["mdmaddress"][1]["mdmaddress1"])
		endif

		_cCodMun    := Posicione("CC2",4,xFilial("CC2") +  oJson["hits"][1]["mdmGoldenFieldAndValues"]["mdmaddress"][1]["mdmstate"] + Alltrim(Upper(oJson["hits"][1]["mdmGoldenFieldAndValues"]["mdmaddress"][1]["mdmcity"])),"CC2_CODMUN")
		_cTipoP     := Iif(Len(_cCGC) == 11, "F", Iif(Len(_cCGC) == 14, "J", "X"))
		//_cEmail     :=  Lower(oJson["hits"][1]["mdmGoldenFieldAndValues"]["mdmemail"][1]["mdmemailaddress"])
		_cCnae      := oJson["hits"][1]["mdmGoldenFieldAndValues"]["cnaebr"]
		_cPais      :=  "105"

		_cTel := oJson["hits"][1]["mdmGoldenFieldAndValues"]["mdmphone"][2]["mdmphonenumber"]
		if (!Empty(_cTel))
			aTel := RemDddTel(_cTel)
		endif

	endif

    RpcClearEnv()


Return({_cNome,_cNomeRed,_cEst,_cCep,_cBairro,_cEnd,_cTipoP,_cCnae,_cPais,_cTel})
