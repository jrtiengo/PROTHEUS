#INCLUDE "PROTHEUS.CH"

User Function UPDBINFER()

Local aButtons  := {}
Local aSays     := {}
Local cMsg      := ""
Local lContinua := .F.
Local nOpcA     := 0
Local aErros	:= {}
Local cMsgHelp	:= ""
Local cLink		:= 'https://tdn.totvs.com/x/uk0wJg'

Private aCodFol := {}
Private aLog    := {}
Private aTitle  := {}
Private cPerg   := "UPDBINRES"

//Carrega o array aCodFol para verificar o cadastro de verbas x Ids de cálculo
Fp_CodFol(@aCodFol, xFilial("SRV", cFilAnt), .F., .F.)

//Verifica se existe o cadastro da verba de Id 1870 e 1871 e se a verba foi preenchida
If Len(aCodFol) >= 1872 .And. Len(aCodFol) >= 1882
	lContinua := (!Empty( aCodFol[1870,1] ) .And. !Empty( aCodFol[1871,1] ) .And. !Empty( aCodFol[1872,1]) .And. !Empty( aCodFol[1882,1]))
EndIf 

//Se não existir cadastro da verba para os Ids 1870, 1871,1872 e 1882 aborta o processamento da rotina
// VERIFICA SE ENCONTROU O GRUPO DE PERGUNTAS
If lContinua  .And. GetRpoRelease() != "12.1.017" .And. !SX1->(DbSeek('UPDBINRES'))
	cMsg :=  + CRLF + OemToAnsi("Não foi encontrado o grupo de perguntas: ") + Alltrim(cPerg)
	
	cMsgHelp := ""
	cMsgHelp += + CRLF + OemToAnsi("Antes de prosseguir será necessário criar o grupo de perguntas. Para isso, siga as instruções contidos no link abaixo:")
	cMsgHelp += + CRLF + cLink + CRLF

	aAdd(aErros, cMsgHelp)
	
	Help(,, 'NOPERGUNT',, cMsg, 1, 0,,,,,, {aErros})
			
	Return()
ElseIf !lContinua
	cMsg := OemToAnsi( "Para executar essa rotina é obrigatório o cadastro da verba (Tipo 4 - Base Desconto), natureza 9989 e Incidências CP 11 do seguinte identificador:" ) + CRLF
	cMsg += OemToAnsi( "1870 - Informativo Base INSS Ferias" ) + CRLF + CRLF
    cMsg += OemToAnsi( "Para executar essa rotina é obrigatório o cadastro da verba (Tipo 3 - Base Provento), natureza 9989 e Incidências CP igual a 31 do seguinte identificador:" ) + CRLF
	cMsg += OemToAnsi( "1871 - Informativo desconto INSS Ferias" ) + CRLF + CRLF
    cMsg += OemToAnsi( "Para executar essa rotina é obrigatório o cadastro da verba (Tipo 4 - Base Desconto), natureza 9989 e Incidências FGTS 11 do seguinte identificador::" ) + CRLF
	cMsg += OemToAnsi( "1872 - Informativo Base FGTS Ferias" )
    cMsg += OemToAnsi( "Para executar essa rotina é obrigatório o cadastro da verba (Tipo 4 - Base Desconto), natureza 9989 e Incidências FGTS 12 do seguinte identificador::" ) + CRLF
	cMsg += OemToAnsi( "1882 - Informativo Base FGTS 13o Salario Ferias" )
	MsgInfo( cMsg )
	Return()
EndIf

//Cria as perguntas no dicionário SX1 para filtro do processamento
If GetRpoRelease() <= "12.1.017"
	fCriaSX1()
EndIf

aAdd(aSays,OemToAnsi( "Este programa tem como objetivo gerar as verbas de Id 1870 - Informativo Base INSS" ))
aAdd(aSays,OemToAnsi( "Ferias, 1871 - Informativo desconto INSS Ferias, 1872 - Informativo Base FGTS Ferias " ))
aAdd(aSays,OemToAnsi( "e 1882 - Informativo Base FGTS 13o Salario Ferias, no movimento de férias (tabela SRR)" ))
aAdd(aSays,OemToAnsi( "para correta geração do evento S-1200 no leiaue S-1.0." ))
aAdd(aSays,OemToAnsi( 'Clique no botão "Abrir" para consultar a documentação no TDN e verificar' ))
aAdd(aSays,OemToAnsi( "os procedimentos necessários para transmitir corretamente o evento ao RET." ))

aAdd(aButtons, { 14,.T.,{|| ShellExecute("open","https://tdn.totvs.com/x/uk0wJg","","",1) } } )
aAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
aAdd(aButtons, { 1,.T.,{|o| nOpcA := 1,IF(gpconfOK(), FechaBatch(), nOpcA := 0 ) }} )
aAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )

//Abre a tela de processamento
FormBatch( "Geração dos Id`s 1870, 1871, 1872 e 1882", aSays, aButtons )

//Efetua o processamento de geração
If nOpcA == 1
    Aadd( aTitle, OemToAnsi( "Funcionários que tiveram as verbas de Id 1870, 1871, 1872 e 1882 geradas:" ) )
    Aadd( aLog, {} )
    ProcGpe( {|lEnd| fProcessa()},,,.T. )
    fMakeLog(aLog,aTitle,,,"UPDBINFER",OemToAnsi("Log de Ocorrências"),"M","P",,.F.)
EndIf

Return

/*/{Protheus.doc} fProcessa
Função que efetua o processamento para a geração dos Id`s 1870 e 1871
/*/
Static Function fProcessa()

Local cAliasQry := GetNextAlias()
Local cFilOld   := cFilAnt
Local cJoinRRRV	:= "% " + FWJoinFilial( "SRR", "SRV" ) + " %"
Local cWhere    := ""
Local nValor1870:= 0
Local nValor1871:= 0
Local nValor1872:= 0
Local cCodFil   := ""
Local cCodMat   := ""
Local dData     := cTod("//")
Local cPer      := ""
Local cSem      := ""
Local dDtPag    := cTod("//")
Local cSeq      := ""
Local dDtRef    := cTod("//")
Local cCenCus   := ""
Local cCodINCCP := ""
Local cCodINCFGT:= ""
Local lNovo1870 := .F.
Local lNovo1871 := .F.
Local lNovo1872 := .F.
Local lProc     := .F.
Local nValor1882:= 0
Local lNovo1882 := .F.

Pergunte( cPerg, .F. )
MakeSqlExpr( cPerg )

//Filial
If !Empty(mv_par01)
    cWhere += mv_par01
EndIf

//Matricula
If !Empty(mv_par02)
	cWhere += Iif(!Empty(cWhere)," AND ","")
	cWhere += mv_par02
EndIf

//Periodo inicial
cWhere += Iif(!Empty(cWhere)," AND ","")
cWhere += "RR_PERIODO >= '" + mv_par03 + "' "

//Periodo final
cWhere += "AND RR_PERIODO <= '" + mv_par04 + "' "

//Roteiro Ferias
cWhere += "AND RR_ROTEIR = 'FER' "

//Prepara a variável para uso no BeginSql
cWhere := "%" + cWhere + "%"

//Processa a query e cria a tabela temporária com os resultados
BeginSql alias cAliasQry
    SELECT SRR.RR_FILIAL, SRR.RR_MAT, SRR.RR_CC, SRR.RR_PERIODO, SRR.RR_SEMANA, SRR.RR_DATA, SRR.RR_DATAPAG, SRR.RR_PD, SRR.RR_DTREF, MIN(SRR.RR_SEQ) AS RR_SEQ, SUM(SRR.RR_VALOR) AS RR_VALOR
    FROM %table:SRR% SRR
    INNER JOIN %table:SRV% SRV
    ON	%exp:cJoinRRRV% AND
        SRV.RV_COD = SRR.RR_PD AND
        SRV.%notDel%
	WHERE %exp:cWhere% AND
        (SRV.RV_INCCP IN ('11','31') OR SRV.RV_INCFGTS IN ('11') OR SRV.RV_INCFGTS IN ('12') ) AND
        SRR.%notDel%
	GROUP BY SRR.RR_FILIAL, SRR.RR_MAT, SRR.RR_CC, SRR.RR_PERIODO, SRR.RR_SEMANA, SRR.RR_DATA, SRR.RR_PD, SRR.RR_DATAPAG, SRR.RR_DTREF
EndSql 

While (cAliasQry)->( !EoF() )

    lProc := .T.

    //Carrega o array aCodFol para verificar o cadastro de verbas x Ids de cálculo
    If xFilial("SRV",(cAliasQry)->RR_FILIAL) != xFilial("SRV",cFilOld)
        cFilOld := (cAliasQry)->RR_FILIAL
        RstaCodFol()
        Fp_CodFol(@aCodFol, xFilial("SRV", (cAliasQry)->RR_FILIAL), .F., .F.)

        //Verifica se existe o cadastro da verba de Id 1870, 1871 e 1872 e se a verba foi preenchida
        If Len(aCodFol) >= 1872 .And. Len(aCodFol) >= 1882
            If (Empty( aCodFol[1870,1] ) .Or. Empty( aCodFol[1871,1] ) .Or. Empty( aCodFol[1872,1]) .Or. Empty( aCodFol[1882,1]))
                 //Adiciona no log de ocorrências
                aAdd( aLog[1], "Cadastre os Id`s 1870, 1871, 1872 e 1882 para a filial '"+ (cAliasQry)->RR_FILIAL + "' para continuar o processamento:")
                Exit
            EndIf
        EndIf
    EndIf

    //Reinicializa variáveis
    If cCodFil + cCodMat + dtos(dDtPag) <> (cAliasQry)->RR_FILIAL + (cAliasQry)->RR_MAT + (cAliasQry)->RR_DATAPAG
        nValor1870  := 0
        nValor1871  := 0
        nValor1872  := 0
        nValor1882  := 0
    EndIf

    cCodFil := (cAliasQry)->RR_FILIAL
    cCodMat := (cAliasQry)->RR_MAT
    dData   := sToD((cAliasQry)->RR_DATA)
    cPer    := (cAliasQry)->RR_PERIODO
    cSem    := (cAliasQry)->RR_SEMANA
    dDtPag  := sToD((cAliasQry)->RR_DATAPAG)
    cSeq    := (cAliasQry)->RR_SEQ
    dDtRef  := sToD((cAliasQry)->RR_DTREF)
    cCenCus := (cAliasQry)->RR_CC

    cCodINCCP 	:= RetValSrv( (cAliasQry)->RR_PD, (cAliasQry)->RR_FILIAL, 'RV_INCCP' )
    cCodINCFGT 	:= RetValSrv( (cAliasQry)->RR_PD, (cAliasQry)->RR_FILIAL, 'RV_INCFGTS' )

    //Identifica os valores de INSS
    If (cAliasQry)->RR_PD <> aCodFol[1870, 1] .And. (cAliasQry)->RR_PD <> aCodFol[1871, 1]
        If cCodINCCP == '11'//Compoe Base de INSS
            nValor1870 += (cAliasQry)->RR_VALOR
        ElseIf cCodINCCP == '31' //Desconto de INSS
            nValor1871 += (cAliasQry)->RR_VALOR
        EndIf
    EndIf

    //Identifica os valores de FGTS
    If (cAliasQry)->RR_PD <> aCodFol[1872, 1] .And. cCodINCFGT == '11'
        nValor1872 += (cAliasQry)->RR_VALOR
    EndIf

    //Identifica os valor de FGTS 13 Salario
    If (cAliasQry)->RR_PD <> aCodFol[1882, 1] .And. cCodINCFGT == '12'
        nValor1882 += (cAliasQry)->RR_VALOR
    EndIf

    //Ordena a tabela SRA pela ordem 1 - RA_FILIAL+RA_MAT
    SRA->( dbSetOrder(1) )

    //Posiciona na tabela SRA
    SRA->( dbSeek( (cAliasQry)->RR_FILIAL + (cAliasQry)->RR_MAT ) )
    
    //Ordena a tabela SRR pela ordem 1 - RR_FILIAL+RR_MAT+RR_TIPO3+DTOS(RR_DATA)+RR_PD+RR_CC
    SRR->( dbSetOrder(1) )

    //Verifica se as verbas de Id 1870 existe na tabela SRR
    lNovo1870 := SRR->( !dbSeek( (cAliasQry)->RR_FILIAL + (cAliasQry)->RR_MAT + "F" + (cAliasQry)->RR_DATA + aCodFol[1870, 1] + (cAliasQry)->RR_CC ) )
    
    //Pula para o próximo registro
    (cAliasQry)->( dbSkip() )

    //Grava a verba somente após percorrer todos os registros do funcionário
    If cCodFil + cCodMat + dtos(dDtPag) <> (cAliasQry)->RR_FILIAL + (cAliasQry)->RR_MAT + (cAliasQry)->RR_DATAPAG

        //Grava a verba de Id 1870
        If nValor1870 > 0
            //Trava o registro na SRR para edição
            If SRR->( RecLock("SRR", lNovo1870) )
                //Se for inclusão, grava todos campos da SRR
                //Se for alteração, apenas altera o valor do registro
                If lNovo1870
                    SRR->RR_FILIAL  := cCodFil
                    SRR->RR_MAT     := cCodMat
                    SRR->RR_PD      := aCodFol[1870, 1]
                    SRR->RR_TIPO1   := "V"
                    SRR->RR_TIPO2   := "C"
                    SRR->RR_DATA    := dData
                    SRR->RR_TIPO3   := "F"
                    SRR->RR_PERIODO := cPer
                    SRR->RR_ROTEIR  := "FER"
                    SRR->RR_SEMANA  := cSem
                    SRR->RR_DATAPAG := dDtPag
                    SRR->RR_SEQ     := cSeq
                    SRR->RR_PROCES  := SRA->RA_PROCES
                    SRR->RR_DTREF   := dDtRef
                    SRR->RR_CC      := cCenCus
                EndIf

                SRR->RR_VALOR   := nValor1870
                
                //Adiciona no log de ocorrências
                aAdd( aLog[1], "Filial: " + cCodFil + "  -  Matrícula: " + cCodMat + "  -  Período: " + cPer + "  -  Verba: " + aCodFol[1870, 1] + "  -  Valor: R$ " + Transform( nValor1870, "@E 99,999,999,999.99" ) )

                //Libera o registro da SRR
                SRR->( MsUnlock() )
            EndIf
        EndIf

        //Ordena a tabela SRR pela ordem 1 - RR_FILIAL+RR_MAT+RR_TIPO3+DTOS(RR_DATA)+RR_PD+RR_CC
        SRR->( dbSetOrder(1) )
        lNovo1871 := SRR->( !dbSeek( cCodFil + cCodMat + "F" + DTOS(dData) + aCodFol[1871, 1] + cCenCus ))

        //Grava a verba de Id 1871
        If nValor1871 > 0
            //Trava o registro na SRR para edição
            If SRR->( RecLock("SRR", lNovo1871) )
                //Se for inclusão, grava todos campos da SRR
                //Se for alteração, apenas altera o valor do registro
                If lNovo1871
                    SRR->RR_FILIAL  := cCodFil
                    SRR->RR_MAT     := cCodMat
                    SRR->RR_PD      := aCodFol[1871, 1]
                    SRR->RR_TIPO1   := "V"
                    SRR->RR_TIPO2   := "C"
                    SRR->RR_DATA    := dData
                    SRR->RR_TIPO3   := "F"
                    SRR->RR_PERIODO := cPer
                    SRR->RR_ROTEIR  := "FER"
                    SRR->RR_SEMANA  := cSem
                    SRR->RR_DATAPAG := dDtPag
                    SRR->RR_SEQ     := cSeq
                    SRR->RR_PROCES  := SRA->RA_PROCES
                    SRR->RR_DTREF   := dDtRef
                    SRR->RR_CC      := cCenCus
                EndIf

                SRR->RR_VALOR   := nValor1871
                
                //Adiciona no log de ocorrências
                aAdd( aLog[1], "Filial: " + cCodFil + "  -  Matrícula: " + cCodMat + "  -  Período: " + cPer + "  -  Verba: " + aCodFol[1871, 1] + "  -  Valor: R$ " + Transform( nValor1871, "@E 99,999,999,999.99" ) )

                //Libera o registro da SRR
                SRR->( MsUnlock() )
            EndIf
        EndIf

        //Ordena a tabela SRR pela ordem 1 - RR_FILIAL+RR_MAT+RR_TIPO3+DTOS(RR_DATA)+RR_PD+RR_CC
        SRR->( dbSetOrder(1) )
        lNovo1872 := SRR->( !dbSeek( cCodFil + cCodMat + "F" + DTOS(dData) + aCodFol[1872, 1] + cCenCus ))

        //Grava a verba de Id 1872
        If nValor1872 > 0
            //Trava o registro na SRR para edição
            If SRR->( RecLock("SRR", lNovo1872) )
                //Se for inclusão, grava todos campos da SRR
                //Se for alteração, apenas altera o valor do registro
                If lNovo1872
                    SRR->RR_FILIAL  := cCodFil
                    SRR->RR_MAT     := cCodMat
                    SRR->RR_PD      := aCodFol[1872, 1]
                    SRR->RR_TIPO1   := "V"
                    SRR->RR_TIPO2   := "C"
                    SRR->RR_DATA    := dData
                    SRR->RR_TIPO3   := "F"
                    SRR->RR_PERIODO := cPer
                    SRR->RR_ROTEIR  := "FER"
                    SRR->RR_SEMANA  := cSem
                    SRR->RR_DATAPAG := dDtPag
                    SRR->RR_SEQ     := cSeq
                    SRR->RR_PROCES  := SRA->RA_PROCES
                    SRR->RR_DTREF   := dDtRef
                    SRR->RR_CC      := cCenCus
                EndIf

                SRR->RR_VALOR   := nValor1872
                
                //Adiciona no log de ocorrências
                aAdd( aLog[1], "Filial: " + cCodFil + "  -  Matrícula: " + cCodMat + "  -  Período: " + cPer + "  -  Verba: " + aCodFol[1872, 1] + "  -  Valor: R$ " + Transform( nValor1872, "@E 99,999,999,999.99" ) )

                //Libera o registro da SRR
                SRR->( MsUnlock() )
            EndIf
        EndIf

        //Ordena a tabela SRR pela ordem 1 - RR_FILIAL+RR_MAT+RR_TIPO3+DTOS(RR_DATA)+RR_PD+RR_CC
        lNovo1882 := SRR->( !dbSeek( cCodFil + cCodMat + "F" + DTOS(dData) + aCodFol[1882, 1] + cCenCus ))

        //Grava a verba de Id 1871
        If nValor1882 > 0
            //Trava o registro na SRR para edição
            If SRR->( RecLock("SRR", lNovo1882) )
                //Se for inclusão, grava todos campos da SRR
                //Se for alteração, apenas altera o valor do registro
                If lNovo1882
                    SRR->RR_FILIAL  := cCodFil
                    SRR->RR_MAT     := cCodMat
                    SRR->RR_PD      := aCodFol[1882, 1]
                    SRR->RR_TIPO1   := "V"
                    SRR->RR_TIPO2   := "C"
                    SRR->RR_DATA    := dData
                    SRR->RR_TIPO3   := "F"
                    SRR->RR_PERIODO := cPer
                    SRR->RR_ROTEIR  := "FER"
                    SRR->RR_SEMANA  := cSem
                    SRR->RR_DATAPAG := dDtPag
                    SRR->RR_SEQ     := cSeq
                    SRR->RR_PROCES  := SRA->RA_PROCES
                    SRR->RR_DTREF   := dDtRef
                    SRR->RR_CC      := cCenCus
                EndIf

                SRR->RR_VALOR   := nValor1882
                
                //Adiciona no log de ocorrências
                aAdd( aLog[1], "Filial: " + cCodFil + "  -  Matrícula: " + cCodMat + "  -  Período: " + cPer + "  -  Verba: " + aCodFol[1882, 1] + "  -  Valor: R$ " + Transform( nValor1882, "@E 99,999,999,999.99" ) )

                //Libera o registro da SRR
                SRR->( MsUnlock() )
            EndIf
        EndIf
    EndIf
EndDo

//Fecha a tabela temporária da query
(cAliasQry)->( dbCloseArea() )

If !lProc
    aAdd( aLog[1], "Não foram encontrados registros para processamento.")
EndIf

Return

/*/{Protheus.doc} fCriaSX1
Função que cria as perguntas que serão utilizdas na rotina
/*/
Static Function fCriaSX1()

Local aHelpPor := {}

AAdd( aHelpPor, "Informe o período inicial para a" )
AAdd( aHelpPor, "geração da verba de base." )
EngHLP117( "P"+".UPDBRES03.", aHelpPor, aHelpPor, aHelpPor )

aHelpPor := {}
AAdd( aHelpPor, "Informe o período final para a" )
AAdd( aHelpPor, "geração da verba de base." )
EngHLP117( "P"+".UPDBRES04.", aHelpPor, aHelpPor, aHelpPor )

//			<cGrupo>	, <cOrdem>	, <cPergunt>				, <cPerSpa>	, <cPerEng>		, <cVar>	,<cTipo>	,<nTamanho>	,<nDecimal>		, <nPresel>		,<cGSC>	,<cValid>							,<cF3>		,<cGrpSxg>	,<cPyme>	,<cVar01>			,<cDef01> 		,<cDefSpa1>		,<cDefEng1>		,<cCnt01>		,<cDef02>				,<cDefSpa2>				,<cDefEng2>			,<cDef03>	, <cDefSpa3>	,<cDefEng3>		, <cDef04>	,<cDefSpa4>		, <cDefEng4>	,<cDef05>		, <cDefSpa5>	, <cDefEng5>	, <aHelpPor>, <aHelpEng>	, <aHelpSpa>	, <cHelp> )
EngSX1117( cPerg 	    , "01" 		,"Filial ?"			 		, ""		, ""		 	, "MV_CH1" 	, "C" 		, 99		,0				, 0	   			, "R" 	, ""								, "XM0" 	, ""		, "S" 		, "MV_PAR01" 		, "" 	   		, "" 			, "" 			, "RR_FILIAL"	, "" 					, ""					, "" 	 			, "" 		, "" 			, "" 			, "" 		, ""	 		, ""	  	 	, ""			, "" 		 	, ""	  		, {}	   	, {}   			, {} 			, ".RHFILDE."	)
EngSX1117( cPerg 	    , "02" 		,"Matrícula ?"	 			, "" 		, ""			, "MV_CH2"	, "C" 		, 99   		,0	  			, 0	  	 		, "R" 	, ""								, "SRA" 	, "" 		, "S" 		, "MV_PAR02" 		, "" 	  		, "" 			, "" 			, "RR_MAT"		, "" 					, ""					, "" 	 			, "" 		, "" 			, "" 			, "" 	 	, ""	  		, ""	   		, ""		  	, "" 		 	, ""	  		, {}	   	, {} 			, {} 			, ".RHMATD."	)
EngSX1117( cPerg 	    , "03"		,"Período inicial? (AAAAMM)", ""		, ""	        , 'MV_CH3'	, 'C'		, 6			,0				, 0				, 'G'	, 'NaoVazio()'						, ""		, ""		, "S"		, "MV_PAR03"		, "" 	   		, ""			, "" 	   		, ""			, "" 					, "" 					, "" 	 			, ""	  	, ""	   		, ""		  	, "" 		, ""	  		, ""	   		, "" 			, "" 			, ""	  		, {}	   	, {} 			, {} 			, ".UPDBRES03."	)
EngSX1117( cPerg 	    , "04"		,"Período final? (AAAAMM)"	, ""		, ""	        , 'MV_CH4'	, 'C'		, 6			,0				, 0				, 'G'	, 'NaoVazio()'						, ""		, ""		, "S"		, "MV_PAR04"		, "" 			, ""			, "" 	   		, ""			, "" 					, "" 					, "" 	 			, ""	  	, ""	   		, ""		  	, "" 		, ""	  		, ""	   		, "" 			, "" 			, ""	  		, {}	   	, {} 			, {} 			, ".UPDBRES04."	)

Return
