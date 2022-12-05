#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AT400APN.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 10/04/2013                                                          *
// Objetivo..: Ponto de entrada disparado na Confirmação do Apontamento da OS      *
//             Verifica os códigos de serviços utilizados no apontamento. Caso o   *
//             tipo de serviço tiver com o campo AA5_RECUS == "S", indica que  o   *
//             Orçamento foi Reprovado.                                            *
//**********************************************************************************

User Function AT400APN()

   Local cSql    := ""
   Local nContar := 0
   Local nSim    := 0
   Local nNao    := 0
  
   // Verifica os códigos dos serviços informados no apontamento
   For nContar = 1 to Len(acols)
   
       // Pesquisa se o PV é proveniente de ordem de serviço
       If Select("T_APONTAMENTO") > 0
          T_APONTAMENTO->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT AA5_RECUS"
       cSql += "  FROM " + RetSqlName("AA5")
       cSql += " WHERE AA5_CODSER = '" + Alltrim(aCols[nContar][4]) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_APONTAMENTO", .T., .T. )

       If T_APONTAMENTO->AA5_RECUS == "S"
          nSim := nSim + 1
       Else
          nNao := nNao + 1
       Endif
      
   Next nContar
   
   // Verifica se deve reprovar o Orçamento
   If nSim <> 0 .And. nNao == 0
      M->AB3_SITUA := "R"
   Endif

Return(.T.)