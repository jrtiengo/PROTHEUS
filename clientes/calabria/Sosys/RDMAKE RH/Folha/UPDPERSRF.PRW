#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} UPDPERSRF
Programa para atualizar as faltas na SRF de acordo com a SRD
@author  Leandro Drumond
@since   23/07/2019
@version 1.0
/*/
User Function UPDPERSRF()
    Local aArea    := GetArea()

    fMontaWizard()
    RestArea(aArea)
Return

/*/{Protheus.doc} fMontaWizard
Função para montar a Wizard de execução
@author  Leandro Drumond
@since   23/07/2019
@version 1.0
/*/
Static Function fMontaWizard()
    Local cText1 := "Realize o backup da base antes de executar esse processo."
    Local cText2 := "Ferramenta para ajuste de períodos indevidos criados no Controle de Dias de Direito (SRF)."
    Local cText3 := "UPDPERSRF - Atualizando os períodos na SRF."
    Local ctext4 := "Ao final do processamento os períodos posteriores ao período ativo de cada funcionário das filiais selecionadas serão excluídos da SRF."
    
    Local cValidFil := fValidFil()
    Local aStruct   := {}

    Private cAliasSM0 := GetNextAlias()
	Private oTmpTbl   := FWTemporaryTable():New(cAliasSM0)
	Private cMark     := GetMark()
    Private oMsSelect := Nil

    DbSelectArea("SM0")
	SM0->(DbGoTop())
	
	aAdd(aStruct, { "EMPRESA" ,"C",Len(SM0->M0_CODIGO) ,0} )
	aAdd(aStruct, { "FILIAL"  ,"C",FWGETTAMFILIAL      ,0} )
	aAdd(aStruct, { "MARK"    ,"C",02                  ,0} )
	aAdd(aStruct, { "NOME"    ,"C",20                  ,0} )
	
	oTmpTbl:SetFields(aStruct)
	oTmpTbl:AddIndex("INDEX1", {"EMPRESA", "FILIAL"})
	oTmpTbl:Create()
	
	If (cAliasSM0)->(Eof())
		nRecSM0 := SM0->(Recno())
		
		While SM0->(!Eof())
			If AllTrim(SM0->M0_CODIGO) == cEmpAnt .And. AllTrim( SM0->M0_CODFIL ) $ cValidFil
				RecLock(cAliasSM0,.T.)
				(cAliasSM0)->EMPRESA := SM0->M0_CODIGO
				(cAliasSM0)->FILIAL  := SM0->M0_CODFIL
				(cAliasSM0)->NOME    := SM0->M0_FILIAL
				(cAliasSM0)->MARK    := cMark
				(cAliasSM0)->(MsUnLock())
			EndIf
			
			SM0->(DbSkip())
		EndDo
	EndIf
    
	oWizard := APWizard():New( cText1, cText2, cText3, ctext4, {||.T.}, {||.T.}, .F., Nil, {|| .T.}, Nil, {00,00,450,600} )

    //Painel 2 - Seleção de Filiais
	oWizard:NewPanel(	"Seleção de Filiais"        ,;
						"Selecione as filiais cujos dados serão atualizados" ,;
						{||.T.}        ,; //<bBack>
						{||.T.}        ,; //<bNext>
						{||.F.}        ,; //<bFinish>
						.T.            ,; //<.lPanel.>
						{|| GetFils() } ) //<bExecute>
	
	//Painel 3 - Execução do processo
	oWizard:NewPanel(	"Realizando atualização da base..." ,;
						"Aguarde enquanto o processamento é executado." ,;
						{||.F.}                   ,; //<bBack>
						{||.F.}                   ,; //<bNext>
						{||.T.}                   ,; //<bFinish>
						.T.                       ,; //<.lPanel.>
						{| lEnd| fCallExec(@lEnd)}) //<bExecute>
	
	oWizard:Activate( .T.,{||.T.},{||.T.},	{||.T.})
Return

/*/{Protheus.doc} fCallExec
Função para preparação e chamada da execução
@author  Leandro Drumond
@since   23/07/2019
@version 1.0
/*/
Static Function fCallExec(lEnd)
	Private oProcess
	
	// Executa o processamento de atualização das faltas chamando a função fUpdPerSRF
	oProcess := MsNewProcess():New( {|lEnd| fUpdPerSRF(oProcess) } , "Executando atualização dos períodos aquisitivos..." , "Executando atualização dos períodos aquisitivos..." )
	oProcess:Activate()
Return

/*/{Protheus.doc} fUpdPerSRF
Função que executa o processo de atualização da base atualizando as faltas na SRF de acordo com a SRD
@author  Leandro Drumond
@since   23/07/2019
@version 1.0
/*/
Static Function fUpdPerSRF(lEnd)
	Local lBackup    := MsgYesNo("O backup da base já foi realizado?")
    Local cAliasQry1 := ""
    Local cAliasQry2 := ""
    Local aFil       := fGetFil()
    Local aCodFol    := {}
    Local aPerAtual	 := {}
    Local nX         := 0
    Local nY         := 0
    Local lSRVComp   := Empty(xFilial("SRV"))
    Local cPdAux     := ""
    Local cWhere     := ""
    Local nFaltas    := 0
    Local cSeekSRF   := ""
    Local cCatProc	 := ""
    Local cPerAtual	 := ""
    Local lAtualizou := .F.

    oProcess:SetRegua1(Len(aFil))

    If lBackup
        For nX := 1 To Len(aFil)
            oProcess:IncRegua1("Filial sendo processada: " + aFil[nX])

            If nX == 1 .Or. !lSRVComp
                FP_CodFol( @aCodFol , xFilial("SRV",aFil[nX]), .F., .F. )
                cPdAux := "'" + aCodFol[54,1] + "','" + aCodFol[203,1] + "','" + aCodFol[242,1] + "','" + aCodFol[244,1] + "'"
            EndIf

            cAliasQry1 := GetNextAlias()

            BeginSql Alias cAliasQry1
                SELECT COUNT(*) CNT
                FROM
                    %Table:SRA% SRA
                WHERE
                    SRA.%NotDel%
                    AND SRA.RA_FILIAL = %Exp:aFil[nX]%
            EndSql

            oProcess:SetRegua2( (cAliasQry1)->CNT )
            (cAliasQry1)->(DbCloseArea())

            BeginSql Alias cAliasQry1
                SELECT DISTINCT
                    SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_ADMISSA, SRA.RA_PROCES, SRA.RA_CATFUNC
                FROM
                    %Table:SRA% SRA
                WHERE
                    SRA.%NotDel%
                    AND SRA.RA_FILIAL = %Exp:aFil[nX]%
                ORDER BY
                    1,2,5,4
            EndSql

            While !(cAliasQry1)->( EOF() )
                oProcess:IncRegua2( "Matrícula sendo processada: " + (cAliasQry1)->RA_MAT )
                
                If cCatProc <> (cAliasQry1)->RA_FILIAL + (cAliasQry1)->RA_CATFUNC + (cAliasQry1)->RA_PROCES
                	cPerAtual := ""
                	aPerAtual := {}
                	cCatProc := (cAliasQry1)->RA_FILIAL + (cAliasQry1)->RA_CATFUNC + (cAliasQry1)->RA_PROCES
                	fGetPerAtual( @aPerAtual, xFilial("RCH", (cAliasQry1)->RA_FILIAL), (cAliasQry1)->RA_PROCES, If((cAliasQry1)->RA_CATFUNC $ "A*P", fGetCalcRot("9"), fGetCalcRot("1")) )
                	If !Empty(aPerAtual)
                		cPerAtual := aPerAtual[1,1]
                	EndIf
                EndIf

                If !Empty(cPerAtual)
	                DbSelectArea("SRF")
	                DbSetOrder(2)
	                
	                cSeekSRF := (cAliasQry1)->RA_FILIAL + (cAliasQry1)->RA_MAT + aCodFol[0072,1]
	                
	                If SRF->( DbSeek(cSeekSRF) )
	                    While SRF->(!Eof() .and. RF_FILIAL + RF_MAT + RF_PD == cSeekSRF )
	                    	If AnoMes(SRF->RF_DATABAS) > cPerAtual //Se inicio do período aquisitivo for superior ao período ativo da folha, foi criado indevidamente, por isso, efetua a exclusão
	                    		lAtualizou := .T.
		                        RecLock("SRF",.F.)
		                        	DbDelete()
		                        SRF->( MsUnLock() )
		                    EndIf
	
	                        SRF->(DbSkip())
	                    EndDo
	                EndIf
	             EndIf

                (cAliasQry1)->(DbSkip())
            EndDo

            (cAliasQry1)->(DbCloseArea())
        Next nX

        If lAtualizou
            MsgInfo("Períodos atualizados com sucesso")
        Else
            MsgInfo("Não existem períodos indevidos na SRF")
        EndIf
    Else
        MsgInfo("Realize o backup e execute a rotina novamente.")
    EndIf
Return

/*/{Protheus.doc} GetFils
Monta tela para seleção de filiais
@author Leandro Drumond
@since 23/07/2019
@version 1.0
@return Nil
/*/
Static Function GetFils()
	Local aColumns    := {}
	Local bMarkAll    := { || RhMkAll( cAliasSM0 , .F., .T. , 'MARK', @cMarkAll ,cMark ) }
	Local cMarkAll    := cMark
	Local oPanel      := oWizard:oMPanel[oWizard:nPanel]
		
	(cAliasSM0)->(DbGoTop())
	
	While (cAliasSM0)->(!Eof())
		If Empty((cAliasSM0)->MARK)
			cFilOk += AllTrim((cAliasSM0)->(EMPRESA)) + AllTrim((cAliasSM0)->(FILIAL)) + "*"
		Else
			cMark := (cAliasSM0)->MARK
		EndIf
		(cAliasSM0)->(DbSkip())
	EndDo
	
	(cAliasSM0)->(DbGoTop())
	
	If oMsSelect == Nil
		aAdd( aColumns, { "MARK"    ,,''        ,"@!"})
		aAdd( aColumns, { "EMPRESA" ,,"Empresa" ,"@!"})
		aAdd( aColumns, { "FILIAL"  ,,"Filial"  ,"@!"})
		aAdd( aColumns, { "NOME"    ,,"Nome"    ,"@!"})
		
		oMsSelect := MsSelect():New( cAliasSM0      ,; //Alias do Arquivo de Filtro
										 "MARK"         ,; //Campo para controle do mark
										 NIL            ,; //Condicao para o Mark
										 aColumns       ,; //Array com os Campos para o Browse
										 NIL            ,; //
										 cMark          ,; //Conteudo a Ser Gravado no campo de controle do Mark
										 {10,12,150 ,285} ,; //Coordenadas do Objeto
										 NIL            ,; //
										 NIL            ,; //
										 oPanel          ; //Objeto Dialog
										 )
		oMsSelect:oBrowse:lAllMark := .T.
		oMsSelect:oBrowse:bAllMark := bMarkAll
	EndIf
Return

/*/{Protheus.doc} RhMkAll
Marca todas as filiais
@author Leandro Drumond
@since 23/07/2019
@version 1.0
@return Nil
/*/
Static Function RhMkAll( cAlias, lInverte, lTodos, cCpoCtrl, cMark, cMarkAux )
	Local nRecno := (cAlias)->(Recno())
	
	(cAlias)->( DbGoTop() )
	While (cAlias)->( !Eof() )  
		RhMkMrk( cAlias , lInverte , lTodos, cCpoCtrl, cMark, {})
		(cAlias)->( DbSkip() )
	End While
	(cAlias)->( MsGoto( nRecno ) )
	
	If cMark == cMarkAux
		cMark := ""
	Else
		cMark := cMarkAux
	EndIf
Return

/*/{Protheus.doc} fGetFil
Pega filiais selecionadas
@author Leandro Drumond
@since 23/07/2019
@version 1.0
@return Nil
/*/
Static Function fGetFil()
	Local aRet  := {}
	
	DbSelectArea(cAliasSM0)
	(cAliasSM0)->( DbGotop() )
	
	While (cAliasSM0)->(!Eof())
		If !( Empty((cAliasSM0)->MARK) )
			aAdd( aRet , (cAliasSM0)->FILIAL )
		EndIf
		
		(cAliasSM0)->(DbSkip())
	EndDo
Return aRet