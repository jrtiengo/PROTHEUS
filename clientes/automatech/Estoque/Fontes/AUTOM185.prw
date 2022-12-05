#Include "Protheus.ch"

//************************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                             *
// --------------------------------------------------------------------------------- *
// Referencia: AUTOM185.PRW                                                          *
// Parâmetros: Nenhum                                                                *
// Tipo......: (X) Programa  ( ) Gatilho                                             *
// --------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                               *
// Data......: 05/08/2013                                                            *
// Objetivo..: Programa que abre o Historico de Produtos                             *
//************************************************************************************

User Function AUTOM185()

   Local cSql      := ""
   Local lPesquisa := .F.
   Local _Grupo    := ""

   U_AUTOM628("AUTOM185")
   
   // Define a ordem de pesquisa de usuários 2 -> por nome
   If Alltrim(Upper(cUserName)) == "ADMINISTRADOR"

      lPesquisa := .F.

   Else

      lPesquisa := .T.
      _Grupo    := ""             

      PswOrder(1) // Seek pelo ID do usuário
//    PswOrder(2) // Seek pelo Nome do Usuário
     
      // Seek para pesquisar dados do usuário logado. .F., para capturar dados de grupos do usuário logado
      If PswSeek(__cUserID,.T.)
//    If PswSeek(cUserName,.F.)

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
      
   // Verifica se o grupo pesquisa pertence aos grupos paramentrizados para acesso
   If lPesquisa        

      If Select("T_PARAMETROS") > 0
         T_PARAMETROS->( dbCloseArea() )
      EndIf
   
      cSql := ""
      cSql := "SELECT ZZ4_KARD" 
      cSql += "  FROM " + RetSqlName("ZZ4")

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

      If T_PARAMETROS->( EOF() )
         MsgAlert("Atenção! Usuário sem permissão para executar este procedimento." + chr(13) + chr(10) + "Entre em contato com o seu supervisor solicitando acesso a este procedimento.")
         Return .T.
      Else

         If U_P_OCCURS(T_PARAMETROS->ZZ4_KARD, _Grupo, 1) == 0
            MsgAlert("Atenção! Usuário sem permissão para executar este procedimento." + chr(13) + chr(10) + "Entre em contato com o seu supervisor solicitando acesso a este procedimento.")
            Return .T.
         Endif

      Endif
      
   Endif

   MaComView(SB1->B1_COD)

Return .T.