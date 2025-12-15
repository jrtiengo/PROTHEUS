#Include 'TOTVS.ch'
#Include 'TopConn.ch'
#Include 'Protheus.ch'

/*/{Protheus.doc} MT103FIM
Operação após gravação da NFE
O ponto de entrada MT103FIM encontra-se no final da função A103NFISCAL.
Após o destravamento de todas as tabelas envolvidas na gravação do documento de entrada, depois de fechar a operação realizada neste.
É utilizado para realizar alguma operação após a gravação da NFE.
@type function
@version V 1.00
@author Tiengo Junior 
@since 08/11/2025
@obs PARAMIXB[1] - Opção Escolhida pelo usuario no aRotina
@obs PARAMIXB[2] - Se o usuario confirmou a operação de gravação da NFECODIGO DE APLICAÇÃO DO USUARIO
@link https://tdn.totvs.com/pages/releaseview.action?pageId=6085406 //
/*/
User Function MT103FIM()

	Local aArea         := FwGetArea()
	Local aAreaSF1      := SF1->(FwGetArea())
	Local aAreaSD1      := SD1->(FwGetArea())
	Local aAreaSC7      := SC7->(FwGetArea())
	Local aAreaSE2      := SE2->(FwGetArea())
	Local aAreaCND      := CND->(FwGetArea())
	Local nOpc          := PARAMIXB[1]
	Local nConfirmado   := PARAMIXB[2]
	Local cNRental      := ""

	If nConfirmado == 1 .and. (nOpc == 3 .or. nOpc == 4)

		If ! Empty(SC7->C7_MEDICAO)

			CND->(DbSetOrder(4)) //CND_FILIAL+CND_NUMMED

			If CND->(MSSeek(FWxFilial("CND")+SC7->C7_MEDICAO))

				cNRental := CND->CND_XRENTA

				SE2->(DBSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM
				If SE2->(MSSeek(FWxFilial("SE2") + SF1->(F1_FORNECE + F1_LOJA + F1_SERIE + F1_DOC)))

					While !SE2->(Eof()) .And. ;
							FWxFilial("SE2") == SE2->E2_FILIAL .And. ;
							SF1->F1_FORNECE == SE2->E2_FORNECE .And. ;
							SF1->F1_LOJA == SE2->E2_LOJA .And. ;
							SF1->F1_SERIE == SE2->E2_PREFIXO .And. ;
							SF1->F1_DOC == SE2->E2_NUM

						Reclock("SE2", .F.)
						SE2->E2_XRENTA := cNRental
						SE2->(MsUnlock())

						SE2->(DbSkip())
					EndDo
				EndIf
			Endif
		Endif
	Endif

	FwRestArea(aAreaSC7)
	FwRestArea(aAreaSE2)
	FwRestArea(aAreaCND)
	FwRestArea(aAreaSF1)
	FwRestArea(aAreaSD1)
	FwRestArea(aArea)

Return()
