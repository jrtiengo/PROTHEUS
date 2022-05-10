#include "Protheus.ch"

/** {Protheus.doc} FVlD1OP
Utiliza a Validação do Campo D1_OPER, para replicar campos no Acols
@param: 	Nil
@return:	Nil.
@author: 	Leonel Vilaverde
@since: 	10/03/2021
@Uso: 		Modulos 02 Compras  e 04 Estoque/Custos
**/


User Function fVlD1OP()
************************
Local lRet := .t.

//Inicio Leonel 10/03/21
Local nPosD1Doc := gdFieldPos("D1_DOC", aHeader )
Local nPosD1Ser := gdFieldPos("D1_SERIE", aHeader )
Local nPosD1For := gdFieldPos("D1_FORNECE", aHeader )
Local nPosD1Loj := gdFieldPos("D1_LOJA", aHeader )
Local nPosD1Cod := gdFieldPos("D1_COD", aHeader )
Local nLin          := ogetdados:obrowse:nat
Local cTES          := ' ' 
Local cFlag         := 0 

//IF Altera == .t. .and. l103Class == .T. //.and. ogetdados:obrowse:nat == 1 .and. cFLAG == 0//Alteração,ópcao Classificacao, 1a linha Acols
	nCodOper:=Aviso("Classificação ...","Deseja Replicar a operação para todos os Itens da NF?",{"Sim","Não"},1)
	IF nCodOper == 1      // 1==Sim
		lRet := fRepCpo()
		MsgRun("Replicando Operação, aguarde...","Replicação de Operação",{||  fRepCpo() })
	EndIf
//EndIF

Return lRet
***********



/** {Protheus.doc} fRepCpo()
Replica D1_TES para replicar campos no Acols
@param: 	Nil
@return:	Nil.
@author: 	Emerson Coelho
@since: 	07/03/2014
@Uso: 		Modulo 05 Faturamento
**/
Static Function fRepCpo()

Local nX := 0
Local nCodOper:=0
Local cField := "D1_OPER"

Local nPosD1OPer := gdFieldPos("D1_OPER", aHeader )
Local nPosD1TES  := gdFieldPos("D1_TES", aHeader )
Local nPosD1MSP  := gdFieldPos("D1_MSUGPRC", aHeader )
Local nPosD1CTA  := gdFieldPos("D1_CONTA", aHeader )
Local nPosD1CC   := gdFieldPos("D1_CC", aHeader )
Local nPosD1B1   := gdFieldPos("D1_COD", aHeader )
Local nLin2      := ogetdados:obrowse:nat
procregua( Len(Acols) )


	For nlin2 := 1 To Len(aCols) // ira partir da 2a. linha

     	if N <=  Len(aCols)
		   RunTrigger(2,nLin2,nil,,'D1_OPER')
        EndIF

		aCols[nLin2 , nPosD1OPer] := M->D1_OPER //aCols[1 , nPosD1OPer]
		N++  //Atualizo o N para atualizar o acols senão dá erro

	Next nlin2

	N:=ogetdados:obrowse:nat // Restauro a posiçao atual da linha do browse

oGetDados:ForceRefresh()
SetFocus(oGetdados:oBrowse:hWnd) // Atualização por linha
Return .t.

