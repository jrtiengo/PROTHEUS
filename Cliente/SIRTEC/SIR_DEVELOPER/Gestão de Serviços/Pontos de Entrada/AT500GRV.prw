#INCLUDE "PROTHEUS.CH"

#DEFINE STR0001 "Sirtec - AT500GRV"

/*
+----------+------------+-------------------+------+------------+
|Programa  |AT500GRV    | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Replica as agenda de uma equipe para os técnicos    |
|          |                                                    |
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
User Function AT500GRV
	
	Local aArea := GetArea()												//Controle do ponto de entrada
	Local MV_YSTC06 := GetMv("MV_YSTC06")									//Parâmetro de controle da execução da rotina
	Local cEq	:= "S"														//Conteudo que indica que AA1 é de equipe
	Local cCod  := ABB_CODTEC												//Código da equipe no Apontamento
	
	//Verifica se rotina está ativada e se é equipe
	If MV_YSTC06 .and. cEq == Posicione("AA1",1,xFilial("AA1")+cCod,"AA1_YEQUIP") 
		//Rotina que grava o relacionamento entre a OS e os técnicos da OS
		Eval({||U_STCA019(1)})	
	Endif

	RestArea(aArea)	
Return 