#INCLUDE 'rwmake.ch'
#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM213.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 07/03/2014                                                          *
// Objetivo..: Gatilho que verifica se a ocorr�ncia informada no chamado t�cnico   *
//             pode ser utilizada.                                                 *
// -----------------------------------------------------------------------------   *
// Par�metros: _CodOcor -> C�digo da Ocorr�ncia                                    *
//**********************************************************************************

User Function AUTOM213(_CodOcor)

   Local cSql := ""
 
   If Empty(Alltrim(_CodOcor))
      Return ""
   Endif
   
   // Pesquisa a ocorr�ncia para verifica��o
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
      MsgAlert("Aten��o!" + Chr(13) + Chr(10) + "Esta ocorr�ncia est� parametrizada para n�o ser utilizada." + Chr(13) + Chr(10) + "Verifique cadastro.")
      Return ""
   Endif   

Return _CodOcor    