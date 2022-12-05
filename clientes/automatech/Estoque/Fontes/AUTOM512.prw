#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// #######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                ##
// ------------------------------------------------------------------------------------ ##
// Referencia: AUTOM512.PRW                                                             ##
// Parâmetros: Nenhum                                                                   ##
// Tipo......: (X) Programa  ( ) Gatilho                                                ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                  ##
// Data......: 31/10/2016                                                               ##
// Objetivo..: Programa que verifica se usuário logado possui acesso as telas de Movi-  ##
//             mentação interna.                                                        ##
// #######################################################################################

User Function AUTOM512()

   Local cSql      := ""
   Local nContar   := 0
   Local lPertence := .F.
   
   U_AUTOM628("AUTOM512")

   // #############################################
   // Pesquisa o campo ZZ4_TRFS para verificação ##
   // #############################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_MVIN FROM " + RetSqlName("ZZ4") + " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   lPertence := .F.
 
   For nContar = 1 to U_P_OCCURS(T_PARAMETROS->ZZ4_MVIN, "|", 1)
       If Alltrim(Upper(U_P_CORTA(T_PARAMETROS->ZZ4_MVIN, "|", nContar))) == Alltrim(Upper(cUserName))
          lPertence := .T.
          Exit
       Endif
   Next nContar    
           
   If lPertence == .F.
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Você não tem permissão de acesso a este programa.")
      Return(.T.)
   Endif
      
   // #####################################
   // Chama o programa de Transferências ##
   // #####################################
   MATA241()
   
Return(.T.)