#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM320.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 03/11/2015                                                          *
// Objetivo..: Programa que retorna .T. ou .F. se o usuário logado possui autori-  *
//             zação para alterar o campo A1_Risco do cadastro de clientes.        *
//**********************************************************************************

User Function AUTOM320()

   Local cSql    := ""
   Local nContar := 0 
   Local lVoltar := .F.

   U_AUTOM628("AUTOM320")

   // Pesquisa o parâmetro ZZ4_RISCO para verificar se usuário logado pode alterar o campo Risco Cliente do Cadastro de Clientes
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_RISC FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If Empty(Alltrim(T_PARAMETROS->ZZ4_RISC))
      Return(.F.)
   Endif
      
   For nContar = 1 to U_P_OCCURS(T_PARAMETROS->ZZ4_RISC, "|", 1)

       If Alltrim(Upper(cUserName)) == Alltrim(Upper(U_P_CORTA(T_PARAMETROS->ZZ4_RISC, "|", nContar)))
          lVoltar := .T.
          Exit
       Endif
       
   Next nContar                 

Return lVoltar