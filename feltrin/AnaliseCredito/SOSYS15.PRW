#include 'protheus.ch'

/*/{Protheus.doc} SOSYS15
Classe e métodos para definir regras de crédito
@type classe
@version  1.0
@author tiengo
@since 28/09/2022
@return variant, null 
/*/

Class RegraCredito

	Data cPed AS STRING
	Data cCli AS STRING

	Method new() CONSTRUCTOR
	Method Regra()
	//Method ClassificaRisco()

EndClass

Method new(cPedNum,cCodCli) class RegraCredito

	::cPed := cPedNum   // Recebe o número do pedido de venda
	::cCli := cCodCli   // Recebe o código do cliente

Return Self

Method Regra() class RegraCredito

	Local lRet := .T.
	Local dDtuc := DateDiffDay( Date(), SA1->A1_ULTCOM ) 
	Local lCodPag := .T.
	Local lPriCom := .T.
	Local lUltCom := .T.
		
		// Bloqueia se a condição de pagamento for igual a 075
		IF SC5->C5_CONDPAG == '075'
            lCodPag := .F.
		EndIF
		
		// Bloqueia se for primeira compra
        If Empty(SA1->A1_PRICOM)
            lPriCom := .F.
		EndIf

		// Bloqueia se a última compra for a 60 dias
		If dDtUc > 60  
			lUltCom := .F.
		EndiF

		// Caso alguma retornar falso, ele bloqueia o PV
		If (lCodPag = .F. .or. lPriCom = .F. .or. lUltCom = .F.)
			lRet := .F.

			IF lRet = .F.
				dbSelectArea("SC5") 
				RecLock('SC5', .F.) // .F. trava registro para alteração - .T. trava para inclusão
				SC5->C5_BLQ := "6"
				SC5->(MsUnlock())
			EndIF

		EndiF

Return (lRet)

/*
Method ClassificaRisco() class RegraCredito

Return
*/
