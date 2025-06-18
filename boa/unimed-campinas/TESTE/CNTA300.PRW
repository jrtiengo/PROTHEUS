#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CNTA300.CH"
#INCLUDE "GCTXDEF.CH"
#INCLUDE "CRMDEF.CH"
#INCLUDE 'FWLIBVERSION.CH'
#INCLUDE "FWEDITPANEL.CH"

//-- Declaração de Variáveis Estáticas
Static cTipRevisa	:= ''
Static cAprTipRev	:= ''
Static cModel		:= 'CNTA300'
Static cContrat		:= ''
Static lRevisado	:= .F.
Static lUserBut		:= .F.
Static lAdiant		:= .F.
Static lDelCrg		:= .F.
Static lDelSFA		:= .F.
Static aLineCNF		:= {}
Static aDelsCNF		:= {}
Static aDelsCNS		:= {}
Static aDelsCNW		:= {}
Static aDelsCNV		:= {}
Static aVldUsr		:= {}
Static aIncArt		:= {}
Static __cGestOld   := ""
Static lLGPD		:= FindFunction("SuprLGPD") .And. SuprLGPD()
Static lCN300RST    := ExistBlock("CN300RST")
Static lPEVLSC		:= ExistBlock("A300VLSC")
Static _lC100VLAT	:= ExistBlock("C100VLAT")
Static lCposVlPre	:= Nil
Static _lVlPreCtb	:= Nil
Static _aCTBEnt		:= Nil
Static _oC7PreSta	:= Nil
Static _oPlaProps	:= Nil
Static _oViewTabs	:= Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CNTA300
Programa de manutenção de Contratos. 

@author Leandro.Moura
@since 23/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CNTA300(aAddFil,nOpcAuto,xRotAuto)
Local oBrowse	:= Nil
Private cCadastro := STR0076 //Manutencao de Contratos
Private aRotina := Menudef()
Private aAddFilB:= {}
Default aAddFil := {}

aAddFilB := aAddFil

If ValType(xRotAuto) <> "A"
	//-- Atalho para config. dos parametros
	//-- mv_par01 - Mostra Lancamentos: S/N
	//-- mv_par02 - Aglut Lancamentos:  S/N
	//-- mv_par03 - Lancamentos Online: S/N
	SetKey(VK_F12,{|| Pergunte("CNT100",.T.)})
	Pergunte("CNT100",.F.)
	oBrowse := BrowseDef()
	//oBrowse:SetMainProc('CNTA300')
	oBrowse:Activate()
	//-- Limpa atalho
	SetKey(VK_F12,Nil)
Else
	FWMVCRotAuto(ModelDef(),"CN9",nOpcAuto,xRotAuto)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author Andrews Egas
@since 21/03/2016
@version P12/MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse as object
Local aCoresLeg	 := {}
Local nX        := 0
Local cRevAlc	:= ""
Local cCondInt	:= ""
Local cCondApr	:= ""
Local cCn100Fil	:= ""
Local lIntPims	:= SuperGetMV('MV_CNXPIMS',.F.,.F.)

cCondInt	:= " .And. CN300RetSt('INTPIMS',,,,CN9->CN9_FILIAL,.F.) .And. CnPimsTpSt(CN9->CN9_NUMERO,CN9->CN9_REVISA,CN9->CN9_FILIAL)"
cCondApr	:= " .And. (Empty(CN9->CN9_APROV) .OR. !ExistSCR2('RV',CN9->(CN9_NUMERO+CN9_REVISA),CN9->CN9_FILCTR))"
cRevAlc 	:= " .Or. (Alltrim(CN9->CN9_SITUAC) == '09' .And. !Empty(CN9->CN9_APROV)) "

If lIntPims
	aadd(aCoresLeg,{"Alltrim(CN9->CN9_SITUAC) $ '02|05|'"+cCondInt+" == 'P4'",	"GCTPIMSE.PNG", 	STR0268})	// Falha de integração com o PIMS
	aadd(aCoresLeg,{"Alltrim(CN9->CN9_SITUAC) $ '05'"	 +cCondInt+" == 'P2'",	"GCTPIMSV.PNG",  	STR0266})	// Vigente integrado com o PIMS
EndIf

//-- Define legendas
aadd(aCoresLeg,{"Alltrim(CN9->CN9_SITUAC) == '01'",                     "RED",    	STR0001})	// Cancelado
aadd(aCoresLeg,{"Alltrim(CN9->CN9_SITUAC) == '02'",                     "YELLOW", 	STR0002})	// Em Elaboracao
aadd(aCoresLeg,{"Alltrim(CN9->CN9_SITUAC) == '03'",                     "BLUE",   	STR0003})	// Emitido
aadd(aCoresLeg,{"Alltrim(CN9->CN9_SITUAC) == '04'",                     "ORANGE", 	STR0004})	// Em Aprovacao
aadd(aCoresLeg,{"AllTrim(CN9->CN9_SITUAC) == '11'",						"BR_CANCEL",STR0198}) 	// Rejeitado
aadd(aCoresLeg,{"Alltrim(CN9->CN9_SITUAC) == '05'",                     "GREEN",  	STR0005})	// Vigente
aadd(aCoresLeg,{"Alltrim(CN9->CN9_SITUAC) == '06'",                     "GRAY",   	STR0006})	// Paralisado
aadd(aCoresLeg,{"Alltrim(CN9->CN9_SITUAC) == '07'",                     "BROWN",  	STR0007})	// Sol. Finalizacao
aadd(aCoresLeg,{"Alltrim(CN9->CN9_SITUAC) == '08'",                     "BLACK",  	STR0008})	// Finalizado
aadd(aCoresLeg,{"Alltrim(CN9->CN9_SITUAC) == '09'"+cCondApr, 			"PINK",   	STR0009})	// Revisao
aadd(aCoresLeg,{"Alltrim(CN9->CN9_SITUAC) == 'A' "+cRevAlc,				"VIOLET",	STR0199})	// Revisão - Aprovação por Alçadas
aadd(aCoresLeg,{"Alltrim(CN9->CN9_SITUAC) == '10'",                     "WHITE", 	STR0010})	// Revisado

//-- Ponto de Entrada - CN100COR - Inclusao de legenda
If ExistBlock("CN100COR")
	aCoresLeg := CN300COR(aCoresLeg)
EndIf

//-- Instanciamento da Classe de Browse
oBrowse := FWMBrowse():New()
oBrowse:SetImpTXT(.F.)
oBrowse:SetAlias('CN9')
oBrowse:SetDescription(STR0076)	//-- Manutenção de Contratos
If (ValType(aCoresLeg) == "A")
	For nX := 1 to Len(aCoresLeg) STEP 1
		If(Len(aCoresLeg[nX]) >= 3)
			oBrowse:addLegend(aCoresLeg[nX][1],aCoresLeg[nX][2],aCoresLeg[nX][3])
		EndIf
	Next nX
EndIf

//-- Filtros adicionais do Browse
If Type('aAddFilB') <> "U"
	For nX := 1 To Len( aAddFilB )
		oBrowse:DeleteFilter( aAddFilB[nX][ADDFIL_ID] )
		oBrowse:AddFilter(aAddFilB[nX][ADDFIL_TITULO], ;
							aAddFilB[nX][ADDFIL_EXPR], ;
							aAddFilB[nX][ADDFIL_NOCHECK], ;
							aAddFilB[nX][ADDFIL_SELECTED], ;
							aAddFilB[nX][ADDFIL_ALIAS], ;
							aAddFilB[nX][ADDFIL_FILASK], ;
							aAddFilB[nX][ADDFIL_FILPARSER], ;
							aAddFilB[nX][ADDFIL_ID] )
		oBrowse:ExecuteFilter()
	Next nX
EndIf

//-- Ponto de Entrada - CN100COR - Inclusao de legenda
If ExistBlock("CN100COR")
	CN300COR(@oBrowse)
EndIf

//-- Filtra Browse
If ExistBlock("CN100FIL")
	cCn100Fil := ExecBlock("CN100FIL",.F.,.F.)
	If ValType(cCn100Fil) == "C" .And. !Empty(cCn100Fil)
		oBrowse:SetFilterDefault(cCn100Fil)
	EndIf
EndIf

Return oBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional
@return aRotina - Estrutura
@return			n,1 - Nome a aparecer no cabecalho
@return			n,2 - Nome da Rotina associada
@return			n,3 - Reservado
@return			n,4 - Tipo de Transação a ser efetuada:
@return				1 - Pesquisa e Posiciona em um Banco de Dados
@return				2 - Simplesmente Mostra os Campos
@return				3 - Inclui registros no Bancos de Dados
@return				4 - Altera o registro corrente
@return				5 - Remove o registro corrente do Banco de Dados
@return				6 - Alteração sem inclusão de registros
@return				7 - Cópia
@return			n,5 - Nivel de acesso
@return			n,6 - Habilita Menu Funcional

@author Leandro.Moura
@since 23/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotInc 	:= {}
Local aRotRev 	:= {}//sub-menu tipos de revisão
Local lRevCauc	:= SuperGetMV("MV_CNRVCAU",.F.,.F.)
Local lIntPims	:= SuperGetMV('MV_CNXPIMS',.F.,.F.)
Local nOpInc 	:= Iif(VerSenha(57),57,76) //Permissão de inclusão
Local nOpAlt 	:= Iif(VerSenha(58),58,77) //Permissão de alteração
Local nOpExc 	:= Iif(VerSenha(59),59,78) //Permissão de exclusão

Private aRotina := {}

ADD OPTION aRotInc TITLE STR0011	ACTION "CN300InCOM"	OPERATION MODEL_OPERATION_INSERT	ACCESS nOpInc		//-- Compra
ADD OPTION aRotInc TITLE STR0012	ACTION "CN300InVEN"	OPERATION MODEL_OPERATION_INSERT	ACCESS nOpInc		//-- Venda
//Sub-Menu Tipos de Revisão disponibilizado no Menu Ações Relacionadas
ADD OPTION aRotRev TITLE STR0100 	ACTION "CN300RAdit"		OPERATION OP_COPIA   ACCESS 0 ID DEF_REV_ADITI 	//-- Aditivo
ADD OPTION aRotRev TITLE STR0101 	ACTION "CN300RReaj"		OPERATION OP_COPIA   ACCESS 0 ID DEF_REV_REAJU 	//-- Reajuste
ADD OPTION aRotRev TITLE STR0102 	ACTION "CN300RReal"		OPERATION OP_COPIA   ACCESS 0 ID DEF_REV_REALI 	//-- Realinhamento
ADD OPTION aRotRev TITLE STR0103 	ACTION "CN300RRead"		OPERATION OP_COPIA   ACCESS 0 ID DEF_REV_READE 	//-- Readequação
ADD OPTION aRotRev TITLE STR0104 	ACTION "CN300RPara"		OPERATION OP_COPIA   ACCESS 0 ID DEF_REV_PARAL 	//-- Paralisação
ADD OPTION aRotRev TITLE STR0105 	ACTION "CN300RRein"		OPERATION OP_COPIA   ACCESS 0 ID DEF_REV_REINI 	//-- Reinício
ADD OPTION aRotRev TITLE STR0106 	ACTION "CN300RClau"		OPERATION OP_COPIA   ACCESS 0 ID DEF_REV_CLAUS 	//-- Alteração de Cláusulas
ADD OPTION aRotRev TITLE STR0107 	ACTION "CN300RCont"		OPERATION OP_COPIA   ACCESS 0 ID DEF_REV_CONTA 	//-- Contábil
ADD OPTION aRotRev TITLE STR0108 	ACTION "CN300RIndi"		OPERATION OP_COPIA   ACCESS 0 ID DEF_REV_INDIC 	//-- Índice
ADD OPTION aRotRev TITLE STR0109 	ACTION "CN300RForn"		OPERATION OP_COPIA   ACCESS 0 ID DEF_REV_FORCL 	//-- Troca de Fonecedor
ADD OPTION aRotRev TITLE STR0122	ACTION "CN300RGApr"		OPERATION OP_COPIA   ACCESS 0 ID DEF_REV_GRAPR 	//-- Grupos de Aprovação
ADD OPTION aRotRev TITLE STR0186	ACTION "CN300RReno"		OPERATION OP_COPIA   ACCESS 0 ID DEF_REV_RENOV 	//-- Renovação
ADD OPTION aRotRev TITLE STR0200	ACTION "CN300RMult"		OPERATION OP_COPIA   ACCESS 0 ID DEF_REV_MULBON //-- Multa/Bonificação
ADD OPTION aRotRev TITLE STR0309	ACTION "CN300RAber"		OPERATION OP_COPIA   ACCESS 0 ID DEF_REV_ABERT 	//-- Aberta

If lRevCauc
	ADD OPTION aRotRev TITLE STR0029	ACTION "CN300RCauc"		OPERATION OP_COPIA   ACCESS 0 ID DEF_REV_CAUCA 	//-- Revisão de Caução
EndIf
ADD OPTION aRotina TITLE STR0013	ACTION "CN300Visua"		OPERATION MODEL_OPERATION_VIEW		ACCESS 0		//-- Visualizar
ADD OPTION aRotina TITLE STR0014	ACTION aRotInc			OPERATION MODEL_OPERATION_INSERT	ACCESS nOpInc 	//-- Incluir
ADD OPTION aRotina TITLE STR0015	ACTION "CN300Alter"		OPERATION MODEL_OPERATION_UPDATE	ACCESS nOpAlt 	//-- Alterar
ADD OPTION aRotina TITLE STR0016	ACTION "CN300Delet"		OPERATION MODEL_OPERATION_DELETE	ACCESS nOpExc 	//-- Excluir
ADD OPTION aRotina TITLE STR0017	ACTION "CN100Situac"	OPERATION MODEL_OPERATION_UPDATE	ACCESS nOpAlt	//-- Situacao
ADD OPTION aRotina TITLE STR0018	ACTION "CN220Aval"		OPERATION MODEL_OPERATION_UPDATE	ACCESS nOpAlt	//-- Aval. Fornecedores
ADD OPTION aRotina TITLE STR0019	ACTION "CN240Acesso"	OPERATION MODEL_OPERATION_UPDATE	ACCESS nOpAlt	//-- Acesso
ADD OPTION aRotina TITLE STR0020	ACTION "CN300Docum"		OPERATION MODEL_OPERATION_UPDATE	ACCESS nOpAlt	//-- Conhecimento
ADD OPTION aRotina TITLE STR0021	ACTION "CN100CtrRet"	OPERATION MODEL_OPERATION_UPDATE	ACCESS nOpAlt	//-- Bx. Retenção
ADD OPTION aRotina TITLE STR0077	ACTION "CN100EstBx"  	OPERATION MODEL_OPERATION_UPDATE	ACCESS nOpAlt	//-- Est. Retenção
ADD OPTION aRotina TITLE STR0027	ACTION "CN300CtrAdia"	OPERATION MODEL_OPERATION_UPDATE	ACCESS nOpAlt	//-- Adiantamentos
ADD OPTION aRotina TITLE STR0099	ACTION aRotRev			OPERATION MODEL_OPERATION_UPDATE	ACCESS nOpAlt	//-- Tipos de Revisão
ADD OPTION aRotina TITLE STR0110	ACTION "CN300Aprov" 	OPERATION MODEL_OPERATION_UPDATE	ACCESS nOpAlt	//-- Aprovar Revisão
ADD OPTION aRotina TITLE STR0201	ACTION "CN300DesRv"		OPERATION MODEL_OPERATION_DELETE	ACCESS nOpAlt  	//-- Desfazer Revisão

If lIntPims
ADD OPTION aRotina TITLE STR0270	ACTION "CnPimsShwE()"	OPERATION MODEL_OPERATION_VIEW		ACCESS nOpAlt 	//-- "Exibir falha de integração com o PIMS"
EndIf

If ExistBlock("CTA100MNU")
	ExecBlock("CTA100MNU",.F.,.F.)
EndIf
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Rotina para integração EAI

@author Israel.Escorizza
@since 09/02/2018
/*/
//-------------------------------------------------------------------
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage, cVersion)
Local  aRet	:= 	CNTI300( cXML, nTypeTrans, cTypeMessage, cVersion)
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Rotina para montagem do model da manutenção de contratos

@author 	Leandro.Moura
@since 		23/09/2013
@version 	P11.90
@return 	oModel , modelo de dados de um contrato
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel		:= NIL
Local oStruCN9		:= FWFormStruct(1,'CN9')
Local oStruCNC		:= FWFormStruct(1,'CNC')
Local oStruCN8		:= FWFormStruct(1,'CN8')
Local oStruCNI		:= FWFormStruct(1,'CNI')
Local oStruCNA		:= FWFormStruct(1,'CNA')
Local oStruCNB		:= FWFormStruct(1,'CNB')
Local oStruCXM		:= FWFormStruct(1,'CXM')
Local oStruCNF		:= FWFormStruct(1,'CNF')
Local oStruCNH		:= FWFormStruct(1,'CNH')
Local oStruCNK		:= FWFormStruct(1,'CNK')
Local oStruCNX		:= FWFormStruct(1,'CNX')
Local oStruCNU		:= FWFormStruct(1,'CNU')
Local oStruCPD		:= FWFormStruct(1,'CPD')
Local oStruCNZ		:= FWFormStruct(1,'CNZ')
Local oStruCNS		:= FWFormStruct(1,'CNS')
Local oStruCNN		:= FWFormStruct(1,'CNN')
Local oStruCNV		:= FWFormStruct(1,'CNV')
Local oStruCNW		:= FWFormStruct(1,'CNW')
Local oStruCNT		:= FWFormStruct(1,'CNT')
Local oStruCNG		:= FWFormStruct(1,'CNG')
Local oStruAGW		:= FWFormStruct(1,'AGW')
Local oStruCXI		:= FWFormStruct(1,'CXI')
Local oStruCXL		:= FWFormStruct(1,'CXL')
Local oStruCXO		:= Nil
Local oStruCXP		:= Nil
Local oStruCXN		:= FWFormStruct(1,'CXN')

Local cVisuMed      := SuperGetMV("MV_CTRMED",.F.,"1") //Define a Visualização das Medições e Pedidos
Local lExibeMed		:= (cVisuMed $ "12")
Local oStruTCNS		:= FWFormModelStruct():New()
Local bPreVldCN9	:= {|oModel,cAction,cField,xValue| CN300CN9Pre(oModel,cAction,cField,xValue)}
Local bPreVldPl		:= {|oModelGrid,nLine,cAction,cField,xValue,xOldValue| CN300PItPre(oModelGrid,nLine,cAction,cField,xValue,xOldValue)}
Local bPreVlCTB		:= {|oModelGrid,nLine,cAction,cField,xValue| CN300CtbPre(oModelGrid,nLine,cAction,cField,xValue)}
Local bPreVlCBA		:= {|oModelGrid,nLine,cAction,cField,xValue,xOldValue| CN300CtAPre(nLine,cAction,cField,xValue,xOldValue,oModelGrid)}
Local bPreCNA		:= {|oModelGrid,nLine,cAction,cField,xValue,xOldValue| CN300CNAPre(nLine,cAction,cField,xValue,xOldValue,oModelGrid)}
Local bPreCNB		:= {|oModelGrid,nLine,cAction,cField,xValue,xOldValue| CN300CNBPre(nLine,cAction,cField,xValue,xOldValue,oModelGrid)}
Local bPreVlRCI		:= {|oModelGrid,nLine,cAction,cField,xValue,xOldValue| CN300RatPre(nLine,cAction,cField,xValue,xOldValue,oModelGrid)}
Local bPreVlCXM		:= {|oModelGrid,nLine,cAction,cField,xValue,xOldValue| CN300PrCXM(oModelGrid,nLine,cAction,cField,xValue,xOldValue)}
Local bPosVlCXM		:= {|oModelGrid,nLine,cAction| CN300PsCXM(oModelGrid,nLine)}
Local bPreVlCXO		:= Nil
Local bPreVlCXP		:= Nil
Local bPreVlCNF		:= {|oModelGrid,nLine,cAction,cField, xValue,xOldValue| CN300PVCNF(oModelGrid,cAction, nLine, cField, xValue,xOldValue)}

Local aCamposCXP	:= {"CXP_CC","CXP_CONTA","CXP_ITEMCT","CXP_CLVL"}
Local aCTBEnt		:= CTBEntArr()
Local nX			:= 0
Local nPosGatFor    := 0
Local nPosGatCli    := 0

Local lCompra		:= CNTGetFun() <> "CNTA301"
Local lA300STRU     := ExistBlock("A300STRU")
Local lVlPresent	:= CposVlPres()

Local cFilSB5 		:= xFilial("SB5")
Local aTriggers      := {}
Local aRelatCNU		:= {}

oStruCXO		:= FWFormStruct(1,'CXO')
oStruCXP		:= FWFormStruct(1,'CXP')
bPreVlCXO		:= {|oModelGrid,nLine,cAction,cField,xValue,xOldValue| MNatPreCXO("CNTA300",oModelGrid,nLine,cAction,cField,xValue,xOldValue)}
bPreVlCXP		:= {|oModelGrid,nLine,cAction,cField,xValue,xOldValue| MNatPreCXP("CNTA300",oModelGrid,nLine,cAction,cField,xValue,xOldValue)}

If Type("INCLUI") <> "L"
	INCLUI := .F.
Endif

//Gera Array de Controle de Acesso
If !INCLUI .And. (FunName() == 'CNTA300' .Or. FunName() == "RPC")
	aVldUsr := CN300VldUsr()
ElseIf INCLUI
	aVldUsr := {}
EndIf

//-- Seta propriedade do campo CNA_CONTRA
oStruCNA:SetProperty('CNA_CONTRA',MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"FwFldGet('CN9_NUMERO')"))
oStruCXM:SetProperty('CXM_CONTRA',MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"FwFldGet('CN9_NUMERO')"))
oStruCXI:SetProperty('CXI_TIPO'  ,MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"Space(TamSx3('CXI_TIPO')[1])"))

oStruCNB:SetProperty("CNB_QUANT" ,MODEL_FIELD_VALID,MTBlcVld("CNB","CNB_QUANT"	,"CN300VlQtd(d,e) .And. A300CalcVl(a) .And. cn300vlMod() .And. CN300VlQMd() .And. Cn300AtuSld()",.F.,.F.) )
oStruCNB:SetProperty("CNB_VLUNIT",MODEL_FIELD_VALID,MTBlcVld("CNB","CNB_VLUNIT"	,"A300VlrCNB(b,c,e) .And. CN300VlPrc(d,e) .And. A300CalcVl(a)",.F.,.F.) )
oStruCNB:SetProperty("CNB_DESC"  ,MODEL_FIELD_VALID,MTBlcVld("CNB","CNB_DESC"	,"A300VlrCNB(b,c,e) .And. CN300VlDes(d,e)",.F.,.F.) )
oStruCNB:SetProperty("CNB_PEDTIT",MODEL_FIELD_VALID,MTBlcVld("CNB","CNB_PEDTIT" ,"VldPdTitCT(a,c)",.F.,.F.,.T.) )
oStruCNS:SetProperty("CNS_PRVQTD",MODEL_FIELD_VALID,MTBlcVld("CNS","CNS_PRVQTD"	,"CN110FsVld(e, a)",.F.,.F.) )
oStruCN9:SetProperty("CN9_TIPREV",MODEL_FIELD_VALID,MTBlcVld("CN9","CN9_TIPREV"	,"ExistCpo('CN0', c) .And. cn300VldTpR()",.F.,.T.) )
oStruCN9:SetProperty("CN9_GESTC" ,MODEL_FIELD_VALID,MTBlcVld("CN9","CN9_GESTC"  ,"CNTGestVld(c)",.F.,.F.,.T.) )
oStruCXM:SetProperty("CXM_VLMAX" ,MODEL_FIELD_VALID,{|a,b,c,d,e| FWInitCpo(a,b,c,d),lRet := Positivo() .And. A300VldVMax(a,b,c,d,e),FWCloseCpo(a,b,c,lRet,.T.),lRet})

oStruCN9:AddTrigger('CN9_FLGREJ', 'CN9_FLGREJ', {|| .T. }, {|| CN300ProRe('CN9') }  )

oStruCNZ:AddTrigger('CNZ_PERC', 'CNZ_VALOR1', {|| .T. }, {|a,b,c|Cn121AtuRat(Nil, c,.T.)})
oStruCNZ:SetProperty("CNZ_PERC", MODEL_FIELD_VALID, MTBlcVld("CNZ","CNZ_PERC", "A121VldPerc(a,c,e,d)", .F., .F.))
aEval({'CNZ_VALOR1', 'CNZ_VALOR2', 'CNZ_VALOR3', 'CNZ_VALOR4', 'CNZ_VALOR5' }, {|x| oStruCNZ:SetProperty(x, MODEL_FIELD_WHEN, {||.F.} ) })

oStruCN9:SetProperty("CN9_DTINIC",MODEL_FIELD_WHEN,{|| oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetModel("CN9MASTER"):GetValue("CN9_SITUAC") == '02' })

oStruCNA:SetProperty("CNA_VLTOT" ,MODEL_FIELD_WHEN,FwBuildFeature( STRUCT_FEATURE_WHEN	,"CN300WTot()"))
oStruCNF:SetProperty('CNF_VLPREV',MODEL_FIELD_WHEN,FwBuildFeature( STRUCT_FEATURE_WHEN	,"!Cn300RetSt('FISICO')"))

If oStruCNX:HasField('CNX_CHEQUE') .And. lCompra
	oStruCNX:SetProperty('CNX_CHEQUE',MODEL_FIELD_OBRIGAT,.T.)
EndIf

oStruTCNS:AddTable("   ",{" "}," ")

//-- Adiciona campos header do cronograma fisico
oStruTCNS:AddField(STR0046,;									// 	[01]  C   Titulo do campo
					 STR0048,;									// 	[02]  C   ToolTip do campo
					 "TCNS_PARC",;								// 	[03]  C   Id do Field
					 "C",;										// 	[04]  C   Tipo do campo
					 TamSX3("CNF_PARCEL")[1],;					// 	[05]  N   Tamanho do campo
					 0,;										// 	[06]  N   Decimal do campo
					 NIL,;										// 	[07]  B   Code-block de validação do campo
					 NIL,;										// 	[08]  B   Code-block de validação When do campo
					 NIL,;										//	[09]  A   Lista de valores permitido do campo
					 .F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 {|| FWFldGet("CNF_PARCEL")},;				//	[11]  B   Code-block de inicializacao do campo
					 NIL,;										//	[12]  L   Indica se trata-se de um campo chave
					 .T.,;										//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.)										// 	[14]  L   Indica se o campo é virtual

oStruTCNS:AddField(	STR0054,;									// 	[01]  C   Titulo do campo
					STR0055,;									// 	[02]  C   ToolTip do campo
					"TCNS_VTOT",;								// 	[03]  C   Id do Field
					"N",;										// 	[04]  C   Tipo do campo
					TamSX3("CNF_VLPREV")[1],;					// 	[05]  N   Tamanho do campo
					TamSX3("CNF_VLPREV")[2],;					// 	[06]  N   Decimal do campo
					NIL,;										// 	[07]  B   Code-block de validação do campo
					NIL,;										// 	[08]  B   Code-block de validação When do campo
					NIL,;										//	[09]  A   Lista de valores permitido do campo
					.F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
					{|| FWFldGet("CNF_VLPREV")},;				//	[11]  B   Code-block de inicializacao do campo
					NIL,;										//	[12]  L   Indica se trata-se de um campo chave
					.T.,;										//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.)										// 	[14]  L   Indica se o campo é virtual

//-- Adiciona campos de arrasto e redistribuição de saldos para o cronograma contábil
oStruCN9:AddField(	STR0144,;																	// 	[01]  C   Titulo do campo	//"Arrasto"
					STR0144,;																	// 	[02]  C   ToolTip do campo
					"CN9_ARRASC",;																// 	[03]  C   Id do Field
					"C",;																		// 	[04]  C   Tipo do campo
					1,;																			// 	[05]  N   Tamanho do campo
					0,;																			// 	[06]  N   Decimal do campo
					FwBuildFeature( STRUCT_FEATURE_VALID,"Pertence('12') .And. CN300VArrC()"),;	// 	[07]  B   Code-block de validação do campo
					{||.T.},;																	// 	[08]  B   Code-block de validação When do campo
					{STR0147,STR0148},;															//	[09]  A   Lista de valores permitido do campo
					.F.,;																		//	[10]  L   Indica se o campo tem preenchimento obrigatório
					FwBuildFeature( STRUCT_FEATURE_INIPAD, "'2'" ),;							//	[11]  B   Code-block de inicializacao do campo
					NIL,;																		//	[12]  L   Indica se trata-se de um campo chave
					.F.,;																		//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.)																		// 	[14]  L   Indica se o campo é virtual


oStruCN9:AddField(	STR0145,;													// 	[01]  C   Titulo do campo	//"Redist. Val."
					STR0146,;													// 	[02]  C   ToolTip do campo	//"Redistribuição de Valores"
					"CN9_REDVAC",;												// 	[03]  C   Id do Field
					"C",;														// 	[04]  C   Tipo do campo
					1,;															// 	[05]  N   Tamanho do campo
					0,;															// 	[06]  N   Decimal do campo
					FwBuildFeature( STRUCT_FEATURE_VALID,"Pertence('12')"),;	// 	[07]  B   Code-block de validação do campo
					{||.T.},;													// 	[08]  B   Code-block de validação When do campo
					{STR0147,STR0148},;											//	[09]  A   Lista de valores permitido do campo	//{'1=Sim','2=Não'}
					.F.,;														//	[10]  L   Indica se o campo tem preenchimento obrigatório
					FwBuildFeature( STRUCT_FEATURE_INIPAD, "'2'" ),;			//	[11]  B   Code-block de inicializacao do campo
					NIL,;														//	[12]  L   Indica se trata-se de um campo chave
					.F.,;														//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.)														// 	[14]  L   Indica se o campo é virtual

oStruCN9:AddField( ;
	                AllTrim(STR0241) ,		 ; 									// [01] C Titulo do campo // 'Automação'
	                AllTrim('') , ; 											// [02] C ToolTip do campo
	                'CN9_AUTO' , ;              								// [03] C identificador (ID) do Field
	                'C' , ;                     								// [04] C Tipo do campo
	                1 , ;                      									// [05] N Tamanho do campo
	                NIL , ;														// [06] N Decimal do campo
	                NIL , ;                     								// [07] B Code-block de validação do campo
	                NIL , ;                     								// [08] B Code-block de validação When do campo
	                NIL , ;                     								// [09] A Lista de valores permitido do campo
	                NIL , ;                     								// [10] L Indica se o campo tem preenchimento obrigatório
	                FwBuildFeature( STRUCT_FEATURE_INIPAD, "'0'" ) ,;			// [11] B Code-block de inicializacao do campo
	                NIL , ;                     								// [12] L Indica se trata de um campo chave
	                NIL , ;                     								// [13] L Indica se o campo pode receber valor em uma operação de update.
	                .T. )

oStruCXN:AddField(	STR0183,;													// 	[01]  C   Titulo do campo
				 	STR0183,;													// 	[02]  C   ToolTip do campo
				 	"CXN_FILDES",;												// 	[03]  C   Id do Field
				 	"C",;														// 	[04]  C   Tipo do campo
				 	40,;														// 	[05]  N   Tamanho do campo
				 	0,;															// 	[06]  N   Decimal do campo
				 	NIL,;														// 	[07]  B   Code-block de validação do campo
				 	NIL,;														// 	[08]  B   Code-block de validação When do campo
				 	NIL,;														//	[09]  A   Lista de valores permitido do campo
				 	.F.,;														//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 	{|| AllTrim(Left(FWFilialName(,CXN->CXN_FILIAL,1),40))},;	//	[11]  B   Code-block de inicializacao do campo
				 	NIL,;														//	[12]  L   Indica se trata-se de um campo chave
				 	.T.,;														//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 	.T.)														// 	[14]  L   Indica se o campo é virtual

oStruCNN:SetProperty( "CNN_CONTRA", MODEL_FIELD_OBRIGAT, .F. )

oStruCNB:AddTrigger("CNB_PRODUT" /*cIdField*/, "CNB_TIPO" /*cTargetIdField*/, {|| .T.} /*bPre*/, {|| Posicione("SB5", 1, cFilSB5 + FwFldGet("CNB_PRODUT"), "B5_TIPO")} /*bSetValue*/)

If lVlPresent .Or. ValPresCtb() //Valor Presente no Cronogram Financeiro OU no Cronograma Contabil
	ConfVlPres(oStruCN9, oStruCNF, oStruCNW) //Configura campos de valor presente nos structs
EndIf

oModel := MPFormModel():New('CNTA300',/*bPreValid*/,{|oModel| CN300TOK(oModel)},{|oModel| CN300GRV(oModel)},{|oModel| CN300CANCE(oModel)}/*bCancel*/)
oModel:AddFields('CN9MASTER',/*cOwner*/,oStruCN9,bPreVldCN9,/*bPosValid*/,/*Carga*/)

//-- Adiciona Grids
oModel:AddGrid('CNCDETAIL','CN9MASTER',oStruCNC,{|oModel,nLine,cAction,cField,xValue,xOldValue| CN300VldFor(cAction,cField,xValue,xOldValue)})
oModel:AddGrid('CN8DETAIL','CN9MASTER',oStruCN8)
oModel:AddGrid('CNIDETAIL','CN8DETAIL',oStruCNI)
oModel:AddGrid('CNADETAIL','CN9MASTER',oStruCNA,bPreVlCBA,{|oModelGrid|CN300VldPlan(1,.T.,oModelGrid)},bPreCNA)
oModel:AddGrid('CNBDETAIL','CNADETAIL',oStruCNB,bPreVldPl,{|oModelGrid|CN300VldPlan(2,.T.,oModelGrid)},bPreCNB)
oModel:AddGrid('CXMDETAIL','CNADETAIL',oStruCXM,bPreVlCXM, bPosVlCXM)
oModel:AddGrid('CNFDETAIL','CNADETAIL',oStruCNF,bPreVlCNF)
oModel:AddGrid('CXIDETAIL','CNADETAIL',oStruCXI,,{|oModelGrid| CN300PVlCXI(oModelGrid)})
oModel:AddGrid('CNHDETAIL','CN9MASTER',oStruCNH)
oModel:AddGrid('CNKDETAIL','CN9MASTER',oStruCNK)
oModel:AddGrid('CNXDETAIL','CN9MASTER',oStruCNX, {|oModel,nLine,cAction,cField, xValue, xOldValue| CN300PVCNX(oModel, cAction, nLine, cField, xValue, xOldValue)}, )
oModel:AddGrid('CNUDETAIL','CN9MASTER',oStruCNU,,{|oMdlCNU| CN300VldVen(oMdlCNU)})
oModel:AddGrid('CPDDETAIL','CNADETAIL',oStruCPD)
oModel:AddGrid('CNZDETAIL','CNBDETAIL',oStruCNZ,bPreVlRCI,{|x| CNZPosVld(x)})
oModel:AddGrid('CXODETAIL','CNADETAIL',oStruCXO,bPreVlCXO,{|oModelGrid| MNatPosCXO(.T.,oModelGrid)})
oModel:AddGrid('CXPDETAIL','CXODETAIL',oStruCXP,bPreVlCXP,{|oModelGrid| MNatPosCXP(.T.,oModelGrid)})
oModel:AddFields('CALC_CNS','CNFDETAIL',oStruTCNS,,,{|| {"",""}})
oModel:AddGrid('CNSDETAIL','CNFDETAIL',oStruCNS)
oModel:AddGrid('CNNDETAIL','CN9MASTER',oStruCNN)
oModel:AddGrid('CNVDETAIL','CNADETAIL',oStruCNV)
oModel:AddGrid('CNWDETAIL','CNVDETAIL',oStruCNW,bPreVlCTB)
oModel:AddGrid('CNTDETAIL','CN9MASTER',oStruCNT)
oModel:AddGrid('CNGDETAIL','CN9MASTER',oStruCNG)
oModel:AddGrid('AGWDETAIL','CN9MASTER',oStruAGW)
oModel:AddGrid('CXLDETAIL','CN9MASTER',oStruCXL)

//- Adiciona valor maximo de linhas da grid
oModel:GetModel('CNBDETAIL'):SetMaxLine( GetNewPar("MV_COMLMAX", 99999) )

oModel:GetModel("CALC_CNS"):SetDescription(STR0064) //-- Dados do cronograma físico

//-- Seta UniqueLine
oModel:GetModel('CNCDETAIL'):SetUniqueLine({"CNC_CODIGO","CNC_LOJA","CNC_CLIENT","CNC_LOJACL"})
oModel:GetModel('CN8DETAIL'):SetUniqueLine({"CN8_CODIGO"})
oModel:GetModel('CNADETAIL'):SetUniqueLine({"CNA_NUMERO"})
oModel:GetModel('CNBDETAIL'):SetUniqueLine({"CNB_ITEM"})
oModel:GetModel('CNFDETAIL'):SetUniqueLine({"CNF_NUMERO","CNF_PARCEL"})
oModel:GetModel('CNHDETAIL'):SetUniqueLine({"CNH_CODIGO"})
oModel:GetModel('CNKDETAIL'):SetUniqueLine({"CNK_CODIGO"})
oModel:GetModel('CNXDETAIL'):SetUniqueLine({"CNX_NUMERO"})
oModel:GetModel('CNUDETAIL'):SetUniqueLine({"CNU_CODVD"})
oModel:GetModel('CPDDETAIL'):SetUniqueLine({"CPD_FILAUT","CPD_NUMPLA"})
oModel:GetModel('CNSDETAIL'):SetUniqueLine({"CNS_ITEM"})
oModel:GetModel('CNNDETAIL'):SetUniqueLine({"CNN_USRCOD","CNN_GRPCOD","CNN_TRACOD"})
oModel:GetModel('CNVDETAIL'):SetUniqueLine({"CNV_NUMERO","CNV_REVISA"})
oModel:GetModel('CNWDETAIL'):SetUniqueLine({"CNW_PARCEL"})
oModel:GetModel('CNTDETAIL'):SetUniqueLine({"CNT_NUMMED"})
oModel:GetModel('CXMDETAIL'):SetUniqueLine({"CXM_AGRTIP","CXM_AGRGRP","CXM_AGRCAT"})

oModel:GetModel('CXODETAIL'):SetUniqueLine({"CXO_NATURE"})

For nX := 1 To Len(aCTBEnt)
	If CXP->(FieldPos("CXP_EC" +aCTBEnt[nX] +"CR")) > 0
		aAdd(aCamposCXP,"CXP_EC" +aCTBEnt[nX] +"CR")
		aAdd(aCamposCXP,"CXP_EC" +aCTBEnt[nX] +"DB")
	EndIf
Next nX

oModel:GetModel('CXPDETAIL'):SetUniqueLine(aCamposCXP)

//-- Define relação entre os grids
oModel:SetRelation('CNCDETAIL',{{'CNC_FILIAL','xFilial("CNC")'},{'CNC_NUMERO','CN9_NUMERO'},{'CNC_REVISA','CN9_REVISA'}},CNC->(IndexKey(1)))
oModel:SetRelation('CN8DETAIL',{{'CN8_FILIAL','xFilial("CN8")'},{'CN8_CONTRA','CN9_NUMERO'}},CN8->(IndexKey(2)))
oModel:SetRelation('CNADETAIL',{{'CNA_FILIAL','xFilial("CNA")'},{'CNA_CONTRA','CN9_NUMERO'},{'CNA_REVISA','CN9_REVISA'}},CNA->(IndexKey(1)))
oModel:SetRelation('CNBDETAIL',{{'CNB_FILIAL','xFilial("CNB")'},{'CNB_CONTRA','CN9_NUMERO'},{'CNB_REVISA','CN9_REVISA'},{"CNB_NUMERO","CNA_NUMERO"}},CNB->(IndexKey(1)))
oModel:SetRelation('CXMDETAIL',{{'CXM_FILIAL','xFilial("CXM")'},{'CXM_CONTRA','CN9_NUMERO'},{'CXM_REVISA','CN9_REVISA'},{"CXM_NUMERO","CNA_NUMERO"}},CXM->(IndexKey(1)))
oModel:SetRelation('CXIDETAIL',{{'CXI_FILIAL','xFilial("CXI")'},{'CXI_CONTRA','CN9_NUMERO'},{'CXI_REVISA','CN9_REVISA'},{"CXI_NUMPLA","CNA_NUMERO"}},CXI->(IndexKey(1)))
oModel:SetRelation('CNFDETAIL',{{'CNF_FILIAL','xFilial("CNF")'},{'CNF_CONTRA','CN9_NUMERO'},{'CNF_REVISA','CN9_REVISA'},{"CNF_NUMPLA","CNA_NUMERO"}},"CNF_PARCEL")
oModel:SetRelation('CNHDETAIL',{{'CNH_FILIAL','xFilial("CNH")'},{'CNH_NUMERO','CN9_NUMERO'},{'CNH_REVISA','CN9_REVISA'}},CNH->(IndexKey(3)))
oModel:SetRelation('CNKDETAIL',{{'CNK_FILIAL','xFilial("CNK")'},{'CNK_CONTRA','CN9_NUMERO'}},CNK->(IndexKey(3)))
oModel:SetRelation('CNXDETAIL',{{'CNX_FILIAL','xFilial("CNX")'},{'CNX_CONTRA','CN9_NUMERO'}},CNX->(IndexKey(3)))

aRelatCNU := {{'CNU_FILIAL','xFilial("CNU")'},{'CNU_CONTRA','CN9_NUMERO'}}

If CNURevisa()
	aAdd(aRelatCNU,{'CNU_REVISA', 'CN9_REVISA'})
EndIf
oModel:SetRelation('CNUDETAIL', aRelatCNU, CNU->(IndexKey(1)))

oModel:SetRelation('CNIDETAIL',{{'CNI_FILIAL','xFilial("CNI")'},{'CNI_CODIGO','CN8_CODIGO'}},CNI->(IndexKey(1)))
oModel:SetRelation('CPDDETAIL',{{'CPD_FILIAL','xFilial("CPD")'},{'CPD_CONTRA','CN9_NUMERO'},{'CPD_NUMPLA', 'CNA_NUMERO'}},CPD->(IndexKey(1)))
oModel:SetRelation('CNZDETAIL',{{'CNZ_FILIAL','xFilial("CNZ")'},{'CNZ_CONTRA','CN9_NUMERO'},{'CNZ_REVISA','CN9_REVISA'},{'CNZ_CODPLA','CNA_NUMERO'},{'CNZ_ITCONT','CNB_ITEM'},{'CNZ_NUMMED','Criavar("CNZ_NUMMED",.F.)'}},CNZ->(IndexKey(1)))
oModel:SetRelation('CNSDETAIL',{{'CNS_FILIAL','xFilial("CNS")'},{'CNS_CONTRA','CN9_NUMERO'},{'CNS_REVISA','CN9_REVISA'},{'CNS_CRONOG','CNF_NUMERO'},{'CNS_PARCEL','CNF_PARCEL'},{'CNS_PLANI','CNA_NUMERO'}},CNS->(IndexKey(1)))
oModel:SetRelation('CNNDETAIL',{{'CNN_FILIAL','xFilial("CNN")'},{'CNN_CONTRA','CN9_NUMERO'}},CNN->(IndexKey(1)))
oModel:SetRelation('CNVDETAIL',{{'CNV_FILIAL','xFilial("CNV")'},{'CNV_CONTRA','CN9_NUMERO'},{'CNV_REVISA','CN9_REVISA'},{"CNV_PLANIL","CNA_NUMERO"}},CNV->(IndexKey(1)))
oModel:SetRelation('CNWDETAIL',{{'CNW_FILIAL','xFilial("CNW")'},{'CNW_CONTRA','CN9_NUMERO'},{'CNW_REVISA','CN9_REVISA'},{"CNW_NUMERO","CNV_NUMERO"}},CNW->(IndexKey(1)))
oModel:SetRelation('CNTDETAIL',{{'CNT_FILIAL','xFilial("CNT")'},{'CNT_CONTRA','CN9_NUMERO'}},CNT->(IndexKey(1)))
oModel:SetRelation('CNGDETAIL',{{'CNG_FILIAL','xFilial("CNG")'},{'CNG_CONTRA','CN9_NUMERO'}},CNG->(IndexKey(1)))
oModel:SetRelation('AGWDETAIL',{{'AGW_FILIAL','xFilial("AGW")'},{'AGW_CONTRA','CN9_NUMERO'}},AGW->(IndexKey(1)))
oModel:SetRelation('CXLDETAIL',{{'CXL_FILIAL','xFilial("CXL")'},{'CXL_CONTRA','CN9_NUMERO'}},CXL->(IndexKey(1)))

oModel:SetRelation('CXODETAIL',{{'CXO_FILIAL','xFilial("CXO")'},{'CXO_CONTRA','CN9_NUMERO'},{'CXO_REVISA','CN9_REVISA'},{'CXO_NUMMED','Space(TamSx3("CXO_NUMMED")[1])'},{'CXO_NUMPLA','CNA_NUMERO'}},CXO->(IndexKey(1)))
oModel:SetRelation('CXPDETAIL',{{'CXP_FILIAL','xFilial("CXP")'},{'CXP_CONTRA','CN9_NUMERO'},{'CXP_REVISA','CN9_REVISA'},{'CXP_NUMMED','Space(TamSx3("CXO_NUMMED")[1])'},{'CXP_NUMPLA','CNA_NUMERO'},{'CXP_ITMNAT','CXO_ITEM'}},CXP->(IndexKey(1)))

If lExibeMed //Deve exibir medicoes, caso contrario não carrega os dados no modelo
	ConfCNDMdl(oModel, cVisuMed, lCompra) //Caso deva exibir as medicoes(CNDDETAIL), configura no objeto <oModel>		
EndIf

oModel:SetPrimaryKey({"CN9_FILIAL","CN9_NUMERO","CN9_REVISA"})

//-- Modelos de preenchimento opcional
oModel:GetModel('CNUDETAIL'):SetOptional(.T.)
oModel:GetModel('CNCDETAIL'):SetOptional(.T.)
oModel:GetModel('CN8DETAIL'):SetOptional(.T.)
oModel:GetModel('CNIDETAIL'):SetOptional(.T.)
oModel:GetModel('CNADETAIL'):SetOptional(.T.)
oModel:GetModel('CNBDETAIL'):SetOptional(.T.)
oModel:GetModel('CXMDETAIL'):SetOptional(.T.)
oModel:GetModel('CXIDETAIL'):SetOptional(.T.)
oModel:GetModel('CNFDETAIL'):SetOptional(.T.)
oModel:GetModel('CNHDETAIL'):SetOptional(.T.)
oModel:GetModel('CNKDETAIL'):SetOptional(.T.)
oModel:GetModel('CNXDETAIL'):SetOptional(.T.)
oModel:GetModel('CPDDETAIL'):SetOptional(.T.)
oModel:GetModel('CNZDETAIL'):SetOptional(.T.)
oModel:GetModel('CNSDETAIL'):SetOptional(.T.)
oModel:GetModel('CNNDETAIL'):SetOptional(.T.)
oModel:GetModel('CNVDETAIL'):SetOptional(.T.)
oModel:GetModel('CNWDETAIL'):SetOptional(.T.)
oModel:GetModel('CNTDETAIL'):SetOptional(.T.)
oModel:GetModel('CNGDETAIL'):SetOptional(.T.)
oModel:GetModel('AGWDETAIL'):SetOptional(.T.)
oModel:GetModel('CXLDETAIL'):SetOptional(.T.)

oModel:GetModel('CXODETAIL'):SetOptional(.T.)
oModel:GetModel('CXPDETAIL'):SetOptional(.T.)

//Submodelos que não serão gravados, utilizados apenas para consulta
oModel:GetModel('CN8DETAIL'):SetOnlyQuery(.T.)
oModel:GetModel('CXLDETAIL'):SetOnlyQuery(.T.)

//-- Desabilita alteracoes nas grids que são somente leitura
CNTA300BlMd(oModel:GetModel('CN8DETAIL'),.T.)
CNTA300BlMd(oModel:GetModel('CNIDETAIL'),.T.)
CNTA300BlMd(oModel:GetModel('CNKDETAIL'),.T.)
CNTA300BlMd(oModel:GetModel('CNXDETAIL'),.T.)
CNTA300BlMd(oModel:GetModel('CNTDETAIL'),.T.)
CNTA300BlMd(oModel:GetModel('CNGDETAIL'),.T.)
CNTA300BlMd(oModel:GetModel('AGWDETAIL'),.T.)
CNTA300BlMd(oModel:GetModel('CXMDETAIL'),.T.)

//-- Desabilita inclusao na tabela de reajuste para evitar chave duplicada
oModel:GetModel('CXLDETAIL'):SetOnlyQuery(.T.)

//-- Desabilita inclusão e exclusão de linhas nos cronogramas
oModel:GetModel('CNFDETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('CNFDETAIL'):SetNoDeleteLine(.T.)
oModel:GetModel('CNSDETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('CNSDETAIL'):SetNoDeleteLine(.T.)
oModel:GetModel('CNVDETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('CNVDETAIL'):SetNoDeleteLine(.T.)
oModel:GetModel('CNWDETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('CNWDETAIL'):SetNoDeleteLine(.T.)

//-- Campos totalizadores
oModel:AddCalc('CALC_CNF','CNADETAIL','CNFDETAIL','CNF_VLPREV','CNF_CALC','SUM',,,STR0079) //-- Montante do Cronograma
oModel:AddCalc('CALC_CNZ','CNBDETAIL','CNZDETAIL','CNZ_PERC','CNZ_TOTRAT','SUM',,,RetTitle("CNZ_PERC"))

If lVlPresent//Apenas se existirem os campos de valor presente.
	oModel:AddCalc('CALC_CNF','CNADETAIL','CNFDETAIL','CNF_VLPRES','CNF_TVPRES','SUM',,, STR0307)//Valor Presente
	oModel:AddCalc('CALC_CNF','CNADETAIL','CNFDETAIL','CNF_VJUROS','CNF_TJUROS','SUM',,, STR0308)//Desp Financeira
EndIf
//-- Utiliza o conceito de aHeader e aCols para uso de funções do CNTA100
oModel:GetModel('CN8DETAIL'):SetUseOldGrid(.T.)

aTriggers := oModel:GetModel('CNADETAIL'):GetStruct():GetTriggers()
nPosGatFor := aScan(aTriggers, {|x| AllTrim(x[1]) == "CNA_FORNEC" .And. AllTrim(x[2]) == "CNA_LJFORN" })
nPosGatCli := aScan(aTriggers, {|x| AllTrim(x[1]) == "CNA_CLIENT" .And. AllTrim(x[2]) == "CNA_LOJACL" })

If nPosGatFor > 0 //Desabilita gatilho do campo CNA_LJFORN
    aTriggers[nPosGatFor][3] := {|| .F.}
EndIf

If nPosGatCli > 0 //Desabilita gatilho do campo CNA_LOJACL
    aTriggers[nPosGatCli][3] := {|| .F.}
EndIf

//-- Validacao na ativacao do Model
oModel:SetVldActivate({|oModel| CN300VldAc(oModel)})
oModel:SetActivate({|oModel| CN300Activ(oModel)})
oModel:SetDeActivate({|oModel| CN300DeAct(oModel)})

If CNTGetFun() <> 'CNTA301'
	CNTSetFun("CNTA300")
EndIf

If Alltrim(CN9->CN9_SITUAC) $ '09|A' .And. FWIsInCallStack("Cn300Delet")
	oModel:bPost := {|oModel|Cn300TOK(oModel)}
EndIf

oModel:SetOnDemand(.T.)

If cPaisLoc == "RUS"
	oModelEvent 	:= CNTA300EventRUS():New()
	oModel:InstallEvent("oModelEvent", /*cOwner*/, oModelEvent)
EndIf

If lA300STRU
	ExecBlock( "A300STRU", .F., .F., { "MODELDEF", IIF(CNTGetFun() == "CNTA301", "V","C"), @oModel } )
EndIf

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Rotina para montagem da view da manutenção de contratos

@author Leandro.Moura
@since 23/09/2013
@version P11.90
@return	oView , view do contrato
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel	:= Nil
	Local oView		:= FWFormView():New()

	//Lista de campo variáveis de acordo com o tipo de Contrato(Compra ou Venda)
	Local cCampoCN8	:= ""
	Local cCampoCNA	:= ""
	Local cCampoCNB	:= ""
	Local cCampoCNC	:= ""
	Local cCampoCNX	:= ""

	//- Listagem de campos para cada modelo (Finalizar string com '|')
	Local cCampoCN9	:= "CN9_VLREAJ|CN9_NUMTIT|CN9_VLMEAC|CN9_TXADM|CN9_FORMA|CN9_DTENTR|CN9_LOCENT|CN9_CODENT|CN9_DESLOC|CN9_DESFIN|CN9_CONTFI|CN9_DTINPR|CN9_PERPRO|CN9_UNIPRO|CN9_VLRPRO|CN9_DTINCP|CN9_FILCTR|CN9_CODCLA|CN9_CODJUS|CN9_CODOBJ|CN9_MPLA|CN9_CSLD|"
	Local cCampoCND	:= "CND_CONTRA|CND_REVISA|CND_PARCEL|CND_CLIENT|CND_FORNEC|CND_LJFORN|CND_LOJACL|CND_CONDPG|CND_DESCCP|CND_VLCONT|CND_VLGER|CND_NUMERO|CND_TIPPLA|CND_DESCTP|CND_PARC1|CND_DATA1|CND_PARC2|CND_DATA2|CND_PARC3|CND_DATA3|CND_PARC4|CND_DATA4|CND_AUTFRN|CND_PEDIDO|CND_RESID|CND_SERVIC|CND_REVGER|CND_ULTMED|CND_FILCTR|CND_ULTMED|CND_RECMED|CND_MEDRET|CND_RETIFI|CND_VLMPED|CND_VLBPED|"
	Local cCampoCNF	:= "CNF_CONTRA|CNF_REVISA|CNF_MAXPAR|CNF_PERANT|CNF_PERIOD|CNF_DIAPAR|CNF_CONDPG|CNF_NUMPLA|"
	Local cCampoCNH	:= "CNH_REVISA|"
	Local cCampoCNK	:= "CNK_CONTRA|CNK_OBS|"
	Local cCampoCNS	:= "CNS_CONTRA|CNS_REVISA|CNS_CRONOG|CNS_PLANI|CNS_PARCEL|CNS_ITOR|"
	Local cCampoCNT	:= "CNT_CONTRA|CNT_CLIENT|CNT_LOJACL|"
	Local cCampoCNV	:= "CNV_CONTRA|CNV_REVISA|CNV_PLANIL|"
	Local cCampoCNW	:= "CNW_CONTRA|CNW_REVISA|CNW_NUMERO|CNW_DTLANC|CNW_MAXPAR|"
	Local cCampoCNZ	:= "CNZ_CONTRA|CNZ_CODPLA|CNZ_REVISA|CNZ_NUMMED|CNZ_FORNEC|CNZ_LJFORN|CNZ_CLIENT|CNZ_LOJACL|CNZ_ITCONT|"
	Local cCampoCXN	:= "CXN_NUMMED|CXN_PARCEL|CXN_CRONOG|CXN_CRONCT|CXN_PARCEL|CXN_DTINI|CXN_DTFIM|CXN_VLPREV|CXN_VLMULT|CXN_VLLIQD|CXN_VLBONI|CXN_VLDESC|CXN_VLTOT|CXN_VLCOMS|CXN_VLREAJ|CXN_VLRADT|CXN_DTVENC|"
	Local cCampoCXM	:= "CXM_CONTRA|CXM_NUMERO|CXM_REVISA|CXM_FILIAL|CXM_VLMED|"
	Local cCampoCXO	:= "CXO_FILIAL|CXO_NUMMED|CXO_CONTRA|CXO_REVISA|CXO_NUMPLA|"
	Local cCampoCXP	:= "CXP_FILIAL|CXP_CONTRA|CXP_NUMMED|CXP_REVISA|CXP_NUMPLA|CXP_ITMNAT|"
	Local cCampoCNU := "CNU_CONTRA|CNU_REVISA|"
	Local oStruCN8		:= Nil
	Local oStruCNA		:= Nil
	Local oStruCNB		:= Nil
	Local oStruCNC		:= Nil
	Local oStruCNX		:= Nil
	Local oStruCNU		:= Nil
	//- Preparação de estruturas da View
	Local oStruCN9		:= FWFormStruct(2,'CN9', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCN9})
	Local oStruCND		:= FWFormStruct(2,'CND', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCND})
	Local oStruCNF		:= FWFormStruct(2,'CNF', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCNF})
	Local oStruCNH		:= FWFormStruct(2,'CNH', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCNH})
	Local oStruCNI		:= Nil
	Local oStruCNK		:= Nil
	Local oStruCNS		:= FWFormStruct(2,'CNS', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCNS})
	Local oStruCNT		:= Nil
	Local oStruCNV		:= FWFormStruct(2,'CNV', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCNV})
	Local oStruCNW		:= FWFormStruct(2,'CNW', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCNW})
	Local oStruCNZ		:= FWFormStruct(2,'CNZ', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCNZ})	
	Local oStruCXL		:= Nil
	Local oStruCXN		:= FWFormStruct(2,'CXN', {|cCampo|  AllTrim(cCampo)+'|' $ cCampoCXN})
	Local oStruCXM		:= FWFormStruct(2,'CXM', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCXM})
	Local oStruCXO		:= Nil
	Local oStruCXP		:= Nil
	Local oStruSC7		:= FWFormStruct(2,'SC7')
	Local oStruSC5		:= Nil

	Local oStruTCNS		:= FWFormViewStruct():New()
	Local oCalcCNF 		:= Nil
	Local oCalcCNZ  	:= Nil
	Local cOper			:= ''	
	Local lFisico 		:= Cn300RetSt("FISICO",		1)
	Local lMedeve		:= Cn300RetSt("MEDEVE",		1)
	Local lFixo			:= Cn300RetSt("FIXO",		1)

	Local lVisuCau		:= .T.
	Local lVisuPla		:= .T.
	Local lVisuCro		:= .T.
	Local lVisuDoc		:= .T.
	Local lVisuAll		:= .F.
	
	Local aAux			:= {}
	Local aCampoCTB		:= {}
	Local nX			:= 0
	Local lA300STRU     := ExistBlock("A300STRU")
	Local lCtrVenda 	:= (CNTGetFun() == 'CNTA301')
	Local cFoldIdPla	:= ""
	Local aUsrButton	:= {}
	Local cBtnDescr		:= ""
	Local bBtnAction	:= {||}

	If !lCtrVenda
		oModel		:= FWLoadModel("CNTA300")
		cCampoCN8	:= "CN8_CONTRA|CN8_REVISA|CN8_CLIENT|CN8_LOJACL|CN8_NOMCLI|"
		cCampoCNA	:= "CNA_CONTRA|CNA_REVISA|CNA_CRONCT|CNA_CLIENT|CNA_CRONOG|CNA_ESPEL|CNA_DTMXMD|CNA_CRONCT|CNA_LOJACL|"
		cCampoCNB	:= "CNB_CONTRA|CNB_NUMERO|CNB_REVISA|CNB_REALI|CNB_DTREAL|CNB_DTANIV|CNB_CONORC|CNB_DTCAD|CNB_RATEIO|CNB_TIPO|CNB_ITSOMA|CNB_PERC|CNB_FILHO|CNB_PRCORI|CNB_SLDREC|CNB_QTDORI|CNB_QTRDAC|CNB_QTRDRZ|CNB_QTREAD|CNB_VLREAD|CNB_VLRDGL|CNB_PERCAL|CNB_FLGCMS|CNB_TS|CNB_IDENT|CNB_VLTOTR|CNB_PROXRJ|"
		cCampoCNC	:= "CNC_CODED|CNC_NUMPR|CNC_REVISA|CNC_CLIENT|CNC_NOMECL|CNC_LOJACL|"		
		cCampoCNX	:= "CNX_NUMMED|CNX_NUMTIT|CNX_PREFIX|CNX_CLIENT|CNX_CONTRA|CNX_LOJACL|"			
	Else
		oModel		:= FWLoadModel("CNTA301")
		cCampoCN8	:= "CN8_CONTRA|CN8_REVISA|CN8_FORNEC|CN8_LOJA|CN8_NOME|"
		cCampoCNA	:= "CNA_CONTRA|CNA_REVISA|CNA_CRONCT|CNA_FORNEC|CNA_LJFORN|CNA_CRONOG|CNA_ESPEL|CNA_DTMXMD|CNA_CRONCT|CNA_VLCOMS|"
		cCampoCNB	:= "CNB_CONTRA|CNB_NUMERO|CNB_REVISA|CNB_REALI|CNB_DTREAL|CNB_DTANIV|CNB_CONORC|CNB_DTCAD|CNB_RATEIO|CNB_TIPO|CNB_ITSOMA|CNB_PERC|CNB_FILHO|CNB_PRCORI|CNB_SLDREC|CNB_QTDORI|CNB_QTRDAC|CNB_QTRDRZ|CNB_QTREAD|CNB_VLREAD|CNB_VLRDGL|CNB_PERCAL|CNB_FLGCMS|CNB_TE|CNB_NUMSC|CNB_NUMSC|CNB_ITEMSC|CNB_IDENT|CNB_VLTOTR|CNB_PROXRJ|"
		cCampoCNC	:= "CNC_NUMERO|CNC_CODIGO|CNC_CODED|CNC_NUMPR|CNC_REVISA|CNC_NOME|CNC_LOJA|"		
		cCampoCNX	:= "CNX_NUMMED|CNX_NUMTIT|CNX_PREFIX|CNX_FORNEC|CNX_CONTRA|CNX_LJFORN|CNX_CHEQUE|"
	EndIf
	
	oStruCNA := FWFormStruct(2,'CNA', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCNA})
	oStruCNB := FWFormStruct(2,'CNB', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCNB})
	oStruCNC := FWFormStruct(2,'CNC', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCNC})
	oCalcCNZ := FWCalcStruct(oModel:GetModel('CALC_CNZ'))
	oCalcCNF := FWCalcStruct(oModel:GetModel('CALC_CNF'))
	
	//-- Adiciona campos header do cronograma fisico
	oStruTCNS:AddField(	"TCNS_PARC",;						// [01]  C   Nome do Campo
							"01",;							// [02]  C   Ordem
							STR0046,;						// [03]  C   Titulo do campo	//"Parcela"
							STR0048,;						// [04]  C   Descricao do campo	//"Parcela do Cronograma"
							NIL,;							// [05]  A   Array com Help
							"C",;							// [06]  C   Tipo do campo
							"",;							// [07]  C   Picture
							NIL,;							// [08]  B   Bloco de Picture Var
							NIL,;							// [09]  C   Consulta F3
							.F.,;							// [10]  L   Indica se o campo é alteravel
							NIL,;							// [11]  C   Pasta do campo
							NIL,;							// [12]  C   Agrupamento do campo
							NIL,;							// [13]  A   Lista de valores permitido do campo (Combo)
							NIL,;							// [14]  N   Tamanho maximo da maior opção do combo
							NIL,;							// [15]  C   Inicializador de Browse
							.T.,;							// [16]  L   Indica se o campo é virtual
							NIL,;							// [17]  C   Picture Variavel
							NIL)							// [18]  L   Indica pulo de linha após o campo

	oStruTCNS:AddField(	"TCNS_VTOT",;							// [01]  C   Nome do Campo
							"02",;								// [02]  C   Ordem
							STR0054,;							// [03]  C   Titulo do campo	//"Valor Total"
							STR0055,;							// [04]  C   Descricao do campo	//"Valor Total da Parcela"
							NIL,;								// [05]  A   Array com Help
							"N",;								// [06]  C   Tipo do campo
							PesqPict("CNF","CNF_VLPREV"),;		// [07]  C   Picture
							NIL,;								// [08]  B   Bloco de Picture Var
							NIL,;								// [09]  C   Consulta F3
							.F.,;								// [10]  L   Indica se o campo é alteravel
							NIL,;								// [11]  C   Pasta do campo
							NIL,;								// [12]  C   Agrupamento do campo
							NIL,;								// [13]  A   Lista de valores permitido do campo (Combo)
							NIL,;								// [14]  N   Tamanho maximo da maior opção do combo
							NIL,;								// [15]  C   Inicializador de Browse
							.T.,;								// [16]  L   Indica se o campo é virtual
							NIL,;								// [17]  C   Picture Variavel
							NIL)								// [18]  L   Indica pulo de linha após o campo

	//-- Adiciona campos de arrasto e redistribuição de saldos para o cronograma contábil
	oStruCN9:AddField(	"CN9_ARRASC",;						// [01]  C   Nome do Campo
							"01",;							// [02]  C   Ordem
							STR0144,;						// [03]  C   Titulo do campo	//"Arrasto"
							STR0144,;						// [04]  C   Descricao do campo	//"Arrasto"
							{STR0135},;						// [05]  A   Array com Help
							"C",;							// [06]  C   Tipo do campo
							"@!",;							// [07]  C   Picture
							NIL,;							// [08]  B   Bloco de Picture Var
							NIL,;							// [09]  C   Consulta F3
							.T.,;							// [10]  L   Indica se o campo é alteravel
							"4",;							// [11]  C   Pasta do campo
							"GRP4",;						// [12]  C   Agrupamento do campo
							{STR0147,STR0148},;				// [13]  A   Lista de valores permitido do campo (Combo)	//{'1=Sim','2=Não'}
							NIL,;							// [14]  N   Tamanho maximo da maior opção do combo
							NIL,;							// [15]  C   Inicializador de Browse
							.T.,;							// [16]  L   Indica se o campo é virtual
							NIL,;							// [17]  C   Picture Variavel
							NIL)							// [18]  L   Indica pulo de linha após o campo

	oStruCN9:AddField(	"CN9_REDVAC",;					// [01]  C   Nome do Campo
						"02",;							// [02]  C   Ordem
						STR0145,;						// [03]  C   Titulo do campo	//"Redist. Val."
						STR0146,;						// [04]  C   Descricao do campo	//"Redistribuição de Valores"
						{STR0136},;						// [05]  A   Array com Help
						"C",;							// [06]  C   Tipo do campo
						"@!",;							// [07]  C   Picture
						NIL,;							// [08]  B   Bloco de Picture Var
						NIL,;							// [09]  C   Consulta F3
						.T.,;							// [10]  L   Indica se o campo é alteravel
						"4",;							// [11]  C   Pasta do campo
						"GRP4",;						// [12]  C   Agrupamento do campo
						{STR0147,STR0148},;				// [13]  A   Lista de valores permitido do campo (Combo)	//{'1=Sim','2=Não'}
						NIL,;							// [14]  N   Tamanho maximo da maior opção do combo
						NIL,;							// [15]  C   Inicializador de Browse
						.T.,;							// [16]  L   Indica se o campo é virtual
						NIL,;							// [17]  C   Picture Variavel
						NIL)							// [18]  L   Indica pulo de linha após o campo

	oStruCND:AddField("CND_FILDES"						,;	// [01]  C   Nome do Campo
					"01"								,;	// [02]  C   Ordem
					STR0183		 						,;	// [03]  C   Titulo do campo
					STR0183								,;	// [04]  C   Descricao do campo
					NIL									,;	// [05]  A   Array com Help
					"C"									,;	// [06]  C   Tipo do campo
					"@!"								,;	// [07]  C   Picture
					NIL									,;	// [08]  B   Bloco de Picture Var
					NIL									,;	// [09]  C   Consulta F3
					.F.									,;	// [10]  L   Indica se o campo é alteravel
					NIL									,;	// [11]  C   Pasta do campo
					NIL									,;	// [12]  C   Agrupamento do campo
					NIL									,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL									,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL									,;	// [15]  C   Inicializador de Browse
					.T.									,;	// [16]  L   Indica se o campo é virtual
					NIL									,;	// [17]  C   Picture Variavel
					NIL									)	// [18]  L   Indica pulo de linha após o campo


	oStruCXN:AddField("CXN_FILDES"						,;	// [01]  C   Nome do Campo
					"01"								,;	// [02]  C   Ordem
					STR0183		 						,;	// [03]  C   Titulo do campo
					STR0183								,;	// [04]  C   Descricao do campo
					NIL									,;	// [05]  A   Array com Help
					"C"									,;	// [06]  C   Tipo do campo
					"@!"								,;	// [07]  C   Picture
					NIL									,;	// [08]  B   Bloco de Picture Var
					NIL									,;	// [09]  C   Consulta F3
					.F.									,;	// [10]  L   Indica se o campo é alteravel
					NIL									,;	// [11]  C   Pasta do campo
					NIL									,;	// [12]  C   Agrupamento do campo
					NIL									,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL									,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL									,;	// [15]  C   Inicializador de Browse
					.T.									,;	// [16]  L   Indica se o campo é virtual
					NIL									,;	// [17]  C   Picture Variavel
					NIL									)	// [18]  L   Indica pulo de linha após o campo


	If (SC7->(ColumnPos('C7_NUM') > 0) .And. X3Uso(GetSx3Cache('C7_NUM', 'X3_USADO')))
		oStruSC7:SetProperty('C7_NUM', MVC_VIEW_ORDEM, '01')
	Else	
		oStruSC7:AddField('C7_MEDPED'						,;	// [01]  C   Nome do Campo
						'01'								,;	// [02]  C   Ordem
						STR0216			 					,;	// [03]  C   Titulo do campo
						STR0216								,;	// [04]  C   Descricao do campo
						NIL									,;	// [05]  A   Array com Help
						'C'									,;	// [06]  C   Tipo do campo
						'@!'								,;	// [07]  C   Picture
						NIL									,;	// [08]  B   Bloco de Picture Var
						NIL									,;	// [09]  C   Consulta F3
						.F.									,;	// [10]  L   Indica se o campo é alteravel
						NIL									,;	// [11]  C   Pasta do campo
						NIL									,;	// [12]  C   Agrupamento do campo
						NIL									,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL									,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL									,;	// [15]  C   Inicializador de Browse
						.T.									,;	// [16]  L   Indica se o campo é virtual
						NIL									,;	// [17]  C   Picture Variavel
						NIL									)	// [18]  L   Indica pulo de linha após o campo
	EndIf

	If CposVlPres()	
		oStruCN9:AddField(	"CN9_TJUFIN",;					// [01]  C   Nome do Campo
							Soma1(X3Ordem("CN9_QTDPAR")),;	// [02]  C   Ordem
							RetTitle("CNF_TJUROS"),;		// [03]  C   Titulo do campo
							RetTitle("CNF_TJUROS"),;		// [04]  C   Descricao do campo
							{STR0312},;						// [05]  A   Array com Help //"Informe a taxa de juros p/ calculo do valor presente."
							"N",;							// [06]  C   Tipo do campo
							PesqPict("CNF","CNF_TJUROS"),;	// [07]  C   Picture
							NIL,;							// [08]  B   Bloco de Picture Var
							NIL,;							// [09]  C   Consulta F3
							.T.,;							// [10]  L   Indica se o campo é alteravel
							"4",;							// [11]  C   Pasta do campo
							"GRP1",;						// [12]  C   Agrupamento do campo
							Nil,;							// [13]  A   Lista de valores permitido do campo (Combo)	//{'1=Sim','2=Não'}
							NIL,;							// [14]  N   Tamanho maximo da maior opção do combo
							NIL,;							// [15]  C   Inicializador de Browse
							.T.,;							// [16]  L   Indica se o campo é virtual
							NIL,;							// [17]  C   Picture Variavel
							NIL)							// [18]  L   Indica pulo de linha após o campo
	EndIf

	If ValPresCtb()	
		oStruCN9:AddField(	"CN9_TJUCTB",;					// [01]  C   Nome do Campo
							Soma1(X3Ordem("CN9_TPCROC")),;	// [02]  C   Ordem
							RetTitle("CNW_TJUROS"),;		// [03]  C   Titulo do campo
							RetTitle("CNW_TJUROS"),;		// [04]  C   Descricao do campo
							{STR0312},;						// [05]  A   Array com Help //"Informe a taxa de juros p/ calculo do valor presente."
							"N",;							// [06]  C   Tipo do campo
							PesqPict("CNW","CNW_TJUROS"),;	// [07]  C   Picture
							NIL,;							// [08]  B   Bloco de Picture Var
							NIL,;							// [09]  C   Consulta F3
							.T.,;							// [10]  L   Indica se o campo é alteravel
							"4",;							// [11]  C   Pasta do campo
							"GRP4",;						// [12]  C   Agrupamento do campo
							Nil,;							// [13]  A   Lista de valores permitido do campo (Combo)	//{'1=Sim','2=Não'}
							NIL,;							// [14]  N   Tamanho maximo da maior opção do combo
							NIL,;							// [15]  C   Inicializador de Browse
							.T.,;							// [16]  L   Indica se o campo é virtual
							NIL,;							// [17]  C   Picture Variavel
							NIL)							// [18]  L   Indica pulo de linha após o campo
	EndIf
	//-- Consulta padrão para a tabela de preços em contratos de compras
	oStruCNB:SetProperty("CNB_TABPRC",MVC_VIEW_LOOKUP,"AIA")

	If !Empty(cTipRevisa) .Or. !Empty(cAprTipRev)
		oStruCN9:SetProperty('CN9_TIPREV',MVC_VIEW_ORDEM,'00')
		oStruCN9:AddGroup( "GRP1" , STR0243, 	"" , 2 )	//"Parâmetros Fin./Fisico"
		oStruCN9:AddGroup( "GRP2" , STR0244, 	"" , 2 )	//"Redistribuição de Saldo"
		oStruCN9:AddGroup( "GRP3" , STR0245, 	"" , 2 )	//"Reajuste"
		oStruCN9:AddGroup( "GRP7" , STR0249, 	"" , 2 )	//"Datas Retroativas"
		oStruCN9:AddGroup( "GRP4" , STR0246, 	"" , 2 )	//"Parâmetros Contábil"
		oStruCN9:AddGroup( "GRP5" , STR0247, 	"" , 2 )	//"Paralisação"
		oStruCN9:AddGroup( "GRP6" , STR0248, 	"" , 2 )	//"Reinício"
		
		oStruCN9:SetProperty( "CN9_DTRRDE" , MVC_VIEW_GROUP_NUMBER, "GRP7" )
		oStruCN9:SetProperty( "CN9_DTRRAT" , MVC_VIEW_GROUP_NUMBER, "GRP7" )		
	Else
		oStruCN9:RemoveField("CN9_TIPREV")
	EndIf

	//--Remove Campos exclusivos de cada revisao.
	If 	(cTipRevisa <> DEF_REV_REAJU .And. cAprTipRev <> DEF_REV_REAJU) .And. ;
		(cTipRevisa <> DEF_REV_ABERT .And. cAprTipRev <> DEF_REV_ABERT) .And. ;
		!(cTipRevisa == DEF_REV_REALI  )

		oStruCN9:RemoveField("CN9_DREFRJ")
		oStruCN9:RemoveField("CN9_DTREAJ")

	Else
		If cTipRevisa == DEF_REV_REALI
			oStruCN9:SetProperty( "CN9_DREFRJ" , MVC_VIEW_GROUP_NUMBER, "GRP3" )
			oStruCN9:RemoveField("CN9_DTREAJ")
		EndIf

		If (cTipRevisa $ DEF_REV_REAJU+'|'+DEF_REV_ABERT)
			oStruCN9:SetProperty( "CN9_DTREAJ" , MVC_VIEW_GROUP_NUMBER, "GRP3" )
			oStruCN9:SetProperty( "CN9_DREFRJ" , MVC_VIEW_GROUP_NUMBER, "GRP3" )
		EndIf
	EndIf

	If !(cTipRevisa $  DEF_REV_PARAL+'|'+DEF_REV_REINI+'|'+DEF_REV_ABERT) .And. !(cAprTipRev $  DEF_REV_PARAL+'|'+DEF_REV_REINI+'|'+DEF_REV_ABERT)
		oStruCN9:RemoveField("CN9_MOTPAR")
		oStruCN9:RemoveField("CN9_DESMTP")
		oStruCN9:RemoveField("CN9_DTFIMP")
		oStruCN9:RemoveField("CN9_DTREIN")
	Else
		oStruCN9:SetProperty( "CN9_MOTPAR" , MVC_VIEW_GROUP_NUMBER, "GRP5" )
		oStruCN9:SetProperty( "CN9_DESMTP" , MVC_VIEW_GROUP_NUMBER, "GRP5" )
		oStruCN9:SetProperty( "CN9_DTFIMP" , MVC_VIEW_GROUP_NUMBER, "GRP5" )
		oStruCN9:SetProperty( "CN9_DTREIN" , MVC_VIEW_GROUP_NUMBER, "GRP6" )
	EndIf

	If Empty(cTipRevisa)
		oStruCN9:RemoveField("CN9_QTDPAR")
		oStruCN9:RemoveField("CN9_TPCRON")
		oStruCN9:RemoveField("CN9_ARRAST")
		oStruCN9:RemoveField("CN9_REDVAL")
		oStruCN9:RemoveField("CN9_UDMES")
		oStruCN9:RemoveField("CN9_CPARCA")
		oStruCN9:RemoveField("CN9_CPARCV")
		oStruCN9:RemoveField("CN9_ARRASC")
		oStruCN9:RemoveField("CN9_REDVAC")
		oStruCN9:RemoveField("CN9_TPCROC")
		oStruCN9:RemoveField("CN9_QTPARC")
		oStruCNA:RemoveField("CNA_SADISC")
		oStruCNA:RemoveField("CNA_SADIST")
		oStruCN9:RemoveField("CN9_DTRRDE")
		oStruCN9:RemoveField("CN9_DTRRAT")

		If CposVlPres()
			oStruCN9:RemoveField("CN9_TJUFIN")//Taxa de Juros do Cronograma Financeiro(CNF)
		EndIf
		If ValPresCtb()
			oStruCN9:RemoveField("CN9_TJUCTB")//Taxa de Juros do Cronograma Contabil(CNW)
		EndIf
	Else
		oStruCN9:SetProperty( "CN9_TPCRON" , MVC_VIEW_GROUP_NUMBER, "GRP1" )
		oStruCN9:SetProperty( "CN9_ARRAST" , MVC_VIEW_GROUP_NUMBER, "GRP1" )
		oStruCN9:SetProperty( "CN9_REDVAL" , MVC_VIEW_GROUP_NUMBER, "GRP1" )
		oStruCN9:SetProperty( "CN9_QTDPAR" , MVC_VIEW_GROUP_NUMBER, "GRP1" )
		oStruCN9:SetProperty( "CN9_UDMES"  , MVC_VIEW_GROUP_NUMBER, "GRP1" )
		oStruCN9:SetProperty( "CN9_CPARCA" , MVC_VIEW_GROUP_NUMBER, "GRP2" )
		oStruCN9:SetProperty( "CN9_CPARCV" , MVC_VIEW_GROUP_NUMBER, "GRP2" )
		oStruCN9:SetProperty( "CN9_TPCROC" , MVC_VIEW_GROUP_NUMBER, "GRP4" )
		oStruCN9:SetProperty( "CN9_QTPARC" , MVC_VIEW_GROUP_NUMBER, "GRP4" )

		If CposVlPres()
			oStruCN9:SetProperty( "CN9_TJUFIN" , MVC_VIEW_GROUP_NUMBER, "GRP1" )//Valor Presente do Cronograma Financeiro(CNF)
		EndIf
		If ValPresCtb()
			oStruCN9:SetProperty( "CN9_TJUCTB" , MVC_VIEW_GROUP_NUMBER, "GRP4" )//Valor Presente do Cronograma Contabil(CNW)
		EndIf
	EndIf

	If lMedeve .Or. !(cTipRevisa $ DEF_REV_ADITI+'|'+DEF_REV_REALI+'|'+DEF_REV_READE+'|'+DEF_REV_RENOV+'|'+DEF_REV_REINI+'|'+DEF_REV_ABERT) .Or. (cTipRevisa == DEF_REV_REALI .And. lFisico)
		oStruCNA:RemoveField("CNA_SADIST")
	EndIf

	If cPaisLoc == "RUS"
		oStruCNA:RemoveField("CNA_F5QUID")
	EndIf

	If FunName() $ "GCPA200*GCPA300" .Or. (lCtrVenda .And. FunName() $ "TECA850*TECA870*TECA745")
		//Bloco SetProperty
		If lVisuAll .Or. lVisuPla
			oStruCNA:SetProperty('*', MVC_VIEW_CANCHANGE, .F.) 				//Desabilita os campos
			oStruCNA:SetProperty('CNA_FLREAJ', MVC_VIEW_CANCHANGE, .T.)		//Habilita o campo
			oStruCNB:SetProperty('*', MVC_VIEW_CANCHANGE, .F.) 				//Desabilita os campos
			
			If FunName() $ "TECA850*TECA870*TECA745"
				TecBModFld(oStruCNB,oStruCNC,oStruCN9,oStruCNA)
			EndIf
		EndIf
	EndIf

	If cTipRevisa == DEF_REV_REALI .And. !lFixo
		oStruCN9:SetProperty("CN9_VLATU", MVC_VIEW_CANCHANGE,.T.)	//Habilita o campo
	EndIf

	// Valida se é uma inclusão direta do GCT ou se é proveniente do GCP
	If Empty(cTipRevisa) .And. ( (!Empty(CN9->CN9_CODED) .And. !INCLUI) .Or. FunName() $ "GCPA200*GCPA300")
		oStruCNA:SetProperty('*', MVC_VIEW_CANCHANGE, .F.) 				//Desabilita os campos
		oStruCNA:SetProperty("CNA_TIPPLA",	MVC_VIEW_CANCHANGE, .T.)
		oStruCNB:SetProperty('*', MVC_VIEW_CANCHANGE, .F.) 				//Desabilita os campos
	EndIf

	If cTipRevisa $ DEF_REV_ADITI+'|'+DEF_REV_RENOV+'|'+DEF_REV_ORCGS+'|'+DEF_REV_ABERT
		oStruCNB:SetProperty('CNB_VLTOT',	MVC_VIEW_CANCHANGE,.F.)	//Desabilita para edição
	EndIf

	oStruCN9:SetProperty("CN9_VLADIT",	MVC_VIEW_CANCHANGE, .F.)	
	oStruCN9:SetProperty("CN9_DTREV",	MVC_VIEW_CANCHANGE, .F.)
	oStruCNA:SetProperty('CNA_SALDO', 	MVC_VIEW_CANCHANGE, .F.) //Desabilita os campos

	If FWIsInCallStack("GCP320GRV")	.And. !lCtrVenda							//Habilita os campos das entidades contabeis
		oStruCNB:SetProperty('CNB_CC', MVC_VIEW_CANCHANGE, .T.) 		
		oStruCNB:SetProperty('CNB_CLVL', MVC_VIEW_CANCHANGE, .T.) 		
		oStruCNB:SetProperty('CNB_CONTA', MVC_VIEW_CANCHANGE, .T.) 		
		oStruCNB:SetProperty('CNB_ITEMCT', MVC_VIEW_CANCHANGE, .T.) 										

		aAux := oStruCNB:GetFields()								//Habilita os campos das entidades contabeis auxiliares
		aCampoCTB := {"CNB_EC05DB","CNB_EC05CR","CNB_EC06DB","CNB_EC06CR","CNB_EC07DB","CNB_EC07CR","CNB_EC08DB","CNB_EC08CR","CNB_EC09DB","CNB_EC09CR",}
		For nX := 1 To Len(aCampoCTB)
			If ( nPos := aScan(aAux,{|x| AllTrim( x[1] )== AllTrim(aCampoCTB[nX]) } ) )> 0
				oStruCNB:SetProperty(AllTrim(aCampoCTB[nX]), MVC_VIEW_CANCHANGE, .T.) 										
			EndIf
		Next nX		

	EndIf

	If lCtrVenda .And. ( FwIsInCallStack('TECA850') .Or. FwIsInCallStack('TECA870') )
		oStruCNB:SetProperty('CNB_VLUNIT',	MVC_VIEW_CANCHANGE,.F.)
	EndIf

	/*----------FIM TRECHO MODIFICACOES STRUCTS-------------*/

	CfgViewDef() //Configura quais views devem ser exibidas


	//Array com os modelos que o usuário pode ver
	If Len(aVldUsr) > 0
		If aVldUsr[1] == .T.
			lVisuAll	:= .T.
		Else
			If !INCLUI
				lVisuCau := .F.
				lVisuPla := .F.
				lVisuCro := .F.
				lVisuDoc := .F.
			EndIf
			aVisuAC	:= CN300VisAc()
			lVisuCau:= aVisuAC[1]
			lVisuPla:= aVisuAC[2]
			lVisuCro:= aVisuAC[3]
			lVisuDoc:= aVisuAC[4]
		EndIf
	EndIf
	
	//-----INICIO DEFINICAO DA VIEW DO CONTRATO---------

	//-- Monta o modelo da interface do formulario
	oView:SetModel(oModel)
	cOper := oModel:GetOperation()	

	//Cria a divisão superior(cabeçalho), com dados da CN9
	oView:AddField('VIEW_CN9',oStruCN9,'CN9MASTER')	
	oView:CreateHorizontalBox('SUPERIOR', 35)
	oView:SetOwnerView('VIEW_CN9','SUPERIOR')

	oView:CreateHorizontalBox('INFERIOR', 65)

	//-- Cria a pasta e planilhas da Manutencao de Contratos
	oView:CreateFolder('FLDCNT','INFERIOR')

	AddAbaCNC(oView, 'FLDCNT', oStruCNC)//Adiciona aba da CNC(Fornecedores ou Clientes)

	If lCtrVenda//Cria Aba de Vendedores
		oStruCNU := FWFormStruct(2,'CNU', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCNU})
		AddAbaVend(oView, 'FLDCNT', oStruCNU)//Adiciona aba de Vendedores		
	EndIf	
	
	If (lVisuAll .Or. lVisuPla) //Cria aba de Planilhas

		cFoldIdPla := AddAbaPlan(oView, 'FLDCNT', oStruCNA)//Adiciona aba Planilhas(CNA), retorna o folder a ser utilizado pelos seus submodelos
		AddAbaCNB(oView, cFoldIdPla, oStruCNB)//Adiciona aba itens da Planilha(CNB)		
		AddAbaCNZ(oView, cFoldIdPla, oStruCNZ, oCalcCNZ)//Adiciona aba Rateio dos Itens(CNZ)
		AddAbaCXM(oView, cFoldIdPla, oStruCXM)//Adiciona aba dos Agrupadores de Estoque(CXM)

		If lVisuCro
			AddAbaCNF(oView, cFoldIdPla, oStruCNF, oCalcCNF)//Adiciona aba Cronograma Financeiro(CNF)
			AddAbaCNS(oView, cFoldIdPla, oStruCNS, oStruTCNS)//Adiciona aba Cronograma Fisico(CNS)
			AddAbaCCtb(oView, cFoldIdPla, oStruCNV, oStruCNW)//Adiciona aba Cronograma Contábil(CNV) e suas parcelas(CNW)
		EndIf	
		
		If GetShowView("CND")			
			cViewPedId := AddAbaMeds(oView, 'FLDCNT', oStruCND) //Adiciona aba Medições(CND), retorna id da view onde pedidos devem ser exibidos.

			If lCtrVenda
				oStruSC5 := FWFormStruct(2,'SC5')
				oView:AddGrid('VIEW_SC5',oStruSC5,'SC5DETAIL')
				oView:SetOwnerView('VIEW_SC5',cViewPedId)
			Else
				oView:AddGrid('VIEW_SC7',oStruSC7,'SC7DETAIL')
				oView:SetOwnerView('VIEW_SC7',cViewPedId)
			EndIf			
		EndIf

		If GetShowView("MULTNAT")
			oStruCXO := FWFormStruct(2,'CXO', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCXO})
			oStruCXP := FWFormStruct(2,'CXP', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCXP})
			AddAbaMNat(oView, 'FLDCNT', oStruCXO, oStruCXP)//Adiciona aba Múltiplas Naturezas(CXO e CXP)			
		EndIf
	EndIf

	AddAbaMult(oView, 'FLDCNT', oStruCNH) //Adiciona aba Multas/Bonificacoes(CNH)
	
	If (lVisuAll .Or. lVisuDoc) .And. GetShowView("CNK")
		oStruCNK := FWFormStruct(2,'CNK', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCNK})
		AddAbaDocs(oView, 'FLDCNT', oStruCNK)//Adiciona aba Documentos(CNK)
	EndIf

	If GetShowView("CNX")
		oStruCNX := FWFormStruct(2,'CNX', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCNX})
		AddAbaAdts(oView, 'FLDCNT', oStruCNX)//Adiciona aba de Adiantamentos(CNX)
	EndIf

	If lVisuAll .Or. lVisuCau
		If GetShowView("CN8")
			oStruCN8 := FWFormStruct(2,'CN8', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCN8})
			oStruCNI := FWFormStruct(2,'CNI')
			AddAbaCauc(oView, 'FLDCNT', oStruCN8, oStruCNI)//Adiciona aba Cauções(CN8)			
		EndIf

		If GetShowView("CNT")
			oStruCNT := FWFormStruct(2,'CNT', {|cCampo| !AllTrim(cCampo)+'|' $ cCampoCNT})
			AddAbaCRet(oView, 'FLDCNT', oStruCNT)//Adiciona aba Cauções Retidos(CNT)
		EndIf
	EndIf
		
	If GetShowView("CXL")//--Aba reajuste
		oStruCXL := FWFormStruct(2,'CXL', {|x| !AllTrim(x)+'|' $ "CXL_CONTRA|CXL_REVISA|"})
		AddAbaReaj(oView, 'FLDCNT', oStruCXL)//Adiciona aba Reajuste(CXL)
	EndIf

	aUsrButton := GetUsrBtns(oModel, lVisuCro)//Obtem todos os botões a serem adicionados na view
	for nX := 1 to Len(aUsrButton)
		cBtnDescr	:= aUsrButton[nX,1]
		bBtnAction	:= aUsrButton[nX,2]
		oView:AddUserButton(cBtnDescr,'CLIPS', bBtnAction)//Adiciona os botoes na view
	next nX
	FwFreeArray(aUsrButton)

	oView:SetProgressBar(.T.)

	If lA300STRU
		ExecBlock( "A300STRU", .F., .F., { "VIEWDEF", IIF(CNTGetFun() == "CNTA301", "V","C"), @oView } )
	EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300InCOM
Rotina para tratamento na opcao de inclusao de contrato de compra

@author Leandro.Moura
@since 23/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CN300InCOM()
	CNTSetFun("CNTA300")
Return FwExecView(STR0156,"CNTA300",MODEL_OPERATION_INSERT,,{|| .T.})

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300InVEN
Rotina para tratamento na opcao de inclusao de contrato de venda

@author Leandro.Moura
@since 23/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CN300InVEN()
	CNTSetFun("CNTA301")	
Return FWExecView(STR0155,"CNTA301",MODEL_OPERATION_INSERT,,{|| .T.})

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300Visua
Rotina para tratamento na opcao de visualizacao

@author Leandro.Moura
@since 23/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CN300Visua()
Local cModel	:= ''
Local lRet		:= .F.

Private aRotina := If( Type('aRotina') <> 'A', Menudef(), aRotina )

CNT300Rese()

If Cn300RetSt('COMPRA',,,,,.F.)
	cModel := "CNTA300"
Else
	CNTSetFun("CNTA301")
	cModel := "CNTA301"
EndIf

lRet := CN240VldUsr(CN9->CN9_NUMERO,DEF_TRAVIS,.T.)//Visualiza Contrato

If lRet
	lRet := FWExecView(STR0013,cModel,MODEL_OPERATION_VIEW,,{|| .T.})
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300Alter
Rotina para tratamento na opcao de alteracao

@author Leandro.Moura
@since 23/09/2013

@version P11.90
/*/
//-------------------------------------------------------------------
Function CN300Alter()
Local cTipRev	:= ""

cContrat	:= CN9->CN9_NUMERO
If CN9->( ColumnPos( "CN9_GESTC" ) ) > 0
	__cGestOld := CN9->CN9_GESTC
EndIf 

If AllTrim(CN9->CN9_SITUAC) $ DEF_SREVS+"|"+DEF_SREVA+"|"+ DEF_SREJE .And. !Empty(CN9->CN9_TIPREV)
	cTipRev := CN300RetSt('TIPREV',,,,,.F.)
	//Guarda o valor na variavel static
	cTipRevisa := cTipRev
	If cTipRev == DEF_REV_REAJU
		Help('',1,'CNTA300NOA')
	ElseIf cTipRev == DEF_REV_REALI .And. A300RevMed()
		Help('',1,'CNTA300NOAREA')
	Else
		CN300Rev(,,,cTipRev)
	EndIf
Else
	FWExecView(STR0178, If(Cn300RetSt('COMPRA',,,,,.F.), "CNTA300", "CNTA301"), MODEL_OPERATION_UPDATE,, {|| .T.})	//"Alteração"
EndIf
cTipRevisa := ""
__cGestOld := ""
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300Delet
Rotina para tratamento na opcao de exclusao

@author Leandro.Moura
@since 23/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CN300Delet()
cAprTipRev	:= ''
cTipRevisa	:= ''
Return FWExecView(STR0016,If(Cn300RetSt('COMPRA',,,,,.F.),"CNTA300","CNTA301"),MODEL_OPERATION_DELETE,,{|| .T.})


//-------------------------------------------------------------------
/*/{Protheus.doc} CN300Aprov
Rotina para tratamento na opcao de alteracao

@param lAuto, logical, Define se é execução automática.
@param bAuto, code-block, Define bloco de código para execução automática.
@param cMsgErro, characters, Mensagem de erro retornada pelo modelo.
@return nRet, numeric, Retorna 0 em caso de falha, 1 em caso de sucesso.

@author Aline.Sebrian
@since 20/02/2014
@version P11.90
/*/
//-------------------------------------------------------------------
Function CN300Aprov(lAuto, bAuto, cMsgErro)
	Local nRet	    := 0
	Local oModel	:= FwModelActive()
	 
	Default lAuto	:= .F.
	Default bAuto	:= {|oUmModel| IIF(oUmModel:VldData() .And. oUmModel:CommitData(),1,0)}
    Default cMsgErro := ""
	
	If ValType(lAuto) != "L"
		lAuto := .F.
	EndIf
	
    If !( ValType(oModel) == 'O' .And. oModel:lActivate 	.And. oModel:GetId() $ 'CNTA300|CNTA301' .And.;
       oModel:GetValue('CN9MASTER','CN9_NUMERO') == CN9->CN9_NUMERO .And. oModel:GetValue('CN9MASTER','CN9_REVISA') == CN9->CN9_REVISA)

        oModel := FWLoadModel(If(CN9->CN9_ESPCTR == "1","CNTA300","CNTA301"))
        If lAuto
            oModel:SetOperation(MODEL_OPERATION_UPDATE)
        EndIf

        //-- Antes de ativar o modelo devemos setar as statics para que a pré validação não ocorra com erros			
        A300SATpRv(Cn300RetSt("TIPREV",,,CN9->CN9_NUMERO,CN9->CN9_FILCTR,.F.))

        oModel:Activate()
    EndIf

    If lAuto
        Pergunte("CNT100",.F.)
        nRet := Eval(bAuto, oModel)
    Else
        nRet := FWExecView(STR0179, If(Cn300RetSt('COMPRA',,,,,.F.), "CNTA300", "CNTA301"), MODEL_OPERATION_UPDATE,, {|| .T.})	//"Aprovação"
    EndIf

    If oModel:HasErrorMessage()
        cMsgErro := oModel:GetErrorMessage()[5] +":"+ oModel:GetErrorMessage()[6]
        nRet := 0
    EndIf
    A300SATpRv('')
	
	If(ValType(oModel)=='O')
		oModel:DeActivate()
	EndIf
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VldAc
Rotina para validacao na ativacao do model

@param oModel Model da rotina

@author Leandro.Moura
@since 23/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300VldAc(oModel)
Local aArea			:= GetArea()
Local lRet			:= .T.
Local lUserOk		:= .F.
Local lVisualiza	:= oModel:GetOperation() == MODEL_OPERATION_VIEW
Local lInclui		:= oModel:GetOperation() == MODEL_OPERATION_INSERT .And. Empty(cTipRevisa)
Local lAltera		:= oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. Empty(cAprTipRev)
Local lExclui		:= oModel:GetOperation() == MODEL_OPERATION_DELETE
Local lAprovRev 	:= FwIsInCallStack('Cn300Aprov')
Local lC100VlAt  	:= _lC100VLAT
Local lReajAuto		:= FWIsInCallStack("CN310Reaj")
Local lChgSit		:= FWIsInCallStack('CN100Sitch')
Local cRetNat   	:= ""			

If lRet .And. lAprovRev // Valida aprovação da revisão
    If ExistSCR2('RV',CN9->(CN9_NUMERO+CN9_REVISA), CN9->CN9_FILCTR) // Valida alçada na revisão
        Help(" ",1,"EXISTSCR") // A aprovação deste documento deve ser realizada pela rotina liberação de documentos
        lRet := .F.
    ElseIf AllTrim(CN9->CN9_SITUAC) != DEF_SREVS // Valida situação
        Help('',1,'CNTA300NOREV') // Ação permitida apenas para contratos em Situação de Revisão
        lRet := .F.
    EndIf
EndIf

If lRet .And. lAltera .And. AllTrim(CN9->CN9_SITUAC) == '01' //Contrato Cencelado
	Help(" ",1,"CNTA300CAN",,STR0300,5,0) // -- Não é permitido alterar dados de um Contrato Cancelado.
	lRet :=  .F.
EndIf

If lRet .And. !FWIsInCallStack('MATA094') .And. !lChgSit
	//-- Valida o acesso do usuario
	If !Empty(cAprTipRev)
		lRet := CN240VldUsr(CN9->CN9_NUMERO,DEF_TRAAPR,.T.)//Valida Transacao
	ElseIf !Empty(cTipRevisa)
		lRet := CN240VldUsr(CN9->CN9_NUMERO,DEF_TRAINC,.T.)//Valida Transacao
	ElseIf lExclui .And. AllTrim(CN9->CN9_SITUAC) $ DEF_SREVS+"|"+DEF_SREVA
		lRet := CN240VldUsr(CN9->CN9_NUMERO,DEF_TRAEXC,.T.)//Valida Transacao
	ElseIf !lInclui .And. !Empty(CN9->CN9_NUMERO)
		If FunName() == "CNTA121" //Se for a nova medição, passa as permissões da medição de contratos
			lRet := CN240VldUsr(CN9->CN9_NUMERO,If(lVisualiza,DEF_TRAINC_MED,DEF_TRAEDT_MED),.T.,,CN9->CN9_FILCTR)
		Else
			lRet := CN240VldUsr(CN9->CN9_NUMERO,If(lVisualiza,DEF_TRAVIS,DEF_TRAEDT),.T.,,CN9->CN9_FILCTR)
		EndIf
	EndIf
EndIf

//-- Verifica se valida exclusao de contrato gerado por edital
If lRet .And. lExclui .And. !Empty(CN9->CN9_CODED) .And. !Empty(CN9->CN9_NUMPR) .And. Empty(CN9->CN9_REVISA) .And. !FWIsInCallStack('GCP200PERM')
	Help(" ",1,"CNT100EDITAL")	//-- Contrato não pode ser excluido pois foi gerado por edital
	lRet := .F.
EndIf

//-- Verifica se o contrato possui revisao
If lRet .And. !Empty(CN9->CN9_REVATU) .And. ( (lAltera .Or. lExclui) .Or. ( !Empty(cTipRevisa) .And. CN9->CN9_REVISA != CnGetRevAt(CN9->CN9_NUMERO)))
	Help(" ",1,"CNTA300REV")	//-- Contrato revisado
	lRet :=  .F.
EndIf

//-- Valida alteracoes em contratos que nao estao em elaboracao
If !lAdiant
	If lRet .And. lC100VlAt .And. ((lAltera .And. !lChgSit) .OR. lExclui)
		lUserOk := ExecBlock("C100VLAT",.F.,.F.,{CN9->CN9_SITUAC,oModel})
		
		If	ValType(lUserOk) <> "L"
			lUserOk := .F.
		Endif 

		If lC100VlAt .And. !lUserOk
			Help(" ",1,"CNTA300ELB")	//-- Acao disponivel apenas para contratos em Elaboracao
			lRet := .F.
		EndIf
		
	EndIf

	If lRet .And. !lUserOk .And. !lReajAuto .And. !lChgSit .And. ( lExclui .And. !(AllTrim(CN9->CN9_SITUAC) $ DEF_SREVS+"|"+DEF_SREVA+"|"+DEF_SREJE) ) .And. ;
			!(AllTrim(CN9->CN9_SITUAC) $ DEF_SELAB+"|"+DEF_SREVS+"|"+DEF_SREVA+"|"+DEF_SREJE) 	.And. !(FWIsInCallStack('GCP200PERM')) .And. !(FWIsInCallStack('GCTEstApr'))
		Help(" ",1,"CNTA300ELB")	//-- Acao disponivel apenas para contratos em Elaboracao
		lRet :=  .F.
	EndIf
EndIf

If lRet .And. (lAltera .Or. lExclui)
	lRet :=  VlAltCtrGS()//Valida alteracoes em contratos originados por Gestao de Servicos			
EndIf

If (lRet .And. !lChgSit .And. (lAltera .Or. lExclui) .And. A300IsGTP())//Valida alteracoes em contratos originados por Gestao de Trasporte de Passageiros
	Help( ,, "CNTA300GTP",, STR0314, 1, 0,,,,,, {STR0315} )//Ação indisponivel para contratos integrados ao Gestão de Trasporte de Passageiros
	lRet := .F.	
EndIf

If lRet .And. lExclui //Valida se o Contrato pode ser excluido	 
	 If ((lRet := VldDelSc()) .And. CN9->CN9_FLGCAU == "1") //Caucao 1=SIM
		lRet := CN9->(CnDrVlCauc(CN9_NUMERO , CN9_REVISA , CN9_FILCTR, .F.)) //Valida a existência de caução(CN8): o submodelo CN8DETAIL é apenas leitura, então não realiza a exclusão do caução automaticamente...
	 EndIf
EndIf

// Valida quando for revisao
If lRet .And. !Empty(cTipRevisa)

	lRet := A300CheckM()

	If lRet .And. cTipRevisa==DEF_REV_REAJU .And. CN9->CN9_FLGREJ <> '1'
		lRet := .F.
		Help('',1,'CNTA300REAJ')
	EndIf

	If lRet .And. cTipRevisa==DEF_REV_INDIC .And. CN9->CN9_FLGREJ <> '1'
		lRet := .F.
		Help('',1,'CNTA300REVIND')
	EndIf

	If lRet .And. cTipRevisa==DEF_REV_REALI .And. !Cn300RetSt("PREVFINANC",2)
		lRet := .F.
		Help('',1,'CNTA300REALI')
	EndIf

	If lRet .And. cTipRevisa==DEF_REV_READE .And. !Cn300RetSt("FIXO",2)
		lRet := .F.
		Help('',1,'CNTA300READE')
	EndIf

	If lRet .And. (cTipRevisa==DEF_REV_REAJU .Or. cTipRevisa== DEF_REV_READE ;
					 .Or. cTipRevisa== DEF_REV_FORCL .Or. cTipRevisa == DEF_REV_ABERT) .And. A300IsServs()
		Help('',1,'CNTA300TRV')
		lRet := .F.
	EndIf

	//Bloqueia o registro do contrato na tabela CN9
	If lRet .And. oModel:GetOperation() <> MODEL_OPERATION_INSERT .And. !lVisualiza
		lRet := SoftLock('CN9',.F.)
	EndIf
	
	//- Avisa o usuário necessidade de criação de campos de multiplas naturezas
	If CnGatMNat() .And. !VldCpoCNM()		
		Aviso("CNTA100", STR0283,{STR0222})
	EndIf
	
EndIf

If lRet .And. lAdiant
	If AllTrim(CN9->CN9_SITUAC) != DEF_SVIGE .And. !IsBlind() //Realizar validação se não executado pela automação
		Help(" ",1,"CNTA100ADI") //"Acao disponivel apenas para contratos em Vigencia"
		lRet := .F.
	EndIf

	If lRet .And. CN300RetSt('INTPIMS',,,,,.F.)
		lRet := .F.
		Help('',1,'CNPIMSADIA') //- Ação indisponivel para contatos com integração com o PIMS.
	EndIf
	
	If (lRet)
		cRetNat := GetNatAdian()
		If Empty( cRetNat )		
			Help(" ",1,"A300NATADI",,STR0158,1,1)//"Informe uma natureza financeira no contrato ou no parâmetro MV_CNNATAD para incluir um adiantamento.
			lRet := .F.
		EndIf

		SED->( dbSetOrder( 1 ) )
		If lRet .And. !SED->( MsSeek( xFilial( "SED" ) + cRetNat ) )
			Help(" ", 1, "REGNOIS",,STR0159,2)// "A natureza definida pelo parametro MV_CNNATAD não está cadastrada."		
			lRet := .F.
		EndIf
	EndIf
EndIf

If lRet .And. oModel:GetOperation() != MODEL_OPERATION_VIEW .And. Empty(cTipRevisa)
	oModel:GetModel("CN9MASTER"):GetStruct():SetProperty('CN9_JUSTIF',MODEL_FIELD_WHEN,{||.F.})
EndIf

RestArea(aArea)
FwFreeArray(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300Activ
Rotina executada na ativacao do modelo.

@param oModel Model da rotina

@author andre.oliveira
@since 05/12/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300Activ(oModel)

Static aGCTCRM			:= {}

Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local lCRM			:= SuperGetMV("MV_CRMXGCT",.F.,.F.) .And. !Empty(oModel:GetValue('CNBDETAIL','CNB_PROPOS'))
Local lC100VlAt		:= CN300VLAT(oModel)
Local lTpPlaCall	:= .F.
If lCRM //- Existe integração com CRM
	If Empty(cTipRevisa) //- Campos bloqueados na elaboração
		aGCTCRM := {'CNA_CLIENT','CNA_LOJACL','CNA_DTINI','CNA_VLTOT','CNA_TIPPLA','CNA_DTFIM','CNA_PERREC','CNA_QTDREC','CNA_DIASEM',;
					  'CNB_PRODUT','CNB_DESCRI','CNB_PROREV','CNB_PROITN','CNB_PROPOS','CNB_QUANT','CNB_VLUNIT','CNB_VLTOT'}
	Else //- Campos bloqueados na revisão.
		aGCTCRM := {'CNA_CLIENT','CNA_LOJACL','CNA_DTINI','CNA_VLTOT','CNA_TIPPLA','CNA_DTFIM',;
					  'CNB_PRODUT','CNB_DESCRI','CNB_PROREV','CNB_PROITN','CNB_PROPOS'}
	EndIf

	If ExistBlock("A300XCRM") //- Ponto de entrada que envia array de campos da integração com CRM
		aGCTCRM := ExecBlock("A300XCRM",.F.,.F.,{aGCTCRM})
	EndIf
EndIf

// Para não atualizar (SetValue) o contrato (função de comparação do Fluig)
If FWIsInCallStack("WF300CtAnt") .Or. ValType('cAprTipRev') == 'U'
	cAprTipRev	:= ''
Endif

If oModel:GetOperation() == MODEL_OPERATION_INSERT
	If Empty(oModel:GetValue("CN9MASTER","CN9_ESPCTR"))
		If CNTGetFun() == "CNTA300" .Or. FWIsInCallStack("MATA161")
			oModel:GetModel("CN9MASTER"):SetValue("CN9_ESPCTR","1")
		ElseIf CNTGetFun() == "CNTA301"
			oModel:GetModel("CN9MASTER"):SetValue("CN9_ESPCTR","2")
		EndIf
	EndIf
ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE
	//-- Na alteracao, bloqueia trechos do modelo conforme tipo de contrato
	CN300TpCtr( oModel , @lTpPlaCall)
	If !lTpPlaCall
		CN300TpPla( .F., oModel )
	EndIf

	If !( AllTrim(CN9->CN9_SITUAC) $ ( DEF_SELAB + "|" + DEF_SREVS + "|" + DEF_SREVA + "|" + DEF_SREJE ) ) .And. !lAdiant
		//Função para bloquear todos os campos na alteração e liberar apenas alguns campos específicos
		LibCpoAlt( oModel )
	EndIf
	
ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE .And. AllTrim(CN9->CN9_SITUAC) $ DEF_SREVS+"|"+DEF_SREVA
	// Caso excluir uma revisao, nao pode excluir partes do modelo que nao tem o campo revisa.
	cn300ModQr(oModel)
EndIf

//-- Coloca os campos da CNC como obrigatorios
If oModel:GetModel("CN9MASTER"):GetValue("CN9_ESPCTR") == "1"
	// Campos obrigatórios para o caso de ser um Fornecedor
	oModel:GetModel("CNCDETAIL"):GetStruct():SetProperty("CNC_CODIGO",MODEL_FIELD_OBRIGAT,.T.)
	oModel:GetModel("CNCDETAIL"):GetStruct():SetProperty("CNC_LOJA",MODEL_FIELD_OBRIGAT,.T.)

	// Campos não obrigatórios para o caso de ser um Fornecedor
	oModel:GetModel("CNCDETAIL"):GetStruct():SetProperty("CNC_CLIENT",MODEL_FIELD_OBRIGAT,.F.)
	oModel:GetModel("CNCDETAIL"):GetStruct():SetProperty("CNC_LOJACL",MODEL_FIELD_OBRIGAT,.F.)
	oModel:GetModel("CNBDETAIL"):GetStruct():SetProperty("CNB_VLUNIT",MODEL_FIELD_OBRIGAT,.F.)
Else
	// Campos obrigatórios para o caso de ser um Cliente
	oModel:GetModel("CNCDETAIL"):GetStruct():SetProperty("CNC_CLIENT",MODEL_FIELD_OBRIGAT,.T.)
	oModel:GetModel("CNCDETAIL"):GetStruct():SetProperty("CNC_LOJACL",MODEL_FIELD_OBRIGAT,.T.)
	oModel:GetModel("CNBDETAIL"):GetStruct():SetProperty("CNB_VLUNIT",MODEL_FIELD_OBRIGAT,.T.)

	// Campos não obrigatórios para o caso de ser um Cliente
	oModel:GetModel("CNCDETAIL"):GetStruct():SetProperty("CNC_CODIGO",MODEL_FIELD_OBRIGAT,.F.)
	oModel:GetModel("CNCDETAIL"):GetStruct():SetProperty("CNC_LOJA",MODEL_FIELD_OBRIGAT,.F.)
EndIf

If !Empty(cTipRevisa)
	If (cTipRevisa $ DEF_REV_ADITI+'|'+DEF_REV_REALI+'|'+DEF_REV_READE+'|'+DEF_REV_REINI+'|'+DEF_REV_RENOV+'|'+DEF_REV_ORCGS+'|'+DEF_REV_ABERT)
		oModel:GetModel("CNSDETAIL"):GetStruct():SetProperty("CNS_SLDQTD",MODEL_FIELD_OBRIGAT,.F.)
		oModel:GetModel("CNSDETAIL"):GetStruct():SetProperty("CNS_PRVQTD",MODEL_FIELD_OBRIGAT,.F.)
		oModel:GetModel("CNSDETAIL"):GetStruct():SetProperty("CNS_RLZQTD",MODEL_FIELD_OBRIGAT,.F.)

		If Cn300RetSt("CONTABIL",2)
			oModel:GetModel("CNWDETAIL"):GetStruct():SetProperty("CNW_VLPREV",MODEL_FIELD_OBRIGAT,.F.)
		EndIf
	EndIf

	If cTipRevisa == DEF_REV_CONTA .Or. cTipRevisa == DEF_REV_ABERT
		oModel:GetModel("CNWDETAIL"):GetStruct():SetProperty("CNW_VLPREV",MODEL_FIELD_OBRIGAT,.F.)
	EndIf
	If (cTipRevisa == DEF_REV_INDIC)
		If oModel:GetModel("CN9MASTER"):GetValue("CN9_FLGREJ") == '1'
			oModel:GetModel("CN9MASTER"):GetStruct():SetProperty("CN9_INDICE",MODEL_FIELD_OBRIGAT,.T.)
		EndIf
	EndIf

	//-- Na alteracao, bloqueia trechos do modelo conforme tipo de contrato
	CN300TpCtr( oModel, @lTpPlaCall )
	If !lTpPlaCall
		CN300TpPla( .F., oModel )
	EndIf

	A300IniRev(oModel,lRevisado)
	
	oModel:GetModel("CNADETAIL"):GoLine(1)
	oModel:GetModel("CNBDETAIL"):GoLine(1)
	oModel:GetModel("CNFDETAIL"):GoLine(1)
EndIf

If	lC100VlAt
	CN300BlCps(oModel)
Endif 	

If !Empty(cAprTipRev) .And. !FWIsInCallStack("WF300bLDet") .And. !FWIsInCallStack("CN100SitCh")
	A300IniApr(oModel)
EndIf

If lAdiant
	A300IniAdi(oModel)
EndIf

aDelsCNF	:= {}
aDelsCNS	:= {}
aDelsCNW	:= {}
aDelsCNV	:= {}

If Type("INCLUI") <> "L"
	INCLUI := .F.
Endif

//Cajo exista controle de acesso libera apenas os modelos permitidos
If !INCLUI .And. FunName() == 'CNTA300'
	If aVldUsr[1] == .F.
		CN300ModAC(oModel)
	EndIf
EndIf

If ExistBlock("CN300ACT")
	ExecBlock("CN300ACT",.F.,.F.,{oModel})
EndIf

FWRestRows(aSaveLines)
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300TOK
Rotina para validacao antes da gravacao do contrato

@param oModel Model da rotina

@author Leandro.Moura
@since 23/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300TOK(oModel)
Local lRet			:= .T.
Local oModelCN9		:= oModel:GetModel("CN9MASTER")
Local lInclui 		:= oModel:GetOperation() == MODEL_OPERATION_INSERT
Local lAltera 		:= oModel:GetOperation() == MODEL_OPERATION_UPDATE
Local lIntegra		:= SuperGetMV('MV_CNXPIMS',.F.,.F.) .And. CN300RetSt('INTPIMS')
Local lPcoInte		:= SuperGetMV("MV_PCOINTE",.F.,"2") == "1"
Local lComValor		:= VldVlrTotal() //Verifica se deve validar o Valor Total do Item

//-- Validacoes genericas do contrato
lRet := CN100Valida(.T.)

//-- Valida Revisões
If lRet .And. !Empty(cTipRevisa)
	lRet := CN300VldRV(oModel)
	If lRet
		//--Tatamento para reabrir pedidos de venda.
		lRet := A300EstPVL()
	EndIf
EndIf

//-- Valida obrigatoriedade do fornecedor
If lRet .And. oModelCN9:GetValue("CN9_ESPCTR") == "1" 
	lRet := CN300GetForn(oModel)
ElseIf lRet
	//-- Valida os vendedores
	lRet := CN300VldVen(oModel:GetModel("CNUDETAIL")) 
EndIf

//-- Valida cabecalho do contrato
If lRet .And. (lAltera .Or. !Empty(cTipRevisa))
	lRet := CN300CTVld(!Empty(cTipRevisa))
EndIf

//-- Valida planilhas do contrato
If lRet .And. lComValor
	lRet := CN300PlaTOK(lPcoInte) 
EndIf

//-- Valida Vigencia x Periodos dos Cronogramas
If lRet .And. lAltera
	lRet := CN100VldPer() 
EndIf

//-- Valida campos de reajuste do contrato
If lRet .And. (lInclui .Or. lAltera) .And. Empty(cTipRevisa) .And. Empty(cAprTipRev)
	lRet := CN300VldRj(oModel)
EndIf

//-- Validações caso exista integração por mensagem unica com o PIMS
If lRet .And. lIntegra
	lRet := CnPimsVlCt(oModel)
EndIf

//Valida Aditivo de prazo de contratos vindo de Editais
If lRet .And. !Empty(oModelCN9:GetValue("CN9_CODED")) .And. cTipRevisa == DEF_REV_ADITI .And. CN300RetSt("REVESPECIE") == "3"
	lRet := CN300EXPRZ(oModel)
EndIf

If lAdiant
	If AllTrim(oModelCN9:GetValue("CN9_SITUAC")) != DEF_SVIGE .And. IsBlind() //Fazer a validação se executado via robô
		Help(" ",1,"CNTA100ADI") //"Acao disponivel apenas para contratos em Vigencia"
		lRet := .F.
	EndIf
EndIf

If lRet
	lRet := CN300VlPrz()//Valida vigencia(CN9_VIGE e CN9_UNVIGE)!
EndIf

If lRet
	lRet := CN300VlDtA()//Valida Dt. Assinat. (CN9_ASSINA)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VldVen
Rotina para validacao dos Vendedores do Contrato

@author Leandro.Moura
@since 23/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300VldVen(oModelCNU)
Local lRet	   		:= .T.
Local nFor	  		:= 0
Local nTotPerc 		:= 0
Local aSaveLines	:= {}

aSaveLines	:= FWSaveRows()

For nFor := 1 To oModelCNU:Length()
	oModelCNU:GoLine(nFor)
	
	If !oModelCNU:IsDeleted()
		nTotPerc += oModelCNU:GetValue("CNU_PERCCM")

		If nTotPerc > 100 //-- Verifica o percentual de comissão
	   		Help(" ",1,"CNTA300PVE")	//-- Execedeu o percentual maximo de comissão dos vendedores
	   		lRet := .F.
		Endif
	EndIf

	If !lRet
		Exit
	EndIf
Next nFor

FWRestRows(aSaveLines)
FwFreeArray(aSaveLines)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300CTVld
Valida o cabecalho do contrato

@author Leandro.Moura
@since 23/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300CTVld(lEmRevisao as Logical)
Local lRet			:= .T.
Local oModel		:= FWModelActive()
Local oModelCN9	:= oModel:GetModel("CN9MASTER")
Default lEmRevisao := .F.

//-- Percentual minimo de caucao
If lRet .And. oModelCN9:GetValue("CN9_FLGCAU") == "1" .And. Empty(oModelCN9:GetValue("CN9_MINCAU"))
	Help(" ",1,"CNTA300PER")	//-- Preencha o percentual minimo de caucao
	lRet := .F.
EndIf

//-- Tipo de tratamento da caucao
If lRet .And. oModelCN9:GetValue("CN9_FLGCAU") == "1" .And. Empty(oModelCN9:GetValue("CN9_TPCAUC"))
	Help(" ",1,"CNTA300TPC")	//-- Informe o tipo de tratamento da caucao
	lRet := .F.
EndIf


If lRet
	lRet := CN300VldRj(oModel)//Valida Indice de reajuste
EndIf

If (!lEmRevisao)//Validacoes nao realizadas durante a inclusao da revisao	
	//-- Moeda Corrente
	If lRet .And. (oModelCN9:GetValue("CN9_MOEDA") < 1 .Or. oModelCN9:GetValue("CN9_MOEDA") > MOEDFIN())
		Help(" ",1,"CNTA300MOE") //-- Preencha a moeda corrente
		lRet := .F.
	EndIf

	//-- Valida diario contabil - Portugal
	If lRet .And. cPaisloc == "PTG"
		lRet := CTBVldDiario(M->CN9_DIACTB)
	EndIf

	//-- Validacoes especificas durante a aprovacao da revisao
	If !Empty(cAprTipRev) .And. lRet .And. !FwIsInCallStack('A097ProcLib') .And. !FwIsInCallStack('A097ProcSup')
		If lRet:= cn300VlCau()
			If lRet .And. cAprTipRev == DEF_REV_PARAL
				lRet := CN100Doc(CN9->(Recno()),{DEF_SPARA,DEF_SREVS},.F.)
			Else
				lRet := CN100Doc(CN9->(Recno()),{DEF_SREVS},.F.)
			EndIf
		EndIf
		//--Gera Base Instalada e Ordem de Servico³
		If lRet .And. SuperGetMv("MV_CNINTFS",.F.,.F.) .And. CN9->CN9_ESPCTR == '2'
			lRet := CN100BIns(CN9->CN9_NUMERO,CN9->CN9_REVISA,CN9->CN9_DTASSI)
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VldRj
Valida campos de reajuste do contrato
(Funcao anteriormente chamada CN300RjVld, renomeada por existir funcao de mesmo nome no CNTA300R)
@author Marcelo Ferreira
@since 03/09/2015
@version T12.7
/*/
//-------------------------------------------------------------------
Static Function CN300VldRj(oModel)
Local lRet      := .T.
Local oModelCN9	:= Nil
Default oModel	:= FWModelActive()

oModelCN9 := oModel:GetModel("CN9MASTER")
//-- Indice de reajuste
If oModelCN9:GetValue("CN9_FLGREJ") == "1"
	If Empty(oModelCN9:GetValue("CN9_INDICE"))
		Help(" ",1,"CNTA300IND")	//-- Preencha o indice de reajuste do contrato
		lRet := .F.
	EndIf
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300GRV
Tratamentos na gravacao do contrato

@author Leandro.Moura
@since 25/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300Grv( oModel )
Local aArea		:= GetArea()
Local dTermino	:= CtoD("")
Local lMedeve	:= .F.
Local lRecorre  := .F.
Local lAprova	:= FWIsInCallStack('A097ProcLib') .Or. FWIsInCallStack('A097ProcSup') .Or. FWIsInCallStack('Cn300Aprov')
Local lInclui	:= oModel:GetOperation() == MODEL_OPERATION_INSERT .And. Empty(cTipRevisa)
Local lRevisa	:= oModel:GetOperation() == MODEL_OPERATION_INSERT .And. !Empty(cTipRevisa) .And. Empty(cAprTipRev) .And. !lAprova
Local lAltera	:= oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. Empty(cAprTipRev) .And. Empty(cTipRevisa) .And. !lAprova
Local lExclui	:= oModel:GetOperation() == MODEL_OPERATION_DELETE
Local nStack    := GetSX8Len()
Local nI		:= 0
Local nX		:= 0
Local oModelCN9	:= oModel:GetModel("CN9MASTER")
Local oModelCNN	:= oModel:GetModel("CNNDETAIL")
Local oModelCNU := oModel:GetModel("CNUDETAIL")
Local oModelCNA := oModel:GetModel("CNADETAIL")
Local lAlterRev	:= oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. !Empty(cTipRevisa)
Local cEspCtr	:= oModelCN9:GetValue('CN9_ESPCTR')
Local cGrpAprAn	:= ""
Local cGrpAprAt	:= ""
Local lRet		:= .T.
Local lEmpenho	:= .T.
Local lNotaEmp	:= SuperGetMV("MV_NOTAEMP",.F.,.F.)
Local lPCOINTE	:= SuperGetMV("MV_PCOINTE",.F.,"2") == "1"
Local lFluig	:= SuperGetMV("MV_APWFECM",.F.,"1") == "1" .And. !Empty(AllTrim(GetNewPar("MV_ECMURL",""))) .And. FWWFFluig()
Local lAglFlg	:= SuperGetMV("MV_CNAGFLG",.F.,.F.)	//- Aglutinação de aprovações no Fluig
Local lContinua	:= .T.
Local lGerApr	:= .F.
Local lCommit	:= .T.
Local lFilSC		:= CNB->(FieldPos("CNB_FILSC")) > 0 .And. FWModeAccess("SC1",1)+FWModeAccess("SC1",2)+FWModeAccess("SC1",3) != "CCC"
Local cFilCNB	:= xFilial("CNB")
Local cFilCTR   := IIF(lInclui, cFilAnt, oModelCN9:GetValue("CN9_FILCTR"))
Local cFilSC	:= ""
Local lC100VlAt	:= CN300VLAT(oModel)
Local cCodUser  := ""
Local cCodGest  := ""
Local cOperac   := ""
Local lMTSoliCAT:= ExistBlock('MTSoliCAT') 	  // Função Fluig (descontinuado)
Local lCnAlcFlg := ExistBlock("CnAlcFlg")  	  // Função Fluig (descontinuado)
Local lLowR033	:= GetRPORelease() < "12.1.033"
Local lFMTSoliCAT:= FindFunction('MTSoliCAT') .And. lLowR033
Local lFCnAlcFlg := FindFunction("CnAlcFlg")  .And. lLowR033
Local lEstAprCTB := SuperGetMV("MV_ESTAPCT",.F.,.T.)


Private lMsErroAuto	:= .F.
Private aFluigIR	:= {}

Begin Transaction

If !lExclui
	If  !lAlterRev //-- Não cai se estiver alterando uma revisão
		If cTipRevisa <> '' //-- Tratamentos da Revisão
			CnRevAtu(CN9->CN9_NUMERO, oModelCN9:GetValue("CN9_REVISA"),'1') //-- Altera a revisao atual.

			oModelCN9:GetStruct():SetProperty('CN9_REVATU',MODEL_FIELD_WHEN,{||.T.})
			oModelCN9:SetValue('CN9_REVATU', '')
			oModelCN9:GetStruct():SetProperty('CN9_REVATU',MODEL_FIELD_WHEN,{||.F.})

			If cTipRevisa == DEF_REV_REALI .And. !lAlterRev
				CNAddItRt()
			EndIf
		EndIf

	ElseIf cTipRevisa <> ''
		CN300GerApr(oModelCN9,3,oModel:GetOperation()) //Exclui SCR gerada do contrato
	EndIf
ElseIf !Empty(oModelCN9:GetValue("CN9_TIPREV"))
	oModel:GetModel('CNNDETAIL'):SetOnlyQuery(.T.)
EndIf

//-- Calcula dia de termino
dTermino := CN100DtFim(oModelCN9:GetValue("CN9_UNVIGE"),oModelCN9:GetValue("CN9_DTINIC"),oModelCN9:GetValue("CN9_VIGE"), .F.)

If (lInclui .Or. lAltera .Or. lRevisa) .And. Empty(cAprTipRev) .And. !lAlterRev .And. !lAprova
	//-- Insere filial original
	If Empty(oModelCN9:GetValue("CN9_FILORI"))
        If lInclui
		    oModelCN9:LoadValue("CN9_FILORI", cFilAnt)
        Else
            oModelCN9:LoadValue("CN9_FILORI", oModelCN9:GetValue("CN9_FILCTR"))
        EndIf
	EndIf
	If lInclui .Or. lAltera

		//-- Quando rejeitado deve limpar as aprovações.
		If oModelCN9:GetValue("CN9_SITUAC") == DEF_SREJE

			//Verifica se já existe registro na SCR para deletar
			dbSelectArea("SCR")
			SCR->(dbSetOrder(2))
			If SCR->(dbSeek(xFilial("SCR",cFilAnt)+"CT"+oModelCN9:GetValue("CN9_NUMERO")))
				MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_LIBAPRO,,},,3)
			EndIf

			If SCR->(dbSeek(xFilial("SCR",cFilAnt)+"IC"+oModelCN9:GetValue("CN9_NUMERO")))
				While !SCR->(EOF()) .AND. SCR->(CR_FILIAL+CR_TIPO+Left(SCR->CR_NUM,Len(CN9->CN9_NUMERO))) == xFilial("SCR",cFilAnt)+"IC"+oModelCN9:GetValue("CN9_NUMERO")
					MaAlcDoc({SCR->CR_NUM,"IC",SCR->CR_TOTAL,SCR->CR_LIBAPRO,,},,3)
					SCR->(dbSkip())
				EndDo
			EndIf
		EndIf
        
        If lInclui //-- Insere filial origem do contrato
		    oModelCN9:SetValue('CN9_FILCTR',cFilAnt)
        EndIf

		//-- Insere situação como 'Em elaboração'		
        If !lC100VlAt
			oModelCN9:SetValue("CN9_SITUAC",DEF_SELAB)
		EndIf

		//-- Insere data de termino
		oModelCN9:SetValue("CN9_DTFIM",dTermino)

		//-- Zera a vigencia caso seja indeterminada
		If oModelCN9:GetValue("CN9_UNVIGE") == "4" .And. oModelCN9:GetValue("CN9_VIGE") # 0
			oModelCN9:LoadValue("CN9_VIGE",0)
		EndIf
	EndIf
EndIf

If !lExclui
	CN300PlnGr( oModel, lAprova)	
EndIf

If !Empty(cAprTipRev) .Or. lAprova//-- Tratamentos da Aprovação<chamar após CN300PlnGr>

	If lEstAprCTB 
		CN290ESTOR(CN9->CN9_NUMERO) //Efetua o estorno da apropriação contabil por item do cronograma contabil, utilizando o LP 69J
	EndIf

	lMedeve	:= Cn300RetSt("MEDEVE",2)
	lRecorre:= Cn300RetSt("RECORRENTE",2)
	A300Aprov(oModel,oModelCN9:GetValue("CN9_REVISA"),lMedeve,lRecorre)

	//-- Atualização da nota de empenho
	If lNotaEmp .And. (cAprTipRev $ DEF_REV_ADITI+'|'+DEF_REV_REALI+'|'+DEF_REV_READE+'|'+DEF_REV_REAJU+'|'+DEF_REV_RENOV+'|'+DEF_REV_ORCGS+'|'+DEF_REV_ABERT)
		lEmpenho := A300AtuNE(oModel)
	EndIf
EndIf

If lInclui .Or. lAltera
	//Gera permissão de controle sobre o contrato para o usuário / gestor
	cCodUser := Iif( lInclui, RetCodUsr(), "" )
	If CN9->( ColumnPos( "CN9_GESTC" ) ) > 0
		cCodGest := oModelCN9:GetValue( "CN9_GESTC" )
	EndIf
	cOperac := Iif( lInclui, "3", Iif( lAltera, "4", "") )
	GrvPermCNN( oModelCNN, cCodUser, cCodGest, cOperac, DEF_TRANS )
EndIf

//-- Rotina que deleta os registro que foram deletados fisicamente
If (lAltera .Or. lRevisa) 
	If lPCOINTE .And. Len(aDelsCNF) > 0
		A300PCOINT(oModel,cTipRevisa,cAprTipRev,,,,lExclui,.T.)//Exclui registros no PCO, antes da deleção fisica dos cronogramas.
	EndIf
	DelByRec("CNF", aDelsCNF)
	DelByRec("CNS", aDelsCNS)
	DelByRec("CNW", aDelsCNW)
	DelByRec("CNV", aDelsCNV)
EndIf

//REMOVER após o término da release 12.1.23
If 	(lAlterRev .Or. lRevisa) .And. oModelCNU:IsModified() .And. !(CNURevisa())
	A300RAtCNU(oModel) //Atualiza CNU
EndIf

If lExclui

	//Não exclui da tabela CPD se a revisão não estiver em branco, para não perder o permissionamento.
	If !Empty(oModelCN9:GetValue("CN9_REVISA"))
		oModel:GetModel('CPDDETAIL'):SetOnlyQuery(.T.)
	EndIf

	If lContinua
		//-- Tratamentos da Revisão
		If AllTrim(oModelCN9:GetValue("CN9_SITUAC")) $ DEF_SREVS+"|"+DEF_SREVA+"|"+DEF_SREJE .And. !Empty(oModelCN9:GetValue("CN9_TIPREV"))
			CN300GerApr(oModelCN9,3,oModel:GetOperation()) 	//- Exclui SCRs geradas para revisão
			If  !lAlterRev
				CNA300RvMd(oModelCN9:GetValue("CN9_NUMERO"),;	//cExp01 - Codigo do contrato selecionado
				CnRevAnt(),;									//cExp02 - Codigo da revisao selecionada
				oModelCN9:GetValue("CN9_REVISA"),;				//cExp03 - Codigo da revisao gerada
				CN9->CN9_FILCTR)								//cExp04 - Filial do contrato
			EndIf
			LimpaSCInt(CN9->CN9_NUMERO, CN9->CN9_REVISA)
			CnRevAtu(CN9->CN9_NUMERO,oModelCN9:GetValue("CN9_REVISA"),'2') //-- Altera a revisao atual.
			cn300AtuGCT(CN9->CN9_FILIAL,CN9->CN9_NUMERO,CN9->CN9_REVISA,' ')
		Else
			//-- Exclui a amarracao com os conhecimentos
			MsDocument("CN9",CN9->(Recno()),2,,3)
			If cEspCtr == "1" //-- Somente executar quando for contrato de compras
				CNB->(dbSetOrder(1))
				If CNB->(dbSeek(cFilCNB+CN9->(CN9_NUMERO+CN9_REVISA)))
					While !CNB->(EOF()) .And. CNB->(CNB_FILIAL+CNB_CONTRA+CNB_REVISA) == cFilCNB+CN9->(CN9_NUMERO+CN9_REVISA)
						If lFilSC .And. !Empty(CNB->CNB_FILSC) .And. !Empty(CNB->CNB_ITEMSC)
							cFilSC := CNB->CNB_FILSC //Filial de origem da SC
						Else
							cFilSC := xFilial("SC1", cFilCTR)
						EndIf
						
						If !Empty(CNB->CNB_ITEMSC)
							If !Empty(CN9->CN9_NUMCOT)
								ProcCotSC(oModel,.T.,cFilSC)
							Else
								SC1->(dbSetOrder(1))
								If SC1->(dbSeek(cFilSC+CNB->(CNB_NUMSC+CNB_ITEMSC)))
									RecLock("SC1")
									SC1->C1_FLAGGCT := ""
									SC1->(MsUnlock())
								EndIf
							EndIf
						ElseIf !Empty(CN9->CN9_CODED)
							SC1->(dbOrderNickName("GCP01"))
							If SC1->(dbSeek(cFilSC+CN9->(CN9_CODED+CN9_NUMPR)+CNB->CNB_PRODUT))
								While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_CODED+C1_NUMPR+C1_PRODUTO) == cFilSC+CN9->(CN9_CODED+CN9_NUMPR)+CNB->CNB_PRODUT
									RecLock("SC1",.F.)
									SC1->C1_FLAGGCT	:= ""
									SC1->(MsUnlock())
									SC1->(dbSkip())
								End
							EndIf
						EndIf
						CNB->(dbSkip())
					EndDo
				ElseIf !Empty(CN9->CN9_NUMCOT)
					ProcCotSC(oModel)
				EndIf
			EndIf
			For nX:= 1 to oModelCNA:Length()
				oModelCNA:GoLine(nX)
				CN300DelAGW(CN9->CN9_NUMERO,oModelCNA:GetValue("CNA_NUMERO")) //-- Exclui localizacao fisica AGW
			Next
		EndIf
	EndIf
EndIf

//-- Confirma num. sequencial e executa os gatilhos
If !Empty(cTipRevisa)
	While GetSX8Len() > nStack
		RollBackSX8()
	End
Else
	While GetSX8Len() > nStack
		ConfirmSX8()
	End
EndIf

If lAdiant
	lRet := GerTitAdian(oModel)	//-- Processa os adiantamentos
	lCommit:= lRet
	If !lCommit
		oModel:SetErrorMessage(,,,,"ErroAdt",STR0326)
	EndIf
EndIf

lRevisado	:= .F.
lUserBut	:= .F.

// Realiza estorno dos lancamentos do PCO na exclusao do contrato e na exclusao do cronograma
If lPCOINTE .And. ( lExclui .Or. lDelCrg )
	A300PCOINT(oModel,cTipRevisa,cAprTipRev,,,,lExclui,lDelCrg)
EndIf

If cTipRevisa == DEF_REV_GRAPR .Or. cTipRevisa == DEF_REV_ABERT//-- "B" Salva o grupo Anterior e grupo ATual.
	cGrpAprAn := CN9->CN9_APROV
	cGrpAprAt := oModelCN9:GetValue("CN9_APROV")
EndIf

If ExistBlock("CN300PCMT") //- Ponto de entrada para atuações pré-commit
	lCommit := ExecBlock("CN300PCMT",.F.,.F.,{oModel})
	If ValType(lCommit) != 'L'
		lCommit := .T.
	EndIf
EndIf

If lCommit
	//-- Atualiza CX4 caso tenha sido incluso Art. de excessão
	If !Empty(aIncArt)
		lCommit := .T.
		For nX := 1 To Len(aIncArt)
			If lCommit .And. RecLock('CX4',.T.)
				CX4->CX4_FILIAL := aIncArt[nX,1]
				CX4->CX4_CODEDT := aIncArt[nX,2]
				CX4->CX4_NUMPRO := aIncArt[nX,3]
				CX4->CX4_MODALI := aIncArt[nX,4]
				CX4->CX4_LEI 	:= aIncArt[nX,5]
				CX4->CX4_ARTIGO := aIncArt[nX,6]
				CX4->(MsUnlock())
			Else
				lCommit := .F.
			EndIf
		Next
		lCommit := lCommit .And. FWFormCommit(oModel)
	Else
		lCommit := FWFormCommit(oModel)
	EndIf
EndIf

If !lCommit .Or. (lAdiant .And. !lRet) .Or. (!lEmpenho)
	DisarmTransaction()
Else
	// Realiza os lancamentos do PCO na inclusao do contrato e na aprovacao da revisao
	If lPCOINTE .And. lCommit .And. !lExclui .And. !lDelCrg
		A300PCOINT(oModel,cTipRevisa,cAprTipRev)
	EndIf

	If !lExclui
		//-- Grava campos memo
		MSMM(oModelCN9:GetValue("CN9_CODOBJ"),,,oModelCN9:GetValue("CN9_OBJCTO"),1,,,"CN9","CN9_CODOBJ")
		MSMM(oModelCN9:GetValue("CN9_CODCLA"),,,oModelCN9:GetValue("CN9_ALTCLA"),1,,,"CN9","CN9_CODCLA")
		MSMM(oModelCN9:GetValue("CN9_CODJUS"),,,oModelCN9:GetValue("CN9_JUSTIF"),1,,,"CN9","CN9_CODJUS")
	EndIf

	If (lCommit .And. lInclui)	
		CtrMetric((cEspCtr == "1"))
	EndIf
EndIf

End Transaction

//== Gera aprovações ====================================================================================================
If lCommit .And. (lRevisa .Or. lAlterRev)
	lGerApr := .F.

	If cTipRevisa == DEF_REV_GRAPR .Or. cTipRevisa == DEF_REV_ABERT //-- "B" Gera aprovação para grupo anterior.
		If !Empty(cGrpAprAn)
			oModelCN9:LoadValue("CN9_APROV",cGrpAprAn)
			CN300GerApr(oModelCN9 ,1,oModel:GetOperation())
			lGerApr := .T.
			oModelCN9:LoadValue("CN9_APROV",cGrpAprAt)
		EndIf
	EndIf

	If !lGerApr
		lGerApr := CN300GerApr(oModelCN9 ,1,oModel:GetOperation()) //Efetua a geração da SCR referente ao contrato
	EndIf

	If lFluig .And. lGerApr
		If !Empty(oModelCN9:GetValue("CN9_APROV")) .Or. (cTipRevisa == DEF_REV_GRAPR .Or.  cTipRevisa == DEF_REV_ABERT)	// Revisao Gr. Aprovacao/Aberta
			If lCnAlcFlg
				ExecBlock("CnAlcFlg", .F., .F., {oModelCN9:GetValue("CN9_NUMERO"),oModelCN9:GetValue("CN9_REVISA"),"RV"})
			Elseif lFCnAlcFlg
				CnAlcFlg(oModelCN9:GetValue("CN9_NUMERO"),oModelCN9:GetValue("CN9_REVISA"),"RV")
			Endif
		Else // Alçada apenas para o Tipo IR
			If lAglFlg
				If lCnAlcFlg
					ExecBlock("CnAlcFlg", .F., .F., {oModelCN9:GetValue("CN9_NUMERO"),oModelCN9:GetValue("CN9_REVISA"),"IR"})
				Elseif lFCnAlcFlg
					CnAlcFlg(oModelCN9:GetValue("CN9_NUMERO"),oModelCN9:GetValue("CN9_REVISA"),"IR")
				Endif
			Else
				For nI := 1 To Len(aFluigIR)
					If lMTSoliCAT
						ExecBlock("MTSoliCAT", .F., .F., {"IR",aFluigIR[nI],"CN9","CR_NUM"})
					Elseif lFMTSoliCAT
						MTSoliCAT("IR",aFluigIR[nI],"CN9","CR_NUM")
					Endif
				Next nI
			EndIf
		Endif
	EndIf
EndIf

//========================================================================================================================
//Limpa as variaveis de controle da Revisao e Aprovacao
cTipRevisa 	:= ''
cAprTipRev 	:= ''
lRevisado	:= .F.
lUserBut	:= .F.
lAdiant   	:= .F.
aIncArt		:= {}

RestArea(aArea)
Return lCommit
//-------------------------------------------------------------------
/*/{Protheus.doc} cn300AtuGCT
Rotina para Atualização da SC vinculada ao Contrato
Gravação do contrato

@author vitor.pires
@since 14/03/2019
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static function cn300AtuGCT(cFilCN9,cContra,cRevisa,cStatus)
Local cFilSC1	:= xFilial("SC1")
Local aAreaCNB 	:= {}
Local aRows		:= FwSaveRows()
Local cChave	:= xFilial('CNB')+cContra+cRevisa

CNB->(dbSetOrder(1))
If CNB->(dbSeek(cChave))
	aAreaCNB := CNB->(GetArea())
	While !CNB->(EOF()) .And. CNB->(CNB_FILIAL+CNB_CONTRA+CNB_REVISA) == cChave
		//-- Retira quantidade atendida da solicitacao de compra
		If !Empty(CNB->(CNB_NUMSC+CNB_ITEMSC))
			If Empty(CN9->CN9_NUMCOT)
				//-- Retira quantidade atendida da solicitacao de compra, desde que não exista na revisão anterior
				cSql := "UPDATE "+RetSqlName('SC1')+" SET C1_FLAGGCT='"+cStatus+"' WHERE C1_FILIAL='"+cFilSC1+"' AND C1_NUM = '"+CNB->CNB_NUMSC+;
						"' AND C1_ITEM='"+CNB->CNB_ITEMSC+"' AND D_E_L_E_T_ = ' ' "
				If ! Empty(cRevisa)
					cSql += 'AND NOT EXISTS('
					cSql += "SELECT 1 FROM "+RetSqlName('CNB')+" CNB WHERE CNB.CNB_FILIAL='"+xFilial("CNB")+"' AND CNB.CNB_CONTRA = '"+cContra+;
							"' AND CNB.CNB_REVISA='"+cnRevAnt()+"' AND CNB_NUMSC='"+CNB->CNB_NUMSC+"'AND CNB_ITEMSC='"+CNB->CNB_ITEMSC+;
							"'  AND CNB.D_E_L_E_T_ = ' ') "

				EndIf
	
				TcSqlExec(cSql)

			Endif
		ElseIf !Empty(CN9->CN9_CODED)

			cSql := "UPDATE "+RetSqlName('SC1')+" SET C1_FLAGGCT='"+cStatus+"' WHERE C1_FILIAL='"+cFilSC1+"' AND C1_CODED = '"+CN9->CN9_CODED+;
					"' AND C1_NUMPR='"+CN9->CN9_NUMPR+"' AND C1_PRODUTO = '"+CNB->CNB_PRODUT+"' AND D_E_L_E_T_ = ' ' "
		
			TcSqlExec(cSql)

		EndIf

		CNB->(dbSkip())
	EndDo
	CNB->(RestArea(aAreaCNB))
EndIf
FwRestRows(aRows)
Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300CANCE()
Ajustes no cancelamento da rotina

@author guilherme.pimentel
@since 22/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function CN300CANCE(oModel)
Local lRet	:= .T.

cTipRevisa 	:= ''
cAprTipRev 	:= ''
lRevisado  	:= .F.
lUserBut	:= .F.
aIncArt		:= {}

FWFormCancel(oModel)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VldFor
Rotina para validacao dos fornecedores do Contrato
Pre valid do modelo de fornecedores - Tabela CNC

@author Leandro.Moura
@since 23/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300VldFor(cAction,cField,xValue,xOldValue)
Local cCodigo	:= ""
Local cLoja		:= ""
Local lRet	   	:= .T.
Local nPlan		:= 0
Local oModel	:= FWModelActive()
Local oModelCN9	:= oModel:GetModel("CN9MASTER")
Local oModelCNA := oModel:GetModel("CNADETAIL")
Local oModelCNC	:= oModel:GetModel("CNCDETAIL")
Local oModelCN8	:= oModel:GetModel("CN8DETAIL")
Local aSaveLines:= FWSaveRows()
Local cCpoCodi	:= If(oModelCN9:GetValue("CN9_ESPCTR")=="1","CNA_FORNEC","CNA_CLIENT")
Local cCpoLoja	:= If(oModelCN9:GetValue("CN9_ESPCTR")=="1","CNA_LJFORN","CNA_LOJACL")
Local cCpoCodCNC:= If(oModelCN9:GetValue("CN9_ESPCTR")=="1","CNC_CODIGO","CNC_CLIENT")
Local cCpoLojCNC:= If(oModelCN9:GetValue("CN9_ESPCTR")=="1","CNC_LOJA","CNC_LOJACL")
Local cCpoCodCN8:= If(oModelCN9:GetValue("CN9_ESPCTR")=="1","CN8_FORNEC","CN8_CLIENT")
Local cCpoLojCN8:= If(oModelCN9:GetValue("CN9_ESPCTR")=="1","CN8_LOJA","CN8_LOJACL")
Local cCodValue	:= IIF(cField == cCpoCodCNC,xOldValue,oModelCNC:GetValue(cCpoCodCNC))
Local cLojValue	:= IIF(cField == cCpoLojCNC,xOldValue,oModelCNC:GetValue(cCpoLojCNC))

If cAction == "DELETE"
	cCodigo := oModelCNC:GetValue(If(oModelCN9:GetValue("CN9_ESPCTR") == "1","CNC_CODIGO","CNC_CLIENT"))
	cLoja := oModelCNC:GetValue(If(oModelCN9:GetValue("CN9_ESPCTR") == "1","CNC_LOJA","CNC_LOJACL"))

	//-- Verifica se pode deletar o fornecedor
	If !Empty(cCodigo) .And. ! Empty(cLoja)
		For nPlan := 1 to oModelCNA:Length()
			oModelCNA:GoLine(nPlan)
			If MTFindMVC(oModelCNA,{{cCpoCodi,cCodigo},{cCpoLoja,cLoja}}) > 0 .And.; //-- Usado em planilha
			 			MTFindMVC(oModelCNC,{{cCpoCodCNC,cCodigo},{cCpoLojCNC,cLoja}}) == oModelCNC:GetLine()
	   			Help(" ",1,If(oModelCN9:GetValue("CN9_ESPCTR")=="1","CNTA300FRN","CNTA300CLI")) //-- O # nao pode ser deletado pois pertence a uma planilha.
		   		lRet := .F.
		   		Exit
			EndIf
		Next nPlan
		For nPlan := 1 to oModelCN8:Length()
			oModelCN8:GoLine(nPlan)
			If MTFindMVC(oModelCN8,{{cCpoCodCN8,cCodigo},{cCpoLojCN8,cLoja}}) > 0 // Usado na caução
		   		Help(" ",1,"CNTA300CAU") //-- "O Fornecedor/Cliente não pode ser alterado, pois, existe uma caução relacionada. Realize as correções no Cadastro de Cauções"
		   		lRet := .F.
		   		Exit
			EndIf
		Next nPlan
	EndIf
EndIf

//Verifica se existe caução para o fornecedor e não permite a troca
If cAction == 'SETVALUE' .And. !Empty(xOldValue) .And. (cField == cCpoCodCNC .Or. cField == cCpoLojCNC)
	If !oModelCNC:IsInserted() .And. MTFindMVC(oModelCN8,{{cCpoCodCN8,cCodValue},{cCpoLojCN8,cLojValue}}) > 0
		Help(" ",1,"CNTA300CAU") //-- "O Fornecedor/Cliente não pode ser alterado, pois, existe uma caução relacionada. Realize as correções no Cadastro de Cauções"
	   	lRet := .F.
	EndIf
EndIf

If cAction == 'CANSETVALUE' .And. !Empty(xOldValue) .And. (cField == cCpoCodCNC .Or. cField == cCpoLojCNC)
	If cField == cCpoCodCNC
		cCodigo := xOldValue
		cLoja := oModelCNC:GetValue(If(oModelCN9:GetValue("CN9_ESPCTR") == "1","CNC_LOJA","CNC_LOJACL"))
	Else
		cCodigo := oModelCNC:GetValue(If(oModelCN9:GetValue("CN9_ESPCTR") == "1","CNC_CODIGO","CNC_CLIENT"))
		cLoja	:= xOldValue
	EndIf

	//-- Verifica se pode alterar o fornecedor/cliente
	For nPlan := 1 to oModelCNA:Length()
		oModelCNA:GoLine(nPlan)
		If 	MTFindMVC(oModelCNA,{{cCpoCodi,cCodigo},{cCpoLoja,cLoja}}) > 0 .And.;
			MTFindMVC(oModelCNC,{{cCpoCodCNC,cCodigo},{cCpoLojCNC,cLoja}}) == oModelCNC:GetLine()
			If oModelCN9:GetValue("CN9_ESPCTR") == "1"
				Alert(STR0137+STR0139)
			Else
				Alert(STR0138+STR0139)
			EndIf
		   	lRet := .F.
		   	Exit
		EndIf
	Next nPlan
EndIf


FWRestRows(aSaveLines)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VldPlan
Rotina para validacao na inclusao das planilhas do contrato
Pos validacao de linha da tabela CNA

@param nTpVld Tipo de validacao (1-Cabecalho, 2-Itens)
@param lVldLine Validacao de linha

@author Leandro.Moura
@since 23/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300VldPlan(nTpVld,lVldLine,oModelGrid)
Local aArea		 := GetArea()
Local aItensPla	 := {}
local aProp		 := {}
Local cProdGrp	 := ""
Local cProdut	 := ""
Local cFornec	 := ""
Local cLojFor	 := ""
Local cCronog	 := ""
Local cCtrmed	 := ""
Local cSitu		 := ""
Local cGcpFIAP	 := ""
Local cFilSC	 := ""
Local cFilScCTR	 := ""
Local cMsgProdSv := ""
Local lRet		 := .T.
Local lInclui	 := .F.
Local lExclui	 := .F.
Local lAltera	 := .F.
Local lProdCtr 	 := .F.
Local lVldPrd 	 := .T.
Local lFilSC	 := CNB->(FieldPos("CNB_FILSC")) > 0 .And. FWModeAccess("SC1",1)+FWModeAccess("SC1",2)+FWModeAccess("SC1",3) != "CCC"
Local nFor		 := 0
Local nCount	 := 0
Local nVlrTot	 := 0
Local nTotPlan	 := 0
Local oModel	 := If(oModelGrid <> Nil, oModelGrid:GetModel(),FwModelActive())
Local oModelCN9	 := oModel:GetModel("CN9MASTER")
Local oModelCNA  := oModel:GetModel("CNADETAIL")
Local oModelCNB  := oModel:GetModel("CNBDETAIL")
Local oModelCXM  := oModel:GetModel("CXMDETAIL")
Local oModelCNZ  := oModel:GetModel("CNZDETAIL")
Local oModelCXO  := Nil
Local oModelCXP	 := Nil
Local aSaveLines := FWSaveRows()
Local lFixo		 := Cn300RetSt("FIXO")
Local lContab	 := Cn300RetSt("CONTABIL")
Local lValor	 := Cn300RetSt("PREVFINANC")
Local lRecorrente:= CN300RetSt("RECORRENTE")
Local lServico	 := CN300RetSt("SERVIÇO")
Local lSemiProd  := Cn300RetSt("SEMIPROD")
Local lAlterRev	 := oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. !Empty(A300GTpRev())
Local lPcoInte	 := SuperGetMV("MV_PCOINTE",.F.,"2") == "1"
Local lVldPco	 := .T.
Local lC100VlAt	 := .F.
Local lTemServ	 := .F.
Local lTemProd	 := .F.
Local cFilCNF	 := ""
Local lNotImport := .F.
Local lComValor	 := VldVlrTotal() //Verifica se deve validar o Valor Total do Item

lInclui := oModel:GetOperation() == MODEL_OPERATION_INSERT
lAltera := oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. Empty(cAprTipRev) .And. !FWIsInCallStack('A097ProcLib') .And. !FWIsInCallStack('A097ProcSup') .And. !FWIsInCallStack('Cn300aprov')
lExclui := oModel:GetOperation() == MODEL_OPERATION_DELETE

If !Empty(oModelCN9:GetValue("CN9_FILCTR")) //-- Tratamento para Filial usada no posicionamento da SC1
	cFilScCTR := xFilial("SC1", oModelCN9:GetValue("CN9_FILCTR")) //-- Filial da SC baseada na Filial do Contrato
Else
	cFilScCTR := xFilial("SC1", cFilAnt) //-- Filial logada
EndIf

If !oModelCNA:IsDeleted() .And. !FWIsInCallStack("CN300CtrAdia") .And. lComValor
	cSitu := AllTrim( oModelCN9:GetValue("CN9_SITUAC") )
	If lFixo // so executa se tiver planilha
		//-- Verifica se a planilha possui cronograma e/ou medicoes
		If cSitu # DEF_SELAB .And. ( ( lAltera .And. ( cSitu $ ( DEF_SELAB + "|" + DEF_SREVS + "|" + DEF_SREVA + "|" + DEF_SREJE ) ) ) .Or. lExclui ) .And. lVldLine .And. !Empty(oModelCNA:GetValue("CNA_CRONOG")) .And. !lAlterRev
			cFilCNF		:= xFilial("CNF")
			lC100VlAt	:= CN300VLAT(oModel)
			cCronog := oModelCNA:GetValue("CNA_CRONOG")
			CNF->(dbSetOrder(1))

			If (!lC100VlAt .And. CNF->(dbSeek(cFilCNF+cCronog)))
				While CNF->(CNF_FILIAL+CNF_NUMERO) == cFilCNF+cCronog
					If !Empty(CNF->CNF_DTREAL)   
						Help(" ",1,"CNTA300SEL")	//-- A planilha selecionada não pode ser alterada  ou excluída pois a mesma possui medições já efetuadas.
						lRet := .F.
						Exit
					EndIf
					CNF->(dbSkip())
				EndDo
			EndIf
		EndIf
		//-- Validacoes do cabecalho da planilha
		If lRet .And. (lInclui .Or. lAltera) .And. (!lVldLine .Or. (nTpVld == 1))
			//-- Verifica se o fornecedor/cliente foi informado
			If lRet .And. ((oModelCN9:GetValue("CN9_ESPCTR") == "1" .And. (Empty(oModelCNA:GetValue("CNA_FORNEC")) .Or. Empty(oModelCNA:GetValue("CNA_LJFORN")))) .Or.;
						 	( oModelCN9:GetValue("CN9_ESPCTR") == "2" .And. (Empty(oModelCNA:GetValue("CNA_CLIENT")) .Or. Empty(oModelCNA:GetValue("CNA_LOJACL")))))
				Help(" ",1,If(oModelCN9:GetValue("CN9_ESPCTR") == "1","CNT300FPLCT","CNT300CPLCT"))
				lRet := .F.
			EndIf
			//-- Verifica reajuste contrato x planilha
			If lRet .And. oModelCNA:GetValue("CNA_FLREAJ") == '1' .And. oModelCN9:GetValue("CN9_FLGREJ") == '2'
				Help(" ",1,"CNT300PLRJ")	//-- Esta planilha não poderá ser Reajustada. O contrato desta planilha não possui Reajuste.
				lRet := .F.
			EndIf

			//-- Verifica se a planilha é recorrente
			If lRecorrente
				//-- Verifica se os campos de recorrencia estao preenchidos
				If lRet .And. ((Empty(oModelCNA:GetValue("CNA_PERIOD")) .Or. oModelCNA:GetValue("CNA_QTDREC") = 0 .Or. Empty(oModelCNA:GetValue("CNA_PROMED"))))
					Help(" ",1,"CNT300PLRC")	//-- Para planilha recorrente é necessário preencher os campos Periodicidade e Quantidade de Recorrências.
					lRet := .F.
				EndIf
			EndIf

			//-- Verifica o cronograma da planilha
			If lRet .And. !lVldLine
				lRet := CN300VldCrg(oModel,oModelCNA,cSitu,lPcoInte)
			EndIf

			//-- Verifica o cronograma da contabil
			If lRet .And. !lVldLine
				lRet := CN300VldCtb(oModel,oModelCNA)
			EndIf
			
			If lRet
				If (oModelCNB:Length(.T.) == 0) //-- Verifica se a planilha contem itens
					Help(" ",1,"CNTA300PLA")  //-- Insira um item na planilha
					lRet := .F.
				ElseIf(lExclui)
					aItensPla := CN300GetPIt()
					For nFor := 1 To Len(aItensPla)
						If !(lRet := MaAvalPerm(1,{aItensPla[nFor,2],"CNT200",5}))
							Help(,,1,'SEMPERM')	//-- Usuário sem permissão para utilizar esta rotina.
							Exit
						EndIf
					Next nFor
					FwFreeArray(aItensPla)
				EndIf
			EndIf
		EndIf

		//-- Valida os itens da planilha
		If lRet .And. (lInclui .Or. lAltera) .And. (lVldLine .Or. nTpVld == 2)
			lProdCtr	:= GetNewPar("MV_PRODCTR",.F.)
			lVldPrd		:= GetNewPar("MV_CNVLAMR","N") == "S"
			cGcpFIAP	:= SuperGetMV("MV_GCPFIAP", .T., "C")
			lNotImport	:= !FWIsInCallStack("CN300AddPrd") .And. !FWIsInCallStack("CN300AddPC")
			nFor := 1
			While lRet .And. nFor <= oModelCNB:Length()
				//-- Caso seja validacao de linha posiciona na linha atual
				If lVldLine
					nFor := oModelCNB:nLine
				EndIf
				oModelCNB:GoLine(nFor)
				If !oModelCNB:IsDeleted()
					cProdut := oModelCNB:GetValue("CNB_PRODUT")
					//-- Verifica se o valor total esta correto
					nVlrTot := oModelCNB:GetValue("CNB_VLTOT")					
					
					If lNotImport //Se nao estiver processando a importacao de uma SC ou pedido de compra					
						If lServico .And. Empty(oModelCNB:GetValue("CNB_VLUNIT"))//Planilha de servico deve ter apenas o valor unitario validado
							Help(" ",1,"CNPRECO",,STR0070 + oModelCNB:GetValue("CNB_ITEM") + STR0088 + oModelCNB:GetValue("CNB_NUMERO") + STR0089,1,1) //-- O item ## da planilha ### não teve preço informado.								
							lRet := .F.
						ElseIf(!lServico .And. Empty(nVlrTot) .And. (oModelCNB:GetValue("CNB_VLUNIT") * oModelCNB:GetValue("CNB_QUANT") == 0))//Demais planilhas devem ter o total validado.
							Help(" ",1,"OBRIGAT2",,CRLF + RetTitle("CNB_VLUNIT"),4,1)
							lRet := .F.
						EndIf
					EndIf

					//Verifica se é Duplicata ou Pedido no tipo de contrato selecionado
					If CN1->(dbSeek(xFilial("CN1")+M->CN9_TPCTO))
						cCtrmed := CN1->CN1_CTRMED
					EndIf

					//-- Valida produto com Contrato de Parceria
					If lRet .And. !lProdCtr
						SB1->(dbSetOrder(1))
						If SB1->(dbSeek(xFilial("SB1")+cProdut)) .And. SB1->B1_CONTRAT == 'S'
							Help(" ",1,"CNTA300PRD")	//-- Produto inválido para o item. Este produto possui  Contrato de Parceria.
							lRet := .F.
						EndIf
					EndIf

					//-- Valida produto em relacao a solicitacao de compra
					If lRet .And. !Empty(oModelCNB:GetValue("CNB_NUMSC")) 
						SC1->(dbSetOrder(1))
						
						If lPEVLSC
							//PE para posicionar na SC
							lRet := ExecBlock("A300VLSC",.F.,.F.,{oModel})
							If !(Valtype(lRet) == 'L')
								lRet := .F.
							EndIf	
						ElseIf !Empty(oModelCN9:GetValue("CN9_CODED")) .And. ( cGcpFIAP == "E" ) .And. !Empty(oModelCN9:GetValue("CN9_FILEDT"))
							lRet := SC1->(dbSeek(xFilial("SC1", oModelCN9:GetValue("CN9_FILEDT"))+oModelCNB:GetValue("CNB_NUMSC")+oModelCNB:GetValue("CNB_ITEMSC")))
						Else
							If lFilSC .And. !Empty(oModelCNB:GetValue("CNB_FILSC"))
								cFilSC := oModelCNB:GetValue("CNB_FILSC") //-- Filial de Origem da SC
							Else
								cFilSC := cFilScCTR //Filial da SC baseada na Filial do Contrato
							EndIf
							lRet := SC1->(dbSeek(cFilSC+oModelCNB:GetValue("CNB_NUMSC")+oModelCNB:GetValue("CNB_ITEMSC")))
						EndIf

						If !lRet .Or. !(SC1->C1_PRODUTO == cProdut)
							Help(" ",1,"CNTA300INV")	//-- Produto inválido para o item.
							lRet := .F.
						EndIf
					EndIf

					//-- Valida amarracao produto X fornecedor
					If lRet .And. lVldPrd .And. !Empty(oModelCNA:GetValue("CNA_FORNEC")+oModelCNA:GetValue("CNA_LJFORN"))
						cFornec	:= oModelCNA:GetValue("CNA_FORNEC")
						cLojFor	:= oModelCNA:GetValue("CNA_LJFORN")

						SA5->(dbSetOrder(1))
						If SA5->(dbSeek(xFilial("SA5")+cFornec+cLojFor+cProdut))
							cProdGrp := Posicione("SB1",1,xFilial("SB1")+cProdut,"B1_GRUPO")

							SAD->(dbSetOrder(1))
							If !Empty(cProdGrp) .And. !SAD->(dbSeek(xFilial("SAD")+cFornec+cLojFor+cProdGrp))
								Help(" ",1,"CNT300FPROD")	//-- O produto não está amarrado ao fornecedor informado. Verifique a amarração produto X fornecedor.
								lRet := .F.
							EndIf
						EndIf
					EndIf

					//-- Valida permissao de Produto
					If lRet .And. !lExclui
						lRet := CN200FldOk()
					EndIf

					//-- Valida rateio do item por CC
					If lRet .And. !lExclui
						If VALTYPE(oModel) == 'O' .AND. VALTYPE(oModel:GetModel("CNZDETAIL")) == 'O'
							lRet := CN300VldRat(,,oModel:GetModel("CNZDETAIL"))
						Else
							lRet := CN300VldRat()
						EndIf
					EndIf

					If lRet .And. (lRecorrente .And. Empty(oModelCNB:GetValue("CNB_ATIVO")))//-- Verifica se a planilha é recorrente e não foi informado o campo CNB_ATIVO
						Help(" ",1,"CN300RCAT",, STR0224 + oModelCNB:GetValue("CNB_ITEM") + STR0088 + STR0225 +;
						oModelCNA:GetValue("CNA_NUMERO") + STR0226 ,1,1) //-- O item ## da planilha ### não teve preço informado.
						lRet := .F.						
					EndIf
				EndIf
			
				If lRet .And. oModelCNB:GetValue("CNB_SLDMED") > 0
					//Valida amarração contábil
					lRet := GctAmarra(oModelCNB:GetValue("CNB_CONTA"), oModelCNB:GetValue("CNB_CC"),oModelCNB:GetValue("CNB_ITEMCT"), oModelCNB:GetValue("CNB_CLVL"), "CNB", oModelCNB)					
				EndIf

				If !lRet .Or. lVldLine
					Exit
				Else
					If !lRecorrente
						nTotPlan += nVlrTot - oModelCNB:GetValue("CNB_VLDESC")
					ElseIf oModelCNB:GetValue("CNB_ATIVO") == "1"
						nTotPlan += nVlrTot - oModelCNB:GetValue("CNB_VLDESC")
					Endif
				EndIf
			End Do

			If lRet .And. !lVldLine .And. nTotPlan <= 0
				Help(" ",1,"CNT300TOTPL")	//-- O valor total da planilha não pode ser zero ou negativa.
				lRet := .F.
			EndIf
		EndIf

		//-- Se possui cronograma fisico, adiciona item incluido
		If lRet .And. nTpVld == 2 .And. lVldLine .And. Cn300RetSt("FISICO") .And. !FWIsInCallStack("A300DivCNB")
			CN300AddFis(oModel,oModelCNB:GetValue("CNB_ITEM"),oModelCNB:GetValue("CNB_PRODUT"),oModelCNB:GetValue("CNB_QUANT"))
		EndIf

		If lRet .And. (nTpVld == 1 .Or. !lVldLine)
			If !Empty(cTipRevisa) .And. !Cn300RetSt("MEDEVE") .And. !Cn300RetSt("RECORRENTE") .And. (cTipRevisa == DEF_REV_ADITI .Or. cTipRevisa == DEF_REV_REALI .Or. cTipRevisa == DEF_REV_READE .Or. cTipRevisa == DEF_REV_REINI .Or. cTipRevisa == DEF_REV_RENOV .Or. cTipRevisa == DEF_REV_ORCGS .Or. cTipRevisa == DEF_REV_ABERT)
				aProp := GetPropMdl(oModelCNA)
				CNTA300BlMd(oModelCNA,.F.)

				oModelCNA:LoadValue('CNA_SADIST', CN300SdDt(oModel))
				If lContab
					oModelCNA:LoadValue('CNA_SADISC', CN300SdDC(oModel))
				EndIf

				RstPropMdl(oModelCNA,aProp)
				FwFreeArray(aProp)
			EndIf			
		EndIf
	EndIf
	// contrato fixo.
	If lRet .And. nTpVld == 1 .And. !lFixo .And. lValor .And. oModelCNA:GetValue("CNA_VLTOT") == 0 .And. !Empty(oModelCNA:GetValue("CNA_TIPPLA"))
		Help(" ",1,"CNTA300PRV",,STR0184 + oModelCNA:GetValue("CNA_NUMERO") + STR0202,1,1)
		lRet := .F.
	Endif

	If Cn300RetSt('SEMIFIXO')
		If Cn300RetSt('SEMIAGRUP')
			//-- Validação de grupo preenchido
			nCount := 1
			lRet := .F.

			While nCount <= oModelCXM:Length()
				oModelCXM:GoLine(nCount)
				If !oModelCXM:IsDeleted()
					lRet := .T.
				EndIf
				nCount++
			End
			If !lRet
				Help(" ",1,"A300GrpVazio",,STR0184 + oModelCNA:GetValue("CNA_NUMERO") + STR0203,1,1)
			EndIf

			//-- Validação de Itens não preenchidos
			If lRet .And. Empty(oModelCXM:GetValue('CXM_AGRTIP')) .And. Empty(oModelCXM:GetValue('CXM_AGRGRP')) .And. Empty(oModelCXM:GetValue('CXM_AGRCAT'))
				lRet := .F.
				Help(" ",1,"A300GrpVazio",,STR0184 + oModelCNA:GetValue("CNA_NUMERO") + STR0203,1,1)
			EndIf
		//-- Validação do SemiFixo por Produto, onde tem que informar o total da Planilha
		ElseIf nTpVld == 1 .And. oModelCNA:GetValue("CNA_VLTOT") == 0 .And. !Empty(oModelCNA:GetValue("CNA_TIPPLA")) .And. !oModelCNA:IsDeleted()
			Help(" ",1,"CNTA300PRV",,STR0184  + oModelCNA:GetValue("CNA_NUMERO") + STR0202,1,1)
			lRet := .F.
		ElseIf nTpVld == 2 .And. oModelCNB:GetValue("CNB_VLUNIT") == 0
			Help("",1,"CN300SFIXIT",,STR0204,1,1)
			lRet := .F.
		ElseIf lRet .And. oModelCNA:GetValue("CNA_SALDO") > 0 .Or. oModelCNB:GetValue("CNB_VLUNIT") > 0
			//Valida amarração contábil
			lRet := GctAmarra(oModelCNB:GetValue("CNB_CONTA"), oModelCNB:GetValue("CNB_CC"),oModelCNB:GetValue("CNB_ITEMCT"), oModelCNB:GetValue("CNB_CLVL"), "CNB", oModelCNB)
		EndIf
	ElseIf !lFixo .And. lValor .And. oModelCNA:GetValue("CNA_VLTOT") == 0 .And. !Empty(oModelCNA:GetValue("CNA_TIPPLA"))
		Help(" ",1,"CNTA300PRV",,STR0184  + oModelCNA:GetValue("CNA_NUMERO") + STR0202,1,1)
		lRet := .F.
	Endif
	
	//-- Verifica percentual de multiplas naturezas
	If lRet .And. !lVldLine .And. CnGatMNat(.T.)
		oModelCXO := oModel:GetModel('CXODETAIL')
		oModelCXP := oModel:GetModel('CXPDETAIL')
		lRet := CnMNPosMd(oModelCNA,oModelCXO,oModelCXP)
	EndIf
	
	If lRet .And. lPcoInte //-- Verifica se possui bloqueio orcamentario no SIGAPCO
		If nTpVld == 2 .And. ( cSitu == "02" .Or. Empty(cSitu))	// Em Elaboracao
			If lRet := A300PCOVld(oModel,"000354","02","CNTA300",.T.)	//-- Inclusao de Planilha - Itens
				lRet := VldPcoCNZ(oModelCNZ, "09")//Inclusão Rateios da Planilha(CNZ) - seq. 09
			EndIf
			If !lRet
				Help(" ",1,"CNTA300PCO",,STR0134,5,0)
				PcoFreeBlq("000354")
			EndIf			
		EndIf		
	EndIf

	If (lRet .And. nTpVld == 0) //Zero quando vier da funcao <CN300PlaTOK>

		If Cn300RetSt('VENDA')			
			lRet:= CN300VlPar(oModel)//-- Valida partes envolvidas do contrato
		EndIf

		If lRet			
			lVldPco := lPcoInte .And. ((cSitu == "05" .And. !Empty(cAprTipRev)) .Or. cSitu == "DR" )//"Aprovação Revisão de Planilha - Itens"
				
			For nFor := 1 To oModelCNB:Length()				 
				oModelCNB:GoLine(nFor)
				If !oModelCNB:IsDeleted()
					If lVldPco
						If lRet := A300PCOVld(oModel,"000354","04","CNTA300", .T., .F., .F.)							
							lRet := VldPcoCNZ(oModelCNZ, "10")//Revisão Rateios da Planilha(CNZ) - seq. 10
						EndIf

						If !lRet
							Help(" ",1,"CNTA300PCO",,STR0134,5,0)
							PcoFreeBlq("000354")
							Exit
						EndIf
					EndIf
					If lRet
						IF lSemiProd //Validacao anteriormente ficava na funcao <CN300PlaTOK>
							If Empty(oModelCNB:GetValue("CNB_PRODUT"))
								Help("",1,"Cn300NoPrd",,STR0227,4,1)
								lRet := .F.
								Exit
							ElseIf oModelCNB:GetValue("CNB_VLUNIT") == 0
								Help("",1,"Cn300NoVlUn",,STR0228,4,1)
								lRet := .F.
								Exit
							EndIf
						Else
							If (oModelCNB:GetValue('CNB_TIPO') == '2')
								lTemServ := .T.
							Else
								lTemProd := .T.
							EndIf
						
							If (lTemServ .And. lTemProd)//Substitui funcao <Cn300VlServ> por questão de perfomance
								lRet := .F.
								cMsgProdSv := StrTran(STR0304	, "XXX", oModelCNB:GetValue('CNB_ITEM'))
								cMsgProdSv := StrTran(cMsgProdSv, "YYY", oModelCNA:GetValue('CNA_NUMERO'))
								cMsgProdSv := StrTran(cMsgProdSv, "ZZZ", IIF(oModelCNB:GetValue('CNB_TIPO') == '2', STR0305 /*Serviço*/, STR0306 /*Produto*/))

								Help("",1,"A300ITMDIF",,STR0211,1,1,,,,,,{cMsgProdSv})//Item XXX da planilha YYY diverge dos demais itens. Tipo divergente: ZZZ
								Exit
							EndIf
						EndIf
					EndIf
				EndIf			
			Next nFor
		EndIf
	EndIf
		
	If(lRet .And. nTpVld == 1 .And. !Empty(oModelCNA:GetValue("CNA_TIPPLA")))
		lRet := CNA300VldPl(oModel)
	EndIf
Endif

FWRestRows(aSaveLines)
FwFreeArray(aSaveLines)
RestArea(aArea)
FwFreeArray(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300PlaTOK
Rotina para validacao das planilhas do contrato,
chamada antes da gravacao do modelo (TudoOk)

@author Leandro.Moura
@since 23/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300PlaTOK(lPcoInte)
Local aArea  		:= GetArea()
Local lRet	   		:= .T.
Local nCount		:= 1
Local oModel		:= FWModelActive()
Local oModelCNA 	:= oModel:GetModel("CNADETAIL")
Local oModelCN9		:= oModel:GetModel("CN9MASTER")
Local oModelCNB		:= oModel:GetModel("CNBDETAIL")
Local aSaveLines	:= FWSaveRows()
Local cSitu			:= ""
Local cCPOCliForn	:= ""
Local cCampoLoja	:= ""
Local lVldPco		:= .F.
Local lTemPlan		:= .F.
Local cTipoRV		:= ""
Local lVldCrgRV		:= .F.
Default lPcoInte	:= .F.

//-- Verifica se possui bloqueio orcamentario no SIGAPCO
cSitu := oModelCN9:GetValue("CN9_SITUAC")
If lRet .And. lPcoInte	   
	If ( cSitu == "02" .Or. Empty(cSitu) )	// Em Elaboracao
		lVldPco := .T.
		If !(lRet := A300PCOVld(oModel,"000354","01","CNTA300",.F.))	//-- Inclusão de Planilha - Total
			Help(" ",1,"CNTA300PCO",,STR0134,5,0)
			PcoFreeBlq("000354")
		EndIf
	EndIf

	If ((cSitu == "05" .And. !Empty(cAprTipRev)) .Or. cSitu == "DR" ) .And. !(lRet := A300PCOVld(oModel,"000354","03","CNTA300",.F.)) //"Aprovação Revisão de Planilha - Total"
		Help(" ",1,"CNTA300PCO",,STR0134,5,0)
		PcoFreeBlq("000354")
	EndIf
EndIf

//Deleta linha em branco do modelo da tabela CNB
If oModelCNB:Length() > 1
	oModelCNB:GoLine(oModelCNB:Length())
	If Empty(oModelCNB:GetValue("CNB_PRODUT"))
		oModelCNB:DeleteLine()
	EndIf
EndIf


If lRet .And. lPcoInte
	PcoIniLan("000354") //-- Planilha de Contrato - SIGAGCT
EndIf

cTipoRV := IIF(Empty(cTipRevisa), cAprTipRev, cTipRevisa)
If lRet .And. !Empty(cTipoRV)
	lVldCrgRV := (	cTipoRV $ DEF_REV_ADITI+'|'+DEF_REV_REALI+'|'+DEF_REV_READE+'|'+;
					DEF_REV_CONTA+'|'+DEF_REV_RENOV+'|'+DEF_REV_ORCGS+'|'+DEF_REV_ABERT )
EndIf

If oModelCN9:GetValue("CN9_ESPCTR") == "1"//Verifica o tipo apenas 1x
	cCPOCliForn := "CNA_FORNEC"
	cCampoLoja	:= "CNA_LJFORN"
Else 
	cCPOCliForn := "CNA_CLIENT"
	cCampoLoja	:= "CNA_LOJACL"
EndIf

//-- Validacoes dos grids de cada planilha
While lRet .And. nCount <= oModelCNA:Length()
	oModelCNA:GoLine(nCount)

	If !oModelCNA:IsDeleted()		
		If (lRet := (!Empty(oModelCNA:GetValue(cCPOCliForn)) .And. !Empty(oModelCNA:GetValue(cCampoLoja))))
			lRet := VldCFCNC(oModel)//Valida fornecedor/cliente na CNC(essa validacao ficava na funcao <CN300TOK>)

			If lRet .And. (lRet := CN300VldPlan(0,.F.))//-- Valida o grid da planilha
				If !lTemPlan
					lTemPlan := .T.
				EndIf
			EndIf
		Else			
			Help(" ",1, IIF(Cn300RetSt('COMPRA'), "CN300NOFOR", "CN300NOCLI"),,STR0206 + oModelCNA:GetValue('CNA_NUMERO'),5,0)
		EndIf		
		
		If lRet .And. lVldPco
			lRet := A300PCOVld(oModel,"000354","01","CNTA300",.F., )//Inclusão de Planilha - Total
			If !lRet
				Help(" ",1,"CNTA300PCO",,STR0134,5,0)
				PcoFreeBlq("000354")
			EndIf
		EndIf

		If lRet .And. lVldCrgRV
			If Cn300RetSt("PREVFINANC") .And. !Cn300RetSt("MEDEVE") .And. !Cn300RetSt("RECORRENTE")				
				lRet := CN300VdCrg(oModel, !Empty(cAprTipRev)) //Validação ficava na função <CN300VldRV> anteriormente				
			EndIf
		EndIf
	EndIf
	nCount++
EndDo

If lPcoInte
	PcoFinLan("000354") // Planilha de Contrato - SIGAGCT
EndIf

If lRet .And. !lTemPlan //valida obrigatoriedade da planilha
	lRet := .F.
	Help(" ",1,"CN300NOPLA",,STR0208,5,0)
EndIf

FWRestRows(aSaveLines)
FwFreeArray(aSaveLines)

RestArea(aArea)
FwFreeArray(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300GetForn
Rotina para carregar o array com os fornecedores

@author Leandro.Moura
@since 23/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300GetForn(oModel)
	Local lResult	:= .F.
	Local nCount	:= 0
	Local oModelCNC	:= Nil
	Local aSaveLines:= {}
	Default oModel	:= FWModelActive()

	aSaveLines	:= FWSaveRows()
	oModelCNC 	:= oModel:GetModel("CNCDETAIL")

	For nCount := 1 To oModelCNC:Length()
		oModelCNC:GoLine(nCount)
		If (!oModelCNC:IsDeleted() .And. !Empty(oModelCNC:GetValue("CNC_CODIGO")))
			lResult := .T.
			Exit
		EndIf
	Next nCount

	If !lResult
		Help(" ",1,"CNTA300FOR")	//-- Inclua ao menos um fornecedor no contrato
	EndIf

	FWRestRows(aSaveLines)
	FwFreeArray(aSaveLines)
Return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300PlnGr
Rotina para tratamentos na gravacao das planilhas

@author Leandro.Moura
@since 23/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300PlnGr( oModel, lAprova as Logical )
Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows( oModel )
Local aNewIt		:= {}
Local lInclui		:= oModel:GetOperation() == MODEL_OPERATION_INSERT
Local lAltera		:= oModel:GetOperation() == MODEL_OPERATION_UPDATE
Local lFixo			:= .F.
Local lValor		:= .F.
Local lFilSC		:= CNB->(FieldPos("CNB_FILSC")) > 0 .And. FWModeAccess("SC1",1)+FWModeAccess("SC1",2)+FWModeAccess("SC1",3) != "CCC"
Local nForCab		:= 0
Local nForIts		:= 0
Local nVlrTot		:= 0
Local nTotCT		:= 0
Local nQtde			:= 0
Local oModelCN9		:= oModel:GetModel("CN9MASTER")
Local oModelCNA 	:= oModel:GetModel("CNADETAIL")
Local oModelCNB 	:= oModel:GetModel("CNBDETAIL")
Local oModelCPD 	:= oModel:GetModel("CPDDETAIL")
Local oModelCNZ		:= oModel:GetModel("CNZDETAIL")
Local cContrat		:= oModelCN9:GetValue("CN9_NUMERO")
Local cEspCnt		:= oModelCN9:GetValue("CN9_ESPCTR")
Local cRevAnt		:= CnRevAnt(.F., oModelCN9:GetValue("CN9_REVISA"))
Local cFilCTR		:= oModelCN9:GetValue("CN9_FILCTR")
Local cFilSC	    := ""
Local cFilScCTR		:= xFilial("SC1", cFilCTR)
Local cItsDel		:= ""
Local cNumSC		:= ""
Local cItSC			:= ""
Local cPlanil		:= ""
Local cItPlan		:= ""
Local cProdIt		:= ""
Local cChavCot		:= ""
Local cBaseIns		:= ""
Local dDtProxRj		:= CtoD("")
Local nMotPlan		:= TamSx3("CNA_VLTOT")[2]
Local nMotSld		:= TamSx3("CNA_SALDO")[2]
Local nDecPlan  	:= TamSx3("CNB_VLTOT")[2]
Local nVlrItem      := 0
Local cNumEdital 	:= oModelCN9:GetValue("CN9_CODED")
Local cProEdital 	:= oModelCN9:GetValue("CN9_NUMPR")
Local lFlagGctEd    := .F.
Local c1DUP         := GetMV("MV_1DUP")
Local cCNTPP 		:= SuperGetMV( "MV_CNTPPP", .F., "0" )
Local aCampos		:= {}
Local aCNBWhen		:= {}
Local cCNBRateio	:= ""
Local lSemiFixo		:= .F.
Local nTotSFixo		:= 0
Local cCpoEmpty		:= ""
Default lAprova		:= FWIsInCallStack('A097ProcLib') .Or. FWIsInCallStack('A097ProcSup') .Or. FWIsInCallStack('Cn300Aprov')

//-- Libera o modelo para alteracoes nas planilhas
CNTA300BlMd(oModelCNA,.F.)
CNTA300BlMd(oModelCNB,.F.)
CNTA300BlMd(oModelCNZ,.F.)
aCNBWhen := GCTGetWhen(oModelCNB)
oModelCNB:GetStruct():SetProperty( '*', MODEL_FIELD_WHEN , {||.T.} )

If !Empty(cTipRevisa) //Esse trecho ficava na funcao <A300CalSum>
	aAdd(aCampos,{'CNZDETAIL',{'CNZ_VALOR1','CNZ_VALOR2','CNZ_VALOR3','CNZ_VALOR4','CNZ_VALOR5'}})
	MtBCMod(oModel,aCampos,{||.T.},'2')
EndIf

cCpoEmpty := IIF((cEspCnt == "1"), "CNA_FORNEC", "CNA_CLIENT")

For nForCab := 1 To oModelCNA:Length()
	oModelCNA:GoLine( nForCab )
	cPlanil   := oModelCNA:GetValue("CNA_NUMERO")
	dDtProxRj := oModelCNA:GetValue("CNA_PROXRJ")
	
	If (lInclui .Or. lAltera) .And. CN300RetSt("RECORRENTE")
		If Empty( cTipRevisa )
			oModelCNA:SetValue( "CNA_PROPAR", c1DUP )
		ElseIf AllTrim( cCNTPP ) $ "0|2"
			oModelCNA:SetValue( "CNA_PROPAR", c1DUP )
		EndIf
	EndIf

	If !oModelCNA:IsDeleted() .And. !Empty(oModelCNA:GetValue(cCpoEmpty))
		If !lSemiFixo
			lSemiFixo := Cn300RetSt("SEMIFIXO")
		EndIf
		
		For nForIts := 1 to oModelCNB:Length()//-- Tratamento em todos os itens de cada planilha
			oModelCNB:GoLine(nForIts)

			cItPlan	:= oModelCNB:GetValue("CNB_ITEM")
			nQtde 	:= oModelCNB:GetValue("CNB_QUANT")
			cNumSC 	:= oModelCNB:GetValue("CNB_NUMSC")
			cItSC	:= oModelCNB:GetValue("CNB_ITEMSC")
			cProdIt	:= oModelCNB:GetValue("CNB_PRODUT")
			cBaseIns:= oModelCNB:GetValue("CNB_BASINS")

			If lFilSC .And. !Empty(oModelCNB:GetValue("CNB_FILSC")) .And. !Empty(oModelCNB:GetValue("CNB_NUMSC")) //-- Filial de busca da SC
				cFilSC := oModelCNB:GetValue("CNB_FILSC") //-- Filial de Origem da SC
			Else
				cFilSC := cFilScCTR //Filial da SC baseada na Filial do Contrato
			EndIf

			If !oModelCNB:IsDeleted() .And. !Empty(oModelCNB:GetValue("CNB_PRODUT"))				

				If lInclui .Or. lAltera
					nVlrItem := Round((nQtde * oModelCNB:GetValue("CNB_VLUNIT")),nDecPlan) - oModelCNB:GetValue("CNB_VLDESC")
					nVlrTot += nVlrItem
                    cCNBRateio := IIF(CN300RatCC(oModel,oModelCNA), "1", "2")//-- Tratamento para rateio por Centro de Custo

                    If (oModelCNB:GetValue("CNB_RATEIO") <> cCNBRateio)
                        oModelCNB:SetValue( "CNB_RATEIO" , cCNBRateio)
                    EndIf						
				EndIf
			
				If oModelCNB:IsInserted()
					oModelCNB:LoadValue("CNB_FILORI", cFilCTR) //-- Inclui Filial de Origem do Contrato
					
					If Empty(oModelCNB:GetValue("CNB_PRCORI"))//- Inclui Preço original na inclusão do contrato.
						oModelCNB:LoadValue("CNB_PRCORI",oModelCNB:GetValue("CNB_VLUNIT"))						
					EndIf
					If Empty(oModelCNB:GetValue("CNB_QTDORI"))//- Inclui quantidade original na inclusão do contrato.										
						oModelCNB:LoadValue("CNB_QTDORI",oModelCNB:GetValue("CNB_QUANT"))
					EndIf

					If cEspCnt == "1"
						oModelCNB:LoadValue("CNB_FLGCMS","2" )
					EndIf

					//-- Adiciona no array de itens inseridos
					If lAltera
						Aadd(aNewIt,cItPlan)
					EndIf

					oModelCNB:LoadValue("CNB_DTCAD",dDataBase)
					oModelCNB:SetValue("CNB_SLDMED",nQtde)
					oModelCNB:SetValue("CNB_SLDREC",nQtde)
					oModelCNB:LoadValue("CNB_PROXRJ",dDtProxRj)

					//-- Atualiza flag do contrato nas solicitacoes de compra
					If !Empty(oModelCN9:GetValue("CN9_NUMCOT")) .And. Empty(oModelCN9:GetValue("CN9_REVISA"))//-- Contrato gerado por cotacao
						cChavCot := cFilSC+oModelCN9:GetValue("CN9_NUMCOT")+oModelCNB:GetValue("CNB_PRODUT")+oModelCNB:GetValue("CNB_IDENT")
						SC1->(dbSetOrder(5))
						SC1->(dbSeek(cChavCot))
						While !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_COTACAO+C1_PRODUTO+C1_IDENT) == cChavCot
							RecLock("SC1",.F.)
							SC1->C1_FLAGGCT := "1"
							SC1->(MsUnlock())
							SC1->(DbSkip())
						EndDo
						
					ElseIf !Empty(cNumSC) //-- Contrato manual
						SC1->(dbSetOrder(1))
						If SC1->(dbSeek(cFilSC+cNumSC+cItSC))
							RecLock("SC1",.F.)
							SC1->C1_FLAGGCT := "1"
							SC1->(MsUnlock())
						EndIf
					
					ElseIf !Empty( cNumEdital )  //Se não foi gerado por cotação e se não tem o número da SC (item aglutinado), então atualiza a flag de acordo com o número do edital
						lFlagGctEd := .T.
					EndIf					
				EndIf

				If !Empty(cTipRevisa)  .Or. lAprova//Revisao
					if !Empty(cTipRevisa)
						A300CalSum(oModel, cRevAnt)//Ficava em <CN300Grv>						
					endif
					cn300AprPl(cContrat, oModelCN9:GetValue("CN9_REVISA")) //Rotina para tratamentos na gravacao das planilhas na aprovacao. Ficava em <A300Aprov>
					a300dtAniv(oModelCNB) //Atualiza a data de aniversário dos itens da planilha Incluidos durante a revisao
				EndIf
			ElseIf oModelCNB:IsDeleted()
				//-- Retira quantidade atendida da solicitacao de compra
				If !Empty(cNumSC)
					SC1->(dbSetOrder(1))
					If SC1->(dbSeek(cFilSC+cNumSC+cItSC))
						RecLock("SC1")
						SC1->C1_FLAGGCT := ""
				  		SC1->(MsUnlock())
					EndIf
				EndIf

				//-- Deleta localizacao fisica
				CN300DelAGW(cContrat,cPlanil,cItPlan)
				//-- Adiciona no array de itens inseridos
				If lAltera
					If Empty(cItsDel)
						cItsDel += "'" + cItPlan + "'"
					Else
						cItsDel += ",'" + cItPlan + "' "
					EndIf
				EndIf
			EndIf
		Next nForIts

		If (lInclui .Or. lAltera) .And. Empty(cTipRevisa)
			CN300GrvCrg(oModel)//-- Tratamento no Cronograma (apenas 1x por planilha)
		EndIf

		/*Inicio gravação das filiais autorizadas. Trecho ficava na função <CN300FilAut>*/
		If (oModelCNA:IsInserted() .And. (lInclui .Or. lAltera)) .Or.;//Planilha inserida durante a inclusão/alteração de um contrato
		   (lAprova .Or. !Empty(cAprTipRev))//Planilhas que foram inseridas durante a inclusão da revisão.
			If !MtFindMVC(oModelCPD,{{"CPD_FILAUT", cFilCTR}})//Verifica se a filial existe no modelo
				If !Empty(oModelCPD:GetValue("CPD_FILAUT"))//Caso a linha nao esteja em branco, adiciona uma linha
					oModelCPD:AddLine()
				EndIf
				oModelCPD:LoadValue("CPD_FILAUT", cFilCTR)					
			EndIf							
		EndIf
		/*Fim gravação das filiais autorizadas*/

		If nVlrTot = 0
			lFixo	:= Cn300RetSt("FIXO")
			lValor	:= Cn300RetSt("PREVFINANC")

			If !lFixo .And. lValor
				nVlrTot := oModelCNA:GetValue("CNA_VLTOT")
			Endif
		ElseIf Empty(oModelCN9:GetValue('CN9_TIPREV'))//-- Atualiza valor total do cabecalho
			oModel:GetModel("CNADETAIL"):GetStruct():SetProperty('CNA_VLTOT',MODEL_FIELD_WHEN,{||.T.})

				oModelCNA:LoadValue("CNA_VLTOT",Round(nVlrTot,nMotPlan))
				oModelCNA:SetValue("CNA_SALDO",Round(nVlrTot,nMotSld))

			CN300BlVlr(oModel,nForCab)
		EndIf
		
		nTotSFixo += oModelCNA:GetValue('CNA_VLTOT')
	ElseIf oModelCNA:IsDeleted()
		//-- Tratamento para os itens da planilha
		For nForIts := 1 to oModelCNB:Length()
			oModelCNB:GoLine(nForIts)

			If lFilSC .And. !Empty(oModelCNB:GetValue("CNB_FILSC")) .And. !Empty(oModelCNB:GetValue("CNB_NUMSC")) //-- Filial de busca da SC
				cFilSC := oModelCNB:GetValue("CNB_FILSC") //-- Filial de Origem da SC
			Else
				cFilSC := cFilScCTR //Filial da SC baseada na Filial do Contrato
			EndIf

			//-- Desbloqueia Solicitacao de Compras
			SC1->(dbSetOrder(1))
			If !Empty(oModelCNB:GetValue("CNB_ITEMSC")) .And. SC1->(dbSeek(cFilSC+oModelCNB:GetValue("CNB_NUMSC")+oModelCNB:GetValue("CNB_ITEMSC")))
				RecLock("SC1")
				SC1->C1_FLAGGCT := ""
				SC1->(MsUnlock())
			EndIf
		Next nForIts

		//-- Deleta localizacao fisica
		CN300DelAGW(cContrat,cPlanil)

		//-- Exclui a amarracao com o banco de conhecimentos
		MsDocument( "CNA", CNA->( RecNo() ), 2, , 3 )

		//-- Atualiza o valor total do contrato
		nVlrTot := -(oModelCNA:GetValue("CNA_VLTOT"))
	EndIf

	nTotCT += nVlrTot
	nVlrTot := 0
Next nForCab

If lFlagGctEd					
	//Atualiza flag de controle do GCT na SC1
	AtuFlagGCT( cNumEdital, cProEdital )
EndIf

If nTotCT < 0
	nTotCT := 0
EndIf

If lSemiFixo //Se tiver ao menos uma planilha SemiFixa
	nTotCt := nTotSFixo
EndIf

If (Len(aCNBWhen) > 0)
	GCTRstWhen(oModelCNB, aCNBWhen )
	FwFreeArray(aCNBWhen)
EndIf

CN300TpPla( .F., oModel )
FWRestRows(aSaveLines)
RestArea(aArea)
Return nTotCT

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300GrvAGW
Rotina para gravacao dos locais fisicos
Funcao utilizada na integracao com Gestao de Servicos

@param cContrat Numero do contrato
@param cPlanil 	Numero da planilha
@param lInclui 	Informa se eh operacao de inclusao
@param nOper Numero da operacao (3-Inclusao,4-Alteracao,5-Exclusao)

@author Leandro.Moura
@since 23/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300DelAGW(cContrat,cPlanil,cItem)
Local cKeySeek	:= xFilial("AGW")+cContrat+cPlanil+If(!Empty(cItem),cItem,"")

AGW->(dbSetOrder(2))
AGW->(dbSeek(cKeySeek))
While AGW->(!EOF()) .And. AGW->(AGW_FILIAL+AGW_CONTRA+If(!Empty(cItem),AGW_PLANIL,"")) == cKeySeek
	RecLock("AGW")
	AGW->(dbDelete())
	AGW->(MsUnLock())

	AGW->(dbSkip())
End

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300SOLIC
Rotina para importacao de solicitacao de compras

@param lItens	Informa se eh importacao por itens

@author Leandro.Moura
@since 01/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300Solic(lItens,lAuto,aAutSel)
	Local aArea		:= GetArea()
	Local aSaveLines:= FWSaveRows()
	Local aImpSC	:= {}	
	Local oModel	:= FWModelActive()
	Local oModelCN9	:= oModel:GetModel("CN9MASTER")
	Local oModelCNA := oModel:GetModel("CNADETAIL")
	Local oModelCNB := oModel:GetModel("CNBDETAIL")	
	Local cEspCnt	:= oModelCN9:GetValue("CN9_ESPCTR")		
	Local bImpSC	:= {|| ImportaSC(oModel, aImpSC) }

	Default lItens	:= .F.
	Default lAuto	:= oModelCN9:GetValue("CN9_AUTO") == '1'
	Default aAutSel := {}

	If !Empty(oModelCN9:GetValue("CN9_CODED"))
		Help(" ",1,"CNT300PLEDT")  //-- O contrato foi gerado por um edital e por isso não se pode excluir planilhas
		Return

	ElseIf !(cEspCnt == "1")
		Aviso(STR0090,STR0047,{STR0222})	//-- Apenas contratos de compra podem importar solicitações.
		Return

	ElseIf oModelCNA:IsDeleted()
		Aviso(STR0090,STR0051,{STR0222}) //-- A solicitação não pode ser importada pois a planilha está deletada.
		Return

	ElseIf !Empty(cTipRevisa) .AND. !(Cn300RetSt("MODALIDADE") $ "1|3" .AND. Cn300RetSt("ESPECIE") $ "1|4")
		Aviso(STR0090,STR0219,{STR0222}) //- "Opção indisponível para o tipo de revisão selecionado."
		Return

	ElseIf Empty(oModelCNA:GetValue("CNA_FORNEC")) .Or. Empty(oModelCNA:GetValue("CNA_LJFORN")) .Or. Empty(oModelCNA:GetValue("CNA_TIPPLA"))
		Aviso(STR0090,STR0050,{STR0222})	//-- Preencha os campos do cabeçalho da planilha.
		Return

	ElseIf Cn300RetSt("SERVIÇO")
		Aviso(STR0090,STR0214,{STR0222})	//--Opção indisponível para planilha de serviço
		Return

	ElseIf Cn300RetSt("SEMIAGRUP")
		Aviso(STR0090,STR0215,{STR0222})	//-- Não Permitido importar solicitacoes para contratos SemiFixos por Agrupador.
		Return

	ElseIf (!Cn300RetSt("FIXO") .And. !Cn300RetSt("SEMIPROD"))
		Aviso(STR0090, STR0205, {STR0222})
		Return

	ElseIf lItens .And. Empty(oModelCNB:GetValue("CNB_PRODUT"))
		Aviso(STR0090,STR0052,{STR0222}) //-- Informe o produto para importar a Solicitação de Compra por item.
		Return
	EndIf

	//-- Chama rotina para selecionar as SC
	If !lItens
		aImpSC := CN300ImpSC(lAuto,aAutSel)
	Else
		aImpSC := CN300ImpIt(oModelCNB:GetValue("CNB_PRODUT"),lAuto,aAutSel)
	EndIf

	If Len(aImpSC) > 0
		If IsBlind()
			Eval(bImpSC)
		Else
			FWMsgRun(, bImpSC, STR0084, STR0323)//Importando produtos da solicitação de compras
		EndIf		
		FwFreeArray(aImpSC)		
	EndIf	

	FWRestRows(aSaveLines)
	FwFreeArray(aSaveLines)
		
	RestArea(aArea)
	FwFreeArray(aArea)
Return

/*/{Protheus.doc} ImportaSC
	Processa a importação dos itens da solicitação de compras
@author philipe.pompeu
@since 09/06/2022
@param oModel, objeto, instância de MPFormModel
@param aImpSC, vetor, lista de itens a serem importadas
/*/
Static Function ImportaSC(oModel, aImpSC)
	Local aAreas	:= {SC1->(GetArea()), SB1->(GetArea()), GetArea()}
	Local nRecnoSC1	:= 0
	Local nCount	:= 0
	Local lOk		:= .T.
	Local lTemProdBlq	:= .F.
	Local aCNBCfg		:= {}
	Local aCNZCfg		:= {}
	Local aCTBEnt 		:= CTBEntArr()
	Local aGrupoUsr   	:= UsrGrComp(RetCodUsr())
	Local oModelCNZ 	:= oModel:GetModel("CNZDETAIL")
	Local oModelCNB 	:= oModel:GetModel("CNBDETAIL")

	aCNBCfg := {GCTGetWhen(oModelCNB), GCTGetObrg(oModelCNB)}
	oModelCNB:GetStruct():SetProperty( '*', MODEL_FIELD_WHEN 	, {||.T.} )
	oModelCNB:GetStruct():SetProperty( '*', MODEL_FIELD_OBRIGAT , .F. )

	aCNZCfg := {GCTGetWhen(oModelCNZ), GCTGetObrg(oModelCNZ)}
	oModelCNZ:GetStruct():SetProperty( '*', MODEL_FIELD_WHEN 	, {||.T.} )
	oModelCNZ:GetStruct():SetProperty( '*', MODEL_FIELD_OBRIGAT , .F. )	

	SB1->(dbSetOrder(1))
	For nCount := 1 to Len(aImpSC)
		//-- Posiciona na SC1
		nRecnoSC1 := aImpSC[nCount]

		SC1->(dbGoto(nRecnoSC1))
		
		SB1->(MsSeek(xFilial("SB1")+SC1->C1_PRODUTO)) // //Posicionar na SB1 relacionada a SC1 para validar o produto
		
		If RegistroOK('SB1',.F.)
			lOk := Empty(SC1->C1_FLAGGCT) .And. CN300AddPrd(oModel, aCTBEnt, aGrupoUsr) //-- Chama rotina para adicionar o item na planilha
		ElseIf !lTemProdBlq
			lTemProdBlq := .T.
		EndIf
	Next nCount

	If lTemProdBlq
		Help(" ",1,"CNTA300SCP",,STR0180,1,1) //-- "Existem itens da solicitação bloqueados ou já utilizados pelo SIGAGCT. Estes itens não serão incluidos."
	EndIf

	GCTRstWhen(oModelCNB , aCNBCfg[1])
	GCTRstObrg(oModelCNB , aCNBCfg[2])
	FwFreeArray(aCNBCfg)
	
	GCTRstWhen(oModelCNZ , aCNZCfg[1])
	GCTRstObrg(oModelCNZ , aCNZCfg[2])
	FwFreeArray(aCNZCfg)

	FwFreeArray(aCTBEnt)
	FwFreeArray(aGrupoUsr)

	aEval(aAreas,{|x|RestArea(x)})
	FwFreeArray(aAreas)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300GetPIt
Rotina para retornar os itens da planilha

@author Leandro.Moura
@since 01/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300GetPIt()
Local aArea		:= GetArea()
Local aItens		:= {}
Local nFor			:= 0
Local oModel		:= FWModelActive()
Local oModelCNB 	:= oModel:GetModel("CNBDETAIL")
Local oModelCXM 	:= oModel:GetModel("CXMDETAIL")
Local lAgrupador  := Cn300RetSt("SEMIAGRUP")
Local aSaveLines	:= FWSaveRows()

//-- Verifica se a planilha contem itens
If lAgrupador
	For nFor := 1 To oModelCXM:Length()
		oModelCXM:GoLine(nFor)
		If !Empty(oModelCXM:GetValue("CXM_ITEMID")) .And. !(oModelCXM:IsDeleted())
			//-- Adiciona itens no array de retorno.
			aAdd(aItens,{ oModelCXM:GetValue("CXM_ITEMID"),;				// 1. Item do Agrupador
						  Iif(!Empty(oModelCXM:GetValue("CXM_AGRTIP")),;	// 2. código do agrupador (verificar qual dos campos está preenchido:
								oModelCXM:GetValue("CXM_AGRTIP"),;      	// Tipo,Grupo ou Categoria de Produto)
						  Iif(!Empty(oModelCXM:GetValue("CXM_AGRGRP")),;
							oModelCXM:GetValue("CXM_AGRGRP"),;
							oModelCXM:GetValue("CXM_AGRCAT"))),;
							0	,;											// 3. Manter zero, pois, não existirá Cronog. Físico, logo não tem qtde
							''	,;											// 4. Manter vazio, não exisitirá SC
							''	,;											// 5. Manter vazio, não exisitirá SC
							oModelCXM:nLine						,;			// 6. Num. da linha do item
							oModelCXM:GetValue("CXM_VLMAX")	,;				// 7. Valor Máximo
							0	} )											// 8. Manter zero, não haverá campo desconto na Entidade
		EndIf
	Next nFor
Else
	For nFor := 1 To oModelCNB:Length()
		oModelCNB:GoLine(nFor)
		If !Empty(oModelCNB:GetValue("CNB_PRODUT")) .And. !(oModelCNB:IsDeleted())
			//-- Adiciona itens no array de retorno.
			aAdd(aItens,{ oModelCNB:GetValue("CNB_ITEM")		,;		// 1. Item da planilha
							oModelCNB:GetValue("CNB_PRODUT")	,;		// 2. Cod. Produto
							oModelCNB:GetValue("CNB_QUANT")		,;		// 3. Quantidade
							oModelCNB:GetValue("CNB_NUMSC")		,;		// 4. Num. Solic. Compra
							oModelCNB:GetValue("CNB_ITEMSC")	,;		// 5. Item Solic. Compra
							oModelCNB:nLine						,;		// 6. Num. da linha do item
							oModelCNB:GetValue("CNB_VLUNIT")	,;		// 7. Valor unitario
							oModelCNB:GetValue("CNB_VLDESC")	,;		// 8. Valor do desconto
							oModelCNB:GetValue("CNB_ATIVO")	} )			// 9. Item de contrato recorrente ativo/inativo
		EndIf
	Next nFor
EndIf

FWRestRows(aSaveLines)
RestArea(aArea)
Return aItens

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300ImpSC
Rotina para selecionar as SC para importacao

@author Leandro.Moura
@since 01/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300ImpSC(lAuto,aAutSel)
	Local aArea		:= GetArea()
	Local aAreaSC1	:= SC1->(GetArea())
	Local aSaveLines:= FWSaveRows()
	Local aCampos	:= {"C1_OK","C1_NUM","C1_ITEM","C1_PRODUTO","C1_QUANT","C1_QUJE","C1_DESCRI","C1_GRUPCOM"}
	Local aButEnc	:= {}
	Local aMarca	:= {}
	Local aCpos		:= {}	
	Local oDlg		:= Nil
	Local oMark		:= Nil
	Local oMainWnd	:= Nil
	Local oSizeMrk	:= Nil	
	Local lInverte	:= .F.	
	Local cCadastro	:= STR0053	//-- Importar Solicitações de Compras
	Local cMarca	:= GetMark()
	Local cCampoOk	:= "C1_OK"
	Local nOpcA		:= 0
	Local nX		:= 0
	Local nPos 		:= 0	
	Local cFilSC1   := ""
	Local cTitulo	:= ""
	Local aSC1Cpos	:= ""
	Local cCampo	:= ""
	Default lAuto	:= .F.
	Default aAutSel := {}	
	
	cFilSC1 := 'C1_FILIAL == "'+xFilial('SC1')+'".And. C1_QUJE < C1_QUANT .And. C1_TPOP<>"P" .And. C1_TPSC<>"2" .And. C1_APROV$" ,L"'
	cFilSC1 += ' .And.( C1_COTACAO == "'+Space(Len(SC1->C1_COTACAO))+'" .Or. C1_COTACAO == "'+Replicate("X",Len(SC1->C1_COTACAO))+'")'
	cFilSC1 += ' .And. SC1->C1_FLAGGCT <> "1" .And. CN300FltSC() .And. C1_RESIDUO <> "S" ''
	
	dbSelectArea("SC1")
	dbSetOrder(1)
	Set Filter To &(cFilSC1)
	cFilter := cFilSC1
	
	If !lAuto
		//-- Monta os botoes da enchoice passando o filtro para ser restaurado na saida da visualizacao
		aButEnc	:=  {	{STR0251,{|| axPesqui()},STR0056 } ,;   					//-- Pesquisar
						{STR0252 ,{|| A110Visual("SC1",RecNo(),2)},STR0057} }   	//-- Visualizar
						
		aSize(aCpos, Len(aCampos))

		aSC1Cpos := FWSX3Util():GetAllFields("SC1")
		for nX := 1 to Len(aSC1Cpos)
			cCampo := AllTrim(aSC1Cpos[nX])

			If ((nPos := aScan(aCampos, cCampo)) <= 0) 	.And.;
				GetSx3Cache(cCampo,"X3_CONTEXT") <> "V" .And.;
				GetSx3Cache(cCampo,"X3_BROWSE") == "S" 	.And.;
				X3USO(GetSx3Cache(cCampo,"X3_USADO"))

				aAdd(aCpos,{})
				nPos := Len(aCpos)
			EndIf
			
			If(nPos > 0)
				cTitulo := IIF(cCampo == "C1_OK", "", GetSx3Cache(cCampo,"X3_TITULO") )				
				aCpos[nPos] := {cCampo, "", cTitulo, GetSx3Cache(cCampo,"X3_PICTURE")}
			EndIf
		next nX
		FwFreeArray(aSC1Cpos)
				
		oSizeMrk := FwDefSize():New()
		oSizeMrk:AddObject( "GRID" ,100,100, .T., .T.,.F.) // Totalmente dimensionavel
		oSizeMrk:lProp := .T.
		oSizeMrk:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3
		oSizeMrk:Process()
	
		DEFINE MSDIALOG oDlg TITLE cCadastro ;
								FROM oSizeMrk:aWindSize[1],oSizeMrk:aWindSize[2] TO oSizeMrk:aWindSize[3],oSizeMrk:aWindSize[4] OF oMainWnd PIXEL
	
		oMark := MsSelect():New("SC1",cCampoOk,"CN200FLAG()",aCpos,@lInverte,@cMarca,;
							{oSizeMrk:GetDimension('GRID','LININI'),oSizeMrk:GetDimension('GRID','COLINI'),;
							 oSizeMrk:GetDimension('GRID','LINEND'),oSizeMrk:GetDimension('GRID','COLEND')})
		oMark:bMark := {|| CN200AddMark(cMarca,@aMarca,cCampoOk,"SC1"),oMark:OBROWSE:Refresh()}
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||(nOpcA:=1),(oDlg:End())},{||oDlg:End()},,aButEnc)
	Else
		dbSelectArea("SC1")
		SC1->(dbSetOrder(1))
		For nX := 1 To Len(aAutSel)
			If SC1->(MsSeeK(xFilial('SC1')+aAutSel[nX,1])) //- C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD
				CN200AddMark(cMarca,@aMarca,cCampoOk,"SC1")
			EndIf
		Next
		nOpcA := 1
	EndIf
	
	If nOpcA == 0
		aMarca := {}
	EndIf
	
	SC1->(DBClearFilter())
	RestArea(aArea)
	RestArea(aAreaSC1)
	FWRestRows(aSaveLines)
	FWFreeArray(aSaveLines)
Return aMarca

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300ImpIt
Rotina para selecionar as SC para importacao por item

@param cProdut Informa o produto para filtro

@author Leandro.Moura
@since 01/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300ImpIt(cProdut,lAuto,aAutSel)
	Local aArea		:= GetArea()
	Local aCampos	:= {"C1_NUM","C1_ITEM","C1_PRODUTO","C1_QUANT","C1_DESCRI"}
	Local aSaveLines:= FWSaveRows()
	Local aGrupo    := UsrGrComp(RetCodUsr())
	Local aSolic	:= {}
	Local aHeadCpos	:= {}
	Local aSolics	:= {}
	Local aSavRec	:= {}
	Local aRecMark	:= {}
	Local aAreaSC1  := {}
	Local oOk	    := Nil
	Local oNo		:= Nil
	Local oDlg		:= Nil
	Local oQual		:= Nil
	Local oMainWnd	:= Nil
	Local oSizeMrk	:= Nil
	Local oModel	:= FWModelActive()
	Local oModelCNA := oModel:GetModel("CNADETAIL")
	Local oModelCNB := oModel:GetModel("CNBDETAIL")
	Local lSolic	:= If(SuperGetMv("MV_RESTCOM")=="S",.T.,.F.)
	Local lCN300FSC	:= ExistBlock("CN300FSC")
	Local lOk		:= .T.
	Local bLine     := ""
	Local cCadastro := STR0053	//-- Importar Solicitações de Compras
	Local cDescr    := ""
	Local cLine     := ""
	Local cKeySC1	:= ""
	Local cMyAlias:= GetNextAlias()
	Local nTamCot 	:= TamSX3("C1_COTACAO")[1]
	Local nCount	:= 0
	Local nSaldo	:= 0
	Local nOpcA     := 0
	Local nItm		:= 0
	Local nX		:= 0
	Local nK		:= 0
	Local nY		:= 0
	Local nLineCNA  := oModelCNA:GetLine()
	Local nLineCNB  := oModelCNB:GetLine()
	
	Default lAuto	:= .F.
	Default aAutSel := {}
	
	//-- Monta o Header com os titulos do MsSelect
	aAdd(aHeadCpos,"")
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	For nCount	:= 1 to Len(aCampos)
		If MsSeek(aCampos[nCount])
			aAdd(aHeadCpos,AllTrim(X3Titulo()))
		EndIf
	Next nCount
	If !lAuto
		DbSelectArea("SC1")
		aAreaSC1 := SC1->(GetArea())
		SC1->(DbSetOrder(1))
		For nK := 1 To oModelCNA:Length()
			oModelCNA:GoLine(nK)
			For nY := 1 To oModelCNB:Length()
				oModelCNB:GoLine(nY)
				If !(oModelCNB:IsDeleted()) .And. !Empty(oModelCNB:GetValue("CNB_NUMSC")) .And. !Empty(oModelCNB:GetValue("CNB_ITEMSC"))
					cKeySC1 := xFilial("SC1") + oModelCNB:GetValue("CNB_NUMSC") + oModelCNB:GetValue("CNB_ITEMSC")
					If SC1->(DbSeek(cKeySC1))
						aAdd(aRecMark, SC1->(Recno()))
					EndIf
				EndIf
			Next nY
		Next nK
		oModelCNA:GoLine(nLineCNA)
		oModelCNB:GoLine(nLineCNB)
		SC1->(RestArea(aAreaSC1))
	EndIf
	
	//-- Filtra solicitacoes de compra conforme produto
	BeginSQL Alias cMyAlias
		SELECT R_E_C_N_O_ SC1RECNO
		FROM %Table:SC1%
		WHERE %NotDel% AND
			C1_FILIAL = %xFilial:SC1% AND
			C1_PRODUTO = %Exp:cProdut% AND
			C1_QUJE < C1_QUANT AND
			C1_TPOP <> 'P' AND
			C1_TPSC <> '2' AND
			(C1_APROV = ' ' OR C1_APROV = 'L') AND
			(C1_COTACAO = %Exp:Space(nTamCot)% OR C1_COTACAO = %Exp:Replicate("X",nTamCot)%) AND
			C1_FLAGGCT <> '1' AND
			C1_RESIDUO <> 'S'
	EndSQL
	
	While (cMyAlias)->(!EOF())	
		If aScan(aRecMark, (cMyAlias)->SC1RECNO) == 0
			//-- Posiciona na SC1
			SC1->(dbGoTo((cMyAlias)->SC1RECNO))
			If !(lSolic .And. aScan(aGrupo,SC1->C1_GRUPCOM) <= 0) .Or. Empty(SC1->C1_GRUPCOM)
				//-- Calcula saldo do item
				nSaldo	:= SC1->(C1_QUANT - C1_QUJE)
		
				//Ponto de entrada para decidir se solicitação pode ser importada.
				If lCN300FSC
					lOk := ExecBlock("CN300FSC", .F., .F.)
				EndIf
		
				If nSaldo > 0 .And. lOk
					aAdd(aSolics,{.F.,SC1->C1_NUM,SC1->C1_ITEM,SC1->C1_PRODUTO,TransForm(nSaldo,PesqPictQt("C1_QUANT")),SC1->C1_DESCRI})
					aAdd(aSavRec,(cMyAlias)->SC1RECNO)
				EndIf
			EndIf		
		EndIf
		(cMyAlias)->(dbSkip())
	EndDo
	
	(cMyAlias)->(dbCloseArea())
	
	//-- Seleciona descricao do produto
	cDescr := Substr( Posicione("SB1",1,xFilial("SB1")+cProdut,"SB1->B1_DESC" ) ,1,15 )
	
	If Len(aSolics) > 0
		If !lAuto
			oOk	:= LoadBitMap(GetResources(), "LBOK")
			oNo	:= LoadBitMap(GetResources(), "LBNO")

			//-- Monta dinamicamente o bline do CodeBlock
			cLine := "{Iif(aSolics[oQual:nAt,1],oOk,oNo)"
			For nCount := 2 To Len( aHeadCpos )
				cLine += ",aSolics[oQual:nAT," + AllTrim(Str(nCount)) + "]"
			Next nCount
			cLine += " } "
	
			bLine := &( "{ || " + cLine + " }" )
	
			oSizeMrk := FwDefSize():New()
			oSizeMrk:AddObject( "ENCHOICE"		,  100, 10, .T., .T.,.F.)
			oSizeMrk:AddObject( "GRID"   	  	,  100, 90, .T., .T.,.F.)
	
			oSizeMrk:lProp := .T.
			oSizeMrk:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3
			oSizeMrk:Process()
	
			//-- Monta interface para selecionar a solicitacao de compra
			DEFINE MSDIALOG oDlg TITLE cCadastro ;
								FROM oSizeMrk:aWindSize[1],oSizeMrk:aWindSize[2] TO oSizeMrk:aWindSize[3],oSizeMrk:aWindSize[4] OF oMainWnd PIXEL
	
			@ oSizeMrk:GetDimension('ENCHOICE','LININI'),oSizeMrk:GetDimension('ENCHOICE','COLINI') 	Say STR0058 PIXEL //-- Produto
			@ oSizeMrk:GetDimension('ENCHOICE','LININI'),oSizeMrk:GetDimension('ENCHOICE','COLINI')+30 MSGET cDescr WHEN .F. PIXEL
	
			oQual:= TWBrowse():New( oSizeMrk:GetDimension('GRID','LININI'),oSizeMrk:GetDimension('GRID','COLINI'),;
							 			oSizeMrk:GetDimension('GRID','XSIZE'),oSizeMrk:GetDimension('GRID','YSIZE'),;
							 			,aHeadCpos,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	
			oQual:SetArray(aSolics)
			oQual:bLDblClick := { || aSolics[oQual:nAt,1] := !aSolics[oQual:nAt,1] }
			oQual:bLine := bLine
	
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||(nOpcA := 1,oDlg:End() ) },{||(nOpcA := 0,oDlg:End())})
		Else
			nOpcA := 1
			For nX := 1 To Len(aAutSel)
				If (nItm := aScan(aSolics,{|x| 	x[aScan(aCampos,"C1_NUM") +1] 	 == aAutSel[nX,1] .And.;
												x[aScan(aCampos,"C1_ITEM")+1] 	 == aAutSel[nX,2] .And.;
												AllTrim(x[aScan(aCampos,"C1_PRODUTO")+1]) == AllTrim(aAutSel[nX,3]) }))
					aSolics[nItm,1] := .T.
				EndIf
			Next nX
		EndIf
	
		If nOpcA == 1
			//-- Verifica as solicitacoes selecionadas
			For nCount := 1 to Len(aSolics)
				If aSolics[nCount,1]
					//-- Adiciona recno da SC1 no array de retorno
					aAdd(aSolic,aSavRec[nCount])
				EndIf
			Next nCount
		EndIf
	Else
		Aviso(STR0090,STR0059,{STR0222})	//-- Nao ha itens em aberto para o produto selecionado.
	EndIf
	
	RestArea(aArea)
	FWRestRows(aSaveLines)
	FWFreeArray(aSaveLines)

Return aSolic

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300AddPrd
Rotina para adicionar o item da solicitacao de compras na planilha

@author Leandro.Moura
@since 01/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300AddPrd(oModel, aCTBEnt, aGrupo)
	Local aAreas		:= {CNB->(GetArea()), SCX->(GetArea()), GetArea()}	
	Local cItem			:= ""
	Local cFilCTR	    := ""
	Local cCpoPre    	:= If(SuperGetMV("MV_CNPRECO",.F.,.T.),"B1_UPRC","B1_CUSTD")
	Local lRet			:= .T.
	Local lSolic		:= If(SuperGetMV("MV_RESTCOM",.F.,"N") == "S",.T.,.F.)
	Local nPosSC		:= 0
	Local nCount		:= 0
	Local nNewLine		:= 0
	Local nVlrUnit		:= 0
	Local oModelCN9		:= Nil
	Local oModelCNB 	:= Nil
	Local oModelCNZ		:= Nil
	Default oModel		:= FWModelActive()
	Default aCTBEnt		:= CTBEntArr()
	Default aGrupo     	:= UsrGrComp(RetCodUsr())
	
	oModelCN9	:= oModel:GetModel("CN9MASTER")
	oModelCNB	:= oModel:GetModel("CNBDETAIL")
	oModelCNZ	:= oModel:GetModel("CNZDETAIL")	

	If !(lSolic .And. aScan(aGrupo,SC1->C1_GRUPCOM) <= 0) .Or. Empty(SC1->C1_GRUPCOM)
		//-- Verifica se o item ja foi adicionado a planilha
		nPosSC := MTFindMVC(oModelCNB,{{"CNB_NUMSC",SC1->C1_NUM},{"CNB_ITEMSC",SC1->C1_ITEM}})

		//-- Caso a linha nao esteja em branco, adiciona uma linha
		If nPosSC == 0 .And. !Empty(oModelCNB:GetValue("CNB_PRODUT")) .And. !Empty(oModelCNB:GetValue("CNB_QUANT"))
			cItem := Soma1(oModelCNB:GetValue("CNB_ITEM",oModelCNB:Length()))
			nNewLine := oModelCNB:AddLine()
			oModelCNB:GoLine(nNewLine)
			oModelCNB:SetValue("CNB_ITEM",cItem)
		ElseIf nPosSC > 0
			//-- Posiciona na linha do item na planilha
			oModelCNB:GoLine(nPosSC)
		EndIf

		If (cPaisLoc == "BRA" .And. !Empty(SC1->C1_VUNIT))//obtem o valor unitario
			nVlrUnit := SC1->C1_VUNIT
		ElseIf(!Empty(SC1->C1_PRECO))
			nVlrUnit := SC1->C1_PRECO
		Else
			nVlrUnit := SB1->(&(cCpoPre))
		EndIf		

		//-- Preenche os campos da grid
		oModelCNB:SetValue("CNB_QUANT"	,SC1->(C1_QUANT - C1_QUJE))
		oModelCNB:SetValue("CNB_UM",SC1->C1_UM)
		oModelCNB:SetValue("CNB_PRODUT"	,SC1->C1_PRODUTO)	

		If(cPaisLoc == "RUS" .And. nNewLine != 0)
			oModelCNB:GoLine(nNewLine) //One of the triggers of CNB_PRODUT runs validation of CNB_CONTA field. Inside of this validation there is a function, that reset position of line in the grid.
		EndIf
		
		If !Empty(oModelCN9:GetValue("CN9_FILCTR"))
			cFilCTR := oModelCN9:GetValue("CN9_FILCTR")
		Else
			cFilCTR := cFilAnt
		EndIf

		If CNB->(FieldPos("CNB_FILSC")) > 0
			oModelCNB:LoadValue("CNB_FILSC", SC1->C1_FILIAL)
		EndIf

		oModelCNB:LoadValue("CNB_FILORI", cFilCTR)
		oModelCNB:SetValue("CNB_NUMSC",SC1->C1_NUM)
		oModelCNB:SetValue("CNB_ITEMSC",SC1->C1_ITEM)
		oModelCNB:SetValue("CNB_QTDSOL",SC1->(C1_QUANT - C1_QUJE))
		oModelCNB:SetValue("CNB_DESCRI",SC1->C1_DESCRI)
		oModelCNB:SetValue("CNB_VLUNIT",nVlrUnit)
		oModelCNB:SetValue("CNB_CONTA",SC1->C1_CONTA)
		oModelCNB:SetValue("CNB_ITEMCT",SC1->C1_ITEMCTA)
		oModelCNB:SetValue("CNB_CC",SC1->C1_CC)
		oModelCNB:SetValue("CNB_CLVL",SC1->C1_CLVL)

		For nCount := 1 To Len(aCTBEnt)
			//-- Adiciona valor nas entidades contabeis
			If CNB->(FieldPos("CNB_EC"+aCTBEnt[nCount]+"CR")) > 0 .And. SC1->(FieldPos("C1_EC" +aCTBEnt[nCount] +"CR")) > 0
				oModelCNB:SetValue("CNB_EC"+aCTBEnt[nCount]+"CR",SC1->&("C1_EC" +aCTBEnt[nCount] +"CR"))
			EndIf
			If CNB->(FieldPos("CNB_EC" +aCTBEnt[nCount] +"DB")) > 0 .And. SC1->(FieldPos("C1_EC" +aCTBEnt[nCount] +"DB")) > 0
				oModelCNB:SetValue("CNB_EC" +aCTBEnt[nCount] +"DB",SC1->&("C1_EC" +aCTBEnt[nCount] +"DB"))
			EndIf
		Next nCount

		//Verifica se possui rateio, caso sim alimenta o model "CNZ".
		If SC1->C1_RATEIO == '1'
			dbSelectArea("SCX")
			SCX->(DbSetOrder(1))
			If SCX->(dbSeek(cSeekCNZ := xFilial("SCX")+SC1->C1_NUM+SC1->C1_ITEM))
				cItemRat := Replicate("0", (TamSx3('CNZ_ITEM')[1]))

				While SCX->(!Eof()) .And. SCX->(CX_FILIAL+CX_SOLICIT+CX_ITEMSOL) == cSeekCNZ
					If cItemRat <> Replicate("0", (TamSx3('CNZ_ITEM')[1]))
						oModelCNZ:AddLine()
					EndIf

					cItemRat := Soma1(cItemRat)
					oModelCNZ:SetValue('CNZ_ITEM',cItemRat)
					oModelCNZ:SetValue('CNZ_PERC',SCX->CX_PERC)
					oModelCNZ:SetValue('CNZ_CC',SCX->CX_CC)
					oModelCNZ:SetValue('CNZ_CONTA',SCX->CX_CONTA)
					oModelCNZ:SetValue('CNZ_ITEMCT',SCX->CX_ITEMCTA)
					oModelCNZ:SetValue('CNZ_CLVL',SCX->CX_CLVL)
										
					For nCount := 1 To Len(aCTBEnt)
						//-- Adiciona valor nas entidades contabeis
						If CNZ->(FieldPos("CNZ_EC" + aCTBEnt[nCount] + "CR")) > 0 .And. SCX->(FieldPos("CX_EC" + aCTBEnt[nCount] + "CR")) > 0
							oModelCNZ:SetValue("CNZ_EC" + aCTBEnt[nCount] + "CR", SCX->&("CX_EC" + aCTBEnt[nCount] + "CR"))
						EndIf
						If CNZ->(FieldPos("CNZ_EC" + aCTBEnt[nCount] + "DB")) > 0 .And. SCX->(FieldPos("CX_EC" + aCTBEnt[nCount] + "DB")) > 0
							oModelCNZ:SetValue("CNZ_EC" + aCTBEnt[nCount] + "DB", SCX->&("CX_EC" + aCTBEnt[nCount] + "DB"))
						EndIf
					Next nCount
					
					SCX->(dbSkip())
				EndDo
			EndIf
		EndIf

		If oModel:HasErrorMessage()
			Aviso(STR0090,AllTrim(SC1->C1_PRODUTO)+": "+oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE],{STR0222})
			oModelCNB:DeleteLine(.T.,.T.)
			oModel:SetErrorMessage("","","","",,"")
		Else
			lRet := oModelCNB:VldLineData()
		EndIf		
	EndIf
	
	aEval(aAreas,{|x|RestArea(x)})
	FwFreeArray(aAreas)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}CNTA300xEdt()
Rotina para geração do Contrato a partir do Edital.
Funcao utilizada na integracao com o modulo SIGAGCP.

@author Matheus Lando Raimundo
@since 30/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CNTA300xEdt(oModel200,oModel300,cCodFor,cLoja,lLote,cLote,aFilsEnv,lVenda,lAta,cFilOrig,cFilEnt)
Local aArea			:= GetArea()
Local oCN9Master	:= oModel300:GetModel('CN9MASTER')
Local cCodEdt		:= IIf(lAta,oModel200:GetModel("CPHMASTER"):GetValue("CPH_CODEDT"),oModel200:GetModel('CO1MASTER'):GetValue('CO1_CODEDT'))
Local cNumPro		:= IIf(lAta,oModel200:GetModel("CPHMASTER"):GetValue("CPH_NUMPRO"),oModel200:GetModel('CO1MASTER'):GetValue('CO1_NUMPRO'))
Local cNumAta		:= IIf(lAta,oModel200:GetModel("CPHMASTER"):GetValue("CPH_NUMATA"),"")
Local cItPla		:= Replicate("0", (TamSx3('CNA_NUMERO')[1]))
Local cItCNB		:= Replicate("0", (TamSx3('CNB_ITEM')[1]))
Local cAutom		:= IIF(lAta,oModel200:GetValue("CPHMASTER","CPH_AUTO"),oModel200:GetValue("CO1MASTER","CO1_AUTO"))
Local cCondPg		:= ""
Local cRevisa		:= ""
Local cFilEdt		:= ""
Local nLinhaPla		:= 0

Default cFilOrig	:= cFilAnt
Default cFilEnt 	:= cFilAnt
Default lVenda		:= CO1->CO1_GERDOC == '2'

If lAta
	If CO1->(DbSeek(xFilial("CO1",cFilOrig)+oModel200:GetModel("CPHMASTER"):GetValue("CPH_CODEDT")))
		cRevisa := CO1->CO1_REVISA
		cFilEdt := CO1->CO1_FILIAL
	EndIf
Else
	cRevisa := oModel200:GetModel('CO1MASTER'):GetValue('CO1_REVISA')
	cFilEdt := oModel200:GetModel('CO1MASTER'):GetValue('CO1_FILIAL')
	cCondPg := oModel200:GetModel('CO3DETAIL'):GetValue('CO3_CONDPG')
EndIf

oCN9Master:SetValue('CN9_ESPCTR',If(!lVenda,'1','2'))
oCN9Master:SetValue('CN9_DTINIC',dDataBase)
oCN9Master:SetValue('CN9_UNVIGE','4')
oCN9Master:SetValue('CN9_CODED',cCodEdt)
oCN9Master:SetValue('CN9_NUMPR',cNumPro)
oCN9Master:SetValue('CN9_NUMATA',cNumAta)
oCN9Master:SetValue('CN9_FILEDT',cFilEdt)
oCN9Master:SetValue('CN9_CONDPG',cCondPg)

If cAutom == '1'
	AtriTpcPg(oCN9Master,lVenda) //Funcao para alimentar atribuir conteudo no cond pagto e tipo de contrato quando executado por rotina automatica
EndIf

If SuperGetMV("MV_NOTAEMP",.F.,.F.)
	dbSelectArea("CX0")
	CX0->(DbSetOrder(2))
	If CX0->(DbSeek(xFilial("CX0")+cCodEdt+cNumPro+cNumAta))
		oCN9Master:LoadValue('CN9_CODNE',CX0->CX0_CODNE)
	EndIf
	RestArea(aArea)
EndIf

CNTA300BlMd(oModel300:GetModel('CNBDETAIL'),.F.)
CNTA300BlMd(oModel300:GetModel('CNZDETAIL'),.F.)
CNTA300BlMd(oModel300:GetModel('CNCDETAIL'),.F.)
oModel300:GetModel('CNADETAIL'):SetNoUpdateLine(.F.)


If FunName() <> 'GCPA300'
//Função que cria os itens das planilhas com os produtos das SC's.
	If CNTA300Itns(oModel300, cCodEdt, cNumPro, cRevisa, cCodFor, cLoja ,@cItPla, lLote, cLote)
	//Função que cria os itens das planilhas com as sobras das quantidades.
		nLinhaPla := CNTA300Rst(oModel300,cCodEdt,cNumPro,cRevisa,cCodFor,cLoja,@cItPla,@cItCNB,@aFilsEnv,lLote,cLote)
	EndIf
EndIf

//Função que cria os itens das planilhas para os produtos sem SC's.
CNTA300Pss(oModel300,cCodEdt,cNumPro,cRevisa,cCodFor,cLoja,@cItPla,@cItCNB,@aFilsEnv,lLote,cLote,nLinhaPla,lVenda,oModel200,lAta,cNumAta,cFilOrig,cFilEnt)

CNTA300BlMd(oModel300:GetModel('CNBDETAIL'),.T.,.T.)
CNTA300BlMd(oModel300:GetModel('CNZDETAIL'),.T.)
CNTA300BlMd(oModel300:GetModel('CNCDETAIL'),.T.)
CNTA300BlMd(oModel300:GetModel('CNADETAIL'),.T.,.T.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}CNTA300Itns()
Rotina para carga das planilhas dos produtos que possuem SC's
Funcao utilizada na integracao com o modulo SIGAGCP.

@author Matheus Lando Raimundo
@since 30/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CNTA300Itns(oModel,cCodEdt,cNumPro,cRevisa,cCodFor,cLoja,cItPla,lLote,cLote)
Local aFils		:= {}
Local oCNADetail	:= oModel:GetModel("CNADETAIL")
Local oCPDDetail	:= oModel:GetModel("CPDDETAIL")
Local oCNBDetail	:= oModel:GetModel("CNBDETAIL")
Local oCNCDetail	:= oModel:GetModel("CNCDETAIL")
Local oCNZDetail	:= oModel:GetModel("CNZDETAIL")
Local aCTBEnt		:= CTBEntArr(.T.)
Local cAliasCP4	:= GetNextAlias()
Local cItemRat	:= Replicate("0", (TamSx3('CNZ_ITEM')[1]))
Local cItem		:= Replicate("0", (TamSx3('CNB_ITEM')[1]))
Local lRateio		:= .F.
Local cSeekCNZ	:= ""
Local cRelacao	:= ""
Local cTpPla		:= SuperGetMV("MV_TPPLA", .T., "")
Local lRet			:= .F.
Local aRetorno	:= aR()
Local nQuant		:= 0
Local nPosNCtr	:= 0
Local cReman		:= ''
Local nCount		:= 0
Local aPerm      := {oCNADetail:lInsertLine,oCNADetail:lUpdateLine}
Local cQuant		:= ""
Local cPrcUn		:= ""
Local cFator		:= "CASE WHEN CO3.CO3_PERCEN > 0 THEN (CO3.CO3_PERCEN / 100) WHEN CO3.CO3_PERCEN = 0 THEN (1) END"
Local nQtd25		:= 0
Local cPercen		:= "%%"
Local cTipoPlan     := ""
Local bQuebra		:= {|| C1_PRODUTO+C1_NUM+C1_ITEM+C1_CC+C1_CLVL+C1_CONTA+C1_ITEMCTA }
Local cQuebra		:= ''
Local lAglutina		:= .F.
Local nCont			:= 0
Local lAgluAll		:= .F.
Local cKey300   	:= ''
Local cKey			:= "C1_PRODUTO,C1_NUM,C1_ITEM,C1_CC,C1_CLVL,C1_CONTA,C1_ITEMCTA"
Local lNotaEmp      := SuperGetMV("MV_NOTAEMP",.F.,.F.)
local lPosHMCO2		:= CO2->(FieldPos("CO2_HOMOLO")) > 0
local lPosDOCO2		:= CO2->(FieldPos("CO2_DOCOK")) > 0
Local cWhere		:= IIf(lPosHMCO2 .And. lPosDOCO2, "% AND CO2.CO2_HOMOLO = 'T' AND CO2.CO2_DOCOK = 'F' %", "%%")

GCP017BMod(oModel,{'CNBDETAIL'},.F.)
GCP017BMod(oModel,{'CNADETAIL'},.F.)

//³Ponto de Entrada para aglutinar solicitação de compras do edital para o contrato
If ExistBlock("C300SCQBRA")
	bQuebra := ExecBlock("C300SCQBRA",.F.,.F.,{bQuebra})
	If ValType(bQuebra) <> "B"
		bQuebra := {|| C1_PRODUTO+C1_NUM+C1_ITEM+C1_CC+C1_CLVL+C1_CONTA+C1_ITEMCTA }
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para ajustar a chave de ordenacao para usar em conjunto³
//³com o  C300SCQBRA                                                       ³  
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("C300SCFILK")
	cKey300 := ExecBlock("C300SCFILK",.F.,.F.,{cKey})
	If ValType(cKey300)=="C"
		cKey := cKey300
	EndIf
EndIf

cKey := '%'+cKey+'%'

If lLote
	cRelacao := '% AND CP4.CP4_LOTE = CO3.CO3_LOTE%'
Else
	cRelacao := '% AND CP4.CP4_CODPRO = CO3.CO3_CODPRO%'
	cLote     := '%(' + "'" + CriaVar('CO2_LOTE', .F.) +  "'" + ')%'
EndIf

cQuant := " SC1.C1_QUANT * " + cFator
cPrcUn := " CASE WHEN (CO3.CO3_PERCEN > 0 AND CO3.CO3_PERCEN <= 25) THEN CP6.CP6_PRCUN2 WHEN CO3.CO3_PERCEN <> 25 THEN CP6.CP6_PRCUN END  "
cPercen := "% ,CO3.CO3_PERCEN %"
cQuant := '%'+cQuant+'%'
cPrcUn := '%'+cPrcUn+'%'

If CO1->CO1_REMAN
	cReman := 	" AND CO2.CO2_REMAN = 'T'"
EndIf
cReman := '%'+cReman+'%'

BeginSQL Alias cAliasCP4

	SELECT SC1.C1_FILENT, SC1.C1_PRODUTO, SC1.C1_UM, SC1.C1_NUM, SC1.C1_ITEM, CO3.CO3_VLUNIT, SUM(SC1.C1_QUANT) C1_QUANT,
			SC1.C1_RATEIO, SC1.C1_CC, SC1.C1_CLVL, SC1.C1_CONTA, SC1.C1_ITEMCTA, CO2.CO2_ITEM	, CP6.CP6_PRCUN, CO3.CO3_LOTE, CO3.CO3_PERCEN,SB5.B5_TIPO
	FROM %table:CP4% CP4

		INNER JOIN %table:SC1% SC1 ON CP4.CP4_FILIAL = %xFilial:CP4%
								    	  AND CP4.CP4_NUMSC  = SC1.C1_NUM
								    	  AND CP4.CP4_ITEMSC = SC1.C1_ITEM
										  AND CP4.CP4_CODEDT = SC1.C1_CODED
										  AND CP4.CP4_NUMPRO = SC1.C1_NUMPR

		INNER JOIN %table:CO2% CO2 ON CP4.CP4_FILIAL      = CO2.CO2_FILIAL
										  AND CP4.CP4_CODEDT = CO2.CO2_CODEDT
								          AND CP4.CP4_NUMPRO = CO2.CO2_NUMPRO
								          AND CP4.CP4_REVISA = CO2.CO2_REVISA
								    	  AND CP4.CP4_CODPRO = CO2.CO2_CODPRO
								    	  AND CP4.CP4_LOTE   = CO2.CO2_LOTE

		INNER JOIN %table:CO3% CO3 ON CP4.CP4_FILIAL      = CO3.CO3_FILIAL
	    								  AND CP4.CP4_CODEDT = CO3.CO3_CODEDT
										  AND CP4.CP4_NUMPRO = CO3.CO3_NUMPRO
										  AND CP4.CP4_REVISA = CO3.CO3_REVISA
										  AND CO3.CO3_LOTE = CP4.CP4_LOTE
								    	  %exp:cRelacao%

		LEFT JOIN %table:CP6% CP6  ON		CP6.CP6_FILIAL	= CO3.CO3_FILIAL
										AND CP6.CP6_CODEDT	= CO3.CO3_CODEDT
										AND CP6.CP6_NUMPRO	= CO3.CO3_NUMPRO
										AND CP6.CP6_REVISA	= CO3.CO3_REVISA
										AND CP6.CP6_LOTE	= CO3.CO3_LOTE
										AND CP6.CP6_CODIGO	= CO3.CO3_CODIGO
										AND CP6.CP6_LOJA	= CO3.CO3_LOJA
										AND CP6.CP6_CODPRO	= CP4.CP4_CODPRO										
										AND CP6.%NotDel%
		Left Join %table:SB5% SB5 ON  SB5.B5_FILIAL = %xFilial:SB5% 
		                              	  AND SB5.B5_COD = SC1.C1_PRODUTO 
		                              	  AND SB5.%NotDel% 										  

	WHERE CP4.CP4_FILIAL  = %xfilial:CP4%
		AND CP4.CP4_CODEDT = %exp:cCodEdt%
		AND CP4.CP4_NUMPRO = %exp:cNumPro%
		AND CP4.CP4_REVISA = %exp:cRevisa%
		AND CP4.CP4_LOTE   IN %exp:cLote%
		AND CO3.CO3_CODIGO = %exp:cCodFor%
		AND CO3.CO3_LOJA   = %exp:cLoja%
		AND CO3.CO3_STATUS = '5'
		%exp:cWhere%
		AND CP4.%NotDel%
		AND SC1.%NotDel%
		AND CO2.%NotDel%
		AND CO3.%NotDel%

	GROUP BY SC1.C1_FILENT, C1_PRODUTO, SC1.C1_UM, CO2.CO2_QUANT , CO3.CO3_VLUNIT, SC1.C1_NUM, SC1.C1_ITEM,
			  SC1.C1_RATEIO, SC1.C1_CC, SC1.C1_CLVL, SC1.C1_CONTA, SC1.C1_ITEMCTA, CO2.CO2_ITEM , CP6.CP6_PRCUN, CO3.CO3_LOTE, CO3.CO3_PERCEN,SB5.B5_TIPO
	ORDER BY SC1.C1_FILENT,SB5.B5_TIPO,%exp:cKey%

EndSql

lRet := (cAliasCP4)->(!EOF())
cTipoPlan := (cAliasCP4)->B5_TIPO
cQuebra := (cAliasCP4)->(Eval(bQuebra))
While (cAliasCP4)->(!EOF())
	nCont ++
	//Caso o produto esteja vinculado a uma SC.	
	If aScan(aFils,(cAliasCP4)->C1_FILENT) == 0 .Or. (cAliasCP4)->B5_TIPO <> cTipoPlan 
		oCNADetail:SetNoInsertLine(.F.)
		oCNADetail:SetNoUpdateLine(.F.)
		cItem := Replicate("0",(TamSx3('CNB_ITEM')[1]))

		If cItPla <> Replicate("0",(TamSx3('CNA_NUMERO')[1]))
			oCNADetail:AddLine()
		EndIf
								
		cItPla := Soma1(cItPla)

		//-- Carrega dados da Planilha
		oCNADetail:SetValue('CNA_FORNEC',oCNCDetail:GetValue('CNC_CODIGO'))
		oCNADetail:SetValue('CNA_LJFORN',oCNCDetail:GetValue('CNC_LOJA'))
		oCNADetail:SetValue('CNA_TIPPLA',cTpPla)
		oCNADetail:SetValue('CNA_NUMERO',cItPla)
		oCNADetail:SetValue('CNA_DTINI',dDataBase)
		oCNADetail:LoadValue('CNA_FLREAJ', oModel:GetValue("CN9MASTER", "CN9_FLGREJ"))
		oCPDDetail:SetValue('CPD_FILAUT',(cAliasCP4)->C1_FILENT) //-- Carrega filial autorizada
		aAdd(aFils, (cAliasCP4)->C1_FILENT)
	EndIf
	
	If cQuebra <> (cAliasCP4)->(Eval(bQuebra))
		If !Empty(oCNBDetail:GetValue('CNB_PRODUT'))
			oCNBDetail:AddLine()
		EndIf
		cQuebra := (cAliasCP4)->(Eval(bQuebra))
		lAglutina := .F.		
	Else
		If nCont > 1
			lAgluAll := .T.
			lAglutina := .T.
		Else
			lAglutina := .F.
		EndIf
	EndIf

	//Verifica se possui rateio para não aglutinar
	SCX->(DbSetOrder(1))
	lRateio := SCX->(dbSeek(cSeekCNZ := xFilial("SCX")+(cAliasCP4)->(C1_NUM+C1_ITEM)))

	//-- Carrega Itens da planilha
	If !lAglutina .Or. nCont == 1
		cItem := Soma1(cItem)
		oCNBDetail:SetValue('CNB_ITEM',cItem)
		oCNBDetail:SetValue('CNB_PRODUT',(cAliasCP4)->C1_PRODUTO)
	EndIF
	If (!lAglutina .Or. nCont == 1) .And. !lAgluAll	
		oCNBDetail:SetValue('CNB_GCPIT',(cAliasCP4)->CO2_ITEM)
		oCNBDetail:SetValue('CNB_GCPLT',(cAliasCP4)->CO3_LOTE)
	Else
		oCNBDetail:SetValue('CNB_GCPIT','')
		oCNBDetail:SetValue('CNB_GCPLT','')
	EndIf
	aRetorno := aR()
	nPosNCtr := aScan(aRetorno,{|x| x[2] + x[8] == (cAliasCP4)->C1_PRODUTO + (cAliasCP4)->CO3_LOTE })
	If CO1->CO1_REMAN .And. nPosNCtr > 0
		nQuant := aRetorno[nPosNCtr,3]
		oCNBDetail:SetValue('CNB_QUANT',nQuant)
	Else
		If (cAliasCP4)->CO3_PERCEN > 0
			nQtd25 := (cAliasCP4)->CO2_QUANT*(cAliasCP4)->CO3_PERCEN  / 100
			oCNBDetail:SetValue('CNB_QUANT',nQtd25)
		Else
			If lAglutina .And. !lRateio .And. nCont > 1
				oCNBDetail:SetValue('CNB_QUANT',oCNBDetail:GetValue("CNB_QUANT")+(cAliasCP4)->C1_QUANT)
			Else
				oCNBDetail:SetValue('CNB_QUANT',(cAliasCP4)->C1_QUANT)
			EndIf
		EndIf
	EndIf
	
	If lAglutina .And. !lRateio .And. nCont > 1 .Or. lAgluAll
		oCNBDetail:SetValue('CNB_NUMSC','')
		oCNBDetail:SetValue('CNB_ITEMSC','')
	Else	
		oCNBDetail:SetValue('CNB_NUMSC',(cAliasCP4)->C1_NUM)
		oCNBDetail:SetValue('CNB_ITEMSC',(cAliasCP4)->C1_ITEM)
	EndIf

	If !lLote
		oCNBDetail:SetValue('CNB_VLUNIT', (cAliasCP4)->CO3_VLUNIT)
		oCNBDetail:SetValue('CNB_VLTOT', (cAliasCP4)->CO3_VLUNIT * oCNBDetail:GetValue('CNB_QUANT'))
	Else
		oCNBDetail:SetValue('CNB_VLUNIT',(cAliasCP4)->CP6_PRCUN)
		oCNBDetail:SetValue('CNB_VLTOTR',(cAliasCP4)->CP6_PRCUN * oCNBDetail:GetValue('CNB_QUANT'))
	EndIf

	If lNotaEmp
		If A400GetIt(CX0->CX0_CODNE,(cAliasCP4)->C1_PRODUTO)
			oCNBDetail:LoadValue('CNB_CODNE', CX0->CX0_CODNE)
			oCNBDetail:LoadValue('CNB_ITEMNE', CX1->CX1_ITEM)
		EndIf
	EndIf

	//Verifica se possui rateio, caso sim alimenta o model "CNZ".
	If lRateio
		cItemRat := Replicate("0", (TamSx3('CNZ_ITEM')[1]))

		While SCX->(!Eof()) .And. SCX->(CX_FILIAL+CX_SOLICIT+CX_ITEMSOL) == cSeekCNZ
			If cItemRat <> Replicate("0", (TamSx3('CNZ_ITEM')[1]))
				oCNZDetail:AddLine()
			EndIf

			cItemRat := Soma1(cItemRat)
			oCNZDetail:SetValue('CNZ_ITEM',cItemRat)
			oCNZDetail:SetValue('CNZ_PERC',SCX->CX_PERC)
			oCNZDetail:SetValue('CNZ_CC',SCX->CX_CC)
			oCNZDetail:SetValue('CNZ_CONTA',SCX->CX_CONTA)
			oCNZDetail:SetValue('CNZ_ITEMCT',SCX->CX_ITEMCTA)
			oCNZDetail:SetValue('CNZ_CLVL',SCX->CX_CLVL)

			For nCount := 1 To Len(aCTBEnt)
				//-- Adiciona valor nas entidades contabeis
				If CNZ->(FieldPos("CNZ_EC" +aCTBEnt[nCount] +"CR")) > 0 .And. SCX->(FieldPos("CX_EC"+aCTBEnt[nCount]+"CR")) > 0
					oCNZDetail:SetValue("CNZ_EC" +aCTBEnt[nCount] +"CR",SCX->&("CX_EC" +aCTBEnt[nCount] +"CR"))
				EndIf
				If CNZ->(FieldPos("CNZ_EC" +aCTBEnt[nCount] +"DB")) > 0 .And. SCX->(FieldPos("CX_EC" +aCTBEnt[nCount] +"DB")) > 0
					oCNZDetail:SetValue("CNZ_EC" +aCTBEnt[nCount] +"DB",SCX->&("CX_EC" +aCTBEnt[nCount] +"DB"))
				EndIf
			Next nCount

			SCX->(dbSkip())
		End
	Else
		If lAglutina .And. nCont > 1
			oCNBDetail:SetValue('CNB_CC',Iif(oCNBDetail:GetValue("CNB_CC")<>(cAliasCP4)->C1_CC,'',(cAliasCP4)->C1_CC))
			oCNBDetail:SetValue('CNB_CLVL',Iif(oCNBDetail:GetValue("CNB_CLVL")<>(cAliasCP4)->C1_CLVL,'',(cAliasCP4)->C1_CLVL))
			oCNBDetail:SetValue('CNB_CONTA',Iif(oCNBDetail:GetValue("CNB_CONTA")<>(cAliasCP4)->C1_CONTA,'',(cAliasCP4)->C1_CONTA))
			oCNBDetail:SetValue('CNB_ITEMCT',Iif(oCNBDetail:GetValue("CNB_ITEMCT")<>(cAliasCP4)->C1_ITEMCTA,'',(cAliasCP4)->C1_ITEMCTA))			
		Else
			oCNBDetail:SetValue('CNB_CC',(cAliasCP4)->C1_CC)
			oCNBDetail:SetValue('CNB_CLVL',(cAliasCP4)->C1_CLVL)
			oCNBDetail:SetValue('CNB_CONTA',(cAliasCP4)->C1_CONTA)
			oCNBDetail:SetValue('CNB_ITEMCT',(cAliasCP4)->C1_ITEMCTA)
	
			For nCount := 1 To Len(aCTBEnt)
				//-- Adiciona valor nas entidades contabeis
				If CNB->(FieldPos("CNB_EC" +aCTBEnt[nCount] +"CR")) > 0 .And. SC1->(FieldPos("C1_EC"+aCTBEnt[nCount]+"CR")) > 0
					oCNBDetail:SetValue("CNB_EC" +aCTBEnt[nCount] +"CR",SC1->&("C1_EC" +aCTBEnt[nCount] +"CR"))
				EndIf
				If CNB->(FieldPos("CNB_EC" +aCTBEnt[nCount] +"DB")) > 0 .And. SC1->(FieldPos("C1_EC" +aCTBEnt[nCount] +"DB")) > 0
					oCNBDetail:SetValue("CNB_EC" +aCTBEnt[nCount] +"DB",SC1->&("C1_EC" +aCTBEnt[nCount] +"DB"))
				EndIf
			Next nCount
		EndIf
	EndIf
	cTipoPlan := (cAliasCP4)->B5_TIPO
	(cAliasCP4)->(dbSkip())
End

oCNADetail:SetNoInsertLine(aPerm[1])
oCNADetail:SetNoUpdateLine(aPerm[2])

oCNADetail:GoLine(1)
oCPDDetail:GoLine(1)
oCNBDetail:GoLine(1)
oCNCDetail:GoLine(1)
oCNZDetail:GoLine(1)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}CNTA300Rst()
Rotina para carga dos itens das planilhas referente a sobra
das quantidades do Edital e das Solicitações de Compra
Funcao utilizada na integracao com o modulo SIGAGCP.

@author Matheus Lando Raimundo
@since 30/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CNTA300Rst(oModel,cCodEdt,cNumPro,cRevisa,cCodFor,cLoja,cItPla,cItemCNB,aFils,lLote,cLote)
Local oCNADetail	:= oModel:GetModel("CNADETAIL")
Local oCPDDetail	:= oModel:GetModel("CPDDETAIL")
Local oCNBDetail	:= oModel:GetModel("CNBDETAIL")
Local oCNCDetail	:= oModel:GetModel("CNCDETAIL")
Local cAliasCP4		:= GetNextAlias()
Local nI			:= 0
Local cTpPla		:= SuperGetMV("MV_TPPLA", .T., "")
Local nLinhaPla		:= 0
Local aRetorno		:= aR()
Local nQuant		:= 0
Local nPosNCtr		:= 0
Local cReman		:= ""
Local cQuant		:= ""
Local cPrcUn		:= ""
Local cFator		:= "CASE WHEN CO3.CO3_PERCEN > 0 THEN (CO3.CO3_PERCEN / 100) WHEN CO3.CO3_PERCEN = 0 THEN (1) END"
Local cPercen 		:= "%%"
Local nQtd25		:= 0
Local aProp			:= {}
Local lNotaEmp      := SuperGetMV("MV_NOTAEMP",.F.,.F.)

If aScan(aFils, cFilAnt) == 0
	aAdd(aFils,cFilAnt)
EndIf

If lLote
	cRelacao := '% AND CP4.CP4_LOTE = CO3.CO3_LOTE%'
Else
	cRelacao := '% AND CP4.CP4_CODPRO = CO3.CO3_CODPRO%'
	cLote     := '%(' + "'" + CriaVar('CO2_LOTE', .F.) +  "'" + ')%'
EndIf

cQuant := " SUM(CO2.CO2_QUANT * " + cFator + ") - SUM(SC1.C1_QUANT * " + cFator + " ) "
cPrcUn := " CASE WHEN CO3.CO3_PERCEN > 0 AND CO3.CO3_PERCEN <= 25 THEN CP6.CP6_PRCUN2 WHEN CO3.CO3_PERCEN <> 25 THEN CP6.CP6_PRCUN END "
cPercen := "% ,CO3.CO3_PERCEN %"
cQuant := '%'+cQuant+'%'

If CO1->CO1_REMAN
	cReman := 	" AND CO2.CO2_REMAN = 'T'"
EndIf
cReman := '%'+cReman+'%'
cPrcUn := '%'+cPrcUn+'%'

BeginSQL Alias cAliasCP4
SELECT SC1.C1_PRODUTO, CO2.CO2_QUANT - SUM(SC1.C1_QUANT) QUANT, CO3.CO3_VLUNIT, CO2.CO2_ITEM, %exp:cPrcUn% CP6_PRCUN, CO3.CO3_LOTE %exp:cPercen%
	 FROM %table:CP4% CP4
		INNER JOIN %table:SC1% SC1 ON CP4.CP4_FILIAL     	 = %xFilial:CP4%
										  AND CP4.CP4_FILENT = SC1.C1_FILENT
										  AND CP4.CP4_NUMSC  = SC1.C1_NUM
										  AND CP4.CP4_ITEMSC = SC1.C1_ITEM

		INNER JOIN %table:CO2% CO2 ON CP4.CP4_FILIAL 	   	 = CO2.CO2_FILIAL
										  AND CP4.CP4_CODEDT = CO2.CO2_CODEDT
								      	  AND CP4.CP4_NUMPRO = CO2.CO2_NUMPRO
								      	  AND CP4.CP4_REVISA = CO2.CO2_REVISA
										  AND CP4.CP4_CODPRO = CO2.CO2_CODPRO
										  AND CP4.CP4_LOTE   = CO2.CO2_LOTE

	    INNER JOIN %table:CO3% CO3 ON CP4.CP4_FILIAL      	 = CO3.CO3_FILIAL
	    								  AND CP4.CP4_CODEDT = CO3.CO3_CODEDT
										  AND CP4.CP4_NUMPRO = CO3.CO3_NUMPRO
										  AND CP4.CP4_REVISA = CO3.CO3_REVISA
								    	 %exp:cRelacao%

		LEFT JOIN %table:CP6% CP6 ON CP4.CP4_FILIAL	   		  = CP6.CP6_FILIAL
									     AND CP4.CP4_CODEDT   = CP6.CP6_CODEDT
										 AND CP4.CP4_NUMPRO   = CP6.CP6_NUMPRO
										 AND CP4.CP4_REVISA   = CP6.CP6_REVISA
										 AND CP4.CP4_LOTE     = CP6.CP6_LOTE
										 AND CP4.CP4_CODPRO   = CP6.CP6_CODPRO
										 AND CO3.CO3_CODIGO   = CP6.CP6_CODIGO
										 AND CO3.CO3_LOJA     = CP6.CP6_LOJA
										 AND CP6.%NotDel%

	WHERE CP4.CP4_FILIAL  = %xfilial:CP4%
		AND CP4.CP4_CODEDT = %exp:cCodEdt%
		AND CP4.CP4_NUMPRO = %exp:cNumPro%
		AND CP4.CP4_REVISA = %exp:cRevisa%
		AND CP4.CP4_LOTE IN %exp:cLote%
		AND CO3.CO3_CODIGO = %exp:cCodFor%
		AND CO3.CO3_LOJA   = %exp:cLoja%
		AND CO3.CO3_STATUS = '5'
	    AND CP4.%NotDel%
		AND SC1.%NotDel%
		AND CO2.%NotDel%
		AND CO3.%NotDel%

	GROUP BY SC1.C1_PRODUTO, CO2.CO2_QUANT ,CO3.CO3_VLUNIT, CO2.CO2_ITEM, %exp:cPrcUn%, CO3.CO3_LOTE %exp:cPercen%
	HAVING CO2.CO2_QUANT - SUM(SC1.C1_QUANT) > 0

EndSql

If !(cAliasCP4)->(Eof())
	//-- Carrega dados da Planilha
	If cItPla <> Replicate("0", (TamSx3('CNA_NUMERO')[1]))
		oCNADetail:SetNoInsertLine(.F.)
		nLinhaPla := oCNADetail:AddLine()
		oCNADetail:SetNoInsertLine(.T.)
	Else
		nLinhaPla := 1
	EndIf

	aProp := GetPropMdl(oCNADetail)
	CNTA300BlMd(oCNADetail,.F.)

	cItPla := Soma1(cItPla)
	oCNADetail:SetValue('CNA_FORNEC',oCNCDetail:GetValue('CNC_CODIGO'))
	oCNADetail:SetValue('CNA_LJFORN',oCNCDetail:GetValue('CNC_LOJA'))
	oCNADetail:SetValue('CNA_TIPPLA',cTpPla)
	oCNADetail:SetValue('CNA_NUMERO',cItPla)
	oCNADetail:SetValue('CNA_DTINI',dDataBase)

	RstPropMdl(oCNADetail,aProp)

	//-- Carrega todas as filiais autorizadas
	For nI := 1 To Len(aFils)
		If !Empty(oCPDDetail:GetValue('CPD_FILAUT'))
			oCPDDetail:AddLine()
		EndIf
		oCPDDetail:SetValue('CPD_FILAUT',aFils[nI])
		oCPDDetail:SetValue('CPD_NUMPLA',cItPla)
	Next nI

	While (cAliasCP4)->(!Eof())
		If 	cItemCNB <> Replicate("0",(TamSx3('CNB_ITEM')[1]))
			oCNBDetail:AddLine()
		EndIf

		cItemCNB := Soma1(cItemCNB)
		oCNBDetail:SetValue('CNB_ITEM',cItemCNB)
		oCNBDetail:SetValue('CNB_PRODUT',(cAliasCP4)->C1_PRODUTO)
		oCNBDetail:SetValue('CNB_GCPIT',(cAliasCP4)->CO2_ITEM)
		oCNBDetail:SetValue('CNB_GCPLT',(cAliasCP4)->CO3_LOTE)

		aRetorno := aR()
		nPosNCtr := aScan(aRetorno,{|x| x[2] + x[8] == (cAliasCO2)->CO2_CODPRO + (cAliasCO2)->CO3_LOTE })
		If CO1->CO1_REMAN .And. nPosNCtr > 0
			nQuant := aRetorno[nPosNCtr,3]
			oCNBDetail:SetValue('CNB_QUANT',nQuant)
		Else
			If (cAliasCP4)->CO3_PERCEN > 0
				nQtd25 := (cAliasCP4)->CO2_QUANT*(cAliasCP4)->CO3_PERCEN  / 100
				oCNBDetail:SetValue('CNB_QUANT',nQtd25)
			Else
				oCNBDetail:SetValue('CNB_QUANT',(cAliasCP4)->QUANT)
			EndIf
		EndIf

		If !lLote
			oCNBDetail:SetValue('CNB_VLUNIT',(cAliasCP4)->CO3_VLUNIT)
			oCNBDetail:SetValue('CNB_VLTOTR',(cAliasCP4)->CO3_VLUNIT * oCNBDetail:GetValue('CNB_QUANT'))
		Else
			oCNBDetail:SetValue('CNB_VLUNIT',(cAliasCP4)->CP6_PRCUN)
			oCNBDetail:SetValue('CNB_VLTOTR',(cAliasCP4)->CP6_PRCUN * oCNBDetail:GetValue('CNB_QUANT'))
		EndIf

		If lNotaEmp
	  		If A400GetIt(CX0->CX0_CODNE,(cAliasCP4)->C1_PRODUTO)
	  			oCNBDetail:LoadValue('CNB_CODNE', CX0->CX0_CODNE)
	  			oCNBDetail:LoadValue('CNB_ITEMNE', CX1->CX1_ITEM)
	  		EndIf
		Endif
		(cAliasCP4)->(dbSkip())
	EndDo
EndIf

oCNADetail:GoLine(1)
oCPDDetail:GoLine(1)
oCNBDetail:GoLine(1)

Return nLinhaPla

//-------------------------------------------------------------------
/*/{Protheus.doc}CNTA300Pss()
Rotina para carga dos itens das planilhas dos produtos sem SC's
Funcao utilizada na integracao com o modulo SIGAGCP.

@author Matheus Lando Raimundo
@since 30/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CNTA300Pss(oModel,cCodEdt,cNumPro,cRevisa,cCodFor,cLoja,cItPla,cItemCNB,aFils,lLote,cLote,nLinhaPla,lVenda,oModel200,lAta,cNumAta,cFilOrig,cFilEnt)
	Local oCNADetail	:= oModel:GetModel("CNADETAIL")
	Local oCPDDetail	:= oModel:GetModel("CPDDETAIL")
	Local oCNBDetail	:= oModel:GetModel("CNBDETAIL")
	Local oCNCDetail	:= oModel:GetModel("CNCDETAIL")
	Local oCNZDetail	:= oModel:GetModel("CNZDETAIL")
	Local nI			:= 0
	Local nX			:= 0
	Local nY 			:= 0
	Local cAliasCO2	:= GetNextAlias()
	Local cTpPla		:= SuperGetMV("MV_TPPLA", .T., "")
	Local aRetorno	:= aR()
	Local nQuant		:= 0
	Local nPosNCtr	:= 0
	Local aProds 		:= {}
	Local lSrp			:= 	oModel200 <> Nil .And. !lVenda
	Local aRecNoCPE	:= {}
	Local lRateio		:= .F.
	Local lIncManual	:= .F.
	Local nQtd25		:= 0
	Local lCN300EDT	:= .F.
	Local cNAta		:= ""
	Local nVlUnit		:= 0
	Local lAtaCtrt	:= .F.
	Local cAutom		:= IIF(!lAta,Iif(oModel200 <> Nil,oModel200:GetModel("CO1MASTER"):GetValue("CO1_AUTO"),oModel:GetModel("CN9MASTER"):GetValue("CN9_AUTO")),"0")
	Local lCtrVend	:= cAutom == '1' .And. CO1->CO1_GERDOC == '2'
	Local lNotaEmp	:= SuperGetMV("MV_NOTAEMP",.F.,.F.)
	Local aCTBEnt		:= CTBEntArr()
	Local nCount		:= 0
	Local lGerCent		:= SuperGetMV("MV_GCPFIAP", .T., "C") == "C"
	Local nQtdeCNB		:= 0
	Local cLoteAta		:= ''
	Local cNumSC		:= ""
	Local cItemSC		:= ""
	Local cPlaVazia		:= Replicate("0", (TamSx3('CNA_NUMERO')[1]))
	Local cItPlaZero	:= Replicate("0",(TamSx3('CNB_ITEM')[1]))
	Local bRetorno		:= IIF(lAta, {|x| x[2] + x[8] == (cAliasCO2)->CPY_CODPRO}, {|x| x[2] + x[8] == (cAliasCO2)->CO2_CODPRO + (cAliasCO2)->CO3_LOTE })
	Local lPosCO3		:= .F.
	Local lCredencia	:= IIF((!lAta .And. oModel200 <> Nil), oModel200:GetValue("CO1MASTER", "CO1_MODALI") == "CR", .F.)	
	Local lAddRec		:= .F.
	Default oModel200	:= Nil
	Default cFilOrig	:= cFilAnt
	Default cFilEnt 	:= cFilAnt

	GCP017BMod(oModel,{'CNBDETAIL'},.F.)
	GCP017BMod(oModel,{'CNADETAIL'},.F.)

	If lAta
		CO1->(DbSetOrder(1))
		lIncManual := !CO1->(DbSeek(xFilial("CO1",cFilOrig)+oModel200:GetModel("CPHMASTER"):GetValue("CPH_CODEDT")))
	EndIf

	//-- Caso esteja gerando o contrato pela Ata filtra somente os produtos selecionados na tela de manutenção do saldo.
	If lSrp .And. lAta
		For nX := 1 to oModel200:GetModel("CPIDETAIL"):Length()
			oModel200:GetModel("CPIDETAIL"):Goline(nX)
			If oModel200:GetModel("CPHMASTER"):GetValue("CPH_CODORG")== oModel200:GetModel("CPIDETAIL"):GetValue("CPI_CODORG");
			.Or. lIncManual ;
			.Or. !Empty(oModel200:GetModel("CPIDETAIL"):GetValue("CPI_FILENT"))
				For nY := 1 To oModel200:GetModel("CPEDETAIL"):Length()
					oModel200:GetModel("CPEDETAIL"):GoLine(nY)
					If oModel200:GetModel("CPEDETAIL"):GetValue('CPE_TIPDOC') == '1' .And. oModel200:GetModel("CPEDETAIL"):GetValue('CPE_OK')
						If Ascan(aProds, oModel200:GetModel("CPIDETAIL"):GetValue('CPI_CODPRO')) == 0
							Aadd(aProds, oModel200:GetModel("CPIDETAIL"):GetValue('CPI_CODPRO'))
						EndIf
						If !(lAddRec := lGerCent)					
							If !Empty(oModel200:GetModel("CPIDETAIL"):GetValue("CPI_FILENT")) .And. oModel200:GetModel("CPIDETAIL"):GetValue("CPI_FILENT") <> cFilOrig
								lAddRec:= oModel200:GetModel("CPIDETAIL"):GetValue("CPI_FILENT") == cFilEnt								
							Else
								lAddRec:= cFilOrig == cFilEnt
							EndIf
						EndIf
						If lAddRec
							cChave :=	oModel200:GetValue('CPYDETAIL','CPY_CODPRO')+;
										oModel200:GetValue('CPEDETAIL','CPE_CODORG')+;
										oModel200:GetValue('CPEDETAIL','CPE_NUMATA')+;
										oModel200:GetValue('CPEDETAIL','CPE_ITEM')
							Aadd(aRecNoCPE, {oModel200:GetModel("CPEDETAIL"):GetDataId(),cChave,oModel200:GetModel("CPEDETAIL"):GetValue('CPE_QUANT'),0})
						EndIf
					EndIf
				Next nY
			EndIf
		Next nX
	EndIf

	Default lVenda		:= .F.

	If aScan(aFils, cFilAnt) == 0
		aAdd(aFils, cFilAnt)
	EndIf

	If !lAta
		CNT300SATA(@cAliasCO2,lLote,cCodEdt,cNumPro,cRevisa,cCodFor,cLoja,cLote)
	Else
		CNT300CATA(@cAliasCO2,cNumAta,cCodFor,cLoja,cCodEdt,aRecNoCPE,cFilOrig)
	EndIf
	
	If ExistBlock("CN300EDT")//Ponto de entrada para validar se realiza a carga padrão ou customizada
		lCN300EDT := ExecBlock("CN300EDT",.F.,.F.,{oModel,@cAliasCO2,aFils,aRetorno,lLote,lAta,lRateio,lVenda,aProds,cCodEdt,cNumPro,cCodFor,cLoja,cLote})
	EndIf

	If !lCN300EDT .And. !(cAliasCO2)->(Eof())
		cTipPro := (cAliasCO2)->B5_TIPO
		lPosCO3 := ((cAliasCO2)->(ColumnPos('RECCO3') > 0) .And. CO3->(ColumnPos('CO3_QUANT') > 0) .And. lCredencia)
		While (cAliasCO2)->(!Eof())//-- Carrega dados da Planilha			
			If lPosCO3
				CO3->(DbGoTo( (cAliasCO2)->RECCO3 ))
				If (CO3->CO3_QUANT <= 0)
					(cAliasCO2)->(dbSkip())
					Loop
				EndIf
			EndIf
			If lAta
				If (nPosCPe := ASCAN(aRecNoCPE,{|a|a[2] == (cAliasCO2)->(CPY_CODPRO+CPE_CODORG+CPE_NUMATA+CPE_ITEM)})) > 0
					If aRecnoCPE[nPosCPE,4] >= aRecnoCPE[nPosCPE,3]
						(cAliasCO2)->(dbSkip())
						Loop	
					EndIf
					aRecnoCPE[nPosCPE,4]+=(cAliasCO2)->CPE_QUANT
				EndIf
			EndIf
			If nLinhaPla == 0 .or. (cTipPro <>  (cAliasCO2)->B5_TIPO .and. !Empty((cAliasCO2)->B5_TIPO))
				If (cItPla <> cPlaVazia)
					CNTA300BlMd(oModel:GetModel('CNADETAIL'),.F.)
					oCNADetail:SetNoInsertLine(.F.)
					oCNADetail:SetNoUpdateLine(.F.)
					oCNADetail:AddLine()
					cItemCNB:= "000"
				EndIf
				nLinhaPla++
				cItPla := Soma1(cItPla)
				If lVenda
					oCNADetail:SetValue('CNA_CLIENT', oCNCDetail:GetValue('CNC_CLIENT'))
					oCNADetail:SetValue('CNA_LOJACL', oCNCDetail:GetValue('CNC_LOJACL'))
				Else
					oCNADetail:SetValue('CNA_FORNEC',oCNCDetail:GetValue('CNC_CODIGO'))
					oCNADetail:SetValue('CNA_LJFORN',oCNCDetail:GetValue('CNC_LOJA'))
				EndIf

				oCNADetail:SetValue('CNA_TIPPLA',cTpPla)
				oCNADetail:SetValue('CNA_NUMERO',cItPla)
				oCNADetail:SetValue('CNA_DTINI'	,dDataBase)
				oCNADetail:LoadValue('CNA_FLREAJ',oModel:GetValue("CN9MASTER", "CN9_FLGREJ"))
				
				For nI := 1 To Len(aFils)//-- Carrega todas as filiais autorizadas
					If !Empty(oCPDDetail:GetValue('CPD_FILAUT'))
						oCPDDetail:AddLine()
					EndIf
					oCPDDetail:SetValue('CPD_FILAUT', aFils[nI])
					oCPDDetail:SetValue('CPD_NUMPLA', cItPla)
				Next nI
			Else				
				oCNADetail:GoLine(nLinhaPla)//-- Posiciona na ultima planilha inclusa.
			EndIf

			CNTA300BlMd(oModel:GetModel( 'CNBDETAIL' ), .F.)

			If Len(aProds) == 0 .Or. Ascan(aProds, IIf(lAta,(cAliasCO2)->CPY_CODPRO,(cAliasCO2)->CO2_CODPRO)) > 0
				If (cItemCNB <> cItPlaZero)
					oCNBDetail:AddLine()
				EndIf
				cItemCNB := Soma1(cItemCNB)
				oCNBDetail:SetValue('CNB_ITEM',cItemCNB)
				If lAta
					oCNBDetail:SetValue('CNB_PRODUT',(cAliasCO2)->CPY_CODPRO)
					oCNBDetail:SetValue('CNB_GCPLT',(cAliasCO2)->CPY_LOTE)
					oCNBDetail:SetValue('CNB_GCPIT',(cAliasCO2)->CPY_ITEM)
					cLoteAta := (cAliasCO2)->CPY_LOTE
				Else
					oCNBDetail:SetValue('CNB_PRODUT',(cAliasCO2)->CO2_CODPRO)
					oCNBDetail:SetValue('CNB_GCPIT',(cAliasCO2)->CO2_ITEM)
					oCNBDetail:SetValue('CNB_GCPLT',(cAliasCO2)->CO3_LOTE)
				EndIf
				aRetorno := aR()
				nPosNCtr := aScan(aRetorno,bRetorno)

				If CO1->CO1_REMAN .And. nPosNCtr > 0
					nQuant := aRetorno[nPosNCtr,3]
					oCNBDetail:SetValue('CNB_QUANT',nQuant)
				Else

					If lAta
						oCNBDetail:SetValue('CNB_QUANT',(cAliasCO2)->CPE_QUANT)
					Else						
						If (cAliasCO2)->CO3_PERCEN > 0
							nQtd25 := (cAliasCO2)->CO2_QUANT*(cAliasCO2)->CO3_PERCEN  / 100
							oCNBDetail:SetValue('CNB_QUANT',nQtd25)
						ElseIf(lPosCO3)
							oCNBDetail:SetValue('CNB_QUANT', CO3->CO3_QUANT)
						Else
							oCNBDetail:SetValue('CNB_QUANT', (cAliasCO2)->CO2_QUANT )
						EndIf
					endIf
				EndIf

				nQtdeCNB := oCNBDetail:GetValue('CNB_QUANT')
				If lCtrVend 
					If cPaisloc != "RUS"
						oCNBDetail:SetValue('CNB_TS','501') 
					Else
						oCNBDetail:SetValue('CNB_TS','   ')
					EndIf
				EndIf

				If lAta
					cNumSC := (cAliasCO2)->CX3_NUMSC
					cItemSC:= (cAliasCO2)->CX3_ITEMSC

					If Empty(cNumSC)
						a300SCCent(cNumAta,cLoteAta,@cNumSC,@cItemSC,nQtdeCNB)
					EndIf

					oCNBDetail:SetValue('CNB_NUMSC',cNumSC)
					oCNBDetail:SetValue('CNB_ITEMSC',cItemSC)

					SCX->(DbSetOrder(1))
					lRateio := SCX->(dbSeek(cSeekCNZ := xFilial("SCX")+cNumSC+cItemSC))

					If lRateio
						cItemRat := Replicate("0", (TamSx3('CNZ_ITEM')[1]))

						While SCX->(!Eof()) .And. SCX->(CX_FILIAL+CX_SOLICIT+CX_ITEMSOL) == cSeekCNZ
							If cItemRat <> Replicate("0", (TamSx3('CNZ_ITEM')[1]))
								oCNZDetail:AddLine()
							EndIf

							cItemRat := Soma1(cItemRat)
							oCNZDetail:SetValue('CNZ_ITEM',cItemRat)
							oCNZDetail:SetValue('CNZ_PERC',SCX->CX_PERC)
							oCNZDetail:SetValue('CNZ_CC',SCX->CX_CC)
							oCNZDetail:SetValue('CNZ_CONTA',SCX->CX_CONTA)
							oCNZDetail:SetValue('CNZ_ITEMCT',SCX->CX_ITEMCTA)
							oCNZDetail:SetValue('CNZ_CLVL',SCX->CX_CLVL)
							SCX->(dbSkip())
							
						EndDo
					Else
						oCNBDetail:SetValue('CNB_CC',(cAliasCO2)->C1_CC)
						oCNBDetail:SetValue('CNB_CLVL',(cAliasCO2)->C1_CLVL)
						oCNBDetail:SetValue('CNB_CONTA',(cAliasCO2)->C1_CONTA)
						oCNBDetail:SetValue('CNB_ITEMCT',(cAliasCO2)->C1_ITEMCTA)
						
						For nCount := 1 To Len(aCTBEnt)
							//-- Adiciona valor nas entidades contabeis
							If CNB->(FieldPos("CNB_EC"+aCTBEnt[nCount]+"CR")) > 0 .And. SC1->(FieldPos("C1_EC" +aCTBEnt[nCount] +"CR")) > 0
								oCNBDetail:SetValue("CNB_EC"+aCTBEnt[nCount]+"CR",(cAliasCO2)->&("C1_EC" +aCTBEnt[nCount] +"CR"))
							EndIf
							If CNB->(FieldPos("CNB_EC" +aCTBEnt[nCount] +"DB")) > 0 .And. SC1->(FieldPos("C1_EC" +aCTBEnt[nCount] +"DB")) > 0
								oCNBDetail:SetValue("CNB_EC" +aCTBEnt[nCount] +"DB",(cAliasCO2)->&("C1_EC" +aCTBEnt[nCount] +"DB"))
							EndIf
						Next nCount
						
					EndIf
				Else// -- fazendo manutenção de um contrato gerado pela ata mediante um REMANESCENTE.
					CPH->(dbSetOrder(1))
					If CPH->(dbSeek(xFilial("CPH")+cCodEdt+cNumPro))
						cNAta := CPH->CPH_NUMATA
						CPY->(dbSetOrder(1))
						If CPY->(dbSeek(xFilial("CPY")+cNAta+(cAliasCO2)->CO2_CODPRO))
							nVlUnit := CPY->CPY_VALATU
							lAtaCtrt := .T.
						EndIf
					EndIf					
				EndIf

				If !lLote
					If lAta
						oCNBDetail:SetValue('CNB_VLUNIT',(cAliasCO2)->CPY_VALATU)
						oCNBDetail:SetValue('CNB_VLTOTR',(cAliasCO2)->CPY_VALATU * oCNBDetail:GetValue('CNB_QUANT'))
					ElseIf lAtaCtrt
						oCNBDetail:SetValue('CNB_VLUNIT',nVlUnit)
						oCNBDetail:SetValue('CNB_VLTOTR',nVlUnit * oCNBDetail:GetValue('CNB_QUANT'))
					Else
						oCNBDetail:SetValue('CNB_VLUNIT',(cAliasCO2)->CO3_VLUNIT)
						oCNBDetail:SetValue('CNB_VLTOTR',(cAliasCO2)->CO3_VLUNIT * oCNBDetail:GetValue('CNB_QUANT'))
					EndIf
				ElseIf !lAta
					oCNBDetail:SetValue('CNB_VLUNIT',(cAliasCO2)->CP6_PRCUN)
					oCNBDetail:SetValue('CNB_VLTOTR',(cAliasCO2)->CP6_PRCUN * oCNBDetail:GetValue('CNB_QUANT'))
				EndIf

				If lAta
					oCNBDetail:LoadValue('CNB_CODNE', (cAliasCO2)->CX3_CODNE)
					oCNBDetail:LoadValue('CNB_ITEMNE', (cAliasCO2)->CX3_ITEMNE)
				ElseIf lNotaEmp .And. A400GetIt(CX0->CX0_CODNE,(cAliasCO2)->CO2_CODPRO)
					oCNBDetail:LoadValue('CNB_CODNE', CX0->CX0_CODNE)
					oCNBDetail:LoadValue('CNB_ITEMNE', CX1->CX1_ITEM)
				EndIf
			EndIf
			
			cTipPro := (cAliasCO2)->B5_TIPO
			(cAliasCO2)->(dbSkip())
		EndDo
	EndIf

	oCNADetail:GoLine(1)
	oCPDDetail:GoLine(1)
	oCNBDetail:GoLine(1)
	GCP017BMod(oModel,{'CNBDETAIL'},.T.)
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc}CN300VlDAss()
Valida data de assinatura

@author Aecio Ferreira Gomes
@since 03/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CN300VlDAss(dDataAssi,dDataInic)
Local lRet			:= .T.
Local lValidAss	:= GetNewPar("MV_CNVLASS","S") == "S"
Local oModel		:= FWModelActive()
Local oModelCN9	:= oModel:GetModel("CN9MASTER")

DEFAULT dDataAssi	:= oModelCN9:GetValue("CN9_DTASSI")
DEFAULT dDataInic	:= oModelCN9:GetValue("CN9_DTINIC")

If lValidAss
	If !Empty(dDataInic)
		lRet := (dDataAssi >= dDataInic)
	EndIf

	If !lRet
		Help(" ",1,"CNTA300ASS") //-- Data de assinatura deve ser maior que a data de inicio.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300PedC
Rotina para importacao de pedido de compra para planilha

@author Leandro.Moura
@since 01/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300PedC(lAuto,aAutSel, oView)
	Local aAreas 	:= {SC7->(GetArea()), GetArea()}
	Local aSaveLines:= FWSaveRows()

	Local oModel	:= FWModelActive()
	Local oModelCN9	:= oModel:GetModel("CN9MASTER")
	Local oModelCNA := oModel:GetModel("CNADETAIL")	
	Local aPCs		:= ""
	Local nCount	:= 0
	Local lFixo		:= Cn300RetSt("FIXO")
	Local lSemiProd := CN300RetSt('SEMIPROD')
	Local lOk		:= .T.
	Local lView		:= .F.	
	Local lPedido   := (SuperGetMV("MV_RESTPED",.F.,"N") == "S")
	Local aGrupo	:= UsrGrComp(RetCodUsr())
	Local aWhenModels	:= {}
	Default lAuto	:= oModelCN9:GetValue('CN9_AUTO') == '1'
	Default aAutSel := {}
	Default oView	:= Nil

	lView := (ValType(oView) == "O" .And. oView:IsActive() .And. !lAuto)

	DO 	CASE
		CASE !Empty(oModelCN9:GetValue("CN9_CODED")) //-- Verifica e' contrato de edital
			Help(" ",1,"CNT300PLEDT")  //-- O contrato foi gerado por um edital e por isso não se pode excluir planilhas
			lOk := .F.
		CASE oModelCNA:IsDeleted()
			Help('', 1, STR0090, NIL, STR0062, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0062})//-- O pedido não pode ser importado pois a planilha está deletada.
			lOk := .F.
		CASE Empty(oModelCNA:GetValue("CNA_TIPPLA")) .Or. (!lSemiProd .And. !lFixo)
			Help(" ",1,"CNTA300TPNP")	//-- O tipo de planilha selecionado não permite realizar esta ação.|| Verifique o tipo de planilha.
			lOk := .F.
		CASE !Empty(cTipRevisa) .AND. !(Cn300RetSt("MODALIDADE") $ "1|3" .AND. Cn300RetSt("ESPECIE") $ "1|4")			
			Help('', 1, STR0090, NIL, STR0219, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0219}) //- "Opção indisponível para o tipo de revisão selecionado."			
			lOk := .F.
		CASE (Empty(oModelCNA:GetValue("CNA_FORNEC")) .Or. Empty(oModelCNA:GetValue("CNA_LJFORN"))) //-- Verifica se a linha do cabecalho nao esta em branco ou deletada
			Help('', 1, STR0090, NIL, STR0050, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0050}) //-- Preencha os campos do cabeçalho da planilha.			
			lOk := .F.
	ENDCASE

	If lOk
		//-- Chama rotina para selecionar os PCs
		aPCs := CN300GetPC(lAuto,aAutSel)
		
		aWhenModels := {GCTGetWhen(oModel:GetModel("CNBDETAIL")),;						
						GCTGetWhen(oModel:GetModel("CNZDETAIL"))}

		MtBCMod(oModel, {'CNBDETAIL', 'CNZDETAIL'}, {||.T.})		

		dbSelectArea("SC7")
		For nCount := 1 to Len(aPCs)
			If !lOk
				Exit
			EndIf
			
			SC7->(dbGoto(aPCs[nCount]))//Posiciona na SC7 - Pedido
			If Empty(SC7->C7_GRUPCOM) .Or. !(lPedido .And. aScan(aGrupo, SC7->C7_GRUPCOM) <= 0)
				lOk := CN300AddPC() //Chama rotina para adicionar o item na planilha
			EndIf
		Next nCount
		
		GCTRstWhen(oModel:GetModel("CNBDETAIL"), aWhenModels[1])
		GCTRstWhen(oModel:GetModel("CNZDETAIL"), aWhenModels[2])
		FwFreeArray(aWhenModels)
	EndIf

	If lView		
		If oView:HasError()
			oView:ShowLastError()
		Endif
		oView:Refresh('VIEW_CNB')
	EndIf
	
	aEval(aAreas, {|x| RestArea(x), FwFreeArray(x) })	
	FwFreeArray(aAreas)
	
	FWRestRows(aSaveLines)
	FwFreeArray(aSaveLines)
	FwFreeArray(aPCs)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300PedC
Rotina para importacao de pedido de compra para planilha

@author Leandro.Moura
@since 01/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300GetPC(lAuto,aAutSel)
Local aArea		:= GetArea()
Local aAreaSC7	:= SC7->( GetArea() )
Local aButEnc	:= {}
Local aMarca 	:= {}
Local aCampos 	:= {}
Local aCpos	 	:= {}

Local oDlg		:= Nil
Local oMark		:= Nil
Local oMainWnd	:= Nil
Local oSizeMrk	:= Nil

Local cCadastro := STR0063		//"Pedido de Compra"
Local cMarca	:= GetMark()
Local cCampoOk	:= "C7_OK"
Local cFilSC7   := ""
Local cCN300PCF	:= ""

Local lInverte	:= .F.

Local nCount	:= 0
Local nOpcA     := 0
Local nX		:= 0

aCampos	:= {"C7_OK","C7_NUM","C7_ITEM","C7_PRODUTO","C7_QUANT","C7_PRECO","C7_DESCRI","C7_GRUPCOM"}
cFilSC7	:= 'C7_FILIAL == "'+xFilial('SC7')+'" .And. (C7_QUANT-C7_QUJE-C7_QTDACLA)>0 .And. C7_RESIDUO=" " .And. C7_TPOP<>"P"'

//----------------------------------------------------------
// Ponto de entrada para incremento do filtro da tela de PC
//----------------------------------------------------------
If ExistBlock("CN300PCF")
	cCN300PCF := ExecBlock("CN300PCF",.F.,.F.)
	If ValType(cCN300PCF) == "C" .And. !Empty(cCN300PCF)
		cFilSC7 += " .And. " + cCN300PCF
	EndIf
EndIf

//-- Monta os botoes da enchoice passando o filtro para ser restaurado na saida da visualizacao
aButEnc	:=  {	{STR0251,{|| axPesqui() },STR0056} ,;	   		//-- Pesquisar
					{STR0253,{|| C200VisuPC(RecNo())},STR0057} }	//-- Visualizar

//-- Monta o Header com os titulos do MsSelect
SX3->(dbSetOrder(2))
For nCount	:= 1 to Len(aCampos)
	If SX3->(dbSeek(aCampos[nCount]))
		If AllTrim(aCampos[nCount]) == "C7_OK"
			aAdd(aCpos,{aCampos[nCount],""," ",GetSx3Cache("C1_OK","X3_PICTURE")})
		Else
			aAdd(aCpos,{aCampos[nCount],"",AllTrim(X3Titulo()),GetSx3Cache(aCampos[nCount],"X3_PICTURE")})
		EndIf
	EndIf
Next nCount

SX3->(dbSetOrder(1))
SX3->(dbSeek("SC7"))
While !SX3->(EOF()) .And. SX3->X3_ARQUIVO == "SC7"
	If SX3->X3_BROWSE == "S" .And. SX3->X3_CONTEXT <> "V" .And. X3Uso(SX3->X3_USADO) .And. aScan(aCpos,{|x| AllTrim(x[1]) == AllTrim(SX3->X3_CAMPO)}) == 0
		aAdd(aCpos,{SX3->X3_CAMPO,"",AllTrim(X3Titulo()),SX3->X3_PICTURE})
	EndIf
	SX3->(dbSkip())
End

dbSelectArea("SC7")
SC7->(dbSetOrder(1)) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
Set Filter To &(cFilSC7) //-- Filtra Pedido de Compra

If !lAuto
	oSizeMrk := FwDefSize():New()
	oSizeMrk:AddObject( "GRID" ,100,100, .T., .T.,.F.) // Totalmente dimensionavel
	oSizeMrk:lProp := .T.
	oSizeMrk:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3
	oSizeMrk:Process()

	//-- Monta interface para selecionar os pedidos de compra
	DEFINE MSDIALOG oDlg TITLE cCadastro ;
								FROM oSizeMrk:aWindSize[1],oSizeMrk:aWindSize[2] TO oSizeMrk:aWindSize[3],oSizeMrk:aWindSize[4] OF oMainWnd PIXEL

	oMark := MsSelect():New("SC7",cCampoOk,"CN200FLAGPC()",aCpos,@lInverte,@cMarca,;
								{oSizeMrk:GetDimension('GRID','LININI'),oSizeMrk:GetDimension('GRID','COLINI'),;
								 oSizeMrk:GetDimension('GRID','LINEND'),oSizeMrk:GetDimension('GRID','COLEND')})

	oMark:bMark := {|| CN200AddMark(cMarca,@aMarca,cCampoOk,"SC7"),oMark:OBROWSE:Refresh()}
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||(nOpcA:=1),(oDlg:End())},{||oDlg:End()},,aButEnc)
Else
	For nX := 1 To Len(aAutSel)
		If SC7->(MsSeeK(xFilial('SC7')+aAutSel[nX,1]))
			CN200AddMark(cMarca,@aMarca,cCampoOk,"SC7")
		EndIf
	Next
	nOpcA := 1
EndIf

If !(nOpcA == 1)
	aMarca := {}
EndIf

SC7->(dbClearFilter())

RestArea(aAreaSC7)
RestArea(aArea)
Return aMarca

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300AddPC
Rotina para adicionar o item do pedido de compras na planilha

@author Leandro.Moura
@since 01/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300AddPC()
	Local aArea	 	:= GetArea()
	Local oModel	:= FWModelActive()
	Local oModelCNB := oModel:GetModel("CNBDETAIL")
	Local oModelCNZ	:= oModel:GetModel("CNZDETAIL")
	Local oModelCNA := oModel:GetModel("CNADETAIL")
	Local aCTBEnt	:= CTBEntArr()
	Local cItem		:= ""
	Local cItemRat	:= ''
	Local cSeekCNZ	:= ''
	Local nNewLine	:= 0
	Local nCount	:= 0
	Local nPosFld	:= 0
	Local lServico	:= Cn300RetSt('SERVIÇO')
	Local lSemiProd := CN300RetSt('SEMIPROD')
	Local lRet		:= .T.
	Local nVlrPlan  := 0
	Local nVlrSald  := 0

	//-- Caso a linha nao esteja em branco, adiciona uma linha
	If !Empty(oModelCNB:GetValue("CNB_PRODUT")) .And. (!Empty(oModelCNB:GetValue("CNB_QUANT")) .Or. lServico .Or. lSemiProd)
		cItem := Soma1(oModelCNB:GetValue("CNB_ITEM",oModelCNB:Length()))
		nNewLine := oModelCNB:AddLine()
	Else
		nNewLine := oModelCNB:GetLine()
		cItem := oModelCNB:GetValue( "CNB_ITEM" )
	EndIf

	oModelCNB:GoLine(nNewLine)
	oModelCNB:SetValue("CNB_ITEM",cItem)
	oModelCNB:SetValue("CNB_PRODUT",SC7->C7_PRODUTO)
	oModelCNB:SetValue("CNB_DESCRI",SC7->C7_DESCRI)
	oModelCNB:SetValue("CNB_UM",SC7->C7_UM)
	If !lServico .And. !lSemiProd
		oModelCNB:SetValue("CNB_QUANT",	SC7->(C7_QUANT - C7_QUJE))
		oModelCNB:SetValue("CNB_QTDSOL",SC7->(C7_QUANT - C7_QUJE))
	EndIf
	oModelCNB:SetValue("CNB_VLUNIT"	,SC7->C7_PRECO)
	oModelCNB:LoadValue("CNB_DESC",SC7->C7_DESC) 
	oModelCNB:LoadValue("CNB_VLDESC",SC7->C7_VLDESC) 				
	oModelCNB:SetValue("CNB_TE",SC7->C7_TES) 
	If cPaisloc == "RUS"
		oModelCNB:SetValue("CNB_CF",		SC7->C7_CF)
	EndIf
	oModelCNB:SetValue("CNB_CONTA",		SC7->C7_CONTA)
	oModelCNB:SetValue("CNB_CC",		SC7->C7_CC)
	oModelCNB:SetValue("CNB_CLVL",		SC7->C7_CLVL)
	oModelCNB:SetValue("CNB_ITEMCT",	SC7->C7_ITEMCTA)
	
	//Gatilha valor com desconto para a planilha
	If oModelCNB:GetValue("CNB_DESC") > 0

		nVlrPlan := oModelCNA:GetValue("CNA_VLTOT") - oModelCNB:GetValue("CNB_VLDESC")
		nVlrSald := oModelCNA:GetValue("CNA_SALDO") - oModelCNB:GetValue("CNB_VLDESC")
	
		oModel:GetModel("CNADETAIL"):GetStruct():SetProperty('CNA_VLTOT',MODEL_FIELD_WHEN,{||.T.})
	
		oModelCNA:SetValue("CNA_VLTOT",nVlrPlan)
		oModelCNA:SetValue("CNA_SALDO",nVlrSald)
		
		oModel:GetModel("CNADETAIL"):GetStruct():SetProperty('CNA_VLTOT',MODEL_FIELD_WHEN,{||.F.})
	EndIf
	//Verifica se possui rateio no pedido, caso sim alimenta o model "CNZ" - Rateio Contábil por Item.
	If SC7->C7_RATEIO == '1'			
		SCH->(DbSetOrder(2)) // -- FILIAL+PEDIDO+ITEMPD+ITEM
		If SCH->(dbSeek(cSeekCNZ := xFilial("SCH")+SC7->C7_NUM+SC7->C7_ITEM))
			cItemRat := Replicate("0", (TamSx3('CNZ_ITEM')[1]))

			While SCH->(!Eof()) .And. SCH->(CH_FILIAL+CH_PEDIDO+CH_ITEMPD) == cSeekCNZ
				If cItemRat <> Replicate("0", (TamSx3('CNZ_ITEM')[1]))
					oModelCNZ:AddLine()
				EndIf

				cItemRat := Soma1(cItemRat)
				oModelCNZ:SetValue('CNZ_ITEM'	, cItemRat)
				oModelCNZ:SetValue('CNZ_PERC'	, SCH->CH_PERC)
				oModelCNZ:SetValue('CNZ_CC'		, SCH->CH_CC)
				oModelCNZ:SetValue('CNZ_CONTA'	, SCH->CH_CONTA)
				oModelCNZ:SetValue('CNZ_ITEMCT'	, SCH->CH_ITEMCTA)
				oModelCNZ:SetValue('CNZ_CLVL'	, SCH->CH_CLVL)
				SCH->(dbSkip())
			EndDo
		EndIf
	EndIf

	// -- Verifica se existe entidades contábeis extras
	For nCount := 1 To Len(aCTBEnt)
		//-- Adiciona valor nas entidades contabeis
		If CNB->(FieldPos("CNB_EC" +aCTBEnt[nCount] +"CR")) > 0 .And. (nPosFld := SC7->(FieldPos("C7_EC"+aCTBEnt[nCount]+"CR"))) > 0			
			oModelCNB:SetValue("CNB_EC" +aCTBEnt[nCount] +"CR", SC7->(FieldGet(nPosFld)))
		EndIf
		If CNB->(FieldPos("CNB_EC" +aCTBEnt[nCount] +"DB")) > 0 .And. (nPosFld := SC7->(FieldPos("C7_EC"+aCTBEnt[nCount]+"DB"))) > 0
			oModelCNB:SetValue("CNB_EC" +aCTBEnt[nCount] +"DB", SC7->(FieldGet(nPosFld)))
		EndIf
	Next nCount
	
	lRet := !(oModel:HasErrorMessage())//O modelo não deve ter erros ao fim do processamento

	RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}CN300VlFor()
Validação para os campos Codigo(CNC_CODIGO) e Loja(CNC_LOJA) do Fornecedor

@author Aecio Ferreira Gomes
@since 03/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CN300VlFor()
Local lRet		 := .T.
Local oModel	 := FWModelActive()
Local oModelCNC	 := oModel:GetModel("CNCDETAIL")
Local oModelCNA	 := oModel:GetModel("CNADETAIL")
Local aAreaSA2   := {}
Local aSaveLines := {}
Local lIsCNC     := Substr(ReadVar(),4,3) == "CNC"
Local cForn		 := If(lIsCNC,oModelCNC:GetValue("CNC_CODIGO"),oModelCNA:GetValue("CNA_FORNEC"))
Local cLoja      := If(lIsCNC,oModelCNC:GetValue("CNC_LOJA"),oModelCNA:GetValue("CNA_LJFORN"))
Local cCampo     := ""
Local nLineCNC   := 0

If lIsCNC
	If !Empty(cLoja)
		lRet := ExistCpo("SA2",cForn+cLoja)
	Else
		aAreaSA2	:= SA2->(GetArea())
		SA2->(DbSetOrder(1))
		If SA2->(MsSeek(xFilial("SA2")+cForn))
			While !SA2->(EOF()) .And. SA2->A2_MSBLQL == '1'
				SA2->(dbSkip())
				If !SA2->(EOF()) .And. SA2->A2_MSBLQL <> '1'
					cLoja := SA2->A2_LOJA
					oModelCNC:SetValue("CNC_LOJA",cLoja)
				EndIf
			EndDo
		EndIf
		lRet := ExistCpo("SA2")
		RestArea(aAreaSA2)
	EndIf
Else
    cCampo := Substr(ReadVar(),4)

    If !Empty(cLoja) .And. cCampo == "CNA_LJFORN"
        nLineCNC := MTFindMVC(oModel:GetModel("CNCDETAIL"),{{"CNC_CODIGO",cForn},{"CNC_LOJA",cLoja}})
    Else
        nLineCNC := MTFindMVC(oModel:GetModel("CNCDETAIL"),{{"CNC_CODIGO",cForn}})
    EndIf
    
    lRet := nLineCNC > 0

    If lRet .And. cCampo == "CNA_FORNEC"//-- Preenche campo Loja (CNA_LJFORN)
        aSaveLines := FWSaveRows()

        oModelCNC:GoLine(nLineCNC)
        cLoja := oModelCNC:GetValue("CNC_LOJA")
        oModelCNA:LoadValue("CNA_LJFORN", cLoja)

        FWRestRows(aSaveLines)
    EndIf

    If !lRet
        Help(" ",1,"REGNOIS")
    EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}CN300VlCli()
Validação para os campos Codigo(CNC_CLIENT) e Loja(CNC_LOJACL) do Cliente

@author Aecio Ferreira Gomes
@since 03/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CN300VlCli()
Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local oModelCNC	:= oModel:GetModel("CNCDETAIL")
Local oModelCNA	:= oModel:GetModel("CNADETAIL")
Local aAreaSA1  := {}
Local lIsCNC	:= Substr(ReadVar(),4,3) == "CNC"
Local cClient	:= Iif(lIsCNC,oModelCNC:GetValue("CNC_CLIENT"),oModelCNA:GetValue("CNA_CLIENT"))
Local cLoja 	:= Iif(lIsCNC,oModelCNC:GetValue("CNC_LOJACL"),oModelCNA:GetValue("CNA_LOJACL"))
Local cCampo    := ""
Local nLineCNC  := 0

If lIsCNC
	If !Empty(cLoja)
		lRet := ExistCpo("SA1",cClient+cLoja)
	Else
		aAreaSA1	:= SA1->(GetArea())
		SA1->(DbSetOrder(1))
		If SA1->(MsSeek(xFilial("SA1")+cClient))
			While !SA1->(EOF()) .And. SA1->A1_MSBLQL == '1'
				SA1->(dbSkip())
				If !SA1->(EOF()) .And. SA1->A1_MSBLQL <> '1'
					cLoja := SA1->A1_LOJA
					oModelCNC:SetValue("CNC_LOJACL",cLoja)
				EndIf
			EndDo
		EndIf
		lRet := ExistCpo("SA1")
		RestArea(aAreaSA1)
	EndIf
Else
    cCampo := Substr(ReadVar(),4)
    
	If (FWIsInCallStack("At850GCTCr") .OR. FWIsInCallStack("At870EftRv")) .AND. FindFunction("TecCotrCli")
		lRet := TecCotrCli(cLoja, cClient, oModel, cCampo, @nLineCNC)
	Else
		If !Empty(cLoja) .And. cCampo == "CNA_LOJACL"
			nLineCNC := MTFindMVC(oModel:GetModel("CNCDETAIL"),{{"CNC_CLIENT",cClient},{"CNC_LOJACL",cLoja}})
		Else
			nLineCNC := MTFindMVC(oModel:GetModel("CNCDETAIL"),{{"CNC_CLIENT",cClient}})
		EndIf

        lRet := nLineCNC > 0
	EndIf
    
    If lRet .And. cCampo == "CNA_CLIENT"//-- Preenche campo Loja (CNC_LOJACL)
        aSaveLines := FWSaveRows()

        oModelCNC:GoLine(nLineCNC)
        cLoja := oModelCNC:GetValue("CNC_LOJACL")
        oModelCNA:LoadValue("CNA_LOJACL", cLoja)

        FWRestRows(aSaveLines)
    EndIf

	If !lRet
		Help(" ",1,"REGNOIS")
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VldRat
Rotina para validacao do rateio por CC dos itens da planilha
Pos validacao da linha do rateio - CNZ

@param lLine	:Informa se é validacao de linha
		nPerc	:Informa o percentual adicionando-se na grid para validação

@author Leandro.Moura
@since 01/10/2013
@version P11.90

@author Israel.Escorizza
@since 03/05/2016
@version P12.1.7

/*/
//-------------------------------------------------------------------
Function CN300VldRat(lLine,nPerc,oModelGrid)
Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oModel		:= Nil
Local oModelCNZ 	:= Nil
Local lRet			:= .T.
Local lTemRat		:= .F.
Local nCount		:= 1

Default lLine		:= .F.
Default nPerc		:= 0

If oModelGrid == Nil
	oModel		:= FWModelActive()
	oModelCNZ	:= oModel:GetModel("CNZDETAIL")
Else
	oModelCNZ	:= oModelGrid
EndIf

For nCount := 1 to oModelCNZ:Length()
	oModelCNZ:GoLine(nCount)
	If !oModelCNZ:IsDeleted() .And. !Empty(oModelCNZ:GetValue("CNZ_PERC"))
		nPerc += oModelCNZ:GetValue("CNZ_PERC")
		lTemRat := .T.
  	EndIf
Next nCount

If lTemRat
	If ((lLine .And. nPerc > 100) .Or. (!lLine .And. nPerc <> 100))	
		Help(" ",1,"CN300PRAT") //-- A soma dos percentuais diferem de 100%.
		lRet := .F.
	EndIf
	FWRestRows(aSaveLines)	
	RestArea(aArea)
EndIf

FwFreeArray(aSaveLines)
FwFreeArray(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300RatCC
Rotina para tratamento na gravacao de rateio por CC de itens da planilha

@param oModel		Model da rotina
@param oModelCNA	Model da tabela CNA - Planilhas

@author Leandro.Moura
@since 01/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300RatCC(oModel,oModelCNA)
Local aArea		:= GetArea()
Local aAreaCNZ	:= CNZ->(GetArea())
Local oModelCN9	:= oModel:GetModel("CN9MASTER")
Local oModelCNZ := oModel:GetModel("CNZDETAIL")
Local cFornec	:= oModelCNA:GetValue("CNA_FORNEC")
Local cLjForn	:= oModelCNA:GetValue("CNA_LJFORN")
Local cClient	:= oModelCNA:GetValue("CNA_CLIENT")
Local cLojCli	:= oModelCNA:GetValue("CNA_LOJACL")
Local cEspCnt	:= oModelCN9:GetValue("CN9_ESPCTR")
Local nCount	:= 0
Local lGravou	:= .F.

//-- Tratamento para cada item
For nCount := 1 to oModelCNZ:Length()
	oModelCNZ:GoLine(nCount)

	If !(oModelCNZ:IsDeleted()) .And. !Empty(oModelCNZ:GetValue("CNZ_PERC"))
		If oModelCNZ:IsInserted() .Or. oModelCNZ:IsUpdated()
			lGravou := .T.

			If cEspCnt == "1"
				oModelCNZ:LoadValue("CNZ_FORNEC",cFornec)
				oModelCNZ:LoadValue("CNZ_LJFORN",cLjForn)
			Else
				oModelCNZ:LoadValue("CNZ_CLIENT",cClient)
				oModelCNZ:LoadValue("CNZ_LOJACL",cLojCli)
			EndIf
		EndIf
	EndIf
Next nCount

RestArea(aAreaCNZ)
RestArea(aArea)
Return lGravou

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300CN9Pre
Rotina para tratamento no pre valid do Modelo CN9

@param nLine	Linha atual
@param cAction	Acao do usuario
@param cCampo	Campo em memoria
@param xValue	Valor em memoria

@author Flavio Lopes Rasta
@since 17/08/2015
@version 12
/*/
//-------------------------------------------------------------------
Function CN300CN9Pre(oModel,cAction,cCampo,xValue)
Local lRet		:= .T.
Local oModelCN9 := Nil

Default oModel 	:= FwModelActive()

oModelCN9 := oModel:GetModel("CN9MASTER")

If cAction == 'UNDELETE' .Or. cAction == 'SETVALUE'
	If cCampo $ "CN9_FLGREJ|CN9_PRORAT"
		CN300VRCt("CN9",xValue,,cCampo)
	EndIf
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300PItPre
Rotina para tratamento no pre valid do grid de itens da planilha

@param nLine	Linha atual
@param cAction	Acao do usuario
@param cCampo	Campo em memoria
@param xValue	Valor em memoria

@author Leandro.Moura
@since 01/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300PItPre(oModelGrid,nLine,cAction,cCampo,xValue,xOldValue)
Local oModel 	:= oModelGrid:GetModel()
Local oModelCNA := oModel:GetModel("CNADETAIL")
Local oModelCNB := oModel:GetModel("CNBDETAIL")
Local oModelCN9 := oModel:GetModel("CN9MASTER")
Local oModelCNF	:= oModel:GetModel("CNFDETAIL")
Local oModelCNS	:= oModel:GetModel("CNSDETAIL")

Local nVlrAtu		:= 0
Local nVlrPlan		:= 0
Local nVlrSald		:= 0
Local nVlrDes		:= 0
Local nX			:= 0
Local nAux			:= 0
Local nVlrFis		:= 0

Local lTipRev		:= !Empty(A300GTpRev())
Local lContab		:= Cn300RetSt("CONTABIL")
Local lRecorrente	:= Cn300RetSt("RECORRENTE")
Local lFixo		    := Cn300RetSt("FIXO")
Local lSemiFixo	    := Cn300RetSt("SEMIFIXO")
Local lCRM			:= SuperGetMV("MV_CRMXGCT",.F.,.F.) .And. !Empty(oModelCNB:GetValue("CNB_PROPOS"))
Local lNDelete		:= .F.
Local lMudouVlr 	:= .F.
Local lRet 		    := .T.
Local lRvSemValor	:= !VldVlrTotal() //Revisao sem alteracao de valor

If Empty(oModelCNB:GetValue("CNB_ITMDST")) .Or. FWIsInCallStack("A300DivCNB") .Or. cAction <> 'CANSETVALUE' .Or. lRvSemValor

	If cAction == 'CANSETVALUE'
		If Empty(oModelCNA:GetValue("CNA_TIPPLA"))
			Help('',1,'CNTA300NOTPPLA')
			lRet := .F.
		ElseIf lTipRev .And. !Empty(oModelCN9:GetValue("CN9_CODED")) .And. oModelCNB:IsInserted()
			lRet := CN300ExcArt(oModel,'ADITIVO')
		ElseIf lCRM .And. aScan(aGCTCRM,cCampo)
			Help(" ",1,"INTEGRACRM_2",,STR0229,1,1)
			lRet := .F.
		ElseIf cCampo == "CNB_VLTOT" .And. (lFixo .Or. lSemiFixo) .And. !lTipRev
			lRet := .F.
		EndIf
	
	ElseIf cAction == 'DELETE'
		If lCRM
			Help("",1,"INTEGRACRM_1",,STR0230)
			lRet := .F.
		ElseIf lTipRev .And. !oModelCNB:IsInserted()  .And. !DelItPlSF() /* Verifica se permite deletar item da planilha semi fixa */
			If !((cTipRevisa == DEF_REV_ADITI) .And. CN300RETST('REVESPECIE') $ '1*4*5' .And. CN300RETST('MODALIDADE') $ '2*3') .And.;
				(cTipRevisa != DEF_REV_ORCGS ) .And. (cTipRevisa != DEF_REV_ABERT )
				Help('',1,'CNTA300ND')
				lRet := .F.
			Else
				oModelCNB:Goline(nLine)
				//Não Permite deletar a linha se houver medição para a mesma
				If oModelCNB:GetValue("CNB_QTDMED") > 0
					Help('',1,'CNTA300ND')
					lRet := .F.
				EndIf
			
				If lRet
					nVlrPlan := oModelCNA:GetValue("CNA_VLTOT") - oModelCNB:GetValue("CNB_VLTOT") + oModelCNB:GetValue("CNB_VLDESC")
					nVlrSald := oModelCNA:GetValue("CNA_SALDO") - oModelCNB:GetValue("CNB_VLTOT") + oModelCNB:GetValue("CNB_VLDESC")
	
					IIF(nVlrPlan < 0,nVlrPlan := 0,)
					IIF(nVlrSald < 0,nVlrSald := 0,)
	
					oModel:GetModel("CNADETAIL"):GetStruct():SetProperty('CNA_VLTOT',MODEL_FIELD_WHEN,{||.T.})
					oModelCNA:SetValue("CNA_VLTOT",nVlrPlan)
					oModelCNA:SetValue("CNA_SALDO",nVlrSald)
	
					CN300BlVlr(oModel,nLine)
					If Cn300RetSt("FISICO")
						For nX := 1 To oModelCNF:Length()
							oModelCNF:GoLine(nX)
							If !oModelCNF:IsDeleted() .And. !Empty(oModelCNF:GetValue("CNF_PARCEL")) .And. oModelCNS:Length() >= nLine
								oModelCNS:GoLine(nLine)
								If !Empty(oModelCNS:GetValue("CNS_ITEM"))
									If !oModelCNS:CanDeleteLine()
										oModelCNS:SetNoDeleteLine(.F.)
										lNDelete := .T.
									EndIf
	
									nAux	:= oModelCNS:GetValue("CNS_PRVQTD") * (oModelCNB:GetValue("CNB_VLUNIT") - (oModelCNB:GetValue("CNB_VLDESC")/oModelCNB:GetValue("CNB_QUANT")))
									nVlrFis	:= oModel:GetModel("CALC_CNS"):GetValue("TCNS_VTOT") - nAux
	
									oModel:GetModel("CALC_CNS"):LoadValue("TCNS_VTOT",nVlrFis)
									oModelCNF:LoadValue("CNF_VLPREV", oModelCNF:GetValue("CNF_VLPREV") - nAux)
									oModelCNF:LoadValue("CNF_SALDO", oModelCNF:GetValue("CNF_SALDO") - nAux)
									oModel:GetModel("CALC_CNF"):LoadValue('CNF_CALC', -nAux)
	
									oModelCNS:DeleteLine()
	
									If lNDelete
										oModelCNS:SetNoDeleteLine(.T.)
									EndIf
								EndIf
							EndIf
						Next nX
					EndIf
				EndIf
			EndIf
	
		ElseIf (lRet := CN200DelOk()) .And. !Empty(oModelCNB:GetValue("CNB_VLTOT"))
			If !lRecorrente
				nVlrPlan := oModelCNA:GetValue("CNA_VLTOT") - oModelCNB:GetValue("CNB_VLTOT") + oModelCNB:GetValue("CNB_VLDESC")
				nVlrSald := oModelCNA:GetValue("CNA_SALDO") - oModelCNB:GetValue("CNB_VLTOT") + oModelCNB:GetValue("CNB_VLDESC")
				lMudouVlr := .T.
			ElseIf oModelCNB:GetValue("CNB_ATIVO") == "1"
				nVlrPlan := oModelCNA:GetValue("CNA_VLTOT") - oModelCNB:GetValue("CNB_VLTOT") + oModelCNB:GetValue("CNB_VLDESC")
				nVlrSald := oModelCNA:GetValue("CNA_SALDO") - oModelCNB:GetValue("CNB_VLTOT") + oModelCNB:GetValue("CNB_VLDESC")
				lMudouVlr := .T.
			EndIf
	
			If lMudouVlr
				aProp := GetPropMdl(oModelCNA)
				CNTA300BlMd(oModelCNA,.F.)
	
				oModel:GetModel("CNADETAIL"):GetStruct():SetProperty('CNA_VLTOT',MODEL_FIELD_WHEN,{||.T.})
				oModelCNA:SetValue("CNA_VLTOT",nVlrPlan)
				oModelCNA:SetValue("CNA_SALDO",nVlrSald)
	
				RstPropMdl(oModelCNA,aProp)
				CN300BlVlr(oModel,nLine)
			EndIf
	
			CN300BlVlr(oModel,nLine)
	
			If Cn300RetSt("FISICO") .And. !lTipRev .And. oModelCNB:IsInserted()//-- Se cronograma fisico, deleta item
				For nX := 1 To oModelCNF:Length()
					oModelCNF:GoLine(nX)
					If !oModelCNF:IsDeleted() .And. !Empty(oModelCNF:GetValue("CNF_PARCEL")) .And. oModelCNS:Length() >= nLine
						oModelCNS:GoLine(nLine)
						If !Empty(oModelCNS:GetValue("CNS_ITEM"))
							If !oModelCNS:CanDeleteLine()
								oModelCNS:SetNoDeleteLine(.F.)
								lNDelete := .T.
							EndIf
							oModelCNS:DeleteLine()
	
							If lNDelete
								oModelCNS:SetNoDeleteLine(.T.)
							EndIf
						EndIf
					EndIf
				Next nX
			EndIf
		EndIf
	ElseIf cAction == 'UNDELETE' .Or. (cAction == 'SETVALUE' .And. AllTrim(cCampo) $ "CNB_VLTOT|CNB_DESC|CNB_ATIVO|CNB_FLREAJ")
		If cAction == 'UNDELETE'
			If !lRecorrente
				nVlrPlan := oModelCNA:GetValue("CNA_VLTOT") + oModelCNB:GetValue("CNB_VLTOT") - oModelCNB:GetValue("CNB_VLDESC")
				nVlrSald := oModelCNA:GetValue("CNA_SALDO") + oModelCNB:GetValue("CNB_VLTOT") - oModelCNB:GetValue("CNB_VLDESC")
				lMudouVlr := .T.
			ElseIf oModelCNB:GetValue("CNB_ATIVO") == "1"
				nVlrPlan := oModelCNA:GetValue("CNA_VLTOT") + oModelCNB:GetValue("CNB_VLTOT") - oModelCNB:GetValue("CNB_VLDESC")
				nVlrSald := oModelCNA:GetValue("CNA_SALDO") + oModelCNB:GetValue("CNB_VLTOT") - oModelCNB:GetValue("CNB_VLDESC")
				lMudouVlr := .T.
			EndIf
	
			If (lRet := Cn300VlServ(oModelGrid,oModelGrid:GetValue('CNB_PRODUT'),nLine))
				If Cn300RetSt("FISICO")
					For nX := 1 To oModelCNF:Length()
						oModelCNF:GoLine(nX)
						If !oModelCNF:IsDeleted() .And. !Empty(oModelCNF:GetValue("CNF_PARCEL")) .And. oModelCNS:Length() >= nLine
							oModelCNS:GoLine(nLine)
							If !Empty(oModelCNS:GetValue("CNS_ITEM"))
								oModelCNS:UnDeleteLine()
								If ((cTipRevisa == DEF_REV_ADITI .Or. cTipRevisa == DEF_REV_ABERT).And. CN300RETST('REVESPECIE') $ '1*4' .And. CN300RETST('MODALIDADE') $ '2*3')
									nAux	:= oModelCNS:GetValue("CNS_PRVQTD") * (oModelCNB:GetValue("CNB_VLUNIT") - (oModelCNB:GetValue("CNB_VLDESC")/oModelCNB:GetValue("CNB_QUANT")))
									nVlrFis	:= oModel:GetModel("CALC_CNS"):GetValue("TCNS_VTOT") + nAux
									oModel:GetModel("CALC_CNS"):LoadValue("TCNS_VTOT",nVlrFis)
								EndIf
							EndIf
						EndIf
					Next nX
				EndIf
			EndIf
			lMudouVlr := .T.
		Else
			If cCampo $ "CNB_VLTOT"
				If !lRecorrente
					nVlrAtu  := oModelCNB:GetValue("CNB_VLTOT") - oModelCNB:GetValue("CNB_VLDESC")
					nVlrPlan := oModelCNA:GetValue("CNA_VLTOT") +(xValue *  (1-(oModelCNB:GetValue("CNB_DESC")/100))   )- nVlrAtu
					nVlrSald := oModelCNA:GetValue("CNA_SALDO") +(xValue *  (1-(oModelCNB:GetValue("CNB_DESC")/100))   )- nVlrAtu
					lMudouVlr:= .T.
				ElseIf oModelCNB:GetValue("CNB_ATIVO") == "1"
					nVlrAtu  := oModelCNB:GetValue("CNB_VLTOT") - oModelCNB:GetValue("CNB_VLDESC")
					nVlrPlan := oModelCNA:GetValue("CNA_VLTOT") +(xValue *  (1-(oModelCNB:GetValue("CNB_DESC")/100))   )- nVlrAtu
					nVlrSald := oModelCNA:GetValue("CNA_SALDO") +(xValue *  (1-(oModelCNB:GetValue("CNB_DESC")/100))   )- nVlrAtu
					lMudouVlr:= .T.
				EndIf
			ElseIf cCampo $ "CNB_ATIVO" .And. lRecorrente
				If xValue == "1" .And. oModelCNB:GetValue("CNB_ATIVO") <> "1"
					nVlrPlan := oModelCNA:GetValue("CNA_VLTOT") + oModelCNB:GetValue("CNB_VLTOT")  *  (1-(oModelCNB:GetValue("CNB_DESC")/100))
					nVlrSald := oModelCNA:GetValue("CNA_SALDO") + oModelCNB:GetValue("CNB_VLTOT")  *  (1-(oModelCNB:GetValue("CNB_DESC")/100))
					lMudouVlr := .T.
				ElseIf xValue == "2" .And. oModelCNB:GetValue("CNB_ATIVO") == "1"
					nVlrPlan := oModelCNA:GetValue("CNA_VLTOT") - ( oModelCNB:GetValue("CNB_VLTOT") *  (1-(oModelCNB:GetValue("CNB_DESC")/100)) )
					nVlrSald := oModelCNA:GetValue("CNA_SALDO") - ( oModelCNB:GetValue("CNB_VLTOT") *  (1-(oModelCNB:GetValue("CNB_DESC")/100)) )
					lMudouVlr := .T.
				EndIf
			ElseIf cCampo $ "CNB_DESC"
				If !lRecorrente
					nVlrAtu := oModelCNB:GetValue("CNB_VLTOT") *  (1-(oModelCNB:GetValue("CNB_DESC")/100))
				ElseIf oModelCNB:GetValue("CNB_ATIVO") == "1"
					nVlrAtu := oModelCNB:GetValue("CNB_VLTOT") *  (1-(oModelCNB:GetValue("CNB_DESC")/100))
				Endif
	
				If Positivo(xValue) .And. xValue < 100
					If Cn300RetSt("COMPRA")
						nVlrDes := (xValue / 100) * oModelCNB:GetValue("CNB_VLTOT")
					Else
						FtDescItem(0,oModelCNB:GetValue("CNB_VLUNIT"),oModelCNB:GetValue("CNB_QUANT"),0,@xValue,@nVlrDes,0,1)
					EndIf
				Else
					nVlrDes := oModelCNB:GetValue("CNB_VLDESC")
				EndIf
	
				If !lRecorrente
					nVlrPlan := oModelCNA:GetValue("CNA_VLTOT") + Round((oModelCNB:GetValue("CNB_VLTOT") - nVlrDes),TamSX3("CNB_VLTOT")[2]) - nVlrAtu
					nVlrSald := oModelCNA:GetValue("CNA_SALDO") + Round((oModelCNB:GetValue("CNB_VLTOT") - nVlrDes),TamSX3("CNB_VLTOT")[2]) - nVlrAtu
					lMudouVlr := .T.
				ElseIf oModelCNB:GetValue("CNB_ATIVO") == "1"
					nVlrPlan := oModelCNA:GetValue("CNA_VLTOT") + Round((oModelCNB:GetValue("CNB_VLTOT") - nVlrDes),TamSX3("CNB_VLTOT")[2]) - nVlrAtu
					nVlrSald := oModelCNA:GetValue("CNA_SALDO") + Round((oModelCNB:GetValue("CNB_VLTOT") - nVlrDes),TamSX3("CNB_VLTOT")[2]) - nVlrAtu
					lMudouVlr := .T.
				EndIf
			ElseIf cCampo == "CNB_FLREAJ"
				CN300VRCt("CNB",xValue,xOldValue)
			EndIf
		EndIf
	
		If lMudouVlr
			aProp := GetPropMdl(oModelCNA)
			CNTA300BlMd(oModelCNA,.F.)

			oModel:GetModel("CNADETAIL"):GetStruct():SetProperty('CNA_VLTOT',MODEL_FIELD_WHEN,{||.T.})
			oModelCNA:SetValue("CNA_VLTOT",nVlrPlan)
			oModelCNA:SetValue("CNA_SALDO",nVlrSald)

			RstPropMdl(oModelCNA,aProp)
			CN300BlVlr(oModel,nLine)
		EndIf
	
		If !lTipRev .AND. Empty(cAprTipRev) // não é revisão
			If  oModel:GetOperation() != MODEL_OPERATION_VIEW
				oModelCN9:LoadValue("CN9_VLINI",oModelCN9:GetValue("CN9_VLATU"))
			EndIf
		Else
			cn300BlqLn()
		EndIf
	
		If lTipRev .And. !Cn300RetSt("MEDEVE") .And. !Cn300RetSt("RECORRENTE") .And. (cTipRevisa $ DEF_REV_ADITI+'|'+DEF_REV_REALI+'|'+DEF_REV_READE+'|'+DEF_REV_REINI+'|'+DEF_REV_RENOV+'|'+DEF_REV_ABERT )
			aProp := GetPropMdl(oModelCNA)
			CNTA300BlMd(oModelCNA,.F.)
			oModelCNA:LoadValue('CNA_SADIST', CN300SdDt(oModel))
	
			If lContab
				oModelCNA:LoadValue('CNA_SADISC', CN300SdDC(oModel))
			EndIf
			RstPropMdl(oModelCNA,aProp)
		EndIf
	EndIf
Else
	lRet := .F.
	Aviso(STR0090,STR0278,{STR0222})	//-- "Item dividido, não pode ser alterado novamente."
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300RatPre
Rotina para tratamento no pre valid do grid de rateio contabil

@param nLine	Linha atual
@param cAction	Acao do usuario
@param cCampo	Campo em memoria
@param xValue	Valor em memoria

@author Flavio Lopes Rasta
@since 07/07/2013
@version P12
/*/
//-------------------------------------------------------------------
Function CN300RatPre(nLine,cAction,cCampo,xValue,xOldValue,oModelGrid)
Local lRet			:= .T.
Local oModel 		:= oModelGrid:GetModel()
Local oModelCNA 	:= oModel:GetModel("CNADETAIL")

If cAction == 'CANSETVALUE' .And. Empty(oModelCNA:GetValue("CNA_TIPPLA"))
	Help('',1,'CNTA300NOTPPLA')
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300Period
Rotina para tratamentos ao selecionar a Periodicidade no pergunte CN300CRG

@author Leandro.Moura
@since 07/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CN300Period(nRotina)
Local lRet		:= .T.
Local nPeriod := If(nRotina == 1,mv_par01,mv_par04)
Local cVarDia := If(nRotina == 1,"mv_par02","mv_par05")
Local lCNCPFis := SuperGetMV("MV_CNCPFIS",.F.,.F.)

//-- Gatilha os dias conforme periodicidade
If nPeriod == 1
	&(cVarDia) := 30
ElseIf nPeriod == 2
	&(cVarDia) := 15
Else
	&(cVarDia) := 0
EndIf

If nRotina == 1
	If nPeriod == 1
		mv_par03 := 1
	Else
		mv_par03 := 2
	EndIf
EndIf

If nPeriod # 4
	MV_PAR07 := Space(Len(MV_PAR07))
Endif

If !lCNCPFis .And. nPeriod == 4 .And. Cn300RetSt("FISICO",2)
	Help(" ",1,"CNTA300TFS")  //-- A periodicidade Condição de Pagamento não permitida para cronograma do tipo Físico, somente para o tipo Financeiro.
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VlDia
Rotina para validação da quantidade de dias de acordo com periodicidade

@author andre.oliveira
@since 26/11/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CN300VlDia(nRotina)
Local lRet		:= .T.
Local nPeriod	:= If(nRotina == 1,mv_par01,mv_par04)
Local nDias	:= If(nRotina == 1,mv_par02,mv_par05)
Local cVarDia	:= If(nRotina == 1,"mv_par02","mv_par05")

//-- Gatilha os dias conforme periodicidade
If nPeriod == 1 .And. nDias # 30
	Aviso(STR0090,STR0091,{STR0222})	//-- A periodicidade mensal admite somente 30 dias de intervalo entre as parcelas.
	&(cVarDia) := 30
ElseIf nPeriod == 2 .And. nDias # 15
	Aviso(STR0090,STR0092,{STR0222})	//-- A periodicidade quinzenal admite somente 15 dias de intervalo entre as parcelas.
	&(cVarDia) := 15
ElseIf nPeriod == 3 .And. !(NaoVazio() .And. Positivo())
	lRet := .F.
ElseIf nPeriod ==4 .And. nDias > 0
	Aviso(STR0090,STR0269,{STR0222}) //-- "A periodicidade Cond. Pagto não utiliza o campo 'Dia(s)' na elaboração do cronograma."
	&(cVarDia) := 0	
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VlCpt
Rotina para validação da competencia

@author andre.oliveira
@since 26/11/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CN300VlCpt()
Local lRet	:= .T.

If mv_par01 # 4 .And. (Vazio() .Or. Substr(mv_par04,1,2) > "12" .Or. Len(AllTrim(Substr(mv_par04,4))) < 4)
	Help(" ",1,"CNTA300CPT")	//-- Competência de início inválida
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VlCPag
Rotina para validação da condição pagamento
@author Alessnadro Honda
@since 07/05/18
@version P12117
/*/
//-------------------------------------------------------------------
Function CN300VlCPag()
Local lRet	:= .F.

If MV_PAR01 == 4
	If !EMPTY(mv_par07) .And. ExistCPO("SE4")
		lRet := .T.
	Endif
Else
 	If EMPTY(mv_par07)
		lRet := .T.
	Else
		Aviso(STR0090,STR0276,{STR0222}) //Para periodicidade diferente de condição de pagamento não é necessário preencher este campo
	Endif
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300AddCrg
Rotina para inclusao de cronograma financeiro/fisico

@author Leandro.Moura
@since 07/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CN300AddCrg(aPergunte)
Local aArea		:= GetArea()
Local aSaveLines:= FWSaveRows()
Local oView		:= FWViewActive()
Local oModel	:= FWModelActive()
Local oModelCN9	:= oModel:GetModel("CN9MASTER")
Local oModelCNA := oModel:GetModel("CNADETAIL")
Local oModelCNB := oModel:GetModel("CNBDETAIL")
Local oModelCNF := oModel:GetModel("CNFDETAIL")

Local cAutom 	:= oModelCN9:GetValue("CN9_AUTO") //- 0: Default; 1: Vindo da Automação (Robô)
Local cComp		:= ""
Local cCondPg	:= ""

Local nParcelas	:= 0
Local nPeriod	:= 0
Local nDias		:= 0
Local nCount	:= 0
Local nQuant	:= 0
Local nJuros	:= 0

Local lUltDia		:= .F.
Local lAgrupador:= .F.
Local lOk		:= .T.
Local lFisico	:= Cn300RetSt("FISICO")
Local lServico	:= Cn300RetSt("SERVIÇO")
Local dDtPrev	:= CToD("")
Local bMkCrg	:= {||}

Default aPergunte := {}

MtBCMod(oModel,{{'CNFDETAIL',{'CNF_VLPREV'}}},{||.T.},'2')
MtBCMod(oModel,{{'CNSDETAIL',{'CNS_PRVQTD'}}},{||.T.},'2')

lAgrupador := Cn300RetSt("SEMIAGRUP",0,oModelCNA:GETVALUE("CNA_NUMERO"))

If Cn300RetSt("SEMIAGRUP",0,oModelCNA:GETVALUE("CNA_NUMERO"))
	Aviso(STR0090,STR0221,{STR0222}) //- "Opção não disponivel para o contrato ou planilha selecionada."
	lOk := .F.
EndIf

If Cn300RetSt("MEDEVE",0,oModelCNA:GETVALUE("CNA_NUMERO"))
	Aviso(STR0090,STR0087,{STR0222}) //-- Esta opção não está disponível para contratos de medição eventual.
	lOk := .F.
EndIf

If Cn300RetSt("RECORRENTE",0,oModelCNA:GETVALUE("CNA_NUMERO"))
	Aviso(STR0090,STR0221,{STR0222}) //- "Opção não disponivel para o contrato ou planilha selecionada."
	lOk := .F.
EndIf

If lOk .And. ((oModelCN9:GetValue("CN9_ESPCTR") == "1" .And. Empty(oModelCNA:GetValue("CNA_FORNEC"))) .Or.;
				(oModelCN9:GetValue("CN9_ESPCTR") == "2" .And. Empty(oModelCNA:GetValue("CNA_CLIENT"))))
	Aviso(STR0090,STR0050,{STR0222})	//-- Preencha os campos do cabeçalho da planilha.
	lOk := .F.
EndIf

If lOk .And. oModelCNA:IsDeleted()
	Aviso(STR0090,STR0067,{STR0222})	//-- O cronograma não pode ser incluído pois a planilha está deletada.
	lOk := .F.
EndIf

If lOk .And. !lServico
	If Empty(oModelCNB:Length(.T.))
		Help(" ",1,"CNTA300PLA")
		lOk := .F.
	Else
		For nCount := 1 to oModelCNB:Length(.T.)
			oModelCNB:GoLine(nCount)
			If !oModelCNB:IsDeleted()
				If !Empty(oModelCNB:GetValue("CNB_PRODUT")) .AND. Empty(oModelCNB:GetValue("CNB_VLTOT"))
					Help(" ",1,"CNTA300ITEMZRD",, STR0301 + oModelCNB:GetValue("CNB_ITEM") + STR0302,1,1) //-- O valor total do item XXX não pode ser igual a zero.
					lOk := .F.
					Exit
				ElseIf Empty(oModelCNB:GetValue("CNB_PRODUT"))
					Help(" ",1,"CNTA300ITEMPROD",, STR0303 + oModelCNB:GetValue("CNB_ITEM"),1,1)  //-- Informe um produto para o item XXX
					lOk := .F.
					Exit
				EndIf
			EndIf
		Next nCount
	EndIf
EndIf

//-- Verifica se existe cronograma para a planilha
If lOk
	For nCount := 1 to oModelCNF:Length()
		oModelCNF:GoLine(nCount)

		If !oModelCNF:IsDeleted() .And. !Empty(oModelCNF:GetValue("CNF_COMPET"))
    		Aviso(STR0090,STR0068,{STR0222})	//-- Esta planilha já contém um cronograma associado.
    		lOk := .F.
	  		Exit
	  	EndIf
	Next nCount
EndIf

If lOK
	While lOk
		If !Empty(aPergunte) //Rotina Automatica
			nPeriod	  := aPergunte[1]
			nDias	  := aPergunte[2]
			lUltDia	  := aPergunte[3]
			cComp	  := aPergunte[4]
			dDtPrev	  := aPergunte[5]
			nParcelas := aPergunte[6]
			cCondPg	  := aPergunte[7]
		    lUltDiaSmp	:= aPergunte[1] == 1 .And. aPergunte[3]

			If Len(aPergunte) > 7
				nJuros := aPergunte[8]
			EndIf
		Else
			If (lOk := Iif( cAutom=="0", Pergunte("CN300CRG",.T.), Pergunte("CN300CRG",.F.) ))
				//-- Carrega as variaveis informadas no pergunte
				nPeriod		:= MV_PAR01
				nDias		:= MV_PAR02
				lUltDia		:= MV_PAR03 <> 2
				cComp		:= MV_PAR04
				dDtPrev		:= MV_PAR05
				nParcelas	:= MV_PAR06
				cCondPg		:= MV_PAR07
				lUltDiaSmp	:= MV_PAR01 == 1 .And. MV_PAR03 == 3

				If ValType(MV_PAR08) == "N"
					nJuros := MV_PAR08
				EndIf
			EndIf
		EndIf

		If lOk .And. (lOK := CN300VldPar(nPeriod,nDias,lUltDia,cComp,@dDtPrev,nParcelas,cCondPg,lFisico,lUltDiaSmp))
			Exit
		EndIf
	EndDo

	//-- Inicio do processo de inserção de cronogramas
	If lOk
	   	If lServico
			If nPeriod == 4 
				If nParcelas > 0
					nQuant := nParcelas * Len(Condicao(1,cCondPg,/*nValIpi*/,dDtPrev))
				Else
					nQuant := Len(Condicao(1,cCondPg,/*nValIpi*/,dDtPrev))
				EndIf
			Else
				nQuant := nParcelas
			EndIf
			CN300ItSrv(1,nQuant)
		EndIf
		
		bMkCrg := {||lOk := CN300MkCrg(oModel,nPeriod,nDias,lUltDia,cComp,dDtPrev,nParcelas,cCondPg,lFisico,lUltDiaSmp, lServico, nJuros)}
		          
		If !IsBlind()
			FWMsgRun(, bMkCrg, STR0084, STR0083)			
		Else
			Eval(bMkCrg)			
		EndIf

		lDelCrg := .F.

		If lServico
			MtBCMod(oModel,{{'CNFDETAIL',{'CNF_VLPREV'}}},{||.F.},'2')
			MtBCMod(oModel,{{'CNSDETAIL',{'CNS_PRVQTD'}}},{||.F.},'2')
		EndIf
	EndIf
EndIf

Pergunte("CNT100",.F.) //-- Retorna pergunte
FWRestRows(aSaveLines)

If !(FunName() $ "TECA850|TECA870|TECA745|CRMA801") .And. ValType(oView) == "O" .And. oView:IsActive() .And. cAutom == "0" //Foi necessário validação para Gestão de Serviços.	
	aEval({'VIEW_CNF','VIEW_CLC1', 'VIEW_CNS', 'VIEW_CLC2'},{|x| oView:Refresh(x) })	
EndIf

RestArea(aArea)
Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VldCrg
Rotina validacao do cronograma

@author Leandro.Moura
@since 07/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300VldCrg(oModel,oModelCNA,cSitu,lPcoInte)
Local aArea	 	:= GetArea()
Local aSaveLines:= FWSaveRows()
Local oModelCNF := oModel:GetModel("CNFDETAIL")
Local lRet		:= .T.
Local lTemCrg	:= .F.
Local lVldCrg	:= .F.
Local lVldVige	:= (SuperGetMV("MV_CNFVIGE", .F., "N") == "N")
Local lFisico   := Cn300RetSt("FISICO")
Local nTamVlTot := GetSx3Cache("CNA_VLTOT","X3_DECIMAL")
Local nTotPlanN	:= NoRound(oModelCNA:GetValue("CNA_VLTOT"),nTamVlTot)
Local nTotPlanR	:= Round(oModelCNA:GetValue("CNA_VLTOT"),nTamVlTot)
Local nTotCrg1	:= 0
Local nTotCrg2  := 0
Local nCount	:= 0
Local nTamVlPrev:= GetSx3Cache("CNF_VLPREV","X3_DECIMAL")
Local nDif		:= 0
Default lPcoInte := .F.

For nCount := 1 to oModelCNF:Length()
	oModelCNF:GoLine(nCount)

	If !oModelCNF:IsDeleted() .And. !Empty(oModelCNF:GetValue("CNF_COMPET"))
    	lTemCrg := .T.

    	If lVldVige .And. (oModelCNF:GetValue("CNF_PRUMED") < oModelCNA:GetValue("CNA_DTINI") .Or. oModelCNF:GetValue("CNF_PRUMED") > oModelCNA:GetValue("CNA_DTFIM"))
    		Help(" ",1,"CN300DTCRG",,STR0097 +oModelCNA:GetValue("CNA_NUMERO") +STR0098,1,1) //-- O cronograma financeiro/físico da planilha ### possui parcela(s) fora das datas de início e fim.
    		lRet := .F.
    	EndIf

		//-- Verifica se possui bloqueio orcamentario no SIGAPCO
		If lRet .And. lPcoInte .And. ( cSitu == "02" .Or. Empty(cSitu))	// Em Elaboracao
			lRet := A300PCOVld(oModel,"000357","01","CNTA300",.T.)	//-- Cronograma Financeiro
		    If !lRet
				Help(" ",1,"CNTA300PCO",,STR0134,5,0)
				PcoFreeBlq("000357")
			EndIf
		EndIf

		//-- Soma no total do cronograma
		If lRet
			nTotCrg1 += NoRound(oModelCNF:GetValue("CNF_VLPREV"),nTamVlPrev)
			nTotCrg2 += Round(oModelCNF:GetValue("CNF_VLPREV")  ,nTamVlPrev)
		Else

			Exit
		EndIf
    EndIf
Next nCount

//-- Valida cronograma fisico
If lRet .And. lFisico
	lRet := CN300VldFis(oModel,oModelCNF,lPcoInte)
EndIf

nTotCrg1 := NoRound(nTotCrg1,nTamVlPrev)
nTotCrg2 := Round(nTotCrg2,nTamVlPrev)

lVldCrg	:=	nTotCrg1 <> nTotPlanN .And. nTotCrg1 <> nTotPlanR .And. nTotCrg2 <> nTotPlanN .And. nTotCrg2 <> nTotPlanR

If lRet .And. lTemCrg .And. lVldCrg
	nDif := Round((nTotCrg1-nTotPlanN),nTamVlTot)

	If Abs(nDif) >= 0.01 .And. !Cn300AjuMt(oModel,nDif)
		Help(" ",1,"CNTA300MON") //-- O montante do cronograma deve ser igual ao montante das planilhas.
		lRet := .F.
	EndIf
EndIf

FWRestRows(aSaveLines)
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VldPar
Rotina validacao dos parametros informados

@author Leandro.Moura
@since 07/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300VldPar(nPeriod,nDias,lUltDia,cComp,dDtPrev,nParcelas,cCondPg,lFisico,lUltDiaSmp)
Local oModel		:= FWModelActive()

Local oModelCNA		:= oModel:GetModel("CNADETAIL")

Local lVldVige   	:= (SuperGetMV("MV_CNFVIGE", .F., "N") == "N")
Local lRet	  		:= .T.

Local dFimCrono		:= CtoD("")

Local nMaxTip9		:= SuperGetMV("MV_NUMPARC",.F.,4)
Local nTamParc 		:= TamSx3("CNF_PARCEL")[1]
Local nCount		:= 0
Local nDiaIni    	:= 0
Local nAvanco		:= 0
Local nMes			:= 0
Local nDia			:= 0

Local cTipCondCt	:= POSICIONE('SE4',1,xFilial('SE4')+oModel:GetValue('CN9MASTER','CN9_CONDPG'),'E4_TIPO')

// Ajusta data prevista para o ultimo dia do mês
If lRet .And. lUltDiaSmp
	nDia	:= day(dDtPrev)
	nMes	:= month(dDtPrev)
	dDtPrev += If(nDia<28, 28-nDia, 0)
	While nMes == month(dDtPrev)
		dDtPrev++
	End
	dDtPrev--
EndIf

//-- Valida campos nao preenchidos

If Alltrim(cComp) == "/"
	Help(" ",1,"CNTA300COMP",,STR0131,5,0) //Preencha o inicio da competencia
	lRet := .F.
EndIf

If !(nPeriod == 4)
	lVazio := Empty(nDias) .Or.	Empty(cComp) .Or. Empty(dDtPrev) .Or. Empty(nParcelas)
Else
	lVazio := Empty(cCondPg)
EndIf

If lVazio
	Help(" ",1,"CNTA300CAM") //-- Preencha todos os campos.
	lRet := .F.
EndIf

If lRet .And. dDtPrev < CToD("01/"+cComp)
	Help(" ",1,"CNTA300PRE") //-- A data de previsão deve ser maior que a competência de início.
	lRet := .F.
EndIf

//-- Validacao para condicao de pagamento
If lRet .And. (nPeriod == 4) .And. Posicione("SE4",1,xFilial("SE4")+AllTrim(cCondPg),"E4_TIPO") == "9"
	Help(" ",1,"CN300CDPG") //-- Tipo da condição de pagamento inválido.
	lRet := .F.
EndIf

//-- Valida numero de parcelas
If lRet 
	If (nTamParc == 1 .And. nParcelas > 35)
		Help(" ",1,"CNTA300NPA")	//-- O tamanho do campo CNF_PARCEL não permite a configuração da quantidade de parcelas inserida.
		lRet := .F.
	Else
		If AllTrim(cTipCondCt) == '9' .And. nParcelas > nMaxTip9
			lRet := .F.
			Help("",1,'CN300MAXPA',,STR0280+Str(nMaxTip9)+STR0281 ,4,1) //-"A condição de pagamento do contrato somente permite cronogramas com até ### parcela(s).
		EndIf
	EndIf
EndIf

//-- Valida data prevista
If lRet .And. lVldVige .And. (dDtPrev < oModelCNA:GetValue("CNA_DTINI") .Or. dDtPrev > oModelCNA:GetValue("CNA_DTFIM"))
	Help(" ",1,"CNTA300DAT") //-- Data da primeira medição inválida.
	lRet := .F.
EndIf

//-- Calcula data final do cronograma
If lRet
	nDiaIni := If(lUltDiaSmp,31,Day(dDtPrev))
	dFimCrono := dDtPrev

	For nCount := 1 to (nParcelas-1)
		If nDias == 30 .And. nPeriod # 3
			nAvanco := CalcAvanco(dFimCrono,lUltDia,.F.,nDiaIni)
		Else
			nAvanco := nDias
		EndIf
		dFimCrono += nAvanco
	Next nCount

	lRet := CNTA300ULT(dFimCrono, oModelCNA:GetValue("CNA_DTFIM"), lVldVige)//-- Verifica data final do cronograma x data final da planilha
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300DelCrg
Rotina para exclusao de cronograma

@author Leandro.Moura
@since 07/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CN300DelCrg(lConfirm)
	Local aArea			:= GetArea()
	Local cCronog		:= ""
	Local nCount		:= 0
	Local nFisico		:= 0
	Local oModel		:= FWModelActive()
	Local oModelCN9 	:= oModel:GetModel("CN9MASTER")
	Local oModelCNF 	:= oModel:GetModel("CNFDETAIL")
	Local oModelCNS 	:= oModel:GetModel("CNSDETAIL")
	Local oModelCNA		:= oModel:GetModel("CNADETAIL")
	Local aSaveLines	:= FWSaveRows()
	Local lCont 		:= .T.
	Local cAutom 		:= oModel:GetModel("CN9MASTER"):GetValue("CN9_AUTO") // -- 0 - Default; 1 - Vindo da Automação (Robô)
	Local lServico		:= Cn300RetSt('SERVIÇO')
	Local aWhenCNA		:= {}
	Default lConfirm 	:= .F.

	If !Empty(cTipRevisa)
		If Empty(oModelCN9:GetValue('CN9_TIPREV')) .AND. !FWIsInCallStack("CN300Activ")
			Help('',1,'CNTA300OPN')
			lCont := .F.
		EndIf
	EndIf

	If oModel:GetOperation() <> MODEL_OPERATION_VIEW 
		cCronog := oModelCNF:GetValue("CNF_NUMERO")
		If lCont .And. CN300PeDCr()  .And.  (!Empty(cCronog) .Or. Cn300RetSt("PREVFINANC",2))		

			If !Empty(cCronog) .And. !lConfirm .And. cAutom == '0'
				lConfirm := MsgYesNo(STR0069 +cCronog +"?")	//"Deseja excluir o cronograma " # "?"
			ElseIf !Empty(cCronog) .And. cAutom == '1'
				lConfirm := .T.
			EndIf

			If lConfirm
				aWhenCNA := GCTGetWhen(oModelCNA)
				oModelCNA:GetStruct():SetProperty("*",MODEL_FIELD_WHEN,FwBuildFeature( STRUCT_FEATURE_WHEN, ".T."))

				For nCount := 1 to oModelCNF:Length()
					oModelCNF:GoLine(nCount)

					//-- Valida o numero do cronograma
					If !oModelCNF:GetValue("CNF_NUMERO") == cCronog
						Loop
					EndIf
					//-- Deleta cronograma fisico
					For nFisico := 1 to oModelCNS:Length()
						oModelCNS:GoLine(nFisico)
						oModelCNS:SetNoDeleteLine(.F.)
						oModelCNS:DeleteLine()
						oModelCNS:SetNoDeleteLine(.T.)
					Next nFisico
					//-- Deleta a parcela do cronograma
					If !oModelCNF:IsDeleted()
						oModelCNF:SetNoDeleteLine(.F.)
						oModelCNF:DeleteLine()
						oModelCNF:SetNoDeleteLine(.T.)
					EndIf
				Next nCount

				If lServico
					CN300ItSrv(1,0)
				EndIf

				// Variavel para efetuar estorno lancamentos SIGAPCO cronograma Financeiro/Fisico na funcao A300PCOINT
				lDelCrg := .T.
				
				oModelCNA:SetValue("CNA_CRONOG","")//Limpa o numero do cronograma na planilha
				
				GCTRstWhen(oModelCNA, aWhenCNA)//Restaura WHEN da CNA
				FwFreeArray(aWhenCNA)
			EndIf		
		Else
			Help('',1,'CNTA300OPNPERM')
		Endif
	EndIf

	FWRestRows(aSaveLines)
	FwFreeArray(aSaveLines)
	RestArea(aArea)
	FwFreeArray(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300GrvCrg
Rotina para tratamentos na gravacao do Cronograma

@author Leandro.Moura
@since 07/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300GrvCrg(oModel)
	Local aCrgDel		:= {}
	Local nCount		:= 0
	Local nCountDel	:= 0
	Local nStack     	:= GetSX8Len()
	Local oModelCNA 	:= oModel:GetModel("CNADETAIL")
	Local oModelCNF 	:= oModel:GetModel("CNFDETAIL")
	Local cCronoNum		:= ""

	For nCount := 1 to oModelCNF:Length()
		oModelCNF:GoLine(nCount)

		If !oModelCNF:IsDeleted() .And. !Empty(oModelCNF:GetValue("CNF_COMPET"))
			cCronoNum := oModelCNA:GetValue("CNA_CRONOG")
			If (Empty(cCronoNum) .Or. cCronoNum <> oModelCNF:GetValue("CNF_NUMERO"))
				oModelCNA:LoadValue("CNA_CRONOG", oModelCNF:GetValue("CNF_NUMERO")) //-- Atualiza a planilha com o cronograma
				While GetSX8Len() > nStack //-- Confirma num. sequencial
					ConfirmSX8()
				End
			EndIf
		ElseIf oModelCNF:IsDeleted()
			If aScan(aCrgDel,oModelCNF:GetValue("CNF_NUMERO")) == 0
				//-- Altera cabecalho da planilha
				nCountDel++
				oModelCNA:SetValue("CNA_SALDO",oModelCNA:GetValue("CNA_VLTOT"))
				//-- Adiciona cronograma no array de controle
				aAdd(aCrgDel,oModelCNF:GetValue("CNF_NUMERO"))
			EndIf
		EndIf
	Next nCount

	If nCountDel == oModelCNF:Length()
		oModelCNA:LoadValue("CNA_CRONOG","")
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300MkCrg
Rotina para montar o cronograma financeiro da planilha

@param oModelCNA 	Modelo do cab. da planilha
@param oModelCNF	Modelo do cronograma financeiro
@param oModelCNS	Modelo do cronograma fisico
@param nPeriod		Periodicidade
@param nDias		Numero de dias
@param lUltDia		Informa se eh o ultimo dia do mes
@param cComp		Competencia
@param dDtPrev		Data prevista primeira medicao
@param nParcelas	Numero de parcelas
@param cCondPg		Condicao de pagamento
@param lFisico		Informa se controla cron. fisico

@author Leandro.Moura
@since 07/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300MkCrg(oModel,nPeriod,nDias,lUltDia,cComp,dDtPrev,nParcelas,cCondPg,lFisico,lUltDiaSmp,lServico, nJuros)
Local aArea	   	:= GetArea()
Local oModelCN9	:= oModel:GetModel("CN9MASTER")
Local oModelCNA	:= oModel:GetModel("CNADETAIL")
Local oModelCNF	:= oModel:GetModel("CNFDETAIL")
Local oModelCNS	:= oModel:GetModel("CNSDETAIL")
Local oModelCCNF:= oModel:GetModel("CALC_CNF")

Local lCNAUpd	:= oModelCNA:CanUpdateLine()
Local lUpdCNF	:= .F.
Local lAjFim	:= .F.
Local lAjFev    := .F.
Local lAjFimC	:= .F.
Local lAjFevC   := .F.

Local aItens	:= CN300GetPIt()
Local aItCrgFis	:= aClone(aItens)
Local aParcel  	:= {}
Local aCrgFis	:= {}
Local aParFis	:= {}
Local aCondComp	:= {}
Local aCondicao	:= {}
Local aRestCNS	:= {}
Local aDifCrg	:= {}

Local nMaxTip9	:= SuperGetMV("MV_NUMPARC",.F.,4)
Local nDiaIni   := If(lUltDiaSmp,31,Day(dDtPrev))
Local nVlrPlan	:= oModelCNA:GetValue("CNA_VLTOT")
Local nTamParc 	:= TamSx3("CNF_PARCEL")[1]
Local nTamPRVQTD:= TamSX3("CNS_PRVQTD")[2]
Local nDifDat	:= 0
Local nVlrParc	:= 0
Local nQtdePv	:= 0
Local nQtdPvR	:= 0
Local nNewLine	:= 0
Local nCount	:= 0
Local nFor		:= 0
Local nVlrReal	:= 0
Local nVlrSld	:= 0
Local nAvanco	:= 0
Local nX		:= 0
Local nI		:= 0
Local nPosComp	:= 0
Local nTxDia    := 0
Local nTxVenc   := 0

Local cTipCondCt:= POSICIONE('SE4',1,xFilial('SE4')+oModelCN9:GetValue('CN9_CONDPG'),'E4_TIPO')
Local cNumCrg	:= GetSX8Num("CNF","CNF_NUMERO")
Local cNumParc	:= Replicate("0",nTamParc)
Local cRefer	:= ""
Local cCompet	:= ""
Local cLog 		:= ""
Local cErrMoed	:= ""
Local cMvMoeda  := GetNewPar( "MV_CNMOEDA", "S" )

Local dVencto	:= dDtPrev
Local dCompet	:= CToD("")

//Validação das parcelas
Local lVldVige 	:= (SuperGetMV("MV_CNFVIGE", .F., "N") == "N")
Local llRet		:= .T.
Local dData		:= CtoD("")
Local dInicio	:= CtoD("")
Local dFim		:= CtoD("")

//--Tratamento para tamanho de campo Descrição
Local nB1Des	:= TamSX3("B1_DESC")[1]
Local nCnsDes	:= TamSX3("CNS_DESCRI")[1]
Local nDecCnaTot:= TAMSX3('CNA_VLTOT')[2]
Local nDecCnfPre:= TamSx3("CNF_VLPREV")[2]
Local cDescr	:= ''
Local lVlPresent:= .F.
Local lDtCompet	:= SuperGetMV("MV_CNFDTCP",.F.,.T.)
Local dData0    := CtoD("")
Local aWhenCNF	:= {}
Default nJuros	:= 0

lVlPresent := CposVlPres() .And. (nJuros > 0)

//-- Verifica se utiliza ultimo dia do mes
If lUltDia
	lAjFim := .T.
	lAjFev := .T.
	lAjFimC:= .T.
	lAjFevC:= .T.
EndIf

//-- Verifica se utiliza condicao de pagamento 
If nPeriod == 4 .And. !Empty(cCondPg)
	//-- Verifica se a qtde de parcelas foi informada
	If nParcelas > 0
		nVlCompet	:= nVlrPlan / nParcelas
		dCompet		:= IIF(!lDtCompet, CtoD(Str(Day(dDtPrev))+"/"+cComp), dDtPrev)
		dData0		:= dDtPrev
		nPosComp 	:= 3

		//-- Calcula a quantidade de parcelas
		For nCount := 1 to nParcelas
			aCondComp := Condicao(nVlCompet,cCondPg,,dData0) 
        
			For nFor := 1 to len(aCondComp)
				aAdd(aCondicao,{aCondComp[nFor,1],aCondComp[nFor,2],dCompet})
				
			Next nFor
				nAvanco	:= CalcAvanco(dCompet,.F.,.F.,nDiaIni)
				dCompet	+= nAvanco
				dData0  += nAvanco

			aCondComp 	:= {}
		Next nCount
	Else // senão a qtde de parcelas será de acordo com a condição de pagamento
		nPosComp := 1
		dCompet	 := IIF(!lDtCompet, CtoD(Str(Day(dDtPrev))+"/"+cComp), dDtPrev)
		aCondicao := Condicao(nVlrPlan,cCondPg,,dDtPrev)
		If !lDtCompet
			nPosComp := 3
			For nFor := 1 to Len(aCondicao)
				aAdd(aCondicao[nFor],dCompet)

				nAvanco	:= CalcAvanco(dCompet,.F.,.F.,nDiaIni)
				dCompet	+= nAvanco
			Next nFor
		EndIf
	EndIf
	nParcelas := Len(aCondicao)
	If nTamParc == 1 .And. nParcelas > 35
		Help(" ",1,"CNTA300NPA")	//-- O tamanho do campo CNF_PARCEL não permite a configuração da quantidade de parcelas inserida.
		llRet := .F.
	ElseIf AllTrim(cTipCondCt) == '9' .And. nParcelas > nMaxTip9
		Help("",1,'CN300MAXPA',,STR0280+Str(nMaxTip9)+STR0281 ,4,1) //-"A condição de pagamento do contrato somente permite cronogramas com até ### parcela(s).
		llRet := .F.
	EndIf
EndIf

If cMvMoeda == "N"
	nTxDia := RecMoeda(dDatabase, oModelCN9:GetValue("CN9_MOEDA") )
	
	If Empty(nTxDia)
		cErrMoed := STR0140+ Alltrim(Str(oModelCN9:GetValue("CN9_MOEDA"), TamSX3("CN9_MOEDA")[1]))+"."+chr(13)+chr(10)
		cErrMoed += STR0141+ Alltrim(Str(oModelCN9:GetValue("CN9_MOEDA"), TamSX3("CN9_MOEDA")[1]))+STR0142+chr(13)+chr(10)
		cErrMoed += DtoC(dDatabase)
		Help('',1,'CNTXMOEDA',,cErrMoed,4)
		 llRet := .F.
	EndIf
EndIf

If llRet
	//-- Cria array de parcelas
	For nCount := 1 to nParcelas
		cNumParc := Soma1(cNumParc)

		//-- Divide valor total pelas parcelas
		If !Empty(aCondicao)
			dVencto	:= aCondicao[nCount,1]
			dCompet	:= aCondicao[nCount,nPosComp]
			nVlrParc:= aCondicao[nCount,2]
		ElseIf (nCount == 1)
			nVlrParc	:= NoRound(nVlrPlan,nDecCnaTot)/nParcelas
			dCompet	:= CalcDiaCom(dDtPrev,cComp)
		Else
			//-- Calcula proxima data de vencto
			If nDias == 30 .And. nPeriod # 3
				nAvanco := CalcAvanco(dVencto,@lAjFim,@lAjFev,nDiaIni)
			Else
			    nAvanco := nDias
			EndIf
	
			dVencto += nAvanco
	
			//-- Calcula competencia
			dCompet := dVencto
		EndIf
	
		//-- Verifica referencia da parcela
		cRefer := StrZero(Month(dCompet),2)+"/"+str(Year(dCompet),4)
	
		//-- Verificação do cronograma referenciando parcelas anteriores
		If Len(aParcel) .And. Empty(aCondicao)
			//-- Se Competencia igual competência anterior
			If aParcel[Len(aParcel),2] == cRefer
				If SubStr(cRefer,0,2) == "12" .And. Day(dCompet) <= Day(aParcel[Len(aParcel),4])
					cRefer := StrZero(Val(SubStr(cRefer,0,2))-11,2)+"/"+StrZero(Val(SubStr(cRefer,4))+1,4)
				EndIf
	
			//-- Se Competencia pulou mês
			Else
				cCompet := SubStr(aParcel[Len(aParcel),2],0,2)
				cCompet := Iif(cCompet == "12","01",Soma1(cCompet))
				If cCompet != SubStr(cRefer,0,2)
					If SubStr(cRefer,0,2) == "01"
						nDifDat := 12-Val(cCompet)
						cRefer := StrZero(12-nDifDat,2) +"/"+ StrZero(Val(SubStr(cRefer,4))-1,4)
					ElseIf nDifDat > 0
						cRefer := cCompet+"/"+StrZero(Val(SubStr(cRefer,4))-1,4)
						nDifDat--
					Else
						cRefer := cCompet+"/"+SubStr(cRefer,4)
					EndIf
				EndIf
			EndIf
		EndIf
	
		//-- Calcula valor real da parcela e verifica o arrendondamento
		If !lFisico
			nVlrReal := Round(nVlrParc,nDecCnfPre)
		EndIf
	
		//-- Obtem moeda
		nTxVenc := RecMoeda(dVencto,oModelCN9:GetValue("CN9_MOEDA") )
		If Empty(nTxVenc)
			nTxVenc := IIF(Empty(nTxDia),1,nTxDia)
		Endif
	
		//-- Verifica se utiliza cronograma fisico
		//-- Adiciona parcela para todos os itens da planilha
		If lFisico
			For nFor := 1 to Len(aItCrgFis)
				If nFor > Len(aDifCrg)
					aAdd(aDifCrg,0)
				EndIf
				//³Verifica a quantidade prevista e desconto do item ³
				nQtdePv := If(nCount < nParcelas,NoRound(aItens[nFor,3]/nParcelas,nTamPRVQTD),aItCrgFis[nFor,3])
				nQtdPvR	:= aItens[nFor,3]/nParcelas
				nDescon := NoRound(aItens[nFor,8]/nParcelas,nTamPRVQTD)
	
				//-- Atualiza valor da parcela de acordo com o cronograma fisico
				//-- (Valor unitario * qtde.) - desconto
				nVlrReal += Round((aItCrgFis[nFor,7] * nQtdePv) - nDescon,nDecCnfPre)

				//-- Atualiza a quantidade no array de itens
				aDifCrg[nFor] += nQtdPvR - nQtdePv
				If aDifCrg[nFor] > 1/10^nTamPRVQTD
					nQtdePv += NoRound(aDifCrg[nFor],nTamPRVQTD)
					aDifCrg[nFor] -= NoRound(aDifCrg[nFor],nTamPRVQTD)
				EndIf
				aItCrgFis[nFor,3] -= nQtdePv
	
				//-- Adiciona item no array de cronograma fisico
				aAdd(aParFis,{nQtdePv,aItens[nFor,3],aItens[nFor,2],aItens[nFor,1]})
			Next nFor
		EndIf
		
		//-- Adiciona informacoes no array de parcelas		
		aAdd(aParcel,{cNumParc,cRefer,nVlrReal,dVencto,nTxVenc})
	
		//-- Tratamento no resto do valor da parcela
		nVlrSld 	+= nVlrParc - nVlrReal
		nVlrReal	:= 0
	
		//-- Adiciona informacoes no array de parcelas
		If lFisico .And. !Empty(aParFis)
			aAdd(aCrgFis,aClone(aParFis))
			aParFis := {}
		EndIf
	Next nCount
EndIf

If llRet
	//-- Adiciona o saldo do arredondamento
	If !lFisico .And. nVlrSld # 0
		aParcel[Len(aParcel),3] += Round(nVlrSld,nDecCnfPre)
	ElseIf lFisico
		//-- Ajusta parcelas do cronograma fisico
		CN300AjFis(@aParcel,@aCrgFis,aItCrgFis,nVlrPlan,nParcelas)
	EndIf

	If lServico
		oModelCNF:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.T.})
		oModelCNF:SetNoUpdateLine(.F.)
	EndIf

	//-- Rotina para guardar o Recno dos registros deletados e deleta-los nos Commit do modelo, pois o Delete Físico não deleta os
	//-- registros do banco.
	oModelCNF:GoLine(1)
	If oModelCNF:Length() > 0 .And. !Empty(oModelCNF:GetValue("CNF_PARCEL"))
		For nI := 1 To oModelCNF:Length()
			oModelCNF:GoLine(nI)
			If oModelCNF:IsDeleted()
				If oModelCNF:GetDataId() <> 0 .And. Ascan(aDelsCNF, oModelCNF:GetDataId()) == 0
					Aadd(aDelsCNF, oModelCNF:GetDataId())
				EndIf
			EndIf
			If lFisico			
				For nX := 1 To oModelCNS:Length()
					oModelCNS:GoLine(nX)
					If oModelCNS:IsDeleted()
						If oModelCNS:GetDataId() <> 0 .And. Ascan(aDelsCNS, oModelCNS:GetDataId()) == 0
							Aadd(aDelsCNS, oModelCNS:GetDataId())
						EndIf
					EndIf
				Next nX
			EndIf
		Next nI

		If (Empty(aDelsCNF) .And. oModelCNF:CanClearData())
			oModelCNF:ClearData(.T., .T.)
		EndIf
	EndIf

	//Validaçao das parcelas
	For nCount := 1 to len(aParcel)
		dInicio	:= oModelCN9:GetValue('CN9_DTINIC')
		dData	:= aParcel[nCount,4]
		dFim	:= oModelCN9:GetValue('CN9_DTFIM')

		If (dData < dInicio) .And. lVldVige
			Aviso(STR0090, STR0132,{STR0222}) //"Atenção"##"O vencimento está menor do que a data inicial do contrato."
			llRet := .F.
			Exit
		EndIf

		If llRet .And. (dData > dFim) .And. lVldVige
			Aviso(STR0090, STR0133,{STR0222}) //"Atenção"##"O vencimento está maior do que a data final do contrato."
			llRet := .F.
			Exit
		EndIf
	Next
EndIf

If llRet	
	
	lUpdCNF := oModelCNF:CanUpdateLine()
	If !lUpdCNF
		oModelCNF:SetNoUpdateLine(.F.)//Libera CNF para carregar os valores
	EndIf
	oModelCNF:SetNoInsertLine(.F.)
	aWhenCNF := GCTGetWhen(oModelCNF)
	oModelCNF:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.T.})

	If lFisico
		aRestCNS := GetPropMdl(oModelCNS)
		Cnta300BlMd(oModelCNS,.F.)
		oModelCNS:SetNoInsertLine(.F.)
	EndIf

	For nCount := 1 to Len(aParcel)
		//-- Caso a linha nao esteja em branco, adiciona uma linha
		If !Empty(oModelCNF:GetValue("CNF_PARCEL"))			
			nNewLine := oModelCNF:AddLine()
			If nNewLine > 0 .And. oModelCNF:GetLine() != nNewLine
				oModelCNF:GoLine( nNewLine )				
			EndIf			
		EndIf		

		oModelCNF:LoadValue("CNF_NUMERO",cNumCrg)
		oModelCNF:LoadValue("CNF_PARCEL",aParcel[nCount,1])
		oModelCNF:LoadValue("CNF_COMPET",aParcel[nCount,2])
		oModelCNF:SetValue("CNF_VLPREV",aParcel[nCount,3])
		oModelCNF:SetValue("CNF_VLREAL",0)
		oModelCNF:SetValue("CNF_SALDO",aParcel[nCount,3])
		oModelCNF:SetValue("CNF_DTVENC",aParcel[nCount,4])
		oModelCNF:SetValue("CNF_PRUMED",aParcel[nCount,4])
		oModelCNF:SetValue("CNF_TXMOED",aParcel[nCount,5])
		oModelCNF:SetValue("CNF_MAXPAR",nParcelas)
		If !( nPeriod == 4 )
			oModelCNF:SetValue("CNF_PERIOD",CValToChar(nPeriod))
			oModelCNF:SetValue("CNF_DIAPAR",nDias)
		Else
			oModelCNF:SetValue("CNF_CONDPG",cCondPg)
		EndIf

		If lVlPresent
			oModelCNF:SetValue("CNF_TJUROS", nJuros)//Ao preencher CNF_TJUROS, CNF_VLPRES e CNF_VJUROS são preenchidos via trigger
		EndIf
		
		If oModelCNF:GetLine() # nCount//-- Tratamento para remover da grid as linha deletadas
			nFor := oModelCNF:GetLine()
			
			oModelCNF:GoLine(nCount)
			oModelCNF:UnDeleteLine()//Necessario p/ que seja feito o calculo do CNF_CALC corretamente

			oModelCNF:LineShift(nCount,nFor)//Joga os dados da nova linha na linha que ja existia
			oModelCNF:GoLine(nFor)
			oModelCNF:DeleteLine(.T.,.T.)//Deleta a nova linha que havia sido incluida

			oModelCNF:GoLine(nCount)//Vai pra linha que ja existia, porém com os novos dados
		EndIf

		If !Empty(oModel:GetErrorMessage()[6])
			llRet := .F.
		    cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
		    cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
		    cLog += cValToChar(oModel:GetErrorMessage()[6])
		    Help( ,,"ERRO",,cLog, 1, 0 )
		EndIf

		//-- Inclui as parcelas do cronograma fisico
		If lFisico .And. !Empty(aCrgFis)
			oModel:GetModel("CALC_CNS"):LoadValue("TCNS_PARC",aParcel[nCount,1])			

			For nFor := 1 to Len(aCrgFis[nCount])
				//-- Caso a linha nao esteja em branco, adiciona uma linha
				If !Empty(oModelCNS:GetValue("CNS_ITEM"))					
					nNewLine := oModelCNS:AddLine()
					oModelCNS:GoLine( nNewLine )					
				EndIf

				//-- Tratamento para tamanho de campo descricao divergente
				cDescr := IIF (nB1Des > nCnsDes,Substr(Posicione("SB1",1,xFilial("SB1")+aCrgFis[nCount,nFor,3],"B1_DESC"),1,25),;
					            Posicione("SB1",1,xFilial("SB1")+aCrgFis[nCount,nFor,3],"B1_DESC"))
				
				oModelCNS:SetValue("CNS_PARCEL",aParcel[nCount,1])
				oModelCNS:LoadValue("CNS_ITEM",aCrgFis[nCount,nFor,4])
				oModelCNS:SetValue("CNS_PRODUT",aCrgFis[nCount,nFor,3])
				oModelCNS:SetValue("CNS_DESCRI",cDescr)
				oModelCNS:SetValue("CNS_DISTSL",aCrgFis[nCount,nFor,1])
				oModelCNS:SetValue("CNS_PRVQTD",aCrgFis[nCount,nFor,1])
				oModelCNS:SetValue("CNS_RLZQTD",0)
				oModelCNS:LoadValue("CNS_SLDQTD",aCrgFis[nCount,nFor,1])
				oModelCNS:SetValue("CNS_TOTQTD",aCrgFis[nCount,nFor,2])
				oModelCNS:SetValue("CNS_ITOR","")
				
			Next nFor		
			
			oModel:GetModel("CALC_CNS"):LoadValue("TCNS_VTOT",oModelCNF:GetValue('CNF_VLPREV'))
		EndIf
	Next nCount

	If lVlPresent .And. CNF->(ColumnPos("CNF_AMRTZA") > 0)
		CN300Amort(oModel)//Calcula amortização linear
	EndIf

	oModelCNF:SetNoUpdateLine(!lUpdCNF)//Devolve a CNF ao estado anterior
	oModelCNF:SetNoInsertLine(.T.)

	GCTRstWhen(oModelCNF, aWhenCNF)//Restauran WHEN da CNF
	FwFreeArray(aWhenCNF)

	oModelCNF:GetStruct():SetProperty('*'			,MVC_VIEW_CANCHANGE,.F.)
	oModelCNF:GetStruct():SetProperty('CNF_COMPET'	,MVC_VIEW_CANCHANGE,.T.)
	oModelCNF:GetStruct():SetProperty('CNF_DTVENC'	,MVC_VIEW_CANCHANGE,.T.)
	oModelCNF:GetStruct():SetProperty('CNF_PRUMED'	,MVC_VIEW_CANCHANGE,.T.)
	oModelCNF:GetStruct():SetProperty('CNF_TXMOED'	,MVC_VIEW_CANCHANGE,.T.)

	If lFisico		
		RstPropMdl(oModelCNS,aRestCNS)
		FwFreeArray(aRestCNS)
		oModelCNS:SetNoInsertLine(.T.)
	EndIf
EndIf

//-- Tratamento para remover linhas deletadas da tela
If llRet
	oModelCNF:SetNoDeleteLine(.F.)
	While oModelCNF:IsDeleted(oModelCNF:Length())
		oModelCNF:GoLine(oModelCNF:Length())
		oModelCCNF:LoadValue('CNF_CALC',oModelCNF:GetValue('CNF_VLPREV'))
		oModelCNF:DeleteLine(.T.,.T.)
	End
	oModelCNF:SetNoDeleteLine(.T.)

	//-- Atualiza a planilha com o cronograma
	oModelCNA:SetNoUpdateLine(.F.)
	oModelCNA:SetValue("CNA_CRONOG"	,oModelCNF:GetValue("CNF_NUMERO"))
	oModelCNA:SetNoUpdateLine(!lCNAUpd)
EndIf
RestArea(aArea)
FwFreeArray(aArea)
FwFreeArray(aParFis)
FwFreeArray(aCrgFis)
FwFreeArray(aItens)
FwFreeArray(aItCrgFis)
Return llRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300AjFis
Rotina para ajustar as parcelas do cronograma fisico

@param aParcel		Parcelas do cronograma financeiro
@param aCrgFis		Parcelas do cronograma fisico
@param aItCrgFis	Array com os itens utilizados no cronograma
@param nVlrPlan		Valor total da planilha

@author Leandro.Moura
@since 07/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300AjFis(aParcel,aCrgFis,aItCrgFis,nVlrPlan,nParcelas)
	Local aArea	   	:= GetArea()
	Local aItens		:= CN300GetPIt()
	Local nQtdePv		:= 0
	Local nTamPRVQTD	:= TamSX3("CNS_PRVQTD")[2]
	Local nTamVlPrev 	:= TamSx3("CNF_VLPREV")[2]
	Local nCount		:= 0
	Local nFor			:= 0
	Local nVlrParc	:= 0
	Local nVlrTot		:= 0

	//-- Verifica as quantidades restantes dos itens do cronograma fisico
	For nCount := 1 to Len(aItCrgFis)
		If aItCrgFis[nCount,3] != 0
			//-- Converte o resto em um numero inteiro
			nQtdRest := Round((aItCrgFis[nCount,3] * (10**nTamPRVQTD)), 2)

			//-- Tratamento caso o resto seja maior que o numero de parcelas
			While nQtdRest > 0
				//-- Realiza o rateio da quantidade restante a partir da ultima parcela
				For nFor := nParcelas To 1 Step -1
					If nQtdRest <= 0
						Exit
					EndIf
					aCrgFis[nFor,nCount,1] += (10** (-nTamPRVQTD) * IIf(aItCrgFis[nCount,3]<0,-1,1))
					nQtdRest -= 1
				Next nFor
			End
		EndIf
	Next nCount

	//-- Recalcula valor das parcelas
	For nCount := 1 to nParcelas
		//-- Total de todos os itens do cronograma fisico
		For nFor := 1 to Len(aCrgFis[nCount])
			nQtdePv := aCrgFis[nCount,nFor,1]
			nDescon := aItens[nFor,8] / nParcelas
			nVlrParc += (aItens[nFor,7]*nQtdePv) - nDescon
		Next nFor

		//-- Atualiza o valor da parcela
		aParcel[nCount,3] := Round(nVlrParc,nTamVlPrev)

		//-- Armazena soma do total das parcelas
		nVlrParc	:= 0
		nVlrTot 	+= aParcel[nCount,3]
	Next nCount

	//-- Ajusta o valor financeiro na ultima parcela
	If nVlrPlan # nVlrTot
		aParcel[Len(aParcel),3] += (nVlrPlan - nVlrTot)
	EndIf

	RestArea(aArea)
	FwFreeArray(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300TpCtr
Rotina para bloquear partes do modelo conforme tipo do contrato

@author Leandro.Moura
@since 15/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CN300TpCtr( oModel, lTpPlaCall as Logical )
Local aSaveLines	:= {}
Local lRet			:= .T.
Local lVldCpo 		:= .F.
Local lHelpFis		:= .F.
Local lFusao   	    := .F.
Local lAlcDocCtr	:= .F.
Local nI            := 0
Local nX			:= 0
Local nY			:= 0
Local oModelCN9		:= NIL
Local oModelCNA		:= NIL
Local oModelCNB		:= NIL
Local oModelCNC		:= NIL
Local oModelCNF		:= NIL
Local oModelCNS		:= NIL
Local oModelCNV		:= NIL
Local oModelCNW		:= NIL
Local oModelCNZ		:= NIL
Local nCNATot 		:= 0
Local nCNASaldo		:= 0
Local nOperation 	:= 0
Local lFixo			:= .F.
Local lSCAdt		:= .F.
Local lOnActive		:= FWIsInCallStack('CN300activ')
Local lVldTpFixo	:= SuperGetMV("MV_VLDTPFI",.T.,.T.)
Default lTpPlaCall	:= .F.

//-- Caso chamada pelo valid do campo, inicializa variaveis
If Empty(oModel)
	lVldCpo := .T.
	oModel := FWModelActive()
EndIf

aSaveLines	:= FWSaveRows( oModel )
oModelCN9	:= oModel:GetModel("CN9MASTER")
oModelCNA	:= oModel:GetModel("CNADETAIL")
oModelCNB	:= oModel:GetModel("CNBDETAIL")
oModelCNC	:= oModel:GetModel("CNCDETAIL")
oModelCNF	:= oModel:GetModel("CNFDETAIL")
oModelCNS	:= oModel:GetModel("CNSDETAIL")
oModelCNV	:= oModel:GetModel("CNVDETAIL")
oModelCNW	:= oModel:GetModel("CNWDETAIL")
oModelCNZ	:= oModel:GetModel("CNZDETAIL")
lFixo		:= Cn300RetSt("FIXO")
lSCAdt		:= CN9->(FieldPos("CN9_XSCORI")) > 0

CN1->(dbSetOrder(1))
If !CN1->(dbSeek(xFilial("CN1")+If(lVldCpo,oModelCN9:GetValue("CN9_TPCTO"),CN9->CN9_TPCTO)))
	Help(" ",1,"REGNOIS")
	lRet := .F.
ElseIf (Empty(cTipRevisa) .And. Empty(cAprTipRev))
	lRet := RegistroOk("CN1")
	If lRet .And. CN1->CN1_CTRFIX !="1" .And. lVldTpFixo .And.!Empty(oModelCN9:GetValue("CN9_NUMCOT"))
		Help(" ",1,"CN300TpCtr",,STR0094,5,0,,,,,,{STR0316}) //-- Para contratos gerados por edital ou por cotação o contrato deve ser obrigatoriamente do tipo fixo. Informe um tipo de contrato valido.
		lRet := .F.
	EndIf
EndIf
	
If lRet .And. Cn300RetSt("ESPECIE") # oModelCN9:GetValue("CN9_ESPCTR")
	Aviso(STR0090,STR0095,{STR0222}) //-- A espécie do tipo de contrato informado é diferente da espécie do contrato que está sendo editado.
	lRet := .F.
EndIf

If lRet .And. !Empty(oModelCN9:GetValue("CN9_CODED")) .And. !lFixo
	Help(" ",1,"CN300TpCtr",,STR0094,5,0,,,,,,{STR0316}) //-- Para contratos gerados por edital ou por cotação o contrato deve ser obrigatoriamente do tipo fixo. Informe um tipo de contrato valido.
	lRet := .F.
EndIf

//-- Posiciona no edital para ver se esta definido o campo de fusão
CO1->(dbSetOrder(1))
If CO1->(dbSeek(xFilial("CO1")+oModelCN9:GetValue('CN9_CODED')+oModelCN9:GetValue('CN9_NUMPR')))
	If CO1->CO1_FUSAO = "1"
		lFusao   := .T.
	EndIf
EndIf

//-- Realiza tratamentos para troca do tipo de contrato
If lRet
	nOperation := oModel:GetOperation()

	//Preenche com o grupo de aprovação
	If !lOnActive
		lAlcDocCtr := ( CN1->CN1_ALCCTR $ "0|1" )
		
		If (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE ) .AND. Empty(cTipRevisa)
			oModelCN9:SetValue("CN9_GRPAPR"	,CN1->CN1_GRPAPR)
			If lAlcDocCtr
				oModelCN9:SetValue("CN9_APROV"	,CN1->CN1_GRPSIT)			
			EndIf	
		EndIf
	EndIf
	
	//-- Se contrato de edital, bloqueia alteracao de clientes/fornecedores
	If !Empty(oModelCN9:GetValue("CN9_CODED")) .And. !lFusao
		CNTA300BlMd(oModelCNC,.T.)
	EndIf

	If !lOnActive .And. (!Cn300RetSt("MEDEVE",2) .Or. Cn300RetSt("SEMIFIXO",2))
		For nY := 1 to oModelCNA:Length()
			oModelCNA:GoLine(nY)
			If !Empty(oModelCNA:GetValue("CNA_TIPPLA"))				
				lFixo := Cn300RetSt("FIXO")
				//-- Se contrato de medicao eventual, bloqueia cronogramas
				If Cn300RetSt("MEDEVE")
					CNTA300BlMd(oModelCNF,.T.)
					CNTA300BlMd(oModelCNS,.T.)
					For nI := 1 To oModelCNF:Length()
						oModelCNF:GoLine(nI)
						If !oModelCNF:IsDeleted()
							If oModelCNF:GetDataId() <> 0 .And. Ascan(aDelsCNF, oModelCNF:GetDataId()) == 0
								Aadd(aDelsCNF, oModelCNF:GetDataId())
							EndIf
						EndIf
						For nX := 1 To oModelCNS:Length()
							oModelCNS:GoLine(nX)
							If !oModelCNS:IsDeleted()
								If oModelCNS:GetDataId() <> 0 .And. Ascan(aDelsCNS, oModelCNS:GetDataId()) == 0
									Aadd(aDelsCNS, oModelCNS:GetDataId())
								EndIf
							EndIf
						Next nX
					Next nI
					//-- Deleta cronogramas que possam ter sido adicionados
					oModelCNF:SetNoDeleteLine(.F.)
					oModelCNS:SetNoDeleteLine(.F.)
					CNTA300DlMd(oModelCNF,'CNF_PARCEL')
					CNTA300DlMd(oModelCNS,'CNS_ITEM')
					oModelCNF:SetNoDeleteLine(.T.)
					oModelCNS:SetNoDeleteLine(.T.)

				//-- Se contrato de medicao nao eventual e com crg fisico, bloqueia financeiro e libera fisico
				ElseIf Cn300RetSt("FISICO")
					CNTA300BlMd(oModelCNF,.T.,.T.)
					CNTA300BlMd(oModelCNS,.T.,.T.)

					//-- Tratamento para permitir alterar as datas de vencimento e datas prevista em contratos em elaboração
					If nOperation == MODEL_OPERATION_UPDATE .and. AllTrim(CN9->CN9_SITUAC) == DEF_SELAB
						CNTA300BlMd(oModelCNF,.F.)
						oModelCNF:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.F.})
						oModelCNF:GetStruct():SetProperty('CNF_DTVENC',MODEL_FIELD_WHEN,{||.T.})
						oModelCNF:GetStruct():SetProperty('CNF_PRUMED',MODEL_FIELD_WHEN,{||.T.})
						oModelCNF:GetStruct():SetProperty('CNF_COMPET',MODEL_FIELD_WHEN,{||.T.})
						oModelCNF:GetStruct():SetProperty('CNF_TXMOED',MODEL_FIELD_WHEN,{||.T.})
					EndIf

					//-- Tratamento para adicionar cronograma fisico quando alterado o tipo de contrato e ja possui itens.
					If !oModelCNA:IsDeleted() .And. oModelCNA:GetValue("CNA_VLTOT") > 0
						If !oModelCNF:IsDeleted() .And. !Empty(oModelCNF:GetValue("CNF_PARCEL")) .And.;	//-- Se possui cronograma fisico
							(oModelCNS:IsDeleted() .Or. Empty(oModelCNS:GetValue("CNS_ITEM")))			//-- e não financeiro

							//-- Deleta cronograma da planilha
							CN300DelCrg(.T.)
							lHelpFis := .T.
						EndIf
					EndIf

				//-- Se contrato de medicao nao eventual e sem crg fisico, libera financeiro e bloqueia fisico
				Else
					CNTA300BlMd(oModelCNF,.T.,.T.)
					CNTA300BlMd(oModelCNS,.T.)
					//-- Deleta cronogramas fisicos que possam ter sido adicionados
					oModelCNS:SetNoDeleteLine(.F.)
					For nX := 1 To oModelCNF:Length()
						oModelCNF:GoLine(nX)
						CNTA300DlMd(oModelCNS,'CNS_ITEM')
					Next nX
					oModelCNS:SetNoDeleteLine(.T.)
				EndIf				
				
				If Cn300RetSt("SEMIFIXO")
					CN300BlqAgr(oModel)
					
					If Cn300RetSt("SEMIPROD")
						For nX := 1 To oModelCNB:Length()
							oModelCNB:GoLine(nX)
							If !oModelCNB:IsDeleted() .And. oModelCNB:GetValue("CNB_QTDORI") > 0
								oModelCNB:LoadValue("CNB_QTDORI", 0)//Semi-fixo por produto, deve ter QTDORI zerado.
							EndIf
						Next nX
					EndIf

				ElseIf !lFixo .Or. !Empty(oModelCN9:GetValue("CN9_CODED"))//-- Se contrato nao fixo ou de edital, bloqueia planilha e itens
					//-- Se contrato nao fixo
					If !lFixo
						CNTA300BlMd(oModelCNA,.F.)
						CNTA300BlMd(oModelCNB,.F.)
						//-- Deleta planilhas que possam ter sido adicionadas
						CNTA300DlMd(oModelCNB,'CNB_PRODUT')
					EndIf
					CNTA300BlMd(oModelCNB,.T.)
				//-- Se contrato fixo, atualiza valor inicial do contrato
				ElseIf lFixo
					//Atualiza o valor da Planilha
					If (oModelCN9:GetValue("CN9_SALDO") == oModelCN9:GetValue("CN9_VLATU") .Or. IIf(FWIsInCallStack("CN300Aprov"),.F.,Empty(cTipRevisa))) // JHSF
						CNTA300BlMd(oModelCNA,,.T.)
						CNTA300BlMd(oModelCNB,,.T.)
						CN300VlPla(.T.,Cn300RetSt("PREVFINANC"))
					EndIf
					CNTA300BlMd(oModelCNA,.F.)
					CNTA300BlMd(oModelCNB,.F.)
				EndIf

				//-- Se contrato com crg contabil, libera edicao de linhas nos modelos
				If Cn300RetSt("CONTABIL")
					CNTA300BlMd(oModelCNV,.T.,.T.)
					CNTA300BlMd(oModelCNW,.T.,.T.)
				//-- Se nao, bloqueia modelos
				Else
					CNTA300BlMd(oModelCNV,.T.)
					CNTA300BlMd(oModelCNW,.T.)
		
					For nI := 1 To oModelCNV:Length()
						oModelCNV:GoLine(nI)
						If !oModelCNV:IsDeleted()
							If oModelCNV:GetDataId() <> 0 .And. Ascan(aDelsCNV, oModelCNV:GetDataId()) == 0
								Aadd(aDelsCNV, oModelCNV:GetDataId())
							EndIf
						EndIf
						For nX := 1 To oModelCNW:Length()
							oModelCNW:GoLine(nX)
							If !oModelCNW:IsDeleted()
								If oModelCNW:GetDataId() <> 0 .And. Ascan(aDelsCNW, oModelCNW:GetDataId()) == 0
									Aadd(aDelsCNW, oModelCNW:GetDataId())
								EndIf
							EndIf
						Next nX
					Next nI
		
					//-- Deleta cronogramas que possam ter sido adicionados
					oModelCNV:SetNoDeleteLine(.F.)
					oModelCNW:SetNoDeleteLine(.F.)
					CNTA300DlMd(oModelCNV,'CNV_NUMERO')
					CNTA300DlMd(oModelCNW,'CNW_PARCEL')
					oModelCNV:SetNoDeleteLine(.T.)
					oModelCNW:SetNoDeleteLine(.T.)
				EndIf
							
				If !oModelCNA:IsDeleted()
					nCNATot += oModelCNA:GetValue( "CNA_VLTOT" )
					nCNASaldo += oModelCNA:GetValue( "CNA_SALDO" ) 
				EndIf				        			
			EndIf
		Next nY
		
		oModelCN9:LoadValue( "CN9_VLATU", nCNATot )
		oModelCN9:LoadValue( "CN9_SALDO", nCNASaldo )
		
		If Empty(cTipRevisa) .AND. Empty(cAprTipRev) .And. nOperation != MODEL_OPERATION_VIEW
			If Alltrim(CN9->CN9_SITUAC) <> '05'
				oModelCN9:LoadValue( "CN9_VLINI", nCNATot )
			EndIf
		EndIf
			
	Else
		CN300TpPla( .F., oModel )
		lTpPlaCall := .T.
	Endif

	If lHelpFis
		Aviso(STR0090,STR0096,{STR0222})
	EndIf

	//-- Se contrato de Cotação, bloqueia alterações de fornecedores, planilhas, rateio.
	If !Empty(oModelCN9:GetValue("CN9_NUMCOT")) .Or. IIF(lSCAdt,!Empty(oModelCN9:GetValue("CN9_XSCORI")),.F.)
		SC1->(DbSetOrder(1))
		SC1->(DbSeek(xFilial('SC1')+oModelCNB:GetValue('CNB_NUMSC')+oModelCNB:GetValue('CNB_ITEMSC')))
		If !Empty(SC1->C1_COTACAO) .Or. IIF(SC1->(FieldPos("C1_XCTADT")) > 0,!Empty(SC1->C1_XCTADT),.F.)
			CN300BlqCot(oModel)
		EndIf
	Endif
	//-- Se contrato de edital, bloqueia alteracao de clientes/fornecedores
	If !Empty(oModelCN9:GetValue("CN9_CODED")) .And. !lFusao
 		CNTA300BlMd(oModelCNC,.T.)
		CNTA300BlMd(oModelCNA,.T., .T.)
		CNTA300BlMd(oModelCNB,.T., .T.)
	EndIf
EndIf

If Empty(cAprTipRev)//Nao chama na aprovacao da revisao
	oModelCNA:GoLine(1)
	CN300BlVlr(oModel, 1) //Chama apenas pra primeira linha, demais serao chamados no pre-valid da CNA
EndIf

FWRestRows(aSaveLines)
Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CN300TpPla
Rotina para bloquear partes do modelo conforme tipo de planilha
@author Rogerio Melonio
@since 28/05/2015
/*/
//-------------------------------------------------------------------
Function CN300TpPla( lTrigger, oModel )
Local aSaveLines	:= {}
Local oModelCN9		:= Nil
Local oModelCNA		:= Nil
Local oModelCNB		:= Nil
Local oModelCNC		:= Nil
Local oModelCNF		:= Nil
Local oModelCNS		:= Nil
Local oModelCNV		:= Nil
Local oModelCNW		:= Nil
Local oModelCNZ		:= Nil
Local oModelCXM		:= Nil
Local oStruCNB		:= Nil
Local cTipoPla		:= ""
Local cTipoCtr		:= ""
Local lCotacao		:= .F.
Local lSCAdt		:= .F.
Local lRet 			:= .T.
Local lEventual		:= .F.
Local lFisico		:= .F.
Local lContabil		:= .F.
Local lSemiFixo 	:= .F.
Local lFixo  		:= .F.
Local lValor 		:= .F.
Local lRecorrente	:= .F.
Local lServico		:= .F.
Local lHelpFis		:= .F.
Local lAlteraVig    := .F.
Local lEdital		:= .F.
Local lPosSC		:= CN9->(FieldPos("CN9_XSCORI")) > 0
Default lTrigger := .F.
Default oModel   := FWModelActive()

aSaveLines := FWSaveRows( oModel )
oModelCN9 := oModel:GetModel("CN9MASTER")
oModelCNA := oModel:GetModel("CNADETAIL")
oModelCNB := oModel:GetModel("CNBDETAIL")
oModelCNC := oModel:GetModel("CNCDETAIL")
oModelCNF := oModel:GetModel("CNFDETAIL")
oModelCNS := oModel:GetModel("CNSDETAIL")
oModelCNV := oModel:GetModel("CNVDETAIL")
oModelCNW := oModel:GetModel("CNWDETAIL")
oModelCNZ := oModel:GetModel("CNZDETAIL")
oModelCXM := oModel:GetModel("CXMDETAIL")

cTipoPla := oModelCNA:GetValue("CNA_TIPPLA")
cTipoCtr := oModelCN9:GetValue("CN9_TPCTO")
lCotacao := !Empty( oModelCN9:GetValue("CN9_NUMCOT") )
lSCAdt	 := IIF(lPosSC,!Empty(oModelCN9:GetValue("CN9_XSCORI")),.F.)
lEdital		:= !Empty(oModelCN9:GetValue("CN9_CODED"))

If Empty(cTipoPla)
	lRet := .F.
Endif

If lTrigger .And. Empty( cTipoCtr )
	lRet := .F.
EndIf

If lRet
	lFisico			:= Cn300RetSt("FISICO")
	lContabil		:= Cn300RetSt("CONTABIL")
	lEventual		:= Cn300RetSt("MEDEVE")
	lFixo			:= Cn300RetSt("FIXO")
	lValor			:= Cn300RetSt("PREVFINANC")
	lSemiFixo		:= Cn300RetSt("SEMIFIXO")
	lRecorrente 	:= Cn300RetSt("RECORRENTE")
	lServico		:= Cn300RetSt("SERVIÇO")

	//-- Realiza tratamentos para bloqueios de grids
	//-- Se contrato de medicao eventual, bloqueia cronogramas
	If lEventual // Cn300RetSt("MEDEVE")
		CNTA300BlMd(oModelCNF,.T.)
		CNTA300BlMd(oModelCNS,.T.)
		//-- Deleta cronogramas que possam ter sido adicionados
		oModelCNF:SetNoDeleteLine(.F.)
		oModelCNS:SetNoDeleteLine(.F.)
		CNTA300DlMd(oModelCNF,'CNF_PARCEL')
		CNTA300DlMd(oModelCNS,'CNS_ITEM')
		oModelCNF:SetNoDeleteLine(.T.)
		oModelCNS:SetNoDeleteLine(.T.)
		//Limpa campo que possui o número do cronograma quando o Tp Contrato ou Tp plnilha for alterado. 
		If FWIsInCallStack('CN300Grv') .And. !oModelCNA:IsDeleted() .And. oModelCNA:GetValue('CNA_CRONOG') <> ''
			oModelCNA:LoadValue('CNA_CRONOG','')
		EndIf		
	
	//-- Se contrato de medicao nao eventual e com crg fisico, bloqueia financeiro e libera fisico
	ElseIf lFisico // Cn300RetSt("FISICO")
		CNTA300BlMd(oModelCNF,.T.,.T.)
		CNTA300BlMd(oModelCNS,.T.,.T.)

		//-- Tratamento para permitir alterar as datas de vencimento e datas prevista em contratos em elaboração
		If oModel:GetOperation() == MODEL_OPERATION_UPDATE .and. AllTrim(CN9->CN9_SITUAC) == DEF_SELAB
			CNTA300BlMd(oModelCNF,.F.)
			oModelCNF:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.F.})
			oModelCNF:GetStruct():SetProperty('CNF_DTVENC',MODEL_FIELD_WHEN,{||.T.})
			oModelCNF:GetStruct():SetProperty('CNF_PRUMED',MODEL_FIELD_WHEN,{||.T.})
			oModelCNF:GetStruct():SetProperty('CNF_COMPET',MODEL_FIELD_WHEN,{||.T.})
			oModelCNF:GetStruct():SetProperty('CNF_TXMOED',MODEL_FIELD_WHEN,{||.T.})
		EndIf

		//-- Tratamento para adicionar cronograma fisico quando alterado o tipo de contrato e ja possui itens.
		If !oModelCNA:IsDeleted() .And. oModelCNA:GetValue("CNA_VLTOT") > 0
			If !oModelCNF:IsDeleted() .And. !Empty(oModelCNF:GetValue("CNF_PARCEL")) .And.;	//-- Se possui cronograma fisico
				(oModelCNS:IsDeleted() .Or. Empty(oModelCNS:GetValue("CNS_ITEM")))				//-- e não financeiro
				CN300DelCrg(.T.) //-- Deleta cronograma da planilha
				lHelpFis := .T.
			EndIf
		EndIf

		If lHelpFis
			Aviso(STR0090,STR0096,{STR0222})
		EndIf
	Else //-- Se contrato de medicao nao eventual e sem crg fisico, libera financeiro e bloqueia fisico
		CNTA300BlMd(oModelCNF,.T.,.T.)
		CNTA300BlMd(oModelCNS,.T.)
		//-- Deleta cronogramas fisicos que possam ter sido adicionados
		oModelCNS:SetNoDeleteLine(.F.)
		CNTA300DlMd(oModelCNS,'CNS_ITEM')
		oModelCNS:SetNoDeleteLine(.T.)
	EndIf

	//-- Tratamentos de bloqueio do Contrato SemiFixo
	If lSemiFixo
		CN300BlqAgr(oModel)
		CNTA300BlMd(oModelCNA,.F.)
	EndIf

	//-- Se contrato de edital, bloqueia planilha e itens
	If !lSemiFixo
		If oModelCXM <> Nil .And. !Empty(oModelCXM:GetValue("CXM_AGRTIP") )
			CNTA300DlMd(oModelCXM,"CXM_ITEMID")
			CNTA300BlMd(oModelCXM,.T.)
			CNTA300BlMd(oModelCNB,.F.)
			CNTA300BlMd(oModelCNZ,.F.)
		Else
			CNTA300BlMd(oModelCXM,.T.)
			CNTA300BlMd(oModelCNB,.F.)
			CNTA300BlMd(oModelCNZ,.F.)
		EndIf

		If !lFixo .Or. lEdital
			//-- Se contrato nao fixo
			If !lFixo
				CNTA300BlMd(oModelCNA,.F.)
				CNTA300BlMd(oModelCNB,.F.)
				//-- Deleta planilhas que possam ter sido adicionadas
				CNTA300DlMd(oModelCNB,'CNB_PRODUT')
				CNTA300BlMd(oModelCNB,.T.)
			EndIf

			If lEdital  .And. ! FWIsInCallStack('A200GERDOC')
				CNTA300BlMd(oModelCNA,,.T.)
				CNTA300BlMd(oModelCNB,,.T.)
			Endif

		//-- Se contrato fixo, atualiza valor inicial do contrato
		ElseIf lFixo 
			If !FWIsInCallStack("TECA850") .And. !FWIsIncallStack("TECA870") .AND. !FWIsInCallStack("TECA745")
				If Empty(cTipRevisa) .AND. Empty(cAprTipRev)
					CNTA300BlMd(oModelCNA,.F.,lCotacao)	
					If lCotacao
						CNTA300BlMd(oModelCNB,.F.,.T.)
					Elseif lSCAdt .And. !FunName() == 'MATA110'
						CNTA300BlMd(oModelCNB,.F.,.T.)
					Else
						CNTA300BlMd(oModelCNB,.F.,.F.)
					EndIf
				Else
					CNTA300BlMd(oModelCNA,.F.)
					CNTA300BlMd(oModelCNB,.F.)
				EndIf
			EndIf

			If !lServico
				//Retorna Campo CNB_QUANT, pois, caso o tipo de contrato/planilha anterior seja semi-fixo esse campo não é obrigatório
				oStruCNB := oModelCNB:GetStruct()
				oStruCNB:SetProperty('CNB_QUANT',MODEL_FIELD_WHEN,{|| .T. })
				oStruCNB:SetProperty('CNB_QUANT',MODEL_FIELD_OBRIGAT, .T. )
			ElseIf lTrigger
				CNTA300DlMd(oModelCNF,'CNF_PARCEL')
				If(!lCotacao) .And. (!lSCAdt)//Nao deve excluir os itens se for oriundo de uma cotação
					CNTA300DlMd(oModelCNB,'CNB_PRODUT')
				EndIf
			EndIf
		EndIf
	EndIf

	//-- Se contrato com crg contabil, libera edicao de linhas nos modelos
	If lContabil
		CNTA300BlMd(oModelCNV,.T.,.T.)
		CNTA300BlMd(oModelCNW,.T.,.T.)

	//-- Se nao, bloqueia modelos
	Else
		CNTA300BlMd(oModelCNV,.T.)
		CNTA300BlMd(oModelCNW,.T.)

		//-- Deleta cronogramas que possam ter sido adicionados
		oModelCNV:SetNoDeleteLine(.F.)
		oModelCNW:SetNoDeleteLine(.F.)
		CNTA300DlMd(oModelCNW,'CNW_PARCEL')
		CNTA300DlMd(oModelCNV,'CNV_NUMERO')

		If !oModelCNV:IsDeleted()
			If !(Empty(oModelCNV:GetValue("CNV_TOTCRG")))				
				oModelCNV:LoadValue("CNV_TOTCRG",0)//retorna o valor para zero, pois, a função de exclusão do modelo insere uma linha para deletar fisicamente
			EndIf
			If !(Empty(oModelCNV:GetValue("CNV_PERIOD")))				
				oModelCNV:LoadValue("CNV_PERIOD","")
			EndIf
		EndIf
		
		oModelCNV:GetStruct():SetProperty("CNV_NUMERO",MODEL_FIELD_OBRIGAT,.F.)
		oModelCNV:SetNoDeleteLine(.T.)
		oModelCNW:SetNoDeleteLine(.T.)
	EndIf

	If !lSemiFixo
		If FWIsInCallStack('A200GerCtr')
			CNTA300BlMd(oModelCNA,.T.,.T.)
			CNTA300BlMd(oModelCNB,.T.,.T.)
		Else
			If Empty(cTipRevisa) .AND. Empty(cAprTipRev)
				CNTA300BlMd(oModelCNA,.F.,lCotacao)
			Else
				CNTA300BlMd(oModelCNA,.F.)
			EndIf
		EndIf
		CN300VLPLA(lFixo,lValor)
		If !oModelCNA:IsDeleted() .And. !Empty(oModelCNA:GetValue("CNA_TIPPLA"))			
			
			lAlteraVig := oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. !( AllTrim(CN9->CN9_SITUAC) $ ( DEF_SELAB + "|" + DEF_SREVS + "|" + DEF_SREVA + "|" + DEF_SREJE ) )
			
			If !lFixo .And. lValor .And. !lAlteraVig				
				oModelCNA:GetStruct():SetProperty('CNA_VLTOT',MODEL_FIELD_WHEN,{||.T.})
			Else
				oModelCNA:GetStruct():SetProperty('CNA_VLTOT',MODEL_FIELD_WHEN,{||.F.})
			Endif
		EndIf
		If !lRecorrente
			oModelCNA:LoadValue('CNA_PERIOD'," ")
			oModelCNA:LoadValue('CNA_QTDREC',0)
			oModelCNA:LoadValue('CNA_DIASEM'," ")
			oModelCNA:LoadValue('CNA_DIAMES',0)
			oModelCNA:LoadValue('CNA_PROMED',Ctod(""))
		Endif
		FWRestRows(aSaveLines)
		lRet := .T.
	EndIf

	If lServico
		CNTA300BlMd(oModelCNF,.F.)

		oModelCNB:GetStruct():SetProperty('CNB_QUANT',MODEL_FIELD_OBRIGAT,.F. )
		oModelCNB:GetStruct():SetProperty('CNB_QUANT',MODEL_FIELD_WHEN,{||.F.})
		MtBCMod(oModel,{{'CNFDETAIL',{'CNF_VLPREV'}}},{||.F.},'2')
	Else
		If lFisico
			MtBCMod(oModel,{{'CNSDETAIL',{'CNS_PRVQTD'}}},{||.T.},'2')
			oModelCNF:GetStruct():SetProperty('CNF_VLPREV',MVC_VIEW_CANCHANGE, .F.)
		ElseIf lValor
			MtBCMod(oModel,{{'CNFDETAIL',{'CNF_VLPREV'}}},{||.T.},'2')
		EndIf
	EndIf
Endif

If !FWIsInCallStack('A300ChgLine') .And. !Empty(cTipRevisa)
	A300Revisa(oModel,A300GTpRev())
EndIf

If cTipRevisa == DEF_REV_ORCGS .OR. FwIsInCallStack( "AT870APRRV" )
	If FindFunction( "TecChngCNA" )
		TecChngCNA( oModel )
	EndIf
EndIf

Return cTipoPla

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VldFis
Rotina para validacao do cronograma fisico

@param oModel		Model da rotina
@param oModelCNF	Model da tabela CNF - Cronograma Financeiro
@author Leandro.Moura
@since 15/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300VldFis(oModel,oModelCNF,lPcoInte)
Local lRet	   		:= .T.
Local aItens		:= {}
Local nFinan   	:= 0
Local nFisic   	:= 0
Local oModelCNS 	:= oModel:GetModel("CNSDETAIL")
Local oModelCN9		:= oModel:GetModel("CN9MASTER")
Local oModelCNA		:= oModel:GetModel("CNADETAIL")
Local oModelCNB 	:= oModel:GetModel("CNBDETAIL")
Local aSaveLines	:= FWSaveRows()
Local nDif			:= 0
Local nTamQnt		:= TamSX3("CNB_QUANT")[2]
Local lPermReaj		:= .F. //-- Permite Reajuste
Default lPcoInte := .F.

//-- Posiciona no cronograma financeiro
For nFinan := 1 To oModelCNF:Length()
	oModelCNF:GoLine(nFinan)
	If !(oModelCNF:IsDeleted()) .And. !Empty(oModelCNF:GetValue("CNF_COMPET"))

		For nFisic := 1 To oModelCNS:Length()
			oModelCNS:GoLine(nFisic)
			If !(oModelCNS:IsDeleted()) .And. !Empty(oModelCNS:GetValue("CNS_ITEM"))
				nPos := aScan(aItens,{|x| x[1] == oModelCNS:GetValue('CNS_ITEM')})
				If  nPos == 0
					Aadd(aItens, {oModelCNS:GetValue('CNS_ITEM'), oModelCNS:GetValue("CNS_PRVQTD")})
				Else
					aItens[nPos, 2] += oModelCNS:GetValue("CNS_PRVQTD")
				EndIf
			EndIf
			
			//-- Verifica se possui bloqueio orcamentario no SIGAPCO
			If lRet .And. lPcoInte
				lRet := A300PCOVld(oModel,"000357","02","CNTA300",.T.)	//-- Cronograma Fisico
				If !lRet
					Help(" ",1,"CNTA300PCO",,STR0134,5,0)
					PcoFreeBlq("000357")
				EndIf
			EndIf
		Next nFisic
	EndIf
	If !lRet
		Exit
	EndIf
Next nFinan

If lRet
	For nFisic := 1 To Len(aItens)
		oModelCNB:GoLine(nFisic)
		nPos := aScan(aItens,{|x| x[1] == oModelCNB:GetValue('CNB_ITEM')})
		If nPos > 0 .AND. !oModelCNB:IsDeleted()
			//--Caso o a planilha permita contingencia de saldos, os valores podem ficar negativos
			nLmtMedP:= 0			 				
			nLmtMedP := CN300PlaSt("LMTMEDCONTRA",oModelCN9:GetValue("CN9_TPCTO"),oModelCNA:GetValue("CNA_TIPPLA"))
			
			//--Caso o a contrato permita contingencia de saldos, os valores podem ficar negativos
			nLmtMedC := 0			
			nLmtMedC := CN300PlaSt("LMTMED",oModelCN9:GetValue("CN9_TPCTO"),oModelCNA:GetValue("CNA_TIPPLA"))
			
			//--Permite Reajuste
			lPermReaj := ( oModelCN9:GetValue("CN9_FLGREJ") == "1" .And. oModelCNA:GetValue("CNA_FLREAJ") == "1" )

			If ((nLmtMedP + nLmtMedC) > 0 .Or. !lPermReaj)
				nDif := Abs(Round(aItens[nPos,2],nTamQnt)-oModelCNB:GetValue("CNB_QUANT"))
				If Round(nDif,2) > 0.01
                    Help(" ",1,"CN300SLDFIS",,STR0129,5,0)
					lRet := .F.
					Exit
				EndIf
			EndIf
		EndIf
	Next nFisic
EndIf

FWRestRows(aSaveLines)
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} CN300AddFis
Rotina para adicionar o produto no cronograma fisico

@param oModel		Model do contrato
@param cItPlan	Numero do item da planilha
@param cProd		Produto do item da planilha
@param nQtde		Qtde. do produto do item da planilha
@param lDeleta	Indica se deleta as linhas deletadas
@author Leandro.Moura
@since 16/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function CN300AddFis(oModel,cItPlan,cProd,nQtde,lDeleta, nLinCNF)
Local cParcCrg	:= ""
Local cDescPrd	:= ""
Local nNewLine	:= 0
Local nFinan	:= 0
Local aSaveLines:= FWSaveRows()
Local aWhenCNS  := {}
Local oModelCNF	:= oModel:GetModel("CNFDETAIL")
Local oModelCNS	:= oModel:GetModel("CNSDETAIL")
Local lRevMed	:= .F.
Local cTipoRev	:= A300GTpRev()
Local lProcParc := .F.
Default lDeleta := .F.
Default nLinCNF := 0

If !Empty(cTipoRev)
	If (cTipoRev $ DEF_REV_REAJU+'|'+DEF_REV_REALI+'|'+DEF_REV_ABERT)
		lRevMed := A300RevMed(0)
	EndIf

	If !FWIsInCallStack("CN300AtCrs")
		aWhenCNS := GCTGetWhen(oModelCNS)
		MtBCMod(oModel,{'CNSDETAIL'},{||.T.})
	EndIf
EndIf

//-- Posiciona no cronograma financeiro
For nFinan := 1 to oModelCNF:Length()
	oModelCNF:GoLine(nFinan)
	If nLinCNF > 0
		If oModelCNF:GetLine() <> nLinCNF
			Loop
		EndIf
	EndIf

	lProcParc := IIF(lRevMed, .T.,  (oModelCNF:Getvalue("CNF_SALDO") > 0) )

	If !(oModelCNF:IsDeleted()) .And. !Empty(oModelCNF:GetValue("CNF_COMPET")) .And.;		
		(lProcParc .Or.(nFinan == oModelCNF:Length() .And. FWIsInCallStack('CN300IcPrc')))

		If !CN300VLCNS(oModelCNS, cItPlan)
			Exit
		EndIf

		If lDeleta .And. Val(cItPlan) == 1
			oModel:GetModel("CALC_CNS"):LoadValue("TCNS_VTOT",0)
		EndIf
		cParcCrg := oModelCNF:GetValue("CNF_PARCEL")
		cDescPrd := Posicione("SB1",1,xFilial("SB1")+cProd,"B1_DESC")
		oModel:GetModel("CALC_CNS"):LoadValue("TCNS_PARC",cParcCrg)
		//-- Adiciona linha no grid do cronog. fisico
		If oModelCNS:IsDeleted() .Or. !Empty(oModelCNS:GetValue("CNS_ITEM"))
			oModelCNS:SetNoInsertLine(.F.)
			nNewLine := oModelCNS:AddLine()
			oModelCNS:GoLine(nNewLine)
			oModelCNS:SetNoInsertLine(.T.)
		EndIf

		//-- Adiciona produto na parcela do cronog. fisico
		oModelCNS:SetNoUpdateLine(.F.)
		oModelCNS:SetValue( "CNS_PARCEL",cParcCrg)
		oModelCNS:LoadValue("CNS_ITEM"	,cItPlan)
		oModelCNS:SetValue( "CNS_PRODUT",cProd)
		oModelCNS:SetValue( "CNS_DESCRI",cDescPrd)
		oModelCNS:SetValue( "CNS_PRVQTD",0)
		oModelCNS:SetValue( "CNS_RLZQTD",0)
		oModelCNS:LoadValue("CNS_SLDQTD",0)
		oModelCNS:SetValue( "CNS_DISTSL",nQtde)
		oModelCNS:SetValue( "CNS_TOTQTD",nQtde)
		oModelCNS:SetValue( "CNS_ITOR"	,"")

		If lDeleta .And. oModelCNS:GetLine() # Val(cItPlan)
			oModelCNS:LineShift(oModelCNS:GetLine(),Val(cItPlan))
		EndIf
	EndIf

	If lDeleta
		//-- Tratamento para remover linhas deletadas da tela
		oModelCNS:SetNoDeleteLine(.F.)
		While oModelCNS:IsDeleted(oModelCNS:Length())
			oModelCNS:GoLine(oModelCNS:Length())
			oModelCNS:DeleteLine(.T.,.T.)
		End
		oModelCNS:SetNoDeleteLine(.T.)
	EndIf
Next nFinan

If (Len(aWhenCNS) > 0)
    GCTRstWhen(oModelCNS, aWhenCNS)
	FwFreeArray(aWhenCNS)
EndIf

FWRestRows(aSaveLines)
FwFreeArray(aSaveLines)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300Docum
Visualiza o banco de conhecimento.
@author israel.escorizza
@return Nil
@since 19/05/2016
@version 2.0
/*/
//------------------------------------------------------------------
Function CN300Docum()
Local aAreaCN9	:= CN9->(GetArea())
Local nRecnoCN9	:= CN9->(Recno())
Local aPerm		:= CN300VldUsr()
Local lPerm		:= aPerm[1] .Or. aPerm[7][aScan(aPerm[7],{|x| x[1] == '047'})][2]
Local lBcoFixo	:= SuperGetMv('MV_CNBCFIX',.F.,.F.)

//VARIAVEIS ADICIONADAS DEVIDO A UTILIZAÇÃO NA FUNÇÃO MSDOCUMENT.
Private aRotina	:= MenuDef()
Private cCadastro	:= STR0071		//"Contratos - Documentos"

If lPerm
	If lBcoFixo
		//- Posiciona sempre no contrato principal (sem revisão), para carregar os documentos para todas revisões
		dbSelectArea('CN9')
		CN9->(dbSetOrder(1)) //- CN9_FILIAL+CN9_NUMERO+CN9_REVISA
		If !(CN9->(MsSeek(xFilial('CN9')+CN9->CN9_NUMERO+Space(TAMSX3('CN9_REVISA')[1]))))
			CN9->(dbGoTo(nRecnoCN9))
		EndIf
	EndIf
	If FWIsInCallStack("CN300Visua") .Or. FWIsInCallStack("CN300Delet") //- Visualização ou Exclusão
		MsDocument('CN9',CN9->(Recno()),1)
	Else
		MsDocument('CN9',CN9->(Recno()),2)
	EndIf
	CN9->(dbGoTo(nRecnoCN9))
Else
	Help(" ",1,"SEMPERM")//Opção Não Permitida
EndIf

RestArea(aAreaCN9)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300InFis
Inicializador padrão do campo CNS_PRODUT

@author Leandro.Moura
@since 16/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CN300InFis()
Local aArea		:= GetArea()
Local cReadVar	:= SubStr(AllTrim(ReadVar()),4)
Local xRet		:= NIL
Local cProd		:= ""
Local cContra	:= CN9->CN9_NUMERO
Local cRevisa	:= CN9->CN9_REVISA
Local cPlanil	:= CNS->CNS_PLANI
Local cItemPl	:= CNS->CNS_ITEM

If cReadVar == "CNS_PRODUT"
	//-- Busca o produto utilizando o item da planilha
	xRet := Posicione("CNB",1,xFilial("CNB")+cContra+cRevisa+cPlanil+cItemPl,"CNB_PRODUT")
ElseIf cReadVar == "CNS_DESCRI"
	//-- Busca a descricao do produto utilizando o item da planilha
	cProd := Posicione("CNB",1,xFilial("CNB")+cContra+cRevisa+cPlanil+cItemPl,"CNB_PRODUT")
	xRet  := Posicione("SB1",1,xFilial("SB1")+cProd,"B1_DESC")
ElseIf cReadVar == "CNS_TOTQTD"
	xRet := Posicione("CNB",1,xFilial("CNB")+cContra+cRevisa+cPlanil+cItemPl,"CNB_QUANT")
EndIf

RestArea(aArea)
Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc}CNTA300ItF()
Rotina para carga das planilhas dos produtos que possuem SC's

@author Matheus Lando Raimundo
@since 30/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CNTA300ItF(oModel,cCodEdt,cNumPro,cRevisa,cFilEdt,cFilEnt,cCodFor,cLoja,lLote,cLote)
Local oCNADetail	:= oModel:GetModel("CNADETAIL")
Local oCNBDetail	:= oModel:GetModel("CNBDETAIL")
Local oCNZDetail	:= oModel:GetModel("CNZDETAIL")
Local oCNCDetail	:= oModel:GetModel("CNCDETAIL")
Local oCPDDETAIL    := oModel:GetModel("CPDDETAIL")
Local cAliasCP4	:= GetNextAlias()
Local cItemRat 	:= Replicate("0", (TamSx3('CNZ_ITEM')[1]))
Local lRateio		:= .F.
Local cSeekCNZ	:= ""
Local lRet			:= .F.
Local cRelacao	:= ""
Local cTpPla		:= SuperGetMV("MV_TPPLA", .T., "")
Local cItPla		:= Replicate("0", (TamSx3('CNA_NUMERO')[1]))
Local cItem		:= Replicate("0", (TamSx3('CNB_ITEM')[1]))
Local lFirst		:= .T.
Local aRetorno	:= aR()
Local nQuant		:= 0
Local nPosNCtr	:= 0
Local cReman		:= ""
Local aCTBEnt		:= CTBEntArr(.T.)
Local nCount		:= 0
Local cQuant		:= ""
Local cPrcUn		:= ""
Local cFator		:= "CASE WHEN CO3.CO3_PERCEN > 0 THEN (CO3.CO3_PERCEN / 100) WHEN CO3.CO3_PERCEN = 0 THEN (1) END"
Local nQtd25		:= 0
Local cPercen		:= "%%"
Local cTipoPlan	:= ""
Local bQuebra		:= {|| C1_PRODUTO+C1_NUM+C1_ITEM+C1_CC+C1_CLVL+C1_CONTA+C1_ITEMCTA }
Local cQuebra		:= ''
Local lAglutina	:= .F.
Local nCont		:= 0
Local lAgluAll	:= .F.
Local cKey300   	:= ''
Local cKey			:= "C1_PRODUTO,C1_NUM,C1_ITEM,C1_CC,C1_CLVL,C1_CONTA,C1_ITEMCTA"
local lPosHMCO2		:= CO2->(FieldPos("CO2_HOMOLO")) > 0
local lPosDOCO2		:= CO2->(FieldPos("CO2_DOCOK")) > 0
Local cWhere		:= IIf(lPosHMCO2 .And. lPosDOCO2, "% AND CO2.CO2_HOMOLO = 'T' AND CO2.CO2_DOCOK = 'F' %", "%%")

CNTA300BlMd(oModel:GetModel('CNBDETAIL'),.F.)
CNTA300BlMd(oModel:GetModel('CNZDETAIL'),.F.)
CNTA300BlMd(oModel:GetModel('CNCDETAIL'),.F.)
oModel:GetModel('CNADETAIL'):SetNoUpdateLine(.F.)

//³Ponto de Entrada para aglutinar solicitação de compras do edital para o contrato
If ExistBlock("C300SCQBRA")
	bQuebra := ExecBlock("C300SCQBRA",.F.,.F.,{bQuebra})
	If ValType(bQuebra) <> "B"
		bQuebra := {|| C1_PRODUTO+C1_NUM+C1_ITEM+C1_CC+C1_CLVL+C1_CONTA+C1_ITEMCTA }
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para ajustar a chave de ordenacao para usar em conjunto³
//³com o  C300SCQBRA                                                       ³  
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("C300SCFILK")
	cKey300 := ExecBlock("C300SCFILK",.F.,.F.,{cKey})
	If ValType(cKey300)=="C"
		cKey := cKey300
	EndIf
EndIf

cKey := '%'+cKey+'%'

If lLote
	cRelacao := '% AND CP4.CP4_LOTE = CO3.CO3_LOTE%'
Else
	cRelacao := '% AND CP4.CP4_CODPRO = CO3.CO3_CODPRO%'
	cLote     := '%(' + "'" + CriaVar('CO2_LOTE', .F.) +  "'" + ')%'
EndIf

cQuant := " SC1.C1_QUANT * " + cFator
cPrcUn := " CASE WHEN CO3.CO3_PERCEN > 0 AND CO3.CO3_PERCEN <= 25 THEN CP6.CP6_PRCUN2 WHEN CO3.CO3_PERCEN <> 25 THEN CP6.CP6_PRCUN END "
cPercen := "% ,CO3.CO3_PERCEN %"
cQuant := '%'+cQuant+'%'

If CO1->CO1_REMAN
	cReman := 	" AND CO2.CO2_REMAN = 'T'"
EndIf
cReman := '%'+cReman+'%'
cPrcUn := '%'+cPrcUn+'%'

BeginSQL Alias cAliasCP4

	SELECT SC1.C1_FILENT, SC1.C1_PRODUTO, SC1.C1_UM, SC1.C1_NUM, SC1.C1_ITEM, CO3.CO3_VLUNIT, SUM(SC1.C1_QUANT) C1_QUANT,SC1.R_E_C_N_O_ REGSC1,
			SC1.C1_RATEIO, SC1.C1_CC, SC1.C1_CLVL, SC1.C1_CONTA, SC1.C1_ITEMCTA, CO3.CO3_CODIGO, CO2.CO2_ITEM, %exp:cPrcUn%  CP6_PRCUN, CO3.CO3_LOTE, SB5.B5_TIPO %exp:cPercen%
	FROM %table:CP4% CP4
		INNER JOIN %table:SC1% SC1 ON CP4.CP4_FILIAL      = %exp:cFilEdt%
								    	  AND CP4.CP4_NUMSC  = SC1.C1_NUM
										  AND CP4.CP4_ITEMSC = SC1.C1_ITEM
										  AND CP4.CP4_CODEDT = SC1.C1_CODED
										  AND CP4.CP4_NUMPRO = SC1.C1_NUMPR
										  AND CP4.CP4_FILENT = SC1.C1_FILENT

		INNER JOIN %table:CO2% CO2 ON CP4.CP4_FILIAL 		= CO2.CO2_FILIAL
									  	  AND CP4.CP4_CODEDT = CO2.CO2_CODEDT
								      	  AND CP4.CP4_NUMPRO = CO2.CO2_NUMPRO
								      	  AND CP4.CP4_REVISA = CO2.CO2_REVISA
								          AND CP4.CP4_CODPRO = CO2.CO2_CODPRO
								          AND CP4.CP4_LOTE   = CO2.CO2_LOTE

		INNER JOIN %table:CO3% CO3 ON CP4.CP4_FILIAL  		= CO3.CO3_FILIAL
										  AND CP4.CP4_CODEDT  = CO3.CO3_CODEDT
										  AND CP4.CP4_NUMPRO  = CO3.CO3_NUMPRO
										  AND CP4.CP4_REVISA  = CO3.CO3_REVISA
								    	  %exp:cRelacao%

		LEFT JOIN %table:CP6% CP6  ON CP4.CP4_FILIAL       = CP6.CP6_FILIAL
										  AND CP4.CP4_CODEDT  = CP6.CP6_CODEDT
										  AND CP4.CP4_NUMPRO  = CP6.CP6_NUMPRO
										  AND CP4.CP4_REVISA  = CP6.CP6_REVISA
										  AND CP4.CP4_LOTE    = CP6.CP6_LOTE
										  AND CP4.CP4_CODPRO  = CP6.CP6_CODPRO
										  AND CO3.CO3_CODIGO  = CP6.CP6_CODIGO
										  AND CO3.CO3_LOJA    = CP6.CP6_LOJA
										  AND CP6.%NotDel%
		Left Join %table:SB5% SB5 ON  SB5.B5_FILIAL = %xFilial:SB5% 
		                              	  AND SB5.B5_COD = SC1.C1_PRODUTO 
		                              	  AND SB5.%NotDel% 	

	WHERE CP4.CP4_FILIAL  = %exp:cFilEdt%
		AND CP4.CP4_CODEDT = %exp:cCodEdt%
		AND CP4.CP4_NUMPRO = %exp:cNumPro%
		AND CP4.CP4_REVISA = %exp:cRevisa%
		AND CP4.CP4_LOTE   IN %exp:cLote%
		AND SC1.C1_FILENT  = %exp:cFilEnt%
		AND CO3.CO3_CODIGO = %exp:cCodFor%
		AND CO3.CO3_LOJA   = %exp:cLoja%
		AND CO3.CO3_STATUS = '5'
		%exp:cWhere%
		AND CP4.%NotDel%
		AND SC1.%NotDel%
		AND CO2.%NotDel%
		AND CO3.%NotDel%

	GROUP BY SC1.C1_FILENT, C1_PRODUTO, SC1.C1_UM, CO2.CO2_QUANT , CO3.CO3_VLUNIT, SC1.R_E_C_N_O_ , SC1.C1_NUM, SC1.C1_ITEM,
			  SC1.C1_RATEIO, SC1.C1_CC, SC1.C1_CLVL, SC1.C1_CONTA, SC1.C1_ITEMCTA, CO3.CO3_CODIGO, CO2.CO2_ITEM, %exp:cPrcUn%, CO3.CO3_LOTE %exp:cPercen%,SB5.B5_TIPO,%exp:cKey%
	ORDER BY SC1.C1_FILENT,SB5.B5_TIPO

EndSql

lRet := (cAliasCP4)->(!EOF())
cTipoPlan := (cAliasCP4)->B5_TIPO
cQuebra := (cAliasCP4)->(Eval(bQuebra))
While (cAliasCP4)->(!EOF())
	nCont ++
	//-- Caso o produto esteja vinculado a uma SC.
	If lFirst .Or. (cAliasCP4)->B5_TIPO <> cTipoPlan  
		lFirst := .F.
		cItem  := Replicate("0",TamSx3('CNB_ITEM')[1])
		If cItPla <> Replicate("0",TamSx3('CNA_NUMERO')[1])
			oCNADetail:AddLine()
		EndIf
		cItPla := Soma1(cItPla)
		
		
		oCPDDetail:SetValue('CPD_FILAUT',(cAliasCP4)->C1_FILENT)

		//-- Carrega dados da Planilha
		oCNADetail:SetValue('CNA_FORNEC',oCNCDetail:GetValue('CNC_CODIGO'))
		oCNADetail:SetValue('CNA_TIPPLA',cTpPla)
		oCNADetail:SetValue('CNA_NUMERO',cItPla)
		oCNADetail:SetValue('CNA_DTINI',dDataBase)
	EndIf

	If cQuebra <> (cAliasCP4)->(Eval(bQuebra))
		If !Empty(oCNBDetail:GetValue('CNB_PRODUT'))
			oCNBDetail:AddLine()
		EndIf
		cQuebra := (cAliasCP4)->(Eval(bQuebra))
		lAglutina := .F.			
	Else
		If nCont > 1
			lAgluAll := .T.
			lAglutina := .T.
		Else
			lAglutina := .F.
		EndIf
	EndIf
	
	//Verifica se possui rateio para não aglutinar
	SCX->(DbSetOrder(1))
	lRateio := SCX->(dbSeek(cSeekCNZ := xFilial("SCX")+(cAliasCP4)->(C1_NUM+C1_ITEM)))	

	If !lAglutina .Or. nCont == 1
		//-- Carrega Itens da planilha
		cItem := Soma1(cItem)
		oCNBDetail:SetValue('CNB_ITEM',cItem)
		oCNBDetail:SetValue('CNB_PRODUT',(cAliasCP4)->C1_PRODUTO)
	EndIf
	If (!lAglutina .Or. nCont == 1) .And. !lAgluAll	
		oCNBDetail:SetValue('CNB_GCPIT',(cAliasCP4)->CO2_ITEM)
		oCNBDetail:SetValue('CNB_GCPLT',(cAliasCP4)->CO3_LOTE)
	Else
		oCNBDetail:SetValue('CNB_GCPIT','')
		oCNBDetail:SetValue('CNB_GCPLT','')
	EndIf
	aRetorno := aR()
	nPosNCtr := aScan(aRetorno,{|x| x[2] + x[8] == (cAliasCP4)->C1_PRODUTO + (cAliasCP4)->CO3_LOTE })
	If CO1->CO1_REMAN .And. nPosNCtr > 0
		nQuant := aRetorno[nPosNCtr,3]
		oCNBDetail:SetValue('CNB_QUANT',nQuant)
	Else
		If (cAliasCP4)->CO3_PERCEN > 0
			nQtd25 := (cAliasCP4)->CO2_QUANT*(cAliasCP4)->CO3_PERCEN  / 100
			oCNBDetail:SetValue('CNB_QUANT',nQtd25)
		Else
			If lAglutina .And. !lRateio .And. nCont > 1
				oCNBDetail:SetValue('CNB_QUANT',oCNBDetail:GetValue("CNB_QUANT")+(cAliasCP4)->C1_QUANT)
			Else
				oCNBDetail:SetValue('CNB_QUANT',(cAliasCP4)->C1_QUANT)
			EndIf
		EndIf
	EndIf

	oCNBDetail:SetValue('CNB_GCPIT',(cAliasCP4)->CO2_ITEM)
	oCNBDetail:SetValue('CNB_GCPLT',(cAliasCP4)->CO3_LOTE)
	oCNBDetail:SetValue('CNB_NUMSC',(cAliasCP4)->C1_NUM)
	oCNBDetail:SetValue('CNB_ITEMSC',(cAliasCP4)->C1_ITEM)
	If !lLote
		oCNBDetail:SetValue('CNB_VLUNIT',(cAliasCP4)->CO3_VLUNIT)
		oCNBDetail:SetValue('CNB_VLTOT', (cAliasCP4)->CO3_VLUNIT * oCNBDetail:GetValue('CNB_QUANT'))
	Else
		oCNBDetail:SetValue('CNB_VLUNIT',(cAliasCP4)->CP6_PRCUN)
		oCNBDetail:SetValue('CNB_VLTOTR',(cAliasCP4)->CP6_PRCUN * oCNBDetail:GetValue('CNB_QUANT'))
	EndIf

	If lRateio
		cItemRat := Replicate("0",TamSx3('CNZ_ITEM')[1])
		While SCX->(!EOF()) .And. SCX->(CX_FILIAL+CX_SOLICIT+CX_ITEMSOL) == cSeekCNZ
			If cItemRat <> Replicate("0",TamSx3('CNZ_ITEM')[1])
				oCNZDetail:AddLine()
			EndIf
			cItemRat := Soma1(cItemRat)
			oCNZDetail:SetValue('CNZ_ITEM',cItemRat)
			oCNZDetail:SetValue('CNZ_PERC', SCX->CX_PERC)
			oCNZDetail:SetValue('CNZ_CC',SCX->CX_CC)
			oCNZDetail:SetValue('CNZ_CONTA',SCX->CX_CONTA)
			oCNZDetail:SetValue('CNZ_ITEMCT',SCX->CX_ITEMCTA)
			oCNZDetail:SetValue('CNZ_CLVL',SCX->CX_CLVL)

			For nCount := 1 To Len(aCTBEnt)
				//-- Adiciona valor nas entidades contabeis
				If CNZ->(FieldPos("CNZ_EC" +aCTBEnt[nCount] +"CR")) > 0 .And. SCX->(FieldPos("CX_EC"+aCTBEnt[nCount]+"CR")) > 0
					oCNZDetail:SetValue("CNZ_EC" +aCTBEnt[nCount] +"CR",SCX->&("CX_EC" +aCTBEnt[nCount] +"CR"))
				EndIf
				If CNZ->(FieldPos("CNZ_EC" +aCTBEnt[nCount] +"DB")) > 0 .And. SCX->(FieldPos("CX_EC" +aCTBEnt[nCount] +"DB")) > 0
					oCNZDetail:SetValue("CNZ_EC" +aCTBEnt[nCount] +"DB",SCX->&("CX_EC" +aCTBEnt[nCount] +"DB"))
				EndIf
			Next nCount

			SCX->(dbSkip())
		End
	Else	
		If lAglutina .And. nCont > 1
			oCNBDetail:SetValue('CNB_CC',Iif(oCNBDetail:GetValue("CNB_CC")<>(cAliasCP4)->C1_CC,'',(cAliasCP4)->C1_CC))
			oCNBDetail:SetValue('CNB_CLVL',Iif(oCNBDetail:GetValue("CNB_CLVL")<>(cAliasCP4)->C1_CLVL,'',(cAliasCP4)->C1_CLVL))
			oCNBDetail:SetValue('CNB_CONTA',Iif(oCNBDetail:GetValue("CNB_CONTA")<>(cAliasCP4)->C1_CONTA,'',(cAliasCP4)->C1_CONTA))
			oCNBDetail:SetValue('CNB_ITEMCT',Iif(oCNBDetail:GetValue("CNB_ITEMCT")<>(cAliasCP4)->C1_ITEMCTA,'',(cAliasCP4)->C1_ITEMCTA))			
		Else
			oCNBDetail:SetValue('CNB_CC',(cAliasCP4)->C1_CC)
			oCNBDetail:SetValue('CNB_CLVL',(cAliasCP4)->C1_CLVL)
			oCNBDetail:SetValue('CNB_CONTA',(cAliasCP4)->C1_CONTA)
			oCNBDetail:SetValue('CNB_ITEMCT',(cAliasCP4)->C1_ITEMCTA)
	
			SC1->(dbGoto((cAliasCP4)->REGSC1))
	
			For nCount := 1 To Len(aCTBEnt)
				//-- Adiciona valor nas entidades contabeis
				If CNB->(FieldPos("CNB_EC" +aCTBEnt[nCount] +"CR")) > 0 .And. SC1->(FieldPos("C1_EC"+aCTBEnt[nCount]+"CR")) > 0
					oCNBDetail:SetValue("CNB_EC" +aCTBEnt[nCount] +"CR",SC1->&("C1_EC" +aCTBEnt[nCount] +"CR"))
				EndIf
				If CNB->(FieldPos("CNB_EC" +aCTBEnt[nCount] +"DB")) > 0 .And. SC1->(FieldPos("C1_EC" +aCTBEnt[nCount] +"DB")) > 0
					oCNBDetail:SetValue("CNB_EC" +aCTBEnt[nCount] +"DB",SC1->&("C1_EC" +aCTBEnt[nCount] +"DB"))
				EndIf
			Next nCount
		EndIf
	EndIf
	cTipoPlan := (cAliasCP4)->B5_TIPO
	(cAliasCP4)->(dbSkip())
End

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}CNTA300xEfl()
Rotina para geração do Contrato a partir do Edital
Integracao com o modulo SIGAGCP

@author Matheus Lando Raimundo
@since 30/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CNTA300xEfl(oModel200,oModel300,cFilEdt,cFilEnt,cCodFor,cLoja,lLote,cLote,aFilsEnv)
Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oCN9Master	:= oModel300:GetModel('CN9MASTER')
Local cCodEdt		:= oModel200:GetModel('CO1MASTER'):GetValue('CO1_CODEDT')
Local cNumPro		:= oModel200:GetModel('CO1MASTER'):GetValue('CO1_NUMPRO')
Local cRevisa		:= oModel200:GetModel('CO1MASTER'):GetValue('CO1_REVISA')
Local cItPla		:= Replicate("0",TamSx3('CNA_NUMERO')[1])
Local cItCNB		:= Replicate("0",TamSx3('CNB_ITEM')[1])
Local cAutom		:= oModel200:GetModel("CO1MASTER"):GetValue("CO1_AUTO")
Local nLinhaPla	:= 0
Local lVenda		:= oModel200:GetModel('CO1MASTER'):GetValue('CO1_GERDOC') == "2"
Local lCN300VEDT	:= ExistBlock("CN300VEDT")
Local lRetorno	:= .T.
Default cFilEdt	:= cFilAnt

oCN9Master:SetValue('CN9_ESPCTR',If(!lVenda,'1','2'))
oCN9Master:SetValue('CN9_DTINIC',dDataBase)
oCN9Master:SetValue('CN9_UNVIGE','4')
oCN9Master:SetValue('CN9_CODED',cCodEdt)
oCN9Master:SetValue('CN9_NUMPR',cNumPro)
oCN9Master:SetValue('CN9_FILEDT',cFilEdt)
CNTA300BlMd(oModel300:GetModel('CNBDETAIL'),.F.)
CNTA300BlMd(oModel300:GetModel('CNZDETAIL'),.F.)
CNTA300BlMd(oModel300:GetModel('CNCDETAIL'),.F.)
GCP017BMod(oModel300,{'CNADETAIL'},.F.)

If cAutom == '1'
	AtriTpcPg(oCN9Master,lVenda) //Funcao para atribuir conteudo Cond Pagto e Tipo de Contrato quando executado por rotina automatica
EndIf

If SuperGetMV("MV_NOTAEMP",.F.,.F.)
	dbSelectArea("CX0")
	CX0->(DbSetOrder(1))
	If CX0->(DbSeek(xFilial("CX0")+cCodEdt))
		oCN9Master:LoadValue('CN9_CODNE',CX0->CX0_CODNE)
	EndIf
	RestArea(aArea)
EndIf

If lCN300VEDT
	lRetorno := ExecBlock("CN300VEDT",.F.,.F.,{oModel300,cCodEdt,cNumPro,cRevisa,cCodFor,cLoja,cItPla,cItCNB,aFilsEnv,lLote,cLote})
EndIf

If lRetorno
	//-- Função que cria os itens das planilhas com os produtos das SC's.
	If !Empty(cFilEnt)
		CNTA300ItF(oModel300,cCodEdt,cNumPro,cRevisa,cFilEdt,cFilEnt,cCodFor,cLoja,lLote,cLote)
	Else
		//-- Função que cria os itens das planilhas com as sobras das quantidades.
		nLinhaPla := CNTA300Rst(oModel300,cCodEdt,cNumPro,cRevisa,cCodFor,cLoja,@cItPla,@cItCNB,aFilsEnv,lLote,cLote)

		//-- Função que cria os itens das planilhas para os produtos sem SC's.
		CNTA300Pss(oModel300,cCodEdt,cNumPro,cRevisa,cCodFor,cLoja,@cItPla,@cItCNB,aFilsEnv,lLote,cLote,nLinhaPla,lVenda,oModel200,.F.,'')
	EndIf
EndIf

CNTA300BlMd(oModel300:GetModel('CNBDETAIL'),.T.)
CNTA300BlMd(oModel300:GetModel('CNZDETAIL'),.T.)
CNTA300BlMd(oModel300:GetModel('CNCDETAIL'),.T.)
GCP017BMod(oModel300,{'CNADETAIL'},.T.)

RestArea(aArea)
FWRestRows( aSaveLines )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VlrCTB
Inicializador padrão do campo CNV_TOTCRG

@author Leandro.Moura
@since 16/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CN300VlrCTB()
Local aArea	:= GetArea()
Local nRet		:= 0

//-- Monta query para buscar o total do cronograma contabil
BeginSQL Alias "TMPCNW"
	SELECT 	SUM(CNW_VLPREV) AS VLRCRON
	FROM %Table:CNW% CNW
	WHERE CNW.%NotDel% AND
		CNW.CNW_FILIAL = %xFilial:CNW% AND
		CNW.CNW_CONTRA = %Exp:CN9->CN9_NUMERO% AND
		CNW.CNW_REVISA = %Exp:CN9->CN9_REVISA% AND
		CNW.CNW_NUMERO = %Exp:CNV->CNV_NUMERO%
EndSQL

//-- Retorna o valor total do cronograma
If TMPCNW->(!EOF())
	nRet := TMPCNW->VLRCRON
EndIf

TMPCNW->(dbCloseArea())

RestArea(aArea)
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300CtbPre
Rotina para tratamento no pre valid do grid de itens do cronog. contabil

@param nLine	Linha atual
@param cAction	Acao do usuario
@param cCampo	Campo em memoria
@param xValue	Valor em memoria
@author Leandro.Moura
@since 17/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300CtbPre(oModelGrid,nLine,cAction,cCampo,xValue)
Local lRet 		:= .T.
Local nVlrAtu	:= 0
Local nVlrCrg	:= 0
Local oModel 	:= oModelGrid:GetModel()
Local oModelCNV := oModel:GetModel("CNVDETAIL")
Local oModelCNW := oModel:GetModel("CNWDETAIL")
Local lExclui	:= oModel:GetOperation() == MODEL_OPERATION_DELETE
Local lVisual	:= oModel:GetOperation() == MODEL_OPERATION_VIEW
Local lEx69J	:= .F.
Local nPos		:= 0

If(!lExclui .And. !lVisual)	
	If cAction == 'CANSETVALUE' .And. cCampo == "CNW_VLPREV"
		//Tratamento para libera o campo CNW_VLPREV dependendo da configuração
		lEx69J := VerPadrao("69J")
		If !(oModelCNW:GetValue("CNW_FLGAPR") == '2' .Or. lEx69J)
			lRet := .F.
		EndIf
	//-- Tratamento para gatilhar o valor total do cronograma
	ElseIf cAction == 'SETVALUE' .And. cCampo == "CNW_VLPREV"
		nVlrAtu := oModelCNW:GetValue("CNW_VLPREV")
		nVlrCrg := (oModelCNV:GetValue("CNV_TOTCRG")+xValue) - nVlrAtu
		CNTA300BlMd(oModelCNV,.F.)
		oModelCNV:LoadValue("CNV_TOTCRG",nVlrCrg)
		CNTA300BlMd(oModelCNV,.T.)
	ElseIf cAction == 'SETVALUE' .And. cCampo == "CNW_VLPRES" //Totalizador valor presente
		nVlrAtu := oModelCNW:GetValue("CNW_VLPRES")
		nVlrCrg := (oModelCNV:GetValue("CNV_VLPRES")+xValue) - nVlrAtu
		CNTA300BlMd(oModelCNV,.F.)
		oModelCNV:LoadValue("CNV_VLPRES",nVlrCrg)
		CNTA300BlMd(oModelCNV,.T.)
	ElseIf cAction == 'SETVALUE' .And. cCampo == "CNW_VJUROS" //Totalizador despesa financeira
		nVlrAtu := oModelCNW:GetValue("CNW_VJUROS")
		nVlrCrg := (oModelCNV:GetValue("CNV_VJUROS")+xValue) - nVlrAtu
		CNTA300BlMd(oModelCNV,.F.)
		oModelCNV:LoadValue("CNV_VJUROS",nVlrCrg)
		CNTA300BlMd(oModelCNV,.T.)
	ElseIf(cAction == 'DELETE' .And. oModelCNW:GetDataId() <> 0)
		 If aScan(aDelsCNW, oModelCNW:GetDataId()) == 0
			 aAdd(aDelsCNW, oModelCNW:GetDataId())
		 EndIf
	ElseIf(cAction == 'UNDELETE')
		If((nPos := aScan(aDelsCNW, oModelCNW:GetDataId())) > 0)
			aDel(aDelsCNW,nPos)
			aSize(aDelsCNW,Len(aDelsCNW) - 1)
		EndIf
		oModelCNW:LoadValue("CNW_VLPREV", 0)
		oModelCNW:LoadValue("CNW_NUMERO", oModelCNV:GetValue("CNV_NUMERO"))
		If ValPresCtb()
			oModelCNW:LoadValue("CNW_VJUROS", 0)
			oModelCNW:LoadValue("CNW_TJUROS", 0)
			oModelCNW:LoadValue("CNW_VLPRES", 0)
		EndIf
	EndIf
EndIf


CN300PVCNW(cAction,nLine,cCampo,xValue)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VldCtb
Rotina para validacao do cronog. contabil da planilha

@param oModel		Model da rotina
@param oModelCNA	Model da tabela CNA - Planilhas

@author Leandro.Moura
@since 17/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300VldCtb(oModel,oModelCNA)
Local lRet	   		:= .T.
Local oModelCNV 	:= oModel:GetModel("CNVDETAIL")
Local oModelCNW 	:= oModel:GetModel("CNWDETAIL")
Local nCount		:= 0
Local aSaveLines	:= FWSaveRows()

Local lVldCrg		:= .F.
Local nVlrPlanN		:= NoRound(oModelCNA:GetValue("CNA_VLTOT")	, TamSx3("CNA_VLTOT")[2])
Local nVlrPlanR		:=   Round(oModelCNA:GetValue("CNA_VLTOT")	, TamSx3("CNA_VLTOT")[2])
Local nVlrCrgN		:= NoRound(oModelCNV:GetValue("CNV_TOTCRG")	, TamSx3("CNV_TOTCRG")[2])
Local nVlrCrgR		:=   Round(oModelCNV:GetValue("CNV_TOTCRG")	, TamSx3("CNV_TOTCRG")[2])

lVldCrg := nVlrCrgN <> nVlrPlanN .And. nVlrCrgN <> nVlrPlanR .And. nVlrCrgR <> nVlrPlanN .And. nVlrCrgR <> nVlrPlanR

//-- Verifica o total do cronog. com o total da planilha
If !oModelCNV:IsDeleted() .And. !Empty(oModelCNV:GetValue("CNV_NUMERO")) .And. lVldCrg
	Help(" ",1,"CNTA300MON") //-- O montante do cronograma deve ser igual ao montante das planilhas.
	lRet := .F.
EndIf

//-- Verifica se contem parcelas com valor 0
If lRet
	For nCount := 1 to oModelCNW:Length()
		oModelCNW:GoLine(nCount)
		If !(oModelCNW:IsDeleted()) .And. !Empty(oModelCNW:GetValue("CNW_PARCEL")) .And. Empty(oModelCNW:GetValue("CNW_VLPREV"))
			Help(" ",1,"CNTA300ZER") //-- Não é permitido incluir parcelas com valor zerado.
			lRet := .F.
			Exit
		EndIf
	Next nCount
EndIf

FWRestRows(aSaveLines)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300DelCtb
Rotina para exclusao de cronograma contabil

@author Leandro.Moura
@since 07/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CN300DelCtb(lChangTpPl)
Local aArea		:= GetArea()
Local cCronog		:= ""
Local lConfirm	:= .F.
Local nCount		:= 0
Local oModel		:= FWModelActive()
Local oModelCN9 	:= oModel:GetModel("CN9MASTER")
Local oModelCNA 	:= oModel:GetModel("CNADETAIL")
Local oModelCNV 	:= oModel:GetModel("CNVDETAIL")
Local oModelCNW 	:= oModel:GetModel("CNWDETAIL")
Local aSaveLines	:= FWSaveRows()
Local lCont		:= .T.
Local cAutom 		:= oModel:GetModel("CN9MASTER"):GetValue("CN9_AUTO") // -- 0 - Default; 1 - Vindo da Automação (Robô)

DEFAULT lChangTpPl	:= .F.

If !Empty(cTipRevisa)
	If Empty(oModelCN9:GetValue('CN9_TIPREV'))
		Help('',1,'CNTA300OPN')
		lCont := .F.
	EndIf
EndIf

If lCont .And. CN300PeDCr()
	cCronog := oModelCNV:GetValue("CNV_NUMERO")

	If !Empty(cCronog)
		If lChangTpPl .Or. cAutom == '1'
			lConfirm 	:= .T. // Se for troca de tipo de planilha, confirma automaticamente
		ElseIf cAutom == '0'
			lConfirm 	:= MsgYesNo(STR0072 +cCronog +"?")	//"Deseja excluir o cronograma contábil " # "?")
		EndIf
	EndIf

	If lConfirm
		//-- Exclui itens do cronograma
		oModelCNW:SetNoDeleteLine(.F.)
		For nCount := 1 to oModelCNW:Length()
			oModelCNW:GoLine(nCount)
	   		oModelCNW:DeleteLine()
		Next nCount
		oModelCNW:SetNoDeleteLine(.T.)

		//-- Exclui cabecalho do cronograma
		oModelCNV:GoLine(1)
		oModelCNV:SetNoDeleteLine(.F.)
		oModelCNV:DeleteLine()
		oModelCNV:SetNoDeleteLine(.T.)

		//-- Limpa o campo CNA_CRONCT
		oModelCNA:SetValue("CNA_CRONCT","")
	EndIf
Else
	Help('',1,'CNTA300OPNPERM')
EndIf


FWRestRows(aSaveLines)
RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300AddCtb
Rotina para inclusao de cronograma contabil

@author Leandro.Moura
@since 07/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CN300AddCtb()
Local aArea		:= GetArea()
Local dDtPrev	:= CToD("")
Local cHistor	:= ""
Local lOk		:= .T.
Local nParcelas	:= 0
Local nPeriod	:= 0
Local nDias		:= 0
Local nCount	:= 0
Local oModel	:= FWModelActive()
Local oModelCN9	:= oModel:GetModel("CN9MASTER")
Local oModelCNA := oModel:GetModel("CNADETAIL")
Local oModelCNV := oModel:GetModel("CNVDETAIL")
Local aSaveLines:= FWSaveRows()
Local cAutom 	:= oModel:GetModel("CN9MASTER"):GetValue("CN9_AUTO") // -- 0 - Default; 1 - Vindo da Automação (Robô)
Local lContabil := Cn300RetSt("CONTABIL")
Local nJuros	:= 0
Local bExec		:= Nil

//-- Verifica se permite crg. contabil
If ! lContabil
	Help(" ",1,"CN300PLANCRCTB")	//- O tipo de planilha ou tipo de contrato não permite Cronog. Contábil.
	lOk := .F.
EndIf

//-- Verifica se a linha do cabecalho nao esta em branco ou deletada
If lOk .And. ((oModelCN9:GetValue("CN9_ESPCTR") == "1" .And. Empty(oModelCNA:GetValue("CNA_FORNEC"))) .Or.;
				(oModelCN9:GetValue("CN9_ESPCTR") == "2" .And. Empty(oModelCNA:GetValue("CNA_CLIENT"))))
	Aviso(STR0090,STR0050,{STR0222})	//-- Preencha os campos do cabeçalho da planilha.
	lOk := .F.
EndIf

If oModelCNA:IsDeleted()
	Aviso(STR0090,STR0093,{STR0222})	//-- O cronograma não pode ser incluído pois a planilha está deletada.
	lOk := .F.
EndIf

If lOk .And. oModelCNA:GetValue("CNA_VLTOT") == 0
	Help(" ",1,"CNTA300PLA")  //-- Insira um item na planilha
	lOk := .F.
EndIf

//-- Verifica se existe cronograma ctb. para a planilha
If lOk
	For nCount := 1 to oModelCNV:Length()
		oModelCNV:GoLine(nCount)

		If !oModelCNV:IsDeleted() .And. !Empty(oModelCNV:GetValue("CNV_NUMERO"))
	    	lOk := .F.
    		Aviso(STR0090,STR0075,{STR0222})	//-- Esta planilha já contém um cronograma contábil associado.
	  		Exit
	  	EndIf
	Next nCount
EndIf

If lOK
	While (lOK := IIF( cAutom=="0", Pergunte("CN300CTB",.T.), Pergunte("CN300CTB",.F.)))
		dDtPrev		:= MV_PAR01
		nParcelas	:= MV_PAR02
		cHistor		:= MV_PAR03
		nPeriod		:= MV_PAR04
		nDias		:= MV_PAR05
		If ValType(MV_PAR06) == "N"
			nJuros := MV_PAR06
		EndIf
		
		lOk := CN300PGCtb(oModelCNA:GetValue("CNA_DTINI"),dDtPrev,nParcelas,nPeriod,nDias)

		If (lOk .Or. cAutom=="1")//Se parametros válidos OU automação(caso contrário ficaria em loop infinito)
			Exit		
		EndIf
	EndDo

	If lOK
		bExec := {||CN300MkCtb(oModel, dDtPrev,nParcelas,nPeriod,nDias,cHistor, nJuros) }		
		If IsBlind()
			Eval(bExec)
		Else
			FWMsgRun(, bExec, STR0084, STR0085)
		EndIf
	EndIf
EndIf

Pergunte("CNT100",.F.) //-- Retorna pergunte

FWRestRows(aSaveLines)
RestArea(aArea)
Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300PGCtb
Rotina validacao dos parametros informados no pergunte - Cronog. Ctb.

@author Leandro.Moura
@since 18/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300PGCtb(dDtIni,dDtPrev,nParcelas,nPeriod,nDias)
Local lRet	   		:= .T.
Local cCompete		:= Strzero(Month(dDtIni),2)+"/"+str(Year(dDtIni),4)
Local lVldVige 		:= (SuperGetMV("MV_CNFVIGE", .F., "N") == "N")
Local dFimCrg		:= dDtPrev
Local nCount		:= 0
Local nAvanco		:= 0
Local nTamParc  	:= TamSx3("CNW_PARCEL")[1]
Local oModel		:= FWModelActive()
Local oModelCNA	:= oModel:GetModel("CNADETAIL")

//-- Valida os parametros informados
If Empty(nPeriod) .Or. Empty(dDtPrev) .Or. Empty(nParcelas)
	Help(" ",1,"CNTA300CAM") //-- Preencha todos os campos
	lRet := .F.
EndIf

If lRet .And. dDtPrev < CToD("01/"+cCompete)
	Help(" ",1,"CNTA300PRE") //-- A data de previsão deve ser maior que a competência de início
	lRet := .F.
EndIf

//-- Valida a data informada com a data incial e final do contrato
If lRet .And. lVldVige .And. (dDtPrev < oModelCNA:GetValue("CNA_DTINI") .Or. dDtPrev > oModelCNA:GetValue("CNA_DTFIM"))
	Help(" ",1,"CNTA300DAT") //-- Data da primeira medição inválida
	lRet := .F.
EndIf

//-- Verifica a data final do cronograma com a data final do contrato
If lRet .And. lVldVige
	//-- Calcula data final do cronograma
	For nCount := 1 to (nParcelas-1)
		If nDias == 30
			nAvanco := Day(LastDay(dFimCrg))
		Else
			nAvanco := nDias
		EndIf

		dFimCrg+= nAvanco
	Next nCount
	
	lRet := CNTA300ULT(dFimCrg, oModelCNA:GetValue("CNA_DTFIM"), lVldVige)	
EndIf

If lRet .And. (nTamParc == 1) .And. (nParcelas > 35)
	Help(" ",1,"CNTA300NPA")	//-- O tamanho do campo CNF_PARCEL não permite a configuração da quantidade de parcelas inserida.
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300MkCtb
Rotina para montar o cronograma contabil da planilha

@param oModel 		Modelo da rotina
@param oModelCNA 	Modelo do cab. da planilha
@param oModelCNV	Modelo do cabecalho do cronograma contabil
@param oModelCNW	Modelo do item do cronograma contabil
@param dDtPrev		Data prevista primeira medicao
@param nParcelas	Numero de parcelas
@param nPeriod		Periodicidade
@param nDias		Numero de dias
@param cHistor		Historico do cronograma
@author Leandro.Moura
@since 18/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300MkCtb(oModel,dDtPrev,nParcelas,nPeriod,nDias,cHistor, nJuros)
Local aArea	   	:= GetArea()
Local aParcela 	:= {}
Local nTamParc 	:= TamSx3("CNW_PARCEL")[1]
Local cNumParc	:= Replicate("0",nTamParc)
Local cCompete	:= ""
Local cNumCrg	:= ""
Local dDtMed	:= dDtPrev
Local nVlrPlan	:= oModel:GetValue("CNADETAIL", "CNA_VLTOT")
Local nCount	:= 0
Local nVlParcel	:= 0
Local nVlrReal	:= 0
Local nNewLine	:= 0
Local nVlrSald	:= 0
Local nI 		:= 0
Local nX 		:= 0
Local nPos 		:= 0
Local aSaveLines:= FWSaveRows()
Local lUpdCNA	:= .F.
Local lVlPresent:= .F.
Local nTamParcel:= 0
Default nJuros	:= 0

oModelCNA := oModel:GetModel("CNADETAIL")
oModelCNV := oModel:GetModel("CNVDETAIL")
oModelCNW := oModel:GetModel("CNWDETAIL")
lUpdCNA	:= oModelCNA:CanUpdateLine()

lVlPresent := (ValPresCtb() .And. (nJuros > 0))

//-- Rotina para guardar o Recno dos registros deletados e deleta-los nos Commit do modelo, pois o Delete Físico não deleta os
//-- registros do banco.
For nI := 1 To oModelCNV:Length()
	oModelCNV:GoLine(nI)
	If oModelCNV:IsDeleted()
		If oModelCNV:GetDataId() <> 0 .And. Ascan(aDelsCNV, oModelCNV:GetDataId()) == 0
			Aadd(aDelsCNV, oModelCNV:GetDataId())
		EndIf
	EndIf
	For nX := 1 To oModelCNW:Length()
		oModelCNW:GoLine(nX)
		If oModelCNW:IsDeleted()
			If oModelCNW:GetDataId() <> 0 .And. Ascan(aDelsCNW, oModelCNW:GetDataId()) == 0
				Aadd(aDelsCNW, oModelCNW:GetDataId())
			EndIf
		EndIf
	Next nX
Next nI

//-- Calcula valor das parcelas sem arredondar
nVlParcel := nVlrPlan/nParcelas

For nCount := 1 to nParcelas
	cNumParc := Soma1(cNumParc)
	//-- Calcula data prevista da proxima parcela
	If nCount > 1
		If nPeriod == 1
			dDtMed := MonthSum(dDtPrev,nCount-1)	
		Else
		    dDtMed += nDias
		EndIf
	EndIf
	cCompete := Strzero(Month(dDtMed),2)+"/"+str(Year(dDtMed),4)
	//-- Calcula valor real da parcela e armazena o arredondamento
	nVlrReal := Round(nVlParcel,TamSx3("CNW_VLPREV")[2])
	nVlrSald += nVlParcel-nVlrReal
	//-- Adicona no array de parcelas
	aAdd(aParcela,{cNumParc,cCompete,dDtMed,nVlrReal,cHistor})
Next nCount

//-- Verifica valor restante do arredondamento
If !(nVlrSald == 0)
	//-- Adiciona na ultima parcela
	aParcela[ Len(aParcela) ,4] += nVlrSald
EndIf

If !Empty(aParcela)
	CNTA300BlMd(oModelCNV,.F.)
	CNTA300BlMd(oModelCNW,.F.)

	cNumCrg := GetSX8Num("CNW","CNW_NUMERO")

	//-- Cria o cabecalho do cronograma Contabil
	oModelCNV:UnDeleteLine()
	
	If((nPos := aScan(aDelsCNV, oModelCNV:GetDataId())) > 0)
		aDel(aDelsCNV,nPos)
		aSize(aDelsCNV,Len(aDelsCNV) - 1)
	EndIf
	
	oModelCNV:SetValue("CNV_NUMERO"	,cNumCrg)
	oModelCNV:SetValue("CNV_TXMOED"	,1)
	oModelCNV:SetValue("CNV_PERIOD"	,cValtoChar(nPeriod))
	oModelCNV:SetValue("CNV_DIAPAR"	,nDias)
	oModelCNV:SetValue("CNV_TOTCRG",0)
	If lVlPresent
		oModelCNV:SetValue("CNV_VLPRES", 0)
		oModelCNV:SetValue("CNV_VJUROS", 0)
	EndIf
	
	oModelCNW:SetNoInsertLine(.F.)
	nTamParcel := Len(aParcela)
	For nCount := 1 to nTamParcel //-- Cria os itens do cronograma Contabil
		nPos := MTFindMVC(oModelCNW,{ {'CNW_PARCEL',aParcela[nCount,1]}, {'CNW_COMPET',aParcela[nCount,2]} },,,.T.)
		
		If(nPos > 0)
			oModelCNW:GoLine(nPos)
			If(oModelCNW:IsDeleted())
				oModelCNW:UnDeleteLine()				
			EndIf
		ElseIf !Empty( oModelCNW:GetValue("CNW_PARCEL") )//-- Caso a linha nao esteja em branco, adiciona uma linha
			nNewLine := oModelCNW:AddLine()
			oModelCNW:GoLine(nNewLine)
		EndIf

		oModelCNW:SetValue("CNW_PARCEL",aParcela[nCount,1])
		oModelCNW:SetValue("CNW_COMPET",aParcela[nCount,2])
		oModelCNW:SetValue("CNW_DTPREV",aParcela[nCount,3])
		oModelCNW:SetValue("CNW_VLPREV",aParcela[nCount,4])
		oModelCNW:SetValue("CNW_HIST",aParcela[nCount,5])
		oModelCNW:SetValue("CNW_CC","")
		oModelCNW:SetValue("CNW_ITEMCT","")
		oModelCNW:SetValue("CNW_CLVL","")
		oModelCNW:SetValue("CNW_FLGAPR","2")

		If lVlPresent
			oModelCNW:SetValue("CNW_MAXPAR", nTamParcel)
			oModelCNW:SetValue("CNW_TJUROS", nJuros)
		EndIf

		//-- Tratamento para remover da grid as linha deletadas
		If oModelCNW:GetLine() # nCount
			nNewLine := oModelCNW:GetLine()
			oModelCNW:LineShift(nCount,nNewLine)
			oModelCNW:GoLine(nNewLine)
			oModelCNW:DeleteLine(.T.,.T.)
			oModelCNW:GoLine(nCount)
		EndIf
	Next nCount
	oModelCNW:SetNoInsertLine(.T.)

	//-- Gravando codigo do cronograma Contabil no CNA
	oModelCNA:SetNoUpdateLine(.F.)
	oModelCNA:SetValue("CNA_CRONCT",cNumCrg)
	oModelCNA:SetNoUpdateLine(!lUpdCNA)

	CNTA300BlMd(oModelCNV,.T.,.T.)
	CNTA300BlMd(oModelCNW,.T.,.T.)
EndIf

//-- Tratamento para remover linhas deletadas da tela
oModelCNW:SetNoDeleteLine(.F.)

For nI := 1 To oModelCNW:Length()
	oModelCNW:GoLine( nI )
	If oModelCNW:IsDeleted()
		oModelCNW:DeleteLine(.T.,.T.)
	EndIf
Next nI

oModelCNW:SetNoDeleteLine(.T.)

FWRestRows(aSaveLines)
RestArea(aArea)
Return

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} CNTA300BlMd()
Função que bloqueia ou desbloqueia um modelo,
alterando as propriedades lInsertLine, lDeleteLine e lUpdateline do model

@param	oModel , model , modelo que se deseja alterar as propriedades
@param	lBloqueia , logico , bloquia ou desbloqueia todas as propriedades
@param	lOnlyUpd , logico , libera o modelo apenas para alteracao (lUpdateLine)	
@author Matheus Lando Raimundo
@since 30/09/2013
@version P11.90
/*/
//------------------------------------------------------------------------------------
Function CNTA300BlMd(oModel,lBloqueia,lOnlyUpd)
	Local cClassName := ""
	Default lOnlyUpd := .F.

	cClassName := Upper(AllTrim(oModel:ClassName()))
	If (cClassName == "FWFORMGRID")	
		If lOnlyUpd
			oModel:SetNoDeleteLine(.T.)
			oModel:SetNoInsertLine(.T.)
			oModel:SetNoUpdateLine(.F.)
		Else
			oModel:SetNoDeleteLine(lBloqueia)
			oModel:SetNoUpdateLine(lBloqueia)
			oModel:SetNoInsertLine(lBloqueia)
		EndIf
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc}CNTA300VlIn()
Função que retorna total de acordo com as planilhas

@author Matheus Lando Raimundo
@since 14/11/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CNTA300VlIn(oModel, cCampo)
Local nTotal		:= 0
Local nI			:= 1
Local oModelCNA		:= oModel:GetModel('CNADETAIL')
Local aSaveLines	:= FWSaveRows()

For nI := 1 To oModelCNA:Length()
	oModelCNA:GoLine(nI)
	If !oModelCNA:IsDeleted()
		nTotal := nTotal + oModelCNA:GetValue(cCampo)
	EndIf
Next nI

FWRestRows(aSaveLines)
Return nTotal

//-------------------------------------------------------------------
/*/{Protheus.doc}CN300CtAPre()
Função que atualiza o valor inicial do cabecalho do Contrato

@author Matheus Lando Raimundo
@since 14/11/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Static Function CN300CtAPre(nLine,cAction,cCampo,xValue,xOldValue,oModelGrid)
Local aSaveLines	:= FWSaveRows()
Local oModel 		:= oModelGrid:GetModel()
Local oModelCNA 	:= oModel:GetModel("CNADETAIL")
Local oModelCPD 	:= oModel:GetModel("CPDDETAIL")
Local oModelCN9 	:= oModel:GetModel("CN9MASTER")
Local oModelCNB	    := oModel:GetModel("CNBDETAIL")
Local lRet 		    := .T.
Local lCRM			:= SuperGetMV("MV_CRMXGCT",.F.,.F.)
Local nFilAut		:= 0
Local nX			:= 0

If cAction == 'DELETE'
	If !Empty(cTipRevisa) .And. !oModelCNA:IsInserted() .And. CN300ExMed(oModel)
		Help('',1,'CNTA300NDPL')
		lRet := .F.
	Else
		If !Empty(oModelCN9:GetValue("CN9_CODED"))
			Help(" ",1,"CNT300PLEDT")  //-- O contrato foi gerado por um edital e por isso não se pode excluir planilhas
			lRet := .F.
		ElseIf lCRM
			For nX := 1 To oModelCNB:Length()
				If !Empty(oModelCNB:GetValue("CNB_PROPOS")) // Caso exista uma proposta nao permite editar
					lRet := .F.
					Help("",1,"INTEGRACRM_3",,STR0231)
					Exit
		        EndIf
			Next nX
		EndIf
	EndIf

	If lRet
		For nFilAut := 1 To oModelCPD:Length() //-- Deleta as filiais autorizadas da planilha
			oModelCPD:GoLine(nFilAut)
			If !oModelCPD:IsDeleted() .And. !Empty(oModelCPD:GetValue("CPD_NUMPLA")) .And. oModelCPD:GetValue("CPD_NUMPLA") == oModelCNA:GetValue("CNA_NUMERO")
				oModelCPD:DeleteLine()
			EndIf
		Next nCount

		oModelCN9:LoadValue("CN9_VLATU",  oModelCN9:GetValue("CN9_VLATU") - oModelCNA:GetValue('CNA_VLTOT'))
		oModelCN9:LoadValue("CN9_SALDO",  oModelCN9:GetValue("CN9_SALDO") - oModelCNA:GetValue('CNA_SALDO'))

		If Empty(cTipRevisa) .AND. Empty(cAprTipRev) .And. oModel:GetOperation() != MODEL_OPERATION_VIEW
			oModelCN9:LoadValue("CN9_VLINI",  oModelCN9:GetValue("CN9_VLATU"))
		EndIf
	EndIf

ElseIf cAction == 'UNDELETE' .Or. cAction == 'SETVALUE'
	//comparação para evitar de somar sempre o valor
	If lRet .AND. ValType(xValue) == "C" .And. ValType(xOldValue) == "C"
		xValue		:= AllTrim(xValue)
		xOldValue	:= AllTrim(xOldValue)
	EndIf
	If cAction == 'SETVALUE' .And. cCampo == "CNA_DTFIM"
		If !oModelCNA:IsDeleted() .And. !Empty(oModelCNA:GetValue("CNA_DTFIM"))
			If oModelCN9:GetValue("CN9_DTFIM") < FwFldGet("CNA_DTFIM")
				Help("",1,"CN300DtFPla",,STR0193,4,1)
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If lRet .And. cAction == 'UNDELETE'
		oModelCN9:LoadValue("CN9_VLATU",  oModelCN9:GetValue("CN9_VLATU") + oModelCNA:GetValue('CNA_VLTOT'))
		oModelCN9:LoadValue("CN9_SALDO",  oModelCN9:GetValue("CN9_SALDO") + oModelCNA:GetValue('CNA_SALDO'))
	EndIf

	If lRet .AND. Empty(cTipRevisa) .AND. Empty(cAprTipRev)
		//comparação para evitar de somar sempre o valor
		If cAction == 'UNDELETE' .Or. ( xValue <> xOldValue .And. cCampo <> "CNA_CRONOG" .And. cCampo <> "CNA_SALDO" )
			oModelCN9:LoadValue("CN9_VLINI",  oModelCN9:GetValue("CN9_VLATU"))
		EndIf
	EndIf

	//Libera apenas o When do campo CNA_SALDO na atualização da Revisão
	If lRet .AND. cAction == 'SETVALUE' .And. !(Empty(cTipRevisa)) .AND. Empty(cAprTipRev)
		oModel:GetModel("CNADETAIL"):GetStruct():SetProperty('CNA_SALDO',MODEL_FIELD_WHEN,{||.T.})
	EndIf

    If cAction == 'SETVALUE' .And. !Empty(xValue) .And. AllTrim(cCampo) $ "CNA_FLREAJ"
		CN300VRCt("CNA",xValue,xOldValue)
    EndIf

ElseIf cAction == 'CANSETVALUE' .And. lCRM
	For nX := 1 To oModelCNB:Length()
		If !Empty(oModelCNB:GetValue("CNB_PROPOS")) // Caso exista uma proposta nao permite editar
			lRet := .F.
			Help("",1,"INTEGRACRM_4",,STR0232)
			Exit
		EndIf
	Next nX
EndIf

FWRestRows(aSaveLines)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CNTA300DlMd()
Função que deleta todos os registros de um modelo

@param	oModel , model	, modelo que se deseja deletar conteudo
@param	cCampo , string , campo utilizado para verificar o preenchimento do modelo
						  se o conteudo do campo estiver vazio a funcao nao sera executada
@param	lClear , logico , apaga da memoria ou apenas marca como deletado.
						  parametro utilizado apenas em operacao de inclusao, quando verdadeiro 
						  se os registros estiverem gravados em banco, nao serao deletados do banco.

@author Matheus Lando Raimundo
@since 14/11/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CNTA300DlMd( oModel, cCampo, lClear )
Local nI			:= 1
Local aSaveLines	:= FWSaveRows()
Local lCanInsLin	:= oModel:CanInsertLine()

Default lClear      := .T.

If !Empty(oModel:GetValue(cCampo)) .AND. oModel:GetOperation() != MODEL_OPERATION_VIEW
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		//Em operação de alteração, registros não devem ser removidos do modelo, apenas marcados como deletados para posteriormente serem deletados do banco
		For nI := oModel:Length() To  1 Step -1
			oModel:Goline(nI)
			If !oModel:IsDeleted()
				oModel:DeleteLine()
			ElseIf !FwIsInCallStack('CN121Grids') .And. oModel:GetID() $ 'CNEDETAIL|CNRDETAIL1|CNRDETAIL2|CXODETAIL'
				oModel:UnDeleteLine()
			EndIf
		Next nI
	Else
  		//Verifica se não pode inserir linha e libera
	  	If !lCanInsLin
  			oModel:SetNoInsertLine( .F. )
  		EndIf
  		nNewLine := oModel:AddLine()
  		oModel:LineShift(1,nNewLine)

  		//Deleta todas as linhas anteriores
  		For nI := oModel:Length() to  2 Step -1
  			oModel:Goline(nI)
  			oModel:DeleteLine(.T.,.T.)
  		Next nI

  		//Limpa o modelo da Grid como se não tivesse alteração, porém, NÃO deve ser utilizado sozinho na ALTERAÇÃO, pois,;
  		//limpa apenas o que está na memória (modelo) e não no banco de dados, permanecendo os dados no banco após o commit.;
  		//No caso desta função primeiro deletamos todas as linhas e apenas chamamos o ClearData para limpar a última linha em branco
		If lClear
  			oModel:ClearData()
 		EndIf
 	EndIf
EndIf

//Devolve para a posição anterior
If !lCanInsLin
	oModel:SetNoInsertLine( .T. )
EndIf

FWRestRows(aSaveLines)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc}CNTA300PRQT()
Função que retorna o valor do campo CNS_PRVQTD de acordo
com a tecnologia usada

@author Matheus Lando Raimundo
@since 14/11/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CNTA300PRQT()
Local oModel		:= FWModelActive()
Local oModelCNS	:= oModel:GetModel("CNSDETAIL")
Local lMVC			:= ValType(oModel) <> "U"
Local nRetorno	:= 0

If lMVC
	nRetorno := oModelCNS:GetValue("CNS_PRVQTD")-oModelCNS:GetValue("CNS_RLZQTD")
Else
	nRetorno := CNS->CNS_PRVQTD
EndIf

Return nRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc}CN300VlDtI()
Validacao da data de inicio do contrato

@author Matheus Lando Raimundo
@since 30/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CN300VlDtI()
Local oModel		:= FWModelActive()
Local oModelCN9	:= oModel:GetModel("CN9MASTER")
Local lRet 		:= .T.

If !Empty(oModelCN9:GetValue("CN9_CODED")) .And. M->CN9_DTINIC < dDataBase
	Aviso(STR0090,STR0086,{STR0222}) //-- A data de início do contrato deve ser igual ou superior a data atual.
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}CN300VlDtA()
Valida a data de assinatura do contrato quando parâmetro MV_GCTDTTR está ativo.

@return lRet, logical, retorna .T. caso a data for válida.

@author juan.felipe
@since 26/08/2020
/*/
//-------------------------------------------------------------------
Function CN300VlDtA()
Local lRet 		:= .T.
Local lValidAss	:= SuperGetMv("MV_GCTDTTR",.F.,.F.)
Local oModel	:= FWModelActive()
Local oModelCN9	:= oModel:GetModel("CN9MASTER")
Local dDataIni  := oModelCN9:GetValue("CN9_DTINIC")
Local dDataAssi := oModelCN9:GetValue("CN9_ASSINA")

If lValidAss .And. !Empty(dDataIni)
    If !Empty(oModelCN9:GetValue("CN9_ASSINA")) .And. dDataAssi < dDataIni
        Help(" ",1,"A300ASSINA",,STR0310,1,4) //-- A data de assinatura (CN9_ASSINA) do contrato deve ser igual ou superior a data de início.
        lRet := .F.
    EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}CN300VlQtd()
Validacao do campo CNB_QUANT

@author André Anjos
@since 30/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CN300VlQtd(nLinha,nOldValue)
Local aSave	    := FWSaveRows()
Local lRet		:= Positivo()

Local oModel	:= FWModelActive()
Local oModelCNB	:= oModel:GetModel("CNBDETAIL")
Local oModelCNF	:= oModel:GetModel("CNFDETAIL")
Local oModelCNS	:= oModel:GetModel("CNSDETAIL")
Local nX		:= 0
Local aSeekCNS	:= {}
Local nDecQuant := GetSx3Cache("CNB_QUANT", "X3_DECIMAL")
Local aRestCNS	:= {}

If !Empty(cTipRevisa) .And. !oModelCNB:IsInserted()
	If oModelCNB:GetValue('CNB_QUANT') < Round(oModelCNB:GetValue('CNB_QTDMED'),nDecQuant)
		oModel:SetErrorMessage( "CNBDETAIL", "CNB_QUANT", "CNBDETAIL", "CNB_QUANT", "CNBQUANTMED", STR0220)//Não é possivel alterar a quantidade para um valor inferior a quantidade medida do item.
		lRet := .F.
	EndIf
EndIf

//-- Atualiza dados do cronograma fisico
If lRet .And. oModelCNB:GetValue("CNB_QUANT") <> nOldValue .And. Cn300RetSt("FISICO") .And. !Cn300RetSt("SEMIPROD")
	aRestCNS:= GetPropMdl(oModelCNS)
	CNTA300BlMd(oModelCNS,.F.)
	aSeekCNS  := { {"CNS_ITEM", oModelCNB:GetValue("CNB_ITEM") }}
	For nX := 1 To oModelCNF:Length() // -- Atualiza dados do cronograma físico
		oModelCNF:GoLine(nX)
		If !oModelCNF:IsDeleted() .And. !Empty(oModelCNF:GetValue("CNF_COMPET")) .And. oModelCNS:SeekLine(aSeekCNS)
			oModelCNS:GoLine(nLinha)
			oModelCNS:LoadValue("CNS_DISTSL",(oModelCNS:GetValue("CNS_DISTSL") + oModelCNB:GetValue("CNB_QUANT") - nOldValue))
			oModelCNS:LoadValue("CNS_TOTQTD",oModelCNB:GetValue("CNB_QUANT"))
		EndIf
	Next nX
	RstPropMdl(oModelCNS,aRestCNS)
	FwFreeArray(aRestCNS)
EndIf

FWRestRows(aSave)
FwFreeArray(aSave)
FwFreeArray(aSeekCNS)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}CN300VlPrc()
Validacao do campo CNB_VLUNIT

@author André Anjos
@since 30/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CN300VlPrc(nLinha,nOldValue)

Local oModel		:= FWModelActive()
Local oModelCN9	:= oModel:GetModel("CN9MASTER")
Local oModelCNB	:= oModel:GetModel("CNBDETAIL")
Local oModelCNF	:= oModel:GetModel("CNFDETAIL")
Local oModelCNS	:= oModel:GetModel("CNSDETAIL")
Local oModelTCNS	:= oModel:GetModel("CALC_CNS")
Local nX			:= 0
Local nTotal		:= 0
Local nReal		:= 0
Local nDif			:= 0
Local nDifR		:= 0
Local nQtdPrvT	:= 0
Local lRet			:= Positivo(oModelCNB:GetValue("CNB_VLUNIT"))
Local nTam		:= TamSx3('CNF_VLPREV')[2]

If lRet .And. oModelCN9:GetValue("CN9_ESPCTR") == "2"
	//-- Zera campos Desconto e Valor de Desconto
	FWFldPut("CNB_DESC",0)
	FWFldPut("CNB_VLDESC",0)
EndIf

//-- Atualiza dados do cronograma fisico
If lRet .And. Cn300RetSt("FISICO")  .And. cTipRevisa <> DEF_REV_REAJU	
	
	oModelCNF:SetNoUpdateLine(.F.)
	oModelCNF:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.T.})
	
	For nX := 1 To oModelCNF:Length()
		oModelCNF:GoLine(nX)
		If !oModelCNF:IsDeleted() .And. !Empty(oModelCNF:GetValue("CNF_COMPET")) .And. oModelCNS:Length() >= nLinha

			oModelCNS:GoLine(nLinha)

			//-- Calculo para novo valor previsto.
			nQtdPrvT += oModelCNS:GetValue('CNS_PRVQTD')

			nTotal := oModelCNF:GetValue('CNF_VLPREV')
			nTotal	+= (M->CNB_VLUNIT - nOldValue) * oModelCNS:GetValue('CNS_PRVQTD') * (1 - oModelCNB:GetValue('CNB_DESC') / 100)

			nReal	:= nTotal
			nTotal	:= Round(nTotal, nTam)

			nDif	+= nReal - nTotal
			nDifR	:= Round(nDif, nTam)

			If nDifR >= 0.01
				nTotal += nDifR
				nDifR := 0
			EndIf

			//-- Atualiza total da parcela no header e CNF
			oModelTCNS:LoadValue("TCNS_VTOT",nTotal)			
			oModelCNF:SetValue('CNF_VLPREV', nTotal)
			
			If Empty(A300GTpRev()) .And. oModelCNF:GetValue('CNF_VLPREV') <= nTotal .And. oModelCNF:GetValue('CNF_VLREAL') == 0
				oModelCNF:LoadValue('CNF_SALDO', nTotal)
			EndIf
			
		EndIf
	Next nX
	oModelCNF:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.F.})
	oModelCNF:GetStruct():SetProperty('CNF_DTVENC',MODEL_FIELD_WHEN,{||.T.}) //libera campos para ajuste de data
	oModelCNF:GetStruct():SetProperty('CNF_PRUMED',MODEL_FIELD_WHEN,{||.T.})
	oModelCNF:GetStruct():SetProperty('CNF_VLPREV',MODEL_FIELD_WHEN,{||!Cn300RetSt("FISICO")})
	oModel:GetModel("CNFDETAIL"):SetNoUpdateLine(.T.)	
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}CN300VlDes()
Validacao do campo CNB_DESC

@author André Anjos
@since 30/09/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CN300VlDes(nLinha,xOldValue)
Local lRet 		:= Positivo() .And. M->CNB_DESC < 100
Local oModel		:= FWModelActive()
Local oModelCNB	:= oModel:GetModel("CNBDETAIL")
Local oModelCNF	:= oModel:GetModel("CNFDETAIL")
Local oModelCNS	:= oModel:GetModel("CNSDETAIL")
Local oModelTCNS	:= oModel:GetModel("CALC_CNS")
Local nVlDesc		:= oModelCNB:GetValue("CNB_VLDESC")
Local nX			:= 0
Local aSave		:= FWSaveRows()

If lRet .And. Cn300RetSt("FISICO") .And. !FWIsInCallStack("A300DivCNB")
	For nX = 1 To oModel:GetModel("CNFDETAIL"):Length()
		oModel:GetModel("CNFDETAIL"):GoLine(nX)
		If !oModel:GetModel("CNFDETAIL"):IsDeleted() .And. !Empty(oModelCNF	:GetValue("CNF_COMPET"))
			If oModel:GetModel("CNSDETAIL"):Length() < nLinha
				Exit
			EndIf

			oModel:GetModel("CNSDETAIL"):GoLine(nLinha)

			nTotal := oModelTCNS:GetValue("TCNS_VTOT") //Pega o valor total da parcela
			nTotal += (nVlDesc/oModelCNB:GetValue("CNB_QUANT")) * oModelCNS:GetValue("CNS_PRVQTD") //Soma antigo desconto
			nTotal -= (oModelCNB:GetValue('CNB_DESC')/100) * oModelCNB:GetValue("CNB_VLUNIT")  //Subtrai novo valor de desconto

			nTotal := Round(nTotal,TamSX3("CNF_VLPREV")[2])
			//-- Atualiza total da parcela no header e CNF
			oModel:GetModel("CALC_CNS"):LoadValue("TCNS_VTOT",nTotal)
			oModel:GetModel("CNFDETAIL"):SetNoUpdateLine(.F.)
			oModel:GetModel("CNFDETAIL"):GetStruct():SetProperty('CNF_VLPREV',MODEL_FIELD_WHEN,{||.T.})
			oModel:GetModel("CNFDETAIL"):GetStruct():SetProperty('CNF_SALDO',MODEL_FIELD_WHEN,{||.T.})
			oModel:GetModel("CNFDETAIL"):SetValue("CNF_VLPREV",nTotal)
			oModel:GetModel("CNFDETAIL"):GetStruct():SetProperty('CNF_SALDO',MODEL_FIELD_WHEN,{||.F.})
			oModel:GetModel("CNFDETAIL"):GetStruct():SetProperty('CNF_VLPREV',MODEL_FIELD_WHEN,{||!Cn300RetSt("FISICO")})
		EndIf
	Next nX
EndIf

FWRestRows(aSave)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}CN300EnVl()
Funcao do When do campo CN9_VLINI para liberar dependendo do tipo do contrato

@author Aecio Ferreira Gomes
@since 03/10/2013
@version P11.90
/*/
//-------------------------------------------------------------------
Function CN300EnVl()
Local lRet 		:= .F.
Local oModel		:= FWModelActive()
Local oModelCN9	:= oModel:GetModel("CN9MASTER")

If !Empty(oModelCN9:GetValue("CN9_TPCTO"))
	CN1->(dbSetOrder(1))
	If CN1->(dbSeek(xFilial("CN1")+oModelCN9:GetValue("CN9_TPCTO")))
		lRet := !Cn300RetSt("FIXO") .And. Cn300RetSt("PREVFINANC")
	EndIf
EndIf

lRet := .F.
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}CN300ENREC()
Funcao do When dos campos de tratamento de planilha recorrente

@author Rogerio Melonio
@since 21/07/2015
@version P12
/*/
//-------------------------------------------------------------------
Function CN300ENREC()
Local lRet := .F.
Local oModel		:= FWModelActive()
Local oModelCNA		:= oModel:GetModel("CNADETAIL")

If !oModelCNA:IsDeleted() .And. !Empty( oModelCNA:GetValue("CNA_TIPPLA") )
	lRet := ( Posicione("CNL",1,xFilial("CNL")+FWFldGet("CNA_TIPPLA"),"CNL_MEDEVE") == "3" )// Cn300RetSt("RECORRENTE",0)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} cn300MultT()
Valida a quantidade, desconto e valor de desconto

@author José Eulálio
@since 30/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function cn300MultT()
Local aArea		:= GetArea()
Local cEspecie	:= ""
Local lRet			:= .T.
Local cReadVar	:= ReadVar()
Local xConteudo	:= &(cReadVar)
Local oModel		:= FWModelActive()
Local oModelCN9	:= oModel:GetModel("CN9MASTER")
Local oModelCNB	:= Nil
Local nValDesc	:= 0

oModelCNB := oModel:GetModel("CNBDETAIL")
cEspecie  := oModelCN9:GetValue("CN9_ESPCTR")
If (cEspecie =="2")
	//³Zera campos Desconto e Valor de Desconto³
	If ( "CNB_VLUNIT" $ cReadVar ) .OR. ( "CNB_QUANT" $ cReadVar )
		FWFldPut("CNB_DESC"  , 0 )
		FWFldPut("CNB_VLDESC", 0 )
	ElseIf "CNB_DESC" $ cReadVar
		FtDescItem(0,oModelCNB:GetValue("CNB_VLUNIT"),oModelCNB:GetValue("CNB_QUANT"),0,@xConteudo,@nValDesc,0,1)
		FWFldPut("CNB_VLDESC", nValDesc)
	EndIf
EndIf

RestArea(aArea)

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CN300SdDt()
Função que retorna o total a ser distribuido no cronograma financeiro

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function CN300SdDt(oModel, lDelete,nLine, nNValor)
Local oCNFDetail	:= oModel:GetModel('CNFDETAIL')
Local oCNADetail	:= oModel:GetModel('CNADETAIL')
Local nSld			:= 0
Local nTotCrg		:= 0
Local nI			:= 0
Local aSaveLines	:= FWSaveRows()
Local nTam			:= TamSX3('CNF_VLPREV')[2]

Default nLine    := 0
Default lDelete  := Nil

For nI := 1 To oCNFDetail:Length()
	oCNFDetail:GoLine(nI)

	If lDelete
		If oCNFDetail:GetLine() == nLine
			Loop
		EndIf
	EndIf
	If ValType(lDelete) == 'U'
		If oCNFDetail:GetLine() == nLine
			nTotCrg += nNValor
			Loop
		EndIf
	EndIf

	If !oCNFDetail:IsDeleted() .Or. (!lDelete .And.  oCNFDetail:GetLine() == nLine)
		nTotCrg += Round(oCNFDetail:GetValue('CNF_VLPREV'), nTam)
	EndIf
Next nI

nSld := NoRound((oCNADetail:GetValue('CNA_VLTOT') - nTotCrg), nTam)
FWRestRows(aSaveLines)

Return nSld

//------------------------------------------------------------------
/*/{Protheus.doc} CN300PVCNF()
Pre Valid do modelo CNF

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function CN300PVCNF(oModelGrid,cAction, nLine, cField, xValue, xOldValue)
	Local oModel		:= oModelGrid:GetModel()
	Local oCNADetail	:= Nil
	Local lRet			:= .T.
	Local nTemp			:= 0
	Local cCpoTot		:= ""

	If (cAction == "CANSETVALUE")
		lRet := !Empty(oModelGrid:GetValue("CNF_NUMERO"))//Só permite edição após geração do cronograma financeiro pelo Outras Ações
	EndIf

	If lRet .And. !Empty(cTipRevisa) .And. (cTipRevisa $ DEF_REV_ADITI+'|'+DEF_REV_REALI+'|'+DEF_REV_READE+'|'+DEF_REV_REINI+'|'+DEF_REV_RENOV+'|'+DEF_REV_ORCGS+'|'+DEF_REV_ABERT )  .And. !Cn300RetSt("RECORRENTE")
		oCNADetail	:= oModel:GetModel('CNADETAIL')

		If cAction == 'SETVALUE'  .And. cField == 'CNF_VLPREV'
			oCNADetail:LoadValue('CNA_SADIST', CN300SdDt(oModel, , nLine, xValue))
		ElseIf cAction == 'DELETE'
			oCNADetail:LoadValue('CNA_SADIST', CN300SdDt(oModel,.T. ,nLine))
		ElseIf cAction == 'UNDELETE'
			oCNADetail:LoadValue('CNA_SADIST', CN300SdDt(oModel,.F. ,nLine))
		EndIf
	EndIf

	If (CposVlPres() .And. oModelGrid:GetValue('CNF_TJUROS') > 0)
		If (cAction == 'SETVALUE' .And. cField $ 'CNF_VLPRES|CNF_VJUROS')		
			cCpoTot := IIF((cField == 'CNF_VLPRES'), 'CN9_VLPRES', 'CN9_VJUROS')
			nTemp := (xValue - xOldValue)
			nTemp := oModel:GetValue('CN9MASTER', cCpoTot) + nTemp
			oModel:LoadValue('CN9MASTER', cCpoTot, nTemp)
		ElseIf(cAction == 'UNDELETE')	 	
			nTemp := oModel:GetValue('CN9MASTER', 'CN9_VLPRES') + oModelGrid:GetValue('CNF_VLPRES')
			oModel:LoadValue('CN9MASTER', 'CN9_VLPRES', nTemp)		
			nTemp := oModel:GetValue('CN9MASTER', 'CN9_VJUROS') + oModelGrid:GetValue('CNF_VJUROS')
			oModel:LoadValue('CN9MASTER', 'CN9_VJUROS', nTemp)
		ElseIf(cAction == 'DELETE')
			nTemp := oModel:GetValue('CN9MASTER', 'CN9_VLPRES') - oModelGrid:GetValue('CNF_VLPRES')
			nTemp := Max(0, nTemp)
			oModel:LoadValue('CN9MASTER', 'CN9_VLPRES', nTemp)			
			
			nTemp := oModel:GetValue('CN9MASTER', 'CN9_VJUROS') - oModelGrid:GetValue('CNF_VJUROS')
			nTemp := Max(0, nTemp)
			oModel:LoadValue('CN9MASTER', 'CN9_VJUROS', nTemp)			
		EndIf		
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} cn300VldTS()
Valida Tipo Saida na Planilha

@author aline.sebrian
@since 07/03/2014
@version 1.0
/*/
//----------------------------------±--------------------------------
Function cn300VldTS()
Local aArea		:= GetArea()
Local cReadVar	:= ReadVar()
Local xConteudo	:= &(cReadVar)
Local lRet			:= .T.
Local oModel		:= FWModelActive()
Local oModelCN9	:= oModel:GetModel("CN9MASTER")
Local cEspecie	:= oModelCN9:GetValue("CN9_ESPCTR")

dbSelectArea("SF4")
SF4->(dbSetOrder(1))
MsSeek(xFilial("SF4")+xConteudo)

If  SF4->(Found())
	If xConteudo < "500"
		Help (" ",1,"A410NOTES")
		lRet := .F.
	EndIf

	If lRet .And. cEspecie=="1"
		Help (" ",1,"CNTA200TS1")//"Tipo Saida somente para Contratos do Tipo Vendas"
		lRet := .F.
	EndIf
Else
	Help (" ",1,"CNTA200TS2")//"Tipo Saida não cadastrada"
	lRet := .F.
EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} cn300VldTE()
Valida Tipo Entrada na Planilha

@author aline.sebrian
@since 07/03/2014
@version 1.0
/*/
//----------------------------------±--------------------------------
Function cn300VldTE()
Local cReadVar	:= ReadVar()
Local xConteudo	:= &(cReadVar)
Local lRet			:= .T.
Local cEspecie	:=  ""
Local oModel		:= FWModelActive()
Local oModelCN9	:= oModel:GetModel("CN9MASTER")

cEspecie := oModelCN9:GetValue("CN9_ESPCTR")

dbSelectArea("SF4")
SF4->(dbSetOrder(1))
MsSeek(xFilial("SF4")+xConteudo)

If  SF4->(Found())
	If xConteudo > "500"
		Help (" ",1,"A410NOTES")
		lRet := .F.
	EndIf

	If lRet
		If cEspecie == "2"
			Help (" ",1,"CNTA200TE1")//"Tipo Entrada somente para Contratos do Tipo Compras"
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}  CN300Rev
Rotina para tratamento na opcao de revisão

@author guilherme.pimentel
@since 21/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function CN300Rev(cAlias,cCampo,nOpc,cTipRev)
Local lRet			:= .T.
Local lAtiva		:= .F.
Local lAlterRev	:= FWIsInCallStack('CN300Alter') .And. !Empty(cTipRev)
Local lCompra := .F.

Default cTipRev 	:= Replicate("0", (TamSx3('CN9_REVISA')[1]))
lAdiant := .F.

If nModulo <> 28
	dbSelectArea("TFJ")
	TFJ->( dbSetOrder(5) ) //TFJ_FILIAL+TFJ_CONTRT+TFJ_CONREV
	If TFJ->(MsSeek(xFilial('TFJ',CN9->CN9_FILCTR)+CN9->(CN9_NUMERO+CN9_REVISA)))
		lRet := .F.
		Help(" ",1,"CN300REVTEC")	//-- Acao disponivel apenas para contratos sem vinculos com Gestão de Serviços
	EndIf
EndIf

cTipRevisa :=	cTipRev

If lRet
	If CN9->CN9_REVISA == CnGetRevAt(CN9->CN9_NUMERO) .And.;
	   ((Alltrim(CN9->CN9_SITUAC) == '05' .And. Empty(CN9->CN9_REVATU)) .Or. (Alltrim(CN9->CN9_SITUAC) $ '04|09|A' .And. lAlterRev)) // Contrato Vigente + Revisao atual;

		If cTipRevisa == DEF_REV_CAUCA		//= Revisão de Caução
			If CN9->CN9_FLGCAU == '1' .And. CN9->CN9_TPCAUC == '2'
				Help('',1,'CN300CAURT') 	//= Não é possível realizar revisões de caução em contratos que possuam caução por retenção.
			Else
				lAtiva	:= .T.
			EndIf

		Else
            If cTipRevisa <> DEF_REV_REINI .Or. lAlterRev //= Revisão não é de reinicio
            	lAtiva := .T.
            Else
            	Help('',1,'CNTA300NOREIN')
            EndIf
        EndIf

	ElseIf (Alltrim(CN9->CN9_SITUAC) == '06' .And. (cTipRevisa==DEF_REV_REINI .Or. cTipRevisa==DEF_REV_ABERT)) .Or. lAlterRev
		lAtiva := .T.
	Else
		Help('',1,'CNTA300NOVIG')
	EndIf

	If lAtiva
		//-Define ID do modelo
		lCompra := CN300RetSt('COMPRA',,,,,.F.) 
		
		Iif( lCompra, CNTSetFun("CNTA300"), CNTSetFun("CNTA301") )
		
		ClrVCpoUsr()
		If lAlterRev
			FWExecView( STR0160, Iif( lCompra, "CNTA300", "CNTA301" ), MODEL_OPERATION_UPDATE,, {|| .T.} )
		Else
			FWExecView( STR0161, Iif( lCompra, "CNTA300", "CNTA301" ), OP_COPIA,, {|| .T.} )
		EndIf
		ClrVCpoUsr()
	EndIf
EndIf

cTipRevisa	:= ''
lUserBut	:= .F.
lRevisado	:= .F.

Return Nil

//------------------------------------------------------------------
/*/{Protheus.doc} A300VldVAt()
Função para validar o o campo CN9_VLATU

@author alexandre.gimenez
@since 20/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function A300VldVAt(oModel,nValue)
Local lRet 	:= .T.
Local cModo	:= Cn300RetSt("MODALIDADE")
Local nReali 	:= 0

If !Cn300RetSt("FIXO",1) .And. (cTipRevisa==DEF_REV_REALI .Or. cTipRevisa==DEF_REV_RENOV .Or. cTipRevisa==DEF_REV_ORCGS)
	nReali:= nValue - CN9->CN9_VLATU
	lRet := (nReali + CN9->CN9_SALDO) > 0
	If lRet
		If cModo == "1"
			lRet:=  nValue >= CN9->CN9_VLATU
		//Quando for apenas decrescimo
		ElseIf cModo == "2"
			lRet:= nValue <= CN9->CN9_VLATU
		//Quando for ambos
		ElseIf cModo == "3"
			lRet:= .T.
		EndIf
		If !lRet
			Help("",1,"A300MODREALI")
		EndIf
	Else
		Help("",1,"A300NOSLD")
	EndIf
	If lRet // Atualiza Saldo
		oModel:LoadValue("CN9_SALDO", CN9->CN9_SALDO + nReali )
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CN300RetSt(cProp)
Funcao que retorna qualquer status ou propriedade do contrato.
as propriedades sao verificadas primeiramente no tipo de planilha, se a 
propriedade nao existir no tipo de planilha ou se o tipo de planilha 
utilizar a propriedade do tipo de contrato, a propriedade sera verificada 
no tipo de contrato. tambem existem propriedades que sao verificadas
diretamente no tipo de revisao

@param	cProp	, string	, Informa a propriedade a ser consultada
@param	nModo	, numerico	, Informa o modo de consulta a planilha
							  0 - Posicionada
							  1 - Todas
							  2 - Ao menos uma
@param cPlan	, string	, codigo da planilha
@param cContrato, string	, codigo do contrato
@param cFilCtr	, string	, filial do contrato
@param lModel	, logico	, utiliza o modelo para verificar a propriedade	

@return xRet	, conteudo de uma propriedade da planilha, do contrato ou da revisao

@author	Matheus Lando Raimundo
@since 	03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function CN300RetSt( cProp, nModo, cPlan, cContrato, cFilCTR, lModel )
Local xRet		 := Nil
Local aAreas	 := {CN9->(GetArea()), CNA->(GetArea()), CN0->(GetArea()),GetArea()}
Local aSaveLines := {}
Local oModel	 := FwModelActive()
Local lMdlAtivo	 := ValType(oModel) == 'O' .And. oModel:lActivate .And. oModel:GetId() $ 'CNTA300|CNTA301'
Local oModelCN9	 := Nil
Local oModelCNA	 := Nil
Local cTipoCtr	 := ""
Local cTipRev	 := ""
Local nX		 := 1
Local lOk 		 := .T.
Local cTpPla	 := ""

Default nModo 	  := 0
Default cPlan 	  := ""
Default cContrato := ""
Default cFilCTR   := cFilAnt
Default lModel	  := .T.

If lMdlAtivo .And. lModel	
	If (nModo > 0)
		aSaveLines	:= FWSaveRows( oModel )		
	EndIf

	oModelCN9	:= oModel:GetModel("CN9MASTER")
	oModelCNA	:= oModel:GetModel("CNADETAIL")	
	cTipoCtr 	:= oModelCN9:GetValue("CN9_TPCTO")
	cTipRev		:= oModelCN9:GetValue("CN9_TIPREV")
	
	If nModo == 0		
		//Se o número da planílha foi informada, então posíciona na linha da CNA correspondente, para pegar o tipo de planilha
		If !Empty( cPlan ) .And. cPlan <> oModelCNA:GetValue("CNA_NUMERO")
			aSaveLines := FWSaveRows( oModel )
			lOk := oModelCNA:SeekLine( { {"CNA_NUMERO", cPlan } } )
		EndIf
		If lOk
			xRet := CN300PlaSt( cProp, cTipoCtr, oModelCNA:GetValue("CNA_TIPPLA") )
		EndIf
	ElseIf nModo == 1
		For nX:=1 To oModelCNA:Length()
			oModelCNA:GoLine(nX)
			xRet := CN300PlaSt( cProp, cTipoCtr, oModelCNA:GetValue("CNA_TIPPLA") )
			If !xRet
				Exit
			Endif
		Next nX
	ElseIf nModo == 2
		For nX:=1 To oModelCNA:Length()
			oModelCNA:GoLine(nX)
			cTpPla := oModelCNA:GetValue("CNA_TIPPLA")
			If !Empty( cTpPla )
				xRet := CN300PlaSt( cProp, cTipoCtr, cTpPla, cFilCtr )
				If xRet
					Exit
				Endif
			Endif
		Next nX
	Endif

	If (Len(aSaveLines) > 0)
		FWRestRows(aSaveLines)
		FwFreeArray(aSaveLines)		
	EndIf
Else
	If !Empty(cContrato)
		CN9->( dbSetorder(1) ) //CN9_FILIAL+CN9_NUMERO+CN9_REVISA

		CN9->( MsSeek( xFilial('CN9',cFilCtr) + cContrato + CnGetRevAt(cContrato,cFilCtr) ) ) //Ultima Revisao
		cTipoCtr := CN9->CN9_TPCTO
		cTipRev	 := CN9->CN9_TIPREV
	Else
		If !IsBlind() .And. M->CN9_TPCTO <> NIl
			cTipoCtr := M->CN9_TPCTO
			cTipRev	 := M->CN9_TIPREV
		Else
			cTipoCtr := CN9->CN9_TPCTO
			cTipRev	 := CN9->CN9_TIPREV
		EndIf
	EndIf

	CNA->( dbSetOrder(1) ) //CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO
	If CNA->( MsSeek( FWxFilial("CNA",cFilCTR) + CN9->(CN9_NUMERO + CN9_REVISA) + cPlan ) )
		If nModo == 0
			xRet := CN300PlaSt( cProp, cTipoCtr, CNA->CNA_TIPPLA, cFilCTR )
		Else
			While !CNA->( Eof() ) .And. CNA->( FWxFilial("CNA",cFilCTR) + CNA_CONTRA + CNA_REVISA ) == CN9->( xFilial("CN9",cFilCTR) + CN9_NUMERO + CN9_REVISA )
				xRet := CN300PlaSt( cProp, cTipoCtr, CNA->CNA_TIPPLA, cFilCTR )
			 	If (!xRet .And. nModo == 1) .Or. (xRet .And. nModo == 2)
			 		Exit
				Endif
				CNA->( dbSkip() )
			EndDo
		Endif
	EndIf
Endif

//-- Propiedades de Tipo de Revisao
If cProp $ "TIPREV|MODALIDADE|REVESPECIE" .And. cProp <> "ESPECIE"
	CN0->( dbSetOrder(1) ) //CN0_FILIAL+CN0_CODIGO
	If CN0->( msSeek( FWxFilial("CN0",cFilCTR) + cTipRev ) )
		If cProp == 'TIPREV'
			xRet := CN0->CN0_TIPO
		ElseIf cProp == 'MODALIDADE'
			xRet := CN0->CN0_MODO
		ElseIf cProp == 'REVESPECIE'
			xRet := CN0->CN0_ESPEC
		EndIf
	Else
		xRet := ""
	EndIf
EndIf

If lCN300RST // Executa ponto de entrada para validacao do retorno da situacao
	xRet := ExecBlock("CN300RST",.F.,.F.,{xRet,CN9->CN9_TPCTO, cProp, cPlan, nModo, (lMdlAtivo .And. lModel) })
EndIf

If Valtype(xRet) == "U"
	xRet := TrataNulo(cProp)
EndIf

aEval(aAreas, {|x| RestArea(x) })
FwFreeArray(aAreas)
Return xRet

//------------------------------------------------------------------
/*/{Protheus.doc} CN300PlaSt()
Função que retorna qualquer status ou propiedade da planilha
utilizada pela funcao CN300RETST, nunca deve ser chamada diretamente.
Sempre que precisar de uma propriedade do contrato ou da planilha, deve-se chamar 
pela funcao CN300RETST

@param cProp	 , string	, propriedade que se deseja consultar
@param cTipoCtr  , string	, codigo do tipo de contrato
@param cTipoPla  , string	, codigo do tipo de planilha
@param cFilCtr	 , string	, filial do contrato
@param lRecursiva, lógico   , Indica se é chamada recursiva 

@return	xRet	, conteudo de uma propriedade da planilha

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Function CN300PlaSt( cProp, cTipoCtr, cTipoPla, cFilCTR, lRecursiva )
Local xRet:= NIL
Local lSeekCN1 	:= .F.
Local lSeekCNL 	:= .F.
Local cPropSeek	:= ""
Local cChave	:= ""
Local cFindId	:= ""
Default cFilCTR := cFilAnt
Default lRecursiva := .F.

cPropSeek	+= "FISICO|FIXO|EVENTUAL|MEDEVE|PREVFINANC|CONTABIL|SEMIFIXO|SEMIPROD|SEMIAGRUP|RECORRENTE|SERVIÇO|"
cPropSeek 	+= "ESPECIE|COMPRA|VENDA|"
cPropSeek 	+= "REVREAJU|REVREALI|"
cPropSeek 	+= "LMTFISICO|LMTFINANCEIRO|LMTMED|LMTMEDCONTRA|"
cPropSeek	+= "TPMULT|MULMAN|"
cPropSeek	+= "MEDAUTO|ALCMDDOC|ALCMDEC|"
cPropSeek	+= "ALCCTDOC|ALCCTEC|INTPIMS|MULTIMED"

cFindId := cProp+cTipoCtr+cTipoPla+cFilCTR

//-- Propriedades de Tipo de Contrato
If cProp $ cPropSeek
	If (_oPlaProps == Nil)
		_oPlaProps := THashMap():New()
	EndIf
	
	If _oPlaProps:Get(cFindId, @xRet)
		Return xRet
	EndIf
	
	//Se for chamada recursiva (chamada da própria CN300PlaSt), não faz o seek novamente, pois os registros já estarão posicionados 
	If lRecursiva
		lSeekCN1 := .T.
	Else
		cChave := FWxFilial("CN1",cFilCTR) + cTipoCtr
		If !(lSeekCN1 := (cChave == CN1->(CN1_FILIAL+CN1_CODIGO)))
			CN1->( dbSetOrder(1) ) //CN1_FILIAL+CN1_CODIGO+CN1_ESPCTR
			lSeekCN1 := CN1->( msSeek(cChave) )//-- Posicionado no Tipo de Contrato
		EndIf
	EndIf
	
	If lSeekCN1	
		If cProp == 'LMTMEDCONTRA'
			xRet := CN1->CN1_LMTMED
		ElseIf cProp == 'ESPECIE'
			xRet := CN1->CN1_ESPCTR
		ElseIf cProp == 'COMPRA'
			xRet := CN1->CN1_ESPCTR == '1'
		ElseIf cProp == 'VENDA'
			xRet := CN1->CN1_ESPCTR == '2'
		ElseIf cProp == 'ALCCTDOC'
			xRet :=  CN1->CN1_ALCCTR == "0" .OR. CN1->CN1_ALCCTR == "1"
		ElseIf cProp == 'ALCCTEC'
			xRet :=  CN1->CN1_ALCCTR == "0" .OR. CN1->CN1_ALCCTR == "2"
		ElseIf cProp == 'INTPIMS'  .And. CN1->(Columnpos('CN1_INTEGR')) > 0
			xRet := CN1->CN1_INTEGR
		ElseIf cProp == 'MULTIMED'  .And. CN1->(ColumnPos('CN1_SLDMED') > 0 )
			xRet := CN1->CN1_SLDMED == '2'
		Else			
			//Se for chamada recursiva (chamada da própria CN300PlaSt), não faz o seek novamente, pois os registros já estarão posicionados 
			If lRecursiva
				lSeekCNL := .T.
			Else
				cChave := FWxFilial("CNL",cFilCTR) + cTipoPla				
				If !(lSeekCNL := (cChave == CNL->( CNL_FILIAL+CNL_CODIGO )))					
					CNL->( dbSetOrder(1) ) //CNL_FILIAL+CNL_CODIGO
					lSeekCNL := CNL->( msSeek( cChave ) )//-- Posicionado no Tipo de Planilha
				EndIf				
			EndIf
			
			If lSeekCNL				
				If cProp == 'FISICO'
					If CNL->CNL_CROFIS == "0" .OR. Empty(CNL->CNL_CROFIS)
						xRet := CN1->CN1_CROFIS == "1"
					Else
						xRet := CNL->CNL_CROFIS == "1"
					Endif
				ElseIf cProp == 'FIXO'
					If CNL->CNL_CTRFIX == "0" .OR. Empty(CNL->CNL_CTRFIX)
						xRet := Empty(CN1->CN1_CTRFIX) .Or. (CN1->CN1_CTRFIX == "1")
					Else
						xRet := Empty(CNL->CNL_CTRFIX) .Or. (CNL->CNL_CTRFIX == "1")
					Endif
				ElseIf cProp == 'EVENTUAL'
					xRet := !CN300PlaSt('FIXO',cTipoCtr,cTipoPla,cFilCTR,.T.) .And. !CN300PlaSt('SEMIFIXO',cTipoCtr,cTipoPla,cFilCTR,.T.) .And. CN300PlaSt('MEDEVE',cTipoCtr,cTipoPla,cFilCTR,.T.)
				ElseIf cProp == 'MEDEVE'
					If CNL->CNL_MEDEVE == "0" .OR. Empty(CNL->CNL_MEDEVE)
						xRet := CN1->CN1_MEDEVE == "1"
					Else
						xRet := CNL->CNL_MEDEVE == "1"
					Endif
				ElseIf cProp == 'RECORRENTE'
					xRet := CNL->CNL_MEDEVE == "3"
				ElseIf cProp == 'PREVFINANC'
					If CNL->CNL_VLRPRV == "0" .OR. Empty(CNL->CNL_VLRPRV)
						xRet := Empty(CN1->CN1_VLRPRV) .Or. (CN1->CN1_VLRPRV == "1")
					Else
						xRet := Empty(CNL->CNL_VLRPRV) .Or. (CNL->CNL_VLRPRV == "1")
					Endif
				ElseIf cProp == 'CONTABIL'
					If CNL->CNL_CROCTB == "0" .OR. Empty(CNL->CNL_CROCTB)
						xRet := CN1->CN1_CROCTB == "1"
					Else
						xRet := CNL->CNL_CROCTB == "1"
					Endif
				ElseIf cProp == 'REVREAJU'
					If CNL->CNL_CREAJM == "0" .OR. Empty(CNL->CNL_CREAJM)
						xRet := CN1->CN1_CREAJM == "1"
					Else
						xRet := CNL->CNL_CREAJM == "1"
					Endif
				ElseIf cProp == 'REVREALI'
					If CNL->CNL_CRALM == "0" .OR. Empty(CNL->CNL_CRALM)
						xRet := CN1->CN1_CREALM == "1"
					Else
						xRet := CNL->CNL_CRALM == "1"
					Endif
				ElseIf cProp == 'MEDAUTO'
					If CNL->CNL_MEDAUT == "0" .OR. Empty(CNL->CNL_MEDAUT)
						xRet := CN1->CN1_MEDAUT == "1"
					Else
						xRet := CNL->CNL_MEDAUT == "1"
					Endif
				ElseIf cProp == 'TPMULT'					
					If CNL->CNL_TPMULT == "0" .OR. Empty(CNL->CNL_TPMULT)
						xRet := CN1->CN1_TPMULT
					Else
						xRet := CNL->CNL_TPMULT
					Endif
				ElseIf cProp == 'MULMAN'
					If CNL->CNL_MULMAN == "0" .OR. Empty(CNL->CNL_MULMAN)
						xRet := CN1->CN1_MULMAN
					Else
						xRet := CNL->CNL_MULMAN
					Endif
				ElseIf cProp == 'LMTFISICO'
					If CNL->CNL_TPLMT == "0" .OR. Empty(CNL->CNL_TPLMT)
						xRet := CN1->CN1_TPLMT == "2"
					Else
						xRet := CNL->CNL_TPLMT == "2"
					Endif
				ElseIf cProp == 'LMTFINANCEIRO'
					If CNL->CNL_TPLMT == "0" .OR. Empty(CNL->CNL_TPLMT)
						xRet := CN1->CN1_TPLMT == "1"
					Else
						xRet := CNL->CNL_TPLMT == "1"
					Endif
				ElseIf cProp == 'LMTMED'
					If CNL->CNL_TPLMT == "0" .OR. Empty(CNL->CNL_TPLMT)
						xRet := CN1->CN1_LMTMED
					Else
						xRet := CNL->CNL_LMTMED
					EndIf
				ElseIf cProp == 'SEMIFIXO'
					If CNL->CNL_CTRFIX == "0" .OR. EMPTY(CNL->CNL_CTRFIX)
						xRet := CN1->CN1_CTRFIX == "3"
					Else
						xRet := CNL->CNL_CTRFIX == "3"
					Endif
				ElseIf cProp == 'SEMIPROD'
					If CNL->CNL_CTRFIX == "0" .OR. EMPTY(CNL->CNL_TPSFIX)
						xRet := CN1->CN1_TPSFIX == "1"  .AND. CN1->CN1_CTRFIX == "3"
					Else
						xRet := CNL->CNL_TPSFIX == "1"  .AND. CNL->CNL_CTRFIX == "3"
					Endif
				ElseIf cProp == 'SEMIAGRUP'
					If CNL->CNL_CTRFIX == "0" .OR. EMPTY(CNL->CNL_TPSFIX)
						xRet := CN1->CN1_TPSFIX == "2"  .AND. CN1->CN1_CTRFIX == "3"
					Else
						xRet := CNL->CNL_TPSFIX == "2"  .AND. CNL->CNL_CTRFIX == "3"
					Endif
				ElseIf cProp == 'ALCMDDOC'
					xRet :=  CNL->CNL_ALCMED == "0" .OR. CNL->CNL_ALCMED == "1" .OR. EMPTY(CNL->CNL_ALCMED)
				ElseIf cProp == 'ALCMDEC'
					xRet :=  CNL->CNL_ALCMED == "0" .OR. CNL->CNL_ALCMED == "2" .OR. EMPTY(CNL->CNL_ALCMED)		
				ElseIf cProp == 'SERVIÇO'
					xRet :=  CNL->CNL_PLSERV == "1"		
				EndIf			
			EndIf						
		EndIf						
	EndIf

	_oPlaProps:Set(cFindId, xRet)
EndIf
Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CNTSetFun()
Aplica getID do modelo ativo.

@author Antenor Silva
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function CNTSetFun(cMod)
cModel	:= cMod
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CNTGetFun()
Recupera getID do modelo ativo.

@author Antenor Silva
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function CNTGetFun()
Return cModel

//-------------------------------------------------------------------
/*/{Protheus.doc} A300GTpRev()
Função para recuperar a variavel estatica cTipRevisa

@author alexandre.gimenez
@since 18/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function A300GTpRev()
Return cTipRevisa

//-------------------------------------------------------------------
/*/{Protheus.doc} A300STpRev()
Função para Atribuir na variavel estatica cTipRevisa

@author alexandre.gimenez
@since 18/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function A300STpRev(cValue)
cTipRevisa	:= cValue
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A300GATpRv()
Função para recuperar a variavel estatica cAprTipRev

@author alexandre.gimenez
@since 18/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function A300GATpRv()
Return cAprTipRev

//-------------------------------------------------------------------
/*/{Protheus.doc} A300SATpRv()
Função para Atribuir na variavel estatica cAprTipRev

@author alexandre.gimenez
@since 18/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function A300SATpRv(cValue)
cAprTipRev	:= cValue
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A300GRevis()
Função para recuperar a variavel estatica lRevisado

@author alexandre.gimenez
@since 18/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function A300GRevis()
Return lRevisado

//-------------------------------------------------------------------
/*/{Protheus.doc} A300SRevis()
Função para Atribuir na variavel estatica lRevisado

@author alexandre.gimenez
@since 18/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function A300SRevis(lValue)
lRevisado	:= lValue
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A300GUsrBt()
Função para recuperar a variavel estatica lUserBut

@author alexandre.gimenez
@since 18/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function A300GUsrBt()
Return lUserBut

//-------------------------------------------------------------------
/*/{Protheus.doc} A300SUsrBt()
Função para Atribuir na variavel estatica lUserBut

@author alexandre.gimenez
@since 18/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function A300SUsrBt(lValue)
lUserBut	:= lValue
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A300GLnCNF()
Função para recuperar a variavel estatica aLineCNF

@author alexandre.gimenez
@since 18/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function A300GLnCNF()
Return aLineCNF

//-------------------------------------------------------------------
/*/{Protheus.doc} A300SLnCNF()
Função para Atribuir na variavel estatica aLineCNF

@author alexandre.gimenez
@since 18/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function A300SLnCNF(xValue)
aAdd(aLineCNF,xValue)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A300SLnCNF()
Função para Limpar a variavel estatica aLineCNF

@author alexandre.gimenez
@since 18/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function A300CLnCNF()
aLineCNF	:= {}
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A300IsServs()
Função para verificar se o contrato foi gerado por gestão de Seviços

@author alexandre.gimenez
@since 18/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function A300IsServs()
Local lRet			:= .F.
Local aArea		:= GetArea()
Local oModel		:= FwModelActive()
Local oCN9Master:= Nil
Local lMdlAtivo	:= ValType(oModel) == 'O' .And. oModel:lActivate .And. oModel:GetId() == 'CNTA300'
Local cContra	:= ""
Local cRevisa	:= ""

If	lMdlAtivo .AND. oModel:GetID()<>"TECA740"
	oCN9Master := oModel:GetModel('CN9MASTER')
	cContra := oCN9Master:GetValue('CN9_NUMERO')
	cRevisa := oCN9Master:GetValue('CN9_REVISA')
Else
	cContra := CN9->CN9_NUMERO
	cRevisa := CN9->CN9_REVISA
Endif

DbSelectArea("TFJ")
TFJ->(DbSetOrder(5))
If TFJ->(dbSeek(xFilial("TFJ")+cContra+cRevisa))
	lRet := .T.
EndIf

RestArea(aArea)

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CN300SdDC()
Função que retorna o total a ser distribuido no cronograma Contabil

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function CN300SdDC(oModel, lDelete,nLine, nNValor)
Local oCNWDetail	:= oModel:GetModel('CNWDETAIL')
Local oCNVDetail	:= oModel:GetModel('CNVDETAIL')
Local oCNADetail	:= oModel:GetModel('CNADETAIL')
Local nSld			:= 0
Local nTotCrg		:= 0
Local nI			:= 0
Local aSaveLines	:= FWSaveRows()

Default nLine    := 0
Default lDelete  := Nil

oCNVDetail:SetNoInsertLine(.F.)
oCNVDetail:SetNoDeleteLine(.F.)

For nI := 1 To oCNWDetail:Length()
	oCNWDetail:GoLine(nI)

	If lDelete
		If oCNWDetail:GetLine() == nLine
			Loop
		EndIf
	EndIf
	If ValType(lDelete) == 'U'
		If oCNWDetail:GetLine() == nLine
			nTotCrg += nNValor
			Loop
		EndIf
	EndIf

	If !oCNWDetail:IsDeleted() .Or. (!lDelete .And.  oCNWDetail:GetLine() == nLine)
		nTotCrg += Round(oCNWDetail:GetValue('CNW_VLPREV'), TamSX3('CNW_VLPREV')[2])
	EndIf
Next nI

If !oCNVDetail:CanUpdateLine()
	oCNVDetail:SetNoUpdateLine(.F.)
EndIf

oCNVDetail:LoadValue('CNV_TOTCRG', nTotCrg)
nSld := NoRound((oCNADetail:GetValue('CNA_VLTOT') - nTotCrg), TamSX3('CNW_VLPREV')[2])
FWRestRows(aSaveLines)

oCNVDetail:SetNoInsertLine(.T.)
oCNVDetail:SetNoDeleteLine(.T.)

Return nSld

//------------------------------------------------------------------
/*/{Protheus.doc} CN300PVCNW()
Pre Valid do modelo CNW

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function CN300PVCNW(cAction, nLine, cField, xValue)
	Local oModel 	:= Nil
	Local oModelCNA	:= Nil
	Local aProp		:= {}

	If !Empty(cTipRevisa)
		oModel 		:= FwModelActive()
		oModelCNA	:= oModel:GetModel('CNADETAIL')
		aProp 		:= GetPropMdl(oModelCNA)

		CNTA300BlMd(oModelCNA,.F.)
		If cAction == 'SETVALUE'  .And. cField == 'CNW_VLPREV'
			oModelCNA:LoadValue('CNA_SADISC', CN300SdDC(oModel,		, nLine, xValue))
		ElseIf cAction == 'DELETE'
			oModelCNA:LoadValue('CNA_SADISC', CN300SdDC(oModel,.T. 	,nLine))
		ElseIf cAction == 'UNDELETE'
			oModelCNA:LoadValue('CNA_SADISC', CN300SdDC(oModel,.F. 	,nLine))
		EndIf
		
		RstPropMdl(oModelCNA,aProp)
		FwFreeArray(aProp)
	EndIf
Return .T.

//------------------------------------------------------------------
/*/{Protheus.doc} CN300PrCF()
Função que processa a inclusão dos cronogramas Fin\Fis

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function CN300PrCF(lFailMsg as logical)
	Local oModel 	:= FwModelActive()
	Local oCN9Master:= oModel:GetModel('CN9MASTER')
	Local lResult	:= .T.
	Default lFailMsg:= .F.

	If !Empty(cTipRevisa)
		If Empty(oCN9Master:GetValue('CN9_TIPREV'))
			Help('',1,'CNTA300OPN')
			lResult := .F.
		Else			
			A300OpenMd({||lResult := CN300AddCrg()}, .T.)
		EndIf
	ElseIf (lFailMsg)//Possibilitar obter as mensagens de erro		
		lResult := CtrExecMsg({|| CN300AddCrg() }, oModel, {"CN9MASTER", "CN9_NUMERO", "CN300PRCF"})
	Else
		lResult := CN300AddCrg()
	EndIf
Return lResult
//------------------------------------------------------------------
/*/{Protheus.doc} CN300PrcCC()
Função que processa a inclusão dos cronogramas Contabil

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function CN300PrcCC(lFailMsg as Logical)
	Local oModel 	:= FwModelActive()
	Local oCN9Master:= oModel:GetModel('CN9MASTER')
	Local lResult	:= .T.
	Local bExec		:= {||CN300AddCtb()}
	Default lFailMsg:= .F.

	If !Empty(cTipRevisa)
		If Empty(oCN9Master:GetValue('CN9_TIPREV'))
			Help('',1,'CNTA300OPN')
		Else
			A300OpenMd(bExec, .T.)
		EndIf
	ElseIf(lFailMsg)
		lResult := CtrExecMsg(bExec, oModel, {"CN9MASTER", "CN9_NUMERO", "CN300PRCCC"})
	Else
		Eval(bExec)	
	EndIf
Return lResult
//------------------------------------------------------------------
/*/{Protheus.doc} CN300PrcCrg()
Função permite ou não excluir um cronograma

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function CN300PeDCr()
Local lRet 	:= .F.
Local oModel	:= FwModelActive()

lRet := (!Empty(A300GTpRev()) .And. oModel:GetModel('CNADETAIL'):IsInserted()) .Or. Empty(A300GTpRev())

Return lRet

/*/{Protheus.doc} CN300VdCrg()
Função que efetua a validação das parcelas do cronograma Fis\Fin e Contábil
@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
Function CN300VdCrg(oModel, lIsAprovRV)
	Local oCNFDetail 	:= oModel:GetModel('CNFDETAIL')	
	Local oCNVDetail	:= Nil
	Local nI2			:= 0
	Local nDeleted		:= 0
	Local lRet			:= .T.
	Local aSavelines	:= FWSaveRows()
	Default lIsAprovRV	:= .F.

	nDeleted	:= 0
	For nI2 := 1 To oCNFDetail:Length()
		oCNFDetail:Goline(nI2)

		If oCNFDetail:IsDeleted()
			nDeleted++
		Else
			If lIsAprovRV				
				If (DeveVldCNF(oCNFDetail:GetDataId()))//Verifica se essa parcela deve ser validada
					lRet := CNVlDatFin(oCNFDetail:GetValue("CNF_DTVENC"))
				EndIf
			ElseIf !Empty(oCNFDetail:GetValue('CNF_PARCEL')).And. oCNFDetail:GetValue('CNF_VLPREV') == 0 .And. oCNFDetail:IsInserted() //Nao permite a inclusão de novas parcelas com valor zerado
				lRet := .F.
				Help('',1,'A300NCRON2',, STR0118 + AllTrim(oCNFDetail:GetValue('CNF_PARCEL'))  + STR0119; // "A parcela Financeira " - " da planilha "
				+ AllTrim(oCNFDetail:GetValue('CNF_NUMPLA')) +  STR0120,4) // " está com o valor zerado"
			EndIf
		EndIf

		If !lRet
			Exit
		EndIf
	Next nI2
	
	If lRet
		If (nDeleted == oCNFDetail:Length() .Or. (oCNFDetail:Length() == 1 .And. Empty(oCNFDetail:GetValue('CNF_PARCEL'))))//Valida se planilha possui cronograma financeiro
			lRet := .F.
			Help('',1,'A300NCRON',,STR0184 + oCNFDetail:GetValue('CNF_NUMPLA') + ' ' + STR0185,4)
		ElseIf lIsAprovRV
			lRet := CNVlDatFin(oModel:GetValue("CN9MASTER", "CN9_DTREV"))
		EndIf
	EndIf

	If lRet .And. !lIsAprovRV .And. Cn300RetSt("CONTABIL")
		oCNVDetail	:= oModel:GetModel('CNVDETAIL')	

		For nI2 := 1 To oCNVDetail:Length()
			oCNVDetail:GoLine(nI2)
			If !oCNVDetail:IsDeleted() .And. Empty(oCNVDetail:GetValue('CNV_NUMERO'))
				lRet := .F.
				Help(" ",1,"A300CRNCTB") //- Planilha sem cronograma contábil. Inclua o cronograma contábil nas planilhas configuradas para possuirem tal cronograma.
				Exit
			EndIf
		Next nI2
	EndIf

	FWRestRows(aSaveLines)
	FwFreeArray(aSaveLines)
Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CN300VlQMd(oModel)
Função que valida se a quantidade do produto não é menor do que a
quantidade já medida.

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function CN300VlQMd()
Local oModel		:= FwModelActive()
Local oCNBDetail 	:= oModel:GetModel('CNBDETAIL')
Local oCNFDetail 	:= oModel:GetModel('CNFDETAIL')
Local oCNSDetail 	:= oModel:GetModel('CNSDETAIL')
Local nI 			:= 0
Local nI2 			:= 0
Local nTotMed		:= 0
Local lRet 		:= .T.

If FWIsInCallStack("A300AtuCrF")
	For nI := 1 To oCNFDetail:Length()
		oCNFDetail:GoLine(nI)
		If !oCNFDetail:IsDeleted()
			For nI2 := 1 To oCNSDetail:Length()
				oCNSDetail:GoLine(nI2)
				If !oCNSDetail:IsDeleted()
					If oCNSDetail:GetValue('CNS_PRODUT') == oCNBDetail:GetValue('CNB_PRODUT')
						nTotMed := nTotMed + oCNSDetail:GetValue('CNS_RLZQTD')
					EndIf
				EndIf
			Next nI2
		EndIf
	Next nI

	If nTotMed > oCNBDetail:GetValue('CNB_QUANT')
		lRet := .F.
		Help('',1,'CNTA300QTM')
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CN300ExMed(oModel)
Função que verifica se a planilha posicionada possui medição

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function CN300ExMed(oModel)
Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oCNADetail	:= oModel:GetModel('CNADETAIL')
Local cContra		:= oCNADetail:GetValue("CNA_CONTRA")
Local cRevisa		:= oCNADetail:GetValue("CNA_REVISA")
Local cNumPla		:= oCNADetail:GetValue("CNA_NUMERO")
Local cQry120		:= ""
Local cQry121		:= ""
Local c120Med		:= ""
Local c121Med		:= ""
Local lRet 		:= .F.

cQry120 := "Select Distinct(CND.CND_NUMMED) FROM " + RetSQLName("CND") +" CND WHERE "
cQry120 += "CND.CND_FILIAL = '" +xFilial("CND") +"' AND "
cQry120 += "CND.CND_CONTRA = '"+ cContra +"' AND "
cQry120 += "CND.CND_REVISA = '"+ cRevisa +"' AND "
cQry120 += "CND.CND_NUMERO = '"+ cNumPla +"' AND "
cQry120 += "CND.CND_SITUAC = 'E' AND "
cQry120 += "CND.D_E_L_E_T_ = '' "

cQry120 := ChangeQuery(cQry120)
dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQry120 ),"CNDTRB",.F.,.T.)

c120Med := CNDTRB->(CND_NUMMED)

CNDTRB->(dbCloseArea())

cQry121 := "Select Distinct(CND.CND_NUMMED) From " + RetSQLName("CND") +" CND, " + RetSQLName("CXN")+ " CXN WHERE "
cQry121 += " CND.CND_FILIAL = '" +xFilial("CND") +"' AND "
cQry121 += " CND.CND_CONTRA = '"+ cContra +"' AND "
cQry121 += " CND.CND_REVISA = '"+ cRevisa +"' AND "
cQry121 += " CND.CND_SITUAC = 'E' AND "
cQry121 += " CND.D_E_L_E_T_ = ' ' AND "
cQry121 += " CXN.CXN_CHECK = 'T' AND "
cQry121 += " CXN.CXN_NUMPLA = '"+ cNumPla +"' AND "
cQry121 += " CXN.CXN_FILIAL = CND.CND_FILCTR AND "
cQry121 += " CXN.CXN_CONTRA = CND.CND_CONTRA AND "
cQry121 += " CXN.CXN_REVISA = CND.CND_REVISA AND "
cQry121 += " CXN.CXN_NUMMED = CND.CND_NUMMED AND "
cQry121 += " CXN.D_E_L_E_T_ = '' "

cQry121 := ChangeQuery(cQry121)
dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQry121 ),"CXNTRB",.F.,.T.)

c121Med := CXNTRB->(CND_NUMMED)

CXNTRB->(dbCloseArea())

If !Empty(c120Med) .Or. !Empty(c121Med)
			lRet := .T.
		EndIf

FWRestRows( aSaveLines )
RestArea(aArea)

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CN300CtrAdia()
Função que inicia o adiantamento


@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function CN300CtrAdia()

Local aArea	:= GetArea()

lAdiant := .T.

//ponto de entrada para permitir a execucao da tela do Adiantamento ou nao
If lAdiant .And. ExistBlock("CN100ADO")
	lRetAdo :=  ExecBlock("CN100ADO",.F.,.F.)
	If ValType( lRetAdo ) == "L"
		lAdiant := lRetAdo
	EndIf
EndIf

If lAdiant	
	FWExecView(STR0181, If(Cn300RetSt('COMPRA',,,,,.F.), "CNTA300", "CNTA301"), MODEL_OPERATION_UPDATE,, {|| .T.})	//"Adiantamentos"
EndIf

CN300Adiant()

RestArea(aArea)

Return

//------------------------------------------------------------------
/*/{Protheus.doc} A300IniAdi(oModel)
Função que inicia o adiantamento do contrato

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function A300IniAdi(oModel)
Local aModels 	:= MTGetAllMd({'CNXDETAIL'})
Local oView		:= FwViewActive()
Local oModelCN9	:= oModel:GetModel("CN9MASTER")
Local oModCNX	:= oModel:GetModel('CNXDETAIL')
Local oStruCNX	:= oModCNX:GetStruct()
Local cEspCtr	:= oModelCN9:GetValue('CN9_ESPCTR')

//-- Trata o When dos campos, para só liberar quando for linha nova.
oStruCNX:SetProperty('CNX_BANCO',MODEL_FIELD_WHEN,{||oModCNX:IsInserted()})
oStruCNX:SetProperty('CNX_BANCO',MODEL_FIELD_OBRIGAT, .T.) //Campo obrigatorio para não permitir a inclusão de adiantamento sem informar o banco/agência/conta
oStruCNX:SetProperty('CNX_AGENCI',MODEL_FIELD_WHEN,{||oModCNX:IsInserted()})
oStruCNX:SetProperty('CNX_AGENCI',MODEL_FIELD_OBRIGAT, .T.) //Campo obrigatorio para não permitir a inclusão de adiantamento sem informar o banco/agência/conta
oStruCNX:SetProperty('CNX_CONTA',MODEL_FIELD_WHEN,{||oModCNX:IsInserted()})
oStruCNX:SetProperty('CNX_CONTA',MODEL_FIELD_OBRIGAT, .T.) //Campo obrigatorio para não permitir a inclusão de adiantamento sem informar o banco/agência/conta


If cEspCtr == '1'
	oStruCNX:SetProperty('CNX_FORNEC',MODEL_FIELD_WHEN,{||oModCNX:IsInserted()})
	oStruCNX:SetProperty('CNX_LJFORN',MODEL_FIELD_WHEN,{||oModCNX:IsInserted()})
	oStruCNX:SetProperty('CNX_FORNEC',MODEL_FIELD_OBRIGAT, .T.)
	oStruCNX:SetProperty('CNX_LJFORN',MODEL_FIELD_OBRIGAT, .T.)
Else
	oStruCNX:SetProperty('CNX_CLIENT',MODEL_FIELD_WHEN,{||oModCNX:IsInserted()})
	oStruCNX:SetProperty('CNX_LOJACL',MODEL_FIELD_WHEN,{||oModCNX:IsInserted()})
	oStruCNX:SetProperty('CNX_CLIENT',MODEL_FIELD_OBRIGAT, .T.)
	oStruCNX:SetProperty('CNX_LOJACL',MODEL_FIELD_OBRIGAT, .T.)
EndIf

oStruCNX:SetProperty('CNX_VLADT',MODEL_FIELD_WHEN, {||oModCNX:IsInserted()})

MtBCMod(oModel,aModels,{||.F.})
CNTA300BlMd(oModCNX,.F.)

If	ValType(oView)=='O'	.And. oView:IsActive()
  oView:SelectFolder("FLDCNT",STR0027,2)
EndIf

//-- O iniciador padrão não atribui o valor a primeira linha
If Empty(oModCNX:GetValue('CNX_DTADT'))
	oModCNX:LoadValue('CNX_DTADT', dDataBase)
	If CNX->(Columnpos('CNX_REVGER')) > 0 .And. Empty(oModCNX:GetValue('CNX_REVGER'))
		oModCNX:LoadValue('CNX_REVGER',oModelCN9:GetValue('CN9_REVISA'))
	EndIf
EndIf
Return

//------------------------------------------------------------------
/*/{Protheus.doc} CN300PVCNX()
Pre Valid do modelo CNX

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function CN300PVCNX(oModel, cAction, nLine, cField, xValue, xOldValue)
	Local lRet	:= .T.
	Local aInfoBanco:= {}

	If (cAction == 'DELETE') 
		If (oModel:GetValue('CNX_SALDO') != oModel:GetValue('CNX_VLADT'))
			Help('',1,'CNTA300NAD')
			lRet := .F.
		Else
			aInfoBanco := {	oModel:GetValue('CNX_BANCO'),;
							oModel:GetValue('CNX_AGENCI'),;
							oModel:GetValue('CNX_CONTA')}
		EndIf
	ElseIf(cAction == 'SETVALUE' .And. cField $ 'CNX_BANCO|CNX_AGENCI|CNX_CONTA')
		aAdd(aInfoBanco, IIF(cField == 'CNX_BANCO'	, xValue, oModel:GetValue('CNX_BANCO')))	
		aAdd(aInfoBanco, IIF(cField == 'CNX_AGENCI'	, xValue, oModel:GetValue('CNX_AGENCI')))	
		aAdd(aInfoBanco, IIF(cField == 'CNX_CONTA'	, xValue, oModel:GetValue('CNX_CONTA')))
	EndIf

	If (lRet .And. Len(aInfoBanco) == 3)
		If (aScan(aInfoBanco, {|x| Empty(x) }) == 0)//Todos precisam estar preenchidos
			lRet := !(CCBlocked(aInfoBanco[1], aInfoBanco[2], aInfoBanco[3]))
			
			If !lRet
				Help(" ",1,"CN300BCBLK",,STR0311,1,0)
			EndIf
		EndIf
		FwFreeArray(aInfoBanco)
	EndIf
Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CN300VldBc(a, b, c, d)
Valid dos campos do Banco do adiantamento

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function CN300VldBc(a, b, c, d)
	Local aArea		:= GetArea()
	Local aAreaSA6	:= {}
	Local lRet 		:= .T.
	Local cCampo  	:= b
	Local cValor  	:= c
	Local oModel	:= Nil
	Local oModelCNX	:= Nil
	Local aInfoBanco:= {}
	Local cChave	:= ""
	Local nX		:= 0

	If (!Empty(cValor))
		oModel		:= FWModelActive()
		oModelCNX	:= oModel:GetModel("CNXDETAIL")

		aAdd(aInfoBanco, IIF(cCampo == 'CNX_BANCO'	, cValor, oModelCNX:GetValue('CNX_BANCO')))	
		aAdd(aInfoBanco, IIF(cCampo == 'CNX_AGENCI'	, cValor, oModelCNX:GetValue('CNX_AGENCI')))	
		aAdd(aInfoBanco, IIF(cCampo == 'CNX_CONTA'	, cValor, oModelCNX:GetValue('CNX_CONTA')))

		for nX := 1 to Len(aInfoBanco)
			If Empty(aInfoBanco[nX])
				Exit
			EndIf
			cChave += aInfoBanco[nX]
		next

		If !Empty(cChave)
			aAreaSA6 := SA6->(GetArea())
			SA6->(dbSetOrder(1))
			If !(lRet := ExistCpo("SA6",cChave))
				RestArea(aAreaSA6)
			EndIf
			FwFreeArray(aAreaSA6)
		EndIf
		FwFreeArray(aInfoBanco)
	EndIf
	RestArea(aArea)
	FwFreeArray(aArea)
Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CNGetAdiant()
Função para retornar o valor da variavel lAdiant

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function CNGetAdiant()
Return lAdiant

//------------------------------------------------------------------
/*/{Protheus.doc} CN300VldUsr()
Retorna array com boleanos validando o acesso do usuário

@author José Eulálio
@since 19/09/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function CN300VldUsr()
	Local lContinua	:= .T.
	Local cAliasQry	:= GetNextAlias()
	Local aArea		:= GetArea()
	Local cCod 		:= RetCodUsr()
	Local cGrps		:= ""
	Local cQuery    := ""
	Local aGrp		:= FWSFUsrGrps(cCod)
	Local nX        := 0
	Local aParams	:= {}

	//Seta a primeira posição// .T. = Controle Total // .F. = Verifica os Acessos do usuário
	// Posições do Array
	//	[1]	Controle Total
	//	[2]	Cauções
	//	[3]	Planilhas
	//	[4]	Cronogramas
	//	[5]	Documentos
	//	[6]	Medições
	//	[7]	Contrato Visualizar
	//	[8]	Controle de Acesso
	//	[n][1] Controle Total
	//	[n][2] Inclusão
	//	[n][3] Edição
	//	[n][4] Exclusão
	//	[n][5] Visualização
	//	[n][n][1] Código da Transação
	//	[n][n][2] Lógico com a Permissão

	aVldUsr		:= {.F.}
	dbSelectArea("CNN")
	CNN->(dbSetOrder(1))

	//Verifica se o contrato tem controle total
	If lContinua := (Empty(CN9->CN9_VLDCTR) .Or. CN9->CN9_VLDCTR == "1")
		//Verifica se o usuário tem controle total
		aVldUsr := {CNN->(DbSeek(xFilial("CNN")+cCod+CN9->CN9_NUMERO+"001"))} //CNN_FILIAL+CNN_USRCOD+CNN_CONTRA+CNN_TRACOD

		If !(aVldUsr[1])  //- Valida se grupo do usuário possui controle total
			CNN->(dbSetOrder(2))
			For nX:=1 to len(aGrp)
				aVldUsr[1] := aVldUsr[1] .Or. CNN->(MsSeek(xFilial("CNN")+aGrp[nX]+CN9->CN9_NUMERO+"001")) //CNN_FILIAL+CNN_GRPCOD+CNN_CONTRA+CNN_TRACOD
			Next nX
		EndIf

		//a primeria posição do Array representa o controle total
		lContinua := 	!(aVldUsr[1])
	Else
		aVldUsr		:= {.T.}
	EndIf

	If lContinua

		//Adiciona a segunda posição do Array
		For nX := 1 to 7
			aADD(aVldUsr,{})
		Next

		//³ Carrega Grupos do usuario
		aGrp := FWSFUsrGrps(cCod)

		For nX:=1 to len(aGrp)
			cGrps += "'"+aGrp[nX]+"',"
		Next
		If len(aGrp) > 0
			cGrps := SubStr(cGrps,1,len(cGrps)-1)
		EndIf

		//QUERY com a amarração entre usuário/grupo x contrato
		cQuery := "SELECT CNO.CNO_FILIAL, CNO.CNO_CODTRA, CNO.CNO_DESCRI, CNO.CNO_CODPAI, "
		cQuery += "(SELECT '.T.' FROM " + RetSQLName("CNN")
		cQuery += " WHERE (CNN_USRCOD = '" + cCod + "' "
		If len(aGrp) > 0
			cQuery += " OR CNN_GRPCOD IN ("+ cGrps +") "
		EndIf
		cQuery += ") AND CNN_TRACOD = CNO.CNO_CODTRA AND"
		cQuery += " CNN_CONTRA = ? AND"
		cQuery += " D_E_L_E_T_ = '' "
		cQuery += " GROUP BY CNN_CONTRA) PERMISSAO "
		cQuery += " FROM 	" + RetSQLName("CNO") + " CNO"

		cQuery := ChangeQuery(cQuery)

		aAdd(aParams, CN9->CN9_NUMERO)//Cenários que há expressões sql no número do contrato(exemplo: UNION)
		dbUseArea(.T.,"TOPCONN",TcGenQry2(,,cQuery,aParams),cAliasQry,.F.,.T.)

		While !( (cAliasQry)->(Eof()) )
			If (cAliasQry)->CNO_CODTRA $ "002|003|004|005|031"
				aAdd(aVldUsr[2],{(cAliasQry)->CNO_CODTRA,IIF(AllTrim((cAliasQry)->PERMISSAO)==".T.",.T.,.F.)})
			ElseIf (cAliasQry)->CNO_CODTRA $ "006|007|008|009|032"
				aAdd(aVldUsr[3],{(cAliasQry)->CNO_CODTRA,IIF(AllTrim((cAliasQry)->PERMISSAO)==".T.",.T.,.F.)})
			ElseIf (cAliasQry)->CNO_CODTRA $ "010|011|012|013|033"
				aAdd(aVldUsr[4],{(cAliasQry)->CNO_CODTRA,IIF(AllTrim((cAliasQry)->PERMISSAO)==".T.",.T.,.F.)})
			ElseIf (cAliasQry)->CNO_CODTRA $ "014|015|016|017|034|038"
				aAdd(aVldUsr[5],{(cAliasQry)->CNO_CODTRA,IIF(AllTrim((cAliasQry)->PERMISSAO)==".T.",.T.,.F.)})
			ElseIf (cAliasQry)->CNO_CODTRA $ "020|021|022|023|024|025|035"
				aAdd(aVldUsr[6],{(cAliasQry)->CNO_CODTRA,IIF(AllTrim((cAliasQry)->PERMISSAO)==".T.",.T.,.F.)})
			ElseIf (cAliasQry)->CNO_CODTRA $ "037|039|047"
				aAdd(aVldUsr[7],{(cAliasQry)->CNO_CODTRA,IIF(AllTrim((cAliasQry)->PERMISSAO)==".T.",.T.,.F.)})
			ElseIf (cAliasQry)->CNO_CODTRA $ "041"
				aAdd(aVldUsr[8],{(cAliasQry)->CNO_CODTRA,IIF(AllTrim((cAliasQry)->PERMISSAO)==".T.",.T.,.F.)})
			EndIf

			(cAliasQry)->(DbSkip())
		End
		(cAliasQry)->(dbCloseArea())
	EndIf

	RestArea(aArea)

	FwFreeArray(aArea)
	FwFreeArray(aParams)
Return aVldUsr

//------------------------------------------------------------------
/*/{Protheus.doc} CN300VisAC()
Atualiza do Array de acordo com o Acesso do usuário

@author José Eulálio
@since 23/09/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function CN300VisAc()
Local nX		:= 0
Local nY		:= 0
Local aVisuAc	:= {}

//Inicializa o Array com 4 posições falsas [1]Caucao [2]Planilha [3]Cronogramas [4]Documentos
For nX	:= 1 to 4
	aAdd(aVisuAC,.F.)
Next

//Atualiza do Array de acordo com o Acesso do usuário
For nX := 2 to Len(aVldUsr)
	If aVldUsr[nX,1,2] == .T.
		Do Case
			Case nX == 2
				aVisuAc[1] := .T. //'CN8','CNI'
			Case nX == 3
				aVisuAc[2] := .T. //'CNA','CNB','CNZ'
			Case nX == 4
				aVisuAc[3] := .T. //'CNF','CNS','CNV','CNW'
			Case nX == 5
				aVisuAc[4] := .T. //'CNK'
		EndCase
	Else
		For nY := 1 to Len(aVldUsr[nX])
			If aVldUsr[nX][nY][2] == .T.
				Do Case
					Case nX == 2
						aVisuAc[1] := .T. //'CN8','CNI'
					Case nX == 3
						aVisuAc[2] := .T. //'CNA','CNB','CNZ'
					Case nX == 4
						aVisuAc[3] := .T. //'CNF','CNS','CNV','CNW'
					Case nX == 5
						aVisuAc[4] := .T. //'CNK'
				EndCase
			EndIf
		Next
	EndIf

Next

Return aVisuAc

//------------------------------------------------------------------
/*/{Protheus.doc} CN300ModAC()
Atualiza do Array de acordo com o Acesso do usuário

@author José Eulálio
@since 24/09/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function CN300ModAC(oModel)
Local nX	:= 0
Local nY	:= 0
Local lRet	:= .T.

//Bloqueia os modelos que o usuário não tem permissão
For nx := 2 to Len(aVldUsr)
	If aVldUsr[nX,1,2] == .F.
		For nY := 1 to Len(aVldUsr[nX])
			If aVldUsr[nX][nY][2] == .F.
				Do Case
					Case nX == 2 //Caucao
						If	aVldUsr[nX][nY][1] == DEF_CAU_INC
							oModel:GetModel( "CN8DETAIL"):SetNoInsertLine( .T. )
							oModel:GetModel( "CNIDETAIL"):SetNoInsertLine( .T. )
							oModel:GetModel( "CNTDETAIL"):SetNoInsertLine( .T. )
						ElseIf	aVldUsr[nX][nY][1] == DEF_CAU_EDT
							oModel:GetModel( "CNIDETAIL"):SetNoUpdateLine( .T. )
							oModel:GetModel( "CN8DETAIL"):SetNoUpdateLine( .T. )
							oModel:GetModel( "CNTDETAIL"):SetNoUpdateLine( .T. )
						ElseIf	aVldUsr[nX][nY][1] == DEF_CAU_EXC
							oModel:GetModel( "CN8DETAIL"):SetNoDeleteLine( .T. )
							oModel:GetModel( "CNIDETAIL"):SetNoDeleteLine( .T. )
							oModel:GetModel( "CNTDETAIL"):SetNoDeleteLine( .T. )
						EndIf
					Case nX == 3 //Planilha
						If	aVldUsr[nX][nY][1] == DEF_PLA_INC
							oModel:GetModel( "CNADETAIL"):SetNoInsertLine( .T. )
							oModel:GetModel( "CNBDETAIL"):SetNoInsertLine( .T. )
							oModel:GetModel( "CNZDETAIL"):SetNoInsertLine( .T. )
							//cronograma
							oModel:GetModel( "CNFDETAIL"):SetNoInsertLine( .T. )
							oModel:GetModel( "CNSDETAIL"):SetNoInsertLine( .T. )
							oModel:GetModel( "CNVDETAIL"):SetNoInsertLine( .T. )
							oModel:GetModel( "CNWDETAIL"):SetNoInsertLine( .T. )
						ElseIf	aVldUsr[nX][nY][1] == DEF_PLA_EDT
							oModel:GetModel( "CNADETAIL"):SetNoUpdateLine( .T. )
							oModel:GetModel( "CNBDETAIL"):SetNoUpdateLine( .T. )
							oModel:GetModel( "CNZDETAIL"):SetNoUpdateLine( .T. )
							//cronograma
							oModel:GetModel( "CNFDETAIL"):SetNoUpdateLine( .T. )
							oModel:GetModel( "CNSDETAIL"):SetNoUpdateLine( .T. )
							oModel:GetModel( "CNVDETAIL"):SetNoUpdateLine( .T. )
							oModel:GetModel( "CNWDETAIL"):SetNoUpdateLine( .T. )
						ElseIf	aVldUsr[nX][nY][1] == DEF_PLA_EXC
							oModel:GetModel( "CNADETAIL"):SetNoDeleteLine( .T. )
							oModel:GetModel( "CNBDETAIL"):SetNoDeleteLine( .T. )
							oModel:GetModel( "CNZDETAIL"):SetNoDeleteLine( .T. )
							//cronograma
							oModel:GetModel( "CNFDETAIL"):SetNoDeleteLine( .T. )
							oModel:GetModel( "CNSDETAIL"):SetNoDeleteLine( .T. )
							oModel:GetModel( "CNVDETAIL"):SetNoDeleteLine( .T. )
							oModel:GetModel( "CNWDETAIL"):SetNoDeleteLine( .T. )
						EndIf
					Case nX == 5 //Documentos
						If aVldUsr[nX][nY][1] == DEF_DOC_INC
							oModel:GetModel( "CNKDETAIL"):SetNoInsertLine( .T. )
						ElseIf aVldUsr[nX][nY][1] == DEF_DOC_EDT
							oModel:GetModel( "CNKDETAIL"):SetNoUpdateLine( .T. )
						ElseIf aVldUsr[nX][nY][1] == DEF_DOC_EXC
							oModel:GetModel( "CNKDETAIL"):SetNoDeleteLine( .T. )
						EndIf
				EndCase
			EndIf
		Next
	EndIf
Next

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CNGetVldUsr()
Função para retornar o valor da variavel aVldUsr

@author José Eulálio
@since 25/09/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function CNGetVldUsr()

Return aVldUsr

//------------------------------------------------------------------
/*/{Protheus.doc} CN300VlCtr()
Validação do campo CN9_VLDCTR

@author José Eulálio
@since 30/09/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function CN300VlCtr()
Local lRet 		:= .F.
Local lContinual:= .T.
Local oModel 	:= FwModelActive()
Local lWarning	:= (oModel:GetId() $ 'CNTA300|CNTA301') .And. oModel:IsActive() .And. oModel:GetValue('CN9MASTER','CN9_VLDCTR') == '2'

If !INCLUI .And. !(aVldUsr[1])
	If !(aVldUsr[8][1][2])
		Help('',1,'CNTA300USR')//O usuário atual não tem permissão para alterar o valor deste campo // Contate o Administrador deste contrato
	EndIf
Else
	lRet := .T.
EndIf

//Ao selecionar esta opção, não será possível realizar medições em filiais que não sejam a originadora do contrato. Deseja continuar?
If !IsBlind() .And. lWarning
	lContinual := MsgYesNo(STR0176,STR0177)
EndIf

If lRet .And. lWarning .And. !lContinual
	oModel:LoadValue('CN9MASTER','CN9_VLDCTR','1')
	lRet := .F.
EndIf

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CNT300SATA()
Retorna a query populada com as informações dos produtos e licitantes para gerar o contrato.
Funcao utilizada na integracao com o modulo SIGAGCP

@author taniel.silva
@since 03/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function CNT300SATA(cAliasCO2,lLote,cCodEdt,cNumPro,cRevisa,cCodFor,cLoja,cLote)
	Local cReman		:= ""
	Local cRelacao	:= ""
	Local cQuant	:= ""
	Local cPrcUn	:= ""
	Local cFator	:= "CASE WHEN CO3.CO3_PERCEN > 0 THEN (CO3.CO3_PERCEN / 100) WHEN CO3.CO3_PERCEN = 0 THEN (1) END"
	Local cPercen	:= "%%"
	local lPosHMCO2		:= CO2->(FieldPos("CO2_HOMOLO")) > 0
	local lPosDOCO2		:= CO2->(FieldPos("CO2_DOCOK")) > 0
	Local cWhere	:= IIf(lPosHMCO2 .And. lPosDOCO2, "% AND CO2.CO2_HOMOLO = 'T' AND CO2.CO2_DOCOK = 'F' %", "%%")

	If lLote
		cRelacao := '% AND CO2.CO2_LOTE = CO3.CO3_LOTE%'
	Else
		cRelacao := '% AND CO2.CO2_CODPRO = CO3.CO3_CODPRO%'
		cLote     := '%(' + "'" + CriaVar('CO2_LOTE', .F.) +  "'" + ')%'
	EndIf

	cQuant := " CO2.CO2_QUANT * " + cFator + " CO2_QUANT"
	cPrcUn := " CASE WHEN CO3.CO3_PERCEN > 0 AND CO3.CO3_PERCEN <= 25 THEN CP6.CP6_PRCUN2 WHEN CO3.CO3_PERCEN <> 25 THEN CP6.CP6_PRCUN END CP6_PRCUN "
	cPercen := "% ,CO3.CO3_PERCEN %"
	cQuant := '%'+cQuant+'%'
	cPrcUn := '%'+cPrcUn+'%'

	If CO1->CO1_REMAN
		cReman := 	" AND CO2.CO2_REMAN = 'T'"
	EndIf
	cReman := '%'+cReman+'%'

	BeginSQL Alias cAliasCO2

	SELECT CO2.CO2_CODPRO, SB1.B1_UM, CO2.CO2_QUANT, CO3.CO3_VLUNIT, CO2.CO2_ITEM, %exp:cPrcUn%, CO3.CO3_LOTE , CO3.R_E_C_N_O_ AS RECCO3,SB5.B5_TIPO %exp:cPercen%
		FROM %table:CO2% CO2

			INNER JOIN %table:SB1% SB1 ON (SB1.B1_FILIAL = %xFilial:SB1% AND CO2.CO2_CODPRO = SB1.B1_COD AND SB1.%NotDel%)
											

			INNER JOIN %table:CO3% CO3 ON (CO2.CO2_FILIAL      = CO3.CO3_FILIAL
											AND CO2.CO2_CODEDT = CO3.CO3_CODEDT
											AND CO2.CO2_NUMPRO = CO3.CO3_NUMPRO
											AND CO2.CO2_REVISA = CO3.CO3_REVISA
											AND CO3.%NotDel%
											%exp:cRelacao%)

			LEFT JOIN %table:CP6% CP6  ON (		CP6.CP6_FILIAL	= CO3.CO3_FILIAL
											AND CP6.CP6_CODEDT	= CO3.CO3_CODEDT
											AND CP6.CP6_NUMPRO	= CO3.CO3_NUMPRO
											AND CP6.CP6_REVISA	= CO3.CO3_REVISA
											AND CP6.CP6_LOTE	= CO3.CO3_LOTE
											AND CP6.CP6_CODPRO	= CO2.CO2_CODPRO
											AND CP6.CP6_CODIGO	= CO3.CO3_CODIGO
											AND CP6.CP6_LOJA	= CO3.CO3_LOJA
											AND CP6.%NotDel%)
			LEFT JOIN %table:SB5% SB5  ON(SB5.B5_FILIAL = %xFilial:SB5% 
											AND SB5.B5_COD = SB1.B1_COD 
											AND SB5.%NotDel%)
			INNER JOIN %table:CO1% CO1 ON(CO2.CO2_FILIAL = CO1.CO1_FILIAL 
											AND CO2.CO2_CODEDT = CO1.CO1_CODEDT 
											AND CO2.CO2_NUMPRO = CO1.CO1_NUMPRO 
											AND CO2.CO2_REVISA = CO1.CO1_REVISA 
											AND CO1.%NotDel%)
		WHERE CO2.CO2_FILIAL  = %xfilial:CO2%
			AND CO2.CO2_CODEDT = %exp:cCodEdt%
			AND CO2.CO2_NUMPRO = %exp:cNumPro%
			AND CO2.CO2_REVISA = %exp:cRevisa%
			AND CO3.CO3_CODIGO = %exp:cCodFor%
			AND CO3.CO3_LOJA   = %exp:cLoja%
			AND (CO3.CO3_STATUS = '5' OR (CO3.CO3_STATUS = '1' AND CO1.CO1_MODALI = 'CR'))
			%exp:cWhere%
			AND CO2.CO2_LOTE   IN %exp:cLote%
			AND CO2.%NotDel%
			%exp:cReman%
			AND NOT EXISTS (SELECT 1 FROM %table:CP4% CP4 WHERE CP4.CP4_FILIAL = CO2.CO2_FILIAL
														AND CP4.CP4_CODEDT   = CO2.CO2_CODEDT
														AND CP4.CP4_CODPRO   = CO2.CO2_CODPRO
														AND CP4.CP4_REVISA   = CO2.CO2_REVISA
														AND CP4.CP4_NUMPRO   = CO2.CO2_NUMPRO
														AND CP4.CP4_LOTE     IN %exp:cLote%
														AND CP4.%NotDel%)
														ORDER BY SB5.B5_TIPO
	EndSql

Return nil

//------------------------------------------------------------------
/*/{Protheus.doc} CNT300CATA()
Retorna a query populada com as informações dos produtos e licitantes para gerar o contrato a partir da ATA.
Funcao utilizada na integracao com o modulo SIGAGCP

@author taniel.silva
@since 03/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function CNT300CATA(cAliasCO2,cNumAta,cCodFor,cLoja,cCodEdt,aRecNoCPE,cFilOrig)
Local cReman		:= ""
Local cRelacao	:= ""
Local cRecNos		:= ""
Local cCTBEnt		:= ""
Local cCTBEntAux	:= ""
Local cFilSC1		:= ""
Local nI			:= 0
Local nPos			:= 0
Local cExpRec		:= ""
Local cFilCPY		:= ""
Local cInnerCPI		:= ""
Local cInnerCX3		:= ""
Local lLote		:= GCP301Lote(cNumAta)
Local aCTBEnt 	:= CtbEntArr()
Local lGerCent	:= SuperGetMV("MV_GCPFIAP", .T., "C") == "C"

Default cFilOrig	:= cFilAnt

cFilCPY := xFilial("CPY",cFilOrig)
cFilSC1 := xFilial("SC1",cFilOrig)

For nI := 1 To Len(aRecNoCPE)
	cRecNos +=  "'" + AllTrim(Str(aRecNoCPE[nI,1])) + "'" + Iif( (nI < Len(aRecNoCPE)), ",", "")
Next nI

cExpRec := "%("+ cRecNos + ")%"

//-- Adiciona campos das novas entidades contabeis
For nPos := 1 To Len(aCTBEnt)
	If SC1->(FieldPos("C1_EC" +aCTBEnt[nPos] +"CR")) > 0
		cCTBEnt 	 += ", ISNULL(SC1.C1_EC" + aCTBEnt[nPos] + "CR,'') C1_EC" + aCTBEnt[nPos] +"CR "
		cCTBEnt 	 += ", ISNULL(SC1.C1_EC" + aCTBEnt[nPos] + "DB,'') C1_EC" + aCTBEnt[nPos] +"DB "
		cCTBEntAux	 += ", ISNULL(SC1.C1_EC" + aCTBEnt[nPos] + "CR,'') "
		cCTBEntAux	 += ", ISNULL(SC1.C1_EC" + aCTBEnt[nPos] + "DB,'') "
	EndIf
Next nPos

cCTBEnt := '%'+cCTBEnt+'%'
cCTBEntAux := '%'+cCTBEntAux+'%'

CO1->(DbSetOrder(1))

If lLote
	cRelacao := '% AND CPY.CPY_LOTE = CPZ.CPZ_LOTE%'
Else
	cRelacao := '% AND CPY.CPY_CODPRO = CPZ.CPZ_CODPRO%'
EndIf

If CO1->CO1_REMAN
	cReman := 	" AND CPY.CPY_REMAN = 'T'"
EndIf
cReman := '%'+cReman+'%'

If (!lGerCent)
	cInnerCPI := "INNER JOIN " + RetSQLName("CPI") + " CPI "
	cInnerCPI += "ON CPI.CPI_FILIAL = CPE.CPE_FILIAL "
	cInnerCPI += "AND CPI.CPI_CODEDT = CPE.CPE_CODEDT "
	cInnerCPI += "AND CPI.CPI_NUMPRO = CPE.CPE_NUMPRO "
	cInnerCPI += "AND CPI.CPI_CODORG = CPE.CPE_CODORG "
	cInnerCPI += "AND CPI.CPI_TIPO = CPE.CPE_TIPO "
	cInnerCPI += "AND CPI.CPI_CODPRO = CPE.CPE_CODPRO "
	cInnerCPI += "AND CPI.CPI_LOTE = CPE.CPE_LOTE "
	cInnerCPI += "AND CPI.D_E_L_E_T_ = ' '"
		
	cInnerCX3 := "AND CX3.CX3_FILENT = (CASE WHEN (SELECT COUNT(1) FROM "+RetSQLName("CX3") +" CX3B WHERE CX3B.CX3_FILIAL = CPE.CPE_FILIAL "
	cInnerCX3 += "AND CX3B.CX3_NUMATA = CPE.CPE_NUMATA "
	cInnerCX3 += "AND CX3B.CX3_CODPRO = CPE.CPE_CODPRO "
	cInnerCX3 += "AND CX3B.CX3_LOTE = CPY.CPY_LOTE "
	cInnerCX3 += "AND CX3B.CX3_NUMSC = (CASE WHEN CPE_NUMSC <> '' THEN CPE_NUMSC ELSE CX3B.CX3_NUMSC END)"
	cInnerCX3 += "AND CX3B.CX3_ITEMSC = (CASE WHEN CPE_ITEMSC <> '' THEN CPE_ITEMSC ELSE CX3B.CX3_ITEMSC END) "
	cInnerCX3 += "AND CX3B.CX3_FILENT = CPI.CPI_FILENT) > 0 THEN CPI.CPI_FILENT ELSE CX3.CX3_FILENT END)"
EndIf
cInnerCPI := "%" + cInnerCPI + "%"
cInnerCX3 := "%" + cInnerCX3 + "%"

BeginSQL Alias cAliasCO2
	SELECT CPY.CPY_CODPRO, 
			SB1.B1_UM, 
			CPE.CPE_CODORG, 
			CPE.CPE_NUMATA, 
			CPE.CPE_ITEM, 
			SUM(CPE.CPE_QUANT) CPE_QUANT, 
			CPY.CPY_VALATU, 
			CPY.CPY_ITEM,
			COALESCE(CX3.CX3_CODNE,'') CX3_CODNE,
			COALESCE(CX3.CX3_ITEMNE,'') CX3_ITEMNE,
			COALESCE(CX3.CX3_NUMSC,'') CX3_NUMSC,
			COALESCE(CX3.CX3_ITEMSC,'') CX3_ITEMSC,
			COALESCE(SC1.C1_RATEIO,'') C1_RATEIO,
			CPY.CPY_LOTE,
			COALESCE(SC1.C1_CC,'') C1_CC,
			COALESCE(SC1.C1_CLVL,'') C1_CLVL,
			COALESCE(SC1.C1_CONTA,'') C1_CONTA,
			COALESCE(SC1.C1_ITEMCTA,'') C1_ITEMCTA %Exp:cCTBEnt%, 
			COALESCE(SB5.B5_TIPO,'') B5_TIPO
	FROM 	%Table:CPY% CPY
	INNER JOIN %Table:SB1% SB1
	ON		SB1.B1_FILIAL = %xFilial:SB1%
			AND CPY.CPY_CODPRO = SB1.B1_COD
	INNER JOIN %Table:CPZ% CPZ
	ON 		CPY.CPY_FILIAL = CPZ.CPZ_FILIAL
			AND CPY.CPY_NUMATA = CPZ.CPZ_NUMATA
			%Exp:cRelacao%
	INNER JOIN %Table:CPH% CPH 
	ON 		CPH.CPH_FILIAL = CPZ.CPZ_FILIAL
			AND CPH.CPH_NUMATA = CPZ.CPZ_NUMATA
	INNER JOIN %Table:CPE% CPE 
	ON		CPE.CPE_FILIAL = CPZ.CPZ_FILIAL
			AND CPE.CPE_NUMATA = CPZ.CPZ_NUMATA
			AND CPE.CPE_CODPRO = CPY.CPY_CODPRO
			AND CPE.CPE_LOTE = CPY.CPY_LOTE							  
	%Exp:cInnerCPI%
	LEFT JOIN %Table:CX3% CX3 
	ON		CX3.CX3_FILIAL = CPE.CPE_FILIAL
			AND CX3.CX3_NUMATA = CPE.CPE_NUMATA
			AND CX3.CX3_CODPRO = CPE.CPE_CODPRO
			AND CX3.CX3_LOTE = CPY.CPY_LOTE
			AND CX3_NUMSC = (CASE WHEN CPE_NUMSC <> '' THEN CPE_NUMSC ELSE CX3_NUMSC END)
			AND CX3_ITEMSC = (CASE WHEN CPE_ITEMSC <> '' THEN CPE_ITEMSC ELSE CX3_ITEMSC END)
			%Exp:cInnerCX3%
			AND CX3.%NotDel%	
	LEFT JOIN %table:SC1% SC1 
	ON		SC1.C1_FILIAL = %Exp:cFilSC1%
			AND CX3.CX3_NUMSC  = SC1.C1_NUM
			AND CX3.CX3_ITEMSC = SC1.C1_ITEM
			AND SC1.%NotDel%							    	  
	LEFT JOIN %Table:SB5% SB5  
	ON  	SB5.B5_FILIAL = %xFilial:SB5% 
			AND SB5.B5_COD = SB1.B1_COD 
			AND SB5.%NotDel% 				    	  
	WHERE 	CPY.CPY_FILIAL  = %Exp:cFilCPY%
			AND CPY.CPY_NUMATA = %Exp:cNumAta%
			AND CPZ.CPZ_CODIGO = %Exp:cCodFor%
			AND CPZ.CPZ_LOJA   = %Exp:cLoja%
			AND CPZ.CPZ_STATUS = '5'
			AND CPE.R_E_C_N_O_ IN %Exp:cExpRec%
			AND CPY.%NotDel%
			AND SB1.%NotDel%
			AND CPY.%NotDel%
			AND CPE.%NotDel%
			%Exp:cReman%
	GROUP BY		
			CPY.CPY_CODPRO,
			SB1.B1_UM,
			CPE.CPE_CODORG, 
			CPE.CPE_NUMATA, 
			CPE.CPE_ITEM, 
			CPY.CPY_VALATU,
			CPY.CPY_ITEM,
			CX3.CX3_CODNE,
			CX3.CX3_ITEMNE,
			CX3.CX3_NUMSC,
			CX3.CX3_ITEMSC,
			SC1.C1_RATEIO,
			CPY.CPY_LOTE,
			SC1.C1_CC,
			SC1.C1_CLVL,
			SC1.C1_CONTA,
			SC1.C1_ITEMCTA %Exp:cCTBEntAux%,
			SB5.B5_TIPO
	ORDER BY
			SB5.B5_TIPO	
EndSql

Return nil

//------------------------------------------------------------------
/*/{Protheus.doc} A300LibNTE()
Verifica a liberação dos campos da nota de empenho na CNB.

@author taniel.silva
@since 03/03/2015
@version P12
@Return lRet
/*/
//-------------------------------------------------------------------
Function A300LibNTE()
Local lRet := .T.
Local lNotaEmp	:= SuperGetMV("MV_NOTAEMP",.F.,.F.)

If !lNotaEmp .Or. (!Empty(FwFldGet('CN9_CODED')) .And. !Empty(FwFldGet('CN9_NUMPR')))
	lRet := .F.
EndIf

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} A300PCOVLD()
Efetua integração com PCO

@author Leonardo Quintania
@since 03/03/2015
@version P12
@Return lRet
/*/
//-------------------------------------------------------------------
Function A300PCOVld(oModel,cCodLan,cItemLan,cProgram,lVldLinGrd, lIniLan, lFinLan)
Local aArea		:= GetArea()
Local lRet		:= .T.
Local lExclui	:= oModel:GetOperation() == MODEL_OPERATION_DELETE
Private cCadastro := STR0076	// "Manutencao de Contratos"
Default lVldLinGrd := .F.
Default lIniLan	:= .T.
Default lFinLan	:= .T.

If !lExclui
	If lIniLan		
		PcoIniLan("000354") //-- Planilha de Contrato - SIGAGCT
		PcoIniLan("000357") //-- Cronograma Financeiro
	EndIf
	
	lRet := PcoVldLan(cCodLan,cItemLan,cProgram,,,lVldLinGrd)	

	If lFinLan
		PcoFinLan("000357")
		PcoFinLan("000354")		
	Endif
EndIf

RestArea(aArea)

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} A300PCOINT()
Efetua integração com PCO

@author Leonardo Quintania
@since 03/03/2015
@version P12
@Return lRet
/*/
//-------------------------------------------------------------------
Function A300PCOINT(oModel,cTipRevisa,cAprTipRev,cNumero,cRevisa,cSitu,lExclui,lDelCrg)
Local aArea		:= GetArea()
Local oModelCN9	:= Nil 
Local lFixo		:= .F.

Default cNumero	:= "" 
Default cRevisa	:= "" 
Default cSitu	:= CN9->CN9_SITUAC
Default lExclui	:= .F.
Default lDelCrg	:= .F.
Default oModel 	:= Nil

If oModel <> Nil .And. oModel:IsActive()
	oModelCN9	:= oModel:GetModel("CN9MASTER")
	cNumero	:= oModelCN9:GetValue("CN9_NUMERO")
	cRevisa	:= oModelCN9:GetValue("CN9_REVISA")
	lFixo	:= Cn300RetSt("FIXO",2)
Else
	lFixo	:= CN300RetSt("FIXO",2,,cNumero,,.F.)
EndIf

CNA->(dbSetOrder(1)) //-- CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO

If CNA->(MsSeek(xFilial("CNA")+cNumero+cRevisa))

	PcoIniLan("000354") //-- Planilha de Contrato - SIGAGCT
	If lFixo
		PcoIniLan("000357") //-- Cronograma Financeiro
	EndIf

	While !CNA->(EOF()) .And. CNA->(CNA_CONTRA+CNA_REVISA) == cNumero+cRevisa
	 	If cSitu == "05" .Or. cSitu == "DR" //Vigente
	 		If cAprTipRev <> "" .Or. cSitu =="DR"
	 			PcoDetLan("000354","03","CNTA300",lExclui) //-- "Aprovação Revisão de Planilha - Total"
			EndIf
		ElseIf cSitu == "06" //Paralisação
			PcoDetLan("000354","05","CNTA300") //-- Paralisação de Contrato - Total
		ElseIf cSitu $ "01|08" //Cancelamento ou Finalização
			PcoDetLan("000354","07","CNTA300") //-- Finalização/Cancelamento do Contrato do Contrato - Planilha - Total
		ElseIf cSitu == "02" .And. !lDelCrg	// Inclusao/Alteracao do contrato
			PcoDetLan("000354","01","CNTA300",lExclui) //-- Inclusão de Planilha - Total
		EndIf

		CNB->(dbSetOrder(1)) //-- CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM
		CNB->(MsSeek(xFilial("CNB")+cNumero+cRevisa+CNA->CNA_NUMERO))
		While !CNB->(EOF()) .And. cNumero+cRevisa+CNA->CNA_NUMERO == CNB->(CNB_CONTRA+CNB_REVISA+CNB_NUMERO)
			If cSitu == "05" .Or. cSitu =="DR" //Vigente
				If cAprTipRev <> "" .Or. cSitu =="DR" 
					PcoDetLan("000354","04","CNTA300",lExclui) //-- "Aprovação Revisão de Planilha - Itens"					
					LancPcoCNZ("10",lExclui)//Revisão Rateios da Planilha(CNZ) - seq. 10
				EndIf
			ElseIf cSitu == "06" //Paralisação
				PcoDetLan("000354","06","CNTA300") //-- Paralisação de Contrato - Itens
			ElseIf cSitu $ "01|08" //Cancelamento ou Finalização
				PcoDetLan("000354","08","CNTA300") //-- Finalização/Cancelamento do Contrato do Contrato - Planilha - Itens
			ElseIf cSitu == "02" .And. !lDelCrg	// Inclusao/Alteracao do contrato
				PcoDetLan("000354","02","CNTA300",lExclui) //-- Inclusão de Planilha - Itens
				LancPcoCNZ("09",lExclui)//Inclusão Rateios da Planilha(CNZ) - seq. 09
			EndIf
			CNB->(dbSkip())
		EndDo
		If lFixo
			dbSelectArea("CNF")
			CNF->(dbSetOrder(1)) //CNF_FILIAL+CNF_NUMERO+CNF_CONTRA+CNF_REVISA
			CNF->(MsSeek(xFilial("CNF")+CNA->CNA_CRONOG+cNumero+cRevisa))
			While !CNF->(EOF()) .And. CNA->CNA_CRONOG+cNumero+cRevisa == CNF->(CNF_NUMERO+CNF_CONTRA+CNF_REVISA)
				If cSitu == "05" .Or. cSitu =="DR"//Vigente
					If cAprTipRev <> "" .Or. cSitu =="DR"
						PcoDetLan("000357","03","CNTA300",lExclui) //"Cronograma Financeiro - Aprovação Revisao"
					EndIf
				ElseIf cSitu == "06" //Paralisação
					PcoDetLan("000357","04","CNTA300") //-- Paralisação de Contrato - Cronograma Financeiro
				ElseIf cSitu $ "01|08" //Cancelamento ou Finalização
					PcoDetLan("000357","05","CNTA300") //"Finalização/Cancelamento do Contrato do Contrato - Cronograma Financeiro"
				ElseIf cSitu == "02"	// Inclusao/Alteracao do contrato
					PcoDetLan("000357","01","CNTA300",lExclui .Or. lDelCrg) //-- Cronograma Financeiro
				EndIf
				If Cn300RetSt("FISICO") .And. cSitu == "02"
					CNS->(dbSetOrder(1)) //CNS_FILIAL+CNS_CONTRA+CNS_REVISA+CNS_CRONOG+CNS_PARCEL+CNS_ITEM
					CNS->(MsSeek(xFilial("CNS")+cNumero+cRevisa+CNF->(CNF_NUMERO+CNF_PARCEL)))
					While !CNS->(EOF()) .And. cNumero+cRevisa+CNF->(CNF_NUMERO+CNF_PARCEL) == CNS->(CNS_CONTRA+CNS_REVISA+CNS_CRONOG+CNS_PARCEL)
						// Posiciona item planilha CNB
						CNB->(DbSetOrder(1))
						CNB->(MsSeek(xFilial("CNB")+CNS->(CNS_CONTRA+CNS_REVISA+CNS_PLANI+CNS_ITEM)))
						PcoDetLan("000357","02","CNTA300",lExclui .Or. lDelCrg) //-- Cronograma Fisico - Proporcionalidade do item de contrato
						CNS->(dbSkip())
					EndDo
				EndIf
				CNF->(dbSkip())
			EndDo
		EndIf
		CNA->(dbSkip())
	EndDo
	If lFixo
		PcoFinLan("000357")
		PcoFreeBlq("000357")
	EndIf
	PcoFinLan("000354")
	PcoFreeBlq("000354")
EndIf

RestArea(aArea)

Return NIL

//------------------------------------------------------------------
/*/{Protheus.doc} CN300VDoc()
Visualiza Documentos

@author Matheus Lando
@since 03/03/2015
@version P12
@Return lRet
/*/
//-------------------------------------------------------------------
Function CN300VDoc()
Local oModel 		:= FwModelActive()
Local oModelCNK	:= oModel:GetModel('CNKDETAIL')
Local oModelCN9	:= oModel:GetModel('CN9MASTER')
Local oView 		:= FwViewActive()

If (Cn300RetSt('COMPRA') .AND. oView:GetFolderActive("FLDCNT", 2)[2] == STR0026 )  .OR. (!Cn300RetSt('COMPRA') .AND. oView:GetFolderActive("FLDCNT", 2)[2] == STR0026 )// Aba de Documentos
	If oModelCNK:GetDataId() == 0
		Help("",1,"A300NDOC",,STR0162,4,1)	//"Selecione um documento para visualizá-lo"
	Else
		CNK->(dbGoTo(oModelCNK:GetDataId()))
		CN170Manut("CNK",oModelCNK:GetDataId(),MODEL_OPERATION_VIEW,/*xFiller*/,oModelCN9:GetValue('CN9_NUMERO'),/*cTpDoc*/,/*cCod*/,.F.)
	EndIf
Else
	Help("",1,"A300ABADOC",,STR0163,4,1)	//"Para visualizar os documentos selecione a aba correspondente"
EndIf

Return
//------------------------------------------------------------------
/*/{Protheus.doc} CN300PEVP
Gatilha do percentual para a quantidade nas partes envolvidas
@author Flavio Lopes Rasta
@since 02/07/2015
/*/
//-------------------------------------------------------------------
Function CN300PEVP()
Local aSaveLines	:= FwSaveRows()
Local lRet 		:= .T.
Local oModel 		:= FwModelActive()
Local oModelCNB 	:= oModel:GetModel('CNBDETAIL')
Local oModelCXI 	:= oModel:GetModel('CXIDETAIL')
Local nPercTot	:= 0
Local nPerc		:= oModelCXI:GetValue('CXI_PERRAT')
Local nQtItTot	:= CN300TtIt(oModelCNB)
Local nX			:= 1

For nX:=1 To oModelCXI:Length()
	oModelCXI:GoLine(nX)
	If !oModelCXI:IsDeleted()
		nPercTot += oModelCXI:GetValue('CXI_PERRAT')
	EndIf
Next nX
FwRestRows( aSaveLines )

//-- Carrega quantidade
If lRet
	oModelCXI:LoadValue('CXI_QUANT',nQtItTot/100*nPerc)
Endif

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CN300PEVQ
Gatilha da quantidade para o percentual  nas partes envolvidas
@author Flavio Lopes Rasta
@since 02/07/2015
/*/
//-------------------------------------------------------------------
Function CN300PEVQ()
Local aSaveLines	:= FwSaveRows()
Local lRet 		:= .T.
Local oModel 		:= FwModelActive()
Local oModelCNB 	:= oModel:GetModel('CNBDETAIL')
Local oModelCXI 	:= oModel:GetModel('CXIDETAIL')
Local nQuantTot	:= 0
Local nQuant		:= oModelCXI:GetValue('CXI_QUANT')
Local nQtItTot  	:= CN300TtIt(oModelCNB)
Local nX			:= 1

For nX:=1 To oModelCXI:Length()
	oModelCXI:GoLine(nX)
	If !oModelCXI:IsDeleted()
		nQuantTot += oModelCXI:GetValue('CXI_QUANT')
	EndIf
Next nX
FwRestRows( aSaveLines )

//-- Carrega percentual de rateio
If lRet
	oModelCXI:LoadValue('CXI_PERRAT',nQuant*100/nQtItTot)
Endif

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CN300TtIt()
Calcula a quantidade total dos itens da planilha
@author Flavio Lopes Rasta
@since 02/07/2015
/*/
//-------------------------------------------------------------------
Function CN300TtIt(oModelCNB)
Local aSaveLines	:= FwSaveRows()
Local nTotal		:= 0
Local nX			:= 1

For nX:=1 To oModelCNB:Length()
	oModelCNB:GoLine(nX)
	If !oModelCNB:IsDeleted()
		nTotal+=oModelCNB:GetValue('CNB_QUANT')
	EndIf
Next nX

FwRestRows( aSaveLines )

Return nTotal

//------------------------------------------------------------------
/*/{Protheus.doc} CN300VlPar()
Valida partes envolvidas
@author Flavio Lopes Rasta
@since 03/07/2015
/*/
//-------------------------------------------------------------------
Function CN300VlPar(oModel as Object)
Local aSaveLines	:= {}
Local lRet			:= .T.
Local oModelCXI		:= Nil
Local oModelCNB		:= Nil
Local oModelCNA		:= Nil
Local nX			:= 1
Local cTpParEnv		:= ""
Local lTipOk		:= .T.
Local lCliOk		:= .T.
Local lFilOk		:= .T.
Local nPercTot		:= 0
Local nQuantTot		:= 0
Local cPlan			:= ""
Local lValida		:= .F.
Local lCliEmpt		:= .F.
Local cFilResp		:= ""
Default oModel		:= FwModelActive()

oModelCXI := oModel:GetModel('CXIDETAIL')

If !FwIsInCallStack("CN300PlaTOK")
	aSaveLines	:= FwSaveRows()
EndIf

For nX:=1 To oModelCXI:Length()
	oModelCXI:GoLine(nX)
	If !oModelCXI:IsDeleted() .And. oModelCXI:GetValue('CXI_PERRAT') > 0
 		lValida:= .T.
 		Exit
 	Endif
Next nX

If lValida
	oModelCNB	:= oModel:GetModel('CNBDETAIL')
	oModelCNA	:= oModel:GetModel('CNADETAIL')
	cPlan		:= oModelCNA:GetValue("CNA_NUMERO")

	For nX:=1 To oModelCXI:Length()
		oModelCXI:GoLine(nX)
		If !oModelCXI:IsDeleted()
			If Empty(cTpParEnv)
				cTpParEnv := oModelCXI:GetValue('CXI_TIPO')
			EndIf

			If oModelCXI:GetValue('CXI_TIPO') <> cTpParEnv
				lTipOk := .F.
			Endif

			If cTpParEnv == '1'
				If ! Empty(oModelCXI:GetValue('CXI_FILRES'))
					cFilResp := oModelCXI:GetValue('CXI_FILRES')
				EndIf

				If MTFindMvc(oModelCXI,{{'CXI_FILRES',oModelCXI:GetValue('CXI_FILRES')}},nX) .Or.  MTFindMvc(oModelCXI,{{'CXI_DESFIL',oModelCXI:GetValue('CXI_DESFIL')}},nX)
					lFilOk := .F.
				Endif
			ElseIf oModelCXI:GetValue('CXI_TIPO') == '2'
				If ! Empty(oModelCXI:GetValue('CXI_CODCLI')) .And.  ! Empty(oModelCXI:GetValue('CXI_LOJACL'))
				If MTFindMvc(oModelCXI,{{'CXI_CODCLI',oModelCXI:GetValue('CXI_CODCLI')},{'CXI_LOJACL',oModelCXI:GetValue('CXI_LOJACL')}},nX)
					lCliOk := .F.
				Endif
				Else
					lCliEmpt := .T.
				EndIf
			Endif
			nPercTot 	+= oModelCXI:GetValue('CXI_PERRAT')
			nQuantTot 	+= oModelCXI:GetValue('CXI_QUANT')
		Endif
	Next nX

	If cTpParEnv == "1" .and. Empty(cFilResp)
		Help(" ",1,"CNTA300PEFILCON")//,,"É necessário informar pelo menos um código de filial responsável cadastrada no sistema.",4,1)
		lRet:= .F.
	EndIf

	If !lTipOk
		Help('',1,'CNTA300PETIPOS')//'Não é permitido informar tipos diferentes de partes envolvidas na mesma planilha'
		lRet:= .F.
	Endif

	If lRet .And. !lCliOk
		Help('',1,'CNTA300PEDUPCL')//'Não é permitido informar o mesmo cliente em mais de um registro.'
		lRet:= .F.
	Endif

	If lCliEmpt
		Help('',1,'CNTA300PETPFIN')//'Para tipo Financiamento é necessário informar o código do Cliente/Loja.'
		lRet:= .F.
	EndIf

	If lRet .And. !lFilOk
		Help('',1,'CNTA300PEDUPFI')//'Não é permitido informar a mesma filial em mais de um registro.'
		lRet:= .F.
	Endif

	If lRet
		If !(nPercTot == 100) .And. nPercTot > 0
			Help(" ",1,"CNTA300PEPERC",,STR0233+cPlan+STR0234,4,1)
			lRet:= .F.
	 	Endif
	Endif

	If lRet
		If !(nQuantTot == CN300TtIt(oModelCNB))
			Help('',1,'CNTA300PEQUANT')//'A quantidade total das partes deve ser igual a quantidade total de itens'
			lRet:= .F.
		Endif
	Endif
EndIf
If Len(aSaveLines) > 0
	FwRestRows( aSaveLines )
	FwFreeArray(aSaveLines)
EndIf
Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CN300VPeT()
When do cliente nas partes envolvidas
@author Flavio Lopes Rasta
@since 03/07/2015
/*/
//-------------------------------------------------------------------
Function CN300VPeT()
Local lRet 		:= .T.
Local oModel		:= FwModelActive()
Local oModelCXI	:= oModel:GetModel('CXIDETAIL')
Local aCampos	:= {}

If oModelCXI:GetValue('CXI_TIPO') == "1"
	oModelCXI:ClearField('CXI_CODCLI',,.T.)
	oModelCXI:ClearField('CXI_LOJACL',,.T.)
	oModelCXI:ClearField('CXI_NOMCLI',,.T.)

	aCampos := {}
	aAdd(aCampos,{'CXIDETAIL',{'CXI_CODCLI','CXI_LOJACL','CXI_NOMCLI'}})
	MtBCMod(oModel,aCampos,{||.F.},'2')
Else
	aCampos := {}
	aAdd(aCampos,{'CXIDETAIL',{'CXI_CODCLI','CXI_LOJACL','CXI_NOMCLI'}})
	MtBCMod(oModel,aCampos,{||.T.},'2')
Endif

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CN300PVlCXI()
Pós-Valid do modelo CXI
@author Flavio Lopes Rasta
@since 03/07/2015
/*/
//-------------------------------------------------------------------
Function CN300PVlCXI(oModelGrid)
Local lRet			:= .T.
Local oModel 	:= oModelGrid:GetModel()
Local oModelCXI 	:= oModel:GetModel('CXIDETAIL')
Local cTipo		:= oModelCXI:GetValue("CXI_TIPO")
Local aSaveLines:= FwSaveRows()
Local nX		:= 1
Local nPercTot	:= 0

If Cn300RetSt('VENDA')
	// Validações do Tipo
	If cTipo == '1'
		If Empty(oModelCXI:GetValue("CXI_FILRES")) .And. Empty(oModelCXI:GetValue("CXI_DESFIL"))
			Help('',1,'CNTA300PETPCON')//'Para tipo Consórcio é necessário informar a filial responsável'
			lRet := .F.
		Endif
	ElseIf cTipo == '2'
		If Empty(oModelCXI:GetValue("CXI_FILRES")) .And. Empty(oModelCXI:GetValue("CXI_CODCLI")) .And. Empty(oModelCXI:GetValue("CXI_LOJACL"))
			Help('',1,'CNTA300PETPFIN')//'Para tipo Financiamento é necessário informar o código do Cliente/Loja.'
			lRet := .F.
		Endif
	Endif

	//Validações Quantidade e Percentual
	If lRet
		If oModelCXI:GetValue("CXI_QUANT") == 0 .Or. oModelCXI:GetValue("CXI_PERRAT") == 0
			Help('',1,'CNTA300PEQTRAT')//'Os valores de Quantidade e Percentual de rateio devem ser maiores do que zero(0)'
			lRet := .F.
		Endif
	EndIf

	// Validações das quantidades e Percencutal somando todos os itens do Grid
	If lRet
		For nX:=1 To oModelCXI:Length()
			oModelCXI:GoLine(nX)
			If !oModelCXI:IsDeleted()
				nPercTot += oModelCXI:GetValue('CXI_PERRAT')
			EndIf
		Next nX

		If nPercTot > 100
			lRet := .F.
			Help(" ",1, 'Help','CN300PEVP_01')//, "A soma dos percentuais de rateio não podem ser superior a 100%", 3, 0 )
		EndIf
	EndIf

Endif

FwRestRows( aSaveLines )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP300NE(oModel)
Rotina de Inclusão de Nota de Empenho pelo Contrato

@author Bruno.Schmidt
@since 04/07/2015
@version P12.1.6
@param oModel Modelo ativo
@return Nil
/*/
//------------------------------------------------------------------
Function GCP300NE()
Local oModel		:= FWLoadModel("CNTA300")
Local oModelCNB	:= NIL
Local oModelCN9	:= NIL
Local oModelCNA	:= NIl
Local aSaveLines	:= FWSaveRows()
Local aItens		:= {}
Local cCodEdit	:= ""
Local cNumero		:= ""
Local nX			:= 0
Local nY			:= 0

If oModel:Activate()
oModelCN9	:= oModel:GetModel('CN9MASTER') //--Cabecalio Contrato
oModelCNA	:= oModel:GetModel('CNADETAIL')// -- Planilhas do Contrato
oModelCNB	:= oModel:GetModel('CNBDETAIL') //-- Itens
 // --Contrato
cFilCont	:= oModelCN9:GetValue("CN9_FILORI")
cNumero	:= oModelCN9:GetValue("CN9_NUMERO")
nRevisa	:= oModelCN9:GetValue("CN9_REVISA")
 // --Edital
cCodEdit	:= oModelCN9:GetValue("CN9_CODED")
cNumProc	:= oModelCN9:GetValue("CN9_NUMPR")

If !Empty(cCodEdit)
 	CO1->(DbSetOrder(1))
 	If CO1->(DbSeek(xFilial('CO1')+cCodEdit+cNumProc ))
	//  Criar Nota e Empenho por Planilha
	For nY := 1 To oModelCNA:Length()
		oModelCNA:Goline(nY)
         		aadd(aItens,{oModelCNA:GetValue("CNA_NUMERO"),{}})
		For nX := 1 To oModelCNB:Length()
			oModelCNB:Goline(nX)
			If !Empty(oModelCNB:GetValue("CNB_GCPIT"))
                		aadd(aItens[nY][2],{oModelCNB:GetValue("CNB_GCPIT")})
			EndIf
		Next nX
		If !Empty(aItens[nY][2])
		 		GCPXNEMP(aItens[nY][2],cCodEdit,cNumProc,cNumero,nRevisa,aItens[nY][1],cFilCont)
		EndIf
	Next nY
Else
	Help(" ",1,"CNTA300EMP")
EndIf
	Else
		Help(" ",1,"CNTA300EMP")
	EndIf
oModel:Deactivate()
Else
      Help(" ",1,"ERRO",oModel:GetErrorMessage()[6])
EndIf

FWRestRows( aSaveLines )
Return
//------------------------------------------------------------------
/*/{Protheus.doc} a300ChgLine
Rotina para desbloquear partes do modelo conforme tipo de planilha
Executada na troca de linha do grid das planilhas
@author Rogerio Melonio
@since 02/06/2015
/*/
//-------------------------------------------------------------------
Function a300ChgLine( oView, cViewID )
	Local oModel := FWModelActive()
	Local nOperation := oModel:GetOperation()
	Local cTpCtr := oModel:GetValue( "CN9MASTER", "CN9_TPCTO" )
	Local cSituac := oModel:GetValue( "CN9MASTER", "CN9_SITUAC" )
	Local lAltera := nOperation == MODEL_OPERATION_UPDATE
	Local lInclui := nOperation == MODEL_OPERATION_INSERT
	Local lAltVigent := .F.
	
	If !Empty( cTpCtr ) .And. ( lAltera .Or. lInclui )
		
		lAltVigent := lAltera .And. !( AllTrim(cSituac) $ ( DEF_SELAB + "|" + DEF_SREVS + "|" + DEF_SREVA + "|" + DEF_SREJE ) )
		
		If !lAltVigent
			cTipoPlan := CN300TpPla( .F., oModel )
		EndIF
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300TOTPLA
Funcao que calcula os campos de valores do contrato considerando o valor manual da planilha
Chamado pelo gatilho do campo CNA_VLTOT
@author Rogerio Melonio
@since 04/07/2015
/*/
//-------------------------------------------------------------------
Function CN300TotPla()
Local aArea		:= GetArea()
Local aSaveLines	:= FwSaveRows()
Local oModel 		:= FWModelActive()
Local oModelCN9	:= oModel:GetModel("CN9MASTER")
Local oModelCNA	:= oModel:GetModel("CNADETAIL")
Local nTotal 		:= oModelCNA:GetValue("CNA_VLTOT")

If !Empty(oModelCN9:GetValue('CN9_TIPREV'))
	If oModelCNA:GetValue('CNA_CONTRA')+oModelCNA:GetValue('CNA_NUMERO') != CNA->(CNA_CONTRA+CNA_NUMERO)
		dbSelectArea('CNA')
		CNA->(dbSetOrder(1)) ////CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO
		CNA->(MsSeek(oModelCNA:GetValue('CNA_FILIAL')+oModelCNA:GetValue('CNA_CONTRA')+oModelCNA:GetValue('CNA_REVISA')+oModelCNA:GetValue('CNA_NUMERO')))
		EndIf

	nTotal += CNA->CNA_SALDO - CNA->CNA_VLTOT
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return nTotal

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VLPLA
Funcao que reseta o campo de valor total da planilha, quando trocado o tipo diferente de não fixo e sem previsão financeira
Chamado pelo gatilho do campo CNA_TIPPLA
@author Rogerio Melonio
@since 04/07/2015
/*/
//-------------------------------------------------------------------
Function CN300VLPLA(lFixo,lValor)
Local oModel 	:= FWModelActive()
Local oModelCN9	:= oModel:GetModel("CN9MASTER")
Local oModelCNA	:= oModel:GetModel("CNADETAIL")
Local oModelCNB	:= oModel:GetModel("CNBDETAIL")
Local nVlrPlan 	:= oModelCNA:GetValue("CNA_VLTOT")
Local nVlrDif	:= oModelCNA:GetValue("CNA_VLTOT") - oModelCNA:GetValue("CNA_SALDO")
Local nI 		:= 0
Local lRet 		:= (!lFixo .And. lValor ) .Or. Cn300RetSt("SEMIAGRUP")
Local aSaveLines:= FWSaveRows()
Local aProp	:= {}

If !lRet
	nVlrPlan := 0
	For nI := 1 To oModelCNB:Length() //-Roda Itens
		oModelCNB:GoLine(nI)
		If !oModelCNB:IsDeleted() .And. oModelCNB:GetValue("CNB_ATIVO") <> "2"
			nVlrPlan += oModelCNB:GetValue("CNB_VLTOT") - oModelCNB:GetValue("CNB_VLDESC")
		Endif
	Next nI

	//Tratativa para não ficar posicionado na ultima linha
	oModelCNB:GoLine(1)

	aProp := GetPropMdl(oModelCNA)
	CNTA300BlMd(oModelCNA,.F.)

	oModel:GetModel("CNADETAIL"):GetStruct():SetProperty('CNA_VLTOT',MODEL_FIELD_WHEN,{||.T.})
	oModelCNA:LoadValue("CNA_VLTOT",nVlrPlan)
	oModel:GetModel("CNADETAIL"):GetStruct():SetProperty('CNA_VLTOT',MODEL_FIELD_WHEN,{||.F.})

	oModelCNA:LoadValue("CNA_SALDO",nVlrPlan - nVlrDif)

	RstPropMdl(oModelCNA,aProp)

	If Empty(cTipRevisa) .AND. Empty(cAprTipRev) .And. oModel:GetOperation() != MODEL_OPERATION_VIEW // não é revisão ou visualização
		If Alltrim(CN9->CN9_SITUAC) <> '05' // contrato não está vigente
			oModelCN9:LoadValue("CN9_VLINI",oModelCN9:GetValue("CN9_VLATU"))
		EndIf
	Endif

Endif

If FWIsInCallStack('CNTA300xEdt')
	GCP017BMod(oModel,{'CNBDETAIL'},.F.)
EndIf

FWRestRows(aSaveLines)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300BlVlr
Funcao que libera/bloqueia o campo de valor total da planilha, quando for trocado o tipo de contrato
Chamado pelo gatilho do campo CN9_TPCTO
@author Rogerio Melonio
@since 04/07/2015
/*/
//-------------------------------------------------------------------
Function CN300BlVlr(oModel,nLine)
Local aSaveLines	:= FWSaveRows()
Local oModelCN9	:= oModel:GetModel("CN9MASTER")
Local oModelCNA	:= oModel:GetModel("CNADETAIL")
Local lRet 		:= !Empty(oModelCN9:GetValue("CN9_TPCTO")) .And. !Empty(oModelCNA:GetValue("CNA_TIPPLA"))
Local lFixo		:= .F.
Local lValor	:= .F.
Local lSemiFixo	:= .F.
Local nI 		:= 0

Default nLine 	:= 0

If lRet
	If nLine <> 0
		lFixo	:= Cn300RetSt("FIXO")
		lValor	:= Cn300RetSt("PREVFINANC")
	   	lSemiFixo	:= Cn300RetSt("SEMIFIXO")

		If !oModelCNA:IsDeleted() .And. !Empty(oModelCNA:GetValue("CNA_TIPPLA"))
			If lSemiFixo
				oModelCNA:GetStruct():SetProperty('CNA_VLTOT',MODEL_FIELD_WHEN,{||CN300WTot()})
			ElseIf !lFixo .And. lValor
				oModel:GetModel("CNADETAIL"):GetStruct():SetProperty('CNA_VLTOT',MODEL_FIELD_WHEN,{||.T.})
			Else
				oModel:GetModel("CNADETAIL"):GetStruct():SetProperty('CNA_VLTOT',MODEL_FIELD_WHEN,{||.F.})
			Endif
		Endif
	Else
		For nI := 1 To oModelCNA:Length()
			oModelCNA:GoLine(nI)
			lFixo	:= Cn300RetSt("FIXO")
			lValor	:= Cn300RetSt("PREVFINANC")
	        lSemiFixo := Cn300RetSt("SEMIFIXO")
			If !oModelCNA:IsDeleted() .And. !Empty(oModelCNA:GetValue("CNA_TIPPLA"))
            	If lSemiFixo
					oModel:GetModel("CNADETAIL"):GetStruct():SetProperty('CNA_VLTOT',MODEL_FIELD_WHEN,{||CN300WTot()})
				ElseIf !lFixo .And. lValor
					oModel:GetModel("CNADETAIL"):GetStruct():SetProperty('CNA_VLTOT',MODEL_FIELD_WHEN,{||.T.})
				Else
					oModel:GetModel("CNADETAIL"):GetStruct():SetProperty('CNA_VLTOT',MODEL_FIELD_WHEN,{||.F.})
				Endif
			Else
				If lSemiFixo
					oModel:GetModel("CNADETAIL"):GetStruct():SetProperty('CNA_VLTOT',MODEL_FIELD_WHEN,{||CN300WTot()})
				Else
					oModel:GetModel("CNADETAIL"):GetStruct():SetProperty('CNA_VLTOT',MODEL_FIELD_WHEN,{||.F.})
				EndIf
			Endif
		Next nI
	Endif
Else
	oModel:GetModel("CNADETAIL"):GetStruct():SetProperty('CNA_VLTOT',MODEL_FIELD_WHEN,{||.F.})
EndIf

FWRestRows(aSaveLines)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300ViewPC
Função que retorna a View do Pedido de Compra vinculado à Medição
@author miguel.santos
@since 20/07/2015
/*/
//-------------------------------------------------------------------
Function CN300ViewPC()
Local oModel 		:= FWModelActive()
Local oModelSC7 	:= oModel:GetModel("SC7DETAIL")
Local cFilBkp		:= cFilAnt
Local cFilMed		:= ""
// Foi necessario criar essas variaveis para que fosse possivel usar a funcao padrao do sistema A120Pedido()
Private aRotina   	:= {}
Private INCLUI    	:= .F.
Private ALTERA    	:= .F.
Private nTipoPed  	:= 1
Private cCadastro 	:= ""
Private l120Auto	:= .F.

//--Monta o aRotina para compatibilizacao
AAdd( aRotina, { '' , '' , 0, 1 } )
AAdd( aRotina, { '' , '' , 0, 2 } )
AAdd( aRotina, { '' , '' , 0, 3 } )
AAdd( aRotina, { '' , '' , 0, 4 } )
AAdd( aRotina, { '' , '' , 0, 5 } )

If !Empty(oModelSC7:GetDataId())
	cFilMed := oModel:GetValue("CNDDETAIL", "CND_FILMED")
	cFilMed := IIF(Empty(cFilMed), cFilAnt, cFilMed)
	If (cFilMed != cFilAnt)//Tratamento p/ visualização dos pedidos de medições feitas em filiais distintas a do contrato
		cFilAnt := oModel:GetValue("CNDDETAIL", "CND_FILMED")
	EndIf
	SC7->(DbGoTo(oModelSC7:GetDataId()))

	cCadastro	:= STR0063		//"Pedido de Compra"
	A120Pedido("SC7",SC7->( Recno()),2)
Else
	Help('',1,'CNTA300SPD') //A Planilha selecionada não possui Pedidos!
EndIf

cFilAnt := cFilBkp //Restaurar a filial
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300COR
Rotina para execucao do ponto de entrada de inclusao de legenda

@param aCores array com cores das legendas

@author Rodrigo Dias Nunes
@since 10/12/2015
@version P12.7
/*/
//-------------------------------------------------------------------
Function CN300COR(aCores)
Local aCoresLeg := {}

aCoresLeg := execBlock("CN100COR",.F.,.F.,{aCores})

Return(aCoresLeg)

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300WReCt()
Função bloqueia a edição dos campos de acordo com o reajuste do
Contrato

@author Flavio Lopes Rasta
@since 20/07/2015
/*/
//-------------------------------------------------------------------
Function CN300WReCt()
	Local lRet := .T.
	lRet := FwFldGet('CN9_FLGREJ') == '1'
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300WRePl()
Função bloqueia a edição dos campos de acordo com o reajuste da
Planilha

@author Flavio Lopes Rasta
@since 20/07/2015
/*/
//-------------------------------------------------------------------
Function CN300WRePl()
Local lRet := .T.

If FwFldGet('CNA_FLREAJ') == '1' .And. FwFldGet('CN9_FLGREJ') == '1' .Or.;
   FwIsInCallStack('CN300VRCt')
	lRet := .T.
Else
	lRet := .F.
EndIf

If ReadVar() == "M->CNA_PRORAT"
	If FwFldGet('CNA_FLREAJ') == '1' .And. FwFldGet('CN9_FLGREJ') == '1' .And.;  
       FwFldGet('CN9_PRORAT') == '1' .Or. FwIsInCallStack('CN300VRCt')
		lRet := .T.
	Else
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300WReIt()
Função bloqueia a edição dos campos de acordo com o reajuste dos
Itens

@author Flavio Lopes Rasta
@since 20/07/2015
/*/
//-------------------------------------------------------------------
Function CN300WReIt()
Local lRet := .T.

If FwFldGet('CN9_FLGREJ') == '1' .And. FwFldGet('CNA_FLREAJ') == '1'
	lRet := .T.
Else
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VRCt()
Função no valid dos campos de Reajuste para limpar os campos

@author Flavio Lopes Rasta
@since 20/07/2015
/*/
//-------------------------------------------------------------------
Function CN300VRCt(cModel,cValue,cOldValue,cField)
Local aSaveLines 	:= FwSaveRows()
Local oModel		:= FwModelActive()
Local oModelCN9		:= oModel:GetModel('CN9MASTER')
Local oModelCNA		:= oModel:GetModel('CNADETAIL')
Local oModelCNB		:= oModel:GetModel('CNBDETAIL')
Local nX			:= 1
Local aProp			:= {}
Default cModel      := ""
Default cValue      := ""
Default cOldValue   := "1"
Default cField      := ""

If cModel == 'CN9'
	If cValue == '2'
        If cField != 'CN9_PRORAT'
            oModelCN9:LoadValue('CN9_INDICE','')
            oModelCN9:LoadValue('CN9_PERI',0)
            oModelCN9:LoadValue('CN9_UNPERI','')
            oModelCN9:LoadValue('CN9_MODORJ','')
            oModelCN9:LoadValue('CN9_PRORAT','')
        EndIf
		
		aProp := GetPropMdl(oModelCNA)
		CNTA300BlMd(oModelCNA,.F.)
		For nX := 1 To oModelCNA:Length()
			oModelCNA:GoLine(nX)
            If cField != 'CN9_PRORAT'
                oModelCNA:SetValue('CNA_FLREAJ','2')
            EndIf
            oModelCNA:SetValue('CNA_PRORAT','2')
		Next nX
		RstPropMdl(oModelCNA,aProp)
		FwFreeArray(aProp)
	EndIf
Endif

If cModel == 'CNA'
	If cValue == '2' .And. cOldValue == '1'
		oModelCNA:LoadValue('CNA_INDICE','')
		oModelCNA:LoadValue('CNA_PERI',0)
		oModelCNA:LoadValue('CNA_UNPERI','')
		oModelCNA:LoadValue('CNA_MODORJ','')
		oModelCNA:LoadValue('CNA_PRORAT','2')

		If CN300RetSt("FIXO") //-- Altera CNB_FLREAJ apenas quando o tipo da planilha for fixo.
			aProp := GetPropMdl(oModelCNB)
			CNTA300BlMd(oModelCNB,.F.)

			For nX := 1 To oModelCNB:Length()
				oModelCNB:GoLine(nX)
				oModelCNB:SetValue('CNB_FLREAJ','2')
			Next nX

			RstPropMdl(oModelCNB,aProp)
			FwFreeArray(aProp)
        ElseIf oModelCNB:CanClearData() .And. oModelCNB:IsModified() //-- Limpa modelo da CNB caso tipo de planilha não tiver itens.
            oModelCNB:ClearData()
		EndIf
	Endif
Endif

If cModel == 'CNB'
	If cValue == '2' .And. cOldValue == '1'
		oModelCNB:LoadValue('CNB_INDICE','')		
	Endif
Endif

FwRestRows( aSaveLines )
FwFreeArray(aSaveLines)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300ProRe()
Função para calcular data do próximo reajuste

Chamado pelos gatilhos:

@author Flavio Lopes Rasta
@since 20/07/2015
/*/
//-------------------------------------------------------------------
Function CN300ProRe(cTab)
Local oModel := FwModelActive()
Local oModelTab	:= NIL
Local cModel	:= ""
Local cUnit		:= ""
Local nPeriod	:= 0
Local dDataRef	:= dDatabase
Local dProxReaj	:= dDatabase
Local xRet
Local lPermReaj := .F. //-- Permite Reajuste

If cTab == 'CN9'
	cModel := cTab+'MASTER'
Else
	cModel := cTab+'DETAIL'
Endif

oModelTab	:= oModel:GetModel(cModel)
cUnit 		:= oModelTab:GetValue(cTab+'_UNPERI')
nPeriod 	:= oModelTab:GetValue(cTab+'_PERI')
dDataRef 	:= oModelTab:GetValue(cTab+'_DTREAJ')

lPermReaj := (oModel:GetValue('CN9MASTER','CN9_FLGREJ') == '1')

If cTab == 'CNA'
	lPermReaj := (lPermReaj .And. (oModel:GetValue('CNADETAIL','CNA_FLREAJ') == '1'))
EndIf

If lPermReaj
	If Empty(dDataRef)
		DO	CASE
			CASE cTab == 'CN9'
				dDataRef := oModel:GetValue('CN9MASTER','CN9_DTINIC')
			CASE cTab == 'CNA' .OR. cTab == 'CNB'
				dDataRef := oModel:GetValue('CNADETAIL','CNA_DTINI')
				If Empty(dDataRef)
					dDataRef := oModel:GetValue('CN9MASTER','CN9_DTINIC')
				EndIf
		END DO
	Endif

	DO	CASE
		CASE cUnit == '1'
			dProxReaj := DaySum(dDataRef,nPeriod)
		CASE cUnit == '2'
			dProxReaj := MonthSum(dDataRef,nPeriod)
		CASE cUnit == '3'
			dProxReaj := YearSum(dDataRef,nPeriod)
	END DO
Else
	dProxReaj := CToD('')
EndIf

If !Empty(cTab) 
	If(cTab)->(Columnpos(cTab+"_PROXRJ")) > 0
		oModelTab:GetStruct():SetProperty(cTab+"_PROXRJ",MODEL_FIELD_WHEN,{||.T.})
		oModelTab:SetValue(cTab+"_PROXRJ",dProxReaj)
		oModelTab:GetStruct():SetProperty(cTab+"_PROXRJ",MODEL_FIELD_WHEN,{||.F.})
	EndIf
	xRet := oModelTab:GetValue(cTab+"_UNPERI")
Else
	xRet := dProxReaj
EndIf

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VLREC
Funcao que valida a quantidade de recorrencias de uma planilha recorrente
Chamado pelo campo CNA_QTDREC
@author Rogerio Melonio
@since 21/07/2015
/*/
//-------------------------------------------------------------------
Function CN300VLREC(oModel,cField,cValue,cOldValue)
Local nTamParc 	:= TamSx3("E2_PARCELA")[1]
Local lCompra	:= CN300RetSt("COMPRA")
Local lRet := .T.

nTamParc := Iif(lCompra,TamSx3("E2_PARCELA")[1], TamSx3("E1_PARCELA")[1] )

//-- Valida numero de parcelas
If lRet .And. (nTamParc == 1 .And. cValue > 35)
	If lCompra
		Help(" ",1,"CNTA30SE2")	//-- O tamanho do campo E2_PARCELA não permite a configuração da quantidade de recorrencias inserida.
	Else
		Help(" ",1,"CNTA30SE1")	//-- O tamanho do campo E1_PARCELA não permite a configuração da quantidade de recorrencias inserida.
	Endif
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300PRIMD
Funcao que retorna a data da primeira medicao de uma planilha recorrente
Chamado pelo campo CNA_PERIOD
@author Rogerio Melonio
@since 21/07/2015
/*/
//-------------------------------------------------------------------
Function CN300PRIMD()
Local oModel	:= FwModelActive()
Local oModelCNA	:= oModel:GetModel("CNADETAIL")
Local dDataIni 	:= oModelCNA:GetValue("CNA_DTINI")
Local cPeriod	:= oModelCNA:GetValue("CNA_PERIOD")
Local nDiaMes	:= oModelCNA:GetValue("CNA_DIAMES")
Local cDiaSem	:= oModelCNA:GetValue("CNA_DIASEM")
Local nPerRec	:= oModelCNA:GetValue("CNA_PERREC")
Local cRecPagAnt:= oModelCNA:GetValue("CNA_RPGANT")
Local dDataPriMed := Ctod("")

If cRecPagAnt $ " |2"
	dDataPriMed := CN300RetMed(cPeriod,dDataIni,nDiaMes,cDiaSem,nPerRec,.T.)
Else
	dDataPriMed := DataValida(dDataIni)
Endif

Return dDataPriMed

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300RetMed
Funcao que calcula datas de medicao de uma planilha recorrente
Chamado por diversas funções relacionadas com planilhas recorrentes
@author Rogerio Melonio
@since 27/07/2015
/*/
//-------------------------------------------------------------------
Function CN300RetMed(cPeriod,dDataIni,nDiaMes,cDiaSem,nPerRec,lDiaMes)
Local dDataMed	:= Ctod("")
Local aDias		:= { 1, 7 }
Local nSaltoPer := Iif(nPerRec = 0, 1, nPerRec)
Default lDiaMes := .F.

If cPeriod $ "1234" .And. !Empty(dDataIni)
	DO 	CASE
		CASE cPeriod == '1' .Or. cPeriod == '2'
			 dDataMed := dDataIni + (aDias[Val(cPeriod)] * nSaltoPer)
		CASE cPeriod == '3'
			 dDataMed := monthSum(dDataIni,nSaltoPer)
			 If nDiaMes <> 0 .And. lDiaMes
			 	nDifDia := nDiaMes - day(dDataMed)
			 	If (dDataMed + nDifDia) > dDataIni
			 		dDataMed += nDifDia
			 	EndIf
			 EndIf
		CASE cPeriod == '4'
			 dDataMed := yearSum(dDataIni,nSaltoPer)
	ENDCASE

	If !Empty(dDataMed)
		// verifica data válida, próximo dia útil
		If cDiaSem == "2"
			dDataMed := DataValida(dDataMed,.T.)
		// verifica data válida, dia útil anterior
		ElseIf cDiaSem == "3"
			dDataMed := DataValida(dDataMed,.F.)
		Endif
	Endif
Endif

Return dDataMed

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300QtdRec
Funcao que retorna a quantidade de recorrencias de uma planilha recorrente
@author Rogerio Melonio
@since 28/07/2015
/*/
//-------------------------------------------------------------------
Function CN300QtdRec
Local cCpoParcela := ""
Local aParcelas := {}

cCpoParcela := IIf( Empty(CNA->CNA_FORNEC),"E1_PARCELA","E2_PARCELA" )
aParcelas := CN100ParRc(CNA->CNA_PERIOD,CNA->CNA_QTDREC,CNA->CNA_DIASEM,CNA->CNA_DIAMES,CNA->CNA_PROMED,CNA->CNA_DTINI,CNA->CNA_DTFIM,cCpoParcela,CNA->CNA_PERREC)

Return(Len(aParcelas))



//-------------------------------------------------------------------
/*/{Protheus.doc} CN300CPE
Gatilho dos campos CXI_CODCLI E CXI_LOJACL, para retornar o codigo
da loja ou nome do cliente

@author Hermes
@since 03/09/2015
@version 1.0
@param nTpRet, numérico, (1 = Retorna Loja, 2 = Retorna Nome Cliente)
@return cRet, Codigo da Loja Ou nome do cliente
/*/
//-------------------------------------------------------------------
Function CN300CPE(nTpRet)
Local cRet 		:= ""
Local oModel	:= FwModelActive()
Local oModelCXI	:= oModel:GetModel("CXIDETAIL")
Local cVarRet	:= IIF( nTpRet == 1, "A1_LOJA", "A1_NOME")

If ReadVar() == "M->CXI_CODCLI"
	cRet := Posicione("SA1",1,xFilial("SA1")+ &(ReadVar())  + iif( nTpRet== 1 ,"", oModelCXI:GetValue("CXI_LOJACL") ) , cVarRet )
	oModelCXI:ClearField('CXI_NOMCLI',,.T.)
ElseIf   ReadVar() ==  "M->CXI_LOJACL"
	cRet := Posicione("SA1",1,xFilial("SA1")+ oModelCXI:GetValue("CXI_CODCLI") + &(ReadVar())  , cVarRet )
	oModelCXI:ClearField('CXI_NOMCLI',,.T.)
EndIf

Return cRet
//-------------------------------------------------------------------
/*/{Protheus.doc}Cn300VldProd()
Validação para os campos dos Agrupadores (Tipo de Produto, Grupo de Produto e Categoria de Produto)

@author Flavia Aguiar
@since 22/07/2015
@version P12
/*/
//-------------------------------------------------------------------
Function Cn300VldProd()
Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local oModelCXM	:= oModel:GetModel("CXMDETAIL")
Local cTpProd	   := oModelCXM:GetValue("CXM_AGRTIP")
Local cGpProd 	:= oModelCXM:GetValue("CXM_AGRGRP")
Local cCtProd     := oModelCXM:GetValue("CXM_AGRCAT")

If !Empty(cTpProd) .and. (!Empty(cGpProd).or. !Empty(cCtProd))
	lRet := .F.
ElseIf !Empty(cGpProd) .and. (!Empty(cTpProd).or. !Empty(cCtProd))
	lRet := .F.
ElseIf !Empty(cCtProd) .and. (!Empty(cGpProd).or. !Empty(cTpProd))
	lRet := .F.
EndIf

If !lRet
	Aviso(STR0090,STR0223,{STR0222})
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}Cn300VldTot()
função para validação do campo Valor Total do cabeçalho da Planilha (CNA_VLTOT).

@author Flavia
@since 04/08/2015
@version P11.90
/*/
//-------------------------------------------------------------------
Function Cn300VldTot(aModelCNA, cCampo, xValor, xVlOld)
Local lRet			:= .T.
Local oModel		:= FWModelActive()
Local oModelCXM	:= oModel:GetModel("CXMDETAIL")
Local lAgrupador	:= Cn300RetSt("SEMIAGRUP")

If lAgrupador
/*
Caso o Contrato/Planilha seja do Tipo semi-fixo com Agrupador de Estoque (CNL/CN1_TPSFIX)
o valor a ser preenchido pelo usuário não poderá ser menor que a soma dos itens do Maximo a Medir (XXX_VLMAX)
*/
	If xValor < A300GetCXMV(oModelCXM) .And. !FWIsInCallStack("CN300PrCXM")
		lRet := .F.
		Help(" ",1,"Cn300VldTot",,STR0235,1,4) //-- O item ## da planilha ### não teve preço informado.
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}CN300BlqAgr()
função que trata o bloqueio dos modelos de Itens da Planilha (CNB) e
Agrupadores de Estoque por Planilha (CXM) de acordo com o Tipo de
Planilha (CNL) ou Tipo de Contrato (CN1) selecionados

@author Flavia Aguiar
@since 28/07/2015
@version P12
b= nome do campo
c= valor atual
e= valor antigo
/*/
//-------------------------------------------------------------------
Function CN300BlqAgr(oModel)
Local lRet		 := .T.
Local lDeleted	 := .T.
Local oView		 := FWViewActive()
Local oModelCNA	 := oModel:GetModel("CNADETAIL")
Local oModelCXM	 := oModel:GetModel("CXMDETAIL")
Local oModelCNB	 := oModel:GetModel("CNBDETAIL")
Local oModelCNZ	 := oModel:GetModel("CNZDETAIL")
Local oGridCNA   := Nil
Local oStruCNB	 := Nil
Local cTipPla	 := oModelCNA:GetValue('CNA_TIPPLA')
Local aSaveLines := FWSaveRows( oModel )
Local nX	     := 0

If !Empty(cTipPla)
	//- Definição do bloqueio ou liberação do campo de valor total
	oModelCNA:GetStruct():SetProperty('CNA_VLTOT',MODEL_FIELD_WHEN,{|| CN300WTot() })

	//-- Limpeza e tratamento de itens na escolha das planilhas
	If Cn300RetSt("SEMIAGRUP")
		CNTA300BlMd(oModelCXM,.F.) //- PERMITE ALTERAR AGRUPADORES

		//Verifica a existencia de linhas não deletadas na CNB
		For nX := 1 To oModelCNB:Length()
			oModelCNB:GoLine(nX)
			If !(oModelCNB:IsDeleted())
				lDeleted := .F.
				exit
			EndIf
		Next nX

		//Verifica a existencia de linhas não deletadas na CNZ
		If lDeleted
			For nX := 1 To oModelCNZ:Length()
				oModelCNZ:GoLine(nX)
				If !(oModelCNZ:IsDeleted())
					lDeleted := .F.
					exit
				EndIf
			Next nX
		EndIf

		If !lDeleted .And. (!Empty(oModelCNB:GetValue('CNB_PRODUT')) .Or. !Empty(oModelCNZ:GetValue('CNZ_PERC')))
			If MsgYesNo(STR0217)	//"Deseja realmente mudar o tipo de planilha? Os itens da planilha e rateios serão excluidos."
				CNTA300BlMd(oModelCNB,.F.)
				CNTA300BlMd(oModelCNZ,.F.)
				oModelCNB:GetStruct():SetProperty('CNB_VLUNIT',MODEL_FIELD_OBRIGAT,.F.)
				CNTA300DlMd(oModelCNB,'CNB_ITEM')
				CNTA300DlMd(oModelCNZ,'CNZ_PERC')
				oModelCNA:SetValue('CNA_VLTOT',0)
			Else
				lRet := .F.
			EndIf
		EndIf

		CNTA300BlMd(oModelCNB,.T.) //- NAO PERMITE ALTERAR OS ITENS.
		CNTA300BlMd(oModelCNZ,.T.) //- NÃO PERMITE ALTERAR RATEIOS

	Else
		//- Tratamentos do campo de quantidade
		oModelCNB:GetStruct():SetProperty("CNB_QUANT",MODEL_FIELD_WHEN,{|| .T. })
		For nX := 1 To oModelCNB:Length()
			oModelCNB:GoLine(nX)
			If !(oModelCNB:IsDeleted())
                If !(Empty(oModelCNB:GetValue("CNB_QUANT")))
                    oModelCNB:SetValue("CNB_QUANT",0)
                EndIf
			EndIf
		Next nX

		oStruCNB := oModelCNB:GetStruct()
		oStruCNB:SetProperty('CNB_QUANT',MODEL_FIELD_WHEN,{|| .F. })
		oStruCNB:SetProperty('CNB_QUANT',MODEL_FIELD_OBRIGAT, .F. )

		CNTA300BlMd(oModelCNB,.F.) //- PERMITE ALTERAR OS ITENS.
		CNTA300BlMd(oModelCNZ,.F.) //- PERMITE ALTERAR RATEIOS

		//Verifica a existencia de linhas não deletadas
		For nX := 1 To oModelCXM:Length()
			oModelCXM:GoLine(nX)
			If !(oModelCXM:IsDeleted())
				lDeleted := .F.
				exit
			EndIf
		Next nX

		If !lDeleted .And. !FWIsInCallStack('CN300Activ') .And. (!Empty(oModelCXM:GetValue('CXM_AGRTIP')) .Or. !Empty(oModelCXM:GetValue('CXM_AGRGRP')) .Or. !Empty(oModelCXM:GetValue('CXM_AGRCAT')))
			If MsgYesNo(STR0218)	//Deseja realmente mudar o tipo de planilha? Os itens da pasta Agrupamento serão excluidos.
				CNTA300BlMd(oModelCXM,.F.)
				CNTA300DlMd(oModelCXM,"CXM_ITEMID")
				oModelCNA:SetValue('CNA_VLTOT',0)
			Else
				lRet := .F.
			EndIf
		EndIf
		CNTA300BlMd(oModelCXM,.T.)	//- BLOQUEIA AGRUPADORES
	Endif
EndIf

FWRestRows(aSaveLines)

If ValType(oView) == 'O' .And. oView:IsActive() .And. oView:oModel:GetId() $ 'CNTA300|CNTA301'
    If oModelCNA:GetValue('CNA_VLTOT') == 0 .And. oModelCNA:IsUpdated()
        If oView:HasError()
			oView:ShowLastError()
		EndIf

        oView:Refresh("VIEW_CN9")
        oView:Refresh("VIEW_CNA")
        oView:Refresh("VIEW_CNB")
        
        If FwIsInCallStack('a300ChgLine') //-- Volta o foco para o grid da CNA
            oGridCNA := oView:GetViewObj('CNADETAIL')[3]
            oGridCNA:SetFocus()
        EndIf
    EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}CN300WTot()
Funcao do When do campo CNA_VLTOT para tipo de semifixo

@author Flavia
@since 04/08/2015
@version P11.90
/*/
//-------------------------------------------------------------------
Function CN300WTot()
Local lRet		   	:= .F.
Local oModel	   	:= FWModelActive()
Local oModelCXM	:= oModel:GetModel("CXMDETAIL")
Local nX    := 0
Local aSaveLines	:= FWSaveRows()

If Cn300RetSt("SEMIAGRUP")
	For nX := 1 To oModelCXM:Length()
		oModelCXM:GoLine(nX)
		If !oModelCXM:IsDeleted() .And. (oModelCXM:GetValue("CXM_VLMAX") == 0)
			lRet := .T.
			Exit
		EndIf
	Next nX
Else
	lRet := .T.
Endif

FWRestRows(aSaveLines)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300PrCXM(oModel)
Pré validação do Modelo CXM

@author guilherme.pimentel
@since 29/08/2015
@version P12
@return lret
/*/
//------------------------------------------------------------------
Function CN300PrCXM(oModelCXM,nLine,cAction,cField,xValue,xOldValue)
Local lRet			:= .T.
Local oModel		:= oModelCXM:GetModel()
Local oModelCNA		:= oModel:GetModel('CNADETAIL')
Local nValor 		:= 0

oModelCNA:GetStruct():SetProperty("CNA_VLTOT" ,MODEL_FIELD_WHEN,{||.T.})
If cAction == 'DELETE'
	If !Empty(cTipRevisa) .And. !oModelCXM:IsInserted() .And. !DelItPlSF() /* Verifica se permite deletar item da planilha semi fixa */
		Help('',1,'CNTA300ND')
		lRet := .F.
	Else
		//Variável estática para controle na deleção dos itens por agrupador não fazer a validação
		lDelSFA := .T.
		nValor := oModelCNA:GetValue('CNA_VLTOT') - oModelCXM:GetValue('CXM_VLMAX')
		oModelCNA:SetValue('CNA_VLTOT',nValor)
	EndIf
ElseIf cAction == 'UNDELETE'
	nValor := oModelCNA:GetValue('CNA_VLTOT') + oModelCXM:GetValue('CXM_VLMAX')
	oModelCNA:SetValue('CNA_VLTOT',nValor)

ElseIf cAction == 'SETVALUE'
	lDelSFA := .F.
	If cField == 'CXM_VLMAX'
		/*
		OBS: Os tratamentos devem ser feitos no Valid devido a regra de travar o campo
		     quando todos preenchidos
		*/
	EndIf
EndIf
oModelCNA:GetStruct():SetProperty("CNA_VLTOT" ,MODEL_FIELD_WHEN,{||CN300WTot()})

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300PsCXM(oModelCXM,nLine)
Pós validação do Modelo CMX

@author Israel Escorizza
@since 04/03/2016
@version V12.1.7
@return lRet
/*/
//------------------------------------------------------------------
Function CN300PsCXM(oModelCXM,nLine)
Local lRet			:= .F.
//- Verifica preenchimento dos agrupadores
If !Empty(oModelCXM:GetValue('CXM_AGRCAT')) .Or. !Empty(oModelCXM:GetValue('CXM_AGRGRP')) .Or. !Empty(oModelCXM:GetValue('CXM_AGRTIP'))
	lRet := .T.
Else
	Help(" ",1,"A300PSCXM",,STR0236,1,4)
EndIf
Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} A300GetCXMV(oModel)
Função que retorna o valor atual da soma dos itens da CXM

@author guilherme.pimentel
@since 29/08/2015
@version P12
@return lret
/*/
//------------------------------------------------------------------
Function A300GetCXMV(oModelCXM)
Local aSaveLines	:= FWSaveRows()
Local nValor := 0
Local nX := 0

For nX := 1 to oModelCXM:Length()
	oModelCXM:GoLine(nX)
	If !oModelCXM:IsDeleted()
		nValor += oModelCXM:GetValue("CXM_VLMAX")
	EndIf
Next nX

FWRestRows(aSaveLines)
Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} A300VldVMax(oModel)
Validação do valor máximo

@author guilherme.pimentel
@since 29/08/2015
@version P12
@return lret
/*/
//------------------------------------------------------------------
Function A300VldVMax(oModelCXM,cField,xValue,nLine,xOldValue)
Local oModel 	:= FWModelActive()
Local oModelCNA := oModel:GetModel('CNADETAIL')
Local nValor	:= 0
Local nX		:= 0
Local lRet 		:= .T.
Local lVlMax	:= .T.
Local cSeekR	:= ""

Default oModelCXM := oModel:GetModel('CXMDETAIL')

If Empty(oModelCXM:GetValue("CXM_AGRTIP")) .And. Empty(oModelCXM:GetValue("CXM_AGRGRP")) .And. Empty(oModelCXM:GetValue("CXM_AGRCAT"))
	lRet := .F.
	Help(" ",1,"A300VldVMax",,STR0237,1,4)
EndIf

If !Empty(cTipRevisa) .And. Cn300RetSt("REVESPECIE") $ '1|2|4|5'
	cSeekR := oModelCXM:GetValue('CXM_FILIAL')+oModelCXM:GetValue('CXM_CONTRA')+oModelCXM:GetValue('CXM_REVISA')+;
			  oModelCXM:GetValue('CXM_NUMERO')+oModelCXM:GetValue('CXM_ITEMID')

	nValor := Posicione('CXM',1,cSeekR,'CXM_VLMAX' )

	If Cn300RetSt("MODALIDADE") == "1" .And. xValue < nValor
		lRet := .F.
	EndIf

	If Cn300RetSt("MODALIDADE") == "2" .And. xValue > nValor
		lRet := .F.
	EndIf
EndIf

If lRet
	oModelCNA:GetStruct():SetProperty("CNA_VLTOT" ,MODEL_FIELD_WHEN,{||.T.})

	For nx := 1 To oModelCXM:Length()
		oModelCXM:GoLine(nX)
		If !oModelCXM:IsDeleted()
			If Empty(oModelCXM:GetValue('CXM_VLMAX'))
				lVlMax := .F.
			EndIf
		EndIf
	Next nX

	nValor := A300GetCXMV(oModelCXM)

	oModelCXM:GoLine(nLine)

	If lVlMax .Or. !CN300WTot()
		oModelCNA:SetValue('CNA_VLTOT',nValor)
	Else
		If oModelCNA:GetValue('CNA_VLTOT') < nValor
			oModelCNA:SetValue('CNA_VLTOT',nValor)
	  	EndIf
	EndIf

	oModelCNA:GetStruct():SetProperty("CNA_VLTOT" ,MODEL_FIELD_WHEN,{||CN300WTot()})
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300EXPRZ()
Função pra validar prazo

@author Filipe Gonçalves
@since 14/10/2015
/*/
//-------------------------------------------------------------------
Function CN300EXPRZ(oModel)
Local aArea		:= GetArea()
Local aSaveLines:= FWSaveRows()
Local oModelCN9	:= oModel:GetModel("CN9MASTER")
Local cCodEd	:= oModelCN9:GetValue("CN9_CODED")
Local cNumPro	:= oModelCN9:GetValue("CN9_NUMPR")
Local dDtaIni	:= oModelCN9:GetValue("CN9_DTINIC")
Local lVlPrz	:= ExistBlock("CN300VLP")
Local dDataF	:= CtoD("")
Local cEspeci	:= ""
Local lRet 		:= .T.

dDataF := CN300DtFim(oModelCN9:GetValue('CN9_UNVIGE'),oModelCN9:GetValue('CN9_DTINIC'),oModelCN9:GetValue('CN9_VIGE'))

DbSelectArea("CO1")
CO1->(DbSetOrder(1))
If CO1->(MsSeek(xFilial("CO1") + cCodEd + cNumPro))
	cEspeci := CO1->CO1_ESPECI
EndIf

If cEspeci == "3"
	If (dDataF - dDtaIni) > 1825
		Help(" ",1,"C300EXPRZ1",,STR0164,4,1)	//"O aditivo de prazo excedeu o prazo de 60 meses para locação de imóvel e cessão de espaço"
		lRet := .F.
	EndIf
EndIf

If lRet .And. lVlPrz
	lRet :=  ExecBlock("CN300VLP",.F.,.F.,{oModel})
EndIf

RestArea(aArea)
FWRestRows( aSaveLines )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300VLUGAT

Gatilho da sequencia 001 do campo CNB_VLUNIT

@author guilherme.pimentel
@since 22/06/2016
/*/
//-------------------------------------------------------------------
Function A300VLUGAT()
Local aArea		:= GetArea()
Local aSaveLines:= FWSaveRows()
Local oModel	:= FwModelActive()
Local oModelCNB	:= Nil
Local nRet 		:= 0

	If oModel:GetId() == "CNTA300"
		oModelCNB := oModel:GetModel("CNBDETAIL")
		nRet := Round(oModelCNB:GetValue("CNB_QUANT") * oModelCNB:GetValue("CNB_VLUNIT"),TamSX3("CNB_VLTOT")[2])
	EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300VLDESC

Gatilho da sequencia 002 do campo CNB_VLUNIT

@author joni.carmo
@since 16/08/2016
/*/
//-----------------------------------------------------------------
Function A300VLDESC()
	Local aArea		:= GetArea()
	Local aSaveLines:= FWSaveRows()
	Local oModel	:= FwModelActive()
	Local oModelCNB	:= Nil
	Local nRet 		:= 0

	If oModel:GetId() == "CNTA300"
		oModelCNB := oModel:GetModel("CNBDETAIL")
		nRet := Round(oModelCNB:GetValue('CNB_VLTOT') * oModelCNB:GetValue('CNB_DESC')/100, TamSx3("CNB_VLDESC")[2])
	EndIf

	FWRestRows( aSaveLines )
	RestArea(aArea)

Return nRet

//------------------------------------------------------------------
/*/{Protheus.doc} MdlActive()
Função com retorno booleano que identifica se o id modelo passado como
parametro é o modelo ativo.

@author Matheus Lando Raimundo
@since 29/03/2016
@version P12
@Return lRet
/*/
//-------------------------------------------------------------------
Function MdlActive(cModel)
Local lRet := .F.
Local oModel := FwModelActive()

lRet := oModel:GetId() == cModel

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300LJ
Função utilizada no gatilho do campo CNC_CODIGO para retornar o
codigo da loja

@author jose.delmondes
@since 14/04/2016
/*/
//-------------------------------------------------------------------
Function CN300LJ(cForn)
Local aArea := GetArea()
Local cLoja	:= ""

dbSelectArea("SA2")
dbSetOrder(1)

If dbSeek(xFilial("SA2")+cForn)
	While !SA2->(EOF()) .And. SA2->A2_COD == cForn
		cLoja := SA2->A2_LOJA
		If SA2->A2_MSBLQL == '1'
			SA2->(dbSkip())
		Else
			Exit
		EndIf
	End
EndIf

RestArea(aArea)

Return cLoja

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VlTot
Valid do campo CNA_VLTOT

@author jose.delmondes
@since 14/04/2016
/*/
//-------------------------------------------------------------------
Function CN300VlTot(xOldValue)
Local aSaveLines	:= FWSaveRows()
Local oModel 		:= FWModelActive()
Local oModelCN9		:= oModel:GetModel("CN9MASTER")
Local oModelCNA		:= oModel:GetModel("CNADETAIL")

Local nTotal 		:= oModelCNA:GetValue("CNA_VLTOT")
Local nTotMed		:= 0
Local nDifValor		:= 0

Local lRet			:= .T.

Local cModo		:= ""
Local cUmAlias	:= ""
Default xOldValue := 0

//caso o total de uma planilha flexível seja alterado em uma revisão, abate do saldo o valor já medido.
If !Empty(cTipRevisa) .And. Cn300RetSt("EVENTUAL")
	cUmAlias := GetNextAlias()
	BeginSQL Alias cUmAlias
		SELECT SUM(CND.CND_VLTOT) CND_VLTOT
		FROM 	%Table:CND% CND
		WHERE	CND.CND_FILCTR = %Exp:oModelCN9:GetValue('CN9_FILCTR')% 
				AND CND.CND_CONTRA = %Exp:oModelCN9:GetValue('CN9_NUMERO')%
				AND CND.CND_NUMERO = %Exp:oModelCNA:GetValue('CNA_NUMERO')%
				AND CND.CND_REVISA = %Exp:CnRevAnt(.F., oModelCN9:GetValue('CN9_REVISA'))% 
				AND CND.%NotDel%
	EndSQL		
	nTotMed := (cUmAlias)->(IIF(EOF(),0,CND_VLTOT))
	(cUmAlias)->(dbCloseArea())
	
	If nTotal < nTotMed
		Help('',1,'CN300VLTOT',,STR0182,3)	//"O Montante da planilha não pode ser menor que o valor já medido."
		lRet := .F.
	EndIf
EndIf

If lRet .And. !Empty(cTipRevisa) .And. cTipRevisa == DEF_REV_REALI  .And. !CN300Retst('FIXO')
	cModo	:=  Cn300RetSt("MODALIDADE")
	If cModo == '1' //Acrescimo
		If oModelCNA:GetValue("CNA_VLTOT") < Posicione( "CNA" , 1 , xFilial("CNA")+oModelCNA:GetValue("CNA_CONTRA")+oModelCNA:GetValue("CNA_REVISA")+oModelCNA:GetValue("CNA_NUMERO") , "CNA_VLTOT" )
			lRet := .F.
			Help("",1,"A300MODREALI") //Modalidade da revisão (Acrescimo/Decrescimo) não respeitado
		EndIf
	ElseIf cModo == '2' //Decrescimo
		If oModelCNA:GetValue("CNA_VLTOT") > Posicione( "CNA" , 1 , xFilial("CNA")+oModelCNA:GetValue("CNA_CONTRA")+oModelCNA:GetValue("CNA_REVISA")+oModelCNA:GetValue("CNA_NUMERO") , "CNA_VLTOT" )
			lRet := .F.
			Help("",1,"A300MODREALI") //Modalidade da revisão (Acrescimo/Decrescimo) não respeitado
		EndIf
	EndIf
EndIf

If lRet

	nDifValor := oModelCNA:GetValue("CNA_VLTOT") - xOldValue

	If !(!Empty(cTipRevisa) .And. Cn300RetSt("RECORRENTE")) .Or. (cTipRevisa == DEF_REV_ORCGS .And. Cn300RetSt("RECORRENTE"))
		oModelCN9:LoadValue("CN9_VLATU",  oModelCN9:GetValue("CN9_VLATU") + nDifValor )
		oModelCN9:LoadValue("CN9_SALDO",  oModelCN9:GetValue("CN9_SALDO") + nDifValor )
	EndIf

	If Empty(cTipRevisa) .AND. Empty(cAprTipRev)  //Se não estiver sendo realizada nenhum tipo de revisão no contrato, o campo Valor inicial é atualizado.
		oModelCN9:LoadValue("CN9_VLINI",  oModelCN9:GetValue("CN9_VLATU"))		
	ElseIf !Empty(cTipRevisa) .And. (cTipRevisa $ DEF_REV_ADITI+DEF_REV_ABERT+DEF_REV_RENOV)// Alimenta o campo CN9_VLADIT em revisões de aditivo
		oModelCN9:LoadValue( "CN9_VLADIT", oModelCN9:GetValue("CN9_VLADIT") + nDifValor )
	EndIf
	
EndIf

FWRestRows( aSaveLines )

Return  lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CNT300Reset
Função que reinicia as variáveis
@author clemente.neto
@since 09/05/2016
/*/
//-------------------------------------------------------------------
Function CNT300Rese()

cTipRevisa   := ''
cAprTipRev   := ''
cModel       := ''
cContrat     := ''
lRevisado    := .F.
lUserBut     := .F.
aLineCNF     := {}
aDelsCNF     := {}
aDelsCNS     := {}
lAdiant      := .F.
aVldUsr      := {}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VLCNS
Valida adição de itens no cronograma fisico

@author jose.delmondes
@since 10/05/2016
/*/
//-------------------------------------------------------------------
Function CN300VLCNS(oModelCNS, cItPlan)
Local aSaveLines	:= FWSaveRows()
Local lRet	:= .T.
Local nX	:= 0

For nX := 1 To oModelCNS:Length()
	oModelCNS:GoLine(nX)
	If oModelCNS:GetValue("CNS_ITEM") == cItPlan .And. !oModelCNS:IsDeleted()
		lRet := .F.
	EndIf
Next nX

FWRestRows( aSaveLines )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VLCNS
Inicializador padrão do campo CN9_NUMERO

@author jose.delmondes
@since 18/08/2016
/*/
//-------------------------------------------------------------------
Function CN300Num()
Local cNum := ''
Local aArea		:= GetArea()
Local aAreaCN9	:= CN9->(GetArea())

If !FWIsInCallStack('CN300REV')
	dbSelectArea("CN9")
	dbSetOrder(1)
	dbGoTop()

	cNum := GETSXENUM('CN9','CN9_NUMERO')

	While CN9->(msSeek(xFilial("CN9")+cNum))
		If ( __lSx8 )
			ConfirmSX8()
		EndIf
		cNum := GETSXENUM('CN9','CN9_NUMERO')
	EndDo
EndIf

RestArea(aAreaCN9)
RestArea(aArea)

Return cNum

//-------------------------------------------------------------------
/*/{Protheus.doc} A300lAdian()
Função para Atribuir na variavel estatica lAdiant

@author Alex Egydio
@since 24/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function A300lAdian(lValue)
	lAdiant := lValue
Return

//----------------------------------------------------------------------------------------
/*/{Protheus.doc} Cn300AtuSld()
Função para atualizar valor do campo CNB_SLDMED após alteração do campo CNB_QUANT

@author 	Israel.Escorizza
@since 		25/11/2016
@version 	1.0
/*/
//-----------------------------------------------------------------------------------------
Function Cn300AtuSld()
Local oModel		:= 	FwModelActive()
Local oModelCNB	:=	oModel:GetModel('CNBDETAIL')
Local lRet			:= .T.
Local lCanSetVl	:= 	oModelCNB:CanSetValue('CNB_SLDMED')
Local nSldMed		:= 	oModelCNB:GetValue('CNB_QUANT') - oModelCNB:GetValue('CNB_QTDMED')

If !lCanSetVl
	oModelCNB:GetStruct():SetProperty('CNB_SLDMED',MODEL_FIELD_WHEN,{|| .T.})
EndIf

If !(lRet := oModelCNB:SetValue('CNB_SLDMED',nSldMed))
	Help('',1,'CN300SLDERR') //- Não foi possivel atribuir saldo.
EndIf

oModelCNB:GetStruct():SetProperty('CNB_SLDMED',MODEL_FIELD_WHEN,{|| lCanSetVl})

Return lRet

//=============================================================================
/*/{Protheus.doc} Cn300ItSrv(nTipOpr,nParcelas)
Função responsável pela atualização do campo “CNB_QUANT” de cada item contido na
planilha quando esta for de serviços.

@author israel.escorizza
@since 10/05/2016
@return
/*/
//=============================================================================
Function Cn300ItSrv(nTipOpr,nParcelas)
Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oModel 		:= FwModelActive()
Local oModelCNB		:= oModel:GetModel('CNBDETAIL')
Local nX			:= 1

Default nTipOpr		:= 1
Default nParcelas	:= 0

For nX := 1 To oModelCNB:Length()
	oModelCNB:GoLine(nX)
	If Empty(oModelCNB:GetValue('CNB_ITMDST'))
		oModelCNB:GetStruct():SetProperty('CNB_QUANT' ,MODEL_FIELD_WHEN,{||.T.})
		oModelCNB:GetStruct():SetProperty('CNB_SLDMED',MODEL_FIELD_WHEN,{||.T.})
		DO 	CASE
			CASE nTipOpr == 1
				oModelCNB:SetValue('CNB_QUANT' ,nParcelas)
				oModelCNB:SetValue('CNB_SLDMED',nParcelas)
			CASE nTipOpr == 2
				oModelCNB:SetValue('CNB_QUANT' ,oModelCNB:GetValue('CNB_QUANT')  + nParcelas)
			CASE nTipOpr == 3
				oModelCNB:SetValue('CNB_QUANT' ,oModelCNB:GetValue('CNB_QUANT')  - nParcelas)
		ENDCASE
		oModelCNB:GetStruct():SetProperty('CNB_QUANT' ,MODEL_FIELD_WHEN,{||.F.})
		oModelCNB:GetStruct():SetProperty('CNB_SLDMED',MODEL_FIELD_WHEN,{||.F.})
	EndIf
Next nX

RestArea(aArea)
FWRestRows( aSaveLines )
Return

//=============================================================================
/*/{Protheus.doc} CN300CnaPre(nLine,cAction,cCampo,xValue,xOldValue,oModelGrid)
Função bPre da grip CNA

@author israel.escorizza
@since 23/05/2016
@return
/*/
//=============================================================================
Static Function CN300CnaPre(nLine,cAction,cCampo,xValue,xOldValue,oModelGrid)
Local aArea			:= GetArea()
Local aSaveLines	:= FwSaveRows()
Local oModel 		:= oModelGrid:GetModel()
Local lRet			:= .T.

If cAction == "ADDLINE"
	//- Libera filhos da CNA
	CNTA300BlMd(oModel:GetModel('CNBDETAIL'),.F.)
	CNTA300BlMd(oModel:GetModel('CXMDETAIL'),.F.)
	CNTA300BlMd(oModel:GetModel('CNFDETAIL'),.F.)
	CNTA300BlMd(oModel:GetModel('CXIDETAIL'),.F.)
ElseIf cAction == "UNDELETE"
	If nModulo == 28
		If FindFunction("TecPreCNA") .AND. FWIsInCallStack("At870EftRv")
			lRet := TecPreCNA( cAction, oModel, oModelGrid)
		EndIf
	EndIf
ElseIf cAction == "DELETE"
	If nModulo == 28
		If FindFunction("TecPreCNA") .AND. FWIsInCallStack("At870EftRv")
			lRet := TecPreCNA( cAction, oModel, oModelGrid)
		EndIf
	EndIf
EndIf

FWRestRows(aSaveLines)
RestArea(aArea)
Return lRet

//=============================================================================
/*/{Protheus.doc} CN300VFoCl()
Função para exibir cadastro de fornecedor / cliente na visualização do contrato

@author israel.escorizza
@since 16/01/2017
@return
/*/
//=============================================================================
Function CN300VFoCl()
Local oModel	:= FwModelActive()
Local oView		:= FwViewActive()

Local lCompra	:= Cn300RetSt('COMPRA') //oModelCN9:GetValue("CN9_ESPCTR")=="1"
Local lRet		:= .T.

Local cFilCtr	:= oModel:GetValue('CN9MASTER','CN9_FILCTR')
Local cCpoCodi	:= ''
Local cCpoLoja	:= ''
Local cForCli	:= ''
Local cLoja		:= ''


If 	oView:GetFolderActive("FLDCNT", 2)[1] == 1				//Se Folder de Fornecerdor/Cliente estiver ativa
	cCpoCodi	:= If(lCompra,"CNC_CODIGO"	,"CNC_CLIENT")
	cCpoLoja	:= If(lCompra,"CNC_LOJA"	,"CNC_LOJACL")
	cForCli		:= oModel:GetValue('CNCDETAIL',cCpoCodi)
	cLoja		:= oModel:GetValue('CNCDETAIL',cCpoLoja)

ElseIf oView:GetFolderActive("FLDCNT", 2)[1] == 2			//Se Folder de planilhas
	cCpoCodi	:= If(lCompra,"CNA_FORNEC","CNA_CLIENT")
	cCpoLoja	:= If(lCompra,"CNA_LJFORN","CNA_LOJACL")
	cForCli		:= oModel:GetValue('CNADETAIL',cCpoCodi)
	cLoja		:= oModel:GetValue('CNADETAIL',cCpoLoja)
Else
	lRet := .F.
	Aviso(STR0195,STR0196,{STR0222})
EndIf

If lRet
	CN121VFoCl(lCompra,cForCli,cLoja,cFilCtr)
EndIf

Return lRet
//=============================================================================
/*/{Protheus.doc} DelItPlSF()
Função para validação da deleção de itens de planilhas semifixa.

@author israel.escorizza
@since 16/01/2017
@return
/*/
//=============================================================================
Static Function DelItPlSF()
Local cModo     := Cn300RetSt("MODALIDADE")
Local cEspec    := Cn300RetSt("REVESPECIE")

Return cEspec $ "1|4|5" .And. cModo $ '2|3' .And. CN300Retst('SEMIFIXO')
//----------------------------------------------------------------------------------------
/*/{Protheus.doc} CN300VlPer()
Validação da periodicidade de contratos recorrentes com cronograma

@author 	guilherme.pimentel
@since 		10/05/2017
@version 	1.0
/*/
//-----------------------------------------------------------------------------------------
Function CN300VlPer(oModelCNA,cField,xValue)
Local lRet := .T.

If Cn300RetSt("RECORRENTE") .And. Cn300RetSt("PREVFINANC")
	If cField == 'CNA_PERIOD'

		If !(xValue $ "1|3")
			lRet := .F.
			Help('',1,'CN300VlPer',,STR0238,3)
		ElseIf xValue == "3"
			oModelCNA:LoadValue('CNA_PERREC',1)
		EndIf

	ElseIf cField == 'CNA_PERREC'

		If oModelCNA:GetValue('CNA_PERIOD') == '3' .And. xValue <> 1
			lRet := .F.
			Help('',1,'CN300VlPer',,STR0239,3)
		EndIf

	EndIf
EndIf

Return lRet

//=============================================================================
/*/{Protheus.doc} Cn300PdNum()
Função que retorna numero do pedido da SC7 (Campo não utilizado/Browse = N)
Ação deve ser realizada por query pois não traz no posicionamento.

@author israel.escorizza
@since 24/08/2016
@return cRet
/*/
//=============================================================================
Function Cn300PdNum()
Local cAliasTemp	:= GetNextAlias()
Local cRet := ""
Local cQuery := ""

If (_oC7PreSta == Nil)//FWPreparedStatement p/ consulta dos pedidos

	cQuery := "SELECT C7_NUM FROM " + RetSqlName("SC7") + " SC7"
	cQuery += " INNER JOIN "+RetSqlName("CND") +" CND ON("
	cQuery += " CND.CND_CONTRA 		= SC7.C7_CONTRA" 
	cQuery += " AND CND.CND_REVISA	= SC7.C7_CONTREV"
	cQuery += " AND CND.CND_NUMMED	= SC7.C7_MEDICAO"
	cQuery += " AND "+ FWJoinFilial("CND", "SC7")
	cQuery += " AND CND.D_E_L_E_T_ = ' '"
	cQuery += ") WHERE "	
	cQuery += " SC7.C7_FILIAL 	= ?"
	cQuery += " AND SC7.C7_CONTRA 	= ?"
	cQuery += " AND SC7.C7_CONTREV	= ?"
	cQuery += " AND SC7.C7_MEDICAO	= ?"
	cQuery += " AND SC7.C7_PLANILH	= ?"
	cQuery += " AND SC7.C7_ITEM 	= ?"
	cQuery += " AND SC7.C7_SEQUEN	= ?"
	cQuery += " AND SC7.C7_QUANT	= ?"
	cQuery += " AND SC7.D_E_L_E_T_ = ' '"

	_oC7PreSta := FWPreparedStatement():New(ChangeQuery( cQuery ))
EndIf
_oC7PreSta:SetString(1, SC7->C7_FILIAL)
_oC7PreSta:SetString(2, SC7->C7_CONTRA)
_oC7PreSta:SetString(3, SC7->C7_CONTREV)
_oC7PreSta:SetString(4, SC7->C7_MEDICAO)
_oC7PreSta:SetString(5, SC7->C7_PLANILH)
_oC7PreSta:SetString(6, SC7->C7_ITEM)
_oC7PreSta:SetString(7, SC7->C7_SEQUEN)
_oC7PreSta:SetNumeric(8, SC7->C7_QUANT)

dbUseArea( .T., "TopConn", TCGenQry(,,_oC7PreSta:getFixQuery()), cAliasTemp, .F., .F. )

If (cAliasTemp)->(!Eof())
	cRet := (cAliasTemp)->C7_NUM
EndIf

(cAliasTemp)->(dbClosearea())
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300ExcArt(oModel,cTipo)
Função que verifica se o processo licitatório contém o artigos que permitem excessões.
@param	oModel
		cTipo		"ADITIVO" 	- Artigo 65 	da LEI Nº 8.666 , DE 21 DE JUNHO DE 1993
								- Artigo 81 	da LEI Nº 13.303, DE 30 DE JUNHO DE 2016
								- Atrigo 29		da LEI Nº 2 ATO PRE/CN/SEST/Nº. 003/12
					"PRAZO"		- Artigo 57 §4 	da LEI Nº 8.666 , DE 21 DE JUNHO DE 1993

@Author israel.escorizza
@since 01/12/2017
/*/
//-------------------------------------------------------------------
Function CN300ExcArt(oModel,cTipo)
Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oModelCN9		:= Nil
Local lRet 			:= .F.

Local cMod			:= ''
Local cLei 			:= ''
Local cCodEd		:= ''
Local cNumPro		:= ''
Local cCtrFil		:= ''
Local cArt			:= ''
Local cMsg			:= ''
Local cHelp			:= ''
Local lA300POSC 	:= ExistBlock("A300POSC")

Default oModel 		:= FwModelActive()
Default cTipo		:= ''

If oModel != Nil
	oModelCN9	:= oModel:GetModel("CN9MASTER")
	cCodEd		:= oModelCN9:GetValue("CN9_CODED")
	cNumPro		:= oModelCN9:GetValue("CN9_NUMPR")
	cCtrFil		:= oModelCN9:GetValue(Iif(Empty(cCodEd),"CN9_FILCTR",'CN9_FILEDT'))

	DbSelectArea("CO1")
	CO1->(DbSetOrder(1))
	If lA300POSC  //Ponto de entrada para Posicionamento  no contrato
		lRet := ExecBlock('A300POSC',.F.,.F.,{cCTRFil,cCodEd,cNumPro})
		If !(ValType(lRet) == 'L')
			lRet := .F.
		EndIf
	Else	
		lRet:= CO1->(DbSeek(xFilial("CO1",cCTRFil)+cCodEd+cNumPro))
	EndIf
		
	If lRet
		cMod := CO1->CO1_MODALI
		cLei := CO1->CO1_LEI
	EndIf

	If lRet
		DO	CASE
			CASE cTipo == 'ADITIVO' .And. cLei $ '1*3'
				cArt := '65'
				cMsg := STR0209			//- Artigo 65 da LEI Nº 8.666, DE 21 DE JUNHO DE 1993 não informado no processo licitatório. Deseja incluir artigo no processo licitatório?
				cHelp:= "CN300ART65"	//- Artigo 65 da LEI Nº 8.666, DE 21 DE JUNHO DE 1993 não informado no processo licitatório.

			CASE cTipo == 'ADITIVO' .And. cLei == '5'
				cArt := '81'
				cMsg := STR0259			//- Artigo 81 da LEI Nº 13.303, DE 30 DE JUNHO DE 2016 não informado no processo licitatório. Deseja incluir artigo no processo licitatório?
				cHelp:= "CN300ART81"	//- Artigo 81 da LEI Nº 13.303, DE 30 DE JUNHO DE 2016 não informado no processo licitatório.

			CASE cTipo $'ADITIVO/PRAZO'	.And. cLei == '2'
				cArt := '29'
				cMsg := STR0277			//- Artigo 29 do ATO PRE/CN/SEST/Nº. 003/12 não informado no processo licitatório. Deseja incluir artigo no processo licitatório?
				cHelp:= "CN300ART29"	//- Artigo 29 do ATO PRE/CN/SEST/Nº. 003/12 não informado no processo licitatório.

			CASE cTipo == 'PRAZO' .And. cLei $ '1*3'
				cArt := '57'
				cMsg := STR0260			//- Artigo 57 da LEI Nº 8.666, DE 21 DE JUNHO DE 1993 não informado no processo licitatório. Deseja incluir artigo no processo licitatório?
				cHelp:= "CN300ART57"	//- Artigo 57 da LEI Nº 8.666, DE 21 DE JUNHO DE 1993 não informado no processo licitatório.
                
            CASE lA300POSC .And. Empty(cLei)
				lRet := .T. //Retorna verdadeiro caso contrato possua edital oriundo de processo externo, pois as validações são realizadas no PE A300POSC.
			
            OTHERWISE
				lRet := .F.

		END CASE

		If lRet .And. !Empty(cLei) .And. (Empty(aIncArt) .Or. aScan(aIncArt,{|x|x[6] == cArt}) == 0)
			DbSelectArea("CX4")
			CX4->(DbSetOrder(1)) //- CX4_FILIAL	+CX4_CODEDT+CX4_NUMPRO+CX4_MODALI+CX4_LEI+CX4_ARTIGO+CX4_PARAG
			If !CX4->(dbSeek(xFilial("CX4",CO1->CO1_FILIAL)+cCodEd+cNumPro+cMod+cLei+cArt))
				If !IsBlind()
					If lRet := MsgYesNo(cMsg,STR0090)
						aAdd(aIncArt,{CO1->CO1_FILIAL,cCodEd,cNumPro,cMod,cLei,cArt})
					Else
						Help("",1,cHelp)
						lRet := .F.
					EndIf
				Else
					aAdd(aIncArt,{CO1->CO1_FILIAL,cCodEd,cNumPro,cMod,cLei,cArt})
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet

//=============================================================================
/*/{Protheus.doc} Cn300VlServ(oModelGrid,xValue,nLinha)
Função que verifica e valida itens de serviço na inclusão de itens do contrato.

@author israel.escorizza
@since 23/05/2016
@return
/*/
//=============================================================================
Function Cn300VlServ(oModelGrid,xValue,nLinha)
Local aArea			:= GetArea()
Local aSaveLines	:= FwSaveRows()
Local lRet			:= .T.
Local nTipPla		:= 0
Local cTipItm		:= ""
Local oModel		:= ""

Default oModelGrid 	:= Nil
Default xValue	   	:= ""
Default nLinha		:= 1

If 	(lRet := oModelGrid != Nil)

	oModel	:= oModelGrid:GetModel()
	cTipItm	:= Posicione('SB5',1,xFilial('SB5')+xValue,'B5_TIPO')

	If Empty(cTipItm)
		cTipItm := '1'
	ElseIf cTipItm == "2" .And. CN300RetSt('FISICO',0)
		lRet := .F.
		Help("",1,"A300SRVFIS",,STR0210,1,1)
	EndIf

	If lRet .And. ExistFunc("CnTpProd")
		nTipPla := CnTpProd("CNTA300", oModel:GetValue('CNADETAIL','CNA_NUMERO'),oModel:GetValue('CN9MASTER','CN9_NUMERO') ,oModel:GetValue('CN9MASTER','CN9_REVISA'),nLinha)

		If (nTipPla == 2 .And. cTipItm != '2') .Or. (nTipPla == 1 .And. cTipItm == '2')
			lRet := .F.
			Help("",1,"A300ITMDIF",,STR0211,1,1)
		EndIf
	EndIf
EndIf

FWRestRows(aSaveLines)
RestArea(aArea)
Return lRet

//=============================================================================
/*/{Protheus.doc} CN300BlqCot(oModel)
Bloqueia o modelo quando gerado por cotacao

@author jose.delmondes
@since 18/09/2017
@return
/*/
//=============================================================================
Function CN300BlqCot(oModel)
Local oModelCN9	:= oModel:GetModel('CN9MASTER')
Local oModelCNZ := oModel:GetModel('CNZDETAIL')
Local oModelCNC := oModel:GetModel('CNCDETAIL')
Local oModelCNA	:= oModel:GetModel('CNADETAIL')
Local oModelCNB := oModel:GetModel('CNBDETAIL')
Local aCampos	:= {}
Local lPosSC	:= IIf(CN9->(FieldPos("CN9_XSCORI")) > 0, Empty(oModelCN9:GetValue("CN9_XSCORI")), .T.)

CNTA300BlMd(oModelCNZ,.T.)
CNTA300BlMd(oModelCNC,.T.)
CNTA300BlMd(oModelCNA,.T.,.T.)
CNTA300BlMd(oModelCNB,.T.,.T.)

If lPosSC
	aAdd(aCampos,{'CNADETAIL',{'CNA_FORNEC','CNA_LJFORN'}})
	MtBCMod(oModel,aCampos,{||.F.},'2')
	aCampos	:= {}
EndIf

aAdd(aCampos,{'CNBDETAIL',{'CNB_PRODUT','CNB_QUANT','CNB_VLUNIT','CNB_VLTOTR','CNB_DESC','CNB_VLDESC','CNB_CONTA','CNB_ITEMCT','CNB_CC','CNB_CLVL' }})
MtBCMod(oModel,aCampos,{||.F.},'2')

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} cn300VldTB()
Valid do campo CNB_TABPRC.
Valida tabela de preço por espécie de contrato.

@author antenor.silva
@since 03/10/2017
@version 1.0
/*/
//----------------------------------±--------------------------------
Function cn300VldTB()
	Local oModel		:= FWModelActive()
	Local oModelCN9		:= oModel:GetModel("CN9MASTER")
	Local cEspecie		:= oModelCN9:GetValue("CN9_ESPCTR")
	Local lRet			:= .F.
	Local cCodTab		:= ""
	Local dValidade		:= Nil
	
	If cEspecie == '2'
		cCodTab := FwFldGet('CNB_TABPRC')
		DA0->(DbSetOrder(1))		
		If(lRet := DA0->(DbSeek(xFilial("DA0") + cCodTab)))			
			If(Empty((dValidade := oModelCN9:GetValue('CN9_DTREV'))))			
				dValidade := FwFldGet('CNA_DTINI')
			EndIf
								
			lRet := DA0->( dValidade >= DA0_DATDE .And. (Empty(DA0_DATATE) .Or. dValidade <= DA0_DATATE) )
			If(!lRet)				
				Help(" ",1,"OMSTABPRC1")
			EndIf			
		Else
			Help(" ",1,"REGNOIS")	
		EndIf		
	Else
		lRet := MaVldTabCom(FwFldGet('CNA_FORNEC'),FwFldGet('CNA_LJFORN'),FwFldGet('CNB_TABPRC'))
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} C300VldTaB()
Função de gatilho do valor do produto baseado na tabela de preço.
No item da planilha.

@author antenor.silva
@since 04/10/2017
@return nRet
/*/
//-------------------------------------------------------------------
Function C300VldTaB()
Local nRet 		:= 0
Local oModel 	:= FwModelActive()
Local oModelCN9 := oModel:GetModel('CN9MASTER')
Local oModelCNA := oModel:GetModel('CNADETAIL')
Local oModelCNB := oModel:GetModel('CNBDETAIL')
Local cContra 	:= oModelCN9:GetValue('CN9_NUMERO')
Local nMoeda	:= oModelCN9:GetValue('CN9_MOEDA')
Local dDataInic	:= oModelCN9:GetValue('CN9_DTINIC')
Local cForn		:= oModelCNA:GetValue('CNA_FORNEC')
Local cLojaF	:= oModelCNA:GetValue('CNA_LJFORN')
Local cClien	:= oModelCNA:GetValue('CNA_CLIENT')
Local cLojaC	:= oModelCNA:GetValue('CNA_LOJACL')
Local cCodTab	:= oModelCNB:GetValue('CNB_TABPRC')
Local cProduto	:= oModelCNB:GetValue('CNB_PRODUT')
Local nQtd		:= oModelCNB:GetValue('CNB_QUANT')
Local lCompra	:= Cn300RetSt('COMPRA', 0,, cContra)

nQtd := Iif(nQtd == 0,1,nQtd)

If(!Empty(oModelCN9:GetValue('CN9_DTREV')))
	dDataInic := oModelCN9:GetValue('CN9_DTREV')
EndIf

If !lCompra
	If Empty(cCodTab)
		cCodTab	:= Posicione("SA1",1,xFilial("SA1")+cClien+cLojaC,"A1_TABELA")
		oModelCNB:LoadValue('CNB_TABPRC',cCodTab)
	EndIf
	nRet := MaTabPrVen(cCodTab,cProduto,nQtd,cClien,cLojaC,nMoeda,dDataInic)
Else
	nRet := MaTabPrCom(cCodTab,cProduto,nQtd,cForn,cLojaF,nMoeda,dDataInic)
EndIf
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300RatP(oModel)
Função de importação de Rateio Pré-Configurado

@author jose.delmondes
@since 05/12/2017
/*/
//-------------------------------------------------------------------
Function CN300RatP(oModel, oView, aAuto)
Local aArea		:= GetArea()
Local aAreaCNB	:= CNB->(GetArea())
Local aSaveLines:= FWSaveRows()
Local oModelCNB	:= oModel:GetModel('CNBDETAIL')
Local oModelCNZ	:= oModel:GetModel('CNZDETAIL')
Local nPos		:= 0
Local cChave	:= ""
Local bRateio	:= { |x,y,z| GCTRatMVC(x,@y,z) }
Local cItem		:= ''
Default oView   := Nil
Default aAuto   := {}

dbSelectArea("CNB")
CNB->(dbSetOrder(1))

If oModelCNB:IsDeleted() .Or. Empty(oModelCNB:GetValue('CNB_PRODUT'))
    Help("",1,"CN300RATP",,STR0262,4,1)
ElseIf !Empty(cTipRevisa) .And. CNB->(dbSeek(xFilial("CNB")+oModelCNB:GetValue("CNB_CONTRA")+CnRevAnt()+oModelCNB:GetValue("CNB_NUMERO")+oModelCNB:GetValue("CNB_ITEM")))
    Help("",1,"CN300RATP",,STR0263,4,1)
ElseIf ValType(oView) == "O" .And. oView:IsActive()
    AdmRatExt( , , bRateio, oModelCNZ )
	If oView:HasError()
		oView:ShowLastError()
	EndIf
ElseIf Len(aAuto) > 0
	If (nPos := aScan(aAuto, {|x| x[1] == "CTJ_FILIAL"})) > 0
		cChave := aAuto[nPos, 2]
		If (nPos := aScan(aAuto, {|x| x[1] == "CTJ_RATEIO"})) > 0
			cChave += aAuto[nPos, 2]						
			CTJ->(dbSetOrder(1))//CTJ_FILIAL+CTJ_RATEIO
			If CTJ->(DbSeek(cChave))
				oModelCNZ:GoLine(1)
				oModelCNZ:LoadValue("CNZ_ITEM", StrZero(1, Len(CNZ->CNZ_ITEM)))
				Eval(bRateio, oModelCNZ, @cItem, .T.)
				While CTJ->(!Eof() .And. CTJ_FILIAL+CTJ_RATEIO == cChave)
					Eval(bRateio, oModelCNZ, @cItem, .F.)
					CTJ->(dbSkip())
				EndDo
			EndIf			
		EndIf
	EndIf	
EndIf

FWRestRows(aSaveLines)
RestArea(aAreaCNB)
RestArea(aArea)

Return

//=============================================================================
/*/{Protheus.doc} CN300PrtExp(oModel)
Função para chamada de impressão / exportação de relatório.
@author israel.escorizza
@since 24/01/2017
@return
/*/
//=============================================================================
Function CN300PrtExp()
CNTR010(CN9->(Recno()))
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CN300Adiant
Função que reinicia a variável Static lAdiant como (.F.) falso
@param  Nenhum 
@return Nenhum
@author Eduardo Gomes Júnior
@since 22/02/2018
/*/
//-------------------------------------------------------------------
Function CN300Adiant()

lAdiant := .F.

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VLAT
Valida existencia do ponto de entrada C100VLAT e testa seu retorno
@param oModel, Objeto,  Model da rotina
@return lRet, Lógico , Verdadeiro/Falso
@author Eduardo Gomes Júnior
@since 09/03/2018
/*/
//-------------------------------------------------------------------
Function CN300VLAT(oModel)

Local lRet 		:= .F.
Local lC100VlAt := _lC100VLAT//Utiliza variavel estatica
Local lUserOk	:= .F.
	
If	lC100VlAt .AND. ALTERA .AND. CN9->CN9_SITUAC == DEF_SVIGE
	
	lUserOk := ExecBlock("C100VLAT",.F.,.F.,{CN9->CN9_SITUAC ,oModel})
	If	ValType(lUserOk) == "L" .AND. lUserOk 
		lRet := .T.
	Endif 	

Endif 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300BlCps
Caso o ponto de entrada C100VLAT exista, bloqueia os campos informados no array ACAMPOS e bloqueia todos os GRIDS (DETAIL) 
para não permitir alterações. 
@param oModel, Objeto,  Model da rotina
@return Nenhum
@author Eduardo Gomes Júnior
@since 09/03/2018
/*/
//-------------------------------------------------------------------
Function CN300BlCps(oModel)

Local aRet		:= {}
Local nX		:= 0
Local aCampos	:= {}

MtBCMod(oModel,{'CN9MASTER'},{||.T.}) // Libera todos os campos do modelo da CN9 para serem usados por meio do ponto de Entrada C100VLAT
aAdd(aCampos,{'CN9MASTER',{'CN9_NUMERO','CN9_DTINIC','CN9_UNVIGE','CN9_VIGE','CN9_MOEDA','CN9_CONDPG','CN9_TPCTO','CN9_FLGREJ','CN9_FLGCAU','CN9_GRPAPR','CN9_APROV'}}) //Bloqueia os campos que não podem ser alterados
MtBCMod(oModel,aCampos,{||.F.},'2')

For nX := 1 to Len(oModel:GetAllSubModels())
	aAdd(aRet,oModel:GetAllSubModels()[nX]:CID)
Next nX

For nX := 1 to Len(aRet)
	If	"DETAIL" $ aRet[nX]
		CNTA300BlMd(oModel:GetModel(aRet[nX]),,.F.)
	EndIf
Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ExistSCR2()
Função que verifica se existe SCR pendente de aprovação para o documento


@param 	cTipo	, Tipo do documento
		cNum	, Chave do documento
		
@return Lógico	, .T. - Existe alçada para aprovacao
				  .F. - Nao existem alcada para aprovacao
				  
@author jose.delmondes
@since 20/03/2018
/*/
//-------------------------------------------------------------------

Function ExistSCR2(cTipo,cNum, cFilCtr)
Local aArea		:= GetArea()
Local cAliasSCR	:= GetNextAlias()
Local lRet 		:= .F.
Local cFilSCR	:= ""
Default cFilCtr := cFilAnt

cFilSCR := xFilial("SCR", cFilCtr)

BeginSQL Alias cAliasSCR

	SELECT	SCR.CR_NUM
	FROM 	%Table:SCR% SCR
	WHERE	SCR.%NotDel% AND
			SCR.CR_FILIAL = %Exp:cFilSCR% AND
			SCR.CR_TIPO = %Exp:cTipo% AND
			SCR.CR_NUM = %Exp:cNum% AND
			SCR.CR_STATUS = '02'
	
EndSQL

lRet := (cAliasSCR)->(!EOF())

(cAliasSCR)->(dbCloseArea())

RestArea(aArea)

Return lRet	  

/*/{Protheus.doc} A300GTMenu()
	Função para recuperar a opção do menu que tem interação com a view
e com o model do CNTA300. Criada para auxiliar na manipulação de pontos de entrada MVC.
Return cExp -> 
	Possíveis retornos:
		DEF_APROV(AP)..............= Durante aprovação da revisão
		DEF_ADIANT(AD).............= Durante a inclusão do adiantamento
		Tipo de Revisão(DEF_REV_*).= Durante a inclusão da revisão
@author Thamara
@since 30/01/2018
/*/
Function A300GTMenu()
	Local cOpc := ""
	
	If !Empty(A300GATpRv())
		cOpc := DEF_APROV //Aprovação de Revisão
	ElseIf CNGetAdiant()
		cOpc := DEF_ADIANT //Adiantamento
	ElseIf !Empty(A300GTpRev())
		cOpc := A300GTpRev() //Tipo de Revisão
	EndIf
Return cOpc

//=============================================================================
/*/{Protheus.doc} Cn300AjuMt(oModel)
Função responsável por ajustar a divergência na gravação do contrato.

@author israel.escorizza
@since 24/04/2018
@return
/*/
//=============================================================================
Function Cn300AjuMt(oModel,nDifer)
Local lRet		:= .F.
Local oModelCNA := oModel:GetModel('CNADETAIL')
Local oModelCNF := oModel:GetModel('CNFDETAIL')
Local nCount	:= 0
Local aProp as Array

Default nDifer 	:= 0

//- Existe uma divergência de #VALOR  entre o montante do cronograma e da planilha #PLANILHA. Deseja atribuir esta diferença a última parcela válida do cronograma?
If IsBlind() .Or. MsgYesNo(STR0271+ cValToChar(nDifer) +STR0272+ oModelCNA:GetValue('CNA_NUMERO')+ CRLF+CRLF +STR0273)
	nCount := oModelCNF:Length()
	aProp := GetPropMdl(oModelCNF)
	
	CNTA300BlMd(oModelCNF,.F.)

	oModelCNF:GetStruct():SetProperty('CNF_VLPREV',MODEL_FIELD_WHEN,{||.T.})
	oModelCNF:GetStruct():SetProperty('CNF_SALDO' ,MODEL_FIELD_WHEN,{||.T.})
	While !lRet .And. nCount > 0
		oModelCNF:GoLine(nCount)
		If !oModelCNF:IsDeleted() .And. oModelCNF:GetValue('CNF_SALDO') > 0 .And. oModelCNF:GetValue('CNF_SALDO') - nDifer > 0
			oModelCNF:SetValue('CNF_SALDO' ,oModelCNF:GetValue('CNF_SALDO')  - nDifer)
			oModelCNF:SetValue('CNF_VLPREV',oModelCNF:GetValue('CNF_VLPREV') - nDifer)
			lRet := .T.
		EndIf
		nCount --
	EndDo
	oModelCNF:GetStruct():SetProperty('CNF_VLPREV',MODEL_FIELD_WHEN,{||.F.})
	oModelCNF:GetStruct():SetProperty('CNF_SALDO' ,MVC_VIEW_CANCHANGE, .F.)

	RstPropMdl(oModelCNF,aProp)
	
	If nCount == 0
		Help(" ",1,"CN300AJMON") //- Não foi possível atribuir diferença ao cronograma. Verifique as parcelas do cronograma e tente novamente.
		lRet := .F.
	EndIf
EndIf
Return lRet

//=============================================================================
/*/{Protheus.doc}  CN300RAdit
Função revisão aditivo

@author Alessandro Honda
@since 29/05/18
@return
/*/
//=============================================================================

Function CN300RAdit

Cn300Rev(,,,DEF_REV_ADITI)

Return

//=============================================================================
/*/{Protheus.doc}  CN300RReaj
Função revisão reajuste

@author Alessandro Honda
@since 29/05/18
@return
/*/
//=============================================================================

Function CN300RReaj

Cn300Rev(,,,DEF_REV_REAJU)

Return

//=============================================================================
/*/{Protheus.doc}  CN300RReal
Função revisão realinhamento

@author Alessandro Honda
@since 29/05/18
@return
/*/
//=============================================================================

Function CN300RReal

Cn300Rev(,,,DEF_REV_REALI)

Return

//=============================================================================
/*/{Protheus.doc}  CN300RRead
Função revisão readequação

@author Alessandro Honda
@since 29/05/18
@return
/*/
//=============================================================================

Function CN300RRead

Cn300Rev(,,,DEF_REV_READE)

Return

//=============================================================================
/*/{Protheus.doc}  CN300RPara
Função revisão paralização

@author Alessandro Honda
@since 29/05/18
@return
/*/
//=============================================================================

Function CN300RPara

Cn300Rev(,,,DEF_REV_PARAL)

Return

//=============================================================================
/*/{Protheus.doc}  CN300RRein
Função revisão reinicio

@author Alessandro Honda
@since 29/05/18
@return
/*/
//=============================================================================

Function CN300RRein

Cn300Rev(,,,DEF_REV_REINI)

Return

//=============================================================================
/*/{Protheus.doc}  CN300RClau
Função revisão cláusula

@author Alessandro Honda
@since 29/05/18
@return
/*/
//=============================================================================

Function CN300RClau

Cn300Rev(,,,DEF_REV_CLAUS)

Return

//=============================================================================
/*/{Protheus.doc}  CN300RCont
Função revisão contábil

@author Alessandro Honda
@since 29/05/18
@return
/*/
//=============================================================================

Function CN300RCont

Cn300Rev(,,,DEF_REV_CONTA)

Return

//=============================================================================
/*/{Protheus.doc}  CN300RIndi
Função revisão índice

@author Alessandro Honda
@since 29/05/18
@return
/*/
//=============================================================================

Function CN300RIndi

Cn300Rev(,,,DEF_REV_INDIC)

Return

//=============================================================================
/*/{Protheus.doc}  CN300RForn
Função revisão fornecedor

@author Alessandro Honda
@since 29/05/18
@return
/*/
//=============================================================================

Function CN300RForn

Cn300Rev(,,,DEF_REV_FORCL)

Return

//=============================================================================
/*/{Protheus.doc}  CN300RGApr
Função revisão grupo aprovador

@author Alessandro Honda
@since 29/05/18
@return
/*/
//=============================================================================

Function CN300RGApr

Cn300Rev(,,,DEF_REV_GRAPR)

Return

//=============================================================================
/*/{Protheus.doc}  CN300RReno
Função revisão renovação

@author Alessandro Honda
@since 29/05/18
@return
/*/
//=============================================================================

Function CN300RReno

Cn300Rev(,,,DEF_REV_RENOV)

Return

//=============================================================================
/*/{Protheus.doc}  CN300RMult
Função revisão multa / bonificação

@author Alessandro Honda
@since 29/05/18
@return
/*/
//=============================================================================

Function CN300RMult

Cn300Rev(,,,DEF_REV_MULBON)

Return

//=============================================================================
/*/{Protheus.doc}  CN300RCauc
Função revisão caução

@author Alessandro Honda
@since 29/05/18
@return
/*/
//=============================================================================

Function CN300RCauc

Cn300Rev(,,,DEF_REV_CAUCA)

Return

//=============================================================================
/*/{Protheus.doc}  CN300RAber
Função revisão Aberta

@author Janaina de Jesus
@since 19/11/2018
@return
/*/
//=============================================================================
Function CN300RAber
Cn300Rev(,,,DEF_REV_ABERT)
Return

//=============================================================================
/*/{Protheus.doc}  CXNLOADINF(oModel,oStruCND)
Função responsável por Carregar a grid da mediçao no contrato

@author Ronaldo.Robes
@since 08/06/2018
@return
/*/
//=============================================================================
Static Function CXNLOADINF(oSubCND as Object, lCopia as Logical)
	Local oModelCNA  := Nil
	Local nU         := 0 
	Local nX		 := 0
	Local aLoad      := {}
	Local aItem      := {}
	Local lCnRevMd   := SuperGetMV("MV_CNREVMD",.F.,.T.)
	Local cRev       := ""
	Local cQuery     := ""
	Local cAliasQry  := GetNextAlias()
	Local cFieldName := ""
	Local oModel	 := oSubCND:GetModel()
	Local oStruCND	 := oSubCND:GetStruct()
	Local cNumPla	 := ""
	oModelCNA 	:= oModel:GetModel("CNADETAIL")
	cNumPla		:= oModelCNA:GetValue('CNA_NUMERO')

	If lCnRevMd
		cRev := " CND_REVISA = " + IIf(!empty(oModelCNA:GetValue('CNA_REVISA')), oModelCNA:GetValue('CNA_REVISA'), "''") + " AND"	
	EndIF

	cQuery := " SELECT CND.*, CXN_NUMPLA, CXN_CHECK"
	cQuery += " FROM " + RetSQLName("CND") + " CND"
	cQuery += " LEFT JOIN " + RetSQLName("CXN") + " CXN"
	cQuery += " ON ("
	cQuery += " CND_FILIAL = CXN_FILIAL AND"
	cQuery += " CND_CONTRA = CXN_CONTRA AND"
	cQuery += " CND_REVISA = CXN_REVISA AND"
	cQuery += " CND_NUMMED = CXN_NUMMED AND"
	cQuery += " CXN.D_E_L_E_T_ = ' ')"
	cQuery += " WHERE"
	cQuery += " CND_FILCTR = '" 	+ oModel:GetValue('CN9MASTER', 'CN9_FILCTR')+ "' AND"
	cQuery += " CND_CONTRA = '" 	+ oModelCNA:GetValue('CNA_CONTRA') 			+ "' AND"
	cQuery += " ISNULL(CXN_NUMPLA, CND_NUMERO) = '"+ cNumPla +"' AND"
	cQuery += " ISNULL(CXN_CHECK, 'T') = 'T' AND"
	If !Empty(cRev)
		cQuery += cRev
	EndIf
	cQuery += " CND.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

	For nX := 1 To Len(oStruCND:AFields)
		If oStruCND:AFields[nX,4] <> "C"
			TcSetField(cAliasQry, oStruCND:AFields[nX,3], oStruCND:AFields[nX,4], oStruCND:AFields[nX,5], oStruCND:AFields[nX,6])
		EndIf
	Next nX

	While !(cAliasQry)->(Eof())
		aItem:={}
		
		For nU:= 1 to len(oStruCND:AFields)
			If oStruCND:AFields[nU][4] <> 'M'
				cFieldName := oStruCND:AFields[nU][3]
				If !oStruCND:AFields[nU][14]
					If (cFieldName == "CND_NUMERO")
						If Empty((cAliasQry)->&(cFieldName))
							aAdd(aItem,(cAliasQry)->CXN_NUMPLA)
						else
							aAdd(aItem,(cAliasQry)->&(cFieldName))
						EndIf					
					Else
						aAdd(aItem,(cAliasQry)->&(cFieldName))
					EndIf
				ElseIF(cFieldName == "CND_FILDES")						
					aAdd(aItem, AllTrim(Left(FWFilialName(, (cAliasQry)->CND_FILMED,1),40)))
				Else
					aAdd(aItem,"")
				EndIF
			Else
				aAdd(aItem,"")
			EndIf
		Next nU

		aAdd(aLoad,{0,aItem})
		
		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())
Return aLoad

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VcCbl
Valida competência informada no cronograma contábil  
@param Nenhum
@return lRet, Lógico , Verdadeiro/Falso
@author Eduardo Gomes Júnior
@since 20/06/2018
/*/
//-------------------------------------------------------------------
Function CN300VcCbl()

Local oModel		:= FWModelActive()
Local oModelCNW		:= oModel:GetModel("CNWDETAIL")
Local lRet			:= .T.
Local lVldVige		:= (SuperGetMV("MV_CNFVIGE", .F., "N") == "N")
Local nTot			:= oModelCNW:Length()
Local nAtual		:= oModelCNW:nLine
Local cCampo		:= Readvar()
Local dData			:= &(Readvar())
Local dInicio		:= FwFldGet("CN9_DTINIC")
Local dFim			:= FwFldGet("CN9_DTFIM")
Local aSaveLines	:= FWSaveRows()

//Se a validação for por competência, aponta para o 1º dia do mes para fazer as comparações
If cCampo == "M->CNW_COMPET" 
	dData    :=	CtoD("01/"+dData)
	dInicio  := CtoD("01/"+StrZero(Month(dInicio),2)+"/"+StrZero(Year(dInicio),4))
	dFim	 := CtoD("01/"+StrZero(Month(dFim),2)+"/"+StrZero(Year(dFim),4))
EndIf

//Verifica se a previsao ultrapassa a proxima parcela se houver
If (nAtual < nTot )

	//Verifica a proxima parcela
	oModelCNW:GoLine(nAtual+1)

	If 	( oModelCNW:GetValue("CNW_DTPREV") <= dData )
	  	lRet := .F.
	ElseIf ( cCampo == "M->CNW_COMPET" .AND. CtoD("01/" + oModelCNW:GetValue("CNW_COMPET") ) < dData)
	  	lRet := .F.
	ElseIf lVldVige .AND. ( (dData < dInicio) .Or. (dData > dFim) )
	  	lRet := .F.
  	EndIf

 	oModelCNW:GoLine(nAtual)
 	
 EndIf

FWRestRows(aSaveLines)

Return lRet

//==============================================================================================================================
/*/{Protheus.doc} Cn9VlConPg() - Função responsável pela validação da condição de pagamento inclusa no contrato
@Param	oModel	- Modelo CO3DETAIL
		
@author Israel.Escorizza 
@since 	22/06/2018 
@return lRet
/*/
//==============================================================================================================================
Function Cn9VlCdPgt(oModel,cValor)
Local lRet			:= .T.
Local aArea			:= GetArea()
Local aSaveLines	:= FWSaveRows()

Local cTipo			:= POSICIONE('SE4',1, xFilial('SE4')+cValor,'E4_TIPO')  //Indice 1 - E4_FILIAL+E4_CODIGO

If AllTrim(cTipo) == '9' //Validação do tipo de condição de pgto
	If Empty(oModel:GetValue('CN9_TPCTO')) .Or. Cn300RetSt('COMPRA')
		lRet := .F.
		Help("",1,"CNCONDPGTO",,STR0282,1,1) //--'A condição de pagamento selecionada somente pode ser utilizada em contratos de venda.'
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet

//===============================================================================================
/*/{Protheus.doc} CnWhenTpCt() - Função responsável pelo when da condição de pagamento CN9_CONDPG
		
@author jose.delmondes
@since 	19/07/2018
@return lRet
/*/
//===============================================================================================
Function CnWhenCPg()
Local lRet	:= .T.

If !FWIsInCallStack('CNTA300xEdt') .And. Empty(FwFldGet("CN9_TPCTO"))  
	lRet := .F.
EndIf 

Return lRet

/*/{Protheus.doc} CN300Track
Função para tratamento do tracker nas rotinas CNTA300 e CNTA301 

@author pedro.alencar
@since 10/08/2018
/*/
Function CN300Track()
	Local aEnt := {}
	Local cCtrNum := M->CN9_NUMERO
	Local cCtrRev := M->CN9_REVISA
	Local cRevAdd := "001"
	
	AAdd( aEnt, { "CN9", cCtrNum } )
	While cRevAdd <= cCtrRev
		AAdd( aEnt, { "CN9", cCtrNum + cRevAdd } )
		cRevAdd := Soma1( cRevAdd )
	EndDo
	
	MaTrkShow( aEnt )

Return ( .T. )

/*/{Protheus.doc} AtuFlagGCT
Atualiza flag de controle do GCT na SC1, com base na tabela de relacionamento Edital x SCs 

@param cNumEdital, Número do edital 
@param cProEdital, Número do processo do edital

@author pedro.alencar
@since 22/08/2018
/*/
Static Function AtuFlagGCT( cNumEdital, cProEdital )
	Local aAreaCP4 := CP4->( GetArea() )
	Local aAreaSC1 := SC1->( GetArea() )
	Local cNumSC := ""
	Local cItemSC := ""
	Default cNumEdital := ""
	Default cProEdital := ""
	
	CP4->( dbSetOrder( 1 ) ) //CP4_FILIAL+CP4_CODEDT+CP4_NUMPRO+CP4_REVISA+CP4_CODPRO+CP4_NUMSC+CP4_ITEMSC+CP4_LOTE
	If CP4->( msSeek( FWxFilial("CP4") + cNumEdital + cProEdital ) )		
		
		SC1->( dbSetOrder( 1 ) ) //C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD
		While CP4->( !EOF() .And. CP4_CODEDT == cNumEdital .And. CP4_NUMPRO == cProEdital )
			cNumSC := CP4->CP4_NUMSC
			cItemSC := CP4->CP4_ITEMSC
					
			If SC1->( msSeek( FWxFilial("SC1") + cNumSC + cItemSC ) )
				RecLock( "SC1", .F. )
				SC1->C1_FLAGGCT := "1"
				SC1->( msUnlock() )
			EndIf
			
			CP4->( dbSkip() )
		EndDo
	
		RestArea( aAreaSC1 )
	EndIf
		
	RestArea( aAreaCP4 )
Return Nil

/*/{Protheus.doc} CNA300VldPl
Verifica se o Tipo de Planilha informado em contratos vindo do edital ou do processo de cotação é do tipo Fixo.

@param oModel, oModel
@return lRet, Planilha fixa

@author janaina.jesus
@since 12/09/2018
/*/
Function CNA300VldPl(oModel)
	Local aArea		:= GetArea()
	Local lRet		:= .T.
	Local oModelCN9	:= NIL
	Local oModelCNA	:= NIL
	Local cCodPla	:= ""	

	//-- Caso chamada pelo valid do campo, inicializa variaveis
	If Empty(oModel)
		oModel := FWModelActive()
	EndIf
		
	oModelCN9	:= oModel:GetModel("CN9MASTER")
	oModelCNA	:= oModel:GetModel("CNADETAIL")
	
	cCodPla:= oModelCNA:GetValue("CNA_TIPPLA")
	If (!Empty(oModelCN9:GetValue("CN9_NUMCOT")) .Or. !Empty(oModelCN9:GetValue("CN9_CODED")))
		lRet := CNVldPlFixa(cCodPla) //Quando NUMCOT ou CODED esta preenchido, precisa ser tipo fixa.
	EndIf

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} CNVldPlFixa
	Valida se a planilha eh fixa, se nao for exibe Help
@author philipe.pompeu
@since 23/08/2019
@return lResult, logico, verdadeiro caso seja do tipo fixa
@param cCodPla, caractere, codigo a ser buscado na CNL
/*/
Function CNVldPlFixa(cCodPla)
	Local aAreaCNL	:= CNL->(GetArea())
	Local lResult	:= .F.
	Local lVldTpFixo:= SuperGetMV("MV_VLDTPFI",.T.,.T.)

	CNL->(DbSetOrder(1))//CNL_FILIAL+CNL_CODIGO
	If !(lResult := !lVldTpFixo)
		lResult  := CNL->(MsSeek(xFilial("CNL") + cCodPla) .And. CNL_CTRFIX $ "0|1")
	EndIf
	
	If(!lResult)
		Help( ,, STR0090,, STR0297, 1, 0,,,,,, {STR0284} )//"Para contratos gerados por edital/compras o tipo de planilha deve ser obrigatoriamente do tipo fixo ou conforme o contrato."		
	EndIf
	RestArea(aAreaCNL)
Return lResult

/*/{Protheus.doc} LibCpoAlt
Função para bloquear todos os campos na alteração e liberar apenas alguns campos específicos 

@param oModel, Modelo de dados do CNTA300 
@Return Nil

@author pedro.alencar
@since 13/09/2018
/*/
Static Function LibCpoAlt( oModel )
	Local aModels := MTGetAllMd()
	Local aCampos := {}
	Local aVetMod := {}
	Local cCampos := ""
	Local cSituac := oModel:GetValue( "CN9MASTER", "CN9_SITUAC" )
	Local nPosCNN := 0
	Default oModel := Nil
	
	If oModel <> Nil
		If ((nPosCNN := aScan(aModels, "CNNDETAIL")) > 0) 
			aDel(aModels,nPosCNN) //Remove o "CNNDETAIL" para nao bloquear a edicao do modelo. Edicao utilizada em caso de alteracao do Gestor
			aSize(aModels,Len(aModels) - 1)
		EndIf
		//Bloqueia o when de todos os campos
		MtBCMod( oModel, aModels, {||.F.} )
		
		
		//bloqueia a edição das grids
		CNTA300BlMd( oModel:GetModel("CNCDETAIL"), .T. )
		CNTA300BlMd( oModel:GetModel("CNADETAIL"),, .T. )
		CNTA300BlMd( oModel:GetModel("CNBDETAIL"),, .T. )
		CNTA300BlMd( oModel:GetModel("CXIDETAIL"), .T. )
		CNTA300BlMd( oModel:GetModel("CNFDETAIL"), .T. )
		CNTA300BlMd( oModel:GetModel("CNHDETAIL"), .T. )
		CNTA300BlMd( oModel:GetModel("CNUDETAIL"), .T. )
		CNTA300BlMd( oModel:GetModel("CPDDETAIL"), .T. )
		CNTA300BlMd( oModel:GetModel("CNZDETAIL"), .T. )
		CNTA300BlMd( oModel:GetModel("CNSDETAIL"), .T. )
		CNTA300BlMd( oModel:GetModel("CNVDETAIL"), .T. )
		CNTA300BlMd( oModel:GetModel("CNWDETAIL"), .T. )
		CNTA300BlMd( oModel:GetModel("CXLDETAIL"), .T. )				
		CNTA300BlMd( oModel:GetModel("CXODETAIL"), .T. )
		CNTA300BlMd( oModel:GetModel("CXPDETAIL"), .T. )	
		
		//Libera o when apenas dos campos informados
		cCampos := IIF( cSituac = DEF_SELAB,  "{ 'CN9_OBJCTO'", "{" )
		If CN9->( ColumnPos( "CN9_GESTC" ) ) > 0
			cCampos += IIF( cSituac = DEF_SELAB, ", 'CN9_DEPART', 'CN9_GESTC' ", " 'CN9_DEPART', 'CN9_GESTC' ")
		EndIf
		cCampos += " }"
		aCampos := &( cCampos )
		aAdd( aVetMod, { "CN9MASTER", aClone( aCampos ) } )
						
		If CNB->( ColumnPos( "CNB_ARREND" ) ) > 0
			aSize( aCampos, 0 )
			cCampos := "{ 'CNB_ARREND' }"
			aCampos := &( cCampos )
			aAdd( aVetMod, { "CNBDETAIL", aClone( aCampos ) } )
		EndIf
		
		MtBCMod( oModel, aVetMod, {||.T.}, "2" )
		
		aSize( aModels, 0 )
		aModels := Nil
		aSize( aCampos, 0 )
		aCampos := Nil
		aSize( aVetMod, 0 )
		aVetMod := Nil
	EndIf
		
Return Nil

/*/{Protheus.doc} GrvPermCNN
Função para incluir a permissão de controle sobre um contrato para o usuários e/ou gestor 

@param oModelCNN, Grid da CNN na qual serão adicionadas as permissões 
@param cCodUser, Código do usuário que está incluindo o contrato (apenas inclusão)
@param cCodGest, Código do gestor do contrato
@param cOperac, Operação do contrato que está chamando a gravação das permissões (sendo "3"=Inclusão e "4"=Alteração)  
@param cTrans, Tipo de transação à qual será concebida a permissão: 
		  	   "001" (DEF_TRANS) = Transacao de controle total do contrato
			   "007" (DEF_TRAINC) = Inclusao de Planilhas
			   "009" (DEF_TRAEXC) = Exclusao de Planilhas
			   "018" (DEF_TRASIT) = Transacao de controle de situacoes
			   "027" (DEF_TRAINC) = Inclusao de Revisoes
			   "029" (DEF_TRAEXC) = Exclusao de Revisoes
			   "030" (DEF_TRAAPR) = Aprovação de revisoes
			   "037" (DEF_TRAVIS) = Transacao de visualizacao do contrato
			   "038" (DEF_TRABCO) = Transacao de controle sobre o banco de conhecimento
			   "039" (DEF_TRAEDT) = Transacao de controle sobre a edicao do contrato
			   "040" (DEF_TRARET) = Transacao de controle sobre a baixa da retencao
			   "042" (DEF_TRAAVA) = Transacao de Avaliações .
			   "046" (DEF_TRAAVV) = Transacao de Avaliações de Visualização. 
@Return Nil

@author pedro.alencar
@since 14/09/2018
/*/
Static Function GrvPermCNN( oModelCNN, cCodUser, cCodGest, cOperac, cTrans )
	Local nLenAux := 0
	Local cMsgExcGes := ""
	Local lExcGes := .T.
	Default oModelCNN := Nil
	Default cCodUser := ""
	Default cCodGest := ""
	Default cOperac := ""
	Default cTrans := DEF_TRANS
	
	If oModelCNN <> Nil .And. ( !Empty(cCodUser) .Or. !Empty(cCodGest) .Or. !Empty(__cGestOld) ) .And. !Empty(cOperac)
		
		If cOperac == "3" //Se for na inclusão do contrato
		
			//Inclui a permissão do usuário
			oModelCNN:SetValue( "CNN_USRCOD", cCodUser )
			oModelCNN:SetValue( "CNN_TRACOD", cTrans )
			
			//verifica se o código do gestor foi informado e inclui a permissão para o mesmo, caso não seja o mesmo usuário da inclusão
			If !Empty( cCodGest ) .And. cCodGest <> cCodUser
				nLenAux := oModelCNN:Length()
				If oModelCNN:AddLine() == nLenAux + 1
					oModelCNN:SetValue( "CNN_USRCOD", cCodGest )
					oModelCNN:SetValue( "CNN_TRACOD", cTrans )
				EndIf
			EndIf
		
		ElseIf cOperac == "4" //Se for na alteração do contrato
			
			//Verifica se o gestor, informado na alteração, é diferente do gestor que já estava definido no contrato
			If cCodGest <> __cGestOld
				//Exclui a linha de permissão para o antigo gestor				
				If !Empty( __cGestOld ) 
					
					If !Empty( cCodGest )
						cMsgExcGes := STR0285 + " (" + cCodGest + " - " + UsrFullName(cCodGest) + ")." //"O gestor do contrato foi alterado. Serão concedidas as permissões de acesso para o novo gestor" 
						cMsgExcGes += CRLF + CRLF + STR0286 + " (" + __cGestOld + " - " + UsrFullName(__cGestOld) + ")?" //"Deseja remover as permissões de acesso do gestor anterior"
					Else
						//Se não foi informado um novo gestor e só tem um usuário com acesso, então significa que o gestor era também o usuário de inclusão do contrato, então não apaga o acesso do mesmo
						If oModelCNN:Length() == 1
							lExcGes := .F.
						Else
							cMsgExcGes := STR0287 + " (" + __cGestOld + " - " + UsrFullName(__cGestOld) + ") " + STR0288 //"O gestor do contrato", "foi removido."
							cMsgExcGes += CRLF + CRLF + STR0289 //"Deseja remover também suas permissões de acesso para esse contrato?"
						EndIf
					EndIf
					
					If lExcGes .And. MsgYesNo( cMsgExcGes, STR0290 ) //"Atualização de permissão de acesso"					      
						ExcPermCNN( oModelCNN, __cGestOld )
					EndIf
				EndIf
				
				//Inclui a permissão para o novo gestor, caso haja um código informado e caso o mesmo já não tenha permissão (pode ter sido o usuário que incluiu o contrato)
				If !Empty( cCodGest ) .And. !oModelCNN:SeekLine( { {"CNN_USRCOD", cCodGest } } )
					nLenAux := oModelCNN:Length()
					
					oModelCNN:SetNoInsertLine(.F.) 
					oModelCNN:SetNoUpdateLine(.F.) 
				
					If oModelCNN:AddLine() == nLenAux + 1
						oModelCNN:SetValue( "CNN_USRCOD", cCodGest )
						oModelCNN:SetValue( "CNN_TRACOD", cTrans )
					EndIf
				EndIf
			EndIf
			
		EndIf
		
	EndIf
Return Nil

/*/{Protheus.doc} ExcPermCNN
Função para excluir a permissão de controle sobre um contrato para um gestor

@param oModelCNN, Grid da CNN na qual será excluída a permissão do gestor 
@param cCodGest, Código do gestor do contrato
@Return lRet, Indica se excluiu a permissão com sucesso

@author pedro.alencar
@since 14/09/2018
/*/
Static Function ExcPermCNN( oModelCNN, cCodGest )
	Local lRet := .T.
	Default oModelCNN := Nil
	Default cCodGest := ""
	
	If oModelCNN <> Nil .And. !Empty( cCodGest )
		If oModelCNN:SeekLine( { { "CNN_USRCOD", cCodGest } } )
			oModelCNN:SetNoDeleteLine(.F.)
			lRet := oModelCNN:DeleteLine()
		EndIf
	EndIf
Return lRet


/*/{Protheus.doc} CN300FltSC
Função para filtrar itens de SC já importadas para itens do contrato

@Return lRet, Indica se filtra ou não o registro atual

@author leonardo.magalhaes
@since 25/04/2019
/*/
Function CN300FltSC()
	
	Local lRet 		:= .T.
	Local oModel	:= FWModelActive()
	Local oModelCNA := oModel:GetModel("CNADETAIL")
	Local oModelCNB := oModel:GetModel("CNBDETAIL")
	Local aBusca 	:= {{"CNB_NUMSC", SC1->C1_NUM}, {"CNB_ITEMSC", SC1->C1_ITEM}}
	Local nX 		:= 0
	
	For nX := 1 To oModelCNA:Length()
		oModelCNA:GoLine(nX)
		If oModelCNB:SeekLine(aBusca)
			lRet := .F.
			Exit
		EndIf
	Next nX
	
Return lRet

/*/{Protheus.doc} TrataNulo
//Função para tratar o tipo de retorno esperado para cada propriedade. Utilizada quando o retorno da função CN300RetSt for nulo.
@author juan.felipe
@since 04/06/2019
@return xRet, Retorno default tratado de acordo com o tipo de retorno esperado para cada propriedade. 
@param cProp, characters, Propriedade do contrato.
@type function
/*/
Static Function TrataNulo( cProp )
	Local xRet := Nil
	Local cRetChar := "ESPECIE|TPMULT|MULMAN|"
	Local cRetBool := "FISICO|FIXO|EVENTUAL|MEDEVE|PREVFINANC|CONTABIL|SEMIFIXO|SEMIPROD|SEMIAGRUP|RECORRENTE|SERVIÇO|COMPRA|VENDA|REVREAJU|REVREALI|LMTFISICO|LMTFINANCEIRO|MEDAUTO|ALCMDDOC|ALCMDEC|ALCCTDOC|ALCCTEC|INTPIMS|MULTIMED"
	Local cRetNum := "LMTMED|LMTMEDCONTRA|"
	Default cProp := ""

	If cProp $ cRetChar 
		xRet := ""
	ElseIf cProp $ cRetBool
		xRet := .F.
	ElseIf cProp $ cRetNum
		xRet := 0
	EndIf
Return xRet

/*/{Protheus.doc}VldCFCNC
Validação de cliente e fornecedor - CNA x CNC
@author Vitor Pires
@since 01/10/2019
@version P12.1.17
/*/
Static Function VldCFCNC(oModel)
	Local lRet		:= .T.
	Local oModelCNA	:= Nil
	Local cForn		:= ''
	Local cLoja 	:= ''
	Local cEspCtr	:= ""
	Default oModel	:= FWModelActive()
	
	oModelCNA	:= oModel:GetModel("CNADETAIL")
	cEspCtr		:= oModel:GetValue("CN9MASTER", "CN9_ESPCTR")

	cForn := If(cEspCtr=='1', oModelCNA:GetValue("CNA_FORNEC"), oModelCNA:GetValue("CNA_CLIENT"))
	cLoja := If(cEspCtr=='1', oModelCNA:GetValue("CNA_LJFORN"), oModelCNA:GetValue("CNA_LOJACL"))

	If cEspCtr == '1'
		lRet := MTFindMVC(oModel:GetModel("CNCDETAIL"),{{"CNC_CODIGO",cForn},{"CNC_LOJA",cLoja}}) > 0
	Else
		lRet := MTFindMVC(oModel:GetModel("CNCDETAIL"),{{"CNC_CLIENT",cForn},{"CNC_LOJACL",cLoja}}) > 0
	EndIf
	
	If !lRet
		Help('',1,"VLDCFCNC",, STR0298, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0299})//"Fornecedor/cliente da planilha não foi informado no contrato."
	EndIf	

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CN300CNBPre

@description Função bPre da grid CNB
@author	Augusto Albuquerque
@since	31/10/2019
/*/
//------------------------------------------------------------------------------
Function CN300CNBPre(nLine,cAction,cCampo,xValue,xOldValue,oModelGrid)
Local oModel 	:= oModelGrid:GetModel()
Local lRet		:= .T.

If cAction == "UNDELETE"
	If nModulo == 28
		If FindFunction("TecPreCNB") .AND. FWIsInCallStack("At870EftRv")
			lRet := TecPreCNB( cAction, oModel, oModelGrid)
		EndIf
	EndIf
ElseIf cAction == "DELETE"
	If nModulo == 28
		If FindFunction("TecPreCNB") .AND. FWIsInCallStack("At870EftRv")
			lRet := TecPreCNB( cAction, oModel, oModelGrid)
		EndIf
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} LimpaSCInt
	Limpa o campo C1_FLAGGCT das solicitacoes que podem ter sido importadas durante o processo de revisao.
@author philipe.pompeu
@since 24/01/2020
@return nil, valor nulo
@param cContra, caractere, numero do contrato
@param cRevAtu, caractere, revisao
/*/
Static Function LimpaSCInt(cContra, cRevAtu)
	Local aAreas	:= {SC1->(GetArea()), GetArea()}	
	Local cMyAlias	:= GetNextAlias()
	Local cRevAnt	:= CnRevAnt( .F. , cRevAtu )
	
	/*A consulta traz apenas os itens que tenham sido incluidos na revisao corrente e que tenham vínculo com SC.*/
	BeginSql Alias cMyAlias
		SELECT SC1.R_E_C_N_O_ AS IDSC 
		FROM %table:CNB% CNB
		LEFT JOIN %table:CNB% CNB2 ON
		(
			CNB2.CNB_FILIAL = %xFilial:CNB%
			AND CNB2.%notdel%
			AND CNB2.CNB_CONTRA = CNB.CNB_CONTRA  
			AND CNB2.CNB_ITEM 	= CNB.CNB_ITEM
			AND CNB2.CNB_NUMERO = CNB.CNB_NUMERO
			AND CNB2.CNB_REVISA = %exp:cRevAnt%
		)
		
		INNER JOIN %table:SC1% SC1 ON(SC1.C1_FILIAL = %xFilial:SC1% AND SC1.C1_NUM = CNB.CNB_NUMSC AND SC1.C1_ITEM = CNB.CNB_ITEMSC AND SC1.%notdel%)
		WHERE 
		CNB.CNB_FILIAL = %xFilial:CNB%
		AND CNB.CNB_CONTRA = %exp:cContra% 
		AND CNB.CNB_REVISA = %exp:cRevAtu% 
		AND ISNULL(CNB2.R_E_C_N_O_,0) = 0
		AND CNB.%notdel%
	EndSql
	
	While ( (cMyAlias)->(!Eof()) )		
		SC1->(DbGoTo((cMyAlias)->IDSC))
		RecLock("SC1",.F.)
		SC1->C1_FLAGGCT := ""
		SC1->(MsUnLock())		
		(cMyAlias)->(dbSkip())
	EndDo	
	(cMyAlias)->(dbCloseArea())
	
	aEval(aAreas, {|x|RestArea(x), aSize(x,0)})
Return Nil

/*/{Protheus.doc} DelByRec
	Deleta os registros da <cUmAlias> com base nos recnos fornecidos em <aRecNos>
@author philipe.pompeu
@since 08/04/2020
@return nil, valor nulo
@param cUmAlias, caractere, tabela da qual os registros devem ser removidos
@param aRecNos, vetor, registros para serem deletados
/*/
Static Function DelByRec(cUmAlias, aRecNos)
	Local nX := 0
	Default cUmAlias:= Alias()
	Default aRecNos	:= {}

	if Len(aRecNos) > 0		
		For nX := 1 To Len(aRecNos)
			(cUmAlias)->( dbGoto( aRecNos[nX]) )
			RecLock( cUmAlias, .F. )
			(cUmAlias)->( dbDelete() )
			(cUmAlias)->( MsUnlock() )
		Next nX
	endif
Return Nil

/*/{Protheus.doc} A300GetCot
	Busca os registros de cotação vinculados ao contrato posicionado na CNB
@author leonardo.magalhaes
@since 22/04/2020
@return aRet, array, Recno's dos registros de acordo com a operação solicitada
@param nOper, numeric, Operação a ser realizada: 1 = Busca por registros na SC8, 2 = Busca por registros na SCE 3 = Busca por registros na SC8 sem os dados da CNB
/*/
Static Function A300GetCot(nOper)

	Local aRet 		:= {}
	Local cAliasAux := GetNextAlias()
	Local cConAux   := Space(Len(CN9->CN9_NUMERO))
	
	Default nOper := 1

	If nOper == 1

		BeginSQL Alias cAliasAux
			SELECT	SC8.R_E_C_N_O_ RECAUX 
			FROM 	%Table:SC8% SC8
			WHERE	C8_FILIAL 		= %xFilial:SC8% 
					AND C8_NUM 		= %Exp:CN9->CN9_NUMCOT%
					AND C8_IDENT 	= %Exp:CNB->CNB_IDENT% 
					AND C8_PRODUTO 	= %Exp:CNB->CNB_PRODUT%
					AND SC8.%NotDel%
					AND C8_NUMCON   <> %Exp:cConAux%
		EndSQL

	ElseIf nOper == 2
		BeginSQL Alias cAliasAux
			SELECT	SCE.R_E_C_N_O_ RECAUX 
			FROM 	%Table:SCE% SCE
			WHERE	CE_FILIAL 		= %xFilial:SCE% 
					AND CE_NUMCOT 	= %Exp:CN9->CN9_NUMCOT%
					AND CE_ITEMCOT 	= %Exp:SC8->C8_ITEM%
					AND CE_PRODUTO 	= %Exp:SC8->C8_PRODUTO%
					AND CE_ITEMGRD	= %Exp:SC8->C8_ITEMGRD% 
					AND CE_FORNECE 	= %Exp:SC8->C8_FORNECE%
					AND CE_LOJA		= %Exp:SC8->C8_LOJA%
					AND CE_NUMPRO   = %Exp:SC8->C8_NUMPRO%
					AND SCE.%NotDel%
		EndSQL

	ElseIf nOper == 3
		BeginSQL Alias cAliasAux
			SELECT	SC8.R_E_C_N_O_ RECAUX 
			FROM 	%Table:SC8% SC8
			WHERE	C8_FILIAL 		= %xFilial:SC8% 
					AND C8_NUM 		= %Exp:CN9->CN9_NUMCOT%
					AND SC8.%NotDel%
					AND C8_NUMCON   <> %Exp:cConAux%
		EndSQL
	EndIf

	If Select(cAliasAUx) > 0
		While !(cAliasAUx)->(Eof())
			aAdd(aRet, (cAliasAux)->RECAUX)
			(cAliasAux)->(DbSkip())
		EndDo

		(cAliasAux)->(DbCloseArea())		
	EndIf	
Return aRet

/*/{Protheus.doc} CposVlPres
	Retorna se deve realizar o calculo do valor presente ou nao com base no dicionario de dados.
@author philipe.pompeu
@since 09/06/2020
@return lResult, lógico, se deve realizar o calculo do valor presente
/*/
Static Function CposVlPres() as Logical
	Local lResult := .F.

	If (lCposVlPre == nil)
		lCposVlPre := CNF->(ColumnPos('CNF_TJUROS') > 0  .And. ColumnPos('CNF_VLPRES') > 0 .And. ColumnPos('CNF_VJUROS') > 0)

		If lCposVlPre
			lCposVlPre := CN9->(ColumnPos('CN9_VJUROS') > 0  .And. ColumnPos('CN9_VLPRES') > 0 .And. ColumnPos('CN9_FRMVL') > 0)
		EndIf
	EndIf
	lResult := lCposVlPre
Return lResult

/*/{Protheus.doc} VlPresente
	Realiza o calculo do valor presente
@author philipe.pompeu
@since 09/06/2020
@return nPresente, numerico, valor presente
@param nFuturo, numeric, valor futuro do qual o valor presente deve ser obtido
@param nJuros, numeric, taxa de juros
@param nParcela, numeric, parcela/periodo a ser calculado
@param nTotParcel, numeric, numero total de parcelas/periodos
/*/
Static Function VlPresente(nFuturo as numeric, nJuros as numeric, nParcela as numeric, nTotParcel as numeric) as numeric
	Local nPresente := 0
	Local nDivisor	:= 0
	Default nFuturo := 0
	Default nJuros 	:= 0
	Default nParcela	:= 0
	Default nTotParcel	:= 0

	nDivisor := ( (1 + nJuros) ^ (nTotParcel - nParcela) )

	If (nDivisor > 0)
		nPresente := nFuturo / nDivisor
	EndIf
Return nPresente

/*/{Protheus.doc} CN300VPres
	Retorna o valor para os campos CNF_VLPRES ou CNF_VJUROS de acordo com <nTipo>
@author philipe.pompeu
@since 09/06/2020
@return nResult, numerico, valor do campo a ser preenchido
@param nTipo, numeric, campo que deve ser retornado
/*/
Function CN300VPres(nTipo as numeric, lContabil as Logical)
	Local nResult	:= 0
	Local cParcela	:= ""
	Local nParcela	:= 0
	Local nParcelas := 0
	Local nJuros	:= 0
	Local nVlrFuturo:= 0
	Local nVlPresent:= 0
	Local oModel	:= FwModelActive()
	Default nTipo	:= 1
	Default lContabil := .F.

	If lContabil //Cronograma Contabil(CNW)
		If (nTipo == 1)//Calcula valor presente
			cParcela	:= oModel:GetValue("CNWDETAIL", "CNW_PARCEL")
			If IsDigit(cParcela)
				nParcela := Val(cParcela) - 1
			Else//Nessa situacao cParcela é alfa
				nParcela := oModel:GetModel("CNWDETAIL"):GetLine() - 1 //Utiliza o numero da linha
			EndIf

			nParcelas	:= oModel:GetValue("CNWDETAIL", "CNW_MAXPAR")
			nJuros		:= (oModel:GetValue("CNWDETAIL", "CNW_TJUROS") / 100)
			nVlrFuturo	:= oModel:GetValue("CNWDETAIL", "CNW_VLPREV")		
			
			nResult := VlPresente(nVlrFuturo, nJuros, nParcela, nParcelas)//Calcula valor presente
			nResult := NoRound(nResult, TamSx3("CNW_VLPREV")[2])
		ElseIf(nTipo == 2)//Calcula o valor dos juros(VJUROS)
			nVlrFuturo	:= oModel:GetValue("CNWDETAIL", "CNW_VLPREV")
			nVlPresent	:= oModel:GetValue("CNWDETAIL", "CNW_VLPRES")
			nResult := (nVlrFuturo - nVlPresent)
		EndIf		
	Else //Cronograma Financeiro(CNF)
		If (nTipo == 1)//Calcula valor presente

			cParcela	:= oModel:GetValue("CNFDETAIL", "CNF_PARCEL")
			If IsDigit(cParcela)
				nParcela := Val(cParcela) - 1
			Else//Nessa situacao cParcela é alfa
				nParcela := oModel:GetModel("CNFDETAIL"):GetLine() - 1 //Utiliza o numero da linha
			EndIf

			nParcelas	:= oModel:GetValue("CNFDETAIL", "CNF_MAXPAR")
			nJuros		:= (oModel:GetValue("CNFDETAIL", "CNF_TJUROS") / 100)
			nVlrFuturo	:= oModel:GetValue("CNFDETAIL", "CNF_VLPREV")
			
			If !Empty(oModel:GetValue("CN9MASTER", "CN9_FRMVL"))
				SM4->(DbSetOrder(1))
				If SM4->(MsSeek(xFilial("SM4") +  oModel:GetValue("CN9MASTER", "CN9_FRMVL")))
					nVlrFuturo := &(AllTrim(SM4->M4_FORMULA))
				EndIf
			EndIf		
			
			nResult := VlPresente(nVlrFuturo, nJuros, nParcela, nParcelas)//Calcula valor presente
			nResult := NoRound(nResult, TamSx3("CNF_VLPREV")[2])
		ElseIf(nTipo == 2)//Calcula o valor dos juros(VJUROS)
			nVlrFuturo	:= oModel:GetValue("CNFDETAIL", "CNF_VLPREV")
			nVlPresent	:= oModel:GetValue("CNFDETAIL", "CNF_VLPRES")
			nResult := (nVlrFuturo - nVlPresent)
		EndIf
	EndIf

Return nResult

/*/{Protheus.doc} C300CNZLOk
Função de pós-validação da linha do grid da CNZ (LinhaOk)
@author fabiano.dantas
@since 26/06/2020
@param oModel, object, Modelo de dados.
@param aEntAd, array, Entidades contábeis adicionais.
@return lRet, logical, Linha válida (.T.) ou inválida (.F.).
/*/
Function C300CNZLOk(oModelCNZ)
	Local lRet 	    := .T.


	If oModelCNZ <> Nil
		//-- Valida amarração contábil
		lRet := GctAmarra(oModelCNZ:GetValue("CNZ_CONTA"), oModelCNZ:GetValue("CNZ_CC"),oModelCNZ:GetValue("CNZ_ITEMCT"), oModelCNZ:GetValue("CNZ_CLVL"), "CNZ", oModelCNZ)
	EndIf
Return lRet

/*/{Protheus.doc} VlAltCtrGS
	Valida alteracoes em contratos originados por Gestao de Servicos
@author philipe.pompeu
@since 03/07/2020
@return lRet, logical, se pode ou nao realizar a operacao
/*/
Static Function VlAltCtrGS() as Logical
	Local lRet := .T.
	Local lGsStack := ( !(FWIsInCallStack('TECA870') .OR. FWIsInCallStack('TECA745') .OR. FWIsInCallStack('TECA850')) .AND. !(FWIsInCallStack('AT870DelRe')) )
	
	If (A300IsServs() .And. lGsStack)
		Help(" ",1,"CNTA300TEC")	//-- Acao disponivel apenas para contratos sem vinculos com Gestão de Serviços
		lRet :=  .F.
	EndIf
Return lRet

/*/{Protheus.doc} GctAmarra
	Valida a amarracao das entidades fornecidas.
@author philipe.pompeu
@since 08/07/2020
@return lResult, logical, amarracao correta das entidades
/*/
Function GctAmarra(cConta, cCC, cItem, cClVl, cTable, oSubModel) as Logical
	Local aCTBEnt	:= {}
	Local aEntid 	:= {}
	Local aEntid2 	:= {}
	Local cPrefCpo	:= ""
	Local cCpoDb	:= ""
	Local cCpoCr	:= ""
	Local lResult	:= .T.
	Local nX		:= 0
	
	If (_aCTBEnt == Nil)
		_aCTBEnt := aClone(CTBEntArr())
	EndIf
	aCTBEnt := _aCTBEnt

	aAdd(aEntid, cConta) 
	aAdd(aEntid, cCC)	  
	aAdd(aEntid, cItem)
	aAdd(aEntid, cClVl)

	If Len(aCTBEnt) > 0 //Verifica entidades contabeis adicionais
		aEntid2 := aClone(aEntid)

		cPrefCpo := PrefixoCpo(cTable)

		For nX := 1 to Len(aCTBEnt)
			cCpoDb :=  cPrefCpo + "_EC"+aCTBEnt[nX]+"DB"
			cCpoCr :=  cPrefCpo + "_EC"+aCTBEnt[nX]+"CR"
			
			If (cTable)->( FieldPos(cCpoDb) > 0 )
				aAdd(aEntid,oSubModel:GetValue(cCpoDb))
			Else
				aAdd(aEntid, "")
			EndIf	
			If (cTable)->( FieldPos(cCpoCr) > 0 )
				aAdd(aEntid2,oSubModel:GetValue(cCpoCr))
			Else
				aAdd(aEntid2, "")
			EndIf
		Next
	EndIf

	lResult := (CtbAmarra(cConta, cCC, cItem, cClVl,,,, aEntid) .And. CtbAmarra(cConta, cCC, cItem, cClVl,,,, aEntid2))//-- Valida amarração contábil
	
	FwFreeArray(aEntid)
	FwFreeArray(aEntid2)
Return lResult

/*/{Protheus.doc} GetNatAdian
	Retorna a natureza a ser utilizada nos titulos de adiantamento
@author philipe.pompeu
@since 20/07/2020
@return cRetNat, char, natureza que deve ser usada
/*/
Static Function GetNatAdian(cNatCtr as Char) as Char
	Local cRetNat	:= PadR( GetNewPar( "MV_CNNATAD",  "" ), TAMSX3('E2_NATUREZ')[1])//Natureza
	Default cNatCtr := CN9->CN9_NATURE

	If (Empty(cRetNat))
		cRetNat := cNatCtr 
	EndIf
Return cRetNat

/*/{Protheus.doc} GerTitAdian
	Gera os títulos de adiantamento
@author philipe.pompeu
@since 20/07/2020
@return lRet, logical, se os adiantamentos foram gerados com sucesso.
/*/
Static Function GerTitAdian(oModel as Object) as Logical
	Local lRet		:= .T.
	Local nI		:= 0
	Local cNumTit   := ""
	Local cRetPrf   := PadR( GetNewPar( "MV_CNPREAD", "CRE" ), Len( SE2->E2_PREFIXO ) )//Prefixo
    Local cFilSA1   := xFilial("SA1")
    Local cFilSA2   := xFilial("SA2")
	Local cCodiCNT	:= ""
	Local cLojaCNT	:= ""
	Local cTpTit	:= ""
	Local cRetNat  	:= ""
	Local cNumCNX	:= ""
	Local cCheque	:= ""
	Local oModelCNX	:= oModel:GetModel("CNXDETAIL")
	Local oModelCN9	:= oModel:GetModel("CN9MASTER")
	Local cEspCtr	:= oModelCN9:GetValue('CN9_ESPCTR')

	cRetNat := GetNatAdian(oModelCN9:GetValue("CN9_NATURE"))

	For nI := 1 To oModelCNX:Length()
		oModelCNX:GoLine(nI)
		If !lRet
			Exit
		EndIf

		cNumCNX   	:= oModelCNX:GetValue("CNX_NUMERO")
		cBco      	:= oModelCNX:GetValue("CNX_BANCO")
		cAgc      	:= oModelCNX:GetValue("CNX_AGENCI")
		cCta      	:= oModelCNX:GetValue("CNX_CONTA")
		cCodiCNT	:= If(cEspCtr == '1',oModelCNX:GetValue("CNX_FORNEC"),oModelCNX:GetValue("CNX_CLIENT"))
		cLojaCNT	:= If(cEspCtr == '1',oModelCNX:GetValue("CNX_LJFORN"),oModelCNX:GetValue("CNX_LOJACL"))
		nVlAdianta	:= oModelCNX:GetValue("CNX_VLADT")
		
		//-- Tratamento localizado para gerar título tipo CH
		If oModelCNX:HasField('CNX_CHEQUE') .And. cEspCtr == '1' 
			cCheque := oModelCNX:GetValue("CNX_CHEQUE")
		EndIf

		//Inclusão
		If !oModelCNX:IsDeleted() .And. oModelCNX:IsInserted()
			Processa({|| lRet := CN100ProcAd(cNumCNX,cEspCtr,CN9->CN9_NUMERO,@cCodiCNT,@cLojaCNT,cBco,cAgc,cCta,nVlAdianta,cRetNat,cRetPrf,@cTpTit,@cNumTit,cCheque)},,STR0250)
			oModelCNX:SetValue('CNX_NUMTIT', cNumTit)
			oModelCNX:SetValue('CNX_PREFIX', cRetPrf)

			If lRet .And. !IsBlind()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Exibe o resumo                                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DEFINE MSDIALOG oDlg TITLE STR0188 FROM 9,0 TO 25,50 OF oMainWnd //"Resumo"
				@ 00,00 BITMAP oBmp RESNAME STR0240 oF oDlg SIZE 30, 120 NOBORDER WHEN .F. PIXEL
				DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
				@ 08,38 SAY STR0188 FONT oBold PIXEL//"Resumo"

				@ 24,30 TO 26 ,400 LABEL '' OF oDlg   PIXEL

				@ 31,38 SAY STR0189 PIXEL OF oDlg // "Prefixo"
				@ 41,38 SAY STR0190 PIXEL OF oDlg // "Numero do Titulo"
				@ 51,38 SAY STR0191 PIXEL OF oDlg // "Tipo"
				@ 61,38 SAY STR0192 PIXEL OF oDlg // "Valor"
				If cEspCtr == "1"
		    		@ 71,38 SAY STR0137 PIXEL OF oDlg // "Fornecedor"
		    	Else
					@ 71,38 SAY STR0138 PIXEL OF oDlg // "Cliente"
		    	Endif
				@ 31,110 SAY cRetPrf SIZE 80, 10 PIXEL   RIGHT
				@ 41,110 SAY cNumTit  SIZE 80, 10 PIXEL   RIGHT
		    	@ 51,110 SAY cTpTit   SIZE 80, 10 PIXEL   RIGHT

				If cEspCtr == "1"
					SA2->(dbSetOrder(1))
					SA2->(dbSeek(cFilSA2+cCodiCNT+cLojaCNT))

					@ 61,110 SAY Transform(nVlAdianta ,PesqPict("SE2","E2_VALOR"))  SIZE 80, 10 PIXEL   RIGHT
					@ 71,110 SAY SA2->A2_COD+" "+SA2->A2_LOJA  SIZE 80, 10 PIXEL   RIGHT
					@ 81,110 SAY If(lLGPD,RetTxtLGPD(SA2->A2_NOME,"A2_NOME"),SA2->A2_NOME)  SIZE 80, 10 PIXEL   RIGHT
				Else
					SA1->(dbSetOrder(1))
					SA1->(dbSeek(cFilSA1+cCodiCNT+cLojaCNT))

					@ 61,110 SAY Transform(nVlAdianta ,PesqPict("SE1","E1_VALOR"))  SIZE 80, 10 PIXEL   RIGHT
					@ 71,110 SAY SA1->A1_COD+" "+SA1->A1_LOJA  SIZE 80, 10 PIXEL   RIGHT
					@ 81,110 SAY If(lLGPD,RetTxtLGPD(SA1->A1_NOME,"A1_NOME"),SA1->A1_NOME) SIZE 80, 10 PIXEL   RIGHT
				Endif

				@ 90,030 TO 92 ,400 LABEL '' OF oDlg PIXEL

				DEFINE SBUTTON oBut FROM 101,162  TYPE 1 ACTION ( oDlg:End() ) ENABLE of oDlg
				ACTIVATE MSDIALOG oDlg CENTERED
			EndIf
		EndIf

		//Exclusão
		If oModelCNX:IsDeleted()
			Processa({|| lRet := CN100EstAd(CN9->CN9_NUMERO,cNumCNX,cEspCtr)},,STR0172)	//"Cancelamento do adiantamento"
		EndIf
	Next nI

Return lRet

/*/{Protheus.doc} AtriTpcPg
	Função para atribuir o tipo da Planilha e Cond de Pagameto para geracao de contratos apartir de uma rotina automatica.
@author eduardo.dias
@since 21/07/2020
@param oModel que sera utilizado para retirar ou atribuir o conteudo aos campos 
@param lVenda se e edital de Venda
@return nil, valor nulo
/*/
Static Function AtriTpcPg(oCN9Master,lVenda)
	Local cTPCTO		:= ""
	Default oCN9Master	:= Nil
	Default lVenda		:= .F.

	cTPCTO:= IIF(!lVenda,"001","002")

	If oCN9Master <> Nil
		oCN9Master:LoadValue('CN9_TPCTO',cTPCTO)
		oCN9Master:LoadValue('CN9_CONDPG','001')
	EndIf

Return Nil

/*/{Protheus.doc} CN300DeAct
	Bloco chamado no DeActivate do modulo. Limpa variaveis estaticas de cache
@author philipe.pompeu
@since 14/08/2020
@return lRet, logical, se os adiantamentos foram gerados com sucesso.
/*/
Function CN300DeAct(oModel)
	If (_oC7PreSta != Nil)
		_oC7PreSta:Destroy()
		_oC7PreSta := Nil
	EndIf
	If (ValType(_aCTBEnt) == 'A')		
		FwFreeArray(_aCTBEnt)
	EndIf
	If FindFunction("CNXStClean")
		CNXStClean()//Limpa variaveis estaticas do CNTXFUN
	EndIf

	If (ValType(_oPlaProps) == 'O')
		_oPlaProps:Clean()		
	EndIf
	FreeObj(_oViewTabs)
Return

/*/{Protheus.doc} ValPresCtb
	Retorna se deve realizar o calculo do valor presente p/ cronograma contabil(CNW)
@author philipe.pompeu
@since 18/12/2020
@return lResult, lógico, se deve realizar o calculo do valor presente
/*/
Static Function ValPresCtb() as Logical
	Local lResult := .F.

	If (_lVlPreCtb == nil)		 
		_lVlPreCtb := CNW->(ColumnPos('CNW_TJUROS') > 0 .And. ColumnPos('CNW_VLPRES') > 0 .And.;
							ColumnPos('CNW_VJUROS') > 0 .And. ColumnPos('CNW_MAXPAR') > 0)		
		If _lVlPreCtb
			_lVlPreCtb := CNV->(ColumnPos('CNV_VLPRES') > 0 .And. ColumnPos('CNV_VJUROS') > 0)
		EndIf
	EndIf
	lResult := _lVlPreCtb
Return lResult

/*/{Protheus.doc} ConfVlPres
	Configura nos structs da CN9, CNF e CNW os campos referentes ao calculo do valor presente.
@author philipe.pompeu
@since 22/12/2020
@return Nil, indefinido
/*/
Static Function ConfVlPres(oStruCN9, oStruCNF, oStruCNW)
	Local bCondTrPre	:= Nil
	Local bCondCtb		:= Nil

	If CposVlPres()
		bCondTrPre := {||FwFldGet("CNF_TJUROS") > 0}
		oStruCNF:AddTrigger("CNF_VLPREV", "CNF_VLPRES", bCondTrPre, {|| CN300VPres() })
		oStruCNF:AddTrigger("CNF_TJUROS", "CNF_VLPRES", bCondTrPre, {|| CN300VPres() })
		oStruCNF:AddTrigger("CNF_VLPRES", "CNF_VJUROS", bCondTrPre, {|| CN300VPres(2) })

		//Adiciona campo para informar taxa de juros na revisão...
		oStruCN9:AddField(	RetTitle("CNF_TJUROS"),;		// 	[01]  C   Titulo do campo
							RetTitle("CNF_TJUROS"),;		// 	[02]  C   ToolTip do campo
							"CN9_TJUFIN",;					// 	[03]  C   Id do Field
							"N",;							// 	[04]  C   Tipo do campo
							TamSx3("CNF_TJUROS")[1],;		// 	[05]  N   Tamanho do campo
							TamSx3("CNF_TJUROS")[2],;		// 	[06]  N   Decimal do campo
							{||.T.},;						// 	[07]  B   Code-block de validação do campo
							{||.T.},;						// 	[08]  B   Code-block de validação When do campo
							Nil,;							//	[09]  A   Lista de valores permitido do campo
							.F.,;							//	[10]  L   Indica se o campo tem preenchimento obrigatório
							FwBuildFeature( STRUCT_FEATURE_INIPAD, "0" ),;							//	[11]  B   Code-block de inicializacao do campo
							NIL,;							//	[12]  L   Indica se trata-se de um campo chave
							.T.,;							//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
							.T.)							// 	[14]  L   Indica se o campo é virtual
	EndIf

	If ValPresCtb()
		bCondCtb := {||FwFldGet("CNW_TJUROS") > 0}
		oStruCNW:AddTrigger("CNW_VLPREV", "CNW_VLPRES", bCondCtb, {|| CN300VPres(,.T.) })
		oStruCNW:AddTrigger("CNW_TJUROS", "CNW_VLPRES", bCondCtb, {|| CN300VPres(,.T.) })
		oStruCNW:AddTrigger("CNW_VLPRES", "CNW_VJUROS", bCondCtb, {|| CN300VPres(2,.T.) })

		//Adiciona campo para informar taxa de juros na revisão...
		oStruCN9:AddField(	RetTitle("CNW_TJUROS"),;		// 	[01]  C   Titulo do campo
							RetTitle("CNW_TJUROS"),;		// 	[02]  C   ToolTip do campo
							"CN9_TJUCTB",;					// 	[03]  C   Id do Field
							"N",;							// 	[04]  C   Tipo do campo
							TamSx3("CNW_TJUROS")[1],;		// 	[05]  N   Tamanho do campo
							TamSx3("CNW_TJUROS")[2],;		// 	[06]  N   Decimal do campo
							{||.T.},;						// 	[07]  B   Code-block de validação do campo
							{||.T.},;						// 	[08]  B   Code-block de validação When do campo
							Nil,;							//	[09]  A   Lista de valores permitido do campo
							.F.,;							//	[10]  L   Indica se o campo tem preenchimento obrigatório
							FwBuildFeature( STRUCT_FEATURE_INIPAD, "0" ),;							//	[11]  B   Code-block de inicializacao do campo
							NIL,;							//	[12]  L   Indica se trata-se de um campo chave
							.T.,;							//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
							.T.)							// 	[14]  L   Indica se o campo é virtual
	EndIf

Return Nil

/*/{Protheus.doc} VldDelSc
	Verifica se o Contrato foi gerado através do MATA110 e se pode permitir exclusao
@author eduardo.dias
@since 21/12/2020
@return lRet, logical, se permitir excluir o contrato atraves da CNTA300.
/*/
Static Function VldDelSc()
Local nPosSC	:= CN9->(FieldPos("CN9_XSCORI")) > 0
Local lRet		:= .T.

If nPosSC 
	If !Empty(CN9->CN9_XSCORI) .And. !FunName() == 'MATA110'
		lRet := .F.
		Help(" ", 1, "SC1GERA",,STR0313,2) //"Contrato só pode ser excluido pela rotina de solicitação de Compras."
	EndIf
EndIf

Return(lRet)


/*/{Protheus.doc} VldVlrTotal
	Verifica se deve validar o valor total do item do contrato
@author eduardo.dias
@since 23/02/2021
@return lRet, logical
/*/
Static Function VldVlrTotal()

	Local cRvSemValor	:= DEF_REV_PARAL+DEF_REV_REINI+DEF_REV_CLAUS+DEF_REV_FORCL+DEF_REV_GRAPR
	Local lRet	 		:= !(cTipRevisa $ cRvSemValor) //"5"-Paralisação 6-Reinicio 7-Clausulas B-Grupo de Aprovação AP-Aprovação

Return(lRet)

/*/{Protheus.doc} CNURevisa
	Verifica se o CNU_REVISA deve ser utilizado nas revisões.
@author philipe.pompeu
@since 30/03/2021
@return lRet, logico, se deve utilizar o CNU_REVISA
/*/
Function CNURevisa() as Logical
	Local lRet 	:= .F.
	Local cChave:= ""

	lRet := (CNU->(ColumnPos('CNU_REVISA') > 0) .And. X3Uso(GetSx3Cache('CNU_REVISA', 'X3_USADO')))
	If lRet
		cChave 	:= AllTrim(FWX2Unico('CNU'))+"+"
		lRet 	:= "CNU_REVISA" $ cChave //Verifica se o CNU_REVISA está contido na chave unica da CNU
	EndIf	
Return lRet

/*/{Protheus.doc} ConfCNDMdl
	Configura no <oModel> os submodelos da CND(Medições) e Pedidos(SC7 ou SC5).
@author philipe.pompeu
@since 19/04/2021
@return Nil, indefinido
/*/
Static Function ConfCNDMdl(oModel as Object, cVisuMed as Char, lCompra as Logical)
	Local oStruCND		:= Nil
	Local oStruSC7		:= Nil
	Local oStruSC5		:= Nil
	Local aRelation		:= {}
	Local bLoad			:= {|oCND, lCopia|CXNLOADINF(oCND, lCopia)}
	Local bLoadCND		:= Nil
	Local nQuantMed		:= SuperGetMv("MV_QTDEXMD",.F.,0)
	Local nIndice		:= IIF(FWSIXUtil():ExistIndex("CND", "8"),8,1)
	Default cVisuMed	:= SuperGetMV("MV_CTRMED",.F.,"1") //Define a Visualização das Medições e Pedidos

	oStruCND := FWFormStruct(1,'CND')
	oStruCND:SetProperty( '*' , MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD , '' ) )
	oStruCND:AddField(	STR0183,;													// 	[01]  C   Titulo do campo
						STR0183,;													// 	[02]  C   ToolTip do campo
						"CND_FILDES",;												// 	[03]  C   Id do Field
						"C",;														// 	[04]  C   Tipo do campo
						40,;														// 	[05]  N   Tamanho do campo
						0,;															// 	[06]  N   Decimal do campo
						NIL,;														// 	[07]  B   Code-block de validação do campo
						NIL,;														// 	[08]  B   Code-block de validação When do campo
						NIL,;														//	[09]  A   Lista de valores permitido do campo
						.F.,;														//	[10]  L   Indica se o campo tem preenchimento obrigatório
						{|| AllTrim(Left(FWFilialName(,CND->CND_FILIAL,1),40))},;	//	[11]  B   Code-block de inicializacao do campo
						NIL,;														//	[12]  L   Indica se trata-se de um campo chave
						.T.,;														//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.)														// 	[14]  L   Indica se o campo é virtual


	If !Empty(nQuantMed)
		IF	cVisuMed == "2"
			bLoad := {|oCNDDETAIL| LoadMaxMD(oCNDDETAIL)}
		Else
			bLoadCND := {|oCNDDETAIL| LoadMaxMD(oCNDDETAIL)}
		EndIf
	EndIf
			
	If (cVisuMed == "2")
		oModel:AddGrid('CNDDETAIL','CNADETAIL',oStruCND,,,,,bLoad) //Medicao por planilha
		oModel:SetRelation('CNDDETAIL',{{'CND_FILCTR','CN9_FILCTR'},{'CND_NUMERO','CNA_NUMERO'},{'CND_CONTRA','CN9_NUMERO'}},CND->(IndexKey(nIndice))) //Medicao x Planilha
	Else
		oModel:AddGrid('CNDDETAIL','CN9MASTER',oStruCND,,,,,bLoadCND) //Medicao por contrato
		oModel:SetRelation('CNDDETAIL',{{'CND_FILCTR','CN9_FILCTR'},{'CND_CONTRA','CN9_NUMERO'},{'CND_REVISA','CN9_REVISA'}},CND->(IndexKey(nIndice))) //Medicao x Contrato
	EndIf
	oModel:GetModel('CNDDETAIL'):SetOptional(.T.)
	oModel:GetModel('CNDDETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('CNDDETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('CNDDETAIL'):SetNoDeleteLine(.T.)
	oModel:GetModel('CNDDETAIL'):SetNoUpdateLine(.T.)

	If lCompra
		oStruSC7 := FWFormStruct(1,'SC7')
		If !(SC7->(ColumnPos('C7_NUM') > 0) .And. X3Uso(GetSx3Cache('C7_NUM', 'X3_USADO')))
			//-- Adiciona campos na Estrutura SC7
			oStruSC7:AddField(STR0216									,;	// 	[01]  C   Titulo do campo
							STR0216									,;	// 	[02]  C   ToolTip do campo
							"C7_MEDPED"								,;	// 	[03]  C   Id do Field
							"C"										,;	// 	[04]  C   Tipo do campo
							TamSX3("C7_NUM")[1]						,;	// 	[05]  N   Tamanho do campo
							0											,;	// 	[06]  N   Decimal do campo
							NIL										,;	// 	[07]  B   Code-block de validação do campo
							NIL										,;	// 	[08]  B   Code-block de validação When do campo
							NIL										,;	//	[09]  A   Lista de valores permitido do campo
							.F.										,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
							{|| Cn300PdNum()}							,;	//	[11]  B   Code-block de inicializacao do campo
							NIL										,;	//	[12]  L   Indica se trata-se de um campo chave
							.F.										,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
							.T.										)	// 	[14]  L   Indica se o campo é virtual
		EndIf

		oModel:AddGrid('SC7DETAIL','CNDDETAIL',oStruSC7) //Pedido de Compra
		oModel:GetModel('SC7DETAIL'):SetOptional(.T.)
		oModel:GetModel('SC7DETAIL'):SetOnlyQuery(.T.)
		oModel:GetModel('SC7DETAIL'):SetNoInsertLine(.T.)
		oModel:GetModel('SC7DETAIL'):SetNoDeleteLine(.T.)
		oModel:GetModel('SC7DETAIL'):SetNoUpdateLine(.T.)

		aRelation := {{'C7_FILIAL','CND_FILIAL'},{'C7_CONTRA','CN9_NUMERO'},{'C7_MEDICAO','CND_NUMMED'}}
		If cVisuMed == "2"
			aAdd(aRelation, {'C7_PLANILH','CND_NUMERO'} )
		EndIf
		oModel:SetRelation('SC7DETAIL',aRelation,SC7->(IndexKey(1))) //Pedido de Compra		
	Else
		oStruSC5	:= FWFormStruct(1,'SC5')
		oModel:AddGrid('SC5DETAIL','CNDDETAIL',oStruSC5) //Pedido de Venda
		oModel:GetModel('SC5DETAIL'):SetOptional(.T.)
		oModel:GetModel('SC5DETAIL'):SetOnlyQuery(.T.)
		oModel:GetModel('SC5DETAIL'):SetNoInsertLine(.T.)
		oModel:GetModel('SC5DETAIL'):SetNoDeleteLine(.T.)
		oModel:GetModel('SC5DETAIL'):SetNoUpdateLine(.T.)

		aRelation := {{'C5_FILIAL','CND_FILIAL'},{'C5_MDCONTR','CN9_NUMERO'},{'C5_MDNUMED','CND_NUMMED'}}
		If cVisuMed == "2"
			aAdd(aRelation, {'C5_MDPLANI','CND_NUMERO'} )		
		EndIf
		oModel:SetRelation('SC5DETAIL',aRelation, SC5->(IndexKey(1))) //Pedido de Venda
	EndIf
Return Nil

/*/{Protheus.doc} a300SCCent
	Carrega Numero da SC da Ata
@author Vitor Pires
@since 26/04/2021
@return Nil, indefinido
/*/
Static Function a300SCCent(cNumAta as Char, cLote as Char, cNumSC as Char, cItemSC as Char, nQtdeCNB as numeric)
	Local cAliasCX3 := GetNextAlias()

	BeginSql ALIAS cAliasCX3
	SELECT CX3_NUMSC,CX3_ITEMSC,CX3_QUANT
		FROM 	%Table:CX3% CX3
		WHERE	CX3.CX3_FILIAL = %xFilial:CX3%
				AND CX3.CX3_NUMATA = %Exp:cNumAta%
				AND CX3.CX3_LOTE = %Exp:cLote%
				AND CX3.%NotDel%	
		ORDER BY
				CX3_QUANT	
	EndSQL

	While (cAliasCX3)->(!Eof())
		If (cAliasCX3)->CX3_QUANT >= nQtdeCNB
			cNumSC := (cAliasCX3)->CX3_NUMSC
			cItemSC:= (cAliasCX3)->CX3_ITEMSC
			Exit
		EndIf
		(cAliasCX3)->(dbSkip())
	EndDo
	(cAliasCX3)->(dbCloseArea())

Return Nil

/*/{Protheus.doc} CtrMetric
	Soma um na métrica de total de contratos via <FWCustomMetrics>
@author philipe.pompeu
@since 12/05/2021
@return Nil, indefinido
/*/
Static Function CtrMetric(lCompra)
	Local cIdMetric		:= "gestao-de-contratos-protheus_total-contratos-gct_total"
	Local cSubRoutine	:= "cnta300Inc-"
	Local lContinua		:= (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')
	Default lCompra		:= .T.

	If (lContinua)
		cSubRoutine	+= IIF(lCompra, "compra", "venda")

		FWCustomMetrics():setSumMetric(cSubRoutine, cIdMetric, 1, /*dDateSend*/, /*nLapTime*/)
	EndIf
Return

/*/{Protheus.doc} A300IsGTP()
	Função para verificar se o contrato foi gerado por gestão de Transporte de Passageiros
@author GTP
@since 22/06/2021
/*/
Function A300IsGTP(lUsaCND as Logical) as Logical
	Local aArea		:= GetArea()
	Local lRet		:= .F.
	Default lUsaCND	:= .F.
	
	If FindFunction("GTPXGCT")
		lRet := GTPXGCT(lUsaCND) /*Chama a função que verificará se há integração entre o contrato e o SIGAGTP*/
	EndIf

	RestArea(aArea)
	FwFreeArray(aArea)
Return lRet

/*/{Protheus.doc} GCTDuplRat
	Valida a duplicidade das entidades contábeis informadas no rateio
@author jose.souza2
@since 04/02/2022
@param oModelCNZ,Objeto,Instância de CNZDETAIL
@param aEntAd,Array, array contendo as entidades contábeis
@param lCompra,Lógico, informa se o contrato é de compra
@param lPedido,Lógico, informa se será gerado pedido de compra com o contrato ou medição
@return lRet 
*/
Function GCTDuplRat(oModelCNZ,aEntAd,lCompra,lPedido,lValidLin)

	Local lRet		  := .T.
	Local nI		  := 0
	Local nX          := 0
	Local cChaveLin   := ""
	Local cChave      := ""
	Local cCampo      := ""
	Local cSolution   := ""
	Local aChave      := {}
	Local oBusca      := Nil
	Local nLin        := 0
	Local nLinDupl    := 0
	Default lCompra   := .F. 
	Default lPedido   := .F.
	Default aEntAd    := CTBEntArr()
	Default lValidLin := .T.

	If !lCompra .Or. !lPedido .Or. (lCompra .And. !(SuperGetMv('MV_RATDUPL',.F.,.F.)))
		aSaveLines := FWSaveRows()
		oBusca     := THashMap():New()
		aChave := {"CNZ_CC","CNZ_CONTA","CNZ_ITEMCT","CNZ_CLVL"}
		For nX := 1 To Len(aEntAd)
			cCampo := "CNZ_EC" + aEntAd[nX] + "DB"
			If CNZ->(ColumnPos(cCampo)) > 0
				aAdd(aChave,cCampo)
			EndIf

			cCampo := "CNZ_EC" + aEntAd[nX] + "CR"
			If CNZ->(ColumnPos(cCampo)) > 0
				aAdd(aChave,cCampo)
			EndIf

		Next nX
		If lValidLin
			nLin := oModelCNZ:GetLine()
			For nX := 1 to len(aChave)
				cChaveLin += oModelCNZ:GetValue(aChave[nx])
			Next
			oBusca:Set(cChaveLin,nLin)
		Else
			nLin := -1 // Nesse caso todas as linhas serão processadas
		EndIf

		For nI := 1 to oModelCNZ:Length()
			oModelCNZ:GoLine(nI)
			If !oModelCNZ:IsDeleted()

				If nI <> nLin
					cChave := ""
					For nX := 1 to len(aChave)
						cChave += oModelCNZ:GetValue(aChave[nx])
					Next

					If oBusca:Get(cChave, @nLinDupl)
						lRet		:= .F.
						nLinDupl	:= Min(nI,nLinDupl)
						cSolution	:= IIF(lCompra,STR0318,STR0319)
						Help(,,"GCTDuplRat",,STR0317+ Str(nLinDupl),1,0,,,,,,{cSolution}) // Foram encontradas entidades contábeis que já foram informadas em linhas anteriores
																		//  Para utilizar entidades contábeis duplicadas no rateio, é necessário configurar o parâmetro MV_RATDUPL para .T. e o tipo de documento a ser gerado na medição deve estar como "Nota Fiscal"
						Exit
					ElseIf !lValidLin
						oBusca:Set(cChave,nI)
					Endif
				Endif
			EndIf
		Next nI
		FWRestRows( aSaveLines )
		FWFreeArray( aSaveLines )
		FWFreeArray( aChave )
		oBusca:Clean()
		FreeObj(oBusca)
	EndIf
Return lRet

/*/{Protheus.doc} CNZPosVld
	Função de pós validação do submodelo CNZDETAIL
@author jose.souza2
@since 04/02/2022
@param oModelCNZ,Objeto,Instância de CNZDETAIL
@return lResult 
*/
Function CNZPosVld(oModelCNZ)
	Local lResult := .T.
	Local aCTBEnt := CTBEntArr()
	Local oModel  := oModelCNZ:GetModel()
	Local lCompra := .F.
	Local cModelId := oModel:GetId()
	Local cPlan   := ""
	Local cContra := ""
	Local cFilCTR := ""
	Local lPedido := .F.

	If !FwIsInCallStack('Cn121Item')

		If (lResult := CN300VldRat(.T.,,oModelCNZ))
			lResult := C300CNZLOk(oModelCNZ)

			If lResult .And. oModelCNZ:Length() > 1
				If cModelId == "CNTA300" //O Id do modelo será CNTA300 tanto para contrato de venda quanto de compra.
					cContra := oModel:GetValue('CN9MASTER','CN9_NUMERO')
					cFilCTR := oModel:GetValue('CN9MASTER','CN9_FILCTR')
					cPlan   := oModel:GetValue('CNADETAIL','CNA_NUMERO')
					lPedido := oModel:GetValue('CNBDETAIL','CNB_PEDTIT') == "1"
					lCompra := CNTGetFun() == "CNTA300" 
				Else
					cContra := oModel:GetValue('CNDMASTER','CND_CONTRA')
					cFilCTR := oModel:GetValue('CNDMASTER','CND_FILCTR')
					cPlan   := oModel:GetValue('CXNDETAIL','CXN_NUMPLA')
					lPedido := oModel:GetValue('CNEDETAIL','CNE_PEDTIT') == "1"
					lCompra := CN300RetSt( "COMPRA", , cPlan, cContra, cFilCTR, .F. )
				EndIf
				lResult:= GCTDuplRat(oModelCNZ,aCTBEnt,lCompra,lPedido)
			EndIf
		EndIf
	EndIf

	FwFreeArray( aCTBEnt )

Return lResult

/*/{Protheus.doc} VldPdTitCT
	Valid do campo CNB_PEDTIT
@author jose.souza2
@since 14/02/2022
@param oModelCNB,Objeto,Instância de CNBDETAIL
@param cValue,Caracter, Valor informado no campo CNB_PEDTIT
@return lRet
*/
Function VldPdTitCT(oModelCNB,cValue)
	Local lRet		:= .T.
	Local lPedido   := .F.
	Local lCompra   := .F.
	Local oModel    := Nil
	Local oModelCNZ := Nil

	oModel	  := oModelCNB:GetModel()
	oModelCNZ := oModel:GetModel('CNZDETAIL')
	lPedido   := cValue == "1"
	lCompra   := CNTGetFun() == "CNTA300"

	lRet:= GCTDuplRat(oModelCNZ,,lCompra,lPedido,.F.)

Return lRet

/*/{Protheus.doc} CNTA300ULT
	Verifica se <dData> está dentro do período de vigência, se não tiver apresenta alerta
@author philipe.pompeu
@since 31/03/2022
@param dData, data, data a ser comparada a <dFim>
@param dFim, data, data limite
@param lVldVige, lógico, se deve validar a vigência
@return lResult, lógico, se <dData> é valido
/*/
Function CNTA300ULT(dData as Date, dFim as Date, lVldVige as Logical) as Logical
	Local lResult	:= .T.
	Default lVldVige := (SuperGetMV("MV_CNFVIGE", .F., "N") == "N")

	If lVldVige
		If (dData > dFim)
			Help(" ",1,"CNTA300ULT") //-- A quantidade de parcelas é inválida pois ultrapassou a data final do contrato
			lResult := .F.
		EndIf
	EndIf
Return lResult

/*/{Protheus.doc} CtrExecMsg
	Executa bExec via MsExecAuto, qualquer erro apresentado será armazenado via SetErrorMessage em <oModel>
@author philipe.pompeu
@since 31/03/2022
@param bExec, codeblock, bloco à ser executado via MsExecAuto
@param oModel, object, instância de MPFormModel onde os erros devem ser guardados
@param aErroInfo, vetor, dados p/ exibição do erro
@return lResult, lógico, se o execAuto falhou ou não
/*/
Function CtrExecMsg(bExec as block, oModel as Object, aErroInfo as array) as Logical
	Local lResult	:= .T.
	Local aErros	:= {}
	Local cErroCod	:= ""
	Local cErroId	:= ""
	Local cModel	:= ""
	Local cCampo	:= ""
	Private lAutoErrNoFile := .T.
	Private lMsHelpAuto    := .T.
	Private lMsErroAuto    := .F.	
	
	MsExecAuto(bExec, oModel)

	lResult := (!lMsErroAuto)
	If !lResult		
		aErros := GetAutoGRLog()
		aEval(aErros, {|x|cErroCod += x + CRLF })

		aSize(aErroInfo, 3)//Garante o tamanho 3
		cModel := aErroInfo[1]
		cCampo := aErroInfo[2]
		cErroId:= aErroInfo[3]
		
		oModel:SetErrorMessage(cModel,	cCampo, "","",cErroId, cErroCod, cErroCod)
		
		FwFreeArray(aErros)
	Else 
		lResult := !(oModel:HasErrorMessage())
	EndIf

Return lResult

/*/{Protheus.doc} AddAbaCNC
	Adiciona uma aba na folder com código <cFolderId> de <oView> referente a tabela CNC(Fornecedores/Clientes)
@author philipe.pompeu
@since 18/04/2022
@param oView, objeto, instância de FWFormView
@param cFolderId, caractere, identificador da folder que a aba deve ser adicionada
@param oStruCNC, objeto, instância de FwFormStruct da tabela CNC
/*/
Static Function AddAbaCNC(oView, cFolderId, oStruCNC)
	Local lCtrVenda := (CNTGetFun() == 'CNTA301')

	oView:AddSheet(cFolderId,'GRDFORNCLI', IIF(lCtrVenda,STR0320, STR0022))			//Clientes ou Fornecedores
	oView:CreateHorizontalBox('FORN' ,100,/*owner*/,/*lUsePixel*/,cFolderId,'GRDFORNCLI')
	oView:AddGrid('VIEW_CNC',oStruCNC,'CNCDETAIL')	
	oView:SetOwnerView('VIEW_CNC','FORN')
Return

/*/{Protheus.doc} AddAbaVend
	Adiciona uma aba na folder com código <cFolderId> de <oView> referente a tabela CNU(Vendedores)
@author philipe.pompeu
@since 18/04/2022
@param oView, objeto, instância de FWFormView
@param cFolderId, caractere, identificador da folder que a aba deve ser adicionada
@param oStruCNU, objeto, instância de FwFormStruct da tabela CNU
/*/
Static Function AddAbaVend(oView, cFolderId, oStruCNU)
	oView:AddSheet(cFolderId,'GRDVEND',STR0321) 	//"Vendedores"
	oView:AddGrid('VIEW_CNU',oStruCNU,'CNUDETAIL')
	If CNU->(ColumnPos("CNU_ITEM") > 0)		
		oView:AddIncrementField('VIEW_CNU','CNU_ITEM')
	EndIf
	oView:CreateHorizontalBox('VEND',100,,,cFolderId,'GRDVEND')
	oView:SetOwnerView('VIEW_CNU','VEND')
Return

/*/{Protheus.doc} AddAbaMult
	Adiciona uma aba na folder com código <cFolderId> de <oView> referente a tabela CNH(Multas/Bonificacoes)
@author philipe.pompeu
@since 18/04/2022
@param oView, objeto, instância de FWFormView
@param cFolderId, caractere, identificador da folder que a aba deve ser adicionada
@param oStruCNH, objeto, instância de FwFormStruct da tabela CNH
/*/
Static Function AddAbaMult(oView, cFolderId, oStruCNH)

	oView:AddSheet(cFolderId,'GRDMULT',STR0025)			//"Multas/Bonificações"
	oView:CreateHorizontalBox('MULTAS',100,/*owner*/,/*lUsePixel*/,cFolderId,'GRDMULT')
	oView:AddGrid('VIEW_CNH',oStruCNH,'CNHDETAIL')
	oView:SetOwnerView('VIEW_CNH','MULTAS')
Return

/*/{Protheus.doc} AddAbaDocs
	Adiciona uma aba na folder com código <cFolderId> de <oView> referente a tabela CNK(Documentos)
@author philipe.pompeu
@since 18/04/2022
@param oView, objeto, instância de FWFormView
@param cFolderId, caractere, identificador da folder que a aba deve ser adicionada
@param oStruCNK, objeto, instância de FwFormStruct da tabela CNK
/*/
Static Function AddAbaDocs(oView, cFolderId, oStruCNK)	
	oView:AddGrid('VIEW_CNK',oStruCNK,'CNKDETAIL')
	oView:AddSheet(cFolderId,'GRDDOC',STR0026) 		//"Documentos"
	oView:CreateHorizontalBox('DOC',100,/*owner*/,/*lUsePixel*/,cFolderId,'GRDDOC')
	oView:SetOwnerView('VIEW_CNK','DOC')
Return

/*/{Protheus.doc} AddAbaAdts
	Adiciona uma aba na folder com código <cFolderId> de <oView> referente a tabela CNX(Adiantamentos)
@author philipe.pompeu
@since 18/04/2022
@param oView, objeto, instância de FWFormView
@param cFolderId, caractere, identificador da folder que a aba deve ser adicionada
@param oStruCNX, objeto, instância de FwFormStruct da tabela CNX
/*/
Static Function AddAbaAdts(oView, cFolderId, oStruCNX)
	oView:AddGrid('VIEW_CNX',oStruCNX,'CNXDETAIL')
	oView:AddIncrementField('VIEW_CNX','CNX_NUMERO')
	oView:AddSheet(cFolderId,'GRDADT',STR0027) 			//"Adiantamentos"
	oView:CreateHorizontalBox('ADTO',100,/*owner*/,/*lUsePixel*/,cFolderId,'GRDADT')
	oView:SetOwnerView('VIEW_CNX','ADTO')
Return

/*/{Protheus.doc} AddAbaCauc
	Adiciona uma aba na folder com código <cFolderId> de <oView> referente a tabela CN8(Cauções) e CNI(Nota Fiscal de Caução)
@author philipe.pompeu
@since 18/04/2022
@param oView, objeto, instância de FWFormView
@param cFolderId, caractere, identificador da folder que a aba deve ser adicionada
@param oStruCN8, objeto, instância de FwFormStruct da tabela CN8
@param oStruCNI, objeto, instância de FwFormStruct da tabela CNI
/*/
Static Function AddAbaCauc(oView, cFolderId, oStruCN8, oStruCNI)
	//Adiciona a Aba "Caucoes"
	oView:AddSheet(cFolderId,'GRDCAUC',STR0023)		//"Cauções"
	oView:CreateHorizontalBox('CAUCAO',100,/*owner*/,/*lUsePixel*/,cFolderId,'GRDCAUC')
	
	//Cria subpastas: Cauções(CN8) e Notas Fiscais(CNI)
	oView:CreateFolder('FLDCAUC','CAUCAO')
	oView:AddSheet('FLDCAUC','GRDCAB',STR0029)	//"Caução"
	oView:CreateHorizontalBox('CAUCCB',100,/*owner*/,/*lUsePixel*/,'FLDCAUC','GRDCAB')
	oView:AddGrid('VIEW_CN8',oStruCN8,'CN8DETAIL')
	oView:SetOwnerView('VIEW_CN8','CAUCCB')

	oView:AddSheet('FLDCAUC','GRDITS',STR0030)	//"Notas Fiscais"
	oView:CreateHorizontalBox('CAUCIT',100,/*owner*/,/*lUsePixel*/,'FLDCAUC','GRDITS')
	oView:AddGrid('VIEW_CNI',oStruCNI,'CNIDETAIL')
	oView:SetOwnerView('VIEW_CNI','CAUCIT')
Return

/*/{Protheus.doc} AddAbaCRet
	Adiciona uma aba na folder com código <cFolderId> de <oView> referente a tabela CNT(Cauções Retidos)
@author philipe.pompeu
@since 18/04/2022
@param oView, objeto, instância de FWFormView
@param cFolderId, caractere, identificador da folder que a aba deve ser adicionada
@param oStruCNT, objeto, instância de FwFormStruct da tabela CNT
/*/
Static Function AddAbaCRet(oView, cFolderId, oStruCNT)
	oView:AddSheet(cFolderId,'GRDCRT',STR0028) 		//"Caucões Retidas"
	oView:CreateHorizontalBox('CARET',100,/*owner*/,/*lUsePixel*/,cFolderId,'GRDCRT')
	oView:AddGrid('VIEW_CNT',oStruCNT,'CNTDETAIL')
	oView:SetOwnerView('VIEW_CNT','CARET')
Return

/*/{Protheus.doc} AddAbaReaj
	Adiciona uma aba na folder com código <cFolderId> de <oView> referente a tabela CXL(Itens de Reajuste)
@author philipe.pompeu
@since 18/04/2022
@param oView, objeto, instância de FWFormView
@param cFolderId, caractere, identificador da folder que a aba deve ser adicionada
@param oStruCXL, objeto, instância de FwFormStruct da tabela CXL
/*/
Static Function AddAbaReaj(oView, cFolderId, oStruCXL)
	oView:AddGrid('VIEW_CXL',oStruCXL,'CXLDETAIL')
	oView:AddSheet(cFolderId,'GRDREAJ',STR0279)	//"Reajustes"
	oView:CreateHorizontalBox('REAJUSTE',100,/*owner*/,/*lUsePixel*/,cFolderId,'GRDREAJ')
	oView:SetOwnerView('VIEW_CXL','REAJUSTE')
Return

/*/{Protheus.doc} AddAbaPlan
	Adiciona uma aba na folder com código <cFolderId> de <oView> referente a tabela CNA(Planilhas)
@author philipe.pompeu
@since 18/04/2022
@param oView, objeto, instância de FWFormView
@param cFolderId, caractere, identificador da folder que a aba deve ser adicionada
@param oStruCNA, objeto, instância de FwFormStruct da tabela CNA
@return cFoldPlan, caractere, identificador da folder dos itens da planilha
/*/
Static Function AddAbaPlan(oView, cFolderId, oStruCNA)
	Local cFoldPlan :=  "FLDPLAN"

	oView:AddSheet(cFolderId,'GRDPLAN',STR0024)		//"Planilhas"

	oView:AddGrid('VIEW_CNA',oStruCNA,'CNADETAIL')
	oView:AddIncrementField('VIEW_CNA','CNA_NUMERO')
	oView:SetViewProperty( 'VIEW_CNA', "CHANGELINE", {{ |oView, cViewID| a300ChgLine(oView, cViewID) }} )
	oView:CreateHorizontalBox('PLANCAB',30,/*owner*/,/*lUsePixel*/,cFolderId,'GRDPLAN')//Adiciona o grid das planilhas(CNA)
	oView:SetOwnerView('VIEW_CNA','PLANCAB')
	
	oView:CreateHorizontalBox('PLANITS',70,/*owner*/,/*lUsePixel*/,cFolderId,'GRDPLAN')
	oView:CreateFolder(cFoldPlan,'PLANITS')	
Return cFoldPlan

/*/{Protheus.doc} AddAbaCNB
	Adiciona uma aba na folder com código <cFolderId> de <oView> referente a tabela CNB(Itens da Planilha)
@author philipe.pompeu
@since 18/04/2022
@param oView, objeto, instância de FWFormView
@param cFolderId, caractere, identificador da folder que a aba deve ser adicionada
@param oStruCNB, objeto, instância de FwFormStruct da tabela CNB
/*/
Static Function AddAbaCNB(oView, cFolderId, oStruCNB)

	//Adiciona subpasta(aba) Itens da Planilha(CNB)
	oView:AddSheet(cFolderId,'ABAITS',STR0031 ) 		//"Itens"
	oView:CreateHorizontalBox('GRDITS',100,/*owner*/,/*lUsePixel*/,cFolderId,'ABAITS')

	oView:AddGrid('VIEW_CNB',oStruCNB,'CNBDETAIL')
	oView:AddIncrementField('VIEW_CNB','CNB_ITEM')
	oView:SetOwnerView('VIEW_CNB','GRDITS')	
Return

/*/{Protheus.doc} AddAbaCNZ
	Adiciona uma aba na folder com código <cFolderId> de <oView> referente a tabela CNZ(Rateios) e o totalizador(oCalcCNZ)
@author philipe.pompeu
@since 18/04/2022
@param oView, objeto, instância de FWFormView
@param cFolderId, caractere, identificador da folder que a aba deve ser adicionada
@param oStruCNZ, objeto, instância de FwFormStruct da tabela CNZ
@param oCalcCNZ, objeto, instância de FWCalcStruct de CALC_CNZ
/*/
Static Function AddAbaCNZ(oView, cFolderId, oStruCNZ, oCalcCNZ)

	//Adiciona aba de Rateios do Item(CNZ): dividida em: 75%(Grid) e 25%(Totalizador)
	oView:AddSheet(cFolderId,'ABARAT',STR0032 ) 		//"Rateio It."

	//Adiciona grid dos rateios(75%)
	oView:AddGrid('VIEW_CNZ',oStruCNZ,'CNZDETAIL')
	oView:AddIncrementField('VIEW_CNZ','CNZ_ITEM')
	oView:CreateHorizontalBox('GRDRAT',75, /*owner*/,/*lUsePixel*/,cFolderId,'ABARAT')
	oView:SetOwnerView('VIEW_CNZ','GRDRAT')
	
	//Adiciona totalizador dos rateios(25%)	
	oView:AddField('VCNZTOT',oCalcCNZ,'CALC_CNZ')
	oView:SetViewProperty('VCNZTOT', 'SETLAYOUT', {FF_LAYOUT_HORZ_DESCR_LEFT, 1})
	oView:CreateHorizontalBox('TOTRAT',25,/*owner*/,/*lUsePixel*/,cFolderId,'ABARAT')
	oView:SetOwnerView("VCNZTOT","TOTRAT")
Return

/*/{Protheus.doc} AddAbaCXM
	Adiciona uma aba na folder com código <cFolderId> de <oView> referente a tabela CXM(Agrupadores de Estoque)
@author philipe.pompeu
@since 18/04/2022
@param oView, objeto, instância de FWFormView
@param cFolderId, caractere, identificador da folder que a aba deve ser adicionada
@param oStruCXM, objeto, instância de FwFormStruct da tabela CXM
/*/
Static Function AddAbaCXM(oView, cFolderId, oStruCXM)
	oView:AddSheet(cFolderId,'ABAAGR',STR0242 ) 		//""Agrupadores de Estoque""
	oView:CreateHorizontalBox('GRDAGR',100,/*owner*/,/*lUsePixel*/,cFolderId,'ABAAGR')
	oView:AddGrid('VIEW_CXM',oStruCXM,'CXMDETAIL')
	oView:AddIncrementField('VIEW_CXM','CXM_ITEMID')
	oView:SetOwnerView('VIEW_CXM','GRDAGR')
Return

/*/{Protheus.doc} AddAbaCNZ
	Adiciona uma aba na folder com código <cFolderId> de <oView> referente a tabela CNZ(Rateios) e o totalizador(oCalcCNZ)
@author philipe.pompeu
@since 18/04/2022
@param oView, objeto, instância de FWFormView
@param cFolderId, caractere, identificador da folder que a aba deve ser adicionada
@param oStruCNZ, objeto, instância de FwFormStruct da tabela CNZ
@param oCalcCNZ, objeto, instância de FWCalcStruct de CALC_CNZ
/*/
Static Function AddAbaCNF(oView, cFolderId, oStruCNF, oCalcCNF)

	oView:AddSheet(cFolderId,'ABACRG',STR0033 ) 	//"Cronog. Financ."
	oView:CreateHorizontalBox('GRDCLC',35,/*owner*/,/*lUsePixel*/,cFolderId,'ABACRG')
	oView:CreateHorizontalBox('GRDCRG',65,/*owner*/,/*lUsePixel*/,cFolderId,'ABACRG')
	
	oView:AddField('VIEW_CLC1',oCalcCNF,'CALC_CNF')
	oView:SetOwnerView('CALC_CNF','GRDCLC')

	oView:AddGrid('VIEW_CNF',oStruCNF,'CNFDETAIL')
	oView:SetOwnerView('VIEW_CNF','GRDCRG')
Return

/*/{Protheus.doc} AddAbaCNS
	Adiciona uma aba na folder com código <cFolderId> de <oView> referente a tabela CNS(Cronogram Físico)
@author philipe.pompeu
@since 18/04/2022
@param oView, objeto, instância de FWFormView
@param cFolderId, caractere, identificador da folder que a aba deve ser adicionada
@param oStruCNS, objeto, instância de FwFormStruct da tabela CNS
@param oStruTCNS, objeto, instância de FWFormViewStruct
/*/
Static Function AddAbaCNS(oView, cFolderId, oStruCNS, oStruTCNS)

	oView:AddSheet(cFolderId,'ABACRF',STR0034 ) 	//"Cronog. Fisico"
	oView:CreateHorizontalBox('GRDCRC',35,/*owner*/,/*lUsePixel*/,cFolderId,'ABACRF')
	oView:CreateHorizontalBox('GRDCRF',65,/*owner*/,/*lUsePixel*/,cFolderId,'ABACRF')
	oView:AddGrid('VIEW_CNS',oStruCNS,'CNSDETAIL')
	oView:SetOwnerView('VIEW_CNS','GRDCRF')
	oView:AddField('VIEW_CLC2',oStruTCNS,'CALC_CNS')
	oView:SetOwnerView('CALC_CNS','GRDCRC')
Return

/*/{Protheus.doc} AddAbaCCtb
	Adiciona uma aba na folder com código <cFolderId> de <oView> referente a tabela CNV(Cabeçalho do Cronograma Contábil) e CNW(Itens do Cronograma Contábil)
@author philipe.pompeu
@since 18/04/2022
@param oView, objeto, instância de FWFormView
@param cFolderId, caractere, identificador da folder que a aba deve ser adicionada
@param oStruCNV, objeto, instância de FwFormStruct da tabela CNV
@param oStruCNW, objeto, instância de FwFormStruct da tabela CNW
/*/
Static Function AddAbaCCtb(oView, cFolderId, oStruCNV, oStruCNW)

	oView:AddSheet(cFolderId,'ABACCB',STR0035 ) 	//"Cronog. Contab."
	oView:CreateHorizontalBox('GRDCTB',40,/*owner*/,/*lUsePixel*/,cFolderId,'ABACCB')
	oView:CreateHorizontalBox('GRDCBI',60,/*owner*/,/*lUsePixel*/,cFolderId,'ABACCB')
	oView:AddGrid('VIEW_CNV',oStruCNV,'CNVDETAIL')
	oView:SetOwnerView('VIEW_CNV','GRDCTB')
	oView:AddGrid('VIEW_CNW',oStruCNW,'CNWDETAIL')
	oView:SetOwnerView('VIEW_CNW','GRDCBI')	
Return

/*/{Protheus.doc} AddAbaMNat
	Adiciona uma aba na folder com código <cFolderId> de <oView> referente as múltiplas naturezas(CXO e CXP)
@author philipe.pompeu
@since 18/04/2022
@param oView, objeto, instância de FWFormView
@param cFolderId, caractere, identificador da folder que a aba deve ser adicionada
@param oStruCXO, objeto, instância de FwFormStruct da tabela CXO
@param oStruCXP, objeto, instância de FwFormStruct da tabela CXP
/*/
Static Function AddAbaMNat(oView, cFolderId, oStruCXO, oStruCXP)

	oView:AddGrid('VIEW_CXO',oStruCXO,'CXODETAIL')
	oView:AddGrid('VIEW_CXP',oStruCXP,'CXPDETAIL')
	
	oView:AddSheet(cFolderId,'ABANTM',STR0265) 		//'Mult. Naturezas da Planilha'
	oView:CreateHorizontalBox('GRDNTM',40,/*owner*/,/*lUsePixel*/,cFolderId,'ABANTM')
	oView:CreateHorizontalBox('GRDCCM',60,/*owner*/,/*lUsePixel*/,cFolderId,'ABANTM')
	oView:SetOwnerView('VIEW_CXO','GRDNTM')
	oView:SetOwnerView('VIEW_CXP','GRDCCM')
	
	oView:AddIncrementField('VIEW_CXO','CXO_ITEM')
	oView:AddIncrementField('VIEW_CXP','CXP_ITEM')
Return

/*/{Protheus.doc} AddAbaMeds
	Adiciona uma aba na folder com código <cFolderId> de <oView> referente a tabela CND(Medições)
@author philipe.pompeu
@since 18/04/2022
@param oView, objeto, instância de FWFormView
@param cFolderId, caractere, identificador da folder que a aba deve ser adicionada
@param oStruCND, objeto, instância de FwFormStruct da tabela CND
@return cViewPedId, caractere, identificador da view que os pedidos devem ser exibidos
/*/
Static Function AddAbaMeds(oView, cFolderId, oStruCND)
	Local cViewPedId := "PEDIDO"
	
	oView:AddSheet(cFolderId,'GRDMED',STR0125) 		//"Medições"

	oView:AddGrid('VIEW_CND',oStruCND,'CNDDETAIL')
	oView:CreateHorizontalBox('MEDIT',30,/*owner*/,/*lUsePixel*/	,cFolderId,'GRDMED')
	oView:SetOwnerView('VIEW_CND','MEDIT')

	//oView:CreateFolder('FLDMED','PEDIDO')
	//oView:AddSheet('FLDMED','ABAPED',STR0126 ) 		//"Pedidos"
	//oView:CreateHorizontalBox('GRDPED',100,/*owner*/,/*lUsePixel*/,'FLDMED','ABAPED')
	oView:CreateHorizontalBox(cViewPedId,70,/*owner*/,/*lUsePixel*/	,cFolderId,'GRDMED')
	
Return cViewPedId

/*/{Protheus.doc} GetUsrBtns
	Retorna os botões(UserButton) que devem ser adicionar na view do CNTA300/301(Contratos)
@author philipe.pompeu
@since 18/04/2022
@param oModel, objeto, instância de MPFormModel
@param lVisuCro, lógico, se visualiza cronogramas
@return aButtons, vetor, lista dos botões
/*/
Static Function GetUsrBtns(oModel, lVisuCro)
	Local lCtrVenda	:= (CNTGetFun() == 'CNTA301')
	Local aButtons	:= {}
	Local cVisuMed	:= SuperGetMV("MV_CTRMED",.F.,"1")
	Local lRemovCrg		:= .F.
	Local lRemovCtb		:= .F.
	Local lC100VlAt		:= .F.
	Local lIncluiCtr := (Type('INCLUI') != "U" .And. INCLUI) .Or. (IsIncByGCT() .Or. IsIncByGCP())//Previne error.log ao chamar a view sem declarar variável INCLUI
	Local lAlteraCtr := (Type('ALTERA') != "U" .And. ALTERA) .Or. FWIsInCallStack("CN300Alter")//Previne error.log ao chamar a view sem declarar variável ALTERA

	lC100VlAt	:= CN300VLAT(oModel)

	If FWIsInCallStack("CN300Visua")
		aAdd(aButtons,{STR0197, {|| CN300VFoCl()}})
	EndIf

	//-- Banco de Conhecimento e Tracker
	If !lAdiant
		If (FWIsInCallStack("CN300Visua") .Or. FWIsInCallStack("A097Visual"))
			If cVisuMed <> "0"
				If !lCtrVenda
					aAdd(aButtons,{STR0127, {|| CN300ViewPC()}	})//Visualizar Pedido de Compra					
				Else
					aAdd(aButtons,{STR0322, {|| CN301ViewVd()}	})//Visualizar Pedido de Venda	
				EndIf
			EndIf		

			If !lCtrVenda
				aAdd(aButtons,{STR0149, {|| a120Posic("CN9",CN9->(Recno()),2,IIF(!Empty(CN9->CN9_REVISA),"IR","IC"),.F.)}	})//"Aprovação por Itens"
				aAdd(aButtons,{STR0037, {|| CN300Docum()}	})//-- Conhecimento
			Else
				aAdd(aButtons,{STR0149, {|| CN301posic("CN9",CN9->(Recno()),2,IIF(!Empty(CN9->CN9_REVISA),"IR","IC"),.F.)}	})//"Aprovação por Itens"
				aAdd(aButtons,{STR0037, {|| StaticCall(CNTA100,CN100Conh)}	})//-- Conhecimento

				If SuperGetMv("MV_CNINTFS",.F.,.F.)//Adiciona botão para localização física (Gestao de Servicos)
					aAdd(aButtons,{STR0051, {|| TECLOCFIS()} })
				EndIf
			EndIf

			aAdd(aButtons,{STR0036, {|| CN100Hist(M->CN9_NUMERO)} })//-- Histórico
			aAdd(aButtons,{STR0038, {|| CN300Track()} })//-- Tracker
			aAdd(aButtons,{STR0150, {|| CN300VDoc()} })//"Visualizar Documento"
			aAdd(aButtons,{STR0264, {|| CN300PrtExp()} })		

		ElseIf !FWIsInCallStack("CN300Delet") .And. Empty(cAprTipRev) .And. !( FWIsInCallStack("CN300Alter") .And. !( AllTrim(CN9->CN9_SITUAC) $ ( DEF_SELAB + "|" + DEF_SREVS + "|" + DEF_SREVA + "|" + DEF_SREJE ) ) )
			If !Empty(cTipRevisa) // Somente na Revisao
				If !lRemovCrg
					aAdd(aButtons,{STR0152,{|| CN300RdSld(oModel)}	})	//"Redistribuir Saldo"
					aAdd(aButtons,{STR0151,{|| CN300AtCrs(oModel)}	})	//"Atualizar cronograma financeiro/físico"
				EndIf

				If !lRemovCtb
					aAdd(aButtons,{STR0153,{|| CN300AtCont()}	})	//"Atualizar cronograma contábil"
				EndIf

				If (cTipRevisa $ DEF_REV_REAJU+'|'+DEF_REV_ABERT)
					aAdd(aButtons,{STR0154,{|oView| CN300REAJU(oModel,,oView)}	})	//"Executar reajuste"
				EndIf
			EndIf

			If !FWIsInCallStack('MATA161') .And. ( lIncluiCtr .Or. (lAlteraCtr .And. Empty(CN9->CN9_NUMCOT)) .Or. (!Empty(cTipRevisa) .AND. (cTipRevisa $ DEF_REV_ADITI+'|'+DEF_REV_ABERT+'|'+DEF_REV_RENOV)) ) .AND. !lC100VlAt
				If !lCtrVenda
					aAdd(aButtons,{STR0039,{|| CN300Solic()}			})//-- Importar solicitações de compra
					aAdd(aButtons,{STR0040,{|| CN300Solic(.T.)}			})//-- Importar sol. de compra pro item
					aAdd(aButtons,{STR0041,{|oView| CN300PedC(,,oView)} })//-- Copiar dados de pedidos de compra					
				EndIf
				aAdd(aButtons,{STR0261,{|x| CN300RatP(oModel,x)}		})	//-- Rateio Pré-Configurado
			EndIf

			If (cTipRevisa $ DEF_REV_ADITI+'|'+DEF_REV_REALI+'|'+DEF_REV_READE+'|'+DEF_REV_REINI+'|'+DEF_REV_RENOV+'|'+DEF_REV_ORCGS+'|'+DEF_REV_ABERT  );
			.Or. Empty(cTipRevisa)

				//Se a revisão tiver cronograma ou não estiver fazendo uma revisão
				If !lRemovCrg .Or. Empty(cTipRevisa)
					//Se o usuário pode visualizar Cronograma
					If lVisuCro .AND. !lC100VlAt
						aAdd(aButtons,{STR0042,{|| CN300PrCF()}		}) 			//-- Incluir cronograma financeiro/físico
						aAdd(aButtons,{STR0043,{|| CN300DelCrg()}	}) 		//-- Excluir cronograma financeiro/físico
					EndIf
				EndIf

				//Se a revisão tiver cronograma ou não estiver fazendo uma revisão
				If !lRemovCtb .Or. Empty(cTipRevisa)
					//Se o usuário pode visualizar Cronograma
					If lVisuCro .AND. !lC100VlAt
						aAdd(aButtons,{STR0044,{|| CN300PrcCC()}	}) //-- Incluir cronograma contábil"
						aAdd(aButtons,{STR0045,{|| CN300DelCtb()}	}) //-- Excluir cronograma contábil"
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return aButtons

/*/{Protheus.doc} CfgViewDef
	Configura as tabelas que devem ser exibidas pela ViewDef do CNTA300/301(Contratos)
@author philipe.pompeu
@since 18/04/2022
/*/
Static Function CfgViewDef()
	Local lShowAdt := .F.
	Local cChaveCNX := ""
	Local lShowCauc	:= .F.
	Local lShowCRet	:= .F.
	Local lShowDocs := .F.
	Local cChaveCNK := ""
	Local cVisuMed	:= ""
	Local lShowMeds	:= .F.
	Local lMultNat	:= SuperGetMv('MV_MULNATP',.F.,.F.) .Or. SuperGetMv('MV_MULNATR',.F.,.F.)
	Local lFldReaj	:= .F.
	
	If (IsIncByGCT() .Or. IsIncByGCP())
		SetShowView("CNK",.F.)
		SetShowView("CNX",.F.)
		SetShowView("CN8",.F.)
		SetShowView("CNT",.F.)
		SetShowView("CND",.F.)
	Else
		If !(lShowAdt := (lAdiant .Or. FwIsInCallStack("CN300CtrAdia")))
			CNX->(DbSetOrder(1))//CNX_FILIAL+CNX_CONTRA+CNX_NUMERO
			cChaveCNX	:= xFilial("CNX", CN9->CN9_FILCTR) + CN9->CN9_NUMERO
			lShowAdt	:= CNX->(DbSeek(cChaveCNX))
		EndIf
		SetShowView("CNX",lShowAdt)
		
		If (CN9->CN9_FLGCAU == "1")
			If (CN9->CN9_TPCAUC == "2")//Retencao
				lShowCRet := .T.
			Else
				lShowCauc := .T.
			EndIf
		EndIf
		SetShowView("CN8",lShowCauc)
		SetShowView("CNT",lShowCRet)
		
		CNK->(DbSetOrder(3))//CNK_FILIAL+CNK_CONTRA+CNK_TPDOC
		cChaveCNK := xFilial("CNK", CN9->CN9_FILCTR) + CN9->CN9_NUMERO
		lShowDocs := CNK->(DbSeek(cChaveCNK))
		SetShowView("CNK",lShowDocs)

		cVisuMed := SuperGetMV("MV_CTRMED",.F.,"1")
		lShowMeds:= (cVisuMed $ "12")
		SetShowView("CND",lShowMeds)

		If FWIsInCallStack("CN300Visua")
			lFldReaj := SuperGetMV('MV_CNRJMNT',.F.,.F.)
		EndIf
	EndIf

	SetShowView("MULTNAT", lMultNat)
	SetShowView("CXL", lFldReaj)
Return

/*/{Protheus.doc} SetShowView
	Seta em <_oViewTabs> se a tabela deve ser exibida ou não na tela de contratos
@author philipe.pompeu
@since 18/04/2022
@param cTabela, caractere, tabela a ser configurada
@param lMostra, lógico, se deve exibir ou não
/*/
Static Function SetShowView(cTabela,lMostra)
	if _oViewTabs == nil
		InitViewCfg()
	endif
	_oViewTabs[cTabela] := lMostra
Return

/*/{Protheus.doc} GetShowView
	Confere em <_oViewTabs> se a tabela deve ser exibida ou não na tela de contratos
@author philipe.pompeu
@since 18/04/2022
@param cTabela, caractere, view à ser verificada
@return lMostra, lógico, se deve exibir ou não
/*/
Static Function GetShowView(cTabela)
	Local lMostra := .T.

	If _oViewTabs:HasProperty(cTabela)
		lMostra := _oViewTabs[cTabela]
	EndIf

Return lMostra

/*/{Protheus.doc} InitViewCfg
	Inicializa a variável estática <_oViewTabs>
@author philipe.pompeu
@since 18/04/2022
/*/
Static Function InitViewCfg()
	Local aTabelas := { "CNK",;//Documentos
						"CNX",;//Adiantamentos
						"CN8",;//Caução
						"CNT",;//Caução retido
						"CXL",;//Reajuste
						"MULTNAT",;//Multiplas Naturezas
						"CND"} //Medicoes						
	If _oViewTabs == Nil
		_oViewTabs := JsonObject():New()
	EndIf
	aEval(aTabelas, {|x| _oViewTabs[x] := .T.})
Return

/*/{Protheus.doc} ProcCotSC
	Processa a cotação da solicitação de compra e verifica se reabre a cotação baseado no conteúdo do parâmetro MV_PCEXCOT
@author jose.souza2
@since 26/05/2022
@param oModel, objeto, carrega o modelo de dados
@param lCNB, lógico, informa se o contrato possui produto informado na CNB
@param cFilSC, caracter, informa a filial da SC
/*/
Static Function ProcCotSC(oModel,lCNB,cFilSC)
	Local nW := 0
	Local nK := 0
	Local lRestaura	:= SuperGetMV("MV_PCEXCOT", .T., "2") == "1"
	Local cChaveSC1 := ""
	Local cChavCot	:= ""
	Local oModelCN9	:= oModel:GetModel("CN9MASTER")
	Local lInclui	:= oModel:GetOperation() == MODEL_OPERATION_INSERT .And. Empty(cTipRevisa)
	Local cFilCTR   := IIF(lInclui, cFilAnt, oModelCN9:GetValue("CN9_FILCTR"))
	Local aRecSC8	:= {}
	Local aRecSCE   := {}
	Local aAreas	:= {SC8->(GetArea()), SCE->(GetArea()),SC1->(GetArea()), GetArea()}
	Default lCNB	:= .F.
	Default cFilSC	:= xFilial("SC1",cFilCTR)
	
	cChavCot := IIF(lCNB,cFilSC+CN9->CN9_NUMCOT+CNB->(CNB_PRODUT+CNB_IDENT),cFilSC+CN9->CN9_NUMCOT)
	//-- Retira quantidade atendida da solicitacao de compra
	SC1->(dbSetOrder(5))
	SC1->(dbSeek(cChavCot))
	cChaveSC1 := IIF(lCNB,"C1_FILIAL+C1_COTACAO+C1_PRODUTO+C1_IDENT","C1_FILIAL+C1_COTACAO")

	While !SC1->(EOF()) .And. If(!lRestaura,SC1->(dbSeek(cChavCot)),SC1->(&cChaveSC1) == cChavCot)
		RecLock("SC1",.F.)
		SC1->C1_FLAGGCT := ""
		If !lRestaura
			SC1->C1_COTACAO := ""
			SC1->C1_IDENT   := ""
		EndIf
		SC1->(MsUnlock())

		If lRestaura
			SC1->(dbSkip())
		EndIf
	EndDo

	//-- Reabre a cotação
	If lRestaura
		aRecSC8:= A300GetCot(IIF(lCNB,1,3)) //Obtem os RECNOs da SC8 que estão vinculados ao contrato

		For nK := 1 To Len(aRecSC8)
			SC8->(MsGoTo(aRecSC8[nK]))
			If SC8->C8_NUMCON == CN9->CN9_NUMERO //-- Se tiver documento gerado, busca a SCE correspondente e deleta
				aRecSCE := A300GetCot(2) //-- Obtem os RECNOs da SCE que estão vinculados ao contrato
				For nW := 1 To Len(aRecSCE)
					SCE->(DbGoTo(aRecSCE[nW]))
					RecLock("SCE", .F., .T.)
					SCE->(DbDelete()) 
					SCE->(MsUnlock())
				Next nW
			EndIf
			RecLock("SC8", .F., .T.)
			SC8->C8_NUMCON  := ""
			SC8->C8_NUMPED  := ""
			SC8->C8_ITEMPED := ""
			SC8->C8_MARKAUD := .F.
			SC8->(MsUnlock())
		Next nK

		//-- Zera os arrays auxiliares
		FwFreeArray(aRecSC8)
		FwFreeArray(aRecSCE)

	EndIf

	aEval(aAreas,{|x|RestArea(x)})
	FwFreeArray(aAreas)
	
Return

/*/{Protheus.doc} CtrChvPco
	Retorna <cChave> do lançamento PCO de acordo com o sequencial
@author philipe.pompeu
@since 17/08/2022
@param cCodLan, caractere, codigo do lancamento
@param cItem, caractere, sequencia dentro do lancamento
@return cChave, caractere, identificador do lancamento
/*/
Function CtrChvPco(cCodLan, cItem)
	Local cChave := ""

	If (cCodLan == '000354')		
		Do Case
			Case (cItem == '01' .Or. cItem == '03')//Inclusão de Planilha ou Revisão de Planilha - Total(CNA)
				cChave := xFilial('CNA')+FWFLDGET('CN9_NUMERO')+FWFLDGET('CN9_REVISA')+FWFLDGET('CNA_NUMERO')				
			Case (cItem == '02' .Or. cItem == '04')//Inclusão de Planilha ou Revisão de Planilha - Itens(CNB)
				cChave := xFilial('CNB')+FWFLDGET('CN9_NUMERO')+FWFLDGET('CN9_REVISA')+FWFLDGET('CNA_NUMERO')+FWFLDGET('CNB_ITEM')
			Case (cItem == '09' .Or. cItem == '10')//Inclusão de Planilha ou Revisão de Planilha - Rateios(CNZ)				
				cChave := xFilial('CNZ')+FWFLDGET('CN9_NUMERO')+FWFLDGET('CN9_REVISA')+FWFLDGET('CNA_NUMERO')+FWFLDGET('CNB_ITEM')+FWFLDGET('CNZ_ITEM')
		End Case
	EndIf
Return cChave

/*/{Protheus.doc} LancPcoCNZ
	Percorre os rateios da CNB corrente e realiza os lancamentos PCO
@author philipe.pompeu
@since 17/08/2022
@param cSeqLanc, caractere, sequencia do lancamento
@param lExclui, logico, se é um processo de exclusão
@return Nil, nulo, sem retorno
/*/
Static Function LancPcoCNZ(cSeqLanc, lExclui)
	Local aAreas	:= { CNZ->(GetArea()), GetArea() }
	Local cChaveCNZ	:= ""
	
	CNZ->(DbSetOrder(1))//CNZ_FILIAL+CNZ_CONTRA+CNZ_REVISA+CNZ_CODPLA+CNZ_ITCONT+CNZ_ITEM
	cChaveCNZ := xFilial("CNZ") + CNB->(CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM)
	If CNZ->(DbSeek(cChaveCNZ))
		While CNZ->(!Eof() .And. CNZ_FILIAL+CNZ_CONTRA+CNZ_REVISA+CNZ_CODPLA+CNZ_ITCONT == cChaveCNZ)//Percorre o rateio dos itens da planilha			
			
			PcoDetLan("000354", cSeqLanc, "CNTA300", lExclui)
			
			CNZ->(DbSkip())	
		EndDo		
	EndIf

	aEval(aAreas,{|x|RestArea(x)})
	FwFreeArray(aAreas)
Return

/*/{Protheus.doc} VldPcoCNZ
	Realiza a validação dos lançamentos PCO dos rateios(CNZ) da CNB corrente
@author philipe.pompeu
@since 17/08/2022
@param oModelCNZ, objeto, instância de FwFormGrid de CNZDETAIL
@param cSeqLanc, caractere, sequência do lançamento
@return lResult, lógico, se há saldo PCO p/ os rateios
/*/
Static Function VldPcoCNZ(oModelCNZ, cSeqLanc)
	Local lResult	:= .T.
	Local nX 		:= 0
	Local oModel	:= oModelCNZ:GetModel()
	
	for nX := 1 to oModelCNZ:Length() //Não precisa de FwRestRows pois é realizado na função chamadora
		oModelCNZ:GoLine(nX)
		If !(oModelCNZ:IsDeleted()) .And. oModelCNZ:GetValue("CNZ_PERC") > 0
			If !(lResult := A300PCOVld(oModel,"000354", cSeqLanc,"CNTA300",.T.))
				Exit
			EndIf
		EndIf
	next nX
Return lResult

/*/{Protheus.doc} VldGrpAprov
	Validação do campo CN9_GRPAPR e CND_APROV referente ao grupo de aprovação informado.
@author jose.souza2/philipe.pompeu
@since 06/09/2022
@return lResult, lógico, retorna se o valor informado é válido
/*/
Function VldGrpAprov(cGrupo)
	Local lResult	:= .T.
	Local aAreas	:= {SAL->(GetArea()), GetArea()}
	Local cSeek		:= ""
	Default cGrupo	:= FwFldGet("CN9_GRPAPR")

	If !Empty(cGrupo)
		SAL->(DbSetOrder(1))//AL_FILIAL+AL_COD+AL_ITEM
		cSeek := xFilial("SAL") + cGrupo
		If (lResult := SAL->(dbSeek(xFilial("SAL") + cGrupo)))
			If (SAL->( ColumnPos('AL_MSBLQL') ) > 0)
				lResult := .F.				
				While SAL->(!Eof() .And. AL_FILIAL+AL_COD == cSeek)
					If (lResult := (SAL->AL_MSBLQL != "1"))
						Exit
					EndIf
					SAL->(DbSkip())
				EndDo
				If !lResult
					Help(" ",1,"REGBLOQ")
				EndIf
			EndIf
		Else
			Help(" ", 1, "REGNOIS",,STR0324,2)//Grupo inexistente, informe um válido.
		EndIf		
	EndIf

	aEval(aAreas, {|x| RestArea(x) })
	FwFreeArray(aAreas)
Return lResult

/*/{Protheus.doc} CNTGestVld
	Valid do campo CN9_GESTC
@author jose.souza2
@since 10/10/2022
@param cValue,Caracter, Valor informado no campo CN9_GESTC
@return lRet
*/
Function CNTGestVld(cValue)
	Local lRet	:= .T.

	lRet:= Cn240VldGr("USR",cValue) //Verifica se o usuário existe e se pode ser utilizado.

Return lRet

/*/{Protheus.doc} IsIncByGCT
	Verifica se é uma inclusão de contrato via CNTA300 com interface gráfica(view)
@author philipe.pompeu
@since 30/11/2022
@return lInclusao, lógico, é uma inclusão via CNTA300
/*/
Static Function IsIncByGCT()
	Local lInclusao := (FwIsInCallStack("CN300InCOM") .Or. FwIsInCallStack("CN300InVEN"))
Return lInclusao

/*/{Protheus.doc} IsIncByGCP
	Verifica se é uma inclusão de contrato oriunda do GCP
@author philipe.pompeu
@since 30/11/2022
@return lIncViaGCP, lógico, se é uma inclusão oriunda do SIGAGCP
/*/
Static Function IsIncByGCP()
	Local lIncViaGCP:= (FwIsInCallStack("A200GerCtr") .Or.;	//Geração pelo Edital(GCPA200)
						FwIsInCallStack("GCP200Ctrs"))		//Geração pela Ata de Registro de Preço(GCPA300)
Return lIncViaGCP

/*/{Protheus.doc} DeveVldCNF
	Verifica se deve validar a parcela(CNF), condições p/ validação:
		-não tenha sofrido medições parciais
		-caso ela tenha sido inserida na revisão atual
		-tenha tido seu valor alterado
@author philipe.pompeu
@since 30/11/2022
@param nRecCNF, numerico, identificador da parcela atual
@return lValidar, lógico, se deve realizar a validação
/*/
Static Function DeveVldCNF(nRecCNF)
	Local aAreas := {CNF->(GetArea()), GetArea()}
	Local lValidar := .F.
	Local nValorAtu:= 0
	Local cChave := ""

	If (nRecCNF > 0)
		CNF->(DbGoTo(nRecCNF))
		If (CNF->CNF_VLREAL == 0)//Só valida se não houve medições parciais
			nValorAtu := CNF->CNF_VLPREV
			
			CNF->(DbSetOrder(3))//CNF_FILIAL+CNF_CONTRA+CNF_REVISA+CNF_NUMERO+CNF_PARCEL
			cChave := CNF->(CNF_FILIAL+CNF_CONTRA+CnRevAnt(.F.,CNF_REVISA)+CNF_NUMERO+CNF_PARCEL)			
			
			If CNF->(DbSeek(cChave))
				lValidar := (CNF->CNF_VLPREV != nValorAtu) //Se houve mudança de valor, deve validar
			Else
				lValidar := .T. //Deve validar se não encontrar(nova parcela)
			EndIf
		EndIf
	EndIf

	aEval(aAreas, {|x| RestArea(x) })
	FwFreeArray(aAreas)
Return lValidar

/*/{Protheus.doc} CN300Amort
	Realiza o cálculo da amortização linear do cronograma financeiro
@author philipe.pompeu
@since 31/03/2023
@param oModel, objeto, instância de MPFormModel do CNTA300/301
@return Nil, nulo
/*/
Function CN300Amort(oModel)
	Local aSaveLines:= FWSaveRows()
	Local nAmortiza := 0
	Local oModelCNF := oModel:GetModel("CNFDETAIL")
	Local nTotalVlPr:= oModel:GetValue("CALC_CNF", "CNF_TVPRES")
	Local nQtdParcel:= 0	
	Local nX 		:= 0

	For nX := oModelCNF:Length() To 1 Step - 1
		oModelCNF:GoLine(nX)
		If !oModelCNF:IsDeleted()
			If oModelCNF:GetValue('CNF_VLREAL') == 0
				nQtdParcel++
			Else
				nTotalVlPr -= oModelCNF:GetValue('CNF_AMRTZA')
			EndIf
		EndIf
	Next nX

	If (nTotalVlPr > 0 .And. nQtdParcel > 0)
		nAmortiza := (nTotalVlPr / nQtdParcel)
		nAmortiza := Round(nAmortiza, GetSx3Cache("CNF_VLREAL", "X3_DECIMAL"))

		For nX := oModelCNF:Length() To 1 Step - 1
			oModelCNF:GoLine(nX)
			If !oModelCNF:IsDeleted() .And. oModelCNF:GetValue('CNF_VLREAL') == 0
				oModelCNF:LoadValue("CNF_AMRTZA", nAmortiza)
			EndIf
		Next nX		
	EndIf

	FWRestRows(aSaveLines)
	FWFreeArray(aSaveLines)
Return

/*/{Protheus.doc} LoadMaxMD
	Retorna os dados que devem ser carregados no submodelo das medições(CNDDETAIL) 
	limitados a quantidade definida no parâmetro MV_QTDEXMD
@author jose.souza2
@since 03/04/2023
@aParam oSubCNDetail,objeto, instância de FwFormGrid do submodelo CNDDETAIL
@return aRet, array, registros que devem ser carregados em <oSubModel>
/*/
Static Function LoadMaxMD(oSubCNDetail as Object)
	
	Local aArea			:= GetArea()
	Local aRet			:= {}
	Local cQuery		:= ""
	Local lCnRevMd		:= SuperGetMV("MV_CNREVMD",.F.,.T.)
	Local oModel		:= oSubCNDetail:GetModel()
	Local oModelCNA		:= oModel:GetModel("CNADETAIL")
	Local lExibPorCtr 	:= SuperGetMV("MV_CTRMED",.F.,"1") == "1"
	Local nQuantMed		:= SuperGetMv("MV_QTDEXMD",.F., 100)
	Local cCamposQry	:= ""
	Local cFields		:= ""
	Local cJoin			:= ""
	Local cSubQuery		:= ""
	Local cWhereAux		:= ""

	cAliasQry	:= GetNextAlias()

	oModelCNA	:= oModel:GetModel("CNADETAIL")
	cNumPla		:= oModelCNA:GetValue('CNA_NUMERO')

	cCamposQry	:= "CND_FILIAL,CND_CONTRA, CND_REVISA,CND_NUMMED, CND_VLTOT, CND_DTINIC, CND_DTFIM, CND_DTVENC, CND_COMPET, CND_VLPREV,CND_VLMULT, CND_VLBONI, CND_VLMPED, CND_VLBPED, CND_REVGER"
	
	If lExibPorCtr
		cFields		:= " LINHA, RECNO, "+cCamposQry+" "
		cSubQuery	:=  " LINHA, CND.R_E_C_N_O_ RECNO,"+cCamposQry+" "
	Else
		cFields		:= " LINHA, CND_NUMERO, RECNO, "+cCamposQry+" "
		cSubQuery	:= " LINHA, ISNULL(CXN_NUMPLA, CND_NUMERO) CND_NUMERO, CND.R_E_C_N_O_ RECNO, "+cCamposQry+" "

		cJoin	:= " LEFT JOIN " + RetSQLName("CXN") + " CXN"
		cJoin 	+= " ON CND_FILIAL = CXN_FILIAL AND"
		cJoin 	+= " CND_CONTRA = CXN_CONTRA AND"
		cJoin 	+= " CND_REVISA = CXN_REVISA AND"
		cJoin 	+= " CND_NUMMED = CXN_NUMMED AND"
		cJoin 	+= " CXN.D_E_L_E_T_ = ' ' "
		
		cWhereAux	:= " ISNULL(CXN_NUMPLA, CND_NUMERO) = '"+ cNumPla +"' AND"
		cWhereAux	+= " ISNULL(CXN_CHECK, 'T') = 'T'"
	EndIf

	cQuery	:= "SELECT " + cFields  + " FROM ( "
	cQuery	+= "SELECT ROW_NUMBER() OVER "
	cQuery	+= "(ORDER BY CND.R_E_C_N_O_ DESC) AS " + cSubQuery 
	cQuery	+= " FROM " + RetSQLName("CND") + " CND"
	cQuery	+= cJoin
	cQuery	+= " WHERE CND_FILCTR = '" + oModel:GetValue('CN9MASTER', 'CN9_FILCTR')+ "'"
	cQuery	+= " AND CND_CONTRA = ? "
	If lCnRevMd
		cQuery	+= " AND CND_REVISA = '" + oModel:GetValue('CN9MASTER', 'CN9_REVISA') + "'"	
	EndIF
	cQuery	+= " AND CND.D_E_L_E_T_ = ' '"
	If !Empty(cWhereAux)
		cQuery 	+= " AND " +cWhereAux 
	EndIf
	cQuery	+= " ) CND WHERE LINHA BETWEEN 1 AND "+ Alltrim(str(nQuantMed)) +" "
	
	cQuery	:= ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry2(,,cQuery,{oModel:GetValue('CN9MASTER', 'CN9_NUMERO')}),cAliasQry,.F.,.T.)

	aRet	:= FWLoadByAlias(oSubCNDetail, cAliasQry, 'CND')

 	(cAliasQry)-> (dbCloseArea())

 	RestArea(aArea)

Return aRet
