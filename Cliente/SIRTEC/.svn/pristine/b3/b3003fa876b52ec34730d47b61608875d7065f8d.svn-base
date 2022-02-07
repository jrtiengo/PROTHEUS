#include 'totvs.ch'

/*/{Protheus.doc} FB103FAT
Rotina que atualiza informaoes da OS no Pedido de Venda.
@type function
@author totvs
@since 16/03/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/User Function FB103FAT()

	Local aAreaAB7 := AB7->(GetArea())
	Local nNumOS   := aScan(aHeader,{|x| Alltrim(x[02]) == "C6_NUMOS" })	

	dbSelectArea("AB7")
	AB7->(dbSetOrder(1)) // AB7_NUMOS + AB7_ITEM
	
	//Alert(SubStr(aCols[1,nNumOS],1,8))
		
	If AB7->(dbSeek(xFilial("AB7") + SubStr(aCols[1,nNumOS],1,8))) .And. Altera	
		//Alert("Foi")
			
		M->C5_SDESCNF := AB7->AB7_SDESNF			
	 	M->C5_SMUNIC  := AB7->AB7_SMUNIC
	 	M->C5_SSETOR  := AB7->AB7_SSETOR
	 	M->C5_SNFOLH  := AB7->AB7_SNFOLH  	
	 	M->C5_SOBSER  := AB7->AB7_SOBSER 
	 	M->C5_SUNIDA  := AB7->AB7_SUNIDA
	 	M->C5_SPEDID  := AB7->AB7_SPEDID
		M->C5_SOBRA   := AB7->AB7_SOBRA
		M->C5_SNUMOS  := AB7->AB7_NUMOS	
	EndIf

	RestArea(aAreaAB7)
Return .T.