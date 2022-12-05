#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM156.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 25/02/2012                                                          *
// Objetivo..: Programa que verifica se o cliente informado na proposta comercial, *
//             Pedido de Call Center e Pedido de Venda possuem parcelas em atraso. *
//             Se existir, abre janela com os dados das parcelas em atraso.        *
// Parãmetros: Cliente, Loja, Tipo (Indica o tipo de mensagem a ser mostrada.      *
//**********************************************************************************

User Function AUTOM156(_Cliente, _Loja, _Tipo)

   Local cSql := ""

   Private oDlgS

   // ############################################################################################
   // Quando for compilar para o web service dos pedidos de venda, este return deve ser ativado ##
   // ############################################################################################
   // Return _Loja

   If Empty(Alltrim(_Cliente))
      Return _Loja
   Endif
       
   If Empty(Alltrim(_Loja))
      Return _Loja
   Endif

   If GetMv("MV_VEXE") == .T.
      Return _Loja      
   Endif   

   // Pesquisa possíveis parcelas em atraso
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
   cSql += "   AND A.E1_CLIENTE = '" + Alltrim(_Cliente) + "'"
   cSql += "   AND A.E1_LOJA    = '" + Alltrim(_Loja)    + "'"
   cSql += "   AND A.E1_VENCTO < CONVERT(DATETIME,'" + Dtoc(Date()) + "', 103)"
   cSql += "   AND A.E1_CLIENTE = B.A1_COD  "
   cSql += "   AND A.E1_LOJA    = B.A1_LOJA "
   cSql += "   AND (A.E1_TIPO   <> 'RA' AND A.E1_TIPO <> 'NCC')"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARCELAS", .T., .T. )

   If T_PARCELAS->( EOF() )
      Return _Loja
   Endif

   If _Tipo == 1

      DEFINE MSDIALOG oDlgS TITLE "Mensagem do Sistema" FROM C(178),C(181) TO C(295),C(566) PIXEL

      @ C(005),C(005) Say "Atenção!"                                                                  Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
      @ C(018),C(005) Say "O cliente informado possui pendências financeiras."                        Size C(122),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
      @ C(028),C(005) Say "Para maiores informações, entre em contato com o Departamento Financeiro." Size C(185),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
      @ C(039),C(005) Button "Histórico Consulta Serasa" Size C(090),C(012) PIXEL OF oDlgS ACTION( U_AUTOMR44( _Cliente, _Loja, T_PARCELAS->A1_NOME ) )
      @ C(039),C(148) Button "Voltar"                    Size C(037),C(012) PIXEL OF oDlgS ACTION( oDlgS:End() )

      ACTIVATE MSDIALOG oDlgS CENTERED 

   Else

      MsgAlert("Atenção!" + chr(13) + chr(13) + "Somente lembrando que o cliente informado possui pendências financeiras." + chr(13) + "Para maiores informações, contate o Departamento Financeiro.")   

   Endif
            
Return _Loja