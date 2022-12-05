#INCLUDE "protheus.ch"

//**************************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                               *
// ----------------------------------------------------------------------------------- *
// Referencia: TKEVALI()                                                               *
// Parâmetros: Nenhum                                                                  *
// Tipo......: (X) Programa  ( ) Gatilho                                               *
// ----------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                                 *
// Data......: 13/05/2014                                                              *
// Objetivo..: Esse ponto de entrada é executado antes da validação da linha atual do  *
//             atendimento pela rotina de Televendas. O objetivo é efetuar alguma vali-*
//             dação na linha de itens do Televendas.                                  *
//**************************************************************************************

// Função que define a Window
User Function TKEVALI()
 
   // Envia para a função que calcula a margem do produto informado
   U_QTGTMK()
   
Return(.T.)