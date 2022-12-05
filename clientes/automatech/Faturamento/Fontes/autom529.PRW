#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

// #####################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                              ##
// ---------------------------------------------------------------------------------- ##
// Referencia: AUTOM529.PRW                                                           ##
// Parâmetros: Nenhum                                                                 ##
// Tipo......: (X) Programa  ( ) Gatilho                                              ##
// ---------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                ##
// Data......: 02/04/2013                                                             ##
// Objetivo..: Programa que abre janela de consulta de variáveis do cálculo da margem ##
//             dos produtos do pedido de venda utilizando o novo cálculo de margem.   ##
// #####################################################################################

User Function AUTOM529()

   Local lChumba  := .F.

   Local cRetorno := ""

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local cMemo3	 := ""
   Local cMemo4	 := ""
   Local cMemo5	 := ""
   Local cMemo6	 := ""

   Local oMemo1
   Local oMemo2
   Local oMemo3
   Local oMemo4
   Local oMemo5
   Local oMemo6

   Local cPedido       := Space(06)
   Local cCliente      := Space(06)
   Local cLoja 	       := Space(03)
   Local cNomeCli      := Space(60)
   Local cCidade	   := Space(40)
   Local cEstado	   := Space(02)
   Local cProduto	   := Space(30)
   Local cPartNumber   := Space(20)
   Local cNomeProduto  := Space(60)
   Local cCondicao     := Space(30)
   Local cTransporte   := Space(30)
   Local cTipoFrete    := Space(10)
   Local cTES	       := Space(30)
   Local cVendedor     := Space(30)
   Local cCustoInicial := 0
   Local cPIS	       := 0
   Local cCOFINS	   := 0
   Local cICMS	       := 0
   Local cCreditoAdj   := 0
   Local cCustoTotal   := 0
   Local cDIFAL        := 0
   Local cCustoADM	   := 0
   Local cPercADM 	   := 0
   Local cCustoComis   := 0
   Local cPercComis	   := 0
   Local cCustoFrete   := 0
   Local cPercFrete    := 0
   Local cCustoCond	   := 0
   Local cPercCond	   := 0
   Local cCustoCartao  := 0
   Local cPercCartao   := 0
   Local cMargem	   := 0
   Local cPercMargem   := 0
   Local lReal   	   := .F.
   Local lDolar 	   := .F.
   Local cDataCotacao  := Ctod("  /  /    ")
   Local cTaxaDolar    := 0
   Local cValorVenda   := 0
   Local cValorDifal   := 0
   Local cValorFrete   := 0
   Local cValorTotal   := 0
   Local oCheckBox1
   Local oCheckBox2
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
   Local oGet19
   Local oGet20
   Local oGet21
   Local oGet22
   Local oGet23
   Local oGet24
   Local oGet25
   Local oGet26
   Local oGet27
   Local oGet28
   Local oGet29
   Local oGet30
   Local oGet31
   Local oGet32
   Local oGet33
   Local oGet34
   Local oGet50
   Local oGet36
   Local oGet37
   Local oGet38

   Local nLinha := 0

   Private oDlg

   U_AUTOM628("AUTOM529")
   
   // #######################################
   // Pesquisa os dados do Pedido de Venda ##
   // #######################################
   If Select("T_PEDIDO") > 0
      T_PEDIDO->( dbCloseArea() )
   EndIf

   cSql := ""

   cSql := "SELECT SC5.C5_EMISSAO,"
   cSql += "       SC5.C5_FILIAL ,"
   cSql += "       SC5.C5_NUM    ,"
   cSql += "       SC5.C5_CONDPAG,"
   cSql += "       SE4.E4_DESCRI ,"
   cSql += "       SC5.C5_TRANSP ,"
   cSql += "      (SELECT A4_NOME FROM SA4010 WHERE A4_COD = SC5.C5_TRANSP AND D_E_L_E_T_ = '') AS NOMETRANSP, "
   cSql += "       SC5.C5_TPFRETE,"
   cSql += "       SC5.C5_FRETE  ,"
   cSql += "       SC5.C5_CLIENTE,"
   cSql += "       SC5.C5_LOJACLI,"
   cSql += "       SC5.C5_MOEDA  ,"
   cSql += "       SC5.C5_VEND1  ,"
   cSql += "      (SELECT A3_NOME FROM SA3010 WHERE A3_COD = SC5.C5_VEND1 AND A3_FILIAL = '  ' AND D_E_L_E_T_ = '') AS NOMEVENDEDOR,"
   cSql += "       SC5.C5_COMIS1 ,"
   cSql += "       SC5.C5_COMIS2 ,"
   cSql += "       SC5.C5_COMIS3 ,"
   cSql += "       SC5.C5_COMIS4 ,"
   cSql += "       SC5.C5_COMIS5 ,"         
   cSql += "       SA1.A1_NOME   ,"
   cSql += "       SA1.A1_EST    ,"
   cSql += "       SA1.A1_MUN    ,"
   cSql += "       SA1.A1_CEP    ,"
   cSql += "       SA1.A1_GRPTRIB,"
   cSql += "       SA1.A1_PESSOA  "
   cSql += "  FROM " + RetSqlName("SC5") + " SC5(Nolock)," 
   cSql += "       " + RetSqlName("SA1") + " SA1(Nolock),"
   cSql += "       " + RetSqlName("SE4") + " SE4(Nolock) "  
   cSql += " WHERE SC5.C5_FILIAL  = '" + Alltrim(SC6->C6_FILIAL) + "'"
   cSql += "   AND SC5.C5_NUM     = '" + Alltrim(SC6->C6_NUM)    + "'"
   cSql += "    AND SC5.D_E_L_E_T_ = ''            "
   cSql += "    AND SC5.C5_CLIENTE = SA1.A1_COD    "
   cSql += "    AND SC5.C5_LOJACLI = SA1.A1_LOJA   "
   cSql += "    AND SE4.E4_CODIGO  = SC5.C5_CONDPAG"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDO", .T., .T. )

   If T_PEDIDO->( EOF() )
      MsgAlert("Não existem dados a serem visualizados para este pedido de venda.")
      Return(.T.)
   Else
      cPedido       := T_PEDIDO->C5_NUM
      cCliente      := T_PEDIDO->C5_CLIENTE
      cLoja 	    := T_PEDIDO->C5_LOJACLI
      cNomeCli      := T_PEDIDO->A1_NOME
      cCidade	    := T_PEDIDO->A1_MUN
      cEstado	    := T_PEDIDO->A1_EST
      cProduto	    := SC6->C6_PRODUTO
      cPartNumber   := Posicione("SB1",1,xFilial("SB1") + SC6->C6_PRODUTO, "B1_PARNUM")
      cNomeProduto  := Alltrim(Posicione("SB1",1,xFilial("SB1") + SC6->C6_PRODUTO, "B1_DESC")) + " " + Alltrim(Posicione("SB1",1,xFilial("SB1") + SC6->C6_PRODUTO, "B1_DAUX"))
      cCondicao     := T_PEDIDO->E4_DESCRI
      cTransporte   := T_PEDIDO->NOMETRANSP

      Do Case
         Case T_PEDIDO->C5_TPFRETE == "C"
              cTipoFrete := "FRETE CIF"
         Case T_PEDIDO->C5_TPFRETE == "F"
              cTipoFrete := "FRETE FOB"
         Case T_PEDIDO->C5_TPFRETE == "T"
              cTipoFrete := "POR CONTA 3º"
         Case T_PEDIDO->C5_TPFRETE == "S"
              cTipoFrete := "SEM FRETE"
      EndCase              

      cTES	        := Posicione("SF4",1,xFilial("SF4") + SC6->C6_TES, "F4_TEXTO")
      cVendedor     := T_PEDIDO->NOMEVENDEDOR
   Endif

   // #############################################################################
   // Envia para o programa que calcula a margem do produto passado no parâmetro ##
   // #############################################################################
   cRetorno := U_AUTOM524(1, SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, SC6->C6_PRODUTO, 0, "V")

   cCustoInicial := Val(U_P_CORTA(cRetorno, "|",01)) 
   cPIS	         := Val(U_P_CORTA(cRetorno, "|",02)) 
   cCOFINS	     := Val(U_P_CORTA(cRetorno, "|",03)) 
   cICMS	     := Val(U_P_CORTA(cRetorno, "|",04)) 
   cCreditoAdj   := Val(U_P_CORTA(cRetorno, "|",05)) 
   cDIFAL        := Val(U_P_CORTA(cRetorno, "|",06)) 
   cCustoTotal   := Val(U_P_CORTA(cRetorno, "|",07))
   cCustoADM	 := Val(U_P_CORTA(cRetorno, "|",09)) 
   cPercADM 	 := Val(U_P_CORTA(cRetorno, "|",10)) 
   cCustoComis   := Val(U_P_CORTA(cRetorno, "|",15)) 
   cPercComis	 := Val(U_P_CORTA(cRetorno, "|",16)) 
   cCustoFrete   := Val(U_P_CORTA(cRetorno, "|",13)) 
   cPercFrete    := Val(U_P_CORTA(cRetorno, "|",14)) 
   cCustoCond	 := Val(U_P_CORTA(cRetorno, "|",17)) 
   cPercCond	 := Val(U_P_CORTA(cRetorno, "|",18)) 
   cCustoCartao  := Val(U_P_CORTA(cRetorno, "|",11)) 
   cPercCartao   := Val(U_P_CORTA(cRetorno, "|",12)) 
   cMargem	     := Val(U_P_CORTA(cRetorno, "|",19)) 
   cPercMargem   := Val(U_P_CORTA(cRetorno, "|",20)) 
   cValorVenda   := Val(U_P_CORTA(cRetorno, "|",08)) 
   cValorDifal   := Val(U_P_CORTA(cRetorno, "|",06)) 
   cValorFrete   := Val(U_P_CORTA(cRetorno, "|",13)) 
   cValorTotal   := cValorVenda + cValorDifal + cValorFrete

   If T_PEDIDO->C5_MOEDA == 1
      lReal  := .T.
      lDolar := .F.
   Else
      lReal  := .F.
      lDolar := .T.
   Endif

   // #################################################
   // Captura a cotação da moeda 2 para a data atual ##
   // #################################################
   If Select("T_COTACAO") > 0
      T_COTACAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT M2_MOEDA2"
   cSql += "  FROM " + RetSqlName("SM2")
   cSql += " WHERE M2_DATA    = CONVERT(DATETIME,'" + Dtoc(Date()) + "', 103)"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COTACAO", .T., .T. )

   If !T_COTACAO->( EOF() )
      cDataCotacao  := Date()
      cTaxaDolar    := T_COTACAO->M2_MOEDA2
   Else
      cDataCotacao  := Date()
      cTaxaDolar    := 0
   Endif   

   // ########################################
   // Desenha tela para display dos valores ##
   // ########################################
   DEFINE MSDIALOG oDlg TITLE "Parâmetros Cálculo de Margem de Produto" FROM C(178),C(181) TO C(607),C(959) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp"                  Size C(122),C(026) PIXEL NOBORDER OF oDlg
   @ C(188),C(180) Jpeg FILE "margem.png"                       Size C(010),C(014) PIXEL NOBORDER OF oDlg

   nLinha := 03
   
   For nContar = 1 to U_P_OCCURS(SC6->C6_ZTBL, "-", 1)

       Do Case
          Case U_P_CORTA(SC6->C6_ZTBL, "-", nContar) == "MRG"
               @ C(nLinha),C(251) Say "BLOQUEADO POR MARGEM"                    Size C(150),C(008) COLOR CLR_RED PIXEL OF oDlg
          Case U_P_CORTA(SC6->C6_ZTBL, "-", nContar) == "DOA"
               @ C(nLinha),C(251) Say "BLOQUEADO POR DOAÇÃO"                    Size C(150),C(008) COLOR CLR_RED PIXEL OF oDlg
          Case U_P_CORTA(SC6->C6_ZTBL, "-", nContar) == "FRT"
               @ C(nLinha),C(251) Say "BLOQUEADO POR FRETE AUTOMATECH"          Size C(150),C(008) COLOR CLR_RED PIXEL OF oDlg
          Case U_P_CORTA(SC6->C6_ZTBL, "-", nContar) == "SIM"
               @ C(nLinha),C(251) Say "BLOQUEADO POR FRETE GRATUITO - SIMFRETE" Size C(150),C(008) COLOR CLR_RED PIXEL OF oDlg
          Case U_P_CORTA(SC6->C6_ZTBL, "-", nContar) == "PAG"
               @ C(nLinha),C(251) Say "BLOQUEADO POR CONDIÇÃO DE PAGAMENTO"     Size C(150),C(008) COLOR CLR_RED PIXEL OF oDlg
       EndCase
               
       nLinha += 5

   Next nContar    

   @ C(032),C(002) GET      oMemo1     Var cMemo1 MEMO          Size C(382),C(001) PIXEL OF oDlg
   @ C(101),C(002) GET      oMemo2     Var cMemo2 MEMO          Size C(382),C(001) PIXEL OF oDlg
   @ C(104),C(234) GET      oMemo6     Var cMemo6 MEMO          Size C(001),C(088) PIXEL OF oDlg
   @ C(112),C(002) GET      oMemo3     Var cMemo3 MEMO          Size C(228),C(001) PIXEL OF oDlg
   @ C(112),C(238) GET      oMemo4     Var cMemo4 MEMO          Size C(145),C(001) PIXEL OF oDlg
   @ C(203),C(002) GET      oMemo5     Var cMemo5 MEMO          Size C(298),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Nº P.Venda"                 Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(039) Say "Cliente"                    Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(251) Say "Cidade"                     Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(370) Say "UF"                         Size C(008),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(058),C(005) Say "Produto"                    Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(058),C(068) Say "Part Number"                Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(058),C(151) Say "Descrição do Produto"       Size C(053),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(079),C(005) Say "Cond. Pagtº"                Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(079),C(068) Say "Transportadora"             Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(079),C(145) Say "Tipo Frete"                 Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(079),C(193) Say "T E S"                      Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(079),C(279) Say "Vendedor(a)"                Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(117),C(005) Say "Custo Médio Inicial ($)"    Size C(056),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(117),C(121) Say "Custo ADM"                  Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(117),C(239) Say "Moeda"                      Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(104),C(090) Say "VARIÁVEIS DE CÁLCULO"       Size C(063),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(104),C(274) Say "VALORES DO PEDIDO DE VENDA" Size C(088),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(129),C(121) Say "Custo Comissão"             Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(129),C(239) Say "Data"                       Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(129),C(299) Say "Cotação"                    Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(140),C(005) Say "COFINS (%)"                 Size C(056),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(140),C(121) Say "Custo Frete"                Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(145),C(260) Say "Total da Venda"             Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(129),C(005) Say "PIS (%)"                    Size C(056),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(153),C(005) Say "ICMS (%)"                   Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(153),C(121) Say "Custo Cond.Pgtº"            Size C(041),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(158),C(260) Say "Valor DIFAL"                Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(164),C(005) Say "C.Adjudicado ($)"           Size C(055),C(009) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(164),C(121) Say "Custo Cartão"               Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(170),C(260) Say "Valor do Frete"             Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(177),C(005) Say "DIFAL"                      Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(189),C(005) Say "Custo Médio Total ($)"      Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(177),C(121) Say "M A R G E M"                Size C(034),C(008) COLOR CLR_RED   PIXEL OF oDlg
   @ C(181),C(260) Say "Total do Produto"           Size C(041),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(045),C(005) MsGet    oGet1      Var cPedido      Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(045),C(039) MsGet    oGet2      Var cCliente     Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(045),C(068) MsGet    oGet3      Var cLoja        Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(045),C(088) MsGet    oGet4      Var cNomeCli     Size C(156),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(045),C(251) MsGet    oGet5      Var cCidade      Size C(112),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(045),C(370) MsGet    oGet6      Var cEstado      Size C(014),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(067),C(005) MsGet    oGet7      Var cProduto     Size C(059),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(067),C(068) MsGet    oGet8      Var cpartNumber  Size C(079),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(067),C(151) MsGet    oGet9      Var cNomeProduto Size C(233),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(088),C(005) MsGet    oGet10     Var cCondicao    Size C(059),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(088),C(068) MsGet    oGet11     Var cTransporte  Size C(071),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(088),C(145) MsGet    oGet12     Var cTipoFrete   Size C(044),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(088),C(193) MsGet    oGet13     Var cTES         Size C(083),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(088),C(279) MsGet    oGet14     Var cVendedor    Size C(105),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(116),C(062) MsGet    oGet17     Var cCustoInicial Size C(050),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg When lChumba
   @ C(128),C(062) MsGet    oGet18     Var cPIS          Size C(024),C(009) COLOR CLR_BLACK Picture "@E 999.99"     PIXEL OF oDlg When lChumba
   @ C(140),C(062) MsGet    oGet19     Var cCOFINS       Size C(024),C(009) COLOR CLR_BLACK Picture "@E 999.99"     PIXEL OF oDlg When lChumba
   @ C(152),C(062) MsGet    oGet20     Var cICMS         Size C(024),C(009) COLOR CLR_BLACK Picture "@E 999.99"     PIXEL OF oDlg When lChumba
   @ C(164),C(062) MsGet    oGet21     Var cCreditoAdj   Size C(050),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg When lChumba
   @ C(176),C(062) MsGet    oGet50     Var cDIFAL        Size C(050),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg When lChumba
   @ C(188),C(062) MsGet    oGet22     Var cCustoTotal   Size C(050),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg When lChumba
   
   @ C(116),C(163) MsGet    oGet23     Var cCustoADM     Size C(040),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg When lChumba
   @ C(116),C(206) MsGet    oGet24     Var cPercADM      Size C(024),C(009) COLOR CLR_BLACK Picture "@E 999.99"     PIXEL OF oDlg When lChumba
   @ C(128),C(163) MsGet    oGet25     Var cCustoComis   Size C(040),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg When lChumba
   @ C(128),C(206) MsGet    oGet26     Var cPercComis    Size C(024),C(009) COLOR CLR_BLACK Picture "@E 999.99"     PIXEL OF oDlg When lChumba
   @ C(140),C(163) MsGet    oGet27     Var cCustoFrete   Size C(040),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg When lChumba
   @ C(140),C(206) MsGet    oGet28     Var cPercFrete    Size C(024),C(009) COLOR CLR_BLACK Picture "@E 999.99"     PIXEL OF oDlg When lChumba
   @ C(152),C(163) MsGet    oGet29     Var cCustoCond    Size C(040),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg When lChumba
   @ C(152),C(206) MsGet    oGet30     Var cPercCond     Size C(024),C(009) COLOR CLR_BLACK Picture "@E 999.99"     PIXEL OF oDlg When lChumba
   @ C(164),C(163) MsGet    oGet31     Var cCustoCartao  Size C(040),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg When lChumba
   @ C(164),C(206) MsGet    oGet32     Var cPercCartao   Size C(024),C(009) COLOR CLR_BLACK Picture "@E 999.99"     PIXEL OF oDlg When lChumba
   @ C(176),C(163) MsGet    oGet15     Var cMargem       Size C(040),C(009) COLOR CLR_RED   Picture "@E 999,999.99" PIXEL OF oDlg When lChumba
   @ C(176),C(206) MsGet    oGet16     Var cPercMargem   Size C(024),C(009) COLOR CLR_RED   Picture "@E 999.99"     PIXEL OF oDlg When lChumba

   @ C(116),C(260) CheckBox oCheckBox1 Var lReal         Prompt "REAL"  Size C(025),C(008)               PIXEL OF oDlg When lChumba
   @ C(116),C(299) CheckBox oCheckBox2 Var lDolar        Prompt "DOLAR" Size C(030),C(008)               PIXEL OF oDlg When lChumba

   @ C(128),C(260) MsGet    oGet33     Var cDataCotacao  Size C(035),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg When lChumba
   @ C(128),C(323) MsGet    oGet34     Var cTaxaDolar    Size C(061),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg When lChumba
   @ C(145),C(305) MsGet    oGet35     Var cValorVenda   Size C(050),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg When lChumba
   @ C(157),C(305) MsGet    oGet36     Var cValorDifal   Size C(050),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg When lChumba
   @ C(169),C(305) MsGet    oGet37     Var cValorFrete   Size C(050),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg When lChumba
   @ C(181),C(305) MsGet    oGet38     Var cValorTotal   Size C(050),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg When lChumba

   @ C(198),C(304) Button "Detalhe PV"                 Size C(037),C(012) PIXEL OF oDlg ACTION( AbrePV(Alltrim(SC6->C6_FILIAL), Alltrim(SC6->C6_NUM)) )
   @ C(198),C(346) Button "Retornar"                   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #########################################
// Abre a visualização do Pedido de Venda ##
// #########################################
Static Function AbrePV( __Filial, __Pedido )

   dbSelectArea("SC5")
   dbSetOrder(1)
   dbSeek(__Filial + __Pedido)

   A410Visual("SC5",SC5->( Recno() ),2)
   
Return(.T.)