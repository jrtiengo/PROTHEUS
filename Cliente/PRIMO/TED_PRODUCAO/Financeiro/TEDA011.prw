#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} TEDA011
Consulta cnpj.
Para cnab BBM.
@author Mauro - Solutio.
@since 16/10/2020
@version 1.0
@return ${return}, ${return_description}
@param _cNum, , descricao
@type function
/*/

User function TEDA011()

	Local _cRet := ""
	
	If SM0->M0_CGC == "83056804000210"
		_cRet := "83056804000210"
	ElseIf SM0->M0_CGC == "91169607000155"
		_cRet := "91169607000155"
	Else
		_cRet := "83056804000130"
	EndIf	
	
Return(_cRet)
