#Include 'Protheus.ch'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FB901PPR ³ Autor ³ Felipe S. Raota             ³ Data ³ 10/04/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Unidade   ³ TRS              ³Contato ³ felipe.raota@totvs.com.br             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Fonte com funções genéricas do PPR.                               ³±±
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

User Function FB901PPR()

Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ ObrColsPPR ³ Autor ³ Felipe S. Raota            ³ Data ³ 05/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Verifica campos obrigatóriosnão preenchidos no aCols.             ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB003PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function ObrColsPPR(nLin, aH, aC, cMsg)

Local nCampo   := 0
Local aAreaAnt := GetArea()
Local aAreaSX3 := {}
Local lRet     := .T.
Local _cSX3    := ""

nLin := IIF(nLin == NIL, N, nLin)
aH   := IIF(aH == NIL, aHeader, aH)
aC   := IIF(aC == NIL, aCols, aC)

	If !GdDeleted(nLin, aH, aC)
		
		For nCampo:=1 to len(aH)

			_cSX3    := GetNextAlias()

			OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX3,"SX3",Nil,.F.)
			lOpen := Select(_cSX3) > 0
			If (lOpen)
  				dbSelectArea(_cSX3)
  				(_cSX3)->(dbSetOrder(2)) //X3_CAMPO
  				(_cSX3)->(dbSeek(aH[nCampo, 2]))
				If (Found())
					If (X3USO(&("(_cSX3)->X3_USADO")) .AND. ((SubStr(BIN2STR(&("(_cSX3)->X3_OBRIGAT")),1,1) == 'x') .or. VerByte(&("(_cSX3)->X3_RESERV"),7)))
						MsgAlert(Alltrim(cMsg) + ' Campo ' + Alltrim(aH[nCampo, 1]) + ' deve ser informado', aH[nCampo, 2])
						lRet := .F.
						EXIT	
					EndIf
				Endif
	
			EndIf
			(_cSX3)->(dbCloseArea())

		Next
	EndIf


	/*aAreaSX3 := SX3->(GetArea())
	SX3->(dbSetOrder(2))  // Por nome de campo
	
	For nCampo:=1 to len(aH)
		
		If Empty(aC[nLin, nCampo])
			If SX3->(MsSeek(aH[nCampo, 2], .F.))
				If (X3USO(SX3->X3_USADO) .AND. ((SubStr(BIN2STR(SX3->X3_OBRIGAT),1,1) == 'x') .or. VerByte(SX3->X3_RESERV,7)))
					MsgAlert(Alltrim(cMsg) + ' Campo ' + Alltrim(aH[nCampo, 1]) + ' deve ser informado', aH[nCampo, 2])
					lRet := .F.
					EXIT
				Endif
			Endif
		Endif
		
	Next
	
	SX3->(RestArea(aAreaSX3))
	
Endif*/

RestArea(aAreaAnt)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _ValidPer  ³ Autor ³ Felipe S. Raota            ³ Data ³ 11/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Verifica se período informado é válido e se já não foi calculado. ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB901PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function _ValidPer(xPer, xAno)

Local aArea := GetArea()
Local lRet  := .T.
Local nPer  := xPer
Local nAno  := Val(xAno)

	If nAno > Year(dDataBase)
	lRet := .F.
	MsgAlert('Período de cálculo não pode ser superior à data atual.')
	Endif

	If lRet

	dbSelectArea('SZD')
	SZD->(dbSetOrder(4))
	
		If SZD->(MsSeek( xFilial('SZD') + Alltrim(Str(nPer)) + '/' + Alltrim(Str(nAno)) ))
		
			If SZD->ZD_FINAL == 'S'
			MsgAlert('Período já cálculado e finalizado! Não é possível prosseguir.')
			lRet := .F.
			Endif
		
		Endif

	Endif

RestArea(aArea)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _CodCalc   ³ Autor ³ Felipe S. Raota            ³ Data ³ 15/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Busca próximo número de código de cálculo válido.                 ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB901PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function _CodCalc()

Local aArea  := GetArea()
Local cRet   := ''
Local cQuery := ''

cQuery := " SELECT ISNULL(MAX(ZD_CODCALC),'000000') + 1 as CODIGO "
cQuery += " FROM "+RetSqlName("SZD")+" "

	If Select("COD") <> 0
	COD->(dbCloseArea())
	Endif

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "COD", .F., .T.)

	If COD->(!EoF())
	cRet := StrZero(COD->CODIGO,6)
	Endif

COD->(dbCloseArea())

RestArea(aArea)

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _AjustaSel ³ Autor ³ Felipe S. Raota            ³ Data ³ 17/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Ajusta variável usada no f_Opcoes, para utilizar como filtro IN no³±±
±±³          ³ SQL                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB901PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function _AjustSel(cParam, nTam)

Local cRet := ""

Local cParAux := Alltrim(cParam)
Local nPosAux := 1
Local nTamAux := nTam

	While nPosAux < len(cParAux)
	cRet += SubStr(cParAux,nPosAux,nTamAux) + ";"
	nPosAux += nTamAux
	Enddo

cRet := FormatIn(cRet,";") 

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _QryEquipe ³ Autor ³ Felipe S. Raota            ³ Data ³ 19/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Gera query de equipes para o período passado por parâmetro.       ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB901PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function _QryEquipe(sPerDe, sPerAte, sDtIni, sDtFim, cCalc, cPer)

Local cQry  := ""
Local _CRLF := Chr(13) + Chr(10)

Local sPerAntIni := DtoS(MonthSub(StoD(sPerDe),1))
Local sPerAntFim := DtoS(MonthSub(StoD(sPerAte),1))

Local cMesPer := StrZero(Month(StoD(sPerAte)),2)

Local cPerAnt := ''
Local cMesAnt := ''
/*
	If Left(cPer, 1) == '1'
	cPerAnt := '2/' + Alltrim(Str(Val(Right(cPer,4)) - 1))
	cMesAnt := '12'
	Else
	cPerAnt := '1/' + Right(cPer,4)
	cMesAnt := '06'
	Endif
*/

	If cMesPer == "01" .OR. cMesPer == "07"

		If cMesPer == "01"
			cMesAnt := "12"
			cPerAnt := "2/" + Alltrim(Str(Val(Right(cPer,4)) - 1))
		Else
			cMesAnt:= "06"
			cPerAnt := "1/" + Right(cPer,4)
		Endif

	Else
		cMesAnt := StrZero(Val(cMesPer) - 1,2)
		cPerAnt := cPer
	Endif

//cQuery := " -- Gero nova tabela SRA, já buscando o código de função correta no período e efetuando alguns filtros."

	cQry := " IF OBJECT_ID(N'SRA_PPR', N'U') IS NOT NULL "
	cQry += " 	DROP TABLE SRA_PPR "

	cQry += " SELECT  ISNULL(( "
	cQry += " 				SELECT TOP 1 SR7.R7_FUNCAO "
	cQry += " 				FROM "+RetSqlName("SR7")+" SR7 "
	cQry += " 				WHERE SR7.D_E_L_E_T_ = ' ' "
	cQry += " 				  AND SR7.R7_MAT = SRA.RA_MAT "
	cQry += " 				  AND SR7.R7_DATA <= '"+sPerAte+"' "
	cQry += " 				ORDER BY SR7.R7_DATA DESC, SR7.R7_SEQ DESC "
	cQry += " 			),SRA.RA_CODFUNC) FUNCAO,  "
	cQry += " 			ISNULL(( "
	cQry += " 				SELECT TOP 1 SRE.RE_CCP "
	cQry += " 				FROM "+RetSqlName("SRE")+" SRE "
	cQry += " 				WHERE SRE.D_E_L_E_T_ = ' ' "
	cQry += " 				  AND SRE.RE_MATD = SRA.RA_MAT "
	cQry += " 				  AND SRE.RE_DATA <= '"+sPerAte+"' "
	cQry += " 				  AND DATEDIFF(DAY, CAST(SRE.RE_DATA as DATE),CAST('"+sPerAte+"' as DATE)) + 1 >= 15 "
	cQry += " 				ORDER BY SRE.RE_DATA DESC "
	cQry += " 			),SRA.RA_CC) UNIDADE, * "
	cQry += " INTO SRA_PPR "
	cQry += " FROM "+RetSqlName("SRA")+" SRA "
	cQry += " WHERE SRA.D_E_L_E_T_ = ' ' "
	cQry += "   AND SRA.RA_ADMISSA <= '"+sPerDe+"' "

	MemoWrite("C:\temp\QrySRA_PPR.txt", cQry)

	TcSQLExec(cQry)
	cQry := ''

// Após gerar 'SRA' nova, vou na tabela SZD e marco como deletado os que tenham admissão inferior ao inicio do período

	cQry += " UPDATE " + RetSqlName("SZD") + _CRLF
	cQry += " SET D_E_L_E_T_ = '*' " + _CRLF
	cQry += " WHERE R_E_C_N_O_ IN " + _CRLF
	cQry += " 	( " + _CRLF
	cQry += " 		SELECT SZD_AUX.R_E_C_N_O_ " + _CRLF
	cQry += " 		FROM "+RetSqlName("SZD")+" SZD_AUX LEFT JOIN SRA_PPR SRA_P ON SZD_AUX.ZD_MAT = SRA_P.RA_MAT " + _CRLF
	cQry += " 		WHERE SZD_AUX.ZD_MESCALC = '"+StrZero(Month(StoD(sPerAte)),2)+"' " + _CRLF
	cQry += " 		  AND SRA_P.R_E_C_N_O_ IS NULL " + _CRLF
	cQry += " 	) " + _CRLF

	MEMOWRITE("C:\temp\UPD_SRA.txt", cQry)

	TcSQLExec(cQry)
	cQry := ''

//cQry := " -- Query principal, filtra ordens de serviço do período, e busca a função de acordo com a tabela de Excessões, se existir. " + _CRLF 
//cQry += " -- Verifica se tabela temporária já existe. " + _CRLF

	cQry += " IF OBJECT_ID(N'PPR_EQUIPES', N'U') IS NOT NULL " + _CRLF
	cQry += " 	DROP TABLE PPR_EQUIPES " + _CRLF

	cQry += " SELECT ZZ5_FILIAL, ZZ5_CODTEC, ZZ5_EQUIPE, ZZ5_DTCHEG, SRA.RA_NOME, SRA.FUNCAO, ISNULL(SZB.ZB_FUNCNEW,SRA.FUNCAO) as ZB_FUNCNEW, SRA.UNIDADE, SZB.ZB_DTINI, SZB.ZB_DTFIM, ZZ5_ENCARR " + _CRLF
	cQry += " INTO PPR_EQUIPES " + _CRLF
	cQry += " FROM "+RetSqlName("ZZ5")+" ZZ5 INNER JOIN SRA_PPR SRA ON ZZ5.ZZ5_CODTEC = SRA.RA_MAT " + _CRLF
	cQry += "                                 LEFT JOIN "+RetSqlName("SZB")+" SZB ON SRA.RA_MAT = SZB.ZB_MAT AND (SZB.ZB_DTINI >= '"+sPerDe+"' OR SZB.ZB_DTFIM <= '"+sPerAte+"') AND SZB.D_E_L_E_T_ = ' ' " + _CRLF
	cQry += " WHERE ZZ5.D_E_L_E_T_ = ' ' " + _CRLF
	cQry += " 	AND ZZ5.ZZ5_DTCHEG <> '        ' " + _CRLF
	cQry += " 	AND ZZ5.ZZ5_DTCHEG BETWEEN '"+sPerDe+"' AND '"+sPerAte+"' -- Mês anterior e Mês atual " + _CRLF
	cQry += " GROUP BY ZZ5.ZZ5_FILIAL, ZZ5.ZZ5_CODTEC, ZZ5.ZZ5_EQUIPE, ZZ5_DTCHEG, SRA.RA_NOME, SRA.FUNCAO, SZB.ZB_FUNCNEW, SRA.UNIDADE, SZB.ZB_DTINI, SZB.ZB_DTFIM, ZZ5_ENCARR " + _CRLF

	MemoWrite("C:\temp\Qry1_PPR.txt", cQry)

//Alert("1")

	TcSQLExec(cQry)
	cQry := ''

//cQry += " -- Conto os dias trabalhados em cada equipe e busco a última data apontada " + _CRLF

	cQry += " IF OBJECT_ID(N'PPR_DIASTRAB', N'U') IS NOT NULL " + _CRLF
	cQry += " 		DROP TABLE PPR_DIASTRAB " + _CRLF

	cQry += " SELECT TRB.ZZ5_FILIAL, TRB.ZZ5_CODTEC, TRB.RA_NOME, TRB.ZZ5_EQUIPE, TRB.FUNCAO, TRB.ZB_FUNCNEW, TRB.UNIDADE, TRB.ZB_DTINI, TRB.ZB_DTFIM, COUNT(*) as DIAS, ( " + _CRLF
	cQry += " 																										SELECT MAX(ZZ5_DTCHEG) " + _CRLF
	cQry += " 																										FROM PPR_EQUIPES PPR " + _CRLF
	cQry += " 																										WHERE PPR.ZZ5_FILIAL = TRB.ZZ5_FILIAL " + _CRLF
	cQry += " 																										  AND PPR.ZZ5_CODTEC = TRB.ZZ5_CODTEC " + _CRLF
	cQry += " 																										  AND PPR.ZZ5_EQUIPE = TRB.ZZ5_EQUIPE " + _CRLF
	cQry += " 																									  ) AS ULT_DATA, ( " + _CRLF
	cQry += " 																										SELECT COUNT(*) " + _CRLF
	cQry += " 																										FROM PPR_EQUIPES PPR " + _CRLF
	cQry += " 																										WHERE PPR.ZZ5_FILIAL = TRB.ZZ5_FILIAL " + _CRLF
	cQry += " 																										  AND PPR.ZZ5_CODTEC = TRB.ZZ5_CODTEC " + _CRLF
	cQry += " 																										  AND PPR.ZZ5_EQUIPE = TRB.ZZ5_EQUIPE " + _CRLF
	cQry += " 																										  AND PPR.ZZ5_ENCARR = 'S' " + _CRLF
	cQry += " 																									  ) AS DIAS_ENCARR " + _CRLF
	cQry += " INTO PPR_DIASTRAB " + _CRLF
	cQry += " FROM PPR_EQUIPES TRB " + _CRLF
	cQry += " GROUP BY TRB.ZZ5_FILIAL, TRB.ZZ5_CODTEC, TRB.ZZ5_EQUIPE, TRB.RA_NOME, TRB.FUNCAO, TRB.ZB_FUNCNEW, TRB.UNIDADE, TRB.ZB_DTINI, TRB.ZB_DTFIM " + _CRLF

	MemoWrite("C:\temp\Qry2_PPR.txt", cQry)

//Alert("2")

	TcSQLExec(cQry)
	cQry := ''

//cQry += " -- Conto os dias trabalhados em cada equipe e busco a última data apontada " + _CRLF

	cQry += " IF OBJECT_ID(N'TBL_PPR', N'U') IS NOT NULL " + _CRLF
	cQry += " 	DROP TABLE TBL_PPR " + _CRLF

	cQry += " SELECT 1 AS TIPO, *, ( " + _CRLF
	cQry += " 				SELECT TOP 1 PPR.ZZ5_EQUIPE " + _CRLF
	cQry += " 				FROM  PPR_DIASTRAB PPR " + _CRLF
	cQry += " 				WHERE PPR.ZZ5_CODTEC = TAB.ZD_MAT " + _CRLF
	cQry += " 			  	  AND PPR.DIAS = TAB.DIAS_PPR " + _CRLF
	cQry += " 			  	  AND PPR.ULT_DATA = (SELECT MAX(PPR.ULT_DATA) FROM PPR_DIASTRAB PPR WHERE PPR.ZZ5_CODTEC = TAB.ZD_MAT AND PPR.DIAS = TAB.DIAS_PPR) " + _CRLF
	cQry += " 		      ) as EQUIPE " + _CRLF
	cQry += " , ( " + _CRLF
	cQry += " 	SELECT TOP 1 PPR.ZB_FUNCNEW " + _CRLF
	cQry += " 	FROM  PPR_DIASTRAB PPR " + _CRLF
	cQry += " 	WHERE PPR.ZZ5_CODTEC = TAB.ZD_MAT " + _CRLF
	cQry += " 	  AND PPR.DIAS = TAB.DIAS_PPR " + _CRLF
	cQry += " 	  AND PPR.ULT_DATA = (SELECT MAX(PPR.ULT_DATA) FROM PPR_DIASTRAB PPR WHERE PPR.ZZ5_CODTEC = TAB.ZD_MAT AND PPR.DIAS = TAB.DIAS_PPR) " + _CRLF
	cQry += "   ) as FUNCAO " + _CRLF
	cQry += " , ( " + _CRLF
	cQry += " 	SELECT TOP 1 PPR.UNIDADE " + _CRLF
	cQry += " 	FROM  PPR_DIASTRAB PPR " + _CRLF
	cQry += " 	WHERE PPR.ZZ5_CODTEC = TAB.ZD_MAT " + _CRLF
	cQry += " 	  AND PPR.DIAS = TAB.DIAS_PPR " + _CRLF
	cQry += " 	  AND PPR.ULT_DATA = (SELECT MAX(PPR.ULT_DATA) FROM PPR_DIASTRAB PPR WHERE PPR.ZZ5_CODTEC = TAB.ZD_MAT AND PPR.DIAS = TAB.DIAS_PPR) " + _CRLF
	cQry += "   ) as UNIDADE " + _CRLF
	cQry += " , ( " + _CRLF
	cQry += " 	SELECT TOP 1 PPR.ZB_DTINI " + _CRLF
	cQry += " 	FROM  PPR_DIASTRAB PPR " + _CRLF
	cQry += " 	WHERE PPR.ZZ5_CODTEC = TAB.ZD_MAT " + _CRLF
	cQry += " 	  AND PPR.DIAS = TAB.DIAS_PPR " + _CRLF
	cQry += " 	  AND PPR.ULT_DATA = (SELECT MAX(PPR.ULT_DATA) FROM PPR_DIASTRAB PPR WHERE PPR.ZZ5_CODTEC = TAB.ZD_MAT AND PPR.DIAS = TAB.DIAS_PPR) " + _CRLF
	cQry += "   ) as ZB_DTINI " + _CRLF
	cQry += " , ( " + _CRLF
	cQry += " 	SELECT TOP 1 PPR.ZB_DTFIM " + _CRLF
	cQry += " 	FROM  PPR_DIASTRAB PPR " + _CRLF
	cQry += " 	WHERE PPR.ZZ5_CODTEC = TAB.ZD_MAT " + _CRLF
	cQry += " 	  AND PPR.DIAS = TAB.DIAS_PPR " + _CRLF
	cQry += " 	  AND PPR.ULT_DATA = (SELECT MAX(PPR.ULT_DATA) FROM PPR_DIASTRAB PPR WHERE PPR.ZZ5_CODTEC = TAB.ZD_MAT AND PPR.DIAS = TAB.DIAS_PPR) " + _CRLF
	cQry += "   ) as ZB_DTFIM " + _CRLF
	cQry += " INTO TBL_PPR " + _CRLF
	cQry += " FROM " + _CRLF
	cQry += " ( " + _CRLF
	cQry += " 	SELECT PPR2.ZZ5_FILIAL as ZD_FILMAT , PPR2.ZZ5_CODTEC as ZD_MAT, MAX(PPR2.DIAS) AS DIAS_PPR, PPR2.DIAS_ENCARR " + _CRLF
	cQry += " 	FROM PPR_DIASTRAB PPR2 " + _CRLF
	cQry += " 	GROUP BY PPR2.ZZ5_FILIAL, PPR2.ZZ5_CODTEC, PPR2.DIAS_ENCARR " + _CRLF
	cQry += " ) TAB " + _CRLF

	MemoWrite("C:\temp\Qry3_PPR.txt", cQry)

//Alert("3")

	TcSQLExec(cQry)
	cQry := ''

	cQry += " IF OBJECT_ID(N'TBL_PPR2', N'U') IS NOT NULL " + _CRLF
	cQry += " 	DROP TABLE TBL_PPR2 " + _CRLF

// Olho nas OS's do período anterior...
	cQry += " SELECT * " + _CRLF
	cQry += " INTO TBL_PPR2 " + _CRLF
	cQry += " FROM " + _CRLF
	cQry += " ( " + _CRLF
	cQry += " 	SELECT 2 as TIPO, SZD.ZD_FILMAT, SZD.ZD_MAT, 0 as DIAS_PPR, 0 as DIAS_ENCARR, " + _CRLF
	cQry += " 		   ( " + _CRLF
	cQry += " 			 SELECT TOP 1 ZZ5.ZZ5_EQUIPE " + _CRLF
	cQry += " 			 FROM "+RetSqlName("ZZ5")+" ZZ5 " + _CRLF
	cQry += " 			 WHERE ZZ5.D_E_L_E_T_ = ' ' " + _CRLF
	cQry += " 			   AND ZZ5.ZZ5_DTCHEG <> '        ' " + _CRLF
	cQry += " 			   AND ZZ5.ZZ5_CODTEC = SZD.ZD_MAT " + _CRLF
	cQry += " 			   AND ZZ5.ZZ5_DTCHEG >= '"+sPerAntIni+"' AND ZZ5.ZZ5_DTCHEG <= '"+sPerAntFim+"' " + _CRLF //Somente olhar para o período anterior ao atual.
	cQry += " 			   AND ZZ5.ZZ5_DTCHEG >= SRA.RA_ADMISSA " + _CRLF // Somente funcionários contratados antes do período
	cQry += " 			 ORDER BY ZZ5.ZZ5_DTCHEG DESC " + _CRLF
	cQry += " 		   ) as EQUIPE, " + _CRLF
//cQry += " 		   SRA.RA_CODFUNC, " + _CRLF
	cQry += " 		   ISNULL(SZB.ZB_FUNCNEW,SRA.FUNCAO) as FUNCAO, " + _CRLF
	cQry += " 		   SRA.UNIDADE, " + _CRLF
	cQry += " 		   '        ' as ZB_DTINI, " + _CRLF
	cQry += " 		   '        ' as ZB_DTFIM " + _CRLF
	cQry += " 	FROM "+RetSqlName("SZD")+" SZD INNER JOIN SRA_PPR SRA ON SZD.ZD_MAT = SRA.RA_MAT " + _CRLF
	cQry += " 									   LEFT JOIN "+RetSqlName("SZB")+" SZB ON SRA.RA_MAT = SZB.ZB_MAT AND (SZB.ZB_DTINI >= '"+sPerAntIni+"' OR SZB.ZB_DTFIM <= '"+sPerAntFim+"') " + _CRLF
	cQry += " 	WHERE SZD.D_E_L_E_T_ = ' ' " + _CRLF
	cQry += " 	  AND SZD.ZD_CODCALC = '"+cCalc+"' " + _CRLF
	cQry += " 	  AND SZD.ZD_MESCALC = '"+cMesPer+"' " + _CRLF
	cQry += " 	  AND SZD.ZD_DIASTRB >= 15 " + _CRLF
//cQry += " 	  AND SRA.RA_ADMISSA <= '"+sPerAntIni+"' " + _CRLF // Não preciso olhar a data de admissão do período passado...
	cQry += " 	  AND NOT EXISTS (SELECT PPR.ZD_MAT FROM TBL_PPR PPR WHERE PPR.ZD_MAT = SZD.ZD_MAT) " + _CRLF
	cQry += " ) TAB " + _CRLF
	cQry += " WHERE TAB.EQUIPE IS NOT NULL " + _CRLF

	MemoWrite("C:\temp\Qry4_PPR.txt", cQry)

//Alert("4")

	TcSQLExec(cQry)
	cQry := ''

	cQry += " SELECT * " + _CRLF
	cQry += " FROM TBL_PPR " + _CRLF

	cQry += " UNION ALL " + _CRLF

	cQry += " SELECT * " + _CRLF
	cQry += " FROM TBL_PPR2 " + _CRLF

	cQry += " UNION ALL " + _CRLF

// Olho no Cálculo de PPR anterior
	cQry += " SELECT * " + _CRLF
	cQry += " FROM " + _CRLF
	cQry += " ( " + _CRLF
	cQry += " 	SELECT 3 as TIPO, SZD.ZD_FILMAT, SZD.ZD_MAT, 0 as DIAS_PPR, 0 as DIAS_ENCARR, " + _CRLF
	cQry += " 		   IsNull(( " + _CRLF
	cQry += " 			SELECT SZDAUX.ZD_EQUIPE " + _CRLF
	cQry += " 			FROM "+RetSqlName("SZD")+" SZDAUX " + _CRLF
	cQry += " 			WHERE SZDAUX.D_E_L_E_T_ = ' ' " + _CRLF
	cQry += " 			  AND SZDAUX.ZD_PERIODO = '"+cPerAnt+"' " + _CRLF
	cQry += " 			  AND SZDAUX.ZD_MESCALC = '"+cMesAnt+"' " + _CRLF
	cQry += " 			  AND SZDAUX.ZD_MAT = SRA.RA_MAT " + _CRLF
	cQry += " 		   ),'     ') as EQUIPE, " + _CRLF
//cQry += " 		   SRA.RA_CODFUNC, " + _CRLF
	cQry += " 		   ISNULL(SZB.ZB_FUNCNEW,SRA.FUNCAO) as FUNCAO, " + _CRLF
	cQry += " 		   SRA.UNIDADE, " + _CRLF
	cQry += " 		   '        ' as ZB_DTINI, " + _CRLF
	cQry += " 		   '        ' as ZB_DTFIM " + _CRLF
	cQry += " 	FROM "+RetSqlName("SZD")+" SZD INNER JOIN SRA_PPR SRA ON SZD.ZD_MAT = SRA.RA_MAT " + _CRLF
	cQry += " 								   LEFT JOIN "+RetSqlName("SZB")+" SZB ON SRA.RA_MAT = SZB.ZB_MAT AND (SZB.ZB_DTINI >= '"+sPerAntIni+"' OR SZB.ZB_DTFIM <= '"+sPerAntFim+"') " + _CRLF
	cQry += " 	WHERE SZD.D_E_L_E_T_ = ' ' " + _CRLF
	cQry += " 	  AND SZD.ZD_CODCALC = '"+cCalc+"' " + _CRLF
	cQry += " 	  AND SZD.ZD_MESCALC = '"+cMesPer+"' " + _CRLF
	cQry += " 	  AND SZD.ZD_DIASTRB >= 15 " + _CRLF
//cQry += " 	  AND SRA.RA_ADMISSA <= '"+sPerAntIni+"' " + _CRLF  // Não preciso olhar a data de admissão do período passado...
	cQry += " 	  AND NOT EXISTS (SELECT PPR.ZD_MAT FROM TBL_PPR PPR WHERE PPR.ZD_MAT = SZD.ZD_MAT) " + _CRLF
	cQry += " 	  AND NOT EXISTS (SELECT PPR2.ZD_MAT FROM TBL_PPR2 PPR2 WHERE PPR2.ZD_MAT = SZD.ZD_MAT) " + _CRLF
	cQry += " ) TAB " + _CRLF
//cQry += " WHERE TAB.EQUIPE <> '' " + _CRLF // Não sei pq coloquei esse filtro, mas não deve ter pois irá eliminar os registros sem equipes. 

	MemoWrite("C:\temp\Qry5_PPR.txt", cQry)

//Alert("5")

Return cQry

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _BuscaEnc  ³ Autor ³ Felipe S. Raota            ³ Data ³ 23/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Busca o código da função do encarregado na tabela de bases de     ³±±
±±³          ³ cálculo.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB901PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function _BuscaEnc()

Local aArea := GetArea()
Local cCodEnc := ''

dbSelectArea("SZ6")
SZ6->(dbSetOrder(1))

SZ6->(dbGoTop())

	While SZ6->(!EoF())

		If SZ6->Z6_ENCARRE == 'S'
		cCodEnc := SZ6->Z6_CODFUNC
		EXIT
		Endif
	
	SZ6->(dbSkip())
	Enddo

restArea(aArea)

Return cCodEnc

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _BuscaBase ³ Autor ³ Felipe S. Raota            ³ Data ³ 23/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Busca a base de cálculo da função passada por parâmetro.          ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB901PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function _BuscaBase(cFun, cGrpPPR, lGrp)

Local aArea := GetArea()
Local nValBase := 0

Local cFormul := ''

// Tratamento para busca de Base de Cálculo Variável por FUNÇÃO
	If !lGrp

	dbSelectArea("SZ6")
	SZ6->(dbSetOrder(1))
	
	// Verifico Base de Cálculo padrão.
		If SZ6->(MsSeek( xFilial("SZ6") + cFun ))
		nValBase := SZ6->Z6_BASE
		Endif
	
	// Verifico variações da Base de Cálculo
	
	dbSelectArea("SZC")
	SZC->(dbSetOrder(2))
	
		If SZC->(MsSeek( xFilial("SZC") + cFun ))
		
			While SZC->(!EoF()) .AND. xFilial("SZC") + cFun == SZC->ZC_FILIAL + SZC->ZC_FUNCAO
			
			// Montagem da Fórmula
			cFormul := U__ConvChave(U__ExecFunc(SZC->ZC_CODFUN),SZC->ZC_TPDADO, .T.) + ' ' + Alltrim(SZC->ZC_OPER1) + ' ' + U__ConvChave(SZC->ZC_VAL1, SZC->ZC_TPDADO, .T.)
			
			// Testo se tem segunda operação
				If !Empty(SZC->ZC_OPER2)
				cFormul += ' .AND. ' + U__ConvChave(U__ExecFunc(SZC->ZC_CODFUN),SZC->ZC_TPDADO, .T.) + ' ' + Alltrim(SZC->ZC_OPER2) + ' ' + U__ConvChave(SZC->ZC_VAL2, SZC->ZC_TPDADO, .T.)
				Endif
			
			// Interpreta fórmula e caso .T. para busca de variações
				If &(cFormul)
				nValBase := SZC->ZC_QTDBC
				EXIT
				Endif
			
			SZC->(dbSkip())
			Enddo
	
		Endif

// Tratamento para busca de Base de Cálculo Variável por GRUPO PPR
	Else
	
	dbSelectArea("SZC")
	SZC->(dbSetOrder(1))
	
		If SZC->(MsSeek( xFilial("SZC") + cGrpPPR ))
		
			While SZC->(!EoF()) .AND. xFilial("SZC") + cGrpPPR == SZC->ZC_FILIAL + SZC->ZC_CODGRP
			
			// Montagem da Fórmula
			cFormul := U__ConvChave(U__ExecFunc(SZC->ZC_CODFUN),SZC->ZC_TPDADO, .T.) + ' ' + Alltrim(SZC->ZC_OPER1) + ' ' + U__ConvChave(SZC->ZC_VAL1, SZC->ZC_TPDADO, .T.)
			
			// Testo se tem segunda operação
				If !Empty(SZC->ZC_OPER2)
				cFormul += ' .AND. ' + U__ConvChave(U__ExecFunc(SZC->ZC_CODFUN),SZC->ZC_TPDADO, .T.) + ' ' + Alltrim(SZC->ZC_OPER2) + ' ' + U__ConvChave(SZC->ZC_VAL2, SZC->ZC_TPDADO, .T.)
				Endif
			
			// Interpreta fórmula e caso .T. para busca de variações
				If &(cFormul)
				nValBase := SZC->ZC_QTDBC
				EXIT
				Endif
			
			SZC->(dbSkip())
			Enddo
	
		Endif
	
	Endif

restArea(aArea)

Return nValBase

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _ExecFunc  ³ Autor ³ Felipe S. Raota            ³ Data ³ 24/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Executa função passada por parâmetro.                             ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB901PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function _ExecFunc(cFunc)

Local aArea   := GetArea()
Local cRet    := ''

Private _cAux := ""

dbSelectArea("SZ8") 
SZ8->(dbSetOrder(1)) 

	If SZ8->(MsSeek( xFilial("SZ8") + cFunc ))
	_cAux := Alltrim(SZ8->Z8_FUNCAO)
	cRet := &(_cAux)
	Endif

SZ8->(dbCloseArea())

restArea(aArea) 

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _ConvChave ³ Autor ³ Felipe S. Raota            ³ Data ³ 24/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Converte chave para o tipo informado por parâmetro.               ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB901PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function _ConvChave(xChav, cTip, lChar)

Local aArea   := GetArea()
Local cRet    := ''

Default lChar := .F.

Private xChv := xChav // Só pra garantir que é private

	Do Case

	Case cTip == 'C'

		Do Case
		Case Type("xChv") == 'C'
				cRet := "'"+Alltrim(xChv)+"'"
		Case Type("xChv") == 'N'
				cRet := "'"+Alltrim(Str(xChv))+"'"
		EndCase
	
	Case cTip == 'N'
		
		Do Case
		Case Type("xChv") == 'C'
				cRet := Val(xChv)
			If lChar
					cRet := Alltrim(Str(cRet))
			Endif
		Case Type("xChv") == 'N'
				cRet := xChv
			If lChar
					cRet := Alltrim(Str(cRet))
			Endif
		EndCase

	Case cTip == 'P'
		
		Do Case
		Case Type("xChv") == 'C'
				cRet := Val(xChv) / 100
			If lChar
					cRet := Alltrim(Str(cRet))
			Endif
		Case Type("xChv") == 'N'
				cRet := xChv / 100 // Retorna o valor pronto para multiplicar
			If lChar
					cRet := Alltrim(Str(cRet))
			Endif
		EndCase
		
	EndCase

restArea(aArea)

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GrvLogPPR ³ Autor ³ Felipe S. Raota            ³ Data ³ 02/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Grava log na tabela SZF.                                          ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB901PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function _GrvLogPPR(cGrp, cMat, cEqp, cInd, cLog, cCalc, cMes)

Local aArea   := GetArea()

dbSelectArea("SZQ")

RecLock("SZQ", .T.)
	SZQ->ZQ_FILIAL  := xFilial("SZQ")
	SZQ->ZQ_CODCALC := cCalc
	SZQ->ZQ_DATA    := dDataBase
	SZQ->ZQ_HORA    := Time()
	SZQ->ZQ_USER    := RetCodUsr()
	SZQ->ZQ_CODGRP  := cGrp
	SZQ->ZQ_MAT     := cMat
	SZQ->ZQ_EQUIPE  := cEqp
	SZQ->ZQ_CODIND  := cInd
	SZQ->ZQ_MES     := cMes
	SZQ->ZQ_LOG     := cLog
MsUnLock()

restArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _VerifCalc ³ Autor ³ Felipe S. Raota            ³ Data ³ 09/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Verifica se código de cálculo existe.                             ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB901PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function _VerifCalc(cCalc)

Local aArea := GetArea()
Local lRet  := .F.

dbSelectArea("SZD")
SZD->(dbSetOrder(1))

	If SZD->(MsSeek( xFilial("SZD") + cCalc ))
	lRet := .T.
	Endif

restArea(aArea)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _MedIntEqp ³ Autor ³ Felipe S. Raota            ³ Data ³ 28/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Gera tabela temporária com a quantidade média de integrantes nas  ³±±
±±³          ³ equipes H por período.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB901PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function _MedIntEqp(cMesAno, cPer)

Local cQry  := ""
Local _CRLF := Chr(13) + Chr(10)
Local sDtAux := ""

dbSelectArea("SZK")
SZK->(dbSetOrder(2))

sPIni := MonthSub(CtoD("01/"+cMesAno), 1)
sPIni := Alltrim(Str(Year(sPIni))) + StrZero(Month(sPIni), 2) + '16' 

sPFim := Alltrim(Str(Year(CtoD("01/"+cMesAno)))) + StrZero(Month(CtoD("01/"+cMesAno)), 2) + '15'

	If Select("TRBM") <> 0
	TRBM->(dbCloseArea())
	Endif

// Mês do final do período
	If Left(cPer,1) == "1"
	cLasM := "06"
	Else
	cLasM := "12"
	Endif

sDtAux := Alltrim(Str(Year(CtoD("01/"+cMesAno)))) + cLasM + "01" 
sDtAux := DtoS(LastDay(StoD(sDtAux)))

cQry += " SELECT TRB2.ZZ5_FILIAL, TRB2.ZZ5_EQUIPE, CAST(ROUND(CAST(SUM(TRB2.QTD_TEC) as Numeric(12,2)) / CAST(COUNT(TRB2.QTD_TEC) as Numeric(12,2)),0) as int) as QTD_TEC " + _CRLF
cQry += " FROM " + _CRLF 
cQry += " ( " + _CRLF
cQry += " 	SELECT TRB.ZZ5_FILIAL, TRB.ZZ5_EQUIPE, TRB.ZZ5_DTCHEG, CAST(ROUND(CAST(SUM(TRB.QTD_TEC) as Numeric(12,2)) / CAST(COUNT(TRB.QTD_TEC) as Numeric(12,2)),0) as int) as QTD_TEC " + _CRLF
cQry += " 	FROM " + _CRLF 
cQry += " 	( " + _CRLF
cQry += " 		SELECT ZZ5.ZZ5_FILIAL, ZZ5.ZZ5_EQUIPE, ZZ5.ZZ5_DTCHEG, ZZ5.ZZ5_NUMOS, ZZ5.ZZ5_SEQ, COUNT(ZZ5.ZZ5_CODTEC) as QTD_TEC " + _CRLF
cQry += " 		FROM "+RetSqlName("ZZ5")+" ZZ5 INNER JOIN "+RetSqlName("SRA")+" SRA ON ZZ5.ZZ5_CODTEC = SRA.RA_MAT " + _CRLF
cQry += " 									   INNER JOIN "+RetSqlName("SZ4")+" SZ4 ON SZ4.Z4_COD = SRA.RA_SGRPPR " + _CRLF
cQry += " 		WHERE ZZ5.D_E_L_E_T_ = ' ' " + _CRLF
cQry += " 		  AND ZZ5.ZZ5_DTCHEG <> '        ' " + _CRLF
cQry += " 		  AND ZZ5.ZZ5_DTCHEG BETWEEN '"+sPIni+"' AND '"+sPFim+"' " + _CRLF
cQry += " 		  AND SRA.D_E_L_E_T_ = ' ' " + _CRLF
cQry += " 		  AND SZ4.D_E_L_E_T_ = ' ' " + _CRLF
cQry += " 		  AND SRA.RA_CATFUNC = 'M' " + _CRLF 
cQry += " 		  AND (SRA.RA_DEMISSA > '"+sDtAux+"' OR SRA.RA_DEMISSA = '        ') " + _CRLF
cQry += " 		  AND SZ4.Z4_CONS = 'S' " + _CRLF
cQry += " 		GROUP BY ZZ5.ZZ5_FILIAL, ZZ5.ZZ5_EQUIPE, ZZ5.ZZ5_DTCHEG, ZZ5.ZZ5_NUMOS, ZZ5.ZZ5_SEQ " + _CRLF
cQry += " 	) TRB " + _CRLF
cQry += " 	GROUP BY TRB.ZZ5_FILIAL, TRB.ZZ5_EQUIPE, TRB.ZZ5_DTCHEG " + _CRLF
cQry += " ) TRB2 " + _CRLF
cQry += " GROUP BY TRB2.ZZ5_FILIAL, TRB2.ZZ5_EQUIPE " + _CRLF
cQry += " ORDER BY TRB2.ZZ5_FILIAL, TRB2.ZZ5_EQUIPE " + _CRLF

cQry := ChangeQuery(cQry)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "TRBM", .F., .T.)

// Se eu encontrar algum registro do período, não precisa gravar denovo =) 
	If !SZK->(MsSeek( xFilial("SZK") + Right(sPFim,6) ))
	
		While TRBM->(!EoF())
		
		RecLock("SZK", .T.)
			SZK->ZK_FILIAL := xFilial("SZK")
			SZK->ZK_EQUIPE := TRBM->ZZ5_EQUIPE
			SZK->ZK_MESANO := StrTran(cMesAno, '/', '')
			SZK->ZK_QTD    := TRBM->QTD_TEC
		MsUnLock()
		
		TRBM->(dbSkip())
		Enddo
	
	Endif

TRBM->(dbCloseArea())

Return