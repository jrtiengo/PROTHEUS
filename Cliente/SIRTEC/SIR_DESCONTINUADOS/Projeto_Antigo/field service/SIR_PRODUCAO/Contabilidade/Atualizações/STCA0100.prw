#INCLUDE "rwmake.ch"

/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA0100    | Microsiga Vitória | Data | 11.08.2008 |
+----------+------------+-------------------+------+------------+
|Descrição |Função para buscar conta de venda de mercadoria ou  |
|          |produto                                             |         
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


User Function STCA0100()

Local _cConta := ""


IF SF2->F2_COND="001"      .AND. SF2->F2_VALISS>0
	_cConta := "3111101003" // venda de serviço a vista
ELSEIF SF2->F2_COND<>"001" .AND. SF2->F2_VALISS>0
	_cConta := "3111102003" // venda de serviço a prazo
ELSEIF SF2->F2_COND="001"  .AND. SF2->F2_VALISS=0
	_cConta := "3111101002" // venda de mercadoria a vista
ELSEIF SF2->F2_COND<>"001" .AND. SF2->F2_VALISS=0
	_cConta := "3111102002" // venda de mercadoria a prazo
EndIf


Return(_cConta)