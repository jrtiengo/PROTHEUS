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
// Referencia: AUTOM630.PRW                                                              ##
// Parâmetros: Nenhum                                                                    ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                           ##
// ------------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                   ##
// Data......: 13/09/2017                                                                ##
// Objetivo..: Programa que calcula o volume cúbido dos produtos                         ##
// Parâmetros: Código do Produto a ser calculado                                         ##
// ########################################################################################

User Function AUTOM630(xTipo, xAltura, xLargura, xComprimento, xBase, xRaio, xLado, xQtd)

   Local kAltura      := xAltura
   Local kLargura     := xLargura
   Local kComprimento := xComprimento
   Local kBase        := xBase
   Local kRaio        := xRaio
   Local kLado        := xLado
   Local kEmbalagem   := Substr(xTipo,01,01)
   Local kVolume      := 0

   Do Case

      // #############################
      // Calula o volume de um CUBO ##
      // #############################
      Case kEmbalagem == "1"

           kVolume := (kLargura /100) * (kAltura / 100) * (kComprimento / 100)
           
      // ##################################
      // Calula o volume de um RETÂNGULO ##
      // ##################################
      Case kEmbalagem == "2"

           kVolume := (kLargura / 100) * (kAltura / 100) * (kComprimento / 100)
   
      // #################################
      // Calula o volume de um CILINDRO ##
      // #################################
      Case kEmbalagem == "3"

           kVolume := 3.14 * ((kRaio / 100) * (kRaio / 100)) * (kAltura / 100)
   
      // ###############################
      // Calula o volume de um PRISMA ##
      // ###############################
      Case kEmbalagem == "4"

           kVolume := (kBase / 100) * (kAltura / 100)

      // ##################################
      // Calula o volume de uma PIRÂMEDE ##
      // ##################################
      Case kEmbalagem == "5"

           kVolume := ((kAltura / 100)* (kLado / 100) * (kLado / 100)) / 3
   

      // ##############################
      // Calula o volume de uma CONE ##
      // ##############################
      Case kEmbalagem == "6"

           kVolume := (3.14 * ((kRaio / 100) * (kRaio / 100)) * (kAltura / 100)) / 3
      

      // ################################
      // Calula o volume de uma ESFERA ##
      // ################################
      Case kEmbalagem == "7"

           kVolume := (4 * 3.14 * ((kRaio / 100) * (kRaio / 100) * (kRaio / 100))) / 3
           
      OtherWise
      
           kVolume := 0     
           
   EndCase           

   kVolume := kVolume * xQtd

Return(kVolume)