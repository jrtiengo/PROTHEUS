/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Relatório usando tReport com uma Section
//³ Finalidade: Exibir as ocorrências do funcionário
//³ Autor: Renato Gumesson
//³ Data: 07 Nov 2016
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC*/

user function RELTO8

local oReport
local cPerg  := 'PEROCORR'
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
 
 SELECT TO8_MAT, RA_NOME, TO8_CODOCO, TO8_DTOCOR, TO8_GRAVID, TO8_DESC
 
 FROM %Table:TO8% AS TO8
 
 LEFT JOIN %Table:SRA% AS SRA ON TO8.TO8_MAT = SRA.RA_MAT AND SRA.D_E_L_E_T_<>'*'
 
 WHERE TO8_MAT BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
 
EndSQL

oSecao1:EndQuery()
oReport:SetMeter((cAlias)->(RecCount()))
oSecao1:Print() 

return

//+-----------------------------------------------------------------------------------------------+
//! Função para criação da estrutura do relatório.                                                !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportDef(cAlias,cPerg)

local cTitle  := "Relatório de Ocorrências de Funcionário"
local cHelp   := "Permite gerar relatório de Ocorrências de Funcionários."
local oReport
local oSection1

oReport := TReport():New('RELTO8',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},cHelp)

//Primeira seção
oSection1 := TRSection():New(oReport,"Ocorrencias Funcionario",{"T08"}) 

TRCell():New(oSection1,"TO8_MAT", "TO8", "Matricula")
TRCell():New(oSection1,"RA_NOME", "SRA", "Nome do Func")
TRCell():New(oSection1,"TO8_CODOCO", "TO8", "Codigo Ocorrencia") 
TRCell():New(oSection1,"TO8_DTOCOR", "TO8", "Data da Ocorrencia") 
TRCell():New(oSection1,"TO8_GRAVID", "TO8", "Gravidade") 
TRCell():New(oSection1,"TO8_DESC", "TO8", "Descricao - Memo")

Return(oReport)

//+-----------------------------------------------------------------------------------------------+
//! Função para criação das perguntas (se não existirem)                                          !
//! Lembrar de incluir a CONSULTA PADRÃO no configurador... neste caso a consulta 'TO8'           !
//+-----------------------------------------------------------------------------------------------+
static function criaSX1(cPerg)

putSx1(cPerg, '01', 'Matricula de?'          , '', '', 'mv_ch1', 'C', 6, 0, 0, 'G', '', 'TO8', '', '', 'mv_par01')
putSx1(cPerg, '02', 'Matricula até?'         , '', '', 'mv_ch2', 'C', 6, 0, 0, 'G', '', 'TO8', '', '', 'mv_par02')

return