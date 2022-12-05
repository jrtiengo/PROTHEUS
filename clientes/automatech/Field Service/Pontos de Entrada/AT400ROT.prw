#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AT400ROT.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho (X) Ponto de Entrada                      *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 23/04/2013                                                          *
// Objetivo..: Cria novas op��es (Bot�es) Or�amento Field Service                  *
//**********************************************************************************

User Function AT400ROT()

   Local aRet := {}          

   aAdd(aRet,{'Consulta Pre�o','U_AUTOM126()', 0 , 2})
   
Return aRet