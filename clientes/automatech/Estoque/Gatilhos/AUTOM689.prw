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
// Referencia: AUTOM689.PRW                                                             ##
// Parâmetros: Nenhum                                                                   ##
// Tipo......: (X) Programa  ( ) Gatilho                                                ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                  ##
// Data......: 17/05/2018                                                               ##
// Objetivo..: Programa executado no início dos módulos Estoque, Faturamento e Compras  ##
//             tendo como objetio de bloquear produtos que tinham indicação de produtos ##
//             de intermediação e deixaram de ser.                                      ##
//             Este processo foi elaborado porque o ponto  de  entrada MT010ALT no P12  ##
//             não está mais funcionando.                                               ##
// Parâmetros: Sem Parâmetros                                                           ##
// ######################################################################################
User Function AUTOM689()

   Local cSql
   
   _Intermediacao := .T.

   If Select("T_BLOQUEAR") > 0
 	  T_BLOQUEAR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT B1_COD  ,"
   cSql += "       B1_INTER,"  
   cSql += "	   B1_STLB  "
   cSql += "     FROM " + RetSqlName("SB1")
   cSql += " WHERE B1_INTER   = 'N'"
   cSql += "   AND B1_STLB   <> 'L'"
   cSql += "   AND D_E_L_E_T_ = '' "
	 
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_BLOQUEAR", .T., .T. )

   T_BLOQUEAR->( DbGoTop() )
   
   WHILE !T_BLOQUEAR->( EOF() )
   
  	  DbSelectArea("SB1")
	  DbSetOrder(1)
	  If DbSeek(xfilial("SB1") + T_BLOQUEAR->B1_COD)
         RecLock("SB1",.F.)         
         SB1->B1_MSBLQL := "1"
         SB1->B1_USUI   := cusername
         SB1->B1_DATAI  := DATE()
         SB1->B1_HORAI  := TIME()
         SB1->B1_STLB   := "S"
         MsUnLock()                                  
      Endif   
      
      T_BLOQUEAR->( DbSkip() )
      
   ENDDO   

Return(.T.)