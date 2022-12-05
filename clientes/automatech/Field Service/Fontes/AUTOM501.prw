#INCLUDE "rwmake.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM501.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 23/08/2016                                                          *
// Objetivo..: Cadastro de metas Anuais de SLA                                     *
//**********************************************************************************

User Function AUTOM501()

   // Declaracao de Variaveis
   Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
   Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

   Private cString := "ZTO"

   dbSelectArea("ZTO")
   dbSetOrder(1)

   AxCadastro(cString,"Cadastro de . . .",cVldExc,cVldAlt)

Return