#INCLUDE "protheus.ch"  
#INCLUDE "jpeg.ch"    

// ####################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                             ##
// --------------------------------------------------------------------------------- ##
// Referencia: AUTOM573.PRW                                                          ##
// Parâmetros: Nenhum                                                                ##
// Tipo......: ( ) Programa  (X) Gatilho  ( ) Ponto de Entrada                       ##
// --------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                               ##
// Data......: 19/05/2017                                                            ## 
// Objetivo..: Gatilho que trata as comissões dos vendedores no Pedido de Venda      ##
// ####################################################################################

User Function AUTOM573(xProduto)

// Local kProduto  := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "C6_PRODUTO" } ) // Posição do código do produto no aHeader
   Local kComiss1  := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "C6_COMIS1" }  ) // Posição do % de Comissão 1   no aHeader
   Local kComiss2  := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "C6_COMIS2" }  ) // Posição do % de comissão 2   no aHeader   
   Local kTipoVen1 := Posicione("SA3",1,xFilial("SA3") + M->C5_VEND1, "A3_TIPOV")
   Local kTipoVen2 := Posicione("SA3",1,xFilial("SA3") + M->C5_VEND2, "A3_TIPOV")
   Local kTipoComp := Posicione("SA1",1,xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_ZCOMP")
   Local kGerente  := Posicione("SBM",1,xFilial("SBM") + SB1->B1_GRUPO, "BM_COMIS")
   Local kExecut1  := Posicione("SBM",1,xFilial("SBM") + SB1->B1_GRUPO, "BM_COME1")
   Local kExecut2  := Posicione("SBM",1,xFilial("SBM") + SB1->B1_GRUPO, "BM_COME2")

   U_AUTOM628("AUTOM573")

   // ######################################################
   // Carrega comissão quando cliente não é compartilhado ##
   // ######################################################
   If kTipoComp == "N"
   
      // ##################################
      // Trata o vendedor 1 se informado ##
      // ##################################
      If Empty(Alltrim(M->C5_VEND1))
      Else
   
         Do Case 

            // #######################################
            // Se vendedor for Executivo de Venda 1 ##
            // #######################################
            Case kTipoVen1 == "1"
                 aCols[n,kComiss1] := kExecut1
              
            // ####################################
            // Se vendedor for Gerente de Vendas ##
            // ####################################
            Case kTipoVen1 == "2"
                 aCols[n,kComiss1] := kGerente

            // ########################################
            // Se vendedor for Executivo de Vendas 2 ##
            // ########################################
            Case kTipoVen1 == "3"
                 aCols[n,kComiss1] := kExecut2

         EndCase

      Endif
         
      // ##################################
      // Trata o vendedor 1 se informado ##
      // ##################################
      If Empty(Alltrim(M->C5_VEND2))
      Else
   
         Do Case 

            // #######################################
            // Se vendedor for Executivo de Venda 1 ##
            // #######################################
            Case kTipoVen2 == "1"
                 aCols[n,kComiss2] := kExecut1
              
            // ####################################
            // Se vendedor for Gerente de Vendas ##
            // ####################################
            Case kTipoVen2 == "2"
                 aCols[n,kComiss2] := kGerente

            // ########################################
            // Se vendedor for Executivo de Vendas 2 ##
            // ########################################
            Case kTipoVen2 == "3"
                 aCols[n,kComiss2] := kExecut2

         EndCase

      Endif
      
   Else   
                                     
      Do Case 

         // ##########################
         // Se vendedor for gerente ##
         // ##########################
         Case kTipoVen1 == "1"
              aCols[n,kComiss1] := (kExecut1 * 70) / 100
              aCols[n,kComiss2] := (kGerente * 30) / 100
              
         // ##########################
         // Se vendedor Executivo 2 ##
         // ##########################
         Case kTipoVen1 == "3"
              aCols[n,kComiss1] := (kExecut2 * 70) / 100
              aCols[n,kComiss2] := (kGerente * 30) / 100

      EndCase
         
   Endif
   
Return(xProduto)