#include "rwmake.ch"        
/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA018     | Microsiga Vitória | Data | 25.10.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Rotina de calculo do valor com o LP 651             |
|          |                                                    |
+----------+----------------------------------------------------+
|Sintaxe   |Validação de usuário                                |
+----------+----------------------------------------------------+
|Parametros|                                                    |
+----------+----------------------------------------------------+
|Retorno   |logico                                              |
+----------+----------------------------------------------------+
|Uso       |Contabil - Sirtec                                   |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
*/                    

User Function STCA018()        

local nRetorno := 0

if SD1->D1_RATEIO = "1"
	
	nRetorno := SDE->DE_CUSTO1-(SF1->F1_IRRF*SDE->DE_PERC)/100-(SF1->F1_VALPIS*SDE->DE_PERC)/100-(SF1->F1_VALCOFI*SDE->DE_PERC)/100-(SF1->F1_VALCSLL*SDE->DE_PERC)/100-(SF1->F1_ISS*SDE->DE_PERC)/100-(SF1->F1_INSS*SDE->DE_PERC)/100

endif

Return(nRetorno)