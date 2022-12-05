#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} UPDSRFPEN
Programa para atualizar os periodos pre-escritos criados equivocadamente
/*/
User Function UPDSRFPEN()

    Local aArea    		:= GetArea()

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
    Local cText2 	:= "Ferramenta para ajuste dos dias de férias pendentes e dias antecipados."
    Local cText3 	:= "UPDSRFPEN - Atualizando os períodos na SRF."
    Local cText4 	:= ""
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
	Local cAliasQry1 	:= ""
	Local cSeekSRH   	:= ""
	Local cTitLog	 	:= "UPDSRF - Log de processamento"	
	Local lAtualizou 	:= .F.	
	Local lBackup    	:= MsgYesNo("O backup da base já foi realizado?")
	Local lSRVComp   	:= Empty(xFilial("SRV"))
	Local nCont         := 0
	Local nTotDias		:= 0	
	
	Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
	Local aFldRel		:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {})
	Local lOfusca		:= Len(aFldRel) > 0

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
				AND SRF.RF_DVENPEN > 0
				AND SRF.%NotDel%
            EndSql

            oProcess:SetRegua2( (cAliasQry1)->CNT )
            (cAliasQry1)->( dbCloseArea() )

            BeginSql Alias cAliasQry1
                SELECT SRF.R_E_C_N_O_ AS RECNO
				FROM %Table:SRF% SRF
				WHERE SRF.RF_FILIAL = %Exp:aFil[nCont]%
				AND SRF.RF_DVENPEN > 0
				AND SRF.%NotDel%
				ORDER BY SRF.RF_FILIAL,SRF.RF_MAT,SRF.RF_DATABAS
			EndSql

            While !(cAliasQry1)->( EOF() )
				SRF->( dbGoTo( (cAliasQry1)->RECNO ) )
				If SRA->( dbSeek( SRF->RF_FILIAL+SRF->RF_MAT ) )
					oProcess:IncRegua2( "Matrícula sendo processada: " + SRA->RA_MAT + If(lOfusca, "", " - " + Alltrim(SRA->RA_NOME)))
					
					cSeekSRH := SRF->RF_FILIAL + SRF->RF_MAT + dToS(SRF->RF_DATABAS)
					lCorrige := .F.
					nTotDias := 0

					If SRH->( DbSeek(cSeekSRH) )
						While SRH->(!Eof() .And. RH_FILIAL + RH_MAT + dToS(RH_DATABAS) == cSeekSRH )
							nTotDias += SRH->RH_DFERIAS + SRH->RH_DABONPE
							SRH->( dbSkip() )
						EndDo
					EndIf

					If SRF->RF_DVENPEN != (SRF->RF_DIASDIR - nTotDias)
						lAtualizou 	:= .T.
						lCorrige 	:= .T.
						Aadd( aLog, SRA->RA_FILIAL + Space(3) + SRA->RA_MAT + " - " + If(lOfusca, Replicate('*',30), Alltrim(SRA->RA_NOME)) )
					EndIf
					If lCorrige .And. RecLock("SRF", .F.)
						SRF->RF_DFERANT := nTotDias
						SRF->RF_DVENPEN := (SRF->RF_DIASDIR - nTotDias)
						SRF->( MsUnlock() )
					EndIf
				EndIf
                (cAliasQry1)->( dbSkip() )
            EndDo

            (cAliasQry1)->( dbCloseArea() )
        Next nCont

        If lAtualizou
            MsgInfo("Períodos atualizados com sucesso")
            If Len(aLog) > 0
		        aTitle  := { "Filial" + Space(3) + "Mat.     Nome   " }
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
	Local bMarkAll    := { || RhMkAll( cAliasSM0 , .F., .T. , 'MARK', @cMarkAll ,cMark ) }
	Local cMarkAll    := cMark
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
