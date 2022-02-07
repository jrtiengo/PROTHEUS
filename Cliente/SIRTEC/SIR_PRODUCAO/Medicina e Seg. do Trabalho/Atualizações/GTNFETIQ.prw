#Include "Topconn.ch"
#Include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GTNFETIQ  ºAutor  ³Ezequiel Pianegonda º Data ³  12/04/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Preenchimento automatico da linha do Func. X Epi via codigo º±±
±±º          ³de barras.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GTNFETIQ()

Local cEnd:= ""
Local cAli:= GetNextAlias()
Local aArea:= GetArea()
Local aTNF:= TNF->(GetArea())
Local nX:= n

//preencho os campos necessarios automaticamente para que o usuário possa ler o codigo de barras e pular para outra linha
TCQuery ChangeQuery("SELECT TOP 1 BF_LOCALIZ FROM "+RetSqlName("SBF")+" SBF WHERE BF_PRODUTO = '"+SubStr(M->TNF_ETIQ, 1, 6)+"' AND BF_LOCAL = '01' AND BF_NUMSERI = '"+SubStr(M->TNF_ETIQ, 7, 6)+"' AND "+RetSqlCond("SBF")) New ALias cAli
cEnd:= cAli->BF_LOCALIZ
cAli->(dbCloseArea())

gdFieldPut("TNF_SERIE", SubStr(M->TNF_ETIQ, 7, 6))
gdFieldPut("TNF_CODEPI", PADR(SubStr(M->TNF_ETIQ, 1, 6), 15, " "))
MDTProEpi(PADR(SubStr(M->TNF_ETIQ, 1, 6), 15, " "),cTipo,lSX5)
fEPIMDT695(PADR(SubStr(M->TNF_ETIQ, 1, 6), 15, " "))
gdFieldPut("TNF_DESC", fBuscaCpo("SB1", 1, xFilial("SB1")+PADR(SubStr(M->TNF_ETIQ, 1, 6), 15, " "), "B1_DESC"))
gdFieldPut("TNF_ENDLOC", cEnd)
gdFieldPut("TNF_NSERIE", SubStr(M->TNF_ETIQ, 7, 6))
gdFieldPut("TNF_MOTIVO", "2")
gdFieldPut("TNF_EPIEFI", "1")
gdFieldPut("TNF_DTENTR", dDataBase)
gdFieldPut("TNF_HRENTR", Time())

//verifico se existe algum produto acima do atual em uso e altero para aguardando devolucao
For nX:= n-1 To 1 Step -1
	//verifica se a linha nao esta deletada
	If !gdDeleted(nX)
		//se forem o mesmo produto
		If gdFieldGet("TNF_CODEPI", nX) == gdFieldGet("TNF_CODEPI", n)
			//se for motivo igual a 1 - Em Uso, troco por 2 - Aguardando Devolucao
			If gdFieldGet("TNF_DEV", nX) == '1'
				//ajusto no browser
				gdFieldPut("TNF_DEV", "2", nX) 

				//ajusto no banco
				If gdFieldGet("TNF_REC_WT", nX) > 0
					dbSelectArea("TNF")
					dbGoTo(gdFieldGet("TNF_REC_WT", nX))
					RecLock("TNF", .F.)
					TNF->TNF_DEV:= "2"
					MsUnLock("TNF")
				EndIf
				
			EndIf
		EndIf
	EndIf
Next nX

RestArea(aTNF)
RestArea(aArea)
Return .T.