#Include 'Protheus.ch'
#include "Topconn.ch"

 /*/{Protheus.doc} LIFR011
Relatório simples com um resumo por Grupo de Bens (N1_GRUPO) da quantidade de bens (únicos) em cada local (N1_LOCAL) .
@type  Function
@author Tiengo
@since 20/04/2023
@see https://tdn.totvs.com/pages/releaseview.action?pageId=415715475
/*/

User Function LIFR011()

 	Local	oReport   := Nil
    Local cAlias    := getNextAlias() 
	//Private cPerg     := Padr("LIFR011", 10)

	//Pergunte(cPerg, .F.)

	oReport := RPTStruc(cAlias)
	oReport:PrintDialog()

Return

Static Function RPrint(oReport, cAlias)

	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
   
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
                ISNULL(SNG.NG_DESCRIC,'') AS DESCRGRU, 
                SUM(N1_QUANTD) AS QUANTIDADE
            FROM %table:SN1% SN1 
            LEFT JOIN %table:SNG% SNG ON SNG.D_E_L_E_T_ = '' AND SNG.NG_FILIAL = SN1.N1_FILIAL AND SNG.NG_GRUPO = SN1.N1_GRUPO
            LEFT JOIN %table:SNL% SNL ON SNL.D_E_L_E_T_ = '' AND SNL.NL_CODIGO = N1_LOCAL AND SNL.NL_BLOQ <> '1'  
            WHERE 
                SN1.N1_BAIXA = '' AND                
                SN1.D_E_L_E_T_ = ''
            GROUP BY N1_FILIAL, N1_LOCAL, NL_DESCRIC, N1_GRUPO, NG_DESCRIC
            ORDER BY N1_FILIAL, N1_LOCAL, N1_GRUPO
        EndSQL

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

		cNumFil := ((cAlias)->FILIAL)
		IncProc("Imprimindo Filial " + Alltrim((cAlias)->FILIAL))
        
        //Função para trazer o Nome da Filial e CNPJ
        aEmpLIF   := FWArrFilAtu(, cNumFil )
        cCGCLIF := AllTrim( aEmpLIF[SM0_CGC])
        cNomLIF := AllTrim( aEmpLIF[SM0_NOMECOM])
       
        oSection1:Cell("FILIAL"):SetValue(Alltrim(cNomLIF) + " - CGC: " + Transform(cCGCLIF,"@R 99.999.999/9999-99"))

		oSection1:PrintLine()

		// Iniciando a segunda seção
		oSection2:Init()

		// Enquanto existir dados na tabela ele imprimi
		While ((cAlias)->FILIAL) == cNumFil
			oReport:IncMeter()

			IncProc("Imprimindo " + Alltrim((cAlias)->LOCBEM))
			oSection2:Cell("LOCBEM"):SetValue((cAlias)->LOCBEM)
            oSection2:Cell("DESCRLOC"):SetValue((cAlias)->DESCRLOC)
            oSection2:Cell("GRUPO"):SetValue((cAlias)->GRUPO)
            oSection2:Cell("DESCRGRU"):SetValue((cAlias)->DESCRGRU)
            oSection2:Cell("QUANTIDADE"):SetValue((cAlias)->QUANTIDADE)
			oSection2:PrintLine()

			(cAlias)->(dbSkip())

		endDo

		oSection1:FInish()
		oReport:ThinLine()
		oSection2:FInish()

	EndDo

	(cAlias)->(dbCloseArea())

Return

Static Function RptStruc(cAlias)

    Local oReport   := NIL
    Local oSection1 := NIL
    Local oSection2 := NIL
    Local cTitulo   := "Resumo Grupo de Bens"
    Local cHelp     := "Lista os ativos e quantidade por local"

    // Instanciando a classe TReport
    oReport := Treport():New("LIFR011", cTitulo, , {|oReport|RPrint(oReport, cAlias)}, cHelp)

    // Sessão 1
    oSection1 := TRSection():New(oReport, "Filial", {"SN1"}, , .F., .T.)

    TRCell():New(oSection1, "FILIAL",       "SN1",  "Filial",  "@!", 100,,,,,,,,,,,.T.)
    

    //TRCell():New( <oParent> , <cName> , <cAlias> , <cTitle> , <cPicture> , <nSize> , <lPixel> , <bBlock> , <cAlign> , <lLineBreak> , <cHeaderAlign> , <lCellBreak> , <nColSpace> , <lAutoSize> , <nClrBack> , <nClrFore> , <lBold> ) ?
    //TRCell():New(oSection1, "FILIAL",       "SN1",  "Filial",			PesqPict("SN1","N1_FILIAL"),	7)

    // Sessão 2
    oSection2 := TRSection():New(oReport, "Ativos", {"SN1","SNL","SNG"}, NIL, .F., .T.)

    TRCell():New(oSection2, "LOCBEM",       "SN1",  "Local",			PesqPict("SN1","N1_LOCAL"),	    7)
	TRCell():New(oSection2, "DESCRLOC",		"SNL",  "Descr. Local",		PesqPict("SNL","NL_DESCRIC"),	TamSx3("NL_DESCRIC")[1])
	TRCell():New(oSection2, "GRUPO",	    "SN1",  "Grupo",			PesqPict("SN1","N1_GRUPO"),	    TamSx3("N1_GRUPO")[1])
    TRCell():New(oSection2, "DESCRGRU",		"SNG",  "Descr. Grupo",		PesqPict("SNG","NG_DESCRIC"),	TamSx3("NG_DESCRIC")[1])
	TRCell():New(oSection2, "QUANTIDADE",	"SN1",  "Quant.",		    PesqPict("SN1","N1_QUANTD"),	TamSx3("N1_QUANTD")[1])

    oSection1:SetPageBreak(.T.)

Return (oReport)
