#Include 'Protheus.ch'
#include "Rwmake.ch"

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � _ValidPass � Autor � Felipe S. Raota            � Data � 27/05/13 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Abertura de tela para digita��o de senha.                         ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � Projeto PPR - Sirtec                                              ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

User Function _ValidPass(cPass,cUser)

Local oDlgSenha
Local oUser
Local oPass
Local _bOk	:=	.T.

DEFINE MSDIALOG oDlgSenha FROM 200,250 TO 300,450 TITLE "Autoriza��o" PIXEL

@ 0.3,01 SAY OemToAnsi("Usu�rio") SIZE 78,17 OF oDlgSenha
@ 1.0,01 MSGET oUser VAR cUser OF oDlgSenha SIZE 55,08

@ 1.9,01 SAY OemToAnsi("Senha") OF oDlgSenha
@ 2.6,01 MSGET oPass VAR cPass PASSWORD OF oDlgSenha  SIZE 55,08

DEFINE SBUTTON FROM 13,65 TYPE 1 ACTION (_bOk := .t., oDlgSenha:End()) ENABLE OF oDlgSenha
DEFINE SBUTTON FROM 32,65 TYPE 2 ACTION (_bOk := .f., oDlgSenha:End()) ENABLE OF oDlgSenha 

oUser:SetFocus()

ACTIVATE MSDIALOG oDlgSenha CENTERED

Return _bOk



