#Include "Topconn.ch"
#Include "Rwmake.ch"
#Include "Protheus.ch"

/*/{Protheus.doc} A261TOK
//Ponto de entrada MOD2 - Valida movimento de transferência
@author Celso Rene
@since 09/10/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

User Function A261TOK()

	Local _lRet		:= .T.
	Local _aArea 	:= GetArea()
	Local _nSaldo	:= 0
	Local x         := 0

	For x:= 1 to Len(aCols)

		dbSelectArea("SB2")
		dbSetOrder(1)
		If (dbSeek(xFilial("SB2") + aCols[x][1] + aCols[x][4] ))
			_nSaldo := SB2->B2_QATU - SB2->B2_RESERVA //SaldoSB2()
			If (_nSaldo <= 0)
				_lRet := .F.
				MsgAlert("Não existe quantidade disponível para o produto: "+ aCols[x][1] + " e armazem: " + aCols[x][4] + ".","Quantidade Insuficiênte!")
				x:= Len(aCols) + 1	
			EndIf
		Else
			_lRet := .F.
			MsgAlert("Não existe quantidade disponível para o produto: "+ aCols[x][1] + " e armazem: " + aCols[x][4] + ".","Quantidade Insuficiênte!")
			x:= Len(aCols) + 1
		EndIf

		_nSaldo:= 0

	Next x

	RestArea(_aArea)

Return(_lRet)
