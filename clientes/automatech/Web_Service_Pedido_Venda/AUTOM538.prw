#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AT_GRAVAPVENDA.PRW                                                  ##
// Par�metros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                             ##
// Data......: 19/01/2017                                                          ##
// Objetivo..: Web Service que gera a inclus�o do pedido de venda no Protheus.     ##
// Par�metros: Vide rela��o abaixo                                                 ##
// ##################################################################################

User Function AUTOM538()

   Local cSql      := ""
   Local cRetorno  := ""
   Local cString   := ""
   Local xControle := ""
   Local _aCabec   := {}
   Local _aItens   := {}
   Local _aItem    := {}
   Local aLinha    := {}
   Local nX        := 0
   Local nY        := 0
   Local cDoc      := ""
   Local lOk       := .T.
   Local nContar   := 0
   Local nVezes    := 0

   Local xCodEmp   := "01"
   Local xCodFil   := "01"
   Local xTipPed   := "1"
   Local xCGCCli   := "02836152000154"
   Local xCodCon   := "A VISTA - DINHEIRO"
   Local xCodAdm   := "02"
   Local xTipFre   := "C"
   Local xValFre   := 50.00
   Local xCodTra   := "000008"
   Local xCodVen1  := "000001"
   Local xCodVen2  := ""
   Local xCodMoe   := "1|"
   Local xForExt   := "000011"
   Local xLojExt   := "001"
   Local xCodPro   := "004442|"
   Local xQtdPro   := "1|"
   Local xPrcPro   := "1000.00|"
   Local xTotPro   := "1000.00|"
   Local xComis1   := "0.50|"
   Local xComis2   := "0.00|"
   Local xIsento   := "0"
   Local xContrib  := "1"
   Local xFormaPG  := "1"
   Local xProposta := "000001"

   Private lMsErroAuto := .F. 
   Private lMsHelpAuto := .F. 

   // #################################################################
   // Prepara o ambiente para realizar a inclus�o do pedido de venda ##
   // #################################################################
//   PREPARE ENVIRONMENT EMPRESA xCodEmp FILIAL xCodFil MODULO "FAT" TABLES "SC5","SC6","SA1","SA2","SB1","SB2","SF4"

   // ################################################################################
   // Gera a consist�ncias dos dados recebidos antes da inclus�o do Pedido de Venda ##
   // ################################################################################

   // ###################################################################################################
   // Tabela de retornos do Web Service Pedido de Venda Protheus                                       ##      
   // ###################################################################################################
   // 000 - Inclus�o de pedido de venda com sucesso                                                    ##
   // 001 - C�digo da Empresa n�o informada                                                            ##
   // 002 - C�digo da Filial n�o informada                                                             ##
   // 003 - Tipo de Pedido de Venda n�o informado                                                      ##
   // 004 - CNPJ/CPF do Cliente n�o informado                                                          ##
   // 005 - Condi��o de Pagamento n�o informada                                                        ##
   // 006 - Administradora de Cart�es n�o informada                                                    ##
   // 007 - Tipo de frete n�o informado                                                                ##
   // 008 - Valor do Frete                                                                             ##
   // 009 - Transportadora                                                                             ##
   // 010 - C�digo vendedor 1 n�o informado                                                            ##
   // 011 - C�digo da moeda n�o informada                                                              ##
   // 011 - C�digo do fornecedor externo n�o informado                                                 ##
   // 012 - C�digo da loja do fornecedor externo n�o informada                                         ##
   // 013 - C�digo(s) do(s) produto(s) do pedido de venda n�o informado(s)                             ##
   // 014 - Informa��o do(s) c�digo(s) do(s) produto(s) inconsist�nte (Sem informa��o do |)            ##
   // 015 - C�digo(s) do(s) produto(s) do pedido de venda n�o informado(s)                             ##
   // 016 - Informa��o da(s) quantidade(s) do(s) produto(s) inconsist�nte (Sem informa��o do |)        ##
   // 017 - Pre�o(s) unit�rio(s) do(s) produto(s) n�o informado(s)                                     ##
   // 018 - Informa��o do(s) pre�o(s) unit�rio(s) do(s) produto(s) inconsist�nte (Sem informa��o do |) ##
   // 019 - Valor Total do(s) produto(s) n�o informado(s)                                              ##
   // 020 - Informa��o do(s) total(is) do(s) produto(s) inconsist�nte (Sem informa��o do |)            ##
   // 021 - Percentual de comiss�o para o vendedor 1 n�o informada                                     ##
   // 022 - Percentual de comiss�o para o vendedor 2 n�o informada                                     ##
   // 023 - Conte�do do tipo de pedido de venda � inv�lido (Aceitos 1 ou 2)                            ##
   // 024 - Dados Cadastrais do Cliente                                                                ##
   // 025 - Nome do cliente n�o informado                                                              ##
   // 026 - Endere�o do cliente n�oo informado                                                         ##
   // 027 - UF do cliente n�o informado                                                                ##
   // 028 - Bairro do cliente n�o informado                                                            ##
   // 029 - Munic�pio do cliente n�o informado                                                         ##
   // 030 - CEP do endere�o do cliente n�o informado                                                   ##
   // 031 - DDD do telefone do cliente n�o informado                                                   ##
   // 032 - Telefone do cliente n�o informado                                                          ##
   // 033 - Inscri��o Estadual do cliente n�o informada                                                ##
   // 034 - E-mail do cliente n�o informado                                                            ##
   // 035 - Contato do cliente n�o informado                                                           ##
   // 036 - Indica��o de IE Isenta n�o informada                                                       ##
   // 037 - Informa��o do campo IE Isenta inconsistente (Aceitos somenete 0 ou 1)                      ##
   // 038 - Cliente contribuinte n�o informado                                                         ##   
   // 039 - Informa��o do campo Cliente Contribuinte inconsistente (Aceitos somenete 0 ou 1)           ##
   // 040 - Campo forma de pagamento n�o informado                                                     ##
   // 041 - Informa��o do campo forma de pagamento inconsistente (Aceitos somenete 1 ou 2)             ##
   // 042 - Erro ao gravar pedido de venda                                                             ##
   // 043 - N� da proposta comercial n�o informada                                                     ##
   // 044 - Cliente inexistente no Protheus                                                            ##
   // 045 - Informa��o da(s) moeda(s) inconsist�nte (Sem informa��o do |)                              ##
   // ###################################################################################################

   // #############################
   // Consiste c�digo da Empresa ##
   // #############################
   If Empty(Alltrim(xCodEmp))
      MsgAlert("001 - C�digo da Empresa n�o informada")
      Return(.T.)
   Endif

   // ############################
   // Consiste c�digo da Filial ##
   // ############################
   If Empty(Alltrim(xCodFil))
      MsgAlert("002 - C�digo da Filial n�o informada")
      Return(.T.)
   Endif

   // #####################################
   // Consiste o tipo de pedido de venda ##
   // #####################################
   If Empty(Alltrim(xTipPed))
      MsgAlert("003 - Tipo de Pedido de Venda n�o informado")
      Return(.T.)
   Endif

   // #################################################
   // Consiste o conte�do do tipo de pedido de venda ##
   // #################################################
   If Alltrim(xTipPed) <> "1" .And. Alltrim(xTipPed) <> "2"
      MsgAlert("023 - Conte�do do tipo de pedido de venda � inv�lido (Aceitos 1 ou 2)")
      Return(.T.)
   Endif   

   // ###############################
   // Consiste CNPJ/CPF do cliente ##
   // ###############################
   If Empty(Alltrim(xCGCCli))
      MsgAlert("004 - CNPJ/CPF do Cliente n�o informado")
      Return(.T.)
   Endif

   // ###################################
   // Consiste a Condi��o de Pagamento ##
   // ###################################
   If Empty(Alltrim(xCodCon))
      MsgAlert("005 - Condi��o de Pagamento n�o informada")
      Return(.T.)
   Endif

   // #######################################
   // Consiste a Administradora de Cart�es ##
   // #######################################
// If U_P_OCCURS(Upper(xCodCon), "CARTAO", 1) <> 0
//    If Empty(Alltrim(xCodAdm))
//       MsgAlert("006 - Administradora de Cart�es n�o informada")
//       Return(.T.)
//    Endif
// Endif

   // ###########################
   // Consiste o Tipo de Frete ##
   // ###########################
   If Empty(Alltrim(xTipFre))
      MsgAlert("007 - Tipo de frete n�o infromado")
      Return(.T.)
   Endif

   // ############################
   // Consiste o Valor do frete ##
   // ############################
// If Empty(Alltrim(xValFre))
//    MsgAlert("008 - Valor do Frete n�o informado")
//    Return(.T.)
// Endif

   // ############################
   // Consiste a Transportadora ##
   // ############################
// If Empty(Alltrim(xCodTra))
//    MsgAlert("009 - Transportadora n�o informada")
//    Return(.T.)
// Endif

   // ################################
   // Consiste o c�digo do Vendedor ##
   // ################################
   If Empty(Alltrim(xCodVen1))
      MsgAlert("010 - C�digo vendedor 1 n�o informado")
      Return(.T.)
   Endif

   // #############################
   // Consiste o c�digo da moeda ##
   // #############################
   If Int(Val(xCodMoe)) == 0
      MsgAlert("011 - C�digo da moeda n�o informada")
      Return(.T.)
   Endif

   If Empty(Alltrim(xCodMoe))
      MsgAlert("011 - Moeda n�o informada")
      Return(.T.)
   Else
      If U_P_OCCURS(xCodMoe, "|", 1) == 0
         MsgAlert("045 - Informa��o da(s) moeda(s) inconsist�nte (Sem informa��o do |)")
         Return(.T.)
      Endif
   Endif

   // ###################################################################
   // Consiste o c�digo e loja do fornecedor em caso de pedido externo ##
   // ###################################################################
   If Alltrim(xTipPed) == "1"

      If Empty(Alltrim(xForExt))
         MsgAlert("011 - C�digo do fornecedor externo n�o informado")
         Return(.T.)
      Endif

      If Empty(Alltrim(xLojExt))
         MsgAlert("012 - C�digo da loja do fornecedor externo n�o informada")
         Return(.T.)
      Endif

   Endif

   // #################################
   // Consiste o c�digo dos produtos ##
   // #################################
   If Empty(Alltrim(xCodPro))
      MsgAlert("013 - C�digo(s) do(s) produto(s) do pedido de venda n�o informado(s)")
      Return(.T.)
   Else
      If U_P_OCCURS(xCodPro, "|", 1) == 0
         MsgAlert("014 - Informa��o do(s) c�digo(s) do(s) produto(s) inconsist�nte (Sem informa��o do #)")
         Return(.T.)
      Endif
   Endif

   // #####################################
   // Consiste a quantidade dos produtos ##
   // #####################################
   If Empty(Alltrim(xQtdPro))
      MsgAlert("015 - C�digo(s) do(s) produto(s) do pedido de venda n�o informado(s)")
      Return(.T.)
   Else
      If U_P_OCCURS(xQtdPro, "|", 1) == 0
         MsgAlert("016 - Informa��o da(s) quantidade(s) do(s) produto(s) inconsist�nte (Sem informa��o do #)")
         Return(.T.)
      Endif
   Endif      

   // #######################################
   // Consiste o pre�o un�rio dos produtos ##
   // #######################################
   If Empty(Alltrim(xPrcPro))
      MsgAlert("017 - Pre�o(s) unit�rio(s) do(s) produto(s) n�o informado(s)")
      Return(.T.)
   Else
      If U_P_OCCURS(xPrcPro, "|", 1) == 0
         MsgAlert("018 - Informa��o do(s) pre�o(s) unit�rio(s) do(s) produto(s) inconsist�nte (Sem informa��o do #)")
         Return(.T.)
      Endif
   Endif      

   // ######################################
   // Consiste o valor total dos produtos ##
   // ######################################
   If Empty(Alltrim(xTotPro))
      MsgAlert("019 - Valor Total do(s) produto(s) n�o informado(s)")
      Return(.T.)
   Else
      If U_P_OCCURS(xTotPro, "|", 1) == 0
         MsgAlert("020 - Informa��o do(s) total(is) do(s) produto(s) inconsist�nte (Sem informa��o do #)")
         Return(.T.)
      Endif
   Endif      

   // ##################################################
   // Consiste o percentual de comiss�o do vendedor 1 ##
   // ##################################################
   If !Empty(Alltrim(xCodVen1))
      If Empty(Alltrim(xComis1))
         MsgAlert("021 - Percentual de comiss�o para o vendedor 1 n�o informada")
         Return(.T.)
      Endif
   Endif   

   // ##################################################
   // Consiste o percentual de comiss�o do vendedor 2 ##
   // ##################################################
   If !Empty(Alltrim(xCodVen2))
      If Empty(Alltrim(xComis2))
         MsgAlert("022 - Percentual de comiss�o para o vendedor 2 n�o informada")
         Return(.T.)
      Endif
   Endif   

   // #############################
   // Consiste o campo IE Isento ##
   // #############################
   If Empty(Alltrim(xIsento))
      MsgAlert("036 - Indica��o de IE Isenta n�o informada")
      Return(.T.)
   Endif

   If Alltrim(xIsento) <> "0" .And. Alltrim(xIsento) <> "1"
      MsgAlert("037 - Informa��o do campo IE Isenta inconsistente (Aceitos somenete 0 ou 1)")
      Return(.T.)
   Endif

   // ################################
   // Consiste o campo Contribuinte ##
   // ################################
   If Empty(Alltrim(xContrib))
      MsgAlert("038 - Cliente contribuinte n�o informado")
      Return(.T.)
   Endif

   If Alltrim(xContrib) <> "0" .And. Alltrim(xContrib) <> "1"
      MsgAlert("039 - Informa��o do campo Cliente Contribuinte inconsistente (Aceitos somenete 0 ou 1)")
      Return(.T.)
   Endif

   // ######################################
   // Consiste o campo forma de pagamento ##
   // ######################################
   If Empty(Alltrim(xFormaPG))
      MsgAlert("040 - Campo forma de pagamento n�o informado")
      Return(.T.)
   Endif

   If Empty(Alltrim(xFormaPG))
//      MsgAlert("041 - Informa��o do campo forma de pagamento inconsistente (Aceitos somenete 1 ou 2)")
//      Return(.T.)
   Else   
      //If xFormaPG$("1#2")
      If U_P_OCCURS(Upper(xCodCon), "CARTAO", 1) == 0      
         xFormaPG := "1"
         xCodAdm  := "  "
      Else
         xFormaPG := "2"
         xCodAdm  := "02"
      Endif   
   Endif

   // #######################################################################
   // Consiste o n� da proposta comercial de v�nculo com o pedido de venda ##
   // #######################################################################
   If Empty(Alltrim(xProposta))
      MsgAlert("043 - N� da proposta comercial n�o informada")
      Return(.T.)
   Endif

   // #####################################
   // Se o cliente n�o existir, o inclui ##
   // #####################################
   If Select("T_CLIENTE") > 0
      T_CLIENTE->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT A1_COD ,"
   cSql += "       A1_LOJA,"
   cSql += "       A1_NOME "
   cSql += "  FROM SA1010 (Nolock)"
   cSql += " WHERE A1_CGC     = '" + Alltrim(xCGCCLI) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )

   If T_CLIENTE->( EOF() )
      MsgAlert("044 - Cliente informado inexistente no Protheus")
      Return(.T.)
   Else

      cCodigo := T_CLIENTE->A1_COD
      cLoja   := T_CLIENTE->A1_LOJA

      // ##########################################################################
      // Verifica se o cliente � jur�dico ou f�sico para pesquisa do novo c�digo ##
      // ##########################################################################
      _Juridico := IIF(Len(Alltrim(xCGCCli)) == 14, "S", "N")

   Endif
   
   // ###########################
   // Inclui o Pedido de Venda ##
   // ###########################

   // #############################################
   // Pesquisa o c�digo da condi��o de pagamento ##
   // #############################################
   If Select("T_CONDICAO") > 0
      T_CONDICAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT E4_CODIGO,"
   cSql += "       E4_DESCRI "
   cSql += "  FROM SE4010    "
   cSql += " WHERE E4_DESCRI = '" + Alltrim(xCodCon) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONDICAO", .T., .T. )

   nCodigoCond := IIF(T_CONDICAO->( EOF() ), "", T_CONDICAO->E4_CODIGO)

   // ######################################################################################################   
   // Verifica quantos pedidos de venda ser�o abertos conforme a quantidade de moeda enviada no par�metro ##
   // ######################################################################################################
   nNumeroPedido := 0

   kMoeda1 := U_P_OCCURS(xCodMoe, "1", 1) 
   kMoeda2 := U_P_OCCURS(xCodMoe, "2", 1) 

   If kMoeda1 <> 0
      nNumeroPedido := nNumeroPedido + 1
   Endif
      
   If kMoeda2 <> 0
      nNumeroPedido := nNumeroPedido + 1
   Endif

   // ##############################################
   // Faz o la�o de abertura dos pedidos de venda ##
   // ##############################################
   For nVezes = 1 to nNumeroPedido

       // ###############################################
       // Pesquisa o pr�ximo c�digo de pedido de venda ##
       // ###############################################
       cNumPed := GetSX8Num("SC5","C5_NUM")

       // ##########################################################
       // Cria array com os dados do cabe�alho do pedido de venda ##
       // ##########################################################


       aAdd(_aCabec,{"C5_NUM"    , cNumPed          , Nil}) // N�mero do Pedido de Venda
       aAdd(_aCabec,{"C5_TIPO"   , "N"              , Nil}) // Tipo do Pedido de Venda
       aAdd(_aCabec,{"C5_CLIENTE", cCodigo          , Nil}) // Codigo do Cliente
       aAdd(_aCabec,{"C5_LOJACLI", cLoja            , Nil}) // Loja do Cliente
       aAdd(_aCabec,{"C5_CLIENT" , cCodigo          , Nil}) // Codigo do Cliente de Entrega
       aAdd(_aCabec,{"C5_LOJAENT", cLoja            , Nil}) // Loja do Cliente de Entrega
       aAdd(_aCabec,{"C5_CONDPAG", nCodigoCond      , Nil}) // Condi��o de Pagamento
                     

//       aAdd(_aCabec,{"C5_FILIAL" , xCodFil          , Nil}) // N�mero do Pedido de Venda
//       aAdd(_aCabec,{"C5_ZPNUV"  , xProposta        , Nil}) // C�digo da proposta do SaleMachine
//       aAdd(_aCabec,{"C5_TIPOCLI", "F"              , Nil}) // Tipo do Cliente
//       aAdd(_aCabec,{"C5_EMISSAO", dDatabase        , Nil}) // Data de Emissao
//       aAdd(_aCabec,{"C5_MOEDA"  , nVezes           , Nil}) // Moeda
//       aAdd(_aCabec,{"C5_EXTERNO", xTipPed          , Nil}) // Tipo de Pedido de Venda (Interno/Externo)
//       aAdd(_aCabec,{"C5_FORMA"  , xFormaPG         , Nil}) // Forma de Pagamento

//       // #####################################################################################
//       // Grava o c�digo da Administradora de cart�es se condi��o de pagamento for de cart�o ##
//       // #####################################################################################
//       If !Empty(Alltrim(xCodAdm))
//          aAdd(_aCabec,{"C5_ADM"    , xCodAdm          , Nil}) // Administradora de Cart�es
//       Endif   

//       aAdd(_aCabec,{"C5_VEND1"  , xCodVen1         , Nil}) // C�digo do Vendedor 1  
//       aAdd(_aCabec,{"C5_TIPLIB" , "1"              , Nil}) // Tipo de Libera��o do Pedido (1 = Por Item)
//       aAdd(_aCabec,{"C5_TPFRETE", xTipFre          , Nil}) // Tipo do frete

//       // ###############################################################
//       // Grava o c�digo da transportadora se foi passado no par�metro ##
//       // ###############################################################
//       If !Empty(Alltrim(xCodTra))
//          aAdd(_aCabec,{"C5_TRANSP" , xCodTra          , Nil}) // C�digo da transportadora
//       Endif   

//       aAdd(_aCabec,{"C5_FRETE"  , VAL(xValFre)     , Nil}) // Valor do frete

//       // ###########################################################
//       // Grava o c�digo do vendedor 2 se foi passado no par�metro ##
//       // ###########################################################
//       If !Empty(Alltrim(xCodVen2))
//          aAdd(_aCabec,{"C5_VEND2", xCodVen2 , Nil}) // C�digo do Vendedor 2  
//       Endif
 
//       // ##################################################################################
//       // Grava o c�digo/loja do distribuidor em caso de pedido de venda de intermedia��o ##
//       // ##################################################################################
//       If Alltrim(xTipPed) == "1"
//          aAdd(_aCabec,{"C5_FORNEXT", xForExt          , Nil}) // C�digo do fornecedor externo (Distribuidor)
//          aAdd(_aCabec,{"C5_LOJAEXT", xLojExt          , Nil}) // Loja do fornecedor externo (Distribuidor)
//       Endif   

       // #########################################################
       // Cria o array com os dados dos itens do pedido de venda ##
       // #########################################################
       For nContar = 1 to U_P_OCCURS(xCodPro, "|", 1)
   
           // ####################################
           // Considera produtos da mesma moeda ##
           // ####################################
           
           If Int(Val(U_P_CORTA(xCodMoe, "|", nContar)))  == nVezes
           Else
              Loop
           Endif   

           // ###################################################
           // Pesquisa o TES correspondente ao cliente/produto ##
           // ###################################################
           If xTipPed == "1"
              kTES := "543"
           Else   
              Do Case
                 Case _Juridico == "S" .And. xIsento == "0"
                      kTES := MaTesInt(2, "03", cCodigo, cLoja, "C", U_P_CORTA(xCodPro,"|", nContar))          

                 Case _Juridico == "S" .And. xIsento == "1"
                      kTES := MaTesInt(2, "02", cCodigo, cLoja, "C", U_P_CORTA(xCodPro,"|", nContar))          
       
                 Case _Juridico == "N"
                      kTES := MaTesInt(2, "02", cCodigo, cLoja, "C", U_P_CORTA(xCodPro,"|", nContar))          
              EndCase        
           Endif

           // ########################################################## 
           // Pesquisa a Situa��o Tribut�ria do produto para grava��o ##
           // ##########################################################
           xSituacao := Posicione( "SB1", 1, xFilial("SB1") + U_P_CORTA(xCodPro,"|", nContar), "B1_ORIGEM" ) + ;
                        Posicione( "SF4", 1, xFilial("SF4") + kTES                           , "F4_SITTRIB")

           // ###############################
           // Carrega o array dos produtos ##
           // ###############################
           aAdd(_aItens, {{"C6_NUM"    , cNumPed                                                                                     , Nil},; // C�digo do Produto
                          {"C6_ITEM"   , Strzero(nContar,02)                                                                         , Nil},; // C�digo do Produto
                          {"C6_PRODUTO", Alltrim(U_P_CORTA(xCodPro,"|", nContar))                                                    , Nil},; // C�digo do Produto
                          {"C6_UM"     , Alltrim(Posicione( "SB1", 1, xFilial("SB1") + U_P_CORTA(xCodPro,"|", nContar), "B1_UM" ))   , Nil},; // Unidade de medida (primeira)
                          {"C6_QTDVEN" , VAL(U_P_CORTA(xQtdPro,"|", nContar))                                                        , Nil},; // Quantidade vendida do produto
                          {"C6_PRCVEN" , VAL(U_P_CORTA(xPrcPro,"|", nContar))                                                        , Nil},; // Preco venda do produto
                          {"C6_PRUNIT" , VAL(U_P_CORTA(xPrcPro,"|", nContar))                                                        , Nil},; // Preco unitario
                          {"C6_TES"    , kTES                                                                                        , Nil}}) // Tipo de entrada/sa�da do produto

//                          {"C6_CF"     , Alltrim(Posicione( "SF4", 1, xFilial("SSF4") + kTES, "F4_CF"))                              , Nil},; // Classifica��o fiscal do produto pela tes
//                          {"C6_LOCAL"  , "01"                                                                                        , Nil},; // Almoxarifado 
//                          {"C6_CLI"    , cCodigo                                                                                     , Nil},; // C�digo do cliente 
//                          {"C6_LOJA"   , cLoja                                                                                       , Nil},; // Loja do cliente
//                          {"C6_COMIS1" , VAL(U_P_CORTA(xComis1,"|", nContar))                                                        , Nil},; // % comiss�o vendedor 1
//                          {"C6_COMIS2" , VAL(U_P_CORTA(xComis2,"|", nContar))                                                        , Nil},; // % comiss�o vendedor 2
//                          {"C6_DESCRI" , Alltrim(Posicione( "SB1", 1, xFilial("SB1") + U_P_CORTA(xCodPro,"|", nContar), "B1_DESC"))  , Nil},; // Descri��o do produto
//                          {"C6_PARNUM" , Alltrim(Posicione( "SB1", 1, xFilial("SB1") + U_P_CORTA(xCodPro,"|", nContar), "B1_PARNUM")), Nil},; // Partnumber do produto
//                          {"C6_CODFAB" , Posicione( "SB1", 1, xFilial("SB1") + U_P_CORTA(xCodPro,"|", nContar), "B1_PROC")           , Nil},; // C�digo do fabricante
//                          {"C6_LOJAFA" , Posicione( "SB1", 1, xFilial("SB1") + U_P_CORTA(xCodPro,"|", nContar), "B1_LOJPROC")        , Nil},; // Loja do fabricante
//                          {"C6_CLASFIS", xSituacao                                                                                   , Nil},; // Situa��o tribut�ria do poroduto
//                          {"C6_STATUS" , "01"                                                                                        , Nil},; // Status do produto 01 - Aguardando libera��o
//                          {"C6_TEMDOC" , "N"                                                                                         , Nil},; // Indica se qguarda documenta��o do cliente
//                          {"C6_RATEIO" , "2"                                                                                         , Nil},; // Rateio
//                          {"C6_TPOP"   , "F"                                                                                         , Nil}}) // Tipo de ordem de produ��o

//                          {"C6_VALOR"  , VAL(U_P_CORTA(xTotPro,"|", nContar))                                                        , Nil},; // Valor total do produto
//                          {"C6_ENTREG" , Dtos(Date())                                                                                , Nil},; // Data da entrega
//                          {"C6_SUGENTR", Dtos(Date())                                                                                , Nil},; // Data de sugest�o de entrega

      Next nContar

      // ##############################################################
      // Executa o comando de inclus�o autom�tica do pedido de venda ##
      // ##############################################################
      nModulo := 5
      MsExecAuto({|x, y, z| MATA410(x, y, z)}, _aCabec, _aItens, 3) 

      If lMsErroAuto
         MsgAlert("Erro na inclus�o do pedido")
         Return(.T.)
      Else
         MsgAlert("000 - " + Alltrim(cNumPed))
         Return(.T.)
      EndIf
      
   Next nVezes   

Return(.T.)        

// ------------------------------------------------------------------------------------------------------------------------------------------------------- ##
// Par�metros para testar o web service                                                                                                                    ##
// ------------------------------------------------------------------------------------------------------------------------------------------------------- ##
// Exemplo de chamada da URL + Par�mentros
// http://54.94.245.225:8094/rest/AT_GRAVAPVENDA?cCodEmp="01"&cCodFil="01"&cTipPed="1"&cCGCCli="02836152000154"&cCodCon="A VISTA - DINHEIRO"&cCodAdm="02"&cTipFre="C"&cValFre="50.00"&cCodTra="000008"&cCodVen1="000001"&cCodVen2=""&cCodMoe="1"&cForExt="000011"&cLojExt="001"&cCodPro="004442|"&cQtdPro="1|"&cPrcPro="1000.00|"&cTotPro="1000.00|"&cComis1="0.50|"&cComis2="0.00|"&cIsento="0"&cContrib="1"&cFormaPG="1"&cProposta="000001"
// Static Function imppvsp(P01, P02, P03, P04, P05, P06, P07, P08, P09, P10, P11, P12, P13, P14, P15, P16, P17, P18, P19, P20, P21, P22, P23, P24, P25)    ##
// imppvsp("01",; // Empresa                                                                                                                               ##
//         "01",; // Filial                                                                                                                                ##
//         "1" ,; // Tipo de Pedido                                                                                                                        ##
//         "02836152000154",;                                                                                                                              ##
//         "HARALD HANS LOSCHENKOHL#AV CARLOS VENTURA, 440 AP 202#RS#ENGENHO#GUAIBA#92500000#51#984825852#147/8243616#harald@automatech.com.br#HARALD#",;  ##
//         "A VISTA - DINHEIRO                      "     ,;                                                                                               ##
//         "02"      ,;                                                                                                                                    ##
//         "C"       ,;                                                                                                                                    ##
//         "50.00"   ,;                                                                                                                                    ##
//         "000008"  ,;                                                                                                                                    ##
//         "000001"  ,;                                                                                                                                    ##
//         "      "  ,;                                                                                                                                    ##
//         "1"       ,;                                                                                                                                    ##
//         "000011"  ,; //                                                                                                                                 ##
//         "001"     ,; //                                                                                                                                 ##
//         "004442#" ,;                                                                                                                                    ##
//         "1#"      ,;                                                                                                                                    ##
//         "1000.00#",;                                                                                                                                    ##
//         "1000.00#",;                                                                                                                                    ##
//         "0.50#"   ,;                                                                                                                                    ##
//         "0.00#"   ,;                                                                                                                                    ##
//         "0"       ,;                                                                                                                                    ##
//         "1"       ,;                                                                                                                                    ##
//         "1"       ,;                                                                                                                                    ##
//         "000001")                                                                                                                                       ##
// ------------------------------------------------------------------------------------------------------------------------------------------------------- ##