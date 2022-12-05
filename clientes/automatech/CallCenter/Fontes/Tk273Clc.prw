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

//�������������������������������Ŀ
//�Verifica se existe os produtos.�
//���������������������������������
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
		//���������������������������������������������������������������������������������������Ŀ
		//�Se a TES utilizada e diferente da TES de bonificacao calcula os acrescimos e descontos �
		//�����������������������������������������������������������������������������������������
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

//��������������������������������������������������������������������������������������������������������������Ŀ
//�Recalcula o item para garantir os impostos de acordo com a quantidade informada se houver desconto da SUFRAMA �
//����������������������������������������������������������������������������������������������������������������
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
	
//���������������������������������������������������������������������������������������Ŀ
//�Verifica se esse TES gera titulos para nao obrigar a selecao das condicoes de pagamento�
//�����������������������������������������������������������������������������������������
DbSelectArea("SF4")
DbSetOrder(1)
If DbSeek(xFilial("SF4")+aCols[nLinha][nPTes])
	If SF4->F4_DUPLIC == "S"
	
		//�������������������������������������������������������������������������������
		//�Se a TES nao estiver bloqueada valida se a quantidade pode ser igual a 0,00  �
		//�������������������������������������������������������������������������������
		If MaTesSel(aCols[nLinha][nPTes])
			lTesTit := .F.				
		Else
			lTesTit := .T.	
		Endif
	Else
		lTesTit := .F.
	Endif
Endif

//����������������������������������������������������
//�Verifica se existe o KIT no cadastro de acessorios�
//����������������������������������������������������
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
			
			//�������������������������������������Ŀ
			//�Pega o conteudo o ultimo item (Valor)�
			//���������������������������������������
			cItem 	:= aCols[Len(aCols)][nPItem]
			nAtual  := 0
			nAtual	:= LEN(aCols)
			
			For nCont := 1 TO Len(aListaKit)
				AADD(aCols,Array(len(aHeader)+1))
				nAtual ++
				
				//�������������Ŀ
				//�X3_TITULO   1�
				//�X3_CAMPO    2�
				//�X3_PICTURE  3�
				//�X3_TAMANHO  4�
				//�X3_DECIMAL  5�
				//�X3_VALID    6�
				//�X3_USADO    7�
				//�X3_TIPO     8�
				//�X3_ARQUIVO  9�
				//�X3_CONTEXT 10�
				//���������������
				//�����������������������������������������������������Ŀ
				//�Inicializa as variaveis da aCols (tratamento para    �
				//�campos criados pelo usu�rio)							�
				//�������������������������������������������������������
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
				
				//���������������������������������������������������������������������������������������������������Ŀ
				//�Atualiza o aCols com o acessorio, atualizado o item o produto e a quantidade alem da funcao fiscal �
				//�����������������������������������������������������������������������������������������������������
				cItem 			 	  := Soma1(cItem,Len(cItem))
				aCols[nAtual][nPItem] := cItem
				
				M->UB_PRODUTO	 	  := aListaKit[nCont][1]
				aCols[nAtual][nPProd] := aListaKit[nCont][1]
				
				MaColsToFis(aHeader,aCols,nAtual,"TK273",.F.)
				TKP000A(M->UB_PRODUTO,nAtual,NIL)
				//�������������������������������������������������������������������Ŀ
				//�Atualiza o acols com as quantidades e recalcula os valores do item.�
				//���������������������������������������������������������������������
				M->UB_QUANT  		 := aListaKit[nCont][2]
				aCols[nAtual][nPQtd] := aListaKit[nCont][2]
				TKP000B(M->UB_QUANT,nAtual)
				
			Next nCont
			n := nAtual
			M->UB_PRODUTO := nValor // Inicializa a variavel de memoria com o item pai

			//������������������������������������������Ŀ
			//�Se nao estiver usando a entrada automatica�
			//��������������������������������������������
			If !lTk271Auto 
				oGetTlv:oBrowse:Refresh()
			Endif	
		Endif
	Endif
Endif

Return(lRet)

/*                                                    
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TKP000A  � Autor � Marcelo Kotaki        � Data � 18/01/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza o preco de acordo com o produto -   UB_PRODUTO    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TeleVendas                                                 ���
�������������������������������������������������������������������������Ĵ��
���Marcelo K �11/06/02�710   �-Revisao do fonte                     	  ���
���Marcelo K �17/06/02�710   �-Inclusao da opcao KIT - SU1/Acessorios	  ���
���Andrea F. �07/04/05�811   � BOPS 80762- Sempre gatilhar a TES quando o ���
���          �        �      �codigo do produto for digitado ou via F3.	  ���
���Henry F   �26/08/05�811   � BOPS 85138- Ajustado o reacalculo das fun  ���
���          �        �      �coes fiscais quando alterado o produto  	  ���
���Henry F   �22/11/05�811   � BOPS 88191- Ajustado do gatilho da Tes     ���
���          �        �      �quando o produto for de bonificacao     	  ���
���Henry F   �13/11/05�811   � BOPS 89371- Inclusao da funcao existcpo    ���
���          �        �      �para realizar o tratamento do B1_MSBLQL 	  ���
���Marcelo K �20/02/06�811   �-Bops 93313/ 92811 - Correcao do refresh da ���
���          �        �      �descricao do produto na escolha do produto  ���
���          �        �      �por digitacao.                              ���
���          �        �      �- PMC: Sintaxe simplificada no IIF          ���
���          �        �      �- PMC: Uso de SuperGetMv ao inves de GETMV  ���
���Marcelo K �04/07/06�8,11  �-Bops 95955 - Validacao do bloqueio de 	  ���
���          �        �      �registro do cadastro de entrada/saida TES   ���
���Fernando  �25/10/06�8.11  �-BOPS104016 - na validacao do bloqueio a TES���
���          �        �      �retorna vazio.                              ���
���Conrado Q.�04/12/06�811   � BOPS 111439 - Adicionado par�metro .T. na  ���
���          �        �      �chamada da fun��o MaTabPrVen que atualiza	  ���
���          �        �      �MV_ESTADO.                               	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

//�����������������������������������������������������������������Ŀ
//� Funcao utilizada para verificar a ultima versao dos fontes      �
//� SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        �
//�������������������������������������������������������������������
If !(FindFunction("SIGACUS_V") .AND. SIGACUS_V() >= 20050512)
    Final("Por favor, contacte o Administrador do Sistema - Ser� necess�rio atualizar os programas SIGACUS*.*")
Endif

//����������������������������������������������������������������������������������������Ŀ
//�Posiciona no produto digitado ou escolhido para ter certeza que esta no registro correto�
//������������������������������������������������������������������������������������������
DbSelectarea("SB1")
DbSetorder(1)      
If !DbSeek( xFilial("SB1") + nValor)
	Help(" ",1,"A010VAZ")
	Return(lRet)
Endif

//�����������������������������������������������������������������Ŀ
//� Valida o bloqueio de registro do Produto escolhido              �
//� tratamento do  campo de bloqueio B1_MSBLQL                      |
//�������������������������������������������������������������������
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

//��������������������������������������������������������������������������������������������������������������������Ŀ
//�Sempre gatilha a TES quando for digitado o codigo do produto e somente nao gatilha quando a linha for de bonificacao�      
//����������������������������������������������������������������������������������������������������������������������
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

//����������������������������Ŀ
//�Verifico o ESTADO do cliente�
//������������������������������
DbSelectarea("SF4")
DbSetorder(1)
If DbSeek(xFilial("SF4") + aCols[nLinha][nPTes] )
	
	//�����������������������������������������������������������������Ŀ
	//� Valida o bloqueio de registro da TES utilizada                  �
	//�������������������������������������������������������������������
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

//�����������������������������������������������������������������
//�Se a tabela nao for vazia pega o preco de tabela,              �
//�caso contrario pega o valor informado no Cadastro do Produto   �
//�Isso ocorre para manter a compatiblizacao com o SIGAFAT        �
//�����������������������������������������������������������������
If !Empty(M->UA_TABELA)
	//������������������������������������������������������������������Ŀ
	//�Se for uma tabela de preco valida calcula o valor unitario do item�
	//��������������������������������������������������������������������
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

//�������������������������������������������������������Ŀ
//�Aplica a regra da TABELA DE DESCONTOS no item          �
//���������������������������������������������������������
nDesc := TkRegraDesc(1,aValores[TOTAL],0,NIL,M->UA_CONDPG,nLinha)
TkP000D(nDesc,nLinha)

//�������������������������������������������������������Ŀ
//�Se houver DESCONTO EM CASCATA ja aplica o valor no item�
//���������������������������������������������������������
If 	(M->UA_DESC4 > 0) .OR. ;
	(M->UA_DESC1 > 0) .OR. ;
	(M->UA_DESC2 > 0) .OR. ;
	(M->UA_DESC3 > 0)
	Tk273DesCab(nLinha,lTudo)
Endif

//������������������������������������������Ŀ
//�Se nao estiver usando a entrada automatica�
//��������������������������������������������
If !lTk271Auto 
	//�����������������������������������������������������������������������������������������������������Ŀ
	//�Executa o refresh na GetDados para garantir que todas as informacoes estejam visiveis para o Operador�
	//�������������������������������������������������������������������������������������������������������
	oGetTlv:oBrowse:Refresh(.T.)
Endif

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TKP000B  � Autor � Marcelo Kotaki        � Data � 18/01/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza o valor do item de acordo com quantidade- UB_QUANT���
���          � o valor do item vai considerar somente os DESCONTOS de:    ���
���          � - CABECALHO                                                ���
���          � - ITEM                                                     ���
���          � O ACRESCIMO sera sempre atualizado com 0                   ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TeleVendas                                                 ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���Marcelo K �22/09/04�710   �-BOPS 74442                           	  ���
���Conrado Q.�04/12/06�811   � BOPS 111439 - Adicionado par�metro .T. na  ���
���          �        �      �chamada da fun��o MaTabPrVen que atualiza	  ���
���          �        �      �MV_ESTADO.                               	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
	//����������������������������������������������������������������������Ŀ
	//�Se for uma tabela de pre�o valida calcula o valor unitario do item    �
	//�Utilizada a funcao de materiais para  calculo da faixa.               �                                                                           �
	//������������������������������������������������������������������������
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

//�������������������������������Ŀ
//�Zera os DESCONTOS 			  �
//���������������������������������
aCols[nLinha][nPDesc] 	 := 0 
aCols[nLinha][nPValDesc] := 0 

//�������������������������������Ŀ
//�Zera os ACRESCIMOS 			  �
//���������������������������������
aCols[nLinha][nPAcre] 	 := 0 
aCols[nLinha][nPValAcre] := 0 

//�������������������������������������������������������Ŀ
//�Aplica a regra da TABELA DE DESCONTOS                  �
//���������������������������������������������������������
nDesc := TkRegraDesc(1,aValores[TOTAL],0,NIL,M->UA_CONDPG,nLinha)
lRet  := TkP000D(nDesc,nLinha)

//�������������������������������������������������������Ŀ
//�Se houver DESCONTO EM CASCATA ja aplica o valor no item�
//���������������������������������������������������������
If (M->UA_DESC4 > 0) .OR. (M->UA_DESC1 > 0) .OR. (M->UA_DESC2 > 0) .OR. (M->UA_DESC3 > 0) .OR. (ReadVar() == "M->UB_QUANT")
	Tk273DesCab(nLinha,.F.)
Endif

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TKP000C  � Autor � Marcelo Kotaki        � Data � 18/01/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula o valor do item quando o unitario for atualizado   ���
���			 � UB_VRUNIT                                                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TELEVENDAS                                                 ���
�������������������������������������������������������������������������Ĵ��
���Marcelo K �11/06/02�710   �-Revisao do fonte                     	  ���
���Henry F   �26/10/05�811   �-Bops 88060 - Implementacao do ponto de en- ���
���          �        �      �trada TK27300C                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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


//���������������������������������������������������������������Ŀ
//�Verifica a existencia do ponto de entrada de validacao do preco�
//�����������������������������������������������������������������
If lTk27300C
	lRet := U_TK27300C()
	If ValType(lRet) <> "L"
		lRet := .F.
	Endif	
Endif	

//�����������������������������������������������������������������Ŀ
//�Caso seja verdadeira executa os processos de validacao. A        �
//�variavel lRet e sempre inicializada com .T. para caso nao exista �
//�o ponto de entrada, o processo seja realizado normalmente        �
//�������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TkP000D  � Autor � Marcelo Kotaki   		� Data � 18/01/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao do desconto (%) do item campo - UB_DESC          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TELEVENDAS                                                 ���
�������������������������������������������������������������������������Ĵ��
���Marcelo K �11/06/02�710   �-Revisao do fonte                     	  ���
���Conrado Q.�15/01/07�811   �-BOPS 116486: Zera os valores existentes no ���
���          �        �      �acrescimo.                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

//���������������������������������������������������������������������������������������Ŀ
//�Se a TES utilizada for igual a TES de bonificacao nao calcula os acrescimos e descontos�
//�����������������������������������������������������������������������������������������
If (cTes == cTesBonus)
	Return(lRet)
Endif	

//�����������������������������������������������������������������������������������������������������Ŀ
//�So pode dar desconto se o Posto de venda estiver configurado para Item ou Ambos						�
//�������������������������������������������������������������������������������������������������������
If Alltrim(cDesconto) == "2" .OR. Alltrim(cDesconto) == "4"   // Desconto = Total ou Desconto = Nao
	If nValor > 0 
		If  !lTk271Auto 
			Help( " ", 1, "NAO_DESCON")
		Endif	
		aCols[nLinha][nPDesc] := 0
		Return(lRet)
	Endif
Endif


//�����������������������������������������������������������������������Ŀ
//�O valor de deconto (%) nao pode ser maior ou igual a 100%  			  �
//�������������������������������������������������������������������������
If nValor >= 100
	Help( " ", 1, "DESCMAIOR2" )
	aCols[nLinha][nPDesc] := 0
	Return(lRet)
Endif

//��������������������������������������������������������������
//�Faz os calculos de desconto baseando-se no preco de tabela  �
//��������������������������������������������������������������
If aCols[nLinha][nPPrcTab] > 0
	nVlrTab := aCols[nLinha][nPPrcTab]
Else
	nVlrTab := aCols[nLinha][nPVrUnit]
Endif

aCols[nLinha][nPDesc]:= nValor
nValUni 			 := A410Arred(nVlrTab * (1-(nValor/100)),"UB_VRUNIT")

//����������������������������������������������������������������������Ŀ
//�Se o posto de venda do operador estiver com preco fiscal bruto = NAO  �
//�o valor unitario do produto sera recalculado com desconto 		     �
//������������������������������������������������������������������������
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
	
	//���������������������������������������������������������������������������������Ŀ
	//�Jogo o desconto desse item no TOTAL pois o valor do unitario nao sera recalculado�
	//�����������������������������������������������������������������������������������
	If cPrcFiscal == "1"  // Se for PRECO FISCAL BRUTO igual a SIM
		aValores[DESCONTO]:= 0
		If !aCols[nLinha][Len(aHeader)+1]		// Se a linha for valida
			aValores[DESCONTO] += aCols[nLinha][nPValDesc]
		Endif	
		Tk273Refresh(aValores)
	Endif
Endif

//����������������������������������������������������������Ŀ
//�O desconto nao pode ser maior que o valor de Tabela		 �
//������������������������������������������������������������
If aCols[nLinha][nPValDesc] >= (aCols[nLinha][nPPrcTab]*aCols[nLinha][nPQtd]) .AND. nValor > 0
	Help(" ", 1, "DESCMAIOR2" )
	aCols[nLinha][nPDesc]   := 0
	aCols[nLinha][nPValDesc]:= 0
	Return(lRet)
Endif

//����������������������������������������������������������������������Ŀ
//�Se houver DESCONTO EM CASCATA considera com o valor de desconto atual �
//������������������������������������������������������������������������
If 	(M->UA_DESC4 > 0) .OR. ;
	(M->UA_DESC1 > 0) .OR. ;
	(M->UA_DESC2 > 0) .OR. ;
	(M->UA_DESC3 > 0)
	Tk273DesCLi(nLinha,1)	// Percentual
Endif
lRet:=.T.

Return(lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TkP000E  � Autor � Luis Marcelo Kotaki   � Data � 20/09/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao do desconto (R$) do item campo - UB_VALDESC      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TELEVENDAS                                                 ���
�������������������������������������������������������������������������Ĵ��
���Marcelo K �11/06/02�710   �-Revisao do fonte                     	  ���
���Marcelo K �03/04/06�710   �-Bops:95512 revisao do calculo do preco de  ���
���          �        �      �tabela quando o usuario lancar o valor desc.���
���Conrado Q.�15/01/07�811   �-BOPS 116486: Zera os valores existentes no ���
���          �        �      �acrescimo.                                  ���
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

//���������������������������������������������������������������������������������������Ŀ
//�Se a TES utilizada for igual a TES de bonificacao nao calcula os acrescimos e descontos�
//�����������������������������������������������������������������������������������������
If (cTes == cTesBonus)
	Return(lRet)
Endif	

//���������������������������������������������������������Ŀ
//�So pode dar desconto se o Posto de venda estiver      	�
//�configurado para Item ou Ambos					    	�
//�����������������������������������������������������������
If Alltrim(cDesconto) == "2" .OR. Alltrim(cDesconto) == "4"   // Item ou Total
	If nValor > 0 
		If  !lTk271Auto 
			Help( " ", 1, "NAO_DESCON")
		Endif	
		aCols[nLinha][nPValDesc] := 0
		Return(lRet)
	Endif	
Endif

//��������������������Ŀ
//�Zero o desconto em %�
//����������������������
aCols[nLinha][nPDesc]    := 0
//���������������������������������������������������������Ŀ
//�Carrego novamente o valor de desconto calculado		    �
//�����������������������������������������������������������
aCols[nLinha][nPValDesc] := nValor

//���������������������������������������������������������Ŀ
//�O Valor do desconto nao pode ser maior que o vlr. do item�
//�����������������������������������������������������������
If nValor >= aCols[nLinha][nPVlrItem]
	Help( " ", 1, "DESCMAIOR2" )
	aCols[nLinha][nPValDesc] := 0
	aCols[nLinha][nPDesc]    := 0
	aCols[nLinha][nPValDesc] := 0
	Return(lRet)
Endif

//��������������������������������������������������������������
//�Faz os calculos de desconto baseando-se no preco de tabela  �
//��������������������������������������������������������������
If aCols[nLinha][nPPrcTab] > 0
	nVlrTab := aCols[nLinha][nPPrcTab]
Else
	nVlrTab := aCols[nLinha][nPVrUnit]
Endif                                       

nValItem:= (nVlrTab * aCols[nLinha][nPQtd])
nValUni := 0
nAuxDesc := A410Arred(nValor/aCols[nLinha][nPQtd],"D2_PRCVEN")
nValUni  := A410Arred(nVlrTab - nAuxDesc,"D2_PRCVEN")

//�������������������������������������������������������Ŀ
//�Se houver DESCONTO EM CASCATA ja aplica o valor no item�
//���������������������������������������������������������
If (M->UA_DESC4 > 0) .OR. (M->UA_DESC1 > 0) .OR. (M->UA_DESC2 > 0) .OR. (M->UA_DESC3 > 0)
	Tk273DesCLi(nLinha,2)	// R$
	nValUni := aCols[nLinha][nPVrUnit]
Endif

//��������������������������������������������������Ŀ
//�Se o posto de venda do operador nao trabalha com  �
//�preco fiscal bruto jogo o desconto sobre o valor  �
//�unitario do produto                               �
//����������������������������������������������������
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
	
	//���������������������������������������������������������������������������������Ŀ
	//�Jogo o desconto desse item no TOTAL pois o valor do unitario nao sera recalculado�
	//�����������������������������������������������������������������������������������
	If cPrcFiscal == "1"  // Se for PRECO FISCAL BRUTO igual a SIM
		aValores[DESCONTO]:= 0
		If !aCols[nLinha][Len(aHeader)+1]		// Se a linha for valida
			aValores[DESCONTO] += aCols[nLinha][nPValDesc]
		Endif	
	Endif
	Tk273Refresh(aValores)
Endif

//���������������������������������Ŀ
//�Calcula a porcentagem do desconto�
//�����������������������������������
aCols[nLinha][nPDesc] := A410Arred((nValor / nValItem)*100,"UB_DESC")

lRet := .T.

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TKP000G  � Autor � Marcelo Kotaki        � Data � 18/01/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula o Valor do item de acordo com o acrescimo - UB_ACRE���
�������������������������������������������������������������������������Ĵ��
���Uso       � TeleVendas                                                 ���
�������������������������������������������������������������������������Ĵ��
���Marcelo K �11/06/02�710   �-Revisao do fonte                     	  ���
���Conrado Q.�15/01/07�811   �-BOPS 116486: Na hora de calcular o acr�sci ���
���          �        �      �mo, leva em considera��o os descontos j�    ���
���          �        �      �existentes.                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

//���������������������������������������������������������������������������������������Ŀ
//�Se a TES utilizada for igual a TES de bonificacao nao calcula os acrescimos e descontos�
//�����������������������������������������������������������������������������������������
If (cTes == cTesBonus)
	Return(lRet)
Endif	

//���������������������������������������������������������������������
//�Se o posto de venda nao recalcula o unitario nao pode dar acrescimo�
//���������������������������������������������������������������������
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

//��������������������������������������������������������������
//�Faz os calculos de desconto baseando-se no Preco de Tabela  �
//��������������������������������������������������������������
If aCols[nLinha][nPPrcTab] > 0
	nVlrTab := aCols[nLinha][nPPrcTab]
	//���������������������������������������������������������Ŀ
	//�Aplica descontos existentes, tanto do cabe�alho quando do�
	//�item.                                                    �
	//�����������������������������������������������������������
	nVlrTab := nVlrTab - ( aCols[nLinha][nPValDesc] / aCols[nLinha][nPQtd] )
	nVlrTab := nVlrTab - If(M->UA_DESC1 > 0, ( nVlrTab * M->UA_DESC1 ) / 100, 0)
	nVlrTab := nVlrTab - If(M->UA_DESC2 > 0, ( nVlrTab * M->UA_DESC2 ) / 100, 0)
	nVlrTab := nVlrTab - If(M->UA_DESC3 > 0, ( nVlrTab * M->UA_DESC3 ) / 100, 0)
	nVlrTab := nVlrTab - If(M->UA_DESC4 > 0, ( nVlrTab * M->UA_DESC4 ) / 100, 0)	
Else
	nVlrTab := aCols[nLinha][nPVrUnit]
Endif

nValUni	:= A410Arred(nVlrTab * (100 + nValor) / 100,"UB_VRUNIT")

//����������������������������������������������������������������������������������������������������������Ŀ
//�O Acrescimo sempre recalcula  o valor do unitario porque se o for jogado no total (ACRESCIMO RODAPE)      �
//�no momento de gerar o SC6 ser� gerado uma DIZIMA PERIODICA consequentemente n�o vai bater o valor liquido �
//������������������������������������������������������������������������������������������������������������
aCols[nLinha][nPVrUnit] := nValUni
aCols[nLinha][nPValAcre]:= A410Arred(((nVlrTab * aCols[nLinha][nPAcre]) / 100) * aCols[nLinha][nPQtd],"UB_VALACRE")
aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VLRITEM")

lRet := .T.

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TKP000H  � Autor � Marcelo Kotaki        � Data � 18/01/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula o Acrescimo do Item em valores -  UB_VALACRE       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TeleVendas                                                 ���
�������������������������������������������������������������������������Ĵ��
���Marcelo K.�11/06/02�7.10  �-Revisao do fonte                     	  ���
���Marcelo K.�08/04/03�7.10  �-Bops: 63849 Usar o valor de tabela do item ���
���          �        �      �para calcular o % do acrescimo              ���
���Marcelo K.�27/04/06�7.10  �-Bops: 97012 - Ajustado o calculo do valor  ���
���          �        �      �unitario de acrescimo para nao considerar   ���
���          �        �      �o valor total de desconto.                  ���
���Conrado Q.�15/01/07�811   �-BOPS 116486: Na hora de calcular o acr�sci ���
���          �        �      �mo, leva em considera��o os descontos j�    ���
���          �        �      �existentes.                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

//���������������������������������������������������������������������������������������Ŀ
//�Se a TES utilizada for igual a TES de bonificacao nao calcula os acrescimos e descontos�
//�����������������������������������������������������������������������������������������
If (cTes == cTesBonus)
	Return(lRet)
Endif	

//���������������������������������������������������������������������
//�Se o posto de venda nao recalcula o unitario nao pode dar acrescimo�
//���������������������������������������������������������������������
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

//��������������������������������������������������������������
//�Faz os calculos de desconto baseando-se no preco de tabela  �
//��������������������������������������������������������������
If aCols[nLinha][nPPrcTab] > 0
	nVlrTab := aCols[nLinha][nPPrcTab]
	//���������������������������������������������������������Ŀ
	//�Aplica descontos existentes, tanto do cabe�alho quando do�
	//�item.                                                    �
	//�����������������������������������������������������������
	nVlrTab := nVlrTab - ( aCols[nLinha][nPValDesc] / aCols[nLinha][nPQtd] )
	nVlrTab := nVlrTab - If(M->UA_DESC1 > 0, ( nVlrTab * M->UA_DESC1 ) / 100, 0)
	nVlrTab := nVlrTab - If(M->UA_DESC2 > 0, ( nVlrTab * M->UA_DESC2 ) / 100, 0)
	nVlrTab := nVlrTab - If(M->UA_DESC3 > 0, ( nVlrTab * M->UA_DESC3 ) / 100, 0)
	nVlrTab := nVlrTab - If(M->UA_DESC4 > 0, ( nVlrTab * M->UA_DESC4 ) / 100, 0)

Else
	nVlrTab := aCols[nLinha][nPVrUnit]
Endif

//���������������������������������������������Ŀ
//�Calcula o % em funcao do acrescimo informado �
//�����������������������������������������������
aCols[nLinha][nPValAcre] := nValor
nValor 					 := A410Arred(nValor / aCols[nLinha][nPQtd],"UB_VALACRE")
nValor 					 := A410Arred((nValor / nVlrTab) * 100,"UB_ACRE")

//�������������������������������������������������������������������������������������������������Ŀ
//�O valor de acrescimo n�o pode passar de 100 % se o campo UB_ACRE estiver com tamanho 5 decimal 2 �
//���������������������������������������������������������������������������������������������������
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

//����������������������������������������������������������������������������������������������������������Ŀ
//�O Acrescimo sempre recalcula  o valor do unitario porque se o for jogado no total (ACRESCIMO RODAPE)      �
//�no momento de gerar o SC6 ser� gerado uma DIZIMA PERIODICA consequentemente n�o vai bater o valor liquido �
//������������������������������������������������������������������������������������������������������������
aCols[nLinha][nPVrUnit] := nValUni
aCols[nLinha][nPVlrItem]:= A410Arred(aCols[nLinha][nPQtd]*aCols[nLinha][nPVrUnit],"UB_VLRITEM")

Tk273Trigger("UB_VLRITEM",nLinha)

lRet := .T.

Return(lRet)

