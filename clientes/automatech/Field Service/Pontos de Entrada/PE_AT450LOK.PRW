#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch"    

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Objeto....: AT450LOK.PRW                                                            ##
// Tipo......: ( ) Programa  (X) Gatilho  ( ) Ponto de Entrada                         ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Samuel Schneider e Harald Hans L�schenkohl                              ##
// Data......: 23/06/2011                                                              ##
// Objetivo..: Ponto de Entrada disparado no momento da sele��o do bot�o Confirmar da  ##
//             Ordem de Servi�o. Valida��es antes da grava��o da Ordem de Servi�o.     ##  
// Par�metros: Sem Par�metros                                                          ##
// ######################################################################################
USER FUNCTION AT450LOK()

   Local _lret := .t. 

   // No protheus 11 procname(6)
   // No protheus 12 procname(5)

//   IF n = 1  .and. procname(6) <> "TUDOOK" 
   IF n = 1  .and. procname(5) <> "TUDOOK" 
      _lret := .f.
      MsgAlert("N�o � Permitido incluir mais de uma ordem de servi�o.")	
   Endif                                                                
   
   // #####################################################################################################
   // Valida o campo AB6_PANT.                                                                           ##
   // Se este campo for = C (Pagamento Antecipado Sim COM PV, verifica se o campo AB6_PVAN foi preechido ##
   // #####################################################################################################
   If M->AB6_PANT == "C"
      If Empty(Alltrim(M->AB6_PVAN))
   	     MsgAlert("Aten��o!"                                                                                          + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ;
   	              "O campo Inf.Pg.Ant. (Informa��o do Pedido de Venda para Pagamento Antecipado) n�o foi preenchido." + CHR(13) + CHR(10) + ;
   	              "Este � de preenchimento obrigat�rio."                                                              + chr(13) + chr(10) + chr(13) + chr(10) + ;
   	              "Verifique!")
         _lRet := .F.
         Return _lRet
      Endif
   Endif      

   // ##################################################################################################
   // Se OS com Posi��o = E e Aprovada == S, chama tela de observa��es padr�o do cadastro de clientes ##
   // ##################################################################################################
   If M->AB6_POSI == "E" .And. M->AB6_APROV == "S"
      U_AUTOM586(M->AB6_CODCLI, M->AB6_LOJA, "OS")
   Endif

RETURN _lRet