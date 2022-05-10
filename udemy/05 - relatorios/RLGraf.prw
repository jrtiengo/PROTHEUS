#Include 'Protheus.ch'
#Include 'RPTDef.ch'
#Include 'FWPrintSetup.ch'

/*/{Protheus.doc} rlgraf
Relatório com gráfico em advpl
@type function
@author Curso Desenvolvendo relatórios com ADVPL - RCTI Treinamentos
@since 2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see www.rctitreinamentos.com.br
/*/

User Function RLGraf()
	
	 Local aArea       := GetArea()
    Local cNomeRel    := "rel_teste_"+dToS(Date())+StrTran(Time(), ':', '-')
    Local cDiretorio  := GetTempPath()
    Local nLinCab     := 025
    Local nAltur      := 250
    Local nLargur     := 1050
    Local aRand       := {}
    Private cHoraEx    := Time()
    Private nPagAtu    := 1
    Private oPrintRel
    //Variaveis para as fontes utilizada no relatorio
    Private oFontRod   := TFont():New("Arial", , -06, , .F.)
    Private oFontTit   := TFont():New("Arial", , -20, , .T.)
    //Variáveis para linhas e colunas
    Private nLinAtu     := 0
    Private nLinFin     := 830
    Private nColIni     := 010
    Private nColFin     := 510
    Private nColMeio    := (nColFin-nColIni)/2


		Processa({||MntQry() },,"Processando...")
		
		//criando o objeto de impressao
		
		oPrintRel := FWMSPrinter():New(cNomeRel,IMP_PDF,.F.,/**/,.T.,,@oPrintRel,,,,,.T.)
		oPrintRel:cPathPDF := GetTempPath()
		oPrintRel:SetResolution(72)
		oPrintRel:SetPortrait()
		oPrintRel:SetPaperSize(DMPAPER_A4)
		oPrintRel:SetMargin(60,60,60,60)
		oPrintRel:StartPage()
		
		//cabecalho
		oPrintRel:SayAlign(nLinCab,nColMeio-150,"Relatorio grafico em ADVPL", oFontTit,300,20,RGB(0,0,255),2,0)
		nLinCab += 36
		nLinAtu := nLinCab
		
		//verificar se o arquivo está aberto
			If File(cDiretorio + "01grafico.png")
				FErase(cDiretorio + "01grafico.png")
			EndIf
			
			DEFINE MSDIALOG oDlg PIXEL FROM 0,0 TO nAltur,nLargur
			
				oChart := FWChartBar():New
				oChart:Init(oDlg, .T., .T. )
        		oChart:SetTitle("Clientes que mais compraram", CONTROL_ALIGN_CENTER)
        		
        		While TMP->(!EOF())
        			oChart:addSerie(TMP->NOME,TMP->TOTAL)
        			TMP->(dbSkip())
        		 		
        		EndDo
        		
        		//definindo legenda
				oChart:setLegend(CONTROL_ALIGN_LEFT)
				//DEFININDO CORES
		
			aAdd(aRand, {"050,050,255", "002,002,200"})
			aAdd(aRand, {"207,136,077", "020,020,006"})
			aAdd(aRand, {"141,225,078", "017,019,010"})
			aAdd(aRand, {"166,085,082", "017,007,007"})
			aAdd(aRand, {"084,120,164", "007,013,017"})
			
        oChart:oFWChartColor:aRandom := aRand
        oChart:oFWChartColor:SetColor("Random")
			
       	oChart:Build()
			
			ACTIVATE MSDIALOG oDlg CENTERED ON INIT (oChart:SaveToPng(0,0,nLargur,nAltur,cDiretorio+"01grafico.png"), oDlg:End())
		oPrintRel:SayBitmap(nLinAtu,nColIni, cDiretorio +"01grafico.png",nLargur/2, nAltur/1.6)
		nLinAtu += nAltur + 5
		
			RodaPe()
		
		oPrintRel:Preview()
		
		RestArea(aArea)
			
Return

/** Função estática que monta a pesquisa em SQL  **/
Static Function MntQry()

  Local cQuery := " "
               
cQuery += "	SELECT F2_CLIENTE AS CLIENTE, A1_NOME AS NOME, SUM(F2_VALBRUT) TOTAL FROM SF2990 AS SF2 "
cQuery += " INNER JOIN SA1990 AS SA1 ON SF2.F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA AND SA1.D_E_L_E_T_ = ' ' "
cQuery += " WHERE SF2.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY F2_CLIENTE, A1_NOME "

cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), 'TMP', .F., .T.)

Return Nil

/* Função de rodapé ***/

Static Function RodaPe()
		Local nLinha := nLinFin
		Local cTitulo := ""
		
		//linha divisoria
		oPrintRel:Line(nLinha,nColIni,nLinha,nColFin, RGB(0,0,200))
		nLinha += 4
		
		//escrevendo dados contidos no rodapé
		cTitulo := "Relatório de Clientes - "+dToc(dDataBase)+ "  |  "+cHoraEx+"  |  "+cUserName
		oPrintRel:SayAlign(nLinha, nColIni, cTitulo, oFontRod,250,07, ,0,)
		
		//páginação a direita
		cTitulo := "Página "+cValToChar(nPagAtu)
		oPrintRel:SayAlign(nLinha, nColFin, cTitulo, oFontRod, 040,07,,1,)
		
			oPrintRel:EndPage()
			nPagAtu++
Return



