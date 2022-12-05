#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"                                                                               
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: AUTOM623.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                         ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 04/09/2017                                                              ##
// Objetivo..: Programa que calcula a margem retroativa dos produtos etiquetas que     ##
//             comece com 03 (Etiquetas ROLOS).                                        ##   
// ######################################################################################

User Function AUTOM623()

   Local cSql := ""
   
   U_AUTOM628("AUTOM623")

   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT D2_FILIAL,"
   cSql += "       D2_PEDIDO,"
   cSql += "       D2_ITEMPV,"
   cSql += "       D2_COD    "
   cSql += "  FROM " + RetSqlName("SD2")
   cSql += " WHERE LEN(RTRIM(LTRIM(D2_COD))) = 17"
   cSql += "   AND SUBSTRING(D2_COD,01,02)   = '03'"
   cSql += "   AND D2_EMISSAO               >= '20170101'"
   cSql += "   AND D_E_L_E_T_                = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )
   
   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )
   
      U_AUTOM524(3, T_CONSULTA->D2_FILIAL, T_CONSULTA->D2_PEDIDO, T_CONSULTA->D2_ITEMPV, T_CONSULTA->D2_COD, 0, "R")      

      T_CONSULTA->( DbSkip() )
      
   ENDDO
   
Return(.T.)