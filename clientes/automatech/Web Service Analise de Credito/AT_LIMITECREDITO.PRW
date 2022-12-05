#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"

// ##################################################################################XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                                                              ##
// ---------------------------------------------------------------------------------------------------------------------------------- ##
// Referencia: AT_LIMITECREDITO.PRW                                                                                                   ##
// Parâmetros: Nenhum                                                                                                                 ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                                                                        ##
// ---------------------------------------------------------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                                                                ##
// Data......: 18/05/2018                                                                                                             ##
// Objetivo..: Web Service que atualiza o Limite de Crédito do Cliente                                                                ##
// Parâmetros: Vide relação abaixo                                                                                                    ##
// Chamada...: http://172.30.2.164:8099/rest/AT_LIMITECREDITO?cCodCliente=000329&cCodLoja=001&cLimite=15000.00&cVencimento=20180518   ##
// #####################################################################################################################################

WSRESTFUL AT_LIMITECREDITO DESCRIPTION "Advpl Tools - Service Limite de Credito Clientes"

    WSDATA cCodCliente AS STRING // Código do Cliente
    WSDATA cCodLoja    AS STRING // Loja do Cliente
    WSDATA cLimite     AS STRING // Valor do Limite de Crédito do Cliente
    WSDATA cVencimento AS STRING // Data de Vencimento do Limite de Crédito

	WSMETHOD GET DESCRIPTION "Advpl Tools - Service Limite de Credito Clientes" WSSYNTAX "/AT_LIMITECREDITO || /AT_LIMITECREDITO/{cCodCliente}{cCodLoja}{cLimite}{cVencimento}  "

END WSRESTFUL

WSMETHOD GET WSRECEIVE cCodCliente, cCodLoja, cLimite, cVencimento WSSERVICE AT_LIMITECREDITO

   Local xCodCliente   := Space(06)
   Local xCodLoja      := Space(03)
   Local xLimite       := 0
   Local xDvencimento  := Space(08)
   Local xData         := Ctod("  /  /    ")
   Local cString       := ""

   Private lMsErroAuto := .F. 
   Private lMsHelpAuto := .F. 

   xCodCliente   := Self:cCodCliente
   xCodLoja      := Self:cCodLoja
   xLimite       := Self:cLimite
   xDvencimento  := Self:cVencimento
   xData         := Ctod(Substr(xDvencimento,07,02) + "/" + Substr(xDvencimento,05,02) + "/" + Substr(xDvencimento,01,04))
   cString       := ""

   Conout("=================================================")
   Conout("==        Parametros recebidos pela URL        ==")
   Conout("=================================================")
   Conout("Codigo do Cliente.......: " + xCodCliente)
   Conout("Codigo da Loja Cliente..: " + xCodLoja)
   Conout("Valor Limite de Credito.: " + xLimite)
   Conout("Data vencto. L.Credito..: " + xDvencimento)
   Conout("=================================================")

   xLimite       := Val(xLimite)

   // ###############################################################################
   // Seta o código da Empresa conforme parâmetro para inclusão do pedido de venda ##
   // ###############################################################################
    
    RPCClearEnv()
    RPCSetType(3)
    RPCSetEnv(cEmpAnt,cFilant)
   
   //PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL cFilant USER 'Administrador' PASSWORD '@tech15021' TABLES "SFM", "SC5","SC6","SA1","SA2","SB1","SB2","SF4" MODULO 'FAT'

   // ##################################################################################################
   // Gera a consistências dos dados recebidos antes da gravação do novo limite de crédito do cliente ##
   // ##################################################################################################

   // ###################################################################################################
   // Tabela de retornos do Web Service - Limite de Crédito                                            ##
   // ###################################################################################################
   // 000 - Limite de Crédito do Cliente alterado com sucesso                                          ##
   // 001 - Código do Cliente não informado                                                            ##
   // 002 - Código da Loja do Cliente não informada                                                    ##
   // 003 - Data de Vencimento do Limite de Crédito não informaa                                       ##
   // 004 - Cliente não localizado no cadastro de clientes                                             ##
   // ###################################################################################################

   // ###############################
   // Consiste o código do Cliente ##
   // ###############################
   If Empty(Alltrim(xCodCliente))
      Conout("001 - Codigo do Cliente não informado")      
      cString := "001 - Código do Cliente não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      //RESET ENVIRONMENT
      Return(.T.)
   Endif

   // #######################################
   // Consiste o código da Loja do Cliente ##
   // #######################################
   If Empty(Alltrim(xCodLoja))
      Conout("002 - Codigo da Loja do Cliente não informada")      
      cString := "002 - Código da Loja do Cliente não informada"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      //RESET ENVIRONMENT
      Return(.T.)
   Endif

   // #####################################################
   // Consiste a data de vencimento do limite de crédito ##
   // #####################################################
   If xData = Ctod("  /  /    ")
      Conout("003 - Data de vencimento do limite de credito nao informada")
      cString := "003 - Data de vencimento do limite de crédito não informada"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      //RESET ENVIRONMENT
      Return(.T.)
   Endif

   // #############################################################################
   // Consiste se o cliente está cadastrado na tabela SA1 - Cadastro de Clientes ##
   // #############################################################################
   DbSelectArea("SA1")
   DbSetOrder(1)
   If DbSeek( xFilial("SA1") + xCodCliente + xCodLoja )
   Else 
      Conout("004 - Cliente/Loja nao localizado no cadastro de Clientes")
      cString := "004 - Cliente/Loja não localizado no cadastro de Clientes"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      //RESET ENVIRONMENT
      Return(.T.)
   Endif

   // ###########################################
   // Atualiza os dados no cadastro do cliente ##
   // ###########################################
   DbSelectArea("SA1")
   DbSetOrder(1)
   If DbSeek( xFilial("SA1") + xCodCliente + xCodLoja )
      Reclock("SA1",.F.)           
      SA1->A1_LC      := xLimite
      SA1->A1_VENCLC  := xData
  	  MsUnlock()
   Endif
   
   // ###############################################################
   // Retorno que conseguiu alterar o limite de crédito do cliente ##
   // ###############################################################
   Conout("000 - Limite de Credito do Cliente alterado com sucesso")
   cString := "000 - Limite de Crédito do Cliente alterado com sucesso"
   ::SetContentType("text/plain")
   ::SetResponse(cString)  	
   //RESET ENVIRONMENT

Return(.T.)




/*















   Local cSql       := ""
   Local cRetorno   := ""
   Local cString    := ""
   Local xControle  := ""
   Local _aCabec    := {}
   Local _aItens    := {}
   Local _aItem     := {}
   Local aLinha     := {}
   Local nX         := 0
   Local nY         := 0
   Local cDoc       := ""
   Local lOk        := .T.
   Local nContar    := 0
   Local nVezes     := 0
   Local xCodEmp    := Self:cCodEmp
   Local xCodFil    := Self:cCodFil
   Local xTipPed    := Self:cTipPed
   Local xCGCCli    := ""
   Local xDadosCli  := Self:cDadosCli
   Local xDadosCon  := Self:cDadosCon
   Local xCodCon    := Self:cCodCon
   Local xTipFre    := Self:cTipFre
   Local xValFre    := Self:cValFre
   Local xCodTra    := Self:cCodTra
   Local xCodVen1   := Self:cCodVen1
   Local xCodVen2   := Self:cCodVen2
   Local xCodMoe    := Self:cCodMoe
   Local xForExt    := Self:cForExt
   Local xLojExt    := Self:cLojExt
   Local xCodPro    := Self:cCodPro
   Local xQtdPro    := Self:cQtdPro
   Local xPrcPro    := Self:cPrcPro
   Local xTotPro    := Self:cTotPro
   Local xIsento    := Self:cIsento
   Local xContrib   := Self:cContrib
   Local xProposta  := Self:cProposta
   Local xObsNota   := Self:cObsNota
   Local xObsInte   := Self:cObsInte
   Local xObsDanf   := Self:cObsDanf
   Local xIDContato := Space(06)
   Local xComis1    := 0
   Local xComis2    := 0
   Local xQtdExata  := Self:cQtdExata
   Local xTipoSrv   := Self:cTipoSrv
   Local xNomeSrv   := ""
   Local xTipoOpe   := Self:cTipoOpe
                
   Private lMsErroAuto := .F. 
   Private lMsHelpAuto := .F. 

   // #############################
   // Carrega a variável xCGCCli ##
   // #############################
   If Len(Self:cCGCCLI) == 18
      xCGCCli := Substr(Self:cCGCCLI,01,02) + Substr(Self:cCGCCLI,04,03) + Substr(Self:cCGCCLI,08,03) + Substr(Self:cCGCCLI,12,04) + Substr(Self:cCGCCLI,17,02)
   Else
      xCGCCli := Substr(Self:cCGCCLI,01,03) + Substr(Self:cCGCCLI,05,03) + Substr(Self:cCGCCLI,09,03) + Substr(Self:cCGCCLI,13,02)
   Endif

   Conout("=================================================")
   Conout("==        Parametros recebidos pela URL        ==")
   Conout("=================================================")
   Conout("Codigo da empresa......: " + xCodEmp)
   Conout("Codigo da filial.......: " + xCodFil)
   Conout("Tipo de Pedido.........: " + xTipPed)
   Conout("CNPJ/CPF...............: " + xCGCCli)
   Conout("Dados do Cliente.......: " + xDadosCli)
   Conout("Dados do Contato.......: " + xDadosCon)
   Conout("Condicao de Pagamento..: " + xCodCon)
   Conout("Tipo de Frete..........: " + xTipFre)
   Conout("Valor do Frete.........: " + xValFre)
   Conout("Transportadora.........: " + xCodTra)
   Conout("Vendedor 1.............: " + xCodVen1)
   Conout("Vendedor 2.............: " + xCodVen2)
   Conout("Moeda xCodMoe..........: " + xCodMoe)
   Conout("Distribuidor...........: " + xForExt)
   Conout("Loja Distribuidor......: " + xLojExt)
   Conout("Codigo Produtos........: " + xCodPro)
   Conout("Quantidade Produtos....: " + xQtdPro)
   Conout("Preco Unitario Produtos: " + xPrcPro)
   Conout("Total dos Produtos.....: " + xTotPro)
   Conout("Insc.Estadual Isenta...: " + xIsento)
   Conout("Contribuinte...........: " + xContrib)
   Conout("Proposta Comercial.....: " + xProposta)
   Conout("Obs. Para NF...........: " + xObsNota)
   Conout("Obs. Interna...........: " + xObsInte)
   Conout("Obs. Danfe.............: " + xObsDanf)      
   Conout("Qtd Exata..............: " + xQtdExata)      
   Conout("Tipo de Servico........: " + xTipoSrv)      
   Conout("Tipo de Operacao.......: " + xTipoOpe)      

   // ###############################################################################
   // Seta o código da Empresa conforme parâmetro para inclusão do pedido de venda ##
   // ###############################################################################
   PREPARE ENVIRONMENT EMPRESA xCodEmp FILIAL xCodFil USER 'Administrador' PASSWORD '@tech15010' TABLES "SFM", "SC5","SC6","SA1","SA2","SB1","SB2","SF4" MODULO 'FAT'

   ALTEMPFIL(xCodEmp, xCodFil)

   // ################################################################################
   // Gera a consistências dos dados recebidos antes da inclusão do Pedido de Venda ##
   // ################################################################################

   // ###################################################################################################
   // Tabela de retornos do Web Service Pedido de Venda Protheus                                       ##      
   // ###################################################################################################
   // 000 - Inclusão de pedido de venda com sucesso                                                    ##
   // 001 - Código da Empresa não informada                                                            ##
   // 002 - Código da Filial não informada                                                             ##
   // 003 - Tipo de Pedido de Venda não informado                                                      ##
   // 004 - CNPJ/CPF do Cliente não informado                                                          ##
   // 005 - Condição de Pagamento não informada                                                        ##
   // 006 - Disponível                                                                                 ##
   // 007 - Tipo de frete não informado                                                                ##
   // 008 - Valor do Frete                                                                             ##
   // 009 - Transportadora                                                                             ##
   // 010 - Código vendedor 1 não informado                                                            ##
   // 011 - Código da moeda não informada                                                              ##
   // 011 - Código do fornecedor externo não informado                                                 ##
   // 012 - Código da loja do fornecedor externo não informada                                         ##
   // 013 - Código(s) do(s) produto(s) do pedido de venda não informado(s)                             ##
   // 014 - Informação do(s) código(s) do(s) produto(s) inconsistênte (Sem informação do |)            ##
   // 015 - Código(s) do(s) produto(s) do pedido de venda não informado(s)                             ##
   // 016 - Informação da(s) quantidade(s) do(s) produto(s) inconsistênte (Sem informação do |)        ##
   // 017 - Preço(s) unitário(s) do(s) produto(s) não informado(s)                                     ##
   // 018 - Informação do(s) preço(s) unitário(s) do(s) produto(s) inconsistênte (Sem informação do |) ##
   // 019 - Valor Total do(s) produto(s) não informado(s)                                              ##
   // 020 - Informação do(s) total(is) do(s) produto(s) inconsistênte (Sem informação do |)            ##
   // 021 - Disponível                                                                                 ##
   // 022 - Disponível                                                                                 ##
   // 023 - Conteúdo do tipo de pedido de venda é inválido (Aceitos 1 ou 2)                            ##
   // 024 - Dados Cadastrais do Cliente                                                                ##
   // 025 - Nome do cliente não informado                                                              ##
   // 026 - Endereço do cliente nãoo informado                                                         ##
   // 027 - UF do cliente não informado                                                                ##
   // 028 - Bairro do cliente não informado                                                            ##
   // 029 - Município do cliente não informado                                                         ##
   // 030 - CEP do endereço do cliente não informado                                                   ##
   // 031 - DDD do telefone do cliente não informado                                                   ##
   // 032 - Telefone do cliente não informado                                                          ##
   // 033 - Inscrição Estadual do cliente não informada                                                ##
   // 034 - E-mail do cliente não informado                                                            ##
   // 035 - Contato do cliente não informado                                                           ##
   // 036 - Indicação de IE Isenta não informada                                                       ##
   // 037 - Informação do campo IE Isenta inconsistente (Aceitos somenete 0 ou 1)                      ##
   // 038 - Cliente contribuinte não informado                                                         ##   
   // 039 - Informação do campo Cliente Contribuinte inconsistente (Aceitos somenete 0 ou 1)           ##
   // 040 - Disponível                                                                                 ##
   // 041 - Disponível                                                                                 ##
   // 042 - Erro ao gravar pedido de venda                                                             ##
   // 043 - Nº da proposta comercial não informada                                                     ##
   // 044 - Cliente inexistente no Protheus                                                            ##
   // 045 - Informação da(s) moeda(s) inconsistênte (Sem informação do |)                              ##
   // 046 - Vendedor 1 não cadastrado                                                                  ##
   // 047 - Vendedor 2 não cadastrado                                                                  ##
   // 048 - Dados Cadastrais do cliente (Parâmetros aguardados não recebidos)                          ##
   // 049 - Dados de Contato não recebidos                                                             ##
   // 050 - Nome do Contato não recebido                                                               ##
   // 051 - E-mail do Contato não recebido                                                             ## 
   // 052 - DDD do telefone do contato não recebido                                                    ##
   // 053 - Nº do telefone do contato não recebido                                                     ##
   // 054 - Produtos de Suprimentos e Serviços devem estar em pedidos separados.                       ##
   // 055 - Produtos não são produtos de Suprimentos.                                                  ##
   // 056 - Condição de Pagamento não localizada no cadastro (SE4)                                     ##
   // 057 - Quantidade exata não informada (S/N)                                                       ##
   // 058 - Se Quantidade Exata diferente de S/N                                                       ## 
   // 059 - Código IBGE do Município não localizado                                                    ## 
   // 060 - Tipo de Serviço em caso de transportadora = Correios (000008)                              ## 
   // 061 - Tipo de Serviço inválido. Aceitos (0, 1 - Correios 40068-PAC, 2 - Correios 40436-SEDEX)    ##
   // 062 - Tipo de Operação não informado                                                             ##
   // 063 - Tipo de Operação inávalido. Aceitos (02, 03 ou 35)                                         ##
   // 064 - Tipo de Operação somente permitido para pedidos de agenciamento                            ##
   // 065 - Tipo de operação inválido para pedidos de agenciamento                                     ##
   // 066 - Esta operação não pode ser selecionada para este cliente. Utilize Operação 03              ##
   // 067 - Esta operação não pode ser selecionada para este cliente. Utilize Operação 02              ##
   // ###################################################################################################

   // #############################
   // Consiste código da Empresa ##
   // #############################
   If Empty(Alltrim(xCodEmp))
      Conout("001 - Codigo da Empresa não informada")      
      cString := "001 - Código da Empresa não informada"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
      Return(.T.)
   Endif

   // ############################
   // Consiste código da Filial ##
   // ############################
   If Empty(Alltrim(xCodFil))
      Conout("002 - Código da Filial não informada")
      cString := "002 - Código da Filial não informada"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
      Return(.T.)
   Endif

   // #####################################
   // Consiste o tipo de pedido de venda ##
   // #####################################
   If Empty(Alltrim(xTipPed))
      Conout("003 - Tipo de Pedido de Venda não informado")
      cString := "003 - Tipo de Pedido de Venda não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
       
      Return(.T.)
   Endif

   // #################################################
   // Consiste o conteúdo do tipo de pedido de venda ##
   // #################################################
   If Alltrim(xTipPed) <> "1" .And. Alltrim(xTipPed) <> "2"
      Conout("023 - Conteúdo do tipo de pedido de venda é inválido (Aceitos 1 ou 2)")
      cString := "023 - Conteúdo do tipo de pedido de venda é inválido (Aceitos 1 ou 2)"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
       
      Return(.T.)
   Endif   

   // ###############################
   // Consiste CNPJ/CPF do cliente ##
   // ###############################
   If Empty(Alltrim(xCGCCli))
      Conout("004 - CNPJ/CPF do Cliente não informado")
      cString := "004 - CNPJ/CPF do Cliente não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
       
      Return(.T.)
   Endif

   // ###################################
   // Consiste a Condição de Pagamento ##
   // ###################################
   If Empty(Alltrim(xCodCon))
      Conout("005 - Condição de Pagamento não informada")
      cString := "005 - Condição de Pagamento não informada"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
       
      Return(.T.)
   Endif

   // #######################################################
   // Consiste dados do Contato do Cliente/Pedido de Venda ##
   // #######################################################
   If Empty(Alltrim(xDadosCon))
      Conout("049 - Dados de Contato do Pedido de Venda não informados")
      cString := "049 - Dados de Contato do Pedido de Venda não informados"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
       
      Return(.T.)
   Endif

   // #############################################
   // Separa os dados de contato para utilização ##
   // #############################################
   kNomeCon := U_P_CORTA(xDadosCon,"|",01)
   kEmaiCon := U_P_CORTA(xDadosCon,"|",02)
   kNDDDCon := U_P_CORTA(xDadosCon,"|",03)
   kTel1Con := U_P_CORTA(xDadosCon,"|",04)
   kTel2Con := U_P_CORTA(xDadosCon,"|",05)   

   // ############################
   // Consistem nome do contato ##
   // ############################
   If Empty(Alltrim(kNomeCon))
      Conout("050 - Nome do Contato não informado")
      cString := "050 - Nome do Contato não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
       
      Return(.T.)
   Endif

   // ##############################
   // Consistem e-mail do contato ##
   // ##############################
   If Empty(Alltrim(kEmaiCon))
      Conout("051 - E-mail do Contato não informado")
      cString := "051 - E-mail do Contato não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
       
      Return(.T.)
   Endif

   // #######################################
   // Consistem DDD do telefone do contato ##
   // #######################################
   If Empty(Alltrim(kNDDDCon))
      Conout("052 - DDD do telefone do Contato não informado")
      cString := "052 - DDD do telefone do Contato não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
       
      Return(.T.)
   Endif

   // #######################################
   // Consistem DDD do telefone do contato ##
   // #######################################
   If Empty(Alltrim(kTel1Con))
      Conout("053 - Telefone do Contato não informado")
      cString := "053 - Telefone do Contato não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
       
      Return(.T.)
   Endif

   // #######################################
   // Consiste a Administradora de Cartões ##
   // #######################################
   // If U_P_OCCURS(Upper(xCodCon), "CARTAO", 1) <> 0
   //    If Empty(Alltrim(xCodAdm))
   //       Conout("Administradora de Cartoes...........: " + xCodAdm)
   //       cString := "006 - Administradora de Cartões não informada"
   //       ::SetContentType("text/plain")
   //       ::SetResponse(cString)  	
   //       RESET ENVIRONMENT
   //        
   //       Return(.T.)
   //    Endif
   // Endif

   // ###########################
   // Consiste o Tipo de Frete ##
   // ###########################
   If Empty(Alltrim(xTipFre))
      Conout("007 - Tipo de frete não informado")
      cString := "007 - Tipo de frete não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
       
      Return(.T.)
   Endif

   // ############################
   // Consiste o Valor do frete ##
   // ############################
   // If Empty(Alltrim(xValFre))
   //    Conout("Valor do Frete...........: " + xValFre)
   //    cString := "008 - Valor do Frete não informado"
   //    ::SetContentType("text/plain")
   //    ::SetResponse(cString)  	
   //    RESET ENVIRONMENT
   //     
   //    Return(.T.)
   // Endif

   // ############################
   // Consiste a Transportadora ##
   // ############################
   // If Empty(Alltrim(xCodTra))
   //    Conout("Transportadora...........: " + xCodTra)
   //    cString := "009 - Transportadora não informada"
   //    ::SetContentType("text/plain")
   //    ::SetResponse(cString)  	
   //    RESET ENVIRONMENT
   //     
   //    Return(.T.)
   // Endif

   // ###################################
   // Consiste o Campo Tipo de Serviço ##
   // ###################################
   If xTipoSrv$("0#1#2")
      Do Case
         Case xTipoSrv == "0"
              nNomeSrv := ""
         Case xTipoSrv == "1"
              nNomeSrv := "CORREIOS 41068-PAC"
         Case xTipoSrv == "2"
              nNomeSrv := "CORREIOS 40436-SEDEX"
      EndCase        
   Else
      Conout("Tipo de Serviço..........: " + xTipoSrv)
      cString := "061 - Tipo de Serviço com informação incorreta, Aceitos 0,1 ou 2"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
      Return(.T.)
   Endif
     
   // #######################################
   // Consiste o tipo de Operação de Venda ##
   // #######################################
   If Empty(Alltrim(xTipoOpe))
      Conout("Tipo de Operacao.........: " + xTipoOpe)
      cString := "062 - Tipo de Operação não informado."
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
      Return(.T.)
   Endif
      
   // ##########################################################
   // Verifica se os tipos de operação informados são válidos ##
   // ##########################################################
   lTipoOpe := .T.

   For nContar = 1 to U_P_OCCURS(xTipoOpe, "|", 1)
   
       If U_P_CORTA(xTipoOpe, "|", nContar)$("02#03#35")
       Else
          lTipoOpe := .F.
          Exit
       Endif
   Next nContar    
          

   If lTipoOpe == .T.
   Else
      Conout("Tipo de Operacao........: " + xTipoOpe)
      cString := "063 - Tipo de Operação informado inválido. Aceitos 02, 03 ou 35"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
      Return(.T.)
   Endif

   // ###########################################################################
   // Verifica se o Tipo de Operação está correto pelo tipo de pedido de venda ##
   // ###########################################################################
   If xTipoOpe == "35" .And. xTipPed <> "1"
      Conout("Tipo de Operacao........: " + xTipoOpe)
      cString := "064 - Tipo de Operação somente permitido para pedidos de agenciamento."
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
      Return(.T.)
   Endif

   If xTipoOpe <> "35" .And. xTipPed == "1"
      Conout("Tipo de Operacao........: " + xTipoOpe)
      cString := "065 - Tipo de operação inválido para pedidos de agenciamento."
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
      Return(.T.)
   Endif

   // ############################################################################
   // Consiste o |Tipo de Serviço em caso de Transportadora = 000008 = Correios ##

   // ############################################################################
   If Empty(Alltrim(xCodTra))
   Else
      If xCodTra == "000008"
         If xTipoSrv$("1#2")
            Do Case
               Case xTipoSrv == "0"
                    nNomeSrv := ""
               Case xTipoSrv == "1"
                    nNomeSrv := "CORREIOS 41068-PAC"
               Case xTipoSrv == "2"
                    nNomeSrv := "CORREIOS 40436-SEDEX"
            EndCase        
         Else
            Conout("Tipo de Serviço..........: " + xTipoSrv)
            cString := "061 - Tipo de Serviço com informação incorreta, Aceitos 1 ou 2"
            ::SetContentType("text/plain")
            ::SetResponse(cString)  	
            RESET ENVIRONMENT
            Return(.T.)
         Endif   
      Endif   
   Endif

   // ################################
   // Consiste o código do Vendedor ##
   // ################################
   If Empty(Alltrim(xCodVen1))
      Conout("010 - Código vendedor 1 não informado")
      cString := "010 - Código vendedor 1 não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
       
      Return(.T.)
   Else
   
      // ##################################
      // Verifica se o vendedor é válido ##
      // ##################################
      If Select("T_VENDEDOR") > 0
         T_VENDEDOR->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A3_COD ,"
      cSql += "       A3_NOME " 
      cSql += "  FROM " + RetSqlName("SA3") + " (Nolock) "
      cSql += " WHERE A3_COD     = '" + Alltrim(xCodVen1) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

      If T_VENDEDOR->( EOF() )
         Conout("046 - Vendedor 1 não cadastrado")
         cString := "046 - Vendedor 1 não cadastrado"
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         RESET ENVIRONMENT
          
         Return(.T.)
      Endif
   
   Endif

   // #############################
   // Consiste o código da moeda ##
   // #############################
   If Int(Val(xCodMoe)) == 0
      Conout("011 - Código da moeda não informada")
      cString := "011 - Código da moeda não informada"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
       
      Return(.T.)
   Endif

   If Empty(Alltrim(xCodMoe))
      Conout("011 - Moeda não informada")
      cString := "011 - Moeda não informada"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
       
      Return(.T.)
   Else
      If U_P_OCCURS(xCodMoe, "|", 1) == 0
         Conout("045 - Informação da(s) moeda(s) inconsistênte (Sem informação do |)")
         cString := "045 - Informação da(s) moeda(s) inconsistênte (Sem informação do |)"
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         RESET ENVIRONMENT
          
         Return(.T.)
      Endif
   Endif

   // ###################################################################
   // Consiste o código e loja do fornecedor em caso de pedido externo ##
   // ###################################################################
   If Alltrim(xTipPed) == "1"

      If Empty(Alltrim(xForExt))
         Conout("011 - Código do fornecedor externo não informado")
         cString := "011 - Código do fornecedor externo não informado"
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         RESET ENVIRONMENT
          
         Return(.T.)
      Endif

      If Empty(Alltrim(xLojExt))
         Conout("012 - Código da loja do fornecedor externo não informada")
         cString := "012 - Código da loja do fornecedor externo não informada"
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         RESET ENVIRONMENT
          
         Return(.T.)
      Endif

   Endif

   // ####################################
   // Consiste o campo Quantidade Exata ##
   // ####################################
   If Empty(Alltrim(xQtdExata))
      Conout("057 - Informação da Quantidade Exata não informada.")
      cString := "057 - Informação da Quantidade Exata não informada."
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
       
      Return(.T.)                      
   Endif
   
   If xQtdExata$("N#S")
   Else
      Conout("058 - Informação da Quantidade Exata é inconsistente. Aceitos somente S ou N.")
      cString := "058 - Informação da Quantidade Exata é inconsistente. Aceitos somente S ou N."
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
       
      Return(.T.)                      
   Endif

   // #################################
   // Consiste o código dos produtos ##
   // #################################
   If Empty(Alltrim(xCodPro))
      Conout("013 - Código(s) do(s) produto(s) do pedido de venda não informado(s)")
      cString := "013 - Código(s) do(s) produto(s) do pedido de venda não informado(s)"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
       
      Return(.T.)
   Else
      If U_P_OCCURS(xCodPro, "|", 1) == 0
         Conout("014 - Informação do(s) código(s) do(s) produto(s) inconsistênte (Sem informação do #)")
         cString := "014 - Informação do(s) código(s) do(s) produto(s) inconsistênte (Sem informação do #)"
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         RESET ENVIRONMENT
          
         Return(.T.)
      Endif
   Endif

   // #####################################
   // Consiste a quantidade dos produtos ##
   // #####################################
   If Empty(Alltrim(xQtdPro))
      Conout("015 - Código(s) do(s) produto(s) do pedido de venda não informado(s)")
      cString := "015 - Código(s) do(s) produto(s) do pedido de venda não informado(s)"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
       
      Return(.T.)
   Else
      If U_P_OCCURS(xQtdPro, "|", 1) == 0
         Conout("Quantidade dos produtos sem |......: " + xQtdPro)
         cString := "016 - Informação da(s) quantidade(s) do(s) produto(s) inconsistênte (Sem informação do #)"
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         RESET ENVIRONMENT
          
         Return(.T.)
      Endif
   Endif      

   // #######################################
   // Consiste o preço unário dos produtos ##
   // #######################################
   If Empty(Alltrim(xPrcPro))
      Conout("017 - Preço(s) unitário(s) do(s) produto(s) não informado(s)")
      cString := "017 - Preço(s) unitário(s) do(s) produto(s) não informado(s)"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
       
      Return(.T.)
   Else
      If U_P_OCCURS(xPrcPro, "|", 1) == 0
         Conout("Preco unitario dos produtos sem |......: " + xPrcPro)
         cString := "018 - Informação do(s) preço(s) unitário(s) do(s) produto(s) inconsistênte (Sem informação do #)"
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         RESET ENVIRONMENT
          
         Return(.T.)
      Endif
   Endif      

   // ######################################
   // Consiste o valor total dos produtos ##
   // ######################################
   If Empty(Alltrim(xTotPro))
      Conout("019 - Valor Total do(s) produto(s) não informado(s)")
      cString := "019 - Valor Total do(s) produto(s) não informado(s)"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
       
      Return(.T.)
   Else
      If U_P_OCCURS(xTotPro, "|", 1) == 0
         Conout("020 - Informação do(s) total(is) do(s) produto(s) inconsistênte (Sem informação do #)")
         cString := "020 - Informação do(s) total(is) do(s) produto(s) inconsistênte (Sem informação do #)"
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         RESET ENVIRONMENT
          
         Return(.T.)
      Endif
   Endif      

   // ##################################################
   // Consiste o percentual de comissão do vendedor 1 ##
   // ##################################################
   //If !Empty(Alltrim(xCodVen1))
   //   If Empty(Alltrim(xComis1))
   //      Conout("021 - Percentual de comissão para o vendedor 1 não informada")
   //      cString := "021 - Percentual de comissão para o vendedor 1 não informada"
   //      ::SetContentType("text/plain")
   //      ::SetResponse(cString)  	
   //      RESET ENVIRONMENT
   //       
   //      Return(.T.)
   //   Endif
   //Endif   

   // ##################################################
   // Consiste o percentual de comissão do vendedor 2 ##
   // ##################################################
   If !Empty(Alltrim(xCodVen2))

      // ##################################
      // Verifica se o vendedor é válido ##
      // ##################################
      If Select("T_VENDEDOR") > 0
         T_VENDEDOR->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A3_COD ,"
      cSql += "       A3_NOME " 
      cSql += "  FROM " + RetSqlName("SA3") + " (Nolock) "
      cSql += " WHERE A3_COD     = '" + Alltrim(xCodVen2) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

      If T_VENDEDOR->( EOF() )
         Conout("047 - Vendedor 2 não cadastrado")
         cString := "047 - Vendedor 2 não cadastrado"
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         RESET ENVIRONMENT
          
         Return(.T.)
      Endif

      // #####################################################
      // Verifica se a comissão do vendedor 2 foi informada ##
      // #####################################################
      //If Empty(Alltrim(xComis2))
      //   Conout("022 - Percentual de comissão para o vendedor 2 não informada")
      //   cString := "022 - Percentual de comissão para o vendedor 2 não informada"
      //   ::SetContentType("text/plain")
      //   ::SetResponse(cString)  	
      //   RESET ENVIRONMENT
      //    
      //   Return(.T.)
      //Endif
   Endif   

   // #############################
   // Consiste o campo IE Isento ##
   // #############################
   If Empty(Alltrim(xIsento))
      Conout("036 - Indicação de IE Isenta não informada")
      cString := "036 - Indicação de IE Isenta não informada"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
       
      Return(.T.)
   Endif

   If Alltrim(xIsento) <> "0" .And. Alltrim(xIsento) <> "1"
      Conout("037 - Informação do campo IE Isenta inconsistente (Aceitos somenete 0 ou 1)")
      cString := "037 - Informação do campo IE Isenta inconsistente (Aceitos somenete 0 ou 1)"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
       
      Return(.T.)
   Endif

   // ################################
   // Consiste o campo Contribuinte ##
   // ################################
   If Empty(Alltrim(xContrib))
      Conout("038 - Cliente contribuinte não informado")
      cString := "038 - Cliente contribuinte não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
       
      Return(.T.)
   Endif

   If Alltrim(xContrib) <> "0" .And. Alltrim(xContrib) <> "1"
      Conout("039 - Informação do campo Cliente Contribuinte inconsistente (Aceitos somenete 0 ou 1)")
      cString := "039 - Informação do campo Cliente Contribuinte inconsistente (Aceitos somenete 0 ou 1)"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
       
      Return(.T.)
   Endif

   // ######################################
   // Consiste o campo forma de pagamento ##
   // ######################################
   //   If Empty(Alltrim(xFormaPG))
   //      Conout("040 - Campo forma de pagamento não informado")
   //      cString := "040 - Campo forma de pagamento não informado"
   //      ::SetContentType("text/plain")
   //      ::SetResponse(cString)  	
   //      RESET ENVIRONMENT
   //       
   //      Return(.T.)
   //   Endif

   //   If Empty(Alltrim(xFormaPG))
   //      Conout("Forma de Pagamento somente 1 ou 2......: " + xFormaPG)
   //      cString := "041 - Informação do campo forma de pagamento inconsistente (Aceitos somenete 1 ou 2)"
   //      ::SetContentType("text/plain")
   //      ::SetResponse(cString)  	
   //      RESET ENVIRONMENT
   //       
   //      Return(.T.)
   //   Else   
   //      //If xFormaPG$("1#2")
   //      If U_P_OCCURS(Upper(xCodCon), "CARTAO", 1) == 0      
   //         xFormaPG := "1"
   //         xCodAdm  := "  "
   //      Else
   //         xFormaPG := "2"
   //         xCodAdm  := "02"
   //      Endif   
   //   Endif

   // #######################################################################
   // Consiste o nº da proposta comercial de vínculo com o pedido de venda ##
   // #######################################################################
   If Empty(Alltrim(xProposta))
      Conout("043 - Nº da proposta comercial SM não informada")
      cString := "043 - Nº da proposta comercial SM não informada"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
       
      Return(.T.)
   Endif

   // #####################################
   // Se o cliente não existir, o inclui ##
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

      // ########################################################################################
      // Ativar linhas abaixo em caso de ser retirado a inclusão de clientes por este processo ##
      // ------------------------------------------------------------------------------------- ##
      //      Conout("044 - Cliente informado inexistente no Protheus")                        ##
      //      cString := "044 - Cliente informado inexistente no Protheus"                     ##
      //      ::SetContentType("text/plain")                                                   ##
      //      ::SetResponse(cString)  	                                                       ##
      //      RESET ENVIRONMENT                                                                ##
      //       
      //      Return(.T.)                                                                      ##
      // ########################################################################################

      // #################################################
      // Vefifica se os dados do cliente foram enviados ##
      // #################################################
      If Empty(Alltrim(xDadosCli))
         
         // ###############################################################
         // Verifica se os dados do cliente foram enviados para inclusão ##
         // ###############################################################
         If Empty(Alltrim(xDadosCli))
            Conout("024 - Dados Cadastrais do Cliente não informados.")
            cString := "024 - Dados Cadastrais do Cliente para inclusão não informados."
            ::SetContentType("text/plain")
            ::SetResponse(cString)  	
            RESET ENVIRONMENT 
             
            Return(.T.)
         Endif

         // ################################################################################
         // Verifica a quantidade de parâmetros recebidos nos dados cadastrais do cliente ##
         // ################################################################################
         If U_P_OCCURS(xDadosCli, "|", 1) <> 13
            Conout("048 - Dados Cadastrais do Cliente (Parâmetros aguardados não recebidos.)")
            cString := "048 - Dados Cadastrais do Cliente (Parâmetros aguardados não recebidos.)"
            ::SetContentType("text/plain")
            ::SetResponse(cString)  	
            RESET ENVIRONMENT 
             
            Return(.T.)
         Endif
         
      Endif   

      // ########################################################
      // Separa os campos do cliente para validação e inclusão ##
      // ########################################################
      kNome      := UPPER(U_P_CORTA(xDadosCli,"|",01))
      kEndereco  := UPPER(U_P_CORTA(xDadosCli,"|",02))
      kEstado    := UPPER(U_P_CORTA(xDadosCli,"|",03))
      kBairro    := UPPER(U_P_CORTA(xDadosCli,"|",04))
      kCidade    := UPPER(U_P_CORTA(xDadosCli,"|",05))
      kCep       := UPPER(U_P_CORTA(xDadosCli,"|",06))
      kDDD       := UPPER(U_P_CORTA(xDadosCli,"|",07))
      kTelefone  := UPPER(U_P_CORTA(xDadosCli,"|",08))
      kInscricao := UPPER(U_P_CORTA(xDadosCli,"|",09))
      kEmail     := UPPER(U_P_CORTA(xDadosCli,"|",10))
      kContato   := UPPER(U_P_CORTA(xDadosCli,"|",11))
      kIsenta    := UPPER(U_P_CORTA(xDadosCli,"|",12))
      kContribui := UPPER(U_P_CORTA(xDadosCli,"|",13))

      // ############################################
      // Verifica se nome do cliente foi informado ##
      // ############################################
      If Empty(Alltrim(kNome))
         Conout("025 - Nome do Cliente inexistente.")
         cString := "025 - Nome do Cliente inexistente."
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         RESET ENVIRONMENT 
          
         Return(.T.)
      Endif

      // ################################################
      // Verifica se endereço do cliente foi informado ##
      // ################################################
      If Empty(Alltrim(kEndereco))
         Conout("026 - Endereço do Cliente inexistente.")
         cString := "026 - Endereço do Cliente inexistente."
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         RESET ENVIRONMENT 
          
         Return(.T.)
      Endif

      // ##########################################
      // Verifica se UF do cliente foi informado ##
      // ##########################################
      If Empty(Alltrim(kEstado))
         Conout("027 - Estado do Cliente inexistente.")
         cString := "027 - Estado do Cliente inexistente."
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         RESET ENVIRONMENT 
          
         Return(.T.)
      Endif

      // ##############################################
      // Verifica se Bairro do cliente foi informado ##
      // ##############################################
      If Empty(Alltrim(kBairro))
         Conout("028 - Bairro do Cliente inexistente.")
         cString := "028 - Bairro do Cliente inexistente."
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         RESET ENVIRONMENT 
          
         Return(.T.)
      Endif

      // #################################################
      // Verifica se Município do cliente foi informado ##
      // #################################################
      If Empty(Alltrim(kCidade))
         Conout("029 - Município do Cliente inexistente.")
         cString := "029 - Município do Cliente inexistente."
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         RESET ENVIRONMENT 
         Return(.T.)
      Endif

      // ################################################################
      // Verifica se o código do município está cadastrado no Protheus ##
      // ################################################################
      If Select("T_IBGE") > 0
         T_IBGE->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT CC2_CODMUN"
      cSql += "  FROM " + RetSqlName("CC2")
      cSql += " WHERE CC2_EST    = '" + Alltrim(kEstado) + "'"
      cSql += "   AND CC2_MUN    = '" + Alltrim(kCidade) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_IBGE", .T., .T. )

      If T_IBGE->( EOF() )
         Conout("059 - Código IBGE do Município não localizado.")
         cString := "059 - Código IBGE do Município não localizado."
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         RESET ENVIRONMENT 
      Endif

      // ###############################
      // CEP do cliente foi informado ##
      // ###############################
      If Empty(Alltrim(kCEP))
         Conout("030 - CEP do Cliente inexistente.")
         cString := "030 - CEP do Cliente inexistente."
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         RESET ENVIRONMENT 
          
         Return(.T.)
      Endif

      // ###############################
      // DDD do cliente foi informado ##
      // ###############################
      If Empty(Alltrim(kDDD))
         Conout("031 - DDD do Cliente inexistente.")
         cString := "031 - DDD do Cliente inexistente."
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         RESET ENVIRONMENT 
          
         Return(.T.)
      Endif

      // ####################################
      // Telefone do cliente foi informado ##
      // ####################################
      If Empty(Alltrim(kTelefone))
         Conout("032 - Telefone do Cliente inexistente.")
         cString := "032 - Telefone do Cliente inexistente."
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         RESET ENVIRONMENT 
          
         Return(.T.)
      Endif

      // ###############################
      // IE  do cliente foi informado ##
      // ###############################
      If Empty(Alltrim(kInscricao))
         Conout("033 - IE do Cliente inexistente.")
         cString := "033 - IE do Cliente inexistente."
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         RESET ENVIRONMENT 
          
         Return(.T.)
      Endif

      // ##################################
      // E-mail do cliente foi informado ##
      // ##################################
      If Empty(Alltrim(kInscricao))
         Conout("034 - E-mail do Cliente inexistente.")
         cString := "034 - E-mail do Cliente inexistente."
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         RESET ENVIRONMENT 
          
         Return(.T.)
      Endif

      // ###################################
      // Contato do cliente foi informado ##
      // ###################################
      If Empty(Alltrim(kContato))
         Conout("035 - Contato do Cliente inexistente.")
         cString := "035 - Contato do Cliente inexistente."
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         RESET ENVIRONMENT 
          
         Return(.T.)
      Endif

      // #########################
      // Indicação de IE Isenta ##
      // #########################
      If Empty(Alltrim(kIsenta))
         Conout("036 - Indicação de IE Isenta não informada")
         cString := "036 - Indicação de IE Isenta não informada"
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         RESET ENVIRONMENT 
          
         Return(.T.)
      Else
         If Alltrim(kIsenta)$("0#1")
         Else
            Conout("037 - Informação do campo IE Isenta inconsistente (Aceitos somenete 0 ou 1)")
            cString := "037 - Informação do campo IE Isenta inconsistente (Aceitos somenete 0 ou 1)"
            ::SetContentType("text/plain")
            ::SetResponse(cString)  	
            RESET ENVIRONMENT 
             
            Return(.T.)
         Endif   
      Endif

      // #########################
      // Indicação Contribuinte ##
      // #########################
      If Empty(Alltrim(kContribui))
         Conout("038 - Cliente contribuinte não informado")
         cString := "038 - Cliente contribuinte não informado"
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         RESET ENVIRONMENT 
          
         Return(.T.)
      Else
         If Alltrim(kIsenta)$("0#1")
         Else
            Conout("039 - Informação do campo Cliente Contribuinte inconsistente (Aceitos somenete 0 ou 1)")
            cString := "039 - Informação do campo Cliente Contribuinte inconsistente (Aceitos somenete 0 ou 1)"
            ::SetContentType("text/plain")
            ::SetResponse(cString)  	
            RESET ENVIRONMENT 
             
            Return(.T.)
         Endif   
      Endif

      // ##############################################
      // Realiza a inclusão do cliente na tabela SA1 ##
      // ##############################################
      
      // ###############################################################
      // Prepara o próximo código de cliente disponível para inclusão ##
      // ###############################################################
      If Select("T_PROXIMO") > 0
         T_PROXIMO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A1_COD ,"
      cSql += "       A1_LOJA,"
      cSql += "       A1_NOME,"
      cSql += "       A1_CGC  "
      cSql += "  FROM " + RetSqlName("SA1")
      cSql += " WHERE D_E_L_E_T_ = ''"
      cSql += " ORDER BY A1_COD DESC "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

      If T_PROXIMO->( EOF() )
         nProximoCod := "000001"
      Else
         nProximoCod := STRZERO((INT(VAL(T_PROXIMO->A1_COD)) + 1),6)
      Endif

      // ########################################################################
      // Verifica se o raiz do CNPJ já está cadastrado no Cadastro de Clientes ##
      // ########################################################################
      If Select("T_RAIZ") > 0
         T_RAIZ->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A1_COD ,"
      cSql += "       A1_LOJA,"
      cSql += "       A1_NOME,"
      cSql += "       A1_CGC  "
      cSql += "  FROM " + RetSqlName("SA1")
      
      If Len(xCGCCLI) == 14
         cSql += " WHERE SUBSTRING(A1_CGC,1,8) = '" + Substr(xCGCCLI,1,8) + "'"
      Else
         cSql += " WHERE A1_CGC = '" + Alltrim(xCGCCLI) + "'"
      Endif            
         
      cSql += "   AND D_E_L_E_T_ = ''"     
      cSql += " ORDER BY A1_COD, A1_LOJA DESC"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RAIZ", .T., .T. )
       
      If T_RAIZ->( EOF() )
         kCodigo     := nProximoCod
         kLoja       := "001"
         lNovo       := .T.
      Else       
         kCodigo := T_RAIZ->A1_COD
         kLoja   := Strzero((INT(VAL(T_RAIZ->A1_LOJA)) + 1),3)
         lNovo       := .F.
      Endif

      // ####################################################################
      // Pesquisa o código e nome do município na Tabela CC2 - Código IBGE ##
      // ####################################################################
      If Select("T_IBGE") > 0
         T_IBGE->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT CC2_CODMUN"
      cSql += "  FROM " + RetSqlName("CC2")
      cSql += " WHERE CC2_EST    = '" + Alltrim(kEstado) + "'"
      cSql += "   AND CC2_MUN    = '" + Alltrim(kCidade) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_IBGE", .T., .T. )

      If T_IBGE->( EOF() )
         cMunicipio := ""
      Else
         cMunicipio := T_IBGE->CC2_CODMUN
      Endif

         Conout("KISENTA:" + kIsenta)

      // ########################
      // Inclui o novo cliente ##
      // ########################
      DbSelectArea("SA1")
      RecLock("SA1",.T.)
      SA1->A1_FILIAL  := ""
      SA1->A1_COD     := kCodigo
      SA1->A1_LOJA    := kLoja
      SA1->A1_PESSOA  := IIF(Len(Alltrim(xCGCCLI)) == 14, "J", "F")
      SA1->A1_NOME    := kNome
      SA1->A1_NREDUZ  := kNome
      SA1->A1_END     := kEndereco
      SA1->A1_TIPO    := "F"
      SA1->A1_EST     := kEstado
      SA1->A1_COD_MUN := cMunicipio
      SA1->A1_MUN     := kCidade
      SA1->A1_BAIRRO  := kBairro
      SA1->A1_CEP     := kCep
      SA1->A1_DDD     := kDDD
      SA1->A1_TEL     := kTelefone
      SA1->A1_CGC     := xCGCCLI
      SA1->A1_INSCR   := kInscricao
      SA1->A1_PAIS    := "105"
      SA1->A1_CODPAIS := "01058"
      SA1->A1_EMAIL   := kEmail
      SA1->A1_NATUREZ := "10101"
      SA1->A1_GRPTRIB := IIF(kIsenta == "0", "003", "002")
      SA1->A1_RISCO   := "E"
      SA1->A1_CONTRIB := IIF(kContribui == "0", "2", "1")
      SA1->A1_VEND    := cCodVen1
      SA1->A1_ZVEND2  := cCodVen2
      SA1->A1_ZCOMP   := "N"
      Msunlock()

      cCodigo := kCodigo
      cLoja   := kLoja

      _Juridico := IIF(Len(Alltrim(xCGCCli)) == 14, "S", "N")

   Else

      cCodigo := T_CLIENTE->A1_COD
      cLoja   := T_CLIENTE->A1_LOJA

      // ##########################################################################
      // Verifica se o cliente é jurídico ou físico para pesquisa do novo código ##
      // ##########################################################################
      _Juridico := IIF(Len(Alltrim(xCGCCli)) == 14, "S", "N")

   Endif

   // ##########################################################################################
   // Verifica se o contato do cliente já está cadastrado. Verificação pelo e-mail do contato ##
   // ##########################################################################################
   If Select("T_CONTATO") > 0
      T_CONTATO->( dbCloseArea() )
   EndIf

   cSql := "SELECT U5_CODCONT,"                                    	
   cSql += "       U5_CONTAT ,"
   cSql += "       U5_DDD    ,"
   cSql += "       U5_FONE   ,"
   cSql += "       U5_FCOM1  ," 
   cSql += "       U5_EMAIL   "
   cSql += "     FROM " + RetSqlName("SU5")
   cSql += "    WHERE UPPER(U5_EMAIL) = '" + Upper(Alltrim(kEmaiCon)) + "'"
   cSql += "       AND U5_NIVEL   = '07'"
   cSql += "       AND D_E_L_E_T_ = ''  "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTATO", .T., .T. )

   If T_CONTATO->( EOF() )
   
      // #######################################
      // Inclui o Contato de Venda - Nível 07 ##
      // #######################################
      Cod_Cnt_VDA := NEWNUMCONT()

      xIDContato  := Cod_Cnt_VDA

      DbSelectArea("SU5")
      RecLock("SU5",.T.)
      SU5->U5_FILIAL  := ""
      SU5->U5_CODCONT := Cod_Cnt_VDA
      SU5->U5_CONTAT  := kNomeCon
      SU5->U5_DDD     := kNDDDCon
      SU5->U5_FONE    := kTel1Con
      SU5->U5_FCOM1   := kTel2Con
      SU5->U5_EMAIL   := kEmaiCon
      SU5->U5_NIVEL   := "07"
      SU5->U5_ATIVO   := "1"
      SU5->U5_STATUS  := "2"
      SU5->U5_TIPO    := "2"
      Msunlock()

      // #######################################
      // Cadastra o Vínculo Contato X Cliente ##
      // #######################################
      DbSelectArea("AC8")
      RecLock("AC8",.T.)
      AC8->AC8_FILIAL := ""
      AC8->AC8_FILENT := ""       
      AC8->AC8_ENTIDA := "SA1"
      AC8->AC8_CODENT := cCodigo + cLoja
      AC8->AC8_CODCON := Cod_Cnt_VDA
      Msunlock()

      // ##########################################
      // Inclui o Contato de Cobranca - Nível 08 ##
      // ##########################################
      Cod_Cnt_COB := NEWNUMCONT()

      DbSelectArea("SU5")
      RecLock("SU5",.T.)
      SU5->U5_FILIAL  := ""
      SU5->U5_CODCONT := Cod_Cnt_COB
      SU5->U5_CONTAT  := kNomeCon
      SU5->U5_DDD     := kNDDDCon
      SU5->U5_FONE    := KTel1Con
      SU5->U5_FCOM1   := KTel2Con
      SU5->U5_EMAIL   := kEmaiCon
      SU5->U5_NIVEL   := "08"      
      SU5->U5_ATIVO   := "1"
      SU5->U5_STATUS  := "2"
      SU5->U5_TIPO    := "3"
      Msunlock()

      // #######################################
      // Cadastra o Vínculo Contato X Cliente ##
      // #######################################
      DbSelectArea("AC8")
      RecLock("AC8",.T.)
      AC8->AC8_FILIAL := ""
      AC8->AC8_FILENT := ""       
      AC8->AC8_ENTIDA := "SA1"
      AC8->AC8_CODENT := cCodigo + cLoja
      AC8->AC8_CODCON := Cod_Cnt_COB
      Msunlock()
      
   Else      

      xIDContato := T_CONTATO->U5_CODCONT

      cSql := ""
      cSql := "UPDATE " + RetSqlName("SU5")
      cSql += "  SET U5_CONTAT  = '" + Alltrim(kNomeCon)   + "', "
      cSql += "      U5_DDD     = '" + Alltrim(kNDDDCon)   + "', "
      cSql += "      U5_FONE    = '" + Alltrim(kTel1Con)   + "', "
      cSql += "      U5_FCOM1   = '" + Alltrim(kTel2Con)   + "', "
      cSql += "      U5_EMAIL   = '" + Alltrim(kEmaiCon)   + "'  "
      cSql += "WHERE U5_CODCONT = '" + Alltrim(xIDContato) + "'"
            
      _nErro := TcSqlExec(cSql) 

      If TCSQLExec(cSql) < 0 
         alert(TCSQLERROR())
         Return(.T.)
      Endif
   
      // ##################################################################################
      // Verifica se existe Contato Vinculado com a tabela AC8 para o contato pesquisado ##
      // ##################################################################################
      If Select("T_VINCULO") > 0
         T_VINCULO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT AC8_FILIAL,"
      cSql += "       AC8_FILENT," 
      cSql += "       AC8_ENTIDA,"
      cSql += "       AC8_CODENT,"
      cSql += "       AC8_CODCON "
      cSql += "  FROM " + RetSqlName("AC8")
      cSql += " WHERE AC8_CODENT = '" + cCodigo + cLoja + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VINCULO", .T., .T. )
                                                             
      If T_VINCULO->( EOF() )
      
         // #######################################
         // Cadastra o Vínculo Contato X Cliente ##
         // #######################################
         DbSelectArea("AC8")
         RecLock("AC8",.T.)
         AC8->AC8_FILIAL := ""
         AC8->AC8_FILENT := ""       
         AC8->AC8_ENTIDA := "SA1"
         AC8->AC8_CODENT := cCodigo + cLoja
         AC8->AC8_CODCON := xIDContato
         Msunlock()

         // ##########################################
         // Inclui o Contato de Cobranca - Nível 08 ##
         // ##########################################
         Cod_Cnt_COB := NEWNUMCONT()

         // #######################################
         // Cadastra o Vínculo Contato X Cliente ##
         // #######################################
         DbSelectArea("AC8")
         RecLock("AC8",.T.)
         AC8->AC8_FILIAL := ""
         AC8->AC8_FILENT := ""       
         AC8->AC8_ENTIDA := "SA1"
         AC8->AC8_CODENT := cCodigo + cLoja
         AC8->AC8_CODCON := Cod_Cnt_COB
         Msunlock()
         
      Endif   
      
   Endif

   // ###################################################################################################
   // Verifica se o tipo de Operação pode ser utilizada para o grupo tributário do cadastro do cliente ##
   // ###################################################################################################
   For nContar = 1 to U_P_OCCURS(xTipoOpe, "|", 1)
   
       If Alltrim(Posicione("SA1", 1, xFilial("SA1") + cCodigo + cLoja, "A1_GRPTRIB")) == "002" // IE ATIVO

          If Alltrim( U_P_CORTA(xTipoOpe, "|", nContar)) =="02" // Isento
             Conout("066 - Esta operação não pode ser selecionada para este cliente. Utilize Operação 03")
             cString := "066 - Esta operação não pode ser selecionada para este cliente. Utilize Operação 03"
             ::SetContentType("text/plain")
             ::SetResponse(cString)  	
             RESET ENVIRONMENT 
             Return(.T.)
          EndIf

       ElseIf Alltrim(Posicione("SA1", 1, xFilial("SA1") + cCodigo + cLoja, "A1_GRPTRIB")) == "003" // IE ISENTO

          If Alltrim( U_P_CORTA(xTipoOpe, "|", nContar)) =="03" // Isento
             Conout("067 - Esta operação não pode ser selecionada para este cliente. Utilize Operação 02")
             cString := "067 - Esta operação não pode ser selecionada para este cliente. Utilize Operação 02"
             ::SetContentType("text/plain")
             ::SetResponse(cString)  	
             RESET ENVIRONMENT 
             Return(.T.)
          EndIf
          
       EndIf
       
    Next nContar       

   // ###############################################################
   // Verifica se a proposta comercial já está incluída no Sistema ##
   // ###############################################################   
   //   If xCodGrv == "N"
   //
   //      If Select("T_JACADASTRADO") > 0
   //         T_JACADASTRADO->( dbCloseArea() )
   //      EndIf
   //
   //      cSql := ""
   //      cSql := "SELECT C5_FILIAL,"
   //      cSql += "       C5_NUM   ,"
   //	  cSql += "       C5_ZPNUV "
   //      cSql += "  FROM " + RetSqlName("SC5") + " (Nolock) "
   //      cSql += " WHERE C5_FILIAL  = '" + Alltrim(xCodFil)   + "'"
   //      cSql += "   AND C5_ZPNUV   = '" + Alltrim(xProposta) + "'"
   //      cSql += "   AND D_E_L_E_T_ = ''"
   //
   //      cSql := ChangeQuery( cSql )
   //      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JACADASTRADO", .T., .T. )
   //
   //      If !T_JACADASTRADO->( EOF() )
   //         Conout("999 - Proposta comercial já cadastrada no pedido de venda nr. " + Alltrim(T_JACADASTRADO->C5_NUM))
   //         cString := "999 - Proposta comercial já cadastrada no pedido de venda nr. " + Alltrim(T_JACADASTRADO->C5_NUM)
   //         ::SetContentType("text/plain")
   //         ::SetResponse(cString)  	
   //         RESET ENVIRONMENT 
   //         Return(.T.)
   //      Endif      
   //      
   //   Endif   

   // ########################################################################################################################
   // Verifica se existem produtos de Hardware junto com produtos de Suprimentos                                            ##
   // --------------------------------------------------------------------------------------------------------------------- ##
   // Regra de preenchimento do código do vendedor no pedido de venda                                                       ##
   // --------------------------------------------------------------------------------------------------------------------- ##
   // Se Empresa logada for 03 - Atech e Filial 01 ou Empresa 01 e Filial 04, aplica-se a seguinte regra                    ##
   // --------------------------------------------------------------------------------------------------------------------- ##
   // 1) Se pedido de venda tiver somente produtos de serviço, o vendedor será o vendedor Hardware do cadastro de clientes. ##
   // 2) Se pedido de venda tiver somente produtos de suprimentos (Grupo de 0200 ao 0299) o vendedor é do Suprimentos       ##
   // 3) Se no pedido de venda tiver produtos de suprimentos junto com produtos de serviço , sistema deverá dar um aviso    ##
   //    que o mesmos deverá ser desdobrado e não permitir a gravação do mesmo.                                             ##
   // Nova regra para venda compartilhada                                                                                   ##
   // Quando o cliente for um cliente com venda compartilhada, não se aplica a regra abaixo ou seja, o pedido de venda po-  ##
   // derá vender os produtos todos juntos.                                                                                 ##            
   // ########################################################################################################################
   If Posicione("SA1", 1, xFilial("SA1") + cCodigo + cLoja, "A1_ZCOMP") == "S"
   Else

      If (xCodEmp == "01" .And. xCodFil == "04") .Or. (xCodEmp == "03" .And. xCodFil == "01") .Or. (xCodEmp == "01" .And. xCodFil == "07")

         // ############################################################################
         // Verifica se todos os produtos do pedido de venda são produtos de serviços ##
         // ############################################################################
         nTotalProdutos := 0
         nTotalServicos := 0

         For nContar = 1 to U_P_OCCURS(xCodPro, "|", 1)

             yyProduto := Alltrim(U_P_CORTA(xCodPro,"|", nContar)) + Space(30 - Len(Alltrim(U_P_CORTA(xCodPro,"|", nContar))))

             If Alltrim(Posicione("SB1", 1, xFilial("SB1") + yyProduto, "B1_TIPO")) == "MO"
                nTotalServicos := nTotalServicos + 1
             Else
                nTotalProdutos := nTotalProdutos + 1
             Endif                   

         Next nContar

         // ##################################################################
         // Aplica a regra quando o pedido de venda somente possui serviços ##
         // ##################################################################
         If nTotalServicos <> 0 .And. nTotalProdutos == 0

            xCodVen1 := POSICIONE("SA1",1,XFILIAL("SA1") + cCodigo + cLoja, "A1_VEND")       
               
         Else

            If nTotalServicos <> 0 .And. nTotalProdutos <> 0          

               Conout("054 - Produtos de Suprimentos e Serviços devem estar em pedidos separados.")
               cString := "054 - Produtos de Suprimentos e Serviços devem estar em pedidos separados."
               ::SetContentType("text/plain")
               ::SetResponse(cString)  	
               RESET ENVIRONMENT
                
               Return(.T.)

            Else   
      
               // #############################################################################
               // Verifica se os produtos pertencem aos grupos de suprimentos (0200 ao 0299) ##
               // #############################################################################
               lTodosSuprimentos := .F.

               For nContar = 1 to U_P_OCCURS(xCodPro, "|", 1)
                                                                           
                   // ############################################
                   // Prepara o código do produto para pesquisa ##
                   // ############################################
                   yyProduto := Alltrim(U_P_CORTA(xCodPro,"|", nContar)) + Space(30 - Len(Alltrim(U_P_CORTA(xCodPro,"|", nContar))))

                   k_Grupo_Produto := Posicione("SB1", 1, xFilial("SB1") + yyProduto, "B1_GRUPO")

                   If (k_Grupo_Produto >= "0200" .And. k_Grupo_Produto <= "0299") .Or. (k_Grupo_Produto >= "0400")
                      lTodosSuprimentos := .T.                       
                   Else
                      lTodosSuprimentos := .F.                                              
                      Exit
                   Endif

               Next nContar

               // ####################################################################################################
               // Não permite venda de produtos que não sejam de suprimentos na Empresa 03 ou Empresa 01, Filial 04 ##
               // ####################################################################################################
               If lTodosSuprimentos == .F.
                  Conout("055 - Produtos não são produtos de Suprimentos.")
                  cString := "055 - Produtos não são produtos de Suprimentos."
                  ::SetContentType("text/plain")
                  ::SetResponse(cString)  	
                  RESET ENVIRONMENT
                   
                  Return(.T.)
               Endif

               // #############################################################################
               // Pesquisa o vendedor suprimentos para popular o vendedor do pedido de venda ##
               // #############################################################################
//             xCodVen2 := POSICIONE("SA1",1,XFILIAL("SA1") + cCodigo + cLoja, "A1_ZVEND2")

            Endif
          
         Endif
          
      Endif   

   Endif

   // ###########################
   // Inclui o Pedido de Venda ##
   // ###########################

   // #############################################
   // Pesquisa o código da condição de pagamento ##
   // #############################################
   If Select("T_CONDICAO") > 0
      T_CONDICAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT E4_CODIGO,"
   cSql += "       E4_DESCRI "
   cSql += "  FROM SE4010    "
   //cSql += " WHERE E4_DESCRI = '" + Alltrim(xCodCon) + "'"
   cSql += " WHERE E4_CODIGO  = '" + Alltrim(xCodCon) + "'"   
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONDICAO", .T., .T. )

   // ###################################
   // Consiste a Condição de Pagamento ##
   // ###################################
   If T_CONDICAO->( EOF() )
      Conout("056 - Condição de Pagamento inexistente")
      cString := "056 - Condição de Pagamento inexistente"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
       
      Return(.T.)
   Else
      nCodigoCond := IIF(T_CONDICAO->( EOF() ), "", T_CONDICAO->E4_CODIGO)
   Endif      

   // ######################################################################################################   
   // Verifica quantos pedidos de venda serão abertos conforme a quantidade de moeda enviada no parâmetro ##
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
   // Faz o laço de abertura dos pedidos de venda ##
   // ##############################################
   For nVezes = 1 to nNumeroPedido

       // ###############################################
       // Pesquisa o próximo código de pedido de venda ##
       // ###############################################
       cNumPed := GetSX8Num("SC5","C5_NUM")
       ConfirmSx8()
   
       Conout("=================================================")
       Conout("==        Cabeçalho do Pedido de Venda         ==")
       Conout("=================================================")
       Conout("Filial.........: " + xCodFil)
       Conout("Num Pedido.....: " + cNumPed)
       Conout("Proposta.......: " + xProposta)
       Conout("Tipo PV........: " + "N")
       Conout("Cliente........: " + cCodigo)
       Conout("Loja...........: " + cLoja)
       Conout("CL Entrega.....: " + cCodigo)
       Conout("Loja Entrega...: " + cLoja)
       Conout("TP Cliente.....: " + "F")
       Conout("Cond.Pagto.....: " + nCodigoCond)
       Conout("Nome Contato...: " + kNomeCon)
       Conout("Email Contato..: " + kEmaiCon)
       Conout("DDD Telefones..: " + kNDDDCon)
       Conout("Telefone 01....: " + kTel1Con)
       Conout("Telefone 02....: " + kTel2Con)
       Conout("ID Contato.....: " + xIDContato)
       Conout("Emissao........: " + Dtoc(dDatabase))
       Conout("Moeda..........: " + xCodMoe)
       Conout("Tipo de Pedido.: " + xTipPed)
       Conout("Cod.Vendedora 1: " + xCodVen1)
       Conout("Tipo Liberacao.: " + "1")
       Conout("Tipo de Frete..: " + xTipFre)
       Conout("Transportadora.: " + xCodTra)
       Conout("Valor do Frete.: " + xValFre)
       Conout("Cod.Vendedor 2 : " + xCodVen2)
       Conout("Distribuidor...: " + xForExt)
       Conout("Loja Dist. ....: " + xLojExt)
       Conout("Loja Dist. ....: " + xQtdExata)
       Conout("ID Contato.....: " + xIDContato)
       Conout("Tipo Serviço...: " + xTipoSrv)
       Conout("Tipo Operação..: " + xTipoOpe)       
       
       // ##########################################################
       // Cria array com os dados do cabeçalho do pedido de venda ##
       // ##########################################################
       aAdd(_aCabec,{"C5_FILIAL" , xCodFil          , Nil}) // Número do Pedido de Venda
       aAdd(_aCabec,{"C5_NUM"    , cNumPed          , Nil}) // Número do Pedido de Venda
       aAdd(_aCabec,{"C5_TIPO"   , "N"              , Nil}) // Tipo do Pedido de Venda
       aAdd(_aCabec,{"C5_CLIENTE", cCodigo          , Nil}) // Codigo do Cliente
       aAdd(_aCabec,{"C5_LOJACLI", cLoja            , Nil}) // Loja do Cliente
       aAdd(_aCabec,{"C5_CLIENT" , cCodigo          , Nil}) // Codigo do Cliente de Entrega
       aAdd(_aCabec,{"C5_LOJAENT", cLoja            , Nil}) // Loja do Cliente de Entrega
       aAdd(_aCabec,{"C5_CONDPAG", nCodigoCond      , Nil}) // Condição de Pagamento
       aAdd(_aCabec,{"C5_ZPNUV"  , xProposta        , Nil}) // Código da proposta do SaleMachine
       aAdd(_aCabec,{"C5_TIPOCLI", "F"              , Nil}) // Tipo do Cliente
       aAdd(_aCabec,{"C5_EMISSAO", dDatabase        , Nil}) // Data de Emissao
       aAdd(_aCabec,{"C5_MOEDA"  , nVezes           , Nil}) // Moeda
       aAdd(_aCabec,{"C5_EXTERNO", xTipPed          , Nil}) // Tipo de Pedido de Venda (Interno/Externo) Grava inicialmente 2 Não. Abaixo trata este campo

//     aAdd(_aCabec,{"C5_FORNEXT", xForExt          , Nil}) // Tipo de Pedido de Venda (Interno/Externo) Grava inicialmente 2 Não. Abaixo trata este campo
//     aAdd(_aCabec,{"C5_LOJAEXT", xLojExt          , Nil}) // Tipo de Pedido de Venda (Interno/Externo) Grava inicialmente 2 Não. Abaixo trata este campo
//     aAdd(_aCabec,{"C5_EXTERNO", "2"              , Nil}) // Tipo de Pedido de Venda (Interno/Externo) Grava inicialmente 2 Não. Abaixo trata este campo

       aAdd(_aCabec,{"C5_FORMA"  , "1"              , Nil}) // Forma de Pagamento
       aAdd(_aCabec,{"C5_VEND1"  , xCodVen1         , Nil}) // Código do Vendedor 1  
       aAdd(_aCabec,{"C5_TIPLIB" , "1"              , Nil}) // Tipo de Liberação do Pedido (1 = Por Item)
       aAdd(_aCabec,{"C5_TPFRETE", xTipFre          , Nil}) // Tipo do frete
       aAdd(_aCabec,{"C5_TABELA" , "500"            , Nil}) // Tabela de Preço
       aAdd(_aCabec,{"C5_ZCON"   , kNomeCon         , Nil}) // Nome do Contato
       aAdd(_aCabec,{"C5_ZEMA"   , kEmaiCon         , Nil}) // E-maildo Contato
       aAdd(_aCabec,{"C5_ZDD1"   , kNDDDCon         , Nil}) // DDD do Telefone do Contato
       aAdd(_aCabec,{"C5_ZTE1"   , kTel1Con         , Nil}) // Telefone 1 do Contato
       aAdd(_aCabec,{"C5_ZTE2"   , kTel2Con         , Nil}) // Telefone 2 do Contato
       aAdd(_aCabec,{"C5_ZIDC"   , xIDContato       , Nil}) // ID do Contato de Venda do Cliente
       aAdd(_aCabec,{"C5_QEXAT"  , xQtdExata        , Nil}) // Indica se Qtd do Pedido é exata ou não (S/N)
       aAdd(_aCabec,{"C5_OBSI"   , Alltrim(xObsInte), Nil}) // Observações Internas
       aAdd(_aCabec,{"C5_OBSNT"  , Alltrim(xObsDanf), Nil}) // Observações para DANFE
       aAdd(_aCabec,{"C5_MENNOTA", Alltrim(xObsNota), Nil}) // Observações para a Nota Fiscal

       // ###############################################################
       // Grava o código da transportadora se foi passado no parâmetro ##
       // ###############################################################
       If !Empty(Alltrim(xCodTra))
          aAdd(_aCabec,{"C5_TRANSP" , xCodTra          , Nil}) // Código da transportadora

          // #############################################################
          // Grava o nome do serviço quando transportadora for Correios ##
          // #############################################################
          If xCodTra == "000008"

             If xTipoSrv == "1"
                aAdd(_aCabec,{"C5_TSRV" , "CORREIOS 41068-PAC", Nil}) 
             Endif
             
             If xTipoSrv == "2"
                aAdd(_aCabec,{"C5_TSRV" , "CORREIOS 40436-SEDEX", Nil}) // Indica o tipo de serviço em caso de transportadora = 000008 (Correios)
             Endif
             
          Endif   

       Endif   

       aAdd(_aCabec,{"C5_FRETE"  , VAL(xValFre)     , Nil}) // Valor do frete

       // ####################################################################
       // Grava o tipo de serviço quando transportadora = 000008 (Correios) ##
       // ####################################################################
       If !Empty(Alltrim(xCodTra))
          If xCodTra == "000008"
             aAdd(_aCabec,{"C5_TSRV" , xNomeSrv          , Nil}) // Indica o tipo de serviço em caso de transportadora = 000008 (Correios)
          Endif   
       Endif   

       // ###########################################################
       // Grava o código do vendedor 2 se foi passado no parâmetro ##
       // ###########################################################
       If !Empty(Alltrim(xCodVen2))
          aAdd(_aCabec,{"C5_VEND2", xCodVen2 , Nil}) // Código do Vendedor 2  
       Endif
 
       Conout("=================================================")
       Conout("==        Itens do Pedido de Venda             ==")
       Conout("=================================================")

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
           
              yyProduto := Alltrim(U_P_CORTA(xCodPro ,"|", nContar)) + Space(30 - Len(Alltrim(U_P_CORTA(xCodPro,"|", nContar))))
              yyTipoOpe := Alltrim(U_P_CORTA(xTipoOpe,"|", nContar))

              Conout("Produto: " + yyProduto) 
              Conout("Cliente: " + cCodigo) 
              Conout("Loja...: " + cLoja)            
              Conout("Tipo Oper: " + yyTipoOpe)
              Conout("Cliente..: " + cCodigo)
              Conout("Loja.....: " + cLoja)               
              Conout("Produto..: " + yyProduto)

              kTES := MaTesInt(2, yyTipoOpe, cCodigo, cLoja, "C", yyProduto)

              Conout("TES..: " + kTES)


              // ######################################################################################################################
              // Linhas substituídas porque no dia 05/04/2018, o tipo de operação passou a ser um árâmetro na chamada do web service ##
              // ######################################################################################################################
              //              Do Case                                                                                                ##
              //                 Case _Juridico == "S" .And. xIsento == "0"                                                          ##
              //                      kTES := MaTesInt(2, "03", cCodigo, cLoja, "C", yyProduto)                                      ##
              //                                                                                                                     ##
              //                 Case _Juridico == "S" .And. xIsento == "1"                                                          ##
              //                      kTES := MaTesInt(2, "02", cCodigo, cLoja, "C", yyProduto)                                      ##
              //                                                                                                                     ##
              //                 Case _Juridico == "N"                                                                               ##
              //                      kTES := MaTesInt(2, "02", cCodigo, cLoja, "C", yyProduto)                                      ##
              //              EndCase                                                                                                ##
              // ######################################################################################################################

           Endif

           // ########################################################## 
           // Pesquisa a Situação Tributária do produto para gravação ##
           // ##########################################################
           yyProduto := Alltrim(U_P_CORTA(xCodPro,"|", nContar)) + Space(30 - Len(Alltrim(U_P_CORTA(xCodPro,"|", nContar))))
           xSituacao := Posicione( "SB1", 1, xFilial("SB1") + yyProduto, "B1_ORIGEM" ) + ;
                        Posicione( "SF4", 1, xFilial("SF4") + kTES     , "F4_SITTRIB")

           // ##########################################################
           // Pesquisa o código do produto pela leitura do ID enviado ##
           // ##########################################################
           If Select("T_PRODUTO") > 0
              T_PRODUTO->( dbCloseArea() )
           EndIf
           
           cSql := ""
           cSql := "SELECT B1_COD   ,"
           cSql += "       B1_DESC  ,"
           cSql += "       B1_GRUPO ,"
           cSql += "       B1_DESC  ,"
           cSql += "       B1_UM     "
           cSql += "  FROM " + RetSqlName("SB1") + " (Nolock) "
           cSql += " WHERE D_E_L_E_T_ = ''"
           cSql += "   AND B1_COD     = '" + Alltrim(U_P_CORTA(xCodPro,"|", nContar)) + "'"

           cSql := ChangeQuery( cSql )
           dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTO", .T., .T. )

           kk_Produto   := T_PRODUTO->B1_COD
           kk_Grupo     := T_PRODUTO->B1_GRUPO
           kk_Descricao := T_PRODUTO->B1_DESC
           kk_Unidade   := T_PRODUTO->B1_UM
    
           // ##########################################
           // Pesquisa o % de comissão dos vendedores ##
           // ##########################################
           kTipoVen1 := Posicione("SA3",1,xFilial("SA3") + xCodVen1       , "A3_TIPOV")
           kTipoVen2 := Posicione("SA3",1,xFilial("SA3") + xCodVen2       , "A3_TIPOV")
           kTipoComp := Posicione("SA1",1,xFilial("SA1") + cCodigo + cLoja, "A1_ZCOMP")
           kGerente  := Posicione("SBM",1,xFilial("SBM") + kk_Grupo       , "BM_COMIS")
           kExecut1  := Posicione("SBM",1,xFilial("SBM") + kk_Grupo       , "BM_COME1")
           kExecut2  := Posicione("SBM",1,xFilial("SBM") + kk_Grupo       , "BM_COME2")

           // ######################################################
           // Carrega comissão quando cliente não é compartilhado ##
           // ######################################################
           If kTipoComp == "N"
   
              If Empty(Alltrim(xCodVen1))
              Else
                 Do Case 

                    // #######################################
                    // Se vendedor for Executivo de Venda 1 ##
                    // #######################################
                    Case kTipoVen1 == "1"
                         xComis1 := kExecut1
              
                    // ####################################
                    // Se vendedor for Gerente de Vendas ##
                    // ####################################
                    Case kTipoVen1 == "2"
                         xComis1 := kGerente

                    // ########################################
                    // Se vendedor for Executivo de Vendas 2 ##
                    // ########################################
                    Case kTipoVen1 == "3"
                         xComis1 := kExecut2
          
                 EndCase
              Endif
              
              If Empty(Alltrim(xCodVen2))
              Else

                 Do Case 

                    // #######################################
                    // Se vendedor for Executivo de Venda 1 ##
                    // #######################################
                    Case kTipoVen2 == "1"
                         xComis2 := kExecut1
              
                    // ####################################
                    // Se vendedor for Gerente de Vendas ##
                    // ####################################
                    Case kTipoVen2 == "2"
                         xComis2 := kGerente

                    // ########################################
                    // Se vendedor for Executivo de Vendas 2 ##
                    // ########################################
                    Case kTipoVen2 == "3"
                         xComis2 := kExecut2
          
                 EndCase
                                               
              Endif
      
           Else   
                                     
              Do Case 

                 // ##########################
                 // Se vendedor for gerente ##
                 // ##########################
                 Case kTipoVen1 == "1"
                      xComis1 := (kExecut1 * 70) / 100
                      xComis2 := (kGerente * 30) / 100
              
                 // ##########################
                 // Se vendedor Executivo 2 ##
                 // ##########################
                 Case kTipoVen1 == "3"
                      xComis1 := (kExecut2 * 70) / 100
                      xComis2 := (kGerente * 30) / 100

              EndCase
         
           Endif

           // ###############################
           // Carrega o array dos produtos ##
           // ###############################
           aAdd(_aItens, {{"C6_FILIAL" , xCodFil                                                                    , Nil},; // Código da Filial
                          {"C6_NUM"    , cNumPed                                                                    , Nil},; // Nº do Pedido de Venda
                          {"C6_ITEM"   , Strzero(nContar,02)                                                        , Nil},; // Código do Produto
                          {"C6_PRODUTO", Alltrim(kk_Produto)                                                        , Nil},; // Código do Produto
  			              {"C6_DESCRI" , kk_Descricao                                                               , Nil},; // Descrição do Produto
                          {"C6_UM"     , kk_Unidade                                                                 , Nil},; // Unidade de medida (primeira)
                          {"C6_QTDVEN" , VAL(U_P_CORTA(xQtdPro,"|", nContar))                                       , Nil},; // Quantidade vendida do produto
                          {"C6_PRCVEN" , VAL(U_P_CORTA(xPrcPro,"|", nContar))                                       , Nil},; // Preco venda do produto
                          {"C6_PRUNIT" , VAL(U_P_CORTA(xPrcPro,"|", nContar))                                       , Nil},; // Preco unitario
              			  {"C6_LOCAL"  , "01"   		                                                            , Nil},; // Armazem
                          {"C6_TES"    , kTES                                                                       , Nil},; // TES
                          {"C6_CLI"    , cCodigo                                                                    , Nil},; // Código do cliente 
                          {"C6_LOJA"   , cLoja                                                                      , Nil},; // Loja do cliente
                          {"C6_CHASSI" , "X"                                                                        , Nil},; // % comissão vendedor 2
                          {"C6_TURNO"  , "M"                                                                        , Nil},; // % comissão vendedor 2                                                                              
   			              {"C6_ENTREG" , Date()                                                                     , Nil},; // Data de Entrega
     			          {"C6_SUGENTR", Date()                                                                     , Nil},; // Data Sugerida
                          {"C6_COMIS1" , xComis1                                                                    , Nil},; // % comissão vendedor 1
                          {"C6_COMIS2" , xComis2                                                                    , Nil}}) // % comissão vendedor 2

           // #################################################################################################################################################
           // Cfop deve ser deixado em branco. O próprio sistema pesquisa o CF adequado                                                                      ##
           // {"C6_CF"     , Alltrim(Posicione( "SF4", 1, xFilial("SF4") + kTES, "F4_CF"))              , Nil},; // Classificação fiscal do produto pela tes ##
           // #################################################################################################################################################

           // #################################
           // Display dos dados para analise ##
           // #################################
           Conout("Filial...............: " + xCodFil)                
           Conout("Numero PV............: " + cNumPed)
           Conout("Item.................: " + Strzero(nContar,02))
           Conout("Produto..............: " + Alltrim(U_P_CORTA(xCodPro,"|", nContar)))
           Conout("Unidade Medida.......: " + Alltrim(Posicione( "SB1", 1, xFilial("SB1") + kk_Produto, "B1_UM" )))
           Conout("Quantidade...........: " + U_P_CORTA(xQtdPro,"|", nContar))                                                     
           Conout("Preco Venda..........: " + U_P_CORTA(xPrcPro,"|", nContar))                                                     
           Conout("Preco Unitario.......: " + U_P_CORTA(xPrcPro,"|", nContar))                                                     
           Conout("Total Produto........: " + U_P_CORTA(xTotPro,"|", nContar))                                                     
           Conout("Tipo de Operação.....: " + xTipoOpe)
           Conout("TES..................: " + kTES)
           Conout("Classificacao Fiscal.: " + Alltrim(Posicione( "SF4", 1, xFilial("SSF4") + kTES, "F4_CF")))                           
           Conout("Armazem..............: " + "01")                                                                                                                                                                
           Conout("Codigo Cliente.......: " + cCodigo)
           Conout("Loja Cliente.........: " + cLoja)
           Conout("Data Entrega.........: " + Dtoc(dDataBase))
           Conout("Data Sugerida........: " + Dtoc(dDataBase))
           Conout("Descricao Produto....: " + Alltrim(Posicione( "SB1", 1, xFilial("SB1") + kk_Produto, "B1_DESC")))  
           Conout("Part Number..........: " + Alltrim(Posicione( "SB1", 1, xFilial("SB1") + kk_Produto, "B1_PARNUM")))
           Conout("Codigo Fabricante....: " + Posicione( "SB1", 1, xFilial("SB1") + kk_Produto, "B1_PROC"))           
           Conout("Loja Fabricante......: " + Posicione( "SB1", 1, xFilial("SB1") + kk_Produto, "B1_LOJPROC"))        
           Conout("Situacao Tributaria..: " + xSituacao)
           Conout("Status do Pedido.....: " + "01")
           Conout("Tem Documento........: " + "N")                                                                                       
           Conout("Rateio...............: " + "2")
           Conout("Tipo Ordem Producao..: " + "F")

      Next nContar

      // ##############################################################
      // Executa o comando de inclusão automática do pedido de venda ##
      // ##############################################################
      nModulo := 5
      MsExecAuto({|x, y, z| MATA410(x, y, z)}, _aCabec, _aItens, 3) 

      If lMsErroAuto
         Conout("Erro na inclusão do pedido")
         cString := MostraErro()
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         RESET ENVIRONMENT
          
         Return(.T.)
      Else

         If Alltrim(xTipPed) == "1"

            DbSelectArea("SC5")
            DbSetOrder(1)
            If DbSeek( xFilial("SC5") + cNumPed )
               Reclock("SC5",.F.)           
//             SC5->C5_EXTERNO := "1"
               SC5->C5_FORNEXT := xForExt
               SC5->C5_LOJAEXT := xLojExt         
               SC5->C5_SDIS    := "1"
//             SC5->C5_MENNOTA := xObsNota
//             SC5->C5_OBSI    := xObsInte
//             SC5->C5_OBSNT   := xObsDanf
	     	   MsUnlock()

               // ######################################################################
               // Envia para o programa que libera o pedido de venda de intermediação ##
               // ######################################################################
               U_AUTOM526( xCodFil, cNumPed)

            Endif
         Endif   

         // ##################################################################
         // Se transportadora = 000008 -> Correios, grava o tipo de serviço ##
         // ##################################################################
         If xCodTra == "000008"

            DbSelectArea("SC5")
            DbSetOrder(1)
            If DbSeek( xFilial("SC5") + cNumPed )
               Reclock("SC5",.F.)           
               Do Case
                  Case xTipoSrv == "1"
                       SC5->C5_TSRV := "CORREIOS 41068-PAC"
                  Case xTipoSrv == "2"
                       SC5->C5_TSRV := "CORREIOS 40436-SEDEX"
                  oTherwise 
                       SC5->C5_TSRV := ""
               EndCase
	     	   MsUnlock()
	     	Endif                

         Endif   

         Conout("Numero do pedido gerado: " + Alltrim(cNumPed))
         cString := "000 - " + Alltrim(cNumPed)
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         RESET ENVIRONMENT
          
         Return(.T.)
      EndIf
      
   Next nVezes   

   RESET ENVIRONMENT

Return(.T.)        

// ############################################################################
// Função que seta a Empresa e Filial conforme parâmetros recebidos pela URL ##
// ############################################################################
Static Function ALTEMPFIL(K_Empresa, k_Filial)

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

// ------------------------------------------------------------------------------------------------------------------------------------------------------- ##
// Parâmetros para testar o web service                                                                                                                    ##
// ------------------------------------------------------------------------------------------------------------------------------------------------------- ##
// Exemplo de chamada da URL + Parâmentros
// http://54.94.245.225:8094/rest/AT_GRAVAPVENDA?cCodEmp=01&cCodFil=01&cTipPed=2&cCGCCli=02.836.152/0001-54&cCodCon=A VISTA - DINHEIRO&cCodAdm=02&cTipFre=C&cValFre=50.00&cCodTra=000008&cCodVen1=000001&cCodVen2=&cCodMoe=1|&cForExt=000011&cLojExt=001&cCodPro=13493|&cQtdPro=1|&cPrcPro=1000.00|&cTotPro=1000.00|&cComis1=0.50|&cComis2=0.00|&cIsento=0&cContrib=1&cFormaPG=1&cProposta=000001&cObsNota=&cObsInte=&cObsDanf=&cCodGrv=N
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

//Tabela de retornos do Web Service Pedido de Venda Protheus                                       
//-------------------------------------------------------------------------------------------------
//000 - Inclusão de pedido de venda com sucesso                                                    
//001 - Código da Empresa não informada                                                            
//002 - Código da Filial não informada                                                             
//003 - Tipo de Pedido de Venda não informado                                                      
//004 - CNPJ/CPF do Cliente não informado                                                          
//005 - Condição de Pagamento não informada                                                        
//006 - Reservado
//007 - Tipo de frete não informado                                                                
//008 - Valor do Frete                                                                             
//009 - Transportadora                                                                             
//010 - Código vendedor 1 não informado                                                            
//011 - Código da moeda não informada                                                              
//011 - Código do fornecedor externo não informado                                                 
//012 - Código da loja do fornecedor externo não informada                                         
//013 - Código(s) do(s) produto(s) do pedido de venda não informado(s)                             
//014 - Informação do(s) código(s) do(s) produto(s) inconsistênte (Sem informação do |)            
//015 - Código(s) do(s) produto(s) do pedido de venda não informado(s)                             
//016 - Informação da(s) quantidade(s) do(s) produto(s) inconsistênte (Sem informação do |)        
//017 - Preço(s) unitário(s) do(s) produto(s) não informado(s)                                     
//018 - Informação do(s) preço(s) unitário(s) do(s) produto(s) inconsistênte (Sem informação do |) 
//019 - Valor Total do(s) produto(s) não informado(s)                                              
//020 - Informação do(s) total(is) do(s) produto(s) inconsistênte (Sem informação do |)            
//021 - Percentual de comissão para o vendedor 1 não informada                                     
//022 - Percentual de comissão para o vendedor 2 não informada                                     
//023 - Conteúdo do tipo de pedido de venda é inválido (Aceitos 1 ou 2)                            
//024 - Dados Cadastrais do Cliente                                                                
//025 - Nome do cliente não informado                                                              
//026 - Endereço do cliente nãoo informado                                                         
//027 - UF do cliente não informado                                                                
//028 - Bairro do cliente não informado                                                            
//029 - Município do cliente não informado                                                         
//030 - CEP do endereço do cliente não informado                                                   
//031 - DDD do telefone do cliente não informado                                                   
//032 - Telefone do cliente não informado                                                          
//033 - Inscrição Estadual do cliente não informada                                                
//034 - E-mail do cliente não informado                                                            
//035 - Contato do cliente não informado                                                           
//036 - Indicação de IE Isenta não informada                                                       
//037 - Informação do campo IE Isenta inconsistente (Aceitos somenete 0 ou 1)                      
//038 - Cliente contribuinte não informado                                                            
//039 - Informação do campo Cliente Contribuinte inconsistente (Aceitos somenete 0 ou 1)           
//040 - Reservado
//041 - Reservado
//042 - Erro ao gravar pedido de venda                                                             
//043 - Nº da proposta comercial não informada                                                     
//044 - Cliente inexistente no Protheus                                                            
//045 - Informação da(s) moeda(s) inconsistênte (Sem informação do |)                              
//046 - Vendedor 1 não cadastrado                                                                  
//047 - Vendedor 2 não cadastrado                                                                  
//048 - Dados Cadastrais do cliente (Parâmetros aguardados não recebidos)                          
//
//URL
//
//http://54.94.245.225:8094/rest/AT_GRAVAPVENDA?cCodEmp=01&cCodFil=01&cTipPed=2&cCGCCli=02.836.152/0001-54&cCodCon=A VISTA - DINHEIRO&cTipFre=C&cValFre=50.00&cCodTra=000008&cCodVen1=000001&cCodVen2=&cCodMoe=1|&cForExt=000011&cLojExt=001&cCodPro=13493|&cQtdPro=1|&cPrcPro=1000.00|&cTotPro=1000.00|&cComis1=0.50|&cComis2=0.00|&cIsento=0&cContrib=1&cProposta=000001&cObsNota=&cObsInte=&cObsDanf=
//
//onde or parâmetros são:
//
//?cCodEmp=01                 -> Código da Empresa a que se refere a proposta comercial
//&cCodFil=01                 -> Código da Filial a que se refere a proposta comercial
//&cTipPed=2                  -> Tipo da Proposta Comercial (1 = Pedido de Intermediação, 2 = Pedido Normal)
//&cCGCCli=02.836.152/0001-54 -> CNPJ do Cliente
//&cDadosCli=<Nome do Cliente>|<Endereço do Cliente>|<Estado>|<Bairro>|<Cidade>|<Cep>|<DDD>|<Telefone>|<Inscrição Estadual>|<E-mail>|<Nome Contato>|<Indicação IE Isenta>|<Indicação Contribuinte>|
//                            -> Dados cadastrais para inclusão do cliente
//&cCodCon=A VISTA - DINHEIRO -> Condição de Pagamento
//&cTipFre=C                  -> Tipo de Frete (C = CIF, F = FOB)
//&cValFre=50.00              -> Valor do Frete
//&cCodTra=000008             -> Código da Transportadora
//&cCodVen1=000001            -> Código Vendedor 1
//&cCodVen2=                  -> Código vendedor 2
//&cCodMoe=1|                 -> Moeda da proposta
//&cForExt=000011             -> Código Fornecedor Externo
//&cLojExt=001                -> Loja Fornecedor Externo
//&cCodPro=13493|             -> Nº do Registro do Produto na tabela SB1
//&cQtdPro=1|                 -> Quantidade dos Produtos
//&cPrcPro=1000.00|           -> Preço Unitário dos Produtos
//&cTotPro=1000.00|           -> Valor Total dos Produtos
//&cComis1=0.50|              -> % Comissão vendedor 1
//&cComis2=0.00|              -> % Comissão vendedor 2
//&cIsento=0                  -> Indica se IE do cliente é Isento onde 0 = Isento, 1 = Não Isento
//&cContrib=1                 -> Indica se Cliente é contribuinte onde 0 = Não Contribuinte, 1 = Contribuinte
//&cProposta=000001           -> Nº da Proposta Comercial
//&cObsNota=                  -> Campo Observações que serão impressos na nota fiscal
//&cObsInte=                  -> Campo Observações Internas
//&cObsDanf=                  -> Campo Observações para Danfe


//&cDadosCli=<Nome do Cliente>|<Endereço do Cliente>|<Estado>|<Bairro>|<Cidade>|<Cep>|<DDD>|<Telefone>|<Inscrição Estadual>|<E-mail>|<Nome Contato>|<Indicação IE Isenta>|<Indicação Contribuinte>|

//HARALD HANS LOSCHENKOHL|AV CARLOS VENTURA, 440 AP 202|RS|ENGENHO|GUAIBA|92500000|51|984825852|147/8243616|harald@automatech.com.br|HARALD|1|1|

*/