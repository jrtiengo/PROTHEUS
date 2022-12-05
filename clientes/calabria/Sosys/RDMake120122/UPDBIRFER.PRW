#INCLUDE "PROTHEUS.CH"

Static lRefAbono	:= If(SRV->(ColumnPos( 'RV_REFABON' )) > 0, .T., .F.)

User Function UPDBIRFER()

Local aButtons  := {}
Local aSays     := {}
Local cMsg      := ""
Local lContinua := .F.
Local nOpcA     := 0

Private aCodFol := {}
Private aLog    := {}
Private aTitle  := {}
Private cPerg   := "UPDBFER"
Private lTem1723:= .F.

//Carrega o array aCodFol para verificar o cadastro de verbas x Ids de cálculo
Fp_CodFol(@aCodFol, cFilAnt, .F., .F.)

//Verifica se existe o cadastro da verba de Id 1562 e se a verba foi preenchida
If Len(aCodFol) >= 1562
	lContinua := !Empty( aCodFol[1562,1] )
EndIf 

lTem1723 := (Len(aCodFol) >= 1723)    

//Se não existir cadastro da verba para o Id 1562, aborta o processamento da rotina
If !lContinua
	cMsg := OemToAnsi( "Para executar essa rotina é obrigatório o cadastro da verba (Tipo 3 - Base Provento) do seguinte identificador:" ) + CRLF
	cMsg += OemToAnsi( "1562 - Base de IRRF Férias s/ dedução" )
	MsgInfo( cMsg )
	Return()
EndIf

//Cria as perguntas no dicionário SX1 para filtro do processamento
If GetRpoRelease() == "12.1.017"
    fCriaSX1()
    lSX1 := .T.
Else
    If !fVldSX1()
        cMsg := OemToAnsi( "Para executar essa rotina é obrigatório possuir o grupo de perguntas UPDBFER." ) + CRLF
        cMsg += OemToAnsi( "Verifique a documentação no TDN: http://tdn.totvs.com/x/8S1-Fw." )
        MsgInfo( cMsg )
        Return()
    EndIf
EndIf

aAdd(aSays,OemToAnsi( "Este programa tem como objetivo gerar as verbas dos Ids 1562, 1722 e/ou 1723" ))
aAdd(aSays,OemToAnsi( "no movimento acumulado (tabela SRD) dos funcionários de acordo com a verbas" ))
aAdd(aSays,OemToAnsi( "das férias para a geração correta do evento S-1200 do eSocial." ))
aAdd(aSays,OemToAnsi( "Obs.: para a geração das verbas no movimento mensal (tabelas SRC) deverá ser"))
aAdd(aSays,OemToAnsi( "efetuado o recálculo da folha."))

aAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
aAdd(aButtons, { 1,.T.,{|o| nOpcA := 1,IF(gpconfOK(), FechaBatch(), nOpcA := 0 ) }} )
aAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )

//Abre a tela de processamento
FormBatch( "Geração das verbas", aSays, aButtons )

//Efetua o processamento de geração
If nOpcA == 1
    Aadd( aTitle, OemToAnsi( "Funcionários que tiveram verba(s) gerada(s):" ) )
    Aadd( aLog, {} )
    ProcGpe( {|lEnd| fProcessa()},,,.T. )
    fMakeLog(aLog,aTitle,,,"UPDBIRFER",OemToAnsi("Log de Ocorrências"),"M","P",,.F.)
EndIf

Return

/*/{Protheus.doc} fProcessa
Função que efetua o processamento para a geração do Id 1562
/*/
Static Function fProcessa()

Local cAliasQry := GetNextAlias()
Local cFilOld   := cFilAnt
Local cJoinRDRV	:= "% " + FWJoinFilial( "SRD", "SRV" ) + " %"
Local cExpDed   := ""
Local cWhere    := ""
Local cWhere1722:= ""
Local cWhereDed := ""
Local cWhereQRY := ""
Local lNovo     := .F.

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
cWhere += "RD_DATARQ >= '" + mv_par03 + "' "

//Periodo final
cWhere += "AND RD_DATARQ <= '" + mv_par04 + "' "
cWhereDed := cWhere

//Filtro para somente trazer verbas que existam no cálculo de férias (SRH)
cWhere += "AND EXISTS( SELECT SRR.RR_FILIAL, SRR.RR_MAT, SRR.RR_PD FROM " + RetSqlName('SRR') + " SRR WHERE SRR.RR_FILIAL = SRD.RD_FILIAL AND SRR.RR_MAT = SRD.RD_MAT AND SRR.RR_DATAPAG = SRD.RD_DATPGT AND SRR.RR_PD = SRD.RD_PD AND SRR.RR_ROTEIR = 'FER' AND SRR.D_E_L_E_T_ = ' ' )"

//Prepara a variável para uso no BeginSql
cWhereQRY := "%" + cWhere + "%"
cWhereDed := "%" + cWhereDed + "%"

//Processa a query e cria a tabela temporária com os resultados
BeginSql alias cAliasQry
	SELECT SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_CC, SRD.RD_DATARQ, SRD.RD_SEMANA, SRD.RD_DATPGT, MIN(SRD.RD_SEQ) AS RD_SEQ, SUM(SRD.RD_VALOR) AS RD_VALOR
    FROM %table:SRD% SRD
    INNER JOIN %table:SRV% SRV
    ON	%exp:cJoinRDRV% AND
        SRV.RV_COD = SRD.RD_PD AND
        SRV.%notDel%
	WHERE %exp:cWhereQRY% AND
			SRV.RV_TIPOCOD = '1' AND
            SRD.RD_IR = 'S' AND
            SRD.%notDel%
	GROUP BY SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_CC, SRD.RD_DATARQ, SRD.RD_SEMANA, SRD.RD_DATPGT
EndSql 

While (cAliasQry)->( !EoF() )
    //Carrega o array aCodFol para verificar o cadastro de verbas x Ids de cálculo
    If (cAliasQry)->RD_FILIAL != cFilOld
        cFilOld := (cAliasQry)->RD_FILIAL
        RstaCodFol()
        Fp_CodFol(@aCodFol, (cAliasQry)->RD_FILIAL, .F., .F.)  
    EndIf
    
    //Ordena a tabela SRA pela ordem 1 - RA_FILIAL+RA_MAT
    SRA->( dbSetOrder(1) )
    //Posiciona na tabela SRA
    SRA->( dbSeek( (cAliasQry)->RD_FILIAL + (cAliasQry)->RD_MAT ) )
    
    //Ordena a tabela SRD pela ordem 1 - RD_FILIAL+RD_MAT+RD_DATARQ+RD_PD+RD_SEMANA+RD_SEQ+RD_CC
    SRD->( dbSetOrder(1) )
    //Verifica se a verba de Id 1562 já exista na tabela SRD
    lNovo := SRD->( !dbSeek( (cAliasQry)->RD_FILIAL + (cAliasQry)->RD_MAT + (cAliasQry)->RD_DATARQ + aCodFol[1562, 1] + (cAliasQry)->RD_SEMANA + (cAliasQry)->RD_SEQ + (cAliasQry)->RD_CC ) )

    //Trava o registro na SRD para edição
    If SRD->( RecLock("SRD", lNovo) )
        //Se for inclusão, grava todos campos da SRD
        //Se for alteração, apenas altera o valor do registro
        If lNovo
            SRD->RD_FILIAL  := (cAliasQry)->RD_FILIAL
            SRD->RD_MAT     := (cAliasQry)->RD_MAT
            SRD->RD_CC      := (cAliasQry)->RD_CC
            SRD->RD_PD      := aCodFol[1562, 1]
            SRD->RD_TIPO1   := "V"
            SRD->RD_DATARQ  := (cAliasQry)->RD_DATARQ
            SRD->RD_DATPGT  := sToD((cAliasQry)->RD_DATPGT)
            SRD->RD_SEQ     := (cAliasQry)->RD_SEQ
            SRD->RD_TIPO2   := "C"
            SRD->RD_MES     := SubStr( (cAliasQry)->RD_DATARQ, 5, 2 )
            SRD->RD_STATUS  := "A"
            SRD->RD_INSS    := "N"
            SRD->RD_IR      := "N"
            SRD->RD_FGTS    := "N"
            SRD->RD_PROCES  := SRA->RA_PROCES
            SRD->RD_PERIODO := (cAliasQry)->RD_DATARQ
            SRD->RD_SEMANA  := (cAliasQry)->RD_SEMANA
            SRD->RD_ROTEIR  := "FOL"
            SRD->RD_DTREF   := sToD((cAliasQry)->RD_DATPGT)
        EndIf
        SRD->RD_VALOR   := (cAliasQry)->RD_VALOR
        
        //Adiciona no log de ocorrências
        aAdd( aLog[1], "Filial: " + (cAliasQry)->RD_FILIAL + "  -  Matrícula: " + (cAliasQry)->RD_MAT + "  -  Período: " + (cAliasQry)->RD_DATARQ + " - Verba: " + aCodFol[1562, 1] + "  -  Valor: R$ " + cValToChar( Transform( (cAliasQry)->RD_VALOR, "@E 99,999,999,999.99" ) ) )

        //Libera o registro da SRD
        SRD->( MsUnlock() )
    EndIf
    
    //Pula para o próximo registro
    (cAliasQry)->( dbSkip() )
EndDo

//Fecha a tabela temporária da query
(cAliasQry)->( dbCloseArea() )

If lTem1723
    If !Empty(aCodFol[1722, 1])
        cWhere1722 += "SRV.RV_CODFOL IN ('0074','0079','0094','0095','0205','0206','0207','0208','0622','0623','0632','0633','0634','0635','1312','1313','1314','1315','1316','1317','1318','1319','1320','1321','1322','1323','1324','1325','1326','1327','1330','1331','1407','1408','1409','1410','1416','1417','1418','1419','1450','1451')"
        If lRefAbono
            cWhere1722 += " OR SRV.RV_REFABON = '1'"
        EndIf
        cWhere1722 := "%" + cWhere1722 + "%"
        //Processa a query e cria a tabela temporária com os resultados
        BeginSql alias cAliasQry
            SELECT SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_CC, SRD.RD_DATARQ, SRD.RD_SEMANA, SRD.RD_DATPGT, MIN(SRD.RD_SEQ) AS RD_SEQ, SUM(SRD.RD_VALOR) AS RD_VALOR
            FROM %table:SRD% SRD
            INNER JOIN %table:SRV% SRV
            ON	%exp:cJoinRDRV% AND
                SRV.RV_COD = SRD.RD_PD AND
                SRV.%notDel%
            WHERE %exp:cWhereDed% AND
                    SRV.RV_TIPOCOD = '1' AND
                    SRD.RD_IR = 'N' AND 
                    ( %exp:cWhere1722% ) AND
                    SRD.%notDel%
            GROUP BY SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_CC, SRD.RD_DATARQ, SRD.RD_SEMANA, SRD.RD_DATPGT
        EndSql 

        While (cAliasQry)->( !EoF() )
            //Carrega o array aCodFol para verificar o cadastro de verbas x Ids de cálculo
            If (cAliasQry)->RD_FILIAL != cFilOld
                cFilOld := (cAliasQry)->RD_FILIAL
                RstaCodFol()
                Fp_CodFol(@aCodFol, (cAliasQry)->RD_FILIAL, .F., .F.)  
            EndIf
            
            //Ordena a tabela SRA pela ordem 1 - RA_FILIAL+RA_MAT
            SRA->( dbSetOrder(1) )
            //Posiciona na tabela SRA
            SRA->( dbSeek( (cAliasQry)->RD_FILIAL + (cAliasQry)->RD_MAT ) )
            
            //Ordena a tabela SRD pela ordem 1 - RD_FILIAL+RD_MAT+RD_DATARQ+RD_PD+RD_SEMANA+RD_SEQ+RD_CC
            SRD->( dbSetOrder(1) )
            //Verifica se a verba de Id 1562 já exista na tabela SRD
            lNovo := SRD->( !dbSeek( (cAliasQry)->RD_FILIAL + (cAliasQry)->RD_MAT + (cAliasQry)->RD_DATARQ + aCodFol[1722, 1] + (cAliasQry)->RD_SEMANA + (cAliasQry)->RD_SEQ + (cAliasQry)->RD_CC ) )

            //Trava o registro na SRD para edição
            If SRD->( RecLock("SRD", lNovo) )
                //Se for inclusão, grava todos campos da SRD
                //Se for alteração, apenas altera o valor do registro
                If lNovo
                    SRD->RD_FILIAL  := (cAliasQry)->RD_FILIAL
                    SRD->RD_MAT     := (cAliasQry)->RD_MAT
                    SRD->RD_CC      := (cAliasQry)->RD_CC
                    SRD->RD_PD      := aCodFol[1722, 1]
                    SRD->RD_TIPO1   := "V"
                    SRD->RD_DATARQ  := (cAliasQry)->RD_DATARQ
                    SRD->RD_DATPGT  := sToD((cAliasQry)->RD_DATPGT)
                    SRD->RD_SEQ     := (cAliasQry)->RD_SEQ
                    SRD->RD_TIPO2   := "C"
                    SRD->RD_MES     := SubStr( (cAliasQry)->RD_DATARQ, 5, 2 )
                    SRD->RD_STATUS  := "A"
                    SRD->RD_INSS    := "N"
                    SRD->RD_IR      := "N"
                    SRD->RD_FGTS    := "N"
                    SRD->RD_PROCES  := SRA->RA_PROCES
                    SRD->RD_PERIODO := (cAliasQry)->RD_DATARQ
                    SRD->RD_SEMANA  := (cAliasQry)->RD_SEMANA
                    SRD->RD_ROTEIR  := "FOL"
                    SRD->RD_DTREF   := sToD((cAliasQry)->RD_DATPGT)
                EndIf
                SRD->RD_VALOR   := (cAliasQry)->RD_VALOR
                
                //Adiciona no log de ocorrências
                aAdd( aLog[1], "Filial: " + (cAliasQry)->RD_FILIAL + "  -  Matrícula: " + (cAliasQry)->RD_MAT + "  -  Período: " + (cAliasQry)->RD_DATARQ + " - Verba: " + aCodFol[1722, 1] + "  -  Valor: R$ " + cValToChar( Transform( (cAliasQry)->RD_VALOR, "@E 99,999,999,999.99" ) ) )

                //Libera o registro da SRD
                SRD->( MsUnlock() )
            EndIf
            
            //Pula para o próximo registro
            (cAliasQry)->( dbSkip() )
        EndDo

        //Fecha a tabela temporária da query
        (cAliasQry)->( dbCloseArea() )
    EndIf
    If !Empty(aCodFol[1723, 1])
        If RetValSrv( aCodfol[65,1], SRA->RA_FILIAL, "RV_INCIRF" ) == "43"
            cExpDed := "% SRV.RV_CODFOL = '0065' %"
        Else
            cExpDed := "% SRV.RV_CODFOL = '0168' %"
        EndIf        
        //Processa a query e cria a tabela temporária com os resultados
        BeginSql alias cAliasQry
            SELECT SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_CC, SRD.RD_DATARQ, SRD.RD_SEMANA, SRD.RD_DATPGT, MIN(SRD.RD_SEQ) AS RD_SEQ, SUM(SRD.RD_VALOR) AS RD_VALOR
            FROM %table:SRD% SRD
            INNER JOIN %table:SRV% SRV
            ON	%exp:cJoinRDRV% AND
                SRV.RV_COD = SRD.RD_PD AND
                SRV.%notDel%
            WHERE %exp:cWhereDed% AND
                    %exp:cExpDed% AND
                    SRD.%notDel%
            GROUP BY SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_CC, SRD.RD_DATARQ, SRD.RD_SEMANA, SRD.RD_DATPGT
        EndSql 

        While (cAliasQry)->( !EoF() )
            //Carrega o array aCodFol para verificar o cadastro de verbas x Ids de cálculo
            If (cAliasQry)->RD_FILIAL != cFilOld
                cFilOld := (cAliasQry)->RD_FILIAL
                RstaCodFol()
                Fp_CodFol(@aCodFol, (cAliasQry)->RD_FILIAL, .F., .F.)  
            EndIf
            
            //Ordena a tabela SRA pela ordem 1 - RA_FILIAL+RA_MAT
            SRA->( dbSetOrder(1) )
            //Posiciona na tabela SRA
            SRA->( dbSeek( (cAliasQry)->RD_FILIAL + (cAliasQry)->RD_MAT ) )
            
            //Ordena a tabela SRD pela ordem 1 - RD_FILIAL+RD_MAT+RD_DATARQ+RD_PD+RD_SEMANA+RD_SEQ+RD_CC
            SRD->( dbSetOrder(1) )
            //Verifica se a verba de Id 1562 já exista na tabela SRD
            lNovo := SRD->( !dbSeek( (cAliasQry)->RD_FILIAL + (cAliasQry)->RD_MAT + (cAliasQry)->RD_DATARQ + aCodFol[1723, 1] + (cAliasQry)->RD_SEMANA + (cAliasQry)->RD_SEQ + (cAliasQry)->RD_CC ) )

            //Trava o registro na SRD para edição
            If SRD->( RecLock("SRD", lNovo) )
                //Se for inclusão, grava todos campos da SRD
                //Se for alteração, apenas altera o valor do registro
                If lNovo
                    SRD->RD_FILIAL  := (cAliasQry)->RD_FILIAL
                    SRD->RD_MAT     := (cAliasQry)->RD_MAT
                    SRD->RD_CC      := (cAliasQry)->RD_CC
                    SRD->RD_PD      := aCodFol[1723, 1]
                    SRD->RD_TIPO1   := "V"
                    SRD->RD_DATARQ  := (cAliasQry)->RD_DATARQ
                    SRD->RD_DATPGT  := sToD((cAliasQry)->RD_DATPGT)
                    SRD->RD_SEQ     := (cAliasQry)->RD_SEQ
                    SRD->RD_TIPO2   := "C"
                    SRD->RD_MES     := SubStr( (cAliasQry)->RD_DATARQ, 5, 2 )
                    SRD->RD_STATUS  := "A"
                    SRD->RD_INSS    := "N"
                    SRD->RD_IR      := "N"
                    SRD->RD_FGTS    := "N"
                    SRD->RD_PROCES  := SRA->RA_PROCES
                    SRD->RD_PERIODO := (cAliasQry)->RD_DATARQ
                    SRD->RD_SEMANA  := (cAliasQry)->RD_SEMANA
                    SRD->RD_ROTEIR  := "FOL"
                    SRD->RD_DTREF   := sToD((cAliasQry)->RD_DATPGT)
                EndIf
                SRD->RD_VALOR   := (cAliasQry)->RD_VALOR
                
                //Adiciona no log de ocorrências
                aAdd( aLog[1], "Filial: " + (cAliasQry)->RD_FILIAL + "  -  Matrícula: " + (cAliasQry)->RD_MAT + "  -  Período: " + (cAliasQry)->RD_DATARQ + " - Verba: " + aCodFol[1723, 1] + "  -  Valor: R$ " + cValToChar( Transform( (cAliasQry)->RD_VALOR, "@E 99,999,999,999.99" ) ) )

                //Libera o registro da SRD
                SRD->( MsUnlock() )
            EndIf
            
            //Pula para o próximo registro
            (cAliasQry)->( dbSkip() )
        EndDo

        //Fecha a tabela temporária da query
        (cAliasQry)->( dbCloseArea() )
    EndIf
EndIf

Return

/*/{Protheus.doc} fCriaSX1
Função que cria as perguntas que serão utilizdas na rotina
/*/
Static Function fCriaSX1()

Local aHelpPor := {}

AAdd( aHelpPor, "Informe o período inicial para a" )
AAdd( aHelpPor, "geração da verba de base." )
EngHLP117( "P"+".UPDBFER03.", aHelpPor, aHelpPor, aHelpPor )

aHelpPor := {}
AAdd( aHelpPor, "Informe o período final para a" )
AAdd( aHelpPor, "geração da verba de base." )
EngHLP117( "P"+".UPDBFER04.", aHelpPor, aHelpPor, aHelpPor )

//			<cGrupo>	, <cOrdem>	, <cPergunt>				, <cPerSpa>	, <cPerEng>		, <cVar>	,<cTipo>	,<nTamanho>	,<nDecimal>		, <nPresel>		,<cGSC>	,<cValid>							,<cF3>		,<cGrpSxg>	,<cPyme>	,<cVar01>			,<cDef01> 		,<cDefSpa1>		,<cDefEng1>		,<cCnt01>		,<cDef02>				,<cDefSpa2>				,<cDefEng2>			,<cDef03>	, <cDefSpa3>	,<cDefEng3>		, <cDef04>	,<cDefSpa4>		, <cDefEng4>	,<cDef05>		, <cDefSpa5>	, <cDefEng5>	, <aHelpPor>, <aHelpEng>	, <aHelpSpa>	, <cHelp> )
EngSX1117( cPerg 	    , "01" 		,"Filial ?"			 		, ""		, ""		 	, "MV_CH1" 	, "C" 		, 99		,0				, 0	   			, "R" 	, ""								, "XM0" 	, ""		, "S" 		, "MV_PAR01" 		, "" 	   		, "" 			, "" 			, "RD_FILIAL"	, "" 					, ""					, "" 	 			, "" 		, "" 			, "" 			, "" 		, ""	 		, ""	  	 	, ""			, "" 		 	, ""	  		, {}	   	, {}   			, {} 			, ".RHFILDE."	)
EngSX1117( cPerg 	    , "02" 		,"Matrícula ?"	 			, "" 		, ""			, "MV_CH2"	, "C" 		, 99   		,0	  			, 0	  	 		, "R" 	, ""								, "SRA" 	, "" 		, "S" 		, "MV_PAR02" 		, "" 	  		, "" 			, "" 			, "RD_MAT"		, "" 					, ""					, "" 	 			, "" 		, "" 			, "" 			, "" 	 	, ""	  		, ""	   		, ""		  	, "" 		 	, ""	  		, {}	   	, {} 			, {} 			, ".RHMATD."	)
EngSX1117( cPerg 	    , "03"		,"Período inicial? (AAAAMM)", ""		, ""	        , 'MV_CH3'	, 'C'		, 6			,0				, 0				, 'G'	, 'NaoVazio()'						, ""		, ""		, "S"		, "MV_PAR03"		, "" 	   		, ""			, "" 	   		, ""			, "" 					, "" 					, "" 	 			, ""	  	, ""	   		, ""		  	, "" 		, ""	  		, ""	   		, "" 			, "" 			, ""	  		, {}	   	, {} 			, {} 			, ".UPDBFER03."	)
EngSX1117( cPerg 	    , "04"		,"Período final? (AAAAMM)"	, ""		, ""	        , 'MV_CH4'	, 'C'		, 6			,0				, 0				, 'G'	, 'NaoVazio()'						, ""		, ""		, "S"		, "MV_PAR04"		, "" 			, ""			, "" 	   		, ""			, "" 					, "" 					, "" 	 			, ""	  	, ""	   		, ""		  	, "" 		, ""	  		, ""	   		, "" 			, "" 			, ""	  		, {}	   	, {} 			, {} 			, ".UPDBFER04."	)

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