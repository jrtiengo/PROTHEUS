#Include "TOTVS.ch"
#Include "Protheus.ch"

/*/{Protheus.doc} INTPCMV
Envio de pedidos de compra para o MV - GAP-14
@version V 1.00
@author Tiengo
@since 28/05/2025
/*/

User Function INTPCMV(nOPC, cMsgErr)

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
		cMsgWS := ' ?xml version="1.0" encoding="ISO-8859-1"?>' + CRLF
		cMsgWS += '	<Mensagem>' + CRLF
		cMsgWS += '		<Cabecalho>' + CRLF
		cMsgWS += '			<mensagemID>7452314</mensagemID>' + CRLF //Aqui deve ser o próximo ID da SZL - confirmar
		cMsgWS += '			<versaoXML>1</versaoXML>' + CRLF
		cMsgWS += '			<identificacaoCliente>' + FWSM0Util():GetSM0Data(cEmpAnt , cFilAnt , { "M0_CGC" }) + '</identificacaoCliente>' + CRLF
		cMsgWS += '			<servico>' +'ORDEM_COMPRA'+ '</servico>' + CRLF
		cMsgWS += '			<dataHora>' +dDatabase+ ' ' + time() + '</dataHora>' + CRLF
		cMsgWS += '			<empresaOrigem>'  +cFilAnt+ '</empresaOrigem>' + CRLF
		cMsgWS += '			<sistemaOrigem>' +cPssw+ '</sistemaOrigem>' + CRLF
		cMsgWS += '			<empresaDestino>1</empresaDestino>' + CRLF //Irão enviar essa informação PENDENTE MV
		cMsgWS += '			<sistemaDestino>1</sistemaDestino>' + CRLF //Irão enviar essa informação PENDENTE MV
		cMsgWS += '			<usuario>' +cUsuario+ '</usuario>' + CRLF //Irão enviar essa informação PENDENTE MV
		cMsgWS += '			<senha>' +cUsuario+ '</senha>' + CRLF //Irão enviar essa informação PENDENTE MV
		cMsgWS += '		</Cabecalho>' + CRLF
		cMsgWS += '		<OrdemCompra>' + CRLF
		cMsgWS += '			<idIntegracao>89754</idIntegracao>' + CRLF //PK da Entradaa, penso que poderiamos enviar o IDINT da SC1
		cMsgWS += '			<operacao>' +cOperMV+ '</operacao>' + CRLF
		//cMsgWS += '			<codigoOrdemCompra>25180</codigoOrdemCompra>' + CRLF
		cMsgWS += '			<codigoOrdemCompraDePara>' +SC7->C7_NUM+ '</codigoOrdemCompraDePara>' + CRLF 
		cMsgWS += '			<dataHoraEmissao>' +dDatabase+ ' ' + time() + '</dataHoraEmissao>' + CRLF
		//cMsgWS += '			<dataInicioPrevEntrega>' +dDatabase+ '</dataInicioPrevEntrega>
		//cMsgWS += '			<dataFinalPrevEntrega>' +SC7->C7_DATPRF+ '/dataFinalPrevEntrega>
		//cMsgWS += '			<codigoSolicCompra>637</codigoSolicCompra>
		cMsgWS += '			<codigoSolicCompraDePara>' +SC7->C7_NUMSC+ '<codigoSolicCompraDePara/>' + CRLF
		//cMsgWS += '			<numeroEmpenho>1</numeroEmpenho>
		//cMsgWS += '			<codigoEstoque>2</codigoEstoque>
		cMsgWS += '			<codigoEstoqueDePara>' +SC7->C7_LOCAL+ '</codigoEstoqueDePara>' + CRLF
		//cMsgWS += '			<descEstoque>' +Posicione('NNR')+ '</descEstoque>
		cMsgWS += '			<codigoFornecedor>80</codigoFornecedor>
		cMsgWS += '			<codigoFornecedorDePara>85</codigoFornecedorDePara>
		cMsgWS += '			<descFornecedor>DESCRICAO FORNECEDOR</descFornecedor>
		cMsgWS += '			<cgcCpf>8734741000108</cgcCpf>
		cMsgWS += '			<codigoCondicaoPagamento>32</codigoCondicaoPagamento>
		cMsgWS += '			<codigoCondicaoPagamentoDePara>32</codigoCondicaoPagamentoDePara>
		cMsgWS += '			<descCondicaoPagamento>30/45/60 DIAS</descCondicaoPagamento>
		cMsgWS += '			<tipoFrete>C</tipoFrete>
		cMsgWS += '			<tipoFreteDePara>151</tipoFreteDePara>
		cMsgWS += '			<descTipoFrete>CIF</descTipoFrete>
		cMsgWS += '			<valorPercentualFrete>10</valorPercentualFrete>
		cMsgWS += '			<valorFrete>50,00</valorFrete>
		cMsgWS += '			<valorPercentualIpi>0,15</valorPercentualIpi>
		cMsgWS += '			<valorIpi>0,50</valorIpi>
		cMsgWS += '			<valorPercentualIcms>0,50</valorPercentualIcms>
		cMsgWS += '			<valorIcms>0,90</valorIcms>
		cMsgWS += '			<valorPercentualDesconto>0</valorPercentualDesconto>
		cMsgWS += '			<valorDesconto>0</valorDesconto>
		cMsgWS += '			<valorTotalNota>70991,36</valorTotalNota>
		cMsgWS += '			<dataAutorizacao>2009-10-29</dataAutorizacao>
		cMsgWS += '			<codigoUsuarioAutorizador>ANDERSONF</codigoUsuarioAutorizador>
		cMsgWS += '			<codigoUsuarioAutorizadorDePara>12135</codigoUsuarioAutorizadorDePara>
		cMsgWS += '			<descUsuarioAutorizador>ANDERSONF</descUsuarioAutorizador>
		cMsgWS += '			<descOrdemCompra>OBERVAÇÕES</descOrdemCompra>
		cMsgWS += '			<tipoPedido>P</tipoPedido>
		cMsgWS += '			<tipoSituacao>A</tipoSituacao>
		cMsgWS += '			<autorizado>S</autorizado>
		cMsgWS += '			<respondida>S</respondida>
		cMsgWS += '			<emailEnviadoFornecedor>N</emailEnviadoFornecedor>
		cMsgWS += '			<tipoCategoria/>


		cMsgWS += '		</OrdemCompra>
		cMsgWS += '	</Mensagem>
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
