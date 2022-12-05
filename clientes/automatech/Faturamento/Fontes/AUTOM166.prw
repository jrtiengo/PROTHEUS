#include "Protheus.ch"                             
#include "topconn.ch"
#include "fileio.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM166.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 09/04/2013                                                          *
// Objetivo..: Valida de pode ou não abrir os campos quantidade, preço unitário  e *
//             valor total do pedido de venda. Somente permite editar estes campos *
//             se PV não for de ordem de Serviço.                                  * 
//**********************************************************************************

User Function AUTOM166(_Pedido)

   Local cSql := ""

   U_AUTOM628("AUTOM166")

   // Pesquisa se o PV é proveniente de ordem de serviço
   If Select("T_PODEEDITAR") > 0
      T_PODEEDITAR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT C6_NUMOS"
   cSql += "  FROM " + RetSqlName("SC6")
   cSql += " WHERE C6_FILIAL = '" + Alltrim(xFilial("SC6")) + "'"
   cSql += "   AND C6_NUM    = '" + Alltrim(_Pedido)        + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
   cSql := ChangeQuery( cSql )

   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PODEEDITAR", .T., .T. )

   If T_PODEEDITAR->( EOF() )
      Return .T.
   Endif
   
   If Empty(Alltrim(T_PODEEDITAR->C6_NUMOS))
      Return .T.
   Else
      Return .F.
   Endif

Return .T.