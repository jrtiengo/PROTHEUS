#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AT400ROT.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho (X) Ponto de Entrada                      *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 23/04/2013                                                          *
// Objetivo..: Cria novas opções (Botões) Orçamento Field Service                  *
//**********************************************************************************

User Function AT400ROT()

   Local aRet := {}          

   aAdd(aRet,{'Consulta Preço','U_AUTOM126()', 0 , 2})
   
Return aRet