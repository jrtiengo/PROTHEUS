#Include "TopConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GZZ9ETIQ  ºAutor  ³Ezequiel Pianegonda º Data ³  13/04/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao do campo etiqueta na rotina de cadastro de EPC    º±±
±±º          ³Inicializa também alguns campos                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GZZ9ETIQ()
Local cEnd:= ""
Local lRet:= .F.
Local nX:= 0
Local lAux:= .T.
Local cAli:= GetNextAlias()
Local aArea:= GetArea()
Local cForLj:= ""

//preencho os campos necessarios automaticamente para que o usuário possa ler o codigo de barras e pular para outra linha
TCQuery ChangeQuery("SELECT TOP 1 BF_LOCALIZ FROM "+RetSqlName("SBF")+" SBF WHERE BF_PRODUTO = '"+SubStr(M->ZZ9_ETIQ, 1, 6)+"' AND BF_LOCAL = '01' AND BF_NUMSERI = '"+SubStr(M->ZZ9_ETIQ, 7, 6)+"' AND "+RetSqlCond("SBF")) New ALias cAli
cEnd:= cAli->BF_LOCALIZ
cAli->(dbCloseArea())

If Alltrim(M->TN3_CODEPI) == Left(M->ZZ9_ETIQ, 6)
	lRet:= .T.
Else
	MsgInfo("Código EPC inválido, verifique.")
	lRet:= .F.
EndIf

For nX:= n-1 To 1 Step -1
	If M->ZZ9_ETIQ == gdFieldGet("ZZ9_ETIQ", nX)
		lAux:= .F.
		lRet:= .F.
	EndIf
Next nX

If !lAux
	MsgInfo("Código EPC e série inválidos, verifique.")
	lRet:= .F.
EndIf

If lRet
	gdFieldPut("ZZ9_ENDLOC", cEnd)
	gdFieldPut("ZZ9_NUMSER", SubStr(M->ZZ9_ETIQ, 7, 6), n)
	gdFieldPut("ZZ9_MOTIVO", "2", n)
	gdFieldPut("ZZ9_DEV", "1", n)
	cForLj:= PADR(u_FornZZ9("SELECT DISTINCT TN3_FORNEC+TN3_LOJA+'-'+A2_NOME FROM "+RetSqlName("TN3")+" AS TN3, "+RetSqlName("SA2")+" AS SA2 WHERE A2_COD = TN3_FORNEC AND A2_LOJA = TN3_LOJA AND TN3_CODEPI = '"+SubStr(M->ZZ9_ETIQ, 1, 6)+"' AND "+RetSqlCond("TN3"), "Fornecedor Epc", 9), 9, " ")
	gdFieldPut("ZZ9_FORNEC", SubStr(cForLj, 1, 6))
	gdFieldPut("ZZ9_LOJA", SubStr(cForLj, 7, 2))
EndIf

RestArea(aArea)
Return lRet