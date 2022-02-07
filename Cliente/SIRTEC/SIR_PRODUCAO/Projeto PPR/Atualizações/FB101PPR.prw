#Include 'Protheus.ch'

#xTranslate .Mes       => 1
#xTranslate .Ano       => 2
#xTranslate .DtIni     => 3
#xTranslate .DtFim     => 4
#xTranslate .QtdDias   => 5
#xTranslate .PerAberto => 6

#xTranslate ._Periodo   => 1
#xTranslate ._Ano       => 2
#xTranslate ._VerbFalta => 3
#xTranslate ._FuncNao   => 4
#xTranslate ._CodCalc   => 5

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Programa  � FB101PPR � Autor � Felipe S. Raota             � Data � 11/04/13  ���
��������������������������������������������������������������������������������Ĵ��
���Unidade   � TRS              �Contato � felipe.raota@totvs.com.br             ���
��������������������������������������������������������������������������������Ĵ��
���Descricao � Controle de processamento para C�lculo do PPR.                    ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � Especifico para cliente Sirtec - Projeto PPR                      ���
��������������������������������������������������������������������������������Ĵ��
���Analista  �  Data  � Manutencao Efetuada                                      ���
��������������������������������������������������������������������������������Ĵ��
���          �  /  /  �                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

User Function FB101PPR()

Local cCadastro := "C�lculo do PPR"
Local aSays     := {}
Local aButtons  := {}
Local nOpca     := 0

Local aPergs := {}
Local aRet   := {}
Local lRet   := .F.

Local lCont  := .T.
Local lCalc  := .F.

Private _aPer  := {}
Private _cPer  := ''

Private _cCodCalc := ''
Private _cOldCalc := ''
Private _CRLF := Chr(13) + Chr(10)

aADD(aSays, "   Este programa tem como objetivo realizar a busca das informa��es necess�rias   ")
aADD(aSays, "   e efetuar o C�lculo do PPR para os funcion�rios.                               ")
aADD(aSays, "                                                                                  ")

aADD(aButtons, {1, .T., {|| (nOpca := 1, FechaBatch()) }})
aADD(aButtons, {2, .T., {|| (nOpca := 2, FechaBatch()) }})

FormBatch(cCadastro, aSays, aButtons)

If nOpca == 1
	
	aADD(aPergs, {3, "Per�odo",1, {"1� Semestre", "2� Semestre"}, 50,'.T.',.T.})
	aADD(aPergs, {1, "Ano", "2014" /*Space(4)*/, "@! 9999", 'U__ValidPer(MV_PAR01, MV_PAR02)','', '.T.',40,.T.})
	aADD(aPergs, {1, "Verbas de Falta", "112418" /*Space(250)*/, "@! ", 'U__fVerbFal()','', '.T.',111,.T.})
	aADD(aPergs, {1, "Fun��es n�o calc. PPR ", "0001900026000270003800049" /*Space(250)*/, "@! ", 'U__fFuncNao()','', '.T.',111,.T.})
	//aADD(aPergs, {1, "Processar calculo?    ", Space(6), "@! ", '','', '.T.',111,.F.})
	
	If ParamBox(aPergs, "C�lculo PPR", aRet)
		
		_cCodCalc := "" //Alltrim(aRet[._CodCalc])
		_cPer := Alltrim(Str(aRet[._Periodo])) + '/' + aRet[._Ano] // Semestre + Ano
		
		dbSelectArea('SZD')
		SZD->(dbSetOrder(4)) 
		
		If SZD->(MsSeek( xFilial('SZD') + _cPer ))
			
			If !MsgYesNo('Per�odo j� calculado. Deseja refazer a busca dos funcion�rios para os per�odos em aberto?')
			
				If MsgYesNo('Deseja reprocessar somente os indicadores?')
					lCalc := .T.
					_cCodCalc := SZD->ZD_CODCALC
				Else
					//_cOldCalc := SZD->ZD_CODCALC
					Return
				Endif
			
			Else
				_cCodCalc := SZD->ZD_CODCALC
				lCalc := .F.
			Endif
			
		Endif
		
		If !lCalc 
		
			If lCont 
				Processa({|| _ProcCalc(aRet, @lCont, _cCodCalc) }, "Aguarde...", "Efetuando Busca de Funcion�rios.", .T.)
			Endif
			
			If lCont
				Processa({|| _BuscaEqp(aRet, @lCont) }, "Aguarde...", "Efetuando Busca da Forma��o de Equipes.", .T.)
			Endif
			If lCont
				Processa({|| _GrupoPPR(aRet, @lCont) }, "Aguarde...", "Buscando Grupo PPR.", .T.)
			Endif
			
		Endif
		
		If lCont
			Processa({|| _VerifDados(aRet, @lCont) }, "Aguarde...", "Verificando Informa��es Encontradas.", .T.)
		Endif
		
		If lCont
			U_FB102PPR(aRet)
		Endif
		
	EndIf
	
Endif

Return

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � _ProcCalc  � Autor � Felipe S. Raota            � Data � 11/04/13 ��� 
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Continua processamento do c�lculo.                                ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � FB101PPR                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

Static Function _ProcCalc(aRet, lCont, cCodC)

Local aArea    := GetArea()
Local nQtdIni  := IIF( aRet[._Periodo]==1, 1, 7 )
Local nQtdFim  := aRet[._Periodo] * 6
Local dDtIni   := CtoD('')
Local dDtFim   := CtoD('')
Local dDtPerAb := StoD(Alltrim(GetMV('MV_FOLMES')) + '01')

Local lPerAb    := .F.
Local cQuery    := ''
Local cVerbFalt := ''
Local cFuncNao  := ''
Local nQtdFalt  := 0
Local nQtdAfast := 0
Local lTrabPer  := .T.

Local nQtdReg := 0

Local sPerAntFim := ''

Local sPIni   := ''
Local sPFim   := ''

Local nDiasNeg := 0

// Ajusta par�metros de sele��o da rotina
If !Empty(aRet[._VerbFalta])
	cVerbFalt := U__AjustSel(aRet[._VerbFalta], 3)
Endif

If !Empty(aRet[._VerbFalta])
	cFuncNao := U__AjustSel(aRet[._FuncNao], 5)
Endif

// Gero matriz com os per�odos
For _x:=nQtdIni to nQtdFim
	
	dDtIni := CtoD( '01/' + StrZero(_x,2) + '/' + aRet[._Ano] )
	dDtFim := LastDay(dDtIni, 2)
	
	If dDtIni < dDtPerAb
		lPerAb := .F.
	Else
		lPerAb := .T.
	Endif
	
	// Testo se considero o per�odo no c�lculo
	//If dDataBase < CtoD("15" + "/" + StrZero(_x, 2) + "/" + aRet[._Ano])
	If dDataBase < dDtFim // Devo considerar somente final do mes e n�o do per�odo por quest�es de faturamento..
		_nQtdDiasT := 0
	Else
		_nQtdDiasT := (dDtFim - dDtIni) + 1
	Endif
	
	aADD(_aPer, {StrZero(_x, 2),; 
                aRet[._Ano],;
                dDtIni,; 
				dDtFim,; 
				_nQtdDiasT,; // Quantidade de Dias do Per�odo
				lPerAb}) // Indica se per�odo est� aberto(.T.) ou Fechado(.F.)
Next

/*
// Verifico novamente se j� n�o foi calculado o per�odo em quest�o
dbSelectArea('SZD')
SZD->(dbSetOrder(4))

If SZD->(MsSeek( xFilial('SZD') + _cPer ))
	TcSQLExec("UPDATE "+RetSqlName("SZD")+" SET D_E_L_E_T_ = '*' WHERE ZD_CODCALC = '"+ SZD->ZD_CODCALC +"' AND ZD_BLQ <> 'S' ") // Limpa registros do c�lculo anterior
Endif
*/

// Se tiver o c�digo do c�lculo, quer dizer que estou reprocessando o per�odo.
// Limpa os registros do c�lculo anterior, somente para os que estiverem em aberto
If !Empty(cCodC)
	TcSQLExec("UPDATE "+RetSqlName("SZD")+" SET D_E_L_E_T_ = '*' WHERE ZD_CODCALC = '"+ cCodC +"' AND ZD_BLQ <> 'F' ")
Endif

If Select("TRB") <> 0
	TRB->(dbCloseArea())
Endif

// Busca Funcion�rios SRA
cQuery := " SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_CC, CTT.CTT_CCSUP, CTTSUP.CTT_DESC01, SZ4.Z4_ORDEM "
cQuery += " FROM "+RetSqlName("SRA")+" SRA INNER JOIN "+RetSqlName("CTT")+" CTT ON SRA.RA_FILIAL = CTT.CTT_FILIAL AND SRA.RA_CC = CTT.CTT_CUSTO "
cQuery += " 				 INNER JOIN "+RetSqlName("CTT")+" CTTSUP ON CTT.CTT_FILIAL = CTTSUP.CTT_FILIAL AND CTT.CTT_CCSUP = CTTSUP.CTT_CUSTO "
cQuery += " 				 INNER JOIN "+RetSqlName("SZ4")+" SZ4 ON SZ4.Z4_COD = SRA.RA_SGRPPR "
cQuery += " WHERE (SRA.RA_DEMISSA > '"+DtoS(_aPer[len(_aPer),.DtFim])+"' OR SRA.RA_DEMISSA = '        ') " // Final do per�odo de aferi��o, ultima posi��o do vetor.
cQuery += "   AND SRA.RA_CATFUNC = 'M' " // Somente mensalistas, estagi�rios e aprendizes n�o fazem parte do PPR.
cQuery += "   AND SRA.D_E_L_E_T_ = ' ' "
cQuery += "   AND CTT.D_E_L_E_T_ = ' ' "
cQuery += "   AND SZ4.Z4_CONS = 'S' "
cQuery += " ORDER BY SRA.RA_FILIAL, SRA.RA_MAT "  

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB", .F., .T.) 

MEMOWRITE("C:\temp\qry_SRA_INI.txt", cQuery)

COUNT TO nQtdReg
nQtdReg := nQtdReg * len(_aPer)
ProcRegua(nQtdReg)

TRB->(dbGoTop())

If TRB->(!EoF())
	
	BEGIN TRANSACTION
		
		If Empty(cCodC)
			_cCodCalc := U__CodCalc()
		Else
			_cCodCalc := cCodC
		Endif
		
		//*----------------------------------------------------
		// Armazena informa��es iniciais na tabela de c�lculo |
		//*----------------------------------------------------
		
		For _x:=1 to len(_aPer)
			
			// Se ainda n�o estou no M�s posicionado
			If _aPer[_x, .QtdDias] == 0
				TRB->(dbGoTop())
				LOOP
			Endif
			
			While !TRB->(EoF())
				
				IncProc("Per�odo: " + _aPer[_x, .Mes] + '/' + _aPer[_x, .Ano] + ' - Matr�cula: ' + TRB->RA_MAT)
				
				// Verifica se a matr�cula j� n�o est� fechada no per�odo
				SZD->(dbSetOrder(1))
				//Alert(xFilial("SZD") + _cPer + _aPer[_x, .Mes] + TRB->RA_FILIAL + TRB->RA_MAT)
				If SZD->(MsSeek( xFilial("SZD") + _cCodCalc + _cPer + _aPer[_x, .Mes] + TRB->RA_FILIAL + TRB->RA_MAT ))
					
					If SZD->ZD_BLQ == "F"
						TRB->(dbSkip())
						LOOP
					Endif
					
				Endif
				
				// Verificar se nesse per�odo, estava em uma fun��o que n�o deve fazer parte do c�lculo.
				If !Empty(aRet[._FuncNao])
					
					sPFim := Alltrim(Str(Year(_aPer[_x,.DtIni]))) + StrZero(Month(_aPer[_x,.DtIni]), 2) + '15'
					
					If Select("FUN") <> 0
						FUN->(dbCloseArea())
					Endif
					
					cQuery := " SELECT TOP 1 SR7.R7_FUNCAO "
					cQuery += " FROM "+RetSqlName("SR7")+" SR7 "
					cQuery += " WHERE " + RetSqlCond("SR7")
					cQuery += "   AND SR7.R7_MAT = '"+TRB->RA_MAT+"'" 
					cQuery += "   AND SR7.R7_DATA <= '"+sPFim+"' "
					cQuery += " ORDER BY SR7.R7_DATA DESC "
					
					dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "FUN", .F., .T.)
					
					If FUN->(!EoF())
						
						// Se n�o deve utilizar no C�lculo PPR
						If FUN->R7_FUNCAO $ cFuncNao
							TRB->(dbSkip())
							LOOP 
						Endif
						
					Endif
					
					FUN->(dbCloseArea())
					
				Endif
				
				//*----------------------------------------------------------
				// Verifica quantidade total de dias trabalhados no per�odo |
				//*----------------------------------------------------------
				
				// ** FALTAS **
				nQtdFalt := _DiasFalta(cVerbFalt)
				
				// ** AFASTAMENTOS **
				nQtdAfast := _DiasAfast()
				
				nDiasNeg := nQtdFalt + nQtdAfast
				
				If nDiasNeg > _aPer[_x, .QtdDias]
					nDiasNeg := _aPer[_x, .QtdDias]
				Endif
				
				RecLock('SZD', .T.)
					SZD->ZD_FILIAL  := xFilial("SZD")
					SZD->ZD_CODCALC := _cCodCalc
					SZD->ZD_FILMAT  := TRB->RA_FILIAL
					SZD->ZD_MAT     := TRB->RA_MAT
					SZD->ZD_UNIDADE := TRB->RA_CC
					SZD->ZD_NOME    := TRB->RA_NOME
					SZD->ZD_PERIODO := _cPer
					SZD->ZD_MESCALC := _aPer[_x, .Mes]
					SZD->ZD_ANOCALC := _aPer[_x, .Ano]
					SZD->ZD_TOTDIAS := _aPer[_x, .QtdDias]
					SZD->ZD_FALTAS  := IIF(_aPer[_x, .QtdDias] <> 0, nDiasNeg, 0)
					SZD->ZD_DIASTRB := IIF(_aPer[_x, .QtdDias] <> 0,(_aPer[_x, .QtdDias] - nDiasNeg), 0)
					SZD->ZD_BLQ     := "A"
				MsUnLock()
				
				TRB->(dbSkip())
			Enddo
			
			TRB->(dbGoTop())
			
		Next _x
		
	END TRANSACTION
	
Endif

TRB->(dbCloseArea())
restArea(aArea)

Return

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � _BuscaEqp  � Autor � Felipe S. Raota            � Data � 18/04/13 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Efetua a busca da equipe em que o funcion�rio mais trabalhou.     ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � FB101PPR                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

Static Function _BuscaEqp(aRet, lCont)

Local sPIni   := ''
Local sPFim   := ''
Local cQuery  := ''
Local nQtdReg := 0

Local cCodFunc  := ''
Local cCodEnc   := ''
Local lEncarre  := .F.
Local nBaseCalc := 0

SZD->(dbSetOrder(1)) 

For _x:=1 to len(_aPer)
	
	// Se ainda n�o estou no M�s posicionado
	If _aPer[_x, .QtdDias] == 0
		LOOP
	Endif
	
	sPIni := MonthSub(_aPer[_x,.DtIni],1)
	sPIni := Alltrim(Str(Year(sPIni))) + StrZero(Month(sPIni), 2) + '16'
	
	sPFim := Alltrim(Str(Year(_aPer[_x,.DtIni]))) + StrZero(Month(_aPer[_x,.DtIni]), 2) + '15'
	
	cQuery := U__QryEquipe(sPIni, sPFim, DtoS(_aPer[_x, .DtIni]), DtoS(_aPer[_x, .DtFim]), _cCodCalc, _cPer)
	
	MemoWrite("C:\temp\qryppr.txt", cQuery)
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB", .F., .T.)
	
	TcSetField("TRB","ZB_DTINI","D",8,0)
	TcSetField("TRB","ZB_DTFIM","D",8,0)
	
	If !TRB->(EoF())
		
		COUNT TO nQtdReg
		nQtdReg := nQtdReg
		ProcRegua(nQtdReg)
		
		TRB->(dbGoTop()) 
		
		BEGIN TRANSACTION
		
			While !TRB->(EoF())
			
				IncProc("Per�odo: " + _aPer[_x, .Mes] + '/' + _aPer[_x, .Ano] + ' - Matr�cula: ' + TRB->ZD_MAT)
				
				lEncarre  := .F.
				
				If SZD->(MsSeek( xFilial("SZD") + _cCodCalc + _cPer + SubStr(sPFim,5,2) + TRB->ZD_FILMAT + TRB->ZD_MAT ))
					
					// Pula registros j� fechados
					If SZD->ZD_BLQ == "F"
						TRB->(dbSkip())
						LOOP
					Endif
					
					// J� trata a excess�o na query.
					cCodFunc := TRB->FUNCAO
					
					If TRB->TIPO == 1
					
						// Verifico se devo tratar o funcion�rio como um encarregado, no per�odo
						
						// Busco a fun��o designada para um encarregado.
						cCodEnc := U__BuscaEnc()
						
						If !Empty(cCodEnc) .AND. cCodEnc == cCodFunc
							lEncarre := .T.
						Else 
						
							If TRB->DIAS_ENCARR >= TRB->DIAS_PPR
								
								lEncarre := .T.
								
								If !Empty(cCodEnc)
									cCodFunc := cCodEnc
								Else
									cCodFunc := '' // Deixo em branco para saber que n�o encontrou a fun��o de encarregado.
								Endif
								
							Endif
							
						Endif
					
					Else
						// Gravo no LOG que essa matr�cula estava de f�rias no per�odo
					Endif
					
					If lEncarre
						nBaseCalc := U__BuscaBase(cCodEnc, .F.)
					Else
						nBaseCalc := U__BuscaBase(cCodFunc, .F.)
					Endif
					
					// Para n�o afetar a busca anterior
					// Tive que tratar a vari�vel pois quando tem exce��o de fun��o, n�o estava marcando o campo... 
					If Alltrim(cCodEnc) == Alltrim(cCodFunc)
						lEncarre := .T.
					Endif
					
					RecLock("SZD", .F.)
						SZD->ZD_EQUIPE  := TRB->EQUIPE
						SZD->ZD_FUNCBC  := cCodFunc
						SZD->ZD_UNIDADE := TRB->UNIDADE
						SZD->ZD_ENCARRE := IIF(lEncarre, 'S', ' ')
						SZD->ZD_BC      := nBaseCalc
					MsUnLock()
					
				Endif
				
				TRB->(dbSkip())
			Enddo
		
		END TRANSACTION
		
	Endif
	
	TRB->(dbCloseArea())
	
Next

Return

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � _GrupoPPR  � Autor � Felipe S. Raota            � Data � 26/04/13 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Efetua a busca do Grupo PPR para cada funcion�rio.                ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � FB101PPR                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

Static Function _GrupoPPR(aRet, lCont)

Local cMes := ''

Local lTrabPer := .T.
Local sPerAntFim := ''

Local sPIni := ''
Local sPFim := ''

Local nQtdBC := 0

dbSelectArea("SZ4")
SZ4->(dbSetOrder(1))

SZD->(dbSetOrder(1))

For _x:=1 to len(_aPer)
	
	// Se ainda n�o estou no M�s posicionado
	If _aPer[_x, .QtdDias] == 0
		LOOP
	Endif
	
	cMes := StrZero(Month(_aPer[_x, .DtIni]),2)
	
	sPIni := MonthSub(_aPer[_x,.DtIni],1)
	sPIni := Alltrim(Str(Year(sPIni))) + StrZero(Month(sPIni), 2) + '16' 
	
	sPFim := Alltrim(Str(Year(_aPer[_x,.DtIni]))) + StrZero(Month(_aPer[_x,.DtIni]), 2) + '15'
	
	cQuery := " SELECT TAB.*, SZ4.Z4_DESC " + _CRLF
	cQuery += " FROM " + _CRLF
	cQuery += " ( " + _CRLF
	cQuery += " 	SELECT SZD.ZD_FILMAT, SZD.ZD_MAT, " + _CRLF 
	cQuery += "         ISNULL( " + _CRLF	
	cQuery += "         	( " + _CRLF
	cQuery += "			 		SELECT TOP 1 SZI.ZI_GRPNEW " + _CRLF 
	cQuery += "			 		FROM "+RetSqlName("SZI")+" SZI " + _CRLF
	cQuery += "			 		WHERE SZI.D_E_L_E_T_ = ' ' " + _CRLF
	cQuery += "	 		   		  AND SZI.ZI_MAT = SZD.ZD_MAT " + _CRLF 
	//cQuery += "			      AND SZI.ZI_DTINI BETWEEN '"+sPIni+"' AND '"+sPFim+"' " + _CRLF
	//cQuery += "	 		   	  AND (SZI.ZI_DTFIM <= '"+sPFim+"' OR SZI.ZI_DTFIM = '        ') " + _CRLF
	cQuery += "					  AND SZI.ZI_DTINI <= '"+sPIni+"' " + _CRLF
	cQuery += "	 		   		  AND (SZI.ZI_DTFIM >= '"+sPFim+"' OR SZI.ZI_DTFIM = '        ') " + _CRLF
	cQuery += "				), " + _CRLF
	cQuery += " 			ISNULL(( " + _CRLF 
	cQuery += " 				SELECT TOP 1 TAB.ZZ5_CODGRP " + _CRLF
	cQuery += " 				FROM ( " + _CRLF
	cQuery += " 					SELECT ZZ5.ZZ5_FILIAL, ZZ5.ZZ5_EQUIPE, ZZ5.ZZ5_CODGRP, COUNT(*) as QTD_DIAS " + _CRLF 
	cQuery += " 					FROM "+RetSqlName("ZZ5")+" ZZ5 " + _CRLF
	cQuery += " 					WHERE ZZ5.ZZ5_CODTEC = SZD.ZD_MAT " + _CRLF
	cQuery += " 				      AND ZZ5.D_E_L_E_T_ = ' ' " + _CRLF
	cQuery += " 				      AND ZZ5.ZZ5_FILIAL = '"+xFilial("ZZ5")+"' " + _CRLF
	cQuery += " 				      AND ZZ5.ZZ5_DTCHEG <> '' " + _CRLF
	cQuery += " 				      AND ZZ5.ZZ5_DTCHEG BETWEEN '"+sPIni+"' AND '"+sPFim+"' " + _CRLF // Coloquei para n�o ter problema de buscar ap�s uma mudan�a de GRUPO PPR
	cQuery += " 					GROUP BY ZZ5.ZZ5_FILIAL, ZZ5.ZZ5_EQUIPE, ZZ5.ZZ5_CODGRP " + _CRLF 
	cQuery += " 				) TAB " + _CRLF
	cQuery += " 				ORDER BY TAB.QTD_DIAS DESC " + _CRLF
	cQuery += " 			), " + _CRLF
	cQuery += " 			( " + _CRLF
	cQuery += " 		 	SELECT SRA.RA_SGRPPR " + _CRLF
	cQuery += " 		 	FROM "+RetSqlName("SRA")+" SRA " + _CRLF
	cQuery += " 		 	WHERE SRA.D_E_L_E_T_ = ' ' " + _CRLF
	cQuery += " 		   	  AND SRA.RA_MAT = SZD.ZD_MAT " + _CRLF
	cQuery += " 			)) " + _CRLF
	cQuery += "         ) as ZZ4_GRPPR " + _CRLF
	cQuery += " 	FROM "+RetSqlName("SZD")+" SZD " + _CRLF
	cQuery += " 	WHERE SZD.D_E_L_E_T_ = ' ' " + _CRLF
	cQuery += " 		  AND SZD.ZD_CODCALC = '"+_cCodCalc+"' " + _CRLF
	cQuery += " 		  AND SZD.ZD_MESCALC = '"+cMes+"' " + _CRLF
	//cQuery += " 		  AND SZD.ZD_DIASTRB >= 15 " // Devo Buscar o Grupo independente da quantidade de dias trabalhados + _CRLF
	cQuery += " ) TAB LEFT JOIN "+RetSqlName("SZ4")+" SZ4 ON TAB.ZZ4_GRPPR = SZ4.Z4_COD AND SZ4.D_E_L_E_T_ =  ' ' " + _CRLF
	
	MemoWrite("C:\temp\qryGrupoPPR.txt", cQuery)
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB", .F., .T.)
	
	If !TRB->(EoF())
		
		COUNT TO nQtdReg  
		nQtdReg := nQtdReg
		ProcRegua(nQtdReg)
		
		TRB->(dbGoTop())
		
		BEGIN TRANSACTION 
		
			While !TRB->(EoF())
				
				lTrabPer := .T.
				nQtdBC := 0
				
				IncProc("Per�odo: " + _aPer[_x, .Mes] + '/' + _aPer[_x, .Ano] + ' - Matr�cula: ' + TRB->ZD_MAT)
				
				If SZD->(MsSeek( xFilial("SZD") + _cCodCalc + _cPer + cMes + TRB->ZD_FILMAT + TRB->ZD_MAT ))
					
					If SZD->ZD_BLQ == "F"
						SZD->(dbSkip())
						LOOP
					Endif
					
					If SZ4->(MsSeek( xFilial("SZ4") + TRB->ZZ4_GRPPR ))
						
						If SZ4->Z4_EQUIPE == 'S'
							
							// ** DIAS REALMENTE TRABALHADOS **
							
							// Verifico se existe algum apontamento de OS no final do per�odo anterior. Somente para quem participa de alguma equipe.
							// Pois se ele ficar de f�rias, posso utilizar o per�odo passado para analise.
							// Somente testo se existe apontamento. Se n�o existir, Dias Trabalhados = 0
							
							sPerAntFim := MonthSub(_aPer[_x,.DtIni],1)
							sPerAntFim := Alltrim(Str(Year(sPerAntFim))) + StrZero(Month(sPerAntFim), 2) + '15'
							
							If SZD->ZD_DIASTRB == 0
								lTrabPer := _TrabPer(sPerAntFim)
							Else
								lTrabPer := .T.
							Endif
							
						Endif
						
					Endif
					
					If !Empty(TRB->ZZ4_GRPPR)
						nQtdBC := U__BuscaBase('', Alltrim(TRB->ZZ4_GRPPR), .T.)
					Endif
					
					RecLock("SZD", .F.)
						SZD->ZD_CODGRP  := TRB->ZZ4_GRPPR
						SZD->ZD_ORDEM   := fBuscaCpo("SZ4", 1, xFilial("SZ4") + TRB->ZZ4_GRPPR, "Z4_ORDEM" )
						SZD->ZD_DESCGRP := TRB->Z4_DESC
						
						If !lTrabPer
							SZD->ZD_DIASTRB := 0
						Endif
						If nQtdBC <> 0
							SZD->ZD_BC := SZD->ZD_BC * nQtdBC
						Endif
						
					MsUnLock()
					
				Endif
				
				TRB->(dbSkip())
			Enddo
		
		END TRANSACTION
		
	Endif
	
	TRB->(dbCloseArea())
	
Next

Return

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � _VerifDados� Autor � Felipe S. Raota            � Data � 02/05/13 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Valida informa��es encontradas.                                   ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � FB101PPR                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

Static Function _VerifDados(aRet, lCont)

Local lOk := .T.

dbSelectArea("SZD")
SZD->(dbSetOrder(1))

dbSelectArea("SZ4")
SZ4->(dbSetOrder(1))

If Select("QTD") <> 0
	QTD->(dbCloseArea())
Endif

cQuery := " SELECT COUNT(*) QUANT "
cQuery += " FROM "+RetSqlName("SZD")+" SZD "
cQuery += " WHERE " + RetSqlCond("SZD")
cQuery += "   AND SZD.ZD_CODCALC = '"+_cCodCalc+"' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "QTD", .F., .T.)

If !QTD->(EoF())
	ProcRegua(QTD->QUANT)
Endif

QTD->(dbCloseArea())

If SZD->(MsSeek(xFilial("SZD") + _cCodCalc))
	
	While !SZD->(EoF())
		
		IncProc('Per�odo: ' + SZD->ZD_MESCALC + '/' + Right(SZD->ZD_PERIODO,4) + ' - Matr�cula: ' + SZD->ZD_MAT)
		
		If SZD->ZD_BLQ == "F"
			SZD->(dbSkip())
			LOOP
		Endif
		
		lOk := .T.
		
		If SZD->ZD_DIASTRB >= 15
		
			If lOk .AND. Empty(SZD->ZD_CODGRP)
				lOk := .F.
				U__GrvLogPPR(SZD->ZD_CODGRP, SZD->ZD_MAT, SZD->ZD_EQUIPE, '      ', 'Grupo PPR em branco.', _cCodCalc, SZD->ZD_MESCALC) 
			Endif
			
			If lOk .AND. Empty(SZD->ZD_FUNCBC)
				lOk := .F.
				U__GrvLogPPR(SZD->ZD_CODGRP, SZD->ZD_MAT, SZD->ZD_EQUIPE, '      ', 'C�digo de Fun��o em branco.', _cCodCalc, SZD->ZD_MESCALC)
			Endif
			
			If lOk .AND. Empty(SZD->ZD_BC) 
				lOk := .F.
				U__GrvLogPPR(SZD->ZD_CODGRP, SZD->ZD_MAT, SZD->ZD_EQUIPE, '      ', 'Base de C�lculo zerada.', _cCodCalc, SZD->ZD_MESCALC)
			Endif
			
			If lOk
				If SZ4->(MsSeek( xFilial("SZ4") + SZD->ZD_CODGRP ))
					If SZ4->Z4_EQUIPE == "S"
						If Empty(SZD->ZD_EQUIPE)
							lOk := .F.
							U__GrvLogPPR(SZD->ZD_CODGRP, SZD->ZD_MAT, SZD->ZD_EQUIPE, '      ', 'Grupo PPR exige preenchimento da Equipe.', _cCodCalc, SZD->ZD_MESCALC)
						Endif
					Endif
				Endif
			Endif
		
		Else
			lOk := .T.
			U__GrvLogPPR(SZD->ZD_CODGRP, SZD->ZD_MAT, SZD->ZD_EQUIPE, '      ', 'T�cnico n�o trabalhou no per�odo: ' + SZD->ZD_MESCALC + '/' + Right(SZD->ZD_PERIODO,4), _cCodCalc, SZD->ZD_MESCALC)
		Endif
		
		RecLock("SZD", .F.)
			SZD->ZD_OK := IIF(lOk, 'S', 'N')
			SZD->ZD_TOTPOS := 0
			SZD->ZD_TOTNEG := 0
			SZD->ZD_TOTAL := 0
			SZD->ZD_BLQ := "A"
		MsUnLock()
		
		SZD->(dbSkip())
	Enddo
	
Endif

Return

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � _DiasFalta � Autor � Felipe S. Raota            � Data � 15/04/13 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula dias que devem abater do total trabalhado.                ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � FB101PPR                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

Static Function _DiasFalta(cVerbFalt)

Local nRet := 0

If Select("FALT") <> 0
	FALT->(dbCloseArea())
Endif

If _aPer[_x, .PerAberto]
	cQuery := " SELECT ISNULL(SUM(SRC.RC_HORAS),0) as DIAS_FALT "
	cQuery += " FROM "+RetSqlName("SRC")+" SRC "
	cQuery += " WHERE SRC.RC_FILIAL = '"+TRB->RA_FILIAL+"' "
	cQuery += "   AND SRC.D_E_L_E_T_ = ' ' "
	cQuery += "   AND SRC.RC_MAT = '"+TRB->RA_MAT+"' "
	cQuery += "   AND SRC.RC_TIPO1 = 'D' "
	cQuery += "   AND SRC.RC_PD IN " + cVerbFalt
Else
	cQuery := " SELECT ISNULL(SUM(SRD.RD_HORAS),0) as DIAS_FALT "
	cQuery += " FROM "+RetSqlName("SRD")+" SRD "
	cQuery += " WHERE SRD.RD_FILIAL = '"+TRB->RA_FILIAL+"' "
	cQuery += "   AND SRD.D_E_L_E_T_ = ' ' "
	cQuery += "   AND SRD.RD_MAT = '"+TRB->RA_MAT+"' "
	cQuery += "   AND SRD.RD_TIPO1 = 'D' "
	cQuery += "   AND SRD.RD_DATARQ = '"+_aPer[_x, .Ano] + _aPer[_x, .Mes]+"' "  
	cQuery += "   AND SRD.RD_PD IN " + cVerbFalt 
Endif

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "FALT", .F., .T.)

MemoWrite("C:\temp\qryfaltas.txt", cQuery)

If FALT->(!EoF())
	nRet := FALT->DIAS_FALT
Endif

FALT->(dbCloseArea())

Return nRet

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � _DiasAfast � Autor � Felipe S. Raota            � Data � 15/04/13 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula dias que devem abater por afastamento.                    ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � FB101PPR                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

Static Function _DiasAfast()

Local nRet  := 0
Local dtIniPer := _aPer[_x, .DtIni]
Local dtFimPer := _aPer[_x, .DtFim]

Local dtIni := CtoD('')
Local dtFim := CtoD('')

Local cPerAuxIni := Alltrim(Str(Year(dtIniPer))) + StrZero(Month(dtIniPer),2)
Local cPerAuxFim := Alltrim(Str(Year(dtFimPer))) + StrZero(Month(dtFimPer),2)

If Select("AFAS") <> 0
	FALT->(dbCloseArea())
Endif

cQuery := " SELECT SR8.R8_FILIAL, SR8.R8_MAT, SR8.R8_DATAINI, SR8.R8_DATAFIM "
cQuery += " FROM "+RetSqlName("SR8")+" SR8 "
cQuery += " WHERE SR8.R8_FILIAL = '"+TRB->RA_FILIAL+"' "
cQuery += "   AND SR8.D_E_L_E_T_ = ' ' "
cQuery += "   AND SR8.R8_MAT = '"+TRB->RA_MAT+"' " 
cQuery += "   AND SR8.R8_TIPO <> 'F' " // F�rias n�o conta como afastamento
cQuery += "   AND (YEAR(SR8.R8_DATAINI) + Replicate('0',2-len(MONTH(SR8.R8_DATAINI))) + MONTH(SR8.R8_DATAINI) = '"+cPerAuxIni+"' "
cQuery += "     OR YEAR(SR8.R8_DATAFIM) + Replicate('0',2-len(MONTH(SR8.R8_DATAFIM))) + MONTH(SR8.R8_DATAFIM) = '"+cPerAuxFim+"' "
cQuery += "     OR (SR8.R8_DATAFIM = '        ' AND SR8.R8_DATAINI <= '"+cPerAuxIni+"01"+"' )"
cQuery += " 	OR (SR8.R8_DATAINI <= '"+cPerAuxIni+"01"+"' AND SR8.R8_DATAFIM >= '"+cPerAuxFim+"31"+"') " // Posso deixar fixo 31 pois � s� para compara��o
cQuery += "     OR (SR8.R8_DATAINI BETWEEN '"+cPerAuxIni+"01"+"' AND '"+cPerAuxFim+"31"+"')"  
cQuery += "     OR (SR8.R8_DATAFIM BETWEEN '"+cPerAuxIni+"01"+"' AND '"+cPerAuxFim+"31"+"')"

cQuery += " ) "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "AFAS", .F., .T.)

MemoWrite("c:\temp\qryAfastamento.txt", cQuery) 

TcSetField("AFAS","R8_DATAINI","D",8,0)
TcSetField("AFAS","R8_DATAFIM","D",8,0)

If AFAS->(!EoF())
	
	While AFAS->(!EoF())
	
		If AFAS->R8_DATAINI < dtIniPer
			dtIni := dtIniPer
		Else
			dtIni := AFAS->R8_DATAINI
		Endif
		
		If !Empty(AFAS->R8_DATAFIM)
		
			If AFAS->R8_DATAFIM > dtFimPer
				dtFim := dtFimPer
			Else
				dtFim := AFAS->R8_DATAFIM
			Endif
		
		Else
			dtFim := dtFimPer
		Endif
		
		nRet := (dtFim - dtIni) + 1
		
		AFAS->(dbSkip())
	Enddo
	
Endif

AFAS->(dbCloseArea())

Return nRet

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � _TrabPer   � Autor � Felipe S. Raota            � Data � 02/05/13 ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se o t�cnico trabalhou no per�odo.                       ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � FB101PPR                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

Static Function _TrabPer(sPerAntFim)

Local lRet := .F.

If Select("TRAB") <> 0
	TRAB->(dbCloseArea())
Endif

cQuery := " SELECT * "
cQuery += " FROM "+RetSqlName("ZZ5")+" ZZ5 "
cQuery += " WHERE ZZ5.D_E_L_E_T_ = ' ' "
cQuery += "   AND ZZ5.ZZ5_DTCHEG <> '        ' "
cQuery += "   AND ZZ5_DTCHEG <= '"+sPerAntFim+"' "
cQuery += "   AND ZZ5.ZZ5_CODTEC = '"+TRB->ZD_MAT+"' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRAB", .F., .T.)

If TRAB->(!EoF())
	lRet := .T.
Else
	lRet := .F.
Endif

TRAB->(dbCloseArea())

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � _fVerbFal� Autor � Felipe S. Raota       Data � 17/04/2013 ���
�������������������������������������������������������������������������͹��
���Descricao � f_Opcoes, para selecionar as verbas que deduzem da quanti- ���
���          � dade total de dias trabalhados.                            ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � FB101PPR                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function _fVerbFal()

Local cTitulo  := "Sele��o de Verbas de Falta/Atestado"
Local lRet     := .T.
Local aBox     := {}
Local MvParDef := ""
Local nTam     := 3
Local cQuery   := ""

MvParDef := ""

cQuery += " SELECT * "
cQuery += " FROM "+RetSqlName("SRV")+" SRV "
cQuery += " WHERE SRV.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY SRV.RV_COD "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "VERB", .F., .T.)

While VERB->(!EoF())
	
	aADD(aBox, VERB->RV_COD + " - " + VERB->RV_DESC )
	
	MvParDef += VERB->RV_COD
	VERB->(dbSkip())
Enddo

MvPar := &(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
mvRet := Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

Do While .T.
	
	lRet := f_Opcoes(	@MvPar,;		// uVarRet
						cTitulo,;		// cTitulo
						@aBox,;		// aOpcoes
						MvParDef,;		// cOpcoes
						,;				// nLin1
						,;				// nCol1
						.F.,;			// l1Elem
						nTam,; 		// nTam
						83,;			// nElemRet
						,;				// lMultSelect
						,;				// lComboBox
						,;				// cCampo
						,;				// lNotOrdena
						,;				// NotPesq
						.T.,;			// ForceRetArr
						)				// F3
	
	If lRet .AND. !Empty(MvPar)
		&MvRet := ""
		For nFor := 1 To Len( MvPar )
			&MvRet += MvPar[nFor]
		Next
		&MvRet += Space(Len(MvParDef)-Len(&MvRet))
		Exit
	Else
		&MvRet := Space(Len(MvParDef))
		Exit
		
	Endif
	
Enddo

VERB->(dbCloseArea())

Return MvParDef

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � _fFuncNao� Autor � Felipe S. Raota       Data � 17/04/2013 ���
�������������������������������������������������������������������������͹��
���Descricao � f_Opcoes, para selecionar as fun��es que n�o fazem parte   ���
���          � do c�lculo PPR.                                            ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � FB101PPR                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function _fFuncNao()

Local cTitulo  := "Sele��o de Fun��es que n�o calculam PPR"
Local lRet     := .T.
Local aBox     := {}
Local MvParDef := ""
Local nTam     := 5
Local cQuery   := ""

MvParDef := ""

cQuery += " SELECT * "
cQuery += " FROM "+RetSqlName("SRJ")+" SRJ "
cQuery += " WHERE SRJ.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY SRJ.RJ_FUNCAO "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "FUN", .F., .T.)

While FUN->(!EoF())
	
	aADD(aBox, FUN->RJ_FUNCAO + " - " + FUN->RJ_DESC )
	
	MvParDef += FUN->RJ_FUNCAO
	FUN->(dbSkip())
Enddo

MvPar := &(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
mvRet := Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

Do While .T.
	
	lRet := f_Opcoes(	@MvPar,;		// uVarRet
						cTitulo,;		// cTitulo
						@aBox,;		// aOpcoes
						MvParDef,;		// cOpcoes
						,;				// nLin1
						,;				// nCol1
						.F.,;			// l1Elem
						nTam,; 		// nTam
						50,;			// nElemRet
						,;				// lMultSelect
						,;				// lComboBox
						,;				// cCampo
						,;				// lNotOrdena
						,;				// NotPesq
						.T.,;			// ForceRetArr
						)				// F3
	
	If lRet .AND. !Empty(MvPar)
		&MvRet := ""
		For nFor := 1 To Len( MvPar )
			&MvRet += MvPar[nFor]
		Next
		&MvRet += Space(Len(MvParDef)-Len(&MvRet))
		Exit
	Else
		&MvRet := Space(Len(MvParDef))
		Exit
		
	Endif
	
Enddo

FUN->(dbCloseArea())

Return MvParDef