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
// Referencia: AUTOM583.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Gatilho                                               ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 14/06/2017                                                              ##
// Objetivo..: Programa que pesquisa o contato do cliente no pedido de venda.          ##
// ######################################################################################

User Function AUTOM583()
                                             
   Local cSql := ""

   U_AUTOM628("AUTOM583")
   
   If Empty(Alltrim(M->C5_ZEMA))
      M->C5_ZIDC := Space(06)
      Return(M->C5_ZEMA)
   Endif

   // ################################
   // Pesquisa o contato do cliente ##
   // ################################
   If Select("T_CONTATO") > 0
      T_CONTATO->( dbCloseArea() )
   EndIf

//   cSql := "SELECT U5_CODCONT,"                                    	
//   cSql += "       U5_CONTAT ,"
//   cSql += "       U5_DDD    ,"
//   cSql += "       U5_FONE   ,"
//   cSql += "       U5_FCOM1  ," 
//   cSql += "       U5_EMAIL   "
//   cSql += "     FROM " + RetSqlName("SU5")
//   cSql += "    WHERE UPPER(U5_EMAIL) = '" + Upper(Alltrim(M->C5_ZEMA)) + "'"
//   cSql += "       AND U5_NIVEL   = '07'"
//   cSql += "       AND D_E_L_E_T_ = ''  "

   cSql := ""
   cSql := "SELECT AC8.AC8_CODENT ,"
   cSql += "       AC8.AC8_CODCON ,"
   cSql += "       SU5.U5_CODCONT ,"
   cSql += "       SU5.U5_CONTAT  ,"
   cSql += "  	   SU5.U5_DDD     ,"
   cSql += "       SU5.U5_FONE    ,"
   cSql += "       SU5.U5_FCOM1   ,"
   cSql += "       SU5.U5_EMAIL    "
   cSql += "  FROM " + RetSqlName("AC8") + " AC8, "
   cSql += "       " + RetSqlName("SU5") + " SU5  "
   cSql += "    WHERE AC8.AC8_CODENT = '" + Alltrim(M->C5_CLIENTE) + Alltrim(M->C5_LOJACLI) + "'"
   cSql += "      AND AC8.D_E_L_E_T_ = ''"
   cSql += "      AND SU5.U5_CODCONT = AC8.AC8_CODCON"
   cSql += "      AND SU5.D_E_L_E_T_ = ''"
   cSql += "      AND SU5.U5_NIVEL   = '07'"
   cSql += "      AND UPPER(SU5.U5_EMAIL) LIKE '%" + Upper(Alltrim(M->C5_ZEMA)) + "%'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTATO", .T., .T. )

   If T_CONTATO->( EOF() )
      M->C5_ZIDC := Space(006)
//    M->C5_ZCON := Space(060)
//    M->C5_ZEMA := Space(150)
//    M->C5_ZDD1 := Space(003)
//    M->C5_ZTE1 := Space(015)
//    M->C5_ZTE2 := Space(015)
   Else
      M->C5_ZIDC := T_CONTATO->U5_CODCONT
      M->C5_ZCON := T_CONTATO->U5_CONTAT
      M->C5_ZEMA := T_CONTATO->U5_EMAIL
      M->C5_ZDD1 := T_CONTATO->U5_DDD
      M->C5_ZTE1 := T_CONTATO->U5_FONE
      M->C5_ZTE2 := T_CONTATO->U5_FCOM1
   Endif

Return(M->C5_ZEMA)