#INCLUDE "rwmake.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM500.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 23/08/2016                                                          *
// Objetivo..: Cadastro de metas Anuais de Servi�os, Putras Pe�as e Cabe�otes      *
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