#INCLUDE 'PROTHEUS.CH'

 /*/{Protheus.doc} nomeFunction
(long_description)
@type  Function
@author user
@since 17/07/2024
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
    /*/

User Function A010TOK

	Local cMsg := 'Escolha outro tipo'
	Local lRet := .T.

	if B1_TIPO = 'PA'

		MsgInfo(cMsg, 'Atenção')

		lRet := .F.

	endif

Return (lRet)
