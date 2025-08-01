#Include "TOTVS.ch"
#Include "Protheus.ch"

/*/{Protheus.doc} IntDocMV
Envio de documento de entrada para o MV - GAP-15
@version V 1.00
@author Tiengo
@since 28/05/2025
@See https://tdn.totvs.com/pages/releaseview.action?pageId=6085406
@return logical, Verdadeiro se tudo ok
/*/

User Function IntDocMV(nOPC, cMsgErr)

	Local lRet        		:= .T.
	Local cUrl              := SuperGetMV("UC_URLMV",.F.,"http://10.210.2.123:8491/jintegra_core/services/WebservicePadrao?Wsdl")	// URL do Webservice
	Local cMsgWS            := ""
	Local cOperMV           := ""
	Local oLog        		:= Nil
	Local jAuxLog     		:= Nil
	Local cMensagEr		  	:= ""
	Local cRespXml			:= ""
	Local oRespXml			:= Nil
	Local lContinua			:= .T.
	Local cError			:= ""
	Local cWarning			:= ""

	SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
	SD1->(DbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM

	If SD1->(MsSeek(FWxFilial('SD1')+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
		//Verifica se a SC veio do MV
		If Empty(SD1->D1_PEDIDO)
			Conout("IntDocMV: Documento sem Pedido de Compra!")
			Return(.T.)
		Endif
	Endif
	SC1->(DbSetOrder(6)) //C1_FILIAL+C1_PEDIDO+C1_ITEMPED+C1_PRODUTO
	If SC1->(MsSeek(FWxFilial('SC1') + SD1->D1_PEDIDO))
		If Alltrim(SC1->C1_XORINT) <> 'MV'
			Conout("IntDocMV: Solicitação não faz parte do MV!")
			Return(.T.)
		Endif
	Else
		Conout("IntDocMV: Pedido de Compra sem SC!")
		Return(.T.)
	Endif
	*/
	oLog    := CtrlLOG():New()
	jAuxLog := JsonObject():New()
	If ! oLog:SetTab("SZL")
		U_AdminMsg("[PrepSendFor] " + DToC(Date()) + " - " + Time() + " -> " + oLog:GetError())
		Return(.T.)
	EndIf

	cOperMV := "I"

	//Montando XML para envio ao MV
	cMsgWS += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://br.com.mv.jintegra.core.webservicePadrao">'+CRLF
	cMsgWS += '<soapenv:Header/>'+CRLF
	cMsgWS += '<soapenv:Body>'+CRLF
	cMsgWS += '<web:processar>'+CRLF
	cMsgWS += '<xml xsi:type="soapenc:string" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"><![CDATA[<?xml version="1.0" encoding="ISO-8859-1"?>'+CRLF
	cMsgWS += '	<mensagem>'+CRLF
	cMsgWS += '		<Cabecalho>'+CRLF
	cMsgWS += '			<mensagemID>'+xIDInt()+'</mensagemID>'+CRLF
	cMsgWS += '			<versaoXML>1</versaoXML>'+CRLF
	cMsgWS += '			<identificacaoCliente>' +FWSM0Util():GetSM0Data(cEmpAnt , cFilAnt , { "M0_CGC" })[1][2]+ '</identificacaoCliente>'+CRLF
	cMsgWS += '			<servico>' +'NOTA_ESTOQUE'+ '</servico>'+CRLF
	cMsgWS += '			<dataHora>' +RetDTHR(dDataBase,.T.)+ '</dataHora>'+CRLF
	cMsgWS += '			<empresaOrigem>' +'1'+ '</empresaOrigem>'+CRLF
	cMsgWS += '			<sistemaOrigem>' +'1'+ '</sistemaOrigem>'+CRLF
	cMsgWS += '			<empresaDestino>1</empresaDestino>'+CRLF
	cMsgWS += '			<sistemaDestino>' +'TOTVS'+ '</sistemaDestino>'+CRLF
	cMsgWS += '		</Cabecalho>'+CRLF
	cMsgWS += '		<NotaFiscal>'+CRLF
	cMsgWS += '			<idIntegracao>'+xIDInt()+'</idIntegracao>'+CRLF
	cMsgWS += '			<operacao>' +cOperMV+ '</operacao>'+CRLF
	cMsgWS += '			<codigoEntradaProdutoDePara>'+'1'+ '</codigoEntradaProdutoDePara>'+CRLF //Não sei o que mandar
	cMsgWS += '			<numeroDocumento>' +SF1->F1_DOC+ '</numeroDocumento>'+CRLF
	cMsgWS += '			<numeroSerie>' +Alltrim(SF1->F1_SERIE)+ '</numeroSerie>'+CRLF
	cMsgWS += '			<codigoCfop>' +AllTrim(SD1->D1_CF)+ '</codigoCfop>'+CRLF
	cMsgWS += '			<numeroCfop>' +AllTrim(SD1->D1_CF)+ '</numeroCfop>'+CRLF
	cMsgWS += '			<dataEmissao>' +DtoS(SF1->F1_EMISSAO)+ '</dataEmissao>'+CRLF
	cMsgWS += '			<dataEntrada>' +DtoS(SF1->F1_DTDIGIT)+ '</dataEntrada>'+CRLF
	cMsgWS += '			<horaEntrada>' +SubStr(Time(), 1, 5) + '</horaEntrada>'+CRLF
	cMsgWS += '			<dataConclusao>' +DtoS(ddatabase) + ' ' + time()+ '</dataConclusao>'+CRLF
	cMsgWS += '			<consignado>' +'N'+ '</consignado>'+CRLF //Tem que definir onde buscar essa informação S/N
	cMsgWS += '			<codigoOrdemCompraDePara>' +SD1->D1_PEDIDO+ '</codigoOrdemCompraDePara>'+CRLF
	cMsgWS += '			<codigoEstoqueDePara>' +SD1->D1_LOCAL+ '</codigoEstoqueDePara>'+CRLF
	cMsgWS += '			<codigoFornecedorDePara>' +SF1->F1_FORNECE+SF1->F1_LOJA+ '</codigoFornecedorDePara>'+CRLF
	cMsgWS += '			<tipoFreteDePara>' +SF1->F1_TPFRETE+ '</tipoFreteDePara>'+CRLF
	cMsgWS += '			<tipoEntrega>' +'T'+ '</tipoEntrega>'+CRLF // T- TOTAL - P - PARCIAL VOU DEIXAR TOTAL POR ENQUANTO

	//Se for CIF, o valor do frete é incluiso na nota
	If SF1->F1_TPFRETE == 'C'
		cMsgWS += '		<incluirFreteNota>' +'S'+'</incluirFreteNota>'+CRLF
	Else
		cMsgWS += '		<incluirFreteNota>' +'N'+ '</incluirFreteNota>'+CRLF
	Endif

	//Busca títulos na SE2 relacionados à nota
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

	//Percorre os itens da nota
	cMsgWS += '		<listaProduto>'+CRLF
	While ! SD1->(Eof()) .and. SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
		cMsgWS += '             <Produto>'+CRLF
		cMsgWS += '					<operacao>' +cOperMV+ '</operacao>'+CRLF
		cMsgWS += '					<codigoProdutoDePara>' +SD1->D1_COD+ '</codigoProdutoDePara>'+CRLF
		cMsgWS += '					<quantidade>' +cValtoChar(SD1->D1_QUANT)+ '</quantidade>'+CRLF
		cMsgWS += '					<codigoUnidadeProdutoDePara>' +SD1->D1_UM+ '</codigoUnidadeProdutoDePara>'+CRLF
		cMsgWS += '					<codigoEmbalagemDePara>' +SD1->D1_SEGUM+ '</codigoEmbalagemDePara>'+CRLF
		cMsgWS += '					<fator>' +cValtoChar(Posicione('SB1', 1, FWxFilial('SB1')+SD1->D1_COD, 'B1_CONV'))+ '</fator>'+CRLF
		cMsgWS += '					<valorUnitario>' +cValtoChar(SD1->D1_VUNIT)+ '</valorUnitario>'+CRLF
		cMsgWS += '					<quantidadeEntradaTotal>' +cValtoChar(SD1->D1_QUANT)+ '</quantidadeEntradaTotal>'+CRLF
		cMsgWS += '					<valorTotal>' +cValtoChar(SD1->D1_TOTAL)+ '</valorTotal>'+CRLF
		cMsgWS += '					<listaLoteProduto>'+CRLF
		cMsgWS += '						<LoteProduto>'+CRLF
		cMsgWS += '							<codigoLote>' +SD1->D1_LOTECTL+ '</codigoLote>'+CRLF
		cMsgWS += '							<quantidadeEntrada>' +cValtoChar(SD1->D1_QUANT)+ '</quantidadeEntrada>'+CRLF
		cMsgWS += '							<dataValidade>' +dTos(SD1->D1_DTVALID)+ '</dataValidade>'+CRLF
		cMsgWS += '							<descMarcaFabricante>' +FWNoAccent(Alltrim(Posicione('SB1', 1, FWxFilial('SB1')+SD1->D1_COD, 'B1_DESC')))+ '</descMarcaFabricante>'+CRLF
		cMsgWS += '						</LoteProduto>'+CRLF
		cMsgWS += '					</listaLoteProduto>'+CRLF
		cMsgWS += '				</Produto>'+CRLF
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
		//cMensagEr += "SF1: "+SF1->F1_DOC+ ' ' +SF1->F1_SERIE+ ' ' +SF1->F1_FORNECE+ ' ' +SF1->F1_LOJA+" - " + oWsdl:cError

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
			//cMensagEr += "SF1: "+SF1->F1_DOC+ ' ' +SF1->F1_SERIE+ ' ' +SF1->F1_FORNECE+ ' ' +SF1->F1_LOJA+" - " + oWsdl:cError

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

			//Informo no campo que a operação de integração não foi bem sucedida e se foi uma inclusão ou classificação
			SF1->(RecLock('SF1',.F.))
			SF1->F1_XSTREQ := '0'
			SF1->F1_XTPREQ := Iif(nOPC == 3, '1', '4')
			SF1->(MsUnlock())

			cMsgErr   += "SF1: "+SF1->F1_DOC+ ' ' +SF1->F1_SERIE+ ' ' +SF1->F1_FORNECE+ ' ' +SF1->F1_LOJA+" - " + oWsdl:cError
			//cMensagEr += "SF1: "+SF1->F1_DOC+ ' ' +SF1->F1_SERIE+ ' ' +SF1->F1_FORNECE+ ' ' +SF1->F1_LOJA+" - Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode + " - Erro SendSoapMsg: " + oWsdl:cError

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

			oRespXml := XmlChildEx(oRespXml:_SOAPENV_ENVELOPE:_SOAPENV_BODY:_NS1_PROCESSARRESPONSE, "_PROCESSARRETURN")

			If oRespXml <> Nil
				If !Empty(oRespXml:text)
					cMensagEr := oRespXml:text
					lContinua := .F.
				Else
					lContinua := .T.
				Endif
			Endif

			If ! lContinua

				//Informo no campo que a operação de integração foi bem sucedida e se foi uma inclusão ou classificação
				SF1->(RecLock('SF1',.F.))
				SF1->F1_XSTREQ := '1'
				SF1->F1_XTPREQ := Iif(nOPC == 3, '1', '4')
				SF1->(MsUnlock())

				cMsgErr   += "SF1: "+SF1->F1_DOC+ ' ' +SF1->F1_SERIE+ ' ' +SF1->F1_FORNECE+ ' ' +SF1->F1_LOJA+" - Sucesso!"
				//cMensagEr += "SF1: "+SF1->F1_DOC+ ' ' +SF1->F1_SERIE+ ' ' +SF1->F1_FORNECE+ ' ' +SF1->F1_LOJA+" - Sucesso!

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
				jAuxLog["jsonbod"] := cMsgErr
				jAuxLog["jsonret"] := AnswerFormat(201, "Integração realizada com sucesso!", cMsgErr)

				If ! oLog:AddItem(jAuxLog)
					U_AdminMsg("[PrepSendFDoc] " + DToC(dDataBase) + " - " + Time() + " -> " + cMsgErr, IsBlind())
				Endif

				lRet := .F.

			Else

				cMsgErr   += "SF1: "+SF1->F1_DOC+ ' ' +SF1->F1_SERIE+ ' ' +SF1->F1_FORNECE+ ' ' +SF1->F1_LOJA+ '' + cMensagEr
				//cMensagEr += "SF1: "+SF1->F1_DOC+ ' ' +SF1->F1_SERIE+ ' ' +SF1->F1_FORNECE+ ' ' +SF1->F1_LOJA+" - Sucesso!

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
				jAuxLog["jsonbod"] := cMsgErr
				jAuxLog["jsonret"] := AnswerFormat(201, "Integração realizada com sucesso!", cMsgErr)

				If ! oLog:AddItem(jAuxLog)
					U_AdminMsg("[PrepSendFDoc] " + DToC(dDataBase) + " - " + Time() + " -> " + cMsgErr, IsBlind())
				Endif
			Endif
		EndIf
	EndIf

Return(lRet)

/*/{Protheus.doc} EnvIntFor
Função para verificar o Log de Integração
@type function
@version V 1.00
@author Tiengo Junior
@since 27/05/2025
/*/
User Function VerLogSF1()

	Local oLogAPI	:= Nil 	as Object

	oLogAPI := CtrlLOG():New()
	oLogAPI:ViewLog('SF1', "", 'MATA103', 'SF1', SF1->(RECNO()) )

Return(.T.)

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

	cQuery += " SELECT MAX(C1_XIDINT ) C1_XIDINT   	"
	cQuery += " FROM " + RetSqlName("SC1") + " SC1	"
	cQuery += " WHERE D_E_L_E_T_ = ' '  			"

	cQuery := ChangeQuery(cQuery)

	MPSysOpenQuery(cQuery, 'TMP')

	If ! TMP->(EoF())
		If ! Empty(TMP->C1_XIDINT)
			cRet := soma1(Alltrim(TMP->C1_XIDINT))
		Else
			cRet := StrZero(1,TamSX3("C1_XIDINT")[1])
		Endif
	Else
		cRet := StrZero(1,TamSX3("C1_XIDINT")[1])
	Endif

	TMP->(dbCloseArea())

Return(cRet)

/*/{Protheus.doc} RetDTHR
description Retorna data e hora atual do servidor formatada conforme documentaÃ§Ã£o
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

Return cRet
