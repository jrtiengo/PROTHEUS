#Include 'Protheus.ch'

User Function SOLRH10()

	Local aParamBox	:= {}
	Local aRet		:= {}
	Local cMatricula:= Space(6)
	
	aAdd( aParamBox, { 1, "Matricula",cMatricula	   ,"","","","", 40,.F. })
					
	If ParamBox(aParamBox,"Informe a sugestão de limite para alteração",@aRet)		 
		Processa({|| procUpdt(aRet[1]) },"Processando", "Listando Matriculas") // Chamada para matricula especifica
		//Processa({|| procUpdt(cMatricula) },"Processando", "Listando Matriculas") //Chamada para todas as matriculas
	EndIf
	
Return

Static Function procUpdt(cMatric)

	Local nValEmp := 0
	Local cPlano  := ""
	Local dDataPer:= CtoD("  /  /  ")
	Local cOrigem := ""
	Local cCodigo := ""
	Local dDataPer:= CtoD("  /  /  ")
	Local cAliasQry := GetNextAlias()
	Local cAliasRHS := GetNextAlias()
	Local cQuery
	Local nReg := 0
	Local nI	:= 0
	Local lAchou := .F.
	
	ProcRegua(0)
	IncProc("Buscando Arquivos...")
	MsgInfo("Realizando a Query")
	cQuery := " SELECT SRD.RD_FILIAL, SRD.RD_PD, SRD.RD_DATARQ, SRD.RD_DATPGT,SRD.RD_MAT, SUM(SRD.RD_VALOR) AS RD_VALOR  "
	cQuery += "  FROM " + RetSQLName("SRD") +" SRD "
	cQuery += " WHERE SRD.RD_FILIAL = '" + xFilial("SRD") + "' "
	cQuery += "   AND SRD.RD_PD IN ('415','502','465','466' ) "
	cQuery += "   AND SRD.RD_DATPGT BETWEEN '20190101' AND '20191231' "
	if !empty(cMatric)
		cQuery += "   AND SRD.RD_MAT = '"+cMatric+"' "
	Endif
	cQuery += "   AND SRD.D_E_L_E_T_ <> '*' "
	cQuery += " GROUP BY SRD.RD_FILIAL, SRD.RD_PD, SRD.RD_DATARQ, SRD.RD_DATPGT,SRD.RD_MAT"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T. )
	Count to nReg
	dbGoTop()
	ProcRegua(nReg)
	MsgInfo("Encontrados "+cValToChar(nReg)+" Registros")
	
	While(cAliasQry)->(!EoF())
		nI += 1
		IncProc("Processando registros...      "+cValToChar(nI)+"/"+cValToChar(nReg))	
		cMatric := (cAliasQry)->RD_MAT
		If (cAliasQry)->RD_PD $ '415/502'
			nValEmp := Iif( (cAliasQry)->RD_PD = "415", Posicione("SRD", 6, xFilial("SRD")+ cMatric+"782", "RD_VALOR"), 0)
			cPlano	:= Posicione("RHL", 1, xFilial("RHL")+ cMatric, "RHL_PLANO" )
			dDataPer:= Posicione("RCH", 4, xFilial("RCH")+"00001"+"PLA"+(cAliasQry)->RD_DATARQ, "RCH_DTPAGO")
			cCodigo	:= Iif( (cAliasQry)->RD_PD = "502", Posicione("RHR", 1, xFilial("SRD")+cMatric+(cAliasQry)->RD_DATARQ, "RHR_CODIGO"), "  ")
			cOrigem := Iif((cAliasQry)->RD_PD = "415", "1", "2")
			cPlano := Iif(!Empty(cPlano), cPlano, "  ")
			
			dbSelectArea("RHS")
			dbSetOrder(1)			
			//RHS_FILIAL+RHS_MAT+RHS_COMPPG+RHS_ORIGEM+RHS_CODIGO+RHS_TPLAN+RHS_TPFORN+RHS_CODFOR+RHS_TPPLAN+RHS_PLANO+RHS_PD
			//dbSeek((cAliasQry)->RD_FILIAL + (cAliasQry)->RD_MAT + (cAliasQry)->RD_DATARQ+cOrigem+"  "+"1"+"1"+"001"+"1"+cPlano+	(cAliasQry)->RD_PD )
			
			//SELECT * FROM RHS010 WHERE RHS_FILIAL = '01' AND RHS_MAT = '003269' AND RHS_PD = '502' AND RHS_COMPPG = '201812' AND RHS_ORIGEM = '2' AND D_E_L_E_T_ <>'*'
			cSql := 'SELECT  COUNT(1) OVER ( PARTITION BY  RHS_FILIAL + RHS_MAT +  RHS_COMPPG  + RHS_PD ) AS QTDREG, R_E_C_N_O_ RCNO FROM ' + RetSqlName("RHS") + " WHERE RHS_FILIAL = '"+ (cAliasQry)->RD_FILIAL +"' AND RHS_MAT = '"+ (cAliasQry)->RD_MAT +"' AND RHS_PD = '" + (cAliasQry)->RD_PD + "'" 
			cSql += " AND RHS_COMPPG = '"+(cAliasQry)->RD_DATARQ +"' AND RHS_ORIGEM = '"+ cOrigem +"' AND D_E_L_E_T_ <>'*'"
			dbUseArea( .T.,"TOPCONN",TcGenQry(,,cSql),cAliasRHS,.F.,.T. )
			
			
			
			If Empty((cAliasRHS)->RCNO)
				
				RecLock("RHS",.T.)
					
					RHS->RHS_FILIAL	:= (cAliasQry)->RD_FILIAL 
					RHS->RHS_MAT	:= (cAliasQry)->RD_MAT
					RHS->RHS_PD		:= (cAliasQry)->RD_PD
					RHS->RHS_VLRFUN	:= (cAliasQry)->RD_VALOR/(cAliasRHS)->QTDREG 
					RHS->RHS_COMPPG	:= (cAliasQry)->RD_DATARQ 
					RHS->RHS_DATPGT	:= StoD((cAliasQry)->RD_DATPGT) 
					RHS->RHS_ORIGEM	:= cOrigem
					RHS->RHS_CODIGO	:= cCodigo
					RHS->RHS_TPFORN	:= '1'
					RHS->RHS_CODFOR	:= '001'
					RHS->RHS_TPLAN	:= '1'
					RHS->RHS_TPPLAN	:= '1'
					RHS->RHS_PLANO	:= cPlano
					RHS->RHS_VLREMP	:= nValEmp 
					RHS->RHS_DATA	:= dDataPer
					RHS->RHS_TIPO	:= '1'			
				MsUnlock()
				
			Else
				RHS->(DBGOTOP())
				RHS->(DBGOTO((cAliasRHS)->RCNO))
				RecLock("RHS",.F.)
					RHS->RHS_VLRFUN	:= (cAliasQry)->RD_VALOR/(cAliasRHS)->QTDREG 
				MsUnlock()
			EndIf
			(cAliasRHS)->(DBCloseArea())
		Else
			
			dDataPer:= Posicione("RCH", 4, xFilial("RCH")+"00001"+"PLA"+(cAliasQry)->RD_DATARQ, "RCH_DTPAGO")
			
			dbSelectArea("RHP")
			dbSetOrder(2)
			dbSeek((cAliasQry)->RD_FILIAL +(cAliasQry)->RD_MAT+(cAliasQry)->RD_DATARQ )

			lAchou := .F.
			If Found()
				While (cAliasQry)->RD_FILIAL +(cAliasQry)->RD_MAT+(cAliasQry)->RD_DATARQ == RHP->(RHP_FILIAL + RHP_MAT + RHP_COMPPG)
					IF (cAliasQry)->RD_PD == RHP->RHP_PD
						RecLock("RHP",.F.)
						RHP->RHP_VLRFUN	:= (cAliasQry)->RD_VALOR
						MsUnlock()
						lAchou := .T.
						Exit // Saise encontrou a Verba
					
					ENDIF
					
					RHP->(dbSkip())
				Enddo



			ENDIF

			If !lAchou
				
				RecLock("RHP",.T.)
				RHP->RHP_FILIAL	:= (cAliasQry)->RD_FILIAL 
				RHP->RHP_MAT	:= (cAliasQry)->RD_MAT
				RHP->RHP_PD		:= (cAliasQry)->RD_PD
				RHP->RHP_VLRFUN	:= (cAliasQry)->RD_VALOR  
				RHP->RHP_COMPPG	:= (cAliasQry)->RD_DATARQ 
				RHP->RHP_DATPGT	:= StoD((cAliasQry)->RD_DATPGT) 
				RHP->RHP_ORIGEM	:= '1'
				RHP->RHP_TPFORN	:= '1'
				RHP->RHP_CODIGO	:= ' '
				RHP->RHP_CODFOR	:= '001'
				RHP->RHP_TPLAN	:= '1'
				RHP->RHP_VLREMP	:= 0 
				RHP->RHP_DTOCOR	:= dDataPer 
				
				MsUnlock()

			
			EndIf
			
		EndIf
		
		(cAliasQry)->(dbSkip())
		
	EndDo
	MsgInfo("Final do Processo...")
	(cAliasqry)->(DBCloseArea())
Return

