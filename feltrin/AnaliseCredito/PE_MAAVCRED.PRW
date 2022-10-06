#include"Protheus.ch"

/*/{Protheus.doc} PE_MAAVCRED
PE para substituir a avaliacao de credito padrao do sistema
@type classe
@version  1.0
@author tiengo
@since 28/09/2022
@return variant, null 
/*/

User Function MAAVCRED()

     oObj := RegraCredito():new('cPed','cCli')

Return(oObj:Regra())
