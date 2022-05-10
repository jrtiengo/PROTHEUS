#INCLUDE 'TOTVS.CH'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³NOVO5     ºAutor  ³Microsiga           º Data ³  05/02/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SCIF050( aCab, nOpcao, cTitulo )

	//Local aArea      := GetArea()
	Local aReturn    := { .f., "" }
	Local nModuloAnt := nModulo	// Guarda o modulo atual
	Local cLog       := ""
	Local aLog       := {}
	
	Default nOpcao := 3
	
	If nOpcao == 5
	
		Default cTitulo := SE2->E2_PREFIXO + "-" + SE2->E2_NUM + "-" + SE2->E2_PARCELA + "- Fornecedor: " + SE2->E2_FORNECE + "/" + SE2->E2_LOJA + "." 
	EndIf

	//Begin Transaction   		

		nModulo := 6 // Financeiro
		lAutoErrNoFile:= .T.
		lMsErroAuto := .f.
		MSExecAuto({|x,y,Z| FINA050(x,y,Z)},aCab,nOpcao,nOpcao) 

		If !lMsErroAuto			
			
			If nOpcao == 3 // Inclusao
			
				cLog := "Geracao do titulo no contas a pagar concluido com sob numero: " + SE2->E2_NUM + "/" + SE2->E2_PARCELA + CRLF
			ElseIf nOpcao == 5	// Exclusao
			
				cLog := "Exclusao do titulo no contas a pagar sob numero: " + cTitulo + CRLF
			EndIf

			aReturn[1] := .t.
			aReturn[2] := cLog
		Else			

			aLog := GetAutoGRLog()
			aEval(aLog,{|x| cLog += x + CRLF})
			aReturn[1] := .f.
			aReturn[2] := cLog 

			//DisarmTransaction()
		EndIf		
	//End Transaction

	nModulo := nModuloAnt // Restaura modulo atual
	
	//RestArea ( aArea )
	
Return ( aReturn )