#Include "TOTVS.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} IntStatusSE1
Busca o status para o títulos a receber GAP-29
@version 1.0 
@author Tiengo Junior
@since 21/05/2025
@type function
/*/

User Function IntStsTit(aParam)

	Local cLockChv  	:= "StatusSE1"			as Character
	Local _cEmp			:= ''					as Character
	Local _cFil			:= ''					as Character

	Default aParam		:= {cEmpAnt, cFilAnt}

	//Prepara o ambiente caso for chamado pelo schedule
	If IsBlind()
		If Len(aParam) < 2

			conout("IntStatusSE1 - Erro ao Preparar o ambiente")
			Return()
		Else
			_cEmp			:= aParam[1]
			_cFil			:= aParam[2]

			RPCSetEnv(_cEmp, _cFil)
		Endif
	Endif

	//Faço um lock para evitar que o mesmo processo seja chamado mais de uma vez
	If LockByName(cLockChv)
		If IsBlind()
			fBuscaSts()
			unlockByName(cLockChv)
			RpcClearEnv() //Encerra o ambiente, fechando as devidas conexões
		Else
			FWMsgRun(, {|| fBuscaSts()}, "Processando", "Aguarde a execução...")
			unlockByName(cLockChv)
			FWAlertSuccess('Processamento concluído','Integração SPM - Status Cliente')
		EndIf
	Else
		conout("IntStatusSE1 - Nao conseguiu lock")
	Endif

Return()

//Busca o status do cliente
Static Function fBuscaSts()

	Local cQuery		:= ""																					as Character
	Local cStatus		:= ""																					as Character
	Local aHeader		:= {}																					as array
	Local oRest			:= Nil																					as Object
	Local oResponse     := Nil																					as Object
	Local cUrl          := SuperGetMV("UB_URLSPM",.F.,"https://appdmz-dev.unimedcampinas.com.br/gesfinspmapi")	as Character
	Local oJSONRet      := JsonObject():New()																	as Object
	Local oLog          := Nil                 									    							as Object
	Local jAuxLog  		:= Nil                 																	as jSon
	Local cLogErro      := ""																					as Character

	oLog := CtrlLOG():New()
	If ! oLog:SetTab("SZL")

		U_AdminMsg("[CNTA300] " + DToC(dDataBase) + " - " + Time() + " -> " + oLog:GetError(), IsBlind())
	EndIf

	//Busca o Token
	cToken	:= U_RetSPMToken()

	If ! Empty(cToken)

		//Query em títulos vencidos, para os clientes que não estão restritos ( A1_XDTIRES e A1_XDTFRES )
		cQuery := " SELECT DISTINCT SE1.E1_FILIAL, 												"
		cQuery += "					SA1.A1_COD, 												"
		cQuery += "					SA1.A1_LOJA, 												"
		cQuery += "					SA1.A1_XIDINT												"
		cQuery += "	FROM "+ RetSqlName("SE1") +" SE1                                            "
		cQuery += "	INNER JOIN "+ RetSqlName("SA1") +" SA1 ON                                   "
		cQuery += "     SE1.E1_CLIENTE = SA1.A1_COD       										"
		cQuery += "	AND SE1.E1_LOJA = SA1.A1_LOJA                                               "
		cQuery += "	AND ((SA1.A1_XDTIRES = ''                                                   "
		cQuery += "	      OR '"+ DtoS(dDataBase)+"' < SA1.A1_XDTIRES))                          "
		cQuery += "	AND ((SA1.A1_XDTFRES = ''                                                   "
		cQuery += "	      OR '"+ DtoS(dDataBase)+"' > SA1.A1_XDTFRES))                          "
		cQuery += "	AND	SA1.A1_FILIAL = '"+ FWxFilial('SA1') +"'                                "
		cQuery += "	AND	SA1.A1_XORINT  = 'SPM'                               					"
		cQuery += "	AND SA1.D_E_L_E_T_ = ''                                                     "
		cQuery += "	WHERE SE1.D_E_L_E_T_ = ''                                                   "
		cQuery += "	  AND SE1.E1_VENCREA < '"+ DtoS(dDataBase)+"'                               "
		cQuery += "	  AND SE1.E1_BAIXA = ''                                                     "
		cQuery += "	  AND SE1.E1_FILIAL = '"+ FWxFilial('SE1') +"'                              "

		cQuery := ChangeQuery(cQuery)

		MPSysOpenQuery(cQuery, 'TMP')

		If ! TMP->(EoF())

			While ! TMP->(EoF())

				//Adiciona o header com a autenticacao
				aAdd( aHeader, "Accept: application/json" )
				aAdd( aHeader, "Authorization: Bearer " + cToken)

				cCodSPM := TMP->A1_XIDINT

				oRest := FWRest():New(cUrl)
				oRest:SetPath( "/clientes/v1/inadimplencia/" + cCodSPM )

				If oResponse := oRest:Get(aHeader)

					FreeObj(jAuxLog)
					jAuxLog             := JsonObject():New()
					jAuxLog["status"]   := "1"
					jAuxLog["idinteg"]  := ""
					jAuxLog["nomapi"]   := "GET_SE1STATUS"
					jAuxLog["rotina"]   := "FINA040"
					jAuxLog["tabela"]   := "SE1"
					jAuxLog["recno"]    := 0
					jAuxLog["data"]     := DToS(dDataBase)
					jAuxLog["hora"]     := Time()
					jAuxLog["msgresp"]  := "success"
					jAuxLog["msgerr"]   := ""
					jAuxLog["jsonbod"]  := oRest:GetResult()
					jAuxLog["jsonret"]  := '{"result": Consulta Gerada com sucesso!"}'

					oJsonRet:FromJson(oRest:cResult) //converte o retorno para Json para manipulação
					cStatus := oJsonRet['resultado']['status']

					//Caso tenha algum status, irei percorrer os títulos não baixados e vencidos desse cliente.
					If ! Empty(cStatus)

						cChave := TMP->E1_FILIAL+TMP->A1_COD+TMP->A1_LOJA

						SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
						If SE1->(MSSeek(cChave))

							While ! SE1->(Eof()) .and. SE1->(E1_FILIAL + E1_CLIENTE + E1_LOJA) == cChave

								If Empty(SE1->E1_BAIXA) .and. SE1->E1_VENCREA < dDataBase

									SE1->(Reclock("SE1", .F.))
									SE1->E1_XSTCTSP := cStatus
								Endif

								SE1->(DbSkip())
							Enddo
						Endif
					Endif
				Else
					cLogErro := oRest:GetLastError()
					FreeObj(jAuxLog)
					jAuxLog             := JsonObject():New()
					jAuxLog["status"]   := "0"
					jAuxLog["idinteg"]  := ""
					jAuxLog["nomapi"]   := "GET_SE1STATUS"
					jAuxLog["rotina"]   := "FINA040"
					jAuxLog["tabela"]   := "SE1"
					jAuxLog["recno"]    := 0
					jAuxLog["data"]     := DToS(dDataBase)
					jAuxLog["hora"]     := Time()
					jAuxLog["msgresp"]  := "error"
					jAuxLog["msgerr"]   := cLogErro
					jAuxLog["jsonbod"]  := oRest:GetBodyRequest()
					jAuxLog["jsonret"]  := '{"result": "' + cLogErro + '"}'

					If ! oLog:AddItem(jAuxLog)
						ConOut(oLog:GetError())
					EndIf

				Endif

				TMP->(DbSkip())
			EndDo
		Else
			ConOut('Nenhum registro encontrado na consulta')
		EndIf
	Else
		cLogErro := 'Erro de Autenticação, Token não encontrado'
		FreeObj(jAuxLog)
		jAuxLog             := JsonObject():New()
		jAuxLog["status"]   := "0"
		jAuxLog["idinteg"]  := ""
		jAuxLog["nomapi"]   := "GET_SE1STATUS"
		jAuxLog["rotina"]   := "FINA040"
		jAuxLog["tabela"]   := "SE1"
		jAuxLog["recno"]    := 0
		jAuxLog["data"]     := DToS(dDataBase)
		jAuxLog["hora"]     := Time()
		jAuxLog["msgresp"]  := "error"
		jAuxLog["msgerr"]   := cLogErro
		jAuxLog["jsonbod"]  := '{"result": "' + cLogErro + '"}'
		jAuxLog["jsonret"]  := '{"result": "' + cLogErro + '"}'

		If ! oLog:AddItem(jAuxLog)
			ConOut(oLog:GetError())
		EndIf
	Endif

Return()
