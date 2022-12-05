#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"   


#DEFINE CHINI CHR(2)
#DEFINE CHFIM CHR(3)

/*
Criado por: Isabel Melo - Veza Consultoria - 06/01/17
Função:		Realizar a impressão da etiqueta térmica na impressora Argox OS 214 Plus dos pedidos de venda da empresa Pacar.
Alterações:
23/06/20 - Substituição do campo nome fantasia pelo campo razão social
*/

USER FUNCTION ImpEtqPV(cIPedIni,cIPedFim,iQtd,cTpEtq)
Local cFile		:= "" 
Local nEtqPV	
Local nEtqPV2
Local I:=0       
Local aSalvAmb 	:= GetArea() 

Private cQuery :=  ""
Private lImp := .T.

	// Se o usuário escolher para gerar somente Itens, ele irá gerar uma tela para seleção.
	If cTpEtq == 'I' .and. lCheckBox2
		MntQryIte(cIPedIni,cIPedFim)
	EndIf

	// Caso, o usuário selecione mais de um pedido, ele não irá seguir com a impressão.
	If lImp = .F.
		Return()
	EndIF

	strSql := "SELECT C5_CLIENTE,C5_LOJACLI,A1_NOME,A1_NREDUZ,CONVERT(varchar, CAST(C5_EMISSAO AS datetime), 103) AS C5_EMISSAO,C6_NUM,C6_ITEM,C6_PRODUTO,C6_DESCRI,C6_QTDVEN "
	strSql += "FROM " + RetSqlName("SC5") + " (NOLOCK)  AS SC5 "
	strSql += "LEFT JOIN " + RetSqlName("SC6") + " AS SC6 ON C6_NUM=C5_NUM AND C6_CLI=C5_CLIENTE and C6_LOJA=C5_LOJACLI "
	strSql += "LEFT JOIN " + RetSqlName("SA1") + " AS SA1 ON A1_COD=C5_CLIENTE AND A1_LOJA=C5_LOJACLI "
	strSql += "WHERE SC5.D_E_L_E_T_ <> '*' AND SC6.D_E_L_E_T_ <> '*' AND SA1.D_E_L_E_T_ <> '*' "
	strSql += "AND C5_NUM BETWEEN '" + cIPedIni + "' AND '" + cIPedFim + "' "
	If cTpEtq == 'I' .And. lCheckBox2
		strSql += "AND C6_ITEM IN ("+ _CITENS +") "
	EndIf
	strSql += "ORDER BY C6_NUM,C6_ITEM " 
		
	If Select("TMPSC5") <> 0
		DbSelectArea("TMPSC5")
		dbCloseArea()
 	EndIf
 	dbUseArea( .T., "TOPCONN", TcGenQry(,,strSql), "TMPSC5", .T., .T. ) 
	DBGOTOP()
	cPedAnt := ""
	Do While !Eof()
		If cPedAnt <> TMPSC5->C6_NUM
			cPedAnt := TMPSC5->C6_NUM             
			If cTpEtq=="C" .or. cTpEtq=="ALL"
				// Imprime etiqueta relativa ao pedido de venda 
				FOR I:=1 TO iQtd
					// Escreve o texto mais a quebra de linha CRLF   
			       	cFile := "c:\temp\" + "eti" + ALLTRIM(STR(Randomize(1,1000))) + ".txt"  
			   		nEtqPV := fCreate(cFile) 
			   		If nEtqPV == -1 
						MsgStop("Falha ao criar arquivo - erro "+str(ferror())) 
						Return 
					Endif 
			       fWrite(nEtqPV,CHINI +"L" + CRLF )            
			       fWrite(nEtqPV,"191100200400040" + Ltrim(Rtrim(TMPSC5->C5_EMISSAO)) + CRLF) 
			       //fWrite(nEtqPV,"191100200800040" + Ltrim(Rtrim(TMPSC5->A1_NREDUZ)) + CRLF) 
				   fWrite(nEtqPV,"191100200800040" + Ltrim(Rtrim(TMPSC5->A1_NOME)) + CRLF) 
			       fWrite(nEtqPV,"191100201200040" + "PEDIDO: " + Ltrim(Rtrim(TMPSC5->C6_NUM)) + CRLF) 
			       fWrite(nEtqPV,"E" + CRLF)
			       fClose(nEtqPV)
			       
			       COPY FILE (cFile) TO "LPT1" 
			       WinExec("TYPE " + cFile + "> LPT1")
			       Sleep( 1000 )  
				NEXT
			Endif                            
		Endif		                         
		If cTpEtq=="I" .or. cTpEtq=="ALL"		
			//Imprime etiquetas de itens     
	       	cFile := "c:\temp\" + "eti" + ALLTRIM(STR(Randomize(1,1000))) + ".txt"  
	   		nEtqPV2 := fCreate(cFile) 
	   		If nEtqPV2 == -1 
				MsgStop("Falha ao criar arquivo - erro "+str(ferror())) 
				Return 
			Endif 
			fWrite(nEtqPV2,CHINI +"L" + CRLF )            
			//fWrite(nEtqPV2,"191100101200035" +  Ltrim(Rtrim(TMPSC5->C6_NUM)) + " "+ Ltrim(Rtrim(TMPSC5->C6_ITEM)) + " - " + Ltrim(Rtrim(TMPSC5->A1_NREDUZ)) + CRLF) 
			fWrite(nEtqPV2,"191100101200035" +  Ltrim(Rtrim(TMPSC5->C6_NUM)) + " "+ Ltrim(Rtrim(TMPSC5->C6_ITEM)) + " - " + Ltrim(Rtrim(TMPSC5->A1_NOME)) + CRLF) 
			fWrite(nEtqPV2,"191100100800035" + Ltrim(Rtrim(TMPSC5->C6_DESCRI)) + CRLF) 
			fWrite(nEtqPV2,"191100100400035" + "QUANTIDADE: " + LTRIM(RTRIM(STR(TMPSC5->C6_QTDVEN))) + CRLF) 
	 		fWrite(nEtqPV2,"E" + CRLF)
			fClose(nEtqPV2)          
	
	        COPY FILE (cFile) TO "LPT1"    
	       	//ALERT ("VAI MANDAR TYPE")
	       	WinExec("TYPE " + cFile + "> LPT1")
	       	//ALERT ("ENVIOU MANDAR TYPE")	        
		EndIf	

		Sleep( 1000 )
		
		DBSELECTAREA("TMPSC5")
		DBSKIP()
	End

	Msginfo("Etiqueta impressa com sucesso!","AVISO!")       
   
	// Restaura os ambientes de dados anteriores
	RestArea( aSalvAmb )

Return()

User Function EtqPV()  
Local oButton1
Local oButton2    
Private lCheckBox2  := .F.
Private oCheckBox2 
Private _lSelIt		:= .F.
Private _CITENS		:= ""
Private ocPedIni 
Private ocPedFim	
Private ocQtdEtq
Private cPedIni		:= space(6)
Private cPedFim		:= space(6) 
Private iQtdEtq		:= 3
Private oDlgPedVen	:= NIL        
Private cTpEtq		:= "ALL"
Private aTpEtq		:= { "C=Cabecalho","I=Itens","ALL=Ambas" } 
Private oCboTpEtq	:= Nil
Private aListBox1   := {}
Private oListBox1

	If Funname()="MATA410" 
		cTpEtq := "I"
		U_ImpEtqPV(SC5->C5_NUM,SC5->C5_NUM,iQtdEtq, cTpEtq)
		Return	
	Endif

	If Funname()="MATA455"
		U_ImpEtqPV(SC9->C9_PEDIDO,SC9->C9_PEDIDO,iQtdEtq)
		Return	
	Endif
      
	cTitTela := "IMPRESSÃO DA ETIQUETA DO PEDIDO DE VENDA"
	
	DEFINE MSDIALOG oDlgPedVen TITLE cTitTela FROM 0,0 TO 150,500 PIXEL
	                                                
	@ 006,020 SAY "Pedido de:" 					SIZE 050,7	PIXEL OF oDlgPedVen 
	@ 006,105 MSGET ocPedIni	VAR cPedIni 	SIZE 040,5  Picture PesqPict("SC5","C5_NUM")	PIXEL OF oDlgPedVen F3 "SC5" WHEN .T.
	@ 016,020 SAY "Pedido Até: "		      	SIZE 050,7 	PIXEL OF oDlgPedVen 
	@ 016,105 MSGET ocPedFim	VAR cPedFim		SIZE 040,5  Picture PesqPict("SC5","C5_NUM")	PIXEL OF oDlgPedVen F3 "SC5" WHEN .T.
	@ 026,020 SAY "Qtd. Etiquetas PV: "		    SIZE 050,7 	PIXEL OF oDlgPedVen 
	@ 026,105 MSGET ocQtdEtq	VAR iQtdEtq		SIZE 040,5  PIXEL OF oDlgPedVen WHEN .T.
	@ 036,020 SAY "Tipo Etiqueta: "		    	SIZE 050,7 	PIXEL OF oDlgPedVen 
	@ 036,105 COMBOBOX oCboTpEtq				VAR cTpEtq ITEMS aTpEtq	SIZE 80,5 PIXEL OF oDlgPedVen        	
	@ 046,020 CheckBox oCheckBox2 Var lCheckBox2 Prompt "Sel. Itens." Size 040,5 PIXEL OF oDlgPedVen
	
	DEFINE SBUTTON oButton1 FROM 060,100 ACTION U_ImpEtqPV(cPedIni,cPedFim,iQtdEtq,cTpEtq) ENABLE OF oDlgPedVen
	oButton1:cCaption := "&Imprime"
	oButton1:cToolTip := "Imprime"
		
	DEFINE SBUTTON oButton2 FROM 060,150 ACTION {||oDlgPedVen:End(),nOpc := 0} ENABLE OF oDlgPedVen
	oButton2:cCaption := "&Sair"
	oButton2:cToolTip := "Sair" 
	
	ACTIVATE MSDIALOG oDlgPedVen 

Return

//Trazendo os dados para mostrar os itens selecionaveis.
Static Function MntQryIte(cIPedIni,cIPedFim)

		If lCheckBox2 .And. cIPedIni <> cIPedFim
			MsgAlert("Mais de um Pedido selecionado. Utilize apenas um pedido por vez", "Atencao!")
			//lCheckBox2 := .F.
			lImp := .F.
			Return()
		EndIf

		cQuery := "SELECT C6_NUM, C6_ITEM, C6_PRODUTO, C6_DESCRI "
		cQuery += "FROM " + RetSqlName("SC6") + " (NOLOCK)  AS SC6 "
		cQuery += "WHERE D_E_L_E_T_ <> '*' "
		cQuery += "AND C6_NUM = '"+ cIPedIni +"' "
		cQuery += "ORDER BY C6_NUM, C6_ITEM "

		If Select("TMPSC6") <> 0
			DbSelectArea("TMPSC6")
			dbCloseArea()
		EndIf
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPSC6", .T., .T. ) 
		DbGoTop()

		//Do While !EOF("TMPSC6") 
		Do While ! TMPSC6->(EoF())

			Aadd(aListBox1,{.F.,Alltrim(TMPSC6->C6_ITEM),Alltrim(TMPSC6->C6_PRODUTO),Alltrim(TMPSC6->C6_DESCRI)})

			DbSkip()
		ENDDO

		DbSelectArea("TMPSC6")
		dbCloseArea()

		SelIte()

Return()

//Criando telas para quando, o usuário quiser selecionar os itens do PV.
Static Function SelIte()

	Local oCheckBox1
	Local lCheckBox1 := .F.
	Private _oDlg
    Private oOk     	:= LoadBitmap( GetResources(), "CHECKED" )
	Private oNo     	:= LoadBitmap( GetResources(), "UNCHECKED" )
    Private CVal        := Nil
    Private oCurso_
    Private VISUAL      := .F.                        
    Private INCLUI      := .F.                        
    Private ALTERA      := .F.                        
    Private DELETA      := .F.                        

	DEFINE MSDIALOG _oDlg TITLE "Itens PV" FROM C(312),C(491) TO C(689),C(1027) PIXEL

	// Cria Componentes Padroes do Sistema
    @ C(010),C(010) Say "Selecione os itens:" Size C(050),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(060),C(010) CheckBox oCheckBox1 Var lCheckBox1 Prompt "Marca/Desmarca todos" Size C(075),C(008) PIXEL OF _oDlg ON CLICK( AEval( aListBox1,{ | x | x[ 1 ] := lCheckBox1 } ), oListBox1:Refresh() )
	@ C(090),C(010) Button "Confirma"       Size C(037),C(012)  Action( _oDlg:end(), gitens() ) PIXEL OF _oDlg
	@ C(120),C(010) Button "Cancela"      Size C(037),C(012)  Action( _oDlg:end(), lCheckBox2 := .F.  ) OF _oDlg PIXEL

    @ C(008),C(080) LISTBOX oListBox1 VAR cVar FIELDS Size C(175),C(170) OF _oDlg PIXEL ON DBLCLICK ( aListBox1[ oListBox1:nAt, 1 ] := !aListBox1[ oListBox1:nAt , 1 ], oListBox1:Refresh() )

    oListBox1:AddColumn( TcColumn():New( " ",        	{ || If( aListBox1[ oListBox1:nAT, 01 ] , oOk, oNo ) },,,,,,.T.,.F.,,,,.F. ) )
	oListBox1:AddColumn( TcColumn():New( "Item",		{ || aListBox1[ oListBox1:nAT, 02 ] },,,, "LEFT",,.F.,.F.,,,,.F. ) )
	oListBox1:AddColumn( TcColumn():New( "Produto",		{ || aListBox1[ oListBox1:nAT, 03 ] },,,, "LEFT",,.F.,.F.,,,,.F. ) )
	oListBox1:AddColumn( TcColumn():New( "Descricao",	{ || aListBox1[ oListBox1:nAT, 04 ] },,,, "LEFT",,.F.,.F.,,,,.F. ) )
    oListBox1:SetArray( aListBox1 )

    ACTIVATE MSDIALOG _oDlg CENTERED 

	aListBox1 := {}
	
Return()

//Alimentando a váriavel _CITENS, com os itens selecionados pelo usuário.
Static Function gitens()

	Local nCont := 0 

	_CITENS := ""

	For nCont := 1 to len(aListBox1)

		If aListBox1[nCont][1]
			_CITENS += "'"+ aListBox1[nCont][2] + "'," //+ IIf(nCont == Len(aListBox1),"",",")
		EndIf

	 Next nCont

	// remover o último caracter, no caso a virgula para não dar erro na query.
	_CITENS := SUBSTR(_CITENS,1,Len(Alltrim(_CITENS))-1)

	 aListBox1 := {}

Return()

Static Function C(nTam)  

	Local nHRes	:= oMainWnd:nClientWidth	// Resolucao horizontal do monitor     
	
		If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
			nTam *= 0.8                                                                
		ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600                
			nTam *= 1                                                                  
		Else	// Resolucao 1024x768 e acima                                           
			nTam *= 1.28                                                               
		EndIf                                                                         
                                                                                
	//Tratamento para tema "Flat"                                                                                            
	
	If "MP8" $ oApp:cVersion                                                      
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()                      
			nTam *= 0.90                                                            
		EndIf                                                                      
	EndIf                                                                         
	
Return Int(nTam)   

