#Include 'Protheus.ch'
#include "Topconn.ch"

User Function HYUR002()

	Local	oReport   := Nil
	Private cPerg     := Padr("HYUR002", 10)

	Pergunte(cPerg, .F.)

	oReport := RPTStruc(cPerg)
	oReport:PrintDialog()

Return

Static Function RPTPrint(oReport)

	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local cNumCod   := ""

    //Verifica se a tabela já está aberta
	If Select ("TMP") <> 0
		DbSelectArea("TMP")
		DbCloseArea()
	EndIF

	BeginSQL Alias "TMP"

    SELECT 
        SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, 
		SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_EMISSAO, SE1.E1_VENCREA, SE1.E1_BAIXA, SE1.E1_VALOR , SE1.E1_PIS, SE1.E1_CSLL, SE1.E1_COFINS
    FROM 
        %Table:SA1% SA1
		INNER JOIN SE1990 SE1 ON 
		SE1.D_E_L_E_T_ = '' AND 
		SE1.E1_TIPO = 'NF' AND 
		SE1.E1_PIS >= 0.01 AND
		SE1.E1_CLIENTE = A1_COD AND  
		SE1.E1_BAIXA BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
    WHERE
		SA1.D_E_L_E_T_ = ''
        ORDER BY E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO

	EndSql

	DbSelectArea("TMP")
	TMP->(dbGoTop())

	oReport:SetMeter(TMP->(LastRec()))

	While !EOF()
		If oReport:Cancel()
			Exit
		EndIF
		// Iniciando a primeira seção
		oSection1:Init()
		oReport:IncMeter()

		cNumcod := TMP->A1_COD
		IncProc("Imprimindo Cliente " + Alltrim(TMP->A1_COD))

		// Imprimindo a primeira seção
		oSection1:Cell("A1_NOME"):SetValue(TMP->A1_NOME)
		oSection1:Cell("A1_COD"):SetValue(TMP->A1_COD)
		oSection1:Cell("A1_LOJA"):SetValue(TMP->A1_LOJA)
		oSection1:PrintLine()

		// Iniciando a segunda seção
		oSection2:Init()

		// Verifica se o código do cliente é o mesmo, se sim, imprime o dados do pedido

		While TMP->A1_COD == cNumCod
			oReport:IncMeter()

			IncProc("Imprimindo títulos " + Alltrim(TMP->E1_NUM))

			oSection2:Cell("E1_PREFIXO"):SetValue(TMP->E1_PREFIXO)
			oSection2:Cell("E1_NUM"):SetValue(TMP->E1_NUM)
			oSection2:Cell("E1_PARCELA"):SetValue(TMP->E1_PARCELA)
			oSection2:Cell("E1_TIPO"):SetValue(TMP->E1_TIPO)
            oSection2:Cell("E1_EMISSAO"):SetValue(DToc (Stod (TMP->E1_EMISSAO)))
			oSection2:Cell("E1_VENCREA"):SetValue(DToc (Stod (TMP->E1_VENCREA)))
			oSection2:Cell("E1_BAIXA"):SetValue(DToc (Stod (TMP->E1_BAIXA)))
			oSection2:Cell("E1_VALOR"):SetValue(TMP->E1_VALOR)
			oSection2:Cell("E1_PIS"):SetValue(TMP->E1_PIS)
			oSection2:Cell("E1_CSLL"):SetValue(TMP->E1_CSLL)
			oSection2:Cell("E1_COFINS"):SetValue(TMP->E1_COFINS)
			oSection2:PrintLine()

			TMP->(dbSkip())

		endDo

		oSection2:FInish()
		oReport:ThinLine()

		oSection1:FInish()

	EndDo
    
    TMP->(dbCloseArea())

Return

Static Function RPTStruc(cPerg)

	Local oReport	:= NIL
	Local oSection1 := NIL
	Local oSection2 := NIL
	Local cDesc 	:= "Relatório de títulos por cliente"

	oReport := Treport():New("HYUR002", "Relatório de títulos por cliente", cPerg, {|oReport| RPTPrint(oReport)}, cDesc)

	//Defininindo a orientação como retrato
	oReport:SetPortrait()

	oSection1 := TRSection():New(oReport, "Clientes", {"SA1"}, NIL, .F., .T.)

	//TRCell():New( <oParent> , <cName> , <cAlias> , <cTitle> , <cPicture> , <nSize> , <lPixel> , <bBlock> , <cAlign> , <lLineBreak> , <cHeaderAlign> , <lCellBreak> , <nColSpace> , <lAutoSize> , <nClrBack> , <nClrFore> , <lBold> ) ?
	TRCell():New(oSection1, "A1_NOME",		"TMP",  "Nome Cliente",	PesqPict("SA1","A1_NOME"),	TamSx3("A1_NOME")[1])
	TRCell():New(oSection1, "A1_COD",       "TMP",  "Código",		PesqPict("SA1","A1_COD"),	TamSx3("A1_COD")[1])
	TRCell():New(oSection1, "A1_LOJA",      "TMP",  "Loja",			PesqPict("SA1","A1_LOJA"),	TamSx3("A1_LOJA")[1])

	oSection2 := TRSection():New(oReport, "Títulos", {"SE1"}, NIL, .F., .T.)

	TRCell():New(oSection2, "E1_PREFIXO",	"TMP",  "Prefixo",			PesqPict("SE1","E1_PREFIXO"),	TamSx3("E1_PREFIXO")[1])
	TRCell():New(oSection2, "E1_NUM",		"TMP",  "Numero",			PesqPict("SE1","E1_NUM"),		TamSx3("E1_NUM")[1])
	TRCell():New(oSection2, "E1_PARCELA",	"TMP",  "Parcela",			PesqPict("SE1","E1_PARCELA"),	TamSx3("E1_PARCELA")[1])
    TRCell():New(oSection2, "E1_TIPO",		"TMP",  "Tipo",				PesqPict("SE1","E1_TIPO"),		TamSx3("E1_TIPO")[1])
	TRCell():New(oSection2, "E1_EMISSAO",	"TMP",  "Dt. Emissão",		PesqPict("SE1","E1_EMISSAO"),	TamSx3("E1_EMISSAO")[1])
	TRCell():New(oSection2, "E1_VENCREA",	"TMP",  "Dt. Vencimento",	PesqPict("SE1","E1_VENCREA"),	TamSx3("E1_VENCREA")[1])
	TRCell():New(oSection2, "E1_BAIXA",		"TMP",  "Dt. Baixa",		PesqPict("SE1","E1_BAIXA"),		TamSx3("E1_BAIXA")[1])
	TRCell():New(oSection2, "E1_VALOR",		"TMP",  "Valor",			PesqPict("SE1","E1_VALOR"),		TamSx3("E1_VALOR")[1])
	TRCell():New(oSection2, "E1_PIS",		"TMP",  "Pis",				PesqPict("SE1","E1_PIS"),		TamSx3("E1_PIS")[1])
	TRCell():New(oSection2, "E1_CSLL",		"TMP",  "CSLL",				PesqPict("SE1","E1_CSLL"),		TamSx3("E1_CSLL")[1])
	TRCell():New(oSection2, "E1_COFINS",	"TMP",  "COFINS",			PesqPict("SE1","E1_COFINS"),	TamSx3("E1_COFINS")[1])

	oSection1:SetPageBreak(.F.) //Quebra de Seção

Return (oReport)
