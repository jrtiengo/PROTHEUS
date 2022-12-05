#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: SIGATMK.PRW                                                         *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho (X) Ponto de Entrada                      *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 25/01/2012                                                          *
// Objetivo..: Ponto de Entrada no login do Módulo de Call Center.                 *
//**********************************************************************************

User Function SIGATMK()

   Local cSql    := ""
   Local cCodigo := RetCodUsr()

   Public _VeMensagem
   Public _Rodar
   Public _News
   Public _Ativi
   Public _Validacao

   Default _VeMensagem := .F.
   Default _Rodar      := .F.
   Default _News       := .F.
   Default _Ativi      := .F.
   Default _Validacao  := .F.

   U_AUTOM628("SIGATMK")

   // Prothelito News
   If !_VeMensagem
      U_AUTOM338()
   Endif

   // Verifica se existem atividades a ser executadas
   If !_Ativi
      U_ATVATI15()
   Endif

   // Verifica se o usuário que se logou é cobrador
   If Select("T_COBRADOR") > 0
      T_COBRADOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT U7_COD    ,"
   cSql += "       U7_CODUSU ,"
   cSql += "       U7_TIPOATE,"
   cSql += "       U7_TIPO    "
   cSql += "  FROM " + RetSqlName("SU7") 
   cSql += " WHERE U7_CODUSU  = '" + Alltrim(cCodigo) + "'"
   cSql += "   AND U7_TIPOATE = '3'"
   cSql += "   AND U7_TIPO    = '1'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COBRADOR", .T., .T. )

   If !T_COBRADOR->( EOF() ) .AND. !_Rodar
      U_AUTOMR84(T_COBRADOR->U7_COD)
   Endif
   
   // Automatech News
   If !_News
      U_AUTOM171()
   Endif

   // Verifica a existência de tarefas a serem visualizadas
   If !_Validacao
      U_ESPVAL02()
   Endif

Return .T.