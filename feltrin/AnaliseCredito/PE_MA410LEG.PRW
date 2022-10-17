#include"Protheus.ch"

/*/{Protheus.doc} MA410LEG
PE para substituir a avaliacao de credito padrao do sistema
@type classe
@version  1.0
@author tiengo
@since 28/09/2022
@return variant, null 
/*/

User Function MA410LEG()

Local aLeg := PARAMIXB


    aLeg := {   {'ENABLE' ,"Pedido de Venda em aberto"},;
                {'DISABLE' ,"Pedido de Venda encerrado"},;
                {'BR_AMARELO',"Pedido de Venda liberado"},;
                {'BR_AZUL' ,"Pedido de Venda com Bloqueio de Regra"},;
                {'BR_LARANJA',"Pedido de Venda com Bloqueio de Verba"},;
                {'BR_PRETO',"Pedido de Venda com Bloqueio de Credito - CUSTOM"} }

Return aLeg
