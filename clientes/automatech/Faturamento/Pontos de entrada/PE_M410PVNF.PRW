#INCLUDE "protheus.ch"

/*
Jean Rehermann
Ponto de entrada na fun��o Prep.doc.Sa�da do pedido de vendas
N�o permite a execu��o do faturamento de pedidos sem passar pelas rotinas que controlam o status
*/

User Function M410PVNF

	Local lRet := .F.

   U_AUTOM628("PE_M410PVNF")
	
	MsgAlert("Esta funcionalidade est� desabilitada!")
	
Return lRet