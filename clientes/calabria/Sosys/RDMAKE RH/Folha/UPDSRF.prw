#INCLUDE "TOTVS.CH"
#INCLUDE "UPDSRF.CH"

/*/{Protheus.doc} UPDSRF
Programa para eliminar registros de férias reatroativos gerados indevidamente pelo fechamento das férias
@author  M. Silveira
@since   27/11/2018
@version 1.0
/*/
User Function UPDSRF()
    Local aArea    := GetArea()

    fMontaWizard()
    RestArea(aArea)
Return

/*/{Protheus.doc} fMontaWizard
Função para montar a Wizard de execução
@author  M. Silveira
@since   27/11/2018
@version 1.0
/*/
Static Function fMontaWizard()
    Local cText1 := STR0001 //"Realize o backup da base antes de executar esse processo."
    Local cText2 := STR0002 //"Ferramenta para eliminar registros da tabela de Controle de Dias de Direito (SRF) que foram gerados indevidamente durante o fechamento do roteiro de Férias."
    Local cText3 := STR0003 //"UPDSRF - Atualização dos dados da tabela SRF."
    Local ctext4 := STR0004 //"Ao final do processamento serão eliminados os registros de férias ativos que estavam com data inferior a outros períodos que estavam quitados."

    Local cValidFil := fValidFil()
    Local aStruct   := {}

    Private cAliasSM0 := GetNextAlias()
	Private oTmpTbl   := FWTemporaryTable():New(cAliasSM0)
	Private cMark     := GetMark()
    Private oMsSelect := Nil
    Private lSimula   := .F.

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

    //Painel 3 - Definição do processamento
	oWizard:NewPanel(	STR0014        ,; //"Simulação dos dados que serão processados"
						STR0015        ,; //"Deseja efetuar a simulação para fazer a geração do LOG dos registros que serão afetados?" ,;
						{||.T.}        ,; //<bBack>
						{||.T.}        ,; //<bNext>
						{||.F.}        ,; //<bFinish>
						.T.            ,; //<.lPanel.>
						{|| GetProc() } ) //<bExecute>


	//Painel 4 - Execução do processo
	oWizard:NewPanel(	STR0007                   ,; //"Realizando atualização da base..."
						STR0008                   ,; //"Aguarde enquanto o processamento é executado."
						{||.F.}                   ,; //<bBack>
						{||.F.}                   ,; //<bNext>
						{||.T.}                   ,; //<bFinish>
						.T.                       ,; //<.lPanel.>
						{| lEnd| fProcExec(@lEnd)}) //<bExecute>

	oWizard:Activate( .T.,{||.T.},{||.T.},	{||.T.})
Return

/*/{Protheus.doc} fProcExec
Função para preparação e chamada da execução
@author  M. Silveira
@since   27/11/2018
@version 1.0
/*/
Static Function fProcExec(lEnd)
	Private oProcess

	// Executa o processamento de atualização da tabela SRF chamando a função fUpdSRF
	oProcess := MsNewProcess():New( {|lEnd| fUpdSRF(oProcess) } , STR0009 , STR0009 ) //"Executando atualização da tabela controle dias de direito..."
	oProcess:Activate()
Return

/*/{Protheus.doc} fUpdSRF
Função que executa o processo de atualização da base atualizando as faltas na SRF de acordo com a SRD
@author  M. Silveira
@since   27/11/2018
@version 1.0
/*/
Static Function fUpdSRF(lEnd)

	Local lBackup	:= If( !lSimula, MsgYesNo(STR0010), .T. )//"O backup da base já foi realizado?"
	Local cQrySRA	:= ""
	Local cQrySRF	:= ""
	Local cFilSRA	:= ""
	Local cMatSRA	:= ""
	Local cNomeSRA	:= ""
	Local cDtBas	:= ""
	Local cDtFim	:= ""
	Local cDiasDir	:= ""
	Local cDiasVen	:= ""
	Local cDiasAnt	:= ""
	Local cStatus	:= ""
	Local cTitLog	:= STR0019 //"UPDSRF - Log de processamento"
	Local aFil		:= fGetFil()
	Local nPerPago	:= 0
	Local nCount	:= 0
	Local nX 		:= 0
	Local aTitle	:= {}
	Local aLog		:= {}
	Local aOfusca	:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
	Local aFldRel	:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {})
	Local lOfusca	:= Len(aFldRel) > 0

    oProcess:SetRegua1(Len(aFil))

    If lBackup

        For nX := 1 To Len(aFil)
            oProcess:IncRegua1(STR0011 + aFil[nX]) //"Filial sendo processada: "

            cQrySRA := GetNextAlias()
            cQrySRF	:= GetNextAlias()

            BeginSql Alias cQrySRA
                SELECT COUNT(*) CNT
                FROM
                    %Table:SRA% SRA
                WHERE
                    SRA.%NotDel%
                    AND SRA.RA_FILIAL = %Exp:aFil[nX]%
            EndSql

            oProcess:SetRegua2( (cQrySRA)->CNT )
            (cQrySRA)->(DbCloseArea())

            BeginSql Alias cQrySRA
                SELECT DISTINCT
                    SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME
                FROM
                    %Table:SRA% SRA
                WHERE
                    SRA.%NotDel%
                    AND SRA.RA_FILIAL = %Exp:aFil[nX]%
                ORDER BY
                    1,2
            EndSql

            While !(cQrySRA)->( EOF() )

				cFilSRA  := (cQrySRA)->RA_FILIAL
				cMatSRA	 := (cQrySRA)->RA_MAT
				cNomeSRA := If( lOfusca, Replicate('*',15), SubStr((cQrySRA)->RA_NOME,1,30) )

					oProcess:IncRegua2( STR0012 + cFilSRA + cMatSRA + " - " + cNomeSRA ) //"Matrícula sendo processada: "

				BeginSql Alias cQrySRF
	            	SELECT
	                    SRF.RF_FILIAL, SRF.RF_MAT, SRF.RF_DATABAS, SRF.RF_DATAFIM, SRF.RF_DIASDIR, SRF.RF_DFERVAT, SRF.RF_DFERAAT, SRF.RF_STATUS, SRF.R_E_C_N_O_
	                FROM
	                    %Table:SRF% SRF
	                WHERE
	                    SRF.%NotDel%
	                    AND SRF.RF_FILIAL = %exp:Upper(cFilSRA)%
	                    AND SRF.RF_MAT = %exp:Upper(cMatSRA)%
	                ORDER BY 1,2,3 DESC
	            EndSql

	            nPerPago := 0
	            nCount 	 := 0

	            While !(cQrySRF)->( EOF() )

	            	nCount ++
				    cDtBas	 := Transform(sTod((cQrySRF)->RF_DATABAS),"00/00/00")
				    cDtFim	 := Transform(sTod((cQrySRF)->RF_DATAFIM),"00/00/00")
				    cDiasDir := cValtoChar((cQrySRF)->RF_DIASDIR)
				    cDiasVen := cValtoChar((cQrySRF)->RF_DFERVAT)
				    cDiasAnt := cValtoChar((cQrySRF)->RF_DFERAAT)
				    cStatus	 := If( (cQrySRF)->RF_STATUS == "1", "Ativo", If( (cQrySRF)->RF_STATUS == "3", "Pago", "Prescrito" ) )

					If (cQrySRF)->RF_STATUS == "3"
						nPerPago += 1

					ElseIf (cQrySRF)->RF_STATUS == "1" .And. nPerPago > 0 .And. nCount > 1

		                DbSelectArea("SRF")
		                SRF->( MsGoto( (cQrySRF)->R_E_C_N_O_ ) )

		                If !lSimula
			                IF SRF->( !EOF() )
				                RecLock("SRF", .F.)
				                SRF->( dbDelete() )
				                SRF->( MsUnlock() )
			                EndIf
			            EndIf

			            //Adiciona registro no LOG
						Aadd( aLog, cFilSRA + Space(9-Len(cFilSRA)) + cMatSRA + Space(3) + cNomeSRA + Space(31-Len(cNomeSRA)) + cDtBas + Space(3) + cDtFim + Space(3) + cDiasDir + Space(8) + cDiasVen + Space(8) + cDiasAnt + Space(8) + cStatus )

					EndIf

					(cQrySRF)->(DbSkip())
	            EndDo

	            (cQrySRF)->(DbCloseArea())
				(cQrySRA)->(DbSkip())

            EndDo

            (cQrySRA)->( DbCloseArea() )
        Next nX

        If Len( aLog ) > 0
	        aTitle  := { "Filial" + Space(3) + "Mat.     Nome                           Dt.Bs.Fer    D.Fim Fer    Dias Dir  D.Venc.   D.Prop.  Status " }
	        cTitLog += If( lSimula, " " + STR0020, "") //(SIMULACAO)
	        fMakeLog({aLog},aTitle,,,"UPDSRF_"+DTOS(DDATABASE),cTitLog,"M","L",,.F.) //"UPDSRF - Log de processamento"
	    Else
	    	MsgInfo(STR0021) //"Não foram localizados registros para serem processados."
        EndIf

    Else
        MsgInfo(STR0013) //"Realize o backup e execute a rotina novamente."
    EndIf
Return


/*/{Protheus.doc} GetProc
Monta tela para seleção do Tipo de Processamento
@author  M. Silveira
@since   27/11/2018
@version 1.0
@return Nil
/*/
Static Function GetProc()

Local oPanel := oWizard:oMPanel[oWizard:nPanel]
Local oRadio
Local oChk1
Local cMsg1 := OemToAnsi(STR0016) //"Caso essa opção seja marcada os dados não serão atualizados."
Local cMsg2 := OemToAnsi(STR0017) //"Será apresentado um LOG com os registros que podem ser afetados no processamento real."

	@ 010, 010 TO 125,280 OF oPanel PIXEL
	@ 020, 015 CHECKBOX oChk1 VAR lSimula PROMPT OemToAnsi(STR0018) SIZE 200,7 PIXEL OF oPanel //"SIMULAÇÃO - geração de LOG dos registros que serão afetados"
	@ 040, 015 SAY cMsg1  SIZE 300, 8 PIXEL OF oPanel
	@ 055, 015 SAY cMsg2  SIZE 300, 8 PIXEL OF oPanel

Return


/*/{Protheus.doc} GetFils
Monta tela para seleção de filiais
@author  M. Silveira
@since   27/11/2018
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
@author  M. Silveira
@since   27/11/2018
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
@author  M. Silveira
@since   27/11/2018
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