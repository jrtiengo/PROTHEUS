#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "ALTDTSRA.CH"

/*/{Protheus.doc} AltDTSRA
Rotina que permite altera os campos RA_SITFOLH e RA_DEMISSA sem nenhuma validação
@type  User Function
@author Cícero Alves
@since 26/11/2019
@see https://tdn.totvs.com/x/FUIdHw
/*/
User Function AltDTSRA()
	
	Private aRotina 	:= 	MenuDef() 		
	Private oBrwSRA
	
	// "Esta rotina deverá ser utilizada apenas para ajustar a base de dados, não haverá nenhuma validação nos campos e não será enviado nenhum tipo de evento para o eSocial."
	// "Deseja continuar?"
	// "ATENÇÃO"
	If !MsgNoYes( STR0001 + CRLF + CRLF + STR0002, STR0003)
		Return
	EndIf
	
	oBrwSRA := FwMBrowse():New()
	oBrwSRA:SetAlias( 'SRA' )
	oBrwSRA:SetDescription(STR0004) // "Cadastro de Funcionários"
	GpLegend(@oBrwSRA, .T.)
	
	cFiltraRh := ChkRh("GPEA010", "SRA", "1")
	cFiltraRh += IF(!Empty(cFiltraRh),' .And. RA_SITFOLH = "D"', ' RA_SITFOLH = "D"' )
	oBrwSRA:SetFilterDefault(cFiltraRh)
	
	oBrwSRA:Activate()
	
Return

/*/{Protheus.doc} MenuDef
Adiciona as opções no menu da rotina
@type  Static Function
@author Cícero Alves
@since 26/11/2019
@return aRotina, Array, Array com as opções da rotina
/*/
Static Function MenuDef()
	
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0005 ACTION 'ViewDef.AltDTSRA' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // Atualizar 
	
Return aRotina

/*/{Protheus.doc} ViewDef
Cria a interface da rotina
@type  Static Function
@author Cícero Alves
@since 26/11/2019
@return oView, Objeto, Objeto instancia da classe FWFormView
@see https://tdn.totvs.com/x/WgueCQ 
/*/
Static Function ViewDef()
	
	Local oView			:= FWFormView():New()
	Local oModel 		:= FWLoadModel( 'AltDTSRA' ) 
	Local oStructSRA	:= FWFormStruct( 2, 'SRA', {|cCampo| AllTrim(cCampo) $ "RA_MAT|RA_NOME|RA_ADMISSA|RA_SITFOLH|RA_DEMISSA"} )
	
	oView:SetModel(oModel)
	
	oStructSRA:SetProperty('*', MVC_VIEW_FOLDER_NUMBER, '1')
	oStructSRA:SetProperty('RA_NOME', MVC_VIEW_CANCHANGE, .F.)
	oStructSRA:SetProperty('RA_ADMISSA', MVC_VIEW_CANCHANGE, .F.)
	
	oView:AddField( 'ViewSRA', oStructSRA, 'ModelSRA' )
	
	oView:CreateHorizontalBox( 'FormSRA', 100 )
	
	oView:SetOwnerView( 'ViewSRA', 'FormSRA')
	
Return oView

/*/{Protheus.doc} ModelDef
Definição do modelo utilizada no rotina
@type  Static Function
@author Cícero Alves
@since 26/11/2019
@return oModel, Objeto, Objeto instancia da classe MPFormModel
@see https://tdn.totvs.com/x/ewueCQ
/*/
Static Function ModelDef()
	
	Local oModel 		:= MPFormModel():New("SRAALT")
	Local oStructSRA	:= FWFormStruct( 1, 'SRA', {|cCampo| AllTrim(cCampo) $ "RA_MAT|RA_NOME|RA_ADMISSA|RA_SITFOLH|RA_DEMISSA"} )
	
	oStructSRA:SetProperty('RA_SITFOLH', MODEL_FIELD_VALID, {|| .T. })
	oStructSRA:SetProperty('RA_DEMISSA', MODEL_FIELD_VALID, {|| .T. })
	
	oModel:AddFields( 'ModelSRA', , oStructSRA )
	
	oModel:GetModel( 'ModelSRA' ):SetDescription(STR0006) // "Informações do Funcionário" 
	
Return oModel