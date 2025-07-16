#Include "TOTVS.ch"
#Include "Protheus.ch"

#Define cTitApp "Integração Documento de Entrada MV"

/*/{Protheus.doc} MT094END
Envio de documento de entrada para o MV - GAP-15
@version V 1.00
@author Tiengo
@since 28/05/2025
@See https://tdn.totvs.com/pages/releaseview.action?pageId=6085406
@return logical, Verdadeiro se tudo ok
/*/

User Function IntDocMV(nOPC, cMsgErr)

	Local lRet        		:= .T.
	Local cUrl              := SuperGetMV("UC_URLMV",.F.,"")               // URL do Webservice
	//Local cPath             := ""                                        // esse vai ser específico para cada aplicação, colocar fixo
	Local cUsuario          := SuperGetMV("UC_USERMV",.F.,"")              // Usuário do webservice
	Local cPssw             := SuperGetMV("UC_PSSWMV",.F.,"")              // Senha do webservice
	//Local cIDCliente        := SuperGetMV("UC_IDCLIMV",.F.,"")             // Id do Cliente na MV
	Local cMsgWS            := ""
	Local cOperMV           := ""
	Local oLog        		:= Nil
	Local jAuxLog     		:= Nil
	Local cMensagEr		  	:= ""

	SD1->(DbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	If SD1->(MsSeek(FWxFilial('SD1')+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))

		//Verifica se a SC veio do MV
		If Empty(SD1->D1_PEDIDO)
			Conout("IntDocMV: Documento sem Pedido de Compra!")
			Return(.T.)
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

		oLog    := CtrlLOG():New()
		jAuxLog := JsonObject():New()
		If ! oLog:SetTab("SZL")
			U_AdminMsg("[PrepSendFor] " + DToC(Date()) + " - " + Time() + " -> " + oLog:GetError())
			Return (.T.)
		EndIf

		cOperMV := "I"

		//Montando XML para envio ao MV
		cMsgWS := ' ?xml version="1.0" encoding="ISO-8859-1"?>' + CRLF
		cMsgWS += '	<Mensagem>' + CRLF
		cMsgWS += '		<Cabecalho>' + CRLF
		cMsgWS += '       <mensagemID>'+xIDInt()+'</mensagemID>' + CRLF
		cMsgWS += '			<versaoXML>1</versaoXML>' + CRLF
		cMsgWS += '			<identificacaoCliente>' + FWSM0Util():GetSM0Data(cEmpAnt , cFilAnt , { "M0_CGC" })[1][2]  + '</identificacaoCliente>' + CRLF
		cMsgWS += '			<servico>' +'NOTA_ESTOQUE'+ '</servico>' + CRLF
		cMsgWS += '			<dataHora>' +ddatabase+ ' ' + time() + '</dataHora>' + CRLF
		cMsgWS += '			<empresaOrigem>'  +cFilAnt+ '</empresaOrigem>' + CRLF
		cMsgWS += '			<sistemaOrigem>' +cPssw+ '</sistemaOrigem>' + CRLF
		cMsgWS += '			<empresaDestino>1</empresaDestino>' + CRLF //Irão enviar essa informação PENDENTE MV
		cMsgWS += '			<sistemaDestino>1</sistemaDestino>' + CRLF //Irão enviar essa informação PENDENTE MV
		cMsgWS += '			<usuario>' +cUsuario+ '</usuario>' + CRLF //Irão enviar essa informação PENDENTE MV
		cMsgWS += '			<senha>' +cUsuario+ '</senha>' + CRLF //Irão enviar essa informação PENDENTE MV
		cMsgWS += '		</Cabecalho>' + CRLF
		cMsgWS += '		<NotaFiscal>' + CRLF
		cMsgWS += '			<idIntegracao>89754</idIntegracao>' + CRLF //PK da Entradaa, penso que poderiamos enviar o IDINT da SC1
		cMsgWS += '			<operacao>' +cOperMV+ '</operacao>' + CRLF
		//cMsgWS += '			<codigoEntradaProduto>25180</codigoEntradaProduto>' + CRLF
		cMsgWS += '			<codigoEntradaProdutoDePara>342</codigoEntradaProdutoDePara>' + CRLF // PK da Entrada me parece redundante
		cMsgWS += '			<tipoEntrega><tipoEntrega/>' + CRLF // T ou P Se é total ou parcial, recever numa proxima reunião se iremos chumbar para T = total
		//cMsgWS += '			<codigoTipoDocumento><codigoTipoDocumento/>' + CRLF
		cMsgWS += '			<codigoTipoDocumentoDePara>' +'STRING'+ '</codigoTipoDocumentoDePara>' + CRLF //Esqueci de ver quais são os tipos
		//cMsgWS += '			<descTipoDocumento>NOTA FISCAL</descTipoDocumento>' + CRLF
		cMsgWS += '			<numeroDocumento>' +SD1->D1_DOC+ '</numeroDocumento>' + CRLF
		cMsgWS += '			<numeroSerie>' +SF1->F1_SERIE+ '</numeroSerie>' + CRLF
		cMsgWS += '			<codigoCfop>' +Val(SD1->D1_CF)+ '</codigoCfop>' + CRLF
		cMsgWS += '			<numeroCfop>' +Val(SD1->D1_CF)+ '</numeroCfop>' + CRLF
		//cMsgWS += '			<descCfop>COMPRA PARA COMERCIALIZAÇÃO</descCfop>
		cMsgWS += '			<dataEmissao>'+ SF1->F1_EMISSAO +'</dataEmissao>' + CRLF
		cMsgWS += '			<dataEntrada>'+ SF1->F1_DTDIGIT +'</dataEntrada>' + CRLF
		cMsgWS += '			<horaEntrada>'+ time() +'</horaEntrada>' + CRLF
		cMsgWS += '			<dataConclusao>' +ddatabase+ ' ' + time() + '</dataConclusao>' + CRLF
		cMsgWS += '			<consignado>' +'N'+ '</consignado>' + CRLF //Precisa ser definido com a Mariana como vamos tratar o consignado
		//cMsgWS += '			<codigoOrdemCompra/>
		cMsgWS += '			<codigoOrdemCompraDePara>' +SD1->D1_PEDIDO+ '<codigoOrdemCompraDePara/>' + CRLF
		//cMsgWS += '			<codigoJustificativa/>
		//cMsgWS += '			<codigoJustificativaDePara>11</codigoJustificativaDePara>
		//cMsgWS += '			<descJustificativa/>
		//cMsgWS += '			<codigoSolicCompra/>
		//cMsgWS += '			<codigoSolicCompraDePara/>
		//cMsgWS += '			<codigoEstoque/>
		cMsgWS += '			<codigoEstoqueDePara>' +SD1->D1_LOCAL+ '</codigoEstoqueDePara>' + CRLF
		//cMsgWS += '			<descEstoque>DESCRICAO DO ESTOQUE</descEstoque>
		//cMsgWS += '			<codigoFornecedor/>
		cMsgWS += '			<codigoFornecedorDePara>' +SF1->F1_FORNECE+SF1->F1_LOJA+ '</codigoFornecedorDePara>' + CRLF
		//cMsgWS += '			<descFornecedor>NOME DO FORNECEDOR</descFornecedor>
		//cMsgWS += '			<cgcCpf/>
		//cMsgWS += '			<codigoCondicaoPagamento>12</codigoCondicaoPagamento>
		//cMsgWS += '			<codigoCondicaoPagamentoDePara/>
		//cMsgWS += '			<descCondicaoPagamento>CONDICAO DE PAGAMENTO</descCondicaoPagamento>
		//cMsgWS += '			<tipoFrete/>
		cMsgWS += '			<tipoFreteDePara>' +SF1->F1_TPFRETE+ '</tipoFreteDePara>' + CRLF
		//cMsgWS += '			<descTipoFrete>CIFA</descTipoFrete>

		//Se for CIF, o valor do frete é incluiso na nota
		If SF1->F1_TPFRETE == 'C'
			cMsgWS += '          <incluirFreteNota>'+ 'S' +'</incluirFreteNota>' + CRLF
		Else
			cMsgWS += '          <incluirFreteNota>'+ 'N' +'</incluirFreteNota>' + CRLF
		Endif

		//cMsgWS += '			<valorPercentualFrete>1</valorPercentualFrete>
		//cMsgWS += '			<valorFrete>2</valorFrete>
		//cMsgWS += '			<tipoEntrega>T</tipoEntrega>
		//cMsgWS += '			<valorPercentualIpi>3</valorPercentualIpi>
		//cMsgWS += '			<valorIpi>4</valorIpi>
		//cMsgWS += '			<valorPercentualIcms>5</valorPercentualIcms>
		//cMsgWS += '			<valorIcms>6</valorIcms>
		//cMsgWS += '			<valorPercentualDesconto>7</valorPercentualDesconto>
		//cMsgWS += '			<valorDesconto>8</valorDesconto>
		//cMsgWS += '			<valorTotalNota>49,14</valorTotalNota>
		//cMsgWS += '			<valorBaseSubsTributaria/>
		//cMsgWS += '			<valorCalculoSubsTributaria/>

		//Busca títulos na SE2 relacionados à nota
		cMsgWS += '			<listaDuplicata>' + CRLF
		cChave := SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC
		SE2->(DbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
		If SE2->(MsSeek(FWxFilial('SE2')+cChave))
			While ! SE2->(Eof()) .and. SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO) == cChave
				cMsgWS += '             <Duplicata>' + CRLF
				cMsgWS += '                <numeroDuplicata>' +SE2->E2_PARCELA+ '</parcelaDuplicata>' + CRLF
				cMsgWS += '                <dataDuplicata>' +SE2->E2_VENCREA+ '</dataVencimento>' + CRLF
				cMsgWS += '                <valorTotalDuplicata>' +Str(SE2->E2_VALOR,12,3)+ '</valorTotalDuplicata>' + CRLF
				cMsgWS += '				</Duplicata>' + CRLF
				SE2->(DbSkip())
			Enddo
		Endif

		//Percorre os itens da nota
		cMsgWS += '	<listaProduto>
		While ! SD1->(Eof()) .and. SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
			cMsgWS += '             <Produto>' + CRLF
			cMsgWS += '                <operacao>' +cOperMV+ '</operacao>' + CRLF
			cMsgWS += '                <codigoProdutoDePara>' +SD1->D1_COD+ '</codigoProdutoDePara>' + CRLF
			cMsgWS += '                <quantidade>' +SD1->D1_QUANT+ '</quantidade>' + CRLF
			//cMsgWS += '					<codigoEspecieDePara/>
			//cMsgWS += '					<descEspecie>DESCRICAO DA ESPECIE</descEspecie>
			//cMsgWS += '					<codigoClasseDePara/>
			//cMsgWS += '					<descClasse>DESCRICAO DA CLASSE</descClasse>
			//cMsgWS += '					<codigoSubClasseDePara/>
			//cMsgWS += '					<descSubClasse>DESCRICAO DA SUB CLASSE</descSubClasse>
			cMsgWS += '                <codigoUnidadeProdutoDePara>' +SD1->D1_UM+ '</codigoUnidadeProdutoDePara>' + CRLF
			cMsgWS += '				   <codigoEmbalagemDePara>' +SD1->D1_SEGUM+ '<codigoEmbalagemDePara/>' + CRLF
			cMsgWS += '				   <fator>' +Posicione('SB1', 1, FWxFilial('SB1')+SD1->D1_COD, B1_CONV)+ '</fator>' + CRLF
			cMsgWS += '                <valorUnitario>' +SD1->D1_VUNIT+ '</valorUnitario>' + CRLF
			//cMsgWS += '					<valorCustoReal>16,38</valorCustoReal>
			//cMsgWS += '					<valorTotalCustoReal>16,38</valorTotalCustoReal>
			//cMsgWS += '					<valorPercentualIssProduto>0</valorPercentualIssProduto>
			//cMsgWS += '					<valorIssProduto>0</valorIssProduto>
			//cMsgWS += '					<valorPercentualIpiProduto>0</valorPercentualIpiProduto>
			//cMsgWS += '					<valorIpiProduto>0</valorIpiProduto>
			//cMsgWS += '					<quantidadeAtendida>3</quantidadeAtendida>
			cMsgWS += '				   <quantidadeEntradaTotal>' +SD1->D1_QUANT+ '</quantidadeEntradaTotal>' + CRLF
			cMsgWS += '                <quantidade>' +SD1->D1_QUANT+ '</quantidade>' + CRLF
			cMsgWS += '                <valorTotal>' +SD1->D1_TOTAL+ '</valorTotal>' + CRLF
			cMsgWS += '				   <listaLoteProduto>
			cMsgWS += '				   		<LoteProduto>
			cMsgWS += '							<codigoLote>' +SD1->D1_LOTECTL+ '</codigoLote>' + CRLF
			cMsgWS += '							<quantidadeEntrada>' +SD1->D1_QUANT+ '</quantidadeEntrada>' + CRLF
			cMsgWS += '							<dataValidade>' +SD1->D1_DTVALID+ '</dataValidade>' + CRLF
			cMsgWS += '							<descMarcaFabricante>' +Posicione('SB1', 1, FWxFilial('SB1')+SD1->D1_COD, B1_CONV)+ '</descMarcaFabricante>' + CRLF //Onde conseguir a marca do lote ?
			cMsgWS += '						</LoteProduto>
			cMsgWS += '					</listaLoteProduto>
			cMsgWS += '             </Produto>' + CRLF
			SD1->(DbSkip())
		Enddo
		cMsgWS += '			</listaProduto>
		cMsgWS += '		</NotaFiscal>
		cMsgWS += '	</Mensagem>
		//Cria o objeto WSDL
		oWsdl := TWsdlManager():New()
		oWsdl:nTimeout := 10

		//Tenta fazer o Parse da URL
		lRet := oWsdl:ParseURL(cURL)

		If ! lRet

			cMsgErr   += "SF1: "+SF1->F1_DOC+ ' ' +SF1->F1_SERIE+ ' ' +SF1->F1_FORNECE+ ' ' +SF1->F1_LOJA+" - " + oWsdl:cError
			cMensagEr += "SF1: "+SF1->F1_DOC+ ' ' +SF1->F1_SERIE+ ' ' +SF1->F1_FORNECE+ ' ' +SF1->F1_LOJA+" - " + oWsdl:cError

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
			jAuxLog["jsonbod"] := cMensagEr
			jAuxLog["jsonret"] := AnswerFormat(606, "Erro ParseURL: ", cMensagEr)

			If ! oLog:AddItem(jAuxLog)
				U_AdminMsg("[PrepSendFDoc] " + DToC(dDataBase) + " - " + Time() + " -> " + cMensagEr, IsBlind())
			Endif

			lContinua := .F.

		EndIf

		If lContinua

			//Define a operação
			aOps := oWsdl:ListOperations()
			lRet := oWsdl:SetOperation("___FALTA_DEFINIR_OPERACAO___")

			If !lRet

				cMsgErr   += "SF1: "+SF1->F1_DOC+ ' ' +SF1->F1_SERIE+ ' ' +SF1->F1_FORNECE+ ' ' +SF1->F1_LOJA+" - " + oWsdl:cError
				cMensagEr += "SF1: "+SF1->F1_DOC+ ' ' +SF1->F1_SERIE+ ' ' +SF1->F1_FORNECE+ ' ' +SF1->F1_LOJA+" - " + oWsdl:cError

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
				jAuxLog["jsonbod"] := cMensagEr
				jAuxLog["jsonret"] := AnswerFormat(606, "Erro SetOperation: ", cMensagEr)

				If ! oLog:AddItem(jAuxLog)
					U_AdminMsg("[PrepSendDoc] " + DToC(dDataBase) + " - " + Time() + " -> " + cMensagEr, IsBlind())
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
				SF1->(RecLock('SF1',.F.))
				SF1->F1_XSTREQ := '0'
				SF1->F1_XTPREQ := Iif(nOPC == 3, '1', '4')
				SF1->(MsUnlock())

				cMsgErr   += "SF1: "+SF1->F1_DOC+ ' ' +SF1->F1_SERIE+ ' ' +SF1->F1_FORNECE+ ' ' +SF1->F1_LOJA+" - " + oWsdl:cError
				cMensagEr += "SF1: "+SF1->F1_DOC+ ' ' +SF1->F1_SERIE+ ' ' +SF1->F1_FORNECE+ ' ' +SF1->F1_LOJA+" - Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode + " - Erro SendSoapMsg: " + oWsdl:cError

				jAuxLog["status"]  := "0"
				jAuxLog["idinteg"] := ""
				jAuxLog["nomapi"]  := "PrepSendFDoc"
				jAuxLog["rotina"]  := "PrepSendFDoc"
				jAuxLog["tabela"]  := "SF1"
				jAuxLog["recno"]   := 0
				jAuxLog["data"]    := DToS(dDataBase)
				jAuxLog["hora"]    := Time()
				jAuxLog["msgresp"] := "error"
				jAuxLog["msgerr"]  := "Erro SendSoapMsg"
				jAuxLog["jsonbod"] := cMensagEr
				jAuxLog["jsonret"] := AnswerFormat(606, "Erro na define da operação", cMensagEr)

				If ! oLog:AddItem(jAuxLog)
					U_AdminMsg("[PrepSendFDoc] " + DToC(dDataBase) + " - " + Time() + " -> " + cMensagEr, IsBlind())
				Endif

			Else
				//Informo no campo que a operação de integração foi bem sucedida e se foi uma inclusão ou classificação
				SF1->(RecLock('SF1',.F.))
				SF1->F1_XSTREQ := '1'
				SF1->F1_XTPREQ := Iif(nOPC == 3, '1', '4')
				SF1->(MsUnlock())

				cMsgErr   += "SF1: "+SF1->F1_DOC+ ' ' +SF1->F1_SERIE+ ' ' +SF1->F1_FORNECE+ ' ' +SF1->F1_LOJA+" - Sucesso!"
				cMensagEr += "SF1: "+SF1->F1_DOC+ ' ' +SF1->F1_SERIE+ ' ' +SF1->F1_FORNECE+ ' ' +SF1->F1_LOJA+" - Sucesso!

				jAuxLog["status"]  := "1"
				jAuxLog["idinteg"] := ""
				jAuxLog["nomapi"]  := "PrepSendDoc"
				jAuxLog["rotina"]  := "PrepSendDoc"
				jAuxLog["tabela"]  := "SF1"
				jAuxLog["recno"]   := 0
				jAuxLog["data"]    := DToS(dDataBase)
				jAuxLog["hora"]    := Time()
				jAuxLog["msgresp"] := "Sucesso"
				jAuxLog["msgerr"]  := ""
				jAuxLog["jsonbod"] := cMensagEr
				jAuxLog["jsonret"] := AnswerFormat(201, "Integração bem sucecidade!", cMensagEr)

				If ! oLog:AddItem(jAuxLog)
					U_AdminMsg("[PrepSendFDoc] " + DToC(dDataBase) + " - " + Time() + " -> " + cMensagEr, IsBlind())
				Endif

			EndIf
		EndIf
	Endif

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
