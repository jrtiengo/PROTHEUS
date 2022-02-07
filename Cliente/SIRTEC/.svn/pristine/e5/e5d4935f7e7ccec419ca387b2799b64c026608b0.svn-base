#Include 'Protheus.ch'
#include "Rwmake.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _ValidPass ³ Autor ³ Felipe S. Raota            ³ Data ³ 27/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Abertura de tela para digitação de senha.                         ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Projeto PPR - Sirtec                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function _ValidPass(cPass,cUser)

Local oDlgSenha
Local oUser
Local oPass
Local _bOk	:=	.T.

DEFINE MSDIALOG oDlgSenha FROM 200,250 TO 300,450 TITLE "Autorização" PIXEL

@ 0.3,01 SAY OemToAnsi("Usuário") SIZE 78,17 OF oDlgSenha
@ 1.0,01 MSGET oUser VAR cUser OF oDlgSenha SIZE 55,08

@ 1.9,01 SAY OemToAnsi("Senha") OF oDlgSenha
@ 2.6,01 MSGET oPass VAR cPass PASSWORD OF oDlgSenha  SIZE 55,08

DEFINE SBUTTON FROM 13,65 TYPE 1 ACTION (_bOk := .t., oDlgSenha:End()) ENABLE OF oDlgSenha
DEFINE SBUTTON FROM 32,65 TYPE 2 ACTION (_bOk := .f., oDlgSenha:End()) ENABLE OF oDlgSenha 

oUser:SetFocus()

ACTIVATE MSDIALOG oDlgSenha CENTERED

Return _bOk



