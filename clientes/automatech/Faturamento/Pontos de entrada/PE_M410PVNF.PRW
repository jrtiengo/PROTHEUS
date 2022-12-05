#INCLUDE "protheus.ch"

/*
Jean Rehermann
Ponto de entrada na função Prep.doc.Saída do pedido de vendas
Não permite a execução do faturamento de pedidos sem passar pelas rotinas que controlam o status
*/

User Function M410PVNF

	Local lRet := .F.

   U_AUTOM628("PE_M410PVNF")
	
	MsgAlert("Esta funcionalidade está desabilitada!")
	
Return lRet