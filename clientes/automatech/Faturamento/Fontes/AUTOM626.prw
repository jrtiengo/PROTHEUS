#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

#define SW_HIDE             0 // Escondido
#define SW_SHOWNORMAL       1 // Normal
#define SW_NORMAL           1 // Normal
#define SW_SHOWMINIMIZED    2 // Minimizada
#define SW_SHOWMAXIMIZED    3 // Maximizada
#define SW_MAXIMIZE         3 // Maximizada
#define SW_SHOWNOACTIVATE   4 // Na Ativação
#define SW_SHOW             5 // Mostra na posição mais recente da janela
#define SW_MINIMIZE         6 // Minimizada
#define SW_SHOWMINNOACTIVE  7 // Minimizada
#define SW_SHOWNA           8 // Esconde a barra de tarefas
#define SW_RESTORE          9 // Restaura a posição anterior
#define SW_SHOWDEFAULT      10// Posição padrão da aplicação
#define SW_FORCEMINIMIZE    11// Força minimização independente da aplicação executada
#define SW_MAX              11// Maximizada

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM626.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 05/09/2017                                                          ##
// Objetivo..: Gera Contrato para Pedidos de Locação                               ##
// Parâmetros: Filial e Nº do Pedido de Venda                                      ##
// ##################################################################################

User Function AUTOM626(kFilial, kPedido)

   Local cSql     := ""
   Local nContar  := 0
   Local lLocacao := .F.
   Local aTipoC   := {}
   
   U_AUTOM628("AUTOM626")
   
   // ###################################################################
   // Verifica se o pedido passado no parâmetro é um pedido de locação ##
   // ###################################################################
   If Select("T_LOCACAO") > 0
      T_LOCACAO->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT C6_FILIAL,"
   cSql += "       C6_NUM   ,"
   cSql += "       C6_TES    "
   cSql += "  FROM " + RetSqlName("SC6")
   cSql += " WHERE C6_FILIAL = '" + Alltrim(kFilial) + "'"
   cSql += "   AND C6_NUM    = '" + Alltrim(kPedido) + "'"            
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_LOCACAO", .T., .T. )

   T_LOCACAO->( DbGoTop() )
   
   WHILE !T_LOCACAO->( EOF() )
      If T_LOCACAO->C6_TES == "728"
         lLocacao := .T.
         Exit
      Endif
      T_LOCACAO->( DbSkip() )
   ENDDO
   
   If lLocacao == .F.
      Return(.T.)
   Endif
            
   // #############################################################
   // Pesquisa os parâmetros para geração do contrato de locação ##
   // #############################################################
   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT C5_FILIAL ,"
   cSql += "       C5_NUM    ,"
   cSql += "       C5_CLIENTE,"
   cSql += "       C5_LOJACLI," 
   cSql += "       C5_MOEDA  ,"
   cSql += "       C5_CONDPAG,"
   cSql += "       C5_ZLOC   ,"
   cSql += "       C5_VEND1  ,"
   cSql += "       C5_VEND2   "
   cSql += "  FROM " + RetSqlName("SC5")
   cSql += " WHERE C5_FILIAL = '" + Alltrim(kFilial) + "'"
   cSql += "   AND C5_NUM    = '" + Alltrim(kPedido) + "'"            
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   kInicial  := Ctod(U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 1))
   kFinal    := Ctod(U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 1))
   kUnidade  := U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 3)
   kVigencia := VAL(U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 4))
   kAtende   := U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 5)
   kTipo     := U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 6)
   kValor    := VAL(U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 7))
   kContrato := U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 8)
   kPerc01   := U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 9)
   kPerc02   := U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 10)   

   // ##########################admin#############################################################
   // Captura o código do tipo de movimento para gravação conforme a Empresa/Filial logada ##
   // #######################################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_TPOA, "
   cSql += "       ZZ4_TCUR, "
   cSql += "       ZZ4_TATE, "
   cSql += "       ZZ4_ACON, "
   cSql += "       ZZ4_LPRO, "
   cSql += "       ZZ4_LTES  "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      MsgAlert("Atenção! Não existe parametrizador para esta Empresa/Filial. Entre em contato com o Administrador do Sistema reportando esta mensagem.")
      Return(.T.)
   Endif
   
   // ###################################################################################
   // Carrega o array aTipoC com os dados parametrizados para a Empresa/Filial logados ##
   // ###################################################################################
   Do Case

      // #########################################################
      // Carrega os tipo de contrato para o Grupo de Empresa 01 ##
      // #########################################################
      Case cEmpAnt == "01"
           For nContar = 1 to U_P_OCCURS(T_PARAMETROS->ZZ4_TPOA, "|", 1)
               aAdd( aTipoC, { "01", U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_TPOA, "|", nContar), "#", 1), U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_TPOA, "|", nContar), "#", 2) } )
           Next nContar

      // #########################################################
      // Carrega os tipo de contrato para o Grupo de Empresa 02 ##
      // #########################################################
      Case cEmpAnt == "02"
           For nContar = 1 to U_P_OCCURS(T_PARAMETROS->ZZ4_TCUR, "|", 1)
               aAdd( aTipoC, { "02", U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_TCUR, "|", nContar), "#", 1), U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_TCUR, "|", nContar), "#", 2) } )
           Next nContar

      // #########################################################
      // Carrega os tipo de contrato para o Grupo de Empresa 03 ##
      // #########################################################
      Case cEmpAnt == "03"
           For nContar = 1 to U_P_OCCURS(T_PARAMETROS->ZZ4_TATE, "|", 1)
               aAdd( aTipoC, { "03", U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_TATE, "|", nContar), "#", 1), U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_TATE, "|", nContar), "#", 2) } )
           Next nContar
              
   EndCase

   // ########################################################
   // Captura o tipo de contrato para gravação em contratos ##
   // ########################################################
   For nContar = 1 to Len(aTipoC)
       If Alltrim(aTipoC[nContar,02]) == Alltrim(cFilAnt)
          TContrato := aTipoC[nContar,03]
          Exit
       Endif
   Next nContar

   // #######################################
   // Captura o próximo código de contrato ##
   // #######################################                                                                                               
   nProximoContrato := GetSXENum( "CN9", "CN9_NUMERO" ) 

   // ################################
   // Grava o cabeçalho do Contrato ##
   // ################################
   aArea := GetArea()
   dbSelectArea("CN9")
   RecLock("CN9",.T.)
   CN9->CN9_FILIAL   := kFilial
   CN9->CN9_NUMERO   := nProximoContrato
   CN9->CN9_DTINIC   := Ctod(U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 1))
   CN9->CN9_UNVIGE   := U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 3)
   CN9->CN9_VIGE     := INT(VAL(U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 4)))
   CN9->CN9_DTFIM    := Ctod(U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 2))
   CN9->CN9_CLIENT   := T_CONSULTA->C5_CLIENTE
   CN9->CN9_LOJACL   := T_CONSULTA->C5_LOJACLI
   CN9->CN9_MOEDA    := T_CONSULTA->C5_MOEDA
   CN9->CN9_CONDPG   := T_CONSULTA->C5_CONDPAG
   CN9->CN9_TPCTO    := TContrato
   CN9->CN9_VLINI    := VAL(U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 7))
   CN9->CN9_VLATU    := VAL(U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 7))
   CN9->CN9_SALDO    := VAL(U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 7))
   CN9->CN9_INDICE   := "001"
   CN9->CN9_FLGREJ   := "2"
   CN9->CN9_FLGCAU   := "2"
   CN9->CN9_TPCAUC   := "2"
   CN9->CN9_SITUAC   := "02"
   MsUnLock()

   // ##############################################
   // Confirma a utilização do código do contrato ##
   // ##############################################
   ConfirmSX8(.T.)
                 
   // ######################################################
   // Atualiza a tabela de acesso ao contrato por usuário ##
   // ######################################################
   If Empty(Alltrim(T_PARAMETROS->ZZ4_ACON))
      cAcessos := "000000|"
   Else
      cAcessos := Alltrim(T_PARAMETROS->ZZ4_ACON)
   Endif

   For nContar = 1 to U_P_OCCURS(cAcessos, "|", 1)
       aArea := GetArea()
       dbSelectArea("CNN")
       RecLock("CNN",.T.)      
       CNN->CNN_FILIAL := kFilial
       CNN->CNN_CONTRA := nProximoContrato
       CNN->CNN_USRCOD := U_P_CORTA(cAcessos, "|", nContar)
       CNN->CNN_TRACOD := "001"
       MsUnLock()
   Next nContar    

   // ################################################
   // Inclui dados do comicionamento dos vendedores ##
   // ################################################
   If !Empty(Alltrim(T_CONSULTA->C5_VEND1))
      aArea := GetArea()
      dbSelectArea("CNU")
      RecLock("CNU",.T.)      
      CNU->CNU_FILIAL := kFilial
      CNU->CNU_CONTRA := nProximoContrato
      CNU->CNU_CODVD  := T_CONSULTA->C5_VEND1
      CNU->CNU_PERCCM := VAL(U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 9))
      MsUnLock()
   Endif

   If !Empty(Alltrim(T_CONSULTA->C5_VEND2))
      aArea := GetArea()
      dbSelectArea("CNU")
      RecLock("CNU",.T.)      
      CNU->CNU_FILIAL := kFilial
      CNU->CNU_CONTRA := nProximoContrato
      CNU->CNU_CODVD  := T_CONSULTA->C5_VEND2
      CNU->CNU_PERCCM := VAL(U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 10))
      MsUnLock()
   Endif

   // ###############################
   // Cria o cabeçalho da Planilha ##
   // ###############################
   aArea := GetArea()
   dbSelectArea("CNA")
   RecLock("CNA",.T.)      
   CNA->CNA_FILIAL := kFilial
   CNA->CNA_CONTRA := nProximoContrato
   CNA->CNA_NUMERO := "000001"	
   CNA->CNA_CLIENT := T_CONSULTA->C5_CLIENTE
   CNA->CNA_LOJACL := T_CONSULTA->C5_LOJACLI
   CNA->CNA_DTINI  := Ctod(U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 1))
   CNA->CNA_VLTOT  := VAL(U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 7))
   CNA->CNA_SALDO  := VAL(U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 7))
   CNA->CNA_TIPPLA := "004"
   CNA->CNA_DTFIM  := Ctod(U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 2))
   CNA->CNA_FLREAJ := "2"
   CNA->CNA_VLCOMS := VAL(U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 7))
   MsUnLock()

   // ###########################################
   // Carrega a tabela CNB (Ítens da Planilha) ##
   // ###########################################

   // ####################################################
   // Carrega a tabela de ítens da planilha do contrato ##
   // ####################################################
   aArea := GetArea()
   dbSelectArea("CNB")
   RecLock("CNB",.T.)      
   CNB->CNB_FILIAL := kFilial
   CNB->CNB_NUMERO := "000001"	
   CNB->CNB_ITEM   := "001"
   CNB->CNB_PRODUT := T_PARAMETROS->ZZ4_LPRO
   CNB->CNB_DESCRI := Posicione("SB1",1,xFilial("SB1") + T_PARAMETROS->ZZ4_LPRO + Space(24),'B1_DESC')
   CNB->CNB_UM	   := "UM"
   CNB->CNB_QUANT  := INT(VAL(U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 4)))
   CNB->CNB_VLUNIT := VAL(U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 7)) /INT(VAL(U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 4)))   
   CNB->CNB_VLTOT  := VAL(U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 7))
   CNB->CNB_CONTRA := nProximoContrato
   CNB->CNB_DTCAD  := Ctod(U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 1))
   CNB->CNB_SLDMED := INT(VAL(U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 4)))
   CNB->CNB_SLDREC := INT(VAL(U_P_CORTA(T_CONSULTA->C5_ZLOC, "|", 4)))
   CNB->CNB_FLGCMS := "1"
   CNB->CNB_TS	   := T_PARAMETROS->ZZ4_LTES
   MsUnLock()

   // ##############################################
   // Grava o código do contrato no campo C5_ZLOC ##
   // ##############################################
   aArea := GetArea()
   dbSelectArea("SC5")
   DbSetOrder(1)
   If DbSeek( kFilial + kPedido )
      RecLock("SC5",.F.)
      SC5->C5_MDCONTR := nProximoContrato
      SC5->C5_ZLOC    := Dtoc(kInicial)          + "|" + ; // 01
                         Dtoc(kFinal)            + "|" + ; // 02
                         kUnidade                + "|" + ; // 03
                         Alltrim(Str(kVigencia)) + "|" + ; // 04
                         kAtende                 + "|" + ; // 05
                         kTipo                   + "|" + ; // 06
                         Str(kValor)             + "|" + ; // 07
                         nProximoContrato        + "|" + ; // 08
                         kPerc01                 + "|" + ; // 09                    
                         kPerc02                 + "|"     // 10
      MsUnLock()
   Endif   

   MsgAlert("PEDIDO DE LOCAÇÃO" + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ;
            "Foi gerado o Contrato de Locação Nº " + nProximoContrato + CHR(13) + CHR(10) + ;
            "para este pedido.")
   
Return(.T.)