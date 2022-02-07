#include "TOTVS.CH" 
#include "rwmake.CH"
#INCLUDE "Protheus.ch" 
#include "ap5mail.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ EasyRpt  ³ Autor ³ Manoel Mariante       ³ Data ³ jan/2018   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ impressao relatorios diversos configurados via arq INI       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ diversos               				                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//------------------------------------------------------------------
User Function TEDR005()
//------------------------------------------------------------------

U_EZRPT('TEDR005.INI',.f.)

RETURN

User Function MyCopy2Sys()
//IF FERASE('\system\tedr010.ini')
//alert('sim')
//End
IF CpyT2S("c:\temp\tedr005.ini","\system\",.t.)
	Alert('Copia tedr005 OK')
else
	Alert('Problema na Cópia tedr005')
End

IF CpyT2S("c:\temp\tedr010.ini","\system\",.t.)
	Alert('Copia tedr010 OK')
else
	Alert('Problema na Cópia tedr010')
End

If file("\system\tedr005.ini")
	alert('achei o arquivo ted005')
else
	alert('nao achei o arqu tedr005')
end
If file("\system\tedr010.ini")
	alert('achei o arquivo td10')
else
	alert('nao achei o arqu tedr010')
end
Return