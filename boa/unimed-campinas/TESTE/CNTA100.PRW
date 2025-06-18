#INCLUDE "CNTA100.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "GCTXDEF.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE FLD_BAIXA "BAIXA"//Campo de baixa da retencao
#DEFINE FLD_SALDO "SALDO"//Campo de saldo da retencao
#DEFINE FLD_PLANI "PLANI"//Campo de planilha da retencao

STATIC lCn100BxRet := Iif(Existblock("CN100BxRet"),.T.,.F.)

Static __cSitACtr := "" /*Situacao anterior do contrato(usada na msg EAI CNTAI300)*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100VldPer³ Autor ³ Marcelo Custodio      ³ Data ³26.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida a vigencia contra os periodos dos cronogramas e      ³±±
±±³          ³ planilhas cadastrados para o contrato                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100VldPer()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100VldPer()
Local lRet := .T.
Local lVldVige := GetNewPar("MV_CNFVIGE","N") == "N"
Local oModelCN9
Local oModel 	  := FwModelActive()
Local lMdlAtivo := ValType(oModel) == 'O' .And. oModel:lActivate .And. oModel:GetId() == 'CNTA300'
Local dTermino
Local cNum
Local cRev

If lMdlAtivo
	oModelCN9	:= oModel:GetModel("CN9MASTER")
	dTermino 	:= CN100DtFim(oModelCN9:GetValue("CN9_UNVIGE"),oModelCN9:GetValue("CN9_DTINIC"),oModelCN9:GetValue("CN9_VIGE"),.F.)
	cNum		:= oModelCN9:GetValue("CN9_NUMERO")
	cRev		:= oModelCN9:GetValue("CN9_REVISA")
Else
	dTermino 	:= CN100DtFim(M->CN9_UNVIGE,M->CN9_DTINIC,M->CN9_VIGE)
	cNum		:= M->CN9_NUMERO
	cRev		:= M->CN9_REVISA
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida periodo contra os cronogramas               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVldVige
	dbSelectArea("CNF")
	dbSetOrder(2)
	dbSeek(xFilial("CNF")+cNum+cRev)
	While CNF->CNF_FILIAL == xFilial("CNF") .And. CNF->CNF_CONTRA == cNum .And. CNF->CNF_REVISA == cRev
		If CNF->CNF_PRUMED > dTermino
			lRet := .F.
			Help(" ",1,"CNTA100VIG") //"Vigencia invalida para os cronogramas ja inclusos"
			Exit
		EndIf
		dbSkip()
	EndDo
EndIf
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MSO021    | Autor ³ Deosdete P. da Silva          ³ Data ³04.08.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gerar documento para aprovacao com alcada na tabela SCR             ³±±
±±³          ³                                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CNTA100                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpcAlc = 1 - Incluir 5 - Alterar                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100Alc(cRevisa, cGrpApr)

Local cCodUsu	:= __cUserID
Local cTipoDoc 	:= "CT"							// Indica que o documento é do tipo contrato
Local cDoc		:= CN9->CN9_NUMERO + cRevisa  	// Documento composto de numero do contrato + revisao

Local nTxMoeda 	:= recMoeda(dDataBase,CN9->CN9_MOEDA) // Taxa da moeda

Local lRet	   	:= .F.
Local aCampos 	:= {}

Default cRevisa := ""
Default cGrpApr := ""

aAdd(aCampos, {cDoc,cTipoDoc, CN9->CN9_VLINI,"", cCodUsu, cGrpApr,	"",	CN9->CN9_MOEDA, nTxMoeda,dDataBase,""})
lRet := !GCTAlcEnt(,MODEL_OPERATION_UPDATE,1,cTipoDoc,cDoc, cRevisa,aCampos)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100VlDAss ³ Autor ³ Marcelo Custodio      ³ Data ³13.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida data de assinatura                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100VlDAss()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100VlDAss(dDataAssi,dDataInic)
Local lRet       := .T.
Local lValidAss  := GetNewPar("MV_CNVLASS","S") == "S"

DEFAULT dDataAssi:= M->CN9_DTASSI
DEFAULT dDataInic:= M->CN9_DTINIC

If lValidAss
	If !Empty(dDataInic)
		lRet := (dDataAssi >= dDataInic)
	EndIf

	If !lRet
		Help(" ",1,"CNTA100ASS") //"Data de assinatura deve ser maior que a data de inicio"
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100DtFim  ³ Autor ³ Marcelo Custodio      ³ Data ³13.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Calcula data final de acordo com a vigencia escolhida        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ dExp01 := CN100DtFim(cExp02,dExp03,cExp04)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ dExp01 - Data calculada                                      ³±±
±±³          ³ cExp04 - Tipo de Vigencia                                    ³±±
±±³          ³          "1" - Dias                                          ³±±
±±³          ³          "2" - Meses                                         ³±±
±±³          ³          "3" - Anos                                          ³±±
±±³          ³ cExp02 - Data calculada                                      ³±±
±±³          ³ dExp03 - Vigencia                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100DtFim(cTipV,dDtIni,nVig,lExec)
Local nX			:= 0
Local nDiaIni		:= 1
Local dDtOri		:= dDtIni
Local dDtUsr		:= dDtIni
Local dDataAssi	    := CToD("")
Local oModel		:= FWModelActive()
Local oView		    := FWViewActive()
Local lMVC			:= oModel <> Nil
Local lRefresh      := .F.
Local aSaveLines	:= FWSaveRows()
Local lDtAssi		:= SuperGetMv("MV_GCTDTTR",.F.,.F.) // Calcula a data de término da vigência tendo como início a data de assinatura.
Local lGCTDTAN		:= SuperGetMv("MV_GCTDTAN",.F.,.F.)
Local lOrigemGCP
Local lUpdateCNA

Default lExec := .T.

//Tratativa feita para quando vier da Ata pegar a data de publicação da Ata
If !(IsInCallStack('GCP320Grv'))
	dDataAssi	:= CN9->CN9_DTASSI
Else
	dDataAssi := dDtIni
EndIf

If lMVC
    If !Empty(oModel:GetModel("CN9MASTER"):GetValue("CN9_ASSINA"))
		dDataAssi := oModel:GetModel("CN9MASTER"):GetValue("CN9_ASSINA")
    Else
	    dDataAssi := dDtIni
    EndIf
EndIf

//Considera a data da assinatura e não da abertura do contrato.
If lDtAssi .And. !Empty(dDataAssi)
	dDtIni := dDataAssi
EndIf

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
			//segundo a legislação de contrato o primeiro dia não conta na vigencia sendo assim o dia de inicio é o mesmo dia do fim no mes final
		Case cTipV == "4"  //Indeterminada
			dDtIni := CTOD("31/12/49")//Retorna data limite do sistema
	EndCase
EndIf

//Parametro MV_GCTDTAN criado para Dataprev para considerar um dia antes do final do contrato
If lGCTDTAN
	dDtIni := dDtIni-1
EndIf

If ExistBlock("CN100ALTDF")
	dDtIni := If( ValType (dDtUsr := ExecBlock("CN100ALTDF",.F.,.F., {dDtIni,cTipV,nVig} ) ) == "D",dDtUsr, dDtIni)
EndIf

If lExec
	//Tratativa para quando chamar um valid para mudar a sitação pra vigente não gerar error.log
	If IsInCallStack('CNTA300xEdt') .And. lMVC
		CNTA300BlMd(oModel:GetModel("CNADETAIL"),,.T.)
	EndIf

	//-- Ajusta datas nas planilhas
	If lMVC .And. oModel:GetID() == "CNTA300" .And. oModel:GetModel("CNADETAIL"):CanUpdateLine() .And. oModel:GetOperation() <> 5
		lOrigemGCP  := IsInCallStack('a200gerdoc')
		lUpdateCNA:= (oModel:GetModel("CNADETAIL"):CanUpdateLine())
        lRefresh := .T.

		If lGCTDTAN .And. dDtIni < FwFldGet("CN9_DTINIC")
			dDtIni := FwFldGet("CN9_DTINIC")
		EndIf

		If lOrigemGCP .And. !lUpdateCNA
	 		oModel:GetModel("CNADETAIL"):SetNoUpdateLine(.F.)
		EndIf

		For nX := 1 To oModel:GetModel("CNADETAIL"):Length()
			oModel:GetModel("CNADETAIL"):GoLine(nX)
			If Empty(oModel:GetModel("CNADETAIL"):GetValue("CNA_DTINI"))
				oModel:GetModel("CNADETAIL"):LoadValue("CNA_DTINI",dDtOri)			
			ElseIf ( !(oModel:GetModel("CNADETAIL"):GetValue("CNA_DTINI") >= dDtOri) .Or.; //Dt Inicio da planilha maior ou igual ao inicio do contrato
			     !(oModel:GetModel("CNADETAIL"):GetValue("CNA_DTINI") < dDtIni)) // Dt inicio da planilha tem que ser menor a data final do contrato
				oModel:GetModel("CNADETAIL"):LoadValue("CNA_DTINI",dDtOri)		
			EndIf

			If Empty(oModel:GetModel("CNADETAIL"):GetValue("CNA_DTFIM"))
				oModel:GetModel("CNADETAIL"):LoadValue("CNA_DTFIM",dDtIni)
			ElseIf ( !(oModel:GetModel("CNADETAIL"):GetValue("CNA_DTFIM") > dDtOri) .Or.;//data fim da planilha maior que data inicio do contrato
				 !(oModel:GetModel("CNADETAIL"):GetValue("CNA_DTFIM") <= dDtIni)) // data fim menor ou igual a data fim do contrato
				oModel:GetModel("CNADETAIL"):LoadValue("CNA_DTFIM", dDtIni )
			EndIf
			 If lDtAssi .And. oModel:GetModel("CN9MASTER"):GetValue("CN9_ASSINA") >= dDtOri
				oModel:GetModel("CNADETAIL"):LoadValue("CNA_DTFIM",dDtIni)
			 EndIf
			If lOrigemGCP .And. Empty(oModel:GetModel("CNADETAIL"):GetValue("CNA_DTFIM"))
				oModel:GetModel("CNADETAIL"):SetValue("CNA_DTFIM",FwFldGet("CN9_DTFIM"))
			EndIf
		Next nX

		If lUpdateCNA != oModel:GetModel("CNADETAIL"):CanUpdateLine()
		   oModel:GetModel("CNADETAIL"):SetNoUpdateLine(!lUpdateCNA)
		EndIf
	EndIf
EndIf

FWRestRows(aSaveLines)

If lRefresh .And. ValType(oView) == "O" .And. oView:IsActive() .And. oView:oModel:GetId() $ 'CNTA300|CNTA301'
    oView:Refresh("VIEW_CNA")
EndIf

Return dDtIni

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100SitCh³ Autor ³ Marcelo Custodio      ³ Data ³18.01.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Altera situacao do contrato, executando todas as validacoes³±±
±±³          ³ necessarias                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100SitCh(cExp01,cExp02,cExp03)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Numero do contrato                                ³±±
±±³          ³ cExp02 - Revisao do contrato                               ³±±
±±³          ³ cExp03 - Nova situacao do contrato                         ³±±
±±³          ³          1 - Cancelado                                     ³±±
±±³          ³          2 - Em elaboracao                                 ³±±
±±³          ³          3 - Emitido                                       ³±±
±±³          ³          4 - Em aprovacao                                  ³±±
±±³          ³          5 - Vigente                                       ³±±
±±³          ³          6 - Paralisado                                    ³±±
±±³          ³          7 - Sol Paralisacao                               ³±±
±±³          ³          8 - Finalizado                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100SitCh(cContra,cRevisa,cNewSituc,cGrpAprov,lAviso, cFilCtr)
Local aAreas	:= {CN9->(GetArea()), CNA->(GetArea()), CNB->(GetArea()), CNF->(GetArea()), GetArea()}
Local aAreaCtr	:= CN9->(GetArea())

Local lMedeve		:= .F.
Local lCaucao		:= .F.
Local lContab		:= .F.
Local lFisico		:= .F.
Local lValor		:= .F.
Local lRecorrente	:= .F.
Local lServico		:= .F.
Local lCN100VDA 	:= .F.
Local lRet      	:= .T.
Local lGeraTit		:= .F.
Local lDeletaPco 	:= .F.
Local lAlcadas      := .F.
Local lEstorna		:= .F.
Local lTemAlc		:= .F.
Local lEventual		:= .F.
Local lPCOINTE		:= SuperGetMV("MV_PCOINTE",.F.,"2") == "1"
Local lGeraTitPR	:= SuperGetMV("MV_CNPROVI",.F.,"S") == "S" //Se for necessário gerar titulo provisório, precisa validar o MV_DATAFIN
Local nPCauc	:= 0
Local nMotPlan  := 0//Montante das planilhas
Local nMotCron  := 0//Montante dos cronogramas
Local nMotCrCt  := 0//Montante dos cronogramas contabeis
Local nMotCauc  := 0//Montante das caucoes

Local cOldSituac:= CN9->CN9_SITUAC
Local cFilCod	:= ""
Local cQuery    := ""
Local cAliasQry := ""
Local cLctoVige := "694"//Inclusão de Contrato
Local cLctoCanc := "696"//Exclusão de Contrato
Local cLpItemPla:= "69L"//Inclusão de Contrato Vigente(por item de planilha)
Local cLpItemCan:= "69M"//Estorno de Contrato Vigente(por item de planilha)
Local cCNBTMP	:= GetNextAlias()
Local cCN8TMP	:= GetNextAlias()
Local cCNDTMP	:= GetNextAlias()

Local dOldDtulst:= CN9->CN9_DTULST
Local dOldDtAssi:= CN9->CN9_DTASSI
Local dDataAssi := dDataBase
Local dDataBloq	:= GetNewPar("MV_ATFBLQM",CTOD("")) //Data de Bloqueio da Movimentação - MV_ATFBLQM

Local oModel	:= Nil
Local uRet      := Nil
Local bTemp		:= Nil

Default cGrpAprov := ""
Default lAviso	:= .T.
Default cFilCtr	:= cFilAnt

//Informa variacao do contrato fixo/variavel
Private lFixo   := .T.

If IsBlind() //-- Valida usuário quando for ExecAuto
	lRet := CN240VldUsr(cContra, DEF_TRASIT,.T.) //-- Valida apenas quando a função CN240SVld for setada como .T.
EndIf

If lRet
    lAviso := (lAviso .And. !IsBlind())//So exibir mensagem quando existir tela

    If(CN9->( CN9_FILCTR + CN9_NUMERO + CN9_REVISA  != cFilCtr + cContra + cRevisa))//Garante o posicionamento inicial no contrato correto.
		CN9->(dbSetOrder(1))
		
		If(lRet := CN9->(dbSeek( xFilial("CN9", cFilCtr) + cContra + cRevisa )))		
			dOldDtulst:= CN9->CN9_DTULST
			dOldDtAssi:= CN9->CN9_DTASSI
			cOldSituac:= CN9->CN9_SITUAC
			aAreaCtr := CN9->(GetArea()) //Guarda para poder restaurar e previnir sua alteracao pelos P.E e outras funcoes
		EndIf	
    EndIf

    If(lRet)	
		//Se vier de Contratos e o envio EAI estiver ativo
		If( (Alltrim(FunName()) == 'CNTA300') .And. FWHasEAI('CNTA300', .T.))
			//Guardo a situacao anterior do Contrato p/ utilizar na montagem da mensagem
			__cSitACtr := cOldSituac
		EndIf
	
		//Verifica se há controle de alcada
		lAlcadas := Cn300RetSt("ALCCTDOC",0,,CN9->CN9_NUMERO,CN9->CN9_FILCTR,.T.) .Or.; //Se for alçada p/ Documento
					Cn300RetSt("ALCCTEC" ,0,,CN9->CN9_NUMERO,CN9->CN9_FILCTR,.T.) 		//Se for alçada p/ Entidade Contabil
	
		//Ponto de entrada que  permite customizar a validação da assinatura do contrato.
		If ExistBlock("CN100VDA")
			lCN100VDA := ExecBlock("CN100VDA",.F.,.F.)
			If valtype(lCN100VDA) == "L"
				lRet := lCN100VDA
			EndIf
		Else
			If cNewSituc  == DEF_SVIGE .Or. cNewSituc  == DEF_SAPRO				
			    dDataAssi := If(!Empty(CN9->CN9_DTASSI),CN9->CN9_DTASSI,dDataAssi) //Verifica se a data da assinatura já foi preenchida.
				lRet      := CN100VlDAss(dDataAssi,CN9->CN9_DTINIC)//Valida data de assinatura
			EndIf
		EndIf
		
		//Ponto de entrada para validacao da troca de situacao
		If ExistBlock("CN100VST")
			uRet := ExecBlock("CN100VST",.F.,.F.,{cNewSituc,cContra,cRevisa})
			If valtype(uRet) == "L"
				lRet := uRet
			EndIf
		EndIf
    EndIf

	If lRet
		RestArea(aAreaCtr)//Garante o posicionamento no contrato correto.
		dbSelectArea("CN9")
		
		DO CASE
			CASE cNewSituc  = DEF_SEMIT			
				//-- Inclui data de assinatura
				RecLock("CN9",.F.)
					CN9->CN9_SITUAC := cNewSituc
					CN9->CN9_DTULST := dDataBase
				CN9->(MsUnlock())
	 			If lAviso
				   Aviso("CNTA100",OemtoAnsi(STR0029),{"Ok"})// "Situacao alterada com sucesso"
			    EndIf
			    		    
			CASE (cNewSituc  = DEF_SAPRO .And. !lAlcadas)//Atualiza situacao para "Em Aprovacao" em contratos que nao possuem controle de aprovacao por alcada
				
				RecLock("CN9",.F.)
				CN9->CN9_SITUAC := cNewSituc
				CN9->CN9_DTASSI := dDataAssi//Inclui data de assinatura
				CN9->CN9_DTULST := dDataBase
				MsUnlock()
				
				If lAviso
					Aviso("CNTA100",OemtoAnsi(STR0029), {"OK"}) //"Situacao alterada com sucesso"
				EndIf
			CASE cNewSituc == DEF_SVIGE  ;  //Atualiza situacao para Vigente
		    .Or. ( cNewSituc == DEF_SAPRO .And. lAlcadas ) //Atualiza para "Em Aprovacao" e executa demais validacoes para contratos que possuem controle de aprovacao por alcada
				
				If lRet := CtbValiDt(Nil, dDataBase,/*.F.*/ ,Nil ,Nil ,{"GCT001"}/*,"Data de apuração bloqueada pelo calendário contábil."*/)
					If !Empty(dDataBloq) .AND. ( dDataBase <= dDataBloq)
						Help(" ",1,"ATFCTBBLQ") //P: Processo bloqueado pelo Calendário Contábil ou parâmetro de bloqueio nesta data ou período. S: Caso possível altere a data de referência do processo, verifique o parâmetro ou contate o responsável pelo Módulo Contábil.)
						lRet := .F.
					EndIf
				EndIf
	
				//-- Verifica situação atual do contrato
				If lRet .And. AllTrim(CN9->CN9_SITUAC) == DEF_SELAB .Or. AllTrim(CN9->CN9_SITUAC) == DEF_SEMIT .Or. AllTrim(CN9->CN9_SITUAC) == DEF_SAPRO
					dbSelectArea("CNA")
					CNA->(dbSetOrder(1))
					CNA->(MsSeek(xFilial("CNA")+CN9->(CN9_NUMERO+CN9_REVISA)))
					While !CNA->(EOF()) .AND. CNA->(CNA_FILIAL+CNA_CONTRA+CNA_REVISA) == CN9->(CN9_FILIAL+CN9_NUMERO+CN9_REVISA)
						nMotPlan  := 0
				    	nMotCron  := 0
	
						lMedeve		:= Cn300RetSt("MEDEVE"		,0,CNA->CNA_NUMERO,,,.F.)	//-- Medicao Eventual
						lValor		:= Cn300RetSt("PREVFINANC"	,0,CNA->CNA_NUMERO,,,.F.)	//-- Previsao Financeira
						lSemiFix	:= Cn300RetSt("SEMIFIXO"	,0,CNA->CNA_NUMERO,,,.F.)	//-- SemiFixo
						lFisico		:= Cn300RetSt("FISICO"		,0,CNA->CNA_NUMERO,,,.F.)	//-- Cronograma fisico
						lContab		:= Cn300RetSt("CONTABIL"	,0,CNA->CNA_NUMERO,,,.F.)	//-- Contabil
						lRecorrente	:= Cn300RetSt("RECORRENTE"	,0,CNA->CNA_NUMERO,,,.F.)	//-- Recorrente
						lServico	:= Cn300RetSt("SERVIÇO"		,0,CNA->CNA_NUMERO,,,.F.)	//-- Serviço
						lFixo := Cn300RetSt("FIXO",0,CNA->CNA_NUMERO,,,.F.)
	
						lGeraTit 	:= lGeraTit .Or. !lMedeve
						
						If lFixo
							If !lMedeve .And. !lRecorrente .And. (lFisico .Or. lContab .Or. lServico) .And. Empty(CNA->CNA_CRONOG)
								Help(" ",1,"CNTA100PLA") //- "O contrato possui planilhas devem pertencer a um cronograma."
								lRet := .F.
								Exit															
							Else
								nMotPlan := CNA->CNA_VLTOT	//- Montante da planilha
							EndIf							
						ElseIf(CN9->(!Empty(CN9_NUMCOT) .Or. !Empty(CN9_CODED)))//Se nao for fixo e for oriundo de cotacao ou edital								
							lRet := CNVldPlFixa(CNA->CNA_TIPPLA)//exibe mensagem de erro e nao permite alterar a situacao do contrato
						EndIf	
						
						If lRet .And. !lMedeve//-- Verifica cronogramas se nao for medicao eventual
							If !lRecorrente
								dbSelectArea("CNF")
								CNF->(dbSetOrder(2))
								If CNF->(MsSeek(xFilial("CNF")+CNA->(CNA_CONTRA+CNA_REVISA+CNA_CRONOG)))									
									If lRet := CNVlDatFin(dDataAssi, lGeraTitPR)//Valida data de assinatura
										While !CNF->(EOF()) .AND. CNF->(CNF_FILIAL+CNF_CONTRA+CNF_REVISA+CNF_NUMERO) == CNA->(CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_CRONOG)
											
											If !(lRet := CNVlDatFin(CNF->CNF_DTVENC, lGeraTitPR))//Valida a data de vencimento
												Exit
											EndIf
											//Soma montante dos cronogramas
											nMotCron+=CNF->CNF_VLPREV
											CNF->(dbSkip())
										EndDo
										//-- Arredonda valores totais de cronograma e planilha
										nMotCron := Round(nMotCron,TamSX3("CNF_VLPREV")[2])
										nMotPlan := Round(nMotPlan,TamSX3("CNA_VLTOT")[2])										
									EndIf
								EndIf							
							
								If lRet .And. !(lRet := (nMotPlan == nMotCron))//-- Verifica montante dos cronogramas contra montante das planilhas
									Help(" ",1,"CNTA100MON") //"O contrato possui planilhas com montante não equivalente ao montante dos cronogramas."									
								EndIf
								
								If lRet .And. lFisico
									cAliasQry := GetNextAlias()
									cQuery := "SELECT CNS.CNS_CONTRA,CNS.CNS_REVISA,CNS.CNS_PLANI,CNS.CNS_ITEM,SUM(CNS.CNS_PRVQTD) AS CNS_PRVQTD "
									cQuery += "  FROM "+ RetSQLName("CNS") +" CNS "
									cQuery += " WHERE CNS.CNS_FILIAL = '"+xFilial("CNS")+"'"
									cQuery += " AND CNS.CNS_CONTRA = '"+CNA->CNA_NUMERO+"'"
									cQuery += " AND CNS.CNS_REVISA = '"+CNA->CNA_REVISA+"'"
									cQuery += " AND CNS.CNS_CRONOG = '"+CNA->CNA_CRONOG+"'"
									cQuery += "   AND CNS.D_E_L_E_T_ = ' ' "
									cQuery += " GROUP BY CNS.CNS_CONTRA,CNS.CNS_REVISA,CNS.CNS_PLANI,CNS.CNS_ITEM"
	
									cQuery := ChangeQuery( cQuery )
									dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cAliasQry, .T., .T. )
	
									TCSetField( cAliasQry, "CNS_PRVQTD", "N", TamSX3("CNS_PRVQTD")[1], TamSX3("CNS_PRVQTD")[2] )
	
									dbSelectArea("CNB")
									CNB->(dbSetOrder(1))
	
									cFilCod := xFilial("CNB")
									While !(cAliasQry)->(Eof())
										If dbSeek(cFilCod+(cAliasQry)->CNS_CONTRA+(cAliasQry)->CNS_REVISA+(cAliasQry)->CNS_PLANI+(cAliasQry)->CNS_ITEM)
											If CNB->CNB_QUANT != (cAliasQry)->CNS_PRVQTD
												lRet := .F.
												Aviso(STR0088,STR0143+(cAliasQry)->CNS_ITEM+STR0144+(cAliasQry)->CNS_PLANI+STR0145,{"OK"},2)//"Atencao"##"O item "####" da planilha "##" possui saldo em aberto para distribuição no cronograma físico."
												Exit
											EndIf
										EndIf
										(cAliasQry)->(dbSkip())
									EndDo
								EndIf								
							EndIf
						EndIf
						//- Verifica valor inicial do contrato se ele for do tipo flexivel e possuir previsao financeira  ³
						If lRet .And. lMedeve .And. !lFixo .And. lValor .And. CNA->CNA_VLTOT <= 0
							Aviso(STR0088,STR0146,{"OK"})//"Atencao !"."Existem planilhas no contrato que não permitem vigência com valor inicial zerado!"
							lRet := .F.
						EndIf
	
						//- Verifica configuracao contabil das planilhas
						If lRet .And. lContab
							If Empty(CNA->CNA_CRONCT)
								Aviso("CNTA100",OemtoAnsi(STR0135)+CNA->CNA_NUMERO+OemtoAnsi(STR0136),{"Ok"})//"A planilha "###" não possui cronograma contábil"
								lRet := .F.
							Else
								//- Verifica montante das planilhas com o montante dos cronogramas contabeis
								cQuery := "SELECT SUM(CNW_VLPREV) as CNW_VLPREV "
								cQuery += " FROM "+ RetSQLName("CNW")+" CNW,"+ RetSQLName("CNV")+" CNV,"
								cQuery += " WHERE CNW.CNW_FILIAL = '"+xFilial("CNW")+"'"
								cQuery += " AND CNV.CNV_FILIAL = '"+xFilial("CNV")+"'"
								cQuery += " AND CNW.CNW_CONTRA = '"+CNA->CNA_CONTRA+"'"
								cQuery += " AND CNW.CNW_REVISA = '"+CNA->CNA_REVISA+"'"
								cQuery += " AND CNV.CNV_CONTRA   = '"+CNA->CNA_CONTRA+"'"
								cQuery += " AND CNV.CNV_REVISA   = '"+CNA->CNA_REVISA+"'"
								cQuery += " AND CNV.CNV_PLANIL   = '"+CNA->CNA_NUMERO+"'"
								cQuery += " AND CNW.CNW_CONTRA = CNV.CNV_CONTRA "
								cQuery += " AND CNW.CNW_REVISA = CNV.CNV_REVISA "
								cQuery += " AND CNW.CNW_NUMERO = CNV.CNV_NUMERO "
								cQuery += " AND CNW.D_E_L_E_T_ = ' ' "
								cQuery += " AND CNV.D_E_L_E_T_ = ' ' "
	
								cAliasQry := GetNextAlias()
								cQuery := ChangeQuery(cQuery)
								dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	
	          		      	    nMotCrCt := (cAliasQry)->CNW_VLPREV
	                			(cAliasQry)->(dbCloseArea())
	
								//- Arredonda valores dos cronogramas contabeis
								nMotCrCt := Round(nMotCrCt,TamSX3("CNW_VLPREV")[2])
	
								//- Verifica montante dos cronogramas contra montante das planilhas
								If nMotPlan != nMotCrCt
									Aviso("CNTA100",OemtoAnsi(STR0147),{"Ok"})//"O montante das planilhas não equivale ao montante dos cronogramas contábeis. Verifique a configuração contábil do contrato!"
									lRet := .F.
								EndIf
							EndIf
						EndIf

						If !lRet
							Exit
						EndIf
						nMotCron:= 0
						nMotPlan:= 0
						CNA->(dbSkip())
					EndDo
				Else
					Help(" ",1,"CNTA100INV") //"Situacao atual invalida"
					lRet := .F.
				EndIf
	
				//-- Controla ou nao caucao
				lCaucao := (CN9->CN9_FLGCAU == "1" .And. CN9->CN9_TPCAUC == "1")
	
				//-- Verifica caucoes quando houver controle
				If lRet .And. lCaucao
					nPCauc := CN9->CN9_MINCAU//Percentual minimo de caucao
					dbSelectArea("CN8")
					CN8->(dbSetOrder(2))
					cFilCod := xFilial("CN8")
					CN8->(MsSeek(cFilCod+CN9->CN9_NUMERO+CN9->CN9_REVISA))
	
					While CN8->CN8_FILIAL = cFilCod .And. CN8->CN8_CONTRA = CN9->CN9_NUMERO .And. CN8->CN8_REVISA = CN9->CN9_REVISA
						//-- Soma montante das caucoes quando nao estiver baixada
						If Empty(CN8_DTBX)
							nMotCauc+=CN8->CN8_VLEFET
						EndIf
						CN8->(dbSkip())
					EndDo
	
					//-- Verifica percentual minimo de caucao
					If nMotCauc < NoRound((CN9->CN9_VLINI*nPCauc)/100,MsDecimais())
						Help(" ",1,"CNTA100MIN") //"O contrato nao possui o percentual minimo de caucao especificado"
						lRet := .F.
					EndIf
				EndIf
	
				//-- Gera Base Instalada e Ordem de Serviço
				If lRet .And. SuperGetMv("MV_CNINTFS",.F.,.F.) .And. CN1->CN1_ESPCTR == "2"
					lRet := CN100BIns(CN9->CN9_NUMERO,CN9->CN9_REVISA,CN9->CN9_DTASSI)
				EndIf
	
				//-- Executa alteracao quando todas as validacoes estiverem OK
				If lRet

					If lAlcadas .Or. !Empty(cGrpAprov)
						//-- Alcada - Gerar documento bloqueado com o tipo "CT" (Contratos) na tela de liberação de documentos (SCR)
						lTemAlc := CN100Alc(cRevisa,cGrpAprov)						
					Else
						lTemAlc := .F.
					EndIf
	
					//- Mudança de estado para "Em Aprovação"
					If cNewSituc == DEF_SAPRO .And. !lTemAlc
						RecLock("CN9",.F.)
						CN9->CN9_SITUAC := cNewSituc
						CN9->CN9_DTASSI := dDataAssi//Inclui data de assinatura
						CN9->CN9_DTULST := dDataBase
						CN9->(MsUnlock())
					   	If lAviso
							Aviso("CNTA100", STR0029,{"Ok"})// "Situacao alterada com sucesso"
						EndIf
	      			Else						
						CN100CtrVg(lTemAlc)
						
						If !lTemAlc //Se for alçada, só vai contabilizar ao aprovar e o contrato se tornar vigente							
							CN100Contab(cLctoVige)//Executa contabilizacao do contrato
							CN100ConIt(cLpItemPla)//Chama a contabilização por item da planilha
						EndIf
											
						If lAviso
						   Aviso("CNTA100", STR0029 + IIf(lTemAlc, CRLF + OemtoAnsi(STR0159)+".", ""), {"OK"}) //"Situacao alterada com sucesso" ## "Documento com controle de Alçada gerado. Aguardando aprovação do grupo "
					    EndIf
				    EndIf
				EndIf
		
				If lRet .And. lGeraTit .And. lGeraTitPR .And. CN9->CN9_SITUAC == DEF_SVIGE				
					bTemp := {||CN100CTit(cContra,cRevisa,,,,cFilCtr), CN100RecTi(cContra,cRevisa)}/*Gera titulos provisorios e titulos provisorios recorrentes*/				
					
					If !IsInCallStack('GCTEstApr')
						If(!IsBlind())
							FWMsgRun(, bTemp,, STR0058)//"Gerando titulos"
						Else
							Eval(bTemp)
						EndIf				
					EndIf
				EndIf
	
			CASE cNewSituc == DEF_SFINA
				If CN100VerNf(cContra,cRevisa, CN9->CN9_FILCTR)
					//-- Se veio direto do vigente, processa solicitacao de finalizacao para depois finalizar
					If CN9->CN9_SITUAC == DEF_SVIGE
						CN100SlFin() //-- Chama funcao que processa codigo relacionado a solicitacao de finalizacao
					EndIf
	
					RecLock("CN9",.F.)
						CN9->CN9_SITUAC := cNewSituc
						CN9->CN9_DTULST := dDataBase
						CN9->CN9_DTENCE := dDataBase
					CN9->(MsUnlock())
	
					bTemp := {||CN100ETit(cContra,cRevisa,/*cCronog*/,/*cParcel*/,cFilCtr)}
								
					If !IsBlind()					
						FWMsgRun(, bTemp,, STR0061)//"Estornando títulos"
						If lAviso
							Aviso("CNTA100",STR0029,{"Ok"})// "Situacao alterada com sucesso"
						EndIf
					Else
						Eval(bTemp)					
					EndIf
				Else
					lRet := .F.
				EndIf			
			CASE cNewSituc == DEF_SELAB				
				If (lRet := CNEXDatFin(cContra, cRevisa, CN9->CN9_FILCTR)) //Verifica se pode excluir títulos provisórios
					//-- Query para validar itens que geraram base instalada
		
					BeginSQL Alias cCNBTMP
					SELECT CNB_ITEM
					FROM %Table:CNB% CNB
					WHERE CNB.%NotDel% AND
						CNB.CNB_FILIAL = %xFilial:CNB% AND
						CNB.CNB_CONTRA = %Exp:cContra% AND
						CNB.CNB_REVISA = %Exp:cRevisa% AND
						CNB.CNB_GERBIN = '1'
					EndSQL
		
		
					//-- Query para validar baixas de cauções
					BeginSQL Alias cCN8TMP
					SELECT CN8_CONTRA
					FROM %Table:CN8% CN8
					WHERE CN8.%NotDel% AND
						CN8.CN8_FILIAL = %xFilial:CN8% AND
						CN8.CN8_CONTRA = %Exp:cContra% AND
						CN8.CN8_REVISA = %Exp:cRevisa% AND
						CN8.CN8_VLBX > 0
					EndSQL
		
					//-- Query para validar medições em outras filiais
		
					BeginSQL Alias cCNDTMP
					SELECT CND.CND_NUMMED
					FROM %Table:CND% CND
					WHERE CND.%NotDel% AND
						CND.CND_FILCTR = %Exp:CN9->CN9_FILCTR% AND
						CND.CND_CONTRA = %Exp:cContra% AND
						CND.CND_REVISA = %Exp:cRevisa%
					EndSQL
		
					CNB->(dbSetOrder(1)) //CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM
					CND->(dbSetOrder(2)) //CND_FILIAL+CND_CONTRA+CND_NUMERO
					CNX->(dbSetOrder(1)) //CNX_FILIAL+CNX_CONTRA+CNX_NUMERO
					COA->(dbSetOrder(2)) //COA_FILIAL+COA_CONTRA+COA_REVISA+COA_AVALIA
					
					If  Empty(cRevisa) .And.;	//-- Não revisado
							!COA->(dbSeek(xFilial("COA")+cContra+cRevisa)) .And.; //-- Sem avaliações de contrato				 	
							!CNX->(dbSeek(xFilial("CNX")+cContra)) .And.; //-- Sem adiantamentos de contrato						
							(cCN8TMP)->(EOF()) .And.; 									//-- Sem baixa de caução
							(cCNBTMP)->(EOF()) .And.;  //-- Sem base instalada
							(cCNDTMP)->(EOF())	//-- Sem medição em outras filiais
		
						//-- Altera situacao e datas do contrato
						RecLock("CN9",.F.)
						CN9->CN9_SITUAC := cNewSituc
						CN9->CN9_DTULST := dDataBase
						CN9->CN9_DTASSI := CTOD("  /  /  ")
						CN9->(MsUnlock())
		
						//-Trecho adicionado para realizar commit no modelo para envio das informações de mensagem unica.
						oModel := FWLoadModel(If(Cn300RetSt('COMPRA',,,,,.F.),"CNTA300","CNTA301"))
						oModel:SetOperation(MODEL_OPERATION_UPDATE)
						oModel:Activate()
						FwMsgRun(Nil,{||lRet := CnPimsChgS(oModel,FWFormCommit(oModel))},Nil,STR0199) //- "Aguarde, atualizando situação do contrato..." 
						oModel:DeActivate()
		
						If !lRet //- Falha de integração do contrato
							//- Restaura Situação original do contrato
							RecLock("CN9",.F.)
							CN9->CN9_SITUAC := cOldSituac
							CN9->CN9_DTULST := dOldDtulst
							CN9->CN9_DTASSI := dOldDtAssi
							CN9->(MsUnlock())
						Else							
							CN100Contab(cLctoCanc)//-- Contabiliza a desativacao do contrato
			
							//-- Limpa o campo Data Aniversario dos itens da Planilha do Contrato
							CNB->( dbSetOrder( 1 ) ) //CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM
							CNB->( dbSeek( FWxFilial("CNB") + cContra + cRevisa ) )
							While !CNB->(EOF()) .And. CNB->(CNB_FILIAL+CNB_CONTRA+CNB_REVISA) = xFilial("CNB")+cContra+cRevisa
								If !Empty(CNB->CNB_DTANIV)
									RecLock("CNB", .F.)
									CNB->CNB_DTANIV := CTOD("  /  /  ")
									CNB->(MsUnLock())
								EndIf
								//Chama a contabilização do estorno do contrato vigente
								If cOldSituac == DEF_SVIGE
									CN100Contab( cLpItemCan )
								EndIf
								
								CNB->(dbSkip())
							EndDo
			
							cFilCtr := CnFilCtr(cContra)
								
							//-- Verifica se existe registro na SCR para deletar
							If SCR->(MsSeek(cFilCtr+"CT"+cContra))
								MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_LIBAPRO,,},,3)
							EndIf
			
							If SCR->(MsSeek(cFilCtr+"IC"+cContra))
								While !SCR->(EOF()) .AND. SCR->(CR_FILIAL+CR_TIPO+Left(SCR->CR_NUM,TAMSX3('CN9_NUMERO')[1])) == cFilCtr+"IC"+cContra
									MaAlcDoc({SCR->CR_NUM,"IC",SCR->CR_TOTAL,SCR->CR_LIBAPRO,,},,3)
									SCR->(dbSkip())
								EndDo
							EndIf
			
							If SCR->(dbSeek(cFilCtr+"IR"+cContra))
								While !SCR->(EOF()) .AND. SCR->(CR_FILIAL+CR_TIPO+Left(SCR->CR_NUM,TAMSX3('CN9_NUMERO')[1]+TAMSX3('CN9_REVISA')[1])) == cFilCtr+"IR"+cContra+cRevisa
									MaAlcDoc({SCR->CR_NUM,"IR",SCR->CR_TOTAL,SCR->CR_LIBAPRO,,},,3)
									SCR->(dbSkip())
								EndDo
							EndIf
			
							//-- Estorna titulos relacionados ao contrato 
							lEventual := CN300RetSt("MEDEVE",1)
							If !lEventual .And. SuperGetMV("MV_CNPROVI",.F.,"S") == "S"
								If !IsInCallStack('GCTEstApr')
									MsAguarde({||CN100ETit(cContra,cRevisa)},STR0061)
								Else
									CN100ETit(cContra,cRevisa)
								EndIf
							EndIf
						EndIf
					Else
						Help(" ",1,"CNT100ESTORNA") //-- "Este Contrato já sofreu movimentação, por isso, sua situação não pode ser alterada."
						lRet := .F.
					EndIf
					//-- Fecha arquivos temporarios
					(cCNBTMP)->(dbCloseArea())
					(cCNDTMP)->(dbCloseArea())
					(cCN8TMP)->(dbCloseArea())
				EndIf	
			CASE cNewSituc == DEF_SCANC
				CN100Cance(lAviso,lAlcadas)
				
				If cOldSituac == DEF_SAPRO
					cFilCtr := CnFilCtr(cContra)
					//Verifica se já existe registro na SCR para deletar
	                If SCR->(MsSeek(cFilCtr+"CT"+cContra))
						MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_LIBAPRO,,},,3)
					EndIf
	
					If SCR->(MsSeek(cFilCtr+"IC"+cContra))
						While !SCR->(EOF()) .AND. SCR->(CR_FILIAL+CR_TIPO+Left(SCR->CR_NUM,TAMSX3('CN9_NUMERO')[1])) == cFilCtr+"IC"+cContra
							MaAlcDoc({SCR->CR_NUM,"IC",SCR->CR_TOTAL,SCR->CR_LIBAPRO,,},,3)
							SCR->(dbSkip())
						EndDo
					EndIf
				EndIf
	
			OTHERWISE
				RecLock("CN9",.F.)
					CN9->CN9_SITUAC := cNewSituc
					CN9->CN9_DTULST := dDataBase
				CN9->(MsUnlock())
	
				CN100SlFin() //-- Chama funcao que processa codigo relacionado a solicitacao de finalizacao
				If lAviso
					Aviso("CNTA100",OemtoAnsi(STR0029)+IIf(lEstorna, CRLF+OemtoAnsi(STR0176), ""), {"Ok"})// "Situacao alterada com sucesso" ## "Documento(s) para aprovação na rotina de Liberação foi(ram) estornado(s) automaticamente."
				EndIf			
		EndCase
	
		//Chamada do PCO na alteração da situação do contrato
		If lRet .And. CN9->CN9_SITUAC == cNewSituc .And. lPCOINTE .And. (CN9->CN9_SITUAC $ DEF_SVIGE + "|" + DEF_SPARA + "|" + DEF_SFINA + "|" + DEF_SCANC.OR. (CN9->CN9_SITUAC $ DEF_SELAB .And. cOldSituac $ DEF_SVIGE))
			oModel := FWLoadModel(If(Cn300RetSt('COMPRA'),"CNTA300","CNTA301"))
			oModel:SetOperation(MODEL_OPERATION_UPDATE)
	
			lDeletaPco := IIf(CN9->CN9_SITUAC $ DEF_SELAB .And. cOldSituac $ DEF_SVIGE,.T.,.F.)
	
			oModel:Activate()
			If !lDeletaPco
				A300PCOINT(oModel,"","",cContra,cRevisa,cNewSituc)
			Else
				A300PCOINT(oModel,"","",cContra,cRevisa,"05",lDeletaPco) //Exclui lançamento vigente pois situação alterada para elaboração
			EndIf
	
		EndIf

    EndIf
EndIf

aEval(aAreas, {|x|RestArea(x)})
FwFreeArray(aAreas)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100Hist  ³ Autor ³ Marcelo Custodio      ³ Data ³20.01.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Historico do contrato                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100Hist(cExp01)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Contrato                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100Hist(cContra)	
	Local aHeadCNG	:= {}
	Local aColsCNG	:= {}
	Local cSeek		:= xFilial("CNG")+cContra
	Local bWhile	:= {|| CNG->(CNG_FILIAL+CNG_CONTRA)}
	Local oModal	:= Nil
	Local oGet		:= Nil

	aHeadCNG := GdMontaHeader( 	NIL			,;	//01 -> Por Referencia contera o numero de campos em Uso
								NIL			,;	//02 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Virtuais
								NIL			,;	//03 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Visuais
								"CNG"		,;	//04 -> Opcional, Alias do Arquivo Para Montagem do aHeader
								{}			,;	//05 -> Opcional, Campos que nao Deverao constar no aHeader
								NIL			,;	//06 -> Opcional, Carregar Todos os Campos
								.T.			,;	//07 -> Nao Carrega os Campos Virtuais
								NIL			,;	//08 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
								NIL			,;	//09 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
								.T.			,;	//10 -> Verifica se Deve Checar se o campo eh usado
								.T. 		,;	//11 -> Verifica se Deve Checar o nivel do usuario
								NIL			,;	//12 -> Utiliza Numeracao na GhostCol
								.F.			 )	//13 -> Carrega os Campos de Usuario
	
	FillGetDados(1,'CNG',1,cSeek,bWhile,{||.T.}, , , , , ,.F.,aHeadCNG,aColsCNG, , ,)

	oModal  := FWDialogModal():New()
    oModal:SetEscClose(.T.)	
	oModal:SetTitle(FwSX2Util():GetX2Name("CNG"))
    oModal:SetSize(200, 350)//Seta a largura e altura da janela em pixel
 
    oModal:createDialog()
    oModal:addCloseButton(, STR0034)
	oModal:setCloseBlock({|| oModal:DeActivate() })

	oGet := MsNewGetDados():New(005,005,100,232,0,,,,,,,,,,oModal:getPanelMain(),aHeadCNG,aColsCNG)
	oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT		
	
	oModal:Activate()

	FwFreeArray(aHeadCNG)
	FwFreeArray(aColsCNG)
Return

/*/{Protheus.doc} CN100Situac
Função que executa a função ControlSit que realiza a mudança da situação do contrato.
@author juan.felipe
@since 02/07/2021
@param cAlias, character, alias do arquivo.
@param nReg, numeric, registro atual.
@param nOpc, numeric, opcao atual.
@param cSituacao, character, nova situação do contrato.
@param lAuto, logical, se é execução automática.
@cMsgErro, character, mensagem de erro gerada pela execução automatica.
@return Nil, nulo.
/*/
Function CN100Situac(cAlias,nReg,nOpc,cSituacao,lAuto,cMsgErro)
    Default cSituacao	:= "00"
    Default lAuto   	:= .F.
    
    Private lAutoErrNoFile := lAuto
    Private lMsHelpAuto    := lAuto
    Private lMsErroAuto    := .F.

    If lAuto
        MsExecAuto({|a,b,c,d,e| ControlSit(a,b,c,d,e)}, cAlias, nReg, nOpc, cSituacao, lAuto)
        If lMsErroAuto
            cMsgErro := PegaMsErro()
        EndIf
    Else
        ControlSit(cAlias,nReg,nOpc,cSituacao,lAuto)
    EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ControlSit Autor ³ Marcelo Custodio      ³ Data ³20.01.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Controle de situacoes do contrato                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ControlSit(cExp01,cExp02,nExp03)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Alias do arquivo                                   ³±±
±±³          ³ cExp02 - Registro atual                                     ³±±
±±³          ³ nExp03 - Opcao atual                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ControlSit(cAlias,nReg,nOpc,cSituacao,lAutomato)
Local cCadastro := OemToAnsi(STR0035) //"Controle de Situacoes"
Local cSitAtu
Local cSitOrg
Local cContra
Local cRevisa
Local cDocPend	:= ""   //Documentos pendentes
Local cGrpApr	:= ""	//Grupo aprovador - tera tratativa quando contrato possuir alcada
Local cFilBkp   := ""

Local aSituac   := RetSx3Box( Posicione("SX3", 2, "CN9_SITUAC", "X3CBox()" ),,, TamSX3("CN9_SITUAC")[1] )
Local aSitTx    := {}

Local dData	:= CTOD("  /  /  ")
Local oSituCb
Local oGet01,oGet02,oGet03
Local oModal	:= Nil
Local oContainer:= Nil

Local nOpcA
Local nPrazo

Local lEdital	:= !Empty(CN9->CN9_CODED) .And. CO1->(DbSeek( xFilial("CO1") + CN9->(CN9_CODED+CN9_NUMPR) ))
Local lRet		:= .T.
Local lFluig	:= SuperGetMV("MV_APWFECM",.F.,"1") == "1" .And. !Empty(AllTrim(GetNewPar("MV_ECMURL",""))) .And. FWWFFluig()
Local lSituAll	:= (GetNewPar( "MV_CNSITAL", "S" ) == "S") .And. !lFluig
Local lDocsOk	:= .T.  //Documentos ok/pronto
Local lCtrApr	:= .F.	//Controle de alcada
Local lIsServ   := .F.  //Verifica se foi gerado pelo Serviço
Local lIsGtp   	:= (FindFunction('A300IsGTP') .And. A300IsGTP())  //Verifica se foi gerado pelo SIGAGTP
Local lCont		:= .F.
Local lAviso	:= .T.
Local lMostraDoc:= SuperGetMv("MV_GCDOCPE", .F., "N") == "S" //Determina se pode ou não alterar a Situação de um Contrato sem documento anexado.
Local lAntCtrGS	:= FwIsInCallStack('AT870ANTCO')
Default cSituacao	:= "00"
DEFAULT lAutomato	:= .F.

If lAutomato
	cFilBkp := cFilAnt
	cFilAnt := CN9->CN9_FILCTR
EndIf

If A300IsServs() .And. !lAntCtrGS			
	Help(" ",1,"GSVALID300",,STR0200,2,0,,,,,,{STR0201}) //-- "Ação não permitida para contratos gerados através do Gestão de Serviços"#"Utilize a rotina de manutenção do assistente(TECA870)"
ElseIf(lIsGtp)
	Help(" ",1,"GTPVLDA300",,STR0216,2,0,,,,,,{STR0217})//Ação não permitida para contratos gerados através do Gestão de Trasporte de Passageiros | Utilize a rotina de orçamento de contratos(GTPA900)
Else
	dData := CN300DtFim(CN9->CN9_UNVIGE,CN9->CN9_DTINIC,CN9->CN9_VIGE)

	aadd(aSituac,{"A=Rev. Alcada","A","Rev. Alcada"})
	aadd(aSituac,{"11=Rejeitado","11","Rejeitado"})

	If lRet .And. CN240VldUsr(CN9->CN9_NUMERO,DEF_TRASIT,.T.)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verificar se o contrato e do tipo que contem        ³
		//³controle de documentos                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄDeoÄÄÄÄÙ
		DbSelectArea("CN1") //Tipo de Contrato
		DbSetOrder(1) //CN1_FILIAL+CN1_CODIGO
		If DbSeek(xFilial("CN1")+CN9->CN9_TPCTO)

			//Controla alcada na mudanca de situacao do contrato
			If !Empty(CN9->CN9_APROV)
				lCtrApr := .T.
				cGrpApr := CN9->CN9_APROV
			EndIf

			If CN1->CN1_CTRDOC == '1'  //Controla documentos

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verificar tipos de documentos realacionados³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("CNJ") //Doc x Situacao
				DbSetOrder(1) //CNJ_FILIAL+CNJ_SITUAC+CNJ_TPCTO+CNJ_TPDOC
				If CNJ->(DbSeek(xFilial("CNJ")+CN9->CN9_SITUAC+CN1->CN1_CODIGO)) .Or. CNJ->(DbSeek(xFilial("CNJ")+Space(TamSx3("CNJ_SITUAC")[1])+Space(TamSx3("CNJ_TPCTO")[1]))) //Verifica se existe algum CNJ_TPCTO em branco para considerar.

					While !CNJ->(Eof()) .AND. CNJ->CNJ_FILIAL+CNJ->CNJ_TPCTO == xFilial("CNJ")+CN1->CN1_CODIGO .AND. CNJ->CNJ_SITUAC == CN9->CN9_SITUAC

						DbSelectArea("CNK")// Documentos entregues
						DbSetOrder(3) //CNK_FILIAL+CNK_CONTRA+CNK_TPDOC

						If CNK->(MsSeek(xFilial("CNK")+CN9->CN9_NUMERO+CNJ->CNJ_TPDOC))
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Tratativa para o mesmo documento fornecido mais de uma vez ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							Do While CNK->(!Eof()) .AND. AllTrim(CNK->(CNK_FILIAL+CNK_CONTRA+CNK_TPDOC)) == AllTrim(xFilial("CNK")+CN9->CN9_NUMERO+CNJ->CNJ_TPDOC)

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Verificar validade do documento encontrado³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If CNK_DTVALI < dDataBase
									cDocPend += CNJ->CNJ_TPDOC + " - " + AllTrim(CNJ->CNJ_DESCTD) + " (" + STR0173 + ") (Seq. " + CNK->CNK_CODIGO + ")" + Chr(13)+Chr(10)	//VENCIDO
									lDocsOk  := .F.
								EndIf
								CNK->(DbSkip())
							EndDo

						Else
							cDocPend += CNJ->CNJ_TPDOC + " - " + AllTrim(CNJ->CNJ_DESCTD) + Chr(13)+Chr(10)
							lDocsOk  := .F.
						EndIf

						CNJ->(DbSkip())

					EndDo

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Mostrar documentos pendentes³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !lDocsOk
						IF !IsBlind() .And. lMostraDoc
							lDocsOk := MsgYesNo(STR0191,STR0067) // "Não foi encontrado nenhum documento para o contrato. Deseja alterar a situação mesmo assim?"
						ELSE
							Help(" ",1,"CNNODOC",,STR0188 + Chr(13)+Chr(10) +cDocPend +STR0189,1,0)  
						ENDIF
					EndIf
				Else					
					CNJ->(dbSetOrder(2))
					lDocsOk := CNJ->(dbSeek(xFilial("CNJ")+CN1->CN1_CODIGO))/*Verifica se existe amarração para qualquer etapa para este tipo de contrato */
					If !lDocsOk //Se nao tem documento relacionado
						IF !IsBlind() .And. lMostraDoc
							lDocsOk := MsgYesNo(STR0191,STR0067) // "Não foi encontrado nenhum documento para o contrato. Deseja alterar a situação mesmo assim?"
						ELSE
							Help(" ",1,"CNNOCNJ",,STR0187 +CN1->CN1_CODIGO + ".",1,0)							
						ENDIF
					EndIf

				EndIf
			EndIf
		EndIf

		If lDocsOk

			dbSelectArea("SX3")
			dbSetOrder(2)

			//Situacao atual
			cSitOrg := CN9->CN9_SITUAC

			If lAntCtrGS
			    cSitAtu := nOpc
			Else
			    cSitAtu := AllTrim(aSituac[Ascan(aSituac,{|aBox|substr(aBox[1],1,At("=",aBox[1])-1)=AllTrim(cSitOrg)})][3])
			EndIf	

			dbSelectArea("CN9")

			dbGoto(nReg)

			cContra := CN9->CN9_NUMERO
			cRevisa := CN9->CN9_REVISA

			If CtrRevisa( CN9->CN9_FILIAL, CN9->CN9_NUMERO, CN9->CN9_REVISA )

				lIsServ := A300IsServs()				

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Disponibliza as situacoes de acordo    ³
				//³ com a atual                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Do Case
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ De: Elaboracao                         ³
					//³ Para: Emitido, Aprovacao, Vigente      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Case AllTrim(CN9->CN9_SITUAC) == DEF_SELAB 
						aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SEMIT})][1])
						aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SAPRO})][1])
						aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SVIGE})][1])
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ De: Emitido                                        ³
					//³ Para: Elaboracao, Aprovacao, Vigente, Cancelado    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Case AllTrim(CN9->CN9_SITUAC) == DEF_SEMIT
						aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SELAB})][1])
						aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SAPRO})][1])
						aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SVIGE})][1])
						If	!( lIsServ .Or. lIsGtp)
							// Se o contrato não foi gerado pelo Gestão de Serviços, então o mesmo pode ser cancelado pelo Gestão de Contratos.
							// Caso contrário, ele deverá ser cancelado pelo Gestão de Serviços.
							aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SCANC})][1])
						EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ De: Aprovacao                          ³
					//³ Para: Elaboracao, Vigente, Cancelado   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Case AllTrim(CN9->CN9_SITUAC) == DEF_SAPRO
						aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SELAB})][1])
						If !((SCR->(MsSeek(xFilial("CN9")+"CT"+CN9->CN9_NUMERO)) .Or. SCR->(MsSeek(xFilial("CN9")+"IC"+CN9->CN9_NUMERO))) .OR. ;
							((MtGLastDBM("CT",CN9->CN9_NUMERO) .Or. MtGLastDBM("IC",CN9->CN9_NUMERO)) .And. !Empty(CN9->CN9_APROV)))

							aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SVIGE})][1])
						EndIf
						If	!( lIsServ .Or. lIsGtp)
							// Se o contrato não foi gerado pelo Gestão de Serviços, então o mesmo pode ser cancelado pelo Gestão de Contratos.
							// Caso contrário, ele deverá ser cancelado pelo Gestão de Serviços.
							aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SCANC})][1])
						EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ De: Vigente                            ³
					//³ Para: Sol. Finalizacao, Cancelado      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Case AllTrim(CN9->CN9_SITUAC) == DEF_SVIGE
						aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SELAB})][1])
						If	!( lIsServ .Or. lIsGtp)
							// Se o contrato não foi gerado pelo Gestão de Serviços...
							// Então o mesmo pode ser finalizado pelo Gestão de Contratos. Caso contrário, ele deverá ser finalizado pelo Gestão de Serviços.
							// Então o mesmo pode ser cancelado pelo Gestão de Contratos. Caso contrário, ele deverá ser cancelado pelo Gestão de Serviços.

							//-- Parametro que define se finaliza direto do vigente ou se passa por solicitacao de finalizacao
							If SuperGetMV("MV_CNVGFIN",.F.,.F.)
								aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SFINA})][1])
							Else
								aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SSPAR})][1])
							EndIf
							aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SCANC})][1])

						EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ De: Sol Finalizacao                    ³
					//³ Para: Finalizado, Cancelado            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Case AllTrim(CN9->CN9_SITUAC) == DEF_SSPAR
						If	!( lIsServ .Or. lIsGtp)
							// Se o contrato não foi gerado pelo Gestão de Serviços, então o mesmo pode ser finalizado pelo Gestão de Contratos.
							// Caso contrário, ele deverá ser finalizado pelo Gestão de Serviços.
							aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SFINA})][1])
							// Se o contrato não foi gerado pelo Gestão de Serviços, então o mesmo pode ser cancelado pelo Gestão de Contratos.
							// Caso contrário, ele deverá ser cancelado pelo Gestão de Serviços.
							aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SCANC})][1])
						EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ De: 	Rejeitado                       ³
					//³ Para: 	Elaboração, Cancelado           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Case AllTrim(CN9->CN9_SITUAC) == DEF_SREJE
						aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SELAB})][1])
						aAdd(aSitTx, aSituac[aScan(aSituac,{|x| AllTrim(x[2]) == DEF_SCANC})][1])

				EndCase

				If lAutomato .And. Alltrim(FunName()) <> 'TECA870'
					oSituCb := cSituacao
					nOpca := 1
					lCont := .T.
				ElseIf Len(aSitTx) > 0 .and. Alltrim(FunName()) <> 'TECA870' .and. !lAutomato
					lCont := .T.
				Else
					If	lIsServ
						If	Alltrim(FunName()) == 'TECA870'
							lCont := .T.
						Else
							MsgAlert(	OemToAnsi(STR0194)+CRLF+;	//"Este contrato foi gerado pelo módulo de Gestão de Serviços."
										OemToAnsi(STR0195)+CRLF+;	//"E não são possíveis mudanças na sua situação através do módulo de Gestão de Contratos na fase em que ele se encontra."
										OemToAnsi(STR0196),;			//"Caso seja necessário, faça a mudança de sua situação através do módulo de Gestão de Serviços."
										OemToAnsi(STR0088) )			//"Atenção!"
						EndIf
					ElseIf lIsGtp
						If	!(lCont := (Alltrim(FunName()) == 'GTPA900'))						
							MsgAlert(	STR0216 + CRLF+;	//Ação não permitida para contratos gerados através do Gestão de Trasporte de Passageiros
										STR0218 + CRLF+;	//Não são possíveis mudanças na sua situação através do módulo de Gestão de Contratos na fase em que ele se encontra.
										STR0219, STR0088 )	//Caso seja necessário, faça a mudança de sua situação através do módulo de Gestão de Trasporte de Passageiros. //Atenção!										
						EndIf       
                    Else
						MsgAlert(	OemToAnsi(STR0197), OemToAnsi(STR0088) ) //"Não foi possível identificar a possibilidade de mudança de situação do contrato. Por favor, contate o administrador do sistema." # "Atenção!"
					EndIf

				EndIf

				If lCont .And. cSituacao == "00" .And. !lAntCtrGS
					oModal  := FWDialogModal():New()
					oModal:SetEscClose(.T.)
					oModal:setTitle(cCadastro)					
					oModal:SetSize(150, 200)//Seta a largura e altura da janela em pixel
					oModal:createDialog()
					oModal:addYesNoButton()
					oModal:setWhen({||len(aSitTx) > 0})					

					oContainer := TPanel():New( ,,, oModal:getPanelMain() )
					oContainer:Align := CONTROL_ALIGN_ALLCLIENT

					@ 007,005 Say STR0036 Of oContainer PIXEL	//"Contrato"
					@ 005,045 MsGet oGet01 Var cContra Picture PesqPict("CN9","CN9_NUMERO") When .F. PIXEL  Size 80,5 Of oContainer

					@ 022,005 Say STR0037 Of oContainer PIXEL	//"Revisão"
					@ 020,045 MsGet oGet02 Var cRevisa Picture PesqPict("CN9","CN9_REVISA") When .F. PIXEL  Size 10,5 Of oContainer

					@ 037,005 Say STR0038 Of oContainer PIXEL	//"Situacao Atual"
					@ 035,045 MsGet oGet03 Var cSitAtu When .F. Of oContainer PIXEL

					@ 052,005 Say STR0039 Of oContainer PIXEL	//"Nova Situacao"
					@ 050,045 MsComboBox oSituCb ITEMS aSitTx When (len(aSitTx) > 0) SIZE 80,5 OF oContainer PIXEL
					
					oModal:Activate()

					If (oModal:getButtonSelected() == 1)						
						nOpca := 1
					Else
						nOpca:= 2
						lCont:=.F.
					EndIf
					oModal:DeActivate()
				Else
					oSituCb := cSituacao
					nOpca:=1
				EndIf

				If lAntCtrGS 
					oSituCb := nOpc
				Endif

				If nOpca == 1 .And. lEdital .And.;
				!( oSituCb == DEF_SFINA .Or. oSituCb == DEF_SCANC .Or. oSituCb == DEF_SSPAR .Or.  oSituCb == DEF_SPARA )
				
					While !(CO1->(EoF())) .And. AllTrim(CO1->CO1_ARTIGO) <> "57"
						CO1->(DbSkip())
					EndDo
				
					Do Case
						Case AllTrim(CO1->CO1_ARTIGO) == "57" .And. AllTrim(CO1->CO1_PARAG) == "IV"
							nPrazo := GCPBissest(48,CN9->CN9_DTINIC)//Bloquear contratos que excedem 48 meses quando vem do edital
						Case AllTrim(CO1->CO1_ARTIGO) == "57" .And. CO1->CO1_PARAG == "V"
							nPrazo := GCPBissest(120,CN9->CN9_DTINIC)//Bloquear contratos que excedem 120 meses quando vem do edital
						OtherWise
							nPrazo := GCPBissest(60,CN9->CN9_DTINIC)//Bloquear contratos que excedem 60 meses quando vem do edital
					EndCase
				
					If ( (dData - CN9->CN9_DTINIC) > nPrazo .Or. CN9->CN9_UNVIGE == "4" ) //Bloquear contratos que excedem 60 meses quando vem do edital
						//Corrigir o Help abaixo na Versão 12.1.5 onde ele já estará correto no dicionário
						//Help('',1,'CNTA300STE') // Não foi possivel efetuar a troca de situação pois não é permitido contratos vigentes de prazo maior que determinado no edital vinculado.
						Help("",1,"","CNTA300STE",STR0193,1,0) //"Não foi possivel efetuar a troca de situação, pois não é permitido contratos vigentes de prazo maior que determinado no processo licitatório vinculado"
						lRet := .F.
					EndIf
				EndIf

				If !Empty(cSituacao)
					lAviso:= .F.
				EndIf
				
				If lCont
					
					lCont := CN100Doc(nReg,{oSituCb},.T.) //Valida amarracao de documentos x situacao
					
					If lCont
						lCont := CN100VerNf(cContra,cRevisa, CN9->CN9_FILCTR) //Verifica se existe medicao em aberto
					EndIf

					If lCont .And. (cSituacao # "00" .Or. (nOpca == 1 .And. IIF(lAntCtrGS, .T., Aviso("CNTA100",OemtoAnsi(STR0041),{STR0052,STR0053}) == 1)))//"Confirma a mudanca de situacao do contrato?"

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Rotina de alteracao da situacao do contrato³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If CN100SitCh(CN9->CN9_NUMERO,CN9->CN9_REVISA,oSituCb,cGrpApr,lAviso, CN9->CN9_FILCTR)

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Chama ponto de entrada para tratamento de inclusao  ³
							//³ de novas rotinas apos alterar a situacao do contrato³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If ExistBlock("CN100SIT")
								ExecBlock("CN100SIT",.f.,.f.,{cSitOrg,oSituCb})
							EndIf

							If (lSituAll .Or. oSituCb == DEF_SPARA .Or. oSituCb == DEF_SSPAR .Or. oSituCb == DEF_SFINA) .And. CN1->CN1_ESPCTR <> "2" .And. !lAutomato
								CN220Aval(cAlias,nReg,nOpc,,.F.,oSituCb)
							EndIf
						EndIf
					EndIf
				EndIf
			Else
				If !lAutomato
					MsgAlert( OemToAnsi(STR0038)+": "+OemToAnsi(STR0037)+CRLF+OemToAnsi(STR0175), OemToAnsi(STR0088) ) //"Atenção!"
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If lAutomato
	cFilAnt := cFilBkp
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CN100CTit ³ Autor ³Marcelo Custodio       ³ Data ³17/03/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera titulos provisorios a pagar com base no cronograma     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CN100CTit(cExp01,cExp02,cExp03,cExp04,nExp05)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp01 - Codigo do Contrato                                 ³±±
±±³          ³cExp02 - Codigo da revisao                                  ³±±
±±³          ³cExp03 - Numero do cronograma - opcional                    ³±±
±±³          ³cExp04 - Parcela do cronograma - opcional                   ³±±
±±³          ³nExp05 - Saldo restante - opcional                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100CTit(cContra,cRevisa,cCronog,cParcel,nSaldo,cFilCtr)

Local aStrucCNF:= CNF->(dbStruct())
Local aArea    := GetArea()
Local aVend    := {}
Local lTemVend := .F.
Local aCond    := {}

Local nValT    := 0
Local nx
Local ny

Local cPlan    := ""
Local cQuery   := ""
Local cMaxTit  := ""
Local cPrefixo
Local cNatTit
Local cEspCtr
Local cFilSE1  := xFilial("SE1")
Local cFilSE2  := xFilial("SE2")
Local cNomeReduz:=""
Local cNatCtr	:= ""

Local lPeSE2   := Existblock("CNTPRSE2")
Local lPeSE1   := Existblock("CNTPRSE1")
Local lCnProCP:= GetNewPar( "MV_CNPROCP", "N" ) == "S"
Local lMoeda	:= (GetNewPar( "MV_CNMOEDA", "S" ) == "S")
Local cUmAlias	:= GetNextAlias()
Local lRevMed	:= FwIsInCallStack("CN300REVPD")
Local dEmissao	:= CtoD("//")
Local nDecVlrTit:= 0
Default cCronog := ""
Default cParcel := ""
Default nSaldo  := -1
Default cFilCtr := cFilAnt

CN9->(dbSetOrder(1))
If CN9->(dbSeek(xFilial("CN9",cFilCtr) + cContra + cRevisa))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se Venda ou Compra                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cEspCtr := CN9->CN9_ESPCTR
	nDecVlrTit := IIF(cEspCtr == "1",GetSx3Cache("E2_VALOR","X3_DECIMAL"),GetSx3Cache("E1_VALOR","X3_DECIMAL"))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pesquisa a natureza do contrato            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(CN9->CN9_NATURE)
		cNatCtr := CN9->CN9_NATURE
	ElseIf cEspCtr == "1"
		cNatCtr := PadR(SuperGetMV("MV_CNNAT",.F.,""),Len(SE2->E2_NATUREZ))
	Else
		cNatCtr := PadR(SuperGetMV("MV_CNNATCL",.F.,""),Len(SE1->E1_NATUREZ))
	EndIf

	If cEspCtr == "1"
		cPrefixo := PadR( GetNewPar( "MV_CNPREF",  "" ), Len( SE2->E2_PREFIXO ) )
		dbSelectArea("SE2")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona sequencia dos titulos a pagar    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If UPPER(TcGetDb()) <> "POSTGRES"
			cQuery := "SELECT MAX(SE2.E2_NUM) as E2_NUM "
			cQuery += "  FROM "+ RetSQLName("SE2") +" SE2 "
			cQuery += " WHERE SE2.E2_FILIAL = '"+xFilial("SE2",cFilCtr)+"'"
			cQuery += "   AND SE2.E2_PREFIXO = '"+ cPrefixo +"'"
			cQuery += "   AND SE2.D_E_L_E_T_ = ' '"

			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SE2TMP",.F.,.T.)

			cMaxTit := Soma1(SE2TMP->E2_NUM)

			SE2TMP->(dbCloseArea())
		Else
			SE2->(dbSetOrder(1))
			SE2->(dbSeek(xFilial("SE2")+cPrefixo+"ZZZ",.T.))
			SE2->(dbSkip(-1))
			cMaxTit := Soma1(SE2->E2_NUM)
		EndIf
	Else
		cPrefixo := PadR( GetNewPar( "MV_CNPRECL",  "" ), Len( SE1->E1_PREFIXO ) )
		dbSelectArea("SE1")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona sequencia dos titulos a receber    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If UPPER(TcGetDb()) <> "POSTGRES"
			cQuery := "SELECT MAX(SE1.E1_NUM) as E1_NUM "
			cQuery += "  FROM "+ RetSQLName("SE1") +" SE1 "
			cQuery += " WHERE SE1.E1_FILIAL  = '"+xFilial("SE1",cFilCtr)+"'"
			cQuery += "   AND SE1.E1_PREFIXO = '"+ cPrefixo +"'"
			cQuery += "   AND SE1.D_E_L_E_T_ = ' '"

			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SE1TMP",.F.,.T.)

			cMaxTit := Soma1(SE1TMP->E1_NUM)

			SE1TMP->(dbCloseArea())
		Else
			SE1->(dbSetOrder(1))
			SE1->(dbSeek(xFilial("SE1")+cPrefixo+"ZZZ",.T.))
			SE1->(dbSkip(-1))
			cMaxTit := Soma1(SE1->E1_NUM)
		EndIf
		aVend	:= CtaVend(cContra,cFilCtr, cRevisa)
		lTemVend:= (Len(aVend) > 0)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona parcelas dos cronogramas         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT distinct CNF.*, CNA.CNA_NUMERO, CNA.CNA_FORNEC, CNA.CNA_LJFORN, CNA_VLTOT, CNA_CLIENT, CNA_LOJACL,CNA_NATURE "	
	cQuery += " FROM "+ RetSQLName("CNF") + " CNF"
	
	cQuery += " INNER JOIN "+ RetSQLName("CNA") +" CNA ON(" //Join com o cabecalho da planilha(CNA)	
	cQuery += " CNA.CNA_FILIAL = '"+ xFilial("CNA",cFilCtr) +"'"
	cQuery += " AND CNA.D_E_L_E_T_   = ' '"
	cQuery += " AND CNA.CNA_CRONOG = CNF.CNF_NUMERO "
	cQuery += " AND CNA.CNA_CONTRA = CNF.CNF_CONTRA "
	cQuery += " AND CNA.CNA_REVISA = CNF.CNF_REVISA)"
	
	cQuery += " WHERE CNF.CNF_FILIAL = '"+ xFilial("CNF",cFilCtr) +"'"
	cQuery += " AND CNF.CNF_CONTRA   = '"+ CN9->CN9_NUMERO +"'"
	cQuery += " AND CNF.CNF_REVISA   = '"+ CN9->CN9_REVISA +"'"
	cQuery += " AND CNF.D_E_L_E_T_   = ' '"	
	
	If !Empty(cCronog)	
		cQuery += " AND CNF.CNF_NUMERO    = '"+ cCronog +"'"
	EndIf
	If !Empty(cParcel)
		cQuery += " AND CNF.CNF_PARCEL    = '"+ cParcel +"'"
	EndIf
	
	If(FwIsInCallStack("A300Titulo"))
		//Quando a chamada ocorre pelo A300Titulo nao deve gerar os titulos de parcelas sem saldo
		cQuery += " AND CNF.CNF_SALDO > 0 "
	EndIf
	
	cQuery += " ORDER BY CNF.CNF_DTVENC"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cUmAlias,.F.,.T.)

	For nx:=1 to len(aStrucCNF)
		if (cUmAlias)->(FieldPos(aStrucCNF[nx,1])) > 0 .And. aStrucCNF[nx,2] <> "C"
			TCSetField( cUmAlias, aStrucCNF[nx,1], aStrucCNF[nx,2], aStrucCNF[nx,3], aStrucCNF[nx,4] )
		endif
	Next

	TCSetField( cUmAlias, "CNA_VLTOT", "N", TamSX3("CNA_VLTOT")[1], TamSX3("CNA_VLTOT")[2] )

	nSaldo := If(nSaldo == -1,(cUmAlias)->CNF_SALDO,nSaldo)
	If(lRevMed)
		nSaldo := (cUmAlias)->CNF_VLPREV
	EndIf

	SE2->(dbSetOrder(1))	
	SE1->(dbSetOrder(1))
	While (cUmAlias)->(!Eof())
		If cPlan != (cUmAlias)->CNA_NUMERO
			cPlan  := (cUmAlias)->CNA_NUMERO			
		EndIf

		If Round(nSaldo,nDecVlrTit) > 0
			If lMoeda
				nValT := nSaldo
			Else
				nValT := xMoeda(nSaldo,CN9->CN9_MOEDA,1,(cUmAlias)->CNF_PRUMED,,(cUmAlias)->CNF_TXMOED)
			EndIf
			aCond := {}
			If lCnProCP
				aCond := Condicao(nValT,CN9->CN9_CONDPG,,(cUmAlias)->CNF_DTVENC)
			Else
				aadd(aCond,{(cUmAlias)->CNF_DTVENC,nValT})
			EndIf

			cNatTit := IIF(Empty((cUmAlias)->CNA_NATURE), cNatCtr, (cUmAlias)->CNA_NATURE)

			If (cEspCtr =="1")//Gera titulo provisorio de compras				
				SA2->(dbSetOrder(1))
				SA2->(dbSeek(xFilial("SA2")+(cUmAlias)->CNA_FORNEC+(cUmAlias)->CNA_LJFORN))
				cNomeReduz := SA2->A2_NREDUZ //Caso SA2 seja desposicionada, garante a gravacao de <E2_NOMFOR> corretamente

				For ny := 1 to Len(aCond)

					While SE2->(dbSeek(cFilSE2+cPrefixo+cMaxTit))//Verifica proximo codigo disponivel
						cMaxTit := Soma1(cMaxTit)
					EndDo
					dEmissao := GetDtEmiPR(aCond[ny][1], CN9->CN9_DTASSI, CN9->CN9_DTREV)

					RecLock("SE2",.T.)
					SE2->E2_FILIAL	:= xFilial("SE2",cFilCtr)
					SE2->E2_PREFIXO	:= cPrefixo
					SE2->E2_NUM		:= cMaxTit
					SE2->E2_PARCELA	:= (cUmAlias)->CNF_PARCEL
					SE2->E2_TIPO	:= "PR"
					SE2->E2_FORNECE	:= (cUmAlias)->CNA_FORNEC
					SE2->E2_LOJA 	:= (cUmAlias)->CNA_LJFORN
					SE2->E2_NOMFOR	:= cNomeReduz
					SE2->E2_EMIS1	:= dEmissao
					SE2->E2_EMISSAO	:= dEmissao
					SE2->E2_VENCTO	:= aCond[ny][1]
					SE2->E2_VENCREA	:= DataValida(aCond[ny][1])
					SE2->E2_VENCORI	:= SE2->E2_VENCTO
					SE2->E2_VALOR	:= aCond[ny][2]

					If	lMoeda//Verifica se o titulo e gerado na moeda corrente ou na moeda informada no contrato  ³
						SE2->E2_TXMOEDA:= (cUmAlias)->CNF_TXMOED
						SE2->E2_MOEDA  := CN9->CN9_MOEDA
					Else
						SE2->E2_MOEDA  := 1
					EndIf
					SE2->E2_SALDO 	  := SE2->E2_VALOR
					SE2->E2_NATUREZ   := cNatTit
					SE2->E2_VLCRUZ    := xMoeda(aCond[ny][2],SE2->E2_MOEDA,1,dDataBase)
					SE2->E2_ORIGEM    := "CNTA100"
					SE2->E2_RATEIO    := "N"
					SE2->E2_FLUXO     := "S"
					SE2->E2_MDCONTR   := CN9->CN9_NUMERO
					SE2->E2_MDREVIS   := CN9->CN9_REVISA
					SE2->E2_MDPLANI   := (cUmAlias)->CNA_NUMERO
					SE2->E2_MDCRON    := (cUmAlias)->CNF_NUMERO
					SE2->E2_MDPARCE   := (cUmAlias)->CNF_PARCEL
					SE2->E2_FILORIG	  := cFilAnt

					If lPeSE2
						ExecBlock("CNTPRSE2",.F.,.F.)//Ponto de entrada criado para alteracoes especificas no preenchimento do titulo a pagar
					EndIf

					MsUnlock()					
				Next

			Else
				SA1->(dbSetOrder(1))
				SA1->(dbSeek(xFilial("SA1")+(cUmAlias)->(CNA_CLIENT+CNA_LOJACL)))
				cNomeReduz := SA1->A1_NREDUZ //Caso SA1 seja desposicionada, garante a gravacao de <E1_NOMCLI> corretamente
				For ny := 1 to Len(aCond)
					While SE1->(dbSeek(cFilSE1+cPrefixo+cMaxTit))//Verifica proximo codigo disponivel
						cMaxTit := Soma1(cMaxTit)
					EndDo
					dEmissao := GetDtEmiPR(aCond[ny][1], CN9->CN9_DTASSI, CN9->CN9_DTREV)

					RecLock("SE1",.T.)

					SE1->E1_FILIAL	:= xFilial("SE1",cFilCtr)
					SE1->E1_PREFIXO	:= cPrefixo
					SE1->E1_NUM		:= cMaxTit
					SE1->E1_PARCELA	:= (cUmAlias)->CNF_PARCEL
					SE1->E1_TIPO	:= "PR"
					SE1->E1_CLIENTE	:= (cUmAlias)->CNA_CLIENT
					SE1->E1_LOJA	:= (cUmAlias)->CNA_LOJACL
					SE1->E1_NOMCLI	:= cNomeReduz
					SE1->E1_EMIS1	:= dEmissao
					SE1->E1_EMISSAO	:= dEmissao
					SE1->E1_VENCTO	:= aCond[ny][1]
					SE1->E1_VENCREA	:= DataValida(aCond[ny][1])
					SE1->E1_VENCORI	:= SE1->E1_VENCTO
					SE1->E1_VALOR	:= aCond[ny][2]
					SE1->E1_SALDO	:= SE1->E1_VALOR

					If lMoeda//³ Verifica se o titulo e gerado na moeda corrente ou na moeda informada no contrato  ³
						SE1->E1_TXMOEDA:= (cUmAlias)->CNF_TXMOED
						SE1->E1_MOEDA  := CN9->CN9_MOEDA
					Else
						SE1->E1_MOEDA  := 1
					EndIf
					SE1->E1_NATUREZ   := cNatTit
					SE1->E1_VLCRUZ    := xMoeda(aCond[ny][2],SE1->E1_MOEDA,1,dDataBase)
					SE1->E1_ORIGEM    := "CNTA100"
					SE1->E1_FLUXO     := "S"
					SE1->E1_MDCONTR   := CN9->CN9_NUMERO
					SE1->E1_MDREVIS   := CN9->CN9_REVISA
					SE1->E1_MDPLANI   := (cUmAlias)->CNA_NUMERO
					SE1->E1_MDCRON    := (cUmAlias)->CNF_NUMERO
					SE1->E1_MDPARCE   := (cUmAlias)->CNF_PARCEL
					SE1->E1_FILORIG   := cFilAnt

					If lTemVend
						GrvVendTit(aVend)						
					EndIf
					
					If lPeSE1
						ExecBlock("CNTPRSE1",.F.,.F.)//Ponto de entrada criado para alteracoes especificas no preenchimento do titulo a receber
					EndIf

					MsUnlock()
	        	Next
			EndIf
			cMaxTit := Soma1(cMaxTit)
		EndIf
		(cUmAlias)->(dbSkip())		
		
		nSaldo := (cUmAlias)->( IIF(lRevMed, CNF_VLPREV, CNF_SALDO) )
	EndDo
	(cUmAlias)->(dbCloseArea())
EndIf

RestArea(aArea)
FwFreeArray(aArea)
FwFreeArray(aCond)
FwFreeArray(aStrucCNF)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CN100RECTI   ³ Autor ³Rogerio Melonio     ³ Data ³27/07/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Realiza inclusao dos titulos provisorios do                 ³±±
±±³          ³contrato para planilhas recorrentes                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CN100RECTI(cExp01,cExp02)			                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp01 - Codigo do Contrato                                 ³±±
±±³          ³cExp02 - Codigo da revisao                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100RecTi(cContra,cRevisa,cParcel,cPlanilha,lEstorno,cFilCtr)

Local aArea      := GetArea()
Local aCond      := {}
Local aAreaCNA   := CNA->(GetArea())
Local nValT      := 0
Local nX	     := 0
Local nY	     := 0

Local cPlan      := ""
Local cQuery     := ""
Local cMaxTit    := ""
Local cMaxParce  := ""
Local nParIni    := 1
Local dDataPriMed := Ctod("")

Local cPrefixo
Local cNatTit
Local cEspCtr
Local cFilSE1	 := xFilial("SE1")
Local cFilSE2  	 := xFilial("SE2")
Local aVend      := {}
Local cLctoVige  := "69J"
Local cGCTTPPP 	 := AllTrim(SuperGetMV("MV_GCTTPPP",.F.,"0"))

Local lPeSE2     := Existblock("CNTPRSE2")
Local lPeSE1     := Existblock("CNTPRSE1")
Local lCnProCP   := GetNewPar( "MV_CNPROCP", "N" ) == "S"
Local lMoeda     := GetNewPar( "MV_CNMOEDA", "S" ) == "S"
Local aParcelas  := {}
Local nRecorre   := 0
Local nRestante  := 0
Local lGctxGS	 := ((FwIsInCallStack("TECA850") .OR. FwIsInCallStack("At870AprRv") .OR. FwIsInCallStack("TitProvRec")) .AND. FindFunction("TecxbPrRec"))
Local lTemVend	 := .F.
Local cNomeReduz :=""
Local aStrucCNA	 := {}
Local cAliasCNA  := GetNextAlias()
Local cAliasTmp  := ""
Local nTamCpo	 := 0
Local lCompra	 := .F.
Local cNatCtr	:= ""
Default cParcel  := ""
Default cPlanilha:= ""
Default lEstorno := .F.
Default cFilCtr	 := cFilAnt

dbSelectArea("CN9")
CN9->(dbSetOrder(1))
If CN9->(dbSeek(xFilial("CN9",cFilCtr)+cContra+cRevisa))
	cEspCtr := CN9->CN9_ESPCTR //- Verifica se Venda ou Compra
	lCompra := (cEspCtr == "1")
	//-- Pesquisa a natureza do contrato
	If !Empty(CN9->CN9_NATURE)
		cNatCtr := CN9->CN9_NATURE
	Else
		nTamCpo := IIF(lCompra, Len(SE2->E2_NATUREZ), Len(SE1->E1_NATUREZ))
		cNatCtr := IIF(lCompra, "MV_CNNAT", "MV_CNNATCL")
		cNatCtr	:= SuperGetMV(cNatCtr, .F.,"")
		cNatCtr := PadR(cNatCtr, nTamCpo)		
	EndIf

	nTamCpo := IIF(lCompra, Len(SE2->E2_PREFIXO), Len(SE1->E1_PREFIXO))
	cPrefixo:= IIF(lCompra, "MV_CNPREF", "MV_CNPRECL")
	cPrefixo:= GetNewPar( cPrefixo,  "" )
	cPrefixo:= PadR(cPrefixo, nTamCpo)
	cMaxTit := ProxNumTit(cPrefixo, lCompra, cFilCtr) //-- Seleciona sequencia dos titulos
	If (!lCompra)
		aVend 	:= CtaVend(cContra, cFilCtr, cRevisa)
		lTemVend:= (Len(aVend) > 0)
	EndIf

	If (!Empty(cParcel))
		If lEstorno			
			cMaxParce := cParcel // se é estorno, está incluindo a parcela atual
		Else // se não é estorno, está incluindo mais uma parcela ao final das recorrencias
			cAliasTmp  := GetNextAlias()

			If lCompra
				nTamCpo := TAMSX3('E2_PARCELA')[1]

				cQuery := " SELECT E2_MDPARCE AS MDPARCE, ( SELECT COUNT(E2_MDPARCE) "
				cQuery += " FROM " + RetSQLName("SE2") +" SE2A "
				cQuery += " WHERE 	SE2A.E2_FILIAL  = '" + xFilial("SE2",cFilCtr) + "'"
				cQuery += " AND SE2A.E2_PREFIXO = '" + cPrefixo  +"'"
				cQuery += " AND SE2A.E2_MDCONTR = '" + cContra   +"'"
				cQuery += " AND SE2A.E2_MDREVIS = '" + cRevisa   +"'"
				cQuery += " AND SE2A.E2_MDPLANI = '" + cPlanilha +"'"
				cQuery += " AND SE2A.D_E_L_E_T_ = ' ' ) AS NRESTANTE "
				cQuery += " FROM " + RetSQLName("SE2") +" SE2 "
				cQuery += " WHERE SE2.E2_FILIAL  = '"+xFilial("SE2",cFilCtr)+"'"
				cQuery += " AND SE2.E2_PREFIXO = '"+ cPrefixo +"'"
				cQuery += " AND SE2.E2_MDCONTR = '"+ cContra +"'"
				cQuery += " AND SE2.E2_MDREVIS = '"+ cRevisa +"'"
				cQuery += " AND SE2.E2_MDPLANI = '"+ cPlanilha +"'"
				cQuery += " AND SE2.E2_NUM = ( SELECT MAX(E2_NUM) FROM " + RetSQLName("SE2") + " SE2B "
				cQuery += " WHERE SE2B.E2_FILIAL  = '"+xFilial("SE2",cFilCtr)+"'"
				cQuery += " AND SE2B.E2_PREFIXO = '" + cPrefixo +"'"
				cQuery += " AND SE2B.E2_MDCONTR = '" + cContra + "' "
				cQuery += " AND SE2B.E2_MDREVIS = '" + cRevisa + "' "
				cQuery += " AND SE2B.E2_MDPLANI = '" + cPlanilha + "' "
				cQuery += " AND SE2B.D_E_L_E_T_ = '' ) "
				cQuery += " AND SE2.D_E_L_E_T_ = ' '"				
			Else
				nTamCpo := TAMSX3('E1_PARCELA')[1]
				cQuery := " SELECT E1_MDPARCE AS MDPARCE, ( SELECT COUNT(E1_MDPARCE) "
				cQuery += " FROM " + RetSQLName("SE1") +" SE1A "
				cQuery += " WHERE SE1A.E1_FILIAL  = '" + xFilial("SE1",cFilCtr) + "'"
				cQuery += " AND SE1A.E1_PREFIXO = '" + cPrefixo  +"'"
				cQuery += " AND SE1A.E1_MDCONTR = '" + cContra   +"'"
				cQuery += " AND SE1A.E1_MDREVIS = '" + cRevisa   +"'"
				cQuery += " AND SE1A.E1_MDPLANI = '" + cPlanilha +"'"
				cQuery += " AND SE1A.D_E_L_E_T_ = ' ' ) AS NRESTANTE "

				cQuery += " FROM " + RetSQLName("SE1") +" SE1 "
				cQuery += " WHERE SE1.E1_FILIAL  = '"+xFilial("SE1",cFilCtr)+"'"
				cQuery += " AND SE1.E1_PREFIXO = '"+ cPrefixo +"'"
				cQuery += " AND SE1.E1_MDCONTR = '"+ cContra +"'"
				cQuery += " AND SE1.E1_MDREVIS = '"+ cRevisa +"'"
				cQuery += " AND SE1.E1_MDPLANI = '"+ cPlanilha +"'"
				cQuery += " AND SE1.E1_NUM = ( SELECT MAX(E1_NUM) FROM " + RetSQLName("SE1") + " SE1B "
				cQuery += " WHERE SE1B.E1_FILIAL  = '"+xFilial("SE1",cFilCtr)+"'"
				cQuery += " AND SE1B.E1_PREFIXO = '"+ cPrefixo +"'"
				cQuery += " AND SE1B.E1_MDCONTR = '" + cContra + "' "
				cQuery += " AND SE1B.E1_MDREVIS = '" + cRevisa + "' "
				cQuery += " AND SE1B.E1_MDPLANI = '" + cPlanilha + "' "
				cQuery += " AND SE1B.D_E_L_E_T_ = '' ) "
				cQuery += " AND SE1.D_E_L_E_T_ = ' '"				
			EndIf

			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),(cAliasTmp),.F.,.T.)
			
			If Len(AllTrim((cAliasTmp)->MDPARCE)) == 1 // verificação necessária caso tamanho do campo MDPARCE seja diferente do EX_PARCELA
				If AllTrim((cAliasTmp)->MDPARCE) == "Z"
					cMaxParce := "a"
				Else
					cMaxParce 	:= Soma1(Left((cAliasTmp)->MDPARCE,nTamCpo))
				Endif
			Else
				If !Empty((cAliasTmp)->MDPARCE)
					cMaxParce 	:= Soma1(Left((cAliasTmp)->MDPARCE,nTamCpo))
				Else
					cMaxParce	:= Soma1(cParcel)
				EndIf
			Endif
			nRestante := (cAliasTmp)->NRESTANTE

			(cAliasTmp)->(dbCloseArea())			
		Endif
	EndIf

	//Seleciona planilhas recorrentes do contrato	
	cQuery := " SELECT CNA_NUMERO, CNA_FORNEC, CNA_LJFORN, CNA_VLTOT, CNA_CLIENT, CNA_LOJACL, CNA_MEDEFE, "
	cQuery += " CNA_PERIOD, CNA_QTDREC, CNA_DIASEM, CNA_DIAMES,CNA_PROMED, CNA_ULTMED, CNA_DTINI, CNA_DTFIM, CNA_PERREC, CNA_PROPAR, CNA_RPGANT, R_E_C_N_O_ AS CNARECNO, CNA_NATURE"	
	cQuery += " FROM " +  RetSQLName("CNA") +" CNA "
	cQuery += " WHERE CNA.CNA_FILIAL = '"+ xFilial("CNA",cFilCtr) +"'"
	cQuery += " AND CNA.CNA_CONTRA = '" + cContra + "' "
	cQuery += " AND CNA.CNA_REVISA = '" + cRevisa + "' "
	cQuery += " AND CNA.CNA_PERIOD IN ('1','2','3','4') "
	cQuery += " AND CNA.CNA_PROMED <> '        ' "

	If !Empty(cPlanilha)
		cQuery += " AND CNA.CNA_NUMERO = '" + cPlanilha + "' "
	Endif

 	cQuery += " AND CNA.D_E_L_E_T_   = ' ' "
	cQuery += " ORDER BY CNA_NUMERO"
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),(cAliasCNA),.F.,.T.)

	aStrucCNA:= CNA->(dbStruct())

	for nX := 1 to Len(aStrucCNA)
		If (aStrucCNA[nX,2]  $ "D|L|N") .And. (cAliasCNA)->(FieldPos(aStrucCNA[nX,1]) > 0)		
			TCSetField(cAliasCNA, aStrucCNA[nX,1], aStrucCNA[nX,2], aStrucCNA[nX,3], aStrucCNA[nX,4])
		EndIf
	next nX
	FwFreeArray(aStrucCNA)

	SE2->(dbSetOrder(1))
	SE1->(dbSetOrder(1))
	While !(cAliasCNA)->(Eof())
		cCpoParcela := IIf( Empty((cAliasCNA)->CNA_FORNEC),"E1_PARCELA","E2_PARCELA" )
		cNatTit := IIF(Empty((cAliasCNA)->CNA_NATURE), cNatCtr, (cAliasCNA)->CNA_NATURE)

		If !lEstorno //-- se não é estorno de medição
			If Empty(cParcel)
				If FwIsInCallStack("CN100SITCH") .Or. FwIsInCallStack("CN100JOB") .Or. FwIsInCallStack("LIBERAALC")//-- se inclusão pela entrada em vigência
					aParcelas	:= CN100ParRc((cAliasCNA)->CNA_PERIOD,(cAliasCNA)->CNA_QTDREC,(cAliasCNA)->CNA_DIASEM,(cAliasCNA)->CNA_DIAMES,(cAliasCNA)->CNA_PROMED,(cAliasCNA)->CNA_DTINI,(cAliasCNA)->CNA_DTFIM,cCpoParcela,(cAliasCNA)->CNA_PERREC)
				ElseIf IsInCallStack("A300TITULO") // se inclusão pela aprovação de revisão
					If cGCTTPPP $ "0/2"
						aParcelas 	:= CN100ParRc((cAliasCNA)->CNA_PERIOD,(cAliasCNA)->CNA_QTDREC,(cAliasCNA)->CNA_DIASEM,(cAliasCNA)->CNA_DIAMES,(cAliasCNA)->CNA_PROMED,(cAliasCNA)->CNA_DTINI,(cAliasCNA)->CNA_DTFIM,cCpoParcela,(cAliasCNA)->CNA_PERREC,.T.,Tira1((cAliasCNA)->CNA_PROPAR))
					Else
						dDataPriMed := CN300RetMed((cAliasCNA)->CNA_PERIOD,(cAliasCNA)->CNA_DTINI,(cAliasCNA)->CNA_DIAMES,(cAliasCNA)->CNA_DIASEM,(cAliasCNA)->CNA_PERREC,.T.)
						aParcelas 	:= CN100ParRc((cAliasCNA)->CNA_PERIOD,(cAliasCNA)->CNA_QTDREC,(cAliasCNA)->CNA_DIASEM,(cAliasCNA)->CNA_DIAMES,dDataPriMed,(cAliasCNA)->CNA_DTINI,(cAliasCNA)->CNA_DTFIM,cCpoParcela,(cAliasCNA)->CNA_PERREC)
						nParIni 	:= (cAliasCNA)->CNA_MEDEFE + 1
					EndIf

				ElseIf IsInCallStack("CnDrPrTit") // se inclusão pelo roll back de revisão
					If cGCTTPPP $ "0/1"
						aParcelas 	:= CN100ParRc((cAliasCNA)->CNA_PERIOD,(cAliasCNA)->(CNA_QTDREC+CNA_MEDEFE),(cAliasCNA)->CNA_DIASEM,(cAliasCNA)->CNA_DIAMES,(cAliasCNA)->CNA_PROMED,(cAliasCNA)->CNA_DTINI,(cAliasCNA)->CNA_DTFIM,cCpoParcela,(cAliasCNA)->CNA_PERREC,.T.)
					Else
						dDataPriMed := CN300RetMed((cAliasCNA)->CNA_PERIOD, (cAliasCNA)->CNA_DTINI,  (cAliasCNA)->CNA_DIAMES, (cAliasCNA)->CNA_DIASEM, (cAliasCNA)->CNA_PERREC, .T.)
						aParcelas 	:= CN100ParRc ((cAliasCNA)->CNA_PERIOD, (cAliasCNA)->CNA_QTDREC, (cAliasCNA)->CNA_DIASEM, (cAliasCNA)->CNA_DIAMES, dDataPriMed, (cAliasCNA)->CNA_DTINI, (cAliasCNA)->CNA_DTFIM, cCpoParcela, (cAliasCNA)->CNA_PERREC)
					EndIf
					nParIni := (cAliasCNA)->CNA_MEDEFE + 1
				EndIf

			Else //-- se foi chamada pelo encerramento da medição
				If (cAliasCNA)->CNA_RPGANT $ " |2"
					dDataPriMed := CN300RetMed((cAliasCNA)->CNA_PERIOD, (cAliasCNA)->CNA_DTINI,  (cAliasCNA)->CNA_DIAMES, (cAliasCNA)->CNA_DIASEM, (cAliasCNA)->CNA_PERREC, .T.)
				Else
					dDataPriMed := DataValida((cAliasCNA)->CNA_DTINI)
				Endif
				aParcelas 	:= CN100ParRc((cAliasCNA)->CNA_PERIOD, (cAliasCNA)->(CNA_QTDREC+CNA_MEDEFE)	,(cAliasCNA)->CNA_DIASEM,(cAliasCNA)->CNA_DIAMES,dDataPriMed,(cAliasCNA)->CNA_DTINI,(cAliasCNA)->CNA_DTFIM,cCpoParcela,(cAliasCNA)->CNA_PERREC,.T.)
				nRecorre  	:= nRestante + (cAliasCNA)->CNA_MEDEFE + 1
				If nRecorre <= Len(aParcelas)
					aParcelas := { aParcelas[nRecorre] }
				Else
					(cAliasCNA)->(dbSkip())
					Loop
				EndIf
			EndIf
		Else //-- se é estorno de medição, reinclui a parcela atual da provisão
			If (cAliasCNA)->CNA_RPGANT $ " |2"
				dDataPriMed := CN300RetMed((cAliasCNA)->CNA_PERIOD, (cAliasCNA)->CNA_DTINI,  (cAliasCNA)->CNA_DIAMES, (cAliasCNA)->CNA_DIASEM, (cAliasCNA)->CNA_PERREC, .T.)
			Else
				dDataPriMed := DataValida((cAliasCNA)->CNA_DTINI)
			Endif
			aParcelas := CN100ParRc((cAliasCNA)->CNA_PERIOD,(cAliasCNA)->(CNA_QTDREC+CNA_MEDEFE)+1,(cAliasCNA)->CNA_DIASEM,(cAliasCNA)->CNA_DIAMES,dDataPriMed,(cAliasCNA)->CNA_DTINI,(cAliasCNA)->CNA_DTFIM,cCpoParcela,(cAliasCNA)->CNA_PERREC,.T.)
			nRecorre := aScan( aParcelas, { |x| Alltrim(x[1]) == AllTrim(cParcel) } )			
			If nRecorre > 0
				aParcelas := { aParcelas[nRecorre] }
			Else
				aParcelas := {}
			EndIf
		Endif

		For nX := nParIni To Len(aParcelas)
			If aParcelas[nX,2] > (cAliasCNA)->CNA_DTFIM
				Loop
			EndIf
			
			cPlan  := (cAliasCNA)->CNA_NUMERO

			If lMoeda
				nValT := (cAliasCNA)->CNA_VLTOT
			Else
				nValT := xMoeda((cAliasCNA)->CNA_VLTOT,CN9->CN9_MOEDA,1,aParcelas[nX][2],,1)
			EndIf
			
			If (lGctxGS)
				nValT := TecxbPrRec(nValT, nX, aParcelas, (cAliasCNA)->CNARECNO)
			EndIf

			aCond := {}
			If lCnProCP
				aCond := Condicao(nValT,CN9->CN9_CONDPG,,aParcelas[nX][2])
			Else
				aadd(aCond,{aParcelas[nX][2],nValT})
			EndIf

			If lCompra //³ Gera titulo provisorio de compras
				SA2->(dbSetOrder(1))				
				SA2->(dbSeek( xFilial("SA2")+(cAliasCNA)->(CNA_FORNEC+CNA_LJFORN) ) )
				cNomeReduz := SA2->A2_NREDUZ //Caso SA2 seja desposicionada, garante a gravacao de <E2_NOMFOR> corretamente
				For ny := 1 to Len(aCond)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica proximo codigo disponivel         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					While SE2->(dbSeek(cFilSE2+cPrefixo+cMaxTit))
						cMaxTit := Soma1(cMaxTit)
					EndDo

					RecLock("SE2",.T.)
					SE2->E2_FILIAL    := xFilial("SE2",cFilCtr)
					SE2->E2_PREFIXO   := cPrefixo
					SE2->E2_NUM       := cMaxTit
					SE2->E2_PARCELA   := aParcelas[nX][1]
					If nRecorre = 0
						SE2->E2_HIST	  := Padr( "RECORRENCIA " + StrZero(nX,3) , TamSx3("E2_HIST")[1] )
					Else
						SE2->E2_HIST	  := Padr( "RECORRENCIA " + StrZero(nRecorre,3) , TamSx3("E2_HIST")[1] )
					Endif
					SE2->E2_TIPO      := "PR"
					SE2->E2_FORNECE   := (cAliasCNA)->CNA_FORNEC
					SE2->E2_LOJA      := (cAliasCNA)->CNA_LJFORN
					SE2->E2_NOMFOR    := cNomeReduz
					SE2->E2_EMIS1     := Iif(Empty(cParcel),CN9->CN9_DTASSI,dDataBase)
					SE2->E2_EMISSAO   := Iif(Empty(cParcel),CN9->CN9_DTASSI,dDataBase)
					SE2->E2_VENCTO    := aCond[ny][1]
					SE2->E2_VENCREA   := DataValida(aCond[ny][1])
					SE2->E2_VENCORI   := SE2->E2_VENCTO
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se o titulo e gerado na moeda corrente ou na moeda informada no contrato  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If	lMoeda
						SE2->E2_VALOR  := aCond[ny][2]
			 			SE2->E2_TXMOEDA:= 1
						SE2->E2_MOEDA  := CN9->CN9_MOEDA
					Else
						SE2->E2_VALOR  := aCond[ny][2]
						SE2->E2_MOEDA  := 1
					EndIf
					SE2->E2_SALDO  := SE2->E2_VALOR
					SE2->E2_NATUREZ   := cNatTit
					SE2->E2_VLCRUZ    := xMoeda(aCond[ny][2],SE2->E2_MOEDA,1,dDataBase)
					SE2->E2_ORIGEM    := "CNTA100"
					SE2->E2_RATEIO    := "N"
					SE2->E2_FLUXO     := "S"
					SE2->E2_MDCONTR   := CN9->CN9_NUMERO
					SE2->E2_MDREVIS   := CN9->CN9_REVISA
					SE2->E2_MDPLANI   := (cAliasCNA)->CNA_NUMERO
					// SE2->E2_MDCRON    :=
					If Empty(cParcel)
						SE2->E2_MDPARCE   := aParcelas[nX][1]
					Else
						SE2->E2_MDPARCE   := cMaxParce
					Endif
					SE2->E2_FILORIG	:= cFilCtr
					
					If lPeSE2
						ExecBlock("CNTPRSE2",.F.,.F.)//Ponto de entrada criado para alteracoes especificas no preenchimento do titulo a pagar
					EndIf

					MsUnlock()
				Next
			Else				
				SA1->(dbSetOrder(1))
				SA1->(dbSeek(xFilial("SA1")+(cAliasCNA)->(CNA_CLIENT+CNA_LOJACL)))			
				cNomeReduz := SA1->A1_NREDUZ//Caso SA1 seja desposicionada, garante a gravacao de <E1_NOMCLI> corretamente

				For ny := 1 to Len(aCond)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica proximo codigo disponivel         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					While SE1->(dbSeek(cFilSE1+cPrefixo+cMaxTit))
						cMaxTit := Soma1(cMaxTit)
					EndDo

					RecLock("SE1",.T.)
					SE1->E1_FILIAL    := xFilial("SE1",cFilCtr)
					SE1->E1_PREFIXO   := cPrefixo
					SE1->E1_NUM       := cMaxTit
					SE1->E1_PARCELA   := aParcelas[nX][1]
					If nRecorre = 0
						SE1->E1_HIST	  := Padr( "RECORRENCIA " + StrZero(nx,3) , TamSx3("E1_HIST")[1] )
					Else
						SE1->E1_HIST	  := Padr( "RECORRENCIA " + StrZero(nRecorre,3) , TamSx3("E1_HIST")[1] )
					Endif
					SE1->E1_TIPO      := "PR"
					SE1->E1_CLIENTE   := (cAliasCNA)->CNA_CLIENT
					SE1->E1_LOJA      := (cAliasCNA)->CNA_LOJACL
					SE1->E1_NOMCLI    := cNomeReduz
					SE1->E1_EMIS1     := Iif(Empty(cParcel),CN9->CN9_DTASSI,dDataBase)
					SE1->E1_EMISSAO   := Iif(Empty(cParcel),CN9->CN9_DTASSI,dDataBase)
					SE1->E1_VENCTO    := aCond[ny][1]
					SE1->E1_VENCREA   := DataValida(aCond[ny][1])
					SE1->E1_VENCORI   := SE1->E1_VENCTO
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se o titulo e gerado na moeda corrente ou na moeda informada no contrato  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lMoeda
						SE1->E1_VALOR   := aCond[ny][2]
						SE1->E1_TXMOEDA	:= 1
						SE1->E1_MOEDA   := CN9->CN9_MOEDA
					Else
						SE1->E1_VALOR   := aCond[ny][2]
						SE1->E1_MOEDA   := 1
					EndIf
					SE1->E1_SALDO     := SE1->E1_VALOR
					SE1->E1_NATUREZ   := cNatTit
					SE1->E1_VLCRUZ    := xMoeda(aCond[ny][2],SE1->E1_MOEDA,1,dDataBase)
					SE1->E1_ORIGEM    := "CNTA100"
					SE1->E1_FLUXO     := "S"
					SE1->E1_MDCONTR   := CN9->CN9_NUMERO
					SE1->E1_MDREVIS   := CN9->CN9_REVISA
					SE1->E1_MDPLANI   := (cAliasCNA)->CNA_NUMERO
					SE1->E1_MDPARCE   := aParcelas[nX][1]
					SE1->E1_FILORIG   := cFilCtr

					If lTemVend
						GrvVendTit(aVend)
					EndIf

					If lPeSE1
						ExecBlock("CNTPRSE1",.F.,.F.)//Ponto de entrada criado para alteracoes especificas no preenchimento do titulo a receber
					EndIf

					MsUnlock()
	        	Next nY
			EndIf
			cMaxTit := Soma1(cMaxTit)
		Next nX		

		// => Variável CNVLRREC disponível para uso no LP 69J de contabilização de planilha recorrente
		Private CNVLRREC
		If Empty(cParcel)
			CNA->( dbGoTo((cAliasCNA)->CNARECNO) )
			CNVLRREC := CN300QtdRec() * CNA->CNA_VLTOT
		Else
			CNVLRREC := CNA->CNA_VLTOT
		Endif
		CN100Contab(cLctoVige)
		(cAliasCNA)->(dbSkip())
	EndDo
	(cAliasCNA)->(dbCloseArea())
	FwFreeArray(aParcelas)
EndIf

CNA->(RestArea(aAreaCNA))
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CN100ParRc
Funcao que retorna as datas das medicoes de uma planilha recorrente
@author Rogerio Melonio
@since 27/07/2015
*/
//-------------------------------------------------------------------
Function CN100ParRc(cPeriodic,nRecorrencias,cDiaSem,nDiaMes,dDataPro,dDataIni,dDataFim,cCpoParcela,nPerRec,lAddRec,cNumParc )
Local aRecorrencias := {}

Local dDataMed
Local dUltMed

Local lSai 		:= .F.
Local lDiaMes	:= cPeriodic $ "34"

Local nTamParc 	:= 1
Local nX 		:= 0

Local cParcIni	:= Pad(GetMV("MV_1DUP"),TAMSX3(cCpoParcela)[1],' ')

Default lAddRec 	:= .F.
Default cCpoParcela := "E2_PARCELA"
Default cNumParc	:= ""

nTamParc 	:= TamSx3(cCpoParcela)[1]

For nX := 1 To nRecorrencias
	If nX == 1
		dDataMed := dDataPro
	Else
		dDataMed := CN300RetMed(cPeriodic,dUltMed,nDiaMes,cDiaSem,nPerRec,lDiaMes)
	Endif

	dUltMed := dDataMed
	If Empty(cNumParc)
		cNumParc := cParcIni
	Else
		cNumParc := Soma1(cNumParc)
	Endif
	If dDataMed <= dDataFim .And. !IsInCallStack("CN121MEDENC")
		aAdd( aRecorrencias, { cNumParc, dDataMed } )
	Else
		If !IsInCallStack("CN121MEDENC")
			If Month(dDataPro) <> Month(dDataIni) .And. nX <= nRecorrencias
				aAdd( aRecorrencias, { cNumParc, dDataMed } )
			Endif
			lSai := .T.
		Else
			aAdd( aRecorrencias, { cNumParc, dDataMed } )
		Endif
	Endif

	If lSai
		Exit
	Endif

Next nX

Return(aRecorrencias)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CN100ETit ³ Autor ³Marcelo Custodio       ³ Data ³17/03/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Realiza exclusao dos titulos provisorios do                 ³±±
±±³          ³contrato/cronograma                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CN100ETit(cExp01,cExp02,cExp03,cExp04)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp01 - Codigo do Contrato                                 ³±±
±±³          ³cExp02 - Codigo da revisao                                  ³±±
±±³          ³cExp03 - Numero do cronograma - opcional                    ³±±
±±³          ³cExp04 - Parcela do cronograma - opcional                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100ETit(cContra,cRevisa,cCronog,cParcel,cFilCtr,cNumPla,lDelUlt)
Local aAreas	:= {CN9->(GetArea()), CNA->(GetArea()), GetArea()}
Local lCn100tit := ExistBlock("CN100TIT")
Local lContinua	:= .T.

Local cQuery    := ""
Local cEspCtr   := ""
Local cPeriod	:= ""
Local cGCTTPPP	:= AllTrim(SuperGetMV("MV_GCTTPPP",.F.,"0"))
Local lAprov	:= FwIsInCallStack("A300APROV")
Local cMyAlias	:= GetNextAlias()
Local cTitAlias	:= ""
Local nTotRecor := 0
Default cCronog := ""
Default cParcel := ""
Default cFilCtr := cFilAnt
Default cNumPla := ""
Default lDelUlt := .F.

CN9->(dbSetOrder(1))
If CN9->(dbSeek(xFilial("CN9",cFilCtr)+cContra+cRevisa))
	cEspCtr := CN9->CN9_ESPCTR
	cTitAlias := IIF(cEspCtr == "1", "SE2", "SE1")

	If(lDelUlt .And. cCronog == "RECORRENTE")
		CNA->(DbSetOrder(1))//CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO
		If CNA->(DbSeek(xFilial("CNA",cFilCtr)+cContra+cRevisa+cNumPla))
			nTotRecor := TotPRCtr(cFilCtr, cContra, cRevisa, cNumPla, (cEspCtr == "1"))
			lContinua := !(nTotRecor < CNA->CNA_QTDREC) //Há cenários que não foi gerado título no encerramento(quando acaba a vigência do contrato), nesse caso não devemos estornar a última parcela
		EndIf
	EndIf

	If lContinua
		dbSelectArea(cTitAlias)
		If cEspCtr == "1"//³ Seleciona titulos provisorios
			cQuery := " SELECT "
			cQuery += " SE2.E2_PREFIXO AS PREFIXO, "
			cQuery += " SE2.E2_NUM AS NUMERO, "
			cQuery += "	SE2.E2_PARCELA AS PARCELA, "
			cQuery += "	SE2.E2_MDPLANI AS PLANILHA, "
			cQuery += " SE2.R_E_C_N_O_ as RECNO "
			cQuery += " FROM "+ RetSQLName("SE2") +" SE2 "
			cQuery += " WHERE "
			cQuery += " SE2.E2_FILORIG = '" + cFilCtr + "'"
			cQuery += " AND SE2.E2_MDCONTR = '" + cContra + "'"
			cQuery += " AND SE2.E2_MDREVIS = '" + cRevisa + "'"
			cQuery += " AND SE2.E2_TIPO    = 'PR'"
			cQuery += " AND "
			If !Empty(cCronog) .And. cCronog <> "RECORRENTE"
				cQuery += "SE2.E2_MDCRON = '"+ cCronog +"' AND "
			EndIf
			If !Empty(cParcel) .And. !lDelUlt
				cQuery += "SE2.E2_MDPARCE = '"+ cParcel +"' AND "
			EndIf
			If !Empty(cNumPla)
				cQuery += "SE2.E2_MDPLANI = '"+ cNumPla +"' AND "
			EndIf

			If lDelUlt
				cQuery += " SE2.E2_PARCELA = ( SELECT MAX(E2_PARCELA) FROM " + RetSQLName("SE2") + " SE2B "
				cQuery += " WHERE SE2B.E2_FILORIG = '"  + cFilCtr + "'"
				cQuery += " AND SE2B.E2_MDCONTR = '" + cContra + "'"
				cQuery += " AND SE2B.E2_MDREVIS = '" + cRevisa + "'"
				cQuery += " AND SE2B.E2_TIPO    = 'PR'"
				cQuery += " AND "
				If !Empty(cCronog) .And. cCronog <> "RECORRENTE"
					cQuery += "SE2B.E2_MDCRON = '"+ cCronog +"' AND "
				EndIf
				If !Empty(cNumPla)
					cQuery += "SE2B.E2_MDPLANI = '"+ cNumPla +"' AND "
				EndIf
				cQuery += "SE2B.D_E_L_E_T_ = ' ' ) AND "
			EndIf
			cQuery += "SE2.D_E_L_E_T_ = ' '"
			
		Else//³ Seleciona titulos provisorios              ³
			cQuery := " SELECT SE1.E1_PREFIXO AS PREFIXO, SE1.E1_NUM AS NUMERO, SE1.E1_PARCELA AS PARCELA,SE1.E1_MDPLANI AS PLANILHA,SE1.R_E_C_N_O_ as RECNO "
			cQuery += " FROM "+RetSQLName("SE1") + " SE1 "
			cQuery += " WHERE SE1.E1_FILORIG = '" + cFilCtr + "'"
			cQuery += " AND SE1.E1_MDCONTR = '" + cContra + "'"
			cQuery += " AND SE1.E1_MDREVIS = '" + cRevisa + "'"
			cQuery += " AND SE1.E1_TIPO    = 'PR'"
			cQuery += " AND "
			If !Empty(cCronog) .And. cCronog <> "RECORRENTE"
				cQuery += "SE1.E1_MDCRON = '"+ cCronog +"' AND "
			EndIf
			If !Empty(cParcel) .And. !lDelUlt
				cQuery += "SE1.E1_MDPARCE = '"+ cParcel +"' AND "
			EndIf
			If !Empty(cNumPla)
				cQuery += "SE1.E1_MDPLANI = '"+ cNumPla +"' AND "
			EndIf

			If lDelUlt
				cQuery += "SE1.E1_PARCELA = ( SELECT MAX(E1_PARCELA) FROM " + RetSQLName("SE1") + " SE1B "
				cQuery += " WHERE SE1B.E1_FILORIG = '"  + cFilCtr + "'"
				cQuery += "   AND SE1B.E1_MDCONTR = '" + cContra + "'"
				cQuery += "   AND SE1B.E1_MDREVIS = '" + cRevisa + "'"
				cQuery += "   AND SE1B.E1_TIPO    = 'PR'"
				cQuery += "   AND "
				If !Empty(cCronog) .And. cCronog <> "RECORRENTE"
					cQuery += "SE1B.E1_MDCRON = '"+ cCronog +"' AND "
				EndIf
				If !Empty(cNumPla)
					cQuery += "SE1B.E1_MDPLANI = '"+ cNumPla +"' AND "
				EndIf
				cQuery += "SE1B.D_E_L_E_T_ = ' ' ) AND "
			Endif

			cQuery += "SE1.D_E_L_E_T_ = ' '"		
		EndIf

		(cTitAlias)->(DbSetOrder(1))
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), cMyAlias,.F.,.T.)

		While !(cMyAlias)->(Eof())//Realiza exclusao dos titulos
			(cTitAlias)->(DbGoTo((cMyAlias)->RECNO))

			If lCn100tit
				ExecBlock("CN100TIT",.F.,.F.,{cContra,(cMyAlias)->PREFIXO,(cMyAlias)->NUMERO})
			EndIf

			If lAprov
				If cGCTTPPP <> "1"
					lContinua := .T.
				Else				
					cPeriod := Posicione("CNA",1,xFilial("CNA",cFilCtr)+cContra+cRevisa+(cMyAlias)->PLANILHA,"CNA_PERIOD")
					lContinua := IIF(cEspCtr == "1", Empty(cPeriod), !Empty(cPeriod))				
				Endif			
			EndIf

			If lContinua
				RecLock(cTitAlias,.F.)
				
				(cTitAlias)->(dbDelete())			

				MsUnlock()
			Endif
			(cMyAlias)->(dbSkip())
		EndDo	
		(cMyAlias)->(dbCloseArea())		
	EndIf
EndIf

aEval(aAreas, {|x|RestArea(x)})
FwFreeArray(aAreas)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    CN100Doc   ³ Autor ³ Marcelo Custodio      ³ Data ³26.12.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina de validacao dos documentos, executada na alteracao ³±±
±±³          ³ de situacao do contrato                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100Doc(nExp01,aExp02,lExp03)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01 - Contrato selecionado                              ³±±
±±³          ³ aExp02 - Situacoes para qual o contrato sera alterado      ³±±
±±³          ³ lExp03 - Valida situacoes inferiores                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100Doc(nReg,aSituac,lAll)
Return CNTDocSit(nReg,aSituac,lAll)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100BxCauc³ Autor ³ Marcelo Custodio      ³ Data ³20.09.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Executa baixa das caucoes de retencao do contrato           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100PlGr(lExp01)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lExp01 -Informa se a rotina de baixa de caucao foi executada³±±
±±³          ³          pela visualizacao de contrato                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100BxCauc(lVisu)
Local oDlg

Local nVlEft  := 0
Local nVlReg  := 0
Local nOpca   := 0
Local nx        := 0
Local nPosMed   := 0

Local cTpTit  := ""
Local cNumTit := ""
Local cParcela:= ""
Local cBco    := Space(TamSX3("A6_COD")[1])//Banco
Local cAgc    := Space(TamSX3("A6_AGENCIA")[1])//Agencia
Local cCta    := Space(TamSX3("A6_CONTA")[1])//Conta
Local cRetNat := PadR( GetNewPar( "MV_CNRETNA",  "" ), Len( SE2->E2_NATUREZ ) )//Natureza
Local cRetPrf := PadR( GetNewPar( "MV_CNRETPR", "CRE" ), Len( SE2->E2_PREFIXO ) )//Prefixo
Local cEspCtr	:= ""
Local cCodiCNT := Space(TamSX3("A2_COD")[1])
Local cLojaCNT := Space(TamSX3("A2_LOJA")[1])

Local aNoFields := {"CNT_FILIAL","CNT_CONTRA","CNT_FORNEC","CNT_LJFORN"}
Local aHeader   := {}
Local aCols     := {}

Local lBxPe     := .F.
Local lRet    := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida controle de acesso ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !CN240VldUsr(CN9->CN9_NUMERO,DEF_TRARET,.T.)
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida natureza informada no parametro MV_CNRETNA ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( cRetNat )
	Aviso( STR0088, STR0089, { "OK" }, 2 )//"Atencao !"#"Configurar a natureza financeira do titulo de caucao atraves do parametro MV_CNRETNA."
	lRet := .F.
EndIf

SED->( dbSetOrder( 1 ) )

If lRet .And. !SED->( MsSeek( xFilial( "SED" ) + cRetNat ) )
	Aviso( STR0088, STR0090, { "OK" }, 2 ) // "Atencao !"#"A natureza definida pelo parametro MV_CNRETNA nao esta cadastrada."
	lRet := .F.
EndIf

If ExistBlock("CNTRETPR")
	cRetPrf := If(ValType(cNewPref:=ExecBlock("CNTRETPR",.F.,.F.))=="C",PADR(cNewPref,Len(SE2->E2_PREFIXO)),cRetPrf)
EndIf

If lRet
	DEFAULT lVisu := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se Venda ou Compra                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cEspCtr := CN9->CN9_ESPCTR

 	cTpTit := PadR( If(cEspCtr=="1",GetNewPar( "MV_CNRETTC",  "NDF" ),GetNewPar( "MV_CNRETTV",  "NCC" )), len( SE2->E2_TIPO ) )//Tipo do titulo - Nota de Debito ao Fornecedor / Nota de Credito ao Cliente

	PRIVATE lBxCNT   := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona campos para a baixa do contrato          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aHeader,{STR0139,FLD_BAIXA,PesqPict("CNT","CNT_VLRET"),15,2,"CN100VldBx()","","N","","V"})//Baixa
	aAdd(aHeader,{STR0140,FLD_SALDO,PesqPict("CNT","CNT_VLRET"),15,2,"","","N","","V"})//Saldo

	dbSelectArea("SX3")
	dbSetOrder(1)
	If dbSeek("CNT")
		Do While !Eof() .And. SX3->X3_ARQUIVO=="CNT"
			If ( X3USO(SX3->X3_USADO)) .And. cNivel >= SX3->X3_NIVEL .And. aScan(aNoFields, {|x| x == AllTrim(SX3->X3_CAMPO)}) == 0
				aAdd(aHeader,{AllTrim(X3Titulo()),;
				AllTrim(SX3->X3_CAMPO),;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_F3,;
				SX3->X3_CONTEXT})
			EndIf
			dbSkip()
		EndDo
	EndIf

	//Adiciona o numero da planilha no aHeader
	aAdd(aHeader,{STR0154,FLD_PLANI,PesqPict("CND","CND_NUMERO"),6,0,"","","C","","V"})				// Planilha

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a dialog de retencao          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0091) FROM 0,0 TO 300,590 OF oMainWnd PIXEL // "Baixa da Caução de Retenção"

	oGetCNT := MsNewGetDados():New(25,4,__DlgHeight(oDlg)-30,__DlgWidth(oDlg)-4,GD_UPDATE,,,,{FLD_BAIXA,"CNT_HIST"},,,,,,oDlg,aHeader,aCols)

	@ __DlgHeight(oDlg)-27,4  Say OemToAnsi(STR0155) Size 60,8 OF oDlg PIXEL//"Total"
	@ __DlgHeight(oDlg)-27,23 MsGet oTotBaix Var nTotBaix PICTURE PesqPict("CNT","CNT_VLRET") WHEN .F. SIZE 60,8 OF oDlg PIXEL

	@ 10, 004 Say If(cEspCtr=="1",STR0095,STR0130) Size 60,8 PIXEL//"Fornecedor"/"Cliente"
	@ 09, 034 MsGet cCodiCNT SIZE 25,8 F3 "CNC001" Valid Vazio(cCodiCNT) .Or. CN100VldCauc(CN9->CN9_NUMERO,cCodiCNT,cLojaCNT,@nVlEft,oGetCNT) PIXEL

	@ 10, 075 Say OemToAnsi(STR0097) Size 60,8 PIXEL//"Loja"
	@ 09, 088 MsGet cLojaCNT SIZE 25,8 Valid Vazio(cLojaCNT) .Or. CN100VldCauc(CN9->CN9_NUMERO,cCodiCNT,cLojaCNT,@nVlEft,oGetCNT) PIXEL

	@ __DlgHeight(oDlg)-27,__DlgWidth(oDlg)-80  BUTTON STR0114 SIZE 35 ,13  FONT oDlg:oFont ACTION (nOpca:=1,oDlg:End()) OF oDlg PIXEL//"Baixar"
	@ __DlgHeight(oDlg)-27,__DlgWidth(oDlg)-40  BUTTON "Sair" SIZE 35 ,13  FONT oDlg:oFont ACTION (nOpca:=0,oDlg:End()) OF oDlg PIXEL//"Baixar"

	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpca == 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula valor do resgate            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nVlReg:=0
		nPosBx:=aScan(oGetCNT:aHeader,{|x| AllTrim(x[2])==FLD_BAIXA})
		For nx:=1 to len(oGetCNT:aCols)
			nVlReg+=Round(oGetCNT:aCols[nx,nPosBx],TamSX3("CNT_VLRET")[2])
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Validacao para nao permitir baixa com valor zerado  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QtdComp(nVlReg) == QtdComp(0)
			Aviso(STR0088,STR0141,{"Ok"}) //"Não e possivel realizar a baixa de retenção com valor zerado !"
			Return
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa ponto de entrada antes do processamento da baixa ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("CN100ABAIX")
			ExecBlock("CN100ABAIX",.F.,.F.,{nVlReg,oGetCNT:aCols,oGetCNT:aHeader,cCodiCNT,cLojaCNT})
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa processamento da baixa         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Processa({|| IF((lRet:=CN100PrcBxRet(CN9->CN9_NUMERO,CN9->CN9_REVISA,cCodiCNT,cLojaCNT,cBco,cAgc,cCta,nVlReg,cRetNat,cRetPrf,cTpTit,@cNumTit,oGetCNT:aCols,oGetCNT:aHeader,@lBxPe,@cParcela)) .And. lVisu,CN100LdAl(2,"CNT",aCols9,aHeader9,"CNT.CNT_CONTRA = '"+ M->CN9_NUMERO +"'",{"CNT_FORNEC","CNT_LJFORN","CNT_DTMED"},oGetDad9,If(cEspCtr=="1",{"CNT_CONTRA","CNT_CLIENT","CNT_LOJACL"},{"CNT_CONTRA","CNT_CLIENT","CNT_LOJACL","CNT_FORNEC","CNT_LJFORN"})),)},,OemToAnsi(STR0103))//"Processando Baixa"

		If lRet
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza tabela de baixas de retencao (CNY)  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPosMed := aScan(oGetCNT:aHeader,{|x| AllTrim(x[2])=="CNT_NUMMED"})
			For nx:=1 to len(oGetCNT:aCols)
				CN100GrvCNY(CN9->CN9_NUMERO,CN9->CN9_REVISA,cCodiCNT,cLojaCNT,oGetCNT:aCols[nx,nPosBx],cNumTit,cRetPrf,cParcela,cTpTit,oGetCNT:aCols[nx,nPosMed])
			Next
		EndIf

		If lRet	.And. !lBxPe

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa ponto de entrada depois do processamento da baixa ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock("CN100DBAIX")
				ExecBlock("CN100DBAIX",.F.,.F.,{nVlReg,cRetPrf,cNumTit,cParcela,cTpTit,cCodiCNT,cLojaCNT})
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exibe o resumo                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0104) FROM 9,0 TO 25,50 OF oMainWnd //"Resumo"
			@ 00,00 BITMAP oBmp RESNAME "LOGIN" oF oDlg SIZE 30, 120 NOBORDER WHEN .F. PIXEL
			DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
			@ 08,38 SAY OemToAnsi(STR0104) FONT oBold PIXEL//"Resumo"

			@ 24,30 TO 26 ,400 LABEL '' OF oDlg   PIXEL

			@ 31,38 SAY OemToAnsi(STR0105) PIXEL OF oDlg // "Prefixo"
			@ 41,38 SAY OemToAnsi(STR0106) PIXEL OF oDlg // "Numero do Titulo"
			@ 51,38 SAY OemToAnsi(STR0107) PIXEL OF oDlg // "Tipo"
			@ 61,38 SAY OemToAnsi(STR0108) PIXEL OF oDlg // "Valor"

			@ 31,110 SAY cRetPrf SIZE 80, 10 PIXEL   RIGHT
			@ 41,110 SAY cNumTit  SIZE 80, 10 PIXEL   RIGHT
			@ 51,110 SAY cTpTit   SIZE 80, 10 PIXEL   RIGHT
			@ 61,110 SAY Transform(nVlReg  ,PesqPict("SE2","E2_VALOR"))  SIZE 80, 10 PIXEL   RIGHT

			@ 90,030 TO 92 ,400 LABEL '' OF oDlg PIXEL

			DEFINE SBUTTON oBut FROM 101,162  TYPE 1 ACTION ( oDlg:End() ) ENABLE of oDlg
			ACTIVATE MSDIALOG oDlg CENTERED
		EndIf
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100VldCauc³ Autor ³ Marcelo Custodio      ³ Data ³20.09.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida o fornecedor informado e calcula o valor retido       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100VldCauc(cExp01,cExp02,cEpx03,nExp04)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo do contrato                                  ³±±
±±³          ³ cExp02 - Codigo do fornecedor/cliente                        ³±±
±±³          ³ cExp03 - Codigo da loja                                      ³±±
±±³          ³ nExp04 - Valor efetivo - referencia                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100VldCauc(cContra,cCodigo,cLoja,nVlEft,oGetCNT)
Local cQuery	:= ""
Local cNumMed	:= ""
Local cAlias	:= GetNextAlias()
Local lRet		:= .T.
Local aArea	:= GetArea()
Local nX		:= 0
Local cEspCtr	:= ""

Default cCodigo	:= ""
Default cLoja		:= ""

//-- Verifica tipo de contrato

cEspCtr := CN9->CN9_ESPCTR

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida o fornecedor                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cEspCtr == "1"
	lRet := ExistCpo("SA2",cCodigo+If(Empty(cLoja),"",cLoja))
Else
	lRet := ExistCpo("SA1",cCodigo+If(Empty(cLoja),"",cLoja))
EndIf

oGetCNT:aCols := {}

If lRet .And. !Empty(cCodigo) .And. !Empty(cLoja)
	cQuery := "SELECT CNT.*,(CNT.CNT_VLRET-CNT.CNT_VLBX) AS CNT_SALDO "
	cQuery += "  FROM "+RetSQLName("CNT")+" CNT "
	cQuery += " WHERE CNT.CNT_FILIAL = '"+xFilial("CNT")+"'"
	cQuery += "   AND CNT.CNT_CONTRA = '"+cContra+"'"
	cQuery += "   AND "
	If cEspCtr == "1"
		cQuery += "CNT.CNT_FORNEC = '"+cCodigo+"' AND "
		If !Empty(cLoja)
			cQuery += "CNT.CNT_LJFORN = '"+cLoja+"' AND "
		EndIf
	Else
		cQuery += "CNT.CNT_CLIENT = '"+cCodigo+"' AND "
		If !Empty(cLoja)
			cQuery += "CNT.CNT_LOJACL = '"+cLoja+"' AND "
		EndIf
	EndIf
	cQuery += "      CNT.CNT_VLRET > CNT.CNT_VLBX "
	cQuery += " AND CNT.D_E_L_E_T_ = ' '

	cQuery := ChangeQuery( cQuery )
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)

	aStrucCNT := CNT->(dbStruct())
	For nx:=1 to len(aStrucCNT)
		if (cAlias)->(FieldPos(aStrucCNT[nx,1])) > 0 .And. aStrucCNT[nx,2] <> "C"
			TCSetField( cAlias, aStrucCNT[nx,1], aStrucCNT[nx,2], aStrucCNT[nx,3], aStrucCNT[nx,4] )
		endif
	Next

	TCSetField(cAlias,"CNT_SALDO" ,"N",TamSX3("CNT_VLRET")[1],TamSX3("CNT_VLRET")[2])

	If (cAlias)->(Eof())
		lRet := .F.
		If cEspCtr == "1"
			Aviso( STR0088, STR0109, {"OK"})//"O fornecedor selecionado não possui valor retido em caução!"
		Else
			Aviso( STR0088, STR0142, {"OK"})//"O cliente selecionado não possui valor retido em caução!"
		EndIf
	Else
		While !(cAlias)->(Eof())
	  		aAdd(oGetCNT:aCols,Array(Len(oGetCNT:aHeader)+1))

  			For nx	:= 1 To Len(oGetCNT:aHeader)
		  		cCampo := Alltrim(oGetCNT:aHeader[nx,2])

				If cCampo == "CNT_NUMMED"
					cNumMed := (cAlias)->( FieldGet( (cAlias)->( FieldPos(oGetCNT:aHeader[nx][2]) ) ) )
				Endif

  				If ( oGetCNT:aHeader[nx][10] != "V" )
					oGetCNT:aCols[Len(oGetCNT:aCols)][nX] := (cAlias)->( FieldGet( (cAlias)->( FieldPos(oGetCNT:aHeader[nx][2]) ) ) )
				Else
					Do Case
						Case oGetCNT:aHeader[nx][2] == FLD_SALDO
							oGetCNT:aCols[Len(oGetCNT:aCols)][nX] := (cAlias)->CNT_SALDO
						Case oGetCNT:aHeader[nx][2] == FLD_BAIXA
				 			oGetCNT:aCols[Len(oGetCNT:aCols)][nX] := 0
						Case oGetCNT:aHeader[nx][2] == FLD_PLANI
							DbSelectArea("CND")
							DbSetorder(4)
							If DbSeek(xFilial("CND")+cNumMed)
								oGetCNT:aCols[Len(oGetCNT:aCols)][nX] := If(Empty(CND->CND_NUMERO),"------",CND->CND_NUMERO)
							EndIf
						OtherWise
							oGetCNT:aCols[Len(oGetCNT:aCols)][nX] := CriaVar(oGetCNT:aHeader[nx][2])
					EndCase
		 		EndIf
			Next nX
			oGetCNT:aCols[Len(oGetCNT:aCols), Len(oGetCNT:aHeader)+1] := .F.

			(cAlias)->( dbSkip() )
		EndDo
	EndIf
EndIf

oGetCNT:Refresh()

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100VldCauc³ Autor ³ Marcelo Custodio      ³ Data ³20.09.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gera o titulo a pagar para o valor retido do contrato        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100VldCauc(cExp01,cExp02,cEpx03,cExp04,cExp05,nExp06,cExp07³±±
±±³          ³              ,cExp08,cExp09,cExp10)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Fornecedor                                          ³±±
±±³          ³ cExp02 - Loja do fornecedor                                  ³±±
±±³          ³ cExp03 - Codigo do banco                                     ³±±
±±³          ³ cExp04 - Agencia                                             ³±±
±±³          ³ cExp05 - Conta                                               ³±±
±±³          ³ nExp06 - Valor do titulo                                     ³±±
±±³          ³ cExp07 - Natureza do titulo                                  ³±±
±±³          ³ cExp08 - Prefixo do titulo                                   ³±±
±±³          ³ cExp09 - Tipo do titulo                                      ³±±
±±³          ³ cExp10 - Numero do titulo - referencia                       ³±±
±±³          ³ cExp11 - Tipo da Transacao 1-Retencao,2-Adiantamento         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100GerSE2(cForn,cLoja,cBco,cAgc,cCta,nVlRet,cRetNat,cRetPrf,cTpTit,cNumTit,cTipo,cParcela,cCheque, dVenciment)
Local aAreaSub
Local aRotAuto := {}
Local aAfrBck  := {}
Local cMoeda   := ""
Local lRet     := .T.
Local lExcPms  := IntePMS() .And. (GetNewPar( "MV_CNEXPMS", "N" ) == "S")

PRIVATE lMsErroAuto := .F.

DEFAULT cCheque	:= ''
Default dVenciment := dDataBase

dVenciment := Max(dVenciment, dDataBase) //Garante que a data de vencimento nunca seja inferior a emissao(database)
cParcela := CriaVar("E2_PARCELA")
cMoeda   := CN9->CN9_MOEDA

If Empty(cNumTit)
	cNumTit := ProxNumTit(cRetPrf)//Obtem o numero pro proximo titulo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe integracao com o PMS    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lExcPms
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Simula chamada do FINA050  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aRatAfr := {}
	Private lF050Auto := .T.
	Private M->E2_VALOR := nVlRet
	Private M->E2_MOEDA := cMoeda
	Private M->E2_EMISSAO := dDataBase
	Private M->E2_MDCONTR := CN9->CN9_NUMERO

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa Dialog para preenchimento do projeto  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAreaSub := GetArea()
	PmsDlgFS(3,cRetPrf,cNumTit,cParcela,cTpTit,cForn,cLoja)
	RestArea(aAreaSub)
	aAfrBck  := aRatAfr
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para validacao do rateio do projeto ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CNTVLDPMS")
	lRet := ExecBlock("CNTVLDPMS",.F.,.F.,{nVlRet,"1"})
EndIf

If lRet

	BEGIN TRANSACTION
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera nota de debito ao fornecedor          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aRotAuto, { "E2_NUM"    , cNumTit, NIL } )
	AAdd( aRotAuto, { "E2_PREFIXO", cRetPrf, NIL } )
	AAdd( aRotAuto, { "E2_NATUREZ", cRetNat, NIL } )
	AAdd( aRotAuto, { "E2_PARCELA", cParcela, NIL } )
	AAdd( aRotAuto, { "E2_TIPO"   , cTpTit, NIL } )
	AAdd( aRotAuto, { "E2_FORNECE", cForn, NIL } )
	AAdd( aRotAuto, { "E2_LOJA"   , cLoja, NIL } )
	AAdd( aRotAuto, { "E2_VALOR"  , nVlRet, NIL } )
	AAdd( aRotAuto, { "E2_EMISSAO", dDataBase, NIL } )
	AAdd( aRotAuto, { "E2_VENCTO" , dVenciment, NIL } )
	AAdd( aRotAuto, { "E2_VENCREA", DataValida( dVenciment ), NIL } )
	AADD( aRotAuto, { "E2_VENCORI", DataValida( dVenciment,.T.),NIL })
	AADD( aRotAuto, { "E2_MOEDA"  , cMoeda, NIL})
	AADD( aRotAuto, { "E2_MDCONTR", CN9->CN9_NUMERO, NIL})
	AADD( aRotAuto, { "E2_MDREVIS", CN9->CN9_REVISA, NIL})
	AADD( aRotAuto, { "E2_ORIGEM" , "CNTA100"      , NIL})
	AAdd( aRotAuto, { "AUTBANCO"  , cBco, NIL } )
	AAdd( aRotAuto, { "AUTAGENCIA", cAgc, NIL } )
	AAdd( aRotAuto, { "AUTCONTA"  , cCta, NIL } )
	
	If !Empty(cCheque)
		AAdd( aRotAuto, { "AUTCHEQUE" , cCheque, NIL } )
	EndIf

	MSExecAuto({|x, y| FINA050(x, y)}, aRotAuto, 3)

	If !lMsErroAuto
		aRatAfr := aAfrBck
		If !Empty(aRatAfr)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava informacao de despesa do projeto  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PmsWriteFI(1,"SE2")
			aRatAfr := {}
		EndIf
	EndIf
	END TRANSACTION

	If lMsErroAuto
		MOSTRAERRO()
		lRet := .F.
	EndIf
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100GerSE1 ³ Autor ³ Robson Nayland        ³ Data ³06.10.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gera o titulo a receber para o valor retido do contrato      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100GerSE1(cExp01,cExp02,cEpx03,cExp04,cExp05,nExp06,cExp07 ³±±
±±³          ³              ,cExp08,cExp09,cExp10)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Fornecedor                                          ³±±
±±³          ³ cExp02 - Loja do fornecedor                                  ³±±
±±³          ³ cExp03 - Codigo do banco                                     ³±±
±±³          ³ cExp04 - Agencia                                             ³±±
±±³          ³ cExp05 - Conta                                               ³±±
±±³          ³ nExp06 - Valor do titulo                                     ³±±
±±³          ³ cExp07 - Natureza do titulo                                  ³±±
±±³          ³ cExp08 - Prefixo do titulo                                   ³±±
±±³          ³ cExp09 - Tipo do titulo                                      ³±±
±±³          ³ cExp10 - Numero do titulo - referencia                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100GrSE1(cCliente,cLoja,cBco,cAgc,cCta,nVlRet,cRetNat,cRetPrf,cTpTit,cNumTit,lExbErro,cParcela, dVenciment)

Local aAreaSub
Local aRotAuto := {}
Local aArea    := GetArea()
Local aAftBck  := {}
Local aCN100RAU:= {}
Local cMoeda   := ""
Local lRet     := .T.
Local lExcPms  := IntePMS() .And. (GetNewPar( "MV_CNEXPMS", "N" ) == "S")

Default lExbErro := .T.
Default dVenciment := dDataBase
PRIVATE lMsErroAuto := .F.

cParcela := CriaVar("E1_PARCELA")
cMoeda   := CN9->CN9_MOEDA
dVenciment := Max(dVenciment, dDataBase) //Garante que a data de vencimento nunca seja inferior a emissao(database)

If Empty(cNumTit)
	cNumTit := ProxNumTit(cRetPrf, .F.) //Obtem o numero pro proximo titulo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe integracao com o PMS    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lExcPms
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Simula chamada do FINA040  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aRatAft := {}
	Private M->E1_VALOR := nVlRet
	Private M->E1_MOEDA := cMoeda

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa Dialog para preenchimento do projeto  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAreaSub := GetArea()
	PmsDlgRC(3,cRetPrf,cNumTit,cParcela,cTpTit,cCliente,cLoja)
	RestArea(aAreaSub)
	aAftBck  := aRatAft
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para validacao do rateio do projeto ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("CNTVLDPMS")
	lRet := ExecBlock("CNTVLDPMS",.F.,.F.,{nVlRet,"2"})
EndIf

If lRet

	BEGIN TRANSACTION
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera nota de debito ao Cliente             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd( aRotAuto, { "E1_NUM"    , cNumTit, NIL } )
		AAdd( aRotAuto, { "E1_PREFIXO", cRetPrf, NIL } )
		AAdd( aRotAuto, { "E1_NATUREZ", cRetNat, NIL } )
		AAdd( aRotAuto, { "E1_TIPO"   , cTpTit, NIL } )
		AAdd( aRotAuto, { "E1_CLIENTE", cCliente, NIL } )
		AAdd( aRotAuto, { "E1_LOJA"   , cLoja, NIL } )
		AAdd( aRotAuto, { "E1_VALOR"  , nVlRet, NIL } )
		AAdd( aRotAuto, { "E1_EMISSAO", dDataBase, NIL } )
		AAdd( aRotAuto, { "E1_VENCTO" , dVenciment, NIL } )
		AAdd( aRotAuto, { "E1_VENCREA", DataValida( dVenciment ), NIL } )
		AADD( aRotAuto, { "E1_VENCORI", DataValida( dVenciment,.T.),NIL })
		AADD( aRotAuto, { "E1_MOEDA"  , CN9->CN9_MOEDA, NIL})
		AADD( aRotAuto, { "E1_MDCONTR", CN9->CN9_NUMERO, NIL})
		AADD( aRotAuto, { "E1_MDREVIS", CN9->CN9_REVISA, NIL})
		AADD( aRotAuto, { "E1_ORIGEM" , "CNTA100"     , NIL})
		AADD( aRotAuto, { "CBCOAUTO"  , cBco, NIL } )
		AADD( aRotAuto, { "CAGEAUTO"  , cAgc, NIL } )
		AADD( aRotAuto, { "CCTAAUTO"  , cCta, NIL } )


		If ExistBlock("CN100RAU")
			aCN100RAU:= ExecBlock("CN100RAU",.F.,.F.,{aRotAuto})
			If ValType(aCN100RAU) == "A"
				aRotAuto    := aClone(aCN100RAU)
			EndIf
		EndIf

		MSExecAuto({|x, y| FINA040(x, y)}, aRotAuto, 3)

		If !lMsErroAuto
			aRatAft := aAftBck
			If !Empty(aRatAft)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava informacao de despesa do projeto  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PmsWriteRC(1,"SE1")
				aRatAft := {}
			EndIf
		EndIf
	END TRANSACTION

	If lMsErroAuto .And. lExbErro
		MOSTRAERRO()
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)

Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100BxRet  ³ Autor ³ Marcelo Custodio      ³ Data ³20.09.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Executa baixa das retencoes do contrato                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100BxRet(nExp01,cExp02,cEpx03,cExp04,lExp05)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01 - Valor a ser resgatado                               ³±±
±±³          ³ cExp02 - Codigo do contrato                                  ³±±
±±³          ³ cExp03 - Codigo do fornecedor                                ³±±
±±³          ³ cExp04 - Loja do fornecedor                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100BxRet(aCols,aHeader,cContra,cForn,cLoja)
Local nx        := 0
Local ny        := 0
Local nPosBx    := aScan(aHeader,{|x| AllTrim(x[2])==FLD_BAIXA})
Local nPosMed   := aScan(aHeader,{|x| AllTrim(x[2])=="CNT_NUMMED"})

dbSelectArea("CNT")
dbSetOrder(1)

For nx:=1 to len(aCols)
	If dbSeek(xFilial("CNT")+cContra+aCols[nx,nPosMed])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Realiza a baixa                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("CNT",.F.)
			If	aCols[nx,nPosBx] > 0
				CNT->CNT_DTBX := dDataBase
			EndIf
			CNT->CNT_VLBX += aCols[nx,nPosBx]
			For ny:=1 to len(aHeader)
				If !(aHeader[ny,2] $ "BAIXA|SALDO|CNT_VLBX|CNT_VLRET|CNT_DTBX")
					CNT->&(aHeader[ny,2]) := aCols[nx,ny]
				EndIf
			Next
		MsUnlock()
	EndIf
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100PrcBxRet³ Autor ³ Marcelo Custodio      ³ Data ³20.09.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Executa o processamento da baixa de retencao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100PrcBxRet(cExp01,cExp02,cEpx03,cExp04,cExp05,cExp06,cExp07³±±
±±³          ³               nExp08,cExp09,cEpx10,cExp11,cExp12)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo do contrato                                   ³±±
±±³          ³ cExp02 - Codigo da revisao                                    ³±±
±±³          ³ cExp03 - Codigo do fornecedor/cliente                         ³±±
±±³          ³ cExp04 - Loja do fornecedor                                   ³±±
±±³          ³ cExp05 - Codigo do banco                                      ³±±
±±³          ³ cExp06 - Codigo da agencia                                    ³±±
±±³          ³ cExp07 - Codigo da conta                                      ³±±
±±³          ³ cExp08 - Valor do resgate                                     ³±±
±±³          ³ cExp09 - Natureza do titulo                                   ³±±
±±³          ³ cExp10 - Prefixo do titulo                                    ³±±
±±³          ³ cExp11 - Tipo do titulo                                       ³±±
±±³          ³ cExp12 - Numero do titulo - referencia                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100PrcBxRet(cContra,cRevisa,cCodigo,cLoja,cBco,cAgc,cCta,nVlReg,cRetNat,cRetPrf,cTpTit,cNumTit,aCols,aHeader,lBxPe,cParcela)
Local lRet    := .F.
Local nPosMed := aScan(aHeader,{|x| AllTrim(x[2])=="CNT_NUMMED"})
Local nTotRet := 0
Local nX     := 0

lBxPe := ExistBlock("CN100BxRet")

ProcRegua(2)

dbSelectArea("CNT")
dbSetOrder(1)

For nx:=1 to len(aCols)
	If dbSeek(xFilial("CNT")+cContra+aCols[nx,nPosMed])
		nTotRet += CNT->CNT_VLRET
	EndIf
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe ponto de entrada para baixa da retencao ³
//³ Tratamento especifico para Galvao, para geracao das DAPs   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IncProc()
If lBxPe
	lRet := ExecBlock("CN100BxRet",.F.,.F.,{cCodigo,cLoja,nVlReg,aCols,aHeader})
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera o titulo                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(CNT->CNT_CLIENT)
		lRet := CN100GerSE2(cCodigo,cLoja,cBco,cAgc,cCta,nVlReg,cRetNat,cRetPrf,cTpTit,@cNumTit,@cParcela)
	Else
		lRet := CN100GrSE1(cCodigo,cLoja,cBco,cAgc,cCta,nVlReg,cRetNat,cRetPrf,cTpTit,@cNumTit,,@cParcela)
	EndIf
EndIf

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a baixa das retencoes                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CN100BxRet(aCols,aHeader,CN9->CN9_NUMERO,cCodigo,cLoja)
	IncProc()
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100CtrRet  ³ Autor ³ Marcelo Custodio      ³ Data ³20.09.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Executa a baixa dos valores retidos atraves do browse de      ³±±
±±³          ³ contrato                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100CtrRet()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100CtrRet()

Private nTotBaix  := 0
Private oTotBaix

If CN9->CN9_FLGCAU == "1" .And. CN9->CN9_TPCAUC == "2"
	//Verifica se o usuário possui permissão na amarração Usuário X Contrato (CNN)
	If (CN240VldUsr(CN9->CN9_NUMERO,DEF_BXRET,.T.))
		CN100BxCauc(.F.)
	EndIf
Else
	Aviso(STR0088,STR0112,{"OK"})//"O contrato selecionado não possui caução de retenção."
EndIf
Return

//-------------------------------------------------------------------
/*{Protheus.doc}VlCliForAd()
Validação para os campos Codigo e Loja da tela de adiantamentos

@author Andre Anjos
@since 03/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function VlCliForAd(cEspCtr,cCodiCNT,cLojaCNT)
Local lRet := .T.
Local cAlias := If(cEspCtr == "1","SA2","SA1")

lRet := Vazio(cCodiCNT) .Or. ExistCpo(cAlias,cCodiCNT+If(!Empty(cLojaCNT),cLojaCNT,""))

CNC->(dbSetOrder(If(cEspCtr == "1",1,3)))
If lRet .And. !Empty(cCodiCNT) .And. !CNC->(dbSeek(xFilial("CNC")+CN9->(CN9_NUMERO+CN9_REVISA)+cCodiCNT+If(!Empty(cLojaCNT),cLojaCNT,"")))
	Help(" ",1,"REGNOIS")
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100ProcAd ³ Autor ³ Marcelo Custodio     ³ Data ³19.10.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Executa processa,emto do Adiantamento dos contratos         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100ProcAd                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±³          ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function CN100ProcAd(cNumCNX,cEspCtr,cContra,cCodiCNT,cLojaCNT,cBco,cAgc,cCta,nVlAdianta,cRetNat,cRetPrf,cTpTit,cNumTit,cCheque)
Local lRet:=.T.
Local oModel := FwModelActive()
Local dVenciment := dDataBase
Default cCheque := ''

ProcRegua(3)

If (ValType(oModel) == 'O' .And. oModel:IsActive() .And. oModel:GetId() $ "CNTA300|CNTA301")
	dVenciment := oModel:GetValue("CNXDETAIL", "CNX_DTADT") //Possibilita ao cliente modificar a data de vencimento do Adiantamento
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada anterior a gravacao SE1 e SE2 campos customizados referente ao adiantamento  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (ExistBlock("CN100ANT"))
	cNumTit := ProxNumTit(cRetPrf, (cEspCtr == "1"))//Obtem o numero antes do P.E <CN100ANT>

	ExecBlock("CN100ANT",.F.,.F.,{cNumCNX,cEspCtr,cContra,cCodiCNT,cLojaCNT,cBco,cAgc,cCta,nVlAdianta,cRetNat,cRetPrf,cTpTit,cNumTit})

else
	cNumTit := ""
EndIf

BEGIN TRANSACTION

IncProc()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa processamento                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cEspCtr ="1"   //Compra
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizando Contas a Pagar             ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cTpTit := PadR( GetNewPar("MV_CNADITC","PA"), Len( SE2->E2_TIPO ) )//Tipo do titulo - PADRAO: Pagamento adiantado 'PA'
   cTpTit := Iif(Empty(cTptit), "PA", cTptit)
   lRet := CN100GerSE2(cCodiCNT,cLojaCNT,cBco,cAgc,cCta,nVlAdianta,cRetNat,cRetPrf,cTpTit,@cNumTit,"2",,cCheque, dVenciment)
Else
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Atualizando Contas a receber           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cTpTit := PadR( GetNewPar("MV_CNADITV","RA"), Len( SE1->E1_TIPO ) )//Tipo do titulo - PADRAO: Recebimento adiantado 'RA'
   cTpTit := Iif(Empty(cTptit), "RA", cTptit)
   lRet := CN100GrSE1(cCodiCNT,cLojaCNT,cBco,cAgc,cCta,nVlAdianta,cRetNat,cRetPrf,cTpTit,@cNumTit,, /*cParcela*/, dVenciment)
Endif

IncProc()

END TRANSACTION

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada anterior a gravacao campos customizados referente ao adiantamento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (ExistBlock("CN100ADI"))
	ExecBlock("CN100ADI",.F.,.F.)
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100EstAd  ³ Autor ³ Marcelo Custodio     ³ Data ³20.10.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Processa estorno do titulo de adiantamento                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100EstAd(cExp01,cExp02,cExp03)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Codigo do Contrato                                 ³±±
±±³          ³ cExp02 - Codigo do Adiantamento                             ³±±
±±³          ³ cExp03 - Especie do Contrato 1-Compra;2-Venda               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100EstAd(cContra,cNumAd,cEspCtr)
Local lRet     := .T.
Local cPref    := ""
Local cTit     := ""
Local aRotAuto := {}

ProcRegua(2)

dbSelectArea("CNX")
dbSetOrder(1)
If dbSeek(xFilial("CNX")+cContra+cNumAd)
	cPref := CNX->CNX_PREFIX
	cTit  := CNX->CNX_NUMTIT

	BEGIN TRANSACTION

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa processamento                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cEspCtr ="1"    // se for fornecedor
		DbselectArea("SE2")
		DbSetOrder(1)
		dbSeek(xFilial("SE2")+cPref+cTit)
		If Found()

			AAdd( aRotAuto, { "E2_NUM"    , SE2->E2_NUM, NIL } )
			AAdd( aRotAuto, { "E2_PREFIXO", SE2->E2_PREFIXO, NIL } )
			AAdd( aRotAuto, { "E2_NATUREZ", SE2->E2_NATUREZ, NIL } )
			AAdd( aRotAuto, { "E2_TIPO"   , SE2->E2_TIPO, NIL } )
			AAdd( aRotAuto, { "E2_FORNECE", SE2->E2_FORNECE, NIL } )
			AAdd( aRotAuto, { "E2_LOJA"   , SE2->E2_LOJA, NIL } )

			MSExecAuto({|x, y, z| FINA050(x, y, z)}, aRotAuto, 5, 5)
		Endif
	Else
		DbselectArea("SE1")   // se for cliente
		DbSetOrder(1)
		dbSeek(xFilial("SE1")+cPref+cTit)
		If Found()
			AAdd( aRotAuto, { "E1_NUM"    , SE1->E1_NUM, NIL } )
			AAdd( aRotAuto, { "E1_PREFIXO", SE1->E1_PREFIXO, NIL } )
			AAdd( aRotAuto, { "E1_NATUREZ", SE1->E1_NATUREZ, NIL } )
			AAdd( aRotAuto, { "E1_TIPO"   , SE1->E1_TIPO, NIL } )
			AAdd( aRotAuto, { "E1_CLIENTE", SE1->E1_CLIENTE, NIL } )
			AAdd( aRotAuto, { "E1_LOJA"   , SE1->E1_LOJA, NIL } )
            AADD( aRotAuto, { "E1_PORTADO", SE1->E1_PORTADO, NIL } )
			AADD( aRotAuto, { "E1_AGEDEP" , SE1->E1_AGEDEP, NIL } )
			AADD( aRotAuto, { "E1_CONTA"  , SE1->E1_CONTA, NIL } )

			MSExecAuto({|x, y| FINA040(x, y)}, aRotAuto, 5)

		Endif
	Endif

	IncProc()

	END TRANSACTION

	If lMsErroAuto
        If !IsBlind()
		    MOSTRAERRO()
        EndIf
		lRet := .F.
	EndIf

	IncProc()
Else
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ValidValor  ³ Autor ³ Robson Nayland       ³ Data ³20.10.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida o valor do adiantamento com o valor do contrato.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ValidValor                                                  ³±±

±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±³          ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ValidValor(nVlAdianta,lRetVl)
//Previsao Financeira
Local nI 		  := 0
Local oModel    := FwModelActive()
Local oModCNX	  := oModel:GetModel('CNXDETAIL')
Local nTotal	  := nVlAdianta
Local aSaveLines	:= FWSaveRows()
Default lRetVl  := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida adiantamentos existentes                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For nI	:= 1 To oModCNX:Length() - 1
	oModCNX:GoLine(nI)

	If !oModCNX:IsDeleted()
		nTotal += oModCNX:GetValue('CNX_SALDO')
	EndIf

Next nI

If CN9->CN9_SALDO < nTotal
 	Help('',1,'CNTA300EXCAD',,STR0172,4) //Valor do adiantamento é superior ao saldo do contrato
    lRetVl:=.F.
Else
	lRetVl:=.T.
EndIf

FWRestRows(aSaveLines)

Return(nVlAdianta,lRetVl)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100LdAl  ³ Autor ³ Marcelo Custodio      ³ Data ³05.01.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Rotina generica para preenchimento dos folders              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100LdAl(nExp01,cExp02,aExp03,aExp04,cExp05,aExp06,oExp07  ³±±
±±³          ³           cExp08,aExo09)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01 - Opcao Atual                                        ³±±
±±³          ³ cExp02 - Alias consultado                                   ³±±
±±³          ³ aExp03 - aCols                                              ³±±
±±³          ³ aExp04 - aHeader                                            ³±±
±±³          ³ cExp05 - Condicao where no formato SQL                      ³±±
±±³          ³ aExp06 - Ordem da consulta                                  ³±±
±±³          ³ oExp07 - GetDados                                           ³±±
±±³          ³ cExp08 - Campos nao exibidos no aheader                     ³±±
±±³          ³ aExp09 - Query especifica                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100LdAl(nOpc,cAlias,aCols,aHeader,cWhere,aOrder,oGetDad,aNoFields,cQuery,cSeek,cWhile,cFilCTR)
Local nX        := 0
Local lExec     := (cQuery == NIL)
Local cOrder    := ""

Default aOrder := {}
Default cWhere := ""
Default cSeek  := ""
Default cWhile := ""
Default cFilCTR:= cFilAnt

acols := {}

dbSelectArea(cAlias)

If nOpc != 3
	If lExec
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Query  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "SELECT "+ cAlias +".* FROM "+ RetSQLName(cAlias) + " " + cAlias + " WHERE "
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtra filial ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery += cAlias+"."+cAlias+"_FILIAL = '"+xFilial(cAlias,cFilCTR)+"' AND "
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica condicao Where ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cWhere)
			cQuery += cWhere + " AND "
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtra refistros deletados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery += cAlias+".D_E_L_E_T_ = ' ' "
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta ordem dos registros  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aOrder) > 0
			For nX:=1 to len(aOrder)
				cOrder += aOrder[nX]+","
			next
			cQuery += "ORDER BY " + SubStr(cOrder,1,len(cOrder)-1)
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FillGetDados(nOpc,cAlias,1,cSeek,{|| &cWhile },{|| .T. },aNoFields,,,cQuery,,,If(len(aHeader)>0,NIL,aHeader),aCols)
Else
	FillGetDados(nOpc,cAlias,1,,,,aNoFields,,,,,.T.,aHeader,aCols)
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza a getdados com os cronogramas contabeis  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oGetDad != Nil
	oGetDad:aCols := acols
	oGetDad:oBrowse:Refresh()
	oGetDad:Refresh()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100Contab³ Autor ³ Marcelo Custodio      ³ Data ³17.04.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Contabiliza a emissao do contrato                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100Contab()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN100Contab(cPadrao)

LOCAL aArea     := GetArea()
LOCAL aCtbDia	:= {}

LOCAL cLoteCtb  := ""

LOCAL lDigita   := .F.
LOCAL lPadrao   := .F.

LOCAL nHdlPrv   := 0
LOCAL nTotal    := 0

Private cArquivo := " "

dbSelectArea("CN9")
dbSetOrder(1)

Pergunte("CNT100",.F.)
lDigita := MV_PAR02 == 1
lPadrao := VerPadrao(cPadrao)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Lancamento Contabil³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lPadrao .and. MV_PAR01 == 1 )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o numero do lote contabil                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX5")
	dbSetOrder(1)
	If MsSeek(xFilial()+"09GCT")
		cLoteCtb := AllTrim(X5Descri())
	Else
		cLoteCtb := "GCT "
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa o execblock                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If At(UPPER("EXEC"),X5Descri()) > 0
		cLoteCtb := &(X5Descri())
	EndIf

	nHdlPrv := HeadProva(cLoteCtb,"CNTA100",Substr(cUsuario,7,6),@cArquivo)
	nTotal  += DetProva(nHdlPrv,cPadrao,"CNTA100",cLoteCtb)
	RodaProva(nHdlPrv,nTotal)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envia para Lancamento Contabil³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc == "PTG"
		aCtbDia := {{"CN9",CN9->(RECNO()),CN9->CN9_DIACTB,"CN9_NODIA"}}
	Else
	    aCtbDia := {}
	EndIF
	cA100Incl(cArquivo,nHdlPrv,3,cLoteCtb,lDigita,.F.,,,,,,aCtbDia)
EndIf

RestArea(aArea)
Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CN100VldBx³ Autor ³ Marcelo Custodio      ³ Data ³05/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o valor informado na baixa das caucoes de retencao  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CN100VldBx()
Local lRet    := .T.
Local aCols   := o:OMOTHER:ACOLS
Local aHeader := o:OMOTHER:aHeader
Local nAt     := o:nAt
Local nPosBx  := aScan(aHeader,{|x| x[2]==FLD_BAIXA})
Local nPosSld := aScan(aHeader,{|x| x[2]==FLD_SALDO})
Local nPosVl  := aScan(aHeader,{|x| x[2]=="CNT_VLRET"})
Local nPosVlb := aScan(aHeader,{|x| x[2]=="CNT_VLBX"})
Local nx
Local uRet	  := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o valor informado na baixa, e inferior ao saldo da retencao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := (M->BAIXA <= (aCols[nAt,nPosVl]-aCols[nAt,nPosVlb]))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica baixa parcial no Ponto de Entrada Cn100BxRet					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCn100BxRet
	lRet := M->BAIXA = aCols[nAt,nPosVl]
	If !lRet
		Aviso(STR0088,STR0184,{"Ok"}) // Ao utilizar o Ponto de Entrada CN100BXRET a baixa não pode ser parcial
	Endif
Endif

//Ponto de entrada para validacao da baixa
If lRet .And. ExistBlock("CN100VBAIX")
	uRet := ExecBlock("CN100VBAIX",.F.,.F.,{M->BAIXA,aCols,aHeader})
	If Valtype(uRet) == "L"
		lRet := uRet
	EndIf
EndIf

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza saldo     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols[nAt,nPosSld] := (aCols[nAt,nPosVl]-aCols[nAt,nPosVlb])-M->BAIXA
	nTotBaix := 0
	For nx:=1 to len(aCols)
		If nx==nAt
			nTotBaix+=Round(M->BAIXA,TamSX3("CNT_VLRET")[2])
		Else
			nTotBaix+=Round(aCols[nx,nPosBx],TamSX3("CNT_VLRET")[2])
		EndIf
	Next
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza objetos   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
o:Refresh()
oTotBaix:Refresh()

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100GrvCNY³ Autor ³ Felipe Bittar        ³ Data ³ 06/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua gravacao da tabela de baixa de retenção             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100GrvCNY(cContra,cRevisa,cCodigo,cLoja,nValor,cNumTit,cRetPrf,cParcela,cTpTit,cNumed)
Local aArea	:= GetArea()
Local cFilCod	:= xFilial("CNY")
Local cEspCtr	:= ""

cEspCtr := CN9->CN9_ESPCTR

DbSelectArea("CNY")

If nValor > 0
	RecLock("CNY",.T.)
		CNY->CNY_FILIAL := cFilCod
		CNY->CNY_CONTRA := cContra
		CNY->CNY_REVISA := cRevisa
		CNY->CNY_NUMMED := cNumed
		CNY->CNY_VLBAIX := Round(nValor,TamSX3("CNY_VLBAIX")[2])
		CNY->CNY_NUMTIT := cNumTit
		CNY->CNY_PREFIX := cRetPrf
		CNY->CNY_PARCEL := cParcela
		CNY->CNY_TIPO   := cTpTit
		If cEspCtr == "1"
			CNY->CNY_FORNEC := cCodigo
			CNY->CNY_LOJA	  := cLoja
		Else
			CNY->CNY_CLIENT := cCodigo
			CNY->CNY_LOJACL := cLoja
		EndIf
	MsUnLock()
EndIf

RestArea(aArea)

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100EstBx ³ Autor ³ Felipe Bittar        ³ Data ³ 06/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua estorno da baixa de retencao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100EstBx()
Local oDlg

Local lRet       := .T.

Local nOpca		 := 0

Local cQuery	 := ""
Local cTpTit     := ""
Local cNumTit    := ""
Local cParcela   := ""
Local cRetPrf    := ""
Local cForn		 := ""
Local cLoja		 := ""
Local cClient    := ""
Local cLjCli     := ""
Local cLine      := ""
Local cEspCtr	 := "1"
Local cTpPref    := PadR( GetNewPar( "MV_CNRETPR", "CRE" ), Len( SE2->E2_PREFIXO ) )//Prefixo
Local cAliasQry

Local aStruTit   := {}
Local aCampos    := {}
Local aTitle     := {}

Local lCN100EsRet:= ExistBlock("CN100ESR")
Local aRet       := {}
Local nx         := 0
Local oGSTmpTbl	:= Nil
Local aIdx			:= {}

If ExistBlock("CNTRETPR")
	cTpPref := If(ValType(cNewPref:=ExecBlock("CNTRETPR",.F.,.F.))=="C",PADR(cNewPref,Len(SE2->E2_PREFIXO)),cTpPref)
EndIf

If !CN240VldUsr(CN9->CN9_NUMERO,DEF_TRARET,.T.)
	lRet := .F.
EndIf

//Veririca se o contrato possui configuração de caução de retenção
If !(CN9->CN9_FLGCAU == "1" .And. CN9->CN9_TPCAUC == "2")
	lRet := .F.
EndIf


cEspCtr := CN9->CN9_ESPCTR

If lRet

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nao executa processo de estorno padrao quando o PE CN100ESR ³
	//³estiver compilado                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lCN100EsRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria Dialog para selecao do titulo                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0148) From 74,7 TO 320,500 PIXEL//"Estorno de Baixa de Retenção - Títulos de Retenção do Contrato"

		If cEspCtr == "1"
			aAdd(aStruTit,{"E2_NUM","C",TamSX3("E2_NUM")[1],TamSX3("E2_NUM")[2]})
			aAdd(aStruTit,{"E2_VALOR","N",TamSX3("E2_VALOR")[1],TamSX3("E2_VALOR")[2]})
			aAdd(aStruTit,{"E2_TIPO","C",TamSX3("E2_TIPO")[1],TamSX3("E2_TIPO")[2]})
			Aadd(aIdx, {"01",{"E2_NUM", "E2_TIPO"}})
		Else
			aAdd(aStruTit,{"E1_NUM","C",TamSX3("E1_NUM")[1],TamSX3("E1_NUM")[2]})
			aAdd(aStruTit,{"E1_VALOR","N",TamSX3("E1_VALOR")[1],TamSX3("E1_VALOR")[2]})
			aAdd(aStruTit,{"E1_TIPO","C",TamSX3("E1_TIPO")[1],TamSX3("E1_TIPO")[2]})
			Aadd(aIdx, {"01",{"E1_NUM", "E1_TIPO"}})
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria arquivo temporario                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		oGSTmpTbl := GSTmpTable():New("TRBTIT", aStruTit, aIdx,,1)
		oGSTmpTbl:CreateTMPTable()

		CN100TrbTit(CN9->CN9_NUMERO,cEspCtr,cTpPref,@oGSTmpTbl)

		oGSTmpTbl:SetProp("POS_DATA", 1)

		oGSTmpTbl:Commit()
		TRBTIT->(dbGoTop())

		If cEspCtr == "1"
			aTitle  := {"",RetTitle("E2_NUM"),RetTitle("E2_VALOR"),RetTitle("E2_TIPO")} 
			aCampos := {"",TRBTIT->E2_NUM,TRBTIT->E2_VALOR,TRBTIT->E2_TIPO}
			cLine   := "{If((cNumTit==(TRBTIT->E2_NUM)),oOk,oNo),TRBTIT->E2_NUM,Transform(TRBTIT->E2_VALOR,PesqPict('SE2','E2_VALOR')),TRBTIT->E2_TIPO}"

			oBrowse := TWBrowse():New( 4, 4,__DlgWidth(oDlg)-5,__DlgHeight(oDlg)-30, {|| {aCampos} },aTitle,{030,090},oDlg,,,,,,,,,,,,,"TRBTIT", .T. )
			oBrowse:bLine := &( "{ || " + cLine + " }" )
			oBrowse:bLDblClick := {|| If(!Empty(TRBTIT->E2_NUM),((cNumTit := TRBTIT->E2_NUM), oBrowse:Refresh()),) }
		Else
			aTitle  := {"",RetTitle("E1_NUM"),RetTitle("E1_VALOR"),RetTitle("E1_TIPO")}
			aCampos := {"",TRBTIT->E1_NUM,TRBTIT->E1_VALOR,TRBTIT->E1_TIPO}
			cLine   := "{If((cNumTit==(TRBTIT->E1_NUM)),oOk,oNo),TRBTIT->E1_NUM,Transform(TRBTIT->E1_VALOR,PesqPict('SE1','E1_VALOR')),TRBTIT->E1_TIPO}"

			oBrowse := TWBrowse():New( 4, 4,__DlgWidth(oDlg)-5,__DlgHeight(oDlg)-30, {|| {aCampos} },aTitle,{030,090},oDlg,,,,,,,,,,,,,"TRBTIT", .T. )
			oBrowse:bLine := &( "{ || " + cLine + " }" )
			oBrowse:bLDblClick := {|| If(!Empty(TRBTIT->E1_NUM),((cNumTit := TRBTIT->E1_NUM), oBrowse:Refresh()),) }
		EndIf

		DEFINE SBUTTON FROM __DlgHeight(oDlg)-24,__DlgWidth(oDlg)-70 When .T. TYPE 1 ACTION (if(Empty(cNumTit),Aviso(STR0088,STR0149,{"OK"}),(oDlg:End(),nOpca:=1))) ENABLE OF oDlg//"Não há títulos selecionados para estorno."
		DEFINE SBUTTON FROM __DlgHeight(oDlg)-24,__DlgWidth(oDlg)-30 When .T. TYPE 2 ACTION (oDlg:End(),nOpca:=2) ENABLE OF oDlg

		ACTIVATE MSDIALOG oDlg CENTERED

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Apaga arquivo temporario                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TRBTIT->(dbCloseArea())
		oGSTmpTbl:Close()
		TecDestroy(oGSTmpTbl)


		If nOpca == 1 .And. !Empty(cNumTit)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ CNY - Baixas de Retencao             				 		 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("CNY")

			cAliasQry := GetNextAlias()

			cQuery := "SELECT CNY.*, CNY.R_E_C_N_O_ as RECNO "
			cQuery += "  FROM "+RetSQLName("CNY")+" CNY "
			cQuery += " WHERE CNY.CNY_FILIAL = '"+xFilial("CNY")+"'"
			cQuery += "   AND CNY.CNY_NUMTIT = '"+cNumTit+"'"
			cQuery += "   AND CNY.CNY_PREFIX = '"+cTpPref+"'"
			cQuery += "   AND "
			If cEspCtr == "1"
				cQuery += "CNY.CNY_CLIENT = '' AND "
			Else
				cQuery += "CNY.CNY_FORNEC = '' AND "
			EndIf
			cQuery += "CNY.D_E_L_E_T_ = ' '"

			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

			TCSetField(cAliasQry,"CNY_VLBAIX" ,"N",TamSX3("CNY_VLBAIX")[1],TamSX3("CNY_VLBAIX")[2])

			If !(cAliasQry)->(Eof())
				//Armazena informacoes do titulo a deletar
				cRetPrf := (cAliasQry)->CNY_PREFIX
				cParcela:= (cAliasQry)->CNY_PARCEL
				cTpTit  := (cAliasQry)->CNY_TIPO
				If cEspCtr == "1"
					cForn   := (cAliasQry)->CNY_FORNEC
					cLoja   := (cAliasQry)->CNY_LOJA
				Else
					cClient := (cAliasQry)->CNY_CLIENT
					cLjCli  := (cAliasQry)->CNY_LOJACL
				EndIf

				While !(cAliasQry)->(Eof())

					//Apaga registro de baixa da retencao
					CNY->(dbGoTo((cAliasQry)->RECNO))
					RecLock("CNY",.F.)
						dbDelete()
					MsUnlock()

					//Devolve o saldo no registro de caucoes retidas
					DbSelectArea("CNT")
					DbSetOrder(1)
					If DbSeek(xFilial("CNT")+CN9->CN9_NUMERO+(cAliasQry)->CNY_NUMMED)
						RecLock("CNT",.F.)
							CNT->CNT_DTBX := CTOD("  /  /  ")
							CNT->CNT_VLBX := CNT->CNT_VLBX - (cAliasQry)->CNY_VLBAIX
						MsUnLock()
					EndIf

					(cAliasQry)->(DbSkip())
				EndDo
				(cAliasQry)->(dbCloseArea())

				//Apaga o tiulo estornado no financeiro
				If cEspCtr == "1"
					DbSelectArea("SE2")
					DbSetOrder(1)
					If DbSeek(xFilial("SE2")+cRetPrf+cNumTit+cParcela+cTpTit+cForn+cLoja)
						RecLock("SE2",.F.)
							DbDelete()
						MsUnLock()
					EndIf
				Else
					DbSelectArea("SE1")
					DbSetOrder(2)
					If DbSeek(xFilial("SE1")+cClient+cLjCli+cRetPrf+cNumTit+cParcela+cTpTit)
						RecLock("SE1",.F.)
							DbDelete()
						MsUnLock()
					EndIf
				EndIf

				Aviso(STR0152,OemToAnsi(STR0150)+cNumTit+OemToAnsi(STR0151),{"OK"})//"Estorno de Baixa de Retenção"//"O título "######" foi estornado com sucesso."
			EndIf
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Retorno esperado do PE:                                                   ³
		//³ aRet[1] - Informa se o estorno foi realizado com sucesso                  ³
		//³ aRet[2] - Array contendo as retencoes estornadas, e os respectivos valores³
		//³   aRet[2,1] - Array contendo o codigo da primeira retencao e o valor      ³
		//³     aRet[2,1,1] - Contem o codigo da medicao                              ³
		//³     aRet[2,1,2] - Contem o valor estornado                                ³
		//³   aRet[2,2] - Array contendo o codigo da segunda retencao e o valor       ³
		//³     aRet[2,2,1] - Contem o codigo da medicao                              ³
		//³     aRet[2,2,2] - Contem o valor estornado                                ³
		//³   ...                                                                     ³
		//³   aRet[2,x] - Estrutura criada para cada retencao estornada               ³
		//³     aRet[2,x,1] - Contem o codigo da medicao                              ³
		//³     aRet[2,x,2] - Contem o valor estornado                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRet := ExecBlock("CN100ESR",.F.,.F.)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o retorno  		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If valtype(aRet) == "A" .And. len(aRet) == 2
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o estorno foi realizado com sucesso ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If valtype(aRet[1]) == "L"
				lRet := aRet[1]
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza as retencoes que foram estornadas no PE³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet .And. valtype(aRet[2]) == "A"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Percorre as retencoes ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nx:=1 to len(aRet[2])
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Valida o retorno do PE³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If len(aRet[2,nx]) == 2 .And. valtype(aRet[2,nx,1]) == "C" .And. valtype(aRet[2,nx,2]) == "N"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Posiciona na retencao e executa o estorno do valor ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("CNT")
						DbSetOrder(1)
						If DbSeek(xFilial("CNT")+CN9->CN9_NUMERO+aRet[2,nx,1])
							RecLock("CNT",.F.)
								CNT->CNT_DTBX := CTOD("  /  /  ")
								CNT->CNT_VLBX := 0
							MsUnLock()
						EndIf
						DbSelectArea("CNY")
						CNY->(DbSetOrder(1))
						If CNY->(DbSeek(xFilial("CNY")+aRet[2,nx,1]))
							RecLock("CNY",.F.)
							CNY->(DbDelete())
							CNY->(MsUnLock())
						Endif
					EndIf
				Next
			EndIf
		EndIf
	EndIf
Else
	Aviso(STR0088,STR0112,{"OK"})//"O contrato selecionado não possui caução de retenção."
EndIf

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100TrbTit³ Autor ³ Felipe Bittar        ³ Data ³ 06/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega arquivo de trabalho com os titulos de retencao do  ³±±
±±³          ³ contrato                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100TrbTit(cContra,cEspCtr,cTpPref,oGSTmpTbl)

Local cAlias
Local cTpTit := ""
Local cQuery := ""

Local aArea  := GetArea()
Default oGSTmpTbl := Nil

If cEspCtr == "1"

	cTpTit := PadR( GetNewPar( "MV_CNRETTC",  "NDF" ), Len( SE2->E2_TIPO ) )//Tipo do titulo - PADRAO: Nota de Debito ao Fornecedor

	dbSelectArea("SE2")
	dbSetOrder(1)
	cAlias := GetNextAlias()
	cQuery := "SELECT SE2.E2_NUM, SE2.E2_VALOR, SE2.E2_TIPO, SE2.E2_MDCONTR "
	cQuery += "  FROM "+RetSQLName("SE2")+" SE2 "
	cQuery += " WHERE SE2.E2_FILIAL  = '"+xFilial("SE2")+"'"
	cQuery += "   AND SE2.E2_MDCONTR = '"+cContra+"'"
	cQuery += "   AND SE2.E2_TIPO    = '"+cTpTit+"'"
	cQuery += "   AND SE2.E2_PREFIXO = '"+cTpPref+"'"
	cQuery += "   AND SE2.E2_VALOR   = SE2.E2_SALDO "
	cQuery += "   AND SE2.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY SE2.E2_NUM"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)

	TCSetField(cAlias,"E2_VALOR" ,"N",TamSX3("E2_VALOR")[1],TamSX3("E2_VALOR")[2])
Else
	cTpTit := PadR( GetNewPar( "MV_CNRETTV",  "NCC" ), Len( SE1->E1_TIPO ) )//Tipo do titulo - PADRAO: NCC

	dbSelectArea("SE1")
	dbSetOrder(2)
	cAlias := GetNextAlias()
	cQuery := "SELECT SE1.E1_NUM, SE1.E1_VALOR, SE1.E1_TIPO, SE1.E1_MDCONTR "
	cQuery += "  FROM "+RetSQLName("SE1")+" SE1 "
	cQuery += " WHERE SE1.E1_FILIAL  = '"+xFilial("SE1")+"'"
	cQuery += "   AND SE1.E1_MDCONTR = '"+cContra+"'"
	cQuery += "   AND SE1.E1_TIPO    = '"+cTpTit+"'"
	cQuery += "   AND SE1.E1_PREFIXO = '"+cTpPref+"'"
	cQuery += "   AND SE1.E1_VALOR   = SE1.E1_SALDO "
	cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY SE1.E1_NUM"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)

	TCSetField(cAlias,"E1_VALOR" ,"N",TamSX3("E1_VALOR")[1],TamSX3("E1_VALOR")[2])
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Copia titulos filtradas para arquivo temporario   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While (cAlias)->(!Eof())
		If cEspCtr == "1"
			oGSTmpTbl:Insert({{'E2_NUM', (cAlias)->E2_NUM},;
					  {'E2_VALOR', (cAlias)->E2_VALOR},;
					  {'E2_TIPO', (cAlias)->E2_TIPO}})

		Else
			oGSTmpTbl:Insert({{'E1_NUM', (cAlias)->E1_NUM},;
					  {'E1_VALOR', (cAlias)->E1_VALOR},;
					  {'E1_TIPO', (cAlias)->E1_TIPO}})
		EndIf
	(cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

RestArea(aArea)
Return

  /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CN100VldPla³ Autor ³Aline Sebrian Damasceno³Data  ³13/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o numero do contrato nas planilhas				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GCT                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100VldPla(aPlani)
Local lRet    := .T.
Local lConCNA := aScan(aPlani,{|x| AllTrim(x[2]) <> AllTrim(FwFldGet("CN9_NUMERO"))})<> 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se numero do contrato esta diferente ao da planilha    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lConCNA
	Help(" ",1,"CNTA100COP") //"Número do contrato cadastrado divergente da planilha."
	lRet := .F.
EndIf

Return lRet

  /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CN100VerNf ³ Autor ³Aline Sebrian Damasceno³Data  ³19/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se tem medicoes em aberto ou sem NF amarrada	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100LdAl(cExp01,cExp02)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Numero do Contrato                                ³±±
±±³          ³ cExp02 - Numero da Revisao do Contrato                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GCT                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100VerNf(cContra, cRevisa, cFilCtr)
	Local lRet      := .T.
	Local lCNVerNF  := (GetNewPar( "MV_CNVERNF" ,  "N" ) == "S")
	Local cQuery    := ''
	Local cAliasCNE := ''
	Local cPedidoGE := ''
	Local cEspCtr   := CN9->CN9_ESPCTR
	Default cFilCtr	:= cFilAnt

	If lCNVerNF

		cAliasCNE := GetNextAlias()

		If cEspCtr == "1"		
			cQuery += " SELECT CND.CND_DTFIM,CND.CND_FILMED,CNE_PEDIDO PEDIDO, ISNULL(C7_RESIDUO, ' ')  C7RESIDUO "
			cQuery += " FROM "+ RetSQLName("CNE")+" CNE "			
			
			cQuery += " INNER JOIN "+RetSQLName("CND")+" CND ON"
			cQuery += " (CND_FILIAL = CNE_FILIAL AND CND_CONTRA = CNE_CONTRA AND CND_REVISA = CNE_REVISA AND CND_NUMMED = CNE_NUMMED)"
			
			cQuery += " LEFT JOIN "+ RetSQLName("SC7") +" SC7 ON ("
			cQuery += " SC7.C7_FILIAL = '"+xFilial("SC7")+"'"
			cQuery += " AND CNE.CNE_PEDIDO = SC7.C7_NUM" 
			cQuery += "	AND	CNE_CONTRA = SC7.C7_CONTRA" 
			cQuery += "	AND	CNE_ITEM = SC7.C7_ITEMED"
			cQuery += " AND	CNE_REVISA = SC7.C7_CONTREV"
			cQuery += " AND	SC7.D_E_L_E_T_ = ' ')"
			
			cQuery += " WHERE CND.CND_FILCTR = '"+ cFilCtr + "'"//Necessario verificar CND_FILCTR p/ verificar medicoes em qlq filial
			cQuery += " AND CNE.CNE_CONTRA = '" +cContra+"'"
			cQuery += " AND CNE.CNE_REVISA = '" +cRevisa+"'"			
			cQuery += " AND CNE.CNE_PEDTIT = '1'
			cQuery += " AND CNE.CNE_QUANT > 0
			cQuery += " AND CNE.D_E_L_E_T_ = ' '"
			cQuery += " AND CND.D_E_L_E_T_ = ' '"
			
			cQuery += " UNION"
			
			cQuery += " SELECT CND.CND_DTFIM, CND.CND_FILMED, CXJ_NUMPED PEDIDO, ISNULL(C7_RESIDUO, ' ')  C7RESIDUO "
			cQuery += " FROM "+ RetSQLName("CNE")+" CNE "

			cQuery += " INNER JOIN "+RetSQLName("CND")+" CND ON"
			cQuery += " (CND_FILIAL = CNE_FILIAL AND CND_CONTRA = CNE_CONTRA AND CND_REVISA = CNE_REVISA AND CND_NUMMED = CNE_NUMMED)"

			cQuery += " INNER JOIN "+ RetSQLName("CXJ") +" CXJ ON("
			cQuery += " CXJ.CXJ_FILIAL  = '"+xFilial("CXJ")+"'"
			cQuery += " AND CXJ.CXJ_CONTRA  = CNE.CNE_CONTRA"
			cQuery += " AND CXJ.CXJ_REVGER  = CNE.CNE_REVISA"
			cQuery += " AND CXJ.CXJ_NUMMED  = CNE.CNE_NUMMED"
			cQuery += " AND CXJ.CXJ_NUMPLA  = CNE.CNE_NUMERO"
			cQuery += " AND	CXJ.D_E_L_E_T_  = ' ')"

			cQuery += " INNER JOIN "+ RetSQLName("SC7") +" SC7 ON("
			cQuery += " SC7.C7_FILIAL	= '"+xFilial("SC7")+"'"
			cQuery += " AND SC7.C7_NUM		= CXJ.CXJ_NUMPED"
			cQuery += " AND SC7.C7_CONTRA	= CXJ.CXJ_CONTRA"
			cQuery += " AND SC7.C7_CONTREV	= CXJ.CXJ_REVGER"
			cQuery += " AND SC7.C7_MEDICAO	= CXJ.CXJ_NUMMED"
			cQuery += " AND SC7.C7_PLANILH	= CXJ.CXJ_NUMPLA"
			cQuery += " AND SC7.C7_ITEMED 	= CXJ.CXJ_ITEMPL"
			cQuery += " AND	SC7.D_E_L_E_T_  = ' ')"
			
			cQuery += " WHERE CND.CND_FILCTR = '"+ cFilCtr + "'"//Necessario verificar CND_FILCTR p/ verificar medicoes em qlq filial
			cQuery += " AND CNE.CNE_CONTRA = '" +cContra+"'"
			cQuery += " AND CNE.CNE_REVISA = '" +cRevisa+"'"
			cQuery += "	AND CNE.CNE_PEDTIT = '1'
			cQuery += " AND CNE.CNE_QUANT > 0
			cQuery += " AND CNE.D_E_L_E_T_ = ' '"	
			cQuery += " AND CND.D_E_L_E_T_ = ' '"
		Else
			cQuery += " SELECT CND.CND_DTFIM, CND.CND_FILMED, CNE_PEDIDO PEDIDO, ISNULL(C6_BLQ, ' ') C6BLQ "
			cQuery += " FROM "+ RetSQLName("CNE")+" CNE "

			cQuery += " INNER JOIN "+RetSQLName("CND")+" CND ON"
			cQuery += " (CND_FILIAL = CNE_FILIAL AND CND_CONTRA = CNE_CONTRA AND CND_REVISA = CNE_REVISA AND CND_NUMMED = CNE_NUMMED)"
			
			cQuery += " LEFT JOIN "+ RetSQLName("SC5") +" SC5 ON("
			cQuery += " SC5.C5_FILIAL = '"+xFilial("SC5")+"'" 
			cQuery += " AND CNE.CNE_PEDIDO = SC5.C5_NUM" 
			cQuery += " AND CNE.CNE_CONTRA = SC5.C5_MDCONTR"
			cQuery += " AND CNE.CNE_NUMMED = SC5.C5_MDNUMED"
			cQuery += " AND CNE.CNE_NUMERO = SC5.C5_MDPLANI"
			cQuery += " AND	SC5.D_E_L_E_T_ = ' ')"
			
			cQuery += " LEFT JOIN "+  RetSQLName("SC6") +" SC6 ON("
			cQuery += " SC6.C6_FILIAL = SC5.C5_FILIAL" 
			cQuery += " AND SC5.C5_NUM = SC6.C6_NUM"
			cQuery += " AND CNE.CNE_ITEM = SC6.C6_ITEMED"
			cQuery += " AND	SC6.D_E_L_E_T_ = ' ')"
			
			cQuery += " WHERE CND.CND_FILCTR = '"+ cFilCtr + "'"//Necessario verificar CND_FILCTR p/ verificar medicoes em qlq filial
			cQuery += " AND CNE.CNE_CONTRA = '" +cContra+"'"
			cQuery += " AND CNE.CNE_REVISA = '" +cRevisa+"'"
			cQuery += "	AND CNE.CNE_PEDTIT = '1'
			cQuery += " AND CNE.CNE_QUANT > 0
			cQuery += " AND CNE.D_E_L_E_T_ = ' '"
			cQuery += " AND CND.D_E_L_E_T_ = ' '"
			
			cQuery += " UNION"
			
			cQuery += " SELECT CND.CND_DTFIM, CND.CND_FILMED, CXJ_NUMPED PEDIDO, ISNULL(C6_BLQ, ' ') C6BLQ  "
			cQuery += " FROM "+ RetSQLName("CNE")+" CNE "

			cQuery += " INNER JOIN "+RetSQLName("CND")+" CND ON"
			cQuery += " (CND_FILIAL = CNE_FILIAL AND CND_CONTRA = CNE_CONTRA AND CND_REVISA = CNE_REVISA AND CND_NUMMED = CNE_NUMMED)"
			
			cQuery += " INNER JOIN "+ RetSQLName("CXJ") +" CXJ ON("
			cQuery += " CXJ.CXJ_FILIAL  = '"+xFilial("CXJ")+"'"
			cQuery += " AND CXJ.CXJ_CONTRA  = CNE.CNE_CONTRA"
			cQuery += " AND CXJ.CXJ_REVGER  = CNE.CNE_REVISA"
			cQuery += " AND CXJ.CXJ_NUMMED  = CNE.CNE_NUMMED"
			cQuery += " AND CXJ.CXJ_NUMPLA  = CNE.CNE_NUMERO"	
			cQuery += " AND	CXJ.D_E_L_E_T_  = ' ')"
			
			cQuery += " INNER JOIN "+ RetSQLName("SC5") +" SC5 ON("
			cQuery += " SC5.C5_FILIAL		= '"+xFilial("SC5")+"'" 
			cQuery += " AND SC5.C5_NUM		= CXJ.CXJ_NUMPED" 
			cQuery += "	AND SC5.C5_MDCONTR	= CXJ.CXJ_CONTRA"
			cQuery += "	AND SC5.C5_MDNUMED	= CXJ.CXJ_NUMMED"
			cQuery += "	AND SC5.C5_MDPLANI	= CXJ.CXJ_NUMPLA"
			cQuery += " AND	SC5.D_E_L_E_T_ = ' ')"
			
			cQuery += " INNER JOIN "+  RetSQLName("SC6") +" SC6 ON("
			cQuery += " SC6.C6_FILIAL		= SC5.C5_FILIAL" 
			cQuery += "	AND SC6.C6_NUM 		= SC5.C5_NUM"
			cQuery += "	AND SC6.C6_ITEMED 	= CXJ.CXJ_ITEMPL"
			cQuery += " AND	SC6.D_E_L_E_T_ = ' ')"
			
			cQuery += " WHERE CND.CND_FILCTR = '"+ cFilCtr + "'"//Necessario verificar CND_FILCTR p/ verificar medicoes em qlq filial
			cQuery += " AND CNE.CNE_CONTRA = '" +cContra+"'"
			cQuery += " AND CNE.CNE_REVISA = '" +cRevisa+"'"
			cQuery += "	AND CNE.CNE_PEDTIT = '1'
			cQuery += " AND CNE.CNE_QUANT > 0
			cQuery += " AND CNE.D_E_L_E_T_ = ' '"	
			cQuery += " AND CND.D_E_L_E_T_ = ' '"			
		EndIf

		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cAliasCNE, .T., .T. )

		While !(cAliasCNE)->(Eof())
		
			If Empty((cAliasCNE)->PEDIDO) .Or. Empty((cAliasCNE)->CND_DTFIM)
				lRet:= .F.
				Help(" ",1,"CN100VERNF",,STR0156,1,0)				
				Exit
			Else 
				cPedidoGE := (cAliasCNE)->PEDIDO
			Endif

			If 	(cEspCtr == "1" .And. (cAliasCNE)->C7RESIDUO == 'S') .Or.;//pedido com eliminação de rediduo não impede
				(cEspCtr == "2" .And. Alltrim((cAliasCNE)->C6BLQ) == 'R')

				(cAliasCNE)->(dbSkip())
				Loop
			EndIf

			If !Empty((cAliasCNE)->CND_FILMED)//Se CND_FILMED vazio, não há como saber a filial que se deve buscar a NF
				If cEspCtr == "1"
					cAliasSD1 := GetNextAlias()
					
					cQuery := "SELECT D1_PEDIDO "
					cQuery += "  FROM "+ RetSQLName("SD1")+" SD1 "
					cQuery += " WHERE SD1.D1_FILIAL  = '" +xFilial("SD1", (cAliasCNE)->CND_FILMED)+"'"
					cQuery += "   AND SD1.D1_PEDIDO  = '" +cPedidoGE+ "'"
					cQuery += "   AND SD1.D_E_L_E_T_ = ' '"

					cQuery := ChangeQuery( cQuery )
					dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cAliasSD1, .T., .T. )

					If (cAliasSD1)->(Eof())					
						Help(" ",1,"CN100VERNF",,STR0157,1,0)
						lRet := .F.
						Exit
					EndIf

					(cAliasSD1)->( dbCloseArea() )
				Else
					cAliasSD2 := GetNextAlias()
					cQuery := "SELECT D2_PEDIDO "
					cQuery += "  FROM "+ RetSQLName("SD2")+" SD2 "
					cQuery += " WHERE SD2.D2_FILIAL  = '" +xFilial("SD2", (cAliasCNE)->CND_FILMED)+"'"
					cQuery += "   AND SD2.D2_PEDIDO  = '" +cPedidoGE+ "'"
					cQuery += "   AND SD2.D_E_L_E_T_ = ' '"

					cQuery := ChangeQuery( cQuery )
					dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cAliasSD2, .T., .T. )

					If (cAliasSD2)->(Eof())					
						Help(" ",1,"CN100VERNF",,STR0158,1,0)
						lRet := .F.
						Exit
					EndIf

					(cAliasSD2)->( dbCloseArea() )
				EndIf				
			EndIf
			(cAliasCNE)->( dbSkip() )
		EndDo
		(cAliasCNE)->( dbCloseArea() )
	EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CN100JOB   ³ Autor ³Andre Lago			 ³Data  ³28/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executada atraves de JOB para transferir para situacao  	  ³±±
±±³			 ³ vigente de acordo com a data de vigencia futura			  ³±±
±±³			 ³ CN9_DTVIGE												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GCT                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100JOB()

	Local lMedeve
	Local lValor
	Local lCaucao
	Local lFisico
	Local lFixo
	Local lContab
	Local nPCauc := 0
	Local cFilCod := ""
	Local lRet := .T.
	Local nMotPlanF := 0
	Local nMotPlanC	:= 0
	Local nTotPlan := 0
	Local nMotCron := 0
	Local nMotCauc := 0
	Local nMotCrCt := 0
	Local cQuery := ""
	Local cAliasQry := ""
	Local aEmpresas := {}
	Local nx
	Local cLctoVige := "694"
	Local cLctoPlan := "69I"
	 	
	mv_par02 := 2 //Mostra Lancamentos S/N

	OpenSm0()
	While SM0->(!Eof())
		Aadd(aEmpresas, { SM0->M0_CODIGO, SM0->M0_CODFIL } )
		SM0->(DbSkip())
	EndDo
	nLen := Len(aEmpresas)

	For nX := 1 To nLen
		// Preparar ambiente
	   	RpcSetType(3) //para nao usar licenca.
	   	RpcSetEnv(aEmpresas[nX,1],aEmpresas[nX,2],,'GCT')
		
		//Inicio do processamento
		dDataAssi := dDataBase

		dbSelectArea("CN9")
		dbSetOrder(1)
		dbGoTop()

		While !Eof()
			lRet := .T.

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica situação atual do contrato                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (AllTrim(CN9->CN9_SITUAC) == DEF_SELAB .Or. AllTrim(CN9->CN9_SITUAC) == DEF_SEMIT .Or. AllTrim(CN9->CN9_SITUAC) == DEF_SAPRO) .and. !Empty(CN9->CN9_DTVIGE) .and. CN9->CN9_DTVIGE <= dDataBase + 1
				//Medicao Eventual
				lMedeve := Cn300RetSt('MEDEVE',2)

				//Previsao Financeira
				lValor :=  Cn300RetSt("PREVFINANC",2)

				//Controla ou nao caucao
				lCaucao := (CN9->CN9_FLGCAU == "1" .And. CN9->CN9_TPCAUC == "1")

				//Controla ou nao cronograma fisico
				lFisico := Cn300RetSt('CROFIS',2)

				//Controla ou nao planilhas
				lFixo := Cn300RetSt('FIXO',2)

				//Controla ou nao contabil
				lContab := Cn300RetSt('CONTABIL',2)

				If lCaucao
					nPCauc := CN9->CN9_MINCAU//Percentual minimo de caucao
				EndIf

				If lFixo
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica planilhas do contrato                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("CNA")
					dbSetOrder(1)
					cFilCod := xFilial("CNA")
					dbSeek(cFilCod+CN9->CN9_NUMERO+CN9->CN9_REVISA)

					While CNA->CNA_FILIAL = cFilCod .And. CNA->CNA_CONTRA = CN9->CN9_NUMERO .And. CNA->CNA_REVISA = CN9->CN9_REVISA
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica cronograma da planilha se o contrato      ³
						//³ nao for de medicao eventual e nao for recorrente   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !lMedeve .And. Empty(CNA->CNA_CRONOG) .And. Empty(CNA->CNA_PERIOD)
							FwLogMsg("INFO", , "", "CNTA100", "", "01", STR0036 + " " + CN9->CN9_NUMERO + " " + STR0037 + " " + CN9->CN9_REVISA, 0, -1, {})//"Contrato " ## "Revisao"
							FwLogMsg("INFO", , "", "CNTA100", "", "01", "Help CNTA100PLA - "+STR0024, 0, -1, {})//"Todas as planilhas devem pertencer a um cronograma"

							lRet := .F.
							Exit
						Else
							//Soma montante das planilhas
							If !Cn300RetSt('CROFIS',0,CNA->CNA_NUMERO)
								nMotPlanF+=CNA->CNA_VLTOT
							Endif
							If Cn300RetSt('CONTABIL',0,CNA->CNA_NUMERO)
								nMotPlanC+=CNA->CNA_VLTOT
							Endif
						EndIf
						nTotPlan++
						dbSkip()
					EndDo
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se o contrato possui planilhas            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lRet .And. nTotPlan == 0 .and. lFixo
					FwLogMsg("INFO", , "", "CNTA100", "", "01", STR0036 + " " + CN9->CN9_NUMERO + " " + STR0037 + " " + CN9->CN9_REVISA, 0, -1, {})//"Contrato" ## "Revisao"
					FwLogMsg("INFO", , "", "CNTA100", "", "01", "Help CNTA100POP - "+STR0025, 0, -1, {})//O contrato nao possui planilhas"
					lRet := .F.
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica cronogramas se nao for medicao eventual   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				if lRet .And. !lMedeve

					If !lFisico
						dbSelectArea("CNF")
						dbSetOrder(2)
						cFilCod := xFilial("CNF")
						dbSeek(cFilCod+CN9->CN9_NUMERO+CN9->CN9_REVISA)

						while CNF->CNF_FILIAL = cFilCod .And. CNF->CNF_CONTRA = CN9->CN9_NUMERO .And. CNF->CNF_REVISA = CN9->CN9_REVISA
							//Soma montante dos cronogramas
							nMotCron+=CNF->CNF_VLPREV
							dbSkip()
						EndDo

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Arredonda valores totais de cronograma e planilha    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nMotCron := Round(nMotCron,TamSX3("CNF_VLPREV")[2])
						nMotPlanF := Round(nMotPlanF,TamSX3("CNA_VLTOT")[2])
						nMotPlanC := Round(nMotPlanC,TamSX3("CNA_VLTOT")[2])
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica montante dos cronogramas contra montante    ³
						//³ das planilhas                                        ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nMotPlanF != nMotCron
							FwLogMsg("INFO", , "", "CNTA100", "", "01", STR0036 + " " + CN9->CN9_NUMERO + " " + STR0037 + " " + CN9->CN9_REVISA, 0, -1, {})//"Contrato" ## "Revisao"
							FwLogMsg("INFO", , "", "CNTA100", "", "01", "Help CNTA100MON - "+STR0168, 0, -1, {})//"O montante das planilhas nao equivale ao montante dos cronogramas"
							lRet := .F.
						EndIf
					Else
						cAliasQry := GetNextAlias()

						cQuery := "SELECT CNS.CNS_CONTRA,CNS.CNS_REVISA,CNS.CNS_PLANI,CNS.CNS_ITEM,SUM(CNS.CNS_PRVQTD) AS CNS_PRVQTD "
						cQuery += "  FROM "+ RetSQLName("CNS") +" CNS "
						cQuery += " WHERE CNS.CNS_FILIAL = '"+xFilial("CNS")+"'"
						cQuery += "   AND CNS.CNS_CONTRA = '"+CN9->CN9_NUMERO+"'"
						cQuery += "   AND CNS.CNS_REVISA = '"+CN9->CN9_REVISA+"'"
						cQuery += "   AND CNS.D_E_L_E_T_ = ' ' "
						cQuery += " GROUP BY CNS.CNS_CONTRA,CNS.CNS_REVISA,CNS.CNS_PLANI,CNS.CNS_ITEM"

						cQuery := ChangeQuery( cQuery )
						dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cAliasQry, .T., .T. )

						TCSetField( cAliasQry, "CNS_PRVQTD", "N", TamSX3("CNS_PRVQTD")[1], TamSX3("CNS_PRVQTD")[2] )

						dbSelectArea("CNB")
						dbSetOrder(1)

						cFilCod := xFilial("CNB")
						While !(cAliasQry)->(Eof())
							If dbSeek(cFilCod+(cAliasQry)->CNS_CONTRA+(cAliasQry)->CNS_REVISA+(cAliasQry)->CNS_PLANI+(cAliasQry)->CNS_ITEM)
								If CNB->CNB_QUANT != (cAliasQry)->CNS_PRVQTD
									lRet := .F.
									FwLogMsg("INFO", , "", "CNTA100", "", "01", STR0036 + " " + CN9->CN9_NUMERO + " " + STR0037 + " " + CN9->CN9_REVISA, 0, -1, {})//"Contrato" ## "Revisao"
									FwLogMsg("INFO", , "", "CNTA100", "", "01", STR0088, 0, -1, {})//"Atencao !"
									FwLogMsg("INFO", , "", "CNTA100", "", "01", STR0143+(cAliasQry)->CNS_ITEM+STR0144+(cAliasQry)->CNS_PLANI+STR0145, 0, -1, {})//"O item " ## " da planilha " ## " possui saldo em aberto para distribuição no cronograma físico."
									Exit
								EndIf
							EndIf
							(cAliasQry)->(dbSkip())
						EndDo
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica caucoes quando houver controle              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lRet .And. lCaucao
					dbSelectArea("CN8")
					dbSetOrder(2)
					cFilCod := xFilial("CN8")
					dbSeek(cFilCod+CN9->CN9_NUMERO+CN9->CN9_REVISA)

					While CN8->CN8_FILIAL = cFilCod .And. CN8->CN8_CONTRA = CN9->CN9_NUMERO .And. CN8->CN8_REVISA = CN9->CN9_REVISA
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Soma montante das caucoes quando nao estiver baixada ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Empty(CN8_DTBX)
							nMotCauc+=CN8->CN8_VLEFET
						EndIf
						dbSkip()
					EndDo

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica percentual minimo de caucao                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nMotCauc < NoRound((CN9->CN9_VLINI*nPCauc)/100,MsDecimais())
						FwLogMsg("INFO", , "", "CNTA100", "", "01", STR0036 + " " + CN9->CN9_NUMERO + " " + STR0037 + " " + CN9->CN9_REVISA, 0, -1, {})//"Contrato" ## "Revisao"
						FwLogMsg("INFO", , "", "CNTA100", "", "01", "Help CNTA100MIN - "+STR0027, 0, -1, {})//"O contrato nao possui o percentual minimo de caucao especificado"
						lRet := .F.
					EndIf
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica valor inicial do contrato se ele for do tipo flexivel e possuir previsao financeira  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lRet .And. lMedeve .And. !lFixo .And. lValor
					If CN9->CN9_VLINI <= 0
						FwLogMsg("INFO", , "", "CNTA100", "", "01", STR0036 + " " + CN9->CN9_NUMERO + " " + STR0037 + " " + CN9->CN9_REVISA, 0, -1, {})//"Contrato" ## "Revisao"
						FwLogMsg("INFO", , "", "CNTA100", "", "01", STR0088, 0, -1, {})//"Atencao !"
						FwLogMsg("INFO", , "", "CNTA100", "", "01", STR0146, 0, -1, {})//"O tipo de Contrato selecionado não permite vigência com valor inicial zerado!"
						lRet := .F.
					EndIf
				EndIf
			Else
				lRet := .F.
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica configuracao contabil das planilhas         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet .And. lContab
				cQuery := "SELECT CNA.CNA_NUMERO "
				cQuery += "  FROM "+ RetSQLName("CNA") +" CNA "
				cQuery += " WHERE CNA.CNA_FILIAL = '"+xFilial("CNA")+"'"
				cQuery += "   AND CNA.CNA_CONTRA = '"+CN9->CN9_NUMERO+"'"
				cQuery += "   AND CNA.CNA_REVISA = '"+CN9->CN9_REVISA+"'"
				cQuery += "   AND CNA.CNA_CRONCT = '' "
				cQuery += "   AND D_E_L_E_T_     = ' '"

				cAliasQry := GetNextAlias()

				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

				If !(cAliasQry)->(Eof())
					FwLogMsg("INFO", , "", "CNTA100", "", "01", STR0036 + " " + CN9->CN9_NUMERO + " " + STR0037 + " " + CN9->CN9_REVISA, 0, -1, {})//"Contrato" ## "Revisao"
					FwLogMsg("INFO", , "", "CNTA100", "", "01", STR0088, 0, -1, {})//"Atencao !"
					FwLogMsg("INFO", , "", "CNTA100", "", "01", STR0135+(cAliasQry)->CNA_NUMERO+STR0136, 0, -1, {})//"A planilha " ## " não possui cronograma contábil"
					lRet := .F.
				EndIf
				(cAliasQry)->(dbCloseArea())

				If lRet
					//Verifica montante das planilhas com o montante dos cronogramas contabeis
					cQuery := "SELECT SUM(CNW_VLPREV) as CNW_VLPREV "
					cQuery += "  FROM "+ RetSQLName("CNW")+" CNW,"+ RetSQLName("CNV")+" CNV,"+ RetSQLName("CNA")+" CNA "
					cQuery += " WHERE CNW.CNW_FILIAL = '"+xFilial("CNW")+"'"
					cQuery += "   AND CNV.CNV_FILIAL = '"+xFilial("CNV")+"'"
					cQuery += "   AND CNA.CNA_FILIAL = '"+xFilial("CNA")+"'"
					cQuery += "   AND CNW.CNW_CONTRA = '"+CN9->CN9_NUMERO+"'"
					cQuery += "   AND CNW.CNW_REVISA = '"+CN9->CN9_REVISA+"'"
					cQuery += "   AND CNW.CNW_CONTRA = CNV.CNV_CONTRA "
					cQuery += "   AND CNW.CNW_REVISA = CNV.CNV_REVISA "
					cQuery += "   AND CNW.CNW_NUMERO = CNV.CNV_NUMERO "
					cQuery += "   AND CNV.CNV_CONTRA = CNA.CNA_CONTRA "
					cQuery += "   AND CNV.CNV_REVISA = CNA.CNA_REVISA "
					cQuery += "   AND CNV.CNV_PLANIL = CNA.CNA_NUMERO "
					cQuery += "   AND CNW.D_E_L_E_T_ = ' ' "
					cQuery += "   AND CNV.D_E_L_E_T_ = ' ' "
					cQuery += "   AND CNA.D_E_L_E_T_ = ' '"

					cAliasQry := GetNextAlias()

					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

		        	nMotCrCt := (cAliasQry)->CNW_VLPREV

		        	(cAliasQry)->(dbCloseArea())

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Arredonda valores dos cronogramas contabeis          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nMotCrCt := Round(nMotCrCt,TamSX3("CNW_VLPREV")[2])

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica montante dos cronogramas contra montante    ³
					//³ das planilhas                                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nMotPlanC != nMotCrCt
						FwLogMsg("INFO", , "", "CNTA100", "", "01", STR0036 + " " + CN9->CN9_NUMERO + " " + STR0037 + " " + CN9->CN9_REVISA, 0, -1, {})//"Contrato" ## "Revisao"
						FwLogMsg("INFO", , "", "CNTA100", "", "01", STR0088, 0, -1, {})//"Atencao !"
						FwLogMsg("INFO", , "", "CNTA100", "", "01", STR0147, 0, -1, {})//"O montante das planilhas não equivale ao montante dos cronogramas contábeis. Verifique a configuração contábil do contrato!"
						lRet := .F.
					EndIf
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa alteracao quando todas as validacoes estiverem OK ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Executa contabilizacao do contrato     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				CN100Contab(cLctoVige)
				
				//Chama a contabilização por item da planilha
				CN100ConIt( "69L" )
				
				if !Empty(CN9->CN9_DTASSI)
					dDataAssi := CN9->CN9_DTASSI
				EndIf

				If lFixo
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza data de aniversario dos itens com a data de      ³
					//³ assinatura                                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("CNB")
					dbSetOrder(1)
					cFilCod := xFilial("CNB")
					dbSeek(xFilial("CNB")+CN9->CN9_NUMERO+CN9->CN9_REVISA)

					While !CNB->(Eof()) .And. CNB->CNB_FILIAL == cFilCod .And. CNB->CNB_CONTRA == CN9->CN9_NUMERO .And. CNB->CNB_REVISA == CN9->CN9_REVISA
						RecLock("CNB")
						CNB->CNB_DTANIV := dDataAssi
						MsUnlock()
						CNB->(dbSkip())
					EndDo
				EndIf

				RecLock("CN9",.F.)
				CN9->CN9_SITUAC := DEF_SVIGE
				If Empty(CN9->CN9_DTASSI)
					CN9->CN9_DTASSI := dDataBase
				EndIf
				CN9->CN9_DTULST := dDataBase
				CN9->(MsUnlock())

				FwLogMsg("INFO", , "", "CNTA100", "", "01", STR0036 + " " + CN9->CN9_NUMERO + " " + STR0037 + " " + CN9->CN9_REVISA, 0, -1, {})//"Contrato" ## "Revisao"
				FwLogMsg("INFO", , "", "CNTA100", "", "01", STR0169+" - "+"CNTA100", 0, -1, {})//"Aviso"
				FwLogMsg("INFO", , "", "CNTA100", "", "01", STR0029, 0, -1, {})// "Situacao alterada com sucesso"
			EndIf

			//- Contabiliza planilhas nao recorrentes do contrato  ³
			dbSelectArea("CNA")
			CNA->(dbSetOrder(1))
			cFilCod := xFilial("CNA")
			dbSeek(cFilCod+CN9->CN9_NUMERO+CN9->CN9_REVISA)
			While CNA->CNA_FILIAL = cFilCod .And. CNA->CNA_CONTRA = CN9->CN9_NUMERO .And. CNA->CNA_REVISA = CN9->CN9_REVISA
				//- Verifica se planilha nao é recorrente    	       ³
				If Empty(CNA->CNA_PERIOD)
					CN100Contab(cLctoPlan)
				Endif
				CNA->(dbSkip())
			EndDo

			dbSelectArea("CN9")

			If lRet .And. !lMedeve .And. (GetNewPar( "MV_CNPROVI" ,  "S" ) == "S")
				CN100CTit(CN9->CN9_NUMERO,CN9->CN9_REVISA)
				CN100RecTi(cContra,cRevisa)
			EndIf

			CN9->(dbSetOrder(1))
			CN9->(dbSkip())

		EndDo

	Next nX
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN100VldFor³ Autor ³                       ³ Data ³01.06.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao generica de validacao                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100Valida()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100Valida(lCtrMvc)
Local lRet      := .T.
Local lInclui	:= .T.

Local lFlgCau	:= .F.
Local lFlgRej	:= .F.
Local nMinCau	:= 0
Local nIndice	:= 0
Local oModel	:= Nil

Default lCtrMVC	:= .F.

If lCtrMVC
	oModel 	:= FwModelActive()
	lInclui := oModel:GetOperation() == MODEL_OPERATION_INSERT
Else
	lInclui := INCLUI
EndIf

If lInclui
	lFlgCau := Iif(lCtrMVC,oModel:GetValue('CN9MASTER','CN9_FLGCAU'),M->CN9_FLGCAU) == "1"
	lFlgRej := Iif(lCtrMVC,oModel:GetValue('CN9MASTER','CN9_FLGREJ'),M->CN9_FLGREJ) == "1"
	nMinCau	:= Iif(lCtrMVC,oModel:GetValue('CN9MASTER','CN9_MINCAU'),M->CN9_MINCAU)
	nIndice	:= Iif(lCtrMVC,oModel:GetValue('CN9MASTER','CN9_INDICE'),M->CN9_INDICE)

	If lFlgCau .And. Empty(nMinCau)
		Help(" ",1,"CNTA100PER") //"Preencha o percentual minimo de caucao"
		lRet := .F.
	EndIf

	If lRet .And. lFlgRej .And. Empty(nIndice)
		Help(" ",1,"CNTA100IND") //"Preencha o indice de reajuste do contrato"
		lRet := .F.
	EndIf
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CN100CtrVg ³ Autor ³ Totvs               ³ Data ³01.09.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Altera situacao do contrato e grava data de assinatura nos ³±±
±±³          ³ itens do contrato                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CN100CtrVg()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±                                                                         ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100 / MATA097                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100CtrVg(lSitAprAlc)
	Local aArea		:= GetArea()
	Local dDataAssi	:= dDataBase
	Local dDtFim	:= ""
	Local lDtAssi		:= SuperGetMv("MV_GCTDTTR",.F.,.F.) // Calcula a data de término da vigência tendo como início a data de assinatura.

	Local oModel	:= Nil
	Local oModelCN9	:= Nil
	Local oModelCNA	:= Nil
	Local oModelCNB	:= Nil
	Local nX		:= 0
	Local nY		:= 0

	Default lSitAprAlc := .F.

	oModel := FWLoadModel(If(Cn300RetSt('COMPRA',,,,,.F.),"CNTA300","CNTA301"))
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	oModel:Activate()

	oModelCN9 := oModel:GetModel('CN9MASTER')
	oModelCNA := oModel:GetModel('CNADETAIL')
	oModelCNB := oModel:GetModel('CNBDETAIL')

	oModelCN9:LoadValue('CN9_SITUAC',IIf(lSitAprAlc,DEF_SAPRO,DEF_SVIGE))

	If !Empty(oModelCN9:GetValue('CN9_DTASSI'))
		dDataAssi := oModelCN9:GetValue('CN9_DTASSI')
	Else
		oModelCN9:LoadValue('CN9_DTASSI',dDataAssi)
	EndIf

	If lDtAssi
		dDtFim := CN100DtFim(oModelCN9:GetValue('CN9_UNVIGE'),oModelCN9:GetValue('CN9_DTINIC'),oModelCN9:GetValue('CN9_VIGE'))
		oModelCN9:LoadValue('CN9_DTFIM',dDtFim)
		
		For nX := 1 to oModelCNA:Length()
			oModelCNA:GoLine(nX)
			CN300TpPla( .F., oModel )//Libera os submodelos de acordo com o tipo de planilha, em tela isso é feito pelo changeLine da View
			oModelCNA:LoadValue('CNA_DTFIM',dDtFim)
			If Cn300RetSt('FIXO')				
				For nY := 1 To oModelCNB:Length()
					oModelCNB:GoLine(nY)
					oModelCNB:LoadValue('CNB_DTANIV',dDataAssi)
				Next nY
			EndIf
		Next nX
	EndIf

	FwMsgRun(Nil,{|| CnPimsChgS(oModel,FWFormCommit(oModel))},Nil,STR0199) //- "Aguarde, atualizando situação do contrato..." 

	oModel:DeActivate()
	RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CtrRevisa  ³ Autor ³Igor Franzoi           ³ Data ³11.07.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida se o contrato tem revisão em aberto				   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtrRevisa												   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtrRevisa( cFilCN9, cNumCN9, cRevCN9 )
Local aArea := GetArea()
Local lRet := .T.
Local cKeyPes := cFilCN9+cNumCN9
Local nOrdCN9 := RetOrdem( "CN9", "CN9_FILIAL+CN9_NUMERO+CN9_REVISA" )

dbSelectArea("CN9")
CN9->(dbSetOrder(nOrdCN9))

CN9->(dbSeek(cKeyPes))
While CN9->(!Eof() .and. CN9_FILIAL+CN9_NUMERO == cKeyPes)
	If !Empty(CN9->CN9_REVISA) .and. (CN9->CN9_SITUAC == '09' .Or. CN9->CN9_SITUAC == '11')
		lRet := .F.
		Exit
	EndIf
	CN9->(dbSkip())
EndDo

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CN100CanceºAutor  ³ Andre Anjos		 º Data ³  16/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que processa o encerramento de um contrato.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ lAviso: exibe confirmacao da alteracao da situacao.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNTA100                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CN100Cance(lAviso,lCtrApr,aRet)
Local aAreaAnt	:= GetArea()
Local aAux		:= {}
Local cAliasNew	:= ""
Local cQuery	:= ""
Local cSitAnt	:= " "
Local nRecCN9	:= 0
Local lRet      := .T.
Local lEstLiber := .F.
Local lMedeve	:= .F.

Local lReman	:= (ValType(aRet)=="A")

Local oModel	:= Nil

Default lAviso := .F.
Default lCtrApr:= .F.

SaveInter()

If CN100VerNf(CN9->CN9_NUMERO,CN9->CN9_REVISA)
	cSitAnt := CN9->CN9_SITUAC
	nRecCN9 := CN9->(Recno())
	If lReman
		RecLock("CN9",.F.)
		CN9->CN9_RESREM := "S"
		CN9->(MsUnlock())
	Else
		RecLock("CN9",.F.)
		CN9->CN9_SITUAC := DEF_SCANC
		CN9->CN9_DTULST := dDataBase
		CN9->(MsUnlock())
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Contabiliza a desativacao do contrato ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("CNT100",.F.)
	CN100Contab("696")

	//-- Posiciona planilhas para verificar tipo
	CNA->(dbSetOrder(1))//-- CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO
	CNA->(dBseek(xFilial("CNA")+CN9->(CN9_NUMERO+CN9_REVISA)))

	lMedeve := Cn300RetSt("MEDEVE",2)
	If !lMedeve .And. GetNewPar("MV_CNPROVI","S") == "S"
		MsAguarde({|| CN100ETit(CN9->CN9_NUMERO,CN9->CN9_REVISA)},STR0061)//"Estornando títulos"
	EndIf

	//-- Estorna controle de alcadas
	If lCtrApr
		SCR->(dbSetOrder(1))
		If SCR->(dbSeek(CnFilCtr(CN9->CN9_NUMERO)+"CR"+CN9->(CN9_NUMERO+CN9_REVISA)))
			lEstLiber := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_LIBAPRO,,},,5)
		EndIf
	EndIf
	
	//-Trecho adicionado para realizar commit no modelo para envio das informações de mensagem unica.
	oModel := FWLoadModel(If(Cn300RetSt('COMPRA',,,,,.F.),"CNTA300","CNTA301"))
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	oModel:Activate()
	FWFormCommit(oModel)
	oModel:DeActivate()
	
	If lAviso
		Aviso("CNTA100",OemtoAnsi(STR0029)+If(lEstLiber,CRLF+OemtoAnsi(STR0176),""),{"Ok"})// "Situacao alterada com sucesso" ## "Os documentos existentes na rotina de Liberação foram estornados automaticamente."
	EndIf
	
	//-- Processa a eliminacao de residuos do SC7
	If	lReman
		cAliasNew := GetNextAlias()
		cQuery := "SELECT SC7.R_E_C_N_O_ SC7RECNO, CNB.R_E_C_N_O_ CNBRECNO"
		cQuery += " FROM"
		cQuery += " "+RetSqlName('SC7')+" SC7"
		cQuery += " JOIN " +RetSqlName("CNB") +" CNB ON CNB.D_E_L_E_T_ <> '*' AND "

		cQuery += "	CNB.CNB_FILORI = '" +xFilial('CNB') +"' AND "

		cQuery += "	CNB.CNB_CONTRA = SC7.C7_CONTRA AND "
		cQuery += "	CNB.CNB_REVISA = SC7.C7_CONTREV AND "
		cQuery += "	CNB.CNB_NUMERO = SC7.C7_PLANILH AND "
		cQuery += "	CNB.CNB_ITEM   = SC7.C7_ITEMED AND "
		cQuery += "	CNB.CNB_SLDREC > 0 "
		cQuery += " WHERE"

		cQuery += "	C7_FISCORI = '"+xFilial("SC7")+"'"

		cQuery += " AND C7_CONTRA  = '"+CN9->CN9_NUMERO+"'"
		cQuery += " AND C7_CONTREV = '"+CN9->CN9_REVISA+"'"
		cQuery += " AND C7_QUANT - C7_QUJE > 0 "
		cQuery += " AND C7_RESREM <> 'S' "
		cQuery += " AND C7_RESIDUO <> 'S' "
		cQuery += " AND SC7.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)

		While (cAliasNew)->(!Eof())
			SC7->(DbGoTo((cAliasNew)->SC7RECNO))

			lRet := SC7->(MA235ElRes())

			//-- Restaura SCs vinculadas ao PC
			If	lRet

				RecLock("SC7",.F.)
				SC7->C7_RESREM := "S"
				SC7->(MsUnLock())

				If	Empty(aScan(aAux,{|x| x == (cAliasNew)->CNBRECNO}))
					CNB->(dbGoTo((cAliasNew)->CNBRECNO))
					aAdd(aRet,{lRet,CNB->CNB_PRODUTO,CNB->CNB_SLDREC,CNB->(CNB_NUMSC+CNB_ITEMSC),(cAliasNew)->CNBRECNO,cSitAnt,nRecCN9,CNB->CNB_GCPLT})
					aAdd(aAux,(cAliasNew)->CNBRECNO)
				EndIf

			EndIf

			(cAliasNew)->(DbSkip())
		EndDo

		DbSelectarea(cAliasNew)
		DbCloseArea()
		RestArea(aAreaAnt)
	EndIf
Else
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CN100SlFinºAutor  ³Microsiga           º Data ³  10/05/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que processa codigo referente a solicitacao de      º±±
±±º          ³ finalizacao de contrato.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNTA100                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CN100SlFin()
Local aAreaSE2   := SE2->(GetArea())
Local cFiltroSE2 := "SE2->E2_MDCONTR == '" +CN9->CN9_NUMERO +"' .AND. SE2->E2_TIPO == 'PR '"

// Deletar os titulos PR gerados na SE2
dbSelectArea("SE2")
SE2->(dbSetFilter({|| &(cFiltroSE2)},cFiltroSE2))
SE2->(dbGoTop())
While !SE2->(Eof())
	RecLock("SE2",.F.)
	SE2->(dbDelete())
	SE2->(MsUnlock())
	SE2->(dbSkip())
EndDo
SE2->(dbClearFilter())
RestArea(aAreaSE2)
Return

/*/{Protheus.doc} CN100ConIt
Função para chamada da contabilização por item de planilha do contrato, quando o mesmo se tornar vigente
ou quando o mesmo tiver uma revisão aprovada/desfeita  

@param cLpItem, Código do lançamento padrão a ser utilizado
@Return lRet, Indica se foi chamada a contabilização

@author pedro.alencar
@since 04/10/2018
/*/
Function CN100ConIt( cLpItem )
	Local lRet := .F.
	Local aAreaCNA := {}
	Local aAreaCNB := {}
	Local lPadrao := .F.
	Local cChaveCNA := ""
	Local cChaveCNB := ""
	Default cLpItem := "69L"
	
	lPadrao := VerPadrao( cLpItem )
	
	If lPadrao .And. MV_PAR01 == 1
		aAreaCNA := CNA->( GetArea() )
		cChaveCNA := FwxFilial("CNA") + CN9->CN9_NUMERO + CN9->CN9_REVISA
		
		CNA->( dbSetOrder( 1 ) ) //CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO		
		lRet := CNA->( MsSeek( cChaveCNA ) )
		If lRet
			aAreaCNB := CNB->( GetArea() )
			
			CNB->( dbSetOrder( 1 ) ) //CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM
			While CNA->( !EOF() ) .And. CNA->CNA_FILIAL + CNA->CNA_CONTRA + CNA->CNA_REVISA == cChaveCNA
				
				cChaveCNB := FwxFilial("CNB") + CNA->CNA_CONTRA + CNA->CNA_REVISA + CNA->CNA_NUMERO
				lRet := CNB->( MsSeek( cChaveCNB ) )
				If lRet
					While CNB->( !EOF() ) .And. CNB->CNB_FILIAL + CNB->CNB_CONTRA + CNB->CNB_REVISA + CNB->CNB_NUMERO == cChaveCNB
						//Chama a contabilização do LP 69L para cada item da NCB
						CN100Contab( cLpItem )
					
						CNB->( dbSkip() )
					EndDo
				EndIf
				
				CNA->( dbSkip() )
			EndDo
		
			RestArea( aAreaCNB )
		EndIf
				
		RestArea( aAreaCNA )	
	EndIf
	
	aSize( aAreaCNB, 0 )
	aAreaCNB := Nil
	aSize( aAreaCNA, 0 )
	aAreaCNA := Nil
Return lRet

/*/{Protheus.doc} CN100SitCtr
	Retorna a variável estática __cSitACtr(criada p/ integração EAI)
@author philipe.santos
@since 09/01/2019
@return caractere, situação anterior do contrato/*/
Function CN100SitCtr()	
Return __cSitACtr

/*/{Protheus.doc} CN100LStCt
	Limpa a variável estática __cSitACtr(criada p/ integração EAI)
@author philipe.santos
@since 09/01/2019/*/
Function CN100LStCt()
	__cSitACtr := ""
Return Nil

/*/{Protheus.doc} GrvVendTit
	Dado <aVend>, grava os vendedores no registro corrente da SE1
@author philipe.pompeu
@since 07/08/2020/*/
Static Function GrvVendTit(aVend)
	Local cVend	:="1"
	Local nX	:= 0
	For nx:=1 to len(aVend)
		SE1->&("E1_VEND"+cVend)  := aVend[nx,1]
		SE1->&("E1_COMIS"+cVend) := aVend[nx,2]
		SE1->&("E1_VALCOM"+cVend):= ((SE1->E1_VALOR * aVend[nx,2]) / 100)
		cVend:=Soma1(cVend)
	Next
Return

/*/{Protheus.doc} ProxNumTit
	Dado <cRetPrf>, busca pelo proximo numero disponivel para geracao do titulo
@author philipe.pompeu
@since 01/09/2020/*/
Static Function ProxNumTit(cRetPrf, lCompra, cFilCtr)
	Local cNumTit	:= ""
	Local cQuery 	:= ""
	Local cTitAlias	:= GetNextAlias()
	Local cTabela	:= ""
	Local cFilTab	:= ""
	Local aArea		:= {}
	Default lCompra := .T.
	Default cFilCtr	:= cFilAnt

	if lCompra//Seleciona sequencia dos titulos a pagar
		cTabela := "SE2"
		cQuery := "SELECT MAX(SE2.E2_NUM) as NUMTIT "
		cQuery += " FROM "+ RetSQLName("SE2") +" SE2 "
		cQuery += " WHERE SE2.E2_FILIAL  = '"+xFilial("SE2", cFilCtr)+"'"
		cQuery += "   AND SE2.E2_PREFIXO = '"+ cRetPrf +"'"
		cQuery += "   AND SE2.D_E_L_E_T_ = ' '"		
	Else//Seleciona sequencia dos titulos a receber
		cTabela := "SE1"
		cQuery := "SELECT MAX(SE1.E1_NUM) as NUMTIT "
		cQuery += "  FROM "+ RetSQLName("SE1") +" SE1 "
		cQuery += " WHERE SE1.E1_FILIAL  = '"+xFilial("SE1", cFilCtr)+"'"
		cQuery += "   AND SE1.E1_PREFIXO = '"+ cRetPrf +"'"
		cQuery += "   AND SE1.D_E_L_E_T_ = ' '"
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTitAlias,.F.,.T.)
	cNumTit := Soma1((cTitAlias)->NUMTIT)
	(cTitAlias)->(dbCloseArea())

	aArea	:= (cTabela)->(GetArea())
	cFilTab := xFilial(cTabela)	
	
	(cTabela)->(dbSetOrder(1))
	While (cTabela)->( dbSeek(cFilTab+cRetPrf+cNumTit) )//Verifica codigo disponivel
		cNumTit += Soma1(cNumTit)
	EndDo

	RestArea(aArea)
	FwFreeArray(aArea)
Return cNumTit

/*/{Protheus.doc} PegaMsErro
Pega mensagem de erro gerada pelo MSExecAuto e converte para string.
Antes de chamar esta função utilizar as variáveis privadas lAutoErrNoFile e lMsHelpAuto como .T. (apenas em execuções automáticas).
@author juan.felipe
@since 02/07/2021
@return cMsgErro, character, mensagem de erro.
/*/
Static Function PegaMsErro()
    Local aErroAuto As Array
    Local cMsgErro As Character
	Local nX As Numeric

	aErroAuto := GetAutoGRLog()
    cMsgErro := ""
    
    For nX := 1 To Len(aErroAuto)
        cMsgErro += aErroAuto[nX] + CRLF  
    Next nX

    FwFreeArray(aErroAuto)
Return cMsgErro

/*/{Protheus.doc} GetDtEmiPR
	Obtem a data de emissão do título provisório
@author philipe.pompeu
@since 06/06/2022
@param dVenciment	, date, vencimento do título
@param dAssina		, date, data assinatura do contrato
@param dRevisao		, date, data da revisão
return dEmissao, date, emissão do título PR
*/
Static Function GetDtEmiPR(dVenciment, dAssina, dRevisao)
	Local dEmissao as DATE
	If Empty(dRevisao) .Or. (dRevisao > dVenciment)
		dEmissao := dAssina
	Else
		dEmissao := dRevisao
	EndIf
Return dEmissao

/*/{Protheus.doc} CNVlDatFin
	Valida <dEmissao> com base no parâmetro MV_DATAFIN
@author philipe.pompeu
@since 06/06/2022
@param dEmissao	, date	, data a ser validada
@param lCnProvi	, lógico, se gera título provisório
return lResult	, lógico, se data é válida
*/
Function CNVlDatFin(dEmissao, lCnProvi)
	Local lResult	:= .T.
	Local dDtMinTit	:= CtoD("//")
	Default lCnProvi := SuperGetMV("MV_CNPROVI",.F.,"S") == "S"

	If (lCnProvi .And. !Empty(dEmissao))//Somente p/ titulos provisorios
		dDtMinTit	:= SuperGetMV("MV_DATAFIN",.F., dEmissao)
		dDtMinTit	:= IIF(ValType(dDtMinTit) == "D", dDtMinTit, dEmissao)
		If !(lResult := (dEmissao >= dDtMinTit)) //Verifica se a emissão é maior ou igual à data mínima
			Help(" ",1,"CNDATAFIN",,I18N(STR0221, {dEmissao, dDtMinTit}), 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0220})//Data #1 inferior a data #2
		EndIf
	EndIf
Return lResult

/*/{Protheus.doc} CNEXDatFin
	Verifica MV_DATAFIN na exclusão dos títulos provisórios
@author philipe.pompeu
@since 09/06/2022
@param cContra	, carectere	, numero do contrato
@param cFilCtr	, carectere, filial do contrato
return lResult	, lógico, se é possível realizar exclusão
*/
Function CNEXDatFin(cContra, cRevisa, cFilCtr)
	Local lResult	:= .T.
	Local cMyAlias	:= GetNextAlias()
	Local cFilCNF := xFilial("CNF", cFilCtr)

	BeginSql alias cMyAlias
		SELECT COUNT(CNF_PARCEL) TOTPARC
		FROM %table:CNF% CNF
		WHERE
		CNF_FILIAL = %Exp:cFilCNF%
		AND CNF_CONTRA = %Exp:cContra%
		AND CNF_REVISA = %Exp:cRevisa%
		AND CNF_SALDO > 0
		AND CNF.%notDel%
	EndSql

	If (cMyAlias)->(!Eof() .And. TOTPARC > 0)
		lResult := CNVlDatFin(dDatabase)
	EndIf

	(cMyAlias)->(dbCloseArea())
Return lResult

/*/{Protheus.doc} TotPRCtr
	Retorna o total de títulos provisórios de um contrato
@author philipe.pompeu
@since 29/09/2022
@param cFilCtr	, carectere	, filial do contrato
@param cContra	, carectere	, numero do contrato
@param cRevisa	, carectere	, revisão
@param cPlanilha, carectere	, planilha
@param lCompra	, lógico	, se é um contrato de compra
return nRestante, numérico	, numero de titulos PR
*/
Static Function TotPRCtr(cFilCtr, cContra, cRevisa, cPlanilha, lCompra)
	Local aArea     := GetArea()
	Local cQuery	:= ""
	Local cAliasTmp	:= GetNextAlias()
	Local nRestante := 0
	Local cTitAlias := IIF(lCompra, "SE2", "SE1")
	Local cPrefCpo	:= PrefixoCpo(cTitAlias)	

	cQuery := "SELECT COUNT("+cPrefCpo+"_MDPARCE) RESTANTE "
	cQuery += " FROM " + RetSQLName(cTitAlias) +" TBL "
	cQuery += " WHERE "	+cPrefCpo+"_FILIAL  = '" + xFilial(cTitAlias,cFilCtr) + "'"	
	cQuery += " AND "	+cPrefCpo+"_MDCONTR = '" + cContra   +"'"
	cQuery += " AND "	+cPrefCpo+"_MDREVIS = '" + cRevisa   +"'"
	cQuery += " AND "	+cPrefCpo+"_MDPLANI = '" + cPlanilha +"'"
	cQuery += " AND "	+cPrefCpo+"_TIPO = 'PR'"
	cQuery += " AND TBL.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),(cAliasTmp),.F.,.T.)

	nRestante := (cAliasTmp)->RESTANTE

	(cAliasTmp)->(dbCloseArea())

	RestArea(aArea)
	FwFreeArray(aArea)
return nRestante
