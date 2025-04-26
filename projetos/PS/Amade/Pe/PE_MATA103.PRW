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
			//0-Nao enviado - 1-Enviado 3-Erros
			If SF1->F1_ZSTSWMS == "0" .or. SF1->F1_ZSTSWMS == "1" .or. SF1->F1_ZSTSWMS == "3"
				lRet := .F.

				FWAlertWarning("Entrar em contato com a Logistica(WMS)", "Pre-nota ainda em processamento pelo WMS")
			Endif
		Endif
	Endif

Return( lRet )

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

User Function MT103LEG()

	Local aLegNew := PARAMIXB[1]    as array

	aAdd( aLegNew, {"BR_PRETO_0"    ,"Não enviado ao WMS"})
	aAdd( aLegNew, {"BR_PRETO_1"    ,"Enviado ao WMS"})
	aAdd( aLegNew, {"BR_PRETO_2"    ,"Processado"})
	aAdd( aLegNew, {"BR_PRETO_3"    ,"Processado com erros WMS"} )

Return(aLegNew)

User Function MT103EXC()

	Local	lRet := .T.

	If SF1->F1_ZSTSWMS == "0" .or. SF1->F1_ZSTSWMS == "4" .or. SF1->F1_ZSTSWMS == "" //Se não for enviado ou não faz parte do WMS

		//1=Aguardando Cancelamento; 2=Cancelamento Autorizado; 3=Cancelamento Negado
		If SF1->F1_ZCANCW == ''
			If RecLock("SF1",.F.)

				SF1->F1_ZCANCW := "1"

				SF1->(MSUnLock())
			Endif
		ElseIf SF1->F1_ZCANCW == '1'

			FWAlertWarning("Aguardando Retorno WMS", "Integraçao WMS")
			lRet := .F.
		ElseIf SF1->F1_ZCANCW == '3'

			FWAlertWarning("Cancelamento Negado", "Integraçao WMS")
			lRet := .F.
		Else
			lRet := .T.
		Endif
	Else

		lRet := .F.
		FWAlertWarning("Nota já processada, não poderá ser excluida", "Integraçao WMS")
	EndIf

Return (lRet)

