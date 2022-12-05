#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: FA050INC.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 05/06/2014                                                          *
// Objetivo..: O ponto de entrada FA050INC - ser� executado na valida��o da Tudo   *
//             Ok na inclus�o do contas a pagar.                                   *
//**********************************************************************************

User Function FA050INC()

   If M->E2_MULTNAT == "2"     
      If Alltrim(M->E2_TIPO) == "PR"
      Else 
         MsgAlert("Aten��o! N�o houve a informa��o de Rateio Multinaturezas. Verifique!")
         Return(.F.)
      Endif
   Endif
   
Return(.T.)