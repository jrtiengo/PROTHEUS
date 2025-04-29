#include 'totvs.ch'
#Include 'Protheus.ch'
#Include 'TopConn.ch'

/*/{Protheus.doc} User Function SF1140I
   Responsável por atualizar as informações do cabeçalho de um Pré-Documento de Entrada.
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

			SF1->F1_ZSTSWMS := "1"
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

		DbSelectArea( "ZS3" )
		ZS3->(DbSetOrder(1)) //ZS3_FILIAL+ZS3_TABELA+ZS3_CHAVE
		cChave := ZS3->(MsSeek(FWxFilial("ZS3")+"SF1"+Alltrim(FWxFilial("SF1")+SF1->F1_DOC+'|'+SF1->F1_SERIE+'|'+SF1->F1_FORNECE+'|'+SF1->F1_LOJA+'|'+SF1->F1_TIPO)))

		If cChave .and. Empty(SF1->F1_ZCANCW)
			RecLock("SF1",.F.)
			SF1->F1_ZCANCW		:= '1' //Cancelamento solicitado
			SF1->(MSUnLock())
			FWAlertWarning('Cancelamento enviado ao WMS, aguardando retorno!','ATENÇÃO WMS')
			lRet := .F.
		Elseif cChave .and. SF1->F1_ZCANCW== '1'
			FWAlertWarning('Cancelamento ja enviado ao WMS, aguardando retorno!','ATENÇÃO WMS')
			lRet := .F.
		Elseif cChave .and. SF1->F1_ZCANCW == '2'
			FWAlertSuccess('Cancelamento autorizado pelo WMS, alteracao permitida!.','ATENÇÃO WMS')
			lRet := .T.
		Elseif ! cChave .and. Empty(SF1->F1_ZCANCW)
			FWAlertSuccess('Nota nao enviado WMS, alteracao permitida!.','ATENÇÃO WMS')
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

		DbSelectArea( "ZS3" )
		ZS3->(DbSetOrder(1)) //ZS3_FILIAL+ZS3_TABELA+ZS3_CHAVE
		cChave := ZS3->(MsSeek(FWxFilial("ZS3")+"SF1"+Alltrim(FWxFilial("SF1")+SF1->F1_DOC+'|'+SF1->F1_SERIE+'|'+SF1->F1_FORNECE+'|'+SF1->F1_LOJA+'|'+SF1->F1_TIPO)))

		If cChave .and. Empty(SF1->F1_ZCANCW)
			RecLock("SF1",.F.)
			SF1->F1_ZCANCW		:= '1' //Cancelamento solicitado
			SF1->(MSUnLock())
			FWAlertWarning('Cancelamento enviado ao WMS, aguardando retorno!','ATENÇÃO WMS')
			lRet := .F.
		Elseif cChave .and. SF1->F1_ZCANCW== '1'
			FWAlertWarning('Cancelamento ja enviado ao WMS, aguardando retorno!','ATENÇÃO WMS')
			lRet := .F.
		Elseif cChave .and. SF1->F1_ZCANCW == '2'
			FWAlertSuccess('Cancelamento autorizado pelo WMS, alteracao permitida!.','ATENÇÃO WMS')
			lRet := .T.
		Elseif ! cChave .and. Empty(SF1->F1_ZCANCW)
			FWAlertSuccess('Nota nao enviado WMS, alteracao permitida!.','ATENÇÃO WMS')
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

	//aAdd(aNewCores,{'F1_ZSTSWMS=="0"'   ,'BR_PRETO_0' })
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
	//aAdd(aRotina,{OemToAnsi("Cancela no WMS ?")		,"U_PSAUX002", 0 , 02, 0, nil})

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

	DbSelectArea( "ZS3" )
	ZS3->(DbSetOrder(1)) //ZS3_FILIAL+ZS3_TABELA+ZS3_CHAVE
	cChave := ZS3->(MsSeek(FWxFilial("ZS3")+"SF1"+Alltrim(FWxFilial("SF1")+SF1->F1_DOC+'|'+SF1->F1_SERIE+'|'+SF1->F1_FORNECE+'|'+SF1->F1_LOJA+'|'+SF1->F1_TIPO)))

	If ! cChave
		If FWAlertYesNo("Você deseja cancelar o envio ao WMS da nota?" +' '+ SF1->F1_DOC, "Envio WMS!")
			If RecLock("SF1",.F.)
				SF1->F1_ZSTSWMS := "4"
				SF1->(MSUnLock())
				FWAlertSuccess("Registro gravado com sucesso!", "Integração WMS!")
			Endif
		Endif
	Else
		FWAlertError("Prenota - ja enviada ao WMS!", "Integração WMS!")
	Endif

Return()

/*/{Protheus.doc} User Function PSAUX002
   Altera Status Cancelamento WMS
   @type Function
   @since 01/04/2025
   @author tiengo
/*/
/*
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
