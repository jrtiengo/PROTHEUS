#INCLUDE "protheus.ch"

//**************************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                               *
// ----------------------------------------------------------------------------------- *
// Referencia: TKEVALI()                                                               *
// Par�metros: Nenhum                                                                  *
// Tipo......: (X) Programa  ( ) Gatilho                                               *
// ----------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                                 *
// Data......: 13/05/2014                                                              *
// Objetivo..: Esse ponto de entrada � executado antes da valida��o da linha atual do  *
//             atendimento pela rotina de Televendas. O objetivo � efetuar alguma vali-*
//             da��o na linha de itens do Televendas.                                  *
//**************************************************************************************

// Fun��o que define a Window
User Function TKEVALI()
 
   // Envia para a fun��o que calcula a margem do produto informado
   U_QTGTMK()
   
Return(.T.)