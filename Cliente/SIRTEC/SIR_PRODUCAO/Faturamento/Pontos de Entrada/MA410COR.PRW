#INCLUDE "PROTHEUS.CH"

#DEFINE STR0001 "Sirtec - MA410COR"

/*
+----------+------------+-------------------+------+------------+
|Programa  |MA410COR    | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Incluir tratamento na cor de status                 |
|          |Pedido de Venda                                     |
+----------+----------------------------------------------------+
|Sintaxe   |ponto de entrada                                    |
+----------+----------------------------------------------------+
|Parametros|#                                                   |
+----------+----------------------------------------------------+
|Retorno   |#                                                   |
+----------+----------------------------------------------------+
|Uso       |Faturamento - Sirtec                                |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
*/
User Function MA410COR

	Local aRet := PARAMIXB
	Local aTemp:= PARAMIXB[1]
	Local MV_YSTC09 := GetMv("MV_YSTC09")								//Parâmetro de controle da execução da rotina   
 	 	
 	//Executa rotina de aglutinar pedidos
 	If MV_YSTC09
		aRet[1] :=  {'C5_YAGLUTI == "S"','BR_PRETO'}
		AADD(aRet,aTemp)				//Pedido Aglutinado
	Endif

Return aRet