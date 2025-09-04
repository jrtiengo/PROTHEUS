#Include 'TOPCONN.CH'
#Include 'PROTHEUS.CH'
#Include 'PARMTYPE.CH'
#Include "FWMVCDEF.ch"

/*/{Protheus.doc} CRMA980
description Pontos de entrada no cadastro de Bens - MV_MVCSA1 
@type function
@version  
@author Tiengo Junior
@since 28/08/2025
@return variant, return_description
/*/
User Function MNTA080()

	Local cMsgErro		:= ""
	Local aParam		:= PARAMIXB
	Local OObj       	:= ''
	Local cIDPonto   	:= ''
	Local cIDModel   	:= ''
	Local xRet		    := .T.

	If ValType(APARAM)=='A'

		If Len(APARAM) > 0

			OObj       := APARAM[1]
			cIDPonto   := APARAM[2]
			cIDModel   := APARAM[3]

			IF cIDPonto == "FORMCOMMITTTSPOS"

			Elseif cIDPonto == "FORMPOS"

				If OOBJ:GetOperation() == 3  .or. OOBJ:GetOperation() == 4 .or. OOBJ:GetOperation() == 5
					If ! u_AtivoTrac(@cMsgErro)
						Aviso("Falha na integração com TracOS", cMsgErro, {"OK"}, 1, "Tractian")
					Endif
				Endif
			Endif
		Endif
	Endif

Return(xRet)
