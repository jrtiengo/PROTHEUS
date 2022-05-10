#Include 'Totvs.ch'
#Include 'FWMVCDef.ch'
#Include "FWMBROWSE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³SCIA130   ºAutor  ³Microsiga           º Data ³  04/25/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SCIA130()

Local aArea   := GetArea()
Local oBrowse := Nil
Local cTitulo := "Processo de Pagamentos"

Private aRotina := {}

oBrowse := FWMBrowse():New()

oBrowse:SetAlias("Z02")

oBrowse:SetDescription(cTitulo)

oBrowse:SetFilterDefault( "Z02->Z02_SOLRES = '" + RetCodUsr() + "' " )

//Definicao da legenda
//oBrowse:AddLegend("Z02_STATUS='1'","RED","Bloqueado")    //1=Bloqueado;2=Liberado
//oBrowse:AddLegend("Z02_STATUS='2'","GREEN","Liberado") //1=Bloqueado;2=Liberado
oBrowse:AddLegend("u_ChkCon1(Z02->Z02_CHAVE+Z02->Z02_NUMRES)=='1'","RED","Sem Anexo")
oBrowse:AddLegend("u_ChkCon1(Z02->Z02_CHAVE+Z02->Z02_NUMRES)=='2'","GREEN","Com Anexo")

oBrowse:Activate()

RestArea(aArea)

Return ( nil )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |MenuDef   | Autor | Joao Mattos           | Data |14/08/2017|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Criacao do menu MVC                                        |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | MenuDef()                                                  |||
|||-----------+------------------------------------------------------------|||
||| Parametros| Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpA1 - Array contendo as rotinas deste programa           |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function MenuDef()

//Local aRotina := {}
//Private aRotina := {}

//Adicionando opções
ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.SCIA130' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.SCIA130' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.SCIA130' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.SCIA130' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
ADD OPTION aRotina TITLE 'Consulta Aprovação'       ACTION "u_A130Po()" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 5
//ADD OPTION aRotina TITLE 'Anexos'                   ACTION "MsDocument('Z02',Z02->(RecNo()), 4)" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 5
ADD OPTION aRotina TITLE 'Anexos'                   ACTION "u_SCI130An()" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 5
ADD OPTION aRotina TITLE 'Envia Aprovação WF'       ACTION "u_SCI130WF()" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
ADD OPTION aRotina TITLE 'Reprocessa Lançamentos '  ACTION "u_SCI130Rep()" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4



Return ( aRotina )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |ModelDef  | Autor | Joao Mattos           | Data |14/08/2017|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Criacao do Modelo MVC                                      |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | ModelDef()                                                 |||
|||-----------+------------------------------------------------------------|||
||| Parametros| Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpO1 - Objeto modelo de dados                             |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function ModelDef()

Local oModel 	:= NIL
Local oStruZ02	:= FWFormStruct(1,'Z02', {|cCampo| AllTRim(cCampo)   $ "Z02_TPPA/Z02_CHAVE/Z02_NOMPA/Z02_DTWF/Z02_HRWF/Z02_STWF/Z02_STATUS/Z02_RTINCR/Z02_CODUSR/Z02_NOMUSR/Z02_NUMRES/Z02_SOLRES/Z02_ANEXO/Z02_VLRPA/" })
Local oStruGrid := FWFormStruct(1,'Z02', {|cCampo| !(AllTRim(cCampo) $ "Z02_TPPA/Z02_CHAVE/Z02_NOMPA/Z02_DTWF/Z02_HRWF/Z02_STWF/Z02_STATUS/Z02_RTINCR/Z02_CODUSR/Z02_NOMUSR/Z02_NUMRES/Z02_SOLRES/Z02_ANEXO/Z02_VLRPA/") })
Local aRelZ02   := {}

oModel	:= MPFormModel():New('SCIA130M',{|oModel| MA130PreVl(oModel)} , {|oModel| MA130PosVl(oModel)} , {|oModel| MA130Commi(oModel)})
oModel:AddFields( 'MdFieldZ02',NIL,oStruZ02)
oModel:AddGrid( 'MdGridZ02','MdFieldZ02',oStruGrid, ,/*{|oModel|MA060PosLin(oModel)}*/                    ,/*bPreGrid*/,/*bProsGrid*/, {|oModel|SCIA130LDG( oModel ) })
//oModel:AddGrid( 'Z13GRID'  , 'MASTER'   , oStruZ13, ,{|oGrd,nLine,cAction| fValidGrid(oGrd,nLine,cAction)},            ,             , {|oModel|SLCM420LDG( oModel ) })

AADD( aRelZ02, { 'Z02_FILIAL'	, 'xFilial( "Z02" )'	})
AADD( aRelZ02, { 'Z02_CHAVE'	, 'Z02_CHAVE'			})
AADD( aRelZ02, { 'Z02_NUMRES'	, 'Z02_NUMRES'			})

oModel:SetRelation('MdGridZ02', aRelZ02, Z02->(IndexKey(1) ) )

oModel:SetDescription("Prestação de Contas")

oModel:SetPrimaryKey( { 'xFilial("Z02")','Z02_CHAVE','Z02_NUMRES'})

oModel:SetVldActive( { |oModel| SCIOpen( oModel ) } )

// Liga o controle de nao repeticao de linha
//oModel:GetModel( 'MdGridZ02' ):SetUniqueLine( { 'Z02_CODUSR' } )

oStruZ02:SetProperty('Z02_TPPA'  , MODEL_FIELD_WHEN,{|| SLA130WHEN(oModel)                            })
//oStruZ02:SetProperty('Z02_CODUSR'  , MODEL_FIELD_WHEN,{|| SLA130WHEN(oModel)                            })
//oStruZ02:SetProperty('Z02_CHAVE' , MODEL_FIELD_WHEN,{|| SLA130WHEN(oModel) .and. "M->Z02_TPPA == '1' "})
//oModel:SetProperty("Z02_DESNAT", MODEL_FIELD_INIT , {|| Posicione("SED",1,xFilial("SED")+Z02->Z02_NAT,"ED_DESCRIC")    } )

Return oModel

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |ViewDef   | Autor | Joao Mattos           | Data |14/08/2017|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Defnicoes da Rotina AxVisual                               |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | ViewDef()                                                  |||
|||-----------+------------------------------------------------------------|||
||| Parametros| Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpO1 - Objeto da View                                     |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function ViewDef()

Local oView		:= NIL
Local oModel	:= FWLoadModel('SCIA130')
Local oStruZ02	:= FWFormStruct(2,'Z02', {|cCampo| AllTRim(cCampo)   $ "Z02_TPPA/Z02_CHAVE/Z02_NOMPA/Z02_DTWF/Z02_HRWF/Z02_STWF/Z02_STATUS/Z02_RTINCR/Z02_CODUSR/Z02_NOMUSR/Z02_NUMRES/Z02_SOLRES/Z02_ANEXO/Z02_VLRPA/"  })
Local oStruGrid := FWFormStruct(2,'Z02', {|cCampo| !(AllTRim(cCampo) $ "Z02_TPPA/Z02_CHAVE/Z02_NOMPA/Z02_DTWF/Z02_HRWF/Z02_STWF/Z02_STATUS/Z02_RTINCR/Z02_CODUSR/Z02_NOMUSR/Z02_NUMRES/Z02_SOLRES/Z02_ANEXO/Z02_VLRPA/"  )})

oView:= FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_Z02', oStruZ02, 'MdFieldZ02')
oView:AddGrid ('GRID_Z02', oStruGrid, 'MdGridZ02' )

oView:CreateHorizontalBox("MAIN",35)
oView:CreateHorizontalBox("GRID",65)

oView:SetOwnerView('VIEW_Z02','MAIN')
oView:SetOwnerView('GRID_Z02','GRID')

oView:AddIncrementField( 'GRID_Z02', 'Z02_ITEM' )

oView:EnableControlBar(.T.)

Return oView

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |SLA130WHEN| Autor | Joao Mattos           | Data |15/08/2017|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Edicao do campo Codigo de Safra                            |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | SLA130WHEN(oModel)                                         |||
|||-----------+------------------------------------------------------------|||
||| Parametros| ExpO1 = Objeto do Model                                    |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpL1 - Verdadeiro ou Falso                                |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function SLA130WHEN(oModel)

Local lReturn := If((oModel:GetOperation() = MODEL_OPERATION_INSERT),.T.,.F.)

Return ( lReturn )


*********************************************************************************************************************************************
*********************************************************************************************************************************************
*********************************************************************************************************************************************
Static Function MA130PreVl( oModel )

Local lRet := .T.

//If oModel:GetValue("Z02_TPPA") == "2" .and. Empty(oModel:GetValue("Z02_NUMRES"))
//	Alert("Processo de ressarcimento deve ter número.")
//	lRet := .F.
//EndIf

Return lRet


*********************************************************************************************************************************************
*********************************************************************************************************************************************
*********************************************************************************************************************************************
Static Function MA130PosVl( oModel )

Local lRet := .T.

//If oModel:GetValue("Z02_TPPA") == "2" .and. Empty(oModel:GetValue("Z02_NUMRES"))
If M->Z02_TPPA == "2" .and. Empty(M->Z02_NUMRES)
	Help( ,, "HELP","", "Processo de ressarcimento deve ter número", 1, 0)
	lRet := .F.
EndIf

If lRet .and. M->Z02_TPPA == "2" .and. Empty(M->Z02_CODUSR)
	Help( ,, "HELP","", "Processo de ressarcimento deve ter titular", 1, 0)
	lRet := .F.
EndIf

If lRet .and. M->Z02_TPPA == "2" .and. Empty(M->Z02_SOLRES)
	Help( ,, "HELP","", "Processo de ressarcimento deve ter solicitante", 1, 0)
	lRet := .F.
EndIf

If lRet .and. M->Z02_TPPA == "2" .and. !Empty(M->Z02_SOLRES)
	
	dbSelectArea("SAI")
	SAI->(dbSetOrder(2)) //Filial + User
	If !dbSeek(xFilial("SAI")+M->Z02_SOLRES,.f.)
		Help( ,, "HELP","", "Processo de ressarcimento deve ter solicitante na alçada de aprovação", 1, 0)
		lRet := .F.
	EndIf
	
EndIf

Return lRet


*********************************************************************************************************************************************
*********************************************************************************************************************************************
*********************************************************************************************************************************************
Static Function MA130Commi( oModel )

Local lRet       := .T.
Local aArea      := GetArea()
Local aAreaSE2   := SE2->(GetArea())
Local aAreaZ02   := Z02->(GetArea())
Local oModelZ02  := oModel:GetModel( 'SCIA130' )
Local nOpc       := oModel:GetOperation()
Local nSumZ02    := 0

FWFormCommit( oModel )

If nOpc == 3 .or. nOpc == 4
	
	//Ao Incluir ou Alterar o mesmo sofre bloqueio....
	cQuery := " UPDATE " +RetSQLName("Z02") + " "
	cQuery += " SET Z02_STATUS = '1' "
	cQuery += " WHERE Z02_FILIAL = '" + xFilial("Z02") + "'"
	cQuery += " AND Z02_CHAVE = '" + Z02->Z02_CHAVE + "'"
	cQuery += " AND Z02_NUMRES = '" + Z02->Z02_NUMRES + "'"
	cQuery += " AND D_E_L_E_T_= '' "
	
	nRet := TcSqlExec(cQuery)
	If nRet<>0
		Alert(TCSQLERROR())
	EndIf
	
Endif

RestArea(aAreaZ02)
RestArea(aAreaSE2)
RestArea(aArea)

Return lRet


*********************************************************************************************************************************************
*********************************************************************************************************************************************
*********************************************************************************************************************************************
User Function SCI130Rep()

FwMsgRun( Nil, {|| u_SCIF040(If(Z02->Z02_TPPA $ "1", "2", "3")) }, "Processando", "Reprocessando Movimentos...")

Return()


*********************************************************************************************************************************************
*********************************************************************************************************************************************
*********************************************************************************************************************************************
User Function SCI130WF()

Local aArea    := GetArea()
Local aAreaSE2 := SE2->(GetArea())
Local aAreaZ02 := Z02->(GetArea())
Local aAreaSCR := SCR->(GetArea())
Local nSumZ02  := 0

//If Z02->Z02_STATUS == '1' //Se o Processo ainda está bloqueado
//	Alert("Processo de pagamento não aprovado.")
//    Return()
//EndIf

If !u_ChkCon(Z02->Z02_CHAVE+Z02->Z02_NUMRES)
	Return()
EndIf

cSolic := ""
cChavePro := ""

If Z02->Z02_TPPA == "1" //Prestação
	
	//Preciso somar o valor de todo o Z02 para botar na alçada....
	dbSelectArea("Z02")
	dbSetOrder(1)
	dbSeek(xFilial("Z02")+Z02->Z02_CHAVE,.f.)
	cChave := xFilial("Z02")+Z02->Z02_CHAVE
	While !EOF() .and. cChave == xFilial("Z02")+Z02->Z02_CHAVE
		nSumZ02 += Z02->Z02_VALOR
		Z02->(dbSkip())
	End
	RestArea(aAreaZ02)
	
	dbSelectArea("SE2")
	SE2->(dbSetOrder(1))
	If dbSeek(xFilial("SE2")+Z02->Z02_CHAVE,.f.)
		cSolic := SE2->E2_SOLPA
		cChavePro := Padr(     SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA), TamSX3("CR_NUM")[01]     )
	Else
		Alert("Título não encontrado. WF não enviado.")
	EndIf
	
ElseIf Z02->Z02_TPPA == "2"  //Ressarcimento
	
	//Preciso somar o valor de todo o Z02 para botar na alçada....
	dbSelectArea("Z02")
	dbSetOrder(1)
	dbSeek(xFilial("Z02")+Z02->Z02_CHAVE+Z02->Z02_NUMRES,.f.)
	cChave := xFilial("Z02")+Z02->Z02_CHAVE+Z02->Z02_NUMRES
	While !EOF() .and. cChave == xFilial("Z02")+Z02->Z02_CHAVE+Z02->Z02_NUMRES
		nSumZ02 += Z02->Z02_VALOR
		Z02->(dbSkip())
	End
	RestArea(aAreaZ02)
	
	cSolic := Z02->Z02_SOLRES
	cChavePro := Padr(	Z02->(Z02_CHAVE+Z02_NUMRES), TamSX3("CR_NUM")[01]     )
EndIf


dbSelectArea("SAI")
SAI->(dbSetOrder(2)) //Filial + User
dbSeek(xFilial("SAI")+cSolic,.f.)

dbSelectArea("SAL")
SAL->(dbSetOrder(2))
If !Empty(SAI->AI_GRUAPR) .And. SAL->(MsSeek(xFilial("SAL",cFilAnt)+SAI->AI_GRUAPR))
	
	//Antes de gerar nova alçada preciso apagar alçada anterior...
	dbSelectArea("SCR")
	dbSetOrder(1) //Filial + Tipo + Num
	If dbSeek(xFilial("SCR")+If(Z02->Z02_TPPA $ "1", "D1", "D2")+cChavePro,.f.)
		cChave := xFilial("SCR")+If(Z02->Z02_TPPA $ "1", "D1", "D2")+cChavePro
		Do While !EOF() .and. cChave == SCR->( CR_FILIAL + CR_TIPO + CR_NUM )
			
			RecLock("SCR",.F.)
			SCR->(dbDelete())
			SCR->(MsUnLock())
			
			SCR->(dbSkip())
		EndDo
		
	EndIf
	
	lFirstNiv:= .T.
	
	Do While !SAL->(Eof()) .And. xFilial("SAL",cFilAnt)+SAI->AI_GRUAPR == SAL->(AL_FILIAL+AL_COD)
		
		
		If lFirstNiv
			cAuxNivel := SAL->AL_NIVEL
			lFirstNiv := .F.
		EndIf
		
		If SAL->AL_MSBLQL == "2" //Se nao estiver bloqueado...
			Reclock("SCR",.T.)
			SCR->CR_FILIAL	:= xFilial("SCR")
			SCR->CR_NUM		:= cChavePro
			SCR->CR_TIPO	:= If(Z02->Z02_TPPA $ "1", "D1", "D2")
			SCR->CR_NIVEL	:= SAL->AL_NIVEL
			SCR->CR_USER	:= SAL->AL_USER
			SCR->CR_APROV	:= SAL->AL_APROV
			SCR->CR_STATUS	:= IIF(SAL->AL_NIVEL == cAuxNivel  ,"02","01")
			SCR->CR_TOTAL	:= nSumZ02
			SCR->CR_EMISSAO	:= Date()
			SCR->CR_MOEDA	:= 1 //SE2->E2_MOEDA
			//SCR->CR_TXMOEDA	:= 1 //SE2->E2_TXMOEDA
			
			If !Empty(SAI->AI_GRUAPR)
				SCR->CR_GRUPO := SAI->AI_GRUAPR
			EndIf
			
			SCR->(MsUnlock())
		EndIf
		
		dbSelectArea("SAL")
		SAL->(dbSkip())
	EndDo
	
	cQuery := " UPDATE " +RetSQLName("Z02") + " "
	cQuery += " SET Z02_STWF = '2', " //Enviado não aprovado...
	cQuery += "     Z02_DTWF = '"+Dtos(Date())+"',"
	cQuery += "     Z02_HRWF = '"+SubStr(Time(),1,5)+"'"
	cQuery += " WHERE Z02_FILIAL = '" + xFilial("Z02") + "'"
	cQuery += " AND Z02_CHAVE = '" + Z02->Z02_CHAVE + "'"
	cQuery += " AND Z02_NUMRES = '" + Z02->Z02_NUMRES + "'"
	cQuery += " AND D_E_L_E_T_= '' "
	
	nRet := TcSqlExec(cQuery)
	If nRet<>0
		Alert(TCSQLERROR())
	EndIf
	
	//Após criar a SCR, tenho de disparar o WF
	FwMsgRun( Nil, {|| u_SCIF011(0) }, "Processando", "Enviando WF...")
	
EndIf


RestArea(aAreaSCR)
RestArea(aAreaZ02)
RestArea(aAreaSE2)
RestArea(aArea)
Return()



*********************************************************************************************************************************************
*********************************************************************************************************************************************
*********************************************************************************************************************************************
Static Function SCIOpen( oModel )

Local lRet := .T.

//Se for alterar e está fechado
If oModel:GetOperation() == MODEL_OPERATION_UPDATE .and. Z02->Z02_STATUS == '3' //MODEL_OPERATION_DELETE
	
	Help( ,, "HELP","", "Processo fechado não pode ser alterado", 1, 0)
	lRet := .F.
EndIf

Return(lRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} SLCM420LDG

Função que retorna a carga da grid da tabela Z13

@author tiago.dantas
@since 02/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SCIA130LDG( oModel )

Local oView		:= FWViewActive()
Local oModelPai := oModel:GetModel()	// Carrega Model Master
Local oModelZ02 := oModelPai:GetModel('SCIA130M')	// Carrega Model Master
Local oModelTM	:= oModelPai:GetModel('MdGridZ02')
Local nOperation:= oModelPai:GetOperation()
Local aArea		:= GetArea()
Local aAreaZ02	:= Z02->(GetArea())
Local aRetVal	:= {}
Local cFilZ02	:= FWxFilial("Z02")
Local cChave	:= Z02->(Z02_CHAVE+Z02_NUMRES) //oModelZ02:GetValue("Z02_CHAVE") + oModelZ02:GetValue("Z02_NUMRES")
Local aCpoZ02	:= oModelTM:GetStruct():GetFields()
Local nCampo
Local aCampos   := {}
Local aAux      := {}
Local cAlias    := "Z02"

Dbselectarea(cAlias)
Dbsetorder(1)
If Z02->(dbSeek( cFilZ02+cChave  ))
	
	While !Z02->(Eof()) .And. ( Z02->(Z02_FILIAL+Z02_CHAVE+Z02_NUMRES ) == cFilZ02+cChave )
		
		For nCampo := 1 to Len(aCpoZ02)
			
			If Alltrim(aCpoZ02[nCampo][3]) == "Z02_DESNAT"
				AADD( aAux , POSICIONE( "SED", 1 , XFILIAL("SED")+Z02->Z02_NAT, "ED_DESCRIC" ) )
			ElseIf Alltrim(aCpoZ02[nCampo][3]) == "Z02_DESCC"
				AADD( aAux , POSICIONE( "CTT", 1 ,XFILIAL("CTT")+Z02->Z02_CC, "CTT_DESC01" )  )
			Else
				AADD( aAux , IIf( aCpoZ02[nCampo][4] == "D", StoD((cAlias)->&(aCpoZ02[nCampo][3])) , (cAlias)->&(aCpoZ02[nCampo][3])  ) )
			EndIf
			
		Next nCampo
		
		AADD( aAux , .T. )
		
		aAdd( aRetVal , {(cAlias)->(RECNO()), aAux} )
		aAux := {}
		Z02->(DbSkip())
	EndDo
	
EndIf

RestArea(aAreaZ02)
RestArea(aArea)
Return aRetVal


******************************************************************************************************************************************
******************************************************************************************************************************************
******************************************************************************************************************************************
User Function ChkCon(cNumChave)

Local aArea    := GetArea()
Local aAreaZ02 := Z02->(GetArea())
Local aAreaAC9 := AC9->(GetArea())
Local cAlerta  := '' //Está(ao) faltando anexo conhecimento no(s) item(ns): '
Local lRet     := .T.
Local lPri     := .T.

dbSelectArea("Z02")
dbSetOrder(1)
dbSeek(xFilial("Z02")+cNumChave,.f.) //Posiciona no primeiro item
cChave := Z02->(Z02_FILIAL+Z02_CHAVE+Z02_NUMRES)
While !EOF() .and. cChave == xFilial("Z02")+Z02->(Z02_CHAVE+Z02_NUMRES)
	
	dbSelectArea("AC9")
	dbSetOrder(2) //Filial + Entidade + Filent + CodEnt
	If !dbSeek(xFilial("AC9")+"Z02"+xFilial("Z02")+cNumChave+Z02->Z02_ITEM,.f.) //Posiciona no primeiro item
		If lPri
			cAlerta  := 'Está(ão) faltando anexo(s) conhecimento(s) no(s) item(ns): ' + Z02->Z02_ITEM + ", "
			lPri := .F.
		Else
			cAlerta += Z02->Z02_ITEM + ", "
		EndIf
	EndIf
	
	dbSelectArea("Z02")
	dbSkip()
End

If !Empty(cAlerta)
	MsgInfo(cAlerta)
	lRet := .F.
EndIf


RestArea(aAreaAC9)
RestArea(aAreaZ02)
RestArea(aArea)
Return(lRet)




*********************************************************************************************************************************************************
*********************************************************************************************************************************************************
*********************************************************************************************************************************************************
User Function A130Po()  //cAlias,nReg,nOpcx,cTipoDoc,lStatus,lResid)

Local aArea			:= GetArea()
Local aSavCols		:= {}
Local aSavHead		:= {}
Local cHelpApv		:= OemToAnsi("Este documento nao possui controle de aprovacao ou deve ser aprovado pelo controle de alçadas.") //
Local cAliasSCR		:= GetNextAlias()
Local cComprador	:= ""
Local cSituaca  	:= ""
Local cNumDoc		:= ""
Local cStatus		:= "Documento aprovado" //
Local cTitle		:= ""
Local cTitDoc		:= ""
Local cAddHeader	:= ""
Local cAprovador	:= ""
Local nSavN			:= 0
Local nX   		:= 0
Local oDlg			:= NIL
Local oGet			:= NIL
Local oBold			:= NIL
Local lExAprov		:= SuperGetMV("MV_EXAPROV",.F.,.F.)
Local lAprPCEC		:= SuperGetMV("MV_APRPCEC",.F.,.F.)
Local lAprSAEC		:= SuperGetMV("MV_APRSAEC",.F.,.F.)
Local lAprSCEC		:= SuperGetMV("MV_APRSCEC",.F.,.F.)
Local lAprCTEC		:= SuperGetMV("MV_APRCTEC",.F.,0) <> 0
Local lAprMDEC		:= SuperGetMV("MV_APRMDEC",.F.,0) <> 0
Local lCtCorp		:= .F.
Local lMdCorp		:= .F.
Local cQuery   	:= ""
Local aStruSCR 		:= SCR->(dbStruct())
Local cFilSCR 	:= xFilial("Z02")

Local cTipoDoc := If(Z02->Z02_TPPA $ "1", "D1", "D2")
Local lStatus  := .T.
Local lResid   := .F.
Local nOpcx    := 2
Local cAlias   := Alias()
Local nReg := 0

Private aCols := {}
Private aHeader := {}
Private N := 1

dbSelectArea("Z02")

cTitle  	:= "Aprovacao do Processo de Pagamentos"
cTitDoc 	:= "Processo"
cHelpApv	:= "Este processo nao possui controle de aprovacao."
cNumDoc 	:= Z02->Z02_CHAVE+Z02->Z02_NUMRES
cComprador	:= UsrRetName(Z02->Z02_SOLRES)

If !Empty(cNumDoc)
	
	aHeader:= {}
	aCols  := {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a montagem do aHeader com os campos fixos.               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//SX3->(dbSetOrder(1))
	//SX3->(MsSeek("SCR"))
	AADD(aHeader,{"Item","bCR_ITEM","",8,0,"","","C","",""} )	//
	
	OpenSxs(,,,,,"SX3TRB","SX3",,.F.)
	If Select("SX3TRB") > 0
		
		dbSelectArea('SX3TRB')
		SX3TRB->( dbSetOrder( 1 ) ) //ORDENA POR ALIAS
		SX3TRB->( dbGoTop(  ) )
		SX3TRB->( dbSeek("SCR") )
		
		While ( !Eof() .And. SX3TRB->&('X3_ARQUIVO') == "SCR" )
			
			IF AllTrim(SX3TRB->&('X3_CAMPO'))$"CR_NIVEL/CR_OBS/CR_DATALIB/" + cAddHeader
				
				If ( X3USO(SX3TRB->&('X3_USADO')) .And. cNivel >= SX3TRB->&('X3_NIVEL') )
					
					If aScan(aNoFields, AllTrim(SX3TRB->&('X3_CAMPO'))) == 0
						
						nUsado++
						Aadd(aHeader,{ TRIM(X3Titulo()),;
						TRIM(SX3TRB->&('X3_CAMPO')),;
						SX3TRB->&('X3_PICTURE'),;
						SX3TRB->&('X3_TAMANHO'),;
						SX3TRB->&('X3_DECIMAL'),;
						SX3TRB->&('X3_VALID'),;
						SX3TRB->&('X3_USADO'),;
						SX3TRB->&('X3_TIPO'),;
						SX3TRB->&('X3_ARQUIVO'),;
						SX3TRB->&('X3_CONTEXT') } )
						
						
						If AllTrim(SX3TRB->&('X3_CAMPO')) == "CR_NIVEL"
							AADD(aHeader,{ OemToAnsi("Aprovador Responsável"),"bCR_NOME",   "",15,0,"","","C","",""} )	//
							AADD(aHeader,{ OemToAnsi("Situação"),"bCR_SITUACA","",20,0,"","","C","",""} )	//
							AADD(aHeader,{ OemToAnsi("Avaliado por"),"bCR_NOMELIB","",15,0,"","","C","",""} )	//
						EndIf
						
						If AllTrim(SX3TRB->&('X3_CAMPO')) == "CR_DATALIB"
							AADD(aHeader,{ OemToAnsi("Grupo"),"bCR_GRUPO","",6,0,"","","C","",""} )	//
						EndIf
						
					EndIf
				EndIf
			EndIf
			dbSelectArea("SX3TRB")
			dbSkip()
		EndDo
		
		SX3TRB->( DbCloseArea() )
	EndIf
	
	
	ADHeadRec("SCR",aHeader)
	
	cQuery    := "SELECT SCR.*,SCR.R_E_C_N_O_ SCRRECNO FROM "+RetSqlName("SCR")+" SCR "
	cQuery    += "WHERE SCR.CR_FILIAL='"+cFilSCR+"' AND "
	cQuery    += "SCR.CR_NUM = '"+Padr(cNumDoc,Len(SCR->CR_NUM))+"' AND "
	
	If Z02->Z02_TPPA $ "1"
		cQuery += "   CR_TIPO	  = 'D1' AND "
	Else
		cQuery += "   CR_TIPO	  = 'D2' AND "
	EndIf
	If lExAprov .And. lResid	// Exibe registros deletados quando MV_EXAPROV estiver ativo e houver itens eliminados como residuo
		cQuery    += " "
	Else
		cQuery    += " SCR.D_E_L_E_T_=' ' "
	EndIf
	
	cQuery += "ORDER BY "+SqlOrder(SCR->(IndexKey()))
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSCR)
	
	For nX := 1 To Len(aStruSCR)
		If aStruSCR[nX][2]<>"C"
			TcSetField(cAliasSCR,aStruSCR[nX][1],aStruSCR[nX][2],aStruSCR[nX][3],aStruSCR[nX][4])
		EndIf
	Next nX
	
	While !(cAliasSCR)->(Eof())
		aAdd(aCols,Array(Len(aHeader)+1))
		
		For nX := 1 to Len(aHeader)
			If IsHeadRec(aHeader[nX][2])
				aTail(aCols)[nX] := (cAliasSCR)->SCRRECNO
			ElseIf IsHeadAlias(aHeader[nX][2])
				aTail(aCols)[nX] := "SCR"
			ElseIf aHeader[nX][02] == "bCR_NOME"
				aTail(aCols)[nX] := UsrRetName((cAliasSCR)->CR_USER)
			ElseIf aHeader[nX][02] == "bCR_ITEM"
				If lAprPCEC .Or. lAprSAEC .Or. lAprSCEC .Or. lAprCTEC .Or. lAprMDEC
					If (cAliasSCR)->CR_TIPO $ "SC|SA|IP|IC|IM"
						aTail(aCols)[nX] := AllTrim((cAliasSCR)->DBM_ITEM) + IIF(!Empty((cAliasSCR)->DBM_ITEMRA),"-"+(cAliasSCR)->DBM_ITEMRA,"")
					Else
						aTail(aCols)[nX] := Replicate("-",8)
					Endif
				Endif
			ElseIf aHeader[nX][02] == "bCR_GRUPO"
				aTail(aCols)[nX] := (cAliasSCR)->CR_GRUPO
			ElseIf aHeader[nX][02] == "bCR_SITUACA"
				Do Case
					Case (cAliasSCR)->CR_STATUS == "01"
						cSituaca := OemToAnsi("Pendente em níveis anteriores") //
						If cStatus == "Documento aprovado" //
							cStatus := "Aguardando liberação(ões)" //
						EndIf
					Case (cAliasSCR)->CR_STATUS == "02"
						cSituaca := OemToAnsi("Pendente") //
						If cStatus == "Documento aprovado" //
							cStatus := "Aguardando liberação(ões)" //
						EndIf
					Case (cAliasSCR)->CR_STATUS == "03"
						cSituaca := OemToAnsi("Aprovado") //
					Case (cAliasSCR)->CR_STATUS == "04"
						cSituaca := OemToAnsi("Bloqueado") //
						If cStatus # "Documento aprovado" //
							cStatus := "Documento bloqueado" //
						EndIf
					Case (cAliasSCR)->CR_STATUS == "05"
						cSituaca := OemToAnsi("Aprovado/rejeitado pelo nível") //
					Case (cAliasSCR)->CR_STATUS == "06"
						cSituaca := "Rejeitado"	//
						If cStatus # "Documento rejeitado" //
							cStatus := "Documento rejeitado" //
						EndIf
				EndCase
				
				If cTipoDoc == "SC" .AND. !((lExAprov .AND. !lResid) .OR. !lExAprov)
					If (cAliasSCR)->(FieldPos("C1_RESIDUO"))>0 .AND. !Empty((cAliasSCR)->C1_RESIDUO)
						cStatus		:= "Elim.Resíduo/" + cStatus // + Status
						cSituaca 	:= "Elim.Resíduo/" + cSituaca // + Situação
					EndIf
				ElseIf cTipoDoc == "IP" .AND. !((lExAprov .AND. !lResid) .OR. !lExAprov)
					If (cAliasSCR)->(FieldPos("C7_RESIDUO"))>0 .AND. !Empty((cAliasSCR)->C7_RESIDUO)
						cStatus		:= "Elim.Resíduo/" + cStatus //"Elim.Resíduo/" + Status
						cSituaca 	:= "Elim.Resíduo/" + cSituaca //"Elim.Resíduo/" + Situação
					EndIf
				EndIf
				
				aTail(aCols)[nX] := cSituaca
			ElseIf aHeader[nX][02] == "bCR_NOMELIB"
				aTail(aCols)[nX] := UsrRetName((cAliasSCR)->CR_USERLIB)
			ElseIf Alltrim(aHeader[nX][02]) == "CR_OBS"//Posicionar para ler
				SCR->(dbGoto((cAliasSCR)->SCRRECNO))
				aTail(aCols)[nX] := SCR->CR_OBS
			ElseIf ( aHeader[nX][10] != "V")
				aTail(aCols)[nX] := FieldGet(FieldPos(aHeader[nX][2]))
			EndIf
		Next nX
		aTail(aCols)[Len(aHeader)+1] := .F.
		
		(cAliasSCR)->(dbSkip())
	EndDo
	
	If !Empty(aCols)
		n:=	 IIF(n > Len(aCols), Len(aCols), n)  // Feito isto p/evitar erro fatal(Array out of Bounds).
		DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
		DEFINE MSDIALOG oDlg TITLE cTitle From 109,095 To 400,600 OF oMainWnd PIXEL	 //"Aprovacao do Pedido de Compra // Contrato"
		@ 005,003 TO 032,250 LABEL "" OF oDlg PIXEL
		If !(cTipoDoc $ "MD|RV|CT|IC|IM")
			@ 015,007 SAY cTitDoc OF oDlg FONT oBold PIXEL SIZE 046,009 // "Pedido" / "Contrato" / "Nota Fiscal"
			@ 014,041 MSGET cNumDoc PICTURE "" WHEN .F. PIXEL SIZE 150,009 OF oDlg FONT oBold
			If cTipoDoc <> "NF"
				@ 015,095 SAY OemToAnsi("Comprador") OF oDlg PIXEL SIZE 045,009 FONT oBold //
				@ 014,138 MSGET cComprador PICTURE "" WHEN .F. of oDlg PIXEL SIZE 103,009 FONT oBold
			EndIF
		Else
			@ 015,007 SAY cTitDoc OF oDlg FONT oBold PIXEL SIZE 046,009 // "Medicao"
			@ 014,035 MSGET cNumDoc PICTURE "" WHEN .F. PIXEL SIZE 50,009 OF oDlg FONT oBold
			
			@ 015,095 SAY cAprovador OF oDlg PIXEL SIZE 045,009 FONT oBold //"Aprovador"
			@ 014,138 MSGET cComprador PICTURE "" WHEN .F. of oDlg PIXEL SIZE 103,009 FONT oBold
		EndIf
		
		@ 132,008 SAY 'Situacao :' OF oDlg PIXEL SIZE 052,009 //
		@ 132,038 SAY cStatus OF oDlg PIXEL SIZE 120,009 FONT oBold
		@ 132,205 BUTTON 'Fechar' SIZE 035 ,010  FONT oDlg:oFont ACTION (oDlg:End()) OF oDlg PIXEL  //
		oGet:= MSGetDados():New(038,003,120,250,nOpcx,,,"")
		oGet:Refresh()
		@ 126,002 TO 127,250 LABEL "" OF oDlg PIXEL
		ACTIVATE MSDIALOG oDlg CENTERED
	Else
		Aviso("Atencao","Este Documento nao possui controle de aprovacao.",{"Voltar"})
	EndIf
	
	(cAliasSCR)->(dbCloseArea())
	
	If lStatus
		aHeader := aClone(aSavHead)
		aCols := aClone(aSavCols)
		N := nSavN
	EndIf
Else
	Aviso("Atencao","Este Documento nao possui controle de aprovacao.",{"Voltar"})
EndIf

dbSelectArea(cAlias)
RestArea(aArea)

Return NIL



******************************************************************************************************************************************
******************************************************************************************************************************************
******************************************************************************************************************************************
User Function SCI130An()

Local aArea    := GetArea()
Local aAreaZ02 := Z02->(GetArea())
Local aAreaAC9 := AC9->(GetArea())

MsDocument('Z02',Z02->(RecNo()), 4)

//Ao Incluir ou Alterar o mesmo sofre bloqueio....
cQuery := " UPDATE " +RetSQLName("Z02") + " "
cQuery += " SET Z02_STATUS = '1' "
cQuery += " WHERE Z02_FILIAL = '" + xFilial("Z02") + "'"
cQuery += " AND Z02_CHAVE = '" + Z02->Z02_CHAVE + "'"
cQuery += " AND Z02_NUMRES = '" + Z02->Z02_NUMRES + "'"
cQuery += " AND D_E_L_E_T_= '' "

nRet := TcSqlExec(cQuery)
If nRet<>0
	Alert(TCSQLERROR())
EndIf

RestArea(aAreaAC9)
RestArea(aAreaZ02)
RestArea(aArea)
Return()

******************************************************************************************************************************************
******************************************************************************************************************************************
******************************************************************************************************************************************
User Function ChkCon1(cNumChave)

Local aArea    := GetArea()
Local aAreaZ02 := Z02->(GetArea())
Local aAreaAC9 := AC9->(GetArea())
Local cAlerta  := '' //Está(ao) faltando anexo conhecimento no(s) item(ns): '
Local lRet     := '1' //nao tem  '2' tem anexo   //.T.
Local lPri     := .T.

dbSelectArea("Z02")
dbSetOrder(1)
dbSeek(xFilial("Z02")+cNumChave,.f.) //Posiciona no primeiro item
cChave := Z02->(Z02_FILIAL+Z02_CHAVE+Z02_NUMRES)
While !EOF() .and. cChave == xFilial("Z02")+Z02->(Z02_CHAVE+Z02_NUMRES)
	
	dbSelectArea("AC9")
	dbSetOrder(2) //Filial + Entidade + Filent + CodEnt
	If !dbSeek(xFilial("AC9")+"Z02"+xFilial("Z02")+cNumChave+Z02->Z02_ITEM,.f.) //Posiciona no primeiro item
		If lPri
			cAlerta  := 'Está(ão) faltando anexo(s) conhecimento(s) no(s) item(ns): ' + Z02->Z02_ITEM + ", "
			lPri := .F.
		Else
			cAlerta += Z02->Z02_ITEM + ", "
		EndIf
	EndIf
	
	dbSelectArea("Z02")
	dbSkip()
End

If !Empty(cAlerta)
	//MsgInfo(cAlerta)
	lRet := '1' //.F.
Else
	lRet := '2' //.F.
	
EndIf


RestArea(aAreaAC9)
RestArea(aAreaZ02)
RestArea(aArea)
Return(lRet)
