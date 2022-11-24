#include "protheus.ch"
#include "rwmake.ch"

/*/{Protheus.doc} MT110LOK
PE para validar conta e centro de custo
@type function
@author Tiengo BMTEC
@since 27/10/2022
@version 1.0
@return ${return}, ${return_description}
@example
@see https://tinyurl.com/5n8vcrzf
/*/

User Function MT110LOK()

Private _nCC    := aScan(aHeader,{|_xCpo| AllTrim(_xCpo[2]) == "C1_CC"})
Private _nCONTA	:= aScan(aHeader,{|_xCpo| AllTrim(_xCpo[2]) == "C1_CONTA"})
Private _lRet	:= .T.
Private _aArea	:= GetArea()

If !Empty( aCols[n,_nCONTA] ) .and. Empty( aCols[n,_nCC] )

	dbSelectArea("CT1")
	dbSetOrder(1)
	If dbSeek( xFilial("CT1") + aCols[n,_nCONTA] ) .and. CT1->CT1_ACCUST = "1"
		
		MsgAlert("Centro de Custos obrigatorio para Conta Contabil informada!","ATENCAO")
		_lRet	:= .F.	
	
	Endif

Endif

RestArea(_aArea)

return(nRet)
