#include "rwmake.ch"                      

/*
+----------+------------+-------------------+------+------------+
|Programa  |            |                   | Data | 16.05.2012 |
+----------+------------+-------------------+------+------------+
|Descrição |FILTRO DOS LANCAMENTOS POR CENTRO DE CUSTO          |
|          |                                                    |
+----------+----------------------------------------------------+
|Sintaxe   |Validação de usuário                                |
+----------+----------------------------------------------------+
|Parametros|                                                    |
+----------+----------------------------------------------------+
|Retorno   |logico                                              |
+----------+----------------------------------------------------+
|Uso       |PCO - SIRTEC                                        |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+*/
                                                                                                                                                                            
                    

User Function SIRPCO01()

Local nValor := 0

IF  SUBSTRING(CT2->CT2_DEBITO,1,1)=="3" .AND. POSICIONE("CT1",1,XFILIAL("CT1")+CT2->CT2_DEBITO,"!EMPTY(CT1->CT1_YCTORC)") .AND. (EMPTY(CT2->CT2_ROTINA) .OR. SUBSTR(CT2->CT2_ROTINA,1,4)='CTBA') .AND.;
    (CT2->CT2_CCD="0101010110" .OR. CT2->CT2_CCD="01020101" .OR. CT2->CT2_CCD="01020801" .OR. CT2->CT2_CCD="01021601" .OR. CT2->CT2_CCD="01021501" .OR. CT2->CT2_CCD="01020701" .OR.;
    CT2->CT2_CCD="01021302" .OR. CT2->CT2_CCD="01021401" .OR. CT2->CT2_CCD="01020601" .OR. CT2->CT2_CCD="01020201" .OR. CT2->CT2_CCD="01022002")

    nValor:= CT2->CT2_VALOR

Else

    nValor:= 0
    
Endif

Return(nValor)    
    
