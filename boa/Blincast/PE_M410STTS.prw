#Include 'TOTVS.ch'
#Include 'TopConn.ch'
#Include 'Protheus.ch'

/*/{Protheus.doc} M410STTS
description Este ponto de entrada pertence a rotina de pedidos de venda, MATA410().
@type function
@version  
@author Tiengo Junior
@since 5/15/2025
@obs PARAMIXB[1] Opacao Escolhida pelo usuario - 03 inclusao - 04 alteracao - 05 exclusao - 06 - copia - 07 - dev. compras
@See https://tdn.totvs.com/pages/releaseview.action?pageId=6784155
/*/

User Function M410STTS()

	Local aArea 		:= FwGetArea()
	Local aAreaCN9 		:= CN9->(FwGetArea())
	Local aAreaCN5 		:= CN5->(FwGetArea())
	Local _nOper 		:= PARAMIXB[1]
	Local cNumRental 	:= ""
	Local aContr		:= {}
	Local cContr   		:= ""
	Local cRevisa		:= ""

	//Se chamado do Rental, gravo o numero do Rental na SC5 e CN9
	If FWIsInCallStack("LOCA021")

		cNumRental := FPA->FPA_PROJET

		SC5->(RecLock("SC5", .F.))
		SC5->C5_XRENTA := cNumRental
		SC5->(MsUnlock())

		aContr := u_Ultrevcn9(cNRental)

		If Len(aContr) >  0

			cContr		:= PadR(aContr[2], TamSX3("CN9_NUMERO")[1])
			cRevisa 	:= PadR(aContr[2], TamSX3("CN9_REVISA")[1])

			CN9->(dbSetOrder(1)) //CN9_FILIAL+CN9_NUMERO+CN9_REVISA

			If CN9->(MsSeek(FWxFilial("CN9") + cContr + cRevisa))

				If _nOper == 3
					CN9->(RecLock("CN9", .F.))
					CN9->CN9_XSTSRE := '2' // Faturado
					CN9->(MsUnlock())
				EndIf
			EndIf
		EndIf
	EndIf

	// Exclusão de pedido
	If _nOper == 5 .And. ! Empty(SC5->C5_XRENTA)

		cNumRental := SC5->C5_XRENTA

		aContr := u_Ultrevcn9(cNRental)

		If Len(aContr) >  0

			cContr		:= PadR(aContr[2], TamSX3("CN9_NUMERO")[1])
			cRevisa 	:= PadR(aContr[2], TamSX3("CN9_REVISA")[1])

			CN9->(dbSetOrder(1)) //CN9_FILIAL+CN9_NUMERO+CN9_REVISA

			If CN9->(MsSeek(FWxFilial("CN9") + cContr + cRevisa))
				CN9->(RecLock("CN9", .F.))
				CN9->CN9_XSTSRE := '1' // Em Aberto
				CN9->(MsUnlock())
			EndIf

		EndIf
	EndIf

	FwRestArea(aAreaCN5)
	FwRestArea(aAreaCN9)
	FwRestArea(aArea)

Return()
