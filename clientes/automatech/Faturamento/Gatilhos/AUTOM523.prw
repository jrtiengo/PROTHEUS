#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"                                 
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: AUTOM523.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Gatilho                                               ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 30/12/2016                                                              ##
// Objetivo..: Gatilho que traz o vendedor correspondente para o pedido de venda       ##
// ######################################################################################
User Function AUTOM523(_Codigo, _Loja)
 
   Local cRetorno     := ""
   Local cSql         := ""
   Local xCompartilha := Posicione("SA1", 1, xFilial("SA1") + _Codigo + _Loja, "A1_ZCOMP" )
   Local xHardware    := Posicione("SA1", 1, xFilial("SA1") + _Codigo + _Loja, "A1_VEND" )
   Local xSuprimentos := Posicione("SA1", 1, xFilial("SA1") + _Codigo + _Loja, "A1_ZVEND2")

   cRetorno := ""
   cSql     := ""

   U_AUTOM628("AUTOM523")
   
   If xCompartilha == "N"
      Do Case
         Case cEmpAnt == "01"
              Do Case 
                 Case cFilAnt == "01"
                      M->C5_VEND1 := xHardware
                 Case cFilAnt == "02"
                      M->C5_VEND1 := xHardware
                 Case cFilAnt == "03"
                      M->C5_VEND1 := xHardware
                 Case cFilAnt == "04"
                      M->C5_VEND1 := xSuprimentos
                 Case cFilAnt == "05"
                      M->C5_VEND1 := xHardware
                 Case cFilAnt == "06"
                      M->C5_VEND1 := xHardware
                 Case cFilAnt == "07"
                      M->C5_VEND1 := xSuprimentos
              EndCase
         Case cEmpAnt == "02"
              M->C5_VEND1 := xHardware
         Case cEmpAnt == "03"
              M->C5_VEND1 := xSuprimentos
         Case cEmpAnt == "04"
              M->C5_VEND1 := xHardware
      EndCase
   Else
      M->C5_VEND1 := xHardware
      M->C5_VEND2 := xSuprimentos
   Endif      

Return(_Loja)