#INCLUDE "protheus.ch"


User Function MD130GRV()

Local ExpN1 := PARAMIXB[1]
Local cGrupo :=''
Local aAreaCN9   := CN9->(GetArea())
Local aArea      := GetArea()
IF ExpN1=3
	cGrupo:=POSICIONE("CN9",1,XFILIAL("CN9")+M->CND_CONTRA+M->CND_REVISA,"CN9_GRUAPR")
	IF !Empty(cGrupo)
		//RecLock( "CND", .F. )
		M->CND_APROV:=cGrupo
		//MsUnLock()
	Endif
	
Endif

	

RestArea(aAreaCN9)
RestArea(aArea)
Return
