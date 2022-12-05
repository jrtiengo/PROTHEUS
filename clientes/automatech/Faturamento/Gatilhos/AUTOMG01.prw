#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMG01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  (X) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 14/09/2011                                                          *
// Objetivo..: Gatilho que verifica se os vendedores da Opotunidade são válidos.   *
// Alterações: 06/12/2011 - Não pode ter dois vendedores iguais                    *
//**********************************************************************************

// Função que define a Window
User Function AUTOMG01( _Vendedor, _Qual)   

   Local cSql := ""

   U_AUTOM628("AUTOMG01")

   If Empty(Alltrim(_Vendedor))
      Return Space(06)
   Endif
   
   // Verifica se o Vendedo informado está cadastrado
   If Select("T_VENDEDOR") > 0
      T_VENDEDOR->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT A3_COD, "
   cSql += "       A3_NOME "
   cSql += "  FROM " + RetSqlName("SA3010")
   cSql += " WHERE A3_COD = '" + Alltrim(_Vendedor) + "'"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

   If T_VENDEDOR->( Eof() )
      MsgAlert("Vendedor informado não cadastrado.")
      IIF(_Qual == 1, M->AD1_VEND := Space(06), M->AD1_VEND2 := Space(06))
      Return Space(06)
   Endif

   // Verifica se já foi informado o vendedor na oportunidade
   If Alltrim(M->AD1_VEND) == Alltrim(M->AD1_VEND2)
      MsgAlert("Vendedor já informado.")
      IIF(_Qual == 1, M->AD1_VEND := Space(06), M->AD1_VEND2 := Space(06))
      Return Space(06)
   Endif
   
Return _Vendedor