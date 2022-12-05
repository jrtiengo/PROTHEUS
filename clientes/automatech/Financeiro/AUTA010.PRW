#include "rwmake.ch"
#include "protheus.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BOLCAX    ºAutor  ³Microsiga           º Data ³  08/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AUTA010()

Local cQuery	:= {}
Local cCodCli	:= ""


If INCLUI() 
	If FunName()=="TECA300"
		cCodCli := ALLTRIM(M->AB1_CODCLI)+ALLTRIM(M->AB1_LOJA)
	ElseIf FunName()=="TECA400"
		cCodCli := ALLTRIM(M->AB3_CODCLI)+ALLTRIM(M->AB3_LOJA)
	EndIf

Else
	If FunName()=="TECA300"
   		cCodCli := ALLTRIM(AB1_CODCLI)+ALLTRIM(AB1_LOJA)
	ElseIf FunName()=="TECA400"
   		cCodCli := ALLTRIM(AB3_CODCLI)+ALLTRIM(AB3_LOJA)
	EndIf
EndIf

cQuery := " SELECT SU5.U5_CODCONT, * FROM SU5990 SU5(Nolock), AC8990 AC8(NoLock) "
cQuery += " WHERE AC8_CODENT = '"+cCodCli+"' AND "
cQuery += " AC8.AC8_CODCON = SU5.U5_CODCONT AND
cQuery += " SU5.D_E_L_E_T_ <> '*' AND
cQuery += " AC8.D_E_L_E_T_ <> '*'     

