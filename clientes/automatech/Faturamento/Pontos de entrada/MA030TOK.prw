#INCLUDE "PROTHEUS.CH"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: M030TOK.PRW                                                         ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 11/03/2014                                                          ##
// Objetivo..: Ponto de Entrada que valida campos antes da gravação do Cadastro de ##
//             Clientes.                                                           ##
// ##################################################################################

User Function MA030TOK()

   Local cSql      := ""

   U_AUTOM628("MA030TOK")

   If M->A1_PESSOA == "J"
      If Len(Alltrim(M->A1_CGC)) <> 14
         MsgAlert("CNPJ inválido. Verifique!")
         Return(.F.)
      Endif
   Else
      If Len(Alltrim(M->A1_CGC)) <> 11
         MsgAlert("CPF inválido. Verifique!")
         Return(.F.)
      Endif
   Endif
   
   If M->A1_GRPTRIB == "003"
      If A1_IENCONT == "1"
         If Alltrim(M->A1_INSCR) == "ISENTO"
            MsgAlert("Atenção!"                                              + chr(13) + chr(10) + chr(13) + chr(10) + ;
                     "Pela configuração informada no cadastro, mesmo sendo"  + chr(13) + chr(10) + ;
                     "Grupo Tributário = IE  Isenta, esta não  poderá  ser"  + chr(13) + chr(10) + ;
                     "Isenta em rezão do campo Destaca IE (última aba)estar" + chr(13) + chr(10) + ;
                     "configurado com SIM.")
            Return(.F.)
         Endif
      Else   
         If Alltrim(M->A1_INSCR) <> "ISENTO"
            MsgAlert("IE informada está inválida. Verifique a IE ou Grupo Tributário do Cliente.")
            Return(.F.)
         Endif
      Endif   
   Endif
                 
   If M->A1_GRPTRIB == "002"
      If Alltrim(M->A1_INSCR) == "ISENTO"
         MsgAlert("IE informada está inválida. Verifique a IE ou Grupo Tributário do Cliente.")
         Return(.F.)
      Endif
   Endif

   // ###########################################################################
   // Se for inclusão de clientes, verifica se o nome do contato foi informado ##
   // ###########################################################################
   If Inclui
      If Empty(Alltrim(M->A1_NCONT))
         MsgAlert("Campo Nome do Contato do Cliente não foi informado. Verifique!")
         Return(.F.)
      Endif
   Endif

   // ###############################
   // Valida o Endereço do Cliente ##
   // ###############################  
   Do Case 

      // #####################################
      // Se string possui vírgula, despresa ##
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
           MsgAlert("Atenção!"                                                                + chr(13) + chr(13) + ;
                    "A separação do nº do endereço do cliente deve ser separado por vírgula:" + chr(13) + chr(13) + ;
                    "Exemplo:"                                                                + chr(13) + Chr(13) + ;
                    "Rua das Laranjeiras, 1000")
           Return(.F.)
   EndCase

Return(.T.)