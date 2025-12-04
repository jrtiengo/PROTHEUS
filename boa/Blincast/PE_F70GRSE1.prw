#Include 'TOTVS.ch'
#Include 'TopConn.ch'
#Include 'Protheus.ch'

/*/{Protheus.doc} F70GRSE1
Ponto de Entrada após gravação dos dados da baixa a receber
O ponto de entrada F70GRSE1 é chamado após a baixa do título a receber. Neste momento o SE1 está posicionado
@type function
@version V 1.00
@author Tiengo Junior
@since 14/10/2025
@link https://tdn.totvs.com/display/public/mp/F70GRSE1+-+Referente+a+baixa+proveniente+do+CNAB+--+34779
/*/
User Function F70GRSE1()

    Local aArea 		:= FwGetArea()
    Local aAreaCN9 	    := CN9->(FwGetArea())
	Local aAreaSE1      := SE1->(FwGetArea())
	Local cNumRental 	:= ""

	If ! Empty(SE1->E1_XRENTA)

		cNumRental := SE1->E1_XRENTA

		CN9->(dbOrderNickName("NRENTAL")) //CN9_FILIAL+CN9_XRENTA

		If CN9->(MSseek(FWxFilial("CN9") + cNumRental))
			
			CN9->(RecLock("CN9", .F.))
			CN9->CN9_XSTSRE := '3' // Adimplente”
			CN9->(MsUnlock())
		EndIf
	Endif

	FwRestArea(aAreaSE1)
    FwRestArea(aAreaCN9)
    FwRestArea(aArea)

Return()

