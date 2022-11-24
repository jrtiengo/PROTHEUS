#INCLUDE "PROTHEUS.CH"

User Function xGatMVC()

Local oModel    := FWModelActive()
Local cDesc     := oModel:GetValue('SG1_MASTER','G1_COD')

oModel:SetValue('SG1_DETAIL','G1_XCODPRF',cDesc)

Return cDesc
