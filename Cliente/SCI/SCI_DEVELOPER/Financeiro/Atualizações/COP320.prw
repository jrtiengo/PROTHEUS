#Include 'rwmake.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณCOP320   บAutor  ณMicrosiga           บ Data ณ  12/25/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณRetirno de Instrucoes Bancarias                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP 10                                                      บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function COP320()

Local cRet := '0000'

/*
BB
1) E1_SALDO < 5000 C/ INSTRUCAO DE CARTORIO > BRASIL17.REM
2) SALDO > 5000 S/ INSTRUCAO > BRASI171.REM
3) IMPRESSAO PELO BANCO > BRASIL.REM CARTEIRA 11  >>> O USUARIO VAI ESCOLHER MANUALMENTE DE ACORDO COM OS TITULOS QUE RESTARAM....

ITAU
IDEM AOS CASOS 1 E 2 DO BB
*/


If SE1->E1_SALDO < 5000 //Terแ instrucao para Protesto
   cRet := '0601'
Else //Nใo terแ instru็ใo de cart๓rio
   cRet := '0701'
EndIf

Return(cRet)