#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR53.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  (X) Gatilho ( ) Ponto de Entrada                      *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 16/04/2012                                                          *
// Objetivo..: Gatilho que tem por finalidade de consistir pedidos  de intermedia- *
//             ção com as seguintes regras:                                        *
//             1º) Se tipo de operação = 35 e não for pedido externo               *
//             2º) Se Indicação de pedido externo e tipo operação <> 35            *
//             3º) Se TES = 534 e Pedido não for externo                           *
//             4º) Se pedido é externo e TES <> 534                                *
// Parãmetros.: _Tipo onde P - Tipo de Operação                                    *
//                         T - TES                                                 *
//**********************************************************************************

User Function AUTOMR53(_Tipo)

   U_AUTOM628("AUTOMR53")

   If _Tipo == "P"
 
      If M->C6_OPER = Nil
         Return .T.
      Endif
   
      If M->C6_OPER == '35' .AND. M->C5_EXTERNO <> '1'
         MsgAlert("Atenção! Tipo de Operação somente permitido para pedidos de intermediação.")
         M->C6_OPER := ""
         M->C6_TES  := ""
         Return ""
      Endif
         
      If M->C6_OPER <> '35' .AND. M->C5_EXTERNO == '1'
         MsgAlert("Atenção! Pedido é de Intermediação, Tipo de Operação invalida.")
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
         MsgAlert("Atenção! TES somente permitida para pedidos de intermediação.")
         M->C6_TES := ""
         M->C6_OPER := ""
         Return ""
      Endif
         
      If M->C6_TES <> '543' .AND. M->C5_EXTERNO == '1'
         MsgAlert("Atenção! Pedido é de Intermediação, TES informada é invalida.")
         M->C6_TES  := ""
         M->C6_OPER := ""
         Return ""
      Endif

      Return M->C6_TES
 
   Endif   

Return .T.   