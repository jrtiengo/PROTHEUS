#Include "TOTVS.ch"
#Include "Protheus.ch"

/*/{Protheus.doc} IntDocMV
1. GAP 015 - Envio de documento de entrada para o MV
2. GAP 093 - Função fValidEst, Valida se a TES utiliza no documento de entrada atualiza estoque
@version V 1.00
@author Tiengo
@since 28/05/2025
@Param
nOPC 	- N - Operação: 1 = Inclusão, 4 = Classificação
cMsgErr - C - Mensagem de erro
@See https://tdn.totvs.com/pages/releaseview.action?pageId=6085406
@return logical, Verdadeiro se tudo ok
/*/

User Function IntDocMV(nOpc, cMsgErr)

	Local aArea         	:= FwGetArea()            as Array
	Local aAreaSD1      	:= SD1->(FwGetArea())     as Array
	Local lRet        		:= .T.
	Local cUrl              := SuperGetMV("UC_URLMV",.F.,"http://10.210.2.123:8491/jintegra_core/services/WebservicePadrao?Wsdl")	// URL do Webservice
	Local cEstMV			:= SuperGetMV("UC_ESTMV",.F.,"")																		// Local de Estoque MV
	Local cMsgWS            := ""
	Local cOperMV           := ""
	Local oLog        		:= Nil
	Local jAuxLog     		:= Nil
	Local cRespXml			:= ""
	Local oRespXml			:= Nil
	Local lContinua			:= .T.
	Local cError			:= ""
	Local cWarning			:= ""
	Local cMsgOk			:= ""

	Default nOpc 			:= 0

	SD1->(DbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	If SD1->(MsSeek(FWxFilial('SD1')+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
		//Verifica se a SC veio do MV
		If ! Empty(SD1->D1_PEDIDO)
			SC1->(DbSetOrder(6)) //C1_FILIAL+C1_PEDIDO+C1_ITEMPED+C1_PRODUTO
			If SC1->(MsSeek(FWxFilial('SC1') + SD1->D1_PEDIDO))
				If Alltrim(SC1->C1_XORINT) <> 'MV'
					Return(.T.)
				Endif
			Endif
		Else
			Return(.T.)
		Endif
	Endif

	If ! fValidEst()
		If ! IsBlind()
			FwAlertWarning("TES não atualiza estoque", "Nota Fiscal não enviada ao MV")
			Return(.T.)
		Else
			Conout("TES não atualiza estoque")
			Return(.T.)
		Endif
	Endif

	oLog    := CtrlLOG():New()
	jAuxLog := JsonObject():New()

	If ! oLog:SetTab("SZL")
		U_AdminMsg("[PrepSendDoc] " + DToC(Date()) + " - " + Time() + " -> " + oLog:GetError())
		Return(.T.)
	EndIf

//Caso vier uma exclusão ou estorno, eu devo excluir no MV, pois o DOC só será incluido novamente depois de ser incluido ou classficado
//Ainda não foi definido se terá exclusão de NF no MV
	Iif(nOPC == 5, cOperMV := 'E', cOperMV := 'I')

//Montando XML para envio ao MV
	cMsgWS += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://br.com.mv.jintegra.core.webservicePadrao">'+CRLF
	cMsgWS += '<soapenv:Header/>'+CRLF
	cMsgWS += '<soapenv:Body>'+CRLF
	cMsgWS += '<web:processar>'+CRLF
	cMsgWS += '<xml xsi:type="soapenc:string" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"><![CDATA[<?xml version="1.0" encoding="ISO-8859-1"?>'+CRLF
	cMsgWS += '	<mensagem>'+CRLF
	cMsgWS += '		<Cabecalho>'+CRLF
	cMsgWS += '			<mensagemID>'+xIDInt()+'</mensagemID>'+CRLF //C1_XIDINT
	cMsgWS += '			<versaoXML>1</versaoXML>'+CRLF
	cMsgWS += '			<identificacaoCliente>' +FWSM0Util():GetSM0Data(cEmpAnt , cFilAnt , { "M0_CGC" })[1][2]+ '</identificacaoCliente>'+CRLF
	cMsgWS += '			<servico>' +'NOTA_ESTOQUE'+ '</servico>'+CRLF
	cMsgWS += '			<dataHora>' +RetDTHR(dDataBase,.T.)+ '</dataHora>'+CRLF
	cMsgWS += '			<empresaOrigem>' +SM0->M0_CGC+ '</empresaOrigem>'+CRLF
	cMsgWS += '			<sistemaOrigem>' +'TOTVS'+ '</sistemaOrigem>'+CRLF
	cMsgWS += '			<empresaDestino>' +SM0->M0_CGC+ '</empresaDestino>'+CRLF
	cMsgWS += '			<sistemaDestino>' +'SOULMV'+ '</sistemaDestino>'+CRLF
	cMsgWS += '		</Cabecalho>'+CRLF
	cMsgWS += '		<NotaFiscal>'+CRLF
//cMsgWS += '			<idIntegracao>'+xIDInt()+'</idIntegracao>'+CRLF
	cMsgWS += '			<operacao>' +cOperMV+ '</operacao>'+CRLF
	cMsgWS += '			<codigoEntradaProdutoDePara>' +Alltrim(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))+ '</codigoEntradaProdutoDePara>'+CRLF
	cMSgWS += '			<tipoEntrada>N</tipoEntrada>'+CRLF
	cMSgWS += '			<codigoTipoDocumento>1</codigoTipoDocumento>'+CRLF
	cMsgWS += '			<numeroDocumento>' +SF1->F1_DOC+ '</numeroDocumento>'+CRLF
	cMsgWS += '			<numeroSerie>' +Alltrim(SF1->F1_SERIE)+ '</numeroSerie>'+CRLF
	cMsgWS += '			<codigoCfop>' +'1'+ '</codigoCfop>'+CRLF //Codigo do MV
	cMsgWS += '			<numeroCfop>' +AllTrim(SD1->D1_CF)+ '</numeroCfop>'+CRLF
	cMsgWS += '			<dataEmissao>' +DtoS(SF1->F1_EMISSAO)+ '</dataEmissao>'+CRLF
	cMsgWS += '			<dataEntrada>' +DtoS(SF1->F1_DTDIGIT)+ '</dataEntrada>'+CRLF
	cMsgWS += '			<horaEntrada>' +SubStr(Time(), 1, 5) + '</horaEntrada>'+CRLF
	cMsgWS += '			<dataConclusao>' +DtoS(ddatabase) + ' ' + time()+ '</dataConclusao>'+CRLF
	cMsgWS += '			<consignado>' +'N'+ '</consignado>'+CRLF
	cMsgWS += '			<codigoOrdemCompraDePara>' +SD1->D1_PEDIDO+ '</codigoOrdemCompraDePara>'+CRLF
	cMsgWS += '			<codigoEstoque>' +cEstMV+ '</codigoEstoque>'+CRLF
	cMsgWS += '			<codigoFornecedorDePara>' +SF1->F1_FORNECE+SF1->F1_LOJA+ '</codigoFornecedorDePara>'+CRLF
	cMsgWS += '			<tipoFrete>' +SF1->F1_TPFRETE+ '</tipoFrete>'+CRLF
	cMsgWS += ' 		<valorTotalNota>' +SF1->F1_VALBRUT+ '</valorTotalNota>'+CRLF
	cMsgWS += '			<tipoEntrega>' +'T'+ '</tipoEntrega>'+CRLF

//Se for CIF, o valor do frete é incluiso na nota
	If SF1->F1_TPFRETE == 'C'
		cMsgWS += '		<incluirFreteNota>' +'S'+'</incluirFreteNota>'+CRLF
	Else
		cMsgWS += '		<incluirFreteNota>' +'N'+ '</incluirFreteNota>'+CRLF
	Endif

//Busca títulos na SE2 relacionados à nota
/*
	cChave := SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC
	SE2->(DbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
	If SE2->(MsSeek(FWxFilial('SE2')+cChave))
		cMsgWS += '			<listaDuplicata>'+CRLF
		While ! SE2->(Eof()) .and. SE2->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == cChave
			cMsgWS += '             <Duplicata>'+CRLF
			cMsgWS += '                <numeroDuplicata>' +SE2->E2_PARCELA+ '</numeroDuplicata>'+CRLF
			cMsgWS += '                <dataDuplicata>' +DtoS(SE2->E2_VENCREA)+ '</dataDuplicata>'+CRLF
			cMsgWS += '                <valorTotalDuplicata>' +cValtoChar(SE2->E2_VALOR)+ '</valorTotalDuplicata>'+CRLF
			cMsgWS += '				</Duplicata>'+CRLF
			SE2->(DbSkip())
		Enddo
		cMsgWS += '			</listaDuplicata>'+CRLF
	Endif
*/

//Percorre os itens da nota
	cMsgWS += '		<listaProduto>'+CRLF
	While ! SD1->(Eof()) .and. SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
		cMsgWS += '		<Produto>'+CRLF
		cMsgWS += '			<operacao>' +cOperMV+ '</operacao>'+CRLF
		cMsgWS += '			<codigoProdutoDePara>' +SD1->D1_COD+ '</codigoProdutoDePara>'+CRLF
		cMsgWS += '			<quantidade>' +cValtoChar(SD1->D1_QUANT)+ '</quantidade>'+CRLF
		cMsgWS += '			<quantidadeEntradaTotal>' +cValtoChar(SD1->D1_QUANT)+ '</quantidadeEntradaTotal>'+CRLF
		cMsgWS += '			<codigoUnidade>' +Alltrim(Posicione("SAH",1,FWxFilial("SAH")+SD1->D1_UM,"AH_XUNIMV"))+ '</codigoUnidade>'+CRLF
		cMsgWS += '			<valorUnitario>' +cValtoChar(SD1->D1_VUNIT)+ '</valorUnitario>'+CRLF
		cMsgWS += '			<valorTotal>' +cValtoChar(SD1->D1_TOTAL)+ '</valorTotal>'+CRLF
		If ! Empty(SD1->D1_LOTECTL)
			cMsgWS += '			<listaLoteProduto>'+CRLF
			cMsgWS += '				<LoteProduto>'+CRLF
			cMsgWS += '					<codigoLote>' +SD1->D1_LOTECTL+ '</codigoLote>'+CRLF
			cMsgWS += '					<quantidadeEntrada>' +cValtoChar(SD1->D1_QUANT)+ '</quantidadeEntrada>'+CRLF
			cMsgWS += '					<dataValidade>' +dTos(SD1->D1_DTVALID)+ '</dataValidade>'+CRLF
			cMsgWS += '					<descMarcaFabricante>' +FWNoAccent(Alltrim(Posicione('SB1', 1, FWxFilial('SB1')+SD1->D1_COD, 'B1_DESC')))+ '</descMarcaFabricante>'+CRLF
			cMsgWS += '				</LoteProduto>'+CRLF
			cMsgWS += '			</listaLoteProduto>'+CRLF
		Endif
		cMsgWS += '		</Produto>'+CRLF
		SD1->(DbSkip())
	Enddo
	cMsgWS += '			</listaProduto>'+CRLF
	cMsgWS += '		</NotaFiscal>'+CRLF
	cMsgWS += '	</mensagem>'+CRLF
	cMsgWS += ']]></xml>'+CRLF
	cMsgWS += '</web:processar>'+CRLF
	cMsgWS += '</soapenv:Body>'+ CRLF
	cMsgWS += '</soapenv:Envelope>'+CRLF

//Cria o objeto WSDL
	oWsdl := TWsdlManager():New()

//header HTTP SOAPAction
	oWsdl:lAlwaysSendSA := .T.
	oWsdl:nTimeout := 10

//Tenta fazer o Parse da URL
	lContinua := oWsdl:ParseURL(cURL)

	If ! lContinua

		cMsgErr   += "SF1: "+SF1->F1_DOC+ ' ' +SF1->F1_SERIE+ ' ' +SF1->F1_FORNECE+ ' ' +SF1->F1_LOJA+" - " + oWsdl:cError

		jAuxLog["status"]  := "0"
		jAuxLog["idinteg"] := ""
		jAuxLog["nomapi"]  := "PrepSendFDoc"
		jAuxLog["rotina"]  := "PrepSendFDoc"
		jAuxLog["tabela"]  := "SF1"
		jAuxLog["recno"]   := SF1->(RecNo())
		jAuxLog["data"]    := DToS(dDataBase)
		jAuxLog["hora"]    := Time()
		jAuxLog["msgresp"] := "error"
		jAuxLog["msgerr"]  := "Erro ParseURL"
		jAuxLog["jsonbod"] := cMsgErr
		jAuxLog["jsonret"] := AnswerFormat(606, "Erro ParseURL: ", cMsgErr)

		If ! oLog:AddItem(jAuxLog)
			U_AdminMsg("[PrepSendFDoc] " + DToC(dDataBase) + " - " + Time() + " -> " + cMsgErr, IsBlind())
		Endif

		lRet := .F.
	EndIf

	If lContinua

		//Define a operação
		lContinua := oWsdl:SetOperation("processar")

		If ! lContinua

			cMsgErr   += "SF1: "+SF1->F1_DOC+ ' ' +SF1->F1_SERIE+ ' ' +SF1->F1_FORNECE+ ' ' +SF1->F1_LOJA+" - " + oWsdl:cError

			jAuxLog["status"]  := "0"
			jAuxLog["idinteg"] := ""
			jAuxLog["nomapi"]  := "PrepSendFDoc"
			jAuxLog["rotina"]  := "PrepSendFDoc"
			jAuxLog["tabela"]  := "SF1"
			jAuxLog["recno"]   := SF1->(RecNo())
			jAuxLog["data"]    := DToS(dDataBase)
			jAuxLog["hora"]    := Time()
			jAuxLog["msgresp"] := "error"
			jAuxLog["msgerr"]  := "Erro SetOperation"
			jAuxLog["jsonbod"] := cMsgErr
			jAuxLog["jsonret"] := AnswerFormat(606, "Erro SetOperation: ", cMsgErr)

			If ! oLog:AddItem(jAuxLog)
				U_AdminMsg("[PrepSendDoc] " + DToC(dDataBase) + " - " + Time() + " -> " + cMsgErr, IsBlind())
			Endif

			lRet := .F.
		EndIf
	EndIf

	If lContinua

		//Envio da mensagem SOAP
		lContinua := oWsdl:SendSoapMsg(cMsgWS)

		If ! lContinua

			cMsgErr   += "SF1: "+SF1->F1_DOC+ ' ' +SF1->F1_SERIE+ ' ' +SF1->F1_FORNECE+ ' ' +SF1->F1_LOJA+" - " + oWsdl:cError

			jAuxLog["status"]  := "0"
			jAuxLog["idinteg"] := ""
			jAuxLog["nomapi"]  := "PrepSendFDoc"
			jAuxLog["rotina"]  := "PrepSendFDoc"
			jAuxLog["tabela"]  := "SF1"
			jAuxLog["recno"]   := SF1->(RecNo())
			jAuxLog["data"]    := DToS(dDataBase)
			jAuxLog["hora"]    := Time()
			jAuxLog["msgresp"] := "error"
			jAuxLog["msgerr"]  := "Erro SendSoapMsg"
			jAuxLog["jsonbod"] := cMsgErr
			jAuxLog["jsonret"] := AnswerFormat(606, "Erro na define da operação", cMsgErr)

			If ! oLog:AddItem(jAuxLog)
				U_AdminMsg("[PrepSendFDoc] " + DToC(dDataBase) + " - " + Time() + " -> " + cMsgErr, IsBlind())
			Endif

			lRet := .F.

		Else

			cRespXml	:= oWsdl:GetSoapResponse()
			oRespXml	:= XmlParser(cRespXml, "_", @cError, @cWarning)

			//Retorna o objeto do nó XML
			oRespXml := XmlChildEx(oRespXml:_SOAPENV_ENVELOPE:_SOAPENV_BODY:_NS1_PROCESSARRESPONSE, "_PROCESSARRETURN")

			If oRespXml <> Nil

				cMsgRet		:=  oRespXml:text

				//Verifico se existe a TAG Motivo de Erro
				If At('<motivoErro>', cMsgRet) > 0

					cMsgErr		:=  cMsgRet
					lContinua	:= .F.
				Else
					cMsgOk 		:=  cMsgRet
					lContinua	:= .T.
				Endif
			Endif

			If ! lContinua

				//Informo que a integração não foi bem sucedida
				SF1->(RecLock('SF1',.F.))
				SF1->F1_XSTREQ := '0'
				SF1->F1_XTPREQ := Iif(nOpc == 5, 'E', 'I')
				SF1->(MsUnlock())

				lRet := .F.

				cMsgErr   += "SF1: "+SF1->F1_DOC+ ' ' +SF1->F1_SERIE+ ' ' +SF1->F1_FORNECE+ ' ' +SF1->F1_LOJA+" - "+" - Erro!"

				jAuxLog["status"]  := "1"
				jAuxLog["idinteg"] := ""
				jAuxLog["nomapi"]  := "PrepSendDoc"
				jAuxLog["rotina"]  := "PrepSendDoc"
				jAuxLog["tabela"]  := "SF1"
				jAuxLog["recno"]   := SF1->(RecNo())
				jAuxLog["data"]    := DToS(dDataBase)
				jAuxLog["hora"]    := Time()
				jAuxLog["msgresp"] := "Erro"
				jAuxLog["msgerr"]  := ""
				jAuxLog["jsonbod"] := cMsgErr
				jAuxLog["jsonret"] := AnswerFormat(201, "Integração não realizada!", cMsgErr)

				If ! oLog:AddItem(jAuxLog)
					U_AdminMsg("[PrepSendFDoc] " + DToC(dDataBase) + " - " + Time() + " -> " + cMsgErr, IsBlind())
				Endif
			Else

				SF1->(RecLock('SF1',.F.))
				SF1->F1_XSTREQ := '1'
				SF1->F1_XTPREQ := Iif(nOpc == 5, 'E', 'I')
				SF1->(MsUnlock())

				cMsgOk   += "SF1: "+SF1->F1_DOC+ ' ' +SF1->F1_SERIE+ ' ' +SF1->F1_FORNECE+ ' ' +SF1->F1_LOJA+ '' + Sucesso

				jAuxLog["status"]  := "1"
				jAuxLog["idinteg"] := ""
				jAuxLog["nomapi"]  := "PrepSendDoc"
				jAuxLog["rotina"]  := "PrepSendDoc"
				jAuxLog["tabela"]  := "SF1"
				jAuxLog["recno"]   := SF1->(RecNo())
				jAuxLog["data"]    := DToS(dDataBase)
				jAuxLog["hora"]    := Time()
				jAuxLog["msgresp"] := "Sucesso"
				jAuxLog["msgerr"]  := ""
				jAuxLog["jsonbod"] := cMsgOk
				jAuxLog["jsonret"] := AnswerFormat(201, "Integração realizada com sucesso!", cMsgOk)

				If ! oLog:AddItem(jAuxLog)
					U_AdminMsg("[PrepSendFDoc] " + DToC(dDataBase) + " - " + Time() + " -> " + cMsgOk, IsBlind())
				Endif
			Endif
		EndIf
	EndIf

	FwRestArea(aAreaSD1)
	FwRestArea(aArea)

Return(lRet)

/*/{Protheus.doc} xIDInt
description Função que cria para o MV o MensagemID
@type function
@version  
@author Marcio Martins
@since 6/4/2025
@return variant, return_description
/*/
Static Function xIDInt()

	Local cRet			:= ""
	Local cQuery 		:= ""
	Local cAlias		:= ""

	cQuery := " SELECT MAX(C1_XIDINT ) C1_XIDINT FROM " + RetSqlName("SC1") + " SC1	WHERE D_E_L_E_T_ = ' '	"

	cQuery := ChangeQuery(cQuery)
	cAlias := MPSysOpenQuery(cQuery)

	If ! (cAlias)->(EoF())
		If ! Empty((cAlias)->C1_XIDINT)
			cRet := soma1(Alltrim((cAlias)->C1_XIDINT))
		Else
			cRet := StrZero(1,TamSX3("C1_XIDINT")[1])
		Endif
	Else
		cRet := StrZero(1,TamSX3("C1_XIDINT")[1])
	Endif

	(cAlias)->(dbCloseArea())

Return(cRet)

/*/{Protheus.doc} RetDTHR
description Retorna data e hora atual do servidor formatada conforme documentacao
@type function
@version  
@author Marcio Martins
@since 10/06/2025
@return variant, return_description
/*/
Static Function RetDTHR(dData,lHora)

	Local cRet := ""

	cRet += strZero(year(dData),4)+"-"
	cRet += strZero(month(dData),2)+"-"
	cRet += strZero(day(dData),2)
	If lHora
		cRet += " "
		cRet += SubStr(Time(),1,2)+":"
		cRet += SubStr(Time(),4,2)+":"
		cRet += SubStr(Time(),7,2)
	Endif

Return(cRet)

/*/{Protheus.doc} AnswerFormat
Funcao que monta a resposta de retorno do oRest
@type function
@version V 1.00
@author Marcio Martins
@since 06/27/2025
@param statusCode, numeric, Codigo de retorno
@param message, character, Mensagem do retorno
@param detailed, character, Detalhe do retorno 
@return json, Json com resposta montada
/*/
Static Function AnswerFormat(statusCode, message, detailed)

	Local jAux   := JsonObject():New()
	Local jRet   := JsonObject():New()

	jAux:FromJson(detailed)

	jRet["result"]     := Iif(statusCode < 300, .T., .F.)
	jRet["statusCode"] := statusCode
	jRet["message"]    := message
	jRet["response"]   := jAux

Return (jRet)

//Valida se a TES utiliza no documento de entrada atualiza estoque
Static Function fValidEst()

	Local aArea         := FwGetArea()            as Array
	Local lRet          :=.T.     				  as Logical

	SF4->(DbSetOrder(1)) //F4_FILIAL+F4_CODIGO

	If SF4->(MsSeek(FWxFilial('SF4') + SD1->D1_TES))
		If SF4->F4_ESTOQUE == 'N'
			lRet := .F.
		Endif
	Endif

	FwRestArea(aArea)

Return(lRet)
