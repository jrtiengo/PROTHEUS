#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR53.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: ( ) Programa  (X) Gatilho ( ) Ponto de Entrada                      *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 16/04/2012                                                          *
// Objetivo..: Gatilho que tem por finalidade de consistir pedidos  de intermedia- *
//             ��o com as seguintes regras:                                        *
//             1�) Se tipo de opera��o = 35 e n�o for pedido externo               *
//             2�) Se Indica��o de pedido externo e tipo opera��o <> 35            *
//             3�) Se TES = 534 e Pedido n�o for externo                           *
//             4�) Se pedido � externo e TES <> 534                                *
// Par�metros.: _Tipo onde P - Tipo de Opera��o                                    *
//                         T - TES                                                 *
//**********************************************************************************

User Function AUTOMR53(_Tipo)

   U_AUTOM628("AUTOMR53")

   If _Tipo == "P"
 
      If M->C6_OPER = Nil
         Return .T.
      Endif
   
      If M->C6_OPER == '35' .AND. M->C5_EXTERNO <> '1'
         MsgAlert("Aten��o! Tipo de Opera��o somente permitido para pedidos de intermedia��o.")
         M->C6_OPER := ""
         M->C6_TES  := ""
         Return ""
      Endif
         
      If M->C6_OPER <> '35' .AND. M->C5_EXTERNO == '1'
         MsgAlert("Aten��o! Pedido � de Intermedia��o, Tipo de Opera��o invalida.")
         M->C6_OPER := ""
         M->C6_TES  := ""
         Return ""
      Endif
      
      Return M->C6_OPER
   
   Else
   
      If M->C6_TES = Nil
         Return .T.
      Endif

      If M->C6_TES == '543' .AND. M->C5_EXTERNO <> '1'
         MsgAlert("Aten��o! TES somente permitida para pedidos de intermedia��o.")
         M->C6_TES := ""
         M->C6_OPER := ""
         Return ""
      Endif
         
      If M->C6_TES <> '543' .AND. M->C5_EXTERNO == '1'
         MsgAlert("Aten��o! Pedido � de Intermedia��o, TES informada � invalida.")
         M->C6_TES  := ""
         M->C6_OPER := ""
         Return ""
      Endif

      Return M->C6_TES
 
   Endif   

Return .T.   