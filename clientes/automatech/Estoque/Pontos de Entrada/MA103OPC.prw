
//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: MA103OPC.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 24/04/2012                                                          *
// Objetivo..: PE que cria novas op��es no Menu no Documento de Entrada            *
//**********************************************************************************

User Function MA103OPC()

   Local aRet := {}

   U_AUTOM628("MA103OPC")

   aAdd(aRet,{'Importa��o XML', 'U_AUTOM108()', 0, 5})

Return aRet