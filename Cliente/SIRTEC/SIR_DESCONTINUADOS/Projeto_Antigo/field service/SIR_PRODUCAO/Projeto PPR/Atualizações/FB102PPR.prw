#Include 'Protheus.ch'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FB102PPR ³ Autor ³ Felipe S. Raota             ³ Data ³ 03/05/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Unidade   ³ TRS              ³Contato ³ felipe.raota@totvs.com.br             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Prepara informações para cálculo. Verificação de Indicadores.     ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para cliente Sirtec - Projeto PPR                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³  Data  ³ Manutencao Efetuada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³  /  /  ³                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function FB102PPR(aRet)

Local lCont := .T.

If lCont
	Processa({|| _BuscaInd(@lCont) }, "Aguarde...", "Efetuando Busca de Indicadores.", .T.) 
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _BuscaInd  ³ Autor ³ Felipe S. Raota            ³ Data ³ 11/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Busca inficadores usados no cálculo.                              ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB102PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _BuscaInd(lCont) 

Local aArea := GetArea()
Local aAreaSZD := {}

Local cFiltro := ''

Local nQtdInd  := 0
Local nPremio  := 0
Local nValPrem := 0
Local nQtdMes  := 0

Local nValMeta := 0
Local nValRef  := 0
Local nPrcRng  := 0

Local lRecebe := .F.

Local lErro := .F.

Local cLastM := ''

Private _cLogComp := "" // Complemento de LOG
Private _cRefLog := ""  // Também para complemento de log, mas específico para códigos 

// Limpa registros do cálculo anterior
If !Empty(_cOldCalc)
	TcSQLExec("UPDATE "+RetSqlName("SZE")+" SET D_E_L_E_T_ = '*' WHERE ZE_CODCALC = '"+ _cOldCalc +"'")
Endif

TcSQLExec("UPDATE "+RetSqlName("SZE")+" SET D_E_L_E_T_ = '*' WHERE ZE_CODCALC = '"+ _cCodCalc +"' AND ZE_BLQ <> 'F' ")
TcSQLExec("UPDATE "+RetSqlName("SZQ")+" SET D_E_L_E_T_ = '*' WHERE ZQ_CODCALC = '"+ _cCodCalc +"'")

dbSelectArea("SZE")
SZE->(dbSetOrder(1))

dbSelectArea("SZ5")
SZ5->(dbSetOrder(2))

dbSelectArea("SZG")
SZG->(dbSetOrder(1))

dbSelectArea("SZA")
SZA->(dbSetOrder(1))

dbSelectArea("SZ7")
SZ7->(dbSetOrder(1))

dbSelectArea("SZH")
SZH->(dbSetOrder(1))

dbSelectArea("SZD")
SZD->(dbSetOrder(5)) // Também ordena pela ordem de cálculo dos grupos PPR

dbSelectArea("SZ8")
SZ8->(dbSetOrder(1))

If Select("QTD") <> 0
	QTD->(dbCloseArea())
Endif

cQuery := " SELECT COUNT(*) QUANT " 
cQuery += " FROM "+RetSqlName("SZD")+" SZD "
cQuery += " WHERE " + RetSqlCond("SZD")
cQuery += "   AND SZD.ZD_CODCALC = '"+_cCodCalc+"' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "QTD", .F., .T.)

If QTD->(!EoF())
	ProcRegua(QTD->QUANT)
Endif

QTD->(dbCloseArea())

If SZD->(MsSeek( xFilial("SZD") + _cCodCalc ))
	
	BEGIN TRANSACTION
	
	While !SZD->(EoF()) .AND. xFilial("SZD") + _cCodCalc == SZD->ZD_FILIAL + SZD->ZD_CODCALC
		
		IncProc('Período: ' + SZD->ZD_MESCALC + '/' + Right(SZD->ZD_PERIODO,4) + ' - Matrícula: ' + SZD->ZD_MAT)
		
		If SZD->ZD_BLQ == "F"
			SZD->(dbSkip())
			LOOP
		Endif
		
		//MsgInfo(SZD->ZD_MAT)
		
		If SZD->ZD_MAT == "000294"
			lTeste := .F.
		Endif
		
		If cLastM <> SZD->ZD_MESCALC
			
			cLastM := SZD->ZD_MESCALC
			
			// Limpo tabela de quantidade média de integrantes nas equipes H, essa tabela é gerada no fonte de cálculo dos cadminomponentes
			TcSQLExec("UPDATE "+RetSqlName("SZK")+" SET D_E_L_E_T_ = '*' WHERE ZK_MESANO = '"+SZD->ZD_MESCALC + '/' + Right(SZD->ZD_PERIODO,4)+"'")
			
			// Gera tabela auxiliar utilizada no momento dos cálculos para saber a quantidade média de integrantes em equipes H
			MsAguarde({|| U__MedIntEqp(SZD->ZD_MESCALC + '/' + Right(SZD->ZD_PERIODO,4), SZD->ZD_PERIODO) },'Carregando tabela temporária com Integrantes por Equipe H')
		Endif
		
		If SZD->ZD_OK == "S" .AND. SZD->ZD_DIASTRB >= 15
			
			// Busco os indicadores (SZ5)
			If SZ5->(MsSeek( xFilial("SZ5") + SZD->ZD_CODGRP )) 
				
				While !SZ5->(EoF()) .AND. xFilial("SZ5") + SZD->ZD_CODGRP == SZ5->Z5_FILIAL + SZ5->Z5_CODGRP
					
					lRecebe := .F.
					lErro := .F.
					nQtdInd := 0
					nPremio := 0
					nValPrem := 0
					nQtdMes := 0 
					nValMeta := 0
					nValRef := 0
					nPrcRng := 0
					
					// Deflatores devem ser verificados mesmo se já tiver informação - Incidêcia por Estrutura PPR
					If SZ5->Z5_TIPO <> '-'
					
						// Verifica se já não foi calculado
						If SZE->(MsSeek( xFilial("SZE") + SZD->ZD_CODCALC + SZD->ZD_MAT + SZD->ZD_MESCALC + SZ5->Z5_COD ))
							
							//If SZE->ZE_QTDIND <> 0 .AND. SZE->ZE_OK == 'S'
								SZ5->(dbSkip())
								LOOP 
							//Endif
							
						Endif
					
					Endif
					
					// Verifica Aferição
					If Empty(SZ5->Z5_AFERIC)
						lErro := .T.
						U__GrvLogPPR(SZD->ZD_CODGRP, SZD->ZD_MAT, SZD->ZD_EQUIPE, SZ5->Z5_COD, 'Indicador sem aferição informada.', _cCodCalc, SZD->ZD_MESCALC)
					Endif
					
					If !lErro
					
						If SZ5->Z5_AFERIC <> "M"
							
							// Se for semestral, só recebe no último mês do período
							
							If Left(SZD->ZD_PERIODO,1) == "1"
								cLasM := "06"
							Else
								cLasM := "12"
							Endif
							
							// Se não tiver no último mês, não gravo nada para esse indicador.
							If SZD->ZD_MESCALC <> cLasM
								SZ5->(dbSkip())
								LOOP
							Endif
							
						Endif
					
					Endif
					
					If !lErro
					
						// Busca valores fixos
						nQtdInd := _ValFix(@cFiltro)
						
						// Verifico se tem meta variável
						nValRef := _MetaVaria()
						
						// Se Não tiver valor Fixo, executo função de busca
						If nQtdInd == 0
							
							// Caso não esteja preenchida a função de busca, verificar relacionamento de indicadores (SZH)
							If Empty(SZ5->Z5_CODFUN)
								nQtdInd := _RelacInd()
							Else
								nQtdInd := U__ConvChave(U__ExecFunc(SZ5->Z5_CODFUN), SZ5->Z5_TPDADO)
							Endif
							
						Endif 
						
						If nQtdInd == 0 .AND. SZ5->Z5_TIPO <> "-" // Deflator pode ficar Zerado e mesmo assim não é um erro.
							
							lErro := .T.
							
							_cLogGrv := ""
							
							If !Empty(SZ5->Z5_CODFUN)
								_cMsgFun := fBuscaCpo("SZ8", 1, xFilial("SZ8") + SZ5->Z5_CODFUN, "Z8_MSGLOG")
								
								If !Empty(_cMsgFun)
									_cLogGrv := &(_cMsgFun)
								Endif
								
								U__GrvLogPPR(SZD->ZD_CODGRP, SZD->ZD_MAT, SZD->ZD_EQUIPE, SZ5->Z5_COD, 'Função de busca: ' + SZ5->Z5_CODFUN + '. Retorno = 0. ' + _cLogGrv, _cCodCalc, SZD->ZD_MESCALC)
							Else  
								U__GrvLogPPR(SZD->ZD_CODGRP, SZD->ZD_MAT, SZD->ZD_EQUIPE, SZ5->Z5_COD, 'Relacionamento de indicadores. Retorno = 0. ' + _cLogGrv, _cCodCalc, SZD->ZD_MESCALC)
							Endif
							
							_cRefLog  := "" 
							_cLogComp := ""
						Endif
					
					Endif
					
					If !lErro
						
						// Verifica, se tiver, o valor mínimo para prêmio
						If SZ5->Z5_VALMIN <> 0
							
							// Verifica se tem Indicador Condicional
							If Empty(SZ5->Z5_INDCOND)
								If nQtdInd > SZ5->Z5_VALMIN
									lRecebe := .T.
								Endif
							Else
								
								If Select("IND") <> 0
									IND->(dbCloseArea())
								Endif
								
								// Busca indicador condicional
								cQuery := " SELECT SZE.ZE_QTDIND "
								cQuery += " FROM "+RetSqlName("SZE")+" SZE "
								cQuery += " WHERE " + RetSqlCond("SZE")
								cQuery += "   AND SZE.ZE_MESCALC = '"+SZD->ZD_MESCALC+"' "
								cQuery += "   AND SZE.ZE_CODCALC = '"+SZD->ZD_CODCALC+"' "
								cQuery += "   AND SZE.ZE_CODIND = '"+SZ5->Z5_INDCOND+"' "
								
								cQuery := ChangeQuery(cQuery)
								dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "IND", .F., .T.)
								
								If IND->(!EoF())
									If IND->ZE_QTDIND >= SZ5->Z5_VALMIN
										lRecebe := .T.
									Endif
								Else
									lErro := .T.
									U__GrvLogPPR(SZD->ZD_CODGRP, SZD->ZD_MAT, SZD->ZD_EQUIPE, SZ5->Z5_COD, 'Indicador condicional ainda não foi calculado.', _cCodCalc, SZD->ZD_MESCALC)
								Endif
								
								IND->(dbCloseArea())
								
							Endif
							
						Else
							lRecebe := .T.
						Endif
						
					Endif
					
					// Verifico Valor Base
					If !lErro .AND. lRecebe
						
						If nValRef == 0
							
							If SZ5->Z5_VALBASE <> 0 .OR. SZ5->Z5_TIPO == "-" // Se deflator, Valor de Base = 0
								nValRef := SZ5->Z5_VALBASE
							Else
								lErro := .T.
								
								If Empty(_cLogComp)
									_cLogComp := "Verifique cadastro de Variação de Metas ou Valor Referencial no indicador."
								Endif
								
								U__GrvLogPPR(SZD->ZD_CODGRP, SZD->ZD_MAT, SZD->ZD_EQUIPE, SZ5->Z5_COD, 'Indicador sem Valor Base informado. ' + _cLogComp, _cCodCalc, SZD->ZD_MESCALC)
								_cLogComp := ""
							Endif
							
						Endif
						
					Endif
					
					// Cálculo para Deflatores
					If SZ5->Z5_TIPO == "-"
						
						// Busco percentual de prêmio
						If !lErro .AND. lRecebe
							nPremio := _PercPrem(nQtdInd, nValRef, .T., @nPrcRng)
							
							nValPrem := 0 // Não posso calcular agora pois o deflator incide sobre o total do período
						Endif
						
					Else
						
						// Busco percentual de prêmio
						If !lErro .AND. lRecebe
							nPremio := _PercPrem(nQtdInd, nValRef, .F., @nPrcRng)
						Endif
						
						// Calculo do Valor do Prêmio
						
						// X = 6 se aferição mensal
						// X = 1 se aferição semestral (não altera nada)
						
						// Fórmula: (((Base_Cálculo_Técnico * Base_Calculo_Indicador) / X ) / total_dias_periodo ) * (% Premio / 100) * dias_trabalhados
						
						If SZ5->Z5_AFERIC == "M"
							nQtdMes := 6
						Else
							nQtdMes := 1
						Endif
						
						nValPrem := ( SZD->ZD_BC * SZ5->Z5_BC ) / nQtdMes
						nValPrem := nValPrem / SZD->ZD_TOTDIAS
						nValPrem := nValPrem * ( nPremio / 100) * SZD->ZD_DIASTRB
					
					Endif
					
					If SZ5->Z5_TIPO == "-"
						
						If SZE->(MsSeek( xFilial("SZE") + SZD->ZD_CODCALC + SZD->ZD_MAT + SZD->ZD_MESCALC + SZ5->Z5_COD ))
							
							//Alert("Alterar 1: " + SZD->ZD_MAT + "   " + SZ5->Z5_COD)
							//MsgInfo(nQtdInd)
							
							RecLock("SZE", .F.)
								SZE->ZE_QTDIND  := SZE->ZE_QTDIND + nQtdInd
								SZE->ZE_PREMIO  := nPremio
							MsUnLock() 
						Else
							RecLock("SZE", .T.)
								SZE->ZE_CODCALC := SZD->ZD_CODCALC
								SZE->ZE_MAT     := SZD->ZD_MAT
								SZE->ZE_MESCALC := SZD->ZD_MESCALC
								SZE->ZE_CODIND  := SZ5->Z5_COD
								SZE->ZE_QTDIND  := nQtdInd
								SZE->ZE_PREMIO  := nPremio
								SZE->ZE_VALPREM := 0
								SZE->ZE_OK      := IIF(lErro, "N", "S")
								SZE->ZE_PERMETA := nPrcRng
								SZE->ZE_BLQ     := "A"
							MsUnLock()
						Endif
						
					Else
					
						RecLock("SZE", .T.)
							SZE->ZE_CODCALC := SZD->ZD_CODCALC
							SZE->ZE_MAT     := SZD->ZD_MAT
							SZE->ZE_MESCALC := SZD->ZD_MESCALC
							SZE->ZE_CODIND  := SZ5->Z5_COD
							SZE->ZE_QTDIND  := nQtdInd
							SZE->ZE_PREMIO  := nPremio
							SZE->ZE_VALPREM := nValPrem
							SZE->ZE_OK      := IIF(lErro, "N", "S")
							SZE->ZE_PERMETA := nPrcRng
							SZE->ZE_BLQ     := "A"
						MsUnLock()
					
					Endif
					
					_lDeflat := .F.
					
					cFiltro := ""
					
					// Verifica incidência e gera filtro
					If SZ5->Z5_INCIDEN == 'E'
						cFiltro := " AND SZD.ZD_EQUIPE = '"+SZD->ZD_EQUIPE+"' AND SZD.ZD_PERIODO = '"+SZD->ZD_PERIODO+"' AND SZD.ZD_MESCALC = '"+SZD->ZD_MESCALC+"' "
					ElseIf SZ5->Z5_INCIDEN == 'U'
						cFiltro := " AND SZD.ZD_UNIDADE = '"+SZD->ZD_UNIDADE+"' AND SZD.ZD_PERIODO = '"+SZD->ZD_PERIODO+"' AND SZD.ZD_MESCALC = '"+SZD->ZD_MESCALC+"' "
					ElseIf SZ5->Z5_INCIDEN == 'X'
						
						// Chamo rotina que verifica estrutura PPR e gero novo filtro
						If !Empty(SZD->ZD_CODGRP)
							cFiltro := _IncidEstr(SZD->ZD_CODGRP, SZD->ZD_EQUIPE)
							_lDeflat := .T.
						Else
							cFiltro := ""
						Endif
						
					Endif
					
					// Somente se for incidência de Equipe ou Unidade
					If !Empty(cFiltro)
						
						aAreaSZD := SZD->(GetArea())
						
						//Alert(SZD->ZD_MAT)
						_GrvIncid(cFiltro, nQtdInd, nPremio, SZ5->Z5_COD, _lDeflat, SZ5->Z5_CODGRP, SZD->ZD_MAT, nPrcRng)
						//Alert(SZD->ZD_MAT)
						
						restArea(aAreaSZD)
					Endif
					
					SZ5->(dbSkip())
				Enddo
					
			Endif
		
		Endif
		
		SZD->(dbSkip())
	Enddo	
	
	//************************************************
	// Faz calculo do total de prêmio do funcionário.
	//************************************************
	
	If Select("TOT") <> 0
		TOT->(dbCloseArea())
	Endif
	
	cQuery := " SELECT SZD.ZD_PERIODO, SZD.ZD_FILMAT, SZD.ZD_MAT, SZD.ZD_NOME, SZE.ZE_MESCALC, SZ5.Z5_TIPO, SUM(SZE.ZE_VALPREM) AS ZE_VALPREM "
	cQuery += " FROM "+RetSqlName("SZD")+" SZD INNER JOIN "+RetSqlName("SZE")+" SZE ON SZD.ZD_FILIAL = SZE.ZE_FILIAL "
	cQuery += " 									                                     AND SZD.ZD_CODCALC = SZE.ZE_CODCALC "
	cQuery += " 									                                     AND SZD.ZD_MAT = SZE.ZE_MAT "
	cQuery += " 									                                     AND SZD.ZD_MESCALC = SZE.ZE_MESCALC "
	cQuery += " 				INNER JOIN "+RetSqlName("SZ5")+" SZ5 ON SZD.ZD_FILIAL = SZ5.Z5_FILIAL "
	cQuery += " 								                      AND SZD.ZD_CODGRP = SZ5.Z5_CODGRP "
	cQuery += " 								                      AND SZE.ZE_CODIND = SZ5.Z5_COD "
	cQuery += " WHERE SZD.D_E_L_E_T_ = ' ' "
	cQuery += "   AND SZE.D_E_L_E_T_ = ' ' "
	cQuery += "   AND SZD.ZD_CODCALC = '"+_cCodCalc+"' "
	cQuery += "   AND SZD.ZD_BLQ <> 'F' "
	cQuery += " GROUP BY SZD.ZD_PERIODO, SZD.ZD_FILMAT, SZD.ZD_MAT, SZD.ZD_NOME, SZE.ZE_MESCALC, SZ5.Z5_TIPO "
	cQuery += " ORDER BY SZD.ZD_MAT "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TOT", .F., .T.)
	
	SZD->(dbSetOrder(1))
	
	If !TOT->(EoF())
	
		While !TOT->(EoF())
			
			If SZD->(MsSeek( xFilial("SZD") + _cCodCalc + TOT->ZD_PERIODO + TOT->ZE_MESCALC + TOT->ZD_FILMAT + TOT->ZD_MAT ))
				
				RecLock("SZD", .F.)
					
					If TOT->Z5_TIPO == "+"
						SZD->ZD_TOTPOS := TOT->ZE_VALPREM
					Endif
					
				MsUnlock()
			
			Endif
			
			TOT->(dbSkip())
		Enddo
	
	Endif
	
	//******************************
	// Efetua cálculo de Deflatores
	//******************************

	If Select("_DEF") <> 0
		_DEF->(dbCloseArea())
	Endif
	
	cQuery := " SELECT SZE.ZE_MAT, SZE.ZE_MESCALC, SZE.ZE_PREMIO, SZD.ZD_TOTPOS, SZD.R_E_C_N_O_ AS RECSZD, SZE.R_E_C_N_O_ AS RECSZE "
	cQuery += " FROM "+RetSqlName("SZE")+" SZE INNER JOIN "+RetSqlName("SZD")+" SZD ON SZD.ZD_CODCALC = SZE.ZE_CODCALC AND SZE.ZE_MAT = SZD.ZD_MAT "
	cQuery += " 							   INNER JOIN "+RetSqlName("SZ5")+" SZ5 ON SZ5.Z5_CODGRP = SZD.ZD_CODGRP AND SZ5.Z5_COD = SZE.ZE_CODIND "
	cQuery += " WHERE SZE.ZE_CODCALC = '000001' "
	cQuery += "   AND " + RetSqlCond("SZE")
	cQuery += "   AND " + RetSqlCond("SZD")
	cQuery += "   AND " + RetSqlCond("SZ5")
	cQuery += "   AND SZ5.Z5_TIPO = '-' "
	cQuery += "   AND SZE.ZE_PREMIO > 0 "
	cQuery += "   AND SZD.ZD_BLQ <> 'F' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "_DEF", .F., .T.)
	
	If !_DEF->(EoF())
	
		While !_DEF->(EoF())
			
			SZE->(dbGoTo(_DEF->RECSZE))
			
			If _DEF->RECSZE == SZE->(RecNo()) 
				RecLock("SZE", .F.)
					SZE->ZE_VALPREM := _DEF->ZD_TOTPOS * (_DEF->ZE_PREMIO / 100)
				MsUnLock()
				
				SZD->(dbGoTo(_DEF->RECSZD))
				
				If _DEF->RECSZD == SZD->(RecNo())
					RecLock("SZD", .F.)
						SZD->ZD_TOTNEG += _DEF->ZD_TOTPOS * (_DEF->ZE_PREMIO / 100)
					MsUnLock()
				Endif
				
			Endif
			
			_DEF->(dbSkip())
		Enddo
	
	Endif
	
	//*********************************
	// Efetua o cálculo do valor total
	//*********************************
	
	dbSelectArea("SZD")
	SZD->(dbSetOrder(1))
	SZD->(dbGoTop())
	
	While !SZD->(EoF())
		
		If SZD->ZD_BLQ <> "F"
		
			RecLock("SZD", .F.)
				SZD->ZD_TOTAL := SZD->ZD_TOTPOS - SZD->ZD_TOTNEG
			MsUnLock()
		
		Endif
		
		SZD->(dbSkip())
	Enddo
	
	END TRANSACTION
	
Endif

restArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _MetaVaria ³ Autor ³ Felipe S. Raota            ³ Data ³ 07/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Busca na tabela SZA, se indicador possui metas variáveis.         ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB102PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _MetaVaria()

Local nValRef := 0
Local cFunFil := ''
Local cFunCond := ''

Local cFormEx := ''

Local lPassFil := .T.
Local lPassCond := .F.

If SZA->(MsSeek( xFilial("SZA") + SZD->ZD_CODGRP + SZ5->Z5_COD ))
	
	// Vou executando as validações, até que encontre um que se enquadre.
	
	While SZA->(!EoF()) .AND. xFilial("SZA") + SZD->ZD_CODGRP + SZ5->Z5_COD == SZA->ZA_FILIAL + SZA->ZA_CODGRP + SZA->ZA_CODIND
		
		lPassFil := .T.
		lPassCond := .F.
		
		// 1º Verifico validação de 'filtro'
		If !Empty(SZA->ZA_CODFUN2)
			
			cFunFil := U__ConvChave(U__ExecFunc(SZA->ZA_CODFUN2), SZA->ZA_TPDADO2)
			cFormEx := cFunFil + ' ' + SZA->ZA_OPERFIL + ' ' + SZA->ZA_CHAVFIL // Sempre em Caracter
			
			//Alert(cFormEx)
			
			lPassFil := &(cFormEx)
		Endif
		
		// Se .T. ou executou ou não tinha preenchido o filtro
		If lPassFil 
			
			// 2º Verifico condições 
			cFunCond := U__ConvChave(U__ExecFunc(SZA->ZA_CODFUN), SZA->ZA_TPDADO, .T.) // 3º Parametro da função define se irá retornar no tipo Caracter para concatenação
			cFormEx := cFunCond + ' ' + SZA->ZA_OPER1 + ' ' + SZA->ZA_CHAV1
			
			If !Empty(SZA->ZA_OPER2)
				cFormEx += ' .AND. ' + cFunCond + ' ' + SZA->ZA_OPER2 + ' ' + SZA->ZA_CHAV2
			Endif
			
			lPassCond := &(cFormEx)
		
		Endif
		
		If lPassFil .AND. lPassCond
			nValRef := SZA->ZA_VALREF
			EXIT
		Endif
		
		SZA->(dbSkip())
	Enddo
	
	If lPassFil .AND. !lPassCond
		If !Empty(cFunCond) .AND. Alltrim(cFunCond) <> "''" // As vezes retornou com aspas o.O...vai saber
			_cLogComp := "Resultado da função: " + Alltrim(cFunCond) + " não encontrado na tabela de Variação de Metas."
		Endif
	Endif 	
Endif

Return nValRef

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _ValFix    ³ Autor ³ Felipe S. Raota            ³ Data ³ 08/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Busca na tabela SZG, se o indicador no período existe valor fixo. ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB102PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _ValFix(cFiltro)

Local nValFix := 0

Local cMat    := Space(TamSx3('ZG_MAT')[1])
Local cEquipe := Space(TamSx3('ZG_EQUIPE')[1])
Local cUnid   := Space(TamSx3('ZG_UNIDADE')[1])

Local cMesAno := SZD->ZD_MESCALC + '/' + Right(SZD->ZD_PERIODO,4)

// Efetua a busca pela matrícula do funcionário
If SZG->(MsSeek( xFilial("SZG") + SZD->ZD_CODGRP + SZ5->Z5_COD + cMesAno + cUnid + cEquipe + SZD->ZD_MAT ))
	nValFix := SZG->ZG_VALOR
Endif

If nValFix == 0
	
	// Efetua a busca pela equipe
	If SZG->(MsSeek( xFilial("SZG") + SZD->ZD_CODGRP + SZ5->Z5_COD + cMesAno + cUnid + SZD->ZD_EQUIPE + cMat ))
		nValFix := SZG->ZG_VALOR
	Endif
	
Endif

If nValFix == 0

	// Efetua a busca pela unidade
	If SZG->(MsSeek( xFilial("SZG") + SZD->ZD_CODGRP + SZ5->Z5_COD + cMesAno + SZD->ZD_UNIDADE + cEquipe + cMat ))
		nValFix := SZG->ZG_VALOR
	Endif

Endif

Return nValFix

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _PercPrem  ³ Autor ³ Felipe S. Raota            ³ Data ³ 08/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Busca na tabela SZ7, o percentual de prêmio adquirido.            ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB102PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _PercPrem(nQtdInd, nBase, lDeflat, nPercent)

Local lPassCond := .F.
Local cFunCond := ''
Local cFormEx := ''

Local nPerc := 0
Local nPercPrem := 0

If !lDeflat

	If SZ5->Z5_PERC <> "S"
		nPerc := (nQtdInd * 100) / nBase
	Else
		nPerc := nQtdInd // O que retorna da função já é o percentual
	Endif
	
	nPerc := Round(nPerc, 0)
	nPercent := nPerc
	
Else
	nPerc := nQtdInd
	nPercent := nPerc
Endif

If SZ7->(MsSeek( xFilial("SZ7") + SZD->ZD_CODGRP + SZ5->Z5_COD ))
	
	// Vou executando as validações, até que encontre um que se enquadre.
	
	While SZ7->(!EoF()) .AND. xFilial("SZ7") + SZD->ZD_CODGRP + SZ5->Z5_COD == SZ7->Z7_FILIAL + SZ7->Z7_CODGRP + SZ7->Z7_CODIND
		
		lPassCond := .F.
		
		cFunCond := U__ConvChave(nPerc, "N", .T.)
		cFormEx := cFunCond + ' ' + SZ7->Z7_OPER1 + ' ' + U__ConvChave(SZ7->Z7_VAL1, "N", .T.)
		
		If !Empty(SZ7->Z7_OPER2)
			cFormEx += ' .AND. ' + cFunCond + ' ' + SZ7->Z7_OPER2 + ' ' + U__ConvChave(SZ7->Z7_VAL2, "N", .T.)
		Endif
		
		lPassCond := &(cFormEx)
		
		If lPassCond
			nPercPrem := SZ7->Z7_PREMIO
			EXIT
		Endif
		
		SZ7->(dbSkip())
	Enddo
	
Endif

Return nPercPrem

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GrvIncid  ³ Autor ³ Felipe S. Raota            ³ Data ³ 09/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Grava informações para outros técnicos de acordo com a incidência.³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB102PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GrvIncid(cFiltro, nQtdGrv, nPrem, cCodInd, lDeflat, cCodGrp, cMat, nPrcRng)

Local nQtdM := 0
Local nValP := 0
Local cIndRel := ""

Local lErroGrv := .F.

If Select("TRB") <> 0
	TRB->(dbCloseArea())
Endif

cQuery := " SELECT SZD.* "
cQuery += " FROM "+RetSqlName("SZD")+" SZD WITH (NOLOCK) "
cQuery += " WHERE " + RetSqlCond("SZD") 
cQuery += "   AND SZD.ZD_CODCALC = '"+_cCodCalc+"' "
cQuery += "   AND SZD.ZD_OK = 'S' "
cQuery += "   AND SZD.ZD_CODGRP = '"+cCodGrp+"' "
cQuery += "   AND SZD.ZD_DIASTRB >= 15 "
cQuery += "   AND SZD.ZD_MAT <> '"+cMat+"' "  
cQuery += cFiltro

If !lDeflat
	// Elimina registros já cadastrados, para Deflatores não deve tratar
	cQuery += "   AND SZD.ZD_MAT NOT IN (SELECT SZE.ZE_MAT "
	cQuery += " 						 FROM "+RetSqlName("SZE")+" SZE WITH (NOLOCK) "
	cQuery += " 						 WHERE SZE.ZE_CODCALC = SZD.ZD_CODCALC "
	cQuery += " 						   AND SZE.ZE_MESCALC = SZD.ZD_MESCALC "
	cQuery += " 						   AND SZE.ZE_MAT = SZD.ZD_MAT "
	cQuery += " 						   AND " + RetSqlCond("SZE")
	cQuery += " 						   AND SZE.ZE_CODIND = '"+cCodInd+"') "
Endif

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB", .F., .T.) 

MEMOWRITE("C:\temp\incid.txt", cQuery)

If !TRB->(EoF())
	
	While !TRB->(EoF())
		
		lErroGrv := .F.
		
		If SZ5->Z5_AFERIC == "M"
			nQtdM := 6
		Else
			nQtdM := 1
		Endif
		/*
		cIndRel := _BusIndRel(cCodGrp, cCodInd, TRB->ZD_CODGRP)
		
		If Empty(cIndRel)
			lErroGrv := .T.
			U__GrvLogPPR(TRB->ZD_CODGRP, TRB->ZD_MAT, TRB->ZD_EQUIPE, SZ5->Z5_COD, 'Indicador sem relacionamento (SZH), para gravar incidências.', _cCodCalc, TRB->ZD_MESCALC)
		Endif
		*/
		If !lErroGrv // Somente erro de Indicador Relacionado, nesse caso pode gerar registro.
			
			If lDeflat
				
				If SZE->(MsSeek( xFilial("SZE") + TRB->ZD_CODCALC + TRB->ZD_MAT + TRB->ZD_MESCALC + SZ5->Z5_COD ))
					
					//Alert("Alterar 2: " + TRB->ZD_MAT + "   " + SZ5->Z5_COD)
					//MsgInfo(nQtdGrv)
					
					RecLock("SZE", .F.)
						SZE->ZE_QTDIND  := SZE->ZE_QTDIND + nQtdGrv
						SZE->ZE_PREMIO  := nPrem
						SZE->ZE_PERMETA := nPrcRng
					MsUnLock()
				Else
					RecLock("SZE", .T.)
						SZE->ZE_CODCALC := TRB->ZD_CODCALC
						SZE->ZE_MAT     := TRB->ZD_MAT
						SZE->ZE_MESCALC := TRB->ZD_MESCALC
						SZE->ZE_CODIND  := SZ5->Z5_COD
						SZE->ZE_QTDIND  := nQtdGrv
						SZE->ZE_PREMIO  := nPrem
						SZE->ZE_VALPREM := 0
						SZE->ZE_OK      := IIF(lErroGrv, "N", "S")
						SZE->ZE_PERMETA := nPrcRng
						SZE->ZE_BLQ     := "A"
					MsUnLock()
				Endif
				
			Else
				
				If TRB->ZD_BC == 0
					lErroGrv := .T.
					U__GrvLogPPR(TRB->ZD_CODGRP, TRB->ZD_MAT, TRB->ZD_EQUIPE, SZ5->Z5_COD, 'Técnico com base de cálculo zerada.', _cCodCalc, TRB->ZD_MESCALC)
				Endif
				
				// Calculo do Valor do Prêmio
				
				// X = 6 se aferição mensal
				// X = 1 se aferição semestral (não altera nada)
				
				// Fórmula: (((Base_Cálculo_Técnico * Base_Calculo_Indicador) / X ) / total_dias_periodo ) * (% Premio / 100) * dias_trabalhados
				
				nValP := ( TRB->ZD_BC * SZ5->Z5_BC ) / nQtdM
				nValP := nValP / TRB->ZD_TOTDIAS
				nValP := nValP * ( nPrem / 100) * TRB->ZD_DIASTRB
				
				RecLock("SZE", .T.) 
					SZE->ZE_CODCALC := TRB->ZD_CODCALC
					SZE->ZE_MAT     := TRB->ZD_MAT
					SZE->ZE_MESCALC := TRB->ZD_MESCALC 
					SZE->ZE_CODIND  := SZ5->Z5_COD
					SZE->ZE_QTDIND  := nQtdGrv
					SZE->ZE_PREMIO  := nPrem
					SZE->ZE_VALPREM := nValP
					SZE->ZE_OK      := IIF(lErroGrv, "N", "S")
					SZE->ZE_PERMETA := nPrcRng
					SZE->ZE_BLQ     := "A"
				MsUnLock()
			
			Endif
		
		Endif
		
		TRB->(dbSkip())
	Enddo
	
Endif

TRB->(dbCloseArea())

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _RelacInd  ³ Autor ³ Felipe S. Raota            ³ Data ³ 10/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Busca indicadores relacionados para fazer a média por equipes e   ³±±
±±³          ³ após das equipes.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB102PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _RelacInd()

Local cQuery := ""
Local nValMed := 0

If Select("TRB") <> 0
	TRB->(dbCloseArea())
Endif

cQuery := " SELECT TRB.ZH_CODGRP, TRB.ZH_CODIND, ROUND(SUM(TRB.MEDIA)/ COUNT(*),2) as MEDIA "
cQuery += " FROM "
cQuery += " ( "
cQuery += " 	SELECT SZH.ZH_CODGRP, SZH.ZH_CODIND, SZH.ZH_GRPREL, SZH.ZH_INDREL, SZD.ZD_EQUIPE, SUM(SZE.ZE_PERMETA) / COUNT(*) as MEDIA "
cQuery += " 	FROM "+RetSqlName("SZH")+" SZH INNER JOIN "+RetSqlName("SZD")+" SZD ON SZH.ZH_GRPREL = SZD.ZD_CODGRP "
cQuery += " 								   INNER JOIN "+RetSqlName("SZE")+" SZE ON SZD.ZD_CODCALC = SZE.ZE_CODCALC AND SZD.ZD_MAT = SZE.ZE_MAT AND SZD.ZD_MESCALC = SZE.ZE_MESCALC AND SZH.ZH_INDREL = SZE.ZE_CODIND "
cQuery += " 	WHERE  " + RetSqlCond("SZH")
cQuery += " 	  AND " + RetSqlCond("SZD")
cQuery += " 	  AND SZE.ZE_OK = 'S' "
cQuery += " 	  AND SZD.ZD_OK = 'S' "
cQuery += " 	  AND SZD.ZD_DIASTRB >= 15 "
cQuery += " 	  AND SZH.ZH_CODGRP = '"+SZD->ZD_CODGRP+"' "
cQuery += " 	  AND SZH.ZH_CODIND = '"+SZ5->Z5_COD+"' "
cQuery += " 	  AND SZH.ZH_CONDIC = 'S' "
cQuery += " 	  AND SZD.ZD_CODCALC = '"+SZD->ZD_CODCALC+"' "
cQuery += " 	  AND SZD.ZD_MESCALC = '"+SZD->ZD_MESCALC+"' "
cQuery += " 	  AND Left(SZD.ZD_UNIDADE,6) = '"+Left(SZD->ZD_UNIDADE,6)+"' "
cQuery += " 	GROUP BY SZH.ZH_CODGRP, SZH.ZH_CODIND, SZH.ZH_GRPREL, SZH.ZH_INDREL, SZD.ZD_EQUIPE "
cQuery += " ) TRB "
cQuery += " GROUP BY TRB.ZH_CODGRP, TRB.ZH_CODIND "

MemoWrite("C:\temp\qryRelacInd.txt", cQuery)

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB", .F., .T.)

If TRB->(!EoF())
	nValMed := TRB->MEDIA
Endif

TRB->(dbCloseArea())

Return nValMed

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _IncidEstr ³ Autor ³ Felipe S. Raota            ³ Data ³ 29/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Verifica estrutura PPR e gera filtro completo.                    ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB102PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _IncidEstr(cGrp, cEqp)

Local cQuery := ""
Local cFilter := ""

Local lFirst := .T.

If Select("ESTR") <> 0
	ESTR->(dbCloseArea())
Endif

cQuery := " SELECT DISTINCT SZ9.Z9_COMP "
cQuery += " FROM "+RetSqlName("SZ9")+" SZ9 "
cQuery += " WHERE SZ9.Z9_NIV < (SELECT TOP 1 SZ9AUX.Z9_NIV "
cQuery += "                     FROM "+RetSqlName("SZ9")+" SZ9AUX "
cQuery += "                      WHERE SZ9AUX.D_E_L_E_T_ = ' ' "
cQuery += "                        AND SZ9AUX.Z9_COMP = '"+cGrp+"') "
cQuery += "   AND "+RetSqlCond("SZ9")

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "ESTR", .F., .T.)

If ESTR->(!EoF())
	
	cFilter += " AND ( ( "
	
	While ESTR->(!EoF())
		
		If lFirst
			cFilter += " SZD.ZD_CODGRP = '"+ESTR->Z9_COMP+"' "
		Else
			cFilter += " OR SZD.ZD_CODGRP = '"+ESTR->Z9_COMP+"' "
		Endif
		
		lFirst := .F.
		
		ESTR->(dbSkip())
	Enddo
	
	cFilter += " ) OR ( SZD.ZD_CODGRP = '"+cGrp+"' AND SZD.ZD_EQUIPE = '"+cEqp+"' ) ) "
	
	If !Empty(cFilter)
		cFilter += " AND SZD.ZD_CODGRP <> '      ' AND SZD.ZD_PERIODO = '"+SZD->ZD_PERIODO+"' AND SZD.ZD_MESCALC = '"+SZD->ZD_MESCALC+"' "
	Endif
	
Endif

Return cFilter

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _IncidEstr ³ Autor ³ Felipe S. Raota            ³ Data ³ 29/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Verifica estrutura PPR e gera filtro completo.                    ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB102PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _BusIndRel(cGrp, cInd, cGrpBusca)

Local cCod := ""

If SZH->(MsSeek( xFilial("SZH") + cGrp + cInd + cGrpBusca))
	cCod := SZH->ZH_INDREL
Endif

Return cCod