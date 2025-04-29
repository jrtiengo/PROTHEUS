#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MT103INC
Documento de entrada pode ser incluído ou classificado
@type     function
@author      Eurai Rapelli
@since       2023.01.01
/*/

User Function MT103INC()

	Local lRet      := .T.          as logical
	Local lClass    := PARAMIXB     as logical

	If lClass
		If ! IsBlind()
			//So sera classificado se o WMS estiver retornado
			If SF1->F1_ZSTSWMS <> '2'
				lRet := .F.
				FWAlertWarning("Entrar em contato com a Logistica(WMS)", "Pre-nota ainda em processamento pelo WMS")
			Endif
		Endif
	Endif

Return( lRet )

/*/{Protheus.doc} MT103COR
Ponto de entrada para as regras de cores do documento de entrada.
@type     user function
@author   tiengo
@since   28042025
/*/
User Function MT103COR()

	Local aNewCores := {}   as array
	Local nX        := 0    as numeric

	aAdd(aNewCores,{'F1_ZSTSWMS=="0"'   ,'BR_PRETO_0' })
	aAdd(aNewCores,{'F1_ZSTSWMS=="1"'   ,'BR_PRETO_1' })
	aAdd(aNewCores,{'F1_ZSTSWMS=="2"'   ,'BR_PRETO_2' })
	aAdd(aNewCores,{'F1_ZSTSWMS=="3"'   ,'BR_PRETO_3' })

	For nX := 1 to Len(PARAMIXB[1])

		aAdd(aNewCores  ,PARAMIXB[1][nX])

	Next nX

Return(aNewCores)

/*/{Protheus.doc} MT103LEG
Ponto de entrada para cores da legenda do documento de entrada.
@type     user function
@author   tiengo
@since   28042025
/*/
User Function MT103LEG()

	Local aLegNew := PARAMIXB[1]    as array

	aAdd( aLegNew, {"BR_PRETO_0"    ,"Não enviado ao WMS"})
	aAdd( aLegNew, {"BR_PRETO_1"    ,"Enviado ao WMS"})
	aAdd( aLegNew, {"BR_PRETO_2"    ,"Processado"})
	aAdd( aLegNew, {"BR_PRETO_3"    ,"Processado com erros WMS"} )

Return(aLegNew)

/*/{Protheus.doc} MT103EXC
Ponto de entrada para validação da exclusão do documento de entrada.
@type     user function
@author   tiengo
@since   28042025
/*/
User Function MT103EXC()

	Local	lRet := .T.

	If ! IsBlind()
		If SF1->F1_ZSTSWMS <> '0'
			//1=Aguardando Cancelamento; 2=Cancelamento Autorizado; 3=Cancelamento Negado
			If Empty(SF1->F1_ZCANCW)
				FWAlertWarning("Exclusao/Estorno nao permitido, solicite o cancelamento ao WMS!", "Exclusao nao permitida")
				lRet := .F.
			ElseIf SF1->F1_ZCANCW == '1'
				FWAlertWarning("Exclusao/Estorno nao permitido, aguardando Retorno WMS", "Exclusao nao permitida")
				lRet := .F.
			ElseIf SF1->F1_ZCANCW == '3'
				FWAlertWarning("Exclusao/Estorno nao permitido, cancelamento Negado", "Exclusao nao permitida")
				lRet := .F.
			Else
				FWAlertSucess("Cancelamento Autorizado", "Exclusao permitida")
				lRet := .T.
			Endif
		Else 
			lRet := .T.
		Endif
	Endif

Return (lRet)

