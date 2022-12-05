#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"

#DEFINE ALIGN_H_LEFT   	0
#DEFINE ALIGN_H_RIGHT  	1
#DEFINE ALIGN_H_CENTER 	2
#DEFINE oFontT 			TFont():New( "Verdana", , 16, , .T. )//Titulo
#DEFINE oFontS 			TFont():New( "Verdana", , 14, , .T. )//Sub-título
#DEFINE oFontS2			TFont():New( "Verdana", , 12, , .T. )//Sub-título 2
#DEFINE oFontC 			TFont():New( "Verdana", , 12, , .F. )//Corpo

Static lTemREQ
Static lSchedule    := .F.

User Function FERTAE()

Local aOrdem		:= {"Matricula", "C.Custo + Matric", "C.Custo + Nome", "Nome"}
Local nFlags   	 	:= PD_ISTOTVSPRINTER +  PD_DISABLEORIENTATION
Local cTitulo    	:= "Relatórios de Férias"
Local cDestino	 	:= ""
Local cUser     	:= AllTrim(SuperGetMv('MV_RHTAEUS',,""))
Local cPassword 	:= AllTrim(SuperGetMv('MV_RHTAEPW',,""))

Private cPerg      	:= "GPR1033"
Private cPathTmp	:= ""
Private nOrdem		:= 1
Private oProfile	:= FwProfile():New()
Private oPrinter
Private oSetup

DEFAULT lTemREQ     := ChkFile("REQ")

lSchedule 	:= IsBlind()

If !Empty(cUser) .And. !Empty(cPassword)
	If ("@" $ cUser)
		If lSchedule
			Conout('Acesse a opção "Config. Assina. Eletr." para configurar o usuário e senha de integração com o Totvs Assinatura Eletrônica')
		Else
			MsgAlert(OEMToAnsi('Acesse a opção "Config. Assina. Eletr." para configurar o usuário e senha de integração com o Totvs Assinatura Eletrônica'), "Atenção")
		EndIf
		Return
	Else
		cUser 		:= rc4crypt( cUser, "123456789", .F., .T.)
		cPassword 	:= rc4crypt( cPassword, "123456789", .F., .T.)
	EndIf
EndIf

If !lTemREQ
	If !lSchedule
		Aviso("Atenção", "Para execução dessa rotina deve ser executado o UPDDISTR para atualização do dicionário de dados do pacote com as implementações de assinatura eletrônica do RH", { "Ok" } )
	EndIf
	Return Nil
EndIf

oProfile:SetUser( RetCodUsr() )
oProfile:SetProgram( "FERTAE" )
oProfile:SetTask( "FERTAEVAR" )

cDestino := oProfile:LoadStrProfile()

If !lSchedule
	oSetup := FWPrintSetup():New(nFlags, cTitulo)
	oSetup:SetUserParms( {|| Pergunte(cPerg, .T.) } ) 
	oSetup:SetPropert(PD_PRINTTYPE   , 6)
	oSetup:SetPropert(PD_PREVIEW,.T.)
	oSetup:SetOrderParms(aOrdem,@nOrdem)

	oSetup:aOptions[PD_VALUETYPE] := cDestino

	If !(oSetup:Activate() == PD_OK)
		Return .T.
	EndIf

	oProfile:SetStringProfile( oSetup:aOptions[PD_VALUETYPE] )

	oProfile:Save()

	cPathTmp	:= GetTempPath(.T.)

	Pergunte(cPerg,.F.)
Else
	cPathTmp	:= Upper(GetPvProfString( GetEnvServer() , "StartPath" , "" , GetADV97() ) )
EndIf

MakeSqlExpr( cPerg ) //Transforma perguntas do tipo Range em expressao SQL

//A primeira pergunta é um checkbox com todas as opções disponíveis, na primeira versão apenas estará disponível aviso e recibo de férias, 
//porém o tratamento será feito prevendo o desenvolvimento dos demais tipos.
Private nAviso    := If("1" $ mv_par01,1,2)     //  Aviso de Ferias
Private nRecib    := If("2" $ mv_par01,1,2)     //  Recibo de Ferias
Private nSol13    := If("3" $ mv_par01,1,2)     //  SoLic. 1o. Parc. 13o.
Private nSolAb    := If("4" $ mv_par01,1,2)     //  SoLic. Abono Pecun.
Private nRecAb    := If("5" $ mv_par01,1,2)     //  Recibo de Abono
Private nRec13    := If("6" $ mv_par01,1,2)     //  Recibo 1¦ parc. 13o.
Private nDtRec    := mv_par02     				//  Imprime Periodo de Ferias
Private dDtfDe    := mv_par03     				//  Periodo de Ferias De
Private dDtfAte   := mv_par04     				//  Periodo de Ferias Ate
Private cFilRange := mv_par05     				//  Filial
Private cMatRange := mv_par06     				//  Matricula
Private cCcRange  := mv_par07     				//  Centro De Custo
Private cNomRange := mv_par08     				//  Nome 
Private dDtPgDe   := mv_par09     				//  Data de Pagamento De
Private dDtPgAte  := mv_par10     				//  Data de Pagamento Ate
Private nImprDem  := mv_par11     				//  Imprime demotidos?
Private nDBanco   := mv_par12     				//  Imprime dados bancários
Private lSomLiR   := mv_par13 == 1 				//  Informa se deve somar os dias de licença remunerada ao período de gozo das férias.
Private nTipRel   := mv_par14	    			//  Tipo do Relatório (1=Relatório/2=Integrar TAE)

//Assinatura Eletrônica
Private oSign
Private aLogTAE     := Array(4)
Private aLogTitle   := Array(4)

If lSchedule .and. nTipRel <> 2
	Conout("Apenas o envio do documento para o TAE esta disponível via Schedule")
	Return Nil
EndIf

aFill(aLogTitle, "")
aLogTAE[1] := {}
aLogTAE[2] := {}
aLogTAE[3] := {}
aLogTAE[4] := {}

If nTipRel == 1
	fMntPrinter(@oPrinter)
Else
	If FindFunction("FwTotvsSign")
		If Empty(SuperGetMv('MV_SIGNURL',,""))
			If lSchedule
				Conout("Não foi possível efetuar autenticação no TAE!")
				Conout("Verifique os parâmetros MV_SIGNURL, MV_RHTAEUS e MV_RHTAEPW")
			Else
				Help( ,, "Atenção",, "Não foi possível efetuar autenticação no TAE!" , 1,,,,,,, {"Verifique os parâmetros MV_SIGNURL, MV_RHTAEUS e MV_RHTAEPW"} )
			EndIf
			Return 
		EndIf
		oSign := FwTotvsSign()
		If !oSign:isAuthenticated()
			oSign:authenticate( cUser, cPassword )
			If !oSign:isAuthenticated()
				If lSchedule
					Conout("Não foi possível efetuar autenticação no TAE!" )
					Conout("Verifique o parâmetro MV_SIGNURL ou a configuração de usuário e senha")
				Else
					Help( ,, "Atenção",, "Não foi possível efetuar autenticação no TAE!" , 1,,,,,,, {"Verifique o parâmetro MV_SIGNURL ou a configuração de usuário e senha"} )
				EndIf
				Return 
			EndIf
		EndIf
	Else
		If lSchedule
			Conout("Para execução dessa rotina é necessário que a LIB esteja atualizada com versão igual ou superior a " + "02/12/2021")
		Else
			Aviso("Atenção", "Para execução dessa rotina é necessário que a LIB esteja atualizada com versão igual ou superior a " + "02/12/2021", { "Ok" } )
		EndIf
		Return Nil
	EndIf
EndIf

If !lSchedule
	RptStatus( { |lEnd| U_FERTAEImp(oPrinter) } , "Gerando relatórios..." )
Else 
	U_FERTAEImp(oPrinter)
EndIf 

oProfile:DeActivate()

If nTipRel == 2 .and. !lSchedule
	MsAguarde( { || fMakeLog( aLogTAE , aLogTitle , "FERTAE" , NIL , "FERTAE" , "Log de ocorrências na integração com TAE" ) } ,  "Log de ocorrências na integração com TAE" )
EndIf 

Return Nil

/*/{Protheus.doc}fMntPrinter
Configuração inicial do objeto FWMSPrinter
@author Leandro Drumond
@since 30/11/2021
@version P12
@return Nil
/*/
Static Function fMntPrinter(oPrinter, cName, lView)

DEFAULT cName := 'FERTAE'
DEFAULT lView := .T.

oPrinter := FWMSPrinter():New( cName, IMP_PDF , .F., cPathTmp, .T., , If(lSchedule,Nil,oSetup ),,,,,If(lSchedule,.F.,lView ))	
                 
oPrinter:SetResolution( 75 )

If !lSchedule
	oPrinter:lServer := oSetup:GetProperty( PD_DESTINATION ) == AMB_SERVER
	If oSetup:GetProperty( PD_ORIENTATION ) == 2
		oPrinter:SetLandscape()
	Else
		oPrinter:SetPortrait()
	EndIf

	oPrinter:SetPaperSize( oSetup:GetProperty( PD_PAPERSIZE ) )
	oPrinter:SetMargin(oSetup:GetProperty( PD_MARGIN )[1],oSetup:GetProperty( PD_MARGIN )[2],oSetup:GetProperty( PD_MARGIN )[3],oSetup:GetProperty( PD_MARGIN )[4])
	oPrinter:cPathPDF 	:= oSetup:aOptions[PD_VALUETYPE]
Else
	oPrinter:lServer := .T.
	oPrinter:SetPortrait()
	oPrinter:SetPaperSize( DMPAPER_LETTER )
	oPrinter:SetMargin(20,20,20,20)
	oPrinter:setDevice(IMP_PDF)
	oPrinter:cPathPDF 	:=  cPathTmp
EndIf

oPrinter:nDevice 	:= IMP_PDF

Return Nil

/*/{Protheus.doc}FERTAEImp
Obtem os dados para impressão do relatório
@version P12
@return Nil
/*/
User Function FERTAEImp(oPrinter)

Local aOrdAux       := {"RA_FILIAL, RA_MAT", "RA_FILIAL, RA_CC, RA_MAT", "RA_FILIAL, RA_CC, RA_NOME", "RA_FILIAL, RA_NOME"}
Local aTabFer2		:= {}
Local cAliasSRA 	:= GetNextAlias()
Local cWhere		:= ""
Local cIndice 		:= '%'+ aOrdAux[nOrdem] + '%'
Local cAcessaSRA	:= &( " { || " + ChkRH( "FERTAE" , "SRA" , "2" ) + " } " )
Local cFiliAtual	:= cFilAnt
Local cFilAux       := "!!"
Local aPerAux
Local aPeriodos
Local cProcesso
Local cRot
Local cPeriodo		:= ""
Local dDataDe
Local dDataAte
Local lImpAv
Local nPosSem
Local nTempoParc
Local nCnt

Private aInfo
Private aCodFol
Private aTabFer		:= {}
Private DaAuxI
Private DaAuxF
Private lAchou
Private lPreview 	:= .F.
Private nOrdSRR 	:= RetOrder( "SRR", "RR_FILIAL+RR_MAT+RR_TIPO3+DTOS(RR_DATA)+RR_PD+RR_CC" )
Private cImpAvFer	:= SuperGetMv('MV_IMPAVF',,"1")
Private cAboAnt		:= If(SuperGetMv("MV_ABOPEC")=="S","1","2") //-- Abono antes ferias
Private nDiasAviso  := SuperGetMv("MV_AVISFER",,0)

If !Empty(cFilRange)
	cWhere += " AND " + cFilRange
EndIf

If !Empty(cMatRange)
	cWhere += " AND " + cMatRange
EndIf

If !Empty(cCcRange)
	cWhere += " AND " + cCCRange
EndIf

If !Empty(cNomRange)
	cWhere += " AND " + cNomRange
EndIf

cWhere	:= "%" + cWhere + "%"

DbSelectARea("SRA")
DbSetOrder(1)

BeginSql alias cAliasSRA
	SELECT RA_FILIAL,RA_MAT
	FROM %table:SRA% SRA
	WHERE SRA.%notDel% 
	%exp:cWhere%
	ORDER BY %exp:cIndice%
EndSql

While (cAliasSRA)->(!Eof())

	SRA->(DbSeek((cAliasSRA)->(RA_FILIAL + RA_MAT)))

	If SRA->RA_SITFOLH $ "D" .AND. nImprDem <> 1	// 1 - Imprime Demitido = Sim
		(cAliasSRA)->(dbSkip())
		Loop
	EndIf

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Consiste Filiais e Acessos                                             ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
    If !( SRA->RA_FILIAL $ fValidFil() ) .Or. !Eval( cAcessaSRA )
		(cAliasSRA)->(dbSkip())
		Loop
	EndIf	

	cFilAnt 	:= SRA->RA_FILIAL
	cProcesso 	:= SRA->RA_PROCES
	cRot 		:= fGetCalcRot("3") //Obtém roteiro de férias
	cPeriodo	:= ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega o periodo atual de calculo (aberto)                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	fGetLastPer(@cPeriodo, , cProcesso, cRot , .T., .F. )

	aPerAux     := {}

	//Carrega todos os dados do periodo
	fCarPeriodo(cPeriodo , cRot , @aPerAux, , @nPosSem)

	If Len(aPerAux) == 0
		(cAliasSRA)->(dbSkip())
		Loop
	Else
		dDataDe  := aPerAux[nPosSem,3]
		dDataAte := aPerAux[nPosSem,4]
	EndIf

	fTab_Fer(@aTabFer,,@aTabFer2)

	//Se as horas semanais forem inferiores a 26, e o Mnemonico P_REGPARCI estiver ativo,
	//utiliza os dias de férias da tabela S065 - Tabela de férias tempo parcial (Artigo 130A da CLT)
	nTempoParc := SRA->RA_HRSEMAN
	If SRA->RA_HOPARC == "1" .And. nTempoParc  > 0 .And. nTempoParc <= 25 .And. Len(aTabFer2) > 0 .And. P_REGPARCI
		nPosTbFer := Ascan(aTabFer2, { |X|  nTempoParc <= X[6] .And. nTempoParc > X[5] })
		If nPosTbFer > 0
			aTabFer := aClone(aTabFer2[nPosTbFer])
		EndIf
	EndIf

	lAchou := .F.
	lImpAv := nAviso == 1

	If cFilAux <> SRA->RA_FILIAL

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega Matriz Com Dados da Empresa                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fInfo(@aInfo,SRA->RA_FILIAL)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega Variaveis Codigos da Folha                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !FP_CODFOL(@aCodFol,SRA->RA_FILIAL)
			Return
		EndIf

		cFilAux := SRA->RA_FILIAL

	EndIf	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura No Arquivo de Ferias o Periodo a Ser Listado         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SRH" )
	If SRH->(dbSeek( SRA->RA_FILIAL + SRA->RA_MAT ))
		aPeriodos := {}
		While SRH->(!Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT == SRH->RH_FILIAL + SRH->RH_MAT)
			If ( (SRH->RH_DATAINI >= dDtfDe .And. SRH->RH_DATAINI <= dDtfAte) .And. (SRH->RH_DTRECIB >= dDtPgDe .And. SRH->RH_DTRECIB <= dDtPgAte) ) 
				AAdd(aPeriodos, Recno() )
			EndIf
			dbSkip()
		Enddo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime Aviso de Ferias Caso nao tenha calculado             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aPeriodos) == 0
			dbSelectArea( "SRA" )
			If lImpAv
				FImprAvi(oPrinter)
			Endif
			(cAliasSRA)->(dbSkip())
			Loop
		EndIf

		For nCnt := 1 To Len(aPeriodos)
			dbSelectArea( "SRH" )
			dbGoTo(aPeriodos[nCnt])

			DaAuxI := SRH->RH_DATAINI
			DaAuxF := SRH->RH_DATAFIM

			lAchou := .T.

			If nAviso == 1
				FImprAvi(oPrinter)
			EndIf

			If nRecib == 1
				FImprFer(oPrinter)
			EndIf			

			lImpAv := .F.
	    Next nCnt
    EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime Aviso de Ferias Caso nao tenha calculado             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lImpAv
		FImprAvi(oPrinter)
	EndIf

	(cAliasSRA)->(DbSkip())
EndDo

cFilAnt := cFiliAtual

If lPreview
	If nTipRel == 1
		oPrinter:Preview()
	EndIf
ElseIf !lSchedule
	MsgInfo("Nenhum funcionário encontrado!")
EndIf

Return Nil

/*/{Protheus.doc}FImprFer
Imprime recibo de férias
@version P12
@return Nil
/*/
Static Function FImprFer(oPrinter)
Local lImpBco 	:= .F.
Local aPdv  	:= {}
Local aPdd  	:= {}
Local cRet1 	:= ""
Local cRet2 	:= ""
Local cDtDisp 	:= ""
Local cBcoDesc	:= ""
Local cBcoAg	:= ""
Local cBcoCta	:= ""
Local cDet		:= ""
Local cId
Local cPathFile
Local cFile
Local dDtBusFer
Local nDiaFeQueb

Local nLin		:= 0
Local nCol		:= 0
Local nMaximo
Local nConta
Local nSizePage
Local nColTot
Local nLinTot
Local nId
Local lOk 
Local jResponse

//Dados bancários
If nDBanco == 1 .And. !Empty(SRA->RA_BCDEPSA) .And. !Empty(SRA->RA_CTDEPSA)
	cDtDisp  := Padr(DtoC(SRH->RH_DTRECIB),10)
	cBcoDesc := AllTrim( DescBco(SRA->RA_BCDEPSA,SRA->RA_FILIAL) )
	cBcoAg   := AllTrim( Substr(SRA->RA_BCDEPSA,4,5) )
	cBcoCta  := AllTrim( SRA->RA_CTDEPSA )
	lImpBco	 := .T.
EndIf

dDtBusFer := SRH->RH_DATAINI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se Funcionario tem  dias de Licensa remunerada, entao deve-se³
//³ imprimir somente o period de gozo das ferias (conf.vlr calcu-³
//³ lado.)                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SRH->( RH_DIALRE1 + RH_DIALREM) > 0 
	nDiaFeQueb := SRH->(RH_DFERIAS - Int(RH_DFERIAS) )
	If lSomLiR
		DaAuxF := SRH->RH_DATAFIM 
	Else
		DaAuxF := SRH->RH_DATAFIM -( SRH->( RH_DIALRE1 + RH_DIALREM ) ) + If(nDiaFeQueb>0 , 1, 0 ) 
	EndIf
EndIf 

aPdv  := {}
aPdd  := {}
cRet1 := ""
cRet2 := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona Arq. SRR Para Guardar na Matriz as Verbas De Ferias³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SRR")
dbSetOrder(nOrdSRR)

If SRR->(dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + "F" ))

	If nTipRel == 2
		cFile		:= "RECF" + SRA->RA_FILIAL + SRA->RA_MAT + DtoS(DaAuxI)
		fMntPrinter(@oPrinter,cFile,.F.)
	EndIf

	nSizePage	:= oPrinter:nPageWidth / oPrinter:nFactorHor //Largura da página em cm dividido pelo fator horizontal, retorna tamanho da página em pixels
	nColTot		:= nSizePage-20
	nLinTot		:= ((oPrinter:nPageHeight / oPrinter:nFactorVert) -40 )

	While SRR->( !Eof() .And. SRA->RA_FIlIAL + SRA->RA_MAT + "F" == SRR->RR_FILIAL + SRR->RR_MAT + SRR->RR_TIPO3 )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica Verba For Abono Ou 13o Esta $ Na Variavel Nao Lista ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SRR->RR_PD # aCodFol[102,1] .AND. SRR->RR_DATA == dDtBusFer
			If RetValSrv( SRR->RR_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
				AAdd(aPdv , { SRR->RR_PD , SRR->RR_VALOR, SRR->RR_PERIODO, SRR->RR_ROTEIR, SRR->RR_SEMANA, SRR->RR_CC, SRR->RR_SEQ })
			ElseIf RetValSrv( SRR->RR_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "2"
				AAdd(aPdd , { SRR->RR_PD , SRR->RR_VALOR, SRR->RR_PERIODO, SRR->RR_ROTEIR, SRR->RR_SEMANA, SRR->RR_CC, SRR->RR_SEQ })
			EndIf
		EndIf
		SRR->(dbSkip())
	Enddo
	
	PER_AQ_I := StrZero(Day(SRH->RH_DATABAS),2)+" De "+MesExtenso(Month(SRH->RH_DATABAS))+" De "+Str(Year(SRH->RH_DATABAS),4)
	PER_AQ_F := StrZero(Day(SRH->RH_DBASEAT),2)+" De "+MesExtenso(Month(SRH->RH_DBASEAT))+" De "+Str(Year(SRH->RH_DBASEAT),4)
	PER_GO_I := StrZero(Day(DAAUXI),2)+" De "+MesExtenso(Month(DAAUXI))+" De "+Str(Year(DAAUXI),4)
	PER_GO_F := StrZero(Day(DAAUXF),2)+" De "+MesExtenso(Month(DAAUXF))+" De "+Str(Year(DAAUXF),4)
	
	oPrinter:StartPage()

	lPreview := .T.

	nLin := 12
	nCol := 10

	oPrinter:Box( nLin, nCol , nLinTot, nColTot, "-6" )			// Margens		

	nLin += 1
	oPrinter:SayAlign(nLin,nCol,"RECIBO DE FÉRIAS",oFontT,nColTot,100,,ALIGN_H_CENTER)

	nLin += 25
	oPrinter:Line( nLin, nCol	, nLin, nColTot	, 0 , "-6") 	// Linha Pos Data

	nLin += 15
	If !Empty(SRA->RA_NSOCIAL)
		oPrinter:SayAlign(nLin,nCol,Padr(" Nome Social: ",30) + Left(SRA->RA_NSOCIAL, 60) ,oFontC,nColTot,100,,ALIGN_H_LEFT)
	Else
		oPrinter:SayAlign(nLin,nCol,Padr(" Nome do Empregado: ",30) + Left(SRA->RA_NOME, 60) ,oFontC,nColTot,100,,ALIGN_H_LEFT)
	EndIf

	nLin += 15
	oPrinter:SayAlign(nLin,nCol,Padr(" Carteira de Trabalho: ",30) + If(Empty(SRA->RA_NUMCP),Space(7),AllTrim(SRA->RA_NUMCP))+" - "+SRA->RA_SERCP ,oFontC,nColTot,100,,ALIGN_H_LEFT)
	oPrinter:SayAlign(nLin,nColTot/2,"Registro: " + SRA->RA_FILIAL+" "+SRA->RA_MAT ,oFontC,nColTot,100,,ALIGN_H_LEFT)

	nLin += 15
	oPrinter:SayAlign(nLin,nCol,Padr(" Periodo Aquisitivo: ",30) + PER_AQ_I + " a " + PER_AQ_F,oFontC,500,100,,ALIGN_H_LEFT)

	nLin += 15
	oPrinter:SayAlign(nLin,nCol,Padr(" Periodo Gozo das Férias: ",30) + PER_GO_I + " a " + PER_GO_F,oFontC,500,100,,ALIGN_H_LEFT)
	
	nLin += 15
	oPrinter:SayAlign(nLin,nCol,Padr(" Qtde. Dias Lic. Remun.: ",30) + cValToChar(SRH->RH_DIALRE1 + SRH->RH_DIALREM),oFontC,500,100,,ALIGN_H_LEFT)

	nLin += 20
	oPrinter:Line( nLin, nCol	, nLin, nColTot	, 0 , "-6") 	// Linha Pos Data

	nLin += 5
	oPrinter:SayAlign(nLin,nCol,"DADOS PARA CÁLCULO DE PAGAMENTO DE FÉRIAS" , oFontS, nColTot, 100,, ALIGN_H_CENTER)

	nLin += 25
	oPrinter:Line( nLin, nCol	, nLin, nColTot	, 0 , "-6") 	// Linha Pos Data

	nLin += 15
	oPrinter:SayAlign(nLin,nCol,Padr(" Salário Mês: ",23) + Transform(SRH->RH_SALMES,"@E 999,999.99") ,oFontC,nColTot,100,,ALIGN_H_LEFT)
	oPrinter:SayAlign(nLin,nColTot/2,Padr(" Salário Hora: ",23) + Transform(SRH->RH_SALHRS,"@E 999,999.99") ,oFontC,nColTot,100,,ALIGN_H_LEFT)

	nLin += 15
	oPrinter:SayAlign(nLin,nCol,Padr(" Valor Dia Mês: ",23) + Transform(SRH->RH_SALDIA,"@E 999,999.99") ,oFontC,nColTot,100,,ALIGN_H_LEFT)
	oPrinter:SayAlign(nLin,nColTot/2,Padr(" Valor Dia Mês Seg.: ",23) + Transform(SRH->RH_SALDIA1,"@E 999,999.99") ,oFontC,nColTot,100,,ALIGN_H_LEFT)

	cDiasFMes := If(SRR->(dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + "F" + Dtos(dDtBusFer) + aCodFol[072,1])), Transform(SRR->RR_HORAS, "@E 999,999.99"), Space(11))
	cDiasFMesSeg := If(SRR->(dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + "F" + Dtos(dDtBusFer) + aCodFol[073,1])), Transform(SRR->RR_HORAS, "@E 999,999.99"), Space(11))									
	
	If SRA->RA_CATFUNC = 'C'
		cCodPgMed := aCodFol[343,1]
		cCodMedMs := aCodFol[344,1]
		If Empty(cDiasFMes)  
			cDiasFMes := If(SRR->(dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + "F" + Dtos(dDtBusFer) + If(!Empty(cCodPgMed),cCodPgMed,aCodFol[075,1] ))), Transform(SRR->RR_HORAS, "@E 999,999.99"), Space(11))
			cDiasFMesSeg := If(SRR->(dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + "F" + Dtos(dDtBusFer) + If(!Empty(cCodMedMs),cCodMedMs,aCodFol[076,1]) )), Transform(SRR->RR_HORAS, "@E 999,999.99"), Space(11))	
		EndIf					
	EndIf

	nLin += 15
	oPrinter:SayAlign(nLin,nCol,Padr(" Dias Férias Mês: ",23) + cDiasFMes ,oFontC,nColTot,100,,ALIGN_H_LEFT)
	oPrinter:SayAlign(nLin,nColTot/2,Padr(" Dias Férias Mês Seg.: ",23) + cDiasFMesSeg ,oFontC,nColTot,100,,ALIGN_H_LEFT)

	cDiasAbMes := If(SRR->(dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + "F" + Dtos(dDtBusFer) + aCodFol[074,1])), Transform(SRR->RR_HORAS, "@E 999,999.99"), Space(11))
	cDiasAbMSeg := If(SRR->(dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + "F" + Dtos(dDtBusFer) + aCodFol[205,1])), Transform(SRR->RR_HORAS, "@E 999,999.99"), Space(11))

	If SRA->RA_CATFUNC = 'C' .and. Empty(cDiasAbMes)
		cDiasAbMes := If(SRR->(dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + "F" + Dtos(dDtBusFer) + aCodFol[623,1])), Transform(SRR->RR_HORAS, "@E 999,999.99"), Space(11))
		cDiasAbMSeg := If(SRR->(dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + "F" + Dtos(dDtBusFer) + aCodFol[634,1])), Transform(SRR->RR_HORAS, "@E 999,999.99"), Space(11))
	EndIf

	nLin += 15
	oPrinter:SayAlign(nLin,nCol,Padr(" Dias Abono Mês: ",23) + cDiasAbMes ,oFontC,nColTot,100,,ALIGN_H_LEFT)
	oPrinter:SayAlign(nLin,nColTot/2,Padr(" Dias Abono Mês Seg.: ",23) + cDiasAbMSeg ,oFontC,nColTot,100,,ALIGN_H_LEFT)
	
	nLin += 20
	oPrinter:Line( nLin, nCol	, nLin, nColTot	, 0 , "-6") 	// Linha Pos Data

	nLin += 5
	oPrinter:SayAlign(nLin,nCol," P R O V E N T O S " ,oFontS,nColTot/2,100,,ALIGN_H_CENTER)
	oPrinter:SayAlign(nLin,nColTot/2," D E S C O N T O S " ,oFontS,nColTot/2,100,,ALIGN_H_CENTER)

	nLin += 25
	oPrinter:Line( nLin, nCol	, nLin, nColTot	, 0 , "-6") 	// Linha Pos Data
	
	nLin += 15
	oPrinter:SayAlign(nLin,nCol," Cód. Verba            Q/H      Valor" ,oFontS2,nColTot/2,100,,ALIGN_H_LEFT)
	oPrinter:SayAlign(nLin,nColTot/2," Cód. Verba            Q/H      Valor" ,oFontS2,nColTot,100,,ALIGN_H_LEFT)

	nLin += 5

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao das Verbas                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nMaximo := MAX(Len(aPDV),Len(aPdd))
	SRR->(DbSetOrder(1))

	For nConta := 1 TO nMaximo

		nLin += 15
	
		If nConta > Len(aPdv)
			cDet := ""
		ElseIf !Empty(aPdv[nConta,7]) // Verifico se existe sequencia, pois pode haver verbas repetidas e será necessário utilizar o indice 4 para busca correta
			SRR->(DbSetOrder(4))//RR_FILIAL+RR_MAT+RR_PERIODO+RR_ROTEIR+RR_SEMANA+RR_PD+RR_CC+RR_SEQ+RR_DATA
			SRR->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT + aPdv[nConta,3] + aPdv[nConta,4] + aPdv[nConta,5] + aPdv[nConta,1] + aPdv[nConta,6] + aPdv[nConta,7] + DToS(dDtBusFer)) )
			nQtdHoras := SRR->RR_HORAS
			cDesc := Left(DescPd(aPdv[nConta,1],SRA->RA_FILIAL),15)
			cDet := " " + aPdv[nConta,1] + " " + cDesc + " " + Transform(nQtdHoras, '@E 99.99') + " " + Transform(aPdv[nConta,2],'@E 999,999.99')
			SRR->(DbSetOrder(1))
		Else
			SRR->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT + "F" + DToS(dDtBusFer) + aPdv[nConta,1]) )
			nQtdHoras := SRR->RR_HORAS
			cDesc := Left(DescPd(aPdv[nConta,1],SRA->RA_FILIAL),15)
			cDet := " " + aPdv[nConta,1] + " " + cDesc + " " + Transform(nQtdHoras, '@E 99.99') + " " + Transform(aPdv[nConta,2],'@E 999,999.99')
		EndIf

		oPrinter:SayAlign(nLin, nCol, cDet, oFontC, nColTot, 100, , ALIGN_H_LEFT)
	
		If nConta > Len(aPdd)
			cDet := ""
		Else
			SRR->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT + "F" + DToS(dDtBusFer) + aPdd[nConta,1]) )
			nQtdHoras := SRR->RR_HORAS
			cDesc := Left(DescPd(aPdd[nConta,1],SRA->RA_FILIAL),15)
			cDet := " " + aPdd[nConta,1] + " " + cDesc + " " + Transform(nQtdHoras, '@E 99.99') + " " + Transform(aPdd[nConta,2],'@E 999,999.99')
		EndIf

		oPrinter:SayAlign(nLin, nColTot/2, cDet, oFontC, nColTot, 100, , ALIGN_H_LEFT)
	Next

	nLin += 30

	nTvp := 0.00
	nTvd := 0.00
	AeVal(aPdv,{ |X| nTVP:= nTVP + X[2]})    // Acumula Valores
	AeVal(aPdd,{ |X| nTVD:= nTVD + X[2]})
	cLiqReceber := Trans(nTvp-nTvd,"@E 999,999,999.99")

	oPrinter:SayAlign(nLin,nCol,Padr(" Total Proventos:",23) + Trans(nTvp,"@E 999,999,999.99") ,oFontC,nColTot,100,,ALIGN_H_LEFT)
	oPrinter:SayAlign(nLin,nColTot/2,Padr(" Total Descontos:",23) + Trans(nTvd,"@E 999,999,999.99") ,oFontC,nColTot,100,,ALIGN_H_LEFT)

	nLin += 20
	oPrinter:Line( nLin, nCol	, nLin, nColTot	, 0 , "-6") 	// Linha Pos Data

	nLin += 10
	oPrinter:SayAlign(nLin,nCol,Padr(" Liquido a receber:",23) + cLiqReceber ,oFontS2,nColTot,100,,ALIGN_H_LEFT)
	
	nLin += 25
	oPrinter:Line( nLin, nCol	, nLin, nColTot	, 0 , "-6") 	// Linha Pos Data	 														

	nLin += 15
	oPrinter:SayAlign(nLin,nCol," Recebi da: " + SubStr(aInfo[3]+Space(40),1,40) ,oFontC,nColTot,100,,ALIGN_H_LEFT)

	nLin += 15
	oPrinter:SayAlign(nLin,nCol," Estabelecida a " + SubStr(AllTrim(aInfo[4]) + ", " + AllTrim(aInfo[14]) + Space(40),1,40) + " Cep: " + SubStr(aInfo[7]+Space(8),1,8),oFontC,nColTot,100,,ALIGN_H_LEFT)

	nLin += 15
	oPrinter:SayAlign(nLin,nCol," Cidade: " + AllTrim(SubStr(aInfo[5]+Space(25),1,25)) + " UF: " + aInfo[6] + " em " + AllTrim(SubStr(aInfo[5]+Space(20),1,20)) + ", " + StrZero(Day(SRH->RH_DTRECIB),2) + " De " + MesExtenso(Month(SRH->RH_DTRECIB)) + " de " + Str(Year(SRH->RH_DTRECIB),4),oFontC,nColTot,100,,ALIGN_H_LEFT)

	cExt   := EXTENSO(nTvp-nTvd,.F.,1)
	SepExt(cExt,80,110,@cRet1,@cRet2)

	nLin += 15

	If Len(cRet2) > 0
		oPrinter:SayAlign(nLin,nCol," a importância de R$ " + AllTrim(TRANSFORM(nTvp-nTvd,"@E 999,999,999.99")) + " ( " + cRet1 ,oFontC,nColTot,100,,ALIGN_H_LEFT)
		
		nLin += 15
		oPrinter:SayAlign(nLin,nCol,cRet2 + " ) ",oFontC,nColTot,100,,ALIGN_H_LEFT)	
	Else
		oPrinter:SayAlign(nLin,nCol," a importância de R$ " + AllTrim(TRANSFORM(nTvp-nTvd,"@E 999,999,999.99")) + " ( " + cRet1 + " ) ",oFontC,nColTot,100,,ALIGN_H_LEFT)
	Endif
	
	nLin += 15
	oPrinter:SayAlign(nLin,nCol," que me paga adiantadamente por motivo das minhas férias regulamentares, ora concedidas que vou gozar",oFontC,nColTot,100,,ALIGN_H_LEFT)

	nLin += 15
	oPrinter:SayAlign(nLin,nCol," de acordo com a descrição acima, tudo conforme o aviso que recebi em tempo, ao qual dei meu aceite.",oFontC,nColTot,100,,ALIGN_H_LEFT)

	nLin += 15
	oPrinter:SayAlign(nLin,nCol," Para clareza e documento, firmo o presente recibo, dando a firma plena e geral quitação. ",oFontC,nColTot,100,,ALIGN_H_LEFT)

	//Impressao dos dados bancarios
	If lImpBco
		nLin += 25
		oPrinter:SayAlign(nLin,nCol," A importância será disponibilizada em: " + cDtDisp,oFontC,nColTot,100,,ALIGN_H_LEFT)

		nLin += 15
		oPrinter:SayAlign(nLin,nCol," Banco: " + cBcoDesc + " - " + " Agência/Conta: " + cBcoAg + "/" + cBcoCta,oFontC,nColTot,100,,ALIGN_H_LEFT)
	EndIf

	If nDtRec == 1
		nLin += 30
		oPrinter:SayAlign(nLin,nCol, " " + AllTrim(aInfo[5]) + ", " + StrZero(Day(SRH->RH_DTRECIB),2) + " de " + MesExtenso(Month(SRH->RH_DTRECIB)) + " de " + StrZero(Year(SRH->RH_DTRECIB),4),oFontC,nColTot,100,,ALIGN_H_LEFT)
	EndIf

	nLin += 40
	oPrinter:Line( nLin, (nColTot/3)+1, nLin, (nColTot - (nColTot/3)) + 1	, 0 , "-6")

	nLin += 5
	oPrinter:SayAlign(nLin,nCol,"Assinatura do Empregado",oFontC,nColTot,100,,ALIGN_H_CENTER)

	oPrinter:EndPage()

	If nTipRel == 2

		cPathFile	:= oPrinter:cPathPDF + cFile

		oPrinter:Preview()
		FreeObj(oPrinter)
		oPrinter := Nil

		//Faz upload do documento para o TAE
		lOk := oSign:uploadDocument( cPathFile+".pdf" )
		jResponse := oSign:getResponse()

		If File(cPathFile+".pdf")
			fErase(cPathFile+".pdf")
		EndIf		

		If lOk
			nId := jResponse[ "data" ]
			cId := "_"+cValToChar(nId)

			//Envia solicitação para o usuário assinar
			If !Empty(SRA->RA_EMAIL)
				lOk  := oSign:requestAction( jResponse[ "data" ], { { SRA->RA_EMAIL, "0" } } )
				jResponse := oSign:getResponse()
			EndIf

			aAdd(aLogTAE[1], SRA->RA_FILIAL + " - " + SRA->RA_MAT + ": " + If(Empty(SRA->RA_EMAIL), "E-mail não cadastrado. Não foi enviado solicitação de assinatura para o colaborador.", "Solicitação enviada para " + AllTrim(SRA->RA_EMAIL)) )
			
			If Empty(aLogTitle[1])
				aLogTitle[1] := "Recibos enviados:"
			EndIf

			fGrvREQ(cPathFile, DaAuxI, DaAuxF, nId, "1")
		Else
			aAdd(aLogTAE[3], SRA->RA_FILIAL + " - " + SRA->RA_MAT + ": " + jResponse[ "description" ])
			If Empty(aLogTitle[3])
				aLogTitle[3] := "Recibos não enviados:"
			EndIf
		EndIf	
	EndIf	
EndIf    

Return Nil

/*/{Protheus.doc}FImprAvi
Imprime aviso de férias
@version P12
@return Nil
/*/
Static Function FImprAvi(oPrinter)

Local aArea			:= GetArea()
Local nSizePage		:= 0
Local nLin			:= 13
Local nCol			:= 20
Local nColTot		:= 0
Local nColAux		:= 0
Local nLinTot		:= 0
Local lImpBco 		:= .F.
Local cBcoDesc		:= ""
Local cBcoAg		:= ""
Local cBcoCta		:= ""
Local cDesc			:= ""
Local cAboPec		:= ""
Local lTemProg  	:= .F.
Local nDferven 		:= 0
Local nDferave 		:= 0
Local nDiasFePro	:= 0
Local nDiasAbono	:= 0
Local nDFaltaV		:= 0
Local nDiasDedFer	:= 0
Local nDiasFer		:= 0
Local dDtIniProg	:= CtoD("")
Local dDataAviso 	:= CtoD("")
Local dDataBsIni    := CtoD("")
Local dDataBsFim    := CtoD("")
Local dDataRet		:= CtoD("")
Local dDataRecib	:= CtoD("")
Local nDiasLicRem	:= 0
Local lOk 
Local jResponse

If lAchou
	dDataAviso 	:= SRH->RH_DTAVISO
	dDataBsIni  := SRH->RH_DATABAS
	dDataBsFim  := SRH->RH_DBASEAT
	dDataRet	:= SRH->RH_DATAFIM
	dDataRecib	:= SRH->RH_DTRECIB
	nDiasLicRem	:= SRH->RH_DIALRE1 + SRH->RH_DIALREM
Else

	DbSelectArea("SRF")
	DbSetOrder(1)
	If SRF->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT))
		While SRF->(!Eof() .and. RF_FILIAL + RF_MAT == SRA->RA_FILIAL + SRA->RA_MAT)
			If SRF->RF_STATUS == "1"
				If SRF->RF_DATAINI >= dDtfDe .and. SRF->RF_DATAINI <= dDtfAte
					dDtIniProg := SRF->RF_DATAINI
					nDiasFePro := SRF->RF_DFEPRO1
					nDiasAbono := SRF->RF_DABPRO1
					lTemProg := .T.
				ElseIf SRF->RF_DATINI2 >= dDtfDe .And. SRF->RF_DATINI2 <= dDtfAte
					dDtIniProg := SRF->RF_DATINI2
					nDiasFePro := SRF->RF_DFEPRO2
					nDiasAbono := SRF->RF_DABPRO2
					lTemProg := .T.
				ElseIf SRF->RF_DATINI3 >= dDtfDe .And. SRF->RF_DATINI3 <= dDtfAte
					dDtIniProg := SRF->RF_DATINI3
					nDiasFePro := SRF->RF_DFEPRO3
					nDiasAbono := SRF->RF_DABPRO3
					lTemProg := .T.
				EndIf
				If lTemProg
					Exit
				EndIf
			EndIf
			SRF->(DbSkip())
		EndDo
	EndIf

	If lTemProg

		If SRF->RF_DVENPEN > 0 .And. !Empty(SRF->RF_IVENPEN)
			dDataBsIni := SRF->RF_IVENPEN
			dDataBsFim := SRF->RF_FVENPEN
			nDferven   := SRF->RF_DVENPEN
		Else
			dDataBsIni := SRF->RF_DATABAS
			dDataBsFim := fCalcFimAq(SRF->RF_DATABAS)
			If nDiasFePro > 0
				nDferven := nDiasFePro
			Else
				nDferven := SRF->RF_DFERVAT
				nDferven := If (nDferVen <= 0,nDferave,nDferven)
			EndIf
		EndIf

		If !Empty(SRF->RF_ABOPEC)
			cAboPec := SRF->RF_ABOPEC
		Else
			cAboPec := cAboAnt
		EndIf

		dDataAviso  := fVerData(dDtIniProg - (If (nDiasAviso > 0, nDiasAviso,aTabFer[3])))
		nDiasFer  	:= If( nDFerven > aTabFer[3] , aTabFer[3] , nDFerven )
		dDataRecib  := If(cAboPec=="1" .and. nDiasAbono > 0,DataValida(DataValida((dDtIniProg-nDiasAbono)-1,.F.)-1,.F.), DataValida(DataValida(dDtIniProg-1,.F.)-1,.F.))

		If SRF->RF_TEMABPE == "S"
			nDiasFer -= If(nDiasAbono > 0, nDiasAbono, 10)
		EndIf

		//--Abater dias de ferias Antecipadas
		If SRF->RF_DFERANT > 0
			nDiasFer := Min(nDiasFer, aTabFer[3]-SRF->RF_DFERANT)
		EndIf

		// Abate Faltas  do cad. Provisoes
		If ( SRF->RF_DFALVAT + SRF->RF_DFALAAT ) > 5
			nDFaltaV := SRF->RF_DFALVAT + SRF->RF_DFALAAT
			TabFaltas(@nDFaltaV)

			If (nDFaltaV > 0 .and. nDiasAbono > 0 )

				nDiasDedFer   := ( nDiasFePro - ( nDFaltaV- nDiasAbono ) )

				If nDiasDedFer > 0
					nDiasFer := nDiasDedFer - NoRound( ( ( nDiasFePro + nDiasAbono ) - nDFaltaV ) / 3 )
				Else
					nDiasFer -= nDFaltaV
				EndIf

			Else
				nDiasFer -= nDFaltaV
			EndIf
		EndIf

		DaAuxI   := dDtIniProg
		DaAuxF   := dDtIniProg + nDiasFer - 1
		lTemProg := nDiasFer > 0
	EndIf	
	If !lTemProg
		RestArea(aArea)
		Return Nil
	EndIf
EndIf

If nTipRel == 2
	cFile		:= "AVIF"+SRA->RA_FILIAL+SRA->RA_MAT+dToS(DaAuxI)
	fMntPrinter(@oPrinter,cFile,.F.)
EndIf

nSizePage	:= oPrinter:nPageWidth / oPrinter:nFactorHor //Largura da página em cm dividido pelo fator horizontal, retorna tamanho da página em pixels
nColTot		:= nSizePage-20

If nDBanco == 1 .And. !Empty(SRA->RA_BCDEPSA) .And. !Empty(SRA->RA_CTDEPSA)
	cBcoDesc := AllTrim( DescBco(SRA->RA_BCDEPSA,SRA->RA_FILIAL) )
	cBcoAg   := AllTrim( Substr(SRA->RA_BCDEPSA,4,5) )
	cBcoCta  := AllTrim( SRA->RA_CTDEPSA )
	lImpBco	 := .T.
EndIf

oPrinter:StartPage()

lPreview := .T.

nLinTot := nLin + 315 + IF( !Empty(SRA->RA_DEPTO), 15, 0 ) + If(cImpAvFer == "1", If(lImpBco, 75, 30), 0) //Se for incluído mais linhas no relatório, elas devem ser somadas aqui, para que a moldura fique do tamanho correto

oPrinter:Box( 12, 10 , nLinTot, nColTot, "-6" )  // Margens

oPrinter:SayAlign(nLin,0,"AVISO DE FÉRIAS",oFontT, nSizePage,100,,ALIGN_H_CENTER)

nLin += 20
oPrinter:Line( nLin, (nColTot/3)+1, nLin, (nColTot - (nColTot/3)) + 1	, 0 , "-6")

nLin += 25
oPrinter:SayAlign(nLin,nCol,AllTrim(aInfo[5]) + ", " + SubStr(DtoC(dDataAviso),1,2) + " De " + MesExtenso(Month(dDataAviso)) + " De " + Str(Year(dDataAviso),4) ,oFontC,nColTot - 25,100,,ALIGN_H_RIGHT)

nLin += 25
oPrinter:SayAlign(nLin,nCol,"A(o) Sr(a)",oFontC,nColTot,100,,ALIGN_H_LEFT)

nLin += 25

If !Empty(SRA->RA_NSOCIAL)
	oPrinter:SayAlign(nLin,nCol,Left(SRA->RA_NSOCIAL, 120),oFontC,nColTot,100,,ALIGN_H_LEFT)
Else
	oPrinter:SayAlign(nLin,nCol,Left(SRA->RA_NOME, 120),oFontC,nColTot,100,,ALIGN_H_LEFT)
EndIf

If lAchou
	// Se for Brasil e imprime funcionarios demitidos SIM, utilizar CC
	// da tabela SRR para buscar CC da epoca das ferias do funcionario
	dbSelectArea( "SRR" )
	SRR->(dbSetOrder(1))	
	
	If SRA->RA_SITFOLH $ "D" .and. nImprDem == 1 .and. dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + "F" + Dtos(dDtBusFer) )
		cDesc := DescCc( SRR->RR_CC, SRR->RR_FILIAL )
	Else
		cDesc := DescCc( SRA->RA_CC, SRA->RA_FILIAL )
	EndIf
Else
	cDesc := DescCc( SRA->RA_CC, SRA->RA_FILIAL )
EndIf

nLin += 15
oPrinter:SayAlign(nLin,nCol,"CTPS: " + SRA->RA_NUMCP + " - " + SRA->RA_SERCP ,oFontC,nColTot,100,,ALIGN_H_LEFT)

nLin += 15
oPrinter:SayAlign(nLin,nCol,Padr("Centro de Custo:",20) + AllTrim(cDesc) ,oFontC,nColTot,100,,ALIGN_H_LEFT)

IF !Empty(SRA->RA_DEPTO) 
	nLin += 15
	oPrinter:SayAlign(nLin,nCol,Padr("Departamento:",20) + fDesc('SQB',SRA->RA_DEPTO,'QB_DESCRIC') ,oFontC,nColTot,100,,ALIGN_H_LEFT)
EndIF

nLin += 35
oPrinter:SayAlign(nLin,nCol + ((nColTot/5)*2),"Nos termos da legislação vigente, suas férias serão",oFontC,nColTot,100,,ALIGN_H_LEFT)

nLin += 15
oPrinter:SayAlign(nLin,nCol,Space(10) + "concedidas conforme o demonstrativo abaixo:" ,oFontC,nColTot,100,,ALIGN_H_LEFT)

nLin += 25

If nDiasLicRem > 0 
	nColAux := nColTot
	nCOlTot -= 10

	oPrinter:SayAlign(nLin,nCol, "Período Aquisitivo:" ,oFontC,nColTot/4,100,,ALIGN_H_CENTER)
	oPrinter:SayAlign(nLin,nCol + nColTot/4, "Período de Gozo:" ,oFontC,nColTot/4,100,,ALIGN_H_CENTER)
	oPrinter:SayAlign(nLin,nCol + (nColTot/4)*2, "Qtd Lic.Remun.:" ,oFontC,nColTot/4,100,,ALIGN_H_CENTER)
	oPrinter:SayAlign(nLin,nCol + (nColTot/4)*3, "Retorno ao Trabalho:" ,oFontC,nColTot/4,100,,ALIGN_H_CENTER)

	nLin += 15
	oPrinter:SayAlign(nLin,nCol, Padr(DtoC(dDataBsIni),10) + " A " + Padr(DtoC(dDataBsFim),10) ,oFontC,nColTot/4,100,,ALIGN_H_CENTER)
	oPrinter:SayAlign(nLin,nCol + nColTot/4, If(SRH->RH_DIALREM == 30,"Licença Remunerada ",Padr(DtoC(DAAUXI),10) + " A " + Padr(DtoC(DAAUXF),10)) ,oFontC,nColTot/4,100,,ALIGN_H_CENTER) //
	oPrinter:SayAlign(nLin,nCol + (nColTot/4)*2, cValToChar(nDiasLicRem) ,oFontC,nColTot/4,100,,ALIGN_H_CENTER)
	oPrinter:SayAlign(nLin,nCol + (nColTot/4)*3, Padr(DtoC(dDataRet+1),10) ,oFontC,nColTot/4,100,,ALIGN_H_CENTER)

	nColTot := nColAux
Else
	oPrinter:SayAlign(nLin,nCol, "Período Aquisitivo:" ,oFontC,nColTot/3,100,,ALIGN_H_CENTER)
	oPrinter:SayAlign(nLin,nCol + nColTot/3, "Período de Gozo:" ,oFontC,nColTot/3,100,,ALIGN_H_CENTER)
	oPrinter:SayAlign(nLin,nCol + (nColTot/3)*2, "Retorno ao Trabalho:" ,oFontC,nColTot/3,100,,ALIGN_H_CENTER)

	nLin += 15
	oPrinter:SayAlign(nLin,nCol, Padr(DtoC(dDataBsIni),10)+" A "+Padr(DtoC(dDataBsFim),10) ,oFontC,nColTot/3,100,,ALIGN_H_CENTER)
	oPrinter:SayAlign(nLin,nCol + nColTot/3, Padr(DtoC(DAAUXI),10)+" A "+Padr(DtoC(DAAUXF),10) ,oFontC,nColTot/3,100,,ALIGN_H_CENTER)
	oPrinter:SayAlign(nLin,nCol + (nColTot/3)*2, Padr(DtoC(DAAUXF+1),10) ,oFontC,nColTot/3,100,,ALIGN_H_CENTER)		
EndIf

nLin += 25

If cImpAvFer == "1"
	oPrinter:SayAlign(nLin,nCol + ((nColTot/5)*2),"A remuneração correspondente as férias e, se for o caso," ,oFontC,nColTot,100,,ALIGN_H_LEFT)

	nLin += 15
	oPrinter:SayAlign(nLin,nCol,Space(10) + "ao abono pecuniário e ao adiantamento da gratificação de natal, estará disponível no" ,oFontC,nColTot,100,,ALIGN_H_LEFT)

	nLin += 15
	oPrinter:SayAlign(nLin,nCol,Space(10) + "dia " + Padr(DtoC(dDataRecib),10)+"." ,oFontC,nColTot,100,,ALIGN_H_LEFT)

	If lImpBco
		nLin += 20
		oPrinter:SayAlign(nLin,nCol,Space(10) + LTrim("Banco: ") + cBcoDesc ,oFontC,nColTot,100,,ALIGN_H_LEFT)

		nLin += 15
		oPrinter:SayAlign(nLin,nCol,Space(10) + LTrim("Agência/Conta: ") + cBcoAg + "/" + cBcoCta ,oFontC,nColTot,100,,ALIGN_H_LEFT)
	EndIf
EndIf	

//--Assinatura empresa e funcionário
nLin += 50
oPrinter:Line( nLin, nCol, nLin, (nColTot - (nColTot/2)) - 10	, 0 , "-6")
oPrinter:Line( nLin, (nColTot/2), nLin, nColTot - 20 , 0 , "-6")

nLin += 5
oPrinter:SayAlign(nLin,nCol, AllTrim(Left(aInfo[3],45)) ,oFontC,(nColTot - (nColTot/2)) - 10,100,,ALIGN_H_CENTER)

If !Empty(SRA->RA_NSOCIAL)
	oPrinter:SayAlign(nLin,(nColTot/2) , AllTrim(Left(SRA->RA_NSOCIAL, 45)) ,oFontC,(nColTot/2) - 10,100,,ALIGN_H_CENTER)
Else
	oPrinter:SayAlign(nLin,(nColTot/2) , AllTrim(Left(SRA->RA_NOME, 45)) ,oFontC,(nColTot/2) - 10,100,,ALIGN_H_CENTER)
EndIf

oPrinter:EndPage()

If nTipRel == 2

	cPathFile	:= oPrinter:cPathPDF + cFile

	oPrinter:Preview()
	FreeObj(oPrinter)
	oPrinter := Nil
	
	//Faz upload do documento para o TAE
	lOk := oSign:uploadDocument( cPathFile+".pdf" )
	jResponse := oSign:getResponse()

	If File(cPathFile+".pdf")
		fErase(cPathFile+".pdf")
	EndIf	

	If lOk
		nId := jResponse[ "data" ]
		cId := "_"+cValToChar(nId)
		
		//Envia solicitação para o usuário assinar
		If !Empty(SRA->RA_EMAIL)
			lOk  := oSign:requestAction( jResponse[ "data" ], { { SRA->RA_EMAIL, "0" } } )
			jResponse := oSign:getResponse()
		EndIf

		aAdd(aLogTAE[2], SRA->RA_FILIAL + " - " + SRA->RA_MAT + ": " + If(Empty(SRA->RA_EMAIL), "E-mail não cadastrado. Não foi enviado solicitação de assinatura para o colaborador.", "Solicitação enviada para " + AllTrim(SRA->RA_EMAIL)) )
		If Empty(aLogTitle[2])
			aLogTitle[2] := "Avisos enviados:"
		EndIf

		fGrvREQ(cPathFile, DaAuxI, DaAuxF, nId, "2")
	Else
		aAdd(aLogTAE[4], SRA->RA_FILIAL + " - " + SRA->RA_MAT + ": " + cValToChar(jResponse[ "description" ]))
		If Empty(aLogTitle[4])
			aLogTitle[4] := "Avisos não enviados:"
		EndIf
	EndIf	
EndIf	

RestArea(aArea)

Return Nil

/*/{Protheus.doc}MesExtenso
Opção de meses
@version P12
@return Nil
/*/
Static Function MesExtenso(nMes)

Local aMeses := { OemToAnsi("Janeiro"),OemToAnsi("Fevereiro"),OemToAnsi("Março"),;
				  OemToAnsi("Abril"),OemToAnsi("Maio"),OemToAnsi("Junho"),;
				  OemToAnsi("Julho"),OemToAnsi("Agosto"),OemToAnsi("Setembro"),;
				  OemToAnsi("Outubro"),OemToAnsi("Novembro"),OemToAnsi("Dezembro") }
Local cRet	 := ""

cRet := aMeses [ nMes ]

Return cRet

/*/{Protheus.doc}fGrvREQ
Grava os arquivos enviados para o TAE na tabela REQ
@version P12
@return Nil
/*/
Static Function fGrvREQ(cArquivo, dDtIni, dDtFim, nId, cTpDoc)

RecLock("REQ", .T.)

REQ->REQ_FILIAL := SRA->RA_FILIAL
REQ->REQ_MAT	:= SRA->RA_MAT
REQ->REQ_DTINI	:= dDtIni
REQ->REQ_DTFIM 	:= dDtFim
REQ->REQ_NDOC	:= cArquivo
REQ->REQ_TPDOC	:= cTpDoc
REQ->REQ_ID 	:= nId
REQ->REQ_DTINTE	:= Date()
REQ->REQ_STATUS	:= "N"

REQ->(MsUnLock())

Return Nil

Static Function Scheddef()  
	Local aParam
	Local aOrd  := {"Matricula", "C.Custo + Matric", "C.Custo + Nome", "Nome"}
	
	aParam	:= { "P", "GPR1033", "", aOrd, }

Return aParam  
