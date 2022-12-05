#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

// ###################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            ##
// -------------------------------------------------------------------------------- ##
// Referencia: AUTOM572.PRW                                                         ##
// Parâmetros: Nenhum                                                               ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                      ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                              ##
// Data......: 18/05/2017                                                           ##
// Objetivo..: Programa que habilita ou não o campo B1_GDES do cadastro de produtos ##
// ###################################################################################

User Function AUTOM572(kGrupo)

   Local cSql     := ""
   Local lRetorno := .F.
   
   If Empty(Alltrim(kGrupo))
      Return(.F.)
   Endif
   
   // ########################################
   // Pesquisa o parâmetro de grupos de AST ##
   // ########################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_GDES FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If Empty(Alltrim(T_PARAMETROS->ZZ4_GDES))
      lRetorno := .F.
   Else
      If U_P_OCCURS(T_PARAMETROS->ZZ4_GDES, kGrupo, 1) == 0
         lRetorno := .F.
      Else
         lRetorno := .T.        
      Endif
   Endif

Return(lRetorno)