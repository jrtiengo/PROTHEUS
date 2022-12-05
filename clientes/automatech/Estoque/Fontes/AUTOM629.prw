#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

// ####################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                             ##
// --------------------------------------------------------------------------------- ##
// Referencia: AUTOM629.PRW                                                          ##
// Parâmetros: Nenhum                                                                ##
// Tipo......: (X) Programa  ( ) Gatilho                                             ##
// --------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                               ##
// Data......: 13/09/2017                                                            ##
// Objetivo..: Cadastro de Embalagens                                                ##
// Parâmetros: Sem Parâmetros                                                        ##
// #################################################################################### 

User Function AUTOM629()

   // ##########################
   // Declaração de Variáveis ##
   // ##########################
   Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
   Local cVldExc := ".T." // Validacao para permitir a exclusao.  Pode-se utilizar ExecBlock.

   Private cString := "ZPJ"

   dbSelectArea("ZPJ")
   dbSetOrder(1)

   AxCadastro(cString,"Cadastro de . . .",cVldExc,cVldAlt)

Return(.T.)