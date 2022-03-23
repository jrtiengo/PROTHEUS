#INCLUDE "FINA260.ch"
#INCLUDE "PROTHEUS.CH"

Static _oFINA2601

/*/
FINA260 customizado para debug
/*/

User Function FIN260J( nPosArotina, lAutomato )

	Local nSavInd := IndexOrd()
	Local nSavRec	:= Recno()

	Private aRotina := MenuDef()
	Private cCadastro := STR0001 //"Conciliação DDA"

	Default nPosArotina := 0 //Variável criada para teste de automação
	Default lAutomato := .F. //Variável criada para teste de automação

	If !FDdaInUse() .and. !lAutomato
		Alert (STR0002+CHR(13)+;  //"O tratamento para DDA - Débito Direto Autorizado não está corretamente implementado."
					STR0003)      //"Por favor, execute o atualizador U_UPDFIN com data posterior a 01/10/09."
		Return
	Endif

	dbSelectArea("FIG")
	dbSetOrder(1)
	dbGoTop()

	If nPosArotina > 0
		bBlock := &( "{ |x,y,z,k| " + aRotina[ nPosArotina,2 ] + "(x,y,z,k) }" )
		dbSelectArea("FIG")
		Eval( bBlock,Alias(),FIG->(Recno()),nPosArotina,lAutomato)
	Else
		mBrowse( 6, 1,22,75,"FIG",,,,,,Fa260Leg())
		SET KEY VK_F12 TO
	EndIf

	dbSelectArea("FIG")
	dbSetOrder(nSavInd)
	dbGoTo(nSavRec)

Return

/*/
Conciliação
/*/
User Function F260Conc( cAlias, nReg, nOpcx, lAutomato )

	Local aArea		:= GetArea()
	Local lOk		:= .F.
	Local aSays		:= {}
	Local aButtons	:= {}

	Default lAutomato	   := .F.


	// MV_PAR01: Considera Filiais Abaixo                            ³
	// MV_PAR02: Filial De                                           ³
	// MV_PAR03: Filial Ate                                          ³
	// MV_PAR04: Fornecedor De                                       ³
	// MV_PAR05: Fornecedor Ate                                      ³
	// MV_PAR06: Loja De			                                      ³
	// MV_PAR07: Loja Ate		                                      ³
	// MV_PAR08: Considera Vencto ou Vencto Real                     ³
	// MV_PAR09: Vencto De                                           ³
	// MV_PAR10: Vencto Ate                                          ³
	// MV_PAR11: Dt. de Processamento do Arquivo DDA De              ³
	// MV_PAR12: Dt. de Processamento do Arquivo DDA Ate             ³
	// MV_PAR13: Avancar Dias (Vencto + nDias)                       ³
	// MV_PAR14: Retroceder Dias (Vencto - nDias)                    ³
	// MV_PAR15: Diferenca a Menor                                   ³
	// MV_PAR16: Diferenca a Maior                                   ³

	Pergunte("FIN260",.F.)

	If !lAutomato
		aADD(aSays,STR0004) //"Esta rotina tem como objetivo a conciliação das informações importadas através de"
		aADD(aSays,STR0005) //"processamento de arquivo de retorno DDA com os dados dos regitros de títulos de  "
		aADD(aSays,STR0006) //"contas a pagar(tabela SE2) para obtenção dos códigos de barra dos boletos bancários."

		aADD(aButtons, { 5,.T.,{|| Pergunte("FIN260",.T. ) } } )
		aADD(aButtons, { 1,.T.,{|| lOk := .T.,FechaBatch()}} )
		aADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
		FormBatch( cCadastro, aSays, aButtons ,,,535)
	Else
		lOk := .T.
	Endif

	If lOk
		Processa({|lEnd| U_F260Gera(lAutomato)})  // Chamada com regua
	Endif

RestArea(aArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ F260Gera ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 01/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Conciliacao DDA - Debito Direto Autorizado                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ F260Gera()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA260                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function F260Gera( lAutomato )

	Local cRecTRB   := ""
	Local lSaida	:= .F.
	Local nOpca		:= 0
	Local aCores 	:= {}
	Local cVarQ     := "  "
	Local oTitulo
	Local oBtn
	Local oDlg
	Local dDtIni	:= CTOD("01/01/1980","ddmmyy")
	Local dDtFin	:= CTOD("01/01/1980","ddmmyy")
	Local nTamCodBar	:= TAMSX3("FIG_CODBAR")[1]
	Local nTamIdCnab	:= TAMSX3("E2_IDCNAB")[1]
	Local cQuery := ""
	Local cAliasFIG := ""
	Local cAliasSE2 := ""
	Local cCampos := ""
	Local nX := 0
	Local cFilSE2 	:= ""
	Local cFornece	:= ""
	Local cLoja		:= ""
	Local cNum		:= ""
	Local cTipo		:= ""
	Local cVencto	:= ""
	Local cVencMin	:= ""
	Local cVencMax	:= ""
	Local cValor	:= ""
	Local cValorMin := ""
	Local cValorMax := ""
	Local cTitSE2	:= ""
	Local cSeqSe2  := ""
	Local nValorMin:= 0
	Local nValorMax:= 0
	Local nRecSe2	:= 0
	Local nRecDDA	:= 0
	Local nRecTrb  := 0
	Local dVencMin	:= CTOD("//")
	Local dVencMax	:= CTOD("//")
	Local cChave	:= ""
	Local cCPNEG	:=	MV_CPNEG
	Local lPCCBaixa  := SuperGetMv("MV_BX10925",.T.,"2") == "1"
	Local lCalcIssBx := SuperGetMV("MV_MRETISS",.T.,"1") == "2"
	Local oOk	:= LoadBitmap( GetResources(), "ENABLE"		)	//Nivel 1
	Local oN2	:= LoadBitmap( GetResources(), "BR_AZUL"		)	//Nivel 2
	Local oN3	:= LoadBitmap( GetResources(), "BR_PRETO"		)	//Nivel 3
	Local oN4	:= LoadBitmap( GetResources(), "BR_CINZA"		)	//Nivel 4
	Local oN5	:= LoadBitmap( GetResources(), "BR_BRANCO"	)	//Nivel 5
	Local oN6	:= LoadBitmap( GetResources(), "BR_AMARELO"	)	//Nivel 6
	Local oN7	:= LoadBitmap( GetResources(), "BR_LARANJA"	)	//Nivel 7
	Local oN8	:= LoadBitmap( GetResources(), "BR_PINK"		)	//Nivel 8
	Local oNo	:= LoadBitmap( GetResources(), "DISABLE"		)	//Nivel 9
	Local nScan := 0
	Local lOk   := nil
	Local aTab  := {}
	Local lDup  := .F.
	Local nNivel := 9
	Local lF260DUPL   := Existblock("F260DUPL") //Ponto de Entrada para tratamento de Duplicidades na tabela TRB
	Local lF260LJCON  := Existblock("F260LJCON") //Esse ponto de entrada tem por finalidade permitir alterar a loja da tabela FIG
	Local nRecFIG     := 0
	Local cLojaFIG    := ""
	Local dDtaVenc    := dDataBase
	Local cVLQ_SE2    := ""
	Local cVLR_SE2    := ""
	Local nVLQ_SE2    := 0
	Local lFA260GRSE2 := ExistBlock("FA260GRSE2")
	Local lFA260GRFIG := ExistBlock("FA260GRFIG")

	Aadd(aCores,oOk)
	Aadd(aCores,oN2)
	Aadd(aCores,oN3)
	Aadd(aCores,oN4)
	Aadd(aCores,oN5)
	Aadd(aCores,oN6)
	Aadd(aCores,oN7)
	Aadd(aCores,oN8)
	Aadd(aCores,oNo)

	//Array que conterao os registros lockados com o usuario
	Private aRLocksSE2 := {}
	Private aRLocksFIG := {}

	Default lAutomato		:= .F.

	//Tratamento para adiantamento tipo NCC
	If "|" $ cCPNEG
		cCPNEG	:=	StrTran(MV_CPNEG,"|","")
	ElseIf "," $ cCPNEG
		cCPNEG	:=	StrTran(MV_CPNEG,",","")
	Endif
	If Mod(Len(cCPNEG),3) > 0
		cCPNEG	+=	Replicate(" ",3-Mod(Len(cCPNEG),3))
	Endif

	//Verifico se o parametro Vencto de/Ate nao esta vazio
	dDtIni	:= Max(dDtIni,Iif(Empty(mv_par09),dDtIni,mv_par09))
	dDtFin	:= Max(dDtFin,Iif(Empty(mv_par10),dDtFin,mv_par10))

	// Acrescento/diminuo das variaveis para abrir periodo
	dDtIni	:= dDtIni - mv_par14
	dDtFin	:= dDtFin + mv_par13

	//Cria arquivo de trabalho
	F260CRIARQ()

//Filtra dados do FIG - Conciliacao DDA
FIG->(dbSetOrder(2)) //Filial+Fornecedor+Loja+Vencto+Titulo
cChave		:= FIG->(IndexKey())
cAliasFIG	:= GetNextAlias()
aStru		:= FIG->(dbStruct())
cCampos		:= ""
cFilIn 		:= F260Filial()

aEval(aStru,{|x| cCampos += ","+AllTrim(x[1])})
cQuery := "SELECT "+SubStr(cCampos,2) + ", R_E_C_N_O_ RECNOFIG "
cQuery += "FROM " + RetSqlName("FIG") + " FIG  WHERE "
cQuery +=		"FIG_FILIAL IN "	+ FormatIn(cFilIn,"/") + " AND "
cQuery += 		"FIG_FORNEC  >= '"+ mv_par04 + "' AND "
cQuery += 		"FIG_FORNEC  <= '"+ mv_par05 + "' AND "
cQuery += 		"FIG_LOJA >= '"	+ mv_par06 + "' AND "
cQuery += 		"FIG_LOJA <= '"	+ mv_par07 + "' AND "
cQuery +=		"FIG_VENCTO >= '"	+ DTOS(dDtIni) + "' AND "
cQuery +=		"FIG_VENCTO <= '"	+ DTOS(dDtFin) + "' AND "
cQuery +=		"FIG_DATA >= '"	+ DTOS(mv_par11) + "' AND "
cQuery +=		"FIG_DATA <= '"	+ DTOS(mv_par12) + "' AND "
cQuery += 		"FIG_VALOR > 0 AND "
cQuery +=		"FIG_CONCIL = '2' AND "
cQuery +=		"FIG_CODBAR <> '"	+ Space(nTamCodbar) + "' AND "
cQuery +=		"D_E_L_E_T_ = ' ' "
cQuery +=	"ORDER BY " + SqlOrder(cChave)

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasFIG,.T.,.T.)

If (cAliasFIG)->(!Eof())
	For nX :=  1 To Len(aStru)
		If aStru[nX][2] <> "C" .And. FieldPos(aStru[nX][1]) > 0
			TcSetField(cAliasFIG, aStru[nX][1], aStru[nX][2], aStru[nX][3], aStru[nX][4])
		EndIf
	Next nX
EndIf

If ((cAliasFIG)->(Bof()) .or. (cAliasFIG)->(Eof())) .and. !lAutomato
	Help(" ",1,"NORECFIG",,STR0008+CHR(10)+STR0009,1,0) //"Nenhum registro DDA encontrado"###"Por favor, verifique parametrização"
	lSaida := .T.
Endif

If !lSaida
	While (cAliasFIG)->(!Eof())
		If !U_F260Verif(cAliasFIG)
			//Grava dados no arquivo de trabalho
			DbSelectArea("TRB")
			RecLock("TRB",.T.)
			cRecTRB  := STRZERO(TRB->(Recno()))
			nRecFIG  :=  (cAliasFIG)->RECNOFIG
			cLojaFIG := (cAliasFIG)->FIG_LOJA

			If lF260LJCON
				cLojaFIG := ExecBlock("F260LJCON",.F.,.F., {nRecFIG, cLojaFIG})
			EndIf

			TRB->SEQMOV  := SUBSTR(cRecTRB,-5)
			TRB->SEQCON	 := ""
			TRB->FIL_DDA := (cAliasFIG)->FIG_FILIAL
			TRB->FOR_DDA := (cAliasFIG)->FIG_FORNEC
			TRB->NOM_DDA := (cAliasFIG)->FIG_NOMFOR
			TRB->LOJ_DDA := cLojaFIG
			TRB->TIT_DDA := (cAliasFIG)->FIG_TITULO+"000000"
			TRB->TIP_DDA := (cAliasFIG)->FIG_TIPO
			TRB->DTV_DDA := (cAliasFIG)->FIG_VENCTO
			TRB->VLR_DDA := Transform((cAliasFIG)->FIG_VALOR, "@E 999,999,999,999.99")
			TRB->REC_DDA := nRecFIG
			TRB->OK      := 9		// NAO CONCILIADO
			TRB->CODBAR  := (cAliasFIG)->FIG_CODBAR
			MsUnlock()
		Endif
		(cAliasFIG)->(dbSkip())
	Enddo

	//Filtra dados do SE2 - Contas a Pagar
	cAliasSE2 := GetNextAlias()
	aStru     := SE2->(dbStruct())
	cCampos   := ""
	cFilIn    := F260Filial()

	cQuery := "SELECT E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA,E2_NOMFOR,E2_EMISSAO,E2_VENCTO, "
	cQuery += "E2_VENCREA,E2_VALOR,E2_EMIS1,E2_HIST,E2_SALDO,E2_ACRESC,E2_ORIGEM,E2_TXMOEDA,E2_SDACRES,E2_DECRESC, "
	cQuery += "E2_SDDECRE,E2_IDCNAB,E2_FILORIG,E2_CODBAR,E2_STATUS,E2_DTBORDE,E2_PIS,E2_COFINS,E2_CSLL,E2_IRRF,E2_INSS, "
	cQuery += "E2_ISS, E2_VRETPIS,E2_VRETCOF,E2_VRETCSL,E2_VRETIRF,E2_VRETISS,R_E_C_N_O_ RECNOSE2 "
	cQuery += "FROM " + RetSqlName("SE2") + " SE2  WHERE "
	cQuery += "E2_FILIAL IN "	+ FormatIn(cFilIn,"/") + " AND "
	cQuery += "E2_FORNECE  >= '"+ mv_par04 + "' AND "
	cQuery += "E2_FORNECE  <= '"+ mv_par05 + "' AND "
	cQuery += "E2_LOJA >= '"	+ mv_par06 + "' AND "
	cQuery += "E2_LOJA <= '"	+ mv_par07 + "' AND "

	//Considera Vencto do titulo
	If mv_par08 == 1
		cQuery +=	"E2_VENCTO >= '"	+ DTOS(dDtIni) + "' AND "
		cQuery +=	"E2_VENCTO <= '"	+ DTOS(dDtFin) + "' AND "
		cChave := "E2_FORNECE+E2_LOJA+DTOS(E2_VENCTO)+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO"
	Else//Considera Vencto real do titulo
		cQuery +=	"E2_VENCREA >= '"	+ DTOS(dDtIni) + "' AND "
		cQuery +=	"E2_VENCREA <= '"	+ DTOS(dDtFin) + "' AND "
		cChave := "E2_FORNECE+E2_LOJA+DTOS(E2_VENCREA)+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO"
	Endif

	cQuery += 		"E2_SALDO > 0 AND "
	cQuery += 		"E2_TIPO NOT IN " + FORMATIN(cCPNEG+MVPAGANT,,3) + " AND "
	cQuery += 		"E2_TIPO NOT IN " + FORMATIN(MVABATIM,'|') + " AND "
	cQuery += 		"E2_TIPO NOT IN " + FORMATIN(MVTXA+"INA",,3) + " AND "
	cQuery += 		"E2_TIPO NOT IN " + FORMATIN(MVTAXA,,3) + " AND "
	cQuery += 		"E2_TIPO NOT IN " + FORMATIN(MVPROVIS,,3) + " AND "
	cQuery +=		"E2_CODBAR = '"	+ Space(nTamCodbar) + "' AND "
	cQuery +=		"E2_IDCNAB = '"	+ Space(nTamIdCnab) + "' AND "
	cQuery +=		"D_E_L_E_T_ = ' ' "
	cQuery +=	"ORDER BY " + SqlOrder(cChave)
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery), cAliasSE2, .T.,.T.)

	If (cAliasSE2)->(!Eof())
		For nX :=  1 To Len(aStru)
			If aStru[nX][2] <> "C" .And. FieldPos(aStru[nX][1]) > 0
				TcSetField(cAliasSE2, aStru[nX][1], aStru[nX][2], aStru[nX][3], aStru[nX][4])
			EndIf
		Next nX
	EndIf

	WHILE (cAliasSE2)->(!Eof())
		dDtaVenc := Iif(mv_par08 == 1, (cAliasSE2)->E2_VENCTO, (cAliasSE2)->E2_VENCREA)

		aAdd(aTab,{	(cAliasSE2)->E2_FILIAL, (cAliasSE2)->E2_FORNECE, (cAliasSE2)->E2_LOJA,;
					dDtaVenc, Transform((cAliasSE2)->E2_VALOR, "@E 999,999,999,999.99"), (cAliasSE2)->RECNOSE2})
		(cAliasSE2)->(DbSkip())
	EndDo

	(cAliasSE2)->(DbGoTop())

	If ((cAliasSE2)->(Bof()) .or. (cAliasSE2)->(Eof())) .and. !lAutomato
		Help(" ",1,"NORECSE2",,STR0042+CHR(10)+STR0009,1,0)		//"Nenhum registro encontrado no arquivo de contas a pagar (SE2)"###"Por favor, verifique parametrização"
		lSaida := .T.
	Else
		dbSelectArea(cAliasSE2)

		While (cAliasSE2)->(!Eof())
			nVLQ_SE2   := (cAliasSE2)->E2_SALDO
			lIRPFBaixa := cPaisLoc = "BRA" .And. (cAliasSE2)->E2_IRRF > 0 .And.;
			SA2->(DbSeek(FWxFilial("SA2", (cAliasSE2)->E2_FILORIG)+(cAliasSE2)->(E2_FORNECE+E2_LOJA))) .And. SA2->A2_CALCIRF == "2"

			//VERIFICA SE IMPOSTOS SÃO CALCULADOS NA EMISSÃO OU NA BAIXA PARA COMPOR VALOR LÍQUIDO
			If lPCCBaixa .And. (cAliasSE2)->(E2_PIS+E2_COFINS+E2_CSLL) > 0
				nVLQ_SE2 -= (cAliasSE2)->(E2_PIS+E2_COFINS+E2_CSLL) - (cAliasSE2)->(E2_VRETPIS+E2_VRETCOF+E2_VRETCSL)
			EndIf

			If lIRPFBaixa .And. (cAliasSE2)->E2_IRRF > 0
				nVLQ_SE2 -= (cAliasSE2)->E2_IRRF - (cAliasSE2)->E2_VRETIRF
			EndIf

			If lCalcIssBx .And. (cAliasSE2)->E2_ISS > 0
				nVLQ_SE2 -= (cAliasSE2)->E2_ISS - (cAliasSE2)->E2_VRETISS
			EndIf

			cVLR_SE2 := Transform((cAliasSE2)->E2_VALOR, "@E 999,999,999,999.99")
			cVLQ_SE2 := Transform(nVLQ_SE2, "@E 999,999,999,999.99")
			dDtaVenc := Iif(mv_par08 == 1, (cAliasSE2)->E2_VENCTO, (cAliasSE2)->E2_VENCREA)

			//Grava dados do SE2 no arquivo de trabalho
			DbSelectArea("TRB")
			RecLock("TRB",.T.)
			cRecTRB := STRZERO(TRB->(Recno()))

			TRB->SEQMOV 	:= SUBSTR(cRecTRB,-5)
			TRB->SEQCON		:= ""
			TRB->FIL_SE2	:= (cAliasSE2)->E2_FILIAL
			TRB->FOR_SE2	:= (cAliasSE2)->E2_FORNECE
			TRB->LOJ_SE2	:= (cAliasSE2)->E2_LOJA
			TRB->NOM_SE2	:= (cAliasSE2)->E2_NOMFOR
			TRB->TIT_SE2	:= (cAliasSE2)->(E2_PREFIXO+"-"+E2_NUM+"-"+E2_PARCELA)
			TRB->KEY_SE2	:= (cAliasSE2)->(E2_PREFIXO+E2_NUM+E2_PARCELA)
			TRB->TIP_SE2	:= (cAliasSE2)->E2_TIPO
			TRB->DTV_SE2	:= dDtaVenc
			TRB->VLR_SE2	:= cVLR_SE2
			TRB->VLQ_SE2	:= cVLQ_SE2
			TRB->PIS_SE2	:= (cAliasSE2)->E2_PIS
			TRB->COF_SE2	:= (cAliasSE2)->E2_COFINS
			TRB->CSL_SE2	:= (cAliasSE2)->E2_CSLL
			TRB->IRF_SE2	:= (cAliasSE2)->E2_IRRF
			TRB->INS_SE2	:= (cAliasSE2)->E2_INSS
			TRB->ISS_SE2	:= (cAliasSE2)->E2_ISS
			TRB->REC_SE2	:= (cAliasSE2)->RECNOSE2
			TRB->OK     	:= 9 //NÃO CONCILIADO
			MsUnlock()

			cFilSE2 	:= TRB->FIL_SE2
			cFornece	:= TRB->FOR_SE2
			cLoja		:= TRB->LOJ_SE2
			cNum		:= TRB->KEY_SE2
			cTipo		:= TRB->TIP_SE2
			cVencto	    := DTOS(TRB->DTV_SE2)
			dVencMin	:= TRB->DTV_SE2- mv_par14
			dVencMax	:= TRB->DTV_SE2+ mv_par13
			cVencMin	:= DTOS(dVencMin)
			cVencMax	:= DTOS(dVencMax)
			cValor      := cVLQ_SE2
			nValorMin   := (cAliasSE2)->E2_VALOR - mv_par15
			nValorMax   := (cAliasSE2)->E2_VALOR + mv_par16
			cValorMin   := Transform(nValorMin, "@E 999,999,999,999.99")
			cValorMax   := Transform(nValorMax, "@E 999,999,999,999.99")
			cTitSE2	    := TRB->TIT_SE2
			nRecSe2	    := TRB->REC_SE2
			cSeqSe2     := TRB->SEQMOV
			nRecTrb     := TRB->(Recno())

			//Tento pre-reconciliacao dentro da Filial + Fornecedor + Loja + Data Vencto + Valor + Ttulo
			DbSelectArea("TRB")
			DbSetOrder(1)	//FOR_DDA+LOJ_DDA+DTV_DDA+TIT_DDA"
			nRecno := TRB->(Recno())

			//***************************************************
			// Incluido Data de vencimento  no seek para deixar *
			// a chave de pesquisa mais forte. Caso a mesma nao *
			// seja encontrada a chave sera Forncedeor e Loja   *
			//***************************************************
			If ((nScan := aScan(aTab, {|x| x[1] == (cAliasSE2)->E2_FILIAL .And.;
				x[4] == dDtaVenc .And.;
				x[5] == cVLR_SE2 .And.;
				x[2]+x[3] == (cAliasSE2)->E2_FORNECE+(cAliasSE2)->E2_LOJA .And. ;
				x[6] <> (cAliasSE2)->RECNOSE2} ))) > 0

				lDup := .T.

				If lF260DUPL
					lDup := ExecBlock("F260DUPL",.F.,.F., {'ONBUILDTRB','TRB', TRB->SEQMOV, (cAliasSE2)->RECNOSE2} )
				EndIf

				If lDup
					(cAliasSE2)->(dbskip())
					Loop
				EndIf
			EndIf

			If DbSeek(cFornece + cLoja + cVencto ) .And. cFilSe2 == TRB->FIL_DDA .And.;
				Empty(TRB->SEQCON) .And. TRB->VLR_DDA == cVLQ_SE2 .And. F260Lock(.T.,aRLocksSE2,aRLocksFIG,nRecSe2,TRB->REC_DDA)
				nNivel := 1
				nRecno := Recno()

				DbGoTo(nRecTrb)
				dbDelete()
				dbGoto(nRecno)
				RecLock("TRB")
				TRB->SEQCON 	:= SUBSTR(cRecTRB,-5)
				TRB->FIL_SE2	:= (cAliasSE2)->E2_FILIAL
				TRB->FOR_SE2	:= (cAliasSE2)->E2_FORNECE
				TRB->LOJ_SE2	:= (cAliasSE2)->E2_LOJA
				TRB->NOM_SE2	:= (cAliasSE2)->E2_NOMFOR
				TRB->TIT_SE2	:= (cAliasSE2)->(E2_PREFIXO+"-"+E2_NUM+"-"+E2_PARCELA)
				TRB->KEY_SE2	:= (cAliasSE2)->(E2_PREFIXO+E2_NUM+E2_PARCELA)
				TRB->TIP_SE2	:= (cAliasSE2)->E2_TIPO
				TRB->DTV_SE2	:= dDtaVenc
				TRB->VLR_SE2	:= cVLR_SE2
				TRB->VLQ_SE2	:= cVLQ_SE2
				TRB->REC_SE2	:= (cAliasSE2)->RECNOSE2
				TRB->OK     	:= nNivel	// NIVEL DE CONCILIACAO
				MsUnlock()
			ElseIf DbSeek(cFornece + cLoja)
				nRecno := Recno()

				While !(TRB->(Eof())) .and. TRB->(FOR_DDA+LOJ_DDA) == cFornece+cLoja
					If !Empty(TRB->SEQCON)
						TRB->(dbSkip())
						Loop
					EndIf

					nNivel    := 9 //Nao conciliado

					If cFilSe2 == TRB->FIL_DDA
						//Chave exata: Filial, Data Vencto e Valor - OK
						If TRB->VLR_DDA == cVLQ_SE2 .And. DTOS(TRB->DTV_DDA) == cVencto
							nNivel := 1
							nRecno := Recno()
							Exit
						//Filial - OK, Data Vencto - OK, Valor - Intervalo
						ElseIf DTOS(TRB->DTV_DDA) == cVencto .And. TRB->VLR_DDA >= cValorMin .And. TRB->VLR_DDA <= cValorMax
							nNivel := 2
							nRecno := Recno()
							Exit
						//Filial - OK, Data Vencto - Intervalo, Valor - OK
						ElseIf DTOS(TRB->DTV_DDA) >= cVencMin .And. DTOS(TRB->DTV_DDA) <= cVencMax .And. TRB->VLR_DDA == cVLQ_SE2
							nNivel := 3
							nRecno := Recno()
							Exit
						//Filial - OK, Data Vencto - Intervalo, Valor - Intervalo
						ElseIf DTOS(TRB->DTV_DDA) >= cVencMin .And. DTOS(TRB->DTV_DDA) <= cVencMax .And. TRB->VLR_DDA >= cValorMin .And. TRB->VLR_DDA <= cValorMax
							nNivel := 4
							nRecno := Recno()
							Exit
						EndIf
					Else
						//Filial - Diferente, Data Vencto - OK, Valor - OK
						If TRB->VLR_DDA == cVLQ_SE2 .And. DTOS(TRB->DTV_DDA) == cVencto
							nNivel := 5
							nRecno := Recno()
							Exit
						//Filial - Diferente, Data Vencto - OK, Valor - Intervalo
						ElseIf DTOS(TRB->DTV_DDA) == cVencto .And. TRB->VLR_DDA >= cValorMin .And. TRB->VLR_DDA <= cValorMax
							nNivel := 6
							nRecno := Recno()
							Exit
						//Filial - Diferente, Data Vencto - intevalo, Valor - OK
						ElseIf TRB->VLR_DDA == cVLQ_SE2 .And. DTOS(TRB->DTV_DDA) >= cVencMin .And. DTOS(TRB->DTV_DDA) <= cVencMax
							nNivel := 7
							nRecno := Recno()
							Exit
						//Filial - Diferente, Data Vencto - intervalo, Valor - Intervalo
						ElseIf DTOS(TRB->DTV_DDA) >= cVencMin .And. DTOS(TRB->DTV_DDA) <= cVencMax .And. TRB->VLR_DDA >= cValorMin .And. TRB->VLR_DDA <= cValorMax
							nNivel := 8
							nRecno := Recno()
							Exit
						EndIf
					EndIf

					TRB->(dbSkip())
					Loop
				EndDo

				If nNivel < 9 .And. Type('lOk') == "U"
					lOk := .T.
				EndIf

				//Caso houve algum tipo de possibilidade de conciliacao
				If nNivel < 9
					//Caso tenho conseguido travar os registros do SE2 e FIG
					If F260Lock(.T., aRLocksSE2,aRLocksFIG,nRecSe2,TRB->REC_DDA) .And. lOk
						DbGoTo(nRecTrb)
						dbDelete()
						dbGoto(nRecno)
						RecLock("TRB")
						TRB->SEQCON 	:= SUBSTR(cRecTRB,-5)
						TRB->FIL_SE2	:= (cAliasSE2)->E2_FILIAL
						TRB->FOR_SE2	:= (cAliasSE2)->E2_FORNECE
						TRB->LOJ_SE2	:= (cAliasSE2)->E2_LOJA
						TRB->NOM_SE2	:= (cAliasSE2)->E2_NOMFOR
						TRB->TIT_SE2	:= (cAliasSE2)->(E2_PREFIXO+"-"+E2_NUM+"-"+E2_PARCELA)
						TRB->KEY_SE2	:= (cAliasSE2)->(E2_PREFIXO+E2_NUM+E2_PARCELA)
						TRB->TIP_SE2	:= (cAliasSE2)->E2_TIPO
						TRB->DTV_SE2	:= If(mv_par08 == 1,(cAliasSE2)->E2_VENCTO,(cAliasSE2)->E2_VENCREA )
						TRB->VLR_SE2	:= cVLR_SE2
						TRB->VLQ_SE2	:= cVLQ_SE2
						TRB->REC_SE2	:= (cAliasSE2)->RECNOSE2
						TRB->OK     	:= nNivel	// NIVEL DE CONCILIACAO
						MsUnlock()
					Endif
					lOk := .T.
				Endif
			Endif
			(cAliasSE2)->(dbSkip())
		Enddo

		If lDup
			If !lAutomato
				Alert("Existe mais de uma chave possivel para a conciliação automática, por este motivo a conciliação de alguns títulos deverá ser feita de forma manual.")
			EndIf
			If lF260DUPL
				ExecBlock("F260DUPL",.F.,.F.,{'AFTERBUILDTRB','TRB',NIL,NIL})
			EndIf
		EndIf

		dbSelectArea("TRB")
		TRB->(DbSetOrder(7))	//SEQMOV+FOR_DDA+LOJ_DDA+DTV_DDA+TIT_DDA"
		TRB->(dbGoTop())

		If !lAutomato //Abre interface só caso não for processo automatico

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Faz o calculo automatico de dimensoes de objetos     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aSize := MSADVSIZE()

			DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL
			oDlg:lMaximized := .T.

			oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,30,30,.T.,.T. )

			DEFINE SBUTTON FROM 10,250 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oPanel
			DEFINE SBUTTON FROM 10,280 TYPE 2 ACTION (nOpca := 0,oDlg:End()) ENABLE OF oPanel
			DEFINE SBUTTON oBtn  FROM 10,310	TYPE 15 ACTION (U_F260Pesq(oTitulo))		ENABLE OF oPanel
			DEFINE SBUTTON oBtn2 FROM 10,340 TYPE 11 ACTION (U_F260LEGTRB())		ENABLE PIXEL OF oPanel

			oBtn:cToolTip	:= STR0010 //"Pesquisa"
			oBtn:cCaption	:= STR0010 //"Pesquisa"
			oBtn2:cToolTip	:= STR0011 //"Legenda"
			oBtn2:cCaption	:= STR0011 //"Legenda"
			oPanel:Align	:= CONTROL_ALIGN_BOTTOM


			@ 01.0,.5 	LISTBOX oTitulo VAR cVarQ FIELDS ;
					 		HEADER "", 	STR0012,;	//"Seq."
										STR0013,;	//"Filial DDA"
								 		STR0014,;	//"Fornec.DDA"
								 		STR0015,;	//"Loja DDA"
								 		STR0071,;	//"Nome Fornec.DDA"
										STR0016,;	//"Titulo DDA"
										STR0017,;	//"Tipo DDA"
										STR0018,;	//"Vencto.DDA"
										STR0019,;	//"Valor DDA"
										STR0020,;	//"Filial SE2"
										STR0021,;	//"Fornec.SE2"
										STR0022,;	//"Loja SE2"
										STR0072,;	//"Nome Fornec.SE2"
										STR0023,;	//"Titulo SE2"
										STR0024,;	//"Tipo SE2"
										STR0025,;	//"Vencto.SE2"
										STR0026,;	//"Valor SE2"
										STR0070,;   //"Valor Liq"
							 COLSIZES 12,GetTextWidth(0,"BBBB"),; 			//SEQ
						 	 			 GetTextWidth(0,"BBBB"),;			//Filial
										 GetTextWidth(0,"BBBBB"),;			//Fornecedor
										 GetTextWidth(0,"BBBB"),;			//Loja
										 GetTextWidth(0,"BBBBBBBB"),;		//Nome Fornecedor
										 GetTextWidth(0,"BBBBBBBB"),;		//Titulo
										 GetTextWidth(0,"BBBB"),;			//Tipo
										 GetTextWidth(0,"BBBBBB"),;			//Vencto
										 GetTextWidth(0,"BBBBBBBBB"),;		//Valor
						 	 			 GetTextWidth(0,"BBBB"),;			//Filial
										 GetTextWidth(0,"BBBBB"),;			//Fornecedor
										 GetTextWidth(0,"BBBB"),;			//Loja
										 GetTextWidth(0,"BBBBBBBB"),;		//Nome Fornecedor
										 GetTextWidth(0,"BBBBBBBBBBB"),;	//Titulo
										 GetTextWidth(0,"BBBB"),;			//Tipo
										 GetTextWidth(0,"BBBBBB"),;			//Vencto
										 GetTextWidth(0,"BBBBBBBBB"),;		//Valor
										 GetTextWidth(0,"BBBBBBBBB");		//Valor Liq
			SIZE 345,400 ON DBLCLICK	(F260Marca(oTitulo), oTitulo:Refresh()) NOSCROLL

			If GetFinLGPD()
				oTitulo:aObfuscatedCols := {;
										.F.,;
										.F.,;	//"Seq."
										.F.,;	//"Filial DDA"
								 		.F.,;	//"Fornec.DDA"
								 		.F.,;	//"Loja DDA"
					RetGlbLGPD("FIG_NOMFOR"),;	//"Nome Fornec.DDA"
										.F.,;	//"Titulo DDA"
										.F.,;	//"Tipo DDA"
										.F.,;	//"Vencto.DDA"
										.F.,;	//"Valor DDA"
										.F.,;	//"Filial SE2"
										.F.,;	//"Fornec.SE2"
										.F.,;	//"Loja SE2"
					RetGlbLGPD("E2_NOMFOR"),;	//"Nome Fornec.SE2"
										.F.,;	//"Titulo SE2"
										.F.,;	//"Tipo SE2"
										.F.,;	//"Vencto.SE2"
										.F.,;	//"Valor SE2"
										.F.,;   //"Valor Liq"
				}
			EndIf

			oTitulo:bLine := { || {aCores[TRB->OK],;
											TRB->SEQMOV 	,;
											TRB->FIL_DDA	,;
											TRB->FOR_DDA	,;
											TRB->LOJ_DDA	,;
											TRB->NOM_DDA	,;
											TRB->TIT_DDA	,;
											TRB->TIP_DDA	,;
											TRB->DTV_DDA	,;
											PADR(TRB->VLR_DDA,18),;
											TRB->FIL_SE2	,;
											TRB->FOR_SE2	,;
											TRB->LOJ_SE2	,;
											TRB->NOM_SE2	,;
											TRB->TIT_SE2	,;
											TRB->TIP_SE2	,;
											TRB->DTV_SE2	,;
											PADR(TRB->VLR_SE2,18),;
											PADR(TRB->VLQ_SE2,18) }}

			oTitulo:Align := CONTROL_ALIGN_ALLCLIENT

			ACTIVATE MSDIALOG oDlg CENTERED
        Else
          nOpca := 1
        Endif

		If nOpca == 1 .or. lAutomato
			BEGIN TRANSACTION
				dbSelectArea("TRB")
				dbGoTop()

				While !(TRB->(Eof()))
					nRecSE2 := TRB->REC_SE2
					nRecDDA := TRB->REC_DDA
					//Se houve cociliacao
					//Gravo os dados do codigo de barras no SE2
					//Gravo os dados do titulo SE2 na tabela DDA (FIG)
					If nRecSE2 > 0 .and. nRecDDA > 0
						dbSelectArea("SE2")
						dbGoto(nRecSE2)

						If RecLock("SE2",.F.)
							SE2->E2_CODBAR	:= TRB->CODBAR
							cTitSE2 := SE2->E2_FILIAL+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+;
													SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA+"|"

							//Ponto de Entrada para gravacao complementar SE2
							If lFA260GRSE2
								ExecBlock("FA260GRSE2",.F.,.F.)
							Endif
						Endif

						dbSelectArea("FIG")
						dbGoto(nRecDDA)

						If RecLock("FIG",.F.)
							FIG->FIG_DDASE2	:= cTitSE2		//Chave do SE2 com o qual foi conciliado
							FIG->FIG_CONCIL	:= "1" 			//Conciliado
							FIG->FIG_DTCONC	:= dDatabase	//Data da Conciliacao
							FIG->FIG_USCONC	:= cUsername	//Usuario responsavel pela conciliacao

							//Ponto de Entrada para gravacao complementar FIG
							If lFA260GRFIG
								ExecBlock("FA260GRFIG",.F.,.F.)
							Endif
						Endif
					EndIf

					dbSelectArea("TRB")
					TRB->(dbSkip())
				Enddo
			END TRANSACTION
		EndIf
	Endif
Endif

//Destravar os registros do SE2 e FIG antes de sair
F260Lock(.F.,aRLocksSE2,aRLocksFIG,,,,.T.)

//Finalizar o arquivo de trabalho
dbSelectArea("TRB")
Set Filter To
dbCloseArea()

//Deleta tabela temporária criada no banco de dados
If _oFINA2601 <> Nil
	_oFINA2601:Delete()
	_oFINA2601 := Nil
Endif

IF SELECT("NEWFIG") != 0
   dbSelectArea( "NEWFIG" )
   dbCloseArea()
ENDIF

IF SELECT("NEWSE2") != 0
   dbSelectArea( "NEWSE2" )
   dbCloseArea()
ENDIF

dbSelectArea("FIG")
dbSetOrder(1)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³F260CriArq³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 01/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cria Estrutura do arquivo de trabalho   						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³F260CriArq() 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome do indice 1 (passado por referenc)				  ³±±
±±³			 ³ ExpC2 = Nome do indice 2 (passado por referenc)				  ³±±
±±³			 ³ ExpC3 = Nome do indice 3 (passado por referenc)				  ³±±
±±³			 ³ ExpC4 = Nome do indice 4 (passado por referenc)				  ³±±
±±³			 ³ ExpC5 = Nome do indice 5 (passado por referenc)				  ³±±
±±³			 ³ ExpC6 = Nome do indice 6 (passado por referenc)				  ³±±
±±³			 ³ ExpC7 = Nome do indice 7 (passado por referenc)				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Generico																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F260CriArq()

	Local aDbStru := {}
	Local nTamFil := TamSX3("E2_FILIAL")[1]
	Local nTamTip := TamSX3("E2_TIPO")[1]
	Local nTamFor := TamSX3("E2_FORNECE")[1]
	Local nTamLoj := TamSX3("E2_LOJA")[1]
	Local nTamNome:= TamSX3("E2_NOMFOR")[1]
	//Ao tamanho do titulo serão somados os separadores
	Local nTamTit := TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+nTamFil+5
	Local nTamKey := TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+nTamTip+nTamFil

	//Arquivo de reconciliacao
	//Campos de sequencia de conciliacao
	aadd(aDbStru,{"SEQMOV    ","C",05,0})
	aadd(aDbStru,{"SEQCON    ","C",05,0})

	//Campos do FIG - Conciliacao DDA
	aadd(aDbStru,{"FIL_DDA   ","C",nTamFil,0})
	aadd(aDbStru,{"FOR_DDA   ","C",nTamFor,0})
	aadd(aDbStru,{"LOJ_DDA   ","C",nTamLoj,0})
	aadd(aDbStru,{"NOM_DDA   ","C",nTamNome,0})
	aadd(aDbStru,{"TIT_DDA   ","C",15,0})
	aadd(aDbStru,{"TIP_DDA   ","C",nTamTip,0})
	aadd(aDbStru,{"DTV_DDA   ","D",08,0})
	aadd(aDbStru,{"VLR_DDA   ","C",18,0})

	//Campos do SE2 - Cadastro Conta a Pagar
	aadd(aDbStru,{"FIL_SE2   ","C",nTamFil,0})
	aadd(aDbStru,{"FOR_SE2   ","C",nTamFor,0})
	aadd(aDbStru,{"LOJ_SE2   ","C",nTamLoj,0})
	aadd(aDbStru,{"NOM_SE2   ","C",nTamNome,0})
	aadd(aDbStru,{"TIT_SE2   ","C",nTamTit,0})  //Numero do titulo com separadores (para visualizacao)
	aadd(aDbStru,{"TIP_SE2   ","C",nTamTip,0})
	aadd(aDbStru,{"DTV_SE2   ","D",08,0})
	aadd(aDbStru,{"VLR_SE2   ","C",18,0})
	aadd(aDbStru,{"VLQ_SE2   ","C",18,0})

	aadd(aDbStru,{"PIS_SE2   ","N",18,2})
	aadd(aDbStru,{"COF_SE2   ","N",18,2})
	aadd(aDbStru,{"CSL_SE2   ","N",18,2})
	aadd(aDbStru,{"IRF_SE2   ","N",18,2})
	aadd(aDbStru,{"INS_SE2   ","N",18,2})
	aadd(aDbStru,{"ISS_SE2   ","N",18,2})

	aadd(aDbStru,{"KEY_SE2   ","C",nTamKey,0}) //Numero do titulo sem separadores (para comparacao)

	//Campos auxiliares
	aadd(aDbStru,{"REC_DDA   ","N",09,0})
	aadd(aDbStru,{"REC_SE2   ","N",09,0})
	aadd(aDbStru,{"OK        ","N",01,0})
	aadd(aDbStru,{"CODBAR    ","C",44,0})

	//------------------
	//Criação da tabela temporaria
	//------------------
	If _oFINA2601 <> Nil
		_oFINA2601:Delete()
		_oFINA2601 := Nil
	Endif

	_oFINA2601 := FWTemporaryTable():New( "TRB" )
	_oFINA2601:SetFields(aDbStru)
	_oFINA2601:AddIndex("1", {"FOR_DDA","LOJ_DDA","DTV_DDA","TIT_DDA"})
	_oFINA2601:AddIndex("2", {"FOR_DDA","LOJ_DDA","TIT_DDA","DTV_DDA"})
	_oFINA2601:AddIndex("3", {"TIT_DDA"})
	_oFINA2601:AddIndex("4", {"FOR_SE2","LOJ_SE2","DTV_SE2","KEY_SE2"})
	_oFINA2601:AddIndex("5", {"FOR_SE2","LOJ_SE2","KEY_SE2","DTV_SE2"})
	_oFINA2601:AddIndex("6", {"KEY_SE2"})
	_oFINA2601:AddIndex("7", {"SEQMOV","FOR_DDA","LOJ_DDA","DTV_DDA","TIT_DDA"})
	_oFINA2601:Create()

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³F260Marca ³ Autor ³ Mauricio Pequim Jr	  ³ Data ³ 02/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Troca o flag para marcado ou nao,aceitando valor.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto da ListBox da conciliacao DDA   				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ F260Marca 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F260Marca(oTitulo)

	Local oDlg1
	Local lRet		:= .T.
	Local lIsDDa	:= .F.
	Local nOpca1 	:= 0
	Local nSequen 	:= 0
	Local nRecTRB	:= 0
	Local nRecSE2	:= 0
	Local nRecDDA	:= 0
	Local nRecOrig := 0
	Local nValorMin:= 0
	Local nValorMax:= 0
	Local nReconc	:= TRB->OK
	Local cFilTrb 	:= ""
	Local cFornece	:= ""
	Local cLoja		:= ""
	Local cNum		:= ""
	Local cTipo		:= ""
	Local dVencto	:= ""
	Local cValor	:= ""
	Local cTitSE2	:= ""
	Local cSeqMov  := ""
	Local cVencMin	:= ""
	Local cVencMax	:= ""
	Local cValorMin:= ""
	Local cValorMax:= ""
	Local dVencMin	:= CTOD("//")
	Local dVencMax	:= CTOD("//")

	If nReconc == 9   // Se n„o reconciliado

		DEFINE MSDIALOG oDlg1 FROM  69,70 TO 160,331 TITLE STR0001 PIXEL  //"Conciliação DDA"

		@ 0, 2 TO 22, 165 OF oDlg1 PIXEL
		@ 7, 98 MSGET nSequen Picture "99999" VALID (nSequen <= TRB->(RecCount())) .and. (nSequen > 0) SIZE 20, 10 OF oDlg1 PIXEL
		@ 8, 08 SAY  STR0027  SIZE 90, 7 OF oDlg1 PIXEL  //"Sequência a Conciliar"
		DEFINE SBUTTON FROM 29, 71 TYPE 1 ENABLE ACTION (nOpca1:=1,If((nSequen <= TRB->(RecCount())) .and. (nSequen > 0),oDLg1:End(),nOpca1:=0)) OF oDlg1
		DEFINE SBUTTON FROM 29, 99 TYPE 2 ENABLE ACTION (oDlg1:End()) OF oDlg1

		ACTIVATE MSDIALOG oDlg1 CENTERED

		IF	nOpca1 == 1

			// Obtenho os dados do registro a conciliar
			cFilTrb 	:= IIF(!Empty(TRB->FIL_DDA),TRB->FIL_DDA,TRB->FIL_SE2)
			cFornece	:= IIF(!Empty(TRB->FOR_DDA),TRB->FOR_DDA,TRB->FOR_SE2)
			cLoja		:= IIF(!Empty(TRB->LOJ_DDA),TRB->LOJ_DDA,TRB->LOJ_SE2)
			cNum		:= IIF(!Empty(TRB->TIT_DDA),TRB->TIT_DDA,TRB->KEY_SE2)
			cTipo		:= IIF(!Empty(TRB->TIP_DDA),TRB->TIP_DDA,TRB->TIP_SE2)
			dVencto	:= IIF(!Empty(TRB->DTV_DDA),TRB->DTV_DDA,TRB->DTV_SE2)
			cValor	:= IIF(!Empty(TRB->VLR_DDA),TRB->VLR_DDA,TRB->VLR_SE2)
			nRecno	:= IIF(!Empty(TRB->REC_DDA),TRB->REC_DDA,TRB->REC_SE2)
			cTitSE2	:= TRB->TIT_SE2
			cSeqMov  := TRB->SEQMOV
			nRecTrb  := TRB->(Recno())
			nRecOrig := Val(TRB->SEQMOV)
			dVencMin	:= dVencto - mv_par14
			dVencMax	:= dVencto + mv_par13
			cVencMin	:= DTOS(dVencMin)
			cVencMax	:= DTOS(dVencMax)
			nValorMin:= DesTrans(cValor) - mv_par15
			nValorMax:= DesTrans(cValor) + mv_par16
			cValorMin:= Transform(nValorMin,"@E 999,999,999,999.99")
			cValorMax:= Transform(nValorMax,"@E 999,999,999,999.99")

			//Verifico se o registro eh DDA ou SE2
			If !Empty(TRB->REC_DDA)
				lIsDDA := .T.
			Endif

			//Posiciono no registro que desejo conciliar
			dbSelectArea("TRB")
			dbGoto(nSequen)

			//Obtenho os recnos originais de cada tabela
			//FIG = nRecDDA
			//SE2 = nRecSE2
			If lIsDDa
				nRecDDA	:= nRecno
				nRecSE2	:= TRB->REC_SE2
			Else
				nRecDDA	:= TRB->REC_DDA
				nRecSE2	:= nRecno
			Endif

			If TRB->OK < 9
				Help(" ",1,"JACONCIL",,STR0028,1,0) //"Tentativa de conciliar com movimento já conciliado"
				dbGoto(nRecOrig)
				oTitulo:Refresh()
				lRet := .F.
			Endif

			//Verifica tentativa de conciliar DDA x DDA ou SE2 x SE2
			If lRet .and. ((lIsDDA .and. !Empty(TRB->TIT_DDA)) .or. (!lIsDDA .and. !Empty(TRB->TIT_SE2)))
				Help(" ",1,"NOCONCMT",,STR0029,1,0) //"Não é possivel conciliar registros DDA x DDA ou SE2 x SE2"
				dbGoto(nRecOrig)
				oTitulo:Refresh()
				lRet := .F.
			Endif

			//Caso consiga reservar os registros nas tabelas originais (SE2 e FIG)
			If lRet .and. F260Lock(.T.,aRLocksSE2,aRLocksFIG,nRecSe2,nRecDDA,.T.)

				If lRet .and. ( IIf (lIsDDA , TRB->(FOR_SE2+LOJ_SE2) != cFornece+cLoja , TRB->(FOR_DDA+LOJ_DDA) != cFornece+cLoja))

					Help(" ",1,"NOCONCFL",,STR0030,1,0) //"Fornecedor e Loja dos movimentos não conferem"
					F260Lock(.F.,aRLocksSE2,aRLocksFIG,nRecSE2,nRecDDA)
					dbGoto(nRecOrig)
					oTitulo:Refresh()
					lRet := .F.
				Endif

				If lRet .And. IIf(lIsDDA, (TRB->(VLQ_SE2) < cValorMin .Or. TRB->(VLQ_SE2) > cValorMax),;
					(TRB->(VLR_DDA) < cValorMin .Or. TRB->(VLR_DDA) > cValorMax))

					Help(" ",1,"NOCONCVL",,STR0031,1,0) //"Os valores dos movimentos não conferem ou não estão dentro da tolerância de valores parametrizada"
					F260Lock(.F.,aRLocksSE2,aRLocksFIG,nRecSE2,nRecDDA)
					dbGoto(nRecOrig)
					oTitulo:Refresh()
					lRet := .F.
				Endif

				If  lRet .and. ( IIf (lIsDDA , ;
					( DTOS(TRB->(DTV_SE2)) < cVencMin  .Or. DTOS(TRB->(DTV_SE2)) > cVencMax ) ,;
					( DTOS(TRB->(DTV_DDA)) < cVencMin  .Or. DTOS(TRB->(DTV_DDA)) > cVencMax ) ) )

					Help(" ",1,"NOCONCDT",,STR0032,1,0) //"As datas dos movimentos não conferem ou não estão dentro da tolerância de datas parametrizada"
					F260Lock(.F.,aRLocksSE2,aRLocksFIG,nRecSE2,nRecDDA)
					dbGoto(nRecOrig)
					oTitulo:Refresh()
					lRet := .F.
				Endif

				If lRet
					//Se partiu de um movimetno DDA
					If lIsDDA

						//Pego os dados do titulo SE2
						cFilTrb 	:= TRB->FIL_SE2
						cFornece	:= TRB->FOR_SE2
						cLoja		:= TRB->LOJ_SE2
						cNum		:= TRB->KEY_SE2
						cTipo		:= TRB->TIP_SE2
						dVencto	:= TRB->DTV_SE2
						cValor	:= TRB->VLR_SE2
						nRecTRB	:= TRB->REC_SE2
						cSeqMov	:= TRB->SEQMOV
						cTitSE2	:= TRB->TIT_SE2

						DbSelectArea("TRB")
						dbDelete()

						dbGoTo(nRecOrig)
						//Gravo os dados SE2 no registro a conciliar (digitado)
						RecLock("TRB")
						TRB->SEQCON 	:= cSeqMov
						TRB->FIL_SE2	:= cFilTrb
						TRB->FOR_SE2	:= cFornece
						TRB->LOJ_SE2	:= cLoja
						TRB->TIT_SE2	:= cTitSE2	//Com separador
						TRB->KEY_SE2	:= cNum		//Sem separador
						TRB->TIP_SE2	:= cTipo
						TRB->DTV_SE2	:= dVencto
						TRB->VLR_SE2	:= cValor
						TRB->REC_SE2	:= nRecSE2
						TRB->OK     	:= 1	// NIVEL DE CONCILIACAO - Conciliado pelo Usuário
						MsUnlock()

				Else

						//Gravo os dados DDA no registro a conciliar (digitado)
						RecLock("TRB")
						TRB->SEQCON 	:= cSeqMov
						TRB->FIL_SE2	:= cFilTrb
						TRB->FOR_SE2	:= cFornece
						TRB->LOJ_SE2	:= cLoja
						TRB->KEY_SE2	:= cNum		//Sem separador
						TRB->TIT_SE2	:= cTitSE2	//Com separador
						TRB->TIP_SE2	:= cTipo
						TRB->DTV_SE2	:= dVencto
						TRB->VLR_SE2	:= cValor
						TRB->VLQ_SE2	:= Transform(0.00,"@E 999,999,999,999.99")
						TRB->REC_SE2	:= nRecSE2
						TRB->OK     	:= 1	// NIVEL DE CONCILIACAO - Conciliado pelo Usuário
						MsUnlock()

						//Deleto o registro
						dbGoTo(nRecOrig)
						dbDelete()
						MsUnlock()

						//Atualizo a tela
						dbGoto(nSequen)
						oTitulo:Refresh()
					Endif
				Endif
			Endif
		Endif
	Else
		DEFINE MSDIALOG oDlg1 FROM  69,70 TO 165,331 TITLE  STR0001 PIXEL //"Conciliação DDA"
		@  0, 2 TO 28, 128 OF oDlg1	PIXEL
		@  7.5,  9 SAY  STR0033  SIZE 115, 7 OF oDlg1 PIXEL  // //"Esta movimentação já se encontra conciliada"
		@ 14  ,  9 SAY  STR0034  SIZE 100, 7 OF oDlg1 PIXEL  // //"Deseja cancelar a conciliação ?"
		DEFINE SBUTTON FROM 32, 71 TYPE 1 ENABLE ACTION (nOpca1:=1,oDlg1:End()) OF oDlg1
		DEFINE SBUTTON FROM 32, 99 TYPE 2 ENABLE ACTION (oDlg1:End()) OF oDlg1

		ACTIVATE MSDIALOG oDlg1 CENTERED

		IF	nOpca1 == 1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cancela reconcilia‡Æo                               			  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nRecOrig := VAL(TRB->SEQMOV)
			nSeqSE2	:= VAL(TRB->SEQCON)
			nRecSE2	:= TRB->REC_SE2
			nRecDDA	:= TRB->REC_DDA

			//Limpo os dados do registro de SE2 conciliado
			dbSelectArea("TRB")
			TRB->FIL_SE2 	:= Space(Len(TRB->FIL_SE2))
			TRB->FOR_SE2 	:= Space(Len(TRB->FOR_SE2))
			TRB->LOJ_SE2 	:= Space(Len(TRB->LOJ_SE2))
			TRB->TIT_SE2 	:= Space(Len(TRB->TIT_SE2))
			TRB->TIP_SE2 	:= Space(Len(TRB->TIP_SE2))
			TRB->DTV_SE2 	:= CTOD("//")
			TRB->VLR_SE2 	:= Space(Len(TRB->VLR_SE2))
			TRB->VLQ_SE2 	:= Space(Len(TRB->VLQ_SE2))
			TRB->KEY_SE2 	:= Space(Len(TRB->KEY_SE2))
			TRB->REC_SE2	:= 0
			TRB->SEQCON		:= Space(5)
			TRB->OK			:= 9

			//Recupera o Registro Deletado
			SET DELETED OFF
			dbGoTo(nSeqSE2)
			dbRecall()
			TRB->OK := 9
			SET DELETED ON
			dbGoto(nRecOrig)

			//Destrava registros nas tabelas originais (SE2 e FIG)
			F260Lock(.F.,aRLocksSE2,aRLocksFIG,nRecSE2,nRecDDA)

		Endif
	Endif
	oTitulo:Refresh()

Return lRet



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³F260Canc  ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 03/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de cancelamento de conciliacao DDA					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ F260Canc(ExpC1,ExpN1,ExpN2)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo											  ³±±
±±³			 ³ ExpN1 = Numero do registro 										  ³±±
±±³			 ³ ExpN2 = Numero da opcao selecionada 							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function F260Canc(cAlias,nReg,nOpc,lAutomato)

	Local nOpcA			:= 0
	Local nSavRec		:= (cAlias)->(RecNo())
	Local oDlg
	Local aDadosSE2	:= {}
	Local lRet			:= .T.
	Local lF260Comp := Existblock("F260COMP")

	Default lAutomato := .F.

	dbSelectArea(cAlias)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpa aGet e aTela              					³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aGets := { }
	aTela := { }

	If !lAutomato
		//Registro não relacionado
		If Empty(FIG->FIG_DDASE2)
			MsgAlert(STR0035) //"Registro não conciliado."
			lRet := .F.
		Endif

		//Registro relacionado porem o registro do SE2 foi excluido
		If lRet
			aDadosSE2 := STRTOKARR(FIG->FIG_DDASE2,"|")
			dbSelectArea("SE2")
			dbSetOrder(1)		//Filial+Prefixo+Numero+Parcela+Tipo+Fornecedor+Loja
			If !MsSeek(aDadosSe2[1]+aDadosSe2[2]+aDadosSe2[3]+aDadosSe2[4]+aDadosSe2[5]+aDadosSe2[6]+aDadosSe2[7])
				MsgAlert(STR0036) //"Registro de Contas a pagar não encontrado. Não será possivel cancelar esta conciliação."
				lRet := .F.
			Endif
		Endif

		//Validar se titulo totalmente baixado
		If lRet .and. SE2->E2_SALDO == 0
			MsgAlert (STR0037+CHR(13)+STR0038) //"O titulo relacionado a esta conciliação se encontra totalmente baixado."###"Não será possivel o cancelamento da conciliação."
			lRet := .F.
		Endif
	Endif

	If lRet
		dbSelectArea(cAlias)
		If !SoftLock(cAlias)
			lRet := .F.
		EndIf
	Endif


	If lRet
		If !lAutomato
			aSize := MsAdvSize()
			DEFINE MSDIALOG oDlg TITLE STR0039 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL //"Cancelamento Conciliacao DDA"
			oDlg:lMaximized := .T.

			dbSelectArea("FIG")
			RegToMemory("FIG",.F.)

			/////////////////
			// painel 1 - MSMGET - Dados do registro DDA

			oPanel1 := TPanel():New(0,0,'Dados DDA',oDlg,, .T., .T.,CLR_WHITE,CLR_BLUE,10,10,.F.,.F.)
			oPanel1:Align := CONTROL_ALIGN_TOP

			oPanel2 := TPanel():New(0,0,'Dados DDA',oDlg,, .T., .T.,, ,110,110,.F.,.F.)
			oPanel2:Align := CONTROL_ALIGN_TOP

			oEnch2:= MsMGet():New( cAlias, nReg, 2,,"AC",,,,,,,,,oPanel2)
			oEnch2:oBox:Align := CONTROL_ALIGN_ALLCLIENT

			/////////////////
			// painel 2 - MsGetDados - Dados dos titulos gerados pelo desdobramento
			// painel 2 - MSMGET - Dados do registro SE2 relacionado
			aGets := { }
			aTela := { }

			dbSelectArea("SE2")
			RegToMemory("SE2",.F.,,,,FunName())
		Endif

		If !SoftLock("SE2")
			Return
		EndIf

		If !lAutomato

			oPanel3 := TPanel():New(0,0,'Dados SE2',oDlg,, .T., .T.,CLR_WHITE,CLR_BLUE,10,10,.F.,.F.)
			oPanel3:Align := CONTROL_ALIGN_TOP

			oPanel4 := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,25,25,.F.,.F.)  //'Dados do Rastreamento'
			oPanel4:Align := CONTROL_ALIGN_ALLCLIENT

			oEnch4 := MsMGet():New( "SE2", SE2->(recno()),2,,"AC",,,,,,,,,oPanel4)
			oEnch4:oBox:Align := CONTROL_ALIGN_ALLCLIENT

			nOpca := 0

			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpca := 0,oDlg:End()}) CENTER
		Else
			nOpcA := 1
		Endif

		If nOpcA == 1

			//VALIDAR SE SE2 não tem IDCNAB (enviado ao banco)
			If !Empty(SE2->E2_IDCNAB) .and. !lAutomato
				If !MsgYesNo(STR0040,STR0041) //"Este título possui IDCNAB preenchido e pode ter sido enviado para pagamento via CNAB. Confirma cancelamento?"###"Atenção"
					lRet := .F.
				Endif
			Endif

			If lRet

				BEGIN TRANSACTION

				//Limpa codigo de barras na tabela SE2
				Reclock("SE2")
				SE2->E2_CODBAR := Space(TamSx3("E2_CODBAR")[1])
				MsUnlock()

				//Limpa dados da conciliacao DDA na tabela FIG
				Reclock("SE2")
				FIG->FIG_CONCIL	:= "2"
				FIG->FIG_DTCONC	:= CTOD("//")
				FIG->FIG_USCONC	:= Space(TamSx3("FIG_USCONC")[1])
				FIG->FIG_DDASE2	:= ""
				MsUnlock()

				END TRANSACTION
			Endif

			If lF260Comp
				Execblock("F260COMP",.F.,.F.)
			EndIf

		Endif
	Endif
	MsUnlock()

	dbSelectArea(cAlias)
	(cAlias)->(dbGoTo(nSavRec))

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³F260Alte  ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 03/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Alteracao da Conciliacao DDA   					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ F260Alte(ExpC1,ExpN1,ExpN2)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo											  ³±±
±±³			 ³ ExpN1 = Numero do registro 										  ³±±
±±³			 ³ ExpN2 = Numero da opcao selecionada 							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function F260Alte(cAlias,nReg,nOpc)

	Local aCpos	:= {}
	Local cTudoOK := ".T."

	If FIG->( EOF()) .or. xFilial("FIG") # FIG->FIG_FILIAL
		Help(" ",1,"ARQVAZIO")
		Return .T.
	Endif

	If !U_F260Verif()
		Help(" ",1,"NOALTER",,STR0043,1,0)		//"Este registro não permite alterações. Apenas titulos com dados a verificar podem sofrer alteração. Vide Legenda."
		Return .T.
	Endif

	Aadd(aCpos,"FIG_FORNEC")
	Aadd(aCpos,"FIG_LOJA")
	Aadd(aCpos,"FIG_NOMFOR")
	Aadd(aCpos,"FIG_CODBAR")
	Aadd(aCpos,"FIG_TITULO")
	Aadd(aCpos,"FIG_VENCTO")

	lAltera:=.T.

	nOpca := AxAltera(cAlias,nReg,nOpc,,aCpos,4,,cTudoOK)

Return

/*/
Tela de Pesquisa
/*/
User Function F260Pesq(oTitulo)

	Local nRecno		:= 0
	Local aPesqui		:={}
	Local cSeek			:= ""
	Local nIndex		:= 1

	dbSelectArea("TRB")
	nRecno	:= Recno()
	nIndex	:= IndexOrd()

	aAdd(aPesqui,{STR0044,1})	//"Fornecedor DDA + Loja DDA + Vencto. DDA + Titulo DDA"
	aAdd(aPesqui,{STR0045,2})	//"Fornecedor DDA + Loja DDA + Titulo DDA + Vencto. DDA"
	aAdd(aPesqui,{STR0046,3})	//"Titulo DDA"
	aAdd(aPesqui,{STR0047,4})	//"Fornecedor SE2 + Loja SE2 + Vencto. SE2 + Titulo SE2"
	aAdd(aPesqui,{STR0048,5})	//"Fornecedor SE2 + Loja SE2 + Titulo SE2 + Vencto. SE2"
	aAdd(aPesqui,{STR0049,6})	//"Titulo SE2"

	WndxPesqui(,aPesqui,cSeek,.F.)

	dbSelectArea("TRB")
	dbSetOrder(nIndex)

	//Caso não tenha achado, volto para o registro de partida
	IF TRB->(EOF())
		TRB->(dbgoto(nRecno))
	Endif

	oTitulo:Refresh()

Return Nil


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FA260Leg()³ Autor ³ Mauricio Pequim Jr.   ³ Data ³04.10.09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela de Legenda - Browse   										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Recno do registro posicionado no browse				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function FA260Leg(nReg)

	Local uRetorno := {}
	Local aLegenda := {}

	Aadd(aLegenda, {"ENABLE" , STR0050})		//"DDA Conciliado"
	Aadd(aLegenda, {"DISABLE", STR0051})		//"DDA Não Conciliado"
	Aadd(aLegenda, {"BR_AMARELO",STR0052})		//"DDA Verificar dados"


	If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
		uRetorno := {}

		Aadd(uRetorno, { 'U_F260VERIF()'			, aLegenda[3][1] } )
		Aadd(uRetorno, { 'FIG->FIG_CONCIL == "1"'	, aLegenda[1][1] } )
		Aadd(uRetorno, { 'FIG->FIG_CONCIL == "2"'	, aLegenda[2][1] } )

	Else

		BrwLegenda(cCadastro, "Legenda", aLegenda)
	Endif

Return uRetorno


/*/
Legenda
/*/
User Function F260LegTrb()

	Local aLegenda := {}
	Local nY     	:= 0
	Local nX     	:= 0
	Local aBmp[9]
	Local oDlgLeg

	Aadd(aLegenda, {"ENABLE"		, STR0053})	//"Conciliado: Fornecedor + Loja OK, Filial OK, Valor OK, Vencimento OK"
	Aadd(aLegenda, {"BR_AZUL"		, STR0054})	//"Conciliado: Fornecedor + Loja OK, Filial OK, Valor IN, Vencimento OK"
	Aadd(aLegenda, {"BR_PRETO"		, STR0055})	//"Conciliado: Fornecedor + Loja OK, Filial OK, Valor OK, Vencimento IN"
	Aadd(aLegenda, {"BR_CINZA"		, STR0056})	//"Conciliado: Fornecedor + Loja OK, Filial OK, Valor IN, Vencimento IN"
	Aadd(aLegenda, {"BR_BRANCO"	, STR0057})	//"Conciliado: Fornecedor + Loja OK, Filial IN, Valor OK, Vencimento OK"
	Aadd(aLegenda, {"BR_AMARELO"	, STR0058})	//"Conciliado: Fornecedor + Loja OK, Filial IN, Valor IN, Vencimento OK"
	Aadd(aLegenda, {"BR_LARANJA"	, STR0059})	//"Conciliado: Fornecedor + Loja OK, Filial IN, Valor OK, Vencimento IN"
	Aadd(aLegenda, {"BR_PINK"		, STR0060})	//"Conciliado: Fornecedor + Loja OK, Filial IN, Valor IN, Vencimento IN"
	Aadd(aLegenda, {"DISABLE"		, STR0061})	//"Não Conciliado"

	DEFINE MSDIALOG oDlgLeg FROM 0,0 TO (Len(aLegenda)*20)+110, 500 TITLE cCadastro OF oMainWnd PIXEL

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³No onclick do usuario a tela sera fechada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oDlgLeg:bLClicked:= {||oDlgLeg:End()}

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Fonte especifico para a descricao das legendas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
		DEFINE FONT oBold2 NAME "Arial" SIZE 0, -11 BOLD

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Desenho de fundo³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 0, 0 BITMAP RESNAME "PROJETOAP" OF oDlgLeg SIZE 35,155 NOBORDER WHEN .F. PIXEL

		@ 11,35 TO 013,400 LABEL '' OF oDlgLeg PIXEL
		@ 03,37 SAY STR0011 OF oDlgLeg PIXEL SIZE 150,009 FONT oBold		//"Legenda"
		For nX := 1 to Len(aLegenda)
			@ 20+((nX-1)*10),43 BITMAP aBmp[nX] RESNAME aLegenda[nX][1] OF oDlgLeg SIZE 20,10 PIXEL NOBORDER
			@ 20+((nX-1)*10),53 SAY If((nY+=1)==nY,aLegenda[nY][2]+If(nY==Len(aLegenda),If((nY:=0)==nY,"",""),""),"") OF oDlgLeg PIXEL
		Next nX
		nY := 0
		@ 120,37 SAY STR0062 OF oDlgLeg PIXEL SIZE 150,009 FONT oBold2 		//"OK - Valor Exato"
		@ 130,37 SAY STR0063 OF oDlgLeg PIXEL SIZE 150,009 FONT oBold2 		//"IN - Valor dentro do intervalo definido"

	ACTIVATE MSDIALOG oDlgLeg CENTERED

Return(NIL)

/*/
±±³Descri‡„o ³ Verificacao de status do registro DDA com necessidade de   ³±±
±±³          ³ de verificacao de dados                                    ³±±
/*/
User Function F260Verif( cAliasFIG )

	Local lRet := .F.

	DEFAULT cAliasFIG := "FIG"


	If Empty((cAliasFIG)->FIG_FORNEC) .OR. Empty((cAliasFIG)->FIG_CODBAR) .OR. ;
		Empty((cAliasFIG)->FIG_TITULO) .OR. Empty((cAliasFIG)->FIG_VENCTO) .OR. ;
		Empty((cAliasFIG)->FIG_VALOR)  .OR. Empty((cAliasFIG)->FIG_CNPJ)
		lRet := .T.
	Endif

Return lRet


/*/
±±³Descri‡„o ³ Montagem da String de filiais a serem utilizadas no 		  ³±±
±±³          ³ processo de filtragem dados - TOP                          ³±±
/*/
Static Function F260Filial()

	Local cFilIn	:= ""
	Local nInc		:= 0
	Local aSM0		:= AdmAbreSM0()

	//Considero filiais do intervalo e arquivos exclusivos
	If mv_par01 == 1 .and. !Empty(xFilial("SE2"))
		//Arquivos Exclusivos
		For nInc := 1 To Len( aSM0 )
			If aSM0[nInc][2] >= mv_par02 .and. aSM0[nInc][2] <= mv_par03
				cFilIn += aSM0[nInc][2] + "/"
			EndIf
		Next
	Else
		cFilIn := xFilial("SE2")
	Endif

Return cFilIn


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³F260Lock  ³ Autor ³ Mauricio Pequim Jr.   ³ Data ³04.10.09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para controle de travamento e destravamento dos     ³±±
±±³          ³ registros utilizados por um determinado usuario            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Rotina para travamento dos registros do SE2 e FIG  ³±±
±±³          ³ ExpA2 = Array p/ guardar registros SE2 em uso pelo usuario ³±±
±±³          ³ ExpA3 = Array p/ guardar registros FIG em uso pelo usuario ³±±
±±³          ³ ExpN4 = Numero do registro do SE2 que se quer travar       ³±±
±±³          ³ ExpN5 = Numero do registro do FIG que se quer travar       ³±±
±±³          ³ ExpL6 = Mostra Help em caso de nao travamento do registro  ³±±
±±³          ³ ExpL7 = Destravamento de todos os registros                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function F260Lock(lLock,aRLocksSE2,aRLocksFIG,nRecnoSE2,nRecnoFIG,lHelp,lTodos)

	Local aArea	:= GetArea()
	Local nPosRec
	Local lSE2	:= .F.
	Local	lFIG	:= .F.
	Local lRet	:= .F.

	DEFAULT lLock := .F.		//Travamento ou destravamento dos registros
	DEFAULT lHelp := .F.		//Mostra help ou nao
	DEFAULT lTodos:= .F.		//Libera todos os registros
	DEFAULT aRLocksSE2:={}	//Array de registros do SE2 lockados com o usuario
	DEFAULT aRLocksFIG:={}	//Array de registros do FIG lockados com o usuario

	If lTodos
		//Destrava todos os registros - Final do processamento
		AEval(aRLocksSE2,{|x,y| SE2->(MsRUnlock(x))})
		aRLocksSE2:={}

		AEval(aRLocksFIG,{|x,y| FIG->(MsRUnlock(x))})
		aRLocksFIG:={}

	Else
		//Controle de marcacao ou desmarcaao dos titulos
		If nRecnoSE2 <> Nil
			SE2->(MsGoto(nRecnoSE2))
			lSE2	:= .T.
		Endif

		If nRecnoFIG <> Nil
			FIG->(MsGoto(nRecnoFIG))
			lFIG	:= .T.
		Endif

		If lLock //Rotina chamada para travamento dos registros do SE2 e FIG

			//A conciliacao somente sera permitida quando os registros do SE2 e FIG puderem ser travados
			//Caso um deles esteja em uso por outro terminal, nao sera permitida a conciliacao
			If lSE2 .and. lFIG
				If SE2->(MsRLock()) .and. FIG->(MsRLock())
					AAdd(aRLocksSE2, SE2->(Recno()))
					AAdd(aRLocksFIG, FIG->(Recno()))
					lRet	:=	.T.
				ElseIf lHelp
					MsgAlert(STR0064)		//"Um dos registros reçacionados está sendo utilizado em outro terminal e não pode ser utilizado na Conciliação DDA"
				Endif
			Endif
		Else
			If lSE2 .and. lFIG
				//Destravo registro no SE2
				SE2->(MsRUnlock(SE2->(Recno())))
				If (nPosRec:=Ascan(aRlocksSE2,SE2->(Recno()))) > 0
					Adel(aRlocksSE2,nPosRec)
					aSize(aRlocksSE2,Len(aRlocksSE2)-1)
				Endif
				//Destravo registro no FIG
				FIG->(MsRUnlock(FIG->(Recno())))
				If (nPosRec:=Ascan(aRlocksFIG,FIG->(REcno()))) > 0
					Adel(aRlocksFIG,nPosRec)
					aSize(aRlocksFIG,Len(aRlocksFIG)-1)
				Endif
			Endif
		Endif
	Endif

	If aArea <> Nil
		RestArea(aArea)
	Endif

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Mauricio Pequim Jr    ³ Data ³29/09/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina := {	{ STR0065	,"AxPesqui"	, 0 , 1 , ,.F. }	,;			//"Pesquisar"
							{ STR0066	,"AxVisual"	, 0 , 2 }       	,;			//"Visualizar"
							{ STR0067	,"U_F260Conc"	, 0 , 3 }			,;			//"Conciliar"
							{ STR0068	,"U_F260Alte"	, 0 , 4 }			,;			//"Alterar"
							{ STR0069	,"U_F260Canc"	, 0 , 5 }			,;			//"Cancelar"
							{ STR0011	,"U_Fa260Leg"	, 0 , 6 , ,.F. } } 			//"Legenda"

	IF ExistBlock("F260BUT")
  		aRotina := ExecBlock("F260BUT",.F.,.F.,aRotina)
	Endif
Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AdmAbreSM0³ Autor ³ Orizio                ³ Data ³ 22/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna um array com as informacoes das filias das empresas ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AdmAbreSM0()
	Local aArea			:= SM0->( GetArea() )
	Local aAux			:= {}
	Local aRetSM0		:= {}
	Local lFWLoadSM0	:= .T.
	Local lFWCodFilSM0 	:= .T.

	If lFWLoadSM0
		aRetSM0	:= FWLoadSM0()
	Else
		DbSelectArea( "SM0" )
		SM0->( DbGoTop() )
		While SM0->( !Eof() )
			aAux := { 	SM0->M0_CODIGO,;
						IIf( lFWCodFilSM0, FWGETCODFILIAL, SM0->M0_CODFIL ),;
						"",;
						"",;
						"",;
						SM0->M0_NOME,;
						SM0->M0_FILIAL }

			aAdd( aRetSM0, aClone( aAux ) )
			SM0->( DbSkip() )
		End
	EndIf

	RestArea( aArea )
Return aRetSM0
