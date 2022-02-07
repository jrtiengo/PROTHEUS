#include 'protheus.ch'


/*/{Protheus.doc} MT105MNU
//Este Ponto de Entrada é utilizado para adicionar itens no menu principal da rotina
 de solicitação ao armazem Eventos.
@author Celso Rene
@since 28/01/2019
@type function
/*/
User Function MT105MNU()

	Local _aRet := {}
	
	If ("XMATA105" $ FunName()  )          
		
		aAdd(_aRet,{"# Rel. Picklist"             , "u_RPICKSCP()"     , 0 , 7}) //Chama user function do fonte RPICKSCP
		aAdd(_aRet,{"# Processar"                 , "u_XM105PRO()"     , 0 , 7})
		aAdd(_aRet,{"# Reimp. Rel. Comprovantes"  , "u_RCOMPEPI(0, '')", 0 , 7}) //Chama user function do fonte RPICKSCP
		aAdd(_aRet,{"# Rel. Separ. Un. (Opcional)", "u_RSEPPIC()"      , 0 , 7}) //Chama user function do fonte RPICKSCP
		aAdd(_aRet,{"# Funcionário x EPI"         , "U_xMDTA695()"     , 0 , 7})
		
	EndIf


Return(_aRet)
