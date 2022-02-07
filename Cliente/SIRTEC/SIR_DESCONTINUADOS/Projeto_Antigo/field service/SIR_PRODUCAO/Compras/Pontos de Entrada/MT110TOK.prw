#INCLUDE "PROTHEUS.CH"
/*
+----------+------------+-------------------+------+------------+
|Programa  |MT110TOK    | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Validação da alteraçao, exclusão da solicitanção    |
|          |de compras                                          |
+----------+----------------------------------------------------+
|Sintaxe   |ponto de entrada                                    |
+----------+----------------------------------------------------+
|Parametros|Paramixb[1] = lRetorno no momento da chamada do     | 
|          |ponto de entrada                                    |
|          |Paramixb[2] = Data da solicitação de compras        | 
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
*/
User Function MT110TOK
	Local lRet  := PARAMIXB[1]
	Local MV_YSTC01 := GetMv("MV_YSTC01")
	
	//verifica execução da rotina
	If MV_YSTC01
		//Verifica solicitante
		If	lRet ;  											//Retorno positivo do sistema
			.and. ALTERA ; 		    	                   		//Alteração
			.and. SC1->C1_SOLICIT <> Alltrim(cUserName)  	    //Usuário igual ao solicitante
				
			MsgInfo("Solicitante diferente do usuário, não será permitida a confirmação.","Sirtec - MT110TOK")
			//Retorno esperado
			lRet := .F.
		Endif
	//nao efetua nenhum tratamento, parametro desativado
	Else
		lRet := .T.	
	Endif
	
Return lRet