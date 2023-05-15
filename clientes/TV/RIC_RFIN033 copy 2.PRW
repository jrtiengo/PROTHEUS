#Include 'Protheus.ch'
#include "Topconn.ch"

 /*/{Protheus.doc} RFIN033
Relatório de faturamento, valor bruto, devoluções e liquido.
@type  Function
@author Tiengo
@since 02/03/2023
@version
@see https://tdn.totvs.com/pages/releaseview.action?pageId=415715475
/*/

User Function RFIN033()

	Local oReport   := Nil
	Local cPerg     := Padr("RFIN033", 10)

	Pergunte(cPerg, .F.)

	oReport := RPTStruc(cPerg)
	oReport:PrintDialog()

Return

Static Function RPTPrint(oReport)

	Local oSection1  := oReport:Section(1)
	Local oSection2  := oReport:Section(2)
	Local cAlias	 := GetNextAlias()
	Local cDataDe    := PadL(cValToChar(MV_PAR03),4)+"01"+"01"
	Local cDataAte   := PadL(cValToChar(MV_PAR03),4)+"12"+"31"
	Local _aFil 	 := {}
	Local _aParam 	 := {}
	Local _nValSoma1 := 0
	Local _nValSoma2 := 0
	Local _nValSoma3 := 0
	Local nCount	 := 0
	Local _aFilAux	 := {}

	//Verifica se a tabela já está aberta
	If Select (cAlias) <> 0
		DbSelectArea(cAlias)
		DbCloseArea()
	EndIF

	BeginSql Alias "TMPF2"
		SELECT DISTINCT(F2_FILIAL)
			FROM %table:SF2% F2
				WHERE 
				F2_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
	EndSql

	//Pega as informações da última query
	aQuery1 := GetLastQuery()

	DbSelectArea("TMPF2")
	Do While !EOF()

		aadd(_aFilAux, TMPF2->F2_FILIAL)

		("TMPF2")->(dbSkip())
	EndDo

	("TMPF2")->(dbCloseArea())

	For nCount := 1 to len(_aFilAux)

		If _aFilAux[nCount] ==  "022802"

			BeginSql Alias cAlias

			SELECT FILIAL , MES , SUM(VLRBRUTO) AS VLRBRUTO, SUM(ANULACOES) ANULACOES ,SUM(VLRBRUTO-ANULACOES) AS VLRLIQ 
				FROM 
			(SELECT F2_FILIAL AS FILIAL, SUBSTRING(F2_EMISSAO ,1,6) AS MES, SUM(F2_VALBRUT) AS VLRBRUTO, 0 AS ANULACOES, 0 AS VLRLIQ 
				FROM %table:SF2% F2
					INNER JOIN %table:SD2% SD2 ON 
					D2_FILIAL = F2_FILIAL 
					AND D2_DOC = F2_DOC 
					AND D2_CLIENTE = F2_CLIENTE 
					AND D2_LOJA = F2_LOJA 
					AND D2_SERIE = F2_SERIE 
					AND D2_CF <> '5949 ' 
					AND D2_ITEM = '01' 
					AND SD2.D_E_L_E_T_= ' ' 
				WHERE 
					F2_EMISSAO BETWEEN %Exp:cDataDe% AND %Exp:cDataAte%
					AND F2_FILIAL = %Exp:_aFilAux[nCount]% 
					AND F2.%NotDel%
			GROUP BY  SUBSTRING(F2_EMISSAO ,1,6), F2_FILIAL

			UNION ALL

			SELECT D1_FILIAL AS FILIAL, SUBSTRING(D1_EMISSAO ,1,6) AS MES, 0 AS VLRBRUTO, SUM(D1_TOTAL) AS ANULACOES, 0 AS VLRLIQ 
				FROM %table:SD1% D1
				WHERE 
					D1_CF IN ('1201', '1202', '1205', '2201', '2205') 
					AND D1_EMISSAO BETWEEN %Exp:cDataDe% AND %Exp:cDataAte%
					AND D1_FILIAL = %Exp:_aFilAux[nCount]% 
					AND D1.%NotDel%
			GROUP BY  SUBSTRING(D1_EMISSAO ,1,6), D1_FILIAL )AS TRB 
			GROUP BY MES, FILIAL
			EndSql

		ELSE

			BeginSql Alias cAlias

			SELECT FILIAL , MES , SUM(VLRBRUTO) AS VLRBRUTO, SUM(ANULACOES) ANULACOES ,SUM(VLRBRUTO-ANULACOES) AS VLRLIQ 
				FROM 
			(SELECT F2_FILIAL AS FILIAL, SUBSTRING(F2_EMISSAO ,1,6) AS MES, SUM(F2_VALBRUT) AS VLRBRUTO, 0 AS ANULACOES, 0 AS VLRLIQ 
				FROM %table:SF2% F2
				WHERE 
					F2_SERIE = 'U' 
					AND F2_EMISSAO BETWEEN %Exp:cDataDe% AND %Exp:cDataAte%
					AND F2_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
					//AND F2_FILIAL = %Exp:_aFilAux[nCount]% 
					AND F2.%NotDel%
			GROUP BY  SUBSTRING(F2_EMISSAO ,1,6), F2_FILIAL

			UNION ALL

			SELECT D1_FILIAL AS FILIAL, SUBSTRING(D1_EMISSAO ,1,6) AS MES, 0 AS VLRBRUTO, SUM(D1_TOTAL) AS ANULACOES, 0 AS VLRLIQ 
				FROM %table:SD1% D1
				WHERE 
					D1_CF IN ('1201', '1202', '1205', '2201', '2205') 
					AND D1_EMISSAO BETWEEN %Exp:cDataDe% AND %Exp:cDataAte%
					AND F2_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
					AND D1.%NotDel%
			GROUP BY  SUBSTRING(D1_EMISSAO ,1,6), D1_FILIAL )AS TRB 
			GROUP BY MES, FILIAL
			EndSql

		EndIf

	Next

	//Pega as informações da última query
	aQuery2 := GetLastQuery()

	DbSelectArea(cAlias)
	(cAlias)->(dbGoTop())

	oReport:SetMeter((cAlias)->(LastRec()))

	While !EOF()
		If oReport:Cancel()
			Exit
		EndIF
		// Iniciando a primeira seção
		oSection1:Init()
		oReport:IncMeter()

		cNumFil := ((cAlias)->FILIAL)
		IncProc("Imprimindo Filial " + Alltrim((cAlias)->FILIAL))
		_aParam 	 := {"M0_FILIAL","M0_CGC"}
		_aFil 	     := FWSM0Util():GetSM0Data(, cNumFil, _aParam)

		// Imprimindo a primeira seção
		oSection1:Cell("FILIAL"):SetValue(Alltrim(_aFil[1][2]) + " - CGC: " + Transform(_aFil[2][2],"@R 99.999.999/9999-99"))
		oSection1:PrintLine()

		// Iniciando a segunda seção
		oSection2:Init()

		// Enquanto existir dados na tabela ele imprimi
		While ((cAlias)->FILIAL) == cNumFil
			oReport:IncMeter()

			IncProc("Imprimindo " + Alltrim((cAlias)->FILIAL))
			oSection2:Cell("MES")		:SetValue(MesExtenso(val(Substring((cAlias)->MES,5,2))) + "/" + Substring((cAlias)->MES,1,4))
			oSection2:Cell("VLRBRUTO")  :SetValue((cAlias)->VLRBRUTO)
			oSection2:Cell("ANULACOES") :SetValue((cAlias)->ANULACOES)
			oSection2:Cell("VLRLIQ")    :SetValue((cAlias)->VLRLIQ)
			oSection2:PrintLine()

			_nValSoma1 += (cAlias)->VLRBRUTO
			_nValSoma2 += (cAlias)->ANULACOES
			_nValSoma3 += (cAlias)->VLRLIQ

			(cAlias)->(dbSkip())

		endDo

		oSection1:FInish()
		oSection2:FInish()
		oReport:ThinLine()

	EndDo

	(cAlias)->(dbCloseArea())

Return

Static Function RPTStruc(cNome)

	Local oReport   := NIL
	Local oSection1 := NIL
	Local oSection2 := NIL
	Local oBreak	:= Nil

	oReport := Treport():New(cNome, "Relatório Faturamento Liquido", cNome, {|oReport| RPTPrint(oReport)},;
		"Relatório de Faturamento Bruto e Liquido")

	//Defininindo a orientação como retrato
	oReport:SetPortrait()

	oSection1 := TRSection():New(oReport, "Faturamento Liquido",{"SF2","SA1","SF1"}, NIL, .F., .T.)

	//TRCell():New( <oParent> , <cName> , <cAlias> , <cTitle> , <cPicture> , <nSize> , <lPixel> , <bBlock> , <cAlign> , <lLineBreak> , <cHeaderAlign> , <lCellBreak> , <nColSpace> , <lAutoSize> , <nClrBack> , <nClrFore> , <lBold> ) ?
	TRCell():New(oSection1, "FILIAL",       "cAlias",  "FILIAL",  "@!", 40,,,,,,,,,,,.T.)

	oSection2 := TRSection():New(oReport, "Faturamento", {"SF2","SA1","SF1"}, NIL, .F., .T.)
	TRCell():New(oSection2, "MES",       	"cAlias",  "MES",       "@!", 14,,,,,,,,,,,.T.)
	TRCell():New(oSection2, "VLRBRUTO",     "cAlias",  "VLRBRUTO",  "@E 999,999,999.99", 14,,,,,,,,,,,.F.)
	TRCell():New(oSection2, "ANULACOES",    "cAlias",  "ANULACOES", "@E 999,999,999.99", 14,,,,,,,,,,,.F.)
	TRCell():New(oSection2, "VLRLIQ",    	"cAlias",  "VLRLIQ", 	"@E 999,999,999.99", 14,,,,,,,,,,,.F.)

	oBreak := TRBreak():New(oSection1,".F.","TOTAL: ",.F.)
	oSection1:SetPageBreak(.T.)

	_nValSoma1 := TRFunction():New(oSection2:Cell("VLRBRUTO"),,	 "SUM",	oBreak,,,,.F.,.F.)
	_nValSoma2 := TRFunction():New(oSection2:Cell("ANULACOES"),, "SUM",	oBreak,,,,.F.,.F.)
	_nValSoma3 := TRFunction():New(oSection2:Cell("VLRLIQ"),,	 "SUM",	oBreak,,,,.F.,.F.)

Return (oReport)
