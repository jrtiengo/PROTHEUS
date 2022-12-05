#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} UPDSRFSTAT
Programa para atualizar SRF
/*/
User Function UPDSRFSTAT()

    Local aArea    		:= GetArea()
	
	Private cDataIni 	:= "01/01/2019" //Alterar a Data Inicial e compilar
    Private cAliasSM0 	:= GetNextAlias()
	Private oTmpTbl   	:= FWTemporaryTable():New(cAliasSM0)
	Private cMark     	:= GetMark()
    Private oMsSelect 	:= Nil


    fMontaWizard()

	If oTmpTbl <> Nil
		oTmpTbl:Delete()
		oTmpTbl := Nil
	EndIf

    RestArea(aArea)

Return

/*/{Protheus.doc} fMontaWizard
Função para montar a Wizard de execução
/*/
Static Function fMontaWizard()

    Local aStruct   := {}
    Local cText1 	:= "Realize o backup da base antes de executar esse processo."
    Local cText2 	:= "Ferramenta para ajuste dos periodos de férias e status."
    Local cText3 	:= "UPDSRFSTAT - Atualizando o status de férias na SRF."
    Local cText4 	:= "Atualização a partir de " + cDataIni
    Local cValidFil := fValidFil()

    DbSelectArea("SM0")
	SM0->( dbGoTop() )

	aAdd(aStruct, { "EMPRESA", "C", Len(SM0->M0_CODIGO), 0} )
	aAdd(aStruct, { "FILIAL" , "C", FWGETTAMFILIAL     , 0} )
	aAdd(aStruct, { "MARK"   , "C", 02                 , 0} )
	aAdd(aStruct, { "NOME"   , "C", 20                 , 0} )

	oTmpTbl:SetFields(aStruct)
	oTmpTbl:AddIndex("INDEX1", {"EMPRESA", "FILIAL"})
	oTmpTbl:Create()

	If (cAliasSM0)->( EoF() )
		nRecSM0 := SM0->( Recno() )

		While SM0->( !Eof() )
			If AllTrim(SM0->M0_CODIGO) == cEmpAnt .And. AllTrim( SM0->M0_CODFIL ) $ cValidFil
				If RecLock(cAliasSM0, .T.)
					(cAliasSM0)->EMPRESA := SM0->M0_CODIGO
					(cAliasSM0)->FILIAL  := SM0->M0_CODFIL
					(cAliasSM0)->NOME    := SM0->M0_FILIAL
					(cAliasSM0)->MARK    := cMark
					(cAliasSM0)->( MsUnLock() )
				EndIf
			EndIf
			SM0->( dbSkip() )
		EndDo
	EndIf

	oWizard := APWizard():New( cText1, cText2, cText3, cText4, {||.T.}, {||.T.}, .F., Nil, {|| .T.}, Nil, {00, 00, 450, 600} )

    //Painel 2 - Seleção de Filiais
	oWizard:NewPanel(	"Seleção de Filiais"        							,;
						"Selecione as filiais cujos dados serão atualizados" 	,;
						{||.T.}        											,; //<bBack>
						{||.T.}        											,; //<bNext>
						{||.F.}        											,; //<bFinish>
						.T.            											,; //<.lPanel.>
						{|| GetFils() } ) 										   //<bExecute>

	//Painel 3 - Execução do processo
	oWizard:NewPanel(	"Realizando atualização da base..." 					,;
						"Aguarde enquanto o processamento é executado." 		,;
						{||.F.}                   								,; //<bBack>
						{||.F.}                   								,; //<bNext>
						{||.T.}                   								,; //<bFinish>
						.T.                       								,; //<.lPanel.>
						{| lEnd| fCallExec(@lEnd)}) 							   //<bExecute>

	oWizard:Activate( .T., {||.T.}, {||.T.}, {||.T.})

Return

/*/{Protheus.doc} fCallExec
Função para preparação e chamada da execução
/*/
Static Function fCallExec(lEnd)
	
	Private oProcess

	// Executa o processamento de atualização das faltas chamando a função fUpdPerSRF
	oProcess := MsNewProcess():New( {|lEnd| fUpdPerSRF(oProcess) }, "Executando atualização dos períodos aquisitivos...", "Executando atualização dos períodos aquisitivos..." )
	oProcess:Activate()

Return

/*/{Protheus.doc} fUpdPerSRF
Função que executa o processo de atualização da base atualizando as faltas na SRF de acordo com a SRD
/*/
Static Function fUpdPerSRF(lEnd)
	
	Local aCodFol    	:= {}
	Local aFil       	:= fGetFil()
	Local aLog		 	:= {}
	Local aTitle	 	:= {}
	Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
	Local aFldRel		:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {})
    Local aAfast        := {}

	Local cAliasQry1 	:= ""
	Local cSeekSRH   	:= ""
	Local cTitLog	 	:= "UPDSRF - Log de processamento"	
    Local cSRF_Fil      := ""  
    Local cSRF_Mat      := ""                    
    Local cSRF_PD       := ""
    Local cSRF_Stat     := "" 
    Local cMatAnt       := ""

    Local dSRF_DtAAtu   := CtoD("//")
    Local dSRF_DtBas    := CtoD("//")
    Local dSRF_DtFim    := CtoD("//")
    Local dSRH_DtBas    := CtoD("//")
	
	Local lAtualizou 	:= .F.	
	Local lBackup    	:= MsgYesNo("O backup da base já foi realizado?")
	Local lSRVComp   	:= Empty(xFilial("SRV"))
    Local lOfusca		:= Len(aFldRel) > 0
    Local lNaoExclui    := .F.

	Local nCont         := 0
	Local nDSusp        := 0
    Local nSRF_DDir     := 0     
  
    oProcess:SetRegua1(Len(aFil))

	SRA->( dbSetOrder(1) )//RA_FILIAL+RA_MAT+RA_NOME
	SRH->( dbSetOrder(1) )//RH_FILIAL+RH_MAT+DTOS(RH_DATABAS)+DTOS(RH_DATAINI)
                                                                                                                        
    If lBackup
        For nCont := 1 To Len(aFil)
            oProcess:IncRegua1("Filial sendo processada: " + aFil[nCont])

            If nCont == 1 .Or. !lSRVComp
                aCodFol := {}
				FP_CodFol( @aCodFol , xFilial("SRV",aFil[nCont]), .F., .F. )
            EndIf

            cAliasQry1 := GetNextAlias()
    

            BeginSql Alias cAliasQry1
                SELECT COUNT(*) CNT
				FROM %Table:SRF% SRF
				WHERE SRF.RF_FILIAL = %Exp:aFil[nCont]%				
				AND SRF.%NotDel%
            EndSql

            oProcess:SetRegua2( (cAliasQry1)->CNT )
            (cAliasQry1)->( dbCloseArea() )

            BeginSql Alias cAliasQry1
                SELECT SRF.R_E_C_N_O_ AS RECNO, SRF.RF_MAT AS MAT
				FROM %Table:SRF% SRF
				WHERE SRF.RF_FILIAL = %Exp:aFil[nCont]%
                AND SRF.RF_DATABAS >=  %Exp:DTOS(CTOD(cDataIni))%
                AND SRF.RF_PD = %Exp:aCodFol[0072,1]%
				AND SRF.%NotDel%
				ORDER BY SRF.RF_FILIAL,SRF.RF_MAT,SRF.RF_DATABAS
			EndSql
           
            While !(cAliasQry1)->( EOF() )
                               
                SRF->( dbGoTo( (cAliasQry1)->RECNO ) )
                
              	If SRA->( dbSeek( SRF->RF_FILIAL+SRF->RF_MAT ) )
					oProcess:IncRegua2( "Matrícula sendo processada: " + SRA->RA_MAT + If(lOfusca, "", " - " + Alltrim(SRA->RA_NOME)))
			
                    //Verifica se já tem Férias calculadas pro periodo
                    cSeekSRH := SRF->RF_FILIAL + SRF->RF_MAT + dToS(SRF->RF_DATABAS)
                    cSRF_Fil := SRF->RF_FILIAL 
                    cSRF_Mat := SRF->RF_MAT
                    If SRH->( DbSeek(cSeekSRH) )
                       
                        While !SRH->( EOF() ) .And. ( SRH->RH_FILIAL + SRH->RH_MAT == SRF->RF_FILIAL + SRF->RF_MAT )
                            dSRH_DtBas := SRH->RH_DATABAS
                            SRH->( dbSkip() )
                        EndDo
                        
						//Ultimo periodo de Férias calculado/Pagos
                        If SRF->( DbSeek(cSRF_Fil + cSRF_Mat + dtos(dSRH_DtBas)) )
                            cSRF_PD     := SRF->RF_PD
                            dSRF_DtBas  := SRF->RF_DATABAS
                            dSRF_DtFim  := SRF->RF_DATAFIM
                            dDtAux 		:= fCalcFimAq(dSRF_DtBas)
							dDtAux		:= IIf(Dtos(dDtAux) < Dtos(dSRF_DtFim), dDtAux, dSRF_DtFim)

                            // Verifica se teve Suspensão de Período Fechado
                            nDSusp := 0
                            aAfast := {}
                            fBuscaAfast(dSRH_DtBas, dDtAux, @aAfast)
                            Aeval( aAfast, { |x| iif( x[05]=="2", nDSusp += x[11] , 0 ) } )

                            If nDSusp > 0

								//Recalcula Data Final do Periodo fechado
								dSRF_DtFim  := fCalcFimAq(dSRF_DtBas) + nDSusp

								If dSRF_DtFim <> SRF->RF_DATAFIM
									lAtualizou := .T.
									Aadd( aLog, SRA->RA_FILIAL + Space(3) + SRA->RA_MAT + " - " + If(lOfusca, Replicate('*',30), Subs(SRA->RA_NOME,1,30)) + "Ultimo Periodo Fechado, teve a Data Final Alterada de " + DTOC(SRF->RF_DATAFIM) + " para "+DTOC(dSRF_DtFim) )

									If RecLock("SRF", .F.)
										SRF->RF_DATAFIM  := dSRF_DtFim  
										SRF->( MsUnlock() )
									EndIf
								EndIf

                                lNaoExclui := .F.
                                While !SRF->( EOF() ) .And. ( cSRF_Fil + cSRF_Mat == SRF->RF_FILIAL + SRF->RF_MAT )

                                    //Apaga periodos abertos
                                    If SRF->RF_STATUS == "1"

                                        //Exclui pois Não Teve Férias pagas
                                        If SRF->RF_DFERANT = 0
                                            lAtualizou  := .T.
                                            Aadd( aLog, SRA->RA_FILIAL + Space(3) + SRA->RA_MAT + " - " + If(lOfusca, Replicate('*',30), Subs(SRA->RA_NOME,1,30)) + "Periodo Excluído - " + DTOC(SRF->RF_DATABAS) + " à " + DTOC(SRF->RF_DATAFIM) )
                                            If RecLock("SRF", .F.)
                                                SRF->( dbDelete() )
                                                SRF->( MsUnlock() )
                                            EndIf

                                        //Não Exclui pois teve Férias Pagas
                                        Else
                                            lNaoExclui := .T.
                                            lAtualizou := .T.
                                            Aadd( aLog, SRA->RA_FILIAL + Space(3) + SRA->RA_MAT + " - " + If(lOfusca, Replicate('*',30), Subs(SRA->RA_NOME,1,30)) + "Periodo Não foi Excluído por ter dias de férias pagos - " + DTOC(SRF->RF_DATABAS) )
                                        EndIf
                                       
                                    EndIf
                                    SRF->( dbSkip() )
                                EndDo
                 
								//Cria Novo Periodo considerando Suspensoes do Periodo aberto
                                If !lNaoExclui
                                    dSRF_DtAAtu := dDatabase
                                    dSRF_DtBas  := dSRF_DtFim + 1

									dSRF_DtFim := fCalcFimAq(dSRF_DtBas)

									// Verifica se teve Suspensão no Período Aberto e soma da DTFIM
									nDSusp := 0
									aAfast := {}
									fBuscaAfast(dSRF_DtBas, dSRF_DtFim, @aAfast)
									Aeval( aAfast, { |x| iif( x[05]=="2", nDSusp += x[11] , 0 ) } )

                                    dSRF_DtFim  := fCalcFimAq(dSRF_DtBas + nDSusp)  
                                    nSRF_DDir   := 30                              
                                    cSRF_Stat   := "1"   
                                
                                    If RecLock("SRF", .T.)
                                        SRF->RF_FILIAL   := cSRF_Fil
                                        SRF->RF_MAT      := cSRF_Mat                   
                                        SRF->RF_PD       := cSRF_PD 
                                        SRF->RF_DATAATU  := dSRF_DtAAtu                        
                                        SRF->RF_DATABAS  := dSRF_DtBas 
                                        SRF->RF_DATAFIM  := dSRF_DtFim  
                                        SRF->RF_DIASDIR  := nSRF_DDir                                
                                        SRF->RF_STATUS   := cSRF_Stat    
                                        
                                        SRF->( MsUnlock() )
                                    EndIf
                                    lAtualizou := .T.
                                    Aadd( aLog, SRA->RA_FILIAL + Space(3) + SRA->RA_MAT + " - " + If(lOfusca, Replicate('*',30), Subs(SRA->RA_NOME,1,30)) + "Novo Período Incluido - "+Dtoc(dSRF_DtBas) + " à " + Dtoc(dSRF_DtFim)  )
                                EndIf
                            EndIf
                        EndIf
                    EndIf
				EndIf

                // Passar para próxima Matricula
                cMatAnt := (cAliasQry1)->MAT
                While !(cAliasQry1)->( EOF() ) .And. cMatAnt == MAT
                    (cAliasQry1)->( dbSkip() )
                EndDo
            EndDo
            
            (cAliasQry1)->( dbCloseArea() )
        Next nCont

        If lAtualizou
            MsgInfo("Períodos atualizados com sucesso")
            If Len(aLog) > 0
		        aTitle  := { "Filial" + Space(3) + "Mat.     Nome "  + Space(30) + "Ação" }
		        fMakeLog({aLog}, aTitle, Nil, Nil, "UPDSRFPEN_"+DTOS(DDATABASE), cTitLog, "M", "L", Nil, .F.) //"UPDSRF - Log de processamento"
		    EndIf
        Else
            MsgInfo("Não existem períodos incorretos na SRF")
        EndIf
    Else
        MsgInfo("Realize o backup e execute a rotina novamente.")
    EndIf

Return

/*/{Protheus.doc} GetFils
Monta tela para seleção de filiais
/*/
Static Function GetFils()
	
	Local aColumns    := {}
	Local cMarkAll    := cMark
	Local bMarkAll    := { || RhMkAll( cAliasSM0 , .F., .T. , 'MARK', @cMarkAll ,cMark ) }
	Local oPanel      := oWizard:oMPanel[oWizard:nPanel]

	(cAliasSM0)->( dbGoTop() )

	While (cAliasSM0)->(!Eof())
		If Empty((cAliasSM0)->MARK)
			cFilOk += AllTrim((cAliasSM0)->(EMPRESA)) + AllTrim((cAliasSM0)->(FILIAL)) + "*"
		Else
			cMark := (cAliasSM0)->MARK
		EndIf
		(cAliasSM0)->( dbSkip() )
	EndDo

	(cAliasSM0)->( dbGoTop() )

	If oMsSelect == Nil
		aAdd( aColumns, { "MARK"   , Nil, ''       , "@!" } )
		aAdd( aColumns, { "EMPRESA", Nil, "Empresa", "@!" } )
		aAdd( aColumns, { "FILIAL" , Nil, "Filial" , "@!" } )
		aAdd( aColumns, { "NOME"   , Nil, "Nome"   , "@!" } )

		oMsSelect := MsSelect():New( cAliasSM0      		,; //Alias do Arquivo de Filtro
										 "MARK"         	,; //Campo para controle do mark
										 NIL            	,; //Condicao para o Mark
										 aColumns       	,; //Array com os Campos para o Browse
										 NIL            	,; //
										 cMark          	,; //Conteudo a Ser Gravado no campo de controle do Mark
										 {10,12,150 ,285} 	,; //Coordenadas do Objeto
										 NIL            	,; //
										 NIL            	,; //
										 oPanel          	; //Objeto Dialog
										 )
		oMsSelect:oBrowse:lAllMark := .T.
		oMsSelect:oBrowse:bAllMark := bMarkAll
	EndIf

Return

/*/{Protheus.doc} RhMkAll
Marca todas as filiais
/*/
Static Function RhMkAll( cAlias, lInverte, lTodos, cCpoCtrl, cMark, cMarkAux )
	
	Local nRecno := (cAlias)->(Recno())

	(cAlias)->( dbGoTop() )
	While (cAlias)->( !Eof() )
		RhMkMrk( cAlias, lInverte, lTodos, cCpoCtrl, cMark, {}) 
		(cAlias)->( dbSkip() )
	EndDo
	(cAlias)->( MsGoto( nRecno ) )

	If cMark == cMarkAux
		cMark := ""
	Else
		cMark := cMarkAux
	EndIf

Return

/*/{Protheus.doc} fGetFil
Pega filiais selecionadas
/*/
Static Function fGetFil()
	
	Local aRet  := {}

	DbSelectArea(cAliasSM0)
	(cAliasSM0)->( dbGotop() )

	While (cAliasSM0)->( !Eof() )
		If !( Empty((cAliasSM0)->MARK) )
			aAdd( aRet, (cAliasSM0)->FILIAL )
		EndIf
		(cAliasSM0)->( dbSkip() )
	EndDo

Return aRet
