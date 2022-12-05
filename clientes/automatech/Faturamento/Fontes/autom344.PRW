#include "jpeg.ch"    
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "TOTVS.CH"

//************************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                             *
// --------------------------------------------------------------------------------- *
// Referencia: AUTOM344.PRW                                                          *
// Parâmetros: Nenhum                                                                *
// Tipo......: (X) Programa  ( ) Gatilho  (  ) Ponto de Entrada                      *
// --------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                               *
// Data......: 13/05/2016                                                            *
// Objetivo..: Programa que popula a coluna Nome do Cliente da tela de Ped.Venda.    *
//************************************************************************************

User Function AUTOM344(__TipoCli, __Codigo, __Loja)

    Local Nome_cliente := ""

    U_AUTOM628("AUTOM344")

    If __TipoCli == "D" .Or. __TipoCli == "B"
       Nome_cliente := Posicione("SA2",1,xFilial("SA2") + __Codigo + __Loja, "A2_NOME")    
    Else   
       Nome_cliente := Posicione("SA1",1,xFilial("SA1") + __Codigo + __Loja, "A1_NOME")
    Endif
    
Return Nome_Cliente