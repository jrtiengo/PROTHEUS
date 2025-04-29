#include 'totvs.ch'
#Include 'Protheus.ch'
#Include 'TopConn.ch'

/*/{Protheus.doc} User Function SF1140I
   Responsável por atualizar as informações do cabeçalho de um Pré-Documento de Entrada.
   0=NE; Não enviado ao WMS
   1=NP; enviado, mas não processo
   2=P; processado
   3=ER; processado com erros
   4=NA nao envia ao WMS  
   Cancelamento: 1=Aguardando Cancelamento; 2=Cancelamento Autorizado; 3=Cancelamento Negado                                  
   @type Function
   @since 01/04/2025
   @author tiengo
/*/
User Function SF1140I()

	Local lInc      := PARAMIXB[1]  as logical
	Local lAlt      := PARAMIXB[2]  as logical

	If lInc .or. lAlt

		If RecLock("SF1",.F.)

			SF1->F1_ZSTSWMS := "0"
			SF1->F1_ZCANCW	:= ""
			SF1->(MSUnLock())
		Endif
	Endif

Return()

/*/{Protheus.doc} User Function A140ALT
   Validar alteracao da Prenota
   @type Function
   @since 01/04/2025
   @author tiengo
   @Return 
   		Se retornado um valor logico Falso (.F.), este P.E. nao deixa excluir a Pre-Nota. 
		Se retornado .T. é confirmada a exclusão da Pre-Nota de Entrada.
/*/
User Function A140ALT()

	Local lRet := .T.	as logical

	If ! IsBlind()
		If SF1->F1_ZSTSWMS <> '0'
			//1=Aguardando Cancelamento; 2=Cancelamento Autorizado; 3=Cancelamento Negado
			If Empty(SF1->F1_ZCANCW)
				FWAlertWarning("Alteracao nao permitida, solicite o cancelamento ao WMS!", "Alteracao nao permitida")
				lRet := .F.
			ElseIf SF1->F1_ZCANCW == '1'
				FWAlertWarning("Alteracao nao permitida, aguardando Retorno WMS", "Alteracao nao permitida")
				lRet := .F.
			ElseIf SF1->F1_ZCANCW == '3'
				FWAlertWarning("Alteracao nao permitida, cancelamento Negado", "Alteracao nao permitida")
				lRet := .F.
			Else
				FWAlertSucess("Cancelamento Autorizado", "Alteracao permitida")
				lRet := .T.
			Endif
		Else
			lRet := .T.
		Endif
	Endif

Return(lRet)
/*/{Protheus.doc} User Function A140Exc
   Validar exclusao pre nota
   @type Function
   @since 01/04/2025
   @author tiengo
   @Return 
   		Se retornado um valor logico Falso (.F.), este P.E. nao deixa excluir a Pre-Nota. 
		Se retornado .T. é confirmada a exclusão da Pre-Nota de Entrada.
/*/
User Function A140Exc()

	Local lRet := .T.   as logical

	If ! IsBlind()
		If SF1->F1_ZSTSWMS <> '0'
			//1=Aguardando Cancelamento; 2=Cancelamento Autorizado; 3=Cancelamento Negado
			If Empty(SF1->F1_ZCANCW)
				FWAlertWarning("Exclusao nao permitida, solicite o cancelamento ao WMS!", "Exclusao nao permitida")
				lRet := .F.
			ElseIf SF1->F1_ZCANCW == '1'
				FWAlertWarning("Exclusao nao permitida, aguardando Retorno WMS", "Exclusao nao permitida")
				lRet := .F.
			ElseIf SF1->F1_ZCANCW == '3'
				FWAlertWarning("Exclusao nao permitida, cancelamento Negado", "Exclusao nao permitida")
				lRet := .F.
			Else
				FWAlertSucess("Cancelamento Autorizado", "Exclusao permitida")
				lRet := .T.
			Endif
		Else
			lRet := .T.
		Endif
	Endif

Return(lRet)

/*/{Protheus.doc} User Function MT140COR
   Adicionar novas cores para projeto WMS
   @type Function
   @since 01/04/2025
   @author tiengo
/*/
User Function MT140COR()

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

/*/{Protheus.doc} User Function MTA140MNU
   Adicionar botão para alterar se envia ou não ao WMS
   @type Function
   @since 01/04/2025
   @author tiengo
/*/

User Function MTA140MNU

	aAdd(aRotina,{OemToAnsi("Altera Envio WMS ?")	,"U_PSAUX001", 0 , 02, 0, nil})
	aAdd(aRotina,{OemToAnsi("Cancela no WMS ?")		,"U_PSAUX002", 0 , 02, 0, nil})

Return()

/*/{Protheus.doc} User Function PSAUX001
   Altera Status de envio
   @type Function
   @since 01/04/2025
   @author tiengo
/*/
User Function PSAUX001()

	Local cParam	:= ""	 as character

	If FWSX6Util():ExistsParam("PS_USTWMSE")
		cParam := GetMV("PS_USTWMSE")
	Else
		cParam := SuperGetMV("PS_USTWMSE", .F., "000000")
	Endif

	if ! __cUserID $ cParam
		FWAlertError("Usuario sem acesso!", "Integração WMS!")
		Return()
	Endif

	If SF1->F1_ZSTSWMS == '0'
		If FWAlertYesNo("Você deseja cancelar o envio ao WMS da nota?" +' '+ SF1->F1_DOC, "Envio WMS!")
			If RecLock("SF1",.F.)
				SF1->F1_ZSTSWMS := "4"
				SF1->(MSUnLock())
				FWAlertSuccess("Registro gravado com sucesso!", "Integração WMS!")
			Endif
		Endif
	Else
		FWAlertError("Nao e possivel alterar, Prenota - ja enviada ao WMS!", "Integração WMS!")
	Endif

Return()

/*/{Protheus.doc} User Function PSAUX002
   Altera Status Cancelamento WMS
   @type Function
   @since 01/04/2025
   @author tiengo
/*/
User Function PSAUX002()

	If SF1->F1_ZSTSWMS <> '0'
		If FWAlertYesNo("Você deseja cancelar o documento no WMS?" +' '+ SF1->F1_DOC, "Cancelamento WMS!")
			If RecLock("SF1",.F.)
				SF1->F1_ZCANCW := "1"
				SF1->(MSUnLock())
				FWAlertSuccess("Cancelamento enviado!", "Cancelamento WMS!")
			Endif
		Else
			FWAlertWarning("Cancelamento nao enviado!", "Cancelamento WMS!")
		Endif
	Else
		FWAlertWarning("Nota nao enviado ainda ao WMS, ela podera ser alterada/excluida", "Cancelamento WMS!")
	Endif

Return()
