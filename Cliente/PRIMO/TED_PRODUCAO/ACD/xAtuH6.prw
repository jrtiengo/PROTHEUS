#Include "Protheus.Ch"
#include "rwmake.ch"
#INCLUDE 'TOPCONN.CH'


/*/{Protheus.doc} xAtuH6
//Tela customizada para atualizar informacoes de campos especificos do apontamento de producao.
@author Celso Renee
@since 17/02/2021
@version 1.0
@type function
/*/
User Function xAtuH6()

Local oButton1
Local oButton2
Local oComboBo1

Local oComboBo2
Local oComboBo3
Local oGet1

Local oSay1
Local oSay2
Local oSay3
Local oSay4

Private nGet1     := 999999
Private nComboBo1 := 1
Private nComboBo2 := 1
Private nComboBo3 := 1

Static _oDlg

//turno
Do Case 
    case SH6->H6_TURNO == "1"
        nComboBo1 := 1
    case SH6->H6_TURNO == "2"
        nComboBo1 := 2
    case SH6->H6_TURNO == "3"
        nComboBo1 := 3
    case SH6->H6_TURNO == "4"
        nComboBo1 := 4
End Case

//truma
Do Case 
    case SH6->H6_TURMA == "1"
        nComboBo2 := 1
    case SH6->H6_TURMA == "2"
        nComboBo2 := 2
    case SH6->H6_TURMA == "3"
        nComboBo2 := 3
    case SH6->H6_TURMA == "4"
        nComboBo2 := 4
End Case

//Pos. Bonina
Do Case 
    case SH6->H6_POSBOBI == "1"
        nComboBo3 := 1
    case SH6->H6_POSBOBI == "2"
        nComboBo3 := 2
    case SH6->H6_POSBOBI == "3"
        nComboBo3 := 3
    case SH6->H6_POSBOBI == "4"
        nComboBo3 := 4
End Case

//numero Jumbo
nGet1 := SH6->H6_NRJUMBO


  DEFINE MSDIALOG _oDlg TITLE "# Apontamen.: " + Alltrim(SH6->H6_OP) + "-" + SH6->H6_IDENT FROM 000, 000  TO 265, 250 COLORS 0, 16777215 PIXEL

    @ 011, 006 SAY oSay1 PROMPT "Turno:" SIZE 025, 007 OF _oDlg COLORS 0, 16777215 PIXEL
    @ 009, 052 MSCOMBOBOX oComboBo1 VAR nComboBo1 ITEMS {"1=Turno1","2=Turno2","3=Turno3","4=Turno4"} SIZE 055, 010 OF _oDlg COLORS 0, 16777215 PIXEL
    @ 033, 006 SAY oSay2 PROMPT "Turma:" SIZE 022, 007 OF _oDlg COLORS 0, 16777215 PIXEL
    @ 031, 052 MSCOMBOBOX oComboBo2 VAR nComboBo2 ITEMS {"1=Turma A","2=Turma B","3=Turma C","4=Turma D"} SIZE 055, 010 OF _oDlg COLORS 0, 16777215 PIXEL
    @ 055, 006 SAY oSay3 PROMPT "Pos. Bonina:" SIZE 031, 007 OF _oDlg COLORS 0, 16777215 PIXEL
    @ 053, 052 MSCOMBOBOX oComboBo3 VAR nComboBo3 ITEMS {"1=12a","2=12b","3=12c","4=22a","5=22b","6=22c"} SIZE 055, 010 OF _oDlg COLORS 0, 16777215 PIXEL
    @ 077, 006 SAY oSay4 PROMPT "Nr. Rolo Jum:" SIZE 038, 007 OF _oDlg COLORS 0, 16777215 PIXEL
    @ 075, 052 MSGET oGet1 VAR nGet1 SIZE 055, 010 OF _oDlg  PICTURE "@R 999999" COLORS 0, 16777215 PIXEL
    @ 105, 015 BUTTON oButton1 PROMPT "Gravar" SIZE 040, 016 OF _oDlg PIXEL ACTION (xH6Grava())
    @ 105, 070 BUTTON oButton2 PROMPT "Sair" SIZE 045, 016 OF _oDlg PIXEL ACTION (close(_oDlg))

  ACTIVATE MSDIALOG _oDlg CENTERED


Return()


/*/{Protheus.doc} xH6Grava
//Atualizando informacoes SH6
@author Celso Rene
@since 17/02/2021
@version 1.0
@type function
/*/
Static function xH6Grava()

dbSelectArea("SH6")
RecLock("SH6",.F.)
SH6->H6_TURNO   := cValtoChar(nComboBo1)
SH6->H6_TURMA   := cValtoChar(nComboBo2)
SH6->H6_POSBOBI := cValtoChar(nComboBo3)
SH6->H6_NRJUMBO := nGet1
SH6->(MsUnlock())

MsgInfo("Informações salvas com sucesso no apontamento de produção posicionado!","Apont. Prod.: "+ Alltrim(SH6->H6_OP) + "-" + SH6->H6_IDENT)

close(_oDlg)

Return()
