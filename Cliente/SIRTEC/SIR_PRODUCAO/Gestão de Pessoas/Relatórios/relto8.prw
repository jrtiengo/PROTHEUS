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
	// #32076 Ajustes referente ao filtro das filiais. Acrescentada coluna para a filial e criado orderm por filial+data. Mauro - Solutio. 02/04/2022.
	BeginSQL Alias cAlias

		SELECT TO8_FILIAL, TO8_MAT, RA_NOME, TO8_CODOCO, TO8_DTOCOR, TO8_GRAVID, TO8_DESC

		FROM %Table:TO8% AS TO8

		// INNER JOIN %Table:SRA% AS SRA ON ( TO8.TO8_FILIAL = SRA.RA_FILIAL AND TO8.TO8_MAT = SRA.RA_MAT AND SRA.RA_FILIAL BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04% AND SRA.D_E_L_E_T_<>'*' )

		INNER JOIN %Table:SRA% AS SRA ON ( TO8.TO8_FILIAL = SRA.RA_FILIAL AND TO8.TO8_MAT = SRA.RA_MAT AND SRA.D_E_L_E_T_<>'*' )

		WHERE TO8_FILIAL BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
		
		AND TO8_MAT BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%

		ORDER BY TO8_FILIAL, TO8_DTOCOR

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

	TRCell():New(oSection1,"TO8_FILIAL", "TO8", "Filial")
	TRCell():New(oSection1,"TO8_MAT", "TO8", "Matricula")
	TRCell():New(oSection1,"RA_NOME", "SRA", "Nome do Func")
	TRCell():New(oSection1,"TO8_CODOCO", "TO8", "Codigo Ocorrencia")
	TRCell():New(oSection1,"TO8_DTOCOR", "TO8", "Data da Ocorrencia")
	TRCell():New(oSection1,"TO8_GRAVID", "TO8", "Gravidade")
	TRCell():New(oSection1,"TO8_DESC", "TO8", "Descricao - Memo")

Return(oReport)
