#INCLUDE 'PROTHEUS.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MT103NPC � Autor � Jorge Alberto-Solutio � Data �21/02/2019���
�������������������������������������������������������������������������Ĵ��
���Descricao � PE chamado apos a confirmacao da selecao de um ou mais     ���
���          � Pedido de Compra ( via tecla F5 ) nas rotinas de Pre Nota  ���
���          � Entrada ou Documento de Entrada, ambas no modulo de Compras���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � U_MT103NPC()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� NIL                                                        ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � NIL											              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico para a empresa Sirtec                           ���
�������������������������������������������������������������������������Ĵ��
���                          ULTIMAS ALTERACOES                           ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
User Function MT103NPC()
	
	Local aAreaSC7 := SC7->( GetArea() )
	Local aAreaSC2 := SC2->( GetArea() )
	Local aArea    := GetArea()
	Local cAliAtu  := Alias()
	Local cFilSC7  := xFilial("SC7")
	Local cFilSC2  := xFilial("SC2")
	Local cNumOS   := ""
	Local nPosPC   := aScan( aHeader, {|x| AllTrim(x[2]) == "D1_PEDIDO" } )
	Local nPosItem := aScan( aHeader, {|x| Alltrim(x[2]) == "D1_ITEMPC" } )
	Local nPosOS   := aScan( aHeader, {|x| Alltrim(x[2]) == "D1_ORDEM"  } )
	Local nPosOP   := aScan( aHeader, {|x| Alltrim(x[2]) == "D1_OP"     } )
	Local nLinha   := 0
	Local nColOS   := 0
	
	DbSelectArea("SC2")
	DbSetOrder( 1 )
	
	DbSelectArea("SC7")
	DbSetOrder( 1 )
	
	For nLinha := 1 To Len( aCols )
		
		If ( !Empty( aCols[ nLinha, nPosPC ] ) .And. !Empty( aCols[ nLinha, nPosItem ] ) )
			
			If SC7->( DbSeek( cFilSC7 + aCols[ nLinha, nPosPC ] + aCols[ nLinha, nPosItem ] ) )
				
				nColOS := AT( "OS", SC7->C7_OBS )
				
				If nColOS > 0
					
					cNumOS := SubStr( SC7->C7_OBS, nColOS+2, 6 )
					
					aCols[ nLinha, nPosOS ] := cNumOS
					
					If SC2->( DbSeek( cFilSC2 + cNumOS ) )
						aCols[ nLinha, nPosOP ] := SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN
					EndIf
					
				EndIf
				
			EndIf
			
		EndIf
		
	Next
	
	RestArea( aAreaSC7 )
	RestArea( aAreaSC2 )
	RestArea( aArea )
	
	If !Empty( cAliAtu )
		DbSelectArea( cAliAtu )
	EndIf
	
Return( NIL )