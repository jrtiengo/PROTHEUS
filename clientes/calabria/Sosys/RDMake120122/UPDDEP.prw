#include 'Protheus.ch'
#Include 'fwmvcdef.ch'
#include 'GPEA938A.CH'

/*/{Protheus.doc} UPDDEP
//Ajuste da integração dos dependentes dos funcionarios no esocial
@author Gisele Nuncherino
@since 26/09/2019
/*/
User Function UPDDEP()

	Local aArea			:= GetArea()
	Local aCoors 		:= FWGetDialogSize(oMainWnd)
	Local oDlg			                                 
	Local oFWLayer
	Local oPanelUp
	Local aColsMark		:= {}
	Local lMarcar		:= .F.
	Local bIntegra		:= {|| INIPROC() }
	Local aStruct 		:= SRA->(DbStruct())
	Local aFieldsFilter	:= {}
	Local nI			:= 1
	Local cAuxFilial	:= cFilant
	
	For nI := 1 To Len(aStruct)
		Aadd(aFieldsFilter, { aStruct[nI, 1], aStruct[nI, 1], aStruct[nI, 2], aStruct[nI, 3], aStruct[nI, 4],})
	Next nI
	
	Private aRotMark   	:= {}
	Private cAliasMark 	:= "TABAUX"
	Private oMark	
	Private oTmpTable	:= Nil
	Private lCorpManage	:= fIsCorpManage() 
	
	if lCorpManage
		cAuxFilial 	:= cFilant
		cFilant 	:= FWPesqSM0("M0_CODFIL")
		if empty(cFilant)
			cFilant := cAuxFilial
		EndIf
	endif

	fCriaTmp()

	UPDDEPVer()

	aColsMark:= fMntColsMark()
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) FROM aCoors[1],aCoors[2] TO aCoors[3], aCoors[4]  PIXEL
		
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlg,.F.,.T.)
	oFWLayer:AddLine("UP",100,.F.) 
	oFWLayer:AddCollumn("ALLSRA", 99, .T., 'UP' )     
	oPanelUp := oFWLayer:GetColPanel("ALLSRA", 'UP' )

	oMark := FWMarkBrowse():New()
	oMark:SetAlias((cAliasMark))
	oMark:SetFields(aColsMark)
	oMark:SetOwner( oPanelUp )  
	oMark:bAllMark := {|| SetMarkAll(oMark:Mark(), lMarcar := !lMarcar), oMark:Refresh(.T.)}

	// Define o campo que sera utilizado para a marcação
	oMark:SetFieldMark( 'TAB_OK')
	oMark:SetUseFilter(.T.)
	oMark:SetValid({||.T.})
	oMark:AddButton("Processar"	, bIntegra	,,,, .F., 2 ) //"Processar integração com esocial"

	oMark:obrowse:odata:afieldsfilter := aFieldsFilter		
	oMark:SetMenuDef('')
	oMark:Activate()
			
	ACTIVATE MSDIALOG oDlg
	
	oTmpTable:Delete()  
	oTmpTable := Nil 

	RestArea(aArea)

	cFilant := cAuxFilial
	
Return .T.



/*/{Protheus.doc} fMntColsMark
//Monta acols
@author Gisele Nuncherino
@since 26/09/2019
/*/
Static Function fMntColsMark()

	Local aArea		:= GetArea()
	Local aColsAux 	:=`{}
	Local aColsSX3	:= {}
	Local aCampos  	:= {}
	Local nX		:= 0
	
	aCampos  	:= SRA->(dbStruct())

	DbSelectArea("SX3")
	DbSetOrder(2)
	
	For nX := 1 to Len(aCampos)
		If SX3->( dbSeek(aCampos[nX,1]) )
		    aColsSX3 := {X3Titulo(), &("{||(cAliasMark)->"+(aCampos[nX,1])+"}"), SX3->X3_TIPO, SX3->X3_PICTURE,1,SX3->X3_TAMANHO,SX3->X3_DECIMAL,.F.,,,,,,,,1}
		    aAdd(aColsAux,aColsSX3)
		    aColsSX3 := {}
		EndIf
	Next nX
	
	RestArea(aArea)

Return aColsAux

/*/{Protheus.doc} fCriaTmp
//Cria tabela temporária
@author Gisele Nuncherino
@since 26/09/2019
/*/
Static Function fCriaTmp()

	Local aColumns	 := {}
	Local lRet		 := .F.
	Local aCampos  	:= SRA->(dbStruct())
	Local nI		:= 1
	
	If Select(cAliasMark) > 0
		DbSelectArea(cAliasMark)
		DbCloseArea()
	EndIf 
	
	aAdd(aColumns, {"TAB_OK", "C", 02, 00})
	
	For nI := 1 To Len(aCampos)
		aAdd(aColumns, {aCampos[nI, 1], aCampos[nI, 2], aCampos[nI, 3], aCampos[nI, 4]})
	Next nI
	
	aAdd(aColumns, {"RECNOSRA", "N", 10, 00})
	
	oTmpTable := FWTemporaryTable():New(cAliasMark)
	oTmpTable:SetFields( aColumns )
	oTmpTable:AddIndex("IND", {aCampos[1, 1], aCampos[2, 1]})
	oTmpTable:Create() 
	
Return lRet


/*/{Protheus.doc} SetMarkAll
//Seleção de registros
@author Gisele Nuncherino
@since 26/09/2019
/*/
Static Function SetMarkAll(cMarca, lMarcar)

	Local aAreaMark  := (cAliasMark)->(GetArea())
	
	dbSelectArea(cAliasMark)
	(cAliasMark)->( dbGoTop() )
	
	While !(cAliasMark)->( Eof() )
		RecLock( (cAliasMark), .F. )
			(cAliasMark)->TAB_OK := IIf(lMarcar, cMarca, '  ')
		MsUnLock()
		
		(cAliasMark)->(dbSkip())
		
	EndDo

RestArea(aAreaMark)

Return


/*/{Protheus.doc} INIPROC
//Processamento dos registros selecionados
@author Gisele Nuncherino
@since 26/09/2019
/*/
Static Function INIPROC()

	Local bProcesso		:= {|oSelf| UPDDEPPROC(oSelf)}
	Local cCadastro 	:= OemToAnsi(STR0002) 
	Local cDescricao	:= OemToAnsi(STR0003) 
	
	tNewProcess():New( "UPDDEP" , cCadastro , bProcesso , cDescricao , "",,,,,.T.)
	
	oMark:deactivate()

Return Nil


/*/{Protheus.doc} UPDDEPPROC
//Processamento dos registros selecionados
@author Gisele Nuncherino
@since 26/09/2019
/*/
Static Function UPDDEPPROC(oSelf)

	Local cMarca 		:= oMark:Mark()
	Local nTotReg		:= 0
	Local aErros		:= {}
	Local aLog			:= {}	
	Local cVersEnvio	:= ""
	Local cVersGPE		:= ""
	Local lRet			:= .F.
	Local lAjustaDep	:= .T. // enviar ajuste de dependentes 
	Local nOpc			:= 3


	If FindFunction("fVersEsoc")
		fVersEsoc( "S2200", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, @cVersGPE)
	EndIf
	If Empty(cVersGPE)
		cVersGPE := cVersEnvio
	EndIf

	DbSelectArea(cAliasMark)
	count to nTotReg  
	(cAliasMark)->(DbGoTop())
	
	oSelf:SetRegua1(nTotReg)
	oSelf:SaveLog(OemToAnsi(STR0004)) 
	
	aLog 	:= {}
	aErros 	:= {}

	While !(cAliasMark)->(Eof())
		 
		If oMark:IsMark(cMarca)
			oSelf:IncRegua1(STR0005 + " " + (cAliasMark)->RA_FILIAL + " - " + (cAliasMark)->RA_MAT)				
			SRA->(DBGOTO((cAliasMark)->RECNOSRA))
			SRA->(RegtoMemory("SRA",.F.,.F.,.F.) )

			// ENVIA OS DADOS PARA O ESOCIAL			
			lRet:= fIntAdmiss("SRA",/*lAltCad*/,nOpc,"S2200",/*cTFilial*/,/*aDep*/, SRA->RA_CODUNIC ,/*oModel*/, "ADM", @aErros, ; 
							   cVersEnvio, /*oMdlRFZ*/, /*aFilial*/, /*oMdlRS9*/, /*cFilTrf*/, /*dDtAdm*/, /*aVinc*/, /*cFilDe*/, .F. , ; 
							   /*cCCAte*/, /*cArqSR6*/, /*cSR6Fil*/, /*cEmpP*/, /*cArqSRJ*/, /*cSRJFil*/, /*cArqSQ3*/, /*cSQ3Fil*/, /*dValRJ5*/,; 
							   /*cSVAObs*/, /*lTrfCNPJ*/, /*lNovoCPF*/, /*cNovoCodUnic*/, lAjustaDep)

			if !lRet
				aAdd( aLog , {"Funcionário: " + (cAliasMark)->RA_FILIAL + " - " + (cAliasMark)->RA_MAT +  " - " + alltrim((cAliasMark)->RA_NOME) + " - Erro: " + aErros[1]})
            ELSE
                aAdd( aLog , {"Funcionário: " + (cAliasMark)->RA_FILIAL + " - " + (cAliasMark)->RA_MAT +  " - " + alltrim((cAliasMark)->RA_NOME) + " - Processamento Realizado Com Sucesso"})
			endif
		EndIf
		
		(cAliasMark)->(DbSkip())
	EndDo
	
	(cAliasMark)->(DbGoTop())
	
	IF LEN(aLog) <= 0
		fMakeLog( aLog , {OemToAnsi(STR0006)} , NIL , .T. , FunName() , OemToAnsi(STR0007), "M", "P" )
	ELSE
		fMakeLog( aLog , {OemToAnsi(STR0008)} , NIL , .T. , FunName() , OemToAnsi(STR0007), "M", "P" )
	EndIf
	
	oSelf:SaveLog(OemToAnsi(STR0009))

	SetMarkAll(oMark:Mark(),.F. )
	
	UPDDEPVER()

	oMark:Refresh(.T.) //Atualiza markbrowse

Return Nil



/*/{Protheus.doc} GPA938Ver
//Carrega registros
@author Gisele Nuncherino
@since 26/09/2019
/*/
Static Function UPDDEPVER 

	Processa( {|| UPDDEPCARGA( ) } )

Return


/*/{Protheus.doc} UPDDEPCARGA
//Carrega registros
@author Gisele Nuncherino
@since 26/09/2019
/*/
Static Function UPDDEPCARGA()

	Local aArea		:= GetArea()
	Local cAliasSRA	:= GetNextAlias()
	Local aCampos  	:= SRA->(dbStruct())
	Local nT		:= 1
	Local lDepErro	:= .T.
	
	DbSelectArea(cAliasMark)
	(cAliasMark)->(DbGotop())
	
	While !(cAliasMark)->(Eof() )
		RecLock(cAliasMark,.F.)
		(cAliasMark)->(__dbZap())
		(cAliasMark)->(msUnlock())
		(cAliasMark)->(dbSkip())
	End
	
	// APENAS FUNCIONARIOS TRANSFERIDOS
	BeginSql alias cAliasSRA
		SELECT DISTINCT  SRA.R_E_C_N_O_ AS RECNOSRA ,SRA.*, C9V.*
		FROM %table:SRA% SRA
		LEFT JOIN %table:SRB% SRB ON
			SRB.RB_FILIAL 	= SRA.RA_FILIAL AND
			SRB.RB_MAT		= SRA.RA_MAT 	AND
			SRB.%notDel% 
		INNER JOIN %table:C9V% C9V ON 
        	C9V.C9V_CPF 	= SRA.RA_CIC  AND
        	C9V.C9V_FILIAL	= SRA.RA_FILIAL	
		WHERE 
	        C9V.C9V_ATIVO 	= '1' 	AND
			//C9V.C9V_IDTRAN 	<> ' ' 	AND
			//C9V.C9V_DTTRAN 	=  ' ' 	AND
			C9V.C9V_STATUS 	= '4'	AND
			SRA.RA_FILIAL = %exp:cFilant% AND
			C9V.%notDel% AND
    	    SRA.%notDel% 
			
	EndSql
	
	DbSelectArea(cAliasMark)
	
	While (cAliasSRA)->(!Eof())
		
		IncProc(OemToAnsi(STR0010))
		
		lDepErro := .T.

		SRB->(DBSETORDER(1)) //RB_FILIAL+RB_MAT+RB_COD
		C9Y->(DBSETORDER(2)) //C9Y_FILIAL+C9Y_ID+C9Y_IDDEP		

		IF SRB->(DBSEEK((cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT)) .and. C9Y->(DBSEEK((cAliasSRA)->(C9V_FILIAL+C9V_ID)))
			WHILE SRB->(!EOF()) .AND. SRB->(RB_FILIAL+RB_MAT) == (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT
				C9Y->(DBSEEK((cAliasSRA)->(C9V_FILIAL+C9V_ID)))
				WHILE !C9Y->(EOF()) .AND. C9Y->(C9Y_FILIAL+C9Y_ID) == (cAliasSRA)->(C9V_FILIAL+C9V_ID)
					IF alltrim(C9Y->C9Y_NOMDEP) == alltrim(SRB->RB_NOME) .AND. C9Y->C9Y_DTNASC == SRB->RB_DTNASC
						lDepErro := .F.
						exit
					EndIf	
					C9Y->(dbSkip())
				EndDo
				SRB->(DbSkip())
			EndDo
		ELSEIF !(SRB->(DBSEEK((cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT))) .and. C9Y->(DBSEEK((cAliasSRA)->(C9V_FILIAL+C9V_ID)))
			lDepErro := .T.
		ELSE
			lDepErro := .F.
		EndIf

		IF lDepErro //se achou dependentes com erro
			RecLock(cAliasMark,.T.)
			For nT := 1 To Len( aCampos ) 
				if aCampos[nT, 2 ] <> "M" .and. aCampos[nT, 2 ] <> "L"
					if aCampos[nT, 2 ] == "D" .and.  valtype((cAliasSRA)->( &(aCampos[nT, 1]) )) <> "D"
						(cAliasMark)->( &(aCampos[nT, 1]) ) := STOD((cAliasSRA)->( &(aCampos[nT, 1]) ))
					ELSEIF aCampos[nT, 2 ] == "N" .and. valtype((cAliasSRA)->( &(aCampos[nT, 1]) )) <> "N"
						(cAliasMark)->( &(aCampos[nT, 1]) ) := VAL((cAliasSRA)->( &(aCampos[nT, 1]) ))			
					ELSE
						(cAliasMark)->( &(aCampos[nT, 1]) ) := (cAliasSRA)->( &(aCampos[nT, 1]) )
					EndIf
				EndIf
			Next nT 
			(cAliasMark)->RECNOSRA := (cAliasSRA)->RECNOSRA
			
			(cAliasMark)->(MsUnLock())		
		EndIf

		(cAliasSRA)->(DbSkip())
	EndDo
	
	(cAliasSRA)->( dbCloseArea() )
	(cAliasMark)->(dbGotop())
	
	RestArea(aArea)
Return 

