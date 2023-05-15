#Include 'Protheus.ch'
Static nPagina := 0
Static cHora := Time()
Static dData := Date()
	
/*/{Protheus.doc} RFIN033
Relatório de Faturamento Liquido

@author	Plauto
@since	01/02/2023
@return NIL	
/*/

User Function RFIN033()
	Local oReport
	Local cPerg := "RFIN011"

	AjustaSX1(cPerg)

	If !Pergunte(cPerg)

		Return

	Endif

	oReport := ReportDef(cPerg)
	oReport:PrintDialog()

Return


//---------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Constrói o objeto instância da Classe TReport


@author Thiago Henrique dos Santos
@since 05/02/2015
@version P11
@return oReport  - Objeto instância da classe TReport
/*/
//---------------------------------------------------------------------

Static Function ReportDef(cPerg)
	Local oReport
	Local oSection   //secao do Relatório
	nPagina := 0
	cHora := Time()
	dData := Date()

	oReport := TReport():New("RFIN033","Faturamento Liquido",cPERG,{|oReport| ReportPrint(oReport)},;
		"O relatório apresentará o faturamento liquido do período e filiais selecionadas")
	oReport:HideHeader()
	oReport:HideParamPage()
	oReport:SetLandScape()
	oReport:bOnPageBreak := {|| PrintCab(oReport)}
	//Atualiza a propriedade bOnPageBreak

	oSecCab:= TRSection():New(oReport,"Faturamento Liquido",{"SF2","SA1","SF1"},/*aOrdem*/)

	oSecCab:SetLineStyle()
	TRCell():New(oSecCab,"GRUPO RIC",,"" ,X3Picture("Z51_NOMFIL"),100,/*lPixel*/)

	oSection:= TRSection():New(oSecCab,"Faturamento Liquido",{"SF2","SA1","SF1"},/*aOrdem*/)

	oSection:SetHeaderBreak(.T.)
	oSection:SetHeaderPage(.F.)

	TRCell():New(oSection,"Filial",,"Codigo" ,X3Picture("Z51_NOMFIL"),TamSx3("Z51_NOMFIL")[1]+10,/*lPixel*/)
	TRCell():New(oSection,"JAN",,"Janeiro"  ,X3Picture("E3_VRLIQ"),TamSx3("E3_VRLIQ")[1]+10,/*lPixel*/)
	TRCell():New(oSection,"FEV",,"Fevereiro"  ,X3Picture("E3_VRLIQ"),TamSx3("E3_VRLIQ")[1]+10,/*lPixel*/)
	TRCell():New(oSection,"MAR",,"Março"  ,X3Picture("E3_VRLIQ"),TamSx3("E3_VRLIQ")[1]+10,/*lPixel*/)
	TRCell():New(oSection,"ABR",,"Abril"  ,X3Picture("E3_VRLIQ"),TamSx3("E3_VRLIQ")[1]+10,/*lPixel*/)
	TRCell():New(oSection,"MAI",,"Maio"  ,X3Picture("E3_VRLIQ"),TamSx3("E3_VRLIQ")[1]+10,/*lPixel*/)
	TRCell():New(oSection,"JUN",,"Junho"  ,X3Picture("E3_VRLIQ"),TamSx3("E3_VRLIQ")[1]+10,/*lPixel*/)
	TRCell():New(oSection,"JUL",,"Julho"  ,X3Picture("E3_VRLIQ"),TamSx3("E3_VRLIQ")[1]+10,/*lPixel*/)
	TRCell():New(oSection,"AGO",,"Agosto"  ,X3Picture("E3_VRLIQ"),TamSx3("E3_VRLIQ")[1]+10,/*lPixel*/)
	TRCell():New(oSection,"SET",,"Setembro"  ,X3Picture("E3_VRLIQ"),TamSx3("E3_VRLIQ")[1]+10,/*lPixel*/)
	TRCell():New(oSection,"OUT",,"Outubro"  ,X3Picture("E3_VRLIQ"),TamSx3("E3_VRLIQ")[1]+10,/*lPixel*/)
	TRCell():New(oSection,"NOV",,"Novembro"  ,X3Picture("E3_VRLIQ"),TamSx3("E3_VRLIQ")[1]+10,/*lPixel*/)
	TRCell():New(oSection,"DEZ",,"Dezembro"  ,X3Picture("E3_VRLIQ"),TamSx3("E3_VRLIQ")[1]+10,/*lPixel*/)
	TRCell():New(oSection,"TOTAL",,"Total"  ,X3Picture("E3_VRLIQ"),TamSx3("E3_VRLIQ")[1]+15,,,,,,,,,,,.T.)
	//TRCell():New(/*oParent*/,/*cName,cAlias*/,/*cTitle*/,/*cPicture*/,/*nSize*/,/*lPixel*/,/*bBlock*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,lBold)


	oSection2:= TRSection():New(oSecCab,"Faturamento Liquido",{"SF2","SA1","SF1"},/*aOrdem*/)


	oSection2:SetHeaderBreak(.F.)
	oSection2:SetHeaderPage(.F.)
	oSection2:SetHeaderSection(.F.)

	TRCell():New(oSection2,"Filial",,"Codigo" ,X3Picture("Z51_NOMFIL"),TamSx3("Z51_NOMFIL")[1]+10,,,,,,,,,,,.T.)
	TRCell():New(oSection2,"JAN",,"Janeiro"  ,X3Picture("E3_VRLIQ"),TamSx3("E3_VRLIQ")[1]+10,,,,,,,,,,,.T.)
	TRCell():New(oSection2,"FEV",,"Fevereiro"  ,X3Picture("E3_VRLIQ"),TamSx3("E3_VRLIQ")[1]+10,,,,,,,,,,,.T.)
	TRCell():New(oSection2,"MAR",,"Março"  ,X3Picture("E3_VRLIQ"),TamSx3("E3_VRLIQ")[1]+10,,,,,,,,,,,.T.)
	TRCell():New(oSection2,"ABR",,"Abril"  ,X3Picture("E3_VRLIQ"),TamSx3("E3_VRLIQ")[1]+10,,,,,,,,,,,.T.)
	TRCell():New(oSection2,"MAI",,"Maio"  ,X3Picture("E3_VRLIQ"),TamSx3("E3_VRLIQ")[1]+10,,,,,,,,,,,.T.)
	TRCell():New(oSection2,"JUN",,"Junho"  ,X3Picture("E3_VRLIQ"),TamSx3("E3_VRLIQ")[1]+10,,,,,,,,,,,.T.)
	TRCell():New(oSection2,"JUL",,"Julho"  ,X3Picture("E3_VRLIQ"),TamSx3("E3_VRLIQ")[1]+10,,,,,,,,,,,.T.)
	TRCell():New(oSection2,"AGO",,"Agosto"  ,X3Picture("E3_VRLIQ"),TamSx3("E3_VRLIQ")[1]+10,,,,,,,,,,,.T.)
	TRCell():New(oSection2,"SET",,"Setembro"  ,X3Picture("E3_VRLIQ"),TamSx3("E3_VRLIQ")[1]+10,,,,,,,,,,,.T.)
	TRCell():New(oSection2,"OUT",,"Outubro"  ,X3Picture("E3_VRLIQ"),TamSx3("E3_VRLIQ")[1]+10,,,,,,,,,,,.T.)
	TRCell():New(oSection2,"NOV",,"Novembro"  ,X3Picture("E3_VRLIQ"),TamSx3("E3_VRLIQ")[1]+10,,,,,,,,,,,.T.)
	TRCell():New(oSection2,"DEZ",,"Dezembro"  ,X3Picture("E3_VRLIQ"),TamSx3("E3_VRLIQ")[1]+10,,,,,,,,,,,.T.)
	TRCell():New(oSection2,"TOTAL",,"Total"  ,X3Picture("E3_VRLIQ"),TamSx3("E3_VRLIQ")[1]+15,,,,,,,,,,,.T.)


Return oReport


	//------------------------------------------------------------------------------------------
	/*/{Protheus.doc} PrintCab()
	Função para impressão do cabeçalho específico em início de página

	@sample		ReportPrint(oReport)

	@param		oReport Objeto com as definições do tReport


	@author		Thiago Henrique dos Santos
	@since		30/10/2015
	@version	P11
	/*/
//------------------------------------------------------------------------------------------

Static Function PrintCab(oReport)
	Local oSecCab := oReport:Section(1)
	Local oFont12	:= TFont():New('Calibri',10,10,,.T.,,,,.T.,.F.)

	nPagina++

	oReport:SkipLine()
	oReport:Say(oReport:Row(),10,"RFIN033",oFont12)
	oReport:Say(oReport:Row(),400,"Folha: "+cValToChar(nPagina),oFont12)
	oReport:Say(oReport:Row(),(oReport:GetWidth()/2)-130,"Faturamento Liquido",oFont12)
	oReport:SkipLine()
	oReport:Say(oReport:Row(),10,"Data: "+DtoC(dData),oFont12)
	oReport:Say(oReport:Row(),400,"Hora: "+cHora,oFont12)

	oReport:SkipLine()
	oReport:Say(oReport:Row(),10,"Empresa: Grupo RIC",oFont12)
	oReport:SkipLine()
	oReport:SkipLine()
	oReport:Line(oReport:Row(),10,oReport:Row(),oReport:GetWidth())

	oSecCab:PrintLine()


return

	//------------------------------------------------------------------------------------------
	/*/{Protheus.doc} ReportPrint()
	Função para impressão do relatório

	@sample		ReportPrint(oReport)

	@param		oReport Objeto com as definições do tReport


	@author		Thiago Henrique dos Santos
	@since		25/11/2014
	@version	P11
	/*/
//------------------------------------------------------------------------------------------
Static Function ReportPrint(oReport)
	Local oSection := oReport:Section(1):Section(1)
	Local oSection2 := oReport:Section(1):Section(2)
	Local oSecCab := oReport:Section(1)
	Local cAlias	:= GetNextAlias()
	Local aArea := GetArea()
	Local aVendas := {}
	Local cAnoTemp	:= ""
	Local oFont20		:= TFont():New('Arial',16,16,,.F.,,,,.T.,.F.)


	oReport:SetMeter(0)
	oReport:IncMeter()

	ExecQuery(cAlias)

	(cAlias)->(DbGoTop())

	If (cAlias)->(!Eof())

		oSecCab:Init()
		oSecCab:PrintLine()
		oReport:Say(oReport:Row(),16,(cAlias)->ANO,oFont20)
		oReport:SkipLine()

		oSection:Init()

		AAdd(aVendas,{0,0,0,0,0,0,0,0,0,0,0,0,0})

	Endif


	While ((cAlias)->(!Eof()))

		oReport:IncMeter()

		If !Empty(cAnoTemp) .AND. cAnoTemp <> (cAlias)->ANO

			oSection2:Init()
			oSection2:Cell("FILIAL"):SetValue(Alltrim("TOTAL"))
			oSection2:Cell("JAN"):SetValue(aVendas[len(aVendas)][1])
			oSection2:Cell("FEV"):SetValue(aVendas[len(aVendas)][2])
			oSection2:Cell("MAR"):SetValue(aVendas[len(aVendas)][3])
			oSection2:Cell("ABR"):SetValue(aVendas[len(aVendas)][4])
			oSection2:Cell("MAI"):SetValue(aVendas[len(aVendas)][5])
			oSection2:Cell("JUN"):SetValue(aVendas[len(aVendas)][6])
			oSection2:Cell("JUL"):SetValue(aVendas[len(aVendas)][7])
			oSection2:Cell("AGO"):SetValue(aVendas[len(aVendas)][8])
			oSection2:Cell("SET"):SetValue(aVendas[len(aVendas)][9])
			oSection2:Cell("OUT"):SetValue(aVendas[len(aVendas)][10])
			oSection2:Cell("NOV"):SetValue(aVendas[len(aVendas)][11])
			oSection2:Cell("DEZ"):SetValue(aVendas[len(aVendas)][12])
			oSection2:Cell("TOTAL"):SetValue(aVendas[len(aVendas)][13])
			oSection2:PrintLine()


			If len(aVendas) > 1

				oSection2:Cell("FILIAL"):SetValue(Alltrim("% Crescimento"))
				oSection2:Cell("JAN"):SetValue(100*(aVendas[len(aVendas)][1] / aVendas[len(aVendas)-1][1]-1)  )
				oSection2:Cell("FEV"):SetValue(100*(aVendas[len(aVendas)][2] / aVendas[len(aVendas)-1][2]-1)  )
				oSection2:Cell("MAR"):SetValue(100*(aVendas[len(aVendas)][3] / aVendas[len(aVendas)-1][3]-1)  )
				oSection2:Cell("ABR"):SetValue(100*(aVendas[len(aVendas)][4] / aVendas[len(aVendas)-1][4]-1)  )
				oSection2:Cell("MAI"):SetValue(100*(aVendas[len(aVendas)][5] / aVendas[len(aVendas)-1][5]-1)  )
				oSection2:Cell("JUN"):SetValue(100*(aVendas[len(aVendas)][6] / aVendas[len(aVendas)-1][6]-1)  )
				oSection2:Cell("JUL"):SetValue(100*(aVendas[len(aVendas)][7] / aVendas[len(aVendas)-1][7]-1)  )
				oSection2:Cell("AGO"):SetValue(100*(aVendas[len(aVendas)][8] / aVendas[len(aVendas)-1][8]-1)  )
				oSection2:Cell("SET"):SetValue(100*(aVendas[len(aVendas)][9] / aVendas[len(aVendas)-1][9]-1)  )
				oSection2:Cell("OUT"):SetValue(100*(aVendas[len(aVendas)][10] / aVendas[len(aVendas)-1][10]-1)  )
				oSection2:Cell("NOV"):SetValue(100*(aVendas[len(aVendas)][11] / aVendas[len(aVendas)-1][11]-1)  )
				oSection2:Cell("DEZ"):SetValue(100*(aVendas[len(aVendas)][12] / aVendas[len(aVendas)-1][12]-1)  )
				oSection2:Cell("TOTAL"):SetValue((100*aVendas[len(aVendas)][13] / aVendas[len(aVendas)-1][13])  )
				oSection2:PrintLine()

			EndIF

			oSection2:Finish()
			oSection:Finish()
			oSecCab:Finish()

			oReport:SkipLine()
			oSecCab:PrintLine()
			oReport:Say(oReport:Row(),16,(cAlias)->ANO,oFont20)
			oReport:SkipLine()

			oSection:Init()

			AAdd(aVendas,{0,0,0,0,0,0,0,0,0,0,0,0,0})

			
			oSection:Cell("FILIAL"):SetValue((cAlias)->FILIAL)
			oSection:Cell("JAN"):SetValue((cAlias)->JAN)
			oSection:Cell("FEV"):SetValue((cAlias)->FEV)
			oSection:Cell("MAR"):SetValue((cAlias)->MAR)
			oSection:Cell("ABR"):SetValue((cAlias)->ABR)
			oSection:Cell("MAI"):SetValue((cAlias)->MAI)
			oSection:Cell("JUN"):SetValue((cAlias)->JUN)
			oSection:Cell("JUL"):SetValue((cAlias)->JUL)
			oSection:Cell("AGO"):SetValue((cAlias)->AGO)
			oSection:Cell("SET"):SetValue((cAlias)->SETEMBRO)
			oSection:Cell("OUT"):SetValue((cAlias)->OUTUBRO)
			oSection:Cell("NOV"):SetValue((cAlias)->NOV)
			oSection:Cell("DEZ"):SetValue((cAlias)->DEZ)
			oSection:Cell("TOTAL"):SetValue((cAlias)->TOTAL)
			oSection:PrintLine()
			
			aVendas[len(aVendas)][1] += (cAlias)->JAN
			aVendas[len(aVendas)][2] += (cAlias)->FEV
			aVendas[len(aVendas)][3] += (cAlias)->MAR
			aVendas[len(aVendas)][4] += (cAlias)->ABR
			aVendas[len(aVendas)][5] += (cAlias)->MAI
			aVendas[len(aVendas)][6] += (cAlias)->JUN
			aVendas[len(aVendas)][7] += (cAlias)->JUL
			aVendas[len(aVendas)][8] += (cAlias)->AGO
			aVendas[len(aVendas)][9] += (cAlias)->SETEMBRO
			aVendas[len(aVendas)][10] += (cAlias)->OUTUBRO
			aVendas[len(aVendas)][11] += (cAlias)->NOV
			aVendas[len(aVendas)][12] += (cAlias)->DEZ
			aVendas[len(aVendas)][13] += (cAlias)->TOTAL
			


		Else

			oSection:Cell("FILIAL"):SetValue((cAlias)->FILIAL)
			oSection:Cell("JAN"):SetValue((cAlias)->JAN)
			oSection:Cell("FEV"):SetValue((cAlias)->FEV)
			oSection:Cell("MAR"):SetValue((cAlias)->MAR)
			oSection:Cell("ABR"):SetValue((cAlias)->ABR)
			oSection:Cell("MAI"):SetValue((cAlias)->MAI)
			oSection:Cell("JUN"):SetValue((cAlias)->JUN)
			oSection:Cell("JUL"):SetValue((cAlias)->JUL)
			oSection:Cell("AGO"):SetValue((cAlias)->AGO)
			oSection:Cell("SET"):SetValue((cAlias)->SETEMBRO)
			oSection:Cell("OUT"):SetValue((cAlias)->OUTUBRO)
			oSection:Cell("NOV"):SetValue((cAlias)->NOV)
			oSection:Cell("DEZ"):SetValue((cAlias)->DEZ)
			oSection:Cell("TOTAL"):SetValue((cAlias)->TOTAL)
			oSection:PrintLine()

			
			aVendas[len(aVendas)][1] += (cAlias)->JAN
			aVendas[len(aVendas)][2] += (cAlias)->FEV
			aVendas[len(aVendas)][3] += (cAlias)->MAR
			aVendas[len(aVendas)][4] += (cAlias)->ABR
			aVendas[len(aVendas)][5] += (cAlias)->MAI
			aVendas[len(aVendas)][6] += (cAlias)->JUN
			aVendas[len(aVendas)][7] += (cAlias)->JUL
			aVendas[len(aVendas)][8] += (cAlias)->AGO
			aVendas[len(aVendas)][9] += (cAlias)->SETEMBRO
			aVendas[len(aVendas)][10] += (cAlias)->OUTUBRO
			aVendas[len(aVendas)][11] += (cAlias)->NOV
			aVendas[len(aVendas)][12] += (cAlias)->DEZ
			aVendas[len(aVendas)][13] += (cAlias)->TOTAL
		

		Endif
		
		cAnoTemp := (cAlias)->ANO

		(cAlias)->(DbSkip())
		
	Enddo
	/* Tiengo 28/02/2023 - Removida a linha TOTAL, solicitada pelo cliente.
	If !Empty(cAnoTemp)

		oSection2:Init()
		oSection2:Cell("FILIAL"):SetValue(Alltrim("TOTAL"))
		oSection2:Cell("JAN"):SetValue(aVendas[len(aVendas)][1])
		oSection2:Cell("FEV"):SetValue(aVendas[len(aVendas)][2])
		oSection2:Cell("MAR"):SetValue(aVendas[len(aVendas)][3])
		oSection2:Cell("ABR"):SetValue(aVendas[len(aVendas)][4])
		oSection2:Cell("MAI"):SetValue(aVendas[len(aVendas)][5])
		oSection2:Cell("JUN"):SetValue(aVendas[len(aVendas)][6])
		oSection2:Cell("JUL"):SetValue(aVendas[len(aVendas)][7])
		oSection2:Cell("AGO"):SetValue(aVendas[len(aVendas)][8])
		oSection2:Cell("SET"):SetValue(aVendas[len(aVendas)][9])
		oSection2:Cell("OUT"):SetValue(aVendas[len(aVendas)][10])
		oSection2:Cell("NOV"):SetValue(aVendas[len(aVendas)][11])
		oSection2:Cell("DEZ"):SetValue(aVendas[len(aVendas)][12])
		oSection2:Cell("TOTAL"):SetValue(aVendas[len(aVendas)][13])
		oSection2:PrintLine()

		If len(aVendas) > 1

			oSection2:Cell("FILIAL"):SetValue(Alltrim("% Crescimento"))
			oSection2:Cell("JAN"):SetValue(100*(aVendas[len(aVendas)][1] / aVendas[len(aVendas)-1][1]-1)  )
			oSection2:Cell("FEV"):SetValue(100*(aVendas[len(aVendas)][2] / aVendas[len(aVendas)-1][2]-1)  )
			oSection2:Cell("MAR"):SetValue(100*(aVendas[len(aVendas)][3] / aVendas[len(aVendas)-1][3]-1)  )
			oSection2:Cell("ABR"):SetValue(100*(aVendas[len(aVendas)][4] / aVendas[len(aVendas)-1][4]-1)  )
			oSection2:Cell("MAI"):SetValue(100*(aVendas[len(aVendas)][5] / aVendas[len(aVendas)-1][5]-1)  )
			oSection2:Cell("JUN"):SetValue(100*(aVendas[len(aVendas)][6] / aVendas[len(aVendas)-1][6]-1)  )
			oSection2:Cell("JUL"):SetValue(100*(aVendas[len(aVendas)][7] / aVendas[len(aVendas)-1][7]-1)  )
			oSection2:Cell("AGO"):SetValue(100*(aVendas[len(aVendas)][8] / aVendas[len(aVendas)-1][8]-1)  )
			oSection2:Cell("SET"):SetValue(100*(aVendas[len(aVendas)][9] / aVendas[len(aVendas)-1][9]-1)  )
			oSection2:Cell("OUT"):SetValue(100*(aVendas[len(aVendas)][10] / aVendas[len(aVendas)-1][10]-1)  )
			oSection2:Cell("NOV"):SetValue(100*(aVendas[len(aVendas)][11] / aVendas[len(aVendas)-1][11]-1)  )
			oSection2:Cell("DEZ"):SetValue(100*(aVendas[len(aVendas)][12] / aVendas[len(aVendas)-1][12]-1)  )
			oSection2:Cell("TOTAL"):SetValue((100*aVendas[len(aVendas)][13] / aVendas[len(aVendas)-1][13]-1)  )
			oSection2:PrintLine()

		EndIF

		oSection2:Finish()
		oSection:Finish()
		oSecCab:Finish()

	Endif
	*/

	(cAlias)->(DbCloseArea())

	RestArea(aArea)

Return

	//------------------------------------------------------------------------------------------
	/*/{Protheus.doc} ExecQuery()
	Função que cria o Alias temporário


	@param		cAlias - Alias temporário a ser criado

	@author		Thiago Henrique dos Santos
	@since		05/02/2015
	@version	P11
	/*/
//------------------------------------------------------------------------------------------
Static Function ExecQuery(cAlias)

	Local cJan := "01"
	Local cFev := "02"
	Local cMar := "03"
	Local cAbr := "04"
	Local cMai := "05"
	Local cJun := "06"
	Local cJul := "07"
	Local cAgo := "08"
	Local cSet := "09"
	Local cOut := "10"
	Local cNov := "11"
	Local cDez := "12"
	Local cDataDe    := PadL(cValToChar(MV_PAR03),4)+"01"+"01"
	Local cDataAte   := PadL(cValToChar(MV_PAR04),4)+"12"+"31"
	Local cTipoDev   := "D"
	Local cJPCas     := "%('012201','012302')%"
	Local cParadise  := "%('012401','012501')%"
	Local cTopView	 := "%('011601','011701')%"
	//Local cTVSC		 := "%('022101','022101','022201','022301','022401','022501','022601','022701','023101','023301')%"
	//Local cJND		 := "%('022802','022808')%"
	Local cVBrutView := "% IIF( SF2.F2_EMISSAO <= '20180401' AND SD2.D2_TES = '556',0, SF2.F2_VALBRUT)  %"

	BeginSql Alias cAlias

        SELECT FILIAL,ANO,
        JAN - IsNull((SELECT SUM(D1_TOTAL) FROM SD1010 D1 
        WHERE D1_FILIAL = F2_FILIAL
        // AND D1_SERIE = F2_SERIE
        AND SUBSTRING(D1_EMISSAO,1,4) = ANO 
        AND SUBSTRING(D1_EMISSAO,5,2) = '01' 
        //AND D1_TES IN ('036','064','005','040') 1205 - 2205 - 1201 - 2201 - 1202 - 2205
		AND D1_CF IN ('1201','1202','1205','2201','2205')
        AND D1.%NotDel% ),0)  JAN ,
        FEV - IsNull((SELECT SUM(D1_TOTAL) FROM SD1010 D1 
        WHERE D1_FILIAL = F2_FILIAL  
        // AND D1_SERIE = F2_SERIE
        AND SUBSTRING(D1_EMISSAO,1,4) = ANO 
        AND SUBSTRING(D1_EMISSAO,5,2) = '02' 
        //AND D1_TES IN ('036','064','005','040')
        AND D1_CF IN ('1201','1202','1205','2201','2205')
		AND D1.%NotDel% ),0) FEV,
        MAR - IsNull((SELECT SUM(D1_TOTAL) FROM SD1010 D1 
        WHERE D1_FILIAL = F2_FILIAL  
        // AND D1_SERIE = F2_SERIE
        AND SUBSTRING(D1_EMISSAO,1,4) = ANO 
        AND SUBSTRING(D1_EMISSAO,5,2) = '03' 
        //AND D1_TES IN ('036','064','005','040')
        AND D1_CF IN ('1201','1202','1205','2201','2205')
		AND D1.%NotDel% ),0) MAR,
        ABR - IsNull((SELECT SUM(D1_TOTAL) FROM SD1010 D1 
        WHERE D1_FILIAL = F2_FILIAL  
        // AND D1_SERIE = F2_SERIE
        AND SUBSTRING(D1_EMISSAO,1,4) = ANO 
        AND SUBSTRING(D1_EMISSAO,5,2) = '04' 
        //AND D1_TES IN ('036','064','005','040')
        AND D1_CF IN ('1201','1202','1205','2201','2205')
		AND D1.%NotDel% ),0) ABR,
        MAI - IsNull((SELECT SUM(D1_TOTAL) FROM SD1010 D1 
        WHERE D1_FILIAL = F2_FILIAL  
        // AND D1_SERIE = F2_SERIE
        AND SUBSTRING(D1_EMISSAO,1,4) = ANO 
        AND SUBSTRING(D1_EMISSAO,5,2) = '05' 
        //AND D1_TES IN ('036','064','005','040')
        AND D1_CF IN ('1201','1202','1205','2201','2205')
		AND D1.%NotDel% ),0) MAI,
        JUN - IsNull((SELECT SUM(D1_TOTAL) FROM SD1010 D1 
        WHERE D1_FILIAL = F2_FILIAL  
        // AND D1_SERIE = F2_SERIE
        AND SUBSTRING(D1_EMISSAO,1,4) = ANO 
        AND SUBSTRING(D1_EMISSAO,5,2) = '06' 
        //AND D1_TES IN ('036','064','005','040')
        AND D1_CF IN ('1201','1202','1205','2201','2205')
		AND D1.%NotDel%),0) JUN,
        JUL - IsNull((SELECT SUM(D1_TOTAL) FROM SD1010 D1 
        WHERE D1_FILIAL = F2_FILIAL  
        // AND D1_SERIE = F2_SERIE
        AND SUBSTRING(D1_EMISSAO,1,4) = ANO 
        AND SUBSTRING(D1_EMISSAO,5,2) = '07' 
        //AND D1_TES IN ('036','064','005','040')
        AND D1_CF IN ('1201','1202','1205','2201','2205')
		AND D1.%NotDel% ),0) JUL,
        AGO - IsNull((SELECT SUM(D1_TOTAL) FROM SD1010 D1 
        WHERE D1_FILIAL = F2_FILIAL  
        // AND D1_SERIE = F2_SERIE
        AND SUBSTRING(D1_EMISSAO,1,4) = ANO 
        AND SUBSTRING(D1_EMISSAO,5,2) = '08' 
        //AND D1_TES IN ('036','064','005','040')
        AND D1_CF IN ('1201','1202','1205','2201','2205')
		AND D1.%NotDel%),0) AGO,
        SETEMBRO - IsNull((SELECT SUM(D1_TOTAL) FROM SD1010 D1 
        WHERE D1_FILIAL = F2_FILIAL  
        // AND D1_SERIE = F2_SERIE
        AND SUBSTRING(D1_EMISSAO,1,4) = ANO 
        AND SUBSTRING(D1_EMISSAO,5,2) = '09' 
        //AND D1_TES IN ('036','064','005','040')
        AND D1_CF IN ('1201','1202','1205','2201','2205')
		AND D1.%NotDel% ),0) SETEMBRO,
        OUTUBRO - IsNull((SELECT SUM(D1_TOTAL) FROM SD1010 D1 
        WHERE D1_FILIAL = F2_FILIAL  
        // AND D1_SERIE = F2_SERIE
        AND SUBSTRING(D1_EMISSAO,1,4) = ANO 
        AND SUBSTRING(D1_EMISSAO,5,2) = '10' 
        //AND D1_TES IN ('036','064','005','040')
        AND D1_CF IN ('1201','1202','1205','2201','2205')
		AND D1.%NotDel% ),0) OUTUBRO,
        NOV - IsNull((SELECT SUM(D1_TOTAL) FROM SD1010 D1 
        WHERE D1_FILIAL = F2_FILIAL  
        // AND D1_SERIE = F2_SERIE
        AND SUBSTRING(D1_EMISSAO,1,4) = ANO 
        AND SUBSTRING(D1_EMISSAO,5,2) = '11' 
        //AND D1_TES IN ('036','064','005','040')
        AND D1_CF IN ('1201','1202','1205','2201','2205')
		AND D1.%NotDel% ),0) NOV,
        DEZ - IsNull((SELECT SUM(D1_TOTAL) FROM SD1010 D1 
        WHERE D1_FILIAL = F2_FILIAL  
        // AND D1_SERIE = F2_SERIE
        AND SUBSTRING(D1_EMISSAO,1,4) = ANO 
        AND SUBSTRING(D1_EMISSAO,5,2) = '12' 
        //AND D1_TES IN ('036','064','005','040')
        AND D1_CF IN ('1201','1202','1205','2201','2205')
		AND D1.%NotDel% ),0) DEZ,
        
		TOTAL - ISNULL((SELECT SUM(D1_TOTAL)
  		FROM SD1010 D1
  		WHERE D1_FILIAL = F2_FILIAL
		AND SUBSTRING(D1_EMISSAO, 1, 4) = ANO
		AND D1_CF IN ('1201', '1202', '1205', '2201', '2205')
		AND D1.D_E_L_E_T_ = ' '), 0) TOTAL

        FROM (
		SELECT 	(CASE SF2.F2_FILIAL
           WHEN '011101' THEN 'TV CURITIBA / SERIE ' +F2_SERIE 
           WHEN '011201' THEN 'TV OESTE / SERIE ' +F2_SERIE 
           WHEN '011303' THEN 'TV MARINGA / SERIE ' +F2_SERIE 
           WHEN '011301' THEN 'TV LONDRINA / SERIE ' +F2_SERIE 
           WHEN '012001' THEN 'RADIO JP CURITIBA / SERIE ' +F2_SERIE 
           WHEN '012002' THEN 'RADIO JP PG / SERIE ' +F2_SERIE 
           WHEN '012101' THEN 'RADIO JP MARINGA / SERIE ' +F2_SERIE 
           WHEN '012301' THEN 'RADIO JP FOZ / SERIE ' +F2_SERIE 
           WHEN '011501' THEN 'RICMAIS PR / SERIE ' +F2_SERIE 
           WHEN '022101' THEN 'TV FLORIANOPOLIS / SERIE ' +F2_SERIE 
           WHEN '022201' THEN 'TV CHAPECO / SERIE ' +F2_SERIE 
           WHEN '022301' THEN 'TV JOINVILE / SERIE ' +F2_SERIE 
           WHEN '022401' THEN 'TV BLUMENAU / SERIE ' +F2_SERIE 
           WHEN '022501' THEN 'TV ITAJAI / SERIE ' +F2_SERIE 
           WHEN '022601' THEN 'TV XANXERE / SERIE ' +F2_SERIE 
           WHEN '022701' THEN 'RERCORD NEWS / SERIE ' +F2_SERIE 
           WHEN '022802' THEN 'JORNAL MATRIZ / SERIE ' +F2_SERIE 
           WHEN '022808' THEN 'JORNAL JOINVILE / SERIE ' +F2_SERIE 
           WHEN '023101' THEN 'SC MAIS INTERNET / SERIE ' +F2_SERIE 
           WHEN '023301' THEN 'EDITORA MAIS SC / SERIE ' +F2_SERIE 
	ELSE SF2.F2_FILIAL
	END) FILIAL, SUBSTRING(SF2.F2_EMISSAO,1,4) ANO,F2_FILIAL,F2_SERIE,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN '01' THEN (CASE WHEN (SF2.F2_FILIAL IN ('022802','023301')) THEN SF2.F2_VALBRUT ELSE (CASE WHEN (SF2.F2_FILIAL NOT IN ('023301') AND SF2.F2_SERIE <>'1  ' ) THEN SF2.F2_VALBRUT ELSE 0 END)	END) ELSE 0 END)) JAN,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN '02' THEN (CASE WHEN (SF2.F2_FILIAL IN ('022802','023301')) THEN SF2.F2_VALBRUT ELSE (CASE WHEN (SF2.F2_FILIAL NOT IN ('023301') AND SF2.F2_SERIE <>'1  ' ) THEN SF2.F2_VALBRUT ELSE 0 END)	END) ELSE 0 END)) FEV,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN '03' THEN (CASE WHEN (SF2.F2_FILIAL IN ('022802','023301')) THEN SF2.F2_VALBRUT ELSE (CASE WHEN (SF2.F2_FILIAL NOT IN ('023301') AND SF2.F2_SERIE <>'1  ' ) THEN SF2.F2_VALBRUT ELSE 0 END)	END) ELSE 0 END)) MAR,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN '04' THEN (CASE WHEN (SF2.F2_FILIAL IN ('022802','023301')) THEN SF2.F2_VALBRUT ELSE (CASE WHEN (SF2.F2_FILIAL NOT IN ('023301') AND SF2.F2_SERIE <>'1  ' ) THEN SF2.F2_VALBRUT ELSE 0 END)	END) ELSE 0 END)) ABR,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN '05' THEN (CASE WHEN (SF2.F2_FILIAL IN ('022802','023301')) THEN SF2.F2_VALBRUT ELSE (CASE WHEN (SF2.F2_FILIAL NOT IN ('023301') AND SF2.F2_SERIE <>'1  ' ) THEN SF2.F2_VALBRUT ELSE 0 END)	END) ELSE 0 END)) MAI,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN '06' THEN (CASE WHEN (SF2.F2_FILIAL IN ('022802','023301')) THEN SF2.F2_VALBRUT ELSE (CASE WHEN (SF2.F2_FILIAL NOT IN ('023301') AND SF2.F2_SERIE <>'1  ' ) THEN SF2.F2_VALBRUT ELSE 0 END)	END) ELSE 0 END)) JUN,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN '07' THEN (CASE WHEN (SF2.F2_FILIAL IN ('022802','023301')) THEN SF2.F2_VALBRUT ELSE (CASE WHEN (SF2.F2_FILIAL NOT IN ('023301') AND SF2.F2_SERIE <>'1  ' ) THEN SF2.F2_VALBRUT ELSE 0 END)	END) ELSE 0 END)) JUL,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN '08' THEN (CASE WHEN (SF2.F2_FILIAL IN ('022802','023301')) THEN SF2.F2_VALBRUT ELSE (CASE WHEN (SF2.F2_FILIAL NOT IN ('023301') AND SF2.F2_SERIE <>'1  ' ) THEN SF2.F2_VALBRUT ELSE 0 END)	END) ELSE 0 END)) AGO,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN '09' THEN (CASE WHEN (SF2.F2_FILIAL IN ('022802','023301')) THEN SF2.F2_VALBRUT ELSE (CASE WHEN (SF2.F2_FILIAL NOT IN ('023301') AND SF2.F2_SERIE <>'1  ' ) THEN SF2.F2_VALBRUT ELSE 0 END)	END) ELSE 0 END)) SETEMBRO,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN '10' THEN (CASE WHEN (SF2.F2_FILIAL IN ('022802','023301')) THEN SF2.F2_VALBRUT ELSE (CASE WHEN (SF2.F2_FILIAL NOT IN ('023301') AND SF2.F2_SERIE <>'1  ' ) THEN SF2.F2_VALBRUT ELSE 0 END)	END) ELSE 0 END)) OUTUBRO,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN '11' THEN (CASE WHEN (SF2.F2_FILIAL IN ('022802','023301')) THEN SF2.F2_VALBRUT ELSE (CASE WHEN (SF2.F2_FILIAL NOT IN ('023301') AND SF2.F2_SERIE <>'1  ' ) THEN SF2.F2_VALBRUT ELSE 0 END)	END) ELSE 0 END)) NOV,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN '12' THEN (CASE WHEN (SF2.F2_FILIAL IN ('022802','023301')) THEN SF2.F2_VALBRUT ELSE (CASE WHEN (SF2.F2_FILIAL NOT IN ('023301') AND SF2.F2_SERIE <>'1  ' ) THEN SF2.F2_VALBRUT ELSE 0 END)	END) ELSE 0 END)) DEZ,		

	(CASE 
	WHEN (SF2.F2_FILIAL IN ('022802' ,'023301'))
	THEN SUM(SF2.F2_VALBRUT)
ELSE (
CASE
	WHEN (SF2.F2_FILIAL NOT IN ('023301') AND SF2.F2_SERIE <>'1  ' )
	THEN SUM(SF2.F2_VALBRUT) 
ELSE 0
END)
END) TOTAL

  
	FROM %table:SF2% SF2	
	INNER JOIN %table:SD2% SD2 ON
	   D2_FILIAL = F2_FILIAL
	   AND D2_DOC = F2_DOC 
	   AND D2_CLIENTE = F2_CLIENTE
	   AND D2_LOJA = F2_LOJA
	   AND D2_SERIE = F2_SERIE	 
	   AND D2_CF <> '5949'  
	   AND EXISTS (SELECT F4_CODIGO FROM %table:SF4% WHERE F4_CODIGO = D2_TES AND F4_DUPLIC = 'S' AND D_E_L_E_T_ = '') 
	   AND D2_ITEM = '01'
	   AND SD2.%NotDel%
	WHERE	SF2.F2_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
	AND SF2.F2_FILIAL NOT IN %Exp:cJPCas%
	AND SF2.F2_FILIAL NOT IN %Exp:cParadise% 
	AND SF2.F2_FILIAL NOT IN %Exp:cTopView%
	AND SF2.F2_EMISSAO  BETWEEN %Exp:cDataDe% AND %Exp:cDataAte%
	AND SF2.F2_SERIE BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
	AND SF2.F2_TIPO <> %Exp:cTipoDev%				
	AND SF2.%NotDel%
	AND SF2.F2_SERIE <> %Exp:'2  '%  
	AND SF2.F2_FILIAL <> '023001'

	GROUP BY SUBSTRING(SF2.F2_EMISSAO,1,4), SF2.F2_FILIAL, SF2.F2_SERIE	

	//Tratamento para agrupar Jovem Pan Cascavel + Jovem Pam Foz Filial

	UNION ALL

	SELECT 'RADIO JP CASCAVEL' FILIAL, SUBSTRING(SF2.F2_EMISSAO,1,4) ANO,F2_FILIAL,F2_SERIE,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cJan% THEN SF2.F2_VALBRUT ELSE 0 END)) JAN,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cFev% THEN SF2.F2_VALBRUT ELSE 0 END)) FEV,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cMar% THEN SF2.F2_VALBRUT ELSE 0 END)) MAR,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cAbr% THEN SF2.F2_VALBRUT ELSE 0 END)) ABR,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cMai% THEN SF2.F2_VALBRUT ELSE 0 END)) MAI,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cJun% THEN SF2.F2_VALBRUT ELSE 0 END)) JUN,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cJul% THEN SF2.F2_VALBRUT ELSE 0 END)) JUL,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cAgo% THEN SF2.F2_VALBRUT ELSE 0 END)) AGO,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cSet% THEN SF2.F2_VALBRUT ELSE 0 END)) SETEMBRO,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cOut% THEN SF2.F2_VALBRUT ELSE 0 END)) OUTUBRO,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cNov% THEN SF2.F2_VALBRUT ELSE 0 END)) NOV,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cDez% THEN SF2.F2_VALBRUT ELSE 0 END)) DEZ,		
	SUM(SF2.F2_VALBRUT) TOTAL


	FROM %table:SF2% SF2	
	INNER JOIN %table:SD2% SD2 ON
	   D2_FILIAL = F2_FILIAL
	   AND D2_DOC = F2_DOC 
	   AND D2_CLIENTE = F2_CLIENTE
	   AND D2_LOJA = F2_LOJA
	   AND D2_SERIE = F2_SERIE
	   AND D2_CF <> '5949'
	   AND EXISTS (SELECT F4_CODIGO FROM %table:SF4% WHERE F4_CODIGO = D2_TES AND F4_DUPLIC = 'S' AND D_E_L_E_T_ = '') 
	   AND D2_ITEM = '01'
	   AND SD2.%NotDel%
	WHERE	SF2.F2_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
	AND SF2.F2_FILIAL IN %Exp:cJPCas% 
	AND SF2.F2_EMISSAO  BETWEEN %Exp:cDataDe% AND %Exp:cDataAte%
	AND SF2.F2_SERIE BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
	AND SF2.F2_TIPO <> %Exp:cTipoDev%				
	AND SF2.%NotDel%				
	AND SF2.F2_SERIE <> %Exp:'2  '%

	GROUP BY SUBSTRING(SF2.F2_EMISSAO,1,4),F2_FILIAL,F2_SERIE

	//Tratamento para agrupar Dance Paradise + DP Movie

	UNION ALL

	SELECT 'DANCE PARADISE' FILIAL, SUBSTRING(SF2.F2_EMISSAO,1,4) ANO,F2_FILIAL,F2_SERIE,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cJan% THEN SF2.F2_VALBRUT ELSE 0 END)) JAN,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cFev% THEN SF2.F2_VALBRUT ELSE 0 END)) FEV,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cMar% THEN SF2.F2_VALBRUT ELSE 0 END)) MAR,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cAbr% THEN SF2.F2_VALBRUT ELSE 0 END)) ABR,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cMai% THEN SF2.F2_VALBRUT ELSE 0 END)) MAI,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cJun% THEN SF2.F2_VALBRUT ELSE 0 END)) JUN,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cJul% THEN SF2.F2_VALBRUT ELSE 0 END)) JUL,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cAgo% THEN SF2.F2_VALBRUT ELSE 0 END)) AGO,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cSet% THEN SF2.F2_VALBRUT ELSE 0 END)) SETEMBRO,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cOut% THEN SF2.F2_VALBRUT ELSE 0 END)) OUTUBRO,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cNov% THEN SF2.F2_VALBRUT ELSE 0 END)) NOV,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cDez% THEN SF2.F2_VALBRUT ELSE 0 END)) DEZ,		
	SUM(SF2.F2_VALBRUT) TOTAL

	FROM %table:SF2% SF2	
	INNER JOIN %table:SD2% SD2 ON
	   D2_FILIAL = F2_FILIAL
	   AND D2_DOC = F2_DOC 
	   AND D2_CLIENTE = F2_CLIENTE
	   AND D2_LOJA = F2_LOJA
	   AND D2_SERIE = F2_SERIE
	   AND D2_CF <> '5949'
	   AND EXISTS (SELECT F4_CODIGO FROM %table:SF4% WHERE F4_CODIGO = D2_TES AND F4_DUPLIC = 'S' AND D_E_L_E_T_ = '') 
	   AND D2_ITEM = '01'
	   AND SD2.%NotDel%
	WHERE	SF2.F2_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
	AND SF2.F2_FILIAL IN %Exp:cParadise% 
	AND SF2.F2_EMISSAO  BETWEEN %Exp:cDataDe% AND %Exp:cDataAte%
	AND SF2.F2_SERIE BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
	AND SF2.F2_TIPO <> %Exp:cTipoDev%				
	AND SF2.%NotDel%				
	AND SF2.F2_SERIE <> %Exp:'2  '%

	GROUP BY SUBSTRING(SF2.F2_EMISSAO,1,4),F2_FILIAL,F2_SERIE

	//Tratamento para agrupar View Editores + Artigos de Luxo

	UNION ALL

	SELECT 'TOP VIEW' FILIAL, SUBSTRING(SF2.F2_EMISSAO,1,4) ANO,F2_FILIAL,F2_SERIE,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cJan% THEN %Exp:cVBrutView% ELSE 0 END)) JAN,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cFev% THEN %Exp:cVBrutView% ELSE 0 END)) FEV,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cMar% THEN %Exp:cVBrutView% ELSE 0 END)) MAR,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cAbr% THEN %Exp:cVBrutView% ELSE 0 END)) ABR,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cMai% THEN %Exp:cVBrutView% ELSE 0 END)) MAI,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cJun% THEN %Exp:cVBrutView% ELSE 0 END)) JUN,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cJul% THEN %Exp:cVBrutView% ELSE 0 END)) JUL,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cAgo% THEN %Exp:cVBrutView% ELSE 0 END)) AGO,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cSet% THEN %Exp:cVBrutView% ELSE 0 END)) SETEMBRO,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cOut% THEN %Exp:cVBrutView% ELSE 0 END)) OUTUBRO,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cNov% THEN %Exp:cVBrutView% ELSE 0 END)) NOV,
	SUM((CASE SUBSTRING(SF2.F2_EMISSAO,5,2) WHEN %Exp:cDez% THEN %Exp:cVBrutView% ELSE 0 END)) DEZ,		
	SUM(%Exp:cVBrutView%) TOTAL

	FROM %table:SF2% SF2, %table:SD2% SD2, %table:SF4% SF4	

	WHERE	SF2.F2_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
	AND SF2.F2_FILIAL IN %Exp:cTopView% 
	AND SF2.F2_EMISSAO  BETWEEN %Exp:cDataDe% AND %Exp:cDataAte%
	AND SF2.F2_SERIE BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
	AND SF2.F2_TIPO <> %Exp:cTipoDev%				
	AND SF2.%NotDel%				
	AND SF2.F2_SERIE <> %Exp:'2  '%				
	AND SD2.D2_FILIAL  = SF2.F2_FILIAL
	AND SD2.D2_DOC     = SF2.F2_DOC
	AND SD2.D2_SERIE   = SF2.F2_SERIE
	AND SD2.D2_CLIENTE = SF2.F2_CLIENTE
	AND SD2.D2_LOJA    = SF2.F2_LOJA
	AND SD2.D2_CF <> '5949'
	AND SD2.%NotDel%

	AND SF4.F4_FILIAL = %xFilial:SF4%
	AND SF4.F4_CODIGO = SD2.D2_TES
	AND SF4.F4_DUPLIC = %Exp:'S'%
	AND SF4.%NotDel%				


	GROUP BY Substring(SF2.F2_EMISSAO,1,4), SF2.F2_SERIE,F2_FILIAL	
        ) ASD

    ORDER BY ANO ASC, FILIAL ASC

	EndSql

	//Pega as informações da última query
	aQuery := GetLastQuery()

Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX1
Cria as perguntas do programa

@author Thiago Henrique dos Santos
@since 05/02/2015
@version P11		

@return nil, sem retorno

/*/
//-------------------------------------------------------------------------------
Static Function AjustaSX1(cPerg)

	Local aHelpPerg  := {}

	aAdd(aHelpPerg,{"Informe a filial inicial."})
	aAdd(aHelpPerg,{"Informe a filial final."})
	aAdd(aHelpPerg,{"Informe o ano inicial."})
	aAdd(aHelpPerg,{"Informe o ano final."})
	aAdd(aHelpPerg,{"Informe a série inicial das notas fiscais"})
	aAdd(aHelpPerg,{"Informe a série final das notas fiscais"})
	aAdd(aHelpPerg,{"Informe o código de cfpo para desconsiderar no relatório"})

	PutSX1(cPerg,"01","Da Filial?"  ,"" ,"" ,"MV_CH1" ,"C",TamSx3("E1_FILIAL")[1],0,0,"G","","SM0" ,"033" ,"S","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPerg[1] ,{},{})
	PutSX1(cPerg,"02","Até Filial?" ,"" ,"" ,"MV_CH1" ,"C",TamSx3("E1_FILIAL")[1],0,0,"G","","SM0" ,"033" ,"S","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPerg[2] ,{},{})
	PutSX1(cPerg,"03","De Ano?"     ,"" ,"" ,"MV_CH3" ,"N",4,0,0,"G","","","","S","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPerg[3] ,{},{})
	PutSX1(cPerg,"04","Até Ano?"    ,"" ,"" ,"MV_CH4" ,"N",4,0,0,"G","","","","S","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPerg[4] ,{},{})
	PutSX1(cPerg,"05","De Série"   	,"" ,"" ,"MV_CH5" ,"C",TamSx3("F2_SERIE")[1],0,0,"G","","" ,"" ,"S","MV_PAR05","","","","","","","","","","","","","","","","",aHelpPerg[5] ,{},{})
	PutSX1(cPerg,"06","Até Série"   ,"" ,"" ,"MV_CH6" ,"C",TamSx3("F2_SERIE")[1],0,0,"G","","" ,"" ,"S","MV_PAR06","","","","","","","","","","","","","","","","",aHelpPerg[6] ,{},{})
	PutSX1(cPerg,"07","Desconsiderar CFO"   ,"" ,"" ,"MV_CH7" ,"C",16,0,0,"G","","" ,"" ,"S","MV_PAR07","","","","","","","","","","","","","","","","",aHelpPerg[6] ,{},{})

Return

