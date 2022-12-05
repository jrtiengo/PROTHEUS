#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM223.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  (X) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 28/03/2014                                                          *
// Objetivo..: Gatilho que verifica se usuário logado pode incluir movimnetos no   *
//             Contas a Receber com o Tipo RA - Recebimento Antecipado.            *
//**********************************************************************************

User Function AUTOM224()

   Local cSql     := ""
   Local cRetorno := M->E1_TIPO

   If Alltrim(M->E1_TIPO) <> "RA"
      Return cRetorno
   Endif

   // Pesquisa os usuários autorizados a lançar RA's
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_LARA" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      Msgalert("Atenção! Usuário não possui autorização de realizar lançamentos do tipo RA.")
      M->E1_TIPO := ""
      cRetorno   := ""
      Return cRetorno
   Endif

   If U_P_OCCURS(T_PARAMETROS->ZZ4_LARA, Alltrim(Upper(cUserName)), 1) == 0
      Msgalert("Atenção! Usuário não possui autorização de realizar lançamentos do tipo RA.")
      M->E1_TIPO := ""
      cRetorno   := ""
      Return cRetorno
   Endif

Return cRetorno