#include 'protheus.ch'
#include 'parmtype.ch'
#include "rwmake.ch"

/*/{Protheus.doc} MT120OK
O ponto se encontra no final da fun��o e � disparado ap�s a confirma��o dos itens 
da getdados e antes do rodap� da dialog do PC, deve ser utilizado para valida��es 
especificas do usu�rio onde ser� controlada pelo retorno do ponto de entrada oqual 
se for .F. o processo ser� interrompido e se .T. ser� validado.

Para preencher o campo CONTA com a conta do cadastro de produtos e validar
preenchimento do campo forma de pagamento conforme o cadastro do fornecedor.
@author Mauro - Solutio.
@since 22/01/2021
@version 6
@return ${return}, ${return_description}

@type function
/*/

User Function MT120OK()

	Local lRet 		:= .T.
	Local nX		:= 0
	Local _cConta	:= ""
	// Local _cFrmPag	:= ""
	Local nPosPro  	:= aScan( aHeader, {|x| AllTrim(Upper(X[2])) == "C7_PRODUTO"	})
	Local nPosCnt  	:= aScan( aHeader, {|x| AllTrim(Upper(X[2])) == "C7_CONTA"		})
	
	For nX:=1 to len(aCols)
		
		_cConta := Posicione( "SB1", 1, xFilial("SB1") + aCols[ nX, nPosPro ], "B1_CONTA" )
		aCols[ nX, nPosCnt ] := _cConta

	Next nX
	/*
	// Atualiza a vari�vel p�blica cXTipo, criada por outro ponto de entrada.
	_cFrmPag := Posicione("SA2", 1, xFilial("SA2") + cA120Forn + cA120Loj, "A2_FRMPAG")
	cXTipo := Alltrim(_cFrmPag)

	If Empty(cXTipo)
		lRet := .F.
	EndIf
	*/
return(lRet)
