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
// Referencia: AUTOM507.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Gatilho                                               ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 10/10/2016                                                              ##
// Objetivo..: Programa que gera registros na Tabela ZTP010 com os produtos que foram  ##
//             marcados na tabela SD1 e SD3.                                           ##
//             Sempre que houver um lançamento de uma nota fiscal de entrada ou um a-  ##
//             juste de estoque (Movimentações Internas 2) referente a entrada, o sis- ##
//             tema, no final da gravação destes processo, marcará os produtos que de- ##
//             verão sofrer rec[alculo do custo na tabela ZTP010.                      ##
//             IMPORTANTE:                                                             ##
//             Alterarções realizadas neste programa, devem ser replicadas para o pro- ##
//             grama AUTOM506  e vice e versa.                                         ##
// ######################################################################################
// Regra para geração do arquivo de log de cálculo                                     ##
// ----------------------------------------------------------------------------------- ##
// Nome do arquivo de log: 0_SALE_CUSTO.TXT                                            ##
// Onde: 0 -> Statsu do Cálculo conforme descrição abaixo:                             ##
//                                                                                     ##
//       0 = Processamento realizado com sucesso                                       ##
//       1 = Idica falta de parametrização geral do Sale Machine                       ##
//       2 = Filial da proposta comercial modelo não definida                          ## 
//       3 = Proposta comercial modelo não definida                                    ##
//       4 = Cliente modelo não definido para cálculo                                  ##
//       5 = Empresas/Filiais não definidas para cálculo                               ##
//       6 = Não foram encontrados produtos para cálculo                               ##
//       7 = Problema encontrado na abertura de registros por Estados                  ##
//       8 = Problema encontrado na pesquisa de TES dos produtos                       ##
//       9 = Problema encontrado no cálculo dos Custo + DIFAL dos produtos por UF      ##
//                                                                                     ##
// Na entrada da execução deste programa, primeiramente o programa verificará o Status ##
// do arquivo de log gravado no caminho especificado. Caso o status for um  dos status ##
// acima com exceção do status 0 e 6, o Sistema enviará um work flow para o  enderecço ##
// harald@automatech.com;br alertando de possíveis falhas nos cálculos deste programa. ##
// ######################################################################################

User Function AUTOM507(_Grupo01, _Grupo02)

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

   Local aEstados       := {}
   Local aCabecalho     := {}
   Local aProdutos      := {}
   Local aCalcular      := {}

   Local cTxPIS         := 0
   Local cTxCofins      := 0

   // ##############################################
   // Prepara o Ambiente para executar o processo ##
   // ##############################################
// PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" 

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

   // #############################################################
   // Envia para a função que verifia o status do arquivo de log ##
   // #############################################################
   UltimoArqLog(T_PARAMETROS->ZZ4_OARQ)

   // #########################################################
   // Gera as consistência sobre o parametrizador Automatech ##
   // #########################################################
   If T_PARAMETROS->( EOF() )
      GeraTXTOpen( T_PARAMETROS->ZZ4_OARQ, "1", "Data....: " + Dtoc(Date())       + chr(13) + chr(10) + ;
                                                "Hora....: " + Time()             + chr(13) + chr(10) + ;
                                                "Mensagem: " + "Parâmetros de OpenCart não definidos no parametrizados Automatech." )
//    RESET ENVIRONMENT
      Return(.T.)
   Endif
         
   If Empty(Alltrim(T_PARAMETROS->ZZ4_FPRO))
      GeraTXTOpen( T_PARAMETROS->ZZ4_OARQ, "2", "Data....: " + Dtoc(Date())       + chr(13) + chr(10) + ;
                                                "Hora....: " + Time()             + chr(13) + chr(10) + ;
                                                "Mensagem: " + "Filial da proposta comercial modelo não definida." )
//    RESET ENVIRONMENT
      Return(.T.)
   Endif
      
   If Empty(Alltrim(T_PARAMETROS->ZZ4_PCOM))
      GeraTXTOpen( T_PARAMETROS->ZZ4_OARQ, "3", "Data....: " + Dtoc(Date())       + chr(13) + chr(10) + ;
                                                "Hora....: " + Time()             + chr(13) + chr(10) + ;
                                                "Mensagem: " + "Proposta comercial modelo não definida." )
//    RESET ENVIRONMENT
      Return(.T.)
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_COPE))
      GeraTXTOpen( T_PARAMETROS->ZZ4_OARQ, "4", "Data....: " + Dtoc(Date())       + chr(13) + chr(10) + ;
                                                "Hora....: " + Time()             + chr(13) + chr(10) + ;
                                                "Mensagem: " + "Cliente modelo para cálculo do DIFAL não definido." )
//    RESET ENVIRONMENT
      Return(.T.)
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_LOPE))
      GeraTXTOpen( T_PARAMETROS->ZZ4_OARQ, "4", "Data....: " + Dtoc(Date())       + chr(13) + chr(10) + ;
                                                "Hora....: " + Time()             + chr(13) + chr(10) + ;
                                                "Mensagem: " + "Loja do Cliente modelo para cálculo do DIFAL não definido." )
//    RESET ENVIRONMENT
      Return(.T.)
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_OEMP))
      GeraTXTOpen( T_PARAMETROS->ZZ4_OARQ, "5", "Data....: " + Dtoc(Date())       + chr(13) + chr(10) + ;
                                                "Hora....: " + Time()             + chr(13) + chr(10) + ;
                                                "Mensagem: " + "Empresas/Filiais a serem utilizadas para cálculo do DIFAL não definidas." )
//    RESET ENVIRONMENT
      Return(.T.)
   Endif

   // #################################################################################################
   // Inicializa a string cStrimng com o período inicial do processo para gravação do arquivo de log ##
   // #################################################################################################
   cString := ""
   cString := "Data Inicial do Cálculo: " + Dtoc(Date())       + Chr(13) + chr(10) 
   cString += "Hora Inicial do Cálculo: " + Time()             + Chr(13) + chr(10) 

   // ####################################################
   // Carrega as variáveis do Parametrizador Automatech ##
   // ####################################################
   kFilial   := T_PARAMETROS->ZZ4_FPRO
   kProposta := T_PARAMETROS->ZZ4_PCOM
   kCliente  := T_PARAMETROS->ZZ4_COPE
   kLojaCli  := T_PARAMETROS->ZZ4_LOPE

   // ###########################################################################
   // Carrega o array aCalcular com os códigos dos produtos a serem calculados ##
   // ###########################################################################

   // ##################################################################################
   // Verifica se existem produtos indicados para cálculo pelos documentos de entrada ##
   // ##################################################################################
   If (Select( "T_CALCULAR" ) != 0 )
      T_CALCULAR->( DbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT SD1.D1_FILIAL,"
   cSql += "       SD1.D1_COD   ,"
   cSql += "       SB1.B1_COD   ,"
   cSql += "	   SB1.B1_DESC  ,"
   cSql += "	   SB1.B1_DAUX  ,"
   cSql += "	   SB1.B1_PARNUM,"  
   cSql += "	   SB1.B1_UM     "
   cSql += "  FROM " + RetSqlName("SD1") + " SD1(NoLock), "
   cSql += "       " + RetSqlName("SB1") + " SB1(NoLock)  "
   cSql += " WHERE SD1.D1_OPEN    = '1'"
   cSql += "   AND SD1.D_E_L_E_T_ = '' "
   cSql += "   AND SB1.B1_COD     = SD1.D1_COD"
   cSql += "   AND SB1.B1_TIPO    = 'PA'"
   cSql += "   AND SB1.B1_MSBLQL <> '1' "
   cSql += "   AND SB1.D_E_L_E_T_ = ''  "
   cSql += " GROUP BY SD1.D1_FILIAL,"
   cSql += "          SD1.D1_COD   ,"
   cSql += "	      SB1.B1_COD   ,"
   cSql += "	      SB1.B1_DESC  ,"
   cSql += "	      SB1.B1_DAUX  ,"
   cSql += "	      SB1.B1_PARNUM,"  
   cSql += "	      SB1.B1_UM     "

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_CALCULAR",.T.,.T.)

   T_CALCULAR->( DbGoTop() )
   
   WHILE !T_CALCULAR->( EOF() )
   
      If (Select( "T_JAEXISTE" ) != 0 )
         T_JAEXISTE->( DbCloseArea() )
      EndIf
  
      cSql := ""
      cSql := "SELECT ZTP_FILIAL,"	
      cSql += "       ZTP_EMPR	,"
      cSql += "       ZTP_PROD	 "
      cSql += "  FROM " + RetSqlName("ZTP") + "(NoLock)"
      cSql += " WHERE ZTP_PROD   = '" + Alltrim(T_CALCULAR->B1_COD) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_JAEXISTE",.T.,.T.)

      lExiste := IIF(T_JAEXISTE->( EOF() ), "N", "S")

      aAdd( aCalcular, { T_CALCULAR->B1_COD   ,; // 01
                         T_CALCULAR->B1_DESC  ,; // 02
                         T_CALCULAR->B1_DAUX  ,; // 03
                         T_CALCULAR->B1_PARNUM,; // 04
                         T_CALCULAR->B1_UM    ,; // 05
                         lExiste              }) // 06
      T_CALCULAR->( DbSkip() )

   ENDDO 

   // ####################################################################################
   // Verifica se existem produtos indicados para cálculo pela Movimentação Interna (2) ##
   // ####################################################################################
   If (Select( "T_CALCULAR" ) != 0 )
      T_CALCULAR->( DbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT SD3.D3_FILIAL,"
   cSql += "       SD3.D3_COD   ,"
   cSql += "	   SB1.B1_COD   ,"
   cSql += "	   SB1.B1_DESC  ,"
   cSql += "	   SB1.B1_DAUX  ,"
   cSql += "	   SB1.B1_PARNUM,"  
   cSql += "	   SB1.B1_UM     "
   cSql += "  FROM " + RetSqlName("SD3") + " SD3(NoLock), "
   cSql += "       " + RetSqlName("SB1") + " SB1(NoLock)  "
   cSql += " WHERE SD3.D3_OPEN    = '1'"
   cSql += "   AND SD3.D_E_L_E_T_ = '' "
   cSql += "   AND SB1.B1_COD     = SD3.D3_COD"
   cSql += "   AND SB1.B1_TIPO    = 'PA'"
   cSql += "   AND SB1.B1_MSBLQL <> '1' "
   cSql += "   AND SB1.D_E_L_E_T_ = ''  "
   cSql += " GROUP BY SD3.D3_FILIAL,"
   cSql += "          SD3.D3_COD   ,"
   cSql += "	      SB1.B1_COD   ,"
   cSql += "	      SB1.B1_DESC  ,"
   cSql += "	      SB1.B1_DAUX  ,"
   cSql += "	      SB1.B1_PARNUM,"  
   cSql += "	      SB1.B1_UM     "

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_CALCULAR",.T.,.T.)

   T_CALCULAR->( DbGoTop() )
   
   WHILE !T_CALCULAR->( EOF() )

      If (Select( "T_JAEXISTE" ) != 0 )
         T_JAEXISTE->( DbCloseArea() )
      EndIf
  
      cSql := ""
      cSql := "SELECT ZTP_FILIAL,"	
      cSql += "       ZTP_EMPR	,"
      cSql += "       ZTP_PROD	 "
      cSql += "  FROM " + RetSqlName("ZTP") + "(NoLock)"
      cSql += " WHERE ZTP_PROD   = '" + Alltrim(T_CALCULAR->B1_COD) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_JAEXISTE",.T.,.T.)

      lExiste := IIF(T_JAEXISTE->( EOF() ), "N", "S")

      aAdd( aCalcular, { T_CALCULAR->B1_COD   ,; // 01
                         T_CALCULAR->B1_DESC  ,; // 02
                         T_CALCULAR->B1_DAUX  ,; // 03
                         T_CALCULAR->B1_PARNUM,; // 04
                         T_CALCULAR->B1_UM    ,; // 05
                         lExiste              }) // 06

      T_CALCULAR->( DbSkip() )

   ENDDO 

   // ########################################################
   // Se não existirem produtos a serem calculados, retorna ##
   // ########################################################

/*
   If Len(aCalcular) == 0
      // #########################################################
      // Envia para a função que gera o arquivo de log em disco ##
      // #########################################################
      cString += "Data Final do Cálculo: " + Dtoc(Date()) + Chr(13) + chr(10) 
      cString += "Hora Final do Cálculo: " + Time()       + Chr(13) + chr(10) 
      cString += "Mensagem.............: Não foram encontrados produtos para atualização."

      GeraTXTOpen( T_PARAMETROS->ZZ4_OARQ, "6", cString )

//      RESET ENVIRONMENT
      Return(.T.)
   Endif

*/

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

/*


   // ########################################################################
   // Envia para a função que cria o arquivo de log or processo de execução ##
   // ########################################################################
   GeraTXTOpen( T_PARAMETROS->ZZ4_OARQ, "7", "Abertura de registros para cálculo para os estados brasileiros" )

   // ####################################################################
   // Início do cálculo e gravação da tabela de Produtos para OpenChart ##
   // ####################################################################
   For nEmpresas = 1 to U_P_OCCURS(T_PARAMETROS->ZZ4_OEMP,"#",1)

       kEmpresa   := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_OEMP, "#", nEmpresas), "|", 1)
       kStringEmp := U_P_CORTA(T_PARAMETROS->ZZ4_OEMP,"#",nEmpresas)
       
       // ################################
       // Carrega as Filiais da Empresa ##
       // ################################
       For nFiliais = 1 to U_P_OCCURS(kStringEmp,"|",1)
        
           If nFiliais == 1
              Loop
           Endif   

           hFilial := U_P_CORTA(kStringEmp,"|", nFiliais)

           // ##############################################
           // Calcula o Custo para os estado da federação ##
           // ##############################################
           For nContar = 1 to Len(aEstados)

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

                   // ###############################################################################
                   // Verifica se produto lido possui custo.                                       ##
                   // Se não existeir, somente registra o produto na tabela e lê o próximo produto ##
                   // ###############################################################################
                   If (Select( "T_SALDO" ) != 0 )
                      T_SALDO->( DbCloseArea() )
                   EndIf

                   cSql := ""
                   cSql := "SELECT B2_FILIAL,"
                   cSql += "       B2_COD   ,"
       	           cSql += "       B2_LOCAL ,"
   	               cSql += "       B2_CM1    "
                   cSql += "  FROM SB2" + Alltrim(kEmpresa) + "0" + "(NoLock)"
                   cSql += " WHERE B2_FILIAL  = '" + Alltrim(hFilial)                 + "'"
                   cSql += "   AND B2_COD     = '" + Alltrim(aCalcular[nCalcular,01]) + "'"
                   cSql += "   AND B2_LOCAL   = '01'"
                   cSql += "   AND D_E_L_E_T_ = ''  "
         
                   cSql := ChangeQuery( cSql )
                   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_SALDO",.T.,.T.)

                  // ###############################################
                  // Verifica se produto possui registro de saldo ##
                  // ###############################################
                  If T_SALDO->( EOF() )
                     GravaTabOpen( kEmpresa                                                                  ,; // 01 - Código da Empresa
                                   hFilial                                                                   ,; // 02 - Código da Filial
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
                     GravaTabOpen( kEmpresa                                                                  ,; // 01 - Código da Empresa
                                   hFilial                                                                   ,; // 02 - Código da Filial
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
                  GravaTabOpen( kEmpresa                                                                  ,; // 01 - Código da Empresa
                                hFilial                                                                   ,; // 02 - Código da Filial
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

               Next nCalcular

           Next nContar
           
       Next nFiliais
       
   Next nEmpresas    

   // ########################################################################
   // Envia para a função que cria o arquivo de log or processo de execução ##
   // ########################################################################
   GeraTXTOpen( T_PARAMETROS->ZZ4_OARQ, "8", "Pesquisa de TES por Produto/UF" )

   // ######################################################
   // Pesquisa  condição de pesquisa para o select abaixo ##
   // ######################################################
   cClausula := ""
   For nContar = 1 to Len(aCalcular)

       If Empty(Alltrim(cClausula))
       Else
          cClausula := cClausula + ","
       Endif   

       cClausula := cClausula + "'" + Alltrim(aCalcular[nContar,1]) + "'"
       
   Next nContar

/*

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
   cSql += "  FROM " + RetSqlName("ZTP") + "(NoLock)"
   cSql += " WHERE ZTP_PROD IN (" + Alltrim(cClausula) + ")"

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_TABELA",.T.,.T.)

   T_TABELA->( DbGoTop() )
   
   WHILE !T_TABELA->( EOF() )
   
      // #######################################################
      // Verifica se o produto tem TES. Se tiver, não calcula ##
      // #######################################################        
      If Empty(Alltrim(T_TABELA->ZTP_TES1))
      Else
         If Empty(Alltrim(T_TABELA->ZTP_TES2))
         Else
            T_TABELA->( DbSkip() )
            Loop
         Endif
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

      // ############################
      // Atualiza o TES pesquisado ##
      // ############################
      dbSelectArea("ZTP")
      dbSetOrder(1)
      If dbSeek( T_TABELA->ZTP_EMPR + T_TABELA->ZTP_FILIAL + T_TABELA->ZTP_PROD + T_TABELA->ZTP_ESTA )
         RecLock("ZTP",.F.)
         ZTP->ZTP_TES1 := MaTesInt(2, T_TABELA->ZTP_TOPE1, T_TABELA->ZTP_CLIE, T_TABELA->ZTP_LOJA, "C", T_TABELA->ZTP_PROD)
         MsUnLock()              
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

      // ############################
      // Atualiza o TES pesquisado ##
      // ############################
      dbSelectArea("ZTP")
      dbSetOrder(1)
      If dbSeek( T_TABELA->ZTP_EMPR + T_TABELA->ZTP_FILIAL + T_TABELA->ZTP_PROD + T_TABELA->ZTP_ESTA )
         RecLock("ZTP",.F.)
         ZTP->ZTP_TES2 := MaTesInt(2, T_TABELA->ZTP_TOPE2, T_TABELA->ZTP_CLIE, T_TABELA->ZTP_LOJA, "C", T_TABELA->ZTP_PROD)
         MsUnLock()              
      Endif

	  T_TABELA->( DbSkip() )
	  
   Enddo	  

   // ########################################################################
   // Envia para a função que cria o arquivo de log or processo de execução ##
   // ########################################################################
   GeraTXTOpen( T_PARAMETROS->ZZ4_OARQ, "9", "Cálculo de Custo/Difal" )

*/

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
   cSql += "  FROM " + RetSqlName("ZTP") + " ZTP (NoLock),"
   cSql += "       " + RetSqlName("SB1") + " SB1 (NoLock) "

   cSql += " WHERE ZTP.ZTP_PROD = '005835'"


//   cSql += " WHERE SB1.B1_FILIAL  = ''"
//   cSql += "  AND SB1.B1_COD     = ZTP.ZTP_PROD"
//   cSql += "  AND SB1.B1_GRUPO  >= '" + Alltrim(_Grupo01) + "'"
//   cSql += "  AND SB1.B1_GRUPO  <= '" + Alltrim(_Grupo02) + "'"
//   cSql += "  AND SB1.D_E_L_E_T_ = ''"

//////////////////////////////////////   cSql += " WHERE ZTP.ZTP_PROD IN (" + Alltrim(cClausula) + ")"
    
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
          If dbSeek( T_TABELA->ZTP_PFIL + T_TABELA->ZTP_PROP )
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
          If dbSeek( T_TABELA->ZTP_PFIL + T_TABELA->ZTP_PROP )
   
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

          // ###################################################################
          // Pesquisa o custo médio para atualização de campo de visualização ##
          // ###################################################################
          DbSelectArea("SB2")
          DbSetOrder(1)
          If DbSeek(T_TABELA->ZTP_FILIAL + T_TABELA->ZTP_PROD + "01" )
             cCustoInicial := SB2->B2_CM1
          Else
             cCustoInicial := 0
          Endif

          // #############################################################
          // Grava os dados do item do produto selecionado para cálculo ##
          // #############################################################
          dbSelectArea("ADZ")
          dbSetOrder(1)
          If dbSeek( T_TABELA->ZTP_PFIL + T_TABELA->ZTP_PROP + "01" )
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
          dbSeek( T_TABELA->ZTP_PFIL + T_TABELA->ZTP_PROP + "01" )

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
          dbSelectArea("ZTP")
          dbSetOrder(1)
          If dbSeek( T_TABELA->ZTP_EMPR + T_TABELA->ZTP_FILIAL + T_TABELA->ZTP_PROD + T_TABELA->ZTP_ESTA )
             RecLock("ZTP",.F.)

             If nVezes == 1

                ZTP->ZTP_PIS1  := cTxPis
                ZTP->ZTP_COF1  := cTxCofins
                ZTP->ZTP_ICM1  := _nAliqIcm
                ZTP->ZTP_DIFA1 := _nValSol
                ZTP->ZTP_PDF1  := (_nValSol  / cCustoInicial) * 100
                kDifal1 := (_nValSol  / cCustoInicial)
                ZTP->ZTP_CM01  := cCustoInicial
                ZTP->ZTP_CAJ1  := nCadjudicado

                cCustoMedio := (ZTP->ZTP_CM01 - nCadjudicado)
                cPercPIS    := (cTxPIS    / 100)
                cPercCOF    := (cTxCofins / 100)
                cPercICM    := (_nAliqIcm / 100)
                cPercDIF    := (_nValSol  / ZTP->ZTP_CM01)
                cCustoTot01 := ROUND((cCustoMedio / (1 - (cPercPIS + cPercCOF + cPercICM + kDifal1))),2)

                ZTP->ZTP_CUS1 := cCustoTot01

             Else

                ZTP->ZTP_PIS2  := cTxPis
                ZTP->ZTP_COF2  := cTxCofins
                ZTP->ZTP_ICM2  := _nAliqIcm
                ZTP->ZTP_DIFA2 := aDifalPF[17] + aDifalPF[129]
                ZTP->ZTP_PDF2  := (((aDifalPF[17] + aDifalPF[129]) / cCustoInicial) * 100)
                ZTP->ZTP_CM02  := cCustoInicial
                ZTP->ZTP_CAJ2  := nCadjudicado

                cCustoMedio := (ZTP->ZTP_CM02 - nCadjudicado)
                cPercPIS    := (cTxPIS    / 100)
                cPercCOF    := (cTxCofins / 100)
                cPercICM    := (_nAliqIcm / 100)
                cPercDIF    := ((aDifalPF[17] + aDifalPF[129]) / ZTP->ZTP_CM02)
	            cCustoTot02 := ROUND((cCustoMedio / (1 - (cPercPIS + cPercCOF + cPercICM + cPercDIF))),2)

                ZTP->ZTP_CUS2 := cCustoTot02

             Endif

             MsUnLock()              

          Endif

       Next nVezes

       T_TABELA->( DbSkip() )
                  
   Enddo

   // #########################################################
   // Desmarca os produtos que estavam envolvidos no cálculo ##
   // #########################################################

   // #######################################
   // Desmarca a atualização na tabela SD1 ##
   // #######################################
   cSql := ""
   cSql := "UPDATE " + RetSqlName("SD1") + CHR(13)
   cSql += "   SET "                     + CHR(13)    
   cSql += "   D1_OPEN = ''"             + CHR(13)

   lResult := TCSQLEXEC(cSql)

   // #######################################
   // Desmarca a atualização na tabela SD3 ##
   // #######################################
   cSql := ""
   cSql := "UPDATE " + RetSqlName("SD3") + CHR(13)
   cSql += "   SET "                     + CHR(13)
   cSql += "   D3_OPEN = ''"             + CHR(13)

   lResult := TCSQLEXEC(cSql)
   
   // ################################################################
   // Encerra o texto de gravação do log de cálculo do SalesMachine ##
   // ################################################################
   cString += "Data Final do Cálculo: " + Dtoc(Date()) + Chr(13) + chr(10) 
   cString += "Hora Final do Cálculo: " + Time()       + Chr(13) + chr(10) 
   cString += Replicate("-",100)                       + chr(13) + chr(10)
   cString += "Relação de Produtos Atualizados"        + chr(13) + chr(10)
   cString += Replicate("-",100)                       + chr(13) + chr(10)
   cString += "CODIGO DOS PRODUTOS            DESCRIÇÃO DOS PRODUTOS" + chr(13) + chr(10)
   cString += Replicate("-",100) + chr(13) + chr(10)   
   
   For nContar = 1 to Len(aCalcular)
       cString += aCalcular[nContar,01] + " " + Alltrim(aCalcular[nContar,02]) + " " + Alltrim(aCalcular[nContar,03]) + chr(13) + chr(10)
   Next nContar

   // #########################################################
   // Envia para a função que gera o arquivo de log em disco ##
   // #########################################################
   GeraTXTOpen( T_PARAMETROS->ZZ4_OARQ, "0", cString )

// RESET ENVIRONMENT

   MsgAlert("Terminou.")

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

// ##########################################################
// Função que gera o arquivo de log do cálculo do OpenCart ##
// ##########################################################
Static Function GeraTXTOpen( cCaminho, kStatus, cString )

   Local cApaga00 := Alltrim(cCaminho) + "0_sale_machine_custo.log"
   Local cApaga01 := Alltrim(cCaminho) + "1_sale_machine_custo.log"
   Local cApaga02 := Alltrim(cCaminho) + "2_sale_machine_custo.log"
   Local cApaga03 := Alltrim(cCaminho) + "3_sale_machine_custo.log"
   Local cApaga04 := Alltrim(cCaminho) + "4_sale_machine_custo.log"
   Local cApaga05 := Alltrim(cCaminho) + "5_sale_machine_custo.log"
   Local cApaga06 := Alltrim(cCaminho) + "6_sale_machine_custo.log"
   Local cApaga07 := Alltrim(cCaminho) + "7_sale_machine_custo.log"
   Local cApaga08 := Alltrim(cCaminho) + "8_sale_machine_custo.log"                     
   Local cApaga09 := Alltrim(cCaminho) + "9_sale_machine_custo.log"                     

   Local xCaminho := Alltrim(cCaminho)  + kStatus + "_sale_machine_custo.log"


Return(.T.)


   // ############################################
   // Apaga o último arquivo para nova gravação ##
   // ############################################
   FERASE(cApaga00)
   FERASE(cApaga01)
   FERASE(cApaga02)
   FERASE(cApaga03)
   FERASE(cApaga04)
   FERASE(cApaga05)
   FERASE(cApaga06)
   FERASE(cApaga07)
   FERASE(cApaga08)                     
   FERASE(cApaga09)                     

   // #############################
   // Cria o novo arquivo de log ##
   // #############################
   nHdl := fCreate(xCaminho)
   fWrite (nHdl, cString ) 
   fClose(nHdl)

Return(.T.)

// ##################################################
// Função que verifica o status da última execução ##
// ##################################################
Static Function UltimoArqLog(kCaminho)

   Local cEmail   := ""
   Local lEnvia   := .F.
   Local aLista   := {}
   Local aFiles   := {}
   Local aSizes   := {}
   Local cApaga00 := Alltrim(kCaminho) + "0_sale_machine_custo.log"
   Local cApaga01 := Alltrim(kCaminho) + "1_sale_machine_custo.log"
   Local cApaga02 := Alltrim(kCaminho) + "2_sale_machine_custo.log"
   Local cApaga03 := Alltrim(kCaminho) + "3_sale_machine_custo.log"
   Local cApaga04 := Alltrim(kCaminho) + "4_sale_machine_custo.log"
   Local cApaga05 := Alltrim(kCaminho) + "5_sale_machine_custo.log"
   Local cApaga06 := Alltrim(kCaminho) + "6_sale_machine_custo.log"
   Local cApaga07 := Alltrim(kCaminho) + "7_sale_machine_custo.log"
   Local cApaga08 := Alltrim(kCaminho) + "8_sale_machine_custo.log"                     
   Local cApaga09 := Alltrim(kCaminho) + "9_sale_machine_custo.log"                     

Return(.T.)

   // ###########################################################
   // Inicializa o array que receberá o nome do arquivo de log ##
   // ###########################################################   
   aLista := {}

   // ###################################
   // Carrega os arquivos do diretório ##
   // ###################################
   ADir(Alltrim(kCaminho) + "*.*", aFiles, aSizes)

   // #################################################################################
   // Verifica se exisite erro no último log. Se não existir, elimina-o do diretório ##
   // #################################################################################
   nRegua := 0
   nCount := Len( aFiles )
   lEnvia := .F.
   
   For nX := 1 to nCount  

       If Upper(Substr(aFiles[nX],02,23)) == "_SALE_MACHINE_CUSTO.LOG"

          Do Case
                                                        
             
             Case Substr(aFiles[nX],01,01) == "0"
                  lEnvia := .F.
                  Exit
             Case Substr(aFiles[nX],01,01) == "6"
                  lEnvia := .F.
                  Exit
             Otherwise
                  lEnvia := .T.
                  cNomeLog := aFiles[nX]
                  cCodErro := Substr(aFiles[nX],01,01)
                  Exit
          EndCase
                  
       Endif
       
   Next nX    

   // #######################################
   // Envia e-mail de alerta do último log ##
   // #######################################
   If lEnvia == .T.

      cEmail := ""
      cEmail := "Atenção!" + chr(13) + chr(10) + chr(13) + chr(10)
      cEmail += "Houve erro ao ser executado o processo automático de Cálculo de Custo e Difal do Sale Machine." + chr(13) + chr(10) + chr(13) + chr(10)
      cEmail += "Erro ocorrido:" + chr(13) + chr(10) + chr(13) + chr(10) 

      Do Case
         Case cCodErro == "1"
              cEmail += "1 - Falta de parametrização geral do Sale Machine"
         Case cCodErro == "2"              
              cEmail += "2 - Filial da proposta comercial modelo não definida"
         Case cCodErro == "3"              
              cEmail += "3 - Proposta comercial modelo não definida"
         Case cCodErro == "4"              
              cEmail += "4 - Cliente modelo não definido para cálculo"
         Case cCodErro == "5"              
              cEmail += "5 - Empresas/Filiais não definidas para cálculo"
         Case cCodErro == "7"              
              cEmail += "7 - Problema encontrado na abertura de registros por Estados"
         Case cCodErro == "8"              
              cEmail += "8 - Problema encontrado na pesquisa de TES dos produtos"
         Case cCodErro == "9"              
              cEmail += "9 - Problema encontrado no cálculo dos Custo + DIFAL dos produtos por UF"
      EndCase
                  
      // ################################
      // Envia e-mail ao desenvolvedor ##
      // ################################
      U_AUTOMR20(cEmail, "haraldhans@gmail.com;harald@auutomatech.com.br", "", "Erro Sales Machine - Cálculo Custo e Difal" )

      // ############################################
      // Apaga o último arquivo para nova gravação ##
      // ############################################
      FERASE(cApaga00)
      FERASE(cApaga01)
      FERASE(cApaga02)
      FERASE(cApaga03)
      FERASE(cApaga04)
      FERASE(cApaga05)
      FERASE(cApaga06)
      FERASE(cApaga07)
      FERASE(cApaga08)                     
      FERASE(cApaga09)                     

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

//   IF Alltrim(kUFVenda) == "SP"
//      iF Alltrim(kProduto) == "006561"
//         A:= 1
//      ENDIF
//   ENDIF
         

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