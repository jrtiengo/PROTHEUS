#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "jpeg.ch" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AT_GRAVAPVENDA.PRW                                                  ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 19/01/2017                                                          ##
// Objetivo..: Inclusão de Pedidos de Venda                                        ##
// Parâmetros: Vide relação abaixo                                                 ##
// ##################################################################################

User Function AUTOM546()

   Local cMemo1	   := ""
   Local oMemo1
   
   Private xFilial := Space(02)
   Private xpedido := Space(06)
   Private oGet1
   Private oGet2

   Private oDlg

   U_AUTOM628("AUTOM546")

   DEFINE MSDIALOG oDlg TITLE "Copia de Pedidos de Venda" FROM C(178),C(181) TO C(331),C(523) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(161),C(001) PIXEL OF oDlg

   @ C(037),C(005) Say "Copia de Pedido de Venda" Size C(066),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(050),C(005) Say "Filial"                   Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(050),C(028) Say "Nº Pedido de Venda"       Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(060),C(005) MsGet oGet1 Var xFilial Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(060),C(028) MsGet oGet2 Var xPedido Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(057),C(089) Button "Duplicar" Size C(037),C(012) PIXEL OF oDlg ACTION( DuplicaPV() )
   @ C(057),C(127) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #######################################
// Função que duplica o pedido de venda ##
// #######################################
Static Function DuplicaPV()

   Local _aCabec   := {}
   Local _aItens   := {}
   Local _aItem    := {}

   Private lMsErroAuto := .F. 
   Private lMsHelpAuto := .F. 

   If Empty(Alltrim(xFilial))
      MsgAlert("Filial não informada.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(xPedido))
      MsgAlert("Pedido não informado.")
      Return(.T.)
   Endif

   // ########################################################
   // Pesquisa se o pedido para a filial informada é válido ##
   // ########################################################
   dbSelectArea("SC5")
   dbSetOrder(1)
   If dbSeek( xFilial + xPedido )
   Else
      MsgAlert("Pedido de Venda inexistente.")
      Return(.T.)
   Endif
   
   If MsgYesNo("Deseja realmente duplicar este pedido de venda?")

      dbSelectArea("SC5")
      dbSetOrder(1)
   
      // ###############################################
      // Pesquisa o próximo código de pedido de venda ##
      // ###############################################
      cNumPed := GetSX8Num("SC5","C5_NUM")

      // ##########################################################
      // Cria array com os dados do cabeçalho do pedido de venda ##
      // ##########################################################
       aAdd(_aCabec,{"C5_NUM"    , cNumPed          , Nil}) // Número do Pedido de Venda
       aAdd(_aCabec,{"C5_FILIAL" , SC5->C5_FILIAL   , Nil}) // Número do Pedido de Venda
       aAdd(_aCabec,{"C5_TIPO"   , SC5->C5_TIPO     , Nil}) // Tipo do Pedido de Venda
       aAdd(_aCabec,{"C5_CLIENTE", SC5->C5_CLIENTE  , Nil}) // Codigo do Cliente
       aAdd(_aCabec,{"C5_LOJACLI", SC5->C5_LOJACLI  , Nil}) // Loja do Cliente
       aAdd(_aCabec,{"C5_CLIENT" , SC5->C5_CLIENT   , Nil}) // Codigo do Cliente de Entrega
       aAdd(_aCabec,{"C5_LOJAENT", SC5->C5_LOJAENT  , Nil}) // Loja do Cliente de Entrega
       aAdd(_aCabec,{"C5_CONDPAG", SC5->C5_CONDPAG  , Nil}) // Condição de Pagamento
       aAdd(_aCabec,{"C5_MOEDA"  , SC5->C5_MOEDA    , Nil}) // Moeda                     
       aAdd(_aCabec,{"C5_TIPOCLI", SC5->C5_TIPOCLI  , Nil}) // Tipo do Cliente
       aAdd(_aCabec,{"C5_EXTERNO", SC5->C5_EXTERNO  , Nil}) // Tipo de Pedido de Venda (Interno/Externo)
       aAdd(_aCabec,{"C5_FORMA"  , SC5->C5_FORMA    , Nil}) // Forma de Pagamento
       aAdd(_aCabec,{"C5_VEND1"  , SC5->C5_VEND1    , Nil}) // Código do Vendedor 1  
       aAdd(_aCabec,{"C5_TIPLIB" , SC5->C5_TIPLIB   , Nil}) // Tipo de Liberação do Pedido (1 = Por Item)
       aAdd(_aCabec,{"C5_TPFRETE", SC5->C5_TPFRETE  , Nil}) // Tipo do frete
       aAdd(_aCabec,{"C5_TRANSP" , SC5->C5_TRANSP   , Nil}) // Código da transportadora
       aAdd(_aCabec,{"C5_VEND2"  , SC5->C5_VEND2    , Nil}) // Código do Vendedor 2  

       // ####################################################################
       // Pesquisa os produtos do pedido de vende de prigem para duplicação ##
       // ####################################################################
       If Select("T_PRODUTOS") > 0
          T_PRODUTOS->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT C6_ITEM   ,"
       cSql += "       C6_PRODUTO,"
       cSql += "       C6_UM     ,"
       cSql += "       C6_QTDVEN ,"
       cSql += "       C6_PRCVEN ,"
       cSql += "       C6_PRUNIT ,"
       cSql += "       C6_TES    ,"
       cSql += "       C6_COMIS1 ,"
       cSql += "       C6_COMIS2 ,"
       cSql += "       C6_STATUS  "
       cSql += "  FROM " + RetSqlName("SC6")
       cSql += " WHERE C6_FILIAL  = '" + Alltrim(xFilial) + "'"
       cSql += "   AND C6_NUM     = '" + Alltrim(xPedido) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

       T_PRODUTOS->( DbGoTop() )
       
       WHILE !T_PRODUTOS->( EOF() )
       
           // ###############################
           // Carrega o array dos produtos ##
           // ###############################
           aAdd(_aItens, {{"C6_NUM"    , cNumPed                , Nil},; // Código do Produto
                          {"C6_ITEM"   , T_PRODUTOS->C6_ITEM    , Nil},; // Código do Produto
                          {"C6_PRODUTO", T_PRODUTOS->C6_PRODUTO , Nil},; // Código do Produto
                          {"C6_UM"     , T_PRODUTOS->C6_UM      , Nil},; // Unidade de medida (primeira)
                          {"C6_QTDVEN" , T_PRODUTOS->C6_QTDVEN  , Nil},; // Quantidade vendida do produto
                          {"C6_PRCVEN" , T_PRODUTOS->C6_PRCVEN  , Nil},; // Preco venda do produto
                          {"C6_PRUNIT" , T_PRODUTOS->C6_PRUNIT  , Nil},; // Preco unitario
                          {"C6_TES"    , T_PRODUTOS->C6_TES     , Nil},; // Tipo de entrada/saída do produto
                          {"C6_COMIS1" , T_PRODUTOS->C6_COMIS1  , Nil},; // % comissão vendedor 1
                          {"C6_COMIS2" , T_PRODUTOS->C6_COMIS2  , Nil},; // % comissão vendedor 2
                          {"C6_STATUS" , "01"                   , Nil}}) // Status do produto 01 - Aguardando liberação

            T_PRODUTOS->( DbSkip() )

      Enddo

      // ##############################################################
      // Executa o comando de inclusão automática do pedido de venda ##
      // ##############################################################
      nModulo := 5
      MsExecAuto({|x, y, z| MATA410(x, y, z)}, _aCabec, _aItens, 3) 

      If lMsErroAuto
         MsgAlert("Erro na inclusão do pedido")
         Return(.T.)
      Else
         MsgAlert("Pedido de Venda duplicado com o nº " + Alltrim(cNumPed))
         Return(.T.)
      EndIf

   Endif

   xFilial := Space(02)
   xpedido := Space(06)
   oGet1:Refresh()
   oGet2:Refresh()

Return(.T.)