#Include "Totvs.ch"
#INCLUDE "TOPCONN.CH"
#DEFINE  ENTER CHR(13)+CHR(10)


/*/{Protheus.doc} M460MARK
O ponto de entrada M460MARK é utilizado para validar os pedidos marcados e está localizado no inicio da função  
a460Nota (endereça rotinas para a geração dos arquivos  SD2/SF2).Será informado no terceiro parâmetro a série   
selecionada na geração da nota e o número da nota fiscal poderá ser verificado pela variável private cNumero.    

Parâmetros - Os parâmetros enviados são {ThisMark(),ThisInv()}, que   identificam se o pedido foi selecionado. Desta forma poderá
verificar se passou True(Marcado) ou False(Não Marcado).   

@type function
@version  25
@author Márcio Borges
@since 25/03/2021
@return logical,  True continua e False aborta emissao da nota.  
/*/
User Function M460MARK()

	Local aArea := GetArea()
	Local _aAreaSB1     := SB1->(GetArea())
	Local _aAreaSF4     := SF4->(GetArea())
	Local _aAreaSC6     := SC6->(GetArea())
	Local _aAreaSC9     := SC9->(GetArea())

	Local lPESONFS := SuperGetMV("ES_PESONFS",.F.,.F.) //Ativa Funcionalidade de Peso Liq/Bruto na Filial

	Private __lNFOk 	:= .T. 

	If __lNFOk

		IF  lPESONFS
			VldPesoPV()
		Endif

	EndIf

	RestArea(_aAreaSB1)
	RestArea(_aAreaSF4)
	RestArea(_aAreaSC6)
	RestArea(_aAreaSC9)
	RestArea(aArea)

Return __lNFOk


/*/{Protheus.doc} VldPesoPV
Valida Peso no Pedido de Vendas
@type function
@version  25
@author Márcio Borges
@since 25/03/2021
/*/
Static Function VldPesoPV()

	Local cQuery    := ""
	Local cAliasQry := GetNextAlias()
	Local cMark		:= PARAMIXB[1]

	Local cAviso	:= ""
	Local aPedido	:= {}
	//Local oCPROTSUP := CPROTSUP():New()

	Private nTolPTEO    := SuperGetMV("ES_DIFPTEO",.f.,0.05) //5% de tolerância

	cAviso := "Os pedidos a seguir estão sem informações de Peso Líquido ou Peso Bruto ou as mesmas"
	cAviso += "não satisfazem os critérios de tolerância de " + Alltrim(Str(nTolPTEO*100)) + "% em relação ao peso teórico. Favor revisar os pedidos antes de realizar o faturamento." + CRLF + CRLF

	// se o PE for chamado pelo Prep. Docs do Faturamento, faz a query na SC9
	If IsInCallStack("MATA460A")

		cQuery := "SELECT SC9.R_E_C_N_O_ C9RECNO, C9_PEDIDO, C9_ITEM, C9_PRODUTO, C9_CLIENTE, C9_LOJA "
		cQuery += " FROM " + RetSqlName("SC9") + " SC9 "
		cQuery += " WHERE C9_FILIAL = '" + xFilial("SC9") + "'"
		cQuery += "   AND C9_OK = '" + cMark + "'"
		cQuery += "   AND SC9.	D_E_L_E_T_ <> '*'"

		// se o PE for chamado pelo Prep. Docs do OMS, faz a query na DAK
	ElseIf IsInCallStack("MATA460B")

		cQuery := "SELECT SC9.R_E_C_N_O_ C9RECNO,C9_PEDIDO,"
		cQuery += "       C9_CLIENTE,"
		cQuery += "       C9_LOJA,"
		cQuery += "       DAK_COD"
		cQuery += "  FROM " + RetSqlName("DAK") + " DAK "
		cQuery += " INNER JOIN " + RetSqlName("SC9") + " SC9 "
		cQuery += "    ON C9_FILIAL = DAK_FILIAL"
		cQuery += "   AND C9_CARGA = DAK_COD"
		cQuery += "   AND SC9.D_E_L_E_T_ <> '*'"
		cQuery += " WHERE DAK_OK = '" + cMark + "'"
		cQuery += "   AND DAK.D_E_L_E_T_ <> '*'"

	EndIf

	MPSysOpenQuery( cQuery, cAliasQry)

	While(cAliasQry)->(!EoF())

		SC9->(dbGoTo((cAliasQry)->C9RECNO))

		SC6->(dbSeek(xFilial()+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO))
		SF4->(dbSeek(xFilial()+SC6->C6_TES))
		SB1->(dbSeek(xFilial()+SC9->C9_PRODUTO))

		IF SB1->B1_TIPO == "PA" .AND. SF4->F4_ESTOQUE == 'S'
			If Empty(SC6->C6_PESO) .OR. Empty(SC6->C6_PBRUTO ) .OR. (SC6->C6_PESO > SB1->B1_PESO * (1+nTolPTEO) .OR. SC6->C6_PESO < SB1->B1_PESO * (1-nTolPTEO)) .OR. SC6->C6_PBRUTO  < SC6->C6_PESO

				nPosPed := aScan(aPedido,(cAliasQry)->C9_PEDIDO)
				If nPosPed = 0
					aAdd(aPedido,(cAliasQry)->C9_PEDIDO)
					cAviso += "Pedido: " + (cAliasQry)->C9_PEDIDO + " Item: " + SC9->C9_ITEM + CRLF
					cAviso += "Produto: " + AllTrim(SC9->C9_PRODUTO) + " | Peso Teórico: " + AllTrim(TRANSFORM(SB1->B1_PESO,PESQPICT("SB1","B1_PESO"))) + CRLF
					cAviso += "Peso Líquido: " + AllTrim(TRANSFORM(SC6->C6_PESO,PESQPICT("SC6","C6_PESO"))) +  " | Peso Bruto: " +  AllTrim(TRANSFORM(SC6->C6_PBRUTO,PESQPICT("SC6","C6_PBRUTO"))) +  CRLF + CRLF
				EndIf
			Endif
		EndIf


		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

	If Len(aPedido) > 0
		Aviso("Validação de Peso ",cAviso,{"OK"},3)
		__lNFOk := .F.
	EndIf

Return
