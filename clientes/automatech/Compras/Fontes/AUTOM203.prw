#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM203.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 07/01/2014                                                          *
// Objetivo..: Programa que pesquisa o nome do usu�rio e preenche o campo virtual  *
//             do grid da tela do Pedido de Compra.                                *
//**********************************************************************************

User Function AUTOM203(_IDUsuario)

   Local _NomeUsuario := ""

   U_AUTOM628("AUTOM203")

   PswOrder(1)

   If PswSeek(_IDUsuario,.T.)

      aReturn := PswRet()

      _NomeUsuario := aReturn[1][4]

   Else
   
      _NomeUsuario := ""
      
   Endif
   
Return _NomeUsuario