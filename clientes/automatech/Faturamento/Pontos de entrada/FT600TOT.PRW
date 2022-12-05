#INCLUDE "PROTHEUS.CH"
/*

*/
User Function FT600TOT()

	Local aRet := PARAMIXB[3]

    Public __TotPropo  := 0

	Public ___aColsADZ := PARAMIXB[1]:aCols

   U_AUTOM628("FT600TOT")
	
Return aRet