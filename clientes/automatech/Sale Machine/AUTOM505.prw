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
// Referencia: AUTOM505.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Gatilho                                               ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 27/09/2016                                                              ##
// Objetivo..: Programa que calcula a planilha financeira para os produtos cadastrados ##
//             a fim de popular a tabela que é utilizada pelo OpenChart                ##
// ######################################################################################

User Function AUTOM505(kProduto)

   Local lChumba    := .F.
   Local cMemo1	    := ""
   Local cMemo2	    := ""

   Local oMemo1
   Local oMemo2

   Private cProduto   := Space(30)
   Private cDescricao := Space(60)
   Private aTipo      := {"0 - Todos", "1 - Abertura de Registros", "2 - Pesquisa TES", "3 - Cálculo de Custo"}

   Private oGet1
   Private oGet2
   Private cComboBx1

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Carga Tabela Open Cart" FROM C(178),C(181) TO C(423),C(517) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(106),C(023) PIXEL NOBORDER OF oDlg

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(161),C(001) PIXEL OF oDlg
   @ C(098),C(002) GET oMemo2 Var cMemo2 MEMO Size C(161),C(001) PIXEL OF oDlg

   @ C(034),C(005) Say "Grupo"                                                   Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(055),C(005) Say "Descrição do Grupo"                                      Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(079),C(005) Say "Processo que realiza a carga da tabela ZTP - Open Cart." Size C(137),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(088),C(005) Say "Este é um processo demorado Execute-o com cautela.."     Size C(132),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(042),C(005) MsGet    oGet1     Var   cProduto   Size C(079),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SBM") VALID( PsqNomeProd( cProduto ) )
   @ C(064),C(005) MsGet    oGet2     Var   cDescricao Size C(159),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(105),C(005) ComboBox cComboBx1 Items aTipo      Size C(113),C(010)                              PIXEL OF oDlg

   @ C(105),C(086) Button "Processar" Size C(037),C(012) PIXEL OF oDlg ACTION( ChamaGeraZTP(cProduto) )
   @ C(105),C(125) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ##################################################################
// Função que pesquisa a descrição do produto selecionado/digitado ##
// ##################################################################
Static Function PsqNomeProd( cProduto )

   Local cSql := ""

   If Empty(Alltrim(cProduto))
      cDescricao := Space(60)
      oGet2:Refresh()
      Return(.T.)
   Endif

   cDescricao := Posicione("SBM", 1, xFilial("SBM") + cProduto, "BM_DESC")
   oGet2:Refresh()   

Return .T.


// #################################################################
// Função que chama a rotina de geração de tabela ZTP - Open Cart ##
// #################################################################
Static Function ChamaGeraZTP(cProduto)

   MsgRun("Aguarde! Gerando tabela ZTP - Open Cart ...", "Carga tabela ZTP (Open Cart)",{|| GeraZTP(cProduto) })

Return(.T.)

// ###########################################
// Função que gera a tabela ZTP - Open Cart ##
// ###########################################
Static Function GeraZTP(cProduto)

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
   Local cAliasSD2  	:= "ZTP" 
     
   Local aEstados       := {}
   Local aCabecalho     := {}
   Local aProdutos      := {}

   // ###############################################
   // Pesquisa o tipo de pesquisa a ser utilizada. ##
   // ###############################################
   If Substr(cComboBx1,01,01) == "0"
      MsgAlert("Selecione o tipo de rotina a ser utilizada.")
      Return(.T.)
   Endif
      
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
   cSql += "       ZZ4_OEMP "
   cSql += "  FROM " + RetSqlName("ZZ4")
   cSql += " WHERE D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PARAMETROS",.T.,.T.)

   If T_PARAMETROS->( EOF() )
      MsgStop("Atenção!"                                                         + chr(13) + chr(10) + chr(13) + chr(10) + ;
              "Verificar parametrizador Automatech (Aba Parâmetros Open Chart)." + chr(13) + chr(10) + ;
              "Parâmetros não definidos.")
      Return(.T.)
   Endif
         
   If Empty(Alltrim(T_PARAMETROS->ZZ4_FPRO))
      MsgStop("Atenção!"                                                         + chr(13) + chr(10) + chr(13) + chr(10) + ;
              "Filial da proposta comercial modelo não informada."               + chr(13) + chr(10) + ;
              "Verificar parametrizador Automatech (Aba Parâmetros Open Chart)." + chr(13) + chr(10) + ;
              "Parâmetros não definidos.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(T_PARAMETROS->ZZ4_PCOM))
      MsgStop("Atenção!"                                                         + chr(13) + chr(10) + chr(13) + chr(10) + ;
              "Nº da proposta comercial modelo não informada."               + chr(13) + chr(10) + ;
              "Verificar parametrizador Automatech (Aba Parâmetros Open Chart)." + chr(13) + chr(10) + ;
              "Parâmetros não definidos.")
      Return(.T.)
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_COPE))
      MsgStop("Atenção!"                                                         + chr(13) + chr(10) + chr(13) + chr(10) + ;
              "Cliente modelo para cálculo do DIFAL não informado."              + chr(13) + chr(10) + ;
              "Verificar parametrizador Automatech (Aba Parâmetros Open Chart)." + chr(13) + chr(10) + ;
              "Parâmetros não definidos.")
      Return(.T.)
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_LOPE))
      MsgStop("Atenção!"                                                         + chr(13) + chr(10) + chr(13) + chr(10) + ;
              "Loja do Cliente modelo para cálculo do DIFAL não informado."      + chr(13) + chr(10) + ;
              "Verificar parametrizador Automatech (Aba Parâmetros Open Chart)." + chr(13) + chr(10) + ;
              "Parâmetros não definidos.")
      Return(.T.)
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_OEMP))
      MsgStop("Atenção!"                                                                  + chr(13) + chr(10) + chr(13) + chr(10) + ;
              "Empresas/Filiais a serem utilizadas para cálculo do DIFAL não informadas." + chr(13) + chr(10) + ;
              "Verificar parametrizador Automatech (Aba Parâmetros Open Chart)."          + chr(13) + chr(10) + ;
              "Parâmetros não definidos.")
      Return(.T.)
   Endif

   // ####################################################
   // Carrega as variáveis do Parametrizador Automatech ##
   // ####################################################
   kFilial   := T_PARAMETROS->ZZ4_FPRO
   kProposta := T_PARAMETROS->ZZ4_PCOM
   kCliente  := T_PARAMETROS->ZZ4_COPE
   kLojaCli  := T_PARAMETROS->ZZ4_LOPE

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

   // ####################################
   // Processo de Abertura de Registros ##
   // ####################################
   If Substr(cComboBx1,01,01) == "1"

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
                  If (Select( "T_CADASTRO" ) != 0 )
                     T_CADASTRO->( DbCloseArea() )
                  EndIf
      
                  cSql := ""
                  cSql := "SELECT B1_COD   ,"
                  cSql += "       B1_DESC  ,"
                  cSql += "	   B1_DAUX  ,"
                  cSql += "       B1_PARNUM,"
                  cSql += "       B1_UM     "
                  cSql += "  FROM " + RetSqlName("SB1")
                  cSql += " WHERE D_E_L_E_T_ = ''"
                  cSql += "   AND B1_MSBLQL <> '1'"
                  cSql += "   AND B1_TIPO    = 'PA'"
                  cSql += "   AND B1_GRUPO = '" + Alltrim(cProduto) + "'"
  
                  cSql := ChangeQuery( cSql )
                  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_CADASTRO",.T.,.T.)

                  T_CADASTRO->( DbGoTop() )
      
                  WHILE !T_CADASTRO->( EOF() )

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
                     cSql += "  FROM SB2" + Alltrim(kEmpresa) + "0"
                     cSql += " WHERE B2_FILIAL  = '" + Alltrim(hFilial)            + "'"
                     cSql += "   AND B2_COD     = '" + Alltrim(T_CADASTRO->B1_COD) + "'"
                     cSql += "   AND B2_LOCAL   = '01'"
                     cSql += "   AND D_E_L_E_T_ = ''  "
             
                     cSql := ChangeQuery( cSql )
                     dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_SALDO",.T.,.T.)
         
                     // ###############################################
                     // Verifica se produto possui registro de saldo ##
                     // ###############################################
                     If T_SALDO->( EOF() )
                        GravaTabOpen( kEmpresa                                                          ,; // 01 - Código da Empresa
                                      hFilial                                                           ,; // 02 - Código da Filial
                                      T_CADASTRO->B1_COD                                                ,; // 03 - Código do Produto
                                      Alltrim(T_CADASTRO->B1_DESC) + " " + Alltrim(T_CADASTRO->B1_DAUX) ,; // 04 - Descrição do Produto
                                      Alltrim(T_CADASTRO->B1_PARNUM)                                    ,; // 05 - Part Number
                                      aEstados[nContar,01]                                              ,; // 06 - Estado
                                      aEstados[nContar,05]                                              ,; // 05 - Grupo Tributário
                                      0                                                                 ,; // 06 - Custo Médio do Produto
                                      kFilial                                                           ,; // 07 - Filial da Proposta Comercial Modelo
                                      kProposta                                                         ,; // 08 - Nº da Proposta Comercial Modelo                                                                
                                      kCliente                                                          ,; // 09 - Código do Cliente
                                      kLojaCli                                                          ,; // 10 - Loja do cliente 
                                      aEstados[nContar,03]                                              ,; // 11 - CNPJ do Cliente
                                      aEstados[nContar,04]                                              ,; // 12 - Inscrição Estadual do Cliente
                                      aEstados[nContar,06]                                              ,; // 13 - Cliente Contribuinte
                                      aEstados[nContar,07]                                              ,; // 14 - Destaca IE
                                      aEstados[nContar,08]                                              ,; // 15 - Tipo de Operação
                                      aEstados[nContar,02]                                              ,; // 16 - Tipo de Operação
                                      cProduto)                                                          
   
                        T_CADASTRO->( DbSkip() )

                        Loop
                     Endif   

                     // #########################################
                     // Verifica se produto possui custo médio ##
                     // #########################################
                     If T_SALDO->B2_CM1 == 0
                        GravaTabOpen( kEmpresa                                                          ,; // 01 - Código da Empresa
                                      hFilial                                                           ,; // 02 - Código da Filial
                                      T_CADASTRO->B1_COD                                                ,; // 03 - Código do Produto
                                      Alltrim(T_CADASTRO->B1_DESC) + " " + Alltrim(T_CADASTRO->B1_DAUX) ,; // 04 - Descrição do Produto
                                      Alltrim(T_CADASTRO->B1_PARNUM)                                    ,; // 05 - Part Number
                                      aEstados[nContar,01]                                              ,; // 06 - Estado
                                      aEstados[nContar,05]                                              ,; // 05 - Grupo Tributário
                                      0                                                                 ,; // 06 - Custo Médio do Produto
                                      kFilial                                                           ,; // 07 - Filial da Proposta Comercial Modelo
                                      kProposta                                                         ,; // 08 - Nº da Proposta Comercial Modelo                                                                
                                      kCliente                                                          ,; // 09 - Código do Cliente
                                      kLojaCli                                                          ,; // 10 - Loja do cliente 
                                      aEstados[nContar,03]                                              ,; // 11 - CNPJ do Cliente
                                      aEstados[nContar,04]                                              ,; // 12 - Inscrição Estadual do Cliente
                                      aEstados[nContar,06]                                              ,; // 13 - Cliente Contribuinte
                                      aEstados[nContar,07]                                              ,; // 14 - Destaca IE
                                      aEstados[nContar,08]                                              ,; // 15 - Tipo de Operação
                                      aEstados[nContar,02]                                              ,; // 16 - Tipo de Operação
                                      cProduto)                                                          

                        T_CADASTRO->( DbSkip() )

                        Loop

                     Endif   
                         
                     // #########################################################
                     // Envia para a função que grava o registro na tabela ZTP ##
                     // #########################################################                    
                     GravaTabOpen( kEmpresa                                                          ,; // 01 - Código da Empresa
                                   hFilial                                                           ,; // 02 - Código da Filial
                                   T_CADASTRO->B1_COD                                                ,; // 03 - Código do Produto
                                   Alltrim(T_CADASTRO->B1_DESC) + " " + Alltrim(T_CADASTRO->B1_DAUX) ,; // 04 - Descrição do Produto
                                   Alltrim(T_CADASTRO->B1_PARNUM)                                    ,; // 05 - Part Number
                                   aEstados[nContar,01]                                              ,; // 06 - Estado
                                   aEstados[nContar,05]                                              ,; // 05 - Grupo Tributário
                                   T_SALDO->B2_CM1                                                   ,; // 06 - Custo Médio do Produto
                                   kFilial                                                           ,; // 07 - Filial da Proposta Comercial Modelo
                                   kProposta                                                         ,; // 08 - Nº da Proposta Comercial Modelo                                                                
                                   kCliente                                                          ,; // 09 - Código do Cliente
                                   kLojaCli                                                          ,; // 10 - Loja do cliente 
                                   aEstados[nContar,03]                                              ,; // 11 - CNPJ do Cliente
                                   aEstados[nContar,04]                                              ,; // 12 - Inscrição Estadual do Cliente
                                   aEstados[nContar,06]                                              ,; // 13 - Cliente Contribuinte
                                   aEstados[nContar,07]                                              ,; // 14 - Destaca IE
                                   aEstados[nContar,08]                                              ,; // 15 - Tipo de Operação
                                   aEstados[nContar,02]                                              ,; // 16 - Tipo de Operação
                                   cProduto)                                                          

                     T_CADASTRO->( DbSkip() )

                  EndDo

              Next nContar
           
          Next nFiliais
       
      Next nEmpresas    

   Endif

   // ####################################
   // Processo de Abertura de Registros ##
   // ####################################
   If Substr(cComboBx1,01,01) == "2"

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
      cSql += "  FROM " + RetSqlName("ZTP")
      cSql += " WHERE ZTP_PARA = '" + Alltrim(cProduto) + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_TABELA",.T.,.T.)

      T_TABELA->( DbGoTop() )
   
      WHILE !T_TABELA->( EOF() )
   
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

   Endif
   
   // ####################################
   // Processo de Abertura de Registros ##
   // ####################################
   If Substr(cComboBx1,01,01) == "3"

      // ##################################################
      // Calcula o Difal para os registros da tabela ZTP ##
      // ##################################################
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
      cSql += "       ZTP_DIFA1  ,"
      cSql += "       ZTP_DIFA2  ,"
      cSql += "       ZTP_TES1	 ,"
      cSql += "       ZTP_TES2	 ,"
      cSql += "       ZTP_PFIL	 ,"
      cSql += "       ZTP_PROP	 ,"
      cSql += "       ZTP_CLIE	 ,"
      cSql += "       ZTP_CNPJ	 ,"
      cSql += "       ZTP_LOJA	 ,"
      cSql += "       ZTP_INSC	 ,"
      cSql += "       ZTP_TRIB1  ,"
      cSql += "       ZTP_TRIB2  ,"
      cSql += "       ZTP_CONT1  ,"
      cSql += "       ZTP_CONT2  ,"
      cSql += "       ZTP_DETA1  ,"
      cSql += "       ZTP_DETA2 ,"
      cSql += "       ZTP_TOPE1 ,"
      cSql += "       ZTP_TOPE2 ,"
      cSql += "       ZTP_MUNI   "
      cSql += "  FROM " + RetSqlName("ZTP")
      cSql += " WHERE ZTP_PARA = '" + Alltrim(cProduto) + "'"
      
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
               If nVezes == 1
                  SA1->A1_GRPTRIB := T_TABELA->ZTP_TRIB1
                  SA1->A1_CONTRIB := T_TABELA->ZTP_CONT1
                  SA1->A1_IENCONT := T_TABELA->ZTP_DETA1
               Else
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
                   ADZ->ADZ_PRCVEN := T_TABELA->ZTP_CUS1
                   ADZ->ADZ_TES    := T_TABELA->ZTP_TES1
                Else
                   ADZ->ADZ_PRCVEN := T_TABELA->ZTP_CUS2
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
             _nValIpi  := MaFisRet(1,"IT_VALIPI")
             _nValMerc := MaFisRet(1,"IT_VALMERC")
             _nValSol  := MaFisRet(1,"IT_VALSOL" )

             MaFisEnd()         
                                
             // ###############################################
             // Atualiza a tabela ZTP com o cálculo do Difal ##
             // ###############################################
             dbSelectArea("ZTP")
             dbSetOrder(1)
             If dbSeek( T_TABELA->ZTP_EMPR + T_TABELA->ZTP_FILIAL + T_TABELA->ZTP_PROD + T_TABELA->ZTP_ESTA )
                RecLock("ZTP",.F.)
                If nVezes == 1
                   ZTP->ZTP_DIFA1 := _nValSol
                   ZTP->ZTP_CUS1  := ZTP->ZTP_CUS1 + _nValSol
                   ZTP->ZTP_PARA  := Alltrim(ZTP->ZTP_PARA)
                Else
                   ZTP->ZTP_DIFA2 := _nValSol
                   ZTP->ZTP_CUS2  := ZTP->ZTP_CUS2 + _nValSol
                   ZTP->ZTP_PARA  := Alltrim(ZTP->ZTP_PARA)

                   // #####################################################################################################
                   // Regra passada pelo Roger em 28/10/2016 sendo:                                                      ##
                   // Para clientes com IE Inativa e o Difal2 = 0 e Difal1 <> 0, atualiza o custo com o Valor do Difal 1 ##
                   // #####################################################################################################
                   If ZTP->ZTP_DIFAL2 == 0
                      If ZTP->ZTP_DIFAL1 <> 0
                         ZTP->ZTP_CUS2 := ZTP->ZTP_CUS2 + ZTP->ZTP_DIFA1
                      Endif
                   Endif

                Endif
                MsUnLock()              
             Endif

          Next nVezes

          T_TABELA->( DbSkip() )
                  
      Enddo

   Endif

Return(.T.)

// #######################################################################
// Função que grava na tabela de custos de vendas os valores calculados ##
// gTipoCalc = 1 -> Para clientes com IE Ativa  , grava Custo 01        ## 
// gTipoCalc = 2 -> Para clientes com IE Inativa, grava Custo 01        ## 
// #######################################################################
Static Function GravaTabOpen( gEmpresa, gFilial, gProduto, gDescricao, gPartNum, gEstado, gTipoCalc, gCusto, ggFilial, gProposta, gCliente, gLojaCli, gCNPJ, gInscricao, gContribuinte, gDestacaIE, gTipoOperacao, gMunicipio, gGrupo )

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
      ZTP->ZTP_PARA := gGrupo
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
      ZTP->ZTP_PARA := gGrupo
      MsUnLock()              
   Endif         

Return(.T.)

*/