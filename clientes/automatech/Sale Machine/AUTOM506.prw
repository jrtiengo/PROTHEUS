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
// Referencia: AUTOM506.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Gatilho                                               ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 07/10/2016                                                              ##
// Objetivo..: Programa que atualiza a tabela ZTQ com saldos dos produtos para a atua- ##
//             lização do Open Cart.                                                   ##
// ######################################################################################

User Function AUTOM506()

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
   Local cString     	:= ""
   Local cGrvString     := ""
     
   Local aEstados       := {}
   Local aCabecalho     := {}
   Local aProdutos      := {}

   cSql           := ""
   kFilial        := ""
   kProposta      := ""
   kCliente       := ""
   kLojaCli       := ""
   kRevisao       := "01"
   nContar        := 0
   xTotalProposta := 0
   nTaxaD         := 0
   nFreteProposta := 0
   nTProduto      := 0
   nContar        := 0
   cString     	  := ""
   cGrvString     := ""

   aEstados       := {}
   aCabecalho     := {}
   aProdutos      := {}

   // ########################################
   // Seta a data com ano de quatro dígitos ##
   // ########################################
   SET DATE FORMAT TO "dd/mm/yyyy"
   SET CENTURY ON
   SET DATE BRITISH

   // ##############################################
   // Prepara o Ambiente para executar o processo ##
   // ##############################################

   PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"
 
   // ################################################################################
   // Pesquisa o código da Filial e Proposta Comercial parametrizada para o cálculo ##
   // ################################################################################
   If (Select( "T_PARAMETROS" ) != 0 )
      T_PARAMETROS->( DbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_OEMS,"
   cSql += "       ZZ4_OARQ "
   cSql += "  FROM " + RetSqlName("ZZ4")
   cSql += " WHERE D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PARAMETROS",.T.,.T.)

   If T_PARAMETROS->( EOF() )
      GeraTXTSTQ( T_PARAMETROS->ZZ4_OARQ, "Data....: " + Dtoc(Date())       + chr(13) + chr(10) + ;
                                          "Hora....: " + Time()             + chr(13) + chr(10) + ;
     		                              "Mensagem: " + "Parâmetros Sale Machine não definidos no parametrizados Automatech." )
      RESET ENVIRONMENT
      Return(.T.)
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_OEMS))
      GeraTXTSTQ( T_PARAMETROS->ZZ4_OARQ, "Data....: " + Dtoc(Date())       + chr(13) + chr(10) + ;
 	                                      "Hora....: " + Time()             + chr(13) + chr(10) + ;
        		                          "Mensagem: " + "Empresas/Filiais a serem utilizadas para carga de Saldos não informadas." )
      RESET ENVIRONMENT
      Return(.T.)
   Endif

   // ################################################################################################
   // Inicializa a string cString com o período inicial do processo para gravação do arquivo de log ##
   // ################################################################################################
   cString := ""                                            
   cString := "Data Inicial do Cálculo: " + Dtoc(Date())       + Chr(13) + chr(10) 
   cString += "Hora Inicial do Cálculo: " + Time()             + Chr(13) + chr(10) 

   // ####################################################################
   // Início do cálculo e gravação da tabela de Produtos para OpenChart ##
   // ####################################################################
   For nEmpresas = 1 to U_P_OCCURS(T_PARAMETROS->ZZ4_OEMS,"#",1)

       kEmpresa   := U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_OEMS, "#", nEmpresas), "|", 1)
       kStringEmp := U_P_CORTA(T_PARAMETROS->ZZ4_OEMS,"#",nEmpresas)
       
       Do Case
          Case kEmpresa == "01"
               kEstado := "RS"
          Case kEmpresa == "02"
               kEstado := "PR"
          Case kEmpresa == "03"
               kEstado := "RS"
       EndCase        

       // ################################
       // Carrega as Filiais da Empresa ##
       // ################################
       For nFiliais = 1 to U_P_OCCURS(kStringEmp,"|",1)
        
           If nFiliais == 1
              Loop
           Endif   

           hFilial := U_P_CORTA(kStringEmp,"|", nFiliais)
 
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
           cSql += "  FROM " + RetSqlName("SB1") + "(NoLock)"
           cSql += " WHERE D_E_L_E_T_ = ''"
           cSql += "   AND B1_MSBLQL <> '1'"
           cSql += "   AND B1_TIPO    = 'PA'"

           cSql := ChangeQuery( cSql )
           dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_CADASTRO",.T.,.T.)

           T_CADASTRO->( DbGoTop() )
      
           WHILE !T_CADASTRO->( EOF() )

              nSaldo_Produto := 0

              // ######################################################################
              // Pesquisa os saldos dos produtos lidos e abre registro na tabela ZTQ ##
              // ######################################################################
              If (Select( "T_SALDO" ) != 0 )
                 T_SALDO->( DbCloseArea() )
              EndIf

              cSql := ""
              cSql := "SELECT B2_FILIAL ,"
              cSql += "       B2_COD    ,"
   	          cSql += "       B2_LOCAL  ,"
              cSql += "       B2_QATU   ,"
              cSql += "       B2_QEMP   ,"
              cSql += "       B2_RESERVA,"
              cSql += "       B2_QPEDVEN,"
              cSql += "       B2_SALPEDI,"     
              cSql += "       B2_CM1     "
              cSql += "  FROM SB2" + Alltrim(kEmpresa) + "0" + "(NoLock)"
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

                 nSaldo_Produto := 0
                 cGrvString     := ""

              Else   

                 nSaldo_Produto := (T_SALDO->B2_QATU - T_SALDO->B2_QEMP - T_SALDO->B2_RESERVA - T_SALDO->B2_QPEDVEN)    

                 If nSaldo_Produto < 0
                    nSaldo_Produto := 0
                 Endif

                 // ############################
                 // Atualiza o campo ZTQ_DISP ##
                 // ############################

                 If (T_SALDO->B2_QATU - T_SALDO->B2_QPEDVEN) > 0
                    cGrvString := "IMEDIATA"
                 Else   

                    If T_SALDO->B2_SALPEDI > 0

                       If (Select( "T_PREVISTA" ) != 0 )
                          T_PREVISTA->( DbCloseArea() )
                       EndIf
            
                       cSql := "" 
                       cSql := "SELECT TOP(1) C7_FILIAL ,"
                       cSql += "              C7_PRODUTO,"
	                   cSql += "              SUBSTRING(C7_DATPRF,07,02) + '/' + SUBSTRING(C7_DATPRF,05,02) + '/' + SUBSTRING(C7_DATPRF,01,04) AS DTAPREVISTA"
                       cSql += "  FROM SC7" + Alltrim(kEmpresa) + "0" + "(NoLock)"
                       cSql += " WHERE C7_FILIAL  = '" + Alltrim(hFilial)            + "'"
                       cSql += "   AND C7_PRODUTO = '" + Alltrim(T_CADASTRO->B1_COD) + "'"
                       cSql += "   AND D_E_L_E_T_ = ''"
                       cSql += "   AND C7_QUANT  <> C7_QUJE"
                       cSql += " ORDER BY C7_DATPRF DESC"

                       cSql := ChangeQuery( cSql )
                       dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PREVISTA",.T.,.T.)

                       If Ctod(T_PREVISTA->DTAPREVISTA) < Date()
                          cGrvString := "SOBCONSULTA"
                       Else   
                          cGrvString := IIF(T_PREVISTA->( EOF() ), "", T_PREVISTA->DTAPREVISTA)
                       Endif   

                    Else                    

                         cGrvString := "SOBCONSULTA"

                    Endif
                 
                 Endif   
    
              Endif
              
              // ##################################################################
              // Envia para a função que grava o registro do produto e seu saldo ##
              // ##################################################################
              GravaSaldobOpen( kEmpresa                                                          ,; // 01 - Código da Empresa
                               hFilial                                                           ,; // 02 - Código da Filial
                               T_CADASTRO->B1_COD                                                ,; // 03 - Código do Produto
                               Alltrim(T_CADASTRO->B1_DESC) + " " + Alltrim(T_CADASTRO->B1_DAUX) ,; // 04 - Descrição do Produto
                               Alltrim(T_CADASTRO->B1_PARNUM)                                    ,; // 05 - Part Number
                               kEstado                                                           ,; // 06 - Estado
                               nSaldo_Produto                                                    ,; // 07 - Saldo do Produto
                               cGrvString)                                                          // 08 - Indica a disponibilidade
              T_CADASTRO->( DbSkip() )

           EndDo

       Next nFiliais
       
   Next nEmpresas    

   // #########################################################################
   // Encerra o texto de gravação do log da carga de estoque do SalesMachine ##
   // #########################################################################
   cString += "Data Final do Cálculo: " + Dtoc(Date()) + Chr(13) + chr(10) 
   cString += "Hora Final do Cálculo: " + Time()       + Chr(13) + chr(10) 
   
   // #########################################################
   // Envia para a função que gera o arquivo de log em disco ##
   // #########################################################
   GeraTXTSTQ( T_PARAMETROS->ZZ4_OARQ, cString )

   RESET ENVIRONMENT                                                      

Return(.T.)

// ########################################################
// Função que grava os saldos dos produtos na tabela ZTQ ##
// ########################################################
Static Function GravaSaldobOpen( gEmpresa, gFilial, gProduto, gDescricao, gPartNum, gEstado, gSaldo, gDisponibilidade )

   dbSelectArea("ZTQ")
   dbSetOrder(1)
   If dbSeek( gEmpresa + gFilial + gProduto + gEstado )
      RecLock("ZTQ",.F.)
      ZTQ->ZTQ_NOME	  := gDescricao
      ZTQ->ZTQ_PART	  := gPartNum
      ZTQ->ZTQ_SALDO  := gSaldo
      ZTQ->ZTQ_DATA	  := Date()
      ZTQ->ZTQ_HORA   := Time()
      ZTQ->ZTQ_USUA   := Alltrim(Upper(cUserName))
      ZTQ->ZTQ_DISP   := gDisponibilidade
      MsUnLock()              
   Else
      RecLock("ZTQ",.T.)
      ZTQ->ZTQ_FILIAL := gFilial
      ZTQ->ZTQ_EMPR	  := gEmpresa
      ZTQ->ZTQ_PROD	  := gProduto
      ZTQ->ZTQ_NOME	  := gDescricao
      ZTQ->ZTQ_PART	  := gPartNum
      ZTQ->ZTQ_ESTA	  := gestado
      ZTQ->ZTQ_SALDO  := gSaldo
      ZTQ->ZTQ_DATA	  := Date()
      ZTQ->ZTQ_HORA   := Time()
      ZTQ->ZTQ_USUA   := Alltrim(Upper(cUserName))
      ZTQ->ZTQ_DISP   := gDisponibilidade
      MsUnLock()              
   Endif         

Return(.T.)

// ##########################################################
// Função que gera o arquivo de log do cálculo do OpenCart ##
// ##########################################################
Static Function GeraTXTSTQ( cCaminho, cString )

   Local xCaminho := Alltrim(cCaminho)          + ;
                     "SALE_STQ_"                + ;
                     Substr(Dtoc(date()),01,02) + ;
                     Substr(Dtoc(date()),04,02) + ;                     
                     Substr(Dtoc(date()),07,04) + ;
                     Substr(Time(),01,02)       + ;
                     Substr(Time(),04,02)       + ;
                     Substr(Time(),07,02)       + ;
                     ".LOG"
          
   nHdl := fCreate(xCaminho)
   fWrite (nHdl, cString ) 
   fClose(nHdl)

Return(.T.)