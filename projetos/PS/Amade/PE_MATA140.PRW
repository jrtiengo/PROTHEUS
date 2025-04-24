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

			SF1->(MSUnLock())
		Endif
	Endif

Return()

/*/{Protheus.doc} User Function A140Exc
   Validar Status da Prenota
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

		If SF1->F1_ZSTSWMS == "1"
			lRet := .F.

			FWAlertWarning("Entrar em contato com a Logistica(WMS)", "Pre-nota ainda em processamento pelo WMS")
		Endif
	Endif

Return()
User Function A140Exc()

	Local lRet := .T.   as logical

	If ! IsBlind()

		If SF1->F1_ZSTSWMS == "1"
			lRet := .F.

			FWAlertWarning("Entrar em contato com a Logistica(WMS)", "Pre-nota ainda em processamento pelo WMS")
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

	aAdd(aRotina,{OemToAnsi("Altera Envio WMS"), "U_PSAUX001", 0 , 02, 0, nil})

Return()

/*/{Protheus.doc} User Function PSAUX001
   Montagem Tela para alterar STATUS
   @type Function
   @since 01/04/2025
   @author tiengo
/*/

User Function PSAUX001

	Private oDlg            := NIL                          as object
	Private cComboBo1       := 'XX'                         as character
	Private oComboBo1       := NIL                          as object
	Private aComboBo1       := {'1=Envia', '2=Não Envia'}   as array
	Private oPanel1         := NIL                          as object
	Private oSay1           := NIL                          as object
	Private oButton1        := NIL                          as object
	Private oButton2        := NIL                          as object

	If FWSX6Util():ExistsParam("PS_USTWMSE")
		cParam := GetMV("PS_USTWMSE")
	Else
		cParam := SuperGetMV("PS_USTWMSE", .F., "000000")
	Endif

	if ! __cUserID $ cParam
		FWAlertError("Usuário sem acesso!", "Integração WMS!")
		Return()
	Endif

	DEFINE MSDIALOG oDlg TITLE "Integração WMS" FROM 000, 000  TO 160, 300 COLORS 0, 16777215 PIXEL

	@ 024, 065 MSCOMBOBOX oComboBo1 VAR cComboBo1 ITEMS aComboBo1 SIZE 072, 010 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 026, 010 SAY oSay1 PROMPT "Envia ao WMS?" SIZE 055, 007 OF oPanel1 COLORS 0, 16777215 PIXEL
	@ 062, 016 BUTTON oButton1 PROMPT "Salvar" SIZE 037, 012 ACTION fGrava() OF oPanel1 PIXEL
	@ 062, 066 BUTTON oButton2 PROMPT "Fechar" SIZE 037, 012 ACTION(Odlg:End()) OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return()

Static Function fGrava()

	//So permite alterar, se ainda não foi enviado ao WMS
	If SF1->F1_ZSTSWMS == '0'
		
		If RecLock("SF1",.F.)
			If ! Empty(cComboBo1) .And. cComboBo1 == '2'
				SF1->F1_ZSTSWMS := "4"
			Else
				SF1->F1_ZSTSWMS := "1"
			Endif
			SF1->(MSUnLock())

			FWAlertSuccess("Registro gravado com sucesso!", "Integração WMS!")
		End
	Else 
		FWAlertError("Nao e possivel alterar, Prenota - ja enviada ao WMS!", "Integração WMS!")
	Endif

Return()
