#Include "TOTVS.CH"


/*/{Protheus.doc} MSD2460
 Ponto de Entrada criado na gravação dos Itens da NF, 
 para executar um execblock criado pelo usuário após a gravação da tabela SD2 e antes do somatório do peso -- https://tdn.totvs.com/pages/releaseview.action?pageId=6787795 
 é chamado para cada item do SD2.
@type function
@version  25
@author Márcio Borges
@since 25/03/2021
/*/
User Function MSD2460()

Local lPESONFS := SuperGetMV("ES_PESONFS",.F.,.F.) //Ativa Funcionalidade de Peso Liq/Bruto na Filial

	If lPESONFS
		If SD2->(D2_FILIAL+D2_PEDIDO+D2_ITEMPV+D2_COD) == SC6->(C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO)
			reclock("SD2",.f.)
			If !Empty(SC6->C6_PESO)
				Replace SD2->D2_PESO    With SC6->C6_PESO
			Endif
			If !Empty(SC6->C6_PBRUTO)
				Replace SD2->D2_PBRUTO  With SC6->C6_PBRUTO
			Endif 
			MsUnlock()
		Else
			MsgAlert("SC6 NÃO POSICIONADO NA GERAÇÃO DO ITEM DA NOTA FISCAL - CONTATE ADMINISTRADOR DO SISTEMA")
		Endif
	Endif
Return
