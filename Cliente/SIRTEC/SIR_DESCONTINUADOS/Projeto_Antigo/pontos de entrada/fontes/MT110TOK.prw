#INCLUDE "PROTHEUS.CH"
/*
+----------+------------+-------------------+------+------------+
|Programa  |MT110TOK    | Microsiga Vit�ria | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descri��o |Valida��o da altera�ao, exclus�o da solicitan��o    |
|          |de compras                                          |
+----------+----------------------------------------------------+
|Sintaxe   |ponto de entrada                                    |
+----------+----------------------------------------------------+
|Parametros|Paramixb[1] = lRetorno no momento da chamada do     | 
|          |ponto de entrada                                    |
|          |Paramixb[2] = Data da solicita��o de compras        | 
+----------+----------------------------------------------------+
|Retorno   |logico                                              |
+----------+----------------------------------------------------+
|Uso       |Compras - Sirtec                                    |
+----------+----------------------------------------------------+
|        ATUALIZA��ES SOFRIDAS DESDE A CONSTRU��O INCIAL        |
+------------+--------+-----------+-----------------------------+
|Fun��o      |Data    |Programador| Mutivo da Altera�ao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
*/
User Function MT110TOK
	Local lRet  := PARAMIXB[1]
	Local MV_YSTC01 := GetMv("MV_YSTC01")
	
	//verifica execu��o da rotina
	If MV_YSTC01
		//Verifica solicitante
		If	lRet ;  											//Retorno positivo do sistema
			.and. ALTERA ; 		    	                   		//Altera��o
			.and. SC1->C1_SOLICIT <> Alltrim(cUserName)  	    //Usu�rio igual ao solicitante
				
			MsgInfo("Solicitante diferente do usu�rio, n�o ser� permitida a confirma��o.","Sirtec - MT110TOK")
			//Retorno esperado
			lRet := .F.
		Endif
	//nao efetua nenhum tratamento, parametro desativado
	Else
		lRet := .T.	
	Endif
	
Return lRet