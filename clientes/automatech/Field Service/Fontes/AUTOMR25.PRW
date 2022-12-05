#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR25.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 10/10/2011                                                          *
// Objetivo..: Gatilho que verifica se o atendimento possui informação de aponta-  *
//             mento. Caso não existir, não permite que o  atendimento tenha se-   *
//             quencia.                                                            *
// Alteração.: 17/11/2011 - Primeiro verificará na tabela AB5 se não encontrar     *
//                          veriricará na tabela AB8.                              *
//**********************************************************************************

User Function AUTOMR25(AB9_NUMOS)
 
   // Variáveis Locais da Função
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
      MsgAlert("Atenção !!" + chr(13) + chr(13) + "Atendimento sem informação de Apontamento." + chr(13) + "Para realizar o atendimento, informe primeiramente os apontamentos.")
      M->AB9_NUMOS := ""
   Endif
      
Return M->AB9_NUMOS