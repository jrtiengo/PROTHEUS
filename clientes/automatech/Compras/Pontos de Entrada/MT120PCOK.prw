#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch"    

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: MT120PCOK.PRW                                                       ##
// Par�metros: Nenhum                                                              ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                             ##
// Data......: 28/02/2018                                                          ##
// Objetivo..: Ponto de Entrada disparado antes da grava��o do pedido de compra.   ##
//             Neste ponto de entrada s�o  consistidos  alguns  campos  antes da   ##
//             grava��o do pedido de compra.                                       ##
// Par�metros: Sem Par�metros                                                      ##
// ##################################################################################

User Function MT120PCOK()

   Local nPosRateio  := 0   // Posi��o da coluna Rateio
   Local _nDel       := 0   // Verificar se linha est� deletada
   Local _lDel       := .F. // Verificar se linha est� deletada
   Local nContar     := 0   // Contador do For/Next
   Local lNaoRateado := "S" // Verifica se o centro de custo do sprodutos foram rateados

   // #######################################
   // Captura a posi��o do campo C7_RATEIO ##
   // #######################################
   nPosRateio := aScan(aHeader,{|x| AllTrim(x[2])=="C7_RATEIO"})    

   // ##############################################
   // Verifica se o nome do contato foi informado ##
   // ##############################################
   If Empty(Alltrim(cContato))
      MsgAlert("Aten��o!" + chr(13) + chr(10) + chr(13) + chr(10) + "Nome do contato n�o foi informado." + chr(13) + chr(10) + chr(13) + chr(10) + "Verifique!")
      Return(.F.)
   Endif
      
   // ############################################################
   // Verifica se o Centro de Custo dos produtos foram rateados ##
   // ############################################################
   lNaoRateado := "S"
   
   For nContar = 1 to Len(aCols)

       _nDel := Len( aHeader ) + 1
   	   _lDel := aCols[ nContar, _nDel ] // Verificando de a linha est� deletada

       If !_lDel 
 
          If aCols[nContar,nPosRateio] <> "1"
             lNaoRateado := "N"
             Exit
          Endif
          
       Endif   

   Next nContar

   If lNaorateado == "N"
      MsgAlert("Aten��o!"                                                + chr(13) + chr(10) + chr(13) + chr(10) + ; 
               "Existem produtos que o Centro de Custo n�o foi rateado." + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Verifique!")
      Return(.F.)
   Endif

Return(.T.)