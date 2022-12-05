#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"

// ###################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            ##
// -------------------------------------------------------------------------------- ##
// Referencia: AT_ANALISECREDITO                                                    ##
// Parâmetros: Nenhum                                                               ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                      ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                              ##
// Data......: 21/05/2018                                                           ##
// Objetivo..: Web Service que realiza a Análise de Crédito de Pedidos de Venda     ##
// Parâmetros: Conforme data abaixo                                                 ##
// Chamada...: http://172.30.2.164:8099/rest/AT_ANALISECREDITO?cCodEmpresa=01       ## 
//             &cCodFilial=01&cCodPedido=147236&cCodStatus=A                        ##
//             &cDadosCartao=02 |319   |8910|383576|000000330||20180521|651.70|     ##
//             &cNrSerasa=034714                                                    ##
// ###################################################################################

WSRESTFUL AT_ANALISECREDITO DESCRIPTION "Advpl Tools - Service Analise de Credito"

    WSDATA cCodEmpresa  AS STRING // Código da Empresa
    WSDATA cCodFilial   AS STRING // Código da Filial
    WSDATA cCodPedido   AS STRING // Código do Pedido de Venda
    WSDATA cCodStatus   AS STRING // Status da Análise (A = Aprovado, R = Rejeitado)
    WSDATA cDadosCartao AS STRING // Dados do Cartão
    WSDATA cNrSerasa    AS STRING // Nr. Análise Serasa

   WSMETHOD GET DESCRIPTION "Advpl Tools - Service Analise de Credito" WSSYNTAX "/AT_ANALISECREDITO || /AT_ANALISECREDITO/{cCodEmpresa}{cCodFilial}{cCodPedido}{cCodStatus}{cDadosCartao}{cNrSerasa} "

END WSRESTFUL

WSMETHOD GET WSRECEIVE cCodEmpresa, cCodFilial, cCodPedido, cCodStatus, cDadosCartao, cNrSerasa WSSERVICE AT_ANALISECREDITO

   Local cSql       := ""
   Local lServ      := .F.
   Local _lEhCartao := .F.
   Local lChumbado  := .F.
   Local aComboBx1  := {"Scaner","Manual"}
   Local _cIdentC5   := Space(06)
   Local lChumba    := .F.

   Local xCodEmpresa  := Space(02)
   Local xCodFilial   := Space(02)
   Local xCodPedido   := Space(06)
   Local xCodStatus   := Space(01)
   Local xDadosCartao := ""
   Local xAdministra  := ""
   Local xBandeira    := ""
   Local xDigito      := ""
   Local xAutorizacao := ""
   Local xTID         := ""
   Local xDocumento   := ""
   Local xDtransacao  := ""
   Local xValorCartao := ""
   Local xNrSerasa    := ""

   Local _lTemEstoq := .f.    // Indica se tem saldo suficiente em estoque

   Private aAdministra := {}
   Private aBandeiras  := {}
   Private cComboBx2
   Private cComboBx3
   Private kPedido     := Space(06)
   Private kCliente    := ""
   Private kDigi       := Space(04)
   Private kEmissao    := Ctod("  /  /    ")
   Private kDocumento  := Space(06)
   Private kAutoriza   := Space(06)
   Private kNumTid     := Space(16)
   Private kValorCart  := 0

   Private lMsErroAuto := .F. 
   Private lMsHelpAuto := .F. 

   xCodEmpresa  := Self:cCodEmpresa
   xCodFilial   := Self:cCodFilial
   xCodPedido   := Self:cCodPedido
   xCodStatus   := Self:cCodStatus
   xDadosCartao := IIF(Empty(Alltrim(Self:cDadosCartao)), "", Self:cDadosCartao)
   xNrSerasa    := IIF(Empty(Alltrim(Self:cNrSerasa)), "", Self:cNrSerasa)    
   xAdministra  := IIF(Empty(Alltrim(U_P_CORTA(xDadosCartao, "|", 1))), "", U_P_CORTA(xDadosCartao, "|", 1))
   xBandeira    := IIF(Empty(Alltrim(U_P_CORTA(xDadosCartao, "|", 2))), "", U_P_CORTA(xDadosCartao, "|", 2))
   xDigito      := IIF(Empty(Alltrim(U_P_CORTA(xDadosCartao, "|", 3))), "", U_P_CORTA(xDadosCartao, "|", 3))
   xAutorizacao := IIF(Empty(Alltrim(U_P_CORTA(xDadosCartao, "|", 4))), "", U_P_CORTA(xDadosCartao, "|", 4))
   xTID         := IIF(Empty(Alltrim(U_P_CORTA(xDadosCartao, "|", 5))), "", U_P_CORTA(xDadosCartao, "|", 5))
   xDocumento   := IIF(Empty(Alltrim(U_P_CORTA(xDadosCartao, "|", 6))), "", U_P_CORTA(xDadosCartao, "|", 6))
   xDtransacao  := IIF(Empty(Alltrim(U_P_CORTA(xDadosCartao, "|", 7))), "", U_P_CORTA(xDadosCartao, "|", 7))
   xValorCartao := IIF(Empty(Alltrim(U_P_CORTA(xDadosCartao, "|", 8))), "", U_P_CORTA(xDadosCartao, "|", 8))

   Conout("=================================================")
   Conout("==        Parametros recebidos pela URL        ==")
   Conout("=================================================")
   Conout("Codigo da Empresa.......: " + xCodEmpresa)
   Conout("Codigo da Filial........: " + xCodFilial)
   Conout("Codigo do Pedido Venda..: " + xCodPedido)
   Conout("Codigo do Status Analise: " + xCodStatus)
   Conout("Dados Cartao............: " + xDadosCartao)
   Conout("Numero Analise SERASA...: " + xNrSerasa)   
   Conout("Administradora..........: " + xAdministra)
   Conout("Bandeira................: " + xBandeira)
   Conout("Ultimos 4 digitos.......: " + xDigito)
   Conout("Autorizacao.............: " + xAutorizacao)
   Conout("Numero TID Cartao.......: " + xTID)
   Conout("Documento...............: " + xDocumento)
   Conout("Data Transacao..........: " + xDtransacao)
   Conout("Valor da Transacao......: " + xValorCartao)
   Conout("=================================================")

   // ###############################################################################
   // Seta o código da Empresa conforme parâmetro para inclusão do pedido de venda ##
   // ###############################################################################
   PREPARE ENVIRONMENT EMPRESA xCodEmpresa FILIAL cCodFilial USER 'Administrador' PASSWORD '@tech15021' TABLES "SFM", "SC5","SC6","SA1","SA2","SB1","SB2","SF4", "SC9" MODULO 'FAT'

   If Empty(Alltrim(xCodEmpresa)) .And. Empty(Alltrim(xCodFilial))
   Else
      TALTEMPFIL(xCodEmpresa, xCodFilial)
   Endif   

   // ##################################################################################################
   // Gera a consistências dos dados recebidos antes da gravação do novo limite de crédito do cliente ##
   // ##################################################################################################

   // ###################################################################################################
   // Tabela de retornos do Web Service - Limite de Crédito                                            ##
   // ###################################################################################################
   // 000 - Pedido de Venda com Análise de Crédito Liberado com Sucesso                                ##
   //       Pedido de Venda com Análise de Crédito Rejeitado com Sucesso                               ##
   // 001 - Código da Empresa não informado                                                            ##
   // 002 - Código da Filial da Empresa não informada                                                  ##
   // 003 - Código do Pedido de Venda não informado                                                    ##
   // 004 - Status da Análise de Crédito não informado                                                 ##
   // 005 - Pedido de Venda nao localizado para esta Empresa/Filial                                    ##
   // 006 - Administradora de Cartão não informada                                                     ##
   // 007 - Bandeira do Cartão não informada                                                           ##
   // 008 - Dígitos do Cartão n]ao informado                                                           ##
   // 009 - Não da Autorização não informado                                                           ##
   // 010 - Número do TID não informado                                                                ##
   // 011 - Data da Transação não informada                                                            ##
   // 012 - Valor da Transação não informada                                                           ##
   // ###################################################################################################

   // ###############################
   // Consiste o código da Empresa ##
   // ###############################
   If Empty(Alltrim(xCodEmpresa))
      Conout("001 - Codigo da Empresa nao informado")      
      cString := "001 - Código da Empresa não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)     
      RESET ENVIRONMENT
      Return(.T.)
   Endif

   // ##############################
   // Consiste o código da Filial ##
   // ##############################
   If Empty(Alltrim(xCodFilial))
      Conout("002 - Codigo da Filial nao informada")      
      cString := "002 - Código da Filial não informada"
      ::SetContentType("text/plain")
      ::SetResponse(cString)     
      RESET ENVIRONMENT
      Return(.T.)
   Endif

   // #######################################
   // Consiste o código do Pedido de Venda ##
   // #######################################
   If Empty(Alltrim(xCodPedido))
      Conout("003 - Codigo do Pedido de Venda nao informado")      
      cString := "003 - Código do Pedido de Venda não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)     
      RESET ENVIRONMENT
      Return(.T.)
   Endif

   // ###############################
   // Consiste o Status da Análise ##
   // ###############################
   If Empty(Alltrim(xCodStatus))
      Conout("004 - Status da Analise de Credito nao informado")      
      cString := "004 - Status da Analise de Crédito não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)     
      RESET ENVIRONMENT
      Return(.T.)
   Endif

   // #############################################################
   // Verifica se o pedido de venda existe para a Empresa/Filial ##
   // #############################################################
   DbSelectArea("SC5")
   DbSetOrder(1)
   If DbSeek( xFilial("SC5") + xCodPedido )
   Else
      Conout("005 - Pedido de Venda nao localizado para esta Empresa/Filial")      
      cString := "005 - Pedido de Venda não localizado para esta Empresa/Filial"
      ::SetContentType("text/plain")
      ::SetResponse(cString)     
      RESET ENVIRONMENT
      Return(.T.)
   Endif   

   // ################################
   // Carrega variáveis de trabalho ##
   // ################################
   _cIdentC5 := SC5->C5_NUM
   kPedido   := SC5->C5_NUM
   kCliente  := SC5->C5_CLIENTE + "." + SC5->C5_LOJACLI + " - " + Alltrim(Posicione("SA1",1, xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI, "A1_NOME"))

   _aAreaIni := GetArea()
   _aAreaSC6 := SC6->( GetArea() )
   _aAreaSC9 := SC9->( GetArea() )
   _aAreaSC5 := SC5->( GetArea() )

   // #############################################################################################################################################
   // Verifica pela condição de pagamento se esta é de Cartão e seta a variável lEhCartao para abrir a solicitação de dados do cartão de crédito ##
   // #############################################################################################################################################
   If Select("T_CONDICAO") > 0
      T_CONDICAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC5.C5_FILIAL ,"
   cSql += "       SC5.C5_NUM    ,"
   cSql += "       SC5.C5_CONDPAG,"
   cSql += "      SE4.E4_DESCRI  "
   cSql += "  FROM " + RetSqlName("SC5") + " (Nolock) SC5, "
   cSql += "       " + RetSqlName("SE4") + " (Nolock) SE4  "
   cSql += " WHERE SC5.C5_FILIAL  = '" + Alltrim(xCodFilial) + "'"
   cSql += "   AND SC5.C5_NUM     = '" + Alltrim(xCodPedido) + "'"
   cSql += "   AND SC5.D_E_L_E_T_ = ''"
   cSql += "   AND SE4.E4_CODIGO  = SC5.C5_CONDPAG"
   cSql += "   AND SE4.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONDICAO", .T., .T. )

   Conout("Condicção de Pagamento: " + T_CONDICAO->E4_DESCRI)


   If U_P_OCCURS(T_CONDICAO->E4_DESCRI, "CARTAO", 1) == 0
      _lEhCartao := .F.
   Else
      _lEhCartao := .T.      
   Endif   

   // #########################################################################
   // Se condição de pagamento for cartão, consiste dados enviados do cartão ##
   // #########################################################################
   If _lEhCartao == .T.   
      
      If Empty(Alltrim(xAdministra))
         Conout("006 - Administradoras de Cartoes não informada")      
         cString := "006 - Administradoras de Cartões não informada"
         ::SetContentType("text/plain")
         ::SetResponse(cString)     
         RESET ENVIRONMENT
         Return(.T.)
      Endif   

      If Empty(Alltrim(xBandeira))
         Conout("007 - Badeira do Cartao nao informada")      
         cString := "007 - Bandeira do Cartão não informada"
         ::SetContentType("text/plain")
         ::SetResponse(cString)     
         RESET ENVIRONMENT
         Return(.T.)
      Endif   

      If Empty(Alltrim(xDigito))
         Conout("008 - Digitos do Cartao nao informado")      
         cString := "008 - Digitos do Cartão não informado"
         ::SetContentType("text/plain")
         ::SetResponse(cString)     
         RESET ENVIRONMENT
         Return(.T.)
      Endif   

      If Empty(Alltrim(xAutorizacao))
         Conout("009 - Número da Autorização do Cartao nao informado")      
         cString := "009 - Número da Autorização do Cartão não informado"
         ::SetContentType("text/plain")
         ::SetResponse(cString)     
         RESET ENVIRONMENT
         Return(.T.)
      Endif   

      If Empty(Alltrim(xTID))
         Conout("010 - Número do TID nao informado")      
         cString := "010 - Número do TID não informado"
         ::SetContentType("text/plain")
         ::SetResponse(cString)     
         RESET ENVIRONMENT
         Return(.T.)
      Endif   

      If Empty(Alltrim(xDtransacao))
         Conout("011 - Data da Transacao nao informada")      
         cString := "011 - Data da Transação não informada"
         ::SetContentType("text/plain")
         ::SetResponse(cString)     
         RESET ENVIRONMENT
         Return(.T.)
      Endif   

      If Empty(Alltrim(xValorCartao))
         Conout("012 - Valor da transacao nao informado")      
         cString := "012 - Valor da Transação não informdo"
         ::SetContentType("text/plain")
         ::SetResponse(cString)     
         RESET ENVIRONMENT
         Return(.T.)
      Endif   
      
   Endif   

   // ###########################################
   // Pesquisa o pedido de venda na tabela SC9 ##      
   // ###########################################                                                 
   _cSql := ""
   _cSql := "SELECT C9_PEDIDO, "
   _cSql += "       C9_ITEM  , "
   _cSql += "       C9_BLCRED  "
   _cSql += "  FROM " + RetSqlName("SC9") 
   _cSql += " WHERE C9_PEDIDO = '" + Alltrim(xCodPedido) + "'"
   _cSql += "   AND C9_FILIAL = '" + Alltrim(xCodFilial) + "'"
   _cSql += "   AND D_E_L_E_T_ = ''"

   dbUseArea(.T.,"TOPCONN", TCGenQry(,,_cSql),"T_C9", .F., .T.)

   While !T_C9->( Eof() )
   
      dbSelectArea("SC6")
      dbSetOrder(1)
      dbSeek( xCodFilial + T_C9->C9_PEDIDO + T_C9->C9_ITEM )
   
      If xCodStatus == "A"
 
         If Empty( SC6->C6_NOTA ) // Jean Rehermann | Solutio - 20/12/2012 - Validação para não alterar o status de itens de um mesmo pedido faturado parcial

            // ############################################
            //                Projeto PCP                ##
            // Geraçao da OP após a liberação de credito ##
            // ############################################
            // If (cEmpAnt == "01" .And. xCodfilial == "04") .Or. ;
            //    (cEmpAnt == "03" .And. xCodfilial == "01") .Or. ;
            //    (cEmpAnt == "01" .And. xCodfilial == "07")
            If (LEFT(SC6->C6_PRODUTO,2) == "02" .Or. LEFT(SC6->C6_PRODUTO,2) == "03")
		    
               // ##########################################################################################################
               // # 4416 - Ped. de contrato ATECH não deve cai em Ag. data de entrega. Cai em 10 - Aguardando Faturamento ##
               //          Somente para pedidos com TES = 717                                                             ##
               // ##########################################################################################################
               If SC6->C6_TES == "717"
            
                  Reclock("SC6",.f.)
                  SC6->C6_STATUS := "10"
                  MsUnlock()
            
                  // #####################################################
                  // Gravo o log de atualização de status na tabela ZZ0 ##
                  // #####################################################
                  U_GrvLogSts( xCodFilial, SC6->C6_NUM, SC6->C6_ITEM, "10", "WS_MT450FIM", 0 )
		    
                  // ################################
                  // Atualiza a hora na tabela SC9 ##
                  // ################################
                  dbSelectArea("SC9")
                  dbSetOrder(1)
                  If dbSeek( xCodFilial + SC6->C6_NUM + SC6->C6_ITEM)
                     RecLock("SC9",.F.)
                     SC9->C9_BLCRED := ""
                     SC9->C9_BLEST  := ""
                     MsUnLock()
                  Endif //dbSeek
		    
               Else //SC6->C6_TES == "717"
                                                                                                                                                    
                  // ##################################################################################################################################
                  // Se o produto que está sendo liberado não for etiqueta, sistema verificará se o saldo do produto (SB2) atende ao pedido de venda ##
                  // Se não atender, será flegado o campo C6_PCS com S indicando que este produto deverá ser enviado para o status 06 - Em Compra no ##
                  // Processo de Liberação de Estoque.                                                                                               ##
                  // ##################################################################################################################################
                  kPCS := ""
               
                  If (LEFT(SC6->C6_PRODUTO,2) == "02" .Or. LEFT(SC6->C6_PRODUTO,2) == "03")
                  Else
                     DbSelectArea("SB2")
                     DbSetOrder(1)
            
                     If DbSeek(xCodFilial + SC6->C6_PRODUTO + SC6->C6_LOCAL)
                             _nSldProduto := SaldoSB2()
                     Else
                             _nSldProduto := 0
                     EndIf // DbSeek
               
                     If (_nSldProduto) >= ( SC6->C6_QTDVEN )
                        kPCS := ""
                     Else
                        kPCS := "S"
                     Endif
                  Endif //(LEFT(SC6->C6_PRODUTO,2) == "02" .Or. LEFT(SC6->C6_PRODUTO,2) == "03")
               
                  Reclock("SC6",.f.)
                  SC6->C6_STATUS := "04"
                  SC6->C6_PCS    := kPCS
                  MsUnlock()
            
                  // #####################################################
                  // Gravo o log de atualização de status na tabela ZZ0 ##
                  // #####################################################
                  U_GrvLogSts( xCodFilial, SC6->C6_NUM, SC6->C6_ITEM, "04", "WS_MT450FIM", 0 )
		    
                  // ################################
                  // Atualiza a hora na tabela SC9 ##
                  // ################################
                  dbSelectArea("SC9")
                  dbSetOrder(1)
                  If dbSeek( xCodFilial + SC6->C6_NUM + SC6->C6_ITEM)
                     RecLock("SC9",.F.)
                     SC9->C9_BLCRED := ""
                     SC9->C9_BLEST  := "03"
                     MsUnLock()
                  Endif //dbSeek
             
               Endif //SC6->C6_TES == "717"
            
            Else //(LEFT(SC6->C6_PRODUTO,2) == "02" .Or. LEFT(SC6->C6_PRODUTO,2) == "03")
		    
               // ################################
               // Atualiza a hora na tabela SC9 ##
               // ################################
               dbSelectArea("SC9")
               dbSetOrder(1)
               If dbSeek( xCodFilial + SC6->C6_NUM + SC6->C6_ITEM )
                  RecLock("SC9",.F.)
                  SC9->C9_BLCRED := ""
                  MsUnLock()
               Endif //dbSeek
		    
               // ##################################################################
               // Envia para a função que atualiza o status do produto do pedido ##
               // ##################################################################
               xGravaSts("PE_MT450FIM")
		    
            Endif //(LEFT(SC6->C6_PRODUTO,2) == "02" .Or. LEFT(SC6->C6_PRODUTO,2) == "03")
            
         EndIf //Empty( SC6->C6_NOTA ) // Jean Rehermann | Solutio - 20/12/2012 - Validação para não alterar o status de itens de um mesmo pedido faturado parcial
        
      Else //xCodStatus == "A"
     
         // ################################
         // Atualiza a hora na tabela SC9 ##
         // ################################
         dbSelectArea("SC9")
         dbSetOrder(1)
         If dbSeek( xCodFilial + SC6->C6_NUM + SC6->C6_ITEM)
            RecLock("SC9",.F.)
            SC9->C9_BLCRED := "09"
            MsUnLock()
         Endif
                              
         // ###################################################################
         // Atualiza o status do pedido de venda com o Status 15 - Rejeitado ##
         // ###################################################################
         Reclock("SC6",.f.)
         SC6->C6_STATUS := "15"
         MsUnlock()

         // #####################################################
         // Atualiza o log de status do produto do pedido lido ##
         // #####################################################
         U_GrvLogSts( xCodFilial, SC6->C6_NUM, SC6->C6_ITEM, "09", "WS_MT450FIM", 0 )
         
      Endif //xCodStatus == "A"
   
      DbSelectArea("T_C9")

      T_C9->( dbSkip() )
   
   Enddo

   T_C9->( dbCloseArea() )
   RestArea( _aAreaSC9 )
   RestArea( _aAreaSC6 )
   RestArea( _aAreaSC5 )
   RestArea( _aAreaIni )

   // ################################################
   // Preenchimento dos dados para venda com cartão ##
   // ################################################
   If xCodStatus == "A"   
   
      IF _lEhCartao
   
         Reclock("SC5",.f.)
         SC5->C5_ADM     := xAdministra
         SC5->C5_BAND    := xBandeira
         SC5->C5_CARTAO  := xDigito
         SC5->C5_AUTORIZ := xAutorizacao
         SC5->C5_TID  := xTID
         SC5->C5_DOC  := xDocumento
         SC5->C5_DATCART := Ctod(Substr(xDtransacao,07,02) + "/" + Substr(xDtransacao,05,02) + "/" + Substr(xDtransacao,01,04))
         SC5->C5_ZVALCRT := Val(xValorCartao)
         MsUnlock()
      Endif

      // ################################################################
      // Grava o número da análise do Serasa se informado no parâmetro ##
      // ################################################################
      If Empty(Alltrim(xNrSerasa))
      Else 
         Reclock("SC5",.f.)
         SC5->C5_ZSER := xNrSerasa
         MsUnlock()
      Endif   

      Conout("000 - Pedido de Venda com Analise de Credito Liberado com sucesso")      
      cString := "000 - Pedido de Venda com Analise de Credito Liberado com sucesso"
      ::SetContentType("text/plain")
      ::SetResponse(cString)     
      RESET ENVIRONMENT
      Return(.T.)
      
   Else

      Conout("000 - Pedido de Venda com Analise de Credito Rejeitado com sucesso")      
      cString := "000 - Pedido de Venda com Analise de Credito Rejeitado com sucesso"
      ::SetContentType("text/plain")
      ::SetResponse(cString)     
      RESET ENVIRONMENT
      Return(.T.)

   Endif

   RESET ENVIRONMENT
   
Return(.T.)

// ############################################################################
// Função que seta a Empresa e Filial conforme parâmetros recebidos pela URL ##
// ############################################################################
Static Function TALTEMPFIL(K_Empresa, k_Filial)

   Local cEmp := k_Empresa
   Local cFil := k_Filial
   
   dbcloseall()
   cempant := cEmp
   cfilant := cFil 
   cNumEmp := cEmp  + cFil
   Opensm0(cempant  + cfil)
   Openfile(cempant + cfil)
   lrefresh :=.T.
          
Return

// #####################################################################
// Função que grava o ststus do itens do pedido em análise de crédito ##
// #####################################################################
Static Function xGravaSts( cOrig )

   Local _cFlagSts   := ""
   Local _cOrigem    := Iif( cOrig == Nil .Or. Empty( cOrig ), "XGRAVASTS", cOrig )
   Local _nRecC9     := 0
   Local _nRecC5     := 0
   Local _Transporte := ""
   Local _lCont      := .t.   //Flag Continuacao do processo
   Local _lTipoN     := .F.
   Local kRisco      := Posicione("SA1",1,xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI, "A1_RISCO")
   Local cQuery      := ""

   // ##################################
   // Garanto o posicionamento no SC9 ##
   // ##################################
   cQuery := ""
   cQuery := "SELECT R_E_C_N_O_ "
   cQuery += "  FROM " + RetSqlName("SC9") 
   cQuery += " WHERE C9_PEDIDO  = '" + Alltrim(SC6->C6_NUM)    + "' "
   cQuery += "   AND C9_ITEM    = '" + Alltrim(SC6->C6_ITEM)   + "' "
   cQuery += "   AND C9_FILIAL  = '" + Alltrim(SC6->C6_FILIAL) + "' "
   cQuery += "   AND D_E_L_E_T_ = ' '"

   dbUseArea( .T., "TOPCONN", TCGenQry( ,,cQuery ), "SC9REC", .F., .T. )

   // ###########################
   // Guardo o registro do SC9 ##
   // ###########################
   _nRecC9 := SC9REC->R_E_C_N_O_
   SC9REC->( dbCloseArea() )
   dbSelectArea("SC9")
   dbGoTo( _nRecC9 )

   // ##################################
   // Garanto o posicionamento no SC5 ##
   // ##################################
   dbSelectArea("SC5")
   dbSetOrder(1)
   dbSeek( xFilial("SC5") + SC9->C9_PEDIDO )

   // #########################################################################################################################################
   // Foi colocado aqui a carga desta variável pois quando função chamada pela análise de crédito, a variável lTipoN não estava inicializada ##
   // Esta variável foi criada pelo Jean da Solutio                                                                                          ##
   // #########################################################################################################################################
   _lTipoN := SC5->C5_TIPO == "N"

   // ###########################
   // Guardo o registro do SC5 ##
   // ###########################
   _nRecC5 := SC5->( Recno() )
   _Transporte := SC5->C5_TRANSP

   // ##############################
   // Avalia se item é de serviço ##
   // ##############################
   _lServ := xServico()

   // ##################################
   // Avalia se item atualiza estoque ##
   // ##################################
   _aAreaX := GetArea()
   _lStok := xAtuEstok()
   RestArea( _aAreaX )

   // ################################
   // Avalia se item está em compra ##
   // ################################
   _aAreaSC6 := SC6->( GetArea() )
   _aCompra := U_Compra()
   _lCompra := _aCompra[ 1 ]
   _lOkComp := _aCompra[ 2 ]
   RestArea( _aAreaSC6 )

   // ##################################
   // Avalia se item está em produção ##
   // ##################################
   _aAreaSC6 := SC6->( GetArea() )
   _aProduz := U_Produz()
   _lProduz := _aProduz[ 1 ]
   _lOkProd := _aProduz[ 2 ]
   RestArea( _aAreaSC6 )

   // #####################
   // Reposiciono no SC9 ##
   // #####################
   dbSelectArea("SC9")
   dbGoTo( _nRecC9 )
   
   // #####################
   // Reposiciono no SC5 ##
   // #####################
   dbSelectArea("SC5")
   dbGoTo( _nRecC5 )

   dbSelectArea("SC6")

   // ###############################
   // Tratamento de Exceçoes       ##
   // 001 - PCP - Exclusao de OP´s ##
   // ###############################
   IF ALLTRIM(_cOrigem) == "PE_MA650DC6"
      IF !empty(SC6->C6_NOTA)
        // ############################################################################
        // Excluindo uma OP de um PV que ja foi faturado, nao precisa mudar o Status ##
        // ############################################################################
       _lCont := .f.
     ENDIF
   ENDIF

   IF _lCont
     
      // ###############################################
      // Avalia se o pedido é Externo (intermediação) ##
      // ###############################################
     _lPExt := SC5->C5_EXTERNO == "1"

     If SC6->C6_BLQ == "R" .And. SC6->C6_STATUS != "14"
       _cFlagSts := "14" // Pedido Cancelado
      
     ElseIf _lPExt // Pedido Externo (intermediação)
      
       _cNfFor := SC5->C5_NFDISTR // Busco conteudo do campo Nota Fiscal do Fornecedor
      
       If Empty( _cNfFor ) .And. !( SC6->C6_STATUS $ "11,12,13,14" )
         _cFlagSts := "13" // Aguardando distribuidor
         
       ElseIf !Empty( _cNfFor ) .And. !( SC6->C6_STATUS $ "10,11,12,13,14" )
         RecLock("SC9",.F.)
         SC9->C9_BLEST := "  " // Libero o estoque para faturar o pedido externo
         MsUnLock()
         _cFlagSts := "10" // Aguardando faturamento
         
       EndIf

   ElseIf !_lStok .And. !_lServ // Não atualiza estoque (apenas remessas, serviço é tratado logo mais abaixo)
      If SC6->C6_STATUS != "10"
         _cFlagSts := "10" // Aguardando faturamento
      EndIf
      
    ElseIf !( SC9->C9_BLCRED $ "  10" ) .And. SC6->C6_STATUS != "03" .And. _lTipoN // Bloqueado por crédito
        _cFlagSts := "03" // Bloqueio de crédito
      
    ElseIf SC6->C6_ENTREG > ( dDataBase + 1 ) .And. !( SC6->C6_STATUS $ "05,07,11,12,13,14" ) .And. _lTipoN
      _cFlagSts := "05" // Aguardando programação de entrega

        // ######################################################################################################################
        // Observação: Foi incçuído no dia 05/04/2017 por Harald 0 Status 07 no if acima. Esta alteração foi acompanhada       ##
        // juntamente com o Sr. Fernando na mesma data. O Status do pedido de venda não pode ser alterado para 05 - Aguardando ##
        // Data de Entrega neste momento. Este Status somente poderá ser utilizado no encerramento da OP.                      ##
        // ######################################################################################################################
      
   ElseIf _lServ
      RecLock("SC9",.F.)
      
      SC9->C9_BLEST := "  " // Sempre libero o estoque quando for serviço
      
      // ######################################################################################################################
      // Em razão da implantação da nota fiscal de serviço eletrônica em 27/02/2015, esta variável não deve mais ser         ##
      // preenchida com o conteúdo SRV. Esta determinação foi aprovada via e-mail recebido da Contratoladoria em 27/02/2015. ##
      // SC9->C9_AGREG := "SRV" //Comentado Michel Aoki - Não haverá mais quebra da nota em serviço e produto.               ##
      // ######################################################################################################################
      SC9->C9_AGREG := ""
      
      MsUnLock()
      If SC6->C6_STATUS != "10"
         _cFlagSts := "10" // Aguardando faturamento
      EndIf
      
   ElseIf _lCompra .And. SC6->C6_STATUS != "06" // Tem pedido de compra e ainda não foi recebido
      _cFlagSts := "06" // Em compra
      
   ElseIf _lProduz .And. SC6->C6_STATUS != "07" // Tem amarração com ordem de produção
      _cFlagSts := "07" // Em produção
      
   ElseIf SC9->C9_BLEST $ "0203" // Bloqueado por estoque
      
        // If (cEmpAnt == "01" .And. SC9->C9_FILIAL == "04") .Or. ;
        //    (cEmpAnt == "01" .And. SC9->C9_FILIAL == "07") .Or. ;
        //    (cEmpAnt == "03" .And. SC9->C9_FILIAL == "01")

        If (LEFT(SC6->C6_PRODUTO,2) == "02" .Or. LEFT(SC6->C6_PRODUTO,2) == "03")
        Else
         If SC9->C9_BLEST == "02"
            RecLock("SC9",.F.)
           SC9->C9_BLEST := "03" // Sempre libero o estoque no padrão, mas bloqueio no status se não tiver saldo
           MsUnLock()
         EndIf
      Endif   
      
        // ##########################################
      // Verifico se existe saldo para o produto ##
      // ##########################################
      _aAreaSC6 := SC6->( GetArea() )
      _lSaldo := xSaldoB2( SC6->C6_PRODUTO, SC6->C6_QTDVEN, SC6->C6_LOCAL )
      RestArea( _aAreaSC6 )
      
        // #####################
      // Reposiciono no SC9 ##
      // #####################
      dbSelectArea("SC9")
      dbGoTo( _nRecC9 )
      
        // #####################
      // Reposiciono no SC5 ##
      // #####################
      dbSelectArea("SC5")
      dbGoTo( _nRecC5 )
      
      dbSelectArea("SC6")
      
      If !_lServ .And. !_lOkComp .And. !_lOkProd .And. !_lSaldo // Não é servico, nao existe PC nem OP e nao tem saldo disponivel (SB2)
         If SC6->C6_STATUS != "04"
            _cFlagSts := "04" // Bloqueio de estoque
         EndIf
      Else
         If !( SC6->C6_STATUS $ "08,11,12,13,14" ) .And. !_lServ .And. !_lCompra .And. !_lProduz
            _cFlagSts := "08" // Aguardando separacao
         EndIf
      EndIf
      
   ElseIf SC6->C6_TEMDOC == "S"// .Or. SC6->C6_LACRE == "S" // Jean Rehermann - 16/07/2012 - Validar se está aguardando o cliente
      If SC6->C6_STATUS != "09"  // Aguardando Documentação cliente
         _cFlagSts := "09"
      End If
      
   ElseIf !( SC6->C6_STATUS $ "08,09,11,12,13,14" ) .And. !_lServ .And. SC5->C5_TIPO != "B"
            _cFlagSts := "08" // Aguardando separacao
      
   ElseIf SC6->C6_STATUS == "09" // Jean Rehermann - 17/07/2012 - Se chegou até aqui é porque ou vai separar ou vai faturar
      If SC6->C6_TEMDOC != "S"// .And. SC6->C6_LACRE != "S"
         If SC5->C5_JPCSEP == "T" // Verifico se já foi separado
            _cFlagSts := "10" // Aguardando Faturamento
         Else
            _cFlagSts := "08" // Aguardando separacao
         EndIf
      EndIf
      
   ElseIf AllTrim( FunName() ) == "MATA410" .Or. SC5->C5_TIPO != "B"
        // ################################################################################################################################
      // Jean - Alterado em 03-09-12 - Quando for emitida a nf diretamente da rotina de PV (MATA410) Prep. Docs., e quando tipo PV = B ##
      // ################################################################################################################################
      _cFlagSts := "10" // Aguardando Faturamento
   EndIf

   If !Empty( _cFlagSts )
      
      RecLock( "SC6", .F. )
      SC6->C6_STATUS := _cFlagSts //Gravo o novo status do item
      MsUnlock()
      
        // #####################################################
      // Gravo o log de atualização de status na tabela ZZ0 ##
      // #####################################################
      U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, _cFlagSts, _cOrigem, 0 )
      
        // ################################
      // Atualiza a hora na tabela SC9 ##
      // ################################
      dbSelectArea("SC9")
      dbGoTo( _nRecC9 )
      RecLock("SC9",.F.)
      SC9->C9_HORA   := Time()
      SC9->C9_TRANSP := _Transporte
        SC9->C9_CODPG  := SC5->C5_CONDPAG
      MsUnLock()
      
        // ##############################################################################################################################
        // Verifica se o pedido de venda é um pedido de Locação. Se for, neste ponto dispara a inclusão do contrato do pedido de venda ##
        // ##############################################################################################################################
        U_AUTOM626(SC6->C6_FILIAL, SC6->C6_NUM)

   EndIf
   
  Endif

Return

// ##################################################
// Função que verifica se o item lido é de serviço ##
// ##################################################
Static Function xServico()

   Local _lRet  := .F.

   _lRet := AllTrim( SC6->C6_CF ) $ "5933|6933"

Return( _lRet )

// #############################################################
// Função que verifica se o item lido possui saldo disponível ##
// #############################################################
Static Function xSaldoB2( cProd, nQtd, cLoc )

   Local _aAreaSB2 := SB2->( GetArea() )
   Local _nSld     := 0
   Local _nSadPV   := 0
   Local _lRet     := .F.

   dbSelectArea("SB2")
   dbSetOrder(1)
   If dbSeek( xFilial("SB2") + cProd + cLoc )  // Jean Rehermann - 21/08/2014 - Nesta data adicionei o parâmetro cLoc para considerar o LOCAL no seek no SB2
     
     // #########################################
      // Pesquisa o saldo disponível do produto ##
      // #########################################
     _nSld := SaldoSB2()
   
      // ################################
      // Quantidade em Pedido de Venda ##
      // ################################
//    _nSldPV := SB2->B2_QPEDVEN

//    _lRet := (_nSld - _nSldPV) >= ( nQtd )

      _lRet := (_nSld) >= ( nQtd )

   EndIf

   RestArea( _aAreaSB2 )

Return _lRet

// ############################################################
// Função que verifica se TES do item lido Comntrola Estoque ##
// ############################################################
Static Function xAtuEstok()

   Local _aAreaSF4 := SF4->( GetArea() )

   DbSelectArea("SF4")
   DbSetOrder(1)
   DbSeek( xFilial("SF4") + SC6->C6_TES )

   _lRet := SF4->F4_ESTOQUE == "S" // .And. ( Posicione("SC5", 1, SC6->C6_FILIAL + SC6->C6_NUM, "C5_TIPO") != "B" )

   RestArea( _aAreaSF4 )

Return _lRet