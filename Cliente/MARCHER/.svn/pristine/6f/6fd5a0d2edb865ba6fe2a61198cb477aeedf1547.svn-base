#Include "TOTVS.ch"

/*/{Protheus.doc} SOLTADTAE
Programa que permite que a data de entrega do pedido de compra seja
alterada sem alterar o status do pedido de compra.
Somente para pedidos de compra pendentes de entrega.
@type function
@version 12.1.25
@author Harald Hans Löschenkohl
@since 04/07/2019
/*/
User Function SOLTADTAE()

	Local   lChumba     := .F.
	Local   cSql        := ""

	Private aMyCols     := {}
	Private aMyHeader   := {}
	Private aAcampos    := {'Data_Entrega'}
	Private cPedido     := SC7->C7_NUM
	Private cEmissao    := SC7->C7_EMISSAO
	Private cFornecedor := SC7->C7_FORNECE
	Private cLojaForne  := SC7->C7_LOJA
	Private cNomeForne  := POSICIONE("SA2",1,XFILIAL("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA, "A2_NOME")
	Private oBrwCpo
	Private oDlg
	Private oGet1
	Private oGet2
	Private oGet3
	Private oGet4
	Private oGet5

	// Cria o cabecalho do grid
	Aadd(aMyHeader, {'Item'        , 'Item'        , '!@', 04, 00, '', , 'C', "" })
	Aadd(aMyHeader, {'Produtos'    , 'Produtos'    , '!@', 30, 00, '', , 'C', "" })
	Aadd(aMyHeader, {'Descricao'   , 'Descricao'   , '!@', 30, 00, '', , 'C', "" })
	Aadd(aMyHeader, {'UND'         , 'Und'         , '!@', 02, 00, '', , 'C', "" })
	Aadd(aMyHeader, {'Data_Entrega', 'Data_Entrega', '!@', 10, 00, '', , 'D', "" })

	// Pesquisa os produtos do pedido de compra selecionado
	If Select("T_CONSULTA") > 0
		T_CONSULTA->( dbCloseArea() )
	EndIf

	cSql := "SELECT C7_ITEM   ,"
	cSql += "       C7_PRODUTO,"
	cSql += "       C7_DESCRI ,"
	cSql += "       C7_UM     ,"
	cSql += "       C7_DTFOLOW  "
	cSql += "  FROM " + RetSqlName("SC7")
	cSql += " WHERE C7_FILIAL = '" + Alltrim(cFilAnt) + "'"
	cSql += "   AND C7_NUM    = '" + Alltrim(cPedido) + "'"
	cSql += "   AND C7_QUANT <> C7_QUJE"
	cSql += "   AND D_E_L_E_T_ = ''"

	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )
	TCSetField( "T_CONSULTA", "C7_DTFOLOW", "D", 8, 0)

	T_CONSULTA->( DbGoTop() )

	If T_CONSULTA->( EOF() )
		MsgAlert("Atenção!" + CRLF + CRLF + ;
			"Pedido de Compra já atendido." + CRLF + ;
			"Alteração de Data de Entrega não permitida.")
		Return(.T.)
	Endif

	WHILE !T_CONSULTA->( EOF() )

		aAdd( aMyCols , { T_CONSULTA->C7_ITEM   ,;
			T_CONSULTA->C7_PRODUTO,;
			T_CONSULTA->C7_DESCRI ,;
			T_CONSULTA->C7_UM     ,;
			T_CONSULTA->C7_DTFOLOW,;
			.F.})

		T_CONSULTA->( DbSkip() )
	ENDDO
	T_CONSULTA->( dbCloseArea() )

	DEFINE MSDIALOG oDlg TITLE "Alteração Data de Entrega - Folow" FROM C(178),C(181) TO C(575),C(839) PIXEL

	@ C(002),C(005) Say "Nº Ped.Compra"                Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	@ C(002),C(048) Say "Data Emissão"                 Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	@ C(002),C(092) Say "Fornecedor"                   Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	@ C(023),C(005) Say "Produtos do Pedido de Compra" Size C(076),C(008) COLOR CLR_BLACK PIXEL OF oDlg

	@ C(012),C(005) MsGet oGet1 Var cPedido     Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
	@ C(012),C(048) MsGet oGet2 Var cEmissao    Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
	@ C(012),C(092) MsGet oGet3 Var cFornecedor Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
	@ C(012),C(124) MsGet oGet4 Var cLojaForne  Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
	@ C(012),C(146) MsGet oGet5 Var cNomeForne  Size C(178),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

	@ C(180),C(248) Button "Salvar" Size C(037),C(012) PIXEL OF oDlg ACTION( SalvaDtaEntrega() )
	@ C(180),C(287) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( Odlg:End() )

	// Monta o grid para edição
	oBrwCpo := MsNewGetDados():New(040,005,228,413,GD_UPDATE,,,,aAcampos,0,999,'U_RepData()',,,oDlg,aMyHeader,aMyCols )

	ACTIVATE MSDIALOG oDlg CENTERED

Return(.T.)


/*/{Protheus.doc} RepData
Função que replica a data informada nas demais linhas
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 17/12/2021
@return logical, .T. se a data estiver correta ou .F. caso contrario
/*/
User Function RepData()

//    Local nContar := 0
//    Local nTotReg := Len(oBrwCpo:aCols)
	Local dDtInf  := &( ReadVar() )
	Local lRet    := .T.

	If dDtInf < dDataBase
		MsgAlert( "Data de entrega deve ser maior ou igual a Data Atual !")
		lRet := .F.
		// Jorge Alberto - 11/01/2022 - #31305 - Comentada a replicação conforme solicitação da Jessica.
		//Else
		//   If nTotReg > 1
		//      If MsgYesNo( "Deseja replicar a data informada para os demais itens ?", "Replicar Data" )
		//         For nContar := oBrwCpo:nAt to nTotReg
		//            oBrwCpo:aCols[nContar,05] := dDtInf
		//         Next
		//      EndIf
		//      oBrwCpo:Refresh()
		//   EndIf
	EndIf

Return(lRet)


/*/{Protheus.doc} SalvaDtaEntrega
Função que grava as data de enytrega alteradas no grid
@type function
@version 12.1.25
@author Harald Hans Löschenkohl
@since 04/07/2019
/*/
Static Function SalvaDtaEntrega()

	Local nContar := 0

	DbSelectArea("SC7")
	DbSetOrder(1)
	For nContar := 1 to Len(oBrwCpo:aCols)
		If DbSeek( xFilial("SC7") + cPedido + oBrwCpo:aCols[nContar,01])
			Reclock("SC7",.F.)
			SC7->C7_DTFOLOW := oBrwCpo:aCols[nContar,05]
			MsUnlock()
		Endif
	Next nContar

	oDlg:End()

Return()
