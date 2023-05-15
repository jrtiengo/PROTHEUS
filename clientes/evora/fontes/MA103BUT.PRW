/*
Botao para sugerir a TES na classificacao do documento de entrada
Ezequiel Pianegonda
23/11/2020
*/
User Function MA103BUT()

	Local aBut := {}

	If ! SuperGetMV('ES_PPFRE',.F.,.F.)
		RETURN aBut
	end

	If ALTERA
		AADD(aBut, {"PRODUTO", {|| AtuTES()}, "Sugere TES Fornecedor"})
	EndIf
Return aBut

/*
Atualiza a TES da linha do item
*/
Static Function AtuTES()

	Local nX:= 0
	Local cTES:= fBuscaCpo("SA2", 1, xFilial("SA2")+cA100For+cLoja, "A2_ETE")
	Local cCampoAux := "D1_TES"

	IF empty(cTEs)
		Alert('TES não informada no cadastro de fornecedor')
		Return
	end

	For nX:= 1 To Len(aCols)
		GDFieldPut("D1_TES", cTES, nX)
		MaColsToFis(aHeader, aCols,, "MT100",.T.,,.T.)  // MATXFIS
		//chama os gatilhos
		_sgati:= ''
		SX7->(dbSetOrder(1))
		SX7->(dbSeek("D1_TES"))

		// Solutio Tiengo 13/04/2023
		//Do While !SX7->(EOF()) .AND. Alltrim(SX7->X7_CAMPO) == "D1_TES"
		//RunTrigger(2, nX,,, PADR(SX7->X7_CAMPO, 10))
		Do While !SX7->(EOF()) .AND. Alltrim(&("SX7->X7_CAMPO")) == Alltrim(cCampoAux)
			cCpoTrigger := &("SX7->X7_CAMPO")
			RunTrigger(	2				,;	 //nTipo (1=Enchoice; 2=GetDados; 3=F3)
			n				,;   //Linha atual da Grid quando for tipo 2
			Nil				,;   //Não utilizado
			,;   //Objeto quando for tipo 1
			cCpoTrigger)		 //Campo que dispara o gatilho
			SX7->(dbskip())
		EndDo

		MaColsToFis(aHeader, aCols,, "MT100", .T.,, .T.)  // MATXFIS
	Next nX

	MaColsToFis(aHeader, aCols,, "MT100", .T.,, .T.)  // MATXFIS
	
Return
