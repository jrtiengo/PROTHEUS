#include "RWMAKE.CH"
#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#INCLUDE "jpeg.ch" 
#INCLUDE "TOTVS.CH"

// ###############################################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAวรO LTDA                                                                        ##
// ------------------------------------------------------------------------------------------------------------ ##
// Referencia: FUNCPROD.PRW                                                                                     ##
// Parโmetros: Nenhum                                                                                           ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                                                  ##
// ------------------------------------------------------------------------------------------------------------ ##
// Autor.....: Pietro Lopes                                                                                     ##
// Data......: 27/07/2018                                                                                       ##
// Objetivo..: Lista de fun็๕es para produtos                                                                   ##
//                                                                                                              ##
//                                                                                                              ##
// Parโmetros: Sem Parโmetros                                                                                   ##
// ###############################################################################################################

User Function FUNCPROD()	
	/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
	ฑฑบPrograma  ณPRDEHETQ     บAutor  ณPietro Lopes     บ Data ณ  27/06/18   บฑฑ
	ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
	ฑฑบDesc.     ณ Fun็ใo criada para verificar se o produto ้ uma etiqueta   บฑฑ
	ฑฑบ          ณ                                                            บฑฑ
	ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
	ฑฑบUso       ณ AP                                                        บฑฑ
	ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
	*/
	User Function PrdEhEtq(cCodProd)

		Local nNX        := 0
		Local lRetEtq    := .F.
		Local nCnt       := 0 

		Default cCodProd := ''		
				
		//Regra passada por Gustavo Regal via Redmine #4949
		For nNX:=1 to Len(Alltrim(cCodProd))
			If !IsAlpha(substr(Alltrim(cCodProd),nNX,1))
				nCnt:=nCnt+1//Realiza a contagem dos caracteres que nใo cont้m letra		
			EndIf
		Next
  		
		//Se o numero de caracteres for igual a 17, e
		//Se o numero de caracteres que nใo cont้m letra forem igual ao tamanho da String		
		If Len(Alltrim(cCodProd))==17 .AND. Len(Alltrim(cCodProd))==nCnt 
			//้ etiqueta
			lRetEtq := .T.
		EndIf
		
	Return lRetEtq
		
Return