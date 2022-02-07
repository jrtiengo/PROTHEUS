#Include "Protheus.ch"
#Include "topconn.ch"


/*/{Protheus.doc} MT680EST
//Ponto de entrada:  É chamado no estorno das produções PCP, modelo I e II. É utilizado para validar se pode ocorrer o estorno do apontamento ou não.
@author Celso Renee
@since 18/01/2021
@version 1.0
@type function
/*/
User Function MT680EST()

Local _lRet := .T.

if (!Empty(SH6->H6_XETIQ))
    dbSelectArea("CB0")
    dbSetOrder(1)
    dbSeek(xFilial("CB0") + SH6->H6_XETIQ)
    if ( CB0->(Found()) .and. (!Empty(CB0->CB0_PEDVEN) .or. !Empty(CB0->CB0_XNEXPED)))
        MsgAlert("Etiqueta esta em Expedição: " + Alltrim(CB0->CB0_XNEXPED) + " ou Pedido de Venda: " + Alltrim(CB0->CB0_PEDVEN) + "  - Apontamento não pode ser excluído!","# Etiqueta já em uso")
        _lRet := .F.
    endif
endif


Return(_lRet)
