#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} nomeFunction
(long_description)
@type user function
@author user
@since 17/07/2024
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/

User Function telinha01

	Local oButton1
	Local oButton2

	Private oGet1
	Private cGet1 := space(8)
	Private oSay1
	Private oGet2
	Private cGet2 := 'SEM NOME'
	Private oDlg

	DEFINE MSDIALOG oDlg TITLE "New Dialog" FROM 000, 000  TO 500, 500 COLORS 0, 16777215 PIXEL

	@ 029, 062 MSGET oGet1 VAR cGet1 SIZE 082, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 027, 030 SAY oSay1 PROMPT "Cliente" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 043, 063 MSGET oGet2 VAR cGet2 SIZE 082, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 033, 153 BUTTON oButton1 PROMPT "Pesquisa" SIZE 036, 017 ACTION PESQUISA() OF oDlg PIXEL
	@ 034, 192 BUTTON oButton2 PROMPT "Fecha" SIZE 036, 017 ACTION(Odlg:End()) OF oDlg PIXEL
	oGet2:disable()

	ACTIVATE MSDIALOG oDlg CENTERED

Return()

Static Function pesquisa

	Local cRet := ''

	cRet := POSICIONE('SA1',1,xFilial('SA1') + cGet1, 'A1_NOME')

	cget2 := cret

Return(cRet)
