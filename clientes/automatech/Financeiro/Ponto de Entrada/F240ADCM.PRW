#Include "Protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: F240ADCM                                                            *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho (X) Ponto de Entrada                      *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 20/06/2012                                                          *
// Objetivo..: Ponto de Entrada que incluí no browse da tela de borderôs o código  *
//             do banco dos títulos listados                                       *
// Parâmetros: Nenhum                                                              *
//**********************************************************************************

User Function F240ADCM()

   Local aCamposADCM := {}
   
   aAdd(aCamposADCM,'E2_CBCO')

Return aCamposADCM