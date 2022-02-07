#Include 'Protheus.ch'
#Include 'TopConn.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PS100COM ³ Autor ³ Primme                ³ Data ³27/07/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Unidade   ³ PRIMME           ³Contato ³                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina para importar os pedidos de compras conforme CSV    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Clientes PRIMME                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³      ³                                        ³±±
±±³              ³  /  /  ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function PS100COM()
Local lPerg := .F.
Local aButtons  := {}
Local aSays := {}
Local nOpca := 0
Private cPerg := PADR("PS100COM",LEN(SX1->X1_GRUPO)," ")
Private cCadastro := OemToAnsi("Importa Arquivo CSV")

/*
#25039 Declarada aqui a variável cXtipo, que será usada no PE MT120PCOK.
Ela também é declarada no PE MT120TEL, porém essa não é chamada no msexecauto, causando problema no outro PE.
Criada maneira de preencher o campo C7_FRMPAG.
Ajustados os campo para criação dos pedidos através do msexecauto.
Mauro - Solutio. 28/11/2019.
*/
Public cXtipo := Space(1)

//Forçada a abertura de pergunta antes da execução da importação
//Evita erro de MV_PAR #25408
if !Pergunte(cPerg,.t.)
     Return
endif
	
// Carrega texto descritivo do programa, apresentado na tela de entrada
aAdd(aSays,OemToAnsi("Através deste programa o sistema irá importar os   "))
aAdd(aSays,OemToAnsi("registros de arquivo CSV para um pedido de compras "))

// Define as funções dos botões da tela de entrada
AADD(aButtons, { 5,.T.,{|| lPerg := Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|| nOpca := If(( lPerg .Or. Pergunte(cPerg,.T.)), 1, 2 ), If( nOpca == 1, FechaBatch(), Nil ) }})
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )

// Monta tela de entrada mostrando o conteúdo do aSays e com as opções de botões do aButtons
FormBatch(cCadastro, aSays, aButtons, , 200, 405)

// Executa a impressão do relatório
If nOpca == 1
	If !Empty(MV_PAR01) .and. !Empty(MV_PAR02) .And. (MV_PAR03 == 1 .Or. MV_PAR03 == 2)
		Processa({||Ler_Arq()})
	Else
		MsgInfo("Necessário informar os parâmetros antes da execução da rotina.")
	Endif
Endif

Return


Static Function Ler_Arq()

Local cLinha := ""
Local aLinha := {}
Local cItem:= '0000'
Local aItem:={}
Local aItens:= {} 
Local aCab:= {}
Local aLog := {}
Local nCont := 0
Local cForn := ''
Local cLoja := ''
//Local cItCta := ''
Local cCond := MV_PAR02
Local cArq := alltrim(MV_PAR01)
Local lOK := .T.
Local cNumSC7 := ''
Local cTipPag	:= IIf(MV_PAR03==1,"1","2")

Private lMsHelpAuto:= .T.
Private	lMsErroAuto:= .F.

SE4->(DbSetORder(1))
If !SE4->(DbSeek(xFilial("SE4")+MV_PAR02))
	lok := .F.
	aadd(aLog,"Condição de pagamento informada nos parâmetros não encontrada. Verifique.")
Endif 

If '.CSV' $ upper(cArq)
	If !File(cArq)
		CpyT2S( cArq, "\cprova" )
		cFile := rat('\',cArq)
		cFile := alltrim(substr(cArq,cFile+1))
		cArq := "\cprova\"+cFile
		If !File(cArq)
			aadd(aLog,"Arquivo não disponível para importação.")
			lOk := .F.
		Endif
	Endif
Else
	aadd(aLog,"Formato inválido para importação.")
	lOk := .F.
Endif


//LER ARQUIVO TEXTO
IF lOk  

	FT_FUse(cArq)
	ProcRegua(FT_FLastRec())
	FT_FGOTOP() 
	aItens := {}
	cForn := ''	
	cLoja := ''
		
	While !FT_FEof()
		IncProc("")
		cLinha := FT_FReadln()
		nCont++
		cCC := ''
		cTes := ''
		//cItCta := ''
		
		aLinha := StrTokArr2(cLinha, ";", .T.) //, .F. -> Não retorna valores em branco
	
		//desconsidera o cabecalho
		If upper(alltrim(aLinha[1])) == 'CARTAO' 
			FT_FSkip()
			Loop
		Endif
		
		If len(aLinha) < 28
			FT_FSkip()
			Loop
		Endif
		
		If !Empty(aLinha[2])
			ST9->(DbSetOrder(1))
			If ST9->(DbSeek(xFilial("ST9")+aLinha[2]))
				cCC := ST9->T9_CCUSTO
				If empty(cCC)
					AADD(aLog,"Linha  "+cValToChar(nCont)+". Centro de Custo não informado!")
				Endif
			Else
				AADD(aLog,"Linha  "+cValToChar(nCont)+". Placa não encontrada!")	
			Endif
		Else
			AADD(aLog,"Linha  "+cValToChar(nCont)+". Placa vazia!")	
		Endif
		
		IF !Empty(aLinha[18]) //PRODUTO
			SB1->(DBSETORDER(1))
			IF SB1->(DBSEEK(XFILIAL('SB1') + aLinha[18]))
				cTes := SB1->B1_TE
			Else
				AADD(aLog,"Linha  "+cValToChar(nCont)+". Código Produto não cadastrado!")
			ENDIF
		ELSE
			AADD(aLog,"Linha  "+cValToChar(nCont)+". Código Produto vazio!")
		ENDIF
		
		If Empty(cForn+cLoja)
			IF !Empty(aLinha[5]) //FORNECEDOR
				SA2->(DBSETORDER(1))
				IF !SA2->(DBSEEK(XFILIAL('SA2') + aLinha[5]))
					AADD(aLog,"Linha  "+cValToChar(nCont)+". Código fornecedor não cadastrado!")
				Else
					cLoja := SA2->A2_LOJA
					cForn := aLinha[5]
				ENDIF
			ELSE
				AADD(aLog,"Linha  "+cValToChar(nCont)+". Código fornecedor vazio!")
			ENDIF
		Else
			IF !Empty(aLinha[5]) //FORNECEDOR
				If aLinha[5] <> cForn
					AADD(aLog,"Linha  "+cValToChar(nCont)+". Definição de fornecedor diferente entre as linhas!")
				Endif
			ELSE
				AADD(aLog,"Linha  "+cValToChar(nCont)+". Código fornecedor vazio!")
			ENDIF
		Endif
		/* 25.05.20 | Leef Tecnologia | Patrique Santos - Conforme Chamado 48097
		If Empty(aLinha[30])
			AADD(aLog,"Linha  "+cValToChar(nCont)+". Item contabil não informado.")
		Else
			CTD->(DbSetOrder(1))
			If !CTD->(DbSeek(xFilial("CTD")+padr(aLinha[30],len(CTD->CTD_ITEM))))
				AADD(aLog,"Linha  "+cValToChar(nCont)+". Item contabil não encontrado.")
			Else
				cItCta := CTD->CTD_ITEM
			Endif
		Endif
		*/
		cItem := Soma1(cItem)
		nQuant := StrTran(aLinha[24],",",".")
		nQuant := alltrim(StrTran(nQuant,'R$',''))
		nQuant := val(nQuant)
		
		nTot := StrTran(aLinha[20],",",".")
		nTot := alltrim(StrTran(nTot,'R$',''))
		nTot := val(nTot)
		
		if nQuant == 0 .or. nTot == 0
			AADD(aLog,"Linha  "+cValToChar(nCont)+"  Preço ou Quantidade zeradas.")
		Endif
		
		_cUM := Posicione("SB1",1,xFilial("SB1")+aLinha[18],"SB1->B1_UM")
		
		aItem:= {;
				{"C7_ITEM"		,cItem																	, Nil},;
				{"C7_PRODUTO"	,aLinha[18]																, Nil},;
				{"C7_UM"		,_cUM																	, Nil},;
				{"C7_QUANT" 	,nQuant																	, Nil},;
				{"C7_PRECO" 	,Round(nTot / nQuant,4)													, Nil},;
				{"C7_TOTAL" 	,nTot																	, Nil},;
				{"C7_LOCAL" 	,"01"																	, Nil},;
				{"C7_CC" 		,cCC 																	, Nil},;
				{"C7_OBS"	 	,Alltrim(aLinha[28])													, Nil},;
				{"C7_TES" 		,cTes 																	, Nil},;
				{"C7_VEICULO" 	,Alltrim(aLinha[2])													    , Nil},;
				{"C7_FRMPAG"	,cTipPag																, Nil};
				}
				//{"C7_ITEMCTA"	,cItCta																	, Nil},;
		AADD(aItens, aItem)
			
		FT_FSkip()
	Enddo
	FT_FUse()
ENDIF

If len(aLog) > 0
	MostraLog(aLog) 
Elseif len(aItens) > 0 
	cNumSC7 := GetNumSC7()
	aCab :=	{}
	aCab := {;
			{"C7_FILIAL"	,xFilial("SC7")					, Nil},;
			{"C7_TIPO"		,1								, Nil},;
			{"C7_COND"		,cCond							, Nil},;
			{"C7_CONTATO"	,"               "				, Nil},;
			{"C7_EMISSAO"	,dDataBase						, Nil},;
			{"C7_NUM"		,cNumSC7						, Nil},;
			{"C7_FORNECE"	,cForn							, Nil},;
			{"C7_LOJA"		,cLoja							, Nil},;
			{"C7_FILENT"	,xFilial("SC7")					, Nil},;
			{"C7_USER"		,__CUSERID						, Nil};
			}
	      
	lMsHelpAuto:= .F.
	lMsErroAuto:= .F.
	
	Begin Transaction
	
	cXTipo := cTipPag
	
	MSExecAuto({|v, x, y, z| MATA120(v, x, y, z)}, 1, aCab, aItens, 3)
	
	If lMsErroAuto
	 	DisarmTransaction()
	 	MsgInfo("Problemas ao incluir o pedido. Verifique log a seguir.")
		MOSTRAERRO()
	Else
	 	MsgInfo("Pedido "+cNumSC7+" incluido com sucesso.")
	EndIf
	
	End Transaction
Else
	MsgInfo("Nenhum registro a processar.")
Endif

Return

 
Static Function MostraLog(aLog)

Local cAux := ''
Local nX := 0
DEFINE FONT oFont NAME "Mono AS" SIZE 6,15
DEFINE MSDIaLog oDlg TITLE "Tela de Logs" From 3, 0 to 340, 417 PIXEL
@ 5, 5 LISTBOX oList FIELDS HEADER "Conferência de Logs" SIZE 200, 145 OF oDlg PIXEL 
oList:SetArray(aLog)
oList:bLine:= {|| {aLog[oList:nat]}}
oList:oFont := oFont
oList:SetFocus()

For nX := 1 to len(aLog)
	cAux += aLog[nX]+Chr(13)+Chr(10)
Next nX

DEFINE SBUTTON FROM 153,175 TYPE 1  ACTION oDlg:End() ENABLE OF oDlg PIXEL                                                               			// Apaga
DEFINE SBUTTON FROM 153,145 TYPE 13 ACTION (cFile:= cGetFile("Arquivos Texto (*.txt) |*.txt|", ""),IIF(cFile == "", .t., memowrite(cFile, cAux))) ENABLE OF oDlg PIXEL     	// Salva e Apaga   // "Salvar Como..."
ACTIVATE MSDIaLog oDlg CENTER

Return