#Include "TOTVS.ch"
#Include "PROTHEUS.ch"
#Include "TOPCONN.ch"

/*/{Protheus.doc} xCOMPREC
Este programa tem como objetivo gerar compensações a receber em massa.
A lógica consiste em encontrar clientes com adiantamentos (RA) e, para cada um,
permitir que o usuário selecione os títulos (NF) que serão compensados.

@type      Function
@author    Tiengo Junior (Refatorado por Manus)
@since     29/08/2025
@version   2.0
@param     MV_PAR01  Data de emissão inicial (Pergunte)
@param     MV_PAR02  Data de emissão final (Pergunte)
@param     MV_PAR03  Cliente inicial (Pergunte)
@param     MV_PAR04  Cliente final (Pergunte)
@see       https://centraldeatendimento.totvs.com/hc/pt-br/articles/7974002547607-Cross-Segmentos-Backoffice-Linha-Protheus-SIGAFIN-FINA330-Documenta%C3%A7%C3%A3o-execauto
/*/
User Function xCOMPREC( )

	Local aArea    := FWGetArea()
	Local cTitulo  := "Compensação a Receber"
	Local cDesc    := "Este programa realiza a compensação a receber em massa para os clientes selecionados."
	Local cPerg    := "XCOMPREC" // Nome da pergunte para os parâmetros

	// Define a "Pergunte" para que o usuário possa filtrar os adiantamentos
	Pergunte(cPerg, .F.)

	// Inicia o processamento em thread, se não for execução "blind"
	If !IsBlind()
		TNewProcess():New(cPerg, cTitulo, {|oSelf| fBusca(oSelf)}, cDesc)
	Endif

	FwRestArea(aArea)

Return

Static Function fBusca(oSelf)

	Local aArea     := FWGetArea()
	Local cQuery    := ""
	Local cAlias    := GetNextAlias()
	Local aClientes := {}
	Local oBrowse

	// Query para buscar clientes que possuem adiantamentos (RA) em aberto
	cQuery := " SELECT DISTINCT E1_CLIENTE, E1_LOJA "
	cQuery += " FROM " + RetSqlName("SE1") + " SE1 "
	cQuery += " WHERE SE1.D_E_L_E_T_ = ' ' "
	cQuery += "   AND SE1.E1_FILIAL = '" + FWxFilial('SE1') + "' "
	cQuery += "   AND SE1.E1_TIPO = 'RA' "
	cQuery += "   AND SE1.E1_SALDO > 0 "
	cQuery += "   AND SE1.E1_BAIXA = ' ' "
	cQuery += "   AND SE1.E1_CLIENTE BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "

	cQueryRA := " SELECT E1_CLIENTE, E1_LOJA, SUM(E1_SALDO) AS SALDO_RA "
	cQueryRA += " FROM " + RetSqlName("SE1") + " SE1 "
	cQueryRA += " WHERE SE1.D_E_L_E_T_ = ' ' " 
    cQueryRA += " AND SE1.E1_FILIAL = '" + FWxFilial('SE1') + "' " 
    cQueryRA += " AND SE1.E1_TIPO = 'RA' " 
    cQueryRA += " AND SE1.E1_SALDO > 0 " 
    cQueryRA += " AND SE1.E1_BAIXA = ' ' " 
    cQueryRA += " AND SE1.E1_CLIENTE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " 
	cQuery := ChangeQuery(cQuery)
	cAlias := MPSysOpenQuery(cQuery)

	If (cAlias)->(EoF())
		If ! IsBlind()
			FWAlertWarning('Atenção não foram encontrados registros','Atenção')
			Return()
		Endif
	Endif

	// Itera sobre os clientes que possuem RAs
	While !(cAlias)->(EoF())
		// Chama a função que busca os títulos a compensar para o cliente encontrado
		fProcessa((cAliasRA)->E1_CLIENTE, (cAliasRA)->E1_LOJA)
		(cAliasRA)->(DbSkip())
	Enddo

	(cAliasRA)->(DbCloseArea())
	FwRestArea(aArea)

	If !IsBlind()
		FWAlertInfo("Processamento finalizado!", "Sucesso")
	Endif

Return

/*-------------------------------------------------------------------
| fProcessaCompensacao(cCliente, cLoja)
|-------------------------------------------------------------------
| Para um dado cliente/loja, busca os títulos (NF) e permite ao
| usuário selecionar quais serão compensados.
|-----------------------------------------------------------------*/
Static Function fProcessa(cCliente, cLoja)

    Local aArea         := FWGetArea()
    Local cQueryNF      := ""
    Local cAliasNF      := GetNextAlias()
    Local aTitulosNF    := {}
    Local aRecsNF       := {}
    Local aRecsRA       := {}
    Local lContabiliza, lAglutina, lDigita
    Local oBrowse

    // 1. Busca os RECNOs dos adiantamentos (RA) para este cliente
    aRecsRA := fGetRecnosRA(cCliente, cLoja)
    If Empty(aRecsRA)
        Return 
    Endif

    // 2. Monta a query para buscar os títulos (NF) em aberto do mesmo cliente
    cQueryNF := " SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_EMISSAO, E1_VENCTO, E1_SALDO, R_E_C_N_O_ "
    cQueryNF += " FROM " + RetSqlName("SE1") + " SE1 "
    cQueryNF += " WHERE SE1.D_E_L_E_T_ = ' ' "
    cQueryNF += "   AND SE1.E1_FILIAL = '" + FWxFilial('SE1') + "' "
    cQueryNF += "   AND SE1.E1_CLIENTE = '" + cCliente + "' "
    cQueryNF += "   AND SE1.E1_LOJA = '" + cLoja + "' "
    cQueryNF += "   AND SE1.E1_TIPO <> 'RA' " // Apenas títulos normais
    cQueryNF += "   AND SE1.E1_SALDO > 0 "
    cQueryNF += "   AND SE1.E1_BAIXA = ' ' "
    cQueryNF += " ORDER BY E1_VENCTO "

    cQueryNF := ChangeQuery(cQueryNF)
    DbUseArea(.T., "TOPCONN", MPSysOpenQuery(cQueryNF), cAliasNF, .F., .T.)

    If (cAliasNF)->(EoF())
        (cAliasNF)->(DbCloseArea())
        Return // Se não há títulos 'NF' para este cliente, vai para o próximo
    Endif

    // 3. Prepara o array para o FWMarkBrowse
    While !(cAliasNF)->(EoF())
        AAdd(aTitulosNF, { .F., ;  // Marca de seleção
                           (cAliasNF)->E1_PREFIXO, ;
                           (cAliasNF)->E1_NUM, ;
                           (cAliasNF)->E1_PARCELA, ;
                           (cAliasNF)->E1_EMISSAO, ;
                           (cAliasNF)->E1_VENCTO, ;
                           (cAliasNF)->E1_SALDO, ;
                           (cAliasNF)->R_E_C_N_O_ }) // Guarda o RECNO para usar depois
        (cAliasNF)->(DbSkip())
    Enddo
    (cAliasNF)->(DbCloseArea())

    // 4. Exibe o FWMarkBrowse para o usuário selecionar os títulos
    oBrowse := FWMarkBrowse():New()
    oBrowse:SetAlias(cAliasNF) // Apenas para estrutura, o conteúdo vem do array
    oBrowse:SetArray(aTitulosNF)
    oBrowse:SetHeader({ "Sel.", "Prefixo", "Título", "Parc.", "Emissão", "Venc.", "Saldo" })
    oBrowse:SetTitle("Selecione os títulos a compensar para o Cliente: " + cCliente + "/" + cLoja)
    oBrowse:Activate()

    aTitulosNF := oBrowse:GetMarked() // Pega apenas os itens marcados

    // Se o usuário selecionou algum título, continua
    If !Empty(aTitulosNF)
        // Extrai os RECNOs dos títulos selecionados
        For nX := 1 To Len(aTitulosNF)
            AAdd(aRecsNF, aTitulosNF[nX][8]) // Posição 8 contém o RECNO
        Next

        // 5. Executa a compensação com os títulos selecionados
        PERGUNTE("FIN330", .F.)
        lContabiliza := (MV_PAR09 == 1)
        lDigita      := (MV_PAR07 == 1)
        lAglutina    := .F. // Conforme seu código original

        // Chama a função de baixa, passando os RECNOs dos RAs e dos NFs selecionados
        If !MaIntBxCR(3, aRecsNF, , aRecsRA, , {lContabiliza, lAglutina, lDigita, .F., .F., .F.}, , , , , Nil, , , , ,)
            FWAlertError("Falha na compensação para o cliente: " + cCliente + "/" + cLoja, "Erro na Baixa")
        Endif
    Endif

    FwRestArea(aArea)

Return

/*-------------------------------------------------------------------
| fGetRecnosRA(cCliente, cLoja)
|-------------------------------------------------------------------
| Retorna um array com os RECNOs de todos os adiantamentos (RA)
| em aberto para um cliente/loja específico.
|-----------------------------------------------------------------*/
Static Function fGetRecnosRA(cCliente, cLoja)

    Local cQueryRA  := ""
    Local cAliasRA  := GetNextAlias()
    Local aRecnos   := {}

    cQueryRA := " SELECT R_E_C_N_O_ "
    cQueryRA += " FROM " + RetSqlName("SE1") + " SE1 "
    cQueryRA += " WHERE SE1.D_E_L_E_T_ = ' ' "
    cQueryRA += "   AND SE1.E1_FILIAL = '" + FWxFilial('SE1') + "' "
    cQueryRA += "   AND SE1.E1_CLIENTE = '" + cCliente + "' "
    cQueryRA += "   AND SE1.E1_LOJA = '" + cLoja + "' "
    cQueryRA += "   AND SE1.E1_TIPO = 'RA' "
    cQueryRA += "   AND SE1.E1_SALDO > 0 "
    cQueryRA += "   AND SE1.E1_BAIXA = ' ' "

    cQueryRA := ChangeQuery(cQueryRA)
    DbUseArea(.T., "TOPCONN", MPSysOpenQuery(cQueryRA), cAliasRA, .F., .T.)

    While !(cAliasRA)->(EoF())
        AAdd(aRecnos, (cAliasRA)->R_E_C_N_O_)
        (cAliasRA)->(DbSkip())
    Enddo

    (cAliasRA)->(DbCloseArea())

Return aRecnos
