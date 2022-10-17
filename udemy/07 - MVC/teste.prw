#include "protheus.ch"

User Function UGRATI131(cPdRot)

	local aArea := GetArea()

	dbSelectArea("RG1")
	RG1->(dbSetOrder(2))

	IF RG1->(MsSeek(FwFIlial+SRA->RA_MAT+"A10"))

		M_001 := RG1->RG1_REFER
		M_002 := FBUSCAPD("290",'V',,,)

		FGERAVERBA("A10",M_002*(M_001/100),M_001,,,"V","G",,,,.T.,,,,,,,,)


	ElseIF RG1->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+"A11"))

		M_001 := RG1->RG1_REFER
		M_002 := FBUSCAPD("290",'V',,,)

		FGERAVERBA("A11",M_002*(M_001/100),M_001,,,"V","G",,,,.T.,,,,,,,,)


	EndIf


	RestArea(aArea)
	
Return
