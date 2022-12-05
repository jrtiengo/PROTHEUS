#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: AUTOM581.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Gatilho                                               ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 12/06/2017                                                              ##
// Objetivo..: Programa que consulta resíduos de pedidos de venda com ordem de compra  ##
// ######################################################################################

User Function AUTOM581

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private aUnidades := U_AUTOM539(2, cEmpAnt)
   Private aStatus	 := {"A - A Resolver", "R - Resolvidos", "T - Todos"}
   Private cComboBx1
   Private cComboBx2
   Private dInicial  := Ctod("01/01/" + Strzero(Year(Date()),4))
   Private dFinal    := Ctod("31/12/" + Strzero(Year(Date()),4))
   Private cCliente  := Space(06)
   Private cLoja     := Space(03)
   Private cNomeCli  := Space(60)
   Private cFornece  := Space(06)
   Private cLojaFor	 := Space(03)
   Private cNomeFor	 := Space(60)
   Private cProduto  := Space(30)
   Private cNomePro	 := Space(60)
   Private cPCompra	 := Space(10)
   Private cPVenda	 := Space(06)

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
   Private oGet12

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

   cComboBx2 := "A - A Resolver"

   Private oDlgRR

   U_AUTOM628("AUTOM581")

   DEFINE MSDIALOG oDlgRR TITLE "Pedidos de Venda (Resíduos)" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(134),C(026) PIXEL NOBORDER OF oDlgRR
   @ C(211),C(047) Jpeg FILE "br_vermelho.png" Size C(009),C(009) PIXEL NOBORDER OF oDlgRR
   @ C(211),C(091) Jpeg FILE "br_verde.png"    Size C(009),C(009) PIXEL NOBORDER OF oDlgRR

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlgRR
   @ C(083),C(005) GET oMemo2 Var cMemo2 MEMO Size C(495),C(001) PIXEL OF oDlgRR
   
   @ C(036),C(005) Say "Unidades"          Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgRR
   @ C(036),C(082) Say "Dta Emis. Inicial" Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlgRR
   @ C(036),C(128) Say "Dta Emis. Final"   Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlgRR
   @ C(036),C(173) Say "Cliente"           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgRR
   @ C(036),C(349) Say "Fornecedor"        Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgRR
   @ C(058),C(005) Say "Produto"           Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgRR
   @ C(058),C(219) Say "Pedido de Compra"  Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlgRR
   @ C(058),C(269) Say "Pedido de Venda"   Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlgRR
   @ C(058),C(319) Say "Status"            Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgRR
   @ C(211),C(059) Say "A Resolver"        Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgRR
   @ C(211),C(104) Say "Resolvido"         Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgRR

   @ C(045),C(005) ComboBox cComboBx1 Items aUnidades Size C(072),C(010)                              PIXEL OF oDlgRR
   @ C(045),C(083) MsGet    oGet1     Var   dInicial  Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRR
   @ C(045),C(128) MsGet    oGet2     Var   dFinal    Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRR
   @ C(045),C(173) MsGet    oGet3     Var   cCliente  Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRR F3("SA1")
   @ C(045),C(199) MsGet    oGet4     Var   cLoja     Size C(013),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRR VALID( BBCCRR() )
   @ C(045),C(219) MsGet    oGet5     Var   cNomeCli  Size C(124),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRR When lChumba
   @ C(045),C(349) MsGet    oGet6     Var   cFornece  Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRR F3("SA2")
   @ C(045),C(375) MsGet    oGet7     Var   cLojaFor  Size C(013),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRR VALID( BBFFRR() )
   @ C(045),C(393) MsGet    oGet8     Var   cNomeFor  Size C(104),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRR When lChumba
   @ C(067),C(005) MsGet    oGet9     Var   cProduto  Size C(072),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRR F3("SB1") VALID( BBPPRR() )
   @ C(067),C(083) MsGet    oGet10    Var   cNomePro  Size C(130),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRR When lChumba
   @ C(067),C(219) MsGet    oGet11    Var   cPCompra  Size C(044),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRR
   @ C(067),C(269) MsGet    oGet12    Var   cPVenda   Size C(044),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRR
   @ C(067),C(319) ComboBox cComboBx2 Items aStatus   Size C(074),C(010)                              PIXEL OF oDlgRR

   @ C(064),C(398) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlgRR ACTION( PPBBDD() )
   @ C(210),C(005) Button "Liberar"   Size C(037),C(012) PIXEL OF oDlgRR ACTION( LIBPVPC() )
   @ C(210),C(461) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgRR ACTION( oDlgRR:End() )

   aAdd( aBrowse, { "0", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })

   // #########################
   // Desenha o grid na tela ##
   // #########################
   oBrowse := TCBrowse():New( 102 , 005, 633, 163,, {'LG'                         ,;                                                  // 01
                                                     'Unidade'                    ,;                                                  // 02
                                                     'P.Venda'                    ,;                                                  // 03
                                                     'Emissão'                    ,;                                                  // 04
                                                     'Cliente'                    ,;                                                  // 05
                                                     'Loja'                       ,;                                                  // 06
                                                     'Descrição dos Clientes'     ,;                                                  // 07
                                                     'Item'                       ,;                                                  // 08
                                                     'Produto'                    ,;                                                  // 09
                                                     'Descrição dos Produtos'     ,;                                                  // 10
                                                     'Part Number'                ,;                                                  // 11
                                                     'Qtd PV'                     ,;                                                  // 12
                                                     'Nº P.Compra'                ,;                                                  // 13
                                                     'Fornecedor'                 ,;                                                  // 14
                                                     'Loja'                       ,;                                                  // 15
                                                     'Descrição dos Fornecedores' ,;                                                  // 16
                                                     'Qtd P.Compra'               ,;                                                  // 17
                                                     'Telefone'},{20,50,50,50},oDlgRR,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )               // 18
   
   // ########################### 
   // Seta vetor para a browse ##
   // ###########################                           
   oBrowse:SetArray(aBrowse) 
    
   // ########################################
   // Monta a linha a ser exibina no Browse ##
   // ########################################
   oBrowse:bLine := {||{ If(aBrowse[oBrowse:nAt,01] == "0", oBranco   ,;
                         If(aBrowse[oBrowse:nAt,01] == "2", oVerde    ,;
                         If(aBrowse[oBrowse:nAt,01] == "3", oCancel   ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "1", oAmarelo  ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "5", oAzul     ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "6", oLaranja  ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "7", oPreto    ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "8", oVermelho ,;
                         If(aBrowse[oBrowse:nAt,01] == "9", oPink     ,;
                         If(aBrowse[oBrowse:nAt,01] == "4", oEncerra, "")))))))))),;
                         aBrowse[oBrowse:nAt,02]            ,;
                         aBrowse[oBrowse:nAt,03]            ,;
                         aBrowse[oBrowse:nAt,04]            ,;
                         aBrowse[oBrowse:nAt,05]            ,;
                         aBrowse[oBrowse:nAt,06]            ,;
                         aBrowse[oBrowse:nAt,07]            ,;                                                                           
                         aBrowse[oBrowse:nAt,08]            ,;
                         aBrowse[oBrowse:nAt,09]            ,;
                         aBrowse[oBrowse:nAt,10]            ,;
                         aBrowse[oBrowse:nAt,11]            ,;
                         aBrowse[oBrowse:nAt,12]            ,;                                                                           
                         aBrowse[oBrowse:nAt,13]            ,;
                         aBrowse[oBrowse:nAt,14]            ,;
                         aBrowse[oBrowse:nAt,15]            ,;                                                                           
                         aBrowse[oBrowse:nAt,16]            ,;                                                                           
                         aBrowse[oBrowse:nAt,17]            ,;                                                                           
                         aBrowse[oBrowse:nAt,18]            }}
   
//   oConsulta:bHeaderClick := {|oObj,nCol| oConsulta:aArray := Ordenar(nCol,oConsulta:aArray),oConsulta:Refresh()}

   ACTIVATE MSDIALOG oDlgRR CENTERED 

Return(.T.)

// ######################################################
// Função que pesquisa o nome do cliente se solicitado ##
// ######################################################
Static Function BBCCRR()

   If Empty(Alltrim(cCliente))
      cCliente := Space(06)
      cLoja    := Space(03)
      cNomeCli := Space(60)     
      oGet3:Refresh()
      oGet4:Refresh()
      oGet5:Refresh()
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cLoja))
      cCliente := Space(06)
      cLoja    := Space(03)
      cNomeCli := Space(60)     
      oGet3:Refresh()
      oGet4:Refresh()
      oGet5:Refresh()
      Return(.T.)
   Endif

   cNomeCli := POSICIONE("SA1",1,XFILIAL("SA1") + cCliente + cLoja, "A1_NOME")

   If Empty(Alltrim(cNomeCli))
      MsgAlert("Cliente informado não cadastrado. Verifique!")
      cCliente := Space(06)
      cLoja    := Space(03)
      cNomeCli := Space(60)     
      oGet3:Refresh()
      oGet4:Refresh()
      oGet5:Refresh()
      Return(.T.)
   Endif
   
Return(.T.)   

// #########################################################
// Função que pesquisa o nome do fornecedor se solicitado ##
// #########################################################
Static Function BBFFRR()

   If Empty(Alltrim(cFornece))
      cFornece := Space(06)
      cLojaFor := Space(03)
      cNomeFor := Space(60)     
      oGet6:Refresh()
      oGet7:Refresh()
      oGet8:Refresh()
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cLojaFor))
      cFornece := Space(06)
      cLojaFor := Space(03)
      cNomeFor := Space(60)     
      oGet6:Refresh()
      oGet7:Refresh()
      oGet8:Refresh()
      Return(.T.)
   Endif

   cNomeFor := POSICIONE("SA2",1,XFILIAL("SA2") + cFornece + cLojaFor, "A2_NOME")

   If Empty(Alltrim(cNomeFor))
      MsgAlert("Fornecedor informado não cadastrado. Verifique!")
      cFornece := Space(06)
      cLojaFor := Space(03)
      cNomeFor := Space(60)     
      oGet6:Refresh()
      oGet7:Refresh()
      oGet8:Refresh()
      Return(.T.)
   Endif
   
Return(.T.)   
                     
// ######################################################
// Função que pesquisa o nome do produto se solicitado ##
// ######################################################
Static Function BBPPRR()

   If Empty(Alltrim(cProduto))
      cProduto := Space(30)
      cNomePro := Space(60)     
      oGet9:Refresh()
      oGet10:Refresh()
      Return(.T.)
   Endif

   cNomePro := POSICIONE("SB1",1,XFILIAL("SB1") + cProduto, "B1_DESC") + " " + POSICIONE("SB1",1,XFILIAL("SB1") + cProduto, "B1_DAUX")

   If Empty(Alltrim(cNomePro))
      MsgAlert("Produto informado não cadastrado. Verifique!")
      cProduto := Space(30)
      cNomePro := Space(60)     
      oGet9:Refresh()
      oGet10:Refresh()
      Return(.T.)
   Endif
   
Return(.T.)

// ###################################################
// Função que pesquisa os dados conforme parâmetros ##
// ###################################################
Static Function PPBBDD()

   MsgRun("Aguarde! Pesquisando Dados cfme. parâmetros ...", "Relação de Pedidos Vendas Cancelados",{|| xPPBBDD() })
   
Return(.T.)

// ###################################################
// Função que pesquisa os dados conforme parâmetros ##
// ###################################################
Static Function xPPBBDD()

   Local cSql := ""

   If dInicial == Ctod("  /  /    ")
      MsgAlert("Data Inicial para pesquisa não informada. Verifique!")
      Return(.T.)
   Endif
      
   If dFinal == Ctod("  /  /    ")
      MsgAlert("Data Final para pesquisa não informada. Verifique!")
      Return(.T.)
   Endif

   aBrowse := {}

   If Select("T_PEDIDOS") > 0
      T_PEDIDOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC6.C6_FILIAL ,"
   cSql += "       SC6.C6_NUM    ,"
   cSql += "       SC5.C5_EMISSAO,"
   cSql += "       SC6.C6_CLI    ,"
   cSql += "	   SC6.C6_LOJA   ,"
   cSql += "       SA1.A1_NOME   ,"
   cSql += "       SC6.C6_ITEM   ,"
   cSql += "	   SC6.C6_PRODUTO,"
   cSql += "       SC6.C6_ZRES   ,"
   cSql += "	   SB1.B1_DESC   ,"
   cSql += "	   SB1.B1_PARNUM ,"
   cSql += "       SC6.C6_QTDVEN ,"
   cSql += "	   SC6.C6_PCOMPRA,"
   cSql += "       SC7.C7_FORNECE,"
   cSql += "	   SC7.C7_LOJA   ,"
   cSql += "       SA2.A2_NOME   ,"
   cSql += "       SA2.A2_DDD    ,"
   cSql += "       SA2.A2_TEL    ,"
   cSql += "       SC7.C7_QUANT  ,"
   cSql += "       SC7.C7_QUJE   "
   cSql += "  FROM " + RetSqlName("SC6") + " SC6, "
   cSql += "       " + RetSqlName("SC5") + " SC5, "
   cSql += "       " + RetSqlName("SA1") + " SA1, "
   cSql += "	   " + RetSqlName("SB1") + " SB1, "
   cSql += "	   " + RetSqlName("SC7") + " SC7, "
   cSql += "	   " + RetSqlName("SA2") + " SA2  "
   cSql += " WHERE SC6.C6_FILIAL   = '" + Substr(cComboBx1,01,02) + "'"
   cSql += "   AND SC6.C6_BLQ      = 'R'           "
   cSql += "   AND SC6.C6_PCOMPRA <> ''            " 
   cSql += "   AND SC5.C5_FILIAL   = SC6.C6_FILIAL "
   cSql += "   AND SC5.C5_NUM      = SC6.C6_NUM    "
   cSql += "   AND SC5.D_E_L_E_T_  = ''            "
   cSql += "   AND SC5.C5_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "', 103)"
   cSql += "   AND SC5.C5_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(dFinal)   + "', 103)"
   cSql += "   AND SA1.A1_COD      = SC6.C6_CLI    "
   cSql += "   AND SA1.A1_LOJA     = SC6.C6_LOJA   "
   cSql += "   AND SA1.D_E_L_E_T_  = ''            "
   cSql += "   AND SB1.B1_COD      = SC6.C6_PRODUTO"
   cSql += "   AND SB1.D_E_L_E_T_  = ''            "
   cSql += "   AND SC7.C7_FILIAL   = SC6.C6_FILIAL "
   cSql += "   AND SC7.C7_NUM      = SC6.C6_PCOMPRA"
   cSql += "   AND SC7.C7_PRODUTO  = SC6.C6_PRODUTO"
   cSql += "   AND SC7.C7_QUJE    <> 0             "
   cSql += "   AND SC7.C7_RESIDUO  = ''            "
   cSql += "   AND SA2.A2_COD      = SC7.C7_FORNECE"
   cSql += "   AND SA2.A2_LOJA     = SC7.C7_LOJA   "
   cSql += "   AND SA2.D_E_L_E_T_  = ''            "

   // ############################################
   // Pesquisa pelo código do cliente informado ##
   // ############################################
   If Empty(Alltrim(cCliente))
   Else
      cSql += " AND SC6.C6_CLI  = '" + Alltrim(cCliente) + "'"
      cSql += " AND SC6.C6_LOJA = '" + Alltrim(cLoja)    + "'"
   Endif
      
   // ###############################################
   // Pesquisa pelo código do fornecedor informado ##
   // ###############################################
   If Empty(Alltrim(cFornece))
   Else
      cSql += " AND SC7.C7_FORNECE = '" + Alltrim(cFornece) + "'"
      cSql += " AND SC7.C7_LOJA    = '" + Alltrim(cLojaFor) + "'"
   Endif

   // ############################################
   // Pesquisa pelo código do produto informado ##
   // ############################################
   If Empty(Alltrim(cProduto))
   Else
      cSql += " AND SC6.C6_PRODUTO = '" + Alltrim(cProduto) + "'"
   Endif

   // ###########################################
   // Pesquisa pelo número do pedido de compra ##
   // ###########################################
   If Empty(Alltrim(cPCompra))
   Else
      cSql += " AND SC6.C6_PCOMPRA = '" + Alltrim(cPCompra) + "'"
   Endif

   // ##########################################
   // Pesquisa pelo número do pedido de venda ##
   // ##########################################
   If Empty(Alltrim(cPVenda))
   Else
      cSql += " AND SC6.C6_NUM = '" + Alltrim(cPVenda) + "'"
   Endif

   // ###################################
   // Pesquisa pelo status selecionado ##
   // ###################################
   Do Case 
      Case Substr(cComboBx2,01,01) == "A"
           cSql += " AND SC6.C6_ZRES = ''"
      Case Substr(cComboBx2,01,01) == "R"
           cSql += " AND SC6.C6_ZRES <> ''"
   EndCase

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDOS", .T., .T. )
   
   T_PEDIDOS->( DbGoTop() )
   
   WHILE !T_PEDIDOS->( EOF() )
  
      aAdd( aBrowse, { IIF(T_PEDIDOS->C6_ZRES == "L", "8", "2") ,;
                       T_PEDIDOS->C6_FILIAL ,;
                       T_PEDIDOS->C6_NUM    ,;
                       Substr(T_PEDIDOS->C5_EMISSAO,07,02) + "/" + Substr(T_PEDIDOS->C5_EMISSAO,05,02) + "/" + Substr(T_PEDIDOS->C5_EMISSAO,01,04) ,;
                       T_PEDIDOS->C6_CLI    ,;
                       T_PEDIDOS->C6_LOJA   ,;
                       T_PEDIDOS->A1_NOME   ,;
                       T_PEDIDOS->C6_ITEM   ,;
                       T_PEDIDOS->C6_PRODUTO,;
                       T_PEDIDOS->B1_DESC   ,;
                       T_PEDIDOS->B1_PARNUM ,;
                       Transform(T_PEDIDOS->C6_QTDVEN, "@E 99999.999") ,;
                       T_PEDIDOS->C6_PCOMPRA,;
                       T_PEDIDOS->C7_FORNECE,;
                       T_PEDIDOS->C7_LOJA   ,;
                       T_PEDIDOS->A2_NOME   ,;   
                       Transform(T_PEDIDOS->C7_QUANT , "@E 99999.999") ,;
                       "(" + Alltrim(T_PEDIDOS->A2_DDD) + ") " + Alltrim(T_PEDIDOS->A2_TEL)})

      T_PEDIDOS->( DbSkip() )
      
   ENDDO
   
   If Len(aBrowse) == 0
      aAdd( aBrowse, { "0", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })      
   Endif


   // ########################### 
   // Seta vetor para a browse ##
   // ###########################                           
   oBrowse:SetArray(aBrowse) 
    
   // ########################################
   // Monta a linha a ser exibina no Browse ##
   // ########################################
   oBrowse:bLine := {||{ If(aBrowse[oBrowse:nAt,01] == "0", oBranco   ,;
                         If(aBrowse[oBrowse:nAt,01] == "2", oVerde    ,;
                         If(aBrowse[oBrowse:nAt,01] == "3", oCancel   ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "1", oAmarelo  ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "5", oAzul     ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "6", oLaranja  ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "7", oPreto    ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "8", oVermelho ,;
                         If(aBrowse[oBrowse:nAt,01] == "9", oPink     ,;
                         If(aBrowse[oBrowse:nAt,01] == "4", oEncerra, "")))))))))),;
                         aBrowse[oBrowse:nAt,02]            ,;
                         aBrowse[oBrowse:nAt,03]            ,;
                         aBrowse[oBrowse:nAt,04]            ,;
                         aBrowse[oBrowse:nAt,05]            ,;
                         aBrowse[oBrowse:nAt,06]            ,;
                         aBrowse[oBrowse:nAt,07]            ,;                                                                           
                         aBrowse[oBrowse:nAt,08]            ,;
                         aBrowse[oBrowse:nAt,09]            ,;
                         aBrowse[oBrowse:nAt,10]            ,;
                         aBrowse[oBrowse:nAt,11]            ,;
                         aBrowse[oBrowse:nAt,12]            ,;                                                                           
                         aBrowse[oBrowse:nAt,13]            ,;
                         aBrowse[oBrowse:nAt,14]            ,;
                         aBrowse[oBrowse:nAt,15]            ,;                                                                           
                         aBrowse[oBrowse:nAt,16]            ,;                                                                           
                         aBrowse[oBrowse:nAt,17]            ,;                                                                           
                         aBrowse[oBrowse:nAt,18]            }}

Return(.T.)      

// ####################################################
// Função que realiza a liberação do pedido de venda ##
// ####################################################
Static Function LIBPVPC()

   Local lChumba   := .F.
   Local cMemo1	   := ""
   Local cDetalhes := ""

   Local oMemo1
   Local oMemo2

   Private oDlgLib

   Do Case
      Case aBrowse[01,01] == "0"
           MsgAlert("Não existem registros pesquisados para liberação.")
           Return(.T.)
      Case aBrowse[oBrowse:nAt,01] == "8"
           MsgAlert("Registro já Liberado.")
           Return(.T.)
   EndCase

   cDetalhes := "Pedido de Venda Nº: " + aBrowse[oBrowse:nAt,03] + chr(13) + chr(10) + chr(13) + chr(10) + ;
                "Data Emissão: "       + aBrowse[oBrowse:nAt,04] + chr(13) + chr(10) + chr(13) + chr(10) + ;
                "Cliente: "            + aBrowse[oBrowse:nAt,05] + "." + aBrowse[oBrowse:nAt,06] + " - " + aBrowse[oBrowse:nAt,07] + chr(13) + chr(10) + chr(13) + chr(10) + ;
                "Item: "               + aBrowse[oBrowse:nAt,08] + chr(13) + chr(10) + chr(13) + chr(10) + ;
                "Produto: "            + Alltrim(aBrowse[oBrowse:nAt,09]) + " - " + Alltrim(aBrowse[oBrowse:nAt,10]) + chr(13) + chr(10) + chr(13) + chr(10) + ;
                "Qtd P.Venda: "        + aBrowse[oBrowse:nAt,12] + chr(13) + chr(10) + chr(13) + chr(10) + ;
                "Pedido de Compra: "   + aBrowse[oBrowse:nAt,13] + chr(13) + chr(10) + chr(13) + chr(10) + ;
                "Fornecedor: "         + aBrowse[oBrowse:nAt,14] + "." + aBrowse[oBrowse:nAt,15] + " - " + aBrowse[oBrowse:nAt,16] + chr(13) + chr(10) + chr(13) + chr(10) + ;
                "Qtd P.Compra: "       + aBrowse[oBrowse:nAt,17]

   DEFINE MSDIALOG oDlgLib TITLE "Liberação de Pedido de Compra" FROM C(178),C(181) TO C(548),C(669) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlgLib

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(237),C(001) PIXEL OF oDlgLib

   @ C(035),C(005) Say "Dados do Pedido de Venda a ser liebrado" Size C(100),C(008) COLOR CLR_BLACK PIXEL OF oDlgLib

   @ C(045),C(005) GET oMemo2 Var cDetalhes MEMO Size C(235),C(119) PIXEL OF oDlgLib When lChumba

   @ C(168),C(164) Button "Liberar" Size C(037),C(012) PIXEL OF oDlgLib ACTION( GGLIBPVPC() )
   @ C(168),C(203) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlgLib ACTION( oDlgLib:End() )

   ACTIVATE MSDIALOG oDlgLib CENTERED 

Return(.T.)

// ####################################################
// Função que realiza a liberação do pedido de venda ##
// ####################################################
Static Function GGLIBPVPC()

   If MsgYesNo("Deseja realmente liberar este pedido de venda?")

      dbSelectArea("SC6")
      DBSetOrder(1)
      DbSeek ( aBrowse[oBrowse:nAt,02] + aBrowse[oBrowse:nAt,03] + aBrowse[oBrowse:nAt,08] + aBrowse[oBrowse:nAt,09])
      RecLock("SC6",.F.)
	  SC6->C6_ZRES    := "L"
	  SC6->C6_PRVCOMP := Ctod("  /  /    ")
      SC6->C6_PCOMPRA := ""
      SC6->C6_ITPCSTS := ""
      SC6->C6_SLDPCOM := 0
      SC6->C6_STATUS  := "14"

      // #################################################
   	  // Atualiza a tabela de Status do Pedido de Venda ##
   	  // #################################################
   	  U_GrvLogSts(aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,08], "14", "AUTOM581")

      MsUnLock()
      
      oDlgLib:End() 
      
      PPBBDD()
      
   Endif
   
Return(.T.)