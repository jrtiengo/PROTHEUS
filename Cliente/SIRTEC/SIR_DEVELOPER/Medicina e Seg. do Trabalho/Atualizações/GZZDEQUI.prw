#Include "rwmake.ch"
#Include "topconn.ch"
#Include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GZZDEQUI  ºAutor  ³Ezequiel Pianegonda º Data ³  13/07/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ajuste do status de em uso para aguardando devolucao        º±±
±±º          ³dos itens do epc                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GZZDEQUI()
Local nX:= 0

//verifico se existe algum produto acima do atual em uso e altero para aguardando devolucao
For nX:= n-1 To 1 Step -1
	//verifica se a linha nao esta deletada
	If !gdDeleted(nX)
		//se forem o mesmo produto
		If Alltrim(xgdFieldG("ZZD_CODEPC", nX)) == Alltrim(IIF(xType("M->ZZD_CODEPC")=="U", xgdFieldG("ZZD_CODEPC", n), M->ZZD_CODEPC))  //If Alltrim(gdFieldGet("ZZD_CODEPC", nX)) == Alltrim(IIF(Type("M->ZZD_CODEPC")=="U", gdFieldGet("ZZD_CODEPC", n), M->ZZD_CODEPC))
			//se for motivo igual a 1 - Em Uso, troco por 2 - Aguardando Devolucao
			If (xgdFieldG("ZZD_DEV", nX) == '1')  //If gdFieldGet("ZZD_DEV", nX) == '1'
				//ajusto no browser
				gdFieldPut("ZZD_DEV", "2", nX)				
			EndIf
		EndIf
	EndIf
Next nX

Return .T.


// gdFieldGet nao funcioa em LOOP
Static Function xgdFieldG(_cVar,_cNum)

Local _cRet := ""

_cRet := gdFieldGet(_cVar, _cNum)
_cRet := Alltrim(_cRet)

Return(_cRet)


//Verificando tipo = funcionalidade Type nao funciona em Loop
Static Function xType(_cVal)

Local _lRet := .F.

If Type(_cVal) == "A"
	_lRet := .T.
EndIf


Return(_lRet)

