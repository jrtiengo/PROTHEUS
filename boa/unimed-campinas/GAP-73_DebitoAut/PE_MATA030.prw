#INCLUDE 'TOPCONN.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#Include "FWMVCDEF.ch"
#INCLUDE 'TRYEXCEPTION.CH'

#DEFINE ENTER 	CHR(13) + CHR(10)
#DEFINE CTITAPP	"Pontos de Entrada - MATA030"

/*/{Protheus.doc} CRMA980
description Pontos de entrada no cadastro de Clientes - MV_MVCSA1 
@type function
@version  
@author Márcio M. Pereira
@since 4/10/2025
@return variant, return_description
/*/
USER FUNCTION CRMA980()

	LOCAL OEXCEPTION
	LOCAL CMSGERROR		:= ""
	LOCAL APARAM		:= PARAMIXB
	LOCAL OOBJ       	:= ''
	LOCAL CIDPONTO   	:= ''
	LOCAL CIDMODEL   	:= ''
	LOCAL XRET		:= .T.

	TRYEXCEPTION

	if VALTYPE(APARAM)=='A'

		IF LEN(APARAM) > 0 //.AND. !L030AUTO

			OOBJ       := APARAM[1]
			CIDPONTO   := APARAM[2]
			CIDMODEL   := APARAM[3]

			IF CIDPONTO == "FORMCOMMITTTSPOS" .AND. OOBJ:GetOperation() == 3
/*
				DBSELECTAREA("CTD")
				DBSETORDER(1)
				IF !DBSEEK(XFILIAL("CTD") + "C" + ALLTRIM(SA1->A1_COD) + ALLTRIM(SA1->A1_LOJA))

					CTD->(RECLOCK("CTD", .T.))

					CTD->CTD_FILIAL := XFILIAL("CTD")
					CTD->CTD_ITEM	:= "C" + ALLTRIM(SA1->A1_COD) + ALLTRIM(SA1->A1_LOJA)
					CTD->CTD_CLASSE	:= "2"
					CTD->CTD_NORMAL	:= "0"
					CTD->CTD_DESC01	:= ALLTRIM(SA1->A1_NOME)
					CTD->CTD_DESC02 := ALLTRIM(SA1->A1_NOME)
					CTD->CTD_BLOQ	:= "2"
					CTD->CTD_DTEXIS	:= CTOD("01/01/1980")
					CTD->CTD_ITLP	:= "C" + ALLTRIM(SA1->A1_COD) + ALLTRIM(SA1->A1_LOJA)

					CTD->(MSUNLOCK())

				ENDIF
*/

			Elseif CIDPONTO == "FORMPOS"

				If SA1->A1_COBDEB == '1'
					//Inclusao
					If OOBJ:GetOperation() == 3
						DbSelectArea("SZ6")
						If ! SZ6->(MSSeek(FWxFilial("SZ6") + SA1->A1_COD + SA1->A1_LOJA))
							SZ6->(RecLock("SZ6", .T.))

							SZ6->Z6_FILIAL    := FWxFilial("SZ6")
							SZ6->Z6_CODCLI    := SA1->A1_COD
							SZ6->Z6_LOJA      := SA1->A1_LOJA
							SZ6->Z6_CODDBA    := SA1->A1_DEBA
							SZ6->Z6_BCOA      := SA1->A1_XBCO
							SZ6->Z6_AGENA     := SA1->A1_XAGE
							SZ6->Z6_DIGAGEA   := SA1->A1_XDAGE
							SZ6->Z6_CTAATU    := SA1->A1_XCONT
							SZ6->Z6_DTAMOV    := dDatabase

							SZ6->(MsUnlock())
						Endif

					Elseif OOBJ:GetOperation() == 4

						DbSelectArea("SZ6")
						SZ6->(DbSetOrder(1)) //Z6_FILIAL+Z6_CODCLI+Z6_LOJA
						If SZ6->(MSSeek(FWxFilial("SZ6") + SA1->A1_COD + SA1->A1_LOJA))

							SZ6->(RecLock("SZ6", .F.))

							SZ6->Z6_FILIAL    := FWxFilial("SZ6")
							SZ6->Z6_CODCLI    := SA1->A1_COD
							SZ6->Z6_LOJA      := SA1->A1_LOJA
							SZ6->Z6_CODDBN    := SA1->A1_DEBA
							SZ6->Z6_BCON      := SA1->A1_XBCO
							SZ6->Z6_AGENN     := SA1->A1_XAGE
							SZ6->Z6_DIGAGEN   := SA1->A1_XDAGE
							SZ6->Z6_CTANOVA   := SA1->A1_XCONT
							SZ6->Z6_DTAMOV    := dDatabase

							SZ6->(MsUnlock())
						Endif

					Elseif OOBJ:GetOperation() == 5

						DbSelectArea("SZ6")
						SZ6->(DbSetOrder(1)) //Z6_FILIAL+Z6_CODCLI+Z6_LOJA
						If SZ6->(MSSeek(FWxFilial("SZ6") + SA1->A1_COD + SA1->A1_LOJA))
							SZ6->(RecLock("SZ6", .F.))
							SZ6->(DBdelete())
							SZ6->(MsUnlock())
						Endif
					Endif
				Endif
			ENDIF
		ENDIF
	ENDIF

	CATCHEXCEPTION USING OEXCEPTION

	IF ( VALTYPE( OEXCEPTION ) == "O" )
		CMSGERROR += CAPTUREERROR()
		U_AdminMsg("[CUSTOMERVENDOR] " + DToC(Date()) + " - " + Time() + " -> " + CMSGERROR, IsBlind())
	ENDIF

	ENDEXCEPTION NODELSTACKERROR

RETURN XRET
