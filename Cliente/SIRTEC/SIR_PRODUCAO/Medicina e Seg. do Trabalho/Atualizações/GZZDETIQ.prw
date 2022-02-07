#Include "TopConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GZZDETIQ  ºAutor  ³Ezequiel Pianegonda º Data ³  13/07/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao do campo etiqueta na rotina de cadastro de EPC    º±±
±±º          ³Inicializa também alguns campos                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GZZDETIQ()
Local cEnd:= ""
Local lRet:= .F.
Local nX:= 0
Local lAux:= .T.
Local cAli:= GetNextAlias()
Local aArea:= GetArea()

gdFieldPut("ZZD_CODEPC", IIF(Empty(gdFieldGet("ZZD_CODEPC")), SubStr(M->ZZD_ETIQ, 1, 6), ""), n)
If ExistTrigger('ZZD_CODEPC') // verifica se existe trigger para este campo
	RunTrigger(2, n, nil, , 'ZZD_CODEPC')
Endif

//preencho os campos necessarios automaticamente para que o usuário possa ler o codigo de barras e pular para outra linha
TCQuery ChangeQuery("SELECT TOP 1 BF_LOCALIZ FROM "+RetSqlName("SBF")+" SBF WHERE BF_PRODUTO = '"+SubStr(M->ZZD_ETIQ, 1, 6)+"' AND BF_LOCAL = '01' AND BF_NUMSERI = '"+SubStr(M->ZZD_ETIQ, 7, 6)+"' AND "+RetSqlCond("SBF")) New ALias cAli
cEnd:= cAli->BF_LOCALIZ
cAli->(dbCloseArea())

If Alltrim(gdFieldGet("ZZD_CODEPC")) == Left(M->ZZD_ETIQ, 6)
	lRet:= .T.
Else
	MsgInfo("Código EPC inválido, verifique.")
	lRet:= .F.
EndIf

For nX:= n-1 To 1 Step -1
	If M->ZZD_ETIQ == gdFieldGet("ZZD_ETIQ", nX)
		lAux:= .F.
		lRet:= .F.
	EndIf
Next nX

If !lAux
	MsgInfo("Código EPC e série inválidos, verifique.")
	lRet:= .F.
EndIf

If lRet
	gdFieldPut("ZZD_ENDLOC", cEnd)
	gdFieldPut("ZZD_SERIE", SubStr(M->ZZD_ETIQ, 7, 6), n)
	gdFieldPut("ZZD_MOTIVO", "2", n)
	gdFieldPut("ZZD_DEV", "1", n)
EndIf

U_GZZDEQUI()

RestArea(aArea)
Return lRet