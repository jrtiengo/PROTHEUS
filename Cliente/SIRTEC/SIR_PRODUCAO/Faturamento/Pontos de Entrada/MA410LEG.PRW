#INCLUDE "PROTHEUS.CH"

#DEFINE STR0001 "Sirtec - MA410LEG"

/*
+----------+------------+-------------------+------+------------+
|Programa  |MA410LEG    | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |P.E. para inlcusão de botões no browse da rotina    |
|          |"Pedidos de Venda"                                  |
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
User Function MA410LEG

	Local aRet := PARAMIXB
	Local MV_YSTC09 := GetMv("MV_YSTC09")								//Parâmetro de controle da execução da rotina   
 	 	
 	//Executa rotina de aglutinar pedidos
 	If MV_YSTC09
		AADD(aRet,{'BR_PRETO','Pedido Aglutinado'})
	Endif

Return aRet