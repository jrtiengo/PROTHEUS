#Include 'TOTVS.ch'
#Include 'TopConn.ch'
#Include 'Protheus.ch'

/*/{Protheus.doc} FA070CAN
description O ponto de entrada FA070CAN sera executado apos gravacao dos dados de cancelamento no SE1 e antes de estornar os dados do SE5 e de comissao.
@type function
@version  
@author Tiengo Junior
@since 14/10/2025
@param aParam, array, param_description
@return variant, return_description
/*/
User Function FA070CAN()

	Local aArea 		:= FwGetArea()
	Local aAreaCN9 	    := CN9->(FwGetArea())
	Local aAreaSE1      := SE1->(FwGetArea())
	Local cNRental    	:= ""
	Local aContr		:= {}
	Local cContr   		:= ""
	Local cRevisa		:= ""

	If ! Empty(SE1->E1_XRENTA)

		cNRental := SE1->E1_XRENTA

		aContr := u_Ultrevcn9(cNRental)

		If Len(aContr) >  0

			cContr		:= PadR(aContr[2], TamSX3("CN9_NUMERO")[1])
			cRevisa 	:= PadR(aContr[2], TamSX3("CN9_REVISA")[1])

			CN9->(dbSetOrder(1)) //CN9_FILIAL+CN9_NUMERO+CN9_REVISA

			If CN9->(MsSeek(FWxFilial("CN9") + cContr + cRevisa))
				CN9->(RecLock("CN9", .F.))
				CN9->CN9_XSTSRE := '2' // faturado
				CN9->(MsUnlock())
			EndIf
		Endif
	Endif

	FwRestArea(aAreaSE1)
	FwRestArea(aAreaCN9)
	FwRestArea(aArea)

Return()
