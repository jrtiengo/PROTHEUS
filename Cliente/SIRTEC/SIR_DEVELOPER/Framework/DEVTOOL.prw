#include "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"
           
/*/{Protheus.doc} DEVTOOL
	
	Ativa a ferramenta DEVTools	

	@author  Fernando Alencar
	@version P11 e P10
	@since   15/09/2011
	@return  
	@obs     
	
/*/
User Function DEVTOOL()

	Local aTools
	Local aSelTools 
	
	aTools 		:= U_DEVTOOL2()		//Retorna lista de ferramentas
	aSelTools	:= U_DEVTOOL0(aTools)//Retorna lista de ferramentas que o usuário selecionar 
	U_DEVTOOL3(aSelTools)
		
Return .T.