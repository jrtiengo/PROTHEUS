#INCLUDE "RWMAKE.CH"      
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

#define STR0001 "Ajuste Tabela SVA - eSocial"
#define STR0002 "Ajuste da Tabela SVA"
#define STR0003 "Processo de ajuste da tabela SVA"
#define STR0004 "Ajuste da Tabela SVA - Inicio do Processamento"
#define STR0005 "Funcionario: "
#define STR0006 " - Ajuste da Tabela SVA - Processamento Realizado Com Sucesso"
#define STR0007 "Ajuste da Tabela SVA - Termino do Processamento"
#define STR0008 "Processando.."
#define STR0009 "Sem registros para processar."
#define STR0010 "Atencao"

/*/
{Protheus.doc} UPDSVA
Ajuste da tabela SVA no esocial

@author Silvio C. Stecca
@since  15/06/2020
/*/
User Function UPDSVA()

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

	UPDSVAVer(.T.)

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

/*/
{Protheus.doc} fMntColsMark
Monta acols

@author Silvio C. Stecca
@since  15/06/2020
/*/
Static Function fMntColsMark()

	Local aArea		:= GetArea()
	Local aColsAux 	:=`{}
	Local aColsSX3	:= {}
	Local aCampos  	:= {}
	Local nX		:= 0
	
	Aadd(aCampos, {"RA_FILIAL"	, "C", FWGETTAMFILIAL, 0})
	Aadd(aCampos, {"RA_MAT"		, "C", TamSX3("RA_MAT")[1]	, TamSX3("RA_MAT")[2]})
	Aadd(aCampos, {"RA_NOME"	, "C", TamSX3("RA_NOME")[1]	, TamSX3("RA_NOME")[2]})
	
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
Cria tabela temporária

@author Silvio C. Stecca
@since  15/06/2020
/*/
Static Function fCriaTmp()

	Local aColumns	:= {}
	Local lRet		:= .F.
	Local aCampos	:= {}
	Local nI		:= 1
	
	Aadd(aCampos, {"RA_FILIAL"	, "C", FWGETTAMFILIAL, 0})
	Aadd(aCampos, {"RA_MAT"		, "C", TamSX3("RA_MAT")[1]	, TamSX3("RA_MAT")[2]})
	Aadd(aCampos, {"RA_NOME"	, "C", TamSX3("RA_NOME")[1]	, TamSX3("RA_NOME")[2]})

	If Select(cAliasMark) > 0
		DbSelectArea(cAliasMark)
		DbCloseArea()
	EndIf 
	
	aAdd(aColumns, {"TAB_OK", "C", 02, 00})
	
	For nI := 1 To Len(aCampos)
		aAdd(aColumns, {aCampos[nI, 1], aCampos[nI, 2], aCampos[nI, 3], aCampos[nI, 4]})
	Next nI
	
	aAdd(aColumns, {"RECNOSVA", "N", 10, 00})
	
	oTmpTable := FWTemporaryTable():New(cAliasMark)
	oTmpTable:SetFields( aColumns )
	oTmpTable:AddIndex("IND", {aCampos[1, 1], aCampos[2, 1]})
	oTmpTable:Create() 
	
Return lRet

/*/
{Protheus.doc} SetMarkAll
Seleção de registros

@author Silvio C. Stecca
@since  15/06/2020
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
{Protheus.doc} INIPROC
Processamento dos registros selecionados

@author Silvio C. Stecca
@since  15/06/2020
/*/
Static Function INIPROC()

	Local bProcesso		:= {|oSelf| UPDSVAPROC(oSelf)}
	Local cCadastro 	:= OemToAnsi(STR0002) 
	Local cDescricao	:= OemToAnsi(STR0003) 
	
	tNewProcess():New( "UPDSVA" , cCadastro , bProcesso , cDescricao , "",,,,,.T.)
	
	oMark:deactivate()

Return Nil

/*/
{Protheus.doc} UPDSVAPROC
Processamento dos registros selecionados

@author Silvio C. Stecca
@since  15/06/2020
/*/
Static Function UPDSVAPROC(oSelf)

	Local cMarca 		:= oMark:Mark()
	Local nTotReg		:= 0
	Local aLog			:= {}	

	DbSelectArea(cAliasMark)
	count to nTotReg  
	(cAliasMark)->(DbGoTop())
	
	oSelf:SetRegua1(nTotReg)
	oSelf:SaveLog(OemToAnsi(STR0004)) 
	
	aLog 	:= {}

	While !(cAliasMark)->(Eof())
		 
		If oMark:IsMark(cMarca)
			oSelf:IncRegua1(STR0005 + " " + (cAliasMark)->RA_FILIAL + " - " + (cAliasMark)->RA_MAT)				
			SVA->(DBGOTO((cAliasMark)->RECNOSVA))

			RecLock("SVA", .F.)
				SVA->(DbDelete())
			SVA->(MsUnLock())

            aAdd(aLog, {OemToAnsi(STR0005) + (cAliasMark)->RA_FILIAL + " - " + (cAliasMark)->RA_MAT +  " - " + alltrim((cAliasMark)->RA_NOME) + OemToAnsi(STR0006)})

		EndIf
		
		(cAliasMark)->(DbSkip())
	EndDo
	
	(cAliasMark)->(DbGoTop())
	
	IF Len(aLog) > 0
		fMakeLog( aLog , {OemToAnsi(STR0006)} , NIL , .T. , FunName() , OemToAnsi(STR0005), "M", "P" )
	EndIf
	
	oSelf:SaveLog(OemToAnsi(STR0007))

	SetMarkAll(oMark:Mark(),.F. )
	
	UPDSVAVER(.F.)

	// Atualiza markbrowse
	oMark:Refresh(.T.)

Return Nil

/*/
{Protheus.doc} GPA938Ver
Carrega registros

@author Silvio C. Stecca
@since  15/06/2020
/*/
Static Function UPDSVAVER(lMsg) 

	Processa({|| UPDSVACARGA(lMsg)})

Return

/*/
{Protheus.doc} UPDSVACARGA
Carrega registros

@author Silvio C. Stecca
@since  15/06/2020
/*/
Static Function UPDSVACARGA(lMsg)

	Local aArea		:= GetArea()
	Local cAliasSVA	:= GetNextAlias()
	Local aCampos  	:= {}
	Local nT		:= 1
	
	Aadd(aCampos, {"RA_FILIAL"	, "C", FWGETTAMFILIAL, 0})
	Aadd(aCampos, {"RA_MAT"		, "C", TamSX3("RA_MAT")[1]	, TamSX3("RA_MAT")[2]})
	Aadd(aCampos, {"RA_NOME"	, "C", TamSX3("RA_NOME")[1]	, TamSX3("RA_NOME")[2]})

	DbSelectArea(cAliasMark)
	(cAliasMark)->(DbGotop())
	
	While !(cAliasMark)->(Eof() )
		RecLock(cAliasMark,.F.)
		(cAliasMark)->(__dbZap())
		(cAliasMark)->(msUnlock())
		(cAliasMark)->(dbSkip())
	End
	
	// APENAS FUNCIONARIOS TRANSFERIDOS
	BeginSql alias cAliasSVA
		SELECT RA_FILIAL, RA_MAT, RA_NOME, SVA.R_E_C_N_O_ RECNOSVA
			FROM %table:SRA% SRA
		LEFT JOIN %table:SVA% SVA ON 
			VA_FILIAL = RA_FILIAL 
			AND VA_MATRIC = RA_MAT
			AND SVA.D_E_L_E_T_ <> '*' 
		INNER JOIN %table:RGE% RGE ON 
			RGE.RGE_FILIAL = SVA.VA_FILIAL 
			AND RGE.RGE_MAT = SVA.VA_MATRIC 
			AND RGE.D_E_L_E_T_ <> '*' 
			AND RGE.RGE_COD = '01' 
			AND RGE.RGE_SALRED > 0 
			AND RGE.RGE_PERC > 0 
		WHERE 
			SVA.VA_OBSERV NOT LIKE '%Data de in%' 
			AND SVA.VA_TP = '1' 
			AND SVA.D_E_L_E_T_ <> '*'
	EndSql
	
	DbSelectArea(cAliasMark)
	
	If (cAliasSVA)->(!Eof())
		Do While (cAliasSVA)->(!Eof())
			
			IncProc(OemToAnsi(STR0008))
			RecLock(cAliasMark,.T.)
			For nT := 1 To Len (aCampos) 
				(cAliasMark)->( &(aCampos[nT, 1]) ) := (cAliasSVA)->( &(aCampos[nT, 1]) )
			Next nT 

			(cAliasMark)->RECNOSVA := (cAliasSVA)->RECNOSVA
			(cAliasMark)->(MsUnLock())		

			(cAliasSVA)->(DbSkip())
		EndDo
	Else
		If lMsg
			Help(,, OemToAnsi(STR0010),, OemToAnsi(STR0009), 1, 0) //"Atenção"##"Sem registros para processar."
			Return ()
		EndIf
	EndIf

	(cAliasSVA)->(dbCloseArea())
	(cAliasMark)->(dbGotop())
	
	RestArea(aArea)

Return