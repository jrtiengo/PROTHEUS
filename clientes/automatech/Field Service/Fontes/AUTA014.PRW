#Include "Protheus.ch"
#Include "TOTVS.ch"

/*/{Protheus.doc} AUTA014
Rotina de Browse para tratamento das requicições de peças no processo de O.S.. FieldService.
 
@author Lucas Moresco
@since 30/06/2014
@version 1.0
/*/
User Function AUTA014

Private aAC       := { "Abandona","Confirma" }
Private aCRA      := { "Confirma","Redigita","Abandona" }
Private cCadastro := "Requisição de Peças"

Private aCores  := {;
				   {" ZZZ->ZZZ_STATUS == 'A' " , 'BR_VERDE'    },; //Requisicao Aberta 
 				   {" ZZZ->ZZZ_STATUS == 'P' " , 'BR_AMARELO'  },; //Requisicao Atendida Parcialmente
				   {" ZZZ->ZZZ_STATUS == 'E' " , 'BR_VERMELHO' }}  //Requisicao Atendida

Private aRotina := {;
				   {"Pesquisar"	,"AxPesqui"       ,0,1},;
				   {"Atender"	,"U_AlteraReqPec('A')" ,0,4},;
				   {"Estornar"	,"U_AlteraReqPec('E')" ,0,2},;
				   {"Legenda"   ,"U_LegendaZZZ()"   ,0,2}}
				                                            	
				                                            	 
    DbSelectArea("ZZZ")				                                            	
	MBrowse(006,001,022,075,"ZZZ",,"ZZZ_NUMOS",20,,, aCores,,,,,.F.)     
	//<aColors>, <cTopFun>, <cBotFun>, <nPar14>, <bInitBloc>, <lNoMnuFilter>)
	
                   

Return()

*****************************************************************************
User Function LegendaZZZ()
*****************************************************************************

Local aLegenda := {}

	Aadd(aLegenda,{"BR_VERDE"    ,"Requisição Aberta " })
	Aadd(aLegenda,{"BR_AMARELO"  ,"Requisição Atendida Parcialmente" })
	Aadd(aLegenda,{"BR_VERMELHO" ,"Requisição Atendida" })

	BrwLegenda(cCadastro, "Legenda", aLegenda)

Return()

*****************************************************************************
User Function AlteraReqPec(cOpcao)
*****************************************************************************

Local cQry       := ""
Local cLocal     := ""
Local cTecnico   := ""
Local nSaldoB2   := 0
Local lRet       := .T.

Private cFuncao  := cOpcao
Private aItens   := {}

	If (cOpcao == "E")
		DbSelectArea("AB6");DbSetOrder(1)
		If (DbSeek(xFilial("AB6")+ZZZ->ZZZ_NUMOS))
			If (AB6->AB6_STATUS == "E") 
				lRet := .F.
				MsgAlert("Atenção, não é possível estornar uma requisição de O.S. já encerrada.")
			EndIf	
		EndIf
		
		If (ZZZ->ZZZ_STATUS == "A")
			lRet := .F.
			MsgAlert("Atenção, não é possível estornar uma requisição de O.S. aberta.")
		EndIf
		
	EndIf
	
	If (lRet)
	
		Iif(Select("TMPZZZ")!=0, TMPZZZ->(DbCloseArea()),)
		
		cQry := "Select B1_LOCALIZ, B1_PARNUM, B1_COD, B1_DESC, B1_UM, ZZZ_ITEM, ZZZ_ITAB8, ZZZ_QUANT, ZZZ_SALDO, ZZZ_TECNIC, ZZZ_STATUS, ZZZ_LOCALI, ZZZ_NUMSER SERIENUM, ZZZ_LOCAL, ZZZ_DOCSD3, ZZZ_QTDORI From "+RetSqlName("ZZZ")+" ZZZ(NoLock) "+chr(13)
		cQry += "Inner Join "+RetSqlName("SB1")+" SB1(NoLock) "+chr(13)
		cQry += "On (ZZZ_PRODUT = B1_COD) "+chr(13)
		cQry += "Where "+chr(13) 
		cQry += "ZZZ.ZZZ_NUMOS =  '"+ZZZ->ZZZ_NUMOS+"' And "+chr(13)
		cQry += "ZZZ.ZZZ_FILIAL = '"+xFilial("ZZZ")+"' And "+chr(13)
		cQry += "SB1.B1_FILIAL = '"+xFilial("SB1")+"' And "+chr(13)
		cQry += "ZZZ.D_E_L_E_T_ <> '*' And "
		cQry += "SB1.D_E_L_E_T_ <> '*' "
		cQry := ChangeQuery(cQry)
		
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), "TMPZZZ", .T., .T. )
	
		DbSelectArea("TMPZZZ"); DbGoTop()
		
		cTecnico := TMPZZZ->ZZZ_TECNIC
		
		While ! Eof()
			
			DbSelectArea("SB2");DbSetOrder(1)
			
			If DbSeek(xFilial("SB2")+TMPZZZ->B1_COD+TMPZZZ->ZZZ_LOCAL)
				nSaldoB2 := SaldoSb2()
			Else
				nSaldoB2 := 0
			EndIf
		
			DbSelectArea("AB8");DbSetOrder(1)
			
			If DbSeek(xFilial("AB8")+ZZZ->ZZZ_NUMOS+"01"+TMPZZZ->ZZZ_ITAB8)
				cLocal   := AB8->AB8_LOCAL
			Else
				cLocal   := ""
			EndIf
			
				If (TMPZZZ->B1_LOCALIZ == "S") 
					cEnde     := TMPZZZ->ZZZ_LOCALI
					cNumSerie := TMPZZZ->SERIENUM
				Else
					cEnde     := "Não Controla"
					cNumSerie := "Não Controla"
				EndIf
				
				Aadd(aItens,{TMPZZZ->ZZZ_ITEM,;   // 01
							 TMPZZZ->B1_PARNUM,;   //02
							 TMPZZZ->B1_COD,;      //03
							 TMPZZZ->B1_DESC,;     //04
							 cLocal,;             //05
							 TMPZZZ->ZZZ_QUANT,;  //06
							 cEnde,;              //07
							 cNumSerie,;          //08
							 0,;                  //09
							 TMPZZZ->ZZZ_SALDO,;  //10
							 nSaldoB2,;           //11
							 TMPZZZ->ZZZ_STATUS,; //12
							 TMPZZZ->B1_UM,;      //13
							 TMPZZZ->ZZZ_DOCSD3,;  //14
							 TMPZZZ->ZZZ_QTDORI,; //15
							 })
			
			
			DbSelectArea("TMPZZZ")
			DbSkip()
		EndDo
	
		MontaTela(ZZZ->ZZZ_NUMOS,cTecnico,aItens)

	EndIf
	
Return()

*****************************************************************************
Static Function MontaTela(cNumOs,cTecnico,aItens)
*****************************************************************************

Local cNumReq  := ""
Local dData    := Date()
Local cDescTec := Posicione("AA1",1,xFilial("AA1")+cTecnico,"AA1_NOMTEC")

Private cNumSD3  := ""
Private oDlg
Private aBrowse  := {}
Private oBrowse  := {}
Private oOpen    := LoadBitmap(GetResources(),'br_verde')    
Private oClose   := LoadBitmap(GetResources(),'br_vermelho') 
Private oPartial := LoadBitmap(GetResources(),'br_amarelo') 

Private aList := {}   
Static Cancela
Static Confirma
Static data
Static numOs
Static numReq
Static oFont1 := TFont():New("MS Sans Serif",,022,,.F.,,,,,.F.,.F.)
Static oFont2 := TFont():New("MS Sans Serif",,024,,.T.,,,,,.F.,.F.)
Static solicitante

  DEFINE MSDIALOG oDlg TITLE "Requisição de Peças" FROM 000, 000  TO 500, 1200 COLORS 0, 16777215 PIXEL

    @ 225, 530 BUTTON Confirma PROMPT "Confirma" ACTION (GeraMovimento()) SIZE 056, 018 OF oDlg PIXEL
    @ 225, 470 BUTTON Cancela PROMPT "Cancela"   ACTION (oDlg:End()) SIZE 056, 018 OF oDlg PIXEL
    
    @ 007, 007 SAY numOs  PROMPT "Ordem de Serviço:" SIZE 093, 011 OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
    @ 008, 080 SAY cNumOs                            SIZE 093, 011 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
    
    @ 022, 007 SAY solicitante PROMPT "Solicitante:" SIZE 056, 011 OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
    @ 023, 050 SAY cTecnico +" - "+ cDescTec          SIZE 300, 011 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
    
    @ 037, 007 SAY cData PROMPT "Data:" SIZE 027, 011 OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
    @ 038, 030 SAY dData                SIZE 050, 011 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
    
    
    fMSNewGetDados1()
  
  ACTIVATE MSDIALOG oDlg

Return

*****************************************************************************
Static Function fMSNewGetDados1()
*****************************************************************************

       
	For ix:= 1 To Len(aItens)
                  
		Aadd(aBrowse,{aItens[ix][12],;
		              aItens[ix][1] ,;
		              aItens[ix][2] ,;
		              aItens[ix][3] ,;
		              aItens[ix][4] ,;
		              aItens[ix][5] ,;
		              aItens[ix][6] ,;
		              aItens[ix][7] ,;
		              aItens[ix][8] ,;
 	      			  aItens[ix][9] ,;
 	      			  aItens[ix][10],;
 	      			  aItens[ix][11],;
 	      			  aItens[ix][13],;
 	      			  aItens[ix][14]})
	Next

    // ################################
    // Vetor com elementos do Browse ##      
    // Cria Browse                   ##
    // ################################
    oBrowse := TCBrowse():New( 72, 06, 590, 150,,;
               {''                                   ,; // 01
                'Item'                               ,; // 02
                'Part Number'                        ,; // 03
                'Produto'                            ,; // 04
                'Desc. Produto'                      ,; // 05
                'U.M.'                               ,; // 06
                'Almoxarifado'                       ,; // 07
                'Quantidade'                         ,; // 08
                'Endereço'                           ,; // 09
                'Num Serie'                          ,; // 10
                Iif(cFuncao=="E",'Estorno','Entrega'),; // 11
                'Saldo Requisição'                   ,; // 12
                'Saldo em Estoque'}                  ,; // 13
                {20,50,50,50}, oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
      
    // Seta vetor para a browse
    oBrowse:SetArray(aBrowse)
    // Monta a linha a ser exibina no Browse

    oBrowse:bLine := {||{       GetStatus(aBrowse[oBrowse:nAt][01])                       ,; // 01
                                aBrowse[oBrowse:nAt][02]                                  ,; // 02
                                aBrowse[oBrowse:nAt][03]                                  ,; // 03
                                aBrowse[oBrowse:nAT][04]                                  ,; // 04
                                aBrowse[oBrowse:nAt][05]                                  ,; // 05
                                aBrowse[oBrowse:nAt][13]                                  ,; // 06
                                aBrowse[oBrowse:nAt][06]                                  ,; // 07
                                Transform(aBrowse[oBrowse:nAt][07],'@E 99,999,999,999.99'),; // 08
                                aBrowse[oBrowse:nAt][08]                                  ,; // 09
                                aBrowse[oBrowse:nAt][09]                                  ,; // 10
                                Transform(aBrowse[oBrowse:nAt][10],'@E 99,999,999,999.99'),; // 11
                                Transform(aBrowse[oBrowse:nAt][11],'@E 99,999,999,999.99'),; // 12
                                Transform(aBrowse[oBrowse:nAt][12],'@E 99,999,999,999.99'),; // 13
                                aBrowse[oBrowse:nAt][14]                                  ,; // 14
                                }}

   	oBrowse:bLDblClick   := {|| AltItem(oBrowse:nAt,oBrowse:ColPos) }
   
Return()

*****************************************************************************
Static Function GetStatus(cStat)
*****************************************************************************

Local oCor := Nil

	If (cStat == "E")
		oCor:= oClose
	ElseIf (cStat == "A")
		oCor:= oOpen
	ElseIf (cStat == "P")
		oCor:= oPartial
	EndIf

Return(oCor)

*****************************************************************************
Static Function GeraMovimento()
*****************************************************************************

Local cDescri       := SPACE (30)
Local aItensExe     := {}
Local lRet          := .T.
Local aItensExe     := {}
Local cArmTecn      := ""
Local cStatus       := ""
Local cQry2         := ""
Local cRecOri       := 0
Local cRecDest      := 0
Local cDocAnt       := ""
Private lMsHelpAuto := .F.
Private lMsErroAuto := .F.
Private cCusMed     := GetMv("MV_CUSMED")
Private cCadastro   := OemToAnsi("Transferencias")
Private aRegSD3     := {}

	If cCusMed == "O"
		Private nHdlPrv             // Endereco do arquivo de contra prova dos lanctos cont.
		Private lCriaHeader := .T.  // Para criar o header do arquivo Contra Prova
		Private cLoteEst 	        // Numero do lote para lancamentos do estoque
		DbSelectArea("SX5")
		DbSeek(xFilial()+"09EST")
		cLoteEst:=IIF(Found(),Trim(X5Descri()),"EST ")
		Private nTotal := 0         // Total dos lancamentos contabeis
		Private cArquivo	        // Nome do arquivo contra prova
	EndIf

	
	For iy:= 1 to Len(oBrowse:aArray)
		If oBrowse:aArray[iy][01] <> 'E'
			If (oBrowse:aArray[iy][10] > oBrowse:aArray[iy][12] .And. cFuncao <> "E")
				lRet := .F.
				MsgAlert("Atenção! A entrega não pode ser maior que o Saldo em Estoque.")
				Exit
			EndIf
		EndIf
		
	Next
			
	If (lRet)		
		
		cArmTecn:= Posicione("AA1",1,xFilial("AA1")+Posicione("AB6",1,xFilial("AB6")+ZZZ->ZZZ_NUMOS,;
							 "AB6_RLAUDO"),"AA1_LOCAL") 

		For iy:= 1 to Len(oBrowse:aArray)
			If (Empty(oBrowse:aArray[iy][8]))
				MsgAlert("Atenção, Informe o Endereço e Número de Série dos Produtos.")
				lRet := .F.
			EndIf
		Next
			
		For ix:= 1 to Len(oBrowse:aArray)
			
			If(oBrowse:aArray[ix][10] == 0 .Or. (!lRet))
				Loop
			EndIf
			
			If(oBrowse:aArray[ix][8] <> "Não Controla" .And. ! Empty(oBrowse:aArray[ix][8]))
				cLocaliz := oBrowse:aArray[ix][8]
				cNumSer  := oBrowse:aArray[ix][9]
			ElseIf(oBrowse:aArray[ix][8] == "Não Controla")
				cLocaliz := ""
				cNumSer  := ""
			Else
				MsgAlert("Atenção, Informe o Endereço e Número de Série dos Produtos.")
				lRet := .F.
			EndIf
			
			If(lRet)
			
				If (cFuncao == "E")
				
					DbSelectArea("SD3");DbSetOrder(2)
					
					cDocAnt := ""
					
					If (DbSeek(xFilial("SD3")+oBrowse:aArray[ix][14]+oBrowse:aArray[ix][4]))
						cRecOri  := SD3->(Recno())
						cDocAnt  := SD3->D3_DOC
						SD3->(DbSkip())
						
						If (cDocAnt == SD3->D3_DOC)
							cRecDest := SD3->(Recno())
						EndIf
					EndIf
				Else
					cNumSD3  := GetSx8Num("SD3","D3_DOC")

				EndIf
				
				If a260Processa(oBrowse:aArray[ix][4],oBrowse:aArray[ix][6],oBrowse:aArray[ix][10],Iif(cFuncao == "E",cDocAnt,cNumSD3),dDataBase,;
				0,"","","",cNumSer,oBrowse:aArray[ix][8],oBrowse:aArray[ix][4],cArmTecn,cArmTecn,Iif(cFuncao == "E",.T.,.F.),Iif(cFuncao == "E",cRecOri,Nil),Iif(cFuncao == "E",cRecDest,Nil),"MATA260",Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
	        	  
			        If ( cFuncao <> "E")
				        If __lSX8 
				          	ConfirmSX8()
				        	lRet := .T.
						ElseIf ! __lSX8 
				        	RollBackSX8() 
				        	lRet := .F.
				        EndIf 
					Else
						lRet := .T.
					EndIf
				Endif
			
			EndIf				
		
			DbSelectArea("ZZZ")
			DbSetOrder(1)
		
			If (DbSeek(xFilial("ZZZ")+ZZZ->ZZZ_NUMOS+oBrowse:aArray[ix][4]+oBrowse:aArray[ix][2]))
				 
				If (ZZZ->ZZZ_SALDO - oBrowse:aArray[ix][10] == 0)
					cStatus := "E"
				ElseIf (ZZZ->ZZZ_SALDO - oBrowse:aArray[ix][10] > 0)
					cStatus := "P"
				Else
					cStatus := "A"
				EndIf
				 
				RecLock("ZZZ",.F.)
					ZZZ->ZZZ_STATUS := cStatus
					ZZZ->ZZZ_DOCSD3 := cNumSD3
				MsUnlock()
				
			EndIf
			
		Next
	
		Iif(Select("TMPZZZ2")!=0, TMPZZZ2->(DbCloseArea()),)
		
		cQry2 := "Select ZZZ_NUMOS, ZZZ_STATUS, Count(*) TOTAL, "+chr(13)
		cQry2 += "(Select Count(*) From "+RetSqlName("ZZZ")+" Where ZZZ_NUMOS = '"+ZZZ->ZZZ_NUMOS+"' And D_E_L_E_T_ <> '*' And ZZZ_FILIAL = '"+xFilial("ZZZ")+"') As TOTALOS "+chr(13) 
		cQry2 += "From "+RetSqlName("ZZZ")+" "+chr(13) 
		cQry2 += "Where ZZZ_NUMOS = '"+ZZZ->ZZZ_NUMOS+"' And "+chr(13) 
		cQry2 += "D_E_L_E_T_ <> '*' And"+chr(13) 
		cQry2 += "ZZZ_FILIAL = '"+xFilial("ZZZ")+"' "+chr(13) 
		cQry2 += "Group By ZZZ_NUMOS, ZZZ_STATUS"+chr(13) 
		cQry2 += "Order By ZZZ_STATUS"+chr(13) 
		cQry2 := ChangeQuery(cQry2)
	
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry2), "TMPZZZ2", .T., .T. )

		DbSelectArea("TMPZZZ2"); DbGoTop()
		
		While ! Eof()
		
			If ( TMPZZZ2->ZZZ_STATUS = 'A' .And. TMPZZZ2->TOTAL  == TMPZZZ2->TOTALOS)
				AtuAprovAB6('R')
				Exit
			ElseIf ( TMPZZZ2->ZZZ_STATUS = 'E' .And. TMPZZZ2->TOTAL  == TMPZZZ2->TOTALOS)
				AtuAprovAB6('L')
				Exit
			EndIf
			
			DbSkip()
		
		EndDo
		
		If (lRet)

			DbSelectArea("ZZZ")
			DbSetOrder(1)
			
			For ix:= 1 To Len(oBrowse:aArray)
				
				If(oBrowse:aArray[ix][10] == 0)
					Loop
				EndIf
				
				If (DbSeek(xFilial("ZZZ")+ZZZ->ZZZ_NUMOS+oBrowse:aArray[ix][4]+oBrowse:aArray[ix][2]))
				
					RecLock("ZZZ",.F.)
						ZZZ->ZZZ_LOCALI := Iif(cFuncao <> "E",oBrowse:aArray[ix][8],"")
						ZZZ->ZZZ_NUMSER := Iif(cFuncao <> "E",oBrowse:aArray[ix][9],"")
						ZZZ->ZZZ_SALDO  := Iif(cFuncao == "E",oBrowse:aArray[ix][7],oBrowse:aArray[ix][11] - oBrowse:aArray[ix][10]) 
					MsUnlock()
				Else
					lRet := .F.
					Exit
				EndIf
			
			Next
		EndIf
		
	EndIf
		
	If (lRet)
		oDlg:End()
	EndIf
	
	
Return()

*****************************************************************************
Static Function AltItem(nLin,nPos)        
*****************************************************************************

Local aArrayF4 := {} 
Local cQry2    := ""

Static oDlg3
Static oButton1
Static oFont1 := TFont():New("MS Sans Serif",,022,,.T.,,,,,.F.,.F.)
Static oFont2 := TFont():New("MS Sans Serif",,022,,.F.,,,,,.F.,.F.)
Static oGetQtd
Static cGetQtd := ""
Static oSay1
Static oSay2
Static oSay3
Static oSay4
Static oSay6

Private oQual

	
	If (nPos == 9)
		//Se controla Endereço
		If (AllTrim(oBrowse:aarray[nLin][8]) <> "Não Controla")
		
			Iif(Select("TMPSBF")!=0, TMPSBF->(DbCloseArea()),)	
		
			cQry2 := "Select BF_FILIAL, BF_PRODUTO, BF_LOCAL, BF_LOCALIZ, BF_NUMSERI From "+RetSqlName("SBF")+" SBF(NoLock) "+chr(13)
			cQry2 += "Where "+chr(13)
			cQry2 += "BF_PRODUTO = '"+AllTrim(oBrowse:aarray[nLin][4])+"' And "+chr(13)
			cQry2 += "BF_FILIAL = '"+xFilial("SBF")+"' And "+chr(13)
			cQry2 += "BF_LOCAL = '"+AllTrim(oBrowse:aarray[nLin][6])+"' And "+chr(13)
			cQry2 += "D_E_L_E_T_ <> '*' "+chr(13)
			cQry2 += "Order By BF_FILIAL, BF_PRODUTO, BF_LOCAL, BF_LOCALIZ, BF_NUMSERI "
			cQry2 := ChangeQuery(cQry2)
		
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry2), "TMPSBF", .T., .T. )
	
			DbSelectArea("TMPSBF"); DbGoTop()
		
			While ! Eof()
				Aadd(aArrayF4,{TMPSBF->BF_LOCALIZ,TMPSBF->BF_NUMSERI})
				DbSkip()
			EndDo
			
			If (! Empty(aArrayF4) )
				DEFINE MSDIALOG oDlg2 TITLE "Alteração da requisição: " From 09,0 To 400,600 COLORS 0, 16777215 PIXEL
				
				@ 1.1, .7  Say "Produto :"
				@ 1  , 3.7 Say AllTrim(oBrowse:aarray[nLin][4])
				@ 2.4,.7 LISTBOX oQual VAR cVar Fields HEADER "Endereço","Número de Serie" SIZE 285,140 ON DBLCLICK (nOpca := 1,oDlg:End())
				
				oQual:SetArray(aArrayF4)
				oQual:bLine:={ ||{aArrayF4[oQual:nAT,1],aArrayF4[oQual:nAT,2]}}
				
						
				@018,208   BUTTON "Confirmar" SIZE 040, 10 PIXEL OF oDlg2 ACTION (nOpca := 1,AtuGrid(oQual:aarray[oQual:nAT][1],oQual:aarray[oQual:nAT][2],nLin,nPos),oDlg2:End())
				@006,250   BUTTON "Limpar"    SIZE 040, 10 PIXEL OF oDlg2 ACTION (nOpca := 1,AtuGrid("L",oQual:aarray[oQual:nAT][2],nLin,nPos),oDlg2:End()) 
				@018,250   BUTTON "Cancelar " SIZE 040, 10 PIXEL OF oDlg2 ACTION oDlg2:End()
				
				ACTIVATE MSDIALOG oDlg2 VALID (nOAT := oQual:nAT,.T.) CENTERED
			Else
				MsgAlert("Atenção, sem itens a exibir.")
			EndIf
		ElseIf (AllTrim(oBrowse:aarray[nLin][8]) == "Não Controla")
			MsgAlert("Atenção, este produto não possui controle de endereçamento.")
		ElseIf (cFuncao == "E")
			MsgAlert("Atenção, não é possível alterar o Endereço /N.S. para opção de estorno.")
		EndIf
		
		
	ElseIf (nPos == 11)
		
		nGetQtd := oBrowse:aarray[nLin][10]
		
		//Funcao para a quantidade
		DEFINE MSDIALOG oDlg3 TITLE "Alteração Entrega" FROM 000, 000  TO 200, 240 COLORS 0, 16777215 PIXEL
		    @ 005, 005 SAY oSay1 PROMPT "Quantidade Total:" SIZE 084, 013 OF oDlg3 FONT oFont1 COLORS 0, 16777215 PIXEL
		    @ 005, 092 SAY oSay2 PROMPT "0" SIZE 025, 011 OF oDlg3 FONT oFont2 COLORS 0, 16777215 PIXEL
		    @ 020, 005 SAY oSay3 PROMPT "Saldo Restante:" SIZE 076, 013 OF oDlg3 FONT oFont1 COLORS 0, 16777215 PIXEL
		    @ 020, 092 SAY oSay6 PROMPT "0" SIZE 025, 011 OF oDlg3 FONT oFont2 COLORS 0, 16777215 PIXEL
		    @ 035, 005 SAY oSay4 PROMPT "Entregar:" SIZE 053, 013 OF oDlg3 FONT oFont1 COLORS 0, 16777215 PIXEL
		    @ 035, 092 MSGET oGetQtd VAR nGetQtd SIZE 025, 010 OF oDlg3 COLORS 0, 16777215 PICTURE '@E 9999' PIXEL
		    @ 070, 078 BUTTON oButton1 PROMPT "Confirmar" ACTION (AtuGrid2(nGetQtd,nLin)) SIZE 037, 012 OF oDlg3 PIXEL
	  ACTIVATE MSDIALOG oDlg3
	
	EndIf	

Return() 	

*****************************************************************************
Static Function AtuGrid(cEndeco,cNumSerie,nLin,nPos) 
*****************************************************************************

Local lRet := .T.

	If (cEndeco == "L")
	
		oBrowse:aarray[nLin][8]:= ""
		oBrowse:aarray[nLin][9]:= ""
		oQual:bLDblClick   := {|| oDlg2:End() }
		oBrowse:DrawSelect()
	
	Else
	
		For ix:= 1 To Len(oBrowse:aarray)
		
			If (oBrowse:aarray[ix][9] == cNumSerie)
				lRet := .F.
				Exit
			Endif
		
		Next
	
		If (lRet)	
			oBrowse:aarray[nLin][8]:= cEndeco
			oBrowse:aarray[nLin][9]:= cNumSerie
		
			oQual:bLDblClick   := {|| oDlg2:End() }
			oBrowse:DrawSelect()
		Else
			MsgAlert("O número de série escolhido já foi selecionado anteriormente.")
		EndIf
	
	EndIf
	
Return()

*****************************************************************************
Static Function AtuGrid2(nGetQtd,nLin) 
*****************************************************************************

Local lRet := .F.

	If (cFuncao <> "E")
		If (AllTrim(oBrowse:aarray[nLin][8]) <> "Não Controla" .And. nGetQtd > 1)
			MsgAlert("Não é possível alterar a quantidade de um produto com controle de N.S.")
		ElseIf (nGetQtd > oBrowse:aarray[nLin][11])
			MsgAlert("A quantidade de entrega não pode ser maior que o Saldo.")
		ElseIf (nGetQtd < 0)
			MsgAlert("Valor negativo não é aceito.")
		Else
			lRet := .T.
		EndIf
	ElseIf (cFuncao == "E")
		If (nGetQtd <> oBrowse:aarray[nLin][7] .And. nGetQtd <> 0)
			MsgAlert("A quantidade a estornar deve ser a mesma movimentada")
		Else
			lRet := .T.
		EndIf
	EndIf
	
	If (lRet)
		oBrowse:aarray[nLin][10]:= nGetQtd
		oBrowse:DrawSelect()
		oDlg3:End()
	EndIf
	
Return()

*****************************************************************************
Static Function AtuAprovAB6(cNovoStatus)
*****************************************************************************
						
Local cStatus := cNovoStatus
								
	DbSelectArea("AB6");DbSetOrder(1)
	
	If (DbSeek(xFilial("AB6")+ZZZ->ZZZ_NUMOS))
		Iif(AB6->AB6_APROV == 'S',cStatus:="P","")
		Iif(AB6->AB6_APROV == 'P',cStatus:="S","")
		
			RecLock("AB6",.F.)
				AB6->AB6_APROV := cStatus
			MsUnlock()
	EndIf
						
Return()
