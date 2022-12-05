#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM230.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 28/04/2014                                                          *
// Objetivo..: Gatilho que verifica se usuário tem permissão para alterar o campo  *
//             TES do cadastro de Pedido de Venda                                  *
//**********************************************************************************

User Function AUTOM230()

   Local cSql   := ""
   Local _Grupo := ""

   U_AUTOM628("AUTOM230")
   
   // Verifica se grupo do usuário pode realiza a pesquisa de Consulta de Preço
   If Alltrim(Upper(cUserName)) == "ADMINISTRADOR"

      Return(.T.)

   Else

      lPesquisa := .T.
      _Grupo    := ""             

      PswOrder(2)
     
      // Seek para pesquisar dados do usuário logado. .F., para capturar dados de grupos do usuário logado
      If PswSeek(cUserName,.F.)

         // Obtem o resultado conforme vetor
         _aRetUser := PswRet(1)

         // Carrega o código do grupo do usuário
         If Len(_aRetUser[1][10]) <> 0
            If Len(_aRetUser[1][10]) == 0
               _Grupo := ""
            Else   
               _Grupo := _aRetUser[1][10][1]
            Endif    
         Else
            _Grupo := ""       
         Endif

      Endif

   Endif
      
   // Verifica se o grupo do usuário tem permissão para realizar a pesquisa
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_TESP" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      Return(.F.)
   Else

      If U_P_OCCURS(T_PARAMETROS->ZZ4_TESP, _Grupo, 1) == 0
         Return(.F.)
      Endif

   Endif

Return(.T.)