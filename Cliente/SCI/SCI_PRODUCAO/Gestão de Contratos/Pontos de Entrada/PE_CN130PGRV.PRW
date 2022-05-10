#INCLUDE "PROTHEUS.CH"

User Function CN130PGRV()
Local ExpN1 := PARAMIXB[1]  //Validações do usuário.Return Nil
Local aArea	:= GetArea()

IF ExpN1=3
	U_SCI99D()//Funcao que envia o e-mail de Workflow do Pedido de Compra
Endif
RestArea( aArea )
return
