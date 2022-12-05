#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM203.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 07/01/2014                                                          *
// Objetivo..: Programa que pesquisa o nome do usuário e preenche o campo virtual  *
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