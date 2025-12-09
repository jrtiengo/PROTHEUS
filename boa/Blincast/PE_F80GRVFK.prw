#include "protheus.ch"
#include "totvs.ch"

/*/{Protheus.doc} F80GRVFK
O ponto de entrada F80GRVFK sera executado para gravar dados complementares das tabelas FK´s. 
@type function
@version V 1.00
@author Tiengo Junior
@since 09/12/2025
@link https://tdn.totvs.com.br/pages/releaseview.action?pageId=268817868
/*/

User Function F80GRVFK()

	Local aArea 		:= FwGetArea()
	Local aAreaSE2      := SE2->(FwGetArea())
	Local aAreaCN9 	    := CN9->(FwGetArea())
	Local oObj          := ParamIxb[1]
	Local nOpc          := ParamIxb[2]
	Local cNRental    := ''

	If nOpc == 1 //Baixa

		If ! Empty(SE2->E2_XRENTA)

			cNRental := SE2->E2_XRENTA

			CN9->(dbOrderNickName("NRENTAL")) //CN9_FILIAL+CN9_XRENTA

			If CN9->(MSseek(FWxFilial("CN9") + cNRental))
				CN9->(RecLock("CN9", .F.))
				CN9->CN9_XSTSRE := '3' // Adimplente”
				CN9->(MsUnlock())
			EndIf
		Endif
	Endif

	FwRestArea(aAreaSE2)
	FwRestArea(aAreaCN9)
	FwRestArea(aArea)

Return(oObj)
