#INCLUDE "protheus.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM196.PRW                                                        ##
// Par�metros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                             ##
// Data......: 06/11/2013                                                          ##
// Objetivo..: Ponto de Entrada disparado na inclus�o do Cadastro de produtos.     ##
//             A finalidade deste � bloquear o produto inclu�do at� que os respon- ##
//             s�veis pela libera��o (Fiscal), libere o produto para uso.          ##
// ##################################################################################

User Function MT010INC()
 
   Local cSql   := ""
   Local cTexto := ""

   U_AUTOM628("MT010INC")

   // #######################################################################
   // Atualiza o produto inclu�do enviando-o para Solicita��o de Libera��o ##
   // #######################################################################
   If SB1->B1_INTER == "S"
   Else
      RecLock("SB1",.F.)         
      SB1->B1_MSBLQL := "1"
      SB1->B1_USUI   := cusername
      SB1->B1_DATAI  := DATE()
      SB1->B1_HORAI  := TIME()
      SB1->B1_STLB   := "S"
      MsUnLock()              
   Endif   

   // #####################################################################################################
   // Envia para o programa que calcula a quantidade de etiquetas por rolo em caso de produtos Etiquetas ##
   // #####################################################################################################
   U_AUTOM552(SB1->B1_COD, 0)   

   // ################################################################
   // Pesquisa o e-mail do(s) Liberador(es) do Cadastro de Produtos ##
   // ################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ4_LIBE "
   cSql += "  FROM " + RetSqlName("ZZ4")
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !Empty(Alltrim(T_PARAMETROS->ZZ4_LIBE))
      cTexto := ""
      cTexto := "Aten��o!" + chr(13) + chr(10) + chr(13) + chr(10)
      cTexto += "Existem produtos que foram inclu�dos no Cadastro de Produtos e estes encontram-se bloqueados aguardando a sua libera��o para utiliza��o." + chr(13) + chr(10)
      cTexto += "Favor realizar a an�lise e libera��o dos produtos." + chr(13) + chr(10) + chr(13) + chr(10)
      cTexto += "Automatech Sistemas de Automa��o Ltda" + chr(13) + chr(10)
      cTexto += "Sistema Protheus" + chr(13) + chr(10)
      
      // ############################
      // Envia e-mail ao Aprovador ##
      // ############################

      // #############################################################################################################################
      // Foi solicitado pelo Sr. Roger em 15/05/2018 que o e-mail de eviso de produos a serem liberados n�o � mais para ser enviado ##
      // #############################################################################################################################
      // U_AUTOMR20(cTexto, Alltrim(T_PARAMETROS->ZZ4_LIBE), "", "Solicita��o de Libera��o de Cadastro de Produto" )
   Endif

   If SB1->B1_INTER == "S"
   Else
      MsgAlert("Aten��o!"                                                                    + chr(13) + chr(13) + chr(13) + chr(10) + ;
               "O produto inclu�do ficar� bloqueado at� este ser validado pela �rea Fiscal." + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Voc� receber� um e-mail lhe informando quando este estiver liberado para uso.")
   Endif
   
Return(.T.)   