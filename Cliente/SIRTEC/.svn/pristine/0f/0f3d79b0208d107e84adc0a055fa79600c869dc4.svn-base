#INCLUDE "RWMAKE.CH"

/*
+----------+------------+-------------------+------+------------+
|Programa  |MT100GE2    | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Ponto de entrada após a geração no Titulo a Pagar   |
|          |no Documento de Entrada                             |
+----------+----------------------------------------------------+
|Sintaxe   |Executa atualização STCA010                         |
+----------+----------------------------------------------------+
|Parametros|#                                                   |
+----------+----------------------------------------------------+
|Retorno   |#                                                   |
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

User Function MT100GE2
   Local aArea := GetArea()
   ////---------------------------------------
   //// Leef - Vanessa - 23/10/19 - Chamado 44172
   //SD1->(DbSelectArea("SD1"))
   //SD1->(DbSetOrder(1))
   //SD1->(DbGotop())
   //SD1->(DbSeek(xFilial("SD1") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)) )
   //if !empty(sd1->d1_pedido)
   //   dbselectarea("SC7")
   //   dbsetorder(1)  // filial+num
   //   dbseek(xFilial("SC7")+sd1->d1_pedido)
   //   if !empty(sc7->c7_frmpag)
   //      SE2->(DbSelectArea("SE2"))
   //      SE2->(RecLock("SE2",.f.))
   //      SE2->E2_FRMPAG:= if(sc7->c7_frmpag=='1','BOLETO', 'DEPOSITO')
   //      SE2->(MsUnLock())   
   //   endif
   //endif  
   //RestArea(aArea)    
   //---------------------------------------        
	//Verifica pedidos, para executar a liberação do titulo
	Execblock("STCA010",.F.,.F.)
	RestArea(aArea)    
		
Return                              