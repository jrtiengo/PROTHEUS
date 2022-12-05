#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM305.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 13/08/2015                                                          *
// Objetivo..: Programa que pesquisa o nº da nota fiscal do RPS e mostra-o na tela *
//             das Funções do Contas a Receber.                                    *
//**********************************************************************************

User Function AUTOM305(__Nota, __Serie)

   Local cSql := ""

   If Alltrim(__Serie) <> "11" .And. Alltrim(__Serie) <> "13"
      Return ""
   Endif

   // Pesquisa o nº da nota fiscal do RPS conforme parâmetros
   If Select("T_SERVICO") > 0
      T_SERVICO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT F2_NFELETR  "
   cSql += "  FROM " + RetSqlName("SF2")
   cSql += " WHERE F2_DOC     = '" + Alltrim(__Nota)  + "'"
   cSql += "   AND F2_SERIE   = '" + Alltrim(__Serie) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERVICO", .T., .T. )
   
   If T_SERVICO->( EOF() )
      Return ""
   Endif
   
Return T_SERVICO->F2_NFELETR