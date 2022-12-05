#Include "Protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM121.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  (X) Gatilho  ( ) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 27/06/2012                                                          *
// Objetivo..: Gatilho responsável pela verificação se o cliente informado possui  *
//             tabela de preço indicada no cadastro de clientes. Caso  não  tenha  *
//             dá mensagem informando ao usuário que cliente não tem esta  infor-  *
//             ção, limpa o código e loja do cliente não permitindo que este cli-  *
//             ente seja utilizado.                                                *
// Parâmetros: < _Tipo >   - Indica de que gatilho foi chamado o programa          *
//                           1 - Chamado Técnico                                   *
//                           2 - Orçamento                                         *
//                           3 - Ordem de Serviço                                  *
//             < _Codigo > - Código do Cliente                                     *
//             < _Loja   > - Loja do Cliente                                       *
//**********************************************************************************

User Function AUTOM121(_Tipo, _Codigo, _Loja)

Local cSql     := ""
Local cDispMsg := GetMv("AUT_INADIP") // Parâmetro que habilita o disparo da mensagem de inadimplência do Cliente

If Empty(Alltrim(_Codigo))
	Return ""
Endif

// Verifica se cliente possui títulos em aberto no financeiro da Automatech
// Pesquisa possíveis parcelas em atraso

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Fabiano Pereira - Solutio IT 25/04/2014           ³
//³   Adicionado para verificar Titulos em Aberto para ³
//³   Chamado Tecnico, Orcamento e Ordem de Servico    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If _Tipo >= 1	//	_Tipo == 1

	If cDispMsg == "S"

		If Select("T_PARCELAS") > 0
			T_PARCELAS->( dbCloseArea() )
		EndIf
		
		cSql := ""
		cSql := "SELECT A.E1_CLIENTE ,"
		cSql += "       A.E1_LOJA    ,"
		cSql += "       A.E1_PREFIXO ,"
		cSql += "       A.E1_NUM     ,"
		cSql += "       A.E1_PARCELA ,"
		cSql += "       A.E1_EMISSAO ,"
		cSql += "       A.E1_VENCTO  ,"
		cSql += "       A.E1_BAIXA   ,"
		cSql += "       A.E1_VALOR   ,"
		cSql += "       A.E1_SALDO   ,"
		cSql += "       B.A1_NOME     "
		cSql += "  FROM " + RetSqlName("SE1") + " A, "
		cSql += "       " + RetSqlName("SA1") + " B  "
		cSql += " WHERE A.D_E_L_E_T_ = ''"
		cSql += "   AND A.E1_SALDO  <> 0 "
		cSql += "   AND A.E1_CLIENTE = '" + Alltrim(_Codigo) + "'"
		cSql += "   AND A.E1_LOJA    = '" + Alltrim(_Loja)    + "'"
		cSql += "   AND A.E1_VENCTO < CONVERT(DATETIME,'" + Dtoc(Date()) + "', 103)"
		cSql += "   AND (A.E1_TIPO   <> 'RA' AND A.E1_TIPO <> 'NCC')"
		cSql += "   AND B.A1_FILIAL = ''            "
		cSql += "   AND B.A1_COD      = A.E1_CLIENTE"
		cSql += "   AND B.A1_LOJA     = A.E1_LOJA   "
		cSql += "   AND B.D_E_L_E_T_  = ''          "
		
		cSql := ChangeQuery( cSql )
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARCELAS", .T., .T. )
		
		If !T_PARCELAS->( EOF() )
			MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "O Cliente " + Alltrim(T_PARCELAS->A1_NOME) + " possui títulos em aberto junto ao financeiro." + chr(13) + chr(10) + "Antes de finalizar a entrada do equipamento do Cliente, consulte seu gestor para maiores orientações.")
		Endif

	Endif
Endif

// Pesquisa tabela de preço do cliente informado
If Select("T_CLIENTE") > 0
	T_CLIENTE->( dbCloseArea() )
EndIf

cSql := "SELECT A1_COD   , "
cSql += "       A1_LOJA  , "
cSql += "       A1_TABELA, "
cSql += "       A1_DESC    "
cSql += "  FROM " + RetSqlName("SA1")
cSql += "  WHERE A1_COD  = '" + Alltrim(_Codigo) + "'"
cSql += "  AND A1_LOJA = '" + Alltrim(_Loja)     + "'"

cSql := ChangeQuery( cSql )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )

If T_CLIENTE->( EOF() )
	Return ""
Endif

If Empty(AllTrim(T_CLIENTE->A1_TABELA))

	MsgAlert("Atenção !!" + chr(13) + "Cliente informado não possui Tabela de Preço vinculada em seu cadastro. Verifique !!")

	Do Case
		Case _Tipo == 1
			M->AB1_CODCLI := Space(06)
			M->AB1_LOJA   := Space(03)
			M->AB1_DESC   := 0
		Case _Tipo == 2
			M->AB3_CODCLI := Space(06)
			M->AB3_LOJA   := Space(03)
			M->AB3_DESC1  := 0
		Case _Tipo == 3
			M->AB6_CODCLI := Space(06)
			M->AB6_LOJA   := Space(03)
			M->AB6_DESC1  := 0
	EndCase

	Return ""

Else

	Do Case
		Case _Tipo == 1
			M->AB1_DESC   := T_CLIENTE->A1_DESC
		Case _Tipo == 2
			M->AB3_DESC1  := T_CLIENTE->A1_DESC
		Case _Tipo == 3
			M->AB6_DESC1  := T_CLIENTE->A1_DESC
	EndCase

Endif

Return M->AB1_TABELA := T_CLIENTE->A1_TABELA