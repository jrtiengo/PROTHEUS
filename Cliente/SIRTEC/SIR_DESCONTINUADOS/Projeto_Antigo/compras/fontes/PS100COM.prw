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


ValidPerg()

Pergunte(cPerg,.F.)
	
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
	If !Empty(MV_PAR01) .and. !Empty(MV_PAR02)
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
Local cItCta := ''
Local cCond := MV_PAR02
Local cArq := alltrim(MV_PAR01)
Local lOK := .T.
Local cAux := ''
Local cNumSC7 := ''
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
		cItCta := ''
		
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
		/*
		IF lOK .and. !Empty(aLinha[9]) //TRANSAÇÃO
			SC7->(DBORDERNICKNAME("STRANS"))
			IF SC7->(DBSEEK(XFILIAL('SC7') + aLinha[9]))
				lOK := .F.
				AADD(aLog,"Linha  "+cValToChar(nCont)+"  Código transação já cadastrado !")
			ENDIF
		ELSE
			lOK := .F.
			AADD(aLog,"Linha  "+cValToChar(nCont)+"  Código transação vazio !")
		ENDIF
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
		
		aItem:= {{"C7_ITEM"		,cItem																	, Nil},;
				 {"C7_PRODUTO"	,aLinha[18]																, Nil},;
				 {"C7_QUANT" 	,nQuant																	, Nil},;
				 {"C7_PRECO" 	,nTot / nQuant															, Nil},;
				 {"C7_TOTAL" 	,nTot																	, Nil},;
				 {"C7_CC" 		,cCC 																	, Nil},;
				 {"C7_ITEMCTA"	,cItCta																	, Nil},;
				 {"C7_TES" 		,cTes 																	, Nil},;
				 {"C7_DATPRF" 	,dDataBase																, Nil},;
				 {"C7_PLACA" 	,aLinha[2]																, Nil},;
				 {"C7_OBS"	 	,Alltrim(aLinha[28])													, Nil}}
				 //{"C7_STRANS"	,aLinha[9]																, Nil}					
		AADD(aItens, aItem)
			
		FT_FSkip()
	Enddo
	FT_FUse()
ENDIF

If len(aLog) > 0
	MostraLog(aLog) 
Elseif len(aItens) > 0 
	cNumSC7 := GetNumSC7()
	aCab:={}
	aCab:= {{"C7_FILIAL"	,xFilial("SC7")					, Nil},;
			{"C7_TIPO"		,"1"							, Nil},;
			{"C7_NUM"		,cNumSC7					, Nil},;
			{"C7_EMISSAO"	,dDataBase						, Nil},;
			{"C7_FORNECE"	,cForn								, Nil},;
			{"C7_LOJA"		,cLoja							, Nil},;
			{"C7_CONTATO"	,"               "				, Nil},;
			{"C7_COND"		,cCond							, Nil},;
			{"C7_FILENT"	,xFilial("SC7")					, Nil},;
			{"C7_USER"		,__CUSERID						, Nil}}
			
		      
	lMsHelpAuto:= .F.
	lMsErroAuto:= .F.
	
	Begin Transaction
	
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


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VALIDPERG ³ Autor ³ Gustavo Cornelli     ³ Data ³25/01/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria perguntas no SX1. Se a pergunta ja existir, atualiza. ³±±
±±³          ³ Se houver mais perguntas no SX1 do que as definidas aqui,  ³±±
±±³          ³ deleta as excedentes do SX1.                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPerg()
local _aArea  := GetArea ()
local _aRegs  := {}
local _aHelps := {}
local _i      := 0
local _j      := 0

_aRegs = {}
//           GRUPO  ORDEM PERGUNT                           PERSPA PERENG VARIAVL   TIPO TAM DEC PRESEL GSC  VALID         VAR01       DEF01              DEFSPA1             DEFENG1             CNT01 VAR02 DEF02             DEFSPA2             DEFENG2            CNT02 VAR03 DEF03   DEFSPA3  DEFENG3  CNT03 VAR04 DEF04  DEFSPA4  DEFENG4  CNT04 VAR05 DEF05   DEFSPA5   DEFENG5  CNT05  F3   PYME   GRPSXG   HELP   PICTURE
AADD(_aRegs,{cPerg, "01", "Seleção do Arquivo CSV       	", "", "",  "mv_ch1",    "C", 60, 0,  0,    "G", "",           "mv_par01", "",                 "",                 "",                 "",   "",   "",                "",                "",                "",   "",   "",     "",      "",      "",   "",   "",    "",      "",      "",   "",   "",      "",      "",      "",   "DIR",   "S",   "",	   "",    ""            })
AADD(_aRegs,{cPerg, "02", "Condição de Pagamento        	", "", "",  "mv_ch2",    "C", 03, 0,  0,    "G", "",           "mv_par02", "",                 "",                 "",                 "",   "",   "",                "",                "",                "",   "",   "",     "",      "",      "",   "",   "",    "",      "",      "",   "",   "",      "",      "",      "",   "SE4",   "S",   "",	   "",    ""            })

// Definicao de textos de help (versao 7.10 em diante): uma array para cada linha.
_aHelps = {}
//              Ordem   1234567890123456789012345678901234567890    1234567890123456789012345678901234567890    1234567890123456789012345678901234567890
AADD (_aHelps, {"01", {"Selecione o arquivo CSV desejado  ",       "para importar para o sistema.              ", "                                        "}})
AADD (_aHelps, {"02", {"Condição de pagamento do pedido   ",       "de compras a ser criado.                   ", "                                        "}})

DbSelectArea ("SX1")
DbSetOrder (1)
For _i := 1 to Len (_aRegs)
	If ! DbSeek (cPerg + _aRegs [_i, 2])
		RecLock("SX1", .T.)
	Else
		RecLock("SX1", .F.)
	Endif
	For _j := 1 to FCount ()
		// Campos CNT nao sao gravados para preservar conteudo anterior.
		If _j <= Len (_aRegs [_i]) .and. left (fieldname (_j), 6) != "X1_CNT" .and. fieldname (_j) != "X1_PRESEL"
			FieldPut(_j, _aRegs [_i, _j])
		Endif
	Next
	MsUnlock()
Next

// Deleta do SX1 as perguntas que nao constam em _aRegs
DbSeek (cPerg, .T.)
do while ! eof () .and. x1_grupo == cPerg
	if ascan (_aRegs, {|_aVal| _aVal [2] == sx1 -> x1_ordem}) == 0
		reclock("SX1", .F.)
		dbdelete()
		msunlock()
	endif
	dbskip()
enddo

// Gera helps das perguntas
For _i := 1 to Len (_aHelps)
	PutSX1Help ("P." + AllTrim(cPerg) + _aHelps [_i, 1] + ".", _aHelps [_i, 2], {}, {})
Next

Restarea(_aArea)

Return