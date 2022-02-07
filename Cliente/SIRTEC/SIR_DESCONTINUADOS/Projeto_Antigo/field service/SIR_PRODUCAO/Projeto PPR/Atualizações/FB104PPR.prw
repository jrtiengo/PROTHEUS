#Include 'Totvs.ch'
#Include 'Topconn.ch'
#Include "Poncalen.ch" 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FB104PPR ³ Autor ³ Felipe S. Raota             ³ Data ³ 19/06/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Unidade   ³ TRS              ³Contato ³ felipe.raota@totvs.com.br             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera informações na tabela SZJ, posteriormente utilizada nas      ³±±
±±³          ³ funções de cálculo. EQUIPE A                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para cliente Sirtec - Projeto PPR                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³  Data  ³ Manutencao Efetuada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³  /  /  ³                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function FB104PPR()

Local cCadastro := "Indicadores de Equipes" 
Local aSays     := {}
Local aButtons  := {}
Local nOpca     := 0

Private cPerg := PADR("FB104PPR", LEN(SX1->X1_GRUPO)," ")

Private _aErroHora := {}
Private _aFator := {}
Private _aDados := {}

aADD(aSays, "   Este programa tem como objetivo buscar informações de Produção/Produtividade   ")
aADD(aSays, "   e Faturamento das Equipes. Para posteriormente gravar na tabela SZJ.           ")
aADD(aSays, "                                                                                  ")

aADD(aButtons, {1, .T., {|| (nOpca := 1, FechaBatch()) }})
aADD(aButtons, {2, .T., {|| (nOpca := 2, FechaBatch()) }})

FormBatch(cCadastro, aSays, aButtons)

If nOpca == 1
	
	// Gera Arq. Trab. temporário para OS's
	_GeraTrab() 
	
	// Gera Arq. Trab. temporário para Horas Trabalhadas por Dia
	_GeraTrab2()
	
	// Gera Parâmetros
	_ValidPerg()
	
	If Pergunte(cPerg,.T.) 
		
		MakeSqlExpr(cPerg)
		
		// DEVO RODAR ESSE ANTES POIS ELA CRIA UMA TABELA INTERMEDIARIA
		Processa({|| _ExecQFat() }, "Aguarde...", "Efetuando Busca de informações.", .T.)
		
		// Executa consulta que retorna totais por Equipe
		Processa({|| _ExecQuery() }, "Aguarde...", "Efetuando Busca de informações.", .T.)
		
		// Gera vetor dos Fatores por Técnico. 
		_GeraVet()
		
		// Busca Horas Trabalhadas dos técnicos através do Registro do Ponto
		Processa({|| _HorasTrab() }, "Aguarde...", "Buscando Horas Trabalhadas.", .T.)
		
		// Agrupa informações p/ técnico
		Processa({|| _AgrupaInf() }, "Aguarde...", "Gerando informações p/ Equipes.", .T.)
		
		dbSelectArea("SZJ") 
		SZJ->(dbSetOrder(1))
		
		If len(_aDados) > 0
			TcSQLExec("UPDATE "+RetSqlName("SZJ")+" SET D_E_L_E_T_ = '*' WHERE ZJ_CODGRP = '"+MV_PAR03+"' AND (ZJ_CODIND = '"+MV_PAR04+"' OR ZJ_CODIND = '"+MV_PAR05+"') AND ZJ_MESANO = '"+StrZero(Month(MV_PAR02),2) + Alltrim(Str(Year(MV_PAR02)))+"' ")
		Endif 
		
		For _x:=1 to len(_aDados)
			
			// % Produtividade 
			RecLock("SZJ", .T.)
				SZJ->ZJ_FILIAL := xFilial("SZJ")
				SZJ->ZJ_CODGRP := MV_PAR03
				SZJ->ZJ_CODIND := MV_PAR04
				SZJ->ZJ_EQUIPE := _aDados[_x,2]
				SZJ->ZJ_TOTAL  := _aDados[_x,7]
				SZJ->ZJ_MESANO := StrZero(Month(MV_PAR02),2) + Alltrim(Str(Year(MV_PAR02))) 
			MsUnLock()
			
		Next 
		
		dbSelectArea("TRFT")
		TRFT->(dbGoTop())
		
		While !TRFT->(EoF())
		
			// Valor Faturado
			RecLock("SZJ", .T.)
				SZJ->ZJ_FILIAL := xFilial("SZJ")
				SZJ->ZJ_CODGRP := MV_PAR03
				SZJ->ZJ_CODIND := MV_PAR05
				SZJ->ZJ_EQUIPE := TRFT->EQUIPE
				SZJ->ZJ_TOTAL  := TRFT->FAT_TOT
				SZJ->ZJ_MESANO := StrZero(Month(MV_PAR02),2) + Alltrim(Str(Year(MV_PAR02))) 
			MsUnLock()
			
			TRFT->(dbSkip())
		Enddo 
		
		If len(_aErroHora) > 0
			Alert("Algumas datas estão com o Registro do Ponto incorreto, verifique em seguida.")
			U_ShowArray(_aErroHora)
		Endif
		
		//U_ShowArray(_aDados)
		
	Endif
	
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GeraTrab  ³ Autor ³ Felipe S. Raota            ³ Data ³ 19/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Cria Arquivo de Trabalho temporário.                              ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB104PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GeraTrab()

Local aCampos := {}
Local aCampos2 := {}

// Tabela para Produtividade
aADD(aCampos,{"FILIAL"  ,"C",TamSX3("ZZ5_FILIAL")[1],0})
aADD(aCampos,{"EQUIPE"  ,"C",TamSX3("ZZ5_EQUIPE")[1],0})
aADD(aCampos,{"CODTEC"  ,"C",TamSX3("ZZ5_CODTEC")[1],0})
aADD(aCampos,{"NUMOS"   ,"C",TamSX3("ZZ5_NUMOS")[1],0})
aADD(aCampos,{"SEQ"     ,"C",TamSX3("ZZ5_SEQ")[1],0})
aADD(aCampos,{"DTCHEG"  ,"C",TamSX3("ZZ5_DTCHEG")[1],0})
aADD(aCampos,{"HOR_EQP" ,"N",TamSX3("ABC_VALOR")[1],TamSX3("ABC_VALOR")[2]})
aADD(aCampos,{"FAT_TOT" ,"N",TamSX3("ABC_VALOR")[1],TamSX3("ABC_VALOR")[2]})
aADD(aCampos,{"EQP_DIA" ,"N",3,0})

If Select("TRB") > 1
	TRB->(dbCloseArea())
EndIf

cArqTrb := CriaTrab(aCampos,.T.)
cNtxTmp := CriaTrab(, .F.) + OrdBagExt()

DbUseArea(.T.,,cArqTrb,"TRB",.F.)
dbCreateIndex( cNtxTmp, "FILIAL+CODTEC+DTCHEG", { || FILIAL+CODTEC+DTCHEG }, .F. ) 

// Tabela para Faturamento
aADD(aCampos2,{"FILIAL"  ,"C",TamSX3("ZZ5_FILIAL")[1],0})
aADD(aCampos2,{"EQUIPE"  ,"C",TamSX3("ZZ5_EQUIPE")[1],0})
aADD(aCampos2,{"FAT_TOT" ,"N",TamSX3("ABC_VALOR")[1],TamSX3("ABC_VALOR")[2]})
aADD(aCampos2,{"HOR_TOT" ,"N",TamSX3("ABC_QUANT")[1],TamSX3("ABC_QUANT")[2]})

If Select("TRFT") > 1
	TRFT->(dbCloseArea())
EndIf

cArqTrb := CriaTrab(aCampos2,.T.)
cNtxTmp := CriaTrab(, .F.) + OrdBagExt()

DbUseArea(.T.,,cArqTrb,"TRFT",.F.)
dbCreateIndex( cNtxTmp, "FILIAL+EQUIPE", { || FILIAL+EQUIPE }, .F. ) 

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GeraTrab2 ³ Autor ³ Felipe S. Raota            ³ Data ³ 21/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Cria Arquivo de Trabalho temporário para Horas/Dia dos técnicos.  ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB104PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GeraTrab2()

Local aCampos := {}

//Cria arquivo temporário   		    
aADD(aCampos,{"FILIAL" ,"C",TamSX3("P8_FILIAL")[1],0})
aAdd(aCampos,{"MAT"    ,"C",TamSX3("P8_MAT")[1],0})
aAdd(aCampos,{"DTPON"  ,"C",TamSX3("P8_DATA")[1],0})
aAdd(aCampos,{"HORA"   ,"N",TamSX3("P8_HORA")[1],TamSX3("P8_HORA")[2]})

If Select("ARQTRB")>1                     
	ARQTRB->(DbCloseArea())
EndIf 

ARQTRB := CriaTrab(aCampos,.T.)
DbUseArea(.T.,,ARQTRB,"ARQTRB",.F.)   

cNtxTmp2 := CriaTrab(, .F.) + OrdBagExt()
dbCreateIndex( cNtxTmp2, "FILIAL+MAT+DTPON", { || FILIAL+MAT+DTPON }, .F.  ) 

dbSelectArea("ARQTRB") 

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GeraVet   ³ Autor ³ Felipe S. Raota            ³ Data ³ 24/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Gera vetor com as informações de fator por Técnico.               ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB104PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GeraVet()

Local nPos := 0
Local nFator := 0
Local nDiasTot := DateDiffDay(MV_PAR01, MV_PAR02) + 1

cQry := " SELECT * "
cQry += " FROM PPR_DIAS_TRAB_POR_EQUIPE "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"FAT",.F.,.T.)

While FAT->(!EoF())
	
	If FAT->QTD_DIAS_EQP == nDiasTot 
		nFator := 1
	Else
		nFator := FAT->QTD_DIAS_EQP / nDiasTot
	Endif
	
	aADD(_aFator, { FAT->EQUIPE, FAT->TECNICO, Round(nFator,2) })  
	
	FAT->(dbSkip())
Enddo

FAT->(dbCloseArea())

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _ExecQFat  ³ Autor ³ Felipe S. Raota            ³ Data ³ 19/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Cria Arquivo de Trabalho temporário.                              ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB104PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _ExecQFat()

Local cQry := ""
Local _CRLF := Chr(13) + Chr(10) 

If Select("TRBF") > 1
	TRBF->(dbCloseArea())
EndIf

// Gero tabela com todas as OS's à considerar no período.
cQry := " IF OBJECT_ID(N'PPR_OS_CONSIDERAR', N'U') IS NOT NULL " + _CRLF
cQry += " 	DROP TABLE PPR_OS_CONSIDERAR " + _CRLF

cQry += " SELECT * " + _CRLF
cQry += " INTO PPR_OS_CONSIDERAR " + _CRLF
cQry += " FROM " + _CRLF
cQry += " ( " + _CRLF
cQry += " 	SELECT *,( " + _CRLF
cQry += " 			  SELECT TOP 1 ZZ5_CODGRP " + _CRLF
cQry += " 			  FROM "+RetSqlName("ZZ5")+" ZZ5 WITH (NOLOCK) " + _CRLF
cQry += " 			  WHERE ZZ5.ZZ5_NUMOS = TRB.AB9_NUMOS " + _CRLF
cQry += " 				AND ZZ5.ZZ5_EQUIPE = TRB.AB9_CODTEC " + _CRLF
cQry += " 				AND ZZ5.D_E_L_E_T_ = ' ' " + _CRLF
cQry += " 				AND ZZ5.ZZ5_FILIAL = '"+xFilial("ZZ5")+"' " + _CRLF
cQry += " 				AND ZZ5.ZZ5_DTCHEG <> '' " + _CRLF
cQry += " 				AND ZZ5.ZZ5_CODGRP <> '' " + _CRLF
cQry += " 			  ) AS CODGRP " + _CRLF
cQry += " 	FROM " + _CRLF
cQry += " 	( " + _CRLF

cQry += " 		SELECT DISTINCT TRB.AB9_FILIAL, TRB.AB9_NUMOS, TRB.AB9_CODTEC " + _CRLF 
cQry += " 		FROM " + _CRLF 
cQry += " 		( " + _CRLF
cQry += " 			SELECT *, (SELECT TOP 1 SC6_AGL.C6_NOTA FROM "+RetSqlName("SC6")+" SC6_AGL WITH (NOLOCK) WHERE SC6_AGL.D_E_L_E_T_ = ' ' AND SC6_AGL.C6_NUM = AUX.C5_YPED ORDER BY SC6_AGL.C6_NOTA DESC) as NF " + _CRLF
cQry += " 			FROM " + _CRLF
cQry += " 			( " + _CRLF
cQry += " 				SELECT DISTINCT AB9.AB9_FILIAL, AB9.AB9_NUMOS, AB9.AB9_CODTEC, SC5.C5_YPED, SC6.C6_NOTA " + _CRLF
cQry += " 				FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) INNER JOIN "+RetSqlName("AB9")+" AB9 WITH (NOLOCK) ON Left(SC6.C6_NUMOS,6) = Left(AB9.AB9_NUMOS,6) " + _CRLF
cQry += " 		                                             	 	 INNER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON SC5.C5_FILIAL = SC6.C6_FILIAL AND SC5.C5_NUM = SC6.C6_NUM " + _CRLF
cQry += " 				WHERE AB9.AB9_FILIAL = '"+xFilial("AB9")+"' " + _CRLF
cQry += " 		  	  	  AND AB9.D_E_L_E_T_ = ' ' " + _CRLF
cQry += " 		  	      AND SC6.C6_FILIAL = '"+xFilial("SC6")+"' " + _CRLF
cQry += " 		  	      AND SC6.D_E_L_E_T_ = ' ' " + _CRLF
cQry += " 		  	      AND SC6.C6_ENTREG BETWEEN '"+DtoS(MV_PAR06)+"' AND '"+DtoS(MV_PAR07)+"' " + _CRLF
cQry += " 		  	      AND SC6.C6_NUMOS <> '' " + _CRLF
cQry += " 		  	      AND AB9.AB9_DTCHEG BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' " + _CRLF
If !Empty(MV_PAR08)
	cQry += " 	  	      AND " +StrTran(MV_PAR08,'AB9_CODTEC','AB9.AB9_CODTEC') + _CRLF
Endif
cQry += " 			) AUX " + _CRLF
cQry += " 		) TRB " + _CRLF
cQry += " 		WHERE (TRB.NF <> '' OR (TRB.C5_YPED = '' AND TRB.C6_NOTA <> '')) " + _CRLF 
cQry += " 	) TRB " + _CRLF
cQry += " ) FIM " + _CRLF
cQry += " WHERE FIM.CODGRP = '"+MV_PAR03+"' " + _CRLF 

MemoWrite("C:\temp\QRY_PPR_BUSCA_01.txt", cQry)

TcSQLExec(cQry)
cQry := ''

// ALTERAR O ZERO PELO CAMPO CRIADO NA SB1
// Calculo Faturamento e Horas totais
cQry += " SELECT FAT.AB9_FILIAL, FAT.AB9_CODTEC, ISNULL(SUM(CASE SB1.B1_SCALCFA WHEN 'N' THEN 0 ELSE ABC.ABC_VALOR END ),0) as FAT_TOTAL, ISNULL(SUM(CASE SB1.B1_SCALCP WHEN 'N' THEN 0 ELSE ABC.ABC_QUANT END ),0) as HR_TOTAL " + _CRLF 
cQry += " FROM " + _CRLF
cQry += " ( " + _CRLF
cQry += " 	SELECT * FROM PPR_OS_CONSIDERAR " + _CRLF
cQry += " ) FAT LEFT JOIN "+RetSqlName("ABC")+" ABC WITH (NOLOCK) ON FAT.AB9_FILIAL = ABC.ABC_FILIAL AND FAT.AB9_NUMOS = ABC.ABC_NUMOS AND FAT.AB9_CODTEC = ABC.ABC_CODTEC " + _CRLF
cQry += " 	    INNER JOIN "+RetSqlName("SB1")+" SB1 ON ABC.ABC_FILIAL = SB1.B1_FILIAL AND ABC.ABC_CODPRO = SB1.B1_COD " + _CRLF
cQry += " WHERE ABC.ABC_FILIAL = '01' " + _CRLF
cQry += "   AND ABC.D_E_L_E_T_ = ' ' " + _CRLF
cQry += "   AND SB1.B1_FILIAL = '01' " + _CRLF
cQry += "   AND SB1.D_E_L_E_T_ = ' ' " + _CRLF
If !Empty(MV_PAR08)
	cQry += "   AND " +StrTran(MV_PAR08,'AB9_CODTEC','FAT.AB9_CODTEC') + _CRLF
Endif
cQry += " GROUP BY FAT.AB9_FILIAL, FAT.AB9_CODTEC " + _CRLF
cQry += " ORDER BY FAT.AB9_CODTEC " + _CRLF

MemoWrite("C:\temp\QRY_PPR_BUSCA_02.txt", cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRBF",.F.,.T.)

COUNT TO nQtdReg
ProcRegua(nQtdReg)

TRBF->(dbGoTop())
While TRBF->(!EoF()) 
	
	IncProc("Processando Busca Faturamento. Equipe: " + TRBF->AB9_CODTEC)
	
	RecLock("TRFT", .T.)
		
		TRFT->FILIAL  := TRBF->AB9_FILIAL
		TRFT->EQUIPE  := TRBF->AB9_CODTEC
		TRFT->FAT_TOT := TRBF->FAT_TOTAL
		TRFT->HOR_TOT := TRBF->HR_TOTAL
		
	MsUnLock()
	
	TRBF->(dbSkip())
Enddo

TRBF->(dbCloseArea())

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _ExecQuery ³ Autor ³ Felipe S. Raota            ³ Data ³ 19/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Cria Arquivo de Trabalho temporário.                              ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB104PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _ExecQuery()

Local cQry := ""
Local _CRLF := Chr(13) + Chr(10)

Local nQtdReg := 0

// *********************************************************
// Gero tabela com a formação de equipes por dia do período
// *********************************************************
cQry := " IF OBJECT_ID(N'PPR_FATOR_EQUIPE', N'U') IS NOT NULL " + _CRLF
cQry += " 	DROP TABLE PPR_FATOR_EQUIPE " + _CRLF

cQry += " SELECT DISTINCT ZZ5.ZZ5_EQUIPE as EQUIPE, ZZ5.ZZ5_CODTEC as TECNICO, ZZ5.ZZ5_DTCHEG as DATACHEG " + _CRLF
cQry += " INTO PPR_FATOR_EQUIPE " + _CRLF
cQry += " FROM PPR_OS_CONSIDERAR TRB INNER JOIN "+RetSqlName("ZZ5")+" ZZ5 ON TRB.AB9_FILIAL = ZZ5_FILIAL AND TRB.AB9_NUMOS = ZZ5_NUMOS AND TRB.AB9_CODTEC = ZZ5.ZZ5_EQUIPE " + _CRLF
cQry += " 						     INNER JOIN "+RetSqlName("SRA")+" SRA ON ZZ5.ZZ5_CODTEC = SRA.RA_MAT " + _CRLF
cQry += " WHERE ZZ5.ZZ5_FILIAL = '01' " + _CRLF
cQry += "   AND ZZ5.D_E_L_E_T_ = ' ' " + _CRLF
cQry += "   AND SRA.RA_FILIAL = '01' " + _CRLF
cQry += "   AND SRA.D_E_L_E_T_ = ' ' " + _CRLF
cQry += "   AND ZZ5.ZZ5_DTCHEG <> '        ' " + _CRLF 
cQry += "   AND ZZ5.ZZ5_DTCHEG BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' " + _CRLF 
If !Empty(MV_PAR08)
	cQry += " 	AND " +StrTran(MV_PAR08,'AB9_CODTEC','TRB.AB9_CODTEC') + _CRLF
Endif
cQry += " ORDER BY ZZ5.ZZ5_EQUIPE, ZZ5.ZZ5_DTCHEG " + _CRLF

MemoWrite("C:\temp\QRY_PPR_BUSCA_03.txt", cQry)

TcSQLExec(cQry)
cQry := ''

// ************************************************************
// Busco quantidade de equipes trabalhada por técnico, por dia
// ************************************************************
cQry += " IF OBJECT_ID(N'PPR_FATOR_POR_EQUIPE', N'U') IS NOT NULL " + _CRLF
cQry += " 	DROP TABLE PPR_FATOR_POR_EQUIPE " + _CRLF

cQry += " SELECT DISTINCT FAT.TECNICO, FAT.DATACHEG, " + _CRLF
cQry += " 	( " + _CRLF
cQry += " 	 SELECT COUNT(*) " + _CRLF
cQry += " 	 FROM PPR_FATOR_EQUIPE TRB " + _CRLF
cQry += " 	 WHERE TRB.TECNICO = FAT.TECNICO " + _CRLF
cQry += " 	   AND TRB.DATACHEG = FAT.DATACHEG " + _CRLF
cQry += " 	) as QTD_EQP " + _CRLF
cQry += " INTO PPR_FATOR_POR_EQUIPE " + _CRLF
cQry += " FROM PPR_FATOR_EQUIPE FAT " + _CRLF
cQry += " ORDER BY FAT.TECNICO, FAT.DATACHEG " + _CRLF

MemoWrite("C:\temp\QRY_PPR_BUSCA_04.txt", cQry)

TcSQLExec(cQry)
cQry := ''

// ***********************************************
// Busco quantidade de dias trabalhado por equipe
// ***********************************************
cQry += " IF OBJECT_ID(N'PPR_DIAS_TRAB_POR_EQUIPE', N'U') IS NOT NULL " + _CRLF
cQry += " 	DROP TABLE PPR_DIAS_TRAB_POR_EQUIPE " + _CRLF

cQry += " SELECT * " + _CRLF
cQry += " INTO PPR_DIAS_TRAB_POR_EQUIPE " + _CRLF
cQry += " FROM " + _CRLF 
cQry += " ( " + _CRLF
cQry += " 	SELECT DISTINCT FAT.EQUIPE, FAT.TECNICO, " + _CRLF 
cQry += " 		( " + _CRLF
cQry += " 		 SELECT COUNT(*) " + _CRLF
cQry += " 		 FROM PPR_FATOR_EQUIPE FAT2 " + _CRLF
cQry += " 		 WHERE FAT2.EQUIPE = FAT.EQUIPE " + _CRLF
cQry += " 		   AND FAT2.TECNICO = FAT.TECNICO " + _CRLF
cQry += " 		) as QTD_DIAS_EQP " + _CRLF

cQry += " 	FROM PPR_FATOR_EQUIPE FAT " + _CRLF
cQry += " ) TRB " + _CRLF
cQry += " ORDER BY TRB.EQUIPE, TRB.TECNICO " + _CRLF

MemoWrite("C:\temp\QRY_PPR_BUSCA_05.txt", cQry)

TcSQLExec(cQry)
cQry := ''

// ***********************
// Retorno de Informações
// ***********************
cQry += " SELECT ZZ5.ZZ5_FILIAL, ZZ5.ZZ5_EQUIPE, ZZ5.ZZ5_CODTEC, ZZ5.ZZ5_NUMOS, ZZ5.ZZ5_SEQ, ZZ5.ZZ5_DTCHEG, " + _CRLF 
cQry += " 		( " + _CRLF
cQry += " 		 SELECT FATOR.QTD_EQP " + _CRLF
cQry += " 		 FROM PPR_FATOR_POR_EQUIPE FATOR " + _CRLF
cQry += " 		 WHERE FATOR.TECNICO = ZZ5.ZZ5_CODTEC " + _CRLF
cQry += " 		   AND FATOR.DATACHEG = ZZ5.ZZ5_DTCHEG " + _CRLF
cQry += " 		) as QTD_EQP " + _CRLF

cQry += " FROM PPR_OS_CONSIDERAR TRB INNER JOIN "+RetSqlName("ZZ5")+" ZZ5 ON TRB.AB9_FILIAL = ZZ5_FILIAL AND TRB.AB9_NUMOS = ZZ5_NUMOS AND TRB.AB9_CODTEC = ZZ5.ZZ5_EQUIPE " + _CRLF
cQry += " 				             INNER JOIN "+RetSqlName("SRA")+" SRA ON ZZ5.ZZ5_CODTEC = SRA.RA_MAT " + _CRLF
cQry += " WHERE ZZ5.ZZ5_FILIAL = '01' " + _CRLF
cQry += "   AND ZZ5.D_E_L_E_T_ = ' ' " + _CRLF
cQry += "   AND SRA.RA_FILIAL = '01' " + _CRLF
cQry += "   AND SRA.D_E_L_E_T_ = ' ' " + _CRLF
cQry += "   AND ZZ5.ZZ5_DTCHEG <> '        ' " + _CRLF 
cQry += "   AND ZZ5.ZZ5_DTCHEG BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' " + _CRLF 
cQry += " ORDER BY ZZ5.ZZ5_DTCHEG " + _CRLF

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"IND",.F.,.T.) 
TCSetField ("IND", "ZZ5_DTCHEG", "D")

COUNT TO nQtdReg
ProcRegua(nQtdReg)

IND->(dbGoTop())

While IND->(!EoF())
	
	IncProc("Processando Data: " + DtoC(IND->ZZ5_DTCHEG))
	
	RecLock("TRB", .T.)
		
		TRB->FILIAL  := IND->ZZ5_FILIAL
		TRB->EQUIPE  := IND->ZZ5_EQUIPE
		TRB->CODTEC  := IND->ZZ5_CODTEC
		TRB->NUMOS   := IND->ZZ5_NUMOS
		TRB->SEQ     := IND->ZZ5_SEQ
		TRB->DTCHEG  := DtoS(IND->ZZ5_DTCHEG)
		TRB->HOR_EQP := 0
		TRB->FAT_TOT := 0
		TRB->EQP_DIA := IND->QTD_EQP 
		
	MsUnLock()
	
	IND->(dbSkip())
Enddo

IND->(dbCloseArea())

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _HorasTrab ³ Autor ³ Felipe S. Raota            ³ Data ³ 19/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Verifica ponto dos técnicos para saber as horas trabalhadas em    ³±±
±±³          ³ cada Ordem de Serviço.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB104PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _HorasTrab()

// Define Variaveis Locais (Basicas)
Local aArea       := GetArea()
Local cString     := 'SRA'
Local wnRel       := ""
Local aFilesOpen  :={"SP5", "SPN", "SP8", "SPG","SPB","SPL","SPC", "SPH", "SPF"}
Local bCloseFiles := {|cFiles| If( Select(cFiles) > 0, (cFiles)->( DbCloseArea() ), NIL) }

// Define Variaveis Private(Basicas)
Private aReturn  := {'Zebrado' , 1, 'Administracao' , 2, 2, 1, '',1 }
Private nomeprog := "FB104PPR"
Private nLastKey := 0

// Define variaveis Private utilizadas no programa RDMAKE ImpEsp
Private aImp      := {}
Private _aTotal   := {}
Private aTotais   := {}
Private aAbonados := {}
Private nImpHrs   := 0

// Variaveis Utilizadas na funcao IMPR
Private Titulo   := OemToAnsi('Horas trabalhadas p/ Dia' )
Private nTamanho := 'P'

// Define Variaveis Private(Programa)
Private dPerIni  := Ctod("//")
Private dPerFim  := Ctod("//")
Private cMenPad1 := Space(30)
Private cMenPad2 := Space(19)
Private cIndCond := ''
Private cFilSPA	 := IF(Empty(xFilial("SPA")),Space(02),SRA->RA_FILIAL)
Private cFor     := ''
Private nOrdem   := 0
Private cAponFer := ''
Private aInfo    := {}
Private aTurnos  := {}
Private aPrtTurn := {}
Private nColunas := 0
Private dEnvIni  := Ctod("//")
Private dEnvFim  := Ctod("//")

Private lTerminal := .F.

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Parametro MV_COLMARC										   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nColunas := SuperGetmv("MV_COLMARC")
IF ( nColunas == NIL )
	Help("", 1, "MVCOLNCAD")
	Return( .F. )
EndIF


// Calcula Tamanho e Tipo de Impressao de modo a conter  integralmente o cabecalho.
IF ( nColunas < 5 )
	nTamanho		:= "M"
	aReturn[4]	:= 1
Else
	nTamanho		:= "G"
	aReturn[4]	:= 1
EndIF

// O numero de colunas eh sempre aos pares
nColunas *= 2

// Define a Ordem do Arquivo Principal SRA
nOrdem := 2

// Carregando variaveis mv_par?? para Variaveis do Sistema. 
FilialDe    := '  '			//Filial  De
FilialAte   := 'ZZ'			//Filial  Ate
CcDe        := '                    '			//Centro de Custo De
CcAte       := 'ZZZZZZZZZZZZZZZZZZZZ'			//Centro de Custo Ate
TurDe       := '   '			//Turno De
TurAte      := 'ZZZ'			//Turno Ate
MatDe       := '      '		//Matricula De
MatAte      := '      '		//Matricula Ate
NomDe       := '                              '			//Nome De
NomAte      := 'ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ'			//Nome Ate
cSit        := ' ADFT'				//Situacao
cCat        := 'ACDEGHIJMPST   '	//Categoria
nImpHrs     := 3				//Imprimir horas Calculadas/Inform/Ambas/NA
nImpAut     := 3				//Demonstrar horas Autoriz/Nao Autorizadas
nCopias     := 1				//N£mero de Copias
lSemMarc    := .T.			//Imprime para Funcion rios sem Marcacoes
cMenPad1    := ''				//Mensagem padrao anterior a Assinatura
cMenPad2    := ''				//Mens. padrao anterior a Assinatura(Cont.)
dPerIni     := mv_par01		//Data Contendo o Inicio do Periodo de Apontamento
dPerFim     := mv_par02		//Data Contendo o Fim  do Periodo de Apontamento
lSexagenal  := .T.			//Horas em  (Sexagenal/Centesimal)
lImpRes     := .F.			//Imprime eventos a partir do resultado ?
lImpTroca   := .T.			//Imprime Descricao Troca de Turnos ou o Atual
lImpExcecao := .T.			//Imprime Descricao da Excecao no Lugar da do Afastamento
dEnvIni     := mv_par01		//Data Contendo o Inicio do Periodo de Apontamento
dEnvFim     := mv_par02		//Data Contendo o Fim  do Periodo de Apontamento

If !( nLastKey == 27 )
	Processa( { |lEnd| GetMarcPPR(@lEnd)} , Titulo )
EndIf

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _AgrupaInf ³ Autor ³ Felipe S. Raota            ³ Data ³ 24/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Agrupa informações p/ Equipe.                                     ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB104PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _AgrupaInf()

Local nPos := 0
Local nPosFat := 0 
Local cEqp := ""

Local nFator := 0

//Alert("_AgrupaInf")

TRFT->(dbGoTop())

// Totalizo horas apontadas nas OS's
While TRFT->(!EoF()) 
	
	aADD(_aDados, { TRFT->FILIAL,;  // 1 - Filial
					TRFT->EQUIPE,;  // 2 - Equipe
					TRFT->HOR_TOT,; // 3 - Somatório de Horas apontadas em OS's
					TRFT->FAT_TOT,; // 4 - Somatório de Valor Faturado
					0.00,;		    // 5 - Somatório de Horas do Ponto
					0.00,;		    // 6 - Fator
					0.00})		    // 7 - Percentual de Produtividade = "3" / "5" 
	
	TRFT->(dbSkip()) 
Enddo

//U_ShowArray(_aDados)

//Alert("Ponto")
//ARQTRB->(dbGoTop())
//U_ShowTRB("ARQTRB")
ARQTRB->(dbGoTop())

TRB->(dbGoTop())
//U_ShowTRB("TRB")
//TRB->(dbGoTop())

_nCount := 0

// Utilizo tabela criada, com Equipe e Técnicos separados por dia...
cQuery := " SELECT * "
cQuery += " FROM PPR_FATOR_EQUIPE "
cQuery += " ORDER BY DATACHEG, TECNICO " 

TCQuery ChangeQuery(cQuery) New Alias "_ALI"

dbSelectArea("_ALI") 
_ALI->(dbGoTop())

COUNT TO _nCount
ProcRegua(_nCount)

_ALI->(dbGoTop())

//U_ShowTRB("_ALI")
//_ALI->(dbGoTop())

_aDadTec := {}
_cLogTec := ""

_nQtdDia := 1

// Somo horas do Ponto
While _ALI->(!EoF())
	
	If TRB->(MsSeek( xFilial("SRA") + _ALI->TECNICO + _ALI->DATACHEG ))
		_nQtdDia := TRB->EQP_DIA
	Endif
	
	If ARQTRB->(MsSeek( xFilial("SRA") + _ALI->TECNICO + _ALI->DATACHEG ))
		
		nPos := aScan(_aDados, {|x| Alltrim(x[2]) == Alltrim(_ALI->EQUIPE) })
		
		If nPos <> 0
			//_aDados[nPos,5] += ARQTRB->HORA
			_aDados[nPos,5] += fConvHr(ARQTRB->HORA,'D') / _nQtdDia  // Centesimal
		Endif
		
		nPos2 := aScan(_aDadTec, {|x| Alltrim(x[1]) == Alltrim(_ALI->EQUIPE) .AND. Alltrim(x[2]) == Alltrim(_ALI->TECNICO) })
		
		If nPos2 <> 0
			//_aDadTec[nPos2,3] += ARQTRB->HORA
			_aDadTec[nPos2,3] += fConvHr(ARQTRB->HORA,'D') / _nQtdDia // Centesimal
		Else
			aADD(_aDadTec, {Alltrim(_ALI->EQUIPE), _ALI->TECNICO, ARQTRB->HORA})
		Endif
		
	Endif
	
	_ALI->(dbSkip())
Enddo

_nHdl := fCreate("C:\temp\log\LOG_EQPA.csv", 0)

For _x:=1 to len(_aDadTec)
	_cLogTec := Alltrim(_aDadTec[_x,1]) +";"+ _aDadTec[_x,2] +";"+ Alltrim(Str(_aDadTec[_x,3])) + Chr(13) + Chr(10)
	fwrite(_nHdl, _cLogTec)
Next

//U_ShowArray(_aDados) 
//U_ShowArray(_aDadTec)

// Efetuo calculo do fator
For _x:=1 to len(_aDados) 
	
	nFator := 0
	For _y:=1 to len(_aFator)
		If _aFator[_y,1] == _aDados[_x,2]
			nFator += _aFator[_y,3]
		Endif
	Next _y
	
	_aDados[_x,6] := nFator
	_aDados[_x,5] := _aDados[_x,5] / nFator  
	_aDados[_x,7] := Round((_aDados[_x,3] / _aDados[_x,5]) * 100,2)
	
Next _x

//U_ShowArray(_aDados)
//U_ShowArray(_aFator)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ 104PPRGRV  ³ Autor ³ Felipe S. Raota            ³ Data ³ 21/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Gera espelho do ponto e retorna Vetor com horas trabalhadas p/Dia ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB104PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function GetMarcPPR(lEnd)

Local aComplPer	:= {}
Local aAbonosPer	:= {}
Local cFil			:= ""
Local cMat			:= ""
Local cTno			:= ""
Local cLastFil	:= "__cLastFil__"
Local cAcessaSRA	:= &("{ || " + ChkRH("PONR010","SRA","2") + "}")
Local cSeq			:= ""
Local cTurno		:= ""
Local cHtml		:= ""
Local lSPJExclu	:= !Empty( xFilial("SPJ") )
Local lSP9Exclu	:= !Empty( xFilial("SP9") )
Local nCount		:= 0.00
Local nX			:= 0.00
Local lMvAbosEve	:= .F.
Local lMvSubAbAp	:= .F.
Local cEmail		:= ""
Local cQuery		:= ""

Private aFuncFunc  := {SPACE(1), SPACE(1), SPACE(1), SPACE(1), SPACE(1), SPACE(1)}
Private aMarcacoes := {}
Private aTabPadrao := {}
Private aTabCalend := {}
Private aPeriodos  := {}
Private aId		   := {}
Private aBoxSPC	   := LoadX3Box("PC_TPMARCA")
Private aBoxSPH	   := LoadX3Box("PH_TPMARCA")
Private cHeader    := ""
Private dIniCale   := Ctod("//")	//-- Data Inicial a considerar para o Calendario
Private dFimCale   := Ctod("//")	//-- Data Final a considerar para o calendario
Private dMarcIni   := Ctod("//")	//-- Data Inicial a Considerar para Recuperar as Marcacoes
Private dMarcFim   := Ctod("//")	//-- Data Final a Considerar para Recuperar as Marcacoes
Private dIniPonMes := Ctod("//")	//-- Data Inicial do Periodo em Aberto
Private dFimPonMes := Ctod("//")	//-- Data Final do Periodo em Aberto
Private lImpAcum   := .F.

// Como a Cada Periodo Lido reinicializamos as Datas Inicial e Final preservamos-as nas variaveis: dCaleIni e dCaleFim.
dIniCale   := dPerIni   //-- Data Inicial a considerar para o Calendario
dFimCale   := dPerFim   //-- Data Final a considerar para o calendario

// Inicializa Variaveis Static
( CarExtAut() , RstGetTabExtra() )

dbSelectArea("SRA")
SRA->(dbSetOrder(nOrdem))

cEmail := ""
_nCount := 0

cQuery := "SELECT SRA.R_E_C_N_O_ "
cQuery += " FROM " + RetSqlName("SRA") + " SRA "
cQuery += " WHERE D_E_L_E_T_ <> '*' "
cQuery += "   AND SRA.RA_MAT IN (SELECT FATR.TECNICO FROM PPR_FATOR_POR_EQUIPE FATR) "
cQuery += " ORDER BY SRA.RA_FILIAL, SRA.RA_MAT "

TCQuery ChangeQuery(cQuery) New Alias "TRB2"

dbSelectArea("TRB2") 
TRB2->(dbGoTop())

COUNT TO _nCount
ProcRegua(_nCount)

TRB2->(dbGoTop())
//U_ShowTRB("TRB2")
//TRB2->(dbGoTop())

While TRB2->(!EoF())
	
	//SRA->(dbSetOrder(1))
	//If !SRA->(MsSeek(xFilial("SRA") + TRB2->CODTEC))
	//	TRB2->( dbSkip() )
	//	Loop 
	//Endif
	
	SRA->(dbGoTo(TRB2->R_E_C_N_O_))
	
	IncProc("Processando Matrícula: " + SRA->RA_MAT)
	
	Sleep(1000) // Para mostrar processamento...
	
	//MemoWrite("C:\temp\LOG\ " + Alltrim(SRA->RA_MAT) + ".txt", "")
	
	//Alert(SRA->RA_MAT)
	
	//Processa o Cadastro de Funcionarios
	// Consiste Parametrizacao do Intervalo de Impressao
	If SRA->(!( RA_SITFOLH	$ cSit	) .OR. !(	RA_CATFUNC	$ cCat	 ) )
		TRB2->( dbSkip() )
		Loop
	EndIf
	
	// Consiste a data de Demissao
	// Se o Funcionario Foi Demitido Anteriormente ao Inicio do Periodo Solicitado Desconsidera-o
	If !Empty(SRA->RA_DEMISSA) .and. ( SRA->RA_DEMISSA < dIniCale )
		TRB2->( dbSkip() )
		Loop
	EndIf
	
	// Alimenta as variaveis com o conteudo dos MV_'S correspondetes
	lMvAbosEve	:= ( Upper(AllTrim(SuperGetMv("MV_ABOSEVE",NIL,"N",cLastFil))) == "S" )	//--Verifica se Deduz as horas abonadas das horas do evento Sem a necessidade de informa o Codigo do Evento no motivo de abono que abona horas
	lMvSubAbAp	:= ( Upper(AllTrim(SuperGetMv("MV_SUBABAP",NIL,"N",cLastFil))) == "S" )	//--Verifica se Quando Abono nao Abonar Horas e Possuir codigo de Evento, se devera Gera-lo em outro evento e abater suas horas das Horas Calculadas

	// Atualiza a Filial Corrente
	cLastFil := SRA->RA_FILIAL
	
	// Carrega periodo de Apontamento Aberto
	If !CheckPonMes( @dPerIni , @dPerFim , .F. , .T. , .F. , cLastFil )
		Exit
	EndIF
	
	// Obtem datas do Periodo em Aberto
	GetPonMesDat( @dIniPonMes , @dFimPonMes , cLastFil )
	
	// Carrega as Tabelas de Horario Padrao
	If ( lSPJExclu .or. Empty( aTabPadrao ) )
		aTabPadrao := {}
		fTabTurno( @aTabPadrao , IF( lSPJExclu , cLastFil , NIL ) )
	EndIf
	
	// Carrega TODOS os Eventos da Filial
	IF ( Empty( aId ) .or. ( lSP9Exclu ) )
		aId := {}
		CarId( fFilFunc("SP9") , @aId , "*" )
	EndIF
	
	// Retorna Periodos de Apontamentos Selecionados
	dPerIni   := dIniCale
	dPerFim   := dFimCale
	aPeriodos := Monta_per( dIniCale , dFimCale , cLastFil , SRA->RA_MAT , dPerIni , dPerFim )
	
	// Corre Todos os Periodos
	naPeriodos := Len(aPeriodos)
	For nX := 1 To naPeriodos
	
		// Reinicializa as Datas Inicial e Final a cada Periodo Lido.
		// Os Valores de dPerIni e dPerFim foram preservados nas variaveis: dCaleIni e dCaleFim.
		dPerIni := aPeriodos[nX, 1]
		dPerFim := aPeriodos[nX, 2]
		
		// Obtem as Datas para Recuperacao das Marcacoes
		dMarcIni	:= aPeriodos[nX, 3]
		//dMarcIni	:= dPerIni
		dMarcFim	:= aPeriodos[nX, 4]
		//dMarcFim	:= dPerFim
		
		// Verifica se Impressao eh de Acumulado
		lImpAcum := ( dPerFim <= dFimPonMes )
		//lImpAcum := .F. // Alterado por Felipe, para poder gerar mesmo que o período do ponto esteja em aberto.
		
		//Alert(lImpAcum)
		
		// Retorna Turno/Sequencia das Marcacoes Acumulada
		If ( lImpAcum )
			If SPF->( dbSeek( SRA->( RA_FILIAL + RA_MAT ) + Dtos( dPerIni) ) ) .and. !Empty(SPF->PF_SEQUEPA)
				cTurno	:= SPF->PF_TURNOPA
				cSeq	:= SPF->PF_SEQUEPA
			Else
				
				// Tenta Achar a Sequencia Inicial utilizando RetSeq()
				IF !RetSeq(cSeq,@cTurno,dPerIni,dPerFim,dDataBase,aTabPadrao,@cSeq) .or. Empty( cSeq )
					
					// Tenta Achar a Sequencia Inicial utilizando fQualSeq()
					cSeq := fQualSeq( NIL , aTabPadrao , dPerIni , @cTurno )
				EndIF
			EndIF
			
			// Obtem Codigo e Descricao da Funcao do Trabalhador na Epoca
			fBuscaCC(dMarcFim, @aFuncFunc[1], @aFuncFunc[2], Nil, .F. , .T.  )
			aFuncFunc[2]:= Substr(aFuncFunc[2], 1, 25)
			fBuscaFunc(dMarcFim, @aFuncFunc[3], @aFuncFunc[4],20, @aFuncFunc[5], @aFuncFunc[6],25, .F. )
		Else
			
			// Considera a Sequencia e Turno do Cadastro
			cTurno	:= SRA->RA_TNOTRAB
			cSeq	:= SRA->RA_SEQTURN
			
			// Obtem Codigo e Descricao da Funcao do Trabalhador
			aFuncFunc[1]:= SRA->RA_CC
			aFuncFunc[2]:= DescCc(aFuncFunc[1], SRA->RA_FILIAL, 25)
			aFuncFunc[3]:= SRA->RA_CODFUNC
			aFuncFunc[4]:= DescFun(SRA->RA_CODFUNC , SRA->RA_FILIAL)
			aFuncFunc[6]:= DescCateg(SRA->RA_CATFUNC , 25)
		EndIf
		
		// Carrega Arrays com as Marcacoes do Periodo (aMarcacoes), com o Calendario de Marcacoes do Periodo (aTabCalend) e com as Trocas de Turno do Funcionario (aTurnos)
		( aMarcacoes := {} , aTabCalend := {} , aTurnos := {} )
		
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 Importante: 												      
		 O periodo fornecido abaixo para recuperar as marcacoes   cor
		 respondente ao periodo de apontamentoo Calendario de 	 Marca
		 coes do Periodo ( aTabCalend ) e com  as Trocas de Turno  do
		 Funcionario ( aTurnos ) integral afim de criar o  calendario
		 com as ordens correspondentes as gravadas nas marcacoes
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		
		dbSelectArea("SPG")
		
		If !GetMarcacoes(	@aMarcacoes					,;	//Marcacoes dos Funcionarios
							@aTabCalend					,;	//Calendario de Marcacoes
							@aTabPadrao					,;	//Tabela Padrao
							@aTurnos						,;	//Turnos de Trabalho
							dPerIni 						,;	//Periodo Inicial
							dPerFim						,;	//Periodo Final
							SRA->RA_FILIAL				,;	//Filial
							SRA->RA_MAT					,;	//Matricula
							cTurno							,;	//Turno
							cSeq							,;	//Sequencia de Turno
							SRA->RA_CC						,;	//Centro de Custo
							IIF(lImpAcum,"SPG","SP8")	,;	//Alias para Carga das Marcacoes
							NIL								,;	//Se carrega Recno em aMarcacoes
							.T.								,;	//Se considera Apenas Ordenadas
							.T.    						,;	//Se Verifica as Folgas Automaticas
							.F.    			 			 ;	//Se Grava Evento de Folga Automatica Periodo Anterior
							)
			
			Alert("Não consegui gerar as Marcações")
			
			TRB2->(dbSkip())
			Loop
		EndIf
		
		aPrtTurn:={}
		
		aEval(aTurnos, {|x| If( x[2] >= dPerIni .AND. x[2]<= dPerFim, aADD(aPrtTurn, x),Nil )} )
		
		// Reinicializa os Arrays aToais e aAbonados
		( aTotais := {} , aAbonados := {} )
		
		// Carrega os Abonos Conforme Periodo
		fAbonosPer( @aAbonosPer , dPerIni , dPerFim , cLastFil , SRA->RA_MAT )
		
		// Carrega os Totais de Horas e Abonos.
		CarAboTot( @aTotais , @aAbonados , aAbonosPer, lMvAbosEve, lMvSubAbAp )
		
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 Carrega o Array a ser utilizado na Impressao.
		 aPeriodos[nX,3] --> Inicio do Periodo para considerar as  marcacoes e tabela
		 aPeriodos[nX,4] --> Fim do Periodo para considerar as   marcacoes e tabela
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		
		If ( !fMontaAEsp( aTabCalend, aMarcacoes, @aImp,dMarcIni,dMarcFim, lTerminal) .AND. !( lSemMarc ) )
			
			MsgInfo("Não consegui montar o vetor de Horas p/ Dia")
			
			TRB2->( dbSkip() )
			Loop
		EndIf
		
		// Reinicializa Variaveis
		aImp      := {}
		aTotais   := {}
		aAbonados := {} 
		
	Next nX
	
	TRB2->( dbSkip() )
End

TRB2->(DbCloseArea())

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ fMontaAEsp  ³ Autor ³ Felipe S. Raota           ³ Data ³ 21/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Monta vetor com a Quantidade de Horas trabalhadas por dia.        ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB104PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function fMontaAEsp(aTabCalend, aMarcacoes, aImp,dInicio,dFim, lTerminal) 

Local aDescAbono := {}
Local cTipAfas   := ""
Local cDescAfas  := ""
Local cOcorr     := ""
Local cOrdem     := ""
Local cTipDia    := ""
Local dData      := Ctod("//")
Local dDtBase    := dFim
Local lRet       := .T.
Local lFeriado   := .T.
Local lTrabaFer  := .F.
Local lAfasta    := .T.
Local nX         := 0
Local nDia       := 0
Local nMarc      := 0
Local nLenMarc   := Len( aMarcacoes )
Local nLenDescAb := Len( aDescAbono )
Local nTab       := 0
Local nContMarc  := 0
Local nDias      := 0

//-- Variaveis ja inicializadas.
aImp := {}
nDias := ( dDtBase - dInicio )

For nDia := 0 To nDias
	
	//-- Reinicializa Variaveis.
	dData      := dInicio + nDia
	aDescAbono := {}
	cOcorr     := ""
	cTipAfas   := ""
	cDescAfas  := ""
	cOcorr	    := ""
	_aTmp := {}
	
	If ( nTab := aScan(aTabCalend, {|x| x[1] == dData .and. x[4] == '1E' }) ) == 0.00
		Loop
	EndIf
	
	If dData < dEnvIni .or. dData > dEnvFim
		Loop
	Endif
	
	nMarc := aScan(aMarcacoes, { |x| x[3] == aTabCalend[nTab, 2] })
	
	//-- Consiste Afastamentos, Demissoes ou Transferencias.
	If ( ( lAfasta := aTabCalend[ nTab , 24 ] ) .or. SRA->( RA_SITFOLH $ 'DúT' .and. dData > RA_DEMISSA ) )
		lAfasta		:= .T.
		cTipAfas	:= IF(!Empty(aTabCalend[ nTab , 25 ]),aTabCalend[ nTab , 25 ],fDemissao(SRA->RA_SITFOLH, SRA->RA_RESCRAI) )
		cDescAfas	:= fDescAfast( cTipAfas, Nil, Nil, SRA->( RA_SITFOLH == 'D' .and. dData > RA_DEMISSA ) )
	EndIf
	
	//Verifica Regra de Apontamento ( Trabalha Feriado ? )
	lTrabaFer := ( PosSPA( aTabCalend[ nTab , 23 ] , cFilSPA , "PA_FERIADO" , 01 ) == "S" )
	
	//-- Consiste Feriados.
	If ( lFeriado := aTabCalend[ nTab , 19 ] )  .AND. !lTrabaFer
		cOcorr := aTabCalend[ nTab , 22 ]
	EndIf
	
	//-- Carrega Array aDescAbono com os Abonos ocorridos no Dia
	nLenDescAb := Len(aAbonados)
	For nX := 1 To nLenDescAb
		If aAbonados[nX,1] == dData
			aAdd(aDescAbono, left(aAbonados[nX,2],20)) //+ Space(1) + aAbonados[nX,3]+ Space(2) + aAbonados[nX,4])
			aadd(_aTmp,aAbonados[nX,3])
		EndIf
	Next nX
	
	//-- Ordem e Tipo do dia em questao.
	cOrdem  := aTabCalend[nTab,2]
	cTipDia := aTabCalend[nTab,6]
	_lDiaTrab := .T.
	
	//-- Se a Data da marcacao for Posterior a Admissao
	IF dData >= SRA->RA_ADMISSA
		//-- Se Afastado
		If ( lAfasta  .AND. aTabCalend[nTab,10] <> 'E' ) .OR. ( lAfasta  .AND. aTabCalend[nTab,10] == 'E' .AND. !lImpExcecao )
			cOcorr := cDescAfas
			_lDiaTrab := .F.
			//-- Se nao for Afastado
		Else
			
			//-- Se tiver EXCECAO para o Dia  ------------------------------------------------
			If aTabCalend[nTab,10] == 'E'
				//-- Se excecao trabalhada
				If cTipDia == 'S'
					//-- Se nao fez Marcacao
					If Empty(nMarc)
						cOcorr := '** Ausente **'
						_lDiaTrab := .F.
						//-- Se fez marcacao
					Else
						//-- Motivo da Marcacao
						If !Empty(aTabCalend[nTab,11])
							cOcorr := AllTrim(aTabCalend[nTab,11])
						Else
							cOcorr := '** Excecao nao Trabalhada **'
							_lDiaTrab := .F.
						EndIf
					Endif
					//-- Se excecao outros dias (DSR/Compensado/Nao Trabalhado)
				Else
					//-- Motivo da Marcacao
					If !Empty(aTabCalend[nTab,11])
						cOcorr := AllTrim(aTabCalend[nTab,11])
					Else
						cOcorr := '** Excecao nao Trabalhada **'
						_lDiaTrab := .F.
					EndIf
				Endif
				
				//-- Se nao Tiver Excecao  no Dia ---------------------------------------------------
			Else
				//-- Se feriado
				If lFeriado
					//-- Se nao trabalha no Feriado
					If !lTrabaFer
						cOcorr := If(!Empty(cOcorr),cOcorr,'** Feriado **' ) // '** Feriado **'
						_lDiaTrab := .F.
						//-- Se trabalha no Feriado
					Else
						//-- Se Dia Trabalhado e Nao fez Marcacao
						If cTipDia == 'S' .and. Empty(nMarc)
							cOcorr := '** Ausente **'
							_lDiaTrab := .F.
						ElseIf cTipDia == 'D'
							cOcorr := '** D.S.R. **'
							_lDiaTrab := .F.
						ElseIf cTipDia == 'C'
							cOcorr := '** Compensado **'
							_lDiaTrab := .F.
						ElseIf cTipDia == 'N'
							cOcorr := '** Nao Trabalhado **'
							_lDiaTrab := .F.
						EndIf
					Endif
				Else
					//-- Se Dia Trabalhado e Nao fez Marcacao
					If cTipDia == 'S' .and. Empty(nMarc)
						cOcorr := '** Ausente **'
						_lDiaTrab := .F.
					ElseIf cTipDia == 'D'
						cOcorr := '** D.S.R. **'
						_lDiaTrab := .F.
					ElseIf cTipDia == 'C'
						cOcorr := '** Compensado **'
						_lDiaTrab := .F.
					ElseIf cTipDia == 'N'
						cOcorr := '** Nao Trabalhado **'
						_lDiaTrab := .F.
					EndIf
					
				Endif
			Endif
		Endif
	Endif
	
	nLenDescAb := Len(aDescAbono)
	
	//-- Adiciona Nova Data a ser impressa.
	aAdd(aImp,{})
	aAdd(aImp[Len(aImp)], aTabCalend[nTab,1])
	
	//-- Ocorrencia na Data.
	aAdd( aImp[Len(aImp)], cOcorr)
	
	//-- Abono na Data.
	If ( nLenDescAb  > 0 )
		If cOcorr == '** Ausente **'
			aAdd( aImp[Len(aImp)], cOcorr ) // '** Ausente **'
		Else
			If !empty(cOcorr)
				aAdd( aImp[Len(aImp)],	Space(01))
				aAdd( aImp[Len(aImp)], cOcorr )
				aAdd( aImp,{})
				aAdd( aImp[Len(aImp)], aTabCalend[nTab,1])
				aAdd( aImp[Len(aImp)],	Space(01) )
			Else
				aAdd( aImp[Len(aImp)],	Space(01))
			Endif
		Endif
		
		For nX := 1 To nLenDescAb
			If nX == 1
				aAdd( aImp[Len(aImp)], aDescAbono[nX])
			Else
				aAdd(aImp, {})
				aAdd(aImp[Len(aImp)], aTabCalend[nTab,1]		)
				aAdd(aImp[Len(aImp)], Space(01)			 	)
				aAdd(aImp[Len(aImp)], aDescAbono[nX]			)
			Endif
		Next nX
	Else
		If cOcorr == '** Ausente **'
			aAdd( aImp[Len(aImp)], cOcorr)
			aAdd( aImp[Len(aImp)], Space(01))
		Else
			aAdd( aImp[Len(aImp)], Space(01))
			aAdd( aImp[Len(aImp)], cOcorr )
		Endif
	Endif
	
	//-- Marcacoes ocorridas na data.
	If nMarc > 0
		While nMarc <= nLenMarc .and. cOrdem == aMarcacoes[nMarc,3]
			nContMarc ++
			aAdd( aImp[Len(aImp)], StrTran(StrZero(aMarcacoes[nMarc,2],5,2),'.',':'))
			nMarc ++
		End While
	EndIf
	
	_aAreaX := GetArea()
	_nExtr  := 0
	_nAtra  := 0
	_nFalt  := 0
	_nSaida := 0
	_nAtest := 0
	_nTotal := 0
	
	DbSelectArea("SPH")
	DbSetOrder(2)
	DbGoTop()
	
	DbSelectArea("SPC")
	DbSetOrder(2)
	DbGoTop()
	/*
	If DbSeek(SRA->RA_FILIAL+SRA->RA_MAT+dtos(ddata))
		
		Do While !EoF() .and. SRA->RA_FILIAL+SRA->RA_MAT+dtos(ddata) == SPC->PC_FILIAL+SPC->PC_MAT+dtos(SPC->PC_DATA)
			
			If SPC->PC_ABONO $ "001|002"
				_nAtest := SomaHoras(_nAtest,SPC->PC_QTABONO)
			endif
			If SPC->PC_PD $ GetMv("ML_IDEXT")
				_nExtr := SomaHoras(_nExtr,SubHoras(SPC->PC_QUANTC,SPC->PC_QTABONO))
			elseif SPC->PC_PD $ GetMv("ML_IDATRA")
				_nAtra := SomaHoras(_nAtra,SubHoras(SPC->PC_QUANTC,SPC->PC_QTABONO))
			elseif SPC->PC_PD $ GetMv("ML_IDFALT")
				_nFalt := SomaHoras(_nFalt,SubHoras(SPC->PC_QUANTC,SPC->PC_QTABONO))
			elseif SPC->PC_PD $ GetMv("ML_IDSAIDA")
				_nSaida := SomaHoras(_nSaida,SubHoras(SPC->PC_QUANTC,SPC->PC_QTABONO))
			endif
			
			dbselectArea("SPC")
			dbSkip()
		enddo
	endif
	
	If !_lDiaTrab .or. (_lDiaTrab .and. Len(aImp[Len(aImp)]) < 4)
		_nTotal := SomaHoras(_nTotal,SubHoras(_nExtr,SomaHoras(_nAtra,SomaHoras(_nFalt,SomaHoras(_nSaida,_nAtest)))))
	Else
		_nTotal := SomaHoras(_nTotal,SomaHoras(8.48,SubHoras(_nExtr,SomaHoras(_nAtra,SomaHoras(_nFalt,SomaHoras(_nSaida,_nAtest))))))
	Endif
	*/
	RestArea(_aAreaX)
	
Next nDia

//U_ShowArray(aImp)

For _x:=1 to len(aImp)
	
	_nLen := 5 // Quando tem somente 1 entrada e 1 saída
	_nHoras := 0
	
	While .T.
		
		_aAux := aImp[_x]
		
		If len(_aAux) >= _nLen
			If len(_aAux) >= _nLen + 1
				_nHoras := SomaHoras(_nHoras, ElapTime(aImp[_x, (_nLen)]+":00",aImp[_x, _nLen+1]+":00"))
			Else
				aADD(_aErroHora, {SRA->RA_FILIAL, SRA->RA_MAT, aImp[_x,1], "Sem Data Final"})
			EndIf
		Else
			EXIT
		Endif
		
		_nLen += 2
		
	EndDo
	
	dbSelectArea("ARQTRB")
	
	RecLock("ARQTRB", .T.)
		ARQTRB->FILIAL := SRA->RA_FILIAL
		ARQTRB->MAT    := SRA->RA_MAT
		ARQTRB->DTPON  := DtoS(aImp[_x,1])
		ARQTRB->HORA   := _nHoras
	MsUnLock()
	
Next

lRet := If(nContMarc>=1,.T.,.F.)

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CarAboTot ³ Autor ³ EQUIPE DE RH          ³ Data ³ 08/08/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega os totais do SPC e os abonos                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ POR010IMP                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function CarAboTot( aTotais , aAbonados , aAbonosPer, lMvAbosEve, lMvSubAbAp )

Local aTotSpc		:= {} //-- 1-SPC->PC_PD/2-SPC->PC_QUANTC/3-SPC->PC_QUANTI/4-SPC->PC_QTABONO
Local aCodAbono		:= {}
Local aJustifica	:= {} //-- Retorno fAbonos() c/Cod abono e horas abonadas.
Local cString   	:= ""
Local cFilSP9   	:= xFilial( "SP9" , SRA->RA_FILIAL )
Local cFilSRV		:= xFilial( "SRV" , SRA->RA_FILIAL )
Local cFilSPC   	:= xFilial( "SPC" , SRA->RA_FILIAL )
Local cFilSPH   	:= xFilial( "SPH" , SRA->RA_FILIAL )
Local cImpHoras 	:= If(nImpHrs==1,"C",If(nImpHrs==2,"I","*")) //-- Calc/Info/Ambas
Local cAutoriza 	:= If(nImpAut==1,"A",If(nImpAut==2,"N","*")) //-- Aut./N.Aut./Ambas
Local cAliasRes		:= IF( lImpAcum , "SPL" , "SPB" )
Local cAliasApo		:= IF( lImpAcum , "SPH" , "SPC" )
Local bAcessaSPC 	:= &("{ || " + ChkRH("PONR010","SPC","2") + "}")
Local bAcessaSPH 	:= &("{ || " + ChkRH("PONR010","SPH","2") + "}")
Local bAcessaSPB 	:= &("{ || " + ChkRH("PONR010","SPB","2") + "}")
Local bAcessaSPL 	:= &("{ || " + ChkRH("PONR010","SPL","2") + "}")
Local bAcessRes		:= IF( lImpAcum , bAcessaSPH , bAcessaSPC )
Local bAcessApo		:= IF( lImpAcum , bAcessaSPL , bAcessaSPB )
Local lCalcula	 	:= .F.
Local lExtra	 	:= .F.
Local nColSpc   	:= 0.00
Local nCtSpc    	:= 0.00
Local nQuaSpc		:= 0.00
Local nPass     	:= 0.00
Local nHorasCal 	:= 0.00
Local nHorasInf 	:= 0.00
Local nX        	:= 0.00

If ( lImpRes )
//Totaliza Codigos a partir do Resultado
	fTotalSPB(;
		@aTotSpc		,;
		SRA->RA_FILIAL	,;
		SRA->RA_Mat		,;
		dMarcIni		,;
		dMarcFim		,;
		bAcessRes		,;
		cAliasRes		,;
		cAutoriza		 ;
		)
//-- Converte as horas para sexagenal quando impressao for a partir do resultado
	If ( lSexagenal )	// Sexagenal
		For nCtSpc := 1 To Len(aTotSpc)
			For nColSpc := 2 To 4
				aTotSpc[nCtSpc,nColSpc]:=fConvHr(aTotSpc[nCtSpc,nColSpc],'H')
			Next nColSpc
		Next nCtSpc
	Endif
Endif

//Totaliza Codigos a partir do Movimento
fTotaliza(;
	@aTotSpc,;
	SRA->RA_FILIAL,;
	SRA->RA_MAT,;
	bAcessApo,;
	cAliasApo,;
	cAutoriza,;
	@aCodAbono,;
	aAbonosPer,;
	lMvAbosEve,;
	lMvSubAbAp;
	)
//-- Converte as horas para Centesimal quando impressao for a partir do apontamento
If !( lImpRes ) .and. !( lSexagenal ) // Centesimal
	For nCtSpc :=1 To Len(aTotSpc)
		For nColSpc :=2 To 4
			aTotSpc[nCtSpc,nColSpc]:=fConvHr(aTotSpc[nCtSpc,nColSpc],'D')
		Next nColSpc
	Next nCtSpc
Endif

//-- Monta Array com Totais de Horas
If nImpHrs # 4  //-- Se solicitado para Listar Totais de Horas
	For nPass := 1 To Len(aTotSpc)
		IF ( lImpRes ) //Impressao dos Resultados
//-- Se encontrar o Codigo da Verba ou For um codigo de hora extra valido de acordo com o solicitado
			If PosSrv( aTotSpc[nPass,1] , cFilSRV , NIL , 01 )
				nHorasCal 	:= aTotSpc[nPass,2] //-- Calculado - Abonado
				nHorasInf 	:= aTotSpc[nPass,3] //-- Informado
				If nHorasCal > 0 .and. cImpHoras $ 'Cú*' .or. nHorasInf > 0 .and. cImpHoras $ 'Iú*'
					cString := If(cImpHoras$'Cú*',Transform(nHorasCal, '@E 99,999.99'),Space(9)) + Space(1)
					cString += If(cImpHoras$'Iú*',Transform(nHorasInf, '@E 99,999.99'),Space(9))
					aAdd(aTotais, aTotSpc[nPass,1] + Space(1) + SRV->RV_DESC + Space(1) + cString )
				EndIf
			Endif
		ElseIf PosSP9( aTotSpc[nPass,1] , cFilSP9 , NIL , 01 )
//-- Impressao a Partir do Movimento
			nHorasCal 	:= aTotSpc[nPass,2] //-- Calculado - Abonado
			nHorasInf 	:= aTotSpc[nPass,3] //-- Informado
			If nHorasCal > 0 .and. cImpHoras $ 'Cú*' .or. nHorasInf > 0 .and. cImpHoras $ 'Iú*'
				cString := If(cImpHoras$'Cú*',Transform(nHorasCal, '@E 99,999.99'),Space(9)) + Space(1)
				cString += If(cImpHoras$'Iú*',Transform(nHorasInf, '@E 99,999.99'),Space(9))
				aAdd(aTotais, aTotSpc[nPass,1] + Space(1) + DescPDPon(aTotSpc[nPass,1], cFilSP9 ) + Space(1) + cString )
			EndIf
		EndIF
	Next nPass

//-- Acrescenta as informacoes referentes aos eventos associados aos motivos de abono
//-- Condicoes: Se nao For Impressao de Resultados
//-- 			e Se For para Imprimir Horas Calculadas ou Ambas
	If !( lImpRes ) .and. (nImpHrs == 1 .or. nImpHrs == 3)
		For nX := 1 To Len(aCodAbono)
// Converte as horas para Centesimal
			If !( lSexagenal ) // Centesimal
				aCodAbono[nX,2]:=fConvHr(aCodAbono[nX,2],'D')
			Endif
			aAdd(aTotais, aCodAbono[nX,1] + Space(1) + DescPDPon(aCodAbono[nX,1], cFilSP9) + '      0,00 '  + Transform(aCodAbono[nX,2],'@E 99,999.99') )
		Next nX
	Endif
EndIf

Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fTotaliza ³ Autor ³ Mauricio MR           ³ Data ³ 27/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Totalizar as Verbas do SPC (Apontamentos) /SPH (Acumulado) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fTotaliza(	aTotais		,;
								cFil		,;
								cMat		,;
								bAcessa 	,;
								cAlias		,;
								cAutoriza	,;
								aCodAbono	,;
								aAbonosPer	,;
								lMvAbosEve	,;
								lMvSubAbAp 	 ;
								)

Local aJustifica	:= {}
Local cCodigo		:= ""
Local cPrefix		:= SubStr(cAlias,-2)
Local cTno			:= ""
Local cCodExtras	:= ""
Local cEvento		:= ""
Local cPD			:= ""
Local cPDI			:= ""
Local cCC			:= ""
Local cTPMARCA		:= ""
Local dPD			:= Ctod("//")
Local lExtra		:= .T.
Local lAbHoras		:= .T.
Local nQuaSpc		:= 0.00
Local nX			:= 0.00
Local nEfetAbono	:= 0.00
Local nQUANTC		:= 0.00
Local nQuanti		:= 0.00
Local nQTABONO		:= 0.00

If ( cAlias )->(dbSeek( cFil + cMat ) )
	While (cAlias)->( !Eof() .and. cFil+cMat == &(cPrefix+"_FILIAL")+&(cPrefix+"_MAT") )

		dData	:= (cAlias)->(&(cPrefix+"_DATA"))  	//-- Data do Apontamento
		cPD		:= (cAlias)->(&(cPrefix+"_PD"))    	//-- Codigo do Evento
		cPDI	:= (cAlias)->(&(cPrefix+"_PDI"))     	//-- Codigo do Evento Informado
		nQUANTC	:= (cAlias)->(&(cPrefix+"_QUANTC"))  	//-- Quantidade Calculada pelo Apontamento
		nQuanti	:= (cAlias)->(&(cPrefix+"_QUANTI"))  	//-- Quantidade Informada
		nQTABONO:= (cAlias)->(&(cPrefix+"_QTABONO")) 	//-- Quantidade Abonada
		cTPMARCA:= (cAlias)->(&(cPrefix+"_TPMARCA")) 	//-- Tipo da Marcacao
		cCC		:= (cAlias)->(&(cPrefix+"_CC")) 		//-- Centro de Custos

		If (cAlias)->( !Eval(bAcessa) )
			(cAlias)->( dbSkip() )
			Loop
		EndIf

		If dData < dMarcIni .or. dDATA > dMarcFim
			(cAlias)->( dbSkip() )
			Loop
		Endif
		
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Obtem TODOS os ABONOS do Evento							   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		//-- Trata a Qtde de Abonos
		aJustifica 	:= {} //-- Reinicializa aJustifica
		nEfetAbono	:=	0.00
		If nQuanti == 0 .and. fAbonos( dData , cPD , NIL , @aJustifica , cTPMARCA , cCC , aAbonosPer ) > 0

			//-- Corre Todos os Abonos
			For nX := 1 To Len(aJustifica)

				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Cria Array Analitico de Abonos com horas Convertidas.		   ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				//-- Obtem a Quantidade de Horas Abonadas
				nQuaSpc := aJustifica[nX,2] //_QtAbono

				//-- Converte as horas Abonadas para Centesimal
				If !( lSexagenal ) // Centesimal
					nQuaSpc:= fConvHr(nQuaSpc,'D')
				Endif

				//-- Cria Novo Elemento no array ANALITICO de Abonos
				aAdd( aAbonados, {} )
				aAdd( aAbonados[Len(aAbonados)], dData )
				aAdd( aAbonados[Len(aAbonados)], DescAbono(aJustifica[nX,1],'C') )

				aAdd( aAbonados[Len(aAbonados)], StrTran(StrZero(nQuaSpc,5,2),'.',':') )
				aAdd( aAbonados[Len(aAbonados)], DescTpMarca(aBoxSPC,cTPMARCA))

				If !( lImpres )
					/*
					ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³ Trata das Informacoes sobre o Evento Associado ao Motivo corrente ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					//-- Obtem Evento Associado
					cEvento := PosSP6( aJustifica[nX,1] , SRA->RA_FILIAL , "P6_EVENTO" , 01 )
					If ( lAbHoras := ( PosSP6( aJustifica[nX,1] , SRA->RA_FILIAL , "P6_ABHORAS" , 01 ) $ " S" ) )
						//-- Se o motivo abona Horas
						If ( lAbHoras )
							If !Empty( cEvento )
								If ( nPos := aScan( aCodAbono, { |x| x[1] == cEvento } ) ) > 0
									aCodAbono[nPos,2] := __TimeSum(aCodAbono[nPos,2], aJustifica[nX,2] ) //_QtAbono
								Else
									aAdd(aCodAbono, {cEvento,  aJustifica[nX,2] }) // Codigo do Evento e Qtde Abonada
								EndIf
							Else
								/*
								ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								³ A T E N C A O: Neste Ponto deveriamos tratar o paramentro MV_ABOSEVE  ³
								³                no entanto, como ja havia a deducao abaixo e caso al-  ³
								³                guem migra-se da versao 609 com o cadastro de motivo   ³
								³                de abonos abonando horas mas sem o codigo, deixariamos ³
								³                de tratar como antes e o cliente argumentaria alteracao³
								³                de conceito.											³
								ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
								//-- Se o motivo  nao possui abono associado
								//-- Calcula o total de horas a abonar efetivamente
								nEfetAbono:= __TimeSum(nEfetAbono, aJustifica[nX,2] ) //_QtAbono
							EndIf
						Endif
					Else
						/*
						ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						³Se Motivo de Abono Nao Abona Horas e o Codigo do Evento Relaci³
						³onado ao Abono nao Estiver Vazio, Eh como se fosse uma  altera³
						³racao do Codigo de Evento. Ou seja, Vai para os Totais      as³
						³Horas do Abono que serao subtraidas das Horas Calculadas (  Po³
						³deriamos Chamar esta operacao de "Informados via Abono" ).	   ³
						³Para que esse processo seja feito o Parametro MV_SUBABAP  deve³
						³ra ter o Conteudo igual a "S"								   ³
						ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
						IF ( ( lMvSubAbAp ) .and. !Empty( cEvento ) )
							//-- Se o motivo  nao possui abono associado
							//-- Calcula o total de horas a abonar efetivamente
							If ( nPos := aScan( aCodAbono, { |x| x[1] == cEvento } ) ) > 0
								aCodAbono[nPos,2] := __TimeSum(aCodAbono[nPos,2], aJustifica[nX,2] ) //_QtAbono
							Else
								aAdd(aCodAbono, {cEvento,  aJustifica[nX,2] }) // Codigo do Evento e Qtde Abonada
							EndIf
							//-- O total de horas acumulado em nEfetAbono sera deduzido do
							//-- total de horas apontadas.
							nEfetAbono:= __TimeSum(nEfetAbono, aJustifica[nX,2] ) //_QtAbono
						Endif
					EndIf
				Endif
			Next nX
		Endif
	
		If !( lImpres )
			//-- Obtem o Codigo do Evento  (Informado ou Calculado)
			cCodigo:= If(!Empty(cPDI), cPDI, cPD )

			//-- Obtem a posicao no Calendario para a Data

			If ( nPos 	:= aScan(aTabCalend, {|x| x[1] ==dDATA .and. x[4] == '1E' }) ) > 0
				//-- Obtem o Turno vigente na Data
				cTno	:=	aTabCalend[nPos,14]
				//-- Carrega ou recupera os codigos correspondentes a horas extras na Data
				cCodExtras	:= ''
				CarExtAut( @cCodExtras , cTno , cAutoriza )
				lExtra:=.F.
				If cCodigo$cCodExtras
					lExtra:=.T.
				Endif
			Endif
			
			//-- Se o Evento for Alguma HE Solicitada (Autorizada ou Nao Autorizada)
			//-- Ou  Valido Qquer Evento (Autorizado e Nao Autorizado)
			//-- OU  Evento possui um identificador correspondente a Evento Autorizado ou Nao Autorizado.
			If lExtra .or. cAutoriza == '*' .or. (aScan(aId,{|aEvento| aEvento[1] == cCodigo .and. Right(aEvento[2],1) == cAutoriza }) > 0.00)

				//-- Procura em aTotais pelo acumulado do Evento Lido
				If ( nPos := aScan(aTotais,{|x| x[1] == cCodigo .AND. x[6] == dData }) ) > 0
					
					//-- Subtrai do evento a qtde de horas que efetivamente abona horas conforme motivo de abono
					aTotais[nPos,2] := __TimeSum(aTotais[nPos,2],If(nQuanti>0, 0, __TimeSub(nQUANTC,nEfetAbono)))
					aTotais[nPos,3] := __TimeSum(aTotais[nPos,3],nQuanti)
					aTotais[nPos,4] := __TimeSum(aTotais[nPos,4],nQTABONO) 
					
				Else
					
					//-- Adiciona Evento em Acumulados
					//-- Subtrai do evento a qtde de horas que efetivamente abona horas conforme motivo de abono
					aAdd(aTotais,{cCodigo,If(nQuanti > 0, 0, __TimeSub(nQUANTC,nEfetAbono)), nQuanti,nQTABONO,lExtra, dData })
				Endif
			Endif
		Endif
		(cAlias)->( dbSkip() )
	End While
Endif

Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fTotalSPB ³ Autor ³ EQUIPE DE RH		    ³ Data ³ 05/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Totaliza eventos a partir do SPB.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fTotalSPB(aTotais,cFil,cMat,dDataIni,dDataFim,bAcessa,cAlias)

Local cPrefix := ""

cPrefix		:= SubStr(cAlias,-2)

If ( cAlias )->( dbSeek( cFil + cMat ) )
	While (cAlias)->( !Eof() .and. cFil+cMat == &(cPrefix+"_FILIAL")+&(cPrefix+"_MAT") )

		If (cAlias)->( &(cPrefix+"_DATA") < dDataIni .or. &(cPrefix+"_DATA") > dDataFim )
			(cAlias)->( dbSkip() )
			Loop
		Endif

		If (cAlias)->( !Eval(bAcessa) )
			(cAlias)->( dbSkip() )
			Loop
		EndIf

		If ( nPos := aScan(aTotais,{|x| x[1] == (cAlias)->( &(cPrefix+"_PD") ) }) ) > 0
			aTotais[nPos,2] := aTotais[nPos,2] + (cAlias)->( &(cPrefix+"_HORAS") )
		Else
			aAdd(aTotais,{(cAlias)->( &(cPrefix+"_PD") ),(cAlias)->( &(cPrefix+"_HORAS") ),0,0 })
		Endif
		(cAlias)->( dbSkip() )
	End While
Endif

Return( NIL )


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LoadX3Box ³ Autor ³ Mauricio MR           ³ Data ³ 10.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna array da ComboBox                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCampo - Nome do Campo                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function LoadX3Box(cCampo)

Local aRet:={},nCont,nIgual
Local cCbox,cString
Local aSvArea := SX3->(GetArea())

SX3->(DbSetOrder(2))
SX3->(DbSeek(cCampo))

cCbox := SX3->(X3Cbox())

While !Empty(cCbox)
	nCont:=AT(";",cCbox)
	nIgual:=AT("=",cCbox)
	cString:=AllTrim(SubStr(cCbox,1,nCont-1)) //Opcao
	IF nCont == 0
		aAdd(aRet,{SubStr(cString,1,nigual-1),SubStr(cString,nigual+1)})
		Exit
	Else
		aAdd(aRet,{SubStr(cString,1,nigual-1),SubStr(cString,nigual+1)})
	Endif
	cCbox:=SubStr(cCbox,nCont+1)
Enddo

RestArea(aSvArea)

Return( aRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Monta_Per³ Autor ³Equipe Advanced RH     ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Static Function Monta_Per( dDataIni , dDataFim , cFil , cMat , dIniAtu , dFimAtu )

Local aPeriodos := {}
Local cFilSPO	:= xFilial( "SPO" , cFil )
Local dAdmissa	:= SRA->RA_ADMISSA
Local dPerIni   := Ctod("//")
Local dPerFim   := Ctod("//")

SPO->( dbSetOrder( 1 ) )
SPO->( dbSeek( cFilSPO , .F. ) )
While SPO->( !Eof() .and. PO_FILIAL == cFilSPO )

	dPerIni := SPO->PO_DATAINI
	dPerFim := SPO->PO_DATAFIM
	
	//-- Filtra Periodos de Apontamento a Serem considerados em funcao do Periodo Solicitado
	IF dPerFim < dDataIni .OR. dPerIni > dDataFim
		SPO->( dbSkip() )
		Loop
	Endif
	
	//-- Somente Considera Periodos de Apontamentos com Data Final Superior a Data de Admissao
	IF ( dPerFim >= dAdmissa )
		aAdd( aPeriodos , { dPerIni , dPerFim , Max( dPerIni , dDataIni ) , Min( dPerFim , dDataFim ) } )
	Else
		Exit
	EndIF
	
	SPO->( dbSkip() )

End While


IF ( aScan( aPeriodos , { |x| x[1] == dIniAtu .and. x[2] == dFimAtu } ) == 0.00 )
	dPerIni := dIniAtu
	dPerFim	:= dFimAtu
	IF !(dPerFim < dDataIni .OR. dPerIni > dDataFim)
		IF ( dPerFim >= dAdmissa )
			aAdd(aPeriodos, { dPerIni, dPerFim, Max(dPerIni,dDataIni), Min(dPerFim,dDataFim) } )
		EndIF 
	Endif
EndIF


Return( aPeriodos )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³DescTPMarc³ Autor ³ Mauricio MR           ³ Data ³ 10.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna Descricao do Tipo da Marcacao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aBox     - Array Contendo as Opcoes do Combox Ja Carregadas³±±
±±³          ³ cTpMarca - Tipo da Marcacao                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ponr010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function DescTpMarca(aBox,cTpMarca)

Local aTpMarca:={},cRet:='',nTpMarca:=0
//-- SE Existirem Opcoes Realiza a Busca da Marcacao
If Len(aBox)>0
   nTpmarca:=aScan(aBox,{|xtp| xTp[1] == cTpMarca})
   cRet:=If(nTpMarca>0,aBox[nTpmarca,2],"")
Endif

Return( cRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CarExtAut³ Autor ³ Mauricio MR           ³ Data ³ 24/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna Relacao de Horas Extras por Filial/Turno           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodExtras --> String que Contem ou Contera os Codigos     ³±±
±±³          ³ cTnoCad    --> Turno conforme o Dia                        ³±±
±±³          ³ cAutoriza  --> "*" Horas Autorizadas/Nao Autorizadas       ³±±
±±³          ³                "A" Horas Autorizadas                       ³±±
±±³          ³                "N" Horas Nao Autorizadas                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PONM010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CarExtAut( cCodExtras , cTnoCad , cAutoriza )

Local aTabExtra		:= {}
Local cFilSP4		:= fFilFunc("SP4")
Local cTno			:= ""
Local lFound		:= .F.
Local lRet			:= .T.
Local nX			:= 0
Local naTabExtra	:= 0
Local ncTurno	    := 0.00

Static aExtrasTno

If ( PCount() == 0.00 )

	aExtrasTno	:= NIL

Else

	DEFAULT aExtrasTno	:= {}

//-- Procura Tabela (Filial + Turno corrente)
	If ( lFound	:= ( SP4->( dbSeek( cFilSP4 + cTnoCad , .F. ) ) ) )
		cTno		:=	cTnoCad
		lFound	:=	.T.
	Else
//-- Procura Tabela (Filial)
		cTno	:= Space(Len(SP4->P4_TURNO))
		lFound	:= SP4->( dbSeek(  cFilSP4 + cTno , .F.) )
	Endif

//-- Se Existe Tabela de HE
	If ( lFound )
//-- Verifica se a Tabela de HE para o Turno ainda nao foi carregada
		If (ncTurno:=aScan(aExtrasTno,{|aTurno| aTurno[1]  == cFilSP4 .and. aTurno[2] == cTno} )) == 0.00
//-- Se nao Encontrou Carrega Tabela para Filial e Turno especificos
			GetTabExtra( @aTabExtra , cFilSP4 , cTno , .F. , .F. )
//-- Posiciona no inicio da Tabela de HE da Filial Solicitada
			If !Empty(aTabExtra)
				naTabExtra:=	Len(aTabExtra)
//-- Corre Codigos de Hora Extra da Filial
				For nX:=1 To naTabExtra
//-- Se Ambos os Tipos de Eventos ou Autorizados
					If cAutoriza == '*' .or. (cAutoriza == 'A' .and. !Empty(aTabExtra[nX,4]))
						cCodExtras += aTabExtra[nX,4]+'A' //-- Cod Autorizado
					Endif
//-- Se Ambos os Tipos de Eventos ou Nao Autorizados
					If cAutoriza == '*' .or. (cAutoriza == 'N' .and. !Empty(aTabExtra[nX,5]))
						cCodExtras += aTabExtra[nX,5]+'N' //-- Cod Nao Autorizado
					EndIf
				Next nX
			Endif
//-- Cria Nova Relacao de Codigos Extras para o Turno Lido
			aAdd(aExtrasTno,{cFilSP4,cTno,cCodExtras})
		Else
//-- Recupera Tabela Anteriormente Lida
			cCodExtras:=aExtrasTno[ncTurno,3]
		Endif

	Endif

Endif

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CarId    ³ Autor ³ Mauricio MR           ³ Data ³ 24/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna Relacao de Eventos da Filial						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFil       --> Codigo da Filial desejada					  ³±±
±±³          ³ aId    	  --> Array com a Relacao	                      ³±±
±±³          ³ cAutoriza  --> "*" Horas Autorizadas/Nao Autorizadas       ³±±
±±³          ³                "A" Horas Autorizadas                       ³±±
±±³          ³                "N" Horas Nao Autorizadas                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PONM010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CarId( cFil , aId , cAutoriza )

Local nPos	:= 0.00

//-- Preenche o Array aCodAut com os Eventos (Menos DSR Mes Ant.)
SP9->( dbSeek( cFil , .T. ) )
While SP9->( !Eof() .and. cFil == P9_FILIAL )
	IF ( ( Right(SP9->P9_IDPON,1) == cAutoriza ) .or. ( cAutoriza == "*" ) )
		aAdd( aId , Array( 04 ) )
		nPos := Len( aId )
		aId[ nPos , 01 ] := SP9->P9_CODIGO	//-- Codigo do Evento
		aId[ nPos , 02 ] := SP9->P9_IDPON 	//-- Identificador do Ponto
		aId[ nPos , 03 ] := SP9->P9_CODFOL	//-- Codigo do da Verba Folha
		aId[ nPos , 04 ] := SP9->P9_BHORAS	//-- Evento para B.Horas
	EndIF
	SP9->( dbSkip() )
EndDo

Return( NIL )









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
aAdd(_aRegs, {cPerg,"01","Data de                 ?", "",    "",    "MV_CH1","D", 08,     0,  0,     "G","",   "MV_PAR01","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "",    ""})
aAdd(_aRegs, {cPerg,"02","Data até                ?", "",    "",    "MV_CH2","D", 08,     0,  0,     "G","",   "MV_PAR02","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "",    ""})
aAdd(_aRegs, {cPerg,"03","Grupo PPR Equipes A     ?", "",    "",    "MV_CH3","C", 06,     0,  0,     "G","",   "MV_PAR03","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "SZ4", ""})
aAdd(_aRegs, {cPerg,"04","Indicador Produtividade ?", "",    "",    "MV_CH4","C", 06,     0,  0,     "G","",   "MV_PAR04","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "SZ5", ""})
aAdd(_aRegs, {cPerg,"05","Indicador Faturamento   ?", "",    "",    "MV_CH5","C", 06,     0,  0,     "G","",   "MV_PAR05","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "SZ5", ""})
aAdd(_aRegs, {cPerg,"06","Data faturamento de     ?", "",    "",    "MV_CH6","D", 08,     0,  0,     "G","",   "MV_PAR06","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "",    ""})
aAdd(_aRegs, {cPerg,"07","Data faturamento até    ?", "",    "",    "MV_CH7","D", 08,     0,  0,     "G","",   "MV_PAR07","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "",    ""})
aAdd(_aRegs, {cPerg,"08","Equipes                 ?", "",    "",    "MV_CH8","C", 99,     0,  0,     "R","",   "MV_PAR08","",   "",     "",     "AB9_CODTEC",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "AA1",    ""})

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
		//If _j <= len(_aRegs[_i]) .and. left(fieldname(_j), 6) != "X1_CNT" .and. fieldname(_j) != "X1_PRESEL"
		If _j <= len(_aRegs[_i]) .and. (left(fieldname(_j), 6) != "X1_CNT" .OR. ALLTRIM(SX1->X1_VAR01) == "MV_PAR08" ) .and. fieldname(_j) != "X1_PRESEL"
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
