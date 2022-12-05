#include "rwmake.ch"
#include "protheus.ch"

STATIC aDescEsca												// Usado na funcao TKREGRADESC 
STATIC lChecaKit  := SuperGetMv("MV_TMKKIT")                    // Indica se o sistema vai lancar automaticamente KIT 

User Function Tk273Clc(cCampo,nLinha,lTudo)

//#include "Tmkdef.ch"

Local nValor    := M->&(cCampo)			// Get atual do campo
Local nPProd    := aPosicoes[1][2]			// Posicao do Produto
Local nPQtd 	:= aPosicoes[4][2]			// Posicao da Quantidade
Local nPTes	    := aPosicoes[11][2]			// Tes
Local nPItem	:= aPosicoes[20][2]        // Posicao do Item
Local aListaKit	:= {}						// Itens do cadastro de KIT
Local nCont 	:= 0 						// Contador	de Itens do KIT
Local nAtual  	:= 0						// Linha atual depois da inclusao de KIT 
Local nColuna 	:= 1   						// Contador de colunas do aHeader
Local cItem 	:= ""						// Valor do item dos produtos (01,02,...)
Local lRet      := .F.						// Retorno da funcao
Local nPVlrItem := aPosicoes[6][2]			// Posicao do Valor do item 
Local nPVrUnit  := aPosicoes[5][2]				// Posicao do Valor unitario
Local lReplace  := .F.							// Indica se o codigo do produto esta sendo alterado no acols
Local nPValDesc := aPosicoes[10][2]			// $ Desconto em Valor

If Empty(M->UA_CLIENTE)
	Help(" ",1,"SEM CLIENT")
	Return(lRet)
Endif	

nLinha:= IIF(ValType(nLinha) == "U", n, nLinha )
lTudo := IIF(ValType(lTudo) == "U", .F., lTudo )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe os produtos.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cCampo <> "UB_PRODUTO"
	If Empty(aCols[nLinha][nPProd])
		Return(lRet)
	Endif
Else
	If	Upper(AllTrim(aCols[nLinha][nPProd])) <> Upper(AllTrim(nValor)) .AND.;
		Upper(AllTrim(aCols[nLinha][nPProd])) <> ""
		
		lReplace := .T.	
		
	Endif
Endif  

Do Case
 	Case (cCampo == "UA_TABELA")
 	    nValor := aCols[nLinha][nPProd]
		lRet := TKP000A(nValor,nLinha,lTudo)

 	Case (cCampo == "UB_PRODUTO")
		lRet := TKP000A(nValor,nLinha,lTudo)
	
	Case (cCampo == "UB_QUANT")
		lRet := TKP000B(nValor,nLinha)
		
	Case (cCampo == "UB_VRUNIT")
		lRet := TkP000C(nValor,nLinha)
		
	Case (cCampo == "UB_DESC")
		lRet := TkP000D(nValor,nLinha)
		If !lRet
			Return(lRet)
		Endif	
		
	Case (cCampo == "UB_VALDESC")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a TES utilizada e diferente da TES de bonificacao calcula os acrescimos e descontos ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRet := TkP000E(nValor,nLinha)
		If !lRet
			Return(lRet)
		Endif	
		
	Case (cCampo == "UB_ACRE")
		lRet := TkP000G(nValor,nLinha)
		If !lRet
			Return(lRet)
		Endif	
			
	Case (cCampo == "UB_VALACRE")
		lRet := TkP000H(nValor,nLinha)
		If !lRet
			Return(lRet)
		Endif	

Endcase
Eval(bRefresh)

MaFisAlt("IT_TES",aCols[nLinha][nPTes],nLinha)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Recalcula o item para garantir os impostos de acordo com a quantidade informada se houver desconto da SUFRAMA ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aValores[SUFRAMA] > 0 
	Tk273Recalc(nLinha)
Endif

If MaFisFound()
	MaColsToFis(aHeader,aCols,nLinha,"TK273",.T.)
	Tk273Refresh(aValores)	
Endif

If M->UA_PDESCAB > 0
	Tk273CalcDesc()
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se esse TES gera titulos para nao obrigar a selecao das condicoes de pagamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SF4")
DbSetOrder(1)
If DbSeek(xFilial("SF4")+aCols[nLinha][nPTes])
	If SF4->F4_DUPLIC == "S"
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a TES nao estiver bloqueada valida se a quantidade pode ser igual a 0,00  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If MaTesSel(aCols[nLinha][nPTes])
			lTesTit := .F.				
		Else
			lTesTit := .T.	
		Endif
	Else
		lTesTit := .F.
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe o KIT no cadastro de acessorios³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (lChecaKit) .AND. (cCampo == "UB_PRODUTO")
	
	DbSelectarea("SUG")
	DbSetorder(2)
	If DbSeek(xFilial("SUG") + nValor)
		If nValor == SUG->UG_PRODUTO
			DbSelectarea("SU1")
			DbSetorder(1)
			If DbSeek(xFilial("SU1")+SUG->UG_CODACE)
				While (! Eof()) .AND. (SU1->U1_FILIAL == xFilial("SU1")) .AND. (SU1->U1_CODACE == SUG->UG_CODACE)
						
					If SU1->U1_KIT == "1"  //SIM
						
						AADD(aListaKit,{SU1->U1_ACESSOR,;			//Codigo do Acessorio
										SU1->U1_QTD})				//Quantidade
					Endif
					
					SU1->(DbSkip())
				End
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pega o conteudo o ultimo item (Valor)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cItem 	:= aCols[Len(aCols)][nPItem]
			nAtual  := 0
			nAtual	:= LEN(aCols)
			
			For nCont := 1 TO Len(aListaKit)
				AADD(aCols,Array(len(aHeader)+1))
				nAtual ++
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³X3_TITULO   1³
				//³X3_CAMPO    2³
				//³X3_PICTURE  3³
				//³X3_TAMANHO  4³
				//³X3_DECIMAL  5³
				//³X3_VALID    6³
				//³X3_USADO    7³
				//³X3_TIPO     8³
				//³X3_ARQUIVO  9³
				//³X3_CONTEXT 10³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Inicializa as variaveis da aCols (tratamento para    ³
				//³campos criados pelo usu rio)							³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nColuna := 1 To LEN( aHeader )
					
					If aHeader[nColuna][8] == "C"
						aCols[nAtual][nColuna] := SPACE(aHeader[nColuna][4])
						
					ElseIf aHeader[nColuna][8] == "D"
						aCols[nAtual][nColuna] := dDataBase
						
					ElseIf aHeader[nColuna][8] == "M"
						aCols[nAtual][nColuna] := ""
						
					ElseIf aHeader[nColuna][8] == "N"
						aCols[nAtual][nColuna] := 0
						
					Else
						aCols[nAtual][nColuna] := .F.
					Endif
					
				Next nColuna
				
				aCols[nAtual][LEN(aHeader)+1] := .F.
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza o aCols com o acessorio, atualizado o item o produto e a quantidade alem da funcao fiscal ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cItem 			 	  := Soma1(cItem,Len(cItem))
				aCols[nAtual][nPItem] := cItem
				
				M->UB_PRODUTO	 	  := aListaKit[nCont][1]
				aCols[nAtual][nPProd] := aListaKit[nCont][1]
				
				MaColsToFis(aHeader,aCols,nAtual,"TK273",.F.)
				TKP000A(M->UB_PRODUTO,nAtual,NIL)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza o acols com as quantidades e recalcula os valores do item.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				M->UB_QUANT  		 := aListaKit[nCont][2]
				aCols[nAtual][nPQtd] := aListaKit[nCont][2]
				TKP000B(M->UB_QUANT,nAtual)
				
			Next nCont
			n := nAtual
			M->UB_PRODUTO := nValor // Inicializa a variavel de memoria com o item pai

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se nao estiver usando a entrada automatica³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lTk271Auto 
				oGetTlv:oBrowse:Refresh()
			Endif	
		Endif
	Endif
Endif

Return(lRet)

/*                                                    
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TKP000A  ³ Autor ³ Marcelo Kotaki        ³ Data ³ 18/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o preco de acordo com o produto -   UB_PRODUTO    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³11/06/02³710   ³-Revisao do fonte                     	  ³±±
±±³Marcelo K ³17/06/02³710   ³-Inclusao da opcao KIT - SU1/Acessorios	  ³±±
±±³Andrea F. ³07/04/05³811   ³ BOPS 80762- Sempre gatilhar a TES quando o ³±±
±±³          ³        ³      ³codigo do produto for digitado ou via F3.	  ³±±
±±³Henry F   ³26/08/05³811   ³ BOPS 85138- Ajustado o reacalculo das fun  ³±±
±±³          ³        ³      ³coes fiscais quando alterado o produto  	  ³±±
±±³Henry F   ³22/11/05³811   ³ BOPS 88191- Ajustado do gatilho da Tes     ³±±
±±³          ³        ³      ³quando o produto for de bonificacao     	  ³±±
±±³Henry F   ³13/11/05³811   ³ BOPS 89371- Inclusao da funcao existcpo    ³±±
±±³          ³        ³      ³para realizar o tratamento do B1_MSBLQL 	  ³±±
±±³Marcelo K ³20/02/06³811   ³-Bops 93313/ 92811 - Correcao do refresh da ³±±
±±³          ³        ³      ³descricao do produto na escolha do produto  ³±±
±±³          ³        ³      ³por digitacao.                              ³±±
±±³          ³        ³      ³- PMC: Sintaxe simplificada no IIF          ³±±
±±³          ³        ³      ³- PMC: Uso de SuperGetMv ao inves de GETMV  ³±±
±±³Marcelo K ³04/07/06³8,11  ³-Bops 95955 - Validacao do bloqueio de 	  ³±±
±±³          ³        ³      ³registro do cadastro de entrada/saida TES   ³±±
±±³Fernando  ³25/10/06³8.11  ³-BOPS104016 - na validacao do bloqueio a TES³±±
±±³          ³        ³      ³retorna vazio.                              ³±±
±±³Conrado Q.³04/12/06³811   ³ BOPS 111439 - Adicionado parâmetro .T. na  ³±±
±±³          ³        ³      ³chamada da função MaTabPrVen que atualiza	  ³±±
±±³          ³        ³      ³MV_ESTADO.                               	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TkP000A(nValor,nLinha,lTudo)

Local lRet   	:= .F.						// Retorno da funcao
Local nPProd	:= aPosicoes[1][2]			// Posicao do Codigo do produto
Local nPDescri  := aPosicoes[2][2]			// Posicao da Descricao do Produto
Local nPSitProd := aPosicoes[3][2]			// Posicao da Situacao do Produto
Local nPQtd 	:= aPosicoes[4][2]			// Posicao da Quantidade
Local nPVrUnit  := aPosicoes[5][2]			// Posicao do Valor unitario
Local nPVlrItem	:= aPosicoes[6][2]			// Posicao do Valor do item
Local nPLocal   := aPosicoes[7][2]			// Posicao do Local
Local nPUm	    := aPosicoes[8][2]			// Posicao da Unidade de medida
Local nPTes	    := aPosicoes[11][2]         // Posicao da TES     			
Local nPCFO		:= aPosicoes[12][2]			// Posicao da CF
Local nPPrcTab  := aPosicoes[15][2]			// Posicao do Preco de Tabela
Local nVrUnit	:= 0 						// Valor unitario
Local nDesc		:= 0						// Valor de desconto
Local cEstado   := SuperGetMV("MV_ESTADO")	// Estado da empresa que esta vendendo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
//³ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(FindFunction("SIGACUS_V") .AND. SIGACUS_V() >= 20050512)
    Final("Por favor, contacte o Administrador do Sistema - Será necessário atualizar os programas SIGACUS*.*")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona no produto digitado ou escolhido para ter certeza que esta no registro correto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectarea("SB1")
DbSetorder(1)      
If !DbSeek( xFilial("SB1") + nValor)
	Help(" ",1,"A010VAZ")
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida o bloqueio de registro do Produto escolhido              ³
//³ tratamento do  campo de bloqueio B1_MSBLQL                      |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ExistCpo("SB1", nValor)
	Return(lRet)
Endif        

MaFisAlt("IT_ALIQIPI",SB1->B1_IPI,nLinha)
MaFisAlt("IT_ALIQICM",SB1->B1_PICM,nLinha)

If Empty(aCols[nLinha][nPQtd])
	aCols[nLinha][nPQtd] := 1
Endif

MaFisAlt("IT_QUANT",aCols[nLinha][nPQtd],nLinha)
MaFisAlt("IT_PRODUTO",nValor,nLinha)

aCols[nLinha][nPProd]   := SB1->B1_COD
aCols[nLinha][nPDescri] := SB1->B1_DESC
aCols[nLinha][nPUm]     := SB1->B1_UM

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Sempre gatilha a TES quando for digitado o codigo do produto e somente nao gatilha quando a linha for de bonificacao³      
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCols[nLinha][nPTes] <> &(SuperGetMv("MV_BONUSTS"))
	If Empty( RetFldProd(SB1->B1_COD,"B1_TS") ) 
		aCols[nLinha][nPTes] := Tmk273TPad()
	Else
		aCols[nLinha][nPTes] := RetFldProd(SB1->B1_COD,"B1_TS")
	Endif	
Endif	

aCols[nLinha][nPLocal]  := RetFldProd(SB1->B1_COD,"B1_LOCPAD")
aCols[nLinha][nPSitProd]:= SB1->B1_SITPROD
aCols[nLinha][nPVrUnit] := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico o ESTADO do cliente³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectarea("SF4")
DbSetorder(1)
If DbSeek(xFilial("SF4") + aCols[nLinha][nPTes] )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida o bloqueio de registro da TES utilizada                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !ExistCpo("SF4", aCols[nLinha][nPTes])
		aCols[nLinha][nPTes]:=CriaVar("UB_TES",.F.)
	Endif
		lRet := .T.	

	If cPaisLoc!="BRA"
		aCols[nLinha,nPCFO] := ALLTRIM(SF4->F4_CF)
	Else
		If (SA1->A1_TIPO != "X")
			If (SA1->A1_EST == cEstado)
				aCols[nLinha,nPCFO] := SF4->F4_CF
			Else
				aCols[nLinha,nPCFO] := "6" + Subs( SF4->F4_CF,2,LEN(SF4->F4_CF)-1 ) 
			Endif
		Else	
			aCols[nLinha,nPCFO] := "7" + Subs( SF4->F4_CF,2,LEN(SF4->F4_CF)-1 ) 	
		Endif	
	Endif
	MaFisAlt("IT_CF",aCols[nLinha][nPCFO],nLinha)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a tabela nao for vazia pega o preco de tabela,              ³
//³caso contrario pega o valor informado no Cadastro do Produto   ³
//³Isso ocorre para manter a compatiblizacao com o SIGAFAT        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(M->UA_TABELA)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for uma tabela de preco valida calcula o valor unitario do item³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVrUnit := MaTabPrVen(	M->UA_TABELA	,aCols[nLinha][nPProd]	,aCols[nLinha][nPQtd]	,M->UA_CLIENTE	,;
							M->UA_LOJA		,M->UA_MOEDA			,						,				,;
											,.T.	)
Else
	DbSelectarea("SB1")
	DbSetorder(1)
	If DbSeek( xFilial("SB1")+aCols[nLinha][nPProd] )
		nVrUnit := SB1->B1_PRV1
	Endif
Endif


aCols[nLinha][nPVrUnit] := nVrUnit
aCols[nLinha][nPPrcTab] := nVrUnit
aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VLRITEM")
MaFisAlt("IT_VALMERC",aCols[nLinha][nPVlrItem],nLinha)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Aplica a regra da TABELA DE DESCONTOS no item          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nDesc := TkRegraDesc(1,aValores[TOTAL],0,NIL,M->UA_CONDPG,nLinha)
TkP000D(nDesc,nLinha)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se houver DESCONTO EM CASCATA ja aplica o valor no item³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If 	(M->UA_DESC4 > 0) .OR. ;
	(M->UA_DESC1 > 0) .OR. ;
	(M->UA_DESC2 > 0) .OR. ;
	(M->UA_DESC3 > 0)
	Tk273DesCab(nLinha,lTudo)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao estiver usando a entrada automatica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTk271Auto 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa o refresh na GetDados para garantir que todas as informacoes estejam visiveis para o Operador³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oGetTlv:oBrowse:Refresh(.T.)
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TKP000B  ³ Autor ³ Marcelo Kotaki        ³ Data ³ 18/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o valor do item de acordo com quantidade- UB_QUANT³±±
±±³          ³ o valor do item vai considerar somente os DESCONTOS de:    ³±±
±±³          ³ - CABECALHO                                                ³±±
±±³          ³ - ITEM                                                     ³±±
±±³          ³ O ACRESCIMO sera sempre atualizado com 0                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³22/09/04³710   ³-BOPS 74442                           	  ³±±
±±³Conrado Q.³04/12/06³811   ³ BOPS 111439 - Adicionado parâmetro .T. na  ³±±
±±³          ³        ³      ³chamada da função MaTabPrVen que atualiza	  ³±±
±±³          ³        ³      ³MV_ESTADO.                               	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                     
Static Function TkP000B(nValor,nLinha)

Local lRet		:= .F.						// Retorno da funcao
Local nPProd	:= aPosicoes[1][2]			// Produto	
Local nPQtd     := aPosicoes[4][2]			// Quantidade          
Local nPVrUnit  := aPosicoes[5][2]			// Valor unitario
Local nPVlrItem := aPosicoes[6][2]			// Valor do item
Local nPDesc 	:= aPosicoes[9][2]			// % Desconto
Local nPValDesc := aPosicoes[10][2]			// $ Desconto em Valor
Local nPAcre 	:= aPosicoes[13][2]			// % Acrescimo
Local nPValAcre := aPosicoes[14][2]			// $ Acrescimo em Valor
Local nPPrcTab  := aPosicoes[15][2]			// Preco de Tabela
Local nDesc		:= 0 						// Variavel auxiliar	

If !Empty(M->UA_TABELA)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for uma tabela de preço valida calcula o valor unitario do item    ³
	//³Utilizada a funcao de materiais para  calculo da faixa.               ³                                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols[nLinha][nPVrUnit] := MaTabPrVen(	M->UA_TABELA	,aCols[nLinha][nPProd]	,nValor	,M->UA_CLIENTE	,;
											M->UA_LOJA		,M->UA_MOEDA			,		,				,;
															,.T.	)
	aCols[nLinha][nPPrcTab] := aCols[nLinha][nPVrUnit]
Endif

aCols[nLinha][nPQtd]    := nValor
aCols[nLinha][nPVlrItem]:= (aCols[nLinha][nPQtd] * aCols[nLinha][nPVrUnit])

MaFisAlt("IT_QUANT",aCols[nLinha][nPQtd],nLinha)
MaFisAlt("IT_PRCUNI",aCols[nLinha][nPVrUnit],nLinha)
MaFisAlt("IT_VALMERC",aCols[nLinha][nPVlrItem],nLinha)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Zera os DESCONTOS 			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols[nLinha][nPDesc] 	 := 0 
aCols[nLinha][nPValDesc] := 0 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Zera os ACRESCIMOS 			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols[nLinha][nPAcre] 	 := 0 
aCols[nLinha][nPValAcre] := 0 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Aplica a regra da TABELA DE DESCONTOS                  ³
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nDesc := TkRegraDesc(1,aValores[TOTAL],0,NIL,M->UA_CONDPG,nLinha)
lRet  := TkP000D(nDesc,nLinha)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se houver DESCONTO EM CASCATA ja aplica o valor no item³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (M->UA_DESC4 > 0) .OR. (M->UA_DESC1 > 0) .OR. (M->UA_DESC2 > 0) .OR. (M->UA_DESC3 > 0) .OR. (ReadVar() == "M->UB_QUANT")
	Tk273DesCab(nLinha,.F.)
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TKP000C  ³ Autor ³ Marcelo Kotaki        ³ Data ³ 18/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula o valor do item quando o unitario for atualizado   ³±±
±±³			 ³ UB_VRUNIT                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TELEVENDAS                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³11/06/02³710   ³-Revisao do fonte                     	  ³±±
±±³Henry F   ³26/10/05³811   ³-Bops 88060 - Implementacao do ponto de en- ³±±
±±³          ³        ³      ³trada TK27300C                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TkP000C(nValor,nLinha)

Local lRet 		:= .T.									// Retorno da funcao
Local nPQtd		:= aPosicoes[4][2]						// Quantidade
Local nPVrUnit	:= aPosicoes[5][2]						// Valor unitario
Local nPVlrItem := aPosicoes[6][2]						// Valor do item 
Local nPDesc 	:= aPosicoes[9][2]						// % Desconto
Local nPValDesc := aPosicoes[10][2]						// $ Desconto em valor
Local nPValAcre := aPosicoes[14][2]						// $ Acrescimo em valor	
Local nPPrcTab  := aPosicoes[15][2]						// Preco de tabela
Local cPrcFiscal:= TkPosto(M->UA_OPERADO,"U0_PRECOF") 	// Preco fiscal bruto 1=SIM / 2=NAO
Local lTk27300C := FindFunction("U_TK27300C")			// P.E. utilizado na alteracao do preco unitario


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a existencia do ponto de entrada de validacao do preco³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTk27300C
	lRet := U_TK27300C()
	If ValType(lRet) <> "L"
		lRet := .F.
	Endif	
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso seja verdadeira executa os processos de validacao. A        ³
//³variavel lRet e sempre inicializada com .T. para caso nao exista ³
//³o ponto de entrada, o processo seja realizado normalmente        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	aCols[nLinha][nPVrUnit] := nValor
	aCols[nLinha][nPPrcTab] := nValor
	
	aCols[nLinha][nPDesc]   := 0
	aCols[nLinha][nPValDesc]:= 0
	aCols[nLinha][nPValAcre]:= 0
	aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VLRITEM")
	
	MaFisAlt("IT_PRCUNI",aCols[nLinha][nPVrUnit],nLinha)
	MaFisAlt("IT_VALMERC",aCols[nLinha][nPVlrItem],nLinha)
	If cPrcFiscal == "1"  // Se for Preco fiscal bruto = 1 - Sim
		aValores[DESCONTO] := 0
		If !aCols[nLinha][Len(aHeader)+1]		// Se a linha for valida
			aValores[DESCONTO] += aCols[nLinha][nPValDesc]
		Endif	
	Endif

Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TkP000D  ³ Autor ³ Marcelo Kotaki   		³ Data ³ 18/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao do desconto (%) do item campo - UB_DESC          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TELEVENDAS                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³11/06/02³710   ³-Revisao do fonte                     	  ³±±
±±³Conrado Q.³15/01/07³811   ³-BOPS 116486: Zera os valores existentes no ³±±
±±³          ³        ³      ³acrescimo.                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TkP000D(nValor,nLinha)

Local lRet		:=.F.					                // Retorno da funcao
Local nPQtd		:= aPosicoes[4][2]                      // Posicao da Quantidade
Local nPVrUnit	:= aPosicoes[5][2]						// Posicao do Valor unitario
Local nPVlrItem := aPosicoes[6][2]						// Posicao do Valor do item
Local nPDesc 	:= aPosicoes[9][2]						// Posicao do % Desconto
Local nPValDesc := aPosicoes[10][2]						// Posicao do $ Desconto em Valor
Local nPTes	    := aPosicoes[11][2]						// Posicao do Codigo do TES
Local nPAcre 	:= aPosicoes[13][2]                     // Posicao do Acrescimo em %
Local nPValAcre := aPosicoes[14][2]						// Posicao do % Acrescimo	
Local nPPrctab  := aPosicoes[15][2]						// Posicao do Preco de Tabela
Local nValUni   := 0									// Valor unitario	
Local nVlrTab   := 0									// Valor de tabela			
Local cDesconto := TkPosto(M->UA_OPERADO,"U0_DESCONT")	// Desconto  1=ITEM / 2=TOTAL / 3=AMBOS / 4=NAO
Local cPrcFiscal:= TkPosto(M->UA_OPERADO,"U0_PRECOF") 	// Preco fiscal bruto 1=SIM / 2=NAO
Local cTesBonus := SuperGetMv("MV_BONUSTS") 			// Codigo da TES usado para as regras de bonificacao
Local cTes    	:= aCols[nLinha][nPTes]					// Conteudo do TES

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a TES utilizada for igual a TES de bonificacao nao calcula os acrescimos e descontos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cTes == cTesBonus)
	Return(lRet)
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³So pode dar desconto se o Posto de venda estiver configurado para Item ou Ambos						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Alltrim(cDesconto) == "2" .OR. Alltrim(cDesconto) == "4"   // Desconto = Total ou Desconto = Nao
	If nValor > 0 
		If  !lTk271Auto 
			Help( " ", 1, "NAO_DESCON")
		Endif	
		aCols[nLinha][nPDesc] := 0
		Return(lRet)
	Endif
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O valor de deconto (%) nao pode ser maior ou igual a 100%  			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nValor >= 100
	Help( " ", 1, "DESCMAIOR2" )
	aCols[nLinha][nPDesc] := 0
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz os calculos de desconto baseando-se no preco de tabela  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCols[nLinha][nPPrcTab] > 0
	nVlrTab := aCols[nLinha][nPPrcTab]
Else
	nVlrTab := aCols[nLinha][nPVrUnit]
Endif

aCols[nLinha][nPDesc]:= nValor
nValUni 			 := A410Arred(nVlrTab * (1-(nValor/100)),"UB_VRUNIT")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o posto de venda do operador estiver com preco fiscal bruto = NAO  ³
//³o valor unitario do produto sera recalculado com desconto 		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Alltrim(cPrcFiscal) == "2"  //NAO
	aCols[nLinha][nPVrUnit]	:= nValUni
	aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VLRITEM")
	aCols[nLinha][nPValDesc]:= A410Arred(aCols[nLinha][nPQtd]*nVlrTab,"UB_VALDESC") - aCols[nLinha][nPVlrItem]
	aCols[nLinha][nPValAcre]:= 0
	aCols[nLinha][nPAcre]	:= 0
Else
	aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VLRITEM")
	aCols[nLinha][nPValDesc]:= aCols[nLinha][nPVlrItem] - A410Arred(aCols[nLinha][nPQtd]*nValUni,"UB_VALDESC")
	aCols[nLinha][nPValAcre]:= 0
	aCols[nLinha][nPAcre]	:= 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Jogo o desconto desse item no TOTAL pois o valor do unitario nao sera recalculado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPrcFiscal == "1"  // Se for PRECO FISCAL BRUTO igual a SIM
		aValores[DESCONTO]:= 0
		If !aCols[nLinha][Len(aHeader)+1]		// Se a linha for valida
			aValores[DESCONTO] += aCols[nLinha][nPValDesc]
		Endif	
		Tk273Refresh(aValores)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O desconto nao pode ser maior que o valor de Tabela		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCols[nLinha][nPValDesc] >= (aCols[nLinha][nPPrcTab]*aCols[nLinha][nPQtd]) .AND. nValor > 0
	Help(" ", 1, "DESCMAIOR2" )
	aCols[nLinha][nPDesc]   := 0
	aCols[nLinha][nPValDesc]:= 0
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se houver DESCONTO EM CASCATA considera com o valor de desconto atual ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If 	(M->UA_DESC4 > 0) .OR. ;
	(M->UA_DESC1 > 0) .OR. ;
	(M->UA_DESC2 > 0) .OR. ;
	(M->UA_DESC3 > 0)
	Tk273DesCLi(nLinha,1)	// Percentual
Endif
lRet:=.T.

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TkP000E  ³ Autor ³ Luis Marcelo Kotaki   ³ Data ³ 20/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao do desconto (R$) do item campo - UB_VALDESC      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TELEVENDAS                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³11/06/02³710   ³-Revisao do fonte                     	  ³±±
±±³Marcelo K ³03/04/06³710   ³-Bops:95512 revisao do calculo do preco de  ³±±
±±³          ³        ³      ³tabela quando o usuario lancar o valor desc.³±±
±±³Conrado Q.³15/01/07³811   ³-BOPS 116486: Zera os valores existentes no ³±±
±±³          ³        ³      ³acrescimo.                                  ³±±
±±³          ³        ³      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TkP000E(nValor,nLinha)

Local lRet		:=.F.                                   // Retorno da funcao
Local nPQtd		:= aPosicoes[4][2]                      // Posicao da Quantidade
Local nPVrUnit	:= aPosicoes[5][2]						// Posicao do Valor unitario
Local nPVlrItem := aPosicoes[6][2]						// Posicao do Valor do item
Local nPDesc 	:= aPosicoes[9][2]						// Posicao do Desconto em %
Local nPValDesc := aPosicoes[10][2]						// Posicao do Valor desconto $
Local nPTes     := aPosicoes[11][2]						// Posicao do TES
Local nPAcre 	:= aPosicoes[13][2]                     // Posicao do Acrescimo em %
Local nPValAcre := aPosicoes[14][2]						// Posicao do Valor do Acrescimo $
Local nPPrctab  := aPosicoes[15][2]                     // Posicao do Preco de Tabela
Local nValUni   := 0									// Valor Unitario
Local nVlrTab   := 0                                    // Valor da Tabela
Local cDesconto := TkPosto(M->UA_OPERADO,"U0_DESCONT")	// Desconto  1=ITEM / 2=TOTAL / 3=AMBOS / 4=NAO
Local cPrcFiscal:= TkPosto(M->UA_OPERADO,"U0_PRECOF") 	// Preco fiscal bruto 1=SIM / 2=NAO
Local cTesBonus := SuperGetMv("MV_BONUSTS") 			// Codigo da TES usado para as regras de bonificacao
Local cTes    	:= aCols[nLinha][nPTes]					// Conteudo do TES
Local nValItem  := 0									// Valor auxiliar	
Local nAuxDesc  := CRIAVAR("UB_VALDESC",.F.)				

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a TES utilizada for igual a TES de bonificacao nao calcula os acrescimos e descontos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cTes == cTesBonus)
	Return(lRet)
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³So pode dar desconto se o Posto de venda estiver      	³
//³configurado para Item ou Ambos					    	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Alltrim(cDesconto) == "2" .OR. Alltrim(cDesconto) == "4"   // Item ou Total
	If nValor > 0 
		If  !lTk271Auto 
			Help( " ", 1, "NAO_DESCON")
		Endif	
		aCols[nLinha][nPValDesc] := 0
		Return(lRet)
	Endif	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Zero o desconto em %³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols[nLinha][nPDesc]    := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrego novamente o valor de desconto calculado		    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols[nLinha][nPValDesc] := nValor

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O Valor do desconto nao pode ser maior que o vlr. do item³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nValor >= aCols[nLinha][nPVlrItem]
	Help( " ", 1, "DESCMAIOR2" )
	aCols[nLinha][nPValDesc] := 0
	aCols[nLinha][nPDesc]    := 0
	aCols[nLinha][nPValDesc] := 0
	Return(lRet)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz os calculos de desconto baseando-se no preco de tabela  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCols[nLinha][nPPrcTab] > 0
	nVlrTab := aCols[nLinha][nPPrcTab]
Else
	nVlrTab := aCols[nLinha][nPVrUnit]
Endif                                       

nValItem:= (nVlrTab * aCols[nLinha][nPQtd])
nValUni := 0
nAuxDesc := A410Arred(nValor/aCols[nLinha][nPQtd],"D2_PRCVEN")
nValUni  := A410Arred(nVlrTab - nAuxDesc,"D2_PRCVEN")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se houver DESCONTO EM CASCATA ja aplica o valor no item³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (M->UA_DESC4 > 0) .OR. (M->UA_DESC1 > 0) .OR. (M->UA_DESC2 > 0) .OR. (M->UA_DESC3 > 0)
	Tk273DesCLi(nLinha,2)	// R$
	nValUni := aCols[nLinha][nPVrUnit]
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o posto de venda do operador nao trabalha com  ³
//³preco fiscal bruto jogo o desconto sobre o valor  ³
//³unitario do produto                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Alltrim(cPrcFiscal) == "2"  //Preco Fiscal Bruto = 2-Nao
	aCols[nLinha][nPVrUnit] := nValUni
	aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VLRITEM")
	aCols[nLinha][nPValDesc]:= A410Arred(aCols[nLinha][nPQtd]*nVlrTab,"UB_VALDESC") - aCols[nLinha][nPVlrItem]
	aCols[nLinha][nPValDesc]:= A410Arred(nValItem - aCols[nLinha][nPVlrItem],"UB_VALDESC")
	aCols[nLinha][nPValAcre]:= 0
	aCols[nLinha][nPAcre]	:= 0
Else
	aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VLRITEM")
	aCols[nLinha][nPValDesc]:= aCols[nLinha][nPVlrItem] - A410Arred(aCols[nLinha][nPQtd]*nValUni,"UB_VALDESC")
	aCols[nLinha][nPValAcre]:= 0
	aCols[nLinha][nPAcre]	:= 0	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Jogo o desconto desse item no TOTAL pois o valor do unitario nao sera recalculado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPrcFiscal == "1"  // Se for PRECO FISCAL BRUTO igual a SIM
		aValores[DESCONTO]:= 0
		If !aCols[nLinha][Len(aHeader)+1]		// Se a linha for valida
			aValores[DESCONTO] += aCols[nLinha][nPValDesc]
		Endif	
	Endif
	Tk273Refresh(aValores)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula a porcentagem do desconto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols[nLinha][nPDesc] := A410Arred((nValor / nValItem)*100,"UB_DESC")

lRet := .T.

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TKP000G  ³ Autor ³ Marcelo Kotaki        ³ Data ³ 18/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula o Valor do item de acordo com o acrescimo - UB_ACRE³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K ³11/06/02³710   ³-Revisao do fonte                     	  ³±±
±±³Conrado Q.³15/01/07³811   ³-BOPS 116486: Na hora de calcular o acrésci ³±±
±±³          ³        ³      ³mo, leva em consideração os descontos já    ³±±
±±³          ³        ³      ³existentes.                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TkP000G(nValor,nLinha)

Local cCampo 	:= ReadVar()							// Valor digitado pelo usuario
Local lRet 	 	:= .F.									// Retorno da funcao
Local nPQtd		:= aPosicoes[4][2]						// Posicao da Quantidade	
Local nPVrUnit	:= aPosicoes[5][2]						// Posicao do Valor unitario
Local nPVlrItem := aPosicoes[6][2]                      // Posicao do Valor do item
Local nPValDesc := aPosicoes[10][2]						// Posicao do Valor desconto $
Local nPTes	    := aPosicoes[11][2]						// Posicao do TES
Local nPAcre 	:= aPosicoes[13][2]                     // Posicao do Acrescimo em %
Local nPValAcre := aPosicoes[14][2]						// Posicao do Acrescimo em $		
Local nPPrcTab  := aPosicoes[15][2]						// Posicao do Preco de Tabela
Local nValUni   := 0									// Variavel auxiliar para calculo do unitario	
Local nVlrTab   := 0									// Variavel auxiliar 
Local cPrcFiscal:= TkPosto(M->UA_OPERADO,"U0_PRECOF") 	// Preco fiscal bruto 1=SIM / 2=NAO
Local cAcrescimo:= TkPosto(M->UA_OPERADO,"U0_ACRESCI") 	// Acrescimo 1=ITEM / 2=NAO
Local cTesBonus := SuperGetMv("MV_BONUSTS") 			// Codigo da TES usado para as regras de bonificacao
Local cTes    	:= aCols[nLinha][nPTes]					// Conteudo do TES	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a TES utilizada for igual a TES de bonificacao nao calcula os acrescimos e descontos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cTes == cTesBonus)
	Return(lRet)
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o posto de venda nao recalcula o unitario nao pode dar acrescimo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cCampo == "M->UB_ACRE"
	If ALLTRIM(cAcrescimo) == "2"  // Acrescimo = 2 - Nao
		If nValor > 0 
			Help( " ", 1, "NAO_ACRESC")
			aCols[nLinha][nPAcre]:= 0
			Return(lRet)
		Endif	
	ElseIf ALLTRIM(cPrcFiscal) == "1"  // Preco Fiscal Bruto NAO (NAO ALTERA O UNITARIO NAO PODE DAR ACRESCIMO)
		If nValor > 0 
			Help( " ", 1, "NAO_ACRESC")
			aCols[nLinha][nPAcre]:= 0
			Return(lRet)
		Endif	
	Endif
Endif

aCols[nLinha][nPAcre]:= nValor

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz os calculos de desconto baseando-se no Preco de Tabela  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCols[nLinha][nPPrcTab] > 0
	nVlrTab := aCols[nLinha][nPPrcTab]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Aplica descontos existentes, tanto do cabeçalho quando do³
	//³item.                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVlrTab := nVlrTab - ( aCols[nLinha][nPValDesc] / aCols[nLinha][nPQtd] )
	nVlrTab := nVlrTab - If(M->UA_DESC1 > 0, ( nVlrTab * M->UA_DESC1 ) / 100, 0)
	nVlrTab := nVlrTab - If(M->UA_DESC2 > 0, ( nVlrTab * M->UA_DESC2 ) / 100, 0)
	nVlrTab := nVlrTab - If(M->UA_DESC3 > 0, ( nVlrTab * M->UA_DESC3 ) / 100, 0)
	nVlrTab := nVlrTab - If(M->UA_DESC4 > 0, ( nVlrTab * M->UA_DESC4 ) / 100, 0)	
Else
	nVlrTab := aCols[nLinha][nPVrUnit]
Endif

nValUni	:= A410Arred(nVlrTab * (100 + nValor) / 100,"UB_VRUNIT")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O Acrescimo sempre recalcula  o valor do unitario porque se o for jogado no total (ACRESCIMO RODAPE)      ³
//³no momento de gerar o SC6 ser  gerado uma DIZIMA PERIODICA consequentemente n„o vai bater o valor liquido ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols[nLinha][nPVrUnit] := nValUni
aCols[nLinha][nPValAcre]:= A410Arred(((nVlrTab * aCols[nLinha][nPAcre]) / 100) * aCols[nLinha][nPQtd],"UB_VALACRE")
aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VLRITEM")

lRet := .T.

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TKP000H  ³ Autor ³ Marcelo Kotaki        ³ Data ³ 18/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula o Acrescimo do Item em valores -  UB_VALACRE       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TeleVendas                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo K.³11/06/02³7.10  ³-Revisao do fonte                     	  ³±±
±±³Marcelo K.³08/04/03³7.10  ³-Bops: 63849 Usar o valor de tabela do item ³±±
±±³          ³        ³      ³para calcular o % do acrescimo              ³±±
±±³Marcelo K.³27/04/06³7.10  ³-Bops: 97012 - Ajustado o calculo do valor  ³±±
±±³          ³        ³      ³unitario de acrescimo para nao considerar   ³±±
±±³          ³        ³      ³o valor total de desconto.                  ³±±
±±³Conrado Q.³15/01/07³811   ³-BOPS 116486: Na hora de calcular o acrésci ³±±
±±³          ³        ³      ³mo, leva em consideração os descontos já    ³±±
±±³          ³        ³      ³existentes.                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TkP000H(nValor,nLinha)

Local lRet 		:= .F.									// Retorno da funcao
Local nPQtd		:= aPosicoes[4][2]						// Posicao da Quantidade
Local nPVrUnit  := aPosicoes[5][2]						// Posicao do Valor unitario	
Local nPVlrItem := aPosicoes[6][2]						// Posicao do Valor do Item
Local nPValDesc := aPosicoes[10][2]						// Posicao do Valor de Desconto
Local nPTes	    := aPosicoes[11][2]						// Posicao do TES
Local nPAcre 	:= aPosicoes[13][2]						// Posicao do Acrescimo
Local nPValAcre := aPosicoes[14][2]						// Posicao do Valor de Acrescimo
Local nPPrctab  := aPosicoes[15][2]						// Posicao do Preco de Tabela
Local nValUni   := 0									// Variavel auxiliar
Local nVlrTab   := 0									// Valor de Tabela
Local cPrcFiscal:= TkPosto(M->UA_OPERADO,"U0_PRECOF") 	// Preco fiscal bruto 1=SIM / 2=NAO
Local cAcrescimo:= TkPosto(M->UA_OPERADO,"U0_ACRESCI") 	// Acrescimo 1=ITEM / 2=NAO
Local cTesBonus := SuperGetMv("MV_BONUSTS")				// Codigo da TES usado para as regras de bonificacao
Local cTes    	:= aCols[nLinha][nPTes]                 // Conteudo do TES

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a TES utilizada for igual a TES de bonificacao nao calcula os acrescimos e descontos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cTes == cTesBonus)
	Return(lRet)
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o posto de venda nao recalcula o unitario nao pode dar acrescimo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ALLTRIM(cAcrescimo) == "2"  // Acrescimo = 1 - Nao
	If nValor > 0 
		Help( " ", 1, "NAO_ACRESC")
		Return(lRet)
	Endif	
ElseIf ALLTRIM(cPrcFiscal) == "1"  // Preco Fiscal Bruto = 1- NAO
	If nValor > 0 
		Help( " ", 1, "NAO_ACRESC")
		Return(lRet)
	Endif	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz os calculos de desconto baseando-se no preco de tabela  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aCols[nLinha][nPPrcTab] > 0
	nVlrTab := aCols[nLinha][nPPrcTab]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Aplica descontos existentes, tanto do cabeçalho quando do³
	//³item.                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVlrTab := nVlrTab - ( aCols[nLinha][nPValDesc] / aCols[nLinha][nPQtd] )
	nVlrTab := nVlrTab - If(M->UA_DESC1 > 0, ( nVlrTab * M->UA_DESC1 ) / 100, 0)
	nVlrTab := nVlrTab - If(M->UA_DESC2 > 0, ( nVlrTab * M->UA_DESC2 ) / 100, 0)
	nVlrTab := nVlrTab - If(M->UA_DESC3 > 0, ( nVlrTab * M->UA_DESC3 ) / 100, 0)
	nVlrTab := nVlrTab - If(M->UA_DESC4 > 0, ( nVlrTab * M->UA_DESC4 ) / 100, 0)

Else
	nVlrTab := aCols[nLinha][nPVrUnit]
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula o % em funcao do acrescimo informado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols[nLinha][nPValAcre] := nValor
nValor 					 := A410Arred(nValor / aCols[nLinha][nPQtd],"UB_VALACRE")
nValor 					 := A410Arred((nValor / nVlrTab) * 100,"UB_ACRE")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O valor de acrescimo n„o pode passar de 100 % se o campo UB_ACRE estiver com tamanho 5 decimal 2 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If TamSX3("UB_ACRE")[1] <= 5
	If nValor >= 100
		MsgStop("O Valor de Acréscimo não pode ser maior que 100%") //
		nValor := 0                  
		aCols[nLinha][nPValAcre] := 0
		Return(lRet)
	Endif
Endif

aCols[nLinha][nPAcre]:= nValor

nValUni := A410Arred(nVlrTab * (100 + nValor) / 100,"UB_VRUNIT")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O Acrescimo sempre recalcula  o valor do unitario porque se o for jogado no total (ACRESCIMO RODAPE)      ³
//³no momento de gerar o SC6 ser  gerado uma DIZIMA PERIODICA consequentemente n„o vai bater o valor liquido ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols[nLinha][nPVrUnit] := nValUni
aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VLRITEM")

Tk273Trigger("UB_VLRITEM",nLinha)

lRet := .T.

Return(lRet)

