#include 'totvs.ch'

/*/{Protheus.doc} FB102FAT
Função chamada por gatilho no campo C5_YCODMSG.
Atualiza as mensagens dos campo C5_YMSG01 ate C5_YMSG12 
@type function
@author Bruno Silva
@since 26/01/2017
@version 1.0
@return ${return}, ${return_description}
@example
IIF(ExistBlock("FB102FAT"),U_FB102FAT(),M->C5_YCODMSG)                                              
@see (links_or_references)
/*/
User Function FB102FAT()

	Local cCampo := ""
	
	//"Servico de XXXXXXX ,
	//conforme pedido XXXXXXXX.
	//Folha XXXXXXXXXX "  
	//" No municipio de XXXXX."
	//"Vencimento xxxxxxxxxxxxx.
	
	For nI := 1 To 12
		cCampo := "M->C5_YMSG"+ PadL(cValToChar(nI),2,"0")
		
		//If ! Empty(&("cCampo)) .and. "Servico de XXXXXXX" $ &(cCampo) 
		//	&(cCampo) := StrTran(&(cCampo),"Servico de XXXXXXX","Servico de "+ Alltrim(M->C5_SPEDID))		
		//EndIf
		
		If ! Empty(&(+cCampo)) .and. "pedido XXXXXXXX" $ &(cCampo) 
			&(cCampo) := StrTran(&(cCampo),"pedido XXXXXXXX","pedido "+ Alltrim(M->C5_SPEDID))		
		EndIf				
		
		If ! Empty(&(cCampo)) .and. "Folha XXXXXXXXXX" $ &(cCampo) 
			&(cCampo) := StrTran(&(cCampo),"Folha XXXXXXXXXX","Folha "+ Alltrim(M->C5_SNFOLH))		
		EndIf				
		
		If ! Empty(&(cCampo)) .and. "No municipio de XXXXX" $ &(cCampo) 
			&(cCampo) := StrTran(&(cCampo),"No municipio de XXXXX","No municipio de "+ Alltrim(M->C5_SMUNIC))		
		EndIf											
						
	Next	

Return M->C5_YCODMSG