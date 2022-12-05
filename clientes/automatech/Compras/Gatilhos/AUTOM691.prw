#INCLUDE "protheus.ch"  
#INCLUDE "jpeg.ch"    

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: AUTOM691.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: ( ) Programa  (X) Gatilho  ( ) Ponto de Entrada                         ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 18/05/2018                                                              ## 
// Objetivo..: Gatilho verifica se o produtos informado é um produto de intermediação  ##
//             no Pedido de Compra                                                     ##
//             Se for, não permitirá utilizá-lo para Compra                            ##
// ######################################################################################

User Function AUTOM691(kProduto)
       
   Local nPosPart := aScan( aHeader, { |x| x[2] == 'C7_PARTNUM' } )
   Local nPosDesc := aScan( aHeader, { |x| x[2] == 'C7_DESCRI ' } )

   U_AUTOM628("AUTOM691")
   
   If Posicione( "SB1", 1, xFilial("SB1") + kProduto, "B1_INTER") == "S"
      MsgAlert("Atenção!"                                    + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ;
               "Este produto é um produto de intermediação." + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ;
               "Compra nao permitida para este produto!")
      kProduto := Space(30)
      aCols[n,nPosPart] := Space(20)
      aCols[n,nPosDesc] := Space(30)
   Endif

Return(kProduto)