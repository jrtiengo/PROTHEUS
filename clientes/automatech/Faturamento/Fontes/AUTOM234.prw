#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM234.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 15/05/2014                                                          *
// Objetivo..: Programa que permite alterar a Condição de Pagamento e a Forma de   *
//             Pagamento de Pedidos de Venda antes do faturamento.                 *
//**********************************************************************************

User Function AUTOM234()

   Local lChumba     := .F.

   Private lAbre     := .F.
   Private aComboBx1 := U_AUTOM539(2, cEmpAnt)

   Private aComboBx2 := {"1 - Boleto","2 - Cartão"}

   Private cComboBx1
   Private cComboBx2
   Private oStatus

   Private cPedido	 := Space(006)
   Private cCliente	 := Space(100)
   Private cCondicao := Space(003)
   Private nCondicao := Space(100)
   Private cStatus	 := Space(100)

   Private cMemo1	 := ""
   Private cMemo2	 := ""
   Private cMemo3	 := ""
   Private cStatus	 := ""

   Private oGet1
   Private oGet2
   Private oGet4

   Private oMemo1
   Private oMemo2
   Private oMemo3
   Private oMemo4
   
   Private oDlg

   U_AUTOM628("AUTOM234")
   
   DEFINE MSDIALOG oDlg TITLE "Alteração Pedido Venda" FROM C(178),C(181) TO C(497),C(762) PIXEL

   @ C(010),C(005) Jpeg FILE "logoautoma.bmp" Size C(138),C(040) PIXEL NOBORDER OF oDlg

   @ C(035),C(210) Say "ALTERAÇÃO DE PEDIDO DE VENDA" Size C(093),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(048),C(005) Say "Filial"                       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(048),C(100) Say "Nº do PV"                     Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(048),C(141) Say "Status do PV"                 Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(094),C(005) Say "Cliente"                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(114),C(005) Say "Forma Pagamento"              Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(114),C(082) Say "Cond. Pagtº."                 Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(044),C(005) GET      oMemo1 Var cMemo1 MEMO Size C(279),C(001) PIXEL OF oDlg
   @ C(089),C(005) GET      oMemo2 Var cMemo2 MEMO Size C(279),C(001) PIXEL OF oDlg
   @ C(138),C(005) GET      oMemo3 Var cMemo3 MEMO Size C(279),C(001) PIXEL OF oDlg
   
   @ C(057),C(005) ComboBox cComboBx1 Items aComboBx1    Size C(089),C(010)                              PIXEL OF oDlg
   @ C(057),C(100) MsGet    oGet1     Var   cPedido      Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(057),C(141) GET      oMemo4    Var   cStatus MEMO Size C(143),C(028)                              PIXEL OF oDlg When lAbre

   @ C(072),C(059) Button "Pesquisar"                 Size C(037),C(012) PIXEL OF oDlg When !lAbre ACTION( PsqPedCond() )
   @ C(072),C(100) Button "Nova Pesq."                Size C(037),C(012) PIXEL OF oDlg When lAbre  ACTION( LmpTela() )

   @ C(102),C(005) MsGet    oGet2 Var       cCliente  Size C(279),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(123),C(005) ComboBox cComboBx2 Items aComboBx2 Size C(072),C(010)                              PIXEL OF oDlg When lAbre
   @ C(123),C(082) MsGet    oGet3 Var       cCondicao Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lAbre F3("SE4") VALID( PsqCondicao() )
   @ C(123),C(110) MsGet    oGet4 Var       nCondicao Size C(174),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(143),C(108) Button "Salvar" Size C(037),C(012) PIXEL OF oDlg ACTION( SlvPedCond() )
   @ C(143),C(148) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que pesquisa a condição de pagamento informada
Static Function PsqCondicao()

   If Empty(Alltrim(cCondicao))
      cCondicao := Space(003)
      nCondicao := Space(100)
      oGet3:Refresh()
      oGet4:Refresh()
      Return(.T.) 
   Endif

   nCondicao := Posicione( "SE4", 1, xFilial("SE4") + cCondicao, "E4_DESCRI" )
   
Return(.T.)   

// Função que pesquisa o pedido informado
Static Function PsqPedCond()

   Local cSql      := ""
   Local lFaturado := .F.
   
   If Substr(cComboBx1,01,02) == "00"
      MsgAlert("Filial não selecionada para pesquisa.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cPedido))
      MsgAlert("Pedido de Venda não informado para pesquisa.")
      Return(.T.)
   Endif

   // Pesquisa o pedido de venda informado
   If Select("T_PEDIDO") > 0
      T_PEDIDO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC5.C5_FILIAL ," 
   cSql += "       SC5.C5_NUM    ,"
   cSql += "       SC5.C5_FORMA  ,"
   cSql += "       SC5.C5_CONDPAG,"
   cSql += "       SE4.E4_DESCRI ,"
   cSql += "       SC5.C5_CLIENTE,"
   cSql += "       SC5.C5_LOJACLI," 
   cSql += "       SA1.A1_NOME    "
   cSql += "  FROM " + RetSqlName("SC5") + " SC5, "
   cSql += "       " + RetSqlName("SA1") + " SA1, "
   cSql += "       " + RetSqlName("SE4") + " SE4  "
   cSql += " WHERE SC5.C5_FILIAL  = '" + Alltrim(Substr(cComboBx1,01,02)) + "'"
   cSql += "   AND SC5.C5_NUM     = '" + Alltrim(cPedido) + "'"
   cSql += "   AND SC5.D_E_L_E_T_ = ''"
   cSql += "   AND SC5.C5_CLIENTE = SA1.A1_COD"
   cSql += "   AND SC5.C5_LOJACLI = SA1.A1_LOJA"
   cSql += "   AND SA1.D_E_L_E_T_ = ''"
   cSql += "   AND SC5.C5_CONDPAG = E4_CODIGO"
   cSql += "   AND SE4.D_E_L_E_T_ = ''"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDO", .T., .T. )

   If T_PEDIDO->( EOF() )
      MsgAlert("Não existem dados a serem visualizados para este Pedido/Filial.")
      Return(.T.)
   Endif
      
   // Verifica se pedido pode ser alterado
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT C6_FILIAL,"
   cSql += "       C6_NUM   ,"
   cSql += "       C6_STATUS "
   cSql += "  FROM " + RetSqlName("SC6")
   cSql += " WHERE C6_FILIAL  = '" + Alltrim(Substr(cComboBx1,01,02)) + "'"
   cSql += "  AND C6_NUM      = '" + Alltrim(cPedido) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )
   
   If T_PRODUTOS->( EOF() )
      MsgAlert("Ítens do Pedido de Venda não localizado.")
      Return(.T.)
   Endif

   // Verifica se pedido possui pelo meno um item faturado. Se existir, não permite alteração.
   cStatus := ""
   lFaturado := .F.
   T_PRODUTOS->( DbGoTop() )
   WHILE !T_PRODUTOS->( EOF() )
      If Alltrim(T_PRODUTOS->C6_STATUS) >= "11"
         lFaturado := .T.
         Exit
      Endif

      Do Case
         Case Alltrim(T_PRODUTOS->C6_STATUS) == "01"
              If U_P_OCCURS(cStatus, "01-Aguardando Liberação", 1) == 0
                 cStatus := cStatus + "01-Aguardando Liberação" + chr(13) + chr(10)
              Endif   
         Case Alltrim(T_PRODUTOS->C6_STATUS) == "02"
              If U_P_OCCURS(cStatus, "02-Aguardando Liberação Margem", 1) == 0
                 cStatus := cStatus + "02-Aguardando Liberação Margem" + chr(13) + chr(10)
              Endif
         Case Alltrim(T_PRODUTOS->C6_STATUS) == "03"
              If U_P_OCCURS(cStatus, "03-Aguardando Liberação de Credito", 1) == 0
                 cStatus := cStatus + "03-Aguardando Liberação de Credito" + chr(13) + chr(10)
              Endif
         Case Alltrim(T_PRODUTOS->C6_STATUS) == "04"
              If U_P_OCCURS(cStatus, "04-Aguardando Liberação de Estoque", 1) == 0
                 cStatus := cStatus + "04-Aguardando Liberação de Estoque" + chr(13) + chr(10)
              Endif   
         Case Alltrim(T_PRODUTOS->C6_STATUS) == "05"
              If U_P_OCCURS(cStatus, "05-Aguardando data de entrega", 1) == 0
                 cStatus := cStatus + "05-Aguardando data de entrega" + chr(13) + chr(10)
              Endif
         Case Alltrim(T_PRODUTOS->C6_STATUS) == "06"
              If U_P_OCCURS(cStatus, "06-Em compra", 1) == 0
                 cStatus := cStatus + "06-Em compra" + chr(13) + chr(10)
              Endif   
         Case Alltrim(T_PRODUTOS->C6_STATUS) == "07"
              If U_P_OCCURS(cStatus, "07-Em produção", 1) == 0
                 cStatus := cStatus + "07-Em produção" + chr(13) + chr(10)
              Endif   
         Case Alltrim(T_PRODUTOS->C6_STATUS) == "08"
              If U_P_OCCURS(cStatus, "08-Aguardando separação estoque", 1) == 0
                 cStatus := cStatus + "08-Aguardando separação estoque" + chr(13) + chr(10)
              Endif
         Case Alltrim(T_PRODUTOS->C6_STATUS) == "09"
              If U_P_OCCURS(cStatus, "09-Aguardando cliente", 1) == 0
                 cStatus := cStatus + "09-Aguardando cliente" + chr(13) + chr(10)
              Endif
         Case Alltrim(T_PRODUTOS->C6_STATUS) == "10"
              If U_P_OCCURS(cStatus, "10-Aguardando faturamento", 1) == 0
                 cStatus := cStatus + "10-Aguardando faturamento" + chr(13) + chr(10)
              Endif   
      EndCase

      T_PRODUTOS->( DbSkip() )

   ENDDO
   
   If lFaturado
      aAdd( aStatus, { " " } )
      MsgAlert("Pedido de Venda não poderá ser alterado pois já possui itens faturados.")
      Return(.T.)
   Endif

   cCliente	 := T_PEDIDO->C5_CLIENTE + "." + T_PEDIDO->C5_LOJACLI + " - " + alltrim(T_PEDIDO->A1_NOME)
   cCondicao := T_PEDIDO->C5_CONDPAG
   nCondicao := T_PEDIDO->E4_DESCRI
   cComboBx2 := IIF(T_PEDIDO->C5_FORMA == "1", "1 - Boleto", "2 - Cartão")

   oGet1:Refresh()
   oGet2:Refresh()
   oGet4:Refresh()

   oMemo4:Refresh()

   lAbre := .T.
   
Return(.T.)

// Função que grava as alterações efetuadas
Static Function SlvPedCond()

   // Consiste se filial foi selecionada
   If Substr(cComboBx1,01,02) == "00"
      MsgAlert("Filial não selecionada.")
      Return(.T.)
   Endif
      
   // Consiste se pedido foi informado
   If Empty(Alltrim(cPedido))
      MsgAlert("Pedido de Venda não informado.")
      Return(.T.)
   Endif

   // Consiste se condição de pagamento foi informada
   If Empty(Alltrim(cCondicao))
      MsgAlert("Condição de Pagamenbto não informada.")
      Return(.T.)
   Endif

   // Grava os dados no cabeçalho do pedido de venda/filial selecionado	
   DbSelectArea("SC5")
   DbSetOrder(1)
   DbSeek( Substr( cComboBx1,01,02) + cPedido )
   Reclock("SC5", .F.)
   C5_FORMA   := Substr(cComboBx2,01,01)
   C5_CONDPAG := cCondicao
   Msunlock()

   // Limpa os campos da tela
   LmpTela()

Return(.T.)

// Função que limpa os campos da tela
Static Function LmpTela()

   lAbre     := .F.

   aComboBx1 := {}
   aComboBx2 := {}
   aComboBx1 := U_AUTOM539(2, cEmpAnt)
   aComboBx2 := {"1 - Boleto","2 - Cartão"}

   cPedido	 := Space(006)
   cCliente	 := Space(100)
   cCondicao := Space(003)
   nCondicao := Space(100)
   cStatus	 := ""

   oGet1:Refresh()
   oGet2:Refresh()
   oGet4:Refresh()
   oMemo4:Refresh()
   
Return(.T.)