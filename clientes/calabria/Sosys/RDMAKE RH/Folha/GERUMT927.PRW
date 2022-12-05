#INCLUDE "PROTHEUS.CH"

User Function GERUMT927()

Local aButtons  := {}
Local aSays     := {}
Local nOpcA     := 0

Private aCodFol := {}
Private aLog    := {}
Private aTitle  := {}
Private oHash   := HMNew()

SetMnemonicos(NIL,NIL,.T.)

If Type("P_LGERBAS") != "L"
    MsgAlert("Cadastro de mnemônicos desatualizado. É necessário possuir o mnemônico P_LGERBAS cadastrado!")
    Return(.F.)
ElseIf P_LGERBAS
    MsgAlert("Foi identificado através do mnemônico P_LGERBAS que a rotina GERUMT927 já foi executada anteriormente. Por esse motivo, não será possível acessar a rotina novamente.")
    Return(.F.)
EndIf

If !Fp_CodFol(@aCodFol, xFilial('SRV', cFilAnt))
    Return(.F.)
EndIf
HMSet( oHash, xFilial('SRV', cFilAnt), aClone(aCodFol) )

aAdd(aSays,OemToAnsi( "Este programa tem como objetivo gerar verbas de base de 1/3 nos cálculos de férias" ))
aAdd(aSays,OemToAnsi( "que tiveram o adiamento do pagamento de 1/3 nas tabelas SRR/SRD caso as verbas de" ))
aAdd(aSays,OemToAnsi( "base NÃO tenham sido geradas no cálculo de férias." ))
aAdd(aSays,OemToAnsi( ""))
aAdd(aSays,OemToAnsi( "Obs.: efetue o backup das tabelas SRR/SRD antes de prosseguir!"))

aAdd(aButtons, { 14, .T., {|| ShellExecute("open","https://tdn.totvs.com/x/nfwYIQ","","",1) } } )
aAdd(aButtons, { 1, .T., {|o| nOpcA := 1,IF(gpconfOK(), FechaBatch(), nOpcA := 0 ) } } )
aAdd(aButtons, { 2, .T., {|o| FechaBatch() } } )

//Abre a tela de processamento
FormBatch( "Geração das verbas de base de 1/3", aSays, aButtons )

//Efetua o processamento de geração
If nOpcA == 1
    Aadd( aTitle, OemToAnsi( "Verbas geradas:" ) )
    Aadd( aLog, {} )
    ProcGpe( {|lEnd| fProcessa()},,,.T. )
    fMakeLog(aLog,aTitle,,,"GERUMT927",OemToAnsi("Log de Ocorrências"),"M","P",,.F.)
	HMClean(oHash)
	FreeObj(oHash)
	oHash := Nil
    If !Empty(aLog) .And. RCA->( dbSeek( xFilial( "RCA", cFilAnt ) + "P_LGERBAS" ) )
        If RecLock("RCA", .F.)
            RCA->RCA_CONTEU := ".T."
            RCA->( MsUnlock() )
        EndIf
    EndIf
EndIf

Return

/*/{Protheus.doc} fProcessa
Função que efetua o processamento para a geração do Id 1661
/*/
Static Function fProcessa()

Local cAliasQry     := GetNextAlias()
Local cFilOld       := cFilAnt
Local cWhere        := ""
Local cPerIni       := ""
Local cPerFim       := ""
Local cUmTFerM      := ""
Local cUmTFerMs     := ""
Local cUmTAboM      := ""
Local cUmTAboMs     := ""
Local cCCFer        := ""
Local cCCFerMs      := ""
Local cCCAbo        := ""
Local cCCAboMs      := ""
Local cSeqFer       := ""
Local cSeqFerMs     := ""
Local cSeqAbo       := ""
Local cSeqAboMs     := ""
Local lNovo         := .F.
Local lBackup       := MsgYesNo("O backup da base já foi realizado?")
Local lPula         := .F.
Local nVFerias      := 0
Local nVFeriasMs    := 0
Local nValAbono     := 0
Local nValAbonoMs   := 0
Local nValBase      := 0

If Type("P_ADIPINI") != "U"
	cPerIni     := P_ADIPINI
	cPerFim     := P_ADIPFIM
	cUmTFerM    := P_ADIUTFM
	cUmTFerMs   := P_ADIUTFMS
	cUmTAboM    := P_ADIUTAM
	cUmTAboMs   := P_ADIUTAMS
EndIf

If lBackup
    If !Empty(cPerIni) .And. !Empty(cUmTFerM)
        //Ordena a tabela SRA pela ordem 1 - RA_FILIAL+RA_MAT
        SRA->( dbSetOrder(1) )
        //Ordena a tabela SRR pela ordem 1 - RR_FILIAL+RR_MAT+RR_TIPO3+DTOS(RR_DATA)+RR_PD+RR_CC
        SRR->( dbSetOrder(1) )
        //Ordena a tabela SRD pela ordem 3 - RD_FILIAL+RD_MAT+DTOS(RD_DATPGT)+RD_PD+RD_SEMANA+RD_SEQ+RD_CC
        SRD->( dbSetOrder(3) )

        cWhere := "SRH.RH_DATAINI >= '" + cPerIni+"01" + "' AND SRH.RH_DATAINI <= '" + cPerFim+"31" + "'"

        //Prepara a variável para uso no BeginSql
        cWhere := "%" + cWhere + "%"

        //Processa a query e cria a tabela temporária com os resultados
        BeginSql alias cAliasQry
            SELECT R_E_C_N_O_ AS RECNO
            FROM %table:SRH% SRH
            WHERE %exp:cWhere% AND
                SRH.%notDel%
        EndSql 

        While (cAliasQry)->( !EoF() )
            SRH->( dbGoTo( (cAliasQry)->RECNO ) )
            
            //Posiciona na tabela SRA
            SRA->( dbSeek( SRH->RH_FILIAL + SRH->RH_MAT ) )

            //Carrega o array aCodFol para verificar o cadastro de verbas x Ids de cálculo
            If SRA->RA_FILIAL != cFilOld
                cFilOld := SRA->RA_FILIAL
                aCodFol    := {}
                RstaCodFol()
                If !HMGet(oHash, xFilial('SRV', SRA->RA_FILIAL), @aCodFol)
                    If !Fp_CodFol(@aCodFol, xFilial('SRV', SRA->RA_FILIAL))
                        Return(.F.)
                    EndIf
                    HMSet( oHash, xFilial('SRV', SRA->RA_FILIAL), aClone(aCodFol) )
                EndIf 
            EndIf

            lPula := SRR->( dbSeek( SRH->RH_FILIAL + SRH->RH_MAT + "F" + dToS(SRH->RH_DATAINI) + aCodFol[077, 1] ) )
            If !lPula
                lPula := SRR->( dbSeek( SRH->RH_FILIAL + SRH->RH_MAT + "F" + dToS(SRH->RH_DATAINI) + cUmTFerM ) )
                If lPula .And. (SRR->RR_VALORBA == 0 .Or. Empty(SRR->RR_CODB1T))
                    lPula := .F.
                EndIf
            EndIf
            //Se encontrar a verba de 1/3 padrão ou a verba de base, pula o registro de férias
            If lPula
                (cAliasQry)->( dbSkip() )
                Loop
            EndIf

            //Posiciona no 1º registro do cálculo de férias
            SRR->( dbSeek( SRH->RH_FILIAL + SRH->RH_MAT + "F" + dToS(SRH->RH_DATAINI) ) )

            nVFerias    := 0
            nVFeriasMS  := 0
            nValAbono   := 0
            nValAbonoMs := 0
            nValBase    := 0

            While SRR->( !EoF() ) .And. SRR->RR_FILIAL+SRR->RR_MAT+SRR->RR_TIPO3+dToS(SRR->RR_DATA) == SRH->RH_FILIAL + SRH->RH_MAT + "F" + dToS(SRH->RH_DATAINI)
                If SRR->RR_PD $ aCodFol[72,1]+"/"+aCodFol[343,1]+"/"+aCodFol[345,1]+"/"+aCodFol[636,1]+"/"+aCodFol[75,1]+"/"+aCodFol[82,1]+"/"+aCodFol[639,1]+"/"+aCodFol[640,1]+"/"+aCodFol[1308,1]+"/"+aCodFol[1310,1]+"/"+aCodFol[1296,1]+"/"+aCodFol[1298,1]+"/"+aCodFol[1300,1]+"/"+aCodFol[1302,1]+"/"+aCodFol[1304,1]+"/"+aCodFol[1306,1]+"/"+aCodFol[80,1]+"/"
                    nVFerias        += SRR->RR_VALOR
                    cCCFer          := SRR->RR_CC
                    cSeqFer         := SRR->RR_SEQ
                    nValBase        := SRR->RR_VALORBA
                ElseIf SRR->RR_PD $ aCodFol[73,1]+"/"+aCodFol[344,1]+"/"+aCodFol[346,1]+"/"+aCodFol[637,1]+"/"+aCodFol[76,1]+"/"+aCodFol[83,1]+"/"+aCodFol[1405,1]+"/"+aCodFol[1406,1]+"/"+aCodFol[1309,1]+"/"+aCodFol[1311,1]+"/"+aCodFol[1297,1]+"/"+aCodFol[1299,1]+"/"+aCodFol[1301,1]+"/"+aCodFol[1303,1]+"/"+aCodFol[1305,1]+"/"+aCodFol[1307,1]+"/"+aCodFol[81,1]+"/"
                    nVFeriasMS      += SRR->RR_VALOR
                    cCCFerMs        := SRR->RR_CC
                    cSeqFerMs       := SRR->RR_SEQ
                ElseIf SRR->RR_PD $ aCodFol[74,1]+"/"+aCodFol[623,1]+"/"+aCodFol[622,1]+"/"+aCodFol[1407,1]+"/"+aCodFol[1408,1]+"/"+aCodFol[1324,1]+"/"+aCodFol[1326,1]+"/"+aCodFol[1312,1]+"/"+aCodFol[1314,1]+"/"+aCodFol[1316,1]+"/"+aCodFol[1318,1]+"/"+aCodFol[1320,1]+"/"+aCodFol[1322,1]+"/"+aCodFol[1330,1]+"/"
                    nValAbono       += SRR->RR_VALOR
                    cCCAbo          := SRR->RR_CC
                    cSeqAbo         := SRR->RR_SEQ
                ElseIf SRR->RR_PD $ aCodFol[205,1]+"/"+aCodFol[634,1]+"/"+aCodFol[633,1]+"/"+aCodFol[1409,1]+"/"+aCodFol[1410,1]+"/"+aCodFol[1325,1]+"/"+aCodFol[1327,1]+"/"+aCodFol[1313,1]+"/"+aCodFol[1315,1]+"/"+aCodFol[1317,1]+"/"+aCodFol[1319,1]+"/"+aCodFol[1321,1]+"/"+aCodFol[1323,1]+"/"+aCodFol[1331,1]+"/"
                    nValAbonoMs     += SRR->RR_VALOR
                    cCCAboMs        := SRR->RR_CC
                    cSeqAboMs       := SRR->RR_SEQ
                EndIf
                SRR->( dbSkip() ) 
            EndDo

            If nVFerias > 0
                lNovo := SRR->( !dbSeek( SRH->RH_FILIAL + SRH->RH_MAT + "F" + dToS(SRH->RH_DATAINI) + cUmTFerM + cCCFer ) )
                //Trava o registro na SRD para edição
                If SRR->( RecLock("SRR", lNovo) )
                    //Se for inclusão, grava todos campos da SRR
                    //Se for alteração, apenas altera o valor do registro
                    If lNovo
                        SRR->RR_FILIAL  := SRH->RH_FILIAL
                        SRR->RR_MAT     := SRH->RH_MAT
                        SRR->RR_PD      := cUmTFerM
                        SRR->RR_TIPO1   := "V"
                        SRR->RR_TIPO2   := "C"
                        SRR->RR_DATA    := SRH->RH_DATAINI
                        SRR->RR_TIPO3   := "F"
                        SRR->RR_PERIODO := SRH->RH_PERIODO
                        SRR->RR_ROTEIR  := "FER"
                        SRR->RR_SEMANA  := SRH->RH_NPAGTO
                        SRR->RR_DATAPAG := SRH->RH_DTRECIB
                        SRR->RR_SEQ     := cSeqFer
                        SRR->RR_PROCES  := SRA->RA_PROCES
                        SRR->RR_CC      := cCCFer                        
                    EndIf
                    SRR->RR_VALORBA := nValBase
                    SRR->RR_VALOR   := Round( nVFerias * 1/3, 2)
                    
                    //Adiciona no log de ocorrências
                    aAdd( aLog[1], "Filial: " + SRH->RH_FILIAL + "  -  Matrícula: " + SRH->RH_MAT + "  -  Verba: " + cUmTFerM + "  -  Valor: R$ " + Transform( Round( nVFerias * 1/3, 2), "@E 99,999,999,999.99" ) )
                    
                    //Libera o registro da SRD
                    SRR->( MsUnlock() )
                EndIf
                lNovo := SRD->( !dbSeek( SRH->RH_FILIAL + SRH->RH_MAT + dToS(SRH->RH_DTRECIB) + cUmTFerM + SRH->RH_NPAGTO + cSeqFer + cCCFer) )
                //Trava o registro na SRD para edição
                If SRD->( RecLock("SRD", lNovo) )
                    //Se for inclusão, grava todos campos da srd
                    //Se for alteração, apenas altera o valor do registro
                    If lNovo
                        SRD->RD_FILIAL  := SRH->RH_FILIAL
                        SRD->RD_MAT     := SRH->RH_MAT
                        SRD->RD_CC      := cCCFer
                        SRD->RD_PD      := cUmTFerM
                        SRD->RD_TIPO1   := "V"
                        SRD->RD_DATARQ  := AnoMes(SRH->RH_DATAINI)
                        SRD->RD_DATPGT  := SRH->RH_DTRECIB
                        SRD->RD_DTREF   := SRH->RH_DTRECIB
                        SRD->RD_SEQ     := cSeqFer
                        SRD->RD_TIPO2   := "K"
                        SRD->RD_MES     := SubStr( SRD->RD_DATARQ, 5, 2 )
                        SRD->RD_STATUS  := "A"
                        SRD->RD_INSS    := "N"
                        SRD->RD_IR      := "N"
                        SRD->RD_FGTS    := "N"
                        SRD->RD_PROCES  := SRA->RA_PROCES
                        SRD->RD_PERIODO := SRH->RH_PERIODO
                        SRD->RD_SEMANA  := SRH->RH_NPAGTO
                        SRD->RD_ROTEIR  := "FOL"
                    EndIf
                    SRD->RD_VALORBA := nValBase
                    SRD->RD_VALOR   := Round( nVFerias * 1/3, 2)
                    
                    //Libera o registro da SRD
                    SRD->( MsUnlock() )
                EndIf
            EndIf
            
            If nVFeriasMS > 0
                lNovo := SRR->( !dbSeek( SRH->RH_FILIAL + SRH->RH_MAT + "F" + dToS(SRH->RH_DATAINI) + cUmTFerMs + cCCFerMs ) )
                //Trava o registro na SRD para edição
                If SRR->( RecLock("SRR", lNovo) )
                    //Se for inclusão, grava todos campos da SRR
                    //Se for alteração, apenas altera o valor do registro
                    If lNovo
                        SRR->RR_FILIAL  := SRH->RH_FILIAL
                        SRR->RR_MAT     := SRH->RH_MAT
                        SRR->RR_PD      := cUmTFerMs
                        SRR->RR_TIPO1   := "V"
                        SRR->RR_TIPO2   := "C"
                        SRR->RR_DATA    := SRH->RH_DATAINI
                        SRR->RR_TIPO3   := "F"
                        SRR->RR_PERIODO := SRH->RH_PERIODO
                        SRR->RR_ROTEIR  := "FER"
                        SRR->RR_SEMANA  := SRH->RH_NPAGTO
                        SRR->RR_DATAPAG := SRH->RH_DTRECIB
                        SRR->RR_SEQ     := cSeqFerMs
                        SRR->RR_PROCES  := SRA->RA_PROCES
                        SRR->RR_CC      := cCCFerMs
                    EndIf
                    SRR->RR_VALORBA := nValBase
                    SRR->RR_VALOR   := Round( nVFeriasMS * 1/3, 2)
                    
                    //Adiciona no log de ocorrências
                    aAdd( aLog[1], "Filial: " + SRH->RH_FILIAL + "  -  Matrícula: " + SRH->RH_MAT + "  -  Verba: " + cUmTFerMs + "  -  Valor: R$ " + Transform( Round( nVFeriasMS * 1/3, 2), "@E 99,999,999,999.99" ) )
                    
                    //Libera o registro da SRD
                    SRR->( MsUnlock() )
                EndIf
                lNovo := SRD->( !dbSeek( SRH->RH_FILIAL + SRH->RH_MAT + dToS(SRH->RH_DTRECIB) + cUmTFerMs + SRH->RH_NPAGTO + cSeqFerMs + cCCFerMs) )
                //Trava o registro na SRD para edição
                If SRD->( RecLock("SRD", lNovo) )
                    //Se for inclusão, grava todos campos da srd
                    //Se for alteração, apenas altera o valor do registro
                    If lNovo
                        SRD->RD_FILIAL  := SRH->RH_FILIAL
                        SRD->RD_MAT     := SRH->RH_MAT
                        SRD->RD_CC      := cCCFerMs
                        SRD->RD_PD      := cUmTFerMs
                        SRD->RD_TIPO1   := "V"
                        SRD->RD_DATARQ  := AnoMes(SRH->RH_DATAINI)
                        SRD->RD_DATPGT  := SRH->RH_DTRECIB
                        SRD->RD_DTREF   := SRH->RH_DTRECIB
                        SRD->RD_SEQ     := cSeqFerMs
                        SRD->RD_TIPO2   := "K"
                        SRD->RD_MES     := SubStr( SRD->RD_DATARQ, 5, 2 )
                        SRD->RD_STATUS  := "A"
                        SRD->RD_INSS    := "N"
                        SRD->RD_IR      := "N"
                        SRD->RD_FGTS    := "N"
                        SRD->RD_PROCES  := SRA->RA_PROCES
                        SRD->RD_PERIODO := SRH->RH_PERIODO
                        SRD->RD_SEMANA  := SRH->RH_NPAGTO
                        SRD->RD_ROTEIR  := "FOL"
                    EndIf
                    SRD->RD_VALORBA := nValBase
                    SRD->RD_VALOR   := Round( nVFeriasMS * 1/3, 2)
                    
                    //Libera o registro da SRD
                    SRD->( MsUnlock() )
                EndIf
            EndIf
            
            If nValAbono > 0
                lNovo := SRR->( !dbSeek( SRH->RH_FILIAL + SRH->RH_MAT + "F" + dToS(SRH->RH_DATAINI) + cUmTAboM + cCCAbo ) )
                //Trava o registro na SRD para edição
                If SRR->( RecLock("SRR", lNovo) )
                    //Se for inclusão, grava todos campos da SRR
                    //Se for alteração, apenas altera o valor do registro
                    If lNovo
                        SRR->RR_FILIAL  := SRH->RH_FILIAL
                        SRR->RR_MAT     := SRH->RH_MAT
                        SRR->RR_PD      := cUmTAboM
                        SRR->RR_TIPO1   := "V"
                        SRR->RR_TIPO2   := "C"
                        SRR->RR_DATA    := SRH->RH_DATAINI
                        SRR->RR_TIPO3   := "F"
                        SRR->RR_PERIODO := SRH->RH_PERIODO
                        SRR->RR_ROTEIR  := "FER"
                        SRR->RR_SEMANA  := SRH->RH_NPAGTO
                        SRR->RR_DATAPAG := SRH->RH_DTRECIB
                        SRR->RR_SEQ     := cSeqAbo
                        SRR->RR_PROCES  := SRA->RA_PROCES
                        SRR->RR_CC      := cCCAbo
                    EndIf
                    SRR->RR_VALORBA := nValBase
                    SRR->RR_VALOR   := Round( nValAbono * 1/3, 2)
                    
                    //Adiciona no log de ocorrências
                    aAdd( aLog[1], "Filial: " + SRH->RH_FILIAL + "  -  Matrícula: " + SRH->RH_MAT + "  -  Verba: " + cUmTAboM + "  -  Valor: R$ " + Transform( Round( nValAbono * 1/3, 2), "@E 99,999,999,999.99" ) )
                    
                    //Libera o registro da SRD
                    SRR->( MsUnlock() )
                EndIf
                lNovo := SRD->( !dbSeek( SRH->RH_FILIAL + SRH->RH_MAT + dToS(SRH->RH_DTRECIB) + cUmTAboM + SRH->RH_NPAGTO + cSeqAbo + cCCAbo) )
                //Trava o registro na SRD para edição
                If SRD->( RecLock("SRD", lNovo) )
                    //Se for inclusão, grava todos campos da srd
                    //Se for alteração, apenas altera o valor do registro
                    If lNovo
                        SRD->RD_FILIAL  := SRH->RH_FILIAL
                        SRD->RD_MAT     := SRH->RH_MAT
                        SRD->RD_CC      := cCCAbo
                        SRD->RD_PD      := cUmTAboM
                        SRD->RD_TIPO1   := "V"
                        SRD->RD_DATARQ  := AnoMes(SRH->RH_DATAINI)
                        SRD->RD_DATPGT  := SRH->RH_DTRECIB
                        SRD->RD_DTREF   := SRH->RH_DTRECIB
                        SRD->RD_SEQ     := cSeqAbo
                        SRD->RD_TIPO2   := "K"
                        SRD->RD_MES     := SubStr( SRD->RD_DATARQ, 5, 2 )
                        SRD->RD_STATUS  := "A"
                        SRD->RD_INSS    := "N"
                        SRD->RD_IR      := "N"
                        SRD->RD_FGTS    := "N"
                        SRD->RD_PROCES  := SRA->RA_PROCES
                        SRD->RD_PERIODO := SRH->RH_PERIODO
                        SRD->RD_SEMANA  := SRH->RH_NPAGTO
                        SRD->RD_ROTEIR  := "FOL"
                    EndIf
                    SRD->RD_VALORBA := nValBase
                    SRD->RD_VALOR   := Round( nValAbono * 1/3, 2)
                    
                    //Libera o registro da SRD
                    SRD->( MsUnlock() )
                EndIf
            EndIf

            If nValAbonoMs > 0
                lNovo := SRR->( !dbSeek( SRH->RH_FILIAL + SRH->RH_MAT + "F" + dToS(SRH->RH_DATAINI) + cUmTAboMs + cCCAboMs ) )
                //Trava o registro na SRD para edição
                If SRR->( RecLock("SRR", lNovo) )
                    //Se for inclusão, grava todos campos da SRR
                    //Se for alteração, apenas altera o valor do registro
                    If lNovo
                        SRR->RR_FILIAL  := SRH->RH_FILIAL
                        SRR->RR_MAT     := SRH->RH_MAT
                        SRR->RR_PD      := cUmTAboMs
                        SRR->RR_TIPO1   := "V"
                        SRR->RR_TIPO2   := "C"
                        SRR->RR_DATA    := SRH->RH_DATAINI
                        SRR->RR_TIPO3   := "F"
                        SRR->RR_PERIODO := SRH->RH_PERIODO
                        SRR->RR_ROTEIR  := "FER"
                        SRR->RR_SEMANA  := SRH->RH_NPAGTO
                        SRR->RR_DATAPAG := SRH->RH_DTRECIB
                        SRR->RR_SEQ     := cSeqAboMs
                        SRR->RR_PROCES  := SRA->RA_PROCES
                        SRR->RR_CC      := cCCAboMs
                    EndIf
                    SRR->RR_VALORBA := nValBase
                    SRR->RR_VALOR   := Round( nValAbonoMs * 1/3, 2)
                    
                    //Adiciona no log de ocorrências
                    aAdd( aLog[1], "Filial: " + SRH->RH_FILIAL + "  -  Matrícula: " + SRH->RH_MAT + "  -  Verba: " + cUmTAboMs + "  -  Valor: R$ " + Transform( Round( nValAbonoMs * 1/3, 2), "@E 99,999,999,999.99" ) )

                    //Libera o registro da SRD
                    SRR->( MsUnlock() )
                EndIf
                lNovo := SRD->( !dbSeek( SRH->RH_FILIAL + SRH->RH_MAT + dToS(SRH->RH_DTRECIB) + cUmTAboMs + SRH->RH_NPAGTO + cSeqAboMs + cCCAboMs) )
                //Trava o registro na SRD para edição
                If SRD->( RecLock("SRD", lNovo) )
                    //Se for inclusão, grava todos campos da srd
                    //Se for alteração, apenas altera o valor do registro
                    If lNovo
                        SRD->RD_FILIAL  := SRH->RH_FILIAL
                        SRD->RD_MAT     := SRH->RH_MAT
                        SRD->RD_CC      := cCCAboMs
                        SRD->RD_PD      := cUmTAboMs
                        SRD->RD_TIPO1   := "V"
                        SRD->RD_DATARQ  := AnoMes(SRH->RH_DATAINI)
                        SRD->RD_DATPGT  := SRH->RH_DTRECIB
                        SRD->RD_DTREF   := SRH->RH_DTRECIB
                        SRD->RD_SEQ     := cSeqAboMs
                        SRD->RD_TIPO2   := "K"
                        SRD->RD_MES     := SubStr( SRD->RD_DATARQ, 5, 2 )
                        SRD->RD_STATUS  := "A"
                        SRD->RD_INSS    := "N"
                        SRD->RD_IR      := "N"
                        SRD->RD_FGTS    := "N"
                        SRD->RD_PROCES  := SRA->RA_PROCES
                        SRD->RD_PERIODO := SRH->RH_PERIODO
                        SRD->RD_SEMANA  := SRH->RH_NPAGTO
                        SRD->RD_ROTEIR  := "FOL"
                    EndIf
                    SRD->RD_VALORBA := nValBase
                    SRD->RD_VALOR   := Round( nValAbonoMs * 1/3, 2)
                    
                    //Libera o registro da SRD
                    SRD->( MsUnlock() )
                EndIf
            EndIf

            //Pula para o próximo registro
            (cAliasQry)->( dbSkip() )
        EndDo

        //Fecha a tabela temporária da query
        (cAliasQry)->( dbCloseArea() )
    Else
        MsgInfo("Prencha o período inicial de busca e a verba de base de 1/3.")
    EndIf
Else
    MsgInfo("Realize o backup e execute a rotina novamente.")
EndIf

Return
