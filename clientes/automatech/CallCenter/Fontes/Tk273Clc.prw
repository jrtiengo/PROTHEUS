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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿣erifica se existe os produtos.�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿞e a TES utilizada e diferente da TES de bonificacao calcula os acrescimos e descontos �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿝ecalcula o item para garantir os impostos de acordo com a quantidade informada se houver desconto da SUFRAMA �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
	
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿣erifica se esse TES gera titulos para nao obrigar a selecao das condicoes de pagamento�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
DbSelectArea("SF4")
DbSetOrder(1)
If DbSeek(xFilial("SF4")+aCols[nLinha][nPTes])
	If SF4->F4_DUPLIC == "S"
	
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿞e a TES nao estiver bloqueada valida se a quantidade pode ser igual a 0,00  �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		If MaTesSel(aCols[nLinha][nPTes])
			lTesTit := .F.				
		Else
			lTesTit := .T.	
		Endif
	Else
		lTesTit := .F.
	Endif
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
//쿣erifica se existe o KIT no cadastro de acessorios�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
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
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			//쿛ega o conteudo o ultimo item (Valor)�
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			cItem 	:= aCols[Len(aCols)][nPItem]
			nAtual  := 0
			nAtual	:= LEN(aCols)
			
			For nCont := 1 TO Len(aListaKit)
				AADD(aCols,Array(len(aHeader)+1))
				nAtual ++
				
				//旼컴컴컴컴컴컴�
				//쿦3_TITULO   1�
				//쿦3_CAMPO    2�
				//쿦3_PICTURE  3�
				//쿦3_TAMANHO  4�
				//쿦3_DECIMAL  5�
				//쿦3_VALID    6�
				//쿦3_USADO    7�
				//쿦3_TIPO     8�
				//쿦3_ARQUIVO  9�
				//쿦3_CONTEXT 10�
				//읕컴컴컴컴컴컴�
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
				//쿔nicializa as variaveis da aCols (tratamento para    �
				//쿬ampos criados pelo usu쟲io)							�
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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
				
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
				//쿌tualiza o aCols com o acessorio, atualizado o item o produto e a quantidade alem da funcao fiscal �
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
				cItem 			 	  := Soma1(cItem,Len(cItem))
				aCols[nAtual][nPItem] := cItem
				
				M->UB_PRODUTO	 	  := aListaKit[nCont][1]
				aCols[nAtual][nPProd] := aListaKit[nCont][1]
				
				MaColsToFis(aHeader,aCols,nAtual,"TK273",.F.)
				TKP000A(M->UB_PRODUTO,nAtual,NIL)
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
				//쿌tualiza o acols com as quantidades e recalcula os valores do item.�
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
				M->UB_QUANT  		 := aListaKit[nCont][2]
				aCols[nAtual][nPQtd] := aListaKit[nCont][2]
				TKP000B(M->UB_QUANT,nAtual)
				
			Next nCont
			n := nAtual
			M->UB_PRODUTO := nValor // Inicializa a variavel de memoria com o item pai

			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//쿞e nao estiver usando a entrada automatica�
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			If !lTk271Auto 
				oGetTlv:oBrowse:Refresh()
			Endif	
		Endif
	Endif
Endif

Return(lRet)

/*                                                    
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o    � TKP000A  � Autor � Marcelo Kotaki        � Data � 18/01/02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Atualiza o preco de acordo com o produto -   UB_PRODUTO    낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � TeleVendas                                                 낢�
굇쳐컴컴컴컴컵컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿘arcelo K �11/06/02�710   �-Revisao do fonte                     	  낢�
굇쿘arcelo K �17/06/02�710   �-Inclusao da opcao KIT - SU1/Acessorios	  낢�
굇쿌ndrea F. �07/04/05�811   � BOPS 80762- Sempre gatilhar a TES quando o 낢�
굇�          �        �      쿬odigo do produto for digitado ou via F3.	  낢�
굇쿓enry F   �26/08/05�811   � BOPS 85138- Ajustado o reacalculo das fun  낢�
굇�          �        �      쿬oes fiscais quando alterado o produto  	  낢�
굇쿓enry F   �22/11/05�811   � BOPS 88191- Ajustado do gatilho da Tes     낢�
굇�          �        �      쿿uando o produto for de bonificacao     	  낢�
굇쿓enry F   �13/11/05�811   � BOPS 89371- Inclusao da funcao existcpo    낢�
굇�          �        �      쿾ara realizar o tratamento do B1_MSBLQL 	  낢�
굇쿘arcelo K �20/02/06�811   �-Bops 93313/ 92811 - Correcao do refresh da 낢�
굇�          �        �      쿭escricao do produto na escolha do produto  낢�
굇�          �        �      쿾or digitacao.                              낢�
굇�          �        �      �- PMC: Sintaxe simplificada no IIF          낢�
굇�          �        �      �- PMC: Uso de SuperGetMv ao inves de GETMV  낢�
굇쿘arcelo K �04/07/06�8,11  �-Bops 95955 - Validacao do bloqueio de 	  낢�
굇�          �        �      퀁egistro do cadastro de entrada/saida TES   낢�
굇쿑ernando  �25/10/06�8.11  �-BOPS104016 - na validacao do bloqueio a TES낢�
굇�          �        �      퀁etorna vazio.                              낢�
굇쿎onrado Q.�04/12/06�811   � BOPS 111439 - Adicionado par�metro .T. na  낢�
굇�          �        �      쿬hamada da fun豫o MaTabPrVen que atualiza	  낢�
굇�          �        �      쿘V_ESTADO.                               	  낢�
굇읕컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Funcao utilizada para verificar a ultima versao dos fontes      �
//� SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If !(FindFunction("SIGACUS_V") .AND. SIGACUS_V() >= 20050512)
    Final("Por favor, contacte o Administrador do Sistema - Ser� necess�rio atualizar os programas SIGACUS*.*")
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿛osiciona no produto digitado ou escolhido para ter certeza que esta no registro correto�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
DbSelectarea("SB1")
DbSetorder(1)      
If !DbSeek( xFilial("SB1") + nValor)
	Help(" ",1,"A010VAZ")
	Return(lRet)
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Valida o bloqueio de registro do Produto escolhido              �
//� tratamento do  campo de bloqueio B1_MSBLQL                      |
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿞empre gatilha a TES quando for digitado o codigo do produto e somente nao gatilha quando a linha for de bonificacao�      
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿣erifico o ESTADO do cliente�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴켸
DbSelectarea("SF4")
DbSetorder(1)
If DbSeek(xFilial("SF4") + aCols[nLinha][nPTes] )
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Valida o bloqueio de registro da TES utilizada                  �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿞e a tabela nao for vazia pega o preco de tabela,              �
//쿬aso contrario pega o valor informado no Cadastro do Produto   �
//쿔sso ocorre para manter a compatiblizacao com o SIGAFAT        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If !Empty(M->UA_TABELA)
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿞e for uma tabela de preco valida calcula o valor unitario do item�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿌plica a regra da TABELA DE DESCONTOS no item          �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
nDesc := TkRegraDesc(1,aValores[TOTAL],0,NIL,M->UA_CONDPG,nLinha)
TkP000D(nDesc,nLinha)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿞e houver DESCONTO EM CASCATA ja aplica o valor no item�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If 	(M->UA_DESC4 > 0) .OR. ;
	(M->UA_DESC1 > 0) .OR. ;
	(M->UA_DESC2 > 0) .OR. ;
	(M->UA_DESC3 > 0)
	Tk273DesCab(nLinha,lTudo)
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿞e nao estiver usando a entrada automatica�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If !lTk271Auto 
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿐xecuta o refresh na GetDados para garantir que todas as informacoes estejam visiveis para o Operador�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	oGetTlv:oBrowse:Refresh(.T.)
Endif

Return(lRet)

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o    � TKP000B  � Autor � Marcelo Kotaki        � Data � 18/01/02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Atualiza o valor do item de acordo com quantidade- UB_QUANT낢�
굇�          � o valor do item vai considerar somente os DESCONTOS de:    낢�
굇�          � - CABECALHO                                                낢�
굇�          � - ITEM                                                     낢�
굇�          � O ACRESCIMO sera sempre atualizado com 0                   낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � TeleVendas                                                 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿌nalista  � Data/Bops/Ver 쿘anutencao Efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿘arcelo K �22/09/04�710   �-BOPS 74442                           	  낢�
굇쿎onrado Q.�04/12/06�811   � BOPS 111439 - Adicionado par�metro .T. na  낢�
굇�          �        �      쿬hamada da fun豫o MaTabPrVen que atualiza	  낢�
굇�          �        �      쿘V_ESTADO.                               	  낢�
굇읕컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
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
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿞e for uma tabela de pre�o valida calcula o valor unitario do item    �
	//쿢tilizada a funcao de materiais para  calculo da faixa.               �                                                                           �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿩era os DESCONTOS 			  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
aCols[nLinha][nPDesc] 	 := 0 
aCols[nLinha][nPValDesc] := 0 

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿩era os ACRESCIMOS 			  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
aCols[nLinha][nPAcre] 	 := 0 
aCols[nLinha][nPValAcre] := 0 

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿌plica a regra da TABELA DE DESCONTOS                  �
//컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
nDesc := TkRegraDesc(1,aValores[TOTAL],0,NIL,M->UA_CONDPG,nLinha)
lRet  := TkP000D(nDesc,nLinha)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿞e houver DESCONTO EM CASCATA ja aplica o valor no item�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If (M->UA_DESC4 > 0) .OR. (M->UA_DESC1 > 0) .OR. (M->UA_DESC2 > 0) .OR. (M->UA_DESC3 > 0) .OR. (ReadVar() == "M->UB_QUANT")
	Tk273DesCab(nLinha,.F.)
Endif

Return(lRet)

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o    � TKP000C  � Autor � Marcelo Kotaki        � Data � 18/01/02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Calcula o valor do item quando o unitario for atualizado   낢�
굇�			 � UB_VRUNIT                                                  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � TELEVENDAS                                                 낢�
굇쳐컴컴컴컴컵컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿘arcelo K �11/06/02�710   �-Revisao do fonte                     	  낢�
굇쿓enry F   �26/10/05�811   �-Bops 88060 - Implementacao do ponto de en- 낢�
굇�          �        �      퀃rada TK27300C                              낢�
굇읕컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
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


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿣erifica a existencia do ponto de entrada de validacao do preco�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If lTk27300C
	lRet := U_TK27300C()
	If ValType(lRet) <> "L"
		lRet := .F.
	Endif	
Endif	

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿎aso seja verdadeira executa os processos de validacao. A        �
//퀆ariavel lRet e sempre inicializada com .T. para caso nao exista �
//쿽 ponto de entrada, o processo seja realizado normalmente        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o    � TkP000D  � Autor � Marcelo Kotaki   		� Data � 18/01/02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Validacao do desconto (%) do item campo - UB_DESC          낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � TELEVENDAS                                                 낢�
굇쳐컴컴컴컴컵컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿘arcelo K �11/06/02�710   �-Revisao do fonte                     	  낢�
굇쿎onrado Q.�15/01/07�811   �-BOPS 116486: Zera os valores existentes no 낢�
굇�          �        �      쿪crescimo.                                  낢�
굇읕컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿞e a TES utilizada for igual a TES de bonificacao nao calcula os acrescimos e descontos�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If (cTes == cTesBonus)
	Return(lRet)
Endif	

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿞o pode dar desconto se o Posto de venda estiver configurado para Item ou Ambos						�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If Alltrim(cDesconto) == "2" .OR. Alltrim(cDesconto) == "4"   // Desconto = Total ou Desconto = Nao
	If nValor > 0 
		If  !lTk271Auto 
			Help( " ", 1, "NAO_DESCON")
		Endif	
		aCols[nLinha][nPDesc] := 0
		Return(lRet)
	Endif
Endif


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿚 valor de deconto (%) nao pode ser maior ou igual a 100%  			  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If nValor >= 100
	Help( " ", 1, "DESCMAIOR2" )
	aCols[nLinha][nPDesc] := 0
	Return(lRet)
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
//쿑az os calculos de desconto baseando-se no preco de tabela  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
If aCols[nLinha][nPPrcTab] > 0
	nVlrTab := aCols[nLinha][nPPrcTab]
Else
	nVlrTab := aCols[nLinha][nPVrUnit]
Endif

aCols[nLinha][nPDesc]:= nValor
nValUni 			 := A410Arred(nVlrTab * (1-(nValor/100)),"UB_VRUNIT")

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿞e o posto de venda do operador estiver com preco fiscal bruto = NAO  �
//쿽 valor unitario do produto sera recalculado com desconto 		     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿕ogo o desconto desse item no TOTAL pois o valor do unitario nao sera recalculado�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	If cPrcFiscal == "1"  // Se for PRECO FISCAL BRUTO igual a SIM
		aValores[DESCONTO]:= 0
		If !aCols[nLinha][Len(aHeader)+1]		// Se a linha for valida
			aValores[DESCONTO] += aCols[nLinha][nPValDesc]
		Endif	
		Tk273Refresh(aValores)
	Endif
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿚 desconto nao pode ser maior que o valor de Tabela		 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If aCols[nLinha][nPValDesc] >= (aCols[nLinha][nPPrcTab]*aCols[nLinha][nPQtd]) .AND. nValor > 0
	Help(" ", 1, "DESCMAIOR2" )
	aCols[nLinha][nPDesc]   := 0
	aCols[nLinha][nPValDesc]:= 0
	Return(lRet)
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿞e houver DESCONTO EM CASCATA considera com o valor de desconto atual �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If 	(M->UA_DESC4 > 0) .OR. ;
	(M->UA_DESC1 > 0) .OR. ;
	(M->UA_DESC2 > 0) .OR. ;
	(M->UA_DESC3 > 0)
	Tk273DesCLi(nLinha,1)	// Percentual
Endif
lRet:=.T.

Return(lRet)

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o    � TkP000E  � Autor � Luis Marcelo Kotaki   � Data � 20/09/00 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Validacao do desconto (R$) do item campo - UB_VALDESC      낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � TELEVENDAS                                                 낢�
굇쳐컴컴컴컴컵컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿘arcelo K �11/06/02�710   �-Revisao do fonte                     	  낢�
굇쿘arcelo K �03/04/06�710   �-Bops:95512 revisao do calculo do preco de  낢�
굇�          �        �      퀃abela quando o usuario lancar o valor desc.낢�
굇쿎onrado Q.�15/01/07�811   �-BOPS 116486: Zera os valores existentes no 낢�
굇�          �        �      쿪crescimo.                                  낢�
굇�          �        �      �                                            낢�
굇읕컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿞e a TES utilizada for igual a TES de bonificacao nao calcula os acrescimos e descontos�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If (cTes == cTesBonus)
	Return(lRet)
Endif	

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿞o pode dar desconto se o Posto de venda estiver      	�
//쿬onfigurado para Item ou Ambos					    	�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If Alltrim(cDesconto) == "2" .OR. Alltrim(cDesconto) == "4"   // Item ou Total
	If nValor > 0 
		If  !lTk271Auto 
			Help( " ", 1, "NAO_DESCON")
		Endif	
		aCols[nLinha][nPValDesc] := 0
		Return(lRet)
	Endif	
Endif

//旼컴컴컴컴컴컴컴컴컴커
//쿩ero o desconto em %�
//읕컴컴컴컴컴컴컴컴컴켸
aCols[nLinha][nPDesc]    := 0
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿎arrego novamente o valor de desconto calculado		    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
aCols[nLinha][nPValDesc] := nValor

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿚 Valor do desconto nao pode ser maior que o vlr. do item�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If nValor >= aCols[nLinha][nPVlrItem]
	Help( " ", 1, "DESCMAIOR2" )
	aCols[nLinha][nPValDesc] := 0
	aCols[nLinha][nPDesc]    := 0
	aCols[nLinha][nPValDesc] := 0
	Return(lRet)
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
//쿑az os calculos de desconto baseando-se no preco de tabela  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
If aCols[nLinha][nPPrcTab] > 0
	nVlrTab := aCols[nLinha][nPPrcTab]
Else
	nVlrTab := aCols[nLinha][nPVrUnit]
Endif                                       

nValItem:= (nVlrTab * aCols[nLinha][nPQtd])
nValUni := 0
nAuxDesc := A410Arred(nValor/aCols[nLinha][nPQtd],"D2_PRCVEN")
nValUni  := A410Arred(nVlrTab - nAuxDesc,"D2_PRCVEN")

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿞e houver DESCONTO EM CASCATA ja aplica o valor no item�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If (M->UA_DESC4 > 0) .OR. (M->UA_DESC1 > 0) .OR. (M->UA_DESC2 > 0) .OR. (M->UA_DESC3 > 0)
	Tk273DesCLi(nLinha,2)	// R$
	nValUni := aCols[nLinha][nPVrUnit]
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿞e o posto de venda do operador nao trabalha com  �
//쿾reco fiscal bruto jogo o desconto sobre o valor  �
//퀅nitario do produto                               �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿕ogo o desconto desse item no TOTAL pois o valor do unitario nao sera recalculado�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	If cPrcFiscal == "1"  // Se for PRECO FISCAL BRUTO igual a SIM
		aValores[DESCONTO]:= 0
		If !aCols[nLinha][Len(aHeader)+1]		// Se a linha for valida
			aValores[DESCONTO] += aCols[nLinha][nPValDesc]
		Endif	
	Endif
	Tk273Refresh(aValores)
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿎alcula a porcentagem do desconto�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
aCols[nLinha][nPDesc] := A410Arred((nValor / nValItem)*100,"UB_DESC")

lRet := .T.

Return(lRet)

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o    � TKP000G  � Autor � Marcelo Kotaki        � Data � 18/01/02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Calcula o Valor do item de acordo com o acrescimo - UB_ACRE낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � TeleVendas                                                 낢�
굇쳐컴컴컴컴컵컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿘arcelo K �11/06/02�710   �-Revisao do fonte                     	  낢�
굇쿎onrado Q.�15/01/07�811   �-BOPS 116486: Na hora de calcular o acr�sci 낢�
굇�          �        �      쿺o, leva em considera豫o os descontos j�    낢�
굇�          �        �      쿮xistentes.                                 낢�
굇읕컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿞e a TES utilizada for igual a TES de bonificacao nao calcula os acrescimos e descontos�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If (cTes == cTesBonus)
	Return(lRet)
Endif	

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿞e o posto de venda nao recalcula o unitario nao pode dar acrescimo�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
//쿑az os calculos de desconto baseando-se no Preco de Tabela  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
If aCols[nLinha][nPPrcTab] > 0
	nVlrTab := aCols[nLinha][nPPrcTab]
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿌plica descontos existentes, tanto do cabe�alho quando do�
	//쿶tem.                                                    �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	nVlrTab := nVlrTab - ( aCols[nLinha][nPValDesc] / aCols[nLinha][nPQtd] )
	nVlrTab := nVlrTab - If(M->UA_DESC1 > 0, ( nVlrTab * M->UA_DESC1 ) / 100, 0)
	nVlrTab := nVlrTab - If(M->UA_DESC2 > 0, ( nVlrTab * M->UA_DESC2 ) / 100, 0)
	nVlrTab := nVlrTab - If(M->UA_DESC3 > 0, ( nVlrTab * M->UA_DESC3 ) / 100, 0)
	nVlrTab := nVlrTab - If(M->UA_DESC4 > 0, ( nVlrTab * M->UA_DESC4 ) / 100, 0)	
Else
	nVlrTab := aCols[nLinha][nPVrUnit]
Endif

nValUni	:= A410Arred(nVlrTab * (100 + nValor) / 100,"UB_VRUNIT")

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿚 Acrescimo sempre recalcula  o valor do unitario porque se o for jogado no total (ACRESCIMO RODAPE)      �
//쿻o momento de gerar o SC6 ser� gerado uma DIZIMA PERIODICA consequentemente n꼘 vai bater o valor liquido �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
aCols[nLinha][nPVrUnit] := nValUni
aCols[nLinha][nPValAcre]:= A410Arred(((nVlrTab * aCols[nLinha][nPAcre]) / 100) * aCols[nLinha][nPQtd],"UB_VALACRE")
aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VLRITEM")

lRet := .T.

Return(lRet)

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o    � TKP000H  � Autor � Marcelo Kotaki        � Data � 18/01/02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Calcula o Acrescimo do Item em valores -  UB_VALACRE       낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � TeleVendas                                                 낢�
굇쳐컴컴컴컴컵컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿘arcelo K.�11/06/02�7.10  �-Revisao do fonte                     	  낢�
굇쿘arcelo K.�08/04/03�7.10  �-Bops: 63849 Usar o valor de tabela do item 낢�
굇�          �        �      쿾ara calcular o % do acrescimo              낢�
굇쿘arcelo K.�27/04/06�7.10  �-Bops: 97012 - Ajustado o calculo do valor  낢�
굇�          �        �      퀅nitario de acrescimo para nao considerar   낢�
굇�          �        �      쿽 valor total de desconto.                  낢�
굇쿎onrado Q.�15/01/07�811   �-BOPS 116486: Na hora de calcular o acr�sci 낢�
굇�          �        �      쿺o, leva em considera豫o os descontos j�    낢�
굇�          �        �      쿮xistentes.                                 낢�
굇읕컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿞e a TES utilizada for igual a TES de bonificacao nao calcula os acrescimos e descontos�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If (cTes == cTesBonus)
	Return(lRet)
Endif	

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿞e o posto de venda nao recalcula o unitario nao pode dar acrescimo�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
//쿑az os calculos de desconto baseando-se no preco de tabela  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
If aCols[nLinha][nPPrcTab] > 0
	nVlrTab := aCols[nLinha][nPPrcTab]
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿌plica descontos existentes, tanto do cabe�alho quando do�
	//쿶tem.                                                    �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	nVlrTab := nVlrTab - ( aCols[nLinha][nPValDesc] / aCols[nLinha][nPQtd] )
	nVlrTab := nVlrTab - If(M->UA_DESC1 > 0, ( nVlrTab * M->UA_DESC1 ) / 100, 0)
	nVlrTab := nVlrTab - If(M->UA_DESC2 > 0, ( nVlrTab * M->UA_DESC2 ) / 100, 0)
	nVlrTab := nVlrTab - If(M->UA_DESC3 > 0, ( nVlrTab * M->UA_DESC3 ) / 100, 0)
	nVlrTab := nVlrTab - If(M->UA_DESC4 > 0, ( nVlrTab * M->UA_DESC4 ) / 100, 0)

Else
	nVlrTab := aCols[nLinha][nPVrUnit]
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿎alcula o % em funcao do acrescimo informado �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
aCols[nLinha][nPValAcre] := nValor
nValor 					 := A410Arred(nValor / aCols[nLinha][nPQtd],"UB_VALACRE")
nValor 					 := A410Arred((nValor / nVlrTab) * 100,"UB_ACRE")

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿚 valor de acrescimo n꼘 pode passar de 100 % se o campo UB_ACRE estiver com tamanho 5 decimal 2 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If TamSX3("UB_ACRE")[1] <= 5
	If nValor >= 100
		MsgStop("O Valor de Acr�scimo n�o pode ser maior que 100%") //
		nValor := 0                  
		aCols[nLinha][nPValAcre] := 0
		Return(lRet)
	Endif
Endif

aCols[nLinha][nPAcre]:= nValor

nValUni := A410Arred(nVlrTab * (100 + nValor) / 100,"UB_VRUNIT")

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿚 Acrescimo sempre recalcula  o valor do unitario porque se o for jogado no total (ACRESCIMO RODAPE)      �
//쿻o momento de gerar o SC6 ser� gerado uma DIZIMA PERIODICA consequentemente n꼘 vai bater o valor liquido �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
aCols[nLinha][nPVrUnit] := nValUni
aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VLRITEM")

Tk273Trigger("UB_VLRITEM",nLinha)

lRet := .T.

Return(lRet)

