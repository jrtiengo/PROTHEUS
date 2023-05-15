#Include 'Protheus.ch'
#include "Topconn.ch"

 /*/{Protheus.doc} LIFR012
listagem dos bens (SN1) agrupados por Grupo de Bens (N1_GRUPO) em cada local (N1_LOCAL).
@type  Function
@author Tiengo
@since 24/04/2023
@see https://tdn.totvs.com/pages/releaseview.action?pageId=415715475
/*/

User Function LIFR012()

	Local	oReport   := Nil
	Private cPerg     := Padr("LIFR012", 10)

	Pergunte(cPerg, .F.)

	oReport := RPTStruc(cPerg)
	oReport:PrintDialog()

Return

Static Function RPTPrint(oReport)

	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local cAlias  	:= getNextAlias() 
	Local cLocal   	:= ""

    //Verifica se a tabela já está aberta
	If Select (cAlias) <> 0
		DbSelectArea(cAlias)
		DbCloseArea()
	EndIF

	BeginSQL Alias cAlias

    SELECT		
		SN1.N1_FILIAL AS FILIAL,
		ISNULL(SN1.N1_LOCAL, '') AS LOCBEM,
		ISNULL(SNL.NL_DESCRIC,'') AS DESCRLOC,
		SN1.N1_GRUPO AS GRUPO, 
		ISNULL(SNG.NG_DESCRIC,'') AS DESCRGRUP, 
		SN1.N1_CBASE AS CODBEM,
		SN1.N1_CHAPA AS CHAPA,
		SN1.N1_NUMSERI AS NUMSERIE,
		SN1.N1_PRODUTO AS PRODUTOSN1,
        ISNULL(IIF (SN1.N1_PRODUTO = '', SD1.D1_COD, ''),'') AS PRODUTOSD1
    FROM %table:SN1% SN1
    LEFT JOIN %table:SNG% SNG ON SNG.D_E_L_E_T_ = '' AND  SNG.NG_FILIAL = SN1.N1_FILIAL AND SNG.NG_GRUPO = SN1.N1_GRUPO
    LEFT JOIN %table:SNL% SNL ON SNL.D_E_L_E_T_ = '' AND SNL.NL_CODIGO = N1_LOCAL AND SNL.NL_BLOQ <> '1'  
    LEFT JOIN %table:SD1% SD1 ON SD1.D_E_L_E_T_ = '' AND SD1.D1_DOC = N1_NFISCAL AND  SD1.D1_SERIE = N1_NSERIE AND SD1.D1_FORNECE = N1_FORNEC AND SD1.D1_LOJA = N1_LOJA AND SUBSTRING(SD1.D1_ITEM, 4,1) = N1_ITEM
    WHERE 
	    SN1.N1_BAIXA = '' AND 
	    SN1.N1_LOCAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% AND 
		SN1.N1_GRUPO BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04% AND
	    SN1.D_E_L_E_T_ = ''
    GROUP BY N1_FILIAL, N1_LOCAL, NL_DESCRIC, N1_GRUPO, NG_DESCRIC, N1_CBASE, N1_CHAPA, N1_NUMSERI, N1_PRODUTO, D1_COD
    ORDER BY N1_FILIAL, N1_LOCAL, N1_GRUPO

	EndSql  

    //Pega as informações da última query
	aQuery := GetLastQuery()

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

		cLocal := ((cAlias)->LOCBEM)
		cNumFil := ((cAlias)->FILIAL)

		//Função para trazer o Nome da Filial e CNPJ
		aEmpLIF   := FWArrFilAtu(, cNumFil )
		cCGCLIF := AllTrim( aEmpLIF[SM0_CGC])
		cNomLIF := AllTrim( aEmpLIF[SM0_NOMECOM])
		IncProc("Imprimindo Locais " + Alltrim((cAlias)->LOCBEM))

		// Imprimindo a primeira seção
		oSection1:Cell("LOCBEM"):SetValue((cAlias)->LOCBEM)
        oSection1:Cell("DESCRLOC"):SetValue((cAlias)->DESCRLOC)
		oSection1:Cell("FILIAL"):SetValue(Alltrim(cNomLIF) + " - CGC: " + Transform(cCGCLIF,"@R 99.999.999/9999-99"))
		oSection1:PrintLine()

		// Iniciando a segunda seção
		oSection2:Init()

		// Verifica se o código do cliente é o mesmo, se sim, imprime o dados do pedido

		While ((cAlias)->FILIAL) == cNumFil .and. ((cAlias)->LOCBEM) == cLocal 
			oReport:IncMeter()

			IncProc("Imprimindo Bens " + Alltrim((cAlias)->GRUPO))

			oSection2:Cell("GRUPO"):SetValue((cAlias)->GRUPO)
            oSection2:Cell("DESCRGRUP"):SetValue((cAlias)->DESCRGRUP)
            oSection2:Cell("CODBEM"):SetValue((cAlias)->CODBEM)
            oSection2:Cell("CHAPA"):SetValue((cAlias)->CHAPA)
            oSection2:Cell("NUMSERIE"):SetValue((cAlias)->NUMSERIE)
			//oSection2:Cell("PRODUTOSN1"):SetValue((cAlias)->PRODUTOSN1)

            //Caso não ache o produto na SN1, ele irá buscar o código do produto na SD1.
            IF !EMPTY((cAlias)->PRODUTOSN1)
                oSection2:Cell("PRODUTOSN1"):SetValue((cAlias)->PRODUTOSN1)
            ElseIF !EMPTY((cAlias)->PRODUTOSD1)
                oSection2:Cell("PRODUTOSN1"):SetValue((cAlias)->PRODUTOSD1)
			Else 
				oSection2:Cell("PRODUTOSN1"):SetValue((cAlias)->PRODUTOSN1)
         	EndIF
			
			oSection2:PrintLine()

			(cAlias)->(dbSkip())

		endDo

		oSection2:FInish()
		oReport:ThinLine()

		oSection1:FInish()

	EndDo
    
    (cAlias)->(dbCloseArea())

Return

Static Function RPTStruc(cPerg)

	Local oReport	:= NIL
	Local oSection1 := NIL
	Local oSection2 := NIL
	Local cTitulo   := "Análitico Grupo de Bens"
    Local cHelp     := "Lista os ativos por grupo e local"

	oReport := Treport():New("LIFR012", cTitulo, cPerg, {|oReport|RPTPrint(oReport)}, cHelp)

	//Defininindo a orientação como retrato
	oReport:SetPortrait()

	oSection1 := TRSection():New(oReport, "Local", {"SN1"}, NIL, .F., .T.)

	//TRCell():New( <oParent> , <cName> , <cAlias> , <cTitle> , <cPicture> , <nSize> , <lPixel> , <bBlock> , <cAlign> , <lLineBreak> , <cHeaderAlign> , <lCellBreak> , <nColSpace> , <lAutoSize> , <nClrBack> , <nClrFore> , <lBold> ) ?
	TRCell():New(oSection1, "LOCBEM",   "SN1",  "Local",        	PesqPict("SN1","N1_LOCAL"),     	TamSx3("N1_LOCAL")[1])
	TRCell():New(oSection1, "DESCRLOC", "SNL",  "Descr. Local", 	PesqPict("SNL","NL_DESCRIC"),   	TamSx3("NL_DESCRIC")[1])
	TRCell():New(oSection1, "FILIAL",   "SN1",  "Filial",			PesqPict("SN1","N1_FILIAL"),		100)

	oSection2 := TRSection():New(oReport, "Bens", {"SN1"}, NIL, .F., .T.)	

	TRCell():New(oSection2, "GRUPO",        "SN1",  "Grupo",			PesqPict("SN1","N1_GRUPO"),     TamSx3("N1_GRUPO")[1])
	TRCell():New(oSection2, "DESCRGRUP",	"SNG",  "Descr. Grupo",		PesqPict("SNG","NG_DESCRIC"),	TamSx3("NG_DESCRIC")[1])
	TRCell():New(oSection2, "CODBEM",	    "SN1",  "Cod. Base",		PesqPict("SN1","N1_CBASE"),     TamSx3("N1_CBASE")[1])
    TRCell():New(oSection2, "CHAPA",		"SN1",  "Chapa",			PesqPict("SN1","N1_CHAPA"),		TamSx3("N1_CHAPA")[1])
	TRCell():New(oSection2, "NUMSERIE",     "SN1",  "N Serie",		    PesqPict("SN1","N1_NUMSERI"),	TamSx3("N1_NUMSERI")[1])
	TRCell():New(oSection2, "PRODUTOSN1",   "SN1",  "Produto",			PesqPict("SN1","N1_PRODUTO"), 	16)

	oSection1:SetPageBreak(.T.) //Quebra de Seção

Return (oReport)
