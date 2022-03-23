#include 'protheus.ch'
#include 'marcher.ch'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � M460FIM � Autor � Jorge Alberto       � Data � 10/10/2017  ���
�������������������������������������������������������������������������͹��
���Descricao � PE Este ponto de entrada pertence � geracao da Nota Fiscal ���
���          � de Sa�da.                                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Marcher                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
	
		If SA3->A3_TIPO $ 'E/R' // Se for Revenda ent�o grava o registro da Entrega T�cnica
			
			aNFS[ nPos_DocNfS ] := SF2->F2_DOC
			aNFS[ nPos_SerNfS ] := SF2->F2_SERIE
			aNFS[ nPos_CliNfS ] := SF2->F2_CLIENTE
			aNFS[ nPos_LojNfS ] := SF2->F2_LOJA
			aNFS[ nPos_DtNfS  ] := dDataBase 
			aNFS[ nPos_UsuNfS ] := RetCodUsr()
			
			// Rotina em MARA020.prw 
			If ! U_MA020INC( aNFS, aNFE, cVend, "1", 0 )
				MsgInfo( "N�o foi poss�vel incluir a Entrega T�cnica da comiss�o da Revenda, a inclus�o dever� ser feita manualmente ! ", "Comiss�o de Revenda" )
			EndIf
			 
		EndIf
	EndIf
	
	RestArea( aAreaSA3 )
	RestArea( aArea )
	dbSelectArea( cAreaAnt )
	
Return