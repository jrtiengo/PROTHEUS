#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"

// ####################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                             ##
// --------------------------------------------------------------------------------  ##
// Referencia: AT_CUSTOSM.PRW                                                        ##
// Parâmetros: Nenhum                                                                ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                       ##
// --------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                               ##
// Data......: 21/06/2017                                                            ##
// Objetivo..: Web Service que gera o cálculo de custo do Sale Machine para produtos ##
//             tos que ainda não estão em estoque.                                   ##
// Parâmetros: cCodProduto   = Código do Produto a ser calculado                     ##
//             cCustoInicial = Custo Inicial para cálculo do Custo do Produto        ##
//             cTipoCalculo  = Indica que o cálculo do custo é para produto novo     ##
// Exemplo de chamada da url                                                         ## 
//                                                                                   ##
// http://54.94.245.225:8095/rest/AT_CUSTOSM?cCodProduto=005599&cCustoInicial=738.56 ##
//                                                                                   ##
// ?cCodEmpresa=01        -> Código da Empresa a ser gerado o cálculo                ##
// &cCodFilial=01         -> Código da Filial a ser gerado o cálculo                 ##
// &cCodProduto=003102    -> Código do Produto a ser calculado                       ##
// &cCustoInicial=1000.00 -> Custo Inicial para cálculo do custo do produto          ##
// &dDataEstoque          -> Previsão de Estoque                                     ##
//                                                                                   ##   
// ####################################################################################

WSRESTFUL AT_CUSTOSM DESCRIPTION "Advpl Tools - Service Custo Sale Machine"

    WSDATA cCodEmpresa   AS STRING // Código da Empresa que será gerado o cálculo
    WSDATA cCodFilial    AS STRING // Código da Filial que será gerado o cálculo
    WSDATA cCodProduto   AS STRING // Código do Produto a ser Calculado
    WSDATA cCustoInicial AS STRING // Custo Inicial a ser considerado
    WSDATA dDataEstoque  AS STRING // Data Prevista de Estoque

	WSMETHOD GET DESCRIPTION "Advpl Tools - Service Custo Sale Machine" WSSYNTAX "/AT_CUSTOSM || /AT_CUSTOSM/{cCodEmpresa}{cCodFilial}{cCodProduto}{cCustoInicial}{dDataEstoque}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE cCodEmpresa, cCodFilial, cCodProduto, cCustoInicial, dDataEstoque WSSERVICE AT_CUSTOSM

   Local cSql          := ""
   Local xCodEmpresa   := Self:cCodEmpresa
   Local xCodFilial    := Self:cCodFilial
   Local xCodProduto   := Self:cCodProduto
   Local xCustoInicial := Val(Self:cCustoInicial)
   Local xDataEstoque  := Self:dDataEstoque
   Local cString       := ""

   cSql          := ""
   xCodEmpresa   := Self:cCodEmpresa
   xCodFilial    := Self:cCodFilial
   xCodProduto   := Self:cCodProduto
   xCustoInicial := Val(Self:cCustoInicial)
   xDataEstoque  := Self:dDataEstoque
   cString       := ""

   Conout("=================================================")
   Conout("==        Parametros recebidos pela URL        ==")
   Conout("=================================================")
   Conout("Codigo da Empresa........: " + xCodEmpresa)
   Conout("Codigo da Filial.........: " + xCodFilial)                                                      
   Conout("Codigo do Produto........: " + xCodProduto)
   Conout("Custo Inicial do Produto.: " + Str(xCustoInicial,10,02))
   Conout("Data prevista Estoque....: " + xDataestoque)

   // #############################################################################################################################
   // Tabela de Retornos                                                                                                         ##
   // -------------------------------------------------------------------------------------------------------------------------- ##
   // 000 - Custo de Produto calculado com sucesso                                                                               ##
   // 001 - Código do Produto a ser calculo não recebido                                                                         ##
   // 002 - Custo Inicial para cálculo do custo do produto não recebido                                                          ##
   // 003 - Parâmetros do SalesMachine não definidos no parametrizados Automatech. Entre em contato com o Administrador          ##
   // 004 - Filial da proposta comercial modelo para cálculo do SalesMachine não definida. Entre em contato com o Adfministrador ##
   // 005 - Proposta comercial modelo para cálculo do SalesMachine não definida. Entre em contato com o Administrador            ##
   // 006 - Cliente modelo para cálculo do SalesMachine não definido. Entre em contato com o Administrador                       ##
   // 007 - Loja do Cliente modelo para cálculo do SalesMachine não definido. Entre em contato com o Administrador               ##
   // 008 - Produto não localizado no Cadastro de Produtos                                                                       ##
   // 009 - Código da Empresa não recebido                                                                                       ##
   // 010 - Código da Filial não recebido                                                                                        ##
   // 011 - Código da Empresa é inválida                                                                                         ##
   // 012 - Código da Filial é inválida                                                                                          ##   
   // 013 - Data Prevista de Estoque não recebida                                                                                ## 
   // #############################################################################################################################

   // ###################################################################################################
   // Inicializa a variável MV_RETSALE para receber o código do retorno do cálculo do custo do produto ##
   // ###################################################################################################
   putmv("MV_RETSALE", "000")

   // #####################################################
   // Verifica se o código da Empresa foi passado na URL ##
   // #####################################################
   If Empty(Alltrim(xCodEmpresa))
      Conout("009 - Código da Empresa não recebido")
      cString := "009 - Código da Empresa não recebido"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
      Return(.T.)
   Endif

   // ###########################################
   // Verifica se o código da Empresa é válido ##
   // ###########################################
   If xCodEmpresa$("01#02#03#04")
   Else
      Conout("011 - Código da Empresa é inválida")
      cString := "011 - Código da Empresa é inválida"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
      Return(.T.)
   Endif

   // ####################################################
   // Verifica se o código da Filial foi passado na URL ##
   // ####################################################
   If Empty(Alltrim(xCodFilial))
      Conout("010 - Código da Filial não recebido")
      cString := "010 - Código da Filial não recebido"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
      Return(.T.)
   Endif

   // ##########################################
   // Verifica se o código da Filial é válido ##
   // ##########################################
   Do Case
      Case xCodEmpresa == "01"

           If xCodFilial$("01#02#03#04#05#06#07")
           Else
              Conout("012 - Código da Filial é inválido")
              cString := "012 - Código da Filial é inválido"
              ::SetContentType("text/plain")
              ::SetResponse(cString)  	
              RESET ENVIRONMENT
              Return(.T.)
           Endif

      Case xCodEmpresa == "02"

           If xCodFilial <> "01"
           Else
              Conout("012 - Código da Filial é inválido")
              cString := "012 - Código da Filial é inválido"
              ::SetContentType("text/plain")
              ::SetResponse(cString)  	
              RESET ENVIRONMENT
              Return(.T.)
           Endif

      Case xCodEmpresa == "03"

           If xCodFilial <> "01"
           Else
              Conout("012 - Código da Filial é inválido")
              cString := "012 - Código da Filial é inválido"
              ::SetContentType("text/plain")
              ::SetResponse(cString)  	
              RESET ENVIRONMENT
              Return(.T.)
           Endif

      Case xCodEmpresa == "04"

           If xCodFilial <> "01"
           Else
              Conout("012 - Código da Filial é inválido")
              cString := "012 - Código da Filial é inválido"
              ::SetContentType("text/plain")
              ::SetResponse(cString)  	
              RESET ENVIRONMENT
              Return(.T.)
           Endif

   EndCase        

   // #####################################################
   // Verifica se o código do produto foi passado na URL ##
   // #####################################################
   If Empty(Alltrim(xCodProduto))
      Conout("001 - Código do Produto a ser calculado não recebido")
      cString := "001 - Código do Produto a ser calculado não recebido"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
      Return(.T.)
   Endif

   // #########################################################################
   // Verifica se o custo inicial para cálculo do produto foi passado na URL ##
   // #########################################################################
   If xCustoInicial == 0
      Conout("002 - Custo Inicial para cálculo do custo do produto não recebido")
      cString := "002 - Custo Inicial para cálculo do custo do produto não recebido"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
      Return(.T.)
   Endif

   // ############################################################
   // Verifica se a data prevista de estoque foi passada na URL ##
   // ############################################################
   If Empty(Alltrim(xDataEstoque))
      Conout("013 - Data Prevista de Estoque não recebida")
      cString := "013 - Data Prevista de Estoque não recebida"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
      Return(.T.)
   Endif

   // #######################################################
   // Verifica se o produto passado na URL está cadastrado ##
   // #######################################################
   xCodProduto := Alltrim(xCodProduto) + Space(30 - Len(Alltrim(xCodproduto)))

   // ###############################################################################
   // Seta o código da Empresa conforme parâmetro para inclusão do pedido de venda ##
   // ###############################################################################
   PREPARE ENVIRONMENT EMPRESA xCodEmpresa FILIAL xCodFilial USER 'Administrador' PASSWORD '@tech15010' TABLES "SC5","SC6","SA1","SA2","SB1","SB2","SF4" MODULO 'FAT'

   XALTEMPFIL(xCodEmpresa, xCodFilial)

   If (Select( "T_PRODUTO" ) != 0 )
      T_PRODUTO->( DbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT B1_COD "
   cSql += "  FROM " + RetSqlName("SB1")
   cSql += " WHERE B1_COD     = '" + Alltrim(xCodProduto) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PRODUTO",.T.,.T.)

   If T_PRODUTO->( EOF() )
      Conout("008 - Produto não localizado no Cadastro de Produtos")
      cString := "008 - Produto não localizado no Cadastro de Produtos"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
      Return(.T.)
   Endif

   // #############################################################
   // Envia para o prodgrama que calcula o custo do Sale Machine ##
   // #############################################################
   U_AUTOM525(xCodProduto, xCustoInicial, xDataEstoque, 0) 

   If GetMv("MV_RETSALE") == "000"
      Conout("Cálculo realizado com sucesso.")
      cString := "000 - Cálculo realizado com sucesso."
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
   Endif

Return(.T.)

// ############################################################################
// Função que seta a Empresa e Filial conforme parâmetros recebidos pela URL ##
// ############################################################################
Static Function XALTEMPFIL(K_Empresa, k_Filial)

   Local cEmp := k_Empresa
   Local cFil := k_Filial
	
   cEmp := k_Empresa
   cFil := k_Filial

   dbcloseall()
   cempant := cEmp
   cfilant := cFil 
   cNumEmp := cEmp  + cFil
   Opensm0(cempant  + cfil)
   Openfile(cempant + cfil)
   lrefresh :=.T.
	       
Return