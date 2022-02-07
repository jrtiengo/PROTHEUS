#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} MTCOLSE2
Ponto de Entrada para Validação da Condição de Pagamento. Utilizado em conjunto com o PE_MT100TOK
@type function
@version 2.0
@author solutio
@since 12/11/2020
@return array, Retorna Array de títulos
/*/
User Function MTCOLSE2()
//Valida Prazo mínimo de pagamento NF
	Local aColsE2  := PARAMIXB[1] //aCols de duplicatas linha 1
	Local nOpc      := PARAMIXB[2] //0-Tela de visualização / 1-Inclusão ou Classificação
	Local nDiasPag  := SuperGetMV("ES_MT100PG",.F.,0) // Minimo de dias entre Duplicatas e Emissão da NF
	Local cCPLivre  := SuperGetMV("ES_MT100CP",.F., "001") // Condições de pag livre de validação na entrada
	Local lValdCond := .T.
	Local X_PARCELA := 1
	Local X_PAR_DAT := 2
	Local X_PAR_VLR := 3
	Local cRotina   := FUNNAME()
	Local _lCND5F 	:= .T. //Valid.CND 5F - A2_YCND5FE

	// Jean Rehermann - Solutio IT - 05/04/2021
	// Tratar a variável, pois quando a função principal é User Function tem que ter o U_ no nome
	// e a FUNNAME não trata isso
	If cRotina == "FBTRS006"
		cRotina := "U_"+ cRotina
	EndIf

	//Se variável
	IF ( Type("lValidCondPag") == "U" )
		_SetNamedPrvt( "lValidCondPag" , .T. ,cRotina) // Cria variável Privada no Escopo do MATA103 / MATA103X//_SetOwnerPrvt( "lValidCondPag" , .T. )
	ENDIF

	//
	lValdCond := !(ccondicao $ cCPLivre) .AND. !Empty(aColsE2[X_PARCELA][X_PAR_VLR])

	If lValdCond

		//If !Empty(ccondicao) // retirado permissão de condição em branco
		If nOpc > 0 //inclusão ou classificação

			if (FWIsInCallStack("MATA103"))
				dbSelectArea("SA2")
				dbSetOrder(1)
				dbSeek(xFilial("SA2") + cA100For + cLoja)
				if (Found() .and. (SA2->A2_YCND5FE == "N" .or.  Empty(SA2->A2_YCND5FE) ))
					_lCND5F := .F.
				endif
			endif

			//Regra: Data da Primeira parcela precisa ser  maior que 7 dias, para pagamento.
			lValidCondPag := dDatabase + nDiasPag <=  aColsE2[X_PARCELA][X_PAR_DAT]
			// Só permite pagamentos na Quinta-Feira
			If lValidCondPag .and. _lCND5F .AND. ! (DOW(aColsE2[X_PARCELA][X_PAR_DAT]) == 5 )
				lValidCondPag := .F.
			Endif
		Endif
		//Endif
	Else
		lValidCondPag := .T.
	Endif

Return aColsE2
