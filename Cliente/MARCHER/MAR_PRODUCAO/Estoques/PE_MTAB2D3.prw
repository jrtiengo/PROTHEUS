#INCLUDE "rwmake.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MTAB2D3()   ³ Autor ³Marcio Q.Borges      ³ Data ³ 13/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gravacao do arquivos de pedido de vendas                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                   					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                                                                       ³±±
±±³                                                                       ³±±
±±³                                                                       ³±±
±±³                                                                       ³±±
±±³                                                                       ³±±
±±³                                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*/
MTAB2D1 ( [ ExpC1 ] , [ ExpC2 ] , [ ExpC3 ] ) --> Nil
Parâmetros
Argumento	Tipo	Descrição
ExpC1 	Caracter	Codigo do Produto (D3_COD)
ExpC2 	Caracter	Local
ExpC3 	Caracter	Expressão numerica indicando se a movimentação soma ou subtrai :1 = Operacao de Entrada-1 = Operacao de Saida
Retorno
Tipo	Descrição
(NULO)	Nil
Descrição
Este Ponto de Entrada está localizado na função B2AtuComD1 (Atualiza os dados do SB2  baseado no SD3);
	É executado ANTES da gravação do SB2, pois,  seu objetivo é que o usuario possa manipular os dados do SB2, antes da atualização feita pelo sistema.
Exemplo do Ponto de Entrada :
Exemplo do Ponto de Entrada :

User Function MTAB2D3()

	Local cCodPro    := ParamIXB[1]  //-- Codigo do Produto
	Local cLocal        := ParamIXB[2]  //-- Local
	Local nMultiplic   := ParamIXB[3]  //-- 1 - Operacao de Entrada/ -1 Operacao de Saida

	dbSelectArea('SB2')
	dbSetOrder(1)

//-- Se o produto nao existir no SB2, sera criado automaticamente
	If !MsSeek(xFilial('SB2')+cCodPro+cLocal, .F.)
		CriaSB2(cCodPro,cLocal)
	EndIf
	RecLock('SB2',.F.)
//--
//--Atualizacao dos campos do SB2 conforme necessidade do usuario. Exemplo:
	REPLACE B2_QATU WITH B2_QATU + (SD3->D3_QUANT*nMultiplic)
//--
	MsUnLock()

Return .T.


*/

User Function MTAB2D3()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	Local cCodPro    	:= ParamIXB[1]  //-- Codigo do Produto
	Local cLocal        := ParamIXB[2]  //-- Local
	//Local nMultiplic   	:= ParamIXB[3]  //-- 1 - Operacao de Entrada/ -1 Operacao de Saida
	Local nQtdAtu
	Local nValAtu

	Local cAlias		:= Alias()
	Local nRecnoD3
	Local nOrdemD3
	Local nRecnoB2
	Local nOrdemB2

	Local lLock




	nRecnoD3 := SD3->(RECNO())
	nOrdemD3 := SD3->(IndexOrd())
	nRecnoB2 := SB2->(RECNO())
	nOrdemB2 := SB2->(IndexOrd())


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no local a ser atualizado                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SB2")
	dbSetOrder(1)
	If ( !MsSeek(cFilial+cCodPro+cLocal) )
		CriaSB2(cCodPro,cLocal)
	EndIf

	nQtdAtu		:= SB2->B2_QATU  // Quantidade atual do estoque
	nValAtu		:= SB2->B2_VATU1 // Valor Atual do Estoque

	DBSELECTAREA("SD3")

	If  Fieldpos("D3_ZB2QANT") > 0 .and. Fieldpos("D3_ZB2VANT") > 0    // Só grava na criação do Movimento, na atualização do mesmo não altera o dado

		lLock :=  RecLock("SD3",.F.) //Verifica se já está com o recLock ativo  .T. se é possivel bloquear

		Replace SD3->D3_ZB2QANT With SB2->B2_QATU
		Replace SD3->D3_ZB2VANT With SB2->B2_VATU1


		If lLock
			MsUnlock()
		Endif

	Endif
	DbSelectArea("SD3")
	DBSETORDER(nOrdemD3)
	DBGOTO(nRecnoD3)

	DbSelectArea("SB2")
	DBSETORDER(nOrdemB2)
	DBGOTO(nRecnoB2)

	DbSelectArea(cAlias)

Return Nil
