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
    Local cQuery    := ""
    Local cNumCod   := ""

    cQuery := " SELECT A1_COD, A1_NOME, C5_NUM, C6_QTDVEN, C6_PRCVEN, B1_DESC "
    cQuery += " FROM SA1990 SA1, SC5990 SC5, SC6990 SC6, SB1990 SB1 "
    cQuery += " WHERE SA1.D_E_L_E_T_ = '' AND "
    cQuery += " C5_FILIAL = '"+MV_PAR01+"' AND SC5.D_E_L_E_T_ = '' AND C5_CLIENTE = A1_COD AND "
    cQuery += " C6_FILIAL = '"+MV_PAR01+"' AND SC6.D_E_L_E_T_ = '' AND C6_NUM = C5_NUM AND "
   // cQuery += " B1_FILIAL = '"+MV_PAR01+"' AND SB1.D_E_L_E_T_ = '' AND B1_COD = C6_PRODUTO "
    cQuery += " SB1.D_E_L_E_T_ = '' AND B1_COD = C6_PRODUTO "
    cQuery += " ORDER BY A1_FILIAL, A1_COD, C5_FILIAL, C5_NUM, C6_FILIAL, C6_ITEM "

    //Verifica se a tabela já está aberta
        If Select ("TEMP") <> 0 
            DbSelectArea("TEMP")
            DbCloseArea()
        EndIF

    TCQUERY cQuery NEW ALIAS "TEMP"

        DbSelectArea("TEMP")
        TEMP->(dbGoTop())

        oReport:SetMeter(TEMP->(LastRec()))
    
    While !EOF()
        If oReport:Cancel()
            Exit    
        EndIF
        // Iniciando a primeira seção
        oSection1:Init()
        oReport:IncMeter()

        cNumcod := TEMP->A1_COD
        IncProc("Imprimindo Cliente " + Alltrim(TEMP->A1_COD))

        // Imprimindo a primeira seção
        oSection1:Cell("A1_COD"):SetValue(TEMP->A1_COD)
        oSection1:Cell("A1_NOME"):SetValue(TEMP->A1_NOME)
        oSection1:PrintLine()

        // Iniciando a segunda seção 
        oSection2:Init()
        
        // Verifica se o código do cliente é o mesmo, se sim, imprime o dados do pedido

        While TEMP->A1_COD == cNumCod   
            oReport:IncMeter()  

        IncProc("Imprimindo Pedidos " + Alltrim(TEMP->C5_NUM))
            oSection2:Cell("C5_NUM"):SetValue(TEMP->C5_NUM)
            oSection2:Cell("B1_DESC"):SetValue(TEMP->B1_DESC)
            oSection2:Cell("C6_PRCVEN"):SetValue(TEMP->C6_PRCVEN)
            oSection2:Cell("C6_QTDVEN"):SetValue(TEMP->C6_QTDVEN)
            oSection2:PrintLine()

            TEMP->(dbSkip())           

        endDo

            oSection2:FInish()
            oReport:ThinLine()

            oSection1:FInish()

    EndDo

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
    TRCell():New(oSection1, "A1_COD",       "TEMP",  "CODIGO",  "@!", 40)
    TRCell():New(oSection1, "A1_NOME",      "TEMP",  "NOME",    "@!", 200)

    oSection2 := TRSection():New(oReport, "Produtos", {"SB1"}, NIL, .F., .T.)
    TRCell():New(oSection2, "C5_NUM",       "TEMP",  "Pedido",      "@!", 30)
    TRCell():New(oSection2, "B1_DESC",      "TEMP",  "Descricao",   "@!", 200)
    TRCell():New(oSection2, "C6_PRCVEN",    "TEMP",  "Prec. Venda", "@E 99999.99", 20)
    TRCell():New(oSection2, "C6_QTDVEN",    "TEMP",  "Quantidade",  "@E 99999.99", 30)

    oSection1:SetPageBreak(.F.) //Quebra de Seção

Return (oReport)
