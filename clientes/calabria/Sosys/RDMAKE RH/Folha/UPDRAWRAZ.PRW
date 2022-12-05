#INCLUDE "PROTHEUS.CH"

User Function UPDRAWRAZ()

Local aButtons      := {}
Local aSays         := {}
Local cMsg          := ""
Local cMsgHelp      := ""
Local nOpcA         := 0
Local aErros	    := {}

Private aCodHash    := {}
Private aInssHash   := {}
Private aLog        := {}
Private aTitle      := {}
Private cPerg       := "UPDRAWRAZ"
Private cSRACPF 	:= "QRYSRACPF"
Private oHash       := HMNew()
Private oTmpCPF     := Nil

If !Fp_CodFol(@aCodHash, xFilial('SRV', cFilAnt), .F., .F.)
    Return(.F.)
EndIf
If !Car_inss(@aInssHash, "202003")
    Return(.F.)
EndIf
HMSet( oHash, xFilial('SRV', cFilAnt), aClone(aCodHash) )
HMSet( oHash, cFilAnt+"202003", aClone(aInssHash) )

If !SX1->(DbSeek('UPDRAWRAZ'))
	cMsg :=  + CRLF + OemToAnsi("Não foi encontrado o grupo de perguntas: ") + Alltrim(cPerg)
	
	cMsgHelp := ""
	cMsgHelp += + CRLF + OemToAnsi("Antes de prosseguir será necessário criar o grupo de perguntas. Para isso, siga as instruções contidas no link abaixo:")
	cMsgHelp += + CRLF + 'https://tdn.totvs.com/x/ULaFI' + CRLF

	aAdd(aErros, cMsgHelp)
	
	Help(,, 'NOPERGUNT',, cMsg, 1, 0,,,,,, {aErros})			
	Return
EndIf

aAdd(aSays,OemToAnsi( "Este programa tem como objetivo ajustar as informações de múltiplos vínculos gravadas" ))
aAdd(aSays,OemToAnsi( "nas tabelas RAW/RAZ quando o trabalhador múltiplos vínculos possui até 2 empregadores" ))
aAdd(aSays,OemToAnsi( "(raiz de CNPJ distintos) dentro do Protheus, conforme resposta da pergunta 07.21 no" ))
aAdd(aSays,OemToAnsi( "FAQ disponível no site do eSocial https://portal.esocial.gov.br e documentação no TDN" ))
aAdd(aSays,OemToAnsi( "disponível em https://tdn.totvs.com/x/ULaFI" ))
aAdd(aSays,OemToAnsi( ""))
aAdd(aSays,OemToAnsi( "Obs.: efetue o backup das tabelas RAW/RAZ antes de prosseguir!"))

aAdd(aButtons, { 14, .T., {|| ShellExecute("open","https://tdn.totvs.com/x/ULaFI","","",1) } } )
aAdd(aButtons, { 5, .T., {|| Pergunte(cPerg,.T. ) } } )
aAdd(aButtons, { 1, .T., {|o| nOpcA := 1,IF(gpconfOK(), FechaBatch(), nOpcA := 0 ) } } )
aAdd(aButtons, { 2, .T., {|o| FechaBatch() } } )

//Abre a tela de processamento
FormBatch( "Atualização das tabelas RAW/RAZ", aSays, aButtons )

//Efetua o processamento de geração
If nOpcA == 1
    Aadd( aTitle, OemToAnsi( "Funcionários que tiveram ajuste:" ) )
    Aadd( aTitle, OemToAnsi( "Funcionários que NÃO tiveram ajuste:" ) )
    Aadd( aLog, {} )
    Aadd( aLog, {} )
    ProcGpe( {|lEnd| fProcessa()},,,.T. )
    fMakeLog(aLog,aTitle,,,"UPDRAWRAZ",OemToAnsi("Log de Ocorrências"),"M","P",,.F.)
	HMClean(oHash)
	FreeObj(oHash)
	oHash := Nil
EndIf

Return

/*/{Protheus.doc} fProcessa
Função que efetua o processamento do ajuste nas tabelas RAW/RAZ
/*/
Static Function fProcessa()

Local aAreaSRA  := SRA->( GetArea() )
Local aEstb		:= fGM23SM0(,.T.)
Local aMats     := {}
Local aMatProc  := {}
Local cAliasQry := GetNextAlias()
Local cCPFOld   := ""
Local cFilOld   := cFilAnt
Local cCNPJ     := ""
Local cIndMV    := ""
Local cNomeTCPF := ""
Local cWhere    := ""
Local cWhereSRA := ""
Local lBackup   := MsgYesNo("O backup da base já foi realizado?")
Local lExterno  := .F.
Local nAliq     := 0
Local nAliqTot  := 0
Local nBasEmp1  := 0
Local nBasEmp2  := 0
Local nContCNPJ := 0
Local nContMat  := 0
Local nPos      := 0
Local nTotal    := 0

If lBackup
    Pergunte( cPerg, .F. )
    MakeSqlExpr( cPerg )

    If Empty(mv_par03) .Or. Empty(mv_par04)
        MsgAlert("Efetue o preenchimento do período de/até")
        Return
    EndIf

    //Filial
    If !Empty(mv_par01)
        cWhereSRA += mv_par01
        cWhereSRA := StrTran( cWhereSRA, "RA_FILIAL", "SRA.RA_FILIAL" )
    EndIf

    //Matricula
    If !Empty(mv_par02)
        cWhereSRA += Iif(!Empty(cWhereSRA), " AND ", "")
        cWhereSRA += mv_par02
        cWhereSRA := StrTran( cWhereSRA, "RA_MAT", "SRA.RA_MAT" )
    EndIf

    cWhere += "RAZ.RAZ_FOLMES >= '202003' AND "
 
    //Periodo inicial
    cWhere += "RAZ.RAZ_FOLMES >= '" + mv_par03 + "' "

    //Periodo final
    cWhere += "AND RAZ.RAZ_FOLMES <= '" + mv_par04 + "' "

    //Prepara a variável para uso no BeginSql
    cWhere      := "%" + cWhere + "%"

	fQryCPF(cWhereSRA, cWhere)
	cNomeTCPF := "%" + oTmpCPF:GetRealName() + "%"

    BeginSql alias cAliasQry
        SELECT SRA.RA_CIC,RAZ.RAZ_TPFOL,RAZ.RAZ_FOLMES, COUNT(*) AS TOTAL
        FROM %table:RAZ% RAZ
        INNER JOIN %table:SRA% SRA ON RAZ.RAZ_FILIAL = SRA.RA_FILIAL AND RAZ.RAZ_MAT = SRA.RA_MAT
        WHERE EXISTS (SELECT RA_CIC FROM %exp:cNomeTCPF% SRA2 WHERE SRA2.RA_CIC = SRA.RA_CIC)
            AND %exp:cWhere%
            AND RAZ.%notDel%
            AND SRA.%notDel%            
        GROUP BY SRA.RA_CIC,RAZ.RAZ_TPFOL,RAZ.RAZ_FOLMES
        HAVING COUNT(*) > 1 
    EndSql

    While (cAliasQry)->( !EoF() )
        nTotal += (cAliasQry)->TOTAL
        (cAliasQry)->( dbSkip() )
    EndDo

    GPProcRegua( nTotal )
    (cAliasQry)->( dbCloseArea() )

    BeginSql alias cAliasQry
        SELECT SRA.RA_CIC,RAZ.RAZ_TPFOL,RAZ.RAZ_FOLMES,RAZ.RAZ_FILIAL,RAZ.RAZ_MAT,RAZ.RAZ_INSCR,RAZ.R_E_C_N_O_
        FROM %table:RAZ% RAZ
        INNER JOIN %table:SRA% SRA ON RAZ.RAZ_FILIAL = SRA.RA_FILIAL AND RAZ.RAZ_MAT = SRA.RA_MAT
        WHERE EXISTS (SELECT RA_CIC FROM %exp:cNomeTCPF% SRA2 WHERE SRA2.RA_CIC = SRA.RA_CIC)
            AND %exp:cWhere%
            AND RAZ.%notDel%
            AND SRA.%notDel%                        

        ORDER BY SRA.RA_CIC,RAZ.RAZ_TPFOL,RAZ.RAZ_FOLMES,RAZ.RAZ_FILIAL,RAZ.RAZ_MAT,RAZ.RAZ_INSCR
    EndSql

    SRA->( dbSetOrder(1) )

    While (cAliasQry)->( !EoF() )   
        aMats       := {}
        aMatProc    := {}
        cCPFOld     := (cAliasQry)->RA_CIC
        cPerOld     := (cAliasQry)->RAZ_FOLMES
        lExterno    := .F.
        
        While (cAliasQry)->( !EoF() ) .And. (cAliasQry)->RAZ_FOLMES+(cAliasQry)->RA_CIC == cPerOld+cCPFOld
            SRA->( dbSeek( (cAliasQry)->RAZ_FILIAL+(cAliasQry)->RAZ_MAT ) )
            GPIncProc("CPF: " + Transform(SRA->RA_CIC, "@R 999.999.999-99") + " | Funcionário: " + SRA->RA_FILIAL+SRA->RA_MAT )

            If (nPos := aScan(aEstb, { |x| AllTrim(x[2]) == AllTrim((cAliasQry)->RAZ_INSCR) } )) == 0
                lExterno    := .T.
            EndIf

            If aScan( aMatProc, { |x| x[1]+x[2] == (cAliasQry)->RAZ_FILIAL+(cAliasQry)->RAZ_MAT } ) == 0
                aAdd( aMatProc, { (cAliasQry)->RAZ_FILIAL, (cAliasQry)->RAZ_MAT } )
            Else
                (cAliasQry)->( dbSkip() )
                Loop  
            EndIf
 
            cCNPJ := ""
            If (nPos := aScan(aEstb, {|x| AllTrim(x[1]) == AllTrim(SRA->RA_FILIAL) })) > 0
                cCNPJ := SubStr(aEstb[nPos][2], 1, 8)
            EndIf

            If !Empty(cCNPJ) 
                If SRA->RA_FILIAL != cFilOld
                    cFilOld     := SRA->RA_FILIAL
                    aCodHash    := {}
                    aInssHash   := {}
                    RstaCodFol()
                    If !HMGet(oHash, xFilial('SRV', SRA->RA_FILIAL), @aCodHash)
                        If !Fp_CodFol(@aCodHash, xFilial('SRV', SRA->RA_FILIAL))
                            Return(.F.)
                        EndIf
                        HMSet( oHash, xFilial('SRV', SRA->RA_FILIAL), aClone(aCodHash) )
                    EndIf
                    If !HMGet(oHash, SRA->RA_FILIAL+(cAliasQry)->RAZ_FOLMES, @aInssHash)
                        If !Car_inss(@aInssHash, (cAliasQry)->RAZ_FOLMES)
                            Return(.F.)
                        EndIf
                        HMSet( oHash, SRA->RA_FILIAL+(cAliasQry)->RAZ_FOLMES, aClone(aInssHash) )
                    EndIf
                EndIf
                If (cAliasQry)->RAZ_TPFOL == "2"
                    cPdBas  := aCodHash[019,1] + "/" + aCodHash[020,1]
                Else
                    cPdBas  := aCodHash[013,1] + "/" + aCodHash[014,1] + "/" + aCodHash[221,1]
                EndIf
                nBaseMat := fBuscaSal( (cAliasQry)->RAZ_FILIAL, (cAliasQry)->RAZ_MAT, (cAliasQry)->RAZ_TPFOL, (cAliasQry)->RAZ_FOLMES, cPdBas )
 
                If (nPos := aScan(aMats, {|x| x[1] == cCNPJ } ) ) == 0
                    aAdd( aMats, { cCNPJ, nBaseMat, { { SRA->RA_FILIAL, SRA->RA_MAT } } } )
                Else
                    aMats[nPos, 2] += nBaseMat
                    aAdd( aMats[nPos, 3], { SRA->RA_FILIAL, SRA->RA_MAT } ) 
                EndIf
            EndIf

            (cAliasQry)->( dbSkip() )
        EndDo

        If !lExterno
            If Len(aMats) == 1
                For nContCNPJ := 1 To Len(aMats)
                    For nContMat := 1 To Len(aMats[nContCNPJ, 3])
                        aAdd( aLog[2], "Filial: " + aMats[nContCNPJ, 3, nContMat, 1] + "  -  Matrícula: " + aMats[nContCNPJ, 3, nContMat, 2] + "  -  Período: " + cPerOld + " NÃO foi atualizado pois trabalhador possui 1 empregador." )
                    Next nContMat         
                Next nContCNPJ
            ElseIf Len(aMats) == 2
                cIndMV  := "1"
                For nContCNPJ := 1 To Len(aMats)
                    If nContCNPJ == 1
                        nBasEmp1    := aMats[nContCNPJ, 2]
                        For nContMat := 1 To Len(aMats[nContCNPJ, 3])
                            If RAW->( dbSeek( aMats[nContCNPJ, 3, nContMat, 1]+aMats[nContCNPJ, 3, nContMat, 2]+cPerOld ) )
                                While RAW->( !EoF() ) .And. RAW->RAW_FILIAL+RAW->RAW_MAT+RAW->RAW_FOLMES == aMats[nContCNPJ, 3, nContMat, 1]+aMats[nContCNPJ, 3, nContMat, 2]+cPerOld
                                    If RAW->( Reclock("RAW", .F.) )
                                        aAdd( aLog[1], "Registro: Filial: " + RAW->RAW_FILIAL + "  -  Matrícula: " + RAW->RAW_MAT + "  -  Período: " + cPerOld + "  -  Recno: " + cValToChar(RAW->( Recno() )) + " da tabela RAW foi EXCLUÍDO." )
                                        RAW->( dbDelete() )
                                        RAW->( MsUnlock() )                                        
                                    EndIf
                                    RAW->( dbSkip() )
                                EndDo
                            EndIf
                            If RAZ->( dbSeek( aMats[nContCNPJ, 3, nContMat, 1]+aMats[nContCNPJ, 3, nContMat, 2]+cPerOld ) )
                                While RAZ->( !EoF() ) .And. RAZ->RAZ_FILIAL+RAZ->RAZ_MAT+RAZ->RAZ_FOLMES == aMats[nContCNPJ, 3, nContMat, 1]+aMats[nContCNPJ, 3, nContMat, 2]+cPerOld
                                    If RAZ->( Reclock("RAZ", .F.) )
                                        aAdd( aLog[1], "Registro: Filial: " + RAZ->RAZ_FILIAL + "  -  Matrícula: " + RAZ->RAZ_MAT + "  -  Período: " + cPerOld + "  -  Recno: " + cValToChar(RAZ->( Recno() )) + " da tabela RAZ foi EXCLUÍDO." )
                                        RAZ->( dbDelete() )
                                        RAZ->( MsUnlock() )                                        
                                    EndIf
                                    RAZ->( dbSkip() )
                                EndDo
                            EndIf
                        Next nContMat                        
                    Else
                        nBasEmp2    := aMats[nContCNPJ, 2]
                        Calc_Inss(aInssHash, nBasEmp1+nBasEmp2, 0, 0, 0, 0, 0, 0, Nil, 0, {}, .T., @nAliqTot)
                        Calc_Inss(aInssHash, nBasEmp1, 0, 0, 0, 0, 0, 0, Nil, 0, {}, .T., @nAliq)
                        If nAliq != nAliqTot
                            cIndMV	:= "2"
                        EndIf
                        For nContMat := 1 To Len(aMats[nContCNPJ, 3])
                            If RAW->( dbSeek( aMats[nContCNPJ, 3, nContMat, 1]+aMats[nContCNPJ, 3, nContMat, 2]+cPerOld ) )
                                While RAW->( !EoF() ) .And. RAW->RAW_FILIAL+RAW->RAW_MAT+RAW->RAW_FOLMES == aMats[nContCNPJ, 3, nContMat, 1]+aMats[nContCNPJ, 3, nContMat, 2]+cPerOld
                                    If RAW->RAW_TPREC != cIndMV .And. RAW->( Reclock("RAW", .F.) )
                                        aAdd( aLog[1], "Registro: Filial: " + RAW->RAW_FILIAL + "  -  Matrícula: " + RAW->RAW_MAT + "  -  Período: " + cPerOld + "  -  Recno: " + cValToChar(RAW->( Recno() )) + " da tabela RAW foi ATUALIZADO." )
                                        RAW->RAW_TPREC  := cIndMV
                                        RAW->( MsUnlock() )                                        
                                    EndIf
                                    RAW->( dbSkip() )
                                EndDo
                            EndIf
                        Next nContMat 
                    EndIf
                Next nContCNPJ
            Else
                For nContCNPJ := 1 To Len(aMats)
                    For nContMat := 1 To Len(aMats[nContCNPJ, 3])
                        aAdd( aLog[2], "Filial: " + aMats[nContCNPJ, 3, nContMat, 1] + "  -  Matrícula: " + aMats[nContCNPJ, 3, nContMat, 2] + "  -  Período: " + cPerOld + " NÃO foi atualizado pois trabalhador possui 3 ou mais empregadores." )
                    Next nContMat         
                Next nContCNPJ
            EndIf
        Else
            For nContCNPJ := 1 To Len(aMats)
                For nContMat := 1 To Len(aMats[nContCNPJ, 3])
                    aAdd( aLog[2], "Filial: " + aMats[nContCNPJ, 3, nContMat, 1] + "  -  Matrícula: " + aMats[nContCNPJ, 3, nContMat, 2] + "  -  Período: " + cPerOld + " NÃO foi atualizado pois trabalhador possui vínculo externo" )
                Next nContMat    
            Next nContCNPJ
        EndIf
    EndDo

    (cAliasQry)->( dbCloseArea() )
    oTmpCPF:Delete()
	oTmpCPF := Nil    
Else
    MsgInfo("Realize o backup e execute a rotina novamente.")
EndIf

RestArea(aAreaSRA)

Return

/*/{Protheus.doc} fQryCPF()
Função que guarda os CPFs que serão processados em uma tabela física temporária para utilização na query dos funcionários que serão processados
/*/
Static Function fQryCPF(cFilSRA, cFilRAZ)

Local aColumns  := {}
Local cAliasQ   := GetNextAlias()
Local cQuery    := ""
Local cQryRAZ   := StrTran(cFilRAZ, "%")

aAdd( aColumns, { "RA_CIC"		,"C",11,0})

oTmpCPF := FWTemporaryTable():New(cSRACPF)
oTmpCPF:SetFields( aColumns )
oTmpCPF:Create()

cQuery := "SELECT SRA.RA_CIC FROM " + RetSqlName('SRA') + " SRA "
cQuery += "WHERE "
If !Empty(cFilSRA)
    cQuery 	+= cFilSRA + " AND "
EndIf
cQuery += "SRA.RA_CIC <> ' ' "
cQuery += "AND SRA.D_E_L_E_T_ <> '*' "
cQuery += "AND EXISTS( SELECT SRA.RA_CIC, COUNT(*) FROM " + RetSqlName('SRA') + " SRA2 WHERE SRA.RA_CIC = SRA2.RA_CIC AND SRA2.D_E_L_E_T_ <> '*' "
cQuery += "GROUP BY SRA2.RA_CIC HAVING COUNT(*) > 1 ) "
cQuery += "AND EXISTS( SELECT RAZ.RAZ_FOLMES FROM " + RetSqlName('RAZ') + " RAZ "
cQuery += "INNER JOIN " + RetSqlName('SRA') + " SRA2 ON RAZ.RAZ_FILIAL = SRA2.RA_FILIAL AND RAZ.RAZ_MAT = SRA2.RA_MAT "
cQuery += "WHERE SRA.RA_CIC = SRA2.RA_CIC AND " + cQryRAZ + " AND RAZ.D_E_L_E_T_ <> '*' AND SRA2.D_E_L_E_T_ <> '*' )
cQuery += "GROUP BY SRA.RA_CIC "
cQuery += "ORDER BY SRA.RA_CIC"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQ,.T.,.T.)

While (cAliasQ)->(!Eof())
	If RecLock(cSRACPF, .T.)
		(cSRACPF)->RA_CIC := (cAliasQ)->RA_CIC

		(cSRACPF)->(MsUnLock())
	EndIf
	(cAliasQ)->(DbSkip())
EndDo

(cAliasQ)->( dbCloseArea() )

Return

/*/{Protheus.doc} fBuscaSal
Função que verifica a base de INSS no cálculo de folha da matrícula
/*/
Static Function fBuscaSal( cFilMat, cMatr, cTpFol, cPeriodo, cPdBas )

Local cRot  := ""
Local nBase := 0

If cTpFol == "2"
    cRot    := fGetCalcRot("6")
Else
    cRot    := Iif(SRA->RA_CATFUNC $ "P*A", fGetCalcRot("9"), fGetRotOrdinar())
EndIf

SRD->( dbSetOrder(1) )//RD_FILIAL+RD_MAT+RD_DATARQ+RD_PD+RD_SEMANA+RD_SEQ+RD_CC
IF SRD->( dbSeek( cFilMat+cMatr+cPeriodo ) )
    While SRD->( !EoF() ) .And. SRD->RD_FILIAL+SRD->RD_MAT+SRD->RD_PERIODO == cFilMat+cMatr+cPeriodo
        If SRD->RD_ROTEIR == cRot .And. SRD->RD_PD $ cPdBas
            nBase += SRD->RD_VALOR
        EndIf
        SRD->( dbSkip() )
    EndDo
EndIf
If nBase == 0
    SRC->( dbSetOrder(4) )//RC_FILIAL+RC_MAT+RC_PERIODO+RC_ROTEIR+RC_SEMANA+RC_PD
    IF SRC->( dbSeek( cFilMat+cMatr+cPeriodo ) )
        While SRC->( !EoF() ) .And. SRC->RC_FILIAL+SRC->RC_MAT+SRC->RC_PERIODO == cFilMat+cMatr+cPeriodo
            If SRC->RC_ROTEIR == cRot .And. SRC->RC_PD $ cPdBas
                nBase += SRC->RC_VALOR
            EndIf
            SRC->( dbSkip() )
        EndDo
    EndIf
EndIf

Return nBase