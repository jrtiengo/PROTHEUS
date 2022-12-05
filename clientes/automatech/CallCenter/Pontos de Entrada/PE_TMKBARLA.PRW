#INCLUDE "protheus.ch"

// Ponto de entrada para ativar a tecla F11 na tela do televendas

User Function TMKBARLA()
	
	If RetCodUsr() $ "000000"
		SetKey( VK_F11, { || Iif( "UB" $ AllTrim( ReadVar() ), U_MargemBut(3), ) } )
    EndIf
    
Return( {} )