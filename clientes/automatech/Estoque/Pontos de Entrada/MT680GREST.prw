#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ########################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                 ##
// ------------------------------------------------------------------------------------- ##
// Referencia: MT680GREST.PRW                                                            ##
// Parâmetros: Nenhum                                                                    ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                           ##
// ------------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                   ##
// Data......: 15/02/2018                                                                ##
// Objetivo..: Ponto de Entrada disparado no estorno de Apontamento de Produção Mod. 2   ##
// Parâmetros: Sem parâmetros                                                            ##
// ########################################################################################

User Function MT680GREST()	

   Local nOriginal   := 0
   Local nQuantidade := 0                                                
   Local nProducao   := ""
   Local nItem       := ""
   Local nSequencia  := ""
                        
   If Empty(Alltrim(M->H6_OP))
      Return(.T.)
   Endif
      
   nProducao  := Substr(M->H6_OP,01,06)
   nItem      := Substr(M->H6_OP,07,02)
   nSequencia := Substr(M->H6_OP,09,03)

   // #########################################################################################################
   // Pesquisa a ordem de produção informada/selecionada para capturar a quantidade para troca se necessário ##
   // #########################################################################################################
   DbSelectArea("SC2")

   If DBSEEK(xFilial("SC2") + nProducao + nItem + nSequencia)
      If SC2->C2_ZQTD == 0
      Else

         nQuan := SC2->C2_QUANT
         nZqtd := SC2->C2_ZQTD

         RecLock("SC2",.F.)
         SC2->C2_QUANT:= nZqtd
         SC2->C2_ZQTD := nQuan
         SC2->C2_QUJE := 0 
         MsUnLock()             

      Endif   

   Endif                     
   
Return(.T.)