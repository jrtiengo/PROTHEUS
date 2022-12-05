#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: MA410MNU.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho  (  ) Ponto de Entrada                    *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 19/11/2015                                                          *
// Objetivo..: Ponto de Entrada que inclui op��es na A��es Relacionadas do Pedido  *
//             de Venda.                                                           *
//**********************************************************************************

User Function MA410MNU() 

   U_AUTOM628("MA410MNU")

   aadd( aRotina,{"PV(Rejeitados Credito)","U_AUTOM321()",0,7,0, nil} ) 

Return 