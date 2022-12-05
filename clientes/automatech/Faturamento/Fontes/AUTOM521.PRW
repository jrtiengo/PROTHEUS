#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM521.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 27/12/2016                                                          ##
// Objetivo..: Gatilho que retorna o grupo do usuário para bloqueio do campo       ##
//             C6_COMIS1 do Pedido de Venda                                        ##
// Parâmetros: _IdUsuario   = Usuário Logado                                       ##
//             _CodVendedor = Código do Vendedor                                   ##
// ##################################################################################

User Function AUTOM521(_IdUsuario, kVendedor)

   Local aRetorno := {}
   Local cRetorno := .T.

   U_AUTOM628("AUTOM521")

   PswOrder(1)

   If PswSeek(_IdUsuario,.T.)
                                                                     
      aReturn := PswRet()

      If aReturn[1][10][1]$("000011#000017")

         If kVendedor == 1

            cRetorno := .F.
            
         Else   

            If Empty(Alltrim(M->C5_VEND2))
         
               cRetorno := .F.
            
            Else   

               If Posicione("SA1", 1, xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_ZCOMP") == "S"

                  cRetorno := .F.

               Else
               
                  If Posicione("SA3",1,xFilial("SA3") + M->C5_VEND2, "A3_TIPOV") == "9"
    
                     cRetorno := .T.
            
                  Else
         
                     cRetorno := .F.
               
                  Endif   
                  
               Endif
               
            Endif   
            
         Endif   

      Else

         cRetorno := .T.               

      Endif
      
   Endif
   
Return(cRetorno)