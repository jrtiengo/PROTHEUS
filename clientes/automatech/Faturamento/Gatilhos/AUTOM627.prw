#INCLUDE "protheus.ch"  
#INCLUDE "jpeg.ch"    

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: AUTOM627.PRW                                                            ##
// Par�metros: Nenhum                                                                  ##
// Tipo......: ( ) Programa  (X) Gatilho  ( ) Ponto de Entrada                         ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                                 ##
// Data......: 08/09/2017                                                              ## 
// Objetivo..: Gatilho que traz a descri��o completa do produto para o pedido de venda ##
// ######################################################################################

User Function AUTOM627(kProduto)
       
   Local nPosDescri := aScan( aHeader, { |x| x[2] == 'C6_DESCRI ' } )

   U_AUTOM628("AUTOM627")

   aCols[n,nPosDescri] := Alltrim(Posicione( "SB1", 1, xFilial("SB1") + kProduto, "B1_DESC")) + " " + ;
                          Alltrim(Posicione( "SB1", 1, xFilial("SB1") + kProduto, "B1_DAUX"))

Return(kProduto)