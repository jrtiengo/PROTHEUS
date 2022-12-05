#Include "Protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM121.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: ( ) Programa  (X) Gatilho  ( ) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 27/06/2012                                                          *
// Objetivo..: Gatilho respons�vel pela verifica��o se o cliente informado possui  *
//             tabela de pre�o indicada no cadastro de clientes. Caso  n�o  tenha  *
//             d� mensagem informando ao usu�rio que cliente n�o tem esta  infor-  *
//             ��o, limpa o c�digo e loja do cliente n�o permitindo que este cli-  *
//             ente seja utilizado.                                                *
// Par�metros: < _Tipo >   - Indica de que gatilho foi chamado o programa          *
//                           1 - Chamado T�cnico                                   *
//                           2 - Or�amento                                         *
//                           3 - Ordem de Servi�o                                  *
//             < _Codigo > - C�digo do Cliente                                     *
//             < _Loja   > - Loja do Cliente                                       *
//**********************************************************************************

User Function AUTOM121(_Tipo, _Codigo, _Loja)

Local cSql     := ""
Local cDispMsg := GetMv("AUT_INADIP") // Par�metro que habilita o disparo da mensagem de inadimpl�ncia do Cliente

If Empty(Alltrim(_Codigo))
	Return ""
Endif

// Verifica se cliente possui t�tulos em aberto no financeiro da Automatech
// Pesquisa poss�veis parcelas em atraso

//����������������������������������������������������Ŀ
//�  Fabiano Pereira - Solutio IT 25/04/2014           �
//�   Adicionado para verificar Titulos em Aberto para �
//�   Chamado Tecnico, Orcamento e Ordem de Servico    �
//������������������������������������������������������
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
			MsgAlert("Aten��o!" + chr(13) + chr(10) + chr(13) + chr(10) + "O Cliente " + Alltrim(T_PARCELAS->A1_NOME) + " possui t�tulos em aberto junto ao financeiro." + chr(13) + chr(10) + "Antes de finalizar a entrada do equipamento do Cliente, consulte seu gestor para maiores orienta��es.")
		Endif

	Endif
Endif

// Pesquisa tabela de pre�o do cliente informado
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

	MsgAlert("Aten��o !!" + chr(13) + "Cliente informado n�o possui Tabela de Pre�o vinculada em seu cadastro. Verifique !!")

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