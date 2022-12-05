#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

// **********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            *
// -------------------------------------------------------------------------------- *
// Referencia: MTA450LIB.PRW                                                        *
// Parâmetros: Nenhum                                                               *
// Tipo......: ( ) Programa  ( ) Gatilho (X) Ponto de Entrada                       *
// -------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                              *
// Data......: 09/05/2017                                                           *
// Objetivo..: Ponto de entrada que verifica se usuário tem permissão para realizar *
//             a análise de crédito conforme parâmetros da tabela ZZ4               *
// **********************************************************************************

User Function MTA450LIB

   Local cSql       := ""
   Local cString    := ""
   Local nVezes     := 0
   Local nContar    := 0
   Local lLiberaCre := .F.

   U_AUTOM628("MTA450LIB")
   
   // ############################################################
   // Pesquisa os parâmetros de liberação de análise de crédito ##
   // ############################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_LCRE1,"
   cSql += "       ZZ4_LCRE2 "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      cString := ""
   Else
      cString := Alltrim(T_PARAMETROS->ZZ4_LCRE1) + Alltrim(T_PARAMETROS->ZZ4_LCRE2)   
   Endif
 
   nVezes := U_P_OCCURS(cString, "|", 1)

   If nVezes == 0
      MsgAlert("Atenção!"                                                + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Você não possui autorização para efetuar esta operação." + chr(13) + chr(10) + ;
               "Entre em contato com seu gestor passado este aviso.")    	
      Return(.F.)               
   Endif

   lLiberaCre := .F.

   For nContar = 1 to nVezes
   
       If U_P_CORTA(U_P_CORTA(cString, "|", nContar), "#", 1) == Alltrim(__CUSERID)
       
          cCondicao := Posicione("SC5",1,SC9->C9_FILIAL + SC9->C9_PEDIDO, "C5_CONDPAG")
          
          // ##################################################
          // Se 999 -> Libera todas as condiões de pagamento ##
          // ##################################################
          If U_P_OCCURS(cString, "999", 1) <> 0
             lLiberaCre := .T.
             Exit
          Endif

          // #######################################################################
          // Verifica se a condição de pagamento pode ser liberada para o usuário ##
          // #######################################################################
          If U_P_OCCURS(cString, cCondicao, 1) <> 0
             lLiberaCre := .T.
             Exit
          Endif
          
       Endif
       
   Next nContar

   If lLiberaCre == .T.
   Else
      MsgAlert("Atenção!"                                                + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Você não possui autorização para efetuar esta operação." + chr(13) + chr(10) + ;
               "Entre em contato com seu gestor passado este aviso.")    	
      Return(.F.)               
   Endif

Return(.T.)