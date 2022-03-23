#Include "Protheus.ch"
#Include "TOTVS.ch"
#include "jpeg.ch"    
#INCLUDE "topconn.ch"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
         
// #####################################################################################
// SOLUTIO IT SOLUÇÕES CORPORATIVAS                                                   ##
// ---------------------------------------------------------------------------------- ##
// Referencia: MT110CFM.PRW                                                           ##
// Parâmetros: Nenhum                                                                 ##
// Tipo......: ( ) Programa  (X) Ponto de Entrada ( ) Gatilho                         ##
// ---------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                ##
// Data......: 04/07/2019                                                             ##
// Objetivo..: Ponto de Entrada disparado no final da gravação do processo de Aprova- ##
//             ção de Solicitação de Compras.                                         ##
//             Este tem o objetivo de gravar as data de Aprovação das Solicitações de ##
//             Compras.                                                               ## 
// #####################################################################################

User Function MT110CFM()

   Local ExpC1  := PARAMIXB[1]     
   Local ExpN1  := PARAMIXB[2]       
   
   // Se Solicitação de Compra foi Aprovada, grava a data de aprovação em C1_DTAPROV
   If ExpN1 == 1
      DbSelectArea("SC1")
      DbSetOrder(1)
 	  If DbSeek( xFilial("SC1") + ExpC1)
         WHILE !SC1->( EOF() ) .And. SC1->C1_FILIAL == xFilial("SC1") .And. SC1->C1_NUM == ExpC1
            Reclock("SC1",.F.)
	        SC1->C1_DTAPROV := Date()
            MsUnlock()
            SC1->( DbSkip() )
         ENDDO   
      Endif   
   Endif
   
Return Nil
