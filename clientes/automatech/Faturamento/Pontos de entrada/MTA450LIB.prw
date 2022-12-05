#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

// **********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                            *
// -------------------------------------------------------------------------------- *
// Referencia: MTA450LIB.PRW                                                        *
// Par�metros: Nenhum                                                               *
// Tipo......: ( ) Programa  ( ) Gatilho (X) Ponto de Entrada                       *
// -------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                              *
// Data......: 09/05/2017                                                           *
// Objetivo..: Ponto de entrada que verifica se usu�rio tem permiss�o para realizar *
//             a an�lise de cr�dito conforme par�metros da tabela ZZ4               *
// **********************************************************************************

User Function MTA450LIB

   Local cSql       := ""
   Local cString    := ""
   Local nVezes     := 0
   Local nContar    := 0
   Local lLiberaCre := .F.

   U_AUTOM628("MTA450LIB")
   
   // ############################################################
   // Pesquisa os par�metros de libera��o de an�lise de cr�dito ##
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
      MsgAlert("Aten��o!"                                                + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Voc� n�o possui autoriza��o para efetuar esta opera��o." + chr(13) + chr(10) + ;
               "Entre em contato com seu gestor passado este aviso.")    	
      Return(.F.)               
   Endif

   lLiberaCre := .F.

   For nContar = 1 to nVezes
   
       If U_P_CORTA(U_P_CORTA(cString, "|", nContar), "#", 1) == Alltrim(__CUSERID)
       
          cCondicao := Posicione("SC5",1,SC9->C9_FILIAL + SC9->C9_PEDIDO, "C5_CONDPAG")
          
          // ##################################################
          // Se 999 -> Libera todas as condi�es de pagamento ##
          // ##################################################
          If U_P_OCCURS(cString, "999", 1) <> 0
             lLiberaCre := .T.
             Exit
          Endif

          // #######################################################################
          // Verifica se a condi��o de pagamento pode ser liberada para o usu�rio ##
          // #######################################################################
          If U_P_OCCURS(cString, cCondicao, 1) <> 0
             lLiberaCre := .T.
             Exit
          Endif
          
       Endif
       
   Next nContar

   If lLiberaCre == .T.
   Else
      MsgAlert("Aten��o!"                                                + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Voc� n�o possui autoriza��o para efetuar esta opera��o." + chr(13) + chr(10) + ;
               "Entre em contato com seu gestor passado este aviso.")    	
      Return(.F.)               
   Endif

Return(.T.)