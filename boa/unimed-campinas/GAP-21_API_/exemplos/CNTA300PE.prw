#include 'totvs.ch'
#include 'fwmvcdef.ch'

/*/{Protheus.doc} cnta300
Ponto de entrada MVC da rotina de cadastro de contratos (CNTA300)
@type function
@version  12.12210
@author elton.alves
@since 27/11/2023
@return variant, pode retornar "nulo", "verdadeiro/falso" ou array a depender 
/*/
user function cnta300() 

	local xRet      := .T.
	local oView     := nil
	local oModel    := fwModelActive()
	local oModelCNF := nil
	//FLUIG
	Local aParam     := PARAMIXB
	Local oObj       := ''
	Local cIdPonto   := ''
	Local cIdModel   := ''
	Local cChave     := ''
	Local cUser		 := __cUserId
	Local lUsaFlg    := SuperGetMv("MV_XFLUIG",,.T.)
	Local cOrigem	 := "CONTRATO"
	Local cSit 		 := ""
	Local xVencto    := ''
	Local aAreaCN9   := CN9->(GetArea())
	Local cDiaCa     := ""
	Local dDataVencA := ""
	Local nLinhas    := 0
	Local x          := 0
	Local cCampo     := ""

	if valType( M->paramixb ) == 'A' .And.;
			len( paramixb ) >= 2

		if paramixb[2] == 'BUTTONBAR'

			xRet := { {'Importação de Itens', 'BUDGET', { |x| U_ImpItens() }, 'Botão customizado' } }

		elseif paramixb[2] == 'FORMLINEPOS'

			if paramixb[3] == 'CNFDETAIL'

				 /* if IsInCallStack('CN300ADDCRG') .And. MV_PAR09 == 1 // Pergunta "CN300CRG" - Data da Medição no dia 01 */

				if valType( oModel ) == 'O' .and. ( oModel:GetOperation() == MODEL_OPERATION_UPDATE .OR.;
						oModel:GetOperation() == MODEL_OPERATION_INSERT  )

					oView     := fwViewActive()
					
					// oModel    := fwModelActive()
					
					oModelCNF := oModel:getModel( 'CNFDETAIL' )
					oModelCNF:SetNoUpdateLine(.F.)

					// Define a data da medição no dia 01 do mês de vencimento da parcela no finaceiro
					// oModelCNF:LoadValue( 'CNF_PRUMED',;
						// firstDate( oModelCNF:GetValue( 'CNF_DTVENC' ) ) )

					xVencto := oModelCNF:GetValue( 'CNF_COMPET' )
					xVencto := StrTokArr2( xVencto, '/', .T. )

					If Len(xVencto) > 1
						xVencto := xVencto[2] + xVencto[1] + '10'
						xVencto := sTod( xVencto )

						oModelCNF:LoadValue( 'CNF_PRUMED',firstDate( xVencto ) )
						//oModelCNF:LoadValue( 'CNF_DTVENC',           xVencto   )
					EndIf

					If Type('oView') != "U"
						oView:Refresh()
					EndIf

					xRet := .T.

				end if

			end if

		elseif paramixb[2] == 'MODELCOMMITNTTS'

			if isInCallStack( 'CN300Aprov' )

				//  Gera os lançamentos orçamentários para estorno dos saldos das
				// parcelas do cronograma da versão do contrato revisada
				U_CRON300E() 

			end if

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    	//³ Tratamento para data de vencimento na atualização do cronograma     ³
    	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf paramixb[2] == 'FORMLINEPRE'

           //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
           //³ Executa somente se for chamado a atualização do cronograma          ³
           //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If FwIsInCallStack("CN300AtCrs")
				cCampo := paramixb[5]
				oModel	:=	FWModelActive()
				oView 	:= FwViewActive()
				oModelCNF := oModel:GetModel("CNFDETAIL")
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    			//³ Verifica deletado                                                   ³
    			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cCampo != "DELETE"
					nLinhas := FWSaveRows()
						For x := 1 To oModelCNF:Length()
							cDiaCa		:=	strzero(day(oModelCNF:GetValue("CNF_DTVENC")),2)
							oModelCNF:GoLine(x)
							If (!oModelCNF:IsDeleted()) .AND.  (oModelCNF:IsInserted())
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    							//³ Realizando o ajuste dos valores                                     ³
    							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								dDataVencA  :=  oModelCNF:GetValue("CNF_DTVENC")
								dDataVencA	:=	stod(cValtochar(Year(dDataVencA))+StrZero(Month(dDataVencA),2)+cDiaCa)
								oModelCNF:LoadValue("CNF_DTVENC",dDataVencA)
							EndIf
						Next x
					FWRestRows(nLinhas)
				Endif
			EndIf

		EndIf

	end if


	//VALIDAÇÃO PARA INTEGRAÇÃO COM O FLUIG - PEDRO RAMOS
	If aParam <> NIL
		oObj       := aParam[1]
		cIdPonto   := aParam[2]
		cIdModel   := aParam[3]

		//ConOut("--- PE CNTA300 -> "+AllTrim(cIdPonto))
		//Antes 'MODELCOMMITTTS'
		If AllTrim(cIdPonto) == "MODELCOMMITNTTS" .And. ((CN9->CN9_TIPREV <> '' .And. Alltrim(CN9->CN9_SITUAC) $ "09") .Or. (CN9->CN9_TIPREV == '' .And. Alltrim(CN9->CN9_SITUAC) $ "04|05"))
			cCampo := FwFldGet("CN9_JUSTIF")
			//SRSF 13/07/2023 - Atualiza campo CN9_XNOME com o usuário
			CN9->(DbSelectArea("CN9"))
			CN9->(DbSetOrder(1))
			If CN9->(MsSeek(XFilial("CN9")+FwFldGet("CN9_NUMERO")+FwFldGet("CN9_REVISA")))
				cSit := CN9->CN9_SITUAC
				cChave 	:= CN9->CN9_FILIAL+LEFT(CN9->CN9_NUMERO,15)+CN9->CN9_REVISA
				If lUsaFlg
					 U_fGrvSZA(cOrigem,cChave,cUser,cCampo,cSit)
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aAreaCN9)

return xRet
