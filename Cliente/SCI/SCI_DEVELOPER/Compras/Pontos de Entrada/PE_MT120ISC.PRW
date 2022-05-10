#INCLUDE "protheus.ch"


User Function MT120ISC ()

Local aAreaC1   := SC1->(GetArea())
Local aArea     := GetArea()
Local nAprov    := aScan(aHeader,{|X| AllTrim(X[2])=="C7_APROV"})
Local cNumSc    := aCols[N,Ascan(aHeader,{|X| Upper(AllTrim(X[2])) == "C7_NUMSC" })]
Local cIteSc    := aCols[N,Ascan(aHeader,{|X| Upper(AllTrim(X[2])) == "C7_ITEMSC"})]
Local cGruApr   :=''

If !Empty(cNumSc)
	
	cGruApr:=POSICIONE("SC1",1,XFILIAL("SC1")+cNumSc+cIteSc,"C1_GRUAPR")
	If !Empty(AllTrim(cGruApr))
		aCols[n][nAprov] := cGruApr
	Else
		aCols[n][nAprov] :=Alltrim(getMV('MV_PCAPROV'))
	Endif
	
Endif
RestArea(aAreaC1)
RestArea(aArea)

Return ()


