#INCLUDE "TopConn.ch"
#INCLUDE 'tbiconn.ch'
#INCLUDE "Protheus.ch"

/*
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#include "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#Include "FwPrintSetup.ch"
#Include "RptDef.CH"
*/

/*/{Protheus.doc} BACA001
Programa de Ajuste de Base de dados, para OP´s que não geraram Empenho de Mão de Obra MOD
@type function
@author Márcio Borges
@since 01/07/2021
/*/
User Function BACA001(aParam)



	Private lViaSchedule
	Private cRotina   := "BACA001"

	IF Type("dDatabase") == "U" // Se rodado via workflow a variável dDatabase estara disponivel somente apos o Prepare Environment
		lViaSchedule := .T.
	ELSE
		lViaSchedule := .F.
	ENDIF

	CONOUT(cRotina + " - Variével lViaSchedule :")
	CONOUT(lViaSchedule)


	IF lViaSchedule
		cEmp := aParam[01]
		cFil := aParam[02]
		//cUser:= aParam[03]

		conout( cRotina + " -  VIA Schedule - Preparando Environment")
		WFPrepEnv(cEmp,cFil,cRotina)
	ELSE
		Conout( cRotina + " -  VIA MENU    - Preparando Environment ")
	ENDIF

	//Ajusta Empenho

	Processa({|| AjustaEmp() },"Processando registros...")

	IF lViaSchedule
		Conout( cRotina + " -  VIA SCHEDULE    -  Job executado com sucesso.. FINALIZANDO ENVIRONMENT ")
		Reset Environment
	ELSE
		Conout( cRotina + " -  VIA MENU -  Job executado com sucesso.. FINALIZANDO ENVIRONMENT ")
	ENDIF

Return




Static Function AjustaEmp()

	Local cSql, cSql2, cSql3
	Local cAliasSQL := GetNextAlias() // Gera novo Alias para Consulta
	Local cAliasTMP := GetNextAlias() // Gera novo Alias para Consulta de Empenho
	Local cAliasAP	:= GetNextAlias() // Gera novo Alias para Consulta de Apontamentos
	Local aFieldAP 	:= {} 			  // Campos para Consulta de Apontamentos
	Local dBloqEst	:= MAX(SUPERGETMV("MV_ULMES",.f.,STOD(SPACE(8))),SUPERGETMV("MV_DBLQMOV",.f.,STOD(SPACE(8)))) //Bloqueia até a data
	Local aSetField := {}
	Local _nPos		:= 0
	Local _nCont	:= 0

	Local lProduzidos := .T.


	DBSelectArea("SD4")
	DBSetOrder(1)



	//------ Fields Consulta AP


	aTamSX3 := TamSX3("D3_QUANT")
	AADD(aFieldAP,{"D3_QUANT",aTamSX3[3],aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSX3("D3_EMISSAO")
	AADD(aFieldAP,{"D3_EMISSAO",aTamSX3[3],aTamSX3[1],aTamSX3[2]})


//------ Fields Consulta AP
	aTamSX3 := TamSX3("C2_QUANT")
	AADD(aSetField,{"QTD",aTamSX3[3],aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSX3("G1_QUANT")
	AADD(aSetField,{"QTD_A_EMP",aTamSX3[3],aTamSX3[1],aTamSX3[2]})
	aTamSX3 := TamSX3("C2_EMISSAO")
	AADD(aSetField,{"C2_EMISSAO",aTamSX3[3],aTamSX3[1],aTamSX3[2]})


	If lProduzidos
		// CONSULTA OPS ABERTAS, COM POSSÍVEIS PROBLEMAS DE EMPENHO.
		cSql := ""
		cSql += " SELECT  C2_QUANT QTD, C2_QUANT* G1_QUANT QTD_A_EMP, SC2.*, SG1.*, B1_APROPRI FROM SC2010 SC2  "
		cSql += " 				 		INNER JOIN SG1010 SG1"
		cSql += " 				 		 ON  G1_FILIAL = C2_FILIAL"
		cSql += " 				 		 AND G1_COD = C2_PRODUTO"
		cSql += " 				 		 AND SG1.D_E_L_E_T_  <> '*' AND  C2_REVISAO BETWEEN  G1_REVINI AND G1_REVFIM "
		//If YESNO("Filtrar Somente MOD?","Qry Seleção Dados")
		cSql += "						 AND G1_COMP LIKE 'MOD%'"
		//Endif
		cSql += " 				 			INNER JOIN SB1010 SB1"
		cSql += " 				 				ON  B1_FILIAL = G1_FILIAL "
		cSql += " 				 				AND B1_COD = G1_COMP"
		cSql += " 				 				AND SB1.D_E_L_E_T_  <> '*'"

		cSql += " 				 		 WHERE C2_FILIAL = '01' AND SC2.D_E_L_E_T_ <> '*'"

		//-- e não exista Empenho MOD para a OP
		cSql += " 				 	AND NOT EXISTS (SELECT  D4_QTDEORI, R_E_C_N_O_ NREG FROM SD4010 SD4 WHERE D4_FILIAL = C2_FILIAL AND D_E_L_E_T_  <> '*' AND D4_OP = C2_NUM+C2_ITEM + C2_SEQUEN  AND D4_PRODUTO = C2_PRODUTO AND D4_COD = G1_COMP)"
		//-- Que foram produzidas em a partir do ultimo fechamento
		cSql += " 				 	AND ( C2_QUJE = 0 OR   EXISTS(SELECT D3_IDENT, D3_NUMSEQ, * FROM SD3010 D3A WHERE D3_FILIAL = '01' AND D3A.D_E_L_E_T_ = ' ' AND D3_OP = C2_NUM+C2_ITEM + C2_SEQUEN AND  D3_COD = C2_PRODUTO AND D3_CF = 'PR0' "
		//cSql += " 				 	AND D3_EMISSAO  >  '" + DTOS(dBloqEst) + "'"
		cSql += " 				 	AND D3_EMISSAO  BETWEEN '" + DTOS(FirstDay(dBloqEst+1)) + "' AND '" + DTOS(LastDay(dBloqEst+1)) + "'"
		cSql += " 				 	AND D3_ESTORNO = ' '"
		cSql += " 				 						 		AND NOT EXISTS( SELECT 1  FROM SD3010 D3B WHERE D3B.D3_FILIAL = D3A.D3_FILIAL AND D3B.D_E_L_E_T_ = ' ' AND D3B.D3_OP = D3A.D3_OP AND D3_COD = G1_COMP AND D3B.D3_IDENT = D3A.D3_IDENT  AND D3_ESTORNO = ' ' ))"
		cSql += " 				 						 		)"

		//filtro de testes
		//cSql += " 					AND C2_NUM IN ('113124','113144','113145')"
		//ordenação
		cSql += " 				 	ORDER BY C2_NUM+C2_ITEM + C2_SEQUEN, G1_COD,G1_COMP"

	Else

	Endif

	MPSysOpenQuery( cSql,cAliasSQL, aSetField )

	DBSelectArea(cAliasSQL)
	Count To _nCont
	ProcRegua(_nCont)
	_nPos := 0
	Begin Transaction
		While (cAliasSQL)->(!EOF())
			_nPos++
			IncProc("Processando registro " + Alltrim(Str(_nPos)) + " de " +  Alltrim(Str(_nCont))  )

			//Verifica Se origem é do apontamento modelo 2  (RE1) ou modelo 1 (MATA250 RE2)

			//Busca Empenho e Cria Empenho se não existir
			cSql2 := "SELECT  D4_QTDEORI, R_E_C_N_O_ NREG  FROM " + RetSqlName("SD4")
			cSql2 += "	WHERE D4_FILIAL = '" + xFilial("SD4") + "' AND D_E_L_E_T_  <> '*' "
			cSql2 += "     AND D4_OP = '" + (cAliasSQL)->(C2_NUM + C2_ITEM + C2_SEQUEN) + "'  AND D4_PRODUTO = '" + (cAliasSQL)->C2_PRODUTO  + "' AND D4_COD LIKE '" + (cAliasSQL)->G1_COMP + "'"

			MPSysOpenQuery( cSql2,cAliasTMP )

			IF (cAliasTMP)->(EOF())



				cLocPad := Posicione("SB1",1,xFilial("SB1") + (cAliasSQL)->G1_COMP,"SB1->B1_LOCPAD")

				cRoteiro :=(cAliasSQL)->C2_ROTEIRO
				If Empty(cRoteiro)
					cRoteiro := SB1->B1_OPERPAD

					if Empty(cRoteiro)
						cRoteiro := '01'
					Endif
				Endif
				//SD4->(DBAppend(.F.))
				SD4->(RecLock("SD4",.T.))
				SD4->D4_FILIAL 	:= xFilial("SD4")
				SD4->D4_COD 	:= (cAliasSQL)->G1_COMP
				SD4->D4_LOCAL 	:= cLocPad
				SD4->D4_OP		:= (cAliasSQL)->(C2_NUM + C2_ITEM + C2_SEQUEN)
				SD4->D4_DATA	:= (cAliasSQL)->C2_EMISSAO
				SD4->D4_QTDEORI	:= (cAliasSQL)->QTD_A_EMP
				SD4->D4_QUANT	:= (cAliasSQL)->QTD_A_EMP
				SD4->D4_TRT		:= (cAliasSQL)->G1_TRT
				SD4->D4_PRODUTO	:= (cAliasSQL)->C2_PRODUTO
				SD4->D4_ROTEIRO	:= cRoteiro
				//SD4->(DBCommit())
				SD4->(MsUnlock())

				(cAliasTMP)->(DBCloseArea())

				//Busca Apontamento e Cria movimento se existir apontamento de PA sem MOD
				// Não existe SH6 pois o apontamento é Simples


				cSql3 := ""
				cSql3 += "SELECT * FROM SD3010 D3A WHERE D3_FILIAL = '" + SD4->D4_FILIAL  + "' AND D3A.D_E_L_E_T_ = ' ' AND D3_OP = '"+ SD4->D4_OP+"' AND D3_CF = 'PR0' AND  D3_COD = '"+ SD4->D4_PRODUTO +"'"
				cSql3 += "		AND NOT EXISTS( SELECT 1  FROM SD3010 D3B WHERE D3B.D3_FILIAL = D3A.D3_FILIAL AND D3B.D_E_L_E_T_ = ' ' AND D3B.D3_OP = D3A.D3_OP AND D3_COD = '"+ SD4->D4_COD + "' AND D3B.D3_IDENT = D3A.D3_IDENT )

				MPSysOpenQuery( cSql3,cAliasAP,aFieldAP )

				While  (cAliasAP)->(!EOF())

					If (cAliasAP)->D3_EMISSAO > dBloqEst

						//SD3->(DBAppend(.F.))
						SD3->(RecLock("SD3",.T.))
						SD3->D3_FILIAL 	:= xFilial("SD3")
						SD3->D3_TM 		:= '999'
						SD3->D3_COD 	:= (cAliasSQL)->G1_COMP
						SD3->D3_TIPO 	:= SB1->B1_TIPO
						SD3->D3_UM 		:= SB1->B1_UM
						SD3->D3_QUANT 	:= (cAliasAP)->D3_QUANT * (cAliasSQL)->G1_QUANT
						SD3->D3_OP		:= (cAliasSQL)->(C2_NUM + C2_ITEM + C2_SEQUEN)
						SD3->D3_CF 		:= If( SB1->B1_APROPRI == 'I', 'RE2','RE1')
						SD3->D3_GRUPO 	:= SB1->B1_GRUPO
						SD3->D3_LOCAL 	:= cLocPad
						SD3->D3_DOC 	:= (cAliasAP)->D3_DOC
						SD3->D3_CONTA	:= SB1->B1_CONTA
						SD3->D3_EMISSAO	:= (cAliasAP)->D3_EMISSAO
						SD3->D3_NIVEL	:= (cAliasSQL)->G1_NIVINV
						SD3->D3_NUMSEQ 	:= (cAliasAP)->D3_NUMSEQ
						SD3->D3_USUARIO := (cAliasAP)->D3_USUARIO
						SD3->D3_TRT		:= (cAliasSQL)->G1_TRT
						SD3->D3_IDENT	:= (cAliasAP)->D3_IDENT
						SD3->D3_CHAVE	:= 'E0'
						SD3->(MsUnLock())

						//Ajusta disponibilidade do empenho
						SD4->(RecLock("SD4",.F.))
						SD4->D4_QUANT	:= SD4->D4_QUANT - (cAliasAP)->D3_QUANT * (cAliasSQL)->G1_QUANT
						SD4->(MsUnLock())
					Else
						lforadata:=.t.

					Endif

					(cAliasAP)->(DBSkip())
				Enddo
			Endif
			(cAliasTMP)->(DBCloseArea())

			(cAliasSQL)->(DBSkip())
		Enddo
		(cAliasSQL)->(DBCloseArea())
	End Transaction

	MsgAlert("Processo executado com sucesso!")
Return
