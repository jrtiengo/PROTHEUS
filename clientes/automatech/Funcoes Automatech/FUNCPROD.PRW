#include "RWMAKE.CH"
#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#INCLUDE "jpeg.ch" 
#INCLUDE "TOTVS.CH"

// ###############################################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                                                        ##
// ------------------------------------------------------------------------------------------------------------ ##
// Referencia: FUNCPROD.PRW                                                                                     ##
// Par�metros: Nenhum                                                                                           ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                                                  ##
// ------------------------------------------------------------------------------------------------------------ ##
// Autor.....: Pietro Lopes                                                                                     ##
// Data......: 27/07/2018                                                                                       ##
// Objetivo..: Lista de fun��es para produtos                                                                   ##
//                                                                                                              ##
//                                                                                                              ##
// Par�metros: Sem Par�metros                                                                                   ##
// ###############################################################################################################

User Function FUNCPROD()	
	/*
	�����������������������������������������������������������������������������
	�����������������������������������������������������������������������������
	�������������������������������������������������������������������������ͻ��
	���Programa  �PRDEHETQ     �Autor  �Pietro Lopes     � Data �  27/06/18   ���
	�������������������������������������������������������������������������͹��
	���Desc.     � Fun��o criada para verificar se o produto � uma etiqueta   ���
	���          �                                                            ���
	�������������������������������������������������������������������������͹��
	���Uso       � AP                                                        ���
	�������������������������������������������������������������������������ͼ��
	�����������������������������������������������������������������������������
	�����������������������������������������������������������������������������
	*/
	User Function PrdEhEtq(cCodProd)

		Local nNX        := 0
		Local lRetEtq    := .F.
		Local nCnt       := 0 

		Default cCodProd := ''		
				
		//Regra passada por Gustavo Regal via Redmine #4949
		For nNX:=1 to Len(Alltrim(cCodProd))
			If !IsAlpha(substr(Alltrim(cCodProd),nNX,1))
				nCnt:=nCnt+1//Realiza a contagem dos caracteres que n�o cont�m letra		
			EndIf
		Next
  		
		//Se o numero de caracteres for igual a 17, e
		//Se o numero de caracteres que n�o cont�m letra forem igual ao tamanho da String		
		If Len(Alltrim(cCodProd))==17 .AND. Len(Alltrim(cCodProd))==nCnt 
			//� etiqueta
			lRetEtq := .T.
		EndIf
		
	Return lRetEtq
		
Return