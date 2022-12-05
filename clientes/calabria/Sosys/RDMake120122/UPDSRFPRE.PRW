#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} UPDSRFPRE
Programa para atualizar os periodos pre-escritos criados equivocadamente
@author  Leandro Drumond
@since   23/07/2019
@version 1.0
/*/
User Function UPDSRFPRE()
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
    Local cText3 := "UPDSRFPRE - Atualizando os períodos na SRF."
    Local ctext4 := ""

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
    Local cSGBD			:= AllTrim( Upper( TcGetDb() ) )
	Local cTop1			:= ""
	Local cOrder		:= ""
	Local cSelect 		:= ""
    Local lAtualizou := .F.
	Local lDel 		 := .F.
	Local aRecno 	 := {}
	Local cTitLog	 := "UPDSRF - Log de processamento"
    Local aTitle	 := {}
    Local aLog		 := {}
	Local aOfusca	:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
	Local aFldRel	:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {})
	Local lOfusca	:= Len(aFldRel) > 0

	Do Case
		Case cSGBD $ "ORACLE"
			cTop1 += " AND ROWNUM <= 1 "
		Case cSGBD $ "MYSQL"
			cOrder += " LIMIT 1 "
		Case cSGBD $ "DB2"
			cOrder += " FETCH FIRST 1 ROW ONLY "
		Case cSGBD $ "INFORMIX"
			cSelect := " FIRST 1 "
		Otherwise
			cSelect := " TOP 1 "
	EndCase

	cSelect := "% " + cSelect + " %"
	cTop1  := "% " + cTop1 + " %"
	cOrder  := "% " + cOrder + " %"


    oProcess:SetRegua1(Len(aFil))

    DbSelectArea("SRF")
	SRF->(DbSetOrder(2))

    If lBackup
        For nX := 1 To Len(aFil)
            oProcess:IncRegua1("Filial sendo processada: " + aFil[nX])

            If nX == 1 .Or. !lSRVComp
                FP_CodFol( @aCodFol , xFilial("SRV",aFil[nX]), .F., .F. )
            EndIf

            cAliasQry1 := GetNextAlias()

            BeginSql Alias cAliasQry1
                SELECT COUNT(*) CNT
				FROM %Table:SRA% SRA
				WHERE SRA.RA_FILIAL = %Exp:aFil[nX]%
				AND SRA.%NotDel%
				AND SRA.RA_SITFOLH = 'A'
            EndSql

            oProcess:SetRegua2( (cAliasQry1)->CNT )
            (cAliasQry1)->(DbCloseArea())

            BeginSql Alias cAliasQry1
                SELECT SRA.RA_FILIAL,SRA.RA_MAT,SRA.RA_NOME
				FROM %Table:SRA% SRA
				WHERE SRA.RA_FILIAL = %Exp:aFil[nX]%
				AND SRA.%NotDel%
				AND SRA.RA_SITFOLH = 'A'
				ORDER BY SRA.RA_FILIAL,SRA.RA_MAT
			EndSql

            While !(cAliasQry1)->( EOF() )
                oProcess:IncRegua2( "Matrícula sendo processada: " + (cAliasQry1)->RA_MAT + If(lOfusca, "", " - " + Alltrim((cAliasQry1)->RA_NOME)))

                cAliasQry2 := GetNextAlias()
	            BeginSql Alias cAliasQry2
					SELECT %exp:cSelect% SR8.R8_DATAINI, SR8.R8_DATAFIM
					FROM %Table:SR8% SR8
					WHERE SR8.R8_FILIAL = %exp:(cAliasQry1)->RA_FILIAL%
					AND SR8.R8_MAT = %exp:(cAliasQry1)->RA_MAT%
					AND SR8.%NotDel%
					%exp:cTop1%
					ORDER BY SR8.R8_DATAINI DESC  %exp:cOrder%
				EndSql
				lDel := .F.
				aRecno := {}
                If !(cAliasQry2)->( EOF() )
                	cSeekSRF := (cAliasQry1)->RA_FILIAL + (cAliasQry1)->RA_MAT + aCodFol[0072,1]
                    If SRF->( DbSeek(cSeekSRF) )
	                    While SRF->(!Eof() .and. RF_FILIAL + RF_MAT + RF_PD == cSeekSRF )
		                    	If Anomes(SRF->RF_DATABAS) > substr((cAliasQry2)->R8_DATAINI,1,6) .And. SRF->RF_STATUS != "2"
		                    		lAtualizou := .T.
		                    		lDel := .T.
	        			            //Adiciona registro no LOG
	        			            Aadd( aLog, (cAliasQry1)->RA_FILIAL + Space(3) +(cAliasQry1)->RA_MAT + " - " + If(lOfusca, Replicate('*',30), Alltrim((cAliasQry1)->RA_NOME)) )

			                        RecLock("SRF",.F.)
			                        	DbDelete()
			                        SRF->( MsUnLock() )
			                    EndIf
		                        If SRF->RF_STATUS == "2"
		                    		aadd(aRecno,SRF->(RECNO()))
		                    	ElseIf SRF->RF_STATUS == "1" .And. Anomes(SRF->RF_DATABAS) < substr((cAliasQry2)->R8_DATAINI,1,6)
		                    		aRecno := {}
		                    	EndIf
	                        SRF->(DbSkip())
	                    EndDo
                    	For nY := 1 To Len(aRecno)
                    		SRF->(DbGoto(aRecno[nY]))
                    		If RecLock("SRF",.F.)
                    			If substr((cAliasQry2)->R8_DATAINI,1,6) >= Anomes(SRF->RF_DATABAS) .And. substr((cAliasQry2)->R8_DATAINI,1,6) <= Anomes(SRF->RF_DATAFIM)
                    				SRF->RF_STATUS := '1'
                    				SRF->RF_DFERVAT := 0
                    				SRF->RF_DFERAAT := 0
	                        	Else
	                        		DbDelete()
	                        	EndIf
	                        	SRF->( MsUnLock() )
	                        EndIf
                    	Next nY
                    EndIf
                EndIf
                (cAliasQry2)->( dbCloseArea() )

                (cAliasQry1)->(DbSkip())
            EndDo

            (cAliasQry1)->(DbCloseArea())
        Next nX

        If lAtualizou
            MsgInfo("Períodos atualizados com sucesso")
            If Len( aLog ) > 0
		        aTitle  := { "Filial" + Space(3) + "Mat.     Nome   " }
		        fMakeLog({aLog},aTitle,,,"UPDSRFPRE_"+DTOS(DDATABASE),cTitLog,"M","L",,.F.) //"UPDSRF - Log de processamento"
		    EndIf
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