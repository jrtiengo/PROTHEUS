#include "CNTA300R.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
//#INCLUDE "GCTXDEF.CH"
#DEFINE STR0001 "STR0001"
#DEFINE STR0002 "STR0002"
#DEFINE STR0003 "STR0003"
#DEFINE STR0004 "STR0004"
#DEFINE STR0005 "STR0005"
#DEFINE STR0006 "STR0006"
#DEFINE STR0007 "STR0007"
#DEFINE STR0008 "STR0008"
#DEFINE STR0009 "STR0009"
#DEFINE STR0010 "STR0010"
#DEFINE STR0011 "STR0011"
#DEFINE STR0012 "STR0012"
#DEFINE STR0013 "STR0013"
#DEFINE STR0014 "STR0014"
#DEFINE STR0015 "STR0015"
#DEFINE STR0016 "STR0016"
#DEFINE STR0017 "STR0017"
#DEFINE STR0018 "STR0018"
#DEFINE STR0019 "STR0019"
#DEFINE STR0020 "STR0020"
#DEFINE STR0021 "STR0021"
#DEFINE STR0022 "STR0022"
#DEFINE STR0023 "STR0023"
#DEFINE STR0024 "STR0024"
#DEFINE STR0025 "STR0025"
#DEFINE STR0026 "STR0026"
#DEFINE STR0027 "STR0027"
#DEFINE STR0028 "STR0028"
#DEFINE STR0029 "STR0029"
#DEFINE STR0030 "STR0030"
#DEFINE STR0031 "STR0031"
#DEFINE STR0032 "STR0032"
#DEFINE STR0033 "STR0033"
#DEFINE STR0034 "STR0034"
#DEFINE STR0035 "STR0035"
#DEFINE STR0036 "STR0036"
#DEFINE STR0037 "STR0037"
#DEFINE STR0038 "STR0038"
#DEFINE STR0039 "STR0039"
#DEFINE STR0040 "STR0040"
#DEFINE STR0041 "STR0041"
#DEFINE STR0042 "STR0042"
#DEFINE STR0043 "STR0043"
#DEFINE STR0044 "STR0044"
#DEFINE STR0045 "STR0045"
#DEFINE STR0046 "STR0046"
#DEFINE STR0047 "STR0047"
#DEFINE STR0048 "STR0048"

//Situacoes de contrato
#DEFINE DEF_SCANC "01"//Cancelado
#DEFINE DEF_SELAB "02"//Em Elaboracao
#DEFINE DEF_SEMIT "03"//Emitido
#DEFINE DEF_SAPRO "04"//Em Aprovacao
#DEFINE DEF_SVIGE "05"//Vigente
#DEFINE DEF_SPARA "06"//Paralisado
#DEFINE DEF_SSPAR "07"//Sol Fina.
#DEFINE DEF_SFINA "08"//Finalizado
#DEFINE DEF_SREVS "09"//Revisao
#DEFINE DEF_SREVD "10"//Revisado

//Transações
#DEFINE DEF_TRAINC "011"//Inclusao de cronogramas
#DEFINE DEF_TRAEDT "012"//Edicao de cronogramas
#DEFINE DEF_TRAEXC "013"//Exclusao de cronogramas
#DEFINE DEF_TRAVIS "033"//Visualizacao de cronogramas

//Tipos de Revisao
#DEFINE DEF_REV_ADITI   "L"	   //-- Aditivo
#DEFINE DEF_REV_REAJU 	"L"     //-- Reajuste
#DEFINE DEF_REV_REALI 	"L"     //-- Realinhamento
#DEFINE DEF_REV_READE 	"L"     //-- Readequação
#DEFINE DEF_REV_PARAL 	"L"     //-- Paralisação
#DEFINE DEF_REV_REINI 	"L"     //-- Reinício
#DEFINE DEF_REV_CLAUS 	"L"     //-- Alteração de Cláusulas
#DEFINE DEF_REV_CONTA 	"L"     //-- Contábil
#DEFINE DEF_REV_INDIC 	"L"     //-- Índice
#DEFINE DEF_REV_FORCL 	"L"     //-- Troca de Fonecedor
#DEFINE DEF_REV_GRAPR 	"L"     //-- Grupos de Aprovação
#DEFINE DEF_REV_RENOV 	"L"     //-- Renovação
#DEFINE DEF_REV_MULBON  "L"     //-- Multa/Bonificação
#DEFINE DEF_REV_ABERT 	"G"     //-- Aberta
#DEFINE DEF_REV_ORCGS   "L"     
#DEFINE DEF_REV_CAUCA   "L"     //-- Caução


/*
#DEFINE "6"
#DEFINE "7"
#DEFINE "8"
#DEFINE "9"
#DEFINE "A"
#DEFINE "B"
#DEFINE "C"
#DEFINE "D"
#DEFINE "F"
#DEFINE "3"
#DEFINE "4"
*/

Static __aUsrCpo 	:= Nil
Static _lA300RVUN	:= ExistBlock("A300RVUN")
Static _lA300RDVI	:= ExistBlock("A300RDVI")
Static _lA300BREAK	:= ExistBlock("A300BREAK")
Static _lVPresFIN	:= Nil
Static _lVPresCTB	:= Nil

//------------------------------------------------------------------
/*/{Protheus.doc} CNTA300R
Programa responsável pela revisão e aprovação do contrato.
@since 18/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} A300IniRev()
Inicializaçao do processo de revisão
@author guilherme.pimentel
@since 21/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static function A300IniRev(oModel,lBlock)
Local lRet		:= .T.
Local aModels 	:= MTGetAllMd({"CALC_CNS","CALC_CNF"})
Local nX 		:= 0
Local oModelCN9 := oModel:GetModel('CN9MASTER')
Local oModelCNA := oModel:GetModel('CNADETAIL')
Local oModelCNB := oModel:GetModel('CNBDETAIL')
Local aArea 	:= GetArea()
Local lAlterRev	:= oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. !Empty(A300GTpRev()) .And. !IsInCallStack('GCPXGerCt')
Local oStruCNC 	:= oModel:GetModel("CNCDETAIL"):GetStruct()
Local lFusao   	:= .F.

Default lBlock := .F.

A300CLnCNF()
For nX := 1 To oModel:GetModel('CNADETAIL'):Length()
	oModel:GetModel('CNADETAIL'):GoLine(nX)
	A300SLnCNF(oModel:GetModel('CNFDETAIL'):Length())
Next nX

//Não permite gravar modelos que não tem revisao
cn300ModQr(oModel)
oModelCN9:LoadValue('CN9_NUMERO',CN9->CN9_NUMERO)

If !lAlterRev
	oModelCN9:LoadValue('CN9_REVISA',Soma1(CN9->CN9_REVISA))	//Atualização da revisão
EndIf

oModelCN9:LoadValue('CN9_DTREV',dDatabase)					//Atualização da Data da Revisão
oModelCN9:LoadValue('CN9_SITUAC','09')						//Atualização da Sitaução "Em Revisão"
oModelCN9:LoadValue('CN9_DREFRJ',CTOD(''))
oModelCN9:LoadValue('CN9_DTREAJ',CTOD(''))
If !A300GRevis() .And. !lAlterRev // Somente Limpa o Campo Caso seja a primeira execução ou não for alteração da revisão
	oModelCN9:LoadValue('CN9_TIPREV','')
	//Remoção da justificativa
	oModelCN9:LoadValue('CN9_JUSTIF','')
	oModelCN9:LoadValue('CN9_CODJUS','')
EndIf

If !lAlterRev
	// Salva valores originais da tabela cnb
	A300CNBOri(oModel)
EndIf

//Bloqueio total dos modelos
If lBlock
	MtBCMod(oModel,aModels,{||.T.})
Else
	MtBCMod(oModel,aModels,{||.F.})
EndIf

LibCpTdRV(oModel)// Liberar Para Todos os tipos de revisao

//-- Posiciona no edital para ver se esta definido o campo de fusão
CO1->(dbSetOrder(1))
If CO1->(dbSeek(xFilial("CO1")+CN9->(CN9_CODED+CN9_NUMPR)))
	If CO1->CO1_FUSAO = "1"
		lFusao   := .T.
	EndIf
EndIf

// Habilita a alteração do fornecedor quando o edital permitir fusão, cisão e incorporação de empresas
If  lFusao .And. (A300GTpRev() == DEF_REV_FORCL .Or. A300GTpRev() == DEF_REV_ABERT)
	oStruCNC:SetProperty("CNC_CODIGO"	,MODEL_FIELD_WHEN,{||.T.})
	oStruCNC:SetProperty("CNC_LOJA"		,MODEL_FIELD_WHEN,{||.T.})
	oStruCNC:SetProperty("CNC_NOME"		,MODEL_FIELD_WHEN,{||.T.})
EndIf

If A300GTpRev() == DEF_REV_FORCL
	CNTA300BlMd(oModelCNA,,.T.)
	CNTA300BlMd(oModelCNB,.T.)
EndIf

A300SUsrBt(.F.)
RestArea(aArea)

If lAlterRev
	A300Revisa(oModel, A300GTpRev())
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300Revisa()
Função responsável pelo controle das revisões.

@author guilherme.pimentel
@since 21/01/2014
@version 1.0

|-------------------------------------------------------------------------------	|
|Ex: Para cada revisão deverá ser liberado determinados campos de alguns modelos	|
|Para isso iremos liberar o campo na revisão desejada, segue exemplo				|
|																							|
|  ***Não é necessário liberar os campos de justificativa e tipo de revisão***		|
|																							|
|Local oStruCNB := oModel:GetModel("CNBDETAIL"):GetStruct()							|
|If A300GTpRev() == DEF_REV_ADITI														|
|	oStruCNB:SetProperty("CNB_PRODUT",MODEL_FIELD_WHEN,{||.T.})						|
|	oStruCNB:SetProperty("CNB_DESCRI",MODEL_FIELD_WHEN,{||.T.})						|
|EndIf																						|
|																							|
|Assim desbloquearemos somente o determinado campo da estrutura						|
|-------------------------------------------------------------------------------	|
/*/
//-------------------------------------------------------------------
Static function A300Revisa(oModel, cTpRev)
Local oStruCN9 	:= oModel:GetModel('CN9MASTER'):GetStruct()
Local oModelCN9	:= oModel:GetModel('CN9MASTER')
Local aCampos  	:= {}
Local aUsrCpo	:= {}
Local aModels  	:= MtGetAllMd({"CALC_CNS","CALC_CNF"})
Local aMdDelLine:= MtGetAllMd({"CN9MASTER","CALC_CNS","CALC_CNF"})
Local lFixo	   	:= Cn300RetSt("FIXO")
Local lFusao   	:= .F.
Local cTipRev	:= 	A300GTpRev()
Local nX		:= 0
Local cCodTpRev	:= oModel:GetValue('CN9MASTER','CN9_TIPREV')
Local lVlPreFin := ValPresFin()

//Bloqueio total dos modelos
MtBCMod(oModel,aModels,{||.F.})

//Bloqueio os modelos para não permitir deletar as linhas.
If cTipRev <> DEF_REV_ADITI .And. cTipRev <> DEF_REV_REAJU .And. cTipRev <> DEF_REV_REALI ;
 	.And. cTipRev <> DEF_REV_READE .And. cTipRev <> DEF_REV_RENOV .And. cTipRev <> DEF_REV_ORCGS .And. cTipRev <> DEF_REV_ABERT // .And.  cTipRev <> DEF_REV_FORCL
	For nX := 1 to Len(aMdDelLine)
		CNTA300BlMd(oModel:GetModel(aMdDelLine[nX]),.T.)
	Next nX
EndIf

LibCpTdRV(oModel)// Liberar Para Todos os tipos de revisao

//-- Ponto de Entrada para liberação de campos do usuário na revisão do contrato.
If ExistBlock("A300USRF")
	aUsrCpo := ExecBlock("A300USRF",.F.,.F.,{cTipRev})
	A300CpoUsr(@aUsrCpo)
Else //- Caso não exista ponto de entrada, todos campos do usuario devem ser liberados.
	If __aUsrCpo == Nil
		__aUsrCpo := CnGetUsrCp( oModel )
	EndIf
	aUsrCpo := __aUsrCpo
EndIf

If Len(aUsrCpo) > 0
	MtBCMod(oModel,aUsrCpo,{||.T.},'2')
EndIf

//-- Posiciona no edital para ver se esta definido o campo de fusão
CO1->(dbSetOrder(1))
If CO1->(dbSeek(xFilial("CO1")+CN9->(CN9_CODED+CN9_NUMPR)))
	If CO1->CO1_FUSAO = "1"
		lFusao   := .T.
	EndIf
EndIf

If cTipRev == DEF_REV_ADITI
	cn300EspVld(oModel,cTpRev)
	CN300VdArr()
	A300RevCtb(oModel)

	// Partes Envolvidas do Contrato
	aCampos := {}
	aAdd(aCampos,{'CXIDETAIL',{'CXI_TIPO','CXI_CODCLI','CXI_LOJACL','CXI_NOMCLI','CXI_FILRES','CXI_DESFIL','CXI_PERRAT'}})
	MtBCMod(oModel,aCampos,{||.T.},'2')
	CNLibVend(oModel)

ElseIf cTipRev == DEF_REV_REAJU

	If !A300GUsrBt() // Reajuste ja executado.

		If	A300ApReRet(cCodTpRev)
			MtBCMod(oModel,{ {"CN9MASTER",{"CN9_DTREAJ","CN9_DREFRJ","CN9_DTRRDE","CN9_DTRRAT"}} },{||.T.},'2')
			oModel:getModel("CN9MASTER"):ClearField('CN9_DTRRDE')
			oModel:getModel("CN9MASTER"):ClearField('CN9_DTRRAT')
		Else
		    MtBCMod(oModel,{ {"CN9MASTER",{"CN9_DTREAJ","CN9_DREFRJ"}} },{||.T.},'2')
		EndIf

		If !IsInCallStack('CN300REAJU')
			oModel:getModel("CN9MASTER"):LoadValue('CN9_DTREAJ',dDataBase)
		EndIf

	EndIf
	
	If(FwIsInCallStack("CN310Inc"))
		aAdd(aCampos,{'CNADETAIL',{'CNA_INDICE','CNA_PERI','CNA_UNPERI','CNA_MODORJ','CNA_PRORAT', 'CNA_PROXRJ','CNA_DTREAJ'}})
		MtBCMod(oModel,aCampos,{||.T.},'2')
	EndIf
	A300RevCtb(oModel)
	CNLibVend(oModel)

ElseIf cTipRev == DEF_REV_REALI
	aCampos := {}
	If lFixo
		If	A300ApReRet(cCodTpRev)
			aAdd(aCampos,{'CN9MASTER',{'CN9_CONDPG','CN9_DESCPG','CN9_ARRAST','CN9_REDVAL', 'CN9_QTDPAR','CN9_TPCRON', 'CN9_CPARCA', 'CN9_CPARCV','CN9_DREFRJ','CN9_DTRRDE','CN9_DTRRAT'}})
			oModel:getModel("CN9MASTER"):ClearField('CN9_DTRRDE')
			oModel:getModel("CN9MASTER"):ClearField('CN9_DTRRAT')
		Else
			aAdd(aCampos,{'CN9MASTER',{'CN9_CONDPG','CN9_DESCPG','CN9_ARRAST','CN9_REDVAL', 'CN9_QTDPAR','CN9_TPCRON', 'CN9_CPARCA', 'CN9_CPARCV','CN9_DREFRJ'}})
		EndIf

		If lVlPreFin
			aAdd(aCampos[1,2] ,	'CN9_TJUFIN')
		EndIf		

		aAdd(aCampos,{'CNBDETAIL',{'CNB_REALI','CNB_DTREAL','CNB_VLUNIT','CNB_VLTOT','CNB_VLTOTR','CNB_DESC','CNB_VLDESC','CNB_CONTA','CNB_ITEMCT','CNB_CC','CNB_CLVL' }})
		aAdd(aCampos,{'CNFDETAIL',{'CNF_COMPET','CNF_VLPREV','CNF_DTVENC','CNF_PRUMED','CNF_TXMOED','CNF_CONDPG', 'CNF_SALDO'}})
		aAdd(aCampos,{'CNTDETAIL',{'CNT_VLRET' }})
		aAdd(aCampos,{'CNZDETAIL',{'CNZ_ITEM','CNZ_PERC','CNZ_CC','CNZ_CONTA','CNZ_ITEMCT','CNZ_CLVL'}})
		MtBCMod(oModel,aCampos,{||.T.},'2')
		CN300VdCrf(oModel)
		CN300VdArr()
	Else
		aAdd(aCampos,{'CN9MASTER',{'CN9_CONDPG','CN9_DESCPG'}})

		If Cn300RetSt("PREVFINANC")
			aAdd(aCampos,{'CNADETAIL',{'CNA_VLTOT'}})
		EndIf

		If Cn300RetSt("SEMIPROD")
			aAdd(aCampos,{'CNBDETAIL',{'CNB_REALI','CNB_DTREAL','CNB_VLUNIT','CNB_VLTOT','CNB_VLTOTR','CNB_DESC','CNB_VLDESC','CNB_CONTA','CNB_ITEMCT','CNB_CC','CNB_CLVL' }})
			aAdd(aCampos,{'CNZDETAIL',{'CNZ_ITEM','CNZ_PERC','CNZ_CC','CNZ_CONTA','CNZ_ITEMCT','CNZ_CLVL'}})
		ElseIf Cn300RetSt('SEMIAGRUP')
			aAdd(aCampos,{'CXMDETAIL',{'CXM_VLMAX','CXM_CC'}})
		EndIf
		
		MtBCMod(oModel,aCampos,{||.T.},'2')
	EndIf

	A300RevCtb(oModel)
	CN300CNZVD(oModel)
	CNTA300BlMd(oModel:GetModel("CNBDETAIL"),.T.,.T.)
	CNLibVend(oModel)

ElseIf cTipRev == DEF_REV_READE
	aCampos := {}
    aAdd(aCampos,{'CN9MASTER',{'CN9_ARRAST','CN9_REDVAL'}})
	If lVlPreFin
		aAdd(aCampos[1,2] ,	'CN9_TJUFIN')
	EndIf

	aAdd(aCampos,{'CNBDETAIL',{'CNB_VLTOT','CNB_DESC','CNB_VLDESC','CNB_QTREAD','CNB_SLDMED','CNB_SLDREC'}})
	If !CN300RetSt('SEMIPROD') .And. !CN300RetSt('SERVIÇO')
		aAdd(aCampos,{'CNBDETAIL',{'CNB_QUANT'}})
	EndIf
	MtBCMod(oModel,aCampos,{||.T.},'2')
	CN300VdCrf(oModel)
	CN300CNZVD(oModel)
	CNTA300BlMd(oModel:GetModel("CNBDETAIL"),.T.,.T.)	
ElseIf cTipRev == DEF_REV_PARAL
	aCampos := {}
	aAdd(aCampos,{'CN9MASTER',{'CN9_MOTPAR','CN9_DESMTP','CN9_DTFIMP'}})
	MtBCMod(oModel,aCampos,{||.T.},'2')
	oStruCN9:SetProperty("CN9_ARRAST",MODEL_FIELD_WHEN,{||.F.})	
ElseIf cTipRev == DEF_REV_REINI
	oModel:GetModel("CN9MASTER"):LoadValue('CN9_DTREIN',dDataBase)
	aCampos := {}
	aAdd(aCampos,{'CN9MASTER',{'CN9_ARRAST','CN9_REDVAL','CN9_QTDPAR', 'CN9_TPCRON'}})
	If lVlPreFin
		aAdd(aCampos[1,2] ,	'CN9_TJUFIN')
	EndIf

	aAdd(aCampos,{'CNFDETAIL',{'CNF_COMPET','CNF_VLPREV','CNF_SALDO', 'CNF_DTVENC', 'CNF_PRUMED', 'CNF_TXMOED', 'CNF_CONDPG'}})

	MtBCMod(oModel,aCampos,{||.T.},'2')		
	CN300VdCrf(oModel)
	A300RevCtb(oModel)

ElseIf cTipRev == DEF_REV_CLAUS		//Revisão de cláusulas
	oStruCN9:SetProperty('CN9_ALTCLA',MODEL_FIELD_WHEN,{||.T.})
	oStruCN9:SetProperty('CN9_OBJCTO',MODEL_FIELD_WHEN,{||.T.})

ElseIf cTipRev == DEF_REV_CONTA
	CNLibConta(oModel)

ElseIf cTipRev == DEF_REV_INDIC
	aCampos := {}
	aAdd(aCampos,{'CN9MASTER',{'CN9_INDICE','CN9_INDDES','CN9_PERI','CN9_UNPERI','CN9_MODORJ','CN9_PRORAT'}})
	aAdd(aCampos,{'CNADETAIL',{'CNA_INDICE','CNA_PERI','CNA_UNPERI','CNA_MODORJ','CNA_PRORAT', 'CNA_PROXRJ'}})
	aAdd(aCampos,{'CNBDETAIL',{'CNB_INDICE'}})
	MtBCMod(oModel,aCampos,{||.T.},'2')
	CNTA300BlMd(oModel:GetModel("CNADETAIL"),.T.,.T.)
	CNTA300BlMd(oModel:GetModel("CNBDETAIL"),.T.,.T.)

ElseIf cTipRev == DEF_REV_FORCL

	CNLibForCl(oModel,lFusao)
	CNLibVend(oModel)
	
ElseIf cTipRev == DEF_REV_GRAPR	 //= Revisão de grupo de aprovador
	aCampos := {}
	aAdd(aCampos,{'CN9MASTER',{'CN9_GRPAPR','CN9_APROV'}})
	MtBCMod(oModel,aCampos,{||.T.},'2')

ElseIf cTipRev == DEF_REV_RENOV	//= Renovação
	Cn300EspVld(oModel,cTpRev) //Quando for tipo renovação a especie será 5-Todos caso avalie a tabela CN0 (CN0_ESPEC)
	Cn300VdArr()
	A300RevCtb(oModel)
	CNLibVend(oModel)

	// Partes Envolvidas do Contrato
	aCampos := {}
	aAdd(aCampos,{'CXIDETAIL',{'CXI_TIPO','CXI_CODCLI','CXI_LOJACL','CXI_NOMCLI','CXI_FILRES','CXI_DESFIL','CXI_PERRAT'}})
	aAdd(aCampos,{'CNBDETAIL',{'CNB_PRODSV'}})	
	MtBCMod(oModel,aCampos,{||.T.},'2')

	//- Agrupadores
	If Cn300RetSt('SEMIAGRUP')
		aAdd(aCampos,{'CXMDETAIL',{'CXM_AGRGRP','CXM_AGRCAT','CXM_VLMAX'}})
		MtBCMod(oModel,aCampos,{||.T.},'2')
	Endif

ElseIf cTipRev == DEF_REV_MULBON // Multa e Bonificação
	aCampos := {}
	aAdd(aCampos,{'CNHDETAIL',{'CNH_CODIGO','CNH_DESCRI','CNH_AVALIA'}})
	MtBCMod(oModel,aCampos,{||.T.},'2')
	CNTA300BlMd(oModel:GetModel("CNHDETAIL"),.F.,.F.)

ElseIf cTipRev == DEF_REV_ORCGS //= Orçamento de Serviço GS
	TecBRevCTR(oModel,cTpRev,aCampos)
ElseIf cTipRev == DEF_REV_CAUCA								//= Revisão de caução
	aAdd(aCampos,{'CN9MASTER',{'CN9_MINCAU'}})
	MtBCMod(oModel,aCampos,{||.T.},'2')
	oModel:LoadValue('CN9MASTER','CN9_FLGCAU','1')
	oModel:LoadValue('CN9MASTER','CN9_TPCAUC','1')

ElseIf cTipRev == DEF_REV_ABERT		//Revisão Aberta

	CNLibConta(oModel)	//Libera campos relacionados ao contábel
	Cn300EspVld(oModel,cTpRev)
	CN300VdCrf(oModel)
	A300RevCtb(oModel)	
	Cn300VdArr()
	CNLibVend(oModel) // Libera os campos relacionados aos vendedores
	CNLibForCl(oModel,lFusao) // Libera os campos relacionados ao fornecedor/cliente
	
	If (oModelCN9:GetValue('CN9_SITUAC') == DEF_SPARA) //Se estiver paralisado		
		oModel:GetModel("CN9MASTER"):LoadValue('CN9_DTREIN',dDataBase)//Preenche a data de reinicio
	EndIf
	
	aCampos := {}
	
	aAdd(aCampos,{'CN9MASTER',{	'CN9_INDICE','CN9_INDDES','CN9_PERI','CN9_UNPERI','CN9_MODORJ','CN9_PRORAT','CN9_VIGE',;
								'CN9_FLGREJ', "CN9_DTREAJ","CN9_DREFRJ","CN9_DTRRDE","CN9_DTRRAT", "CN9_NATURE",;
								'CN9_ARRAST','CN9_REDVAL','CN9_QTDPAR', 'CN9_TPCRON','CN9_ALTCLA','CN9_OBJCTO',;
								'CN9_GRPAPR','CN9_APROV','CN9_DEPART','CN9_GESTC','CN9_DESC', 'CN9_DESCRI',;
								'CN9_MOTPAR','CN9_DESMTP','CN9_DTFIMP'}})
	
	If lVlPreFin
		aAdd(aCampos[1,2] ,	'CN9_TJUFIN')
	EndIf

	If CN9->(Columnpos('CN9_XREGP')) > 0
		aAdd(aCampos[1,2], 'CN9_XREGP')
	EndIf

	aAdd(aCampos,{'CNADETAIL',{'CNA_FLREAJ','CNA_INDICE','CNA_PERI','CNA_UNPERI','CNA_MODORJ','CNA_PRORAT', 'CNA_PROXRJ', 'CNA_DESCPL'}})
	If CNA->(ColumnPos("CNA_CONDPG") > 0 .And. ColumnPos("CNA_NATURE") > 0)
		aAdd(aCampos,{'CNADETAIL',{'CNA_CONDPG','CNA_NATURE'}})
	EndIf
	aAdd(aCampos,{'CNBDETAIL',{'CNB_INDICE','CNB_FLREAJ','CNB_ITEM','CNB_VLTOT','CNB_DESC','CNB_VLDESC','CNB_QTREAD','CNB_SLDMED','CNB_SLDREC', 'CNB_DTPREV',IIF(CNTGetFun() == 'CNTA300', "CNB_TE", "CNB_TS") }})	
	
	If oModelCN9:GetValue('CN9_FLGCAU') == '1' .And. oModelCN9:GetValue('CN9_TPCAUC') == '1'		
		aAdd(aCampos,{'CN9MASTER',{'CN9_MINCAU'}})
	ElseIf oModelCN9:GetValue('CN9_FLGCAU') == '2'
		aAdd(aCampos,{'CN9MASTER',{'CN9_MINCAU','CN9_FLGCAU', 'CN9_TPCAUC'}})
	EndIf
	
	aAdd(aCampos,{'CNFDETAIL',{'CNF_NUMERO','CNF_PARCEL','CNF_COMPET','CNF_VLPREV','CNF_VLREAL','CNF_SALDO', 'CNF_DTVENC', 'CNF_PRUMED', 'CNF_TXMOED', 'CNF_CONDPG'}})
	aAdd(aCampos,{'CXIDETAIL',{'CXI_TIPO','CXI_CODCLI','CXI_LOJACL','CXI_NOMCLI','CXI_FILRES','CXI_DESFIL','CXI_PERRAT'}})

	//- Agrupadores
	If Cn300RetSt('SEMIAGRUP')
		aAdd(aCampos,{'CXMDETAIL',{'CXM_AGRGRP','CXM_AGRCAT','CXM_VLMAX'}})		
		CNTA300BlMd(oModel:GetModel("CXMDETAIL"), .F.)
	EndIf

	MtBCMod(oModel,aCampos,{||.T.},'2')
	FwFreeArray(aCampos)
	
	CNTA300BlMd(oModel:GetModel("CNADETAIL"),.F.)
	CNTA300BlMd(oModel:GetModel("CNBDETAIL"), !(Cn300RetSt('FIXO') .Or. Cn300RetSt('SEMIFIXO')))

	If lVlPreFin
		oModel:GetModel('CNFDETAIL'):GetStruct():SetProperty('CNF_TJUROS',MODEL_FIELD_WHEN,FwBuildFeature( STRUCT_FEATURE_WHEN	,"FwFldGet('CNF_SALDO') > 0"))		
	EndIf		
EndIf

//- Chamada de função para liberação de campos de multiplas naturezas. 
CnRevMNat(oModel)

If oModel:CanSetValue('CN9MASTER','CN9_VIGE')
	oModel:GetModel('CN9MASTER'):GetStruct():SetProperty('CN9_VIGE',MODEL_FIELD_WHEN,{|| FwFldGet("CN9_UNVIGE") != '4'})
EndIf

If !oModel:GetModel("CNADETAIL"):CanUpdateLine()
	oModel:GetModel("CNADETAIL"):SetNoUpdateLine(.F.)
EndIf

If !oModel:GetModel("CNBDETAIL"):CanUpdateLine() .And. (Cn300RetSt('FIXO') .Or. Cn300RetSt('SEMIFIXO'))
	oModel:GetModel("CNBDETAIL"):SetNoUpdateLine(.F.)
EndIf

If Cn300RetSt('SERVIÇO')
	oModel:GetModel("CNBDETAIL"):GetStruct():SetProperty('CNB_QUANT',MODEL_FIELD_OBRIGAT,.F. )
	oModel:GetModel("CNBDETAIL"):GetStruct():SetProperty('CNB_QUANT',MODEL_FIELD_WHEN,{||.F.})
EndIf

//-- Ponto de Entrada para liberação dos Modelos para edição, de acordo com a Revisão que deseja customizar
If ExistBlock("A300MLDR")
	// Passa o tipo de Revisão e o Modelo
	ExecBlock("A300MLDR",.F.,.F.,{cTipRev,oModel})
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} cn300ModQr()
Não permite que modelos sem o campo revisao, seja duplicado na revisão

@author alexandre.gimenez
@since 21/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function cn300ModQr(oModel)
Local aModels := {'CNK','CNX','CNU','CNI','CPD','CNN','CNT','CNG','AGW'}
Local nX := 0

If (CNURevisa() .And. (nX := aScan(aModels,{|x| x == 'CNU' })) > 0)
	aDel(aModels, nX)
	aSize(aModels, Len(aModels)-1)
EndIf

For nX := 1 to Len(aModels)
	oModel:GetModel(aModels[nX]+'DETAIL'):SetOnlyQuery(.T.)
Next nX

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} cn300vldtpr()
Validação do tipo da revisão

@author
@since
@version 1.0
/*/
//-------------------------------------------------------------------
Static function cn300VldTpR()
Local oModel	:= FwModelActive()
Local oView	:= FwViewActive()
Local oModCN9	:= oModel:GetModel("CN9MASTER")
Local cTipRev	:= oModCN9:GetValue("CN9_TIPREV")
Local aArea 	:= GetArea()
Local lRet		:= .F.

DbSelectArea("CN0")
CN0->(DbSetOrder(1))

//Validação de tipo de contrato X tipo de revisão
If CN0->(DbSeek(xFilial("CN0")+cTipRev))
	lRet := CN0->CN0_TIPO == A300GTpRev()
EndIf

//Verificação se acontecerá refresh dos valores
If lRet .And. A300GRevis() .And. MsgYesNo(STR0022)	//"A alteração impactará na oerda dos dados, deseja continuar?"

    //-- Trecho alterado por instruções do FrameWork 
	A300IniRev(oModel,.T.)
	oModel:Deactivate()
   	oModel:nOperation := 3
 	oModel:Activate(.T.)   
    oModCN9:LoadValue("CN9_TIPREV",cTipRev)
    A300IniRev(oModel,.F.)
	If ValType(oView) == "O" .And. oView:IsActive()
		oView:Refresh()
	EndIf
EndIf

//Função de controle das revisões
If lRet
	A300Revisa(oModel,cTipRev)
	A300SRevis(.T.)
EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} cnFilRev(cContra,cRev)
Função para filtrar consulta padrao dependo do tipo de revisao

@author alexandre.gimenez
@since 23/01/2014
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Static function cnFilRev()
Local lRet := Nil

If Empty(A300GTpRev())
	lRet := .T.
Else
	lRet := CN0->CN0_TIPO == A300GTpRev()
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300IniApr()
Inicializaçao do processo da aprovação

@author aline.sebrian
@since 20/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function A300IniApr(oModel)
Local aModels	:= MTGetAllMd({"CALC_CNS","CALC_CNF"})
Local oModelCN9	:= oModel:GetModel('CN9MASTER')
Local oStruCN9 	:= oModelCN9:GetStruct()

If oModel:GetOperation() == MODEL_OPERATION_INSERT  .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE
	If A300GATpRv() == DEF_REV_PARAL .Or. (A300GATpRv() == DEF_REV_ABERT .And. !Empty(oModelCN9:GetValue('CN9_MOTPAR')) .And. Empty(oModelCN9:GetValue('CN9_DTREIN')))
		oModelCN9:SetValue('CN9_SITUAC','06')	//Atualização da Situação "Paralisado"
	Else
		oModelCN9:SetValue('CN9_SITUAC','05')	//Atualização da Situação "Vigente"
	EndIf

	//-- Atualizaça retencao de caução retida em revisão de reajuste ou realinhamento.
	A300AtCauR(oModel)
	oStruCN9:SetProperty('*',MODEL_FIELD_WHEN,{||.F.}) 	//Desabilita os campos do contrato

	//Bloqueio total dos modelos
	MtBCMod(oModel,aModels,{||.F.})
EndIf
Return

//------------------------------------------------------------------
/*/{Protheus.doc} CN300ApArF
Função que aplica o arrasto no cronograma fisico e automaticamente
no financeiro

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function CN300ApArF(oModel)
	Local aSaveLines := FWSaveRows()
	Local oCN9Master := oModel:GetModel('CN9MASTER')
	Local oCNFDetail := oModel:GetModel('CNFDETAIL')
	Local oCNSDetail := oModel:GetModel('CNSDETAIL')
	Local oStruCNF 	 := oModel:GetModel('CNFDETAIL'):GetStruct()

	Local lRedVlrs	 := oCN9Master:GetValue('CN9_REDVAL') == '1'

	Local nI		:= 0
	Local nI2		:= 0
	Local nI3		:= 0 
	Local nRound	:= TamSX3('CNS_PRVQTD')[2]
	Local nDifArr	:= 0
	Local nQuant	:= 0
	
	Local aProd		:= {}
	Local aLinhas 	:= {}
	Local aItens	:= {}
	Local aSld		:= {}
	Local nSldQtd	:= 0
	Local nSaldo 	:= 0 
	Local bFalseWhen:= FwBuildFeature( STRUCT_FEATURE_WHEN, ".F.")

	//-- Libera os campos do cronograma Financeiro.
	oStruCNF:SetProperty("CNF_VLPREV",MODEL_FIELD_WHEN,{||.T.})
	oStruCNF:SetProperty("CNF_VLREAL",MODEL_FIELD_WHEN,{||.T.})

	For nI := 1 To oCNFDetail:Length()
		oCNFDetail:GoLine(nI)
		If oCNFDetail:IsDeleted()
			Loop
		EndIf

		For nI2 := 1 To oCNSDetail:Length()
			oCNSDetail:GoLine(nI2)

			If oCNSDetail:IsDeleted()
				Loop
			EndIf

			//-- O array aItens guarda o código do produto e o saldo total que será arrastado
			If oCNSDetail:GetValue('CNS_RLZQTD') > 0 .And. oCNSDetail:GetValue('CNS_SLDQTD') > 0
				If ((nSldQtd := oCNSDetail:GetValue('CNS_SLDQTD')) > 0)
					nPos := aScan(aItens,{|x| x[1] == oCNSDetail:GetValue('CNS_ITEM')})
					If nPos == 0
						aAdd(aItens, {oCNSDetail:GetValue('CNS_ITEM'), 0})
						nPos := Len(aItens)			
					EndIf				
					aItens[nPos, 2] += nSldQtd
				EndIf

				//-- Zero o saldo e atualizo a quantidade prevista igual a realizada
				nSaldo := oCNSDetail:GetValue('CNS_DISTSL') + oCNSDetail:GetValue('CNS_SLDQTD')	
				oCNSDetail:SetValue('CNS_PRVQTD', oCNSDetail:GetValue('CNS_RLZQTD'))
				oCNSDetail:LoadValue('CNS_SLDQTD', 0)
			EndIf

			//-- Se não estiver trabalhando com a redistribuição de valores guardo a primeira linha não medida,
			//-- para posteriormente atualiza-la com os valores do arrasto.
			If !lRedVlrs
				If oCNSDetail:GetValue('CNS_RLZQTD') == 0
					nPos := aScan(aProd,{|x| x[1] == oCNSDetail:GetValue('CNS_ITEM')})
					If nPos == 0 .And. oCNSDetail:GetValue('CNS_DISTSL') > 0
						oCNSDetail:SetValue('CNS_PRVQTD', oCNSDetail:GetValue('CNS_PRVQTD') + oCNSDetail:GetValue('CNS_DISTSL'))
						Aadd(aProd, {oCNSDetail:GetValue('CNS_ITEM')})
					EndIF
				EndIf

				//-- Se não, além de guardar todas as linhas não medidas, se faz necessário guardar os valores de todas
				//-- as parcelas para que sejam resdistribuidos.
			ElseIf oCNSDetail:GetValue('CNS_RLZQTD') == 0
				nPos := aScan(aLinhas,{|x| x[1] == oCNSDetail:GetValue('CNS_ITEM')})
				If nPos == 0
					aAdd(aLinhas, {oCNSDetail:GetValue('CNS_ITEM'), 0, {}})
					nPos := Len(aLinhas)
				EndIf
				aLinhas[nPos, 2] += 1

				nSldQtd := oCNSDetail:GetValue('CNS_SLDQTD')
				If aScan(aSld,oCNSDetail:GetValue('CNS_ITEM')) == 0
					nSldQtd += oCNSDetail:GetValue('CNS_DISTSL')
					aAdd(aSld, oCNSDetail:GetValue('CNS_ITEM'))
				EndIf

				If (nSldQtd > 0 )
					nPos := aScan(aItens,{|x| x[1] == oCNSDetail:GetValue('CNS_ITEM')})
					If nPos == 0
						aAdd(aItens, {oCNSDetail:GetValue('CNS_ITEM'), 0})
						nPos := Len(aItens)			
					EndIf				
					aItens[nPos, 2] += nSldQtd
				EndIf
			ElseIf oCNSDetail:GetValue('CNS_RLZQTD') > 0
				//-- O vetor aLinhas (com redistribuição de valores) guarda as linhas que não irei atualizar
				//-- no momento de aplicar o arrasto, ou seja, as parcelas já medidas
				nPos := aScan(aLinhas,{|x| x[1] == oCNSDetail:GetValue('CNS_ITEM')})
				If nPos == 0
					Aadd(aLinhas, {oCNSDetail:GetValue('CNS_ITEM'), 0 , {oCNFDetail:GetLine()} })
				Else
					Aadd(aLinhas[nPos, 3], oCNFDetail:GetLine())
				EndIf
			EndIf
		Next nI2
	Next nI
	If lRedVlrs
		For nI := 1 To Len(aItens)
			nPos 	:= aScan(aLinhas,{|x| x[1] == aItens[nI, 1]})
			nQuant := aItens[nI,2] / aLinhas[nPos,2]
			nDifArr:= aItens[nI,2] - (Round(nQuant,nRound) * aLinhas[nPos,2])

			For nI2 := 1 To oCNFDetail:Length()
				oCNFDetail:GoLine(nI2)
				If Ascan(aLinhas[nPos, 3], oCNFDetail:GetLine()) == 0
					For nI3 := 1 To oCNSDetail:Length()
						oCNSDetail:GoLine(nI3)
						If oCNSDetail:GetValue('CNS_ITEM') == aItens[nI, 1]
							If nI2 == oCNFDetail:Length()
								oCNSDetail:SetValue('CNS_PRVQTD', Round(nQuant, nRound) + nDifArr)
							Else
								oCNSDetail:SetValue('CNS_PRVQTD', Round(nQuant, nRound))
							EndIf
						EndIf
					Next nI3
				EndIf
			Next nI2

		Next nI
	EndIf

	//-- Atualiza o Financeiro
	A300FscTFn(oModel)

	oStruCNF:SetProperty("CNF_VLPREV",MODEL_FIELD_WHEN, bFalseWhen)
	oStruCNF:SetProperty("CNF_VLREAL",MODEL_FIELD_WHEN, bFalseWhen)

	FWRestRows(aSaveLines)
	FwFreeArray(aSaveLines)
	
	FwFreeArray(aProd)
	FwFreeArray(aLinhas)
	FwFreeArray(aItens)
	FwFreeArray(aSld)
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CN300RevPd
Tratamentos no pedido de compra/venda

@param oModel Modelo de dados ativo

@author guilherme.pimentel
@since 06/03/2014
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static function CN300RevPd(oModel, nReajTotal as numeric)
	Local lRet		:= A300RevMed()
	Local cQuery	:= ''	
	Local cContra	:= oModel:GetValue('CN9MASTER','CN9_NUMERO')
	Local cRevisa	:= oModel:GetValue('CN9MASTER','CN9_REVISA')
	Local aCab		:= {}
	Local cCNDAlias	:= ""
	Local cChave := ""
	Local cTipoRv:= A300GATpRv()
	Local cDtReajst := ""
	Local cFiltroPed:= ""
	Local cPlanVazia:= Space(GetSX3Cache("CND_NUMERO", "X3_TAMANHO"))
	Local lCNEVlLiq := CNE->(Columnpos('CNE_VLLIQD')) > 0
	Private lMsErroAuto := .F.
	Default nReajTotal	:= 0
	
	If lRet
		CNA->(DbSetOrder(1))//CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO
		cChave := xFilial("CNA") + cContra + cRevisa		
		If(CNA->(DbSeek(cChave)))
			cDtReajst := DTOS(oModel:GetValue('CN9MASTER','CN9_DTREAJ')) 
			
			If(Cn300RetSt("COMPRA"))				
				cFiltroPed := "((SELECT SUM(SC7.C7_QUJE) AS C7_QUJE "
				cFiltroPed += " FROM "+RetSQLName("SC7")+" SC7 "
				cFiltroPed += " WHERE SC7.C7_MEDICAO = CND.CND_NUMMED "
				cFiltroPed += " AND SC7.C7_FILIAL = '"+xFilial("SC7")+"'"
				cFiltroPed += " AND SC7.D_E_L_E_T_ = ' ') = 0)"	
			Else
				cFiltroPed := "((SELECT SUM(SC6.C6_QTDENT) AS C6_QTDENT FROM " +RetSQLName("SC6")+ " SC6 "
				cFiltroPed += " INNER JOIN " +RetSQLName("SC5")+ " SC5 ON (SC5.C5_NUM = SC6.C6_NUM) "
				cFiltroPed += " WHERE SC5.C5_FILIAL = '"+ xFilial("SC5") +"' AND SC6.C6_FILIAL = '"+ xFilial("SC6")+"'"
				cFiltroPed += " AND SC5.C5_MDNUMED = CND.CND_NUMMED AND SC5.D_E_L_E_T_ = ''  AND SC6.D_E_L_E_T_ = '' ) = 0)"
			EndIf			 
				
			While ( CNA->(!Eof() .And.  CNA_FILIAL+CNA_CONTRA+CNA_REVISA == cChave) )
				
				If( (cTipoRv == DEF_REV_REALI) .Or.;
					(CNA->CNA_FLREAJ == '1' .And.  cTipoRv == DEF_REV_REAJU) .Or.;
					(CNA->CNA_FLREAJ == '1' .And.  cTipoRv == DEF_REV_ABERT .And. nReajTotal > 0))
					cCNDAlias := GetNextAlias()
					//Seleciona medicoes nao zeradas e nao recebidas
					cQuery := "SELECT CND.R_E_C_N_O_ as RECNO,CND.CND_NUMMED "
					cQuery += " FROM "+RetSQLName("CND")+" CND "
					cQuery += " WHERE CND.CND_FILIAL = '"+xFilial("CND")+"' AND CND.D_E_L_E_T_ = ' '"
					
					If !Empty(cDtReajst)
						cQuery += " AND CND.CND_DTFIM <= '"+ cDtReajst +"'"
					EndIf
					
					cQuery += " AND CND.CND_NUMERO IN('"+ CNA->CNA_NUMERO +"','"+ cPlanVazia +"')"
					cQuery += " AND CND.CND_CONTRA = '"+cContra+"'"
					cQuery += " AND CND.CND_REVISA = '"+cRevisa+"'"
					cQuery += " AND CND.CND_ZERO   = '2'"
					cQuery += " AND " + cFiltroPed
									
					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cCNDAlias,.F.,.T.)
					
					While !(cCNDAlias)->(Eof())
						CND->(dbGoTo((cCNDAlias)->RECNO))
						If IsNewMed(cContra,cRevisa,(cCNDAlias)->CND_NUMMED) //Verifica se a medição foi gerada pela rotina CNTA121
							lRet := CN121Estorn(.T.,.T.)	//- Executa o estorno da medição.
							//- Atualiza CNE_VLLIQD
							If lCNEVlLiq
								Cn300AtLiq((cCNDAlias)->CND_NUMMED,cContra,cRevisa,.T.)
							EndIf
							lRet := CN121Encerr(.T.,.T.)	//- Executa o encerramento da medição.
						Else							
							aAdd(aCab,{"CND_CONTRA",CND->CND_CONTRA,NIL})
							aAdd(aCab,{"CND_REVISA",CND->CND_REVISA,NIL})
							aAdd(aCab,{"CND_COMPET",CND->CND_COMPET,NIL})
							aAdd(aCab,{"CND_NUMERO",CND->CND_NUMERO,NIL})
							aAdd(aCab,{"CND_NUMMED",CND->CND_NUMMED,NIL})
				
							MSExecAuto({|x,y|CNTA120(x,y,7,.F.)},aCab,{})//Chama o ExecAuto p/ Estornar						
							If((lRet := !(lMsErroAuto)))
								//- Atualiza CNE_VLLIQD
								If lCNEVlLiq
									Cn300AtLiq((cCNDAlias)->CND_NUMMED,cContra,cRevisa,.F.)
								EndIf														
								MSExecAuto({|x,y|CNTA120(x,y,6,.F.)},aCab,{}) //Chama o execAuto para Encerrar
								If(!(lRet := !(lMsErroAuto)))
									If(!IsBlind())									
										MostraErro()
									EndIf
								EndIf						
							ElseIf(!IsBlind())									
								MostraErro()
							EndIf
							
							aEval(aCab,{|x| aSize(x,0) })
							aSize(aCab,0)
						EndIf
						(cCNDAlias)->(dbSkip())
					EndDo
					(cCNDAlias)->(dbCloseArea())					
				EndIf
				CNA->(dbSkip())
			EndDo
		EndIf		
	EndIf

	FwModelActive(oModel)//Restaura o modelo
Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CN300ClDt
Função recursiva para calcular o valor a ser redistribuido

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function CN300ClDt(oCNFDetail, nSldADis, nMont ,nDescParc, aLinhas)
Local nI 			:= 0
Local aSaveLines	:= FWSaveRows()
Local nVlrDesc    := 0

For nI := 1 To oCNFDetail:Length()
	oCNFDetail:GoLine(nI)
	If Ascan(aLinhas, oCNFDetail:GetLine()) == 0
		If oCNFDetail:GetValue('CNF_VLREAL') > nSldADis
			nDescParc := nDescParc + 1
			nVlrDesc  := nVlrDesc + oCNFDetail:GetValue('CNF_VLPREV')
			Aadd(aLinhas, oCNFDetail:GetLine())
			nSldADis := (nMont - nVlrDesc) / (oCNFDetail:Length(.T.) - nDescParc)
			CN300ClDt(oCNFDetail, @nSldADis, nMont,@nDescParc, @aLinhas)
		EndIf
	EndIf
Next nI

FWRestRows(aSaveLines)
Return aLinhas


//-------------------------------------------------------------------
/*/{Protheus.doc} A300OpenMd()
Funcao abrir todo o modelo e fazer processamento e bloquear novamente.

@author alexandre.gimenez
@since 14/03/2014
@version 1.0
/*/
//--------------------------------------------------------------------
Static function A300OpenMd(bCodeBlock,lClose, lMsgRun, cMsgRun)
	Local oModel	:= FwModelActive()
	Local aModels	:= Nil

	Default lClose	:= .T.
	Default lMsgRun := .F.
	//Default cMsgRun := STR0039

	//-- Adicionado todos os modelos de contratos
	aModels := {'CN9MASTER','CNCDETAIL','CN8DETAIL','CNIDETAIL','CNADETAIL','CNBDETAIL',;
				'CNFDETAIL','CNHDETAIL','CNKDETAIL','CNXDETAIL','CNUDETAIL','CPDDETAIL',;
				'CNZDETAIL','CNSDETAIL','CNNDETAIL','CNVDETAIL','CNWDETAIL','CNTDETAIL','CXMDETAIL'}	

	GCTOpenMdl(oModel, aModels)//-- Abre o Modelo
	//-- Processa o Bloco Abre o Modelo
	If !Empty(bCodeBlock)
		If lMsgRun
			lMsgRun := !IsBlind()
		EndIf
		
		If lMsgRun
			//FWMsgRun(, bCodeBlock, STR0037, cMsgRun)
		Else	
			Eval(bCodeBlock)
		EndIf
	EndIf
	//-- Fecha o Modelo de acordo com a revisao
	If lClose
		A300Revisa(oModel,A300GTpRev())
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} a300refresh(cCampo)
Gatilho para dar refresh na view

@author alexandre.gimenez
@since 14/03/2014
@version 1.0
/*/
//--------------------------------------------------------------------
Static function a300refresh(cCampo)
	Local oView		:= FwViewActive()
	Local oModel 	:= FwModelActive()
	Local oModelCNB := Nil
	Local cRet      := Nil

	If ValType(oView) == "O" .And. oView:IsActive() .And. !(oView:GetModel():GetId()=="BROWSE") .And. !IsInCallStack("A300DivCNB") .And. !IsInCallStack("TECA850")
		oView:Refresh()
	EndIf

	If oModel:GetId() == "CNTA300" .and. !Empty(cCampo)
		oModelCNB := oModel:GetModel("CNBDETAIL")
		cRet := oModelCNB:GetValue(cCampo)
	Else
		cRet := FwFldGet(cCampo)
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300AtCauR()
Funcao para atualizar retencao de caução retida em revisão de reajuste
ou realinhamento..

@author alexandre.gimenez
@since 13/03/2014
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function A300AtCauR(oModel)
Local oModCN9	:= oModel:GetModel("CN9MASTER")
Local oModCNT	:= oModel:GetModel("CNTDETAIL")
Local oModCNA	:= oModel:GetModel("CNADETAIL")
Local oModCNB	:= oModel:GetModel("CNBDETAIL")
Local lCaucaoR	:= (oModCN9:GetValue("CN9_FLGCAU") == "1"  .And. oModCN9:GetValue("CN9_TPCAUC") == '2')
Local nVlrCauc	:= oModCN9:GetValue("CN9_MINCAU")
Local cIndice	:= oModCN9:GetValue("CN9_INDICE")
Local cDataRef	:= oModCN9:GetValue("CN9_DREFRJ")
Local lCnRevMd	:= SuperGetMV("MV_CNREVMD",.F.,.T.)
Local nX		:= 0
Local nVlrReaj:= 0
Local nVLrRetC:= 0
Local nPos		:= 0
Local lRevMed	:= .F.
Local aMed		:= Nil
Local aVLrRetC:={}
Local lAtualiz:= .F.
Local lFixo	:= .F.

If lCaucaoR
	lFixo	:= Cn300RetSt("FIXO",2)
	lRevMed	:= A300RevMed()
	If lRevMed		
		If (A300GATpRv() == DEF_REV_REAJU .Or. A300GATpRv() == DEF_REV_REALI)
			aMed := A300SldRec('a2','',.F.)
			lAtualiz := .T.
		ElseIf A300GTpRev() == DEF_REV_REAJU
			aMed := A300SldRec('a2',oModCNB:GetValue("CNB_ITEM"),.T.)
			lAtualiz := .T.
		ElseIf A300GTpRev() == DEF_REV_REALI .Or. A300GTpRev() == DEF_REV_RENOV .Or. A300GTpRev() == DEF_REV_ORCGS
			aMed := A300SldRec('a2','',.T.)
			lAtualiz := .T.
		EndIf
	EndIf
EndIf

If lAtualiz .And. !lFixo .And. (A300GTpRev() == DEF_REV_REALI .Or.  A300GATpRv() == DEF_REV_REALI )
	lAtualiz := .F.
EndIf

If lAtualiz .And. !Empty(aMed)
	DbSelectArea("CND")
	CND->(DbSetOrder(1))
	DbSelectArea("CNE")
	CNE->(DbSetOrder(1))
	DbSelectArea("CNT")
	CNT->(DbSetOrder(1))
	oModCNT:SetNoUpdateLine(.F.)
	For nX := 1 to Len(aMed)
		oModCNT:GoLine(MTFindMVC(oModCNT,{{'CNT_NUMMED',aMed[nX,2]}}))
		//-- Posiciona planilha
		If lFixo
			oModCNA:GoLine(MTFindMVC(oModCNA,{{'CNA_NUMERO',aMed[nX,1]}})) //Posiciona planilha
			//Busca Item
			oModCNB:GoLine(MTFindMVC(oModCNB,{{'CNB_ITEM',aMed[nX,3]}})) // Posiciona no Item
			If !Empty(oModCNB:GetValue("CNB_ITMDST")) // o Item foi quebrado, posciona no novo item
				oModCNB:GoLine(MTFindMVC(oModCNB,{{'CNB_ITEM',oModCNB:GetValue("CNB_ITMDST")}}))
			EndIf

		EndIf
		If lCnRevMd  .And. empty(A300GTpRev())
			//Busca medicao ja revisada
			If CND->(DbSeek(xFilial('CND')+oModCN9:GetValue("CN9_NUMERO")+oModCN9:GetValue("CN9_REVISA")+aMed[nX,1]+aMed[nX,2]))
				oModCNT:SetValue("CNT_VLRET",CND->CND_RETCAC)
			EndIf
		Else
			//Busca medicao nao revisada ainda
			If CNE->(DbSeek(xFilial('CNE')+oModCN9:GetValue("CN9_NUMERO")+CnRevAnt()+aMed[nX,1]+aMed[nX,2]+aMed[nX,3]))
				If (A300GTpRev() == DEF_REV_REALI .Or.  A300GATpRv() == DEF_REV_REALI )
					nVlrReaj := Round(( oModCNB:GetValue("CNB_VLUNIT") - CNE->CNE_VLUNIT ) * CNE->CNE_QUANT,TamSx3("CNB_VLUNIT")[2] )
					nVLrRetC := Round(nVlrReaj*nVlrCauc/100*(1-(CNE->CNE_PDESC/100)),TamSx3("CNB_VLUNIT")[2])
					If !Empty(aVLrRetC) .And. ( nPos := aScan(aVLrRetC,{|x| x[1] == CNE->CNE_NUMMED  })) > 0
						aVLrRetC[nPos,2] += nVLrRetC
					Else
						aAdd(aVLrRetC,{CNE->CNE_NUMMED,nVLrRetC})
					EndIf
				Else
					nVlrReaj := Round(( CNE->CNE_VLUNIT*A300VlrInd(cIndice,cDataRef) - CNE->CNE_VLUNIT ) * CNE->CNE_QUANT,TamSx3("CNB_VLUNIT")[2] )
					nVLrRetC := Round(nVlrReaj*nVlrCauc/100*(1-(CNE->CNE_PDESC/100)),TamSx3("CNB_VLUNIT")[2])
					oModCNT:SetValue("CNT_VLRET",oModCNT:GetValue("CNT_VLRET")+nVLrRetC)
				EndIf


			EndIf
		EndIf
	Next nX
	If !Empty(aVLrRetC)
		For nX := 1 to Len(aVLrRetC)
			oModCNT:GoLine(MTFindMVC(oModCNT,{{'CNT_NUMMED',aVLrRetC[nX,1]}}))
			If CNT->(DbSeek(xFilial('CNT')+oModCN9:GetValue("CN9_NUMERO")+aVLrRetC[nX,1]))
				oModCNT:SetValue("CNT_VLRET",CNT->CNT_VLRET+aVLrRetC[nX,2])
			EndIf
		Next nX
	EndIf
	oModCNT:SetNoUpdateLine(.T.)
EndIf


Return


//-------------------------------------------------------------------
/*/{Protheus.doc} A300AtuMed()
Funcao para atualizar a medicao conforme reajuste ou realinhamento.

@author alexandre.gimenez
@since 10/03/2014
@version 1.0
/*/
//--------------------------------------------------------------------
Static function A300AtuMed(oModel)
Local aAreas 	:= { CND->(GetArea()), CNE->(GetArea()), CXN->(GetArea()), GetArea() }
Local oModCN9	:= oModel:GetModel("CN9MASTER")
Local oModCNA	:= oModel:GetModel("CNADETAIL")
Local oModCNB	:= oModel:GetModel("CNBDETAIL")
Local oModCNF 	:= oModel:GetModel("CNFDETAIL")
Local lRevMed 	:= A300RevMed()
Local nX		:= 0
Local nY		:= 0
Local aDados	:= {}
Local lAtualiz	:= .F.
Local cIndice	:= oModCN9:GetValue("CN9_INDICE")
Local cDataRef	:= oModCN9:GetValue("CN9_DREFRJ")
Local lCaucaoR	:= oModCN9:GetValue("CN9_TPCAUC") == '2'
Local nVlrCauc	:= oModCN9:GetValue("CN9_MINCAU")
Local nAtuCauc	:= IIF(Cn300RetSt("COMPRA"),-1,1)
Local cNewItem	:= ''
Local nVlrReaj	:= 0
Local nVLrRetC	:= 0
Local lFixo		:= Cn300RetSt("FIXO",2)
Local lSemiProd	:= Cn300RetSt('SEMIFIXO',2) .And. Cn300RetSt("SEMIPROD",2)
Local nTotAnt	:= 0
Local lCnaUpd	:= oModCNA:CanUpdateLine()
Local lReajMed	:= Cn300RetSt("REVREAJU")
Local cTpRevisao:= A300GATpRv()
Local nDecVlUnit:= TamSx3("CNB_VLUNIT")[2]
Local nDecVlTot := TamSx3("CNB_VLTOT")[2]
Local nDecVlDesc:= TamSx3("CNB_VLDESC")[2]
Local nReajTotal:= 0
Local nLinha	:= 0

If lRevMed
	lAtualiz := !Empty(cTpRevisao) .And. (cTpRevisao $ DEF_REV_REAJU+"|"+DEF_REV_REALI+"|"+DEF_REV_ABERT )
EndIf

If lAtualiz .And. !lFixo .And. !lSemiProd .And. (A300GTpRev() == DEF_REV_REALI .Or.  A300GATpRv() == DEF_REV_REALI )
	lAtualiz := .F.
EndIf

If lAtualiz	
	CND->(DbSetOrder(1))	
	CNE->(DbSetOrder(1))

	aDados := A300SldRec('a2','',.F.)
	If !Empty(aDados)
		CNTA300BlMd(oModCNF,.F.)
		For nX := 1 to Len(aDados)
			cNewItem:= ''
			cIndice	:= oModCN9:GetValue("CN9_INDICE")

			//-- Prepara informações do item reajustado/realinhado
			If !(Empty(aDados[nX,1])) //tem planilha				
				If ((nLinha := MTFindMVC(oModCNA,{{'CNA_NUMERO',aDados[nX,1]}})) > 0)
					oModCNA:GoLine(nLinha) //Posiciona planilha
					If ((A300GTpRev() == DEF_REV_REAJU .And. oModCNA:GetValue("CNA_FLREAJ") == '2') .Or. !A300RevMed(0)) .Or.;
						(Cn300RetSt('SEMIFIXO') .And. Cn300RetSt('SEMIAGRUP')) // não permite reajuste
						Loop
					EndIf

					If !Empty(oModCNA:GetValue('CNA_INDICE'))
						cIndice := oModCNA:GetValue('CNA_INDICE')
					EndIf

					If (!oModCNB:IsEmpty())
						If (nLinha := MTFindMVC(oModCNB,{{'CNB_ITEM',aDados[nX,3]}})) > 0 //Busca Item
							oModCNB:GoLine(nLinha) // Posiciona no Item
							If !Empty(oModCNB:GetValue("CNB_ITMDST")) // o Item foi quebrado, posciona no novo item
								oModCNB:GoLine(MTFindMVC(oModCNB,{{'CNB_ITEM',oModCNB:GetValue("CNB_ITMDST")}}))
							EndIf
							cNewItem := oModCNB:GetValue("CNB_ITEM") // Atualiza Item caso tenha sido quebrado
							
							If !Empty(oModCNB:GetValue("CNB_INDICE"))
								cIndice := oModCNB:GetValue("CNB_INDICE") // atualiza indice da planilha
							EndIf							
						EndIf
					EndIf

				EndIf
			EndIf
			
			If CNE->(DbSeek(xFilial('CNE')+oModCN9:GetValue("CN9_NUMERO")+oModCN9:GetValue("CN9_REVISA")+aDados[nX,1]+aDados[nX,2]+aDados[nX,3]))
				nTotAnt := CNE->CNE_VLTOT

				RecLock("CNE",.F.)
					CNE->CNE_ITEM		:= IIF(Empty(cNewItem),CNE->CNE_ITEM,cNewItem)
					CNE->CNE_QTDORI 	:= CNE->CNE_QUANT
					CNE->CNE_VUNORI		:= CNE->CNE_VLUNIT
					If (A300GTpRev() == DEF_REV_REALI .Or.  A300GATpRv() == DEF_REV_REALI )
						CNE->CNE_VLUNIT	:= Round(oModCNB:GetValue("CNB_VLUNIT"),nDecVlUnit)
					Else
						CNE->CNE_VLUNIT	:= Round(CNE->CNE_VLUNIT*A300VlrInd(cIndice,cDataRef),nDecVlUnit)
					EndIf
					CNE->CNE_VLTOT	:= Round(CNE->CNE_VLUNIT * CNE->CNE_QUANT		, nDecVlTot)
					CNE->CNE_VLDESC	:= Round(CNE->CNE_VLTOT  * CNE->CNE_PDESC / 100	, nDecVlDesc)
				MsUnlock()

				nVlrReaj 	:= Round(CNE->CNE_VLTOT - nTotAnt , nDecVlUnit )
				nReajTotal	+= nVlrReaj
				nVLrRetC 	:= IIF(lCaucaoR,Round( (nVlrReaj*(nVlrCauc/100))*(1-(CNE->CNE_PDESC/100)) ,nDecVlUnit),0)
			EndIf

			If IsNewMed(oModCN9:GetValue("CN9_NUMERO"),oModCN9:GetValue("CN9_REVISA"),aDados[nX,2])
				CXN->(dbSetOrder(1))
				If CXN->(DbSeek(xFilial('CND')+oModCN9:GetValue("CN9_NUMERO")+oModCN9:GetValue("CN9_REVISA")+aDados[nX,2]+aDados[nX,1]))
					RecLock("CXN",.F.)
					CXN->CXN_VLSALD	+= oModCNA:GetValue('CNA_VLTOT') - oModCNA:GetValue('CNA_SALDO')
					CXN->CXN_VLPREV += nVlrReaj
					CXN->CXN_VLLIQD += nVlrReaj
					CXN->CXN_VLTOT 	+= nVlrReaj
					MsUnlock()
				EndIf				
				cPlanilha := SPACE(Len(CXN->CXN_NUMPLA))
			Else
				cPlanilha := aDados[nX,1]
			EndIf

			If CND->(DbSeek(xFilial('CND')+oModCN9:GetValue("CN9_NUMERO")+oModCN9:GetValue("CN9_REVISA")+cPlanilha+aDados[nX,2]))
				RecLock("CND",.F.)
				CND->CND_VLREAJ	+= nVlrReaj
				CND->CND_VLTOT	+= nVlrReaj + (nVLrRetC*nAtuCauc)
				CND->CND_VLPREV	+= nVlrReaj
				CND->CND_VLLIQD	+= nVlrReaj
				CND->CND_RETCAC	+= nVLrRetC
				CND->CND_VLCONT	:= oModCN9:GetValue("CN9_VLATU")
				MsUnlock()
			EndIf
			
			oModCNA:SetNoUpdateLine(.F.)
			For nY := 1 To oModCNF:Length()//ajusta parcelas do cronograma financeiro e saldo do contrato
				oModCNF:GoLine(nY)
				If oModCNF:GetValue("CNF_COMPET") == CND->CND_COMPET
					IF ( !(A300GTpRev() == DEF_REV_REAJU .And. lFixo) .OR. lReajMed ) .And. !(A300GTpRev() == DEF_REV_REALI .And. lFixo) .And. !Empty(oModCNF:GetValue("CNF_COMPET"))
						oModCNF:LoadValue("CNF_VLREAL",oModCNF:GetValue("CNF_VLREAL")+nVlrReaj)
						oModCNF:LoadValue("CNF_SALDO",oModCNF:GetValue("CNF_SALDO")-nVlrReaj)
					EndIf
					oModCN9:LoadValue("CN9_SALDO",oModCN9:GetValue("CN9_SALDO")-nVlrReaj)
					oModCNA:LoadValue("CNA_SALDO",oModCNA:GetValue("CNA_SALDO")-nVlrReaj)
					Exit
				EndIf
			Next nY
			oModCNA:SetNoUpdateLine(lCnaUpd)
		Next nX
		CNTA300BlMd(oModCNF,.T.)
		FwFreeArray(aDados)
	EndIf
EndIf

aEval(aAreas, {|x| RestArea(x) })
FwFreeArray(aAreas)
Return nReajTotal

//-------------------------------------------------------------------
/*/{Protheus.doc} A300FscTFn()
Funcao para atualizar o cronograma financeiro pelo fisico.

@author alexandre.gimenez
@since 10/03/2014
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function A300FscTFn(oModel)
	Local nF 		:= 0
	Local nS		:= 0
	Local nVlrPre	:= 0
	Local nVlrRlz	:= 0
	Local oModCNS	:= oModel:GetModel("CNSDETAIL")
	Local oModCNF	:= oModel:GetModel("CNFDETAIL")
	Local oModCNB	:= oModel:GetModel("CNBDETAIL")
	Local oCalcCNS	:= oModel:GetModel("CALC_CNS")
	Local aSavelines:= FWSaveRows()
	Local nJuros	:= 0
	Local lVlPreFin := ValPresFin(oModel:GetModel("CN9MASTER"), @nJuros)
	Local nDecVlPrev:= GetSx3Cache('CNF_VLPREV'	, 'X3_DECIMAL')
	Local nDecSaldo	:= GetSx3Cache('CNF_SALDO'	, 'X3_DECIMAL')
	Local aPropCNF := {GCTGetWhen(oModCNF), GetPropMdl(oModCNF)}

	oModCNF:SetNoUpdateLine(.F.)
	oModCNF:GetStruct():SetProperty("*",MODEL_FIELD_WHEN,{||.T.})

	For nF := 1 To oModCNF:Length()
		oModCNF:Goline(nF)
		If !oModCNF:IsDeleted()
			nVlrPre	:= 0
			nVlrRlz	:= 0
			
			For nS := 1 To oModCNS:Length()
				oModCNS:GoLine(nS)
				If !oModCNS:IsDeleted()
					nVlrPre += Round(oModCNS:GetValue("CNS_PRVQTD") * oModCNB:GetValue("CNB_VLUNIT",nS) * (1-(oModCNB:GetValue("CNB_DESC",nS)/100)),nDecVlPrev)
					nVlrRlz += Round(oModCNS:GetValue("CNS_RLZQTD") * oModCNB:GetValue("CNB_VLUNIT",nS) * (1-(oModCNB:GetValue("CNB_DESC",nS)/100)),nDecVlPrev)				
				EndIf
			Next nS			
			oModCNF:SetValue("CNF_VLREAL",nVlrRlz)
			oModCNF:SetValue("CNF_VLPREV",nVlrPre)
			oCalcCNS:SetValue("TCNS_VTOT",oModCNF:GetValue("CNF_VLPREV"))			
			oModCNF:LoadValue("CNF_SALDO",Round(nVlrPre - nVlrRlz, nDecSaldo))		

			If lVlPreFin .And. (Empty(oModCNF:GetValue("CNF_VLREAL")) .Or. Empty(oModCNF:GetValue("CNF_TJUROS")))
				oModCNF:SetValue('CNF_TJUROS', nJuros)//Ao preencher CNF_TJUROS, CNF_VLPRES e CNF_VJUROS são preenchidos via trigger
			EndIf
		EndIf
	Next nF

	CN300AjSld(oModel,oModel:GetModel('CNADETAIL'):GetValue("CNA_VLTOT"))

	FwRestRows(aSaveLines)
	FwFreeArray(aSaveLines)

	GCTRstWhen(oModCNF, aPropCNF[1])//Restaura submodelo CNF
	RstPropMdl(oModCNF, aPropCNF[2])//Restaura submodelo CNF
	FwFreeArray(aPropCNF)
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} A300SldRec()
Query para verificar se existem item medidos nao recebidos.
retorna o saldo

@author alexandre.gimenez
@since 10/03/2014
@version 1.0
/*/
//----------------------------------±--------------------------------
Static Function A300SldRec(cTipRet,cItem,lFilterPla)
	Local oModel	:= FwModelActive()
	Local cDatReaj	:= DTOS(oModel:GetValue("CN9MASTER","CN9_DTREAJ"))
	Local cFilIt	:= ""
	Local cFilPed	:= ""
	Local cAliasSql := ""
	Local lFixo		:= Cn300RetSt("FIXO",0)
	Local nPos		:= 0
	Local xRet 		:= Nil
	Default lFilterPla := .T.
		
	cFilIt	:= IIF(Empty(cItem)," "," AND CNE.CNE_ITEM = '"+cItem+"'")
	
	If lFixo .And. lFilterPla
		cFilIt +=" AND CNE.CNE_NUMERO = '"+oModel:GetValue("CNADETAIL","CNA_NUMERO")+"'"
	EndIf
	
	If (A300GTpRev() == DEF_REV_REAJU .Or. A300GATpRv() == DEF_REV_REAJU )
		cFilIt += " AND CND.CND_DTFIM  <= '"+cDatReaj+"'"
	EndIf
	
	If(SuperGetMV("MV_CNREVMD",.F.,.T.))
		cFilIt += " AND CND.CND_REVISA = '"+ CnRevAnt(.F., oModel:GetValue("CN9MASTER","CN9_REVISA")) +"'"
	Else
		cFilIt += " AND CND.CND_REVISA IN('"+ oModel:GetValue("CN9MASTER","CN9_REVISA") +"', '"+ CnRevAnt(.F., oModel:GetValue("CN9MASTER","CN9_REVISA")) +"')"	
	EndIf
	
	cFilIt := '%'+cFilIt+'%'
	
	If Cn300RetSt("COMPRA")
		cFilPed := " SELECT SUM(SC7.C7_QUJE) AS C7_QUJE "
		cFilPed += " FROM "+ RetSQLName("SC7") +" SC7 "
		cFilPed += " WHERE "
		cFilPed += " SC7.C7_FILIAL = CND.CND_FILIAL "
		cFilPed += " AND SC7.C7_MEDICAO = CND.CND_NUMMED "
		cFilPed += " AND SC7.D_E_L_E_T_ = ' '"
	Else
		cFilPed := " SELECT SUM(SC6.C6_QTDENT) AS C6_QTDENT "
		cFilPed += " FROM "+ RetSQLName("SC6") +" SC6 "
		cFilPed += " JOIN "+ RetSQLName("SC5") +" SC5 ON SC5.C5_NUM = SC6.C6_NUM "
		cFilPed += " WHERE SC5.C5_FILIAL = CND.CND_FILIAL "
		cFilPed += " AND SC6.C6_FILIAL = SC5.C5_FILIAL "
		cFilPed += " AND SC5.C5_MDNUMED = CND.CND_NUMMED "
		cFilPed += " AND SC5.D_E_L_E_T_ = ' ' "
		cFilPed += " AND SC6.D_E_L_E_T_ = ' ' "
	EndIf
	cFilPed := '%'+ cFilPed + '%'
	
	cAliasSql 	:= GetNextAlias()
	
	BeginSQL Alias cAliasSql
	
		SELECT CND.CND_NUMMED NUMMED,
				CND.CND_PARCEL PARCEL,
				CNE.CNE_NUMERO NUMERO,
				CNE.CNE_ITEM	ITEM,
				CNE.CNE_QUANT QUANT,
				CNE.CNE_VLTOT VLTOT,
				CNE.CNE_VLDESC VLDESC,
				CND.CND_PEDIDO PEDIDO
		FROM %Table:CND% CND
		INNER JOIN %Table:CNE% CNE ON(CNE.CNE_FILIAL = CND.CND_FILIAL AND CNE.CNE_CONTRA = CND.CND_CONTRA AND CNE.CNE_REVISA = CND.CND_REVISA AND CNE.CNE_NUMMED = CND.CND_NUMMED AND CNE.%NotDel%)
	
		WHERE
				CND.CND_FILCTR = %Exp:oModel:GetValue('CN9MASTER','CN9_FILCTR')%
				AND CND.CND_CONTRA = %Exp:oModel:GetValue("CN9MASTER","CN9_NUMERO")%				
				AND CND.CND_PARCEL != %Exp:Space(TamSX3("CND_PARCEL")[1])%			
				AND CND.%NotDel%			
				%Exp:cFilIt%
				AND (%Exp:cFilPed%) = 0
				
		UNION
	
		SELECT CND.CND_NUMMED NUMMED,
				CXN.CXN_PARCEL PARCEL,
				CNE.CNE_NUMERO NUMERO,
				CNE.CNE_ITEM	ITEM,
				CNE.CNE_QUANT QUANT,
				CNE.CNE_VLTOT VLTOT,
				CNE.CNE_VLDESC VLDESC,
				CXJ.CXJ_NUMPED PEDIDO
	
		FROM
				%Table:CND% CND
				
				INNER JOIN %Table:CXN% CXN ON(CXN.CXN_FILIAL = CND.CND_FILIAL AND CXN.CXN_CONTRA = CND.CND_CONTRA 
				AND CXN.CXN_REVISA = CND.CND_REVISA AND CXN.CXN_NUMMED = CND.CND_NUMMED AND CXN.%NotDel%)
				
				INNER JOIN %Table:CNE% CNE ON(CNE.CNE_FILIAL = CXN.CXN_FILIAL AND CNE.CNE_NUMMED = CXN.CXN_NUMMED AND CNE.CNE_CONTRA = CXN.CXN_CONTRA
				AND CNE.CNE_REVISA = CXN.CXN_REVISA AND CNE.CNE_NUMERO = CXN.CXN_NUMPLA AND CNE.%NotDel%)
				
		 	 	INNER JOIN %Table:CXJ% CXJ ON(CXJ.CXJ_FILIAL = CND.CND_FILIAL AND CXJ.CXJ_CONTRA = CND.CND_CONTRA AND CXJ.CXJ_NUMMED = CND.CND_NUMMED
		 	 	AND CXJ.CXJ_NUMPLA = CXN.CXN_NUMPLA AND CXJ.CXJ_ITEMPL = CNE.CNE_ITEM AND CXJ.%NotDel%)
	
		WHERE
				CND.CND_FILCTR = %Exp:oModel:GetValue('CN9MASTER','CN9_FILCTR')%
				AND CND.CND_CONTRA = %Exp:oModel:GetValue("CN9MASTER","CN9_NUMERO")%
				AND CND.%NotDel%			
	
				%Exp:cFilIt%
				AND (%Exp:cFilPed%) = 0
	EndSQL
	
	xRet := IIF(Left(cTipRet,1) == 'n', 0, {})
	
	While (cAliasSql)->(!EOF())
		If cTipRet == 'n' // Soma quantidade
			xRet += (cAliasSql)->QUANT
		ElseIf cTipRet == 'a' .And. !Empty(cItem)// Monta array com parcelas {/*Parcela , Quantidade*/}
			If !Empty(xRet) .And. ( nPos := aScan(xRet,{|x| x[1] == (cAliasSql)->PARCEL }) ) > 0
				xRet[nPos,2] += (cAliasSql)->QUANT
			Else
				aAdd(xRet,{(cAliasSql)->PARCEL,(cAliasSql)->QUANT })
			EndIf
		ElseIf cTipRet == 'a2' //{/*Planilha, NumeroMed, Item*/}
			If(aScan(xRet,{|x| x[1]+x[2]+x[3] == (cAliasSql)->(NUMERO + NUMMED + ITEM)}) == 0)
				aAdd(xRet,{(cAliasSql)->NUMERO,(cAliasSql)->NUMMED,(cAliasSql)->ITEM })				
			EndIf		
		ElseIf cTipRet == 'a3'//{/*Pedido*/}
			If Empty(xRet) .Or. ( nPos := aScan(xRet,(cAliasSql)->PEDIDO ))  == 0
				aAdd(xRet,(cAliasSql)->PEDIDO)
			EndIf
		ElseIf cTipRet == 'a4' // Monta array com parcelas {/*Parcela , valor*/}
			If !Empty(xRet) .And. ( nPos := aScan(xRet,{|x| x[1] == (cAliasSql)->PARCEL }) ) > 0
				xRet[nPos,2] += (cAliasSql)->VLTOT - (cAliasSql)->VLDESC
			Else
				aAdd(xRet,{(cAliasSql)->PARCEL , (cAliasSql)->VLTOT - (cAliasSql)->VLDESC })
			EndIf
		ElseIf cTipRet == 'n2'
			xRet += ((cAliasSql)->VLTOT 	- (cAliasSql)->VLDESC )		
		EndIf
		(cAliasSql)->(DbSkip())
	EndDo	
	(cAliasSql)->(dbCloseArea())

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} cn300BlqLn()
Bloqueia e desbloqueia inserir linhas nos modelos de acordo com a revisão

@author José Eulálio
@since 06/03/2014
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static function cn300BlqLn()
Local oModel 	:= Nil
Local cTpRev	:= A300GTpRev()

If !(cTpRev == DEF_REV_ADITI .Or. cTpRev == DEF_REV_RENOV .Or. cTpRev == DEF_REV_ORCGS .Or. cTpRev == DEF_REV_ABERT)
	oModel 	:= FWModelActive()
	//Bloqueia adição de linhas nos Modelos
	oModel:GetModel('CNADETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('CNBDETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('CNCDETAIL'):SetNoInsertLine(.T.)	
EndIf

Return

//------------------------------------------------------------------
/*/{Protheus.doc} CN300DlPrc()
Função que deleta parcelas do cronograma Financeiro, na revisão de
aditivo ou reajuste.

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function CN300DlPrc(oModel)
Local oCN9Master 	:= oModel:GetModel('CN9MASTER')
Local oCNFDetail 	:= oModel:GetModel('CNFDETAIL')
Local oCNSDetail 	:= oModel:GetModel('CNSDETAIL')
Local nQtdParcs  	:= oCN9Master:GetValue('CN9_QTDPAR')
Local nI    	    := 0
Local nI2    	    := 0
Local aSaveLines	:= FWSaveRows()
Local nNMed      	:= 0
Local nMed			:= 0
Local lRet 			:= .T.
Local aSldFis		:= {}
Local nPos 			:= 0
Local lFisico		:= .F.

For nI := 1 To oCNFDetail:Length()
	oCNFDetail:GoLine(nI)
	If !oCNFDetail:IsDeleted()
		If oCNFDetail:GetValue('CNF_VLREAL') == 0
			nNMed := nNMed + 1
		Else
			nMed := nMed + 1
		EndIf
	EndIf
Next nI

If (nQtdParcs >= nNMed) .And. (nMed == 0)
	Help('',1,'CNT300DCPC')// O número de redução de parcelas não pode ser maior ou igual ao o número de parcelas.
	lRet := .F.
EndIf

If lRet
	oCNFDetail:SetNoDeleteLine(.F.)
	lFisico:= Cn300RetSt("FISICO")	
	For nI := oCNFDetail:Length() To 1 Step -1
		oCNFDetail:GoLine(nI)
		If !oCNFDetail:IsDeleted()

			If nQtdParcs == 0
				Exit
			EndIf

			If oCNFDetail:GetValue('CNF_VLREAL') == 0
				oCNFDetail:DeleteLine()

				nQtdParcs := nQtdParcs - 1

				If lFisico
					For nI2 := 1 To oCNSDetail:Length()
						oCNSDetail:GoLine(nI2)
						oCNSDetail:DeleteLine()
						nPos := Ascan(aSldFis,{|x| x[1] == oCNSDetail:GetValue('CNS_PRODUT')})

						If nPos > 0
							aSldFis[nPos, 2] += oCNSDetail:GetValue('CNS_SLDQTD')
						Else
							Aadd(aSldFis, {oCNSDetail:GetValue('CNS_PRODUT'), oCNSDetail:GetValue('CNS_SLDQTD')})
						EndIf
					Next nI2
				EndIf
			EndIf
		EndIf
	Next nI
	oCNFDetail:SetNoDeleteLine(.T.)

	If Cn300RetSt("SERVIÇO")
		CN300ItSrv(3,oCN9Master:GetValue('CN9_QTDPAR')-nQtdParcs)
    EndIf
EndIf
FWRestRows(aSaveLines)

Return aSldFis

//------------------------------------------------------------------
/*/{Protheus.doc} CNA300RvMd()
Se o parametro lCnRevMd = True, será inserido registro na tabela,
senão será alterado o registro.

@author Taniel Balsanelli
@since 05/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function CNA300RvMd(cContra,cRevisa,cNRevisa,cFilCtr,lExclui)
	Local aAreaCN9	:= CN9->(GetArea())
    Local aAreaCND	:= {}
	Local oModel	:= FwModelActive()
	Local aStruCND	:= {}
	Local aStruCXN	:= {}
	Local aStruCNE	:= {}
	Local aStruCNZ 	:= {}
	Local lCnRevMd	:= SuperGetMV("MV_CNREVMD",.F.,.T.)
	Local lFilCNZ	:= !Empty(xFilial('CNZ'))
    Local lDelMedAnt:= .F.
    Local lDesfRev  := FwIsInCallStack("CNDRPROCES")
	Local oModelCN9 := Nil 
	Local cAliasCND := GetNextAlias()
	Local cAliasTemp:= ""
	Local cObsCND	:= ""
	Local oQueryCND := Nil
	Local oQueryCXN := Nil
	Local oQueryCNE := Nil
	Local oQueryCNZ := Nil
	Local nTotRev   := 0
	Local cIdX2CND	:= AllTrim(FWX2Unico('CND'))	
	Local cOldCodEnt:= ""
	Local cCodEnt	:= ""
	Local lGetDoc	:= .F.
	Default lExclui := (oModel:GetOperation() == MODEL_OPERATION_DELETE) 
	
	If !lDesfRev
		oModelCN9 := oModel:GetModel('CN9MASTER')
		CN9->(dbSetOrder(1))
		CN9->(dbSeek(oModelCN9:GetValue('CN9_FILIAL')+oModelCN9:GetValue('CN9_NUMERO')))
	EndIf
	
	Default cFilCtr := CN9->CN9_FILCTR
	
	//- Seleciona medições que devem ser alteradas.
	cQuery := "SELECT CND.*,CND.R_E_C_N_O_ as RECNO "
	cQuery += " FROM "+ RetSQLName("CND") +" CND "
	cQuery += " WHERE CND.CND_FILCTR 	= '"+cFilCtr+"'"
	cQuery += " AND CND.CND_CONTRA 		= '"+cContra+"'"
	cQuery += " AND CND.D_E_L_E_T_		= ' '"
    
    If lExclui .And. lDesfRev //-- Quando exclusão deve retornar a medição da revisão anterior
        cQuery += " AND CND.CND_REVISA	IN('"+cRevisa+"','"+cNRevisa+"')"
        cQuery += " ORDER BY CND_CONTRA, CND_NUMMED, CND_REVISA ASC "
    Else
	    cQuery += " AND CND.CND_REVISA 	= '"+IIF(lExclui,cNRevisa,cRevisa)+"'"
    EndIf

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cAliasCND, .F., .F. )
	
	If(!lExclui .And. lCnRevMd)		
		ConFldsTab(cAliasCND, "CND", aStruCND) //Configura os campos da tabela CND em <cAliasCND>
	EndIf

	//Revisão da tabela CND	
	While !(cAliasCND)->(Eof())
		CND->(dbGoto((cAliasCND)->RECNO))
		
        If lExclui .And. lDesfRev
            If oQueryCND == Nil //-- Seleciona a medição atual e a anterior
                cQuery := "SELECT CND.R_E_C_N_O_ as RECNO "
                cQuery += " FROM "+ RetSQLName("CND") +" CND "
                cQuery += " WHERE CND.CND_FILCTR = ?"
                cQuery += " AND CND.CND_NUMMED   = ?"
                cQuery += " AND CND.CND_CONTRA   = ?"
                cQuery += " AND CND.CND_REVISA   IN(?, ?)"
                cQuery += " AND CND.D_E_L_E_T_	 = ' '"
                cQuery += " ORDER BY CND_REVISA ASC" //-- Retorna primeiro a medição anterior

                oQueryCND := FWPreparedStatement():New(ChangeQuery( cQuery ))
            EndIf
            cAliasTemp := GetNextAlias()

            oQueryCND:SetString(1,CND->CND_FILCTR)
            oQueryCND:SetString(2,CND->CND_NUMMED)
            oQueryCND:SetString(3,CND->CND_CONTRA)
            oQueryCND:SetString(4,cRevisa)  //-- Revisão anterior
            oQueryCND:SetString(5,cNRevisa) //-- Revisão atual
            
            dbUseArea( .T., "TopConn", TCGenQry(,, oQueryCND:getFixQuery()), cAliasTemp, .F., .F. )

            If !(cAliasTemp)->(Eof())
                Count To nTotRev //-- Conta a quantidade de registros retornados pela query
                (cAliasTemp)->(DbGoTop())
                aAreaCND := CND->(GetArea())
                CND->(dbGoTo((cAliasTemp)->RECNO))

                If nTotRev == 1 .And. CND->CND_REVISA != cNRevisa//-- Estorna medição anterior caso a medição atual esteja deletada
                    lDelMedAnt := EstMedRev()
                EndIf

                RestArea(aAreaCND)
            EndIf
            (cAliasTemp)->(dbCloseArea())
        
            If CND->CND_REVISA != cNRevisa .And. !lDelMedAnt //-- Exclui apenas os registros da revião atual, exceto quando lDelMedAnt igual a .T.
                nTotRev := 0
                (cAliasCND)->(dbSkip())
                Loop
            EndIf
        EndIf

		lGetDoc := .F.
        If lExclui            
			RecLock("CND", .F.)
            If lCnRevMd .Or. nTotRev > 1 .Or. lDelMedAnt
                CND->(dbDelete())				
            Else
				lGetDoc		:= .T.
				cOldCodEnt	:= CND->(&(cIdX2CND)) //Pega o identificador com a revisão anterior				
                CND->CND_REVISA := cRevisa
            EndIf			
			CND->(MsUnlock())
        Else			
            If lCnRevMd
                cObsCND := CND->CND_OBS //Campo Memo não retornado em <cAliasCND>				
                RecLock("CND",.T.)
                CopiaReg("CND", cAliasCND, aStruCND)
                CND->CND_OBS := cObsCND //Grava o campo memo <CND_OBS>
            Else				
				lGetDoc		:= .T.
				cOldCodEnt	:= CND->(&(cIdX2CND)) //Pega o identificador com a revisão anterior				
                RecLock("CND",.F.)
            EndIf
            CND->CND_REVISA := cNRevisa
        	CND->(MsUnlock())
        EndIf

		IF(lGetDoc)
			cCodEnt := CND->(&(cIdX2CND)) //Pega o identificador com a revisão atualizada
			UpdBCMed(cOldCodEnt, cCodEnt) //Atualiza base de conhecimento da medição
		EndIf

        If (oQueryCXN == Nil)			
            cQuery := " SELECT CXN.*,CXN.R_E_C_N_O_ as RECNO "
            cQuery += " FROM "+RetSQLName("CXN")+" CXN "
            cQuery += " WHERE CXN.CXN_FILIAL 	= ?"
            cQuery += " AND CXN.CXN_CONTRA 		= ?"
            cQuery += " AND CXN.CXN_REVISA 		= ?"
            cQuery += " AND CXN.CXN_NUMMED 		= ?"
            cQuery += " AND CXN.D_E_L_E_T_ 		= ' '"

            oQueryCXN := FWPreparedStatement():New(ChangeQuery( cQuery ))
        Endif
        cAliasTemp := GetNextAlias()

        oQueryCXN:SetString(1,(cAliasCND)->CND_FILIAL)
        oQueryCXN:SetString(2,cContra)

        If lDelMedAnt
            oQueryCXN:SetString(3,(cAliasCND)->CND_REVISA)
        Else
            oQueryCXN:SetString(3,IIF(lExclui,cNRevisa,cRevisa))
        EndIf

        oQueryCXN:SetString(4,(cAliasCND)->CND_NUMMED)

        dbUseArea( .T., "TopConn", TCGenQry(,,oQueryCXN:getFixQuery()), cAliasTemp, .F., .F. )		
        If(!lExclui .And. lCnRevMd)		
            ConFldsTab(cAliasTemp, "CXN", aStruCXN) //Configura os campos da tabela CXN em <cAliasTemp>
        EndIf
        
        While !(cAliasTemp)->(EOF())
            CXN->(dbGoto((cAliasTemp)->RECNO))	
            If lExclui
                RecLock("CXN",.F.)
                If lCnRevMd .Or. nTotRev > 1 .Or. lDelMedAnt
                    CXN->(dbDelete())
                Else
                    CXN->CXN_REVISA := cRevisa
                EndIf
            Else
                RecLock("CXN", lCnRevMd)					
                If lCnRevMd
                    CopiaReg("CXN", cAliasTemp, aStruCXN)
                EndIf
                CXN->CXN_REVISA := cNRevisa
            EndIf
            CXN->(MsUnlock())
    
            (cAliasTemp)->(dbSkip())
        EndDo
        (cAliasTemp)->(dbCloseArea())
    

        If (oQueryCNE == Nil)			
            cQuery := " SELECT CNE.*,CNE.R_E_C_N_O_ as RECNO "
            cQuery += " FROM "+RetSQLName("CNE")+" CNE "
            cQuery += " WHERE CNE.CNE_FILIAL = ?"
            cQuery += " AND CNE.CNE_CONTRA = ?"
            cQuery += " AND CNE.CNE_REVISA = ?"
            cQuery += " AND CNE.CNE_NUMMED = ?"
            cQuery += " AND CNE.D_E_L_E_T_ = ' '"

            oQueryCNE := FWPreparedStatement():New(ChangeQuery( cQuery ))
        Endif

        oQueryCNE:SetString(1,(cAliasCND)->CND_FILIAL)
        oQueryCNE:SetString(2,cContra)

        If lDelMedAnt
            oQueryCNE:SetString(3,(cAliasCND)->CND_REVISA)
        Else
            oQueryCNE:SetString(3,IIF(lExclui,cNRevisa,cRevisa))
        EndIf
        
        oQueryCNE:SetString(4,(cAliasCND)->CND_NUMMED)

        dbUseArea( .T., "TopConn", TCGenQry(,,oQueryCNE:getFixQuery()), cAliasTemp, .F., .F. )
        
        If(!lExclui .And. lCnRevMd)		
            ConFldsTab(cAliasTemp, "CNE", aStruCNE) //Configura os campos da tabela CNE em <cAliasTemp>
        EndIf
        
        While !(cAliasTemp)->(EOF())
            CNE->(dbGoto((cAliasTemp)->RECNO))
            If lExclui
                RecLock("CNE",.F.)
                If lCnRevMd .Or. nTotRev > 1 .Or. lDelMedAnt
                    CNE->(dbDelete())
                Else
                    CNE->CNE_REVISA := cRevisa
                EndIf
            Else
                RecLock("CNE", lCnRevMd)
                If lCnRevMd
                    CopiaReg("CNE", cAliasTemp, aStruCNE)
                EndIf
                CNE->CNE_REVISA := cNRevisa
            EndIf
            CNE->(MsUnlock())
            (cAliasTemp)->(dbSkip())
        EndDo
        (cAliasTemp)->(dbCloseArea())	

        If (oQueryCNZ == Nil)			
            cQuery := "SELECT CNZ.*,CNZ.R_E_C_N_O_ as RECNO "
            cQuery += " FROM "+RetSQLName("CNZ")+" CNZ "
            cQuery += " WHERE "
            cQuery += " CNZ.CNZ_CONTRA 		= ?"
            cQuery += " AND CNZ.CNZ_REVISA 	= ?"
            cQuery += " AND CNZ.CNZ_NUMMED 	= ?"
            cQuery += " AND CNZ.D_E_L_E_T_ 	= ' '"

            If lFilCNZ //- Gestão corporativa
                cQuery += " AND CNZ.CNZ_FILIAL 	= ?"
            EndIf

            oQueryCNZ := FWPreparedStatement():New(ChangeQuery( cQuery ))
        EndIf

        oQueryCNZ:SetString(1,cContra)

        If lDelMedAnt
            oQueryCNZ:SetString(2,(cAliasCND)->CND_REVISA)
        Else
            oQueryCNZ:SetString(2,IIF(lExclui,cNRevisa,cRevisa))
        EndIf

        oQueryCNZ:SetString(3,(cAliasCND)->CND_NUMMED)		
        If lFilCNZ//- Gestão corporativa
            oQueryCNZ:SetString(4,(cAliasCND)->CND_FILIAL)			
        EndIf		

        dbUseArea( .T., "TopConn", TCGenQry(,,oQueryCNZ:getFixQuery()), cAliasTemp, .F., .F. )
    
        If(!lExclui .And. lCnRevMd)		
            ConFldsTab(cAliasTemp, "CNZ", aStruCNZ) //Configura os campos da tabela CNZ em <cAliasTemp>
        EndIf
        
        While !(cAliasTemp)->(EOF())
            CNZ->(dbGoto((cAliasTemp)->RECNO))
            If lExclui
                RecLock("CNZ",.F.)
                If lCnRevMd .Or. nTotRev > 1 .Or. lDelMedAnt
                    CNZ->(dbDelete())
                Else				
                    CNZ->CNZ_REVISA := cRevisa
                EndIf
            Else
                RecLock("CNZ", lCnRevMd)
                If lCnRevMd
                    CopiaReg("CNZ", cAliasTemp, aStruCNZ)
                EndIf
                CNZ->CNZ_REVISA := cNRevisa
            EndIf
            CNZ->(MsUnlock())
            (cAliasTemp)->(dbSkip())
        EndDo
        (cAliasTemp)->(dbCloseArea())
    
        //Revisão dos Pedidos gerados
        If lExclui
            If !lDelMedAnt
                CNA300RvPd(cContra,cNRevisa,cRevisa,(cAliasCND)->CND_FILIAL)
            EndIf
        Else
            CNA300RvPd(cContra,cRevisa,cNRevisa,(cAliasCND)->CND_FILIAL)
        EndIf
            
        nTotRev := 0
        lDelMedAnt := .F.
        (cAliasCND)->(dbSkip())
	EndDo
	(cAliasCND)->(dbCloseArea())
	
	If (oQueryCND != Nil)
		oQueryCND:Destroy() //Destroi objeto
	EndIf
	If (oQueryCXN != Nil)
		oQueryCXN:Destroy() //Destroi objeto	
	EndIf
	If (oQueryCNE != Nil)
		oQueryCNE:Destroy() //Destroi objeto		
	EndIf
	If (oQueryCNZ != Nil)
		oQueryCNZ:Destroy() //Destroi objeto		
	EndIf

	CN9->(RestArea(aAreaCN9))
Return Nil

//------------------------------------------------------------------
/*/{Protheus.doc} CNA300RvPd()
Atualiza numero da revisão do pedido gerado pela medição na revisão
de contratos

@author Israel Escorizza
@since 02/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CNA300RvPd(cContra,cRevisa,cNRevisa,cFilMed)
Local cQuery := ""
Default cContra	:= ""
Default cRevisa	:= ""
Default cNRevisa	:= ""
Default cFilMed	:= ""

cQuery := "UPDATE "+ RetSqlName("SC7") + " SET C7_CONTREV='"+ cNRevisa +"'"
cQuery += " WHERE D_E_L_E_T_ = ' ' AND C7_FILIAL='"+cFilMed+"' AND C7_CONTRA='"+cContra+"' AND C7_CONTREV='"+cRevisa+"'"
TcSqlExec(cQuery)// --Ajusta campo de revisao dos pedidos de compra

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} a300dtAniv()
Atualiza a data de aniversário dos itens da planilha inclusos durante uma revisão

@author José eulálio
@since 28/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function a300dtAniv(oModelCNB)

If Empty(oModelCNB:GetValue('CNB_DTANIV'))				
	oModelCNB:LoadValue('CNB_DTANIV',dDataBase)				
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VdArr()
Validações nos campos CN9_ARRAST (valid)
que deverão ser consideradas na revisão de realinhamento, aditivo de prazo e quantidade/prazo

@author Antenor Silva
@since 27/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function CN300VdArr()
Local oModel		:= FWModelActive()
Local oStruCN9 	:= oModel:GetModel('CN9MASTER'):GetStruct()
Local oModelCN9	:= oModel:GetModel('CN9MASTER')
Local lRet			:= .T.
Local cTipRevisa 	:= A300GTpRev()

If !Empty(A300GTpRev())
	If (cTipRevisa == DEF_REV_ADITI .Or. cTipRevisa == DEF_REV_REALI .Or. cTipRevisa == DEF_REV_READE .Or. cTipRevisa == DEF_REV_REINI .Or. cTipRevisa == DEF_REV_RENOV .Or. cTipRevisa == DEF_REV_ORCGS .Or. cTipRevisa == DEF_REV_ABERT)
		If oModelCN9:GetValue('CN9_ARRAST') == "2"
			oStruCN9:SetProperty('CN9_REDVAL',MODEL_FIELD_WHEN,{||.T.})
			oModelCN9:SetValue('CN9_REDVAL',"2")
			oStruCN9:SetProperty('CN9_REDVAL',MODEL_FIELD_WHEN,{||.F.})
		Else
			oStruCN9:SetProperty('CN9_REDVAL',MODEL_FIELD_WHEN,{||.T.})
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VArrC()
Validações no campo CN9_ARRASC (valid)
que deverão ser consideradas na revisão de realinhamento, aditivo de prazo e quantidade/prazo

@author jose.delmondes
@since 15/02/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static function CN300VArrC()
Local oModel		:= FWModelActive()
Local oStruCN9 		:= oModel:GetModel('CN9MASTER'):GetStruct()
Local oModelCN9		:= oModel:GetModel('CN9MASTER')
Local lRet			:= .T.
Local cTipRevisa 	:= A300GTpRev()
Local lContabil		:= Cn300RetSt("CONTABIL",2)

If !Empty(cTipRevisa) .And. lContabil
	If (cTipRevisa == DEF_REV_ADITI .Or. cTipRevisa == DEF_REV_REALI .Or. cTipRevisa == DEF_REV_READE .Or. cTipRevisa == DEF_REV_REINI .Or. cTipRevisa == DEF_REV_ABERT)
		If oModelCN9:GetValue('CN9_ARRASC') == "2"
			oModelCN9:SetValue('CN9_REDVAC',"2")
			oStruCN9:SetProperty('CN9_REDVAC',MODEL_FIELD_WHEN,{||.F.})
		Else
			oStruCN9:SetProperty('CN9_REDVAC',MODEL_FIELD_WHEN,{||.T.})
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300CalRat()
Função que atualiza os campos do Valor do Rateio do itens da planilha

@param oModelCNZ, Submodelo da CNZ (Cuja CNB pai já esteja posicionada)
@param nVlTotCNB, Valor total da planilha (CNB)

@author antenor.silva
@since 25/02/2014
@version 1.0
/*/
//----------------------------------±--------------------------------
Static function  A300CalRat( oModelCNZ, nVlTotCNB )
	Local nPerc := 0
	Local nZ := 0
	Local nValPerc := 0
	Default oModelCNZ := Nil
	Default nVlTotCNB := 0
	
	If oModelCNZ <> Nil
		For nZ := 1 To oModelCNZ:Length()
			oModelCNZ:GoLine( nZ )
			If (!oModelCNZ:IsDeleted() .And. !Empty(oModelCNZ:GetValue("CNZ_PERC")))
				nPerc := oModelCNZ:GetValue( "CNZ_PERC" )
				nValPerc := (nPerc * nVlTotCNB) / 100
				oModelCNZ:SetValue( "CNZ_VALOR1", nValPerc )
				oModelCNZ:SetValue( "CNZ_VALOR2", xMoeda( nValPerc, 1, 2, dDatabase ) )
				oModelCNZ:SetValue( "CNZ_VALOR3", xMoeda( nValPerc, 1, 3, dDatabase ) )
				oModelCNZ:SetValue( "CNZ_VALOR4", xMoeda( nValPerc, 1, 4, dDatabase ) )
				oModelCNZ:SetValue( "CNZ_VALOR5", xMoeda( nValPerc, 1, 5, dDatabase ) )
			EndIf
		Next nZ
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} A300CalSum()
Calcular a soma(CNB_QTRDAC) – soma(CNB_QTRDRZ) em qualquer alteração CNB
e atualizar os valores de rateio dos itens da planilha

@author antenor.silva
@since 25/02/2014
@version 1.0
/*/
//----------------------------------±--------------------------------
Static function A300CalSum(oModel, cRevAnt)
	Local aAreas	:= {CNB->(GetArea()), GetArea()}
	Local oModelCN9	:= oModel:GetModel('CN9MASTER')
	Local oModelCNB	:= oModel:GetModel('CNBDETAIL')
	Local oModelCNZ	:= oModel:GetModel('CNZDETAIL')	
	Local lLineIns	:= .F.
	Local lExiste	:= .F.
	Local nSldMed	:= 0
	Local nSldRec	:= 0
	Local lAcrescimo	:= .F.
	Local lDecrescimo	:= .F.
	Local lEmRevisao 	:= oModelCN9:GetValue("CN9_SITUAC")==DEF_SREVS
	Local lItemAddRV	:= .F.
	Local nAcresc	:= 0
	Local nDecresc	:= 0
	Local nQtdAtual	:= 0
	Local nTamCpo	:= 0
	Default cRevAnt	:= CnRevAnt()

	dbSelectArea("CNB")
	CNB->(dbSetOrder(1))

	lLineIns := oModelCNB:IsInserted()
	lExiste := CNB->(dbSeek(xFilial("CNB")+oModelCNB:GetValue('CNB_CONTRA')+cRevAnt+oModelCNB:GetValue('CNB_NUMERO')+oModelCNB:GetValue('CNB_ITEM')))

	lItemAddRV := ((oModelCNB:GetOperation() == MODEL_OPERATION_UPDATE .And. !lExiste) .Or. lLineIns)
	
	If lEmRevisao .And. lItemAddRV //Se em revisão e o item foi adicionado na revisão atual, iguala saldos a quantidade
		nQtdAtual := oModelCNB:GetValue('CNB_QUANT')

		aEval({'CNB_SLDMED','CNB_SLDREC','CNB_QTDORI'}, {|x| oModelCNB:SetValue(x, nQtdAtual) })

		oModelCNB:SetValue("CNB_QTRDAC"	, 0)//Novos itens tem quantidade acrescida zerada
		oModelCNB:SetValue("CNB_QTRDRZ"	, 0)//Novos itens tem quantidade reduzida zerada
	Else
		If (lExiste)
			nSldMed := CNB->CNB_SLDMED
			nSldRec := CNB->CNB_SLDREC
		Else
			nSldMed := oModelCNB:GetValue("CNB_SLDMED")
			nSldRec := oModelCNB:GetValue("CNB_SLDREC")
		EndIf
		
		lDecrescimo	:= oModelCNB:GetValue("CNB_QUANT") < oModelCNB:GetValue("CNB_QTDORI")
		lAcrescimo 	:= oModelCNB:GetValue("CNB_QUANT") > oModelCNB:GetValue("CNB_QTDORI")

		If lDecrescimo
			nAcresc	:= 0
			nDecresc:= oModelCNB:GetValue("CNB_QTDORI") - oModelCNB:GetValue("CNB_QUANT")
			
			nTamCpo := GetSX3Cache('CNB_QTRDRZ', 'X3_DECIMAL')
			nDecresc:= NoRound(nDecresc, nTamCpo)
		ElseIf lAcrescimo
			nAcresc	:= oModelCNB:GetValue("CNB_QUANT") - oModelCNB:GetValue("CNB_QTDORI")
			nDecresc:= 0
			
			nTamCpo := GetSX3Cache('CNB_QTRDAC', 'X3_DECIMAL')
			nAcresc := NoRound(nAcresc, nTamCpo)
		EndIf
		oModelCNB:SetValue("CNB_QTRDAC"	, nAcresc)
		oModelCNB:SetValue("CNB_QTRDRZ"	, nDecresc)
		If (lDecrescimo .And. oModelCNB:GetValue("CNB_SLDMED") > 0)
			If !(lLineIns .Or. !lExiste)
				nSldMed -= oModelCNB:GetValue("CNB_QTRDRZ")
				nSldRec -= oModelCNB:GetValue("CNB_QTRDRZ")
			EndIf
			nSldMed := Max(0,nSldMed)//Garante que não haverá valores negativos
			nSldRec := Max(0,nSldRec)//Garante que não haverá valores negativos

			oModelCNB:SetValue("CNB_SLDMED",nSldMed)
			oModelCNB:SetValue("CNB_SLDREC",nSldRec)
		ElseIf lAcrescimo .And. lExiste			
			nSldMed += oModelCNB:GetValue("CNB_QTRDAC")
			nSldRec += oModelCNB:GetValue("CNB_QTRDAC")

			nTamCpo := GetSX3Cache('CNB_SLDMED', 'X3_DECIMAL')
			oModelCNB:SetValue("CNB_SLDMED", NoRound(nSldMed,nTamCpo))

			nTamCpo := GetSX3Cache('CNB_SLDREC', 'X3_DECIMAL')
			oModelCNB:SetValue("CNB_SLDREC", NoRound(nSldRec,nTamCpo))
		EndIf
		
	EndIf
	
	A300CalRat( oModelCNZ, oModelCNB:GetValue("CNB_VLTOT") )//Tratamentos para o rateio do item 

	aEval(aAreas, {|x| RestArea(x) })
	FwFreeArray(aAreas)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} A300CalcVl()
Calcula o valor adicionado ou reduzido no caso de aditivo, readequamento - (qtde)
O mesmo conceito se aplica as funções de valor, ao alterar o cnb_vlunit – calcular o valor reajustado, aditivado ou realinhado

@author antenor.silva
@since 25/02/2014
@version 1.0
/*/
//----------------------------------±--------------------------------
Static function  A300CalcVl( oModelCNB )
	Local lRet := .T.
	Local cTipRev := A300GTpRev()
	Local nCNBQuant := 0
	Local nCNBQtOri := 0
	
	If !Empty(cTipRev)
		nCNBQuant := oModelCNB:GetValue("CNB_QUANT")
		nCNBQtOri := oModelCNB:GetValue("CNB_QTDORI")
		
		If cTipRev == DEF_REV_ADITI
			If nCNBQuant < nCNBQtOri //se for decréscimo
				oModelCNB:LoadValue( "CNB_QTRDRZ", nCNBQtOri - nCNBQuant )
				oModelCNB:LoadValue( "CNB_QTRDAC", 0 )
			Else //se for acréscimo
				oModelCNB:LoadValue( "CNB_QTRDAC", nCNBQuant - nCNBQtOri )
				oModelCNB:LoadValue( "CNB_QTRDRZ", 0 )
			EndIf
	
		ElseIf cTipRev == DEF_REV_READE //tipo readequação
			oModelCNB:SetValue( "CNB_QTREAD", nCNBQuant - nCNBQtOri )
			oModelCNB:SetValue( "CNB_SLDMED", oModelCNB:GetValue("CNB_SLDMED") + (nCNBQuant - nCNBQtOri) )
			oModelCNB:SetValue( "CNB_SLDREC", oModelCNB:GetValue("CNB_SLDREC") + (nCNBQuant - nCNBQtOri) )
	
		ElseIf cTipRev == DEF_REV_REALI //tipo realinhamento
			oModelCNB:SetValue( "CNB_REALI", oModelCNB:GetValue("CNB_VLUNIT") - oModelCNB:GetValue("CNB_PRCORI") )
			oModelCNB:SetValue( "CNB_VLTOTR", nCNBQtOri * oModelCNB:GetValue("CNB_REALI") )
			oModelCNB:SetValue( "CNB_DTREAL", dDataBase )
	
		ElseIf cTipRev == DEF_REV_RENOV .Or. cTipRev == DEF_REV_ORCGS //- Tipo Renovação / Orçamento Serviços GS
			//Tratamento dos Aditivos
			If nCNBQuant < nCNBQtOri //se for decréscimo
				oModelCNB:LoadValue( "CNB_QTRDRZ", nCNBQtOri - nCNBQuant )
				oModelCNB:LoadValue( "CNB_QTRDAC", 0 )
			Else //se for acréscimo
				oModelCNB:LoadValue( "CNB_QTRDAC", nCNBQuant - nCNBQtOri )
				oModelCNB:LoadValue( "CNB_QTRDRZ", 0 )
			EndIf
		ElseIf cTipRev == DEF_REV_ABERT //- Tipo Aberta
			If nCNBQuant < nCNBQtOri //se for decréscimo
				oModelCNB:LoadValue( "CNB_QTRDRZ", nCNBQtOri - nCNBQuant )
				oModelCNB:LoadValue( "CNB_QTRDAC", 0 )
			Else //se for acréscimo
				oModelCNB:LoadValue( "CNB_QTRDAC", nCNBQuant - nCNBQtOri )
				oModelCNB:LoadValue( "CNB_QTRDRZ", 0 )
			EndIf			
			oModelCNB:SetValue( "CNB_REALI"	, oModelCNB:GetValue("CNB_VLUNIT") - oModelCNB:GetValue("CNB_PRCORI") )
			oModelCNB:SetValue( "CNB_VLTOTR", nCNBQtOri * oModelCNB:GetValue("CNB_REALI") )
			oModelCNB:SetValue( "CNB_DTREAL", dDataBase )
		EndIf		
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VlBas()
Valida base instalada no Gestao de Servicos

@author aline.sebrian
@since 27/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function CN300VlBas()
Local lRet := .T.
Local oModel     := FwModelActive()
Local oModelCNB  := oModel:GetModel("CNBDETAIL")

If oModelCNB:GetValue("CNB_BASINS") == '1' .And. oModelCNB:GetValue("CNB_QTDMED")>0
	Help( " ", 1, "CN300NBASE") //Este item não poderá gerar base instalada pois já foi movimentado.
	lRet := .F.
Else
	If CNB->CNB_GERBIN == '1'
		Help( " ", 1, "CN300GBASE") //Este item da planilha já gerou base instalada e por isso este campo não pode ser alterado.
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} cn300AprPl(oModel,oModelCN8)
Libera equipamentos dos itens do contrato que foram removidos:
 processo de troca ou substituicao.

@author aline.sebrian
@since 24/02/2014
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static function cn300AprPl(cContra,cRev)
	Local oModel     := Nil
	Local oModelCNA  := Nil
	Local oModelCNB  := Nil
	Local cPlanil    := ""
	Local lCNINTFS   := SuperGetMV("MV_CNINTFS",.F.,.F.)
	Local cTipRev	   := A300GATpRv()

	If lCNINTFS .And. ( cTipRev == DEF_REV_ADITI .Or. cTipRev == DEF_REV_RENOV .Or. cTipRev == DEF_REV_ORCGS .Or. cTipRev == DEF_REV_ABERT)
		
		oModel := FwModelActive()		

		If (ValType(oModel) == "O" .And. (oModel:IsActive() .And. oModel:GetId() $ 'CNTA300|CNTA301'))
			oModelCNA  := oModel:GetModel("CNADETAIL")
			oModelCNB  := oModel:GetModel("CNBDETAIL")
			cPlanil := oModelCNA:GetValue("CNA_NUMERO")
			cn300AdtFS(cContra,cRev,cPlanil,oModelCNB)			
		EndIf
	EndIf
Return

//------------------------------------------------------------------
/*/{Protheus.doc} A300AtuCrF()
Função para atualizar cronograma fisico

@author alexandre.gimenez
@since 05/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A300AtuCrF(oModel,nQuant,aQntMed,nLinha,nLineOri)
Local oModCNB	:= oModel:GetModel("CNBDETAIL")
Local oModCNF	:= oModel:GetModel("CNFDETAIL")
Local oModCNS	:= oModel:GetModel("CNSDETAIL")
Local nSomaCNS	:= 0
Local nNewSum	:= 0
Local nOldVlr	:= 0
Local nDif		:= 0
Local nX		:= 0
Local nPos		:= 0
Local lRevMed 	:= A300RevMed(0)
Local aSaveLines:= FWSaveRows()
Local nY		:= 0
Local nPosCNS	:= 0
Local nValCNS	:= 0

Default nLineOri := nLinha

oModCNS:GetStruct():SetProperty("CNS_PRVQTD",MODEL_FIELD_WHEN,{||.T.})
oModCNS:GetStruct():SetProperty("CNS_DISTSL",MODEL_FIELD_WHEN,{||.T.})
oModCNS:GetStruct():SetProperty("CNS_SLDQTD",MODEL_FIELD_WHEN,{||.T.})
oModCNF:GetStruct():SetProperty("*",MODEL_FIELD_WHEN,{||.T.})

//Soma CNS
For nX := 1 to oModCNF:Length()
	oModCNF:GoLine(nX)
	If !oModCNF:IsDeleted() .And. oModCNS:Length() >= nLinha .And. oModCNS:GoLine(nLinha) == nLinha
		nSomaCNS += oModCNS:GetValue("CNS_PRVQTD",nLineOri)
	EndIf
Next nX

//Atualiza CNS
For nX := 1 to oModCNF:Length()
	nValCNS := 0
	oModCNF:GoLine(nX)
	If !oModCNF:IsDeleted() .And. oModCNS:Length() >= nLinha .And. oModCNS:GoLine(nLinha) == nLinha
		//Atualizar valor medido
		If lRevMed
			nPos := aScan(aQntMed,{|x| x[1] == oModCNS:GetValue("CNS_PARCEL") })
			QtdeRec := If(nPos > 0,aQntMed[nPos,2],0)

			oModCNS:GoLine(nLineOri)
			If (oModCNS:GetValue("CNS_RLZQTD") - QtdeRec) < oModCNS:GetValue("CNS_PRVQTD")
				oModCNF:SetNoUpdateLine(.F.)

				oModCNB:GoLine(nLinha)
				If nLineOri <> nLinha
					oModCNS:GoLine(nLineOri)
					nAux := oModCNS:GetValue("CNS_PRVQTD") - oModCNS:GetValue("CNS_RLZQTD") + QtdeRec

					oModCNS:GoLine(nLinha)
					oModCNS:LoadValue("CNS_RLZQTD",QtdeRec)
					oModCNF:LoadValue("CNF_VLREAL",(QtdeRec * oModCNB:GetValue("CNB_VLUNIT")) * (1 - (oModCNB:GetValue("CNB_DESC")/100)))
					oModCNS:SetValue("CNS_PRVQTD",nAux)
				Else
					nAux 	:= oModCNS:GetValue("CNS_RLZQTD") - QtdeRec
					nOldVlr := oModCNS:GetValue("CNS_PRVQTD")

					oModCNS:LoadValue("CNS_RLZQTD",nAux)

					nPosCNS:= oModCNS:GetLine()
					For nY := 1 To oModCNS:Length()
						oModCNS:GoLine(nY)
						nValCNS += oModCNS:GetValue('CNS_RLZQTD') * oModCNB:GetValue("CNB_VLUNIT",nY)
					Next
					oModCNF:SetValue("CNF_VLREAL",nValCNS)
					oModCNS:GoLine(nPosCNS)

					oModCNS:SetValue("CNS_PRVQTD",nAux)

				EndIf
				nNewSum += oModCNS:GetValue("CNS_PRVQTD")
			ElseIf nLineOri == nLinha
				nNewSum += oModCNS:GetValue("CNS_PRVQTD")
			EndIf
		Else
			If nLineOri <> nLinha
				oModCNS:LoadValue("CNS_RLZQTD",0)
				If oModCNS:GetValue("CNS_PRVQTD",nLineOri) > oModCNS:GetValue("CNS_RLZQTD",nLineOri)
					oModCNS:SetValue("CNS_PRVQTD",oModCNS:GetValue("CNS_PRVQTD",nLineOri) - oModCNS:GetValue("CNS_RLZQTD",nLineOri))
				Else
					oModCNS:SetValue("CNS_PRVQTD",0)
				EndIf
			ElseIf oModCNS:GetValue("CNS_PRVQTD") > oModCNS:GetValue("CNS_RLZQTD")
				nOldVlr := oModCNS:GetValue("CNS_PRVQTD")
				oModCNS:SetValue("CNS_PRVQTD",oModCNS:GetValue("CNS_RLZQTD"))

			EndIf
			nNewSum += oModCNS:GetValue("CNS_PRVQTD")
		EndIf
	EndIf
Next nX

//Arredonda
If nNewSum <> nQuant
	nDif := Round(nQuant - nNewSum,TamSX3('CNS_PRVQTD')[2])
	For nX := oModCNF:Length() to 1 step -1
		oModCNF:GoLine(nX)
		If !oModCNF:IsDeleted()
			oModCNS:GoLine(nLinha)
			oModCNS:SetValue("CNS_PRVQTD",oModCNS:GetValue("CNS_PRVQTD")+nDif)
			Exit
		EndIf
	Next nX
EndIf

oModCNS:GetStruct():SetProperty("CNS_PRVQTD",MODEL_FIELD_WHEN,{||.F.})
oModCNS:GetStruct():SetProperty("CNS_DISTSL",MODEL_FIELD_WHEN,{||.F.})
oModCNS:GetStruct():SetProperty("CNS_SLDQTD",MODEL_FIELD_WHEN,{||.F.})


FWRestRows(aSaveLines)
Return .T.

//------------------------------------------------------------------
/*/{Protheus.doc} ReajCrgFin()
Função para reajustar cronograma financeiro

@author alexandre.gimenez
@since 27/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReajCrgFin(oModel,nVlrReaj,lFisico)
	Local oModCNF	:= oModel:GetModel("CNFDETAIL")
	Local nX		:= 0
	Local nSldFin	:= 0
	Local nPercRj	:= 0
	Local nVlrRjP	:= 0
	Local nTotCro	:= 0
	Local nTotPla	:= oModel:getModel("CNADETAIL"):GetValue("CNA_VLTOT")
	Local nLine	:= oModCNF:Length()
	Local nPos		:= 0
	Local aSaveLines	:= FWSaveRows()
	Local aVlrMed	:= {}
	Local lReajMed	:= Cn300RetSt("REVREAJU")
	Local nJuros	:= 0
	Local lVlPreFin := ValPresFin(oModel:GetModel("CN9MASTER"), @nJuros)
	Local lResult 	:= .T.
	Default lFisico := .F.

	//-- Calcula Saldo da Planilha
	For nX:= 1 To nLine
		oModCNF:GoLine(nX)
		If !oModCNF:IsDeleted()
			nSldFin += oModCNF:GetValue("CNF_SALDO")
		EndIf
	Next nX

	//Valores medidos e não recebidos
	If	lReajMed	
		nSldFin += A300SldRec('n2','')
	Endif 
	aVlrMed := A300sldRec('a4','')

	oModCNF:SetNoUpdateLine(.F.)
	//- Distribui valor reajustado proporcionalmente
	For nX:= 1 To nLine
		oModCNF:GoLine(nX)
		If !oModCNF:IsDeleted()
			If !Empty(aVlrMed) .And. (nPos := aScan(aVlrMed, {|x| x[1] = oModCNF:GetValue("CNF_PARCEL")})) > 0 .AND. lReajMed	
				nPercRj := aVlrMed[nPos][2] / nSldFin			
			Else
				nPercRj := oModCNF:GetValue("CNF_SALDO") / nSldFin
			EndIf
			nVlrRjP := Round((nPercRj * nVlrReaj), TamSX3('CNF_VLPREV')[2])

			If !(lResult := oModCNF:SetValue("CNF_VLPREV",oModCNF:GetValue("CNF_VLPREV")+nVlrRjP))
				Exit
			EndIf
			
			If lVlPreFin .And. (Empty(oModCNF:GetValue("CNF_VLREAL")) .Or. Empty(oModCNF:GetValue("CNF_TJUROS")))
				oModCNF:SetValue('CNF_TJUROS', nJuros)//Ao preencher CNF_TJUROS, CNF_VLPRES e CNF_VJUROS são preenchidos via trigger
			EndIf
			nTotCro += Round(oModCNF:GetValue('CNF_VLPREV'), TamSX3('CNF_VLPREV')[2])
		EndIf
	Next nX
	
	CN300AjSld(oModel,nTotPla,nTotCro)//Arredonda ultima parcela caso necessario.

	FWRestRows(aSaveLines)
	FwFreeArray(aSaveLines)
Return lResult

//------------------------------------------------------------------
/*/{Protheus.doc} A300ReajCt()
Função para reajustar cronograma Contabil

@author alexandre.gimenez
@since 13/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A300ReajCt(oModel,nVlrReaj)
Local oModCNW	:= oModel:GetModel("CNWDETAIL")
Local nX		:= 0
Local nSldCtb	:= 0
Local nPercRj	:= 0
Local nVlrRjP	:= 0
Local nTotCro	:= 0
Local nTotPla	:= oModel:getModel("CNADETAIL"):GetValue("CNA_VLTOT")
Local nLine	:= oModCNW:Length()
Local nDifCtb	:= 0
Local nRound	:= TamSX3('CNW_VLPREV')[2]
Local aSaveLines	:= FWSaveRows()

//-- Calcula Saldo disponivel para atualizar
For nX:= 1 To nLine
	oModCNW:GoLine(nX)
	If !oModCNW:IsDeleted() .And. oModCNW:GetValue("CNW_DTPREV") >= oModel:GetValue("CN9MASTER","CN9_DTREAJ")
		nSldCtb += oModCNW:GetValue("CNW_VLPREV")
	EndIf
Next nX

oModCNW:GetStruct():SetProperty('CNW_VLPREV',MODEL_FIELD_WHEN,{||.T.})

//- Distribui valor reajustado proporcionalmente
For nX:= 1 To nLine
	oModCNW:GoLine(nX)
	If !oModCNW:IsDeleted() .And. oModCNW:GetValue("CNW_DTPREV") >= oModel:GetValue("CN9MASTER","CN9_DTREAJ")
		nPercRj := oModCNW:GetValue("CNW_VLPREV") / nSldCtb
		nVlrRjP := Round((nPercRj * nVlrReaj), nRound)
		oModCNW:SetValue("CNW_VLPREV",oModCNW:GetValue("CNW_VLPREV")+nVlrRjP)
	EndIf
	nTotCro += Round(oModCNW:GetValue("CNW_VLPREV"), nRound)
Next nX

//--Arredonda ultima parcela caso necessario
nDifCtb := nTotPla - nTotCro
If nDifCtb # 0
	For nX:= nLine To 1 Step -1
		oModCNW:GoLine(nX)
		If !oModCNW:IsDeleted() .And. oModCNW:GetValue("CNW_DTPREV") >= oModel:GetValue("CN9MASTER","CN9_DTREAJ")
			oModCNW:SetValue("CNW_VLPREV",Round(oModCNW:GetValue("CNW_VLPREV"),nRound)+ Round(nDifCtb,nRound))
			Exit
		EndIf
	Next nX
EndIf

FWRestRows(aSaveLines)
Return

//------------------------------------------------------------------
/*/{Protheus.doc} CN300AjSld()
Função para ajustar o saldo, caso de diferença de casas decimais

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function CN300AjSld(oModel, nTotal, nTotCrg)
	Local oCNFDetail 	:= oModel:GetModel('CNFDETAIL')
	Local nDif  	   	:= 0
	Local nI			:= 0
	Local nRound		:= TamSX3('CNF_VLPREV')[2]
	Local aSavelines	:= FWSaveRows()
	Local lFisico 	:= Cn300RetSt("FISICO",0)
	Local cTipRev		:= A300GTpRev()
	Default nTotCrg	:= 0

	If lFisico .And. !(cTipRev == DEF_REV_REAJU .Or. cTipRev == DEF_REV_REALI .Or. cTipRev == DEF_REV_RENOV .Or. cTipRev == DEF_REV_ORCGS .Or. cTipRev == DEF_REV_ABERT)// e nao for Reajuste/Realinhamento/Renovação/Orcamento Serviço/Aberta
		CN300AjSlF(oModel)
	Else
		If nTotCrg == 0
			For nI := 1 To oCNFDetail:Length()
				oCNFDetail:GoLine(nI)
				If !oCNFDetail:IsDeleted()
					nTotCrg += Round(oCNFDetail:GetValue('CNF_VLPREV'),nRound)
				EndIf
			Next nI
		EndIf

		nDif := nTotal - nTotCrg

		If nDif > -5  .And. nDif < 5
			For nI:= oCNFDetail:Length() To 1 Step -1
				oCNFDetail:GoLine(nI)
				If !oCNFDetail:IsDeleted()
					oCNFDetail:SetValue('CNF_VLPREV', Round(oCNFDetail:GetValue('CNF_VLPREV'), nRound) + Round(nDif,nRound))
					Exit
				EndIf
			Next nI
		EndIf
	EndIf

	FWRestRows(aSaveLines)
	FwFreeArray(aSaveLines)
Return

//------------------------------------------------------------------
/*/{Protheus.doc} CN300RdSld()
	Executa a redistribuição dos saldos
@author philipe.pompeu
@since 04/07/2023
/*/
//-------------------------------------------------------------------
Static function CN300RdSld()
	Local bExec := {|| RecalcSaldo() }
	
	If (IsBlind())
		Eval(bExec)
	Else
		//FwMsgRun(, bExec, STR0037, STR0047)	//Redistribuindo saldos
		//FWAlertInfo(STR0048,'CN300RDSLD')	//Redistribuição dos saldos realizadas com sucesso.
	EndIf
Return

//------------------------------------------------------------------
/*/{Protheus.doc} RecalcSaldo()
Função para redistribuir o saldo aditivado de acordo com
os parametros selecionados

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RecalcSaldo()
	Local oModel 		:= FwModelActive()
	Local oCN9Master 	:= oModel:GetModel('CN9MASTER')
	Local oCNADetail 	:= oModel:GetModel('CNADETAIL')
	Local oCNFDetail 	:= oModel:GetModel('CNFDETAIL')
	Local nMontPla   	:= oCNADetail:GetValue('CNA_VLTOT')
	Local nSldReal   	:= 0
	Local nSldDistr  	:= 0
	Local nSldDif		:= 0
	Local nTotDif		:= 0
	Local nVlrPrv		:= 0
	Local nI		   	:= 0
	Local nTotCrg 		:= 0
	Local nParLoc		:= 0
	Local aLinhas    	:= {}
	Local lParAnt		:= oCN9Master:GetValue('CN9_CPARCA')
	Local lParRea		:= oCN9Master:GetValue('CN9_CPARCV')
	Local lFisico		:= Cn300RetSt("FISICO")
	Local lServico		:= Cn300RetSt("SERVIÇO")
	Local lRet		   	:= .T.
	Local nLNovas    	:= 0
	Local aSaveLines	:= FWSaveRows()
	Local nMont      	:= 0
	Local cEspec   	:= Cn300RetSt("REVESPECIE")

	CNTA300BlMd(oCNFDetail, .F.)

	If Empty(oCN9Master:GetValue("CN9_TIPREV"))
		lRet := .F.
		Help(" ",1,"CN300TREV")
	ElseIf Cn300RetSt("MEDEVE") .Or. Cn300RetSt("RECORRENTE")
		lRet := .F.
		Help('',1,'CN300NOFIN') //-- A planilha não possui cronograma financeiro.
	ElseIf lFisico
		lRet := .F.
		Help( " ", 1, "CN300PLFIS") //Para planilhas com cronograma fisico, utilize a opção atualizar cronograma Financeiro/Fisico
	ElseIf !(cEspec $ '1|2|4|5')
		lRet := .F.
		Help('',1,'A300NQT') //Função não disponível para este tipo de revisão
	ElseIf !lParAnt .And. lParRea
		lRet := .F.
		Help( " ", 1, "CN300NPLC") //Para considerar as parcelas com valor realizado é necessário considerar também as parcelas anteriores
	ElseIf !lParAnt .And. lParRea
		lRet := .F.
		Help( " ", 1, "CN300NPLC") //Para considerar as parcelas com valor realizado é necessário considerar também as parcelas anteriores
	ElseIf lServico
		lRet := .F.
		//Help( " " , 1 , "CN300NPLS" , , STR0034 , 1 , 1 , , , , , , { STR0035 } ) // Opção indisponível para planilhas de serviço. Utilize a opção atualizar cronograma financeiro/físico. 
	EndIf

	If lRet
		For nI := 1 To oCNFDetail:Length()
			oCNFDetail:GoLine(nI)
			If !oCNFDetail:IsDeleted()
				nTotCrg += Round(oCNFDetail:GetValue('CNF_VLPREV'), TamSX3('CNF_VLPREV')[2])
			EndIf
		Next nI
	EndIf

	If lRet
			
		nMont := nMontPla - nTotCrg

		If nMont != 0
			If lParAnt .And. lParRea
			
				nParLoc := 0
				nSldReal	:= nMont / (oCNFDetail:Length( .T. ) - nParLoc )
				nSldDistr 	:= Round(nSldReal,TamSX3('CNF_VLPREV')[2])
				nSldDif		:= nSldReal - nSldDistr

				If nMont < 0
					aLinhas := CN300ClDt(oCNFDetail, @nSldDistr, nMont ,0, aLinhas)
				EndIf

				For nI := 1 To oCNFDetail:Length()
					oCNFDetail:GoLine(nI)
					If Ascan(aLinhas, oCNFDetail:GetLine()) == 0 .And. !oCNFDetail:IsDeleted()

						nTotDif += nSldDif
						nVlrPrv := oCNFDetail:GetValue('CNF_VLPREV') + nSldDistr
						If nTotDif >= 0.01 .Or. nTotDif <= -0.01
							nVlrPrv += Round(nTotDif,TamSX3("CNF_VLPREV")[2])
							nTotDif -= Round(nTotDif,TamSX3("CNF_VLPREV")[2])
						EndIf
						If nI == oCNFDetail:Length()
							nTotDif := Round(nTotDif,TamSX3("CNF_VLPREV")[2])
							nVlrPrv += nTotDif
						EndIf
						If Cn300RetSt('SERVIÇO') .And. nVlrPrv == 0
							oCNFDetail:DeleteLine()
						ElseIf nVlrPrv <= 0
							Help(" ",1,"CN300RVLPR",,STR0007,4,0) //'Não é possível zerar o valor de uma parcela. Reduza a quantidade de parcelas do cronograma ou redistribua o saldo manualmente.'
							Exit
						Else
							oCNFDetail:SetValue('CNF_VLPREV', nVlrPrv)
						EndIf
					EndIf

				Next nI

			//-- Considera parcelas antigas
			ElseIf lParAnt
				For nI := 1 To oCNFDetail:Length()
					oCNFDetail:GoLine(nI)
					If oCNFDetail:IsDeleted()
						Loop
					EndIf
					If oCNFDetail:GetValue('CNF_VLREAL') == 0 .And. !oCNFDetail:IsDeleted()
						Aadd(aLinhas, oCNFDetail:GetLine())
					EndIf
				Next nI

				nSldReal	:= nMont / Len(aLinhas)
				nSldDistr 	:= Round(nSldReal,TamSX3('CNF_VLPREV')[2])
				nSldDif		:= nSldReal - nSldDistr

				For nI := 1 To Len(aLinhas)
					oCNFDetail:GoLine(aLinhas[nI])
						nTotDif += nSldDif
						nVlrPrv := oCNFDetail:GetValue('CNF_VLPREV') +  nSldDistr
						If nTotDif >= 0.01 .Or. nTotDif <= -0.01
							nVlrPrv += Round(nTotDif,TamSX3("CNF_VLPREV")[2])
							nTotDif -= Round(nTotDif,TamSX3("CNF_VLPREV")[2])
						EndIf
						If nI == Len(aLinhas)
							nTotDif := Round(nTotDif,TamSX3("CNF_VLPREV")[2])
							nVlrPrv += nTotDif
						EndIf
					If Cn300RetSt('SERVIÇO') .And. nVlrPrv == 0
						oCNFDetail:DeleteLine()
					ElseIf nVlrPrv <= 0
							Help(" ",1,"CN300RVLPR",,STR0007,4,0) //'Não é possível zerar o valor de uma parcela. Reduza a quantidade de parcelas do cronograma ou redistribua o saldo manualmente.'
							Exit
						Else
						oCNFDetail:SetValue('CNF_VLPREV', nVlrPrv)
					EndIf
				Next nI
			Else
				//-- Redistribui somente para as linhas novas
				nLNovas := CN300LenNw(oCNFDetail)
				If nLNovas > 0
					nSldReal	:= nMont / nLNovas
					nSldDistr 	:= Round(nSldReal,TamSX3('CNF_VLPREV')[2])
					nSldDif	:= nSldReal - nSldDistr

					For nI := 1 To oCNFDetail:Length()
						oCNFDetail:GoLine(nI)
						If oCNFDetail:IsInserted() .And. !oCNFDetail:IsDeleted()
							nTotDif += nSldDif
							nVlrPrv := oCNFDetail:GetValue('CNF_VLPREV') +  nSldDistr
						EndIf
						If nTotDif >= 0.01 .Or. nTotDif <= -0.01
							nVlrPrv += Round(nTotDif,TamSX3("CNF_VLPREV")[2])
							nTotDif -= Round(nTotDif,TamSX3("CNF_VLPREV")[2])
						EndIf
						If nI == oCNFDetail:Length()
							nTotDif := Round(nTotDif,TamSX3("CNF_VLPREV")[2])
							nVlrPrv += nTotDif
						EndIf
						If nVlrPrv <= 0
							Help(" ",1,"CN300RVLPR",,STR0007,4,0) //'Não é possível zerar o valor de uma parcela. Reduza a quantidade de parcelas do cronograma ou redistribua o saldo manualmente.'
							Exit
						Else
							oCNFDetail:SetValue('CNF_VLPREV', nVlrPrv)
						EndIf
					Next nI
				EndIf
			EndIf
		EndIf
		//-- Se eu não estiver considerando parcelas antigas nem parcelas realizadas e não tiver nenhuma linha nova não executo o Ajuste de Saldo
		//-- Pois jogará todo o valor para última parcela e ficará sem sentido.
		If !(!lParAnt .And. !lParRea .And. nLNovas == 0)
			CN300AjSld(oModel, nMontPla)
		EndIf
	EndIf
	CNTA300BlMd(oCNFDetail, ,.T.)
	FWRestRows(aSaveLines)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} cn300VlCau(oModel,oModelCN8)
Função para validar o percentual minimo da caução manual

@author aline.sebrian
@since 24/02/2014
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static function cn300VlCau()
Local lRet      := .T.
Local nFor      := 0
Local nValor    := 0
Local nMinimo   := NoRound((CN9->CN9_VLATU*CN9->CN9_MINCAU)/100,MsDecimais())
Local oModel    := FwModelActive()
Local oModelCN8 := oModel:GetModel("CN8DETAIL")
Local oModelCN9	:= oModel:GetModel("CN9MASTER")
Local lCaucaoR  := oModelCN9:GetValue("CN9_TPCAUC") == '2'

For nFor := 1 To oModelCN8:Length()
	oModelCN8:GoLine(nFor)
    nValor += oModelCN8:GetValue("CN8_VLEFET")
Next nFor

If !lCaucaoR .And. nMinimo > nValor
	Help("",1,"CNTA100MINVM",, STR0001 + AllTrim(Str(nMinimo)) + "." ,4)//'O valor mínimo é de '
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300CheckM()
Verifica se existe medicao em aberto para o contrato

@author alexandre.gimenez
@since 24/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function A300CheckM()
Local cAlias 	:= GetNextAlias()
Local oModel    := FwModelActive()
Local oModelCN9 := Nil
Local cContra	:= ""
Local cQuery 	:= ""
local lRet 		:= .T.
Local cFilCPD 	:= xFilial("CPD")
Local aComp		:= {xFilial("CND")}
Local nX		:= 0
Local lCN300RCM := ExistBlock("CN300RCM")
Local cFilCtr	:= ""

If FwIsInCallStack("CN300TOK")
	oModelCN9	:= oModel:GetModel("CN9MASTER")
	cContra		:= oModelCN9:GetValue("CN9_NUMERO")
	cFilCtr		:= oModelCN9:GetValue("CN9_FILCTR")
Else
	cContra	:= CN9->CN9_NUMERO
	cFilCtr	:= CN9->CN9_FILCTR
EndIf

If CPD->(dbSeek(cFilCPD+cContra))
	While CPD->(CPD_FILIAL+CPD_CONTRA) == cFilCPD+cContra .and. CPD->(! Eof())

		if Ascan(aComp,CPD->CPD_FILAUT) = 0
			aAdd(aComp,CPD->CPD_FILAUT)
		EndIf
		CPD->(dbSkip())
	Enddo
EndIf

cQuery := "SELECT COUNT(CND.CND_NUMMED) AS QTD "
cQuery += " FROM "+RetSQLName("CND")+" CND "
cQuery += " WHERE CND.CND_FILIAL IN ('"

For nX := 1 to Len(aComp)
	If nX>1
		cQuery += ",'"
	EndIf
	cQuery += aComp[nX]+"'"
Next nX

cQuery += ") AND CND.CND_CONTRA = '"+cContra+"'"
cQuery += " AND CND.CND_FILCTR = '"+cFilCtr+"'"
cQuery += " AND CND.CND_DTFIM  = ''"
cQuery += "   AND CND.D_E_L_E_T_ = ' '"

If lCN300RCM
	lRet := ExecBlock("CN300RCM",.F.,.F.,{cContra,cQuery})
	lCN300RCM := ValType(lRet) == "L"
EndIf

If !lCN300RCM
	lRet := .T.
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)

If (cAlias)->QTD > 0
	Help("",1,"A300CheckM") //O contrato selecionado possui medição em aberto. Encerre a medição antes de gerar a revisão.
	lRet := .F.
EndIf

(cAlias)->(dbCloseArea())
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300CNBOri()
Salva valor original dos campos quantidade e preco

@author alexandre.gimenez
@since 24/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function A300CNBOri(oModel)
Local nX	:= 0
Local nY	:= 0
Local oModelCNA	:= oModel:GetModel("CNADETAIL")
Local oModelCNB	:= oModel:GetModel("CNBDETAIL")
Local aSaveLines:= FWSaveRows()
Local aPropCNB	:= GetPropMdl(oModelCNB)

CNTA300BlMd(oModelCNB,,.T.)

// Roda Planilhas
For nX := 1 to oModelCNA:Length()
	oModelCNA:GoLine(nX)
	If Cn300RetSt("FIXO")
		For nY := 1 to oModelCNB:Length() //Roda Itens
			oModelCNB:GoLine(nY)
			oModelCNB:LoadValue("CNB_PRCORI",oModelCNB:GetValue("CNB_VLUNIT"))
			oModelCNB:LoadValue("CNB_QTDORI",oModelCNB:GetValue("CNB_QUANT"))
		Next nY
	Endif
Next nX

RstPropMdl(oModelCNB,aPropCNB)
FwFreeArray(aPropCNB)
FWRestRows(aSaveLines)
FwFreeArray(aSaveLines)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A300RevMed()
Função para analisar os antigos parametro CNREAJM e CNREALM disponiveis
no tipo de contrato

@author alexandre.gimenez
@since 24/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function A300RevMed(nModo)
Local lRet		:= 	.F.
Local aArea	    := 	GetArea()
Local lReajMd := 	.F.		//- Reajusta Medição
Local lRealMd := 	.F.		//- Realinha Medição
Local cTipRev	:= 	A300GTpRev()+"|"+A300GATpRv()

Default nModo	:= 2

If ((DEF_REV_REAJU $ cTipRev) .Or. (DEF_REV_REALI $ cTipRev) .Or. (DEF_REV_ABERT $ cTipRev))	
	lReajMd := Cn300RetSt("REVREAJU",nModo)
	lRealMd := Cn300RetSt("REVREALI",nModo)

	If 	( lReajMd .And. DEF_REV_REAJU $ cTipRev ) .Or.;
		( lRealMd .And. DEF_REV_REALI $ cTipRev ) .Or.;
		( (lReajMd .Or. lRealMd) .And. DEF_REV_ABERT $ cTipRev)		
		lRet := .T.
	EndIf
EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300VlrCnb()
Função para validar o campo cnb_vlunit na revisao e identificar a
necessidade de dividir o mesmo.

@author alexandre.gimenez
@since 24/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function A300VlrCNB(cField,nNewValue,nOldValue)
Local aArea		:= GetArea()
Local aWhenCNF	:= {}
Local aWhenCNB	:= {}
Local oModel	:= Nil
Local oModCNB	:= Nil
Local oModCNF	:= Nil
Local oModCN9	:= Nil
local cModo		:= ""
Local lServico	:= .F.
Local cTipRev	:= A300GTpRev()
Local lRevMed 	:= .F.
Local lQuebra 	:= .F.
Local lRet		:= .T.
Local lMsmVlr	:= nNewValue <> nOldValue .Or. cTipRev == DEF_REV_ORCGS
Local nQtdNRec	:= 0
Local nValue	:= 0
Local lDivItem	:= .F.
Local lAuto		:= IsBlind()
Local oView		:= Nil
Local lNotReajus:= .F.
Local aAux		:= {}
Local cMsgQuebr := ""
Local lRefresh	:= .F.

// Verifica se é revisão
If !Empty(cTipRev) .And. lMsmVlr .And. !IsInCallStack('CNAddItRt') .And. !IsInCallStack("A300DivCNB")
	oModel	:= FwModelActive()
	oModCNB	:= oModel:GetModel("CNBDETAIL")
	oModCNF	:= oModel:GetModel("CNFDETAIL")
	oModCN9	:= oModel:GetModel("CN9MASTER")
	cModo	 := Cn300RetSt("MODALIDADE")
	lServico := Cn300RetSt("SERVIÇO")
	lRevMed	 := A300RevMed(0) .And. cTipRev <> DEF_REV_RENOV
	aWhenCNF := GCTGetWhen(oModCNF)
	aWhenCNB := GCTGetWhen(oModCNB)
	lNotReajus:= !FwIsInCallStack("CN300REAJU")

	oModCNF:GetStruct():SetProperty("*",MODEL_FIELD_WHEN,{||.T.})
	oModCNB:GetStruct():SetProperty("*",MODEL_FIELD_WHEN,{||.T.})

	//-- Validação de acrescimo ou decrescimo
	If !oModCNB:IsInserted()
		If lRet .And. cTipRev == DEF_REV_REALI .And. cModo <> "3" /*Quando Ambos não valida*/
			DbSelectArea("CNB")
			CNB->(DbSetorder(1))
			If CNB->(DbSeek(xFilial("CNB")+oModCN9:GetValue("CN9_NUMERO")+CN9->CN9_REVISA+oModCNB:GetValue("CNB_NUMERO")+oModCNB:GetValue("CNB_ITEM")))
				If cField == "CNB_VLUNIT"
					//Quando for apenas acrescimo
					If cModo == "1"
						lRet	:= ( nNewValue * (1-(oModCNB:GetValue("CNB_DESC")/100)) >= oModCNB:GetValue("CNB_PRCORI")*(1-(CNB->CNB_DESC/100)) )
					//Quando for apenas decrescimo
					ElseIf cModo == "2"
						lRet	:= (nNewValue * (1-(oModCNB:GetValue("CNB_DESC")/100)) <= oModCNB:GetValue("CNB_PRCORI")*(1-(CNB->CNB_DESC/100)) )
					EndIf
				ElseIf cField == "CNB_DESC"
					//Quando for apenas acrescimo
					If cModo == "1"
						lRet	:= ( oModCNB:GetValue("CNB_VLUNIT") * (1-(nNewValue/100)) >= oModCNB:GetValue("CNB_PRCORI")*(1-(CNB->CNB_DESC/100)) )
					//Quando for apenas decrescimo
					ElseIf cModo == "2"
						lRet	:= ( oModCNB:GetValue("CNB_VLUNIT") * (1-(nNewValue/100)) <= oModCNB:GetValue("CNB_PRCORI")*(1-(CNB->CNB_DESC/100)) )
					EndIf
				EndIf
			EndIf

			If !lRet
				Help("",1,"A300MODREALI") //Modalidade da revisão (Acrescimo/Decrescimo) não respeitado
			EndIf
		EndIf
	EndIf

	If lRet .And. Cn300RetSt("FIXO") .And. !Cn300RetSt("RECORRENTE")

		If 	!oModCNB:IsInserted() .And.;
			 (cTipRev $ DEF_REV_REAJU+"|"+DEF_REV_REALI+"|"+DEF_REV_RENOV+"|"+DEF_REV_ORCGS+"|"+DEF_REV_ABERT .Or. lServico)// Valida somente Reajuste, Realinhamento, Renovação, Aberta e planilhas de serviços.
			If oModCNB:GetValue("CNB_SLDREC") == 0 .And. !(cTipRev $ DEF_REV_RENOV+"|"+DEF_REV_ORCGS)
				lRet := .F.
				Help("",1,"A300TOTRECEBI") //Item totalmente recebido, sem saldo para ser alterado.
			ElseIf !Empty(oModCNB:GetValue("CNB_ITMDST")) // Item ja quebrado, nao pode ser alterado novamente.
				lRet := .F.
				Help("",1,"A300DIVIDIDO") // Item dividido, nao pode ser alterado novamente.
			EndIf

			//-----------------------------------------------------------
			// Ponto de entrada na validação do campo CNB_VLUNIT
			//-----------------------------------------------------------
			If lRet .And. _lA300RVUN
				lRet := ExecBlock("A300RVUN",.F.,.F.,{oModel,lQuebra,nOldValue,nNewValue})
				If ValType( lRet ) <> "L"
					lRet := .F.
				EndIf
			Endif

			If lRet
				nQtdNRec := A300SldRec('n',oModel:GetModel("CNBDETAIL"):GetValue("CNB_ITEM"))
				If !lRevMed // Parametro de Revisar medição (Inativo)
					If oModCNB:GetValue("CNB_SLDMED") == 0 .And. !(cTipRev $ DEF_REV_RENOV+"|"+DEF_REV_ORCGS) // Sem Saldo a Medir
						lRet := .F.
						Help("",1,"A300TOTMEDI") // Item totalmente medido, sem saldo para ser alterado.
					ElseIf (oModCNB:GetValue("CNB_QTDORI") <>  oModCNB:GetValue("CNB_SLDMED") .Or.;
						 	oModCNB:GetValue("CNB_QTDORI") <>  oModCNB:GetValue("CNB_QUANT")) .And.;
						 	oModCNB:GetValue("CNB_QTDMED") > 0  // Item teve movimentação, tem que quebrar
						lQuebra := .T.
					EndIf
				Else // Parametro de Revisar medição (Ativo)
					If oModCNB:GetValue("CNB_QTDMED") > nQtdNRec
						lQuebra := .T.
					EndIf
				EndIf
			EndIf
	 	EndIf
		
		If cTipRev == DEF_REV_ORCGS 
			If lQuebra
				lQuebra := (nNewValue - (nQtdNRec * nOldValue)) > 0 
			EndIf	
		EndIf

		If (lQuebra .And. _lA300BREAK)// Permite alterar a mensagem padrão e forçar a divisão de itens inicialmente não divididos pelo sistema
			aAux := ExecBlock("A300BREAK", .F., .F., {lQuebra, oModel, cField, nOldValue, nNewValue, STR0009})
			If (ValType(aAux) == "A" .And. Len(aAux) == 2 .And. ValType(aAux[1]) == "L" .And. ValType(aAux[2]) == "C")
				lQuebra		:= aAux[1]
				cMsgQuebr	:= aAux[2]
			EndIf
		EndIf
		
		If lRet
			If lQuebra .And. !oModCNB:IsInserted()
				If (cTipRev == DEF_REV_REALI) .Or. (cTipRev == DEF_REV_RENOV) .Or. (cTipRev == DEF_REV_ABERT)					
				 	lDivItem := IIF(lAuto, .T., MsgYesNo(IIF(Empty(cMsgQuebr), STR0009, cMsgQuebr),STR0008))//- "Para essa alteração será necessário dividir o item, pois há medições para essa planilha. Deseja prosseguir?"
				ElseIf(cTipRev == DEF_REV_REAJU .Or. cTipRev == DEF_REV_ORCGS)//Para Reajuste não precisa realizar a pergunta, sempre vai dividir o item
					lDivItem := .T.
				EndIf
				
				If lDivItem
					If lNotReajus
						A300OpenMd({||}, .F.)//Nesse caso o modelo ja foi aberto na funcao <CN300REAJU>
					EndIf
				Else
					lRet := .F.
					//oModel:SetErrorMessage( "CNBDETAIL", "CNB_VLUNIT", "CNBDETAIL", "CNB_VLUNIT", "", STR0033) // Ação cancelada pelo usuário
				EndIf

				If lRet
					If cField == "CNB_VLUNIT"
						oModCNB:LoadValue("CNB_VLUNIT",nOldValue)
						oModCNB:SetValue("CNB_VLTOT",nOldValue*oModCNB:GetValue('CNB_QUANT'))
					ElseIf cField == "CNB_DESC"
						oModel:GetModel("CNBDETAIL"):LoadValue("CNB_DESC",nOldValue)
					EndIf
					lRet := A300DivCNB(oModel,lRevMed,nNewValue,nQtdNRec,cField)
				EndIf
			EndIf
			nValue := oModCNB:GetValue("CNB_DESC")

			If (oModCN9:GetValue("CN9_FLGCAU") == "1" .And. oModCN9:GetValue("CN9_TPCAUC") == '2' )//Se utilizar caucao com retencao
				A300AtCauR(oModel)//Atualiza retencao do caucao
			EndIf
			If cTipRev $ DEF_REV_REALI+'|'+DEF_REV_RENOV+'|'+DEF_REV_ORCGS+'|'+DEF_REV_ABERT .And. lNotReajus				
				A300Revisa(oModel, cTipRev) //-- trava modelo novamente
				lRefresh := .T.
			EndIf
	 	EndIf
		
		lRefresh := (lRefresh .Or. lDivItem .Or. oModCNB:IsInserted())		
		If (lRefresh .And. lRet .And. !lAuto .And. lNotReajus)
			oView := FWViewActive()
			If (ValType(oView) == "O" .And. oView:IsActive() .And. oView:GetModel():GetId() $ 'CNTA300|CNTA301')
				oView:Refresh('VIEW_CNB')
			EndIf
		EndIf
	EndIf
	
	GCTRstWhen( oModCNF , aWhenCNF )
	GCTRstWhen( oModCNB , aWhenCNB )
	FwFreeArray(aWhenCNF)
	FwFreeArray(aWhenCNB)
EndIf

RestArea(aArea)
FwFreeArray(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300DivCNB()
Funcao para dividir o item da tabela CNB quando é alterado o item na revisao
e o mesmo ja possua medições

@author alexandre.gimenez
@since 24/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function A300DivCNB(oModel,lRevMed,nNewValue,nQtdNRec,cField)
	Local lRet		:= .T.
	Local lFisico 	:= Cn300RetSt("FISICO",0)
	Local oModCNB	:= oModel:GetModel("CNBDETAIL")
	Local oModelCNZ := oModel:GetModel("CNZDETAIL")
	Local lRateio   := !Empty(oModelCNZ:GetValue("CNZ_CODPLA"))
	Local nR        := 0
	Local nLineOri	:= oModCNB:GetLine()
	Local nLineDst	:= 0
	Local nX		:= 0
	Local aHeader	:= oModCNB:GetStruct():GetFields()
	Local aDados	:= {}
	Local cCampo	:= ""
	Local nQtdRec	:= 0
	Local nNaoRec	:= 0
	Local nSldRec	:= 0
	Local nForaDt	:= 0
	Local nDecQuant	:= TamSX3("CNB_QUANT")[2]
	Local nQuant	:= 0
	Local aQntMed	:= Nil	
	Local aRateio   := {}
	Local bWhenQuant:= Nil
	Local aCposCNZ	:= {}
	Local aCTBEnt	:= {}
	Local aItRateio := {}
	Local nTamDados	:= 0

	// copia dados da origem
	For nX := 1 to Len(aHeader)
		cCampo := AllTrim(aHeader[nX][MODEL_FIELD_IDFIELD])
		If cCampo $ "CNB_QUANT|CNB_QTDMED"
			aAdd(aDados,{cCampo,oModCNB:GetValue("CNB_QUANT") - oModCNB:GetValue("CNB_SLDREC"),oModCNB:GetValue("CNB_QUANT") - oModCNB:GetValue("CNB_SLDREC")})
		ElseIf cCampo $ "CNB_SLDMED|CNB_SLDREC"
			aAdd(aDados,{cCampo,0,0})
		Else
			aAdd(aDados,{cCampo,oModCNB:GetValue(cCampo),oModCNB:GetValue(cCampo)})
		EndIf
	Next nX

	oModCNB:SetNoInsertLine(.F.)
	nLineDst := oModCNB:AddLine()
	If nLineDst == nLineOri // Não foi possivel adicionar linha
		lRet := .F.
	Else // Duplica Linha
		nQtdRec := oModCNB:GetValue("CNB_QTDMED",nLineOri) - nQtdNRec 									// Valor Recebido
		nNaoRec := oModCNB:GetValue("CNB_SLDREC",nLineOri) - oModCNB:GetValue("CNB_SLDMED",nLineOri) 	// Valor medido nao recebido ainda.
		nSldRec := oModCNB:GetValue("CNB_SLDMED",nLineOri) + nQtdNRec 									// Saldo recebido considerando valor fora de data
		nForaDt := oModCNB:GetValue("CNB_SLDREC",nLineOri) - oModCNB:GetValue("CNB_SLDMED",nLineOri) - nQtdNRec
		
		nTamDados := len(aDados)
		For nX := 1 to nTamDados
			cCampo := aDados[nX,1]
			If !(cCampo $ "CNB_REALI|CNB_VLTOTR|CNB_VLDESC") // Campos Calculados
				If	cCampo == "CNB_VLUNIT"
					oModCNB:SetValue(cCampo,IIF(cField == "CNB_VLUNIT",nNewValue,aDados[nX,2]))
				ElseIf cCampo == "CNB_ITEM"					
					oModCNB:LoadValue(cCampo,soma1(oModCNB:GetValue("CNB_ITEM",oModCNB:GetLine()-1)))					
				ElseIf cCampo == "CNB_QUANT"
					//Quantidade Nova
					If !(A300GTpRev() $ DEF_REV_RENOV+"|"+DEF_REV_ORCGS+'|'+DEF_REV_ABERT)
						nQuant	:= Round( IIF( lRevMed , nSldRec , oModCNB:GetValue( "CNB_SLDMED" , nLineOri ) ) , nDecQuant )
						oModCNB:SetValue( cCampo , nQuant )
					Else
						nQuant	:= Round( oModCNB:GetValue( 'CNB_QUANT' , nLineOri ) - ( oModCNB:GetValue( "CNB_QTDMED" , nLineOri ) + Iif( lRevMed , nQtdNRec , 0 ) ) , nDecQuant )
						oModCNB:SetValue( cCampo , nQuant )
					Endif
					//Quantidade Origem
					aDados[nX,3] := Round ( IIF( lRevMed , nQtdRec , oModCNB:GetValue( "CNB_QTDMED" , nLineOri ) ) , nDecQuant )
				ElseIf cCampo == "CNB_QTDMED"
					//Quantidade Medida Nova
					oModCNB:LoadValue(cCampo,IIF(lRevMed,nQtdNRec,0))
					//Quantidade Medida Origem
					aDados[nX,3] := IIF(lRevMed,nQtdRec,oModCNB:GetValue("CNB_QTDMED",nLineOri))
				ElseIf cCampo == "CNB_SLDMED"
					//Saldo a Medir Novo
					oModCNB:LoadValue(cCampo,oModCNB:GetValue("CNB_QUANT")-oModCNB:GetValue("CNB_QTDMED") )
					//Saldo a Medir Origem
					aDados[nX,3] := 0
				ElseIf cCampo == "CNB_SLDREC"
					//Saldo a Receber Novo
					oModCNB:LoadValue(cCampo,IIF(lRevMed,nSldRec,oModCNB:GetValue("CNB_SLDMED",nLineOri)))
					//Saldo a Receber Origem
					aDados[nX,3] := IIF(lRevMed,nForaDt,nNaoRec)
				ElseIf cCampo == "CNB_ITMDST"					
					oModCNB:LoadValue(cCampo,"")// Deixa item novo em branco					
					aDados[nX,3] := oModCNB:GetValue("CNB_ITEM")// Atualiza linha origem - vincula item destino
				ElseIf cCampo == "CNB_QTDORI"					
					oModCNB:LoadValue(cCampo,oModCNB:GetValue("CNB_QUANT"))// Quantidade Origem nova, igual o quantidade do registro					
				ElseIf cCampo == "CNB_VLTOT"
					// Valor Total Novo
						//Calculado
					//Valor Total Origem
					aDados[nX,3] := oModCNB:GetValue("CNB_QUANT",nLineOri)*oModCNB:GetValue("CNB_VLUNIT",nLineOri)
				ElseIf cCampo == "CNB_DESC"
					// Desconto Novo
					oModCNB:SetValue(cCampo,IIF(cField == "CNB_DESC",nNewValue,oModCNB:GetValue(cCampo,nLineOri)))					
				Else
					oModCNB:LoadValue(cCampo,aDados[nX,2])
				EndIf
			EndIf

			If (nX == nTamDados) //Após ter carregado todos os dados
				A300CalcVl(oModCNB)
			EndIf
		Next nX
				
		bWhenQuant := oModCNB:GetStruct():GetProperty('CNB_QUANT', MODEL_FIELD_WHEN)
		oModCNB:GetStruct():SetProperty("CNB_QUANT",MODEL_FIELD_WHEN,{|| .T.})

		oModCNB:GoLine(nLineOri)
		For nX := Len(aDados) To 1 Step -1//Atualiza linha origem com dados recalculados
			cCampo := aDados[nX,1]
			If !(cCampo) $ "CNB_VLTOT"
				If cCampo $ "CNB_QUANT|CNB_VLUNIT|CNB_DESC"
					oModCNB:SetValue(cCampo,aDados[nX,3])
				Else
					oModCNB:LoadValue(cCampo,aDados[nX,3])
				EndIf
			EndIf
		Next nX

		oModCNB:GetStruct():SetProperty("CNB_QUANT",MODEL_FIELD_WHEN, bWhenQuant)
		FwFreeArray(aDados)
	EndIf
	
	If lFisico//Ajusta cronograma fisico
		aQntMed := A300SldRec('a', oModCNB:GetValue("CNB_ITEM"))

		//Linha Nova
		oModCNB:GoLine(nLineDst)
		CN300AddFis(oModel,oModCNB:GetValue("CNB_ITEM"),oModCNB:GetValue("CNB_PRODUT"),oModCNB:GetValue("CNB_QUANT"))
		A300AtuCrF(oModel,oModCNB:GetValue("CNB_QUANT"),aQntMed,oModCNB:GetLine(),nLineOri)

		//Linha Origem
		oModCNB:GoLine(nLineOri)
		A300AtuCrF(oModel,oModCNB:GetValue("CNB_QUANT"),aQntMed,oModCNB:GetLine())
	EndIf

	If _lA300RDVI// Ponto de entrada na divisão de linhas dos itens
		ExecBlock("A300RDVI",.F.,.F.,{oModel,nLineDst,nLineOri,nNewValue})
	Endif

	If lRateio
		aCTBEnt	:= CTBEntArr()
		aCposCNZ:={ {"CNZ_ITEM"		},;
					{"CNZ_PERC"		},;
					{"CNZ_CC"		},;
					{"CNZ_CONTA"	},;
					{"CNZ_ITEMCT"	},;
					{"CNZ_CLVL"		}}

		for nX := 1 to Len(aCTBEnt)
			cCampo := "CNZ_EC" + aCTBEnt[nX] + "CR"
			If oModelCNZ:HasField(cCampo)
				aAdd(aCposCNZ, {cCampo})
			EndIf
			cCampo := "CNZ_EC" + aCTBEnt[nX] + "DB"
			If oModelCNZ:HasField(cCampo)
				aAdd(aCposCNZ, {cCampo})
			EndIf
		next nX

		For nR := 1 To  oModelCNZ:Length() 
			oModelCNZ:GoLine(nR)
			aItRateio := aClone(aCposCNZ)
			for nX := 1 to Len(aItRateio)				
				aAdd(aItRateio[nX], oModelCNZ:GetValue(aItRateio[nX,1]))
			next nX

			aAdd(aRateio,aItRateio)
		Next nR

		oModCNB:GoLine(oModCNB:length())

		For nR:= 1 to Len(aRateio)
			If nR > 1
				oModelCNZ:AddLine()
			EndIf
			
			aItRateio := aRateio[nR]			
			for nX := 1 to Len(aItRateio)
				oModelCNZ:SetValue(aItRateio[nX,1], aItRateio[nX,2])				
			next nX
		Next nR

		FwFreeArray(aRateio)
		FwFreeArray(aCTBEnt)
		FwFreeArray(aCposCNZ)
	EndIf

	cn300BlqLn()	
	oModCNB:GoLine(nLineOri)//Linha Origem
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300VlrInd()
Busca Valor do indice na tabela de historico

@author alexandre.gimenez
@since 24/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function A300VlrInd(cIndice, dDataRef, lProRat, dDataApl, dDtRjAnt, dDtPrxRj,lPercent)
Local nRet		 := 0
Local nPercProRat:= 0
Local aArea	     := GetArea()

Default lProRat  := .F.
Default lPercent := .F.

// Caso não seja informado o indice busca o indice do contrato.
If Empty(cIndice)
	cIndice := CN9->CN9_INDICE
EndIf

// Seleciona indice do contrato
If Posicione("CN6",1,xFilial("CN6")+cIndice,"CN6_TIPO") == "1"//Diario
	//Seleciona historico do indice diario
	dbSelectArea("CN7")
	CN7->(dbSetOrder(1))
	If dbSeek(xFilial("CN7")+cIndice+DTOS(dDataRef))
		nRet := CN7->CN7_VLREAL
	EndIf
Else
	//Seleciona historico do indice mensal
	dbSelectArea("CN7")
	CN7->(dbSetOrder(2))	//- CN7_FILIAL+CN7_CODIGO+CN7_COMPET
	If dbSeek(xFilial("CN7")+cIndice+strzero(Month(dDataRef),2)+"/"+strzero(Year(dDataRef),4))
		nRet := CN7->CN7_VLREAL
	EndIf
EndIf

//Se for Pro Rata, resgata o índice proporcional para o cálculo do reajuste do periodo
If lProRat .And. !Empty(dDtPrxRj) .And. !Empty(dDtrjAnt)
	If Int( dDtPrxRj - dDtRjAnt ) > 0
		nPercProRat := Int( dDataApl - dDtRjAnt ) / Int( dDtPrxRj - dDtRjAnt ) //Calcula  a proporcionalidade do período parcial pelo o período integral do reajuste
		If nPercProRat > 0 .And. nPercProRat < 1 //Não deve zerar o índice nem aumentá-lo
			nRet := nRet * nPercProRat
		Endif
	EndIf
EndIf

// Transforma indice em percentual.
If !lPercent
	nRet := (nRet/100) + 1
EndIf
RestArea(aArea)
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300ApAr(oModel)
Aplica o arrasto nas parcelas.

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*///-------------------------------------------------------------------
Static Function CN300ApAr(oModel)
Local oCN9Master := oModel:GetModel('CN9MASTER')
Local oCNFDetail := oModel:GetModel('CNFDETAIL')
Local oCNADetail := oModel:GetModel('CNADETAIL')
Local lRedVlrs   := oCN9Master:GetValue('CN9_REDVAL') == '1'
Local nI := 0
Local nSldDist := 0
Local nSldReal := 0
Local nSldDif	 := 0
Local nTotDif	 := 0
Local nVlrPrv	 := 0
Local aLinhas := {}
Local aSaveLines	:= FWSaveRows()
Local nTamVlPrev	:= TamSX3("CNF_VLPREV")[2]
Local nJuros	:= 0
Local lVlPreFin := ValPresFin(oModel:GetModel("CN9MASTER"), @nJuros)

For nI := 1 To oCNFDetail:Length()
	oCNFDetail:GoLine(nI)
	If oCNFDetail:IsDeleted()
		Loop	
	EndIf

	If oCNFDetail:GetValue('CNF_SALDO') <> oCNFDetail:GetValue('CNF_VLPREV')
		nSldDist += oCNFDetail:GetValue('CNF_SALDO')
		oCNFDetail:SetValue('CNF_VLPREV', oCNFDetail:GetValue('CNF_VLREAL'))
		oCNFDetail:SetValue('CNF_SALDO', 0)		
		If lVlPreFin .And. Empty(oCNFDetail:GetValue("CNF_TJUROS")) //Somente se nao tiver um juros anterior
			oCNFDetail:SetValue('CNF_TJUROS', nJuros)//Ao preencher CNF_TJUROS, CNF_VLPRES e CNF_VJUROS são preenchidos via trigger
		EndIf
	EndIf

	If !lRedVlrs
		If oCNFDetail:GetValue('CNF_VLREAL') == 0 .And. Len(aLinhas) == 0
			Aadd(aLinhas, oCNFDetail:GetLine())
		EndIf
	ElseIf oCNFDetail:GetValue('CNF_VLREAL') == 0
		Aadd(aLinhas, oCNFDetail:GetLine())
		nSldDist += oCNFDetail:GetValue('CNF_SALDO')  
	EndIf
Next nI

If !Empty(aLinhas)
	If !lRedVlrs
		oCNFDetail:GoLine(aLinhas[1])
		oCNFDetail:SetValue('CNF_VLPREV', oCNFDetail:GetValue('CNF_VLPREV') + nSldDist)
		If lVlPreFin .And. (Empty(oCNFDetail:GetValue("CNF_VLREAL")) .Or. Empty(oCNFDetail:GetValue("CNF_TJUROS")))
			oCNFDetail:SetValue('CNF_TJUROS', nJuros)//Ao preencher CNF_TJUROS, CNF_VLPRES e CNF_VJUROS são preenchidos via trigger
		EndIf
	Else
		nSldReal :=  oCNADetail:GetValue('CNA_SALDO') / Len(aLinhas)
		nSldDist := Round(nSldReal,nTamVlPrev)
		nSldDif  := nSldReal - nSldDist

		For nI := 1 To Len(aLinhas)
			oCNFDetail:GoLine(aLinhas[nI])
			nTotDif += nSldDif
			nVlrPrv := nSldDist
			If nTotDif >= 0.01 .Or. nTotDif <= -0.01
				nVlrPrv += Round(nTotDif,nTamVlPrev)
				nTotDif -= Round(nTotDif,nTamVlPrev)
			EndIf
			If nI == Len(aLinhas)
				nTotDif := Round(nTotDif,nTamVlPrev)
				nVlrPrv += nTotDif
			EndIf

			oCNFDetail:SetValue('CNF_VLPREV', nVlrPrv)
			If lVlPreFin .And. (Empty(oCNFDetail:GetValue("CNF_VLREAL")) .Or. Empty(oCNFDetail:GetValue("CNF_TJUROS")))
				oCNFDetail:SetValue('CNF_TJUROS', nJuros)//Ao preencher CNF_TJUROS, CNF_VLPRES e CNF_VJUROS são preenchidos via trigger
			EndIf
		Next nI
	EndIf
ElseIf(oCNFDetail:Length() == 1 .And. oCNADetail:GetValue('CNA_SADIST') > 0 .And. !Cn300RetSt("FISICO",0))
	oCNFDetail:GoLine(1)
	If !(oCNFDetail:IsDeleted())
		nVlrPrv := oCNFDetail:GetValue('CNF_VLPREV')
		nVlrPrv += oCNADetail:GetValue('CNA_SADIST')
		oCNFDetail:SetValue('CNF_VLPREV', nVlrPrv)
		If lVlPreFin .And. (Empty(oCNFDetail:GetValue("CNF_VLREAL")) .Or. Empty(oCNFDetail:GetValue("CNF_TJUROS")))
			oCNFDetail:SetValue('CNF_TJUROS', nJuros)//Ao preencher CNF_TJUROS, CNF_VLPRES e CNF_VJUROS são preenchidos via trigger
		EndIf
	EndIf
EndIf

CN300AjSld(oModel, oModel:GetModel("CALC_CNF"):GetValue('CNF_CALC'))
oCNADetail:LoadValue('CNA_SADIST', CN300SdDt(oModel))

FWRestRows(aSaveLines)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300IcPrc(oModel)
Inclui parcelas no contrato.

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function CN300IcPrc(oModel, aSldsFis)
Local aSaveLines	:= FWSaveRows()
Local oCN9Master:= oModel:GetModel('CN9MASTER')
Local oCNFDetail:= oModel:GetModel('CNFDETAIL')
Local oCNBDetail:= oModel:GetModel('CNBDETAIL')
Local cParce		:= strzero(0,TamSx3("CNF_PARCEL")[1])//Controla a Sequencia das parcelas
Local cCronog		:= oCNFDetail:GetValue('CNF_NUMERO')
Local cCond			:= oCN9Master:GetValue('CN9_CONDPG')
Local nQtdParcs := oCN9Master:GetValue('CN9_QTDPAR')
local nDiaPar		:= 30
Local nI    	:= 0
Local nI2    	:= 0
Local lVldVige   	:= GetNewPar("MV_CNFVIGE","N") == "N"
Local lUltimoDia:= oCN9Master:GetValue('CN9_UDMES')
Local lFisico		:= Cn300RetSt("FISICO",0)
Local lAjFim		:= .F.
Local lAjFev	:= .F.
Local lAjFimC	:= .F.
Local lAjFevC	:= .F.
Local lOk		:= .T.
Local nMaxParc	:= 0
Local lVlPreFin := .F.
Local nJuros 	:= 0
Local nLinDel	:= 0

If lUltimoDia // Verifica se utiliza ultimo dia do mes
	lAjFim := .T.
	lAjFev := .T.
	lAjFimC:= .T.
	lAjFevC:= .T.
Endif

//Ultima linha não deletada
For nI := oCNFDetail:Length() To 1 Step -1
	oCNFDetail:GoLine(nI)
	If !oCNFDetail:IsDeleted()
		nLinDel := nI
		Exit
	EndIf
Next nI

dPrevista	:= oCNFDetail:GetValue('CNF_PRUMED')//Seleciona ultima data
dComp		:= oCNFDetail:GetValue('CNF_COMPET')//Seleciona ultima competencia
dComp		:= CTOD(Str(Day(dPrevista))+"/"+dComp)
cParce		:= oCNFDetail:GetValue('CNF_PARCEL')
nMaxParc	:= oCNFDetail:GetValue('CNF_MAXPAR') + nQtdParcs
lVlPreFin 	:= ValPresFin(oCN9Master, @nJuros)

//oCNFDetail:GoLine(1)
nDiaIni   := Day(oCNFDetail:GetValue('CNF_PRUMED')) //Seleciona o dia da última parcela do cronograma

cParce := Soma1(cParce)
cCompet := strzero(Month(dComp),2)+"/"+str(Year(dComp),4)

aCond := Condicao(0,cCond,,dPrevista)//Calcula data de acordo com a condicao

nDiaPar  := oCNFDetail:GetValue('CNF_DIAPAR')

For nI := 1 To nQtdParcs

	//--Calcula data da proxima parcela                      ³
	nMes := Month(dPrevista)
	nAno := Year(dPrevista)

	If nDiaPar == 30 .OR. nDiaPar == 0
		nAvanco  := CalcAvanco(dPrevista,lAjFim,lAjFev,nDiaIni)
	Else
		nAvanco := nDiaPar
	EndIf

	dPrevista += nAvanco
	If nDiaPar == 30 .OR. nDiaPar == 0
		nAvanco  := CalcAvanco(dComp,lAjFimC,lAjFevC,nDiaIni)
	Else
		nAvanco := nDiaPar
	EndIf
	dComp    += nAvanco
	
	If (lOk := CNTA300ULT(dPrevista, oModel:GetModel("CNADETAIL"):GetValue("CNA_DTFIM"), lVldVige))	//-- Verifica data final do cronograma x data final da planilha
		If Cn300RetSt("SERVIÇO")
			CN300ItSrv(2,1)
		EndIf

		oCNFDetail:AddLine()
		oCNFDetail:LoadValue('CNF_TXMOED', 1)
		oCNFDetail:LoadValue('CNF_NUMERO', cCronog)
		oCNFDetail:LoadValue('CNF_PARCEL', cParce)
		oCNFDetail:LoadValue('CNF_COMPET', strzero(Month(dComp),2)+"/"+str(Year(dComp),4))
		oCNFDetail:LoadValue('CNF_PRUMED', dPrevista)
		oCNFDetail:LoadValue('CNF_DIAPAR', nDiaPar)
		oCNFDetail:LoadValue('CNF_DTVENC', If(len(aCond)>0,aCond[1][1],dPrevista))
		oCNFDetail:LoadValue('CNF_MAXPAR', nMaxParc)
		
		If lVlPreFin
			oCNFDetail:LoadValue('CNF_TJUROS', nJuros)
		EndIf

		dPrevista := oCNFDetail:GetValue('CNF_PRUMED')//Seleciona ultima data
		dComp	  := oCNFDetail:GetValue('CNF_COMPET')//Seleciona ultima competencia
		dComp	  := CTOD(Str(Day(dPrevista))+"/"+dComp)
		cParce := Soma1(cParce)

		If lFisico
			For nI2 := 1 To oCNBDetail:Length()
				oCNBDetail:GoLine(nI2)
				nPos := aScan(aSldsFis,{|x| x[1] == oCNBDetail:GetValue("CNB_ITEM")})
				If nPos > 0
					CN300AddFis(oModel,oCNBDetail:GetValue("CNB_ITEM") ,oCNBDetail:GetValue("CNB_PRODUT"), aSldsFis[nPos, 2], ,oCNFDetail:GetLine())
				Else
					CN300AddFis(oModel,oCNBDetail:GetValue("CNB_ITEM"),oCNBDetail:GetValue("CNB_PRODUT"),oCNBDetail:GetValue("CNB_SLDMED"), ,oCNFDetail:GetLine())
				EndIf
			Next nI2
		EndIf
	EndIf
Next nI

For nI := nLinDel To 1 Step -1
	oCNFDetail:GoLine(nI)
	If !oCNFDetail:IsDeleted() .And. !oCNFDetail:IsInserted()
		oCNFDetail:LoadValue('CNF_MAXPAR', nMaxParc) //Se adicionada parcelas, atualiza numero total de parcelas...
	EndIf
Next nI

If lOk
	If (lFisico .And. nQtdparcs == 0)
		For nI := 1 To oCNBDetail:Length()
			oCNBDetail:GoLine(nI)
			nPos := aScan(aSldsFis,{|x| x[1] == oCNBDetail:GetValue("CNB_ITEM")})
			If nPos == 0
				CN300AddFis(oModel,oCNBDetail:GetValue("CNB_ITEM"),oCNBDetail:GetValue("CNB_PRODUT"),oCNBDetail:GetValue("CNB_QUANT"))
			EndIf
		Next nI
	EndIf
EndIf

FWRestRows(aSaveLines)
Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300AtCrgs()
Função para atualizar os cronogramas.

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
User function CN300AtCrs(oModel, lFailMsg)
	Local lResult	:= .T.
	Local bExec		:= Nil
	Default lFailMsg := .F.

	If lFailMsg
		bExec := {|x|CNAtuCrong(x)}
		lResult := CtrExecMsg(bExec, oModel, {"CN9MASTER", "CN9_NUMERO", "CN300ATCRS"})
	Else
		bExec := {||CNAtuCrong(oModel)}
		A300OpenMd(bExec, .T., .T., "STR0045")//Atualizando cronograma financeiro		
	EndIf

Return lResult

/*/{Protheus.doc} CNAtuCrong
	Função auxiliar ao método <CN300AtCrgs>. Realiza a atualização do cronograma financeiro. 
@author philipe.pompeu
@since 31/03/2022
@return Nil, indefinido
@param oModel, objeto, instância de MPFormModel
/*/
Static function CNAtuCrong(oModel)
	Local aSaveLines	:= FWSaveRows()
	Local aSldFis	 	:= {}
	Local aOldSldFis	:= {}

	Local oCN9Master 	:= Nil
	Local oCNFDetail 	:= Nil
	Local oCNSDetail 	:= Nil
	Local oCNADetail 	:= Nil
	Local oCNBDetail	:= Nil

	Local lCont 	:= .T.
	Local lArrasto	:= .F.
	Local lIncParcs := .F.
	Local lFisico 	:= .F.
	Local lOk		:= .F.
	Local cTpRev    := ""
	Local lVlPreFin	:= .F.
	Local nJuros	:= 0
	Local nI		:= 0

	If nModulo == 28 .Or. nModulo==87
		oModel := FwModelActive()
	EndIf

	If oModel:IsActive()
		oCNADetail	:= oModel:GetModel('CNADETAIL')
		
		If Cn300RetSt("MEDEVE") .Or. Cn300RetSt("RECORRENTE")
			Help('',1,'CN300NOFIN') //-- A planilha não possui cronograma financeiro.
			lCont := .F.
		ElseIf oCNADetail:IsInserted()
			Help('',1,'A300NPLAN') //Função não disponível para novas planilhas
			lCont := .F.
		EndIf

		If lCont
			cTpRev		:= Cn300RetSt("TIPREV")
			lFisico		:= Cn300RetSt("FISICO")
			oCN9Master	:= oModel:GetModel('CN9MASTER')
			oCNFDetail	:= oModel:GetModel('CNFDETAIL')
			oCNSDetail	:= oModel:GetModel('CNSDETAIL')
			oCNBDetail	:= oModel:GetModel('CNBDETAIL')
			lArrasto	:= oCN9Master:GetValue('CN9_ARRAST') == '1'
			lIncParcs 	:= oCN9Master:GetValue('CN9_TPCRON') == '1'
			CNTA300BlMd(oCNFDetail, .F.)
			CNTA300BlMd(oCNSDetail, .F.)
			A300OpenMd({||}, .F.)
			
			lVlPreFin := ValPresFin(oCN9Master, @nJuros)

			If (lFisico .Or. lVlPreFin)			
				For nI := 1 To oCNFDetail:Length()			
					oCNFDetail:Goline(nI)

					If !oCNFDetail:IsDeleted()					
						If lVlPreFin .And. (Empty(oCNFDetail:GetValue("CNF_VLREAL")) .Or. Empty(oCNFDetail:GetValue("CNF_TJUROS")))
							oCNFDetail:SetValue("CNF_TJUROS", nJuros)//Ao preencher CNF_TJUROS, CNF_VLPRES e CNF_VJUROS são preenchidos via trigger
						EndIf

						If 	(lFisico) .And.; //Apenas c/ cronograma fisico
							(Empty(oCNFDetail:Getvalue("CNF_DTREAL")) .Or. nI == oCNFDetail:Length()) .And.;
							(!Empty(aSldFis))//Como o campo de saldo a distribuir tem o valor identico para todos os itens do Fisico, pego o da primeira linha
							
							aSldFis := CN300SAdF(oCNSDetail)

							If !lVlPreFin //Caso não precise calcular valor presente
								Exit //Sai do loop, pois <aSldFis> só precisa ser carregado uma vez...
							EndIf
						EndIf
					EndIf
				Next nI
				oCNFDetail:Goline(1)//Volta p/ inicio
			EndIf

			If lIncParcs
				lOk := CN300IcPrc(oModel, aSldFis)
			Else
				aOldSldFis := CN300DlPrc(oModel)
				lOk := IIF(lFisico,(Len(aOldSldFis) > 0),.T.)
			EndIf

			If lOk
				If lFisico .And. !lIncParcs .And. Len(aOldSldFis) > 0
					CN300RecFis(oModel,aOldSldFis)
				EndIf

				If lArrasto
					If lFisico
						If oCNFDetail:Length(.T.) >= 1
							CN300ApArF(oModel)
						EndIf
					Else
						CN300ApAr(oModel)						
					EndIf
					If CNF->(ColumnPos("CNF_AMRTZA") > 0)
						CN300Amort(oModel)//Calcula a amortização linear
					EndIf
				EndIf

				CNTA300BlMd(oCNFDetail, ,.T.)

				oCNFDetail:GoLine(1)
				A300Revisa(oModel, cTpRev)

				oCN9Master:LoadValue('CN9_QTDPAR', 0)
				FWAlertInfo(STR0005,'CN300ATU')
			EndIf
		EndIf
	EndIf

	FWRestRows(aSaveLines)
	FwFreeArray(aSaveLines)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A300Titulo(oModel)
Função para processar os titulos provisórios

@author aline.sebrian
@since 24/02/2014
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static function A300Titulo(cContra,cRev,lMedeve,lRecorre)
	Local aArea 	:= GetArea()
	Local cRevAnt  	:= ""
	Local oModel	:= Nil
	Local lTemCrg	:= .F.
	Local cFilCtr	:= ""
	Default lRecorre:= .F.

	If (SuperGetMV("MV_CNPROVI",.F.,"S") == "S")
		cRevAnt := CnRevAnt()
		oModel	:= FwModelActive()
		cFilCtr := oModel:GetValue("CN9MASTER", "CN9_FILCTR")
		lTemCrg := HasCrgFin(cFilCtr, cContra, cRev, cRevAnt)//Verifica se alguma das planilhas possui cronograma financeiro

		If (lTemCrg .Or. lRecorre)
			CN100ETit(cContra,cRevAnt)	
			//-- Nao gera titulos quando a revisao for paralisacao
			If A300GATpRv() != DEF_REV_PARAL
				CN100CTit(cContra,cRev)//"Processa títulos provisórios"
				CN100RecTi(cContra,cRev)//"Processa títulos recorrentes"
			EndIf
		EndIf
	EndIf

	RestArea(aArea)
	FwFreeArray(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A300NwLine()
Verificação se a linha nos modelos CNA ou CNB são novas

@param cModel - modelo que será validado

@author guilherme.pimentel
@since 25/02/2014
@version 1.1
/*/
//-------------------------------------------------------------------
Static function A300NwLine(cModel)
	Local oModel	:= FWModelActive()
	Local oGrid	:= oModel:GetModel(cModel)
	Local lRet		:= oGrid:IsInserted()
	Local cRevAnt	:= '   '
	Local aAreaCNB	:= {}

	/*Para novos itens, caso a linha esteja inserida, retorna .T.
	Caso a linha não seja nova - o que ocorre se não for uma inclusão de item - verifica se existia na versão anterior.*/	
	If ! lRet .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE
		If cModel == 'CNBDETAIL'
			aAreaCNB := CNB->(GetArea())
			cRevAnt	:= CnRevAnt() //Novos itens - liberado
			lExiste := CNB->(dbSeek(xFilial("CNB")+oGrid:GetValue('CNB_CONTRA')+cRevAnt+oGrid:GetValue('CNB_NUMERO')+oGrid:GetValue('CNB_ITEM')))
			lRet	:= !lExiste
			CNB->(RestArea(aAreaCNB))
		EndIf	
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300DtRei(oModel)
Função para validar a data prevista para o reinicio do contrato

@author aline.sebrian
@since 24/02/2014
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static function A300DtRei()
Local lRet := .T.
If M->CN9_DTFIMP <= ddatabase
	Help('',1,'CNTA300DTREI')
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300Aprov(oModel,cRev,lMedeve,lRecorre)
Função para atualizar a aprovação do contrato

@author aline.sebrian
@since 21/02/2014
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------

Static function A300Aprov(oModel,cRev,lMedeve,lRecorre, oSay)
Local aArea     	:= {}
Local aAreaCND		:= {} 
Local cContra		:= ""
Local lFluig		:= .F.
Local lAvlFor		:= .F.
Local cChave		:= ""
Local lView			:= .F.
Local nReajTotal	:= 0
Default lRecorre	:= .F.
Default oSay		:= Nil

If (!IsBlind() .And. oSay == Nil)
	Return FwMsgRun(, {|x| A300Aprov(oModel,cRev,lMedeve,lRecorre, x)}, "STR0037", "STR0039")
EndIf

aArea     	:= GetArea()
cContra		:= Iif(!Empty(CN9->CN9_NUMERO),CN9->CN9_NUMERO, oModel:GetValue("CN9MASTER","CN9_NUMERO"))
lFluig		:= SuperGetMV("MV_APWFECM",.F.,"1") == "1" .And. !Empty(AllTrim(GetNewPar("MV_ECMURL",""))) .And. FWWFFluig()
lAvlFor		:= (GetNewPar( "MV_CNSITAL", "S" ) == "S") .And. !lFluig
lView		:= (!IsBlind() .And. ValType(oSay) == "O")


CnCauAtu(oModel,cRev) //Atualiza caução manual

//Caso alguma aplicação tenha trocado o modelo de dados ativo, reativa o modelo em uso.
FwModelActive(oModel)

CnSitAtu(cContra,cRev)//Atualiza situacao da revisao anterior para 10-Revisado

CNContab("69G")	//Lançamento Contábil na Aprovação da Revisao

If lView
	oSay:SetText( STR0026 )//"Processando títulos provisórios"
	ProcessMessage()
EndIf
A300Titulo(cContra,cRev,lMedeve,lRecorre)//Processa titulos provisorios das parcelas

//Caso alguma aplicação tenha trocado o modelo de dados ativo, reativa o modelo em uso.
FwModelActive(oModel)

If lAvlFor	 .And. (A300GATpRv() == DEF_REV_PARAL .OR. A300GATpRv() == DEF_REV_REINI) .And. CN9->CN9_ESPCTR <> '2'
	CN220Aval("CNM",,MODEL_OPERATION_UPDATE,,.F.,IF(A300GATpRv()==DEF_REV_PARAL,DEF_SPARA,DEF_SVIGE),,,cContra,cRev)
EndIf

dbSelectArea("CND")
aAreaCND := CND->(GetArea())
CND->(dbSetOrder(1))

cChave := xFilial("CND",oModel:GetValue("CN9MASTER","CN9_FILCTR")) + oModel:GetValue("CN9MASTER","CN9_NUMERO")
cChave += oModel:GetValue("CN9MASTER","CN9_REVISA")

If !CND->(dbSeek( cChave))/*Verifica se a medicao ja foi revisada na inclusao da revisao, devido ao legado.*/
	
	If lView
		oSay:SetText( "STR0040" )//"Atualizando medições, aguarde..."
		ProcessMessage()
	EndIf
	//Tratamento de revisao de contrato, na inclusão ou exclusao de revisao
	CNA300RvMd(oModel:GetValue("CN9MASTER","CN9_NUMERO"),CnRevAnt(),oModel:GetValue("CN9MASTER","CN9_REVISA"),oModel:GetValue("CN9MASTER","CN9_FILCTR"))
	
	//Função para reajustar ou realinhar medição.
	nReajTotal := A300AtuMed(oModel)		
EndIf

If lView
	oSay:SetText( "STR0041" )//"Atualizando pedidos"
	ProcessMessage()
EndIf
//Tratamento no pedido de Compra/Venda
CN300RevPd(oModel, nReajTotal)

//Chama a contabilização da aprovação da revisão, por item da planilha
CN100ConIt( "69N" )

//Caso alguma aplicação tenha trocado o modelo de dados ativo, reativa o modelo em uso.
FwModelActive(oModel)

RestArea(aAreaCND)
RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VDCRF()
Valida cronograma físico

@author Antenor Silva
@since 30/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function CN300VdCrf(oModel)
Local oStruCNS 	:= oModel:GetModel('CNSDETAIL'):GetStruct()
Local oStruCNF 	:= oModel:GetModel('CNFDETAIL'):GetStruct()

If Cn300RetSt("FISICO",2)
	oStruCNS:SetProperty('CNS_PRVQTD',MODEL_FIELD_WHEN,{||.T.})
	oStruCNS:SetProperty('CNS_DISTSL',MODEL_FIELD_WHEN,{||.T.})
	oStruCNS:SetProperty('CNS_SLDQTD',MODEL_FIELD_WHEN,{||.T.})
	oStruCNS:SetProperty('CNS_TOTQTD',MODEL_FIELD_WHEN,{||.T.})
	oStruCNS:SetProperty('CNS_TOTQTD',MODEL_FIELD_WHEN,{||.T.})
	CNTA300BlMd(oModel:GetModel('CNFDETAIL'), .T.,.T.)

	oStruCNF:SetProperty('CNF_SALDO',MODEL_FIELD_WHEN,{||.T.})
Else
	oStruCNF:SetProperty('CNF_SALDO',MODEL_FIELD_WHEN,{||.T.})
	oStruCNS:SetProperty('CNS_PRVQTD',MODEL_FIELD_WHEN,{||.F.})
EndIf

oStruCNF:SetProperty('CNF_VLPREV',MODEL_FIELD_WHEN,{||!Cn300RetSt("FISICO")})

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} cn300EspVld()
Bloqueia e desbloqueia campos de acordo com a especie da Revisão de Aditivo

@author Aline Sebrian
@since 29/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function cn300EspVld( oModel, cTpRev )
Local oModCN9	:= oModel:GetModel('CN9MASTER')
Local oModCNB 	:= oModel:GetModel('CNBDETAIL')
Local oModCNA 	:= oModel:GetModel('CNADETAIL')
Local oModCNF 	:= oModel:GetModel('CNFDETAIL')
Local oModCXM 	:= oModel:GetModel('CXMDETAIL')
Local oStruCN9 	:= oModCN9:GetStruct()
Local aCTBEnt	:= CTBEntArr()
Local cModo     := Cn300RetSt("MODALIDADE")
Local cEspec    := Cn300RetSt("REVESPECIE")
Local lEventual	:= Cn300RetSt("EVENTUAL")
Local lSemiProd := Cn300RetSt("SEMIPROD")
Local lSemiAgru := Cn300RetSt("SEMIAGRUP")
Local lServico	:= CN300RetSt('SERVIÇO')
Local lNovCrgFin:= Empty(oModel:GetValue('CNFDETAIL','CNF_NUMERO'))
Local aCampos   := {}
Local nX 		:= 0
Local lVlPreFin := ValPresFin()
Local bNwLineCNA:= FwBuildFeature( STRUCT_FEATURE_WHEN, "A300NwLine('CNADETAIL')")
Local bNwLineCNB:= FwBuildFeature( STRUCT_FEATURE_WHEN, "A300NwLine('CNBDETAIL')")
Default cTpRev  := ""

If !Empty(cEspec)
	If cModo == '2'
		oModCNA:SetNoInsertLine(.T.)
		oModCNB:SetNoInsertLine(.T.)
	EndIf

    If cEspec == '1' //Aditivo de Quantidade

		//Se tipo do contrato for CN1_MEDEVE = "1", CN1_CTRFIX = "2" a revisão de aditivo de quantidade não será permitida (bloqueio planilha, libera apenas cabecalho).
		If lEventual .And. CN0->CN0_ESPEC $ '1|4'
			//Modelos e campos a serem alterados
			aAdd(aCampos,{'CN9MASTER',{'CN9_UNVIGE','CN9_DTFIM','CN9_ASSINA'}})
			If oModCN9:GetValue('CN9_UNVIGE') != '4'
				aAdd(aCampos,{'CN9MASTER',{'CN9_VIGE'}})
			EndIf
			aAdd(aCampos,{'CNWDETAIL',{'CNW_COMPET','CNW_DTPREV','CNW_VLPREV','CNW_HIST','CNW_CC', 'CNW_ITEMCT', 'CNW_CLVL'}})
			MtBCMod(oModel,aCampos,{||FwFldGet("CNW_FLGAPR")<>"1"},'2')
			//Limpeza do array para uso posterior
			aCampos := {}

		Else
			//Modelos e campos a serem alterados a qualquer momento
			oStruCN9:SetProperty('CN9_REDVAL',MODEL_FIELD_WHEN,{|| oModCN9:GetValue("CN9_ARRAST") == '1' })
			aCampos := {}
			aAdd(aCampos,{'CN9MASTER',{'CN9_ARRAST','CN9_REDVAL','CN9_QTDPAR','CN9_TPCRON', 'CN9_CPARCA', 'CN9_CPARCV', 'CN9_TPCROC', 'CN9_QTPARC', 'CN9_UDMES'}})
			If lVlPreFin
				aAdd(aCampos[1,2], 'CN9_TJUFIN')
			EndIf
			aAdd(aCampos,{'CNFDETAIL',{'CNF_VLPREV','CNF_SALDO'}})
			If lSemiProd .Or. lEventual
				aAdd(aCampos,{'CNADETAIL',{'CNA_VLTOT'}})
			EndIf

			aAdd(aCampos,{'CNZDETAIL',{'CNZ_ITEM','CNZ_PERC','CNZ_CC','CNZ_CONTA','CNZ_ITEMCT','CNZ_CLVL'}})

			If lSemiAgru
				aAdd(aCampos,{'CXMDETAIL',{'CXM_VLMAX'}})
			Else
				aAdd(aCampos,{'CNBDETAIL',{'CNB_VLTOT','CNB_QTRDAC','CNB_QTRDRZ','CNB_SLDREC','CNB_SLDMED','CNB_DESC','CNB_VLDESC','CNB_CONTA','CNB_ITEMCT','CNB_CC','CNB_CLVL'}})
				If !lSemiProd .And. !lServico
					aAdd(aCampos,{'CNBDETAIL',{'CNB_QUANT'}})
				EndIf
				If CNB->( ColumnPos( "CNB_ARREND" ) ) > 0
					aAdd( aCampos, { "CNBDETAIL", {"CNB_ARREND"} } )
				EndIf
			EndIf

			For nX := 1 To Len(aCTBEnt)
				aAdd(aCampos,{'CNZDETAIL', {"CNZ_EC" +aCTBEnt[nX] +"CR" }})
				aAdd(aCampos,{'CNZDETAIL', {"CNZ_EC" +aCTBEnt[nX] +"DB" }})
			Next nX
			MtBCMod(oModel,aCampos,{||.T.},'2')

			//Liberação da inclusão de Planilhas
			aCampos := {}
			aAdd(aCampos,{'CNADETAIL',{'CNA_FORNEC','CNA_LJFORN','CNA_CLIENT', 'CNA_LOJACL', 'CNA_TIPPLA','CNA_FLREAJ','CNA_DESCRI','CNA_INDICE','CNA_UNPERI','CNA_PERI','CNA_DTINI','CNA_DTFIM', 'CNA_PERIOD','CNA_PERREC','CNA_QTDREC','CNA_DIASEM','CNA_CONDPG','CNA_NATURE','CNA_DESCPL'}})
			MtBCMod(oModel,aCampos,bNwLineCNA,'2')

			If lSemiAgru
				//- Liberação dos Agrupadores
				aCampos := {}
				aAdd(aCampos,{'CXMDETAIL',{'CXM_AGRTIP','CXM_AGRGRP','CXM_AGRCAT','CXM_CC'}})
				MtBCMod(oModel,aCampos,{||A300NwLine('CXMDETAIL')},'2')
			Else
				//Liberação da inclusão de Itens da planilha
				aCampos := {}
				aAdd(aCampos,{'CNBDETAIL',{'CNB_PRODUT','CNB_DESCRI','CNB_UM','CNB_VLUNIT','CNB_TE','CNB_TS','CNB_PEDTIT','CNB_TABPRC','CNB_INDICE','CNB_FLREAJ','CNB_CONTA','CNB_ITEMCT','CNB_CC','CNB_CLVL','CNB_DTPREV'}})
				For nX := 1 To Len(aCTBEnt)
					If CNB->(FieldPos("CNB_EC" +aCTBEnt[nX] +"CR")) > 0
						aAdd(aCampos,{'CNBDETAIL', {"CNB_EC" +aCTBEnt[nX] +"CR" }})
						aAdd(aCampos,{'CNBDETAIL', {"CNB_EC" +aCTBEnt[nX] +"DB" }})
					EndIf
				Next nX
				MtBCMod(oModel,aCampos,bNwLineCNB,'2')
			EndIf

			//Verificação no cronograma físico
			CN300VdCrf(oModel)
			aCampos := {}
			aAdd(aCampos,{'CNWDETAIL',{'CNW_DTPREV'}})
			MtBCMod(oModel,aCampos,{||.F.},'2')
			
		EndIf
    ElseIf cEspec == '3' //Aditivo de Prazo
		//Modelos e campos a serem alterados a qualquer momento
		aCampos := {}
		aAdd(aCampos,{'CN9MASTER',{'CN9_ARRAST','CN9_REDVAL','CN9_QTDPAR','CN9_TPCRON','CN9_UDMES','CN9_UNVIGE','CN9_VIGE','CN9_DTFIM','CN9_ASSINA','CN9_SALDO'/*Remover campos dos parâmetros*/}})
		If lVlPreFin
			aAdd(aCampos[1,2], 'CN9_TJUFIN')
		EndIf
		aAdd(aCampos,{'CNFDETAIL',{'CNF_VLPREV','CNF_SALDO','CNF_COMPET','CNF_DTVENC','CNF_PRUMED','CNF_TXMOED','CNF_CONDPG'}})
		aAdd(aCampos,{'CNADETAIL',{'CNA_DTINI','CNA_DTFIM','CNA_PERIOD','CNA_PERREC','CNA_QTDREC','CNA_DIASEM','CNA_DIAMES','CNA_PROMED'}})
		If !lSemiAgru
			aAdd(aCampos,{'CNBDETAIL',{'CNB_ATIVO','CNB_PARPRO'}})
		EndIf
		MtBCMod(oModel,aCampos,{||.T.},'2')

	ElseIf cEspec =='4' //Aditivo de Quantidade/Prazo
		//Modelos e campos a serem alterados a qualquer momento
		oStruCN9:SetProperty('CN9_REDVAL',MODEL_FIELD_WHEN,{|| oModCN9:GetValue("CN9_ARRAST") == '1' })
		aCampos := {}
		aAdd(aCampos,{'CN9MASTER',{'CN9_ARRAST','CN9_REDVAL','CN9_QTDPAR','CN9_TPCRON', 'CN9_UDMES','CN9_UNVIGE','CN9_VIGE','CN9_DTFIM','CN9_DTFIM','CN9_ASSINA','CN9_CPARCA','CN9_CPARCV'}})
		If lVlPreFin
			aAdd(aCampos[1,2], 'CN9_TJUFIN')
		EndIf

		aAdd(aCampos,{'CNFDETAIL',{'CNF_VLPREV','CNF_SALDO','CNF_COMPET','CNF_DTVENC','CNF_PRUMED','CNF_TXMOED','CNF_CONDPG'}})
		aAdd(aCampos,{'CNADETAIL',{'CNA_DTINI','CNA_DTFIM','CNA_PERIOD','CNA_PERREC','CNA_QTDREC','CNA_DIASEM','CNA_DIAMES','CNA_PROMED'}})
		If lSemiProd .Or. lEventual
			aAdd(aCampos,{'CNADETAIL',{'CNA_VLTOT'}})
		EndIf

		aAdd(aCampos,{'CNZDETAIL',{'CNZ_ITEM','CNZ_PERC','CNZ_CC','CNZ_CONTA','CNZ_ITEMCT','CNZ_CLVL'}})

		If lSemiAgru
			aAdd(aCampos,{'CXMDETAIL',{'CXM_AGRGRP','CXM_AGRCAT','CXM_VLMAX'}})
		Else
			aAdd(aCampos,{'CNBDETAIL',{'CNB_VLTOT','CNB_QTRDAC','CNB_QTRDRZ','CNB_SLDREC','CNB_SLDMED','CNB_DESC','CNB_VLDESC','CNB_ATIVO','CNB_PARPRO','CNB_CONTA','CNB_CC','CNB_ITEMCT','CNB_CLVL'}})
			If !lSemiProd .And. !lServico
				aAdd(aCampos,{'CNBDETAIL',{'CNB_QUANT'}})
			EndIf
			If CNB->( ColumnPos( "CNB_ARREND" ) ) > 0
				aAdd( aCampos, { "CNBDETAIL", {"CNB_ARREND"} } )
			EndIf
		EndIf
		For nX := 1 To Len(aCTBEnt)
			aAdd(aCampos,{'CNZDETAIL', {"CNZ_EC" +aCTBEnt[nX] +"CR" }})
			aAdd(aCampos,{'CNZDETAIL', {"CNZ_EC" +aCTBEnt[nX] +"DB" }})
		Next nX

		MtBCMod(oModel,aCampos,{||.T.},'2')				
		
		//Liberação da inclusão de Planilhas
		aCampos := {}
		aAdd(aCampos,{'CNADETAIL',{'CNA_FORNEC','CNA_LJFORN','CNA_CLIENT', 'CNA_LOJACL','CNA_TIPPLA','CNA_FLREAJ','CNA_DESCRI','CNA_INDICE','CNA_UNPERI','CNA_PERI','CNA_DESCPL'}})
		MtBCMod(oModel,aCampos,bNwLineCNA,'2')

		If lSemiAgru
			//- Liberação dos Agrupadores
			aCampos := {}
			aAdd(aCampos,{'CXMDETAIL',{'CXM_AGRTIP','CXM_CC'}})
			MtBCMod(oModel,aCampos,{||A300NwLine('CXMDETAIL')},'2')
		Else
			//Liberação da inclusão de Itens da planilha
			aCampos := {}
			aAdd(aCampos,{'CNBDETAIL',{'CNB_PRODUT','CNB_DESCRI','CNB_UM','CNB_VLUNIT','CNB_TE','CNB_TS','CNB_PEDTIT','CNB_TABPRC','CNB_INDICE','CNB_FLREAJ','CNB_CONTA','CNB_ITEMCT','CNB_CC','CNB_CLVL', 'CNB_DTPREV'}})
			For nX := 1 To Len(aCTBEnt)
				If CNB->(FieldPos("CNB_EC" +aCTBEnt[nX] +"CR")) > 0
					aAdd(aCampos,{'CNBDETAIL', {"CNB_EC" +aCTBEnt[nX] +"CR" }})
					aAdd(aCampos,{'CNBDETAIL', {"CNB_EC" +aCTBEnt[nX] +"DB" }})
				EndIf
			Next nX

			MtBCMod(oModel,aCampos,{||A300NwLine('CNBDETAIL')},'2')
		EndIf

		//Verificação no cronograma físico
		CN300VdCrf(oModel)

	ElseIf cEspec =='5' // Todos

		//Modelos e campos a serem alterados a qualquer momento
		oStruCN9:SetProperty('CN9_REDVAL',MODEL_FIELD_WHEN,{|| oModCN9:GetValue("CN9_ARRAST") == '1' })
		aCampos := {}
		aAdd(aCampos,{'CN9MASTER',{'CN9_ARRAST','CN9_REDVAL','CN9_QTDPAR','CN9_TPCRON', 'CN9_UDMES','CN9_UNVIGE','CN9_VIGE','CN9_DTFIM','CN9_ASSINA', 'CN9_CPARCA', 'CN9_CPARCV',  'CN9_TPCROC', 'CN9_QTPARC', 'CN9_CONDPG','CN9_DESCPG','CN9_VLATU'}})
		If lVlPreFin
			aAdd(aCampos[1,2], 'CN9_TJUFIN')
		EndIf

		aAdd(aCampos,{'CNFDETAIL',{'CNF_VLPREV','CNF_SALDO','CNF_COMPET','CNF_DTVENC','CNF_PRUMED','CNF_TXMOED','CNF_CONDPG'}})
		aAdd(aCampos,{'CNTDETAIL',{'CNT_VLRET' }})
		aAdd(aCampos,{'CNADETAIL',{'CNA_DTINI','CNA_DTFIM','CNA_PERIOD','CNA_PERREC','CNA_QTDREC','CNA_DIASEM','CNA_DIAMES','CNA_PROMED'}})
		If lSemiProd .Or. lEventual
			aAdd(aCampos,{'CNADETAIL',{'CNA_VLTOT'}})
		EndIf

		aAdd(aCampos,{'CNZDETAIL',{'CNZ_ITEM','CNZ_PERC','CNZ_CC','CNZ_CONTA','CNZ_ITEMCT','CNZ_CLVL'}})

		For nX := 1 To Len(aCTBEnt)
			aAdd(aCampos,{'CNZDETAIL', {"CNZ_EC" + aCTBEnt[nX] + "CR"}})
			aAdd(aCampos,{'CNZDETAIL', {"CNZ_EC" + aCTBEnt[nX] + "DB"}})
		Next nX

		If lSemiAgru
			aAdd(aCampos,{'CXMDETAIL',{'CXM_AGRGRP','CXM_AGRCAT','CXM_VLMAX'}})
		Else
			aAdd(aCampos,{'CNBDETAIL',{'CNB_VLUNIT','CNB_VLTOT','CNB_QTRDAC','CNB_QTRDRZ','CNB_SLDREC','CNB_SLDMED','CNB_DESC','CNB_VLDESC','CNB_REALI','CNB_DTREAL','CNB_VLTOTR','CNB_ATIVO','CNB_PARPRO','CNB_CONTA' ,'CNB_CC','CNB_CLVL','CNB_ITEMCT'}})
			nX := Len(aCampos)
			Aeval(aCTBEnt,{|cSeq| AAdd(aCampos[nX,2],"CNB_EC"+cSeq+"CR"),AAdd(aCampos[nX,2],"CNB_EC"+cSeq+"DB")})
			If !lSemiProd .AND. !lServico
				aAdd(aCampos,{'CNBDETAIL',{'CNB_QUANT'}})
			EndIf
			If CNB->( ColumnPos( "CNB_ARREND" ) ) > 0
				aAdd( aCampos, { "CNBDETAIL", {"CNB_ARREND"} } )
			EndIf
		EndIf

		MtBCMod(oModel,aCampos,{||.T.},'2')

		//Liberação da inclusão de Planilhas
		aCampos := {}
		aAdd(aCampos,{'CNADETAIL',{'CNA_FORNEC','CNA_LJFORN','CNA_CLIENT', 'CNA_LOJACL','CNA_TIPPLA','CNA_FLREAJ','CNA_DESCRI','CNA_INDICE','CNA_UNPERI','CNA_PERI','CNA_RPGANT','CNA_CONDPG','CNA_NATURE','CNA_DESCPL'}})
		MtBCMod(oModel,aCampos,bNwLineCNA,'2')

		//Liberação da inclusão de Itens da planilha
		If lSemiAgru
			aCampos := {}
			aAdd(aCampos,{'CXMDETAIL',{'CXM_AGRTIP','CXM_CC'}})
			MtBCMod(oModel,aCampos,{||A300NwLine('CXMDETAIL')},'2')
		Else
			aCampos := {}
			aAdd(aCampos,{'CNBDETAIL',{'CNB_PRODUT','CNB_DESCRI','CNB_UM','CNB_TE','CNB_TS','CNB_PEDTIT','CNB_TABPRC','CNB_INDICE','CNB_FLREAJ', 'CNB_DTPREV'}})
			MtBCMod(oModel,aCampos,{||A300NwLine('CNBDETAIL')},'2')
		EndIf

		//Verificação no cronograma físico
		CN300VdCrf(oModel)
	EndIf

	If lEventual
		CNTA300BlMd( oModCNB, .T. )
		CNTA300BlMd( oModel:GetModel("CNZDETAIL"), .T. )
		If cEspec == '3'
			oModCNA:SetNoInsertLine(.T.)		
		EndIf
		If(cEspec $ "1|4|5" )
			MtBCMod(oModel,{{'CNADETAIL',{'CNA_VLTOT'}}},{||Cn300RetSt('PREVFINANC')},'2')//Permitir alteracao apenas em casos que exista previsao financeira.
		EndIf
	ElseIf cEspec $ "1|4|5" .And. !lSemiAgru
		CNTA300BlMd( oModCNB, .F. )
		CNTA300BlMd( oModel:GetModel("CNZDETAIL"), .F. )
	EndIf

	If lNovCrgFin
		oModCNF:SetNoUpdateLine(.T.)
	EndIf

	If cModo == '2'
		oModCNA:SetNoInsertLine(.T.)
		oModCNB:SetNoInsertLine(.T.)
		oModCXM:SetNoInsertLine(.T.)
	EndIf
	If lServico
		MtBCMod(oModel,{{'CNBDETAIL',{'CNB_QUANT'}}},{||.F.},'2')
    EndIf
	If !Empty(oModCN9:GetValue("CN9_CODED"))
		CNTA300BlMd(oModCNB,.F.,)
	EndIf
EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} cn300vlMod()
Valida a quantidade de acordo com a Modalidade da Revisão

@author José Eulálio
@since 29/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function cn300vlMod()
Local aArea	:= GetArea()
Local lRet     := .T.
Local cModo    := Cn300RetSt("MODALIDADE")
Local cEspec   := Cn300RetSt("REVESPECIE")
Local oModel	:= FwModelActive()
Local oModCNB	:= oModel:GetModel("CNBDETAIL")
Local cTipRev	:= A300GTpRev()

If cTipRev $ DEF_REV_ADITI+'|'+DEF_REV_RENOV+'|'+DEF_REV_ORCGS+'|'+DEF_REV_ABERT
	If cEspec == '3'
		lRet	:= .F.
	Else
		//Quando for apenas acrescimo
		If cModo == "1"
			lRet	:= (oModCNB:GetValue("CNB_QUANT") >= oModCNB:GetValue("CNB_QTDORI"))
		//Quando for apenas decrescimo
		ElseIf cModo == "2"
			lRet	:= (oModCNB:GetValue("CNB_QUANT") <= oModCNB:GetValue("CNB_QTDORI"))
		//Quando for ambos
		ElseIf cModo == "3"
			lRet	:= .T.
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} cn300ParLoad()
Acrescimo e Decrescimo das parcelas durante a revisão do contrato

@author aline.sebrian
@since 27/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function cn300ParLoad()
Local lConfirm 	:= .F.

lConfirm 	:= MsgYesNo(STR0023)	//"Deseja acrescentar parcelas  " # "?")

Return lConfirm

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300REAJU()
Função de cálculo para a revisão de reajuste

@author guilherme.pimentel
@since 23/01/2014
@version 1.1
/*/
//-------------------------------------------------------------------
Static function CN300REAJU(oModel, nValorRj, oView)
Local aSaveLines	:= {}
Local aWhenModels	:= {}
Local oModelCN9	:= Nil
Local oModelCNA	:= Nil
Local oModelCNB	:= Nil
Local oModelCNF := Nil
Local oModelCXM := Nil

Local nVlrInd	 := 0
Local nVlrUn	 := 0
Local nVlrReaj	 := 0
Local nSldReaj	 := 0
Local nVlrNRec	 := 0
Local nVlTotOri	 := 0
Local nLineCNB	 := 0
Local nCN300VRJ	 := 0
Local nX		 := 0
Local nY		 := 0

Local lRevMed 	 := .F.
Local lFisico 	 := .F.
Local lFixo		 := .F.
Local lPrevF	 := .F.
Local lContabil	 := .F.
Local lSemiFixo	 := .F.
Local lSemiAgru	 := .F.
Local lSemiProd	 := .F.
Local lVldReaj 	 := .F.
Local lAgrZer	 := .F.
Local lRet 		 := .T.

Local cTipoCtr 	 := ""
Local cIndice	 := ""
Local cIndCabec	 := ""
Local cTipPla	 := ""
Local cModoReaj	 := ""
Local cMdRjCabec := ""
Local cItemDest	 := ""

Local dDataRef	 := CtoD("")
Local dDataApl	 := CtoD("")
Local cCodTpRev	 := ""
Local dDtRjAnt   := CtoD("")
Local dDtPrxRj   := CtoD("")

//Variaveis para calculo de Pro Rata
Local cProRatCN9 := ""
Local lProRata 	 := .F.
Local cProRatCNA := ""
Local cUniPeri	 := ""
Local nPeri		 := 0
Local lCN300VRJ  := .F.
Local lPermReaj  := .F.
Local lAmortiza	 := .F.
Default nValorRj := 0

If (!IsBlind() .And. ValType(oView) == "O" )
	FwMsgRun(, {|| lRet := CN300REAJU(oModel, nValorRj)}, "STR0037", "STR0038")//Reajustando contrato 	
	If(!lRet .And. oView:HasError())
		oView:ShowLastError()
	EndIf
	Return lRet
EndIf

aSaveLines	:= FWSaveRows()
oModelCN9	:= oModel:GetModel('CN9MASTER')
oModelCNA	:= oModel:GetModel('CNADETAIL')
oModelCNB	:= oModel:GetModel('CNBDETAIL')
oModelCNF	:= oModel:GetModel('CNFDETAIL')
oModelCXM	:= oModel:GetModel('CXMDETAIL')
cTipoCtr	:= oModelCN9:GetValue("CN9_TPCTO")
cIndice		:= oModelCN9:GetValue("CN9_INDICE")
dDataRef	:= oModelCN9:GetValue("CN9_DREFRJ")
dDataApl	:= oModelCN9:GetValue("CN9_DTREAJ")
cCodTpRev	:= oModel:GetValue('CN9MASTER','CN9_TIPREV')
cProRatCN9	:= oModelCN9:GetValue("CN9_PRORAT")

lPermReaj := (oModelCN9:GetValue("CN9_FLGREJ") == '1')
lAmortiza := CNF->(ColumnPos("CNF_AMRTZA") > 0)

If A300GUsrBt()
	lRet := .F.
	Help('',1,'A300Unic') //Funcao somente pode ser executada 1 vez
ElseIf !(A300GTpRev() $ DEF_REV_REAJU+"|"+DEF_REV_ABERT)
	lRet := .F.
	Help('',1,'A300REVREAJ') //Somente revisao de reajuste
ElseIf Empty(dDataRef)
	lRet := .F.
	Help('',1,'A300REF') //Data de referencia nao preenchida
ElseIf Empty(dDataApl)
	lRet := .F.
	Help('',1,'A300REAJ') //Data do reajuste nao preenchida
ElseIf Empty(oModelCN9:GetValue("CN9_TIPREV"))
	lRet := .F.
	Help('',1,'A300TIPREV') // Deve ser informado o tipo de revisão
ElseIf A300ApReRet(cCodTpRev) .And.(A300GTpRev() == DEF_REV_REAJU .Or. A300GTpRev() == DEF_REV_REALI )
	If (!Empty(oModelCN9:GetValue('CN9_DTRRDE')) .And. Empty(oModelCN9:GetValue('CN9_DTRRAT'))) .Or.;
		(Empty(oModelCN9:GetValue('CN9_DTRRDE')) .And. !Empty(oModelCN9:GetValue('CN9_DTRRAT'))) .Or. ;
		oModelCN9:GetValue('CN9_DTRRDE') > oModelCN9:GetValue('CN9_DTRRAT')
		lRet := .F.
		Help(" ",1,"A300EMPTDT",,STR0014,1,1)
	EndIf
EndIf

If lRet
	aWhenModels := {GCTGetWhen(oModelCNA),;
					GCTGetWhen(oModelCNB),;
					GCTGetWhen(oModelCNF)}

	cUniPeri := oModelCN9:GetValue('CN9_UNPERI')
	nPeri 	 := oModelCN9:GetValue('CN9_PERI')
	
	//Efetua cálculo da data do próximo reajuste
	dDtPrxRj := CN300DtPrxRj(dDataApl, cUniPeri, nPeri,lPermReaj )
	If CN9->(Columnpos('CN9_PROXRJ')) > 0
		oModelCN9:GetStruct():SetProperty('CN9_PROXRJ',MODEL_FIELD_WHEN,{||.T.})
		oModelCN9:SetValue('CN9_PROXRJ',dDtPrxRj)
		oModelCN9:GetStruct():SetProperty('CN9_PROXRJ',MODEL_FIELD_WHEN,{||.F.})
	EndIf
	
	lCN300VRJ  := ExistBlock("CN300VRJ")
	A300OpenMd({||},.F.) //-- Abre o Modelo
	oModelCNB:GetStruct():SetProperty("*",MODEL_FIELD_WHEN,{||.T.})

	// Roda Planilhas e aplica Reajuste
	For nX := 1 to oModelCNA:Length()
		oModelCNA:GoLine(nX)

		//Efetua reajuste apenas para planilhas habilitadas
		If 	oModelCNA:GetValue('CNA_FLREAJ') <> '2' .And. oModelCNA:GetValue("CNA_SALDO") > 0 .And.;			
			(Empty(oModelCNA:GetValue('CNA_PROXRJ')) .Or. oModelCNA:GetValue('CNA_PROXRJ') <= dDataApl .Or.  oModelCNA:GetValue('CNA_PRORAT') == '1' )

			cTipPla		:= oModelCNA:GetValue("CNA_TIPPLA")
			lRevMed 	:= A300RevMed(0)

			lFisico		:= CN300PlaSt("FISICO"		,cTipoCtr,cTipPla)
			lFixo		:= CN300PlaSt("FIXO"		,cTipoCtr,cTipPla)
			lPrevF		:= CN300PlaSt("PREVFINANC"	,cTipoCtr,cTipPla)
			lContabil	:= CN300PlaSt("CONTABIL"	,cTipoCtr,cTipPla)
			lSemiFixo	:= Cn300PlaSt("SEMIFIXO"	,cTipoCtr,cTipPla)
			lSemiAgru	:= Cn300PlaSt("SEMIAGRUP"	,cTipoCtr,cTipPla)
			lSemiProd	:= Cn300PlaSt("SEMIPROD"	,cTipoCtr,cTipPla)

			nVlrReaj	:= 0
			nVlTotOri	:= oModelCNA:GetValue("CNA_VLTOT") // Guarda valor inicial da CNA para usar no cronograma
			cProRatCNA	:= oModelCNA:GetValue('CNA_PRORAT')

			// Resgata parâmetros para o reajuste
			cIndCabec	:= If(Empty(oModelCNA:GetValue("CNA_INDICE")), oModelCN9:GetValue("CN9_INDICE"), oModelCNA:GetValue("CNA_INDICE"))
			cMdRjCabec 	:= If(Empty(oModelCNA:GetValue("CNA_MODORJ")), oModelCN9:GetValue("CN9_MODORJ"), oModelCNA:GetValue("CNA_MODORJ"))
			cUniPeri 	:= oModelCNA:GetValue('CNA_UNPERI')
			nPeri 	 	:= oModelCNA:GetValue('CNA_PERI')

			If Empty(cUniPeri)
				cUniPeri := oModelCN9:GetValue('CN9_UNPERI')
			EndIf

			If Empty(nPeri)
				nPeri 	 := oModelCN9:GetValue('CN9_PERI')
			EndIf

			// Se for contrato não FIXO e não SEMIFIXO(PRODUTO) atualizará apenas as  planilhas, pois  esta não possuem itens
			If (!lFixo .And. !lSemiProd)
				If lPrevF //- Se sem previsão financeira, não é necessário reajustar.
					dDtRjAnt := If( Empty(oModelCNA:GetValue("CNA_DTREAJ")) , oModelCNA:GetValue('CNA_DTINI') , oModelCNA:GetValue("CNA_DTREAJ") )
					dDtPrxRj := oModelCNA:GetValue("CNA_PROXRJ")

					// Validar se efetuará o reajuste
					lVldReaj := CN300RjVld(cMdRjCabec, dDataApl, dDtRjAnt, dDtPrxRj)

					//Efetua o reajuste da planilha
					If lVldReaj
						If lRevMed
							nVlrNRec := A300SldRec('n2','')
						EndIf

						If lSemiAgru
							oModelCXM:SetNoUpdateLine(.F.)
							lAgrZer := .F.
							For nY := 1 to oModelCXM:Length()
								oModelCXM:GoLine(nY)
								nVlrInd	:= A300VlrInd(cIndCabec,dDataRef)
								nVlrUn 	:= Round( oModelCXM:GetValue('CXM_VLMAX') * nVlrInd, TamSx3("CXM_VLMAX")[2] )
								If NVlrUn != 0
									oModelCXM:SetValue('CXM_VLMAX',nVlrUn)
								Else
									lAgrZer := .T.
								EndIf
							Next nY
							oModelCXM:SetNoUpdateLine(.T.)
						EndIf

						If !lSemiAgru .Or. lAgrZer
							nSldReaj := (oModelCNA:GetValue("CNA_SALDO")+nVlrNRec)
							nVlrReaj := Round(nSldReaj*A300VlrInd(cIndCabec,dDataRef),TamSx3("CNA_VLTOT")[2]) - nSldReaj

							oModelCNA:SetValue("CNA_VLTOT",oModelCNA:GetValue("CNA_VLTOT")+nVlrReaj)

							//Efetua cálculo da data do próximo reajuste
							dDtPrxRj := CN300DtPrxRj(dDataApl, cUniPeri, nPeri,(lPermReaj .And. (oModelCNA:GetValue("CNA_FLREAJ") == '1')))
							oModelCNA:SetValue('CNA_DTREAJ',dDataApl)
							oModelCNA:SetValue('CNA_PROXRJ',dDtPrxRj)
						EndIf
					EndIf
				EndIf
			Else //Do Contrário, atualizará os itens da planilha
				// Verifica se reajuste utilizará Pro Rata
				If cProRatCN9 == "1" //Contrato aceita Pro Rata
					lProRata := .T.
				EndIf

				If cProRatCNA == "2" //Planilha NÃO aceita Pro Rata
					lProRata := .F.
				EndIf

				dDtRjAnt := If( Empty(oModelCNA:GetValue("CNA_DTREAJ")) , oModelCNA:GetValue('CNA_DTINI') , oModelCNA:GetValue("CNA_DTREAJ") )
				dDtPrxRj := oModelCNA:GetValue("CNA_PROXRJ")

				//Reajusta Itens habilitados
				For nY := 1 to oModelCNB:Length()
					oModelCNB:GoLine(nY)
					If Empty(oModelCNB:GetValue('CNB_ITMDST'))
						If 	oModelCNB:GetValue('CNB_FLREAJ') <> "2" .And.;//Verifica se item da planilha aceita reajuste
							(oModelCNB:GetValue("CNB_SLDMED") > 0 .Or. lSemiProd ) //Verifica se o saldo da planilha é maior do que zero OU se é (semifixo produto)
							
							dDtPrxRj := oModelCNA:GetValue("CNA_PROXRJ")
							cModoReaj:= cMdRjCabec

							// Validar se efetuará o reajuste
							lVldReaj := CN300RjVld(cModoReaj, dDataApl, dDtRjAnt, dDtPrxRj)

							// Se item não se enquadra no reajuste, verifica se ele não utilizará Reajuste Pro Rata
							If !lVldReaj
								If lProRata
									If dDataApl > dDtRjAnt .And. dDataApl < dDtPrxRj //Data de próximo reajuste maior que a data de aplicação
										lVldReaj := .T.
									EndIf
								EndIf
							EndIf

							//Efetua o reajuste do valor unitário
							If lVldReaj
								cIndice:= If(Empty(oModelCNB:GetValue('CNB_INDICE')), cIndCabec, oModelCNB:GetValue('CNB_INDICE'))
								nVlrInd	:= A300VlrInd(cIndice, dDataRef, lProRata, dDataApl, dDtRjAnt, dDtPrxRj)
								nVlrUn := Round( oModelCNB:GetValue('CNB_VLUNIT') * nVlrInd, TamSx3("CNB_VLUNIT")[2] )

								//-- Ponto de entrada para customização do cálculo do índice
								If lCN300VRJ
									nCN300VRJ := Execblock("CN300VRJ",.F.,.F.,{oModelCNA,oModelCNB,nVlrInd,dDataRef, lProRata, dDataApl, dDtRjAnt, dDtPrxRj, cIndice})
									If ValType(nCN300VRJ) == "N"
										nVlrUn := nCN300VRJ
									EndIf
								EndIf

								oModelCNB:SetValue('CNB_VLUNIT',nVlrUn)

								// Verifica se nao existe item destino de reajuste criado a partir do saldo para medição
								cItemDest	:= oModelCNB:GetValue('CNB_ITMDST')
								If !Empty(cItemDest) .And. (nLineCNB := MTFindMVC(oModelCNB,{{'CNB_ITEM',cItemDest}}) ) > 0
									oModelCNB:GoLine(nLineCNB)
								EndIf
								
								//Efetua cálculo da data do próximo reajuste
								dDtPrxRj := CN300DtPrxRj(dDataApl, cUniPeri, nPeri,(lPermReaj .And. (oModelCNA:GetValue("CNA_FLREAJ") == '1')))
								oModelCNB:SetValue('CNB_DTREAJ',dDataApl)
								oModelCNB:SetValue('CNB_PROXRJ',dDtPrxRj)

							EndIf
						EndIf
					EndIf
				Next nY

				If !lSemiProd
					oModelCNA:SetValue('CNA_DTREAJ',dDataApl)
					oModelCNA:SetValue('CNA_PROXRJ',dDtPrxRj)
				EndIf

				If lSemiProd
					dDtRjAnt := If( Empty(oModelCNA:GetValue("CNA_DTREAJ")) , oModelCNA:GetValue('CNA_DTINI') , oModelCNA:GetValue("CNA_DTREAJ") )
					dDtPrxRj := oModelCNA:GetValue("CNA_PROXRJ")
					
					If (lVldReaj := CN300RjVld(cMdRjCabec, dDataApl, dDtRjAnt, dDtPrxRj))// Validar se efetuará o reajuste
						If lRevMed
							nVlrNRec := A300SldRec('n2','')
						EndIf
						nSldReaj := (oModelCNA:GetValue("CNA_SALDO")+nVlrNRec)
						nVlrReaj := Round(nSldReaj*A300VlrInd(cIndCabec,dDataRef),TamSx3("CNA_VLTOT")[2]) - nSldReaj

						oModelCNA:SetValue("CNA_VLTOT",oModelCNA:GetValue("CNA_VLTOT")+nVlrReaj)//Efetua o reajuste da planilha

						//Efetua cálculo da data do próximo reajuste
						dDtPrxRj := CN300DtPrxRj(dDataApl, cUniPeri, nPeri,(lPermReaj .And. (oModelCNA:GetValue("CNA_FLREAJ") == '1')))
						oModelCNA:SetValue('CNA_DTREAJ',dDataApl)
						oModelCNA:SetValue('CNA_PROXRJ',dDtPrxRj)
					EndIf
				EndIf
			EndIf

			// Reajusta Cronogramas
			nVlrReaj := oModelCNA:GetValue("CNA_VLTOT") - nVlTotOri
			nValorRj := nVlrReaj
			If nVlrReaj != 0
				If lFisico
					A300FscTFn(oModel) // Atualiza Cronograma Finaceiro pelo cronograma fisico
				ElseIf lFixo
					If !(lRet := ReajCrgFin(oModel,nVlrReaj,lFisico))
						Exit
					EndIf					
				EndIf
				//-- Atualiza Cronograma contabil
				If lContabil
					A300ReajCt(oModel,nVlrReaj)
				EndIf
				If lAmortiza
					CN300Amort(oModel)//Calcula a amortização linear
				EndIf
			EndIf
			
		EndIf
	Next nX
	
	A300SUsrBt(.T.)
	CNAddItRt()
	
	If lRet .And. !IsBlind() .And. !IsInCallStack("CNTA310")
		FWAlertSuccess(STR0006,"CN300REAJ") //Reajuste realizado com sucesso!
	EndIf	

	A300Revisa(oModel,A300GTpRev())//-- Fecha o Modelo
	GCTRstWhen(oModelCNA, aWhenModels[1])
	GCTRstWhen(oModelCNB, aWhenModels[2])
	GCTRstWhen(oModelCNF, aWhenModels[3])
	FwFreeArray(aWhenModels)	
EndIf

FWRestRows(aSaveLines)
FwFreeArray(aSaveLines)
Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} CN300RjVld()
Efetua a validação se item será reajustado

@author Marcelo Ferreira
@since  01/09/2015
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Static function CN300RjVld(cModoReaj, dDataApl, dDtRjAnt, dDtPrxRj)
Local lRet := .F.

	//Validação se item está  dentro da data ou da competência de reajuste
	Do Case
		Case cModoReaj == "1" // Modo de Reajuste "Por Competência"
			If Left(DtoS(dDataApl), 6) >= Left(DtoS(dDtPrxRj), 6) //Data de próximo reajuste dentro ou maior que o "AnoMes" da data de aplicação
				lRet := .T.
			EndIf

		Case cModoReaj == "2" // Modo de Reajuste "Por Data"
			If dDataApl >= dDtPrxRj //Data de próximo reajuste maior ou igual a data de aplicação
				lRet := .T.
			EndIf

		Case Alltrim(cModoReaj) == "" // Modo de Reajuste "Em Branco"
			lRet := .T.
	End Case

Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} CN300DtPrxRj()
Define data de próximo reajuste

@author Marcelo Ferreira
@since  01/09/2015
@version 1.0
@return dDtPrxRj
/*/
//--------------------------------------------------------------------
Static function CN300DtPrxRj(dDataApl, cUniPeri, nPeri, lPermReaj)
Local dDtPrxRj := CtoD("")
Default lPermReaj := .T.

If lPermReaj
	If cUniPeri == '1' //Dias
		dDtPrxRj := DaySum( dDataApl, nPeri )
	ElseIf cUniPeri == '2' //Meses
		dDtPrxRj := MonthSum( dDataApl, nPeri )
	ElseIf cUniPeri == '3' //Anos
		dDtPrxRj := YearSum( dDataApl, nPeri )
	EndIf
Else
	dDtPrxRj := cTod('')
EndIf
Return dDtPrxRj

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VldRV()
Validações das revisões

@param oModel - Modelo ativo

@author guilherme.pimentel
@since 21/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CN300VldRV(oModel)
Local lRet 		:= .T.
Local oModelCN9	:= oModel:GetModel('CN9MASTER')
Local cEdital 	:= oModelCN9:GetValue('CN9_CODED') //Codigo do edital
Local cProcesso	:= oModelCN9:GetValue('CN9_NUMPR') //Numero do Processo

//Verificação padrão para todas as revisões
lRet :=  !(Empty(oModelCN9:GetValue('CN9_JUSTIF')) .Or. Empty(oModelCN9:GetValue('CN9_TIPREV')))

If lRet
	If A300GTpRev() == DEF_REV_ADITI
		If lRet .And. !Empty(cEdital) .And. !Empty(cProcesso) .And. A300RvPrz(oModel,cEdital,cProcesso)
			lRet := A300RvCnEd(oModel,cEdital,cProcesso)
		EndIf
	ElseIf A300GTpRev() == DEF_REV_REAJU
		If !A300GUsrBt()
			lRet := .F.
			Help("",1,"CN300NOREAJU") // É necessario executar o reajuste para concluir a revisão. Verifique "Ações relacionadas
		Else
			oModel:GetModel("CN9MASTER"):LoadValue("CN9_VLREAJ",oModel:GetModel("CN9MASTER"):GetValue("CN9_VLATU") - CN9->CN9_VLATU )
		EndIf

		If lRet .And. !Empty(cEdital) .And. !Empty(cProcesso)
			lRet := A300RvCnEd(oModel,cEdital,cProcesso)
		EndIf

	ElseIf A300GTpRev() == DEF_REV_REALI //Realinhamento
		If lRet .And. !Empty(cEdital) .And. !Empty(cProcesso)
			lRet := A300RvCnEd(oModel,cEdital,cProcesso)
		EndIf
	ElseIf A300GTpRev() == DEF_REV_READE //Readequação
		If lRet
			If (oModelCN9:GetValue('CN9_VLATU') <> CN9->CN9_VLATU)
				lRet := .F.
				Help("",1,"CN300VldRV") //O valor atual é diferente do anterior. Favor verificar.
			EndIf
		EndIf

		If lRet .And. !Empty(cEdital) .And. !Empty(cProcesso)
			lRet := A300RvCnEd(oModel,cEdital,cProcesso)
		EndIf
	ElseIf A300GTpRev() == DEF_REV_PARAL
		If lRet .And. Empty(oModelCN9:GetValue('CN9_MOTPAR'))
			lRet := .F.
			Help("",1,"CN300VldRVMPAR") // Favor preencher o campo Motivo da Paralisação.
		EndIf
	ElseIf A300GTpRev() == DEF_REV_CLAUS

		If Empty(oModelCN9:GetValue('CN9_ALTCLA')) .And. Empty(oModelCN9:GetValue('CN9_OBJCTO'))
			lRet := .F.
			Help("",1,"CN300VldRVCL") // Favor preencher o campo Cláusula.
		EndIf

	ElseIf A300GTpRev() == DEF_REV_RENOV .Or. A300GTpRev() == DEF_REV_ORCGS // Renovação / Orç. Serviço
		If lRet .And. !Empty(cEdital) .And. !Empty(cProcesso)
			lRet := A300RvCnEd(oModel,cEdital,cProcesso)
		EndIf
		
		//-- A Validação deve ser feita tbm para revisões do tipo DEF_REV_ORCGS (Gestão de serviços)
		If lRet .And. oModelCN9:GetValue("CN9_FLGCAU") == "1" .And. A300GTpRev() == DEF_REV_ORCGS
			If 	Empty(oModelCN9:GetValue("CN9_MINCAU"))
				Help(" ",1,"CNTA300PER")	//-- Preencha o percentual minimo de caucao
				lRet := .F.
			ElseIf oModelCN9:GetValue("CN9_MINCAU") < CN9->CN9_MINCAU
				Help(" ",1,"CN300PERMN")	//-- Percentual da caução deve ser maior que o original
				lRet := .F.
			EndIf
		EndIf
	ElseIf A300GTpRev() == DEF_REV_CAUCA 
		If lRet .And. oModelCN9:GetValue("CN9_FLGCAU") == "1"
			If oModelCN9:GetValue("CN9_MINCAU") <= CN9->CN9_MINCAU
				Help(" ",1,"CN300PERMN")	//-- Percentual da caução deve ser maior que o original
				lRet := .F.
			EndIf
		EndIf
	EndIf

Else
	Help("",1,"CN300VldRVJUS") // Favor preencher o campo Justificativa e/ou Tipo da Revisão.
EndIf

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CN300RecFis()
Função que recupera o saldo cronog fisico depois de deletar as
linhas

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function CN300RecFis(oModel, aOldSlds)
Local nI 		 := 0
Local nI2 		 := 0
Local oCNFDetail 	:= oModel:GetModel('CNFDETAIL')
Local oCNSDetail 	:= oModel:GetModel('CNSDETAIL')
Local aSavelines	:= FWSaveRows()

For nI := 1 To oCNFDetail:Length()
	oCNFDetail:Goline(nI)
	If !oCNFDetail:IsDeleted()
		For nI2 := 1 To oCNSDetail:Length()
			oCNSDetail:GoLine(nI2)
			nPos := aScan(aOldSlds,{|x| x[1] == oCNSDetail:GetValue('CNS_PRODUT')})
			oCNSDetail:LoadValue('CNS_DISTSL', (oCNSDetail:GetValue('CNS_DISTSL')) +  aOldSlds[nPos, 2])
		Next nI2
	EndIf
Next nI
FwRestRows(aSaveLines)
Return

//------------------------------------------------------------------
/*/{Protheus.doc} CN300SAdF()
Função que recupera o saldo a distribuir dos itens do cronog Fisico

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function CN300SAdF(oCNSDetail as Object) as Array
	Local aSldFis 		:= {}
	Local nI 		 	:= 0
	Local aSavelines	:= FWSaveRows()

	For nI := 1 To oCNSDetail:Length()
		oCNSDetail:GoLine(nI)
		Aadd(aSldFis, {oCNSDetail:GetValue('CNS_ITEM'), oCNSDetail:GetValue('CNS_DISTSL')})
	Next nI

	FwRestRows(aSaveLines)
	FwFreeArray(aSaveLines)
Return aSldFis

//------------------------------------------------------------------
/*/{Protheus.doc} CN300AtCrC()
Função que atualiza Cronog. Contábil

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CN300AtCrC()
	Local oModel 		:= FwModelActive()
	Local oCN9Master 	:= oModel:GetModel('CN9MASTER')
	Local oCNWDetail 	:= oModel:GetModel('CNWDETAIL')
	Local cModo		:= 	oCN9Master:GetValue('CN9_TPCROC')
	Local lCont		:= .T.
	Local lArrasto	:= If(oCN9Master:HasField("CN9_ARRASC"),oCN9Master:GetValue('CN9_ARRASC') == '1',.F.)
	Local nJuros	:= 0
	Local nMaxParc	:= 0
	Local nX		:= 0

	If (lCont := Cn300RetSt("CONTABIL"))
		CNTA300BlMd(oCNWDetail,.F.)

		If cModo == "1"
			lCont := CN300IncCb(oModel)
		ElseIf cModo == "2"
			CN300DelCb(oModel)
		EndIf

		If lCont
			If lArrasto
				CN300ArrCb(oModel)
			EndIf

			If ValPresCTB(oCN9Master, @nJuros)
				nMaxParc := oCNWDetail:Length(.T.)
				For nX := 1 To oCNWDetail:Length()
					oCNWDetail:GoLine(nX)
					If !oCNWDetail:IsDeleted()
						oCNWDetail:SetValue('CNW_MAXPAR', nMaxParc)
						If oCNWDetail:GetValue('CNW_FLGAPR') == '2' //Nao apropriado
							oCNWDetail:SetValue('CNW_TJUROS', nJuros)
						EndIf
					EndIf
				Next nI

				If CNW->(ColumnPos("CNW_AMRTZA") > 0)
					CN300Amort(oModel,.F.)//Calcula amortização linear
				EndIf
			EndIf

			oCN9Master:LoadValue('CN9_QTPARC', 0)

			MsgInfo(STR0005,"CN300ATU")

			CNTA300BlMd(oCNWDetail, ,.T.)
			oCNWDetail:GoLine(1)
		EndIf
	Else
		Help(" ",1,"CN300NOCON")
	EndIf

Return lCont


//------------------------------------------------------------------
/*/{Protheus.doc} CN300AtCont()
Função que atualiza Cronog. Contábil

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CN300AtCont(lFailMsg)
	Local lResult	:= .T.
	Local bExec		:= {||CN300AtCrC()}
	Local oModel	:= Nil
	Default lFailMsg:= .F.	

	If lFailMsg
		oModel := FwModelActive()
		GCTOpenMdl(oModel)//abre o modelo antes da execucao da atualizacao do cronograma
		lResult := CtrExecMsg(bExec, oModel, {"CN9MASTER", "CN9_NUMERO", "CN300ATCONT"})
		
		A300Revisa(oModel,A300GTpRev()) //Fecha modelo
	Else
		A300OpenMd(bExec, .T., .T., "STR0046")
	EndIf	
Return lResult

//------------------------------------------------------------------
/*/{Protheus.doc} CN300ArrCb()
Função responsável pelo arrasto e redistribuição de saldo do
cronograma contábil.

@author jose.delmondes
@since 15/02/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static function CN300ArrCb(oModel)
Local oCN9Master	:= oModel:GetModel('CN9MASTER')
Local oCNADetail	:= oModel:GetModel('CNADETAIL')
Local oCNWDetail	:= oModel:GetModel('CNWDETAIL')
Local oCNVDetail	:= oModel:Getmodel('CNVDETAIL')
Local lRedVlr   	:= oCN9Master:GetValue('CN9_REDVAC') == '1'
Local nTotPlan		:= oCNADetail:GetValue('CNA_VLTOT')
Local nTotCron		:= oCNVDetail:GetValue('CNV_TOTCRG')
Local nVlrArr		:= nTotPlan - nTotCron
Local nUltParc		:= oCNWDetail:Length()
Local nVlrParc		:= 0
Local nQtdParc		:= 0
Local nResto		:= 0
Local nI			:= 0

If !lRedVlr
	//Se não utilizar a redistribuição de valores, a diferença entre o total da planilha e o
	//total do cronograma será somada a primeira parcela não apropriada do cronograma contábil.
	For nI := 1 To nUltParc
		oCNWDetail:GoLine(nI)

		//Se a linha estiver deletada pula para a próxima
		If oCNWDetail:IsDeleted()
			Loop
		EndIf

		//Atualiza primeira parcela não apropriada com o valor de arrasto
		If oCNWDetail:GetValue('CNW_FLGAPR') == '2'
			oCNWDetail:SetValue('CNW_VLPREV', oCNWDetail:GetValue('CNW_VLPREV')+nVlrArr)
			Exit
		EndIf
	Next nI
Else

	//Soma valores das parcelas não apropriadas ao valor de arrasto
	For nI := 1 To nUltParc
		oCNWDetail:GoLine(nI)

		//Se a linha estiver deletada pula para a próxima
		If oCNWDetail:IsDeleted()
			Loop
		EndIf

		//Soma valor da parcela
		If oCNWDetail:GetValue('CNW_FLGAPR') == '2'
			nVlrArr += oCNWDetail:GetValue('CNW_VLPREV')
			nQtdParc ++
		EndIf
	 Next nI

	 //Obtem valor das parcelas e a sobra
	 nVlrParc	:= NoRound(nVlrArr/nQtdParc,TamSX3('CNW_VLPREV')[2])
	 nResto	:= nVlrArr - (nQtdparc * nVlrParc)

	 //Atualiza valores das parcelas
	 For nI := 1 To nUltParc
		oCNWDetail:GoLine(nI)

		//Se a linha estiver deletada pula para a próxima
		If oCNWDetail:IsDeleted()
			Loop
		EndIf

		//Atualiza parcelas, a sobra será somada a última parcela.
		If oCNWDetail:GetValue('CNW_FLGAPR') == '2' .And. nI <> nUltParc
			oCNWDetail:SetValue('CNW_VLPREV', nVlrParc)
		ElseIf oCNWDetail:GetValue('CNW_FLGAPR') == '2' .And. nI == nUltParc
			oCNWDetail:SetValue('CNW_VLPREV', nVlrParc + nResto )
		EndIf
	 Next nI
EndIf

Return

//------------------------------------------------------------------
/*/{Protheus.doc} CN300DelCb()
Função que deleta as linhas do cronog. Contábil

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function CN300DelCb(oModel)
Local oCN9Master 	:= oModel:GetModel('CN9MASTER')
Local oCNWDetail 	:= oModel:GetModel('CNWDETAIL')
Local nQtdParcs  	:= oCN9Master:GetValue('CN9_QTPARC')
Local nI    	    := 0
Local aSaveLines	:= FWSaveRows()
Local lRet 		:= .T.

If (nQtdParcs >= oCNWDetail:Length(.T.))
	Help('',1,'CNT300DCPC')// O número de redução de parcelas não pode ser maior ou igual ao o número de parcelas.
	lRet := .F.
EndIf

If lRet
	oCNWDetail:SetNoDeleteLine(.F.)
	For nI := oCNWDetail:Length() To 1 Step -1
		oCNWDetail:GoLine(nI)
		If !oCNWDetail:IsDeleted() .And. oCNWDetail:GetValue("CNW_FLGAPR") <> "1"
			If nQtdParcs == 0
				Exit
			EndIf

			oCNWDetail:DeleteLine()
			nQtdParcs := nQtdParcs - 1
		EndIf
	Next nI
	oCNWDetail:SetNoDeleteLine(.T.)
EndIf

FWRestRows(aSaveLines)

Return

//------------------------------------------------------------------
/*/{Protheus.doc} CN300IncCb()
Função que inclui as linhas no cronog. Contábil

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function CN300IncCb(oModel)
	Local oCN9Master 	:= oModel:GetModel('CN9MASTER')
	Local oCNWDetail 	:= oModel:GetModel('CNWDETAIL')
	Local oCNVDetail 	:= oModel:GetModel('CNVDETAIL')
	Local nX		   	:= 0
	Local nDiaPar   	:= 30
	Local nAvanco	 	:= 0
	Local cNrParcela 	:= 0
	Local nParcelas 	:= oCN9Master:GetValue('CN9_QTPARC')
	Local dUltData   	:= CtoD("")
	Local aSaveLines	:= FWSaveRows()
	Local lRet			:= .T.
	Local nDiaIni		:= 0

	//Ultima linha não deletada
	For nX := oCNWDetail:Length() To 1 Step -1
		oCNWDetail:GoLine(nX)
		If !oCNWDetail:IsDeleted()
			Exit
		EndIf
	Next nI

	dUltData	:= oCNWDetail:GetValue("CNW_DTPREV")
	cNrParcela	:= oCNWDetail:GetValue("CNW_PARCEL")
	nDiaIni   	:= Day(oCNWDetail:GetValue("CNW_DTPREV"))
	nDiaPar		:= oCNVDetail:GetValue('CNV_DIAPAR')

	For nX :=1 to nParcelas
		cNrParcela := Soma1(cNrParcela)

		If nDiaPar == 30
			nAvanco	:= CalcAvanco(dUltData,.T.,.T.,nDiaIni)
		Else
			nAvanco	:= nDiaPar
		EndIf

		dUltData := dUltData + nAvanco
		cCompete := Strzero(Month(dUltData),2)+"/"+str(Year(dUltData),4)
		
		If (lRet := CNTA300ULT(dUltData, oModel:GetModel("CNADETAIL"):GetValue("CNA_DTFIM")))	
			oCNWDetail:AddLine()
			oCNWDetail:LoadValue("CNW_PARCEL",cNrParcela)
			oCNWDetail:SetValue("CNW_COMPET",cCompete)
			lRet := oCNWDetail:SetValue("CNW_DTPREV",dUltData)
			oCNWDetail:SetValue("CNW_VLPREV",0)
			dPrevista 	:= oCNWDetail:GetValue('CNW_DTPREV')//Seleciona ultima data
			dUltData	:= oCNWDetail:GetValue('CNW_COMPET')//Seleciona ultima competencia
			dUltData	:= CTOD(Str(Day(dPrevista))+"/"+dUltData)
		EndIf

		If !lRet
			Exit
		EndIf
	Next nX

	FWRestRows(aSaveLines)
	FwFreeArray(aSaveLines)
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} CN300VlPrz()
Retirada do Valid do campo CN9_VIGE e CN9_UNVIGE e
colocada no tudoOk do CNTA300

@author matheus.raimundo
@since 18/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function CN300VlPrz()
Local lRet 	:= .T.
Local dData 	:= CtoD("")
Local oModel	:= FwModelActive()
Local oModelCN9	:= oModel:GetModel("CN9MASTER")
Local lEdital	:= !Empty(oModelCN9:GetValue('CN9_CODED'))
Local cTipRev	:= A300GTpRev()
Local dDatai	:=  oModelCN9:GetValue('CN9_DTINIC')

dData := CN300DtFim(oModelCN9:GetValue('CN9_UNVIGE'),dDatai,oModelCN9:GetValue('CN9_VIGE'))
dData := CN300DtFim(oModelCN9:GetValue('CN9_UNVIGE'),oModelCN9:GetValue('CN9_DTINIC'),oModelCN9:GetValue('CN9_VIGE'))

If !Empty(cTipRev) .And. !Empty(oModelCN9:GetValue('CN9_DTINIC'))
	If cTipRev == DEF_REV_ADITI .And. Cn300RetSt("REVESPECIE") $ '3|4'  .Or.;
	 ((cTipRev == DEF_REV_RENOV .Or. cTipRev == DEF_REV_ORCGS .Or. cTipRev == DEF_REV_ABERT) .And. Cn300RetSt("REVESPECIE") $ '5')

		If Cn300RetSt("MODALIDADE") == '1'
			If oModelCN9:GetValue("CN9_DTFIM") > dData
				Help('',1,'CNTA300IDTI') // A data final deve ser maior do que a data final da última revisão, revisão de Acresicmo.
				lRet := .F.
			EndIf
		ElseIf Cn300RetSt("MODALIDADE") == '2'
			If oModelCN9:GetValue("CN9_DTFIM") < dData
				Help('',1,'CNTA300IDTF') // A data final deve ser menor do que a data final da última revisão, revisão de Decrescimo.
				lRet := .F.
			EndIf
		EndIf
		If lRet .And. lEdital .And. (oModelCN9:GetValue("CN9_UNVIGE") == "4")
			Help("",1,"CN300VlPrz",,STR0043,1,0,,,,,,{STR0044}) //Parágrafo único. É vedado o contrato por prazo indeterminado.
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300DtFim()
Retorna a data conforme unidade de vigencia e quantidade.

@author matheus.raimundo
@since 18/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function CN300DtFim(cTipV,dDtIni,nVig)
Local nX			:= 0
Local nDiaIni		:= 1

If (!Empty(nVig) .Or. cTipV == "4") .And. !Empty(dDtIni)
	Do Case
		Case cTipV == "1"  //Dia
			dDtIni += nVig
		Case cTipV == "2"  //Mes
			nDiaIni := Day(dDtIni) //Dia do início do contrato.
			For nX := 1 to nVig
				dDtIni += CalcAvanco(dDtIni,.F.,.F.,nDiaIni)
			Next
		Case cTipV == "3"  //Ano
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Valida ano bissexto                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Day(dDtIni) == 29 .And. Month(dDtIni) == 2 .And. ((Year(dDtIni)+nVig) % 4 != 0)
				dDtIni := cTod("28/02/"+str(Year(dDtIni)+nVig))
			Else
				dDtIni := cTod(str(Day(dDtIni))+"/"+str(Month(dDtIni))+"/"+str(Year(dDtIni)+nVig))
			EndIf
		Case cTipV == "4"  //Indeterminada
			dDtIni := CTOD("31/12/49")//Retorna data limite do sistema
	EndCase
EndIf

Return dDtIni

//-------------------------------------------------------------------
/*/{Protheus.doc} A300RevCtb()
Função para liberar cronograma contabil

@author alexandre.gimenez
@since 18/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function A300RevCtb( oModel )
Local oModCN9   := oModel:GetModel('CN9MASTER')
Local oModCNV   := oModel:GetModel('CNVDETAIL')
Local oModCNW   := oModel:GetModel('CNWDETAIL')
Local oStruCN9 	:= oModCN9:GetStruct()
Local oStruCNV	:= oModCNV:GetStruct()
Local aCampos 	:= {}
Local cEspec    := Cn300RetSt("REVESPECIE")
Local lValPres	:= ValPresCtb()
Local aTemp		:= {}

oStruCNV:SetProperty("CNV_NUMERO",MODEL_FIELD_OBRIGAT,.F.)

If Cn300RetSt( "CONTABIL", 2 )
	aAdd(aCampos,{'CNVDETAIL',{'CNV_CONTA','CNV_TXMOED'}})

	If oStruCN9:HasField("CN9_REDVAC") .And. oStruCN9:HasField("CN9_ARRASC")
		aTemp := {'CN9MASTER',{'CN9_ARRASC','CN9_TPCROC','CN9_QTPARC'}}		
		oStruCN9:SetProperty('CN9_REDVAC',MODEL_FIELD_WHEN,{|| oModCN9:GetValue("CN9_ARRASC") == '1' })
	Else
		aTemp := {'CN9MASTER',{'CN9_TPCROC','CN9_QTPARC'}}
	EndIf

	If lValPres
		aAdd(aTemp[2], 'CN9_TJUCTB')
	EndIf

	aAdd(aCampos, aClone(aTemp))

	MtBCMod(oModel,aCampos,{||.T.},'2')

	aCampos := {}

	If A300GTpRev() == DEF_REV_ADITI .And. cEspec == '1' //Aditivo de Quantidade
		aTemp := {'CNWDETAIL',{'CNW_VLPREV','CNW_HIST','CNW_CC','CNW_ITEMCT', 'CNW_CLVL'}}	
	Else
		aTemp := {'CNWDETAIL',{'CNW_VLPREV','CNW_DTPREV','CNW_HIST','CNW_CC','CNW_ITEMCT','CNW_CLVL','CNW_COMPET'}}
	EndIf

	If lValPres
		aAdd(aTemp[2], 'CNW_TJUROS')
	EndIf

	aAdd(aCampos, aClone(aTemp))

	MtBCMod(oModel,aCampos,{||FwFldGet("CNW_FLGAPR")<>"1"},'2')

	oModCNV:SetNoUpdateLine(!CN300RetSt('CONTABIL'))
	oModCNW:SetNoUpdateLine(!CN300RetSt('CONTABIL'))

	FwFreeArray(aTemp)
	FwFreeArray(aCampos)
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} A300IsRFor()
Função para verificar se esta sendo executada a revisao de fornecedor

@author Alexandre.gimenez
@since 18/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function A300IsRFor()
Return (A300GTpRev() == DEF_REV_FORCL)

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300LenNw()
Função que retorna as linhas novas de um modelo

@author matheus.raimundo
@since 18/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function CN300LenNw(oModel)
Local nLen 			:= 0
Local nI 			:= 0
Local aSaveLines	:= FWSaveRows()

For nI := 1 To oModel:Length()
	oModel:GoLine(nI)
	If oModel:IsInserted() .And. !oModel:IsDeleted()
		nLen := nLen + 1
	EndIf
Next nI

FWRestRows(aSaveLines)
Return nLen

//------------------------------------------------------------------
/*/{Protheus.doc} CN300AjSlF()
Função para ajustar o saldo, caso de diferença de casas decimais

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CN300AjSlF(oModel)
	Local oCNFDetail 	:= oModel:GetModel('CNFDETAIL')
	Local oCNSDetail 	:= oModel:GetModel('CNSDETAIL')
	Local oCNBDetail 	:= oModel:GetModel('CNBDETAIL')
	Local nDif  	   	:= 0
	Local nValor		:= 0
	Local nI			:= 0
	Local nI2			:= 0
	Local nI3			:= 0
	Local nRound		:= TamSX3('CNS_PRVQTD')[2]
	Local aSavelines	:= FWSaveRows()
	Local aItens		:= {}
	Local nPos			:= 0
	Local aDifs		:= {}

	CNTA300BlMd(oCNFDetail, .T., .T. )

	For nI := 1 To oCNFDetail:Length()
		oCNFDetail:GoLine(nI)
		If !oCNFDetail:IsDeleted()

			For nI2 := 1 To oCNSDetail:Length()
				oCNSDetail:GoLine(nI2)
				If !oCNSDetail:IsDeleted()
					nPos := aScan(aItens,{|x| x[1] == oCNSDetail:GetValue('CNS_PRODUT')})
					If nPos == 0
						Aadd(aItens, {oCNSDetail:GetValue('CNS_PRODUT'), oCNSDetail:GetValue('CNS_PRVQTD')})
					Else
						aItens[nPos, 2]  += oCNSDetail:GetValue('CNS_PRVQTD')
					EndIf
				EndIf
			Next nI2

		EndIf
	Next nI

	nDif := oModel:GetModel('CNADETAIL'):GetValue('CNA_VLTOT') -  oModel:GetModel("CALC_CNF"):GetValue('CNF_CALC')
	If (nDif <> 0.00) .And. (nDif > -5) .And. (nDif < 5)
		For nI := 1 To oCNBDetail:Length()
			oCNBDetail:GoLine(nI)
			If !oCNBDetail:IsDeleted()
				nPos := Ascan(aItens,{|x| x[1] == oCNBDetail:GetValue('CNB_PRODUT')})
				nDif := oCNBDetail:GetValue('CNB_QUANT') - aItens[nPos, 2]
				Aadd(aDifs,{oCNBDetail:GetValue('CNB_PRODUT'), nDif})
			EndIf
		Next nI

		For nI2	:= oCNFDetail:Length() To 1 Step -1
			oCNFDetail:GoLine(nI2)
			If !oCNFDetail:IsDeleted()
				For nI3 := oCNSDetail:Length() To 1 Step -1
					oCNSDetail:GoLine(nI3)
					nPos := Ascan(aDifs,{|x| x[1] == oCNSDetail:GetValue('CNS_PRODUT')})
					If nPos > 0
						If !oCNSDetail:IsDeleted()
							oCNSDetail:SetValue('CNS_PRVQTD', Round(oCNSDetail:GetValue('CNS_PRVQTD') + aDifs[nPos, 2],nRound))
							Loop
						EndIf
					EndIf
				Next nI3
				Exit
			EndIf
		Next nI2
	EndIf

	//-Insere na ultima parcela divergencia financeira
	nDif := oModel:GetModel('CNADETAIL'):GetValue('CNA_VLTOT') -  oModel:GetModel("CALC_CNF"):GetValue('CNF_CALC')
	If nDif <> 0.00
		For nI := oCNFDetail:Length() To 1 Step -1
			oCNFDetail:GoLine(nI)
			If !oCNFDetail:IsDeleted() .And. oCNFDetail:GetValue('CNF_VLPREV') > 0
				nValor := oCNFDetail:GetValue('CNF_VLPREV') + nDif
				oCNFDetail:SetValue('CNF_VLPREV',nValor)
				oModel:SetValue("CALC_CNS","TCNS_VTOT",oCNFDetail:GetValue('CNF_VLPREV'))
				Exit
			EndIf
		Next nI
	EndIf

	FWRestRows(aSaveLines)
	FwFreeArray(aSaveLines)
Return

//------------------------------------------------------------------
/*/{Protheus.doc} CN300CAprv(cContr)
Função que valida se o contrato não está pendente de aprovação e pode

@author Matheus Lando Raimundo
@since 03/02/2014
@version 1.0
/*/
//------------------------------------------------------------------
Static function CN300CAprv(cContr, lMostraHelp)
Local lRet := .T.
Local cRevAtu := ""

Default lMostraHelp := .F.

DbSelectArea("CN9")
CN9->(DbSetOrder(1))
If CN9->(dbSeek(xFilial("CN9")+cContr))
	cRevAtu := CN9->CN9_REVATU
	If CN9->(dbSeek( xFilial("CN9") + cContr + cRevAtu )) .And. (CN9->CN9_SITUAC == '09')
		DbSelectArea("CN1")
		CN1->(DbSetOrder(1))
		If CN1->(DbSeek(xFilial("CN1") + CN9->CN9_TPCTO))
			DbSelectArea("CN0")
			CN0->(DbSetOrder(1))
			If CN0->(DbSeek(xFilial("CN0") + CN9->CN9_TIPREV))
				If CN0->CN0_TIPO == '2'							//Revisão de Reajuste
				lRet := Cn300RetSt("REVREAJU",2)
			ElseIf CN0->CN0_TIPO == '3'							//Revisão de Realinhamento
					lRet := Cn300RetSt("REVREALI",2)
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If !lRet .And. lMostraHelp
	Help('',1,'CNTA300NSEL')//"Este Item não poderá ser selecionado pois o contrato que o originou encontra-se em processo de revisão, fazendo-se necessária sua aprovação ou cancelamento para realização deste procedimento"
EndIf

Return lRet


//------------------------------------------------------------------
/*/{Protheus.doc} A300EstPVL()
Funcao para estornar pedido de venda

@author alexandre.gimenez
@since 30/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function A300EstPVL()
Local lRet 		:= .T.
Local aPedidos		:= {}
Local nX			:= 0
Local lContinua	:= .F.

If Cn300RetSt("VENDA") .And. A300RevMed()
	//Retorna Pedidos nao entregues
	aPedidos := A300SldRec('a3','', .F. )
	If Len(aPedidos) > 0
		DbSelectArea( 'SC9' )
		SC9->( DbSetOrder(1) )	//C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN + C9_PRODUTO
		SC9->( DbGoTop() )
		Begin Transaction
			For nX:= 1 to Len(aPedidos)
				//Busca o pedido no SC9 - Pedidos Liberados
				If ( SC9->( MsSeek( xFilial('SC9') + aPedidos[nX] ) ) )
					If !lContinua .And. MSGYESNO(STR0024,STR0008)
						lContinua := .T.
					Else
						lContinua := .F.
						lRet := .F.
					EndIf
					If lContinua
						While SC9->( !Eof() ) .And. SC9->C9_PEDIDO == aPedidos[nX]
							lRet := A460Estorna(.F.,.T.,0)
							If !lRet
								DisarmTransaction()
								Exit
							EndIf
							SC9->(DbSkip())
						End
					EndIf
				EndIf
				If !lRet
					Exit
				EndIf
			Next nX
		End Transaction
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} A300RvCnEd()
Funcao revisar contratos vinculados à um edital

@author Leonardo Quintania
@since 16/10/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static function A300RvCnEd(oModel,cEdital,cProcesso)
Local aArea      := GetArea()
Local aAreaCN9   := CN9->(GetArea())
Local aSaveLines := FWSaveRows()
Local nVlTot     := oModel:GetValue('CN9MASTER','CN9_VLATU') //Valor Atualizado do Contrato
Local cNumero    := oModel:GetValue('CN9MASTER','CN9_NUMERO')
Local cTpRevi    := oModel:GetValue('CN9MASTER','CN9_TIPREV')
Local cPicture   := PesqPict("CN9","CN9_VLINI")
Local cLei       := ''
Local nVlMax     := 0
Local nVlMin     := 0
Local nPerc      := 0
Local nPorc      := 0
Local nPercant   := 0
Local nVrAdit    := 0
Local nValAnt    := 0
Local nUltValAtu := nVlTot
Local cTexto     := ""
Local lRet		:= .T.
Local lInclui	:= oModel:GetOperation() == MODEL_OPERATION_INSERT
Local nPorcRev	:= 0
Local cFilCtr	:= oModel:GetValue('CN9MASTER', IIF(Empty(cEdital),"CN9_FILCTR","CN9_FILEDT"))

CO1->(dbSetOrder(1))
If CO1->(dbSeek(xFilial("CO1", cFilCtr) + cEdital + cProcesso))//Posiciona no edital para ver qual é a espécie
	cLei := CO1->CO1_LEI
	If CO1->CO1_REFORM == "1" //-- Reformas: 50%
		nPerc := 0.50
	ElseIf CO1->CO1_REFORM == "2" //-- Obras e servicos: 25%
		nPerc := 0.25
	EndIf
EndIf
//Para empresas com regulamento interno não sujeitas às leis 8666 ou 10520
If cLei != '2' 
	CN9->(DbSetOrder(1))
	If CN9->(DbSeek(xFilial("CN9")+cNumero))
		While CN9->(!EOF()) .And. CN9->CN9_NUMERO == cNumero
			If lInclui .Or. !(CN9->CN9_SITUAC == '09') //não considera alteração da revisão antes da aprovação
	    		If Empty(CN9->CN9_REVISA) //Quando for o primeiro registro
	    			nUltValAtu:= CN9->CN9_VLATU
	    		Else
	        		CN0->(DbSetOrder(1)) //Posicionar para verificar o tipo de revisão
	        		CN0->(DbSeek(xFilial("CN0")+ CN9->CN9_TIPREV))
	        		If CN0->CN0_REPACT == "1"
						nVrAdit := 0
						nUltValAtu := CN9->CN9_VLATU
						nPorc := 0
	        		Else
						nVrAdit += (CN9->CN9_VLATU - nUltValAtu)//
	                    nPercant := nPorc
						nPorcRev := ((CN9->CN9_VLATU-nUltValAtu)/nUltValAtu)
						nPorc += nPorcRev //
	        			If nPorc > nPerc
	        				nVlMax := nUltValAtu  * (1+nPercAnt+nPerc)
	        				nVlMin := nUltValAtu * (1-nPerc)
	        				If (nVlTot > nVlMax .Or. nVlTot < nVlMin)
	        					lRet := .F.
	                            cTexto := STR0030 + LTrim(STR(nPorc * 100)) + STR0031 +Transform(nUltValAtu,cPicture)+;
	                                      STR0032 + LTrim(Transform(nVlMin,cPicture)) + STR0017 + LTrim(Transform(nVlMax,cPicture)) +"."
	                            Help('',1,'CN300PORCENT',,cTexto,4)
	        				EndIf
	        				Exit
	        			EndIf
	        		EndIf
	            EndIf
	            nValAnt   := CN9->CN9_VLATU
	        EndIf
			CN9->(DbSkip())
		EndDo
	
	    //Verifica valor atual - inclusão ou alteração
	    CN0->(dbSetOrder(1))
	    CN0->(dbSeek(xFilial("CN0")+ cTpRevi))
	    If CN0->CN0_REPACT == "2"
	        nPercant := nPorc
	        nPorc   += ((nVlTot - nUltValAtu)/nUltValAtu)
	        If nPorc > nPerc
	            nVlMax := nUltValAtu  * (1-nPercAnt+nPerc)
	            nVlMin := nUltValAtu  * (1-nPerc)
	            If (nVlTot > nVlMax .Or. nVlTot < nVlMin)
	                lRet := .F.
	                cTexto := STR0030 + LTrim(STR(nPorc * 100)) + STR0031 +Transform(nUltValAtu,cPicture)+;
	                          STR0032 + LTrim(Transform(nVlMin,cPicture)) + STR0017 + LTrim(Transform(nVlMax,cPicture)) +"."
	                Help('',1,'CN300PORCENT',,cTexto,4)
	            EndIf
	        EndIf
	    EndIf
	EndIf
EndIf

RestArea(aAreaCN9)
RestArea(aArea)
FWRestRows( aSaveLines )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CN300GerApr
Realiza a geração de registros para aprovação SCR

@author Leonardo Quintania
@since 25/02/2015
@version P12.1.4
/*/
//-------------------------------------------------------------------
Static function CN300GerApr( oModelCN9, nOper, nTipOpr )
Local cDoc     	:= ""   	// Documento composto de numero do contrato + revisao
Local cTipoDoc 	:= "RV"		// Indica que o documento é do tipo revisao de contrato
Local cContra	:= oModelCN9:GetValue("CN9_NUMERO")
Local cRevisa	:= oModelCN9:GetValue("CN9_REVISA")
Local cGrpApr	:= oModelCN9:GetValue("CN9_APROV")
Local nVlrApr	:= Cn300VlApr(oModelCN9)
Local nTxMoeda 	:= 0
Local lRet	   	:= .T.
Local aCampos	:= {}
Default nOper	:= 1

cDoc := cContra + cRevisa //Contrato + Revisão

If nOper == 1
	nTxMoeda := RecMoeda(dDataBase,CN9->CN9_MOEDA) 	// Taxa da moeda
	aAdd( aCampos, {cDoc,cTipoDoc,nVlrApr,"","",cGrpApr,"",CN9->CN9_MOEDA,nTxMoeda,dDataBase,""} )
Else
	aAdd( aCampos, {cDoc,cTipoDoc,nVlrApr,"","",cGrpApr,"","","",dDataBase,""} )	
EndIf

lRet := GCTAlcEnt( oModelCN9:GetModel(), nTipOpr, nOper, cTipoDoc, cDoc,, aCampos )

Return lRet
//------------------------------------------------------------------
/*/{Protheus.doc} A300AtuNE()
Funcao para atualizar a nota de empenho na revisão do contrato

@param oModel Modelo de dados
@author Flavio Lopes Rasta
@since 30/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static function A300AtuNE(oModel)
Local oModelCN9		:= oModel:GetModel('CN9MASTER')
Local oModelCNA		:= oModel:GetModel('CNADETAIL')
Local oModelCNB		:= oModel:GetModel('CNBDETAIL')
Local aItensAnt		:= {}
Local aItensDep		:= {}
Local aItens		:= {}
Local aDados		:= {}
Local aDadosNew	:= {}
Local nPos			:= 0
Local nPosRep		:= 1
Local nX 			:= 1
Local nY 			:= 1
Local nZ			:= 0
Local cContrato		:= oModelCN9:GetValue('CN9_NUMERO')
Local cRevisa		:= oModelCN9:GetValue('CN9_REVISA')
Local cRevAtu		:= ""
Local cNotaEmp
Local cItNotaEmp
Local nValor		:= 0
Local lRet			:= .T.

//-- Adiciona ao array os dados novos da CNB
For nX:=1 To oModelCNA:Length()
	oModelCNA:GoLine(nX)
	If !oModelCNA:IsDeleted()
		For nY:=1 To oModelCNB:Length()
			oModelCNB:GoLine(nY)
			If !Empty(oModelCNB:GetValue('CNB_CODNE'))
				cNotaEmp 	:= oModelCNB:GetValue('CNB_CODNE')
				cItNotaEmp 	:= oModelCNB:GetValue('CNB_ITEMNE')
				nValor		:= oModelCNB:GetValue('CNB_QUANT') * oModelCNB:GetValue('CNB_VLUNIT')
				If (nPosRep := aScan(aItensDep,{|x| AllTrim(x[1]) + AllTrim(x[2]) ==  AllTrim(cNotaEmp) + AllTrim(cItNotaEmp)}) ) > 0
					aItensDep[nPosRep][3] := aItensDep[nPosRep][3]+nValor
				Else
					aAdd(aItens,cNotaEmp)
					aAdd(aItens,cItNotaEmp)
					aAdd(aItens,nValor)
					aAdd(aItensDep, aItens)
				Endif
				aItens:={}
			Endif
		Next nY
	Endif
Next nX


If !Empty(aItensDep)
	aSort(aItensDep, , , { | x,y | x[1]+x[2] < y[1]+y[2] } )

	//-- Obtem a revisão anterior
	CN9->(DbSetOrder(8))
	CN9->(DbSeek(xFilial("CN9")+cContrato+cRevisa))


	cRevAtu := CN9->CN9_REVISA+Space(TamSX3("CN9_REVISA")[1]-Len(CN9->CN9_REVISA))

	//-- Seleciona o contrato vigente anterior a revisão
	CNB->(DbSetOrder(1))
	CNB->(DbSeek(xFilial("CNB")+cContrato+cRevAtu))
	While !CNB->(Eof()) .And. CNB->(CNB_CONTRA+CNB_REVISA) == cContrato+cRevAtu
		If !Empty(CNB->CNB_CODNE)
			cNotaEmp 	:= CNB->CNB_CODNE
			cItNotaEmp 	:= CNB->CNB_ITEMNE
			nValor		:= CNB->CNB_QUANT * CNB->CNB_VLUNIT
			//-- Adiciona ao array os dados antigos da CNB
			If (nPosRep := aScan(aItensAnt,{|x| AllTrim(x[1]) + AllTrim(x[2]) ==  AllTrim(cNotaEmp) + AllTrim(cItNotaEmp)}) ) > 0
				aAdd(aItensAnt[nPosRep][3],aItensAnt[nPosRep][3]+nValor)
			Else
				aAdd(aItens,cNotaEmp)
				aAdd(aItens,cItNotaEmp)
				aAdd(aItens,nValor)
				aAdd(aItensAnt,aItens)
			Endif
			aItens:={}
		Endif
		CNB->(DbSkip())
	End

	aSort(aItensAnt, , , { | x,y | x[1]+x[2] < y[1]+y[2] } )

	//-- Compara os valores

	For nX:=1 To Len(aItensDep)
		For nY:=1 To Len(aItensAnt)
			If aItensDep[nX][1]+aItensDep[nX][2] == aItensAnt[nY][1]+aItensAnt[nY][2]
				If aItensAnt[nX][3] <> aItensDep[nY][3]
					aAdd(aDados,{})
		  			aAdd(aTail(aDados),aItensDep[nX][1])
					aAdd(aTail(aDados),aItensDep[nX][2])
					aAdd(aTail(aDados),aItensAnt[nY][3])
					aAdd(aTail(aDados),aItensDep[nX][3])
				Endif
			EndIf
		Next nY
	Next nX

	//Aglutina por nota de empenho
	For nZ := 1 To Len(aDados)
	 	nPos := aScan(aDadosNew,{|x| AllTrim(x[1])== AllTrim(aDados[nZ][1])})
	 	If nPos > 0
			aAdd(aDadosNew[nPos],{aDados[nZ][2],aDados[nZ][3],aDados[nZ][4]})
		Else
			aAdd(aDadosNew,{})
			aAdd(aTail(aDadosNew),aDados[nZ][1])
  			aAdd(aTail(aDadosNew),{aDados[nZ][2],aDados[nZ][3],aDados[nZ][4]})
		EndIf
	Next nZ

	If !Empty(aDadosNew)
		lRet := GCPXRefCan(aDadosNew)
	EndIf
Endif

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} A300CpoUsr()
Funcao para validação do array informado pelo usuario no ponto de entrada CN300USRFD

@param 		aCpoUsr
@author 	Israel.Escorizza
@since 		24/04/2015
@version 	1.0
/*/
//-------------------------------------------------------------------

Static function A300CpoUsr(aUsrCpo)
Local nIndex 	:= 1
Local nIndCpo	:= 1
Local nIndErr	:= 1
Local aErros	:= {}
Local cError	:= CRLF

Default aUsrCpo	:= ""

If ValType(aUsrCpo)=="A"
	While nIndex <= Len(aUsrCpo)
		//- Verifica se a posição do array contem um array
		If ValType(aUsrCpo[nIndex]) != "A"
			aAdd(aErros,STR0002)
			aDel(aUsrCpo,nIndex)
			aSize(aUsrCpo,Len(aUsrCpo)-1)
		Else
			//- Verifica se tabela informada faz parte do modelo
			If aUsrCpo[nIndex][1] $ "AGW|CN8|CNA|CNB|CNC|CNF|CNG|CNH|CNI|CNK|CNN|CNS|CNT|CNU|CNV|CNW|CNX|CNZ|CPD|CXI|CXL|CXM|CN9|CND"
				If aUsrCpo[nIndex][1] == "CN9"
					aUsrCpo[nIndex][1]=aUsrCpo[nIndex][1]+"MASTER"
				Else
					aUsrCpo[nIndex][1]=aUsrCpo[nIndex][1]+"DETAIL"
				EndIf

				//- Verifica se campos do usuario foram informados em um array.
				If ValType(aUsrCpo[nIndex][2]) != "A"
					aAdd(aErros,STR0002)
					aDel(aUsrCpo,nIndex)
					aSize(aUsrCpo,Len(aUsrCpo)-1)
				Else
					nIndCpo := 1
					SX3->(dbSetOrder(2))
					While nIndCpo <= Len(aUsrCpo[nIndex][2])
						If !SX3->(dbSeek(aUsrCpo[nIndex][2][nIndCpo]))
							aAdd(aErros,STR0003+aUsrCpo[nIndex][2][nIndCpo])
							aDel(aUsrCpo[nIndex][2],nIndCpo)
							aSize(aUsrCpo[nIndex][2],Len(aUsrCpo[nIndex][2])-1)
						Else
							//- Verifica se campo é do usuario.
							If Empty(GetSX3Cache(aUsrCpo[nIndex][2][nIndCpo],'X3_PROPRI'))
								aAdd(aErros,STR0003+aUsrCpo[nIndex][2][nIndCpo])
								aDel(aUsrCpo[nIndex][2],nIndCpo)
								aSize(aUsrCpo[nIndex][2],Len(aUsrCpo[nIndex][2])-1)
							Else
								nIndCpo++
							EndIf
						EndIf
					EndDo
					If Len(aUsrCpo[nIndex][2]) == 0
						aDel(aUsrCpo,nIndex)
						aSize(aUsrCpo,Len(aUsrCpo)-1)
						nIndex--
					EndIf
				EndIf
			Else
				aAdd(aErros,STR0004+aUsrCpo[nIndex][1])
				aDel(aUsrCpo,nIndex)
				aSize(aUsrCpo,Len(aUsrCpo)-1)
			EndIf
		EndIf

		nIndex++
	EndDo
Else
	aAdd(aErros,STR0002)
EndIf

While nIndErr <= Len(aErros)
	cError+=aErros[nIndErr]+CRLF
	nIndErr++
EndDo
If Len(aErros) > 0
	Help("",1,cError)
EndIf

Return

//=============================================================================
/*/{Protheus.doc} A300RevSrv()
Função responsável pela atualização do campo “CNB_QUANT” na revisão de novo item
contido na planilha quando esta for de serviços.

@author israel.escorizza
@since 10/05/2016
@return
/*/
//=============================================================================
Static function A300RevSrv()
Local oModel	:= FwModelActive()
Local oModelCNF	:= oModel:GetModel('CNFDETAIL')

Local nQtdAbert	:= 0
Local nX		:= 0

If 	oModel:IsActive() .And. oModel:GetId() == 'CNTA300'	.And.;
	!Empty(oModel:GetValue('CN9MASTER','CN9_REVISA')) 	.And.;
	Empty(oModel:GetValue('CNBDETAIL','CNB_QUANT'))	 	.And.;
	!Empty(oModelCNF:GetValue('CNF_NUMERO'))			.And.;
	Cn300RetSt('SERVIÇO')

	For nX := 1 To oModelCNF:Length()
		oModelCNF:GoLine(nX)
		If !oModelCNF:IsDeleted() .And. Empty(oModelCNF:GetValue('CNF_DTREAL'))
			nQtdAbert++
		EndIf
	Next nX

	oModel:GetModel('CNBDETAIL'):GetStruct():SetProperty('CNB_QUANT'  ,MODEL_FIELD_WHEN,{||.T.})
	oModel:GetModel('CNBDETAIL'):GetStruct():SetProperty('CNB_SLDMED' ,MODEL_FIELD_WHEN,{||.T.})
	oModel:SetValue('CNBDETAIL','CNB_QUANT' ,nQtdAbert)
	oModel:SetValue('CNBDETAIL','CNB_SLDMED',nQtdAbert)
	oModel:GetModel('CNBDETAIL'):GetStruct():SetProperty('CNB_QUANT'  ,MODEL_FIELD_WHEN,{||.F.})
	oModel:GetModel('CNBDETAIL'):GetStruct():SetProperty('CNB_SLDMED' ,MODEL_FIELD_WHEN,{||.F.})
EndIf

Return
//------------------------------------------------------------------
/*/{Protheus.doc} CNQtRRetro()
Função que retorna array com os itens a serem considerados no
reajuste retroativo.

@author 	Matheus Lando
@since 		04/02/2016
/*/
//-------------------------------------------------------------------
Static function CNQtRRetro(cContra,cRevisa)
Local cAliasSql := GetNextAlias()
Local aProd	  := {}
Local dDtDe	  := CtoD("")
Local dDtAte	  := CtoD("")
Local oModel	  := FwModelActive()
Local oModCN9	  := oModel:GetModel('CN9MASTER')
Local lCposRet  := (CN9->(ColumnPos('CN9_DTRRDE')) > 0) .And. (CN9->(ColumnPos('CN9_DTRRAT')) > 0)

If lCposRet
	dDtDe 	 := oModCN9:GetValue("CN9_DTRRDE")
	dDtAte	 := oModCN9:GetValue("CN9_DTRRAT")
	If !Empty(dDtDe)
		BeginSQL Alias cAliasSql

		SELECT C7_PLANILH, C7_ITEMED,SUM(C7_QUJE) C7_QUJE FROM %Table:SC7% SC7
			INNER JOIN %Table:SD1% SD1 ON D1_FILIAL = %xFilial:SD1% AND  D1_PEDIDO = C7_NUM AND D1_ITEMPC = C7_ITEM AND SD1.%NotDel%
			INNER JOIN %Table:CNA% CNA ON (
					CNA_FILIAL = %xFilial:CNA% 
				AND CNA_CONTRA = C7_CONTRA 
				AND CNA_REVISA = C7_CONTREV
				AND CNA_NUMERO = C7_PLANILH 
				AND CNA.%NotDel%)
			WHERE  C7_FILIAL = %xFilial:SC7%
				AND SC7.%NotDel%
				AND C7_CONTRA = %Exp:cContra%
				AND D1_EMISSAO BETWEEN %Exp:dDtDe% AND %Exp:dDtAte%
				AND C7_CONTREV = %Exp:cRevisa%
				AND C7_QUJE > 0
			GROUP BY C7_PLANILH, C7_ITEMED
		EndSQL

	EndIf
EndIf

If Select(cAliasSql) > 0
	While !(cAliasSql)->(Eof())
		Aadd(aProd, {(cAliasSql)->(C7_PLANILH),(cAliasSql)->(C7_ITEMED),(cAliasSql)->(C7_QUJE)})
		(cAliasSql)->(DbSkip())
	EndDo
	(cAliasSql)->(dbCloseArea())
EndIf

Return aProd
//------------------------------------------------------------------
/*/{Protheus.doc} CNAddItRt()
Função que adiciona os itens referentes ao reajustes retroativo

@author 	Matheus Lando
@since 		04/02/2016
/*/
//-------------------------------------------------------------------
Static function CNAddItRt()
	Local oModel 	:= FwModelActive()
	Local oModCN9 	:= oModel:GetModel('CN9MASTER')
	Local oModCNB 	:= oModel:GetModel('CNBDETAIL')
	Local oModCNA 	:= oModel:GetModel('CNADETAIL')
	Local nX		:= 0
	Local nY		:= 0
	Local aHeader	:= oModCNB:GetStruct():GetFields()
	Local cContra	:= oModCN9:GetValue("CN9_NUMERO")
	Local oStruCNB 	:= oModCNB:GetStruct()
	Local oStruCNA 	:= oModCNA:GetStruct()
	Local aProds	:= {}
	Local aItem		:= {}
	Local aSaveLines:= FWSaveRows()
	Local nVlrAtu	:= 0
	Local nVlrOri	:= 0
	Local cTipRev	:= Cn300RetSt('TIPREV',1)
	Local cCodTpRev	:= oModel:GetValue('CN9MASTER','CN9_TIPREV')
	Local nLinhaOrig:= 0
	Local bTrueWhen	:= Nil
	Local aProps	:= {}

	If  A300ApReRet(cCodTpRev) .And. !Cn300RetSt('FISICO',1)

		aProds := CNQtRRetro(cContra,CnRevAnt())

		If Len(aProds) > 0
			aAdd(aProps,{GetPropMdl(oModCNA), GCTGetWhen(oModCNA)})
			aAdd(aProps,{GetPropMdl(oModCNB), GCTGetWhen(oModCNB)})
			oModCNA:SetNoUpdateLine(.F.)

			bTrueWhen := FwBuildFeature( STRUCT_FEATURE_WHEN, ".T.")
			oStruCNB:SetProperty("*",MODEL_FIELD_WHEN,bTrueWhen)
			oStruCNA:SetProperty("*",MODEL_FIELD_WHEN,bTrueWhen)
			
			For nX := 1 To Len(aProds)
				oModCNA:GoLine(MTFindMVC(oModCNA,{{'CNA_NUMERO',aProds[nX,1]}}))
				nLinhaOrig := MTFindMVC(oModCNB,{{'CNB_ITEM',aProds[nX,2]}})
				oModCNB:GoLine(nLinhaOrig)

				If oModCNB:GetValue("CNB_RJRTO")
					Loop
				EndIf
				
				nVlrOri := oModCNB:getValue("CNB_VLUNIT")// Recupera valor antigo, o atual e devolve posicionamento para o antigo
				nVlrAtu := 0

				While !Empty(oModCNB:GetValue('CNB_ITMDST'))
					oModCNB:GoLine(MTFindMVC(oModCNB,{{'CNB_ITEM',oModCNB:GetValue('CNB_ITMDST')}}))
					nVlrAtu := oModCNB:getValue("CNB_VLUNIT")
					
					If !Empty(oModCNB:GetValue('CNB_ITMDST'))
						nVlrOri += (nVlrAtu - nVlrOri) // Adiciona o valor do reajuste retroativo ao valor original.
					EndIf
				EndDo	
				
				oModCNB:GoLine(nLinhaOrig)

				// copia dados da origem
				If ((oModCNA:GetValue('CNA_FLREAJ') == '1' .And. cTipRev == DEF_REV_REAJU) .Or. cTipRev == DEF_REV_REALI) .And. (nVlrAtu-nVlrOri > 0)

					For nY := 1 to Len(aHeader)
						cCampo := AllTrim(aHeader[nY][MODEL_FIELD_IDFIELD])
						aAdd(aItem,{cCampo,oModCNB:GetValue(cCampo)})
					Next nY					

					For nY := 1 To Len(aItem)
						If nY == 1
							oModCNB:SetNoInsertLine(.F.)//Alguma trigger/valid bloqueia o modelo da CNB, por isso é necessário liberar em todas as iterações
							oModCNB:AddLine()
						EndIf

						If !(aItem[nY,1]) $ "CNB_REALI|CNB_VLTOTR|CNB_VLDESC" // Campos Calculados			

							If aItem[nY,1] == "CNB_ITEM"
								oModCNB:LoadValue("CNB_ITEM",StrZero(oModCNB:GetLine(),TamSX3("CNB_ITEM")[1]))
							ElseIf aItem[nY,1] == "CNB_QUANT"
								oModCNB:SetValue("CNB_QUANT", aProds[nX,3] )
								//Quantidade Medida Origem
							ElseIf aItem[nY,1] == "CNB_QTDMED"
								//Quantidade Medida Nova
								oModCNB:LoadValue("CNB_QTDMED",0)
								//Quantidade Medida Origem
							ElseIf aItem[nY,1] == "CNB_SLDMED"
								//Saldo a Medir Novo
								oModCNB:LoadValue("CNB_SLDMED",oModCNB:GetValue("CNB_QUANT"))
								//Saldo a Medir Origem
							ElseIf aItem[nY,1] == "CNB_SLDREC"
								//Saldo a Receber Novo
								oModCNB:LoadValue("CNB_SLDREC",0)
								//Saldo a Receber Origem
							ElseIf aItem[nY,1] == "CNB_ITMDST"
								// Deixa item novo em branco
								oModCNB:LoadValue("CNB_ITMDST","")
							ElseIf aItem[nY,1] == "CNB_QTDORI"
								oModCNB:LoadValue("CNB_QTDORI",0)
							ElseIf aItem[nY,1] == "CNB_RJRTO"
								oModCNB:LoadValue("CNB_RJRTO",.T.)
							ElseIf aItem[nY,1] == "CNB_VLUNIT"
								oModCNB:SetValue("CNB_VLUNIT",nVlrAtu-nVlrOri)
							Else
								oModCNB:SetValue(aItem[nY,1],aItem[nY,2])
							EndIf
						EndIf
					Next nY

					A300AtCrRj(oModCNB:GetValue('CNB_QUANT'),oModCNB:GetValue('CNB_VLUNIT'))

					aItem := {}
				EndIf

			Next nX	

			/*Restaura propriedades dos modelos*/
			RstPropMdl(oModCNA, aProps[1,1] )
			RstPropMdl(oModCNB, aProps[2,1] )	

			/*Restaura WHEN original dos campos do modelo*/
			GCTRstWhen(oModCNA, aProps[1,2] )
			GCTRstWhen(oModCNB, aProps[2,2] )
			
			FwFreeArray(aProds)
			FwFreeArray(aProps)
		EndIf

	EndIf
	FWRestRows(aSaveLines)
	FwFreeArray(aSaveLines)
Return


//------------------------------------------------------------------
/*/{Protheus.doc} A300AtCrRj()
Função que atualiza o cronograma financeiro refente ao
reajuste retroativo.

@author 	Matheus Lando
@since 		04/02/2016
/*/
//-------------------------------------------------------------------
Static function A300AtCrRj(nQuant,nVlrUnit)
Local oModel := FwModelActive()
Local oModCNS	:= oModel:GetModel("CNSDETAIL")
Local oModCNF	:= oModel:GetModel("CNFDETAIL")
Local nX		:= 0
Local aSavelines	:= FWSaveRows()


oModCNF:SetNoUpdateLine(.F.)
oModCNS:SetNoUpdateLine(.F.)

oModCNF:GetStruct():SetProperty("*",MODEL_FIELD_WHEN,{||.T.})
oModCNS:GetStruct():SetProperty("*",MODEL_FIELD_WHEN,{||.T.})

For nX := 1 To oModCNF:Length()
	oModCNF:Goline(nX)
	If !oModCNF:IsDeleted() .And. oModCNF:GetValue("CNF_VLREAL") == 0
		oModCNF:SetValue("CNF_VLPREV",oModCNF:GetValue("CNF_VLPREV")+(nQuant*nVlrUnit))
		Exit
	EndIf
Next nX

oModCNF:SetNoUpdateLine(.T.)
oModCNS:SetNoUpdateLine(.T.)

oModCNF:GetStruct():SetProperty("*",MODEL_FIELD_WHEN,{||.F.})
oModCNS:GetStruct():SetProperty("*",MODEL_FIELD_WHEN,{||.F.})

FwRestRows(aSaveLines)

Return

//=============================================================================
/*/{Protheus.doc} Cn300VlApr
Função responsável por retornar o valor que será enviado para aprovação da revisão
baseado nos parametros MV_CNRVDIF e MV_CNRVSAL

@author israel.escorizza
@since 23/01/2017
@return nRet
/*/
//=============================================================================
Static function Cn300VlApr(oModelCN9, nRecCNA)
	Local aAreas	:= {CN9->(GetArea()), CNA->(GetArea()), GetArea()}
	Local cAprRvDif	:= SuperGetMV('MV_CNRVDIF',.F.,"")	//- Tipos de revisão aprovação por dif. valor total
	Local cAprRvSal	:= SuperGetMV('MV_CNRVSAL',.F.,"")	//- Tipos de revisão aprovação por valor do saldo

	Local cNumDoc	:= ""
	Local cTipRev	:= ""
	Local cRevVal	:= "1|2|3|C|G" //- Aditivo|Reajuste|Realinhamento|Renovação|Aberta

	Local nSaldo	:= 0
	Local nVlAtu	:= 0
	Local nRet		:= 0

	Local lPlan     := .F.

	Default nRecCNA := 0

	lPlan := nRecCNA > 0

	If lPlan //-- Obtem saldo e valor atual da planilha
		CNA->(dbGoto(nRecCNA))
		CN9->(dbSetOrder(1))
		CN9->(MsSeek(xFilial('CN9')+CNA->(CNA_CONTRA+CNA_REVISA)))
		cNumDoc := CN9->(CN9_NUMERO+CN9_REVISA)
		nSaldo := CNA->CNA_SALDO
		nVlAtu := CNA->CNA_VLTOT
	ElseIf !Empty(oModelCN9) //-- Obtem saldo e valor atual do contrato
		cNumDoc	:= oModelCN9:GetValue("CN9_NUMERO")+oModelCN9:GetValue("CN9_REVISA")
		nSaldo	:= oModelCN9:GetValue("CN9_SALDO")
		nVlAtu	:= oModelCN9:GetValue("CN9_VLATU")
	Else
		cNumDoc := CN9->(CN9_NUMERO+CN9_REVISA)
		nSaldo 	:= CN9->CN9_SALDO
		nVlAtu	:= CN9->CN9_VLATU
	EndIf

	cTipRev	:= Cn300RetSt("TIPREV",,,CnGetCtNum(cNumDoc,"RV"))
	cRevVg	:= CnGetRevVg(CN9->CN9_NUMERO, CN9->CN9_FILCTR)
	If (CN9->CN9_REVISA == cRevVg)/*Esse cenário ocorre ao visualizar um documento já aprovado*/
		cRevVg := CnRevAnt(.F., CN9->CN9_REVISA)
	EndIf

	If cTipRev $ cRevVal		
		If cTipRev $ cAprRvSal 			//- Aprovação por saldo
			nRet := nSaldo
		ElseIf cTipRev $ cAprRvDif		//- Aprovação por diferença de valor do contrato/planilha
			If lPlan
				CNA->(dbSetOrder(1))
				CNA->(MsSeek(xFilial('CNA')+CNA->(CNA_CONTRA+cRevVg+CNA->CNA_NUMERO)))
				nRet := nVlAtu - CNA->CNA_VLTOT
			Else
				dbSelectArea('CN9')
				CN9->(dbSetOrder(1))
				CN9->(MsSeek(xFilial('CN9')+CN9->(CN9_NUMERO)+cRevVg))
				nRet := nVlAtu - CN9->CN9_VLATU
			EndIf

			nRet := Max(nRet, 0)
		Else							//- Aprovação por valor do contrato
			nRet := nVlAtu
		EndIf
	Else
		nRet := Iif(lPlan, CNA->CNA_VLTOT, 0)
	EndIf

	aEval(aAreas, {|x| RestArea(x) })
	FwFreeArray(aAreas)
Return nRet

//------------------------------------------------------------------
/*/{Protheus.doc} A300RvPrz()
Funcao para validação referente ao art. 57 da lei 8666. Caso exista adição
de prazo, não será validado o valor aditivado. Funçao utilizada em contratos
gerados pelo modulo Gestão de Compras Públicas.

@author 	Jose.Delmondes
@since 		09/06/2016
@version 	1.0
/*/
//-------------------------------------------------------------------
Static function A300RvPrz(oModel,cEdital,cProcesso)
Local lRet			:= .T.
Local cTpRev		:= oModel:GetValue('CN9MASTER','CN9_TIPREV')
Local cRevAnt		:= Tira1(oModel:GetModel("CN9MASTER"):GetValue("CN9_REVISA"))
Local aArea			:= GetArea()
Local aAreaCN0		:= {}
Local aAreaCN9		:= {}
Local cLei			:= ''

Default oModel		:= FwModelActive()
Default cEdital		:= ""
Default cProcesso	:= ""

//-- Posiciona no edital para ver qual é a espécie
CO1->(dbSetOrder(1))
If CO1->(dbSeek(xFilial("CO1")+cEdital+cProcesso))
	cLei := CO1->CO1_LEI
EndIf

//Para empresas com regulamento interno não sujeitas às leis 8666 ou 10520
If !Empty(cLei) .And. !(cLei == '2' )

	If cRevAnt = Replicate('0',TamSX3("CN9_REVISA")[1]) // Ajusta Tira1
		cRevAnt = Replicate(' ',TamSX3("CN9_REVISA")[1])
	EndIf

	dbSelectArea("CN0")
	aAreaCN0 := CN0->(GetArea())
	CN0->(dbsetOrder(1))

	If CN0->(dbSeek(xFilial("CN0")+cTpRev)) .And. CN0->CN0_ESPEC $ '3*4' .And. CN0->CN0_MODO $ '1*3'
		dbSelectArea("CN9")
		aAreaCN9 := CN9->(GetArea())
		CN9->(dbSetorder(1))
		If CN9->(dbSeek(xFilial("CN9")+oModel:GetValue('CN9MASTER','CN9_NUMERO')+cRevAnt))
			If DateDiffDay(CN9->CN9_DTFIM,oModel:GetValue('CN9MASTER','CN9_DTFIM')) > 0
				lRet := .F.
			EndIf
		EndIf
		RestArea(aAreaCN9)
	EndIf
	RestArea(aAreaCN0)
EndIf
RestArea(aArea)

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} CN300CNZVD()
Função para liberar o modelo da CNZ quando feita alterações na quantidade

@author 	filipe.goncalves
@since 		17/04/2017
@version 	1.0
/*/
//-------------------------------------------------------------------
Static function CN300CNZVD(oModel)
Local aCTBEnt	:= CTBEntArr()
Local aCampos   := {}
Local cAutom	:= oModel:GetModel("CN9MASTER"):GetValue("CN9_AUTO") // -- 0 - Default; 1 - Vindo da Automação (Robô)
Local nX		:= 0

aCampos := {}

If cAutom == '0'
	aAdd(aCampos,{'CNZDETAIL',{'CNZ_PERC','CNZ_CC','CNZ_CONTA','CNZ_ITEMCT','CNZ_CLVL'}})
Else
	aAdd(aCampos,{'CNZDETAIL',{'CNZ_ITEM','CNZ_PERC','CNZ_CC','CNZ_CONTA','CNZ_ITEMCT','CNZ_CLVL'}})
EndIf

For nX := 1 To Len(aCTBEnt)
	aAdd(aCampos,{'CNZDETAIL', {"CNZ_EC" +aCTBEnt[nX] +"CR" }})
	aAdd(aCampos,{'CNZDETAIL', {"CNZ_EC" +aCTBEnt[nX] +"DB" }})
Next nX

MtBCMod(oModel,aCampos,{||.T.},'2')

Return

//------------------------------------------------------------------
/*/{Protheus.doc} Cn300AtLiq(cNumMed,cRevisa)
Função que atualiza o valor liquido dos itens da medição na aprovação de revisão.

@author 	Israel.escorizza
@since 		24/11/2017
@version 	1.0
/*/
//-------------------------------------------------------------------
Static function Cn300AtLiq(cNumMed,cContra,cRevisa,l121)
Local lRet 		:= .T.
Local aArea		:= GetArea()
Local aAreaCNE	:= CNE->(GetArea())
Local aSaveLines:= FWSaveRows()
Local cEspCtr	:= Iif(	Cn300RetSt('COMPRA',1,"",cContra+cRevisa,,.F.),'1','2')
Local cAliasCNE := GetNextAlias()

Default l121 := .F.

BeginSQL Alias cAliasCNE

SELECT	CNE.R_E_C_N_O_ as RECNO,
		CNE.CNE_VLTOT,
		CNE.CNE_VLDESC,
		CNE.CNE_EXCEDE,
		CXN.CXN_VLLIQD,
		CXN.CXN_VLMULT,
		CXN.CXN_VLBONI,
		CXN.CXN_VLDESC,
		CXN.CXN_VLRADI

FROM %Table:CNE% CNE
LEFT JOIN %Table:CXN% CXN ON

CNE.CNE_CONTRA = CXN.CXN_CONTRA AND
CNE.CNE_REVISA = CXN.CXN_REVISA AND
CNE.CNE_NUMMED = CXN.CXN_NUMMED

WHERE
CNE.CNE_CONTRA = %Exp:cContra% AND
CNE.CNE_REVISA = %Exp:cRevisa% AND
CNE.CNE_NUMMED = %Exp:cNumMed%

EndSql

While !(cAliasCNE)->(EOF())
	If (cAliasCNE)->CNE_EXCEDE == '1'
		nVlLiqd	:= (cAliasCNE)->CNE_VLTOT
	Else
		If l121
			nVlLiqd := CN130Liq(cEspCtr, (cAliasCNE)->CNE_VLTOT, (cAliasCNE)->CNE_VLDESC, (cAliasCNE)->CXN_VLLIQD, (cAliasCNE)->CXN_VLMULT, (cAliasCNE)->CXN_VLBONI, (cAliasCNE)->CXN_VLDESC, CND->CND_RETCAC * ((cAliasCNE)->CXN_VLLIQD / CND->CND_VLLIQD) ,(cAliasCNE)->CXN_VLRADI)
		Else
			nVlLiqd := CN130Liq(cEspCtr, (cAliasCNE)->CNE_VLTOT, (cAliasCNE)->CNE_VLDESC, CND->CND_VLTOT, CND->CND_VLMULT, CND->CND_VLBONI, CND->CND_DESCME, CND->CND_RETCAC, CND->CND_TOTADT)
		EndIf
	EndIf

	CNE->(dbGoTo((cAliasCNE)->RECNO))
	RecLock("CNE",.F.)
	CNE->CNE_VLLIQD := nVlLiqd
	MsUnlock()
	(cAliasCNE)->(dbSkip())
EndDo
(cAliasCNE)->(dbCloseArea())

FWRestRows(aSaveLines)
RestArea(aAreaCNE)
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300ApReRet
Valida se tipo de revisão aplica reajuste retroativo. 
@param cCodTpRev, Caracter,  Tipo de revisão
@return lRet, Lógico, Verdadeiro/Falso
@author Eduardo Gomes Júnior
@since 16/03/2018
/*/
//-------------------------------------------------------------------
Static function A300ApReRet(cCodTpRev)

Local aArea	:= GetArea()
Local lRet  := .F.

dbSelectArea("CN0")
dbSetOrder(1)
If	dbSeek(xFilial("CN0")+cCodTpRev)
	If	CN0_RETRO == "1"
		lRet  := .T.
	Endif 		 
Endif 

RestArea(aArea)

Return lRet

/*/{Protheus.doc} ClrVCpoUsr
Função para limpar a variável estática, com os campos de usuário do model  

@author pedro.alencar
@since 05/09/2018
/*/
Static function ClrVCpoUsr ()

	If __aUsrCpo <> Nil
		aSize( __aUsrCpo, 0 )
		__aUsrCpo := Nil
	EndIf
	
Return Nil

/*/{Protheus.doc} CNLibForCl
Função que libera os campos relacionados a alteração de fornecedor e cliente 
@param oModel, modelo de dados
@param lFusao, logico
@author janaina.jesus
@since 23/11/2018
/*/
Static function CNLibForCl(oModel,lFusao)
	Local cEspec     := Cn300RetSt("REVESPECIE")
	Local aCampos    := {}
	Local oStruCNA   := oModel:GetModel('CNADETAIL'):GetStruct()
	Local oStruCNC   := oModel:GetModel('CNCDETAIL'):GetStruct()
	Local bTrueWhen	 := FwBuildFeature( STRUCT_FEATURE_WHEN, ".T.")
	Local bNewLine	 := FwBuildFeature( STRUCT_FEATURE_WHEN, "A300NwLine('CNCDETAIL')")
	
	CNTA300BlMd(oModel:GetModel("CNCDETAIL"),.F.,.F.)
	CNTA300BlMd(oModel:GetModel("CPDDETAIL"),.F.,.F.)
	
	If cEspec <> "5"		
		CNTA300BlMd(oModel:GetModel("CNADETAIL"), ,.T.)		
	EndIf
	
	If lFusao
		If CNTGetFun() == 'CNTA300'
			oStruCNC:SetProperty("CNC_CODIGO",	MODEL_FIELD_WHEN,{||.T.})
			oStruCNC:SetProperty("CNC_LOJA",	MODEL_FIELD_WHEN,{||.T.})
			oStruCNC:SetProperty("CNC_NOME",	MODEL_FIELD_WHEN,{||.T.})
			oStruCNA:SetProperty('CNA_FORNEC',	MODEL_FIELD_WHEN,{||.T.})
			oStruCNA:SetProperty('CNA_LJFORN',	MODEL_FIELD_WHEN,{||.T.})
		Else
			oStruCNC:SetProperty('CNC_CLIENT',	MODEL_FIELD_WHEN,{||.T.})
			oStruCNC:SetProperty('CNC_LOJACL',	MODEL_FIELD_WHEN,{||.T.})
			oStruCNC:SetProperty('CNC_NOMECL',	MODEL_FIELD_WHEN,{||.T.})
			oStruCNA:SetProperty('CNA_CLIENT',	MODEL_FIELD_WHEN,{||.T.})
			oStruCNA:SetProperty('CNA_LOJACL',	MODEL_FIELD_WHEN,{||.T.})

		    // Partes Envolvidas do Contrato
		   aCampos := {}
		   aAdd(aCampos,{'CXIDETAIL',{'CXI_TIPO','CXI_CODCLI','CXI_LOJACL','CXI_NOMCLI','CXI_FILRES','CXI_DESFIL','CXI_PERRAT'}})
		   MtBCMod(oModel,aCampos,{||.T.},'2')
		   CNTA300BlMd(oModel:GetModel("CXIDETAIL"),.F.,.F.)
		EndIf
	Else
		If CNTGetFun() == 'CNTA300'
			oStruCNC:SetProperty('CNC_CODIGO',	MODEL_FIELD_WHEN,bNewLine)
			oStruCNC:SetProperty('CNC_LOJA',	MODEL_FIELD_WHEN,bNewLine)
			oStruCNC:SetProperty('CNC_NOME',	MODEL_FIELD_WHEN,bNewLine)
			oStruCNA:SetProperty('CNA_FORNEC',	MODEL_FIELD_WHEN,bTrueWhen)
			oStruCNA:SetProperty('CNA_LJFORN',	MODEL_FIELD_WHEN,bTrueWhen)
		Else
			oStruCNC:SetProperty('CNC_CLIENT',	MODEL_FIELD_WHEN,bNewLine)
			oStruCNC:SetProperty('CNC_LOJACL',	MODEL_FIELD_WHEN,bNewLine)
			oStruCNC:SetProperty('CNC_NOMECL',	MODEL_FIELD_WHEN,bNewLine)
			oStruCNA:SetProperty('CNA_CLIENT',	MODEL_FIELD_WHEN,bTrueWhen)
			oStruCNA:SetProperty('CNA_LOJACL',	MODEL_FIELD_WHEN,bTrueWhen)

			// Partes Envolvidas do Contrato
			aCampos := {}
			aAdd(aCampos,{'CXIDETAIL',{'CXI_TIPO','CXI_CODCLI','CXI_LOJACL','CXI_NOMCLI','CXI_FILRES','CXI_DESFIL','CXI_PERRAT'}})
			MtBCMod(oModel,aCampos,{||.T.},'2')
			CNTA300BlMd(oModel:GetModel("CXIDETAIL"),.F.,.F.)
		EndIf
	EndIf
Return

/*/{Protheus.doc} CNLibConta
Função que libera os campos relacionados ao Contábel 
@param oModel, modelo de dados
@author janaina.jesus
@since 03/12/2018
/*/
Static function CNLibConta(oModel)

	Local aCampos    := {}
	Local aCTBEnt    := {}
	Local nX         := 0

	aCTBEnt := CTBEntArr()

	If Cn300RetSt('SEMIAGRUP')
		CNTA300BlMd(oModel:GetModel("CXMDETAIL"),,.T.)
		aAdd(aCampos,{'CXMDETAIL',{'CXM_CC'}})

			For nX := 1 To Len(aCTBEnt)
			If CXM->(FieldPos("CXM_EC" +aCTBEnt[nX] +"CR")) > 0
				aAdd(aCampos[Len(aCampos),2],"CXM_EC" +aCTBEnt[nX] +"CR")
				aAdd(aCampos[Len(aCampos),2],"CXM_EC" +aCTBEnt[nX] +"DB")
			EndIf
		Next nX
		MtBCMod(oModel,aCampos,{||.T.},'2')
	Else
		CNTA300BlMd(oModel:GetModel("CNBDETAIL"),,.T.)
		CNTA300BlMd(oModel:GetModel("CNZDETAIL"),.F.)

		aAdd(aCampos,{'CNBDETAIL',{'CNB_CONTA','CNB_ITEMCT','CNB_CC','CNB_CLVL'}})

		For nX := 1 To Len(aCTBEnt)
			If CNB->(FieldPos("CNB_EC" +aCTBEnt[nX] +"CR")) > 0
				aAdd(aCampos[Len(aCampos),2],"CNB_EC" +aCTBEnt[nX] +"CR")
				aAdd(aCampos[Len(aCampos),2],"CNB_EC" +aCTBEnt[nX] +"DB")
			EndIf
		Next nX

		aAdd(aCampos,{'CNZDETAIL',{'CNZ_ITEM','CNZ_PERC','CNZ_CC','CNZ_CONTA','CNZ_ITEMCT','CNZ_CLVL'}})

		For nX := 1 To Len(aCTBEnt)
			aAdd(aCampos[Len(aCampos),2],"CNZ_EC" +aCTBEnt[nX] +"CR")
			aAdd(aCampos[Len(aCampos),2],"CNZ_EC" +aCTBEnt[nX] +"DB")
		Next nX
		MtBCMod(oModel,aCampos,{||.T.},'2')
		A300RevCtb(oModel)
	EndIf

Return

/*/{Protheus.doc} ConFldsTab
	Configurar os campos(fields) de <cTabela> no
	alias <cUmAlias> utilizando como base a estrutura em
	<aTabStruct>(caso esteja vazio sera carregado.)
@author philipe.pompeu
@since 11/06/2019
@return Nil, nulo
@param cUmAlias, caracter, um Alias qualquer
@param cTabela, caracter, uma tabela do dicionario
@param aTabStruct, vetor, estrutura de <cTabela>
/*/
Static Function ConFldsTab(cUmAlias, cTabela, aTabStruct)
	Local nI := 0
	Local lAddPos := .F.
	
	If(Empty(aTabStruct))
		aTabStruct := (cTabela)->(DbStruct())
		lAddPos := .T.
	EndIf

	For nI:= 1 to Len(aTabStruct)
		If(lAddPos)
			aAdd(aTabStruct[nI], (cTabela)->(FieldPos(aTabStruct[nI,1])))
		EndIf		
		
		If aTabStruct[nI,2] $  "D|L|N"			
			TCSetField(cUmAlias, aTabStruct[nI,1], aTabStruct[nI,2], aTabStruct[nI,3], aTabStruct[nI,4])
		EndIf
	Next nI
Return Nil

/*/{Protheus.doc} CopiaReg
	Copia os dados da linha atual de <cUmAlias> para
	o a tabela informada em <cTabela> utilizando a estrutura
	fornecida em <aTabStruct>.
	<cTabela> deve estar lockada(RecLock).
@author philipe.pompeu
@since 11/06/2019
@return Nil, nulo
@param cTabela, caracter, tabela a ser gravada
@param cUmAlias, caracter, um Alias qualquer
@param aTabStruct, vetor, estrutura de <cTabela>
/*/
Static Function CopiaReg(cTabela, cUmAlias, aTabStruct)
	Local nZ := 0	
	For nZ := 1 to Len(aTabStruct)
		If((cUmAlias)->(FieldPos(aTabStruct[nZ,1]) > 0))
			(cTabela)->(FieldPut(aTail(aTabStruct[nZ]), (cUmAlias)->(&(aTabStruct[nZ,1]))))
		EndIf
	Next nZ				
Return

/*/{Protheus.doc} CNLibVend
//Libera os campos de código e comissão do vendedor.
@author juan.felipe
@since 05/09/2019
@version 1.0
@return Nil, nulo
@param oModel, object, Modelo de dados.
@type function
/*/
Static Function CNLibVend(oModel)
	Local oModelCNU  := oModel:GetModel('CNUDETAIL')
	Local oStruCNU   := oModel:GetModel('CNUDETAIL'):GetStruct()
	
	CNTA300BlMd(oModelCNU,.F.)
	oStruCNU:SetProperty('*',MODEL_FIELD_WHEN,{||.T.})
Return

/*/{Protheus.doc} A300AtCNU
//Atualiza registros da tabela CNU na revisão do contrato
REMOVER após o término da release 12.1.23
@author juan.felipe
@since 11/09/2019
@version 1.0
@return Nil, nulo
@param oModel, object, modelo de dados
@type function
/*/
Static function A300RAtCNU(oModel)
    Local nI 		 := 0
	Local nDeletado  := 0
    Local nEncontrou := 0
    Local cContra 	 := oModel:GetModel('CN9MASTER'):GetValue('CN9_NUMERO')
    Local cAliasCNU  := GetNextAlias()
    Local cFilCNU 	 := xFilial('CNU', CN9->CN9_FILCTR)
    Local aAreaCNU 	 := CNU->(GetArea())
    Local oModelCNU  := oModel:GetModel('CNUDETAIL')
	Local aCampos	:= aClone(oModelCNU:GetStruct():GetFields())
	Local aTemp		:= {}
	Local nX		:= 0
	Local lFound	:= .F.
	
	for nI := 1 to Len(aCampos)
		nX := CNU->(FieldPos(aCampos[nI,3]))
		If (nX > 0)
			aAdd(aTemp, {aCampos[nI,3], nX})
		EndIf
	next nI
    FwFreeArray(aCampos)
	aCampos := aTemp	

    BeginSQL Alias cAliasCNU
        SELECT CNU.CNU_CODVD,
               CNU.R_E_C_N_O_ AS RECNO
        FROM %Table:CNU% CNU
        WHERE CNU.%NotDel% AND 
              CNU.CNU_FILIAL = %Exp:cFilCNU% AND 
              CNU.CNU_CONTRA = %Exp:cContra%
    EndSQL
    
    While !(cAliasCNU)->(Eof())
        For nI := 1 to oModelCNU:Length()
            oModelCNU:GoLine(nI)
            If oModelCNU:IsDeleted() .And. (cAliasCNU)->CNU_CODVD == oModelCNU:GetValue('CNU_CODVD')
                nDeletado ++
            ElseIf (cAliasCNU)->CNU_CODVD == oModelCNU:GetValue('CNU_CODVD')
                nEncontrou ++
            EndIf
        Next nI

        If nDeletado > 0 .Or. nEncontrou == 0 //Deleta vendedor caso tenha sido deletado ou não exista no grid
            CNU->(MsGoTo((cAliasCNU)->RECNO))
            RecLock('CNU',.F.)
            CNU->(dbDelete())
            CNU->(MsUnlock())
        EndIf
        nDeletado := 0
        nEncontrou := 0
        (cAliasCNU)->(dbSkip())
    EndDo

    CNU->(dbSetOrder(1))
    For nI := 1 to oModelCNU:Length()
        oModelCNU:GoLine(nI)
		If !oModelCNU:IsDeleted()
			lFound := CNU->(dbSeek(cFilCNU + cContra + oModelCNU:GetValue('CNU_CODVD')))
			If !lFound .Or. (lFound .And. oModelCNU:IsUpdated())			
				RecLock('CNU', !lFound)				
				
				for nX := 1 to Len(aCampos)
					If (aCampos[nX,1] == "CNU_FILIAL")
						CNU->CNU_FILIAL := cFilCNU
					ElseIf(aCampos[nX,1] == "CNU_CONTRA")
						CNU->CNU_CONTRA := cContra
					Else
						CNU->(FieldPut(aCampos[nX,2], oModelCNU:GetValue(aCampos[nX,1])))
					EndIf
				next nX

				CNU->(MsUnlock())				
			EndIf			
		EndIf
    Next nI

    (cAliasCNU)->(dbCloseArea())
    RestArea(aAreaCNU)
	FwFreeArray(aAreaCNU)
	FwFreeArray(aCampos)
Return

/*/{Protheus.doc} LibCpTdRV
	Libera os campos para todas as revisões
@author philipe.pompeu
@since 08/01/2020
@return Nil, nulo
@param oStruCN9, objeto, estrutura do modelo CN9
/*/
Static Function LibCpTdRV(oModel)
	Local oStruCN9 	:= oModel:GetModel('CN9MASTER'):GetStruct()
	Local lAlterRev	:= oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. !Empty(A300GTpRev()) .And. !IsInCallStack('GCPXGerCt')
	
	oStruCN9:SetProperty("CN9_JUSTIF",MODEL_FIELD_WHEN,{||.T.})
	oStruCN9:SetProperty("CN9_TIPREV",MODEL_FIELD_WHEN,{||!lAlterRev})
	oStruCN9:SetProperty("CN9_AUTO"	 ,MODEL_FIELD_WHEN,{||.T.})
Return Nil

/*/{Protheus.doc} HasCrgFin
	Retorna verdadeiro caso <cContra> tenha cronograma financeiro em alguma das planilhas.
É necessário conferir as duas revisões(atual e anterior), pois é possível excluir planilhas entre uma revisão e outra.
@author philipe.pompeu
@since 19/11/2020
@return lResult, lógico
/*/
Static Function HasCrgFin(cFilCtr as Char, cContra as Char, cRev as Char, cRevAnt as Char) as Logical
	Local lResult	:= .F.
	Local cMyAlias	:= GetNextAlias()
	Local cCrgVazio := Space(Len(CNA->CNA_CRONOG))
	Local cCNAFil 	:= xFilial("CNA", cFilCtr)

	BeginSql Alias cMyAlias
		SELECT COUNT(CNA_NUMERO) TOTAL
		FROM %table:CNA%
		WHERE 
		CNA_FILIAL = %exp:cCNAFil%
		AND CNA_CONTRA = %exp:cContra%
		AND CNA_REVISA IN (%exp:cRev%, %exp:cRevAnt%)
		AND CNA_CRONOG <> %exp:cCrgVazio%
		AND %notdel%
	EndSql

	If (cMyAlias)->(!Eof())
		lResult := ((cMyAlias)->TOTAL > 0)
	EndIf
	(cMyAlias)->(dbCloseArea())
Return lResult

/*/{Protheus.doc} EstMedRev
	Estorna a medição da revisão posicionada.
@author juan.felipe
@since 19/11/2020
@return lRet, logical, retorna .T. caso a medição seja estornada com sucesso.
/*/
Static Function EstMedRev() as Logical
    Local aCab		    := {}
    Local lRet          := .T.
    Private lMsErroAuto := .F.

    If IsNewMed(CND->CND_CONTRA, CND->CND_REVISA, CND->CND_NUMMED) //-- Verifica se a medição foi gerada pela rotina CNTA121
        lRet := CN121Estorn(.T.,.T.) //-- Executa o estorno da medição.
    Else							
        aAdd(aCab,{"CND_CONTRA",CND->CND_CONTRA,NIL})
        aAdd(aCab,{"CND_REVISA",CND->CND_REVISA,NIL})
        aAdd(aCab,{"CND_COMPET",CND->CND_COMPET,NIL})
        aAdd(aCab,{"CND_NUMERO",CND->CND_NUMERO,NIL})
        aAdd(aCab,{"CND_NUMMED",CND->CND_NUMMED,NIL})

        MSExecAuto({|x,y|CNTA120(x,y,7,.F.)},aCab,{}) //-- Chama o ExecAuto para Estornar		
        lRet := !lMsErroAuto

        If !IsBlind() .And. !lRet									
            MostraErro()
        EndIf
        
		FwFreeArray(aCab)
    EndIf

Return lRet

/*/{Protheus.doc} ValPresFin
	Retorna se deve realizar o calculo do valor presente ou nao com base no dicionario de dados.
@author philipe.pompeu
@since 09/12/2020
@return lResult, lógico, se deve realizar o calculo do valor presente
/*/
Static Function ValPresFin(oCN9Master, nJuros) as Logical
	Local lResult := .F.
	Default oCN9Master 	:= Nil
	Default nJuros		:= 0

	If (_lVPresFIN == nil)
		_lVPresFIN := CNF->(ColumnPos('CNF_TJUROS') > 0  .And. ColumnPos('CNF_VLPRES') > 0 .And. ColumnPos('CNF_VJUROS') > 0)

		If _lVPresFIN
			_lVPresFIN := CN9->(ColumnPos('CN9_VJUROS') > 0  .And. ColumnPos('CN9_VLPRES') > 0 .And. ColumnPos('CN9_FRMVL') > 0)
		EndIf
	EndIf
	lResult := _lVPresFIN

	If lResult .And. oCN9Master <> Nil
		nJuros	:= oCN9Master:GetValue("CN9_TJUFIN")
		lResult	:= (nJuros > 0)	
	EndIf
Return lResult

/*/{Protheus.doc} ValPresCTB
	Retorna se deve realizar o calculo do valor presente p/ cronograma contabil(CNW)
@author philipe.pompeu
@since 21/12/2020
@return lResult, lógico, se deve realizar o calculo do valor presente
/*/
Static Function ValPresCTB(oCN9Master, nJuros) as Logical
	Local lResult := .F.
	Default oCN9Master 	:= Nil
	Default nJuros		:= 0

	If (_lVPresCTB == nil)
		_lVPresCTB := CNW->(ColumnPos('CNW_TJUROS') > 0 .And. ColumnPos('CNW_VLPRES') > 0 .And.;
							ColumnPos('CNW_VJUROS') > 0 .And. ColumnPos('CNW_MAXPAR') > 0)

		If _lVPresCTB
			_lVPresCTB := CNV->(ColumnPos('CNV_VLPRES') > 0 .And. ColumnPos('CNV_VJUROS') > 0)
		EndIf
	EndIf
	lResult := _lVPresCTB

	If lResult .And. oCN9Master <> Nil
		nJuros	:= oCN9Master:GetValue("CN9_TJUCTB")
		lResult	:= (nJuros > 0)	
	EndIf
Return lResult

/*/{Protheus.doc} UpdBCMed
	Atualiza base de conhecimento da medição corrente com base na revisão anterior.
@author philipe.pompeu
@since 18/06/2021
@return Nil, indefinido
/*/
Static Function UpdBCMed(cOldCodEnt, cCodEnt)
	Local cMyAlias	:= GetNextAlias()	
	Local cAC9Fil 	:= xFilial("AC9", IIF(Empty(CND->CND_FILMED), CND->CND_FILIAL,CND->CND_FILMED) )
	
	cOldCodEnt := PadR(cOldCodEnt, GetSX3Cache("AC9_CODENT", "X3_TAMANHO"))

	BeginSql Alias cMyAlias
		SELECT AC9.R_E_C_N_O_ RECAC9
		FROM %table:AC9% AC9
		WHERE 
			AC9.AC9_FILIAL = %exp:cAC9Fil%
		AND AC9.AC9_ENTIDA = 'CND'
		AND AC9.AC9_FILENT = %exp:CND->CND_FILIAL%
		AND AC9.AC9_CODENT = %exp:cOldCodEnt%
		AND AC9.%notdel%		
	EndSql
	
	While (cMyAlias)->(!Eof())

		AC9->(DbGoTo((cMyAlias)->RECAC9))
		RecLock("AC9",.F.)
		AC9->AC9_CODENT := cCodEnt//Atualiza o identificador
		AC9->(MsUnlock())

		(cMyAlias)->(DbSkip())
	EndDo
	
	(cMyAlias)->(dbCloseArea())
Return Nil

/*/{Protheus.doc} GCTOpenMdl
	Realiza a abertura de todos os <aSubModels> de <oModel>. Estando aSubModels vazio, libera todos os submodelos.
@author philipe.pompeu
@since 31/03/2022
@return Nil, indefinido
@param oModel, objeto, instância de MPFormModel
@param aSubModels, vetor, lista com os id's dos submodelos à serem liberados
/*/
Static function GCTOpenMdl(oModel as Object, aSubModels as Array)

	If Empty(aSubModels)
		aSubModels := {}
		aEval(oModel:GetAllSubModels(), {|x| aAdd(aSubModels, x:CID) })
	EndIf
	
	MtBCMod(oModel, aSubModels, {||.T.})
Return
