#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: FA740BRW.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 01/07/2015                                                          *
// Objetivo..: Ponto de Entrada que cria novas op��es na tela do Contas a Receber. *
//**********************************************************************************

User Function FA740BRW()

   Local aBotao := {}
   
   aAdd(aBotao, {'Alterar Vencimento',"U_AUTOM299()",   0 , 3    })
   
Return(aBotao)