#Include "TOTVS.ch"
#Include "Protheus.ch"

/*/{Protheus.doc} INTPCMV
Envio de pedidos de compra para o MV - GAP-14
@version V 1.00
@author Tiengo
@since 28/05/2025
@Return lRet - Verdadeiro se tudo ok
/*/

User Function INTPCMV(nOPC, cDocto, cMsgErr)

	Local lRet        		:= .T.
	Local cUrl              := SuperGetMV("UC_URLMV",.F.,"")
	Local cMsgWS            := ""
	Local cOperMV           := ""
	Local oLog        		:= Nil
	Local jAuxLog     		:= Nil
	Local cMensagEr		  	:= ""
	Local lContinua			:= .T.

	//Customização para integração com MV, posiciona na SC1 para ver se a origem é MV
	/*
	If ! Empty(SC7->C7_NUMSC)
		SC1->(DbSetOrder(1)) //C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD
		If SC1->(MsSeek(FWxFilial('SC1') + SC7->C7_NUMSC))
			If SC1->C1_XORINT <> 'MV'
				Conout("IntPedMV: Solicitação não faz parte do MV!")
				Return(.T.)
			Endif
		Else
			Conout("IntPedMV: Pedido de Compra sem SC!")
			Return(.T.)
		Endif
	Else
		Conout("IntPedMV: Pedido de Compra, sem SC!")
		Return(.T.)
	Endif
*/
	oLog    := CtrlLOG():New()
	jAuxLog := JsonObject():New()
	If ! oLog:SetTab("SZL")
		U_AdminMsg("[PrepSendPed] " + DToC(Date()) + " - " + Time() + " -> " + oLog:GetError())
		Return (.T.)
	EndIf

	If nOpc == 1 // Inclusão

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
		cMsgWS += '			<servico>' +'ORDEM_COMPRA'+ '</servico>'+CRLF
		cMsgWS += '			<dataHora>' +RetDTHR(dDataBase,.T.)+ '</dataHora>'+CRLF
		cMsgWS += '			<empresaOrigem>' +'1'+ '</empresaOrigem>'+CRLF
		cMsgWS += '			<sistemaOrigem>' +'1'+ '</sistemaOrigem>'+CRLF
		cMsgWS += '			<empresaDestino>1</empresaDestino>'+CRLF
		cMsgWS += '			<sistemaDestino>' +'TOTVS'+ '</sistemaDestino>'+CRLF
		cMsgWS += '		</Cabecalho>'+CRLF
		cMsgWS += '		<OrdemCompra>'+CRLF
		cMsgWS += '			<operacao>' +cOperMV+ '</operacao>'+CRLF
		cMsgWS += '			<codigoOrdemCompraDePara>' +cDocto+ '</codigoOrdemCompraDePara>'+CRLF
		cMsgWS += '			<dataHoraEmissao>' +DtoS(SC7->C7_EMISSAO) + ' ' + time()+ '</dataHoraEmissao>'+CRLF
		cMsgWS += '			<codigoSolicCompraDePara>' +SC7->C7_NUMSC+ '</codigoSolicCompraDePara>'+CRLF
		cMsgWS += '			<codigoEstoqueDePara>' +SC7->C7_LOCAL+ '</codigoEstoqueDePara>'+CRLF
		cMsgWS += '			<codigoFornecedorDePara>' +SC7->C7_FORNECE+SC7->C7_LOJA+ '</codigoFornecedorDePara>'+CRLF
		cMsgWS += '			<cgcCpf>' +Alltrim(Posicione('SA2', 1, FWxFilial('SA2')+SC7->C7_FORNECE+SC7->C7_LOJA, 'A2_CGC'))+ '</cgcCpf>'+CRLF
		cMsgWS += '			<codigoCondicaoPagamento>' +'1'+ '</codigoCondicaoPagamento>'+CRLF
		cMsgWS += '			<tipoFreteDePara>' +'C'+ '</tipoFreteDePara>'+CRLF
		cMsgWS += '			<valorTotalNota>' +xTotal(SC7->C7_NUM)+ '</valorTotalNota>'+CRLF
		cMsgWS += '			<tipoPedido>' +'P'+ '</tipoPedido>'+CRLF
		cMsgWS += '			<tipoSituacao>' +'T'+ '</tipoSituacao>'+CRLF
		cMsgWS += ' 		<autorizado>' +'S'+ '</autorizado>'+CRLF
		cMsgWS += '			<codigoUsuarioAutorizador>' +'DBAMV'+ '</codigoUsuarioAutorizador>'+CRLF
		cMsgWS += '			<descUsuarioAutorizador>' +'DBAMV'+ '</descUsuarioAutorizador>'+CRLF

		//Percorre os itens da nota
		If SC7->(MsSeek(FWxFilial('SC7') + cDocto))

			cMsgWS += '		<listaProduto>'+CRLF

			While ! SC7->(Eof()) .and. SC7->C7_NUM == cDocto
				cMsgWS += '             <Produto>'+CRLF
				cMsgWS += '					<operacao>' +cOperMV+ '</operacao>'+CRLF
				cMsgWS += '					<codigoProdutoDePara>' +SC7->C7_PRODUTO+ '</codigoProdutoDePara>'+CRLF
				cMsgWS += '					<quantidade>' +cValtoChar(SC7->C7_QUANT)+ '</quantidade>'+CRLF
				cMsgWS += '					<codigoUnidadeProdutoDePara>' +SC7->C7_UM+ '</codigoUnidadeProdutoDePara>'+CRLF
				cMsgWS += '					<valorUnitario>' +cValtoChar(SC7->C7_PRECO)+ '</valorUnitario>'+CRLF

				SC7->(DbSkip())
			Enddo
			cMsgWS += '		</listaProduto>'+CRLF
		Endif
		cMsgWS += '		</OrdemCompra>'+CRLF
		cMsgWS += '	</mensagem>'+CRLF
		cMsgWS += ']]></xml>'+CRLF
		cMsgWS += '</web:processar>'+CRLF
		cMsgWS += '</soapenv:Body>'+CRLF
		cMsgWS += '</soapenv:Envelope>'+CRLF

		//Cria o objeto WSDL
		oWsdl := TWsdlManager():New()

		//header HTTP SOAPAction
		oWsdl:lAlwaysSendSA := .T.
		oWsdl:nTimeout := 10

		//Tenta fazer o Parse da URL
		lContinua := oWsdl:ParseURL(cURL)

		If ! lContinua

			cMsgErr   += "SC7: "+SC7->C7_NUM+ ' ' +SC7->C7_FORNECE+ ' ' +SC7->C7_LOJA+" - " + oWsdl:cError

			jAuxLog["status"]  := "0"
			jAuxLog["idinteg"] := ""
			jAuxLog["nomapi"]  := "PrepSendPed"
			jAuxLog["rotina"]  := "PrepSendPed"
			jAuxLog["tabela"]  := "SC7"
			jAuxLog["recno"]   := SC7->(RecNo())
			jAuxLog["data"]    := DToS(dDataBase)
			jAuxLog["hora"]    := Time()
			jAuxLog["msgresp"] := "error"
			jAuxLog["msgerr"]  := "Erro ParseURL"
			jAuxLog["jsonbod"] := cMsgErr
			jAuxLog["jsonret"] := AnswerFormat(606, "Erro ParseURL: ", cMsgErr)

			If ! oLog:AddItem(jAuxLog)
				U_AdminMsg("[PrepSendPed] " + DToC(dDataBase) + " - " + Time() + " -> " + cMsgErr, IsBlind())
			Endif

			lRet := .F.

		EndIf

		If lContinua

			//Define a operação
			lContinua := oWsdl:SetOperation("processar")

			If ! lContinua

				cMsgErr   += "SC7: "+SC7->C7_NUM+ ' ' +SC7->C7_FORNECE+ ' ' +SC7->C7_LOJA+" - " + oWsdl:cError

				jAuxLog["status"]  := "0"
				jAuxLog["idinteg"] := ""
				jAuxLog["nomapi"]  := "PrepSendPed"
				jAuxLog["rotina"]  := "PrepSendPed"
				jAuxLog["tabela"]  := "SC7"
				jAuxLog["recno"]   := SC7->(RecNo())
				jAuxLog["data"]    := DToS(dDataBase)
				jAuxLog["hora"]    := Time()
				jAuxLog["msgresp"] := "error"
				jAuxLog["msgerr"]  := "Erro SetOperation"
				jAuxLog["jsonbod"] := cMsgErr
				jAuxLog["jsonret"] := AnswerFormat(606, "Erro SetOperation: ", cMsgErr)

				If ! oLog:AddItem(jAuxLog)
					U_AdminMsg("[PrepSendPed] " + DToC(dDataBase) + " - " + Time() + " -> " + cMsgErr, IsBlind())
				Endif

				lRet := .F.
			EndIf
		EndIf

		If lContinua

			//Envio da mensagem SOAP
			lRet := oWsdl:SendSoapMsg(cMsgWS)

			If ! lRet

				cMsgErr   += "SC7: "+SC7->C7_NUM+ ' ' +SC7->C7_FORNECE+ ' ' +SC7->C7_LOJA+" - " + oWsdl:cError

				jAuxLog["status"]  := "0"
				jAuxLog["idinteg"] := ""
				jAuxLog["nomapi"]  := "PrepSendPed"
				jAuxLog["rotina"]  := "PrepSendPed"
				jAuxLog["tabela"]  := "SC7"
				jAuxLog["recno"]   := SC7->(RecNo())
				jAuxLog["data"]    := DToS(dDataBase)
				jAuxLog["hora"]    := Time()
				jAuxLog["msgresp"] := "error"
				jAuxLog["msgerr"]  := "Erro SendSoapMsg"
				jAuxLog["jsonbod"] := cMsgErr
				jAuxLog["jsonret"] := AnswerFormat(606, "Erro no envio SENDSOAP", cMsgErr)

				If ! oLog:AddItem(jAuxLog)
					U_AdminMsg("[PrepSendPed] " + DToC(dDataBase) + " - " + Time() + " -> " + cMsgErr, IsBlind())
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
					SC7->(RecLock('SC7',.F.))
					SC7->C7_XSTREQ := '1'
					SC7->C7_XTPREQ := Iif(nOPC == 3, '1', '')
					SC7->(MsUnlock())

					cMsgErr   += "SC7: "+SC7->C7_NUM+ ' ' +SC7->C7_FORNECE+ ' ' +SC7->C7_LOJA+" - "+" - Sucesso!"

					jAuxLog["status"]  := "1"
					jAuxLog["idinteg"] := ""
					jAuxLog["nomapi"]  := "PrepSendPed"
					jAuxLog["rotina"]  := "PrepSendPed"
					jAuxLog["tabela"]  := "SC7"
					jAuxLog["recno"]   := SC7->(RecNo())
					jAuxLog["data"]    := DToS(dDataBase)
					jAuxLog["hora"]    := Time()
					jAuxLog["msgresp"] := "Sucesso"
					jAuxLog["msgerr"]  := ""
					jAuxLog["jsonbod"] := cMsgErr
					jAuxLog["jsonret"] := AnswerFormat(201, "Integração realizada com sucesso!", cMsgErr)

					If ! oLog:AddItem(jAuxLog)
						U_AdminMsg("[PrepSendPed] " + DToC(dDataBase) + " - " + Time() + " -> " + cMsgErr, IsBlind())
					Endif

					lRet := .F.

				Else

					cMsgErr   += "SC7: "+SC7->C7_NUM+ ' ' +SC7->C7_FORNECE+ ' ' +SC7->C7_LOJA+" - " + cMsgErr

					jAuxLog["status"]  := "1"
					jAuxLog["idinteg"] := ""
					jAuxLog["nomapi"]  := "PrepSendPed"
					jAuxLog["rotina"]  := "PrepSendPed"
					jAuxLog["tabela"]  := "SC7"
					jAuxLog["recno"]   := SC7->(RecNo())
					jAuxLog["data"]    := DToS(dDataBase)
					jAuxLog["hora"]    := Time()
					jAuxLog["msgresp"] := "Sucesso"
					jAuxLog["msgerr"]  := ""
					jAuxLog["jsonbod"] := cMsgErr
					jAuxLog["jsonret"] := AnswerFormat(201, "Integração realizada com sucesso!", cMsgErr)

					If ! oLog:AddItem(jAuxLog)
						U_AdminMsg("[PrepSendPed] " + DToC(dDataBase) + " - " + Time() + " -> " + cMsgErr, IsBlind())
					Endif

					lRet := .F.
				Endif
			EndIf
		EndIf
	Endif

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

	cQuery += " SELECT MAX(C1_XIDINT ) C1_XIDINT   	"
	cQuery += " FROM " + RetSqlName("SC1") + " SC1	"
	cQuery += " WHERE D_E_L_E_T_ = ' '  			"

	cQuery := ChangeQuery(cQuery)

	MPSysOpenQuery(cQuery, 'TMP')

	If TMP->(EoF())
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

Return (cRet)

/*/{Protheus.doc} xIDInt
Função para retornar o total da nota na TAG do XML
@type function
@version  
@author Tiengo Junior
@since 29/07/2025
@return variant, return_description
/*/
Static Function xTotal(cNum)

	Local cRet			:= ""
	Local cQuery 		:= ""

	cQuery += " SELECT SUM(C7_TOTAL) TOTAL FROM " + RetSqlName("SC7") + " WHERE D_E_L_E_T_ = ' ' AND C7_NUM = '" + cNum + "' "
	cQuery := ChangeQuery(cQuery)

	MPSysOpenQuery(cQuery, 'TMP')

	If ! TMP->(EoF())
		cRet := cValtoChar(TMP->TOTAL)
	Endif

	TMP->(dbCloseArea())

Return(cRet)
