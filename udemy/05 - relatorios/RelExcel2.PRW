#Include 'Protheus.ch'
#include "Topconn.ch"

User Function RelExcel2()

    Processa({||MntQry() },,"Processando...")
    MsAguarde({||GeraExcel()},, "O Arquivo excel está sendo gerado...")

    DbSelectArea("TR1")
    dbCloseArea()

Return

Static Function MntQry()

    Local cQuery := ""

        cQuery := " SELECT "
        cQuery += " C5_NUM, C5_TIPO, C5_VEND1, C5_CLIENTE, C5_EMISSAO, " 
        cQuery += " C6_ITEM, C6_PRODUTO, C6_UM, C6_QTDVEN, C6_PRCVEN, C6_VALOR, "
        cQuery += " A1_COD, A1_NOME, A1_VEND, A1_MCOMPRA,
        cQuery += " B1_DESC, B1_GRUPO "
        cQuery += " FROM "+RetSQLName("SC5") + " SC5 " 
        cQuery += " INNER JOIN "+RetSQLName("SC6")+" SC6 ON SC6.C6_NUM = SC5.C5_NUM AND SC6.C6_FILIAL = '"+FWxFilial("SC6")+"' AND SC6.D_E_L_E_T_ = '' "
        cQuery += " INNER JOIN "+RetSQLName("SA1")+" SA1 ON SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_FILIAL = '"+FWxFilial("SA1")+"' AND SA1.D_E_L_E_T_ = '' "
        cQuery += " INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.B1_COD = SC6.C6_PRODUTO AND SB1.B1_FILIAL = '"+FWxFilial("SB1")+"' AND SB1.D_E_L_E_T_ = '' "
        cQuery += " WHERE "
        cQuery += " SC5.C5_FILIAL = '"+FWxFilial("SC6")+"' AND SC5.D_E_L_E_T_ = '' "
        cQuery += " ORDER BY "
        cQuery += " C5_FILIAL, C5_NUM, " 
        cQuery += " C6_FILIAL, C6_ITEM "

        If Select ("TR1") <> 0 
            DbSelectArea("TR1")
            DbCloseArea()
        EndIF

    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "TR1", .F., .T.)

Return

Static Function GeraExcel()

    Local oExcel    := FWMSEXCEL():New()
    Local lOK       := .f.
    Local cArq      := ""
    Local cDirTmp   := "C:\temp\"

    DbSelectArea("TR1")
    TR1->(dbGoTop())

    oExcel:SetFontSize (12)
    oExcel:SetFont("Arial")
    oExcel:SetTitleBold(.T.)
    oExcel:SetBgGeneralColor("#333")
    oExcel:SetTitleFrColor("#FFFF00")
    oExcel:SetLineFrColor("#A9A9A9")
    oExcel:Set2LineFrColor("#FFFFFF")

    // ABA 1 

    oExcel:AddWorkSheet("ABA 1")
    oExcel:AddTable("ABA 1", "CLIENTES")
    oExcel:AddColumn("ABA 1", "CLIENTES", "A1_COD",1,1)
    oExcel:AddColumn("ABA 1", "CLIENTES", "A1_NOME",1,1)
    oExcel:AddColumn("ABA 1", "CLIENTES", "C5_NUM",1,1)


    // ABA 2 

    oExcel:AddWorkSheet("ABA 2")
    oExcel:AddTable("ABA 2", "PEDIDOS")
    oExcel:AddColumn("ABA 2", "PEDIDOS", "C5_NUM",1,1)
    oExcel:AddColumn("ABA 2", "PEDIDOS", "C5_EMISSAO",1,1)
    oExcel:AddColumn("ABA 2", "PEDIDOS", "C6_QTDVEN",1,1)
    oExcel:AddColumn("ABA 2", "PEDIDOS", "C6_VALOR",3,3)
    oExcel:AddColumn("ABA 2", "PEDIDOS", "B1_DESC",1,1)
    
    
        While TR1->(!EOF())

            oExcel:AddRow("ABA 1","CLIENTES", {TR1->(A1_COD),; 
                                                TR1->(A1_NOME),; 
                                                TR1->(C5_NUM)})

            oExcel:AddRow("ABA 2","PEDIDOS", {TR1->(C5_NUM),; 
                                                TR1->(sTod(C5_EMISSAO)),; 
                                                TR1->(C6_QTDVEN),; 
                                                TR1->(C6_VALOR),; 
                                                TR1->(B1_DESC)})
            lOk := .T.
            TR1->(dbSkip())

        EndDO

    oExcel:Activate()

        cArq := CriaTrab(NIL, .F.) + ".xml"
        oExcel:GetXMLFile(cArq)

            If __CopyFile(cArq,cDirTmp + cArq)
                If lOK
                    oExcelAPP := MSExcel():New()
                    oExcelAPP:WorkBooks:Open(cDirTmp + cArq)
                    oExcelApp:SetVisible(.T.)
                    oExcelApp:Destroy()
                    MsgInfo("O arquivo Excel foi gerado no diretório: " + cDirTmp + cArq + ". ")
                EndIF
                Else 
                    MsgAlert("Erro ao copiar o arquivo Excel!")
            EndIF

Return
