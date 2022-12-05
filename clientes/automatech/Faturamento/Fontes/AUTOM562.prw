#INCLUDE "protheus.ch"
#INCLUDE "ap5mail.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM562.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 18/04/2017                                                          ##
// Objetivo..: Programa que retorna .T./.F. liberando a edição do campo A1_ZCOMP   ##
//             Cliente Compartilhado                                               ##
//             Este campo somente poderá estar liberado ara edição para determina- ##
//             dos grupos de usuários conforme abaixo.                             ##
// Parâmetros: Sem Parâmetros                                                      ##
// ##################################################################################

User Function AUTOM562()
 
   Local xx       := 0
   Local _lLibera := .F.

   U_AUTOM628("AUTOM562")

   // #######################################################
   // Define a ordem de pesquisa de usuários 2 -> por nome ##
   // #######################################################
   PswOrder(2)
     
   // ####################################################################################################
   // Seek para pesquisar dados do usuário logado. .F., para capturar dados de grupos do usuário logado ##
   // ####################################################################################################
   If PswSeek(cUserName,.F.)

      // ###################################
      // Obtem o resultado conforme vetor ##
      // ###################################
      _aRetUser := PswRet(1)

      _Grupo   := ""
      _lLibera := .F.

      // #######################################
      // Carrega o código do grupo do usuário ##
      // #######################################
      If Len(_aRetUser[1][10]) <> 0

         If Len(_aRetUser[1][10]) == 0

            _Grupo   := ""
            _lLibera := .F.

         Else   

            _Grupo   := _aRetUser[1][10][1]
            _lLibera := .F.

            For xx = 1 to Len(_aRetUser[1][10])
                If _Grupo$("000026#000003#000006#000004#ê000024#000000#000041")
                   _lLibera := .T.
                   Exit
                Endif
            Next xx                   

         Endif    
   
      Else

         _Grupo   := ""       
         _lLibera := .F.
      
      Endif

   Else
   
      Return .F.
      
   Endif      

   If _lLibera 
      Return(.T.)
   Else
      Return(.F.)      
   Endif

Return(.T.)