#include "Protheus.ch"                             

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR71.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 30/03/2012                                                          *
// Objetivo..: Programa que realiza a pesquisa o n�mero da nota fiscal de origem   *
//             dos lan�amentos do tipo NCC do Contas a Receber.                    *
//**********************************************************************************

User Function AUTOMR71( _Tipo, _Nota, _Filial)

   Local cSql   := ""
   Local cNotas := ""

   If Alltrim(_Tipo) <> "NCC"
      Return ""                                           
   Endif

   // Pesquisa a nota fiscal de Origem
   If Select("T_ORIGEM") > 0
   	  T_ORIGEM->( dbCloseArea() )
   EndIf

   cSql := ""      
   cSql := "SELECT D1_NFORI"
   cSql += "  FROM " + RetSqlName("SD1")
   cSql += " WHERE D1_FILIAL    = '" + Alltrim(_Filial) + "'"
   cSql += "   AND D1_DOC       = '" + Alltrim(_Nota)   + "'"
   cSql += "   AND R_E_C_D_E_L_ = ''"
   cSql += " GROUP BY D1_NFORI"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ORIGEM", .T., .T. )
   
   If T_ORIGEM->( EOF() )
      Return ""
   Endif

   T_ORIGEM->( DbGoTop() )
   WHILE !T_ORIGEM->( EOF() )
      If Alltrim(T_ORIGEM->D1_NFORI) <> ""
         cNotas := cNotas + Alltrim(T_ORIGEM->D1_NFORI) + ","
      Endif
      T_ORIGEM->( DbSkip() )   
   ENDDO

   // Elimina a �ltima v�rgula
   cNotas := Substr(cNotas,01,Len(cNotas) - 1)
   
Return cNotas