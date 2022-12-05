#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: FA050INC.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 05/06/2014                                                          *
// Objetivo..: O ponto de entrada FA050INC - será executado na validação da Tudo   *
//             Ok na inclusão do contas a pagar.                                   *
//**********************************************************************************

User Function FA050INC()

   If M->E2_MULTNAT == "2"     
      If Alltrim(M->E2_TIPO) == "PR"
      Else 
         MsgAlert("Atenção! Não houve a informação de Rateio Multinaturezas. Verifique!")
         Return(.F.)
      Endif
   Endif
   
Return(.T.)