#INCLUDE "PROTHEUS.CH"
User Function MT100TOK
Local lRet := .T.
Local aNewVal := {}
Local aValNew := {}
conout("MTUFOPRO - SCH -  MT100TOK - "+FWTimeStamp(1))
If Type('cMAVenc') <> 'U' 
	If !Empty(Alltrim(cMAVenc))	  
		conout("MTUFOPRO - SCH -  MT100TOK - ESTA PREENCHIDO O cMAVENC= "+cMAVenc+"  "+FWTimeStamp(1))
		if '|'$Alltrim(cMAVenc)
  			aNewVal:=Strtokarr(Alltrim(cMAVenc),'|')
			If aNewval[1] $ '@@@PONTOVIRGULA@@@'
				aValNew := strtokarr(aNewval[1],'@@@PONTOVIRGULA@@@')
			Else	                                       
				aValNew := strtokarr(aNewval[1],';')
			Endif		    
		else
			aValNew := strtokarr(Alltrim(cMAVenc),';')
		endif	
		if len(aValNew) > 0
			dDtvcto := Ctod(aValNew[2])	  		
			if dDtvcto <= DATE()
         		conout("MTUFOPRO - SCH -  MT100TOK - Vencimento atrasado " +dtoc(dDtvcto)+"  "+FWTimeStamp(1))
   		    	FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , 'MTUFOPRO - VECTO TITULO  - Menor que hoje   ## VECTO EM '+dtoc(dDtvcto))
				lRet := .F.
			endif
		endif
	endif	
endif	
if lRet
	If(L103AUTO)	
		aVenc	:= Condicao(100,CCONDABAX,,DDEMISSAO)	
	Else
		aVenc	:= Condicao(100,CCONDICAO,,DDEMISSAO)
	EndIf
	If Len(aVenc)>0 //  .And// . getNewPar("OC_VALVENC", .F.)
		If(aVenc[1][1] <= DATE())
       		conout("MTUFOPRO - SCH -  MT100TOK - Vencimento atrasado " +dtoc(aVenc[1][1])+"  "+FWTimeStamp(1))
       		If(L103AUTO)	
   		    	FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , 'MTUFOPRO - VECTO TITULO  - Menor que hoje   ## VECTO EM '+dtoc(aVenc[1][1]))
			else
				Help('Valida Vencimento',1,'MT100TOK',,"Lançamento bloqueado, pois a NF está vencida, gentileza verificar." ,1,0)			
			endif
			lRet := .F.
		Endif
	EndIf
endif	
Return(lRet)
