#Include "Protheus.Ch"
#Include "TOTVS.CH"

User Function ___SCIA400() //tarasconi em 31/01/2020 - retirada a função pois era usada para impostos importados....

Local cPerg:= "SCIA400"

Private sData1:=""
Private sData2:=""

If cPerg == "SCIA400"
	If !SX1->( dbSeek( cPerg ) )
		
		aHelpPor := {"Data Inicial"}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSX1(cPerg,"01","Data Inicial de:","Data Inicial:?","Date From?","mv_ch1","D",08,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		
		//---------------------------------------MV_PAR01--------------------------------------------------
		aHelpPor := {"Data Final"}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSX1(cPerg,"02","Data Final:","Data Final:?","Date Until?","mv_ch2","D",08,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		
		//---------------------------------------MV_PAR02--------------------------------------------------
	Endif
Endif

If Pergunte(cPerg,.T.)
	
	sData1:=DtoS(MV_PAR01)
	sData2:=DtoS(MV_PAR02)
	
	
		If ddatabase<=getMV("MV_DATAFIN")
	
			Alert('Periodo de para movimentacao financeira esta fechado!')
		    return
	
		endif
	
	
	If month(MonthSub( MV_PAR01 , 1 )) = Month(dDataBase)
		
		Processa({|| geraAGL() },"Gerando titulos AGL","Processando")
		
	Else
		
		Alert('Periodo de apuracao deve ser anterior ao vencimento dos titulos')
		
	endif
	
Endif

Return


Static Function geraAGL()


Local aArray :={}
Local aInfAGL:={}
//Local lMsErroAuto:= .F.
Local nTotal:=0
Local aBaixa := {}
Local dData1
Local dData2
//PRIVATE lMsErroAuto := .F.
Private lMsHelpAuto := .T.                                         
Private lMsErroAuto := .F.    

// Alert('Oi Guria')
// Calculo do proximo numero do lancamento
//----------------------------------------------------------------
c5Query := " SELECT ISNULL(MAX(E2_AGLIMP)+1,'1') PROXDOC "
c5Query += " FROM "+RETSQLNAME("SE2")+" "
c5Query += " WHERE E2_TIPO = 'TX'"
c5Query += " AND   E2_FILIAL = '" + xFilial("SE2") + "'"
c5Query += " AND D_E_L_E_T_ <> '*' "
c5Query := ChangeQuery(c5Query)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,c5Query),"TMPSE2",.F.,.T.)
DbSelectArea("TMPSE2")
cE2NUM:=""
cE2NUM:=Strzero(TMPSE2->PROXDOC,9)
TMPSE2->(dbCloseArea())
//----------------------------------------------------------------



//-- Titulos de PCC
cQuery:= " SELECT E2_CODRET FROM "+RETSQLNAME("SE2")+" "
cQuery+= " WHERE  E2_TIPO='TX' "
//cQuery:= " and E2_NATUREZ IN ('73141','73121','73131','73171') "
//cQuery:= " and E2_CODRET  IN ('5960','5979','5987') "
cQuery+= " and E2_CODRET<>'5952' "
cQuery+= " and E2_FILIAL   = '" + xFilial("SE2") + "'"
cQuery+= " and E2_VENCREA >= '" + sData1 + "'"
cQuery+= " and E2_VENCREA <= '" + sData2 + "'"
cQuery+= " and E2_PREFIXO <> 'AGL' "
cQuery+= " and E2_CODRET  <> ''    "
cQuery+= " and E2_SALDO   > 0      "
//EDY cQuery+= " and RTRIM(E2_AGLIMP)= ''"
cQuery+= " and D_E_L_E_T_ <> '*'   "
cQuery+= " GROUP BY E2_CODRET "
cQuery:= ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMPPCC",.F.,.T.)
DbSelectArea("TMPPCC")


WHILE TMPPCC->(!EOF())
	incproc("Gerando AGL: "+TMPPCC->E2_CODRET)
	aArray:={}
	aInfAGL:={}
	nTotal:=0
	aBaixa := {}
	cNat:=""
	//-- Titulos de PCC
	cQuery:= " SELECT * FROM "+RETSQLNAME("SE2")+" "
	cQuery+= " WHERE  E2_TIPO='TX' "
	cQuery+= " and E2_FILIAL   = '" + xFilial("SE2") + "'"
	cQuery+= " and E2_CODRET   = '" + TMPPCC->E2_CODRET+ "'"
	cQuery+= " and E2_VENCREA >= '" + sData1 + "'"
	cQuery+= " and E2_VENCREA <= '" + sData2 + "'"
	cQuery+= " and E2_PREFIXO <> 'AGL' "
	cQuery+= " and E2_CODRET  <> ''    "
	cQuery+= " and E2_SALDO   > 0      "
	cQuery+= " and D_E_L_E_T_ <> '*'   "
	cQuery:= ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMPSUM",.F.,.T.)
	DbSelectArea("TMPSUM")
	TMPSUM->(DBGOTOP())
	WHILE TMPSUM->(!EOF())
		
		nTotal+= TMPSUM->E2_SALDO-TMPSUM->E2_DECRESC+ TMPSUM->E2_ACRESC
		
		If Empty(aInfAGL)
			If AllTrim(TMPSUM->E2_FORNECE)<>"".and. AllTrim(TMPSUM->E2_LOJA)<>"" .and. AllTrim(TMPSUM->E2_CODRET)<>""
				AADD(aInfAGL,TMPSUM->E2_FORNECE)
				AADD(aInfAGL,TMPSUM->E2_LOJA)
				AADD(aInfAGL,dtos(datavalida(stod(TMPSUM->E2_VENCTO),.F.)))
				AADD(aInfAGL,dtos(datavalida(stod(TMPSUM->E2_VENCREA),.F.)))
				AADD(aInfAGL,TMPSUM->E2_CODRET)
			Endif
		Endif
		
		
		aBaixa := {}
		
		AADD(aBaixa, {"E2_FILIAL"    , TMPSUM->E2_FILIAL , Nil})
		AADD(aBaixa, {"E2_PREFIXO"   , TMPSUM->E2_PREFIXO , Nil})
		AADD(aBaixa, {"E2_NUM"       , TMPSUM->E2_NUM , Nil})
		AADD(aBaixa, {"E2_PARCELA"   , TMPSUM->E2_PARCELA , Nil})
		AADD(aBaixa, {"E2_TIPO"      , TMPSUM->E2_TIPO , Nil})
		AADD(aBaixa, {"E2_FORNECE"   , TMPSUM->E2_FORNECE , Nil})
		AADD(aBaixa, {"E2_LOJA"      , TMPSUM->E2_LOJA , Nil})
		AADD(aBaixa, {"AUTMOTBX"     , "AGL" , Nil})
		AADD(aBaixa, {"AUTBANCO"     , "" , Nil})
		AADD(aBaixa, {"AUTAGENCIA"   , "" , Nil})
		AADD(aBaixa, {"AUTCONTA"     , "" , Nil})
		AADD(aBaixa, {"AUTDTBAIXA"   , dDataBase , Nil})
		AADD(aBaixa, {"AUTDTCREDITO" , dDataBase , Nil})
		AADD(aBaixa, {"AUTHIST"      , 'AGL/PARCELA '+cE2NUM , Nil})
		AADD(aBaixa, {"AUTVLRPG"     , TMPSUM->E2_SALDO-TMPSUM->E2_DECRESC+TMPSUM->E2_ACRESC , Nil})
		
		MSEXECAUTO({|x,y| FINA080(x,y)}, aBaixa, 3)
		
		///ACESSAPERG("FIN080", .F.)
		TMPSUM->(dbSkip())
	ENDDO
	
	
	
	
	// Calculo do proximo numero do lancamento
	//----------------------------------------------------------------
	c5Query := " SELECT ISNULL(MAX(E2_PARCELA)+1,'1') PROXDOC "
	c5Query += " FROM "+RETSQLNAME("SE2")+" "
	c5Query += " WHERE E2_PREFIXO = 'AGL'"
	c5Query += " AND   E2_NUM     = '" + cE2NUM + "'"
	c5Query += " AND   E2_FILIAL  = '" + xFilial("SE2") + "'"
	c5Query += " AND D_E_L_E_T_ <> '*' "
	c5Query := ChangeQuery(c5Query)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,c5Query),"TSE2PAR",.F.,.T.)
	DbSelectArea("TSE2PAR")
	cE2PAR:=""
	cE2PAR:=Strzero(TSE2PAR->PROXDOC,2)
	TSE2PAR->(dbCloseArea())
	//----------------------------------------------------------------
	
	
	
	IF TMPPCC->E2_CODRET $ '1708,0588'
		cNat:= '73111'
	Endif
	
	IF TMPPCC->E2_CODRET= '5979'
		cNat:= '73171'
	Endif
	
	IF TMPPCC->E2_CODRET= '5987'
		cNat:= '73141'
	Endif
	
	IF TMPPCC->E2_CODRET='5960'
		cNat:= '73131'
	Endif
	
	IF !(TMPPCC->E2_CODRET $ '1708,5960,0588,5987,5979')
		cNat:='73111'
	Endif
	
	aArray:={{ "E2_FILIAL"  ,  xFILIAL("SE2") , NIL },;
	{ "E2_PREFIXO"  , "AGL" , NIL },;
	{ "E2_NUM"      , cE2NUM            , NIL},;
	{ "E2_TIPO"     , "TX"              , NIL},;
	{ "E2_PARCELA"  , cE2PAR            , NIL},;
	{ "E2_NATUREZ"  , cNat, NIL},;
	{ "E2_FORNECE"  , AllTrim(aInfAGL[1]), NIL},;
	{ "E2_LOJA"     , AllTrim(aInfAGL[2])   , NIL},;
	{ "E2_EMISSAO"  , dDataBase           , NIL},;
	{ "E2_VENCTO"   , stod(aInfAGL[3])    , NIL},;
	{ "E2_VENCREA"  , stod(aInfAGL[4]) , NIL},;
	{ "E2_CODRET"   , AllTrim(aInfAGL[5]) , NIL},;
	{ "E2_VALOR"    ,nTotal             , Nil},;
	{ "E2_EMIS1"    ,ddatabase          , Nil},;
	{ "E2_LA"       ,"S"                , Nil},;
	{ "E2_SALDO"    ,nTotal             , Nil},;
	{ "E2_VLCRUZ"   ,nTotal             , Nil},;
	{ "E2_NUMTIT"   ,"FINA381"          , Nil},;
	{ "E2_HIST"     ,'AGL REF COD RET '+AllTrim(aInfAGL[5]), Nil},;
	{ "E2_DIRF"     ,'2'             , Nil},;
	{ "E2_MULTNAT"  ,'2'             , Nil}}
	
	
	MemoWrite("TesteAgl"+AllTrim(aInfAGL[5])+"_"+cE2PAR+".TXT",varinfo("teste agl ",aArray))
	
	MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
	
	
	TMPSUM->(dbCloseArea())
	If lMsErroAuto
		MostraErro()
	Endif
	
	cQuery:=""
	
	cQuery:= " UPDATE " +RETSQLNAME("SE2")
	cQuery+= "  SET E2_AGLIMP    ='" + cE2NUM  + "',"
	cQuery+= " E2_PARAGL    ='" + cE2PAR  + "',"
	cQuery+= " E2_NUMTIT='FINA381'   "
	cQuery+= " FROM " +RETSQLNAME("SE2")+" SE2 "
	cQuery+= " INNER JOIN " +RETSQLNAME("SE5")+" SE5  ON (SE5.E5_PREFIXO=SE2.E2_PREFIXO AND SE2.E2_TIPO=SE5.E5_TIPO "
	cQuery+= " AND SE2.E2_NUM=SE5.E5_NUMERO AND SE2.E2_PARCELA=SE5.E5_PARCELA "
	cQuery+= " AND SE2.E2_FORNECE=SE5.E5_CLIFOR AND SE2.E2_LOJA=SE5.E5_LOJA AND E5_DATA=E2_BAIXA) "
	cQuery+= " WHERE  E5_TIPO='TX' "
	cQuery+= " and E5_FILIAL   =  '" + xFilial("SE5")+ "'"
	cQuery+= " and SE5.E5_DATA >= '" + dToS(dDatabase) + "'"
	cQuery+= " and SE5.E5_DATA <= '" + dToS(dDatabase) + "'"
	cQuery+= " and SE5.E5_PREFIXO <> 'AGL'"
	cQuery+= " and SE5.E5_MOTBX    = 'AGL'"
	cQuery+= " and SE5.E5_SITUACA  <> 'C'"
	cQuery+= " and SE2.E2_CODRET   = '" + TMPPCC->E2_CODRET  + "'"
	cQuery+= " and SE2.E2_VENCREA >= '" + sData1 + "'"
	cQuery+= " and SE2.E2_VENCREA <= '" + sData2 + "'"
	cQuery+= " and SE2.E2_PREFIXO <> 'AGL' "
	cQuery+= " and SE5.D_E_L_E_T_ <> '*' "
	cQuery+= " and SE2.D_E_L_E_T_ <> '*' "
	
	nRet:=TcSqlExec(cQuery)
	If nRet<>0
		Alert(TCSQLERROR())
	Endif
	
	
	
	
	cQuery:=""
	
	cQuery:= " UPDATE " +RETSQLNAME("SE2")
	cQuery+= "  SET E2_AGLIMP    ='',"
	cQuery+= " E2_PARAGL    ='',"
	cQuery+= " E2_NUMTIT=''   "
	cQuery+= " FROM " +RETSQLNAME("SE2")+" SE2 "
	cQuery+= " INNER JOIN " +RETSQLNAME("SE5")+" SE5  ON (SE5.E5_PREFIXO=SE2.E2_PREFIXO AND SE2.E2_TIPO=SE5.E5_TIPO "
	cQuery+= " AND SE2.E2_NUM=SE5.E5_NUMERO AND SE2.E2_PARCELA=SE5.E5_PARCELA "
	cQuery+= " AND SE2.E2_FORNECE=SE5.E5_CLIFOR AND SE2.E2_LOJA=SE5.E5_LOJA AND E5_DATA=E2_BAIXA) "
	cQuery+= " WHERE  E5_TIPO='TX' "
	cQuery+= " and E5_FILIAL   =  '" + xFilial("SE5")+ "'"
	cQuery+= " and SE5.E5_DATA >= '" + dToS(dDatabase) + "'"
	cQuery+= " and SE5.E5_DATA <= '" + dToS(dDatabase) + "'"
	cQuery+= " and SE5.E5_PREFIXO <> 'AGL'"
	cQuery+= " and SE5.E5_MOTBX    <> 'AGL'"
	cQuery+= " and SE5.E5_SITUACA  = 'C'"
	cQuery+= " and SE2.E2_CODRET   = '" + TMPPCC->E2_CODRET  + "'"
	cQuery+= " and SE2.E2_VENCREA >= '" + sData1 + "'"
	cQuery+= " and SE2.E2_VENCREA <= '" + sData2 + "'"
	cQuery+= " and SE2.E2_PREFIXO <> 'AGL' "
	cQuery+= " and SE2.E2_CODRET  <> ''    "
	cQuery+= " and SE5.D_E_L_E_T_ <> '*' "
	cQuery+= " and SE2.D_E_L_E_T_ <> '*' "
	
	nRet:=TcSqlExec(cQuery)
	If nRet<>0
		Alert(TCSQLERROR())
	Endif
	
	
	
	
	TMPPCC ->( dbSkip() )
	
EndDo


TMPPCC->(dbCloseArea())



/* ------------------ AGL PCC ------------------------*/


//-- Titulos de PCC
cQuery:= " SELECT E2_CODRET FROM "+RETSQLNAME("SE2")+" "
cQuery+= " WHERE  E2_TIPO='TX' "
//cQuery:= " and E2_NATUREZ IN ('73141','73121','73131','73171') "
//cQuery:= " and E2_CODRET  IN ('5960','5979','5987') "
cQuery+= " and E2_CODRET='5952' "
cQuery+= " and E2_FILIAL   = '" + xFilial("SE2") + "'"
cQuery+= " and E2_VENCREA >= '" + sData1 + "'"
cQuery+= " and E2_VENCREA <= '" + sData2 + "'"
cQuery+= " and E2_PREFIXO <> 'AGL' "
//EDY cQuery+= " and RTRIM(E2_AGLIMP)= ''"
cQuery+= " and E2_CODRET  <> ''    "
cQuery+= " and D_E_L_E_T_ <> '*'   "
cQuery+= " and E2_SALDO   > 0    "
cQuery+= " GROUP BY E2_CODRET "
cQuery:= ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMPPCC",.F.,.T.)
DbSelectArea("TMPPCC")



WHILE TMPPCC->(!EOF())
	incproc("Gerando AGL PCC: "+TMPPCC->E2_CODRET)
	aArray:={}
	aInfAGL:={}
	nTotal:=0
	aBaixa:={}
	//-- Titulos de PCC
	cQuery:= " SELECT * FROM "+RETSQLNAME("SE2")+" "
	cQuery+= " WHERE  E2_TIPO='TX' "
	cQuery+= " and E2_FILIAL   = '" + xFilial("SE2") + "'"
	cQuery+= " and E2_CODRET   = '" + TMPPCC->E2_CODRET + "'"
	cQuery+= " and E2_VENCREA >= '" + sData1 + "'"
	cQuery+= " and E2_VENCREA <= '" + sData2 + "'"
	cQuery+= " and E2_PREFIXO <> 'AGL' "
	//EDY cQuery+= " and RTRIM(E2_AGLIMP)= ''"
	cQuery+= " and E2_CODRET  <> ''    "
	cQuery+= " and E2_SALDO    > 0     "
	cQuery+= " and D_E_L_E_T_ <> '*'   "
	cQuery:= ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMPSUM",.F.,.T.)
	DbSelectArea("TMPSUM")
	//	TMPSUM->(DBGOTOP())
	WHILE TMPSUM->(!EOF())
		nTotal+= TMPSUM->E2_SALDO-TMPSUM->E2_DECRESC+ TMPSUM->E2_ACRESC
		If Empty(aInfAGL)
			If AllTrim(TMPSUM->E2_FORNECE)<>"".and. AllTrim(TMPSUM->E2_LOJA)<>"" .and. AllTrim(TMPSUM->E2_CODRET)<>""
				AADD(aInfAGL,TMPSUM->E2_FORNECE)
				AADD(aInfAGL,TMPSUM->E2_LOJA)
				AADD(aInfAGL,dtos(datavalida(stod(TMPSUM->E2_VENCTO),.F.)))
				AADD(aInfAGL,dtos(datavalida(stod(TMPSUM->E2_VENCREA),.F.)))
				AADD(aInfAGL,TMPSUM->E2_CODRET)
			Endif
		Endif
		aBaixa := {}
		
		AADD(aBaixa, {"E2_FILIAL"    , TMPSUM->E2_FILIAL , Nil})
		AADD(aBaixa, {"E2_PREFIXO"   , TMPSUM->E2_PREFIXO , Nil})
		AADD(aBaixa, {"E2_NUM"       , TMPSUM->E2_NUM , Nil})
		AADD(aBaixa, {"E2_PARCELA"   , TMPSUM->E2_PARCELA , Nil})
		AADD(aBaixa, {"E2_TIPO"      , TMPSUM->E2_TIPO , Nil})
		AADD(aBaixa, {"E2_FORNECE"   , TMPSUM->E2_FORNECE , Nil})
		AADD(aBaixa, {"E2_LOJA"      , TMPSUM->E2_LOJA , Nil})
		AADD(aBaixa, {"AUTMOTBX"     , "AGL" , Nil})
		AADD(aBaixa, {"AUTBANCO"     , "" , Nil})
		AADD(aBaixa, {"AUTAGENCIA"   , "" , Nil})
		AADD(aBaixa, {"AUTCONTA"     , "" , Nil})
		AADD(aBaixa, {"AUTDTBAIXA"   , dDataBase , Nil})
		AADD(aBaixa, {"AUTDTCREDITO" , dDataBase , Nil})
		AADD(aBaixa, {"AUTHIST"      , 'AGL/PARCELA '+cE2NUM , Nil})
		AADD(aBaixa, {"AUTVLRPG"     , TMPSUM->E2_SALDO-TMPSUM->E2_DECRESC+TMPSUM->E2_ACRESC , Nil})
		
		MSEXECAUTO({|x,y| FINA080(x,y)}, aBaixa, 3)
		
	
		
		///ACESSAPERG("FIN080", .F.)
		TMPSUM->(dbSkip())
	ENDDO
	
	
	
	TMPSUM->(dbCloseArea())
	
	// Calculo do proximo numero do lancamento
	//----------------------------------------------------------------
	c5Query := " SELECT ISNULL(MAX(E2_PARCELA)+1,'1') PROXDOC "
	c5Query += " FROM "+RETSQLNAME("SE2")+" "
	c5Query += " WHERE E2_PREFIXO = 'AGL'"
	c5Query += " AND   E2_NUM     = '" + cE2NUM + "'"
	c5Query += " AND   E2_FILIAL  = '" + xFilial("SE2") + "'"
	c5Query += " AND D_E_L_E_T_ <> '*' "
	c5Query := ChangeQuery(c5Query)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,c5Query),"TSE2PAR",.F.,.T.)
	DbSelectArea("TSE2PAR")
	cE2PAR:=""
	cE2PAR:=Strzero(TSE2PAR->PROXDOC,2)
	TSE2PAR->(dbCloseArea())
	//----------------------------------------------------------------
	
	
	aArray:={{ "E2_FILIAL"  ,  xFILIAL("SE2") , NIL },;
	{ "E2_PREFIXO"  , "AGL" , NIL },;
	{ "E2_NUM"      , cE2NUM            , NIL},;
	{ "E2_TIPO"     , "TX"              , NIL},;
	{ "E2_PARCELA"  , cE2PAR            , NIL},;
	{ "E2_NATUREZ"  , "73171", NIL},;
	{ "E2_FORNECE"  , AllTrim(aInfAGL[1]), NIL},;
	{ "E2_LOJA"     , AllTrim(aInfAGL[2])   , NIL},;
	{ "E2_EMISSAO"  , dDataBase           , NIL},;
	{ "E2_VENCTO"   , stod(aInfAGL[3])    , NIL},;
	{ "E2_VENCREA"  , stod(aInfAGL[4]) , NIL},;
	{ "E2_CODRET"   , AllTrim(aInfAGL[5]) , NIL},;
	{ "E2_VALOR"    ,nTotal             , Nil},;
	{ "E2_EMIS1"    ,ddatabase          , Nil},;
	{ "E2_LA"       ,"S"                , Nil},;
	{ "E2_SALDO"    ,nTotal             , Nil},;
	{ "E2_VLCRUZ"   ,nTotal             , Nil},;
	{ "E2_NUMTIT"   ,"FINA381"          , Nil},;
	{ "E2_HIST"     ,'AGL REF COD RET '+AllTrim(aInfAGL[5]), Nil},;
	{ "E2_DIRF"     ,'2'             , Nil},;
	{ "E2_MULTNAT"  ,'2'             , Nil}}
	
	
	MemoWrite("TesteAgl2.txt",varinfo("teste agl ",aArray))
	
	MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
	
	
	
	
	
	If lMsErroAuto
		MostraErro()
	Endif
	
	
	cQuery:=""
	
	cQuery:= " UPDATE " +RETSQLNAME("SE2")
	cQuery+= " SET E2_AGLIMP    ='" + cE2NUM  + "',"
	cQuery+= " E2_PARAGL    ='" + cE2PAR  + "',"
	cQuery+= " E2_NUMTIT='FINA381'   "
	cQuery+= " FROM " +RETSQLNAME("SE2")+" SE2 "
	cQuery+= " INNER JOIN " +RETSQLNAME("SE5")+" SE5  ON (SE5.E5_PREFIXO=SE2.E2_PREFIXO AND SE2.E2_TIPO=SE5.E5_TIPO "
	cQuery+= " AND SE2.E2_NUM=SE5.E5_NUMERO AND SE2.E2_PARCELA=SE5.E5_PARCELA "
	cQuery+= " AND SE2.E2_FORNECE=SE5.E5_CLIFOR AND SE2.E2_LOJA=SE5.E5_LOJA AND E5_DATA=E2_BAIXA) "
	cQuery+= " WHERE  E5_TIPO='TX' "
	cQuery+= " and E5_FILIAL   =  '" + xFilial("SE5")+ "'"
	cQuery+= " and SE5.E5_DATA >= '" + dToS(dDatabase) + "'"
	cQuery+= " and SE5.E5_DATA <= '" + dToS(dDatabase) + "'"
	cQuery+= " and SE5.E5_PREFIXO <> 'AGL'"
	cQuery+= " and SE5.E5_MOTBX    = 'AGL'"
	cQuery+= " and SE5.E5_SITUACA  <> 'C'"
	cQuery+= " and SE2.E2_CODRET   = '" + TMPPCC->E2_CODRET  + "'"
	cQuery+= " and SE2.E2_VENCREA >= '" + sData1 + "'"
	cQuery+= " and SE2.E2_VENCREA <= '" + sData2 + "'"
	cQuery+= " and SE2.E2_PREFIXO <> 'AGL' "
	cQuery+= " and SE2.E2_CODRET  <> ''    "
	cQuery+= " and SE5.D_E_L_E_T_ <> '*' "
	cQuery+= " and SE2.D_E_L_E_T_ <> '*' "
	
	nRet:=TcSqlExec(cQuery)
	If nRet<>0
		Alert(TCSQLERROR())
	Endif
	
	// Limpo os titulos tx que tiveram estorno na E5
	
	cQuery:= " UPDATE " +RETSQLNAME("SE2")
	cQuery+= " SET E2_AGLIMP    ='',"
	cQuery+= " E2_PARAGL    ='',"
	cQuery+= " E2_NUMTIT=''"
	cQuery+= " FROM " +RETSQLNAME("SE2")+" SE2 "
	cQuery+= " INNER JOIN " +RETSQLNAME("SE5")+" SE5  ON (SE5.E5_PREFIXO=SE2.E2_PREFIXO AND SE2.E2_TIPO=SE5.E5_TIPO "
	cQuery+= " AND SE2.E2_NUM=SE5.E5_NUMERO AND SE2.E2_PARCELA=SE5.E5_PARCELA "
	cQuery+= " AND SE2.E2_FORNECE=SE5.E5_CLIFOR AND SE2.E2_LOJA=SE5.E5_LOJA AND E5_DATA=E2_BAIXA) "
	cQuery+= " WHERE  E5_TIPO='TX' "
	cQuery+= " and E5_FILIAL   =  '" + xFilial("SE5")+ "'"
	cQuery+= " and SE5.E5_DATA >= '" + dToS(dDatabase) + "'"
	cQuery+= " and SE5.E5_DATA <= '" + dToS(dDatabase) + "'"
	cQuery+= " and SE5.E5_PREFIXO <> 'AGL'"
	cQuery+= " and SE5.E5_MOTBX    = 'EST'"
	cQuery+= " and SE5.E5_SITUACA  = 'C'"
	cQuery+= " and SE2.E2_CODRET   = '" + TMPPCC->E2_CODRET  + "'"
	cQuery+= " and SE2.E2_VENCREA >= '" + sData1 + "'"
	cQuery+= " and SE2.E2_VENCREA <= '" + sData2 + "'"
	cQuery+= " and SE2.E2_PREFIXO <> 'AGL' "
	cQuery+= " and SE2.E2_CODRET  <> ''    "
	cQuery+= " and SE5.D_E_L_E_T_ <> '*' "
	cQuery+= " and SE2.D_E_L_E_T_ <> '*' "
	
	nRet:=TcSqlExec(cQuery)
	If nRet<>0
		Alert(TCSQLERROR())
	Endif
	
	
	
	
	
	
	
	
	
	cQuery:=""
	
	cQuery:= " UPDATE " +RETSQLNAME("SE5")
	cQuery+= " SET E5_AGLIMP=E2_AGLIMP, "
	cQuery+= " E5_PARAGL=E2_PARAGL "
	cQuery+= " FROM " +RETSQLNAME("SE5")+" SE5 "
	cQuery+= " INNER JOIN " +RETSQLNAME("SE2")+" SE2  ON (SE5.E5_PREFIXO=SE2.E2_PREFIXO AND SE2.E2_TIPO=SE5.E5_TIPO "
	cQuery+= " AND SE2.E2_NUM=SE5.E5_NUMERO AND SE2.E2_PARCELA=SE5.E5_PARCELA "
	cQuery+= " AND SE2.E2_FORNECE=SE5.E5_CLIFOR AND SE2.E2_LOJA=SE5.E5_LOJA AND E5_DATA=E2_BAIXA) "
	cQuery+= " WHERE  E5_TIPO='TX' "
	cQuery+= " and E5_FILIAL   =  '" + xFilial("SE5")+ "'"
	cQuery+= " and SE5.E5_DATA >= '" + dToS(dDatabase) + "'"
	cQuery+= " and SE5.E5_DATA <= '" + dToS(dDatabase) + "'"
	cQuery+= " and SE5.E5_PREFIXO <> 'AGL'"
	
	//EDY cQuery+= " and RTRIM(SE5.E5_AGLIMP)='' "
	cQuery+= " and SE5.D_E_L_E_T_ <> '*' "
	cQuery+= " and SE2.D_E_L_E_T_ <> '*' "
	
	nRet:=TcSqlExec(cQuery)
	If nRet<>0
		Alert(TCSQLERROR())
	Endif
	
	
	TMPPCC ->( dbSkip() )
	
EndDo


TMPPCC->(dbCloseArea())


Return








