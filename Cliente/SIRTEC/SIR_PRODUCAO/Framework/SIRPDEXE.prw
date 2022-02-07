#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'TOPCONN.CH' 



User Function SIRPDEXE

Local   oBrowse
                                           
//-> Instanciamento da Classe de Browse
oBrowse := FWMBrowse():New()
        
//-> Defini��o da tabela do Browse
oBrowse:SetAlias("ZA3")
oBrowse:SetMenuDef("SIRPDEXE")
        
// Titulo da Browse
oBrowse:SetDescription("Tabela de Prod x Exe")
        
// Ativa��o da Classe
oBrowse:Activate()

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MenuDef   �Autor  �Microsiga           � Data �  11/04/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MenuDef()

Local _aRotina := {}

ADD OPTION _aRotina Title "Pesquisar"  Action "PesqBrw"          OPERATION 1 ACCESS 0
ADD OPTION _aRotina Title "Visualizar" Action "ViewDef.SIRPDEXE" OPERATION 2 ACCESS 0
ADD OPTION _aRotina Title "Incluir"    Action "ViewDef.SIRPDEXE" OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title "Alterar"    Action "ViewDef.SIRPDEXE" OPERATION 4 ACCESS 0
ADD OPTION _aRotina Title "Excluir"    Action "ViewDef.SIRPDEXE" OPERATION 5 ACCESS 0 
 
Return(_aRotina)
 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �Microsiga           � Data �  11/04/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ModelDef()
                                                                                               
Local oStruZA3 := FWFormStruct(1,"ZA3")
Local oModel   := MPFormModel():New("IRPDEXE")

//oStruZA3:RemoveField("ZA3_NOTA")

oStruZA3:SetProperty("ZA3_NOTA" , MODEL_FIELD_WHEN , {||.F.})

oModel:AddFields("ZA3UNICO", Nil  , oStruZA3)

oModel:SetDescription("Tabela de Prod x Exe")

oModel:GetModel("ZA3UNICO"):SetDescription("Tabela de Prod x Exe")             

oModel:SetPrimaryKey({"ZA3_FILIAL","ZA3_NOTA"})

Return(oModel) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GEST001L  �Autor  �Microsiga           � Data �  11/04/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ViewDef()

Local oModel   := FWLoadModel("SIRPDEXE")
Local oStruZA3 := FWFormStruct(2,"ZA3") 
Local oView	   := FWFormView():New()

//oStruZA3:RemoveField("ZA3_NOTA")

oView:SetModel(oModel)
oView:AddField("VIEW_ZA3", oStruZA3, "ZA3UNICO")
oView:CreateHorizontalBox("UM", 100)
oView:SetOwnerView("VIEW_ZA3" , "UM")

Return(oView)