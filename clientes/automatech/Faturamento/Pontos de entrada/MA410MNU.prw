#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: MA410MNU.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho  (  ) Ponto de Entrada                    *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 19/11/2015                                                          *
// Objetivo..: Ponto de Entrada que inclui opções na Ações Relacionadas do Pedido  *
//             de Venda.                                                           *
//**********************************************************************************

User Function MA410MNU() 

   U_AUTOM628("MA410MNU")

   aadd( aRotina,{"PV(Rejeitados Credito)","U_AUTOM321()",0,7,0, nil} ) 

Return 