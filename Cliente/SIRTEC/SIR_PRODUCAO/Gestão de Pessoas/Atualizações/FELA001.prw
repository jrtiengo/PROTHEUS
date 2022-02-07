#Include 'Totvs.ch'
#INCLUDE "TOPCONN.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FELA001   ³ Autor ³Gregory Araujo         ³ Data ³30/04/2018³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Função para replicação de campos                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function FELA001()
	
	Local cQuery	:= ""
	Local cAliasTmp := GetNextAlias()
	Local lRet		:= .F.
	Local aRegs		:= {}
	Local nI := 0   
	Local cUPD := ""
	Local nStatus := 0
	
	cQuery := " SELECT RV_CODFOL, RV_NATUREZ , RV_INCIRF, RV_INCFGTS, RV_INCSIND, RV_INCCP "
	cQuery += " FROM " + RETSQLNAME("SRV")  
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery) 
	
	dbUseArea (.F.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTmp,.T.,.F.) 
	
	While (cAliasTmp)->(!EOF()) 
		
		aAdd(aRegs,{(cAliasTmp)->RV_CODFOL, ;
					(cAliasTmp)->RV_NATUREZ, ;
					(cAliasTmp)->RV_INCIRF, ;
					(cAliasTmp)->RV_INCFGTS, ;
					(cAliasTmp)->RV_INCSIND, ;
					(cAliasTmp)->RV_INCCP} ;
					)
		(cAliasTmp)->(dbSkip())
	EndDo
	
	If Len(aRegs) > 0
		
		For nI := 1 To Len(aRegs)
		
			cUPD := " UPDATE SRV040 "
		    cUPD += " SET RV_NATUREZ = '"+aRegs[nI][2]+"', "
		    cUPD += "    RV_INCIRF  = '"+aRegs[nI][3]+"', "
		    cUPD += "    RV_INCFGTS = '"+aRegs[nI][4]+"', "
		    cUPD += "    RV_INCSIND = '"+aRegs[nI][5]+"', "
		    cUPD += "    RV_INCCP   = '"+aRegs[nI][6]+"' "
		    cUPD += " WHERE RV_CODFOL = '"+aRegs[nI][1]+"' "
		    cUPD += " AND RV_CODFOL <> ' ' "
		    cUPD += " AND D_E_L_E_T_ <> '*' "
		 
		    nStatus := TCSqlExec(cUPD)
		                    
		    If (nStatus < 0)
		    	MsgInfo("TCSQLError() " + TCSQLError())
		    EndIf
			
		Next nI
		
	EndIf
		    
	MsgAlert("Concluído")
	
	(cAliasTmp)->(dbCloseArea())
	
Return()

