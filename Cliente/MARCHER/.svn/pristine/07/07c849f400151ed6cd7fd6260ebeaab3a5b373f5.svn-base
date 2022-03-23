#Include "Topconn.ch"
#Include "Rwmake.ch"
#Include "Protheus.ch"


/*/{Protheus.doc} MT260TOK
//Ponto de entrada para validar informacoes inseridas pelo usuario
@author Celso Rene
@since 09/10/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function MT260TOK()

	Local _lRet		:= .T.
	Local _aArea 	:= GetArea()
	Local _nSaldo	:= 0

	If (FunName() == "MATA260")

		dbSelectArea("SB2")
		dbSetOrder(1)
		If (dbSeek(xFilial("SB2") + CCODORIG + CLOCORIG ))
			_nSaldo := SB2->B2_QATU - SB2->B2_RESERVA //SaldoSB2()
			If (_nSaldo <= 0)
				_lRet := .F.
				MsgAlert("Não existe quantidade disponível para o produto: "+ CCODORIG + " e armazem: " + CLOCORIG + ".","Quantidade Insuficiênte!")	
			EndIf
		Else
			_lRet := .F.
			MsgAlert("Não existe quantidade disponível para o produto: "+ CCODORIG + " e armazem: " + CLOCORIG + ".","Quantidade Insuficiênte!")
		EndIf

	EndIf

	RestArea(_aArea)

Return(_lRet)
