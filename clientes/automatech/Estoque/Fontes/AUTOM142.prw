#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM142.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: ( ) Programa  (X) Gatilho  ( ) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 30/10/2012                                                          *
// Objetivo..: Gatilho que consistente a data de endere�amento de produtos         *
// Par�metro.: Data de Endere�amento                                               *
//**********************************************************************************

User Function AUTOM142(_Data)

   Local dFechado := GetMV("MV_ULMES")      
   Local vData    := _Data

   U_AUTOM628("AUTOM142")

   If _Data = Ctod("  /  /    ")
      vData := Date()
   Endif   

   If _Data > Date()
      MsgAlert("Data informada � inv�lida.")
      vData := Date()   
   Endif

   If _Data <= dFechado
      MsgAlert("Lan�amento n�o permitido para esta data pois este per�odo j� est� Fechado.")
      vData := Date()   
   Endif
            
   
Return vData