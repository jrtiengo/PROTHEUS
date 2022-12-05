#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM534.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: ( ) Programa  (X) Gatilho   ( ) Ponto de Entrada                    ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 31/01/2017                                                          ##
// Objetivo..: Gatilho que verifica se o código do vendedor no pedido de venda po- ##
//             de ser liberado para aletração para o usuário logado.               ##
// ################################################################################## 

User Function AUTOM534(_Vendedor)

   U_AUTOM628("AUTOM534")
                 
   If Empty(Alltrim(_Vendedor))

      Return(.T.)

   Else
   
      // #######################################################
      // Define a ordem de pesquisa de usuários 2 -> por nome ##
      // #######################################################
      PswOrder(2)
     
      // ####################################################################################################
      // Seek para pesquisar dados do usuário logado. .F., para capturar dados de grupos do usuário logado ##
      // ####################################################################################################
      If PswSeek(cUserName,.F.)

         // ################################### 
         // Obtém o resultado conforme vetor ##
         // ###################################
         _aRetUser := PswRet(1)

         _Grupo  := ""
         _lLibera := .F.

         // #######################################
         // Carrega o código do grupo do usuário ##
         // #######################################
         If Len(_aRetUser[1][10]) <> 0

            If Len(_aRetUser[1][10]) == 0

               _lLibera := .F.
 
            Else   

               _Grupo   := _aRetUser[1][10][1]
               _lLibera := .F.

               For xx = 1 to Len(_aRetUser[1][10])
                   If _Grupo$("000024#000000#000004")
                      _lLibera := .T.
                      Exit
                   Endif
               Next xx                   

            Endif    
   
         Else

            _lLibera := .F.
      
         Endif

      Else
      
         _lLibera := .F.
                  
      Endif   
      
   Endif      

   If _lLibera 

      If Posicione("SA1", 1, xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_ZCOMP") == "S"
         Return(.F.)
      Else
         Return(.T.)         
      Endif   

   Else
      Return(.F.)      
   Endif

Return(.T.)