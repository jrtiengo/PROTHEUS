#INCLUDE 'rwmake.ch'
#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM213.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 07/03/2014                                                          *
// Objetivo..: Gatilho que verifica se a ocorrência informada no chamado técnico   *
//             pode ser utilizada.                                                 *
// -----------------------------------------------------------------------------   *
// Parâmetros: _CodOcor -> Código da Ocorrência                                    *
//**********************************************************************************

User Function AUTOM213(_CodOcor)

   Local cSql := ""
 
   If Empty(Alltrim(_CodOcor))
      Return ""
   Endif
   
   // Pesquisa a ocorrência para verificação
   If Select("T_OCORRENCIA") > 0
      T_OCORRENCIA->( dbCloseArea() )
   EndIf
   
   cSql := ""   
   cSql := "SELECT AAG_USUAR"
   cSql += "  FROM " + RetSqlName("AAG")
   cSql += " WHERE AAG_CODPRB = '" + Alltrim(_CodOcor) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OCORRENCIA", .T., .T. )

   If T_OCORRENCIA->( EOF() )
      Return ""   
   Endif
      
   If T_OCORRENCIA->AAG_USUAR <> "S"
      MsgAlert("Atenção!" + Chr(13) + Chr(10) + "Esta ocorrência está parametrizada para não ser utilizada." + Chr(13) + Chr(10) + "Verifique cadastro.")
      Return ""
   Endif   

Return _CodOcor    