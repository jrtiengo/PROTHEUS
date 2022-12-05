#INCLUDE "protheus.ch"  
#INCLUDE "jpeg.ch"    

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: AUTOM690.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: ( ) Programa  (X) Gatilho  ( ) Ponto de Entrada                         ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 18/05/2018                                                              ## 
// Objetivo..: Gatilho verifica se o produtos informado é um produto de intermediação  ##
//             Se for, não permitirá utilizá-lo em PV não intermediação                ##
// ######################################################################################

User Function AUTOM690(kProduto)
       
   Local nPosPart := aScan( aHeader, { |x| x[2] == 'C6_PARNUM ' } )
   Local nPosDesc := aScan( aHeader, { |x| x[2] == 'C6_DESCRI ' } )

   U_AUTOM628("AUTOM690")
   
   If M->C5_EXTERNO == "1"
   Else
      If Posicione( "SB1", 1, xFilial("SB1") + kProduto, "B1_INTER") == "S"
         MsgAlert("Atenção!"                                                             + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ;
                  "Este produto somente pode ser utilizado em Pedidos de Intermediação." + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ;
                  "Verifique!")
         kProduto := Space(30)
         aCols[n,nPosPart] := Space(20)
         aCols[n,nPosDesc] := Space(30)
      Endif
   Endif

Return(kProduto)