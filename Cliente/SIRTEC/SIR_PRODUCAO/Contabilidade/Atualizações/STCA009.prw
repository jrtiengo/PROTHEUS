#INCLUDE "rwmake.ch"

/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA0009    | Microsiga Vitória | Data | 05.10.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Grava a conta de estoque no campo B1_CONTA          |
|          |de acordo com o grupo de produto                    |
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


User Function STCA009()

Local _cConta := SB1->B1_CONTA
Local aArea := GetArea() 

If M->B1_GRUPO="0003"
	_cConta := "1170200005"
ElseIf M->B1_GRUPO="0007"
	_cConta := "1170200001"
ElseIF M->B1_GRUPO="0016"
	_cConta := "1170200002"
EndIf


RestArea(GetArea())

Return(_cConta)   