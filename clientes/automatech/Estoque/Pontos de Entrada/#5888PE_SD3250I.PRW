#INCLUDE "rwmake.ch" 

// Jean Rehermann | JPC - No apontamento da OP verifica se está encerrado e altera o status do PV
User Function SD3250I()
	
	Local _aAreaSD3 := SD3->( GetArea() )
	Local _aAreaSC2 := SC2->( GetArea() )
	Local _aAreaSC6 := SC6->( GetArea() )
	Local _aAreaSC9 := SC9->( GetArea() )
	Local _aAreaSB2 := SB2->( GetArea() )              
	Local _nSaldoSB2:= 0
	Local _nQtdAlt	:= 0
	Local _lAltera	:= .F.
	
//	If SD3->D3_PARCTOT == "T" .Or. ( SC2->C2_QUJE - SC2->C2_PERDA ) >= SC2->C2_QUANT // Apontamento total, encerrando a OP
		
		dbSelectArea("SC2")
		dbSetOrder(1)
		If dbSeek( xFilial("SC2") + SD3->D3_OP )
			If !Empty( AllTrim( SC2->C2_PEDIDO + SC2->C2_ITEMPV ) ) // Amarrado com pedido de venda
				dbSelectArea("SC6")
				dbSetOrder(1)
				If dbSeek( xFilial("SC6") + SC2->C2_PEDIDO + SC2->C2_ITEMPV )
					SB2->(dbSeek(xFilial("SB2")+SC2->C2_PRODUTO))
					_nSaldoSB2	:= SaldoSB2(,,,,,"SB2")
					If SC6->C6_STATUS == "07" // Jean Rehermann | Solutio - 30/10/2012 - Só permite alterar o status se estiver em produção
						Begin Transaction
						RecLock("SC6", .F.)
							// Jean Rehermann | Solutio - 15/10/2012 - Tarefa #5588 - Altera no PV a quantidade para ficar igual a produzida
							If ( SC2->C2_QUJE - SC2->C2_PERDA ) >= SC2->C2_QUANT
								If ApMsgYesNo("A OP está sendo produzida com uma quantidade maior do que o pedido de venda!"+CHR(10)+CHR(13)+"Total Produzido: "+Alltrim(Str(SC2->C2_QUJE - SC2->C2_PERDA,2))+CHR(13)+"Total da OP: "+Alltrim(Str(SC2->C2_QUANT,2))+CHR(13)+"Total do Pedido: "+Alltrim(Str(SC6->C6_QTDVEN,2))+CHR(10)+CHR(13)+"Deseja alterar a quantidade do pedido de venda para: "+Alltrim(Str(SC2->C2_QUJE,2))+"?","Atenção - "+ProcName())
									_nQtdAlt		:= SC2->C2_QUJE
									SC6->C6_QTDVEN	:= SC2->C2_QUJE
									SC6->C6_VALOR	:= Round( SC2->C2_QUJE * SC6->C6_PRCVEN, TamSX3("C6_VALOR")[2] )
									_lAltera		:= .T.
								Endif
							ElseIf ( SC2->C2_QUJE - SC2->C2_PERDA + _nSaldoSB2 ) < SC2->C2_QUANT
								If ApMsgYesNo("A OP está sendo produzida com uma quantidade menor do que o pedido de venda!"+CHR(10)+CHR(13)+"Total Produzido: "+Alltrim(Str(SC2->C2_QUJE - SC2->C2_PERDA,2))+CHR(13)+"Total da OP: "+Alltrim(Str(SC2->C2_QUANT,2))+CHR(13)+"Total do Pedido: "+Alltrim(Str(SC6->C6_QTDVEN,2))+CHR(13)+"Saldo do Produto: "+Alltrim(Str(_nSaldoSB2,2))+CHR(10)+CHR(13)+"Deseja alterar a quantidade do pedido de venda para: "+Alltrim(Str(SC2->C2_QUJE + _nSaldoSB2,2))+"?","Atenção - "+ProcName())
									_nQtdAlt		:= SC2->C2_QUJE + _nSaldoSB2
									SC6->C6_QTDVEN	:= SC2->C2_QUJE + _nSaldoSB2
									SC6->C6_VALOR	:= Round( SC2->C2_QUJE * SC6->C6_PRCVEN, TamSX3("C6_VALOR")[2] )
									_lAltera		:= .T.
								Endif
							EndIf
							// Fim tarefa #5588
							
							SC6->C6_STATUS := "08" // Aguardando separação de estoque
							U_GrvLogSts(SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "08", "PE_SD3250I", SC6->C6_QTDVEN) // Gravo o log de atualização de status na tabela ZZ0
							MsUnLock()
							
							If _lAltera
								dbSelectArea("SC9")
								dbSetOrder(1)
								If dbSeek( xFilial("SC9") + SC2->C2_PEDIDO + SC2->C2_ITEMPV )
									RecLock("SC9", .F.)
										SC9->C9_BLEST	:= "02"
										SC9->C9_BLCRED	:= "02"
										SC9->C9_QTDLIB	:= _nQtdAlt
									MsUnLock()
								Endif
								dbSelectArea("SB2")
								dbSetOrder(1)
								If dbSeek( xFilial("SB2") + SC2->C2_PRODUTO )
									RecLock("SB2", .F.)
										SB2->B2_QPEDVEN	:= SB2->B2_QPEDVEN + SC2->C2_QUJE
									MsUnLock()
								Endif
							Endif
						End Transaction
					EndIf
				EndIf
			EndIf
		EndIf
		
//	EndIf
	
	RestArea( _aAreaSC6 )
	RestArea( _aAreaSC2 )
	RestArea( _aAreaSD3 )
	RestArea( _aAreaSC9 )
	RestArea( _aAreaSB2 )
	
Return()
