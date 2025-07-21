#Include "TOTVS.ch"
#Include "Protheus.ch"

/*/{Protheus.doc} INTPCMV
Envio de pedidos de compra para o MV - GAP-14
@version V 1.00
@author Tiengo
@since 28/05/2025
/*/

User Function INTPCMV(nOPC, cDocto, cMsgErr)

	Local lRet        		:= .T.
	Local cUrl              := SuperGetMV("UC_URLMV",.F.,"")               // URL do Webservice
	Local cUsuario          := SuperGetMV("UC_USERMV",.F.,"")              // Usuário do webservice
	Local cPssw             := SuperGetMV("UC_PSSWMV",.F.,"")              // Senha do webservice
	Local cMsgWS            := ""
	Local cOperMV           := ""
	Local oLog        		:= Nil
	Local jAuxLog     		:= Nil
	Local cMensagEr		  	:= ""

	//Customização para integração com MV, posiciona na SC1 para ver se a origem é MV
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

	oLog    := CtrlLOG():New()
	jAuxLog := JsonObject():New()
	If ! oLog:SetTab("SZL")
		U_AdminMsg("[PrepSendPed] " + DToC(Date()) + " - " + Time() + " -> " + oLog:GetError())
		Return (.T.)
	EndIf

	If nOpc == 1 // Inclusão

		cOperMV := "I"

		//Montando XML para envio ao MV
		cMsgWS := '?xml version="1.0" encoding="ISO-8859-1"?>'+CRLF
		cMsgWS += '<Mensagem>'+CRLF
		cMsgWS += '		<Cabecalho>'+CRLF
		cMsgWS += '			<mensagemID>' +xIDInt()+' </mensagemID>'+CRLF
		cMsgWS += '			<versaoXML>1</versaoXML>'+CRLF
		cMsgWS += '			<identificacaoCliente>' + FWSM0Util():GetSM0Data(cEmpAnt , cFilAnt , { "M0_CGC" })[1][2] + '</identificacaoCliente>'+CRLF
		cMsgWS += '			<servico>' +'ORDEM_COMPRA'+ '</servico>'+CRLF
		cMsgWS += '			<dataHora>' +DtoS(ddatabase) + 'HH' + time()+ '</dataHora>'+CRLF
		cMsgWS += '			<empresaOrigem>'  +cFilAnt+ '</empresaOrigem>'+CRLF
		cMsgWS += '			<sistemaOrigem>' +cPssw+ '</sistemaOrigem>'+CRLF
		cMsgWS += '			<empresaDestino>1</empresaDestino>'+CRLF
		cMsgWS += '			<sistemaDestino>1</sistemaDestino>'+CRLF
		cMsgWS += '			<usuario>' +cUsuario+ '</usuario>'+CRLF
		cMsgWS += '			<senha>' +cUsuario+ '</senha>'+CRLF
		cMsgWS += '		</Cabecalho>'+CRLF
		cMsgWS += '		<OrdemCompra>'+CRLF
		cMsgWS += '			<idIntegracao>89754</idIntegracao>'+CRLF
		cMsgWS += '			<operacao>' +cOperMV+ '</operacao>'+CRLF
		cMsgWS += '			<codigoOrdemCompraDePara>' +cDocto+ '</codigoOrdemCompraDePara>'+CRLF
		cMsgWS += '			<dataHoraEmissao>' +DtoS(SC7->C7_EMISSAO) + ' ' + time()+ '</dataHoraEmissao>'+CRLF
		cMsgWS += '			<codigoSolicCompraDePara>' +SC7->C7_NUMSC+ '</codigoSolicCompraDePara>'+CRLF
		cMsgWS += '			<codigoEstoqueDePara>' +SC7->C7_LOCAL+ '</codigoEstoqueDePara>'+CRLF
		cMsgWS += '			<codigoFornecedorDePara>' +SC7->C7_FORNECE+SC7->C7_LOJA+ '</codigoFornecedorDePara>'+CRLF
		cMsgWS += '			<cgcCpf>' +Alltrim(Posicione('SA2', 1, FWxFilial('SA2')+SC7->C7_FORNECE+SC7->C7_LOJA, 'A2_CGC'))+ '</cgcCpf>'+CRLF
		cMsgWS += '			<codigoCondicaoPagamentoDePara>' +SC7->C7_COND+ '</codigoCondicaoPagamentoDePara>'+CRLF
		cMsgWS += '			<tipoFreteDePara>' +SC7->C7_TPFRETE+ '</tipoFreteDePara>'+CRLF
		cMsgWS += '			<valorTotalNota>' +cValtoChar(SC7->C7_TOTAL)+ '</valorTotalNota>'+CRLF

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

				DBSelectArea("SZ0")
				SZ0->(dbSetOrder(2)) //ZZ0_FILIAL+Z0_NUMPED+Z0_PRODUTO
				If SZ0->(MSSeek(FWxFilial("SZ0")+SC7->C7_NUM+SC7->C7_PRODUTO))

					cMsgWS += '             <listaRateioSetor>'+CRLF

					While ! SZ0->(Eof()) .and. SZ0->(Z0_NUMPED+Z0_PRODUTO) == SC7->(C7_NUM+C7_PRODUTO)
						cMsgWS += '		<rateioSetor>'+CRLF
						cMsgWS += '			<operacao>' +cOperMV+ '</operacao>'+CRLF
						cMsgWS += '			<codigoSetorDepara>' +SZ0->Z0_CCUSTO+' </codigoSetorDepara>'+CRLF
						cMsgWS += '			<quantidadeRateio>' +SZ0->Z0_PERC+ '</quantidadeRateio>'+CRLF
						cMsgWS += '		</rateioSetor>'+CRLF
						SZ0->(DbSkip())
					Enddo

					cMsgWS += '			</listaRateioSetor>'+CRLF
					cMsgWS += '		</listaRateioSetor>'+CRLF
				Endif
				SC7->(DbSkip())
			Enddo
			cMsgWS += '		</listaProduto>'+CRLF
		Endif
		cMsgWS += '		</OrdemCompra>
		cMsgWS += '</Mensagem>

		//Cria o objeto WSDL
		oWsdl := TWsdlManager():New()
		oWsdl:nTimeout := 10

		//Tenta fazer o Parse da URL
		lRet := oWsdl:ParseURL(cURL)

		If ! lRet

			cMsgErr   += "SC7: "+SC7->C7_NUM+ ' ' +SC7->C7_FORNECE+ ' ' +SC7->C7_LOJA+" - " + oWsdl:cError
			cMensagEr += "SC7: "+SC7->C7_NUM+ ' ' +SC7->C7_FORNECE+ ' ' +SC7->C7_LOJA+" - " + oWsdl:cError

			jAuxLog["status"]  := "0"
			jAuxLog["idinteg"] := ""
			jAuxLog["nomapi"]  := "PrepSendFPed"
			jAuxLog["rotina"]  := "PrepSendFPed"
			jAuxLog["tabela"]  := "SC7"
			jAuxLog["recno"]   := SC7->(RecNo())
			jAuxLog["data"]    := DToS(dDataBase)
			jAuxLog["hora"]    := Time()
			jAuxLog["msgresp"] := "error"
			jAuxLog["msgerr"]  := "Erro ParseURL"
			jAuxLog["jsonbod"] := cMensagEr
			jAuxLog["jsonret"] := AnswerFormat(606, "Erro ParseURL: ", cMensagEr)

			If ! oLog:AddItem(jAuxLog)
				U_AdminMsg("[PrepSendPed] " + DToC(dDataBase) + " - " + Time() + " -> " + cMensagEr, IsBlind())
			Endif

			lContinua := .F.

		EndIf

		If lContinua

			//Define a operação
			aOps := oWsdl:ListOperations()
			lRet := oWsdl:SetOperation("___FALTA_DEFINIR_OPERACAO___")

			If !lRet

				cMsgErr   += "SC7: "+SC7->C7_NUM+ ' ' +SC7->C7_FORNECE+ ' ' +SC7->C7_LOJA+" - " + oWsdl:cError
				cMensagEr += "SC7: "+SC7->C7_NUM+ ' ' +SC7->C7_FORNECE+ ' ' +SC7->C7_LOJA+" - " + oWsdl:cError

				jAuxLog["status"]  := "0"
				jAuxLog["idinteg"] := ""
				jAuxLog["nomapi"]  := "PrepSendFPed"
				jAuxLog["rotina"]  := "PrepSendFPed"
				jAuxLog["tabela"]  := "SC7"
				jAuxLog["recno"]   := SC7->(RecNo())
				jAuxLog["data"]    := DToS(dDataBase)
				jAuxLog["hora"]    := Time()
				jAuxLog["msgresp"] := "error"
				jAuxLog["msgerr"]  := "Erro SetOperation"
				jAuxLog["jsonbod"] := cMensagEr
				jAuxLog["jsonret"] := AnswerFormat(606, "Erro SetOperation: ", cMensagEr)

				If ! oLog:AddItem(jAuxLog)
					U_AdminMsg("[PrepSendPed] " + DToC(dDataBase) + " - " + Time() + " -> " + cMensagEr, IsBlind())
				Endif

				lContinua := .F.
				lRet := .T.
			EndIf
		EndIf

		If lContinua

			//Define se fará a conexão SSL com o servidor de forma anônima, ou seja, sem verificação de certificados ou chaves.
			oWsdl:lSSLInsecure   := .T.

			lRet := oWsdl:SendSoapMsg(cMsgWS)

			If ! lRet

				//Informo no campo que a operação de integração não foi bem sucedida e se foi uma inclusão ou classificação
				SC7->(RecLock('SC7',.F.))
				SC7->C7_XSTREQ := '0'
				SC7->C7_XTPREQ := Iif(nOPC == 3, '1', '')
				SC7->(MsUnlock())

				cMsgErr   += "SC7: "+SC7->C7_NUM+ ' ' +SC7->C7_FORNECE+ ' ' +SC7->C7_LOJA+" - " + oWsdl:cError
				cMensagEr += "SC7: "+SC7->C7_NUM+ ' ' +SC7->C7_FORNECE+ ' ' +SC7->C7_LOJA+" - Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode + " - Erro SendSoapMsg: " + oWsdl:cError

				jAuxLog["status"]  := "0"
				jAuxLog["idinteg"] := ""
				jAuxLog["nomapi"]  := "PrepSendFPed"
				jAuxLog["rotina"]  := "PrepSendFPed"
				jAuxLog["tabela"]  := "SC7"
				jAuxLog["recno"]   := SC7->(RecNo())
				jAuxLog["data"]    := DToS(dDataBase)
				jAuxLog["hora"]    := Time()
				jAuxLog["msgresp"] := "error"
				jAuxLog["msgerr"]  := "Erro SendSoapMsg"
				jAuxLog["jsonbod"] := cMensagEr
				jAuxLog["jsonret"] := AnswerFormat(606, "Erro na define da operação", cMensagEr)

				If ! oLog:AddItem(jAuxLog)
					U_AdminMsg("[PrepSendFPed] " + DToC(dDataBase) + " - " + Time() + " -> " + cMensagEr, IsBlind())
				Endif

			Else
				//Informo no campo que a operação de integração foi bem sucedida e se foi uma inclusão ou classificação
				SC7->(RecLock('SC7',.F.))
				SC7->C7_XSTREQ := '1'
				SC7->C7_XTPREQ := Iif(nOPC == 3, '1', '')
				SC7->(MsUnlock())

				cMsgErr   += "SC7: "+SC7->C7_NUM+ ' ' +SC7->C7_FORNECE+ ' ' +SC7->C7_LOJA+" - Sucesso!"
				cMensagEr += "SC7: "+SC7->C7_NUM+ ' ' +SC7->C7_FORNECE+ ' ' +SC7->C7_LOJA+" - Sucesso!

				jAuxLog["status"]  := "1"
				jAuxLog["idinteg"] := ""
				jAuxLog["nomapi"]  := "PrepSendDPed"
				jAuxLog["rotina"]  := "PrepSendDPed"
				jAuxLog["tabela"]  := "SC7"
				jAuxLog["recno"]   := 0
				jAuxLog["data"]    := DToS(dDataBase)
				jAuxLog["hora"]    := Time()
				jAuxLog["msgresp"] := "Sucesso"
				jAuxLog["msgerr"]  := ""
				jAuxLog["jsonbod"] := cMensagEr
				jAuxLog["jsonret"] := AnswerFormat(201, "Integração bem sucecidade!", cMensagEr)

				If ! oLog:AddItem(jAuxLog)
					U_AdminMsg("[PrepSendDPed] " + DToC(dDataBase) + " - " + Time() + " -> " + cMensagEr, IsBlind())
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
