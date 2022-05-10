#INCLUDE "protheus.ch"
#include "TOPCONN.CH"
#INCLUDE "rwmake.ch"
//----------------------------------------------------------------------
User Function SCIG005(nRecnoCT2)
//----------------------------------------------------------------------            
Local aArea:=GetArea()
cCOCred:=""
cCODebi:=""

If FUNNAME()<>'CTBA211'

		cQuery := " SELECT CT2_COC,CT2_COD "
		cQuery += " FROM " + RetSqlName("CT2") + " CT2 "
		cQuery += " WHERE CT2_FILIAL = '" + xFilial("CT2") + "'"
		cQuery += " AND R_E_C_N_O_ = " + STR(nRecnoCt2) + " "
		cQuery += " AND CT2.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery)                           
		dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), "TRBCT2", .F., .T.) // executa query
		dbSelectArea("TRBCT2")
		DbGoTop()
		
		cCODebi:=TRBCT2->CT2_COD   
		cCOCred:=TRBCT2->CT2_COC
		
		IF (empty(cCOCred) .and.empty(cCODebi)) .or. TRBCT2->(EOF())
			TRBCT2->(dbCloseArea())
		
			cQuery := " SELECT CTK_COC,CTK_COD "
			cQuery += " FROM " + RetSqlName("CTK") + " CTK "
			cQuery += " WHERE CTK_FILIAL = '" + xFilial("CTK") + "'"
			cQuery += " AND CTK_RECDES = " + STR(nRecnoCt2) + " "
			cQuery += " AND CTK.D_E_L_E_T_ = ' ' "
			
			cQuery := ChangeQuery(cQuery)                           
			dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), "TRBCTK", .F., .T.) // executa query
			dbSelectArea("TRBCTK")
			DbGoTop()
			
			cCODebi:=TRBCTK->CTK_COD   
			cCOCred:=TRBCTK->CTK_COC
			TRBCTK->(dbCloseArea())
		Else
		   TRBCT2->(dbCloseArea())
		End
		   
		   
End           
ResTArea(aArea)
Return {cCODebi,cCOCred}