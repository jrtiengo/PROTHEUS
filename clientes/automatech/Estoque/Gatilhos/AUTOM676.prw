#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"                                                         

// ########################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                                 ##
// ------------------------------------------------------------------------------------- ##
// Referencia: AUTOM676.PRW                                                              ##
// Par�metros: Nenhum                                                                    ##
// Tipo......: ( ) Programa  ( ) Ponto de Entrada  (X) Gatilho                           ##
// ------------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                                   ##
// Data......: 15/02/2018                                                                ##
// Objetivo..: Gatilho que inverte o campo C2_ZQTD X C2_QUANT                            ##
//             Invers�o realizada no momento do encerramento da Ordem de Produ��o        ##
// Par�metros: Sem par�metros                                                            ##
// ########################################################################################

User Function AUTOM676()
       
   Local nOriginal   := M->D3_QUANT
   Local nQuantidade := 0
   Local nProducao   := ""
   Local nItem       := ""
   Local nSequencia  := ""
                        
   If Empty(Alltrim(M->D3_OP))
      Return(nOriginal)
   Endif
      
   nProducao  := Substr(M->D3_OP,01,06)
   nItem      := Substr(M->D3_OP,07,02)
   nSequencia := Substr(M->D3_OP,09,03)

   // #########################################################################################################
   // Pesquisa a ordem de produ��o informada/selecionada para capturar a quantidade para troca se necess�rio ##
   // #########################################################################################################
   DbSelectArea("SC2")

   If DBSEEK(xFilial("SC2") + nProducao + nItem + nSequencia)
      If SC2->C2_ZQTD == 0
      Else
         nQuantidade := SC2->C2_ZQTD
      Endif   
   Endif

Return(nQuantidade)