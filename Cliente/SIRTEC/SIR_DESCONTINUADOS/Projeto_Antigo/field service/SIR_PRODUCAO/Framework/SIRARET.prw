#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'TOPCONN.CH' 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIRARET     บAutor  ณMicrosiga         บ Data ณ  08/23/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function SIRARET

Local   oBrowse
                                           
//-> Instanciamento da Classe de Browse
oBrowse := FWMBrowse():New()
        
//-> Defini็ใo da tabela do Browse
oBrowse:SetAlias("ZZW")
oBrowse:SetMenuDef("SIRARET")
        
// Titulo da Browse
oBrowse:SetDescription("Rotina para Cadastramento de Equipe de Programa็ใo")
        
// Ativa็ใo da Classe
oBrowse:Activate()

Return Nil 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef   บAutor  ณMicrosiga           บ Data ณ  11/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MenuDef()

Local _aRotina := {}

ADD OPTION _aRotina Title "Pesquisar"  Action "PesqBrw"        OPERATION 1 ACCESS 0
ADD OPTION _aRotina Title "Visualizar" Action "ViewDef.SIRARET" OPERATION 2 ACCESS 0
ADD OPTION _aRotina Title "Incluir"    Action "ViewDef.SIRARET" OPERATION 3 ACCESS 0
ADD OPTION _aRotina Title "Alterar"    Action "ViewDef.SIRARET" OPERATION 4 ACCESS 0
ADD OPTION _aRotina Title "Excluir"    Action "ViewDef.SIRARET" OPERATION 5 ACCESS 0 
 
Return(_aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณModelDef  บAutor  ณMicrosiga           บ Data ณ  11/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ModelDef()
                                                                                               
Local oStruZZW := FWFormStruct(1,"ZZW") 
Local oStruZA2 := FWFormStruct(1,"ZA2")
Local oModel   := MPFormModel():New("IRARET")

oStruZZW:RemoveField("ZZW_STATUS")
oStruZZW:RemoveField("ZZW_STAVA") 
oStruZZW:RemoveField("ZZW_DEFEIT")
oStruZZW:RemoveField("ZZW_SITUAC")    
oStruZZW:RemoveField("ZZW_STGRV") 
oStruZZW:RemoveField("ZZW_SITUA")
oStruZZW:RemoveField("ZZW_REJEIT")   
oStruZZW:RemoveField("ZZW_STATU")
oStruZZW:RemoveField("ZZW_RETSTA") 

oStruZZW:SetProperty("ZZW_NOTA" , MODEL_FIELD_WHEN , {||.F.})

oStruZA2:SetProperty("ZA2_NOTA" , MODEL_FIELD_WHEN , {||.F.})

oModel:AddFields("ZZWUNICO", Nil  , oStruZZW)
oModel:SetDescription("Retorno")
oModel:GetModel("ZZWUNICO"):SetDescription("Informa็๕es do retorno")       
oModel:SetPrimaryKey({"ZZW_FILIAL","ZZW_NOTA"})

oModel:AddGrid("ZA2UNICO", "ZZWUNICO",oStruZA2,,,,)
oModel:GetModel("ZA2UNICO"):SetDescription("Tabela de Execu็ใo") 
oModel:GetModel("ZA2UNICO"):SetUniqueLine({"ZA2_NOTA"})
oModel:GetModel("ZA2UNICO"):SetOptional(.f.)
oModel:SetRelation("ZA2UNICO",{{"ZA2_FILIAL","xFilial('ZA2')"},{"ZA2_NOTA","ZZW_NOTA"}},ZA2->(IndexKey(1)))
oModel:SetPrimaryKey({"ZA2_FILIAL","ZA2_NOTA"}) 

Return(oModel) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณViewDef  บAutor  ณMicrosiga           บ Data ณ  11/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ViewDef()

Local oModel   := FWLoadModel("SIRARET")
Local oStruZZW := FWFormStruct(2,"ZZW")
Local oStruZA2 := FWFormStruct(2,"ZA2") 
Local oView	   := FWFormView():New()

oStruZZW:RemoveField("ZZW_STATUS")
oStruZZW:RemoveField("ZZW_STAVA") 
oStruZZW:RemoveField("ZZW_DEFEIT")
oStruZZW:RemoveField("ZZW_SITUAC")
oStruZZW:RemoveField("ZZW_STGRV") 
oStruZZW:RemoveField("ZZW_SITUA")
oStruZZW:RemoveField("ZZW_REJEIT")  
oStruZZW:RemoveField("ZZW_STATU")
oStruZZW:RemoveField("ZZW_RETSTA")

//oStruZZW:RemoveField("ZZW_NOTA") 

oView:SetModel(oModel)
oView:AddField("VIEW_ZZW", oStruZZW, "ZZWUNICO")
oView:AddGrid("VIEW_ZA2" , oStruZA2, "ZA2UNICO")

oView:CreateHorizontalBox("SUPERIOR" ,60)
oView:CreateHorizontalBox("INFERIOR" ,40)

oView:CreateFolder("GRADES", "INFERIOR")
oView:AddSheet("GRADES", "PASTA01", OemToAnsi("Tabela de Execu็ใo"))

oView:CreateHorizontalBox("PASTA_ZA2", 100, , , "GRADES","PASTA01")

oView:SetOwnerView("VIEW_ZZW", "SUPERIOR")
oView:SetOwnerView("VIEW_ZA2", "PASTA_ZA2") 

oView:EnableTitleView("VIEW_ZZW")
oView:EnableTitleView("VIEW_ZA2")

oView:SetCloseOnOk( {||.t.} )

Return(oView)