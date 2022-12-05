#Include "Rwmake.ch"
#Include "Topconn.ch"
#Include "AP5Mail.ch"
#Include "Protheus.ch"
#INCLUDE "protheus.ch"
#INCLUDE "XMLXFUN.CH"
#Include "Tbiconn.Ch"

// #######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                                ##
// ------------------------------------------------------------------------------------ ##
// Referencia: AUTOM614.PRW                                                             ##
// Par�metros: Nenhum                                                                   ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                          ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans L�schenkohl                                                  ##
// Data......: 15/08/2017                                                               ##
// Objetivo..: Programa que envia e-mail com anexo                                      ##
// Par�metros: cTiulo    = T�tulo do E-Mail                                             ##
//             cDestina  = E-mail do Destinat�rio                                       ## 
//             cCco      = E-mail de quem enviou o E-mail                               ##
//             cMensagem = Mensagem do E-mail                                           ##
//             cArquivos = Arquivos a serem enviados no E-mail                          ## 
//                                                                                      ##
// Exemplo de chamada da fun��o                                                         ##
//                                                                                      ##
// U_AUTOM613("Documentos Referente a NF N� 004661/1"    ,;                             ##
//            "harald@automatech.com.br"                 ,;                             ##
//            "naoresponda@comunicados.automatech.com.br",;                             ##
//            "Seguem em anexo os documentos referente a NF N� 004661 S�rie 1",;        ##
//            "\XML_DANFE\boleto_081286_1.pdf" + ";" + "\XML_DANFE\danfe_004681_1.pdf") ##
// ######################################################################################

User Function AUTOM613(cTitulo,cDestina,cCco,cMensagem, cArquivos) 

   Local nInd, cBody
   Local lResult       := .f.                    // Resultado da tentativa de comunicacao com servidor de E-Mail
   Local cDestin       := cDestina               // E-mail do Destinat�rio
   Local cTitulo       := cTitulo                // T�tulo do E-Mail
   Local cMensagem     := cMensagem              // Mensagem do E-mail
   Local cFrom         := cCco                   // E-mai lde quem est� enviando o E-mail (naoresponda (Fixo))
   Local cAnexo        := cArquivos              // Arquivos a serem anexados ao E-mail Exemplo: "\XML_DANFE\boleto_081286_1.pdf" + ";" + "\XML_DANFE\danfe_004681_1.pdf"
   Local lAutentica    := GetMV("MV_RELAUTH")    // Verifica se necessita de Autentica��o
   Local cEmailTo      := cDestin                // Vari�vel utilizada para display de erro

   U_AUTOM628("AUTOM613")

// PREPARE ENVIRONMENT EMPRESA '01' FILIAL '06'

   // #########################################
   // Tenta conexao com o servidor de E-Mail ##
   // #########################################
   CONNECT SMTP                        ;
           SERVER   GetMV("MV_RELSERV"); // Nome do servidor de e-mail
           ACCOUNT  GetMV("MV_RELACNT"); // Nome da conta a ser usada no e-mail
           PASSWORD GetMV("MV_RELPSW") ; // Senha
           RESULT   lResult              // Resultado da tentativa de conex�o
 
   lxDeuErro := .F.

   If lResult
   
      // ################################################# 
      // Verifica se o E-mail necessita de Autenticacao ##
      // #################################################
      If lAutentica     
         lRet := MailAuth(GetMV("MV_RELACNT"),GetMV("MV_RELPSW")) 
      Else
         lRet := .T.
      Endif
     
      If lRet

         SEND MAIL                 ;
              FROM       cCco      ;
              TO         cDestin   ;
              SUBJECT    cTitulo   ;
              BODY       cMensagem ;
              ATTACHMENT cAnexo    ;
              RESULT     lResult 
     
         If !lResult
         
            // #########################
            // Erro no envio do email ##
            // #########################
//            GET MAIL ERROR cError
//            Help(" ",1,"ATENCAO",,cError+ " " + cEmailTo,4,5)     //STR0006
              lxDeuErro := .T.
         Endif
  
      Else
  
//         GET MAIL ERROR cError
//         Help(" ",1,"Autenticacao",,cError,4,5)
//         MsgStop("Erro de autentica��o","Verifique a conta e a senha para envio")
         lxDeuErro := .T.
  
      Endif
     
      // ##################################################################
      // (MailSend(cMailConta,{cEmail},{},{},cSubject,cMensagem,aFiles)) ##
      // ##################################################################

      // ############################################
      // Finaliza conexao com o servidor de E-Mail ##
      // ############################################
      DISCONNECT SMTP SERVER    

   Else

      // ####################################
      // Erro na conexao com o SMTP Server ##
      // ####################################
//      GET MAIL ERROR cError
//      Help(" ",1,"Atencao",,cError,4,5)
      lxDeuErro := .T.

   Endif

// RESET ENVIRONMENT

Return(.T.)