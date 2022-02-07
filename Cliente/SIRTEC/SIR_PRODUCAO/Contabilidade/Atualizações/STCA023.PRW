#INCLUDE "rwmake.ch"
/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA0023    | Microsiga Vitória | Data | 30.10.2007 |
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


User Function STCA023()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private cContd  := ""

Private cCcusto  := Alltrim(Posicione("SRA",2,xFilial("SRA")+SRZ->RZ_CC,"RA_CC"))

IF cCcusto = "0101010101"
   cContd := POSICIONE("SRV",1,XFILIAL("SRV")+SRZ->RZ_PD,"RV_YCONT1")
Elseif cCcusto = "0101010112"                                         
   cContd := POSICIONE("SRV",1,XFILIAL("SRV")+SRZ->RZ_PD,"RV_YCONT3")
Elseif cCcusto <> "0101010112" .or. cCcusto <> "0101010101"           
   cContd := POSICIONE("SRV",1,XFILIAL("SRV")+SRZ->RZ_PD,"RV_YCONTD")                                 
Endif


Return(cContd)
