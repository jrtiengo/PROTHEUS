#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"

/*/{Protheus.doc} User Function PgtFer927
Busca as verbas de base de 1/3 no acumulado gera no movimento mensal mensal para pagamento
@type  User Function
@author Cícero Alves
@since 15/05/2020
@version 12.1.xx
@see https://tdn.totvs.com/x/cvTAI
/*/
User Function PgtFer927()
	
	Local cDesc	:= "Realiza o lançamento no movimento mensal, das verbas de 1/3 de férias que foram geradas como base."
	Local cPerg	:= "PGTFER927"
	
	Private cAliasQry  := ""
	Private aLog 	   := {}
	Private aLogTitulo := {}
	Private lItemClVl  := GetMvRH( "MV_ITMCLVL", .F., "2" ) $ "1*3"
	
	// Verifica se o grupo de perguntas existe na base
	dbSelectarea("SX1")
	DbSetOrder(1)
	If ! dbSeek(cPerg)
		Help(" ", 1, "NOPERG")
		Return 
	EndIf
	If !dbSeek(cPerg+" 17")
		fAlert()
		Return 
	EndIf

	tNewProcess():New(cPerg, "Pagamento de 1/3 de férias MP-927", {|| ValidPerg()}, cDesc, cPerg,,,,,,.T.)
	
	fMakeLog( aLog, aLogTitulo, cPerg,,,,, "P")
	
Return

/*/{Protheus.doc} ValidPerg()
Valida o preenchimento das perguntas e executa a rotina de acordo com o escolhido
@type  Static Function
@author Cícero Alves
@since 18/05/2020
@version version
/*/
Static Function ValidPerg()
	
	Local cGrupo1 := ""
	Local cGrupo2 := ""
	Local cGrupo3 := ""
	Local lValido := .T.
	
	Pergunte("PGTFER927", .F.)
	
	// Verbas
	cGrupo1 := MV_PAR10 := Separa(MV_PAR10, 3, .F.) 
	MV_PAR11 := Separa(MV_PAR11, 3, .F.) 
	cGrupo2 := MV_PAR12 := Separa(MV_PAR12, 3, .F.) 
	MV_PAR13 := Separa(MV_PAR13, 3, .F.) 
	cGrupo3 := MV_PAR14 := Separa(MV_PAR14, 3, .F.) 
	MV_PAR15 := Separa(MV_PAR15, 3, .F.) 
	
	// Categorias
	MV_PAR05 := Separa(MV_PAR05, 1, .T.)
	
	// Situações
	MV_PAR06 := Separa(MV_PAR06, 1, .T.) 
	
	If Empty(MV_PAR10 + MV_PAR12 + MV_PAR14)
		lValido := .F.
		aAdd(aLogTitulo, "Informe as verbas de base")
		aAdd(aLog, {"É necessário informar um grupo de verbas base para realizar a busca no acumulado."})
	EndIf
	
	If (!Empty(MV_PAR10) .And. Empty(MV_PAR11)) .Or. (!Empty(MV_PAR12) .And. Empty(MV_PAR13)) .Or. (!Empty(MV_PAR14) .And. Empty(MV_PAR15))
		lValido := .F.
		aAdd(aLogTitulo, "Informe a verba para Pagamento")
		aAdd(aLog, {"Para cada grupo de verbas base informada é necessário preencher a verba correspondente para o pagamento."})
	EndIf
	
	If lValido
		Do Case
			Case MV_PAR09 == 1 // Gerar Verbas
				GeraVerbas(cGrupo1, cGrupo2, cGrupo3)
			Case MV_PAR09 == 2 // Excluir Lançamentos
				DeletaVer()
			Case MV_PAR09 == 3 // Relatório de valores não pagos
				ReportDef()
		EndCase
	EndIf
	
Return

/*/{Protheus.doc} GeraVerbas
Busca os valores na tabela de acumulados e gera nos lançamentos mensais
@type  Static Function
@author Cícero Alves
@since 18/05/2020
@param cGrupo1, Caracter, Grupo 1 de verbas de base
@param cGrupo2, Caracter, Grupo 2 de verbas de base
@param cGrupo3, Caracter, Grupo 3 de verbas de base
/*/
Static Function GeraVerbas(cGrupo1, cGrupo2, cGrupo3)
	
	Local cWhere 		:= GetWhere()
	Local cVerbaPgt		:= ""
	Local cChave		:= ""
	Local aPagamento	:= {}
	
	cAliasQry := GetNextAlias()
	
	BeginSQL ALIAS cAliasQry
		SELECT RD_FILIAL, RD_MAT, RD_PD, RD_VALOR, RD_CC, RD_PROCES, RD_ITEM, RD_CLVL, SRD.R_E_C_N_O_ AS RECNO
		FROM %Table:SRD% SRD, %Table:SRA% SRA
		WHERE SRD.RD_FILIAL = SRA.RA_FILIAL AND SRD.RD_MAT = SRA.RA_MAT
		AND SRD.RD_NUMID = ''
		AND %Exp: cWhere%
		AND SRD.%NotDel%
		AND SRA.%NotDel%
		ORDER BY RD_DATARQ, RD_FILIAL, RD_PROCES, RD_MAT, RD_CC
	EndSQL
	
	If (cAliasQry)->(EoF())
		aAdd(aLogTitulo, "Nenhum registro encontrado")
		aAdd(aLog, {"Não foi encontrada nenhuma verba no Acumulado, Tabela SRD, com os parâmetros informados."})
		Return
	EndIf
	
	While (cAliasQry)->(!EoF())
		
		If (cAliasQry)->RD_PD $ cGrupo1
			cVerbaPgt := MV_PAR11
			
		ElseIf (cAliasQry)->RD_PD $ cGrupo2
			cVerbaPgt := MV_PAR13
		Else
			cVerbaPgt := MV_PAR15
		EndIf
		
		cChave := (cAliasQry)->(RD_FILIAL + RD_MAT + cVerbaPgt + RD_CC )
		
		If (nPos := aScan(aPagamento, {|x| x[1] + x[2] + x[3] + x[4] == cChave})) > 0
			aPagamento[nPos][5] += (cAliasQry)->RD_VALOR
			aAdd(aPagamento[nPos][6], (cAliasQry)->RECNO)
		Else 
			(cAliasQry)->(aAdd(aPagamento, { RD_FILIAL, RD_MAT, cVerbaPgt, RD_CC, RD_VALOR, {RECNO}, RD_PROCES, If(lItemClVl,RD_ITEM,""), If(lItemClVl,RD_CLVL,"")}))
		EndIf
		
		(cAliasQry)->(dbSkip())
		
	EndDo
	
	(cAliasQry)->(dbCloseArea())
	
	GravaPgt(aPagamento)
	
Return

/*/{Protheus.doc} GravaPgt
Realiza a gravação da verba de pagamento na RGB e atualiza a SRD
@type  Static Function
@author Cícero Alves
@since 18/05/2020
@param aPagamento, Array, Array com as informações das verbas de pagamento
/*/
Static Function GravaPgt(aPagamento)
	
	Local nI, nJ, nR, nX
	Local nPosPag	:= 0
	Local cRoteiro	:= MV_PAR16
	Local aPerAtual	:= {}
	Local cLastFil	:= ""
	Local cLastProc	:= ""
	Local cLastMat	:= ""
	Local ctitulo	:= ""
	Local aLogRGB	:= {}
	Local aTransf	:= {}
	Local cFilAtu	:= ""
	Local cMatAtu	:= ""
	Local lTransf	:= .F.
	Local lTrfEmp	:= .F.
	
	Begin Sequence
	
	For nI := 1 To Len(aPagamento)
		
		If aPagamento[nI][1] != cLastFil .Or. aPagamento[nI][7] != cLastProc
			aPerAtual := {}
			cLastFil := aPagamento[nI][1]
			cLastProc := aPagamento[nI][7]
			// Busca o Perí­odo atual para o roteiro selecionado
			If ! fGetPerAtual( @aPerAtual, xFilial("RCJ", aPagamento[nI][1]), aPagamento[nI][7], cRoteiro )
				cTitulo := "O lançamento na RGB não foi realizado"
				aAdd(aLogRGB, "Não Existe perí­odo ativo. " + aPagamento[nI][1] + " Processo: " + aPagamento[nI][7] + " Roteiro: " + cRoteiro )
				LOOP
			EndIf
		EndIf

		If cLastMat != aPagamento[nI][1] + aPagamento[nI][2]
			cFilAtu		:= aPagamento[nI][1]
			cMatAtu		:= aPagamento[nI][2]
			cLastMat	:= cFilAtu + cMatAtu
			aTransf		:= {}
			lTransf		:= .F.
			lTrfEmp		:= .F.
			fTransf( @aTransf, Nil, Nil, Nil, Nil, Nil, .T., .T., Nil, Nil, Nil, Nil, cFilAtu, cMatAtu)
			For nX := 1 To Len( aTransf )
				If AnoMes( aTransf[nX, 7] ) <= aPerAtual[1][1] .And. ( (aTransf[nX, 1] != aTransf[nX, 4] .And. cEmpAnt != aTransf[nX, 4]) .Or. (aTransf[nX, 8] != aTransf[nX, 10]) )
					If cEmpAnt == aTransf[nX, 4]
						cFilAtu	:= aTransf[nX, 10]
						cMatAtu	:= aTransf[nX, 11]
					EndIf
					lTransf	:= .T.
					lTrfEmp := (aTransf[nX, 1] != aTransf[nX, 4])
				EndIf
			Next nX
			If lTransf .And. (lTransf .Or. cFilAtu+cMatAtu != aPagamento[nI][1]+aPagamento[nI][2])
				If lTrfEmp
					cTitulo := "O lançamento na RGB não foi realizado"
					aAdd(aLogRGB, "A verba " + aPagamento[nI][3] + " será gerada na empresa de destino.")
					aAdd(aLogRGB, "Funcionário" + ": " + cFilAtu + " - " + cMatAtu)
					Loop
				ElseIf ( nPosPag := aScan( aPagamento, { |x| x[1]+x[2] == cFilAtu+cMatAtu }, nI+1 ) ) > 0
					aPagamento[ nPosPag, 5 ] += aPagamento[ nI, 5 ]
					For nR := 1 To Len( aPagamento[ nI, 6 ] )
						aAdd( aPagamento[ nPosPag, 6 ], aPagamento[ nI, 6, nR ] )
					Next nR
					Loop
				EndIf
			EndIf
		EndIf

		dbSelectArea("RGB")
		dbSetOrder(1)
		
		If ! RGB->(dbSeek(cFilAtu + cMatAtu + aPagamento[nI][3] + aPerAtual[1][1] + aPerAtual[1][2]))
			RecLock("RGB", .T.)
				RGB->RGB_FILIAL	:= cFilAtu
				RGB->RGB_MAT	:= cMatAtu
				RGB->RGB_PROCES	:= aPagamento[nI][7]
				RGB->RGB_PERIOD	:= aPerAtual[1][1]
				RGB->RGB_SEMANA	:= aPerAtual[1][2]
				RGB->RGB_ROTEIR	:= cRoteiro
				RGB->RGB_PD		:= aPagamento[nI][3]
				RGB->RGB_VALOR	:= aPagamento[nI][5]
				RGB->RGB_TIPO1	:= PosSRV(aPagamento[nI][3], cFilAtu, "RV_TIPO" )
				RGB->RGB_CC		:= aPagamento[nI][4]
				RGB->RGB_TIPO2	:= "F"
				If !Empty(MV_PAR17)
					RGB->RGB_DTREF	:= MV_PAR17
				EndIf
				If lItemClVl
					RGB_ITEM	:= aPagamento[nI][8]
					RGB_CLVL 	:= aPagamento[nI][9]
				EndIf
			RGB->(MsUnlock())
			
			// Atualiza Acumulado para identificar que a verba já foi gerada
			dbSelectArea("SRD")
			For nJ := 1 To Len(aPagamento[nI][6]) 
				SRD->(dbGoTo(aPagamento[nI][6][nJ]))
				RecLock("SRD", .F.)
					// Período + Semana + Roteiro + Verba  
					SRD->RD_NUMID := aPerAtual[1][1] + aPerAtual[1][2] + cRoteiro + aPagamento[nI][3]
				SRD->(MsUnlock())
			Next nJ
			
		Else
			cTitulo := "O lançamento na RGB não foi realizado"
			aAdd(aLogRGB, "A verba " + aPagamento[nI][3] + " já existe nos lançamentos mensais.")
			aAdd(aLogRGB, "Funcionário" + ": " + cFilAtu + " - " + cMatAtu)
		EndIf
		
	Next nI
	
	End Sequence
	
	If !Empty(ctitulo)
		aAdd(aLogTitulo, ctitulo)
		aAdd(aLog, aLogRGB)
	ElseIf Empty(aLog)
		aAdd(aLogTitulo, "Geração concluí­da") 
		aAdd(aLog, {"A Geração das Verbas nos lançaamentos mensais foi concluí­da."})  
	EndIf
	
Return

/*/{Protheus.doc} DeletaVer
Exclui os lançamentos criados por essa rotina
@type  Static Function
@author Cícero Alves
@since 18/05/2020
/*/
Static Function DeletaVer()
	
	Local aTransf	:= {}
	Local cWhere 	:= ""
	Local cRoteiro	:= MV_PAR16
	Local cAliasSRD	:= GetNextAlias()
	Local cAliasSRD2:= GetNextAlias()
	Local nX		:= 0
	
	cAliasQry := GetNextAlias()
	
	MakeSqlExp("PGTFER927")
	
	cWhere := "RGB.RGB_PD IN ('" + MV_PAR11 + "','" + MV_PAR13 + "','" + MV_PAR15 + "')"	// Verbas de pagamento
	
	cWhere += If(!Empty(MV_PAR01), "AND " + MV_PAR01, "")									// Filiais 
	cWhere += If(!Empty(MV_PAR02), "AND " + MV_PAR02, "")									// Matrí­culas 
	cWhere += If(!Empty(MV_PAR03), "AND " + MV_PAR03, "")									// Centros de Custo
	cWhere += If(!Empty(MV_PAR04), "AND " + MV_PAR04, "")									// Sindicatos
	cWhere += If(!Empty(MV_PAR05), "AND " + MV_PAR05, "")									// Categorias
	cWhere += If(!Empty(MV_PAR06), "AND " + MV_PAR06, "")									// Situações
	cWhere += If(!Empty(MV_PAR16), "AND RGB.RGB_ROTEIR = '" + MV_PAR16 + "'", "")			// Roteiro
	
	cWhere := "%" + cWhere + "%" 
	
	Begin Sequence
	
	BeginSQL ALIAS cAliasQry
		SELECT DISTINCT(RGB.R_E_C_N_O_) AS RECNO, RGB_FILIAL, RGB_MAT, RGB_PD, RGB_VALOR, RGB_CC, RGB_PROCES, RGB_PERIOD, RGB_SEMANA, RGB_ROTEIR 
		FROM %Table:RGB% RGB, %Table:SRA% SRA, %Table:SRD% SRD
		WHERE RGB.RGB_FILIAL = SRA.RA_FILIAL AND RGB.RGB_MAT = SRA.RA_MAT
		AND RGB.RGB_ROTEIR = %Exp:cRoteiro%
		AND SRD.RD_NUMID = RGB.RGB_PERIOD || RGB.RGB_SEMANA || RGB.RGB_ROTEIR || RGB.RGB_PD
		AND %Exp:cWhere%
		AND RGB.%NotDel%
		AND SRA.%NotDel%
		AND SRD.%NotDel%
		ORDER BY RGB_FILIAL, RGB_MAT
	EndSQL
	
	If (cAliasQry)->(EoF())
		aAdd(aLogTitulo, "Nenhum registro encontrado")
		aAdd(aLog, {"Não foi encontrada nenhuma verba para exclusão nos lançamentos mensais, Tabela RGB, com os parâmetros informados."})
		Return
	EndIf
	
	
	While (cAliasQry)->(!EoF())
		
		BeginSQL ALIAS cAliasSRD
			SELECT SRD.R_E_C_N_O_ AS RECNO 
			FROM %Table:SRD% SRD
			WHERE SRD.RD_FILIAL = %Exp:(cAliasQry)->RGB_FILIAL%
			AND SRD.RD_MAT = %Exp:(cAliasQry)->RGB_MAT%
			AND SRD.RD_CC = %Exp:(cAliasQry)->RGB_CC%
			AND SRD.RD_NUMID = %Exp:(cAliasQry)->(RGB_PERIOD + RGB_SEMANA + RGB_ROTEIR + RGB_PD)%
			AND SRD.%NotDel%
		EndSQL
		
		While (cAliasSRD)->(!EoF())
			dbselectArea("SRD")
			SRD->(dbGoTo((cAliasSRD)->RECNO))
			If RecLock("SRD", .F.)
				SRD->RD_NUMID := ""
				SRD->(MsUnlock())
			EndIf

			aTransf := {}
			fTransf( @aTransf, Nil, Nil, Nil, Nil, Nil, .T., .T., Nil, Nil, Nil, Nil, (cAliasQry)->RGB_FILIAL, (cAliasQry)->RGB_MAT)
			For nX := 1 To Len( aTransf )
				If ( aTransf[nX, 1] == aTransf[nX, 4] .And. aTransf[nX, 8] != aTransf[nX, 10] )
					BeginSQL ALIAS cAliasSRD2
						SELECT SRD.R_E_C_N_O_ AS RECNO 
						FROM %Table:SRD% SRD
						WHERE SRD.RD_FILIAL = %Exp:aTransf[nX, 8]%
						AND SRD.RD_MAT = %Exp:aTransf[nX, 9]%
						AND SRD.RD_NUMID = %Exp:(cAliasQry)->(RGB_PERIOD + RGB_SEMANA + RGB_ROTEIR + RGB_PD)%
						AND SRD.%NotDel%
					EndSQL

					While (cAliasSRD2)->(!EoF())
						dbselectArea("SRD")
						SRD->(dbGoTo((cAliasSRD2)->RECNO))
						If RecLock("SRD", .F.)
							SRD->RD_NUMID := ""
							SRD->(MsUnlock())
						EndIf
						(cAliasSRD2)->(dbSkip())
					EndDo					
					(cAliasSRD2)->(dbCloseArea())
				EndIf
			Next nX

			(cAliasSRD)->(dbSkip())
		EndDo
		
		(cAliasSRD)->(dbCloseArea())
		
		dbselectArea("RGB")
		RGB->(dbGoTo((cAliasQry)->RECNO))
		RecLock("RGB", .F.)
			RGB->(dbDelete())
		RGB->(MsUnLock())
		RGB->(MsUnlock())
		
		(cAliasQry)->(dbSkip())
		
	EndDo
	
	End Sequence
	
	If Empty(aLogTitulo)
		aAdd(aLogTitulo, "Exclusão concluída") 
		aAdd(aLog, {"A exclusão das Verbas nos lançamentos mensais foi concluí­da."})
	EndIf
	
Return

/*/{Protheus.doc} ReportDef
Define as seções, células e totalizadores do relatório
@type  Static Function
@author Cícero Alves
@since 17/05/2020
@version 12.1.xx
@see https://tdn.totvs.com/x/vonlG
/*/
Static Function ReportDef()
	
	Local cDesc := "Demonstra os valores das verbas de 1/3 de férias que foram geradas como base e ainda não foram pagas"
	
	Local oFuncSec
	Local oLanSec
	Local oBreakFun
	Local oBreakCC
	Local oBreakFil
	Local cTotCC, cTotFil := ""
	
	Private oReport := TReport():New( "PGTFER927", "Valores de 1/3 não pagos", "PGTFER927", {|oReport| PrintReport(oReport) }, cDesc,,,,,,, 3)
	
	// Informações do funcionário
	DEFINE SECTION oFuncSec OF oReport TITLE "Funcionário" TABLES "SRD", "SRA", "CTT"
		DEFINE CELL NAME "RD_FILIAL"  OF oFuncSec ALIAS "SRD" BLOCK {|| oReport:SkipLine(), (cAliasQry)->RD_FILIAL }
		DEFINE CELL NAME "RA_MAT"     OF oFuncSec ALIAS "SRA"
		DEFINE CELL NAME "RA_NOME"    OF oFuncSec ALIAS "SRA"
		DEFINE CELL NAME "RD_CC"	  OF oFuncSec ALIAS "SRD"
		DEFINE CELL NAME "CTT_DESC01" OF oFuncSec ALIAS "CTT" TITLE "Centro de Custo" SIZE 40 BLOCK {|| (cAliasQry)->RD_CC + " - " + (cAliasQry)->CTT_DESC01 }
		
		oFuncSec:SetLineStyle()
		oFuncSec:SetTotalInLine(.F.)
		oFuncSec:Cell("RD_CC"):Disable()
	
	// Valores
	DEFINE SECTION oLanSec OF oFuncSec TITLE "Verbas" TABLES "SRD", "SRV"
		DEFINE CELL NAME "ESPACO"     	OF oLanSec TITLE "" BLOCK {|| "		"}	
		DEFINE CELL NAME "RD_MAT" 		OF oLanSec ALIAS "SRD"
		DEFINE CELL NAME "RD_PD"  		OF oLanSec ALIAS "SRD" TITLE "Verba"
		DEFINE CELL NAME "RV_DESC" 		OF oLanSec ALIAS "SRV" 
		DEFINE CELL NAME "RD_DATPGT" 	OF oLanSec ALIAS "SRD" TITLE "Data do Pagamento" 
		DEFINE CELL NAME "RD_VALOR"		OF oLanSec ALIAS "SRD" 
		
		oFuncSec:SetLineStyle()
		oLanSec:SetTotalInLine(.F.)
		oLanSec:Cell("RD_MAT"):Disable()
		oLanSec:Cell("RD_VALOR"):SetHeaderAlign("RIGHT")
	
	// Total do funcionário
	DEFINE BREAK oBreakFun OF oFuncSec TITLE "Total do Funcionário" WHEN {|| RA_FILIAL + RA_MAT }
	DEFINE FUNCTION NAME "TOTALFUN" FROM oLanSec:Cell("RD_VALOR") FUNCTION SUM BREAK oBreakFun NO END SECTION NO END REPORT PICTURE "@E 99,999,999,999.99"
	oBreakFun:SetTotalInLine(.F.)
	
	// Total do centro de custo
	DEFINE BREAK oBreakCC OF oReport WHEN oFuncSec:Cell("RD_CC")
	DEFINE FUNCTION NAME "TOTALCC" FROM oLanSec:Cell("RD_VALOR") FUNCTION SUM BREAK oBreakCC NO END SECTION NO END REPORT PICTURE "@E 99,999,999,999.99"
	oBreakCC:OnBreak({|x|  oReport:SkipLine(), cTotCC := "Total do Centro de Custo " + x })
	oBreakCC:SetTotalText({|| cTotCC })
	oBreakCC:SetTotalInLine(.F.)
	
	// Total da Filial
	DEFINE BREAK oBreakFil OF oReport WHEN oFuncSec:Cell("RD_FILIAL")
	DEFINE FUNCTION NAME "TOTALFIL" FROM oLanSec:Cell("RD_VALOR") FUNCTION SUM BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 99,999,999,999.99"
	oBreakFil:OnBreak({|x|  oReport:SkipLine(), cTotFil := "Total da Filial " + x })
	oBreakFil:SetTotalText({|| cTotFil })
	oBreakFil:SetTotalInLine(.F.)
	
	oReport:PrintDialog()
	
Return

/*/{Protheus.doc} PrintReport
Busca as informações e imprime o relatório
@type  Static Function
@author Cícero Alves
@since 17/05/2020
@param oReport, Objeto, Instância da classe TReport
/*/
Static Function PrintReport(oReport)
	
	Local cWhere	:= GetWhere()
	Local cJoin		:= "%" + FWJoinFilial( "SRD", "CTT") + "%"
	Local cJoinSRV	:= "%" + FWJoinFilial( "SRD", "SRV") + "%"
	
	cAliasQry := GetNextAlias()
	
    BEGIN REPORT QUERY oReport:Section(1)
		
		BeginSql alias cAliasQry
			COLUMN RD_DATPGT AS DATE
			SELECT CTT_DESC01, RA_FILIAL, RA_MAT, RA_NOME, RV_DESC, RD_FILIAL, RD_MAT, RD_PD, RD_VALOR, RD_DATARQ, RD_DATPGT, RD_CC, RD_PROCES, RD_PERIODO
			FROM %Table:CTT% CTT, %Table:SRD% SRD, %Table:SRV% SRV, %Table:SRA% SRA
			WHERE %Exp:cJoinSRV% AND SRV.RV_COD = SRD.RD_PD
			AND SRD.RD_FILIAL = SRA.RA_FILIAL AND SRD.RD_MAT = SRA.RA_MAT
			AND %Exp:cJoin% AND CTT.CTT_CUSTO = SRD.RD_CC
			AND SRD.RD_NUMID = ''
			AND %Exp: cWhere%
			AND SRD.%NotDel%
			AND SRA.%NotDel%
			AND SRV.%NotDel%
			AND CTT.%NotDel%
			ORDER BY RD_FILIAL, RD_CC, RD_MAT
		EndSQL
		
	END REPORT QUERY oReport:Section(1)
	
	oReport:Section(1):Section(1):SetParentQuery()
    oReport:Section(1):Section(1):SetParentFilter({|cParam| (cAliasQry)->(RD_FILIAL + RD_MAT) == cParam}, {|| (cAliasQry)->(RA_FILIAL + RA_MAT)})
	
	oReport:Section(1):Print()
	
	(cAliasQry)->(dbCloseArea())
	
Return

/*/{Protheus.doc} GetWhere
Constroi a cláusula Where para busca conforme as informações passadas nas perguntas
@type  Static Function
@author Cícero Alves
@since 18/05/2020
@return cWhere, Caractere, clausula Where em SQL
/*/
Static Function GetWhere()
	
	Local cWhere := ""
	
	MakeSqlExp("PGTFER927")
	
	cWhere := If(!Empty(MV_PAR10), MV_PAR10, '')											// Verbas base 1
	cWhere += If(!Empty(MV_PAR12), If(!Empty(cWhere), " OR " + MV_PAR12, ''), '')			// Verbas base 2
	cWhere += If(!Empty(MV_PAR14), If(!Empty(cWhere), " OR " + MV_PAR14, ''), '')			// Verbas base 3
	cWhere := "( " + cWhere + " )"
	cWhere += If(!Empty(MV_PAR01), "AND " + MV_PAR01, "")									// Filiais
	cWhere += If(!Empty(MV_PAR02), "AND " + MV_PAR02, "")									// Matrículas
	cWhere += If(!Empty(MV_PAR03), "AND " + MV_PAR03, "")									// Centros de Custo 
	cWhere += If(!Empty(MV_PAR04), "AND " + MV_PAR04, "")									// Sindicatos
	cWhere += If(!Empty(MV_PAR05), "AND " + MV_PAR05, "")									// Categorias
	cWhere += If(!Empty(MV_PAR06), "AND " + MV_PAR06, "")									// Situações
	cWhere += If(!Empty(MV_PAR07), "AND " + "RD_DATPGT >= '" + dToS(MV_PAR07) + "'", "")	// Data de Pagamento De
	cWhere += If(!Empty(MV_PAR08), "AND " + "RD_DATPGT <= '" + dToS(MV_PAR08) + "'", "") 	// Data de Pagamento Até
	
	cWhere := "%" + cWhere + "%" 
	
Return cWhere

/*/{Protheus.doc} Separa
Inclui um separador entre os caracteres de um texto
@type  Static Function
@author Cícero Alves
@since 17/05/2020
@param cTexto, Caractere, Texto que serÃ¡ alterado
@param nCaracter, Numérico, Frequência para inclusão do separador
@param lAspas, Lógico, Indica se inclui aspas simples 
@return cSeparado, Caractere, cTexto com o separador incluído na frequência indicada
@example Separa("123456789", 3, .T.) => "'123';'456';'789'"
/*/
Static Function Separa(cTexto, nCaracter, lAspas)
	
	Local cSeparado := ""
	Local cPedaco	:= ""
	Local nI
	
	For nI := 1 To Len(RTrim(cTexto)) STEP nCaracter
		If AllTrim((cPedaco := SubStr( cTexto, nI, nCaracter))) != "*"
			If lAspas
				cSeparado += "'" + cPedaco + "';"
			Else
				cSeparado += cPedaco + ";"
			EndIf
		EndIf
	Next
	
	// Reitra o último caracter
	cSeparado := Left(cSeparado, Len(cSeparado) - 1)
	
Return cSeparado

//-------------------------------------------------------------------
/*/{Protheus.doc} fAlert
Função para exibição de alerta e link para o TDN
@author  allyson.mesashi
@since   14/12/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function fAlert()
Local oButton1
Local oButton2
Local oCheckBo1
Local lCheckBo1 := .F.
Local oGroup1
Local oPanel1
Local oSay1
Local cSession	:= "AlertaPGT927"
Local lChkMsg 	:= fwGetProfString(cSession, "MSG_PGT927_" + cUserName,'',.T.) == ""
Local oDlg

lChkMsg 	:= fwGetProfString(cSession, "MSG_PGT927_" + cUserName,'',.T.) == ""

If lChkMsg

	DEFINE MSDIALOG oDlg TITLE OemToAnsi("Dicionário de perguntas") FROM 000, 000  TO 200, 500 COLORS 0, 16777215 PIXEL

		@ 000, 000 MSPANEL oPanel1 SIZE 300, 150 OF oDlg COLORS 0, 16777215 RAISED
		@ 005, 012 GROUP oGroup1 TO 055, 237 PROMPT OemToAnsi("Atenção") OF oPanel1 COLOR 0, 16777215 PIXEL
		@ 022, 017 SAY oSay1 PROMPT OemToAnsi('É necessário possuir a pergunta 17 no dicionário de dados. Clique em "Abrir Link" para consultar a documentação no TDN') SIZE 215, 025 OF oPanel1 COLORS 0, 16777215 PIXEL
		@ 080, 012 CHECKBOX oCheckBo1 VAR lCheckBo1 PROMPT OEMToAnsi("Não exibir novamente") SIZE 067, 008 OF oPanel1 COLORS 0, 16777215 PIXEL
		@ 070, 160 BUTTON oButton1 PROMPT "Abrir Link" SIZE 037, 012 OF oPanel1 PIXEL
		@ 070, 200 BUTTON oButton2 PROMPT "OK" SIZE 037, 012 OF oPanel1 PIXEL

		oButton1:bLClicked := {|| ShellExecute("open","https://tdn.totvs.com/x/d2VyIg","","",1) }
		oButton2:bLClicked := {|| oDlg:End() }

	ACTIVATE MSDIALOG oDlg CENTERED

	If lCheckBo1
		fwWriteProfString(cSession, "MSG_PGT927_" + cUserName, 'CHECKED', .T.)
	Endif
	
Endif

Return
