#INCLUDE "rwmake.ch"

/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA0101    | Microsiga Vit�ria | Data | 13.08.2008 |
+----------+------------+-------------------+------+------------+
|Descri��o |Fun��o para buscar valor do csll do documento       |
|          |                                                    |           
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


User Function STCA0101()


Local xValcsll := POSICIONE("SE1",2,XFILIAL("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC+" "+"NF "),"E1_CSLL")

IF xValcsll > 0
   xValcsll := POSICIONE("SE1",2,XFILIAL("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC+" "+"NF "),"E1_CSLL")
Else
   xValcsll := 0   
Endif

Return(xValcsll)   