#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} SI001FAT
Realiza importação de arquivo CSV atualizando pedidos de venda e após gera doocumento de saída para cada pedido.
@author Bruno Silva
@since 23/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function SI001FAT()

	Private cPerg := Padr("SI001FAT", LEN(SX1->X1_GRUPO), " ")
	Private _aErro := {} 
	Private _cRotina := "Importação Pedidos de Venda"
	ValPerg()
	If !Pergunte(cPerg,.T.)
		Return
	EndIf

	Processa({|| ProcArqCSV()})
Return
 
Static Function ProcArqCSV()
	
	Local cLinha  := ""
	Local lPrim   := .T.	
	Local aDados  := {}	
	Local aItens  := {}
	Local aCabec  := {}
	Local i
	Local cArqCSV    := Alltrim(MV_PAR01) + Alltrim(MV_PAR02)
	Local cNumPed := ""
	Local cLogErro
	Local lOk
	Local cMsg := ""
	Local nE
	Private _nIteAtu := 0
 
	If !File(cArqCSV)
		MsgStop("O arquivo " + cArqCSV + " não foi encontrado. A importação será abortada!",_cRotina)
		Return
	EndIf
	 
	FT_FUSE(cArqCSV)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	While !FT_FEOF()	 
		IncProc("Lendo arquivo texto...")	 
		cLinha := FT_FREADLN()
		If lPrim
			//aCampos := Separa(cLinha,";",.T.)
			lPrim := .F.
		Else
			AADD(aDados,Separa(cLinha,";",.T.))
		EndIf	 
		FT_FSKIP()
	EndDo
		
	//Begin Transaction
	ProcRegua(Len(aDados))
	
	For i := 1 to Len(aDados)
		 
		IncProc("Importando Pedidos...")
		//      1;     2;        3;     4;          5;    6;       7;           8;       9;        10  ;        11;     12;        13;      14;       15;    16
		//Cliente;Pedido;Municipio;Tabela;Cond. PAGTO;Banco;Natureza;Cod Msg Serv;Linha 01;UF Prestação;Mun. Prest;Produto;Quantidade;Valor Un;Quant Lib;Tipo Saída
		//000001;036162;000015; ;103;104;101029;229;"""Servico de INSPECAO, conforme pedido 4506175405.""";BA;33307;FAT0003;1;R$1.010,36;1;507
		//		alert(len(aDados[i]))	
		If Len(aDados[i]) >= 15
			
			If cNumPed == aDados[i,2]				
				If Len(aItens) == 0 
					aItens := aClone(fBuscaItens(cNumPed))
				EndIf
				
				lOk := .T.
			Else			
				If Len(aItens) > 0 .and. Len(aCabec) > 0			
					fImportPed(aCabec,aItens,cNumPed)
				EndIf	
					
					aCabec := {}
					SC5->(dbSetOrder(1))
					SC5->(dbSeek(xFilial("SC5") + aDados[i,2] ))
					aadd(aCabec,{"C5_NUM"     , aDados[i,2]  ,Nil})	
					//aadd(aCabec,{"C5_TIPO"    , SC5->C5_TIPO ,Nil})	
					aadd(aCabec,{"C5_CLIENTE" , aDados[i,1]  ,Nil})	
					//aadd(aCabec,{"C5_LOJACLI" , "01"         ,Nil})
					aadd(aCabec,{"C5_NATUREZ" , aDados[i,7]  ,Nil})
					aadd(aCabec,{"C5_YMUN"    , aDados[i,3]  ,Nil})
					aadd(aCabec,{"C5_BANCO"   , aDados[i,6]  ,Nil})
					aadd(aCabec,{"C5_ESTPRES" , aDados[i,10] ,Nil})
					aadd(aCabec,{"C5_MUNPRES" , aDados[i,11] ,Nil})
					aadd(aCabec,{"C5_TABELA"  , "   "        ,Nil})	
					aadd(aCabec,{"C5_CONDPAG" , aDados[i,5]  ,Nil})
					aadd(aCabec,{"C5_YCODMSG" , aDados[i,8]  ,Nil})							
					aadd(aCabec,{"C5_YMSG01"  , StrTran(aDados[i,9],'"""','"')  ,Nil})	
					                                                                                                  								
					cNumPed := aDados[i,2]
					aItens := aClone(fBuscaItens(cNumPed))
					lOk := .T.					
			EndIf 
			If lOk
				aLinha := {}
				//aadd(aLinha,{"LINPOS",     "C6_ITEM",     StrZero(Len(aItens)+1,2)})
				aadd(aLinha,{"AUTDELETA" ,  "N",           Nil})
				aAdd(aLinha,{"C6_ITEM"  ,StrZero(_nIteAtu ,2),Nil}) // Numero do Item no Pedido			
				aadd(aLinha,{"C6_PRODUTO", aDados[i,12],        Nil})
				aadd(aLinha,{"C6_QTDVEN" ,  Val(aDados[i,13]) ,             Nil})
				aadd(aLinha,{"C6_PRCVEN" ,  fFomatVal(aDados[i,14]),          Nil})
				aadd(aLinha,{"C6_PRUNIT" ,  fFomatVal(aDados[i,14]),          Nil})
				//aadd(aLinha,{"C6_VALOR",   fFomatVal(aDados[i,14]*,          Nil})
				aadd(aLinha,{"C6_TES",     aDados[i,16],        Nil})
				//aadd(aLinha,{"C6_CC" ,   "A0102020101030201",        Nil})								
				aadd(aItens, aLinha)
				_nIteAtu ++
				If i == Len(aDados)				
					fImportPed(aCabec,aItens,aDados[i,2])
				EndIf
			EndIf
		EndIf		
	Next i
		
	//End Transaction
 
	FT_FUSE()
If Len(_aErro) == 0
	MsgInfo("Importação dos Pedidos de Venda concluída com sucesso!","Importação Pedidos de Venda",_cRotina)
ELse
	MsgAlert("Importação dos Pedidos de Venda foi concluída mas existem inconsistências na importação, verique a tela a seguir!",_cRotina)
	//u_ShowArray(_aErro)
	cMsg := ""
	For nE := 1 To Len(_aErro)
		cMsg += _aErro[nE] + CHR(13)+ CHR(10)
	Next nE
	MsgAlert(cMsg, _cRotina)
	
EndIf	

 
Return

// Formata string para valor de numerico
Static Function fFomatVal(cValor)
	Local nValor := 0
	
	cValor := StrTran(cValor, "R$","")
	cValor := StrTran(cValor, ".","")
	cValor := StrTran(cValor, ",",".")
	nValor := Val(cValor)

Return nValor


// Busco itens do pedido excluindo todos menos o primeira linha
Static Function fBuscaItens(cNumPed)
	Local aItens := {}
	Local aLinha := {}
	Local aAreaSC5 := SC5->(GetArea())
	Local aAreaSC6 := SC6->(GetArea())
	Local cDeleta := "N"
	Local lFirst := .T.
	
	_nIteAtu := 1
	
	dbSelectArea("SC6")
	SC6->(dbSetOrder(1))
	If SC6->(dbSeek(xFilial("SC6") + cNumPed))
		While !SC6->(EOF()) .And. SC6->(C6_FILIAL + C6_NUM)  == xFilial("SC6") + cNumPed
		aLinha := {}
			If (SC6->C6_QTDENT > 0 .And. ! Empty(SC6->C6_NOTA) .And. ! Empty(SC6->C6_SERIE))// .Or. lFirst			
				aadd(aLinha,{"AUTDELETA",  "N",           Nil})
				_nIteAtu ++
				lFirst := .F.
			Else
				aadd(aLinha,{"AUTDELETA",  "S",           Nil})
			EndIf			
			//aadd(aLinha,{"LINPOS",     "C6_ITEM",    SC6->C6_ITEM})
			aAdd(aLinha, {"C6_ITEM"   , SC6->C6_ITEM    ,    Nil}) 			
			aadd(aLinha,{"C6_PRODUTO" , SC6->C6_PRODUTO ,    Nil})
			aadd(aLinha,{"C6_QTDVEN"  , SC6->C6_QTDVEN  ,    Nil})
			aadd(aLinha,{"C6_PRCVEN"  , SC6->C6_PRCVEN  ,    Nil})
			aadd(aLinha,{"C6_PRUNIT"  , SC6->C6_PRUNIT  ,    Nil})
			//aadd(aLinha,{"C6_VALOR"   , SC6->C6_VALOR   ,    Nil})
			aadd(aLinha,{"C6_TES"     , SC6->C6_TES     ,    Nil})
			//aadd(aLinha,{"C6_CC" ,   "A0102020101030201",        Nil})
			aadd(aItens, aLinha)
			cDeleta := "S"
			SC6->(dbSkip())
		EndDo
	EndIf	
		
	RestArea(aAreaSC5)
	RestArea(aAreaSC6)
Return aItens

Static Function fImportPed(aCab,aItens,cNumPed)
	Local nC
	Local cLogErro
	Local lOk := .T.
	Local aAreaSC5 := SC5->(GetArea())
	
	//U_ShowArray(aCab)
	
	lMsErroAuto    := .F.
	lAutoErrNoFile := .F.
		
	// Verifica se o pedido existe 
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	If ! SC5->(dbSeek(xFilial("SC5") + cNumPed))
		lOk := .F.
		cLogErro := "O pedido de venda " + cNumPed + " não está cadastrado. A importação não será realizada!" 
		aAdd(_aErro,cLogErro)
		MsgStop(cLogErro , _cRotina)	
	EndIf
	
	If lOk		
		MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCab, aItens, 4, .F.) // Alteracao		
		If !lMsErroAuto
			//ConOut("Alterado com sucesso! " + cDoc)
			If .T. //MsgYesNo("Pedido de venda "+ cNumPed +" atualizado com sucesso. Deseja gerar a NF deste pedido?",_cRotina)
				fGeraNF(cNumPed)				
			EndIf
		Else	     		   
		   MostraErro()		   
		   aAdd(_aErro,"Erro na importação do pedido de venda "+cNumPed+".")		   
		EndIf
	EndIf
	
	RestArea(aAreaSC5)
Return

// Funcao que gera a NF de saida do pedido
Static Function fGeraNF(cNumPed)	
	
	Local cTitulo
	Local aPvlNfs := {}
	Local cSerie  := ""	
	Local lSel
	Local lFat 
	Local aLog := {}
	Local cNf
	Local nX
	Local cArqLog
	Local cSeq
	Local _aPvlNfs   := {}
	Local aBloqueio := {{"","","","","","","",""}}
	Local cLogErro := ""
	Local cCRLF := CHR(13) + CHR(10) 
	Private lMsHelpAuto  
	Private lMsErroAuto  		
	
	dbSelectArea("SC9")
	SC9->(dbSetOrder(1))
	
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
						
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
						
	dbSelectArea("SC6")
	SC6->(dbSetOrder(1))
						
	dbSelectArea("SB2")
	SB2->(dbSetOrder(1))
						
	dbSelectArea("SF4")
	SF4->(dbSetOrder(1))
						
	dbSelectArea("SE4")
	SE4->(dbSetOrder(1))
	
	lSel := .F.
	lFat := .T.
	lBloq := .F.	
		
	If SC5->(dbSeek(xFilial("SC5") + cNumPed))
			
		aPvlNfs := {}	
		aBloqueio := {}	
		// Liberacao de pedido
		Ma410LbNfs(2,@aPvlNfs,@aBloqueio)
		
		// Checa itens liberados
		Ma410LbNfs(1,@aPvlNfs,@aBloqueio)
		
		//u_showarray(aPvlNfs)
		//u_showarray(aBloqueio)			
			
		// Gera array com os pedidos selecionados								
		//SC9->(DbSeek(xFilial("SC9") + PTRB->NUM + PTRB->ITEM))					
		If SC9->(DbSeek(xFilial("SC9") + SC5->C5_NUM))		
			While ! SC9->(Eof()) .And. SC9->C9_FILIAL + SC9->C9_PEDIDO == xFilial("SC9") + SC5->C5_NUM 
				IF SC9->C9_QTDLIB > 0 .AND. EMPTY(SC9->C9_NFISCAL)
					If !EMPTY(SC9->C9_BLEST) .OR. !EMPTY(SC9->C9_BLCRED)
						aAdd(_aErro, "O pedido " + SC9->C9_PEDIDO + ", item " + SC9->C9_ITEM + " está bloqueado." )						
						aAdd(aLog, "O pedido " + SC9->C9_PEDIDO + ", item " + SC9->C9_ITEM + " está bloqueado." )
						lFat := .F.
						lBloq := .T.
					Else 
						// Posiciona nas tabeas		
						SB1->(dbSeek(xFilial("SB1") + SC9->C9_PRODUTO))									
						SC5->(dbSeek(xFilial("SC5") + SC9->C9_PEDIDO)	)								
						SC6->(dbSeek(xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM + SC9->C9_PRODUTO))									
						SB2->(dbSeek(xFilial("SB2") + SC6->C6_PRODUTO + SC9->C9_LOCAL))					
						SF4->(dbSeek(xFilial("SF4") + SC6->C6_TES))							
						SE4->(dbSeek(xFilial("SE4") + SC5->C5_CONDPAG))												
						
						AADD(_aPvlNfs,{SC9->C9_PEDIDO   ,;       // Nuero da pedido de venda liberado
						SC9->C9_ITEM     ,;       // Item do pedido de venda liberado
						SC9->C9_SEQUEN   ,;       // Sequencia
						SC9->C9_QTDLIB   ,;       // Quantidade liberada
						SC9->C9_PRCVEN   ,;       // Preco de venda
						SC9->C9_PRODUTO  ,;       // Coigo do produto liberado
						SF4->F4_ISS=="S" ,;
						SC9->(RecNo())   ,;       // Recno() da tabela SC9
						SC5->(RecNo())   ,;       // Recno() da tabela SC5
						SC6->(RecNo())   ,;       // Recno() da tabela SC6
						SE4->(RecNo())   ,;       // Recno() da tabela SE4
						SB1->(RecNo())   ,;       // Recno() da tabela SB1
						SB2->(RecNo())   ,;       // Recno() da tabela SB2
						SF4->(RecNo())   ,;       // Recno() da tabela SF4
						SB2->B2_LOCAL    ,;       // Almoxarifado do produto
						DAK->(RecNo())   ,;       // Recno() da tabela DAK
						SC9->C9_QTDLIB2  })       // Quantidade lieberada da 2a. unidade medida

						//aAdd(aLog, "Pedido:" + SC9->C9_PEDIDO + " Item: " + SC9->C9_ITEM + ": Liberado." )
					EndIf
				EndIf
				SC9->(DbSkip())
			EndDo					
		EndIf	
	Else
		cLogErro := "O pedido de venda " + cNumPed + " não foi encontrado. A geração da NF não será realizada!" 
		aAdd(_aErro,cLogErro)
		MsgStop(cLogErro , _cRotina)
		
	EndIf
	
		
	// Gera a NF
	lMsHelpAuto := .F.  // se .t. direciona as mensagens de help
	lMsErroAuto := .F.  // necessario a criacao
	If Len(_aPvlNfs) > 0
		If lFat				
			cSerie  := "1  "
			cNumero  := ""			
			//Sx5NumNota(@cSerie,SuperGetMV("MV_TPNRNFS"),cFilAnt)
			//Sx5NumNota(@cSerie,SuperGetMV("MV_TPNRNFS"))			
			//cNumNF := NxtSX5Nota( , NIL, '2')
			Begin Transaction
			//              aPvlNfs ,cSerie ,lMostraCtb,lAglutCtb,lCtbOnLine,lCtbCusto,lReajusta,nCalAcrs,nArredPrcLis,lAtuSA7,lECF,cEmbExp,bAtuFin,bAtuPGerNF,bAtuPvl,bFatSE1)
			cNf := MaPvlNfs(_aPvlNfs,cSerie ,.F.       ,.F.      ,.F.       ,.F.      ,.F.      ,3       ,3           ,.F.    ,.F.,"")		
			If lMsErroAuto
				MsgInfo("Erro na geracao da NF do pedido de venda "+cNumPed+". Verifique log a seguir.")
				MostraErro()
				aAdd(_aErro,"Erro na geracao da NFdo pedido de venda "+cNumPed+".")
				DisarmTransaction()
			Else			
				
				aAdd(aLog, "Nota fiscal " + Alltrim(cNf) +" Série "+ Alltrim(cSerie) + " gerada com sucesso.")
				//MsgInfo("Nota fiscal " + Alltrim(cNf) +" Série "+ Alltrim(cSerie) + " gerada com sucesso.",_cRotina)
				aAdd(aLog, "--------------------------------------------")
				
			Endif
			End Transaction		
		EndIf	
			
	Endif
	
	If lBloq
		// Mostra mensagens de bloqueio
		cLog := ""
		For nX := 1 To Len(aLog)
			cLog += aLog[nX] + cCRLF
		Next
		cLog += "A NF de Saída não será gerada."
		IIF(!Empty(cLog),MsgAlert(cLog,cTitulo), cLog := "")
	EndIF		
	/*
	// Cria arquivo de Log
	If Len(aLog) > 0
		cLog := ""
		For nX := 1 To Len(aLog) 
			cLog += aLog[nX] + cCRLF			
		Next
		cArqLog := "C:\temp\Log_NF_" + DTOS(Date())+".txt"
		cSeq := '1'
		While File(cArqLog)
			cArqLog := "C:\temp\Log_NF_" + DTOS(Date())+ cSeq +".txt"
			cSeq := SOma1(cSeq)
		EndDo
		MemoWrite(cArqLog, cLog)
	EndIf	
*/
Return	


/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± Descricao:  FUNCAO VALPERG()                                            ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function ValPerg()
	Local i
	Local j
	aRegs :={}
	cPerg := PADR(cPerg,len(SX1->X1_GRUPO))
	
	aAdd(aRegs,{cPerg,"01","Diretorio ?"          ,"","","mv_ch1","C",30,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","   "})
	aAdd(aRegs,{cPerg,"02","Nome do arquivo CSV ?","","","mv_ch2","C",20,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","   "})
	dbSelectArea("SX1")
	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next
Return 
