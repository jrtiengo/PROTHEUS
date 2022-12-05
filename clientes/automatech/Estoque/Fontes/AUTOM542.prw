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
// Referencia: AUTOM542.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Gatilho                                               ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 03/03/2017                                                              ##
// Objetivo..: Programa que traz o Tipo de Produto na tela da Liberação de Pedidos V.  ##
// ######################################################################################

User Function AUTOM542()

   Local cSql     := ""
   Local lProduto := .F.   
   Local lServico := .F.
   Local cRetorno := ""

   U_AUTOM628("AUTOM542")

   If (Select( "T_TIPOPRODUTO" ) != 0 )
      T_TIPOPRODUTO->( DbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC6.C6_FILIAL ,"
   cSql += "       SC6.C6_NUM    ,"
   cSql += "	   SC6.C6_PRODUTO,"
   cSql += "	   SC6.C6_DESCRI ,"
   cSql += "	   SB1.B1_GRUPO   "
   cSql += "  FROM " + RetSqlName("SC6") + " (Nolock) SC6, "
   cSql += "       " + RetSqlName("SB1") + " (Nolock) SB1  "
   cSql += " WHERE SC6.C6_FILIAL  = '" + Alltrim(SC5->C5_FILIAL) + "'"
   cSql += "   AND SC6.C6_NUM     = '" + Alltrim(SC5->C5_NUM)    + "'"
   cSql += "   AND SB1.B1_COD     = SC6.C6_PRODUTO"
   cSql += "   AND SB1.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_TIPOPRODUTO",.T.,.T.)
   
   T_TIPOPRODUTO->( DbGoTop() )
   
   WHILE !T_TIPOPRODUTO->( EOF() )
   
      If T_TIPOPRODUTO->B1_GRUPO >= "0300" .AND. T_TIPOPRODUTO->B1_GRUPO <= "0500"
         lServico := .T.
      Else
         lProduto := .T.      
      Endif   

      T_TIPOPRODUTO->( DbSkip() )
      
   ENDDO

   Do Case
      Case lProduto == .T. .and. lServico == .T.
           cRetorno := "PRODUTOS/SERVIÇOS"
      Case lProduto == .T. .and. lServico == .F.
           cRetorno := "PRODUTOS"
      Case lProduto == .F. .and. lServico == .T.
           cRetorno := "SERVIÇOS"
   EndCase
   
Return(cRetorno)