#INCLUDE "PROTHEUS.CH"

#DEFINE STR0001 "Sirtec - AT470BUT"

/*
+----------+------------+-------------------+------+------------+
|Programa  |AT470BUT    | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |P.E. para inlcusão de botões na despesa do          |
|          |Atendimento de OS                                   |
+----------+----------------------------------------------------+
|Sintaxe   |ponto de entrada                                    |
+----------+----------------------------------------------------+
|Parametros|#                                                   |
+----------+----------------------------------------------------+
|Retorno   |#                                                   |
+----------+----------------------------------------------------+
|Uso       |Field Service - Sirtec                              |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
*/
User Function AT470BUT
	
	Local aBotao := {}
	
	AAdd(aBotao,{"CARGA",{||U_STCA021()},"Carregar Apontamentos"})

Return( aBotao ) 