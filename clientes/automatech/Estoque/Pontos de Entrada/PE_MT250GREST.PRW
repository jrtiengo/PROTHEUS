#INCLUDE "protheus.ch" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT250GREST ºAutor  ³Robson Salvieri     º Data ³  05/04/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³P.E. na exclusao de movimento de producao                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Automatech - Solutio IT                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Alterado: ANALISTA - 18/99/99
          Ficha: 000000 - Analista - Motivo da Alteracao
*/
User Function MT250GREST()
	
	Local _aAreaSD3 := SD3->( GetArea() )
	Local _aAreaSC2 := SC2->( GetArea() )
	Local _aAreaSC6 := SC6->( GetArea() )
	Local _aAreaSC9 := SC9->( GetArea() )
	Local _aAreaSB2 := SB2->( GetArea() )              

   U_AUTOM628("PE_MT250GREST")

	If !Empty( AllTrim( SC2->C2_PEDIDO + SC2->C2_ITEMPV ) ) // Amarrado com pedido de venda
		dbSelectArea("SC6")
		dbSetOrder(1)
		If dbSeek( xFilial("SC6") + SC2->C2_PEDIDO + SC2->C2_ITEMPV )
			If SC6->C6_STATUS == "08" //08 - Aguardando separacao estoque 
				Begin Transaction
					RecLock("SC6", .F.)
						SC6->C6_STATUS := "07" //07 - Em producao
						DbSelectArea("ZZ0")
						DbSetOrder(2) //ZZ0_FILIAL+ZZ0_PEDIDO+ZZ0_ITEMPV
						If DbSeek(xFilial("ZZ0")+SC6->C6_NUM+SC6->C6_ITEM)
							While !Eof() .And. SC6->C6_NUM+SC6->C6_ITEM == ZZ0->ZZ0_PEDIDO+ZZ0->ZZ0_ITEMPV
								If ZZ0->ZZ0_PEDIDO == "07"
									DbSelectArea("SC6")
									SC6->C6_QTDVEN	:= SC6->C6_QTDORI // ZZ0->ZZ0_QTDORI - Alterado em 30/11/13 - Jean Rehermann
								Endif
								DbSelectArea("ZZ0")
								dbSkip()
							EndDo 
						EndIf
						U_GrvLogSts(SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "07", "PE_MT250GREST", 0 ) // Gravo o log de atualização de status na tabela ZZ0
					MsUnLock()
					dbSelectArea("SB2")
					dbSetOrder(1)
					If dbSeek( xFilial("SB2") + SC2->C2_PRODUTO )
						RecLock("SB2", .F.)
							SB2->B2_QPEDVEN	:= SB2->B2_QPEDVEN - SD3->D3_QUANT
						MsUnLock()
					Endif   
				End Transaction
			EndIf
		EndIf
	EndIf
	
	RestArea( _aAreaSC6 )
	RestArea( _aAreaSC2 )
	RestArea( _aAreaSD3 )
	RestArea( _aAreaSC9 )
	RestArea( _aAreaSB2 )
	
Return()