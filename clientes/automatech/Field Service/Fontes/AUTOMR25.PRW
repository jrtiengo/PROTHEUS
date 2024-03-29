#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR25.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 10/10/2011                                                          *
// Objetivo..: Gatilho que verifica se o atendimento possui informa��o de aponta-  *
//             mento. Caso n�o existir, n�o permite que o  atendimento tenha se-   *
//             quencia.                                                            *
// Altera��o.: 17/11/2011 - Primeiro verificar� na tabela AB5 se n�o encontrar     *
//                          veriricar� na tabela AB8.                              *
//**********************************************************************************

User Function AUTOMR25(AB9_NUMOS)
 
   // Vari�veis Locais da Fun��o
   Local cSql := ""

   If Empty(Alltrim(AB9_NUMOS))
      Return .T.
   Endif

   If Select("T_ATENDE") > 0
      T_ATENDE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AB8_CODPRO "
   cSql += "  FROM " + RetSqlName("AB8010")
   cSql += " WHERE AB8_NUMOS  = '" + ALLTRIM(Substr(AB9_NUMOS,01,06)) + "'"
   cSql += "   AND AB8_FILIAL = '" + ALLTRIM(cFilAnt) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATENDE", .T., .T. )

   DbSelectArea("T_ATENDE")

   If EOF() .And. FunName() != 'TECA450'
      MsgAlert("Aten��o !!" + chr(13) + chr(13) + "Atendimento sem informa��o de Apontamento." + chr(13) + "Para realizar o atendimento, informe primeiramente os apontamentos.")
      M->AB9_NUMOS := ""
   Endif
      
Return M->AB9_NUMOS