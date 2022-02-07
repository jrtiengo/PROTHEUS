#INCLUDE "PROTHEUS.CH"
/*/
+----------+------------+-------------------+------+------------+
|Programa  |MTA110OK    | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Validação da inclusão, na solicitação de compras    |
|          |                                                    |
+----------+----------------------------------------------------+
|Sintaxe   |ponto de entrada                                    |
+----------+----------------------------------------------------+
|Parametros|PARAMIXB[1] = NUMERO DA SOLICITAÇÃO                 |
|          |PARAMIXB[2] = NOME DO SOLICITANTE                   | 
|          |PARAMIXB[3] = DATA DA SOLICITAÇÃO                   | 
+----------+----------------------------------------------------+
|Retorno   |logico                                              |
+----------+----------------------------------------------------+
|Uso       |Compras - Sirtec                                    |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
/*/
User Function MTA110OK 
	Local cUser := PARAMIXB[2]
	Local lRet  := .F.
	Local MV_YSTC01 := GetMv("MV_YSTC01")
	
	//verifica execução da rotina
	If MV_YSTC01
		//Verifica campo "solicitante"
		If Alltrim(cUser) == Alltrim(cUserName)
			lRet := .T.
		Else
			MsgInfo("Solicitante diferente do usuário, não será permitida a confirmação.","Sirtec - MTA110OK")
		Endif
	//nao efetua nenhum tratamento, parametro desativado
	Else
		lRet := .T.	
	Endif
	
Return lRet