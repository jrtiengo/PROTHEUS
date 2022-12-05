#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

//********************************************************************************************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                                                                                 *
// ----------------------------------------------------------------------------------------------------------------------------------------------------- *
// Referencia: MA030BRW.PRW                                                                                                                              *
// Parâmetros: Nenhum                                                                                                                                    *
// Tipo......: ( ) Programa  (X) Ponto de Entrada  ( ) Gatilho                                                                                           *
// ----------------------------------------------------------------------------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                                                                                                   *
// Data......: 12/04/2016                                                                                                                                *
// Objetivo..: Ponto de Entrada que passa cláusula Where para filtro do cadastro de Clientes no Browse do Cadastro de Clientes                           *
//********************************************************************************************************************************************************

User Function MA030BRW()

	Local _cRet := ""

   U_AUTOM628("MA030BRW")
	
    _cRet := " SA1->A1_MSBLQL <> '1' "

Return _cRet