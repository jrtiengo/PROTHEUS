#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM142.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  (X) Gatilho  ( ) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 30/10/2012                                                          *
// Objetivo..: Gatilho que consistente a data de endereçamento de produtos         *
// Parâmetro.: Data de Endereçamento                                               *
//**********************************************************************************

User Function AUTOM142(_Data)

   Local dFechado := GetMV("MV_ULMES")      
   Local vData    := _Data

   U_AUTOM628("AUTOM142")

   If _Data = Ctod("  /  /    ")
      vData := Date()
   Endif   

   If _Data > Date()
      MsgAlert("Data informada é inválida.")
      vData := Date()   
   Endif

   If _Data <= dFechado
      MsgAlert("Lançamento não permitido para esta data pois este período já está Fechado.")
      vData := Date()   
   Endif
            
   
Return vData