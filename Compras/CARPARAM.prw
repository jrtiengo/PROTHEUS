#INCLUDE "rwmake.Ch"
#INCLUDE "Protheus.Ch"

/*/
Tela para manipular parâmetros SX6.
@version 12.1.33
@author Tiengo
@since 10/05/2022
/*/

User Function CARPARAM()

Local cUser     := SUPERGETMV("ES_USERSB1", .T., "000000") // SuperGetMv ( <nome do parâmetro>, <lHelp>, <cPadrão>, <Filial do sistema> )
Local cDescri	:= "Preenchimento dos parametros do Fechamento fiscal on line."
Local cCampo7a	:= "MV_DATAFIS - Ultima data de encerramento de operacoes fiscais"
Local cGet7		:= Space(08)
Local lOk		:= .T.

	If (!__cUserID $ cUser)
	
		cGet7 := GetMV("MV_DATAFIS")
	
		DEFINE MSDIALOG oDlg TITLE cDescri From 000,000 To 200,400 OF oMainWnd PIXEL
	
		@ 010, 005 Say cCampo7a										Pixel of oDlg
		@ 020, 005 MsGet oGet7 Var cGet7 			Picture "@!"	Pixel of oDlg
		@ 040, 025 Button "Grava"	Action(oDlg:End(),lOk:=.T.)		Pixel of oDlg
		@ 040, 100 Button "Sair"	Action(oDlg:End())				Pixel of oDlg
		ACTIVATE MSDIALOG oDlg Centered
	
	Else
		MsgBox("Usuario não autorizado!")
		lOk := .F.

	EndIf

	If lOk := .T.
	
		PutMV("MV_DATAFIS",DTOS(cGet7))
	
	EndIf

Return()
