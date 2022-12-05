#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'APWIZARD.CH'
#INCLUDE "Fileio.ch"

#define STR0001 "Anonimização de Dados Pessoais"
#define STR0002 "Esta rotina realiza a anonimização dos dados pessoais referentes aos papeis/personas registradas no sistema."
#define STR0003 "A anonimização é um processo de tratamento dos dados pessoais na qual realiza-se a exclusão dessas informações, com o objetivo de desvincular todas as informações que possam identificar (direta ou indireta) o titular."
#define STR0004 "A anonimização é irreversivel, ou seja, o dado perderá de modo definitivo e irreversível a possibilidade de associação, direta ou indireta, a um indivíduo."
#define STR0005 "Ciente da irreversibilidade desse processo, deseja continuar com a exclusão dos dados? "
#define STR0006 "Filtragem dos dados"
#define STR0007 "Informe o CPF e/ou Nome para localizar os registros a serem anonimizados."
#define STR0008 "Processando"
#define STR0009 "Localizando os registros"
#define STR0010 "Aguarde a filtragem dos dados..."
#define STR0011 "Carregando"
#define STR0012 "Os filtros CPF e Nome não foram informados. A localização dos registros será realizada sem filtros."
#define STR0013 "Continuar com o processamento?"
#define STR0014 "Processar"
#define STR0015 "Selecionado Registros..."
#define STR0016 "Aguarde"
#define STR0017 "Confirma Deleção"
#define STR0018 "Anonimização - Registros a serem excluídos do sistema"

//-------------------------------------------------------------------
/*/{Protheus.doc} User Function GPEM932
Rotina para realizar a anonimizacao dos dados das personas do LGPD
@author  Gisele Nuncherino	
@since   13/11/2020
/*/
//-------------------------------------------------------------------
User Function GPEM932()

Local aArea		:= GetArea()

Private __ODLG //variavel para pergunte forçando dialog
Private oWizard		:= Nil

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel 1 - Tela inicial do Wizard 		            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWizard := APWizard():New(			OemToAnsi(STR0001)	,;  //"Anonimização de Dados Pessoais"
										"" 					,; 
										OemtoAnsi(STR0002)  ,;  //"Esta rotina realiza a anonimização dos dados pessoais referentes aos papeis/personas registradas no sistema."								
										OemToAnsi(STR0003)+ CRLF + OemToAnsi(STR0004)+ CRLF + OemToAnsi(STR0005)	,; 
										{||.T.}, {||.T.}, .F., Nil, {|| .T.}, Nil, {00,00,450,600} )

	oWizard:NewPanel(	OemToAnsi(STR0006)		,;  //"Filtragem dos dados"
						OemToAnsi(STR0007)		,; //"Informe o CPF e/ou Nome para localizar os registros a serem anonimizados."
						{||.T.}					,; //<bBack>
						{||.T.} 				,; //<bNext>
						{|| Processa()}			,; //<bFinish>
						.T.						,; //<.lPanel.>
						{|| GPE931Perg()} )		   //<bExecute>

	oWizard:Activate( 		.T./*<.lCenter.>*/	,;
						 {||.T.}/*<bValid>*/	,;
						 {||.T.}/*<bInit>*/		,;
						 {||.T.}/*<bWhen>*/ 	)

	RestArea( aArea )

Return Nil

/*{Protheus.doc}ProcDelete
Rotina para exibir o processamento da rotina
@author Gisele Nuncherino
@since 13/11/2020
@version P12
*/
Static Function Processa()
	FwMsgRun(,{|| ProcDelete() },OemToAnsi(STR0010), OemToAnsi(STR0011)) 
return .T.


/*{Protheus.doc}ProcDelete
Rotina para selecionar os itens a serem excluidos e processar a exclusão
@author Gisele Nuncherino
@since 13/11/2020
@version P12
*/
Static Function ProcDelete()

Local ASTRUTRB 	:= {}
Local aOrdem	:= {}
Local oTmpTable
Local ABROWSE	:= {}
Local aPesq 	:= {}
Local cAliasTMP	:= GetNextAlias()
Local cCPF		:= ''
Local cNome		:= ''
Local nJ := 1
Local nI := 1
Local cFiltraRh

Local aAdvSize		:= {}

Static oMark
Private cMarca 	:= ''

	cCPF := StrTran( MV_PAR01 ,'.','' )
	cCPF := ALLTRIM(StrTran( cCPF ,'-','' ))
	cNome:= AllTrim(MV_PAR02)

	IF Empty(cCPF) .AND. Empty(cNome)
		If !MsgYesNo(OemToAnsi(STR0012), OemToAnsi(STR0013) ) //"Os filtros CPF e Nome não foram informados. A localização dos registros será realizada sem filtros."Continuar com o processamento?
			Return Nil
		EndIf
	EndIf

	Aadd( aPesq , {	"CPF", 	{ { "CPF"   , "C", 11 	, 0, "CPF", "999.999.999-99"}}, 1})
	Aadd( aPesq , {	"Nome", { { "NOME"  , "C", 100  , 0, "NOME", "@!"}}, 1})

	aadd(aStruTrb,{"FILIAL"	,"Filial"		, "C",8  ,0, "@!0"				})
	aadd(aStruTrb,{"CPF"	,"CPF"			, "C",11 ,0, "@R 999.999.999-99"})
	aadd(aStruTrb,{"NOME" 	,"Nome Persona"	, "C",100,0, "@!"})
	aadd(aStruTrb,{"PERSONA","Persona"		, "C",20 ,0, "@!"})
	aadd(aStruTrb,{"TABELA" ,"Tabela"		, "C",3  ,0, "@!"})
	aadd(aStruTrb,{"OK"    	,"OK"			, "C",02 ,0, "@!"})
	aadd(aStruTrb,{"RECNO" 	,"RECNO"		, "N",12 ,0, ""  })

	aBrowse := {}
	nJ := 1
	nI := 1
	For nI := 1 To Len(aStruTrb)
		
		If alltrim(aStruTrb[nI][1]) <> 'OK' .AND. alltrim(aStruTrb[nI][1]) <> 'RECNO' .AND. alltrim(aStruTrb[nI][1]) <> 'TABELA'
			AAdd( aBrowse, FWBrwColumn():New() )
			aBrowse[nJ]:SetData( &("{||" + aStruTrb[nI][1] + "}") )
			aBrowse[nJ]:SetTitle( aStruTrb[nI][2] )
			aBrowse[nJ]:SetSize( aStruTrb[nI][4] )
			aBrowse[nJ]:SetDecimal( aStruTrb[nI][5] )
			aBrowse[nJ]:SetPicture( aStruTrb[nI][6] )
		EndIf		
		nJ++
	Next nI

	If Select("TRB931") > 0
		TRB931->(DbCloseArea())
	EndIf

	aStruTrb := {}
	aadd(aStruTrb,{"FILIAL"	,"C",08	,0})
	aadd(aStruTrb,{"CPF"	,"C",11 ,0})
	aadd(aStruTrb,{"NOME" 	,"C",100,0})
	aadd(aStruTrb,{"PERSONA","C",20 ,0})
	aadd(aStruTrb,{"TABELA"	,"C",03 ,0})
	aadd(aStruTrb,{"OK"    	,"C",02 ,0})
	aadd(aStruTrb,{"RECNO"  ,"N",12 ,0})

	oTmpTable := FWTemporaryTable():New("TRB931")
	oTmpTable:SetFields( aStruTrb )

	aOrdem := {}
	Aadd(aOrdem, {"I1",{ 'CPF'	}})
	Aadd(aOrdem, {"I2",{ 'NOME'	}})

	oTmpTable:AddIndex("I1", aOrdem[1][2])
	oTmpTable:AddIndex("I2", aOrdem[2][2])
	oTmpTable:Create()

	IF CHKFILE("SRA")
		// Busca pela SRA
		BeginSql alias cAliasTMP
			SELECT *
				FROM %table:SRA% SRA
				WHERE 	SRA.RA_CIC LIKE '%' + %Exp:cCPF% +'%'
						AND SRA.RA_NOME LIKE '%' + %Exp:cNome% +'%'
						AND SRA.%notDel%
				ORDER BY SRA.RA_CIC
		EndSql
			While !(cAliasTMP)->(Eof())
					RecLock("TRB931",.T.)
						TRB931->FILIAL	:=	(cAliasTMP)->RA_FILIAL
						TRB931->CPF		:=	(cAliasTMP)->RA_CIC
						TRB931->NOME	:=	(cAliasTMP)->RA_NOME
						TRB931->PERSONA	:=	"SRA - Funcionário"
						TRB931->TABELA	:=	"SRA"
						TRB931->OK		:= "  "
						TRB931->RECNO	:= (cAliasTMP)->R_E_C_N_O_
					TRB931->(MsUnLock())
				(cAliasTMP)->(dbSkip())
			EndDo
		(cAliasTMP)->(dbCloseArea())
	EndIf

	IF CHKFILE("SPW")
		// Busca pela SPW - Visitante
		BeginSql alias cAliasTMP
			SELECT *
				FROM %table:SPW% SPW
				WHERE   SPW.PW_CPF LIKE '%' + %Exp:cCPF% +'%'
						AND (SPW.PW_NOME  LIKE '%' + %Exp:cNome% +'%'
 						OR SPW.PW_POSNOM1 LIKE '%' + %Exp:cNome% +'%'
						OR SPW.PW_POSNOM2 LIKE '%' + %Exp:cNome% +'%'
						OR SPW.PW_POSNOM3 LIKE '%' + %Exp:cNome% +'%'
						OR SPW.PW_POSNOM4 LIKE '%' + %Exp:cNome% +'%'
						OR SPW.PW_NOMFULL LIKE '%' + %Exp:cNome% +'%' )
						AND SPW.%notDel%
				ORDER BY SPW.PW_CPF
			EndSql
			While !(cAliasTMP)->(Eof())
					RecLock("TRB931",.T.)
						TRB931->FILIAL	:=	(cAliasTMP)->PW_FILIAL
						TRB931->CPF		:=	(cAliasTMP)->PW_CPF
						TRB931->NOME	:=	(cAliasTMP)->PW_NOME
						TRB931->PERSONA	:=	"SPW - Visitante"
						TRB931->TABELA	:=	"SPW"
						TRB931->OK		:= "  "
						TRB931->RECNO	:= (cAliasTMP)->R_E_C_N_O_
					TRB931->(MsUnLock())
				(cAliasTMP)->(dbSkip())
			EndDo
		(cAliasTMP)->(dbCloseArea())
	EndIf

	IF CHKFILE("SQG")
		// Busca pela SQG - Curriculos
		BeginSql alias cAliasTMP
			SELECT *
				FROM %table:SQG% SQG
				WHERE   SQG.QG_CIC LIKE '%' + %Exp:cCPF% +'%'
						AND SQG.QG_NOME LIKE '%' + %Exp:cNome% +'%'
						AND SQG.%notDel%
				ORDER BY SQG.QG_CIC
			EndSql
			While !(cAliasTMP)->(Eof())
					RecLock("TRB931",.T.)
						TRB931->FILIAL	:=	(cAliasTMP)->QG_FILIAL
						TRB931->CPF		:=	(cAliasTMP)->QG_CIC
						TRB931->NOME	:=	(cAliasTMP)->QG_NOME
						TRB931->PERSONA	:=	"SQG - Currículo"
						TRB931->TABELA	:=	"SQG"
						TRB931->OK		:= "  "
						TRB931->RECNO	:= (cAliasTMP)->R_E_C_N_O_
					TRB931->(MsUnLock())
				(cAliasTMP)->(dbSkip())
			EndDo
		(cAliasTMP)->(dbCloseArea())
	EndIf

	IF CHKFILE("RD0")
		// Busca pela RD0 - Participantes
		BeginSql alias cAliasTMP
			SELECT *
				FROM %table:RD0% RD0
				WHERE   RD0.RD0_CIC LIKE '%' + %Exp:cCPF% +'%'
						AND RD0.RD0_NOME LIKE '%' + %Exp:cNome% +'%'
						AND RD0.%notDel%
				ORDER BY RD0.RD0_CIC
			EndSql
			While !(cAliasTMP)->(Eof())
					RecLock("TRB931",.T.)
						TRB931->FILIAL	:=	(cAliasTMP)->RD0_FILIAL
						TRB931->CPF		:=	(cAliasTMP)->RD0_CIC
						TRB931->NOME	:=	(cAliasTMP)->RD0_NOME
						TRB931->PERSONA	:=	"RD0 - Participante"
						TRB931->TABELA	:=	"RD0"
						TRB931->OK		:= "  "
						TRB931->RECNO	:= (cAliasTMP)->R_E_C_N_O_
					TRB931->(MsUnLock())
				(cAliasTMP)->(dbSkip())
			EndDo
		(cAliasTMP)->(dbCloseArea())
	EndIf

	IF CHKFILE("SRB")
		// Busca pela SRB - Dependentes
		BeginSql alias cAliasTMP
			SELECT *
				FROM %table:SRB% SRB
				WHERE   SRB.RB_CIC LIKE '%' + %Exp:cCPF% +'%'
						AND SRB.RB_NOME LIKE '%' + %Exp:cNome% +'%'
						AND SRB.%notDel%
				ORDER BY SRB.RB_CIC
			EndSql
			While !(cAliasTMP)->(Eof())
					RecLock("TRB931",.T.)
						TRB931->FILIAL	:=	(cAliasTMP)->RB_FILIAL
						TRB931->CPF		:=	(cAliasTMP)->RB_CIC
						TRB931->NOME	:=	(cAliasTMP)->RB_NOME
						TRB931->PERSONA	:=	"SRB - Dependente"
						TRB931->TABELA	:=	"SRB"
						TRB931->OK		:= "  "
						TRB931->RECNO	:= (cAliasTMP)->R_E_C_N_O_
					TRB931->(MsUnLock())
				(cAliasTMP)->(dbSkip())
			EndDo
		(cAliasTMP)->(dbCloseArea())
	EndIf

	IF CHKFILE("SRQ")
		// Busca pela SRQ - Beneficiarios
		BeginSql alias cAliasTMP
			SELECT *
				FROM %table:SRQ% SRQ
				WHERE   SRQ.RQ_CIC LIKE '%' + %Exp:cCPF% +'%'
						AND SRQ.RQ_NOME LIKE '%' + %Exp:cNome% +'%'
						AND SRQ.%notDel%
				ORDER BY SRQ.RQ_CIC
			EndSql
			While !(cAliasTMP)->(Eof())
					RecLock("TRB931",.T.)
						TRB931->FILIAL	:=	(cAliasTMP)->RQ_FILIAL
						TRB931->CPF		:=	(cAliasTMP)->RQ_CIC
						TRB931->NOME	:=	(cAliasTMP)->RQ_NOME
						TRB931->PERSONA	:=	"SRQ - Beneficiário"
						TRB931->TABELA	:=	"SRQ"
						TRB931->OK		:= "  "
						TRB931->RECNO	:= (cAliasTMP)->R_E_C_N_O_C
					TRB931->(MsUnLock())
				(cAliasTMP)->(dbSkip())
			EndDo
		(cAliasTMP)->(dbCloseArea())
	EndIf

	IF CHKFILE("RA7")
		// Busca pela RA7 - Instrutor
		BeginSql alias cAliasTMP
			SELECT *
				FROM %table:RA7% RA7
				WHERE   RA7.RA7_CIC LIKE '%' + %Exp:cCPF% +'%'
						AND RA7.RA7_NOME LIKE '%' + %Exp:cNome% +'%'
						AND RA7.%notDel%
				ORDER BY RA7.RA7_CIC
			EndSql
			While !(cAliasTMP)->(Eof())
					RecLock("TRB931",.T.)
						TRB931->FILIAL	:=	(cAliasTMP)->RA7_FILIAL
						TRB931->CPF		:=	(cAliasTMP)->RA7_CIC
						TRB931->NOME	:=	(cAliasTMP)->RA7_NOME
						TRB931->PERSONA	:=	"RA7 - Instrutor"
						TRB931->TABELA	:=	"RA7"
						TRB931->OK		:= "  "
						TRB931->RECNO	:= (cAliasTMP)->R_E_C_N_O_
					TRB931->(MsUnLock())
				(cAliasTMP)->(dbSkip())
			EndDo
		(cAliasTMP)->(dbCloseArea())
	EndIf

	IF CHKFILE("TMK")
		// Busca pela TMK - Usuários de Medicina e Segurança
		BeginSql alias cAliasTMP
			SELECT *
				FROM %table:TMK% TMK
				WHERE   TMK.TMK_CIC LIKE '%' + %Exp:cCPF% +'%'
						AND TMK.TMK_NOMUSU LIKE '%' + %Exp:cNome% +'%'
						AND TMK.%notDel%
				ORDER BY TMK.TMK_CIC
			EndSql
			While !(cAliasTMP)->(Eof())
					RecLock("TRB931",.T.)
						TRB931->FILIAL	:=	(cAliasTMP)->TMK_FILIAL
						TRB931->CPF		:=	(cAliasTMP)->TMK_CIC
						TRB931->NOME	:=	(cAliasTMP)->TMK_NOMUSU
						TRB931->PERSONA	:=	"TMK - Usuários de Medicina e Segurança"
						TRB931->TABELA	:=	"TMK"
						TRB931->OK		:= "  "
						TRB931->RECNO	:= (cAliasTMP)->R_E_C_N_O_
					TRB931->(MsUnLock())
				(cAliasTMP)->(dbSkip())
			EndDo
		(cAliasTMP)->(dbCloseArea())
	EndIf

	IF CHKFILE("TM0")
		// Busca pela TM0 - Ficha Médica                  
		BeginSql alias cAliasTMP
			SELECT *
				FROM %table:TM0% TM0
				WHERE   TM0.TM0_CPF LIKE '%' + %Exp:cCPF% +'%'
						AND TM0.TM0_NOMFIC LIKE '%' + %Exp:cNome% +'%'
						AND TM0.%notDel%
				ORDER BY TM0.TM0_CPF
			EndSql
			While !(cAliasTMP)->(Eof())
					RecLock("TRB931",.T.)
						TRB931->FILIAL	:=	(cAliasTMP)->TM0_FILIAL
						TRB931->CPF		:=	(cAliasTMP)->TM0_CPF   
						TRB931->NOME	:=	(cAliasTMP)->TM0_NOMFIC
						TRB931->PERSONA	:=	"TM0 - Ficha Médica                  "
						TRB931->TABELA	:=	"TM0"
						TRB931->OK		:= "  "
						TRB931->RECNO	:= (cAliasTMP)->R_E_C_N_O_
					TRB931->(MsUnLock())
				(cAliasTMP)->(dbSkip())
			EndDo
		(cAliasTMP)->(dbCloseArea())
	EndIf

	dbSelectArea("TRB931")

	aAdvSize	:= MsAdvSize( .F.,.F.,370)
	Define MsDialog oDlgMark From aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] PIXEL
		oTela     := FWFormContainer():New( oDlgMark )
		cIdGrid   := oTela:CreateHorizontalBox( 100 )

		oTela:Activate( oDlgMark, .F. )

		oPanelDown  := oTela:GeTPanel( cIdGrid )
		
		oMark := FWMarkBrowse():New()
		oMark:SetAlias( "TRB931" )
		oMark:SetColumns(aBrowse)
		oMark:SetFieldMark( "OK" )
		oMark:AddButton(OemToAnsi(STR0014)/*"Processar"*/, {|| FwMsgRun(,{|| ProcReg() },Nil, "Processando...") },,,, .F., 2 ) 
		oMark:SetDescription( OemToAnsi(STR0001) )  

		cFiltraRh := ""
		oMark:SetFilterDefault( cFiltraRh )
		oMark:ForceQuitButton(.T.)  
		oMark:SetmenuDef( "" )
		oMark:SetSeek( .T., aPesq )
		oMark:SetAllMark( { || MsgRun( OemToAnsi(STR0015) , OemToAnsi(STR0016) , { || fMarkAll()}) } )
		
		cMarca 	:= GetMark()

		oMark:SetOwner(oPanelDown)

		oMark:Activate()

	ACTIVATE MSDIALOG oDlgMark CENTERED
Return .T.


/*{Protheus.doc}MenuDef
Cria os Menus para visualizar
@author Gisele Nuncherino
@since 13/11/2020
@version P12
*/
Static Function MenuDef()
	Local aRotina := {}
	Local aArea	:= GetArea()

	ADD OPTION aRotina TITLE OemToAnsi(STR0017) ACTION 'U_DelRegs' OPERATION 5 ACCESS 0 

	RestArea(aArea)
Return aRotina


/*{Protheus.doc}GPE931Perg
Rotina para exibir a tela de perguntas para filtragem dos dados
@author Gisele Nuncherino
@since 13/11/2020
@version P12
*/
Static Function GPE931Perg()

Pergunte("GPEM931",.T.,,,oWizard:oMPanel[oWizard:nPanel])

Return


/*{Protheus.doc}fMarkAll
Função para marcar/desmarcar todos os itens
@author Gisele Nuncherino
@since 13/11/2020
@version P12
*/
Static Function fMarkAll()

	dbSelectArea("TRB931")
	TRB931->( dbGoTop() )

	cMarca := oMark:Mark()

	While TRB931->( !Eof() )

		If (TRB931->OK <> cMarca)
			RecLock("TRB931", .F.)
			TRB931->OK := oMark:Mark()
			MSUnlock()
		ElseIf (TRB931->OK == cMarca)
			RecLock("TRB931", .F.)
			TRB931->OK := "  "
			MSUnlock()
		EndIf

		TRB931->( dbSkip() )
	EndDo

	oMark:GoTop()
	oMark:oBrowse:Refresh(.t.)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcReg
Monta a browse com os registros a serem processados
@author  Gisele Nuncherino
@since   17/11/2020
/*/
//-------------------------------------------------------------------
Static Function ProcReg()

Local lProc	  		:= .F.
Local cAliasProc	:= ''
Local nZ			:= 0
Local aTabelas		:= {}

Local aRegs			:= {}

Private oBrowse

aTabelas	:= {	{"RC8",1,"RC8->(RC8_FILIAL+RC8_MAT)"},;
					{"RC9",1,"RC9->(RC9_FILIAL+RC9_MAT)"},;
					{"RCS",1,"RCS->(RCS_FILIAL+RCS_MAT)"},;
					{"RCV",1,"RCV->(RCV_FILIAL+RCV_MAT)"},;
					{"RCW",1,"RCW->(RCW_FILIAL+RCW_MAT)"},;
					{"SRL",1,"SRL->(RL_FILIAL+RL_MAT)"	},;
					{"RIE",1,"RIE->(RIE_FILIAL+RIE_MAT)"},;
					{"SM8",1,"SM8->(M8_FILIAL+M8_MAT)"	},;
					{"SR4",1,"SR4->(R4_FILIAL+R4_MAT)"	},;
					{"RGE",1,"RGE->(RGE_FILIAL+RGE_MAT)"},;
					{"RAZ",1,"RAZ->(RAZ_FILIAL+RAZ_MAT)"},;
					{"RC8",1,"RC8->(RC8_FILIAL+RC8_MAT)"},;
					{"RC9",1,"RC9->(RC9_FILIAL+RC9_MAT)"},;
					{"RFI",1,"RFI->(RFI_FILIAL+RFI_MAT)"},;
					{"RH3",2,"RH3->(RH3_FILIAL+RH3_MAT)"},;
					{"RI6",3,"RI6->(RI6_FILIAL+RI6_MAT)"},;
					{"RHM",1,"RHM->(RHM_FILIAL+RHM_MAT)"},;
					{"RHO",1,"RHO->(RHO_FILIAL+RHO_MAT)"},;
					{"RHP",1,"RHP->(RHP_FILIAL+RHP_MAT)"},;
					{"RI8",1,"RI8->(RI8_FILIAL+RI8_MAT)"},;
					{"RHN",1,"RHN->(RHN_FILIAL+RHN_MAT)"},;
					{"AA1",7,"AA1->(AA1_FILIAL+AA1_MAT)"},;
					{"GYG",2,"GYG->(GYG_FILIAL+GYG_FUNCIO)"}}

//VERIFICA NOVOS INDICES
If AllTrim(RCU->(IndexKey(3))) == "RCU_FILIAL+RCU_MAT"
	AADD(aTabelas, {"RCU",3,"RCU->(RCU_FILIAL+RCU_MAT)"})
EndIf
If AllTrim(RA8->(IndexKey(3))) == "RA8_FILIAL+RA8_MAT"
	AADD(aTabelas, {"RA8",3,"RA8->(RA8_FILIAL+RA8_MAT)"})
EndIf

dbSelectArea("TRB931")
TRB931->( dbGoTop() )
cMarca := oMark:Mark()

While TRB931->( !Eof() )
	If (TRB931->OK == cMarca)
		lProc := .T.
		do case
			case TRB931->TABELA == "SPW" //VISITANTE
				dbSelectArea("SPW")
				DBGOTO(TRB931->RECNO)	
				SPY->(DBSETORDER(1))		
				//PY_FILIAL+PY_VISITA+DTOS(PY_DTVISIT)+PY_CRACHA+PY_NUMERO
				IF SPY->(DBSEEK(xFilial("SPY", SPW->SPW_FILIAL) + SPW->SPW_VISITA))
					WHILE !SPY->(EOF()) .AND. SPY->(SPY_FILIAL+SPY_VISITA) == SPW->(SPW_FILIAL+SPW_VISITA)
						aadd(aRegs, {SPY->SPY_FILIAL, '' , '',  "SPW - Visitante", "SPY", cMarca, SPY->(Recno())})
						SPY->(DBSKIP())
					ENDDO
				EndIf

			case TRB931->TABELA == "RD0" //PARTICIPANTES
				dbSelectArea("RD0")
				DBGOTO(TRB931->RECNO)
				IF CHKFILE("RDC")
					RDC->(DBSETORDER(2))
					//RDC_FILIAL+RDC_CODADO+RDC_CODAVA+RDC_CODPRO+RDC_CODDOR+DTOS(RDC_DTIAVA)+RDC_CODNET+RDC_NIVEL+RDC_TIPOAV
					IF RDC->(DBSEEK(xFilial("RDC", RD0->RD0_FILIAL) + RD0->RD0_CODIGO ))
						WHILE !RDC->(EOF()) .AND. RDC->(RDC_FILIAL+RDC_CODADO) == RD0->(RD0_FILIAL+RD0_CODIGO)
							aadd(aRegs, {RDC->RDC_FILIAL, '' , '',  "RD0 - Participante", "RDC", cMarca, RDC->(Recno())})
							RDC->(DBSKIP())
						ENDDO
					EndIf

					RDC->(DBSETORDER(3))
					//RDC_FILIAL+RDC_CODDOR+RDC_CODADO+RDC_CODAVA+RDC_CODPRO+DTOS(RDC_DTIAVA)+RDC_CODNET+RDC_NIVEL+RDC_TIPOAV
					IF RDC->(DBSEEK(xFilial("RDC", RD0->RD0_FILIAL) + RD0->RD0_CODIGO))
						WHILE !RDC->(EOF()) .AND. RDC->(RDC_FILIAL+RDC_CODDOR) == RD0->(RD0_FILIAL+RD0_CODIGO)
							aadd(aRegs, {RDC->RDC_FILIAL, '' , '',  "RD0 - Participante", "RDC", cMarca, RDC->(Recno())})
							RDC->(DBSKIP())
						ENDDO
					EndIf					
				EndIf
				IF CHKFILE("RDZ")
					RDZ->(DBSETORDER(2))
					//RDZ_FILIAL+RDZ_CODRD0+RDZ_EMPENT+RDZ_FILENT+RDZ_ENTIDA
					IF RDZ->(DBSEEK(xFilial("RDZ", RD0->RD0_FILIAL) + RD0->RD0_CODIGO))
						WHILE !RDZ->(EOF()) .AND. RDZ->(RDZ_FILIAL+RDZ_CODRD0) == RD0->(RD0_FILIAL+RD0_CODIGO)
							aadd(aRegs, {RDZ->RDZ_FILIAL, '' , '',  "RD0 - Participante", "RDZ", cMarca, RDZ->(Recno())})
							RDZ->(DBSKIP())
						ENDDO
					EndIf
				EndIf

			case TRB931->TABELA == "SRA" //FUNCIONARIO
				dbSelectArea("SRA")
				DBGOTO(TRB931->RECNO)	

				for nZ := 1 to len(aTabelas)
					cAliasProc := aTabelas[nZ,1]

					IF CHKFILE(cAliasProc) 
						(cAliasProc)->(DBSETORDER(aTabelas[nZ,2]))
						IF (cAliasProc)->(DBSEEK(xFilial(cAliasProc, SRA->RA_FILIAL) + SRA->RA_MAT))
							WHILE !(cAliasProc)->(EOF()) .AND. &(aTabelas[nZ,3]) == SRA->(RA_FILIAL+RA_MAT)
								aadd(aRegs, {&(cAliasProc + "->" + cAliasProc + "_FILIAL"), '' , '',  "SRA - Funcionario", cAliasProc, cMarca, (cAliasProc)->(Recno())})	
								(cAliasProc)->(DBSKIP())
							ENDDO
						EndIf
					EndIf

				Next nZ

				IF CHKFILE("RGC") //RRA DIRF
					If AllTrim(RGC->(IndexKey(3))) == "RGC_FILIAL+RGC_CPFCGC"
						RGC->(DBSETORDER(3)) 
						//RGC_FILIAL+RGC_CPFCGC
						IF RGC->(DBSEEK(XFILIAL("RGC",SRA->RA_FILIAL) + SRA->RA_CIC))
							WHILE !RGC->(EOF()) .AND. RGC->(RGC_FILIAL+RGC_CPFCGC) == SRA->(RA_FILIAL+RA_CIC)
								aadd(aRegs, {RGC->RGC_FILIAL, '' , '',  "SRA - Funcionario", "RGC", cMarca, RGC->(Recno())})
								RGC->(DBSKIP())
							ENDDO
						EndIf
					EndIf
				EndIf
		endcase
	EndIf
	TRB931->( DBSKIP() )
EndDo

IF LEN(aRegs) > 0
	for nZ := 1 to len(aRegs)
		RecLock("TRB931",.T.)
			TRB931->FILIAL	:=	aRegs[nZ][1]
			TRB931->CPF		:=	aRegs[nZ][2]   
			TRB931->NOME	:=	aRegs[nZ][3]
			TRB931->PERSONA	:=	aRegs[nZ][4]
			TRB931->TABELA	:=	aRegs[nZ][5]
			TRB931->OK		:=  aRegs[nZ][6]
			TRB931->RECNO	:=  aRegs[nZ][7]
		TRB931->(MsUnLock())
	Next nZ
EndIf

if lProc
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("TRB931")
	oBrowse:SetDescription(OemToAnsi(STR0018)) //"Anonimização - Registros a serem excluídos do sistema"
	oBrowse:SetLocate()
	oBrowse:SetTemporary(.T.)
	oBrowse:SetFilterDefault("TRB931->OK == '" + cMarca + "'")
   	oBrowse:SetColumns(MontaColunas("RECNO"     ,"Recno"        ,01,"@!",0,012,0))
   	oBrowse:SetColumns(MontaColunas("TABELA"    ,"Persona"      ,02,"@!",1,080,0))
	oBrowse:Activate()

	oDlgMark:End()

EndIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} MontaColunas
Monta as colunas para a browse
@author  Gisele Nuncherino
@since   17/11/2020
/*/
//-------------------------------------------------------------------
Static Function MontaColunas(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
    Local aColumn
    Local bData     := {||}
    Default nAlign     := 1
    Default nSize     := 20
    Default nDecimal:= 0
    Default nArrData:= 0
   
    
    If nArrData > 0
        bData := &("{||" + cCampo +"}") 
    EndIf
    
    /* Array da coluna
    [n][01] Título da coluna
    [n][02] Code-Block de carga dos dados
    [n][03] Tipo de dados
    [n][04] Máscara
    [n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
    [n][06] Tamanho
    [n][07] Decimal
    [n][08] Indica se permite a edição
    [n][09] Code-Block de validação da coluna após a edição
    [n][10] Indica se exibe imagem
    [n][11] Code-Block de execução do duplo clique
    [n][12] Variável a ser utilizada na edição (ReadVar)
    [n][13] Code-Block de execução do clique no header
    [n][14] Indica se a coluna está deletada
    [n][15] Indica se a coluna será exibida nos detalhes do Browse
    [n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
    */
    aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}
Return {aColumn}


//-------------------------------------------------------------------
/*/{Protheus.doc} DelRecs
Processa a deleção dos registros selecionados
@author  Gisele Nuncherino
@since   17/11/2020
/*/
//-------------------------------------------------------------------
Static Function DelReg()

Local nTotal := 0
Local nSpace := 0
Local cMsgLog := "Registros anomizados com sucesso:" + CRLF
cMsgLog += "*** RECNO *** Tabela/Persona ***" + CRLF

dbSelectArea("TRB931")
TRB931->( dbGoTop() )

While !TRB931->( Eof() ) 
	If TRB931->OK == cMarca 
		dbSelectArea(TRB931->TABELA)
		DBGOTO(TRB931->RECNO)

		RecLock(TRB931->TABELA, .F.)
			dbDelete()
		MsUnlock()

		nTotal++
		nSpace := len(alltrim(Str(TRB931->RECNO))) + 4
		cMsgLog += SPACE(4) + alltrim(Str(TRB931->RECNO)) + SPACE(14-nSpace) + TRB931->PERSONA + CRLF
	EndIf
	TRB931->( DBSkip() ) 
EndDo
cMsgLog += CRLF
cMsgLog += "***** Total de registros processados: " + alltrim(Str(nTotal))

GeraLog( cMsgLog )

CloseBrowse()

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} GeraLog( cMsg )
Função para gerar um log conforme a mensagem passada no cMsg
@author  Gisele Nuncherino
@since   17/11/2020
/*/
//-------------------------------------------------------------------
static function GeraLog( cMsg )
	local cMascara	:= "Arquivo" + " .LOG | *.log" //"Arquivos"
	local cTitulo	:= "Selecione o local" //"Selecione o local"
	local nMascpad	:= 0
	local cRootPath	:= ""
	local lSalvar	:= .F.	//.F. = Salva || .T. = Abre
	local nOpcoes	:= nOR( GETF_LOCALHARD,GETF_ONLYSERVER,GETF_RETDIRECTORY )
	local l3Server	:= .T.	//.T. = apresenta o árvore do servidor || .F. = não apresenta
	local cFileLOG	:= "Anonimizacao" + "_" + dtos( date() ) + "_" + strTran( allTrim( time() ),":","" ) + ".log"
	local cPathLOG	:= ""	
	local nArqLog	:= 0
	
	cPathLOG	:= cGetFile( cMascara,cTitulo,nMascpad,cRootPath,lSalvar,nOpcoes,l3Server )
		
	If empty(cPathLOG)
		cPathLOG := GetSrvProfString("RootPath","") + "\"
	EndIf
	
	nArqLog		:= fCreate( cPathLOG+cFileLOG,FC_NORMAL,,.F. )
	fWrite( nArqLog,cMsg )
	fClose( nArqLog )
	MsgInfo("Processo finalizado." + CRLF + "Log gerado com sucesso." + CRLF + CRLF + "Arquivo: " + cPathLOG+cFileLOG,"Anonimização Finalizada")
return .T. 


//-------------------------------------------------------------------
/*/{Protheus.doc} DelRegs
Informa o processamento da delecao
@author  Gisele Nuncherino
@since   17/11/2020
/*/
//-------------------------------------------------------------------
User Function DelRegs()

FwMsgRun(,{|| DelReg() },Nil, "Excluindo registros...") 

return .T.
