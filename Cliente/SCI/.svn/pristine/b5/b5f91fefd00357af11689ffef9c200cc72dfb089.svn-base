#Include "PROTHEUS.CH"
#Include "RPTDEF.CH"
#Include "FwPrintSetup.ch"

#Define STR0001 "Contratos"
#Define STR0007 "1-Cancelado"
#Define STR0008 "2-Elaboracao"
#Define STR0009 "3-Emitido"
#Define STR0010 "4-Em Aprovacao"
#Define STR0011 "5-Vigente"
#Define STR0012 "6-Cancelado"
#Define STR0013 "7-Solic. Finalizacao"
#Define STR0014 "8-Finalizado"
#Define STR0015 "9-Revisao"
#Define STR0016 "10-Revisado"
#Define STR0017 "Dias"
#Define STR0018 "Meses"
#Define STR0019 "Anos"
#Define STR0020 "Sim"
#Define STR0021 "Nao"
#Define STR0022 "Processando"
#Define STR0023 "OBJETO"
#Define STR0025 "JUSTIFICATIVAS"
#Define STR0031 "Folha....: "
#Define STR0032 "DT.Ref..: "
#Define STR0033 "Emissao.: "
#Define STR0034 "CANCELADO PELO OPERADOR"
#Define STR0039 "MEDICOES"
#Define STR0040 "EM BRANCO"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CNTR010  ³ Autor ³ Marcos V. Ferreira    ³ Data ³ 03.03.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Requisao de Contratos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo Cust³23/05/06³      ³Nome da funcao convertida para xxxxxR3    ³±±
±±³odio        ³        ³      ³para criacao de novo relario de acordo com³±±
±±³            ³        ³      ³a classe TReport                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³andre luis ³16/12/2014³³      ³Convercao do relaorio nao personalido   ³±±
±±³                              ³   para  a class FWMSPrinter            ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SCIR030( cAlias, nReg, nOpc )

Local cMens         := ""
Local nOpca         := 0 
Local cFilePrint    := "requisicao_contratos_" + DtoS(MsDate())+StrTran(Time(),":","")
Local cPathInServer := "\spool\" 
Local cSession      := GetPrinterSession()
Local aDevice       := {}
Local cPerg         := PADR("SCIR030",10/*TamSx3("X1_GRUPO")[1]*/)
Local lOk           := .T.
Local cRevAtu       := ""
Local cAditivo      := ""
Local lImprime      := .F.



Private cTitRel := OemToAnsi(STR0001) //Contratos
Private lEnd	:= .F.    
Private  oPrint := Nil
Private  oSetup := Nil
Private cTipContra
Private cDescri := ""
 
aAdd(aDevice,"DISCO") // 1
aAdd(aDevice,"SPOOL") // 2
aAdd(aDevice,"EMAIL") // 3
aAdd(aDevice,"EXCEL") // 4
aAdd(aDevice,"HTML" ) // 5
aAdd(aDevice,"PDF"  ) // 6
nLocal       	:= If(GetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
nOrientation	:= If(GetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
cDevice     	:= GetProfString(cSession,"PRINTTYPE","SPOOL",.T.)
nPrintType    	:= aScan(aDevice,{|x| x == cDevice })
 
cPathInServer   := "\spool\"
lAdjustToLegacy := .F.
lDisableSetup   := .T.
lViewPDF        := .T.
lPdfAsPng       := .T. //-- .T. Pdf





If FunName() == "CNTA300"
	cRevAtu  := Space( TamSX3("CN9_REVATU")[1] )
	cAditivo := CN9->CN9_REVISA
	
	If	Empty(CN9->CN9_REVISA) .And. Empty(CN9->CN9_REVATU)
	    lImprime := .T.
	EndIf
	
	If !lImprime
	
		cRevAtu := CN9->CN9_REVATU
	
		If	!Empty(CN9->CN9_REVISA)
			nReg := CN9->(Recno())
			DbSeek(xFilial("CN9") + CN9->CN9_NUMERO )
			cRevAtu := CN9->CN9_REVATU
			dbGoTo(nReg)
		EndIf
	
		If cRevAtu = cAditivo
			cDescri := AllTrim( Posicione("CN0",1,xFilial("CN9") + CN9->CN9_TIPREV,"CN0_DESCRI") )
		    lImprime := .T.
		EndIf
	
	EndIf
	
	If !lImprime
		MsgAlert("Este Contrato não é o Principal ou a última revisão")
		lOk := .F.
	EndIf
EndIf
	
If lOk //-- Contrato não possui revisão

	oPrint 	 := FWMSPrinter():New( cFilePrint ,IMP_PDF , lAdjustToLegacy , cPathInServer , lDisableSetup , , , , lPdfAsPng , , , lViewPDF )
	
	nFlags := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
	oSetup := FWPrintSetup():New( nFlags , cFilePrint )
	
	oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
	oSetup:SetPropert(PD_ORIENTATION , nOrientation)
	oSetup:SetPropert(PD_DESTINATION , nLocal)
	oSetup:SetPropert(PD_MARGIN      , {5,5,5,5})
	oSetup:SetPropert(PD_PAPERSIZE   , 2)
	// Ordem obrigátoria de configuração do relatório
	
	If oSetup:Activate() == PD_OK // PD_OK =1
		
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Salva os Parametros no Profile             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			WriteProfString( cSession, "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )
			WriteProfString( cSession, "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==1   ,"SPOOL"     ,"PDF"       ), .T. )
			WriteProfString( cSession, "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )
			
			// ----------------------------------------------
			// Define saida de impressão
			// ----------------------------------------------
			
			oPrint:SetResolution( 72 )
			oPrint:SetPortrait()
			oPrint:SetPaperSize( DMPAPER_A4 )
//			oPrint:SetMargin( 5,5,5,5 ) //nEsquerda, nSuperior, nDireita, nInferior
			oPrint:SetMargin( 60,60,5,5 ) //nEsquerda, nSuperior, nDireita, nInferior
		
			If	oSetup:GetProperty(PD_PRINTTYPE) = IMP_SPOOL
				
				oPrint:nDevice := IMP_SPOOL
				// ----------------------------------------------
				// Salva impressora selecionada
				// ----------------------------------------------
				fwWriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
				oPrint:cPrinter := oSetup:aOptions[PD_VALUETYPE]
						
			ElseIf oSetup:GetProperty(PD_PRINTTYPE) = IMP_PDF
				
				oPrint:nDevice := IMP_PDF
				// ----------------------------------------------
				// Define para salvar o PDF
				// ----------------------------------------------
				oPrint:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
				
			EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processamento do Relatorio									        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    RptStatus({|lEnd| CNR010Imp(@lEnd)})
		
	EndIf

EndIf //- End lOk	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CNR010IMP³ Autor ³ Marcos V. Ferreira    ³ Data ³ 03.03.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTR010			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CNR010Imp(lEnd)
Local cAliasTOP  := CriaTrab(Nil, .F.)
Local cQuery	 := ""
Local cSeek		 := ""
Local aStrucCN8  := {}
Local aStrucCN9  := {}
Local nX		 := 0
Local cDirSpool  := GetMv("MV_RELT")
Local lCtbCron
Local cPlanilha  := ""
Local cTpCtr     := ""
Local cFilePrint := "Requisao_Contratos"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera Picture dos Campos								           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cPtVIGE	:= PesqPict("CN9","CN9_VIGE")
Local cPtMINCAU := PesqPict("CN9","CN9_MINCAU")
Local cPtVlini  := PesqPict("CN9","CN9_VLINI")
Local cPtVlAdit := PesqPict("CN9","CN9_VLADIT") 
Local cPtVLATU  := PesqPict("CN9","CN9_VLATU")
Local cPtSALDO  := PesqPict("CN9","CN9_SALDO") 
Local cPtVLPREV := PesqPict("CN9","CN9_VLMIGR")
Local cCgc      := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa Fontes											           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oFont09
Local oFont09n2
Local oFont10n
Local oFont08n
Local oFont08
Local oFont06

Local cPerio  := ""
Local cNome   := ""
Local cFantas := ""
Local cCnpj   := ""
Local cInsc   := ""
Local cEnder  := ""
Local cBairro := ""
Local cRepres := ""
Local cContat := ""
Local cCidade := ""
Local cEstado := ""
Local cEmail  := ""
Local cCgc    := ""
Local cTel    := ""
Local cPicTel := ""
Local nPage   := 0 
Local cForne  := ""  
Local cCron   := ""    
Local cCota   := ""

Local aContent := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas pelo Objeto TMSPrinter					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nlin	:= 2900
Private nPagina := 0 
PRIVATE oDlg
Private nGet2:=Date()
PRIVATE oFont:= TFont():New("Arial",,14,.T.)
PRIVATE oSay2:=""
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Gerais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Private cImpCtbCro:=IF(mv_par20=1,.T.,.F.) // imrimir Cronograma contabil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa Objeto FWMSPrinter								 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oFont09n2 :=  TFontEx():New(oPrint,"Arial",09,09,.T.,.T.,.F.)
oFont10n  :=  TFontEx():New(oPrint,"Arial",10,10,.T.,.T.,.F.)
oFont09	  :=  TFontEx():New(oPrint,"Arial",09,09,.F.,.F.,.F.)

oFont08n  :=  TFontEx():New(oPrint,"Arial",08,08,.T.,.T.,.F.)
oFont08   :=  TFontEx():New(oPrint,"Arial",08,08,.F.,.F.,.F.)

oFont06n  :=  TFontEx():New(oPrint,"Arial",06,06,.T.,.T.,.F.)
oFont06   :=  TFontEx():New(oPrint,"Arial",06,06,.F.,.F.,.F.)

dbSelectArea("CNC")
dbSetOrder(1)
dbSeek(xFilial("CNC") + CN9->CN9_NUMERO + CN9->CN9_REVISA)

//lCompras := Empty(CN9->CN9_CLIENT)
lCompras := Empty( CNC->CNC_CLIENT )
nCompVend := If(lCompras, 1, 2)

cTpCtr  := CValToChar(nCompVend)
dbSelectArea("CN1")
dbSeek(xFilial()+cTpCtr)
If Found()
	cTipContra:=CN1->CN1_ESPCTR //TIPO DE CONTRAT COMPRA/VENDA
Endif

dbSelectArea("SX5");dbSetOrder(1)
dbSelectArea("SA1");dbSetOrder(1)
dbSelectArea("SA2");dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Query do Contrato											           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStrucCN9 := CN9->(dbStruct())
cQuery := "SELECT DISTINCT CN9.CN9_NUMERO, CN9.CN9_REVISA, CN9.R_E_C_N_O_ RECCN9 " 

If CN9->(FieldPos("CN9_FILCTR")) > 0
	cQuery += ", CN9_FILCTR "
EndIf
cQuery += " FROM " + RetSqlName("CN9") + " CN9 "
cQuery += " JOIN " + RetSqlName("CN1") + " CN1 ON "
cQuery += " CN1.D_E_L_E_T_ = '' AND "
cQuery += " CN1.CN1_FILIAL = '"+	xFilial("CN1")	+ "' AND "
cQuery += " CN1.CN1_CODIGO = CN9.CN9_TPCTO AND "
cQuery += " CN1.CN1_ESPCTR = '" +Str(nCompVend,1) +"' "
//If lCompras // Rel. Compras
	cQuery += "LEFT JOIN " + RetSqlName("CNC") + " CNC ON CNC.CNC_FILIAL = '" +xFilial("CNC") +"' AND "
	cQuery += "CNC.CNC_NUMERO = CN9.CN9_NUMERO AND CN9.CN9_REVISA = CNC.CNC_REVISA "
//Endif
cQuery += "WHERE CN9_FILIAL = '"+	xFilial("CN9")	+ "' AND "
cQuery += "CN9_NUMERO >= '"		+	CN9->CN9_NUMERO	+ "' AND "
cQuery += "CN9_NUMERO <= '"		+	CN9->CN9_NUMERO + "' AND "
cQuery += "CN9_REVISA >= '"		+	CN9->CN9_REVISA	+ "' AND "
cQuery += "CN9_REVISA <= '"		+	CN9->CN9_REVISA	+ "' AND "
cQuery += "CN9_DTINIC >= '"		+	dtos(CN9->CN9_DTINIC)	+ "' AND "
cQuery += "CN9_DTFIM  <= '"		+	dtos(CN9->CN9_DTFIM)	+ "' AND "
cQuery += "CN9_SITUAC >= '"		+	CN9->CN9_SITUAC		+ "' AND "
cQuery += "CN9_SITUAC <= '"		+	CN9->CN9_SITUAC		+ "' AND "
If lCompras // Rel. Compras
	cQuery += "CNC_CODIGO >= '"	+	CNC->CNC_CODIGO	+ "' AND "
	cQuery += "CNC_CODIGO <= '"	+	CNC->CNC_CODIGO	+ "' AND "
Else // Rel. Vendas  

	//cQuery += "CN9_CLIENT >= '"		+	CN9->CN9_CLIENT	+ "' AND "
	//cQuery += "CN9_CLIENT <= '"		+	CN9->CN9_CLIENT	+ "' AND "
	cQuery += "CNC_CLIENT >= '"	+	CNC->CNC_CLIENT	+ "' AND "
	cQuery += "CNC_CLIENT <= '"	+	CNC->CNC_CLIENT	+ "' AND "

Endif
If !Empty( CN9->CN9_TPCTO )
	cQuery += "CN9_TPCTO = '"	   	+	CN9->CN9_TPCTO	+ "' AND "
EndIf
cQuery += "CN9.D_E_L_E_T_ = '' "
cQuery += "ORDER BY CN9_NUMERO, CN9_REVISA "

cQuery := ChangeQuery(cQuery)  

MsAguarde({|| dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasTOP,.F.,.T.)},OemToAnsi(STR0022)) //-- Processando


For nX := 1 to Len(aStrucCN9)
	If aStrucCN9[nX,2] != 'C' .And. FieldPos(aStrucCN9[nx,1]) > 0
		TCSetField(cAliasTop,aStrucCN9[nX,1], aStrucCN9[nX,2],aStrucCN9[nX,3],aStrucCN9[nX,4])
	EndIf
Next nX

dbSelectArea(cAliasTop)
SetRegua(LastRec())
If (cAliasTOP)->(!EoF())
	
		Do While (cAliasTOP)->(!Eof())
			
			oPrint:StartPage()//Inicia uma nova página
			
			dbSelectarea("CN9")
		    dbGoto( (cAliasTOP)->RECCN9 )
		    
		    dbSelectArea("CNC")
			dbSetOrder(1)
			dbSeek(xFilial("CNC") + CN9->CN9_NUMERO + CN9->CN9_REVISA )
			
			If lEnd
				CNRBox(0050,2350,OemToAnsi(STR0034),,.T.,1) //-- CANCELADO PELO OPERADOR
				Exit
			EndIf
			
			IncProc()
			
			If empty(CN9->CN9_NUMERO)
				Loop
			EndIf
			
			nPage := 8+23
			nLin  := 0
			//.......................................................................................
			//  Requisição de Contrato
			//.......................................................................................
			cabec(oPrint)                       
			
			oPrint:Line( 055+23, 010, 055+23, 480)  // linha Dados da Contratacao
			                       
			//1 linha
			oPrint:Box( 055+23, 090, 65+25, 235 ) // departamento     
			oPrint:Box( 055+23, 235, 65+25, 320 ) // centro de custo
			oPrint:Box( 055+23, 320, 65+25, 450 ) // centro de custo    
			
			// box REQUISAO FINANCEIRO 
			oPrint:Box( 055+23, 450, 118  , 550 ) // REQUISAO FINANCEIRO
			             
			//2 linha
			oPrint:Box( 065+23, 090, 75+25, 235 ) //numero de contrato
			oPrint:Box( 065+23, 235, 75+25, 320 ) //interviniente
			oPrint:Box( 065+23, 320, 75+25, 450 )  //interviniente
			
			//3 linha
			oPrint:Box( 075+23, 090, 85+25, 235 ) //modalidade
			oPrint:Box( 075+23, 235, 85+25, 320 ) //tipo de contrato
			oPrint:Box( 075+23, 320, 85+25, 450 )  //tipo de contrato
            
			//.......................................................................................
			//  Dados da Contratacao
			//.......................................................................................
			nPage+=23             
			oPrint:Say( nPage + 020, 010, "DADOS DA CONTRATAÇÃO:"			                             , oFont10n:oFont )
			oPrint:Say( nPage + 012, 450, "PROTOCOLOS/FLUXO"			                                  ,oFont06n:oFont )  
			oPrint:Say( nPage + 020, 450, "REQUISIÇÃO FINANCEIRO"			                              ,oFont06n:oFont )  
	   
			nPage+=15
			
			//Denis - Compatibilização Lobo Guara
			//SX5->( Dbseek(xFilial("SX5")+"Z3"+CN9->CN9_AREA) )
			aContent := FWGetSX5( "Z3", CN9->CN9_AREA )
			
			If Len(aContent) == 0
				aContent := {{'','','',''}}
			EndIf
			 
			oPrint:Say( nPage + 015, 010, "DEPARTAMENTO:"			           , oFont06n:oFont )
			//oPrint:Say( nPage + 015, 095, alltrim(SX5->X5_DESCRI)			   , oFont06:oFont )
			oPrint:Say( nPage + 015, 095, alltrim( aContent[1][4] )			   , oFont06:oFont )			
			oPrint:Say( nPage + 015, 242, "CENTRO DE CUSTO:"			       , oFont06n:oFont )
			
			cQuery := " SELECT CNB_CC "
			cQuery += " FROM " + RetSqlName("CNA") + " CNA "
			cQuery += " INNER JOIN " + RetSqlName("CNB") + " CNB ON CNA_NUMERO = CNB_NUMERO AND CNA_CONTRA = CNB_CONTRA AND "
			cQuery += " CNA_REVISA = CNB_REVISA "
			cQuery += " WHERE "
			cQuery += " CNA_FILIAL = '"		+	xFilial("CNA")	+ "' AND "
			cQuery += " CNB_FILIAL = '"		+	xFilial("CNB")	+ "' AND "
			cQuery += " CNA_CONTRA = '"		+	CN9->CN9_NUMERO		+ "' AND "
			cQuery += " CNA_REVISA = '"		+	CN9->CN9_REVISA		+ "' AND "
			cQuery += " CNA.D_E_L_E_T_ <> '*' AND "
			cQuery += " CNB.D_E_L_E_T_ <> '*' " 
			dbUseArea( .t., 'TOPCONN', TCGenQry(,,cQuery), 'TMPCNA', .f., .t. )
			cCC := ""
			If TMPCNA->(!EoF())
			   cCC := TMPCNA->CNB_CC
			EndIf								
			TMPCNA->(DbCloseArea())
			 
			If Empty(cCC)
				cCC:=CN9->CN9_CC
			End
			
			cNomeCC:= alltrim(posicione("CTT",1,Xfilial("CTT")+cCC,"CTT_DESC01"))
			
			oPrint:Say( nPage + 015, 324,Alltrim(cCC) + "-" + substr(cNomeCC,1,22) ,oFont06:oFont )
			oPrint:Say( nPage + 017, 452, "DATA:         /          /  "        , oFont06:oFont )
					
			nPage+=10
			oPrint:Say( nPage + 015, 010, "Nº "+Upper(OemToAnsi(Substr(STR0001,1,8)))+":"			   ,oFont06n:oFont )
			oPrint:Say( nPage + 015, 095,CN9->CN9_NUMERO 	                                           ,oFont06:oFont )  
			
			                                          
			oPrint:Say( nPage + 015, 184, alltrim(RetTitle("CN9_REVISA"))+":",oFont06n:oFont )
			oPrint:Say( nPage + 015, 208,CN9->CN9_REVISA 	                                              ,oFont06:oFont )  
   			If!empty( CN9->CN9_INTERV )
				SA1->(Dbseek(xFilial("SA1")+CN9->CN9_INTERV+CN9->CN9_LJINTE ))
				oPrint:Say( nPage + 015, 242, "INTERVENIÊNTE:"			                                  ,oFont06n:oFont )
				oPrint:Say( nPage + 015, 324,substr(alltrim(SA1->A1_NOME),1,25) 	                       ,oFont06:oFont )
				
			EndIf
			
			
			oPrint:Say( nPage + 020, 452,  "NOME:"                               ,oFont06:oFont )
			
			nPage+=10
			oPrint:Say( nPage + 015, 010, "MODALIDADE:"			                                         ,oFont06n:oFont )
			
		  
			//Denis - Compatibilização Lobo Guara
			//SX5->( Dbseek(xFilial("SX5")+"Z4"+CN9->CN9_MODAL) )
			aContent := FWGetSX5( "Z4", CN9->CN9_MODAL )
			
			If Len(aContent) == 0 .or. Empty(CN9->CN9_MODAL)
				aContent := {{'','','',''}}
			EndIf

			//If cDescri != "" //-- Contrato de revisão
			If AllTrim(CN9->CN9_REVISA)<>""	
			    //oPrint:Say( nPage + 015, 095,cDescri                                          ,oFont06:oFont )
				oPrint:Say( nPage + 015, 095,POSICIONE("CN0",1,XFILIAL("CN0")+CN9->CN9_TIPREV,'CN0_DESCRI'),oFont06:oFont )
			Else
				//oPrint:Say( nPage + 015, 095,IIf(empty(CN9->CN9_REVISA),alltrim(SX5->X5_DESCRI),POSICIONE("CN0",1,XFILIAL("CN0")+CN9->CN9_TIPREV,'CN0_DESCRI')) ,oFont06:oFont )
				oPrint:Say( nPage + 015, 095,IIf(empty(CN9->CN9_REVISA),alltrim( aContent[1][4] ),POSICIONE("CN0",1,XFILIAL("CN0")+CN9->CN9_TIPREV,'CN0_DESCRI')) ,oFont06:oFont )
								
			EndIf
			
			//Denis - Compatibilização Lobo Guara
			//SX5->( Dbseek(xFilial("SX5")+"Z4"+CN9->CN9_TPOCTO) )
			aContent := FWGetSX5( "Z4", CN9->CN9_TPOCTO )
			
			If Len(aContent) == 0
				aContent := {{'','','',''}}
			EndIf

			oPrint:Say( nPage + 015, 242, "TIPO DE CONTRATO:"			                                 ,oFont06n:oFont )
			//oPrint:Say( nPage + 015, 324, Alltrim(SX5->X5_DESCRI)                                          ,oFont06:oFont )
			oPrint:Say( nPage + 015, 324, Alltrim( aContent[1][4] )                                          ,oFont06:oFont )
			
			nPage+=10
			oPrint:Say( nPage + 014, 452,  "RUBRICA:"                                                     , oFont06:oFont )
			
			//.......................................................................................
			//  Dados do Contratante
			//.......................................................................................
						
			nPage+=12
			oPrint:Say( nPage + 015, 010, "DADOS DO CONTRATANTE:"			                              ,oFont10n:oFont )    
			oPrint:Say( nPage + 017, 451,  "REQUISIÇÃO PRESIDÊNCIA"                                      , oFont06n:oFont )
			
			
			
			If !Empty( CNC->CNC_CLIENT ) //!empty(CN9->CN9_CLIENT )
			
				//SA1->(Dbseek(xFilial("SA1")+CN9->CN9_CLIENT+CN9->CN9_LOJACL ))
				SA1->( dbSeek(xFilial("SA1")+CNC->CNC_CLIENT+CNC->CNC_LOJACL ) )
				
				cNome := SA1->A1_NOME
				cFantas := SA1->A1_NREDUZ
				cCnpj:= SA1->A1_CGC
				cCpf := SA1->A1_CPFREPR
				cInsc:= SA1->A1_INSCR
				cEnder:= SA1->A1_END
				cBairro:= SA1->A1_BAIRRO
				cRepres:= SA1->A1_REPRLEG
				cContat:= SA1->A1_CONTATO
				cCidade:=SA1->A1_MUN
				cEstado := SA1->A1_EST
				cEmail:= SA1->A1_EMAIL
				IF SA1->A1_PESSOA=='J'
					cCgc:="@R 99.999.999/9999-99"
				ELSE
					cCgc:="@R 999.999.999-99"
				END
				cPicCpf := PesqPict("SA1","A1_CPFREPR")
				cTel:= SA1->A1_TEL
				cPicTel:=PesqPict("SA1","A1_TEL")
				
			Else       
			    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Impressao dos Fornecedores						 		  		 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    cForne := CNR010For(CN9->CN9_NUMERO,CN9->CN9_REVISA)
				
				SA2->(Dbseek(xFilial("SA2")+cForne ))
				
				cNome := SA2->A2_NOME
				cFantas := SA2->A2_NREDUZ
				cCnpj:= SA2->A2_CGC
				cCpf := SA1->A1_CPFREPR
				cPicCpf := PesqPict("SA1","A1_CPFREPR")
				cCgc:=PesqPict("SA2","A2_CGC")
				cInsc:= SA2->A2_INSCR
				cEnder:= SA2->A2_END
				cBairro:= SA2->A2_BAIRRO
				cRepres:= SA2->A2_REPRLEG
				cContat:= SA2->A2_CONTATO
				cCidade:=SA2->A2_MUN
				cEstado := SA2->A2_EST
				cEmail:= SA2->A2_EMAIL
				cTel  := SA2->A2_TEL
				cPicTel:=PesqPict("SA2","A2_TEL")
				
			EndiF

			// realiza o calculo do tamanho do box   
			
			nLin := nPage + 12
			cNome := AllTrim(cNome)
			nLinhasRS := Iif( MlCount( cNome,40) > 1,MlCount( cNome,40), 1) 
			
			nSizeBox := nLin + (nLinhasRS * 10) + 6
			nTam := Iif( (nLinhasRS * 10)>0, (nLinhasRS * 10)-10, 0)			
			       
			//Dados do contatante
			oPrint:Line(107+23, 010, 107+23, 480) 
			
			oPrint:Box( 107+23, 420, 147+23, 550 )   //presidenciavel
			
			oPrint:Box( 107+23, 090, 117+23 + nTam, 235 ) //linha razao social
			oPrint:Box( 107+23, 235, 117+23 + nTam, 320 )
			oPrint:Box( 107+23, 320, 117+23 + nTam, 450 )
			
			oPrint:Box( 117+23 + nTam, 090, 127+23 + nTam, 235 ) //linha CNPJ
			oPrint:Box( 117+23 + nTam, 235, 127+23 + nTam, 320 )
			oPrint:Box( 117+23 + nTam, 320, 127+23 + nTam, 450 )
			
			oPrint:Box( 127+23 + nTam, 090, 137+23 + nTam, 235 ) //Endereco
			oPrint:Box( 127+23 + nTam, 235, 137+23 + nTam, 320 )
			oPrint:Box( 127+23 + nTam, 320, 137+23 + nTam, 450 )
			
			oPrint:Box( 137+23 + nTam, 090, 147+23 + nTam, 235 ) //cidade
			oPrint:Box( 137+23 + nTam, 235, 147+23 + nTam, 320 )
			oPrint:Box( 137+23 + nTam, 320, 147+23 + nTam, 450 )
			
			oPrint:Box( 147+23 + nTam, 090, 157+23 + nTam, 235 ) //representante legal
			oPrint:Box( 147+23 + nTam, 235, 157+23 + nTam, 320 )
			oPrint:Box( 147+23 + nTam, 320, 157+23 + nTam, 450 )
			
			oPrint:Box( 157+23 + nTam, 090, 167+23 + nTam, 235 ) //contato comercial
			oPrint:Box( 157+23 + nTam, 235, 167+23 + nTam, 320 )
			oPrint:Box( 157+23 + nTam, 320, 167+23 + nTam, 450 )
			
			oPrint:Box( 167+23 + nTam, 090, 177+23 + nTam, 235 ) //Fone 2
			oPrint:Box( 167+23 + nTam, 235, 177+23 + nTam, 320 )
			oPrint:Box( 167+23 + nTam, 320, 177+23 + nTam, 450 )          
			                                                                  
			
			oPrint:Box( 167+23, 450, 177+50, 550 )    // requisiçao juridico
			                                                          
	         
			nPage+=12
			nLin := nPage
			For nI := 1 To nLinhasRS					
				oPrint:Say( nLin + 014, 095,MemoLine(cNome , 40, nI )         , oFont06:oFont )	
				nLin+=10				
			Next nI			
		
			
			oPrint:Say( nPage + 015, 010, "RAZÃO SOCIAL:"			                ,oFont06n:oFont )
			oPrint:Say( nPage + 014, 242, "NOME FANTASIA:"			            ,oFont06n:oFont )
			oPrint:Say( nPage + 014, 324, substr(cFantas,1,50)                    ,oFont06:oFont )  
			
			
			oPrint:Say( nPage + 015, 452, "DATA:         /          /  "       , oFont06:oFont )
			
			nPage+=10
			oPrint:Say( nPage + 015 + nTam, 010, "CNPJ/CPF:"			                    ,oFont06n:oFont )
			oPrint:Say( nPage + 014 + nTam, 095, Transform(cCnpj,cCgc) 			     ,oFont06:oFont )
			
			oPrint:Say( nPage + 014 + nTam, 242, "INSCRIÇÃO ESTADUAL:"			        ,oFont06n:oFont )
			oPrint:Say( nPage + 014 + nTam, 324,cInsc , oFont06:oFont )    
			
		    oPrint:Say( nPage + 018, 452,"NOME:"                               , oFont06:oFont )
			
			nPage+=10
			oPrint:Say( nPage + 014 + nTam, 010, "ENDEREÇO:"			                ,oFont06n:oFont )
			oPrint:Say( nPage + 014 + nTam, 095, substr(cEnder,1,35) 			         ,oFont06:oFont )
			
			oPrint:Say( nPage + 014 + nTam, 242, "BAIRRO:"			                    ,oFont06n:oFont )
			oPrint:Say( nPage + 014 + nTam, 324, cBairro                                ,oFont06:oFont )
			
			nPage+=10
			oPrint:Say( nPage + 015 + nTam, 010, "CIDADE:"			                   , oFont06n:oFont )
			oPrint:Say( nPage + 014 + nTam, 095, substr(cCidade,1,25)			        , oFont06:oFont ) 
			
			oPrint:Say( nPage + 014, 452,"RUBRICA:"                            , oFont06:oFont )
			
			oPrint:Say( nPage + 014 + nTam, 242, "ESTADO:"			                   , oFont06n:oFont )
			oPrint:Say( nPage + 014 + nTam, 324,cEstado , oFont06:oFont )
			
			nPage+=10
			oPrint:Say( nPage + 015 + nTam, 010, "REPRESENTANTE LEGAL:"			   , oFont06n:oFont )
			oPrint:Say( nPage + 014 + nTam, 095,cRepres 			                    , oFont06:oFont )
			
			oPrint:Say( nPage + 014 + nTam, 242, "CPF:"			                   , oFont06n:oFont )
			oPrint:Say( nPage + 014 + nTam, 324,Transform(cCpf,cPicCpf)                  , oFont06:oFont )
			
			nPage+=10
			oPrint:Say( nPage + 015 + nTam, 010, "CONTATO COMERCIAL:"			       , oFont06n:oFont )
			oPrint:Say( nPage + 014 + nTam, 095,cContat 			                    , oFont06:oFont )
			
			oPrint:Say( nPage + 014 + nTam, 242, "FONE 1:"			                   , oFont06n:oFont )
			oPrint:Say( nPage + 014 + nTam, 324, Transform(cTel,cPicTel)               , oFont06:oFont ) 
			
			oPrint:Say( nPage + 014, 451,  "REQUISIÇÃO JURÍDICO"               , oFont06n:oFont )
			
			nPage+=10
			oPrint:Say( nPage + 015 + nTam, 010, "FONE 2:"			                   , oFont06n:oFont )
			oPrint:Say( nPage + 014 + nTam, 095," " 			                        , oFont06:oFont )
			
			oPrint:Say( nPage + 015, 452,"DATA:         /          /  "       , oFont06:oFont ) 
			oPrint:Say( nPage + 027, 452,"NOME:"                                  , oFont06:oFont )
			
						
			oPrint:Say( nPage + 014 + nTam, 242, "E-MAIL:"			                   , oFont06n:oFont )
			
			
			// realiza o calculo de linhas do e-mail para imprimir o box
			cEmail := AllTrim(cEmail)
			
			nLinhas := Iif( MlCount( cEmail,38) > 1,MlCount( cEmail,38), 1)			
			
			If nLinhas > 1
				oPrint:Box( 167+23 + nTam, 320, nPage + (nLinhas * 10) + 4 + nTam, 450 ) // e-mail
			Else
				oPrint:Box( 167+23 + nTam, 320, 177+23 + nTam, 450 )
			EndIf
			// imprime o e-mail com quebras, em caso de dois e-mails ou mais 		
			
			nLin := nPage
			For nI := 1 To nLinhas					
				oPrint:Say( nLin + 014 + nTam, 324,MemoLine(cEmail , 38, nI )         , oFont06:oFont )	
				nLin+=10				
			Next nI						
					
			nPage+=30
			oPrint:Say( nPage + 10, 452,"RUBRICA:"                            , oFont06:oFont )
			nLin := 0
			


			//.......................................................................................
			//  Analise Financeira
			//.......................................................................................
			

			nLin +=nPage+30 //-- Forca a Quebra da pagina por Contrato
			//oPrint:Say( nLin -002, 451,  "REQUISIÇÃO JURÍDICO"                 , oFont06n:oFont )
			//oPrint:Box( nLin, 450, nLin+30, 550 ) 
			//oPrint:Say( nLin + 010, 452,"DATA ENVIO:         /          /"    , oFont06:oFont ) 
			//oPrint:Say( nLin + 025, 452,"DATA RETOR.:      /           /"       , oFont06:oFont ) 

			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Impressao do Contrato				      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			CNRBox(010,090,RetTitle("CN9_DTINIC"),dtoc(CN9->CN9_DTINIC),.F.)//-- Data Inicio
			CNRBox(090,240,RetTitle("CN9_SITUAC"),CNR010Sit(CN9->CN9_SITUAC),.T.)	//-- Situacao
			CNRBox(240,320,RetTitle("CN9_DTFIM"),dtoc(CN9->CN9_DTFIM),.F.)//-- Data Final
			CNRBox(320,450,RetTitle("CN9_VIGE"),Transform(CN9->CN9_VIGE,cPtVIGE) + " - " +IIf(CN9->CN9_UNVIGE == "1",OemToAnsi(STR0017),IIf(CN9->CN9_UNVIGE=="2",OemToAnsi(STR0018),OemToAnsi(STR0019))),.F.)	//-- Vigencia (Dias/Meses/Anos)
			             
			nLin+=15
			CNRBox(010,090,RetTitle("CN9_INDICE"),CN9->CN9_INDICE + " - " + Posicione("CN6",1,xFilial("CN6")+CN9->CN9_INDICE,"CN6_DESCRI"),.T.)//-- Indice
			CNRBox(090,240,RetTitle("CN9_FLGREJ"),IIf(CN9->CN9_FLGREJ=="1",OemToAnsi(STR0020),OemToAnsi(STR0021)),.F.)//-- Reajuste (Sim/Nao)
			CNRBox(240,320,RetTitle("CN9_REVATU")+"l",CN9->CN9_REVATU,.T.) //-- Revisao Atual
			CNRBox(320,450,RetTitle("CN9_VLINI"),"R$ "+TransForm(CN9->(C010xMoeda(.F.,CN9->CN9_NUMERO,CN9->CN9_REVISA,"CN9_VLINI")),cPtVlini),.F.)	//-- Valor Inicial
			
			nLin+=25   
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime Texto de Objetivo do Contrato					   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
			
			cObj := MSMM(CN9->CN9_CODOBJ, Len(SYP->YP_TEXTO),,,3)
				
			nTotLinha := MlCount( AllTrim( cObj ), 150)
				                                         
			//CNRBox(010,290,OemToAnsi(STR0023),,.T.,1) //-- Cabecalho OBJETO
			oPrint:Say( nLin, 010, "OBJETO:"			                              ,oFont10n:oFont )    
			nLin+=10                            
			
			oPrint:Box( nLin, 010, nLin + (nTotLinha * 10), 550 )    // requisiçao juridico

			For nX := 1 To nTotLinha 
				CNRBox(010,290,MemoLine(cObj,150,nX),,.T.,4,oFont06)
				nLin+=10   
			Next nX                       
			
			If nTotLinha == 0
				CNRBox(010,290,OemToAnsi(STR0040),,.T.,4) //-- EM BRANCO                    
				nLin+=10
			EndIf
				
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime Texto de justificativa do Contrato					      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			If!empty(CN9->CN9_REVISA)                     
			
				nLin+=20
			
				cJus := MSMM(alltrim(CN9->CN9_CODJUS))
				
				nTotLinha := MlCount( AllTrim(cJus), 140 )
		
				//CNRBox(290,010,OemToAnsi(STR0025),,.T.,1) //-- Cabecalho JUSTIFICATIVAS
				oPrint:Say( nLin, 010, "JUSTIFICATIVAS:"	                             ,oFont10n:oFont )    
				nLin+=10   
				oPrint:Box( nLin, 010, nLin + (nTotLinha * 10), 550 )    // requisiçao juridico
			
				For nX := 1 To nTotLinha 
					CNRBox(010,290,MemoLine(cJus,140,nX),,.T.,4,oFont06)
				    nLin+=10
				Next nXt
			    If nTotLinha == 0 
					CNRBox(010,010,OemToAnsi(STR0040),,.T.,4) //-- EM BRANCO
			        nLin+=10 
			    EndIf
            EndIf				
                
            nLin+=10

            IF ALLTRIM(POSICIONE("CN0",1,XFILIAL("CN0")+CN9->CN9_TIPREV,'CN0_CODIGO'))<>'002'
			//.......................................................................................
			//  Dados Negociais
			//.......................................................................................
			  nLin += 10
			  oPrint:Say( nLin + 005, 452,"ASSINATURA PRESIDENTE"             , oFont06n:oFont )
              oPrint:Say( nLin + 026, 010, "DADOS NEGOCIAIS:"			     , oFont06n:oFont )
			  oPrint:Box( nLin + 010, 450, 50+nLin, 550 )
			  
			  nLin+=30
			  oPrint:Say( nLin - 012, 452,  "NOME:"                          , oFont06:oFont )
			  oPrint:Say( nLin - 001, 452,  "DATA:         /          /  "   , oFont06:oFont )
			  oPrint:Say( nLin + 015, 452,  "RUBRICA:"                       , oFont06:oFont )
			  oPrint:Line( nLin, 010, nLin, 450)
				                				
			  oPrint:Box( nLin, 090, nLin+10, 175 ) // Garantia Minima Total
			  oPrint:Box( nLin, 175, nLin+10, 320 )
			  oPrint:Box( nLin, 320, nLin+10, 450 )
			    
			  
			  
			  oPrint:Say( nLin +008,010, "GARANTIA MÍN.TOTAL:"		       , oFont06n:oFont )
			  
			  cVlrMin := Iif( "CNTA300" $ FunName(), "R$ "+Transform(CN9->CN9_VLTOTG,cPtVlAdit) , "R$ "+Transform(CN9->CN9_VLINI,cPtVlini) )
			  
			  oPrint:Say( nLin +008,095,cVlrMin                                  , oFont06:oFont )
				
				If !empty(CN9->CN9_TXROY)
					oPrint:Say( nLin +008,185,   "ROYALTIES P/VEND." +IIF(CN9->CN9_TTXROY=='2',"BRUTA","LÍQUIDA")  + ":"          , oFont06n:oFont )
					oPrint:Say( nLin +008,274,Transform(CN9->CN9_TXROY,"@E 99.99")+" %"  , oFont06:oFont )
				EndIf
				
				If !empty(CN9->CN9_PERACE)
					oPrint:Say( nLin +008,324,   "PERÍODO DE ACERTO:"                ,oFont06n:oFont )
					
					If CN9->CN9_PERACE == "1"
						cPerio:="Mensal"
					ElseIf CN9->CN9_PERACE == "2"
						cPerio:="Bimestral"
					ElseIf CN9->CN9_PERACE == "3"
						cPerio:="Trimestral"
					ElseIf CN9->CN9_PERACE == "6"
						cPerio:="Semestral"
					ElseIf CN9->CN9_PERACE == "A"
						cPerio:="Anual"
					ElseIf CN9->CN9_PERACE == "F"
						cPerio:="Fim Contrato"
					EndIf
					oPrint:Say( nLin +008,400,   cPerio                               , oFont06:oFont )
				EndIf
				
			    nLin+=10             

				If !empty(CN9->CN9_PRZESC) 
				    oPrint:Box(nLin, 090, nLin+10, 175 ) //PRAZO DE ESCOAMENTO:
				    oPrint:Box(nLin, 175, nLin+10, 320 )
				    oPrint:Box(nLin, 320, nLin+10, 450 ) 
				    
					oPrint:Say( nLin +008,010, "PRAZO DE ESCOAMENTO:"                 , oFont06n:oFont )
					cPerio:= X3Combo( "CN9_PRZESC", CN9->CN9_PRZESC )
					oPrint:Say( nLin +008,095, cPerio			                      , oFont06:oFont ) 
					nLin+=10
				EndIf 
                    
                If !empty(CN9->CN9_CTCORT) 
                       
					cCota:=alltrim(CN9->CN9_CTCORT)
				  
					nLinhas := Iif( MlCount( cCota,090) > 1, MlCount( cCota,090),  1 ) 
					                                  
                     oPrint:Say( nLin +008,010,"COTA COR. POR PRODUTO:"            , oFont06n:oFont )    
				     
				     oPrint:Box( nLin, 090, nLin + (nLinhas * 10), 450 )    // box da Cota
				       
				  	 For nX := 1 To nLinhas   
						 oPrint:Say( nLin +008,095, MemoLine(cCota, 090, nX )              , oFont06:oFont )
						     
				         //maia oPrint:Say( nLin +008,095,CN9->CN9_CTCORT                         , oFont06:oFont )  
				         nLin+=10  
				     Next    
				EndIf
	
				oPrint:Box( nLin, 090, nLin+10, 175 ) //PRAZO CONTRATUAL:
				oPrint:Box( nLin, 175, nLin+10, 450 )
				
				IF CN9->CN9_UNVIGE='1'
					cUnidade:="/Dias"
				ELSEIF CN9->CN9_UNVIGE='2'
					cUnidade:="/Meses"
				ELSEIF CN9->CN9_UNVIGE='3'
					cUnidade:="/Anos"
				ELSEIF CN9->CN9_UNVIGE='4'
					cUnidade:="Indeterminada" 
				END                               
				                                                           
				oPrint:Say( nLin +008,010, "PRAZO CONTRATUAL:"			                               , oFont06n:oFont )
				oPrint:Say( nLin +008,095, STR(CN9->CN9_VIGE,3) +" "+cUnidade                        , oFont06:oFont )
				
				If !empty(CN9->CN9_CARMIN)
					oPrint:Say( nLin +008,185,   "CARÊNCIA MÍN.GARANT./INICIO DA COMERCIALIZAÇÃO:"     , oFont06n:oFont )
					cPerio:= ""
					If CN9->CN9_CARMIN == "1"
						cPerio:="Nao se Aplica"
					ElseIf CN9->CN9_CARMIN == "2"
						cPerio:="1 Mes"
					ElseIf CN9->CN9_CARMIN == "3"
						cPerio:="2 Meses"
					ElseIf CN9->CN9_CARMIN == "4"
						cPerio:="3 Meses"
					ElseIf CN9->CN9_CARMIN == "5"
						cPerio:="4 Meses"
					ElseIf CN9->CN9_CARMIN == "6"
						cPerio:="5 Meses"
					ElseIf CN9->CN9_CARMIN == "7"
						cPerio:="6 Meses"
					EndIf
					oPrint:Say( nLin +008,360,   cPerio                                                 , oFont06:oFont )
				EndIf

				nLin+=10
				oPrint:Box( nLin, 090, nLin+10, 175 ) //FORMA DE PAGTO:
				oPrint:Box( nLin, 175, nLin+10, 450 )
				
				oPrint:Say( nLin +008,010, "FORMA DE PAGTO:"			                                , oFont06n:oFont )
				oPrint:Say( nLin +008,095, IIF(CN9->CN9_FORPAG=="1","Parcelado","A Vista")             , oFont06:oFont )
				
				oPrint:Say( nLin +008,185, "VALOR DA PARCELA:"                                          , oFont06n:oFont )
				oPrint:Say( nLin +008,264, "R$ "+Transform(CN9->CN9_VLMIGR,cPtVLPREV)                  , oFont06:oFont )
				
				oPrint:Say( nLin+008, 452,"CONTRATO CLIENTE"                                            , oFont06n:oFont )
				
				
				nLin+=10
				oPrint:Box( nLin, 090, nLin+10, 175 ) //Nº DE PARCELAS:
				oPrint:Box( nLin, 175, nLin+10, 450 )

				oPrint:Box( nLin, 450, nLin+10, 550 )    // box Contrato Cliente
				
				oPrint:Say( nLin +008,010, "Nº DE PARCELAS:"			                               , oFont06n:oFont )
				oPrint:Say( nLin +008,095,  cValToChar( CN9->CN9_QTDEPA )                            , oFont06:oFont ) 
				//oPrint:Say( nLin +008,095, "" 						                                   , oFont06:oFont ) 
				
				oPrint:Say( nLin +008,185,"DATA PRIMEIRO PAGTO:"	                                      , oFont06n:oFont )
						      
				  
				cCron := ""
				cQuery := " SELECT CNA_CRONOG "
				cQuery += " FROM " + RetSqlName("CNA") + " CNA "
				cQuery += " INNER JOIN " + RetSqlName("CNB") + " CNB ON CNA_NUMERO = CNB_NUMERO AND CNA_CONTRA = CNB_CONTRA AND "
				cQuery += " CNA_REVISA = CNB_REVISA "
				cQuery += " WHERE "
				cQuery += " CNA_FILIAL = '"		+	xFilial("CNA")	+ "' AND "
				cQuery += " CNB_FILIAL = '"		+	xFilial("CNB")	+ "' AND "
				cQuery += " CNA_CONTRA = '"		+	CN9->CN9_NUMERO		+ "' AND "
				cQuery += " CNA_REVISA = '"		+	CN9->CN9_REVISA		+ "' AND "
                                                
				cQuery += " CNA.D_E_L_E_T_ <> '*' AND "
				cQuery += " CNB.D_E_L_E_T_ <> '*' " 
				dbUseArea( .t., 'TOPCONN', TCGenQry(,,cQuery), 'TMPCNA', .f., .t. )
				If TMPCNA->(!EoF())
				       
				   cCron := TMPCNA->CNA_CRONOG
				EndIf								
				TMPCNA->(DbCloseArea())     
				  
				dbSelectArea("CNF")
                dbSetOrder(1) //-- CNF_FILIAL+CNF_NUMERO+CNF_CONTRA+CNF_REVISA
                MsSeek(cSeekCNF := xFilial("CNF")+cCron+CN9->CN9_NUMERO+CN9->CN9_REVISA)
				
				oPrint:Say( nLin +008,274,       DTOC(CN9->CN9_PRDTPG)                                     , oFont06:oFont )
				
				oPrint:Say( nLin+008, 452,"DATA:         /          /"                                     , oFont06:oFont )
				
				nLin+=10
				oPrint:Box( nLin, 090, nLin+10, 175 )     //VIGÊNCIA CONTRATUAL:
				oPrint:Box( nLin, 175, nLin+10, 320 )
				oPrint:Box( nLin, 320, nLin+10, 450 )
				
				oPrint:Say( nLin +008,010, "VIGÊNCIA CONTRATUAL:"			                              , oFont06n:oFont )
				oPrint:Say( nLin +008,095, "INICIO:"			                                          , oFont06n:oFont )
				oPrint:Say( nLin +008,120, DTOC(CN9->CN9_DTINIC)                                          , oFont06:oFont )
				
				
				oPrint:Say( nLin +008,324, "FIM:"			                                              , oFont06n:oFont )
				oPrint:Say( nLin +008,344,DTOC(CN9->CN9_DTFIM)                                            , oFont06:oFont )
				
				nLin+=10
				oPrint:Box(nLin, 090, nLin+10, 175 ) //FORMA DE COBRANÇA::
				oPrint:Box(nLin, 175, nLin+10, 320 )
				oPrint:Box(nLin, 320, nLin+10, 450 )
				
				oPrint:Say( nLin +008,010, "FORMA DE COBRANÇA:"			                                 , oFont06n:oFont )
				oPrint:Say( nLin +008,095, IIF(CN9->CN9_FORCOB=="1","Boleto","Deb.Conta")             , oFont06:oFont )

				If !empty(CN9->CN9_DIAVEN)
					oPrint:Say( nLin +008,185, "DIA DE VENCIMENTO:"			                             , oFont06n:oFont )
					oPrint:Say( nLin +008,274, CN9->CN9_DIAVEN                                            , oFont06:oFont )
				EndIf
				
				oPrint:Say( nLin +008,452,"CONTRATO FINANCEIRO"                                          , oFont06n:oFont )
				
				nLin+=10
				oPrint:Box(nLin, 090, nLin+10, 175 ) //DIA DE RELATÓRIO:
				oPrint:Box(nLin, 175, nLin+10, 320 )
				oPrint:Box(nLin, 320, nLin+10, 450 ) 
				
				oPrint:Box( nLin, 450,nLin+10, 550 )   // box contrato cliente


				oPrint:Box( nLin + 010, 450,  nLin+50, 550 )// box contrato financeiro
				
				oPrint:Say( nLin + 017, 452, "DATA:         /          /  "                              , oFont06:oFont )
				oPrint:Say( nLin + 040, 452, "RUBRICA:"                                                  , oFont06:oFont )
				
				If !empty(CN9->CN9_DIAREL)
					oPrint:Say( nLin +008,010, "DIA DE RELATÓRIO:"			                             , oFont06n:oFont )
					oPrint:Say( nLin +008,095,CN9->CN9_DIAREL                                            , oFont06:oFont )
				EndIf
				If !empty(CN9->CN9_SELOBR)
					oPrint:Say( nLin +008,185, "OBRIGAÇÃO DE SELO HOLOGRÁFICO:"			                 , oFont06n:oFont )
					oPrint:Say( nLin +008,324,IIF(CN9->CN9_SELOBR=="1","SIM","NÃO")                       , oFont06:oFont )
					
					oPrint:Say( nLin +008,452,"DEPTO DE COBRANÇA"                                         , oFont06:oFont )
				EndIf

				nLin += 10
				
				If !Empty(CN9->CN9_VENC1) .Or. !Empty(CN9->CN9_PARC1)
					R10ImpParc() //-- imprime os valores do parcelamento
				EndIf
				
				cObser:=alltrim(CN9->CN9_OBSESP)
				nLinhas := Iif( MlCount( cObser,090) >= 3,MlCount( cObser,090), 3)
				
				oPrint:Box( nLin, 090, nLin + (nLinhas * 10) + 10, 450 ) //OBS ESPECIFICAS:
				oPrint:Say( nLin +008,010, "OBS ESPECÍFICAS:"			                                 , oFont06n:oFont )
								
				For nI := 1 To nLinhas
					
					oPrint:Say( nLin +008,095, MemoLine(cObser , 090, nI ) 			                      , oFont06:oFont )
					
					nLin+=10
					
				Next nI
			  
			 //................................................................................................................
			Else //Fim Dados Negociais
			
			  DEFINE MSDIALOG oDlg FROM 0,0 TO 225,250 PIXEL TITLE 'Data da Recisao'

              oSay2 := TSay():New( 35, 01,{|| "Dt. Recisão:"},oDlg,, oFont,,,, .T., CLR_BLACK,CLR_WHITE )
              oSay2:lTransparent:= .F.           

              @ 32,65 MSGET oGet2 VAR nGet2 SIZE 46,10 OF oDlg PIXEL PICTURE  "99/99/9999"

              oSButton1 := SButton():New( 70,30,1,{|| oDlg:End()},oDlg,.T.,,)
              oSButton2 := SButton():New( 70,70,2,{|| oDlg:End()},oDlg,.T.,,)

              ACTIVATE MSDIALOG oDlg CENTERED
			  
			  
			  nLin += 10
			  oPrint:Box( nLin, 010, 15+nLin, 550 )
			  //oPrint:Box( nLin, 010, nLin + 10, 550 )    // requisiçao juridico
			  oPrint:Say(nLin +010, 020,"DATA RESCISÃO: "+DtoC(nGet2),oFont06n:oFont)
			  nLin += 10
			End
			
			If nLin >= 580
				nLin:=15
				oPrint:EndPage()
				oPrint:StartPage()
				cabec(oPrint)
				nLin:=75
			EndIf			
				  
					 
			R10ImpAss() //-- Imprime a area de assinaturas
			        
			
			nLin := 0
			oPrint:EndPage()
			(cAliasTop)->(dbSkip()) 
			
		EndDo
				
		//-- Visualiza antes de Imprimir
		
		oPrint:Preview()
		FreeObj( oPrint ) 
		FreeObj( oSetup )
		oPrint   := Nil
		oSetup   := Nil
Else 

    Aviso("Atenção!", "Não há relatório para ser impresso. Verifique os parâmetros de impressão.", {"Ok"}, 3)
    
    FreeObj( oPrint ) 
	FreeObj( oSetup )
	oPrint   := Nil
	oSetup   := Nil

EndIf	

//-- Encerra arquivo de Trabalho
dbSelectArea(cAliasTop)
dbCloseArea()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R10ImpAss ºAutor  ³Giovanni Melo       º Data ³  09/02/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Imprime a area de assinaturas                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ Nenhum                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno	 ³ Nenhum                    								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ scir030													  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R10ImpAss() 

	Local oFont06n := TFontEx():New(oPrint,"Arial",06,06,.T.,.T.,.F.)
	Local oFont06  := TFontEx():New(oPrint,"Arial",06,06,.F.,.F.,.F.)

	nLin+=20
	oPrint:Say( nLin + 010, 010,"DEPARTAMENTO REQUISITANTE:", oFont06n:oFont )
	oPrint:Line( nLin, 010, nLin, 480)
	
	nLin+=10
//	oPrint:Say( nLin +015, 020, "DIRETOR: "                                        , oFont06n:oFont ) 
	oPrint:Say( nLin +015, 020, "RESPONSÁVEL DA ÁREA: "                                        , oFont06n:oFont )
	oPrint:Say( nLin +015, 190,"DATA:        /          /           ASSINATURA/CARIMBO: ", oFont06:oFont )			
	nLin+=20
	oPrint:Line( nLin, 010, nLin, 480)
	oPrint:Say( nLin +015, 020, "OBSERVAÇÕES: "                                     , oFont06:oFont )
	oPrint:Box( nLin, 090, nLin+35, 480 )
				
	nLin+=45
	oPrint:Say( nLin +08, 020, "VICE-PRESIDENTE: "                                , oFont06n:oFont )
	oPrint:Say( nLin +08, 190,"DATA:        /          /           ASSINATURA/CARIMBO: ", oFont06:oFont )
	nLin+=15
	oPrint:Line( nLin, 010, nLin, 480)			
	oPrint:Box( nLin, 090, nLin+35, 480 )
	oPrint:Say( nLin +015, 020, "OBSERVAÇÕES: "                                   , oFont06:oFont )
		
	nLin+=40			
	oPrint:Say( nLin +014, 010, "APROVAÇÃO PRESIDÊNCIA: ", oFont06n:oFont )
	oPrint:Say( nLin +014, 190,"DATA:      /          /           ASSINATURA/CARIMBO: ", oFont06:oFont )
	nLin+=20
	oPrint:Line( nLin, 010, nLin, 480)
						
	nLin+=5
	
	oPrint:Say( nLin +015, 020, "ANÁLISE JURÍDICA"                              , oFont06n:oFont )
	nLin+=20
	oPrint:Line( nLin, 010, nLin, 480)
	oPrint:Say( nLin +015, 020, "OBSERVAÇÕES: "                                  , oFont06:oFont )
	oPrint:Box( nLin, 090, nLin+35, 480 )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ cabec³ Autor ³ andre luis                ³ Data ³ 15.12.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de cabecalho do relaotrio                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ 			                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function cabec(oPrint)
//Local oFont09n2 :=  TFontEx():New(oPrint,"Arial",10,10,.T.,.T.,.F.)
Local oFont10n  :=  TFontEx():New(oPrint,"Arial",11,11,.T.,.T.,.F.)
Local clogo     :="LogoSCIContrato.bmp"

nLin+=10
oPrint:Box( nLin, 010, nLin+35, 550 )

oPrint:SayBitmap( nLin+001 ,14 ,clogo,30,30, , )
oPrint:Say( nLin + 020, 250, "REQUISIÇÃO DE CONTRATO"			   , oFont10n:oFont )

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CNR010For³ Autor ³ Marcos V. Ferreira    ³ Data ³03/03/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Fornecedores							                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Contrato                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTR010  		                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CNR010For(cContrato,cRevisa)
Local aAreaAnt	:= GetArea()
Local cSeek		:= ""
Local cFornece  := ""

Default cContrato := ""

If !Empty(cContrato)
	//If mv_par13 == 1
		dbSelectArea("CNC")
		dbSetOrder(1)
		If MsSeek(cSeek := xFilial("CNC")+cContrato+If(FieldPos("CNC_REVISA")>0,cRevisa,""))
		    /*
	              CNRBox(0300,0480,Posicione("SA2",1,xFilial("SA2")+CNC->CNC_CODIGO+CNC->CNC_LOJA,"A2_NOME"),,.T.,2,oFont06)
		          CNRBox(0300,0480,Posicione("SA1",1,xFilial("SA1")+CNC->CNC_CLIENT+CNC->CNC_LOJACL,"A1_NOME"),,.T.,2,oFont06)
			
			*/   
			 cFornece := CNC->CNC_CODIGO+CNC->CNC_LOJA
		EndIf
	//EndIf
EndIf

RestArea(aAreaAnt)
Return(cFornece)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CNR010Cro| Autor ³ Marcos V. Ferreira    ³ Data ³03/03/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cronogramas							                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Cronograma                               ³±±
±±³          ³ ExpC2 = Codigo do Contrato                                 ³±±
±±³          ³ ExpC3 = Codigo da Revisao                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTR010 / CNTR020                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CNR010Cro(cCronogra,cContrato,cRevisao,lImpCro,nCNBTamPrd,cProduto,dInicio,dFim)
Local aAreaAnt := GetArea()
Local cSeekCNF := ""
Local lCabecCro:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa Fontes										              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oFont06  := TFontEx():New(oPrint,"Arial",07,07,.F.,.F.,.F.)
Local oFont06n  := TFontEx():New(oPrint,"Arial",07,07,.T.,.T.,.F.)

Local oFont08  := TFontEx():New(oPrint,"Arial",09,09,.F.,.F.,.F.)
Local oFont08n  := TFontEx():New(oPrint,"Arial",09,09,.T.,.T.,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera Picture dos Campos									        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cPtVLPREV := PesqPict("CN9","CN9_VLMIGR")
Local cPtSALDO2 := PesqPict("CNF","CNF_SALDO")
Local cPtVLREAL := PesqPict("CNF","CNF_VLREAL")
Local cPtVlini  := PesqPict("CN9","CN9_VLINI")
//Local cPtVlAdit := PesqPict("CN9","CN9_VLADIT")   
Local cPtVlAdit := PesqPict("CN9","CN9_VLTOTG")   
Local nLinhas   := 0
Local cObser    := ""
Local cPerio    := ""

Default cCronogra := ""
Default cContrato := ""
Default cRevisao  := ""
Default lImpCro	  := .T.
Default nCNBTamPrd:= TamSX3("CNB_PRODUT")[1]
Default cProduto  := ""

If !Empty(cContrato) .And. !Empty(cCronogra)
	
	If lImpCro
		dbSelectArea("CNF")
		dbSetOrder(1) //-- CNF_FILIAL+CNF_NUMERO+CNF_CONTRA+CNF_REVISA
		If MsSeek(cSeekCNF := xFilial("CNF")+cCronogra+cContrato+cRevisao)
			
			lCabecCro := .T.

			 	nLin += 10
				
				nLin += 10
				
				dbSelectArea("CN9")
				dbSetOrder(1)
				dbSeek(xFilial("CN9")+CNF->CNF_CONTRA+CNF->CNF_REVISA)
				
				oPrint:Say( nLin +005, 482,"ASSINATURA PRESIDENTE"            , oFont08n:oFont )
				oPrint:Say( nLin + 026, 010, "DADOS NEGOCIAIS:"			      , oFont08n:oFont )
				oPrint:Box( nLin + 010, 480, 50+nLin, 580 )
				nLin+=30
				oPrint:Say( nLin - 012, 482,  "NOME:"                          , oFont08:oFont )
				oPrint:Say( nLin - 001, 482," DATA:         /          /  "    , oFont08:oFont )
				oPrint:Say( nLin + 015, 482,  "RUBRICA:"                       , oFont08:oFont )
				oPrint:Line( nLin, 010, nLin, 480)
				
				oPrint:Box( nLin, 090, nLin+10, 172 ) //VALOR MÍN.GARANT. TOTAL:
				oPrint:Box( nLin, 172, nLin+10, 270 )
				oPrint:Box( nLin, 270, nLin+10, 350 )
				oPrint:Box( nLin, 350, nLin+10, 430 )
				oPrint:Box( nLin, 430, nLin+10, 480 )
				
				//cVlrMin := Iif( "CNTA300" $ FunName(), Transform(CN9->CN9_VLADIT,cPtVlAdit) , Transform(CN9->CN9_VLINI,cPtVlini) )
				cVlrMin := Iif( "CNTA300" $ FunName(), Transform(CN9->CN9_VLTOTG,cPtVlAdit) , Transform(CN9->CN9_VLINI,cPtVlini) )
				
				oPrint:Say( nLin +008,010, "VALOR MÍN.GARANT.TOTAL:"		       , oFont06n:oFont )
				oPrint:Say( nLin +008,095,cVlrMin                                   , oFont06:oFont )
				
				If !empty(CN9->CN9_TXROY)
					oPrint:Say( nLin +008,185,   "ROYALTIES P/VEND." +IIF(CN9->CN9_TTXROY=='2',"BRUTA","LÍQUIDA")  + ":"          , oFont06n:oFont )
					oPrint:Say( nLin +008,274,Transform(CN9->CN9_TXROY,"@E 99.99")+" %"  , oFont06:oFont )
				EndIf
				
				If !empty(CN9->CN9_PERACE)
					oPrint:Say( nLin +008,354,   "PERÍODO DE ACERTO:"                ,oFont06n:oFont )
					
					If CN9->CN9_PERACE=="1"
						cPerio:="Mensal"
					ElseIf CN9->CN9_PERACE=="2"
						cPerio:="Bimestral"
					ElseIf CN9->CN9_PERACE=="3"
						cPerio:="Trimestral"
					ElseIf CN9->CN9_PERACE=="6"
						cPerio:="Semestral"
					ElseIf CN9->CN9_PERACE=="A"
						cPerio:="Anual"
					EndIf
					oPrint:Say( nLin +008,434,   cPerio                               , oFont06:oFont )
				EndIf
				
				nLin+=10
				oPrint:Box(nLin, 090, nLin+10, 175 ) //PRAZO DE ESCOAMENTO:
				oPrint:Box(nLin, 175, nLin+10, 320 )
				oPrint:Box(nLin, 320, nLin+10, 450 )
				
				If !empty(CN9->CN9_PRZESC)
					oPrint:Say( nLin +008,010, "PRAZO DE ESCOAMENTO:"                 , oFont06n:oFont )
					
					cPerio:= ""
					If CN9->CN9_PRZESC =="1"
						cPerio:="30 Dias"
					ElseIf CN9->CN9_PRZESC =="2"
						cPerio:="60 Dias"
					ElseIf CN9->CN9_PRZESC =="3"
						cPerio:="90 Dias"
					ElseIf CN9->CN9_PRZESC =="4"
						cPerio:="120 Dias"
					EndIf
					oPrint:Say( nLin +008,095, cPerio			                       , oFont06:oFont )
				EndIf
				If !empty(CN9->CN9_CTCORT)
					oPrint:Say( nLin +008,220,"COTA CORTESIA POR MODELO DE PRODUTO:"   , oFont06n:oFont )
					
					
					
					
					
					oPrint:Say( nLin +008,354,alltrim(CN9->CN9_CTCORT)                  , oFont06:oFont )
				EndIf 
				    
			
				nLin+=10
				oPrint:Box( nLin, 090, nLin+10, 172 ) //PRAZO CONTRATUAL:
				oPrint:Box( nLin, 172, nLin+10, 350 )
				oPrint:Box( nLin, 350, nLin+10, 480 )
				
				oPrint:Say( nLin +008,010, "PRAZO CONTRATUAL:"			                               , oFont06n:oFont )
				oPrint:Say( nLin +008,095, CNF->CNF_COMPET                                              , oFont06:oFont )
				
				If !empty(CN9->CN9_CARMIN)
					oPrint:Say( nLin +008,185,   "CARÊNCIA MÍN.GARANT./INICIO DA COMERCIALIZAÇÃO:"     , oFont06n:oFont )
					cPerio:= ""
					If CN9->CN9_CARMIN == "1"
						cPerio:="Nao se Aplica"
					ElseIf CN9->CN9_CARMIN == "2"
						cPerio:="1 Mes"
					ElseIf CN9->CN9_CARMIN == "3"
						cPerio:="2 Meses"
					ElseIf CN9->CN9_CARMIN == "4"
						cPerio:="3 Meses"
					ElseIf CN9->CN9_CARMIN == "5"
						cPerio:="4 Meses"
					EndIf
					oPrint:Say( nLin +008,352,   cPerio                                                 , oFont06:oFont )
				EndIf
				nLin+=10
				oPrint:Box( nLin, 090, nLin+10, 172 ) //FORMA DE PAGTO:
				oPrint:Box( nLin, 172, nLin+10, 350 )
				oPrint:Box( nLin, 350, nLin+10, 480 )
				
				oPrint:Say( nLin +008,010, "FORMA DE PAGTO:"			                                , oFont06n:oFont )
				oPrint:Say( nLin +008,185,   "VALOR DA PARCELA:"                                        , oFont06n:oFont )
				oPrint:Say( nLin+008, 482,"CONTRATO CLIENTE"                                            , oFont06n:oFont )
				
				oPrint:Say( nLin +008,095, IIF(CN9->CN9_FORPAG=="1","BOLETO","CRED.CONTA")             , oFont06:oFont )
				//oPrint:Say( nLin +008,0354, Transform(CNF->CNF_VLPREV,cPtVLPREV)                        , oFont06:oFont )
				oPrint:Say( nLin +008,0354, Transform(CN9->CN9_VLMIGR,cPtVLPREV)                        , oFont06:oFont )
				
				nLin+=10
				oPrint:Box( nLin, 090, nLin+10, 172 ) //Nº DE PARCELAS:
				oPrint:Box( nLin, 172, nLin+10, 270 )
				oPrint:Box( nLin, 270, nLin+10, 350 )                         
				
				oPrint:Box( nLin, 350, nLin+10, 425 )
				oPrint:Box( nLin, 425, nLin+10, 480 )
				oPrint:Box( nLin, 480,  nLin+10, 580 )
				
				oPrint:Say( nLin +008,010, "Nº DE PARCELAS:"			                                  , oFont06n:oFont )
				oPrint:Say( nLin +008,185,"DATA PRIMEIRO PAGTO:"	                                      , oFont06n:oFont )
				//oPrint:Say( nLin +008,354,"INICIO COMERCIAL:"	                                          , oFont06n:oFont )
				
				oPrint:Say( nLin +008,095,    cValToChar( CN9->CN9_QTDEPA )                             , oFont06:oFont )
				//oPrint:Say( nLin +008,095,      ""                                                        , oFont06:oFont )
			    oPrint:Say( nLin +008,274,      DTOC(CNF->CNF_DTVENC)                                     , oFont06:oFont ) 
				
				oPrint:Say( nLin+008, 482,"DATA:         /          /"                                     , oFont08:oFont )
				
				nLin+=10
				oPrint:Box( nLin, 090, nLin+10, 142 )     //VIGÊNCIA CONTRATUAL:
				oPrint:Box( nLin, 350, nLin+10, 425 )
				oPrint:Box(nLin, 425, nLin+10, 480 )
				
				oPrint:Say( nLin +008,010, "VIGÊNCIA CONTRATUAL:"			                              , oFont06n:oFont )
				oPrint:Say( nLin +008,120, "INICIO:"			                                          , oFont06n:oFont )
				oPrint:Say( nLin +008,380, "FIM:"			                                              , oFont06n:oFont )
				
				//,dInicio,dFim
				oPrint:Say( nLin +008,144,dInicio                                                          , oFont06:oFont )
				oPrint:Say( nLin +008,427,dFim                                                             , oFont06:oFont )
				
				nLin+=10
				oPrint:Box(nLin, 090, nLin+10, 172 ) //FORMA DE COBRANÇA::
				oPrint:Box(nLin, 172, nLin+10, 350 )
				oPrint:Box(nLin, 350, nLin+10, 480 )
				
				oPrint:Say( nLin +008,010, "FORMA DE COBRANÇA:"			                                 , oFont06n:oFont )
				If !empty(CN9->CN9_DIAVEN)
					oPrint:Say( nLin +008,185, "DIA DE VENCIMENTO:"			                             , oFont06n:oFont )
					oPrint:Say( nLin +008,354, CN9->CN9_DIAVEN                                            , oFont06:oFont )
				EndIf
				oPrint:Say( nLin +008,482,"CONTRATO FINANCEIRO"                                          , oFont08n:oFont )
				
				
				nLin+=10
				oPrint:Box(nLin, 090, nLin+10, 172 ) //DIA DE RELATÓRIO:
				oPrint:Box(nLin, 172, nLin+10, 350 )
				oPrint:Box(nLin, 350, nLin+10, 480 )
				oPrint:Box( nLin, 480,nLin+10, 580 )
				
				If !empty(CN9->CN9_DIAREL)
					oPrint:Say( nLin +008,010, "DIA DE RELATÓRIO:"			                            , oFont06n:oFont )
					oPrint:Say( nLin +008,095,CN9->CN9_DIAREL                                            , oFont06:oFont )
				EndIf
				If !empty(CN9->CN9_SELOBR)
					oPrint:Say( nLin +008,185, "OBRIGAÇÃO DE SELO HOLOGRÁFICO:"			                 , oFont06n:oFont )
					oPrint:Say( nLin +008,354,IIF(CN9->CN9_SELOBR=="1","SIM","NÃO")                       , oFont06:oFont )
					
					oPrint:Say( nLin +008,482,"DEPTO DE COBRANÇA"                                         , oFont06:oFont )
				EndIf
				nLin+=10
				
				oPrint:Box( nLin, 090, nLin+35, 480 )   //OBS ESPECÍFICAS:
				oPrint:Box( nLin, 480,  nLin+35, 580 )
				oPrint:Say( nLin +008,010, "OBS ESPECÍFICAS:"			                                 , oFont06n:oFont )
				
				oPrint:Say( nLin + 007, 482," DATA:         /          /  "                               , oFont08:oFont )
				oPrint:Say( nLin + 030, 482,  "RUBRICA:"                                                  , oFont08:oFont )
				
				
				cObser:=alltrim(CN9->CN9_OBSESP)
				nLinhas := MlCount( cObser,140)
				
				For nI := 1 To nLinhas
					
					oPrint:Say( nLin +008,095, MemoLine(cObser , 140, nI ) 			                      , oFont08:oFont )
					
					nLin+=10
					
				Next nI
				
				nLin+=35
				
		EndIf
	EndIf
EndIf
RestArea(aAreaAnt)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CNR010Med| Autor ³ Marcos V. Ferreira	| Data ³03/03/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Medicoes		            		                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Planilha                                 ³±±
±±³          ³ ExpC2 = Codigo do Contrato                                 ³±±
±±³          ³ ExpC3 = Codigo da Revisao                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTR010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CNR010Med(cPlanilha,cContrato,cRevisao,lImpMed,cFilCtr)
Local aAreaAnt	:= GetArea()
Local cAliasMed := CriaTrab(Nil, .F.)
Local cSeek		:= ""
Local aStrucCND := {}
Local aStrucCNE := CNE->(dbStruct())
Local cQuery	:= ""
Local cMedicao	:= ""
Local nX		:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa Fontes											           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oFont06	:= TFontEx():New(oPrint,"Arial",07,07,,.T.,,,,.T.,.F.)
Local oFont06n	:= TFontEx():New(oPrint,"Arial",07,07,,.F.,,,,.F.,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera Picture dos Campos									        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cPtVLMEAC := PesqPict("CND","CND_VLMEAC")
Local cPtVLSALD := PesqPict("CND","CND_VLSALD")
Local cPtVLTOT1 := PesqPict("CND","CND_VLTOT")
Local cPtQTDSOL := PesqPict("CNE","CNE_QTDSOL")
Local cPtQTAMED := PesqPict("CNE","CNE_QTAMED")
Local cPtQUANT  := PesqPict("CNE","CNE_QUANT")
Local cPtPERC   := PesqPict("CNE","CNE_PERC")
Local cPtVLUNIT := PesqPict("CNE","CNE_VLUNIT")
Local cPtVLTOT2 := PesqPict("CNE","CNE_VLTOT")

Local cProduto1  := ""
Local cProduto2  := ""
Local nCNETamPrd := TamSX3("CNE_PRODUT")[1]
Local nTipo      := 2

Default cContrato := ""
Default cRevisao  := ""
Default cPlanilha := ""
Default lImpMed	  := .T.

If !Empty(cContrato)
	
	If lImpMed
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Query da Planilha  									           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aStrucCND := CND->(dbStruct())
		cQuery := "SELECT CND_NUMMED, CND_NUMERO, CND_CONTRA, CND_FORNEC, CND_LJFORN,  CND_COMPET, CND_DTVENC, CND_VLMEAC, CND_VLSALD, CND_VLTOT,"
		cQuery += "CNE_ITEM, CNE_PRODUT, CNE_QTDSOL, CNE_QTAMED, CNE_QUANT, CNE_PERC, CNE_VLUNIT, CNE_VLTOT "
		cQuery += "FROM " + RetSqlName("CND") + " CND "
		cQuery += "LEFT JOIN " + RetSqlName("CNE") + " CNE ON CND_NUMERO = CNE_NUMERO AND "
		cQuery += "CND_CONTRA = CNE_CONTRA AND CND_REVISA = CNE_REVISA AND CND_NUMMED = CNE_NUMMED "
		cQuery += "WHERE "
		If CND->(FieldPos("CND_FILCTR")) > 0
			cQuery += "CND_FILCTR = '"		+	cFilCtr			+ "' AND "
		Else
			cQuery += "CND_FILIAL = '"		+	xFilial("CND")	+ "' AND "
		EndIf
		cQuery += "CNE_FILIAL = '"		+	xFilial("CNE")	+ "' AND "
		If !Empty(cPlanilha)
			cQuery += "CND_NUMERO = '"		+	cPlanilha		+ "' AND "
		EndIf
		cQuery += "CND_CONTRA = '"		+	cContrato		+ "' AND "
		cQuery += "CND_REVISA = '"		+	cRevisao		+ "' AND "
		cQuery += "CND.D_E_L_E_T_ = '' AND "
		cQuery += "CNE.D_E_L_E_T_ = '' "
		
		cQuery := ChangeQuery(cQuery)
		MsAguarde({|| dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasMed,.F.,.T.)},OemToAnsi(STR0022)) //Processando
		
		For nX := 1 to Len(aStrucCND)
			If aStrucCND[nX,2] != 'C' .And. FieldPos(aStrucCND[nx,1]) > 0
				TCSetField(cAliasMed,aStrucCND[nX,1], aStrucCND[nX,2],aStrucCND[nX,3],aStrucCND[nX,4])
			EndIf
		Next nX
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza estrutura dos itens da medicao  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 to Len(aStrucCNE)
			If aStrucCNE[nX,2] != 'C' .And.  FieldPos( aStrucCNE[nx,1] ) > 0
				TCSetField(cAliasMed,aStrucCNE[nX,1], aStrucCNE[nX,2],aStrucCNE[nX,3],aStrucCNE[nX,4])
			EndIf
		Next nX
		
		dbSelectArea(cAliasMed)
		
		Do While (cAliasMed)->(!Eof())
			
			If Empty(cMedicao)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Informacoes sobre a Medicao						   	     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nCNETamPrd> 15 .And. !Empty(SubStr((cAliasMed)->CNE_PRODUT,16,nCNETamPrd))
					nLin += 20 //-- Salta Linha
				Else
					nLin += 25 //-- Salta Linha
				EndIf
				CNRBox(290,0480,Upper(OemToAnsi(STR0039)),,.T.,1) //-- Cabecalho MEDICOES
				nLin += 10
				//-- Numero da Medicao
				CNRBox(0010,0120,RetTitle("CND_NUMMED"),(cAliasMed)->CND_NUMMED,.F.)
				//-- Numero da Planilhao
				CNRBox(0120,0260,RetTitle("CND_NUMERO"),(cAliasMed)->CND_NUMERO,.F.)
				//-- Numero do Contrato
				CNRBox(0260,0400,RetTitle("CND_CONTRA"),(cAliasMed)->CND_CONTRA,.F.)
				//-- Competencia
				CNRBox(0400,0480,RetTitle("CND_COMPET"),(cAliasMed)->CND_COMPET,.T.)
				
				nLin += 14 //-- Salta Linha
				
				If !Empty((cAliasMed)->CND_FORNEC)
					//-- Fornecedor                                                                    '
					CNRBox(0010,0400,RetTitle("CND_FORNEC"),(cAliasMed)->CND_FORNEC + " - " + Posicione("SA2",1,xFilial("SA2")+CND_FORNEC+CND_LJFORN,"A2_NOME"),.F.)
					//-- Loja Fornecedor
					CNRBox(0400,0480,RetTitle("CND_LJFORN"),(cAliasMed)->CND_LJFORN,.T.)
					
					nLin += 14
				EndIf
				//-- Data de Vencimento
				CNRBox(0010,0095,RetTitle("CND_DTVENC"),DTOC((cAliasMed)->CND_DTVENC),.F.)
				//-- Medicoes Acumuladas
				CNRBox(0095,0200,RetTitle("CND_VLMEAC"),TransForm((cAliasMed)->(C010xMoeda(.F.,cContrato,cRevisao,"CND_VLMEAC")),cPtVLMEAC),.F.)
				//-- Saldo da Medicao
				CNRBox(0200,0340,RetTitle("CND_VLSALD"),TransForm((cAliasMed)->(C010xMoeda(.F.,cContrato,cRevisao,"CND_VLSALD")),cPtVLSALD),.F.)
				//-- Valor Total
				CNRBox(0340,0480,RetTitle("CND_VLTOT"),TransForm((cAliasMed)->(C010xMoeda(.F.,cContrato,cRevisao,"CND_VLTOT")),cPtVLTOT1),.T.)
				
				nLin += 14
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Cabecalho dos Itens da Medicao						        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				CNRBox(0010,0070,RetTitle("CNE_ITEM"),,.F.,2,oFont06:oFont)
				CNRBox(0070,0105,RetTitle("CNE_PRODUT"),,.F.,2,oFont06:oFont)
				CNRBox(0105,0170,RetTitle("CNE_QTDSOL"),,.F.,2,oFont06:oFont)
				CNRBox(0170,0225,RetTitle("CNE_QTAMED"),,.F.,2,oFont06:oFont)
				CNRBox(0225,0285,RetTitle("CNE_QUANT"),,.F.,2,oFont06:oFont)
				CNRBox(0285,0370,RetTitle("CNE_PERC"),,.F.,2,oFont06:oFont)
				CNRBox(0370,0430,RetTitle("CNE_VLUNIT"),,.F.,2,oFont06:oFont)
				CNRBox(0430,0480,RetTitle("CNE_VLTOT"),,.T.,2,oFont06:oFont)
				
				cMedicao := (cAliasMed)->CND_NUMMED
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica o conteudo do campo Produto³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cProduto1 := (cAliasMed)->CNE_PRODUT
				
				If nCNETamPrd> 15 .And. !Empty(SubStr((cAliasMed)->CNE_PRODUT,16,nCNETamPrd))
					nTipo := 5
					cProduto1 := SubStr((cAliasMed)->CNE_PRODUT,1,15)
					cProduto2 := SubStr((cAliasMed)->CNE_PRODUT,16,nCNETamPrd)
				Else
					nTipo    := 2
					cProduto2:=""
				EndIf
				
				nLin += 10
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Impressao dos Itens da Medicao						        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//-- Item da Medicao
				CNRBox(0010,0070,(cAliasMed)->CNE_ITEM,,.F.,nTipo,oFont06:oFont)
				//-- Produto
				CNRBox(0070,0105,cProduto1,cProduto2,.F.,nTipo,oFont06:oFont)
				//-- Quantidade Solicitada
				CNRBox(0105,0170,TransForm((cAliasMed)->CNE_QTDSOL,cPtQTDSOL),,.F.,nTipo,oFont06:oFont,.T.)
				//-- Quantidade Medida
				CNRBox(0170,0225,TransForm((cAliasMed)->CNE_QTAMED,cPtQTAMED),,.F.,nTipo,oFont06:oFont,.T.)
				//-- Quantidade
				CNRBox(0225,0285,TransForm((cAliasMed)->CNE_QUANT,cPtQUANT),,.F.,nTipo,oFont06:oFont,.T.)
				//-- Percentual
				CNRBox(0285,0370,TransForm((cAliasMed)->CNE_PERC,cPtPERC),,.F.,nTipo,oFont06:oFont,.T.)
				//-- Valor Unitario
				CNRBox(0370,0430,TransForm((cAliasMed)->(C010xMoeda(.F.,cContrato,cRevisao,"CNE_VLUNIT")),cPtVLUNIT),,.F.,nTipo,oFont06:oFont,.T.)
				//-- Valor Total
				CNRBox(0430,0480,TransForm((cAliasMed)->(C010xMoeda(.F.,cContrato,cRevisao,"CNE_VLTOT")),cPtVLTOT2),,.T.,nTipo,oFont06:oFont,.T.)
				
				If nCNETamPrd> 15 .And. !Empty(cProduto2)
					nLin += 20 //-- Salta Linha
				EndIf
				
				(cAliasMed)->(dbSkip())
			EndIf
			
			If (cMedicao != (cAliasMed)->CND_NUMMED)
				CNTR030Mul (cMedicao,oFont06:oFont)
				CNTR030Desc(cMedicao,oFont06:oFont)
				CNR030Cauc (cMedicao, oFont06:oFont)
				dbselectarea("CND")
				cMedicao := ""
			Endif
			
		EndDo
		
		//-- Finaliza a query
		dbSelectArea(cAliasMed)
		(cAliasMed)->(dbCloseArea())
		
	EndIf
EndIf

RestArea(aAreaAnt)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CNRCabec ³ Autor ³ Marcos V. Ferreira    ³ Data ³03/03/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cabecalho padrao para relatorios graficos                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Posicao da coluna para impressao do cTexto         ³±±
±±³          ³ ExpC2 = Texto a ser impresso	                             ³±±
±±³          ³ ExpC3 = Titulo do Relatorio                                ³±±
±±³          ³ ExpO4 = Fonte para impressao do cTexto                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTR010 / CNR020	                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CNRCabec(nCol,cTexto,cTitulo,oFontT,lPaisagem)
Local cFileLogo	:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa Fontes											           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oFont09	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Local oFont09n	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)

Default nCol	:= 0
Default cTexto	:= ""
Default cTitulo := ""
Default oFontT  := oFont09
Default lPaisagem := .F.

If (If(lPaisagem,(nLin >= 2350),(nLin >= 2900)))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cabecalho da Pagina					      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPagina++ //-- Variavel Private
	nLin := 200 //-- Variavel private
	oPrint:EndPage() 	//-- Encerra a pagina anterior
	oPrint:StartPage()	//-- Inicia uma nova pagina
	oPrint:Line(50,50,50,If(lPaisagem,3181,2350))
	oPrint:Line(51,51,51,If(lPaisagem,3181,2351))
	oPrint:Line(200,50,200,If(lPaisagem,3181,2351))
	oPrint:Line(201,51,201,If(lPaisagem,3181,2351))
	oPrint:Say(105,1060,Upper(OemToAnsi(cTitulo)),oFont09n) 				//Texto do Cabecalho
	oPrint:Say(065,If(lPaisagem,2830,2000),OemToAnsi(STR0031)	+ StrZero(nPagina,3),oFont09) 	//"Folha....: "
	oPrint:Say(105,If(lPaisagem,2830,2000),OemToAnsi(STR0032)	+ Dtoc(dDataBase),oFont09) 		//"DT.Ref..: "
	oPrint:Say(160,If(lPaisagem,2830,2000),OemToAnsi(STR0033)	+ Dtoc(Date()),oFont09) 		//"Emissao.: "
	cFileLogo += "LGRL"+SM0->M0_CODIGO+".BMP"
	oPrint:SayBitmap(70,60,cFileLogo,474,117) //-- Logotipo
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salta para a proxima linha			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLin += 50
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do texto					      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cTexto)
	oPrint:Say(nLin,nCol,cTexto,oFontT)
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CNRBox() ³ Autor ³ Marcos V. Ferreira    ³ Data ³03/03/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria Box para Textos			                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Posicao inicial da coluna para criacao do Box      ³±±
±±³          ³ ExpN2 = Posicao final da coluna para criacao do Box        ³±±
±±³          ³ ExpC3 = Texto da 1a. linha do Box                          ³±±
±±³          ³ ExpC4 = Texto da 2a. linha do Box                          ³±±
±±³          ³ ExpL5 = Quebra para proxima linha apos a impressao do Box  ³±±
±±³          ³         (.T. Com  Quebra / .F. Sem Quebra)                 ³±±
±±³          ³ ExpN6 = Tipo do Box : 									           ³±±
±±³          ³                      1 - Linha de Cabecalho                ³±±
±±³          ³                      2 - Linha Unica Simples               ³±±
±±³          ³                      3 - Linha de Detalhe                  ³±±
±±³          ³                      4 - Somente Texto                     ³±±
±±³          ³ ExpO7 = Fonte para impressao do Texto                      ³±±
±±³          ³ ExpL8 = Se .T. realiza o alinhamento do cTexto1 a Direita. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTR010  / CNTR020                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CNRBox(nCol1,nCol2,cTexto1,cTexto2,lQuebra,nTipo,oFontB,lAlinDir)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa Fontes											           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local oFont06n  :=  TFontEx():New(oPrint,"Arial",07,07,.T.,.T.,.F.)
Local oFont06   :=  TFontEx():New(oPrint,"Arial",07,07,.F.,.F.,.F.)
Default nCol1	:= 0
Default nCol2	:= 0
Default cTexto1 := ""
Default cTexto2 := ""
Default lQuebra := .T.
Default nTipo   := 3
Default oFontB  := oFont06
Default lAlinDir:= .F.

if nLin >=670
	nLin:=15
	oPrint:EndPage()
	oPrint:StartPage()
	cabec(oPrint)
	nLin:=83
EndIf

If nTipo == 1  //-- Linha de Cabecalho
	oPrint:Box(nLin,010,nLin+10,480)
	oPrint:Say(nLin+08,nCol1,cTexto1,oFont06n:oFont)
	//290, 010
ElseIf nTipo == 2 //-- Linha Unica Simples
	oPrint:Box(nLin,nCol1,nLin+10,nCol2)
	If lAlinDir //-- Alinhamento a Direita
		oPrint:Say(nLin+7,nCol1+8,AllTrim(cTexto1),oFontB)
	Else
		oPrint:Say(nLin+7,nCol1+8,cTexto1,oFontB)
	EndIf
ElseIf nTipo == 3 //-- Linha de Detalhe
	oPrint:Box(nLin,nCol1,nLin+15,nCol2)
	oPrint:Say(nLin+07,nCol1+03,cTexto1,oFont06n:oFont)
	oPrint:Say(nLin+12,nCol1+40,cTexto2,oFont06:oFont)
	
ElseIf nTipo == 4 //-- Somente Texto
	oPrint:Say(nLin+7,nCol1,cTexto1,oFontB:oFont)
ElseIf nTipo == 5 //-- Linha com dois textos
	If lAlinDir //-- Alinhamento a Direita
		oPrint:Say(nLin+7,nCol1+8,AllTrim(cTexto1),oFontB)
		oPrint:Say(nLin+7,nCol1+8,AllTrim(cTexto2),oFontB)
	Else
		oPrint:Say(nLin+7,nCol1+8,cTexto1,oFontB)
		oPrint:Say(nLin+7,nCol1+8,cTexto2,oFontB)
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ TamTexto | Autor ³ Marcos V. Ferreira    ³ Data ³08/03/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Recupera o tamanho de uma string em pixels                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTR010 / CNTR020                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TamTexto(cTexto)
Local nSize := 0
Local nx
Local aSize := {{17.241,2.692,15.241,13.692}}
For nx := 1 to Len(cTexto)
	If Substr(cTexto,nx,1)=="." .Or. Substr(cTexto,nx,1)=="," .or.  Substr(UPPER(cTexto),nx,1)=="I"
		nSize += aSize[1,2]
	ElseIf Substr(cTexto,nx,1)$"abcdefghijklmnopqrstuvxyzw"
		nSize += aSize[1,4]
	ElseIf Substr(UPPER(cTexto),nx,1)$"ABCDEFGHIJKLMNOPQRSTUVXWYZ""
		nSize += aSize[1,3]
	Else
		nSize += aSize[1,1]
	EndIf
Next
Return nSize

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CNR010Sit³ Autor ³ Marcos V. Ferreira    ³ Data ³03/03/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o tipo da situacao do Contrato                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTR010  		                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CNR010Sit(cTipo)
Local cRet := ""

Default cTipo := ""

cTipo := AllTrim(cTipo)

Do Case
	Case cTipo == "01"
		cRet := OemToAnsi(STR0007) //-- 1-Cancelado
	Case cTipo == "02"
		cRet := OemToAnsi(STR0008) //-- 2-Elaboracao
	Case cTipo == "03"
		cRet := OemToAnsi(STR0009) //-- 3-Emitido
	Case cTipo == "04"
		cRet := OemToAnsi(STR0010) //-- 4-Em Aprovacao
	Case cTipo == "05"
		cRet := OemToAnsi(STR0011) //-- 5-Vigente
	Case cTipo == "06"
		cRet := OemToAnsi(STR0012) //-- 6-Cancelado
	Case cTipo == "07"
		cRet := OemToAnsi(STR0013) //-- 7-Solic. Finalizacao
	Case cTipo == "08"
		cRet := OemToAnsi(STR0014) //-- 8-Finalizado
	Case cTipo == "09"
		cRet := OemToAnsi(STR0015) //-- 9-Revisao
	Case cTipo == "10"
		cRet := OemToAnsi(STR0016) //-- 10-Revisado
EndCase

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ AjustaSX1³ Autor ³ Marcos V. Ferreira    ³ Data ³03/03/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajusta as perguntas do SX1                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNTR010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1(cPerg)
Local aAreaAnt := GetArea()
Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpSpa := {}

If cPerg == "SCIR030"
	If !SX1->( dbSeek( cPerg ) )
		//---------------------------------------MV_PAR01--------------------------------------------------
		aHelpPor := {"Numero inicial do Contrato"}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSX1(cPerg,"01","Contrato de:","De contrato?","From contract?","mv_ch1","C",15,0,0,"G","","CN9","","S","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		
		//---------------------------------------MV_PAR02--------------------------------------------------
		aHelpPor := {"Numero final do Contrato"}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSX1(cPerg,"02","Contrato ate:","A contrato?","To contract?","mv_ch2","C",15,0,0,"G","","CN9","","S","mv_par02","","","","ZZZZZZZZZZZZZZZ","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		
		//---------------------------------------MV_PAR03--------------------------------------------------
		aHelpPor := {"Numero inicial da Revisao"}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSX1(cPerg,"03","Revisao de:","De Revision:?","From Review?","mv_ch3","C",3,0,0,"G","","","","S","mv_par03","","","","001","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		
		//---------------------------------------MV_PAR04--------------------------------------------------
		aHelpPor := {"Numero final da Revisao"}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSX1(cPerg,"04","Revisao ate:","A Revision:?","Review To?","mv_ch4","C",3,0,0,"G","","","","S","mv_par04","","","","ZZZ","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		
		//---------------------------------------MV_PAR05--------------------------------------------------
		aHelpPor := {"Data de inicio da Vigencia"}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSX1(cPerg,"05","Vigencia de:","De Vigencia:?","From Validity?","mv_ch5","D",08,0,0,"G","","","","S","mv_par05","","","","01/01/06","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		
		//---------------------------------------MV_PAR06--------------------------------------------------
		aHelpPor := {"Data de termino da Vigencia"}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSX1(cPerg,"06","Vigencia ate:","A Vigencia:?","To Validity?","mv_ch6","D",08,0,0,"G","","","","S","mv_par06","","","","31/12/49","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		
		//---------------------------------------MV_PAR07--------------------------------------------------
		aHelpPor := {"Codigo inicial da Situacao"}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSX1(cPerg,"07","Situacao de:","De Situacion:?","From status?","mv_ch7","C",2,0,0,"G","","","","S","mv_par07","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		
		//---------------------------------------MV_PAR08--------------------------------------------------
		aHelpPor := {"Codigo final da Situacao"}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSX1(cPerg,"08","Situacao ate:","A Situacion:?","To status?","mv_ch8","C",2,0,0,"G","","","","S","mv_par08","","","","99","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		
		//---------------------------------------MV_PAR09--------------------------------------------------
		aHelpPor := {"Codigo inicial do Fornecedor"}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSX1(cPerg,"09","Fornecedor de:","De Proveedor:?","From Supplier:?","mv_ch9","C",6,0,0,"G","","SA2","","S","mv_par09","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		
		//---------------------------------------MV_PAR10--------------------------------------------------
		aHelpPor := {"Codigo final do Fornecedor"}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSX1(cPerg,"10","Fornecedor ate:","A Proveedor:?","To Supplier:?","mv_cha","C",6,0,0,"G","","SA2","","S","mv_par10","","","","ZZZZZZ","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		
		//---------------------------------------MV_PAR11--------------------------------------------------
		aHelpPor := {"Codigo do Tipo de Contrato"}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSX1(cPerg,"11","Tipo de Contrato ?","Tipo de Contrato:?","Type of Contract?","mv_chb","C",3,0,0,"G","","CN1","","S","mv_par11","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		
		//---------------------------------------MV_PAR12--------------------------------------------------
		aHelpPor := {"Utilizada para exibir os Caucoes","do Contrato (Sim/Nao)"}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSx1(cPerg,"12","Exibir Caucoes ?","Mostrar garantias?","Display pledges","mv_chc","N",1,0,1,"C","","","","","mv_par12","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		
		//---------------------------------------MV_PAR13--------------------------------------------------
		aHelpPor := {"Utilizada para exibir os Fornecedores","do Contrato (Sim/Nao)"}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSx1(cPerg,"13","Exibir Fornecedores ?","Mostrar Proveedores?","Display Supplier?","mv_chd","N",1,0,1,"C","","","","","mv_par13","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		
		//---------------------------------------MV_PAR14--------------------------------------------------
		aHelpPor := {"Utilizada para exibir as Planilhas ","do Contrato (Sim/Nao)"}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSx1(cPerg,"14","Exibir Planilha ?","Mostrar Planilla?","Display worksheet?","mv_che","N",1,0,1,"C","","","","","mv_par14","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		
		//---------------------------------------MV_PAR15--------------------------------------------------
		aHelpPor := {"Utilizada para exibir os Cronogramas","do Contrato (Sim/Nao)"}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSx1(cPerg,"15","Exibir Cronograma ?","Mostrar Cronograma?","Display schedule?","mv_chf","N",1,0,1,"C","","","","","mv_par15","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		
		//---------------------------------------MV_PAR16--------------------------------------------------
		aHelpPor := {"Utilizada para exibir as Multas ","do Contrato (Sim/Nao)"}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSx1(cPerg,"16","Exibir Multas/Bonificacoes?","Mostrar Multas?","Display fines?","mv_chg","N",1,0,1,"C","","","","","mv_par16","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		
		//---------------------------------------MV_PAR17--------------------------------------------------
		aHelpPor := {"Utilizada para exibir as Medicoes ","do Contrato (Sim/Nao)"}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSx1(cPerg,"17","Exibir Medicoes ?","Mostrar Mediciones?","Display measurements?","mv_chh","N",1,0,1,"C","","","","","mv_par17","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		
		//---------------------------------------MV_PAR18--------------------------------------------------
		aHelpPor := {"Permite exibir os campos Objeto,","Clausulas e Justificativas do Contrato","(Sim/Nao)"}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSx1(cPerg,"18","Exibir Textos do Contrato ?","Mostrar Textos del Contrato?","Display contract texts?","mv_chi","N",1,0,1,"C","","","","","mv_par18","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		
		//---------------------------------------MV_PAR19--------------------------------------------------
		aHelpPor := {"Permite exibir os Valores ","de Multas/Bonificacoes,Caucoes Retidas","e Descontos do Contrato (Sim/Nao)"}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSx1(cPerg,"19","Exibir Detalhes da Medicao ?","Mostrar detalles de Medicion?","Display measurement details?","mv_chj","N",1,0,1,"C","","","","","mv_par19","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	EndIf
	If !SX1->( dbSeek( PadR(cPerg,10) + "20" ) )
		//---------------------------------------MV_PAR20--------------------------------------------------
		aHelpPor := {"Permite exibir os Cronograma","Contabil(Sim/Nao)",""}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSx1(cPerg,"20","Exibir Cronograma Contabil ?","Mostrar Cronograma Contable?","Display accounting schedule?","mv_chk","N",1,0,1,"C","","","","","mv_par20","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	EndIf
	
	If !SX1->( dbSeek( PadR(cPerg,10) + "21" ) )
		//---------------------------------------MV_PAR21--------------------------------------------------
		aHelpPor := {"Codigo inicial do Cliente"}
		aHelpEng := {"Codigo inicio del Cliente"}
		aHelpSpa := {"Client initial Code"}
		
		//PutSX1(cPerg,"21","Cliente de:","De Cliente:?","From Client?","mv_chl","C",TamSx3('A1_COD')[1],0,0,"G","","SA1GCT","","S","mv_par21","","","","","","","","","","","","","","","","")
		PutHelp("P."+cPerg+"21.",aHelpPor,aHelpEng, aHelpSpa,.T.)
	EndIf
	
	If !SX1->( dbSeek( PadR(cPerg,10) + "22" ) )
		//---------------------------------------MV_PAR22--------------------------------------------------
		aHelpPor := {"Codigo final do Cliente"}
		aHelpEng := {"Codigo final del Cliente"}
		aHelpSpa := {"Client final Code"}
		
		//PutSX1(cPerg,"22","Cliente ate:","A Cliente:?","To Client?","mv_chm","C",TamSx3('A1_COD')[1],0,0,"G","","SA1GCT","","S","mv_par22","","","","ZZZZZZ","","","","","","","","","","","","")
		PutHelp("P."+cPerg+"22.",aHelpPor,aHelpEng, aHelpSpa,.T.)
	EndIf
	
	If !SX1->( dbSeek( PadR(cPerg,10 /*TamSx3("X1_GRUPO")[1]*/ ) + "23" ) )
		//---------------------------------------MV_PAR23--------------------------------------------------
		aHelpPor := {"Define se a impressão dos valores","no relatório será realizada na","moeda do contrato ou em outra moeda."}
		aHelpEng := {"Define if the values will be printed","using contract currency or other currency."}
		aHelpSpa := {"Define si la impresión de los valores","en el informe será realizada en la ","moneda del contrato o en otra moneda."}
		
		//PutSX1(cPerg,"23","Imprimir valores na moeda","Imprimir valores en moneda","Print values in currency","mv_chn","N",1,0,0,"C","","","","S","mv_par23","Do contrato","Del contrato","Of Contract","","Informada","Informada","Informed","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	EndIf
	
	If !SX1->( dbSeek( PadR(cPerg,10 /*TamSx3("X1_GRUPO")[1]*/ ) + "24" ) )
		//---------------------------------------MV_PAR24--------------------------------------------------
		aHelpPor := {"Indica a moeda para impressão","dos valores. A pergunta anterior",'deve estar como "Informada".'}
		aHelpEng := {"Indica la moneda para impresión","de los valores. La pregunta anterior",'debe estar como "Informada".'}
		aHelpSpa := {"Indicates the values currency ","printing. The previous question must",'be set as "Informed".'}
		
		//PutSX1(cPerg,"24","Moeda","Moneda","Currency","mv_cho","N",1,0,0,"C","","","","S","mv_par24","Moeda 1","Moneda 1","Currency 1","","Moeda 2","Moneda 2","Currency 2","Moeda 3","Moneda 3","Currency 3","Moeda 4","Moneda 4","Currency 4","Moeda 5","Moneda 5","Currency 5",aHelpPor,aHelpEng,aHelpSpa)
	EndIf
	
	If !SX1->( dbSeek( PadR(cPerg,10 /*TamSx3("X1_GRUPO")[1]*/ ) + "25" ) )
		//---------------------------------------MV_PAR25--------------------------------------------------
		aHelpPor := {"Data de referência para conversão","dos valores entre moedas."}
		aHelpEng := {"Fecha de referencia para conversión","de los valores entre monedas."}
		aHelpSpa := {"Reference date for values","convertion between currency."}
		
		//PutSX1(cPerg,"25","Data de referencia","Fecha de referencia","Reference date","mv_chp","D",8,0,0,"G","","","","S","mv_par25","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	EndIf
	
	If !SX1->( dbSeek( PadR(cPerg,10 /*TamSx3("X1_GRUPO")[1]*/ ) + "26" ) )
		//---------------------------------------MV_PAR26--------------------------------------------------
		aHelpPor := {"Imprime por contratos de Compras ou ","Vendas."}
		aHelpEng := {"Imprime por contractos de Compras","o Ventas."}
		aHelpSpa := {"Print by Purchase Contract or ","Sales."}
		
		//PutSX1(cPerg,"26","Por contrato de?","Por Contracto","By Contract","mv_chq","N",10,0,0,"C","","","","S","mv_par26","Compras","Compras","Purchase","","Vendas","Ventas","Sales","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	EndIf
	
EndIf

RestArea(aAreaAnt)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³C010xMoedaºAutor  ³Microsiga           º Data ³  11/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Realiza a conversao entre moedas de um determinado valor.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ lTReport: indica se a impressao e em TReport.			  º±±
±±º			 ³ cContra: numero do contrato que esta sendo impresso.		  º±±
±±º			 ³ cRev: revisao do contrato que esta sendo impresso.		  º±±
±±º			 ³ cCampo: nome do campo a ser convertido.					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno	 ³ nRet: valor apos conversao								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNTR010													  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C010xMoeda(lTReport,cContra,cRev,cCampo)
Local dDataRef  := 1 //If(lTReport,mv_par13,mv_par25)
Local nMoedaOri	:= 0
Local nMoedaDes := 0
Local nRet 		:= 0

If "CNTR020" $ FunName()
	//-- Impressao da planilha e itens da planilha no CNTR020
	nRet := C020xMoeda(lTReport,cContra,cRev,cCampo)
Else
	If Empty(dDataRef)
		dDataRef := dDataBase
	EndIf
	nMoedaOri := If(Substr(cCampo,1,3) == "CN8",CN8_MOEDA,Posicione("CN9",1,xFilial("CN9")+cContra+cRev,"CN9_MOEDA"))
	nMoedaDes := nMoedaOri
	nRet	  := &(cCampo)
	
	If cTipContra == 2 // Codigo do Tipo de Contrato 1=Compra 2=Venda
			nMoedaDes := 1
	EndIf
	
	nRet := Round(xMoeda(nRet,nMoedaOri,nMoedaDes,dDataRef,6),TamSX3(cCampo)[2])
EndIf

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R10ImpParcºAutor  ³Giovanni Melo       º Data ³  27/01/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Imprime os parcelamentos                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ Nenhum                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno	 ³ Nenhum                    								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CNTR010													  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function R10ImpParc()

	Local oFont06n := TFontEx():New(oPrint,"Arial",07,07,.T.,.T.,.F.)
	Local oFont06  := TFontEx():New(oPrint,"Arial",07,07,.F.,.F.,.F.)
	
	oPrint:Say( nLin + 10, 010, "PARCELAMENTO:", oFont06n:oFont )

	CNRBox(110,202,RetTitle("CN9_VENC1"),dtoc(CN9->CN9_VENC1),.F.)
	CNRBox(202,295,RetTitle("CN9_PARC1"),Transform(CN9->CN9_PARC1, PesqPict("CN9","CN9_PARC1")),.F.)
	CNRBox(295,387,RetTitle("CN9_VENC2"),dtoc(CN9->CN9_VENC2),.F.)
	CNRBox(387,480,RetTitle("CN9_PARC2"),Transform(CN9->CN9_PARC2, PesqPict("CN9","CN9_PARC2")),.F.)
	nLin += 15
	CNRBox(110,202,RetTitle("CN9_VENC3"),dtoc(CN9->CN9_VENC3),.F.)
	CNRBox(202,295,RetTitle("CN9_PARC3"),Transform(CN9->CN9_PARC3, PesqPict("CN9","CN9_PARC3")),.F.)
	CNRBox(295,387,RetTitle("CN9_VENC4"),dtoc(CN9->CN9_VENC4),.F.)
	CNRBox(387,480,RetTitle("CN9_PARC4"),Transform(CN9->CN9_PARC3, PesqPict("CN9","CN9_PARC4")),.F.)
	nLin += 15
	CNRBox(110,202,RetTitle("CN9_VENC5"),dtoc(CN9->CN9_VENC5),.F.)
	CNRBox(202,295,RetTitle("CN9_PARC5"),Transform(CN9->CN9_PARC5, PesqPict("CN9","CN9_PARC5")),.F.)
	CNRBox(295,387,RetTitle("CN9_VENC6"),dtoc(CN9->CN9_VENC6),.F.)
	CNRBox(387,480,RetTitle("CN9_PARC6"),Transform(CN9->CN9_PARC6, PesqPict("CN9","CN9_PARC6")),.F.)
	nLin += 15
	CNRBox(110,202,RetTitle("CN9_VENC7"),dtoc(CN9->CN9_VENC7),.F.)
	CNRBox(202,295,RetTitle("CN9_PARC7"),Transform(CN9->CN9_PARC7, PesqPict("CN9","CN9_PARC7")),.F.)
	CNRBox(295,387,RetTitle("CN9_VENC8"),dtoc(CN9->CN9_VENC8),.F.)
	CNRBox(387,480,RetTitle("CN9_PARC8"),Transform(CN9->CN9_PARC8, PesqPict("CN9","CN9_PARC8")),.F.)
	nLin += 15
	CNRBox(110,202,RetTitle("CN9_VENC9"),dtoc(CN9->CN9_VENC9),.F.)
	CNRBox(202,295,RetTitle("CN9_PARC9"),Transform(CN9->CN9_PARC9, PesqPict("CN9","CN9_PARC9")),.F.)
	CNRBox(295,387,RetTitle("CN9_VENC10"),dtoc(CN9->CN9_VENC10),.F.)
	CNRBox(387,480,RetTitle("CN9_PARC10"),Transform(CN9->CN9_PARC10, PesqPict("CN9","CN9_PARC10")),.F.)
	nLin += 15
	
Return 



