#INCLUDE "PROTHEUS.CH"
/*
Jean Rehermann - Solutio IT - 11/05/2018
Ponto de entrada no processamento do retorno do cnab
Possibilita alterar algumas das variáveis do CNAB
*/
User Function FINA200()

	Local nX := 1
	
	// Aplica a retencao bancaria (no fonte fina200 não esta aplicando corretamente)
	If dBaixa == dDataCred
		For nX := 1 To SA6->A6_RETENCA
			dDataCred := DataValida(dDataCred+1,.T.)
		Next
	EndIf
	
Return( Nil )