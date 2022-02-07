#Include 'Protheus.ch'
#Include 'TopConn.ch'
#Include 'rptDef.ch'
#INCLUDE "Totvs.ch"
#INCLUDE "Tbiconn.ch"

User Function SIRALT()

	Local cQuery	:= ""
	Local nCont		:= 1		
	
	// Filtra T14_IDEDMD, atraves de selecao entra C91010 e T14010, considerando periodo/matricula/versao.
	cQuery := " SELECT C91_TRABAL, C91_PERAPU, T14_VERSAO, T14_IDEDMD "
	cQuery += " FROM "+ RETSQLNAME("C91") +" C91, "+ RETSQLNAME("T14") +" T14 "
	cQuery += " WHERE C91.C91_PERAPU = '201902' "
	cQuery += " AND T14.T14_VERSAO = C91.C91_VERSAO "
	cQuery += " AND SUBSTRING(T14.T14_IDEDMD,17,3) = 'FOL' "
	cQuery += " AND C91.D_E_L_E_T_ <> '*' "
	cQuery += " AND T14.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY C91.C91_TRABAL "
	
	If Select("TMP1") <>  0
		TMP1->(DbCloseArea())
	EndIf
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP1",.T.,.T.)

	DbSelectArea("TMP1")
	Do While !EOF()

		cQuery := " SELECT T3P_BENEFI, T3P_PERAPU, T3P_VERSAO "
		cQuery += " FROM "+ RETSQLNAME("T3P") +" T3P "
		cQuery += " WHERE T3P.T3P_PERAPU = '201903' "
		cQuery += " AND T3P.T3P_BENEFI = '"+ TMP1->C91_TRABAL +"' "
		cQuery += " AND T3P.D_E_L_E_T_ <> '*' "
		
		If Select("TMP2") <>  0
			TMP2->(DbCloseArea())
		EndIf
	
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP2",.T.,.T.)
		
		DbSelectArea("TMP2")
		Do While !EOF()
			
			cQuery := " UPDATE "+ RETSQLNAME("T3R") +" "
			cQuery += " SET T3R_IDEDMD = '"+ TMP1->T14_IDEDMD +"' "
			cQuery += " WHERE T3R_VERSAO = '"+ TMP2->T3P_VERSAO +"' "
			cQuery += " AND SUBSTRING(T3R_IDEDMD,1,1) <> 'R' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
			TCSQLEXEC(cQuery)
			
			nCont++
			
			DbSelectArea("TMP2")
			DbSkip()
		EndDo
		TMP2->(DbCloseArea())
		
		DbSelectArea("TMP1")
		DbSkip()
	EndDo
	TMP1->(DbCloseArea())
	
	Alert(Str(nCont))

Return()