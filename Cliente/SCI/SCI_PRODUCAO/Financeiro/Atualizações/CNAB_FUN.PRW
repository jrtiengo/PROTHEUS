#include "rwmake.ch"     

***********************************************************
**** INICIA VARIAVEL PUBLICA COMO NUMERICA
************************************************************
User Function CNAB_VAR()  

	Public __cNumBor := SE2->E2_NUMBOR   // Variavel que vai saber qual bordero passou
	Public __cNum    := '0001'           // Contador de borderos
	Public __cLinhas := '000001'         // Contador de linhas do arquivo
	Public __cLinBor := '000001'         // Contador de linhas do bordero
	
Return('0000')

***********************************************************
**** CONTA A LINHA DO FINAL DO DO TRAILLER DO ARQUIVO
************************************************************
User Function CNAB_LIN( cRet )

	__cLinhas := StrZERO((Val(__cLinhas)+1),6) // Contador de linhas do arquivo

Return( cRet )

***********************************************************
**** CONTA A LINHA DO FINAL DO DETALHES
************************************************************
User Function CNAB_DET( cRet )

	__cLinhas := StrZERO((Val(__cLinhas)+1),6) // Contador de linhas do arquivo
	__cLinBor := StrZERO((Val(__cLinBor)+1),6)
	
Return( cRet )

***********************************************************
**** VERIFICA SE MUDOU O BORDERO E RETORNA O NUMERO DE BORD
************************************************************
User Function CNAB_BOR()

	If SE2->E2_NUMBOR <> __cNumBor // Já estou no proximo bordero //Var Public que sabe qual bordero anterior
	   
	   __cNumbor  := SE2->E2_NUMBOR
	   __cNum     := StrZERO((Val(__cNum)+1),4)
	   __cLinBor  := '000001'
	   nSomaValor := 0
	
	EndIf
	
Return(__cNum)
