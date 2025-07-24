#Include 'Protheus.ch'
#Include "topconn.ch"
#INCLUDE "TOTVS.CH"
#include 'FWCommand.ch'

/*/{Protheus.doc} FSLIBPLE
Funcoes relacionadas ao processo de integração Pleres
A Função de nome FSLIBPLE nunca será implementada

@type function
@author Gustavo Barcelos
@since 12/01/2015
@version 1.0
@example
(examples)
@see (links_or_references)
/*/

User Function FSLIBPLE()

Return


/*/{Protheus.doc} FSXML2ARR
Rotina que transforma cada tag do XML em um array específico.

@type function
@author gustavo.barcelos
@since 13/01/2016
@version 1.0

@param nOpc, numeric, opção a ser executada: 1 = inclusão; 2 = estorno.
@param cXml, character, XML transmitido para o WebService com as informações a serem cadastradas.
@param cFil, character, Filial convertida no padrão do sistema Microsiga Protheus.
@param aFatura, array, Array que irá receber as informações da tag <Fatura>.
@param aPedido, array, Array que irá receber as informações da tag <Pedido>.
@param aCliente, array, Array que irá receber as informações da tag <Cliente>.
@param aItensPedido, array, Array que irá receber as informações da tag <ItensPedido>.
@param aPagam, array, Array que irá receber as informações da tag <Pagamentos>.
@param cMsg, character, Mensagem que será transmitida caso ocorra ERRO.

@return lRet, boolean, .T. = arquivo carregado com sucesso e array carregados; .F. = falha no carregamento do XML. 

/*/

User Function FSXML2ARR(nOpc, cXml, cFil, aFatura, aPedido, aCliente, aItensPedido, aPagam, cMsg, cCusto)

	Local cError  	:= ""
	Local cWarning	:= ""
	Local aItensAux	:= {}
	Local aPagAux		:= {}
	Local oXml			:= Nil
	Local lRet			:= .T.
	Local oXmlFat		:= Nil
	Local oXmlPed		:= Nil
	Local oXmlCli		:= Nil
	Local oXmlItm		:= Nil
	Local oXmlPag		:= Nil
	Local cFindCC 		:= ""
	//	Local nQuantI		:= 0
	//hfp Local nQuantP		:= 0
	//hfp Local nPosCli		:= 0
	//hfp Local nPos			:= 0
	Local nValPG		:= 0
	Local nValPV		:= 0
	Local nValIt		:= 0
	Local nParce		:= 0
	Local cCodCli		:= ""
	Local cLojCli		:= ""
	Local cTes			:= ""
	Local cTipFat		:= AllTrim( SubStr(cXml, at("<TipoFaturamento>", cXml) + 17, at("</TipoFaturamento>", cXml) - ( at("<TipoFaturamento>", cXml) + 17 ) ) )
	//hfp Local cTipCli		:=  ""
	//Local cCondPg		:= ""
	Local cSerProd	:= Iif(cTipFat == "C", GetMV("ES_SERCON"), SubStr(cXml, at("<CodEspec>", cXml) + 10, at("</CodEspec>", cXml) - ( at("<CodEspec>", cXml) + 10 ) ) )
	Local nF := 0, nC := 0, nP := 0, nI := 0, nPg := 0, nIa := 0, nPGa := 0
	Local aArea		:= {GetArea(), SX3->(GetArea()) , SA1->(GetArea())}
	//	Local cFilCdb	:= "00201SP0001|00201SP0002|00201SP0003|00201SP0004|00201SP0005|00201SP0006|00201SP0007|00201SP0008|00201SP0009|00201SP0010|00201SP0011|00402SP0001|00201SP0012|00201SP0013|00201SP0014|00201SP0015|00201SP0016|00201SP0017|00201SP0018|00201SP0019|00201SP0020|"
	Local lPrdMot	:= .F.
	Local cNovoProd	:= ""
	//incluído bloco abaixo [Mauro Nagata, www.compila.com.br, 20200903]
	Local lDPCServ
	Local cNomFil
	Local cAtendto
	//fim bloco [Mauro Nagata, www.compila.com.br, 20200903]
	//incluído bloco abaixo [Mauro Nagata, www.compila.com.br, 20200911]
	// hfp Local cUF

	//ajustes VOucher
	Local lPrdVouch 	:= .F.  		//hfp - www.compila.com.br - voucher
	Local aAllVouch	:= {{""}} 	//hfp - www.compila.com.br - voucher

	//Gera o Objeto XML ref. ao script
	oXml := XmlParser( cXml, "_", @cError, @cWarning )

	//Testa se XML foi carregado
	If ( oXml == NIL )
		cMsg := "Falha ao gerar Objeto XML : "+cError+" / "+cWarning
		lRet:= .F.
	Endif

	If lRet

		If nOpc == 1

			//-------------------------------------------------------------------------------

			//Carrega informações da tag <Fatura>
			oXmlFat:= XmlChildEx(oXml:_INTEGRACAO, "_FATURA")

			For nF := 1 to XmlChildCount(oXmlFat)
				aAdd(aFatura, {UPPER(Alltrim(XmlGetChild(oXmlFat, nF):REALNAME)),Alltrim(XmlGetChild(oXmlFat, nF):TEXT)})
			Next nF

			//-------------------------------------------------------------------------------

			//Carrega informações da tag <Cliente>
			oXmlCli:= XmlChildEx(oXml:_INTEGRACAO, "_CLIENTE")

			For nC := 1 to XmlChildCount(oXmlCli)
				//Caso seja tag <Complemento>, concatena dados ao campo A1_END (Endereco)
				/*
				If UPPER(Alltrim(XmlGetChild(oXmlCli, nC):REALNAME)) == "COMPLEMENTO"
					nPosCli := aScan(aCliente, {|X| X[1] == "ENDERECO"})
					aCliente[nPosCli][2] := aCliente[nPosCli][2] + " " + Alltrim(XmlGetChild(oXmlCli, nC):TEXT)
				Else
					//Grava array
					aAdd(aCliente, {UPPER(Alltrim(XmlGetChild(oXmlCli, nC):REALNAME)) ,  Alltrim(XmlGetChild(oXmlCli, nC):TEXT) } )
				EndIf
				*/
				aAdd(aCliente, {UPPER(Alltrim(XmlGetChild(oXmlCli, nC):REALNAME)) ,  Alltrim(XmlGetChild(oXmlCli, nC):TEXT) } )
			Next nC

			//Acrescenta dados de Código e Loja no padrão Pleres (Codigo Cliente = oito primeiros digitos do CPJ ou CNPJ; Loja Cliente = quatro digitos do 9º ao 12º do CPJ ou CNPJ)
			cCodCli	:= Left( aCliente[ aScan( aCliente, {|X| X[1] == "CPFCNPJ" } ) ][2], 8 )
			cLojCli	:= SubStr( aCliente[ aScan( aCliente, { |X| X[1] == "CPFCNPJ" } ) ][2], 9, 4 )

			aAdd( aCliente, { "A1_COD"		, cCodCli } )
			aAdd( aCliente, { "A1_LOJA"	, cLojCli } )
			aAdd( aCliente, { "A1_NREDUZ"	, aCliente[ aScan( aCliente, { |X| X[1] == "NOME" } ) ][2] } )
			aAdd( aCliente, { "A1_NATUREZ", IIF( LEN( ALLTRIM( M->A1_CGC ) ) == 14, GetMV( "ES_NATFINJ" ), GetMV( "ES_NATFINC" ) ) } )

			aAdd( aCliente, { "A1_TIPO"	, "F" } )
			//incluído bloco abaaixo [Mauro Nagata, www.compila.com.br, 20200911]
			//aAdd( aCliente, { "A1_TIPO"	, If( aCliente[ aScan( aCliente, { |x| x[1] == "UF" } ) ] [2] = "EX", "X", "F" )
			aAdd( aCliente, { "A1_CODMUN"	, "" } )
			aAdd( aCliente, { "A1_PFISICA", "" } )
			aAdd( aCliente, { "A1_CODPAIS", "01058" } )
			//fim bloco [Mauro Nagata, www.compila.com.br, 20200911]

			// ***************************************************************************************
			//preapara os dados VERIFICANDO SE 'EX'    --- 20210315 HFP -COMPILA
			// conforme solicitado, estava dando erro no xml, quando o cliente era exportacao, mas
			// estava fixado acima o codigo 01058.
			// **************************************************************************************
			cTpPessoa	:= If( aCliente[ aScan( aCliente, {|X| X[1] == "UF" } ) ][2] = "EX", "X", If( Len( AllTrim( aCliente[ aScan( aCliente, {|X| X[1] == "CPFCNPJ" } ) ][2] ) ) == 14, "J", "F" ) )

			If cTpPessoa = "X"

				aCliente[ aScan( aCliente, { |X| X[1] == "A1_TIPO" } )	]	[2] := cTpPessoa
				aCliente[ aScan( aCliente, { |X| X[1] == "A1_CODPAIS" } )]	[2] := "02496"  //estados unidos

			ENDIF


			//Prepara array para ser usado em MSExecAuto
			aCliente := FSDadosArr( aCliente, 1 )

			//-------------------------------------------------------------------------------

			//Carrega informações da tag <Pagamentos>
			If at("<Pagamentos>",cXml) > 0
				oXmlPag := XmlChildEx(oXML:_INTEGRACAO:_PAGAMENTOS, "_PAGAMENTO")

				If oXmlPag <> Nil
					//Caso retorno seja Array, significa que possui mais de um item de pagamento e percorre todos os itens
					If VALTYPE(oXmlPag) == "A"
						For nPg := 1 to LEN(oXmlPag)
							For nPGa := 1 to XmlChildCount(oXmlPag[nPg])
								If UPPER(Alltrim(XmlGetChild(oXmlPag[nPg], nPGa):REALNAME)) == "VALOR"
									nValPG += Val( Alltrim(XmlGetChild(oXmlPag[nPg], nPGa):TEXT) )
								EndIf
								If UPPER(Alltrim(XmlGetChild(oXmlPag[nPg], nPGa):REALNAME)) == "QTDEPARCELAS"
									nParce += Val( Alltrim(XmlGetChild(oXmlPag[nPg], nPGa):TEXT) )
								EndIf
								aAdd(aPagAux, {UPPER(Alltrim(XmlGetChild(oXmlPag[nPg], nPGa):REALNAME)),Alltrim(XmlGetChild(oXmlPag[nPg], nPGa):TEXT)})
							Next nPGa
							aAdd(aPagam, aPagAux)
							aPagAux := {}
						Next nPg
					Else
						For nPg := 1 to XmlChildCount(oXmlPag)
							If UPPER(Alltrim(XmlGetChild(oXmlPag, nPg):REALNAME)) == "VALOR"
								nValPG += Val( Alltrim(XmlGetChild(oXmlPag, nPg):TEXT) )
							EndIf
							If UPPER(Alltrim(XmlGetChild(oXmlPag, nPG):REALNAME)) == "QTDEPARCELAS"
								nParce += Val( Alltrim(XmlGetChild(oXmlPag, nPg):TEXT) )
							EndIf
							aAdd(aPagAux, {UPPER(Alltrim(XmlGetChild(oXmlPag, nPg):REALNAME)),Alltrim(XmlGetChild(oXmlPag, nPg):TEXT)})
						Next nPg
						aAdd(aPagam, aPagAux)
					EndIf
				EndIf

				cMsg := FSGravParc(@aPedido, aPagam, cTipFat)

				If cMsg <> ""
					lRet := .F.
				Else
					cMsg := "Pedido de Venda incluído com sucesso!"
				EndIF

			EndIf

			//-------------------------------------------------------------------------------

			//Carrega informações da tag <Pedido>
			oXmlPed:= XmlChildEx(oXml:_INTEGRACAO, "_PEDIDO")

			For nP := 1 to XmlChildCount(oXmlPed)
				If UPPER(Alltrim(XmlGetChild(oXmlPed, nP):REALNAME)) == "CNPJFILIAL"
					aAdd(aPedido, {UPPER(Alltrim(XmlGetChild(oXmlPed, nP):REALNAME)), cFil})
					//incluído bloco abaixo [Mauro Nagata, www.compila.com.br, 20200903]
				ElseIf UPPER(Alltrim(XmlGetChild(oXmlPed, nP):REALNAME)) == "NOMEFILIAL"
					cNomFil := PadR( Alltrim(XmlGetChild(oXmlPed, nP):TEXT), 100 )		//nome da filial
				Else
					//fim bloco [Mauro Nagata, www.compila.com.br, 20200903]
					aAdd(aPedido, {UPPER(Alltrim(XmlGetChild(oXmlPed, nP):REALNAME)),Alltrim(XmlGetChild(oXmlPed, nP):TEXT)})
				EndIF

				If UPPER(Alltrim(XmlGetChild(oXmlPed, nP):REALNAME)) == "ATENDIMENTO"
					aAdd(aPedido, {"C5_XATENDI",Alltrim(XmlGetChild(oXmlPed, nP):TEXT)})
				Endif

			Next nP

			SA1->( DbCloseArea() )

			//Acrescenta campos obrigatórios
			aAdd(aPedido, {"C5_CLIENTE", cCodCli})
			aAdd(aPedido, {"C5_LOJACLI", cLojCli})
			aAdd(aPedido, {"C5_TIPO", "N"})
			aAdd(aPedido, {"C5_EMISSAO", DtoS( Date() )})
			aAdd(aPedido, {"C5_XBLQ", "4"})
			aAdd(aPedido, {"C5_NATUREZ", ""})
			aAdd(aPedido, {"C5_CONDPAG", AllTrim(GetMV("ES_CONPAR")) })
			aAdd(aPedido, {"C5_TIPLIB", "1"})


			//Prepara array para ser usado em MSExecAuto
			aPedido := FSDadosArr(aPedido, 2)

			//-------------------------------------------------------------------------------

			//Carrega informações da tag <ItemPedido>
			oXmlItm := XmlChildEx(oXML:_INTEGRACAO:_ITENSPEDIDO, "_ITEMPEDIDO")

			cTes := GetMV("ES_TESCON")//IIf(cTipFat == "C", GetMV("ES_TESCON"), GetMV("ES_TESPAR"))

			lPrdMot := .F.

			lPrdVouch:=.F.  //hfp - compila - voucher
			cTpVouch	:=""  //hfp - compila - voucher

			DBSELECTAREA("SZK")
			SZK->(DBSETORDER(1)) //|

			//Caso retorno seja Array, significa que possui mais de um item de pedido de vendas e percorre todos os itens
			IF VALTYPE(oXmlItm) == "O"
				oXmlItm	:= {oXmlItm}
			ENDIF

			For nI := 1 to LEN(oXmlItm)
				nValIt := 0
				lPrdVouch:=.F. //hfp - compila - voucher
				cTpVouch	:=""	//hfp - compila - voucher

				For nIa := 1 to XmlChildCount(oXmlItm[nI])
					If UPPER(Alltrim(XmlGetChild(oXmlItm[nI], nIa):REALNAME)) == "VALOR"
						aAdd(aItensAux, {"C6_PRCVEN",Alltrim(XmlGetChild(oXmlItm[nI], nIa):TEXT)})
						nValPV += Val( Alltrim(XmlGetChild(oXmlItm[nI], nIa):TEXT) )
						nValIt += Val( Alltrim(XmlGetChild(oXmlItm[nI], nIa):TEXT) )
					EndIF

					/*----------------------------------------
						10/12/2018 - Jonatas Oliveira - Compila
						Verifica se está com produto de Motoboy
					------------------------------------------*/
					If UPPER(Alltrim(XmlGetChild(oXmlItm[nI], nIa):REALNAME)) == "CODESPEC"
						IF Alltrim(XmlGetChild(oXmlItm[nI], nIa):TEXT) == ALLTRIM(fGetMV("ES_PRDMOT", .F., "23000004")) 
							lPrdMot	:= .T.
						ENDIF 
					ENDIF 

					// *****************************************
					// hfp - Compila - Voucher
					// Tratamento para caso pedido seja VOucher, carregando os dados da 
					// parametrizacao do VOucher para Array.
					// 1- "S" é voucher **  2-cod prd vouch,	3- TES AtenVouch, 4- TES IDTranVouch
					// **************************************************************
					aAllVouch := u_FVerSZK(SM0->M0_CODIGO, cFil, "VOUCH" )  

					IF aAllVouch[1,1] == "S"

						// verifica se esta com produto voucher
						If UPPER(Alltrim(XmlGetChild(oXmlItm[nI], nIa):REALNAME)) == "CODESPEC"
							cVouPrTmp:= Alltrim(XmlGetChild(oXmlItm[nI], nIa):TEXT)  //produto do xml
							cVouPr:= Alltrim(aAllVouch[1,2])  //Alltrim(SZK->ZK_PRVOUCH)  //produto da configuracao permitida
							IF cVouPrTmp == cVouPr  //23000011
								lPrdVouch := .T.
								cTpVouch:= "ATENDI" 
							ENDIF
							
							//ELSE
							//NOVO TRATAMENTO COM AS INFORMACOES DO DIA 13/12
							//VERIFICO SE TEM A TAG <tIPO>vc</tipo>
							// O PRODUTO NAO É O MESMO POR ISSO ESSE TRATAMENTO
							cTmpX:=Upper(cXml)
							nPosTmp1 	:= At("<TIPO>",cTmpX)
							nPosTmp2 	:= At("</TIPO>",cTmpX)
							IF nPosTmp1 <> 0 //achou
								cTMP:= Substr(cTmpX,nPosTmp1,nPosTmp2-nPosTmp1)
								cTMP := StrTran(cTMP,"<TIPO>","")
								IF cTMP == "VC"
									lPrdVouch := .T.
									cTpVouch:= "IDTRAN"

								ENDIF
							ENDIF
							//ENDIF
					 	ENDIF 
					ENDIF

					aAdd(aItensAux, {UPPER(Alltrim(XmlGetChild(oXmlItm[nI], nIa):REALNAME)),Alltrim(XmlGetChild(oXmlItm[nI], nIa):TEXT)})
				
				Next nIa
				
				//incluído bloco abaixo [Mauro Nagata, www.compila.com.br, 20200901]
				//De Para Código SERViço
				//.T., permitir preencher com código serviço, conforme tabela ZZE
				//.F., não permitir preencher
				lDPCServ := fSGetMv( "AL_DPCSERV", .F., .T.)	
				If lDPCServ 
					nC5XATENDI	:= aScan( aPedido, { |x| x[1] = "C5_XATENDI" } )
					if nC5XATENDI > 0
						cAtendto 	:= aPedido[ nC5XATENDI, 2]					//atendimento
						cUnAtend		:= PadR( Substr( cAtendto, 1, At( "-", cAtendto ) - 1 ), 100 )						//unidade de atendimento

						DbSelectArea( "ZZE" )	//De Para Código de Serviço
						If DbSeek( xFilial( "ZZE" ) + cNomFil + cUnAtend )	//Nome da Filial + Unidade de Atendimento
							RecLock( "ZZE", .F. )
							cSerProd := ZZE->ZZE_CODSRV	//código do serviço
							ZZE->( MsUnlock() )
						EndIf 
					endif
				EndIf 
				//fim bloco [Mauro Nagata, www.compila.com.br, 20200901]			
								
				/*------------------------------------------------------ Augusto Ribeiro | 21/02/2020 - 4:21:36 PM
					Realiza a troca do produto caso exista parametro
				------------------------------------------------------------------------------------------*/
				cNovoProd	:= fSGetMv("AL_PROPFAT",.F.,"", cFil)
				IF !EMPTY(cNovoProd)
					cSerProd	:= cNovoProd
				ENDIF
				
				/*----------------------------------------
					16/01/2018 - Jonatas Oliveira - Compila
					Realiza tratativa Motoboy
				------------------------------------------*/
				FWLogMsg("INFO", /*cTransactionId*/, "CONOUT", /*cCategory*/, /*cStep*/, /*cMsgId*/,"****Filial PV**** " + cFil)
				//	IF ALLTRIM(cFil) $ cFilCdb
				
				FWLogMsg("INFO", /*cTransactionId*/, "CONOUT", /*cCategory*/, /*cStep*/, /*cMsgId*/,"Realiza tratativa Motoboy inicio " + dtoc(DDATABASE) + " - " +  TIME())
				IF fGetMv("ES_HABMOT",.F., .T.)//|Habilita tratativa Motoboy|  
					FWLogMsg("INFO", /*cTransactionId*/, "CONOUT", /*cCategory*/, /*cStep*/, /*cMsgId*/,"Tratativa Motoboy Habilitada")
					
					/*----------------------------------------
						30/01/2019 - Jonatas Oliveira - Compila
						Verifica se filial está habilitada para 
						Motoboy com o valor do parametro ES_VALMOT
					------------------------------------------*/
					IF !lPrdMot
						IF SZK->(DBSEEK(SM0->M0_CODIGO + cFil ))
						 	IF SZK->ZK_XMOTOB == "S" .AND. nValIt == fGetMv("ES_VALMOT",.F., 12) 
						 		lPrdMot := .T.
						 	ENDIF 
						ENDIF
					ENDIF  
					
					IF lPrdMot
						cTes := fGetMv("ES_TESMOT",.F.,"509") 
						cSerProd := fGetMV("ES_PRDMOT", .F., "23000004") 
						aAdd(aPedido, {"C5_XMOTOB", "1", NIL})//|Pedido de Motoboy|
						
						FWLogMsg("INFO", /*cTransactionId*/, "CONOUT", /*cCategory*/, /*cStep*/, /*cMsgId*/,"Tratativa Motoboy -  TES "+ cTes + " Produto: " + cSerProd) 
					ENDIF 
					 
				ENDIF 
				
				FWLogMsg("INFO", /*cTransactionId*/, "CONOUT", /*cCategory*/, /*cStep*/, /*cMsgId*/,"**** VOUCHER **** " + cFil)
				FWLogMsg("INFO", /*cTransactionId*/, "CONOUT", /*cCategory*/, /*cStep*/, /*cMsgId*/,"Realiza tratativa VOUCHER inicio " + dtoc(DDATABASE) + " - " +  TIME())

				// ***********************************************************		
				// hfp - Compila - voucher
				//		* tratamento para o tipo Voucher
				// *********************************************
				IF lPrdVouch  // no tratamento anterior é voucher?

					// pega dados de acordo com o tipo do xml
					IF cTpVouch == "ATENDI"
						cTes 		:= aAllVouch[1,3] // SZK->ZK_ATESVOU
						cSerProd := aAllVouch[1,2] // SZK->ZK_PRVOUCH

						cTmpX:=Upper(cXml)
						nPosTmp1 	:= At("<ATENDIMENTO>",cTmpX)
						nPosTmp2 	:= At("</ATENDIMENTO>",cTmpX)
						IF nPosTmp1 <> 0 //achou
							cTMP:= Substr(cTmpX,nPosTmp1,nPosTmp2-nPosTmp1)
							cTMP := StrTran(cTMP,"<ATENDIMENTO>","")
							aAdd(aPedido, {"C5_XCODVOU",cTMP, NIL})	// Pedido é de Vouche
						ENDIF

					ELSEIF cTpVouch == "IDTRAN"
						cTes 		:= aAllVouch[1,4] // SZK->ZK_ITESVOU
						
						cSerProd := cVouPrTmp  //pega o que vier no xml

						nPosTmp1 	:= At("<IDTRANSACAO>",cTmpX)
						nPosTmp2 	:= At("</IDTRANSACAO>",cTmpX)
						IF nPosTmp1 <> 0 //achou
							cTMP:= Substr(cTmpX,nPosTmp1,nPosTmp2-nPosTmp1)
							cTMP := StrTran(cTMP,"<IDTRANSACAO>","")
							aAdd(aPedido, {"C5_XCODVOU",cTMP, NIL})	// Pedido é de IDTRANS  //20211213
						ENDIF

					ENDIF

					aAdd(aPedido, {"C5_XVOUCHE", "1", NIL})	// Pedido é de Vouche

					FWLogMsg("INFO", /*cTransactionId*/, "CONOUT", /*cCategory*/, /*cStep*/, /*cMsgId*/,"Tratativa voucher -  TES "+ cTes + " Produto: " + cSerProd)

				ENDIF  //  end voucher

				//Acrescenta campos obrigatórios
				aAdd(aItensAux, {"C6_PRODUTO", cSerProd})
				aAdd(aItensAux, {"C6_TES", cTes})
				aAdd(aItensAux, {"C6_QTDVEN", "1"})
				aAdd(aItensAux, {"C6_CCUSTO", cCusto})
				aAdd(aItensAux, {"C6_QTDEMP", "0" })
				aAdd(aItensAux, {"C6_QTDOP",  "" })
				//Prepara array para ser usado em MSExecAuto
				aItensAux := FSDadosArr(aItensAux, 3)
				aAdd(aItensPedido, aItensAux)
				aItensAux := {}
			Next nI


			If nParce > GetMv("MV_NUMPARC")
				cMsg := "Número de Parcelas não pode ser maior que "+ cValToChar(GetMv("MV_NUMPARC")) +". Total de Parcelas do Pedido "+cValToChar(nParce)+"."
				lRet := .F.
			EndIf

			//-------------------------------------------------------------------------------
		Else

			//Carrega informações da tag <Estorno>
			oXmlFat:= XmlChildEx(oXml:_INTEGRACAO, "_ESTORNO")

			For nF := 1 to XmlChildCount(oXmlFat)
				aAdd(aFatura, {UPPER(Alltrim(XmlGetChild(oXmlFat, nF):REALNAME)),Alltrim(XmlGetChild(oXmlFat, nF):TEXT)})
			Next nF

			//-------------------------------------------------------------------------------

			//Carrega informações da tag <Pedido>
			oXmlPed:= XmlChildEx(oXml:_INTEGRACAO, "_PEDIDO")

			For nP := 1 to XmlChildCount(oXmlPed)
				If UPPER(Alltrim(XmlGetChild(oXmlPed, nP):REALNAME)) == "CNPJFILIAL"
					aAdd(aPedido, {UPPER(Alltrim(XmlGetChild(oXmlPed, nP):REALNAME)), cFil})
				Else
					If UPPER(Alltrim(XmlGetChild(oXmlPed, nP):REALNAME)) == "CNPJCLI"
						aAdd(aPedido, {"C5_CLIENTE", Left(Alltrim(XmlGetChild(oXmlPed, nP):TEXT), 8)})
						aAdd(aPedido, {"C5_LOJACLI", SubStr(Alltrim(XmlGetChild(oXmlPed, nP):TEXT),9,4)})
					Else
						aAdd(aPedido, {UPPER(Alltrim(XmlGetChild(oXmlPed, nP):REALNAME)),Alltrim(XmlGetChild(oXmlPed, nP):TEXT)})
					EndIf
				EndIF
			Next nP

			aPedido := FSDadosArr(aPedido, 2)

			//-------------------------------------------------------------------------------

		EndIf

	EndIf

	//-------------------------------------------------------------------------------

	aEval(aArea, {|xAux| RestArea(xAux)})

Return lRet



/*/{Protheus.doc} FSGravParc
Rotina responsável pela gravação das parcelas no pedido de venda de acordo com os dados informados na tag <pagamento>
@type function
@author gustavo.barcelos
@since 19/01/2016
@version 1.0
@param aPedido, array, Array do cabeçalho do Pedido de Vendas que receberá as informações de Parcelamento
@param aPagam, array, Array com os dados do pagamento
/*/

Static Function FSGravParc(aPedido, aPagam, cTipFat)

	Local nPgm			:= 0, nPac := 0
	Local aArea			:= GetArea()
	Local nDiaV			:= 0
	Local nParcelasCC	:= 0
	Local nParcela		:= 0
	Local cTipo			:= ""
	Local cQuery		:= ""
	Local dData			:= Date()
	Local lCC30DD		:= SuperGetMV("FS_CC30DD", NIL, .T.)
	Local nQtdDias		:= SuperGetMV("FS_CCQTDD", NIL, 30)

	//If AllTrim(cTipFat) <> "C"
	//Percorre todos os pagamentos informados no XML
	For nPgm := 1 to len(aPagam)
		cTipo := aPagam[nPgm][aScan(aPagam[nPgm], {|X| X[1] == "TIPO"})][2]
		//Caso condição de pagamento seja diferente de Cartão de Crédito, insere valor de parcela total e data de vencimento igual ao do Pedido de Vendas
		If cTipo <> "CC"
			nParcela += 1
			aAdd(aPedido, {"C5_PARC" + AllTrim(Str(nParcela)), aPagam[nPgm][aScan(aPagam[nPgm], {|X| X[1] == "VALOR"})][2]})

			If cTipo == "CH" .OR. cTipo == "FT"
				aAdd(aPedido, {"C5_DATA" + AllTrim(Str(nParcela)), aPagam[nPgm][aScan(aPagam[nPgm], {|X| X[1] == "DATAPGTO"})][2]})
			ElseIf cTipo == "CD"
				aAdd(aPedido, {"C5_DATA" + AllTrim(Str(nParcela)), DtoS(Date() + 1)})
			Else
				aAdd(aPedido, {"C5_DATA" + AllTrim(Str(nParcela)), DtoS(Date())})
			EndIf
		Else
			If !lCC30DD
				//Caso condição de pagamento seja igual a Cartão de Crédito, realiza a divisão do valor a ser pago pela quantidade de parcelas, e calcula data de vencimento
				//	baseado na quantidade de dias informado no cadastro de Administradoras Financeiras (SAE)
				cQuery += " SELECT AE_XBAND, "
				cQuery += " 			AE_COD, "
				cQuery += " 			AE_VENCTO FROM "+RetSqlName("SAE")+" "
				cQuery += " 	WHERE AE_XBAND = '"+aPagam[nPgm][aScan(aPagam[nPgm], {|X| X[1] == "CODBANDEIRA"})][2]+"' "
				cQuery += " 		AND AE_FILIAL = '"+xFilial("SAE")+"' "
				cQuery += " 		AND D_E_L_E_T_ = '' "

				TCQUERY cQuery NEW ALIAS "QRY"

				DBSelectArea("QRY")

				nDiaV := QRY->AE_VENCTO

				QRY->(DBCloseArea())

				If nDiaV == 0
					RestArea(aArea)
					Return "Não foi encontrada uma bandeira correspondente no Protheus."
				EndIF
			EndIf

			nParcelasCC	:= Val(aPagam[nPgm][aScan(aPagam[nPgm], {|X| X[1] == "QTDEPARCELAS"})][2])
			nValor			:= NoRound( Val(aPagam[nPgm][aScan(aPagam[nPgm], {|X| X[1] == "VALOR"})][2]) / nParcelasCC )

			If lCC30DD
				dData := Date()
			Else
				//Caso a data de pagamento seja menor que a data de pagamento da operadora, o vencimento deverá ser no mesmo mês; caso contrário vencimento será no mês seguinte.
				If (Day(dData) < nDiaV)
					dData := StoD( AnoMes(dData) + AllTrim( Str(nDiaV) ) )
				Else
					dData := MonthSum( StoD( AnoMes(dData) + AllTrim( Str(nDiaV) ) ), 1)
				EndIF
			EndIf

			For nPac := (nParcela + 1) to (nParcela + nParcelasCC)

				If lCC30DD
					dData := dData + nQtdDias
					aAdd(aPedido, {"C5_DATA" + AllTrim(Str(nPac)), DtoS(dData)})
				Else
					aAdd(aPedido, {"C5_DATA" + AllTrim(Str(nPac)), DtoS(dData)})
					dData := MonthSum(dData, 1)
				EndIf
				//Caso seja a última parcela, realiza o cálculo do valor de arredondamento e soma a última parcela
				If nPac == (nParcela + nParcelasCC)
					nValor := nValor + ( Val(aPagam[nPgm][aScan(aPagam[nPgm], {|X| X[1] == "VALOR"})][2]) - (nValor * nParcelasCC) )
				EndIF

				aAdd(aPedido, {"C5_PARC" + AllTrim(Str(nPac)), AllTrim(Str(nValor)) })
			Next nPac
			nParcela := nPac - 1
		EndIf
	Next nPgm


	RestArea(aArea)

Return ""

/*/{Protheus.doc} FSValidPed
Rotina responsável pela validação do Pedido de Vendas (Existência e Faturamento)
@type function
@author gustavo.barcelos
@since 15/01/2016
@version 1.0
@param cFil, character, Filial do Pedido de Vendas
@param aCabec, array, Array com os dados de cabeçalho do Pedido de Vendas
@param cMsg, character, Mensagem que deverá ser retornada em caso de erro
@return boolean, .T. = Pedido validado e libera processo; .F. = Pedido não validado e não libera processo 
/*/

User Function FSValidPed(cFil, aCabec, cMsg)

	Local lRet 					:= .T.
	Local aCabecX				:= {}
	Local aLog					:= {}
	Local nL						:= 0
	Local aArea					:= GetArea()
	Local cFilBkp				:= cFilAnt
	Local aItensX				:= {}
	Local lLiber				:= .T.
	Local nSC5Rec				:= 0
	Local cNumPed				:= ""

	Private lMsErroAuto 		:= .F.
	Private lAutoErrNoFile 	:= .T.

	cFilAnt := cFil

	If Empty(Alltrim(aCabec[aScan(aCabec, {|X| X[1] == "C5_XIDPLE"})][2]))
		lRet := .f.
		cMsg := "Pedido nao possui codigo ID Pleres!"
	Endif

	//Busca se pedido existe no sistema
	If lRet

		If FSBuscaPed( cFil , aCabec[aScan(aCabec, {|X| X[1] == "C5_XIDPLE"})][2], @aCabecX, @aItensX, @lLiber, @nSC5Rec)

			//Caso pedido exista, busca se pedido já está faturado
			If FSBuscaFat( cFil , aCabec[aScan(aCabec, {|X| X[1] == "C5_XIDPLE"})][2] )
				lRet := .F.
				cMsg := "Pedido correspondente a este ID Pleres já existente e está faturado!"

			Else
				SC5->(dbGoto(nSC5REC))
				If SC5->C5_XBLQ == '7' // Pedido preparado para faturamento
					lRet := .f.
					cMsg := "Pedido correspondente a este ID Pleres já existente e está faturado!"
				Endif

				If lRet

					SC5->(dbGoto(nSC5REC))
					If SC5->C5_XBLQ == '7' // Pedido preparado para faturamento
						lRet := .f.
						cMsg := "Pedido correspondente a este ID Pleres já existente e está faturado!"
					Else

						cNumPed:= SC5->C5_NUM

						//Caso pedido tenha sido alterado
						lMsErroAuto 		:= .F.
						lAutoErrNoFile 	:= .T.

						MATA410(aCabecX, {}, 5)

						If lMsErroAuto
							aLog 	:= GetAutoGRLog()
							cMsg	:= ""
							For nL := 1 to len(aLog)
								cMsg += aLog[nL] + chr(13) + chr(10)
							Next

							lRet := .F.

						Else

							//Caso pedido tenha sido excluído, pagamento também é excluído.
							DBSelectArea("SZ7")
							SZ7->( DBSetOrder(1) )
							SZ7->( DBSeek(cSeek:= cFil + cNumPed ) )
							While SZ7->(!Eof()) .And. cSeek == SZ7->(Z7_FILIAL+Z7_PEDIDO)
								Reclock("SZ7")
								SZ7->( DBDelete() )
								SZ7->(MSUnlock())

								SZ7->( DBSkip() )
							EndDo

							cMsg := "Pedido " + AllTrim(SC5->C5_NUM) + " excluído com sucesso!"

						EndIf
					Endif
				EndIf
			EndIF
		Else
			cMsg := "Pedido correspondente a este ID Pleres não existe no Protheus!"
		EndIf
	Endif

	RestArea(aArea)

	cFilAnt := cFilBkp

Return lRet


/*/{Protheus.doc} FSBuscaPed
Rotina que realiza a busca do pedido de vendas a partir do ID Pleres disponibilizado pelo WebService.
@type function
@author gustavo.barcelos
@since 13/01/2016
@version 1.0
@param cFil, character, Filial do pedido de vendas Pleres
@param cIdPle, character, Número do pedido de vendas Pleres
@param aCabecX, array, Informações do pedido de vendas no Protheus, deve ser usado na exclusão do pedido caso ele já exista 
@return lRet, boolean, .F. = Pedido não encontrado; .T. = Pedido encontrado
/*/

Static Function FSBuscaPed(cFil, cIdPle, aCabecX, aItensX, lLiber, nSC5REC)

	Local lRet 			:= .F.
	Local cQuery 		:= ""
	Local aItensAux	:= {}
	Local aArea			:= GetArea()

	cQuery := " SELECT R_E_C_N_O_ SC5RECNO FROM "+RetSqlName("SC5")+" "
	cQuery += " WHERE D_E_L_E_T_ = '' "
	cQuery += " AND C5_FILIAL = '" + cFil + "' "
	cQuery += " AND C5_XIDPLE = '" + cIdPle + "' "

	TCQUERY cQuery NEW ALIAS "QRY"
	DbSelectArea( "QRY" )
	QRY->( DBGoTop() )

	If !QRY->( EOF() )
		nSC5REC	:= QRY->SC5RECNO

		SC5->( dbGoto( nSC5REC ) )

		lRet := .T.
		aAdd( aCabecX, { "C5_FILIAL"	, 	SC5->C5_FILIAL	, NIL	} )
		aAdd( aCabecX, { "C5_NUM"		,	SC5->C5_NUM		, NIL	} )
		aAdd( aCabecX, { "C5_CLIENTE", 	SC5->C5_CLIENTE, NIL	} )
		aAdd( aCabecX, { "C5_LOJACLI", 	SC5->C5_LOJACLI, NIL	} )
		aAdd( aCabecX, { "C5_EMISSAO", 	SC5->C5_EMISSAO, NIL	} )

		lLiber:= !Empty( SC5->C5_LIBEROK ) .And. Empty( SC5->C5_NOTA ).And. Empty( SC5->C5_BLQ )

		SC6->(dbSetOrder(1))
		SC6->(MsSeek(cSeek:= SC5->(C5_FILIAL+C5_NUM),.T.))
		While SC6->(!Eof()) .And. cSeek==SC6->(C6_FILIAL+C6_NUM)
			aItensAux:= {}
			aAdd(aItensAux, {"C6_ITEM"		, SC6->C6_ITEM, NIL})
			aAdd(aItensAux, {"C6_PRODUTO"	, SC6->C6_PRODUTO, NIL})
			aAdd(aItensAux, {"C6_TES"		, SC6->C6_TES, NIL})
			aAdd(aItensAux, {"C6_QTDVEN"	, SC6->C6_QTDVEN, NIL})
			aAdd(aItensAux, {"C6_VALOR"	, SC6->C6_VALOR, NIL})
			aAdd(aItensAux, {"C6_PRCVEN"	, SC6->C6_PRCVEN, NIL})
			aAdd(aItensX, aItensAux)
			SC6->(dbSkip())
		EndDo
	EndIf

	QRY->(DbCloseArea())

	U_FSOrdArr(aCabecX,"SC5",.F.)
	U_FSOrdArr(aItensX,"SC6",.T.)

	RestArea(aArea)

Return lRet


/*/{Protheus.doc} FSBuscaFat
Rotina responsável por identificar se o pedido de vendas já foi faturado
@type function
@author gustavo.barcelos
@since 15/01/2016
@version 1.0
@param cFil, character, Filial do Pedido de Vendas
@param cIdPle, character, Código do ID no sistema Pleres do Pedido de Vendas
@return boolean, .T. = Pedido já faturado; .F. = Pedido não faturado 
/*/

Static Function FSBuscaFat(cFil, cIdPle)

	Local lRet 			:= .F.
	Local cQuery 		:= ""
	Local aArea			:= GetArea()
	Local cTabQry		:= GetNextAlias()

	cQuery := " SELECT C9_FILIAL, "
	cQuery += " 	C9_PEDIDO, "
	cQuery += " 	C9_ITEM, "
	cQuery += " 	C6_NUM, "
	cQuery += " 	C6_ITEM, "
	cQuery += " 	C5_NUM, "
	cQuery += " 	C5_XIDPLE, "
	cQuery += " 	C9_NFISCAL, "
	cQuery += " 	C9_SERIENF "
	cQuery += " 	FROM "+RetSqlName("SC9")+" SC9 INNER JOIN "+RetSqlName("SC6")+" SC6 "
	cQuery += " 		ON C9_FILIAL = C6_FILIAL AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM "
	cQuery += " 	INNER JOIN "+RetSqlName("SC5")+" SC5 "
	cQuery += " 		ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM "
	cQuery += " WHERE SC9.D_E_L_E_T_ = '' "
	cQuery += " AND SC5.D_E_L_E_T_ = '' "
	cQuery += " AND SC6.D_E_L_E_T_ = '' "
	cQuery += " AND C9_NFISCAL <> '' "
	cQuery += " AND C9_FILIAL = '" + cFil + "' "
	cQuery += " AND C5_XIDPLE = '" + cIdPle + "' "


	TCQUERY cQuery NEW ALIAS "QRY"
	DbSelectArea("QRY")
	QRY->(DBGoTop())

	If !QRY->(EOF())
		lRet := .T.
	EndIF

	QRY->(DbCloseArea())

	RestArea(aArea)

	//Valida se o Pedido esta na Fila para Faturamento
	cQuery := ""
	cQuery += "SELECT SC5.C5_FILIAL" + CRLF
	cQuery += ", 		SC5.C5_NUM" + CRLF
	cQuery += ", 		SC5.C5_XIDPLE" + CRLF
	cQuery += ", 		SC5.C5_XBLQ" + CRLF
	cQuery += "FROM 	" + RetSqlName("SC5") + " SC5" + CRLF
	cQuery += "WHERE 	SC5.C5_FILIAL = '" + cFil + "'" + CRLF
	cQuery += "			AND	SC5.C5_XIDPLE = '" + cIdPle + "'" + CRLF
	cQuery += "			AND 	SC5.C5_XBLQ = '7'" + CRLF
	cQuery += "			AND 	SC5.D_E_L_E_T_ <> '*'" + CRLF

	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cTabQry, .T., .T.)

	If !(cTabQry)->(Eof())
		lRet := .T.
	EndIf

	If Select(cTabQry) > 0
		(cTabQry)->(DbCloseArea())
	EndIf

Return lRet


/*/{Protheus.doc} FSAtuCli
Rotina responsável pela atualização ou inclusão do Cliente.
@type function
@author gustavo.barcelos
@since 14/01/2016
@version 1.0
@param aCliente, array, Array com os dados do cliente fornecidos pelo WebService
@param aPedido, array, Array com os dados do pedido para atualização das informações baseado no cliente
@param cMsg, character, Mensagem a ser retornada
@param lCli, boolean, T = Cliente Novo e Pessoa Jurídica; F = Cliente já existente
@param cTipo, character, Tipo de Faturamento
@return boolean, .T. = Registro atualizado/criado com sucesso; .F. = Registro não atualizado/criado
/*/

User Function FSAtuCli(aCliente, aPedido, cMsg, lCli, cTipo, aPagam)

	Local lRet			:= .F.
	Local aLog			:= {}
	Local nL				:= 0
	Local nI				:= 0
	Local cCodCli 		:= ""
	Local cLojCli 		:= ""
	Local cSitCli 		:= ""
	Local nSA1RECNO	:= 0
	//Local cTpPessoa	:= If(Len(AllTrim(aCliente[aScan(aCliente, {|X| X[1] == "A1_CGC"})][2])) == 14, "J", "F")
	Local cTpPessoa	:= If( aCliente[ aScan( aCliente, {|X| X[1] == "A1_EST" } ) ][2] = "EX", "X", If( Len( AllTrim( aCliente[ aScan( aCliente, {|X| X[1] == "A1_CGC" } ) ][2] ) ) == 14, "J", "F" ) )
	Local lAtualJur	:= SuperGetMV("FS_ATUCLIP", NIL, .F.)		//Atualiza Pessoa Juridica
	Local lAtualFis	:= SuperGetMV("FS_ATUCLIF", NIL, .T.)		//Atualiza Pessoa Fisica
	Local lAtualiza	:= .F.
	Local lContinua	:= .T.
	Local cEmail		:= ""
	Local cNat			:= ""
	Local cRecIss		:= ""

	Private lMsErroAuto 		:= .F.
	Private lAutoErrNoFile 	:= .T.

	//Valida o CNPJ/CPF do Cliente
	If lContinua
		/*
		If Empty(AllTrim(aCliente[aScan(aCliente, {|X| X[1] == "A1_CGC"})][2]))
			lContinua 	:= .F.
			cMsg		:= "CNPJ ou CPF do Cliente em Branco."
		EndIf
		*/
					//substituído bloco acima pelo abaixo [Mauro Nagata, www.compila.com.br, 20200911]
					If aCliente[ aScan( aCliente, { |X| X[1] == "A1_EST" } ) ] [2] != "EX"
						If Empty( AllTrim( aCliente[ aScan( aCliente, { |X| X[1] == "A1_CGC" } ) ] [2] ) )
							lContinua 	:= .F.
							cMsg			:= "Número de CPF/CNPJ obrigatório e não informado"
						EndIf
						//incluído bloco abaixo [Mauro Nagata, www.compila.com.br, 20200915]
					ElseIf Empty( AllTrim( aCliente[ aScan( aCliente, { |X| X[1] == "A1_CGC" } ) ] [2] ) )
						lContinua	:= .F.
						cMsg			:= "Número do passaporte/RG estrangeiro obrigatório e não informado"
						//fim bloco [Mauro Nagata, www.compila.com.br, 20200915]
					EndIf
					//fim bloco [Mauro Nagata, www.compila.com.br, 20200911]
				EndIf

				If lContinua
					If cTpPessoa == "J"
						If lAtualJur
							lAtualiza := .T.
						Else
							lAtualiza := .F.
						EndIf
					ElseIf cTpPessoa == "F"
						If lAtualFis
							lAtualiza := .T.
						Else
							lAtualiza := .F.
						EndIf
						//incluído bloco abaixo [Mauro Nagata, www.compila.com.br, 20200911]
					Else
						lAtualiza := .T.
					EndIf
					//fim bloco [Mauro Nagata, www.compila.com.br, 20200911]
				EndIf

				//Valida o Telefone do Cliente
				If lContinua
					//Tratamento para o Numero do Telefone
					aCliente[aScan(aCliente, {|X| X[1] == "A1_TEL"})][2] := StrTran(aCliente[aScan(aCliente, {|X| X[1] == "A1_TEL"})][2], "-", "")
					aCliente[aScan(aCliente, {|X| X[1] == "A1_TEL"})][2] := StrTran(aCliente[aScan(aCliente, {|X| X[1] == "A1_TEL"})][2], " ", "")

					If !Empty(aCliente[aScan(aCliente, {|X| X[1] == "A1_TEL"})][2]) .AND. Len(AllTrim(aCliente[aScan(aCliente, {|X| X[1] == "A1_TEL"})][2])) <> 8
						lContinua	:= .F.
						cMsg		:= "Telefone do Cliente invalido."
					EndIf
				EndIf

				//Valida o DDD do Cliente
				If lContinua
					If aScan(aCliente, {|X| X[1] == "A1_DDD"}) > 0
						aCliente[aScan(aCliente, {|X| X[1] == "A1_DDD"})][2] := StrTran(aCliente[aScan(aCliente, {|X| X[1] == "A1_DDD"})][2], " ", "")
						If !Empty(aCliente[aScan(aCliente, {|X| X[1] == "A1_TEL"})][2]) .AND. Empty(aCliente[aScan(aCliente, {|X| X[1] == "A1_DDD"})][2])
							lContinua	:= .F.
							cMsg		:= "DDD do Cliente invalido."
						EndIf
					EndIf
				EndIf

				//Valida o CEP do Cliente
				If lContinua
					aCliente[aScan(aCliente, {|X| X[1] == "A1_CEP"})][2] := StrTran(aCliente[aScan(aCliente, {|X| X[1] == "A1_CEP"})][2], "-", "")

					If Empty(aCliente[aScan(aCliente, {|X| X[1] == "A1_CEP"})][2]) .OR. Len(AllTrim(aCliente[aScan(aCliente, {|X| X[1] == "A1_CEP"})][2])) <> 8
						lContinua	:= .F.
						cMsg		:= "CEP do Cliente invalido."
					EndIf
				EndIf
				If lContinua
					cSpChar	:= '",;/(!$&^:<>`´)+=\%#*' + "'"
					cEmail 	:= aCliente[aScan(aCliente, {|X| X[1] == "A1_EMAIL"})][2]
					nPosArr	:= 0
					nCont		:= 0
					nI 			:= 0
					lSpChar	:= .F.

					For nI := 1 to Len(cEmail)
						If Substr(cEmail, nI, 1) == "@"
							nPosArr := nI
							nCont++
						EndIf

						If Substr(cEmail, nI, 1) $ cSpChar
							lSpChar := .T.
						EndIf
					Next nI

					//Sem arroba, arroba antes da 5 posicao, mais de uma arroba ou Caractere especial
					If nPosArr == 0 .OR. nPosArr < 3 .OR. nCont > 1 .OR. lSpChar
						lContinua	:= .F.
						cMsg			:= "E-Mail do Cliente invalido."
					EndIf
				EndIf

				If lContinua

					aCliente[aScan(aCliente, {|X| X[1] == "A1_NOME"})][2] := FwNoAccent(aCliente[aScan(aCliente, {|X| X[1] == "A1_NOME"})][2])

					//If FSBuscaCli( AllTrim( aCliente[ aScan( aCliente, {|X| X[1] == "A1_CGC" } ) ][2] ), @cCodCli, @cLojCli, @cSitCli, @nSA1RECNO )
					//substituída linha acima pela abaixo [Mauro Nagata, www.compila.com.br, 20200911]
					If FSBuscaCli( AllTrim( aCliente[ aScan( aCliente, {|X| X[1] == "A1_CGC" } ) ][2] ), @cCodCli, @cLojCli, @cSitCli, @nSA1RECNO, aCliente[ aScan( aCliente, {|X| X[1] == "A1_EST" } ) ][2])

						lCli := .F.

						SA1->(dbGoto(nSA1RECNO))

						//Quando encontrado o cliente, dados de código e loja são atualizados para os valores presentes no sistema atualmente.
						aCliente[ aScan( aCliente, {|X| X[1] == "A1_COD" } ) ][2] 	:= cCodCli
						aCliente[ aScan( aCliente, {|X| X[1] == "A1_LOJA" } ) ][2] 	:= cLojCli

						If !Empty(SA1->A1_NATUREZ)
							//Mantem a natureza ja cadastrada
							aCliente[aScan(aCliente, {|X| X[1] == "A1_NATUREZ"})][2] := SA1->A1_NATUREZ
						EndIf

						If !Empty(SA1->A1_INSCRM)
							aCliente[aScan(aCliente, {|X| X[1] == "A1_INSCRM"})][2] := SA1->A1_INSCRM
						EndIf

						//incluído bloco acima [Mauro Nagata, www.compila.com.br, 20200915]
						//If !Empty(SA1->A1_PFISICA)
						aCliente[aScan(aCliente, {|X| X[1] == "A1_PFISICA"})][2] := SA1->A1_PFISICA
						//EndIf
						//fim bloco [Mauro Nagata, www.compila.com.br, 20200915]
						//incluída linha abaixo [Mauro Nagata, www.compila.com.br, 20200911]
						aCliente[aScan(aCliente, {|X| X[1] == "A1_CODPAIS"})][2] := SA1->A1_CODPAIS

						//hfp-compila 20210326 task 21473700
						//aCliente[aScan(aCliente, {|X| X[1] == "A1_COD_MUN"})][2] := SA1->A1_COD_MUN

						If cTpPessoa = "X"
							aCliente[aScan(aCliente, {|X| X[1] == "A1_CGC"})][2] 		:= ""

							//se estrangeiro, atualizar o cliente e loja do pedido de vendas
							aPedido[aScan(aPedido, {|X| X[1] == "C5_CLIENTE"})][2]	:= cCodCli
							aPedido[aScan(aPedido, {|X| X[1] == "C5_LOJACLI"})][2]	:= cLojCli

							// conforme solicitado, estava dando erro no xml, quando o cliente era exportacao, mas
							// estava fixado acima o codigo 01058.   hfp-compila - task 21473700
							// **************************************************************************************
							//AJUSTa A1_PAIS
							aCliente[ aScan( aCliente, { |X| X[1] == "A1_PAIS" } )]	[2] := '249'

							// 20220117 HFP - Compila
							aCliente[ aScan( aCliente, { |X| X[1] == "A1_CODMUN" } ) ]	[2] := "99999"
							aCliente[ aScan( aCliente, { |X| X[1] == "A1_COD_MUN" } )]	[2] := "9999"

						EndIf
						If lAtualiza
							_aAlErro	:= {.F.}  //|  Variavel para contornar erro do Padrao ref. ao retorno do lmsErroAuto
							MSExecAuto({|x,y| Mata030(x,y)}, aCliente, 4)   // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
							If lMsErroAuto  .OR. _aAlErro[1]
								aLog 	:= GetAutoGRLog()
								cMsg	:= ""
								For nL := 1 to len(aLog)
									cMsg += aLog[nL] + chr(13) + chr(10)
								Next
							Else
								lRet := .T.
								cMsg := "Cliente atualizado com sucesso!"
							EndIf
						Else
							lRet := .T.
							cMsg := ""
						EndIf
					Else
						//incluído bloco abaixo [Mauro Nagata, www.compila.com.br, 20200911]
						If cTpPessoa = "X"
							cQrySYA := " SELECT	YA_SISEXP "
							cQrySYA += " FROM " + RetSqlName( "SYA" )+" "
							cQrySYA += " WHERE	D_E_L_E_T_ 		<> '*' "
							cQrySYA += " 			AND YA_CODGI = '" + aCliente[ aScan( aCliente, { |x| x[1] == "A1_PAIS" } ) ] [2] + "' "

							If Select("QRYSYA") > 0
								QRYSYA->(DbCloseArea())
							EndIf

							TCQUERY cQrySYA NEW ALIAS "QRYSYA"

							DbSelectArea("QRYSYA")
							QRYSYA->(DbGoTop())

							cCodPais := ""
							If !QRYSYA->(Eof())
								cCodPais := "0" + QRYSYA->YA_SISEXP
							EndIf

							QRYSYA->(DbCloseArea())

							IF  aCliente[ aScan( aCliente, { |X| X[1] == "A1_EST" } )][2] == 'EX'

								// conforme solicitado, estava dando erro no xml, quando o cliente era exportacao, mas
								// estava fixado acima o codigo 01058.   hfp-compila
								// **************************************************************************************
								//AJUSTa A1_PAIS
								aCliente[ aScan( aCliente, { |X| X[1] == "A1_PAIS" } )]	[2] := '249'

							ELSE

								aCliente[ aScan( aCliente, { |X| X[1] == "A1_CODPAIS" } )]	[2] := cCodPais

							ENDIF

							cCliEstr := GetMV( "AL_CLIESTR" )	//codigo do cliente estrangeiro
							cCliEstr := Soma1( cCliEstr )
							cCliEstr := Substr( cCliEstr, Len( cCliEstr ) - 6, 7 )
							PutMV( "AL_CLIESTR", cCliEstr )
							cCodCli 	:= "E" + cCliEstr
							cLojCli	:= "001"

							aCliente[ aScan( aCliente, { |x| x[1] == "A1_PFISICA" } )]	[2] := aCliente[ aScan( aCliente, { |X| X[1] == "A1_CGC" } ) 	]	[2]
							aCliente[ aScan( aCliente, { |x| x[1] == "A1_COD" } )		]	[2] := cCodCli
							aCliente[ aScan( aCliente, { |x| x[1] == "A1_LOJA" } )	]	[2] := "001"
							aCliente[ aScan( aCliente, { |X| X[1] == "A1_CGC" } ) 	]	[2] := ""
							aCliente[ aScan( aCliente, { |X| X[1] == "A1_INSCR" } ) 	]	[2] := ""
							aCliente[ aScan( aCliente, { |X| X[1] == "A1_CEP" } ) 	]	[2] := "00000000"
							aCliente[ aScan( aCliente, { |X| X[1] == "A1_MUN" } ) 	]	[2] := "ESTRANGEIRO"
							aCliente[ aScan( aCliente, { |X| X[1] == "A1_CODMUN" } ) ]	[2] := "99999"
							aCliente[ aScan( aCliente, { |X| X[1] == "A1_COD_MUN" } )]	[2] := "9999"
							aCliente[ aScan( aCliente, { |X| X[1] == "A1_TIPO" } )	]	[2] := cTpPessoa

							//se estrangeiro, atualizar o cliente e loja do pedido de vendas
							aPedido[aScan(aPedido, {|X| X[1] == "C5_CLIENTE"})][2]	:= cCodCli
							aPedido[aScan(aPedido, {|X| X[1] == "C5_LOJACLI"})][2]	:= cLojCli
						EndIf
						//fim bloco [Mauro Nagata, www.compila.com.br, 20200911]
						_aAlErro	:= {.F.} //|  Variavel para contornar erro do Padrao ref. ao retorno do lmsErroAuto
						MSExecAuto({|x,y| Mata030(x,y)}, aCliente, 3)   // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
						If lMsErroAuto .OR. _aAlErro[1]
							aLog 	:= GetAutoGRLog()
							cMsg 	:= ""
							For nL := 1 to len(aLog)
								cMsg += aLog[nL] + chr(13) + chr(10)
							Next
						Else
							lRet := .T.
							If SA1->A1_PESSOA == "J"
								lCli := .T.
							EndIf
							cMsg := "Cliente criado com sucesso!"
						EndIf

					EndIf

					//Atualiza informações do Pedido de Vendas
					If cTipo == "C" .AND. Empty(aPagam)
						aPedido[aScan(aPedido, {|X| X[1] == "C5_CONDPAG"})][2] := SA1->A1_COND
					EndIf

					IF(Empty(SA1->A1_NATUREZ))
						cNat :=  IIF(LEN(ALLTRIM(M->A1_CGC)) == 14,GetMV("ES_NATFINJ"),GetMV("ES_NATFINC"))
					Else
						cNat := SA1->A1_NATUREZ
					Endif


		/*----------------------------------------
		17/09/2018 - Jonatas Oliveira - Compila
		Busca natureza da tabela Customizada
		------------------------------------------*/
		DBSELECTAREA("ZZA")
		ZZA->(DBSETORDER(1))//|ZZA_FILIAL+ZZA_CODCLI+ZZA_LOJA|
		If ZZA->(DBSEEK(aPedido[aScan(aPedido, {|X| X[1] == "C5_FILIAL"})][2] + SA1->A1_COD + SA1->A1_LOJA ))
			IF !EMPTY(ZZA->ZZA_NATURE)
				cNat := ZZA->ZZA_NATURE
			ENDIF
			
			cRecIss	:= ZZA->ZZA_ISS
		Endif 		
			
		aPedido[aScan(aPedido, {|X| X[1] == "C5_NATUREZ"})][2] := cNat
		
		IF !EMPTY(cRecIss)
			nPosRecI	:= aScan(aPedido, {|X| X[1] == "C5_RECISS"})
			
			IF nPosRecI > 0 
				aPedido[ nPosRecI ][ 2 ] := cRecIss
			ELSE				
				aAdd(aPedido, {"C5_RECISS", cRecIss , NIL})
			ENDIF
			 
		ENDIF 
	Endif

Return lRet


/*/{Protheus.doc} FSDadosArr
Rotina responsável pela preparação do array para utilização em MSExecAuto
@type function
@author gustavo.barcelos
@since 14/01/2016
@version 1.0
@param aDados, array, array a ser preparado para utilizar em MSExecAuto
@param nOpcao, numeric, Opção a ser utilizada no De/Para: 1 = De/Para de Clientes; 2 = De/Para de Pedidos de Vendas (Cabeçalho); 3 = De/Para de Pedidos de Vendas (Itens).
@return array, array com os dados a serem acrescentados no array a ser utilizado na MSExecAuto
/*/

Static Function FSDadosArr(aDados, nOpcao)

	Local aOrig		:= IIf(nOpcao == 1, FSTagCli(), IIf(nOpcao == 2, FSTagPedC(), FSTagPedI() ) )
	Local aResult 	:= {}
	Local nPos		:= 0
	//hfp Local cTipo		:= ""
	Local xValor
	Local nD			:= 0
	
	For nD := 1 to len(aDados)
	
		//Testa se campo do XML está no De/Para de campos	
		If (nPos:= aScan(aOrig,{|x| Alltrim(Upper(x[2])) == aDados[nD][1] })) <> 0
			
			cCampo:= aOrig[nPos,1]
			bBloco:= aOrig[nPos,3]
			
			//Converte valor para padrão do SX3
			xValor := U_FSCnvVlr(cCampo,aDados[nD][2],.T.)
			
			//Executa bloco de código presente no cadastro do De/Para de campos
			If !Empty(bBloco)
				xValor := Eval(&bBloco, xValor)
			EndIf

			//Carrega array no padrão MSExecAuto para retorno
			Aadd(aResult, {aOrig[nPos,1], xValor, Nil})
	
		EndIf
		
	Next nD
	
	If nOpcao == 1
		
		//Ordena array de retorno de acordo com ordenação do SX3
		U_FSOrdArr(aResult,"SA1",.F.)
	
	ElseIf nOpcao == 2
		
		//Ordena array de retorno de acordo com ordenação do SX3
		U_FSOrdArr(aResult,"SC5",.F.)
	
	ElseIf nOpcao == 3
	
		//Ordena array de retorno de acordo com ordenação do SX3
		U_FSOrdArr(aResult,"SC6",.F.)
	
	EndIf

Return aResult

/*/{Protheus.doc} FSTagPedC
Rotina que prepara o De/Para de tags para ser utilizado na montagem do array de Pedido de Vendas (Cabeçalho).
@type function
@author gustavo.barcelos
@since 14/01/2016
@version 1.0
@return array, Array com as informações do De/Para
/*/

Static Function FSTagPedC()

	Local aTagCab:= {}
	Local nNumPar:= GetMv("MV_NUMPARC")
	Local cSeqPar:= "0" //Defini uma casa o sequencial alfanumerico
	Local nXi		:= 0

	Aadd(aTagCab,{"C5_FILIAL" 	,"CNPJFilial"			, "" })
	Aadd(aTagCab,{"C5_XIDPLE" 	,"IDPleres"				, "" })
	Aadd(aTagCab,{"C5_MENNOTA" ,"DescNFE"				, "" })
	Aadd(aTagCab,{"C5_XTIPFAT" ,"TipoFaturamento"	, "" })
	Aadd(aTagCab,{"C5_NUM" 	 	,"C5_NUM"				, "" })		//Campo não presente no XML, porém obrigatório
	Aadd(aTagCab,{"C5_CLIENTE" ,"C5_CLIENTE"			, "" })		//Campo não presente no XML, porém obrigatório
	Aadd(aTagCab,{"C5_LOJACLI" ,"C5_LOJACLI"			, "" })		//Campo não presente no XML, porém obrigatório
	Aadd(aTagCab,{"C5_CONDPAG" ,"C5_CONDPAG"			, "" })		//Campo não presente no XML, porém obrigatório
	Aadd(aTagCab,{"C5_EMISSAO" ,"C5_EMISSAO"			, "" })		//Campo não presente no XML, porém obrigatório
	Aadd(aTagCab,{"C5_TIPO" 	,"C5_TIPO"				, "" })		//Campo não presente no XML, porém obrigatório
	Aadd(aTagCab,{"C5_NATUREZ" ,"C5_NATUREZ"			, "" })		//Campo não presente no XML, porém obrigatório
	Aadd(aTagCab,{"C5_XBLQ"	 	,"C5_XBLQ" 				, "" })		//Campo não presente no XML, porém obrigatório
	Aadd(aTagCab,{"C5_XOBS"	 	,"C5_XOBS" 				, "" })
	Aadd(aTagCab,{"C5_XBRTLIQ"	,"C5_XBRTLIQ"			, "" })
	Aadd(aTagCab,{"C5_XATENDI"	,"C5_XATENDI"			, "" })

//Sequencia 123456789ABCD...
	For nXi:= 1 To nNumPar
		cSeqPar:= Soma1(cSeqPar)

	//C5_PARCA, C5_PARC10
		Aadd(aTagCab,{"C5_PARC"+cSeqPar, "C5_PARC"+cValToChar(nXi), "" })
		Aadd(aTagCab,{"C5_DATA"+cSeqPar, "C5_DATA"+cValToChar(nXi), "" })
	Next nXi

Return(aTagCab)


/*/{Protheus.doc} FSTagPedI
Rotina que prepara o De/Para de tags para ser utilizado na montagem do array de Pedido de Vendas (Itens).
@type function
@author gustavo.barcelos
@since 14/01/2016
@version 1.0
@return array, Array com as informações do De/Para
/*/

Static Function FSTagPedI()

	Local aTagItm:= {}

	Aadd(aTagItm,{"C6_ITEM" 		,"SeqItem"			, "" })
	Aadd(aTagItm,{"C6_VALOR" 	,"Valor"			, "" })
	Aadd(aTagItm,{"C6_PRCVEN" 	,"C6_PRCVEN"		, "" })
	Aadd(aTagItm,{"C6_TES" 		,"C6_TES"			, "" })
	Aadd(aTagItm,{"C6_PRODUTO" 	,"C6_PRODUTO"		, "" })
	Aadd(aTagItm,{"C6_QTDVEN" 	,"C6_QTDVEN"		, "" })
	Aadd(aTagItm,{"C6_QTDLIB" 	,"C6_QTDLIB"		, "" })
	Aadd(aTagItm,{"C6_CCUSTO" 	,"C6_CCUSTO"		, "" })

Return(aTagItm)


/*/{Protheus.doc} FSTagCli
Rotina que prepara o De/Para de tags para ser utilizado na montagem do array de cliente.
@type function
@author gustavo.barcelos
@since 14/01/2016
@version 1.0
@return array, Array com as informações do De/Para
/*/

Static Function FSTagCli()

	Local aTagCli:= {}

	Aadd(aTagCli,{"A1_CGC" 		,"CPFCNPJ"				, "" })
	Aadd(aTagCli,{"A1_NOME" 	,"Nome"					, "" })
	Aadd(aTagCli,{"A1_END" 		,"Endereco"				, "" })
	Aadd(aTagCli,{"A1_COMPLEM" ,"Complemento"			, "" })
	Aadd(aTagCli,{"A1_BAIRRO" 	,"Bairro"				, "" })
	Aadd(aTagCli,{"A1_COD_MUN" ,"CodMunicipio"		, "" })
	Aadd(aTagCli,{"A1_MUN" 		,"Municipio"			, "" })
	Aadd(aTagCli,{"A1_EST" 		,"UF"						, "" })
	Aadd(aTagCli,{"A1_CEP" 		,"CEP"					, "" })
	Aadd(aTagCli,{"A1_DDD" 		,"DDD"					, "" })
	Aadd(aTagCli,{"A1_TEL" 		,"Telefone"				, "" })
	Aadd(aTagCli,{"A1_EMAIL" 	,"Email"					, "" })
	Aadd(aTagCli,{"A1_PAIS" 	,"CodPais"				, "" })
	Aadd(aTagCli,{"A1_INSCRM" 	,"InscMunicipal"		, "" })
	Aadd(aTagCli,{"A1_INSCR" 	,"InscEstadual"		, "" })
	Aadd(aTagCli,{"A1_COD" 		,"A1_COD"				, "" })		//Campo não presente no XML, porém obrigatório
	Aadd(aTagCli,{"A1_LOJA" 	,"A1_LOJA"				, "" })		//Campo não presente no XML, porém obrigatório
	Aadd(aTagCli,{"A1_NREDUZ"	,"A1_NREDUZ"			, "" })		//Campo não presente no XML, porém obrigatório
	Aadd(aTagCli,{"A1_NATUREZ" ,"A1_NATUREZ"			, "" })		//Campo não presente no XML, porém obrigatório
	//incluída linha abaixo [Mauro Nagata, www.compila.com.br, 20200911]
	Aadd(aTagCli,{"A1_CODMUN" 	,"A1_CODMUN"			, "" })		//Campo não presente no XML, porém obrigatório
	Aadd(aTagCli,{"A1_PFISICA" ,"A1_PFISICA"			, "" })		//Campo não presente no XML, porém obrigatório
	Aadd(aTagCli,{"A1_TIPO" 	,"A1_TIPO"				, "" })		//Campo não presente no XML, porém obrigatório
	Aadd(aTagCli,{"A1_CODPAIS" ,"A1_CODPAIS"			, "" })		//Campo não presente no XML, porém obrigatório
	//fim bloco [Mauro Nagata, www.compila.com.br, 20200911]

Return(aTagCli)


/*/{Protheus.doc} FSBuscaCli
Rotina que realiza a busca do cliente no Protheus baseado em seu CGC.
@type function
@author gustavo.barcelos
@since 14/01/2016
@version 1.0
@param cCGCCli, character, CGC do cliente fornecido pelo WebService
@param cCodCli, character, Código do cliente realizado após a busca
@param cLojCli, character, Loja do cliente realizado após a busca
@param cSitCli, character, Situação do cliente realizado após a busca
@return boolean, .T. = Cliente encontrado; .F. = Cliente não encontrado
/*/

//Static Function FSBuscaCli(cCGCCli, cCodCli, cLojCli, cSitCli, nSA1RECNO)
//substituída linha acima pela abaixo [Mauro Nagata, www.compila.com.br, 20200911]
Static Function FSBuscaCli(cCGCCli, cCodCli, cLojCli, cSitCli, nSA1RECNO, cEstEx)

	Local aArea	:= GetArea()
	Local lRet		:= .F.
	Local cQuery	:= ""
	
	//Está sendo considerado que o CNPJ nunca estará em branco, mesmo quando for Cliente Estrangeiro.
	//Está sendo considerado que o Cliente possui um CNPJ para cada Loja.
	cQuery += " SELECT	A1_FILIAL, A1_COD, A1_LOJA, A1_CGC, A1_MSBLQL, R_E_C_N_O_ SA1RECNO FROM "+RetSqlName("SA1")+" "
	cQuery += " WHERE		D_E_L_E_T_ <> '*' "
	//cQuery += " AND A1_CGC = '" + cCGCCli + "' "
	//substituída linha acima pelo bloco abaixo [Mauro Nagata, www.compila.com.br, 20200911]
	cQuery += " 		AND 	(	
	cQuery += "						(	A1_CGC 		= '" + cCGCCli + "' " + " AND '" + cEstEx + "' != 'EX' ) "
	cQuery += "					OR "
	cQuery += "						(	A1_PFISICA 	= '" + cCGCCli + "' " + " AND '" + cEstEx + "' = 'EX' ) "
	cQuery += "					) "	
	//incluída linha abaixo [Mauro Nagata, www.compila.com.br, 20200915]
	cQuery += "			AND '" + cCGCCli + "' <> '' "
	//fim bloco [Mauro Nagata, www.compila.com.br, 20200911]

	TCQUERY cQuery NEW ALIAS "QRY"
	DbSelectArea( "QRY" )
	QRY->( DBGoTop() )
	
	If !QRY->(EOF())
		lRet 			:= .T.
		cCodCli 		:= QRY->A1_COD
		cLojCli 		:= QRY->A1_LOJA
		cSitCli 		:= QRY->A1_MSBLQL
		nSA1RECNO	:= QRY->SA1RECNO
	EndIF
	
	QRY->( DbCloseArea() )
	
	RestArea( aArea )

Return lRet


/*/{Protheus.doc} FSGeraPed
Rotina responsável pela geração do Pedido de Vendas
@type function
@author gustavo.barcelos
@since 18/01/2016
@version 1.0
@param aCabec, array, Array com o cabeçalho do Pedido de Vendas (SC5)
@param aItens, array, Array com os itens do Pedido de Vendas (SC6)
@param cMsg, character, Mensagem de retorno ao fim do processo
@param cPedido, character, Código do pedido gerado pelo sistema
@return boolean, .F. = Não foi possível realizar o cadastro do PV; .T. = PV cadastrado com sucesso
/*/

User Function FSGeraPed(aCabec, aItens, cPedido, cMsg, cXml)
	Local lRet 	:= .T.
	
	Default cXml := ""
	
	If !U_FSExeAut("MATA410", 3, @aCabec, @aItens, @cMsg)
		lRet := .F.
	Else
	
		If RecLock("SC5", .F.)
			SC5->C5_XPLEXML := cXml
			SC5->(MsUnlock())
		EndIf
			
		cPedido := SC5->C5_NUM
		cMsg := "Pedido " + cPedido + " cadastrado com sucesso!"
	EndIf
	
Return lRet


/*/{Protheus.doc} FSGeraParc
Rotina responsável pela gravação das parcelas de pagamentos para o pedido inserido.
@type function
@author gustavo.barcelos
@since 01/02/2016
@version 1.0
@param cFil, character, Filial do pedido inserido;
@param cPedido, character, Número do pedido inserido;
@param aParc, array, Array com os dados de pagamentos do pedido inserido.
/*/

User Function FSGeraParc(cFil, cPedido, aParc)

	Local aArea 	:= GetArea()
	Local nP		:= 0
	Local nX		:= 0
	Local nI		:= 0
	Local lMotoboy  := .F.
	Local cTipo 	:= ""
	Local cIdTran   := ""
	Local nQtdParc  := 0
	Local nValor    := 0
	Local aPedAtend := ""
	Local cSeq := "1"

	Local lVoucher  := .F.  // hfp - compila - voucher

	cFil := Left(cFil, len(cFilAnt))

	DBSelectArea("SZ7")
	SZ7->(DBSetOrder(1))

	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	lMotoboy := SC5->(MsSeek(cFil+cPedido)) .AND. SC5->C5_XMOTOB == "1"

	lTmp:= SZK->(FieldPos("C5_XVOUCHE")) > 0  //hfp - 20220117 veririfca se tem o campo criado antes
   lVoucher := lTmp .and. SC5->(MsSeek(cFil+cPedido)) .AND. SC5->C5_XVOUCHE == "1" // hfp - compila - voucher

	For nP := 1 to len(aParc)

		cTipo := aParc[nP][aScan(aParc[nP], {|X| X[1] == "TIPO"})][2]
		nQtdParc := Val( aParc[nP][aScan(aParc[nP], {|X| X[1] == "QTDEPARCELAS"})][2] )
		nValor := Val( aParc[nP][aScan(aParc[nP], {|X| X[1] == "VALOR"})][2] )
		
		//MODIFICADO O ASCAN, PQ DANDO ERRO DE POSICIONAMENTO  HFP - COMPILA - VOUCHER
		nPosTr:= aScan(aParc[nP], {|X| X[1] == "IDTRANSACAO"})  
		IF nPosTr > 0
			cIdTran  := aParc[nP][nPosTr][2]
		ENDIF

		// hfp - compila - voucher  If lMotoboy .AND. cTipo == "CC"
		If ( lMotoboy .or. lVoucher)  .AND. cTipo == "CC"

			aPedAtend := PedAtend(cFil, SC5->C5_XATENDI)

			For nX := 1 to len(aPedAtend)

				If SZ7->(MsSeek(cFil+aPedAtend[nX][1])) .AND.  Alltrim(SZ7->Z7_IDTRAN) == cIdTran
					
					nQtdParc := SZ7->Z7_QTDPAR

					RecLock("SC5", .F.)
						For nI := 1 to nQtdParc
							SC5->(&("C5_DATA"+cSeq)) := StoD(aPedAtend[nX][3][nI])
							SC5->(&("C5_PARC"+cSeq)) := nValor/nQtdParc
							cSeq := Soma1(cSeq)
						Next nI
					SC5->(MsUnlock())
				Endif

			Next nX
		Endif

		RecLock("SZ7", .T.)
		
		SZ7->Z7_FILIAL	:= cFil
		SZ7->Z7_PEDIDO	:= cPedido
		SZ7->Z7_FORMA	:= cTipo
		SZ7->Z7_VALOR	:= nValor
		SZ7->Z7_QTDPAR	:= nQtdParc
		SZ7->Z7_PAGTO	:= StoD( aParc[nP][aScan(aParc[nP], {|X| X[1] == "DATAPGTO"})][2] )

		cNumChq:= aParc[nP][aScan(aParc[nP], {|X| X[1] == "NUMCHEQUE"})][2]
		If Empty(cNumChq)
			cNumChq:= aParc[nP][aScan(aParc[nP], {|X| X[1] == "NUMCARTAO"})][2]
		EndIf
		SZ7->Z7_NUMCHQ	:= cNumChq

		SZ7->Z7_BAND	:= aParc[nP][aScan(aParc[nP], {|X| X[1] == "CODBANDEIRA"})][2]
		SZ7->Z7_IDTRAN	:= cIdTran
		
		SZ7->( MsUnlock() )
	
	Next nP
	
	SZ7->(DBCloseArea())
	
	RestArea(aArea)

Return


/*/{Protheus.doc} FSValTipPV
Rotina que valida o tipo de Pedido de Venda, e realiza o bloqueio quando o cliente for  novo e pessoa jurídica com o status = 1.
@type function
@author gustavo.barcelos
@since 04/02/2016
@version 1.0
@param cTipoFat, character, Tipo de Faturamento, P = Particular; C = Convênio
@param lCliente, boolean, T = Cliente novo e pessoa jurídica
/*/

User Function FSValTipPV(cTipoFat, lCliente, cFilAtu, cPedido)

	If lCliente
		SC5->(dbSetOrder(1))
		SC5->(MsSeek(cFilAtu+cPedido))
		If SC5->(!Eof())
			RecLock("SC5", .F.)
			SC5->C5_XBLQ := "1"
			MsUnlock()
		EndIf
	EndIf

Return


/*/{Protheus.doc} FSPLEEST
Conecta ao WS do Pleres para envio(post) ou retorno(request)

@author claudiol
@since 24/02/2016
@version undefined
@param cTipo, characters, descricao
@param cXml, characters, descricao
@type function
/*/
User Function FSPLEEST(cTipo,cXml)

	Local oWSDL
	Local cDescErr	:= "Erro:"
	Local lRet		:= .T.
	Local cError:= ""
	Local cWarning:= ""
	Local cXmlRet:= ""
	Local cRet		:= ""
	Local lDebug := SuperGetMV("ES_XDBGINT", NIL, .F.)

// Cria a instância da classe client
	oWSDL := WSIntegracaoERPProtheusTotvs():New()
	oWSDL:_URL := SuperGetMv("ES_PLEWEST",.F.,"http://54.207.126.178:7705/IntegracaoERPProtheusTotvs.svc?dominio=CDB_TESTE")

// Habilita informações de debug no log de console
	If lDebug
		WSDLDbgLevel(3)
	EndIf

// Chama o método do Web Service
	If cTipo=="PRD"
		lRet:= oWSDL:Produto(cXml)
		cRet:= oWSDL:cProdutoResult
	ElseIf cTipo=="BXA"
		lRet:= oWSDL:BaixaSA(cXml)
		cRet:= oWSDL:cBaixaSAResult
	EndIf

	If lRet
		cXmlRet:= FWNoAccent(cRet)
		oXmlRet:= XmlParser( cXmlRet, "_", @cError, @cWarning )

		aRet:= { oxmlret:_RETORNO:_CODSTATUS:TEXT, oxmlret:_RETORNO:_MSGERRO:TEXT }
	Else
		cRet:= GetWSCError()
		aRet:= {"-1", Dtoc(Date())+" "+Time() + cDescErr + CRLF + cRet}
	EndIf

Return(aRet)


/*/{Protheus.doc} FSPLEFAT
Conecta ao WS do Pleres para envio(post) ou retorno(request)

@author claudiol
@since 10/03/2016
@version undefined
@param cTipo, characters, descricao
@param cXml, characters, descricao
@type function
/*/
User Function FSPLEFAT(cXml,cIdPleres)

	Local oWSDL
	Local cDescErr:= "Erro: "
	Local lRet		:= .T.
	Local aRet		:= {"",""}
	Local cDesRet	:= Left(cIdPleres,1) //P=Pleres;X=Xclinic;C=Clinux
	Local cError:= ""
	Local cWarning:= ""
	Local cXmlRet:= ""
	Local oXmlRet
	Local lDebug := SuperGetMV("ES_XDBGINT", NIL, .F.)

	If cDesRet=="X" //Xclinic

		FWLogMsg("INFO", /*cTransactionId*/, "CONOUT", /*cCategory*/, /*cStep*/, /*cMsgId*/,"*********************************************************")
		FWLogMsg("INFO", /*cTransactionId*/, "CONOUT", /*cCategory*/, /*cStep*/, /*cMsgId*/,"* FSLIBPLE - Filial: " + cFilAnt + " - ID: " + cIdPleres+" - " + DtoC(Date()) + " - " + Time() + " Integrando XClinic!")
		FWLogMsg("INFO", /*cTransactionId*/, "CONOUT", /*cCategory*/, /*cStep*/, /*cMsgId*/,"*********************************************************")


	//Substitui login e senha de acesso
		cXml:= StrTran(cXml, "PAR_LOGIN", Supergetmv("ES_XCLLOG",.F.,""))
		cXml:= StrTran(cXml, "PAR_SENHA", Supergetmv("ES_XCLPSW",.F.,""))

	// Cria a instância da classe client
		oWSDL := WSIntegraFaturamento():New()
		oWSDL:_URL := 	SuperGetMv("ES_XCLWFAT",.F.,"http://187.1.82.118/wsIntegraFaturamento/wsIntegraFaturamento.asmx")

		FWLogMsg("INFO", /*cTransactionId*/, "CONOUT", /*cCategory*/, /*cStep*/, /*cMsgId*/,"*********************************************************")
		FWLogMsg("INFO", /*cTransactionId*/, "CONOUT", /*cCategory*/, /*cStep*/, /*cMsgId*/,"* FSLIBPLE - Filial: + " + cFilAnt + "Parametro ES_XCLWFAT - Link: " + oWSDL:_URL)
		FWLogMsg("INFO", /*cTransactionId*/, "CONOUT", /*cCategory*/, /*cStep*/, /*cMsgId*/,"*********************************************************")
	
		If lDebug
		// Habilita informações de debug no log de console
			WSDLDbgLevel(3)
		EndIf
	
	// Chama o método do Web Service
		lRet:= oWSDL:LotexNotaFiscal(cXml)
	
		If lRet
			aRet:= {}
			Aadd(aRet, cValToChar(oWsdl:oWSLotexNotaFiscalResult:nCodStatus))
			Aadd(aRet, oWsdl:oWSLotexNotaFiscalResult:cMsgErro)
		Else
			cRet:= GetWSCError()
			aRet:= {"-1", Dtoc(Date())+" "+Time() + CRLF + cDescErr + cRet}
		EndIf

	ElseIf cDesRet=="P" //Pleres

		FWLogMsg("INFO", /*cTransactionId*/, "CONOUT", /*cCategory*/, /*cStep*/, /*cMsgId*/,"*********************************************************")
		FWLogMsg("INFO", /*cTransactionId*/, "CONOUT", /*cCategory*/, /*cStep*/, /*cMsgId*/,"* FSLIBPLE - Filial: " + cFilAnt + " - ID: " + cIdPleres+" - " + DtoC(Date()) + " - " + Time() + " Integrando Pleres!")
		FWLogMsg("INFO", /*cTransactionId*/, "CONOUT", /*cCategory*/, /*cStep*/, /*cMsgId*/,"*********************************************************")

	//Substitui login e senha de acesso
		cXml:= StrTran(cXml, "PAR_LOGIN", Supergetmv("ES_PLELOG",.F.,""))
		cXml:= StrTran(cXml, "PAR_SENHA", Supergetmv("ES_PLEPSW",.F.,""))

	// Cria a instância da classe client
		oWSDL := WSIntegracaoERPProtheusTotvs():New()
		oWSDL:_URL := 	SuperGetMv("ES_PLEWFAT",.F.,"http://54.207.126.178:7705/IntegracaoERPProtheusTotvs.svc/LotexNotaFiscal?dominio=CDB_TESTE")

		FWLogMsg("INFO", /*cTransactionId*/, "CONOUT", /*cCategory*/, /*cStep*/, /*cMsgId*/,"*********************************************************")
		FWLogMsg("INFO", /*cTransactionId*/, "CONOUT", /*cCategory*/, /*cStep*/, /*cMsgId*/,"* FSLIBPLE - Filial: + " + cFilAnt + "Parametro ES_PLEWFAT - Link: " + oWSDL:_URL)
		FWLogMsg("INFO", /*cTransactionId*/, "CONOUT", /*cCategory*/, /*cStep*/, /*cMsgId*/,"*********************************************************")
	
		If lDebug
		// Habilita informações de debug no log de console
			WSDLDbgLevel(3)
		EndIf
	
	// Chama o método do Web Service
		cXml := "<![CDATA["+cXml+"]]>"
		lRet:= oWSDL:LotexNotaFiscal(cXml)
	
		If lRet
			cXmlRet:= FWNoAccent(owsdl:CLOTEXNOTAFISCALRESULT)
			oXmlRet:= XmlParser( cXmlRet, "_", @cError, @cWarning )

			aRet:= { oxmlret:_RETORNO:_CODSTATUS:TEXT, oxmlret:_RETORNO:_MSGERRO:TEXT }
		Else
			cRet:= GetWSCError()
			aRet:= {"-1", Dtoc(Date())+" "+Time() + CRLF + cDescErr + cRet}
		EndIf

	ElseIf cDesRet=="C" //Clinux

		FWLogMsg("INFO", /*cTransactionId*/, "CONOUT", /*cCategory*/, /*cStep*/, /*cMsgId*/,"*********************************************************")
		FWLogMsg("INFO", /*cTransactionId*/, "CONOUT", /*cCategory*/, /*cStep*/, /*cMsgId*/,"* FSLIBPLE - Filial: " + cFilAnt + " - ID: " + cIdPleres+" - " + DtoC(Date()) + " - " + Time() + " Integrando Clinux!")
		FWLogMsg("INFO", /*cTransactionId*/, "CONOUT", /*cCategory*/, /*cStep*/, /*cMsgId*/,"*********************************************************")


	//Substitui login e senha de acesso
		cXml:= StrTran(cXml, "PAR_LOGIN", Supergetmv("ES_CLILOG",.F.,""))
		cXml:= StrTran(cXml, "PAR_SENHA", Supergetmv("ES_CLIPSW",.F.,""))

	// Cria a instância da classe client
		oWSDL := WSclinuxWS():New()
		oWSDL:_URL := 	SuperGetMv("ES_CLIWFAT",.F.,"http://54.232.247.42/alliar/integracao.php")

		FWLogMsg("INFO", /*cTransactionId*/, "CONOUT", /*cCategory*/, /*cStep*/, /*cMsgId*/,"*********************************************************")
		FWLogMsg("INFO", /*cTransactionId*/, "CONOUT", /*cCategory*/, /*cStep*/, /*cMsgId*/,"* FSLIBPLE - Filial: + " + cFilAnt + "Parametro ES_CLIWFAT - Link: " + oWSDL:_URL)
		FWLogMsg("INFO", /*cTransactionId*/, "CONOUT", /*cCategory*/, /*cStep*/, /*cMsgId*/,"*********************************************************")
	
		If lDebug
		// Habilita informações de debug no log de console
			WSDLDbgLevel(3)
		EndIf
	
	// Chama o método do Web Service
		lRet:= oWSDL:LotexNotaFiscal(cXml)

		If lRet
			cXmlRet:= FWNoAccent(owsdl:CLOTEXNOTAFISCALRESULT)
			oXmlRet:= XmlParser( cXmlRet, "_", @cError, @cWarning )

			aRet:= { oxmlret:_LOTEXNOTAFISCALRESPONSE:_CODSTATUS:TEXT, oxmlret:_LOTEXNOTAFISCALRESPONSE:_MSGERRO:TEXT }
		Else
			cRet:= GetWSCError()
			aRet:= {"-1", Dtoc(Date())+" "+Time() + CRLF + cDescErr + cRet}
		EndIf

	EndIf

Return(aRet)




Static Function NoAcento(cString)
	Local cChar  := ""
	Local nX     := 0
	Local nY     := 0
	Local cVogal 		:= "aeiouAEIOU"
	Local cAgudo 		:= "áéíóú"+"ÁÉÍÓÚ"
	Local cCircu 		:= "âêîôû"+"ÂÊÎÔÛ"
	Local cTrema 		:= "äëïöü"+"ÄËÏÖÜ"
	Local cCrase 		:= "àèìòù"+"ÀÈÌÒÙ"
	Local cTio   		:= "ãõ"
	Local cCecid 		:= "çÇ"
	Local cEspChar 	:= "/\?.$@&*':,"

	For nX:= 1 To Len(cString)
		cChar:=SubStr(cString, nX, 1)
		IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase+cEspChar
			nY:= At(cChar,cAgudo)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cCircu)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cTrema)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cCrase)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cTio)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr("ao",nY,1))
			EndIf
			nY:= At(cChar,cCecid)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr("cC",nY,1))
			EndIf
			nY:= At(cChar,cEspChar)
			If nY > 0
				cString := StrTran(cString,cChar,"")
			EndIf
		Endif
	Next
	For nX:=1 To Len(cString)
		cChar:=SubStr(cString, nX, 1)
		If Asc(cChar) < 32 .Or. Asc(cChar) > 123
			cString:=StrTran(cString,cChar,".")
		Endif
	Next nX
	cString := _NoTags(cString)
Return cString

User Function FSAJSCHVNF()
Local lEnd 
Local oProcess

oProcess := MsNewProcess():New( { |lEnd| FSEXEAJS( @lEnd , oProcess) } , 'Verificando ...', 'Lendo...', .T. )
oProcess:Activate()

Return

Static Function FSEXEAJS(lEnd,oProcess)
Local cAlias 	:= GetNextAlias()
Local cXml		:= ""
Local nPosIni	:= 0
Local nPosFim	:= 0
Local cChave	:= ""
Local cQuery	:= ""
//hfp Local nCount	:= 0

	SET DELETED OFF

	DbSelectArea("SF2")
	SF2->(DbSetOrder(1))

	DbSelectArea("CKO")
	CKO->(DbSetOrder(1))
	
	cQuery += " SELECT SF2.F2_DOC, SF2.R_E_C_N_O_ SF2RECNO,  CKQ.R_E_C_N_O_ CKQRECNO, CKO.R_E_C_N_O_ CKORECNO FROM "+RetSqlName("SF2")+" SF2 "
	cQuery += " INNER JOIN "+RetSqlName("CKQ")+" CKQ ON SF2.F2_DOC = CKQ.CKQ_NUMERO AND SF2.F2_EMISSAO = CKQ.CKQ_DT_GER "
	cQuery += " INNER JOIN "+RetSqlName("CKO")+" CKO ON CKQ.CKQ_IDERP = CKO.CKO_IDERP "
	cQuery += " WHERE SF2.F2_XCVNFS = ''  "

	cQuery := ChangeQuery(cQuery)

	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.T.,.T.)
	
	oProcess:SetRegua1( (cAlias)->(RecCount()) )
	
	Do While (cAlias)->(!Eof())
		
		CKO->(DBGoto( (cAlias)->CKORECNO  ))
		SF2->(DBGoto( (cAlias)->SF2RECNO  ))
			
		cXml := CKO->CKO_XMLRET
		
		nPosIni 	:= At("<CodigoVerificacao>",cXml)
		nPosFim	:= At("</CodigoVerificacao>",cXml)
		
		oProcess:IncRegua1("Processando NF: "+ (cAlias)->F2_DOC  )
		ProcessMessage()	
							
		If nPosIni > 0 .and. nPosFim > 0
		
			cChave := Substr(cXml,nPosIni,nPosFim-nPosIni)
			cChave := StrTran(cChave,"<CodigoVerificacao>","")
	
			If RecLock("SF2", .F.)
				SF2->F2_XCVNFS := cChave
				SF2->(MsUnlock())
			EndIf

		Endif
		
		(cAlias)->(DBSkip())
	EndDo
	
	SET DELETED ON
	
Return	

Static Function PedAtend(cFil, cAtend)

Local aPed   := {}
Local cAlias := GetNextAlias()
Local cQuery := ""
Local aArea  := GetArea()

Default cFil := xFilial("SC5")
Default cAtend := ""

	cQuery := " SELECT C5_NUM, R_E_C_N_O_ C5_REC,  "
	cQuery += " C5_DATA1, "
	cQuery += " C5_DATA2, "
	cQuery += " C5_DATA3, "
	cQuery += " C5_DATA4, "
	cQuery += " C5_DATA5, "
	cQuery += " C5_DATA6, "
	cQuery += " C5_DATA7, "
	cQuery += " C5_DATA8, "
	cQuery += " C5_DATA9, "
	cQuery += " C5_DATAA, "
	cQuery += " C5_DATAB, "
	cQuery += " C5_DATAC, "
	cQuery += " C5_DATAD  "
	cQuery += " FROM "+RetSqlName("SC5")+" SC5 "
	cQuery += " WHERE SC5.D_E_L_E_T_ = ''  AND "
	cQuery += " SC5.C5_FILIAL = '"+cFil+"'  AND "
	cQuery += " SC5.C5_XATENDI = '"+cAtend+"' AND "
	cQuery += " SC5.C5_XMOTOB <> '1' "

	cQuery := ChangeQuery(cQuery)

	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.T.,.T.)

	While (cAlias)->(!Eof())

		aAdd(aPed, { (cAlias)->C5_NUM, (cAlias)->C5_REC,;
		 	{;
			 (cAlias)->C5_DATA1,;
			 (cAlias)->C5_DATA2,;
			 (cAlias)->C5_DATA3,;
			 (cAlias)->C5_DATA4,;
			 (cAlias)->C5_DATA5,;
			 (cAlias)->C5_DATA6,;
			 (cAlias)->C5_DATA7,;
			 (cAlias)->C5_DATA8,;
			 (cAlias)->C5_DATA9,;
			 (cAlias)->C5_DATAA,;
			 (cAlias)->C5_DATAB,;
			 (cAlias)->C5_DATAC,;
			 (cAlias)->C5_DATAD; 
			};
		})

		(cAlias)->(DbSkip())
	Enddo

RestArea(aArea)

Return aClone(aPed)



/*/{Protheus.doc} fSGetMv(param_name)
	(long_description)
	@type  Function
	@author user
	@since 29/03/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function fSGetMv(cparam_name,lMostra, param_default,cfilial)

return_var := SuperGetMV(cparam_name,lMostra,param_default,cfilial)

Return return_var


/*/{Protheus.doc} fGetMv(param_name)
	(long_description)
	@type  Function
	@author user
	@since 29/03/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function fGetMv(cparam_name,lMostra, param_default)

return_var := GetMV(cparam_name,lMostra,param_default)

Return return_var
