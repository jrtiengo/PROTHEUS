#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AT400APN.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 10/04/2013                                                          *
// Objetivo..: Ponto de entrada disparado na Confirma��o do Apontamento da OS      *
//             Verifica os c�digos de servi�os utilizados no apontamento. Caso o   *
//             tipo de servi�o tiver com o campo AA5_RECUS == "S", indica que  o   *
//             Or�amento foi Reprovado.                                            *
//**********************************************************************************

User Function AT400APN()

   Local cSql    := ""
   Local nContar := 0
   Local nSim    := 0
   Local nNao    := 0
  
   // Verifica os c�digos dos servi�os informados no apontamento
   For nContar = 1 to Len(acols)
   
       // Pesquisa se o PV � proveniente de ordem de servi�o
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
   
   // Verifica se deve reprovar o Or�amento
   If nSim <> 0 .And. nNao == 0
      M->AB3_SITUA := "R"
   Endif

Return(.T.)