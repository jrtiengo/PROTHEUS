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

	Local _lRet  
	Local dDtuc := DateDiffDay( Date(), SA1->A1_ULTCOM ) 

	DO CASE

		// Libera se a condição de pagamento for diferente de 510
        CASE SC5->C5_CONDPAG <> '510'
            _lRet := .t.
		
		// Bloqueia se a condição de pagamento for igual a 075
		CASE SC5->C5_CONDPAG == '075'
            _lRet := .f.
		
		// Bloqueia se for primeira compra
        CASE Empty(SA1->A1_PRICOM)
            _lRet := .f.

		// Bloqueia se a última compra for a 60 dias
		CASE dDtUc > 60  
			_lRet := .f.

		// Se Saldo do pedido for maior que o limite de crédito bloqueia
        CASE SA1->A1_SALPED > SA1->A1_LC
            _lRet := .f.

	ENDCASE

Return (_lRet)

/*
Method ClassificaRisco() class RegraCredito

Return
*/
