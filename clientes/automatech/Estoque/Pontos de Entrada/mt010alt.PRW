#INCLUDE "protheus.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: MT010ALT.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 12/12/2017                                                          ##
// Objetivo..: Ponto de Entrada disparado na alteração do Cadastro de produtos.    ##
// ##################################################################################

User Function MT010ALT()
 
   U_AUTOM628("MT010ALT")

   // #####################################################################################################
   // Envia para o programa que calcula a quantidade de etiquetas por rolo em caso de produtos Etiquetas ##
   // #####################################################################################################
   U_AUTOM552(SB1->B1_COD, 0)   

   // ##########################################################################################################
   // Verifica se há a necessidade de bloquear o produto em caso de produto ser de indicação de intermediação ##
   // ##########################################################################################################
   If SB1->B1_INTER == "S"
   Else

      // #####################################################################
      // Se o produto já sofreu uma liberação, não será bloqueado novamente ##
      // Se nunca foi liberado, será bloqueado                              ##
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

         MsgAlert("Atenção!"                                                                    + chr(13) + chr(13) + chr(13) + chr(10) + ;
                  "O produto incluído ficará bloqueado até este ser validado pela área Fiscal." + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  "Você receberá um e-mail lhe informando quando este estiver liberado para uso.")
      Endif

   Endif   
   
Return(.T.)   