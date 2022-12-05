#INCLUDE "PROTHEUS.CH"

User Function UPD131FER()

Local aButtons  := {}
Local aSays     := {}
Local cMsg      := ""
Local lContinua := .F.
Local nOpcA     := 0

Private aCodFol := {}
Private aLog    := {}
Private aTitle  := {}
Private cPerg   := "UPD131F"

//Cria as perguntas no dicionário SX1 para filtro do processamento
If !fCriaSX1()
	Aviso("Atenção","É preciso criar o grupo de perguntas UPD131F via configurador(SIGACFG) conforme documentação. http://tdn.totvs.com/x/DRiWHQ ")
	Return
EndIf

aAdd(aSays,OemToAnsi( "Este programa tem como objetivo corrigir o roteiro de calculo das " ))
aAdd(aSays,OemToAnsi( "verbas de 13 salario antecipadas nas férias/Rescisão para o roteiro FOL que"))
aAdd(aSays,OemToAnsi( " estão no acumulado(SRD) como roteiro 131 "))

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
    fMakeLog(aLog,aTitle,,,"UPD131FER",OemToAnsi("Log de Ocorrências"),"M","P",,.F.)
EndIf

Return

/*/{Protheus.doc} fProcessa
Função que efetua o processamento para a geração do Id 1562
/*/
Static Function fProcessa()

Local cAliasQry := GetNextAlias()
Local cFilOld   := cFilAnt
Local cJoinRDRV	:= "% " + FWJoinFilial( "SRD", "SRV" ) + " %"
Local cWhere    := ""
Local cWhereQRY := ""
Local lNovo     := .F.
Local cRot131	:= fGetCalcRot("5")
Local cRotFOL	:= fGetRotOrdinar()
Local cPd131	:= RetValSRV('0022', xFilial("SRA"), "RV_COD",2)
Local cPdBase	:= "%'" + RetValSRV('0108', xFilial("SRA"), "RV_COD",2) + "','" +RetValSRV('0109', xFilial("SRA"), "RV_COD",2) + "'%"
Local aRecno	:= {}
Local nI		:= 1

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

//Prepara a variável para uso no BeginSql
cWhereQRY := "%" + cWhere + "%"

//Processa a query e cria a tabela temporária com os resultados
BeginSql alias cAliasQry
	SELECT SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_PROCES, SRD.RD_ROTEIR, SRD.RD_PERIODO, SRD.RD_SEMANA, SRD.RD_CC, SRD.RD_DATARQ, SRD.RD_DATPGT, SRD.R_E_C_N_O_ AS RECNOSRD
    FROM %table:SRD% SRD
    WHERE %exp:cWhereQRY% 
	 		AND SRD.RD_TIPO2 = 'K' 
	 		AND SRD.RD_ROTEIR = %exp:cRot131%
	 		AND SRD.RD_PD = %exp:cPd131%
            AND SRD.%notDel%
EndSql 

While (cAliasQry)->( !EoF() )
	SRD->(DbSetOrder(5))//RD_FILIAL, RD_MAT, RD_PROCES, RD_ROTEIR, RD_PERIODO, RD_SEMANA, R_E_C_N_O_, D_E_L_E_T_
   	If SRD->(dbseek((cAliasQry)->RD_FILIAL+(cAliasQry)->RD_MAT+(cAliasQry)->RD_PROCES+(cAliasQry)->RD_ROTEIR+(cAliasQry)->RD_PERIODO+(cAliasQry)->RD_SEMANA))
   		While SRD->(RD_FILIAL+RD_MAT+RD_PROCES+RD_ROTEIR+RD_PERIODO+RD_SEMANA) == (cAliasQry)->RD_FILIAL+(cAliasQry)->RD_MAT+(cAliasQry)->RD_PROCES+(cAliasQry)->RD_ROTEIR+(cAliasQry)->RD_PERIODO+(cAliasQry)->RD_SEMANA
	   		lAchou := fTemSRD((cAliasQry)->RECNOSRD,cRotFOL,SRD->RD_PD)
   			If !lAchou
   				aadd(aRecno,SRD->(Recno()))
   				aAdd( aLog[1], "Filial: " + (cAliasQry)->RD_FILIAL + "  -  Matrícula: " + (cAliasQry)->RD_MAT + "  -  Período: " + (cAliasQry)->RD_DATARQ + " - Verba: " +SRD->RD_PD  )
			EndIf
   			SRD->(dbSkip())
   		EndDo
    EndIf
    (cAliasQry)->( dbSkip() )
EndDo
(cAliasQry)->( dbCloseArea() )

cAliasQry := GetNextAlias()
//Processa a query e cria a tabela temporária com os resultados
BeginSql alias cAliasQry
 	SELECT SRD.R_E_C_N_O_ AS RECNOSRD
    FROM %table:SRD% SRD
    INNER JOIN  %table:SRR% SRR ON SRR.RR_FILIAL = SRD.RD_FILIAL AND SRD.RD_MAT = SRR.RR_MAT AND SRD.RD_PERIODO = SRR.RR_PERIODO AND SRD.RD_SEMANA = SRR.RR_SEMANA AND SRR.RR_TIPO3='R' AND SRD.RD_PROCES = SRR.RR_PROCES AND SRR.%notDel% AND SRD.RD_PD = SRR.RR_PD
    WHERE %exp:cWhereQRY% 
	 		AND SRD.RD_ROTEIR = %exp:cRot131%
	 		AND SRD.RD_PD IN (%exp:cPdBase%)
            AND SRD.%notDel%
EndSql 
  
While (cAliasQry)->( !EoF() )
	SRD->(dbGoto((cAliasQry)->RECNOSRD))
	lAchou := fTemSRD((cAliasQry)->RECNOSRD,cRotFOL,SRD->RD_PD)
	If !lAchou
		aadd(aRecno,SRD->(Recno()))
		aAdd( aLog[1], "Filial: " + SRD->RD_FILIAL + "  -  Matrícula: " + SRD->RD_MAT + "  -  Período: " + SRD->RD_DATARQ + " - Verba: " +SRD->RD_PD  )
	EndIf
	(cAliasQry)->( dbSkip() )
EndDo
(cAliasQry)->( dbCloseArea() ) 

For nI := 1 To Len(aRecno)
 	SRD->(dbGoto(aRecno[nI]))
	If SRD->( RecLock("SRD", .F.) )
		SRD->RD_ROTEIR  := cRotFOL
        SRD->( MsUnlock() )
    EndIf
Next 

If Len(aRecno) == 0
	Aviso("Atenção","Não foram encontradas inconsistências no acumulado.",{"OK"})
EndIf


Return

/*/{Protheus.doc} fCriaSX1
Função que cria as perguntas que serão utilizdas na rotina
/*/
Static Function fCriaSX1()
Local lRet := .T.
Local aHelpPor := {}

If GetRpoRelease() == "12.1.017"
	
	AAdd( aHelpPor, "Informe o período inicial para a" )
	AAdd( aHelpPor, "geração da verba." )
	EngHLP117( "P"+".UPD131F03.", aHelpPor, aHelpPor, aHelpPor )
	
	aHelpPor := {}
	AAdd( aHelpPor, "Informe o período final para a" )
	AAdd( aHelpPor, "geração da verba." )
	EngHLP117( "P"+".UPD131F04.", aHelpPor, aHelpPor, aHelpPor )
	
	//			<cGrupo>	, <cOrdem>	, <cPergunt>				, <cPerSpa>	, <cPerEng>		, <cVar>	,<cTipo>	,<nTamanho>	,<nDecimal>		, <nPresel>		,<cGSC>	,<cValid>							,<cF3>		,<cGrpSxg>	,<cPyme>	,<cVar01>			,<cDef01> 		,<cDefSpa1>		,<cDefEng1>		,<cCnt01>		,<cDef02>				,<cDefSpa2>				,<cDefEng2>			,<cDef03>	, <cDefSpa3>	,<cDefEng3>		, <cDef04>	,<cDefSpa4>		, <cDefEng4>	,<cDef05>		, <cDefSpa5>	, <cDefEng5>	, <aHelpPor>, <aHelpEng>	, <aHelpSpa>	, <cHelp> )
	EngSX1117( cPerg 	    , "01" 		,"Filial ?"			 		, ""		, ""		 	, "MV_CH1" 	, "C" 		, 99		,0				, 0	   			, "R" 	, ""								, "XM0" 	, ""		, "S" 		, "MV_PAR01" 		, "" 	   		, "" 			, "" 			, "RD_FILIAL"	, "" 					, ""					, "" 	 			, "" 		, "" 			, "" 			, "" 		, ""	 		, ""	  	 	, ""			, "" 		 	, ""	  		, {}	   	, {}   			, {} 			, ".RHFILDE."	)
	EngSX1117( cPerg 	    , "02" 		,"Matrícula ?"	 			, "" 		, ""			, "MV_CH2"	, "C" 		, 99   		,0	  			, 0	  	 		, "R" 	, ""								, "SRA" 	, "" 		, "S" 		, "MV_PAR02" 		, "" 	  		, "" 			, "" 			, "RD_MAT"		, "" 					, ""					, "" 	 			, "" 		, "" 			, "" 			, "" 	 	, ""	  		, ""	   		, ""		  	, "" 		 	, ""	  		, {}	   	, {} 			, {} 			, ".RHMATD."	)
	EngSX1117( cPerg 	    , "03"		,"Período inicial? (AAAAMM)", ""		, ""	        , 'MV_CH3'	, 'C'		, 6			,0				, 0				, 'G'	, 'NaoVazio()'						, ""		, ""		, "S"		, "MV_PAR03"		, "" 	   		, ""			, "" 	   		, ""			, "" 					, "" 					, "" 	 			, ""	  	, ""	   		, ""		  	, "" 		, ""	  		, ""	   		, "" 			, "" 			, ""	  		, {}	   	, {} 			, {} 			, ".UPDBFER03."	)
	EngSX1117( cPerg 	    , "04"		,"Período final? (AAAAMM)"	, ""		, ""	        , 'MV_CH4'	, 'C'		, 6			,0				, 0				, 'G'	, 'NaoVazio()'						, ""		, ""		, "S"		, "MV_PAR04"		, "" 			, ""			, "" 	   		, ""			, "" 					, "" 					, "" 	 			, ""	  	, ""	   		, ""		  	, "" 		, ""	  		, ""	   		, "" 			, "" 			, ""	  		, {}	   	, {} 			, {} 			, ".UPDBFER04."	)
Else
	
	dbSelectArea("SX1")
	dbSetOrder(1)
	If !SX1->( dbSeek(cPerg) )
		lRet := .F.
	EndIf
EndIf
Return lRet

Static Function fTemSRD(nRecno,cRotFOL,cPd)
Local aArea		:= SRD->(GetArea())
Local lTemConv	:= SRD->(COlumnPos("RD_CONVOC"))
Local lAchou	:= .F.

SRD->(dbGoto(nRecno))
If lTemConv
	SRD->( dbSetOrder(RetOrdem("SRD","RD_FILIAL+RD_MAT+RD_CC+RD_ITEM+RD_CLVL+RD_DATARQ+RD_PD+RD_SEQ+RD_PERIODO+RD_SEMANA+RD_ROTEIR+DTOS(RD_DTREF)+RD_CONVOC")) )
	lAchou := SRD->(dbSeek( SRD->(RD_FILIAL + RD_MAT + RD_CC + RD_ITEM + RD_CLVL + RD_DATARQ + cPd + RD_SEQ + RD_PERIODO + RD_SEMANA + cRotFOL + DTOS(RD_DTREF) + RD_CONVOC) ) )
Else
	SRD->( dbSetOrder(RetOrdem("SRD","RD_FILIAL+RD_MAT+RD_CC+RD_ITEM+RD_CLVL+RD_DATARQ+RD_PD+RD_SEQ+RD_PERIODO+RD_SEMANA+RD_ROTEIR+DTOS(RD_DTREF)")) )
	lAchou := SRD->(dbSeek( SRD->(RD_FILIAL + RD_MAT + RD_CC + RD_ITEM + RD_CLVL + RD_DATARQ + cPd + RD_SEQ + RD_PERIODO + RD_SEMANA + cRotFOL + DTOS(RD_DTREF)) ) )
EndIf

RestArea(aArea)
Return lAchou