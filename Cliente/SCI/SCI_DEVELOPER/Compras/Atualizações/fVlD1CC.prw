#include "Protheus.ch"

/** {Protheus.doc} FVlD1CC
Utiliza a Validação do Campo D1_CC, para replicar campos no Acols
@param: 	Nil
@return:	Nil.
@author: 	Leonel Vilaverde
@since: 	20/10/2021
@Uso: 		Modulos 02 Compras  e 04 Estoque/Custos
**/


User Function fVlD1CC()
************************
Local lRet := .t.

//Inicio Leonel 20/10/21
Local nPosD1Doc := gdFieldPos("D1_DOC", aHeader )
Local nPosD1Ser := gdFieldPos("D1_SERIE", aHeader )
Local nPosD1For := gdFieldPos("D1_FORNECE", aHeader )
Local nPosD1Loj := gdFieldPos("D1_LOJA", aHeader )
Local nPosD1Cod := gdFieldPos("D1_COD", aHeader )
Local nLin          := ogetdados:obrowse:nat
Local cTES          := ' ' 
Local cFlag         := 0 

//IF Altera == .t. .and. l103Class == .T. //.and. ogetdados:obrowse:nat == 1 .and. cFLAG == 0//Alteração,ópcao Classificacao, 1a linha Acols
	nCodOper:=Aviso("Classificação ...","Deseja Replicar o Centro de Custo para todos os Itens da NF?",{"Sim","Não"},1)
	IF nCodOper == 1      // 1==Sim
		lRet := fRepCC()
		MsgRun("Replicando o Centro de Custo, aguarde...","Replicação de CC",{||  fRepCC() })
	EndIf
//EndIF

Return lRet
***********


Static Function fRepCC()

Local nX := 0
Local nCodOper:=0
Local cField := "D1_CC"

Local nPosD1CC   := gdFieldPos("D1_CC", aHeader )
Local nLin          := ogetdados:obrowse:nat
procregua( Len(Acols) )

	For nlin := 1 To Len(aCols) // ira partir da 2a. linha

		aCols[Nlin , nPosD1CC] := M->D1_CC 

		N++  //Atualizo o N para atualizar o acols senão dá erro

	Next nlin


	N:=ogetdados:obrowse:nat // Restauro a posiçao atual da linha do browse

oGetDados:ForceRefresh()
SetFocus(oGetdados:oBrowse:hWnd) // Atualização por linha
Return .t.

