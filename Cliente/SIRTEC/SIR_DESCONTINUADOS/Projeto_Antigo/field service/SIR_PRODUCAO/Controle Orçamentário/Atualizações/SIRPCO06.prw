#include "rwmake.ch"                      

/*
+----------+------------+-------------------+------+------------+
|Programa  |            |                   | Data | 16.05.2012 |
+----------+------------+-------------------+------+------------+
|Descri??o |FILTRO PARA TRATAMENTO DE CENTRO DE CUSTO           |
|          |                                                    |
+----------+----------------------------------------------------+
|Sintaxe   |Valida??o de usu?rio                                |
+----------+----------------------------------------------------+
|Parametros|                                                    |
+----------+----------------------------------------------------+
|Retorno   |logico                                              |
+----------+----------------------------------------------------+
|Uso       |PCO - SIRTEC                                        |
+----------+----------------------------------------------------+
|        ATUALIZA??ES SOFRIDAS DESDE A CONSTRU??O INCIAL        |
+------------+--------+-----------+-----------------------------+
|Fun??o      |Data    |Programador| Mutivo da Altera?ao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+*/
                                                                                                                                                                            

User Function SIRPCO06()

Local nValor:= 0


IF !EMPTY(FORMULA("211")) .AND.;
   (SD3->D3_CC="0101010110" .OR. SD3->D3_CC="01020101" .OR. SD3->D3_CC="01020801" .OR. SD3->D3_CC="01020801" .OR. SD3->D3_CC="01021601" .OR. SD3->D3_CC="01021501" .OR. SD3->D3_CC="01020701" .OR.;
   SD3->D3_CC="01021302" .OR. SD3->D3_CC="01021401" .OR. SD3->D3_CC="01020601" .OR. SD3->D3_CC="01020201" .OR. SD3->D3_CC="01022002")    
   
   nValor:= SD3->D3_CUSTO1
   
Else

   nValor:= 0
   
Endif

Return(nValor)   
   

