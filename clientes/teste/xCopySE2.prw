#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static nRecSE2 := 0

//-------------------------------------------------------------------
/*/{Protheus.doc} xCopySE2
Copia o título do contas a pagar

@author  Jonatas Martins
@since   09/04/2020
/*/
//-------------------------------------------------------------------
User Function xCopySE2()
	Local aArea    := GetArea()
	Local aAreaSE2 := SE2->(GetArea())
	Local aAreaSED := SED->(GetArea())
	Local bExecuta := {|| FA050Inclu("SE2", SE2->(Recno()), 3)}

	If VldCopy()[1]
		nRecSE2 := SE2->(Recno())
		FINA050(,,, bExecuta,,,,,,,, )
	EndIf

	RestArea(aAreaSED)
	RestArea(aAreaSE2)
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J273PreVld
Valida a cópia do título

@author  Jonatas Martins
@since   09/04/2020
/*/
//-------------------------------------------------------------------
Function VldCopy()
Local lPEPreVld := ExistBlock("J273Pre")
Local lContinue := .F.
Local cMsgErro  := ""
Local cTitErro  := ""

	SA2->(DbSetOrder(1)) // A2_FILIAL + A2_FORNECE + A2_LOJA
	SA2->(DbSeek(xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA))

	SED->(DbSetOrder(1)) // ED_FILIAL + ED_CODIGO
	SED->(DbSeek(xFilial("SED") + SE2->E2_NATUREZ))

	Do Case

		Case SA2->A2_MSBLQL == "1" // Fornecedor Bloqueado
			cMsgErro := "Não é permitido copiar título de fornecedor bloqueado." // "Não é permitido copiar título de fornecedor bloqueado."
			cTitErro := "Fornecedor bloqueado!" // "Fornecedor bloqueado!"

		Case SED->ED_MSBLQL == "1" .Or. SED->ED_COND == "1"
			cMsgErro := "Não é permitido copiar título de natureza bloqueada." // "Não é permitido copiar título de natureza bloqueada."
			cTitErro := "Natureza bloqueada!" // "Natureza bloqueada!"

		Case lPEPreVld
			lContinue := ExecBlock("J273Pre", .F. ,.F., {SE2->(Recno())})

			If ValType(lContinue) <> "L"
				lContinue := .F.
			EndIf
		OtherWise
			lContinue := .T.
	End Case

	If (!lContinue) .And. (!Empty(cMsgErro) .Or. !Empty(cTitErro))
		ApMsgAlert(cMsgErro, cTitErro)
	EndIf

Return {lContinue, cMsgErro, cTitErro}

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadVar
Copia os dados do título posicionado para as variáveis de memória do
contas a pagar que está sendo aberto no modo de inclusão

@author  Jonatas Martins
@since   09/04/2020
/*/
//-------------------------------------------------------------------
Function LoadVar()
	Local aSE2Struct := SE2->(DBStruct())
	Local lPENoCopy  := ExistBlock("J273NCop")
	Local cPENoCopy  := ""
	Local cField     := ""
	Local xValue     := Nil
	Local nStru      := 0
	Local cSE2NoCopy := ""

	cSE2NoCopy += "E2_VENCTO |E2_VENCORI|E2_VENCREA|E2_BAIXA  |E2_NUMBOR |E2_DTBORDE|"
	cSE2NoCopy += "E2_LOTE   |E2_MOVIMEN|E2_VALLIQ |E2_NUMLIQ |E2_BCOCHQ |E2_AGECHQ |"
	cSE2NoCopy += "E2_BAIXA  |E2_BCOPAG |E2_LA     |E2_CTACHQ |E2_STATUS |E2_TITPAI |"
	cSE2NoCopy += "E2_TIPOLIQ|E2_DATALIB|E2_USUALIB|E2_STATLIB|E2_CODAPRO|E2_TIPOFAT|"
	cSE2NoCopy += "E2_FLAGFAT|E2_FATPREF|E2_FATURA |E2_DTFATUR|E2_FATFOR |E2_FATLOJ |"
	cSE2NoCopy += "E2_LINDIG |E2_CODBAR "

	If lPENoCopy
		cPENoCopy := ExecBlock("J273NCop", .F. ,.F., {cSE2NoCopy})

		If ValType(cPENoCopy) == "C" .And. !Empty(cPENoCopy)
			cSE2NoCopy := cPENoCopy
		EndIf
	EndIf

	For nStru := 1 To Len(aSE2Struct)
		cField := aSE2Struct[nStru][1]
		
		If PADR(cField, 10) $ cSE2NoCopy
			If cField = "E2_STATLIB"
				CriaVar("E2_STATLIB", .T.)
			EndIf
			Loop
		EndIf

		Do Case
			Case cField == "E2_FILIAL"
				xValue := xFilial("SE2")

			Case cField == "E2_NUM"
				xValue := ProxTitulo("SE2", SE2->E2_PREFIXO)

			Case cField == "E2_EMISSAO" .Or. cField == "E2_EMIS1"
				xValue := dDataBase

			Case cField == "E2_SALDO"
				xValue := SE2->E2_VALOR

			Case cField == "E2_ORIGEM"
				xValue := "FINA050"

			OtherWise
				xValue := SE2->(FieldGet(FieldPos(cField)))
		End Case
		
		&("M->" + cField) := xValue
	Next nField

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} JGetField
Retorna o valor de um campo a partir da tabela posicionada

@param cTab, nome da tabela
@param cCampo, nome do campo sem o prefixo da tabela

@Return xValue, valor do campo

@author  Bruno Ritter
@since   09/04/2020
/*/
//-------------------------------------------------------------------
Static Function JGetField(cTab, cCampo)
	Local xValue := (cTab)->(FieldGet(FieldPos(cTab + "_" + cCampo)))
Return xValue
