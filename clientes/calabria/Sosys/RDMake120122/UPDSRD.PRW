#INCLUDE "RWMAKE.CH"      
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

#define STR0001 "Ajuste Tabela SRD - eSocial"
#define STR0002 "Ajuste da Tabela SRD"
#define STR0003 "UPDSRD - Processo de ajuste da tabela SRD"
#define STR0004 "Ajuste da Tabela SRD - Inicio do Processamento."
#define STR0005 "Registro SRD: "
#define STR0006 " - Processamento Realizado Com Sucesso."
#define STR0007 "Ajuste da Tabela SRD - Termino do Processamento."
#define STR0008 "Processando.."
#define STR0009 "Sem registros para processar."
#define STR0010 "Atencao"
#define STR0011 "Identificamos um GAP em nosso sistema na geração dos Eventos Periódicos do eSocial,"
#define STR0012 "mês de 05/2020, onde estava sendo gerada uma linha em branco na tabela SRD, roteiro ADI."
#define STR0013 "É necessário realizar o ajuste nesta tabela, que consistem em deletar esse registro que foi gerado incorretamente."
#define STR0014 "Esta rotina tem como objetivo apresentar os registros inconsistentes e deleta-los após a confirmação."
#define STR0015 "Executando manutenção nos registros da SRD..."
#define STR0016 "Realize o backup da base antes de executar esse processo."
#define STR0017 "Ferramenta para ajuste das datas de pagamento das verbas de mês seguinte na SRD."

/*/
{Protheus.doc} UPDSRD
Ajuste da tabela SRD no esocial

@author Silvio C. Stecca
@since  07/07/2020
/*/
User Function UPDSRD()

    Local aArea := GetArea()

    fMontaWizard()
    RestArea(aArea)

Return

/*/
{Protheus.doc} fMontaWizard
Monta o wizard da função

@author Silvio C. Stecca
@since  07/07/2020
/*/
Static Function fMontaWizard()

    Local cText1 := STR0016
    Local cText2 := STR0017
    Local cText3 := STR0003
    Local ctext4 := STR0011 +  STR0012 + STR0013 + STR0014
    
	oWizard := APWizard():New(cText1, cText2, cText3, ctext4, {||.T.}, {||.T.}, .F., Nil, {|| .T.}, Nil, {00,00,450,600} )
	
	//Painel 2 - Execução do processo
	oWizard:NewPanel(	STR0008                 , ; //"Processando.."
						STR0015                 , ; //"Executando manutenção nos registros da SRD..."
						{||.F.}                 , ; //<bBack>
						{||.F.}                 , ; //<bNext>
						{||.T.}                 , ; //<bFinish>
						.T.                     , ; //<.lPanel.>
						{| lEnd| fMntSRD(@lEnd)} ) //<bExecute>
	
	oWizard:Activate( .T.,{||.T.},{||.T.},	{||.T.})
Return

/*/
{Protheus.doc} fMntSRD
Ajuste da tabela SRD no esocial

@author Silvio C. Stecca
@since  07/07/2020
/*/
Static Function fMntSRD(lEnd)

	Local aArea			:= GetArea()
	Local aCoors 		:= FWGetDialogSize(oMainWnd)
	Local oDlg			                                 
	Local oFWLayer
	Local oPanelUp
	Local aColsMark		:= {}
	Local lMarcar		:= .F.
	Local bIntegra		:= {|| UPDSRDPROC()}
	Local bCancela		:= {|| oDlg:End()}
	Local aStruct 		:= SRD->(DbStruct())
	Local aFieldsFilter	:= {}
	Local nI			:= 1
	Local cAuxFilial	:= cFilant
    Local aFilCompet    := {}

	For nI := 1 To Len(aStruct)
		aAdd(aFieldsFilter, { aStruct[nI, 1], aStruct[nI, 1], aStruct[nI, 2], aStruct[nI, 3], aStruct[nI, 4],})
	Next nI
	
	Private aRotMark   	:= {}
	Private cAliasMark 	:= "TABAUX"
	Private oMark	
	Private oTmpTable	:= Nil
	Private lCorpManage	:= fIsCorpManage() 
	
	if lCorpManage
		cAuxFilial 	:= cFilant
		cFilant 	:= FWPesqSM0("M0_CODFIL")
		if Empty(cFilant)
			cFilant := cAuxFilial
		EndIf
	endif

	fCriaTmp()

    UPDSRDCARGA(.T.)

	aColsMark:= fMntColsMark()
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) FROM aCoors[1],aCoors[2] TO aCoors[3], aCoors[4]  PIXEL
		
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlg,.F.,.T.)
	oFWLayer:AddLine("UP",100,.F.) 
	oFWLayer:AddCollumn("ALLSRD", 99, .T., 'UP')     
	oPanelUp := oFWLayer:GetColPanel("ALLSRD", 'UP')

	oMark := FWMarkBrowse():New()
	oMark:SetAlias((cAliasMark))
	oMark:SetFields(aColsMark)
	oMark:SetOwner(oPanelUp)  

    aAdd(aFilCompet, {'RD_DATARQ'	,'FIELD'}) 
    aAdd(aFilCompet, {'=='			,'OPERATOR'})
    aAdd(aFilCompet, {'%RD_DATARQ%'	,'EXPRESSION'})
	
    oMark:AddFilter("Competencia (AAAAMM): ", "AllTrim(RD_DATARQ)  == '%RD_DATARQ%' ",,,,.T., aFilCompet, 'cIdCompet')

    // Define o campo que sera utilizado para a marcacao
	oMark:SetFieldMark('TAB_OK')
	oMark:SetUseFilter(.T.)
	oMark:SetValid({||.T.})
	oMark:AddButton("&Processar", bIntegra,,,, .F., 2) //"Processar manutenção tabela SRD."
	oMark:AddButton("&Cancelar"	, bCancela,, 2,, .F., 2)

	oMark:obrowse:odata:afieldsfilter := aFieldsFilter		
	oMark:bAllMark := {|| SetMarkAll(oMark:Mark(), lMarcar := !lMarcar), oMark:Refresh(.T.)}
	oMark:SetMenuDef('')
	oMark:Activate()
			
	ACTIVATE MSDIALOG oDlg
	
	oTmpTable:Delete()  
	oTmpTable := Nil 

	RestArea(aArea)

	cFilant := cAuxFilial
	
Return .T.

/*/
{Protheus.doc} fMntColsMark
Monta acols

@author Silvio C. Stecca
@since  07/07/2020
/*/
Static Function fMntColsMark()

	Local aArea		:= GetArea()
	Local aColsAux 	:=`{}
	Local aColsSX3	:= {}
	Local aCampos  	:= {}
	Local nX		:= 0
	
	aAdd(aCampos, {"RD_FILIAL"	, TamSX3("RD_FILIAL")[3]    , FWGETTAMFILIAL, 0})
	aAdd(aCampos, {"RD_MAT"		, TamSX3("RD_MAT")[3]    	, TamSX3("RD_MAT")[1]	, TamSX3("RD_MAT")[2]})
	aAdd(aCampos, {"RD_DATARQ"	, TamSX3("RD_DATARQ")[3]    , TamSX3("RD_DATARQ")[1], TamSX3("RD_DATARQ")[2]})
	aAdd(aCampos, {"RD_ROTEIR"	, TamSX3("RD_ROTEIR")[3]    , TamSX3("RD_ROTEIR")[1], TamSX3("RD_ROTEIR")[2]})
	aAdd(aCampos, {"RD_PD"	    , TamSX3("RD_PD")[3]        , TamSX3("RD_PD")[1]	, TamSX3("RD_PD")[2]})
	aAdd(aCampos, {"RD_VALOR"	, TamSX3("RD_VALOR")[3]     , TamSX3("RD_VALOR")[1]	, TamSX3("RD_VALOR")[2]})

	DbSelectArea("SX3")
	DbSetOrder(2)
	
	For nX := 1 to Len(aCampos)
		If SX3->( dbSeek(aCampos[nX, 1]) )
		    aColsSX3 := {X3Titulo(), &("{||(cAliasMark)->"+(aCampos[nX, 1]) + "}"), SX3->X3_TIPO, SX3->X3_PICTURE, 1, SX3->X3_TAMANHO, SX3->X3_DECIMAL, .F.,,,,,,,, 1}
		    aAdd(aColsAux, aColsSX3)
		    aColsSX3 := {}
		EndIf
	Next nX
	
	RestArea(aArea)

Return aColsAux

/*/
{Protheus.doc} fCriaTmp
Cria tabela temporÃ¡ria

@author Silvio C. Stecca
@since  07/07/2020
/*/
Static Function fCriaTmp()

	Local aColumns	:= {}
	Local lRet		:= .F.
	Local aCampos	:= {}
	Local nI		:= 1
	
	aAdd(aCampos, {"RD_FILIAL"	, TamSX3("RD_FILIAL")[3]    , FWGETTAMFILIAL, 0})
	aAdd(aCampos, {"RD_MAT"		, TamSX3("RD_MAT")[3]    	, TamSX3("RD_MAT")[1]	, TamSX3("RD_MAT")[2]})
	aAdd(aCampos, {"RD_DATARQ"	, TamSX3("RD_DATARQ")[3]    , TamSX3("RD_DATARQ")[1], TamSX3("RD_DATARQ")[2]})
	aAdd(aCampos, {"RD_ROTEIR"	, TamSX3("RD_ROTEIR")[3]    , TamSX3("RD_ROTEIR")[1], TamSX3("RD_ROTEIR")[2]})
	aAdd(aCampos, {"RD_PD"	    , TamSX3("RD_PD")[3]        , TamSX3("RD_PD")[1]	, TamSX3("RD_PD")[2]})
	aAdd(aCampos, {"RD_VALOR"	, TamSX3("RD_VALOR")[3]     , TamSX3("RD_VALOR")[1]	, TamSX3("RD_VALOR")[2]})

	If Select(cAliasMark) > 0
		DbSelectArea(cAliasMark)
		DbCloseArea()
	EndIf 
	
	aAdd(aColumns, {"TAB_OK", "C", 02, 00})
	
	For nI := 1 To Len(aCampos)
		aAdd(aColumns, {aCampos[nI, 1], aCampos[nI, 2], aCampos[nI, 3], aCampos[nI, 4]})
	Next nI
	
	aAdd(aColumns, {"RECNOSRD", "N", 10, 00})
	
	oTmpTable := FWTemporaryTable():New(cAliasMark)
	oTmpTable:SetFields( aColumns )
	oTmpTable:AddIndex("IND", {aCampos[1, 1], aCampos[2, 1]})
	oTmpTable:Create() 
	
Return lRet

/*/
{Protheus.doc} SetMarkAll
SeleÃ§Ã£o de registros

@author Silvio C. Stecca
@since  07/07/2020
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

/*/
{Protheus.doc} UPDSRDPROC
Processamento dos registros selecionados

@author Silvio C. Stecca
@since  07/07/2020
/*/
Static Function UPDSRDPROC()

	Local cMarca 		:= oMark:Mark()
	Local nTotReg		:= 0
	Local aLog			:= {}	

	DbSelectArea(cAliasMark)
	count to nTotReg  
	(cAliasMark)->(DbGoTop())
	
	aLog := {}

	While !(cAliasMark)->(Eof())

		If oMark:IsMark(cMarca)
            			
			SRD->(DBGOTO((cAliasMark)->RECNOSRD))

			RecLock("SRD", .F.)
				SRD->(DbDelete())
			SRD->(MsUnLock())

            aAdd(aLog, {OemToAnsi(STR0005) + " Filial: " + (cAliasMark)->RD_FILIAL + " /  Matric.: " + (cAliasMark)->RD_MAT + " - Roteiro: " + (cAliasMark)->RD_ROTEIR +  " - Competencia: " + (cAliasMark)->RD_DATARQ + OemToAnsi(STR0006)})

		EndIf
		
		(cAliasMark)->(DbSkip())
	EndDo
	
	(cAliasMark)->(DbGoTop())
	
	IF Len(aLog) > 0
		fMakeLog( aLog , {OemToAnsi(STR0006)} , NIL , .T. , FunName() , OemToAnsi(STR0005), "M", "P" )
	EndIf
	
	SetMarkAll(oMark:Mark(),.F. )
	
	UPDSRDCARGA(.F.)

	// Atualiza markbrowse
	oMark:Refresh(.T.)

Return Nil

/*/
{Protheus.doc} UPDSRDCARGA
Carrega registros

@author Silvio C. Stecca
@since  07/07/2020
/*/
Static Function UPDSRDCARGA(lMsg)

	Local aArea		:= GetArea()
	Local cAliasSRD	:= GetNextAlias()
	Local aCampos  	:= {}
	Local nT		:= 1
	
	aAdd(aCampos, {"RD_FILIAL"	, TamSX3("RD_FILIAL")[3]    , FWGETTAMFILIAL, 0})
	aAdd(aCampos, {"RD_MAT"		, TamSX3("RD_MAT")[3]    	, TamSX3("RD_MAT")[1]	, TamSX3("RD_MAT")[2]})
	aAdd(aCampos, {"RD_DATARQ"	, TamSX3("RD_DATARQ")[3]    , TamSX3("RD_DATARQ")[1], TamSX3("RD_DATARQ")[2]})
	aAdd(aCampos, {"RD_ROTEIR"	, TamSX3("RD_ROTEIR")[3]    , TamSX3("RD_ROTEIR")[1], TamSX3("RD_ROTEIR")[2]})
	aAdd(aCampos, {"RD_PD"	    , TamSX3("RD_PD")[3]        , TamSX3("RD_PD")[1]	, TamSX3("RD_PD")[2]})
	aAdd(aCampos, {"RD_VALOR"	, TamSX3("RD_VALOR")[3]     , TamSX3("RD_VALOR")[1]	, TamSX3("RD_VALOR")[2]})
	
    DbSelectArea(cAliasMark)
	(cAliasMark)->(DbGotop())
	
	While !(cAliasMark)->(Eof() )
		RecLock(cAliasMark,.F.)
		(cAliasMark)->(__dbZap())
		(cAliasMark)->(msUnlock())
		(cAliasMark)->(dbSkip())
	End
	
	// APENAS FUNCIONARIOS TRANSFERIDOS
	BeginSql alias cAliasSRD

		SELECT RD_FILIAL, RD_MAT, RD_DATARQ, RD_ROTEIR, RD_PD, RD_VALOR, R_E_C_N_O_ AS RECNOSRD
			FROM %table:SRD% SRD
		WHERE 
            SRD.RD_ROTEIR = 'ADI'
		    AND SRD.RD_PD = ''
			AND SRD.%notDel% 
            AND SRD.RD_FILIAL = %Exp:cFilAnt%

	EndSql
	
	DbSelectArea(cAliasMark)
	
	If (cAliasSRD)->(!Eof())
		Do While (cAliasSRD)->(!Eof())
			
			IncProc(OemToAnsi(STR0008))
			RecLock(cAliasMark, .T.)
			For nT := 1 To Len (aCampos) 
				If aCampos[nT, 2 ] <> "M" .And. aCampos[nT, 2 ] <> "L"
					If aCampos[nT, 2] == "D" .And.  ValType((cAliasSRD)->(&(aCampos[nT, 1]))) <> "D"
						(cAliasMark)->(&(aCampos[nT, 1])) := sTod((cAliasSRD)->(&(aCampos[nT, 1])))
					ElseIf aCampos[nT, 2] == "N" .And. ValType((cAliasSRD)->(&(aCampos[nT, 1]))) <> "N"
						(cAliasMark)->(&(aCampos[nT, 1])) := Val((cAliasSRD)->(&(aCampos[nT, 1])))			
					Else
						(cAliasMark)->(&(aCampos[nT, 1])) := (cAliasSRD)->(&(aCampos[nT, 1]))
					EndIf
				EndIf
			Next nT 

			(cAliasMark)->RECNOSRD := (cAliasSRD)->RECNOSRD
			(cAliasMark)->(MsUnLock())		

			(cAliasSRD)->(DbSkip())
		EndDo
	Else
		If lMsg
			Help(,, OemToAnsi(STR0010),, OemToAnsi(STR0009), 1, 0) //"Atencao"##"Sem registros para processar."
			Return ()
		EndIf
	EndIf

	(cAliasSRD)->(dbCloseArea())
	(cAliasMark)->(dbGotop())
	
	RestArea(aArea)

Return
