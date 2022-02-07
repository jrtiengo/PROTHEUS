#Include "rwmake.ch"
#Include "topconn.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FB105PPR ³ Autor ³ Felipe S. Raota             ³ Data ³ 25/06/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Unidade   ³ TRS              ³Contato ³ felipe.raota@totvs.com.br             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera informações na tabela SZJ, posteriormente utilizada nas      ³±±
±±³          ³ funções de cálculo. (Indicadores Equipe H / CR)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para cliente Sirtec - Projeto PPR                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³  Data  ³ Manutencao Efetuada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³  /  /  ³                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function FB105PPR()

Local cTitulo1 := "Índice de Produtividade/Produção Equipe H"
Local cTitulo2 := "Índice de Faturamento Equipe H"
Local cTitulo3 := "Índice de Faturamento Equipe CR/STC"
Local cTitulo4 := "Índice de Produtividade/Produção Equipe CR/STC"

Local cCadastro := "Indicadores de Equipes"  
Local aSays     := {}
Local aButtons  := {}
Local nOpca     := 0

Private cPerg := Padr("FB105PPR", LEN(SX1->X1_GRUPO), " ")

aADD(aSays, "   Este programa tem como objetivo buscar informações de Produção/Produtividade   ")
aADD(aSays, "   e Faturamento das Equipes. Para posteriormente gravar na tabela SZJ.           ") 
aADD(aSays, "                                                                                  ")

aADD(aButtons, {1, .T., {|| (nOpca := 1, FechaBatch()) }})
aADD(aButtons, {2, .T., {|| (nOpca := 2, FechaBatch()) }})

FormBatch(cCadastro, aSays, aButtons)

If nOpca == 1

	_ValidPerg()
	
	If Pergunte(cPerg,.T.)
		If !Empty(MV_PAR03) .AND. !Empty(MV_PAR04) .AND. !Empty(MV_PAR05)
			RptStatus({|| _105PPR01(MV_PAR03, MV_PAR04, MV_PAR05) }, cTitulo1) // Produtividade/Produção Equipe H
		Endif
		If !Empty(MV_PAR03) .AND. !Empty(MV_PAR06)
			RptStatus({|| _105PPR02(MV_PAR03, MV_PAR06) }, cTitulo2) // Faturamento Equipe H
		Endif 
		
		/*
		If !Empty(MV_PAR07) .AND. !Empty(MV_PAR08)
			RptStatus({|| _105PPR02(MV_PAR07, MV_PAR08) }, cTitulo3) // Faturamento Equipe CR
		Endif
		If !Empty(MV_PAR07) .AND. !Empty(MV_PAR09) .AND. !Empty(MV_PAR10)
			RptStatus({|| _105PPR01(MV_PAR07, MV_PAR09, MV_PAR10) }, cTitulo4) // Produtividade/Produção Equipe CR/STC
		Endif
		*/
	Endif

Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _105PPR01  ³ Autor ³ Felipe S. Raota            ³ Data ³ 25/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Busca informações necessárias para Produtividade/Produção.        ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB105PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _105PPR01(_cGrpPPR, _cInd001, _cInd002)

Local cChave1  := ""
Local nHrInter := 0 
Local nHrAtend := 0  
Local nUSSAten := 0
Local nIndFunc := 0  
Local nProdEsp := 0  
Local nIndProd := 0   
Local cEqpDe  
Local cEqpAte  
Local cOSDe   
Local cOSAte   
Local cDatDe  
Local cDatAte 
Local cNomeEqp := ""

Private nTotal1  := 0
Private nTotal2  := 0 
Private nTotal3  := 0

// Monta dados do relatório
_fSTC001(1, _cGrpPPR)

dbSelectArea("_AB9")

SetRegua(RecCount())

_AB9->(dbGoTop())

If _AB9->(!EoF()) 
	TcSQLExec("UPDATE "+RetSqlName("SZJ")+" SET D_E_L_E_T_ = '*' WHERE ZJ_CODGRP = '"+_cGrpPPR+"' AND (ZJ_CODIND = '"+_cInd001+"' OR ZJ_CODIND = '"+_cInd002+"') AND ZJ_MESANO = '"+StrZero(Month(MV_PAR02),2) + Alltrim(Str(Year(MV_PAR02)))+"' ")
Endif

While !_AB9->(EoF())
	
	// CALCULA O INDICE DAS FUNCOES PARA CADA ATENDIMENTO
	_fSTC001(2, _cGrpPPR)
	
	// CALCULA A QUANTIDADE DE USS DO ATENDIMENTO
	_fSTC001(3, _cGrpPPR)
	
	If cChave1 <> _AB9->(AB9_CODTEC)
		cChave1 := _AB9->(AB9_CODTEC)
	Endif
	
	//Calculo das horas
	_fSTC006()
	
	_AB9->(dbSkip())
	
	//Imprime Totais da Equipe
	If cChave1 <> _AB9->(AB9_CODTEC) 
		
		//If nTotal2 >= 1900 // Teste produtividade mínima.
		
			// % Produtividade
			RecLock("SZJ", .T.)
				SZJ->ZJ_FILIAL := xFilial("SZJ")
				SZJ->ZJ_CODGRP := _cGrpPPR
				SZJ->ZJ_CODIND := _cInd001
				SZJ->ZJ_EQUIPE := cChave1
				If nTotal2 >= 1900
					SZJ->ZJ_TOTAL  := Int((Int(nTotal1) / Int(nTotal2)) * 100)
				Else
					SZJ->ZJ_TOTAL  := 0
					U__GrvLogPPR(_cGrpPPR, , cChave1, '      ', 'Produtividade('+Alltrim(Str(nTotal2))+') não atingiu o mínimo de 1900.', , StrZero(Month(MV_PAR02),2))
				Endif
				SZJ->ZJ_MESANO := StrZero(Month(MV_PAR02),2) + Alltrim(Str(Year(MV_PAR02)))
			MsUnLock()
			
		//Endif
		
		// Produção
		RecLock("SZJ", .T.)
			SZJ->ZJ_FILIAL := xFilial("SZJ")
			SZJ->ZJ_CODGRP := _cGrpPPR
			SZJ->ZJ_CODIND := _cInd002
			SZJ->ZJ_EQUIPE := cChave1
			SZJ->ZJ_TOTAL  := nTotal1
			SZJ->ZJ_MESANO := StrZero(Month(MV_PAR02),2) + Alltrim(Str(Year(MV_PAR02)))
		MsUnLock()
		
		// nTotal1 -> Quantidade produzida em USS (Indicador de Produção)
		// nTotal2 -> Meta em USS (Produção)
		// (nTotal1 / nTotal2) -> Indicador de Produtividade
		
		//Zera totais
		nTotal1  := 0
		nTotal2  := 0
		nTotal3  := 0
	Endif

EndDo

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _105PPR02  ³ Autor ³ Felipe S. Raota            ³ Data ³ 25/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Busca informações necessárias para Faturamento.                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB105PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _105PPR02(_cGrpPPR, _cIndFat)

Local cQry := ""
Local _CRLF := Chr(13) + Chr(10)

Local cForn := ""

If Select("TRBF") > 1
	TRBF->(dbCloseArea())
EndIf

cQry := " IF OBJECT_ID(N'PPR_OS_UTIL', N'U') IS NOT NULL " + _CRLF 
cQry += " 	DROP TABLE PPR_OS_UTIL " + _CRLF

cQry += " SELECT DISTINCT SC6.C6_FILIAL, LEFT(SC6.C6_NUMOS,8) as C6_NUMOS " + _CRLF
cQry += " INTO PPR_OS_UTIL " + _CRLF
cQry += " FROM "+RetSqlName("SC6")+" SC6 INNER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON SC5.C5_FILIAL = SC6.C6_FILIAL AND SC5.C5_NUM = SC6.C6_NUM " + _CRLF 
cQry += " WHERE SC6.D_E_L_E_T_ = ' ' " + _CRLF
cQry += "   AND SC6.C6_FILIAL = '"+xFilial("SC6")+"' " + _CRLF
cQry += "   AND SC6.C6_NUMOS <> '' " + _CRLF
cQry += "   AND SC6.C6_ENTREG BETWEEN '"+DtoS(MV_PAR11)+"' AND '"+DtoS(MV_PAR12)+"' " + _CRLF 
cQry += "   AND (ISNULL((SELECT TOP 1 SC6_AGL.C6_NOTA FROM "+RetSqlName("SC6")+" SC6_AGL WITH (NOLOCK) WHERE SC6_AGL.D_E_L_E_T_ = ' ' AND SC6_AGL.C6_NUM = SC5.C5_YPED ORDER BY SC6_AGL.C6_NOTA DESC),'') <> '' OR (SC5.C5_YPED = '' AND SC6.C6_NOTA <> '')) " + _CRLF

MemoWrite("C:\temp\QRY_PPR_BUSCA_01_H.txt", cQry)

TcSQLExec(cQry)
cQry := ''

cQry += " IF OBJECT_ID(N'PPR_OS_EQUIPE', N'U') IS NOT NULL " + _CRLF 
cQry += " 	DROP TABLE PPR_OS_EQUIPE " + _CRLF

cQry += " SELECT DISTINCT AB9.AB9_FILIAL, LEFT(AB9.AB9_NUMOS,6) AS AB9_NUMOS, AB9.AB9_CODTEC " + _CRLF
cQry += " INTO PPR_OS_EQUIPE " + _CRLF
cQry += " FROM PPR_OS_UTIL PPR INNER JOIN "+RetSqlName("AB9")+" AB9 WITH (NOLOCK) ON AB9.AB9_FILIAL = PPR.C6_FILIAL AND LEFT(AB9.AB9_NUMOS,6) = LEFT(PPR.C6_NUMOS,6) " + _CRLF
cQry += " WHERE AB9.D_E_L_E_T_ = ' ' " + _CRLF

MemoWrite("C:\temp\QRY_PPR_BUSCA_02_H.txt", cQry)

TcSQLExec(cQry)
cQry := ''

cQry += " SELECT TRB2.AB9_FILIAL, TRB2.AB9_CODTEC, SUM(TRB2.PED_EQP) as PED_EQP " + _CRLF
cQry += " FROM " + _CRLF
cQry += " ( " + _CRLF

cQry += " 	SELECT *, ROUND((ULT.POR_EQP * 100) / ULT.TOTAL_ABC,2) as PERC_EQP, ROUND((ULT.TOT_PED * (ROUND((ULT.POR_EQP * 100) / ULT.TOTAL_ABC,2)) / 100),2) as PED_EQP " + _CRLF
cQry += " 	FROM " + _CRLF
cQry += " 	( " + _CRLF
cQry += " 		SELECT  FIM.AB9_FILIAL, FIM.AB9_NUMOS, FIM.AB9_CODTEC, " + _CRLF
cQry += " 				CASE " + _CRLF
cQry += " 					WHEN FIM.TOTAL_ABC = 0 AND FIM.TOT_PED > 0 THEN FIM.TOT_PED " + _CRLF
cQry += " 					ELSE FIM.TOTAL_ABC " + _CRLF
cQry += " 				END as TOTAL_ABC, " + _CRLF
cQry += " 				CASE " + _CRLF
cQry += " 					WHEN FIM.TOTAL_ABC = 0 AND FIM.TOT_PED > 0 THEN FIM.TOT_PED / FIM.QTD_EQP " + _CRLF
cQry += " 					ELSE FIM.POR_EQP " + _CRLF
cQry += " 				END as POR_EQP, " + _CRLF
cQry += " 				FIM.TOT_PED, FIM.CODGRP, FIM.QTD_EQP " + _CRLF
cQry += " 		FROM " + _CRLF 
cQry += " 		( " + _CRLF
cQry += " 			SELECT *, ( SELECT COUNT(*) FROM PPR_OS_EQUIPE OS WITH (NOLOCK) WHERE OS.AB9_FILIAL = TAB.AB9_FILIAL AND OS.AB9_NUMOS = TAB.AB9_NUMOS ) as QTD_EQP " + _CRLF
cQry += " 			FROM " + _CRLF
cQry += " 			( " + _CRLF
cQry += " 				SELECT *, " + _CRLF
cQry += " 					ISNULL(( " + _CRLF
cQry += " 					SELECT SUM(ABC.ABC_VALOR) FROM "+RetSqlName("ABC")+" ABC WITH (NOLOCK) WHERE ABC.D_E_L_E_T_ = ' ' AND LEFT(ABC.ABC_NUMOS,6) = TRB.AB9_NUMOS " + _CRLF
cQry += " 					),0) as TOTAL_ABC, " + _CRLF
cQry += " 					ISNULL(( " + _CRLF 
cQry += " 					SELECT SUM(ABC.ABC_VALOR) FROM "+RetSqlName("ABC")+" ABC WITH (NOLOCK) WHERE ABC.D_E_L_E_T_ = ' ' AND LEFT(ABC.ABC_NUMOS,6) = TRB.AB9_NUMOS AND ABC.ABC_CODTEC = TRB.AB9_CODTEC " + _CRLF 
cQry += " 					),0) as POR_EQP, " + _CRLF
cQry += " 					ISNULL(( " + _CRLF 
cQry += " 					SELECT SUM(SC6.C6_VALOR) FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) WHERE SC6.D_E_L_E_T_ = ' ' AND LEFT(SC6.C6_NUMOS,6) = TRB.AB9_NUMOS AND SC6.C6_ENTREG BETWEEN '"+DtoS(MV_PAR11)+"' AND '"+DtoS(MV_PAR12)+"' " + _CRLF 
cQry += " 					),0) as TOT_PED, " + _CRLF
cQry += " 					ISNULL(( " + _CRLF
cQry += " 					SELECT TOP 1 ZZ5_CODGRP " + _CRLF
cQry += " 					FROM "+RetSqlName("ZZ5")+" ZZ5 WITH (NOLOCK) " + _CRLF
cQry += " 					WHERE Left(ZZ5.ZZ5_NUMOS,6) = TRB.AB9_NUMOS " + _CRLF
cQry += " 				  	AND ZZ5.ZZ5_EQUIPE = TRB.AB9_CODTEC " + _CRLF 
cQry += " 				  	AND ZZ5.D_E_L_E_T_ = ' ' " + _CRLF 
cQry += " 				  	AND ZZ5.ZZ5_FILIAL = '"+xFilial("ZZ5")+"' " + _CRLF 
cQry += " 				  	--AND ZZ5.ZZ5_DTCHEG <> '' " + _CRLF 
cQry += " 				  	AND ZZ5.ZZ5_CODGRP <> '' " + _CRLF 
cQry += " 				  	),'') AS CODGRP " + _CRLF
cQry += " 				FROM PPR_OS_EQUIPE TRB " + _CRLF
If !Empty(MV_PAR13)
	cForn := FormatIn(Alltrim(MV_PAR13),";")
	cQry += "   		WHERE ( TRB.AB9_CODTEC IN " + cForn + " )" + _CRLF
Endif
cQry += " 			) TAB " + _CRLF
If !Empty(MV_PAR13)
	cForn := FormatIn(Alltrim(MV_PAR13),";")
	cQry += "   	WHERE ( TAB.CODGRP = '"+_cGrpPPR+"' OR TAB.AB9_CODTEC IN " + cForn + " )" + _CRLF
Else
	cQry += "   	WHERE TAB.CODGRP = '"+_cGrpPPR+"' " + _CRLF
Endif

cQry += " 		)FIM " + _CRLF
cQry += " 	) ULT " + _CRLF

cQry += " ) TRB2 " + _CRLF
cQry += " GROUP BY TRB2.AB9_FILIAL, TRB2.AB9_CODTEC " + _CRLF
cQry += " ORDER BY TRB2.AB9_FILIAL, TRB2.AB9_CODTEC " + _CRLF

MemoWrite("C:\temp\QRY_PPR_BUSCA_03_H.txt", cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"_TRB",.F.,.T.)

COUNT TO nQtdReg
ProcRegua(nQtdReg)
/*
If !_TRB->(EoF())
	/TcSQLExec("UPDATE "+RetSqlName("SZJ")+" SET D_E_L_E_T_ = '*' WHERE ZJ_CODGRP = '"+_cGrpPPR+"' AND ZJ_CODIND = '"+_cIndFat+"' AND ZJ_MESANO = '"+StrZero(Month(MV_PAR02),2) + Alltrim(Str(Year(MV_PAR02)))+"' ")
Endif
*/

TcSQLExec("UPDATE "+RetSqlName("SZJ")+" SET D_E_L_E_T_ = '*' WHERE ZJ_CODGRP = '"+_cGrpPPR+"' AND ZJ_CODIND = '"+_cIndFat+"' AND ZJ_MESANO = '"+StrZero(Month(MV_PAR02),2) + Alltrim(Str(Year(MV_PAR02)))+"' ")

dbSelectArea("_TRB")
_TRB->(dbGoTop()) 
While !_TRB->(EoF()) 
	
	IncProc("Processando Busca Faturamento. Equipe: " + _TRB->AB9_CODTEC)
	
	RecLock("SZJ", .T.)
		SZJ->ZJ_FILIAL := xFilial("SZJ")
		SZJ->ZJ_CODGRP := _cGrpPPR
		SZJ->ZJ_CODIND := _cIndFat
		SZJ->ZJ_EQUIPE := _TRB->AB9_CODTEC
		SZJ->ZJ_TOTAL  := _TRB->PED_EQP
		SZJ->ZJ_MESANO := StrZero(Month(MV_PAR02),2) + Alltrim(Str(Year(MV_PAR02)))
	MsUnLock()
	
	_TRB->(dbSkip())
Enddo

_TRB->(dbCloseArea())

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _fSTC001   ³ Autor ³ Felipe S. Raota            ³ Data ³ 25/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Cria Arquivo de Trabalho com as informações dos indicadores.      ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB105PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _fSTC001(nOpc, _cGrpPPR)

Local cSQL := ""
Local cAB9 := RetSQLName("AB9") + " AB9 "
Local cABC := RetSQLName("ABC") + " ABC "
Local cDA1 := RetSQLName("DA1") + " DA1 "
Local cAA1 := RetSQLName("AA1") + " AA1 "
Local cAA5 := RetSQLName("AA5") + " AA5 "
Local cZZ5 := RetSQLName("ZZ5") + " ZZ5 "
Local cSRJ := RetSQLName("SRJ") + " SRJ "

Local _CRLF := Chr(13) + Chr(10)

Do Case 
	
	Case nOpc == 1
	
		cSQL := " SELECT * " + _CRLF
		cSQL += " FROM " + _CRLF
		cSQL += " ( " + _CRLF
		cSQL += "   SELECT AB9.AB9_FILIAL, AB9.AB9_CODTEC  , AB9.AB9_NUMOS  , AB9.AB9_SEQ  , AB9.AB9_DTCHEG  , AB9.AB9_HRSAID  , AB9.AB9_HRCHEG  , AB9.AB9_YFINT  , AB9.AB9_YIINT, " + _CRLF 
		cSQL += "   ( " + _CRLF
		cSQL += "    SELECT TOP 1 ZZ5_CODGRP " + _CRLF 
		cSQL += "    FROM "+RetSqlName("ZZ5")+" ZZ5 WITH (NOLOCK) " + _CRLF 
		cSQL += "    WHERE ZZ5.ZZ5_NUMOS = AB9.AB9_NUMOS " + _CRLF 
		cSQL += " 	 AND ZZ5.ZZ5_EQUIPE = AB9.AB9_CODTEC " + _CRLF 
		cSQL += " 	 AND ZZ5.D_E_L_E_T_ = ' ' " + _CRLF 
		cSQL += " 	 AND ZZ5.ZZ5_FILIAL = '01' " + _CRLF 
		cSQL += " 	 AND ZZ5.ZZ5_DTCHEG <> '' " + _CRLF 
		cSQL += " 	 AND ZZ5.ZZ5_CODGRP <> '' " + _CRLF 
		cSQL += "   ) AS CODGRP " + _CRLF
		cSQL += "   FROM "+RetSqlName("AB9")+" AB9 " + _CRLF   
		cSQL += "   WHERE AB9.D_E_L_E_T_ = ''   " + _CRLF
		cSQL += "     AND AB9.AB9_FILIAL = '"+xFilial("AB9")+"' " + _CRLF  
		cSQL += "     AND AB9.AB9_DTINI  BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' " + _CRLF  
		cSQL += " ) TRB " + _CRLF
		cSQL += " WHERE TRB.CODGRP = '"+_cGrpPPR+"' " + _CRLF
		
		If !Empty(MV_PAR13)
			cForn := FormatIn(Alltrim(MV_PAR13),";")
			cSQL += "AND TRB.AB9_CODTEC IN " + cForn + _CRLF
		Endif
		
		cSQL += " ORDER BY TRB.AB9_FILIAL,TRB.AB9_CODTEC,TRB.AB9_NUMOS,TRB.AB9_SEQ " + _CRLF
		
		MemoWrite("C:\temp\QRY_PROD01.txt", cSQL)
		
		//Verifica se alias está em uso
		If ChkFile("_AB9")
			dbselectArea("_AB9")
			_AB9->(dbCloseArea())
		EndIf
		
		TcQuery cSQL New Alias "_AB9" 
	
	//CALCULA O INDICE DAS FUNCOES PARA CADA ATENDIMENTO
	Case nOpc == 2
		
		cSQL := " SELECT  " 

		cSQL += " SUM(SRJ.RJ_YMETA) META_FUNCAO " 
		
		cSQL += " FROM " + cZZ5 + " " 
		
		cSQL += " INNER JOIN " + cAB9 + " ON " 
		
		cSQL += "     AB9.D_E_L_E_T_ = '' " 
		cSQL += " AND AB9.AB9_FILIAL = '" + xFilial("AB9") + "' " 
		cSQL += " AND ZZ5.ZZ5_NUMOS  = AB9.AB9_NUMOS " 
		cSQL += " AND ZZ5.ZZ5_EQUIPE = AB9.AB9_CODTEC " 
		cSQL += " AND ZZ5.ZZ5_SEQ    = AB9.AB9_SEQ " 
		cSQL += " AND AB9.AB9_NUMOS  = '" + _AB9->AB9_NUMOS  + "' "
		cSQL += " AND AB9.AB9_CODTEC = '" + _AB9->AB9_CODTEC + "' "
		cSQL += " AND AB9.AB9_SEQ    = '" + _AB9->AB9_SEQ    + "' "
		
		cSQL += " INNER JOIN " + cAA1 + " ON " 
		
		cSQL += "     AA1.D_E_L_E_T_ = '' "
		cSQL += " AND AA1.AA1_FILIAL = '" + xFilial("AA1") + "' " 
		cSQL += " AND AA1.AA1_CODTEC = ZZ5.ZZ5_CODTEC " 
		
		cSQL += " INNER JOIN " + cSRJ + " ON " 
		
		cSQL += "     SRJ.D_E_L_E_T_ = '' " 
		cSQL += " AND SRJ.RJ_FILIAL = '" + xFilial("SRJ") + "' "
		cSQL += " AND SRJ.RJ_FUNCAO  = AA1.AA1_FUNCAO " 
		
		cSQL += " WHERE  " 
		
		cSQL += "     ZZ5.D_E_L_E_T_ = '' " 
		cSQL += " AND ZZ5.ZZ5_FILIAL = '" + xFilial("ZZ5") + "' "
		cSQL += " AND ZZ5.ZZ5_NUMOS  = '" + _AB9->AB9_NUMOS  + "' "
		cSQL += " AND ZZ5.ZZ5_EQUIPE = '" + _AB9->AB9_CODTEC + "' "
		cSQL += " AND ZZ5.ZZ5_SEQ    = '" + _AB9->AB9_SEQ    + "' "
		
		If !Empty(MV_PAR13)
			cForn := FormatIn(Alltrim(MV_PAR13),";")
			cSQL += "AND ZZ5.ZZ5_EQUIPE IN " + cForn + _CRLF
		Endif
		
		MemoWrite("C:\temp\QRY_PROD02.txt", cSQL)
		
		// Verifica se alias está em uso
		If chkfile("_SRJ")
			dbselectArea("_SRJ")
			_SRJ->(dbCloseArea())
		EndIf
		
		TcQuery cSQL New Alias "_SRJ" 

	//CALCULA A QUANTIDADE DE USS DO ATENDIMENTO	
	Case nOpc == 3
		
		cSQL := " SELECT  " 
		
		cSQL += " SUM(ABC.ABC_QUANT*DA1.DA1_YQUSS*(AA5_PRCCLI/100)) USS_ATEND "
		
		cSQL += " FROM " + cABC + " " 
		
		cSQL += " INNER JOIN " + cAB9 + " ON " 
		
		cSQL += "     AB9.D_E_L_E_T_ = '' "
		cSQL += " AND AB9.AB9_FILIAL = '" + xFilial("AB9") + "' " 
		cSQL += " AND ABC.ABC_FILIAL = AB9.AB9_FILIAL " 
		cSQL += " AND ABC.ABC_NUMOS  = AB9.AB9_NUMOS " 
		cSQL += " AND ABC.ABC_CODTEC = AB9.AB9_CODTEC " 
		cSQL += " AND ABC.ABC_SEQ    = AB9.AB9_SEQ " 
		cSQL += " AND AB9.AB9_NUMOS  = '" + _AB9->AB9_NUMOS  + "' "
		cSQL += " AND AB9.AB9_CODTEC = '" + _AB9->AB9_CODTEC + "' "
		cSQL += " AND AB9.AB9_SEQ    = '" + _AB9->AB9_SEQ    + "' "
		
		cSQL += " LEFT OUTER JOIN " + cDA1 + "   ON  " 
		
		cSQL += "     DA1.D_E_L_E_T_ = '' "
		cSQL += " AND DA1.DA1_FILIAL = '" + xFilial("DA1") + "' "  
		cSQL += " AND ABC.ABC_YTABPR = DA1.DA1_CODTAB  	   " 
		cSQL += " AND ABC.ABC_CODPRO = DA1.DA1_CODPRO   " 
		
		cSQL += " LEFT OUTER JOIN " + cAA5 + " ON " 
		
		cSQL += "     AA5.D_E_L_E_T_ = '' " 
		cSQL += " AND AA5.AA5_FILIAL = '" + xFilial("AA5") + "' " 
		cSQL += " AND ABC.ABC_CODSER = AA5.AA5_CODSER   " 
		
		cSQL += " WHERE " 
		
		cSQL += " ABC.D_E_L_E_T_ = '' "                 
		cSQL += " AND ABC.ABC_FILIAL = '" + xFilial("ABC") + "' " 
		cSQL += " AND ABC.ABC_NUMOS  = '" + _AB9->AB9_NUMOS  + "' "
		cSQL += " AND ABC.ABC_CODTEC = '" + _AB9->AB9_CODTEC + "' "
		cSQL += " AND ABC.ABC_SEQ    = '" + _AB9->AB9_SEQ    + "' "	

		If !Empty(MV_PAR13)
			cForn := FormatIn(Alltrim(MV_PAR13),";")
			cSQL += "AND AB9.AB9_CODTEC IN " + cForn + _CRLF
		Endif

		//Log de controle
		MemoWrite("C:\temp\QRY_PROD03.txt", cSQL)
		
		//Verifica se alias está em uso
		If chkfile("_ABC")
			dbselectArea("_ABC")
			_ABC->(dbCloseArea())
		EndIf
		
		//Cria query
		TcQuery cSQL New Alias "_ABC"
EndCase

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _fSTC006   ³ Autor ³ Felipe S. Raota            ³ Data ³ 25/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Calcula totais.                                                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB105PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _fSTC006()

//Horas de intervalo
nHrInter  := SubtHoras(STOD(_AB9->AB9_DTCHEG),_AB9->AB9_YIINT,STOD(_AB9->AB9_DTCHEG),_AB9->AB9_YFINT) 

//Horas de atendimento
nHrAtend := SubtHoras(STOD(_AB9->AB9_DTCHEG),_AB9->AB9_HRCHEG,STOD(_AB9->AB9_DTCHEG),_AB9->AB9_HRSAID) - nHrInter

//Quantidade USS do Atendimento
nUSSAten := NoRound(_ABC->USS_ATEND,2)

//Indice das Funcoes
nIndFunc := NoRound(_SRJ->META_FUNCAO,2)

//Produtividade Esperada
nProdEsp := NoRound((nHrAtend*nIndFunc),2)

//Indice de Produtividade
nIndProd := NoRound((nUSSAten/nProdEsp),2)

//Totais da Equipe
nTotal1 += nUSSAten 
nTotal2 += nProdEsp 
nTotal3 += nIndProd

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _ValidPerg ³ Autor ³ Felipe S. Raota            ³ Data ³ 19/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Valida perguntas.                                                 ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB104PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _ValidPerg()

Local _aArea  := GetArea()
Local _aRegs  := {}
Local _aHelps := {}
Local _i      := 0
Local _j      := 0

// Definicao dos parametros a serem solicitados para o relatorio
_aRegs := {} // Get/Choose

//            Grupo/Ordem/Pergunta                   /Perspa/Pereng/Variável/Tipo/Tamanho/Dec/Presel/GSC/Valid/Var01     /Def01/Defspa1/Defeng1/Cnt01/Var02/Def02/Defspa2/Defeng2/Cnt02/Var03/Def03/Defspa3/Defeng3/Cnt03/Var04/Def04/Defspa4/Defeng4/Cnt4/Var05/Def05/Defspa5/Defeng5/Cnt05/F3/GRPSXG
aAdd(_aRegs, {cPerg,"01","Data de                  ?","",    "",    "MV_CH1","D", 08,     0,  0,     "G","",   "MV_PAR01","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "",    ""})
aAdd(_aRegs, {cPerg,"02","Data até                 ?","",    "",    "MV_CH2","D", 08,     0,  0,     "G","",   "MV_PAR02","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "",    ""})
aAdd(_aRegs, {cPerg,"03","Grupo PPR Equipe H       ?","",    "",    "MV_CH3","C", 06,     0,  0,     "G","",   "MV_PAR03","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "SZ4", ""})
aAdd(_aRegs, {cPerg,"04","Indicador Produtividade H?","",    "",    "MV_CH4","C", 06,     0,  0,     "G","",   "MV_PAR04","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "SZ5", ""})
aAdd(_aRegs, {cPerg,"05","Indicador Produção H     ?","",    "",    "MV_CH5","C", 06,     0,  0,     "G","",   "MV_PAR05","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "SZ5", ""})
aAdd(_aRegs, {cPerg,"06","Indicador Faturamento H  ?","",    "",    "MV_CH6","C", 06,     0,  0,     "G","",   "MV_PAR06","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "SZ5", ""})
aAdd(_aRegs, {cPerg,"07","Grupo PPR Equipe CR/STC  ?","",    "",    "MV_CH7","C", 06,     0,  0,     "G","",   "MV_PAR07","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "SZ4", ""})
aAdd(_aRegs, {cPerg,"08","Indicador Fatur. CR/STC  ?","",    "",    "MV_CH8","C", 06,     0,  0,     "G","",   "MV_PAR08","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "SZ5", ""})
aAdd(_aRegs, {cPerg,"09","Indicador Produtiv CR/STC?","",    "",    "MV_CH9","C", 06,     0,  0,     "G","",   "MV_PAR09","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "SZ5", ""})
aAdd(_aRegs, {cPerg,"10","Indicador Produção CR/STC?","",    "",    "MV_CHA","C", 06,     0,  0,     "G","",   "MV_PAR10","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "SZ5", ""})
aAdd(_aRegs, {cPerg,"11","Data faturamento de      ?","",    "",    "MV_CHB","D", 08,     0,  0,     "G","",   "MV_PAR11","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "",    ""})
aAdd(_aRegs, {cPerg,"12","Data faturamento até     ?","",    "",    "MV_CHC","D", 08,     0,  0,     "G","",   "MV_PAR12","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "",    ""})
aAdd(_aRegs, {cPerg,"13","Equipes H(;)             ?","",    "",    "MV_CHD","C", 99,     0,  0,     "G","",   "MV_PAR13","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "",    ""})

// Definicao de textos de help dos parametros (versao 7.10 em diante): um array para cada linha.
_aHelps := {}

//            Ordem   1234567890123456789012345678901234567890    1234567890123456789012345678901234567890    1234567890123456789012345678901234567890
aAdd(_aHelps, {"01",{"Informe a Data de Processamento inicial ", "                                        ", "                                        "}} )
aAdd(_aHelps, {"02",{"Informe a Data de Processamento final   ", "                                        ", "                                        "}} )

dbSelectArea("SX1")
dbSetOrder(1)

For _i := 1 to len(_aRegs)
	If !dbSeek(cPerg + _aRegs[_i, 2])  // _i = ocorrencia do array  2 = segundo campo dentro daquela ocorrencia, no caso, a "ordem"
		RecLock("SX1", .T.) // lock na tab para INSERT de registro (.T.)
	Else
		RecLock("SX1", .F.) // lock na tab para UPDATE de registro (.F.)
	Endif

	For _j := 1 to FCount() // fcount()=nro. de campos dos regs. desta tabela (sx1)
// Campos CNT nao sao gravados para preservar conteudo anterior.
		If _j <= len(_aRegs[_i]) .and. left(fieldname(_j), 6) != "X1_CNT" .and. fieldname(_j) != "X1_PRESEL"
			FieldPut(_j, _aRegs[_i, _j]) 
		Endif
	Next

	MsUnlock()   // libera lock
Next

// Deleta do SX1 as perguntas que nao constam em _aRegs
dbSeek(cPerg, .T.)
While !EOF() .and. x1_grupo == cPerg
	If aScan(_aRegs, {|_aVal| _aVal[2] == sx1->x1_ordem}) == 0
		RecLock("SX1", .F.)
		dbDelete()
		MsUnlock()
	Endif
	dbSkip()
Enddo

// Gera helps das perguntas
For _i := 1 to Len(_aHelps)
	PutSX1Help("P." + cPerg + _aHelps[_i, 1] + ".", _aHelps[_i, 2], {}, {})
Next

RestArea(_aArea)

Return