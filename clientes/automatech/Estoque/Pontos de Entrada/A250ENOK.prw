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
// Referencia: A250ENOK.PRW                                                              ##
// Parâmetros: Nenhum                                                                    ##
// Tipo......: ( ) Programa  (X) Ponto de Entrada  ( ) Gatilho                           ##
// ------------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                   ##
// Data......: 15/02/2018                                                                ##
// Objetivo..: LOCALIZAÇÃO   :  Executado na função A250EndOk( ) que e responsavel por   ##
//             validar se pode realizar  o  encerramento  de  uma determinada ordem de   ##
//             produção.                                                                 ##
//             EM QUE PONTO : O ponto é disparado apos a confirmação do encerramento e   ##
//             antes da gravação. Deve ser utilizado para validar se o encerramento pode ##
//             ser efetuado ou nao.                                                      ##
// Parâmetros: Sem parâmetros                                                            ##
// ########################################################################################

User Function A250ENOK()

   Local lRet := .T.

   // ###########################################################################################################
   // Tarefa #5032 - Impressão Ordem de produção/encerramento de OP                                            ##
   // Este ponto de entrada foi comentado em razão deste processo estar temporariamente indisponível para uso. ##
   // Descomentar se o processo de coletor para apontamento de produção for colocado no ar                     ##
   // ###########################################################################################################

   // ###################################
   // Atualiza a metragem linear na op ##
   // ###################################
//   DbSelectArea("SC2")
//   If DBSEEK(xFilial("SC2") + SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN)
//
//      nZqtd := SC2->C2_ZQTD
//      nQuan := SC2->C2_QUANT
//      
//      RecLock("SC2",.F.)
//      SC2->C2_ZQTD  := nQuan
//      SC2->C2_QUANT := nZqtd
//      MsUnLock()              
//
//   Endif

Return(lRet)