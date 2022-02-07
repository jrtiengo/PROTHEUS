#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'TOPCONN.CH' 

/*
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ĳ��
���Programa  � AFPA04AK� Autor �Luiz Junior            � Data �           ���
�������������������������������������������������������������������������ĳ��
���Locacao   �                  �Contato �                                ���
�������������������������������������������������������������������������ĳ��
���Descricao � Gerenciamento de caixa da Asfrete                          ���
�������������������������������������������������������������������������ĳ��
���Parametros�                                                            ���
�������������������������������������������������������������������������ĳ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������ĳ��
���Aplicacao �                                                            ���
�������������������������������������������������������������������������ĳ��
���Uso       �                                                            ���
�������������������������������������������������������������������������ĳ��
���Analista Resp.�  Data  �                                               ���
�������������������������������������������������������������������������ĳ��
���              �  /  /  �                                               ���
���              �  /  /  �                                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������
*/

User Function CADBAIL

Local   oBrowse
                                           
//-> Instanciamento da Classe de Browse
oBrowse := FWMBrowse():New()
        
//-> Defini��o da tabela do Browse
oBrowse:SetAlias("ZZR")
oBrowse:SetMenuDef("CADBAIL")
        
// Titulo da Browse
oBrowse:SetDescription("Rotina para Cadastramento da Bairro")
        
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

ADD OPTION _aRotina Title "Pesquisar"  Action "PesqBrw"         OPERATION 1 ACCESS 0
ADD OPTION _aRotina Title "Visualizar" Action "ViewDef.CADBAIL" OPERATION 2 ACCESS 0
ADD OPTION _aRotina Title "Incluir"    Action "ViewDef.CADBAIL" OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title "Alterar"    Action "ViewDef.CADBAIL" OPERATION 4 ACCESS 0
ADD OPTION _aRotina Title "Excluir"    Action "ViewDef.CADBAIL" OPERATION 5 ACCESS 0
 
 
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
                                                                                               
Local oStruZZA := FWFormStruct(1,"ZZR")
Local oModel   := MPFormModel():New("ADBAIL")

oStruZZA:SetProperty("ZZR_CODIGO" , MODEL_FIELD_INIT , {|x| x := GETCOD()})
oStruZZA:SetProperty("ZZR_CODIGO" , MODEL_FIELD_WHEN , {||.F.})

oModel:AddFields("ZZRUNICO", Nil  , oStruZZA)

oModel:SetDescription("Cadastro de Bairro")

oModel:GetModel("ZZRUNICO"):SetDescription("Cadastro de Bairro")             

oModel:SetPrimaryKey({"ZZR_FILIAL","ZZR_CODIGO"})

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

Local oModel   := FWLoadModel("CADBAIL")
Local oStruZZA := FWFormStruct(2,"ZZR") 
Local oView	   := FWFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_ZZR", oStruZZA, "ZZRUNICO")
oView:CreateHorizontalBox("UM", 100)
oView:SetOwnerView("VIEW_ZZR" , "UM")

Return(oView)
   
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CADAREAL  �Autor  �Microsiga           � Data �  01/02/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function GETCOD

Local _cQuery  := ""
Local _cAlias  := GetNextAlias()

If Select("_cAlias") > 0
	("_cAlias")->(DbCloseArea())
EndIf

_cQuery := " SELECT MAX(ZZR_CODIGO) AS ZZR_CODIGO FROM "+RETSQLNAME("ZZR") 

TcQuery _cQuery New Alias _cAlias

_cCodigo := Iif(Empty(("_cAlias")->ZZR_CODIGO),"000001", Soma1(("_cAlias")->ZZR_CODIGO))

Return(_cCodigo)