#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} UPDLINTUR
//Tela atualização de turno SPF
@author  Philipe Couto
@since   08/11/2018
@version 0.1
/*/
//-------------------------------------------------------------------
User Function UPDLINTUR()
    Local aButtons  := {}
    Local aSays     := {}
    Local cMsg      := ""
    Local lContinua := .F.
    Local nOpcA     := 0

    Private aCodFol := {}
    Private aLog    := {}
    Private aTitle  := {}

    aAdd(aSays,OemToAnsi( "Esta rotina tem como objetivo criar o registro da troca de turno no primeiro dia do período," ))
    aAdd(aSays,OemToAnsi( "quando o fechamento do mês anterior não tiver criado este registro." ))
    aAdd(aSays,OemToAnsi( "Caso exista algum registro com data dentro do período atual," ))
    aAdd(aSays,OemToAnsi( "o sistema não fará alteração na tabela." ))

    aAdd(aButtons, { 1,.T.,{|o| nOpcA := 1,FechaBatch() }} )
    aAdd(aButtons, { 2,.T.,{|o| nOpca := 0,FechaBatch()}} )

    //Abre a tela de processamento
    FormBatch( "Atualização nova linha de turno", aSays, aButtons )

    //Efetua o processamento de geração
    If nOpcA == 1
        Aadd( aTitle, OemToAnsi( "Funcionários que tiveram TURNOS ALTERADOS:" ) )
        Aadd( aLog, {} )
        ProcGpe( {|lEnd| ProcAtuTur()},,,.T. )
        fMakeLog(aLog,aTitle,,,"TelaTeste",OemToAnsi("Log de Ocorrências"),"M","P",,.F.)
    EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcAtuTur
Processa nova linha de turno na SPF
@author  Philipe Couto
@since   08/11/2018
@version 0.1
/*/
//-------------------------------------------------------------------
Static Function ProcAtuTur()

    Local cFil          := ""
    Local cMat          := ""
    Local cPfData       := ""
    Local dNextPerIni	:= Ctod("//")
    Local dNextPerFim	:= Ctod("//")
    Local aChkPonMes    := {}
    Local lPonMes       := .F.
    Local nTotal		:= 0
	Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
	Local aFldRel		:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {})

	Private lOfusca		:= Len(aFldRel) > 0
    Private cAliasSra   := GetNextAlias()

    BeginSql Alias cAliasSra
        SELECT DISTINCT RA_FILIAL, RA_MAT, RA_CC, RA_ADMISSA, RA_DEMISSA, RA_SITFOLH, RA_TNOTRAB, RA_PROCES, RA_REGRA, RA_SEQTURN, R_E_C_N_O_ AS recno
        FROM %table:SRA% SRA
        WHERE SRA.RA_REGRA <> '  ' AND SRA.RA_FILIAL>=%exp:xFilial("SRA")% AND SRA.RA_FILIAL<=%exp:xFilial("SRA")% AND SRA.D_E_L_E_T_=' ' ORDER BY RA_MAT
    EndSql

    DbSelectArea("SRA")
    SRA->(dbSetOrder(1))

    dbSelectArea( cAliasSra )
	count to ntotal

	GpProcRegua(ntotal)
	(cAliasSra)->(DbGoTop())

    Begin Sequence
        While (cAliasSra)->( !Eof() )

            cFil := (cAliasSra)->RA_FILIAL
            cMat :=  (cAliasSra)->RA_MAT


            SRA->(DbGoto((cAliasSra)->RECNO))

            GPIncProc(OemToAnsi("Processando matrícula: ")+SRA->RA_FILIAL+" - "+SRA->RA_MAT+ If(lOfusca, "", " - "+SRA->RA_NOME) )

            aChkPonMes := ChkPonMes(cFil, cMat)

            lPonMes := aChkPonMes[1]
            cPfData := aChkPonMes[2]

            If lPonMes
                dNextPerIni := aChkPonMes[3]
                dNextPerFim := aChkPonMes[4]
                InsLinTurn(cFil, cMat, cPfData, dNextPerIni, dNextPerFim)
            EndIf

            (cAliasSra)->(DbSkip())
        EndDo
        (cAliasSra)->(DbCloseArea())
    End Sequence
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkPonMes
Verifica se o funcionário deve ter nova linha de turno na SPF
@author  Philipe Couto
@since   08/11/2018
@version 0.1
/*/
//-------------------------------------------------------------------
Static Function ChkPonMes(cFil, cMat)

    Local cGetPfData    := ""
    Local dIniPonMes	:= Ctod("//")
    Local dFimPonMes	:= Ctod("//")
    Local dNextPerIni	:= Ctod("//")
    Local dNextPerFim	:= Ctod("//")
    Local aReturn       := {}
    Local lRet          := .F.
    Local cReg2			:= ""
    Local cRaSitFolh    := SRA->RA_SITFOLH

    Default cFil := ""
    Default cMat := ""

    GetPonMesDat(@dIniPonMes , @dFimPonMes, cFil)

    dNextPerIni := dIniPonMes
    dNextPerFim := dFimPonMes

    dIniPonMes := DTOS(dIniPonMes)
    dFimPonMes := DTOS(dFimPonMes)

    cReg2 := GetPfData(cFil, cMat, 2, dIniPonMes)

    If !Empty(cReg2) .OR. cRaSitFolh == "D"
    	lRet := .F.
    Else
	    cGetPfData := GetPfData(cFil, cMat, 1, dIniPonMes)
	    If dIniPonMes > cGetPfData
	        lRet := .T.
	    EndIf
	EndIf

    Aadd(aReturn, lRet)
    Aadd(aReturn, cGetPfData)
    Aadd(aReturn, dNextPerIni)
    Aadd(aReturn, dNextPerFim)
Return aReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} GetPfData
Obtém a data atual do registro do func na SPF
@author  Philipe Couto
@since   08/11/2018
@version 0.1
/*/
//-------------------------------------------------------------------
Static Function GetPfData(cFil, cMat, cTipo, cDtaIni)

	Local cSpfData	:= ""
	Local cAliasQry	:= GetNextAlias()
	Local cWhere	:= "%%"
	Default cFil	:= ""
	Default cMat	:= ""
	DEFAULT cTipo	:= 1

	If  cTipo == 1
		cWhere := "% AND PF_DATA < '"+ cDtaIni +"'%"
	ElseIf cTipo == 2
		cWhere := "% AND PF_DATA >= '"+ cDtaIni +"'%"
	EndIf

	BeginSql Alias cAliasQry
		SELECT PF_DATA, PF_FILIAL, PF_MAT
		FROM %table:SPF% SPF
		WHERE PF_MAT=%exp:cMat% AND PF_FILIAL=%exp:cFil% AND D_E_L_E_T_=' '
		%exp:cWhere%
		ORDER BY PF_DATA DESC
	EndSql

	If !(cAliasQry)->(Eof())
		cSpfData := (cAliasQry)->PF_DATA
	EndIf
	(cAliasQry)->(DbCloseArea())

Return cSpfData

//-------------------------------------------------------------------
/*/{Protheus.doc} InsLinTurn
Realiza a troca de turno do funcionário
@author  Philipe Couto
@since   09/11/2018
@version 0.1
/*/
//-------------------------------------------------------------------
Static Function InsLinTurn(cFil, cMat, cPfData, dPerIni, dNextPerFim)

    Local aTabPadrao    := {}
    Local aTabCalend    := {}
    Local aTurnos       := {}
    Local dFunPerIni
    Local dFunPerPro
    Local cTurnoDe
    Local cTurnoPara
    Local cRegDe
    Local cRegPar
    Local cSeqDe
    Local cSeqPar
    Local nLenTabCal    := 0
    Local dNewPerTur    := ""

    Default cFil        := ""
    Default cMat        := ""
    Default cPfData     := ""
    Default dPerIni     := ""
    Default dNextPerFim := ""

    DbSelectArea("SPF")
    DbSetOrder(1)

    dFunPerIni := STOD(cPfData)
    dFunPerPro := dPerIni

    dNewPerTur := DTOS(dPerIni)

    If (cAliasSra)->( CriaCalend( 	dFunPerIni	,; //01 -> Periodo Inicial
                                    dFunPerPro	,; //02 -> Periodo Final (Com um Dia a Mais para a Obtencao da Proxima Sequencia)
                                    RA_TNOTRAB  ,; //03 -> Turno de Trabalho
                                    RA_SEQTURN  ,; //04 -> Sequencia de Turno
                                    @aTabPadrao	,; //05 -> Tabela de Horario Padrao
                                    @aTabCalend	,; //06 -> Calendario de Marcacoes
                                    RA_FILIAL	,; //07 -> Filial do Funcionario
                                    RA_MAT		,; //08 -> Matricula do Funcionario
                                    NIL   		,; //09 -> Centro de Custo do Funcionario (Nao Passar Pois Nao precisa carregar as Excecoes)
                                    @aTurnos	,; //10 -> Array com as Trocas de Turno
                                    NIL			,; //11 -> Array com Todas as Excecoes do Periodo
                                    NIL			,; //12 -> Se executa Query para a Montagem da Tabela Padrao
                                    .F.			,; //13 -> Se executa a funcao se sincronismo do calendario
                                    .T.			 ; //14 -> Se forca a Criacao de novo Calendario
                                    );
                        )
    EndIf

    nLenTabCal := Len(aTabCalend)

    If nLenTabCal > 0
        cSeqDe   := aTabCalend[1][8]
        cTurnoDe := aTabCalend[1][14]
        cRegDe   := aTabCalend[1][23]

        cSeqPar     := aTabCalend[nLenTabCal][8]
        cTurnoPara  := aTabCalend[nLenTabCal][14]
        cRegPar     := aTabCalend[nLenTabCal][23]
    EndIf

    If !SPF->( DbSeek( ( cFil + cMat + dNewPerTur ) ) )
        If SPF->( RecLock( "SPF" , .T. ) )
            SPF->PF_FILIAL	:= cFil
            SPF->PF_MAT		:= cMat
            SPF->PF_DATA	:= dPerIni
            SPF->PF_TURNODE	:= cTurnoDe
            SPF->PF_SEQUEDE	:= cSeqDe
            SPF->PF_REGRADE	:= cRegDe
            SPF->PF_TURNOPA	:= cTurnoPara
            SPF->PF_SEQUEPA	:= cSeqPar
            SPF->PF_REGRAPA	:= cRegPar
            aadd(alog[1], cFil + " - " + cMat + " --> "+ If(lOfusca, Replicate('*',30), SRA->RA_NOME) )
            SPF->( MsUnLock() )
        EndIf
    EndIf
Return
