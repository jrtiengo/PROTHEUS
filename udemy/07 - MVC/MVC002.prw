#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FwMvcDef.ch'

/*/{Protheus.doc} MVC002
//TODO Tela de cadastro em MVC com duas entidades
@author Rcti treinamentos
@version 1.0
@see www.rctitreinamentos.com.br

@type function
/*/
user function MVC002()
	Local aArea := GetArea()
	Local oBrowse := FwMBrowse():New()
	
	oBrowse:SetAlias("ZZB")
	oBrowse:SetDescription  ("Albuns")
	
	// definindo as legendas
	oBrowse:AddLegend("ZZB->ZZB_TIPO == '1'","GREEN", "CD") //vrede
	oBrowse:AddLegend("ZZB->ZZB_TIPO == '2'","BLUE", "DVD") //azul
	//ativa o browse
	oBrowse:Activate()
	RestArea(aArea)
		
return Nil

Static Function MenuDef()

	Local aRotina := FwMvcMenu("MVC002")

Return aRotina

Static Function ModelDef()
	Local oModel := MPFormModel():New("XMVC003",,,,)
	Local oStPai := FWFormStruct(1,"ZZB")
	Local oStFilho := FWFormStruct(1,"ZZA")
	
	oModel:AddFields("ZZBMASTER",,oStPai)
	oModel:AddGrid('ZZADETAIL','ZZBMASTER',oStFilho,,,,,)
	
	oModel:SetRelation('ZZADETAIL',{{'ZZA_FILIAL','xFilial("ZZA")'},{'ZZA_CODALB','ZZB_COD'}},ZZA->(IndexKey(1)))
	
		oModel:SetPrimaryKey({"ZZA_FILIAL",""})
		
	oModel:SetDescription("Modelo 3")
	oModel:GetModel('ZZBMASTER'):SetDescription('Modelo albuns')
	oModel:GetModel('ZZADETAIL'):SetDescription('Modelo musicas')

Return oModel

Static Function ViewDef()
	local oView := Nil
	Local oModel := FWLoadModel("MVC002")
	Local oStPai := FwFormStruct(2,"ZZB")
	Local oStFilho := FwFormStruct(2,"ZZA")
	
	oView := FWFormView():New()
	oView:SetModel(oModel) 
	
	oView:AddField('VIEW_ZZB',oStPai,'ZZBMASTER')
	oView:AddGrid('VIEW_ZZA',oStFilho,'ZZADETAIL')
	
	oView:CreateHorizontalBox('CABEC',40)
	oView:CreateHorizontalBox('GRID',60)
	
	oView:SetOwnerView('VIEW_ZZB','CABEC')
	oView:SetOwnerView('VIEW_ZZA','GRID')
	
	oView:EnableTitleView("VIEW_ZZB",'Cabeçalho')
	oView:EnableTitleView("VIEW_ZZA",'Grid')


Return oView











