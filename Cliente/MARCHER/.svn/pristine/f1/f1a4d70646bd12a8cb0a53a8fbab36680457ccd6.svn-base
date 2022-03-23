#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT120F   ºAutor  ³ Jorge Alberto       º Data ³ 17/08/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Último PE depois de gravar os itens do Pedido de Compra.   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Marcher do Brasil                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT120F()

	Local cFilPedido  := PARAMIXB
	Local aAreaSC7	   := {}
	Local nTamAprov   := 0
	Local nTamConApro := 0

	// Só entra no PE se for na inclusão do PC
	If !INCLUI
		Return
	EndIf
	
	aAreaSC7    := SC7->( GetArea() )
	nTamAprov   := TamSX3( "C7_APROV"   )[1]
	nTamConApro := TamSX3( "C7_CONAPRO" )[1]
	
	DbSelectArea("SC7")
	DbSetOrder(1)
	If SC7->( DbSeek( cFilPedido ) )

		While SC7->( !EOF() ) .And. SC7->C7_FILIAL + SC7->C7_NUM == cFilPedido
		
			If SC7->C7_APROV == "LIMPAR"

				If RecLock("SC7",.F.)
					SC7->C7_APROV   := Space( nTamAprov )
					SC7->C7_CONAPRO := Space( nTamConApro )
					MsUnlock()
				EndIf
			EndIf
							
			SC7->( DbSkip() )
		EndDo
		
	EndIf
	DbCloseArea()		
	RestArea( aAreaSC7 )

Return
