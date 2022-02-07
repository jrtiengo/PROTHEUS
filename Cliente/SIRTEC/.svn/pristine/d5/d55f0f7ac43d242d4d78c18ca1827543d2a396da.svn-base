#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³STCA026   º Autor ³Microsiga Vitoria   º Data ³  10/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna data para mensagem da Nota de Saida                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function STCA026(cCampo)

Private cRet := ""

Do Case 
	Case cCampo == "DATA"
		fSTC0001()
	Case cCampo == "MOD"
		fSTC0002()
	Case cCampo == "PINSS"
		fSTC0003()	
	Case cCampo == "BINSS"
		fSTC0004()
	Case cCampo == "VINSS"
		fSTC0005()
	Case cCampo == "VPIS"
		fSTC0006()
	Case cCampo == "VCOFINS"
		fSTC0007()
	Case cCampo == "VCSLL"
		fSTC0008()
	Case cCampo == "KIT"
		fSTC0009()										
EndCase		

Return cRet


Static Function fSTC0001

Private cMes := ""
Private cAno := ""
Private nMes := 0
Private nAno := 0

nMes := Val(Left(GravaData(dDataBase,.F.,2),2))
nAno := Val(Right(GravaData(dDataBase,.F.,2),2))

Do Case 

	Case nMes == 1
		cRet := "16/12/" + StrZero((nAno-1),2) + " a 15/" + StrZero((nMes),2) + "/" + StrZero((nAno),2)

	Case nMes == 2
		cRet := "16/" + StrZero((nMes-1),2) + "/" + StrZero((nAno),2) + " a 15/" + StrZero((nMes),2) + "/" + StrZero((nAno),2)
   
	Case nMes == 3
		cRet := "16/" + StrZero((nMes-1),2) + "/" + StrZero((nAno),2) + " a 15/" + StrZero((nMes),2) + "/" + StrZero((nAno),2)
	
	Case nMes == 4
		cRet := "16/" + StrZero((nMes-1),2) + "/" + StrZero((nAno),2) + " a 15/" + StrZero((nMes),2) + "/" + StrZero((nAno),2)
	
	Case nMes == 5
		cRet := "16/" + StrZero((nMes-1),2) + "/" + StrZero((nAno),2) + " a 15/" + StrZero((nMes),2) + "/" + StrZero((nAno),2)
	
	Case nMes == 6
		cRet := "16/" + StrZero((nMes-1),2) + "/" + StrZero((nAno),2) + " a 15/" + StrZero((nMes),2) + "/" + StrZero((nAno),2)
	
	Case nMes == 7
		cRet := "16/" + StrZero((nMes-1),2) + "/" + StrZero((nAno),2) + " a 15/" + StrZero((nMes),2) + "/" + StrZero((nAno),2)
	
	Case nMes == 8
		cRet := "16/" + StrZero((nMes-1),2) + "/" + StrZero((nAno),2) + " a 15/" + StrZero((nMes),2) + "/" + StrZero((nAno),2)
	
	Case nMes == 9
		cRet := "16/" + StrZero((nMes-1),2) + "/" + StrZero((nAno),2) + " a 15/" + StrZero((nMes),2) + "/" + StrZero((nAno),2)
	
	Case nMes == 10
		cRet := "16/" + StrZero((nMes-1),2) + "/" + StrZero((nAno),2) + " a 15/" + StrZero((nMes),2) + "/" + StrZero((nAno),2)
	
	Case nMes == 11
		cRet := "16/" + StrZero((nMes-1),2) + "/" + StrZero((nAno),2) + " a 15/" + StrZero((nMes),2) + "/" + StrZero((nAno),2)
	
	Case nMes == 12
		cRet := "16/" + StrZero((nMes-1),2) + "/" + StrZero((nAno),2) + " a 15/" + StrZero((nMes),2) + "/" + StrZero((nAno),2)
EndCase		
Return

Static Function fSTC0002

	//cRet := Padl(Transform((xTOT_SRV/2),"@E@Z 999,999,999.99"),14)
	cRet := Padl(Transform((SF2->F2_BASEINS),"@E@Z 999,999,999.99"),14)
	
Return

Static Function fSTC0003

	Local nPerINSS

	nPerINSS := ((SF2->F2_VALINSS/SF2->F2_BASEINS)*100)
	nPerINSS := Round((nPerINSS),2)
	
	cRet := Padl(Transform(nPerINSS,"@E@Z 999,999,999.99"),14)
	
Return

Static Function fSTC0004

	cRet := Padl(Transform((SF2->F2_BASEINS),"@E@Z 999,999,999.99"),14)
	
Return 

Static Function fSTC0005

	cRet := Padl(Transform(SF2->F2_VALINSS,"@E@Z 999,999,999.99"),14)
	
Return

Static Function fSTC0006

	cRet := Padl(Transform(SF2->F2_VALIMP6,"@E@Z 999,999,999.99"),14)
	
Return  

Static Function fSTC0007

	cRet := Padl(Transform(SF2->F2_VALIMP5,"@E@Z 999,999,999.99"),14)
	
Return

Static Function fSTC0008

	cRet := Padl(Transform(SF2->F2_VALCSLL,"@E@Z 999,999,999.99"),14)
	
Return

Static Function fSTC0009

	cRet := Padl(Transform((xTOT_SRV),"@E@Z 999,999,999.99"),14)
	
Return
