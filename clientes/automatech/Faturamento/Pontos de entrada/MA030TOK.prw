#INCLUDE "PROTHEUS.CH"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: M030TOK.PRW                                                         ##
// Par�metros: Nenhum                                                              ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                             ##
// Data......: 11/03/2014                                                          ##
// Objetivo..: Ponto de Entrada que valida campos antes da grava��o do Cadastro de ##
//             Clientes.                                                           ##
// ##################################################################################

User Function MA030TOK()

   Local cSql      := ""

   U_AUTOM628("MA030TOK")

   If M->A1_PESSOA == "J"
      If Len(Alltrim(M->A1_CGC)) <> 14
         MsgAlert("CNPJ inv�lido. Verifique!")
         Return(.F.)
      Endif
   Else
      If Len(Alltrim(M->A1_CGC)) <> 11
         MsgAlert("CPF inv�lido. Verifique!")
         Return(.F.)
      Endif
   Endif
   
   If M->A1_GRPTRIB == "003"
      If A1_IENCONT == "1"
         If Alltrim(M->A1_INSCR) == "ISENTO"
            MsgAlert("Aten��o!"                                              + chr(13) + chr(10) + chr(13) + chr(10) + ;
                     "Pela configura��o informada no cadastro, mesmo sendo"  + chr(13) + chr(10) + ;
                     "Grupo Tribut�rio = IE  Isenta, esta n�o  poder�  ser"  + chr(13) + chr(10) + ;
                     "Isenta em rez�o do campo Destaca IE (�ltima aba)estar" + chr(13) + chr(10) + ;
                     "configurado com SIM.")
            Return(.F.)
         Endif
      Else   
         If Alltrim(M->A1_INSCR) <> "ISENTO"
            MsgAlert("IE informada est� inv�lida. Verifique a IE ou Grupo Tribut�rio do Cliente.")
            Return(.F.)
         Endif
      Endif   
   Endif
                 
   If M->A1_GRPTRIB == "002"
      If Alltrim(M->A1_INSCR) == "ISENTO"
         MsgAlert("IE informada est� inv�lida. Verifique a IE ou Grupo Tribut�rio do Cliente.")
         Return(.F.)
      Endif
   Endif

   // ###########################################################################
   // Se for inclus�o de clientes, verifica se o nome do contato foi informado ##
   // ###########################################################################
   If Inclui
      If Empty(Alltrim(M->A1_NCONT))
         MsgAlert("Campo Nome do Contato do Cliente n�o foi informado. Verifique!")
         Return(.F.)
      Endif
   Endif

   // ###############################
   // Valida o Endere�o do Cliente ##
   // ###############################  
   Do Case 

      // #####################################
      // Se string possui v�rgula, despresa ##
      // #####################################
      Case U_P_OCCURS(M->A1_END, ",", 1) <> 0
           Return(.T.)

      // ################################
      // Se string possui BR, despresa ##
      // ################################  
      Case U_P_OCCURS(M->A1_END, "BR", 1) <> 0 
           Return(.T.)

      // ################################
      // Se string possui KM, despresa ##
      // ################################
      Case U_P_OCCURS(M->A1_END, "KM", 1) <> 0
           Return(.T.)

      Otherwise
           MsgAlert("Aten��o!"                                                                + chr(13) + chr(13) + ;
                    "A separa��o do n� do endere�o do cliente deve ser separado por v�rgula:" + chr(13) + chr(13) + ;
                    "Exemplo:"                                                                + chr(13) + Chr(13) + ;
                    "Rua das Laranjeiras, 1000")
           Return(.F.)
   EndCase

Return(.T.)