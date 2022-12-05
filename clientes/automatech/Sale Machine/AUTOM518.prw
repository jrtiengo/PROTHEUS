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
// Referencia: AUTOM518.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Gatilho                                               ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 06/12/2016                                                              ##
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

User Function AUTOM518()

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

   // ##############################################
   // Prepara o Ambiente para executar o processo ##
   // ##############################################
// PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" 

MSGALERT("Vai Começar: " + time())

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
   cSql += "  FROM " + RetSqlName("ZZ4")
   cSql += " WHERE D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PARAMETROS",.T.,.T.)

   // #########################################################
   // Gera as consistência sobre o parametrizador Automatech ##
   // #########################################################
   If T_PARAMETROS->( EOF() )
      xGeraTXTOpen( T_PARAMETROS->ZZ4_OARQ, "1", "Data....: " + Dtoc(Date())       + chr(13) + chr(10) + ;
                                                "Hora....: " + Time()             + chr(13) + chr(10) + ;
                                                "Mensagem: " + "Parâmetros de OpenCart não definidos no parametrizados Automatech." )
//      RESET ENVIRONMENT
      Return(.T.)
   Endif
         
   If Empty(Alltrim(T_PARAMETROS->ZZ4_FPRO))
      xGeraTXTOpen( T_PARAMETROS->ZZ4_OARQ, "2", "Data....: " + Dtoc(Date())       + chr(13) + chr(10) + ;
                                                "Hora....: " + Time()             + chr(13) + chr(10) + ;
                                                "Mensagem: " + "Filial da proposta comercial modelo não definida." )
//      RESET ENVIRONMENT
      Return(.T.)
   Endif
      
   If Empty(Alltrim(T_PARAMETROS->ZZ4_PCOM))
      xGeraTXTOpen( T_PARAMETROS->ZZ4_OARQ, "3", "Data....: " + Dtoc(Date())       + chr(13) + chr(10) + ;
                                                "Hora....: " + Time()             + chr(13) + chr(10) + ;
                                                "Mensagem: " + "Proposta comercial modelo não definida." )
//      RESET ENVIRONMENT
      Return(.T.)
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_COPE))
      xGeraTXTOpen( T_PARAMETROS->ZZ4_OARQ, "4", "Data....: " + Dtoc(Date())       + chr(13) + chr(10) + ;
                                                "Hora....: " + Time()             + chr(13) + chr(10) + ;
                                                "Mensagem: " + "Cliente modelo para cálculo do DIFAL não definido." )
//      RESET ENVIRONMENT
      Return(.T.)
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_LOPE))
      xGeraTXTOpen( T_PARAMETROS->ZZ4_OARQ, "4", "Data....: " + Dtoc(Date())       + chr(13) + chr(10) + ;
                                                "Hora....: " + Time()             + chr(13) + chr(10) + ;
                                                "Mensagem: " + "Loja do Cliente modelo para cálculo do DIFAL não definido." )
//      RESET ENVIRONMENT
      Return(.T.)
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_OEMP))
      xGeraTXTOpen( T_PARAMETROS->ZZ4_OARQ, "5", "Data....: " + Dtoc(Date())       + chr(13) + chr(10) + ;
                                                "Hora....: " + Time()             + chr(13) + chr(10) + ;
                                                "Mensagem: " + "Empresas/Filiais a serem utilizadas para cálculo do DIFAL não definidas." )
//      RESET ENVIRONMENT
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
   cSql += "  FROM " + RetSqlName("ZTP") + " ZTP, "
   cSql += "       " + RetSqlName("SB1") + " SB1  "
   cSql += " WHERE SB1.B1_COD     = ZTP.ZTP_PROD"
   cSql += "   AND SB1.D_E_L_E_T_ = ''"
   cSql += "   AND SB1.B1_GRUPO  >= '0100'"
   cSql += "   AND SB1.B1_GRUPO  <= '0127'"
      
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
          _nValPIS  := MaFisRet(1,"IT_VALPIS" )
          _nValCOF  := MaFisRet(1,"IT_VALCOF" ) 

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
                ZTP->ZTP_PIS1  := _nValPIS
                ZTP->ZTP_COF1  := _nValCOF
                ZTP->ZTP_ICM1  := _nValICM

                ZTP->ZTP_CUS1  := ZTP->ZTP_CUS1 + _nValSol + _nValPIS + _nValCOF
             Else
                ZTP->ZTP_DIFA2 := _nValSol
                ZTP->ZTP_PIS2  := _nValPIS
                ZTP->ZTP_COF2  := _nValCOF
                ZTP->ZTP_ICM2  := _nValICM
                ZTP->ZTP_CUS2  := ZTP->ZTP_CUS2 + _nValSol + _nValPIS + _nValCOF

                // #####################################################################################################
                // Regra passada pelo Roger em 28/10/2016 sendo:                                                      ##
                // Para clientes com IE Inativa e o Difal2 = 0 e Difal1 <> 0, atualiza o custo com o Valor do Difal 1 ##
                // #####################################################################################################
                If ZTP->ZTP_DIFA2 == 0
                   If ZTP->ZTP_DIFA1 <> 0
                      ZTP->ZTP_CUS2 := ZTP->ZTP_CUS2 + ZTP->ZTP_DIFA1 + ZTP->ZTP_PIS1 + ZTP->ZTP_COF1
                   Endif
                Endif

             Endif
             MsUnLock()              
          Endif

       Next nVezes

       T_TABELA->( DbSkip() )
                  
   Enddo
   
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
   xGeraTXTOpen( T_PARAMETROS->ZZ4_OARQ, "0", cString )

//   RESET ENVIRONMENT

MSGALERT("Terminou: " + time())

Return(.T.)

// ##########################################################
// Função que gera o arquivo de log do cálculo do OpenCart ##
// ##########################################################
Static Function xGeraTXTOpen( cCaminho, kStatus, cString )

   Local xCaminho := Alltrim(cCaminho) + "sale_machine_PISCOF.log"

   // #############################
   // Cria o novo arquivo de log ##
   // #############################
   nHdl := fCreate(xCaminho)
   fWrite (nHdl, cString ) 
   fClose(nHdl)

Return(.T.)