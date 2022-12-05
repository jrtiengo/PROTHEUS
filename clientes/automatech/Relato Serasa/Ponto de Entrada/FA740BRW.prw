#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: FA740BRW.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 01/07/2015                                                          *
// Objetivo..: Ponto de Entrada que cria novas opções na tela do Contas a Receber. *
//**********************************************************************************

User Function FA740BRW()

   Local aBotao := {}
   
   aAdd(aBotao, {'Alterar Vencimento',"U_AUTOM299()",   0 , 3    })
   
Return(aBotao)