#include "protheus.ch"
#INCLUDE "rwmake.ch"
#include "tbiconn.ch"
           
/*/{Protheus.doc} FDESCON

	Finalizar a coneção corrente
	
	@author  Ricardo Tomasi
	@author  Kivson Maciel
	@author  Fernando Alencar
	@version P11 e P10
	@since   20/10/2011
	@return  
	@obs     
	
/*/
user Function FDESCON()

	RpcClearEnv()
	Set Deleted On
	TcUnLink(nHndTcp)  
	
Return   