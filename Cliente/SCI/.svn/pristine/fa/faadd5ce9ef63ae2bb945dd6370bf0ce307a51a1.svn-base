#Include "Totvs.ch"
#Include 'apvt100.ch'

/*/{Protheus.doc} User Function SCIA140
    Programa para Conferencia de Solicitação ao Armazem via ACD
    @type  Function
    @author Denis Rodrigues
    @since 01/06/2020
    @version 1.0
    @param 
    @return 
    @example
    @see 
/*/
User Function SCIA140()
    
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
		@ 01,00 VTSay "|  CONFERENCIA DE SA SCI  |"
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
			A140SEPSA()
		EndIf
	
	EndDo

Return 


/*/{Protheus.doc} User Function A140SEPSA
	Funcao para iniciar a conferencia dos itens da SA
	@type  Function
	@author Denis Rodrigues
	@since 01/06/2020
	@version 1.0
	@param 
	@return 
	@example
	@see
/*/
Static Function A140SEPSA()

	Local cNumSA  := Space( TamSX3("CP_NUM")[01] )	
	Local cCodBar := Space( TamSX3("B1_CODBAR")[01] )
	Local cCodPrd := ""
	Local cEndPrd := ""
	Local cLocPrd := ""
	Local cLotPrd := ""
	Local cCodLot := Space( TamSX3("B8_LOTECTL")[01] )
	Local cAliasT := ""
	Local cQuery  := ""	
	Local cAliasT3:= ""
	Local cQuery3 := ""
	Local nQtdBep := 0
	Local nBepAux := 0
	Local nQuantSA:= 0 
	Local nBepLote:= 0
	Local nPosIT  := 0
	Local lCtrl   := .T.
	Local lBaixaSA:= .F.
	Local lPacote := .F.
	Local aBaixaIT:= {}
	Local aAuxPrd := {}

	VTBeep(2)
	
	While .T.
	
		VTClearBuffer()
		VTClear()
		cNumSA  := Space( TamSX3("CP_NUM")[01] )
		aBaixaIT:= {}
	
		@ 00,00 VTSay "+------------------------+"
		@ 01,00 VTSay "| CONFERENCIA DE SA SCI  |"
		@ 02,00 VTSay "+------------------------+"
		@ 03,00 VTSay "| INFORME O NUMERO DA SA |"
		@ 04,00 VTSay "+------------------------+"
		@ 05,00 VTSay "|                        |"
		@ 06,00 VTSay "|                        |"
		@ 06,02 VTGet cNumSA F3 "SCPZ00"
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

			VTClear()
			VTClearBuffer()

			aBaixaIT:= {}
			nQuantSA := 0
			aAuxPrd := {}
			cAliasT := GetNextAlias()
			cQuery := " SELECT Z00_PROD,"
			cQuery += "        Z00_QTDSEP,"
			cQuery += "        Z00_NUMSA,"
			cQuery += "        Z00_ENDER"
			cQuery += " FROM " + RetSQLName("Z00")
			cQuery += " WHERE Z00_FILIAL = '" + xFilial("Z00") 	+ "'"
			cQuery += "   AND Z00_NUMSA  = '" + cNumSA 		   	+ "'"
			cQuery += "   AND Z00_TIPO   = 'END'"
			cQuery += "   AND Z00_QTDSEP > 0"
			cQuery += "   AND D_E_L_E_T_ = ''"					
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
				cQuery3 += "   AND CP_STACONF <> 'OK'"
				cQuery3 += "   AND CP_QUJE    <> CP_QUANT"
				cQuery3 += " ORDER BY CP_ITEM"

				cQuery3 := ChangeQuery(cQuery3)
				dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery3),cAliasT3,.F.,.T. )

				While ( cAliasT3 )->( !Eof() )

					If aScan( aAuxPrd,{|x| x[1] = ( cAliasT )->Z00_PROD .And. x[2] = ( cAliasT )->Z00_ENDER } ) = 0

						aAdd( aAuxPrd,{ ( cAliasT )->Z00_PROD, ( cAliasT )->Z00_ENDER } )

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
							nQtdBep  := 0
							nBepAux  := 0			

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
										aProd := A140NUMSA( cNumSA,( cAliasT )->Z00_PROD, "END" )
									
										cLocPrd  := aProd[1][2]//Local do Produto
										cEndPrd  := aProd[1][3]//Endereco do Produto  

										If nQuantSA = 0                                 
											nQuantSA := aProd[1][8]//Quantidade para bipar
										EndIf 

										cCodPrd  := aProd[1][1]//Codigo do Produto

										If nQuantSA = 0
											Exit
										EndIf 
										
										//Se a quantidade do endereço for menor que a bipagem pula o endereço
										If nBepAux >= aProd[1][04]
											Loop											
										EndIf 										
																
										VTClearBuffer()
										VTClear()
										@ 00,00 VTSay "+------------------------+"
										@ 01,00 VTSay "| CONFERENCIA DE SA SCI  |"									
										@ 02,00 VTSay "+------------------------+"
										@ 03,00 VTSay "| NUMERO DA SA:          |"
										@ 03,16 VTSay cNumSA 
										@ 04,00 VTSay "-------------------------+"
										@ 05,00 VTSay "| LOCAL:                 |"
										@ 05,10 VTSay AllTrim( cLocPrd )
										@ 06,00 VTSay "|                        |"
										@ 06,02 VTSay SubStr(aProd[1][11],1,23)
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
										
											VTClear()
											VTClearBuffer()
											lBaixaSA := .F.
											Exit
											
										EndIf


										If Len( AllTrim(cCodBar) ) = 14

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
										EndIf 

										If AllTrim( cCodBar ) != AllTrim( aProd[1][9] )

											VTAlert( "Produto invalido","Invalido",.F.,1000 )
											cCodBar  := Space( TamSX3("B1_CODBAR")[01] )
											Loop

										Else

											If aProd[1][10] > ( nQuantSA - nQtdBep )

												VTAlert( "Quantidade maior do que esta na SA","Codigo Pacote",.F.,2000 )
												cCodBar := Space( TamSX3("B1_CODBAR")[01] )
												Loop
											
											Else 										

												//+----------------------------------+
												//|Verifica se o Produto tem Lote    |
												//+----------------------------------+
												If SB1->B1_RASTRO $ 'L|S' //Se controla rastreabilidade, devemos informar o lote

													aProd := A140NUMSA( cNumSA,( cAliasT )->Z00_PROD, "LOT" )
								
													cLotPrd  := aProd[1][5]//Endereco do Produto

													aProd[1][10] := nQtdPac

													If !Empty( aProd[1][7] )

														If Upper( cCodLot ) != Upper( cLotPrd )                                 
															nBepLote := 0
														EndIf 
														
													
														cCodLot := Space( TamSX3("B8_LOTECTL")[01] )
																																		
														VTClearBuffer()
														VTClear()   
														@ 00,00 VTSay "+------------------------+"
														@ 01,00 VTSay "| CONFERENCIA DE SA SCI  |"																					
														@ 02,00 VTSay "+------------------------+"
														@ 03,00 VTSay "| NUMERO DA SA:          |"
														@ 03,16 VTSay cNumSA 
														@ 04,00 VTSay "-------------------------+"
														@ 05,00 VTSay "| NUM.LOTE:              |"
														@ 05,12 VTSay AllTrim( cLotPrd )
														@ 06,00 VTSay "|                        |"
														@ 07,00 VTSay "+------------------------+"
														@ 08,00 VTSay "| CONFIRMAR LOTE:        |"
														@ 09,00 VTSay "|                        |"
														@ 10,02 VTGet cCodLot
														@ 10,00 VTSay "|                        |"
														@ 11,00 VTSay "+------------------------+" 
														@ 12,00 VTSay "|(ESC) VOLTA             |"
														@ 13,00 VTSay "+------------------------+"
														VTRead

														If VTLastKey() == 27
														
															VTClear()
															VTClearBuffer()
															lBaixaSA := .F.
															Exit
															
														EndIf 

														If Empty( cCodLot ) .Or. Upper( cCodLot ) != Upper( cLotPrd )

															VTAlert( "Lote invalido.","Lote",.F.,1000 )
															cCodLot := Space( TamSX3("B8_LOTECTL")[01] )
															cCodBar := Space( TamSX3("B1_CODBAR")[01] )
															Loop

														EndIf  
													
													EndIf 

												Else 										
													cCodLot  := Space( TamSX3("B8_LOTECTL")[01] )
												EndIf 
											
											EndIf 
											
											If nQtdBep <= nQuantSA//Quantidade bipada menor que a quantidade da SA

												If aProd[1][10] = 0

													nBepAux++
													nQtdBep++ //Aumenta Bip
												
												Else 

													nBepAux := aProd[1][10]
													nQtdBep := nQtdBep + aProd[1][10]

												EndIf 
										
												dbSelectArea("Z00")
												dbSetOrder(2)//Z00_FILIAL+Z00_NUMSA+Z00_PROD+Z00_LOCAL+Z00_ENDER+Z00_LOTE
												If dbSeek( xFilial("Z00") + cNumSA + PadR( cCodPrd,TamSX3("B1_COD")[01] ) + cLocPrd + PadR( cEndPrd,TamSX3("Z00_ENDER")[01] ) )
																				
													Reclock("Z00",.F.)														
														Z00->Z00_STACON := "OK" 
														Z00->Z00_QTCONF := Iif( lPacote,nQtdBep,nBepAux )
													MsUnlock()
													
													//Se tiver Lote grava a quantidade
													If !Empty( cCodLot )

														dbSelectArea("Z00")
														dbSetOrder(3)//Z00_FILIAL+Z00_NUMSA+Z00_PROD+Z00_LOTE
														If dbSeek( xFilial("Z00") + cNumSA + PadR( cCodPrd,TamSX3("B1_COD")[01] ) + cCodLot )

															If lPacote

																Reclock("Z00",.F.)
																	Z00->Z00_QTCONF := nQtdBep
																MsUnlock()
															
															Else 

																Reclock("Z00",.F.)
																	Z00->Z00_QTCONF := Z00->Z00_QTCONF + nBepAux
																MsUnlock()
															
															EndIf 

														EndIf 

													EndIf 
														
													nPosIT := aScan( aBaixaIT, {|x| x[1] = AllTrim( cNumSA )  .And.;
																					x[2] = AllTrim( cCodPrd ) .And.;
																					x[4] = AllTrim( cLocPrd ) .And.; 
																					x[5] = AllTrim( cEndPrd ) .And.; 
																					x[6] = AllTrim( cCodLot ) } )

													If nPosIT = 0

														aAdd( aBaixaIT,{ AllTrim( cNumSA ),; //1-Numero SA
																		AllTrim( cCodPrd ),; //2-Produto
																		".",;				 //3-Item - Não esta sendo usado
																		AllTrim( cLocPrd ),; //4-Local
																		AllTrim( cEndPrd ),; //5-Endereco
																		AllTrim( cCodLot ),; //6-Lote
																		Iif(lPacote,nQtdBep,nBepAux) } ) //7-Quant.Bipada
													
													Else 

														If lPacote
															aBaixaIT[nPosIT][7] := nQtdBep//nBepAux
														Else 
															aBaixaIT[nPosIT][7] := aBaixaIT[nPosIT][7] + 1
														EndIf

													EndIf 
																											
												EndIf
																						
												VTAlert( cValToChar( nQtdBep ) + "/" + cValToChar( nQuantSA ) ,"Leitura OK",.T.,1000 )
												cCodBar := Space( TamSX3("B1_CODBAR")[01] )
														
												If nQtdBep = nQuantSA

													VTAlert( "Leitura finalizada do endereco.","ITEM OK",.T.,2000 )
												
													dbSelectArea("SCP")
													dbSetOrder(2)//CP_FILIAL+CP_PRODUTO+CP_NUM+CP_ITEM
													If dbSeek( xFilial("SCP") + ( cAliasT )->Z00_PROD + PadR( cNumSA, TamSX3("CP_NUM")[01] ) )

														While SCP->( !Eof() ) .And. AllTrim( ( cAliasT )->Z00_PROD ) == AllTrim( SCP->CP_PRODUTO ) ;
																			  .And. AllTrim( cNumSA ) == AllTrim( SCP->CP_NUM ) ;

															If (( cAliasT )->Z00_QTDSEP + SCP->CP_QUJE) < SCP->CP_QUANT

																Reclock("SCP",.F.)
																	SCP->CP_STACONF := "YY"
																Msunlock()
															
															Else 

																If ( cAliasT )->Z00_QTDSEP = nQtdBep 

																	Reclock("SCP",.F.)
																		SCP->CP_STACONF := "OK"
																	Msunlock()
																
																EndIf 

															EndIf 														
														
															SCP->( dbSkip() )

														EndDo

													EndIf												

													nQtdBep  := 0
													nBepAux  := 0
													nQuantSA := 0
													lCtrl    := .F.
													lPacote  := .F. 

												EndIf 
													
											EndIf 

										EndIf 
								
									EndDo 

								Else 

									If VTYesNo("O item " + AllTrim( SCP->CP_PRODUTO ) + " nao possui endereco." + CRLF + " deseja realizar a baixa da SA?","Sem endereco ",.T.)
										lBaixaSA := .T.							
									Else
										lBaixaSA := .F.
									EndIf 

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

			If Len( aBaixaIT ) > 0
				lBaixaSA := .T.
			EndIf 

			If lBaixaSA
				A140BAIXASA( aBaixaIT )//Funcao para fazer a baixa da SA automaticamente
			EndIf 
			
		EndIf 

	EndDo 
	
Return

/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    |A140NUMSA| Autor | Denis Rodrigues        | Data |28/04/2020|||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao |  Funcao para incluir informacoes no array                  |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | A040NUMSA(cExpC1,ExpC2,cExpC3)                             |||
|||-----------+------------------------------------------------------------|||
||| Parametros| cExp1 - conteudo a ser incluido                            |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function A140NUMSA( cNumSA,cCodProd,cTipo )

	Local cQuery  := ""
	Local cCodBar := ""	
	Local cAliasT := GetNextAlias()
	Local aRet	  := {}
	Local nQtdPac := 0
	Local nQtdSep := 0
	
	cQuery := " SELECT Z00_PROD,"
	cQuery += "        Z00_LOCAL,"
    cQuery += "        Z00_ENDER,"
	cQuery += "        Z00_QTDEND,"
	cQuery += "        Z00_LOTE,"
	cQuery += "        Z00_SALOTE,"
	cQuery += "        Z00_DAVALO,"
	cQuery += "        Z00_QTDSA,"
	cQuery += "        Z00_QTDSEP,"
	cQuery += "        Z00_QTCONF,"
	cQuery += "        Z00_TIPO"
	cQuery += " FROM " + RetSQLName("Z00")
	cQuery += " WHERE Z00_FILIAL = '" + xFilial("Z00") 	+ "'"
	cQuery += "   AND Z00_NUMSA  = '" + cNumSA 		   	+ "'"
	cQuery += "   AND Z00_PROD   = '" + cCodProd  		+ "'"

	If cTipo == "END"

		cQuery += "   AND Z00_QTCONF <= Z00_QTDSEP" //Quant Conferida menor ou igual adicionado para atender a separação e conferência parcial
		cQuery += "   AND Z00_QTDSEP > 0"
		cQuery += "   AND Z00_TIPO   = 'END'"

	Else 

		cQuery += "   AND Z00_TIPO   = 'LOT'"
		cQuery += "   AND Z00_QTDSEP > 0"

	EndIf

	cQuery += "   AND D_E_L_E_T_<>'*'"
	cQuery += " ORDER BY Z00_ENDER"

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	While ( cAliasT )->( !Eof() )

		dbSelectArea("SB1")
		dbSetOrder(1)//B1_FILIAL+B1_COD
		If dbSeek( xFilial("SB1") + ( cAliasT )->Z00_PROD )
			cCodBar := AllTrim( SB1->B1_CODBAR )
		Else 
			cCodBar := "X"
		EndIf 	

		nQtdSep := ( cAliasT )->Z00_QTDSEP

		If ( cAliasT )->Z00_QTCONF <> ( cAliasT )->Z00_QTDEND

			aAdd( aRet,{ ( cAliasT )->Z00_PROD,;    //01 - Cod.Produto
						( cAliasT )->Z00_LOCAL,;    //02 - Local
						( cAliasT )->Z00_ENDER,;    //03 - Endereço
						( cAliasT )->Z00_QTDEND,;   //04 - Qtd. Endereço
						( cAliasT )->Z00_LOTE,;     //05 - Numero Lote
						( cAliasT )->Z00_SALOTE,;   //06 - Saldo Lote
						( cAliasT )->Z00_DAVALO,;   //07 - Data Valid. Lote
						nQtdSep,; 				    //08 - Quant. da SA
						cCodBar,;                   //09 - Codigo de Barras
						nQtdPac,;                   //10 - Quantidade do pacote
						AllTrim( SB1->B1_DESC ) } ) //11 - Descrição do Produto

		Else 

			If AllTrim( ( cAliasT )->Z00_TIPO ) == "LOT"

				aAdd( aRet,{ ( cAliasT )->Z00_PROD,;    //01 - Cod.Produto
							( cAliasT )->Z00_LOCAL,;    //02 - Local
							( cAliasT )->Z00_ENDER,;    //03 - Endereço
							( cAliasT )->Z00_QTDEND,;   //04 - Qtd. Endereço
							( cAliasT )->Z00_LOTE,;     //05 - Numero Lote
							( cAliasT )->Z00_SALOTE,;   //06 - Saldo Lote
							( cAliasT )->Z00_DAVALO,;   //07 - Data Valid. Lote
							nQtdSep,; 				    //08 - Quant. da SA
							cCodBar,;                   //09 - Codigo de Barras
							nQtdPac,;                   //10 - Quantidade do pacote
							AllTrim( SB1->B1_DESC ) } ) //11 - Descrição do Produto

			EndIf 

		EndIf 
	
		( cAliasT )->( dbSkip() )
		
	EndDo
	
	( cAliasT )->( dbCloseArea() )
	
Return( aRet )

/*/{Protheus.doc} A139BAIXASA
	Funcao para fazer a baixa automatica da SA após ser bipada
	@type  Static Function
	@author Denis Rodrigues
	@since 06/10/2020
	@version 1.0
	@param param_name, param_type, param_descr
		  aBaixaIT   , array     , array com os dados da SA para baixar
		  aBaixaIT[1], String    , Numero da SA
		  aBaixaIT[2], String    , Produto
		  aBaixaIT[3], String    , Item
		  aBaixaIT[4], String    , Local
		  aBaixaIT[5], String    , Endereco
		  aBaixaIT[6], String    , Lote
		  aBaixaIT[7], String    , Quant.Bipada
	@return return_var, return_type, return_description
	@example(examples)
	@see (links_or_references)
/*/
Static Function A140BAIXASA( aBaixaIT )

	Local aCmpSCP  := {}
	Local aCmpSD3  := {}
	Local aRelProj := {}	
	Local aMsg     := {}
	Local aAuxItens:= {}
	Local nRecno   := 0
	Local nX       := 0
	Local cCodTM   := "510"
	Local cErrorLog:= ""
	Local cAliasT  := ""
	Local cQuery   := ""
	Local cLoteDest:= ""

	Private lMSHelpAuto    := .F.
    Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .T.
	Private l185Auto := .T.
	Private A185RotAut := .T.

	cAliasT := GetNextAlias()
	cQuery := " SELECT CP_FILIAL,"
	cQuery += "        CP_NUM,"
	cQuery += "        CP_ITEM,"
	cQuery += "        CP_PRODUTO,"
	cQuery += "        CP_QUANT,"
	cQuery += "        CP_QUJE,"
	cQuery += "        CP_LOCAL"
	cQuery += " FROM " + RetSQLName("SCP")
	cQuery += " WHERE CP_FILIAL  = '" + xFilial("SCP")  + "'"
	cQuery += "   AND CP_NUM     = '" + aBaixaIT[1][1] + "'"
	cQuery += "   AND CP_QUANT <> CP_QUJE"
	cQuery += "   AND D_E_L_E_T_ = ''"
	cQuery += " ORDER BY CP_ITEM"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )

	While ( cAliasT )->( !Eof() )

		For nX := 1 To Len( aBaixaIT )

			If AllTrim( aBaixaIT[nX][2] ) == AllTrim( ( cAliasT )->CP_PRODUTO ) .And. aBaixaIT[nX][07] > 0

				If ( ( cAliasT )->CP_QUANT - ( cAliasT )->CP_QUJE ) = aBaixaIT[nX][7]

					aAdd( aAuxItens,{( cAliasT )->CP_FILIAL ,;
										( cAliasT )->CP_NUM,;
										( cAliasT )->CP_ITEM,;
										AllTrim( ( cAliasT )->CP_PRODUTO ),;
										( ( cAliasT )->CP_QUANT - ( cAliasT )->CP_QUJE ),;
										( cAliasT )->CP_LOCAL,;
										aBaixaIT[nX][5],; //07 - Endereco
										aBaixaIT[nX][6] } ) //08 - Lote

				EndIf 

				If ( ( cAliasT )->CP_QUANT - ( cAliasT )->CP_QUJE ) > aBaixaIT[nX][7]

					aAdd( aAuxItens,{( cAliasT )->CP_FILIAL ,;
										( cAliasT )->CP_NUM,;
										( cAliasT )->CP_ITEM,;
										AllTrim( ( cAliasT )->CP_PRODUTO ),;
										aBaixaIT[nX][7],;
										( cAliasT )->CP_LOCAL,;
										aBaixaIT[nX][5],;
										aBaixaIT[nX][6] } )
					
					aBaixaIT[nX][7] := 0

				EndIf 

				If ( ( cAliasT )->CP_QUANT - ( cAliasT )->CP_QUJE ) < aBaixaIT[nX][7]

					aAdd( aAuxItens,{( cAliasT )->CP_FILIAL ,;
									 ( cAliasT )->CP_NUM,;
									 ( cAliasT )->CP_ITEM,;
									 AllTrim( ( cAliasT )->CP_PRODUTO ),;
									 ( cAliasT )->CP_QUANT - Iif( ( cAliasT )->CP_QUJE > 0,( cAliasT )->CP_QUJE,0 ),;
									 ( cAliasT )->CP_LOCAL,;
									 aBaixaIT[nX][5],;
									 aBaixaIT[nX][6] } )
					
					aBaixaIT[nX][7] := aBaixaIT[nX][7] - ( ( cAliasT )->CP_QUANT - Iif( ( cAliasT )->CP_QUJE > 0,( cAliasT )->CP_QUJE,0 ) )

				EndIf 
			
			EndIf 
		
		Next nX 

		( cAliasT )->( dbSkip() )

	EndDo 

	( cAliasT )->( dbCloseArea() ) 

	For nX := 1 To Len( aAuxItens )

		VTClearBuffer()
		VTClear()	
		VTAlert( "Baixando a SA - Item: " + aAuxItens[nX][4],"Baixa SA",.T.,2000 )	

		If !Empty( aAuxItens[nX][8] )
			cLoteDest := PadR( aAuxItens[nX][8],TamSX3("D3_LOTECTL")[01] )
		Else 
			cLoteDest := ""
		EndIf 

		dbSelectArea("SCP")
		dbSetOrder(1)//CP_FILIAL+CP_NUM+CP_ITEM+CP_EMISSAO
		If dbSeek( xFilial("SCP") + PadR( aAuxItens[nX][2],TamSX3("CP_NUM")[01] ) + PadR( aAuxItens[nX][3],TamSX3("CP_ITEM")[01]) )
	
			nRecno := SCP->( Recno() )
	    
			aCmpSCP := { {"CP_FILIAL"  , SCP->CP_FILIAL	  , Nil },;
						 {"CP_NUM" 	   , SCP->CP_NUM 	  , Nil },;
						 {"CP_ITEM"    , SCP->CP_ITEM 	  , Nil },;
						 {"CP_QUANT"   , aAuxItens[nX][5] , Nil },;
						 {"CP_PRODUTO" , SCP->CP_PRODUTO  , Nil },;
						 {"CP_QUJE"    , aAuxItens[nX][5] , Nil },;
						 {"CP_LOCAL"   , SCP->CP_LOCAL    , Nil } } 

			aCmpSD3 := { {"D3_TM" 	   , cCodTM    		 , Nil },;
					 	 {"D3_COD" 	   , SCP->CP_PRODUTO , Nil },;
					 	 {"D3_LOCAL"   , SCP->CP_LOCAL 	 , Nil },;
						 {"D3_NUMSA"   , SCP->CP_NUM 	 , Nil },;
						 {"D3_ITEMSA"  , SCP->CP_ITEM 	 , Nil },;
						 {"D3_DOC" 	   , "" 			 , Nil },;
					 	 {"D3_CUSTO"   , 0  			 , Nil },;
						 {"D3_LOCALIZ" , PadR( "PALLET",TamSX3("D3_LOCALIZ")[01] )		  , Nil },;//aBaixaIT[nX][5]
					 	 {"D3_LOTECTL" , cLoteDest		 , Nil },; 					 	 
					 	 {"D3_EMISSAO" , dDataBase 		 , Nil } } 

			SCP->( dbGoTo(nRecno) )
			lMSHelpAuto := .F.
			lMsErroAuto := .F.			
			lAutoErrNoFile := .T.			
			MSExecAuto({|x,y,z| mata185(x,y,z)},aCmpSCP,aCmpSD3,1,,aRelProj)   // 1 = BAIXA (ROT.AUT)

 			If lMsErroAuto
				
				aMsg := GetAutoGRLog()
				aEval(aMsg,{|x| cErrorLog += x + CRLF })		
				ConOut(cErrorLog)
				VTAlert( "Erro ao baixar item " + aAuxItens[nX][4],"Baixa SA",.T.,2000 )
				VTAlert( cErrorLog,"Erro Baixa SA",.T.,2000 )

			Else

				VTAlert( "Item da SA Baixado com sucesso","Baixa SA",.T.,2000 )
				ConOUt("Item baixado com sucesso.")

			EndIf

    	Else
    		ConOut("Solicitação ao Armazem não encontrada.")
    	EndIf
	
	Next nX 

Return
