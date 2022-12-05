#include 'topconn.ch'
#INCLUDE "jpeg.ch" 

// #include "MATR968.CH"    

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: XAMATR968.PRW                                                       *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 17/08/2013                                                          *
// Objetivo..: Programa que gera o RPS da Nota Fiscal de Serviço Eletrônica        *
//**********************************************************************************

User Function AMATR968()

   // Define Variaveis
   Local wnrel
   Local tamanho	:= "G"
   Local titulo		:= "Impressão da Nota"                                     
   Local cDesc1		:= "Impressão da Nota de Serviços - RPS"
   Local cDesc2		:= " "
   Local cDesc3		:= " "
   Local cTitulo	:= ""
   Local cErro		:= ""
   Local cSolucao	:= ""                         

   Local lPrinter	:= .T.
   Local lOk		:= .F.
   Local aSays     	:= {}, aButtons := {}, nOpca := 0

   Private nomeprog := "MATR968"
   Private nLastKey := 0
   Private cPerg

   Private lMostra  := .T.

   Private oPrint

   U_AUTOM628("AMATR968")

   cString := "SF2"
   wnrel   := "MATR968"
   cPerg   := "MTR968"

   AjustaSX1()
   Pergunte(cPerg,.F.)

   AADD(aSays,"Impressão da Nota Fiscal de Serviços Eletrônica") //"Impressão do Recibo Provisório de Serviços - RPS"

   AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
   AADD(aButtons, { 1,.T.,{|| nOpca := 1, FechaBatch() }} )
   AADD(aButtons, { 2,.T.,{|| nOpca := 0, FechaBatch() }} )  

   FormBatch( Titulo, aSays, aButtons,, 160 )

   If nOpca == 0
      Return
   EndIf   

   // Configuracoes para impressao grafica
   oPrint := TMSPrinter():New("Impressão") //"Impressão RPS"
   oPrint:SetPortrait()					   // Modo retrato
   oPrint:SetPaperSize(9)				   // Papel A4

   If nLastKey = 27
      dbClearFilter()
	  Return
   Endif

   RptStatus({|lEnd| Mt968Print(@lEnd,wnRel,cString)},Titulo)

   // Visualiza impressão gráfica antes de imprimir
   If lMostra == .T.
      oPrint:Preview()  		
   Endif   

Return

// Função que chama o processo de elaboração do relatório a ser impressõ
Static Function Mt968Print(lEnd,wnRel,cString)

   Local aAreaRPS	:= {}
   Local aPrintServ	:= {}
   Local aPrintObs	:= {}
   Local aTMS		:= {}
   Local aItensSD2  := {}

   Local cServ		 := ""
   Local cDescrServ	 := ""
   Local cCNPJCli	 := ""                            
   Local cTime		 := "" 
   Local lNfeServ	 := AllTrim(SuperGetMv("MV_NFESERV",.F.,"1")) == "1"
   Local cLogo		 := ""
   Local cServPonto	 := ""               
   Local cObsPonto	 := ""
   Local cAliasSF3	 := "SF3"
   Local cCli		 := ""
   Local cIMCli		 := ""
   Local cEndCli	 := ""
   Local cBairrCli	 := ""
   Local cCepCli	 := ""
   Local cMunCli	 := ""
   Local cUFCli		 := ""
   Local cEmailCli	 := ""
   Local cCampos	 := ""     
   Local cDescrBar   := SuperGetMv("MV_DESCBAR",.F.,"")
   Local cCodServ    := ""
   Local cF3_NFISCAL := ""
   Local cF3_SERIE   := ""
   Local cF3_CLIEFOR := ""
   Local cF3_LOJA    := ""
   Local cF3_EMISSAO := ""
   Local cKey        := ""        
   Local cObsRio     := ""
   Local cLogAlter   := GetNewPar("MV_LOGRPS","") // caminho+nome do logotipo alternativo  
   Local cTotImp     := ""
   Local cFontImp    := ""

   Local lCampBar    := !Empty(cDescrBar) .And. SB1->(FieldPos(cDescrBar)) > 0
   Local lIssMat     := (cAliasSF3)->(FieldPos("F3_ISSMAT")) > 0
   Local lDescrNFE	 := ExistBlock("MTDESCRNFE")
   Local lObsNFE	 := ExistBlock("MTOBSNFE")
   Local lCliNFE	 := ExistBlock("MTCLINFE")           
   Local lPEImpRPS	 := ExistBlock("MTIMPRPS")           
   Local lDescrBar   := GetNewPar("MV_DESCSRV",.F.)
   Local lImpRPS	 := .T. 
   Local lcmpAbat	 := SD2->( FieldPos("D2_ABATISS")>0 .And. FieldPos("D2_ABATMAT")>0 )

   Local nValDed	 := 0
   Local nTOTAL      := 0 
   Local nDEDUCAO    := 0 
   Local nBASEISS    := 0 
   Local nALIQISS    := 0
   Local nVALISS     := 0 
   Local nDescIncond := 0
   Local nValLiq     := 0
   Local nVlContab   := 0
   Local nValDesc	 := 0  
   Local nValBruto	 := 0

   Local nAliqPis    := 0
   Local nAliqCof    := 0
   Local nAliqCSLL   := 0
   Local nAliqIR     := 0
   Local nAliqINSS   := 0
   Local nValPis     := 0
   Local nValCof     := 0
   Local nValCSLL    := 0
   Local nValIR      := 0
   Local nValINSS    := 0 
   Local cNatureza   := ""
   Local cRecIss     := "" 
   Local cRecCof     := ""
   Local cRecPis     := ""
   Local cRecIR      := ""    
   Local cRecCsl     := ""           
   Local cRecIns	 := ""

   Local nCopias	 := mv_par07
   Local nLinIni	 := 225  
   Local nColIni	 := 225
   Local nColFim	 := 2175
   Local nLinFim	 := 2975
   Local nX			 := 1
   Local nY			 := 1
   Local nLinha		 := 0
   Local _cObsAuto   := "" //Michel Aoki

   Local nValor_Deducao := 0
   Local nLaco          := 0

   Local oFont10 	 := TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)	//Normal s/negrito
   Local oFont10n	 := TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.)	//Negrito
   Local oFont12n	 := TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.)	//Negrito
   Local oFont09 	 := TFont():New("Courier New",9,9,,.F.,,,,.T.,.F.)	//Normal s/negrito
   Local oFont09n	 := TFont():New("Courier New",9,9,,.T.,,,,.T.,.F.)	//Negrito

   Local oFontA08	 := TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)	//Normal s/negrito
   Local oFontA08n   := TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)	//Negrito
   Local oFontA09	 := TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)	//Normal s/negrito
   Local oFontA09n   := TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)	//Negrito
   Local oFontA10	 := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)	//Normal s/negrito
   Local oFontA10n   := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)	//Negrito
   Local oFontA11	 := TFont():New("Arial",11,11,,.F.,,,,.T.,.F.)	//Normal s/negrito
   Local oFontA11n   := TFont():New("Arial",11,11,,.T.,,,,.T.,.F.)	//Negrito
   Local oFontA12	 := TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)	//Normal s/negrito
   Local oFontA12n   := TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)	//Negrito
   Local oFontA13	 := TFont():New("Arial",13,13,,.F.,,,,.T.,.F.)	//Normal s/negrito
   Local oFontA13n   := TFont():New("Arial",13,13,,.T.,,,,.T.,.F.)	//Negrito
   Local oFontA14	 := TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)	//Normal s/negrito
   Local oFontA14n   := TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)	//Negrito
   Local oFontA16	 := TFont():New("Arial",16,16,,.F.,,,,.T.,.F.)	//Normal s/negrito
   Local oFontA16n   := TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)	//Negrito
   Local oFontA18	 := TFont():New("Arial",18,18,,.F.,,,,.T.,.F.)	//Normal s/negrito
   Local oFontA18n   := TFont():New("Arial",18,18,,.T.,,,,.T.,.F.)	//Negrito
   Local oFontA20    := TFont():New("Arial",20,20,,.F.,,,,.T.,.F.)	//Normal s/negrito
   Local oFontA20n   := TFont():New("Arial",20,20,,.T.,,,,.T.,.F.)	//Negrito

   #IFDEF TOP
      Local cQuery    := "" 
   #ELSE 
      Local cChave    := ""
	  Local cFiltro   := ""       
   #ENDIF

   Private lRecife	   := Iif(GetNewPar("MV_ESTADO","xx") == "PE" .And. Upper(Alltrim(SM0->M0_CIDENT)) == "RECIFE",.T.,.F.) 
   Private lJoinville  := Iif(GetNewPar("MV_ESTADO","xx") == "SC" .And. Upper(Alltrim(SM0->M0_CIDENT)) == "JOINVILLE",.T.,.F.)
   Private lSorocaba   := Iif(GetNewPar("MV_ESTADO","xx") == "SP" .And. Upper(Alltrim(SM0->M0_CIDENT)) == "SOROCABA",.T.,.F.)
   Private lRioJaneiro := Iif(GetNewPar("MV_ESTADO","xx") == "RJ" .And. Upper(Alltrim(SM0->M0_CIDENT)) == "RIO DE JANEIRO",.T.,.F.)      
   Private lBhorizonte := Iif(GetNewPar("MV_ESTADO","xx") == "MG" .And. Upper(Alltrim(SM0->M0_CIDENT)) == "BELO HORIZONTE",.T.,.F.) 
   Private _cnumNFSE   := ""     

   dbSelectArea("SF3")
   dbSetOrder(6)

   #IFDEF TOP

      // Campos que serao adicionados a query somente se existirem na base
      If lIssMat
   	     cCampos := " ,F3_ISSMAT "
      Endif
	 
      If lRecife
         cCampos += " ,F3_CNAE "
      Endif	     
	
      If Empty(cCampos)
  	     cCampos := "%%"
      Else       
  	     cCampos := "% " + cCampos + " %"
      Endif                              

      If TcSrvType()<>"AS/400"
    
  	     lQuery 	:= .T.
	     cAliasSF3	:= GetNextAlias()    
		
         // Verifica se imprime ou nao os documentos cancelados
 	    If mv_par08 == 2
		   cQuery := "% SF3.F3_DTCANC = '' AND %"
	    Else                                      
	  	   cQuery := "%%"
	    Endif
		
A := 1


	    BeginSql Alias cAliasSF3
		   COLUMN F3_ENTRADA AS DATE
		   COLUMN F3_EMISSAO AS DATE
		   COLUMN F3_DTCANC AS DATE
		   COLUMN F3_EMINFE AS DATE
	
		   SELECT F3_FILIAL, F3_ENTRADA, F3_EMISSAO, F3_NFISCAL, F3_SERIE , F3_CLIEFOR, F3_PDV,
		          F3_LOJA  , F3_ALIQICM, F3_BASEICM, F3_VALCONT, F3_TIPO  , F3_VALICM , F3_ISSSUB , F3_ESPECIE,
			      F3_DTCANC, F3_CODISS , F3_OBSERV , F3_NFELETR, F3_EMINFE, F3_CODNFE , F3_CREDNFE, F3_ISENICM, F3_RECISS
			      %Exp:cCampos%
			
		     FROM %table:SF3% SF3
				
		    WHERE SF3.F3_FILIAL = %xFilial:SF3% AND 
			      SF3.F3_CFO >= '5' AND 
			      SF3.F3_ENTRADA >= %Exp:mv_par01% AND 
			      SF3.F3_ENTRADA <= %Exp:mv_par02% AND 
			      SF3.F3_TIPO = 'S' AND
			      SF3.F3_CODISS <> %Exp:Space(TamSX3("F3_CODISS")[1])% AND
			      SF3.F3_CLIEFOR >= %Exp:mv_par03% AND
			      SF3.F3_CLIEFOR <= %Exp:mv_par04% AND
			      SF3.F3_NFISCAL >= %Exp:mv_par05% AND
			      SF3.F3_NFISCAL <= %Exp:mv_par06% AND
			      %Exp:cQuery%
			      SF3.%NotDel%                           
					
   		    ORDER BY SF3.F3_ENTRADA,SF3.F3_SERIE,SF3.F3_NFISCAL,SF3.F3_TIPO,SF3.F3_CLIEFOR,SF3.F3_LOJA

	    EndSql
	
   	    dbSelectArea(cAliasSF3)

     Else

   #ENDIF

 /*
   If Select("T_SF3S") > 0
      T_SF3->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT F3_FILIAL , F3_ENTRADA, F3_EMISSAO, F3_NFISCAL, F3_SERIE  , F3_CLIEFOR, F3_PDV     ,"
   cSql += "       F3_LOJA   , F3_ALIQICM, F3_BASEICM, F3_VALCONT, F3_TIPO   , F3_VALICM  , F3_ISSSUB ,"
   cSql += "       F3_ESPECIE, F3_DTCANC , F3_CODISS , F3_OBSERV , F3_NFELETR, F3_EMINFE  , F3_CODNFE  ," 
   cSql += "       F3_CREDNFE, F3_ISENICM, F3_RECISS"
   cSql += "  FROM " + RetSqlName("SF3") + " SF3 "
   cSql += " WHERE SF3.F3_FILIAL   = '" + xFilial("SF3") + "'"
   cSql += "   AND SF3.F3_CFO     >= '5'" 
   cSql += "   AND SF3.F3_ENTRADA >= '" + MV_PAR01 + "'"
   cSql += "   AND SF3.F3_ENTRADA <= '" + MV_PAR02 + "'"
   cSql += "   AND SF3.F3_TIPO     = 'S'"
   cSql += "   AND SF3.F3_NFISCAL >= '" + Alltrim(MV_PAR05) + "'"
   cSql += "   AND SF3.F3_NFISCAL <= '" + Alltrim(MV_PAR06) + "'"
   cSql += "   AND SF3.D_E_L_E_T_  = ''"
   cSql += "   AND SF3.F3_DTCANC   = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SF3", .T., .T. )

*/

   cArqInd	:= CriaTrab(NIL,.F.)
   cChave	:= "DTOS(F3_ENTRADA)+F3_SERIE+F3_NFISCAL+F3_TIPO+F3_CLIEFOR+F3_LOJA+F3_CNAE"
   cFiltro  := "F3_FILIAL == '" + xFilial("SF3") + "' .And. "
   cFiltro  += "F3_CFO >= '5" + SPACE(LEN(F3_CFO)-1) + "' .And. "	 
   cFiltro  += "DtOs(F3_ENTRADA) >= '" + Dtos(mv_par01) + "' .And. " 
   cFiltro	+= "DtOs(F3_ENTRADA) <= '" + Dtos(mv_par02) + "' .And. "
   cFiltro	+= "F3_TIPO == 'S' .And. F3_CODISS <> '" + Space(Len(F3_CODISS)) + "' .And. "
   cFiltro	+= "F3_CLIEFOR >= '" + mv_par03 + "' .And. F3_CLIEFOR <= '" + mv_par04 + "' .And. "
   cFiltro	+= "F3_NFISCAL >= '" + mv_par05 + "' .And. F3_NFISCAL <= '" + mv_par06 + "'"

   // Verifica se imprime ou nao os documentos cancelados
   If mv_par08 == 2
	  cFiltro	+= " .And. Empty(F3_DTCANC)"
   Endif

//   IndRegua(cAliasSF3,cArqInd,cChave,,cFiltro,STR0006)  //"Selecionando Registros..."
   
   #IFNDEF TOP
      DbSetIndex(cArqInd+OrdBagExt())
   #ENDIF                

   (cAliasSF3)->(dbGotop())
   SetRegua(LastRec())

   #IFDEF TOP
      Endif    
   #ENDIF

   If lSorocaba
      // Imprime os RPS gerados de acordo com o numero de copias selecionadas
	  While (cAliasSF3)->(!Eof())
		
	     ProcRegua(LastRec())
		 If Interrupcao(@lEnd)
			Exit
		 Endif
				
		// Busca o SF2 para verificar NF Cupom nao sera processada e valor da Carga Tributária - Lei 12.741
		cTotImp  := ""
		cFontImp := ""
		
		SF2->(dbSetOrder(1))

		If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))

 		   If !Empty(SF2->F2_NFCUPOM)
		  	  (cAliasSF3)->(dbSKip())
			  Loop
		   Endif
			
  		   // Comentado Michel Aoki - Futuramente usar este codigo, pois e o standard
  		   // Lei Transparência - 12.741
		   cTotImp := Iif(SF2->(FieldPos("F2_TOTIMP"))>0 .And. SF2->F2_TOTIMP > 0,"Valor Aproximado dos Tributos: R$ "+Alltrim(Transform(SF2->F2_TOTIMP,"@E 999,999,999,999.99")+"."),"")
			
		   //Busca a fonte da Carga Tributária - Lei Transparência - 12.741
		   SB1->(dbSetOrder(1))  
		   SD2->(dbSetOrder(3))
	       
	       If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
		      If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
		   		 cFontImp:= Iif(!Empty(cTotImp) .And. "IBPT" $ AlqLeiTran("SB1","SBZ")[2],"Fonte: "+AlqLeiTran("SB1","SBZ")[2],"")
			  EndIf
		   EndIf

		Endif
		
    	// Ponto de entrada para verificar se esse RPS deve ser impresso
		aAreaRPS := (cAliasSF3)->(GetArea())
		lImpRPS	 := .T.

		If lPEImpRPS
			lImpRPS := Execblock("MTIMPRPS",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
		Endif

		RestArea(aAreaRPS)
		
		If !lImpRPS
			(cAliasSF3)->(dbSKip())
			Loop
		EndIf

		// Busca a descricao do codigo de servicos
		cDescrServ := ""
		SX5->(dbSetOrder(1))
		If SX5->(dbSeek(xFilial("SX5")+"60"+(cAliasSF3)->F3_CODISS))
			cDescrServ := Alltrim(SX5->X5_DESCRI)
		Endif

		If lDescrBar
			SF2->(dbSetOrder(1))
			SD2->(dbSetOrder(3))
			SB1->(dbSetOrder(1))
			If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
				If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
					If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
						cDescrServ := If (lCampBar,SB1->(AllTrim(&cDescrBar)),cDescrServ)
					Endif
				Endif
			Endif
		Endif
		
		If !Empty(cCodServ)
			cCodServ += " / "
		EndIf

		cCodServ += Alltrim((cAliasSF3)->F3_CODISS) + " - " + alltrim(cDescrServ)
				
		// Busca o pedido para discriminar os servicos prestados no documento
		cServ := ""
		If lNfeServ
			SC6->(dbSetOrder(4))
			SC5->(dbSetOrder(1))
			If SC6->(dbSeek(xFilial("SC6")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
				dbSelectArea("SX5")
				SX5->(dbSetOrder(1))
				If SC5->(dbSeek(xFilial("SC5")+SC6->C6_NUM)) .And. dbSeek(xFilial("SX5")+"60"+PadR(AllTrim((cAliasSF3)->F3_CODISS),6))
				    cServ := _BuscaDados(SC5->C5_NUM,(cAliasSF3)->F3_NFISCAL,1)
					cServ := AllTrim(SC5->C5_MENNOTA)+CHR(13)+CHR(10)
		   			if !empty(alltrim(SC5->C5_OBSNT))
						cServ += ( " " + AllTrim(SC5->C5_OBSNT))
					endif
					cServ := " | "+AllTrim(SubStr(SX5->X5_DESCRI,1,55))
				Endif
			Endif
		Else
			dbSelectArea("SX5")
			SX5->(dbSetOrder(1))
			If dbSeek(xFilial("SX5")+"60"+PadR(AllTrim((cAliasSF3)->F3_CODISS),6))
				cServ := AllTrim(SubStr(SX5->X5_DESCRI,1,55))
			Endif
		Endif

		If Empty(cServ)
			cServ := cCodServ
		Endif
				
		//Lei Transparência
		/*If !Empty(cTotImp)
			cServ+= +CHR(13)+CHR(10)+cTotImp+cFontImp
		EndIf
		*/

		// Ponto de entrada para compor a descricao a ser apresentada
		aAreaRPS	:= (cAliasSF3)->(GetArea())
		cServPonto	:= ""
		If lDescrNFE
 		   cServPonto := Execblock("MTDESCRNFE",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
		Endif
		RestArea(aAreaRPS)
		If !(Empty(cServPonto))
		   cServ := cServPonto
		Endif

		aPrintServ	:= M968Discri(cServ,10,1400)		

		// Verifica o Cliente/Fornecedor do documento
		cCNPJCli := ""
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
			If RetPessoa(SA1->A1_CGC) == "F"
			   cCNPJCli := Transform(SA1->A1_CGC,"@R 999.999.999-99")
			Else
			   cCNPJCli := Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
			Endif
			cCli		:= SA1->A1_NOME
			cIMCli		:= SA1->A1_INSCRM
			cEndCli		:= SA1->A1_END
			cBairrCli	:= SA1->A1_BAIRRO
			cCepCli		:= SA1->A1_CEP
			cMunCli		:= SA1->A1_MUN
			cUFCli		:= SA1->A1_EST
			cEmailCli	:= SA1->A1_EMAIL
		Else
			(cAliasSF3)->(dbSKip())
			Loop
		Endif	

		// Funcao que retorna o endereco do solicitante quando houver integracao com TMS
		If IntTms()
			aTMS := TMSInfSol((cAliasSF3)->F3_FILIAL,(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE)
			If Len(aTMS) > 0
				cCli		:= aTMS[04]
				If RetPessoa(Alltrim(aTMS[01])) == "F"
 				   cCNPJCli := Transform(Alltrim(aTMS[01]),"@R 999.999.999-99")
				Else
				   cCNPJCli := Transform(Alltrim(aTMS[01]),"@R 99.999.999/9999-99")
				Endif
				cIMCli		:= aTMS[02]
				cEndCli		:= aTMS[05]
				cBairrCli	:= aTMS[06]
				cCepCli		:= aTMS[09]
				cMunCli		:= aTMS[07]
				cUFCli		:= aTMS[08]
				cEmailCli	:= aTMS[10]
			Endif
		Endif		

		// Ponto de entrada para trocar o cliente a ser impresso.
		If lCliNFE
			aMTCliNfe := Execblock("MTCLINFE",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})

			// O ponto de entrada somente e utilizado caso retorne todas as informacoes necessarias
			If Len(aMTCliNfe) >= 12
  			   cCli		:= aMTCliNfe[01]
			   cCNPJCli	:= aMTCliNfe[02]

			   If RetPessoa(cCNPJCli) == "F"
			  	  cCNPJCli := Transform(cCNPJCli,"@R 999.999.999-99")
			   Else
			   	  cCNPJCli := Transform(cCNPJCli,"@R 99.999.999/9999-99")
			   Endif

				cIMCli		:= aMTCliNfe[03]
				cEndCli		:= aMTCliNfe[04]
				cBairrCli	:= aMTCliNfe[05]
				cCepCli		:= aMTCliNfe[06]
				cMunCli		:= aMTCliNfe[07]
				cUFCli		:= aMTCliNfe[08]
				cEmailCli	:= aMTCliNfe[09]
			Endif
		Endif

        cF3_NFISCAL := (cAliasSF3)->F3_NFISCAL
        cF3_SERIE   := (cAliasSF3)->F3_SERIE
        cF3_CLIEFOR := (cAliasSF3)->F3_CLIEFOR
        cF3_LOJA    := (cAliasSF3)->F3_LOJA
        cF3_EMISSAO := (cAliasSF3)->F3_EMISSAO
        _cNumNFSE   := Padl(StrZero(Year((cAliasSF3)->F3_EMISSAO),4)+"/"+(cAliasSF3)->F3_NFELETR,14)
	    nTOTAL   	+= (cAliasSF3)->F3_VALCONT
        nDEDUCAO 	+= (cAliasSF3)->F3_ISSSUB + Iif( lIssMat , (cAliasSF3)->F3_ISSMAT , 0 )
        nBASEISS 	+= (cAliasSF3)->F3_BASEICM
        nALIQISS 	:= (cAliasSF3)->F3_ALIQICM
        nVALISS		+= (cAliasSF3)->F3_VALICM
       
        cKey		:= (cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA

		(cAliasSF3)->(dbSkip())
		
		If cKey <> (cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA .Or. ((cAliasSF3)->(Eof()))

		   // Obtendo os Valores de PIS/COFINS/CSLL/IR/INSS da NF de saida
		   SF2->(dbSetOrder(1))
		   If SF2->(dbSeek(xFilial("SF2")+cKey))
			  nValPis  := SF2->F2_VALPIS 
			  nValCof  := SF2->F2_VALCOFI
			  nValINSS := SF2->F2_VALINSS
			  nValIR   := SF2->F2_VALIRRF
			  nValCSLL := SF2->F2_VALCSLL 
		   Endif

		   // Obtendo as aliquotas de PIS/COFINS/CSLL/IR/INSS atraves da natureza da NF de saida
		   SE1->(dbSetOrder(2))
		   
		   If SE1->(dbSeek(xFilial("SE1")+cF3_CLIEFOR+cF3_LOJA+cF3_SERIE+cF3_NFISCAL))
		      
		      While SE1->(!Eof()) .And. SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM == xFilial("SF3")+cF3_CLIEFOR+cF3_LOJA+cF3_SERIE+cF3_NFISCAL
			     
			     If SE1->E1_TIPO == MVNOTAFIS
				    cNatureza := SE1->E1_NATUREZ
					Exit
			  	 EndIf
				 SE1->(dbSKip())

			  EndDo				

			  SED->(dbSetOrder(1))
			  
			  If SED->(dbSeek(xFilial("SDE")+cNatureza))
				 nAliqPis  := Iif( nValPis  > 0 , Iif( SED->ED_PERCPIS > 0 , SED->ED_PERCPIS , SuperGetMv("MV_TXPIS"  )) , 0 )
				 nAliqCof  := Iif( nValCof  > 0 , Iif( SED->ED_PERCCOF > 0 , SED->ED_PERCCOF , SuperGetMv("MV_TXCOFIN")) , 0 )
				 nALiqINSS := Iif( nValINSS > 0 , SED->ED_PERCINS , 0 )
				 nAliqIR   := Iif( nValIR   > 0 , Iif( SED->ED_PERCIRF > 0 , SED->ED_PERCIRF , SuperGetMV("MV_ALIQIRF")) , 0 )
				 nALiqCSLL := Iif( nValCSLL > 0 , Iif( SED->ED_PERCCSL > 0 , SED->ED_PERCCSL , SuperGetMv("MV_TXCSLL" )) , 0 )
			  EndIf
  
           Else
			  nAliqPis  := Iif( nValPis  > 0 , SuperGetMv("MV_TXPIS"  ) , 0 )
			  nAliqCof  := Iif( nValCof  > 0 , SuperGetMv("MV_TXCOFIN") , 0 )
			  nAliqIR   := Iif( nValIR   > 0 , SuperGetMV("MV_ALIQIRF") , 0 )
			  nALiqCSLL := Iif( nValCSLL > 0 , SuperGetMv("MV_TXCSLL" ) , 0 )
		   EndIf

           aItensSD2 := {}
		   SD2->(dbSetOrder(3))
		   SB1->(dbSetOrder(1))
		   If SD2->(dbSeek(xFilial("SD2")+cKey))
		      Do While SD2->(!Eof()) .And. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == xFilial("SD2")+cKey                      
			 	 SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD))	
                 aAdd(aItensSD2,{SD2->D2_ITEM,SB1->B1_DESC,SD2->D2_QUANT,SD2->D2_PRCVEN,SD2->D2_TOTAL})  
				 SD2->(dbSkip())
              EndDo
		   Endif
			
		   ASort(aItensSD2,,,{|x,y| x[1]  < y[1] })

		   // Relatorio Grafico:                                                                                      
		   // * Todas as coordenadas sao em pixels	                                                                   
		   // * oPrint:Line - (linha inicial, coluna inicial, linha final, coluna final)Imprime linha nas coordenadas 
		   // * oPrint:Say(Linha,Coluna,Valor,Picture,Objeto com a fonte escolhida)		                           

		   For nX := 1 to nCopias

			   // SESSAO - CABECALHO DO RPS - LOGOTIPO - NUMERO E EMISSAO                                                
			   oPrint:SayBitmap(0110,0170, GetSrvProfString("Startpath","")+"SOROCABA.BMP" ,2350,1800) // o arquivo com o logo deve estar abaixo do rootpath (mp10\system)
			   PrintBox( 0080,0080,3350,2330)
			   PrintLine(0220,1850,0220,2330)
			   PrintLine(0080,1850,0360,1850)     
			   PrintBox( 0080,0080,3350,2330)
			   oPrint:Say(0120,0850,"Prefeitura de Sorocaba",oFontA13n)
			   oPrint:Say(0180,0850,"Secretaria de Finanças",oFontA13n)
			   oPrint:Say(0250,0500,"NOTA FISCAL DE SERVIÇOS ELETRÔNICA",oFontA16n)
 			   oPrint:Say(0100,1860,"Número/Prefeit.",oFontA10)                                                                      
 		   	   oPrint:Say(0160,1950,Padl(StrZero(Year((cAliasSF3)->F3_EMISSAO),4)+"/"+(cAliasSF3)->F3_NFELETR,14),oFontA10n)
//			   oPrint:Say(2440,370,(cAliasSF3)->F3_DOC+"/"+(cAliasSF3)->F3_SERIE,oFontA10n)
			   oPrint:Say(0235,1860,"Data de Emissão",oFontA10)
			   oPrint:Say(0300,1950,PadC(cF3_EMISSAO,15),oFontA10n)				

		 	   // SESSAO - PRESTADOR DE SERVICOS                                                                         
			   PrintLine(0360,0080,0360,2330)
			   oPrint:Say(0370,0965,"PRESTADOR DE SERVIÇOS",oFontA10n)
			   oPrint:Say(0410,0100,"Nome/Razão Social:",oFontA08)
			   oPrint:Say(0410,0370,PadR(Alltrim(SM0->M0_NOMECOM),40),oFontA08n)
			   oPrint:Say(0455,0100,"CNPJ:",oFontA08)
			   oPrint:Say(0455,1640,"Inscrição Mobiliária: ",oFontA08)
			   oPrint:Say(0455,0265,PadR(Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),50),oFontA08n)
			   oPrint:Say(0455,1950,PadR(Alltrim(SM0->M0_INSCM),50),oFontA08n)
			   oPrint:Say(0505,0100,"Endereço: ",oFontA08)
			   oPrint:Say(0505,0265,PadR(Alltrim(SM0->M0_ENDENT),50) + " - Bairro: " + PadR(Alltrim(Alltrim(SM0->M0_BAIRENT) + " - CEP: " + Transform(SM0->M0_CEPENT,"@R 99999-999")),50) ,oFontA08n)
			   oPrint:Say(0555,0100,"Município: ",oFontA08)
			   oPrint:Say(0555,1050,"UF: ",oFontA08)
			   oPrint:Say(0555,0265,PadR(Alltrim(SM0->M0_CIDENT),50),oFontA08n)
			   oPrint:Say(0555,1120,PadR(Alltrim(SM0->M0_ESTENT),50),oFontA08n)				

			   // SESSAO - TOMADOR DE SERVICOS                                                                           
			   PrintLine(0600,0080,0600,2330)
			   oPrint:Say(0610,0990,"TOMADOR DE SERVIÇOS",oFontA10n)
			   oPrint:Say(0650,0100,"Nome/Razão Social:",oFontA08)
			   oPrint:Say(0650,0370,PadR(Alltrim(cCli),40),oFontA08n)
			   oPrint:Say(0695,0100,"CNPJ/CPF:",oFontA08)
			   oPrint:Say(0695,0265,PadR(cCNPJCli,50),oFontA08n)
			   oPrint:Say(0745,0100,"Endereço: ",oFontA08)
			   oPrint:Say(0745,0265,PadR(Alltrim(cEndCli),50) + " - Bairro: " + PadR(Alltrim(Alltrim(cBairrCli) + " - CEP: " + Transform(cCepCli,"@R 99999-999")),50) ,oFontA08n)
			   oPrint:Say(0795,0100,"Município: ",oFontA08)
			   oPrint:Say(0795,1050,"UF: ",oFontA08)
			   oPrint:Say(0795,1250,"E-mail: ",oFontA08)
			   oPrint:Say(0795,0265,PadR(Alltrim(cMunCli),50),oFontA08n)
			   oPrint:Say(0795,1120,PadR(Alltrim(cUFCli),50),oFontA08n)
			   oPrint:Say(0795,1350,PadR(Alltrim(cEmailCli),50),oFontA08n)				

			   // SESSAO - DESCRIMINACAO DOS SERVICOS                                                                    
 			   PrintLine(0845,0080,0845,2330)
 			   oPrint:Say(0855,0940,"DISCRIMINAÇÃO DOS SERVIÇOS",oFontA10n)
			   PrintLine(0905,0080,0905,2330)
			   oPrint:Say(0915,0100,"Descrição:",oFontA08)				
			   nLinha	:= 0950

			   For nY := 1 to Len(aPrintServ)
			   	   If nY > 10
				  	  Exit
				   Endif
				   oPrint:Say(nLinha,0100,Alltrim(aPrintServ[nY]),oFontA08)
				   nLinha 	:= nLinha + 39
			   Next nY				

			   // SESSAO - ITENS DO RPS 25 ITEMS POR RPS SEGUNDO O WEB-SERVICES DA NFS-E                                 
			   PrintLine(1335,0080,1335,2330)
			   PrintLine(1335,1450,2645,1450)
			   PrintLine(1335,1640,2645,1640)
			   PrintLine(1335,1950,2645,1950)
			   oPrint:Say(1345,0100,"Item",oFontA08)
			   oPrint:Say(1345,1470,"Quantidade",oFontA08)
			   oPrint:Say(1345,1660,"Valor Unitário",oFontA08)
			   oPrint:Say(1345,1970,"Valor Total",oFontA08)
			   nLinha	:= 1390    
            
               For nY := 1 to Len(aItensSD2)
				   If nY > 25
					  Exit
				   Endif
				   oPrint:Say(nLinha,0100,PadR(aItensSD2[nY][01] + "    " + aItensSD2[nY][02],100),oFontA09)
				   oPrint:Say(nLinha,1470,Transform(aItensSD2[nY][03], PesqPict("SD2","D2_QUANT" )),oFontA09)
			 	   oPrint:Say(nLinha,1710,Transform(aItensSD2[nY][04], PesqPict("SD2","D2_PRCVEN")),oFontA09)
			 	   //oPrint:Say(nLinha,2020,Transform(aItensSD2[nY][05], PesqPict("SD2","D2_TOTAL" )),oFontA09)		
			       oPrint:Say(nLinha,2020,Transform(aItensSD2[nY][05], PesqPict("SF2","F2_VALBRUT" )),oFontA09)		
			       nLinha 	:= nLinha + 45
			   Next nY

			   // SESSAO - PIS / COFINS / INSS / IR / CSLL                                                               
			   PrintLine(2645,0080,2645,2330)
			   PrintLine(2645,0530,2765,0530)
			   PrintLine(2645,0980,2765,0980)
			   PrintLine(2645,1430,2765,1430)
			   PrintLine(2645,1880,2765,1880)
			   oPrint:Say(2665,0210,"PIS("   +Transform(nAliqPis, "@E 99.99") +"%):" ,oFontA09)
			   oPrint:Say(2665,0640,"COFINS("+Transform(nAliqCof, "@E 99.99") +"%):" ,oFontA09)
			   oPrint:Say(2665,1090,"INSS("  +Transform(nAliqINSS,"@E 99.99") +"%):" ,oFontA09)
			   oPrint:Say(2665,1580,"IR("    +Transform(nAliqIR  ,"@E 99.99") +"%):" ,oFontA09)
			   oPrint:Say(2665,2000,"CSLL("  +Transform(nAliqCSLL,"@E 99.99") +"%):" ,oFontA09)

			   oPrint:Say(2710,0230,"R$ " + Transform(nValPis ,PesqPict("SF3","F3_VALICM")),oFontA10n) 
			   oPrint:Say(2710,0675,"R$ " + Transform(nValCof ,PesqPict("SF3","F3_VALICM")),oFontA10n) 
			   oPrint:Say(2710,1125,"R$ " + Transform(nValINSS,PesqPict("SF3","F3_VALICM")),oFontA10n) 
			   oPrint:Say(2710,1575,"R$ " + Transform(nValIR  ,PesqPict("SF3","F3_VALICM")),oFontA10n) 
			   oPrint:Say(2710,2020,"R$ " + Transform(nValCSLL,PesqPict("SF3","F3_VALICM")),oFontA10n) 
								
			   // SESSAO - VALOR TOTAL DO RPS                                                                            
			   PrintLine(2765,0080,2765,2330)
			   oPrint:Say(2785,0950,"VALOR TOTAL DO RPS =",oFontA11n)
			   oPrint:Say(2785,1950,"R$ " + Transform(nTOTAL,PesqPict("SF3","F3_VALCONT")),oFontA11n)

		       // SESSAO - RODAPE - VALOR TODAL DE DEDUCOES - BASE DE CALCULO - ALIQUOTA - VALOR DO ISS                 
			   PrintLine(2855,0080,2855,2330)
			   PrintLine(2855,0642,2980,0642)
			   PrintLine(2855,1204,2980,1204)
	 		   PrintLine(2855,1766,2980,1766)
 				
			   oPrint:Say(2865,0100,"VL. Total Deduções:",oFontA09)
			   oPrint:Say(2865,0662,"Base de Cálculo:"   ,oFontA09)
			   oPrint:Say(2865,1224,"Alíquota:"          ,oFontA09)
			   oPrint:Say(2865,1786,"Valor do ISS:"      ,oFontA09)
				
			   oPrint:Say(2920,0360,"R$ " + Transform(nDEDUCAO,PesqPict("SF3","F3_BASEICM")),oFontA10n)
			   oPrint:Say(2920,0890,"R$ " + Transform(nBASEISS,PesqPict("SF3","F3_BASEICM")),oFontA10n)
			   oPrint:Say(2920,1640,Transform(nALIQISS,PesqPict("SF3","F3_ALIQICM"))+"%",oFontA10n)
			   oPrint:Say(2920,2020,"R$ " + Transform(nVALISS ,PesqPict("SF3","F3_VALICM" )),oFontA10n)

			   // SESSAO - INFORMACOES IMPORTANTES                                                                       
			   PrintLine(2980,0080,2980,2330)
			   oPrint:Say(2990,0920,"INFORMAÇÕES IMPORTANTES",oFontA10n)
			   oPrint:Say(3035,0100,"É possível consultar a autenticidade desta nota no site da prefeitura",oFontA08)
		       //oPrint:Say(3075,0100,"substituí-lo por uma Nota Fiscal de Serviços Eletrônica.",oFontA08)               
			   oPrint:Say(3075,0100,"* Valores para Alíquota e Valor de ISSQN serão calculados de acordo com o movimento econômico com base na tabela de faixa de faturamento.",oFontA08)
		       //oPrint:Say(3170,0100,"* Valores para Alíquota e Valor de ISSQN serão calculados de acordo com o movimento econômico com base na tabela de faixa de faturamento.",oFontA08)
				
			   If nCopias > 1 .And. nX < nCopias
				  oPrint:EndPage()
			   Endif

		   Next nX
            
		   cCodServ := ""
           cServ    := "" 
           nTotal   := 0
	       nDeducao := 0
	       nBaseISS := 0
	       nValISS  := 0

    	EndIf

	   If !((cAliasSF3)->(Eof()))
		  oPrint:EndPage()
	   Endif		
	
	Enddo	

Else	

	// Imprime os RPS gerados de acordo com o numero de copias selecionadas
	While (cAliasSF3)->(!Eof())		

	   ProcRegua(LastRec())
		
	
	   If Interrupcao(@lEnd)
		  Exit
	   Endif		

	   // Analisa Deducoes do ISS
	   nValDed := (cAliasSF3)->F3_ISSSUB		
	   If lIssMat
		  nValDed += (cAliasSF3)->F3_ISSMAT
	   Endif
           
 	   // Valor contabil 
       nVlContab := (cAliasSF3)->F3_VALCONT		

	   // Busca o SF2 para verificar o horario de emissao do documento e Lei da Transparência
   	   SF2->(dbSetOrder(1))
	   cTime   := ""
	   cTotImp := ""
	   cFontImp:= ""
		
	   If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
		  cTime := Transform(SF2->F2_HORA,"@R 99:99")			
		  /*Comentado Michel Aoki - Descomentar futuramente, pois este é o standard
		  //Lei Transparência - 12.741
		  cTotImp := Iif(SF2->(FieldPos("F2_TOTIMP"))>0 .And. SF2->F2_TOTIMP > 0,"Valor Aproximado dos Tributos: R$ "+Alltrim(Transform(SF2->F2_TOTIMP,"@E 999,999,999,999.99")+"."),"")
			
		  // Busca a fonte da Carga Tributária - Lei Transparência - 12.741
		  SB1->(dbSetOrder(1))  
	 	  SD2->(dbSetOrder(3))
     	  If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
		     If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
		   		cFontImp:= Iif(!Empty(cTotImp) .And. "IBPT" $ AlqLeiTran("SB1","SBZ")[2],"Fonte: "+AlqLeiTran("SB1","SBZ")[2],"")
		     EndIf
		  EndIf
		  */
		  // NF Cupom nao sera processada
		  If !Empty(SF2->F2_NFCUPOM)
			 (cAliasSF3)->(dbSKip())
			 Loop
		  Endif
	   Endif
		
 	   // Ponto de entrada para verificar se esse RPS deve ser impresso 
   	   aAreaRPS := (cAliasSF3)->(GetArea())
	   lImpRPS	 := .T.
	   If lPEImpRPS
		  lImpRPS := Execblock("MTIMPRPS",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
	   Endif
	   RestArea(aAreaRPS)
		
	   If !lImpRPS
		  (cAliasSF3)->(dbSKip())
		  Loop
	   EndIf
		
	   // Busca a descricao do codigo de servicos
	   cDescrServ := ""
	   SX5->(dbSetOrder(1))
	   If SX5->(dbSeek(xFilial("SX5")+"60"+(cAliasSF3)->F3_CODISS))
		  cDescrServ := SX5->X5_DESCRI
	   Endif
 	// If lDescrBar 
		  SF2->(dbSetOrder(1))
		  SD2->(dbSetOrder(3))
		  SB1->(dbSetOrder(1))
		  If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
			 If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
				If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
					cTotImp := _Transparencia(Alltrim(SB1->B1_DESC),SD2->D2_TOTAL)//Lei da Transparência Michel Aoki
				Endif
			 Endif
		  Endif
	// Endif 
	
	   If lRecife
		  cCodAtiv := Alltrim((cAliasSF3)->F3_CNAE)
	   Else
		  cCodServ := Alltrim((cAliasSF3)->F3_CODISS) + " - " + cDescrServ
	   EndIf
		
	   // Busca o pedido para discriminar os servicos prestados no documento
	   cServ := ""
	   If lNfeServ
	      SC6->(dbSetOrder(4))
		  SC5->(dbSetOrder(1))
		  If SC6->(dbSeek(xFilial("SC6")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
			 dbSelectArea("SX5")
			 SX5->(dbSetOrder(1))
			 If SC5->(dbSeek(xFilial("SC5")+SC6->C6_NUM)) .And. dbSeek(xFilial("SX5")+"60"+PadR(AllTrim((cAliasSF3)->F3_CODISS),6))
				cServ := AllTrim(SC5->C5_MENNOTA)+CHR(13)+CHR(10)
    			if !empty(alltrim(SC5->C5_OBSNT))
					cServ += ( " " + AllTrim(SC5->C5_OBSNT))
				endif
				cServ := " | "+AllTrim(SubStr(SX5->X5_DESCRI,1,55))
			 Endif
		  Endif
	   Else
	
		  SC6->(dbSetOrder(4))
		  SC5->(dbSetOrder(1))
		  If SC6->(dbSeek(xFilial("SC6")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
			 dbSelectArea("SX5")
			 SX5->(dbSetOrder(1))
			 If SC5->(dbSeek(xFilial("SC5")+SC6->C6_NUM)) .And. dbSeek(xFilial("SX5")+"60"+PadR(AllTrim((cAliasSF3)->F3_CODISS),6))
				cServ := _BuscaDados(SC5->C5_NUM,(cAliasSF3)->F3_NFISCAL,1)
			 Endif
		  Endif
		
	   Endif        
		
	   If Empty(cServ)
		  cServ := cDescrServ
	   Endif
		
	   //Lei Transparência
	   /*If !Empty(cTotImp) Michel Aoki
		    cServ+= +CHR(13)+CHR(10)+cTotImp+cFontImp
	     EndIf
	   */
		
	   //Adicionado Michel aoki - Observação Automatech
	   SC6->(dbSetOrder(4))
	   SC5->(dbSetOrder(1))
	   If SC6->(dbSeek(xFilial("SC6")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
		  _cObsAuto := _ObsPv(SC6->C6_NUM)
	   Endif
	   //>>>>>>>>>>>>>>>>>>>>>>>>	

       // Ponto de entrada para compor a descricao a ser apresentada
	   aAreaRPS	  := (cAliasSF3)->(GetArea())
	   cServPonto := ""

	   If lDescrNFE
	   	  cServPonto := Execblock("MTDESCRNFE",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
	   Endif

	   RestArea(aAreaRPS)

	   If !(Empty(cServPonto))
	   	  cServ := cServPonto
	   Endif

	   aPrintServ	:= Mtr968Mont(cServ,13,999)
		
       // #################################################################################################
       // Altera a descrição dos produtos caso no cadastro do produto o campo B1_GDES estiver preenchido ##
       // #################################################################################################
       If Select("T_DESCRICAO") > 0
          T_DESCRICAO->( dbCloseArea() )
       EndIf
                     
       cSql := ""
       cSql := "SELECT SC6.C6_FILIAL , "
       cSql += "       SC6.C6_PRODUTO, "
       cSql += "       SC6.C6_NOTA   , "
       cSql += "       SC6.C6_SERIE  , "
       cSql += "       SC6.C6_NUMOS  , "
	   cSql += "	   SB1.B1_DESC   , "
	   cSql += "	   SB1.B1_DAUX   , "
	   cSql += "	   SB1.B1_GDES     "
       cSql += "  FROM " + RetSqlName("SC6") + " SC6, "
	   cSql += "	   " + RetSqlName("SB1") + " SB1  "
       cSql += " WHERE SC6.C6_FILIAL  = '" + Alltrim(cFilAnt)                 + "'"
       cSql += "   AND SC6.C6_NOTA    = '" + Alltrim((cAliasSF3)->F3_NFISCAL) + "'"
       cSql += "   AND SC6.C6_SERIE   = '" + Alltrim((cAliasSF3)->F3_SERIE)   + "'"
       cSql += "   AND SC6.C6_NUMOS  <> ''"
       cSql += "   AND SC6.D_E_L_E_T_ = ''"                                                                                                                    
 	   cSql += "   AND SB1.B1_COD     = SC6.C6_PRODUTO"
	   cSql += "   AND SB1.D_E_L_E_T_ = ''"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DESCRICAO", .T., .T. )
       
       If T_DESCRICAO->( EOF() )
       Else

          aPrintServ := {}

          T_DESCRICAO->( DbGoTop() )
          
          WHILE !T_DESCRICAO->( EOF() )
          
             If Empty(Alltrim(T_DESCRICAO->B1_GDES))
                aAdd(aPrintServ, Alltrim(T_DESCRICAO->B1_DESC) + " " + Alltrim(T_DESCRICAO->B1_DAUX) )
             Else
                aAdd(aPrintServ, Alltrim(T_DESCRICAO->B1_GDES) )
             Endif
             
             T_DESCRICAO->( DbSkip() )
             
          ENDDO
          
       Endif

	   If lRioJaneiro
          cObsRio := ""
          nDescIncond := 0                         
		  SF2->(dbSetOrder(1))
		  SD2->(dbSetOrder(3))
		  
		  If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
			 If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
	            SF4->(DbSetOrder(1))		
				If SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
	               If SF2->F2_DESCONT > 0
	                  If SF4->F4_DESCOND == "1"  
	                     cObsRio := " Deconto Condic. de (R$) " 
	                     cObsRio += Alltrim(Transform(SF2->F2_DESCONT,"@ze 9,999,999,999,999.99")) 
	                  Else
	                     nDescIncond := SF2->F2_DESCONT                  
	                  EndIf
	               EndIf
	    		EndIf
			 Endif
		  Endif            
	   Endif

   	   cObserv 	:= Alltrim((cAliasSF3)->F3_OBSERV) + Iif(!Empty((cAliasSF3)->F3_OBSERV)," | ","")
//	   cObserv 	+= Iif(!Empty((cAliasSF3)->F3_PDV) .And. Alltrim((cAliasSF3)->F3_ESPECIE) == "CF",STR0042 + " | ","")

       If lRioJaneiro
	      cObsRio     += "'Obrigatória a conversão em Nota Fiscal de Serviços Eletrônica – NFS-e – NOTA CARIOCA em até vinte dias.'" + " | "
	   EndIf
	   
	   aAreaRPS 	:= (cAliasSF3)->(GetArea())

	   // Ponto de entrada para complementar as observacoes a serem apresentadas
	   cObsPonto	:= ""
	   cObsPonto	:= _cObsAuto//Adicionado Michel Aoki
		
	   /*
	   If lObsNFE Comentado Michel aoki
	   	cObsPonto := Execblock("MTOBSNFE",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
	   Endif 
	   */

	   RestArea(aAreaRPS)
	   cObserv 	 := _cObsAuto//cObserv + cObsPonto
	   cObserv 	 := cObserv + cObsRio
	   aPrintObs := Mtr968Mont(cObserv,11,675)		

   	   // Verifica o cLiente/fornecedor do documento
	   cCNPJCli := ""
	   cRecIss  := ""
	   SA1->(dbSetOrder(1))
	
	   If SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
		  If RetPessoa(SA1->A1_CGC) == "F"
		   	 cCNPJCli := Transform(SA1->A1_CGC,"@R 999.999.999-99")
		  Else
			 cCNPJCli := Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
		  Endif
		  cCli		:= SA1->A1_NOME
		  cIMCli	:= SA1->A1_INSCRM
		  cEndCli	:= SA1->A1_END
		  cBairrCli	:= SA1->A1_BAIRRO
		  cCepCli	:= SA1->A1_CEP
		  cMunCli	:= SA1->A1_MUN
		  cUFCli	:= SA1->A1_EST
		  cEmailCli	:= SA1->A1_EMAIL
		  cRecIss   := SA1->A1_RECISS
		  cRecCof   := SA1->A1_RECCOFI
		  cRecPis   := SA1->A1_RECPIS
		  cRecIR    := SA1->A1_RECIRRF    
		  cRecCsl   := SA1->A1_RECCSLL         
		  cRecIns   := SA1->A1_RECINSS
  	   Else
		  (cAliasSF3)->(dbSKip())
		  Loop
	   Endif		

	   // Funcao que retorna o endereco do solicitante quando houver integracao com TMS
	   If IntTms()
		  aTMS := TMSInfSol((cAliasSF3)->F3_FILIAL,(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE)
		  If Len(aTMS) > 0
		 	 cCli		:= aTMS[04]
			 If RetPessoa(Alltrim(aTMS[01])) == "F"
				cCNPJCli := Transform(Alltrim(aTMS[01]),"@R 999.999.999-99")
			 Else
				cCNPJCli := Transform(Alltrim(aTMS[01]),"@R 99.999.999/9999-99")
			 Endif
			cIMCli		:= aTMS[02]
			cEndCli		:= aTMS[05]
			cBairrCli	:= aTMS[06]
			cCepCli		:= aTMS[09]
			cMunCli		:= aTMS[07]
			cUFCli		:= aTMS[08]
			cEmailCli	:= aTMS[10]
		Endif
	 Endif		

 	 // Ponto de entrada para trocar o cliente a ser impresso.
	 If lCliNFE
	 	aMTCliNfe := Execblock("MTCLINFE",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
	
		// O ponto de entrada somente e utilizado caso retorne todas as informacoes necessarias
		If Len(aMTCliNfe) >= 12
		   cCli		:= aMTCliNfe[01]
		   cCNPJCli	:= aMTCliNfe[02]
		   If RetPessoa(cCNPJCli) == "F"
		   	  cCNPJCli := Transform(cCNPJCli,"@R 999.999.999-99")
		   Else
		   	  cCNPJCli := Transform(cCNPJCli,"@R 99.999.999/9999-99")
		   Endif
		   cIMCli		:= aMTCliNfe[03]
		   cEndCli		:= aMTCliNfe[04]
		   cBairrCli	:= aMTCliNfe[05]
		   cCepCli		:= aMTCliNfe[06]
		   cMunCli		:= aMTCliNfe[07]
		   cUFCli		:= aMTCliNfe[08]
		   cEmailCli	:= aMTCliNfe[09]
		Endif
	Endif

	lBhorizonte := .T. // Jean Rehermann - Solutio IT - 28/05/2015 - Forço a entrada neste trecho para calcular os impostos
		
	If lBhorizonte                        

	   nValDed     := 0
	   nValDesc    := 0
	   nDescIncond := 0
	   nValLiq     := 0
	   nVALISS     := 0
	   nValPis     := 0
	   nValCof     := 0
	   nValCSLL    := 0
	   nValIR      := 0
	   nValINSS	:= 0
								
   	   nValDed := Iif( (cAliasSF3)->F3_RECISS == "1", (cAliasSF3)->F3_VALICM, 0 )
	   cRecIss := (cAliasSF3)->F3_RECISS // Caso cliente tenha sido alterado após emissão da nota, tenho que considerar o que está na nota
			
	   SF2->(dbSetOrder(1))
   	   SD2->(dbSetOrder(3))
	
	   If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
		  If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
		  	 While SD2->(!Eof()) .And. xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA==xFilial("SD2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
			    If Alltrim(SD2->D2_CODISS) == Alltrim((cAliasSF3)->F3_CODISS) 
				   SF4->(DbSetOrder(1))		
				   If SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
					  nValLiq  += SD2->D2_TOTAL
					  nVALISS  += Iif(SD2->(FieldPos("D2_VALISS")) > 0,SD2->D2_VALISS, 0) 
					  nValPis  := Iif(SD2->(FieldPos("D2_VALPIS")) > 0,SD2->D2_VALPIS, 0) 
					  nValCof  := Iif(SD2->(FieldPos("D2_VALCOF")) > 0,SD2->D2_VALCOF, 0) 
					  nValCSLL := Iif(SD2->(FieldPos("D2_VALCSL")) > 0,SD2->D2_VALCSL, 0) 
					  nValIR   := Iif(SD2->(FieldPos("D2_VALIRRF")) > 0,SD2->D2_VALIRRF, 0)
					  nValINSS := Iif(SD2->(FieldPos("D2_VALINS")) > 0,SD2->D2_VALINS, 0)

					  nValDesc	:= SD2->D2_DESCON

					  If SF4->F4_DESCOND <> "1"  
					     nDescIncond := nValDesc
					  EndIf

					  If SF4->F4_AGREG == "D"
						 nValDesc += SD2->D2_DESCICM
						 nValLiq -= SD2->D2_DESCICM
						 //nVlContab := nVlContab + SD2->D2_DESCICM
					  Endif
				   EndIf
			    Endif
				SD2->(dbSkip())
			 Enddo 
		  Endif 
	   EndIf
	   
	   nRetFeder   := 0
       
       If cRecIss == "1"
          nValLiq := nValLiq - nValISS
	   EndIf
       
       If cRecCof == "S"
          nValLiq    := nValLiq - nValCof
		  nRetFeder  := nRetFeder + nValCof
	   EndIf
       If cRecPis == "S"
          nValLiq := nValLiq - nValPis     
          nRetFeder  := nRetFeder + nValPis
	   EndIf
       If cRecCsl == "S"
          nValLiq := nValLiq - nValCsll
          nRetFeder  := nRetFeder + nValCsll
	   EndIf
       If cRecIr == "1"
          nValLiq := nValLiq - nValIR    
          nRetFeder  := nRetFeder + nValIR
	   Endif            
	   If cRecIns == "S"
		  nValLiq := nValLiq - nValINSS
		  nRetFeder  := nRetFeder + nValINSS
	   EndIf

	   lBhorizonte := .F. // Jean Rehermann - Solutio IT - 28/05/2015 - Retorno o Flag para o original após o cálculo dos impostos

	Endif

	If lJoinville
		SF2->(dbSetOrder(1))
		SB1->(dbSetOrder(1))
		SD2->(dbSetOrder(3))
		If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->(F3_NFISCAL+F3_SERIE)))
			If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
				If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
					nValBase	:= Iif (Empty((cAliasSF3)->F3_BASEICM),(cAliasSF3)->F3_ISENICM,(cAliasSF3)->F3_BASEICM)
					nAliquota	:= SB1->B1_ALIQISS
				Endif
			EndIf
		EndIf
	Endif

    // Relatorio Grafico:                                                                                      
    // * Todas as coordenadas sao em pixels	                                                                   
    // * oPrint:Line - (linha inicial, coluna inicial, linha final, coluna final)Imprime linha nas coordenadas 
    // * oPrint:Say(Linha,Coluna,Valor,Picture,Objeto com a fonte escolhida)		                           
    For nX := 1 to nCopias
			
	    // Box no tamanho do RPS
		oPrint:Line(nLinIni,nColIni,nLinIni,nColFim)
		oPrint:Line(nLinIni,nColIni,nLinFim,nColIni)
		oPrint:Line(nLinIni,nColFim,nLinFim,nColFim)
		oPrint:Line(nLinFim,nColIni,nLinFim,nColFim)
			
		// Dados da empresa emitente do documento
		If Empty(cLogAlter)   			
//		   cLogo := GetSrvProfString("Startpath","") + cEmpAnt + "logo_nfse.bmp" //FisxLogo("1")

           Do Case 
              Case cEmpAnt == "01"
                   Do Case 
                      Case cFilant == "01"
       		               cLogo := GetSrvProfString("Startpath","") + cEmpAnt + "logo_POA.bmp" //FisxLogo("1")

                      Case cFilant == "02"
       		               cLogo := GetSrvProfString("Startpath","") + cEmpAnt + "Logo_cXS.bmp" //FisxLogo("1")

                      Case cFilant == "03"
       		               cLogo := GetSrvProfString("Startpath","") + cEmpAnt + "logo_PEL.bmp" //FisxLogo("1")
                      Case cFilant == "05"
       		               cLogo := GetSrvProfString("Startpath","") + cEmpAnt + "logo_XPA.bmp" //FisxLogo("1")
                      Case cFilant == "07"
       		               cLogo := GetSrvProfString("Startpath","") + cEmpAnt + "logo_POA.bmp" //FisxLogo("1")

       		          Otherwise
             		       cLogo := cLogAlter       		               
       		       EndCase
              Case cEmpAnt == "02"                              
              Case cEmpAnt == "03"
                   Do Case 
                      Case cFilant == "01"
       		               cLogo := GetSrvProfString("Startpath","") + cEmpAnt + "logo_POA.bmp" //FisxLogo("1")
                      Case cFilant == "03"
       		               cLogo := GetSrvProfString("Startpath","") + cEmpAnt + "logo_PEL.bmp" //FisxLogo("1")
       		          Otherwise
             		       cLogo := cLogAlter       		               
       		       EndCase 
			  Case cEmpAnt == "04"
					Do Case 
					  Case cFilant == "01"
                           cLogo := GetSrvProfString("Startpath","") + cEmpAnt + "logo_PEL.bmp" //FisxLogo("1")
        		      Otherwise
                   			cLogo := cLogAlter
                   	EndCase       		               
           EndCase
  		Else
   		   cLogo := cLogAlter
   		EndIf

   		// o arquivo com o logo deve estar abaixo do rootpath (mp8\system)
   		oPrint:SayBitmap(250,nColIni+10,cLogo,350,340) 
		oPrint:Line(nLinIni,1800,612,1800)
		oPrint:Line(354,1800,354,nColFim)
		oPrint:Line(483,1800,483,nColFim)
		oPrint:Line(612,nColIni,612,nColFim)

        Do Case
           Case cEmpAnt == "01"
                Do Case
                   Case cFilAnt == "01"
      		            oPrint:Say(305,750,"PREFEITURA DE PORTO ALEGRE",oFontA12n)
		                oPrint:Say(370,750,"SECRETARIA DA FAZENDA"     ,oFontA12n)
		                oPrint:Say(435,750,"NOTA FISCAL ELETRÔNICA DE SERVIÇO - NFS-e" ,oFontA12n)
                   Case cFilAnt == "02"
      		            oPrint:Say(305,750,"PREFEITURA MUNICIPAL DE CAXIAS DO SUL",oFontA11n)
		                oPrint:Say(370,750,"SECRETARIA DA RECEITA MUNICIPAL"      ,oFontA11n)
		                oPrint:Say(435,750,"NOTA FISCAL FATURA DE SERVIÇO ELETRÔNICA - NFFS-e" ,oFontA10n)
                   Case cFilAnt == "03"
      		            oPrint:Say(305,750,"PREFEITURA MUNICIPAL DE PELOTAS",oFontA12n)
		                oPrint:Say(370,750,"SECRETARIA DA RECEITA"     ,oFontA12n)
		                oPrint:Say(435,750,"NOTA FISCAL ELETRÔNICA DE SERVIÇO - NFS-e" ,oFontA12n)
                   Case cFilAnt == "05"
      		            oPrint:Say(305,750,"PREFEITURA MUNICIPAL DE SÃO PAULO",oFontA12n)
		                oPrint:Say(370,750,"SECRETARIA DA RECEITA"            ,oFontA12n)
		                oPrint:Say(435,750,"NOTA FISCAL ELETRÔNICA DE SERVIÇO - NFS-e" ,oFontA12n)
                   Case cFilAnt == "07"
      		            oPrint:Say(305,750,"PREFEITURA DE PORTO ALEGRE",oFontA12n)
		                oPrint:Say(370,750,"SECRETARIA DA FAZENDA"     ,oFontA12n)
		                oPrint:Say(435,750,"NOTA FISCAL ELETRÔNICA DE SERVIÇO - NFS-e" ,oFontA12n)
                EndCase
           Case cEmpAnt == "03"
                Do Case                      
                   Case cFilAnt == "01"
      		            oPrint:Say(305,750,"PREFEITURA DE PORTO ALEGRE",oFontA12n)
		                oPrint:Say(370,750,"SECRETARIA DA FAZENDA"     ,oFontA12n)
		                oPrint:Say(435,750,"NOTA FISCAL ELETR?NICA DE SERVI?O - NFS-e" ,oFontA12n)
                   Case cFilAnt == "03"
      		            oPrint:Say(305,750,"PREFEITURA MUNICIPAL DE PELOTAS",oFontA12n)
		                oPrint:Say(370,750,"SECRETARIA DA RECEITA"     ,oFontA12n)
		                oPrint:Say(435,750,"NOTA FISCAL ELETRÔNICA DE SERVIÇO - NFS-e" ,oFontA12n)
                EndCase
           Case cEmpAnt == "04"
           		Do Case                      
                   Case cFilAnt == "01"
      		            oPrint:Say(305,750,"PREFEITURA MUNICIPAL DE PELOTAS",oFontA12n)
		                oPrint:Say(370,750,"SECRETARIA DA RECEITA"     ,oFontA12n)
		                oPrint:Say(435,750,"NOTA FISCAL ELETRÔNICA DE SERVIÇO - NFS-e" ,oFontA12n)
                EndCase
        EndCase        

		// Informacoes sobre a emissao do RPS

        // Número/Série RPS
		oPrint:Say(250,1830,"Número/Prefeit.",oFontA10n) 

	    //oPrint:Say(295,1830,PadC(Alltrim(Alltrim((cAliasSF3)->F3_NFISCAL) + Iif(!Empty((cAliasSF3)->F3_SERIE)," / " + Alltrim((cAliasSF3)->F3_SERIE),"")),15),oFont10)
	    //oPrint:Say(295,1830,Padl(StrZero(Year((cAliasSF3)->F3_EMISSAO),4)+"/"+(cAliasSF3)->F3_NFELETR,14),oFontA10) 

        // ##################################################################################
        // Alterado devido o Protheus 12 porque mudou o tamanho do campo nota fiscal (RPS) ##
        // ##################################################################################
        Do Case
           Case cEmpAnt == "01"
                Do Case
                   Case cFilAnt == "01"
     	                oPrint:Say(295,1830,Substr((cAliasSF3)->F3_NFELETR,01,04) + "/" + Substr((cAliasSF3)->F3_NFELETR,05),oFontA10) 
                   Case cFilAnt == "02"
	                    oPrint:Say(295,1830,StrZero(Year((cAliasSF3)->F3_EMISSAO),4) + "/" + Substr((cAliasSF3)->F3_NFELETR,12),oFontA10) 
                   Case cFilAnt == "05"
	                    oPrint:Say(295,1830,(cAliasSF3)->F3_NFELETR,oFontA10) 
	               Otherwise
     	                oPrint:Say(295,1830,((cAliasSF3)->F3_NFELETR,01,04) + "/" + Substr((cAliasSF3)->F3_NFELETR,05),oFontA10) 	                    
     	        EndCase
           Case cEmpAnt == "02"
                oPrint:Say(295,1830,Substr((cAliasSF3)->F3_NFELETR,01,04) + "/" + Substr((cAliasSF3)->F3_NFELETR,05),oFontA10) 
           Case cEmpAnt == "03"
	            oPrint:Say(295,1830,Substr((cAliasSF3)->F3_NFELETR,01,04) + "/" + Substr((cAliasSF3)->F3_NFELETR,05),oFontA10) 
           Case cEmpAnt == "04"
                oPrint:Say(295,1830,StrZero(Year((cAliasSF3)->F3_EMISSAO),4) + "/" + Alltrim((cAliasSF3)->F3_NFELETR),oFontA10)   
        EndCase
             	                



	            

        // Data Emissão
// 		oPrint:Say(375,1830,PadC(Alltrim(STR0017),15),oFontA10n) 
 		oPrint:Say(375,1830,"Data de Emissão",oFontA10n) 
		oPrint:Say(420,1830,PadC((cAliasSF3)->F3_EMISSAO,15),oFontA10)

        // Hora Emissão
//		oPrint:Say(510,1830,PadC(Alltrim(STR0018),15),oFontA10n) 
 		oPrint:Say(510,1830,"Hora de Emissão",oFontA10n) 
		oPrint:Say(555,1830,PadC(Alltrim(cTime),15),oFontA10)

        nLinha := 625

		// Dados da Prestadora de Serviço
		oPrint:Say(nLinha,750,"PRESTADOR DE SERVIÇO",oFontA12n)
        nLinha += 50
        oPrint:Line(nLinha,750,nLinha,(nColFim - 30))
        nLinha += 50

        // Imprime logo da Prestadora de Serviços
// 		oPrint:SayBitmap(nLinha,0250,"pclogoautoma.bmp",370,250) 
 		oPrint:SayBitmap(nLinha,0250,"pclogoautoma.bmp",450,180) 

        // Nome/Razão Social
		oPrint:Say(nLinha,0750,"Nome/Razão Social:",oFontA09) 
		oPrint:Say(nLinha,1050,Alltrim(SM0->M0_NOMECOM),oFontA09n)
        nLinha += 50

        // C.P.F./C.N.P.J.
		oPrint:Say(nLinha,0750,"CPF/CNPJ:",oFontA09) 
		oPrint:Say(nLinha,1050,Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),oFontA09n)
        nLinha += 50

        // Inscrição Municipal
		oPrint:Say(nLinha,0750,"Inscrição Municipal:",oFontA09) 
		oPrint:Say(nLinha,1050,Alltrim(SM0->M0_INSCM),oFontA09n)
        nLinha += 50

        // Endereço
		oPrint:Say(nLinha,0750,"Endereço:",oFontA09) 

		oPrint:Say(nLinha,1050,Alltrim(SM0->M0_ENDENT),oFontA09n)   &&          + " - " + Alltrim(SM0->M0_BAIRENT),oFontA09n)
        nLinha += 50

        // Bairro/CEP
		oPrint:Say(nLinha,0750,"Bairro:",oFontA09) 
		oPrint:Say(nLinha,1050,Alltrim(SM0->M0_BAIRENT) + " - " + Transform(SM0->M0_CEPENT,"@R 99999-999"),oFontA09n)
        nLinha += 50
        
        // Município
		oPrint:Say(nLinha,0750,"Município:",oFontA09) 
		oPrint:Say(nLinha,1050,Alltrim(SM0->M0_CIDENT) + " - UF: " + Alltrim(SM0->M0_ESTENT),oFontA09n)
        
        // Linha Separadora
        nLinha += 60
        oPrint:Line(nLinha,nColIni,nLinha,nColFim)

        nLinha += 40

		// Dados do destinatario
		oPrint:Say(nLinha,750,"TOMADOR DE SERVIÇOS",oFontA12n)
        nLinha += 50
        oPrint:Line(nLinha,750,nLinha,(nColFim - 30))
        nLinha += 50

        // Nome/Razão Social
		oPrint:Say(nLinha,250,"Nome/Razão Social:",oFontA09) 
		oPrint:Say(nLinha,750,Alltrim(cCli),oFontA09n)
        nLinha += 50
		
        // C.P.F./C.N.P.J.
		oPrint:Say(nLinha,250,"C.P.F./C.N.P.J.:",oFontA09) 
		oPrint:Say(nLinha,750,Alltrim(cCNPJCli),oFontA09n)
        
        // Inscrição Municipal
		oPrint:Say(nLinha,1530,"Inscrição Municipal:",oFontA09) 
		oPrint:Say(nLinha,1830,Alltrim(cIMCli),oFontA09n)
        nLinha += 50

        // Endereço
		oPrint:Say(nLinha,250,"Endereço:",oFontA09) 
		oPrint:Say(nLinha,750,Alltrim(cEndCli) + " - " + Alltrim(cBairrCli) + "  - CEP: " + Transform(cCepCli,"@R 99999-999"),oFontA09n)
        nLinha += 50
        		
        // Município
		oPrint:Say(nLinha,250,"Município:",oFontA09) 
		oPrint:Say(nLinha,750,Alltrim(cMunCli),oFontA09n)

        // UF
		oPrint:Say(nLinha,1750,"UF:",oFontA09) 
		oPrint:Say(nLinha,1830,Alltrim(cUFCli),oFontA09n)
        nLinha += 50				
        
        // E-mail
		oPrint:Say(nLinha,250,"E-mail:",oFontA09) 
		oPrint:Say(nLinha,750,Alltrim(cEmailCli),oFontA09n)
        nLinha += 50
        
        // Linha Separadora
		oPrint:Line(nLinha,nColIni,nLinha,nColFim)
        nLinha += 30		

		// Discriminacao dos Servicos
		oPrint:Say(nLinha,0250,"DISCRIMINAÇÃO DOS SERVIÇOS",oFontA12n) 
        nLinha += 60
        oPrint:Line(nLinha,nColIni,nLinha,nColFim)
        nLinha += 60

		For nY := 1 to Len(aPrintServ)
            // Jean Rehermann - Solutio IT - 28/05/2015 - Alterei de 15 para 7 linhas para apresentar os impostos retidos
			If nY > 7  
			   Exit
			Endif
			oPrint:Say(nLinha,250,Alltrim(aPrintServ[nY]),oFontA10)
			nLinha += 45
		Next                        

		// Jean Rehermann - Solutio IT - Impressão das linhas das retenções
		nLinha += 50

        oPrint:Line(nLinha,nColIni,nLinha,nColFim)

//		nLinha += 15

   	    oPrint:Line(nLinha,0680,nLinha + 100,680)

   	    oPrint:Line(nLinha,0980,nLinha + 100,0980)
   	    oPrint:Line(nLinha,1280,nLinha + 100,1280)    
  	    oPrint:Line(nLinha,1580,nLinha + 100,1580)    
  	    oPrint:Line(nLinha,1880,nLinha + 100,1880)    

		nLinha += 15

	    oPrint:Say(nLinha,0250,"ISS Ret. (R$)",oFontA09n)
		oPrint:Say(nLinha,0700,"PIS (R$)"     ,oFontA09n)
		oPrint:Say(nLinha,1000,"COFINS (R$)"  ,oFontA09n)
		oPrint:Say(nLinha,1300,"CSLL (R$)"    ,oFontA09n)
		oPrint:Say(nLinha,1600,"IR Ret (R$)"  ,oFontA09n)
		oPrint:Say(nLinha,1900,"INSS Ret (R$)",oFontA09n)
		
		nLinha += 50

        cPictRet := PesqPict("SF3","F3_VALICM")

//      A leitura dos valores dos impostos para impressão foi alterado no dia 15/09/2015 em reunião realizada entre Tatiane, Adriana e Harald
//      Fico determinado que a leituira dos impostos será pelo cabeçalho da nota fiscal e não pela tabela SF3 - Livros Fiscais        
//

        // Envia para a função que calcula os valores das reduções
        aAbatimento := {}
        aAbatimento := CalcAbaServico()

        nValISS  := 0
        nValPIS  := aAbatimento[01,01]
        nValCof  := aAbatimento[01,02]
        nValCSLL := aAbatimento[01,03]
        nValIR   := aAbatimento[01,04]
        nValINSS := aAbatimento[01,05]
 
//->    nValISS  := 0
//->    nValPIS  := SF2->F2_VALPIS
//->    nValCof  := SF2->F2_VALCOFI
//->    nValCSLL := SF2->F2_VALCSLL
//->    nValIR   := SF2->F2_VALIRRF
//->    nValINSS := SF2->F2_VALINSS

//      nValDed  := nValISS + nValPIS + nValCof + nValCSLL + nValIR + nValINSS

       // ------------------------------------------------------------------------------------------------------------------- //
       // Regra passada no dia 12/05/2016 pelo Sr. Paulo da Controladoria sobre a nova regra de impressão dos impostos sendo: //
       //                                                                                                                     //
       // Deverá ser pesquisada na tabela SE1 - Contas a Receber verificando a existência de registros de impostos com:       //
       //                                                                                                                     //
       // IMPOSTO        E1_TIPO         E1_NATUREZ                                                                           //
       // -------        -------         ----------                                                                           //
       // PIS            PI-             PIS                                                                                  //
       // CSLL           CS-             CSLL                                                                                 //
       // COFINS         CF-             COFINS                                                                               //
       // IR             IR-             IRF                                                                                  //
       // INSS           -               -                                                                                    //
       //                                                                                                                     //
       // Sendo a impressão com a seguinte regra:                                                                             //
       // ---------------------------------------                                                                             //
       // Se existir registros de PIS, CSLL e COFINS e se a soma destes impostos for >= 10,00, realiza a impressão            //
       // Se existir registro  de IRRF e se o valor total deste imposto for >= 10,00, realiza a impressão                     //
       // O INSS não está parametrizado nesta regra pois o mesmo não foi passado pela Contraladoria                           //
       // ------------------------------------------------------------------------------------------------------------------- //

       // ------------------------ //
       // Pesquisa o valor do IRRF //
       // ------------------------ //      
       If Select("T_IRRF") > 0
          T_IRRF->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT E1_FILIAL ,"
       cSql += "       E1_PREFIXO,"
       cSql += "       E1_NUM    ,"
	   cSql += "       E1_TIPO   ,"
	   cSql += "       E1_NATUREZ," 
	   cSql += "       SUM(E1_VALOR) AS VALOR_IRRF"
       cSql += "  FROM " + RetSqlName("SE1")
       cSql += " WHERE E1_NUM     = '" + Alltrim((cAliasSF3)->F3_NFISCAL) + "'"
       cSql += "   AND E1_PREFIXO = '" + Alltrim((cAliasSF3)->F3_SERIE)   + "'"
       cSql += "   AND D_E_L_E_T_ = ''"
       cSql += "   AND E1_TIPO    = 'IR-'"
       cSql += " GROUP BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_TIPO, E1_NATUREZ"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_IRRF", .T., .T. )

       nValIR := IIF(T_IRRF->( EOF() ), 0, T_IRRF->VALOR_IRRF )

       If nValIR < 10
          nValIR := 0
       Endif
          
       // -------------------------- //
       // Pesquisa o valor do COFINS //
       // -------------------------- //      
       If Select("T_COFINS") > 0
          T_COFINS->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT E1_FILIAL ,"
       cSql += "       E1_PREFIXO,"
       cSql += "       E1_NUM    ,"
	   cSql += "       E1_TIPO   ,"
	   cSql += "       E1_NATUREZ," 
	   cSql += "       SUM(E1_VALOR) AS VALOR_COFINS"
       cSql += "  FROM " + RetSqlName("SE1")
       cSql += " WHERE E1_NUM     = '" + Alltrim((cAliasSF3)->F3_NFISCAL) + "'"
       cSql += "   AND E1_PREFIXO = '" + Alltrim((cAliasSF3)->F3_SERIE)   + "'"
       cSql += "   AND D_E_L_E_T_ = ''"
       cSql += "   AND E1_TIPO    = 'CF-'"
       cSql += " GROUP BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_TIPO, E1_NATUREZ"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COFINS", .T., .T. )

       nValCof := IIF(T_COFINS->( EOF() ), 0, T_COFINS->VALOR_COFINS )

       // ------------------------ //
       // Pesquisa o valor do CSLL //
       // ------------------------ //      
       If Select("T_CSLL") > 0
          T_CSLL->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT E1_FILIAL ,"
       cSql += "       E1_PREFIXO,"
       cSql += "       E1_NUM    ,"
	   cSql += "       E1_TIPO   ,"
	   cSql += "       E1_NATUREZ," 
	   cSql += "       SUM(E1_VALOR) AS VALOR_CSLL"
       cSql += "  FROM " + RetSqlName("SE1")
       cSql += " WHERE E1_NUM     = '" + Alltrim((cAliasSF3)->F3_NFISCAL) + "'"
       cSql += "   AND E1_PREFIXO = '" + Alltrim((cAliasSF3)->F3_SERIE)   + "'"
       cSql += "   AND D_E_L_E_T_ = ''"
       cSql += "   AND E1_TIPO    = 'CS-'"
       cSql += " GROUP BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_TIPO, E1_NATUREZ"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CSLL", .T., .T. )

       nValCSLL := IIF(T_CSLL->( EOF() ), 0, T_CSLL->VALOR_CSLL )

       // ----------------------- //
       // Pesquisa o valor do PIS //
       // ----------------------- //      
       If Select("T_PIS") > 0
          T_PIS->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT E1_FILIAL ,"
       cSql += "       E1_PREFIXO,"
       cSql += "       E1_NUM    ,"
	   cSql += "       E1_TIPO   ,"
	   cSql += "       E1_NATUREZ," 
	   cSql += "       SUM(E1_VALOR) AS VALOR_PIS"
       cSql += "  FROM " + RetSqlName("SE1")
       cSql += " WHERE E1_NUM     = '" + Alltrim((cAliasSF3)->F3_NFISCAL) + "'"
       cSql += "   AND E1_PREFIXO = '" + Alltrim((cAliasSF3)->F3_SERIE)   + "'"
       cSql += "   AND D_E_L_E_T_ = ''"
       cSql += "   AND E1_TIPO    = 'PI-'"
       cSql += " GROUP BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_TIPO, E1_NATUREZ"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PIS", .T., .T. )

       nValPis := IIF(T_PIS->( EOF() ), 0, T_PIS->VALOR_PIS )

       // ----- Fim da Nova regra

       // If (nValPIS + nValCof + nValCSLL) >= 10
           nValDed  := nValPIS + nValCof + nValCSLL + nValIR + nValINSS        
           nValLiq  := SF2->F2_VALBRUT - (nValPIS + nValCof + nValCSLL + nValIR + nValINSS)
       // Else
       //    nValPIS  := 0
       //    nValCof  := 0
       //    nValCSLL := 0
       //    nValDed  := nValIR + nValINSS                   
       //    nValLiq  := SF2->F2_VALBRUT - (nValIR + nValINSS)
       // Endif
        
		//nValBruto := SF2->F2_VALBRUT
		nValBruto := nValLiq

    	oPrint:Say(nLinha,0280,Transform( nValISS , cPictRet ),oFontA09)
		oPrint:Say(nLinha,0780,Transform( nValPis , cPictRet ),oFontA09)         
		oPrint:Say(nLinha,1080,Transform( nValCof , cPictRet ),oFontA09) 
		oPrint:Say(nLinha,1380,Transform( nValCSLL, cPictRet ),oFontA09) 
		oPrint:Say(nLinha,1680,Transform( nValIR  , cPictRet ),oFontA09) 
		oPrint:Say(nLinha,1980,Transform( nValINSS, cPictRet ),oFontA09)

//    	oPrint:Say(nLinha,0280,Transform( Iif( nValISS  > 0 .And. cRecIss == "1", nValISS, 0 ) , cPictRet ),oFontA09)
//		oPrint:Say(nLinha,0780,Transform( Iif( nValPis  > 0 .And. cRecPis == "S", nValPis, 0 ) , cPictRet ),oFontA09)         
//		oPrint:Say(nLinha,1080,Transform( Iif( nValCof  > 0 .And. cRecCof == "S", nValCof, 0 ) , cPictRet ),oFontA09) 
//		oPrint:Say(nLinha,1380,Transform( Iif( nValCSLL > 0 .And. cRecCsl == "S", nValCSLL, 0 ), cPictRet ),oFontA09) 
//		oPrint:Say(nLinha,1680,Transform( Iif( nValIR   > 0 .And. cRecIr == "1", nValIR, 0 )   , cPictRet ),oFontA09) 
//		oPrint:Say(nLinha,1980,Transform( Iif( nValINSS > 0 .And. cRecIns == "S", nValINSS, 0 ), cPictRet ),oFontA09)
 
    	nLinha += 40


/*
        cPictRet := PesqPict("SF3","F3_VALICM")
			
	    oPrint:Say(nLinha,250,Alltrim("ISS Ret.: "),oFontA09)
    	oPrint:Say(nLinha,920,Transform( Iif( nValISS > 0 .And. cRecIss == "1", nValISS, 0 ) , cPictRet ),oFontA09n)
    	nLinha += 45
		oPrint:Say(nLinha,250,"PIS:" ,oFontA09)
		oPrint:Say(nLinha,920,Transform( Iif( nValPis > 0 .And. cRecPis == "S", nValPis, 0 ) , cPictRet ),oFontA09n) 
    	nLinha += 45
		oPrint:Say(nLinha,250,"COFINS:" ,oFontA09)
		oPrint:Say(nLinha,920,Transform( Iif( nValCof > 0 .And. cRecCof == "S", nValCof, 0 ) , cPictRet ),oFontA09n) 
    	nLinha += 45
		oPrint:Say(nLinha,250,"CSLL:" ,oFontA09)
		oPrint:Say(nLinha,920,Transform( Iif( nValCSLL > 0 .And. cRecCsl == "S", nValCSLL, 0 ) , cPictRet ),oFontA09n) 
    	nLinha += 45
		oPrint:Say(nLinha,250,"IR Ret.:" ,oFontA09)
		oPrint:Say(nLinha,920,Transform( Iif( nValIR > 0 .And. cRecIr == "1", nValIR, 0 ) , cPictRet ),oFontA09n) 
    	nLinha += 45
		oPrint:Say(nLinha,250,"INSS Ret.:" ,oFontA09)
		oPrint:Say(nLinha,920,Transform( Iif( nValINSS > 0 .And. cRecIns == "S", nValINSS, 0 ) , cPictRet ),oFontA09n)
    	nLinha += 45

*/

        oPrint:Line(nLinha,nColIni,nLinha,nColFim)

    	nLinha += 20
			
		// Valores da prestacao de servicos
		If !lBhorizonte

           lMostra := .T.

           If nValLiq <= 0
              MsgAlert("Atenção!"                                     + chr(13) + chr(10) + chr(13) + chr(10) + ;
                       "Valor total do documento está inconsistente." + chr(13) + chr(10) + ;
                       "Tente emitir novamente."                      + chr(13) + chr(10) + ;
                       "Se persistir esta inconsistência, entre em contato com a área de projetos.")
              lMostra := .F.
              Exit
           Else
              lMostra := .T.              
           Endif

		    oPrint:Say(nLinha,0930,"VALOR TOTAL DA PRESTAÇÃO DE SERVIÇO",oFontA10) 
	      //oPrint:Say(1885,1700,"R$ " + Transform(nVlContab,"@E 999,999,999.99"),oFont10)

            nLinha += 5
            
			oPrint:Say(nLinha,1850,"R$ " + Transform(nValBruto,"@E 999,999,999.99") )
		    //oPrint:Say(nLinha,1850,"R$ " + _BuscaDados(SC5->C5_NUM,(cAliasSF3)->F3_NFISCAL,2))
		    //Transform(nValLiq,"@E 999,999,999.99"),oFontA10n)

            nLinha += 70

		    oPrint:Line(nLinha,nColIni,nLinha,nColFim)

            nLinha += 40

		EndIf 
			
		If lRecife

            // Código do Serviço
//			oPrint:Say(nLinha,250,Alltrim(STR0043),oFontA10n) 
            nLinha += 40
			oPrint:Say(nLinha,250,Alltrim(cCodAtiv),oFont10)
            nLinha += 50
            
		ElseIf lBhorizonte

            // Código do Serviço
//			oPrint:Say(nLinha,250,Alltrim(STR0043),oFontA10n) 
			oPrint:Say(nLinha,950,Alltrim(cCodServ),oFont10)			
            nLinha += 50

		Else
            // Código do Serviço
//			oPrint:Say(nLinha,250,Alltrim(STR0031),oFontA10n) 
            nLinha += 40
			oPrint:Say(nLinha,250,Alltrim(cCodServ),oFont10)
            nLinha += 50
		EndIf

		If lBhorizonte
		    oPrint:Line(nLinha,nColIni,nLinha,nColFim)
		Else
		    oPrint:Line(nLinha,nColIni,nLinha,nColFim)
		EndIf   

		If lRioJaneiro
    	   oPrint:Line(nLinha,632,nLinha,632)
	 	   oPrint:Line(nLinha,979,nLinha,979)
	   	   oPrint:Line(nLinha,1446,nLinha,1446)    
	  	   oPrint:Line(nLinha,1736,nLinha,1736)    

   	       nLinha += 15
                
//		   oPrint:Say(nLinha,0250,Alltrim(STR0032),oFontA09n) // "Total deduções (R$)"
//	       oPrint:Say(nLinha,0647,Alltrim(STR0044),oFontA09n) // "Desc.Incond. (R$)"
//	       oPrint:Say(nLinha,1014,Alltrim(STR0033),oFontA09n) // "Base de cálculo (R$)"
//	       oPrint:Say(nLinha,1484,Alltrim(STR0034),oFontA09n) // "Alíquota (%)"
//	       oPrint:Say(nLinha,1791,Alltrim(STR0035),oFontA09n) // "Valor do ISS (R$)"

   	       nLinha += 40
   	       
	       oPrint:Say(nLinha,0320,Transform(nValDed    ,"@E 999,999,999.99"),oFontA09)        
	       oPrint:Say(nLinha,0667,Transform(nDescIncond,"@E 999,999,999.99"),oFontA09)
	       oPrint:Say(nLinha,1134,Transform((cAliasSF3)->F3_BASEICM,"@E 999,999,999.99"),oFontA09)
	       oPrint:Say(nLinha,1584,Transform((cAliasSF3)->F3_ALIQICM,"@E 999.99"),oFontA09)
	       oPrint:Say(nLinha,1881,Transform((cAliasSF3)->F3_VALICM,"@E 999,999,999.99"),oFontA09)

   	       nLinha += 45

	       oPrint:Line(nLinha,nColIni,nLinha,nColFim)

		ElseIf lBhorizonte 
		   oPrint:Say(nLinha,0250,Alltrim("Valor dos serviços: "),oFontA09n) // "Valor dos serviços"
	       oPrint:Say(nLinha,0920,Transform(nVlContab,"@E 999,999,999.99"),oFontA09)        
   		   oPrint:Say(nLinha,1250,Alltrim("Valor dos serviços: "),oFontA09n) // "Valor dos serviços"
	       oPrint:Say(nLinha,1870,Transform(nVlContab,"@E 999,999,999.99"),oFontA09)        

           nLinha += 50

		   oPrint:Say(nLinha,0250,Alltrim("(-)Descontos: "),oFontA09n) // "Descontos"
	       oPrint:Say(nLinha,0920,Transform(nValDesc,"@E 999,999,999.99"),oFontA09)        
   		   oPrint:Say(nLinha,1250,Alltrim("(-)Deduçoes: "),oFontA09n) // "Deduções"
	       oPrint:Say(nLinha,1870,Transform(nValDed,"@E 999,999,999.99"),oFontA09)        

           nLinha += 50
           
		   oPrint:Say(nLinha,0250,Alltrim("(-)Ret.Federais: "),oFontA09n) // "Ret.Federais"
	       oPrint:Say(nLinha,0920,Transform(nRetFeder,"@E 999,999,999.99"),oFontA09)        
   		   oPrint:Say(nLinha,1250,Alltrim("(-)Desc.Incond.: "),oFontA09n) // "Desc.Incod"
	       oPrint:Say(nLinha,1870,Transform(nDescIncond,"@E 999,999,999.99"),oFontA09)        
           
           nLinha += 50
           
		   oPrint:Say(nLinha,0250,Alltrim("(-)ISS Ret.: "),oFontA09n) // "ISS Ret."
	       oPrint:Say(nLinha,0920,Transform(IIf(cRecIss=="1",nValISS,0),"@E 999,999,999.99"),oFontA09)        
   		   oPrint:Say(nLinha,1250,Alltrim("(=)Base Cálc.: "),oFontA09n) // "Base Cálc."
	       oPrint:Say(nLinha,1870,Transform((cAliasSF3)->F3_BASEICM,"@E 999,999,999.99"),oFontA09)        
           
           nLinha += 50
           
		   oPrint:Say(nLinha,250,Alltrim("Valor Liq.: "),oFontA09n) // "Valor Liq."
	       oPrint:Say(nLinha,920,Transform(nValLiq,"@E 999,999,999.99"),oFontA09)        
   		   oPrint:Say(nLinha,1250,Alltrim("Alíquota: "),oFontA09n) // "Alíquota"
	       oPrint:Say(nLinha,1988,Transform((cAliasSF3)->F3_ALIQICM,"@E 999.99"),oFontA09)        
           
           nLinha += 50

   		   oPrint:Say(nLinha,1250,Alltrim("(=)Valor ISS: "),oFontA09n) // "Valor ISS"
	       oPrint:Say(nLinha,1870,Transform((cAliasSF3)->F3_VALICM,"@E 999,999,999.99"),oFontA09)        

           nLinha += 60

		   oPrint:Say(nLinha,0250,"PIS:" ,oFontA09)
		   oPrint:Say(nLinha,0285,Transform(nValPis ,PesqPict("SF3","F3_VALICM")),oFontA09) 
   		   oPrint:Say(nLinha,0630,"COFINS:" ,oFontA09)
		   oPrint:Say(nLinha,0660,Transform(nValCof ,PesqPict("SF3","F3_VALICM")),oFontA09) 
		   oPrint:Say(nLinha,1005,"IR:" ,oFontA09)
		   oPrint:Say(nLinha,1035,Transform(nValIR  ,PesqPict("SF3","F3_VALICM")),oFontA09) 
		   oPrint:Say(nLinha,1380,"CSLL:" ,oFontA09)
		   oPrint:Say(nLinha,1410,Transform(nValCSLL,PesqPict("SF3","F3_VALICM")),oFontA09) 
		   oPrint:Say(nLinha,1755,"INSS:" ,oFontA09)
		   oPrint:Say(nLinha,1785,Transform(nValINSS,PesqPict("SF3","F3_VALICM")),oFontA09)

           nLinha += 70

//		   oPrint:Say(nLinha,nColIni,PadC(Alltrim(STR0036),75),oFontA10n) // "INFORMAÇÕES SOBRE A NOTA FISCAL ELETRÔNICA"

           nLinha += 70
           
		   oPrint:Line(nLinha,nColIni,nLinha,nColFim)
		   oPrint:Line(nLinha,0712,nLinha,0712)
		   oPrint:Line(nLinha,1070,nLinha,1070)
		   oPrint:Line(nLinha,1686,nLinha,1686)

           nLinha += 20

		   oPrint:Say(nLinha,250,Alltrim("Número do RPS"),oFontA09n) // "Número"
//		   oPrint:Say(nLinha,737,Alltrim(STR0038),oFontA09n) // "Emissão"
//		   oPrint:Say(nLinha,1094,Alltrim(STR0039),oFontA09n) // "Código Verificação"
//		   oPrint:Say(nLinha,1711,Alltrim(STR0040),oFontA09n) // "Crédito IPTU"
		   		             
           nLinha += 40		   		   
		   		   
  		   //oPrint:Say(2440,370,Padl(StrZero(Year((cAliasSF3)->F3_EMISSAO),4)+"/"+(cAliasSF3)->F3_NFELETR,14),oFontA09) 
		   oPrint:Say(nLinha,0370,(cAliasSF3)->F3_DOC+"/"+(cAliasSF3)->F3_SERIE,oFontA09)
		   oPrint:Say(nLinha,0757,Padl(Transform(dToC((cAliasSF3)->F3_EMINFE),"@d"),14),oFontA09)
		   oPrint:Say(nLinha,1144,Padl((cAliasSF3)->F3_CODNFE,24),oFontA09)
		   oPrint:Say(nLinha,1831,Transform((cAliasSF3)->F3_CREDNFE,"@E 999,999,999.99"),oFontA09)
                      
           nLinha += 60
           
		   oPrint:Line(nLinha,nColIni,nLinha,nColFim)
				
           nLinha += 50

		   For nY := 1 to Len(aPrintObs)
		  	   If nY > 11
				  Exit
			   Endif
			   oPrint:Say(nLinha,250,Alltrim(aPrintObs[nY]),oFontA09)
			   nLinha 	:= nLinha + 50
		   Next
               			
		Else

  		   oPrint:Line(nLinha,0712,nLinha + 100,0712)
    	   oPrint:Line(nLinha,1199,nLinha + 100,1199)
	       oPrint:Line(nLinha,1686,nLinha + 100,1686)    

           nLinha += 15

		   oPrint:Say(nLinha,0250,"Total deduções (R$)" ,oFontA10n) // "Total deduções (R$)(Iss+Fed)"
		   oPrint:Say(nLinha,0737,"Base de cálculo (R$)",oFontA10n) // "Base de cálculo (R$)"
		   oPrint:Say(nLinha,1224,"Alíquota (%)"        ,oFontA10n) // "Alíquota (%)"
		   oPrint:Say(nLinha,1711,"Valor do ISS (R$)"   ,oFontA10n) // "Valor do ISS (R$)"

//		   oPrint:Say(nLinha,0250,Alltrim(STR0032),oFontA10n) // "Total deduções (R$)(Iss+Fed)"
//		   oPrint:Say(nLinha,0737,Alltrim(STR0033),oFontA10n) // "Base de cálculo (R$)"
//		   oPrint:Say(nLinha,1224,Alltrim(STR0034),oFontA10n) // "Alíquota (%)"
//		   oPrint:Say(nLinha,1711,Alltrim(STR0035),oFontA10n) // "Valor do ISS (R$)"

           nLinha += 40

//	       oPrint:Say(nLinha,0370,Transform(nValDed + nRetFeder,"@E 999,999,999.99"),oFontA10)

	       oPrint:Say(nLinha,0370,Transform(nValDed,"@E 999,999,999.99"),oFontA10)

		   oPrint:Say(nLinha,0857,Iif(lJoinville,Transform(nValBase,"@E 999,999,999.99"),Transform((cAliasSF3)->F3_BASEICM,"@E 999,999,999.99")),oFontA10)
		   oPrint:Say(nLinha,1344,Iif(lJoinville,Transform(nAliquota,"@E 999,999,999.99"),Transform((cAliasSF3)->F3_ALIQICM,"@E 999,999,999.99")),oFontA10)
		   oPrint:Say(nLinha,1831,Transform((cAliasSF3)->F3_VALICM,"@E 999,999,999.99"),oFontA10)

           nLinha += 45
           
		   oPrint:Line(nLinha,nColIni,nLinha,nColFim)

           nLinha += 20

	    EndIf

        If !lBhorizonte

           // INFORMAÇÕES SOBRE A NOTA FISCAL ELETRÔNICA
		   oPrint:Say(nLinha,0250,"INFORMAÇÕES SOBRE A NOTA FISCAL ELETRÔNICA",oFontA12n) 
                      
           nLinha += 80

		   oPrint:Line(nLinha,nColIni,nLinha,nColFim)

		   oPrint:Line(nLinha,0712,nLinha + 100,0712)
		   oPrint:Line(nLinha,1070,nLinha + 100,1070)
		   oPrint:Line(nLinha,1686,nLinha + 100,1686)

           nLinha += 15

		   oPrint:Say(nLinha,0250,"Número" + "/RPS"   ,oFontA10n) // "Número"
		   oPrint:Say(nLinha,0737,"Emissão"           ,oFontA10n) // "Emissão"
		   oPrint:Say(nLinha,1094,"Código Verificação",oFontA10n) // "Código Verificação"
		   oPrint:Say(nLinha,1711,"Crédito IPTU (R$)" ,oFontA10n) // "Crédito IPTU"


//		   oPrint:Say(nLinha,0250,Alltrim(STR0037)+"/RPS",oFontA10n) // "Número"
//		   oPrint:Say(nLinha,0737,Alltrim(STR0038),oFontA10n)        // "Emissão"
//		   oPrint:Say(nLinha,1094,Alltrim(STR0039),oFontA10n)        // "Código Verificação"
//		   oPrint:Say(nLinha,1711,Alltrim(STR0040),oFontA10n)        // "Crédito IPTU"
		   
           nLinha += 40
           
		   oPrint:Say(nLinha,0370,Padl(StrZero(Year((cAliasSF3)->F3_EMISSAO),4)+"/"+(cAliasSF3)->F3_NFISCAL,14),oFontA10)
		   oPrint:Say(nLinha,0757,Padl(Transform(dToC((cAliasSF3)->F3_EMINFE),"@d"),14),oFontA10)
		   oPrint:Say(nLinha,1144,Padl((cAliasSF3)->F3_CODNFE,24),oFontA10)
		   oPrint:Say(nLinha,1831,Transform((cAliasSF3)->F3_CREDNFE,"@E 999,999,999.99"),oFontA10)

           nLinha += 45

		   oPrint:Line(nLinha,nColIni,nLinha,nColFim)
		   
           nLinha += 13
				
		   // Outras Informações
		   oPrint:Say(nLinha,0250,"OUTRAS INFORMAÇÕES",oFontA12n) // "OUTRAS INFORMAÇÕES"

           nLinha += 50
		   oPrint:Line(nLinha,nColIni,nLinha,nColFim)
           nLinha += 50

		   For nY := 1 to Len(aPrintObs)
		       If nY > 11
				  Exit
			   Endif
               
               __Observacao := Strtran(aPrintObs[nY], Chr(10), " ")
//             __Observacao := Strtran(aPrintObs[nY], "#", "")               

			   oPrint:Say(nLinha,250,Alltrim(__Observacao),oFont10)
			   nLinha 	:= nLinha + 50
		   Next     
		
		   // Adicionado Michel Aoki - 09/03
		   oPrint:Say(nLinha,250,Alltrim(cTotImp),oFont10)
		   nLinha 	:= nLinha + 50

           // Imprime o parcelamento
           If Select("T_PARCELAS") > 0
              T_PARCELAS->( dbCloseArea() )
           EndIf

           cSql := ""
           cSql := "SELECT SE1.E1_NUM    ,"
           cSql += "       SE1.E1_PREFIXO,"
           cSql += "       SE1.E1_PARCELA,"
           cSql += "       SE1.E1_VENCREA,"
//         cSql += "      (SE1.E1_VALOR - SE1.E1_IRRF - SE1.E1_COFINS - SE1.E1_PIS - SE1.E1_CSLL) AS VALOR,"
           cSql += "       SE1.E1_VALOR AS VALOR,"
           cSql += "      (SELECT F2_COND "  
           cSql += "         FROM " + RetSqlName("SF2")
           cSql += "        WHERE F2_DOC   = SE1.E1_NUM" 
           cSql += "          AND F2_SERIE = SE1.E1_PREFIXO "
           cSql += "          AND D_E_L_E_T_ = '') AS CONDICAO,"
           cSql += "      (SELECT E4_DESCRI"
	       cSql += "         FROM " + RetSqlName("SE4")
      	   cSql += "        WHERE E4_CODIGO = (SELECT F2_COND"
		   cSql += "                             FROM " + RetSqlName("SF2")
		   cSql += "			                WHERE F2_DOC   = SE1.E1_NUM" 
		   cSql += "					          AND F2_SERIE = SE1.E1_PREFIXO "
		   cSql += "					          AND D_E_L_E_T_ = '')"
		   cSql += "          AND D_E_L_E_T_ = '') AS DESCRICAO"
           cSql += "  FROM " + RetSqlName("SE1") + " SE1 "
           cSql += " WHERE SE1.E1_NUM     = '" + Alltrim((cAliasSF3)->F3_NFISCAL) + "'"
           cSql += "   AND SE1.E1_PREFIXO = '" + Alltrim((cAliasSF3)->F3_SERIE)   + "'"
           cSql += "   AND SE1.E1_TIPO    = 'NF'"
           cSql += "   AND SE1.D_E_L_E_T_ = ''"

           cSql := ChangeQuery( cSql )
           dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARCELAS", .T., .T. )

           T_PARCELAS->( DbGoTop() )

           // Calcula o valor total das deduções
//           aAbatimento := {}
//           aAbatimento := CalcAbaServico()
//
//           nValor_Deducao := 0
// 
//           For nLaco = 1 to Len(aAbatimento)
//               nValor_Deducao := nValor_Deducao + aAbatimento[01,01] + aAbatimento[01,02] + aAbatimento[01,03] + aAbatimento[01,04] + aAbatimento[01,05]
//           Next nLaco
//
//           If nValor_Deducao < 10
//              nValor_Deducao := 0
//           Endif
           
           // Calcula o valor total do abatimento
           nValor_Deducao := 0
           nValor_Deducao := xSAbatimento()

           //If nValor_Deducao < 10
           //   nValor_Deducao := 0
           //Endif

           If !T_PARCELAS->( EOF() )

			   nLinha 	:= nLinha + 50
			   oPrint:Say(nLinha,250,"Condição de Pagamento:" + Alltrim(T_PARCELAS->DESCRICAO),oFont10)
			   nLinha 	:= nLinha + 50

               WHILE !T_PARCELAS->( EOF() )

                  If nValor_Deducao == 0
                     nValor_Parcela := T_PARCELAS->VALOR                  
                  Else
                     Do Case
                        Case Empty(Alltrim(T_PARCELAS->E1_PARCELA))
                             nValor_Parcela := T_PARCELAS->VALOR - nValor_Deducao
                        Case INT(VAL(T_PARCELAS->E1_PARCELA)) == 1
                             nValor_Parcela := T_PARCELAS->VALOR - nValor_Deducao
                        Otherwise
                             nValor_Parcela := T_PARCELAS->VALOR
                     EndCase
                  Endif

//			      oPrint:Say(nLinha,250,"Vencimento: " + Substr(T_PARCELAS->E1_VENCREA,07,02) + "/" + ;
//			                                             Substr(T_PARCELAS->E1_VENCREA,05,02) + "/" + ;
//			                                             Substr(T_PARCELAS->E1_VENCREA,01,04) + " " + ;
//			                                            "Valor R$ " + TRANSFORM(T_PARCELAS->VALOR, "@E 999,999.99"),oFont10)

			      oPrint:Say(nLinha,250,"Vencimento: " + Substr(T_PARCELAS->E1_VENCREA,07,02) + "/" + ;
			                                             Substr(T_PARCELAS->E1_VENCREA,05,02) + "/" + ;
			                                             Substr(T_PARCELAS->E1_VENCREA,01,04) + " " + ;
			                                             "Valor da parcela: " + TRANSFORM(nValor_Parcela, "@E 999,999.99"),oFont10)
			                                             //"Valor da parcela: " + TRANSFORM(nValor_Parcela, "@E 999,999.99"),oFont10)
			      nLinha	+= 50				
			      
			      oPrint:Say(nLinha,250,"Valor Liquido R$ " + TRANSFORM(nValLiq, "@E 999,999.99"), oFontA10)

			      nLinha 	:= nLinha + 25
                  T_PARCELAS->( DbSkip() )

              ENDDO
                  
           Endif

	       nLinha := nLinha + 120

           If cFilAnt == "05"
           Else
     	      oPrint:Say(nLinha,250,"A autenticidade desta Nota Fiscal Fatura de Serviços Eletrônica - NFFS-e pode ser verificada no portal do Município no endereço:",oFontA09)
     	   Endif   
	       nLinha := nLinha + 50

           // #################################################################
           // Imprime o link a ser acessado para consulta da nota fiscal/rps ##
           // #################################################################
           Do Case         
           
              // ##########################
              // Empresa 01 - Automatech ##
              // ##########################
              Case cEmpAnt == "01"

                   Do Case
         
                      // ###########################
                      // Filial 01 - Porto alegre ##
                      // ###########################
                      Case cFilant == "01"              
            	           oPrint:Say(nLinha,250,"https://nfe-portoalegre.rs.gov.br/nfse/pages/consultaNFS-e_cidadao.jsf",oFontA09)
     	                   nLinha := nLinha + 50
       	                   oPrint:Say(nLinha,250,"CNPJ: " + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")     + "     " + ;
   	                                             "Nº da NFs: " + Substr((cAliasSF3)->F3_NFELETR,01,04) + "/" + Substr((cAliasSF3)->F3_NFELETR,05) + "     " + ;
                                                 "Código Verificação: " + Padl((cAliasSF3)->F3_CODNFE,24),oFontA09n)

                      // ############################
                      // Filial 02 - Caxias do Sul ##
                      // ############################
                      Case cFilant == "02"              
         	               oPrint:Say(nLinha,250,"https://nfse.caxias.rs.gov.br/portal/consulta.jspx?nf=0",oFontA09)
 	                       nLinha := nLinha + 50
        	               oPrint:Say(nLinha,250,"Chave de Acesso: " + "43-"      + ;
       	                                         SM0->M0_CGC                     + ;
       	                                         "-98-"                          + ;
       	                                         "S00-"                          + ;
                                                 "000" + Alltrim(Padl((cAliasSF3)->F3_NFISCAL,9)) + "/" + ;
                                                 "000" + Alltrim(Padl((cAliasSF3)->F3_NFISCAL,9)),oFontA09n)

                      // ######################
                      // Filial 03 - Pelotas ##
                      // ######################
                      Case cFilant == "03"              
        	               oPrint:Say(nLinha,250,"http://pelotas.ginfes.com.br/",oFontA09)
 	                       nLinha := nLinha + 50
        	               oPrint:Say(nLinha,250,"Nº NFS-e: " + Padl((cAliasSF3)->F3_NFELETR,14)          + "     " + ;
                                                 "Código Verificação: " + Padl((cAliasSF3)->F3_CODNFE,24) + "     " + ;
                                                 "CNPJ Prestador: " + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),oFontA09n)

                   EndCase

              // #####################
              // Empresa 03 - Atech ##
              // #####################
              Case cEmpAnt == "03"
        	       oPrint:Say(nLinha,250,"https://nfe-portoalegre.rs.gov.br/nfse/pages/consultaNFS-e_cidadao.jsf",oFontA09)
     	           nLinha := nLinha + 50
       	           oPrint:Say(nLinha,250,"CNPJ: " + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")     + "     " + ;
   	                                     "Nº da NFs: " + StrZero(Year((cAliasSF3)->F3_EMISSAO),4) + "/" + (cAliasSF3)->F3_NFELETR + "     " + ;
                                         "Código Verificação: " + Padl((cAliasSF3)->F3_CODNFE,24),oFontA09n)

           EndCase

		   // Adicionado Michel Aoki - 09/03
//		   oPrint:Say(nLinha,250,Alltrim(cTotImp),oFont10)
			
		   nLinha += 50		  
				
//		   oPrint:Line(nLinha,nColIni,nLinha,nColFim)
	
        EndIF
			
		If nCopias > 1 .And. nX < nCopias
		   oPrint:EndPage()
		Endif
			
	Next
		
	(cAliasSF3)->(dbSkip())
		
	If !((cAliasSF3)->(Eof()))  
	   oPrint:EndPage()
	Endif

   Enddo
	
EndIf
                            
If !lQuery
	RetIndex("SF3")	
	dbClearFilter()	
	Ferase(cArqInd+OrdBagExt())
Else
	dbSelectArea(cAliasSF3)
	dbCloseArea()
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTR948Str ºAutor  ³Mary Hergert        º Data ³ 03/08/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Montar o array com as strings a serem impressas na descr.   º±±
±±º          ³dos servicos e nas observacoes.                             º±±
±±º          ³Se foi uma quebra forcada pelo ponto de entrada, e          º±±
±±º          ³necessario manter a quebra. Caso contrario, montamos a linhaº±± 
±±º          ³de cada posicao do array a ser impressa com o maximo de     º±±
±±º          ³caracteres permitidos.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Array com os campos da query                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cString: string completa a ser impressa                     º±±
±±º          ³nLinhas: maximo de linhas a serem impressas                 º±±
±±º          ³nTotStr: tamanho total da string em caracteres              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MATR968                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function Mtr968Mont(cString,nLinhas,nTotStr)

Local aAux		:= {}
Local aPrint	:= {}

Local cMemo 	:= ""
Local cAux		:= ""

Local nX		:= 1
Local nY 		:= 1
Local nPosi		:= 1

cString := SubStr(cString,1,nTotStr)

For nY := 1 to Min(MlCount(cString,86),nLinhas)

	cMemo := MemoLine(cString,86,nY) 
			
	// Monta a string a ser impressa ate a quebra
	Do While .T.
		nPosi 	:= At("|",cMemo)
		If nPosi > 0
			Aadd(aAux,{SubStr(cMemo,1,nPosi-1),.T.})
			cMemo 	:= SubStr(cMemo,nPosi+1,Len(cMemo))
		Else    
			If !Empty(cMemo)
				Aadd(aAux,{cMemo,.F.})
			Endif
			Exit
		Endif	
	Enddo
Next            
		
For nY := 1 to Len(aAux)
	cMemo := ""
	If aAux[nY][02]   
		Aadd(aPrint,aAux[nY][01])
	Else
		cMemo += Alltrim(aAux[nY][01]) + Space(01)
		Do While !aAux[nY][02]
			nY += 1  
			If nY > Len(aAux)
				Exit
			Endif
			cMemo += Alltrim(aAux[nY][01]) + Space(01)
		Enddo
		For nX := 1 to Min(MlCount(cMemo,86),nLinhas)
			cAux := MemoLine(cMemo,86,nX) 
		   	Aadd(aPrint,cAux)
		Next
	Endif                            
Next   

Return(aPrint)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AjustaSX1 ³ Autor ³ Mary C. Hergert       ³ Data ³05/07/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria as perguntas necessarias a impressao do RPS            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATR968                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1()
Local 	aAreaSX1	:= SX1->(GetArea())

SX1->(dbSetOrder(1))
If SX1->(dbSeek("MTR968    05")) 
	If SX1->X1_TAMANHO <> TamSx3("F3_NFISCAL")[1]
    	RecLock("SX1",.F.)
		SX1->X1_TAMANHO := TamSx3("F3_NFISCAL")[1]
    	SX1->(MSUnlock())
	Endif
Endif

If SX1->(dbSeek("MTR968    06")) 
	If SX1->X1_TAMANHO <> TamSx3("F3_NFISCAL")[1]
    	RecLock("SX1",.F.)
	    SX1->X1_TAMANHO := TamSx3("F3_NFISCAL")[1]
    	SX1->(MSUnlock())
	Endif
Endif

RestArea(aAreaSX1)                   
Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M968Discri³ Autor ³Alexandre Inacio Lemes ³ Data ³27/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta um array com a string quebrada em linhas com o tamanho³±±
±±³          ³da capacidade de impressao da linha utilizado RPS Sorocaba  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATR968                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function M968Discri(cString,nLinhas,nTotStr)

Local aAux		:= {}
Local aPrint	:= {}

Local cMemo 	:= ""
Local cAux		:= ""

Local nX		:= 1
Local nY 		:= 1
Local nPosi		:= 1

cString := SubStr(cString,1,nTotStr)

For nY := 1 to Min(MlCount(cString,130),nLinhas)

	cMemo := MemoLine(cString,130,nY) 
			
	// Monta a string a ser impressa ate a quebra
	Do While .T.
		nPosi 	:= At("|",cMemo)
		If nPosi > 0
			Aadd(aAux,{SubStr(cMemo,1,nPosi-1),.T.})
			cMemo 	:= SubStr(cMemo,nPosi+1,Len(cMemo))
		Else    
			If !Empty(cMemo)
				Aadd(aAux,{cMemo,.F.})
			Endif
			Exit
		Endif	
	Enddo
Next            
		
For nY := 1 to Len(aAux)
	cMemo := ""
	If aAux[nY][02]   
		Aadd(aPrint,aAux[nY][01])
	Else
		cMemo += Alltrim(aAux[nY][01]) + Space(01)
		Do While !aAux[nY][02]
			nY += 1  
			If nY > Len(aAux)
				Exit
			Endif
			cMemo += Alltrim(aAux[nY][01]) + Space(01)
		Enddo
		For nX := 1 to Min(MlCount(cMemo,130),nLinhas)
			cAux := MemoLine(cMemo,130,nX) 
		   	Aadd(aPrint,cAux)
		Next
	Endif                            
Next   

Return(aPrint)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PrintBox  ³ Autor ³Alexandre Inacio Lemes ³ Data ³27/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para "ENGROSSAR" a espessura das linhas do BOX atrave³±±
±±³          ³s do deslocamento dos pixels pelo for next                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATR968                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrintBox(nPosY,nPosX,nAltura,nTamanho)

Local nX := 0

For nX := 1 To 5
	oPrint:Box(nPosY+nX,nPosX+nX,nAltura+nX,nTamanho+nX)
Next nX

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PrintLine ³ Autor ³Alexandre Inacio Lemes ³ Data ³27/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para "ENGROSSAR" a espessura das linhas do PrintLine ³±±
±±³          ³Atraves do deslocamento dos pixels pelo for next            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATR968                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrintLine(nPosY,nPosX,nAltura,nTamanho)

Local nX := 0

For nX := 1 To 5
	oPrint:Line(nPosY+nX,nPosX+nX,nAltura+nX,nTamanho+nX)
Next nX

Return

 
//Michel Aoki 
//Observação da nota

Static Function _ObsPv(_xPedido)
	  
	  Local _aArea   := GetArea()
	  Local _aRetObs  := {}
	  Local cMensagem := ""
	  Local cNumeroOS := ""
	  // Impressão da mensagem da nota.
	  cQuery := {}
	  cQuery := " SELECT CAST( CAST(C5_MENNOTA AS VARBINARY(1024)) AS VARCHAR(1024)) AS OBSERVA,"
	  cQuery += " CAST( CAST(C5_OBSNT AS VARBINARY(1024)) AS VARCHAR(1024)) AS OBSERVA2,"
      cQuery += "       (SELECT DISTINCT SUBSTRING(C6_NUMORC,01,06)"
      cQuery += "          FROM " + RetSqlName("SC6")
      cQuery += "         WHERE C6_FILIAL  = C5_FILIAL" 
      cQuery += "           AND C6_NUM     = C5_NUM"
      cQuery += "           AND C6_NUMORC <> ''"
      cQuery += "           AND D_E_L_E_T_ = '') AS NUMEROOS"  
      cQuery += "   FROM " + RETSQLNAME("SC5")
	  cQuery += "  WHERE C5_NUM    = '" + Alltrim(_Xpedido) + "'"
	  cQuery += "    AND C5_FILIAL = '" + xFilial("SC5") + "'"
	  cQuery += "    AND D_E_L_E_T_ <> '*'"

 	  cQuery := ChangeQuery(cQuery)
	  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TSC5",.T.,.T.)
	
	  DbSelectArea("TSC5")
      cNumeroOs := Alltrim(TSC5->NUMEROOS)
	  cMensagem := Alltrim(TSC5->OBSERVA) + " "  
	  if !empty(alltrim(TSC5->OBSERVA2))
			cMensagem += (AllTrim(TSC5->OBSERVA2) + " ")
	  endif
	  DbSelectArea("TSC5")
	  DbCloseArea()               
 
      If Empty(Alltrim(cMensagem))
         If Empty(Alltrim(cNumeroOS))
            cMensagem +=  "PEDIDO NR. " + Alltrim(_Xpedido)
         Else   
            cMensagem +=  "OS NR. " + Alltrim(cNumeroOS) + " - " + "PEDIDO NR. " + Alltrim(_Xpedido)
         Endif   
      Else
         If !Empty(Alltrim(cNumeroOS))
            cMensagem +=  "OS NR. " + Alltrim(cNumeroOS) + " - " + cMensagem
         Endif   
      Endif
	
		 
	 RestArea(_aArea)

Return(cMensagem)


//Adicionado Michel Aoki - Lei Transparência

Static Function _Transparencia(_cDesc,_nTotal)

   Local _cMensTransp := ""
   Local _nAproximado := 0	
         
   // Pesquisa as naturezas de serviços e seus Percentuais para cálculo dos impostos aproximados para impressão
   If Select("T_ALIQUOTAS") > 0
      T_ALIQUOTAS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4.ZZ4_NATT, "
   cSql += "      (SELECT EL0_ALIQIM FROM EL0010 WHERE EL0_COD = ZZ4.ZZ4_NATT AND D_E_L_E_T_ = '') AS PRC_TEC,"
   cSql += "       ZZ4.ZZ4_NATP, " 
   cSql += "      (SELECT EL0_ALIQIM FROM EL0010 WHERE EL0_COD = ZZ4.ZZ4_NATP AND D_E_L_E_T_ = '') AS PRC_PRO,"
   cSql += "       ZZ4_NATA    , "    
   cSql += "      (SELECT EL0_ALIQIM FROM EL0010 WHERE EL0_COD = ZZ4.ZZ4_NATA AND D_E_L_E_T_ = '') AS PRC_AGE "
   cSql += "  FROM " + RetSqlName("ZZ4") + " ZZ4 "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ALIQUOTAS", .T., .T. )

   If !T_ALIQUOTAS->( EOF() )
      cPrcTecnica := T_ALIQUOTAS->PRC_TEC
      cPrcProjeto := T_ALIQUOTAS->PRC_PRO
      cPrcAgencia := T_ALIQUOTAS->PRC_AGE
   Endif

   If Empty(Alltrim(T_ALIQUOTAS->ZZ4_NATT))
      MsgAlert("Atenção! Naturezas de Serviços de Assistência Técnica não parametrizada no Parametrizador Automatech. Verifique!")
      Return("")
   Endif
      
   If Empty(Alltrim(T_ALIQUOTAS->ZZ4_NATP))
      MsgAlert("Atenção! Naturezas de Serviços de Projetos não parametrizado no Parametrizador Automatech. Verifique!")
      Return("")
   Endif

   If Empty(Alltrim(T_ALIQUOTAS->ZZ4_NATA))
      MsgAlert("Atenção! Naturezas de Serviços de Agenciamento não parametrizado no Parametrizador Automatech. Verifique!")
      Return("")
   Endif

		 
		 
 // Calcula o valor aproximado dos tributos para impressão da nota fiscal
           
    // Em caso do produto ser serviço de Assistência Técnica
    If Substr(_cDesc,01,03) == "AST" .Or. Substr(_cDesc,01,05) == "CONTR" .Or. Substr(_cDesc,01,04) == "BEMA" .Or. Substr(_cDesc,01,04) == "OUTR";
    	 .Or. Substr(_cDesc,01,03) == "SUP"
        _nAproximado := _nAproximado + Round(((_nTotal * cPrcTecnica) / 100),2)
    Endif
              
    // Em caso do produto ser serviço de Projetos
    If Substr(_cDesc,01,03) == "PRJ"
        _nAproximado := _nAproximado + Round(((_nTotal * cPrcProjeto) / 100),2)
    Endif

    // Em caso do produto ser serviço de Agenciamento - Comissão
    If Substr(_cDesc,01,12) == "AGENCIAMENTO" .Or. Substr(_cDesc,01,08) == "COMISSAO"
       _nAproximado := _nAproximado + Round(((_nTotal * cPrcAgencia) / 100),2)
    Endif

    If _nAproximado > 0
		_cMensTransp:= "Valor Aproximado dos Tributos: R$ " + Alltrim(Transform(_nAproximado, "@E 999,999,999.99")) + "   Fonte: IBPT"
	ENDIF
			
	T_ALIQUOTAS->( dbCloseArea() )
			
Return(_cMensTransp)



 
Static Function _BuscaDados(_cNumPV,_cDoc,_nOpc)

Local _cRetorno := ""
Local _nCont    := 0

_cQuery := " SELECT C6_DESCRI, C6_VALOR FROM " +RetSqlName('SC6')
_cQuery += " where C6_NUM = '"+alltrim(_cNumPV)+"' "
_cQuery += " AND   C6_FILIAL =  '"+alltrim(xFilial("SC6"))+"' "
_cQuery += " AND C6_NOTA = '"+alltrim(_cDoc)+"' "
_cQuery += " AND D_E_L_E_T_= '' "
TcQuery _cQuery NEW ALIAS ("TMP")

WHILE  TMP->(!EOF()) 
	if _nOpc == 1
		_nCont++
		If _nCont == 1
			_cRetorno += Alltrim(TMP->C6_DESCRI)
		Else             
			_cRetorno += CHR(13)+CHR(10)+" | "+Alltrim(TMP->C6_DESCRI)
		EndIf
		
		TMP->(Dbskip())
	else 
		_nCont++
		If _nCont == 1
			_cRetorno += Alltrim(Transform(TMP->C6_VALOR,'@E 99,999,999,999.99'))
		Else             
			_cRetorno += Alltrim(Transform(TMP->C6_VALOR,'@E 99,999,999,999.99'))
		EndIf
		
		TMP->(Dbskip())
	endif
enddo

TMP->(DbCloseArea())
Return(	_cRetorno)		

// ---------------------------------------------------------------------------------------------------- //
// Função que calcula o valor da retenção de imposto verificando o cadastro dos produtos da nota fiscal //
// Regra para cálculo das retenções de PIS, COFINS e CSLL                                               //
// Esta regra foi definina no dia 28/10/2015 juntamente com Paulo, Adriana e Harald                     //
// Caso o Cliente tiver em seu cadastro congigurado o PIS = S ou COFINS = S ou CSLL = S, indica que   o //
// cliente terá cálculo de retenção de Impostos.                                                        //
// Caso  o  produto  da  nota estiver configurado com PIS = S ou COFINS = S ou CSLL = S, sistema deverá //
// calcular a retenção de impostos.                                                                     //
// ---------------------------------------------------------------------------------------------------- //
Static Function CalcAbaServico()

   Local cSql       := ""
   Local nVlrPIS    := 0
   Local nVlrCofins := 0
   Local nVlrCSLL   := 0
   Local nVlrIRFF   := 0
   Local nVlrINSS   := 0

   Local aRetencao  := {}

   // Verifica se o cliente da nota fiscal está parametrizado para cálcular retenção de imposto
   If Posicione("SA1",1,xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA,"A1_RECPIS")  == "S" .Or. ;
      Posicione("SA1",1,xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA,"A1_RECCSLL") == "S" .Or. ;   
      Posicione("SA1",1,xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA,"A1_RECCOFI") == "S"

      // Dados da NF
      If Select("T_ABATIMENTO") > 0
         T_ABATIMENTO->( dbCloseArea() )
      EndIf

      cSql := "SELECT SD2.D2_FILIAL ,"
      cSql += "       SD2.D2_DOC    ,"
      cSql += "       SD2.D2_SERIE  ,"
      cSql += "       SD2.D2_COD    ,"
      cSql += " 	  SB1.B1_PIS    ,"
      cSql += " 	  SD2.D2_BASEPIS,"
      cSql += " 	  SD2.D2_ALQPIS ,"
      cSql += " 	  SD2.D2_VALPIS ,"
      cSql += " 	  SD2.D2_BASEISS,"
      cSql += " 	  SD2.D2_ALIQISS,"
      cSql += " 	  SD2.D2_VALISS ,"
      cSql += " 	  SB1.B1_COFINS ,"
      cSql += " 	  SD2.D2_BASECOF,"
      cSql += " 	  SD2.D2_ALQCOF ,"
      cSql += " 	  SD2.D2_VALCOF ,"
      cSql += " 	  SB1.B1_CSLL   ,"
      cSql += " 	  SD2.D2_BASECSL,"
      cSql += " 	  SD2.D2_ALQCSL ,"
      cSql += " 	  SD2.D2_VALCSL ,"
      cSql += "       SB1.B1_IRRF   ,"
      cSql += "       SD2.D2_BASEIRR,"
      cSql += "       SD2.D2_ALQIRRF,"
      cSql += "       SD2.D2_VALIRRF,"
      cSql += "       SB1.B1_INSS   ,"
      cSql += "       SD2.D2_BASEINS,"
      cSql += "       SD2.D2_ALIQINS,"
      cSql += "       SD2.D2_VALINS  "
      cSql += "  FROM " + RetSqlName("SD2") + " SD2, "
      cSql += "       " + RetSqlName("SB1") + " SB1  "
      cSql += " WHERE SD2.D2_FILIAL  = '" + Alltrim(cFilAnt)       + "'"
      cSql += "   AND SD2.D2_DOC     = '" + Alltrim(SF2->F2_DOC)   + "'"
      cSql += "   AND SD2.D2_SERIE   = '" + Alltrim(SF2->F2_SERIE) + "'"
      cSql += "   AND SD2.D_E_L_E_T_ = ''"
      cSql += "   AND SB1.B1_COD     = SD2.D2_COD"
      cSql += "   AND SB1.D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ABATIMENTO", .T., .T. )

      T_ABATIMENTO->( DbGoTop() )

      aAdd( aRetencao, { 0, 0, 0, 0, 0 } )

      nVlrPIS    := 0
      nVlrCofins := 0
      nVlrCSLL   := 0
      nVlrIRFF   := 0
      nVlrINSS   := 0      
   
      WHILE !T_ABATIMENTO->( EOF() )
 
         // PIS
         If T_ABATIMENTO->B1_PIS == "1"
            nVlrPIS := nVlrPIS + T_ABATIMENTO->D2_VALPIS
            aRetencao[01,01] := nVlrPIS
         Endif   
 
         // COFINS
         If T_ABATIMENTO->B1_COFINS == "1"
            nVlrCofins := nVlrCofins + T_ABATIMENTO->D2_VALCOF
            aRetencao[01,02] := nVlrCofins
         Endif   

         // CSLL
         If T_ABATIMENTO->B1_CSLL == "1"
            nVlrCSLL := nVlrCSLL + T_ABATIMENTO->D2_VALCSL
            aRetencao[01,03] := nVlrCSLL
         Endif   

         // IRRF
         If T_ABATIMENTO->B1_IRRF == "S"
            nVlrIRRF := nVlrIRFF + T_ABATIMENTO->D2_VALIRRF
            aRetencao[01,04] := nVlrIRRF
         Endif   

         // INSS
         If T_ABATIMENTO->B1_INSS == "S"
            nVlrINSS := nVlrINSS + T_ABATIMENTO->D2_VALINS
            aRetencao[01,05] := nVlrINSS
         Endif   

         T_ABATIMENTO->( DbSkip() )
      
      ENDDO
      
   Else

      aAdd( aRetencao, { 0, 0, 0, 0, 0 } )   
   
   Endif

Return aRetencao

// Função que calcula o valor do abatimento
Static Function xSAbatimento()

   Local cSql      := ""
   Local nImpostos := 0

   If Select("T_IMPOSTOS") > 0
      T_IMPOSTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SUM(E1_VALOR) AS IMPOSTOS"
   cSql += "  FROM " + RetSqlName("SE1")
   cSql += " WHERE E1_NUM     = '" + Alltrim(SF2->F2_DOC)   + "'"
   cSql += "   AND E1_PREFIXO = '" + Alltrim(SF2->F2_SERIE) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += "   AND E1_TIPO IN ('CS-', 'PI-', 'CF-', 'IR-', 'IN-')"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_IMPOSTOS", .T., .T. )

   If T_IMPOSTOS->( EOF() )
      nImpostos := 0
   Else
      nImpostos := T_IMPOSTOS->IMPOSTOS
   Endif
   
Return nImpostos
