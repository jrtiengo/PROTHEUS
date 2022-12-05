#INCLUDE "PROTHEUS.CH"

User Function UPDDIFPLA()

Local aButtons      := {}
Local aSays         := {}
Local bFilt			:= { || GpFltBldExp( "SRA" , NIL , @cExpFiltro , NIL ) }
Local cExpFiltro    := ""
Local cMsg          := ""
Local nOpcA         := 0

Private aCodFol     := {}
Private aLogUPD     := {}
Private aTitle      := {}
Private cPerg       := "UPDDIFPLA"

If !fVldSX1()
    cMsg := OemToAnsi( "Para executar essa rotina é obrigatório possuir o grupo de perguntas UPDDIFPLA." ) + CRLF
    cMsg += OemToAnsi( "Verifique a documentação no TDN: https://tdn.totvs.com/x/cGkjIw." )
    MsgInfo( cMsg )
    Return()
EndIf

aAdd(aSays,OemToAnsi( "Este programa tem como objetivo apurar diferença do desconto de plano de saúde que" ))
aAdd(aSays,OemToAnsi( "foi congelado de 09/2020 a 12/2020." ))
aAdd(aSays,OemToAnsi( 'Clique no botão "Abrir" para abrir a documentação no TDN.'))
aAdd(aSays,OemToAnsi( "" ))

aAdd(aButtons, { 14 ,.T.,{||  ShellExecute("open","https://tdn.totvs.com/x/cGkjIw","","",1) } } )
aAdd(aButtons, { 17,.T.,bFilt } )
aAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
aAdd(aButtons, { 1,.T.,{|o| nOpcA := 1,IF(gpconfOK(), FechaBatch(), nOpcA := 0 ) }} )
aAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )

//Abre a tela de processamento
FormBatch( "Apuração da diferença de plano de saúde", aSays, aButtons )

//Efetua o processamento de geração
If nOpcA == 1
    Aadd( aTitle, OemToAnsi( "Funcionários que tiveram diferenças geradas:" ) )
    Aadd( aLogUPD, {} )
    ProcGpe( {|lEnd| fProcessa( cExpFiltro )},,,.T. )
    If !Empty(aLogUPD[1])
        fMakeLog(aLogUPD,aTitle,,,"UPDDIFPLA",OemToAnsi("Log de Ocorrências"),"M","P",,.F.)
    EndIf
EndIf

Return

/*/{Protheus.doc} fProcessa
Função que efetua o processamento para a geração do Id 1562
/*/
Static Function fProcessa( cFiltroSRA )

Local aAreaRGB      := RGB->( GetArea() )
Local aAreaRHS      := RHS->( GetArea() )
Local aAreaSRA      := SRA->( GetArea() )
Local aAreaSRD      := SRD->( GetArea() )
Local aTamIt	    := TamSx3("RA_ITEM")
Local aTamClVL	    := TamSx3("RA_CLVL")
Local aDifs         := {}
Local aPerAtual     := {}
Local cAliasQry     := GetNextAlias()
Local cFilOld       := ""
Local cPdDep        := ""
Local cPdEmpAgr     := ""
Local cPdEmpDep     := ""
Local cPdEmpTit     := ""
Local cPdTit        := ""
Local cPerIni       := ""
Local cPerIniQ      := ""
Local cPerFim       := ""
Local cPerFimQ      := ""
Local cProcOld      := ""
Local cWhere        := ""
Local nParcelas     := 0
Local nTipoProc     := 0

Private aLancs      := {}
Private aVbsForn    := {}
Private dDataAtu    := cToD("//")
Private lTemItem	:= !Empty( aTamIt )
Private lTemClVl	:= !Empty( aTamClVl )
Private nTipoTab    := 0

Pergunte( cPerg, .F. )
MakeSqlExpr( cPerg )

cPerIni     := SubStr(mv_par03, 3, 4)+SubStr(mv_par03, 1, 2)
cPerFim     := SubStr(mv_par04, 3, 4)+SubStr(mv_par04, 1, 2)
nTipoTab    := mv_par05
cPdTit      := mv_par06
cPdDep      := mv_par07
nParcelas   := mv_par08
nTipoProc   := mv_par09

If nTipoProc == 1
    If cPerFim < cPerIni
        MsgInfo( "Período final não pode ser menor que o período inicial" )
        Return .F.
    ElseIf cPerIni < "202009"
        MsgInfo( "Período inicial não pode ser menor que 092020 (início do congelamento)" )
        Return .F.
    ElseIf cPerFim > "202012"
        MsgInfo( "Período final não pode ser maior que 122020 (término do congelamento)" )
        Return .F.
    EndIf
EndIf

cPerIniQ := "%'" + cPerIni + "'%"
cPerFimQ := "%'" + cPerFim + "'%"

//Filial
If !Empty(mv_par01)
    cWhere += mv_par01
EndIf

//Matricula
If !Empty(mv_par02)
	cWhere += Iif(!Empty(cWhere)," AND ","")
	cWhere += mv_par02
EndIf

If !Empty(cFiltroSRA)
    cFiltroSRA 	:= GPEParSQL(fPrepExpIn(cFiltroSRA))
    cWhere 		+= "AND ( " + cFiltroSRA + ") "
EndIf

//Prepara a variável para uso no BeginSql
If !Empty(cWhere)
    cWhere += " AND "
EndIf
cWhere := "%" + cWhere + "%"

RGB->( dbSetOrder(1) )//RGB_FILIAL+RGB_MAT+RGB_PD+RGB_PERIOD+RGB_SEMANA+RGB_SEQ+RGB_CONVOC
RHS->( dbSetOrder(1) )//RHS_FILIAL+RHS_MAT+RHS_COMPPG+RHS_ORIGEM+RHS_CODIGO+RHS_TPLAN+RHS_TPFORN+RHS_CODFOR+RHS_TPPLAN+RHS_PLANO+RHS_PD
SRA->( dbSetOrder(1) )//RA_FILIAL+RA_MAT+RA_NOME
SRD->( dbSetOrder(1) )//RD_FILIAL+RD_MAT+RD_DATARQ+RD_PD+RD_SEMANA+RD_SEQ+RD_CC+RD_PROCES

If nTipoProc == 1
    //Processa a query e cria a tabela temporária com os resultados
    BeginSql alias cAliasQry
        SELECT *
        FROM %table:SRA% SRA
        WHERE %exp:cWhere% 
                EXISTS ( SELECT * FROM %table:RHS% RHS WHERE RHS.RHS_FILIAL = SRA.RA_FILIAL AND RHS.RHS_MAT = SRA.RA_MAT AND RHS.RHS_COMPPG >= %exp:cPerIniQ% AND RHS.RHS_COMPPG <= %exp:cPerFimQ% AND RHS.%notDel%) AND
                SRA.%notDel%            
        ORDER BY RA_FILIAL,RA_MAT
    EndSql 

    While (cAliasQry)->( !EoF() )
        aDifs   := {}
        aLancs  := {}
        If SRA->( dbSeek( (cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT ) )
            //Carrega o array aCodFol para verificar o cadastro de verbas x Ids de cálculo
            If SRA->RA_FILIAL != cFilOld
                aPerAtual   := {}
                cFilOld     := SRA->RA_FILIAL
                cProcOld    := SRA->RA_PROCES
                RstaCodFol()
                Fp_CodFol(@aCodFol, SRA->RA_FILIAL, .F., .F.)  
                cPdEmpAgr   := aCodFol[726,1]
                cPdEmpDep   := aCodFol[725,1]
                cPdEmpTit   := aCodFol[213,1]
                If fGetPerAtual( @aPerAtual, xFilial("RCH", SRA->RA_FILIAL), SRA->RA_PROCES, "PLA" )
                    dDataAtu    := aPerAtual[1,6]
                Else
                    dDataAtu    := dDataBase
                EndIf
            ElseIf SRA->RA_PROCES != cProcOld
                aPerAtual   := {}
                cProcOld    := SRA->RA_PROCES
                If fGetPerAtual( @aPerAtual, xFilial("RCH", SRA->RA_FILIAL), SRA->RA_PROCES, "PLA" )
                    dDataAtu    := aPerAtual[1,6]
                Else
                    dDataAtu    := dDataBase
                EndIf           
            EndIf

            fRecalc(cPerIni, cPerFim)

            fApurDif(@aDifs, cPdEmpAgr, cPdEmpDep, cPdEmpTit)
            
            fGravaRGB(aDifs, cPdTit, cPdDep, nParcelas, cPdEmpAgr, cPdEmpDep, cPdEmpTit, aPerAtual[1,1], aPerAtual[1,2])
        EndIf
        //Pula para o próximo registro
        (cAliasQry)->( dbSkip() )
    EndDo
Else
    BeginSql alias cAliasQry
        SELECT *
        FROM %table:RGB% RGB
        WHERE EXISTS ( SELECT * FROM %table:SRA% SRA WHERE %exp:cWhere% RGB.RGB_FILIAL = SRA.RA_FILIAL AND RGB.RGB_MAT = SRA.RA_MAT AND RGB.RGB_NUMID = 'UPDDIFPLA' AND SRA.%notDel%) AND
            RGB.%notDel%            
        ORDER BY RGB_FILIAL,RGB_MAT
    EndSql

    While (cAliasQry)->( !EoF() )
        RGB->( dbGoTo( (cAliasQry)->R_E_C_N_O_ ) )
        If RGB->( RecLock("RGB", .F.) )
            RGB->( dbDelete() )
            RGB->( MsUnlock() )
        EndIf
        //Pula para o próximo registro
        (cAliasQry)->( dbSkip() )
    EndDo
    MsgStop("Processamento finalizado.")
EndIf
//Fecha a tabela temporária da query
(cAliasQry)->( dbCloseArea() )

RestArea( aAreaRGB )
RestArea( aAreaRHS )
RestArea( aAreaSRA )
RestArea( aAreaSRD )

Return

/*/{Protheus.doc} fVldSX1
Função que verifica as perguntas que serão utilizdas na rotina
/*/
Static Function fVldSX1()

Local aAreaSX1  := SX1->( GetArea() )
Local lOk       := .F.

SX1->( dbSetOrder(1) )
lOk := SX1->( dbSeek( cPerg ) )

RestArea(aAreaSX1)

Return lOk

/*/{Protheus.doc} fRecalc
Função que irá recalcular o roteiro PLA
/*/
Static Function fRecalc(cPerIni, cPerFim)

Local cPerAux := cPerIni

While cPerAux <= cPerFim
    SetMnemonicos(NIL,NIL,.T.)
    SetRotExec( "PLA" )
    SetPeriodCalc( cPerAux )
    SetNumPgCalc( "01" )
    ExecRot( SRA->RA_FILIAL, "PLA" )
    cPerAux := SomaMesAno(cPerAux)
End

Return

/*/{Protheus.doc} fApurDif
Função que irá verificar as diferenças devidas
/*/
Static Function fApurDif(aDifs, cPdEmpAgr, cPdEmpDep, cPdEmpTit)

Local c1PdTab   := ""
Local c2PdTab   := ""
Local c3PdTab   := ""
Local cPdEmp    := ""
Local nCont     := 0
Local nLinFor   := 0
Local nLinha    := 0
Local nPosDif   := 0
Local nVlrDif   := 0
Local nVlrEmp   := 0

For nCont := 1 To Len(aLancs)
    If aLancs[nCont, 5] == "1" .And. RHS->( dbSeek( SRA->RA_FILIAL+SRA->RA_MAT+aLancs[nCont, 1]+aLancs[nCont, 2]+aLancs[nCont, 3]+aLancs[nCont, 4]+aLancs[nCont, 5]+aLancs[nCont, 6]+aLancs[nCont, 7]+aLancs[nCont, 8]+aLancs[nCont, 9] ) ) 
        If (nVlrDif := aLancs[nCont, 10] - RHS->RHS_VLRFUN) > 0 .Or. aLancs[nCont, 11] > 0
            nLinFor := aScan( aVbsForn, { |x| x[1]+x[2]+x[3] == SRA->RA_FILIAL+aLancs[nCont, 6]+aLancs[nCont, 5] } )
            nVlrEmp := 0

            If nLinFor > 0
                cPdEmpTit := aVbsForn[nLinFor,4]
                cPdEmpDep := aVbsForn[nLinFor,5]
                cPdEmpAgr := aVbsForn[nLinFor,6]
            Else
                If ( nLinha := fPosTab( 'S016', aLancs[nCont, 6], "=", 4, , , , , , , .T., SRA->RA_FILIAL ) ) > 0

                    c1PdTab	:= fTabela('S016',nLinha,08,,SRA->RA_FILIAL )
                    c2PdTab	:= fTabela('S016',nLinha,09,,SRA->RA_FILIAL )
                    c3PdTab	:= fTabela('S016',nLinha,10,,SRA->RA_FILIAL )

                    cPdEmpTit := If( !Empty(c1PdTab), c1PdTab, cPdEmpTit )
                    cPdEmpDep := If( !Empty(c2PdTab), c2PdTab, cPdEmpDep )
                    cPdEmpAgr := If( !Empty(c3PdTab), c3PdTab, cPdEmpAgr )

                    //Adiciona no array poder ser utilizado ao processar outras matriculas do mesmo fornecedor
                    aAdd( aVbsForn, {;
                                        SRA->RA_FILIAL,;
                                        aLancs[nCont, 6],;
                                        aLancs[nCont, 5],;
                                        cPdEmpTit,;
                                        cPdEmpDep,;
                                        cPdEmpAgr })
                EndIf
            EndIf
            
            If aLancs[nCont, 2] == "1"
                cPdEmp := cPdEmpTit
            ElseIf aLancs[nCont, 2] == "2"
                cPdEmp := cPdEmpDep
            Else
                cPdEmp := cPdEmpAgr
            EndIf

            If RHS->( dbSeek( SRA->RA_FILIAL+SRA->RA_MAT+aLancs[nCont, 1]+aLancs[nCont, 2]+aLancs[nCont, 3]+aLancs[nCont, 4]+aLancs[nCont, 5]+aLancs[nCont, 6]+aLancs[nCont, 7]+aLancs[nCont, 8]+aLancs[nCont, 9] ) )
                nVlrEmp := aLancs[nCont, 11] - RHS->RHS_VLREMP
            EndIf

            If (nPosDif := aScan(aDifs, { |x| x[2]+x[3] == aLancs[nCont, 2]+aLancs[nCont, 3] })) == 0
                aAdd( aDifs, aClone(aLancs[nCont]) )
                aDifs[Len(aDifs), 10] := nVlrDif
                aDifs[Len(aDifs), 11] := nVlrEmp
            Else
                aDifs[nPosDif, 10] += nVlrDif
                aDifs[nPosDif, 11] += nVlrEmp
            EndIf
        EndIf
    EndIf
Next nCont

Return

/*/{Protheus.doc} fGravaRGB
Função que irá verificar as diferenças para gravação na RGB
/*/
Static Function fGravaRGB( aDifs, cPdTit, cPdDep, nParcelas, cPdEmpAgr, cPdEmpDep, cPdEmpTit, cPerAtu, cSemAtu )

Local aRGB          := {}
Local nCont         := 0
Local nLinFor       := 0
Local nPos          := 0

For nCont := 1 To Len(aDifs)
    nLinFor := aScan( aVbsForn, { |x| x[1]+x[2]+x[3] == SRA->RA_FILIAL+aDifs[nCont, 6]+aDifs[nCont, 5] } )
    If nLinFor > 0
        cPdEmpTit := aVbsForn[nLinFor,4]
        cPdEmpDep := aVbsForn[nLinFor,5]
        cPdEmpAgr := aVbsForn[nLinFor,6]
    EndIf
    If aDifs[nCont, 2] == "1"
        If (nPos := aScan( aRGB, { |x| x[1] == cPdTit } )) == 0
            aAdd( aRGB, { cPdTit, aDifs[nCont, 10] } )
        Else
            aRGB[ nPos, 2 ] += aDifs[nCont, 10]
        EndIf
        If (nPos := aScan( aRGB, { |x| x[1] == cPdEmpTit } )) == 0
            aAdd( aRGB, { cPdEmpTit, aDifs[nCont, 11] } )
        Else
            aRGB[ nPos, 2 ] += aDifs[nCont, 11]
        EndIf
    ElseIf aDifs[nCont, 2] == "2"
        If (nPos := aScan( aRGB, { |x| x[1] == cPdDep } )) == 0
            aAdd( aRGB, { cPdDep, aDifs[nCont, 10] } )
        Else
            aRGB[ nPos, 2 ] += aDifs[nCont, 10]
        EndIf
        If (nPos := aScan( aRGB, { |x| x[1] == cPdEmpDep } )) == 0
            aAdd( aRGB, { cPdEmpDep, aDifs[nCont, 11] } )
        Else
            aRGB[ nPos, 2 ] += aDifs[nCont, 11]
        EndIf
    Else
        If (nPos := aScan( aRGB, { |x| x[1] == cPdDep } )) == 0
            aAdd( aRGB, { cPdDep, aDifs[nCont, 10] } )
        Else
            aRGB[ nPos, 2 ] += aDifs[nCont, 10]
        EndIf
        If (nPos := aScan( aRGB, { |x| x[1] == cPdEmpAgr } )) == 0
            aAdd( aRGB, { cPdEmpAgr, aDifs[nCont, 11] } )
        Else
            aRGB[ nPos, 2 ] += aDifs[nCont, 11]
        EndIf
    EndIf
Next nCont

//Adiciona no log de ocorrências
If !Empty(aRGB)
    If aScan( aRGB, { |x| x[2] > 0 } ) > 0
        aAdd( aLogUPD[1], "Filial: " + SRA->RA_FILIAL + "  -  Matrícula: " + SRA->RA_MAT )
    EndIf
    For nCont := 1 To Len(aRGB)
        If aRGB[nCont, 2] > 0
            aAdd( aLogUPD[1], "----- Verba gerada: " + aRGB[nCont, 1] + " | Valor gerado: R$ " + Transform( aRGB[nCont, 2]/nParcelas, "@E 99,999,999,999.99" ) + " | Parcela(s): " + cValToChar(nParcelas) )
            fGrvRGB( aRGB[nCont, 1], aRGB[nCont, 2], nParcelas, cPerAtu, cSemAtu )
        EndIf
    Next nCont
EndIf

Return

/*/{Protheus.doc} fGrvRGB
Função que irá gravar a diferença na RGB
/*/
Static Function fGrvRGB( cPd, nValor, nParcela, cPerAtu, cSemAtu )

Local lMudaDtRef    := .F.
Local lNovo         := .F.

lNovo := !RGB->( dbSeek( SRA->RA_FILIAL+SRA->RA_MAT+cPd+cPerAtu+cSemAtu+"9" ) )

If !lNovo .And. AllTrim(RGB->RGB_NUMID) != "UPDDIFPLA"
    lMudaDtRef      := .T.
    lNovo           := .T.
EndIf

If RGB->( RecLock("RGB", lNovo) )
    RGB->RGB_FILIAL 	:= 	SRA->RA_FILIAL
    RGB->RGB_MAT	 	:= 	SRA->RA_MAT
    RGB->RGB_CC			:= 	SRA->RA_CC
    RGB->RGB_PD			:= 	cPd
    RGB->RGB_PROCES		:=	SRA->RA_PROCES
    RGB->RGB_PERIOD		:= 	cPerAtu
    RGB->RGB_ROTEIR		:= 	"FOL"
    RGB->RGB_ROTORI 	:=  "PLA"
    RGB->RGB_SEMANA 	:=	cSemAtu
    RGB->RGB_TIPO1		:= 	"V"
    RGB->RGB_TIPO2		:= 	"G"
    RGB->RGB_HORAS		:= 	0
    RGB->RGB_VALOR		:= 	(nValor/nParcela)
    RGB->RGB_PARCEL		:= 	nParcela
    RGB->RGB_SEQ		:= 	"9"
    RGB->RGB_NUMID		:= 	"UPDDIFPLA"
    If lMudaDtRef
        RGB->RGB_DTREF	:= dDataBase
    EndIf
    If lTemItem
        RGB->RGB_ITEM := SRA->RA_ITEM
    EndIf
    If lTemClVl
        RGB->RGB_CLVL := SRA->RA_CLVL
    EndIf
    RGB->( MsUnlock() )
EndIf

Return
