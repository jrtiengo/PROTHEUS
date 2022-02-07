#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SIRPRG01L     �Autor  �Microsiga           � Data �  04/16/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function SIRPRG01L 

Local   oBrowse
                                           
//-> Instanciamento da Classe de Browse
oBrowse := FWMBrowse():New()
        
//-> Defini��o da tabela do Browse
oBrowse:SetAlias("ZZU")
oBrowse:SetMenuDef("SIRPRG01L")
       
// Titulo da Browse
oBrowse:SetDescription("Rotina para gerenciamento da programa��o")
        
// Ativa��o da Classe
oBrowse:Activate()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MenuDef   �Autor  �Microsiga           � Data �  11/04/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MenuDef()

Local _aRotina := {}

ADD OPTION _aRotina Title "Pesquisar"  Action "PesqBrw"           OPERATION 1 ACCESS 0
ADD OPTION _aRotina Title "Visualizar" Action "ViewDef.SIRPRG01L" OPERATION MODEL_OPERATION_VIEW  ACCESS 0
ADD OPTION _aRotina Title "Programar"  Action "U_SFOLPGL()"       OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title "Inc.Manual" Action "ViewDef.SIRPRG01L" OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title "Alterar"    Action "ViewDef.SIRPRG01L" OPERATION 4 ACCESS 0
 
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
                                                                                               
Local oStruZZU := FWFormStruct(1,"ZZU")
Local oModel   := MPFormModel():New("IRPRG01L")

oModel:AddFields("ZZUUNICO", Nil  , oStruZZU)

oModel:SetDescription("Gerenciamento Programa��o")

oModel:GetModel("ZZUUNICO"):SetDescription("Gerenciamento Programa��o")

oModel:SetPrimaryKey({"ZZU_FILIAL","ZZU_IDMOV"})

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

Local oModel   := FWLoadModel("SIRPRG01L")
Local oStruZZU := FWFormStruct(2,"ZZU") 
Local oView	   := FWFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_ZZU", oStruZZU, "ZZUUNICO")
oView:CreateHorizontalBox("UM", 100)
oView:SetOwnerView("VIEW_ZZU" , "UM")

Return(oView)   