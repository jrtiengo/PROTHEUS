#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ fb101est  ³ Autor³ Daniela Maria Uez     ³ Data ³ 26/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Rotina para geração do inventário de produtos zerado.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ Gera inventário zerado conforme parâmetros do cliente.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Data      ³ Programador   ³ Manutencao Efetuada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³           ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function fb101est()
	
	Local nOpca     := 0
	Local cCadastro := OemToAnsi("Geração do inventário")
	Local aSays     := {}
	Local aButtons  := {}
	Local lPerg     := .F.
	
	Private cPerg   := PADR("FB101EST", 10 , " ") //PADR("FB101EST", LEN(SX1->X1_GRUPO)," ") // Grupo das Perguntas (SX1)
	_ValidPerg()
	
	Pergunte(cPerg,.F.)
	
	aAdd(aSays,OemToAnsi("Esta rotina irá zerar os valores do inventário para os produtos"))
	aAdd(aSays,OemToAnsi("conforme os parâmetros informados pelo usuário.                "))
	aAdd(aSays,OemToAnsi("                                                               "))
	
	// Define as funções dos botões da tela de entrada
	AADD(aButtons, { 5,.T.,{|| lPerg := Pergunte(cPerg,.T. ) } } )
	AADD(aButtons, { 1,.T.,{|| nOpca := If(( lPerg .Or. Pergunte(cPerg,.T.)) .And. _TudoOk() , 1, 2 ), If( nOpca == 1, FechaBatch(), Nil ) }})
	AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
	
	// Monta tela de entrada mostrando o conteúdo do aSays e com as opções de botões do aButtons
	FormBatch(cCadastro, aSays, aButtons, , 200, 405)
	
	// Executa a impressão do relatório
	If nOpca == 1
		Processa({|lEnd| GeraInv(), "Gerando inventário zerado"})
	Endif
	
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera o inventário zerado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function GeraInv()
	
	Local aArea   := GetArea()
	Local aInvent := {}
	
	lMsErroAuto   := .F.
	
	cQuery := 	" SELECT SB1.B1_COD, SB1.B1_TIPO, SB1.B1_DESC, SB1.B1_LOCALIZ, SB1.B1_RASTRO, " +;			
				"        (SELECT COUNT(SB1X.B1_COD)" +;
				"           FROM " + RetSqlName("SB1") + " SB1X " +;
				"           WHERE SB1X.B1_FILIAL  = '" + xFilial("SB1") + "' AND " +;
				"             	SB1X.D_E_L_E_T_ = ' ' AND " +;
				"             	SB1X.B1_COD   BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND " +;
				"             	SB1X.B1_TIPO  BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' AND " +;
				"             	SB1X.B1_GRUPO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "') TOTAL" +;
				"    FROM " + RetSqlName("SB1") + " SB1 " +;
				"    WHERE SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND " +;
				"     	 SB1.D_E_L_E_T_ = ' ' AND " +;
				"     	 SB1.B1_COD   BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND " +;
				"     	 SB1.B1_TIPO  BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' AND " +;
				"     	 SB1.B1_GRUPO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " +;
				"	   ORDER BY SB1.B1_COD"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"_TRB",.F.,.T.)
	
	ProcRegua(_TRB->TOTAL)
	
	While !_TRB->(EOF())
	
		// Incrementa a regua
		IncProc("Gerando inventario para os produtos...")
	
		// Valida se o produto consta no armazém informado
		dbSelectArea("SB2")
		dbSetOrder(1)
		If dbSeek(xFilial("SB2")+_TRB->B1_COD+MV_PAR07)
			//	CriaSB2(_TRB->B1_COD,MV_PAR07)
			//Endif
			if _TRB->B1_LOCALIZ=="S"
			    
				dbSelectArea("SBF")
				dbsetorder(2)
				dbseek(xFilial("SBF")+_TRB->B1_COD+MV_PAR07)      
				
				while(SBF->BF_PRODUTO+SBF->BF_LOCAL==_TRB->B1_COD+MV_PAR07)					
				 	/* Aadd(aInvent,{"B7_FILIAL", 	xFilial("SB7"),  '.T.'})
					Aadd(aInvent,{"B7_COD", 	_TRB->B1_COD, 	 '.T.'})
					Aadd(aInvent,{"B7_LOCAL", 	MV_PAR07, 		 Nil})
					Aadd(aInvent,{"B7_TIPO", 	_TRB->B1_TIPO,	 Nil})
					Aadd(aInvent,{"B7_DOC", 	MV_PAR09, 		 Nil})
					Aadd(aInvent,{"B7_QUANT", 	0, 		  		 Nil})
					Aadd(aInvent,{"B7_DATA", 	MV_PAR08, 		 Nil})
					Aadd(aInvent,{"B7_DTVALID", MV_PAR08, 		 Nil})   						
					Aadd(aInvent,{"B7_LOCALIZ", SBF->BF_LOCALIZ, '.T.'})             
					Aadd(aInvent,{"B7_NUMLOTE", SBF->BF_NUMLOTE, '.T.'})                        
					Aadd(aInvent,{"B7_LOTECTL", SBF->BF_LOTECTL, '.T.'})    					
					Aadd(aInvent,{"B7_NUMSERI", SBF->BF_NUMSERI, '.T.'})    					
										
					MSExecAuto({|x,y| mata270(x,y)},aInvent,3) 
					
					SBF->(dbSkip())					
					aInvent := {}*/
					
					dbSelectArea("SB7")
					if dbSeek(xFilial("SB7")+dtos(MV_PAR08)+_TRB->B1_COD+MV_PAR07+;
							SBF->BF_LOCALIZ+SBF->BF_NUMSERI+SBF->BF_LOTECTL+SBF->BF_NUMLOTE)
						reclock("SB7", .F.)
					else
						reclock("SB7", .T.)
					endif 
					
					Replace B7_FILIAL with xFilial("SB7")
					Replace B7_COD with _TRB->B1_COD
					Replace B7_LOCAL with MV_PAR07
					Replace B7_TIPO with _TRB->B1_TIPO
					Replace B7_DOC with MV_PAR09
					Replace B7_QUANT with 0
					Replace B7_DATA with MV_PAR08
					Replace B7_DTVALID with MV_PAR08
					Replace B7_LOCALIZ with SBF->BF_LOCALIZ
					Replace B7_NUMLOTE with SBF->BF_NUMLOTE
					Replace B7_LOTECTL with SBF->BF_LOTECTL
					Replace B7_NUMSERI with SBF->BF_NUMSERI					
					msunlock()                      
					
					dbselectarea("SBF")
					SBF->(dbSkip())					
				enddo 	
				
			elseif _TRB->B1_RASTRO == "S"
		         
				dbSelectArea("SB8")
				dbsetorder(1)
				dbseek(xFilial("SB8")+_TRB->B1_COD+MV_PAR07)
				while(SB8->B8_PRODUTO+SB8->B8_LOCAL==_TRB->B1_COD+MV_PAR07)					
				 	
				 	/*Aadd(aInvent,{"B7_FILIAL", 	xFilial("SB7"),  '.T.'})
					Aadd(aInvent,{"B7_COD", 	_TRB->B1_COD, 	 '.T.'})
					Aadd(aInvent,{"B7_LOCAL", 	MV_PAR07, 		 '.T.'})
					Aadd(aInvent,{"B7_TIPO", 	_TRB->B1_TIPO,	 '.T.'})
					Aadd(aInvent,{"B7_DOC", 	MV_PAR09, 		 '.T.'})
					Aadd(aInvent,{"B7_QUANT", 	0, 		  		 '.T.'})
					Aadd(aInvent,{"B7_DATA", 	MV_PAR08, 		 '.T.'})
					Aadd(aInvent,{"B7_DTVALID", MV_PAR08, 		 '.T.'})   						
					Aadd(aInvent,{"B7_LOCALIZ", SB8->B8_LOCALIZ, '.T.'})             
					Aadd(aInvent,{"B7_NUMLOTE", SB8->B8_NUMLOTE, '.T.'})    
					Aadd(aInvent,{"B7_LOTECTL", SB8->B8_LOTECTL, '.T.'})    					
					
					MSExecAuto({|x,y| mata270(x,y)},aInvent,3) 
					
					SBF->(dbSkip())					
					aInvent := {}*/
					
					dbSelectArea("SB7")
					if dbSeek(xFilial("SB7")+dtos(MV_PAR08)+_TRB->B1_COD+MV_PAR07+;
							SB8->B8_LOCALIZ+SB8->B8_SERIE+SB8->B8_LOTECTL+SB8->B8_NUMLOTE)
						reclock("SB7", .F.)
					else
						reclock("SB7", .T.)
					endif 
					
					Replace B7_FILIAL with xFilial("SB7")
					Replace B7_COD with _TRB->B1_COD
					Replace B7_LOCAL with MV_PAR07
					Replace B7_TIPO with _TRB->B1_TIPO
					Replace B7_DOC with MV_PAR09
					Replace B7_QUANT with 0
					Replace B7_DATA with MV_PAR08
					Replace B7_DTVALID with MV_PAR08
					Replace B7_LOCALIZ with SB8->B8_LOCALIZ
					Replace B7_NUMLOTE with SB8->B8_NUMLOTE
					Replace B7_LOTECTL with SB8->B8_LOTECTL
					Replace B7_NUMSERI with SB8->B8_SERIE				
					msunlock()                      
					
					dbSelectArea("SB8")
					SB8->(dbSkip())					
		        enddo
		    else
		    /*	Aadd(aInvent,{"B7_FILIAL", 	xFilial("SB7"), '.T.'})
				Aadd(aInvent,{"B7_COD", 	_TRB->B1_COD, 	'.T.'})
				Aadd(aInvent,{"B7_LOCAL", 	MV_PAR07, 		'.T.'})
				Aadd(aInvent,{"B7_TIPO", 	_TRB->B1_TIPO,	Nil})
				Aadd(aInvent,{"B7_DOC", 	MV_PAR09, 		Nil})
				Aadd(aInvent,{"B7_QUANT", 	0, 		  		Nil})
				Aadd(aInvent,{"B7_DATA", 	MV_PAR08, 		Nil})
				Aadd(aInvent,{"B7_DTVALID", MV_PAR08, 		Nil})   
		     		        
		          
				MSExecAuto({|x,y| mata270(x,y)},aInvent,3) 
				aInvent := {}				    	*/
			
				dbSelectArea("SB7")
				if dbSeek(xFilial("SB7")+dtos(MV_PAR08)+_TRB->B1_COD+MV_PAR07)
					reclock("SB7", .F.)
				else
					reclock("SB7", .T.)
				endif 
				
				Replace B7_FILIAL with xFilial("SB7")
				Replace B7_COD with _TRB->B1_COD
				Replace B7_LOCAL with MV_PAR07
				Replace B7_TIPO with _TRB->B1_TIPO
				Replace B7_DOC with MV_PAR09
				Replace B7_QUANT with 0
				Replace B7_DATA with MV_PAR08
				Replace B7_DTVALID with MV_PAR08
			
				msunlock()
		    endif 
		endif 
		
		_TRB->(dbSkip())
	End
	
	If lMsErroAuto
		Aviso("Atenção","Ocorreu um erro na geração do inventário. ",{"OK"})
    	Mostraerro()
	Else
		Aviso("Atenção","Inventário gerado com sucesso",{"OK"})
	Endif
	
	RestArea(aArea)
	
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria as perguntas no SX1 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _ValidPerg()

Local _aArea  := GetArea()
Local _aRegs  := {}
Local _aHelps := {}
Local _i      := 0
Local _j      := 0

// Definicao dos parametros a serem solicitados para o relatorio
_aRegs := {} // Get/Choose

//            Grupo/Ordem/Pergunta                   /Perspa/Pereng/Variável/Tipo/Tamanho/Dec/Presel/GSC/Valid/Var01     /Def01/Defspa1/Defeng1/Cnt01/Var02/Def02/Defspa2/Defeng2/Cnt02/Var03/Def03/Defspa3/Defeng3/Cnt03/Var04/Def04/Defspa4/Defeng4/Cnt4/Var05/Def05/Defspa5/Defeng5/Cnt05/F3/GRPSXG
aAdd(_aRegs, {cPerg,"01","Código Produto de ?",      "",    "",    "MV_CH1","C", 15,     0,  0,     "G","",   "MV_PAR01","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "SB1",""})
aAdd(_aRegs, {cPerg,"02","Código Produto até ?",     "",    "",    "MV_CH2","C", 15,     0,  0,     "G","",   "MV_PAR02","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "SB1",""})
aAdd(_aRegs, {cPerg,"03","Tipo Produto de ?",        "",    "",    "MV_CH3","C", 02,     0,  0,     "G","",   "MV_PAR03","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "02", ""})
aAdd(_aRegs, {cPerg,"04","Tipo produto até ?",       "",    "",    "MV_CH4","C", 02,     0,  0,     "G","",   "MV_PAR04","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "02", ""})
aAdd(_aRegs, {cPerg,"05","Grupo Produto de ?",       "",    "",    "MV_CH5","C", 04,     0,  0,     "G","",   "MV_PAR05","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "SBM",""})
aAdd(_aRegs, {cPerg,"06","Grupo Produto até ?",      "",    "",    "MV_CH6","C", 04,     0,  0,     "G","",   "MV_PAR06","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "SBM",""})
aAdd(_aRegs, {cPerg,"07","Almoxarifado",             "",    "",    "MV_CH7","C", 02,     0,  0,     "G","",   "MV_PAR07","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "",   ""})
aAdd(_aRegs, {cPerg,"08","Data do Inventário ?",     "",    "",    "MV_CH8","D", 08,     0,  0,     "G","",   "MV_PAR08","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "",   ""})
aAdd(_aRegs, {cPerg,"09","Documento ?",              "",    "",    "MV_CH9","C", 09,     0,  0,     "G","",   "MV_PAR09","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "",   ""})
//aAdd(_aRegs, {cPerg,"10","Endereço?  ",              "",    "",    "MV_CHA","C", 15,     0,  0,     "G","",   "MV_PAR10","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "SBE",""})

// Definicao de textos de help dos parametros (versao 7.10 em diante): um array para cada linha.
_aHelps := {}

//            Ordem   1234567890123456789012345678901234567890    1234567890123456789012345678901234567890    1234567890123456789012345678901234567890
aAdd(_aHelps, {"01",{"Informe o Código do Produto inicial.    ", "                                        ", "                                        "}} )
aAdd(_aHelps, {"02",{"Informe o Código do Produto final.      ", "                                        ", "                                        "}} )
aAdd(_aHelps, {"03",{"Informe o Tipo do Produto inicial.      ", "                                        ", "                                        "}} )
aAdd(_aHelps, {"04",{"Informe o Tipo do Produto final.        ", "                                        ", "                                        "}} )
aAdd(_aHelps, {"05",{"Informe o Grupo do Produto inicial.     ", "                                        ", "                                        "}} )
aAdd(_aHelps, {"06",{"Informe o Grupo do Produto final.       ", "                                        ", "                                        "}} )
aAdd(_aHelps, {"07",{"Informe o Almoxarifado.                 ", "                                        ", "                                        "}} )
aAdd(_aHelps, {"08",{"Informe a Data do Inventário.           ", "                                        ", "                                        "}} )
aAdd(_aHelps, {"09",{"Informe o Documento.                    ", "                                        ", "                                        "}} )
//aAdd(_aHelps, {"10",{"Informe o Endereço.                     ", "                                        ", "                                        "}} )

/*
dbSelectArea("SX1")
dbSetOrder(1)

For _i := 1 to len(_aRegs)
	If !dbSeek(cPerg + _aRegs[_i, 2])  // _i = ocorrencia do array  2 = segundo campo dentro daquela ocorrencia, no caso, a "ordem"
		RecLock("SX1", .T.) // lock na tab para INSERT de registro (.T.)
	Else
		RecLock("SX1", .F.) // lock na tab para UPDATE de registro (.F.)
	Endif
	
	For _j := 1 to FCount() // fcount()=nro. de campos dos regs. desta tabela (sx1)
		// Campos CNT nao sao gravados para preservar conteudo anterior.
		If _j <= len(_aRegs[_i]) .and. left(fieldname(_j), 6) != "X1_CNT" .and. fieldname(_j) != "X1_PRESEL"
			FieldPut(_j, _aRegs[_i, _j])
		Endif
	Next
	
	MsUnlock()   // libera lock
Next

// Deleta do SX1 as perguntas que nao constam em _aRegs
dbSeek(cPerg, .T.)
While !EOF() .and. x1_grupo == cPerg
	If aScan(_aRegs, {|_aVal| _aVal[2] == sx1->x1_ordem}) == 0
		RecLock("SX1", .F.)
		dbDelete()
		MsUnlock()
	Endif
	dbSkip()
Enddo

// Gera helps das perguntas
For _i := 1 to Len(_aHelps)
	PutSX1Help("P." + cPerg + _aHelps[_i, 1] + ".", _aHelps[_i, 2], {}, {})
Next
*/

RestArea(_aArea)

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida as perguntas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _TudoOk()

Local _aArea   := GetArea()
Local _lRet    := .T.

If _lRet
	If Empty(MV_PAR07)
		MsgInfo("O codigo do almoxarifado deve ser informado.","Campo Obrigatorio")
		_lRet     := .F.
	Endif
Endif

If _lRet
	If Empty(MV_PAR08)
		MsgInfo("A data do inventario deve ser informada.","Campo Obrigatorio")
		_lRet     := .F.
	Endif
Endif

If _lRet
	If Empty(MV_PAR09)
		MsgInfo("O codigo do Documento deve ser informado.","Campo Obrigatorio")
		_lRet     := .F.
	Endif
Endif

RestArea(_aArea)

Return(_lRet)
