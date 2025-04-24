#Include 'Protheus.ch'
#Include "FWMVCDEF.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#include "restful.ch"

/*/{Protheus.doc} UNI6998F
@Description 
@Type		 
@Author 	 
@Since  	 27/01/2025
/*/
User Function UNI6998F()
	Local cQuery := ""
	Local cAlias := ""
	rpcSetenv('01','010001')
	cQuery := "SELECT R_E_C_N_O_ FROM ZZP010 "
	CqUERY += "WHERE D_E_L_E_T_ = ' ' "
	cQuery += "AND ZZP_STATUS = '1' "
	cAlias:=Mpsysopenquery(cQuery )
	if select (cAlias) == 0 .or. empty((cAlias)->R_E_C_N_O_)
		if select (cAlias) > 0
			(cAlias)->(dbclosearea())
		endif
		return .f.
	endif

	while ! (cAlias)->(EOF())

		ZZP->(DbGoto((cAlias)->R_E_C_N_O_))
		cFilial := ZZP->ZZP_FILIAL
		if ! u_UNI6998()
			ZZP->ZZP_STATUS := '2'
			ZZP->(DbSkip())
		else
			ZZP->ZZP_STATUS := '3'
			ZZP->(DbSkip())
		endif

		(cAlias)->(DbSkip())
	enddo
	rpcClearEnv()
Return


/*Exemplo de inclusão de contrato com rateios(CNZ)*/
user Function UNI6998()
	Local aErro     := {}
	Local oModel    := Nil
	Local oModelCNB := Nil
	Local oModelCNZ := Nil
	Local oContrato := JsonObject():new()
	Local nAux
	Local lRet := .f.
	Local nAux2
	Local cContrat  := "CONTRATOTESTE"
	oContrato:fromJson(ZZP->ZZP_BODY)

	oModel := FWLoadModel('CNTA300')
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

	//Cabeçalho do Contrato
	oModel:SetValue('CN9MASTER','CN9_NUMERO', cContrat)
	oModel:SetValue('CN9MASTER','CN9_DTINIC', ctod(oContrato['data_inclusao']))
	oModel:SetValue('CN9MASTER','CN9_UNVIGE', oContrato['unidade_vigencia'])
	oModel:SetValue('CN9MASTER','CN9_VIGE',   oContrato['vigencia']     )
	oModel:SetValue('CN9MASTER','CN9_MOEDA',     1)
	oModel:SetValue('CN9MASTER','CN9_TPCTO',     oContrato['tipo_contrato'])
	oModel:SetValue('CN9MASTER','CN9_CONDPG',   oContrato['condicao_pagamento'])
	oModel:SetValue('CN9MASTER','CN9_AUTO'  ,  '1')
	oModel:SetValue('CN9MASTER','CN9_FLGREJ' ,  oContrato['reajuste'])
	oModel:SetValue('CN9MASTER','CN9_FLGCAU'  ,  oContrato['controla_caucao'])
	oModel:SetValue('CN9MASTER','CN9_NATURE'  ,  oContrato['natureza'])
	oModel:SetValue('CN9MASTER','CN9_ASSINA'  , ctod(oContrato['data_assinatura']))
	oModel:SetValue('CN9MASTER','CN9_INDICE'    , oContrato['indice'])
	oModel:SetValue('CN9MASTER','CN9_PERI'    , oContrato['periodicidade'])
	oModel:SetValue('CN9MASTER','CN9_OBJCTO'  , oContrato['objeto'])
	oModel:SetValue('CN9MASTER','CN9_ALTCLA'  , oContrato['clausula'])
	oModel:SetValue('CN9MASTER','CN9_JUSTIF'  , oContrato['justificativa'])


	//Cliente/Fornecedor do Contrato
	oModel:SetValue('CNCDETAIL','CNC_CODIGO', oContrato['fornecedor'])
	oModel:SetValue('CNCDETAIL','CNC_LOJA'  , oContrato['loja']    )

	//Planilhas do Contrato
	oModel:SetValue('CNADETAIL','CNA_NUMERO'    , PadL("1", Len(CNA->CNA_NUMERO),"0"))
	oModel:SetValue('CNADETAIL','CNA_FORNEC'    , oModel:GetValue('CNCDETAIL','CNC_CODIGO'))
	oModel:SetValue('CNADETAIL','CNA_TIPPLA'    , oContrato['tipo_planilha'])
	oModel:SetValue('CNADETAIL','CNA_DTINI'     , ctod(oContrato['data_inclusao']))

	oModelCNB := oModel:GetModel("CNBDETAIL")
	oModelCNZ := oModel:GetModel("CNZDETAIL")

	For nAux :=1 to len (oContrato['produtos'])
		//Primeiro produto
		if nAux > 1
			oModelCNB:AddLine()
		endif
		oModelCNB:SetValue('CNB_ITEM'      , StrZero(nAux, Len(CNB->CNB_ITEM)))
		oModelCNB:SetValue('CNB_PRODUT'    ,oContrato['produtos'][nAux]['produto'])
		oModelCNB:SetValue('CNB_QUANT'     ,oContrato['produtos'][nAux]['quantidade'])
		oModelCNB:SetValue('CNB_VLUNIT'    ,oContrato['produtos'][nAux]['valor_unitario'])
		oModelCNB:SetValue('CNB_CLVL'    ,oContrato['produtos'][nAux] ['classe_valor'])
		oModelCNB:SetValue('CNB_PEDTIT'    ,oContrato['produtos'][nAux]['pedido_titulo'])
		oModelCNB:SetValue('CNB_CC'   ,oContrato['produtos'][nAux]['centro_custo'])

		//Rateio do primeiro item
		for nAux2 :=1 to len (oContrato['produtos'][nAux]['rateios'])
			if nAux2 > 1
				oModelCNZ:AddLine()
			endif
			oModelCNZ:SetValue('CNZ_ITEM'   ,StrZero(nAux2, Len(CNZ->CNZ_ITEM)))
			oModelCNZ:SetValue('CNZ_PERC'   ,oContrato['produtos'][nAux]['rateios'][nAux2]['percentual'])
			oModelCNZ:SetValue('CNZ_CC'     ,oContrato['produtos'][nAux]['rateios'][nAux2]['centro_custo'])

		next
	next
	If (oModel:VldData()) /*Valida o modelo como um todo*/
		oModel:CommitData()//--Grava Contrato
	EndIf

	CN9->(DbSetOrder(1))
	If(oModel:HasErrorMessage())
		aErro := oModel:GetErrorMessage()
		AEval( aErro, { | x |  ConOut( x ) } )

	ElseIf(CN9->(DbSeek(xFilial("CN9") + cContrat)))
		ConOut("Contrato gravado com sucesso.")
		lRet := .t.
	EndIf
Return lRet




/*
User Function UNI69PIC()
	Local cJson := oRest:GetBodyRequest()
	Local aHeader := oRest:getHeaderRequest()
	Local oheader := JsonObject():new()
	Local cRet := ''
	Local oRet := JsonObject():new()
	Local oBody := JsonObject():new()
	Local cFil := ''


	oheader:fromJson('{"Content-Type":"application/json"}')
	oRest:SETHEADERRESPONSE(oheader)

	if !aHeader:hasProperty('filial') .or. empty(aHeader['filial'])
		oRest:setStatusCode(400)
		return oRest:setResponse('{"error":"Filial não informada"}')
	endif

	cFil := aHeader['filial']

	if empty(cJson)
		oRest:setStatusCode(400)
		return oRest:setResponse('{"error":"Corpo da requisição não informado"}')
	endif

	oBody:fromJson(lower(cJson))


	rpcsetenv('01',cFil)
	if u_UNI6998(oBody)
		oRest:setStatusCode(201)
		oRet["sucesso"] := "Contrato criado com sucesso"
		cRet := oRet:toJSON()
		freeobj(oRet)
	else
		oRest:setStatusCode(400)
		oRet["error"] := "Erro ao criar contrato"
		cRet := oRet:toJSON()
		freeobj(oRet)
 
	endif 
	rpcclearenv()
	freeobj(oBody)

Return orest:setResponse(cRet)
*/
