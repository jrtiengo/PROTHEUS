#INCLUDE "protheus.ch"

// Ponto de entrada para ativar a tecla F11 na tela do pedido de vendas

User Function MT410BRW()
	
   U_AUTOM628("PE_MT410BRW")

	If RetCodUsr() $ "000000"
		SetKey( VK_F11, { || Iif( "C6" $ AllTrim( ReadVar() ), U_MargemBut(1), ) } )
    EndIf
    
Return