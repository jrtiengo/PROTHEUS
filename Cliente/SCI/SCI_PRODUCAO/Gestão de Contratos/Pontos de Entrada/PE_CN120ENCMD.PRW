#INCLUDE "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CN120ENCMD³ Autor ³ SCI                   ³ Data ³ Jan/2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ LOCAL: CN120MedEnc: Executado após encerramento da medição.³±±
±±³          ³ EM QUE PONTO: Após o processamento do encerramento.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_CN120ENCMD()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Internacional                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CN120ENCMD()

Local aArea := GetArea()

dbSelectArea("CNB")
dbSetOrder(1)
dbSeek(CND->(CND_FILIAL+CND_CONTRA+CND_REVISA+CND_NUMERO),.T. )

cNATUREZA:=CNB->CNB_NATURE

/*
dbSelectArea("SX6")
dbSetOrder(1)
dbSeek(xFilial("SX6")+"MV_CNNATMD")
RecLock("SX6",.F.)
sx6->x6_conteud:=cNATUREZA
SX6->(MsUnlock())
*/
PutMv("MV_CNNATMD",cNATUREZA)


If !Empty( CND->CND_FORNEC ) //CONTAS A PAGAR
	
	//Itens da Medicao
	dbSelectArea("CNE")
	dbSetOrder(4)
	dbSeek( xFilial("CNE") + CND->CND_NUMMED )
	
	//Itens da Planilha
	dbSelectArea("CNB")
	dbSetOrder(1)
	dbSeek( xFilial("CNB") + CND->CND_CONTRA + CND->CND_REVISA + CND->CND_NUMERO )
	
	//Cabecalho Planilha
	dbSelectArea("CNA")
	dbSetOrder(1)
	dbSeek( xFilial("CNA") + CND->CND_CONTRA + CND->CND_REVISA + CND->CND_NUMERO )
	
	dbSelectArea("CTH")
	dbSetOrder(1)
	dbSeek( xFilial("CTH") + CNE->CNE_CLVL )
	
	//Natureza
	dbSelectArea("SED")
	dbSetOrder(1)
	dbSeek( xFilial("SED") + CNB->CNB_NATURE )
	
	
	cQuery:=" UPDATE " + RetSQLName("SE2") + " "
	cQuery+=" SET E2_NATUREZ = '" + CNB->CNB_NATURE + "',"
	
	If CNA->CNA_TIPPLA = '002'
		cQuery+="   E2_TIPO    = 'GA', "
	EndIf
	
	cQuery+="     E2_CCCTB   = '" + CNE->CNE_CC + "',"
	cQuery+="     E2_ITCTB   = '" + CNE->CNE_ITEMCT + "',"
	cQuery+="     E2_CLVLCTB = '" + CNE->CNE_CLVL + "',"
	cQuery+="     E2_CTACTB  = '" + SED->ED_CTACTBF + "',"
	cQuery+="     E2_CONTAD  = '" + SED->ED_CONTA + "',"
	
	If !Empty( CNE->CNE_CLVL )
		cQuery+=" E2_DESCLVL = '" + CTH->CTH_DESC01 +"',"
	EndIf
	
	cQuery+="     E2_USRCTO  = '" + CN9->CN9_CODUSR + "',"
	cQuery+="     E2_VENCTO  = '" + DToS(CND->CND_DTVENC) + "',"	// direito de imagem
	cQuery+="     E2_VENCORI = '" + DToS(CND->CND_DTVENC) + "',"	// direito de imagem
	cQuery+="     E2_VENCREA = '" + DToS(CND->CND_DTVENC) + "'," 	// direito de imagem
	cQuery+="     E2_HIST    = '" +'Ctr. ' + CNB->CNB_CONTRA + ' Parc. ' + CND->CND_PARCEL + ' Compet. ' + CND->CND_COMPET + "'"
	
	cQuery+=" WHERE E2_FILIAL= '" + xFilial("SE2") + "'"
	
	cQuery+=" AND E2_PREFIXO = 'CTV'"
	
	cQuery+=" AND E2_NUM	 = '" + CND->CND_NUMTIT + "'"
	cQuery+= "AND E2_MDCONTR = '" + CND->CND_CONTRA + "'"
	cQuery+= "AND E2_MDREVIS = '" + CND->CND_REVISA + "'"
	cQuery+= "AND E2_MDPLANI = '" + CND->CND_NUMERO + "'"
	
	cQuery+=" AND E2_TIPO	 = 'DP'"
	cQuery+=" AND E2_FORNECE = '" + CND->CND_FORNEC + "'"
	cQuery+=" AND E2_LOJA	 = '" + CND->CND_LJFORN + "'"
	cQuery+=" AND D_E_L_E_T_ = ''"
	
	nRet := TcSqlExec(cQuery)
	
	If nRet <> 0
		//Alert(TCSQLERROR())
	EndIf
	
	dNewData := DataValida( CND->CND_DTVENC, .T. )
	cNovaData:= SubStr( DtoS( MonthSum( dNewData , 1 ) ), 1, 6 ) + '20'
	
	cQuery:=" UPDATE " + RetSQLName("SE2") + " SET "
	
	cQuery+="     E2_VENCTO  = '" + cNovaData + "',"	// direito de imagem
	cQuery+="     E2_VENCREA = '" + cNovaData + "' "
	
	cQuery+=" WHERE E2_FILIAL= '" + xFilial("SE2") + "'"
	cQuery+=" AND E2_PREFIXO = 'CTC'"
	cQuery+=" AND E2_NUM     = '" + CND->CND_NUMTIT + "'"
	cQuery+=" AND E2_TIPO    = 'TX'"
	cQuery+=" AND E2_NATUREZ IN ('73171','73141','73131', '73121') "
	cQuery+=" AND D_E_L_E_T_ = ''"
	
	nRet := TcSqlExec(cQuery)
	
	If nRet <> 0
		//Alert(TCSQLERROR())
	Endif
	
	//U_F_ATUGCT()
	
Else //CONTAS A RECEBER
	
	//Itens da Medicao
	dbSelectArea("CNE")
	dbSetOrder(4)
	dbSeek( xFilial("CNE") + CND->CND_NUMMED )
	
	//Itens da Planilha
	dbSelectArea("CNB")
	dbSetOrder(1)
	dbSeek( xFilial("CNB") + CND->CND_CONTRA + CND->CND_REVISA + CND->CND_NUMERO )
	
	//Natureza
	dbSelectArea("SED")
	dbSetOrder(1)
	dbSeek( xFilial("SED") + CNB->CNB_NATURE )
	
	cQuery:=" UPDATE " + RetSQLName("SE1") + " "
	
	cQuery+=" SET E1_NATUREZ = '"+CNB->CNB_NATURE+"',"
	cQuery+="     E1_CREDIT  = '"+SED->ED_CONTA+"',"
	cQuery+="     E1_CCCTB   = '"+CNE->CNE_CC+"',"
	cQuery+="     E1_CTACTB  = '"+SED->ED_CTACTBC+"',"
	cQuery+="     E1_ITCTB   = '"+CNE->CNE_ITEMCT+"',"
	cQuery+="     E1_CLVLCTB = '"+CNE->CNE_CLVL+"',"
	cQuery+="     E1_USRCTO  = '"+CN9->CN9_CODUSR+"',"
	cQuery+="     E1_VENCTO  = '"+DToS(CND->CND_DTVENC)+"',"
	cQuery+="     E1_VENCREA = '"+DToS(CND->CND_DTVENC)+"',"
	cQuery+="     E1_HIST    = '"+'Ctr. '+CNB->CNB_CONTRA+' Parc. '+CND->CND_PARCEL+' Compet. '+CND->CND_COMPET+"'"
	
	cQuery+=" WHERE E1_FILIAL='"+XfILIAL("SE1")+"'"
	
	cQuery+=" AND E1_PREFIXO = 'CTV'"
	cQuery+=" AND E1_MEDNUME = '"+CND->CND_NUMMED+"'"
	cQuery+=" AND E1_TIPO    = 'DP'"
	cQuery+=" AND E1_CLIENTE = '"+CND->CND_CLIENT+"'"
	cQuery+=" AND E1_LOJA    = '"+CND->CND_LOJACL+"'"
	
	cQuery+=" AND E1_MDPLANI = '"+CNB->CNB_NUMERO+"'"
	cQuery+=" AND E1_MDCONTR = '"+CNB->CNB_CONTRA+"'"
	cQuery+=" AND E1_MDREVIS = '"+CNB->CNB_REVISA+"'"
	
	cQuery+=" AND D_E_L_E_T_ =''"
	
	nRet := TcSqlExec(cQuery)
	
	If nRet <> 0
		//Alert( TCSQLERROR() )
	Endif
	
	
	cQuery:="	UPDATE SE1 " //+ RetSqlName("SE1") + " "
	
	cQuery+="	SET E1_CTACTB = SE1PAI.E1_CTACTB "
	
	cQuery+="	FROM " + RETSQLNAME("SE1") + " SE1 "
	
	cQuery+="         INNER JOIN " + RetSQLName("SE1") + " SE1PAI "
	cQuery+="         ON  ( SE1PAI.E1_PREFIXO 	= SUBSTRING(SE1.E1_TITPAI, 1, 3 ) "
	cQuery+="         		AND SE1PAI.E1_NUM	= SUBSTRING(SE1.E1_TITPAI, 4, 9 ) "
	cQuery+="          		AND SE1PAI.E1_TIPO	= SUBSTRING(SE1.E1_TITPAI, 15,3 ) "
	cQuery+="          		AND SE1PAI.E1_TITPAI = '' ) "
	
	cQuery+="    WHERE RTRIM( SE1.E1_TIPO ) = 'IN-' "
	cQuery+="         AND SE1.D_E_L_E_T_ <> '*' "
	cQuery+="         AND SE1PAI.D_E_L_E_T_ <> '*' "
	cQuery+="         AND ( SE1.E1_CTACTB = '' or SE1.E1_CTACTB <> SE1PAI.E1_CTACTB ) "
	cQuery+="         AND  SE1.E1_EMISSAO = SE1PAI.E1_EMISSAO "
	cQuery+="         AND  SE1.E1_PARCELA = SE1PAI.E1_PARCELA "
	cQuery+="		  AND  SE1.E1_EMISSAO > '20181001' "
	
	nRet := TcSqlExec(cQuery)
	
	If nRet <> 0
		//Alert( TCSQLERROR() )
	Endif
	
EndIf

RestArea( aArea )

Return(.T.)
