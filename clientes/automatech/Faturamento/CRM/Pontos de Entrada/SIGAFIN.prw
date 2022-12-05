#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: SIGAFIN.PRW                                                         *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho (X) Ponto de Entrada                      *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 25/01/2012                                                          *
// Objetivo..: Ponto de Entrada que verifica se deve ser aberto a tela de estatis- *
//             tica de cobrança.                                                   *
//**********************************************************************************

User Function SIGAFIN()

   Local cSql    := ""
   Local cCodigo := RetCodUsr()

   Public _Rodar

   Default _Rodar := .F.

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
   
Return .F.