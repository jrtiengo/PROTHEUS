#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#include "TOPCONN.CH"

/*/{Protheus.doc} M410STTS
//Este ponto de entrada pertence à rotina de pedidos de venda, MATA410().
//Esta em todas as rotinas de inclusão, alteração, exclusão, cópia e devolução de compras.
//Executado após todas as alterações no arquivo de pedidos terem sido feitas.
@author Celso Rene
@since 26/01/2021
@version 1.0
@type function
/*/
User Function M410STTS()

	Local _nOper    := PARAMIXB[1]
    Local _cUpdtCB0 := ""
	Local _cUpdtZZ1 := ""

	if (_nOper == 5) //exclusao

		//atualizando o campo pedido de venda dos itens da expedicao - processo exclusado registro P.V.
		_cUpdtCB0 := " UPDATE " + RetSqlName("CB0") + " SET CB0_PEDVEN = '' WHERE D_E_L_E_T_ = '' AND CB0_PEDVEN = '" + SC5->C5_NUM + "' AND CB0_XNEXPE <> '' "
		TcSqlExec(_cUpdtCB0)
		
		_cUpdtZZ1 := " UPDATE " + RetSqlName("ZZ1") + " SET ZZ1_PEDVEN = '' ,  ZZ1_DATAPV = ''  WHERE D_E_L_E_T_ = '' AND ZZ1_PEDVEN = '" + SC5->C5_NUM + "' "
		TcSqlExec(_cUpdtZZ1)

	endif


Return()
