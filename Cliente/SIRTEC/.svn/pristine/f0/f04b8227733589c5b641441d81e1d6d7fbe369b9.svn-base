#INCLUDE "rwmake.ch"
/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA0024    | Microsiga Vitória | Data | 30.10.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Grava a conta contabil de acordo com a categoria    |
|          |do funcionario.                                     |
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


User Function STCA024()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private cContc  := ""

Private cCcusto  := Alltrim(Posicione("SRA",2,xFilial("SRA")+SRZ->RZ_CC,"RA_CC"))

IF cCcusto = "0101010101"
   cContc := POSICIONE("SRV",1,XFILIAL("SRV")+SRZ->RZ_PD,"RV_YCONT2")
Elseif cCcusto = "0101010112"                                         
   cContc := POSICIONE("SRV",1,XFILIAL("SRV")+SRZ->RZ_PD,"RV_YCONT4")
Elseif cCcusto <> "0101010112" .or. cCcusto <> "0101010101"           
   cContc := POSICIONE("SRV",1,XFILIAL("SRV")+SRZ->RZ_PD,"RV_YCONTC")                                 
Endif

Return(cContc)
