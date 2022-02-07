#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA005     | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Validação da quantidade do produto no pedido        |
|          |de venda                                            |
+----------+----------------------------------------------------+
|Sintaxe   |Validação de usuário                                |
+----------+----------------------------------------------------+
|Parametros|cProduto,nQuantidade                                |
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
User Function STCA005
	//Variaveis locais
	Local cProduto	:= PARAMIXB[1]					//produto utilizado
	Local nQuant	:= PARAMIXB[2]                  //quantidade digitada
	Local nQTDDig	:= 0
	Local lRet		:= .T.                          //retorno esperado
	Local MV_YPEDMSG:= GetMv("MV_YPEDMSG")          //codigo da formula contendo a mensagem 
	Local MV_YSTC02 := GetMv("MV_YSTC02")
	
	//verifica execução da rotina
	If MV_YSTC02
		//Verifica quantidade digitada
		If nQuant >= SB1->B1_YMSOLIC
			lRet := .F.
			MsgInfo(&(Posicione("SM4",1,xFilial("SM4")+MV_YPEDMSG,"M4_FORMULA")),"Sirtec - SCTA005")
		Else
			//Verifica todo o acols
			For st:=1 to Len(aCols)
				If !GdDeleted(st)
					If GdFieldGet("C7_PRODUTO",st) == cProduto
						nQTDDig += GdFieldGet("C7_QUANT",st)
					Endif	
				Endif
			Next st
			//Verifica quantidade no acols
			If nQTDDig >= SB1->B1_YMSOLIC
				lRet := .F.
				MsgInfo(&(Posicione("SM4",1,xFilial("SM4")+MV_YPEDMSG,"M4_FORMULA")),"Sirtec - SCTA005")
			Endif
		Endif
	//nao efetua nenhum tratamento, parametro desativado
	Else
		lRet := .T.
	Endif

Return lRet