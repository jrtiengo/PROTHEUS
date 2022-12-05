#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: FA040INC.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 05/06/2014                                                          *
// Objetivo..: O ponto de entrada FA040INC - ser� executado na valida��o da Tudo   *
//             Ok na inclus�o do contas a receber.                                 *
//**********************************************************************************

User Function FA040INC()

   If M->E1_MULTNAT == "2" .And. M->E1_DESDOBR == "N"
      MsgAlert("Aten��o! N�o houve a informa��o de Rateio Multinaturezas. Verifique!")
      Return(.F.)
   Endif
   
Return(.T.)