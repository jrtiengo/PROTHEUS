#include 'protheus.ch'
#include "topconn.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PE       ³ Autor ³    				    ³ Data ³`24/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ponto de entrada para tratamento dos dados do XML da nota  ³±±
±±³          ³ fiscal eletronica. Disparado de NFESEFAZ.PRW               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function PE01NFESEFAZ()

// ===================================================================================================================================== ***** //
// ***** ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ***** //
// Valores passados em PARAMIXB para o P.E. via NFESEFAZ.PRW                                                                             ***** //
// o NFESEFA.PRW foi ajustado para passar os dados da aDI (Importacao) e da aExp (exportacao) e aTotal (Totalizacoes da Nota)            ***** //
//                                                                                                                                       ***** //
// aParam := {aProd,cMensCli,cMensFis,aDest,aNota,aInfoItem,aDupl,aTransp,aEntrega,aRetirada,aVeiculo,aReboque, aTotal, aDI, aExp}       ***** //
//                                                                                                                                       ***** //
// ***** ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ATENCAO ***** //
// ===================================================================================================================================== ***** //

Local aArea     := GetArea()
Local aAreaSF2  := SF2->( GetArea() )
Local aAreaSD2  := SD2->( GetArea() )
Local aAreaSF1  := SF1->( GetArea() )
Local aAreaSD1  := SD1->( GetArea() )
Local aAreaSF4  := SF4->( GetArea() )

Local aProduto  := PARAMIXB[1]
Local cMensCli  := PARAMIXB[2]
Local cMensFis  := PARAMIXB[3]
Local aDest 	:= PARAMIXB[4]
Local aNota 	:= PARAMIXB[5]
Local aInfoItem	:= PARAMIXB[6]
Local aDupl		:= PARAMIXB[7]
Local aTransp	:= PARAMIXB[8]
Local aEntrega	:= PARAMIXB[9]
Local aRetirada	:= PARAMIXB[10]
Local aVeiculo	:= PARAMIXB[11]
Local aReboque	:= PARAMIXB[12]

/* vetores incluidos a mais no nfesefaz */
//Local aTotal    := PARAMIXB[13]
//Local aDI       := PARAMIXB[14]
//Local aExp      := PARAMIXB[15]


Local nI
Local nPos
Local cTipo         := ''
Local aMsgTES       := {}
Local aMsgFormulas  := {}
Local nValorII      := 0
Local aPedVen       := {}
Local aNFOri        := {}
Local cNum          := ""
Local cNotasDev     := ""

Local aDados		:= {}     
Local cMsgPisCof

// ENTROU?
//MsgInfo("Entrou no ponto PE_PE01NFESEFAZ")

// uso o CFOP para identificar o tipo da nota fiscal (entrada ou saida)
If aProduto[1,7] >= '5000'
	cTipo := '1'    // saida
Else
	cTipo := '0'    // entrada
EndIf

// alert('PE01NFESEFAZ')
If cTipo = '1' // saida   SF2 SD2
	
	
	// ===========================================================================
	//   - informacao do pedido
	
	//SD2->( dbSetOrder(3) )
	//SD2->( dbSeek(xFilial('SD2')+SF2->F2_DOC+SF2->F2_SERIE) )
	
	cMensPed:= ""
	cNotasDev := ""
	nItem := 0
	//Do While ! SD2->( Eof() ) .and. xFilial('SD2')+SF2->F2_DOC+SF2->F2_SERIE == SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE 
	                   
	cQuery := " SELECT  D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_ITEM,D2_COD, SD2.R_E_C_N_O_ AS RECSD2 "
	cQuery += " FROM " + RetSqlName("SD2") + " SD2 " 
	cQuery += " WHERE SD2.D2_FILIAL  = '" + xFilial("SD2") + "' "
	cQuery += "   AND SD2.D2_DOC     = '" + SF2->F2_DOC    + "' "
	cQuery += "   AND SD2.D2_SERIE   = '" + SF2->F2_SERIE  + "' "
	cQuery += "   AND SD2.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY   D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_ITEM "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), "CLAS", .F., .T.)
	DbGoTop()
	While !Eof()
		
	    DbSelectArea("SD2")
	    DbGoto( CLAS->RECSD2 )
	 	
		
		dbSelectArea("SC5")
		dbSetOrder(1)
		MsSeek(xFilial("SC5")+SD2->D2_PEDIDO)
		
		/* ponto 1.1  Pedido */
//		If !Empty( SD2->D2_PEDIDO ) //.and. Empty( cMensPed )
			
			//cMenscli	+= ' Pedido: ' + SD2->D2_PEDIDO      
//			If !( "Pedido: " $ cMensCli )
//				cMenscli	+= ' Pedido: ' + SD2->D2_PEDIDO
//			EndIf
			

//		EndIf
		

		/* ponto 1.2  - OBS do Pedido  */   
		If !AllTrim(SC5->C5_OBSNF) $ cMensCli
			If Len(cMensCli) > 0 .And. SubStr(cMensCli, Len(cMensCli), 1) <> " "
				cMensCli += " "
			EndIf     
			cMensCli += SC5->C5_OBSNF
			
		EndIf
		                                           
		/* ponto 1.3  - Descricao Condicao de Pagamento */

		

		// ponto 1.8 nota de Devolucao 
		if SF2->F2_TIPO = "D" .and. !Empty(SD2->D2_NFORI)
			//nPos := aScan( aNFOri, SD2->D2_NFORI  )   
			//
			nPos := aScan(aNFOri,{|x| x[1]==SD2->D2_NFORI })
			If nPos == 0
				Aadd( aNFOri, { SD2->D2_NFORI,;
				                 SD2->D2_SERIORI} )
			EndIf
		EndIf
        


		/* ponto 2.1  - NUMERO SERIE DO PRODUTO */
		//-----------------------------------------------------
		// Descricao do produto com numero de serie
		//-----------------------------------------------------
		/*
		cDescAdd := ""
		nTem := 0
		If !Empty( SD2->D2_NUMSERI )
			cDescAdd += " Nr Serie: " + AllTrim( SD2->D2_NUMSERI )
			nTem += 1
		Else
			cDescAdd += " Nr Serie: "
			
			cQuery := " SELECT DB_NUMSERI FROM  " + RetSQLName("SDB")
			cQuery += " WHERE          DB_FILIAL   = '"+ xFilial("SDB") + "'" + CRLF
			cQuery += "       AND      DB_PRODUTO  = '"+ SD2->D2_COD    + "'" + CRLF
			cQuery += "       AND      DB_DOC      = '"+ SD2->D2_PEDIDO + "'" + CRLF			
			cQuery += "       AND      DB_SERIE    = '"+ SD2->D2_ITEMPV + "'" + CRLF						
			cQuery += "       AND      DB_ATIVID   = '015'                   " + CRLF						
			cQuery += "       AND 	   DB_CLIFOR   = '"+ SD2->D2_CLIENTE+ "'" + CRLF
			cQuery += "       AND 	   DB_LOJA     = '"+ SD2->D2_LOJA   + "'" + CRLF
			cQuery += "       AND      D_E_L_E_T_  <> '*'" + CRLF
			//cQuery += "       AND      DB_DOC      = '"+ SD2->D2_DOC    + "'" + CRLF
			//cQuery += "       AND 	   DB_SERIE    = '"+ SD2->D2_SERIE  + "'" + CRLF
			//cQuery += "       AND      DB_NUMSEQ   = '"+ SD2->D2_NUMSEQ + "'" + CRLF
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), "TMPPRD", .F., .T.)
			dbGoTop()
			While !EOF()                                     
				If !Empty(TMPPRD->DB_NUMSERI )
					cDescAdd += AllTrim( TMPPRD->DB_NUMSERI ) + " / "
					nTem += 1
				EndIf	
				DbSkip()
			EndDo
				
			TMPPRD->( DbCloseArea() )
		EndIf		
		*/      
	    /*
		nItem += 1 //aScan(aProduto,{|x| x[1]== val(SD2->D2_ITEM).and. x[2] == SD2->D2_COD })
		
		If nItem > 0
			//===========================================================================
			// REMOVER O DESCONTO
			//===========================================================================
	       	//nItem :=  val(SD2->D2_ITEM)        
	       	If nTem > 0 
	
	       		aProduto[nItem, 4] := Alltrim( 	aProduto[nItem, 4] ) +  cDescAdd   // inf complentares do produto
	       	EndIf	
	 

			
			aProduto[nItem, 10] := SD2->D2_TOTAL + SD2->D2_DESCZFR
	   	 	aProduto[nItem, 15] := 0 //SD2->D2_DESCZFR
		    aProduto[nItem, 16] := Round((SD2->D2_TOTAL+ SD2->D2_DESCZFR)/SD2->D2_QUANT,8)  
		EndIf	               
		      
		*/
		
		
			/* ponto 1.7  - formulas TES */    
		// ===========================================================================
	//   - informacao de mensagens das TES
//		DbSelectArea("SM4") // * Formulas
// 		dbSetOrder(1)
//		DbSelectArea("SF4") // * Tipos de Entrada e Saida
//		dbSetOrder(1)
//		SF4->( dbSeek(xFilial('SF4') + SD2->D2_TES) )
//		aMsgTES := {SF4->F4_FORMULA,SF4->F4_FORM1,SF4->F4_FORM2}
//		For nI := 1 to Len(aMsgTES)
//  		If ! Empty(aMsgTES[nI])
//				nPos := aScan( aMsgFormulas , aMsgTES[nI] )
//				If nPos == 0
//					aAdd( aMsgFormulas , aMsgTES[nI] )
//					cMensCli += Iif(Empty(AllTrim(FORMULA(aMsgTES[nI]))), '', AllTrim(FORMULA(aMsgTES[nI]))+'/p/')
//				Endif
//			Endif
//		Next
		
		//SD2->( dbSkip() )
		         
		DbSelectArea("CLAS")
		DbSkip() 
	EndDo
	CLAS->( DbCloseArea() )
	
	//-----------------------------------------------------
	//Fim - Descricao do produto com numero de serie
	/* ponto 1.4  - codigo suframa  */
	/*
	dbSelectArea("SA1")
	dbSetOrder(1)
	IF DBSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
		
		if !Empty( SA1->A1_SUFRAMA ) .and. !( SA1->A1_SUFRAMA $ cMensCli )
			cMensCli +=  " Suframa: " + Transform(SA1->A1_SUFRAMA, "@E 9999999999999")
		endif
		
		/* ponto 1.5  - Endereco Entrega  */  
	/*	
		if !Empty( SA1->A1_ENDENT ) .and. !(  SA1->A1_ENDENT $ cMensCli )
			cMenscli += " Endereco Entrega:" +  Alltrim(SA1->A1_ENDENT) + " Bairro: " + Alltrim(SA1->A1_BAIRROE) + "N." + Alltrim(cvaltochar(SA1->A1_MUNE))
		endif
	endif
	*/
	// 	ponto 1.9  - dados adicionais da nota de devolucao
	If Len( aNFOri ) > 0
		cMensCli += ' Devolucao ref. Nota(s) Num: '
		cNum := Space(0)
		For nI := 1 to Len( aNFOri )
			cNum += AllTrim(aNFOri[nI,1])+' Serie ' + AllTrim(aNFOri[nI,2])+'/p/'
		Next
		cMensCli += cNum+'/p/'
	Endif
	
	// ===========================================================================
	//   - informacao do numero do LOTE do produto
	/*	For nI := 1 to Len(aProduto)
	
	//..Personaçizações de Produto
	dbSelectArea("SB1")
	dbSetOrder(1)
	If DbSeek(xFilial("SB1")+AllTrim(aProduto[nI, 2]))
	
	If !Empty(SB1->B1_TEXTONF)
	ctxtaux := SB1->B1_TEXTONF
	If !AllTrim(ctxtaux) $ cMensCli
	cMensCli += AllTrim(ctxtaux) + " #"
	EndIf
	EndIf
	endif
	
	
	If ! Empty(aProduto[nI, 19])
	
	cDescLTL := ""
	cDescLTL := "Lotes: " + AllTrim(aProduto[nI, 19])
	ctamanho :=AllTrim(aProduto[nI, 4])
	
	
	If Len(ctamanho)>90
	If Len(ctamanho)>180
	nSpc :=270 - Len(ctamanho)
	Else
	nSpc :=180 - Len(ctamanho)
	EndIf
	Else
	nSpc :=90 - Len(ctamanho)
	EndIf
	
	aProduto[nI, 25] := AllTrim(aProduto[nI, 25]) + "Lotes: "+aProduto[nI, 19]
	Endif
	Next
	*/
	
	
	
	
Else // entrada  SF1 SD1
	
	SD1->( dbSetOrder(1) )
	SD1->( dbSeek(xFilial('SD1')+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA) )
	Do While !Eof() .and. xFilial('SD1')+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA

	    // nota de importacao 
		DbSelectArea("CD5")
		DbSetOrder(4)
		// Procura algum registro na CD5 referente a nota que foi complementada
		If MsSeek(xFilial("CD5")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEM)
		                      
		   	If !Empty( CD5->CD5_NDI ) .and. !(  CD5->CD5_NDI $ cMensCli )
				cMensCli += 'Numero da DI:  '  + cvaltochar(CD5->CD5_NDI) + " / " + ;
				            'Data de DI:  '	+  cvaltochar(CD5->CD5_DTDI)+  " / " + ;
							'Base Cofins:  '	+  cvaltochar(CD5->CD5_BSCOF)+  " / " + ; 
							'Base Pis:  '	+  cvaltochar(CD5->CD5_BSPIS)+  " / " + ;
							'Valor Imp.I:  '	+  cvaltochar(CD5->CD5_VLRII)+  " / " + ;
							'Valor Desp.Acess:  '	+  cvaltochar(CD5->CD5_DSPAD)+  " / " + ; 
							'Valor Cofins:  '	+  cvaltochar(CD5->CD5_VLCOF)+  " / " + ;
							'Valor Pis:  '	+  cvaltochar(CD5->CD5_VLPIS) + " - " 
				// CD5_NDI = Numero da DI
				// CD5_DTDI= Data de DI
				// CD5_VLCOF= Valor Cofins
				// CD5_VLPIS= Valor Pis
			Endif
	    ENDIF   

                                                            

			/* formulas TES */    
		// ===========================================================================
	//   - informacao de mensagens das TES
/*		DbSelectArea("SM4") // * Formulas
		dbSetOrder(1)
		DbSelectArea("SF4") // * Tipos de Entrada e Saida
		dbSetOrder(1)
		SF4->( dbSeek(xFilial('SF4') + SD1->D1_TES) )
		aMsgTES := {SF4->F4_FORMULA,SF4->F4_FORM1,SF4->F4_FORM2}
		For nI := 1 to Len(aMsgTES)
			If ! Empty(aMsgTES[nI])
				nPos := aScan( aMsgFormulas , aMsgTES[nI] )
				If nPos == 0
					aAdd( aMsgFormulas , aMsgTES[nI] )
					cMensCli += Iif(Empty(AllTrim(FORMULA(aMsgTES[nI]))), '', AllTrim(FORMULA(aMsgTES[nI]))+'/p/')
				Endif
			Endif
		Next

  */




		//===========================================================================
		// REMOVER O DESCONTO
		//===========================================================================
       	/*
       	nItem :=  val(SD1->D1_ITEM)        
       	
       	nTotItNfe := SD1->D1_TOTAL - SD1->D1_VALDESC
		aProduto[nItem, 10] := nTotItNfe //SD1->D1_TOTAL 
   		aProduto[nItem, 15] := 0       
		aProduto[nItem, 16] := NoRound(nTotItNfe/SD1->D1_QUANT,8)  
        */
       
       	nItem :=  val(SD1->D1_ITEM)        
       	
       	nTotItNfe := SD1->D1_TOTAL - SD1->D1_VALDESC
		nAuxUni   := Round(nTotItNfe/SD1->D1_QUANT,2)
		//#29702. Incluída validação para notas de devolução. Não pode alterar quando qtd for zero. Dá rejeição 610 (não grava vProd). Mauro-Mônica-Solutio.
		If SD1->D1_QUANT > 0
			aProduto[nItem, 10] := nAuxUni*SD1->D1_QUANT
		EndIf
   		aProduto[nItem, 15] := 0       
		//#29702. Incluída validação para notas de devolução. Não pode alterar quando qtd for zero. Dá rejeição 610 (não grava vProd). Mauro-Mônica-Solutio.
		If SD1->D1_QUANT > 0 
			aProduto[nItem, 16] := Round(nTotItNfe/SD1->D1_QUANT,2)  
		EndIf
       
  		DbSelectArea("SD1")
 		Dbskip()
	EndDo
    
 /*            aLCEU
	cMsgPisCof := MsgPISCof()
    If !cMsgPisCof $ cMensCli
    	cMensCli += cMsgPisCof
    Endif
 */  
  
Endif


// atualiza dados para o NFESEFAZ
PARAMIXB[1]   := aProduto
PARAMIXB[2]   := cMensCli
PARAMIXB[3]   := cMensFis
PARAMIXB[4]   := aDest
PARAMIXB[5]   := aNota
PARAMIXB[6]   := aInfoItem
PARAMIXB[7]   := aDupl
PARAMIXB[8]   := aTransp
PARAMIXB[9]   := aEntrega
PARAMIXB[10]  := aRetirada
PARAMIXB[11]  := aVeiculo
PARAMIXB[12]  := aReboque

/* vetores incluidos a mais no nfesefaz */

//PARAMIXB[13]  := aTotal
//PARAMIXB[14]  := aDI
//PARAMIXB[15]  := aExp


RestArea( aAreaSF2 )
RestArea( aAreaSD2 )
RestArea( aAreaSF1 )
RestArea( aAreaSD1 )
RestArea( aAreaSF4 )
RestArea( aArea )

Return( PARAMIXB )

/*

// Funcao para retornar mensagem com valores de PIS e COFINS na nota de entrada
Static Function MsgPISCof()
Local cAreaAnt := Alias()
Local cQuery
Local cMsg
Local nValPis,nValCof,cDI,cDTDI
          
// Busca dados da CD5
cQuery := "SELECT SUM(CD5_VLPIS) VLPIS, SUM(CD5_VLCOF) VLCOF, CD5_NDI NDI, CD5_DTDI DTDI"
cQuery += " FROM " + RetSQLName("CD5") + " CD5"
cQuery += " WHERE CD5_FILIAL = '" + SF1->F1_FILIAL+"'"
cQuery += " AND CD5_DOC = '"+SF1->F1_DOC+"'"
cQuery += " AND CD5_SERIE = '"+SF1->F1_SERIE+"'"
cQuery += " AND CD5_FORNEC = '"+SF1->F1_FORNECE+"'"
cQuery += " AND CD5_LOJA = '"+SF1->F1_LOJA+"'"
cQuery += " AND CD5.D_E_L_E_T_ <> '*'"
cQuery += " GROUP BY CD5_NDI, CD5_DTDI"
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)
dbSelectArea("TRB")
If Eof()
	cMsg := ""
Else
	nValPis := 0
	nValCof := 0
	cDI := ""
	cDTDI := ""
	cMsg := ""
	Do While !Eof()
		cDI += TRB->NDI+" "
		cDTDI += dtoc(stod(TRB->DTDI))+" "
		nValPis += TRB->VLPIS
		nValCof += TRB->VLCOF
		dbSkip()
	Enddo	
	cMsg += 'Numero da DI:  '  + cDI
	cMsg += 'Data de DI:  '	+  cDTDI
	cMsg += 'Valor Cofins:  ' +  cvaltochar(nValCof)
	cMsg += 'Valor Pis:  '	+  cvaltochar(nValPis)
Endif   
*/
//TRB->(dbCloseArea())

//dbSelectArea(cAreaAnt)
//Return cMsg
