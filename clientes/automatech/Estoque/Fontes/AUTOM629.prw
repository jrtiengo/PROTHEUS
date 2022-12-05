#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

// ####################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                             ##
// --------------------------------------------------------------------------------- ##
// Referencia: AUTOM629.PRW                                                          ##
// Par�metros: Nenhum                                                                ##
// Tipo......: (X) Programa  ( ) Gatilho                                             ##
// --------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                               ##
// Data......: 13/09/2017                                                            ##
// Objetivo..: Cadastro de Embalagens                                                ##
// Par�metros: Sem Par�metros                                                        ##
// #################################################################################### 

User Function AUTOM629()

   // ##########################
   // Declara��o de Vari�veis ##
   // ##########################
   Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
   Local cVldExc := ".T." // Validacao para permitir a exclusao.  Pode-se utilizar ExecBlock.

   Private cString := "ZPJ"

   dbSelectArea("ZPJ")
   dbSetOrder(1)

   AxCadastro(cString,"Cadastro de . . .",cVldExc,cVldAlt)

Return(.T.)