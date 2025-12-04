#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} CNTA121
Ponto de entrada em MVC para a rotina CNTA121 - Nova Medição
@type function
@version V 1.00
@author Tiengo Junior
@since 31/10/2025
@link https://tdn.totvs.com/display/public/PROT/CNTA121+-+Exemplos+pontos+de+entrada_MVC#CNTA121Exemplospontosdeentrada_MVC-03.Importarrateiosparamedi%C3%A7%C3%A3o(CNZAUTRAT)
@obs 
/*/

User Function CNTA121()

	Local aParam    := PARAMIXB
	Local xRet      := .T.             as Logical
	Local oModel    := Nil             as Object
	Local cIdPonto  := ''              as Character
	Local cIdModel  := ''              as Character
	Local nOpc      := 0               as Numeric

	If aParam <>  NIL

		oModel  	:= aParam[1]
		cIdPonto	:= AllTrim(aParam[2])
		cIdModel	:= aParam[3]

		nOpc		:= oModel:GetOperation()

		If cIdPonto == 'MODELVLDACTIVE' .and. FwIsInCallStack("CN121MedEnc")

			//-> Realziar loop na Loop na FPA e posicionar no item que tem REPASSE = 1
			//Posiciona na tabela de locacao x projetos
			FPA->(DbSetOrder(1))// FPA_FILIAL+FPA_PROJET+FPA_OBRA+FPA_SEQGRU+FPA_CNJ
			If FPA->(MSSeek(FWxFilial("FPA")+ CND->CND_XRENTA))
				While ! FPA->(Eof()) .And. FWxFilial("FPA") == CND->CND_FILIAL .And. FPA->FPA_PROJET == CND->CND_XRENTA
					If FPA->FPA_XREPAS == '1'
						FPA->(RecLock("FPA", .F.))
						FPA->FPA_XSTSRE := '1' // APTO FATURADO
						FPA->(MsUnlock())
					Endif
					FPA->(DbSkip())
				Enddo
			EndIf
		EndIf

		If cIdPonto == 'MODELVLDACTIVE' .And. FwIsInCallStack("CN121Estorn")

			//Posiciona na tabela de locacao x projetos
			FPA->(DbSetOrder(1))// FPA_FILIAL+FPA_PROJET+FPA_OBRA+FPA_SEQGRU+FPA_CNJ
			If FPA->(MSSeek(FWxFilial("FPA")+ CND->CND_XRENTA))
				While ! FPA->(Eof()) .And. FWxFilial("FPA") == CND->CND_FILIAL .And. FPA->FPA_PROJET == CND->CND_XRENTA
					If FPA->FPA_XREPAS == '1'
						FPA->(RecLock("FPA", .F.))
						FPA->FPA_XSTSRE := '0' // NAO FATURADO
						FPA->(MsUnlock())
					Endif
					FPA->(DbSkip())
				Enddo
			EndIf
		Endif
	Endif

Return(xRet)
