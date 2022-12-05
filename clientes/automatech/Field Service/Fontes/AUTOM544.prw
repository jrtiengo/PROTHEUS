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
// Referencia: AUTOM544.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                         ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 06/03/2017                                                              ##
// Objetivo..: Programa que carrega o combo de Fabricante do campo AB6_FABR pela lei-  ##
//             tura do parametrizador Automatech.                                      ##
// ######################################################################################

User Function AUTOM544()

   Local cSql     := ""
   Local cRetorno := ""

   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ4_FAB1,"
   cSql += "       ZZ4_FAB2,"
   cSql += "       ZZ4_FAB3 "
   cSql += "  FROM ZZ4010"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )
   
   If T_PARAMETROS->( EOF() )
      Return(cRetorno)
   Endif

   cString1 := Substr(Alltrim(T_PARAMETROS->ZZ4_FAB1),01, Len(Alltrim(T_PARAMETROS->ZZ4_FAB1)) - 1)
   cString2 := Substr(Alltrim(T_PARAMETROS->ZZ4_FAB2),01, Len(Alltrim(T_PARAMETROS->ZZ4_FAB2)) - 1)
   cString3 := Substr(Alltrim(T_PARAMETROS->ZZ4_FAB3),01, Len(Alltrim(T_PARAMETROS->ZZ4_FAB3)) - 1)   

   cString1 := Strtran(cString1, "|", ";")
   cString2 := Strtran(cString2, "|", ";")
   cString3 := Strtran(cString3, "|", ";")

   cRetorno := Alltrim(cString1) + ";" + Alltrim(cString2) + ";" + Alltrim(cString3)
                                                                                    
Return(cRetorno)