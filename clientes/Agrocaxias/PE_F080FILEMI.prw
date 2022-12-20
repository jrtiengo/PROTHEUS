#INCLUDE "PROTHEUS.CH"

 /*/{Protheus.doc} F080FILEMI
(PE para definir por qual campo de data será validada a condição de não baixar títulos com data inferior a data de emissão no CP)
@type  Function
@author Tiengo
@since 20/12/2022
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
@see (https://tdn.totvs.com/display/public/PROT/F080FILEMI+-+Campo+data+validado+na+baixa)
/*/

User Function F080FILEMI()

Local cNomeCp := 'E2_EMIS1'

//Alert ("Ponto de entrada que permite por qual campo de data será validada a baixa")

Return cNomeCp
