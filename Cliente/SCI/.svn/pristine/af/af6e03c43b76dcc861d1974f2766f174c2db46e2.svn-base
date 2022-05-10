#Include "Totvs.ch"
#Include 'apvt100.ch'
/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    | SCIA139 | Autor | Denis Rodrigues        | Data |28/04/2020|||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao | Funcao para a conferencia de Solicitacao ao Armazem via ACD|||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Parametros|                                                            |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|||  Uso      | Especifico SCI                                             |||
|||-----------+------------------------------------------------------------|||
|||                           ULTIMAS ALTERACOES                           |||
|||-------------+--------+-------------------------------------------------|||
||| Programador | Data   | Motivo da Alteracao                             |||
|||-------------+--------+-------------------------------------------------|||
|||             |        |                                                 |||
|||-------------+--------+-------------------------------------------------|||
|============================================================================|*/
User Function SCIA139()

	Local cCodEmp := "01"
	Local cCodFil := "0101"
	Local cOpcao1 := space(1)

	VTClear()
	VTSetSize(18,32)

	RpcClearEnv()
	RpcSetType( 3 )
	RpcSetenv( cCodEmp, cCodFil,,,,GetEnvServer(),{"SCP"} )
	
	While .T.

		cOpcao1 := space(1)
	
		VTClear()
		VTClearBuffer()
	
		@ 00,00 VTSay "+-------------------------+"
		@ 01,00 VTSay "|  SEPARACAO DE SA SCI    |"
		@ 02,00 VTSay "+-------------------------+"
		@ 03,00 VTSay "|  ESCOLHA OPCAO ABAIXO   |"
		@ 04,00 VTSay "+-------------------------+"
		@ 05,00 VTSay "|                         |"
		@ 06,00 VTSay "| ( 1 ) SELECIONAR SA     |"
		@ 07,00 VTSay "| (ESC) SAIR              |"
		@ 08,00 VTSay "|                         |"
		@ 09,00 VTSay "| Opcao:                  |"
		@ 09,09 VTGet cOpcao1 Valid cOpcao1 $ "1"
		@ 10,00 VTSay "+-------------------------+"
	
		VTRead
		
		If VTLastKey() == 27
		
			VTClear()
			VTClearBuffer()
			Exit

		EndIf
	
		VTClear()
		
		If cOpcao1=="1"
			A130SELSA()
		EndIf
	
	EndDo

Return

/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    |A130SELSA| Autor | Denis Rodrigues        | Data |28/04/2020|||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao |  Funcao para incluir informacoes no array                  |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | A040INC(cExp1)                                             |||
|||-----------+------------------------------------------------------------|||
||| Parametros| cExp1 - conteudo a ser incluido                            |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function A130SELSA()

	Local cNumSA  := Space( TamSX3("CP_NUM")[01] )	
	Local cCodBar := Space( TamSX3("B1_CODBAR")[01] )
	Local cCodEnd := Space( TamSX3("BF_LOCALIZ")[01] )
	Local cCodPrd := ""
	Local cEndPrd := ""
	Local cLocPrd := ""
	Local cLotPrd := ""
	Local cCodLot := Space( TamSX3("B8_LOTECTL")[01] )
	Local cAliasT := ""
	Local cAliasT2:= ""
	Local cAliasT3:= ""
	Local cQuery  := ""
	Local cQuery2 := ""
	Local cQuery3 := ""
	Local cOpcEsc := Space(1)
	Local nBepUni := 0
	Local nBepLot := 0
	Local nBepAux := 0
	Local nQuantSA:= 0
	Local nQtdSald:= 0
	Local nQtdSlLt:= 0
	Local nQtdPac := 0	
	Local lConfEnd:= .T.
	Local lCtrl   := .T.
	Local lPacote := .F.
	Local aAuxPrd := {}
	Local aProd   := {}
	
	VTBeep(2)
	
	While .T.
	
		VTClearBuffer()
		VTClear()
		cNumSA  := Space( TamSX3("CP_NUM")[01] )
	
		@ 00,00 VTSay "+------------------------+"
		@ 01,00 VTSay "|  SEPARACAO DE SA SCI   |"
		@ 02,00 VTSay "+------------------------+"
		@ 03,00 VTSay "| INFORME O NUMERO DA SA |"
		@ 04,00 VTSay "+------------------------+"
		@ 05,00 VTSay "|                        |"
		@ 06,00 VTSay "|                        |"
		@ 06,02 VTGet cNumSA F3 "SCPNSA"
		@ 07,00 VTSay "|                        |"
		@ 08,00 VTSay "|(ESC) VOLTA             |"
		@ 09,00 VTSay "+------------------------+"
		VTRead

		If VTLastKey() == 27
		
			VTClear()
			VTClearBuffer()
			Exit
			
		EndIf
	
		dbSelectArea("SCP")
		dbSetOrder(1)//CP_FILIAL+CP_NUM+CP_ITEM+DtoS(CP_EMISSAO)
		If !dbSeek( xFilial("SCP") + cNumSA )
		
			VTBeep(4)
			VTAlert("Numero da SA nao encontrada.","Alerta",.T.,3000)
			Loop
		
		Else

			nQuantSA := 0
			aAuxPrd := {}
			cAliasT := GetNextAlias()
			cQuery := " SELECT Z00_PROD,"
			cQuery += "        Z00_NUMSA,"
			cQuery += "        Z00_QTDSEP"
			cQuery += " FROM " + RetSQLName("Z00")
			cQuery += " WHERE Z00_FILIAL = '" + xFilial("Z00") 	+ "'"
			cQuery += "   AND Z00_NUMSA  = '" + cNumSA 		   	+ "'"
			cQuery += "   AND Z00_TIPO   = 'END'"
			cQuery += "   AND D_E_L_E_T_ = ' '"		
			cQuery += " ORDER BY R_E_C_N_O_"	
		
			cQuery := ChangeQuery( cQuery )
			dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )

			While ( cAliasT )->( !Eof() )

				cAliasT3 := GetNextAlias()
				cQuery3 := " SELECT CP_STACONF,"
				cQuery3 += "        CP_PREREQU,"
				cQuery3 += "        CP_QUJE,"
				cQuery3 += "        CP_QUANT"
				cQuery3 += " FROM " + RetSQLName("SCP")
				cQuery3 += " WHERE CP_FILIAL  = '" + xFilial("SCP") + "'"
				cQuery3 += "   AND CP_NUM     = '" + ( cAliasT )->Z00_NUMSA + "'"
				cQuery3 += "   AND CP_PRODUTO = '" + ( cAliasT )->Z00_PROD  + "'"
				cQuery3 += "   AND CP_STACONF <> 'XX'"
				cQuery3 += "   AND CP_PREREQU = 'S'"
				cQuery3 += "   AND CP_QUJE    <> CP_QUANT"
				cQuery3 += " ORDER BY CP_ITEM"

				cQuery3 := ChangeQuery(cQuery3)
				dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery3),cAliasT3,.F.,.T. )

				While ( cAliasT3 )->( !Eof() )

					If aScan( aAuxPrd, ( cAliasT )->Z00_PROD ) = 0

						aAdd( aAuxPrd, ( cAliasT )->Z00_PROD )

						dbSelectArea("SCP")
						dbSetOrder(1)//CP_FILIAL+CP_NUM+CP_ITEM+DtoS(CP_EMISSAO)
						dbSeek( xFilial("SCP") + cNumSA )

						If AllTrim( SCP->CP_PREREQU ) != "S"
						
							VTBeep(4)
							VTAlert("SA ainda nao foi gerada","Alerta",.F.,3000)
							Loop
					
						Else

							VTBeep(1)
							lCtrl    := .T.   
							nBepUni  := 0
							nBepLot  := 0
							nBepAux  := 0
							lConfEnd := .T.					

							//+----------------------------------+
							//|Verifica se o Produto tem endereço|
							//+----------------------------------+
							dbSelectArea("SB1")
							dbSetOrder(1)//B1_FILIAL+B1_COD
							If dbSeek( xFilial("SB1") + ( cAliasT )->Z00_PROD )
					
								If AllTrim( SB1->B1_LOCALIZ ) == "S"

									While lCtrl
								
										VTClearBuffer()
										VTClear()	

										//+--------------------------------------------------------+
										//|Retorna informacoes de saldo e endereço do produto da SA|
										//+--------------------------------------------------------+
										aProd := A139NUMSA( cNumSA,( cAliasT )->Z00_PROD, "END" )

										If AllTrim( cEndPrd ) <> AllTrim( aProd[1][3] )

											lConfEnd := .T.

											If AllTrim( cCodPrd ) == AllTrim( aProd[1][1] )
												
												nQuantSA := nQuantSA - nBepUni
												nBepUni := 0
											
											Else 
												nQuantSA := 0
											EndIf 

										EndIf 
																
										cLocPrd := aProd[1][2]//Local do Produto
										cEndPrd := aProd[1][3]//Endereco do Produto                                    

										If nQuantSA = 0										
											nQuantSA := aProd[1][8]//Quantidade para bipar										
										EndIf 

										cCodPrd  := aProd[1][1]//Codigo do Produto

										//Se a quantidade do endereço for menor que a bipagem pula o endereço
										If nBepUni >= aProd[1][04]
											Loop
										EndIf 
																
										If lConfEnd//Confirma endereco
									
											nQtdSald := aProd[1][4]//Saldo disponivel
											cCodEnd := Space( TamSX3("BF_LOCAL")[01] ) + Space( TamSX3("BF_LOCALIZ")[01] )											
																								
											VTClearBuffer()
											VTClear()   
											@ 00,00 VTSay "+--------------------------+"
											@ 01,00 VTSay "|  SEPARACAO DE SA SCI     |"
											@ 02,00 VTSay "+--------------------------+"
											@ 03,00 VTSay "| NUMERO DA SA:            |"
											@ 03,16 VTSay cNumSA 
											@ 04,00 VTSay "---------------------------+"
											@ 05,00 VTSay "| LOCAL:                   |"
											@ 05,10 VTSay AllTrim( cLocPrd )
											@ 06,00 VTSay "| BIPAR ENDERECO:          |"
											@ 06,19 VTSay AllTrim( cEndPrd )
											@ 07,00 VTSay "+--------------------------+"
											@ 08,00 VTSay "| CONFIRMAR ENDERECO:      |"
											@ 09,00 VTSay "|                          |"
											@ 10,02 VTGet cCodEnd
											@ 10,00 VTSay "|                          |"
											@ 11,00 VTSay "+--------------------------+" 
											@ 12,00 VTSay "|(ESC) VOLTA               |"
											@ 13,00 VTSay "+--------------------------+"
											VTRead
											
											If VTLastKey() == 27
											
												VTClear()
												VTClearBuffer()
												Exit
												
											EndIf
										
										EndIf

										If AllTrim( cCodEnd ) != AllTrim( cLocPrd ) + AllTrim( cEndPrd )
					
											cCodEnd := Space( TamSX3("BF_LOCALIZ")[01] )
											cCodLoc := Space( TamSX3("BF_LOCAL")[01] )
											VTAlert( "Endereco invalido.","Endereco",.F.,1000 )
											Loop
												
										Else

											lConfEnd := .F.

											VTClearBuffer()
											VTClear()
											@ 00,00 VTSay "+------------------------+"
											@ 01,00 VTSay "|  SEPARACAO DE SA SCI   |"
											@ 02,00 VTSay "+------------------------+"
											@ 03,00 VTSay "| NUMERO DA SA:          |"
											@ 03,16 VTSay cNumSA 
											@ 04,00 VTSay "-------------------------+"
											@ 05,00 VTSay "| LOCAL:                 |"
											@ 05,10 VTSay AllTrim( cLocPrd )
											@ 06,00 VTSay "| ENDERECO:              |"
											@ 06,12 VTSay AllTrim( cEndPrd )
											@ 07,00 VTSay "+------------------------+"
											@ 08,00 VTSay "| PRODUTO:               |"
											@ 08,11 VTSay AllTrim( aProd[1][1] )
											@ 09,00 VTSay "+------------------------+"
											@ 10,00 VTSay "|                        |"
											@ 11,00 VTSay "|                        |"
											@ 11,02 VTGet cCodBar
											@ 12,00 VTSay "+------------------------+" 
											@ 13,00 VTSay "|(ESC) VOLTA             |"
											@ 14,00 VTSay "+------------------------+"
											VTRead

											If VTLastKey() == 27
											
												cOpcEsc := Space(1)
												VTClear()
												VTClearBuffer()					
												@ 00,00 VTSay "+------------------------+"
												@ 01,00 VTSay "|  SEPARACAO DE SA SCI   |"										
												@ 02,00 VTSay "+------------------------+"
												@ 03,00 VTSay "| O QUE DESEJA FAZER?    |"												
												@ 04,00 VTSay "-------------------------+"
												@ 05,00 VTSay "| 1 PROXIMO ITEM         |"
												@ 06,00 VTSay "| 2 CONTINUAR            |"
												@ 07,00 VTSay "+------------------------+"
												@ 08,00 VTSay "| ESCOLHA:               |"												
												@ 09,00 VTSay "+------------------------+"
												@ 10,00 VTSay "|                        |"
												@ 11,02 VTGet cOpcEsc
												@ 12,00 VTSay "+------------------------+"
												VTRead

												If AllTrim( cOpcEsc ) == "1"

													VTAlert( "Leitura finalizada do item.","ITEM OK",.T.,2000 )
												
													dbSelectArea("SCP")
													dbSetOrder(2)//CP_FILIAL+CP_PRODUTO+CP_NUM+CP_ITEM
													If dbSeek( xFilial("SCP") + ( cAliasT )->Z00_PROD + PadR( cNumSA, TamSX3("CP_NUM")[01] ) )

														While SCP->( !Eof() ) .And. AllTrim( ( cAliasT )->Z00_PROD ) == AllTrim( SCP->CP_PRODUTO ) ;
																			  .And. AllTrim( cNumSA ) == AllTrim( SCP->CP_NUM ) ;
											
															If nBepUni < nQuantSA

																Reclock("SCP",.F.)
																	SCP->CP_STACONF := "YY"
																Msunlock()
															
															Else 

																If nQuantSA = 0

																	Reclock("SCP",.F.)
																		SCP->CP_STACONF := "XX"
																	Msunlock()
																
																Else 

																	Reclock("SCP",.F.)
																		SCP->CP_STACONF := "YY"
																	Msunlock()

																EndIf 																	

															EndIf 
														
															SCP->( dbSkip() )

														EndDo

													EndIf

													dbSelectArea("Z00")
													dbSetOrder(2)//Z00_FILIAL+Z00_NUMSA+Z00_PROD+Z00_LOCAL+Z00_ENDER+Z00_LOTE
													If dbSeek( xFilial("Z00") + cNumSA + ( cAliasT )->Z00_PROD + cLocPrd + cEndPrd )

														Reclock("Z00",.F.)
															Z00->Z00_STACON := "PA"//Parcial
														MsUnlock()
													
													EndIf 
													nQuantSA := 0

													Exit
																									
												Else 
													Loop
												EndIf 
												
											EndIf


											//EAN14
											If Len( AllTrim( cCodBar ) ) = 14 

												//Trecho para verificar a etiqueta de pacote
												dbSelectArea("SB5")
												dbSetOrder(1)//B5_FILIAL+B5_COD
												If dbSeek( xFilial("SB5") + ( cAliasT )->Z00_PROD )

													Do Case 
														Case SubStr( cCodBar,1,1 ) == "1"//B5_EAN141 - 6 Unidades

															nQtdPac := SB5->B5_EAN141
															aProd[1][9] := "1" + AllTrim( SB1->B1_CODBAR )
															lPacote := .T.

														Case SubStr( cCodBar,1,1 ) == "2"//B5_EAN142 - 12 Unidades

															nQtdPac := SB5->B5_EAN142
															aProd[1][9] := "2" + AllTrim( SB1->B1_CODBAR )
															lPacote := .T.

														Case SubStr( cCodBar,1,1 ) == "3"//B5_EAN143 - 24 Unidades

															nQtdPac := SB5->B5_EAN143
															aProd[1][9] := "3" + AllTrim( SB1->B1_CODBAR )
															lPacote := .T.

														Case SubStr( cCodBar,1,1 ) == "4"//B5_EAN143 - 48 Unidades

															nQtdPac := SB5->B5_EAN144
															aProd[1][9] := "4" + AllTrim( SB1->B1_CODBAR )
															lPacote := .T.

														Case SubStr( cCodBar,1,1 ) == "5"//B5_EAN143 - 60 Unidades

															nQtdPac := SB5->B5_EAN145
															aProd[1][9] := "5" + AllTrim( SB1->B1_CODBAR )
															lPacote := .T.

														Case SubStr( cCodBar,1,1 ) == "6"//B5_EAN143 - 72 Unidades

															nQtdPac := SB5->B5_EAN146
															aProd[1][9] := "6" + AllTrim( SB1->B1_CODBAR )
															lPacote := .T.

														OtherWise

															nQtdPac := 0
															aProd[1][9] := AllTrim( SB1->B1_CODBAR )
															lPacote := .F.

													EndCase 

													aProd[1][10] := nQtdPac
												
												EndIf 
											
											Else 

												nQtdPac := 0
												lPacote := .F.
											
											EndIf 

											If AllTrim( cCodBar ) != AllTrim( aProd[1][9] )

												VTAlert( "Produto invalido","Invalido",.F.,1000 )
												cCodBar := Space( TamSX3("B1_CODBAR")[01] )
												Loop

											Else

												If aProd[1][10] > nQtdSald

													VTAlert( "O endereco " + AllTrim( cEndPrd ) + "tem apenas " + cValToChar(nQtdSald),"Ler etq. unitario",.F.,2000 )
													cCodBar := Space( TamSX3("B1_CODBAR")[01] )
													Loop

												Else 

													If aProd[1][10] > ( nQuantSA - nBepUni )
													
														VTAlert( "Quantidade maior do que esta na SA","Codigo Pacote",.F.,2000 )
														cCodBar := Space( TamSX3("B1_CODBAR")[01] )
														Loop
													
													Else 
							
														//+----------------------------------+
														//|Verifica se o Produto tem Lote    |
														//+----------------------------------+
														If SB1->B1_RASTRO $ 'L|S' //Se controla rastreabilidade, devemos informar o lote

															aProd := A139NUMSA( cNumSA,( cAliasT )->Z00_PROD, "LOT" )
														
															If AllTrim( cLotPrd ) <> AllTrim( aProd[1][5] )
																nBepLot := 0
															EndIf 
									
															cLotPrd  := aProd[1][5]//Endereco do Produto

															aProd[1][10] := nQtdPac

															If !Empty( aProd[1][7] )
															
																nQtdSlLt := aProd[1][6]//Saldo do Lote
																cCodLot := Space( TamSX3("B8_LOTECTL")[01] )
																																					
																VTClearBuffer()
																VTClear()   
																@ 00,00 VTSay "+------------------------+"
																@ 01,00 VTSay "| NUMERO DA SA:          |"
																@ 01,16 VTSay cNumSA 
																@ 02,00 VTSay "-------------------------+"
																@ 03,00 VTSay "| NUM.LOTE:              |"
																@ 03,12 VTSay AllTrim( cLotPrd )
																@ 04,00 VTSay "|                        |"
																@ 05,00 VTSay "+------------------------+"
																@ 06,00 VTSay "| CONFIRMAR LOTE:        |"
																@ 07,00 VTSay "|                        |"
																@ 08,02 VTGet cCodLot
																@ 08,00 VTSay "|                        |"
																@ 09,00 VTSay "+------------------------+" 
																@ 10,00 VTSay "|(ESC) VOLTA             |"
																@ 11,00 VTSay "+------------------------+"
																VTRead

																If VTLastKey() == 27
																
																	VTClear()
																	VTClearBuffer()
																	cCodBar := Space( TamSX3("B1_CODBAR")[01] )
																	Loop
																	
																EndIf
														
																If Empty( cCodLot ) .Or. Upper( cCodLot ) != Upper( cLotPrd )

																	VTAlert( "Lote invalido.","Lote",.F.,1000 )
																	cCodLot := Space( TamSX3("B8_LOTECTL")[01] )
																	cCodBar := Space( TamSX3("B1_CODBAR")[01] )
																	Loop

																EndIf  
														
															EndIf 

														Else 
													
															nQtdSlLt := 0
															cCodLot  := Space( TamSX3("B8_LOTECTL")[01] )

														EndIf 
													
													EndIf 

												EndIf

												If nBepUni <= nQuantSA//Quantidade bipada menor que a quantidade da SA
																					
													If nQtdSald > 0//Saldo do endereco do produto maior que zero

														If aProd[1][10] = 0

															nBepAux := 1
															nBepUni++ //Aumenta Bip
															nBepLot++
														
														Else 

															nBepAux := aProd[1][10]
															nBepUni := nBepUni + aProd[1][10]
															nBepLot := nBepLot + aProd[1][10]

														EndIf 
																								
														nQtdSald--//Diminui Saldo

														dbSelectArea("Z00")
														dbSetOrder(2)//Z00_FILIAL+Z00_NUMSA+Z00_PROD+Z00_LOCAL+Z00_ENDER+Z00_LOTE
														If dbSeek( xFilial("Z00") + cNumSA + PadR( cCodPrd,TamSX3("B1_COD")[01] ) + cLocPrd + PadR( cEndPrd,TamSX3("Z00_ENDER")[01] ) )

															Reclock("Z00",.F.)
																Z00->Z00_QTDSEP := nBepUni 
																Z00->Z00_STACON := "PA"//Parcial
																Z00->Z00_QTCONF := 0 
															MsUnlock()
																											
														EndIf

														//Se tiver Lote grava a quantidade
														If !Empty( cCodLot )

															cAliasT2 := GetNextAlias()
															cQuery2 := " SELECT R_E_C_N_O_ AS RECNO"
															cQuery2 += " FROM " + RetSQLName("Z00")
															cQuery2 += " WHERE Z00_FILIAL = '" + xFilial("Z00") + "'"
															cQuery2 += "   AND Z00_NUMSA  = '" + cNumSA         + "'"
															cQuery2 += "   AND Z00_PROD   = '" + cCodPrd        + "'"
															cQuery2 += "   AND Z00_LOTE   = '" + cCodLot        + "'"
															cQuery2 += "   AND Z00_TIPO   = 'LOT'"
															cQuery2 += "   AND D_E_L_E_T_ = ' '"														
															cQuery2 := ChangeQuery( cQuery2 )
															dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery2),cAliasT2,.F.,.T. )

															If ( cAliasT2 )->( !Eof() )

																dbSelectArea("Z00")
																Z00->( dbGoTo( ( cAliasT2 )->RECNO ) )

																Reclock("Z00",.F.)
																	Z00->Z00_QTDSEP := nBepLot
																	Z00->Z00_QTCONF := 0 
																MsUnlock()
																
															EndIf 

															( cAliasT2 )->( dbCloseArea() )

														EndIf 

														VTAlert( cValToChar( nBepUni ) + "/" + cValToChar( nQuantSA ) ,"Leitura OK",.T.,1000 )
														cCodBar := Space( TamSX3("B1_CODBAR")[01] )
																					
														aProd := {cCodPrd,; //01 - Produto Origem
														          cLocPrd,; //02 - Local Origem
																  nBepAux,; //03 - Quantidade
																  "",;      //04 - Sublote Origem
																  cCodLot,; //05 - Lote Origem
																  cEndPrd,; //06 - Endereço Origem
																  cCodPrd,; //07 - Produto Destino
																  cLocPrd,; //08 - Local Destino
																  "PALLET"} //09 - Endereço Destino 
												
														A139TRANF(aProd)//Função que realiza a transferencia para o novo Endereço
														
														If nBepUni = nQuantSA

															VTAlert( "Leitura finalizada do item.","ITEM OK",.T.,3000 )
														
															dbSelectArea("SCP")
															dbSetOrder(2)//CP_FILIAL+CP_PRODUTO+CP_NUM+CP_ITEM
															If dbSeek( xFilial("SCP") + ( cAliasT )->Z00_PROD + PadR( cNumSA, TamSX3("CP_NUM")[01] ) )

																While SCP->( !Eof() ) .And. AllTrim( ( cAliasT )->Z00_PROD ) == AllTrim( SCP->CP_PRODUTO ) ;
																					  .And. AllTrim( cNumSA ) == AllTrim( SCP->CP_NUM ) ;

																	If nBepUni < ( nQuantSA - ( cAliasT )->Z00_QTDSEP )

																		Reclock("SCP",.F.)
																			SCP->CP_STACONF := "YY"
																		Msunlock()
																	
																	Else 

																		Reclock("SCP",.F.)
																			SCP->CP_STACONF := "XX"
																		Msunlock()
																		
																	EndIf 
																
																	SCP->( dbSkip() )

																EndDo

															EndIf

															dbSelectArea("Z00")
															dbSetOrder(2)//Z00_FILIAL+Z00_NUMSA+Z00_PROD+Z00_LOCAL+Z00_ENDER+Z00_LOTE
															If dbSeek( xFilial("Z00") + cNumSA + ( cAliasT )->Z00_PROD + cLocPrd + cEndPrd )

																Reclock("Z00",.F.)
																	Z00->Z00_STACON := " "
																MsUnlock()
															
															EndIf 

															nBepUni  := 0
															nBepAux  := 0
															nQuantSA := 0
															lConfEnd := .T.
															lCtrl    := .F.
															lPacote  := .F. 

														EndIf 
													
													EndIf

												EndIf

											EndIf 

										EndIf 
								
									EndDo 

								Else 

									VTAlert( "O item " + AllTrim( ( cAliasT )->Z00_PROD ) + " nao possui endereco.","Sem endereco",.T.,3000 )
									Exit
							
								EndIf 
						
							EndIf 

						EndIf 
					
					EndIf 

					( cAliasT3 )->( dbSkip() )
				
				EndDo 

				( cAliasT3 )->( dbCloseArea() )

				( cAliasT )->( dbSkip() )

			EndDo 

			( cAliasT )->( dbCloseArea() )

		EndIf 

	EndDo 

Return

/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    |A139NUMSA| Autor | Denis Rodrigues        | Data |28/04/2020|||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao |  Funcao para incluir informacoes no array                  |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | A139NUMSA(cExp1,cExp2,cExp3)                               |||
|||-----------+------------------------------------------------------------|||
||| Parametros| cExp1 - conteudo a ser incluido                            |||
|||           | cExp2 - Codigo do Produto                                  |||
|||           | cExp3 - Endereço                                           |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function A139NUMSA( cNumSA,cCodProd,cTipo )

	Local cQuery  := ""
	Local cCodBar := ""
	Local cAliasT2:= GetNextAlias()
	Local cAliasT3:= ""
	Local cQuery3 := ""
	Local aRet	  := {}
	Local nQuantSA:= 0
	Local nQtdEnt := 0
	Local NQtdSA  := 0
	
	cQuery := " SELECT Z00_PROD,"
	cQuery += "        Z00_LOCAL,"
    cQuery += "        Z00_ENDER,"
	cQuery += "        Z00_QTDEND,"
	cQuery += "        Z00_LOTE,"
	cQuery += "        Z00_SALOTE,"
	cQuery += "        Z00_DAVALO,"
	cQuery += "        Z00_QTDSA,"
	cQuery += "        Z00_QTDSEP,"
	cQuery += "        Z00_STACON"
	cQuery += " FROM " + RetSQLName("Z00")
	cQuery += " WHERE Z00_FILIAL = '" + xFilial("Z00") 	+ "'"
	cQuery += "   AND Z00_NUMSA  = '" + cNumSA 		   	+ "'"
	cQuery += "   AND Z00_PROD   = '" + cCodProd  		+ "'"	

	If cTipo == "END"

		cQuery += "   AND Z00_QTDSEP < Z00_QTDEND"
		cQuery += "   AND Z00_QTDSEP < Z00_QTDSA"
		cQuery += "   AND Z00_TIPO   = 'END'"		

	Else 

		cQuery += "   AND Z00_TIPO   = 'LOT'"
		cQuery += "   AND Z00_QTDSEP < Z00_SALOTE"
		cQuery += "   AND Z00_LOTE = (SELECT TOP(1) Z00_LOTE "
		cQuery += "                   FROM " + RetSQLName("Z00")
		cQuery += "                    WHERE Z00_FILIAL = '" + xFilial("Z00") + "'" 
		cQuery += "                      AND Z00_TIPO   = 'END' "
		cQuery += "                      AND Z00_NUMSA  = '" + cNumSA   + "'" 
		cQuery += "                      AND Z00_PROD   = '" + cCodProd + "'" 
		cQuery += "                      AND Z00_QTDEND <> Z00_QTDSEP"
		cQuery += "                      AND D_E_L_E_T_ = ' '" 
		cQuery += "                      ORDER BY Z00_ENDER)"

	EndIf
	 
	cQuery += "   AND D_E_L_E_T_ = ' '"		
	cQuery += " ORDER BY Z00_ENDER"	

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT2,.F.,.T. )
	
	While ( cAliasT2 )->( !Eof() )

		dbSelectArea("SB1")
		dbSetOrder(1)//B1_FILIAL+B1_COD
		If dbSeek( xFilial("SB1") + ( cAliasT2 )->Z00_PROD )
			cCodBar := AllTrim( SB1->B1_CODBAR )		
		Else 
			cCodBar := "X"
		EndIf 

		If cTipo == "END"

			//Se for parcial e quantidade separada maior que zero
			If ( cAliasT2 )->Z00_QTDSEP > 0

				cAliasT3 := GetNextAlias()
				cQuery3 := " SELECT CP_STACONF,"
				cQuery3 += "        CP_PREREQU,"
				cQuery3 += "        CP_QUJE,"
				cQuery3 += "        CP_QUANT"
				cQuery3 += " FROM " + RetSQLName("SCP")
				cQuery3 += " WHERE CP_FILIAL  = '" + xFilial("SCP") + "'"
				cQuery3 += "   AND CP_NUM     = '" + cNumSA + "'"
				cQuery3 += "   AND CP_PRODUTO = '" + ( cAliasT2 )->Z00_PROD  + "'"
				cQuery3 += "   AND CP_PREREQU = 'S'"
				cQuery3 += "   AND CP_QUJE    <> CP_QUANT"
				cQuery3 += " ORDER BY CP_ITEM"

				cQuery3 := ChangeQuery(cQuery3)
				dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery3),cAliasT3,.F.,.T. )

				While ( cAliasT3 )->( !Eof() )

					nQtdEnt += ( cAliasT3 )->CP_QUJE
					NQtdSA  += ( cAliasT3 )->CP_QUANT

					( cAliasT3 )->( dbSkip() )
				
				EndDo 

				nQuantSA := NQtdSA - nQtdEnt

				( cAliasT3 )->( dbCloseArea() )

			Else 

				cAliasT3 := GetNextAlias()
				cQuery3 := " SELECT CP_STACONF,"
				cQuery3 += "        CP_PREREQU,"
				cQuery3 += "        CP_QUJE,"
				cQuery3 += "        CP_QUANT"
				cQuery3 += " FROM " + RetSQLName("SCP")
				cQuery3 += " WHERE CP_FILIAL  = '" + xFilial("SCP") + "'"
				cQuery3 += "   AND CP_NUM     = '" + cNumSA + "'"
				cQuery3 += "   AND CP_PRODUTO = '" + ( cAliasT2 )->Z00_PROD  + "'"
				cQuery3 += "   AND CP_PREREQU = 'S'"
				cQuery3 += "   AND CP_QUJE    <> CP_QUANT"
				cQuery3 += " ORDER BY CP_ITEM"

				cQuery3 := ChangeQuery(cQuery3)
				dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery3),cAliasT3,.F.,.T. )

				While ( cAliasT3 )->( !Eof() )

					nQtdEnt += ( cAliasT3 )->CP_QUJE
					NQtdSA  += ( cAliasT3 )->CP_QUANT

					( cAliasT3 )->( dbSkip() )
				
				EndDo 

				If nQtdEnt = 0 
					nQuantSA := ( cAliasT2 )->Z00_QTDSA
				Else 
					nQuantSA := NQtdSA - nQtdEnt
				EndIf 
		
				( cAliasT3 )->( dbCloseArea() )
				
			EndIf 
		
		EndIf 

		aAdd( aRet,{ ( cAliasT2 )->Z00_PROD,;   //01 - Cod.Produto
					 ( cAliasT2 )->Z00_LOCAL,;  //02 - Local
		 			 ( cAliasT2 )->Z00_ENDER,;  //03 - Endereço
		 			 ( cAliasT2 )->Z00_QTDEND,; //04 - Qtd. Endereço
		 			 ( cAliasT2 )->Z00_LOTE,;   //05 - Numero Lote
		 			 ( cAliasT2 )->Z00_SALOTE,; //06 - Saldo Lote
		 			 ( cAliasT2 )->Z00_DAVALO,; //07 - Data Valid. Lote
		 			 nQuantSA,;  			    //08 - Quant. da SA - Quanto Separada
					 cCodBar,;                  //09 - Codigo de Barras
					 0 } )			    		//10 - Quantidade do Pacote

		( cAliasT2 )->( dbSkip() )
		
	EndDo
	
	( cAliasT2 )->( dbCloseArea() )

	If Len( aRet ) = 0

		aAdd( aRet,{ "",; //01 - Cod.Produto
					 "",; //02 - Local
		 			 "",; //03 - Endereço
		 			 0,;  //04 - Qtd. Endereço
		 			 "",; //05 - Numero Lote
		 			 0,;  //06 - Saldo Lote
		 			 "",; //07 - Data Valid. Lote
		 			 0,;  //08 - Quant. da SA - Quanto Separada
					 "",; //09 - Codigo de Barras
					 0 } )//10 - Quantidade do Pacote

	EndIf 

Return( aRet )


/*/{Protheus.doc} A139TRANF
	Função para transferir as quantidades para outro endereço
	@type  Static Function
	@author Denis Rodrigues
	@since 03/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example (examples)
	@see (links_or_references)
/*/
Static Function A139TRANF(aProd)

	Local cOrigProdu := aProd[01]
	Local cOrigLocal := aProd[02]
	Local nQtde		 := aProd[03]
	Local cSubLote	 := aProd[04]
	Local cLoteCTL	 := Upper( aProd[05] )
	Local cOrigEnder := aProd[06]
	Local cDestProdu := aProd[07]
	Local cDestLocal := aProd[08]
	Local cDestEnder := aProd[09]
	Local dDtValida  := StoD("//")
	Local nX         := 0
	Local aAuto 	 := {}
	Local aLinha	 := {}
	Local cDocumen 	 := GetSxeNum("SD3","D3_DOC")
	Local cErrorLog  := ""
	Local aMsg 		 := {}

	Private lMsErroAuto := .F.
	Private lMSHelpAuto := .F.
	Private lAutoErrNoFile := .T.	

	aAdd( aAuto,{cDocumen,dDataBase}) //Cabecalho

	If nQtde > 1
		nQtde := 1
	EndIf 

	For nX := 1 To nQtde

  		aLinha := {}
    	//Origem
		SB1->(dbSeek(xFilial("SB1")+PadR( cOrigProdu, tamsx3('D3_COD') [1])))
		aAdd( aLinha,{"ITEM",'00'+cValToChar(nX),Nil})
		aAdd( aLinha,{"D3_COD", SB1->B1_COD, Nil}) //Cod Produto origem
		aAdd( aLinha,{"D3_DESCRI", SB1->B1_DESC, Nil}) //descr produto origem
		aAdd( aLinha,{"D3_UM", SB1->B1_UM, Nil}) //unidade medida origem
		aAdd( aLinha,{"D3_LOCAL", cOrigLocal, Nil}) //armazem origem
		aAdd( aLinha,{"D3_LOCALIZ", PadR( cOrigEnder, tamsx3('D3_LOCALIZ') [1]),Nil}) //Informar endereço origem
		
		//Destino
		SB1->(dbSeek(xFilial("SB1")+PadR( cDestProdu, TamSX3('D3_COD') [1])))
		aadd(aLinha,{"D3_COD", SB1->B1_COD, Nil}) //cod produto destino
		aadd(aLinha,{"D3_DESCRI", SB1->B1_DESC, Nil}) //descr produto destino
		aadd(aLinha,{"D3_UM", SB1->B1_UM, Nil}) //unidade medida destino
		aadd(aLinha,{"D3_LOCAL", cDestLocal, Nil}) //armazem destino
		aadd(aLinha,{"D3_LOCALIZ", PadR( cDestEnder,TamSX3('D3_LOCALIZ') [1]),Nil}) //Informar endereço destino
		
		aadd(aLinha,{"D3_NUMSERI", "", Nil}) //Numero serie
		aadd(aLinha,{"D3_LOTECTL", cLoteCTL, Nil}) //Lote Origem
		aadd(aLinha,{"D3_NUMLOTE", cSubLote, Nil}) //sublote origem
		aadd(aLinha,{"D3_DTVALID", dDtValida, Nil}) //data validade
		aadd(aLinha,{"D3_POTENCI", 0, Nil}) // Potencia

		If aProd[03] > 1
			aadd(aLinha,{"D3_QUANT", aProd[03], Nil}) //Quantidade
		Else 
			aadd(aLinha,{"D3_QUANT", 1, Nil}) //Quantidade
		EndIf 

		aadd(aLinha,{"D3_QTSEGUM", 0, Nil}) //Seg unidade medida
		aadd(aLinha,{"D3_ESTORNO", "", Nil}) //Estorno
		aadd(aLinha,{"D3_NUMSEQ", "", Nil}) // Numero sequencia D3_NUMSEQ
		
		aadd(aLinha,{"D3_LOTECTL", cLoteCTL, Nil}) //Lote destino
		aadd(aLinha,{"D3_NUMLOTE", cSubLote, Nil}) //sublote destino
		aadd(aLinha,{"D3_DTVALID", dDtValida, Nil}) //validade lote destino
		aadd(aLinha,{"D3_ITEMGRD", "", Nil}) //Item Grade
		
		aadd(aLinha,{"D3_CODLAN", "", Nil}) //cat83 prod origem
		aadd(aLinha,{"D3_CODLAN", "", Nil}) //cat83 prod destino
		
		aAdd(aAuto,aLinha)
		
	Next nX 

	lMSHelpAuto := .F.
	lMsErroAuto := .F.			
	lAutoErrNoFile := .T.	
	MSExecAuto({|x,y| mata261(x,y)},aAuto,3)

	If lMsErroAuto

		aMsg := GetAutoGRLog()
		aEval(aMsg,{|x| cErrorLog += x + CRLF })		
		ConOut(cErrorLog)
		VTAlert( cErrorLog,"Erro ao transferir",.T.,2000 )

	Else
		ConOut("Inclusão de movimentação com sucesso") 
	EndIf

Return
