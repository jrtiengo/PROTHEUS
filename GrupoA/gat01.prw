#include "protheus.ch"
#include "rwmake.ch"

/*/{Protheus.doc} gat01
Gatilho para retornar C7_PREÇO na rotina MATA173, se não utiliza utiliza a função A120Trigger.
@type function
@author Tiengo BMTEC
@since 27/10/2022
@version 1.0
@return ${return}, ${return_description}
@example
@see https://tinyurl.com/5n8vcrzf
/*/

user function gat01()

    Local nPosPrc   := aScan( aHeader, {|x| AllTrim(Upper(X[2])) == "C7_PRECO" })
    Local nRet      := 0

	IF funname() == "MATA173"
		nRet := M->C7_PRECO
	Else
		nRet := If(A120Trigger("C7_PRECO"),acols[n][nPosPrc],0)
	EndIF
        
return(nRet)
