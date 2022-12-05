#INCLUDE "PROTHEUS.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM100.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 18/04/2012                                                          *
// Objetivo..: Gatilho que pesquisa o último atendimento do cliente Field Service  *
//**********************************************************************************

User Function AUTOM100(_Codigo, _Loja)

   Local cSql := ""

   If Empty(Alltrim(_Codigo)) 
      Return _Loja
   Endif
      
   If Empty(Alltrim(_Loja)) 
      Return _Loja
   Endif

   // Pesquisa o último atendimento para o cliente
   If Select("T_ULTIMO") > 0
      T_ULTIMO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AB1_EMISSA " 
   cSql += "  FROM " + RetSqlName("AB1") 
   cSql += " WHERE AB1_CODCLI = '" + Alltrim(_Codigo) + "'"
   cSql += "   AND AB1_LOJA   = '" + Alltrim(_Loja)   + "'"
   cSql += " ORDER BY AB1_EMISSA DESC "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ULTIMO", .T., .T. )

   T_ULTIMO->( DbGoTop() )

   If T_ULTIMO->( EOF() )
      M->AB1_MENS := "1º Atendimento para o Cliente"
   Else
      M->AB1_MENS := "Último atendimento ocorrido em " + Substr(T_ULTIMO->AB1_EMISSA,07,02) + "/" + ;
                                                         Substr(T_ULTIMO->AB1_EMISSA,05,02) + "/" + ;
                                                         Substr(T_ULTIMO->AB1_EMISSA,01,04)
   Endif      

Return _Loja