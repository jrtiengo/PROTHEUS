#include 'totvs.ch'

/*/{Protheus.doc} FB005TEC
AXCadastro da tabela SZV - Faturamento/OS
@type function
@author Brauno Silva
@since 29/01/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/User Function FB005TEC()

	Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
	Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
	
	dbSelectArea("SZV")
	dbSetOrder(1)
	
	AxCadastro("SZV","Cadastro de Faturamento/OS",cVldExc,cVldAlt)

Return