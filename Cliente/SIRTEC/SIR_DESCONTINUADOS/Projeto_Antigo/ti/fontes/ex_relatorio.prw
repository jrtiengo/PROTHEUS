/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exemplo de relatorio usando tReport com uma Section
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC*/

user function EXCLIE

local oReport
local cPerg  := 'EXTREPCLI'
local cAlias := getNextAlias()

criaSx1(cPerg)
Pergunte(cPerg, .F.)

oReport := reportDef(cAlias, cPerg)
oReport:printDialog()

return
        
//+-----------------------------------------------------------------------------------------------+
//! Rotina para montagem dos dados do relatório.                                  !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportPrint(oReport,cAlias)
              
local oSecao1 := oReport:Section(1)

oSecao1:BeginQuery()

BeginSQL Alias cAlias
 
 SELECT A1_COD, A1_NOME, A1_MUN, A1_EST
 FROM %Table:SA1% SA1
 WHERE A1_COD BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
 
EndSQL

oSecao1:EndQuery()
oReport:SetMeter((cAlias)->(RecCount()))
oSecao1:Print() 

return

//+-----------------------------------------------------------------------------------------------+
//! Função para criação da estrutura do relatório.                                                !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportDef(cAlias,cPerg)

local cTitle  := "Relatório de Clientes"
local cHelp   := "Permite gerar relatório de clientes."
local oReport
local oSection1

oReport := TReport():New('EXCLI',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},cHelp)

//Primeira seção
oSection1 := TRSection():New(oReport,"Clientes",{"SA1"}) 

TRCell():New(oSection1,"A1_COD", "SA1", "Codigo")
TRCell():New(oSection1,"A1_NOME", "SA1", "Nome") 
TRCell():New(oSection1,"A1_MUN", "SA1", "Cidade") 
TRCell():New(oSection1,"A1_EST", "SA1", "Estado") 

Return(oReport)

//+-----------------------------------------------------------------------------------------------+
//! Função para criação das perguntas (se não existirem)                                          !
//+-----------------------------------------------------------------------------------------------+
static function criaSX1(cPerg)

putSx1(cPerg, '01', 'Cliente de?'          , '', '', 'mv_ch1', 'C', 6, 0, 0, 'G', '', 'SA1', '', '', 'mv_par01')
putSx1(cPerg, '02', 'Cliente até?'         , '', '', 'mv_ch2', 'C', 6, 0, 0, 'G', '', 'SA1', '', '', 'mv_par02')

return