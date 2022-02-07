#INCLUDE "PROTHEUS.CH"

User Function UPDCODUNIC()

Local aButtons  := {}
Local aDupl     := {}
Local aSays     := {}
Local cMsg      := ""
Local lContinua := .F.
Local nOpcA     := 0

Private aLog    := {}
Private aLog2   := {}
Private aTitle  := {}
Private aTitle2 := {}

aAdd(aSays,OemToAnsi( "Este programa tem como objetivo verificar funcionários que possuem a mesma matrícula" ))
aAdd(aSays,OemToAnsi( "para o eSocial (campo RA_CODUNIC) e que, por esse motivo, não foi possível enviar" ))
aAdd(aSays,OemToAnsi( "evento de admissão." ))
aAdd(aSays,OemToAnsi( "Ao final, será apresentado uma lista dos funcionários com a matrícula duplicada e será" ))
aAdd(aSays,OemToAnsi( "exibido uma pergunta para confirmar a correção nas matrículas."))
aAdd(aSays,OemToAnsi( "Após a correção no cadastro do funcionário, será efetuado integração ao TAF e o"))
aAdd(aSays,OemToAnsi( "evento de admissão ficará pendente para transmissão ao governo."))

aAdd(aButtons, { 1,.T.,{|o| nOpcA := 1,IF(gpconfOK(), FechaBatch(), nOpcA := 0 ) }} )
aAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )

//Abre a tela de processamento
FormBatch( "Verificação matrícula eSocial", aSays, aButtons )

//Efetua o processamento de geração
If nOpcA == 1
    Aadd( aTitle, OemToAnsi( "Funcionários que possuem matrícula duplicada:" ) )
    Aadd( aLog, {} )
    ProcGpe( {|lEnd| fVerifica(@aDupl)},,,.T. )
    If Empty(aDupl)
        MsgInfo( "Não foi encontrado funcionários com matrícula duplicada." )
    Else
        fMakeLog(aLog,aTitle,,,"UPDCODUNIC_VERIFICACAO",OemToAnsi("Log de Ocorrências"),"M","P",,.F.)
        IF MsgYesNo( "Deseja efetuar correção na matrícula dos funcionários?" )
            Aadd( aTitle2, OemToAnsi( "Funcionários que tiveram matrícula corrigida:" ) )
            Aadd( aLog2, {} )
            Aadd( aTitle2, OemToAnsi( "Trabalhadores que precisam ser excluídos no TAF:" ) )
            Aadd( aLog2, {} )
            ProcGpe( {|lEnd| fCorrige(aDupl)},,,.T. )
            MsgInfo( "É necessário acessar o módulo TAF, acessar a rotina Cadastro Trabalhador (Atualizações / Eventos Esocial / Trabalhador) e efetuar a exclusão manual dos trabalhadores exibidos no log a seguir!" )
            fMakeLog(aLog2,aTitle2,,,"UPDCODUNIC_CORRECAO",OemToAnsi("Log de Ocorrências"),"M","P",,.F.)
        EndIf
    EndIf
EndIf

Return

/*/{Protheus.doc} fVerifica
Função que verifica os funcionários que possuem matrícula duplicada
/*/
Static Function fVerifica( aDupl )

Local aCPF          := {}
Local aMatricDup    := {}
Local cAliasQry     := GetNextAlias()
Local cCateg        := fSqlIn( StrTran(fCatTrabEFD("TCV"), "|" , ""), 3 )//"101|102|103|104|105|106|111|301|302|303|306|307|309|"
Local cUltCPF       := ""
Local cWhere        := ""
Local nCont         := 0
Local nTamanho      := TamSx3("RA_CODUNIC")[1]

cWhere += "RA_CODUNIC != '" + Space(nTamanho) + "' AND "
cWhere += "RA_CATEFD IN (" + cCateg + ") AND "
cWhere += "D_E_L_E_T_ = ' ' "
cWhere += "GROUP BY RA_CODUNIC HAVING COUNT(*) > 1"

//Prepara a variável para uso no BeginSql
cWhere := "%" + cWhere + "%"

//Processa a query e cria a tabela temporária com os resultados
BeginSql alias cAliasQry
	SELECT RA_CODUNIC
    FROM %table:SRA% SRA
	WHERE %exp:cWhere%
EndSql 

SRA->( dbSetOrder( RetOrdem("SRA", "RA_CODUNIC+RA_FILIAL") ) )

While (cAliasQry)->( !EoF() )    
    aCPF := {}
    //Posiciona na tabela SRA
    If SRA->( dbSeek( (cAliasQry)->RA_CODUNIC ) )
        While SRA->( !EoF() .And. SRA->RA_CODUNIC == (cAliasQry)->RA_CODUNIC )
            If aScan( aCPF, { |x| x[2] == SRA->RA_CIC } ) == 0
                aAdd( aCPF, { SRA->RA_CODUNIC, SRA->RA_CIC, SRA->RA_FILIAL, SRA->RA_MAT, SRA->(Recno()) } )
            EndIf
            SRA->( dbSkip() )
        EndDo
    EndIf

    If Len(aCPF) > 1
        For nCont := 1 To Len(aCPF)
            //Adiciona no log de ocorrências
            aAdd( aLog[1], "RA_CODUNIC: " + aCPF[nCont, 1] + " |  Filial: " + aCPF[nCont, 3] + "  -  Matrícula: " + aCPF[nCont, 4] + " -  CPF: " + aCPF[nCont, 2] )
        Next nCont
        aAdd( aDupl, aClone(aCPF) )
    EndIf
   
    //Pula para o próximo registro
    (cAliasQry)->( dbSkip() )
EndDo

//Fecha a tabela temporária da query
(cAliasQry)->( dbCloseArea() )

Return

/*/{Protheus.doc} fCorrige
Função que ajusta a matrícula do funcionário
/*/
Static Function fCorrige( aDupl )

Local aErros        := {}
Local cCodUnic      := ""
Local cC9VFil       := ""
Local cC9VId        := ""
Local cBkpFil       := cFilAnt
Local cUltCodUni    := ""
Local cVersEnvio    := ""
Local cVersGPE      := ""
Local lIntegra      := .F.
Local lRet          := .F.
Local nCont         := 0
Local nContRA       := 0

For nCont := 1 To Len(aDupl)
    For nContRA := 1 To Len(aDupl[nCont])
        //Posiciona na filial do funcionário
        cFilAnt := aDupl[nCont, nContRA, 3]
        //Se status no TAF for diferente de 4
        If TAFGetStat( "S-2200", aDupl[nCont, nContRA, 2] + ";" + aDupl[nCont, nContRA, 1] ) != "4"
            cC9VFil := C9V->C9V_FILIAL
            cC9VId  := C9V->C9V_ID
            //Posiciona no registro físico da tabela SRA
            SRA->( dbGoTo(aDupl[nCont, nContRA, 5]) )
            //Carrega o conteúdo da tabela para a memória 
            RegToMemory("SRA",,,.F.)  
            //Gera nova matricula
            cCodUnic  := fRACodUnic()
            //Verifica versão do layout
            lIntegra := Iif( FindFunction("fVersEsoc"), fVersEsoc( "S2200", .T., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio,@cVersGPE ), .T.)
            //Integra novo trabalhador ao TAF
            If lIntegra
                lRet := fIntAdmiss("SRA", Nil, Nil, "S2200", Nil, Nil, cCodUnic, Nil, "ADM", @aErros, cVersEnvio)
            EndIf 
            //Adiciona o funcionário no log de processamento
            If lRet        
                //Adiciona no log de ocorrências
                aAdd( aLog2[1], "- Filial: " + SRA->RA_FILIAL + " - Matrícula: " + SRA->RA_MAT + " - RA_CODUNIC antigo: " + SRA->RA_CODUNIC + "  -  novo: " + cCodUnic )
                aAdd( aLog2[2], "- Filial: " + cC9VFil + "  -  ID: " + cC9VId )
                //Trava o registro na SRA para edição
                If SRA->( RecLock("SRA", .F.) )  
                    SRA->RA_CODUNIC := cCodUnic
                    //Libera o registro da SRA
                    SRA->( MsUnlock() )
                EndIf
            Else
                //Adiciona no log de ocorrências
                aAdd( aLog2[1], "- Filial: " + SRA->RA_FILIAL + "  -  Matrícula: " + SRA->RA_MAT )
                aAdd( aLog2[1], "  Erro na integração com o TAF. Matrícula não será corrigida." )
            EndIf
        EndIf
    Next nContRA
Next nCont

cFilAnt := cBkpFil

Return