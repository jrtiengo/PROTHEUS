#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch"    

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM540.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 20/02/2017                                                          ##
// Objetivo..: Manutenção Informações Dados Cartões de Crédito                     ##
// ##################################################################################

User Function AUTOM540()

   Local cSql    := ""
   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Private lEditar     := .F.
   Private aEmpresas   := U_AUTOM539(1, "")
   Private aFiliais    := U_AUTOM539(2, cEmpAnt)
   Private aAdministra := {}
   Private aBandeiras  := {}
   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4
   Private cPedido	   := Space(06)
   Private cCliente    := Space(80)
   Private cCartao 	   := Space(04)
   Private cEmissao    := Ctod("  /  /    ")
   Private cDocumento  := Space(06)
   Private cAutoriza   := Space(06)
   Private cNumTID 	   := Space(16)
   Private cValorCart  := 0

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8

   Private oDlg

   // ################################################
   // Carrega o combo de Administradoras de Cartões ##
   // ################################################
   If Select("T_ADMINISTRA") > 0
      T_ADMINISTRA->( dbCloseArea() )
   EndIf

   cSql := "SELECT SAE.AE_FILIAL,"
   cSql += "       SAE.AE_COD   ,"
   cSql += "       SAE.AE_DESC   "
   cSql += "     FROM " + RetSqlName("SAE") + " SAE "
   cSql += "    WHERE SAE.AE_FILIAL  = '" + Alltrim(cFilAnt) + "'"
   cSql += "      AND SAE.D_E_L_E_T_ = ''"
   cSql += "    ORDER BY SAE.AE_DESC     "
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ADMINISTRA", .T., .T. )
   
   T_ADMINISTRA->( DbGoTop() )
   
   aAdd( aAdministra, "000000 - Selecione Administradora" )

   WHILE !T_ADMINISTRA->(EOF())
      aAdd( aAdministra, T_ADMINISTRA->AE_COD + " - " + Alltrim(T_ADMINISTRA->AE_DESC) )
      T_ADMINISTRA->( DbSkip() )
   ENDDO
       
   // #####################################################
   // Carrega o combo de Bandeiras de Cartões de Crédito ##
   // #####################################################     
   If Select("T_BANDEIRAS") > 0
      T_BANDEIRAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT X5_CHAVE,"
   cSql += "       X5_DESCRI" 
   cSql += "  FROM " + RetSqlName("SX5")
   cSql += " WHERE X5_TABELA  = 'G3'"
   cSql += "   AND D_E_L_E_T_ = ''  "
   cSql += " ORDER BY X5_DESCRI     "
                                
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_BANDEIRAS", .T., .T. )

   T_BANDEIRAS->( DbGoTop() )
   
   aAdd( aBandeiras, "000000 - Selecione a Bandeira" )

   WHILE !T_BANDEIRAS->(EOF())
      aAdd( aBandeiras, T_BANDEIRAS->X5_CHAVE + " - " + Alltrim(T_BANDEIRAS->X5_DESCRI) )
      T_BANDEIRAS->( DbSkip() )
   ENDDO

   DEFINE MSDIALOG oDlg TITLE "Informação Dados Cartão de Crédito" FROM C(178),C(181) TO C(524),C(735) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(270),C(001) PIXEL OF oDlg
   @ C(150),C(001) GET oMemo2 Var cMemo2 MEMO Size C(270),C(001) PIXEL OF oDlg
   
   @ C(036),C(005) Say "Empresa"        Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(070) Say "Filial"         Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(135) Say "Nº Ped.Venda"   Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(058),C(005) Say "Cliente"        Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(081),C(005) Say "Administradora" Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(103),C(005) Say "Bandeira"       Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(125),C(005) Say "Ult.4 Dig."     Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(125),C(040) Say "Dt.Transação"   Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(125),C(079) Say "Documento"      Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(125),C(126) Say "Autorização"    Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(125),C(172) Say "TID"            Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(125),C(218) Say "Valor Cartão"   Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(045),C(005) ComboBox cComboBx3 Items aEmpresas Size C(060),C(010) PIXEL OF oDlg ON CHANGE AlteraCombo()      When !lEditar
   @ C(045),C(070) ComboBox cComboBx4 Items aFiliais  Size C(060),C(010) PIXEL OF oDlg                              When !lEditar
   @ C(045),C(135) MsGet    oGet1     Var   cPedido   Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When !lEditar

   @ C(042),C(180) Button "Pesquisar"     Size C(037),C(012) PIXEL OF oDlg ACTION( BscCartao() )      When !lEditar
   @ C(042),C(224) Button "Nova Pesquisa" Size C(048),C(012) PIXEL OF oDlg ACTION( LimpaDadosTela() ) When lEditar

   @ C(068),C(005) MsGet    oGet2     Var   cCliente    Size C(267),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg When lChumba
   @ C(090),C(005) ComboBox cComboBx1 Items aAdministra Size C(267),C(010)                                         PIXEL OF oDlg When lEditar
   @ C(112),C(005) ComboBox cComboBx2 Items aBandeiras  Size C(267),C(010)                                         PIXEL OF oDlg When lEditar
   @ C(135),C(005) MsGet    oGet3     Var   cCartao     Size C(024),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg When lEditar
   @ C(135),C(040) MsGet    oGet4     Var   cEmissao    Size C(038),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg When lEditar
   @ C(135),C(079) MsGet    oGet5     Var   cDocumento  Size C(040),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg
   @ C(135),C(126) MsGet    oGet6     Var   cAutoriza   Size C(040),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg
   @ C(135),C(172) MsGet    oGet7     Var   cNumTid     Size C(040),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg
   @ C(135),C(218) MsGet    oGet8     Var   cValorCart  Size C(056),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlg

   @ C(156),C(099) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlg ACTION( GrvDadosPV() )
   @ C(156),C(138) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #############################################################
// Função que carrega as filiais conforme Empresa selecionada ##
// #############################################################
Static Function AlteraCombo

   aFiliais := U_AUTOM539(2, Substr(cComboBx3,01,02) )
   @ C(045),C(097) ComboBox cComboBx4 Items aFiliais  Size C(087),C(010) PIXEL OF oDlg

Return

// ############################################################
// Função que pesquisa os dados do pedido de venda informado ##
// ############################################################
Static Function BscCartao()

   Local cSql    := ""
   Local nContar := 0

   If Empty(Alltrim(cPedido))
      MsgAlert("Nº do Pedido de Venda a ser pesquisado não informado.")
      Return(.T.)
   Endif
      
   // #######################################
   // Pesquisa o pedido de venda informado ##
   // #######################################
   If Select("T_PEDIDO") > 0
      T_PEDIDO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC5.C5_FILIAL ,"
   cSql += "       SC5.C5_NUM    ,"
   cSql += "       SC5.C5_CONDPAG,"
   cSql += "       SE4.E4_DESCRI ,"
   cSql += "       SC5.C5_CLIENTE,"
   cSql += "       SC5.C5_LOJACLI,"
   cSql += "       SA1.A1_NOME   ,"
   cSql += "       SC5.C5_ADM 	 ,"
   cSql += "       SC5.C5_BAND   ," 
   cSql += "       SC5.C5_CARTAO ," 
   cSql += "       SC5.C5_AUTORIZ,"
   cSql += "       SC5.C5_TID	 ,"
   cSql += "       SC5.C5_DOC	 ,"
   cSql += "       SC5.C5_DATCART,"
   cSql += "       SC5.C5_ZVALCRT "
   cSql += "  FROM " + RetSqlName("SC5") + " (Nolock) SC5, "
   cSql += "       " + RetSqlName("SE4") + " (Nolock) SE4, "
   cSql += "       " + RetSqlName("SA1") + " (Nolock) SA1  "
   cSql += " WHERE SC5.C5_FILIAL  = '" + Substr(cComboBx4,01,02) + "'"
   cSql += "   AND SC5.C5_NUM     = '" + Alltrim(cPedido)        + "'"
   cSql += "   AND SC5.D_E_L_E_T_ = ''"
   cSql += "   AND SE4.E4_CODIGO  = SC5.C5_CONDPAG"
   cSql += "   AND SE4.D_E_L_E_T_ = ''"
   cSql += "   AND SA1.A1_COD     = SC5.C5_CLIENTE"
   cSql += "   AND SA1.A1_LOJA    = SC5.C5_LOJACLI"
   cSql += "   AND SA1.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDO", .T., .T. )

   If T_PEDIDO->( EOF() )
      MsgAlert("Não existem dados a serem visualizados para este pedido de venda.")
      Return(.T.)
   Endif
   
   If U_P_OCCURS(T_PEDIDO->E4_DESCRI, "CARTAO", 1) == 0
      MsgAlert("Condição de pagamento deste pedido não é uma condição de pagamento de Cartão.")
      Return(.T.)
   Endif
   
   // ####################################### 
   // Posiciona a administradora de cartão ##
   // #######################################
   For nContar = 1 to Len(aAdministra)
       If Alltrim(U_P_CORTA(aAdministra[nContar], "-",1)) == Alltrim(T_PEDIDO->C5_ADM)
          cComboBx1 := aAdministra[nContar]
          Exit
       Endif
   Next nContar
          
   // #########################################
   // Posiciona a bandeira da administradora ##
   // #########################################
   For nContar = 1 to Len(aBandeiras)
       If Alltrim(U_P_CORTA(aBandeiras[nContar], "-",1)) == Alltrim(T_PEDIDO->C5_BAND)
          cComboBx2 := aBandeiras[nContar]
          Exit
       Endif
   Next nContar

   // ####################################
   // Carrega as variáveis para display ##
   // ####################################
   cCliente   := T_PEDIDO->C5_CLIENTE + "." + T_PEDIDO->C5_LOJACLI + " - " + Alltrim(T_PEDIDO->A1_NOME)
   cCartao 	  := T_PEDIDO->C5_CARTAO
   cEmissao   := Ctod(Substr(T_PEDIDO->C5_DATCART,07,02) + "/" + Substr(T_PEDIDO->C5_DATCART,05,02) + "/" + Substr(T_PEDIDO->C5_DATCART,01,04))
   cDocumento := T_PEDIDO->C5_DOC
   cAutoriza  := T_PEDIDO->C5_AUTORIZ
   cNumTID 	  := T_PEDIDO->C5_TID
   cValorCart := T_PEDIDO->C5_ZVALCRT
   lEditar    := .T.

Return(.T.)

// ##########################################################
// Função que grava os dados informados no pedido de venda ##
// ##########################################################
Static Function GrvDadosPV()

   // #######################################
   // Consiste os dados anbtes da gravação ##
   // #######################################
   If Substr(cComboBx1,01,06) == "000000"
      MsgAlert("Administradora de Cartão não selecionada.")
      Return(.T.)
   Endif
      
   If Substr(cComboBx2,01,06) == "000000"
      MsgAlert("Bandeira não selecionada.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cNumTid))
      MsgAlert("Nº do TID não informado.")
      Return(.T.)
   Endif

   If cEmissao == Ctod("  /  /    ")
      MsgAlert("Data da Transação não informada.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cAutoriza))
      MsgAlert("Nº da Autoarização não informada.")
      Return(.T.)
   Endif

   If cValorCart == 0
      MsgAlert("Valor do Cartão não informado.")
      Return(.T.)
   Endif

   // ######################################################################
   // Pesquisa o cabeçalho do pedido de venda para atualização dos campos ##
   // ######################################################################
   dbSelectArea("SC5")
   dbSetOrder(1)
   If dbSeek( xFilial("SC5") + cPedido )
      Reclock("SC5",.f.)
      SC5->C5_ADM 	  := Alltrim(U_P_CORTA(cComboBx1, "-", 1))
      SC5->C5_BAND    := Alltrim(U_P_CORTA(cComboBx2, "-", 1))
      SC5->C5_CARTAO  := cCartao
      SC5->C5_AUTORIZ := cAutoriza
      SC5->C5_TID	  := cNumTID
      SC5->C5_DOC	  := cDocumento
      SC5->C5_DATCART := cEmissao
      SC5->C5_ZVALCRT := cValorCart
      MsUnlock()
   Endif

   LimpaDadosTela()      
   
Return(.T.)

// ###########################################################
// Função que limpa as variáveis da tela para nova pesquisa ##
// ###########################################################
Static Function LimpaDadosTela()

   lEditar     := .F.
   cComboBx1   := "000000 - Selecione Administradora"
   cComboBx2   := "000000 - Selecione a Bandeira"
   cPedido	   := Space(06)
   cCliente    := Space(80)
   cCartao 	   := Space(04)
   cEmissao    := Ctod("  /  /    ")
   cDocumento  := Space(06)
   cAutoriza   := Space(06)
   cNumTID 	   := Space(16)
   cValorCart  := 0
   
   oGet1:Refresh()
   oGet2:Refresh()
   oGet3:Refresh()
   oGet4:Refresh()
   oGet5:Refresh()
   oGet6:Refresh()
   oGet7:Refresh()
   oGet8:Refresh()
                  
Return(.T.)