#INCLUDE "protheus.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: MT010ALT.PRW                                                        ##
// Par�metros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                             ##
// Data......: 12/12/2017                                                          ##
// Objetivo..: Ponto de Entrada disparado na altera��o do Cadastro de produtos.    ##
// ##################################################################################

User Function MT010ALT()
 
   U_AUTOM628("MT010ALT")

   // #####################################################################################################
   // Envia para o programa que calcula a quantidade de etiquetas por rolo em caso de produtos Etiquetas ##
   // #####################################################################################################
   U_AUTOM552(SB1->B1_COD, 0)   

   // ##########################################################################################################
   // Verifica se h� a necessidade de bloquear o produto em caso de produto ser de indica��o de intermedia��o ##
   // ##########################################################################################################
   If SB1->B1_INTER == "S"
   Else

      // #####################################################################
      // Se o produto j� sofreu uma libera��o, n�o ser� bloqueado novamente ##
      // Se nunca foi liberado, ser� bloqueado                              ##
      // #####################################################################
      If SB1->B1_STLB == "L"
      Else
         RecLock("SB1",.F.)         
         SB1->B1_MSBLQL := "1"
         SB1->B1_USUI   := cusername
         SB1->B1_DATAI  := DATE()
         SB1->B1_HORAI  := TIME()
         SB1->B1_STLB   := "S"
         MsUnLock()                                  

         MsgAlert("Aten��o!"                                                                    + chr(13) + chr(13) + chr(13) + chr(10) + ;
                  "O produto inclu�do ficar� bloqueado at� este ser validado pela �rea Fiscal." + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  "Voc� receber� um e-mail lhe informando quando este estiver liberado para uso.")
      Endif

   Endif   
   
Return(.T.)   