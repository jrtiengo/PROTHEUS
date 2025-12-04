#Include 'TOTVS.ch'
#Include 'TopConn.ch'
#Include 'Protheus.ch'

/*/{Protheus.doc} LCJF1VLD
description O ponto de entrada FA070CAN Valida se o faturamento pode ser realizado.
@type function
@version  
@author Tiengo Junior
@since 14/10/2025
@param
@See https://tdn.totvs.com/pages/releaseview.action?pageId=592556514
@return Lógico (.T., .F.)
/*/

User Function LCJF1VLD()

	Local lRet := .T.

	//Se a locação for de repasse e o campo de status não estiver apto a faturar, realiza o bloqueio do faturamento
	FPA->(DbSetOrder(1))// FPA_FILIAL+FPA_PROJET+FPA_OBRA+FPA_SEQGRU+FPA_CNJ
	If FPA->(MSSeek(FWxFilial("FPA")+ FPY->FPY_PROJET))
		If FPA->FPA_XREPAS = '1' //.and. FPA->FPA_XSTSRE = '0'
			FWAlertWarning( "Verifica o Faturamento do contrato no SIGAGCT!", "Locação não está apto para faturar" )
			lRet := .F.
		EndIf
	Endif

Return(lRet)
