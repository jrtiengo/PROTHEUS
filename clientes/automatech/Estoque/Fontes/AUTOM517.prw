#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM517.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 01/12/2016                                                          ##
// Objetivo..: Painel Logística                                                    ##
// ##################################################################################

User Function AUTOM517()

   Local cSql        := ""
   Local lSelecao    := .F.
   Local lChumba     := .F.
   Local nContar     := 0

   Private cFiliais    := Space(15)
   Private aVendedores := {}
   Private aStatus     := {}
   Private aFilial     := U_AUTOM539(2, cEmpAnt) // {"01-POA", "02-CXS", "03-PEL", "04-SUP"}
   Private aFiltros    := {}

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3

   Private dInicial := Date() - 30
   Private dFinal   := Date()

   Private cPedidoI := Space(06)
   Private cPedidoF := Space(06)
   Private cCliente := Space(06)
   Private cLoja    := Space(03)
   Private cNome	:= Space(60)
   
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8

   Private nMeter1 := 0
   Private oMeter1

   Private aBrowse  := {}
   Private aDetalhe := {}

   Private oDlg

   Private oVerde    := LoadBitmap(GetResources(),'br_verde')
   Private oVermelho := LoadBitmap(GetResources(),'br_vermelho')
   Private oAzul     := LoadBitmap(GetResources(),'br_azul')
   Private oAmarelo  := LoadBitmap(GetResources(),'br_amarelo')
   Private oPreto    := LoadBitmap(GetResources(),'br_preto')
   Private oLaranja  := LoadBitmap(GetResources(),'br_laranja')
   Private oCinza    := LoadBitmap(GetResources(),'br_cinza')
   Private oBranco   := LoadBitmap(GetResources(),'br_branco')
   Private oPink     := LoadBitmap(GetResources(),'br_pink')
   Private oCancel   := LoadBitmap(GetResources(),'br_cancel')
   Private oEncerra  := LoadBitmap(GetResources(),'br_marrom')
   Private oBpmsed3e := LoadBitmap(GetResources(),'bpmsed3e')
   Private oBpmedt3i := LoadBitmap(GetResources(),'bpmedt3i')
   Private olbno     := LoadBitmap(GetResources(),'lbno')
   Private olbok     := LoadBitmap(GetResources(),'lbok')
   Private olightblu := LoadBitmap(GetResources(),'lightblu')

   U_AUTOM628("AUTOM517")

   // ################################
   // Carrega o combo de vendedores ##
   // ################################
   If Select("T_VENDEDOR") > 0
      T_VENDEDOR->( dbCloseArea() )
   EndIf

   cSql := "SELECT A.A3_COD   ,"
   cSql += "       A.A3_NOME  ,"
   cSql += "       A.A3_CODUSR,"
   cSql += "       A.A3_TSTAT  "
   cSql += "  FROM " + RetSqlName("SA3") + " A "
   cSql += " WHERE A.D_E_L_E_T_ = ''"
   cSql += "   AND A.A3_CODUSR <> ''"
   cSql += "   AND A.A3_NREDUZ <> ''"
   cSql += " ORDER BY A.A3_NOME"     
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

   aAdd( aVendedores, "000000 - Todos os Vendedores" ) 

   T_VENDEDOR->( DbGoTop() )

   WHILE !T_VENDEDOR->( EOF() )
      aAdd( aVendedores, IIF(Empty(Alltrim(T_VENDEDOR->A3_TSTAT)), "1", Alltrim(T_VENDEDOR->A3_TSTAT)) + "." + Alltrim(T_VENDEDOR->A3_COD) + " - " + T_VENDEDOR->A3_NOME ) 
      T_VENDEDOR->( DbSkip() )
   ENDDO

   // ############################
   // Carrega o combo de Status ##
   // ############################
   aAdd( aStatus, "AA - Pedidos em Carteira (Todos - 11/12/14)" )
   aAdd( aStatus, "BB - Faturados / Expedidos" )
   aAdd( aStatus, "CC - Em Separação / Aguardando Faturamento" )
   aAdd( aStatus, "TT - Todos" )
   aAdd( aStatus, "01 - Aguardando Liberação - Significa que o pedido está aguardando início do processo (verificação do pedido por parte da área de estoque)" )
   aAdd( aStatus, "02 - Aguardando Liberação Margem - Pedido com margem abaixo do mínimo" )
   aAdd( aStatus, "03 - Aguardando Liberação de Credito - O pedido está aguardando análise de credito (liberação a ser realizada pelo departamento financeiro)" )
   aAdd( aStatus, "04 - Aguardando Liberação de Estoque - Avaliação por parte da área de estoque (itens que não possuem estoque e que devem ser adquiridos)" )
   aAdd( aStatus, "05 - Aguardando data de entrega - Pedido está aguardando para ser faturado (exemplo programação de entrega de ribbons/etiquetas)" )
   aAdd( aStatus, "06 - Em compra - Pedido está aguardando o fornecedor" )
   aAdd( aStatus, "07 - Em produção - Pedido está aguardando ser produzido" )
   aAdd( aStatus, "08 - Aguardando separação estoque - Pedido está sendo separado / liberação dos itens e números seriais" )
   aAdd( aStatus, "09 - Aguardando cliente - Aguardando documentação de lacre e ou comprovante de deposito em caso de pagamento a vista" )
   aAdd( aStatus, "10 - Aguardando faturamento - Pedido já foi separado e está aguardando emissão da NF" )
   aAdd( aStatus, "11 - Item faturado - Já emitimos a NF" )
   aAdd( aStatus, "12 - Item expedido - Item já foi liberado para transportadora/cliente" )
   aAdd( aStatus, "13 - Aguardando distribuidor - Em caso de pedido de intermediação, pedido ficará pendente em função do faturamento do distribuidor" )
   aAdd( aStatus, "14 - Pedido cancelado" )
   aAdd( aStatus, "15 - Pedido Com Análise de Crédito Rejeitado" ) 

   // Desenha a tela do Acompanhamento de Pedidos
   DEFINE MSDIALOG oDlg TITLE "Painel Logística" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(026),C(005) Say "Filial"           Size C(012),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(026),C(025) Say "Data Inicial"     Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(060) Say "Data Final"       Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(097) Say "Vendedor"         Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(192) Say "Status"           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(284) Say "Nº PV Inicial"    Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(320) Say "Nº PV Final"      Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(356) Say "Cliente"          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(046),C(005) Say "Pedidos de Venda"         Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(141),C(005) Say "Ítens do Pedido de Venda" Size C(100),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(002),C(005) Jpeg FILE "nlogoautoma.bmp" Size C(136),C(040) PIXEL NOBORDER OF oDlg
   @ C(212),C(005) Jpeg FILE "br_branco"       Size C(010),C(010) PIXEL NOBORDER OF oDlg
   @ C(212),C(090) Jpeg FILE "br_branco"       Size C(010),C(010) PIXEL NOBORDER OF oDlg
   @ C(212),C(191) Jpeg FILE "br_branco"       Size C(010),C(010) PIXEL NOBORDER OF oDlg

   @ C(035),C(005)  ComboBox cComboBx3 Items aFilial     Size C(020),C(010)                              PIXEL OF oDlg
   @ C(035),C(025)  MsGet    oGet1     Var   dInicial    Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(035),C(060)  MsGet    oGet2     Var   dFinal      Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(035),C(097)  ComboBox cComboBx1 Items aVendedores Size C(090),C(010)                              PIXEL OF oDlg

   @ C(035),C(192)  ComboBox cComboBx2 Items aStatus                   Size C(087),C(010) PIXEL OF oDlg
   @ C(035),C(284)  MsGet    oGet3     Var   cPedidoI                  Size C(030),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(035),C(320)  MsGet    oGet4     Var   cPedidoF                  Size C(030),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(035),C(356)  MsGet    oGet5     Var   cCliente                  Size C(030),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA1") VALID( PegaNomeCli() )
   @ C(035),C(1000) MsGet    oGet6     Var   cLoja     	 When lChumba  Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( PegaNomeCli() )
   @ C(035),C(387)  MsGet    oGet7     Var   cNome       When lChumba  Size C(112),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(008),C(462) Button "Atualiza"      Size C(037),C(012) PIXEL OF oDlg ACTION( PegaStatus(2) )
   @ C(210),C(016) Button "Lib. Pedidos"  Size C(037),C(012) PIXEL OF oDlg ACTION( MATA440() )
   @ C(210),C(054) Button "Ped.Venda"     Size C(033),C(012) PIXEL OF oDlg ACTION( MATA410() )
   @ C(210),C(101) Button "Doc.Saída"     Size C(030),C(012) PIXEL OF oDlg ACTION( MATA460A() )
   @ C(210),C(132) Button "NFe Sefaz"     Size C(030),C(012) PIXEL OF oDlg ACTION( SPEDNFE() )
   @ C(210),C(164) Button "NFe-S"         Size C(024),C(012) PIXEL OF oDlg ACTION( FISA022() )
   @ C(210),C(202) Button "Separação"     Size C(031),C(012) PIXEL OF oDlg ACTION( U_JPCACD01() )
   @ C(210),C(234) Button "Cons. Saldos"  Size C(037),C(012) PIXEL OF oDlg ACTION( PsqSldPainel(aDetalhe[oDetalhe:nAt,05]) )

   @ C(210),C(272) Button "Anal.Crédito"  Size C(037),C(012) PIXEL OF oDlg When lChumba ACTION( MATA450() )
   @ C(210),C(310) Button "Exc.Doc.Saída" Size C(037),C(012) PIXEL OF oDlg ACTION( MATA521A() )
   @ C(210),C(348) Button "Cad.Produtos"  Size C(037),C(012) PIXEL OF oDlg ACTION( MATA010() )
   @ C(210),C(386) Button "Cad.Clientes"  Size C(037),C(012) PIXEL OF oDlg ACTION( MATA030() )
   @ C(210),C(424) Button "Mais >>>>>"    Size C(037),C(012) PIXEL OF oDlg ACTION( AbreMaisOpcoes() )

   @ C(210),C(462) Button "Voltar"        Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )


   If Len(aBrowse) == 0
      aAdd( aBrowse, { "","","","","","","","","" } )
   Endif   

   oBrowse := TCBrowse():New( 068 , 005, 631, 110,,{'FL', 'Nº Pedido', 'Emissão', 'Moeda', 'Cliente', 'Loja', 'Descrição dos Clientes', 'Vendedor', 'Descrição dos Vendedores'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // ###########################
   // Seta vetor para a browse ##
   // ###########################                           
   oBrowse:SetArray(aBrowse) 
    
   // ########################################
   // Monta a linha a ser exibina no Browse ##
   // ########################################
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07],;
                         aBrowse[oBrowse:nAt,08],;
                         aBrowse[oBrowse:nAt,09]} }

   oBrowse:bLDblClick := {|| QUEPRODUTO(aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02]) } 
   
   // ################################################################
   // Desenha o List de produtos para o pedido de venda selecionado ##
   // ################################################################
   If Len(aDetalhe) == 0
      aAdd( aDetalhe, { "1","","","","","","","","","","","","","","","","","","","","","","","","" })
   Endif   

   @ 190,005 LISTBOX oDetalhe FIELDS HEADER 'Status', 'Descrição Status', 'Nº PV', 'Item', 'Produtos', 'Descrição dos Produtos', 'Qtd', 'Unitário', 'Vlr Total', 'Lacre', 'Nº Série', 'Dta Entrega', 'N.Fiscal', 'Série', 'Dta Fat.', 'Transp.', 'Descrição Transportadoras', 'Espécie', 'Volume', 'Peso Liquido', 'Pedo Bruto', 'Hora Expedição', 'Conhecimento', 'Nº OC', 'Código Postal' PIXEL SIZE 631,075 OF oDlg 

   oDetalhe:SetArray( aDetalhe )

   oDetalhe:bLine := {||{   If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "1", oBranco  ,;
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "2", oVerde   ,;
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "3", oPink    ,;                         
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "4", oAmarelo ,;                         
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "5", oAzul    ,;                         
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "6", oLaranja ,;                         
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "7", oPreto   ,;                         
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "8", oVermelho,;
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "X", oCancel  ,;
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "A", oCancel  ,;
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "B", oCancel  ,;
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "C", oCancel  ,;
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "D", oCancel  ,;
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "E", oCancel  ,;
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "9", oEncerra, ""))))))))))))))),;                         
        		    		aDetalhe[oDetalhe:nAt,02],;
          		    		aDetalhe[oDetalhe:nAt,03],;
          		    		aDetalhe[oDetalhe:nAt,04],;
          		    		aDetalhe[oDetalhe:nAt,05],;
          		    		aDetalhe[oDetalhe:nAt,06],;
          		    		aDetalhe[oDetalhe:nAt,07],;
          		    		aDetalhe[oDetalhe:nAt,08],;
          		    		aDetalhe[oDetalhe:nAt,09],;          		    		  
          		    		aDetalhe[oDetalhe:nAt,10],;
          		    		aDetalhe[oDetalhe:nAt,11],;
          		    		aDetalhe[oDetalhe:nAt,12],;          		    		  
          		    		aDetalhe[oDetalhe:nAt,13],;
          		    		aDetalhe[oDetalhe:nAt,14],;
          		    		aDetalhe[oDetalhe:nAt,15],;          		    		  
          		    		aDetalhe[oDetalhe:nAt,16],;
          		    		aDetalhe[oDetalhe:nAt,17],;
          		    		aDetalhe[oDetalhe:nAt,18],;          		    		  
          		    		aDetalhe[oDetalhe:nAt,19],;
          		    		aDetalhe[oDetalhe:nAt,20],;
          		    		aDetalhe[oDetalhe:nAt,21],;
          		    		aDetalhe[oDetalhe:nAt,22],;
          		    		aDetalhe[oDetalhe:nAt,23],;
          		    		aDetalhe[oDetalhe:nAt,24],;          		    		  
          		    		aDetalhe[oDetalhe:nAt,25]}}

   oDetalhe:Refresh()

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #####################################################
// Função que pesquisa o saldo do produto selecionado ##
// #####################################################
Static Function PsqSldPainel(_Produto)

   If Empty(Alltrim(_Produto))
      MsgAlert("Produto a ser pesquisado inexistente.")
      Return(.T.)
   Endif

   aArea := GetArea()

   // Posiciona no produto a ser pesquisado o seu saldo
   DbSelectArea("SB1")
   DbSetOrder(1)
   DbSeek(xFilial("SB1") + _Produto)

   MaViewSB2(_Produto)

   RestArea( aArea )

Return .T.

// ########################################
// Função que Imprime a Danfe do Sistema ##
// ########################################
Static Function STSDANFE()

   Local cFil := Substr(cComboBx3,01,02)

   Private aFilBrw := {"SF2","F2_FILIAL=='"+ cFil +"'.And.F2_SERIE=='"+ SubStr( cFil, 2 ) +"'"}
   
   SPEDDANFE()
   
Return(.T.)

// ########################################################
// Função que limpa os campos conforme botão selecionado ##
// ########################################################
Static Function LimpaCmp(_Tipo)

   If _Tipo == 1
      cPedidoI := Space(06)
      cPedidoF := Space(06)
      oGet3:Refresh()
      oGet4:Refresh()
   Else
      cCliente := Space(06)
      cLoja    := Space(03)
      cNome    := Space(60)
      oGet5:Refresh()
      oGet6:Refresh()
      oGet7:Refresh()
   Endif
   
   // Realiza novamente a pesquisa
   PegaStatus(2)

Return(.T.)   

// Função que pesquisa o nome do cliente
Static Function PegaNomeCli()
                           
   If Empty(Alltrim(cCliente))
      cLoja := Space(03)     
      cNome := Space(60)
      Return(.T.)
   Endif
      
   dbSelectArea("SA1")
   dbSetOrder(1) 
   If DbSeek(xFilial("SA1") + cCliente + cLoja)
      cNome := SA1->A1_NOME
   Endif

Return(.T.)      

// Função que abre janela mostrando descrição dos Status
Static Function MostraDStatus()

   Private oDlgLegenda

   DEFINE MSDIALOG oDlgLegenda TITLE "Status dos Pedidos" FROM C(178),C(181) TO C(490),C(875) PIXEL

   @ C(004),C(005) Say "01-Aguardando Liberação - Significa que o pedido está aguardando início do processo (verificação do pedido por parte da área de estoque)"  Size C(332),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(013),C(005) Say "02-Aguardando Liberação Margem - Pedido com margem abaixo do mínimo "                                                                      Size C(181),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(022),C(005) Say "03-Aguardando Liberação de Credito - O pedido está aguardando análise de credito (liberação a ser realizada pelo departamento financeiro)" Size C(332),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(031),C(005) Say "04-Aguardando Liberação de Estoque - Avaliação por parte da área de estoque (itens que não possuem estoque e que devem ser adquiridos)"    Size C(335),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(040),C(005) Say "05-Aguardando data de entrega - Pedido está aguardando para ser faturado (exemplo programação de entrega de ribbons/etiquetas)"            Size C(332),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(049),C(005) Say "06-Em compra - Pedido está aguardando o fornecedor"                                                                                        Size C(131),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(058),C(005) Say "07-Em produção - Pedido está aguardando ser produzido"                                                                                     Size C(136),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(067),C(005) Say "08-Aguardando separação estoque - Pedido está sendo separado / liberação dos itens e números seriais"                                      Size C(251),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(076),C(005) Say "09-Aguardando cliente - Aguardando documentação de lacre e ou comprovante de deposito em caso de pagamento a vista"                        Size C(298),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(085),C(005) Say "10-Aguardando faturamento - Pedido já foi separado e está aguardando emissão da NF"                                                        Size C(208),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(094),C(005) Say "11-Item faturado - Já emitimos a NF"                                                                                                       Size C(087),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(103),C(005) Say "12-Item expedido - Item já foi liberado para transportadora/cliente"                                                                       Size C(157),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(112),C(005) Say "13-Aguardando distribuidor - Em caso de pedido de intermediação, pedido ficará pendente em função do faturamento do distribuidor"          Size C(313),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(121),C(005) Say "14-Pedido cancelado"                                                                                                                       Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda
   @ C(130),C(005) Say "15-Pedido Com Análise de Crédito Rejeitado"                                                                                                Size C(108),C(008) COLOR CLR_BLACK PIXEL OF oDlgLegenda

   @ C(139),C(153) Button "Retornar" Size C(037),C(012) PIXEL OF oDlgLegenda ACTION( oDlgLegenda:End() )

   ACTIVATE MSDIALOG oDlgLegenda CENTERED 

Return(.T.)

// ###########################################################
// Função que pesquisa os pedidos conforme filtro informado ##
// ###########################################################
Static Function PegaStatus(___TipoPesquisa)

   MsgRun("Favor Aguarde! Pesquisando Pedidos de Venda ...", "Painel Logóstica",{|| xPegaStatus(___TipoPesquisa) })

Return(.T.)

// ###########################################################
// Função que pesquisa os pedidos conforme filtro informado ##
// ###########################################################
Static Function xPegaStatus(___TipoPesquisa)

   Local cSql   := ""
   Local nRegua := 0
   
   // ##############################################
   // Consiste nº de pedido de venda se informado ##
   // ##############################################
   If !Empty(Alltrim(cPedidoI))
      If Empty(Alltrim(cPedidoF))
         MsgAlert("Pedido final para pesquisa não informado.")
         Return(.T.)
      Endif
   Endif
         
   // ##############################################
   // Consiste nº de pedido de venda se informado ##
   // ##############################################
   If !Empty(Alltrim(cPedidoF))
      If Empty(Alltrim(cPedidoI))
         MsgAlert("Pedido inicial para pesquisa não informado.")
         Return(.T.)
      Endif
   Endif

   // ########################################################################
   // Carrega o array aFiltros com os filtros selcionados para visualização ##
   // ########################################################################
   aAdd( aFiltros, { "Filial: "          + Substr(cCombobx3,01,02) ,;
                     "Data Inicial: "    + Dtoc(dInicial)          ,;
                     "Data Final: "      + Dtoc(dFinal)            ,;
                     "Vendedor: "        + cCombobx1               ,;
                     "Status: "          + cCombobx2               ,;
                     "Pedido Inicial: "  + cPedidoI                ,;
                     "Pedido Final: "    + cPedidoF                ,;
                     "Cliente: "         + cCliente                ,;
                     "Nome do Cliente: " + cNome } )

   // #############################################
   // Limpa e atualiza o grid antes da pesquisa  ##
   // #############################################
   aBrowse := {}

   If ___TipoPesquisa == 2
      oBrowse:SetArray(aBrowse) 
      oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                            aBrowse[oBrowse:nAt,02],;
                            aBrowse[oBrowse:nAt,03],;
                            aBrowse[oBrowse:nAt,04],;
                            aBrowse[oBrowse:nAt,05],;
                            aBrowse[oBrowse:nAt,06],;
                            aBrowse[oBrowse:nAt,07],;
                            aBrowse[oBrowse:nAt,08],;
                            aBrowse[oBrowse:nAt,09]} }

      oBrowse:Refresh()
   Endif   

   // ################################################################
   // Limpa o list de detalhes do pedido para receber nova pesquisa ##
   // ################################################################
   aDetalhe := {}

   If ___TipoPesquisa == 2
      oDetalhe:SetArray( aDetalhe )
      oDetalhe:bLine := {||{If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "1", oBranco  ,;
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "2", oVerde   ,;
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "3", oPink    ,;                         
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "4", oAmarelo ,;                         
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "5", oAzul    ,;                         
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "6", oLaranja ,;                         
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "7", oPreto   ,;                         
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "8", oVermelho,;
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "X", oCancel  ,;
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "A", oCancel  ,;
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "B", oCancel  ,;
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "C", oCancel  ,;
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "D", oCancel  ,;
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "E", oCancel  ,;
                            If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "9", oEncerra, ""))))))))))))))),;                         
        		    		aDetalhe[oDetalhe:nAt,02],;
          		    		aDetalhe[oDetalhe:nAt,03],;
          		    		aDetalhe[oDetalhe:nAt,04],;
          		    		aDetalhe[oDetalhe:nAt,05],;
          		    		aDetalhe[oDetalhe:nAt,06],;
          		    		aDetalhe[oDetalhe:nAt,07],;
          		    		aDetalhe[oDetalhe:nAt,08],;
          		    		aDetalhe[oDetalhe:nAt,09],;          		    		  
          		    		aDetalhe[oDetalhe:nAt,10],;
          		    		aDetalhe[oDetalhe:nAt,11],;
          		    		aDetalhe[oDetalhe:nAt,12],;          		    		  
          		    		aDetalhe[oDetalhe:nAt,13],;
          		    		aDetalhe[oDetalhe:nAt,14],;
          		    		aDetalhe[oDetalhe:nAt,15],;          		    		  
          		    		aDetalhe[oDetalhe:nAt,16],;
          		    		aDetalhe[oDetalhe:nAt,17],;
          		    		aDetalhe[oDetalhe:nAt,18],;          		    		  
          		    		aDetalhe[oDetalhe:nAt,19],;
          		    		aDetalhe[oDetalhe:nAt,20],;
          		    		aDetalhe[oDetalhe:nAt,21],;
          		    		aDetalhe[oDetalhe:nAt,22],;
          		    		aDetalhe[oDetalhe:nAt,23],;
          		    		aDetalhe[oDetalhe:nAt,24],;          		    		  
          		    		aDetalhe[oDetalhe:nAt,25]}}
      oDetalhe:Refresh()
   Endif   

   // ##############################################################
   // Verifica se existem pedidos aguardando liberaçlão de Pedido ##
   // ##############################################################
   If Select("T_ALIBERAR") > 0
      T_ALIBERAR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT C6_STATUS "
   cSql += "  FROM " + RetSqlName("SC6") 
   cSql += " WHERE C6_FILIAL = '" + Substr(cComboBx3,01,02) + "'" 
   cSql += "   AND C6_STATUS IN ('01', '02', '03')"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ALIBERAR", .T., .T. )

   @ C(212),C(005) Jpeg FILE IIF(T_ALIBERAR->( EOF() ), "br_branco", "br_vermelho") Size C(010),C(010) PIXEL NOBORDER OF oDlg

   // ###########################################################
   // Verifica se existem documentos de saídas a serem gerados ##
   // ###########################################################
   If Select("T_DOCSAIDA") > 0
      T_DOCSAIDA->( dbCloseArea() )
   EndIf

   cSql := "SELECT C6_FILIAL, "
   cSql += "       C6_NUM     "
   cSql += "  FROM " + RetSqlName("SC6")
   cSql += " WHERE C6_FILIAL = '" + Substr(cComboBx3,01,02) + "'" 
   cSql += "   AND C6_NOTA   = ''  "
   cSql += "   AND C6_STATUS = '10'" 
   cSql += "   AND D_E_L_E_T_ = '' "
   cSql += " GROUP BY C6_FILIAL, C6_NUM"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DOCSAIDA", .T., .T. )

   @ C(212),C(090) Jpeg FILE IIF(T_DOCSAIDA->( EOF() ), "br_branco", "br_vermelho") Size C(010),C(010) PIXEL NOBORDER OF oDlg

   // #########################################################
   // Verifica se existem pedidos de venda a serem separados ##
   // #########################################################
   If Select("T_SEPARACAO") > 0
      T_SEPARACAO->( dbCloseArea() )
   EndIf

   cSql := "SELECT C6_FILIAL, "
   cSql += "       C6_NUM     "
   cSql += "  FROM " + RetSqlName("SC6")
   cSql += " WHERE C6_FILIAL = '" + Substr(cComboBx3,01,02) + "'" 
   cSql += "   AND C6_NOTA   = ''  "
   cSql += "   AND C6_STATUS = '08'" 
   cSql += "   AND D_E_L_E_T_ = '' "
   cSql += " GROUP BY C6_FILIAL, C6_NUM"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SEPARACAO", .T., .T. )

   @ C(212),C(191) Jpeg FILE IIF(T_SEPARACAO->( EOF() ), "br_branco", "br_vermelho") Size C(010),C(010) PIXEL NOBORDER OF oDlg

   // ##################################################
   // Pesquisa pedidos conforme parâmetros informados ##
   // ##################################################
   If Select("T_PEDIDOS") > 0
      T_PEDIDOS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT DISTINCT SC6.C6_FILIAL,"                + CHR(13)
   cSql += "       SC6.C6_NUM            ,"                + CHR(13)
   cSql += "      (SELECT C5_TIPO         "                + CHR(13)
   cSql += "         FROM " + RetSqlName("SC5")            + CHR(13)
   cSql += "        WHERE C5_FILIAL      = SC6.C6_FILIAL " + CHR(13)
   cSql += "          AND C5_NUM         = SC6.C6_NUM    " + CHR(13)
   cSql += "          AND D_E_L_E_T_ = '') AS TIPO,      " + CHR(13)
   cSql += "      (SELECT C5_EMISSAO      "                + CHR(13)
   cSql += "         FROM " + RetSqlName("SC5")            + CHR(13)
   cSql += "        WHERE C5_FILIAL      = SC6.C6_FILIAL " + CHR(13)
   cSql += "          AND C5_NUM         = SC6.C6_NUM    " + CHR(13)
   cSql += "          AND D_E_L_E_T_ = '') AS EMISSAO,   " + CHR(13)
   cSql += "      (SELECT C5_MOEDA      "                  + CHR(13)
   cSql += "         FROM " + RetSqlName("SC5")            + CHR(13)
   cSql += "        WHERE C5_FILIAL      = SC6.C6_FILIAL " + CHR(13)
   cSql += "          AND C5_NUM         = SC6.C6_NUM    " + CHR(13)
   cSql += "          AND D_E_L_E_T_ = '') AS MOEDA,     " + CHR(13)
   cSql += "       SC6.C6_CLI   , "                        + CHR(13)
   cSql += "       SC6.C6_LOJA  , "                        + CHR(13)
   cSql += "      (SELECT C5_VEND1"                        + CHR(13)
   cSql += "         FROM " + RetSqlName("SC5")            + CHR(13)
   cSql += "        WHERE C5_FILIAL  = SC6.C6_FILIAL   "   + CHR(13)
   cSql += "          AND C5_NUM     = SC6.C6_NUM      "   + CHR(13)
   cSql += "          AND D_E_L_E_T_ = '') AS VENDEDOR,"   + CHR(13)
   cSql += "       SA3.A3_NOME"                            + CHR(13)
   cSql += "  FROM " + RetSqlName("SC6") + " SC6, "        + CHR(13)
   cSql += "       " + RetSqlName("SA3") + " SA3  "        + CHR(13)
   cSql += " WHERE SC6.C6_FILIAL  = '" + Substr(cComboBx3,01,02) + "'" + CHR(13)
   cSql += "   AND SC6.D_E_L_E_T_ = ''"                    + CHR(13)
   cSql += "   AND (SELECT C5_EMISSAO "                    + CHR(13)
   cSql += "          FROM " + RetSqlName("SC5")           + CHR(13)
   cSql += "         WHERE C5_FILIAL  = SC6.C6_FILIAL "    + CHR(13)
   cSql += "           AND C5_NUM     = SC6.C6_NUM    "    + CHR(13)
   cSql += "           AND D_E_L_E_T_ = '') >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "', 103)" + CHR(13)
   cSql += "   AND (SELECT C5_EMISSAO "                    + CHR(13)
   cSql += "          FROM " + RetSqlName("SC5")           + CHR(13)
   cSql += "         WHERE C5_FILIAL  = SC6.C6_FILIAL"     + CHR(13)
   cSql += "           AND C5_NUM     = SC6.C6_NUM   "     + CHR(13)
   cSql += "           AND D_E_L_E_T_ = '') <= CONVERT(DATETIME,'" + Dtoc(dFinal) + "', 103)" + CHR(13)

   // ##################################### 
   // Pesquisa conforme Status informado ##
   // #####################################
   Do Case
      Case Substr(cComboBx2,01,02) == "AA"
           cSql += "   AND SC6.C6_STATUS IN ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '13', '15')" + CHR(13)
      Case Substr(cComboBx2,01,02) == "BB"
           cSql += "   AND SC6.C6_STATUS IN ('11', '12')" + CHR(13)
      Case Substr(cComboBx2,01,02) == "TT"
           cSql += "   AND SC6.C6_STATUS IN ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15')" + CHR(13)
      Case Substr(cComboBx2,01,02) == "CC"
           cSql += "   AND SC6.C6_STATUS IN ('08', '10')" + CHR(13)
      Otherwise
           cSql += "   AND SC6.C6_STATUS = '" + Substr(cComboBx2,01,02) + "'" + CHR(13)
   EndCase        

   // ##############################################
   // Pesquisa pedidos por Vendedores selecionado ##
   // ##############################################
   If Substr(cComboBx1,01,06) == "000000"
   Else
      cSql += "   AND (SELECT C5_VEND1" + CHR(13)
      cSql += "          FROM " + RetSqlName("SC5") + CHR(13)
      cSql += "         WHERE C5_FILIAL  = SC6.C6_FILIAL   " + CHR(13)
      cSql += "           AND C5_NUM     = C6_NUM          " + CHR(13)
      cSql += "           AND D_E_L_E_T_ = '') = '" + Alltrim(Substr(cComboBx1,03,06)) + "'" + CHR(13)
   Endif

   // #################################################
   // Pesquisa pelo pedido Inicial e Final informado ##
   // #################################################
   If !Empty(Alltrim(cPedidoI))
      cSql += "   AND SC6.C6_NUM >= '" + Alltrim(cPedidoI) + "'" + CHR(13)
      cSql += "   AND SC6.C6_NUM <= '" + Alltrim(cPedidof) + "'" + CHR(13)
   Endif

   // ##################################
   // Pesquisa pelo Cliente informado ##
   // ##################################
   If !Empty(Alltrim(cCliente))
      cSql += "  AND SC6.C6_CLI  = '" + Alltrim(cCliente) + "'" + CHR(13)
//    cSql += "  AND SC6.C6_LOJA = '" + Alltrim(cLoja)    + "'" + CHR(13)
   Endif

   cSql += "   AND (SELECT C5_VEND1"                       + CHR(13)
   cSql += "          FROM " + RetSqlName("SC5")           + CHR(13)
   cSql += "         WHERE C5_FILIAL  = SC6.C6_FILIAL   "  + CHR(13)
   cSql += "           AND C5_NUM     = C6_NUM          "  + CHR(13)
   cSql += "           AND D_E_L_E_T_ = '') = SA3.A3_COD"  + CHR(13)
   cSql += "   AND SA3.A3_FILIAL = ''"                     + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDOS", .T., .T. )
   
   T_PEDIDOS->( DbGoTop() )

   nRegua := 0
   
   WHILE !T_PEDIDOS->( EOF() )
      
      // ################################
      // Pesquisa o nº da Oportunidade ##
      // ################################
//      If Select("T_OPORTUNIDADE") > 0
//         T_OPORTUNIDADE->( dbCloseArea() )
//      EndIf
//      
//      cSql := ""
//      cSql := "SELECT DISTINCT SC6.C6_NUMORC,"
//      cSql += "                SCJ.CJ_NROPOR "
//      cSql += "  FROM " + RetSqlName("SC6") + " SC6, "
//      cSql += "       " + RetSqlName("SCJ") + " SCJ  "
//      cSql += " WHERE SC6.C6_FILIAL  = '" + Alltrim(T_PEDIDOS->C6_FILIAL) + "'"
//      cSql += "   AND SC6.C6_NUM     = '" + Alltrim(T_PEDIDOS->C6_NUM)    + "'"
//      cSql += "   AND SC6.D_E_L_E_T_ = ''"
//      cSql += "   AND SCJ.CJ_FILIAL  = SC6.C6_FILIAL"
//      cSql += "   AND SCJ.CJ_NUM     = SUBSTRING(SC6.C6_NUMORC,01,06)"
//      cSql += "   AND SCJ.D_E_L_E_T_ = ''"
//
//      cSql := ChangeQuery( cSql )
//      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OPORTUNIDADE", .T., .T. )

//      If T_OPORTUNIDADE->( EOF() )                 
         cOportunidade := ""
//      Else   
//         cOportunidade := T_OPORTUNIDADE->CJ_NROPOR
//      Endif

      // ########################################################################################
      // Pesquisa o nome do cliente ou fornecedor conforme o tipo de pedido de venda (C5_TIPO) ##
      // ########################################################################################
      Do Case 
         Case T_PEDIDOS->TIPO == "D"
              kCliente := Posicione( "SA2", 1, xFilial("SA2") + T_PEDIDOS->C6_CLI + T_PEDIDOS->C6_LOJA, "A2_NOME" )
         Case T_PEDIDOS->TIPO == "B"
              kCliente := Posicione( "SA2", 1, xFilial("SA2") + T_PEDIDOS->C6_CLI + T_PEDIDOS->C6_LOJA, "A2_NOME" )
         Otherwise       
              kCliente := Posicione( "SA1", 1, xFilial("SA1") + T_PEDIDOS->C6_CLI + T_PEDIDOS->C6_LOJA, "A1_NOME" )
      EndCase                               

      // #############################################
      // Alimenta o array aBrowse para visualização ##
      // #############################################
      aAdd( aBrowse, { T_PEDIDOS->C6_FILIAL,;
                       T_PEDIDOS->C6_NUM   ,;
                       Substr(T_PEDIDOS->EMISSAO,07,02) + "/" + Substr(T_PEDIDOS->EMISSAO,05,02) + "/" + Substr(T_PEDIDOS->EMISSAO,01,04) ,;
                       IIF(T_PEDIDOS->MOEDA == 1, "R$", "US$") ,;
                       T_PEDIDOS->C6_CLI   ,;
                       T_PEDIDOS->C6_LOJA  ,;
                       kCliente             ,;
                       T_PEDIDOS->VENDEDOR ,;
                       T_PEDIDOS->A3_NOME})
      T_PEDIDOS->( DbSkip() )
   ENDDO   

   If ___TipoPesquisa == 1
      If Len(aBrowse) <> 0
         queproduto(aBrowse[01,01], aBrowse[01,02], ___TipoPesquisa)
      Endif   
      Return(.T.)
   Endif   

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07],;
                         aBrowse[oBrowse:nAt,08],;
                         aBrowse[oBrowse:nAt,09]} }

   // Carrega o List com as informações do primeiro pedido do grid
   If Len(aBrowse) <> 0
      queproduto(aBrowse[01,01], aBrowse[01,02], ___TipoPesquisa)
   Else
      MsgAlert("Não existem dados a serem visualizados para esta seleção de filtro.")
   Endif   

   cPedidoI := Space(06)
   cPedidoF := Space(06)
   cCliente := Space(06)
   cLoja    := Space(03)
   cNome    := Space(60)

   oGet3:Refresh()
   oGet4:Refresh()
   oGet5:Refresh()
   oGet6:Refresh()
   oGet7:Refresh()

Return(.T.)

// Função que pesquisa os dados do pedido selecionado
Static Function queproduto(_Filial, _Pedido, ___TipoPesquisa)

   Local cSql 

   If Empty(Alltrim(_Pedido))
      Return(.T.)
   Endif
      
   aDetalhe := {}

   If Select("T_DETALHE") > 0
      T_DETALHE->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT SC6.C6_STATUS ,"
   cSql += "       SC6.C6_NUM    ,"
   cSql += "       SC6.C6_ITEM   ,"
   cSql += "       SC6.C6_PRODUTO,"
   cSql += "       SB1.B1_DESC   ,"
   cSql += "       SC6.C6_QTDVEN ,"
   cSql += "       SC6.C6_PRCVEN ,"
   cSql += "       SC6.C6_PRVCOMP,"
   cSql += "       SC6.C6_VALOR  ,"
   cSql += "       SC6.C6_LACRE  ,"
   cSql += "       SC6.C6_ORDC   ,"
   cSql += "       SB1.B1_LOCALIZ,"
   cSql += "       ' ' AS LOG    ,"
   cSql += "       SC6.C6_NOTA   ,"
   cSql += "       SC6.C6_SERIE  ,"
   cSql += "       SC6.C6_DATFAT ,"
   cSql += "       SC6.C6_ENTREG ,"
   cSql += "       SC6.C6_SUGENTR,"
   cSql += "      (SELECT C5_TRANSP  FROM " + RetSqlName("SC5") + " WHERE C5_FILIAL = SC6.C6_FILIAL AND C5_NUM = SC6.C6_NUM AND D_E_L_E_T_ = '') AS TRANSPO,"
   cSql += "      (SELECT F2_ESPECI1 FROM " + RetSqlName("SF2") + " WHERE F2_FILIAL = SC6.C6_FILIAL AND F2_DOC = SC6.C6_NOTA AND F2_SERIE = SC6.C6_SERIE AND D_E_L_E_T_ = '') AS ESPECIE ,"
   cSql += "      (SELECT F2_VOLUME1 FROM " + RetSqlName("SF2") + " WHERE F2_FILIAL = SC6.C6_FILIAL AND F2_DOC = SC6.C6_NOTA AND F2_SERIE = SC6.C6_SERIE AND D_E_L_E_T_ = '') AS VOLUME  ,"
   cSql += "      (SELECT F2_PLIQUI  FROM " + RetSqlName("SF2") + " WHERE F2_FILIAL = SC6.C6_FILIAL AND F2_DOC = SC6.C6_NOTA AND F2_SERIE = SC6.C6_SERIE AND D_E_L_E_T_ = '') AS PLIQUIDO,"
   cSql += "      (SELECT F2_PBRUTO  FROM " + RetSqlName("SF2") + " WHERE F2_FILIAL = SC6.C6_FILIAL AND F2_DOC = SC6.C6_NOTA AND F2_SERIE = SC6.C6_SERIE AND D_E_L_E_T_ = '') AS PBRUTO  ,"
   cSql += "      (SELECT F2_HREXPED FROM " + RetSqlName("SF2") + " WHERE F2_FILIAL = SC6.C6_FILIAL AND F2_DOC = SC6.C6_NOTA AND F2_SERIE = SC6.C6_SERIE AND D_E_L_E_T_ = '') AS HORA    ,"
   cSql += "      (SELECT F2_CONHECI FROM " + RetSqlName("SF2") + " WHERE F2_FILIAL = SC6.C6_FILIAL AND F2_DOC = SC6.C6_NOTA AND F2_SERIE = SC6.C6_SERIE AND D_E_L_E_T_ = '') AS CONHECIMENTO,"
   cSql += "      (SELECT F2_POSTAL  FROM " + RetSqlName("SF2") + " WHERE F2_FILIAL = SC6.C6_FILIAL AND F2_DOC = SC6.C6_NOTA AND F2_SERIE = SC6.C6_SERIE AND D_E_L_E_T_ = '') AS COD_POSTAL"   
   cSql += "  FROM " + RetSqlName("SC6") + " SC6, "
   cSql += "       " + RetSqlName("SB1") + " SB1  "
   cSql += " WHERE SB1.B1_FILIAL  = ''            "
   cSql += "   AND SB1.B1_COD     = SC6.C6_PRODUTO"
   cSql += "   AND SC6.D_E_L_E_T_ = ''            "
   cSql += "   AND SC6.C6_FILIAL  = '" + Alltrim(_Filial) + "'"
   cSql += "   AND SC6.C6_NUM     = '" + Alltrim(_Pedido) + "'"
   cSql += "   AND SC6.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DETALHE", .T., .T. )

   T_DETALHE->( DbGoTop() )
   
   If T_DETALHE->( EOF() )
      aAdd( aDetalhe, { "","","","","","","","","","","","","","","","","","","","","","","","",""  })
   Else
      WHILE !T_DETALHE->( EOF() )
      
         Do Case
            Case T_DETALHE->C6_STATUS == "01"
                 nStatus  := "Aguardando Liberação"
                 cLegenda := "1" 
            Case T_DETALHE->C6_STATUS == "02"
                 nStatus  := "Aguardando Liberação Margem"
                 cLegenda := "2" 
            Case T_DETALHE->C6_STATUS == "03"
                 nStatus  := "03-Aguardando Liberação de Credito"
                 cLegenda := "3" 
            Case T_DETALHE->C6_STATUS == "04"
                 nStatus  := "04-Aguardando Liberação de Estoque"
                 cLegenda := "4" 
            Case T_DETALHE->C6_STATUS == "05"
                 nStatus  := "05-Aguardando data de entrega"
                 cLegenda := "5" 
            Case T_DETALHE->C6_STATUS == "06"
                 nStatus  := "06-Em compra"
                 cLegenda := "6" 
            Case T_DETALHE->C6_STATUS == "07"
                 nStatus  := "07-Em produção"
                 cLegenda := "7" 
            Case T_DETALHE->C6_STATUS == "08"
                 nStatus  := "08-Aguardando separação estoque"
                 cLegenda := "8" 
            Case T_DETALHE->C6_STATUS == "09"
                 nStatus  := "09-Aguardando cliente"
                 cLegenda := "9" 
            Case T_DETALHE->C6_STATUS == "10"
                 nStatus  := "10-Aguardando faturamento"
                 cLegenda := "X" 
            Case T_DETALHE->C6_STATUS == "11"
                 nStatus  := "11-Item faturado"
                 cLegenda := "A" 
            Case T_DETALHE->C6_STATUS == "12"
                 nStatus  := "12-Item expedido"
                 cLegenda := "B" 
            Case T_DETALHE->C6_STATUS == "13"
                 nStatus  := "13-Aguardando distribuidor"
                 cLegenda := "C" 
            Case T_DETALHE->C6_STATUS == "14"
                 nStatus  := "14-Pedido cancelado"
                 cLegenda := "D" 
            Case T_DETALHE->C6_STATUS == "15"
                 nStatus  := "15-Análise de Crédito Rejeitado"
                 cLegenda := "E" 
            Otherwise
                 nStatus := "Status Indefinido"
                 cLegenda := "E" 
         EndCase         

         // Pesquisa a data de entrega de produtos se houver
         If Select("T_PREVISTO") > 0
            T_PREVISTO->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT SUBSTRING(C7_DATPRF,07,02) + '/' + SUBSTRING(C7_DATPRF,05,02) + '/' +  SUBSTRING(C7_DATPRF,01,04) AS PREVISTO"
         cSql += "  FROM " + RetSqlName("SC7")
         cSql += " WHERE C7_FILIAL  = '01'"
         cSql += "   AND C7_PRODUTO = '" + Alltrim(T_DETALHE->C6_PRODUTO) + "'"
         cSql += "   AND C7_QUANT <> C7_QUJE"
         cSql += "   AND D_E_L_E_T_ = ''"
         cSql += " ORDER BY C7_DATPRF DESC"
      
         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PREVISTO", .T., .T. )

         cDatPrevista := IIF(T_PREVISTO->( EOF() ), Ctod("  /  /    "), Ctod(T_PREVISTO->PREVISTO))

         // Carrega o Grid com os dados dos produtos do pedido selecionado
         aAdd( aDetalhe, { cLegenda                                       ,;
                           nStatus                                        ,;
                           T_DETALHE->C6_NUM                              ,;
                           T_DETALHE->C6_ITEM                             ,;
                           T_DETALHE->C6_PRODUTO                          ,;
                           T_DETALHE->B1_DESC                             ,;
                           T_DETALHE->C6_QTDVEN                           ,;         
                           T_DETALHE->C6_PRCVEN                           ,;
                           T_DETALHE->C6_VALOR                            ,;
                           IIF(T_DETALHE->C6_LACRE   == "S", "SIM", "NÃO"),;
                           IIF(T_DETALHE->B1_LOCALIZ == "S", "SIM", "NÃO"),;
                           cDatPrevista                                   ,;
                           T_DETALHE->C6_NOTA                             ,;
                           T_DETALHE->C6_SERIE                            ,;
                           Substr(T_DETALHE->C6_DATFAT,07,02) + "/" + Substr(T_DETALHE->C6_DATFAT,05,02) + "/" + Substr(T_DETALHE->C6_DATFAT,01,04) ,;
                           T_DETALHE->TRANSPO                             ,;
     			           IIF(T_DETALHE->TRANSPO <> '', Posicione( "SA4", 1, xFilial("SA4") + T_DETALHE->TRANSPO, "A4_NOME" ), ''),;
                           T_DETALHE->ESPECIE                             ,;
                           T_DETALHE->VOLUME                              ,;
                           T_DETALHE->PLIQUIDO                            ,;
                           T_DETALHE->PBRUTO                              ,;
                           T_DETALHE->HORA                                ,;
                           T_DETALHE->CONHECIMENTO                        ,;
                           T_DETALHE->C6_ORDC                             ,;
                           T_DETALHE->COD_POSTAL                          })
         T_DETALHE->( DbSkip() )                           

         //Substr(T_DETALHE->C6_SUGENTR,07,02) + "/" + Substr(T_DETALHE->C6_SUGENTR,05,02) + "/" + Substr(T_DETALHE->C6_SUGENTR,01,04) ,;

      ENDDO   
   Endif
      
   If ___TipoPesquisa == 1
      Return(.T.)
   Endif

   oDetalhe:SetArray( aDetalhe )
   oDetalhe:bLine := {||{If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "A", oCancel  ,;
                         If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "B", oCancel  ,;
                         If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "C", oCancel  ,;
                         If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "D", oCancel  ,;
                         If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "E", oCancel  ,;
                         If(Alltrim(aDetalhe[oDetalhe:nAt,01]) == "9", oEncerra, ""))))))))))))))),;
      		    		 aDetalhe[oDetalhe:nAt,02],;
          		    	 aDetalhe[oDetalhe:nAt,03],;
          		    	 aDetalhe[oDetalhe:nAt,04],;
          		    	 aDetalhe[oDetalhe:nAt,05],;
          		    	 aDetalhe[oDetalhe:nAt,06],;
          		    	 aDetalhe[oDetalhe:nAt,07],;
          		    	 aDetalhe[oDetalhe:nAt,08],;
          		    	 aDetalhe[oDetalhe:nAt,09],;          		    		  
          		    	 aDetalhe[oDetalhe:nAt,10],;
          		    	 aDetalhe[oDetalhe:nAt,11],;
          		    	 aDetalhe[oDetalhe:nAt,12],;          		    		  
          		    	 aDetalhe[oDetalhe:nAt,13],;
          		    	 aDetalhe[oDetalhe:nAt,14],;
          		    	 aDetalhe[oDetalhe:nAt,15],;          		    		  
          		    	 aDetalhe[oDetalhe:nAt,16],;
          		    	 aDetalhe[oDetalhe:nAt,17],;
          		    	 aDetalhe[oDetalhe:nAt,18],;          		    		  
          		    	 aDetalhe[oDetalhe:nAt,19],;
          		    	 aDetalhe[oDetalhe:nAt,20],;
          		    	 aDetalhe[oDetalhe:nAt,21],;
          		    	 aDetalhe[oDetalhe:nAt,22],;
          		    	 aDetalhe[oDetalhe:nAt,23],;
          		    	 aDetalhe[oDetalhe:nAt,24],;          		    		  
          		    	 aDetalhe[oDetalhe:nAt,25]}}
   oDetalhe:Refresh()
  
Return(.T.)

// Função que pesquisa os nºs de séries do p´roduto selecionado
Static Function PegaNrSerie()

   Private oDlgS

   Private aSeries := {}
   Private oSeries

   If Alltrim(aDetalhe[oDetalhe:nAt,11]) <> "SIM"
      MsgAlert("Produto não tem seu controle por nº de série.")
      Return(.T.)
   Endif

   If Empty(Alltrim(aDetalhe[oDetalhe:nAt,13]))
      MsgAlert("Produto ainda não faturado. Aguarde Faturamento para pesquisa dos nºs de séries.")
      Return(.T.)
   Endif                              

   If Select("T_SERIES") > 0
      T_SERIES->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT DB_NUMSERI"
   cSql += "  FROM " + RetSqlName("SDB")
   cSql += " WHERE DB_FILIAL  = '" + Alltrim(aBrowse[oBrowse:nAt,01])   + "'"
   cSql += "   AND DB_PRODUTO = '" + Alltrim(aDetalhe[oDetalhe:nAt,05]) + "'"
   cSql += "   AND DB_DOC     = '" + Alltrim(aDetalhe[oDetalhe:nAt,13]) + "'"
   cSql += "   AND DB_SERIE   = '" + Alltrim(aDetalhe[oDetalhe:nAt,14]) + "'"
   cSql += "   AND DB_CLIFOR  = '" + Alltrim(aBrowse[oBrowse:nAt,05])   + "'"
   cSql += "   AND DB_LOJA    = '" + Alltrim(aBrowse[oBrowse:nAt,06])   + "'"
   cSql += "   AND D_E_L_E_T_ = ''
   cSql += " ORDER BY DB_NUMSERI"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERIES", .T., .T. )

   If T_SERIES->( EOF() )
      aAdd( aSeries, { "" } )
   Else
      T_SERIES->( DbGoTop() )
      WHILE !T_SERIES->( EOF() )
         aAdd( aSeries, { T_SERIES->DB_NUMSERI })
         T_SERIES->( DbSkip() )
      ENDDO
   Endif

   DEFINE MSDIALOG oDlgS TITLE "Nºs de Séries" FROM C(178),C(181) TO C(534),C(450) PIXEL

   @ C(005),C(005) Say "Nº de Séries do produto selecionado" Size C(104),C(008) COLOR CLR_BLACK PIXEL OF oDlgS

   @ C(162),C(091) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgS ACTION( oDlgs:End() )

   // Cria Componentes Padroes do Sistema
   @ 015,005 LISTBOX oSeries FIELDS HEADER "Nºs de Séries" PIXEL SIZE 160,188 OF oDlgS ;
                            ON dblClick(aSeries[oSeries:nAt,1] := !aSeries[oSeries:nAt,1],oSeries:Refresh())     
   oSeries:SetArray( aSeries )
   oSeries:bLine := {||     {aSeries[oSeries:nAt,01]}}

   ACTIVATE MSDIALOG oDlgS CENTERED 

Return(.T.)

// Tela para exibir a sequencia de logs para o item selecionado
Static Function MostraLog( _Filial, _Pedido, _Item )
	
	Local _cTitle := "Log de Status - PV: " + _Pedido +" Item: " + _Item
	Local cQuery := ""
	Local aStru  := {}
	Local aMlog  := {}
	Local oMlog
	
	If Select("T_ZZ0") > 0
		T_ZZ0->( dbCloseArea() )
	EndIf

	cQuery := " SELECT * "
	cQuery += "   FROM "+ RetSqlName("ZZ0")
	cQuery += "  WHERE ZZ0_PEDIDO = '" + Alltrim(_Pedido) + "'"
	cQuery += "    AND ZZ0_ITEMPV = '" + Alltrim(_Item)   + "'"
	cQuery += "    AND ZZ0_FILIAL = '" + Alltrim(_Filial) + "'"
	cQuery += "    AND D_E_L_E_T_ = '' "
	cQuery += "  ORDER BY ZZ0_DATA, ZZ0_HORA "
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"T_ZZ0",.T.,.T.)
	
	// Formatar os campos para uso
	aStru := T_ZZ0->( dbStruct() )
	aEval( aStru, { |e| If( e[ 2 ] != "C" .And. T_ZZ0->( FieldPos( Alltrim( e[ 1 ] ) ) ) > 0, TCSetField( "T_ZZ0", e[ 1 ], e[ 2 ],e [ 3 ], e[ 4 ] ), Nil ) } )

	T_ZZ0->( dbGoTop() )

    // Vetor com elementos do Browse
	While !T_ZZ0->( Eof() )
		aAdd( aMlog, { Padr( Iif( T_ZZ0->ZZ0_STATUS <> '  ', T_ZZ0->ZZ0_STATUS+"-"+ Tabela( "Z0", T_ZZ0->ZZ0_STATUS ), "SEM STATUS" ),60 ),;
					   PadR( T_ZZ0->ZZ0_USER+"-"+ Upper( UsrRetName( T_ZZ0->ZZ0_USER ) ), 30 ),;
					   PadR( DtoC( StoD( T_ZZ0->ZZ0_DATA ) ), 10 ),;
					   PadR( T_ZZ0->ZZ0_HORA, 10 ),;
					   Padr( T_ZZ0->ZZ0_ORIGEM, 20 ) } )
		T_ZZ0->( dbSkip() )
	End
       
	T_ZZ0->( dbCloseArea() )

	If Len( aMlog ) > 0

		DEFINE DIALOG oDlg2 TITLE _cTitle FROM 180,180 TO 500,800 PIXEL
		                 
		// Cria Browse
		oMlog := TCBrowse():New( 01, 01, 310, 156,, {PadR('Status',60),PadR('Usuário',30),PadR('Data',10),PadR('Hora',10),PadR('Origem',25) },{20,50,50,50},oDlg2,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	
		// Seta vetor para a browse
		oMlog:SetArray(aMlog) 
	
		// Monta a linha a ser exibida no Browse
		oMlog:bLine := {||{ aMlog[ oMlog:nAt, 01 ], aMlog[ oMlog:nAt, 02 ], aMlog[ oMlog:nAT, 03 ], aMlog[ oMlog:nAT, 04 ], aMlog[ oMlog:nAT, 05 ] } }
	
		// Evento de clique no cabeçalho da browse
		oMlog:bHeaderClick := {|| Nil } 
	
		// Evento de duplo click na celula
		oMlog:bLDblClick   := {|| Nil }
	
		ACTIVATE DIALOG oDlg2 CENTERED 

	Else                
	
		MsgAlert( "Nenhum log registrado para o PV: " + Alltrim(_Pedido) + " Item: " + Alltrim(_Item) )
	EndIf

Return(.T.)
           
// Tela que mostra os filtros realizados
Static Function MostraFil()

   Local nContar  := 0
   Local lChumba  := .F.
   Local cFiltros := ""
   Local oMemo1

   Private oDlgF
   
   cFiltros := ""

   For nContar = 1 to Len(aFiltros)
   
       cFiltros := cFiltros + aFiltros[nContar,01] + chr(13) + chr(10) + ;
                              aFiltros[nContar,02] + chr(13) + chr(10) + ;
                              aFiltros[nContar,03] + chr(13) + chr(10) + ;
                              aFiltros[nContar,04] + chr(13) + chr(10) + ;
                              aFiltros[nContar,05] + chr(13) + chr(10) + ;
                              aFiltros[nContar,06] + chr(13) + chr(10) + ;
                              aFiltros[nContar,07] + chr(13) + chr(10) + ;
                              aFiltros[nContar,08] + chr(13) + chr(10) + ;
                              aFiltros[nContar,09] + chr(13) + chr(10) + chr(13) + chr(10)
                              
   Next nContar

   DEFINE MSDIALOG oDlgF TITLE "Filtros Realizados" FROM C(178),C(181) TO C(548),C(633) PIXEL

   @ C(005),C(005) GET oMemo1 Var cFiltros MEMO Size C(215),C(162) PIXEL OF oDlgF

   @ C(169),C(183) Button "Retornar" Size C(037),C(012) PIXEL OF oDlgF ACTION( oDlgF:End() )

   ACTIVATE MSDIALOG oDlgF CENTERED 

Return(.T.)

// Função que abre tela de seleção do tipo de DANFE a ser emitida
Static Function MDanfe()

   Private oDlgDanfe

   DEFINE MSDIALOG oDlgDanfe TITLE "D A N F E" FROM C(178),C(181) TO C(278),C(343) PIXEL

   @ C(005),C(008) Button "DANFE pelo Sistema" Size C(070),C(012) PIXEL OF oDlgDanfe ACTION( DPeloSistema() )
   @ C(018),C(008) Button "DANFE pelo Site"    Size C(070),C(012) PIXEL OF oDlgDanfe ACTION( U_AUTOM163() )
   @ C(032),C(008) Button "Retornar"           Size C(070),C(012) PIXEL OF oDlgDanfe ACTION( oDlgDanfe:End() )

   ACTIVATE MSDIALOG oDlgDanfe CENTERED 

Return(.T.)

// Função que Imprime a Danfe do Sistema
Static Function DPeloSistema()

   Private aFilBrw := {"", "", ""}
   
   SPEDDANFE()
   
Return(.T.)

// Função que permite que seja enviado ao cliente o e-mail de informação de faturamento/expedição de produtos
Static Function AvisoMail( k_Filial, k_Pedido, k_Cliente, k_Loja, k_NomeCli )

   Local cSql        := ""
   Local lChumba     := .F.

   Private a_Filial  := K_Filial
   Private a_Pedido  := K_Pedido
   Private a_Cliente := K_Cliente + "." + K_Loja + " - " + Alltrim(K_NomeCli)
   Private a_Email   := Space(250)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   Private oDlgA

   Private aSelecao  := {}
   Private oSelecao

   Private oOk       := LoadBitmap( GetResources(), "LBOK" )
   Private oNo       := LoadBitmap( GetResources(), "LBNO" )

   // Pesquisa o e-mail do Cliente
   If Select("T_EMAIL") > 0
      T_EMAIL->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A1_EMAIL "
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += " WHERE A1_COD     = '" + Alltrim(K_Cliente) + "'"
   cSql += "   AND A1_LOJA    = '" + Alltrim(K_Loja)    + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_EMAIL",.T.,.T.)

   If T_EMAIL->( EOF() )
      a_Email := Space(250)
   Else
      a_Email := T_EMAIL->A1_EMAIL
   Endif      

   // Verifica o e-mail do cliente
   If Empty(Alltrim(a_Email))
      MsgAlert("Cliente sem informação do e-mail para envio do aviso.")
      Return(.T.)
   Endif

   // Carrega o Array aSelecao
   If Select("T_DADOS") > 0
      T_DADOS->( dbCloseArea() )
   EndIf
    
   cSql := ""  
   cSql := "SELECT C6_NUM    ,"
   cSql += "       C6_ITEM   ,"
   cSql += "       C6_PRODUTO,"
   cSql += "       C6_DESCRI ,"
   cSql += "       C6_NOTA   ,"
   cSql += "       C6_SERIE  ,"
   cSql += "       C6_DATFAT  "
   cSql += "  FROM " + RetSqlName("SC6")
   cSql += " WHERE C6_NUM     = '" + Alltrim(K_Pedido) + "'"
   cSql += "   AND C6_FILIAL  = '" + Alltrim(K_Filial) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_DADOS",.T.,.T.)

   IF T_DADOS->( EOF() )
      MsgAlert("Não existem dados a serem visualizados para este status.")
      Return(.T.)
   Endif

   T_DADOS->( DbGoTop() )
   WHILE !T_DADOS->( EOF() )
      aAdd( aSelecao, { .F.                 ,;
                        T_DADOS->C6_ITEM    ,;
                        T_DADOS->C6_PRODUTO ,;
                        T_DADOS->C6_DESCRI  ,;
                        T_DADOS->C6_NOTA    ,;
                        T_DADOS->C6_SERIE   ,;
                        Substr(T_DADOS->C6_DATFAT,07,02) + "/" + Substr(T_DADOS->C6_DATFAT,05,02) + "/" + Substr(T_DADOS->C6_DATFAT,01,04)} )       
      T_DADOS->( DbSkip() )
   ENDDO                           

   lTemNota := .F.

   For nContar = 1 to Len(aSelecao)
       If !Empty(Alltrim(aSelecao[nContar,05]))
          lTemNota := .T.
          Exit
       Endif
   Next nContar       
       
   If !lTemNota
      MsgAlert("Não existem dados a serem enviados ao cliente para este pedido.")
      Return(.T.)
   Endif   

   // Abre a janela para seleção dos ítens do pedido de venda passados no parâmetro
   DEFINE MSDIALOG oDlgA TITLE "Envio de Aviso ao Cliente" FROM C(178),C(181) TO C(443),C(633) PIXEL

   @ C(005),C(005) Say "Filial"                                          Size C(012),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(005),C(023) Say "Nº Pedido"                                       Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(005),C(069) Say "Cliente"                                         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(029),C(005) Say "E-Mail"                                          Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(040),C(005) Say "Selecione os ítens a serem informados no e-mail" Size C(117),C(008) COLOR CLR_BLACK PIXEL OF oDlgA

   @ C(014),C(005) MsGet oGet1 Var a_Filial  Size C(012),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA When lChumba
   @ C(014),C(023) MsGet oGet2 Var a_Pedido  Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA When lChumba
   @ C(014),C(069) MsGet oGet3 Var a_Cliente Size C(151),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA When lChumba
   @ C(027),C(023) MsGet oGet4 Var a_Email   Size C(197),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA When lChumba

   @ C(116),C(005) Button "Marca Todos"    Size C(037),C(012) PIXEL OF oDlgA ACTION( MrcTodos(1) )
   @ C(116),C(043) Button "Desmarca Todos" Size C(048),C(012) PIXEL OF oDlgA ACTION( MrcTodos(2) )
   @ C(116),C(144) Button "Enviar"         Size C(037),C(012) PIXEL OF oDlgA ACTION( MandaMail(a_Filial, a_Pedido, a_Cliente, a_Email, aSelecao) )
   @ C(116),C(183) Button "Retornar"       Size C(037),C(012) PIXEL OF oDlgA ACTION( oDlgA:End() )

   @ 062,005 LISTBOX oSelecao FIELDS HEADER 'M', 'Item', 'Produto', 'Descrição dos Produtos', 'Nº N.Fiscal', 'Série', 'Emissão' PIXEL SIZE 280,080 OF oDlgA ;
                              ON dblClick(aSelecao[oSelecao:nAt,1] := !aSelecao[oSelecao:nAt,1],oSelecao:Refresh())     

   oSelecao:SetArray( aSelecao )
   oSelecao:bLine := {||     {Iif(aSelecao[oSelecao:nAt,01],oOk,oNo),;
         		     		      aSelecao[oSelecao:nAt,02],;
         	         	          aSelecao[oSelecao:nAt,03],;
         	         	          aSelecao[oSelecao:nAt,04],;
         	         	          aSelecao[oSelecao:nAt,05],;
         	         	          aSelecao[oSelecao:nAt,06],;         	         	                    	         	           
         	        	          aSelecao[oSelecao:nAt,07]}}

   ACTIVATE MSDIALOG oDlgA CENTERED 

Return(.T.)

// Função que marca e desmarca os ítens do pedido de venda
Static Function MrcTodos(__Tipo)

   Local nContar := 0
   
   For nContar = 1 to Len(aSelecao)
       aSelecao[nContar,01] := IIF(__Tipo == 1, .T., .F.)
   Next nContar
   
Return(.T.)   

// Função que envia o e-mail de aviso ao cliente
Static Function MandaMail(a_Filial, a_Pedido, a_Cliente, a_Email, aSelecao)
   
   Local nContar      := 0
   Local lMarcado     := .F.
   Local lEnvia       := .T.
   Local gItens       := ""
   Local cTexto       := ""
   Local cSql         := ""
   Local nValor_Total := 0
   Local nRecCount    := 0
   Local cSeries      := ""

   // Verifica e-mail do cliente
   If Empty(Alltrim(a_Email))
      MsgAlert("E-mail do cliente não informado.")
      Return(.T.)
   Endif

   // Verifica se houve algum item marcado
   For nContar = 1 to Len(aSelecao)
       If aSelecao[nContar,01] == .T.
          nNota    := aSelecao[nContar,05]
          lMarcado := .T.
          Exit
       Endif
   Next nContar
   
   If lMarcado == .F.
      MsgAlert("Não houve marcação de nenhum produto para envio.")
      Return(.T.)
   Endif
   
   // Verifica se houve a marcação de notas diferentes
   For nContar = 1 to Len(aSelecao)
       If aSelecao[nContar,01] == .F.
          Loop
       Endif
       If aSelecao[nContar,05] <> nNota
          lEnvia := .F.
          Exit
       Endif
   Next nContar
   
   If !lEnvia
      MsgAlert("Somente é permitido a indicação de envio de e-mail para a mesma nota fiscal.")
      Return(.T.)
   Endif

   // Agrupa os ítens do pedido para envio de aviso
   For nContar = 1 to Len(aSelecao)
       If aSelecao[nContar,01] == .F.
          Loop
       Endif
       gItens := gItens + aSelecao[nContar,02] + "|"
   Next nContar
   
   // Elimina a última vírgula da string
   gItens := Substr(gItens,01, Len(Alltrim(gItens)) - 1)
   
   // Envia para o programa que envia o aviso de faturamento ao cliente
// U_MAILSTS(a_Pedido, gItens, "F")

   // Elabora o texto para o e-email
   cTexto := ""
   cTexto := chr(13) + chr(10) + chr(13) + chr(10)
   cTexto := "Prezado Cliente"                                         + chr(13) + chr(10) + chr(13) + chr(10)
   cTexto += Substr(a_cliente,13,40)                                   + chr(13) + chr(10) + chr(13) + chr(10)
   cTexto += "Muito obrigado por utilizar nossos produtos e serviços." + chr(13) + chr(10)
   cTexto += "Abaixo seguem as informações de seu pedido:"             + chr(13) + chr(10) + chr(13) + chr(10)
   cTexto += "Nº do Pedido: " + Alltrim(a_Pedido)                      + chr(13) + chr(10)

   // Pesquisa dados dos Ítens do Pedido de Venda
   If Select("T_DADOS") > 0
      T_DADOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC6.C6_FILIAL ,"
   cSql += "       SC6.C6_PRODUTO,"
   cSql += "       SC6.C6_DESCRI ,"
   cSql += "       SC6.C6_QTDVEN ,"
   cSql += "       SC6.C6_PRCVEN ,"
   cSql += "       SC6.C6_VALOR  ,"
   cSql += "       SC6.C6_TES    ,"
   cSql += "       SC6.C6_NOTA   ,"
   cSql += "       SC6.C6_SERIE  ,"
   cSql += "       SF4.F4_TEXTO  ,"
   cSql += "       SC5.C5_TRANSP ,"
   cSql += "       SA4.A4_NOME    "
   cSql += "  FROM " + RetSqlName("SC6") + " SC6   ,"
   cSql += "       " + RetSqlName("SF4") + " SF4   ,"
   cSql += "       " + RetSqlName("SC5") + " SC5   ,"
   cSql += "       " + RetSqlName("SA4") + " SA4    "
   cSql += " WHERE SC6.C6_FILIAL  = '" + Alltrim(a_Filial) + "'"
   cSql += "   AND SC6.C6_NUM     = '" + Alltrim(a_Pedido) + "'"
   cSql += "   AND SC6.D_E_L_E_T_ = ''"
   cSql += "   AND SC6.C6_TES     = SF4.F4_CODIGO"
   cSql += "   AND SF4.D_E_L_E_T_ = ''"
   cSql += "   AND SC6.C6_FILIAL  = SC5.C5_FILIAL"
   cSql += "   AND SC6.C6_NUM     = SC5.C5_NUM   "
   cSql += "   AND SC5.C5_TRANSP  = SA4.A4_COD   "
   cSql += "   AND SA4.D_E_L_E_T_ = ''           "

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_DADOS",.T.,.T.)
   
   // Calcula o valor total do Pedido de Venda
   nValor_Total := 0
   T_DADOS->( DbGoTop() )
   WHILE !T_DADOS->( EOF() )
      nValor_Total := nValor_Total + T_DADOS->C6_VALOR
      T_DADOS->( DbSkip() )
   ENDDO

   T_DADOS->( DbGoTop() )
  
   cTexto += "Tipo de Saída: " + Alltrim(T_DADOS->F4_TEXTO)                                             + chr(13) + chr(10)
   cTexto += "Valor Total do Pedido: R$ " + Transform(nValor_Total,"@E 9,999,999.99")                   + chr(13) + chr(10)
   cTexto += "Nº Nota Fiscal: " + Alltrim(T_DADOS->C6_NOTA) + " - Série: " + Alltrim(T_DADOS->C6_SERIE) + chr(13) + chr(10)
   cTexto += "Transportadora: " + Alltrim(T_DADOS->A4_NOME)                                             + chr(13) + chr(10) + chr(13) + chr(10)
   cTexto += "DADO(S) DO(S) PRODUTO(S):"                                                                + chr(13) + chr(10) + chr(13) + chr(10)

   T_DADOS->( DbGoTop() )
   
   WHILE !T_DADOS->( EOF() )

      cTexto += "Codigo: "     + Alltrim(T_DADOS->C6_PRODUTO)                    + chr(13) + chr(10)
      cTexto += "Descrição:"   + Alltrim(T_DADOS->C6_DESCRI)                     + chr(13) + chr(10)
      cTexto += "Quantidade: " + Transform(T_DADOS->C6_QTDVEN,"@E 999,999")      + chr(13) + chr(10)
      cTexto += "Unitário: "   + Transform(T_DADOS->C6_PRCVEN,"@E 9,999,999.99") + chr(13) + chr(10)
      cTexto += "Total: "      + Transform(T_DADOS->C6_VALOR ,"@E 9,999,999.99") + chr(13) + chr(10)

      // Pesquisa os nºs de séries para o produto
      If Select("T_SERIES") > 0
         T_SERIES->( dbCloseArea() )
      EndIf

      cSql := ""   
      cSql := "SELECT DB_FILIAL ,"
      cSql += "       DB_NUMSERI "
      cSql += "  FROM " + RetSqlName("SDB")
      cSql += " WHERE DB_FILIAL  = '" + Alltrim(T_DADOS->C6_FILIAL) + "'"
      cSql += "   AND DB_DOC     = '" + Alltrim(T_DADOS->C6_NOTA)   + "'"
      cSql += "   AND DB_SERIE   = '" + Alltrim(T_DADOS->C6_SERIE)  + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_SERIES",.T.,.T.)

      Count To nRecCount

      If (nRecCount > 0)

         T_SERIES->( DbGoTop() )

         cSeries := ""

         WHILE !T_SERIES->( EOF() )
            cSeries := cSeries + Alltrim(T_SERIES->DB_NUMSERI) + ", "
            T_SERIES->( DbSkip() )
         ENDDO

         cTexto += "Nº(s) Série(s): " + Substr(cSeries,01, Len(Alltrim(cSeries)) - 2) + chr(13) + chr(10) + chr(13) + chr(10)
         
      Else
      
         cTexto += chr(13) + chr(10)
       
      Endif      

      T_DADOS->( DbSkip() )
      
   ENDDO
   
   ctexto += chr(13) + chr(10) + chr(13) + chr(10)
   cTexto += "Att."
   ctexto += chr(13) + chr(10) + chr(13) + chr(10)
   cTexto += "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA"
                                         
   // Envia o e_mail
// U_AUTOMR20(cTexto , Alltrim(a_Email), "", "Aviso de Faturamento" )

   oDlgA:End()
      
Return(.T.)

// ########################################################################### 
// Função que permite selecionar as fialiais a serem utilizadas na pesquisa ##
// ###########################################################################
Static Function SelFiliais()

   Local cMemo1	 := ""
   Local oMemo1

   Private oDlgFil

   Private aLista := {}
   Private oLista

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   Do Case
      Case cEmpAnt == "01"
           aAdd( aLista, { .F., "01 - Porto Alegre"      })
           aAdd( aLista, { .F., "02 - Caxias do Sul"     })
           aAdd( aLista, { .F., "03 - Pelotas"           })
           aAdd( aLista, { .F., "04 - Suprimentos"       })
           aAdd( aLista, { .F., "05 - São Paulo"         })
           aAdd( aLista, { .F., "06 - Espírito Santo"    })
           aAdd( aLista, { .F., "07 - Suprimentos(Novo)" })           
      Case cEmpAnt == "02"
           aAdd( aLista, { .F., "01 - Curitiba"     })
      Case cEmpAnt == "03"
           aAdd( aLista, { .F., "01 - Porto Alegre" })
   EndCase                            

   DEFINE MSDIALOG oDlgFil TITLE "Seleção de filiais para pesquisa" FROM C(178),C(181) TO C(435),C(463) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(025) PIXEL NOBORDER OF oDlgFil

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(134),C(001) PIXEL OF oDlgFil

   @ C(032),C(005) Say "Selecione as filiais a serem utilizadas para pesquisa" Size C(123),C(008) COLOR CLR_BLACK PIXEL OF oDlgFil

   @ C(113),C(005) Button "Marca Todas"    Size C(046),C(012) PIXEL OF oDlgFil ACTION( MrcSelFiliais(1) )
   @ C(113),C(052) Button "Desmarca Todas" Size C(046),C(012) PIXEL OF oDlgFil ACTION( MrcSelFiliais(2) )
   @ C(113),C(100) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlgFil ACTION( FecSelFiliais() )
   
   // Lista com os produtos do pedido selecionado
   @ 050,005 LISTBOX oLista FIELDS HEADER "M", "Filiais" PIXEL SIZE 170,90 OF oDlgFil ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     
   oLista:SetArray( aLista )

   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo), aLista[oLista:nAt,02]}}

   ACTIVATE MSDIALOG oDlgFil CENTERED 

Return(.T.)

// #####################################################################
// Função que marca/desmarca as filiais da tela de seleção de filiais ##
// #####################################################################
Static Function MrcSelFiliais(_Tipo)

   Local nContar := 0
   
   For nContar = 1 to Len(aLista)
       aLista[nContar,01] := IIF(_Tipo == 1, .T.,.F.)
   Next nContar
   
Return(.T.)

// ##############################################################################
// Função que carrega a variável cFiliais e fecha a tela de seleção de filiais ##
// ##############################################################################
Static Function FecSelFiliais()

   Local nContar   := 0

   cFiliais := ""
   
   For nContar = 1 to Len(aLista)

       If aLista[nContar,01] == .T.
          cFiliais := cFiliais + Substr(aLista[nContar,02],01,02) + "-"
       Endif

   Next nContar

   // #####################################
   // Elimina a última vírgula da string ##
   // #####################################
   cFiliais := Substr(cFiliais,01,Len(Alltrim(cFiliais)) - 1)
   oget8:Refresh()

   oDlgFil:End()   
   
Return(.T.)

// ######################################################################
// Função que abre mais opções de trabalho na tela do Painel Logística ##
// ######################################################################
Static Function AbreMaisOpcoes()

   Local cMemo1	 := ""
   Local oMemo1
 
   Private oDlgM

   DEFINE MSDIALOG oDlgM TITLE "Painel Logística" FROM C(178),C(180) TO C(495),C(419) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlgM

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(112),C(001) PIXEL OF oDlgM

   @ C(036),C(005) Button "Saldo por Endereço"        Size C(110),C(016) PIXEL OF oDlgM ACTION( MATA226() )
   @ C(053),C(005) Button "Endereçar Produtos"        Size C(110),C(016) PIXEL OF oDlgM ACTION( MATA265() )
   @ C(071),C(005) Button "Nº de Séries"              Size C(110),C(016) PIXEL OF oDlgM ACTION( U_AUTOMR30() )
   @ C(088),C(005) Button "Nº de Série por Documento" Size C(110),C(016) PIXEL OF oDlgM ACTION( U_AUTOMR66() )
   @ C(106),C(005) Button "Log Status do Pedido"      Size C(110),C(016) PIXEL OF oDlgM ACTION( MostraLog(aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aDetalhe[oDetalhe:nAt,04]) )
   @ C(123),C(005) Button "NF Não Transm./Sequencia"  Size C(110),C(016) PIXEL OF oDlgM ACTION( U_AUTOM565() )
   @ C(140),C(005) Button "Voltar"                    Size C(110),C(016) PIXEL OF oDlgM  ACTION( oDlgM:End() )

   ACTIVATE MSDIALOG oDlgM CENTERED 

Return(.T.)