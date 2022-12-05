#INCLUDE "PROTHEUS.CH"

User Function SG1Gat()

    Local oModel := FWModelActive()
    Local cCod   := oModel:Getvalue("SB1MASTER","B1_TIPO")
    
    oModel:SetValue('SG1_MASTER','G1_XCODPRF',cCod)

Return cCod
                                                 