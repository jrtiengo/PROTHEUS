#INCLUDE "PROTHEUS.CH"

User Function UPDSR0RG2()

Local aButtons      := {}
Local aSays         := {}
Local bFilt			:= { || GpFltBldExp( "SRA" , NIL , @cExpFiltro , NIL ) }
Local cExpFiltro    := ""
Local nOpcA         := 0

Private aCodFol     := {}
Private aLogUPD     := {}
Private aTitle      := {}

aAdd(aSays,OemToAnsi( "Este programa tem como objetivo efetuar o fechamento de registros" ))
aAdd(aSays,OemToAnsi( "na tabela SR0 que tem dias de cálculo zerados que não foram" ))
aAdd(aSays,OemToAnsi( "migrados para a tabela de histórico RG2." ))
aAdd(aSays,OemToAnsi( 'Clique no botão "Abrir" para abrir a documentação no TDN.'))
aAdd(aSays,OemToAnsi( "" ))

aAdd(aButtons, { 14 ,.T.,{||  ShellExecute("open","https://tdn.totvs.com/x/neqWJw","","",1) } } )
aAdd(aButtons, { 17,.T.,bFilt } )
aAdd(aButtons, { 1,.T.,{|o| nOpcA := 1,IF(gpconfOK(), FechaBatch(), nOpcA := 0 ) }} )
aAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )

//Abre a tela de processamento
FormBatch( "Fechamento de registros na tabela RG2", aSays, aButtons )

//Efetua o processamento de geração
If nOpcA == 1
    Aadd( aTitle, OemToAnsi( "Funcionários que tiveram registros alterados:" ) )
    Aadd( aLogUPD, {} )
    ProcGpe( {|lEnd| fProcessa( cExpFiltro )},,,.T. )
    If !Empty(aLogUPD[1])
        fMakeLog(aLogUPD,aTitle,,,"UPDSR0RG2",OemToAnsi("Log de Ocorrências"),"M","P",,.F.)
    EndIf
EndIf

Return

/*/{Protheus.doc} fProcessa
Função que efetua o processamento para a geração do Id 1562
/*/
Static Function fProcessa( cFiltroSRA )

Local aAreaRG2      := RG2->( GetArea() )
Local aAreaSRA      := SRA->( GetArea() )
Local aAreaSR0      := SR0->( GetArea() )
Local aPerAtual     := {}
Local cAliasQry     := GetNextAlias()
Local cFilOld       := ""
Local cPerAberto    := ""
Local cProcOld      := ""
Local cWhere        := "%%"
Local lCampos       := SR0->( ColumnPos("R0_SLDANT") ) > 0 .And. SR0->( ColumnPos("R0_VALORI") )
Local lExcluiSR0    := .T.

If !Empty(cFiltroSRA)
    cFiltroSRA 	:= GPEParSQL(fPrepExpIn(cFiltroSRA))
    cWhere 		:= "%" + cFiltroSRA + " AND%"
EndIf

RG2->( dbSetOrder(1) )//RG2_FILIAL+RG2_MAT+RG2_TPVALE+RG2_CODIGO+RG2_PERIOD+RG2_NROPGT+RG2_ROTEIR
SRA->( dbSetOrder(1) )//RA_FILIAL+RA_MAT+RA_NOME
SR0->( dbSetOrder(1) )//R0_FILIAL+R0_MAT+R0_CODIGO+R0_TPVALE

BeginSql alias cAliasQry
    SELECT R_E_C_N_O_ AS RECNO
    FROM %table:SRA% SRA
    WHERE %exp:cWhere% 
            EXISTS ( SELECT * FROM %table:SR0% SR0 WHERE SR0.R0_FILIAL = SRA.RA_FILIAL AND SR0.R0_MAT = SRA.RA_MAT AND SR0.R0_QDIACAL = '0' AND SR0.R0_VALCAL = '0' AND SR0.%notDel%) AND
            SRA.%notDel%            
    ORDER BY RA_FILIAL,RA_MAT
EndSql 

While (cAliasQry)->( !EoF() )
    SRA->( dbGoTo( (cAliasQry)->RECNO ) )

    If SRA->RA_FILIAL != cFilOld
        aPerAtual   := {}
        cFilOld     := SRA->RA_FILIAL
        cProcOld    := SRA->RA_PROCES
        If fGetPerAtual( @aPerAtual, xFilial("RCH", SRA->RA_FILIAL), SRA->RA_PROCES, "FOL" )
            cPerAberto  := aPerAtual[1, 1]
        Else
            cPerAberto  := AnoMes(dDataBase)
        EndIf
    ElseIf SRA->RA_PROCES != cProcOld
        aPerAtual   := {}
        cProcOld    := SRA->RA_PROCES
        If fGetPerAtual( @aPerAtual, xFilial("RCH", SRA->RA_FILIAL), SRA->RA_PROCES, "FOL" )
            cPerAberto  := aPerAtual[1, 1]
        Else
            dDataAtu    := AnoMes(dDataBase)
        EndIf           
    EndIf

    If SR0->( dbSeek( SRA->RA_FILIAL+SRA->RA_MAT ) )
        While SR0->( !EoF() ) .And. SR0->R0_FILIAL+SR0->R0_MAT == SRA->RA_FILIAL+SRA->RA_MAT
            If SR0->R0_QDIACAL == 0 .And. SR0->R0_VALCAL == 0 .And. SR0->R0_PERIOD < cPerAberto
                lExcluiSR0    := .T.
                If aScan( aLogUPD[1], { |x| x ==  "Filial: " + SRA->RA_FILIAL + "  -  Matrícula: " + SRA->RA_MAT } ) == 0
                    aAdd( aLogUPD[1], "Filial: " + SRA->RA_FILIAL + "  -  Matrícula: " + SRA->RA_MAT )
                EndIf
                If RG2->( dbSeek( SRA->RA_FILIAL+SRA->RA_MAT+SR0->R0_TPVALE+SR0->R0_CODIGO+SR0->R0_PERIOD+SR0->R0_NROPGT+SR0->R0_ROTEIR ) )
                    aAdd( aLogUPD[1], "----- Lançamento abaixo já existia na tabela RG2:"  )
                    aAdd( aLogUPD[1], "----- Período: " + SR0->R0_PERIOD  + " | Roteiro: " + SR0->R0_ROTEIR + " | Tipo: " + SR0->R0_TPVALE + " | Código: " + SR0->R0_CODIGO  )
                    aAdd( aLogUPD[1], "----- O registro apenas será excluído da tabela SR0."  )
                Else
                    If RG2->( RecLock( "RG2", .T. ) )
                        RG2->RG2_FILIAL	:= SR0->R0_FILIAL
                        RG2->RG2_MAT   	:= SR0->R0_MAT
                        RG2->RG2_PERIOD	:= SR0->R0_PERIOD
                        RG2->RG2_NROPGT	:= SR0->R0_NROPGT
                        RG2->RG2_TPVALE	:= SR0->R0_TPVALE
                        RG2->RG2_CODIGO	:= SR0->R0_CODIGO
                        RG2->RG2_ANOMES	:= SR0->R0_PERIOD
                        RG2->RG2_ROTEIR	:= SR0->R0_ROTEIR
                        RG2->RG2_TPBEN	:= SR0->R0_TPBEN
                        RG2->RG2_PEDIDO	:= SR0->R0_PEDIDO
                        RG2->RG2_NROPED := SR0->R0_NROPED
                        RG2->RG2_VALFIX := SR0->R0_QVALFIX
                        RG2->RG2_VALSEG := SR0->R0_QVALSEG
                        RG2->RG2_VALTER := SR0->R0_QVALTER
                        RG2->RG2_VALQUA := SR0->R0_QVALQUA
                        RG2->RG2_VALQUI := SR0->R0_QVALQUI
                        RG2->RG2_VALSEX := SR0->R0_QVALSEX
                        RG2->RG2_VALSAB := SR0->R0_QVALSAB
                        RG2->RG2_VALDOM := SR0->R0_QVALDOM
                        RG2->RG2_DIAPRO	:= SR0->R0_DIASPRO
                        RG2->RG2_DIACAL	:= SR0->R0_QDIACAL
                        RG2->RG2_VALCAL	:= SR0->R0_VALCAL
                        RG2->RG2_CUSUNI	:= SR0->R0_VLRVALE
                        RG2->RG2_CUSFUN	:= SR0->R0_VLRFUNC
                        RG2->RG2_CUSEMP	:= SR0->R0_VLREMP
                        RG2->RG2_PERC	:= 0
                        RG2->RG2_SALBSE	:= SR0->R0_SALBASE
                        RG2->RG2_CC		:= SR0->R0_CC
                        RG2->RG2_DIADIF	:= SR0->R0_QDIADIF
                        RG2->RG2_VALDIF	:= SR0->R0_VALDIF
                        RG2->RG2_CUNIDF	:= SR0->R0_CUNIDF
                        RG2->RG2_CFUNDF	:= SR0->R0_CFUNDF
                        RG2->RG2_CEMPDF	:= SR0->R0_CEMPDF
                        RG2->RG2_VTDUTE	:= SR0->R0_QDIAINF
                        RG2->RG2_VTDNUT	:= SR0->R0_QDNUTIL
                        RG2->RG2_DUTILM	:= SR0->R0_DUTILM
                        RG2->RG2_DNUTIM	:= SR0->R0_DNUTIM
                        RG2->RG2_FALTAS	:= SR0->R0_FALTAS
                        RG2->RG2_FERIAS	:= SR0->R0_FERIAS
                        RG2->RG2_AFAST	:= SR0->R0_AFAST

                        If lCampos
                            RG2->RG2_SLDANT	:= SR0->R0_SLDANT
                            RG2->RG2_VALORI	:= SR0->R0_VALORI
                        EndIf

                        RG2->( MsUnlock() )

                        aAdd( aLogUPD[1], "----- Lançamento abaixo foi migrado para a tabela RG2:"  )
                        aAdd( aLogUPD[1], "----- Período: " + SR0->R0_PERIOD  + " | Roteiro: " + SR0->R0_ROTEIR + " | Tipo: " + SR0->R0_TPVALE + " | Código: " + SR0->R0_CODIGO  )
                    Else
                        lExcluiSR0    := .F.
                        aAdd( aLogUPD[1], "----- Não foi possível efetuar gravação na tabela RG2. O lançamento abaixo será mantido na tabela SR0:"  )
                        aAdd( aLogUPD[1], "----- Período: " + SR0->R0_PERIOD  + " | Roteiro: " + SR0->R0_ROTEIR + " | Tipo: " + SR0->R0_TPVALE + " | Código: " + SR0->R0_CODIGO  )
                    EndIf
                EndIf
                If lExcluiSR0
                    If SR0->( RecLock( "SR0", .F. ) )
                        SR0->( dbDelete() )
                        SR0->( MsUnlock() )
                    Else
                        aAdd( aLogUPD[1], "----- Não foi possível efetuar exclusão na tabela SR0. O lançamento abaixo será mantido na tabela SR0:"  )
                        aAdd( aLogUPD[1], "----- Período: " + SR0->R0_PERIOD  + " | Roteiro: " + SR0->R0_ROTEIR + " | Tipo: " + SR0->R0_TPVALE + " | Código: " + SR0->R0_CODIGO  ) 
                    EndIf
                EndIf
            EndIf
            SR0->( dbSkip() ) 
        EndDo
    EndIf
    (cAliasQry)->( dbSkip() )
EndDo

//Fecha a tabela temporária da query
(cAliasQry)->( dbCloseArea() )

RestArea( aAreaSR0 )
RestArea( aAreaSRA )
RestArea( aAreaRG2 )

Return
