#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "Fileio.ch"


//-------------------------------------------------------------------
/*/{Protheus.doc} User Function ATUSQB
Rotina para realizar o ajuste do campo QB_KEYINI
@author  Gisele Nuncherino	
@since   01/12/2020
/*/
//-------------------------------------------------------------------
User Function ATUSQB()

Local aArea		:= GetArea()

Private __ODLG //variavel para pergunte forçando dialog
Private oWizard		:= Nil

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Painel 1 - Tela inicial do Wizard 		            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWizard := APWizard():New(			"Ajuste de Departamento - Chave de busca"	,;  
										"" ,; 
										"Ajuste de Departamento - Chave de busca" ,;  
										"Esta rotina realiza o ajuste da chave de busca (QB_KEYINI) no cadastro de departamentos." + CRLF + "Antes de realizar este procedimento, é recomendavél realizar o backup da tabela SQB (Departamentos)."+ CRLF + "Ao final do processamento dos dados, o sistema direcionará para a rotina de cadastro de departamentos para a conferência dos dados." ,; 
										{||.T.}, {||.T.}, .F., Nil, {|| .T.}, Nil, {00,00,450,600} )

	oWizard:NewPanel(	"Filtragem dos dados"	,;  
						"Informe a filial e o centro de custo dos departamentos a serem reprocessados."		,; 
						{||.T.}					,; //<bBack>
						{||.T.} 				,; //<bNext>
						{|| Processa()}			,; //<bFinish>
						.T.						,; //<.lPanel.>
						{|| AUTSQBPerg()} )		   //<bExecute>

	oWizard:Activate( 		.T./*<.lCenter.>*/	,;
						 {||.T.}/*<bValid>*/	,;
						 {||.T.}/*<bInit>*/		,;
						 {||.T.}/*<bWhen>*/ 	)

	RestArea( aArea )

Return Nil

/*{Protheus.doc}Processa
Rotina para exibir o processamento da rotina
@author Gisele Nuncherino
@since 01/12/2020
@version P12
*/
Static Function Processa()
	FwMsgRun(,{|| ProcUpdate() }, "Aguarde enquanto os dados são processados e carregados...", "Processando") 
return .T.


/*{Protheus.doc}ProcUpdate
Rotina para reprocessar o campo QB_KEYINI
@author Gisele Nuncherino
@since 01/12/2020
@version P12
*/
Static Function ProcUpdate()


Local cAliasTMP	:= GetNextAlias()
Local cFil		:= ''
Local cCC		:= ''

cFil 	:= xfilial("SQB", MV_PAR01)
cCC 	:= MV_PAR02


IF CHKFILE("SQB")
	BeginSql alias cAliasTMP
		SELECT SQB.R_E_C_N_O_ AS RECSQB
			FROM %table:SQB% SQB
			WHERE 	SQB.QB_FILIAL = %Exp:cFil% 
					AND SQB.QB_CC = %Exp:cCC% 
					AND SQB.%notDel%
		EndSql
	
	While !(cAliasTMP)->(Eof())
		SQB->(DBGOTO((cAliasTMP)->RECSQB))
			RecLock("SQB",.F.)
				SQB->QB_KEYINI	:=	''
			SQB->(MsUnLock())
		(cAliasTMP)->(dbSkip())
	EndDo
	(cAliasTMP)->(dbCloseArea())
EndIf

FWAlertInfo("Ajuste dos registros concluído com sucesso.")

CSAA100()
	
Return .T.


/*{Protheus.doc}AUTSQBPerg
Rotina para exibir a tela de perguntas para filtragem dos dados
@author Gisele Nuncherino
@since 01/12/2020
@version P12
*/
Static Function AUTSQBPerg()

Pergunte("AUTSQB",.T.,,,oWizard:oMPanel[oWizard:nPanel])

Return


/*{Protheus.doc} User Function FiltraCCT
Rotina para filtrar os centros de custos na consulta padrao CTTSQB conforme a filial selecionada
@author Gisele Nuncherino
@since 04/12/2020
@version P12
*/
User Function FiltraCCT()

Local oDlg, oLbx
Local aCpos  	:= {}
Local aRet   	:= {}
Local lRet   	:= .F.
Local cFilt 	:= MV_PAR01

DEFINE MSDIALOG oDlg TITLE "Centro de Custo" FROM 0,0 TO 350,500 PIXEL

@ 030,010 LISTBOX oLbx FIELDS HEADER "Filial", "Centro de Custo" , "Desrição" SIZE 230,120 OF oDlg PIXEL

aCpos := fGetCTT(cFilt)

oLbx:SetArray( aCpos )
oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2], aCpos[oLbx:nAt,3]}}
oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3]}}}

DEFINE SBUTTON FROM 160,213 TYPE 1 ACTION (oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3]})  ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTER

If Len(aRet) > 0 .And. lRet
	If Empty(aRet[2])
		lRet := .F.
	Else
		MV_PAR02 := aRet[2]
	EndIf
EndIf

Return lRet


/*{Protheus.doc}fGetCTT
Query para retornar os centros de custos conforme filtro
@author Gisele Nuncherino
@since 04/12/2020
@version P12
*/
Static Function fGetCTT(cFilt)

Local aDados  	:= {}
Local cQuery 	:= ""
Local cAliasCTT := GetNextAlias()

cQuery := " SELECT CTT.CTT_FILIAL,CTT.CTT_CUSTO, CTT.CTT_DESC01 "
cQuery +=   " FROM " + RetFullName("CTT",EmpSQBResp()) + " CTT "
cQuery +=  " WHERE CTT.D_E_L_E_T_ = ' ' "

if !empty(cFilt)
	cQuery +=    " AND CTT.CTT_FILIAL  = '" + xFilial("CTT", cFilt) + "' "
EndIf

cQuery += " ORDER BY CTT.CTT_FILIAL, CTT.CTT_CUSTO "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCTT,.T.,.T.)

While (cAliasCTT)->(!Eof())
	aAdd(aDados,{(cAliasCTT)->(CTT_FILIAL),(cAliasCTT)->(CTT_CUSTO), (cAliasCTT)->(CTT_DESC01)})
	(cAliasCTT)->(dbSkip())
EndDo
(cAliasCTT)->(dbCloseArea())

If Len(aDados) < 1
	aAdd(aDados,{" "," "," "})
EndIf

Return aDados
