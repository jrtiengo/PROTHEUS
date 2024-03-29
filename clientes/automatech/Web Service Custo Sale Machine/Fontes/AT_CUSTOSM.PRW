#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"

// ####################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                             ##
// --------------------------------------------------------------------------------  ##
// Referencia: AT_CUSTOSM.PRW                                                        ##
// Par�metros: Nenhum                                                                ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                       ##
// --------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                               ##
// Data......: 21/06/2017                                                            ##
// Objetivo..: Web Service que gera o c�lculo de custo do Sale Machine para produtos ##
//             tos que ainda n�o est�o em estoque.                                   ##
// Par�metros: cCodProduto   = C�digo do Produto a ser calculado                     ##
//             cCustoInicial = Custo Inicial para c�lculo do Custo do Produto        ##
//             cTipoCalculo  = Indica que o c�lculo do custo � para produto novo     ##
// Exemplo de chamada da url                                                         ## 
//                                                                                   ##
// http://54.94.245.225:8095/rest/AT_CUSTOSM?cCodProduto=005599&cCustoInicial=738.56 ##
//                                                                                   ##
// ?cCodEmpresa=01        -> C�digo da Empresa a ser gerado o c�lculo                ##
// &cCodFilial=01         -> C�digo da Filial a ser gerado o c�lculo                 ##
// &cCodProduto=003102    -> C�digo do Produto a ser calculado                       ##
// &cCustoInicial=1000.00 -> Custo Inicial para c�lculo do custo do produto          ##
// &dDataEstoque          -> Previs�o de Estoque                                     ##
//                                                                                   ##   
// ####################################################################################

WSRESTFUL AT_CUSTOSM DESCRIPTION "Advpl Tools - Service Custo Sale Machine"

    WSDATA cCodEmpresa   AS STRING // C�digo da Empresa que ser� gerado o c�lculo
    WSDATA cCodFilial    AS STRING // C�digo da Filial que ser� gerado o c�lculo
    WSDATA cCodProduto   AS STRING // C�digo do Produto a ser Calculado
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
   // 001 - C�digo do Produto a ser calculo n�o recebido                                                                         ##
   // 002 - Custo Inicial para c�lculo do custo do produto n�o recebido                                                          ##
   // 003 - Par�metros do SalesMachine n�o definidos no parametrizados Automatech. Entre em contato com o Administrador          ##
   // 004 - Filial da proposta comercial modelo para c�lculo do SalesMachine n�o definida. Entre em contato com o Adfministrador ##
   // 005 - Proposta comercial modelo para c�lculo do SalesMachine n�o definida. Entre em contato com o Administrador            ##
   // 006 - Cliente modelo para c�lculo do SalesMachine n�o definido. Entre em contato com o Administrador                       ##
   // 007 - Loja do Cliente modelo para c�lculo do SalesMachine n�o definido. Entre em contato com o Administrador               ##
   // 008 - Produto n�o localizado no Cadastro de Produtos                                                                       ##
   // 009 - C�digo da Empresa n�o recebido                                                                                       ##
   // 010 - C�digo da Filial n�o recebido                                                                                        ##
   // 011 - C�digo da Empresa � inv�lida                                                                                         ##
   // 012 - C�digo da Filial � inv�lida                                                                                          ##   
   // 013 - Data Prevista de Estoque n�o recebida                                                                                ## 
   // #############################################################################################################################

   // ###################################################################################################
   // Inicializa a vari�vel MV_RETSALE para receber o c�digo do retorno do c�lculo do custo do produto ##
   // ###################################################################################################
   putmv("MV_RETSALE", "000")

   // #####################################################
   // Verifica se o c�digo da Empresa foi passado na URL ##
   // #####################################################
   If Empty(Alltrim(xCodEmpresa))
      Conout("009 - C�digo da Empresa n�o recebido")
      cString := "009 - C�digo da Empresa n�o recebido"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
      Return(.T.)
   Endif

   // ###########################################
   // Verifica se o c�digo da Empresa � v�lido ##
   // ###########################################
   If xCodEmpresa$("01#02#03#04")
   Else
      Conout("011 - C�digo da Empresa � inv�lida")
      cString := "011 - C�digo da Empresa � inv�lida"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
      Return(.T.)
   Endif

   // ####################################################
   // Verifica se o c�digo da Filial foi passado na URL ##
   // ####################################################
   If Empty(Alltrim(xCodFilial))
      Conout("010 - C�digo da Filial n�o recebido")
      cString := "010 - C�digo da Filial n�o recebido"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
      Return(.T.)
   Endif

   // ##########################################
   // Verifica se o c�digo da Filial � v�lido ##
   // ##########################################
   Do Case
      Case xCodEmpresa == "01"

           If xCodFilial$("01#02#03#04#05#06#07")
           Else
              Conout("012 - C�digo da Filial � inv�lido")
              cString := "012 - C�digo da Filial � inv�lido"
              ::SetContentType("text/plain")
              ::SetResponse(cString)  	
              RESET ENVIRONMENT
              Return(.T.)
           Endif

      Case xCodEmpresa == "02"

           If xCodFilial <> "01"
           Else
              Conout("012 - C�digo da Filial � inv�lido")
              cString := "012 - C�digo da Filial � inv�lido"
              ::SetContentType("text/plain")
              ::SetResponse(cString)  	
              RESET ENVIRONMENT
              Return(.T.)
           Endif

      Case xCodEmpresa == "03"

           If xCodFilial <> "01"
           Else
              Conout("012 - C�digo da Filial � inv�lido")
              cString := "012 - C�digo da Filial � inv�lido"
              ::SetContentType("text/plain")
              ::SetResponse(cString)  	
              RESET ENVIRONMENT
              Return(.T.)
           Endif

      Case xCodEmpresa == "04"

           If xCodFilial <> "01"
           Else
              Conout("012 - C�digo da Filial � inv�lido")
              cString := "012 - C�digo da Filial � inv�lido"
              ::SetContentType("text/plain")
              ::SetResponse(cString)  	
              RESET ENVIRONMENT
              Return(.T.)
           Endif

   EndCase        

   // #####################################################
   // Verifica se o c�digo do produto foi passado na URL ##
   // #####################################################
   If Empty(Alltrim(xCodProduto))
      Conout("001 - C�digo do Produto a ser calculado n�o recebido")
      cString := "001 - C�digo do Produto a ser calculado n�o recebido"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
      Return(.T.)
   Endif

   // #########################################################################
   // Verifica se o custo inicial para c�lculo do produto foi passado na URL ##
   // #########################################################################
   If xCustoInicial == 0
      Conout("002 - Custo Inicial para c�lculo do custo do produto n�o recebido")
      cString := "002 - Custo Inicial para c�lculo do custo do produto n�o recebido"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
      Return(.T.)
   Endif

   // ############################################################
   // Verifica se a data prevista de estoque foi passada na URL ##
   // ############################################################
   If Empty(Alltrim(xDataEstoque))
      Conout("013 - Data Prevista de Estoque n�o recebida")
      cString := "013 - Data Prevista de Estoque n�o recebida"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
      Return(.T.)
   Endif

   // #######################################################
   // Verifica se o produto passado na URL est� cadastrado ##
   // #######################################################
   xCodProduto := Alltrim(xCodProduto) + Space(30 - Len(Alltrim(xCodproduto)))

   // ###############################################################################
   // Seta o c�digo da Empresa conforme par�metro para inclus�o do pedido de venda ##
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
      Conout("008 - Produto n�o localizado no Cadastro de Produtos")
      cString := "008 - Produto n�o localizado no Cadastro de Produtos"
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
      Conout("C�lculo realizado com sucesso.")
      cString := "000 - C�lculo realizado com sucesso."
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      RESET ENVIRONMENT
   Endif

Return(.T.)

// ############################################################################
// Fun��o que seta a Empresa e Filial conforme par�metros recebidos pela URL ##
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