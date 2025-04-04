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

			If SF1->F1_ZSTSWMS == "1"
				lRet := .F.

				FWAlertWarning("Entrar em contato com a Logistica(WMS)", "Pre-nota ainda em processamento pelo WMS")
			Endif
		Endif
	Endif

Return( lRet )

User Function MT103COR()

	Local aNewCores := {}   as array
	Local nX        := 0    as numeric

	aAdd(aNewCores,{'F1_ZSTSWMS=="1"'   ,'BR_PRETO_1' })
	aAdd(aNewCores,{'F1_ZSTSWMS=="2"'   ,'BR_PRETO_2' })
	aAdd(aNewCores,{'F1_ZSTSWMS=="3"'   ,'BR_PRETO_3' })

	For nX := 1 to Len(PARAMIXB[1])

		aAdd(aNewCores  ,PARAMIXB[1][nX])

	Next nX

Return(aNewCores)

User Function MT103LEG()

	Local aLegNew := PARAMIXB[1]    as array

	aAdd( aLegNew, {"BR_PRETO_1"    ,"Não processado WMS"} )
	aAdd( aLegNew, {"BR_PRETO_2"    ,"Processado"} )
	aAdd( aLegNew, {"BR_PRETO_3"    ,"Processado com erros WMS"} )

Return(aLegNew)



