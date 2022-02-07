#Include 'Protheus.ch'
#Include 'Topconn.ch'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FB005FUN ³ Autor ³ Felipe S. Raota             ³ Data ³ 27/05/14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Unidade   ³ TRS              ³Contato ³ felipe.raota@totvs.com.br             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função de Busca: 000005. Indicador de Combustível.                ³±±
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

User Function FB005FUN(cEquipe, cMesAno, cTp)

// cTp = "K" - Indicador KM/l
// cTp = "T" - Tipo de Veículo

Local xRet
Local cQry := ""
Local cCRLF := Chr(13) + Chr(10)

Local cPlaca := ""

Local sPIni := ""
Local sPFim := ""

sPIni := MonthSub(CtoD("01/"+cMesAno), 1)
sPIni := Alltrim(Str(Year(sPIni))) + StrZero(Month(sPIni), 2) + '16' 

sPFim := Alltrim(Str(Year(CtoD("01/"+cMesAno)))) + StrZero(Month(CtoD("01/"+cMesAno)), 2) + '15'

If Select("TRB") > 0
	TRB->(dbCloseArea())
Endif

If cTp == "K"
	xRet := 0
ElseIf cTp == "T"
	xRet := ""
Endif

cQry := " SELECT TOP 1 TRB2.*, ST9.T9_PLACA, ST9.T9_CODFAMI " + cCRLF
cQry += " FROM " + cCRLF
cQry += " ( " + cCRLF
cQry += " 	SELECT TRB.ZZ5_FILIAL, TRB.ZZ5_CODTEC, TRB.AA1_BEM, COUNT(*) as QTD_USO " + cCRLF
cQry += " 	FROM " + cCRLF
cQry += " 	( " + cCRLF
cQry += " 		SELECT DISTINCT ZZ5.ZZ5_FILIAL, ZZ5.ZZ5_CODTEC, ZZ5.ZZ5_NUMOS, ZZ5.ZZ5_DTCHEG, AA1.AA1_STPINT, AA1.AA1_BEM " + cCRLF
cQry += " 		FROM "+RetSqlName("ZZ5")+" ZZ5 INNER JOIN "+RetSqlName("AA1")+" AA1 ON AA1.AA1_CODTEC = ZZ5.ZZ5_CODTEC " + cCRLF
cQry += " 		WHERE ZZ5.D_E_L_E_T_ = ' ' " + cCRLF
cQry += " 		  AND AA1.D_E_L_E_T_ = ' ' " + cCRLF
cQry += " 		  AND AA1.AA1_FILIAL = ' ' " + cCRLF
cQry += " 		  AND ZZ5.ZZ5_FILIAL = '"+xFilial("ZZ5")+"' " + cCRLF
cQry += " 		  AND ZZ5.ZZ5_EQUIPE = '"+cEquipe+"' " + cCRLF
cQry += " 		  AND ZZ5.ZZ5_DTCHEG BETWEEN '"+sPIni+"' AND '"+sPFim+"' " + cCRLF
cQry += " 		  AND AA1.AA1_STPINT = '2' " + cCRLF
cQry += " 	) TRB " + cCRLF
cQry += " 	GROUP BY TRB.ZZ5_FILIAL, TRB.ZZ5_CODTEC, TRB.AA1_BEM " + cCRLF
cQry += " ) TRB2 INNER JOIN "+RetSqlName("ST9")+" ST9 ON ST9.T9_FILIAL = TRB2.ZZ5_FILIAL AND ST9.T9_CODBEM = TRB2.AA1_BEM " + cCRLF
cQry += " ORDER BY TRB2.QTD_USO DESC " + cCRLF

//MemoWrite("C:\temp\qry1_combustivel.txt", cQry)

cQry := ChangeQuery(cQry)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "TRB", .F., .T.) 

If !TRB->(EoF())
	
	If cTp == "K"
		
		cPlaca := TRB->T9_PLACA
		
		If Select("TRB2") > 0
			TRB2->(dbCloseArea()) 
		Endif
		
		cQry := " SELECT MIN(TRB.TR6_KMABAS) as KMINI, MAX(TRB.TR6_KMABAS) as KMFIM, SUM(TRB.TR6_QTDCOM) as LITROS, " + cCRLF
		cQry += " 	(SELECT TOP 1 TR6I.TR6_KMABAS FROM "+RetSqlName("TR6")+" TR6I WHERE TR6I.D_E_L_E_T_ = ' ' AND TR6I.TR6_FILIAL = ' ' AND TR6I.TR6_PLACA = '"+cPlaca+"' AND TR6I.TR6_DTABAS < '"+sPIni+"' ORDER BY TR6I.TR6_DTABAS DESC) as KMINI_ANTES, " + cCRLF
		cQry += " 	(SELECT TOP 1 TR6F.TR6_KMABAS FROM "+RetSqlName("TR6")+" TR6F WHERE TR6F.D_E_L_E_T_ = ' ' AND TR6F.TR6_FILIAL = ' ' AND TR6F.TR6_PLACA = '"+cPlaca+"' AND TR6F.TR6_DTABAS > '"+sPFim+"' ORDER BY TR6F.TR6_DTABAS ASC) as KMFIM_DEPOIS " + cCRLF
		cQry += " FROM " + cCRLF
		cQry += " ( " + cCRLF
		cQry += " 	SELECT TR6.TR6_PLACA, TR6.TR6_KMABAS, TR6.TR6_QTDCOM, TR6.TR6_DTABAS " + cCRLF
		cQry += " 	FROM "+RetSqlName("TR6")+" TR6 " + cCRLF
		cQry += " 	WHERE TR6.D_E_L_E_T_ = ' ' " + cCRLF
		cQry += " 	  AND TR6.TR6_DTABAS BETWEEN '"+sPIni+"' AND '"+sPFim+"' " + cCRLF
		cQry += " 	  AND TR6.TR6_PLACA = '"+cPlaca+"' " + cCRLF
		cQry += " ) TRB " + cCRLF 
		
		//MemoWrite("C:\temp\qry2_combustivel.txt", cQry) 
		
		cQry := ChangeQuery(cQry)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "TRB2", .F., .T.)
		
		If !TRB2->(EoF())
			xRet := (TRB2->KMFIM_DEPOIS - TRB2->KMINI_ANTES) / TRB2->LITROS
			If xRet < 0
				xRet := 0
			Endif
			If xRet > 199
				U__GrvLogPPR(SZD->ZD_CODGRP, SZD->ZD_MAT, SZD->ZD_EQUIPE, SZ5->Z5_COD, 'Verifique! Indicador de combustível muito elevado.', _cCodCalc, SZD->ZD_MESCALC)
			Endif
		Endif
	
	ElseIf cTp == "T"
		xRet := TRB->T9_CODFAMI 
	Endif
	
Endif

If Empty(xRet)
	_cRefLog := cPlaca 
Endif

Return xRet