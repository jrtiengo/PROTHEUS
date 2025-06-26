#Include 'Protheus.ch'

/*/{Protheus.doc} MT094LEG
description Ponto de Entrada executado na abertura da tela de liberação de documentos para alterar/criar a legenda e cor.
@type function
@version  
@author Tiengo Junior
@since 23/06/2025
@obs PARAMIXB Array com as Legendas já disponíveis
@Return Array com as novas Legendas
@See https://tdn.totvs.com/pages/releaseview.action?pageId=286512466
/*/

User Function MT094LEG()

	Local aLegenda := {}        as array
	Local nX       := 0         as numeric

	//GAP-180 - Adicionar uma legenda, quando for pedidos emergenciais
	aAdd(aLegenda, { "CR_XIEMERG =='S' .and. CR_STATUS == '01' ", "BR_MARROM"           ,"Pedido Emergencial (Bloqueado Aguardando outros niveis)" })
	aAdd(aLegenda, { "CR_XIEMERG =='S' .and. CR_STATUS == '02' ", "ORANGE"              ,"Pedido Emergencial (Aguardando Liberacao do usuario)" })
	aAdd(aLegenda, { "CR_XIEMERG =='S' .and. CR_STATUS == '03' ", "BR_VERDE_ESCURO"     ,"Pedido Emergencial (Documento Liberado pelo usuario)" })
	aAdd(aLegenda, { "CR_XIEMERG =='S' .and. CR_STATUS == '04' ", "BR_PRETO_1"          ,"Pedido Emergencial (Documento Bloqueado pelo usuario)" })
	aAdd(aLegenda, { "CR_XIEMERG =='S' .and. CR_STATUS == '05' ", "BR_VIOLETA"          ,"Pedido Emergencial (Documento Liberado por outro usuario)" })
	aAdd(aLegenda, { "CR_XIEMERG =='S' .and. CR_STATUS == '06' ", "BR_PRETO_2"          ,"Pedido Emergencial (Documento Rejeitado pelo usuario)" })
	aAdd(aLegenda, { "CR_XIEMERG =='S' .and. CR_STATUS == '07' ", "BR_PRETO_3"          ,"Pedido Emergencial (Documento Rejeitado ou Bloqueado por outro usuario)" })

	For nX := 1 to Len(PARAMIXB[1])
		aAdd(aLegenda  ,PARAMIXB[1][nX])
	Next nX

Return(aLegenda)
