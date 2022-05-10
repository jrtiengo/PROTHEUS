#INCLUDE "TOTVS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SCIA020   ³ Autor ³ Joao Mattos           ³ Data ³08.10.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Programa para renegociacao dos titulos do contas a receber ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_SCIA020()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Sport Club Internacional                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Andre silveira ³05/11/2014³     ³ Incluindo novos campos Persentual de ³±±
±±³               ³         ³      ³ multa e persentual de juros          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function SCIA020()

Private cCadastro 	:= OemToAnsi("Renegociação do Contas a Receber")
Private aRotina   	:= MenuDef()
Private aCores 		:={	{ 'SZ7->Z7_STATUS == "P"'	, 'ENABLE'		},;		// Pendente
{ 'SZ7->Z7_STATUS == "S"' 	, 'DISABLE'	},;		// Suspenso
{ 'SZ7->Z7_STATUS == "R"' 	, 'BR_AZUL'	}}		// Realizado

mBrowse( 6, 1,22,75,"SZ7",,,,,,aCores)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³SCA20Visua³ Autor ³Joao Mattos            ³ Data ³08.10.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de Tratamento da Visualizacao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do arquivo                                     ³±±
±±³          ³ExpN2: Registro do Arquivo                                  ³±±
±±³          ³ExpN3: Opcao da MBrowse                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
User Function SCA20VISUAL(cAlias,nReg,nOpcx)

Local aArea     := GetArea()
Local aStruct   := {}
Local oGetDad
Local oDlg
Local nUsado    := 0
Local nCntFor   := 0
Local nOpcA     := 0
Local lContinua := .T.
Local lQuery    := .F.
Local cCadastro := OemToAnsi("Renegociação do Contas a Receber")
Local cQuery    := ""
Local cTrab     := "SZ8"
Local bWhile    := {|| .T. }
Local aObjects  := {}
Local aPosObj   := {}
Local aSizeAut  := MsAdvSize()
Local aNoFields := {} // CAMPOS QUE NAO SERAO MOSTRADOS NA GETDADOS

PRIVATE aHEADER := {}
PRIVATE aCOLS   := {}
PRIVATE aGETS   := {}
PRIVATE aTELA   := {}

//-- Campos que nao irao aparecer na GetDados
aAdd( aNoFields, 'Z8_CODRENE')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem da Variaveis de Memoria                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SZ7")
dbSetOrder(1)
For nCntFor := 1 To FCount()
	
	M->&(FieldName(nCntFor)) := FieldGet(nCntFor)
Next nCntFor

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do aHeader                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//dbSelectArea("SX3")
OpenSxs(,,,,,"SX3TRB","SX3",,.F.)
If Select("SX3TRB") > 0
	
	dbSelectArea('SX3TRB')
	SX3TRB->( dbSetOrder( 1 ) ) //ORDENA POR ALIAS
	SX3TRB->( dbGoTop(  ) )
	SX3TRB->( dbSeek("SZ8") )
	
	While ( !Eof() .And. SX3TRB->&('X3_ARQUIVO') == "SZ8" )
		
		If ( X3USO(SX3TRB->&('X3_USADO')) .And. cNivel >= SX3TRB->&('X3_NIVEL') )
			
			If aScan(aNoFields, AllTrim(SX3TRB->&('X3_CAMPO'))) == 0
				
				nUsado++
				Aadd(aHeader,{ TRIM(X3Titulo()),;
				TRIM(SX3TRB->&('X3_CAMPO')),;
				SX3TRB->&('X3_PICTURE'),;
				SX3TRB->&('X3_TAMANHO'),;
				SX3TRB->&('X3_DECIMAL'),;
				SX3TRB->&('X3_VALID'),;
				SX3TRB->&('X3_USADO'),;
				SX3TRB->&('X3_TIPO'),;
				SX3TRB->&('X3_ARQUIVO'),;
				SX3TRB->&('X3_CONTEXT') } )
			EndIf
		EndIf
		dbSelectArea("SX3TRB")
		dbSkip()
	EndDo
	
	SX3TRB->( DbCloseArea() )
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do aCols                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SZ8")
dbSetOrder(1) // Z8_FILIAL + Z8_CODRENE + Z8_ITEM + Z8_PREFIXO + Z8_NUM + Z8_PARCELA + Z8_TIPO
SZ8->(dbSeek(xFilial("SZ8") + SZ7->Z7_CODRENE ))
bWhile := {|| xFilial("SZ8")  == SZ8->Z8_FILIAL .And. SZ7->Z7_CODRENE == SZ8->Z8_CODRENE }

While ( !Eof() .And. Eval(bWhile) )
	
	aadd(aCOLS,Array(nUsado+1))
	For nCntFor := 1 To nUsado
		If ( aHeader[nCntFor][10] != "V" )
			
			aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
		Else
			
			aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
		EndIf
	Next nCntFor
	aCOLS[Len(aCols)][Len(aHeader)+1] := .F.
	dbSelectArea(cTrab)
	dbSkip()
EndDo

aObjects := {}
AAdd( aObjects, { 100, 030, .T., .T. } )
AAdd( aObjects, { 100, 070, .T., .T. } )
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

EnChoice( cAlias ,nReg, nOpcx, , , , , aPosObj[1], , 3 )
oGetDad := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"U_SCA20LinOk","AllwaysTrue","",.F.)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})

RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³SCA20Inclu³ Autor ³Joao Mattos            ³ Data ³09.10.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de Tratamento da Inclusao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do arquivo                                     ³±±
±±³          ³ExpN2: Registro do Arquivo                                  ³±±
±±³          ³ExpN3: Opcao da MBrowse                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador     ³Manutencao Efetuada                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 05/11/2014³Andre Silveira³ incluindo os campos Z8_PEJUROS e Z8_PEMULTA³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
User Function SCA20INCLUI(cAlias,nReg,nOpcx)

Local aArea     	:= GetArea()
Local cCadastro 	:= OemToAnsi("Renegociação do Contas a Receber")
Local oGetDad		:= Nil
Local oDlg			:= Nil
Local nUsado    	:= 0
Local nCntFor   	:= 0
Local nOpcA     	:= 0
Local aObjects  	:= {}
Local aPosObj   	:= {}
Local aSizeAut  	:= MsAdvSize()
Local cItem		    := StrZero(1, TamSX3("Z8_ITEM")[1])
Local nPosItem	    := 0
Local aNoFields	    := {} // CAMPOS QUE NAO SERAO MOSTRADOS NA GETDADOS
Local aDados		:= {}
Local nX			:= 0
Local nPosPrefixo	:= 0
Local nPosNum 	    := 0
Local nPosParcela	:= 0
Local nPosTipo	    := 0
Local nPosEmissao	:= 0
Local nPosVencto 	:= 0
Local nPosValor	    := 0
Local nPosOrigem	:= 0
Local nPosJuros	    := 0
Local nPosMulta 	:= 0
Local nPosVlNomi	:= 0
Local nPosPerJur    := 0
Local nPosPeMult    := 0

PRIVATE aHEADER   := {}
PRIVATE aCOLS     := {}
PRIVATE aGETS     := {}
PRIVATE aTELA     := {}

//-- Campos que nao irao aparecer na GetDados
aAdd( aNoFields, 'Z8_CODRENE')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem da Variaveis de Memoria                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SZ7")
dbSetOrder(1)
For nCntFor := 1 To FCount()
	
	M->&(FieldName(nCntFor)) := CriaVar(FieldName(nCntFor))
Next nCntFor

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do aHeader                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
OpenSxs(,,,,,"SX3TRB","SX3",,.F.)
If Select("SX3TRB") > 0
	
	dbSelectArea('SX3TRB')
	SX3TRB->( dbSetOrder( 1 ) ) //ORDENA POR ALIAS
	SX3TRB->( dbGoTop(  ) )
	SX3TRB->( dbSeek("SZ8") )
	
	While ( !Eof() .And. SX3TRB->&('X3_ARQUIVO') == "SZ8" )
		
		If ( X3USO(SX3TRB->&('X3_USADO')) .And. cNivel >= SX3TRB->&('X3_NIVEL') )
			
			If aScan(aNoFields, AllTrim(SX3TRB->&('X3_CAMPO'))) == 0
				
				nUsado++
				Aadd(aHeader,{ TRIM(X3Titulo()),;
				TRIM(SX3TRB->&('X3_CAMPO')),;
				SX3TRB->&('X3_PICTURE'),;
				SX3TRB->&('X3_TAMANHO'),;
				SX3TRB->&('X3_DECIMAL'),;
				SX3TRB->&('X3_VALID'),;
				SX3TRB->&('X3_USADO'),;
				SX3TRB->&('X3_TIPO'),;
				SX3TRB->&('X3_ARQUIVO'),;
				SX3TRB->&('X3_CONTEXT') } )
			EndIf
		EndIf
		dbSelectArea("SX3TRB")
		dbSkip()
	EndDo
	
	SX3TRB->( DbCloseArea() )
EndIf

// SELECIONA OS TITULOS QUE SERAO RENEGOCIADOS
aDados	:= u_SCIA030()

If Len(aDados) > 0
	
	nPosPrefixo	:= AScan ( aHeader, { |x| AllTrim( x[2] ) == "Z8_PREFIXO" 	} ) // Prefixo
	nPosNum 		:= AScan ( aHeader, { |x| AllTrim( x[2] ) == "Z8_NUM" 		} ) // Numero
	nPosParcela 	:= AScan ( aHeader, { |x| AllTrim( x[2] ) == "Z8_PARCELA" 	} ) // Parcela
	nPosTipo	 	:= AScan ( aHeader, { |x| AllTrim( x[2] ) == "Z8_TIPO" 		} ) // Tipo
	nPosEmissao 	:= AScan ( aHeader, { |x| AllTrim( x[2] ) == "Z8_EMISSAO"	} ) // Data de Emissao
	nPosVencto 	    := AScan ( aHeader, { |x| AllTrim( x[2] ) == "Z8_VENCTO"	} ) // Data de Vencimento
	nPosVlNomi	 	:= AScan ( aHeader, { |x| AllTrim( x[2] ) == "Z8_VLNOMIN"	} ) // Valor Nominal (saldo)
	nPosPerJur      := AScan ( aHeader, { |x| AllTrim( x[2] ) == "Z8_PEJUROS"	} ) // percentual de juros
	nPosJuros	 	:= AScan ( aHeader, { |x| AllTrim( x[2] ) == "Z8_VLJUROS"	} ) // Valor Juros
	nPosPeMult      := AScan ( aHeader, { |x| AllTrim( x[2] ) == "Z8_PEMULTA"	} ) // Percentual da multa
	nPosMulta	 	:= AScan ( aHeader, { |x| AllTrim( x[2] ) == "Z8_VLMULTA"	} ) // Valor Multa
	nPosValor	 	:= AScan ( aHeader, { |x| AllTrim( x[2] ) == "Z8_VLTOTAL"	} ) // Valor Total com juros e multa
	nPosOrigem	 	:= AScan ( aHeader, { |x| AllTrim( x[2] ) == "Z8_ORIGEM"	} ) // Origem = N=Negociado R=Renegociado
	
	For nX	:= 1 to Len(aDados)
		
		If nX	== 1 // atualizar o cabecalho
			
			M->Z7_CLIENTE	:= aDados[nX][01]	//-- Codigo do cliente
			M->Z7_LOJA		:= aDados[nX][02]	//-- Loja do cliente
			M->Z7_NOMECLI	:= aDados[nX][03]	//-- Nome do cliente
			M->Z7_CONDPGT	:= aDados[nX][16]	//-- Codigo da condicao de pagamento
			M->Z7_NOMCPGT	:= aDados[nX][17]	//-- Descricao da condicao de pagamento
			M->Z7_NATUREZ	:= aDados[nX][18]	//-- Natureza financeira
		EndIf
		
		// Atualiza dados dos itens
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montagem do aCols                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aCOLS,Array(nUsado+1))
		For nCntFor   := 1 To nUsado
			
			aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
		Next nCntFor
		
		aCOLS[Len(aCols)][nPosItem] 		:= Strzero(nX,TamSx3("Z8_ITEM")[1])	//-- Item
		aCOLS[Len(aCols)][nPosPrefixo]		:= aDados[nX][04]							//-- Prefixo
		aCOLS[Len(aCols)][nPosNum]			:= aDados[nX][05]							//-- Numero
		aCOLS[Len(aCols)][nPosParcela]		:= aDados[nX][06]							//-- Parcela
		aCOLS[Len(aCols)][nPosTipo]			:= aDados[nX][07]							//-- Tipo
		aCOLS[Len(aCols)][nPosEmissao]		:= aDados[nX][08]							//-- Data de emissao do titulo
		aCOLS[Len(aCols)][nPosVencto]		:= aDados[nX][09]							//-- Data de vencimento do titulo
		aCOLS[Len(aCols)][nPosVlNomi]		:= aDados[nX][10]							//-- Valor Nominal (saldo)
		aCOLS[Len(aCols)][nPosPerJur]		:= aDados[nX][11]                           //percentual de juros
		aCOLS[Len(aCols)][nPosJuros]		:= aDados[nX][12]							//-- Juros
		aCOLS[Len(aCols)][nPosPeMult]		:= aDados[nX][13]							//-- Percentual da multa
		aCOLS[Len(aCols)][nPosMulta]		:= aDados[nX][14]							//-- Multa
		aCOLS[Len(aCols)][nPosValor]		:= aDados[nX][15]							//-- Valor Total com juros e multa
		aCOLS[Len(aCols)][nPosOrigem]		:= aDados[nX][19]							//-- Origem = [N]egociação ou [R]enegociação
		aCOLS[Len(aCols)][Len(aHeader)+1]	:= .F.
	Next nX
	
	aObjects := {}
	AAdd( aObjects, { 100, 030, .T., .T. } )
	AAdd( aObjects, { 100, 069, .T., .T. } )
	AAdd( aObjects, { 100, 001, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	
	EnChoice( cAlias ,nReg, nOpcx, , , , , aPosObj[1], , 3 )
	oGetDad := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"U_SCA20LinOk","U_SCA20TudOk","+Z8_ITEM",.T.)
	oGetDad:nMax := Len(aCols)
	
	@ aPosObj[3,1],aPosObj[3,2]+500 Button " Confirma "	Size 034,011 of oDlg PIXEL Action ( nOpcA:=1, oDlg:End() )
	@ aPosObj[3,1],aPosObj[3,2]+550 Button " Cancela  "	Size 034,011 of oDlg PIXEL Action ( nOpcA:=0, oDlg:End() )
	
	ACTIVATE MSDIALOG oDlg
	
	If ( nOpcA == 1 )
		
		Begin Transaction
		
		U_SCA20Grv(1)
		If ( __lSX8 )
			
			ConfirmSX8()
		EndIf
		EvalTrigger()
		End Transaction
	Else
		
		If ( __lSX8 )
			
			RollBackSX8()
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³SCA20Alter³ Autor ³Joao Mattos            ³ Data ³09.10.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o   ³Funcao de Tratamento da Alteracao                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do arquivo                                     ³±±
±±³          ³ExpN2: Registro do Arquivo                                  ³±±
±±³          ³ExpN3: Opcao da MBrowse                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function SCA20ALTERA(cAlias,nReg,nOpcx)

Local aArea     	:= GetArea()
Local aStruct   	:= {}
Local cCadastro 	:= OemToAnsi("Renegociação do Contas a Receber")
Local oGetDad		:= Nil
Local oDlg			:= Nil
Local nUsado    	:= 0
Local nCntFor   	:= 0
Local nOpcA     	:= 0
Local lContinua 	:= .T.
Local cQuery    	:= ""
Local cTrab     	:= "SZ8"
Local bWhile    	:= {|| .T. }
Local aObjects  	:= {}
Local aPosObj   	:= {}
Local aSizeAut  	:= MsAdvSize()
Local aNoFields	:= {} // CAMPOS QUE NAO SERAO MOSTRADOS NA GETDADOS
Local lOk			:= .t.

If SZ7->Z7_STATUS <> "P"
	
	MsgAlert( "Somente as renegociações pendentes poderão ser alteradas.","Atenção!" )
	lOk	:= .f.
EndIf

If lOk
	
	PRIVATE aHEADER := {}
	PRIVATE aCOLS   := {}
	PRIVATE aGETS   := {}
	PRIVATE aTELA   := {}
	
	//-- Campos que nao irao aparecer na GetDados
	aAdd( aNoFields, 'Z8_CODRENE')
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem da Variaveis de Memoria                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SZ7")
	dbSetOrder(1)
	lContinua := SoftLock("SZ7")
	If ( lContinua )
		
		For nCntFor := 1 To FCount()
			
			M->&(FieldName(nCntFor)) := FieldGet(nCntFor)
		Next nCntFor
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montagem do aHeader                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		OpenSxs(,,,,,"SX3TRB","SX3",,.F.)
		If Select("SX3TRB") > 0
			
			dbSelectArea('SX3TRB')
			SX3TRB->( dbSetOrder( 1 ) ) //ORDENA POR ALIAS
			SX3TRB->( dbGoTop(  ) )
			SX3TRB->( dbSeek("SZ8") )
			
			While ( !Eof() .And. SX3TRB->&('X3_ARQUIVO') == "SZ8" )
				
				If ( X3USO(SX3TRB->&('X3_USADO')) .And. cNivel >= SX3TRB->&('X3_NIVEL') )
					
					If aScan(aNoFields, AllTrim(SX3TRB->&('X3_CAMPO'))) == 0
						
						nUsado++
						Aadd(aHeader,{ TRIM(X3Titulo()),;
						TRIM(SX3TRB->&('X3_CAMPO')),;
						SX3TRB->&('X3_PICTURE'),;
						SX3TRB->&('X3_TAMANHO'),;
						SX3TRB->&('X3_DECIMAL'),;
						SX3TRB->&('X3_VALID'),;
						SX3TRB->&('X3_USADO'),;
						SX3TRB->&('X3_TIPO'),;
						SX3TRB->&('X3_ARQUIVO'),;
						SX3TRB->&('X3_CONTEXT') } )
					EndIf
				EndIf
				dbSelectArea("SX3TRB")
				dbSkip()
			EndDo
			
			SX3TRB->( DbCloseArea() )
		EndIf
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montagem do aCols                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SZ8")
		dbSetOrder(1)
		SZ8->(dbSeek(xFilial("SZ8")+SZ7->Z7_CODRENE ))
		bWhile := {|| xFilial("SZ8")  == SZ8->Z8_FILIAL .And. SZ7->Z7_CODRENE == SZ8->Z8_CODRENE }
		
		While ( !Eof() .And. Eval(bWhile) )
			
			aadd(aCOLS,Array(nUsado+1))
			For nCntFor := 1 To nUsado
				
				If ( aHeader[nCntFor][10] != "V" )
					
					aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
				Else
					
					aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
				EndIf
			Next nCntFor
			aCOLS[Len(aCols)][Len(aHeader)+1] := .F.
			dbSelectArea(cTrab)
			dbSkip()
		EndDo
		If ( lQuery )
			
			dbSelectArea(cTrab)
			dbCloseArea()
			dbSelectArea(cAlias)
		EndIf
	EndIf
	If ( lContinua )
		
		aObjects := {}
		AAdd( aObjects, { 100, 030, .T., .T. } )
		AAdd( aObjects, { 100, 070, .T., .T. } )
		aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects, .T. )
		
		DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
		
		EnChoice( cAlias ,nReg, nOpcx, , , , , aPosObj[1], , 3 )
		oGetDad := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"U_SCA20LinOk","U_SCA20TudOk","+Z8_ITEM",.T.)
		
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=If(oGetDad:TudoOk().And.Obrigatorio(aGets,aTela),1,0),If(nOpcA==1,oDlg:End(),Nil)},{||oDlg:End()})
		
		If ( nOpcA == 1 )
			
			Begin Transaction
			
			U_SCA20Grv(2)
			If ( __lSX8 )
				
				ConfirmSX8()
			EndIf
			EvalTrigger()
			End Transaction
		Else
			
			If ( __lSX8 )
				
				RollBackSX8()
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³SCA20Suspen³ Autor ³Joao Mattos           ³ Data ³09.10.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de Tratamento da Suspensão                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do arquivo                                     ³±±
±±³          ³ExpN2: Registro do Arquivo                                  ³±±
±±³          ³ExpN3: Opcao da MBrowse                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
User Function SCA20SUSPEN(cAlias,nReg,nOpcx)

Local aArea     := GetArea()
Local aStruct   := {}
Local cCadastro := OemToAnsi("Renegociação do Contas a Receber")
Local oGetDad
Local oDlg
Local nUsado    := 0
Local nCntFor   := 0
Local nOpcA     := 0
Local lContinua := .T.
Local cQuery    := ""
Local cTrab     := "SZ8"
Local bWhile    := {|| .T. }
Local aObjects  := {}
Local aPosObj   := {}
Local aSizeAut  := MsAdvSize()
Local aNoFields	:= {} // CAMPOS QUE NAO SERAO MOSTRADOS NA GETDADOS
Local lOk			:= .t.

If SZ7->Z7_STATUS <> "P"
	
	MsgAlert( "Somente as renegociações pendentes poderão ser suspensas.","Atenção!" )
	lOk	:= .f.
EndIf

If lOk
	
	PRIVATE aHEADER := {}
	PRIVATE aCOLS   := {}
	PRIVATE aGETS   := {}
	PRIVATE aTELA   := {}
	
	//-- Campos que nao irao aparecer na GetDados
	aAdd( aNoFields, 'Z8_CODRENE')
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montagem da Variaveis de Memoria                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SZ7")
	dbSetOrder(1)
	lContinua := SoftLock("SZ7")
	If ( lContinua )
		
		For nCntFor := 1 To FCount()
			
			M->&(FieldName(nCntFor)) := FieldGet(nCntFor)
		Next nCntFor
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montagem do aHeader                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		OpenSxs(,,,,,"SX3TRB","SX3",,.F.)
		If Select("SX3TRB") > 0
			
			dbSelectArea('SX3TRB')
			SX3TRB->( dbSetOrder( 1 ) ) //ORDENA POR ALIAS
			SX3TRB->( dbGoTop(  ) )
			SX3TRB->( dbSeek("SZ8") )
			
			While ( !Eof() .And. SX3TRB->&('X3_ARQUIVO') == "SZ8" )
				
				If ( X3USO(SX3TRB->&('X3_USADO')) .And. cNivel >= SX3TRB->&('X3_NIVEL') )
					
					If aScan(aNoFields, AllTrim(SX3TRB->&('X3_CAMPO'))) == 0
						
						nUsado++
						Aadd(aHeader,{ TRIM(X3Titulo()),;
						TRIM(SX3TRB->&('X3_CAMPO')),;
						SX3TRB->&('X3_PICTURE'),;
						SX3TRB->&('X3_TAMANHO'),;
						SX3TRB->&('X3_DECIMAL'),;
						SX3TRB->&('X3_VALID'),;
						SX3TRB->&('X3_USADO'),;
						SX3TRB->&('X3_TIPO'),;
						SX3TRB->&('X3_ARQUIVO'),;
						SX3TRB->&('X3_CONTEXT') } )
					EndIf
				EndIf
				dbSelectArea("SX3TRB")
				dbSkip()
			EndDo
			
			SX3TRB->( DbCloseArea() )
		EndIf
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montagem do aCols                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SZ8")
		dbSetOrder(1)
		SZ8->(dbSeek(xFilial("SZ8") + SZ7->Z7_CODRENE ))
		bWhile := {|| xFilial("SZ8")  == SZ8->Z8_FILIAL .And. SZ7->Z7_CODRENE == SZ8->Z8_CODRENE }
		
		While ( !Eof() .And. Eval(bWhile) )
			
			aadd(aCOLS,Array(nUsado+1))
			For nCntFor := 1 To nUsado
				
				If ( aHeader[nCntFor][10] != "V" )
					
					aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
				Else
					
					aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
				EndIf
			Next nCntFor
			aCOLS[Len(aCols)][Len(aHeader)+1] := .F.
			dbSelectArea(cTrab)
			dbSkip()
		EndDo
	EndIf
	If ( lContinua )
		
		aObjects := {}
		AAdd( aObjects, { 100, 030, .T., .T. } )
		AAdd( aObjects, { 100, 070, .T., .T. } )
		aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects, .T. )
		
		DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
		
		EnChoice( cAlias ,nReg, nOpcx, , , , , aPosObj[1], , 3 )
		oGetDad := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"U_SCA20LinOk","U_SCA20TudOk","",.F.)
		
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=If(oGetDad:TudoOk(),1,0),If(nOpcA==1,oDlg:End(),Nil)},{||oDlg:End()})
		
		If ( nOpcA == 1 )
			
			Begin Transaction
			
			U_SCA20Grv(3)
			EvalTrigger()
			End Transaction
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³SCA20APROVA³ Autor ³Joao Mattos           ³ Data ³16.10.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Aprovacao da Renegociacao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do arquivo                                     ³±±
±±³          ³ExpN2: Registro do Arquivo                                  ³±±
±±³          ³ExpN3: Opcao da MBrowse                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
User Function SCA20APROVA(cAlias,nReg,nOpcx)

Local aArea	:= GetArea()

// Executa função para Aprovar a Renegociação
MsAguarde( { || SCA20_APR() }, 'Processando...', 'Aguarde...' )

RestArea( aArea )

Return ( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³SCA20_APR  ³ Autor ³Joao Mattos           ³ Data ³17.10.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Aprovacao da Renegociacao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function SCA20_APR()

Local aArea		:= GetArea()
Local aBaixa		:= {}
Local cLog			:= ""
Local cErr			:= "//------< logs das baixas >------\\" + CRLF
Local cErr2		:= "//------< logs das inclusoes >------\\" + CRLF
Local aMsg			:= {}
Local nBaixados	:= 0
Local nIncluidos	:= 0
Local aTitulo		:= {}
Local cPrefixo	:= ""
Local cNum			:= ""
Local cParcela	:= ""
Local cTipo		:= ""
Local cCliente	:= ""
Local cLoja		:= ""
Local lOk			:= .t.
Local cPerg		:= Pad("SCIA020", 10/*TamSx3("X1_GRUPO")[1]*/)
Local cPasta		:= ""
Local cArquivo	:= "log_" + Substr(Dtos(dDataBase),3,2) + Substr(Dtos(dDataBase),5,2) + Substr(Dtos(dDataBase),7,2) + "_" + Left(Time(),2) + "_" + Substr(Time(),4,2) + "_" + Right(Time(),2) + ".txt"
Local nHdl			:= Nil
Local cErros		:= ""

If SZ7->Z7_STATUS <> "P"
	
	MsgAlert( "Somente as renegociações pendentes poderão ser aprovadas.","Atenção!" )
	lOk	:= .f.
EndIf

If lOk
	
	PRIVATE lMsErroAuto 		:= .F.
	PRIVATE lAutoErrNoFile	:= .T.
	
	SE1->( DbSetOrder(1) ) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Baixa  os registros origem N - Negociados                     ³
	//³Inclui os registros origem R - Renegociados                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Begin Transaction
	
	DbSelectArea("SZ8")
	DbSetOrder(1)
	DbSeek(xFilial("SZ8")+ SZ7->Z7_CODRENE )
	While ( !Eof() .And. xFilial("SZ8") == Z8_FILIAL .And. SZ7->Z7_CODRENE == Z8_CODRENE )
		
		cPrefixo	:= PadR( SZ8->Z8_PREFIXO	,	TamSX3("E1_PREFIXO")[1]	)
		cNum		:= PadR( SZ8->Z8_NUM		,	TamSX3("E1_NUM")[1]		)
		cParcela	:= PadR( SZ8->Z8_PARCELA	,	TamSX3("E1_PARCELA")[1]	)
		cTipo		:= PadR( SZ8->Z8_TIPO	,	TamSX3("E1_TIPO")[1]		)
		cCliente	:= PadR( SZ7->Z7_CLIENTE	,	TamSX3("E1_CLIENTE")[1]	)
		cLoja		:= PadR( SZ7->Z7_LOJA	,	TamSX3("E1_LOJA")[1]		)
		
		If SZ8->Z8_ORIGEM == "N" // Titulo Negociado - Será baixado
			
			lAutoErrNoFile	:= .T.
			lMsErroAuto		:= .F.
			aBaixa				:= {}
			
			SE1->( DbSeek(xFilial("SE1") + cPrefixo + cNum + cParcela + cTipo )  )
			
			aBaixa := {{ "E1_PREFIXO"  	,	cPrefixo		       	,Nil    	},;
			{ "E1_NUM"      	,	cNum		           	,Nil    	},;
			{ "E1_PARCELA"   ,	cParcela		     		,Nil    	},;
			{ "E1_TIPO"     	,	cTipo			          	,Nil    	},;
			{ "E1_CLIENTE"  	,	cCliente		         	,Nil    	},;
			{ "E1_LOJA"  		,	cLoja			         	,Nil    	},;
			{ "AUTMOTBX"    	,	"NEG"                 	,Nil    	},;
			{ "AUTDTBAIXA"  	,	dDataBase	         		,Nil    	},;
			{ "AUTDTCREDITO"	,	dDataBase          		,Nil    	},;
			{ "AUTHIST"     	,	SZ8->Z8_HISTORI      	,Nil    	},;
			{ "AUTJUROS"    	,	SZ8->Z8_VLJUROS       	,Nil,	.T.	},;
			{ "AUTMULTA"    	,	SZ8->Z8_VLMULTA       	,Nil,	.T.	},;
			{ "AUTVALREC"   	,	SZ8->Z8_VLTOTAL      	,Nil    	}}
			
			MSExecAuto({|x,y| Fina070(x,y)}, aBaixa, 3)
			If lMsErroAuto
				
				aMsg := GetAutoGRLog()
				
				aEval(aMsg,{|x| cErr += x + CRLF})
			Else
				
				nBaixados ++
			EndIf
		ElseIf SZ8->Z8_ORIGEM == "R" // Titulo Renegociado - Será Incluso
			
			lAutoErrNoFile	:= .T.
			lMsErroAuto		:= .F.
			aTitulo			:= {}
			
			// Verificar se ja existe incluido este título
			If !SE1->( DbSeek(xFilial("SE1") + cPrefixo + cNum + cParcela + cTipo )  )
				
				aTitulo	:= { 	{ "E1_PREFIXO"  	, SZ8->Z8_PREFIXO   				, NIL },;
				{ "E1_NUM"      	, SZ8->Z8_NUM       				, NIL },;
				{ "E1_PARCELA"  	, SZ8->Z8_PARCELA					, NIL },;
				{ "E1_TIPO"     	, SZ8->Z8_TIPO       			, NIL },;
				{ "E1_NATUREZ"  	, SZ7->Z7_NATUREZ    			, NIL },;
				{ "E1_CLIENTE"  	, SZ7->Z7_CLIENTE    			, NIL },;
				{ "E1_LOJA"  		, SZ7->Z7_LOJA	  				, NIL },;
				{ "E1_EMISSAO"  	, SZ8->Z8_EMISSAO   				, NIL },;
				{ "E1_VENCTO"   	, SZ8->Z8_VENCTO					, NIL },;
				{ "E1_VENCREA"  	, DataValida( SZ8->Z8_VENCTO  )	, NIL },;
				{ "E1_VALOR"    	, SZ8->Z8_VLTOTAL					, NIL } }
				
				MsExecAuto( { |x,y| FINA040(x,y)} , aTitulo, 3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
				If lMsErroAuto
					
					aMsg := GetAutoGRLog()
					
					aEval(aMsg,{|x| cErr2 += x + CRLF})
				Else
					
					nIncluidos ++
				EndIf
			Else
				
				cErr2 += "Titulo-Prefixo: " + cPrefixo + " - Numero: " + cNum + " - Parcela: " + cParcela + " - Tipo: " + cTipo + " já está incluso." + CRLF
			EndIf
		EndIf
		
		DbSelectArea("SZ8")
		DbSkip()
	EndDo
	
	If nBaixados > 0
		
		cErr += "Foram baixados " + AllTrim(Str(nBaixados)) + " titulos com sucesso."
	EndIf
	
	If nIncluidos > 0
		
		cErr2 += "Foram incluidos " + AllTrim(Str(nIncluidos)) + " titulos com sucesso."
	EndIf
	
	// Atualiza o Status
	DbSelectArea("SZ7")
	RecLock("SZ7", .f.)
	SZ7->Z7_STATUS	:= "R" // Realizado
	MsUnLock()
	
	End Transaction
	
	cErros	:= cErr + CRLF
	//	cErros	+= CRLF
	cErros	+= cErr2 + CRLF
	
	If Aviso( "Log da Operação"		,cErros	, { "Grava log", "OK" } ) == 1
		
		CriaSX1( cPerg )
		If Pergunte( cPerg, .t. )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cria arquivo                                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cPasta	:= Iif( Right( Trim( MV_PAR01 ), 1 ) <> "\", Trim( MV_PAR01 ) + "\", Trim( MV_PAR01 ) )
			nHdl	:= fCreate( cPasta + cArquivo )
			If FERROR() != 0
				
				MsgAlert( "Erro ao criar o arquivo " + cPasta + cArquivo + ". Código do erro: " + Str(FERROR()),"Atenção!" )
			Else
				
				fWrite( nHdl , cErr 	+ CRLF)
				fWrite( nHdl , cErr2 + CRLF)
				fClose(nHdl) // fecha texto
			Endif
		EndIf
	EndIf
EndIf

RestArea( aArea )

Return ( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³SCA20Legend³ Autor ³Joao Mattos           ³ Data ³09.10.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de Tratamento da Legenda                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
User Function SCA20LEGEND()

BrwLegenda(cCadastro,"Status Renegociação", 	{{"BR_VERDE" 		,"Pendente"		},;
{"BR_AZUL" 		,"Realizada"		},;
{"BR_VERMELHO" 	,"Suspensa"		}})
Return ( Nil )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³SCA20LinOk³ Autor ³Joao Mattos            ³ Data ³29.05.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao da linha Ok                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function SCA20LinOk()

Local aArea      := GetArea()
Local lReturn    := .t.

RestArea(aArea)

Return( lReturn )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³SCA20Grv  ³ Autor ³Joao Mattos            ³ Data ³29.05.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcao de Gravacao                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³SCA20Grv( ExpN1 )                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: [1] Inclusao                                         ³±±
±±³          ³       [2] Alteracao                                        ³±±
±±³          ³       [3] Suspensao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function SCA20Grv(nOpc)

Local aArea     	:= GetArea()
Local aRegistro 	:= {}
Local lGravou   	:= .F.
Local lRet      	:= .t.
Local nCntFor   	:= 0
Local nCntFor2  	:= 0
Local nUsado    	:= Len(aHeader)
Local aRecnoSZ8 	:= {}
Local cItem		:= Strzero(0,TamSX3("Z8_ITEM")[1])

If lRet
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Guarda os registros em um array para atualizacao              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SZ8")
	dbSetOrder(1)
	dbSeek(xFilial("SZ8")+ M->Z7_CODRENE )
	While ( !Eof() .And. xFilial("SZ8") == SZ8->Z8_FILIAL .And. M->Z7_CODRENE == SZ8->Z8_CODRENE )
		
		aadd(aRegistro,SZ8->(RecNo()))
		dbSelectArea("SZ8")
		dbSkip()
	EndDo
	
	Do Case
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inclusao / Alteracao                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case nOpc != 3
			
			For nCntFor := 1 To Len(aCols)
				
				If ( nCntFor > Len(aRegistro) )
					If ( !aCols[nCntFor][nUsado+1] )
						
						RecLock("SZ8",.T.)
					EndIf
				Else
					
					SZ8->(dbGoto(aRegistro[nCntFor]))
					RecLock("SZ8")
				EndIf
				
				If ( !aCols[nCntFor][nUsado+1] )
					
					lGravou := .T.
					For nCntFor2 := 1 To nUsado
						
						If ( aHeader[nCntFor2][10] != "V" )
							
							FieldPut(FieldPos(aHeader[nCntFor2][2]),aCols[nCntFor][nCntFor2])
						EndIf
					Next nCntFor2
					
					cItem := Soma1( cItem )
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Grava os campos obrigatorios                                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SZ8->Z8_FILIAL 	:= xFilial("SZ8")
					SZ8->Z8_CODRENE	:= M->Z7_CODRENE
					SZ8->Z8_ITEM 		:= cItem
				Else
					If ( nCntFor <= Len(aRegistro) )
						
						dbDelete()
					EndIf
				EndIf
				MsUnLock()
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Guarda Numero dos Registros das Tarefas para Confirmacao     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aAdd ( aRecnoSZ8, SZ8->(Recno()) )
			Next nCntFor
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Suspensao                                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		OtherWise
			
			// COMANDOS PARA SUSPENSAO
	EndCase
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualizacao do Cabecalho                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SZ7")
	dbSetOrder(1)
	If ( MsSeek(xFilial("SZ7")+M->Z7_CODRENE ) )
		
		RecLock("SZ7", .f.)
	Else
		If ( lGravou )
			
			RecLock("SZ7",.T.)
		EndIf
	EndIf
	
	If ( !lGravou )
		
		SZ7->Z7_STATUS := "S" // SUSPENSO
	Else
		
		For nCntFor := 1 To SZ7->(FCount())
			
			If ( FieldName(nCntFor)!="Z7_FILIAL" )
				
				FieldPut(nCntFor,M->&(FieldName(nCntFor)))
			Else
				
				SZ7->Z7_FILIAL := xFilial("SZ7")
			EndIf
		Next nCntFor
		
		If nOpc == 1 // inclusao
			
			SZ7->Z7_STATUS := "P" // PENDENTE
		EndIf
	EndIf
	MsUnLock()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a integridade da rotina                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aArea)

Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³SCA20TudOk³ Autor ³Joao Mattos            ³ Data ³10.10.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o   ³Funcao TudOk                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 := SCA20TudOk()                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 -> Validacao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
User Function SCA20TudOk()

Local aArea     := GetArea()
Local lReturn   := .t.

RestArea(aArea)

Return( lReturn )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Joao Mattos           ³ Data ³08/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transação a ser efetuada:                        ³±±
±±³          ³	1 - Pesquisa e Posiciona em um Banco de Dados     		  ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()

Local aRotina := {	{ OemToAnsi("Pesquisar") 	, "AxPesqui" 			, 0 , 1	},; // "Pesquisar"
{ OemToAnsi("Visualizar")	, "u_SCA20VISUAL" 	, 0 , 2	},;	// "Visualizar"
{ OemToAnsi("Incluir")		, "u_SCA20INCLUI" 	, 0 , 3	},;	// "Incluir"
{ OemToAnsi("Alterar")		, "u_SCA20ALTERA" 	, 0 , 4	},;	// "Alterar"
{ OemToAnsi("Suspende")		, "u_SCA20SUSPEN" 	, 0 , 5	},;	// "Suspende"
{ OemToAnsi("Aprova")		, "u_SCA20APROVA" 	, 0 , 6	},;	// "Aprova"
{ OemToAnsi("Imprime")		, "u_SCIR010" 		, 0 , 7	},;	// "Imprime"
{ OemToAnsi("Legenda")		, "u_SCA20LEGEND" 	, 0 , 8	}}	// "Legenda"

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CriaSX1   ³ Autor ³ Joao Mattos           ³ Data ³17.10.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Cria perguntas                                             ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CriaSX1()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC01 - Nome do conjunto de perguntas                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Sport Club Internacional                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CriaSX1( cPerg )

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}
Local nContador	:= 0
Local cNroPerg	:= ""

//-- MV_PAR01
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}
nContador ++
cNroPerg	:= StrZero(nContador, 2)

Aadd( aHelpPor, 'Informe o diretório onde será gravado  '  )
Aadd( aHelpPor, 'o arquivo texto.                       '  )

Aadd( aHelpSpa, 'Informe o diretório onde será gravado  '  )
Aadd( aHelpSpa, 'o arquivo texto.                       '  )

Aadd( aHelpEng, 'Informe o diretório onde será gravado  '  )
Aadd( aHelpEng, 'o arquivo texto.                       '  )

//PutSx1( cPerg , cNroPerg, "Diretório?","Diretório?","Diretório?","mv_ch1","C",99,0,0,"G","","  ","","","mv_par" + cNroPerg,"","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

Return ( Nil )		
