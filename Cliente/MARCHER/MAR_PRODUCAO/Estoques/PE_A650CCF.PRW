#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A650CCF    ºAutor  ³Cesar Mussi    º Data ³    23/12/14  	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³PE - Verifica se o produto será fabricado ou comprado         º±±
±±º          ³ALTERA TIPO DO COMPONENTE NA INCL DE OP                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CP - Solutio IT                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
Por padrão o sistema busca na estrutura se o item é componente ou se o item é PI.
Se for PI, considera Para Produzir, se for componente, considera para Comprar. 
Não considerando o campo B1_PRODSBP. Considera esta  campo apenas quando parâmetro para estutura negativa está ativado (MV_NEGESTR)

Este ponto de entrada fixa quando Preenchido o campo B1_PRODSBP para determinar se produz ou compra.
Se vazio campo B1_PRODSBP, considera como padrão de acordo com a estrutura.

Caso ativado o parâmetro MV_NEGESTR, este PE deve ser revisto.

Retorno: Caracter representando o tipo do componente.
Sera desprezado se nao for "F", "C" ou "I".
F - fabricado
C - comprado
I - ignorado (nao gera SC nem OP)
Fonte: https://tdn.totvs.com/pages/releaseview.action?pageId=236427989

Paramixb[1] //Componente (produto)
Paramixb[2] //Tipo [F-fabricado quando PI da estrutura, C-Comprado quando componente da estrutura] 
Paramixb[3] //Data Prevista


*/


USER FUNCTION A650CCF()

	Local cProd := Paramixb[1]
	Local _cTipo := Paramixb[2]
	Local aAreaSB1 := SB1->(GetArea())


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona SB1                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SB1->B1_COD != cProd
		SB1->(dbSetOrder(1))
		SB1->(MsSeek(FWxFilial("SB1")+cProd))
	EndIf
	cProdSBP :=SB1->B1_PRODSBP


//_myRet := IIF(cProdSBP=="P","F","C")

	If cProdSBP == "P" //Produz produto
		_cTipo:= "F"  // (F - Fabricado)
	ElseIf cProdSBP == "C" // Compra
		_cTipo:= "C" // (C - comprado )
	Else
		//Retorna o Tipo conforme a Estrutura (tipo recebido)
	EndIf
	RestArea(aAreaSB1)
Return(_cTipo)