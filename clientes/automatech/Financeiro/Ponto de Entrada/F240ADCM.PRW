#Include "Protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: F240ADCM                                                            *
// Par�metros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho (X) Ponto de Entrada                      *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 20/06/2012                                                          *
// Objetivo..: Ponto de Entrada que inclu� no browse da tela de border�s o c�digo  *
//             do banco dos t�tulos listados                                       *
// Par�metros: Nenhum                                                              *
//**********************************************************************************

User Function F240ADCM()

   Local aCamposADCM := {}
   
   aAdd(aCamposADCM,'E2_CBCO')

Return aCamposADCM