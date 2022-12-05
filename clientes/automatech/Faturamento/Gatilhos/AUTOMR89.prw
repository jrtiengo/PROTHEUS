#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR89.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  (X) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 13/03/2012                                                          *
// Objetivo..: Gatilho que carrega o campo Natureza da tela de Inclusão Manual do  *
//             Contas a Pagar                                                      *
//**********************************************************************************

User Function AUTOMR89(_Fornece, _Loja)
 
   Local cSql := ""
   
   U_AUTOM628("AUTOMR89")

   If Empty(Alltrim(_Fornece))
      Return ""
   Endif
   
   If Select("T_NATUREZA") > 0
      T_NATUREZA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A2_NATUREZ "
   cSql += "  FROM " + RetSqlName("SA2")
   cSql += " WHERE A2_COD  = '" + Alltrim(_Fornece) + "'"
   cSql += "   AND A2_LOJA = '" + Alltrim(_Loja)    + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NATUREZA", .T., .T. )

   If T_NATUREZA->( EOF() )
      T_NATUREZA->( dbCloseArea() )
      Return ""
   Endif
   
   If !Empty(Alltrim(T_NATUREZA->A2_NATUREZ))
      Return T_NATUREZA->A2_NATUREZ
   Endif
   
Return ""