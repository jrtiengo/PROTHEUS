#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"


/*/{Protheus.doc} MARS020
Função chamada pelo Schedule
@type function
@version 1.12.25
@author Jorge Alberto - Solutio
@since 27/05/2020
/*/
User Function MARS020(aParam)

    RPCSetType( 3 ) //Nao consome licensa de uso

    PREPARE ENVIRONMENT EMPRESA aParam[01] FILIAL aParam[02] MODULO 'PCP' TABLES 'SC2', 'SH6', 'SSPEXPORTPROD'
        Conout('MARS020 - Início')
        U_MARS020Proc( .F. )
        Conout('MARS020 - Fim')
    RESET ENVIRONMENT

Return()


/*/{Protheus.doc} MARS025
Função chamada via menu do usuário
@type function
@version 1.12.25
@author Jorge Alberto - Solutio
@since 27/05/2020
/*/
User Function MARS025()

    If MSGYESNO( "Confirma consulta na tabela de Integração Senai ?", "Integração Marcher x Senai" )

        U_MARS020Proc( .T. )
    
    EndIf

Return


/*/{Protheus.doc} MARS020Proc
Rotina que irá consultar os registros na tabela SSPExportProd e irá gravar os Apontamentos de Produção da OP informada.
@type function
@version 1.12.25
@author Jorge Alberto - Solutio
@since 27/05/2020
@param lManual, logical, .T. quando é chamada via Menu, e .F. quando é chamada via Scheduler.
/*/
User Function MARS020Proc( lManual )

    Local aMsg       := {}
    Local _aVetor    := {}
    Local aAreaSC2   := {}
    Local dDate      := Date()
    Local nStatus    := 0
    Local nlin       := 0
    Local nTmH6Prod  := TamSX3("H6_PRODUTO")[1]
    Local nTmH6Oper  := TamSX3("H6_OPERAC")[1]
    Local cHoraIni   := ""
    Local cHoraFim   := ""
    Local cQuery     := ""
    Local cMsg       := ""
    Local cFilSC2    := xFilial("SC2")
    Local cFilSH6    := xFilial("SH6")
    Local cLocal     := SuperGetMV("ES_LCAPAUT",,"02")
    Local cApPend    := "2" // SuperGetMV("MV_APTPEND",.F.,"1")
    Local cAliReg    := GetNextAlias()
    Local cOPDebug   := ""
    Local lDebug     := .F.
    Local lTrfSld    := SuperGetMV("ES_TRFSLD",,.T.)
    Local cRecTransf := SuperGetMV("ES_RECTRF",,"000004")

    Private cTitAlert := "Integração Marcher x Senai"
    Private cTM       := SuperGetMV("ES_TMOPEXT",,"555") // Tipo de Movimento ( TM ) de Apontamento de OP Externa.
    Private nTmD4COD  := TamSX3("D4_COD")[1]
    Private nTmD4OP   := TamSX3("D4_OP")[1]
    Private lMsHelpAuto := .T.
    Private lMsErroAuto := .F.

    Pergunte("MTA680",.F.)
    MV_PAR01 := 2 // 1 = Mostra Lançamento Contábil e 2 = Não mostra
    MV_PAR03 := 2 // 1 = Hora Normal e 2 = Hora Centesimal
    MV_PAR04 := 1 // 1 = Permite que seja apontado somente o Tempo, sem quantidade e 2 = Não
    MV_PAR07 := 3 // 1 = Produção+Perda, 2 = Produção-Perda e 3 = Não verifica o Saldo de Operações anteriores

    DbSelectArea("SC2")
    DbSetOrder(1)

    DbSelectArea("SH6")
    DbSetOrder(1) // H6_FILIAL + H6_OP + H6_PRODUTO + H6_OPERAC + H6_SEQ + DTOS(H6_DATAINI) + H6_HORAINI + DTOS(H6_DATAFIN) + H6_HORAFIN

    // Pega tudo que não foi processado !
    cQuery += "SELECT OP, OPER, CODPECA, MAQ, QUANT, REJ, DATAINI, RTRIM(CONVERT( VARCHAR(5), HORAINI )) AS HORAINI, DATAFIM, RTRIM(CONVERT( VARCHAR(5), HORAFIM )) AS HORAFIM, SSPExportProdID "
    cQuery +=   "FROM SSPEXPORTPROD "
    If lDebug // lDebug := .T.   cOPDebug := "16559301001"
        cQuery +=  "WHERE OP = '" + cOPDebug + "' "
    Else
        cQuery +=  "WHERE STATUS = 0 AND RETORNO = 0 "
    EndIf
    cQuery +=  "ORDER BY OP, OPER "
    
    DbUseArea( .T., 'TOPCONN', TCGenQry(,,cQuery), cAliReg, .F., .T. )
    TcSetField( (cAliReg), "QUANT"  , "N", 10, 0 )
    TcSetField( (cAliReg), "REJ"    , "N", 10, 0 )
    TcSetField( (cAliReg), "DATAINI", "D", 08, 0 )
    TcSetField( (cAliReg), "DATAFIM", "D", 08, 0 )
    
    While (cAliReg)->( !EOF() )

        cMsg := ""

        If SC2->( DbSeek( cFilSC2 + AllTrim( (cAliReg)->OP ) ) )

            // OP Encerrada Totalmente.
            If ( !Empty( SC2->C2_DATRF ) .And. SC2->C2_QUJE >= SC2->C2_QUANT )
                
                cMsg := "OP " + AllTrim( (cAliReg)->OP ) + " está Encerrada Totalmente no Protheus."
            
                If lManual 
                    MSGALERT( cMsg, cTitAlert )
                EndIf

                // Marca que o registro foi processado
                nStatus := TCSqlExec("UPDATE SSPEXPORTPROD " +;
                                        "SET RETORNO = 1 " +;
                                          ", REPDATE = '" + DtoS( dDate )+ "' " +;
                                          ", ERRO = '" + cMsg + "' " +;
                                      "WHERE SSPExportProdID = " + cValToChar( (cAliReg)->SSPExportProdID ) )
    
                If nStatus < 0
                    IIF( lManual,;
                                MSGALERT( "TCSQLError() " + TCSQLError(), cTitAlert ),;
                                conout( "MARS020 - "+cTitAlert+": "+cMsg + CRLF + "TCSQLError() " + TCSQLError() ) )
                EndIf

                // Passa para a próxima OP a ser processada
                (cAliReg)->( DbSkip() )
                Loop
            EndIf

            cHoraIni := (cAliReg)->HORAINI
            cHoraFim := (cAliReg)->HORAFIM

            // Hora de Início e Fim não podem ser iguais para o mesmo dia.
            If( (cAliReg)->DATAINI == (cAliReg)->DATAFIM .And. cHoraIni == cHoraFim )
                cHoraFim := Replace( cValTochar( SomaHoras( cValTochar( cHoraIni ), "00:01" ) ), ".",":" )
                If Len(AllTrim( cHoraFim )) <= 2
                    cHoraFim := PadL( AllTrim(cHoraFim), 2, "0" ) + ":00"
                Else
                    nLin := At( ":", cHoraFim )
                    If nLin > 0 .And. Len( AllTrim(cHoraFim) ) <> 5 // Formato da hora tem que ser "99:99"

                        // Minutos não pode ser superior a 60, por isso tem que verificar se coloca zero a Esquerda ou Direita.
                        If Val(SubStr( cHoraFim, nLin+1 )) < 6
                            cHoraFim := PadL( SubStr( cHoraFim, 1, nLin-1 ), 2, "0" ) + ":" + PadR( SubStr( cHoraFim, nLin+1 ), 2, "0" )
                        Else
                            cHoraFim := PadL( SubStr( cHoraFim, 1, nLin-1 ), 2, "0" ) + ":" + PadL( SubStr( cHoraFim, nLin+1 ), 2, "0" )
                        EndIf
                    EndIf
                EndIf
            EndIf

            If( (cAliReg)->QUANT == 0  .And. (cAliReg)->REJ == 0 )
                
                nStatus := TCSqlExec("UPDATE SSPEXPORTPROD " +;
                                        "SET RETORNO = 1 " +;
                                        ", REPDATE = '" + DtoS( dDate )+ "' " +;
                                        ", ERRO = 'A680SEMQTD - O apontamento digitado está sem quantidade produzida e sem quantidade de perda.' " +;
                                        "WHERE SSPExportProdID = " + cValToChar( (cAliReg)->SSPExportProdID ) )
                If nStatus < 0
                    IIF( lManual,;
                                MSGALERT( "TCSQLError() " + TCSQLError(), cTitAlert ),;
                                conout( "MARS020 - "+cTitAlert+": "+cMsg + CRLF + "TCSQLError() " + TCSQLError() ) )
                EndIf
                
                // Passa para a próxima OP a ser processada
                (cAliReg)->( DbSkip() )
                Loop

            EndIf

            // Somente irá fazer a Transferencia para os Recursos conforme o parâmetro
            If lTrfSld .And. AllTrim( (cAliReg)->MAQ ) $ cRecTransf

                // Se já apontou a OP, então não precisa transferir.
                If .NOT. SH6->( DbSeek( cFilSH6 + SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + SC2->C2_ITEMGRD + PadR( AllTrim((cAliReg)->CODPECA), nTmH6Prod ) + PadR( AllTrim((cAliReg)->OPER), nTmH6Oper ) ) )
                    ValidaSaldo( SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + SC2->C2_ITEMGRD, lManual, (cAliReg)->OPER, (cAliReg)->QUANT, SC2->C2_QUANT )
                EndIf
            EndIf

            // TESTE - Os 2 comandos abaixo são só para testes !!
            // (cAliReg)->( DbSkip() )
            // Loop

            // Excluiu os registros de Processamento Pendente para a OP e Operação
            DelProcPend( SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN, (cAliReg)->OPER)

            aAreaSC2 := SC2->( GetArea() )

            _aVetor   := {}

            aAdd( _aVetor, {"H6_FILIAL" , cFilSC2                                       ,NIL})
            aAdd( _aVetor, {"H6_OP"     , SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN   ,NIL})
            aAdd( _aVetor, {"H6_OPERAC" , (cAliReg)->OPER                               ,NIL})
            aAdd( _aVetor, {"H6_PRODUTO", AllTrim( (cAliReg)->CODPECA )                 ,NIL})
            aAdd( _aVetor, {"H6_QTDPROD", (cAliReg)->QUANT                              ,NIL})
            aAdd( _aVetor, {"H6_QTDPERD", (cAliReg)->REJ                                ,NIL})
            aAdd( _aVetor, {"H6_RECURSO", (cAliReg)->MAQ                                ,NIL})
            aAdd( _aVetor, {"H6_DATAINI", (cAliReg)->DATAINI                            ,NIL})
            aAdd( _aVetor, {"H6_HORAINI", cHoraIni                                      ,NIL})
            aAdd( _aVetor, {"H6_DATAFIN", (cAliReg)->DATAFIM                            ,NIL})
            aAdd( _aVetor, {"H6_HORAFIN", cHoraFim                                      ,NIL})
            aAdd( _aVetor, {"H6_DTAPONT", Date()                                        ,NIL})
            aAdd( _aVetor, {"H6_LOCAL"  , cLocal                                        ,NIL})
            aAdd( _aVetor, {"H6_TIPO"   , "P"                                           ,NIL})
            aAdd( _aVetor, {"H6_OBSERVA", "Realizado automaticamente"                   ,NIL})
            // Se der erro, grava os dados para que possam ser Reprocessados pela rotina "Apontamento Pendente (PCPA138)"
            AADD( _aVetor, {"PENDENTE"  , cApPend                                       ,NIL})
            
            lAutoErrNoFile := .T.
            lMsErroAuto    := .F.
            lMSHelpAuto    := .T. // se igua a .T. nao aparecem os Avisos
            aMsg           := {}
            //Inclusão
            MSExecAuto({|x,y| MATA681(x,y)}, _aVetor, 3)

            If lMsErroAuto

                cMsg := ""
                aMsg := GetAutoGRLog()
                For nLin := 1 To Len( aMsg )
                    cMsg += AllTrim( aMsg[nLin] ) + CRLF
                Next

                If lManual
                    MSGALERT( "Erro no apontamento automatico: " + cMsg, cTitAlert )
                Else
                    Conout( "MARS020 - "+cTitAlert + ": " + cMsg )
                EndIf

                nStatus := TCSqlExec("UPDATE SSPEXPORTPROD " +;
                                    "SET RETORNO = 1 " +;
                                    ", REPDATE = '" + DtoS( dDate )+ "' " +;
                                    ", ERRO = '" + Left(cMsg,500) + "' " +;
                                    "WHERE SSPExportProdID = " + cValToChar( (cAliReg)->SSPExportProdID ) )
                If nStatus < 0
                    IIF( lManual,;
                                MSGALERT( "TCSQLError() " + TCSQLError(), cTitAlert ),;
                                conout( "MARS020 - "+cTitAlert+": "+cMsg + CRLF + "TCSQLError() " + TCSQLError() ) )
                EndIf

            Else

                cMsg := "" + CRLF

                // Na OP marca o retorno
                RestArea( aAreaSC2 )
                DbSelectArea("SC2")

                RecLock( "SC2", .F. )
                    SC2->C2_IDATARE := dDate
                    SC2->C2_IHORARE := Time()
                MsUnLock()
                
                // Marca que o registro foi processado
                nStatus := TCSqlExec("UPDATE SSPEXPORTPROD " +;
                                        "SET STATUS = 1 " +;
                                        ", REPDATE = '" + DtoS( dDate )+ "' " +;
                                    "WHERE SSPExportProdID = " + cValToChar( (cAliReg)->SSPExportProdID ) )
    
                If nStatus < 0
                    IIF( lManual,;
                                MSGALERT( "TCSQLError() " + TCSQLError(), cTitAlert ),;
                                conout( "MARS020 - "+cTitAlert+": "+cMsg + CRLF + "TCSQLError() " + TCSQLError() ) )
                EndIf

            EndIf
            
        Else
            
            cMsg := "OP " + AllTrim( (cAliReg)->OP ) + " não foi localizada no Protheus."
            
            If lManual 
                MSGALERT( cMsg, cTitAlert )
            EndIf

            // Marca que o registro deve ser Reprocessado pelo Senai
            nStatus := TCSqlExec("UPDATE SSPEXPORTPROD " +;
                                    "SET RETORNO = 1 " +;
                                      ", REPDATE = '" + DtoS( dDate )+ "' " +;
                                      ", ERRO = '" + cMsg + "' " +;
                                  "WHERE SSPExportProdID = " + cValToChar( (cAliReg)->SSPExportProdID ) )
   
            If nStatus < 0
                IIF( lManual,;
                            MSGALERT( "TCSQLError() " + TCSQLError(), cTitAlert ),;
                            conout( "MARS020 - "+cTitAlert+": "+cMsg + CRLF + "TCSQLError() " + TCSQLError() ) )
            EndIf

        EndIf

        (cAliReg)->( DbSkip() )
    EndDo

    (cAliReg)->( DbCloseArea() )

Return


/*/{Protheus.doc} DelProcPend
Excluiu os registros de Processamento Pendente (PCPA138) para a OP e Operação.
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 26/08/2021
@param cOP, character, Código da OP
@param cOperac, character, Operação
/*/
Static Function DelProcPend( cOP, cOperac )

    Local cQuery    := ""
    Local cAliReg   := GetNextAlias()

    cQuery += "SELECT R_E_C_N_O_ RECT4K "
    cQuery +=   "FROM "+ RetSqlName("T4K") + " "
    cQuery +=  "WHERE D_E_L_E_T_ = ' ' "
    cQuery +=    "AND T4K_FILIAL = '" + xFilial("T4K") + "' "
    cQuery +=    "AND T4K_OP = '" + cOP + "' "
    cQuery +=    "AND T4K_OPERAC = '" + cOperac + "' "
    
    DbUseArea( .T., 'TOPCONN', TCGenQry(,,cQuery), cAliReg, .F., .T. )
    
    DbSelectArea("T4K")

    While (cAliReg)->( !EOF() )
        
        T4K->( DbGoTo( (cAliReg)->RECT4K ) )

        Reclock("T4K",.F.)
            T4K->(dbDelete())
        T4K->(MsUnLock())

        (cAliReg)->( DbSkip() )
    EndDo
    (cAliReg)->( DbCloseArea() )
Return


/*/{Protheus.doc} ValidaSaldo
Valida o saldo e se for necessário faz a transferência de saldo do 01 para o 02.
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 26/08/2021
@param cOP, character, Código da OP
@param lManual, logical, Execução manual ou via scheduler
@param cOper, character, Código da Operação ( conforme estrutura )
@param nQtApont, numeric, Quantidade que está sendo Apontada
@param nQtOP, numeric, Quantidade da OP
/*/
Static Function ValidaSaldo( cOP, lManual, cOper, nQtApont, nQTOP )

    Local cLocal01 := "01"
    Local cDoc     := ""
    Local cObs     := "Oper " + AllTrim( cOper ) + " OP " + cOP
    Local cMsg     := ""
    Local cFilSD4  := ""
    Local nQtdEst  := 0
    Local nQtProp  := 0
    Local nLin     := 0
    Local aCab     := {}
    Local aItem    := {}
    Local aMsg     := {}

    DbSelectArea("SB1")
    DbSetOrder(1) // B1_FILIAL + B1_COD

    DbSelectArea("SB2")
    DbSetOrder(1) // B2_FILIAL + B2_COD + B2_LOCAL

    DbSelectArea("SD4")
    DbSetOrder(2) // D4_FILIAL + D4_OP + D4_COD
    cFilSD4 := xFilial("SD4")

    SD4->( DbSeek( cFilSD4 + cOP ) )

    While SD4->( .NOT. EOF() ) .And. D4_FILIAL + D4_OP == cFilSD4 + cOP
        
        SB1->( DbSeek( xFilial("SB1") + SD4->D4_COD ) )

        If( "MOD" $ SD4->D4_COD .Or. SB1->B1_FANTASM == 'S' )
            SD4->( DbSkip() )
            Loop
        EndIf
        
        If SB2->( DbSeek( xFilial("SB2") + SD4->D4_COD + cLocal01 ) )

            nQtdEst := SaldoSB2()
            
            // Quantidade Proporcional do Empenho em relação a OP
            nQtProp := nQtApont / nQTOP
            nQtProp := Int( Round( (SD4->D4_QUANT * nQtProp), 0 ) )

            // Se tem saldo então carrega o array para realizar a transferência
            If( nQtProp <= nQtdEst .And. nQtProp > 0 .And. nQtdEst > 0 )

                aAdd( aItem , { {"D3_COD"    , SD4->D4_COD, NIL},;
                                {"D3_UM"     , SB1->B1_UM , NIL},;
                                {"D3_QUANT"  , nQtProp    , NIL},;
                                {"D3_LOCAL"  , cLocal01   , NIL},;
                                {"D3_OBSERVA", cObs       , NIL}})

            EndIf
        EndIf

        SD4->( DbSkip() )
    EndDo

    If Len( aItem ) > 0

        cDoc := GetSX8Num("SD3", "D3_DOC",,1)

        DBSelectArea("SD3")
        DBSetOrder(2) //D3_FILIAL+D3_DOC+D3_COD
        MsSeek(xFilial("SD3")+cDoc)

        // Se já existe essa numeração, deverá pegar um novo
        While Found()
            ConfirmSx8()
            cDoc := GetSX8Num("SD3", "D3_DOC",,1)
            MsSeek(xFilial("SD3")+cDoc)
        EndDo

        aCab := {   {"D3_TM"     , cTM       , NIL},;
                    {"D3_DOC"    , cDoc      , NIL},;
                    {"D3_EMISSAO", dDataBase , NIL}}

        lAutoErrNoFile := .T.
        lMsErroAuto    := .F.
        lMSHelpAuto    := .T. // se igua a .T. nao aparecem os Avisos
        aMsg := {}

        MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,aItem,3)

        If lMsErroAuto

            cMsg := ""
            aMsg := GetAutoGRLog()
            For nLin := 1 To Len( aMsg )
                cMsg += AllTrim( aMsg[nLin] ) + CRLF
            Next

            If lManual
                MSGALERT( "Erro no apontamento automatico: " + cMsg, cTitAlert )
            Else
                Conout( "MARS020 - "+cTitAlert + " OP: " + cOP + " ExecAuto MATA241: " + cMsg )
            EndIf
        EndIf
    EndIf

Return
