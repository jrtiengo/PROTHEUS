#Include 'Protheus.ch'
#include "Topconn.ch"

 /*/{Protheus.doc} RICGPE003
Relatório simples trazer as funcionários Pais 
@type  Function
@author Tiengo
@since 15/05/2023
@see https://tdn.totvs.com/pages/releaseview.action?pageId=415715475
/*/

User Function RICGPE003()

    Local oReport
    Local cAlias  := getNextAlias() 

    OReport := RptStruc(cAlias)

    OReport:printDialog()

Return

Static Function RPrint(oReport, cAlias)

    Local oSecao1 := oReport:Section(1)

    oSecao1:BeginQuery()

        BeginSQL Alias cAlias

            SELECT 
                RA_FILIAL AS Filial,
                RA_MAT AS Matricula,
                RA_NOME AS Nome
            FROM %table:SRA% SRA
            INNER JOIN %table:SRB% SRB ON SRB.D_E_L_E_T_ = ''  AND SRB.RB_MAT = SRA.RA_MAT AND SRB.RB_GRAUPAR = 'F'
            WHERE
                RA_SEXO = 'M'AND
                RA_SITFOLH <> 'D' AND
                SRA.D_E_L_E_T_ = ''  
            GROUP BY RA_FILIAL, RA_MAT, RA_NOME
            ORDER BY RA_FILIAL, RA_MAT, RA_NOME

        EndSQL

    oSecao1:EndQuery()
    oReport:SetMeter((cAlias)->(RecCount()))

    oSecao1:Print()

Return

Static Function RptStruc(cAlias)

    Local cTitulo   := "Funcionarios Pais"
    Local cHelp     := "Permite imprimir funcionarios pais"
    Local oReport
    Local oSection1

    // Instanciando a classe TReport
    oReport := Treport():New("RICGPE002", cTitulo, /**/, {|oReport|RPrint(oReport, cAlias)}, cHelp)

    // Sessão
    oSection1 := TRSection():New(oReport, "Funcionarios Pais", {"SRA","SRB"})

    //TRCell():New( <oParent> , <cName> , <cAlias> , <cTitle> , <cPicture> , <nSize> , <lPixel> , <bBlock> , <cAlign> , <lLineBreak> , <cHeaderAlign> , <lCellBreak> , <nColSpace> , <lAutoSize> , <nClrBack> , <nClrFore> , <lBold> ) ?
    TRCell():New(oSection1, "Filial",           "SRA",  "Filial",       PesqPict("SRA","RA_FILIAL"),	TamSx3("RA_FILIAL")[1])
    TRCell():New(oSection1, "Matricula",        "SRA",  "Matricula",    PesqPict("SRA","RA_MAT"),	    TamSx3("RA_MAT")[1])
    TRCell():New(oSection1, "Nome",             "SRA",  "Nome",         PesqPict("SRA","RA_NOME"),  	TamSx3("RA_NOME")[1])

Return (oReport)

