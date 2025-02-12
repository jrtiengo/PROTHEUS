#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FwMvcDef.ch'


/*/{Protheus.doc} MVC003
//TODO Exemplo de valida��es em MVC
@author RCT Treinamentos
@version 1.0
@see www.rctitreinamentos.com.br

@type function
/*/
user function MVC003()
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

	Local aRotina := FwMvcMenu("MVC003")

Return aRotina

Static Function ModelDef()
	Local oModel := MPFormModel():New("XMVC003",{|oModel|MdlPreVld(oModel)},{|oModel| MdlPosVld(oModel)},,)
	Local oStPai := FWFormStruct(1,"ZZB")
	Local oStFilho := FWFormStruct(1,"ZZA")
	
	oModel:AddFields("ZZBMASTER",,oStPai)
	oModel:AddGrid('ZZADETAIL','ZZBMASTER',oStFilho,,,,,)
	
	//Valida��o na abertura do modelo
	oModel:SetVldActivate({|oModel| MdlActiveVld(oModel)})
	
	oModel:SetRelation('ZZADETAIL',{{'ZZA_FILIAL','xFilial("ZZA")'},{'ZZA_CODALB','ZZB_COD'}},ZZA->(IndexKey(1)))
	//Valida��o para n�o repetir dados
	oModel:GetModel('ZZADETAIL'):SetUniqueLine({"ZZA_FILIAL","ZZA_NOME"})
	
		oModel:SetPrimaryKey({"ZZA_FILIAL",""})
		
	oModel:SetDescription("Modelo 3")
	oModel:GetModel('ZZBMASTER'):SetDescription('Modelo albuns')
	oModel:GetModel('ZZADETAIL'):SetDescription('Modelo musicas')

Return oModel

Static Function ViewDef()
	local oView := Nil
	Local oModel := FWLoadModel("MVC003")
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
	
	oView:AddIncrementField('VIEW_ZZA','ZZA_NUM')
	
	oView:EnableTitleView("VIEW_ZZB",'Cabe�alho')
	oView:EnableTitleView("VIEW_ZZA",'Grid')


Return oView

Static Function MdlActiveVld(oModel)
	Local lValid := .T.

	If(dDataBase != Date())
		
		Help(NIL, NIL, "MdlActiveVld", NIL, "Data do sistema",;
		1,0, NIL, NIL, NIL, NIL, NIL,{"A data do sistema est� diferente da data atual."})
		
		lValid := .F.
		
	EndIf

Return (lValid)

// PR�-vALIDA��O DO MODELO

Static Function MdlPreVld(oModel)
	Local lValid := .T.
	
	MsgAlert("Pr� valida��o","MDLPREVLD")


Return (lValid)
// P�s-Valida��o do modelo 

Static Function MdlPosVld(oModel)
	Local lValid := .T.
	
	If MsgYesNo("Deseja realmente continuar? ")
		MsgInfo("Validado pelo usu�rio")
		
		Else
			lValid := .F.
		
	EndIf

Return(lValid)






