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
// Referencia: A250ENOK.PRW                                                              ##
// Par�metros: Nenhum                                                                    ##
// Tipo......: ( ) Programa  (X) Ponto de Entrada  ( ) Gatilho                           ##
// ------------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                                   ##
// Data......: 15/02/2018                                                                ##
// Objetivo..: LOCALIZA��O   :  Executado na fun��o A250EndOk( ) que e responsavel por   ##
//             validar se pode realizar  o  encerramento  de  uma determinada ordem de   ##
//             produ��o.                                                                 ##
//             EM QUE PONTO : O ponto � disparado apos a confirma��o do encerramento e   ##
//             antes da grava��o. Deve ser utilizado para validar se o encerramento pode ##
//             ser efetuado ou nao.                                                      ##
// Par�metros: Sem par�metros                                                            ##
// ########################################################################################

User Function A250ENOK()

   Local lRet := .T.

   // ###########################################################################################################
   // Tarefa #5032 - Impress�o Ordem de produ��o/encerramento de OP                                            ##
   // Este ponto de entrada foi comentado em raz�o deste processo estar temporariamente indispon�vel para uso. ##
   // Descomentar se o processo de coletor para apontamento de produ��o for colocado no ar                     ##
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