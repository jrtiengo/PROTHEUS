#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA004     | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Aviso de produto sem solicitação de compras         |
|          |                                                    |
+----------+----------------------------------------------------+
|Sintaxe   |gatilho                                             |
+----------+----------------------------------------------------+
|Parametros|cProduto,nQuantidade,X7_CAMPO                       |
+----------+----------------------------------------------------+
|Retorno   |X7_CAMPO                                            |
+----------+----------------------------------------------------+
|Uso       |Compras - Sirtec                                    |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
*/                    
User Function STCA004
	Local cProduto	:= PARAMIXB[1]
	Local nQuant	:= PARAMIXB[2]
	Local cRet		:= PARAMIXB[3]
	Local MV_YSOLMSG:= GetMv("MV_YSOLMSG")
	Local MV_YSTC02 := GetMv("MV_YSTC02")
	
	//verifica execução da rotina
	If MV_YSTC02
		If nQuant < SB1->B1_YMSOLIC
			MsgInfo(&(Posicione("SM4",1,xFilial("SM4")+MV_YSOLMSG,"M4_FORMULA")),"Sirtec - SCTA004")
		Endif
	Endif

Return &(cRet)       