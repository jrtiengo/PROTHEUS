#Include 'Protheus.ch'
#include "Topconn.ch"

User Function TRPT002()

	Local oReport   := Nil
	Local cPerg     := Padr("TRPT002", 10)

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
        SC5.C5_NUM, SA1.A1_COD, SA1.A1_NOME, SC6.C6_QTDVEN, SC6.C6_PRCVEN, SB1.B1_DESC
    FROM 
        %Table:SA1% SA1
        INNER JOIN SC5990 SC5 ON SC5.D_E_L_E_T_ = '' AND SC5.C5_CLIENTE = SA1.A1_COD 
        INNER JOIN SC6990 SC6 ON SC6.D_E_L_E_T_ = '' AND SC6.C6_NUM = SC5.C5_NUM
        INNER JOIN SB1990 SB1 ON SB1.D_E_L_E_T_ = '' AND SB1.B1_COD = SC6.C6_PRODUTO
    WHERE
        SA1.D_E_L_E_T_ = ''
        ORDER BY A1_FILIAL, A1_COD, C5_FILIAL, C5_NUM, C6_FILIAL, C6_ITEM
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
		oSection1:Cell("A1_COD"):SetValue(TMP->A1_COD)
		oSection1:Cell("A1_NOME"):SetValue(TMP->A1_NOME)
		oSection1:PrintLine()

		// Iniciando a segunda seção
		oSection2:Init()

		// Verifica se o código do cliente é o mesmo, se sim, imprime o dados do pedido

		While TMP->A1_COD == cNumCod
			oReport:IncMeter()

			IncProc("Imprimindo Pedidos " + Alltrim(TMP->C5_NUM))
			oSection2:Cell("C5_NUM"):SetValue(TMP->C5_NUM)
			oSection2:Cell("B1_DESC"):SetValue(TMP->B1_DESC)
			oSection2:Cell("C6_QTDVEN"):SetValue(TMP->C6_QTDVEN)
            oSection2:Cell("C6_PRCVEN"):SetValue(TMP->C6_PRCVEN)
			oSection2:PrintLine()

			TMP->(dbSkip())

		endDo

		oSection2:FInish()
		oReport:ThinLine()

		oSection1:FInish()

	EndDo
    
    TMP->(dbCloseArea())

Return

Static Function RPTStruc(cNome)

	Local oReport := NIL
	Local oSection1 := NIL
	Local oSection2 := NIL

	oReport := Treport():New(cNome, "Relatório de pedidos por cliente", cNome, {|oReport| RPTPrint(oReport)},"Descricao do Help")

	//Defininindo a orientação como retrato
	oReport:SetPortrait()

	oSection1 := TRSection():New(oReport, "Clientes", {"SA1"}, NIL, .F., .T.)

	//TRCell():New( <oParent> , <cName> , <cAlias> , <cTitle> , <cPicture> , <nSize> , <lPixel> , <bBlock> , <cAlign> , <lLineBreak> , <cHeaderAlign> , <lCellBreak> , <nColSpace> , <lAutoSize> , <nClrBack> , <nClrFore> , <lBold> ) ?
	TRCell():New(oSection1, "A1_COD",       "TMP",  "CODIGO",  "@!", 40)
	TRCell():New(oSection1, "A1_NOME",      "TMP",  "NOME",    "@!", 200)

	oSection2 := TRSection():New(oReport, "Produtos", {"SB1"}, NIL, .F., .T.)
	TRCell():New(oSection2, "C5_NUM",       "TMP",  "Pedido",      "@!", 30)
	TRCell():New(oSection2, "B1_DESC",      "TMP",  "Descricao",   "@!", 200)
	TRCell():New(oSection2, "C6_QTDVEN",    "TMP",  "Quantidade",  "@E 99999.99", 30)
    TRCell():New(oSection2, "C6_PRCVEN",    "TMP",  "Prec. Venda", "@E 99999.99", 20)

	oSection1:SetPageBreak(.F.) //Quebra de Seção

Return (oReport)
