#INCLUDE "rwmake.ch"

/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA0102    | Microsiga Vitória | Data | 25.08.2008 |
+----------+------------+-------------------+------+------------+
|Descrição |Funçao para buscar conta contabil por natureza ou   |              
|          |fornecedor                                          |
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


User Function STCA0102()


Local cOrigem := POSICIONE("SE2",1,XFILIAL("SE2")+SEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA),"E2_ORIGEM")
Local cContad := ""
Local nFornec := ""



IF ALLTRIM(cOrigem)="MATA100"

   cContad := POSICIONE("SED",1,XFILIAL("SED")+SE2->(E2_NATUREZ),"ED_CONTA")    

ELSE   
   cContad := POSICIONE("SA2",1,XFILIAL("SE2")+SE2->(E2_FORNECE+E2_LOJA),"A2_CONTA")

Endif   

Return(cContad)