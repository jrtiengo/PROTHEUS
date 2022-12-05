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
// Referencia: AUTOM635.PRW                                                              ##
// Par�metros: Nenhum                                                                    ##
// Tipo......: ( ) Programa  ( ) Ponto de Entrada  (X) Gatilho                           ##
// ------------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                                   ##
// Data......: 26/09/2017                                                                ##
// Objetivo..: Gatilho que verifica se produto informado no pedido de venda possui indi- ##
//             ca��o de dimens�es.                                                       ##
// ########################################################################################

User Function AUTOM635(kProduto)

   nPosCodigo  := aScan( aHeader, { |x| x[2] == 'C6_PRODUTO' } )
   nPosNome    := aScan( aHeader, { |x| x[2] == 'C6_DESCRI ' } )
   nPosUnidade := aScan( aHeader, { |x| x[2] == 'C6_UM     ' } )

   If Empty(Alltrim(kProduto))
      Return(.T.)
   Endif
   
   If Posicione( "SB1", 1, xFilial("SB1") + kProduto, "B1_EMBA" )$("0#1#2#3#4#5#6#7")
   Else
     MsgAlert("Aten��o!"                                                             + chr(13) + chr(10) + chr(13) + chr(10) + ;
              "Este produto n�o possui parametriza��o de dimens�es em seu cadastro." + chr(13) + chr(10) + ;
              "Entre em contato com a �rea de log�stica informando esta situa��o."   + chr(13) + chr(10) + ;
              "Produto n�o poder� ser utilizado sem informa��o de dimens�es.")     
     aCols[n,nPosCodigo]  := Space(30)
     aCols[n,nPosNome]    := Space(60)
     aCols[n,nPosUnidade] := Space(02)
  Endif
  
Return(.T.)