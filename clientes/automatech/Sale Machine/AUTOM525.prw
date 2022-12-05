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
// Referencia: AUTOM525.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Gatilho                                               ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 04/01/2017                                                              ##
// Objetivo..: Programa que gera o cálculo do SalesMachine para os produtos após a     ##
//             gravação do documento de entrada.                                       ##
// Parâmetros: cProduto     - Código do produto a ser calculado.                       ##
//             cCustoIni    - Custo Inicial para cálculo via Web Service               ##
//             cDtaEstoque  - Data Prevista de estoque                                 ##
//             cTipoCalculo - Tipo de Cálculo de Custo onde:                           ##
//                            0 - Cálculo Via Web Service                              ##
//                            1 - Cálculo via rotinas do Protheus                      ##
// ######################################################################################

User Function AUTOM525(K_Produto, k_Custo, k_DtaEstoque, k_TipoCalc)

   Local cSql           := ""
   Local kFilial        := ""
   Local kProposta      := ""
   Local kCliente       := ""
   Local kLojaCli       := ""
   Local kRevisao       := "01"
   Local nContar        := 0
   Local xTotalProposta := 0
   Local nTaxaD         := 0
   Local nFreteProposta := 0
   Local nTProduto      := 0
   Local nContar        := 0
   Local cString        := ""
   Local lPertence      := .F.
   Local nPertence      := 0
   Local k_Grupo01      := ""
   Local k_Grupo02      := ""
   Local k_TipoPsq      := ""

   Local aEstados       := {}
   Local aCabecalho     := {}
   Local aProdutos      := {}
   Local aCalcular      := {}
   Local _aQtdRolo      := {}
   
   Local cTxPIS         := 0
   Local cTxCofins      := 0

   Local cTempoIni      := Time()
   Local lCalcula       := .T.

   // ###################################################################################################
   // Prepara o código do produto ou código dos grupos para cálculo                                    ##
   // O cálculo pode ser realizado de duas maneiras, individual ou por intervalo de grupos de produtos ##
   // ###################################################################################################
   If U_P_OCCURS(K_Produto, "|", 1) == 0
      If Len(K_Produto) < 30
         k_Produto := Alltrim(k_Produto) + Space(30 - Len(Alltrim(K_Produto)))
      Endif
   Else
      k_Grupo01 := U_P_CORTA(k_Produto, "|", 1)
      k_Grupo02 := U_P_CORTA(k_Produto, "|", 2)         

      If Len(Alltrim(k_Grupo01)) >= 17
         k_TipoPsq := "P"
      Else
         k_TipoPsq := "G"         
      Endif   

   Endif

   // ###################################
   // Carrega as taxas de Pis e Cofins ##
   // ###################################
   cTxPIS    := GetMv("MV_TXPIS")
   cTxCofins := GetMv("MV_TXCOFIN")

   // ################################################################################
   // Pesquisa o código da Filial e Proposta Comercial parametrizada para o cálculo ##
   // ################################################################################
   If (Select( "T_PARAMETROS" ) != 0 )
      T_PARAMETROS->( DbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FPRO,"
   cSql +=  "      ZZ4_PCOM,"
   cSql += "       ZZ4_COPE,"
   cSql += "       ZZ4_LOPE,"
   cSql += "       ZZ4_OEMP,"
   cSql += "       ZZ4_OARQ "
   cSql += "  FROM " + RetSqlName("ZZ4") + "(NoLock)"
   cSql += " WHERE D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PARAMETROS",.T.,.T.)

   // #########################################################
   // Gera as consistência sobre o parametrizador Automatech ##
   // #########################################################
   If T_PARAMETROS->( EOF() )
      If k_TipoCalc == 0
         putmv("MV_RETSALE", "003")
      Else
         MsgAlert("Parâmetros do SalesMachine não definidos no parametrizados Automatech. Entre em contato com o Administrador." )
      Endif   
      Return(.T.)
   Endif
         
   If Empty(Alltrim(T_PARAMETROS->ZZ4_FPRO))
      If k_TipoCalc == 0
         putmv("MV_RETSALE", "004")
      Else
         MsgAlert("Filial da proposta comercial modelo para cálculo do SalesMachine não definida. Entre em contato com o Adfministrador." )
      Endif   
      Return(.T.)
   Endif
      
   If Empty(Alltrim(T_PARAMETROS->ZZ4_PCOM))
      If k_TipoCalc == 0
         putmv("MV_RETSALE", "005")
      Else
         MsgAlert("Proposta comercial modelo para cálculo do SalesMachine não definida. Entre em contato com o Administrador." )
      Endif
      Return(.T.)
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_COPE))
      If k_TipoCalc == 0
         putmv("MV_RETSALE", "006")
      Else
         MsgAlert("Cliente modelo para cálculo do SalesMachine não definido. Entre em contato com o Administrador." )
      Endif   
      Return(.T.)
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_LOPE))
      If k_TipoCalc == 0
         putmv("MV_RETSALE", "007")
      Else
         MsgAlert("Loja do Cliente modelo para cálculo do SalesMachine não definido. Entre em contato com o Administrador." )
      Endif   
      Return(.T.)
   Endif

// If Empty(Alltrim(T_PARAMETROS->ZZ4_OEMP))
//    MsgAlert("Empresas/Filiais a serem utilizadas para cálculo do SalesMachine não definidas. Entre em contato com o Administrador." )
//    Return(.T.)
// Endif

   // ####################################################
   // Carrega as variáveis do Parametrizador Automatech ##
   // ####################################################
   // kFilial   := T_PARAMETROS->ZZ4_FPRO
   kFilial   := cFilAnt
   kProposta := T_PARAMETROS->ZZ4_PCOM
   kCliente  := T_PARAMETROS->ZZ4_COPE
   kLojaCli  := T_PARAMETROS->ZZ4_LOPE

   Do Case

      Case cEmpAnt == "01"
           // kFilial   := T_PARAMETROS->ZZ4_FPRO
           kFilial   := cFilAnt
           kProposta := T_PARAMETROS->ZZ4_PCOM

      Case cEmpAnt == "02"
           //kFilial   := "01"
           kFilial   := cFilAnt
           kProposta := "000297"

      Case cEmpAnt == "03"
           //kFilial   := "01"
           kFilial   := cFilAnt
           kProposta := "000297"

      Case cEmpAnt == "04"
           //kFilial   := "01"
           kFilial   := cFilAnt
           kProposta := "000297"

   EndCase

   // ###########################################################################
   // Carrega o array aCalcular com os códigos dos produtos a serem calculados ##
   // ###########################################################################

   // ################################################################################################
   // Carrega o array aCalcula. Este array contém os produtos envolvidos no cálculo do SalesMachine ##
   // ################################################################################################
   
   // ###########################################################################
   // Verifica se o produto passado no parâmetro já está contido na tabela ZTP ##
   // ###########################################################################
   If U_P_OCCURS(k_Produto, "|", 1) == 0

      If (Select( "T_JAEXISTE" ) != 0 )
         T_JAEXISTE->( DbCloseArea() )
      EndIf
  
      cSql := ""
      cSql := "SELECT ZTP_FILIAL,"	
      cSql += "       ZTP_EMPR	,"
      cSql += "       ZTP_PROD	 "
      cSql += "  FROM ZTP010 (NoLock)"
      cSql += " WHERE ZTP_PROD   = '" + Alltrim(K_Produto) + "'"
      cSql += "   AND ZTP_EMPR   = '" + Alltrim(cEmpAnt)   + "'"
      cSql += "   AND ZTP_FILIAL = '" + Alltrim(cFilAnt)   + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_JAEXISTE",.T.,.T.)

      lExiste := IIF(T_JAEXISTE->( EOF() ), "N", "S")

      aAdd( aCalcular, { K_Produto                                                  ,; // 01 - Código do Produto
                         POSICIONE("SB1",1,XFILIAL("SB1") + K_Produto, "B1_DESC"  ) ,; // 02 - Descrição do Produto
                         POSICIONE("SB1",1,XFILIAL("SB1") + K_Produto, "B1_DAUX"  ) ,; // 03 - Descrição Auxiliar do Produto
                         POSICIONE("SB1",1,XFILIAL("SB1") + K_Produto, "B1_PARNUM") ,; // 04 - Part Number do Produto
                         POSICIONE("SB1",1,XFILIAL("SB1") + K_Produto, "B1_UM"    ) ,; // 05 - Unidade de Medida do Produto
                         lExiste                                                 })    // 06 - Indica se produto já está contido na tabela do SalesMachine

   Else

      If (Select( "T_JAEXISTE" ) != 0 )
         T_JAEXISTE->( DbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SB1.B1_COD ,"
      cSql += "       CASE WHEN (SELECT TOP(1) ZTP_PROD 
      cSql += "                    FROM " + RetSqlName("ZTP") + " (Nolock) "
      cSql += "                   WHERE ZTP_PROD       = SB1.B1_COD "
      cSql += "                     AND ZTP_EMPR   = '" + Alltrim(cEmpAnt)   + "'"
      cSql += "                     AND ZTP_FILIAL = '" + Alltrim(cFilAnt)   + "'"
      cSql += "                     AND D_E_L_E_T_ = '') IS NULL"
	  cSql += "           THEN 'N'"
      cSql += "       ELSE 'S'     "
      cSql += "       END AS TEMZTP" 
      cSql += "  FROM " + RetSqlName("SB1") + " (noLock) SB1 "
      cSql += " WHERE SB1.B1_MSBLQL <> '1'"
      cSql += "   AND SB1.D_E_L_E_T_ = '' "

      If k_TipoPsq == "G"
         cSql += "   AND SB1.B1_GRUPO  >= '" + Alltrim(k_Grupo01) + "'"
         cSql += "   AND SB1.B1_GRUPO  <= '" + Alltrim(k_Grupo02) + "'"
      Else
         cSql += "   AND SB1.B1_COD  >= '" + Alltrim(k_Grupo01) + "'"
         cSql += "   AND SB1.B1_COD  <= '" + Alltrim(k_Grupo02) + "'"
      Endif         

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_JAEXISTE",.T.,.T.)

      T_JAEXISTE->( DbGoTop() )

      WHILE !T_JAEXISTE->( EOF() )

         aAdd( aCalcular, { T_JAEXISTE->B1_COD                                                  ,; // 01 - Código do Produto
                            POSICIONE("SB1",1,XFILIAL("SB1") + T_JAEXISTE->B1_COD, "B1_DESC"  ) ,; // 02 - Descrição do Produto
                            POSICIONE("SB1",1,XFILIAL("SB1") + T_JAEXISTE->B1_COD, "B1_DAUX"  ) ,; // 03 - Descrição Auxiliar do Produto
                            POSICIONE("SB1",1,XFILIAL("SB1") + T_JAEXISTE->B1_COD, "B1_PARNUM") ,; // 04 - Part Number do Produto
                            POSICIONE("SB1",1,XFILIAL("SB1") + T_JAEXISTE->B1_COD, "B1_UM"    ) ,; // 05 - Unidade de Medida do Produto
                            T_JAEXISTE->TEMZTP                                               })    // 06 - Indica se produto já está contido na tabela do SalesMachine

         T_JAEXISTE->( DbSkip() )
         
      ENDDO                               
      
   Endif

   // ########################################################
   // Se não existirem produtos a serem calculados, retorna ##
   // ########################################################
   If Len(aCalcular) == 0
      //MsgAlert("Não foram encontrados produtos para cálculo do Sales Machine.")
      Return(.T.)
   Endif

   // #################################################################################################
   // Cria o array aEstados com os estados da federação                                              ##
   // ---------------------------------------------------------------------------------------------- ##
   // [01] - Estado             = Estado da Federação                                                ## 
   // [02] - Código Município   = Código do município (Sempre capitais)                              ##
   // [03] - CNPJ               = CNPJ (Ficticio gerado pela internet)                               ##
   // [04] - Inscrição Estadual = Inscrição Estadual (Ficticio gerado pela internet por estado)      ##
   // [05] - Grupo Tributário   = Grupo Tributário onde 002 = IE Ativa e 003 = IE Inativa            ##
   // [06] - Contribuinte       = 1 = Cliente Contribuinte e 2 - Cliente Não Contribuinte            ##
   // [07] - Destaca IE         = 1 = Destaca IE e 2 = Não destaca IE                                ##
   // [08] - Tipo de Operação   = Tipo de Operação 03 ou 03                                          ##
   // #################################################################################################
   aAdd( aEstados, { "AC", "00401", "41546936000108", "01.451.174/769-15", "002", "1", " ", "03" } )
   aAdd( aEstados, { "AC", "00401", "41546936000108", "01.451.174/769-15", "003", "2", " ", "02" } )
   aAdd( aEstados, { "AL", "04302", "41546936000108", "248245732"        , "002", "1", " ", "03" } )
   aAdd( aEstados, { "AL", "04302", "41546936000108", "248245732"        , "003", "2", " ", "02" } )
   aAdd( aEstados, { "AP", "00303", "41546936000108", "0316819811"       , "002", "1", " ", "03" } )
   aAdd( aEstados, { "AP", "00303", "41546936000108", "0316819811"       , "003", "2", " ", "02" } )
   aAdd( aEstados, { "AM", "02603", "41546936000108", "42.463.254-3"     , "002", "1", " ", "03" } )
   aAdd( aEstados, { "AM", "02603", "41546936000108", "42.463.254-3"     , "003", "2", " ", "02" } )
   aAdd( aEstados, { "BA", "27408", "41546936000108", "866487-74"        , "002", "1", " ", "03" } )      
   aAdd( aEstados, { "BA", "27408", "41546936000108", "866487-74"        , "003", "2", " ", "02" } )      
   aAdd( aEstados, { "CE", "04400", "41546936000108", "76892977-6"       , "002", "1", " ", "03" } )            
   aAdd( aEstados, { "CE", "04400", "41546936000108", "76892977-6"       , "003", "2", " ", "02" } )            
   aAdd( aEstados, { "DF", "00108", "41546936000108", "07784003001-93"   , "002", "1", " ", "03" } )                  
   aAdd( aEstados, { "DF", "00108", "41546936000108", "07784003001-93"   , "003", "2", " ", "02" } )                  
   aAdd( aEstados, { "ES", "05309", "41546936000108", "56253799-6"       , "002", "1", " ", "03" } )
   aAdd( aEstados, { "ES", "05309", "41546936000108", "56253799-6"       , "003", "2", " ", "02" } )
   aAdd( aEstados, { "GO", "08707", "41546936000108", "11.093.967-0"     , "002", "1", " ", "03" } )      
   aAdd( aEstados, { "GO", "08707", "41546936000108", "11.093.967-0"     , "003", "2", " ", "02" } )      
   aAdd( aEstados, { "MA", "00605", "41546936000108", "12346953-8"       , "002", "1", " ", "03" } )         
   aAdd( aEstados, { "MA", "00605", "41546936000108", "12346953-8"       , "003", "2", " ", "02" } )         
   aAdd( aEstados, { "MT", "03403", "41546936000108", "4521770966-4"     , "002", "1", " ", "03" } )               
   aAdd( aEstados, { "MT", "03403", "41546936000108", "4521770966-4"     , "003", "2", " ", "02" } )               
   aAdd( aEstados, { "MS", "02704", "41546936000108", "28650997-0"       , "002", "1", " ", "03" } )                     
   aAdd( aEstados, { "MS", "02704", "41546936000108", "28650997-0"       , "003", "2", " ", "02" } )                     
   aAdd( aEstados, { "MG", "06200", "41546936000108", "905.358.568/5213" , "002", "1", " ", "03" } )
   aAdd( aEstados, { "MG", "06200", "41546936000108", "905.358.568/5213" , "003", "2", " ", "02" } )
   aAdd( aEstados, { "PA", "01402", "41546936000108", "15-398792-8"      , "002", "1", " ", "03" } )      
   aAdd( aEstados, { "PA", "01402", "41546936000108", "15-398792-8"      , "003", "2", " ", "02" } )      
   aAdd( aEstados, { "PB", "07507", "41546936000108", "01162432-9"       , "002", "1", " ", "03" } )            
   aAdd( aEstados, { "PB", "07507", "41546936000108", "01162432-9"       , "003", "2", " ", "02" } )            
   aAdd( aEstados, { "PR", "06902", "41546936000108", "462.85167-70"     , "002", "1", " ", "03" } )                  
   aAdd( aEstados, { "PR", "06902", "41546936000108", "462.85167-70"     , "003", "2", " ", "02" } )                  
   aAdd( aEstados, { "PE", "11606", "41546936000108", "3967359-67"       , "002", "1", " ", "03" } )                  
   aAdd( aEstados, { "PE", "11606", "41546936000108", "3967359-67"       , "003", "2", " ", "02" } )                  
   aAdd( aEstados, { "PI", "11001", "41546936000108", "94850645-8"       , "002", "1", " ", "03" } )                  
   aAdd( aEstados, { "PI", "11001", "41546936000108", "94850645-8"       , "003", "2", " ", "02" } )                  
   aAdd( aEstados, { "RJ", "04557", "41546936000108", "24.229.33-5"      , "002", "1", " ", "03" } )                  
   aAdd( aEstados, { "RJ", "04557", "41546936000108", "24.229.33-5"      , "003", "2", " ", "02" } )                  
   aAdd( aEstados, { "RN", "08102", "41546936000108", "20.150.475-8"     , "002", "1", " ", "03" } )                  
   aAdd( aEstados, { "RN", "08102", "41546936000108", "20.150.475-8"     , "003", "2", " ", "02" } )                  
   aAdd( aEstados, { "RS", "14902", "41546936000108", "164/8444889"      , "002", "1", " ", "03" } )                  
   aAdd( aEstados, { "RS", "14902", "41546936000108", "164/8444889"      , "003", "2", " ", "02" } )                  
   aAdd( aEstados, { "RO", "00205", "41546936000108", "2208334017448-2"  , "002", "1", " ", "03" } )                  
   aAdd( aEstados, { "RO", "00205", "41546936000108", "2208334017448-2"  , "003", "2", " ", "02" } )                  
   aAdd( aEstados, { "RR", "00100", "41546936000108", "24674118-0"       , "002", "1", " ", "03" } )                  
   aAdd( aEstados, { "RR", "00100", "41546936000108", "24674118-0"       , "003", "2", " ", "02" } )                  
   aAdd( aEstados, { "SC", "05407", "41546936000108", "989.755.487"      , "002", "1", " ", "03" } )                   
   aAdd( aEstados, { "SC", "05407", "41546936000108", "989.755.487"      , "003", "2", " ", "02" } )                   
   aAdd( aEstados, { "SP", "50308", "41546936000108", "129.520.226.500"  , "002", "1", "1", "03" } )                  
   aAdd( aEstados, { "SP", "50308", "41546936000108", "129.520.226.500"  , "003", "2", " ", "02" } )                  
   aAdd( aEstados, { "SE", "00308", "41546936000108", "00640281-0"       , "002", "1", " ", "03" } )                  
   aAdd( aEstados, { "SE", "00308", "41546936000108", "00640281-0"       , "003", "2", " ", "02" } )                  
   aAdd( aEstados, { "TO", "69000", "41546936000108", "8703135823-9"     , "002", "1", " ", "03" } )                  
   aAdd( aEstados, { "TO", "69000", "41546936000108", "8703135823-9"     , "003", "2", " ", "02" } )                  

   // ####################################################################
   // Início do cálculo e gravação da tabela de Produtos para OpenChart ##
   // ####################################################################

   // ######################################################################
   // Seleciona os produtos a serem calculados para os parâmetros setados ##
   // ######################################################################
   For nCalcular = 1 to Len(aCalcular)

       // ###################################################
       // Se produto já existe na tabela ZTP, lê o próximo ##
       // ###################################################
       If aCalcular[nCalcular,06] == "S"
          Loop
       Endif

      // ##############################################
      // Calcula o Custo para os estado da federação ##
      // ##############################################

      // #############################################
      // k_TipoCalc == 0 = Chamado pelo Web Service ##
      // #############################################
      If k_TipoCalc == 0 

         For nContar = 1 to Len(aEstados)

             GravaTabOpen( cEmpAnt                                                                   ,; // 01 - Código da Empresa
                           cFilAnt                                                                   ,; // 02 - Código da Filial
                           aCalcular[nCalcular,01]                                                   ,; // 03 - Código do Produto
                           Alltrim(aCalcular[nCalcular,02]) + " " + Alltrim(aCalcular[nCalcular,03]) ,; // 04 - Descrição do Produto
                           Alltrim(aCalcular[nCalcular,04])                                          ,; // 05 - Part Number
                           aEstados[nContar,01]                                                      ,; // 06 - Estado
                           aEstados[nContar,05]                                                      ,; // 05 - Grupo Tributário
                           k_Custo                                                                   ,; // 06 - Custo Médio Inicial do Produto
                           kFilial                                                                   ,; // 07 - Filial da Proposta Comercial Modelo
                           kProposta                                                                 ,; // 08 - Nº da Proposta Comercial Modelo                                                                
                           kCliente                                                                  ,; // 09 - Código do Cliente
                           kLojaCli                                                                  ,; // 10 - Loja do cliente 
                           aEstados[nContar,03]                                                      ,; // 11 - CNPJ do Cliente
                           aEstados[nContar,04]                                                      ,; // 12 - Inscrição Estadual do Cliente
                           aEstados[nContar,06]                                                      ,; // 13 - Cliente Contribuinte
                           aEstados[nContar,07]                                                      ,; // 14 - Destaca IE
                           aEstados[nContar,08]                                                      ,; // 15 - Tipo de Operação
                           aEstados[nContar,02])                                                        // 16 - Tipo de Operação

         Next nContar

      Else                       

         For nContar = 1 to Len(aEstados)

             // ############################################################################## 
             // Verifica se produto lido possui custo.                                      ##
             // Se não existir, somente registra o produto na tabela e lê o próximo produto ##
             // ##############################################################################
             If (Select( "T_SALDO" ) != 0 )
                T_SALDO->( DbCloseArea() )
             EndIf

             cSql := ""
             cSql := "SELECT B2_FILIAL,"
             cSql += "       B2_COD   ,"
             cSql += "       B2_LOCAL ,"
     	     cSql += "       B2_CM1    "
             cSql += "  FROM SB2" + Alltrim(cEmpAnt) + "0" + "(NoLock)"
             cSql += " WHERE B2_FILIAL  = '" + Alltrim(cFilAnt)                 + "'"
             cSql += "   AND B2_COD     = '" + Alltrim(aCalcular[nCalcular,01]) + "'"
             cSql += "   AND B2_LOCAL   = '01'"
             cSql += "   AND D_E_L_E_T_ = ''  "
         
             cSql := ChangeQuery( cSql )
             dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_SALDO",.T.,.T.)

             // ###############################################
             // Verifica se produto possui registro de saldo ##
             // ###############################################
             If T_SALDO->( EOF() )
                GravaTabOpen( cEmpAnt                                                                   ,; // 01 - Código da Empresa
                              cFilAnt                                                                   ,; // 02 - Código da Filial
                              aCalcular[nCalcular,01]                                                   ,; // 03 - Código do Produto
                              Alltrim(aCalcular[nCalcular,02]) + " " + Alltrim(aCalcular[nCalcular,03]) ,; // 04 - Descrição do Produto
                              Alltrim(aCalcular[nCalcular,04])                                          ,; // 05 - Part Number
                              aEstados[nContar,01]                                                      ,; // 06 - Estado
                              aEstados[nContar,05]                                                      ,; // 05 - Grupo Tributário
                              0                                                                         ,; // 06 - Custo Médio do Produto
                              kFilial                                                                   ,; // 07 - Filial da Proposta Comercial Modelo
                              kProposta                                                                 ,; // 08 - Nº da Proposta Comercial Modelo                                                                
                              kCliente                                                                  ,; // 09 - Código do Cliente
                              kLojaCli                                                                  ,; // 10 - Loja do cliente 
                              aEstados[nContar,03]                                                      ,; // 11 - CNPJ do Cliente
                              aEstados[nContar,04]                                                      ,; // 12 - Inscrição Estadual do Cliente
                              aEstados[nContar,06]                                                      ,; // 13 - Cliente Contribuinte
                              aEstados[nContar,07]                                                      ,; // 14 - Destaca IE
                              aEstados[nContar,08]                                                      ,; // 15 - Tipo de Operação
                              aEstados[nContar,02])                                                        // 16 - Tipo de Operação
                Loop
             Endif   

             // #########################################
             // Verifica se produto possui custo médio ##
             // #########################################
             If T_SALDO->B2_CM1 == 0
                GravaTabOpen( cEmpAnt                                                                  ,; // 01 - Código da Empresa
                              cFilAnt                                                                   ,; // 02 - Código da Filial
                              aCalcular[nCalcular,01]                                                   ,; // 03 - Código do Produto
                              Alltrim(aCalcular[nCalcular,02]) + " " + Alltrim(aCalcular[nCalcular,03]) ,; // 04 - Descrição do Produto
                              Alltrim(aCalcular[nCalcular,04])                                          ,; // 05 - Part Number
                              aEstados[nContar,01]                                                      ,; // 06 - Estado
                              aEstados[nContar,05]                                                      ,; // 05 - Grupo Tributário
                              0                                                                         ,; // 06 - Custo Médio do Produto
                              kFilial                                                                   ,; // 07 - Filial da Proposta Comercial Modelo
                              kProposta                                                                 ,; // 08 - Nº da Proposta Comercial Modelo                                                                
                              kCliente                                                                  ,; // 09 - Código do Cliente
                              kLojaCli                                                                  ,; // 10 - Loja do cliente 
                              aEstados[nContar,03]                                                      ,; // 11 - CNPJ do Cliente
                              aEstados[nContar,04]                                                      ,; // 12 - Inscrição Estadual do Cliente
                              aEstados[nContar,06]                                                      ,; // 13 - Cliente Contribuinte
                              aEstados[nContar,07]                                                      ,; // 14 - Destaca IE
                              aEstados[nContar,08]                                                      ,; // 15 - Tipo de Operação
                              aEstados[nContar,02])                                                        // 16 - Tipo de Operação                                   
                Loop

             Endif   
                         
             // #########################################################
             // Envia para a função que grava o registro na tabela ZTP ##
             // #########################################################                    
             GravaTabOpen( cEmpAnt                                                                   ,; // 01 - Código da Empresa
                           cFilAnt                                                                   ,; // 02 - Código da Filial
                           aCalcular[nCalcular,01]                                                   ,; // 03 - Código do Produto
                           Alltrim(aCalcular[nCalcular,02]) + " " + Alltrim(aCalcular[nCalcular,03]) ,; // 04 - Descrição do Produto
                           Alltrim(aCalcular[nCalcular,04])                                          ,; // 05 - Part Number
                           aEstados[nContar,01]                                                      ,; // 06 - Estado
                           aEstados[nContar,05]                                                      ,; // 05 - Grupo Tributário
                           T_SALDO->B2_CM1                                                           ,; // 06 - Custo Médio do Produto
                           kFilial                                                                   ,; // 07 - Filial da Proposta Comercial Modelo
                           kProposta                                                                 ,; // 08 - Nº da Proposta Comercial Modelo                                                                
                           kCliente                                                                  ,; // 09 - Código do Cliente
                           kLojaCli                                                                  ,; // 10 - Loja do cliente 
                           aEstados[nContar,03]                                                      ,; // 11 - CNPJ do Cliente
                           aEstados[nContar,04]                                                      ,; // 12 - Inscrição Estadual do Cliente
                           aEstados[nContar,06]                                                      ,; // 13 - Cliente Contribuinte
                           aEstados[nContar,07]                                                      ,; // 14 - Destaca IE
                           aEstados[nContar,08]                                                      ,; // 15 - Tipo de Operação
                           aEstados[nContar,02])                                                        // 16 - Tipo de Operação

         Next nContar
         
      Endif   

   Next nCalcular 

   // #########################################################
   // Carrega a cláusula where para filtro no select adiante ##
   // #########################################################
   cClausula := ""
   For nContar = 1 to Len(aCalcular)

       If Empty(Alltrim(cClausula))
       Else
          cClausula := cClausula + ","
       Endif   

       cClausula := cClausula + "'" + Alltrim(aCalcular[nContar,1]) + "'"
       
   Next nContar

   // ##########################################################
   // Pesquisa os registro da tabela ZTP para pesquisa do TES ##
   // ##########################################################
   If (Select( "T_TABELA" ) != 0 )
      T_TABELA->( DbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZTP_FILIAL,"	
   cSql += "       ZTP_EMPR	 ,"
   cSql += "       ZTP_PROD	 ,"
   cSql += "       ZTP_NOME	 ,"
   cSql += "       ZTP_PART	 ,"
   cSql += "       ZTP_ESTA	 ,"
   cSql += "       ZTP_CUS1	 ,"
   cSql += "       ZTP_CUS2	 ,"
   cSql += "       ZTP_DATA	 ,"
   cSql += "       ZTP_HORA	 ,"
   cSql += "       ZTP_USUA	 ,"
   cSql += "       ZTP_PARA	 ,"
   cSql += "       ZTP_DIFA1 ,"
   cSql += "       ZTP_DIFA2 ,"
   cSql += "       ZTP_TES1	 ,"
   cSql += "       ZTP_TES2	 ,"
   cSql += "       ZTP_PFIL	 ,"
   cSql += "       ZTP_PROP	 ,"
   cSql += "       ZTP_CLIE	 ,"
   cSql += "       ZTP_CNPJ	 ,"
   cSql += "       ZTP_LOJA	 ,"
   cSql += "       ZTP_INSC	 ,"
   cSql += "       ZTP_TRIB1 ,"
   cSql += "       ZTP_TRIB2 ,"
   cSql += "       ZTP_CONT1 ,"
   cSql += "       ZTP_CONT2 ,"
   cSql += "       ZTP_DETA1 ,"
   cSql += "       ZTP_DETA2 ,"
   cSql += "       ZTP_TOPE1 ,"
   cSql += "       ZTP_TOPE2 ,"
   cSql += "       ZTP_MUNI   "
   cSql += "  FROM ZTP010 (NoLock)"   
   cSql += " WHERE ZTP_EMPR   = '" + Alltrim(cEmpAnt)   + "'"
   cSql += "   AND ZTP_FILIAL = '" + Alltrim(cFilAnt)   + "'"
   cSql += "   AND ZTP_PROD IN ("  + Alltrim(cClausula) + ")"

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_TABELA",.T.,.T.)

   T_TABELA->( DbGoTop() )
   
   WHILE !T_TABELA->( EOF() )
   
      // #######################################################
      // Verifica se o produto tem TES. Se tiver, não calcula ##
      // #######################################################        
      If !Empty(Alltrim(T_TABELA->ZTP_TES1)) .And. !Empty(Alltrim(T_TABELA->ZTP_TES2))
         T_TABELA->( DbSkip() )
         Loop                  
      Endif   

      // ##########################################################
      // Prepara o cadastro do cliente para o estado posicionado ##
      // ##########################################################
   	  dbSelectArea("SA1")
	  dbSetOrder(1)
	  If dbSeek( xFilial("SA1") + T_TABELA->ZTP_CLIE + T_TABELA->ZTP_LOJA)
         RecLock("SA1",.F.)
         SA1->A1_EST     := T_TABELA->ZTP_ESTA
         SA1->A1_COD_MUN := T_TABELA->ZTP_MUNI
         SA1->A1_CGC     := T_TABELA->ZTP_CNPJ
         SA1->A1_INSCR   := T_TABELA->ZTP_INSC
         SA1->A1_GRPTRIB := T_TABELA->ZTP_TRIB1
         SA1->A1_CONTRIB := T_TABELA->ZTP_CONT1
         SA1->A1_IENCONT := T_TABELA->ZTP_DETA1
         MsUnLock()              
      Endif   

      If Empty(Alltrim(T_TABELA->ZTP_TOPE1))
         k_x_Toper := "03"
      Else
         k_x_Toper := T_TABELA->ZTP_TOPE1
      Endif   

      // #################
      // Pesquisa o TES ##
      // #################
//    K_TES1 := MaTesInt(2, T_TABELA->ZTP_TOPE1, T_TABELA->ZTP_CLIE, T_TABELA->ZTP_LOJA, "C", T_TABELA->ZTP_PROD)
      K_TES1 := MaTesInt(2, k_x_Toper, T_TABELA->ZTP_CLIE, T_TABELA->ZTP_LOJA, "C", T_TABELA->ZTP_PROD)

      // ###############################
      // Atualiza o TES na tabela ZTP ##
      // ###############################
      cSql := ""     
      cSql := "UPDATE ZTP010"
      cSql += "   SET"
      cSql += "       ZTP_TES1   = '"  + Alltrim(K_TES1) + "' "
      cSql += " WHERE ZTP_EMPR   = '" + Alltrim(T_TABELA->ZTP_EMPR)   + "'"
      cSql += "   AND ZTP_FILIAL = '" + Alltrim(T_TABELA->ZTP_FILIAL) + "'"
      cSql += "   AND ZTP_PROD   = '" + Alltrim(T_TABELA->ZTP_PROD)   + "'"
      cSql += "   AND ZTP_ESTA   = '" + Alltrim(T_TABELA->ZTP_ESTA)   + "'"

      _nErro := TcSqlExec(cSql) 

      If TCSQLExec(cSql) < 0 
         Alert(TCSQLERROR())
         Return(.T.)
      Endif

      // ##########################################################
      // Prepara o cadastro do cliente para o estado posicionado ##
      // ##########################################################
   	  dbSelectArea("SA1")
	  dbSetOrder(1)
	  If dbSeek( xFilial("SA1") + T_TABELA->ZTP_CLIE + T_TABELA->ZTP_LOJA)
         RecLock("SA1",.F.)
         SA1->A1_EST     := T_TABELA->ZTP_ESTA
         SA1->A1_COD_MUN := T_TABELA->ZTP_MUNI
         SA1->A1_CGC     := T_TABELA->ZTP_CNPJ
         SA1->A1_INSCR   := T_TABELA->ZTP_INSC
         SA1->A1_GRPTRIB := T_TABELA->ZTP_TRIB2
         SA1->A1_CONTRIB := T_TABELA->ZTP_CONT2
         SA1->A1_IENCONT := T_TABELA->ZTP_DETA2
         MsUnLock()              
      Endif   

      If Empty(Alltrim(T_TABELA->ZTP_TOPE2))
         k_x_Toper := "02"
      Else
         k_x_Toper := T_TABELA->ZTP_TOPE2
      Endif   

      // #################
      // Pesquisa o TES ##
      // #################
//    K_TES2 := MaTesInt(2, T_TABELA->ZTP_TOPE2, T_TABELA->ZTP_CLIE, T_TABELA->ZTP_LOJA, "C", T_TABELA->ZTP_PROD)
      K_TES2 := MaTesInt(2, k_x_Toper, T_TABELA->ZTP_CLIE, T_TABELA->ZTP_LOJA, "C", T_TABELA->ZTP_PROD)

      // ###############################
      // Atualiza o TES na tabela ZTP ##
      // ###############################
      cSql := ""     
      cSql := "UPDATE ZTP010"
      cSql += "   SET"
      cSql += "       ZTP_TES2   = '"  + Alltrim(K_TES2) + "' "
      cSql += " WHERE ZTP_EMPR   = '" + Alltrim(T_TABELA->ZTP_EMPR)   + "'"
      cSql += "   AND ZTP_FILIAL = '" + Alltrim(T_TABELA->ZTP_FILIAL) + "'"
      cSql += "   AND ZTP_PROD   = '" + Alltrim(T_TABELA->ZTP_PROD)   + "'"
      cSql += "   AND ZTP_ESTA   = '" + Alltrim(T_TABELA->ZTP_ESTA)   + "'"

      _nErro := TcSqlExec(cSql) 

      If TCSQLExec(cSql) < 0 
         Alert(TCSQLERROR())
         Return(.T.)
      Endif


	  T_TABELA->( DbSkip() )
	  
   Enddo	  

   // ##################################################
   // Calcula o Difal para os registros da tabela ZTP ##
   // ##################################################
   If (Select( "T_TABELA" ) != 0 )
      T_TABELA->( DbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZTP.ZTP_FILIAL,"	
   cSql += "       ZTP.ZTP_EMPR	 ,"
   cSql += "       ZTP.ZTP_PROD	 ,"
   cSql += "       ZTP.ZTP_NOME	 ,"
   cSql += "       ZTP.ZTP_PART	 ,"
   cSql += "       ZTP.ZTP_ESTA	 ,"
   cSql += "       ZTP.ZTP_CUS1	 ,"
   cSql += "       ZTP.ZTP_CUS2	 ,"
   cSql += "       ZTP.ZTP_DATA	 ,"
   cSql += "       ZTP.ZTP_HORA	 ,"
   cSql += "       ZTP.ZTP_USUA	 ,"
   cSql += "       ZTP.ZTP_PARA	 ,"
   cSql += "       ZTP.ZTP_DIFA1 ,"
   cSql += "       ZTP.ZTP_DIFA2 ,"
   cSql += "       ZTP.ZTP_TES1	 ,"
   cSql += "       ZTP.ZTP_TES2	 ,"
   cSql += "       ZTP.ZTP_PFIL	 ,"
   cSql += "       ZTP.ZTP_PROP	 ,"
   cSql += "       ZTP.ZTP_CLIE	 ,"
   cSql += "       ZTP.ZTP_CNPJ	 ,"
   cSql += "       ZTP.ZTP_LOJA	 ,"
   cSql += "       ZTP.ZTP_INSC	 ,"
   cSql += "       ZTP.ZTP_TRIB1 ,"
   cSql += "       ZTP.ZTP_TRIB2 ,"
   cSql += "       ZTP.ZTP_CONT1 ,"
   cSql += "       ZTP.ZTP_CONT2 ,"
   cSql += "       ZTP.ZTP_DETA1 ,"
   cSql += "       ZTP.ZTP_DETA2 ,"
   cSql += "       ZTP.ZTP_TOPE1 ,"
   cSql += "       ZTP.ZTP_TOPE2 ,"
   cSql += "       ZTP.ZTP_MUNI   "
   cSql += "  FROM ZTP010 ZTP (NoLock)"
   cSql += " WHERE ZTP_EMPR   = '" + Alltrim(cEmpAnt) + "'"
   cSql += "   AND ZTP_FILIAL = '" + Alltrim(cFilAnt) + "'"
   cSql += "   AND ZTP.ZTP_PROD IN (" + Alltrim(cClausula) + ")"
    
   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_TABELA",.T.,.T.)

   T_TABELA->( DbGoTop() )
   
   WHILE !T_TABELA->( EOF() )
                          
      nVezes := 0

      For nVezes = 1 to 2

          // ##########################################################
          // Prepara o cadastro do cliente para o estado posicionado ##
          // ##########################################################
     	  dbSelectArea("SA1")
     	  dbSetOrder(1)
	      If dbSeek( xFilial("SA1") + T_TABELA->ZTP_CLIE + T_TABELA->ZTP_LOJA)
             RecLock("SA1",.F.)
             SA1->A1_EST     := T_TABELA->ZTP_ESTA
             SA1->A1_COD_MUN := T_TABELA->ZTP_MUNI
             SA1->A1_CGC     := T_TABELA->ZTP_CNPJ
             SA1->A1_INSCR   := T_TABELA->ZTP_INSC
             If nVezes == 1 // PJ
                SA1->A1_GRPTRIB := T_TABELA->ZTP_TRIB1
                SA1->A1_CONTRIB := T_TABELA->ZTP_CONT1
                SA1->A1_IENCONT := T_TABELA->ZTP_DETA1
             Else           // PF
                SA1->A1_GRPTRIB := T_TABELA->ZTP_TRIB2
                SA1->A1_CONTRIB := T_TABELA->ZTP_CONT2
                SA1->A1_IENCONT := T_TABELA->ZTP_DETA2
             Endif
             MsUnLock()              
          Endif   

          // #############################################################################
          // Altera dados da Proposta Comercial Modelo para realizar o cálculo do DIFAL ##
          // #############################################################################
          dbSelectArea("ADY")
          dbSetOrder(1)
//        If dbSeek( kFilial + kProposta )
          If dbSeek( "01" + kProposta )
             RecLock("ADY",.F.)
             ADY->ADY_CODIGO := T_TABELA->ZTP_CLIE
             ADY->ADY_LOJA   := T_TABELA->ZTP_LOJA
             ADY->ADY_CLIENT := T_TABELA->ZTP_CLIE
             ADY->ADY_LOJENT := T_TABELA->ZTP_LOJA
             ADY->ADY_TABELA := "500"
             ADY->ADY_TPFRET := "C"
             MsUnLock()              
          Else
             Loop
          Endif
         
          // ########################################################################
          // Cria o array aCabecalho para ser enviado a função de cálculo do DIFAL ##
          // ########################################################################   
          dbSelectArea("ADY")
          dbSetOrder(1)
//        If dbSeek( kFilial + kProposta )   
          If dbSeek( "01" + kProposta )   
             aAdd( aCabecalho, { ADY->ADY_FILIAL,; && - 01
                                 ADY->ADY_PROPOS,; && - 02
                                 ADY->ADY_OPORTU,; && - 03
                                 ADY->ADY_REVISA,; && - 04
                                 ADY->ADY_ENTIDA,; && - 05
                                 ADY->ADY_CODIGO,; && - 06
                                 ADY->ADY_LOJA  ,; && - 07
                                 ADY->ADY_TABELA,; && - 08
                                 ADY->ADY_ORCAME,; && - 09
                                 ADY->ADY_STATUS,; && - 10
                                 ADY->ADY_DATA  ,; && - 11
                                 ADY->ADY_VAL   ,; && - 12
                                 ADY->ADY_OBSP  ,; && - 13
                                 ADY->ADY_OBSI  ,; && - 14
                                 ADY->ADY_TPFRET,; && - 15
                                 ADY->ADY_TRANSP,; && - 16
                                 ADY->ADY_TSRV  ,; && - 17
                                 ADY->ADY_FRETE ,; && - 18
                                 ADY->ADY_PARAQ ,; && - 19
                                 ADY->ADY_ENTREG,; && - 20
                                 ADY->ADY_OC    ,; && - 21
                                 ADY->ADY_FCOR  ,; && - 22
                                 ADY->ADY_FORMA ,; && - 23
                                 ADY->ADY_ADM   ,; && - 24
                                 ADY->ADY_PREVIS,; && - 25
                                 ADY->ADY_CLIENT,; && - 26
                                 ADY->ADY_LOJENT,; && - 27
                                 ADY->ADY_VEND  ,; && - 28
                                 ADY->ADY_PROCES,; && - 29
                                 ADY->ADY_TPCONT,; && - 30
                                 ADY->ADY_VISTEC,; && - 31
                                 ADY->ADY_CODVIS,; && - 32
                                 ADY->ADY_SITVIS,; && - 33
                                 ADY->ADY_CONDPG,; && - 34
                                 ADY->ADY_TES   ,; && - 35
                                 ADY->ADY_DESCON,; && - 36
                                 ADY->ADY_TPPROD,; && - 37
                                 ADY->ADY_LOCAL ,; && - 38
                                 ADY->ADY_DTREVI,; && - 39
                                 ADY->ADY_QEXAT ,; && - 40
                                 ADY->ADY_ZIDF  }) && - 41
          Endif

          If k_TipoCalc == 0

             cCustoInicial := k_Custo
             
          Else   

             // ###################################################################
             // Pesquisa o custo médio para atualização de campo de visualização ##
             // # 3983 - Cálculo de Custo para Etiquetas                         ##
             //          Quando o produto for etiqueta, o custo inicial deverá   ##
             //          capturado pela matéria-prima de consumo e pego o custo  ##
             //          da última entrada destas materia-prima.                 ##
             // ###################################################################

             If Len(Alltrim(T_TABELA->ZTP_PROD)) == 17
          
                // ####################################################################
                // Separa dados do código do produtos para pesquisa de matéria-prima ##
                // ####################################################################
                k_Base  := Substr(T_TABELA->ZTP_PROD,01,02)
                k_Faca  := '@FAC == "'  + Substr(T_TABELA->ZTP_PROD,03,04) + '"'
                k_Papel := "PAP       " + Substr(T_TABELA->ZTP_PROD,07,03)

                // #######################################
                // Pesquisa a matéria-prima da etiqueta ##
                // #######################################
                If (Select( "T_MATERIAPRIMA" ) != 0 )
                   T_MATERIAPRIMA->( DbCloseArea() )
                EndIf

                cSql := ""          
                cSql := "SELECT BU_BASE   ,"
                cSql += "       BU_IDC2   ,"
                cSql += "       BU_CONDICA," 
                cSql += "       BU_COMP   ,"
                cSql += "       BU_QUANT   "
                cSql += "  FROM " + RetSqlName("SBU")
                cSql += " WHERE BU_BASE    = '" + Alltrim(k_Base)  + "'"
                cSql += "   AND BU_IDC2    = '" + Alltrim(k_Papel) + "'"
                cSql += "   AND BU_CONDICA = '" + Alltrim(k_Faca)  + "'"
                cSql += "   AND D_E_L_E_T_ = ''

                cSql := ChangeQuery( cSql )
                dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_MATERIAPRIMA",.T.,.T.)

                k_Materia    := T_MATERIAPRIMA->BU_COMP

                // ######################################
                // Pesquisa o consumo da materia-prima ##
                // ######################################
                If K_Base == "02"

                   k_QtdConsumo := T_MATERIAPRIMA->BU_QUANT
                
                Else   

                   k_QtdConsumo := U_CalcPerda("SM", "", T_TABELA->ZTP_PROD, .F.)
                
                Endif   

                // ##############################################
                // Pesquisa dados da útlima entrada do produto ##
                // ##############################################
                If Select("T_ULTIMACOMPRA") > 0
                   T_ULTIMACOMPRA->( dbCloseArea() )
                EndIf
    
                cSql := ""
                cSql := "SELECT TOP 1 SD1.D1_DOC    ,"
                cSql += "             SD1.D1_CUSTO  ,"
                cSql += "             SD1.D1_DTDIGIT,"
                cSql += "             SD1.D1_BRICMS ,"
                cSql += "             SD1.D1_ICMSRET,"
                cSql += "             SD1.D1_VALICM ,"
                cSql += "             SD1.D1_QUANT  ,"
                cSql += "             SD1.D1_VALIPI ,"
                cSql += "             SD1.D1_ICMSRET,"
                cSql += "             SD1.D1_FORNECE,"
                cSql += "             SD1.D1_LOJA   ,"
                cSql += "             SA2.A2_NOME   ,"
                cSql += "             SA2.A2_EST    ,"
                cSql += "             SD1.D1_COD    ,"
                cSql += "             SB1.B1_GRTRIB  "
                cSql += "  FROM " + RetSqlName("SD1") + " SD1(NoLock), "
                cSql += "       " + RetSqlName("SA2") + " SA2(NoLock), "
                cSql += "       " + RetSqlName("SB1") + " SB1(NoLock), "
   	 		    cSql += "       " + RetSqlName("SF4") + " SF4(Nolock)  "  
                cSql += " WHERE SD1.D_E_L_E_T_ = ''"
                cSql += "   AND SD1.D1_FILIAL  = '" + Alltrim(cFilAnt) + "'"
                cSql += "   AND SD1.D1_PEDIDO <> ''" 
                cSql += "   AND SD1.D1_TIPO    = 'N'" 
                cSql += "   AND SD1.D1_COD     = '" + Alltrim(k_Materia) + "'"
                cSql += "   AND SD1.D1_FORNECE = SA2.A2_COD "
                cSql += "   AND SD1.D1_LOJA    = SA2.A2_LOJA"
                cSql += "   AND SA2.D_E_L_E_T_ = ''         "
                cSql += "   AND SD1.D1_COD     = SB1.B1_COD "
                cSql += "   AND SB1.D_E_L_E_T_ = ''         "
   		        cSql += "   AND SF4.F4_CODIGO  = SD1.D1_TES "
     		    cSql += "   AND SF4.D_E_L_E_T_ = ''         "
		        cSql += "   AND SF4.F4_ESTOQUE = 'S'        "
		        cSql += "   AND SF4.F4_DUPLIC  = 'S'        "
                cSql += " ORDER BY SD1.D1_EMISSAO DESC      "

                cSql := ChangeQuery( cSql )
                dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ULTIMACOMPRA", .T., .T. )

                If T_ULTIMACOMPRA->( EOF() )         
                   cCustoInicial := 0
                Else
                   K_ValIPI      := ROUND(T_ULTIMACOMPRA->D1_VALIPI / T_ULTIMACOMPRA->D1_QUANT,2)
                   cCustoInicial := ROUND((((T_ULTIMACOMPRA->D1_CUSTO / T_ULTIMACOMPRA->D1_QUANT) + K_ValIPI) * k_QtdConsumo),2)
                Endif
 
             Else
 
                DbSelectArea("SB2")
                DbSetOrder(1)
                If DbSeek(T_TABELA->ZTP_FILIAL + T_TABELA->ZTP_PROD + "01" )
                   cCustoInicial := SB2->B2_CM1
                Else
                   cCustoInicial := 0
                Endif
 
             Endif   
             
          Endif

          // #############################################################
          // Grava os dados do item do produto selecionado para cálculo ##
          // #############################################################
          dbSelectArea("ADZ")
          dbSetOrder(1)
//        If dbSeek( kFilial + kProposta + "01" )
          If dbSeek( "01" + kProposta + "01" )
             RecLock("ADZ",.F.)
             ADZ->ADZ_PRODUT := T_TABELA->ZTP_PROD
             ADZ->ADZ_DESCRI := ALLTRIM(T_TABELA->ZTP_NOME)
             ADZ->ADZ_UM     := "UM"
             ADZ->ADZ_MOEDA  := "1"
             ADZ->ADZ_CONDPG := "188"
             ADZ->ADZ_QTDVEN := 1
             If nVezes == 1
                ADZ->ADZ_PRCVEN := cCustoInicial
                ADZ->ADZ_TES    := T_TABELA->ZTP_TES1
             Else
                ADZ->ADZ_PRCVEN := cCustoInicial
                ADZ->ADZ_TES    := T_TABELA->ZTP_TES2
             Endif                
                
             MsUnLock()              
          Else
             Loop
          Endif
            
          // ####################################################
          // Carrega o array de produtos da proposta comercial ##
          // ####################################################
          dbSelectArea("ADZ")
          dbSetOrder(1)
//        dbSeek( kFilial + kProposta + "01" )
          dbSeek( "01" + kProposta + "01" )

          aProdutos := {}
         
          aAdd( aProdutos, {ADZ->ADZ_FILIAL      ,; && - 01
                            ADZ->ADZ_ITEM        ,; && - 02
                            ADZ->ADZ_PRODUT      ,; && - 03
                            ADZ->ADZ_DESCRI      ,; && - 04
                            ADZ->ADZ_UM          ,; && - 05
                            ADZ->ADZ_LACRE       ,; && - 06
                            ADZ->ADZ_CONDPG      ,; && - 07
                            ADZ->ADZ_QTDVEN      ,; && - 08
                            ADZ->ADZ_DESCON      ,; && - 09
                            ADZ->ADZ_MOEDA       ,; && - 10
                            ADZ->ADZ_MOEDA       ,; && - 11
                            ADZ->ADZ_PRCVEN      ,; && - 12
                            ADZ->ADZ_PRCTAB      ,; && - 13
                            ADZ->ADZ_VALDES      ,; && - 14
                            ADZ->ADZ_PMS         ,; && - 15
                            ADZ->ADZ_DT1VEN      ,; && - 16
                            ADZ->ADZ_ITEMOR      ,; && - 17
                            ADZ->ADZ_ORCAME      ,; && - 18
                            ADZ->ADZ_PROPOS      ,; && - 19
                            ADZ->ADZ_FOLDER      ,; && - 20
                            ADZ->ADZ_ITPAI       ,; && - 21
                            ADZ->ADZ_TES         ,; && - 22
                            ADZ->ADZ_COMIS1      ,; && - 23
                            ADZ->ADZ_COMIS2      ,; && - 24
                            ADZ->ADZ_QTGMRG      ,; && - 25
                            ADZ->ADZ_MARGEM      ,; && - 26
                            ADZ->ADZ_ORDC        ,; && - 27
                            ADZ->ADZ_ORDA        ,; && - 28
                            ADZ->ADZ_DEVO        ,; && - 29
                            ADZ->ADZ_TPPROD      ,; && - 30
                            ADZ->ADZ_PRDALO      ,; && - 31
                            ADZ->ADZ_LOCAL       ,; && - 32
                            ADZ->ADZ_REVISA      ,; && - 33
                            ADZ->ADZ_DTENTR      ,; && - 34
                            ADZ->ADZ_ORDS        ,; && - 35
                            0                    ,; && - 36
                            0                    ,; && - 37
                            0                    ,; && - 38
                            0                    ,; && - 39
                            0                    ,; && - 40
                            0                    ,; && - 41
                            0                    ,; && - 42
                            0                    }) && - 43                                                                                                                        
   
          // ##################################################################
          // Envia para a função que calcula o crédito adjudicado do produto ##
          // ##################################################################
          nCadjudicado := 0
          nCadjudicado := CreditoADJ(aProdutos[01,01]   ,; // 01 - Filial
                                     aProdutos[01,02]   ,; // 02 - Item
                                     aProdutos[01,03]   ,; // 03 - Produto
                                     aProdutos[01,08]   ,; // 04 - Quantidade
                                     aProdutos[01,22]   ,; // 05 - TES
                                     T_TABELA->ZTP_CLIE ,; // 06 - Cliente
                                     T_TABELA->ZTP_LOJA)   // 07 - Loja Cliente

          // ################################################################
          // Realiza o cálculo do DIFAL dos produtos da proposta comercial ##
          // ################################################################

          // #############################
          // Pesquisa o tipo de cliente ##
          // #############################
          xTipoCli := POSICIONE("SA1",1,XFILIAL("SA1") + T_TABELA->ZTP_CLIE + T_TABELA->ZTP_LOJA, "A1_TIPO")

          // ###############################
          // Calculo ST e Outros Impostos ##
          // ###############################                     
          MaFisIni(aCabecalho[01,06], aCabecalho[01,07], "C", "N", xTipoCli, MaFisRelImp("MTR700",{"ADY","ADZ"}),,,"SB1","MTR700")

          // ################################
          // Calcula o valor total do item ##
          // ################################
          nTProduto := 0
          nTProduto := (aProdutos[01,08] * aProdutos[01,12]) + aProdutos[01,36] - aProdutos[01,14]

          // ######################
          // Calcula os Impostos ##
          // ######################
          MaFisAdd(aProdutos[01,03] ,; // 01 - Código do Produto (Obrigatório)
                   aProdutos[01,22] ,; // 02 - Código do TES (Obrigatório)
                   aProdutos[01,08] ,; // 03 - Quantidade de Venda do Produto (Obrigatório)
                   aProdutos[01,12] ,; // 04 - Preço Unitário de Venda do Produto (Obrigatório)
                   aProdutos[01,14] ,; // 05 - Valor do Desconto (Opcional)
                   ""               ,; // 06 - Nº da NF Original (Devolução/Beneficiamento)
                   ""               ,; // 07 - Série da NF Original (Devolução/Beneficiamento)
                   0                ,; // 08 - RecNo da NF Original do arq SD1/SD2
                   0                ,; // 09 - Valor do Frete do Item ( Opcional )
                   0                ,; // 10 - Valor da Despesa do item ( Opcional )
                   0                ,; // 11 - Valor do Seguro do item ( Opcional )
                   0                ,; // 12 - Valor do Frete Autonomo ( Opcional )
                   nTProduto        ,; // 13 - Valor da Mercadoria ( Obrigatorio )
                   0                ,; // 14 - Valor da Embalagem ( Opiconal )
                   0                ,; // 15 - RecNo do SB1
                   0)                  // 16 - RecNo do SF4
           
          // #################################
          // Captura os valores de impostos ##
          // #################################
          _nAliqIcm := MaFisRet(1,"IT_ALIQICM")
          _nValIcm  := MaFisRet(1,"IT_VALICM" )
          _nBaseIcm := MaFisRet(1,"IT_BASEICM")
          _nValIpi  := MaFisRet(1,"IT_VALIPI" )
          _nValMerc := MaFisRet(1,"IT_VALMERC")
          _nValSol  := MaFisRet(1,"IT_VALSOL" )
          aDifalPF  := MaFisRet(1,"IT_LIVRO"  )

          MaFisEnd()         

          // ###############################################
          // Atualiza a tabela ZTP com o cálculo do Difal ##
          // ###############################################
          If nVezes == 1

             xK_ZTP_PIS1  := cTxPis
             xK_ZTP_COF1  := cTxCofins
             xK_ZTP_ICM1  := _nAliqIcm
             xK_ZTP_DIFA1 := _nValSol
             xK_ZTP_PDF1  := (_nValSol  / cCustoInicial) * 100
             kDifal1 := (_nValSol  / cCustoInicial)
             xK_ZTP_CM01  := cCustoInicial
             xK_ZTP_CAJ1  := nCadjudicado

             cCustoMedio := (xK_ZTP_CM01 - nCadjudicado)
             cPercPIS    := (cTxPIS    / 100)
             cPercCOF    := (cTxCofins / 100)
             cPercICM    := (_nAliqIcm / 100)

             // ##########################################################
             // Diferencia o cálculo para produtos etiquetas dos demais ##
             // ##########################################################
             If Len(Alltrim(T_TABELA->ZTP_PROD)) == 17
                cCustoTot01 := ROUND((cCustoMedio / (1 - (kDifal1))),2)  
             Else
                cCustoTot01 := ROUND((cCustoMedio / (1 - (cPercPIS + cPercCOF + cPercICM + kDifal1))),2)
             Endif

             xK_ZTP_CUS1 := cCustoTot01

             cSql := ""     
             cSql := "UPDATE ZTP010"
             cSql += "   SET"
             cSql += "       ZTP_PIS1   = "  + Alltrim(Str(xK_ZTP_PIS1,10,02))  + ", "
             cSql += "       ZTP_COF1   = "  + Alltrim(Str(xK_ZTP_COF1,10,02))  + ", "
             cSql += "       ZTP_ICM1   = "  + Alltrim(Str(xK_ZTP_ICM1,10,02))  + ", "
             cSql += "       ZTP_DIFA1  = "  + Alltrim(Str(xK_ZTP_DIFA1,10,02)) + ", "
             cSql += "       ZTP_PDF1   = "  + Alltrim(Str(xK_ZTP_PDF1,06,02))  + ", "
             cSql += "       ZTP_CM01   = "  + Alltrim(Str(xK_ZTP_CM01,10,02))  + ", "
             cSql += "       ZTP_CAJ1   = "  + Alltrim(Str(xK_ZTP_CAJ1,10,02))  + ", "
             cSql += "       ZTP_CUS1   = "  + Alltrim(Str(xK_ZTP_CUS1,10,02))  + ", "

             If k_TipoCalc == 0
    	        dPrevista := Ctod(Substr(k_DtaEstoque,07,02) + "/" + Substr(k_DtaEstoque,05,02) + "/" + Substr(k_DtaEstoque,01,04))
                cSql += "    ZTP_PROV   = 'S',"
    	        cSql += "    ZTP_DPRE   = '" + Strzero(year(dPrevista),4) + Strzero(month(dPrevista),2) + Strzero(day(dPrevista),2) + "' "
             Else
                cSql += "    ZTP_PROV   = 'N'"                
             Endif

             cSql += " WHERE ZTP_EMPR   = '" + Alltrim(T_TABELA->ZTP_EMPR)   + "'"
             cSql += "   AND ZTP_FILIAL = '" + Alltrim(T_TABELA->ZTP_FILIAL) + "'"
             cSql += "   AND ZTP_PROD   = '" + Alltrim(T_TABELA->ZTP_PROD)   + "'"
             cSql += "   AND ZTP_ESTA   = '" + Alltrim(T_TABELA->ZTP_ESTA)   + "'"

             _nErro := TcSqlExec(cSql) 

             If TCSQLExec(cSql) < 0 
                Alert(TCSQLERROR())
                Return(.T.)
             Endif

          Else

             xK_ZTP_PIS2  := cTxPis
             xK_ZTP_COF2  := cTxCofins
             xK_ZTP_ICM2  := _nAliqIcm
             xK_ZTP_DIFA2 := aDifalPF[17] + aDifalPF[129]
             xK_ZTP_PDF2  := (((aDifalPF[17] + aDifalPF[129]) / cCustoInicial) * 100)
             xKDifal2     := ((aDifalPF[17] + aDifalPF[129]) / cCustoInicial)
             xK_ZTP_CM02  := cCustoInicial
             xK_ZTP_CAJ2  := nCadjudicado

             cCustoMedio := (xK_ZTP_CM02 - nCadjudicado)
             cPercPIS    := (cTxPIS    / 100)
             cPercCOF    := (cTxCofins / 100)
             cPercICM    := (_nAliqIcm / 100)

             // ##########################################################
             // Diferencia o cálculo para produtos etiquetas dos demais ##
             // ##########################################################
             If Len(Alltrim(T_TABELA->ZTP_PROD)) == 17
                cCustoTot02 := ROUND((cCustoMedio / (1 - (xKDifal2))),2)
             Else   
                cCustoTot02 := ROUND((cCustoMedio / (1 - (cPercPIS + cPercCOF + cPercICM + xKDifal2))),2)
             Endif   

             xK_ZTP_CUS2 := cCustoTot02

             cSql := ""     
             cSql := "UPDATE ZTP010"
             cSql += "   SET"
             cSql += "       ZTP_PIS2   = "  + Alltrim(Str(xK_ZTP_PIS2,10,02))  + ", "
             cSql += "       ZTP_COF2   = "  + Alltrim(Str(xK_ZTP_COF2,10,02))  + ", "
             cSql += "       ZTP_ICM2   = "  + Alltrim(Str(xK_ZTP_ICM2,10,02))  + ", "
             cSql += "       ZTP_DIFA2  = "  + Alltrim(Str(xK_ZTP_DIFA2,10,02)) + ", "
             cSql += "       ZTP_PDF2   = "  + Alltrim(Str(xK_ZTP_PDF2,06,02))  + ", "
             cSql += "       ZTP_CM02   = "  + Alltrim(Str(xK_ZTP_CM02,10,02))  + ", "
             cSql += "       ZTP_CAJ2   = "  + Alltrim(Str(xK_ZTP_CAJ2,10,02))  + ", "
             cSql += "       ZTP_CUS2   = "  + Alltrim(Str(xK_ZTP_CUS2,10,02))  + ", "

             If k_TipoCalc == 0
    	        dPrevista := Ctod(Substr(k_DtaEstoque,07,02) + "/" + Substr(k_DtaEstoque,05,02) + "/" + Substr(k_DtaEstoque,01,04))
                cSql += "    ZTP_PROV   = 'S',"
    	        cSql += "    ZTP_DPRE   = '" + Strzero(year(dPrevista),4) + Strzero(month(dPrevista),2) + Strzero(day(dPrevista),2) + "' "
             Else
                cSql += "    ZTP_PROV   = 'N'"                
             Endif

             cSql += " WHERE ZTP_EMPR   = '" + Alltrim(T_TABELA->ZTP_EMPR)   + "'"
             cSql += "   AND ZTP_FILIAL = '" + Alltrim(T_TABELA->ZTP_FILIAL) + "'"
             cSql += "   AND ZTP_PROD   = '" + Alltrim(T_TABELA->ZTP_PROD)   + "'"
             cSql += "   AND ZTP_ESTA   = '" + Alltrim(T_TABELA->ZTP_ESTA)   + "'"

             _nErro := TcSqlExec(cSql) 

             If TCSQLExec(cSql) < 0 
                Alert(TCSQLERROR())
                Return(.T.)
             Endif

          Endif

       Next nVezes

       T_TABELA->( DbSkip() )
                  
   Enddo

   If k_TipoCalc == 0
      putmv("MV_RETSALE", "000")
   Endif 

Return(.T.)

// #######################################################################
// Função que grava na tabela de custos de vendas os valores calculados ##
// gTipoCalc = 1 -> Para clientes com IE Ativa  , grava Custo 01        ## 
// gTipoCalc = 2 -> Para clientes com IE Inativa, grava Custo 01        ## 
// #######################################################################
Static Function GravaTabOpen( gEmpresa, gFilial, gProduto, gDescricao, gPartNum, gEstado, gTipoCalc, gCusto, ggFilial, gProposta, gCliente, gLojaCli, gCNPJ, gInscricao, gContribuinte, gDestacaIE, gTipoOperacao, gMunicipio )

   dbSelectArea("ZTP")
   dbSetOrder(1)
   If dbSeek( gEmpresa + gFilial + gProduto + gEstado )

      RecLock("ZTP",.F.)
      ZTP->ZTP_NOME	  := gDescricao
      ZTP->ZTP_PART	  := gPartNum
      ZTP->ZTP_CUS1	  := gCusto
      ZTP->ZTP_CUS2	  := gCusto
      ZTP->ZTP_DATA	  := Date()
      ZTP->ZTP_HORA	  := Time()
      ZTP->ZTP_USUA	  := Alltrim(Upper(cUserName))
      ZTP->ZTP_DIFA1  := 0	
      ZTP->ZTP_DIFA2  := 0	
      ZTP->ZTP_TES1	  := ""
      ZTP->ZTP_TES2	  := ""
      ZTP->ZTP_PFIL	  := ggFilial
      ZTP->ZTP_PROP	  := gProposta
      ZTP->ZTP_CLIE	  := gCliente
      ZTP->ZTP_LOJA	  := gLojaCli
      ZTP->ZTP_CNPJ	  := gCNPJ
      ZTP->ZTP_INSC	  := gInscricao
      ZTP->ZTP_MUNI   := gMunicipio

      If gTipoCalc == "002"
         ZTP->ZTP_TRIB1 := gTipoCalc
         ZTP->ZTP_CONT1	:= gContribuinte
         ZTP->ZTP_DETA1	:= gDestacaIE
         ZTP->ZTP_TOPE1	:= gTipoOperacao
      Else   
         ZTP->ZTP_TRIB2	:= gTipoCalc
         ZTP->ZTP_CONT2	:= gContribuinte
         ZTP->ZTP_DETA2	:= gDestacaIE
         ZTP->ZTP_TOPE2 := gTipoOperacao
      Endif

      MsUnLock()              

   Else

      RecLock("ZTP",.T.)
      ZTP->ZTP_FILIAL := gFilial
      ZTP->ZTP_EMPR	  := gEmpresa
      ZTP->ZTP_PROD	  := gProduto
      ZTP->ZTP_NOME	  := gDescricao
      ZTP->ZTP_PART	  := gPartNum
      ZTP->ZTP_ESTA	  := gestado
      ZTP->ZTP_CUS1	  := gCusto
      ZTP->ZTP_CUS2	  := gCusto
      ZTP->ZTP_DATA	  := Date()
      ZTP->ZTP_HORA	  := Time()
      ZTP->ZTP_USUA	  := Alltrim(Upper(cUserName))
      ZTP->ZTP_DIFA1  := 0	
      ZTP->ZTP_DIFA2  := 0	
      ZTP->ZTP_TES1	  := ""
      ZTP->ZTP_TES2	  := ""
      ZTP->ZTP_PFIL	  := ggFilial
      ZTP->ZTP_PROP	  := gProposta
      ZTP->ZTP_CLIE	  := gCliente
      ZTP->ZTP_LOJA	  := gLojaCli
      ZTP->ZTP_CNPJ	  := gCNPJ
      ZTP->ZTP_INSC	  := gInscricao
      ZTP->ZTP_MUNI   := gMunicipio

      If gTipoCalc == "002"
         ZTP->ZTP_TRIB1 := gTipoCalc
         ZTP->ZTP_CONT1	:= gContribuinte
         ZTP->ZTP_DETA1	:= gDestacaIE
         ZTP->ZTP_TOPE1	:= gTipoOperacao
      Else   
         ZTP->ZTP_TRIB2	:= gTipoCalc
         ZTP->ZTP_CONT2	:= gContribuinte
         ZTP->ZTP_DETA2	:= gDestacaIE
         ZTP->ZTP_TOPE2 := gTipoOperacao
      Endif

      MsUnLock()              

   Endif         

Return(.T.)

// #######################################################
// Função que calcula o crédito adjudicado dos produtos ##
// #######################################################
Static Function CreditoADJ(CA_Filial, CA_Item, CA_Produto, CA_Quantidade, CA_TES, CA_Cliente, CA_Loja)

   Local cSql        := ""
   Local cAliquota	 := GetMv("MV_ICMPAD")
   Local cCredito    := 0

   kFilial     := CA_Filial
   kItem       := CA_Item
   KProduto    := CA_Produto
   kQuantidade := CA_Quantidade
   kTES        := CA_TES
   kCliente	   := CA_Cliente
   kLoja       := CA_Loja
   kUFVenda	   := Posicione("SA1", 1, xFilial("SA1") + kCliente + kLoja, "A1_EST")
   kGCliente   := Posicione("SA1", 1, xFilial("SA1") + kCliente + kLoja, "A1_GRPTRIB")
   kCFOP  	   := Posicione("SF4", 1, xFilial("SF4") + kTES            , "F4_CF")

   // #####################################################################################
   // Se Filial logada for 06 - Espirito Santo, não haverá cálculo de crédito adjudicado ##
   // Regra passada em 01/08/2017 por Roger                                              ##
   // #####################################################################################
   If cEmpAnt == "01"
      If cFilAnt == "06"
         cCredito := 0
         Return(cCredito)
      Endif   
   Endif

   // ##############################################
   // Pesquisa dados da útlima entrada do produto ##
   // ##############################################
   If Select("T_ULTIMA") > 0
      T_ULTIMA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT TOP 1 SD1.D1_DOC    ,"
   cSql += "             SD1.D1_DTDIGIT,"
   cSql += "             SD1.D1_BRICMS ,"
   cSql += "             SD1.D1_ICMSRET,"
   cSql += "             SD1.D1_VALICM ,"
   cSql += "             SD1.D1_QUANT  ,"
   cSql += "             SD1.D1_ICMSRET,"
   cSql += "             SD1.D1_FORNECE,"
   cSql += "             SD1.D1_LOJA   ,"
   cSql += "             SA2.A2_NOME   ,"
   cSql += "             SA2.A2_EST    ,"
   cSql += "             SD1.D1_COD    ,"
   cSql += "             SB1.B1_GRTRIB  "
   cSql += "  FROM " + RetSqlName("SD1") + " SD1(NoLock), "
   cSql += "       " + RetSqlName("SA2") + " SA2(NoLock), "
   cSql += "       " + RetSqlName("SB1") + " SB1(NoLock)  "
   cSql += " WHERE SD1.D_E_L_E_T_ = ''"
   cSql += "   AND SD1.D1_FILIAL  = '" + Alltrim(kFilial) + "'"
   cSql += "   AND SD1.D1_PEDIDO <> ''" 
   cSql += "   AND SD1.D1_TIPO    = 'N'" 
   cSql += "   AND SD1.D1_COD     = '" + Alltrim(kProduto) + "'"
   cSql += "   AND SD1.D1_FORNECE = SA2.A2_COD "
   cSql += "   AND SD1.D1_LOJA    = SA2.A2_LOJA"
   cSql += "   AND SA2.D_E_L_E_T_ = ''         "
   cSql += "   AND SD1.D1_COD     = SB1.B1_COD "
   cSql += "   AND SB1.D_E_L_E_T_ = ''         "
   cSql += " ORDER BY SD1.D1_EMISSAO DESC      "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ULTIMA", .T., .T. )

   If T_ULTIMA->( EOF() )
      cCredito     := 0
   Else
      E_cUFEntrada := T_ULTIMA->A2_EST
      E_cGProduto  := T_ULTIMA->B1_GRTRIB
      E_cBase	   := T_ULTIMA->D1_BRICMS
      E_cQEntrada  := T_ULTIMA->D1_QUANT

      // ####################################################
      // Aplica a regra para calcular o crédito adjudicado ##
      // ####################################################
      cCredito := 0

//	  If Alltrim(E_cUFEntrada) <> Alltrim(SM0->M0_ESTENT)      
         If Alltrim(E_cGProduto) <> "017"
     	    If Alltrim(kUFVenda) <> Alltrim(SM0->M0_ESTENT)               
               If Alltrim(kGCliente) <> "003"
                  If kCFOP <> "5108" .And. kCFOP <> "6108"
                     //cCredito := Round((((E_cbase / E_cQEntrada) * kQuantidade) * cAliquota) / 100,2)
                     cCredito := Round((((T_ULTIMA->D1_ICMSRET / T_ULTIMA->D1_QUANT) + (T_ULTIMA->D1_VALICM / T_ULTIMA->D1_QUANT)) * 1),2)
                  Endif
               Endif
            Endif
         Endif
      Endif
// Endif   

Return(cCredito)