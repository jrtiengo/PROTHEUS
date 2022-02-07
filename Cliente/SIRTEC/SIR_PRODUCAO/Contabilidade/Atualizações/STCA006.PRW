#INCLUDE "rwmake.ch"

/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA0006    | Microsiga Vitória | Data | 19.09.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Função para atualizar o grupo contábil no plano de  |
|          |contas                                              |
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


User Function STCA006()

Local _cGrupo := ""
Local aArea := GetArea() 

If SUBSTRING(M->CT1_CONTA,1,1)="1" .AND. M->CT1_CLASSE="2"
	_cGrupo := "001"
ElseIf SUBSTRING(M->CT1_CONTA,1,1)="2" .AND. M->CT1_CLASSE="2"
	_cGrupo := "002"
ElseIf SUBSTRING(M->CT1_CONTA,1,1)="3" .AND. M->CT1_CLASSE="2"
	_cGrupo := "003"
ElseIf SUBSTRING(M->CT1_CONTA,1,1)="4" .AND. M->CT1_CLASSE="2"
	_cGrupo := "004"
EndIf


RestArea(GetArea())

Return(_cGrupo)   