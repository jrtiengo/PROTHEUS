#Include "TOTVS.CH"

/*/{Protheus.doc} MTA120G3
Ponto de entrada na gravacao dos itens do Pedido de Compra
Tem como objetivo avaliar a alcada do Pedido de Compra x Orcamento Contabil
@type function
@version  2
@author Jeferson Silva
@since 18/02/2020
@return variant, Verdadeiro
/*/
User Function MTA120G3()

	Local aArea        := GetArea()
	Local aAreaSC7     := SC7->( GetArea() )

	Local cGrpCOrc     := AllTrim(GetMv( 'CI_MTA1204' )) // Grupo  com Orçamento // 000002

	Local nMargemBlq   := GetMv( 'CI_MTA1203' ) // Margem para bloqueio


	Local nVlOrcado    := 0
	Local nVlRealizado := 0


	IF ( Type("__cNewAprov") == "U" ) //Código do Grupo de Aprovação
		_SetNamedPrvt( "__cNewAprov" , "" ,"A120GRAVA")
	ENDIF


	//----------- Validação Orçamento por Produto
	/*
	aOrc := u_TDOrcPRD(SC7->C7_PRODUTO, SC7->C7_EMISSAO,SC7->C7_NUM,SC7->C7_ITEM)
	nVlRealizado := aOrc[1]
	nVlOrcIni    := aOrc[2]
	nVlOrcado    := aOrc[3]
	nMargemBlq   := aOrc[4]

	If nVlOrcado > 0
		IF  nVlRealizado <= nVlOrcado

			cScript := " Update " + RetSqlName('SC7') + " Set C7_APROV = '"+cGrpCOrc+"' "
			cScript	+= " Where C7_FILIAL = '" + xFilial('SC7') + "' And C7_NUM = '"+SC7->C7_NUM+"' "
			TCSQLExec( cScript )

			__cNewAprov := cGrpCOrc

		Endif
	Endif
	*/

	//----------- Validação Orçamento por Item Contábil

	aOrc := u_TDVlrOrc(SC7->C7_ITEMCTA, SC7->C7_EMISSAO,SC7->C7_NUM,SC7->C7_ITEM)
	nVlRealizado := aOrc[1]
	nVlOrcIni    := aOrc[2]
	nVlOrcado    := aOrc[3]
	nMargemBlq   := aOrc[4]

	If nVlOrcado > 0
		IF  nVlRealizado <= nVlOrcado

			cScript := " Update " + RetSqlName('SC7') + " Set C7_APROV = '"+cGrpCOrc+"' "
			cScript	+= " Where C7_FILIAL = '" + xFilial('SC7') + "' And C7_NUM = '"+SC7->C7_NUM+"' "
			TCSQLExec( cScript )

			__cNewAprov := cGrpCOrc

		Endif
	Endif

	Restarea(aAreaSC7)
	Restarea(aArea)

Return (.T.)


/*/{Protheus.doc} MT120APV
Ponto de entrada para alterar o Grupo de Aprovacao.
@type function
@version 2 
@author Jeferson Silva
@since 18/02/2020
@return variant, Variável de controle
/*/
User Function MT120APV()

Return(__cNewAprov)


/*/{Protheus.doc} TDVlrOrc
Tedesco Valida Orçamento PC + NF (atua em conjunto com MT120APV e MT120GRV)
@type function
@version  1
@author solutio
@since 20/12/2021
@param _cItemCta, variant, Item de conta contábil
@param _dDtEmissao, variant, Data de Emissão para verificação
@param _C7_NUM, variant, Pedido de venda (opicional)
@param _C7_ITEM, variant, Item Pedido de Venda (opcional)
@return variant, retorno 
/*/
User Function TDVlrOrc(_cItemCta, _dDtEmissao,_C7_NUM,_C7_ITEM)
	Local aReturn    := {}

	Local cQuery     := ''
	Local cRevisa    := Alltrim(GetMv( 'CI_MTA1202' ))
	Local nMargemBlq := GetMv( 'CI_MTA1203' ) //Margem para bloqueio


	Local cTRBD1       := GetNextAlias()
	Local CV1TMP       := GetNextAlias()
	Local SC7TMP       := GetNextAlias()
	Local nVlOrcIni    := 0 //Valor Orçado Inicial
	Local nVlOrcado    := 0 //Valor orçado aplicado Margem para Bloqueio
	Local nVlRealizado := 0
	Local nVlReaNF     := 0 // Valor Realizado Entregas Futuras

	DEFAULT _C7_NUM  := SPACE(TAMSX3("C7_NUM")[1])
	DEFAULT _C7_ITEM := SPACE(TAMSX3("C7_ITEM")[1])

	IF EMPTY(_cItemCta) .OR. EMPTY(_dDtEmissao)
		If !IsBlind()
			MsgInfo("TDVlrOrc - Deve ser informado item conta e data de emissão para correto funcionamento da rotina! ")
		Endif
	ENDIF



// So podera haver um unico registo na condicao abaixo.
	cQuery	:= " Select Max(CV1_VALOR) nVlOrcado,CV1_PERIOD, CV1_DTINI, CV1_DTFIM "
	cQuery	+= " From " + RetSqlName( 'CV1' ) + " CV1"
	cQuery	+= " Where CV1_FILIAL = '" + xFilial( 'CV1' ) + "'"
	cQuery	+= " And CV1_ORCMTO = '"+ cValToChar( Year( _dDtEmissao ) ) +"' "
	cQuery	+= " And CV1_REVISA = '"+cRevisa+"' "
	cQuery	+= " And CV1_CTDINI = '"+_cItemCta+"' "
	cQuery	+= " AND '"+Dtos(_dDtEmissao)+"'  BETWEEN CV1_DTINI AND CV1_DTFIM "
	cQuery	+= " AND CV1_PERIOD IN ('  ', '" + STRZERO(MONTH(_dDtEmissao),2) + "') "
	cQuery	+= " And CV1.D_E_L_E_T_ = ' '"
	cQuery	+= " Group By CV1_PERIOD,CV1_DTINI, CV1_DTFIM "

	MPSysOpenQuery( cQuery, CV1TMP )
	If (CV1TMP)->( !Eof() )
		nVlOrcIni := (CV1TMP)->nVlOrcado
	Endif

	If nVlOrcIni > 0
		// Avaliação do REALIZADO
		cQuery	:= ""
		cQuery	+= " select sum(nVlRealizado) as nVlRealizado FROM (
		// Realizado em Outros Pedidos
		cQuery	+= " 	Select  SUM(CASE WHEN C7_RESIDUO='S' THEN (C7_QUJE*C7_PRECO)+C7_VALIPI+C7_VALFRE+C7_DESPESA-C7_VLDESC ELSE C7_TOTAL+C7_VALIPI+C7_VALFRE+C7_DESPESA-C7_VLDESC END) nVlRealizado "
		cQuery	+= " 		From " + RetSqlName( 'SC7' ) + " SC7"
		cQuery	+= " 		Where C7_FILIAL = '" + xFilial( 'SC7' ) + "'"
		cQuery	+= " 			And C7_ITEMCTA = '"+_cItemCta+"' "
		cQuery	+= " 			And C7_EMISSAO Between '"+(CV1TMP)->CV1_DTINI+"' And '"+(CV1TMP)->CV1_DTFIM+"' "
		If !Empty((CV1TMP)->CV1_PERIOD)
			cQuery	+= " 			And C7_EMISSAO LIKE '"+ ANOMES(_dDtEmissao) +"%' "
		Endif
		cQuery	+= " 			And C7_CONAPRO IN ('L','B') " // Consideras PC Liberados e Bloqueado para a analise e posterior definicao do Grupo de Aprovacao
		cQuery	+= " 			And SC7.D_E_L_E_T_ = ' '"
		cQuery	+= " 			And C7_NUM <> '" + SC7->C7_NUM + "'"
		cQuery	+= " 			And C7_ENTFUT <> 'S'"
		// Realizado No Pedido Atual Até a linha anterior
		cQuery	+= " UNION ALL "
		cQuery	+= " 	Select  SUM(CASE WHEN C7_RESIDUO='S' THEN (C7_QUJE*C7_PRECO)+C7_VALIPI+C7_VALFRE+C7_DESPESA-C7_VLDESC ELSE C7_TOTAL+C7_VALIPI+C7_VALFRE+C7_DESPESA-C7_VLDESC END) nVlRealizado "
		cQuery	+= " 		From " + RetSqlName( 'SC7' ) + " SC7"
		cQuery	+= " 		Where C7_FILIAL = '" + xFilial( 'SC7' ) + "'"
		cQuery	+= " 			And C7_ITEMCTA = '"+_cItemCta+"' "
		cQuery	+= " 			And C7_EMISSAO Between '"+(CV1TMP)->CV1_DTINI+"' And '"+(CV1TMP)->CV1_DTFIM+"' "
		If !Empty((CV1TMP)->CV1_PERIOD)
			cQuery	+= " 			And C7_EMISSAO LIKE '"+ ANOMES(_dDtEmissao) +"%' "
		Endif
		cQuery	+= " 			And C7_CONAPRO IN ('L','B') " // Consideras PC Liberados e Bloqueado para a analise e posterior definicao do Grupo de Aprovacao
		cQuery	+= " 			And SC7.D_E_L_E_T_ = ' '"
		cQuery	+= " 			And C7_NUM = '" + _C7_NUM + "' AND C7_ITEM <= '" + _C7_ITEM + "'"
		cQuery	+= " 			And C7_ENTFUT <> 'S'"
		cQuery	+= " ) REALIZADO "

		MPSysOpenQuery( cQuery, SC7TMP )
		If (SC7TMP)->( !Eof() )
			nVlRealizado := (SC7TMP)->nVlRealizado
		Endif

		//Entrega futura recebidos
		cQuery	:= ""
		//cQuery	+= " SELECT SUM(D1_TOTAL  + D1_VALIPI + D1_VALFRE + D1_DESPESA + D1_VALDESC) nVlReaNF FROM " + RetSqlName( 'SD1' ) + " D1"
		cQuery	+= " SELECT SUM(D1_CUSTO) nVlReaNF FROM " + RetSqlName( 'SD1' ) + " D1"
		cQuery	+= " 	INNER JOIN " + RetSqlName( 'SC7' ) + " C7"
		cQuery	+= " 		ON  C7_FILIAL = D1_FILIAL "
		cQuery	+= " 		AND C7_NUM = D1_PEDIDO"
		cQuery	+= " 		AND C7_ITEM = D1_ITEMPC"
		cQuery	+= " 		AND C7.D_E_L_E_T_ = ' '"
		cQuery	+= " WHERE  D1_FILIAL = '" + xFilial( 'SD1' ) + "'"
		cQuery	+= " 	AND D1_PEDIDO  <> ' '"
		cQuery	+= " 	AND C7_ENTFUT = 'S'"
		cQuery	+= " 	And C7_ITEMCTA = '"+_cItemCta+"' "
		cQuery	+= " 	AND D1.D_E_L_E_T_ = ' '"
		cQuery	+= " 	AND D1_DTDIGIT BETWEEN '"+(CV1TMP)->CV1_DTINI+"' And '"+(CV1TMP)->CV1_DTFIM+"' "
		If !Empty((CV1TMP)->CV1_PERIOD)
			cQuery	+= " AND D1_DTDIGIT LIKE '"+ ANOMES(_dDtEmissao) +"%' "
		Endif

		MPSysOpenQuery( cQuery, cTRBD1 )

		If (cTRBD1)->(!Eof())
			nVlReaNF := (cTRBD1)->nVlReaNF
		Endif

		nVlRealizado += nVlReaNF


		nVlOrcado := nVlOrcIni * (nMargemBlq / 100)

	Endif
	aReturn := {nVlRealizado,nVlOrcIni,nVlOrcado, nMargemBlq}

	//Regra para bloqueio: (nVlOrcado - nVlRealizado) < nMargemBlq .And. (nVlOrcado - nVlRealizado) >= 0
	//Regra Bloqueio simplificada:  (nVlOrcado - nVlRealizado) >= 0

	IF SELECT(CV1TMP)  <> 0
		(CV1TMP)->(DbCloseArea())
	ENDIF

	IF SELECT(SC7TMP)  <> 0
		(SC7TMP)->(DbCloseArea())
	ENDIF

	IF SELECT(cTRBD1)  <> 0
		(cTRBD1)->(DbCloseArea())
	ENDIF


Return aReturn




/*/{Protheus.doc} TDOrcPRD
Tedesco Valida Orçamento PC + NF por PRODUTO (atua em conjunto com MT120APV e MT120GRV)
@type function
@version  1
@author Marcio
@since 05/01/2022
@param _Produto, variant, Item de conta contábil
@param _dDtEmissao, variant, Data de Emissão para verificação
@param _C7_NUM, variant, Pedido de venda (opicional)
@param _C7_ITEM, variant, Item Pedido de Venda (opcional)
@return variant, retorno 
/*/
User Function TDOrcPRD(_Produto, _dDtEmissao,_C7_NUM,_C7_ITEM)
	Local aReturn    := {}

	Local cQuery     := ''
	Local nMargemBlq := GetMv( 'CI_MTA1203' ) //Margem para bloqueio


	Local cTRBD1       := GetNextAlias()
	Local SZ3TMP       := GetNextAlias()
	Local SC7TMP       := GetNextAlias()
	Local nVlOrcIni    := 0 //Valor Orçado Inicial
	Local nVlOrcado    := 0 //Valor orçado aplicado Margem para Bloqueio
	Local nVlRealizado := 0
	Local nVlReaNF     := 0 // Valor Realizado Entregas Futuras

	DEFAULT _C7_NUM  := SPACE(TAMSX3("C7_NUM")[1])
	DEFAULT _C7_ITEM := SPACE(TAMSX3("C7_ITEM")[1])

	IF EMPTY(_cItemCta) .OR. EMPTY(_dDtEmissao)
		If !IsBlind()
			MsgInfo("TDOrcPRD - Deve ser informado item conta e data de emissão para correto funcionamento da rotina! ")
		Endif
	ENDIF



// So podera haver um unico registo na condicao abaixo.
	cQuery	:= " Select Max(Z3_VALOR) nVlOrcado,Z3_ANOMES "
	cQuery	+= " From " + RetSqlName( 'SZ3' ) + " Z3"
	cQuery	+= " Where Z3_FILIAL = '" + xFilial( 'SZ3' ) + "'"
	cQuery	+= " And Z3_ANOMES = '" + ANOMES(_dDtEmissao) +"' "
	cQuery	+= " And Z3.D_E_L_E_T_ = ' '"
	cQuery	+= " Group By Z3_ANOMES "

	MPSysOpenQuery( cQuery, SZ3TMP )
	If (SZ3TMP)->( !Eof() )
		nVlOrcIni := (SZ3TMP)->nVlOrcado
	Endif

	If nVlOrcIni > 0
		// Avaliação do REALIZADO
		cQuery	:= ""
		cQuery	+= " select sum(nVlRealizado) as nVlRealizado FROM (
		// Realizado em Outros Pedidos
		cQuery	+= " 	Select  SUM(CASE WHEN C7_RESIDUO='S' THEN (C7_QUJE*C7_PRECO)+C7_VALIPI+C7_VALFRE+C7_DESPESA-C7_VLDESC ELSE C7_TOTAL+C7_VALIPI+C7_VALFRE+C7_DESPESA-C7_VLDESC END) nVlRealizado "
		cQuery	+= " 		From " + RetSqlName( 'SC7' ) + " SC7"
		cQuery	+= " 		Where C7_FILIAL = '" + xFilial( 'SC7' ) + "'"
		cQuery	+= " 			And C7_PRODUTO = '"+_cItemCta+"' "
		cQuery	+= " 			And C7_EMISSAO LIKE '"+ (SZ3TMP)->Z3_ANOMES +"%' "
		cQuery	+= " 			And C7_CONAPRO IN ('L','B') " // Consideras PC Liberados e Bloqueado para a analise e posterior definicao do Grupo de Aprovacao
		cQuery	+= " 			And SC7.D_E_L_E_T_ = ' '"
		cQuery	+= " 			And C7_NUM <> '" + SC7->C7_NUM + "'"
		cQuery	+= " 			And C7_ENTFUT <> 'S'"
		// Realizado No Pedido Atual Até a linha anterior
		cQuery	+= " UNION ALL "
		cQuery	+= " 	Select  SUM(CASE WHEN C7_RESIDUO='S' THEN (C7_QUJE*C7_PRECO)+C7_VALIPI+C7_VALFRE+C7_DESPESA-C7_VLDESC ELSE C7_TOTAL+C7_VALIPI+C7_VALFRE+C7_DESPESA-C7_VLDESC END) nVlRealizado "
		cQuery	+= " 		From " + RetSqlName( 'SC7' ) + " SC7"
		cQuery	+= " 		Where C7_FILIAL = '" + xFilial( 'SC7' ) + "'"
		cQuery	+= " 			And C7_PRODUTO = '"+_cItemCta+"' "
		cQuery	+= " 			And C7_EMISSAO LIKE '"+ (SZ3TMP)->Z3_ANOMES +"%' "
		cQuery	+= " 			And C7_CONAPRO IN ('L','B') " // Consideras PC Liberados e Bloqueado para a analise e posterior definicao do Grupo de Aprovacao
		cQuery	+= " 			And SC7.D_E_L_E_T_ = ' '"
		cQuery	+= " 			And C7_NUM = '" + _C7_NUM + "' AND C7_ITEM <= '" + _C7_ITEM + "'"
		cQuery	+= " 			And C7_ENTFUT <> 'S'"
		cQuery	+= " ) REALIZADO "

		MPSysOpenQuery( cQuery, SC7TMP )
		If (SC7TMP)->( !Eof() )
			nVlRealizado := (SC7TMP)->nVlRealizado
		Endif

		//Entrega futura recebidos
		cQuery	:= ""
		//cQuery	+= " SELECT SUM(D1_TOTAL  + D1_VALIPI + D1_VALFRE + D1_DESPESA + D1_VALDESC) nVlReaNF FROM " + RetSqlName( 'SD1' ) + " D1"
		cQuery	+= " SELECT SUM(D1_CUSTO) nVlReaNF FROM " + RetSqlName( 'SD1' ) + " D1"
		cQuery	+= " 	INNER JOIN " + RetSqlName( 'SC7' ) + " C7"
		cQuery	+= " 		ON  C7_FILIAL = D1_FILIAL "
		cQuery	+= " 		AND C7_NUM = D1_PEDIDO"
		cQuery	+= " 		AND C7_ITEM = D1_ITEMPC"
		cQuery	+= " 		AND C7.D_E_L_E_T_ = ' '"
		cQuery	+= " WHERE  D1_FILIAL = '" + xFilial( 'SD1' ) + "'"
		cQuery	+= " 	AND D1_PEDIDO  <> ' '"
		cQuery	+= " 	AND C7_ENTFUT = 'S'"

		cQuery	+= " 			And C7_PRODUTO = '"+_cItemCta+"' "
		cQuery	+= " 	AND D1.D_E_L_E_T_ = ' '"
		cQuery	+= " 	AND D1_DTDIGIT LIKE '"+ (SZ3TMP)->Z3_ANOMES +"%' "

		MPSysOpenQuery( cQuery, cTRBD1 )

		If (cTRBD1)->(!Eof())
			nVlReaNF := (cTRBD1)->nVlReaNF
		Endif

		nVlRealizado += nVlReaNF


		nVlOrcado := nVlOrcIni * (nMargemBlq / 100)

	Endif
	aReturn := {nVlRealizado,nVlOrcIni,nVlOrcado, nMargemBlq}

	//Regra para bloqueio: (nVlOrcado - nVlRealizado) < nMargemBlq .And. (nVlOrcado - nVlRealizado) >= 0
	//Regra Bloqueio simplificada:  (nVlOrcado - nVlRealizado) >= 0

	IF SELECT(SZ3TMP)  <> 0
		(SZ3TMP)->(DbCloseArea())
	ENDIF

	IF SELECT(SC7TMP)  <> 0
		(SC7TMP)->(DbCloseArea())
	ENDIF

	IF SELECT(cTRBD1)  <> 0
		(cTRBD1)->(DbCloseArea())
	ENDIF


Return aReturn
