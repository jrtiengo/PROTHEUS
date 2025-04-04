#include 'totvs.ch'
#Include 'Protheus.ch'
#Include 'TopConn.ch'

/*/{Protheus.doc} User Function SF1140I
   Responsável por atualizar as informações do cabeçalho de um Pré-Documento de Entrada e seus anexos.
   @type Function
   @since 23/10/2024
   @author user
/*/

User Function SF1140I()

	Local lInc      := PARAMIXB[1]  as logical
	Local lAlt      := PARAMIXB[2]  as logical

	If lInc .or. lAlt

		If RecLock("SF1",.F.)

			SF1->F1_ZSTSWMS := "1"

			SF1->(MSUnLock())
		Endif
	Endif

Return()

/*
Se retornado um valor logico Falso (.F.), este P.E. nao deixa excluir a Pre-Nota. 
Se retornado .T. é confirmada a exclusão da Pre-Nota de Entrada.
*/
User Function A140Exc()

	Local lRet := .T.   as logical

	If ! IsBlind()

		If SF1->F1_ZSTSWMS == "1"
			lRet := .F.

			FWAlertWarning("Entrar em contato com a Logistica(WMS)", "Pre-nota ainda em processamento pelo WMS")
		Endif
	Endif

Return(lRet)

User Function MT140COR()

	Local aNewCores := {}   as array
	Local nX        := 0    as numeric

	aAdd(aNewCores,{'F1_ZSTSWMS=="1"'   ,'BR_PRETO_1' })
	aAdd(aNewCores,{'F1_ZSTSWMS=="2"'   ,'BR_PRETO_2' })
	aAdd(aNewCores,{'F1_ZSTSWMS=="3"'   ,'BR_PRETO_3' })

	For nX := 1 to Len(PARAMIXB[1])

		aAdd(aNewCores  ,PARAMIXB[1][nX])

	Next nX

Return(aNewCores)

User Function MTA140MNU

	aAdd(aRotina,{OemToAnsi("Altera Envio WMS"), "U_PSAUX001", 0 , 02, 0, nil})

Return()

User Function PSAUX001

	Private oDlg            := NIL                          as object
	Private cComboBo1       := 'XX'                         as character
	Private oComboBo1       := NIL                          as object
	Private aComboBo1       := {'1=Envia', '2=Não Envia'}   as array
	Private oPanel1         := NIL                          as object
	Private oSay1           := NIL                          as object
	Private oButton1        := NIL                          as object
	Private oButton2        := NIL                          as object

	If FWSX6Util():ExistsParam("PS_USTATUS")
		cParam := GetMV("PS_USTATUS")
	Else
		cParam := SuperGetMV("PS_USTATUS", .F., "000000")
	Endif

	if ! __cUserID $ cParam
        FWAlertSuccess("Usuário sem acesso!", "Integração WMS!")
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

	If RecLock("SF1",.F.)

		If ! Empty(cComboBo1) .And. cComboBo1 == '2'
			SF1->F1_ZSTSWMS := "4"
		Else
			SF1->F1_ZSTSWMS := "1"
		Endif

		SF1->(MSUnLock())

		FWAlertSuccess("Registro gravado com sucesso!", "Integração WMS!")
	Endif

Return()
