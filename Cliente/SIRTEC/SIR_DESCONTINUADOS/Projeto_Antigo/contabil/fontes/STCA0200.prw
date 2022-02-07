#INCLUDE "rwmake.ch"

/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA0200    | Microsiga Vit�ria | Data | 26.02.2009 |
+----------+------------+-------------------+------+------------+
|Descri��o |Fun��o para buscar conta contabil                   |
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


User Function STCA0200()


Local cConta   := ""
Local cPrefixo := POSICIONE("SE2",1,XFILIAL("SE2")+SEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO+EF_FORNECE+EF_LOJA),"E2_PREFIXO")


IF cPrefixo == "GPE"
   //SE2->E2_NATUREZ=="201011020" .OR. SE2->E2_NATUREZ=="202011015" .OR. SE2->E2_NATUREZ=="202011022" .OR.;
   //SE2->E2_NATUREZ=="201011034"   
   cConta := SED->ED_CONTA
   
Else

   cConta := SA2->A2_CONTA

Endif   

Return(cConta)   