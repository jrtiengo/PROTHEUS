#INCLUDE "totvs.ch"

/*/{Protheus.doc} BRWANG
Browser para informar Taxa e Observações
@type function
@version  1.0
@author tiengo
@since 27/09/2022
@return variant, null 
/*/
User Function BRWANG()

	Local oSay1
	Local oSay2
	Local oGet1
	Local oMemo1
	Local oButton1
	Local oButton2
	private oDlg
	private nTaxa := 0
	private cMemo := ""

	DEFINE MSDIALOG oDlg TITLE "Taxa Angeza" FROM 000, 000  TO 260, 280 COLORS 0, 16777215 PIXEL

	@ 011, 010 SAY oSay1 PROMPT "Taxa Angeza:" SIZE 055, 008 OF oDlg COLORS 0, 16777215 PIXEL
	@ 037, 010 SAY oSay2 PROMPT "Observações:" SIZE 055, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 022, 010 MSGET oGet1 VAR nTaxa SIZE 096, 010 OF oDlg COLORS 0, 16777215 PIXEL PICTURE "@E 999.99"
	@ 047, 010 GET oMemo1 VAR cMemo MEMO SIZE 096, 040 OF oDlg COLORS 0, 16777215 PIXEL
	@ 100, 010 BUTTON oButton1 PROMPT "Confirmar" SIZE 037, 012 OF oDlg ACTION( Grava()) PIXEL
	@ 100, 050 BUTTON oButton2 PROMPT "Cancelar" SIZE 037, 012 OF oDlg ACTION( oDlg:End() ) PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return()

Static Function Grava()

    // Gravar e contatenar as informações digitadas do campo taxa e memo

	dbSelectArea("SE1") 
	RecLock('SE1', .F.) // .F. trava registro para alteração - .T. trava para inclusão
	SE1->E1_OBSANGE := "Taxa: " +  cValToChar(nTaxa) + " - " + cMemo
    //SE1->E1_OBSANGE := Alltrim(SE1->E1_OBSANGE) + "Taxa: " +  cValToChar(nTaxa) + " " + cMemo
	SE1->(MsUnlock())

	MsgInfo("Alteração efetuada com Sucesso!", "Atenção")
	oDlg:end()

Return()
