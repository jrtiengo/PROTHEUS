User function TPBenef()
	Local cTipoBenef:='2'
	If !EMPTY(SE2->E2_XCOD)

		If LEN(AllTrim(Posicione("SA2",1,xFilial("SA2")+SE2->E2_XCOD,"SA2->A2_CGC"))) < 14
			cTipoBenef:='1'
		Else
			cTipoBenef:='2'
		Endif
	Else
		If LEN(AllTrim(SA2->A2_CGC)) < 14
			cTipoBenef:='1'
		Else
			cTipoBenef:='2'
		Endif
	Endif
Return (cTipoBenef) 
