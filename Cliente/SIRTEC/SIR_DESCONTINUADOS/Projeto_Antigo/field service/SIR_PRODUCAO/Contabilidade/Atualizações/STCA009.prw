#INCLUDE "rwmake.ch"

/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA0009    | Microsiga Vit�ria | Data | 05.10.2007 |
+----------+------------+-------------------+------+------------+
|Descri��o |Grava a conta de estoque no campo B1_CONTA          |
|          |de acordo com o grupo de produto                    |
+----------+----------------------------------------------------+
|Sintaxe   |Valida��o de usu�rio                                |
+----------+----------------------------------------------------+
|Parametros|                                                    |
+----------+----------------------------------------------------+
|Retorno   |logico                                              |
+----------+----------------------------------------------------+
|Uso       |Contabil - Sirtec                                   |
+----------+----------------------------------------------------+
|        ATUALIZA��ES SOFRIDAS DESDE A CONSTRU��O INCIAL        |
+------------+--------+-----------+-----------------------------+
|Fun��o      |Data    |Programador| Mutivo da Altera�ao         |
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