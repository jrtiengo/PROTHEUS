#Include 'Protheus.ch'
#include "Topconn.ch"

User Function RelExcel()

    Processa({||MntQry() },,"Processando...")
    MsAguarde({||GeraExcel()},, "O Arquivo excel está sendo gerado...")

    DbSelectArea("TR1")
    dbCloseArea()

Return

Static Function MntQry()

    Local cQuery := ""

    cQuery := " SELECT "
    cQuery += " B1_COD AS COD_PROD, "
	cQuery += " B1_DESC AS DESC_PROD, "
	cQuery += " B1_TIPO AS TIPO, "
	cQuery += " BM_GRUPO AS COD_GRUPO, "
	cQuery += " BM_DESC AS DESC_GRUPO, "
	cQuery += " BM_PROORI AS ORI_GRUPO "
	cQuery += " FROM "+RetSQLName("SB1") + " SB1 " 
    //cQuery += " "+RetSQLName("SB1") + " SB1 "
    cQuery += " INNER JOIN "+RetSQLName("SBM")+ " SBM "
	cQuery += " ON SBM.BM_FILIAL = SB1.B1_FILIAL AND SBM.BM_GRUPO = SB1.B1_GRUPO "
	cQuery += " AND SBM.BM_FILIAL = '"+FWxFilial("SBM")+"' "
	cQuery += " AND SBM.D_E_L_E_T_ = '' "
    cQuery += " WHERE "
	cQuery += " SB1.B1_FILIAL = '"+FWxFilial("SB1")+"' "
	cQuery += " AND SB1.D_E_L_E_T_ = '' "
    cQuery += " ORDER BY "
    cQuery += " SB1.B1_COD "

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

    oExcel:AddWorkSheet("Produtos")
    oExcel:AddTable("Produtos", "Grupos")
    oExcel:AddColumn("Produtos", "Grupos", "COD_PROD",1,1)
    oExcel:AddColumn("Produtos", "Grupos", "DESC_PROD",1,1)
    oExcel:AddColumn("Produtos", "Grupos", "TIPO",1,1)
    oExcel:AddColumn("Produtos", "Grupos", "COD_GRUPO",1,1)
    oExcel:AddColumn("Produtos", "Grupos", "DESC_GRUPO",1,1)
    oExcel:AddColumn("Produtos", "Grupos", "ORI_GRUPO",1,1)

        While TR1->(!EOF())

            oExcel:AddRow("Produtos","Grupos", {TR1->(COD_PROD),; 
                                                TR1->(DESC_PROD),; 
                                                TR1->(TIPO),; 
                                                TR1->(COD_GRUPO),; 
                                                TR1->(DESC_GRUPO),; 
                                                TR1->(ORI_GRUPO)})
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
