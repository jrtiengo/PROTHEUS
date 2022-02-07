#INCLUDE "rwmake.ch"

/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA0101    | Microsiga Vitória | Data | 13.08.2008 |
+----------+------------+-------------------+------+------------+
|Descrição |Função para buscar valor do csll do documento       |
|          |                                                    |           
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


User Function STCA0101()


Local xValcsll := POSICIONE("SE1",2,XFILIAL("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC+" "+"NF "),"E1_CSLL")

IF xValcsll > 0
   xValcsll := POSICIONE("SE1",2,XFILIAL("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC+" "+"NF "),"E1_CSLL")
Else
   xValcsll := 0   
Endif

Return(xValcsll)   