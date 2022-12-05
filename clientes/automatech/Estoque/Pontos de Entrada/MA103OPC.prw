
//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: MA103OPC.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 24/04/2012                                                          *
// Objetivo..: PE que cria novas opções no Menu no Documento de Entrada            *
//**********************************************************************************

User Function MA103OPC()

   Local aRet := {}

   U_AUTOM628("MA103OPC")

   aAdd(aRet,{'Importação XML', 'U_AUTOM108()', 0, 5})

Return aRet