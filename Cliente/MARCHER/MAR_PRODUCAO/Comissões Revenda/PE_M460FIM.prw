#include 'protheus.ch'
#include 'marcher.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ M460FIM º Autor ³ Jorge Alberto       º Data ³ 10/10/2017  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ PE Este ponto de entrada pertence à geracao da Nota Fiscal º±±
±±º          ³ de Saída.                                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Marcher                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function M460FIM()
	
	Local cAreaAnt := Alias()
	Local aArea := GetArea()
	Local aAreaSA3  := SA3->( GetArea() )
	Local aNFS := {}
	Local aNFE := {}
	Local cVend := ""
	
	aSize( aNFS, nQtdeColNfS ) // Seta como default um array com 6 posicoes vazias 
	aSize( aNFE, nQtdeColNfE ) // Seta como default um array com 6 posicoes vazias 
	
	// Retorna o Vendedor do Pedido
	cVend := U_MA20VEND( SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA )

	If !Empty( cVend )

		dbSelectArea("SA3")
		dbSetOrder(1)
		dbSeek( xFilial("SA3") + cVend )
	
		If SA3->A3_TIPO $ 'E/R' // Se for Revenda então grava o registro da Entrega Técnica
			
			aNFS[ nPos_DocNfS ] := SF2->F2_DOC
			aNFS[ nPos_SerNfS ] := SF2->F2_SERIE
			aNFS[ nPos_CliNfS ] := SF2->F2_CLIENTE
			aNFS[ nPos_LojNfS ] := SF2->F2_LOJA
			aNFS[ nPos_DtNfS  ] := dDataBase 
			aNFS[ nPos_UsuNfS ] := RetCodUsr()
			
			// Rotina em MARA020.prw 
			If ! U_MA020INC( aNFS, aNFE, cVend, "1", 0 )
				MsgInfo( "Não foi possível incluir a Entrega Técnica da comissão da Revenda, a inclusão deverá ser feita manualmente ! ", "Comissão de Revenda" )
			EndIf
			 
		EndIf
	EndIf
	
	RestArea( aAreaSA3 )
	RestArea( aArea )
	dbSelectArea( cAreaAnt )
	
Return