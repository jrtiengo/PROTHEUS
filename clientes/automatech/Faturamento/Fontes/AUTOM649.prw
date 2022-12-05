#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "jpeg.ch" 

// ###################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            ##
// -------------------------------------------------------------------------------- ##
// Referencia: AUTOM649.PRW                                                         ##
// Parâmetros: Nenhum                                                               ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                      ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                              ##
// Data......: 19/10/2017                                                           ##
// Objetivo..: Programa que altera vendedor no pedido de venda                      ##
// ###################################################################################

User Function AUTOM649()

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private lEditar   := .F.

   Private aEmpresas := U_AUTOM539(1, "")
   Private aFiliais  := U_AUTOM539(2, cEmpAnt)

   Private cComboBx1
   Private cComboBx2

   Private cPedido  := Space(06)
   Private cCliente := Space(60)
   Private cVend01  := Space(06)
   Private cNome01  := Space(60)
   Private cVend02  := Space(06)
   Private cNome02  := Space(60)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6

   Private oDlg

   If __CuserID$("000000#000271#000321")
   Else
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Você não tem permissão para executar este procedimento.")
      Return(.T.)
   Endif   

   DEFINE MSDIALOG oDlg TITLE "Alteração de Vendedor" FROM C(178),C(181) TO C(477),C(643) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(226),C(001) PIXEL OF oDlg
   @ C(127),C(002) GET oMemo2 Var cMemo2 MEMO Size C(226),C(001) PIXEL OF oDlg

   @ C(037),C(005) Say "Empresas"     Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(070) Say "Filial"       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(148) Say "Pedido Venda" Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(060),C(005) Say "Cliente"      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(083),C(005) Say "Vendedor 1"   Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(105),C(005) Say "Vendedor 2"   Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(046),C(005) ComboBox cComboBx1 Items aEmpresas Size C(060),C(010)                              PIXEL OF oDlg ON CHANGE ALTERACOMBO()
   @ C(046),C(070) ComboBox cComboBx2 Items aFiliais  Size C(072),C(010)                              PIXEL OF oDlg
   @ C(046),C(148) MsGet    oGet1     Var   cPedido   Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(043),C(189) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION(BUSCAOPEDIDO() )

   @ C(069),C(005) MsGet oGet6 Var cCliente Size C(222),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(092),C(005) MsGet oGet2 Var cVend01  Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lEditar F3("SA3") VALID(cNome01 := Posicione( "SA3", 1, xFilial("SA3") + cVend01, "A3_NOME" ))
   @ C(092),C(042) MsGet oGet3 Var cNome01  Size C(184),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(114),C(005) MsGet oGet4 Var cVend02  Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lEditar F3("SA3") VALID(cNome02 := Posicione( "SA3", 1, xFilial("SA3") + cVend02, "A3_NOME" ))
   @ C(114),C(042) MsGet oGet5 Var cNome02  Size C(184),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(133),C(058) Button "Salvar"   Size C(037),C(012) PIXEL OF oDlg ACTION( GravaVendedores() )
   @ C(133),C(097) Button "Desfazer" Size C(037),C(012) PIXEL OF oDlg ACTION( DESMONTA() )
   @ C(133),C(136) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( odlg:End() )


   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #######################################################################
// Função que carrega o combo de filiais conforme a empresa selecionada ##
// #######################################################################
Static Function AlteraCombo

   aFiliais := U_AUTOM539(2, Substr(cComboBx1,01,02) )
   @ C(046),C(070) ComboBox cComboBx2 Items aFiliais  Size C(072),C(010) PIXEL OF oDlg

Return(.T.)

// ########################################################################
// Função que pesquisa o pedido de vedna informado para a empresa/filial ##
// ########################################################################
Static Function BUSCAOPEDIDO()

   Local cSql := ""

   If Empty(Alltrim(cPedido))
      MsgAlert("Pedido de Venda a ser pesquisado não informado. Verifique!")
      Return(.T.)
   Endif
   
   If Select("T_PEDIDO") > 0
      T_PEDIDO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC5.C5_FILIAL ,"
   cSql += "       SC5.C5_NUM    ,"
   cSql += "	   SC5.C5_CLIENTE,"
   cSql += "	   SC5.C5_LOJACLI,"
   cSql += "	   SA1.A1_NOME   ,"
   cSql += "	   SC5.C5_VEND1  ,"
   cSql += "      (SELECT A3_NOME FROM SA3010 WHERE A3_COD = SC5.C5_VEND1 AND D_E_L_E_T_ = '') AS N_VEND01,"
   cSql += "	   SC5.C5_VEND2  ,"
   cSql += "      (SELECT A3_NOME FROM SA3010 WHERE A3_COD = SC5.C5_VEND2 AND D_E_L_E_T_ = '') AS N_VEND02,"
   cSql += "       SC5.C5_NOTA    "
   cSql += "  FROM SC5" + Substr(cComboBx1,01,02) + "0 SC5,"
   cSql += "       " + RetSqlName("SA1") + " SA1 "
   cSql += " WHERE SC5.C5_FILIAL  = '" + Substr(cComboBx2,01,02) + "'"
   cSql += "   AND SC5.C5_NUM     = '" + Alltrim(cPedido)        + "'"
   cSql += "   AND SC5.D_E_L_E_T_ = ''"
   cSql += "   AND SA1.A1_COD     = SC5.C5_CLIENTE"
   cSql += "   AND SA1.A1_LOJA    = SC5.C5_LOJACLI"
   cSql += "   AND SA1.D_E_L_E_T_ = ''            "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDO", .T., .T. )
      
   If T_PEDIDO->( EOF() )

      MsgAlert("Pedido de Venda não localizado.")

      lEditar := .F.
      cCliente := T_PEDIDO->C5_CLIENTE + "." + T_PEDIDO->C5_LOJACLI + " - " + Alltrim(T_PEDIDO->A1_NOME)
      cVend01  := T_PEDIDO->C5_VEND1
      cNome01  := T_PEDIDO->N_Vend01
      cVend02  := T_PEDIDO->C5_VEND2
      cNome02  := T_PEDIDO->N_Vend02

      oGet6:Refresh()
      oGet2:Refresh()
      oGet3:Refresh()
      oGet4:Refresh()      
      oGet5:Refresh()

      Return(.T.)

   Endif

   If Empty(Alltrim(T_PEDIDO->C5_NOTA))
   Else

      MsgAlert("Pedido de Venda já encerrado. Alteração não permitida.")

      lEditar := .F.

      cPedido  := Space(06)
      cCliente := Space(60)
      cVend01  := Space(06)
      cNome01  := Space(60)
      cVend02  := Space(06)
      cNome02  := Space(60)

      oGet6:Refresh()
      oGet2:Refresh()
      oGet3:Refresh()
      oGet4:Refresh()      
      oGet5:Refresh()

      Return(.T.)

   Endif

   lEditar := .T.

   cCliente := T_PEDIDO->C5_CLIENTE + "." + T_PEDIDO->C5_LOJACLI + " - " + Alltrim(T_PEDIDO->A1_NOME)
   cVend01  := T_PEDIDO->C5_VEND1
   cNome01  := T_PEDIDO->N_VEND01
   cVend02  := T_PEDIDO->C5_VEND2
   cNome02  := T_PEDIDO->N_VEND02

   oGet6:Refresh()
   oGet2:Refresh()
   oGet3:Refresh()
   oGet4:Refresh()      
   oGet5:Refresh()

Return(.T.)

// ##########################################################
// Função que grava os novos vendedores no pedido de venda ##
// ##########################################################
Static Function GravaVendedores()

   Local cSql := ""

   If Empty(Alltrim(cVend01))
      MsgAlert("Vendedor 1 não informado. Verifique!")
      Return(.T.)
   Endif   

   cSql := ""
   cSql := "UPDATE SC5" + Substr(cComboBx1,01,02) + "0"
   cSql += "   SET "
   cSql += "   C5_VEND1 = '" + Alltrim(cVend01)   + "',"
   cSql += "   C5_VEND2 = '" + Alltrim(cVend02)   + "' "
   cSql += " WHERE C5_FILIAL = '" + Substr(cComboBx2,01,02) + "'"
   cSql += "   AND C5_NUM    = '" + Alltrim(cPedido)        + "'"

   _nErro := TcSqlExec(cSql) 

   If TCSQLExec(cSql) < 0 
      alert(TCSQLERROR())
      Return(.T.)
   Endif

   MsgAlert("Vendedor(es) do pedido de venda alterado(s) com sucesso.")

   lEditar := .F.

   cPedido  := Space(06)
   cCliente := Space(60)
   cVend01  := Space(06)
   cNome01  := Space(60)
   cVend02  := Space(06)
   cNome02  := Space(60)

   oGet6:Refresh()
   oGet2:Refresh()
   oGet3:Refresh()
   oGet4:Refresh()      
   oGet5:Refresh()

Return(.T.)

// #################################
// Função que desmonta a pesquisa ##
// #################################
Static Function DESMONTA()

   lEditar := .F.

   cPedido  := Space(06)
   cCliente := Space(60)
   cVend01  := Space(06)
   cNome01  := Space(60)
   cVend02  := Space(06)
   cNome02  := Space(60)

   oGet6:Refresh()
   oGet2:Refresh()
   oGet3:Refresh()
   oGet4:Refresh()      
   oGet5:Refresh()

Return(.T.)