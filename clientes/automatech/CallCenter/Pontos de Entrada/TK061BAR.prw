#Include "Protheus.ch"

User Function TK271ROTM()

   Local arOTINA := {}

   AAdd(aRotina,{ "Dados NF", "U_AUTOM134(SUA->UA_FILIAL, SUA->UA_NUM)", 0, 7}) 	
   AAdd(aRotina,{ "Impressão Pedido", "U_AUTOM157(SUA->UA_FILIAL, SUA->UA_NUM)", 0, 7}) 	

Return(aRotina)