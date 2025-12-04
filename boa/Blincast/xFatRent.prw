#INCLUDE "apwebsrv.ch"
#Include "totvs.ch"
#Include "TopConn.ch"
#Include "TBIConn.ch"
#Include "Protheus.ch"

/*/{Protheus.doc} xFatRental
description Faturar de forma automática os pedidos de venda cuja série for de repasse, iremos
amarrar a série de repasse pelo código do produto que está sendo faturado.
@type function
@version  
@author Tiengo Junior
@since 11/10/2025
@return variant, return_description
/*/
User Function xFatRent()

	Local	lSchedule	:= FWGetRunSchedule()
	Local 	cFunction	:= "xFatRent"
	Local	cTitle		:= "Faturamento Pedido Repasse Rental"
	Local	cObs		:= ""
	Local	oProcess	:= Nil
	Local	cHInicio	:= Time()

	Private CTITAPP  	:= "xFatRental - Atualização Status Rental"

	If !lSchedule
		cObs := "Essa rotina tem a finalidade de realizar o faturamento de pedidos de repasse"
		oProcess := TNewProcess():New(cFunction, cTitle, {|oSelf, lSchedule| xStsProc(oSelf, lSchedule, 0)}, cObs)
		Aviso("Aviso - " + cTitle + " - " + cHInicio + " - " + Time() , "Fim do processamento! ", {"OK"})
	Else
		xStsProc(Nil, lSchedule, 0)
		Conout(cFunction +": " + cTitle + " - " + cHInicio + " - " + Time() +" - Fim do processamento!")
	EndIf

	If ValType(oProcess) == "O"
		FreeObj(oProcess)
	EndIf

Return(.T.)

/*/{Protheus.doc} xStsProc
description Processamento para criar faturamento de pedidos de repasse
@type function
@version  
@author Tiengo Junior
@since 11/10/2025
@param oSelf, object, param_description
@param lSchedule, logical, param_description
@param nRecno, numeric, param_description
@return variant, return_description
/*/
Static Function xStsProc(oSelf, lSchedule, nRecno)

	Local cQuery    	:= ""
	Local cAlias 		:= ""
	Local cMsg			:= ""
	Local cPrdRental  	:= SuperGetMV('MV_BLIPROD', .F., '')

	Default oSelf := Nil
	Default lSchedule := FWGetRunSchedule()

	cQuery := "SELECT DISTINCT 													"
	cQuery += "    SC5.C5_FILIAL, 												"
	cQuery += "    SC5.C5_NUM, 													"
	cQuery += "    SC5.C5_CLIENTE, 												"
	cQuery += "    SC5.C5_LOJACLI, 												"
	cQuery += "    SC5.C5_TIPO, 												"
	cQuery += "    SC5.C5_NOTA, 												"
	cQuery += "    SC5.C5_SERIE, 												"
	cQuery += "    SC5.C5_EMISSAO 												"
	cQuery += "FROM SC5010 SC5 													"
	cQuery += "INNER JOIN SC6010 SC6 ON SC6.C6_FILIAL = SC5.C5_FILIAL 			"
	cQuery += "   AND SC6.C6_NUM = SC5.C5_NUM 									"
	cQuery += "   AND SC6.C6_PRODUTO = '" + cPrdRental + "'						"
	cQuery += "   AND SC6.D_E_L_E_T_ = ' ' 										"
	cQuery += "WHERE SC5.D_E_L_E_T_ = ' '										"
	cQuery += "  AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' 					"
	cQuery += "  AND SC5.C5_NOTA= ' ' 											"
	cQuery += "  AND SC5.C5_XRENTA <> ' ' 										"

	cQuery := ChangeQuery(cQuery)
	cAlias := MPSysOpenQuery(cQuery)

	If (cAlias)->(Eof())
		If lSchedule
			Conout("Nenhum titulo Encontrado")
			Return()
		Else
			FWAlertWarning("Nenhum titulo Encontrado")
			Return()
		Endif
	Endif

	While ! (cAlias)->(Eof())

		fGeraNota((cAlias)->C5_NUM, @cMsg)

		(cAlias)->(dbSkip())
	Enddo

	If ! Empty(cMsg) .and. ! lSchedule
		Aviso("Status Processamento NF", cMsg, {"OK"}, 3, "Inclusão de Nota fiscal")
	Endif

	(cAlias)->(dbCloseArea())

Return()

/*/{Protheus.doc} fGeraNota
Funcao que executa a Rotina MATA460 
@type function
@version V 1.00
@author Tiengo junior
@since 11/10/2025
/*/

Static Function fGeraNota(cC5Num, cMsg)

	Local aArea      	:= FWGetArea()
	Local aPvlDocS 		:= {}
	Local nPrcVen 		:= 0
	Local cEmbExp 		:= ""
	Local cSerie        := SuperGetMV('MV_BLISER', .F., 'LOC')

	SC5->(DbSetOrder(1))
	SC5->(MsSeek(xFilial("SC5")+cC5Num))

	SC6->(dbSetOrder(1))
	SC6->(MsSeek(xFilial("SC6")+cC5Num))

	//É necessário carregar o grupo de perguntas MT460A, se não será executado com os valores default.
	Pergunte("MT460A",.F.)

	// Obter os dados de cada item do pedido de vendas liberado para gerar o Documento de Saída
	While SC6->(!Eof() .And. SC6->C6_FILIAL == xFilial("SC6")) .And. SC6->C6_NUM == cC5Num

		SC9->(DbSetOrder(1))
		SC9->(MsSeek(xFilial("SC9")+SC6->(C6_NUM+C6_ITEM))) //FILIAL+NUMERO+ITEM

		SE4->(DbSetOrder(1))
		SE4->(MsSeek(xFilial("SE4")+SC5->C5_CONDPAG) )  //FILIAL+CONDICAO PAGTO

		SB1->(DbSetOrder(1))
		SB1->(MsSeek(xFilial("SB1")+SC6->C6_PRODUTO))    //FILIAL+PRODUTO

		SB2->(DbSetOrder(1))
		SB2->(MsSeek(xFilial("SB2")+SC6->(C6_PRODUTO+C6_LOCAL))) //FILIAL+PRODUTO+LOCAL

		SF4->(DbSetOrder(1))
		SF4->(MsSeek(xFilial("SF4")+SC6->C6_TES))   //FILIAL+TES

		nPrcVen := SC9->C9_PRCVEN

		If ( SC5->C5_MOEDA <> 1 )
			nPrcVen := xMoeda(nPrcVen,SC5->C5_MOEDA,1,dDataBase)
		EndIf

		//Define que o pedido foi liberado
		RecLock("SC5", .F.)

		SC5->C5_LIBEROK := 'S'

		SC5->(MsUnlock())

		MaLibDoFat(;
			SC6->(RecNo()),; //nRegSC6
		SC6->C6_QTDVEN,; //nQtdaLib
		,;               //lCredito
		,;               //lEstoque
		.F.,;            //lAvCred
		.F.,;            //lAvEst
		.F.,;            //lLibPar
		.F.;             //lTrfLocal
		)

		//Criando Array com os itens a serem gerados
		If AllTrim(SC9->C9_BLEST) == "" .And. AllTrim(SC9->C9_BLCRED) == ""
			AAdd(aPvlDocS,{ SC9->C9_PEDIDO,;
				SC9->C9_ITEM,;
				SC9->C9_SEQUEN,;
				SC9->C9_QTDLIB,;
				nPrcVen,;
				SC9->C9_PRODUTO,;
				.F.,;
				SC9->(RecNo()),;
				SC5->(RecNo()),;
				SC6->(RecNo()),;
				SE4->(RecNo()),;
				SB1->(RecNo()),;
				SB2->(RecNo()),;
				SF4->(RecNo())})
		EndIf

		SC6->(DbSkip())

	EndDo

	SetFunName("MATA461")

	cDoc := MaPvlNfs(  /*aPvlNfs*/         aPvlDocS,;           // 01 - Array com os itens a serem gerados
                       /*cSerieNFS*/       Alltrim(cSerie),;    // 02 - Serie da Nota Fiscal
                       /*lMostraCtb*/      .F.,;                // 03 - Mostra Lançamento Contábil
                       /*lAglutCtb*/       .F.,;                // 04 - Aglutina Lançamento Contábil
                       /*lCtbOnLine*/      .F.,;                // 05 - Contabiliza On-Line
                       /*lCtbCusto*/       .T.,;                // 06 - Contabiliza Custo On-Line
                       /*lReajuste*/       .F.,;                // 07 - Reajuste de preço na Nota Fiscal
                       /*nCalAcrs*/        0,;                  // 08 - Tipo de Acréscimo Financeiro
                       /*nArredPrcLis*/    0,;                  // 09 - Tipo de Arredondamento
                       /*lAtuSA7*/         .T.,;                // 10 - Atualiza Amarração Cliente x Produto
                       /*lECF*/            .F.,;                // 11 - Cupom Fiscal
                       /*cEmbExp*/         cEmbExp,;            // 12 - Número do Embarque de Exportação
                       /*bAtuFin*/         {||},;               // 13 - Bloco de Código para complemento de atualização dos títulos financeiros
                       /*bAtuPGerNF*/      {||},;               // 14 - Bloco de Código para complemento de atualização dos dados após a geração da Nota Fiscal
                       /*bAtuPvl*/         {||},;               // 15 - Bloco de Código de atualização do Pedido de Venda antes da geração da Nota Fiscal
                       /*bFatSE1*/         {|| .T. },;          // 16 - Bloco de Código para indicar se o valor do Titulo a Receber será gravado no campo F2_VALFAT quando o parâmetro MV_TMSMFAT estiver com o valor igual a "2".
                       /*dDataMoe*/        dDatabase,;          // 17 - Data da cotação para conversão dos valores da Moeda do Pedido de Venda para a Moeda Forte
                       /*lJunta*/          .F.)                 // 18 - Aglutina Pedido Iguais

	If ! Empty(cDoc)
		Conout("Pedido de venda: " + cC5Num + " Documento de Saida: " + cDoc + " Serie:" + ALLTRIM(cSerie) + ", gerado com sucesso!")
		cMsg += "Pedido de venda: " + cC5Num + " Documento de Saida: " + cDoc + " Serie:" +ALLTRIM(cSerie) + ", gerado com sucesso!"
	EndIf

	FWRestArea(aArea)

Return()


/*/{Protheus.doc} SchedDef
description Função para utilização no Schedule
@type function
@version  
@author Tiengo Junior
@since 11/10/2025
@return variant, return_description
/*/
Static Function SchedDef()

	Local _aPar 	:= {}		//array de retorno
	Local _cFunc	:= "xFatRent"
	Local _cPerg	:= PadR(_cFunc, 10)

	_aPar := { 	"P"		,;	//Tipo R para relatorio P para processo
	_cPerg	,;	//Nome do grupo de perguntas (SX1)
	Nil		,;	//cAlias (para Relatorio)
	Nil		,;	//aArray (para Relatorio)
	Nil		}	//Titulo (para Relatorio)

Return(_aPar)
