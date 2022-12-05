#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM231.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 29/04/2014                                                          *
// Objetivo..: Programa principal que calcula o crédito adjudicado do Sistema.     *     
// Parâmetros: < Filial    > - Código da Filial                                    * 
//             < Pedido    > - Nº do Pedido de Venda                               *
//             < Item PV   > - Item do Pedido de Venda                             *
//             < Produto   > - Código do Produto                                   *
//             < Tela      > - 0 - Não Abre a tela de visualização dos dados       *
//                             1 - Abre tela de visualização dos dados             * 
//             < Chamado   > - Indica de onde foi chamado o processo               *
//             < TES       > - TES utilizada no produto                            *
//             < Quantidade> - Quantidade do produto                               *
//**********************************************************************************

// Função que define a Window
User Function AUTOM231( __Filial, __Pedido, __Item, __Produto, __Tela, __Chamado, __TES, __Quantidade)

   Local lChumba     := .F.
   Local cSql        := ""
   Local cPedido     := ""
   Local cProduto    := ""
   Local cNFentrada  := ""
   Local cDataEntra  := ""
   Local cFornecedor := ""
   Local cUFEntrada  := ""
   Local cGProduto   := ""
   Local cNPedido	 := ""
   Local cDEmissao	 := ""
   Local cCliente	 := ""
   Local cUFVenda	 := ""
   Local cGCliente	 := ""
   Local cCFOP  	 := ""
   Local cBase	     := 0
   Local cQEntrada	 := 0
   Local cQVenda	 := 0
   Local cAliquota	 := GetMv("MV_ICMPAD")
   Local cCredito    := 0

   Local cMemo1	 := ""
   Local cRegra	 := ""

   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5
   Local oGet6
   Local oGet7
   Local oGet8
   Local oGet9
   Local oGet10
   Local oGet11
   Local oGet12
   Local oGet13
   Local oGet14
   Local oGet15
   Local oGet16
   Local oGet17
   Local oGet18   

   Local oMemo1
   Local oMemo2

   Private oDlgAdj

   U_AUTOM628("AUTOM231")
   
   // Pedido de Venda
   If __Chamado == "PV"

      // Pesquisa dados do pedido conforme parâmetros passados ao programa
      If Select("T_PEDIDO") > 0
         T_PEDIDO->( dbCloseArea() )
      EndIf
   
      cSql := ""
      cSql := "SELECT SC6.C6_FILIAL ,"
      cSql += "       SC6.C6_NUM    ,"
      cSql += "       SC6.C6_CLI    ,"
      cSql += "       SC6.C6_LOJA   ,"
      cSql += "       SC6.C6_ITEM   ,"
      cSql += "       SC6.C6_PRODUTO,"
      cSql += "       SC6.C6_DESCRI ,"
      cSql += "       SC6.C6_CF     ,"
      cSql += "       SC6.C6_QTDVEN ,"
      cSql += "       SC5.C5_EMISSAO,"
      cSql += "       SA1.A1_NOME   ,"
      cSql += "       SA1.A1_EST    ,"
      cSql += "       SA1.A1_GRPTRIB "
      cSql += "  FROM " + RetSqlName("SC6") + " SC6, "
      cSql += "       " + RetSqlName("SC5") + " SC5, "
      cSql += "       " + RetSqlName("SA1") + " SA1  "
      cSql += " WHERE SC6.D_E_L_E_T_ = ''"
      cSql += "   AND SC6.C6_FILIAL  = '" + Alltrim(__Filial)  + "'"
      cSql += "   AND SC6.C6_NUM     = '" + Alltrim(__Pedido)  + "'"
      cSql += "   AND SC6.C6_PRODUTO = '" + Alltrim(__Produto) + "'"
      cSql += "   AND SC6.C6_ITEM    = '" + Alltrim(__Item)    + "'"
      cSql += "   AND SC6.D_E_L_E_T_ = ''"
      cSql += "   AND SC6.C6_FILIAL  = SC5.C5_FILIAL"
      cSql += "   AND SC6.C6_NUM     = SC5.C5_NUM   "
      cSql += "   AND SC5.D_E_L_E_T_ = ''           "
      cSql += "   AND SA1.A1_COD     = SC6.C6_CLI   "
      cSql += "   AND SA1.A1_LOJA    = SC6.C6_LOJA  "
      cSql += "   AND SA1.D_E_L_E_T_ = ''           "
   
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDO", .T., .T. )

      If T_PEDIDO->( EOF() )
         Return 0
      Endif
      
   Endif   
      
   // Carrega as variáveis para cálculo do crédito adjudicado
   Do Case
      Case __Chamado == "PV"
           cPedido   := T_PEDIDO->C6_NUM
           cProduto  := Alltrim(T_PEDIDO->C6_PRODUTO) + " - " + Alltrim(T_PEDIDO->C6_DESCRI)
           cNPedido	 := T_PEDIDO->C6_NUM
           cDEmissao := T_PEDIDO->C5_EMISSAO
           cCliente	 := Alltrim(T_PEDIDO->C6_CLI) + "." + Alltrim(T_PEDIDO->C6_LOJA) + " - " + Alltrim(T_PEDIDO->A1_NOME)
           cUFVenda	 := T_PEDIDO->A1_EST
           cGCliente := T_PEDIDO->A1_GRPTRIB
           cCFOP  	 := T_PEDIDO->C6_CF
      Case __Chamado == "PC"
           cPedido   := ""
           cProduto  := ""
           cNPedido	 := ""
           cDEmissao := ""
           cCliente	 := ""
           cUFVenda	 := Posicione("SA1", 1, xFilial("SA1") + M->ADY_CODIGO + M->ADY_LOJA, "A1_EST")
           cGCliente := Posicione("SA1", 1, xFilial("SA1") + M->ADY_CODIGO + M->ADY_LOJA, "A1_GRPTRIB")
           cCFOP  	 := Posicione("SF4", 1, xFilial("SF4") + __TES, "F4_CF")
      Case __Chamado == "CC"
           cPedido   := ""
           cProduto  := ""
           cNPedido	 := ""
           cDEmissao := ""
           cCliente	 := ""
           cUFVenda	 := Posicione("SA1", 1, xFilial("SA1") + M->UA_CLIENTE + M->UA_LOJA, "A1_EST")
           cGCliente := Posicione("SA1", 1, xFilial("SA1") + M->UA_CLIENTE + M->UA_LOJA, "A1_GRPTRIB")
           cCFOP  	 := Posicione("SF4", 1, xFilial("SF4") + __TES, "F4_CF")
   EndCase            

   // Pesquisa dados da útlima entrada do produto
   If Select("T_ULTIMA") > 0
      T_ULTIMA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT TOP 1 SD1.D1_DOC    ,"
   cSql += "             SD1.D1_DTDIGIT,"
   cSql += "             SD1.D1_BRICMS ,"
   cSql += "             SD1.D1_VALICM ,"
   cSql += "             SD1.D1_QUANT  ,"
   cSql += "             SD1.D1_ICMSRET,"
   cSql += "             SD1.D1_FORNECE,"
   cSql += "             SD1.D1_LOJA   ,"
   cSql += "             SA2.A2_NOME   ,"
   cSql += "             SA2.A2_EST    ,"
   cSql += "             SD1.D1_COD    ,"
   cSql += "             SB1.B1_GRTRIB  "
   cSql += "  FROM " + RetSqlName("SD1") + " SD1, "
   cSql += "       " + RetSqlName("SA2") + " SA2, "
   cSql += "       " + RetSqlName("SB1") + " SB1  "
   cSql += " WHERE SD1.D_E_L_E_T_ = ''"
   cSql += "   AND SD1.D1_PEDIDO <> ''" 
   cSql += "   AND SD1.D1_TIPO    = 'N'" 

   Do Case
      Case __Chamado == "PV"
           cSql += "   AND SD1.D1_COD     = '" + Alltrim(T_PEDIDO->C6_PRODUTO) + "'"
      Case __Chamado == "PC"
           cSql += "   AND SD1.D1_COD     = '" + Alltrim(__Produto) + "'"
      Case __Chamado == "CC"
           cSql += "   AND SD1.D1_COD     = '" + Alltrim(__Produto) + "'"
   EndCase           

   cSql += "   AND SD1.D1_FORNECE = SA2.A2_COD "
   cSql += "   AND SD1.D1_LOJA    = SA2.A2_LOJA"
   cSql += "   AND SA2.D_E_L_E_T_ = ''         "
   cSql += "   AND SD1.D1_COD     = SB1.B1_COD "
   cSql += "   AND SB1.D_E_L_E_T_ = ''         "
   cSql += " ORDER BY SD1.D1_EMISSAO DESC      "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ULTIMA", .T., .T. )

   If T_ULTIMA->( EOF() )
      cNFentrada  := ""
      cDataEntra  := ""
      cFornecedor := ""
      cUFEntrada  := ""
      cGProduto   := ""
      cBase	      := 0
      cQEntrada	  := 0
      cQVenda	  := 0
      cAliquota	  := 0
      cCredito    := 0
   Else
      cNFentrada  := T_ULTIMA->D1_DOC
      cDataEntra  := Substr(T_ULTIMA->D1_DTDIGIT,07,02) + "/" + Substr(T_ULTIMA->D1_DTDIGIT,05,02) + "/" + Substr(T_ULTIMA->D1_DTDIGIT,01,04)
      cFornecedor := T_ULTIMA->A2_NOME
      cUFEntrada  := T_ULTIMA->A2_EST
      cGProduto   := T_ULTIMA->B1_GRTRIB
      cBase	      := T_ULTIMA->D1_BRICMS
      cQEntrada	  := T_ULTIMA->D1_QUANT

      Do Case
         Case __Chamado == "PV"
              cQVenda := T_PEDIDO->C6_QTDVEN
         Case __Chamado == "PC"
              cQVenda := __Quantidade
         Case __Chamado == "CC"
              cQVenda := __Quantidade
      EndCase        

      // Aplica a regra para o cálculo
      cCredito := 0

  	  If Alltrim(cUFEntrada) <> Alltrim(SM0->M0_ESTENT)      
         If Alltrim(cGProduto) <> "017"
     	    If Alltrim(cUFVenda) <> Alltrim(SM0->M0_ESTENT)               
               If Alltrim(cGCliente) <> "003"
                  If cCFOP <> "5108" .And. cCFOP <> "6108"
//                   cCredito := Round((((cbase / cQEntrada) * cQVenda) * cAliquota) / 100,2)

                     // ########################################################################
                     // Nova regra de cálculo alterada por solicitação do Roger em 15/12/2016 ##
                     // ########################################################################
                     cCredito := Round((((T_ULTIMA->D1_ICMSRET / T_ULTIMA->D1_QUANT) + (T_ULTIMA->D1_VALICM / T_ULTIMA->D1_QUANT)) * cQVenda),2)
                  Endif
               Endif
            Endif
         Endif
      Endif

      // Pesquisa a descrição do grupo tributário do cliente
      If Select("T_TRIBUTARIO") > 0
         T_TRIBUTARIO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT X5_DESCRI"
      cSql += "  FROM " + RetSqlName("SX5")
      cSql += " WHERE X5_TABELA  = '21'"
      cSql += "   AND X5_CHAVE   = '" + Alltrim(cGProduto) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"
 
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TRIBUTARIO", .T., .T. )

      cGProduto := cGProduto + " - " + Alltrim(T_TRIBUTARIO->X5_DESCRI)

   Endif

   Do Case
      Case __Chamado == "PC"
           Return(cCredito)
      Case __Chamado == "CC"
           Return(cCredito)
   EndCase

   // Preenche a regra de cálculo do crédito adjudicado
   cRera  := ""
   cRegra := "ENTRADA DA MERCADORIA" + chr(13) + chr(10) + chr(13) + chr(10)
   cRegra += "UF do Fornecedor diferente da UF da Empresa Logada" + chr(13) + chr(10)
   cRegra += "Grupo Tributário do Produto diferente de 017" + chr(13) + chr(10) + chr(13) + chr(10)
   cRegra += "NA VENDA"  + chr(13) + chr(10) + chr(13) + chr(10)
   cRegra += "UF do Cliente diferente da UF da Empresa Logada"  + chr(13) + chr(10)
   cRegra += "Grupo Tributário do Cliente diferente de 003 - IE ISENTO"  + chr(13) + chr(10)
   cRegra += "CFOP diferente de 5108 e 6108" + chr(13) + chr(10)
   
   // Pesquisa a descrição do grupo tributário do cliente
   If Select("T_TRIBUTARIO") > 0
      T_TRIBUTARIO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT X5_DESCRI"
   cSql += "  FROM " + RetSqlName("SX5")
   cSql += " WHERE X5_TABELA  = '88'"
   cSql += "   AND X5_CHAVE   = '" + Alltrim(cGCliente) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
 
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TRIBUTARIO", .T., .T. )

   cGCliente := cGCliente + " - " + Alltrim(T_TRIBUTARIO->X5_DESCRI)

   // Caso tipo == 0, somente devolve o valor do crédito adjudicado
   If __Tela == 0
      Return(cCredito)
   Endif

   // Display dos valores do cálculo do crédito adjudicado
   DEFINE MSDIALOG oDlgAdj TITLE "Cálculo Crédito Adjudicado" FROM C(186),C(190) TO C(611),C(939) PIXEL

   @ C(010),C(010) Jpeg FILE "logoautoma.bmp" Size C(144),C(040) PIXEL NOBORDER OF oDlgAdj

   @ C(003),C(305) Say "CÁLCULO CRÉDITO ADJUDICADO"  Size C(086),C(008) COLOR CLR_BLACK PIXEL OF oDlgAdj

   @ C(012),C(166) Say "Pedido Venda"                Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlgAdj
   @ C(027),C(166) Say "Produto"                     Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgAdj
   @ C(049),C(005) Say "DADOS DA ENTRADA"            Size C(057),C(008) COLOR CLR_BLACK PIXEL OF oDlgAdj
   @ C(061),C(005) Say "Última NF Entrada"           Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlgAdj
   @ C(061),C(053) Say "Data Entrada"                Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgAdj
   @ C(061),C(098) Say "Fornecedor"                  Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgAdj
   @ C(061),C(242) Say "UF"                          Size C(008),C(008) COLOR CLR_BLACK PIXEL OF oDlgAdj
   @ C(061),C(261) Say "Grupo Tributário do Produto" Size C(069),C(008) COLOR CLR_BLACK PIXEL OF oDlgAdj
   @ C(088),C(005) Say "DADOS DA VENDA"              Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgAdj
   @ C(101),C(005) Say "Pedido Venda"                Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgAdj
   @ C(101),C(053) Say "Data Pedido"                 Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgAdj
   @ C(101),C(098) Say "Cliente"                     Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgAdj
   @ C(101),C(242) Say "UF"                          Size C(008),C(008) COLOR CLR_BLACK PIXEL OF oDlgAdj
   @ C(101),C(261) Say "Grupo Tributário do Cliente" Size C(064),C(008) COLOR CLR_BLACK PIXEL OF oDlgAdj
   @ C(101),C(350) Say "CFOP"                        Size C(017),C(008) COLOR CLR_BLACK PIXEL OF oDlgAdj
   @ C(128),C(005) Say "FÓRMULA"                     Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgAdj
   @ C(141),C(005) Say "((Base do ICMS Entrada / Quantidade de Entrada) * Quantidade Vendida ) * Alíquota Estado Empresa Logada" Size C(263),C(008) COLOR CLR_BLACK PIXEL OF oDlgAdj
   @ C(155),C(005) Say "CRÉDITO ADJUDICADO"          Size C(064),C(008) COLOR CLR_BLACK PIXEL OF oDlgAdj
   @ C(169),C(005) Say "Base do ICMS Entrada"        Size C(056),C(008) COLOR CLR_BLACK PIXEL OF oDlgAdj
   @ C(169),C(065) Say "Qtd de Entrada"              Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgAdj
   @ C(169),C(108) Say "Qtd de Venda"                Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgAdj
   @ C(169),C(150) Say "Alq Estado"                  Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgAdj
   @ C(169),C(183) Say "Crédito Adjudicado"          Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlgAdj
   @ C(123),C(242) Say "Regra de Cálculo do Crédito Adjudicado" Size C(097),C(008) COLOR CLR_BLACK PIXEL OF oDlgAdj

   @ C(042),C(000) GET oMemo1 Var cMemo1 MEMO Size C(374),C(001) PIXEL OF oDlgAdj

   @ C(011),C(205) MsGet oGet17 Var cPedido     When lChumba Size C(031),C(009) COLOR CLR_BLACK Picture "@!"              PIXEL OF oDlgAdj
   @ C(026),C(205) MsGet oGet18 Var cProduto    When lChumba Size C(168),C(009) COLOR CLR_BLACK Picture "@!"              PIXEL OF oDlgAdj
   @ C(071),C(005) MsGet oGet1  Var cNFentrada  When lChumba Size C(042),C(009) COLOR CLR_BLACK Picture "@!"              PIXEL OF oDlgAdj
   @ C(071),C(053) MsGet oGet2  Var cDataEntra  When lChumba Size C(039),C(009) COLOR CLR_BLACK Picture "@!"              PIXEL OF oDlgAdj
   @ C(071),C(098) MsGet oGet3  Var cFornecedor When lChumba Size C(138),C(009) COLOR CLR_BLACK Picture "@!"              PIXEL OF oDlgAdj
   @ C(071),C(242) MsGet oGet4  Var cUFEntrada  When lChumba Size C(013),C(009) COLOR CLR_BLACK Picture "@!"              PIXEL OF oDlgAdj
   @ C(071),C(261) MsGet oGet5  Var cGProduto   When lChumba Size C(112),C(009) COLOR CLR_BLACK Picture "@!"              PIXEL OF oDlgAdj
   @ C(111),C(005) MsGet oGet6  Var cNPedido    When lChumba Size C(042),C(009) COLOR CLR_BLACK Picture "@!"              PIXEL OF oDlgAdj
   @ C(111),C(053) MsGet oGet7  Var cDEmissao   When lChumba Size C(039),C(009) COLOR CLR_BLACK Picture "@!"              PIXEL OF oDlgAdj
   @ C(111),C(098) MsGet oGet8  Var cCliente    When lChumba Size C(138),C(009) COLOR CLR_BLACK Picture "@!"              PIXEL OF oDlgAdj
   @ C(111),C(242) MsGet oGet9  Var cUFVenda    When lChumba Size C(013),C(009) COLOR CLR_BLACK Picture "@!"              PIXEL OF oDlgAdj
   @ C(111),C(261) MsGet oGet10 Var cGCliente   When lChumba Size C(086),C(009) COLOR CLR_BLACK Picture "@!"              PIXEL OF oDlgAdj
   @ C(111),C(350) MsGet oGet11 Var cCFOP       When lChumba Size C(010),C(009) COLOR CLR_BLACK Picture "@!"              PIXEL OF oDlgAdj
   @ C(179),C(005) MsGet oGet12 Var cBase       When lChumba Size C(054),C(009) COLOR CLR_BLACK Picture "@E 9,999,999.99" PIXEL OF oDlgAdj
   @ C(179),C(065) MsGet oGet13 Var cQEntrada   When lChumba Size C(036),C(009) COLOR CLR_BLACK Picture "@E 9,999,999.99" PIXEL OF oDlgAdj
   @ C(179),C(108) MsGet oGet14 Var cQVenda     When lChumba Size C(036),C(009) COLOR CLR_BLACK Picture "@E 9,999,999.99" PIXEL OF oDlgAdj
   @ C(179),C(150) MsGet oGet15 Var cAliquota   When lChumba Size C(026),C(009) COLOR CLR_BLACK Picture "@E 999.99"       PIXEL OF oDlgAdj
   @ C(179),C(183) MsGet oGet16 Var cCredito    When lChumba Size C(045),C(009) COLOR CLR_BLACK Picture "@E 9,999,999.99" PIXEL OF oDlgAdj

   @ C(132),C(242) GET oMemo2 Var cRegra MEMO Size C(131),C(076) PIXEL OF oDlgAdj

   @ C(194),C(108) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgAdj ACTION( oDlgAdj:End() )

   ACTIVATE MSDIALOG oDlgAdj CENTERED 

Return(cCredito)