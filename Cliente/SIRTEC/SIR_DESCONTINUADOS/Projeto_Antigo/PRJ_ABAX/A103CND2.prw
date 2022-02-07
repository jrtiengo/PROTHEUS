//-------00------------------------------------------------------------ 
/*/{Protheus.doc} A103CND2

	Programa utilizado para alterar as informa��es dos t�tulos a pagar, poder�o ser modificadas as parcelas e os valores.
	Fonte trabalha em conjunto com com o fonte MTUFOPRO - Integra��o entre o Protheus e o Abax

	@author 	Leonardo Vasco Viana de Oliveira
	@since		27.10.2016
	@version	P11
*/
User Function A103CND2() 

Local aNewVenc := {}       
Local aOldVenc := Paramixb 

If Type('cMAVenc') <> 'U' 

	If !Empty(Alltrim(cMAVenc))	  

		aNewVal := Strtokarr(Alltrim(cMAVenc),'|') // Primeira posi��o Valor separada por '|'
		
		For nString := 1 to Len(aNewVal) 
				
			If aNewval[nString] $ '@@@PONTOVIRGULA@@@'
				aValNew := strtokarr(aNewval[nString],'@@@PONTOVIRGULA@@@')
			Else	                                       
				aValNew := strtokarr(aNewval[nString],';')
			Endif		    
			
			nValABX := val(aValNew[1])
			dDtABX  := Ctod(aValNew[2])	  		
		  		
		   aadd(aNewVenc,{dDtABX,nValABX}) // := Condicao(nValor,cCondAbax,,dDtAbax) 
	   	   
		Next
		
	Else
		aNewVenc := Condicao(nVBrtAbax,cCondAbax,,dDtVAbax) 
	Endif	
Endif             

If Len(aNewVenc) > 0
	RETURN(aNewVenc) //aNewVenc)           14513.66
Else
	Return(aOldVenc)
Endif		