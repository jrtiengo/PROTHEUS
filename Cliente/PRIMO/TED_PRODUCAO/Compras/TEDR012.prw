#Include 'Protheus.ch'
#include "RWMAKE.ch"
#include "COLORS.CH"
#include "Topconn.ch"


/*/{Protheus.doc} TEDR012
Conferência de notas digitadas.
@author Mauro - Solutio
@since 07/05/2021
@version 6
@return ${return}, ${return_description}
@type function
/*/

User Function TEDR012()

	Private cPerg	:= Padr("TEDR012",10)
	Private oReport	:= Nil

	
	If !Pergunte(cPerg)
		Return()
	EndIf
	

	ReportDef()
	oReport:PrintDialog()

Return


Static Function ReportDef()

	Local oBreak1 	:= Nil
	//Local oBreak2	:= Nil
	//Local oBreak3	:= Nil
	Local oSctD1 	:= Nil
	Local oSctD2 	:= Nil
	Local oSctD3 	:= Nil
	Local oSctD4 	:= Nil

	oReport := TReport():New("TEDR012","Relatório de Conferência de Notas Digitdas.",cPerg,{|oReport| PrintReport(oReport)},"Conferência de Notas Digitdas.")
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	//oReport:SetPortrait()
	oReport:SetLandscape(.T.)

	//Criando a seção de dados
	oSctD1 := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
	"Cabecalho",;		//Descrição da seção
	{"QRY"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSctD1:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha

	//Colunas do relatório
	TRCell():New( oSctD1, "DATAEM"		,,"Emissao:",,11)
	TRCell():New( oSctD1, "UNIDADE"		,,"Unidade:",,30)
	//TRCell():New( oSctD1, "USUARIO"		, "QRY","Usuário:",)

	
	//Criando a seção de dados
	oSctD2 := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
	"DadosNota",;		//Descrição da seção
	{"QRY"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSctD2:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha

	//Colunas do relatório
	TRCell():New( oSctD2, "NOTA"		, "QRY","Nota"			, X3Picture("F1_DOC") 		,TamSX3("F1_DOC")[1] + 2	,,,"LEFT",,"CENTER" )
	TRCell():New( oSctD2, "SERIE"		, "QRY","Serie"			, X3Picture("F1_SERIE") 	,TamSX3("F1_SERIE")[1] + 2	,,,"LEFT",,"CENTER" )
	TRCell():New( oSctD2, "EMISSAO"		, "QRY","Emissao"		, X3Picture("F1_EMISSAO") 	,TamSX3("F1_EMISSAO")[1] + 2,,,"LEFT",,"CENTER" )
	TRCell():New( oSctD2, "DIGITACAO"	, "QRY","Digitacao"		, X3Picture("F1_DTDIGIT") 	,TamSX3("F1_DTDIGIT")[1] + 2,,,"LEFT",,"CENTER" )
	TRCell():New( oSctD2, "FORNECE"		, "QRY","Fornecedor"	, X3Picture("F1_FORNECE") 	,TamSX3("F1_FORNECE")[1] + 2,,,"LEFT",,"CENTER" )
	TRCell():New( oSctD2, "LOJA"		, "QRY","Loja"			, X3Picture("F1_LOJA") 		,TamSX3("F1_LOJA")[1] + 2	,,,"LEFT",,"CENTER" )
    TRCell():New( oSctD2, "RAZAO"		, "QRY","Razao Social"	, X3Picture("A1_NOME") 		,TamSX3("A1_NOME")[1] + 2	,,,"LEFT",,"CENTER" )
	TRCell():New( oSctD2, "VALTOT"		, "QRY","Valor Total NF", X3Picture("D2_TOTAL") 	,TamSX3("D2_TOTAL")[1] + 2	,,,"RIGHT",,"CENTER" )
	
	
	//Criando a seção de dados								
	oSctD3 := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
	"ItensNota",;		//Descrição da seção
	{"QRY1"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSctD3:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha

	TRCell():New( oSctD3, "NOTA"		, "QRY","Nota"				, X3Picture("F1_DOC") 		,TamSX3("F1_DOC")[1] + 2	,,,"LEFT",,"CENTER" )
	TRCell():New( oSctD3, "SERIE"		, "QRY","Serie"				, X3Picture("F1_SERIE") 	,TamSX3("F1_SERIE")[1] + 2	,,,"LEFT",,"CENTER" )
	TRCell():New( oSctD3, "EMISSAO"		, "QRY","Emissao"			, X3Picture("F1_EMISSAO") 	,TamSX3("F1_EMISSAO")[1] + 2,,,"LEFT",,"CENTER" )
	TRCell():New( oSctD3, "DIGITACAO"	, "QRY","Digitacao"			, X3Picture("F1_DTDIGIT") 	,TamSX3("F1_DTDIGIT")[1] + 2,,,"LEFT",,"CENTER" )
	TRCell():New( oSctD3, "FORNECE"		, "QRY","Fornecedor"		, X3Picture("F1_FORNECE") 	,TamSX3("F1_FORNECE")[1] + 2,,,"LEFT",,"CENTER" )
	TRCell():New( oSctD3, "LOJA"		, "QRY","Loja"				, X3Picture("F1_LOJA") 		,TamSX3("F1_LOJA")[1] + 2	,,,"LEFT",,"CENTER" )
    TRCell():New( oSctD3, "RAZAO"		, "QRY","Razao Social"		, X3Picture("A1_NOME") 		,TamSX3("A1_NOME")[1] + 2	,,,"LEFT",,"CENTER" )
	TRCell():New( oSctD3, "PRODUTO"		, "QRY1","Cod.Material"		, X3Picture("B1_COD" )		,TamSX3("B1_COD")[1] + 2	,,,"LEFT",,"CENTER" )
	TRCell():New( oSctD3, "DESCRICAO"	, "QRY1","Descrição"		, X3Picture("B1_DESC")		,TamSX3("B1_DESC")[1] + 2	,,,"LEFT",,"CENTER" )
	TRCell():New( oSctD3, "TES"			, "QRY1","TES"				, X3Picture("D1_TES")		,TamSX3("D1_TES")[1] + 2	,,,"LEFT",,"CENTER" )
	TRCell():New( oSctD3, "CCUSTO"		, "QRY1","Centro Custo"		, X3Picture("D1_CC")		,TamSX3("D1_CC")[1] + 2	,,,"LEFT",,"CENTER" )
	TRCell():New( oSctD3, "CLASSE"		, "QRY1","Clase Valor"		, X3Picture("D1_CLVL")		,TamSX3("D1_CLVL")[1] + 2	,,,"LEFT",,"CENTER" )
	TRCell():New( oSctD3, "CFOP"		, "QRY1","CFOP"				, X3Picture("D1_CF")		,TamSX3("D1_CF")[1] + 2		,,,"LEFT",,"CENTER" )
	TRCell():New( oSctD3, "QUANT"		, "QRY1","Qtde."			, X3Picture("D1_QUANT")		,TamSX3("D1_QUANT")[1] + 2	,,,"RIGHT",,"CENTER" )
	TRCell():New( oSctD3, "VLRUNI"		, "QRY1","Valor Unitário"	, X3Picture("D1_VUNIT")		,TamSX3("D1_VUNIT")[1] + 2 	,,,"RIGHT",,"CENTER" )
	TRCell():New( oSctD3, "VLRTOT"		, "QRY1","Valor Total Item"	, X3Picture("D1_TOTAL") 	,TamSX3("D1_TOTAL")[1] + 2	,,,"RIGHT",,"CENTER" )


	//Criando a seção de dados								
	oSctD4 := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
	"Titulos",;		//Descrição da seção
	{"QRY2"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSctD4:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha

	TRCell():New( oSctD4, "NUMERO"		, "QRY2","Nro.Duplicata"	, X3Picture("E2_NUM" )		,TamSX3("E2_NUM")[1] + 2	,,,"LEFT",,"CENTER" )
	TRCell():New( oSctD4, "PREFIXO"		, "QRY2","Prefixo"			, X3Picture("E2_PREFIXO" )	,TamSX3("E2_PREFIXO")[1] + 2,,,"LEFT",,"CENTER" )
	TRCell():New( oSctD4, "PARCELA"		, "QRY2","Parcela"			, X3Picture("E2_PARCELA")	,TamSX3("E2_PARCELA")[1] + 2,,,"LEFT",,"CENTER" )
	TRCell():New( oSctD4, "EMISSAO"		, "QRY2","Emissão"			, X3Picture("E2_EMISSAO")	,TamSX3("E2_EMISSAO")[1] + 2,,,"LEFT",,"CENTER" )
	TRCell():New( oSctD4, "VENCIMENTO"	, "QRY2","Vencimento"		, X3Picture("E2_VENCTO")	,TamSX3("E2_VENCTO")[1] + 2	,,,"LEFT",,"CENTER" )
	TRCell():New( oSctD4, "NATUREZA"	, "QRY2","Natureza"			, X3Picture("E2_NATUREZ")	,TamSX3("E2_NATUREZ")[1] + 2,,,"LEFT",,"CENTER" )
	TRCell():New( oSctD4, "VALOR"		, "QRY2","Valor Original"	, X3Picture("E2_VALOR")		,TamSX3("E2_VALOR")[1] + 2	,,,"RIGHT",,"CENTER" )
	

	// Definindo a quebra
	oBreak1 := TRBreak():New(oSctD1,{|| QRY->(NOTA) },{|| "Total Nota" })
	oSctD1:SetHeaderBreak(.T.)

	//Definindo a quebra
	//oBreak2 := TRBreak():New(oSctD2,{|| QRY->(NOTA) },{|| "Total Nota" })
	//oSctD2:SetHeaderBreak(.T.)

	//oSctD2:SetHeaderSection(.T.)

	//Definindo a quebra
	//oBreak2 := TRBreak():New(oSctD2,{|| QRY->(NOTA) },{|| "Total Nota" })
	//oSctD2:SetHeaderBreak(.T.)

	//oSctD2:SetHeaderSection(.T.)

	//Totalizadores
	//oFunTot1 := TRFunction():New(oSctD2:Cell("VLRTOT"),,"SUM",oBreak,,PesqPict( "SD2", "D2_TOTAL" ))
	//oFunTot1:SetEndReport(.F.)

Return Nil

Static Function PrintReport(oReport)

	Local cQuery	:= ""
	Local _cNota	:= ""
	Local oSctD1 	:= Nil
	Local oSctD2 	:= Nil
	Local oSctD3 	:= Nil
	Local oSctD4 	:= Nil
	

	cQuery := " SELECT F1_FILIAL AS FILIAL, F1_DOC AS NOTA, F1_SERIE AS SERIE, F1_EMISSAO AS EMISSAO, "
	cQuery += " F1_FORNECE AS FORNECE, F1_LOJA AS LOJA, A2_NOME AS RAZAO, F1_VALMERC AS VALTOT, "
	cQuery += " F1_DUPL AS DUPLICATA, F1_PREFIXO AS PREFIXO, F1_DTDIGIT AS DIGITACAO "
	If !Empty(Alltrim(MV_PAR07))
		cQuery += " ,ISNULL((	SELECT TOP 1 D1_TES "
		cQuery += " 			FROM SD1980 SD1 "
		cQuery += " 			WHERE SD1.D1_FILIAL = SF1.F1_FILIAL "
		cQuery += " 			AND SD1.D1_DOC = SF1.F1_DOC "
		cQuery += " 			AND SD1.D1_SERIE = SF1.F1_SERIE "
		cQuery += " 			AND SD1.D1_FORNECE = SF1.F1_FORNECE "
		cQuery += " 			AND SD1.D1_LOJA = SF1.F1_LOJA "
		cQuery += " 			AND SD1.D_E_L_E_T_ <> '*' "
		cQuery += " 			AND SD1.D1_TES = '"+ MV_PAR07 +"' ),'') TES "
	EndIf
	cQuery += " FROM "+ RETSQLNAME("SF1") +" SF1, "+ RETSQLNAME("SA2") +" SA2 "
	cQuery += " WHERE SF1.F1_FILIAL = '"+ xFilial("SF1") +"' "
	cQuery += " AND SF1.F1_EMISSAO BETWEEN '"+ Dtos(MV_PAR01) +"' AND '"+ Dtos(MV_PAR02) +"' "
	cQuery += " AND SF1.F1_FORNECE BETWEEN '"+ MV_PAR03 +"' AND '"+ MV_PAR04 +"' "
	cQuery += " AND SF1.F1_DTDIGIT BETWEEN '"+ Dtos(MV_PAR05) +"' AND '"+ Dtos(MV_PAR06) +"' "
	cQuery += " AND SA2.A2_COD = SF1.F1_FORNECE "
	cQuery += " AND SA2.A2_LOJA = SF1.F1_LOJA "
	cQuery += " AND SF1.D_E_L_E_T_ <> '*' "
	cQuery += " AND SA2.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY SF1.F1_EMISSAO, SF1.F1_FORNECE + SF1.F1_LOJA, SF1.F1_DOC, SF1.F1_SERIE "


	If Select("QRY") > 0
		Dbselectarea("QRY")
		QRY->(DbClosearea())
	EndIf

	TcQuery cQuery New Alias "QRY"
	TCSetField("QRY", "EMISSAO", "D")
	TCSetField("QRY", "DIGITACAO", "D")

	//Pegando as seções do relatório
	oSctD1 := oReport:Section(1)
	oSctD2 := oReport:Section(2)
	oSctD3 := oReport:Section(3)
	oSctD4 := oReport:Section(4)

	// Define valores da seção.
	oSctD1:Cell("DATAEM"):SetBlock({||DTOC(dDataBase)})
	oSctD1:Cell("UNIDADE"):SetBlock({||FWFilialName(cEmpAnt,cFilAnt,1)})

	//inicializo a primeira seção
	oSctD1:Init()

	//Imprimindo a linha atual
	oSctD1:PrintLine()
	
	QRY->(DbGoTop())
	Do While ! QRY->(EOF())

		If oReport:Cancel()
			Exit
		EndIf
		
		_cNota := QRY->(NOTA)+QRY->(SERIE)

		oSctD2:Init()

		Do While QRY->NOTA+QRY->SERIE == _cNota //QRY->(NOTA) == _cNota

			If !Empty(Alltrim(MV_PAR07))
				If Empty(ALLTRIM(QRY->TES))
					QRY->(DbSkip())
					Loop
				EndIf
			EndIf

			oSctD2:Printline()

			// Itens da nota.
			cQuery := " SELECT "
			cQuery += " D1_DOC AS NOTA, D1_SERIE AS SERIE, D1_EMISSAO AS EMISSAO, SD1.D1_DTDIGIT AS DIGITACAO, D1_FORNECE AS FORNECE, D1_LOJA AS LOJA, SA2.A2_NOME AS RAZAO, "
			cQuery += " B1_COD AS PRODUTO, B1_DESC AS DESCRICAO, D1_TES AS TES,  D1_CLVL AS CLASSE, D1_CC AS CCUSTO, "
			cQuery += " D1_CF AS CFOP, D1_QUANT AS QUANT, D1_VUNIT AS VLRUNI, D1_TOTAL AS VLRTOT, D1_ITEM "
			cQuery += " FROM "+ RETSQLNAME("SD1") +" SD1, "+ RETSQLNAME("SB1") +" SB1 , " + RETSQLNAME("SA2") +" SA2 "
			cQuery += " WHERE SD1.D1_FILIAL = '"+ QRY->FILIAL +"' "
			cQuery += " AND SD1.D1_DOC + SD1.D1_SERIE = '"+ QRY->NOTA+QRY->SERIE +"' "
			cQuery += " AND SD1.D1_FORNECE = '"+ QRY->FORNECE +"' " 
			cQuery += " AND SD1.D1_LOJA = '"+ QRY->LOJA +"' "
			cQuery += " AND SB1.B1_FILIAL = SD1.D1_FILIAL "
			cQuery += " AND SB1.D_E_L_E_T_ <> '*' AND SB1.B1_COD = SD1.D1_COD "
			cQuery += " AND SA2.D_E_L_E_T_  <> '*' AND SA2.A2_COD = SD1.D1_FORNECE AND SA2.A2_LOJA = SD1.D1_LOJA
			cQuery += " AND SD1.D_E_L_E_T_ <> '*' "
			cQuery += " ORDER BY SD1.D1_ITEM "

			If Select("QRY1") > 0
				Dbselectarea("QRY1")
				QRY1->(DbClosearea())
			EndIf

			TcQuery cQuery New Alias "QRY1"
			TCSetField("QRY1", "EMISSAO"	, "D")
			TCSetField("QRY1", "DIGITACAO"	, "D")

			oSctD3:Init()

			QRY1->(DbGoTop())
			Do While ! QRY1->(EOF())

				oSctD3:Printline()
				QRY1->(DbSkip())
			
			EndDo
			oSctD3:Finish()
			QRY1->(DbClosearea())

			// Títulos.
			cQuery := " SELECT E2_NUM AS NUMERO, E2_PREFIXO AS PREFIXO, E2_PARCELA AS PARCELA , E2_EMISSAO AS EMISSAO, "
			cQuery += " E2_VENCTO AS VENCIMENTO, E2_NATUREZ AS NATUREZA, E2_VALOR AS VALOR "
			cQuery += " FROM "+ RETSQLNAME("SE2") +" SE2 "
			cQuery += " WHERE SE2.E2_FILIAL = '"+ QRY->FILIAL +"' "
			cQuery += " AND SE2.E2_NUM = '"+ QRY->DUPLICATA +"' "
			cQuery += " AND SE2.E2_PREFIXO = '"+ QRY->PREFIXO +"' "
			cQuery += " AND SE2.E2_FORNECE = '"+ QRY->FORNECE +"' "
			cQuery += " AND SE2.E2_LOJA = '"+ QRY->LOJA +"' "
			cQuery += " AND SE2.D_E_L_E_T_ <> '*' "
			cQuery += " ORDER BY SE2.E2_PARCELA "

			If Select("QRY2") > 0
				Dbselectarea("QRY2")
				QRY2->(DbClosearea())
			EndIf

			TcQuery cQuery New Alias "QRY2"
			TCSetField("QRY2", "EMISSAO"	, "D")
			TCSetField("QRY2", "VENCIMENTO"	, "D")

			oSctD4:Init()

			QRY2->(DbGoTop())
			Do While ! QRY2->(EOF())

				oSctD4:Printline()
				QRY2->(DbSkip())
			
			EndDo
			oSctD4:Finish()
			QRY2->(DbClosearea())

			QRY->(DbSkip())
			
		EndDo
		oSctD2:Finish()
	EndDo
	
	oSctD1:Finish()
	//oSctD2:Finish()
	//oSctD3:Finish()
	QRY->(DbCloseArea())
	
	

Return Nil
