#INCLUDE "rwmake.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM500.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 23/08/2016                                                          *
// Objetivo..: Cadastro de metas Anuais de Serviços, Putras Peças e Cabeçotes      *
//**********************************************************************************

User Function AUTOM500()

   // Declaracao de Variaveis
   Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
   Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

   Private cString := "ZTN"

   dbSelectArea("ZTN")
   dbSetOrder(1)

   AxCadastro(cString,"Cadastro de . . .",cVldExc,cVldAlt)

Return