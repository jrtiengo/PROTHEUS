#include "protheus.ch"

User Function UGRATI131()

	local aArea := GetArea()

	/*
	dbSelectArea("RG1")
	RG1->(dbSetOrder(2))
	RG1->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+"A10"))
	M_001 := RG1->RG1_REFER
    M_002 := FBUSCAPD("290",'V',,,)

	FGERAVERBA("A10",M_002*(M_001/100),M_001,,,"V","G",,,,.T.,,,,,,,,)

	RestArea(aArea)
	*/

	// Tiengo - Adicionado condição, para atender as verbas, A10, A11, A12 e A13.
	dbSelectArea("RG1")
	RG1->(dbSetOrder(2))
	//IF RG1->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+"A10"))
	IF RG1->(MsSeek(FWxFilial("RG1")+SRA->RA_MAT+"A10"))

		M_001 := RG1->RG1_REFER
		M_002 := FBUSCAPD("290",'V',,,)

		FGERAVERBA("A10",M_002*(M_001/100),M_001,,,"V","G",,,,.T.,,,,,,,,)
	EndIf

	IF RG1->(MsSeek(FWxFilial("RG1")+SRA->RA_MAT+"A11"))

		M_001 := RG1->RG1_REFER
		M_002 := FBUSCAPD("290",'V',,,)

		FGERAVERBA("A11",M_002*(M_001/100),M_001,,,"V","G",,,,.T.,,,,,,,,)
	EndIf

	IF RG1->(MsSeek(FWxFilial("RG1")+SRA->RA_MAT+"A12"))

		M_001 := RG1->RG1_REFER
		M_002 := FBUSCAPD("290",'V',,,)

		FGERAVERBA("A12",M_002*(M_001/100),M_001,,,"V","G",,,,.T.,,,,,,,,)
	EndIf

	IF RG1->(MsSeek(FWxFilial("RG1")+SRA->RA_MAT+"A13"))

		M_001 := RG1->RG1_REFER
		M_002 := FBUSCAPD("290",'V',,,)

		FGERAVERBA("A13",M_002*(M_001/100),M_001,,,"V","G",,,,.T.,,,,,,,,)
	EndIf

	IF RG1->(MsSeek(FWxFilial("RG1")+SRA->RA_MAT+"A19"))

		M_001 := RG1->RG1_REFER
		M_002 := FBUSCAPD("290",'V',,,)

		FGERAVERBA("A19",M_002*(M_001/100),M_001,,,"V","G",,,,.T.,,,,,,,,)

	EndIf

	RestArea(aArea)

Return
