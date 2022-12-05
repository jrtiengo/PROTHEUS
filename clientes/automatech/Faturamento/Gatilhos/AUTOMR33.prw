#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR33.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  (X) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 23/02/2012                                                          *
// Objetivo..: Gatilho disparado no código da loja do cliente na oportunidade de   *
//             venda. Tem por objetivo de carregar o código do vendedor com o có-  *
//             digo do vendedor do cadastro de cliente informado.                  *
// Parâmetros: _Cliente = Código do Cliente	                                       *
//             _Loja    = Codigo da Loja do Cliente                                *
//**********************************************************************************

User Function AUTOMR33( _Cliente, _Loja )

   Local cSql := ""
   
   U_AUTOM628("AUTOMR33")
   
   If Select("T_VENDEDOR") > 0
      T_VENDEDOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.A1_COD ,"
   cSql += "       A.A1_LOJA,"
   cSql += "       A.A1_VEND,"
   cSql += "       B.A3_NOME "
   cSql += "  FROM " + RetSqlName("SA1") + " A, "
   cSql += "       " + RetSqlName("SA3") + " B "
   cSql += " WHERE A.A1_COD  = '" + Alltrim(_Cliente) + "'"
   cSql += "   AND A.A1_LOJA = '" + Alltrim(_Loja)   + "'"
   cSql += "   AND A.R_E_C_D_E_L_ = ''"
   cSql += "   AND A.A1_VEND = B.A3_COD "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )
   
   If T_VENDEDOR->( EOF() )
      M->AD1_NOMVEN := ""
      Return ""
   Endif
   
   If Empty(Alltrim(T_VENDEDOR->A1_VEND))
      M->AD1_NOMVEN := ""
      Return ""
   Endif

   M->AD1_NOMVEN := T_VENDEDOR->A3_NOME
   
Return T_VENDEDOR->A1_VEND