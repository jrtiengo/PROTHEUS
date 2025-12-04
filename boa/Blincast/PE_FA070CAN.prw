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
	Local cNumRental 	:= ""

	If ! Empty(SE1->E1_XRENTA)

		cNumRental := SE1->E1_XRENTA

		CN9->(dbOrderNickName("NRENTAL")) //CN9_FILIAL+CN9_XRENTA

		If CN9->(MSseek(FWxFilial("CN9") + cNumRental))
			
			CN9->(RecLock("CN9", .F.))
			CN9->CN9_XSTSRE := '2' // faturado
			CN9->(MsUnlock())
		EndIf
	Endif

	FwRestArea(aAreaSE1)
    FwRestArea(aAreaCN9)
    FwRestArea(aArea)

Return()
