#Include "TOTVS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO13    ºAutor  ³Ednei Silva         º Data ³  09/03/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/







User Function SCICTFAT()

Local cPerg:='SCITFAT'
Private cAglNum:=''
If cPerg == "SCITFAT"
	If !SX1->( dbSeek( cPerg ) )
		
		aHelpPor := {"Numero Processo"}
		aHelpEng := {""}
		aHelpSpa := {""}
		
		//PutSX1(cPerg,"01","Numero Processo:","Numero Processo:","Numero Processo","mv_ch1","C",09,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		
		
	Endif
Endif

If Pergunte(cPerg,.T.)
	
	cAglNum:=mv_par01
	
	Processa({|| ctbAgl() },"Contabilizando titulos AGL","Processando...")
	
endif

Return



static function ctbAgl()

Local cContaD:=""
Local cLA:=""
Local aCab   := {}
Local aItens := {}
Private lMsErroAuto := .f.
PRIVATE cHist:=""

// Numero
//----------------------------------------------------------------


//----------------------------------------------------------------
// Todos os titulos AGL selecionada
//----------------------------------------------------------------
c3Query := " SELECT * "
c3Query += " FROM  " + RetSQLName("SE2") + " SE2 "
c3Query += " WHERE SE2.E2_FILIAL = '" + xFilial("SE2") + "'"
c3Query += " AND   SE2.E2_TIPO    =  'TX' "
c3Query += " AND   SE2.E2_PREFIXO =  'AGL' "
c3Query += " AND   SE2.E2_NUM =  '"+cAglNum+"' "
c3Query += " AND   SE2.D_E_L_E_T_ <> '*' "
c3Query += " ORDER BY E2_NUM,E2_PARCELA "
c3Query := ChangeQuery(c3Query)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,c3Query),"TMPFAT",.F.,.T.)
DbSelectArea("TMPFAT")
ProcRegua(TMPFAT->(RecCount()))
TMPFAT->(dbGoTop())
nCont:=0 // contador linhas lançamento

While TMPFAT->(!Eof())
	nCont:=0
	cLA:=     Posicione("SE5",7,xfilial("SE5")+TMPFAT->E2_PREFIXO+TMPFAT->E2_NUM+TMPFAT->E2_PARCELA+TMPFAT->E2_TIPO+TMPFAT->E2_FORNECE+TMPFAT->E2_LOJA,"E5_LA")
	
	IF TMPFAT->E2_PREFIXO='AGL'  .AND. cLA<>'S' .AND. ALLTRIM(TMPFAT->E2_MOVIMEN)<>"" // Se for titulo com aglutinçao
		
		
		TMPFAT->(IncProc())
		
		
		
		aCab :={}
		aItens := {}
		dBaixa  := StoD(TMPFAT->E2_MOVIMEN)
		// Calculo do proximo numero do lancamento
		//----------------------------------------------------------------
		c5Query := " SELECT ISNULL(MAX(CT2_DOC)+1,'1') PROXDOC "
		c5Query += " FROM CT2010 "
		c5Query += " WHERE CT2_DATA = '" + Dtos(dBaixa) + "'"
		c5Query += " AND   CT2_LOTE = '001FAT' "
		c5Query += " AND   CT2_FILIAL = '" + xFilial("CT2") + "'"
		c5Query += " AND D_E_L_E_T_ <> '*' "
		c5Query := ChangeQuery(c5Query)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,c5Query),"XMAXCT2",.F.,.T.)
		DbSelectArea("XMAXCT2")
		cDocCt2:=""
		cDocCt2:=Strzero(XMAXCT2->PROXDOC,6)
		XMAXCT2->(dbCloseArea())
		//----------------------------------------------------------------
		
		
		//Inclusão do cabeçalho do Lançamento Contábil
		//----------------------------------------------------------------
		aAdd(aCab,  {'DDATALANC'     ,dBaixa    ,NIL} )
		aAdd(aCab,  {'CLOTE'         ,'001FAT'  ,NIL} )
		aAdd(aCab,  {'CSUBLOTE'      ,'001'     ,NIL} )
		aAdd(aCab,  {'CDOC'          ,cDocCt2   ,NIL} )
		aAdd(aCab,  {'CPADRAO'       ,''        ,NIL} )
		aAdd(aCab,  {'NTOTINF'       ,0         ,NIL} )
		aAdd(aCab,  {'NTOTINFLOT'    ,0         ,NIL} )
		
		
		
		
		// Seleciono todos os titulos que compoem o AGL selecionado
		//-------------------------------------------------------------------
		c4Query := " SELECT * "
		c4Query += " FROM  " + RetSQLName("SE2") + " SE2 "
		c4Query += " WHERE SE2.E2_AGLIMP = '" + TMPFAT->E2_NUM+ "' "
		c4Query += " AND   SE2.D_E_L_E_T_ <> '*' "
		c4Query += " AND   SE2.E2_PARAGL = '" + TMPFAT->E2_PARCELA+ "' "
		c4Query := ChangeQuery(c4Query)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,c4Query),"TMPAGL",.F.,.T.)
		DbSelectArea("TMPAGL")
		//-------------------------------------------------------------------
		While TMPAGL->(!Eof())
			
			
			
			// Regra para buscar a conta contabil e montar o historico dos lancamento de impostos aglutinados
			//-----------------------------------------------------------------------------------------------
			DO CASE
				CASE TMPAGL->E2_CODRET='5952'
					cContaD:='21050010010002'
					cHist  := "VLR PIS/COF/CSL NF" +" "+ ALLTRIM(TMPAGL->E2_NUM) +" "+ SUBSTR(POSICIONE("SA2",1,xFilial("SA2")+TMPAGL->E2_FORNECE+TMPAGL->E2_LOJA,"A2_NOME"),1,15)+' AGL/PARCELA '+TMPAGL->E2_AGLIMP+'/'+TMPAGL->E2_PARAGL
					
				CASE TMPAGL->E2_CODRET='5979'
					cContaD:='21050010010008'
					cHist  := "VLR PIS NF" +" "+ ALLTRIM(TMPAGL->E2_NUM) +" "+ SUBSTR(POSICIONE("SA2",1,xFilial("SA2")+TMPAGL->E2_FORNECE+TMPAGL->E2_LOJA,"A2_NOME"),1,15)+' AGL/PARCELA '+TMPAGL->E2_AGLIMP+'/'+TMPAGL->E2_PARAGL
					
				CASE TMPAGL->E2_CODRET='5960'
					cContaD:='21050010010009'
					cHist  := "VLR COF NF" +" "+ ALLTRIM(TMPAGL->E2_NUM) +" "+ SUBSTR(POSICIONE("SA2",1,xFilial("SA2")+TMPAGL->E2_FORNECE+TMPAGL->E2_LOJA,"A2_NOME"),1,15)+' AGL/PARCELA '+TMPAGL->E2_AGLIMP+'/'+TMPAGL->E2_PARAGL
					
				CASE TMPAGL->E2_CODRET='5987'
					cContaD:='21050010010010'
					cHist  := "VLR CSL NF" +" "+ ALLTRIM(TMPAGL->E2_NUM) +" "+ SUBSTR(POSICIONE("SA2",1,xFilial("SA2")+TMPAGL->E2_FORNECE+TMPAGL->E2_LOJA,"A2_NOME"),1,15)+' AGL/PARCELA '+TMPAGL->E2_AGLIMP+'/'+TMPAGL->E2_PARAGL
					
				CASE TMPAGL->E2_CODRET='0561'
					cContaD:='21050010020001'
					cHist  := "VLR IRF NF" +" "+ ALLTRIM(TMPAGL->E2_NUM) +" "+ SUBSTR(POSICIONE("SA2",1,xFilial("SA2")+TMPAGL->E2_FORNECE+TMPAGL->E2_LOJA,"A2_NOME"),1,15)+' AGL/PARCELA '+TMPAGL->E2_AGLIMP+'/'+TMPAGL->E2_PARAGL
					
				CASE TMPAGL->E2_CODRET='9385'
					cContaD:='21050010010006'
					cHist  := "VLR IRF NF" +" "+ ALLTRIM(TMPAGL->E2_NUM) +" "+ SUBSTR(POSICIONE("SA2",1,xFilial("SA2")+TMPAGL->E2_FORNECE+TMPAGL->E2_LOJA,"A2_NOME"),1,15)+' AGL/PARCELA '+TMPAGL->E2_AGLIMP+'/'+TMPAGL->E2_PARAGL
					
				CASE TMPAGL->E2_CODRET='0588'
					cContaD:='21050010010007'
					cHist  := "VLR IRF NF" +" "+ ALLTRIM(TMPAGL->E2_NUM) +" "+ SUBSTR(POSICIONE("SA2",1,xFilial("SA2")+TMPAGL->E2_FORNECE+TMPAGL->E2_LOJA,"A2_NOME"),1,15)+' AGL/PARCELA '+TMPAGL->E2_AGLIMP+'/'+TMPAGL->E2_PARAGL
					
				CASE TMPAGL->E2_CODRET='1708'
					cContaD:='21050010010001'
					cHist  := "VLR IRF NF" +" "+ ALLTRIM(TMPAGL->E2_NUM) +" "+ SUBSTR(POSICIONE("SA2",1,xFilial("SA2")+TMPAGL->E2_FORNECE+TMPAGL->E2_LOJA,"A2_NOME"),1,15)+' AGL/PARCELA '+TMPAGL->E2_AGLIMP+'/'+TMPAGL->E2_PARAGL
					
				CASE TMPAGL->E2_CODRET $ ('0422/0481/0473/9427')
					cContaD:='21050010010005'
					cHist  := "VLR IRF NF" +" "+ ALLTRIM(TMPAGL->E2_NUM) +" "+ SUBSTR(POSICIONE("SA2",1,xFilial("SA2")+TMPAGL->E2_FORNECE+TMPAGL->E2_LOJA,"A2_NOME"),1,15)+' AGL/PARCELA '+TMPAGL->E2_AGLIMP+'/'+TMPAGL->E2_PARAGL
					
			ENDCASE
			
			
			
			//-------------------------------------------------------------------------------------
			//Inclusão de Lançamento Contábil impostos aglutinados
			//----------------------------------------------------------
			nCont:=nCont+1
			Aadd 	(aItens, {{'CT2_FILIAL'       ,'01'      ,NIL},;
			{'CT2_LOTE'     ,'001FAT'                        ,NIL},;
			{'CT2_SBLOTE'   ,'001'                           ,NIL},;
			{'CT2_DOC'      ,cDocCt2					     ,NIL},;
			{'CT2_DATA'     ,dBaixa                          ,NIL},;
			{'CT2_LINHA'    ,STRZERO(nCont,3,0)              ,NIL},;
			{'CT2_MOEDLC'   ,'01'                            ,NIL},;
			{'CT2_DC'       ,'1'                             ,NIL},;
			{'CT2_CREDIT'   ,''                              ,NIL},;
			{'CT2_DEBITO'   ,cContaD                         ,NIL},;
			{'CT2_VALOR'    ,TMPAGL->E2_VALOR			  	 ,NIL},;
			{'CT2_EMPORI'   ,'01'             			     ,NIL},;
			{'CT2_FILORI'   ,'0101'             			 ,NIL},;
			{'CT2_TPSALD'   ,'1'                			 ,NIL},;
			{'CT2_COD'      ,''         	        	     ,NIL},;
			{'CT2_CCD'      ,''         	        	     ,NIL},;
			{'CT2_COC'      ,''         	        	     ,NIL},;
			{'CT2_CCC'      ,''         	        	     ,NIL},;
			{'CT2_ORIGEM'   ,'FAT-FINANCEIRO'    			 ,NIL},;
			{'CT2_HIST'     ,substr(cHist,1,40) 			 ,NIL},;
			{'CT2_CRCONV'   ,'1'   			     			 ,NIL},;
			{'CT2_AGLUT'    ,'2'							 ,NIL}})
			
			
			//Inclusão de Lançamento Contábil Historico impostos aglutinados
			//--------------------------------------------------------------
			IF len(cHist)>40
				nCont:=nCont+1
				Aadd 	(aItens, {{'CT2_FILIAL'   	  ,'01'		,NIL},;
				{'CT2_LOTE'     ,'001FAT'						,NIL},;
				{'CT2_SBLOTE'   ,'001'					   	    ,NIL},;
				{'CT2_DOC'      ,cDocCt2						,NIL},;
				{'CT2_DATA'     ,dBaixa					        ,NIL},;
				{'CT2_LINHA'    ,STRZERO(nCont,3,0)             ,NIL},;
				{'CT2_MOEDLC'   ,'01'							,NIL},;
				{'CT2_DC'       ,'4'    					    ,NIL},;
				{'CT2_CREDIT'   ,''                             ,NIL},;
				{'CT2_DEBITO'   ,''			             	    ,NIL},;
				{'CT2_VALOR'    ,0							    ,NIL},;
				{'CT2_EMPORI'   ,'01'						    ,NIL},;
				{'CT2_FILORI'   ,'0101'						    ,NIL},;
				{'CT2_TPSALD'   ,'1'						    ,NIL},;
				{'CT2_COD'      ,''         	        	    ,NIL},;
				{'CT2_CCD'      ,''         	        	    ,NIL},;
				{'CT2_COC'      ,''         	        	    ,NIL},;
				{'CT2_CCC'      ,''         	        	    ,NIL},;
				{'CT2_ORIGEM'   ,'FAT-FINANCEIRO'  	     	    ,NIL},;
				{'CT2_HIST'     ,substr(cHist,40,len(cHist))	,NIL},;
				{'CT2_CRCONV'   ,''					     		,NIL},;
				{'CT2_AGLUT'    ,'2' 							,NIL}})
				
			Endif
			
			TMPAGL->(dbSkip())
		enddo
		
		TMPAGL->(dbclosearea())
		
		
		// Lancamento de credito
		
		nValor  := 0
		cContaD := ""
		cHist   := ""
		cBanco  := ""
		cAge    := ""
		cConta  := ""
		
		cBanco:=     Posicione("SE5",7,xfilial("SE5")+TMPFAT->E2_PREFIXO+TMPFAT->E2_NUM+TMPFAT->E2_PARCELA+TMPFAT->E2_TIPO+TMPFAT->E2_FORNECE+TMPFAT->E2_LOJA,"E5_BANCO")
		cAge  :=     Posicione("SE5",7,xfilial("SE5")+TMPFAT->E2_PREFIXO+TMPFAT->E2_NUM+TMPFAT->E2_PARCELA+TMPFAT->E2_TIPO+TMPFAT->E2_FORNECE+TMPFAT->E2_LOJA,"E5_AGENCIA")
		cConta:=     Posicione("SE5",7,xfilial("SE5")+TMPFAT->E2_PREFIXO+TMPFAT->E2_NUM+TMPFAT->E2_PARCELA+TMPFAT->E2_TIPO+TMPFAT->E2_FORNECE+TMPFAT->E2_LOJA,"E5_CONTA")
		
		nValor  :=	TMPFAT->E2_VALOR + TMPFAT->E2_JUROS + TMPFAT->E2_MULTA - TMPFAT->E2_DESCONT
		cContaD :=  Posicione("SA6",1,xfilial("SA6")+cBanco+cAge+cConta,"A6_CONTA")
		cHist   := "BX TIT. AGL/PARCELA" +" "+ ALLTRIM(TMPFAT->E2_NUM) +"/"+ALLTRIM(TMPFAT->E2_PARCELA)+" "+SUBSTR(POSICIONE("SA2",1,xFilial("SA2")+TMPFAT->E2_FORNECE+TMPFAT->E2_LOJA,"A2_NOME"),1,15)
		
		
		nCont:=nCont+1
		
		//	{'CT2_CREDIT'   ,cContaD                         ,NIL},;
		//Inclusão de Lançamento Contábil da Fatura principal
		//----------------------------------------------------------
		Aadd 	(aItens, {{'CT2_FILIAL'       ,'01'      ,NIL},;
		{'CT2_LOTE'     ,'001FAT'                        ,NIL},;
		{'CT2_SBLOTE'   ,'001'                           ,NIL},;
		{'CT2_DOC'      ,cDocCt2					     ,NIL},;
		{'CT2_DATA'     ,dBaixa                          ,NIL},;
		{'CT2_LINHA'    ,STRZERO(nCont,3,0)              ,NIL},;
		{'CT2_MOEDLC'   ,'01'                            ,NIL},;
		{'CT2_DC'       ,'2'                             ,NIL},;
		{'CT2_CREDIT'   ,cContaD                         ,NIL},;
		{'CT2_DEBITO'   ,''                              ,NIL},;
		{'CT2_VALOR'    ,nValor	             		  	 ,NIL},;
		{'CT2_EMPORI'   ,'01'             			     ,NIL},;
		{'CT2_FILORI'   ,'0101'             			 ,NIL},;
		{'CT2_TPSALD'   ,'1'                			 ,NIL},;
		{'CT2_COD'      ,''         	        	     ,NIL},;
		{'CT2_CCD'      ,''         	        	     ,NIL},;
		{'CT2_COC'      ,''         	        	     ,NIL},;
		{'CT2_CCC'      ,''         	        	     ,NIL},;
		{'CT2_ORIGEM'   ,'FAT-FINANCEIRO'    			 ,NIL},;
		{'CT2_HIST'     ,substr(cHist,1,40) 			 ,NIL},;
		{'CT2_CRCONV'   ,'1'   						     ,NIL},;
		{'CT2_AGLUT'    ,'2'							 ,NIL}})
		
		
		//Inclusão de Lançamento Contábil Historico impostos
		//----------------------------------------------------------
		
		IF len(cHist)>40
			nCont:=nCont+1
			Aadd 	(aItens, {{'CT2_FILIAL'   	  ,'01'	   ,NIL},;
			{'CT2_LOTE'     ,'001FAT'					   ,NIL},;
			{'CT2_SBLOTE'   ,'001'					   	   ,NIL},;
			{'CT2_DOC'      ,cDocCt2					   ,NIL},;
			{'CT2_DATA'     ,dBaixa					   ,NIL},;
			{'CT2_LINHA'    ,STRZERO(nCont,3,0)            ,NIL},;
			{'CT2_MOEDLC'   ,'01'						   ,NIL},;
			{'CT2_DC'       ,'4'    					   ,NIL},;
			{'CT2_CREDIT'   ,''		    	        	   ,NIL},;
			{'CT2_DEBITO'   ,''                            ,NIL},;
			{'CT2_VALOR'    ,0							   ,NIL},;
			{'CT2_EMPORI'   ,'01'						   ,NIL},;
			{'CT2_FILORI'   ,'0101'						   ,NIL},;
			{'CT2_TPSALD'   ,'1'						   ,NIL},;
			{'CT2_COD'      ,''         	        	   ,NIL},;
			{'CT2_CCD'      ,''         	        	   ,NIL},;
			{'CT2_COC'      ,''         	        	   ,NIL},;
			{'CT2_CCC'      ,''         	        	   ,NIL},;
			{'CT2_ORIGEM'   ,'FAT-FINANCEIRO'  	     	   ,NIL},;
			{'CT2_HIST'     ,substr(cHist,40,len(cHist))   ,NIL},;
			{'CT2_CRCONV'   ,''						   ,NIL},;
			{'CT2_AGLUT'    ,'2' 						   ,NIL}})
			
		Endif
		
		
		
		MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3)
		If lMsErroAuto
			
			FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", "Erro na inclusao(AGL - Lote 001AGL)!"  , 0, 0, {}) 
			MostraErro()
			
		else
			
			dbSelectArea("SE5")
			dbSetOrder(7)
			IF SE5->(DbSeek(xfilial("SE5")+TMPFAT->E2_PREFIXO+TMPFAT->E2_NUM+TMPFAT->E2_PARCELA+TMPFAT->E2_TIPO+TMPFAT->E2_FORNECE+TMPFAT->E2_LOJA))
				
				RecLock( "SE5", .F.)
				SE5->E5_LA := 'S'
				MsUnLock()
				
			Endif
			
		endif
		
	Endif
	
	
	TMPFAT->(dbSkip())
enddo

TMPFAT->(dbclosearea())

Return


