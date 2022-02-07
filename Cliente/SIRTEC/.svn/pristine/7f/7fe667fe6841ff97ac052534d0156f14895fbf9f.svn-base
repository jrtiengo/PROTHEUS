//-------00------------------------------------------------------------ 
/*/{Protheus.doc} A103CND2

	Programa utilizado para alterar as informações dos títulos a pagar, poderão ser modificadas as parcelas e os valores.
	Fonte trabalha em conjunto com com o fonte MTUFOPRO - Integração entre o Protheus e o Abax

	@author 	Leonardo Vasco Viana de Oliveira
	@since		27.10.2016
	@version	P11
*/
User Function A103CND2() 
Local aNewVenc := {}       
Local aOldVenc := Paramixb 
Local nString
conout("MTUFOPRO - SCH -  A103CND2 - "+FWTimeStamp(1))
If Type('cMAVenc') <> 'U' 
     conout("MTUFOPRO - SCH -  A103CND2 - ESTA PREENCHIDO O cMAVENC "+FWTimeStamp(1))
	If !Empty(Alltrim(cMAVenc))	  
		if '|'$Alltrim(cMAVenc)
  			aNewVal:=Strtokarr(Alltrim(cMAVenc),'|')
			For nString := 1 to Len(aNewVal) 
				If aNewval[nString] $ '@@@PONTOVIRGULA@@@'
					aValNew := strtokarr(aNewval[nString],'@@@PONTOVIRGULA@@@')
				Else	                                       
					aValNew := strtokarr(aNewval[nString],';')
				Endif		    
				nValABX := val(aValNew[1])
    			dDtABX  := ctod(aValNew[2])
        		aadd(aNewVenc,{dDtABX,nValABX}) // := Condicao(nValor,cCondAbax,,dDtAbax) 
			Next
		else
			aValNew := strtokarr(Alltrim(cMAVenc),';')
			nValABX := val(aValNew[1])
   			dDtABX  := ctod(aValNew[2])
    		aadd(aNewVenc,{dDtABX,nValABX}) // := Condicao(nValor,cCondAbax,,dDtAbax) 
		endif	
	Else
		aNewVenc := Condicao(nVBrtAbax,cCondAbax,,dDtVAbax) 
	Endif	
Endif
If Len(aNewVenc) > 0
	RETURN(aNewVenc) //aNewVenc)           14513.66
Else
	Return(aOldVenc)
Endif		
