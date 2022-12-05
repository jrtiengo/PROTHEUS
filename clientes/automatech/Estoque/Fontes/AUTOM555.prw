#Include "Protheus.ch"
#INCLUDE "jpeg.ch"    

//************************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                             *
// --------------------------------------------------------------------------------- *
// Referencia: AUTOM555.PRW                                                          *
// Parâmetros: Nenhum                                                                *
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                       *
// --------------------------------------------------------------------------------  *
// Autor.....: Harald Hans Löschenkohl                                               *
// Data......: 05/04/2017                                                            *
// Objetivo..: Programa que permite realizar consulta de pedidos de venda com Status *
//             = 05 - Aguardando Data de Entrega. Permitee aonda o usuário alterar a *
//             Data de Entrega do Pedido de Venda.                                   *
//************************************************************************************

User Function AUTOM555()

   MsgRun("Aguarde! Abrindo o Painel de Produção ...", "Programa: AUTOM555",{|| xAUTOM555() })
                                                                                 
Return(.T.)

// ############################                
// Abre o Paunel de Produção ##
// ############################admin
Static Function xAUTOM555()

   Local cSql    := ""
   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private cDataInicial := Ctod("  /  /    ")
   Private cDataFinal   := Ctod("  /  /    ")
   Private cPedido	    := Space(06)
   Private cCliente	    := Space(06)
   Private cLoja	    := Space(03)
   Private cNomeCli	    := Space(40)
   Private cProduto	    := Space(30)
   Private cNomePro 	:= Space(60)
   Private cVencer      := 0
   Private cVencidos    := 0
   Private nValorTotal  := 0

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
   Private oGet10   
   Private oGet11   
   
   Private lRaizCodigo := .F.
   Private oCheckBox1

   Private aVendedor   := {}
   Private cComboBx1
   
   Private aStatus     := {"04 - Aguardando Lib.Estoque", "05 - Aguardando Data de Entrega", "06 - Em Compra", "07 - Em Produção (Normal)", "7A - Em Produção (Avulsa)", "08 - Aguardando Separação de Estoque", "XX - OP Sem Vínculo PV", "00 - Todos Status"}
   Private cComboBx2

   Private aLegenda    := {"1 - Data Entrega A Vencer", "2 - Data Entrega Vencidas", "3 - Ambas"}
   Private cComboBx3

   // Declara as Legendas
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

   Private aBrowse   := {}
   Private oBrowse

   aStatus := {}

   aAdd( aStatus, "01 - Aguardando Liberação"     )
   aAdd( aStatus, "02 - Aguardando Lib. Margem"   )
   aAdd( aStatus, "03 - Aguardando Lib. Crédito"  )
   aAdd( aStatus, "04 - Aguardando Lib. Estoque"  )
   aAdd( aStatus, "05 - Aguardando Data Entrega"  )
   aAdd( aStatus, "06 - Em compra"                )
   aAdd( aStatus, "07 - Em produção"              )
   aAdd( aStatus, "08 - Aguardando Sep. Estoque"  )
   aAdd( aStatus, "09 - Aguardando Cliente"       )
   aAdd( aStatus, "10 - Aguardando Faturamento"   )
   aAdd( aStatus, "11 - Item faturado"            )
   aAdd( aStatus, "12 - Item expedido"            )
   aAdd( aStatus, "13 - Aguardando Distribuidor"  )
   aAdd( aStatus, "14 - Pedido Cancelado"         )
   aAdd( aStatus, "15 - Pedido Crédito Rejeitado" )
   aAdd( aStatus, "XX - OP Sem Vínculo PV"        )
   aAdd( aStatus, "00 - Todos Status"             )

   Private oDlg

   U_AUTOM628("AUTOM555")

   // ################################
   // Carrega o combo de Vendedores ##
   // ################################
   If Select("T_VENDEDORES") > 0
      T_VENDEDORES->( dbCloseArea() )
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
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDORES", .T., .T. )

   aVendedor := {}

   aAdd( aVendedor, "000000 - Todos os Vendedores" )

   T_VENDEDORES->( DbGoTop() )

   WHILE !T_VENDEDORES->( EOF() )

      If Empty(Alltrim(T_VENDEDORES->A3_NOME))
         T_VENDEDORES->( DbSkip() )         
         Loop
      Endif   

      aAdd( aVendedor, T_VENDEDORES->A3_COD + " - " + Alltrim(T_VENDEDORES->A3_NOME) )

      T_VENDEDORES->( DbSkip() )

   ENDDO

   // ##############################
   // Desenha a tela para display ##
   // ##############################
// DEFINE MSDIALOG oDlg TITLE "Pedidos com Data Programada de Entrega" FROM C(178),C(181) TO C(614),C(896) PIXEL

   DEFINE MSDIALOG oDlg TITLE "Pedidos com Data Programada de Entrega" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlg
   @ C(058),C(363) Jpeg FILE "br_verde.bmp"    Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(058),C(436) Jpeg FILE "br_vermelho.bmp" Size C(009),C(009) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg
   @ C(081),C(002) GET oMemo2 Var cMemo2 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(004),C(427) Say "Vlr Total Produtos/Pedidos" Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(005) Say "Dta Entrega Inicial"        Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(054) Say "Dta Entrega Final"          Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(103) Say "Nº Ped.Venda"               Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(144) Say "Cliente"                    Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(057),C(005) Say "Produto"                    Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(057),C(200) Say "Vendedor"                   Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(354) Say "Status"                     Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(427) Say "Legenda"                    Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(058),C(372) Say "Pedidos A Vencer"           Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(058),C(443) Say "Pedidos Vencidos"           Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(011),C(427) MsGet    oGet11     Var   nValorTotal  Size C(073),C(009) COLOR CLR_BLACK Picture "@E 9,999,999,999.99" PIXEL OF oDlg When lChumba
   @ C(045),C(005) MsGet    oGet1      Var   cDataInicial Size C(042),C(009) COLOR CLR_BLACK Picture "@D" PIXEL OF oDlg
   @ C(045),C(054) MsGet    oGet2      Var   cDataFinal   Size C(042),C(009) COLOR CLR_BLACK Picture "@D" PIXEL OF oDlg
   @ C(045),C(103) MsGet    oGet3      Var   cPedido      Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(045),C(144) MsGet    oGet4      Var   cCliente     Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA1")
   @ C(045),C(176) MsGet    oGet5      Var   cLoja        Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( TrazXCliente( cCliente, cLoja ) )
   @ C(045),C(200) MsGet    oGet6      Var   cNomeCli     Size C(152),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(045),C(354) ComboBox cComboBx2  Items aStatus      Size C(069),C(010)                              PIXEL OF oDlg
   @ C(045),C(427) ComboBox cComboBx3  Items aLegenda     Size C(072),C(010)                              PIXEL OF oDlg
   @ C(067),C(005) MsGet    oGet7      Var   cProduto     Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SB1") VALID( TrazXProduto( cProduto ) )
   @ C(067),C(069) MsGet    oGet8      Var   cNomePro     Size C(126),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(067),C(200) ComboBox cComboBx1  Items aVendedor    Size C(113),C(010)                              PIXEL OF oDlg
   @ C(035),C(200) CheckBox oCheckBox1 Var   lRaizCodigo  Prompt "Pesquisar somente raiz do código do cliente" Size C(115),C(008) PIXEL OF oDlg
   @ C(066),C(363) MsGet    oGet9      Var   cVencer      Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(066),C(436) MsGet    oGet10     Var   cVencidos    Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

//   @ C(064),C(316) Button "Pesquisar"     Size C(037),C(012) PIXEL OF oDlg ACTION( PesqEntrega() )
//   @ C(210),C(005) Button "PV"            Size C(037),C(012) PIXEL OF oDlg ACTION( MATA410() )
//   @ C(210),C(043) Button "Lib.PV"        Size C(016),C(012) PIXEL OF oDlg ACTION( MATA440() )
//   @ C(210),C(061) Button "Lib.STQ"       Size C(018),C(012) PIXEL OF oDlg ACTION( MATA455() )
//   @ C(210),C(082) Button "Anal. Credito" Size C(037),C(012) PIXEL OF oDlg ACTION( MATA450() )
//   @ C(210),C(125) Button "Dta.Entrega"   Size C(037),C(012) PIXEL OF oDlg ACTION( xAltDtaOC(aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,08], aBrowse[oBrowse:nAt,09], aBrowse[oBrowse:nAt,10], aBrowse[oBrowse:nAt,06], aBrowse[oBrowse:nAt,02]) )
//   @ C(210),C(164) Button "Vincula OC"    Size C(037),C(012) PIXEL OF oDlg ACTION( AltDtaOC( cEmpAnt, cFilAnt, aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,08], aBrowse[oBrowse:nAt,09], aBrowse[oBrowse:nAt,10], aBrowse[oBrowse:nAt,02]) )
//   @ C(210),C(202) Button "Limpa OC"      Size C(037),C(012) PIXEL OF oDlg ACTION( LimpaDadosOC( cEmpAnt, cFilAnt, aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,08], aBrowse[oBrowse:nAt,09], aBrowse[oBrowse:nAt,10], aBrowse[oBrowse:nAt,22], aBrowse[oBrowse:nAt,23], aBrowse[oBrowse:nAt,24], aBrowse[oBrowse:nAt,02]) )
//   @ C(210),C(241) Button "Vinc./Desv.OP" Size C(042),C(012) PIXEL OF oDlg ACTION( VincDesvOP(aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,09], aBrowse[oBrowse:nAt,08], aBrowse[oBrowse:nAt,10], aBrowse[oBrowse:nAt,12], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,13]) )
//   @ C(210),C(289) Button "O.Produção"    Size C(037),C(012) PIXEL OF oDlg ACTION( MATA650() )
//   @ C(210),C(327) Button "Impressão OP"  Size C(037),C(012) PIXEL OF oDlg ACTION( U_AUTR314() )
//   @ C(210),C(371) Button "Sld.Prod"      Size C(025),C(012) PIXEL OF oDlg ACTION( xSaldoProd(aBrowse[oBrowse:nAt,09]) )
//   @ C(210),C(397) Button "Sld.Comp."     Size C(025),C(012) PIXEL OF oDlg ACTION( xSaldoProd(aBrowse[oBrowse:nAt,11]) )
//   @ C(210),C(424) Button "Kardex"        Size C(025),C(012) PIXEL OF oDlg ACTION( AbreKardexP(aBrowse[oBrowse:nAt,09]) )


   @ C(064),C(316) Button "Pesquisar"     Size C(037),C(012) PIXEL OF oDlg ACTION( PesqEntrega() )
   @ C(210),C(005) Button "PV"            Size C(037),C(012) PIXEL OF oDlg ACTION( xAbreProgramas(1) )
   @ C(210),C(043) Button "Lib.PV"        Size C(016),C(012) PIXEL OF oDlg ACTION( xAbreProgramas(2) )
   @ C(210),C(061) Button "Lib.STQ"       Size C(018),C(012) PIXEL OF oDlg ACTION( xAbreProgramas(3) )
   @ C(210),C(082) Button "Anal. Credito" Size C(037),C(012) PIXEL OF oDlg ACTION( xAbreProgramas(4) )
   @ C(210),C(125) Button "Dta.Entrega"   Size C(037),C(012) PIXEL OF oDlg ACTION( xAltDtaOC(aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,08], aBrowse[oBrowse:nAt,09], aBrowse[oBrowse:nAt,10], aBrowse[oBrowse:nAt,06], aBrowse[oBrowse:nAt,02]) )
   @ C(210),C(164) Button "Vincula OC"    Size C(037),C(012) PIXEL OF oDlg ACTION( AltDtaOC( cEmpAnt, cFilAnt, aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,08], aBrowse[oBrowse:nAt,09], aBrowse[oBrowse:nAt,10], aBrowse[oBrowse:nAt,02]) )
   @ C(210),C(202) Button "Limpa OC"      Size C(037),C(012) PIXEL OF oDlg ACTION( LimpaDadosOC( cEmpAnt, cFilAnt, aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,08], aBrowse[oBrowse:nAt,09], aBrowse[oBrowse:nAt,10], aBrowse[oBrowse:nAt,22], aBrowse[oBrowse:nAt,23], aBrowse[oBrowse:nAt,24], aBrowse[oBrowse:nAt,02]) )
   @ C(210),C(241) Button "Vinc./Desv.OP" Size C(042),C(012) PIXEL OF oDlg ACTION( VincDesvOP(aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,09], aBrowse[oBrowse:nAt,08], aBrowse[oBrowse:nAt,10], aBrowse[oBrowse:nAt,12], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,13]) )
   @ C(210),C(289) Button "O.Produção"    Size C(037),C(012) PIXEL OF oDlg ACTION( xAbreProgramas(5) )

   @ C(210),C(327) Button "I.OP 1"        Size C(016),C(012) PIXEL OF oDlg ACTION( U_AUTR314() )
   @ C(210),C(345) Button "I.OP 2"        Size C(018),C(012) PIXEL OF oDlg ACTION( U_AUTOM669() )

   @ C(210),C(371) Button "Sld.Prod"      Size C(025),C(012) PIXEL OF oDlg ACTION( xSaldoProd(aBrowse[oBrowse:nAt,09]) )
   @ C(210),C(397) Button "Sld.Comp."     Size C(025),C(012) PIXEL OF oDlg ACTION( xSaldoProd(aBrowse[oBrowse:nAt,11]) )
   @ C(210),C(424) Button "Kardex"        Size C(025),C(012) PIXEL OF oDlg ACTION( AbreKardexP(aBrowse[oBrowse:nAt,09]) )



   @ C(210),C(461) Button "Voltar"        Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aBrowse, { "7", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })

   oBrowse := TCBrowse():New( 108 , 005, 633, 155,,{'L'                       ,; // 01 
                                                    'Status'                  ,; // 02
                                                    'Nº Ped.Venda'            ,; // 03
                                                    'Emissão'                 ,; // 04
                                                    'D.Abertura'              ,; // 05
                                                    'Entrega'                 ,; // 06
                                                    'D.Atraso'                ,; // 07
                                                    'Item'                    ,; // 08
                                                    'Produto'                 ,; // 09
                                                    'Descrição dos Produtos'  ,; // 10
                                                    'Componente'              ,; // 11
                                                    'Nº OP'                   ,; // 12
                                                    'Tp OP'                   ,; // 13
                                                    'OP Impressa'             ,; // 14
                                                    'Quantª'                  ,; // 15 
                                                    'Und'                     ,; // 16
                                                    'Cliente'                 ,; // 17
                                                    'Loja'                    ,; // 18
                                                    'Descrição dos Clientes'  ,; // 19
                                                    'Vendedor'                ,; // 20
                                                    'Descrição dos vendedores',; // 21
                                                    'O.Compra'                ,; // 22
                                                    'Dt.Prev.Entrega'         ,; // 23
                                                    'Item O.Compra'           ,; // 24
                                                    'Valor Total Produto'    },; // 25
                                                    {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,02]               ,;
                         aBrowse[oBrowse:nAt,03]               ,;
                         aBrowse[oBrowse:nAt,04]               ,;                         
                         aBrowse[oBrowse:nAt,05]               ,;                         
                         aBrowse[oBrowse:nAt,06]               ,;                         
                         aBrowse[oBrowse:nAt,07]               ,;                         
                         aBrowse[oBrowse:nAt,08]               ,;                         
                         aBrowse[oBrowse:nAt,09]               ,;                         
                         aBrowse[oBrowse:nAt,10]               ,;                         
                         aBrowse[oBrowse:nAt,11]               ,;                         
                         aBrowse[oBrowse:nAt,12]               ,;                         
                         aBrowse[oBrowse:nAt,13]               ,;                         
                         aBrowse[oBrowse:nAt,14]               ,;                         
                         aBrowse[oBrowse:nAt,15]               ,;                         
                         aBrowse[oBrowse:nAt,16]               ,;                         
                         aBrowse[oBrowse:nAt,17]               ,;                         
                         aBrowse[oBrowse:nAt,18]               ,;                         
                         aBrowse[oBrowse:nAt,19]               ,;                         
                         aBrowse[oBrowse:nAt,20]               ,;                                                                           
                         aBrowse[oBrowse:nAt,21]               ,;                                                                           
                         aBrowse[oBrowse:nAt,22]               ,;                                                                           
                         aBrowse[oBrowse:nAt,23]               ,;                                                                           
                         aBrowse[oBrowse:nAt,24]               ,;                                                                           
                         aBrowse[oBrowse:nAt,25]               }}              

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ############################################################
// Função que abre o programa selecionado na barra de botões ##
// ############################################################
Static Function xAbreProgramas(kOpcao)

   Do Case                 
      // ##################
      // Pedido de Venda ##
      // ##################
      Case kOpcao == 1
           MsgRun("Aguarde! Abrindo Pedido de Venda ...", "Programa: AUTOM555",{|| MATA410() })
           
      // ###############################
      // Liberação de Pedido de Venda ##
      // ###############################    
      Case kOpcao == 2
           MsgRun("Aguarde! Abrindo Liberação Pedido de Venda ...", "Programa: AUTOM555",{|| MATA440() })
           
      // ##########################################
      // Liberação de Estoque de Pedido de Venda ##
      // ##########################################    
      Case kOpcao == 3
           MsgRun("Aguarde! Abrindo Liberação de Estoque ...", "Programa: AUTOM555",{|| MATA455() })
                                                                                            
      // ########################################
      // Análise de Crédito de Pedido de Venda ##
      // ########################################    
      Case kOpcao == 4
           MsgRun("Aguarde! Abrindo Análise de Crédito ...", "Programa: AUTOM555",{|| MATA450() })
      
      // ####################
      // Ordem de Produção ##
      // ####################
      Case kOpcao == 5
           MsgRun("Aguarde! Abrindo Ordem de Produção ...", "Programa: AUTOM555",{|| MATA650() })

   EndCase

Return(.T.)

// ##########################################################################
// Função que pesquisa o saldo do produto ou componente conforme parâmetro ##
// ##########################################################################
Static Function xSaldoProd(_Produto)

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

// #############################################
// Função que pesquisa o fornecedor informado ##
// #############################################
Static Function TrazXCliente( _Cliente, _Loja )

   Local cSql := ""
   
   If Empty(Alltrim(_Cliente))
      cNomeCli := ""
      Return .T.
   Endif

   If Select("T_FORNECEDOR") > 0
   	  T_FORNECEDOR->( dbCloseArea() )
   EndIf

   cSql := "SELECT A1_COD , "
   cSql += "       A1_LOJA, " 
   cSql += "       A1_NOME  "
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += " WHERE A1_COD  = '" + Alltrim(_CLiente) + "'"
   cSql += "   AND A1_LOJA = '" + Alltrim(_Loja)    + "'"

	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FORNECEDOR", .T., .T. )
	
    If !T_FORNECEDOR->( EOF() )
       cCliente := T_FORNECEDOR->A1_COD
       cLoja    := T_FORNECEDOR->A1_LOJA
       cNomeCli := Alltrim(T_FORNECEDOR->A1_NOME)
    Else
       MsgAlert("Cliente informado não cadastrado.")
       cCliente := Space(06)
       cLoja    := Space(03)
       cNomeCli := ""
    Endif

Return .T.

// ################################
// Função que pesquisa o produto ##
// ################################
Static Function TrazXProduto( _Produto )

   Local cSql := ""
   
   If Empty(Alltrim(_Produto))
      cNomePro := ""
      Return .T.
   Endif

   cNomePro := Posicione( "SB1", 1, xFilial("SB1") + _Produto, "B1_DESC" )

   If Empty(Alltrim(cNomePro))
      MsgAlert("Produto informado não cadastrado.")
      cNomePro := ""
   Endif

Return .T.

// #########################################################################
// Função que pesquisa os pedidos de venda conforme parâmetros informados ##
// #########################################################################
Static Function PesqEntrega()

   MsgRun("Aguarde! Pesquisando informações conforme parâmetros ...", "Pesquisa de Informações",{|| xPesqEntrega() })

Return(.T.)

// #########################################################################
// Função que pesquisa os pedidos de venda conforme parâmetros informados ##
// #########################################################################
Static Function xPesqEntrega()

   Local cSql := ""
                                                                   
   If Substr(cComboBx2,01,02) == "00"
      If cDataInicial == Ctod("  /  /    ")
         MsgAlert("Para este tipo de consulta (Todos os Status), é necessário informar período inicial de pesquisa.")
         Return(.T.)
      Endif
         
      If cDataFinal == Ctod("  /  /    ")
         MsgAlert("Para este tipo de consulta (Todos os Status), é necessário informar período final de pesquisa.")
         Return(.T.)
      Endif
   Endif

   // #####################################################################################
   // Se Status = XX, envia para a função que pesquisa OP's sem vículo a pedido de venda ##
   // #####################################################################################
   If Substr(cComboBx2,0,02) == "XX"
      PsqOPSemPV()
      Return(.T.)
   Endif

   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC6.C6_NUM    ,"
   cSql += "       SC6.C6_STATUS ,"
   cSql += "       SC5.C5_EMISSAO,"
   cSql += "	   SC6.C6_ENTREG ,"
   cSql += "	   SC6.C6_CLI    ,"
   cSql += "	   SC6.C6_LOJA   ,"
   cSql += "	   SA1.A1_NOME   ,"
   cSql += "	   SC5.C5_VEND1  ,"
   cSql += "	   SA3.A3_NOME   ,"
   cSql += "       SC6.C6_ITEM   ,"
   cSql += "       SC6.C6_PRODUTO,"
   cSql += "       SC6.C6_NUMOP  ,"
   cSql += "       SB1.B1_DESC   ,"
   cSql += "       SC6.C6_PCOMPRA,"
   cSql += "       SC6.C6_PRVCOMP,"
   cSql += "       SC6.C6_VALOR  ,"
   cSql += "       SC6.C6_ITPCSTS,"
   cSql += "       SC6.C6_ZTPOP  ,"
   cSql += "       SC6.C6_QTDVEN ,"
   cSql += "       SC6.C6_UM      "
   cSql += "  FROM " + RetSqlName("SC6") + " SC6, "
   cSql += "       " + RetSqlName("SA1") + " SA1, "
   cSql += "	   " + RetSqlName("SC5") + " SC5, "
   cSql += "	   " + RetSqlName("SA3") + " SA3, "
   cSql += "       " + RetSqlName("SB1") + " SB1  "
   cSql += " WHERE SC6.C6_FILIAL  = '" + Alltrim(cFilAnt) + "'"
   cSql += "   AND SC6.D_E_L_E_T_ = ''"
   cSql += "   AND SA1.A1_COD     = SC6.C6_CLI "
   cSql += "   AND SA1.A1_LOJA    = SC6.C6_LOJA"
   cSql += "   AND SA1.D_E_L_E_T_ = ''         "
   cSql += "   AND SC5.C5_FILIAL  = SC6.C6_FILIAL"
   cSql += "   AND SC5.C5_NUM     = SC6.C6_NUM"
   cSql += "   AND SC5.D_E_L_E_T_ = ''"
   cSql += "   AND SA3.A3_COD     = SC5.C5_VEND1"
   cSql += "   AND SA3.D_E_L_E_T_ = ''"
   cSql += "   AND SB1.B1_COD     = SC6.C6_PRODUTO"
   cSql += "   AND SB1.D_E_L_E_T_ = ''"

   If Substr(cComboBx2,01,02) == "00"
//    cSql += "   AND SC6.C6_STATUS  IN ('04', '05', '06', '07', '08')"
   Else
      Do Case 
         Case Alltrim(Substr(cComboBx2,01,02)) == "7A"
              cSql += "   AND SC6.C6_STATUS  = '07'"
              cSql += "   AND SC6.C6_ZTPOP   = 'A'"
         Case Alltrim(Substr(cComboBx2,01,02)) == "07"
              cSql += "   AND SC6.C6_STATUS  = '07'"
              cSql += "   AND SC6.C6_ZTPOP  <> 'A'"
         Otherwise
              cSql += "   AND SC6.C6_STATUS  = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
      EndCase
   Endif
   
   If cDataInicial == Ctod("  /  /    ")
   Else

      kInicial := Strzero(Year(cDataInicial),4) + Strzero(Month(cDataInicial),2) + Strzero(Day(cDataInicial),2)
      kFinal   := Strzero(Year(cDataFinal)  ,4) + Strzero(Month(cDataFinal)  ,2) + Strzero(Day(cDataFinal)  ,2)

      cSql += "   AND SC6.C6_ENTREG >= '" + kInicial + "'"
      cSql += "   AND SC6.C6_ENTREG <= '" + kFinal   + "'"

   Endif   

   If Empty(Alltrim(cCliente))
   Else

      If lRaizCodigo == .F.
         cSql += "   AND SC6.C6_CLI  = '" + Alltrim(cCliente) + "'"
         cSql += "   AND SC6.C6_LOJA = '" + Alltrim(cLoja)    + "'"
      Else
         cSql += "   AND SC6.C6_CLI  = '" + Alltrim(cCliente) + "'"
      Endif         
   Endif

   If Substr(cComboBx1,01,06) == "000000"
   Else
      cSql += "   AND SC5.C5_VEND1 = '" + Alltrim(Substr(cComboBx1,01,06)) + "'"
   Endif                                                                             

   If Empty(Alltrim(cProduto))
   Else
      cSql += "   AND SC6.C6_PRODUTO = '" + Alltrim(cProduto) + "'"
   Endif                                                                             

   If Empty(Alltrim(cPedido))
   Else
      cSql += "   AND SC6.C6_NUM = '" + Alltrim(cPedido) + "'"
   Endif                                                                             

   cSql += " ORDER BY SC6.C6_ENTREG"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )
   
   aBrowse := {}

   cVencer   := 0
   cVencidos := 0 
   oGet9:Refresh()
   oGet10:Refresh()

   nValorTotal := 0

   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )
   
      dEmissao   := Substr(T_CONSULTA->C5_EMISSAO,07,02) + "/" + Substr(T_CONSULTA->C5_EMISSAO,05,02) + "/" + Substr(T_CONSULTA->C5_EMISSAO,01,04)
      dEntrega   := Substr(T_CONSULTA->C6_ENTREG ,07,02) + "/" + Substr(T_CONSULTA->C6_ENTREG ,05,02) + "/" + Substr(T_CONSULTA->C6_ENTREG ,01,04)
      dPCompra   := Substr(T_CONSULTA->C6_PRVCOMP,07,02) + "/" + Substr(T_CONSULTA->C6_PRVCOMP,05,02) + "/" + Substr(T_CONSULTA->C6_PRVCOMP,01,04)
      cLegenda   := IIF(Ctod(dEntrega) > Date(), "1", "9")
      kVendedor  := T_CONSULTA->C5_VEND1   + " - " + T_CONSULTA->A3_NOME
      kProduto   := T_CONSULTA->C6_PRODUTO + " - " + T_CONSULTA->B1_DESC
      kOProducao := IIF(Empty(Alltrim(T_CONSULTA->C6_NUMOP)), "", T_CONSULTA->C6_NUMOP + T_CONSULTA->C6_ITEM + "001")

      Do Case
         Case T_CONSULTA->C6_STATUS == "01"
              kStatus := "01 - Ag.Liberação"
         Case T_CONSULTA->C6_STATUS == "02"
              kStatus := "02 - Ag.Lib.Margem"
         Case T_CONSULTA->C6_STATUS == "03"
              kStatus := "03 - Ag.Lib.Crédito"
         Case T_CONSULTA->C6_STATUS == "04"
              kStatus := "04 - Ag.Lib.Estoque"
         Case T_CONSULTA->C6_STATUS == "05"
              kStatus := "05 - Dta Entrega"
         Case T_CONSULTA->C6_STATUS == "06"
              kStatus := "06 - Em Compra"
         Case T_CONSULTA->C6_STATUS == "07"
              kStatus := "07 - Em Produção"
         Case T_CONSULTA->C6_STATUS == "08"
              kStatus := "08 - Em Separação"
         Case T_CONSULTA->C6_STATUS == "09"
              kStatus := "09 - Ag. Cliente"
         Case T_CONSULTA->C6_STATUS == "10"
              kStatus := "10 - Ag. Faturamento"
         Case T_CONSULTA->C6_STATUS == "11"
              kStatus := "11 - Item Faturado"
         Case T_CONSULTA->C6_STATUS == "12"
              kStatus := "12 - Item Expedido"
         Case T_CONSULTA->C6_STATUS == "13"
              kStatus := "13 - Ag. Distribuidor"
         Case T_CONSULTA->C6_STATUS == "14"
              kStatus := "14 - Pedido Cancelado"
         Case T_CONSULTA->C6_STATUS == "15"
              kStatus := "14 - Crédito Rejeitado"
      EndCase              

      Do Case
         Case Substr(cComboBx3,01,01) == "1" // A Vencer
              If Ctod(dEntrega) <= Date()
                 T_CONSULTA->( DbSkip() )
                 Loop
              Endif
         Case Substr(cComboBx3,01,01) == "2" // Vencidos
              If cTod(dEntrega) > Date()
                 T_CONSULTA->( DbSkip() )
                 Loop
              Endif
      EndCase

      If Ctod(dEntrega) <= Date()
         cVencidos := cVencidos + 1
      Else
         cVencer   := cVencer   + 1      
      Endif

      kDiasAbertura := Date() - Ctod(dEmissao)
      kDiasAtraso   := Date() - Ctod(dEntrega)

      // ####################################################################################################
      // Se possui Ordem de produção, verifica se a mesma já foi impressa para popular coluna OP Impressa. ##
      // ####################################################################################################
      If Empty(Alltrim(T_CONSULTA->C6_NUMOP))
         kImpresso := ""
      Else
         If Select("T_IMPRESSAO") > 0
            T_IMPRESSAO->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT C2_NUM ,"
         cSql += "       C2_IMPR "
         cSql += "  FROM " + RetSqlName("SC2")
         cSql += " WHERE C2_FILIAL  = '" + Alltrim(cFilAnt)              + "'"
         cSql += "   AND C2_NUM     = '" + Alltrim(T_CONSULTA->C6_NUMOP) + "'"
         cSql += "   AND C2_ITEM    = '" + Alltrim(T_CONSULTA->C6_ITEM)  + "'"
         cSql += "   AND D_E_L_E_T_ = ''"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_IMPRESSAO", .T., .T. )
         
         If T_IMPRESSAO->( EOF() )
            kImpresso := "Não"
         Else
            kImpresso := IIF(T_IMPRESSAO->C2_IMPR == 0, "Não", "Sim")
         Endif
      Endif
         
      // ######################################################
      // Pesquisa o componente da etiqueta para visualização ##
      // ######################################################
      If Len(Alltrim(T_CONSULTA->C6_PRODUTO)) > 6
       
         If Select("T_COMPONENTE") > 0
            T_COMPONENTE->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT G1_COMP "
         cSql += "  FROM " + RetSqlName("SG1")
         cSql += " WHERE G1_COD     = '" + Alltrim(T_CONSULTA->C6_PRODUTO) + "'"
     	 cSql += "   AND D_E_L_E_T_ = ''"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMPONENTE", .T., .T. )
      
         kComponente := IIF(T_COMPONENTE->( EOF() ), space(06), T_COMPONENTE->G1_COMP)
      Else
         kComponente := Space(06)
      Endif   

      // ###################################################
      // Carrega o array aBrowse com os dados pesquisados ##
      // ###################################################


                       
      aAdd( aBrowse, { cLegenda              ,; // 01
                       kStatus               ,; // 02
                       T_CONSULTA->C6_NUM    ,; // 03
                       dEmissao              ,; // 04
                       kDiasAbertura         ,; // 05
                       dEntrega              ,; // 06
                       kDiasAtraso           ,; // 07
                       T_CONSULTA->C6_ITEM   ,; // 08
                       T_CONSULTA->C6_PRODUTO,; // 09
                       T_CONSULTA->B1_DESC   ,; // 10
                       kComponente           ,; // 11            
                       kOProducao            ,; // 12
                       T_CONSULTA->C6_ZTPOP  ,; // 13
                       kImpresso             ,; // 14
                       T_CONSULTA->C6_QTDVEN ,; // 15
                       T_CONSULTA->C6_UM     ,; // 16
                       T_CONSULTA->C6_CLI    ,; // 17                     
                       T_CONSULTA->C6_LOJA   ,; // 18    
                       T_CONSULTA->A1_NOME   ,; // 19
                       T_CONSULTA->C5_VEND1  ,; // 20
                       T_CONSULTA->A3_NOME   ,; // 21
                       T_CONSULTA->C6_PCOMPRA,; // 22
                       dPCompra              ,; // 23
                       T_CONSULTA->C6_ITPCSTS,; // 24
                       TRANSFORM(T_CONSULTA->C6_VALOR, "@E 9,999,999,999.99")}) // 25

      nValorTotal := nValorTotal + T_CONSULTA->C6_VALOR

      T_CONSULTA->( dBsKIP() )

   Enddo
         
   oGet9:Refresh()
   oGet10:Refresh()

   If Len(aBrowse) == 0
      aBrowse := {}   
      aAdd( aBrowse, { "7", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
      MsgAlert("Não existem dados a serem visualizados para estes parâmetros.")
   Endif   

   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,02]               ,;
                         aBrowse[oBrowse:nAt,03]               ,;
                         aBrowse[oBrowse:nAt,04]               ,;                         
                         aBrowse[oBrowse:nAt,05]               ,;                         
                         aBrowse[oBrowse:nAt,06]               ,;                         
                         aBrowse[oBrowse:nAt,07]               ,;                         
                         aBrowse[oBrowse:nAt,08]               ,;                         
                         aBrowse[oBrowse:nAt,09]               ,;                         
                         aBrowse[oBrowse:nAt,10]               ,;                         
                         aBrowse[oBrowse:nAt,11]               ,;                         
                         aBrowse[oBrowse:nAt,12]               ,;                         
                         aBrowse[oBrowse:nAt,13]               ,;                         
                         aBrowse[oBrowse:nAt,14]               ,;                         
                         aBrowse[oBrowse:nAt,15]               ,;                                                  
                         aBrowse[oBrowse:nAt,16]               ,;                                                  
                         aBrowse[oBrowse:nAt,17]               ,;                                                  
                         aBrowse[oBrowse:nAt,18]               ,;                                                  
                         aBrowse[oBrowse:nAt,19]               ,;                                                  
                         aBrowse[oBrowse:nAt,20]               ,;                                                  
                         aBrowse[oBrowse:nAt,21]               ,;                                                  
                         aBrowse[oBrowse:nAt,22]               ,;                                                  
                         aBrowse[oBrowse:nAt,23]               ,;                                                  
                         aBrowse[oBrowse:nAt,24]               ,;                                                  
                         aBrowse[oBrowse:nAt,25]               }}

Return(.T.)

// #########################################################################################
// Função que abre a tela de seleção da data e ordem de compra para o produto selecionado ##
// #########################################################################################
Static Function xAltDtaOC(_Pedido, _Item, _Produto, _Descricao, _Entrega, _Status)

   Local lChumba := .F.

   Local cMemo1	 := ""
	   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Local kPedido    := _Pedido
   Local kProduto   := _Produto
   Local kDescricao := _Descricao
   Local kEntrega   := Ctod(_Entrega)
   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet5

   Private oDlgE

   If Empty(Alltrim(_Pedido))
      MsgAlert("Nenhum pedido de venda selecionado para alteração.")
      Return(.T.)
   Endif

   If Substr(_Status,01,02) == "04"
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Alteração não permitida para pedidos de venda com " + chr(13) + chr(10) + "status 04 - Aguardando Liberação de Estoque.")
      Return(.T.)
   Endif

   If Substr(_Status,01,02) == "06"
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Alteração não permitida para pedidos de venda com " + chr(13) + chr(10) + "status 06 - Em Compra.")
      Return(.T.)
   Endif

   If Substr(_Status,01,02) == "08"
//      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Alteração não permitida para pedidos de venda com " + chr(13) + chr(10) + "status 08 - Aguardando Separação de Estoque.")
//      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgE TITLE "Data de Entrega de Produtos" FROM C(178),C(181) TO C(478),C(525) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlgE

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(165),C(001) PIXEL OF oDlgE
   @ C(127),C(002) GET oMemo2 Var cMemo2 MEMO Size C(165),C(001) PIXEL OF oDlgE

   @ C(037),C(005) Say "Pedido de Venda"      Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(058),C(005) Say "Produto"              Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(079),C(005) Say "Descrição do Produto" Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(102),C(005) Say "Data de Entrega"      Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
                                                                                         
   @ C(045),C(005) MsGet oGet1 Var kPedido    Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(067),C(005) MsGet oGet2 Var kProduto   Size C(064),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(089),C(005) MsGet oGet3 Var kDescricao Size C(163),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(112),C(005) MsGet oGet5 Var kEntrega   Size C(040),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE

   @ C(132),C(047) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgE ACTION( xColEntrega(_Pedido, _Item, _Produto, _Descricao, kEntrega ) )
   @ C(132),C(086) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgE ACTION( oDlgE:End() )

   ACTIVATE MSDIALOG oDlgE CENTERED 

Return(.T.)

// #######################################################################################
// Função que atualiza o nº da ordem de compra e data de entrega no produto selecionado ##
// #######################################################################################
Static Function xColEntrega(_Pedido, _Item, _Produto, _Descricao, _Entrega)

   Local cTexto := ""
   Local cTipoD := 0

   // ###############################################################################
   // Consistência para pedidos com Status inicial 05 - Aguardando Data de Entrega ##
   // ###############################################################################
   If Substr(cComboBx2,01,02) == "05"

      If _Entrega <= Date()

         cTexto := ""
         cTexto += "Atenção!"                                            + chr(13) + chr(10) + chr(13) + chr(10) 
         cTexto += "Esta alteração irá alterar o Status deste produto"   + chr(13) + chr(10)
         cTexto += "para o status 08 - Aguardando Separação de Estoque." + chr(13) + chr(10) + chr(13) + chr(10) 
         cTexto += "Deseja realmente realizar esta operação?"

         cTipoD := 2
      
      Else
   
         cTexto := ""
         cTexto += "Deseja realmente realizar esta aletração de data de entrega?"

         cTipoD := 1

      Endif

   Endif

   // ################################################################
   // Consistência para pedidos com Status inicial 07 - Em Produção ##
   // ################################################################
   If Substr(cComboBx2,01,02) == "07"

      cTexto := ""
      cTexto += "Deseja realmente realizar esta aletração de data de entrega?"

      cTipoD := 1
      
   Endif   

   If MsgYesNo(cTexto)

      // ###########################################
      // Atualiza a Data de Entrega na tabela SC6 ##
      // ###########################################
      dbSelectArea("SC6")
      dbSetOrder(1)
      If DbSeek( cFilAnt + _Pedido + _Item + _Produto )

         RecLock("SC6", .F.)

         If _Entrega <= SC6->C6_ENTREG 

	        SC6->C6_ENTREG := _Entrega

            SC6->C6_STATUS := "08"

            // #####################################################
   		    // Gravo o log de atualização de status na tabela ZZ0 ##
    	    // #####################################################
   		    U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "08", "AUTOM555", 0 )
   		    
   		 Else
   		 
	        SC6->C6_ENTREG := _Entrega

            SC6->C6_STATUS := "05"

            // #####################################################
   		    // Gravo o log de atualização de status na tabela ZZ0 ##
    	    // #####################################################
   		    U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "05", "AUTOM555", 0 )

         Endif

         MsUnlock()
      
         // ###################################################
         // Atualiza o Grid para visualização das aletrações ##
         // ###################################################
         PesqEntrega()
      
      Endif
      
   Else
     
      Return(.T.)
   
   Endif   
           
   oDlgE:End()
   
Return(.T.)

// aaqui


// #########################################################################################
// Função que abre a tela de seleção da data e ordem de compra para o produto selecionado ##
// #########################################################################################
Static Function AltDtaOC(_Empresa, _Filial, _Pedido, _Item, _Produto, _Descricao, _Status)

   Local cSql    := ""
   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1

   Private kEmpresa   := _Empresa
   Private kFilial    := _Filial
   Private kPedido    := _Pedido
   Private kProduto   := _Produto
   Private kDescricao := _Descricao

   Private oGet1
   Private oGet2
   Private oGet3

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   Private oDlgE

   Private aLista := {}
   Private oLista

   If Empty(Alltrim(kPedido))
      MsgAlert("Nenhum pedido de venda selecionado para alteração.")
      Return(.T.)
   Endif

   If Substr(_Status,01,02) <> "06"
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Alteração não permitida para pedidos de venda com " + chr(13) + chr(10) + "status diferente de 06 - Em Compras.")
      Return(.T.)
   Endif

   If Select("T_COMPRA") > 0
      T_COMPRA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC7.C7_FILIAL ,"
   cSql += "       SC7.C7_NUM    ,"
   cSql += "	   SC7.C7_DATPRF ,"
   cSql += "   	   SC7.C7_FORNECE,"
   cSql += "       SC7.C7_LOJA   ,"
   cSql += "	   SA2.A2_NOME   ,"
   cSql += "	   SC7.C7_QUANT  ,"
   cSql += "	   SC7.C7_QUJE   ,"
   cSql += "   	  (SC7.C7_QUANT - SC7.C7_QUJE) AS SALDO,"
   cSql += "       SC7.C7_ITEM    "
   cSql += "  FROM SC7" + Substr(kEmpresa,01,02) + "0 SC7 (NOLOCK),"
   cSql += "       SA2010 SA2 (NOLOCK) "
   cSql += " WHERE SC7.C7_FILIAL  = '" + Alltrim(kFilial)  + "'"
   cSql += "   AND SC7.C7_PRODUTO = '" + Alltrim(kProduto) + "'"
   cSql += "   AND SC7.C7_QUANT  <> SC7.C7_QUJE"
   cSql += "   AND SC7.D_E_L_E_T_ = ''"
   cSql += "   AND SA2.A2_COD     = SC7.C7_FORNECE"
   cSql += "   AND SA2.A2_LOJA    = SC7.C7_LOJA"
   cSql += "   AND SA2.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMPRA", .T., .T. )

   T_COMPRA->( dBgOtOP() )
   
   WHILE !T_COMPRA->( EOF() )

      aAdd( aLista, { .F.                 ,;
                      T_COMPRA->C7_NUM    ,;
                      Substr(T_COMPRA->C7_DATPRF,07,02) + "/" + Substr(T_COMPRA->C7_DATPRF,05,02) + "/" + Substr(T_COMPRA->C7_DATPRF,01,04) ,;
                      T_COMPRA->C7_FORNECE,;
                      T_COMPRA->C7_LOJA   ,;                      
                      T_COMPRA->A2_NOME   ,;
                      T_COMPRA->SALDO     ,;
                      T_COMPRA->C7_ITEM   })
                      
      T_COMPRA->( DbSkip() )
      
   ENDDO                         

   If Len(aLista) == 0
      aAdd( aLista, { .F., "", "", "", "", "", "", "" })
      MsgAlert("Nenhuma Ordem de Compra localizada para este produto.")
      Return(.T.)
   Endif

   // ########################################
   // Desenha a tela para display dos dados ##
   // ########################################
   DEFINE MSDIALOG oDlgE TITLE "Data de Entrega de Produtos" FROM C(178),C(181) TO C(479),C(758) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlgE

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(282),C(001) PIXEL OF oDlgE

   @ C(037),C(005) Say "Pedido de Venda"                                        Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(037),C(051) Say "Produto"                                                Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(058),C(005) Say "Selecione o Pedido de Compra que atenderá este produto" Size C(139),C(008) COLOR CLR_BLACK PIXEL OF oDlgE

   @ C(045),C(005) MsGet oGet1 Var kPedido    Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(045),C(051) MsGet oGet2 Var kProduto   Size C(064),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(045),C(121) MsGet oGet3 Var kDescricao Size C(162),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba

   @ C(134),C(208) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgE ACTION( ColDtaOC(_Empresa, _Filial, _Pedido, _Item, _Produto, _Descricao) )
   @ C(134),C(247) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgE ACTION( oDlgE:End() )

   // ###########################
   // Cria o display da aLista ##
   // ###########################
   @ 085,005 LISTBOX oLista FIELDS HEADER "M"                      ,; // 01
                                          "P.Compra"               ,; // 02
                                          "Dta Entrega"            ,; // 03
                                          "Fornecedor"             ,; // 04
                                          "Loja"                   ,; // 05
                                          "Descrição Fornecedores" ,; // 06
                                          "Saldo"                  ,; // 07
                                          "Item"                    ; // 08
                             PIXEL SIZE 360,080 OF oDlgE ;
                             ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     

   oLista:SetArray( aLista )

   oLista:bLine := {|| {Iif(aLista[oLista:nAt,01],oOk,oNo),;
                            aLista[oLista:nAt,02]         ,;  
                            aLista[oLista:nAt,03]         ,;  
                            aLista[oLista:nAt,04]         ,;  
                            aLista[oLista:nAt,05]         ,;  
                            aLista[oLista:nAt,06]         ,;  
                            aLista[oLista:nAt,07]         ,;  
                            aLista[oLista:nAt,08]         }}

   ACTIVATE MSDIALOG oDlgE CENTERED 

Return(.T.)

// #######################################################################################
// Função que atualiza o nº da ordem de compra e data de entrega no produto selecionado ##
// #######################################################################################
Static Function ColDtaOC(_Empresa, _Filial, _Pedido, _Item, _Produto, _Descricao)

   Local nContar  := 0
   Local lMarcado := .F.
   Local nQuantos := 0
   Local cOcompra := ""
   Local cEntrega := Ctod("  /  /    ")
   Local cItem    := ""                 
   Local cSaldo   := 0
   
   // #######################################################################
   // Verifica se houve macação de algum pedido de compra para atualização ##
   // #######################################################################
   lMarcado := .F.
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          cOcompra := aLista[nContar,02]
          cEntrega := Ctod(aLista[nContar,03])
          cItem    := aLista[nContar,08]
          cSaldo   := aLista[nContar,07]
          lMarcado := .T.
          Exit
       Endif
   Next nContar        

   If lMarcado == .F.
      MsgAlert("Nenhum pedido de compra foi selecionado.")
      Return(.T.)
   Endif
      
   // #################################################
   // Verifica se foi marcado mais do que 1 registro ##
   // #################################################
   nQuantos := 0
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          nQuantos := nQuantos + 1
       Endif
   Next nContar        

   If nQuantos > 1
      MsgAlert("Somente permitido indicar um pedido de compra.")
      Return(.T.)
   Endif

   // ####################################
   // Atualiza o Registro na tabela SC6 ##
   // ####################################
   dbSelectArea("SC6")
   dbSetOrder(1)
   If DbSeek( _Filial + _Pedido + _Item + _Produto )

      RecLock("SC6", .F.)
	  SC6->C6_PRVCOMP := cEntrega
      SC6->C6_PCOMPRA := cOcompra
      SC6->C6_ITEMPC  := cItem
      SC6->C6_ITPCSTS := cItem              
//    SC6->C6_SLDPCOM := cSaldo 
      SC6->C6_SLDPCOM := SC6->C6_QTDVEN
      SC6->C6_STATUS  := "06"

      // #################################################
   	  // Atualiza a tabela de Status do Pedido de Venda ##
   	  // #################################################
   	  U_GrvLogSts(xFilial("SC6"),SC6->C6_NUM, SC6->C6_ITEM, "06", "AUTOM555")

      MsUnlock()
      
   Endif

   oDlgE:End()

   // ###################################################
   // Atualiza o Grid para visualização das aletrações ##
   // ###################################################
   PesqEntrega()
   
Return(.T.)                                                                                                 

// ##################################################################
// Função que permite o usuário limpar os dados para nova gravação ##
// ##################################################################
Static Function LimpaDadosOC(_Empresa, _Filial, _Pedido, _Item, _Produto, _Descricao, _OCompra, _Entrega, _ItemPC, _Status)

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Local kPedido    := _Pedido
   Local kProduto   := _Produto
   Local kDescricao := _Descricao
   Local kOCompra   := _OCompra
   Local kEntrega   := _Entrega
   Local kItemPC    := _ItemPC

   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet5
   Local oGet6
   Local oGet7

   Private oDlgL

   If Empty(Alltrim(kPedido))
      MsgAlert("Nenhum pedido de venda selecionado para alteração.")
      Return(.T.)
   Endif

   If Substr(_Status,01,02) <> "06"
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Alteração não permitida para pedidos de venda com " + chr(13) + chr(10) + "status diferente de 06 - Em Compra.")
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgL TITLE "Data de Entrega de Produtos" FROM C(178),C(181) TO C(478),C(525) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlgL

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(165),C(001) PIXEL OF oDlgL
   @ C(127),C(002) GET oMemo2 Var cMemo2 MEMO Size C(165),C(001) PIXEL OF oDlgL

   @ C(037),C(005) Say "Pedido de Venda"      Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(058),C(005) Say "Produto"              Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(079),C(005) Say "Descrição do Produto" Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(102),C(005) Say "Nº O.Compra"          Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(102),C(056) Say "Data Entrega"         Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(102),C(104) Say "Item PC"              Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgL

   @ C(045),C(005) MsGet oGet1 Var kPedido    Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL When lChumba
   @ C(067),C(005) MsGet oGet2 Var kProduto   Size C(064),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL When lChumba
   @ C(089),C(005) MsGet oGet3 Var kDescricao Size C(163),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL When lChumba
   @ C(112),C(005) MsGet oGet5 Var kOcompra   Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL When lChumba
   @ C(112),C(056) MsGet oGet6 Var kEntrega   Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL When lChumba
   @ C(112),C(104) MsGet oGet7 Var kItemPC    Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL When lChumba

   @ C(132),C(047) Button "Limpar" Size C(037),C(012) PIXEL OF oDlgL ACTION( GrvLimpaOC(_Empresa, _Filial, _Item, kPedido, kProduto, kDescricao, kOcompra, kEntrega, kItemPC) )
   @ C(132),C(086) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgL ACTION( oDlgL:End() )

   ACTIVATE MSDIALOG oDlgL CENTERED 

Return(.T.)

// ###########################################################
// Função que grava a limpeza dos campos conforme indicação ##
// ###########################################################
Static Function GrvLimpaOC(_Empresa, _Filial, _Item, kPedido, kProduto, kDescricao, kOcompra, kEntrega, kItemPC)

   // #####################################
   // Limpa os campos do Pedido de Venda ##
   // #####################################
   dbSelectArea("SC6")
   dbSetOrder(1)
   If DbSeek( _Filial + kPedido + _Item + kProduto )

      RecLock("SC6", .F.)
	  SC6->C6_PRVCOMP := Ctod("  /  /    ")
      SC6->C6_PCOMPRA := ""
      SC6->C6_ITPCSTS := ""
      SC6->C6_STATUS  := "04"  
      SC6->C6_SLDPCOM := 0

      // #################################################
   	  // Atualiza a tabela de Status do Pedido de Venda ##
   	  // #################################################
   	  U_GrvLogSts(xFilial("SC6"),SC6->C6_NUM, SC6->C6_ITEM, "04", "AUTOM549")

      MsUnlock()
      
   Endif

   oDlgL:End()
   
   // ###################################################
   // Atualiza o Grid para visualização das aletrações ##
   // ###################################################
   PesqEntrega()
   
Return(.T.)

// #################################################################################
// Função que vincula/desvincula ordem de produção ao pedido de venda selecionado ##
// #################################################################################
Static Function VincDesvOP(_Pedido, _Produto, _ItemPV, _Descricao, _OProducao, _Status, _Avulso)

   Local lChumba     := .F.
   Local lVincula    := .F.
   Local lDesvincula := .F.
   Local cMemo1	     := ""
   Local cMemo2	     := ""

   Local oMemo1
   Local oMemo2

   Local cPedido    := _Pedido      
   Local cProduto   := _Produto
   Local cItemPV    := _ItemPV
   Local cDescricao := _Descricao
   Local cNumeroOP  := IIF(Empty(Alltrim(_OProducao)), Space(11), _OProducao)

   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5

   Private oDlgOP

   lVincula    := IIF(Empty(Alltrim(_OProducao)), .T., .F.)
   lDesvincula := IIF(Empty(Alltrim(_OProducao)), .F., .T.)

   // ###########################################################################
   // Verifica se pedido de venda foi selecionado para vincular/desvincular OP ##
   // ###########################################################################
   If Empty(Alltrim(cPedido))
      MsgAlert("Nenhum pedido de venda selecionado para Vincular/Desvincular.")
      Return(.T.)
   Endif

   // ##################################################################################################
   // Verifica se pedido de venda selecionado pertence ao Status 04 - Aguardando Liberação de Estoque ##
   // ##################################################################################################
   If lVincula == .T.
      If Substr(_Status,01,02) <> "04" .And. Substr(_Status,01,02) <> "05"
         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Alteração não permitida para pedidos de venda com " + chr(13) + chr(10) + "status diferente de 04 - Aguardando Liberação de estoque.")
         Return(.T.)
      Endif
   Endif

   // ##############################################################################
   // Verifica se pedido de venda selecionado pertence ao Status 07 - Em Produção ##
   // ##############################################################################
   If lDesvincula == .T.
      If Substr(_Status,01,02) <> "07"
         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Alteração não permitida para pedidos de venda com " + chr(13) + chr(10) + "status diferente de 07 - Em Produção.")
         Return(.T.)
      Endif
   Endif

   // ###############################################
   // Verifica se o produto selecionado é etiqueta ##
   // ###############################################
   If Len(Alltrim(cProduto)) <= 6
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Produto selecionado não é ETIQUETA.")
      Return(.T.)
   Endif

   If lDesvincula == .T.
      If _Avulso <> "A"
         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Ordem de Produção não é uma OP Avulsa. Desvinculação não permitida.")
         Return(.T.)
      Endif
   Endif   

   // ############################################
   // Desena a tela para visualização dos dados ##
   // ############################################
   DEFINE MSDIALOG oDlgOP TITLE "Víncução/Desvinculação Pedido de Venda OP Avulsa" FROM C(178),C(181) TO C(482),C(507) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlgOP

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(157),C(001) PIXEL OF oDlgOP
   @ C(128),C(002) GET oMemo2 Var cMemo2 MEMO Size C(157),C(001) PIXEL OF oDlgOP
   
   @ C(037),C(005) Say "Nº P.Venda"           Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgOP
   @ C(058),C(005) Say "Produto"              Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgOP
   @ C(058),C(076) Say "Item PV"              Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgOP
   @ C(081),C(005) Say "Descrição do Produto" Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlgOP
   @ C(103),C(005) Say "Nº Ordem Produção"    Size C(049),C(008) COLOR CLR_BLACK PIXEL OF oDlgOP
   
   @ C(046),C(005) MsGet oGet1 Var cPedido    Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgOP When lChumba
   @ C(068),C(005) MsGet oGet2 Var cProduto   Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgOP When lChumba
   @ C(068),C(076) MsGet oGet3 Var cItemPV    Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgOP When lChumba
   @ C(090),C(005) MsGet oGet4 Var cDescricao Size C(156),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgOP When lChumba
   @ C(113),C(005) MsGet oGet5 Var cNumeroOP  Size C(048),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgOP F3("SC2") VALID( VeOProducao( cNumeroOP, cProduto) )

   @ C(134),C(022) Button "Vincular"    Size C(037),C(012) PIXEL OF oDlgOP ACTION( GravaVinculo("V", cPedido, cProduto, cItemPV, cNumeroOP) ) When lVincula
   @ C(134),C(062) Button "Desvincular" Size C(037),C(012) PIXEL OF oDlgOP ACTION( GravaVinculo("D", cPedido, cProduto, cItemPV, cNumeroOP) ) When lDesvincula
   @ C(134),C(100) Button "Voltar"      Size C(037),C(012) PIXEL OF oDlgOP ACTION( oDlgOP:End() )

   ACTIVATE MSDIALOG oDlgOP CENTERED 

Return(.T.)

// #################################################################################
// Função que verifica se a op selecionada já está vinculada a um pedido de venda ##
// #################################################################################
Static Function VeOProducao( kNumeroOP, kProduto)

   If Empty(Alltrim(kNumeroOP))
      Return(.T.)
   Endif
   
   // ###############################
   // Pesquisa a Ordem de produção ##
   // ###############################
   dbSelectArea("SC2")
   dbSetOrder(1)
   If dbSeek( xFilial("SC2") + Substr(kNumeroOP,01,08) )

      // ##########################################################
      // Verifica se a OP já está vinculada a um pedido de venda ##
      // ##########################################################
      If Empty(Alltrim(SC2->C2_PEDIDO))
      Else
         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Ordem de Produção já vinculada ao pedido de venda nº " + Alltrim(SC2->C2_PEDIDO))
         Return(.T.)
      Endif

      // ##################################################################################
      // Verifica se o produto da OP é o mesmo do produto do pedido de venda selecionado ##
      // ##################################################################################
      If Alltrim(SC2->C2_PRODUTO) <> Alltrim(kProduto)
         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Produto do pedido de venda selecionado é diferente do produto da ordem de produção selecionada." + chr(13) + chr(10) + chr(13) + Chr(10) + "Verifique!")
         Return(.T.)
      Endif

   Endif

Return(.T.)

// ##################################################################################################
// Função que grava a vinculação/desvinculação da ordem de produção ao pedido de venda selecionado ##
// ##################################################################################################
Static Function GravaVinculo(kTipo, kPedido, kProduto, kItemPV, kProducao)

   If Empty(Alltrim(kProducao))
      If kTipo == "V"
         Msgalert("Nº Ordem de Produção a ser vinculada não informada.")
      Else
         Msgalert("Nº Ordem de Produção a ser desvinculada não informada.")         
      Endif         
      Return(.T.)
   Endif

   // ##############################################################################################################
   // Em caso de vinculação, verifica se a Ordem de Produção selecionada já foi vinculada a algum pedido de venda ##
   // ##############################################################################################################
   If kTipo == "V"

      // ######################################################
      // Vincula o nº do pedido de venda a ordem de produção ##
      // ######################################################
	  dbSelectArea("SC2")
	  dbSetOrder(1)
	  If dbSeek( xFilial("SC2") + Substr(kProducao,01,08) )
         RecLock("SC2", .F.)
         SC2->C2_PEDIDO := kPedido
         SC2->C2_ITEMPV := kItemPV
         MsUnlock()
      Endif

      // #######################################################
      // Vincula o nº da Ordem de Produção no Pedido de Venda ##
      // #######################################################
	  dbSelectArea("SC6")
  	  dbSetOrder(1)
	  If dbSeek( xFilial("SC6") + kPedido + kItemPV + kProduto )
         RecLock("SC6", .F.)
         SC6->C6_NUMOP  := Substr(kProducao,01,06)
         SC6->C6_ITEMOP := Substr(kProducao,07,02)
         SC6->C6_ZTPOP  := "A"
         SC6->C6_STATUS := "07"

         // #################################################
      	 // Atualiza a tabela de Status do Pedido de Venda ##
   	     // #################################################
    	 U_GrvLogSts(xFilial("SC6"), kPedido, kItemPV, "07", "AUTOM555")

         MsUnlock()
      Endif

   Else

      // #########################################################
      // Desvincula o nº do pedido de venda a ordem de produção ##
      // #########################################################
	  dbSelectArea("SC2")
	  dbSetOrder(1)
	  If dbSeek( xFilial("SC2") + Substr(kProducao,01,08) )
         RecLock("SC2", .F.)
         SC2->C2_PEDIDO := ""
         SC2->C2_ITEMPV := ""
         MsUnlock()
      Endif

      // #######################################################
      // Vincula o nº da Ordem de Produção no Pedido de Venda ##
      // #######################################################
	  dbSelectArea("SC6")
  	  dbSetOrder(1)
	  If dbSeek( xFilial("SC6") + kPedido + kItemPV + kProduto )
         RecLock("SC6", .F.)
         SC6->C6_NUMOP  := ""
         SC6->C6_ITEMOP := ""
         SC6->C6_ZTPOP  := ""
         SC6->C6_STATUS := "04"

         // #################################################
      	 // Atualiza a tabela de Status do Pedido de Venda ##
   	     // #################################################
    	 U_GrvLogSts(xFilial("SC6"), kPedido, kItemPV, "04", "AUTOM555")

         MsUnlock()

      Endif

   Endif

   // ###########################################################
   // Fecha a janela de vinculação/desvinculação de op para pv ##
   // ###########################################################
   oDlgOP:End()
   
   // ###################################################
   // Atualiza o Grid para visualização das aletrações ##
   // ###################################################
   PesqEntrega()
   
Return(.T.)

// ##################################################
// Função que abre o kardex do produto selecionado ##
// ##################################################
Static Function AbreKardexP(kProduto)

   Private cCadastro := "Cadastro de Produtos"
   
   If Empty(Alltrim(kProduto))
      MsgAlert("Produto não selecionado para realizar a consulta do Kardex.")
      Return(.T.)
   Endif
          
   dbSelectArea("SB1")
   dbSetOrder(1)
   dbSeek( xFilial("SB1") + kProduto )
   
   U_AUTOM181()
   
Return(.T.)

// ##########################################################
// Função que pesquisa op's sem vínculo a pedidos de venda ##
// ##########################################################
Static Function PsqOPSemPV()

   Local lChumba  := .F.
   Local cMemo1	  := ""
   Local oMemo1

   Local cQuantos := 0
   Local oGet1

   Local cSql      := ""
   Local aProducao := {}

   Private oDlgXX

   If Select("T_PRODUCAO") > 0
      T_PRODUCAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC2.C2_FILIAL ,"
   cSql += "       SC2.C2_NUM    ,"
   cSql += "	   SC2.C2_ITEM   ,"
   cSql += "	   SC2.C2_SEQUEN ,"
   cSql += "	   SC2.C2_PRODUTO,"
   cSql += "	   LTRIM(RTRIM(SB1.B1_DESC)) + ' ' + LTRIM(RTRIM(SB1.B1_DAUX)) AS DESCRICAO,"
   cSql += "	   SC2.C2_LOCAL  ,"
   cSql += "	   SC2.C2_QUANT  ,"
   cSql += "	   SC2.C2_UM     ,"
   cSql += "	   SC2.C2_EMISSAO,"
   cSql += "	   SC2.C2_DATPRI ,"
   cSql += "	   SC2.C2_DATPRF ,"
   cSql += "	   SC2.C2_QUANT  ," 
   cSql += "	   SC2.C2_QUJE   ,"
   cSql += "   	  (SC2.C2_QUANT - SC2.C2_QUJE) AS A_PRODUZIR,"
   cSql += "       SC2.C2_OBS     "
   cSql += "  FROM " + RetSqlName("SC2") + " SC2, "
   cSql += "       " + RetSqlName("SB1") + " SB1  "
   cSql += "    WHERE SC2.C2_FILIAL  = '" + Alltrim(cFilAnt) + "'"
   cSql += "      AND SC2.C2_QUANT  <> C2_QUJE"
   cSql += "      AND SC2.C2_PEDIDO  = ''"
   cSql += "      AND SC2.D_E_L_E_T_ = ''"
   cSql += "      AND SB1.B1_COD     = SC2.C2_PRODUTO"
   cSql += "      AND SB1.D_E_L_E_T_ = ''"
   cSql += "    ORDER BY SC2.C2_NUM"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUCAO", .T., .T. )

   cQuantos := 0

   T_PRODUCAO->( DbGoTop() )
   
   WHILE !T_PRODUCAO->( EOF() )

      cQuantos := cQuantos + 1
   
      aAdd( aProducao, { T_PRODUCAO->C2_NUM    ,;
                         T_PRODUCAO->C2_ITEM   ,;
                         T_PRODUCAO->C2_SEQUEN ,;
                         T_PRODUCAO->C2_PRODUTO,;
                         T_PRODUCAO->DESCRICAO ,;
                         T_PRODUCAO->C2_UM     ,;
                         T_PRODUCAO->C2_LOCAL  ,;
                         T_PRODUCAO->C2_QUANT  ,;
                         T_PRODUCAO->C2_QUJE   ,;
                         T_PRODUCAO->A_PRODUZIR,;
                         Substr(T_PRODUCAO->C2_EMISSAO,07,02) + "/" + Substr(T_PRODUCAO->C2_EMISSAO,05,02) + "/" + Substr(T_PRODUCAO->C2_EMISSAO,01,04) ,;
                         Substr(T_PRODUCAO->C2_DATPRI ,07,02) + "/" + Substr(T_PRODUCAO->C2_DATPRI ,05,02) + "/" + Substr(T_PRODUCAO->C2_DATPRI ,01,04) ,;
                         Substr(T_PRODUCAO->C2_DATPRF ,07,02) + "/" + Substr(T_PRODUCAO->C2_DATPRF ,05,02) + "/" + Substr(T_PRODUCAO->C2_DATPRF ,01,04) ,;
                         T_PRODUCAO->C2_OBS})

      T_PRODUCAO->( DbSkip() )
      
   ENDDO
   
   If Len(aProducao) == 0
      MsgAlert("Não existem dados a serem visualizados.")
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgXX TITLE "OP's sem Vínculo a Pedidos de Vendas" FROM C(178),C(181) TO C(547),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgXX

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(385),C(001) PIXEL OF oDlgXX

   @ C(171),C(005) Say "Total de OP's"                                                  Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgXX
   @ C(036),C(005) Say "Relação de Ordens de Produção sem Vínculo com Pedidos de Venda" Size C(168),C(008) COLOR CLR_BLACK PIXEL OF oDlgXX

   @ C(170),C(040) MsGet oGet1 Var cQuantos Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgXX When lChumba

   @ C(168),C(351) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgXX ACTION( oDlgXX:End() )

   oProducao := TCBrowse():New( 055 , 005, 491, 155,,{'Nº OP'                  ,; // 01 
                                                      'Item'                   ,; // 02
                                                      'Seq'                    ,; // 03
                                                      'Produto'                ,; // 04
                                                      'Descrição dos Produtos' ,; // 05
                                                      'Und'                    ,; // 06 
                                                      'Armazém'                ,; // 07
                                                      'Quantidade'             ,; // 08
                                                      'Produzido'              ,; // 09
                                                      'A Produzir'             ,; // 10
                                                      'Emissão'                ,; // 11
                                                      'Data Inicial'           ,; // 12
                                                      'Data Entrega'           ,; // 13
                                                      'Observações'   }        ,; // 14
                                                    {20,50,50,50},oDlgXX,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oProducao:SetArray(aProducao) 
    
   oProducao:bLine := {||{aProducao[oProducao:nAt,01],;
                          aProducao[oProducao:nAt,02],;
                          aProducao[oProducao:nAt,03],;
                          aProducao[oProducao:nAt,04],;
                          aProducao[oProducao:nAt,05],;
                          aProducao[oProducao:nAt,06],;
                          aProducao[oProducao:nAt,07],;
                          aProducao[oProducao:nAt,08],;
                          aProducao[oProducao:nAt,09],;
                          aProducao[oProducao:nAt,10],;                                                                                                                                                            
                          aProducao[oProducao:nAt,11],;
                          aProducao[oProducao:nAt,12],;
                          aProducao[oProducao:nAt,13],;
                          aProducao[oProducao:nAt,14]}}

   ACTIVATE MSDIALOG oDlgXX CENTERED 

Return(.T.)