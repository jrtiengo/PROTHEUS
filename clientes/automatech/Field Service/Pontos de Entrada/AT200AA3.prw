#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "jpeg.ch" 

// ###################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            ##
// -------------------------------------------------------------------------------- ##
// Referencia: AT200AA3.PRW                                                         ##
// Parâmetros: Nenhum                                                               ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                      ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                              ##
// Data......: 08/03/2017                                                           ##
// Objetivo..: Ponto de Entrada disparado após a gravação do contrato de AT.        ##
// ###################################################################################

User Function AT200AA3()

   // ################################################################
   // Envia para sub-função que vincula o contrato a base instalada ##
   // ################################################################
//   VincBaseInst()

Return(.T.)

// #####################################################################
// Vincula o contrato a base instalada conforme nº de séries marcados ##
// #####################################################################
Static Function VincBaseInst()

   MsgRun("Favor Aguarde! Atualizando tabela da Base Instalada ...", "Atualização Base Instalada",{|| xVincBaseInst() })

Return(.T.)

// #####################################################################
// Vincula o contrato a base instalada conforme nº de séries marcados ##
// #####################################################################
Static Function xVincBaseInst()

   Local cSql := ""

   If Select("T_ATUALIZA") > 0
      T_ATUALIZA->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT ZKA_FILIAL,"
   cSql += "       ZKA_CLIE  ,"
   cSql += "       ZKA_LOJA  ,"
   cSql += "       ZKA_PROD  ,"
   cSql += "       ZKA_SERI  ,"
   cSql += "       ZKA_STAT   "
   cSql += "     FROM " + RetSqlName("ZKA")
   cSql += "    WHERE ZKA_FILIAL = '" + Alltrim(cFilAnt)       + "'"
   cSql += "      AND ZKA_CLIE   = '" + Alltrim(M->AAH_CODCLI) + "'"
   cSql += "      AND ZKA_LOJA   = '" + Alltrim(M->AAH_LOJA)   + "'"
   cSql += "      AND ZKA_CONT   = '" + Alltrim(M->AAH_CONTRT) + "'"
   cSql += "      AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATUALIZA", .T., .T. )

   T_ATUALIZA->( DbGoTop() )
   
   WHILE !T_ATUALIZA->( EOF() )

      IF ALLTRIM(T_ATUALIZA->ZKA_SERI) == '2063560'
         A := 1
      ENDIF   

      DbSelectArea ("AA3")
      DbSetOrder(1)
      If DbSeek( cFilAnt + M->AAH_CODCLI + M->AAH_LOJA + T_ATUALIZA->ZKA_PROD + T_ATUALIZA->ZKA_SERI)

         dbSelectArea("AA3")
  	     RecLock("AA3", .F.)
  	     
  	     If Alltrim(T_ATUALIZA->ZKA_STAT) == ""
  	        If Alltrim(AA3->AA3_CONTRT) == Alltrim(M->AAH_CONTRT)
  	           AA3->AA3_CONTRT := ""
  	        Endif
  	     Else
  	        If Alltrim(AA3->AA3_CONTRT) == ""
  	           AA3->AA3_CONTRT := M->AAH_CONTRT
  	        Endif                              
  	     Endif   

         MsUnlock()  	           
         
      Endif   

      T_ATUALIZA->( DbSkip() )
      
   Enddo   
   
Return(.T.)