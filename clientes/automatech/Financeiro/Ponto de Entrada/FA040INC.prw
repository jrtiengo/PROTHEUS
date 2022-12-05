#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: FA040INC.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 05/06/2014                                                          *
// Objetivo..: O ponto de entrada FA040INC - será executado na validação da Tudo   *
//             Ok na inclusão do contas a receber.                                 *
//**********************************************************************************

User Function FA040INC()

   If M->E1_MULTNAT == "2" .And. M->E1_DESDOBR == "N"
      MsgAlert("Atenção! Não houve a informação de Rateio Multinaturezas. Verifique!")
      Return(.F.)
   Endif
   
Return(.T.)