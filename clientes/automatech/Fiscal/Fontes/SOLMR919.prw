#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF
#DEFINE CHRCOMP If(aReturn[4]==1,15,18)
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³MATR919   ³ Autor ³ Mary C. Hergert       ³ Data ³ 13.07.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do Livro ISS - Modelo Porto Alegre/RS             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Jean Rehermann - SOlutio IT - 14/05/2015 - Implementada versão com impressão do número da NFE ao invés da RPS
/*/

User Function SOLMR919()

	Local Titulo      := OemToAnsi("Impressao do Registro de Entradas com ISS")
	Local cDesc1      := OemToAnsi(" Este programa ira emitir o relatorio de entradas com ISS ")
	Local cDesc2      := OemToAnsi("de acordo com os parametros configurados pelo usuario")
	Local cDesc3      := OemToAnsi("")
	Local cString     := "SF3"
	Local lDic        := .F. 	// Habilita/Desabilita Dicionario
	Local lComp       := .T. 	// Habilita/Desabilita o Formato Comprimido/Expandido
	Local lFiltro     := .T. 	// Habilita/Desabilita o Filtro
	Local wnrel       := "MATR919"  	// Nome do Arquivo utilizado no Spool
	Local nomeprog    := "MATR919"  	// nome do programa
	
	Private Tamanho := "M" // P/M/G
	Private Limite  := 132 // 80/132/220
	Private aOrdem  := {}  // Ordem do Relatorio
	Private cPerg   := "MTR919"  // Pergunta do Relatorio
	Private aReturn := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 } 
	
	Private lEnd    := .F.// Controle de cancelamento do relatorio
	Private m_pag   := 1  // Contador de Paginas
	Private nLastKey:= 0  // Controla o cancelamento da SetPrint e SetDefault
	
	AjustaSx1()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                                  ³
	//³ mv_par01             // Data Inicial                                  ³
	//³ mv_par02             // Data Final                                    ³
	//³ mv_par03             // Livro Selecionado                             ³
	//³ mv_par04             // Pagina Inicial                                ³
	//³ mv_par05             // Nro do CCM                                    ³
	//³ mv_par06             // Livro ou Livro+termos ou Termos               ³
	//| mv_par07             // Valor da Estimativa                           |
	//| mv_par08             // Valor do ISSQN sobre a Estimativa             | 
	//| mv_par09             // Valor do ISSQN recolhido dentro do periodo    |
	//| mv_par10             // Data do recolhimento do ISSQN no periodo      |
	//| mv_par11             // ISSQN recolhido por intimacao ou ato infracao |
	//| mv_par12             // Data da intimacao                             |
	//| mv_par13             // Numero do ato de infracao                     |
	//| mv_par14             // Se deseja apresentar o ISS Retido em Devol.   |
	//| mv_par15             // Imprimir notas canceladas                     |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)

	wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro)
	If ( nLastKey==27 )
		dbSelectArea(cString)
		dbSetOrder(1)
		dbClearFilter()
		Return
	Endif
	SetDefault(aReturn,cString)
	If ( nLastKey==27 )
		dbSelectArea(cString)
		dbSetOrder(1)
		dbClearFilter()
		Return
	Endif

	//³ Impressao de Termo / Livro                                   ³
	Do Case
		Case mv_par06 == 1 
		     lImpLivro  := .T. 
		     lImpTermos := .F.
		Case mv_par06 == 2 
		     lImpLivro  := .F. 
		     lImpTermos := .T.
		Case mv_par06 == 3 
		     lImpLivro  := .T. 
		     lImpTermos := .T.
	EndCase    
	
	If lImpLivro 
		RptStatus({|lEnd| ImpDet(@lEnd,wnRel,cString,nomeprog,Titulo)},Titulo)
	EndIf
	
	If lImpTermos
		R990ImpTerm(cPerg)
	EndIf

	dbSelectArea(cString)
	dbClearFilter()
	Set Device To Screen
	Set Printer To
	
	If ( aReturn[5] = 1 )
		dbCommitAll()
		OurSpool(wnrel)
	Endif
	MS_FLUSH()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³IMPDET    ³ Autor ³ Mary C. Hergert       ³ Data ³ 13.07.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do Relatorio                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpDet()

	Local aLay	    := RetLayOut()
	Local aDetail   := {}
	Local aTotCod   := {}
	
	Local cAliasSF3 := "SF3"
	Local cArqInd   := ""
	
	Local dDataImp  := Ctod("//")
	
	Local lQuery    := .F.
	Local lHouveMov := .F.
	Local lISSRet	:= SF3->(FieldPos("F3_RECISS")) > 0
	
	Local nTotal    := 0
	Local nTotIss   := 0
	Local nToBIss   := 0
	Local nTotDed   := 0
	Local nPagina   := mv_par04
	Local nValDed	:= 0
	Local nValLiq	:= 0
	Local nValRet	:= 0                                  
	Local nRetISS	:= 0
	Local li        := 100

	#IFDEF TOP
		Local aStruSF3  := {}
		Local aCamposSF3:= {}
	
		Local cQuery    := ""   
		Local cCmpQry	:= ""
	
		Local nX        := 0
	#ELSE 
		Local cChave    := ""
		Local cFiltro   := ""       
	#ENDIF

	dbSelectArea("SF3")
	dbSetOrder(1)

	#IFDEF TOP
	
	    If TcSrvType()<>"AS/400"
	    
		    aAdd(aCamposSF3,"F3_FILIAL")
	   	    aAdd(aCamposSF3,"F3_ENTRADA")
	   	    aAdd(aCamposSF3,"F3_NFISCAL")
	   	    aAdd(aCamposSF3,"F3_NFELETR")
	   	    aAdd(aCamposSF3,"F3_SERIE")
	   	    aAdd(aCamposSF3,"F3_CLIEFOR")
	   	    aAdd(aCamposSF3,"F3_LOJA")
	   	    aAdd(aCamposSF3,"F3_CFO")
	   	    aAdd(aCamposSF3,"F3_ALIQICM")   
	   	    aAdd(aCamposSF3,"F3_ESPECIE")
	   	    aAdd(aCamposSF3,"F3_BASEICM")
	   	    aAdd(aCamposSF3,"F3_ISENICM")
	   	    aAdd(aCamposSF3,"F3_OUTRICM")
	   	    aAdd(aCamposSF3,"F3_VALCONT")
	   	    aAdd(aCamposSF3,"F3_TIPO")
	   	    aAdd(aCamposSF3,"F3_VALICM")
	   	    aAdd(aCamposSF3,"F3_DTCANC")
	   	    aAdd(aCamposSF3,"F3_OBSERV")
	   	    
	   	    If lISSRet
	   	    	aAdd(aCamposSF3,"F3_RECISS")
	   	    Endif
	    	//
	    	aStruSF3  := SF3->(Mtr919Str(aCamposSF3,@cCmpQry))
	
			lQuery    := .T.
			cAliasSF3 := "F3_MATR919"
			
			cQuery    := "SELECT "
			cQuery    += cCmpQry
			cQuery    += "FROM " + RetSqlName("SF3") + " SF3 "
			cQuery    += "WHERE "
			cQuery    += "F3_FILIAL = '" + xFilial("SF3") + "' AND "
			cQuery    += "F3_CFO >= '5" + SPACE(LEN(F3_CFO)-1) + "' AND "	
			cQuery    += "F3_ENTRADA >= '" + Dtos(mv_par01) + "' AND "
			cQuery    += "F3_ENTRADA <= '" + Dtos(mv_par02) + "' AND "
			// Somente a parte referente ao servico do documento
			cQuery    += "F3_TIPO = 'S' AND "
			If mv_par03<>"*"
				cQuery	+=	"F3_NRLIVRO='"+mv_par03+"' AND "
			EndIf
			// Imprimir notas candeladas
			If MV_PAR15 == 2
				cQuery    += "F3_DTCANC = '" + Space(Len(Dtos(SF3->F3_DTCANC))) + "' AND "
				cQuery    += "F3_OBSERV NOT LIKE '%CANCELAD%' AND "
			EndIf
			cQuery    += "SF3.D_E_L_E_T_ = ' ' "               
			cQuery    += "ORDER BY " + SqlOrder(SF3->(IndexKey()))
		
		    cQuery := ChangeQuery(cQuery)
		    MemoWrite("SOLMR919.TXT", cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)
		
			For nX := 1 To len(aStruSF3)
				If aStruSF3[nX][2] <> "C" 
					TcSetField(cAliasSF3,aStruSF3[nX][1],aStruSF3[nX][2],aStruSF3[nX][3],aStruSF3[nX][4])
				EndIf
			Next nX
		
			dbSelectArea(cAliasSF3)	
		Else
	
	#ENDIF
	
			cArqInd	:=	CriaTrab(NIL,.F.)
			cChave	:=	"DTOS(F3_ENTRADA)+F3_SERIE+F3_NFISCAL+F3_TIPO+F3_CLIEFOR+F3_LOJA"
			cFiltro :=  "F3_FILIAL == '" + xFilial("SF3") + "' .AND. F3_CFO >= '5" + Space(Len(F3_CFO)-1) + "' .And."
			cFiltro	+=	"DtoS(F3_ENTRADA) >= '" + DtoS(mv_par01) + "' .And. DtoS(F3_ENTRADA) <= '" + DtoS(mv_par02) + "' .And. "
			// Somente a parte referente ao servico do documento
			cFiltro	+=	"F3_TIPO == 'S' "
			If MV_PAR15 == 2
				cFiltro +=  " .And. Empty(F3_DTCANC) .And. !('CANCELAD'$F3_OBSERV) "
			EndIf
			If mv_par03<>"*"
				cFiltro	+=	".And. F3_NRLIVRO=='"+mv_par03+"'"
			EndIf
				
			IndRegua(cAliasSF3,cArqInd,cChave,,cFiltro,"Selecionando Registros...")
			#IFNDEF TOP
				DbSetIndex(cArqInd+OrdBagExt())
			#ENDIF                
			(cAliasSF3)->(dbGotop())
			SetRegua(LastRec())
	
	#IFDEF TOP
		Endif    
	#ENDIF


	While (cAliasSF3)->(!Eof())                  
	
		nMes := Month((cAliasSF3)->F3_ENTRADA)
	
	    dDataImp := (cAliasSF3)->F3_ENTRADA
		li       := Mr919Cabec(@nPagina,(cAliasSF3)->F3_ENTRADA)
		aTotCod  := {}
		nTotal   := 0
		nTotIss  := 0
		nToBIss  := 0                               
		nTotDed  := 0   
	
		While (cAliasSF3)->(!Eof()) .And. Month((cAliasSF3)->F3_ENTRADA) == nMes
	
			//³O valor do ISS retido na operacao sera lancado em deducoes, ³
			//³visto que nao e devido pela empresa (sera pago pelo cliente)³
			nValRet := 0
			nRetIss := 0
			If mv_par14 == 1
				// Analisa o ISS Retido pelo SF3
				If lISSRet
					If (cAliasSF3)->F3_RECISS$"S1"
						nValRet := (cAliasSF3)->F3_BASEICM
						nRetISS := (cAliasSF3)->F3_VALICM
					Endif
				Else  // Analisa o ISS Retido pelo cliente/fornecedor
					If (cAliasSF3)->F3_TIPO $ "DB"
						SA2->(dbSetOrder(1))
						SA2->(dbSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
						If SA2->A2_RECISS$"S1"            
							nValRet := (cAliasSF3)->F3_BASEICM 
							nRetISS := (cAliasSF3)->F3_VALICM
						Endif
					Else
						SA1->(dbSetOrder(1))
						SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
						If SA1->A1_RECISS$"S1"                
							nValRet := (cAliasSF3)->F3_BASEICM 
							nRetISS := (cAliasSF3)->F3_VALICM
						Endif
					Endif
				Endif		
			Endif
	
			// Valor das Deducoes e Valor Liquido
	       	If (cAliasSF3)->F3_ISENICM > 0 .Or. (cAliasSF3)->F3_OUTRICM > 0 .Or. ((cAliasSF3)->F3_ISENICM + (cAliasSF3)->F3_OUTRICM + (cAliasSF3)->F3_BASEICM == 0)
	        	nValDed := 0
	        	nValLiq := 0
	        Else 
	        	nValDed := (cAliasSF3)->F3_VALCONT - (cAliasSF3)->F3_BASEICM + nValRet
	        	nValLiq := (cAliasSF3)->F3_BASEICM - nValRet 
	        Endif
	        
			lHouveMov := .T.
	
			aDetail := {StrZero(Day((cAliasSF3)->F3_ENTRADA),2),;
						Iif( !Empty((cAliasSF3)->F3_DTCANC), "C ", "  " )+;
						IIF(SF3->(FieldPos("F3_NFELETR")) > 0  .and. !Empty((cAliasSF3)->F3_NFELETR),(cAliasSF3)->F3_NFELETR,(cAliasSF3)->F3_NFISCAL),;
	                    (cAliasSF3)->F3_SERIE,;	
						(cAliasSF3)->F3_ESPECIE,;
						TransForm((cAliasSF3)->F3_VALCONT,"@e 99,999,999.99"),;
						TransForm(nValDed,"@e 99,999,999.99"),;
						TransForm(nValLiq,"@e 99,999,999.99")}
					
			FmtLin(aDetail,aLay[15],,,@Li)
	
			//³Acumula total                                                           ³
			If Empty(F3_DTCANC) .And. !('CANCELAD'$F3_OBSERV)
				nTotal   += (cAliasSF3)->F3_VALCONT
				nTotIss  += ((cAliasSF3)->F3_VALICM - nRetISS)
				nToBIss  += nValLiq
				nTotDed  += nValDed
			EndIf
				
			(cAliasSF3)->(dbSkip())
	    
			//³Se nao for fim de arquivo salta pagina com saldo a transportar          ³
			If !(cAliasSF3)->(Eof()) .And. ( Li > 57 ) .And. Month((cAliasSF3)->F3_ENTRADA) == nMes
				FmtLin({},aLay[17],,,@Li)
				FmtLin({TransForm(nTotal ,"@e 99,999,999.99"),TransForm(nTotDed ,"@e 99,999,999.99"),TransForm(nToBIss,"@e 99,999,999.99")},aLay[20],,,@Li)
				FmtLin({},aLay[19],,,@Li)			                             
				li := Mr919Cabec(@nPagina,(cAliasSF3)->F3_ENTRADA)
			Endif	
			
		EndDo	
	
		//³Imprime total                                                           ³
		FmtLin({},aLay[17],,,@Li)
		FmtLin({TransForm(nTotal ,"@e 99,999,999.99"),TransForm(nTotDed ,"@e 99,999,999.99"),TransForm(nToBIss,"@e 99,999,999.99")},aLay[18],,,@Li)
		FmtLin({},aLay[19],,,@Li)
	
		//³Imprime quadro de resumo                                                ³
		If ( Li > 47) 
			li := Mr919Cabec(@nPagina,dDataImp)
		Endif	
	
		FmtLin({},aLay[22],,,@Li)	 
		FmtLin({},aLay[22],,,@Li)	
		FmtLin({},aLay[23],,,@Li)
		FmtLin({},aLay[24],,,@Li)	
		FmtLin({TransForm(nToBIss ,"@e 99,999,999.99"),TransForm(nTotIss ,"@e 99,999,999.99")},aLay[25],,,@Li)		
		FmtLin({TransForm(mv_par07,"@e 99,999,999.99"),TransForm(mv_par08,"@e 99,999,999.99")},aLay[29],,,@Li)	
		FmtLin({dToC(mv_par10),TransForm(mv_par09,"@e 99,999,999.99")},aLay[30],,,@Li)	
		FmtLin({dToC(mv_par12)},aLay[31],,,@Li)	
		FmtLin({Alltrim(Str(mv_par13)),TransForm(mv_par11,"@e 99,999,999.99")},aLay[32],,,@Li)		
	 	FmtLin({},aLay[26],,,@Li)	
	 	FmtLin({},aLay[27],,,@Li)	
		Li += 4
		FmtLin({},aLay[33],,,@Li)	
		FmtLin({},aLay[34],,,@Li)	
	EndDo
	
	If !lHouveMov
		li:= Mr919Cabec(@nPagina,mv_par01)
		FmtLin({},aLay[28],,,@Li)		
		
		FmtLin({},aLay[17],,,@Li)
		FmtLin({TransForm(nTotal ,"@e 99,999,999.99"),TransForm(nTotDed ,"@e 99,999,999.99"),TransForm(nToBIss,"@e 99,999,999.99")},aLay[18],,,@Li)
		FmtLin({},aLay[19],,,@Li)
	
		//³Imprime quadro de resumo                                                ³
		FmtLin({},aLay[22],,,@Li)	
		FmtLin({},aLay[22],,,@Li)	
		FmtLin({},aLay[23],,,@Li)
		FmtLin({},aLay[24],,,@Li)	
		FmtLin({TransForm(nToBIss ,"@e 99,999,999.99"),TransForm(nTotIss ,"@e 99,999,999.99")},aLay[25],,,@Li)		
	 	FmtLin({},aLay[26],,,@Li)	
	 	FmtLin({},aLay[27],,,@Li)	
	Endif
	
	If !lQuery
		RetIndex("SF3")	
		dbClearFilter()	
		Ferase(cArqInd+OrdBagExt())
	Else
		dbSelectArea(cAliasSF3)
		dbCloseArea()
	Endif
		
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³Mr919Cabec³ Autor ³ Mary C. Hergert       ³ Data ³ 13.07.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o cabecalho do relatorio                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array com o LayOut                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Mr919Cabec(nPagina,dDataImp)

	Local li   := 0
	Local aLay := RetLayOut()
	
	Local cCCM        := mv_par05
	
	Local nMV_ALIQISS := GetMv("MV_ALIQISS")
	
	Local cMesIncid   := MesExtenso(Month(dDataImp))
	Local cAno        := Ltrim(Str(Year(dDataImp)))
	
	@ Li,000 PSAY AvalImp(Limite)
	
	FmtLin({},aLay[01],,,@Li)
	FmtLin({StrZero(nPagina,5)},aLay[02],,,@Li)
	FmtLin({},aLay[03],,,@Li)
	FmtLin({},aLay[04],,,@Li)
	FmtLin({},aLay[05],,,@Li)
	FmtLin({SM0->M0_NOMECOM,SM0->M0_ENDENT},aLay[06],,,@Li)
	FmtLin({},aLay[05],,,@Li)
	FmtLin({Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),SM0->M0_INSC,Iif(!Empty(cCCM),mv_par05," "),cMesIncid,cAno},aLay[07],,,@Li)
	FmtLin({},aLay[05],,,@Li)
	FmtLin({},aLay[08],,,@Li)
	FmtLin({TransForm(nMV_ALIQISS,"@e 999.99")},aLay[09],,,@Li)
	FmtLin({},aLay[10],,,@Li)
	FmtLin({},aLay[11],,,@Li)
	FmtLin({},aLay[12],,,@Li)
	FmtLin({},aLay[13],,,@Li)
	FmtLin({},aLay[14],,,@Li)
	
	nPagina++

Return(li)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³RetLayOut | Autor ³ Mary C. Hergert       ³ Data ³ 13.07.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o LayOut a ser impresso                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array com o LayOut                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RetLayOut()

	Local aLay := Array(40)
	
	//
	//                     1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
	//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	aLay[01] := "+---------------------------------------------------------------------------------------------------------------------------------+"
	aLay[02] := "| REGISTRO DE SERVICOS PRESTADOS                                                                                     PAGINA ####  |"
	aLay[03] := "|                                                                                                                                 |"
	aLay[04] := "| IMPOSTO SOBRE SERVICOS                                                                                                          |"
	aLay[05] := "|                                                                                                                                 |"
	aLay[06] := "| ########################################                     Endereco: #############################                            |"
	aLay[07] := "| C.N.P.J.: #################   Inscr. Est.: ###############   Inscr. Munic.: ###############        MES: ##########    ANO: #### |"
	aLay[08] := "|=================================================================================================================================|" 
	aLay[09] := "|                                                                                                           ALIQUOTA DE: ###### % |"
	aLay[10] := "|---------+--------------------------------------------+------------------------+------------------------+------------------------|"
	aLay[11] := "|         |          DOCUMENTOS COMPROBATORIOS         |                        |                        |                        |"
	aLay[12] := "|   DIA   +----------------+-------------+-------------+         TOTAL          |        DEDUCOES        |   LIQUIDO TRIBUTAVEL   |"
	aLay[13] := "|         |     NUMERO     |    SERIE    |   ESPECIE   |                        |                        |                        |"
	aLay[14] := "|=========+================+=============+=============+========================+========================+========================|"
	aLay[15] := "|   ##    |  ###########   |     ###     |     ###     |    ################    |    ################    |    ################    |" 
	aLay[16] := "|         |                |             |             |                        |                        |                        |"
	aLay[17] := "|---------+----------------+-------------+-------------+------------------------+------------------------+------------------------|"
	aLay[18] := "| TOTAL DO MES                                         |    ################    |    ################    |    #################   |"
	aLay[19] := "+---------------------------------------------------------------------------------------------------------------------------------+"
	aLay[20] := "| A TRANSPORTAR                                        |    ################    |    ################    |    #################   |"
	aLay[21] := "+---------------------------------------------------------------------------------------------------------------------------------+"
	aLay[22] := "                                                                                                                                   "
	aLay[23] := "+====================================================  R E S U M O  ==============================================================+" 
	aLay[24] := "|                                                                                                                                 |"
	aLay[25] := "| A) SOMA MENSAL DO LIQUIDO TRIBUTAVEL:    R$ ################                             IMP.:     R$ ################          |"
	aLay[26] := "|                                                                                                                                 |"
	aLay[27] := "+=================================================================================================================================+"
	aLay[28] := "| *** NAO HOUVE MOVIMENTACAO ***         |             |                        |                        |                        |" 
	aLay[29] := "| B) ESTIMATIVA MENSAL................:    R$ ################                             IMP.:     R$ ################          |"
	aLay[30] := "| C) TOTAL RECOLHIDO, DO MES, EM  ##########                                                         R$ ################          |"
	aLay[31] := "| D) TOTAL RECOLHIDO EM ##########, POR INTIMACAO                                                                                 |"
	aLay[32] := "|    OU ATO DE INFRACAO No. ##########                                                               R$ ################          |"
	aLay[33] := "  _____/_____/_______                                  __________________________________________________________________________  "
	aLay[34] := "                                                                               Assinatura do Responsavel                           "

Return(aLay)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³AjustaSX1 ³ Autor ³Mary C. Hergert        ³ Data ³25/03/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Acerta o arquivo de perguntas                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function AjustaSx1()

	Local cAlias	:=	Alias()
	Local aHelpPor := {}
	Local aHelpEng := {}
	Local aHelpSpa := {}
	
	// Corrigindo pergunta do mv_par11
	SX1->(dbSetOrder(1))
	If SX1->(dbSeek("MTR91911"))
		If SX1->(X1_GSC) == "C" 
			Reclock("SX1",.F.)
			X1_TIPO		:= "N"
	  		X1_TAMANHO	:= 12
			X1_DECIMAL	:= 2                         
			X1_PRESEL	:= 0
			X1_GSC		:= "G"
			MsUnLock()
		Endif
	Endif
	
	Aadd( aHelpPor, "Informe a data de inicio para geracao   " )
	Aadd( aHelpPor, "do relatorio.                           " )
	Aadd( aHelpPor, "                                        " ) 
	
	Aadd( aHelpEng, "Enter the initial date for the report   " )    
	Aadd( aHelpEng, "generation.                             " )
	Aadd( aHelpEng, "                                        " )   
	
	Aadd( aHelpSpa, "Digite la fecha de inicio para generar  " )
	Aadd( aHelpSpa, "Informe.                                " )
	Aadd( aHelpSpa, "                                        " )
	PutSx1("MTR919","01","Data Inicial?"            ,"Initial Date?"            ,"Fecha Inicial?l"            ,"mv_ch1","D",08,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	
	aHelpPor := {}
	aHelpEng := {}
	aHelpSpa := {}
	
	Aadd( aHelpPor, "Informe a data de final  para geracao   " )
	Aadd( aHelpPor, "do relatorio.                           " )
	Aadd( aHelpPor, "                                        " ) 
	
	Aadd( aHelpEng, "Enter the final  date to generate the   " )    
	Aadd( aHelpEng, "report.                                 " )
	Aadd( aHelpEng, "                                        " )   
	
	Aadd( aHelpSpa, "Informe la fecha de final  para la      " )
	Aadd( aHelpSpa, "generacion del informe.                 " )
	Aadd( aHelpSpa, "                                        " )
	PutSx1("MTR919","02","Data Final?"           ,"Final Date?"         ,"Fecha final?"         ,"mv_ch2","D",08,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	
	aHelpPor := {}
	aHelpEng := {}
	aHelpSpa := {}
	Aadd( aHelpPor, "Informe o numero do livro a ser         " )
	Aadd( aHelpPor, "impresso.                               " )
	Aadd( aHelpPor, "                                        " ) 
	
	Aadd( aHelpEng, "Enter the number of the book that will  " )    
	Aadd( aHelpEng, "be printed                              " )
	Aadd( aHelpEng, "                                        " )   
	
	Aadd( aHelpSpa, "Digite el numero del libro que debe     " )
	Aadd( aHelpSpa, "imprimirse.                             " )
	Aadd( aHelpSpa, "                                        " )
	PutSx1("MTR919","03","Livro Selecionado?"  ,"Livro Selecionado?","Livro Selecionado?","mv_ch3","C",01,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	
	aHelpPor := {}
	aHelpEng := {}
	aHelpSpa := {}
	Aadd( aHelpPor, "Informe o numero da pagina inicial.     " )
	Aadd( aHelpPor, "                                        " )
	Aadd( aHelpPor, "                                        " ) 
	
	Aadd( aHelpEng, "Enter the initial page number.          " )    
	Aadd( aHelpEng, "                                        " )
	Aadd( aHelpEng, "                                        " )   
	
	Aadd( aHelpSpa, "Digite el numero de la pagina inicial.  " )
	Aadd( aHelpSpa, "                                        " )
	Aadd( aHelpSpa, "                                        " )
	PutSx1("MTR919","04","Pagina inicial?"     ,"Pagina inicial?"   ,"Pagina inicial?"   ,"mv_ch4","N",05,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	
	aHelpPor := {}
	aHelpEng := {}
	aHelpSpa := {}
	Aadd( aHelpPor, "Informe o codigo do contribuinte        " )
	Aadd( aHelpPor, "municipal(CCM).                         " )
	Aadd( aHelpPor, "                                        " ) 
	
	Aadd( aHelpEng, "Enter the code of the municipal         " )    
	Aadd( aHelpEng, "contributor (CCM).                      " )
	Aadd( aHelpEng, "                                        " )   
	
	Aadd( aHelpSpa, "Informe el codigo del contribuyente     " )
	Aadd( aHelpSpa, "Municipal(CCM).                         " )
	Aadd( aHelpSpa, "                                        " )
	PutSx1("MTR919","05","Numero C.C.M?"       ,"Numero C.C.M?"     ,"Numero C.C.M?"     ,"mv_ch5","C",18,0,0,"G","","","","","mv_par05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	
	aHelpPor := {}
	aHelpEng := {}
	aHelpSpa := {}
	Aadd( aHelpPor, "Informe o tipo de impressao a ser       " )
	Aadd( aHelpPor, "gerada.                                 " )
	Aadd( aHelpPor, "                                        " ) 
	
	Aadd( aHelpEng, "Enter the type of printing to be        " )    
	Aadd( aHelpEng, "generated.                              " )
	Aadd( aHelpEng, "                                        " )   
	
	Aadd( aHelpSpa, "Informe el Tipo de impresion que se     " )
	Aadd( aHelpSpa, "generara.                               " )
	Aadd( aHelpSpa, "                                        " )
	PutSx1( "MTR919","06","Imprime?","Print?","Imprimir?","mv_ch6","N",1,0,3,"C","","","","","mv_par06","Somente Livro","Somente Livro","Somente Livro","","Somente Termos","Somente Termos","Somente Termos","Livro e Termos","Livro e Termos","Livro e Termos","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	
	aHelpPor := {}
	aHelpEng := {}
	aHelpSpa := {}
	Aadd( aHelpPor, "Informe o valor liquido tributavel      " )
	Aadd( aHelpPor, "da estimativa mensal do contribuinte    " )
	Aadd( aHelpPor, "                                        " ) 
	
	Aadd( aHelpEng, "Enter the type of printing to be        " )    
	Aadd( aHelpEng, "generated.                              " )
	Aadd( aHelpEng, "                                        " )   
	
	Aadd( aHelpSpa, "Informe el Tipo de impresion que se     " )
	Aadd( aHelpSpa, "generara.                               " )
	Aadd( aHelpSpa, "                                        " )
	PutSx1( "MTR919","07","Estimativa?","Estimativa?","Estimativa?","mv_ch7","N",12,2,0,"G","","","","","mv_par07","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	
	aHelpPor := {}
	aHelpEng := {}
	aHelpSpa := {}
	Aadd( aHelpPor, "Informe do ISSQN calculado sobre        " )
	Aadd( aHelpPor, "valor liquido tributavel da estimativa  " )
	Aadd( aHelpPor, "mensal do contribuinte                  " ) 
	
	Aadd( aHelpEng, "Informe do ISSQN calculado sobre        " )
	Aadd( aHelpEng, "valor liquido tributavel da estimativa  " )
	Aadd( aHelpEng, "mensal do contribuinte                  " ) 
	
	Aadd( aHelpSpa, "Informe do ISSQN calculado sobre        " )
	Aadd( aHelpSpa, "valor liquido tributavel da estimativa  " )
	Aadd( aHelpSpa, "mensal do contribuinte                  " ) 
	PutSx1( "MTR919","08","Val.Est.?","Val.Est.?","Val.Est.?","mv_ch8","N",12,2,0,"G","","","","","mv_par08","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	
	aHelpPor := {}
	aHelpEng := {}
	aHelpSpa := {}
	Aadd( aHelpPor, "Informe o valor do ISSQN que foi         " )
	Aadd( aHelpPor, "recolhido dentro do periodo em que esta  " )
	Aadd( aHelpPor, "sendo gerado o Livro Fiscal              " ) 
	
	Aadd( aHelpEng, "Informe o valor do ISSQN que foi         " )
	Aadd( aHelpEng, "recolhido dentro do periodo em que esta  " )
	Aadd( aHelpEng, "sendo gerado o Livro Fiscal              " ) 
	
	Aadd( aHelpSpa, "Informe o valor do ISSQN que foi         " )
	Aadd( aHelpSpa, "recolhido dentro do periodo em que esta  " )
	Aadd( aHelpSpa, "sendo gerado o Livro Fiscal              " ) 
	PutSx1( "MTR919","09","Valor ISSQN?","Valor ISSQN?","Valor ISSQN?","mv_ch9","N",12,2,0,"G","","","","","mv_par09","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	
	aHelpPor := {}
	aHelpEng := {}
	aHelpSpa := {}
	Aadd( aHelpPor, "Informe a data em que, dentro do periodo " )
	Aadd( aHelpPor, "em que esta sendo gerado o Livro Fiscal, " )
	Aadd( aHelpPor, "houve o recolhimento do ISSQN            " ) 
	
	Aadd( aHelpEng, "Informe a data em que, dentro do periodo " )
	Aadd( aHelpEng, "em que esta sendo gerado o Livro Fiscal, " )
	Aadd( aHelpEng, "houve o recolhimento do ISSQN            " ) 
	
	Aadd( aHelpSpa, "Informe a data em que, dentro do periodo " )
	Aadd( aHelpSpa, "em que esta sendo gerado o Livro Fiscal, " )
	Aadd( aHelpSpa, "houve o recolhimento do ISSQN            " ) 
	PutSx1( "MTR919","10","Dta. Recol.?","Dta. Recol.?","Dta. Recol.?","mv_cha","D",8,0,0,"G","","","","","mv_par10","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	
	aHelpPor := {}
	aHelpEng := {}
	aHelpSpa := {}
	Aadd( aHelpPor, "Informe o valor do ISSQN que foi         " )
	Aadd( aHelpPor, "recolhido por intimacao ou ato de        " )
	Aadd( aHelpPor, "infracao                                 " ) 
	
	Aadd( aHelpEng, "Informe o valor do ISSQN que foi         " )
	Aadd( aHelpEng, "recolhido por intimacao ou ato de        " )
	Aadd( aHelpEng, "infracao                                 " ) 
	
	Aadd( aHelpSpa, "Informe o valor do ISSQN que foi         " )
	Aadd( aHelpSpa, "recolhido por intimacao ou ato de        " )
	Aadd( aHelpSpa, "infracao                                 " ) 
	PutSx1( "MTR919","11","ISSQN Infra.?","ISSQN Infra.","ISSQN Infra.","mv_chb","N",12,2,0,"G","","","","mv_par11","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	
	aHelpPor := {}
	aHelpEng := {}
	aHelpSpa := {}
	Aadd( aHelpPor, "Informe a data em o contribuinte foi     " )
	Aadd( aHelpPor, "intimado a recolher o ISSQN.             " )
	Aadd( aHelpPor, "                                         " ) 
	
	Aadd( aHelpEng, "Informe a data em o contribuinte foi     " )
	Aadd( aHelpEng, "intimado a recolher o ISSQN.             " )
	Aadd( aHelpEng, "                                         " ) 
	
	Aadd( aHelpSpa, "Informe a data em o contribuinte foi     " )
	Aadd( aHelpSpa, "intimado a recolher o ISSQN.             " )
	Aadd( aHelpSpa, "                                         " ) 
	PutSx1( "MTR919","12","Dta. Intima.?","Dta. Intima.?","Dta. Intima.?","mv_chc","D",08,0,0,"G","","","","","mv_par12","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	
	aHelpPor := {}
	aHelpEng := {}
	aHelpSpa := {}
	Aadd( aHelpPor, "Informe o numero do ato de infracao      " )
	Aadd( aHelpPor, "que obrigou o contribuinte a recolher    " )
	Aadd( aHelpPor, "o ISSQN no periodo.                      " ) 
	
	Aadd( aHelpEng, "Informe o numero do ato de infracao      " )
	Aadd( aHelpEng, "que obrigou o contribuinte a recolher    " )
	Aadd( aHelpEng, "o ISSQN no periodo.                      " ) 
	
	Aadd( aHelpSpa, "Informe o numero do ato de infracao      " )
	Aadd( aHelpSpa, "que obrigou o contribuinte a recolher    " )
	Aadd( aHelpSpa, "o ISSQN no periodo.                      " ) 
	PutSx1( "MTR919","13","Ato Infracao?","Ato Infracao?","Ato Infracao?","mv_chd","N",10,0,0,"G","","","","","mv_par13","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	
	aHelpPor := {}
	aHelpEng := {}
	aHelpSpa := {}
	Aadd( aHelpPor, "Informe se os valores de ISS retido      " )
	Aadd( aHelpPor, "deverão ser apresentados na coluna de    " )
	Aadd( aHelpPor, "deduções.                                " ) 
	
	Aadd( aHelpEng, "Informe se os valores de ISS retido      " )
	Aadd( aHelpEng, "deverão ser apresentados na coluna de    " )
	Aadd( aHelpEng, "deduções.                                " ) 
	
	Aadd( aHelpSpa, "Informe se os valores de ISS retido      " )
	Aadd( aHelpSpa, "deverão ser apresentados na coluna de    " )
	Aadd( aHelpSpa, "deduções.                                " ) 
	PutSx1( "MTR919","14","ISS Retido Ded.?","ISS Retido Ded.?","ISS Retido Ded.?","mv_che","N",1,0,2,"C","","","","","mv_par14","Sim","Sim","Sim","","Não","Não","Não","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	
	aHelpPor := {}
	aHelpEng := {}
	aHelpSpa := {}
	Aadd( aHelpPor, "Informe se as notas canceladas deverão   " )
	Aadd( aHelpPor, "ser apresentadas.                        " )
	
	Aadd( aHelpEng, "Informe se as notas canceladas deverão   " )
	Aadd( aHelpEng, "ser apresentadas.                        " )
	
	Aadd( aHelpSpa, "Informe se as notas canceladas deverão   " )
	Aadd( aHelpSpa, "ser apresentadas.                        " )
	PutSx1( "MTR919","15","Imprime Canceladas?","Imprime Canceladas?","Imprime Canceladas?","mv_chf","C",1,0,2,"C","","","","","mv_par15","Sim","Sim","Sim","","Não","Não","Não","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	
	dbSelectArea(cAlias)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Mtr919Str ºAutor  ³Mary Hergert        º Data ³  26/12/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Montar um array apenas com os campos utilizados na query    º±±
±±º          ³para passagem na funcao TCSETFIELD                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aCampos: campos a serem tratados na query                   º±±
±±º          ³cCmpQry: string contendo os campos para select na query     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Matr919                                                     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function Mtr919Str(aCampos,cCmpQry)

	Local	aRet	:=	{}
	Local	nX		:=	0
	Local	aTamSx3	:=	{}
	//
	For nX := 1 To Len(aCampos)
		If(FieldPos(aCampos[nX])>0)
			aTamSx3 := TamSX3(aCampos[nX])
			aAdd (aRet,{aCampos[nX],aTamSx3[3],aTamSx3[1],aTamSx3[2]})
			//
			cCmpQry	+=	aCampos[nX]+", "
		EndIf
	Next(nX)
	//
	If(Len(cCmpQry)>0)
		cCmpQry	:=	" " + SubStr(cCmpQry,1,Len(cCmpQry)-2) + " "
	EndIf

Return(aRet)
