#INCLUDE "rwmake.ch"

/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA0102    | Microsiga Vit�ria | Data | 25.08.2008 |
+----------+------------+-------------------+------+------------+
|Descri��o |Fun�ao para buscar conta contabil por natureza ou   |              
|          |fornecedor                                          |
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