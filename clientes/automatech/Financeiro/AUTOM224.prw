#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM223.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: ( ) Programa  (X) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 28/03/2014                                                          *
// Objetivo..: Gatilho que verifica se usu�rio logado pode incluir movimnetos no   *
//             Contas a Receber com o Tipo RA - Recebimento Antecipado.            *
//**********************************************************************************

User Function AUTOM224()

   Local cSql     := ""
   Local cRetorno := M->E1_TIPO

   If Alltrim(M->E1_TIPO) <> "RA"
      Return cRetorno
   Endif

   // Pesquisa os usu�rios autorizados a lan�ar RA's
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_LARA" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      Msgalert("Aten��o! Usu�rio n�o possui autoriza��o de realizar lan�amentos do tipo RA.")
      M->E1_TIPO := ""
      cRetorno   := ""
      Return cRetorno
   Endif

   If U_P_OCCURS(T_PARAMETROS->ZZ4_LARA, Alltrim(Upper(cUserName)), 1) == 0
      Msgalert("Aten��o! Usu�rio n�o possui autoriza��o de realizar lan�amentos do tipo RA.")
      M->E1_TIPO := ""
      cRetorno   := ""
      Return cRetorno
   Endif

Return cRetorno