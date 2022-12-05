#Include "Protheus.ch"

// ####################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                             ##
// --------------------------------------------------------------------------------- ##
// Referencia: AUTOM181.PRW                                                          ##
// Par�metros: Nenhum                                                                ##
// Tipo......: (X) Programa  ( ) Gatilho                                             ##
// --------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                               ##
// Data......: 19/04/2012                                                            ##
// Objetivo..: Programa que abre o Kardex do produto selecionado na tela de consulta ##
// ####################################################################################

User Function AUTOM181()

   Local cSql      := ""
   Local lPesquisa := .F.
   Local _Grupo    := ""
   
   U_AUTOM628("AUTOM181")

   // #######################################################
   // Define a ordem de pesquisa de usu�rios 2 -> por nome ##
   // #######################################################
   If Alltrim(Upper(cUserName)) == "ADMINISTRADOR"

      lPesquisa := .F.

   Else
           
      lPesquisa := .T.
      _Grupo    := ""             

      PswOrder(1) // Seek pelo ID
//    PswOrder(2) // Seek pelo Nome do Usu�rio
     
      // ####################################################################################################
      // Seek para pesquisar dados do usu�rio logado. .F., para capturar dados de grupos do usu�rio logado ##
      // ####################################################################################################
//    If PswSeek(cUserName,.F.)
      If PswSeek(__cUserID,.T.)

         // ###################################
         // Obtem o resultado conforme vetor ##
         // ###################################
         _aRetUser := PswRet(1)

         // #######################################
         // Carrega o c�digo do grupo do usu�rio ##
         // #######################################
         If Len(_aRetUser[1][10]) <> 0
            If Len(_aRetUser[1][10]) == 0
               _Grupo    := ""
            Else   
               _Grupo := _aRetUser[1][10][1]
            Endif    
         Else
            _Grupo := ""  
            lPesquisa := .F.     
         Endif

      Endif

   Endif
      
   // ###############################################################################
   // Verifica se o grupo pesquisa pertence aos grupos paramentrizados para acesso ##
   // ###############################################################################
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
         MsgAlert("Aten��o! Usu�rio sem permiss�o para executar este procedimento." + chr(13) + chr(10) + "Entre em contato com o seu supervisor solicitando acesso a este procedimento.")
         Return .T.
      Else

         If U_P_OCCURS(T_PARAMETROS->ZZ4_KARD, _Grupo, 1) == 0
            MsgAlert("Aten��o! Usu�rio sem permiss�o para executar este procedimento." + chr(13) + chr(10) + "Entre em contato com o seu supervisor solicitando acesso a este procedimento.")
            Return .T.
         Endif

      Endif
      
   Endif

   // ######################### 
   // Abre tela de perguntas ##
   // #########################
   Pergunte("MTC030",.T.) // Ativa os par�metros sem exibir a tela.

   // #############################
   // Chama o programa do Kardex ##
   // #############################
   Mc030Con()

Return(.T.)