#INCLUDE "TOTVS.CH"
#INCLUDE "UPDFASRF.CH"

/*/{Protheus.doc} UPDFASRF
Programa para atualizar as faltas na SRF de acordo com a SRD
@author  gabriel.almeida
@since   19/04/2018
@version 1.0
/*/
User Function UPDFASRF()
    Local aArea    := GetArea()

    fMontaWizard()
    RestArea(aArea)
Return

/*/{Protheus.doc} fMontaWizard
Função para montar a Wizard de execução
@author  gabriel.almeida
@since   19/04/2018
@version 1.0
/*/
Static Function fMontaWizard()
    Local cText1 := STR0001 //"Realize o backup da base antes de executar esse processo."
    Local cText2 := STR0002 //"Ferramenta para ajuste das faltas na tabela de Controle de Dias de Direito (SRF)."
    Local cText3 := STR0003 //"UPDFASRF - Atualizando as faltas na SRF."
    Local ctext4 := STR0004 //"Ao final do processamento as faltas dos funcionários das filiais selecionadas estarão atualizadas de acordo com a SRD na SRF."
    
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
	oWizard:NewPanel(	STR0005        ,; //"Seleção de Filiais"
						STR0006        ,; //"Selecione as filiais cujos dados serão atualizados"
						{||.T.}        ,; //<bBack>
						{||.T.}        ,; //<bNext>
						{||.F.}        ,; //<bFinish>
						.T.            ,; //<.lPanel.>
						{|| GetFils() } ) //<bExecute>
	
	//Painel 3 - Execução do processo
	oWizard:NewPanel(	STR0007                   ,; //"Realizando atualização da base..."
						STR0008                   ,; //"Aguarde enquanto o processamento é executado."
						{||.F.}                   ,; //<bBack>
						{||.F.}                   ,; //<bNext>
						{||.T.}                   ,; //<bFinish>
						.T.                       ,; //<.lPanel.>
						{| lEnd| fCallExec(@lEnd)}) //<bExecute>
	
	oWizard:Activate( .T.,{||.T.},{||.T.},	{||.T.})
Return

/*/{Protheus.doc} fCallExec
Função para preparação e chamada da execução
@author  gabriel.almeida
@since   19/04/2018
@version 1.0
/*/
Static Function fCallExec(lEnd)
	Private oProcess
	
	// Executa o processamento de atualização das faltas chamando a função fUpdFalSRF
	oProcess := MsNewProcess():New( {|lEnd| fUpdFalSRF(oProcess) } , STR0009 , STR0009 ) //"Executando atualização das faltas..."
	oProcess:Activate()
Return

/*/{Protheus.doc} fUpdFalSRF
Função que executa o processo de atualização da base atualizando as faltas na SRF de acordo com a SRD
@author  gabriel.almeida
@since   19/04/2018
@version 1.0
/*/
Static Function fUpdFalSRF(lEnd)
	Local lBackup    := MsgYesNo(STR0010) //"O backup da base já foi realizado?"
    Local cAliasQry1 := ""
    Local cAliasQry2 := ""
    Local aFil       := fGetFil()
    Local aCodFol    := {}
    Local nX         := 0
    Local nY         := 0
    Local lSRVComp   := Empty(xFilial("SRV"))
    Local cPdAux     := ""
    Local cWhere     := ""
    Local nFaltas    := 0
    Local cSeekSRF   := ""
    Local lAtualizou := .F.
    Local dDataF

    oProcess:SetRegua1(Len(aFil))

    If lBackup
        For nX := 1 To Len(aFil)
            oProcess:IncRegua1(STR0011 + aFil[nX]) //"Filial sendo processada: "

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
                    SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_ADMISSA
                FROM
                    %Table:SRA% SRA
                WHERE
                    SRA.%NotDel%
                    AND SRA.RA_FILIAL = %Exp:aFil[nX]%
                ORDER BY
                    1,2
            EndSql

            While !(cAliasQry1)->( EOF() )
                oProcess:IncRegua2( STR0012 + (cAliasQry1)->RA_MAT ) //"Matrícula sendo processada: "

                DbSelectArea("SRF")
                DbSetOrder(2)
                
                cSeekSRF := (cAliasQry1)->RA_FILIAL + (cAliasQry1)->RA_MAT + aCodFol[0072,1]
                
                If SRF->( DbSeek(cSeekSRF) )
                    While SRF->(!Eof() .and. RF_FILIAL + RF_MAT + RF_PD == cSeekSRF )
                        dDataF := If(Empty(SRF->RF_DATAFIM),fCalcFimAq(SRF->RF_DATABAS),SRF->RF_DATAFIM)
                        
                        cWhere := "%"
                        cWhere += " SRD.RD_FILIAL = '"	 	+ (cAliasQry1)->RA_FILIAL + "' "
                        cWhere += " AND SRD.RD_MAT = '" 	+ (cAliasQry1)->RA_MAT    + "' "
                        cWhere += " AND SRD.RD_DATARQ >= '"	+ AnoMes(SRF->RF_DATABAS) + "' "
                        cWhere += " AND SRD.RD_DATARQ <= '"	+ AnoMes(dDataF) + "' "
                        cWhere += " AND SRD.RD_PD IN (" 	+ cPdAux   + ") "
                        cWhere += "%"

                        cAliasQry2 := GetNextAlias()

                        BeginSql Alias cAliasQry2
                            SELECT *
                            FROM
                                %Table:SRD% SRD
                            WHERE
                                %Exp:cWhere% AND
                                SRD.%NotDel%
                        EndSql

                        nFaltas := 0

                        While (cAliasQry2)->(!Eof())
                            fAcumFaltas(AnoMes(SRF->RF_DATABAS),AnoMes(dDataF),(cAliasQry2)->RD_DATARQ,(cAliasQry2)->RD_PD,cAliasQry2,@nFaltas,aCodFol)
                            (cAliasQry2)->(DbSkip())

                            lAtualizou := .T.
                        EndDo

                        (cAliasQry2)->(DbCloseArea())

                        RecLock("SRF",.F.)
                            If SRF->RF_DFERVAT > 0
                                SRF->RF_DFALAAT := 0
                                SRF->RF_DFALVAT := nFaltas //Faltas vencidas
                            Else
                                SRF->RF_DFALAAT := nFaltas //Faltas a vencer
                                SRF->RF_DFALVAT := 0
                            EndIf
                        SRF->( MsUnLock() )

                        SRF->(DbSkip())
                    EndDo
                EndIf

                (cAliasQry1)->(DbSkip())
            EndDo

            (cAliasQry1)->(DbCloseArea())
        Next nX

        If lAtualizou
            MsgInfo(STR0014) //"Faltas atualizadas com sucesso."
        Else
            MsgInfo(STR0015) //"Não existem faltas na SRD para atualização."
        EndIf
    Else
        MsgInfo(STR0013) //"Realize o backup e execute a rotina novamente."
    EndIf
Return

/*/{Protheus.doc} GetFils
Monta tela para seleção de filiais
@author Gabriel de Souza Almeida
@since 19/04/2018
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
@author Gabriel de Souza Almeida
@since 19/04/2018
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
@author Gabriel de Souza Almeida
@since 19/04/2018
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

/*/{Protheus.doc} fAcumFaltas
Cópia da função do GPECONV que acumula as faltas da SRD
@author Gabriel de Souza Almeida
@since 19/04/2018
@version 1.0
@return Nil
/*/
Static Function fAcumFaltas(cDatai,cDataF,cMesAno,cVerbaPesq,cAlias,nFaltas,aCodFol)
    If cMesAno >= cDatai .And. cMesAno <= cDataF
        //Pesquisa Faltas no Acumulado
        If cVerbaPesq == aCodFol[054,1]
            If PosSrv(aCodFol[54,1],SRA->RA_FILIAL,"RV_MEDFER") $ "S *SP"
                nFaltas += If((cAlias)->RD_TIPO1 == "D", (cAlias)->RD_HORAS, Int((cAlias)->RD_HORAS/Round(SRA->RA_HRSMES/30,2)) )
            EndIf
        EndIf

        //Pesquisa Faltas Mes Anterior no Acumulado
        If cVerbaPesq == aCodFol[203,1]
            If PosSrv(aCodFol[203,1],SRA->RA_FILIAL,"RV_MEDFER") $ "S *SP"
                nFaltas += If((cAlias)->RD_TIPO1 == "D", (cAlias)->RD_HORAS, Int((cAlias)->RD_HORAS/Round(SRA->RA_HRSMES/30,2)) )
            EndIf
        EndIf

        //Pesquisa Faltas (II) no Acumulado
        If cVerbaPesq == aCodFol[242,1]
            If PosSrv(aCodFol[242,1],SRA->RA_FILIAL,"RV_MEDFER") $ "S *SP"
                nFaltas += If((cAlias)->RD_TIPO1 == "D", (cAlias)->RD_HORAS, Int((cAlias)->RD_HORAS/Round(SRA->RA_HRSMES/30,2)) )
            EndIf
        EndIf

        //Pesquisa Reembolso de Faltas no Acumulado
        If cVerbaPesq == aCodFol[244,1]
            If PosSrv(aCodFol[244,1],SRA->RA_FILIAL,"RV_MEDFER") $ "S *SP"
                nFaltas -= If((cAlias)->RD_TIPO1 == "D", (cAlias)->RD_HORAS, Int((cAlias)->RD_HORAS/Round(SRA->RA_HRSMES/30,2)) )
            EndIf
        EndIf				
    EndIf
Return