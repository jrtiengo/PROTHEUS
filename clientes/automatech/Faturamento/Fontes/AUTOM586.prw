#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch"    

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: AUTOM586.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Gatilho                                               ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 22/06/2017                                                              ##
// Objetivo..: Programa que mostra para o usuário as Observações padrão do Cliente.    ##
// Parâmetros: kCliente    = Código do Cliente                                         ##
//             kLoja       = Loja do Cliente                                           ##
//             kChamadoPor = Indica de onde foi chamado o programa                     ##
//                           PV = Pedido de Venda                                      ##
//                           OS = Ordem de Serviço                                     ##
// ######################################################################################

User Function AUTOM586(kCliente, kLoja, kChamadoPor)

   Local lChumba    := .F.
   Local cMemo1	    := ""
   Local cObsPadrao := ""
   Local oMemo1
   Local oMemo2

   Private oDlg

   U_AUTOM628("AUTOM586")

   If Empty(Alltrim(kCliente))
      Return(kLoja)
   Endif   

   If Empty(Alltrim(kLoja))
      Return(kLoja)
   Endif   

   If kChamadoPor == "PV"
      cObsPadrao := POSICIONE("SA1",1,XFILIAL("SA1") + KCliente + kLoja, "A1_PRF_OBS")
   Else
      cObsPadrao := POSICIONE("SA1",1,XFILIAL("SA1") + KCliente + kLoja, "A1_IFAT")      
   Endif
   
   If Empty(Alltrim(cObsPadrao))
      Return(kLoja)
   Endif

   DEFINE MSDIALOG oDlg TITLE "Observações Padrão do Cliente" FROM C(178),C(181) TO C(474),C(719) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(261),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Observações Padrão do Cadastro do Cliente" Size C(107),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(045),C(005) GET oMemo2 Var cObsPadrao MEMO Size C(259),C(083) PIXEL OF oDlg When lChumba

   @ C(132),C(116) Button "Continuar ..." Size C(037),C(012) PIXEL OF oDlg ACTION( CONTINUAMSG(kCliente, kLoja, kChamadoPor, cObsPadrao) )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(kLoja)

// ###############################################################################################################
// Função que grava a observação padrão no campo Observações Internas ou do Pedido de Venda ou Ordem de serviço ##
// ###############################################################################################################
Static Function CONTINUAMSG(kCliente, kLoja, kChamadoPor, cObsPadrao)

   // ##################
   // Pedido de Venda ##
   // ##################
   If kChamadoPor == "PV"
   
      If Empty(Alltrim(M->C5_OBSI))
         M->C5_OBSI := "***** OBSERVAÇÃO PADRÃO CADASTRO CLIENTE" + CHR(13) + CHR(10) + CHR(13) + CHR(10) + Alltrim(cObsPadrao)
      Else
         If U_P_OCCURS(M->C5_OBSI, "***** OBSERVAÇÃO PADRÃO CADASTRO CLIENTE", 1) == 0
            M->C5_OBSI := M->C5_OBSI + CHR(13) + CHR(10) + CHR(13) + CHR(10) + "***** OBSERVAÇÃO PADRÃO CADASTRO CLIENTE" + CHR(13) + CHR(10) + CHR(13) + CHR(10) + Alltrim(cObsPadrao)
         Endif
      Endif
   Endif
   
   // ###################
   // Ordem de Serviço ##
   // ###################
   If kChamadoPor == "OS"
   
      If Empty(Alltrim(M->AB6_MINTER))
         M->AB6_MINTER := "***** OBSERVAÇÃO PADRÃO CADASTRO CLIENTE" + CHR(13) + CHR(10) + CHR(13) + CHR(10) + Alltrim(cObsPadrao)
      Else
         If U_P_OCCURS(M->AB6_MINTER, "***** OBSERVAÇÃO PADRÃO CADASTRO CLIENTE", 1) == 0
            M->AB6_MINTER := M->AB6_MINTER + CHR(13) + CHR(10) + CHR(13) + CHR(10) + "***** OBSERVAÇÃO PADRÃO CADASTRO CLIENTE" + CHR(13) + CHR(10) + CHR(13) + CHR(10) + Alltrim(cObsPadrao)
         Endif
      Endif
   Endif

   oDlg:End() 
   
Return(kLoja)                     
      
         

