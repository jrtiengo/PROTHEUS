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


// uso o CFOP para identificar o tipo da nota fiscal (entrada ou saida)
If aProduto[1,7] >= '5000'
	cTipo := '1'    // saida
Else
	cTipo := '0'    // entrada
EndIf

If cTipo = '1' // saida   SF2 SD2
	
	cMensPed:= ""
	cNotasDev := ""
	nItem := 0

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
	

		/* ponto 1.2  - OBS do Pedido  */   
		If !AllTrim(SC5->C5_OBSNF) $ cMensCli
			If Len(cMensCli) > 0 .And. SubStr(cMensCli, Len(cMensCli), 1) <> " "
				cMensCli += " "
			EndIf     
			cMensCli += SC5->C5_OBSNF
			
		EndIf
	
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
 		         
		DbSelectArea("CLAS")
		DbSkip() 
	EndDo
	CLAS->( DbCloseArea() )
	
	// 	ponto 1.9  - dados adicionais da nota de devolucao
	If Len( aNFOri ) > 0
		cMensCli += ' Devolucao ref. Nota(s) Num: '
		cNum := Space(0)
		For nI := 1 to Len( aNFOri )
			cNum += AllTrim(aNFOri[nI,1])+' Serie ' + AllTrim(aNFOri[nI,2])+'/p/'
		Next
		cMensCli += cNum+'/p/'
	Endif
	
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
			Endif
	    ENDIF   
      
       	nItem :=  val(SD1->D1_ITEM)        
       	
       	nTotItNfe := SD1->D1_TOTAL - SD1->D1_VALDESC
		nAuxUni   := Round(nTotItNfe/SD1->D1_QUANT,2)
		
		aProduto[nItem, 10] := nAuxUni*SD1->D1_QUANT
   		aProduto[nItem, 15] := 0       
		aProduto[nItem, 16] := Round(nTotItNfe/SD1->D1_QUANT,2)  
       
  		DbSelectArea("SD1")
 		Dbskip()
	EndDo
    
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


RestArea( aAreaSF2 )
RestArea( aAreaSD2 )
RestArea( aAreaSF1 )
RestArea( aAreaSD1 )
RestArea( aAreaSF4 )
RestArea( aArea )

Return( PARAMIXB )
