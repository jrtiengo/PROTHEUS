#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*
+----------+------------+-------------------+------+------------+
|Programa  |SF1100I     | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição | Ponto de Entrada após a gravação do SF1            |
|          |                                                    |
+----------+----------------------------------------------------+
|Sintaxe   |função a ser executada                              |
+----------+----------------------------------------------------+
|Parametros|                                                    |
+----------+----------------------------------------------------+
|Retorno   |                                                    |
+----------+----------------------------------------------------+
|Uso       |Estoque/Custos - Sirtec                             |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
*/                    

User Function SF1100I

Private aArea 	 := GetArea()
Private aSA2Area := SA2->(GetArea())
Private aSF1Area := SF1->(GetArea())
Private aSD1Area := SD1->(GetArea())

	//Avaliação do Fornecedor
	U_STCA003()

RestArea(aArea)
RestArea(aSA2Area)
RestArea(aSD1Area)
RestArea(aSF1Area)
Return