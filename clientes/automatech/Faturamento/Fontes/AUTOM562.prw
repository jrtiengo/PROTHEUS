#INCLUDE "protheus.ch"
#INCLUDE "ap5mail.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM562.PRW                                                        ##
// Par�metros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                             ##
// Data......: 18/04/2017                                                          ##
// Objetivo..: Programa que retorna .T./.F. liberando a edi��o do campo A1_ZCOMP   ##
//             Cliente Compartilhado                                               ##
//             Este campo somente poder� estar liberado ara edi��o para determina- ##
//             dos grupos de usu�rios conforme abaixo.                             ##
// Par�metros: Sem Par�metros                                                      ##
// ##################################################################################

User Function AUTOM562()
 
   Local xx       := 0
   Local _lLibera := .F.

   U_AUTOM628("AUTOM562")

   // #######################################################
   // Define a ordem de pesquisa de usu�rios 2 -> por nome ##
   // #######################################################
   PswOrder(2)
     
   // ####################################################################################################
   // Seek para pesquisar dados do usu�rio logado. .F., para capturar dados de grupos do usu�rio logado ##
   // ####################################################################################################
   If PswSeek(cUserName,.F.)

      // ###################################
      // Obtem o resultado conforme vetor ##
      // ###################################
      _aRetUser := PswRet(1)

      _Grupo   := ""
      _lLibera := .F.

      // #######################################
      // Carrega o c�digo do grupo do usu�rio ##
      // #######################################
      If Len(_aRetUser[1][10]) <> 0

         If Len(_aRetUser[1][10]) == 0

            _Grupo   := ""
            _lLibera := .F.

         Else   

            _Grupo   := _aRetUser[1][10][1]
            _lLibera := .F.

            For xx = 1 to Len(_aRetUser[1][10])
                If _Grupo$("000026#000003#000006#000004#�000024#000000#000041")
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