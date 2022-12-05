#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AT_GRAVAPVENDA.PRW                                                  ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 19/01/2017                                                          ##
// Objetivo..: Web Service que gera a inclusão do pedido de venda no Protheus.     ##
// Parâmetros: Vide relação abaixo                                                 ##
// ##################################################################################

WSRESTFUL AT_GRAVAPVENDA DESCRIPTION "Advpl Tools - Service Pedido de Venda"

    WSDATA cCodEmp   AS STRING // Código da Empresa
    WSDATA cCodFil   AS STRING // Código da Filial
    WSDATA cTipPed   AS STRING // Tipo do Pedido de Venda  
    WSDATA cCGCCli   AS STRING // Cnpj do Cliente
    WSDATA cDadosCli AS STRING // String com os dados do cliente (NOME#ENDERECO#ESTADO#BAIRRO#MUNICIPIO#CEP#DDD#TELEFONE#IE#EMAIL#CONTATO#)
    WSDATA cCodCon   AS STRING // Condição de Pagamento  
    WSDATA cCodAdm   AS STRING // Administradora de Cartão  
    WSDATA cTipFre   AS STRING // Tipo de Frete  
    WSDATA cValFre   AS STRING // Valor do Frete  
    WSDATA cCodTra   AS STRING // Transportadora
    WSDATA cCodVen1  AS STRING // Código do Vendedor 1
    WSDATA cCodVen2  AS STRING // Código do Vendedor 2
    WSDATA cCodMoe   AS STRING // Código da Moeda
    WSDATA cForExt   AS STRING // Códifo Fornecedor Externo
    WSDATA cLojExt   AS STRING // Loja do Fornecedor externo
    WSDATA cCodPro   AS STRING // String com os Códigos dos produtos (004442#003102#001372#)
    WSDATA cQtdPro   AS STRING // String com os Códigos dos produtos (1#1.5#3#) 
    WSDATA cPrcPro   AS STRING // String com as Quantidades dos produtos (1075.25#750.00#100.00#) 
    WSDATA cTotPro   AS STRING // String com os Preços Unitários dos produtos (1075.25#1125.00#300.00#) 
    WSDATA cComis1   AS STRING // Percentual Comissão Vendedor 1
    WSDATA cComis2   AS STRING // Percentual Comissão Vendedor 2
    WSDATA cIsento   AS STRING // Indica se a IE do cliente é Isenta ou não
    WSDATA cContrib  AS STRING // Indica se o cliente é ou não contribuinte
    WSDATA cFormaPG  AS STRING // Indica a Forma de Pagamento
    WSDATA cProposta AS STRING // Nº da proposta comercial SaleMachine
    
	WSMETHOD GET DESCRIPTION "Advpl Tools - Service Pedido de Venda" WSSYNTAX "/AT_GRAVAPVENDA || /AT_GRAVAPVENDA/{cCodEmp}{cCodFil}{cTipPed}{cCGCCli}{cDadosCli}{cCodCon}{cCodAdm}{cTipFre}{cValFre}{cCodTra}{cCodVen1}{cCodVen2}{cCodMoe}{cForExt}{cLojExt}{cCodPro}{cQtdPro}{cPrcPro}{cTotPro}{cComis1}{cComis2}{cIsento}{cContrib}{cFormaPG}{cProposta}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE cCodEmp, cCodFil, cTipPed, cCGCCli, cDadosCli, cCodCon, cCodAdm, cTipFre, cValFre, cCodTra, cCodVen1, cCodVen2, cCodMoe, cForExt, cLojExt, cCodPro, cQtdPro, cPrcPro, cTotPro, cComis1, cComis2, cIsento, cContrib, cFormaPG, cProposta WSSERVICE AT_GRAVAPVENDA

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

   Local xCodEmp   := Self:cCodEmp
   Local xCodFil   := Self:cCodFil
   Local xTipPed   := Self:cTipPed
   Local xCGCCli   := Self:cCGCCLI
   Local xCodCon   := Self:cCodCon
   Local xCodAdm   := Self:cCodAdm
   Local xTipFre   := Self:cTipFre
   Local xValFre   := Self:cValFre
   Local xCodTra   := Self:cCodTra
   Local xCodVen1  := Self:cCodVen1
   Local xCodVen2  := Self:cCodVen2
   Local xCodMoe   := Self:cCodMoe
   Local xForExt   := Self:cForExt
   Local xLojExt   := Self:cLojExt
   Local xCodPro   := Self:cCodPro
   Local xQtdPro   := Self:cQtdPro
   Local xPrcPro   := Self:cPrcPro
   Local xTotPro   := Self:cTotPro
   Local xComis1   := Self:cComis1
   Local xComis2   := Self:cComis2
   Local xDadosCli := Self:cDadosCli
   
   Local xNomeCli  := U_P_corta(xDadosCli, "|", 01) // Nome
   Local xEndeCli  := U_P_corta(xDadosCli, "|", 02) // ENDERECO
   Local xEstaCli  := U_P_corta(xDadosCli, "|", 03) // ESTADO
   Local xBairCli  := U_P_corta(xDadosCli, "|", 04) // BAIRRO
   Local xMuniCli  := U_P_corta(xDadosCli, "|", 05) // MUNICIPIO
   Local xCEPCli   := U_P_corta(xDadosCli, "|", 06) // CEP
   Local xDDDCli   := U_P_corta(xDadosCli, "|", 07) // DDD
   Local xTeleCli  := U_P_corta(xDadosCli, "|", 08) // TELEFONE
   Local xInscCli  := U_P_corta(xDadosCli, "|", 09) // IE
   Local xEmaiCli  := U_P_corta(xDadosCli, "|", 10) // EMAIL   
   Local xContCli  := U_P_corta(xDadosCli, "|", 11) // CONTATO   

   Local xIsento   := Self:cIsento
   Local xContrib  := Self:cContrib
   Local xFormaPG  := Self:cFormaPG
   Local xProposta := Self:cProposta

   Private lMsErroAuto := .F. 
   Private lMsHelpAuto := .F. 

   // ###############################################################################
   // Seta o código da Empresa conforme parâmetro para inclusão do pedido de venda ##
   // ###############################################################################
   cEmpAnt := cCodEmp

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
   // 006 - Administradora de Cartões não informada                                                    ##
   // 007 - Tipo de frete não informado                                                                ##
   // 008 - Valor do Frete                                                                             ##
   // 009 - Transportadora                                                                             ##
   // 010 - Código vendedor 1 não informado                                                            ##
   // 011 - Código da moeda não informada                                                              ##
   // 011 - Código do fornecedor externo não informado                                                 ##
   // 012 - Código da loja do fornecedor externo não informada                                         ##
   // 013 - Código(s) do(s) produto(s) do pedido de venda não informado(s)                             ##
   // 014 - Informação do(s) código(s) do(s) produto(s) inconsistênte (Sem informação do #)            ##
   // 015 - Código(s) do(s) produto(s) do pedido de venda não informado(s)                             ##
   // 016 - Informação da(s) quantidade(s) do(s) produto(s) inconsistênte (Sem informação do #)        ##
   // 017 - Preço(s) unitário(s) do(s) produto(s) não informado(s)                                     ##
   // 018 - Informação do(s) preço(s) unitário(s) do(s) produto(s) inconsistênte (Sem informação do #) ##
   // 019 - Valor Total do(s) produto(s) não informado(s)                                              ##
   // 020 - Informação do(s) total(is) do(s) produto(s) inconsistênte (Sem informação do #)            ##
   // 021 - Percentual de comissão para o vendedor 1 não informada                                     ##
   // 022 - Percentual de comissão para o vendedor 2 não informada                                     ##
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
   // 040 - Campo forma de pagamento não informado                                                     ##
   // 041 - Informação do campo forma de pagamento inconsistente (Aceitos somenete 1 ou 2)             ##
   // 042 - Erro ao gravar pedido de venda                                                             ##
   // 043 - Nº da proposta comercial não informada                                                     ##
   // ###################################################################################################

   // #############################
   // Consiste código da Empresa ##
   // #############################
   If Empty(Alltrim(xCodEmp))
      Conout("Codigo da Empresa...........: " + xCodEmp)   
      cString := "001 - Código da Empresa não informada"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Endif

   // ############################
   // Consiste código da Filial ##
   // ############################
   If Empty(Alltrim(xCodFil))
      Conout("Codigo da Filial...........: " + xCodFil)   
      cString := "002 - Código da Filial não informada"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Endif

   // #####################################
   // Consiste o tipo de pedido de venda ##
   // #####################################
   If Empty(Alltrim(xTipPed))
      Conout("Tipo de Pedido de Venda...........: " + xTipPed)   
      cString := "003 - Tipo de Pedido de Venda não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Endif

   // #################################################
   // Consiste o conteúdo do tipo de pedido de venda ##
   // #################################################
//   If Alltrim(xTipPed) <> "1" 
//      If Alltrim(xTipPed) <> "2"
//         Conout("Tipo de Pedido de Venda...........: " + xTipPed)   
//         cString := "023 - Conteúdo do tipo de pedido de venda é inválido (Aceitos 1 ou 2)"
//         ::SetContentType("text/plain")
//         ::SetResponse(cString)  	
//         Return(.T.)
//      Endif
//   Endif   

   // ###############################
   // Consiste CNPJ/CPF do cliente ##
   // ###############################
   If Empty(Alltrim(xCGCCli))
      Conout("CNPJ/CPF do Cliente...........: " + xCGCCli)
      cString := "004 - CNPJ/CPF do Cliente não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Endif

   // ###################################
   // Consiste a Condição de Pagamento ##
   // ###################################
   If Empty(Alltrim(xCodCon))
      Conout("Condicao de Pagamento...........: " + xCodCon)
      cString := "005 - Condição de Pagamento não informada"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
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
//       Return(.T.)
//    Endif
// Endif

   // ###########################
   // Consiste o Tipo de Frete ##
   // ###########################
   If Empty(Alltrim(xTipFre))
      Conout("Tipo de Frete...........: " + xTipFre)
      cString := "007 - Tipo de frete não infromado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
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
//    Return(.T.)
// Endif

   // ################################
   // Consiste o código do Vendedor ##
   // ################################
   If Empty(Alltrim(xCodVen1))
      Conout("Codigo vendedor 1......: " + xCodVen1)
      cString := "010 - Código vendedor 1 não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Endif

   // #############################
   // Consiste o código da moeda ##
   // #############################
   If Empty(Alltrim(xCodMoe))
      Conout("Codigo Moeda......: " + xCodMoe)
      cString := "011 - Código da moeda não informada"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Endif

   // ###################################################################
   // Consiste o código e loja do fornecedor em caso de pedido externo ##
   // ###################################################################
   If Alltrim(xTipPed) == "1"
      If Empty(Alltrim(xForExt))
         Conout("Codigo distribuidor......: " + xForExt)
         cString := "011 - Código do fornecedor externo não informado"
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         Return(.T.)
      Endif

      If Empty(Alltrim(xLojExt))
         Conout("Codigo loja distribuidor......: " + xLojExt)
         cString := "012 - Código da loja do fornecedor externo não informada"
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         Return(.T.)
      Endif

   Endif

   // #################################
   // Consiste o código dos produtos ##
   // #################################
   If Empty(Alltrim(xCodPro))
      Conout("Codigo dos produtos......: " + xCodPro)
      cString := "013 - Código(s) do(s) produto(s) do pedido de venda não informado(s)"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Else
      If U_P_OCCURS(xCodPro, "|", 1) == 0
         Conout("Codigo dos produtos sem | ......: " + xCodPro)
         cString := "014 - Informação do(s) código(s) do(s) produto(s) inconsistênte (Sem informação do #)"
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         Return(.T.)
      Endif
   Endif

   // #####################################
   // Consiste a quantidade dos produtos ##
   // #####################################
   If Empty(Alltrim(xQtdPro))
      Conout("Quantidade dos produtos......: " + xQtdPro)
      cString := "015 - Código(s) do(s) produto(s) do pedido de venda não informado(s)"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Else
      If U_P_OCCURS(xQtdPro, "|", 1) == 0
         Conout("Quantidade dos produtos sem |......: " + xQtdPro)
         cString := "016 - Informação da(s) quantidade(s) do(s) produto(s) inconsistênte (Sem informação do #)"
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         Return(.T.)
      Endif
   Endif      

   // #######################################
   // Consiste o preço unário dos produtos ##
   // #######################################
   If Empty(Alltrim(xPrcPro))
      Conout("Preco unitario dos produtos......: " + xPrcPro)
      cString := "017 - Preço(s) unitário(s) do(s) produto(s) não informado(s)"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Else
      If U_P_OCCURS(xPrcPro, "|", 1) == 0
         Conout("Preco unitario dos produtos sem |......: " + xPrcPro)
         cString := "018 - Informação do(s) preço(s) unitário(s) do(s) produto(s) inconsistênte (Sem informação do #)"
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         Return(.T.)
      Endif
   Endif      

   // ######################################
   // Consiste o valor total dos produtos ##
   // ######################################
   If Empty(Alltrim(xTotPro))
      Conout("Valor total dos produtos......: " + xTotPro)
      cString := "019 - Valor Total do(s) produto(s) não informado(s)"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Else
      If U_P_OCCURS(xTotPro, "|", 1) == 0
         Conout("Valor total dos produtos sem #......: " + xTotPro)
         cString := "020 - Informação do(s) total(is) do(s) produto(s) inconsistênte (Sem informação do #)"
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         Return(.T.)
      Endif
   Endif      

   // ##################################################
   // Consiste o percentual de comissão do vendedor 1 ##
   // ##################################################
   If !Empty(Alltrim(xCodVen1))
      If Empty(Alltrim(xComis1))
         Conout("Percentual comissao vendedor 1......: " + xComis1)
         cString := "021 - Percentual de comissão para o vendedor 1 não informada"
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         Return(.T.)
      Endif
   Endif   

   // ##################################################
   // Consiste o percentual de comissão do vendedor 2 ##
   // ##################################################
   If !Empty(Alltrim(xCodVen2))
      If Empty(Alltrim(xComis2))
         Conout("Percentual comissao vendedor 2......: " + xComis2)
         cString := "022 - Percentual de comissão para o vendedor 2 não informada"
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         Return(.T.)
      Endif
   Endif   

   // #############################
   // Consiste o campo IE Isento ##
   // #############################
   If Empty(Alltrim(xIsento))
      Conout("Indica IE Isenta......: " + xComis2)
      cString := "036 - Indicação de IE Isenta não informada"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Endif

   If xIsento$("0#1")
   Else
      Conout("Indica IE Isenta Somente 1 ou 2......: " + xIsento)
      cString := "037 - Informação do campo IE Isenta inconsistente (Aceitos somenete 0 ou 1)"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Endif

   // ################################
   // Consiste o campo Contribuinte ##
   // ################################
   If Empty(Alltrim(xContrib))
      Conout("Cliente Contribuinte......: " + xContrib)
      cString := "038 - Cliente contribuinte não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Endif

   If xContrib$("0#1")
   Else
      Conout("Cliente Contribuinte somente 0 ou 1......: " + xContrib)
      cString := "039 - Informação do campo Cliente Contribuinte inconsistente (Aceitos somenete 0 ou 1)"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Endif

   // ######################################
   // Consiste o campo forma de pagamento ##
   // ######################################
   If Empty(Alltrim(xFormaPG))
      Conout("Forma de Pagamento......: " + xFormaPG)
      cString := "040 - Campo forma de pagamento não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Endif

   If Empty(Alltrim(xFormaPG))
//      Conout("Forma de Pagamento somente 1 ou 2......: " + xFormaPG)
//      cString := "041 - Informação do campo forma de pagamento inconsistente (Aceitos somenete 1 ou 2)"
//      ::SetContentType("text/plain")
//      ::SetResponse(cString)  	
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

   // ##########################################
   // Consiste os dados cadastrais do cliente ##
   // ##########################################
   If Empty(Alltrim(xDadosCli))
      Conout("Dados Cadastrais do Cliente......: " + xDadosCli)
      cString := "024 - Dados cadastrais do cliente nao enviados"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Endif

   // #########################################################
   // Consiste campo a campo dos dados cadastrais do cliente ##
   // #########################################################

   // #############################
   // Consiste o nome do Cliente ##
   // #############################
   If Empty(Alltrim(xNomeCli))
      Conout("Nome do Cliente.....: " + xNomeCli)
      cString := "025 - Nome do cliente não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Endif

   // #################################
   // Consiste o endereço do Cliente ##
   // #################################
   If Empty(Alltrim(xEndeCli))
      Conout("Endereco do Cliente....: " + xEndeCli)
      cString := "026 - Endereço do cliente nãoo informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Endif

   // ###########################################
   // Consiste o estado do endereço do Cliente ##
   // ###########################################
   If Empty(Alltrim(xEstaCli)) // ESTADO#
      Conout("Estado do Cliente....: " + xEstaCli)
      cString := "027 - UF do cliente não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Endif

   // ###########################################
   // Consiste o bairro do endereço do Cliente ##
   // ###########################################
   If Empty(Alltrim(xBairCli))
      Conout("Bairro do Cliente....: " + xBairCli)
      cString := "028 - Bairro do cliente não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Endif

   // ##################################
   // Consiste o município do Cliente ##
   // ##################################
   If Empty(Alltrim(xMuniCli))
      Conout("Municipio do Cliente....: " + xMuniCli)
      cString := "029 - Município do cliente não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Endif

   // ########################################
   // Consiste o CEP do endereço do Cliente ##
   // ########################################
   If Empty(Alltrim(xCEPCli)) // CEP#
      Conout("CEP do Cliente....: " + xCEPCli)
      cString := "030 - CEP do endereço do cliente não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Endif

   // ########################################
   // Consiste o DDD do telefone do cliente ##
   // ########################################
   If Empty(Alltrim(xDDDCli))
      Conout("DDD....: " + xDDDCli)
      cString := "031 - DDD do telefone do cliente não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Endif

   // #######################################
   // Consiste o nº do telefone do cliente ##
   // #######################################
   If Empty(Alltrim(xTeleCli))
      Conout("Telefone....: " + xTeleCli)
      cString := "032 - Telefone do cliente não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Endif

   // #########################################
   // Consiste Inscrição estadual do cliente ##
   // #########################################
   If Empty(Alltrim(xInscCli))
      Conout("Inscricao Estadual....: " + xInscCli)
      cString := "033 - Inscrição Estadual do cliente não informada"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Endif

   // ############################
   // Consiste email do cliente ##
   // ############################
   If Empty(Alltrim(xEmaiCli))
      Conout("E-mail do Cliente....: " + xEmaiCli)
      cString := "034 - E-mail do cliente não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Endif

   // ######################################
   // Consiste nome do contato do cliente ##
   // ######################################
   If Empty(Alltrim(xContCli))
      Conout("Contato do Cliente....: " + xContCli)
      cString := "035 - Contato do cliente não informado"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Endif

   // #######################################################################
   // Consiste o nº da proposta comercial de vínculo com o pedido de venda ##
   // #######################################################################
   If Empty(Alltrim(xProposta))
      Conout("Numero da proposta do sale machine....: " + xProposta)
      cString := "043 - Nº da proposta comercial não informada"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
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

      // ##########################################################################
      // Verifica se o cliente é jurídico ou físico para pesquisa do novo código ##
      // ##########################################################################
      _Juridico := IIF(Len(Alltrim(xCGCCli)) == 14, "S", "N")

      // ###################################################
      // Se for pessoa física, não tem loja diferente 001 ##
      // ###################################################
      If _Juridico == "N"      

         // #####################################
         // Pesquisa novo código para inclusão ##
         // #####################################
         If Select("T_PROXIMO") > 0
            T_PROXIMO->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT A1_COD ,"
         cSql += "       A1_LOJA,"
         cSql += "       A1_NOME,"
         cSql += "       A1_CGC  "
         cSql += "  FROM SA1010  "
         cSql += " WHERE D_E_L_E_T_ = ''"
         cSql += " ORDER BY A1_COD DESC "

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

         If T_PROXIMO->( EOF() )
            nProximoCod := "000001"
         Else
            nProximoCod := STRZERO((INT(VAL(T_PROXIMO->A1_COD)) + 1),6)
         Endif

      Else
      
         // #####################################################################################
         // Verifica se o raiz do CNPJ já está cadastrado.                                     ## 
         // Se está, captura o último código de loja para dar sequencia a numeração das lojas. ##
         // #####################################################################################
         If Select("T_RAIZ") > 0
            T_RAIZ->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT A1_COD ,"
         cSql += "       A1_LOJA,"
         cSql += "       A1_NOME,"
         cSql += "       A1_CGC  "
         cSql += "  FROM SA1010  "
         cSql += " WHERE SUBSTRING(A1_CGC,1,8) = '" + Substr(xCGCCLI,01,08) + "'"
         cSql += "   AND D_E_L_E_T_ = ''"     
         cSql += " ORDER BY A1_COD, A1_LOJA DESC"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RAIZ", .T., .T. )
       
         If T_RAIZ->( EOF() )  
         
            // ##########################################
            // Pesquisa o próximo código para inclusão ##
            // ##########################################
            If Select("T_PROXIMO") > 0
               T_PROXIMO->( dbCloseArea() )
            EndIf

            cSql := ""
            cSql := "SELECT TOP(1) A1_COD"
            cSql += "  FROM SA1010  "
            cSql += " WHERE D_E_L_E_T_ = ''"     
            cSql += " ORDER BY A1_COD DESC"
         
            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )
         
            If T_PROXIMO->( EOF() )
               cCodigo := "000001"
               cLoja   := "001"   
            Else
               cCodigo := Strzero((INT(VAL(T_PROXIMO->A1_COD)) + 1),6)
               cLoja   := "001"
            Endif
         Else       
            cCodigo := T_RAIZ->A1_COD
            cLoja   := Strzero((INT(VAL(T_RAIZ->A1_LOJA)) + 1),3)
         Endif
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
      cSql += " WHERE CC2_EST    = '" + Alltrim(xEstaCli) + "'"
      cSql += "   AND CC2_MUN    = '" + Alltrim(xMuniCli) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_IBGE", .T., .T. )

      If T_IBGE->( EOF() )
         cMunicipio := ""
      Else
         cMunicipio := T_IBGE->CC2_CODMUN
      Endif

      // ###########################################
      // Inclui os dados do cliente na Tabela SA1 ##
      // ###########################################
      DbSelectArea("SA1")
      RecLock("SA1",.T.)
      SA1->A1_FILIAL  := ""
      SA1->A1_COD     := cCodigo
      SA1->A1_LOJA    := cLoja
      SA1->A1_PESSOA  := IIF(_Juridico == "S", "J", "F")
      SA1->A1_NOME    := UPPER(Alltrim(xNomeCli))
      SA1->A1_NREDUZ  := UPPER(Alltrim(xNomeCli))
      SA1->A1_END     := UPPER(Alltrim(xEndeCli))
      SA1->A1_TIPO    := "F"
      SA1->A1_EST     := UPPER(Alltrim(xEstaCli))
      SA1->A1_COD_MUN := cMunicipio
      SA1->A1_MUN     := UPPER(Alltrim(xMuniCli))
      SA1->A1_BAIRRO  := UPPER(Alltrim(xBairCli))
      SA1->A1_CEP     := UPPER(Alltrim(xCEPCli))
      SA1->A1_DDD     := UPPER(Alltrim(xDDDCli))
      SA1->A1_TEL     := UPPER(Alltrim(xTeleCli))
      SA1->A1_CGC     := xCGCCLI      
      SA1->A1_INSCR   := xInscCli
      SA1->A1_PAIS    := "105"
      SA1->A1_CODPAIS := "01058"
      SA1->A1_EMAIL   := xEmaiCli
      SA1->A1_NATUREZ := "10101"
      SA1->A1_GRPTRIB := IIF(UPPER(ALLTRIM(xInscCli)) == "ISENTO", "003", "002")
      SA1->A1_RISCO   := "E"
      SA1->A1_CONTRIB := UPPER(ALLTRIM(xContrib))
      SA1->A1_VEND    := UPPER(Alltrim(xCodVen1))
      SA1->A1_NCONT   := UPPER(Alltrim(xContCli))
      Msunlock()

      // ##############################
      // Inclui o contato do cliente ##
      // ##############################

      // #######################################################
      // Pesquisa o próximo código de contato a ser utilizado ##
      // #######################################################
      Cod_Contato := NEWNUMCONT()

      DbSelectArea("SU5")
      RecLock("SU5",.T.)
      U5_FILIAL  := ""
      U5_CODCONT := Cod_Contato
      U5_CONTAT  := UPPER(Alltrim(xContCli))
      U5_DDD     := UPPER(Alltrim(xDDDCli))
      U5_FONE    := UPPER(Alltrim(xTeleCli))
      U5_FCOM1   := UPPER(Alltrim(xTeleCli))
      U5_EMAIL   := xEmaiCli
      U5_NIVEL   := "08"
      U5_ATIVO   := "1"
      U5_STATUS  := "2"
      U5_TIPO    := "3"
      Msunlock()

      // #######################################
      // Cadastra o Vínculo Contato X Cliente ##
      // #######################################
      DbSelectArea("AC8")
      RecLock("AC8",.T.)
      AC8_FILIAL  := ""
      AC8_FILENT := ""       
      AC8_ENTIDA := "SA1"
      AC8_CODENT := Alltrim(cCodigo) + Alltrim(cLoja)
      AC8_CODCON := Cod_Contato
      Msunlock()

   Else
   
      cCodigo := T_CLIENTE->A1_COD
      cLoja   := T_CLIENTE->A1_LOJA
   
      _Juridico := IIF(Len(Alltrim(xCGCCli)) == 14, "S", "N")
      
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
   cSql += " WHERE E4_DESCRI = '" + Alltrim(xCodCon) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONDICAO", .T., .T. )

   nCodigoCond := IIF(T_CONDICAO->( EOF() ), "", T_CONDICAO->E4_CODIGO)

   // ###############################################
   // Pesquisa o próximo código de pedido de venda ##
   // ###############################################
   cNumPed := GetSX8Num("SC5","C5_NUM")

   // ##########################################################
   // Cria array com os dados do cabeçalho do pedido de venda ##
   // ##########################################################
   aAdd(_aCabec,{"C5_FILIAL" , xCodFil          , Nil}) // Número do Pedido de Venda
   aAdd(_aCabec,{"C5_NUM"    , cNumPed          , Nil}) // Número do Pedido de Venda
   aAdd(_aCabec,{"C5_ZPNUV"  , xProposta        , Nil}) // Código da proposta do SaleMachine
   aAdd(_aCabec,{"C5_TIPO"   , "N"              , Nil}) // Tipo do Pedido de Venda
   aAdd(_aCabec,{"C5_CLIENTE", cCodigo          , Nil}) // Codigo do Cliente
   aAdd(_aCabec,{"C5_LOJACLI", cLoja            , Nil}) // Loja do Cliente
   aAdd(_aCabec,{"C5_CLIENT" , cCodigo          , Nil}) // Codigo do Cliente de Entrega
   aAdd(_aCabec,{"C5_LOJAENT", cLoja            , Nil}) // Loja do Cliente de Entrega
   aAdd(_aCabec,{"C5_TIPOCLI", "F"              , Nil}) // Tipo do Cliente
   aAdd(_aCabec,{"C5_CONDPAG", nCodigoCond      , Nil}) // Condição de Pagamento
   aAdd(_aCabec,{"C5_EMISSAO", dDatabase        , Nil}) // Data de Emissao
   aAdd(_aCabec,{"C5_MOEDA"  , Int(Val(xCodMoe)), Nil}) // Moeda
   aAdd(_aCabec,{"C5_EXTERNO", xTipPed          , Nil}) // Tipo de Pedido de Venda (Interno/Externo)
   aAdd(_aCabec,{"C5_FORMA"  , xFormaPG         , Nil}) // Forma de Pagamento

   // #####################################################################################
   // Grava o código da Administradora de cartões se condição de pagamento for de cartão ##
   // #####################################################################################
   If !Empty(Alltrim(xCodAdm))
      aAdd(_aCabec,{"C5_ADM"    , xCodAdm          , Nil}) // Administradora de Cartões
   Endif   

   aAdd(_aCabec,{"C5_VEND1"  , xCodVen1         , Nil}) // Código do Vendedor 1  
   aAdd(_aCabec,{"C5_TIPLIB" , "1"              , Nil}) // Tipo de Liberação do Pedido (1 = Por Item)
   aAdd(_aCabec,{"C5_TPFRETE", xTipFre          , Nil}) // Tipo do frete

   // ###############################################################
   // Grava o código da transportadora se foi passado no parâmetro ##
   // ###############################################################
   If !Empty(Alltrim(xCodTra))
      aAdd(_aCabec,{"C5_TRANSP" , xCodTra          , Nil}) // Código da transportadora
   Endif   

   aAdd(_aCabec,{"C5_FRETE"  , VAL(xValFre)     , Nil}) // Valor do frete

   // ###########################################################
   // Grava o código do vendedor 2 se foi passado no parâmetro ##
   // ###########################################################
   If !Empty(Alltrim(xCodVen2))
      aAdd(_aCabec,{"C5_VEND2", xCodVen2 , Nil}) // Código do Vendedor 2  
   Endif
 
   // ##################################################################################
   // Grava o código/loja do distribuidor em caso de pedido de venda de intermediação ##
   // ##################################################################################
   If Alltrim(xTipPed) == "1"
      aAdd(_aCabec,{"C5_FORNEXT", xForExt          , Nil}) // Código do fornecedor externo (Distribuidor)
      aAdd(_aCabec,{"C5_LOJAEXT", xLojExt          , Nil}) // Loja do fornecedor externo (Distribuidor)
   Endif   

   // #########################################################
   // Cria o array com os dados dos itens do pedido de venda ##
   // #########################################################
   For nContar = 1 to U_P_OCCURS(xCodPro, "|", 1)
   
       // ###################################################
       // Pesquisa o TES correspondente ao cliente/produto ##
       // ###################################################
       If xTipPed == "1"
          kTES := "543"
       Else   
          Do Case
             Case _Juridico == "S" .And. Upper(Alltrim(xInscCli)) <> "ISENTO"
                  kTES := MaTesInt(2, "03", cCodigo, cLoja, "C", U_P_CORTA(xCodPro,"|", nContar))          

             Case _Juridico == "S" .And. Upper(Alltrim(xInscCli)) == "ISENTO"
                  kTES := MaTesInt(2, "02", cCodigo, cLoja, "C", U_P_CORTA(xCodPro,"|", nContar))          
       
             Case _Juridico == "N"
                  kTES := MaTesInt(2, "02", cCodigo, cLoja, "C", U_P_CORTA(xCodPro,"|", nContar))          
          EndCase        
       Endif

       // ##########################################################
       // Pesquisa a Situação Tributária do produto para gravação ##
       // ##########################################################
       xSituacao := Posicione( "SB1", 1, xFilial("SB1") + U_P_CORTA(xCodPro,"|", nContar), "B1_ORIGEM" ) + ;
                    Posicione( "SF4", 1, xFilial("SF4") + kTES                           , "F4_SITTRIB")

       // ###############################
       // Carrega o array dos produtos ##
       // ###############################
       aAdd(_aItens, {{"C6_FILIAL" , xCodFil                                                                                     , Nil},; // Número do item no pedido
                      {"C6_NUM"    , cNumPed                                                                                     , Nil},; // Código do Produto
                      {"C6_ITEM"   , Strzero(nContar,02)                                                                         , Nil},; // Código do Produto
                      {"C6_PRODUTO", Alltrim(U_P_CORTA(xCodPro,"|", nContar))                                                    , Nil},; // Código do Produto
                      {"C6_UM"     , Alltrim(Posicione( "SB1", 1, xFilial("SB1") + U_P_CORTA(xCodPro,"|", nContar), "B1_UM" ))   , Nil},; // Unidade de medida (primeira)
                      {"C6_QTDVEN" , VAL(U_P_CORTA(xQtdPro,"|", nContar))                                                        , Nil},; // Quantidade vendida do produto
                      {"C6_PRCVEN" , VAL(U_P_CORTA(xPrcPro,"|", nContar))                                                        , Nil},; // Preco venda do produto
                      {"C6_PRUNIT" , VAL(U_P_CORTA(xPrcPro,"|", nContar))                                                        , Nil},; // Preco unitario
                      {"C6_VALOR"  , VAL(U_P_CORTA(xTotPro,"|", nContar))                                                        , Nil},; // Valor total do produto
                      {"C6_TES"    , kTES                                                                                        , Nil},; // Tipo de entrada/saída do produto
                      {"C6_CF"     , Alltrim(Posicione( "SF4", 1, xFilial("SSF4") + kTES, "F4_CF"))                              , Nil},; // Classificação fiscal do produto pela tes
                      {"C6_LOCAL"  , "01"                                                                                        , Nil},; // Almoxarifado 
                      {"C6_CLI"    , cCodigo                                                                                     , Nil},; // Código do cliente 
                      {"C6_LOJA"   , cLoja                                                                                       , Nil},; // Loja do cliente
                      {"C6_COMIS1" , VAL(xComis1)                                                                                , Nil},; // % comissão vendedor 1
                      {"C6_COMIS2" , VAL(xComis2)                                                                                , Nil},; // % comissão vendedor 2
                      {"C6_ENTREG" , dDataBase                                                                                   , Nil},; // Data da entrega
                      {"C6_SUGENTR", dDataBase                                                                                   , Nil},; // Data de sugestão de entrega
                      {"C6_DESCRI" , Alltrim(Posicione( "SB1", 1, xFilial("SB1") + U_P_CORTA(xCodPro,"|", nContar), "B1_DESC"))  , Nil},; // Descrição do produto
                      {"C6_PARNUM" , Alltrim(Posicione( "SB1", 1, xFilial("SB1") + U_P_CORTA(xCodPro,"|", nContar), "B1_PARNUM")), Nil},; // Partnumber do produto
                      {"C6_CODFAB" , Posicione( "SB1", 1, xFilial("SB1") + U_P_CORTA(xCodPro,"|", nContar), "B1_PROC")           , Nil},; // Código do fabricante
                      {"C6_LOJAFA" , Posicione( "SB1", 1, xFilial("SB1") + U_P_CORTA(xCodPro,"|", nContar), "B1_LOJPROC")        , Nil},; // Loja do fabricante
                      {"C6_CLASFIS", xSituacao                                                                                   , Nil},; // Situação tributária do poroduto
                      {"C6_STATUS" , "01"                                                                                        , Nil},; // Status do produto 01 - Aguardando liberação
                      {"C6_TEMDOC" , "N"                                                                                         , Nil},; // Indica se qguarda documentação do cliente
                      {"C6_RATEIO" , "2"                                                                                         , Nil},; // Rateio
                      {"C6_TPOP"   , "F"                                                                                         , Nil}}) // Tipo de ordem de produção

   Next nContar
      
   MsgAlert(cNumPed)
 
   // ##############################################################
   // Executa o comando de inclusão automática do pedido de venda ##
   // ##############################################################
   nModulo := 5
   MsExecAuto({|x, y, z| MATA410(x, y, z)}, _aCabec, _aItens, 3) 

   If lMsErroAuto
      //MsgAlert("042 - Erro ao gravar o pedido de venda")
      MostraErro()
      Return(.T.)
   Else
      MsgAlert("000 - " + Alltrim(cNumPed))
      Return(.T.)
   EndIf

Return(.T.)        

// ------------------------------------------------------------------------------------------------------------------------------------------------------- ##
// Parâmetros para testar o web service                                                                                                                    ##
// ------------------------------------------------------------------------------------------------------------------------------------------------------- ##
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