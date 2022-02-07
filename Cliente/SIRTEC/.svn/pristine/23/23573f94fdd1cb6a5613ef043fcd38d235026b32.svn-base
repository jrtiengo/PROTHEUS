// #########################################################################################
// Projeto:
// Modulo :
// Fonte  : inspseg
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 14/11/13 | TOTVS Developer Studio | Gerado pelo Assistente de Código
// ---------+-------------------+-----------------------------------------------------------

#include "rwmake.ch"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} novo
Permite a manutenção de dados armazenados em Z11.

@author    TOTVS Developer Studio - Gerado pelo Assistente de Código
@version   1.xx
@since     14/11/2013
/*/
//------------------------------------------------------------------------------------------
user function INSPSEG
//--< variáveis >---------------------------------------------------------------------------

//Indica a permissão ou não para a operação (pode-se utilizar 'ExecBlock')
	local cVldAlt := ".T." // Operação: ALTERAÇÃO
	local cVldExc := ".T." // Operação: EXCLUSÃO

//trabalho/apoio
	local cAlias

//--< procedimentos >-----------------------------------------------------------------------
	cAlias := "Z11"
	chkFile(cAlias)
	dbSelectArea(cAlias)
//indices
	dbSetOrder(1)
	axCadastro(cAlias, "Cadastro de Inspecoes de Seguranca", cVldExc, cVldAlt)

	return
//--< fim de arquivo >----------------------------------------------------------------------
