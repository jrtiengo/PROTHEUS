#INCLUDE "REPORT.CH"
#INCLUDE "PROTHEUS.CH"   

/*
-------------------------------------------
- Relatório OS (AB8):    usando tReport   -
- Autor: Renato Gumesson                  -
- Data: 17/04/2014                        -
-------------------------------------------
*/

user function STCRAB8

local oReport
local cPerg  := 'ZZZAB8'
local cAlias := getNextAlias()

criaSx1(cPerg)
Pergunte(cPerg, .F.)

oReport := reportDef(cAlias, cPerg)
oReport:printDialog()

return
        
//--------------------------------------------------
//- Rotina para montagem dos dados do relatório.   -
//--------------------------------------------------
Static Function ReportPrint(oReport,cAlias)
              
local oSecao1 := oReport:Section(1)

oSecao1:BeginQuery()

BeginSQL Alias cAlias
 
 SELECT AB8_NUMOS, AB8_ITEM, AB8_SUBITE, AB8_CODPRO, AB8_DESPRO, AB8_QUANT, AB8_VUNIT, AB8_TOTAL, AB8_ENTREG, AB8_CODCLI, AB8_LOJA
 FROM %Table:AB8% AB8
 WHERE AB8_ENTREG >= %Exp:MV_PAR01% AND AB8_ENTREG <= %Exp:MV_PAR02% 
 AND   AB8_CODCLI >= %Exp:MV_PAR03% AND AB8_CODCLI <= %Exp:MV_PAR04% 
 AND   AB8_LOJA   >= %Exp:MV_PAR05% AND AB8_LOJA   <= %Exp:MV_PAR06%
 
EndSQL

oSecao1:EndQuery()
oReport:SetMeter((cAlias)->(RecCount()))
oSecao1:Print() 

return

//-----------------------------------------------------
//- Função para criação da estrutura do relatório.    -
//-----------------------------------------------------

Static Function ReportDef(cAlias,cPerg)

local cTitle  := "Relatório de apontamentos (subitens) da OS"
local cHelp   := "Permite gerar relatório de apontamentos da Ordem de Serviço."
local oReport
local oSection1

oReport := TReport():New('ZZZAB8',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},cHelp)

//Primeira seção
oSection1 := TRSection():New(oReport,"Apontamentos da OS",{"AB8"}) 

TRCell():New(oSection1,"AB8_NUMOS", "AB8", "Numero da OS")
TRCell():New(oSection1,"AB8_ITEM", "AB8", "Item") 
TRCell():New(oSection1,"AB8_SUBITE", "AB8", "Subitem") 
TRCell():New(oSection1,"AB8_CODPRO", "AB8", "Cod Produto")
TRCell():New(oSection1,"AB8_DESPRO", "AB8", "Descricao Produto") 
TRCell():New(oSection1,"AB8_QUANT", "AB8", "Quantidade") 
TRCell():New(oSection1,"AB8_VUNIT", "AB8", "Valor Unitario") 
TRCell():New(oSection1,"AB8_TOTAL", "AB8", "Total") 
TRCell():New(oSection1,"AB8_ENTREG", "AB8", "Entrega") 
TRCell():New(oSection1,"AB8_CODCLI", "AB8", "Codigo Cliente") 
TRCell():New(oSection1,"AB8_LOJA", "AB8", "Loja Cliente")  

TRFunction():New(oSection1:Cell("AB8_TOTAL"),,"SUM",,"Total",/*cPicture*/,/*uFormula*/,/*secao*/.F.,/*report*/.T.,/*pagina*/.F.)
oReport:SetTotalText("TOTAL GERAL")
oReport:SetTotalInLine(.F.)


Return(oReport)

//+-----------------------------------------------------------------------------------------------+
//! Função para criação das perguntas (se não existirem)                                          !
//+-----------------------------------------------------------------------------------------------+
static function criaSX1(cPerg)

putSx1(cPerg, '01', 'Data entrega de?'          , '', '', 'mv_ch1', 'D', 8, 0, 0, 'G', '', '', '', '', 'mv_par01')
putSx1(cPerg, '02', 'Data entrega ate?'         , '', '', 'mv_ch2', 'D', 8, 0, 0, 'G', '', '', '', '', 'mv_par02')
putSx1(cPerg, '03', 'Codigo Cliente de?'        , '', '', 'mv_ch3', 'C', 6, 0, 0, 'G', '', '', '', '', 'mv_par03')
putSx1(cPerg, '04', 'Codigo Cliente ate?'       , '', '', 'mv_ch4', 'C', 6, 0, 0, 'G', '', '', '', '', 'mv_par04')
putSx1(cPerg, '05', 'Loja Cliente de?'          , '', '', 'mv_ch5', 'C', 2, 0, 0, 'G', '', '', '', '', 'mv_par05')
putSx1(cPerg, '06', 'Loja Cliente ate?'         , '', '', 'mv_ch6', 'C', 2, 0, 0, 'G', '', '', '', '', 'mv_par06')
//putSx1(cPerg, '07', 'Teste de?'         , '', '', 'mv_ch7', 'C', 2, 0, 0, 'G', '', 'AB8', '', '', 'mv_par07')

return