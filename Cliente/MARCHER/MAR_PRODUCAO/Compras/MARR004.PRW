#INCLUDE "TOPCONN.ch"
#INCLUDE "PROTHEUS.CH" 
#Include "TOTVS.CH"
#Include "HBUTTON.CH"




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMARR004   บAutor  ณMarcioQuevedoBorges บ Data ณ 02/10/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua filtro  de solicita็๕es a serem atendidas.          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ COMA010 - Libera็ใo de Documentos                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

// Rotina Chamada 
*/
User Function MARR004() 
	/*
	ParamIXB = {cFornecedor,cLoja,cCodTab,cCondPag} onde :
	cFornecedor == C๓digo do Fornecedor
	cLoja == Loja do Fornecedor
	cCodTab == C๓digo da Tabela de Pre็o do Fornecedor
	cCondPag == Tabela de Pre็o para Condi็ใo de Pagamento especํfica

	*/

	Local cFornecedor   := PARAMIXB[1] 
	Local cLoja  		:= PARAMIXB[2]
	Local cCodTab    	:= PARAMIXB[3]
	Local cCondPag   	:= PARAMIXB[4]
		
	Local oFont1 := TFont():New("MS Sans Serif",,016,,.T.,,,,,.F.,.F.)
	Local oFont2 := TFont():New("MS Sans Serif",,016,,.T.,,,,,.F.,.F.)
	Local oGroup1
	Local oGroup2
	Local oGroup3
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSButton1
	Local oSButton2
	Local oSButton3
	Local oSpinBox1
	Local oSpinBox2
	Static oDlg	
	Private lProcessado := .F.
	Private lEscolhido 	:= .F.
	Private cPatchFile 	:= " "
	Private cCriticas	:= "" 
	Private cSayCrit	:= " "
	Private cxEnter 		:= CHR(13)+CHR(10)
	Private lTudoOk		:= .T.
	
	cNomeFor := Posicione("SA2",1,xFilial("SA2")+ M->AIA_CODFOR+M->AIA_LOJFOR,"A2_NOME") 
	
	//!INCLUI .Or. lCopia

	If !(INCLUI .Or. ALTERA )//!(nOpr $ '3/4') //Se nใo for inclusใo ou Altera็ใo, nใo permite carregar 
		IW_MsgBox("S๓ ้ possํvel importar tabela de Pre็o na opera็ใo de Inclusใo, C๓pia ou Altera็ใo de Tabela de Pre็o!",OemToAnsi("Informativo"),"INFO" )
		Return
	Endif
	
	If INCLUI .And. (Empty(M->AIA_DATDE) .Or. Empty(M->AIA_CODFOR) .Or. Empty(M->AIA_LOJFOR) .Or. Empty(M->AIA_CODTAB) .Or. Empty(M->AIA_DESCRI) )   
		IW_MsgBox("S๓ ้ possํvel importar tabela de Pre็o ap๓s preenchimento dos dados do cabe็alho!",OemToAnsi("Informativo"),"INFO" )
		Return
	Endif
	
	//Abertura de tela
	

	DEFINE MSDIALOG oDlg TITLE "New Dialog" FROM 000, 000  TO 400, 500 COLORS 0, 16777215 PIXEL

	@ 014, 015 GROUP oGroup1 TO 051, 228 PROMPT " Dados do Fornecedor " OF oDlg COLOR 0, 16777215 PIXEL	
    @ 023, 021 SAY oSay1 PROMPT "Codigo/Loja" SIZE 032, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 032, 021 SAY oSay2 PROMPT M->AIA_CODFOR +"/"+M->AIA_LOJFOR  SIZE 037, 009 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
	@ 023, 060 SAY oSay3 PROMPT "Empresa" SIZE 032, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
    @ 032, 060 SAY oSay4 PROMPT cNomeFor SIZE 157, 009 OF oGroup1 FONT oFont1 COLORS 0, 16777215 PIXEL

    @ 058, 017 GROUP oGroup2 TO 100, 229 PROMPT " Arquivo " OF oDlg COLOR 0, 16777215 PIXEL
    DEFINE SBUTTON oSButton1 FROM 072, 023 TYPE 14 OF oDlg ONSTOP "Clique para Selecionar o Aruivo Desejado" ENABLE ACTION Abrir()
    @ 070, 056 MSGET oGet1 VAR cPatchFile SIZE 139, 026 OF oGroup2 COLORS 0, 16777215 READONLY PIXEL

    @ 105, 019 GROUP oGroup3 TO 166, 228 PROMPT "Mensagem/Criticas" OF oDlg COLOR 0, 16777215 PIXEL
    //@ 110, 021 SAY oSay2 PROMPT cCriticas  SIZE 037, 009 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
    @ 111, 020 SAY oSay5 PROMPT cSayCrit SIZE 157, 009 OF oGroup3 FONT oFont2 COLORS 255, 16777215 PIXEL

    
`//  @ 110, 023 MSGET oGet2 VAR cCriticas SIZE 192, 050 OF oGroup3 COLORS 0, 16777215 READONLY PIXEL
    DEFINE SBUTTON oSButton2 FROM 178, 199 TYPE 01 OF oDlg ONSTOP "Processa Importa" ENABLE ACTION (Processa({|| Roda(.T.,@lTudoOk)},"Importador de Tab.Pre็oc","Carregando dados..."),IIF(lTudoOk,oDlg:End(),AllwaysTrue()) ) WHEN  ValidaOK()
    DEFINE SBUTTON oSButton3 FROM 178, 168 TYPE 02 OF oDlg ONSTOP "Sai da Rotina" ENABLE ACTION oDlg:End()

  ACTIVATE MSDIALOG oDlg CENTERED
	

	
	
		// Carregar informa็๕es do cabe็alho da tabela de pre็o .
		// Botใo para Carregar arquivo txt no formato especํfico
		// Validar arquivo carregado segundo regras
		
			//Obs,: Resolver com PE na grava็ใo da tabela? Verifica se existe Amarra็ใo Produto X Fornecedor na Grava็ใo da tabela de pre็o ou na importa็ใo dos itens.
			//Importar registros -> AIB_DATVIG deve ser igual ao campo de data deInํcio de vig๊ncia da tabela (M->AIA_DATDE )
			
		//Atualiza aHeader aCols de registros
	//	nP2_DATA 	:= GdFieldPos("M_DATAATU", aHeader) //P2_DATA
	
	
	
	
Return

//---------------------------------------
// Valida Botใo OK
//---------------------------------------
Static Function ValidaOK()
Local lRet:= .F.

	If !lProcessado .and. lEscolhido //colocar condi็๕es de carga dos bot๕es
		lRet := .T.
	Endif 
Return lRet

//---------------------------------------
// Executa Botใo Abrir
//---------------------------------------
Static Function Abrir()

Local cEscolheuFile := .F.

WHILE !cEscolheuFile
	
	CTIPO := " "
	CTIPO += "Todos os arquivos   (*.*)    | *.*   | "
	cPatchFile:= CGETFILE( CTIPO , "Sele็ใo da pasta de gera็ใo da Tabela ",,"C:\" ) //,.T.,GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY+GETF_LOCALFLOPPY)
	cPatchFile  := LOWER(ALLTRIM(cPatchFile))
	
	
	If File(cPatchFile)
		cEscolheuFile := .T.
	ELSE
		IW_MsgBox("Nใo foi possํvel localizar o arquivo",OemToAnsi("Arquivo..."),"INFO" )
		
	ENDIF
	
Enddo

	
	lEscolhido := .T.
	oDlg:Refresh()
Return 




//-----------------------------------
// Processa importa็ใo do arquivo
//----------------------------------
Static Function Roda(lCabecalho,lTudoOk)

Local X_PRODUTO		:= 1
Local X_PRECO		:= 2
Local nHl 			:= FT_FUSE(cPatchFile)
Local nTam 			:= Ft_FLastRec()
Local _nLin			:=0
Local cLine	 		:= "" 
Local cENTER		:= CHR(13)+ CHR(10)

Local aLine			:= {} //Linha do registro que estแ sendo lido do arquivo
Local aRegs			:= {} // array de registros a serem adicionados ao aCols	
DEFAULT lCabecalho 	:= .T. // possui cabe็alho
DEFAULT lTudoOk		:= .T. // Sem crํticas
	DBSelectArea("SB1"); DBSetOrder(1)

	ProcRegua(nTam)
	lProcessado := .T.
	
	// Efetua a carga do arquivo 
	
	

	//Abre e posiciona arquivo
	If nHl < 0 //-1 = falha na abertura
		If lMsgBox
			IW_MsgBox("Falha na Abertura do arquivo"+ cPatchFile,OemToAnsi("Informativo"),"ALERT" )
		Else
			Conout(Funname() + " - Falha na Abertura do arquivo"+ cPatchFile)
		Endif
		cCriticas := "Falha na Abertura do arquivo. Verifique se o arquivo estแ em uso ou o formato nใo ้ Texto padronizado."
	Else
		
		FT_FGOTOP()
		_nLin++
		While !FT_FEOF() //.and. Empty(cCriticas)
	
			If lCabecalho // Passa para pr๓ximo registro
				//Incrementa acumuladores
				_nLin++
				FT_FSKIP()
				//IncProc('Lendo Arquivo...')
				lCabecalho := .F.
				LOOP
			Endif
			
			cLine := FT_FREADLN()
			cLine  := strtran(cLine,";;"," ")//Para evitar conte๚do nulo no array
			aLine   := StrTokArr(cLine,";")
			aLine[2]:= strtran(aLine[X_PRECO],",",".")
			
			If Len(aLine) >= 1
				//Consiste Valor
				If  !IsNumeric(strtran(aLine[X_PRECO],".",""))  // Estou retirando sinal decimal verifica se ้ expressใo ้ apenas n๚meros antes de converter com o Val.
					cCriticas += "- Posi็ใo referente ao Pre็o estแ trazendo o conte๚do invแlido (deve ser n๚merico): '" + aLine[2] + "' na linha: " + transform(_nLin,"@! 9999") + cxENTER
					lTudoOk := .F.
				Endif
				//Consiste Produto
				If !SB1->(MSSeek(xFilial("SB1")+aLine[X_PRODUTO]))
					cCriticas += "- O produto " + aLine[X_PRODUTO] + " informado nใo estแ cadastrado no cad.Produto  -  linha: " + cValtoChar(_nLin) + cxENTER
					lTudoOk := .F.
				Endif
				If lTudoOk
					AADD(aRegs, { aLine[X_PRODUTO],;
							     Val(aLine[X_PRECO]) })
				Endif
			
			Endif
			
			//Incrementa acumuladores
			_nLin++
			FT_FSKIP()
			IncProc('Lendo Arquivo...')
			
		EndDo
		
		If lTudoOk // S๓ carrega para o aCols nใo foram encontradas Crํticas
			//carraga acols
			For nI:= 1 to Len(aRegs)
				//Apaga Produto jแ existente
				aCols := ACLONE(oGetDad:aCols)
				nPosIt := aScan(oGetDad:aCols,{|x| AllTrim(x[GDFieldPos( "AIB_CODPRO" )]) == AllTrim(aRegs[nI][X_PRODUTO])})
				If nPosIt > 0
					//oGetDad:DELLINE(nPosIt)
					oGetDad:aCols[ nPosIt,Len(aHeader)+1] := .T.  
				Endif  
				
				//Cria nova linha Acols			
				 oGetDad:ADDLINE() //Adiciona Linha Acols

				//Preenche Campos
				__ReadVar 	:= "M->AIB_CODPRO"
				oGetDad:aCols[ oGetDad:nAt, GDFieldPos( "AIB_CODPRO" ) ] :=  aRegs[nI][X_PRODUTO]
				//oGetDad:GdFieldPut('AIB_CODPRO', aRegs[nI][1],oGetDad:nAt)
				
				M->AIB_CODPRO :=  aRegs[nI][X_PRODUTO]
				//If ExistTrigger("AIB_CODPRO")
				//	RunTrigger(2,oGetDad:nAt,"",oGetDad,"AIB_CODPRO")
					
				//Endif
				
				__ReadVar 	:= "M->AIB_DESCRI"
				//oGetDad:GdFieldPut('AIB_DESCRI', Posicione("SB1",1,xFilial("SB1")+ aRegs[nI][1],"B1_DESC"),oGetDad:nAt)
				oGetDad:aCols[ oGetDad:nAt, GDFieldPos( "AIB_DESCRI" ) ] :=  Posicione("SB1",1,xFilial("SB1")+ aRegs[nI][X_PRODUTO],"B1_DESC")
				M->AIB_DESCRI := SB1->B1_DESC
				
				__ReadVar 	:= "M->AIB_PRCCOM"
				//oGetDad:GdFieldPut('AIB_PRCCOM', aRegs[nI][2],oGetDad:nAt)
				oGetDad:aCols[ oGetDad:nAt, GDFieldPos( "AIB_PRCCOM" ) ] :=   aRegs[nI][X_PRECO]
				M->AIB_PRCCOM :=  aRegs[nI][X_PRECO]
				//If ExistTrigger("AIB_PRCCOM")
				//	RunTrigger(2,oGetDad:nAt,"",oGetDad,"AIB_PRCCOM")
				//Endif
				
				__ReadVar 	:= "M->AIB_DATVIG"
				oGetDad:aCols[ oGetDad:nAt, GDFieldPos( "AIB_DATVIG" ) ] :=   M->AIA_DATDE
				M->AIB_DATVIG :=  M->AIA_DATDE

				
			Next nI
		Endif
		
		
	Endif

	FT_FUSE()


	
	
	//cCriticas := "criticas esperada " + CHR(10) + CHR(13)+ "teste"
	
	If !Empty(cCriticas)
		CaixaTexto(cCriticas) //Apresenta Crํstica
		cSayCrit := "Nใo importado dados. Feche esta janela, "+ cENTER + "corriga as crํticas e tente novamente!"
	Endif
	
	oDlg:Refresh()
	oGetDad:ForceRefresh()
	//u_vartotxt(ClassMethArr(oGetDad,.T.),"c:\sqlsiga\oGetDad_ClassMethArr-"+ StrTran(Time(),":","h") + ".txt")
	
Return

*********************************************************************
Static Function CaixaTexto(cTexto)
*********************************************************************

	
	__cFileLog := MemoWrite(Criatrab(,.F.)+".log",cTexto)

	Define FONT oFont NAME "Tahoma" Size 6,12
	Define MsDialog oDlgMemo Title ".: Leitura Concluida com Crํticas - Resolva e Processe novamente :." From 3,0 to 340,550 Pixel

	@ 5,5 Get oMemo  Var cTexto MEMO Size 265,145 Of oDlgMemo Pixel
	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:=oFont
	
	Define SButton  From 153,245 Type 1 Action oDlgMemo:End() Enable Of oDlgMemo Pixel

	Activate MsDialog oDlgMemo Center

Return(cTexto)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMYQUERY   บAutor  ณMarcioQuevedo Borgesบ Data ณ  12/17/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecuta Query de Consulta                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MyQuery( cQuery , cursor )

	IF SELECT( cursor ) <> 0
		dbSelectArea(cursor)
		DbCloseArea(cursor)
	Endif

	TCQUERY cQuery NEW ALIAS (cursor)

Return
