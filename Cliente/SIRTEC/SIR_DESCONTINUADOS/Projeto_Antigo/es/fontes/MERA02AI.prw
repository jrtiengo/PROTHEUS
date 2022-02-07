#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'TOPCONN.CH' 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NOVO3     �Autor  �Microsiga           � Data �  08/23/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MERA02AI

Local   oBrowse
                                           
//-> Instanciamento da Classe de Browse
oBrowse := FWMBrowse():New()
        
//-> Defini��o da tabela do Browse
oBrowse:SetAlias("ZZ4")
oBrowse:SetMenuDef("MERA02AI")
        
// Titulo da Browse
oBrowse:SetDescription("Rotina para Cadastramento de Equipe de Programa��o")
        
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
ADD OPTION _aRotina Title "Visualizar" Action "ViewDef.MERA02AI" OPERATION 2 ACCESS 0
ADD OPTION _aRotina Title "Incluir"    Action "ViewDef.MERA02AI" OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title "Alterar"    Action "ViewDef.MERA02AI" OPERATION 4 ACCESS 0
ADD OPTION _aRotina Title "Excluir"    Action "ViewDef.MERA02AI" OPERATION 5 ACCESS 0 
 
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
                                                                                               
Local oStruZZ4 := FWFormStruct(1,"ZZ4") 
Local oStruZZ5 := FWFormStruct(1,"ZZ5")
Local oModel   := MPFormModel():New("ERA02AI")

oModel:AddFields("ZZ4UNICO", Nil  , oStruZZ4)
oModel:SetDescription("Cadastro de Equipe")
oModel:GetModel("ZZ4UNICO"):SetDescription("Cadastro de Equipe")      
oModel:SetPrimaryKey({"ZZ4_FILIAL","ZZ4_CODIGO"})

oModel:AddGrid("ZZ5UNICO", "ZZWUNICO",oStruZZ5,,,,)
oModel:GetModel("ZZ5UNICO"):SetDescription("Dados das Previs�es Financeiras")
oModel:GetModel("ZZ5UNICO"):SetUniqueLine({"ZA2_NOTA"})
oModel:GetModel("ZZ5UNICO"):SetOptional(.f.)
oModel:SetRelation("ZZ5UNICO",{{"ZZ5_FILIAL","xFilial('ZZ5')"},{"ZZ5_CODIGO","ZZ4_CODIGO"}},ZZ5->(IndexKey(1)))
oModel:SetPrimaryKey({"ZZ5_FILIAL","ZZ5_CODIGO"})

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

Local oModel   := FWLoadModel("TSTMVC")
Local oStruZZ4 := FWFormStruct(2,"ZZ4")
Local oStruZZ5 := FWFormStruct(2,"ZZ5") 
Local oView	   := FWFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_ZZ4", oStruZZ4, "ZZ4UNICO")
oView:AddGrid( "VIEW_ZZ5", oStruZZ5, "ZZ5UNICO" )

oView:CreateHorizontalBox("SUPERIOR" ,60)
oView:CreateHorizontalBox("INFERIOR" ,40)

oView:CreateFolder("GRADES", "INFERIOR")
oView:AddSheet("GRADES", "PASTA01", OemToAnsi("Percentual"))

oView:CreateHorizontalBox("PASTA_ZA2", 100, , , "GRADES","PASTA01")

oView:SetOwnerView("VIEW_ZZ4", "SUPERIOR")
oView:SetOwnerView("VIEW_ZZ5", "PASTA_ZZ5")

oView:EnableTitleView("VIEW_ZZ4")
oView:EnableTitleView("VIEW_ZZ5")

oView:SetCloseOnOk( {||.t.} )

Return(oView)