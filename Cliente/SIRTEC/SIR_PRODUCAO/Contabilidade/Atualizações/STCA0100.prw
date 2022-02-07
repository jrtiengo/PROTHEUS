#INCLUDE "rwmake.ch"

/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA0100    | Microsiga Vit�ria | Data | 11.08.2008 |
+----------+------------+-------------------+------+------------+
|Descri��o |Fun��o para buscar conta de venda de mercadoria ou  |
|          |produto                                             |         
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


User Function STCA0100()

Local _cConta := ""


IF SF2->F2_COND="001"      .AND. SF2->F2_VALISS>0
	_cConta := "3111101003" // venda de servi�o a vista
ELSEIF SF2->F2_COND<>"001" .AND. SF2->F2_VALISS>0
	_cConta := "3111102003" // venda de servi�o a prazo
ELSEIF SF2->F2_COND="001"  .AND. SF2->F2_VALISS=0
	_cConta := "3111101002" // venda de mercadoria a vista
ELSEIF SF2->F2_COND<>"001" .AND. SF2->F2_VALISS=0
	_cConta := "3111102002" // venda de mercadoria a prazo
EndIf


Return(_cConta)