#include "protheus.ch"
#include "totvs.ch"

/*/{Protheus.doc} SF2460I
description localizado após a atualização das tabelas referentes à nota fiscal (SF2/SD2). 
O Ponto de entrada é executado após a exibição da tela de contabilização On-Line, mas antes da contabilização oficial.
@type function
@version  
@author Tiengo Junior
@since 11/10/2025
@param oSelf, object, param_description
@param lSchedule, logical, param_description
@param nRecno, numeric, param_description
@return variant, return_description
/*/

User Function SF2460I()

	Local aArea	    := FWGetArea()
	Local aAreaSE1  := SE1->(FWGetArea())
	Local aAreaSF2	:= SF2->(FWGetArea())
	Local aAreaSD2	:= SD2->(FWGetArea())
	Local aAreaCND	:= CND->(FWGetArea())
	Local aAreaSC5  := SC5->(FWGetArea())
	Local cNumRental := ""

	If ! Empty(SC5->C5_XRENTA)

		cNumRental := SC5->C5_XRENTA

		//Grava o numero do Rental na SE1
		CN9->(DbOrderNickName('NRENTAL')) //CN9_FILIAL+CN9_XRENTA

		If CN9->(MSseek(FWxFilial("CN9") + cNumRental))

			SE1->(DBSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			If SE1->(MSSeek(FWxFilial("SE1") + SF2->F2_SERIE + SF2->F2_DOC))

				While ! SE1->(Eof()) .And. FWxFilial("SE1") == SE1->E1_FILIAL .And. SF2->F2_SERIE == SE1->E1_PREFIXO .And. SF2->F2_DOC == SE1->E1_NUM

					Reclock("SE1",.F.)
					SE1->E1_XRENTA  := cNumRental
					SE1->(MsUnlock())

					SE1->(DbSkip())
				EndDo
			EndIf
		Endif
	Endif

	RestArea(aArea)
	RestArea(aAreaSE1)
	RestArea(aAreaSF2)
	RestArea(aAreaSD2)
	RestArea(aAreaCND)
	RestArea(aAreaSC5)

Return()
