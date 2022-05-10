#Include "Totvs.ch"
#Include 'Protheus.ch'
#Include "FWMVCDef.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSCIA150   บAutor  ณMicrosiga           บ Data ณ  05/08/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function SCIA150()

Local oBrowse

Private aRotina := MenuDef()

//Instaciamento da Classe de Browse
oBrowse := FWMBrowse():New()

//Definicao da tabela do Browse
oBrowse:SetAlias("Z03")

//Definicao da legenda
//oBrowse:AddLegend("Z03_COD<>''","YELLOW","OK")

//Definicao de filtro
//oBrowse:SetFilterDefault("ZA0_TIPO='1'")

//Titulo da Browse
oBrowse:SetDescription("Cadastro de Titulares")

//Opcionalmente pode ser desligado a exibi็ใo dos detalhes
oBrowse:DisableDetails()

//Ativacao da Classe
oBrowse:Activate()

Return



/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    | MenuDef | Autor | Denis Rodrigues        | Data |18/08/2018|||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao | Funcao para gerar o Menu                                   |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Parametros|                                                            |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.SCIA150' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.SCIA150' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.SCIA150' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.SCIA150' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return ( aRotina )
//Return FWMVCMenu("MVCMOD1")


/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    | ModelDef| Autor | Denis Rodrigues        | Data |18/08/2018|||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao | Funcao ModelDef                                            |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Parametros|                                                            |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function ModelDef()

//Cria a estrutura a ser uada no Modelo de dados
Local oStruZ03 := FWFormStruct( 1,"Z03" )
Local oModel //Modelo de dados que sera contruido

//Cria o objeto do Modelo de Dados
oModel := MPFormModel():New("SCIA150M", /*{|oModel| u_150PreVl(oModel)}*/, /*{|oModel| MA130PosVl(oModel)}*/,/*{|oModel| u_150PosVl(oModel)}*/ /*{|oModel| MA130Commi(oModel)}*/)

oModel:SetVldActive( { |oModel| SCIOpen( oModel ) } )

//Adiciona ao modelo um componente de formulario
oModel:AddFields( "Z03MASTER", /*cOwner*/, oStruZ03)

oModel:SetPrimaryKey( { "Z03_FILIAL", "Z03_CPF" } )

//Adiciona a descri็ใo do Modelo de dados
oModel:SetDescription("Cadastro de Titulares")

//Adiciona a descri็ใo do Componente do Modelo de Dados
oModel:GetModel("Z03MASTER"):SetDescription("Formulแrio - Cadastro de Titulares")

Return( oModel )

/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    | ViewDef | Autor | Denis Rodrigues        | Data |18/08/2018|||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao | Funcao ViewDef                                             |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Parametros|                                                            |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function ViewDef()

Local oModel := FWLoadModel("SCIA150")

//Cria a estrutura a ser usada na View
Local oStruZ03 := FWFormStruct( 2,"Z03")

//Interface de visualiza็ใo construํda
Local oView

//Cria o objeto de View
oView := FWFormView():New()

//Define qual o Modelo de dados serแ utilizado na View
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo formulแrio (antiga Enchoice)
oView:Addfield( "VIEW_Z03", oStruZ03, "Z03MASTER" )

//Criar um 'box' horizontal para receber algum elemento da view
oView:CreateHorizontalBox( "TELA",100 )

//Relaciona o identificador (ID) da View com o 'box' para exibicao
oView:SetOwnerView( "VIEW_Z03", "TELA" )

Return( oView )


*********************************************************************************************************************************************
*********************************************************************************************************************************************
*********************************************************************************************************************************************
Static Function SCIOpen( oModel )

Local lRet := .T.

If oModel:GetOperation() == MODEL_OPERATION_DELETE
	
	dbSelectArea("SE2")
	dbOrderNickname("TEMTITULAR")
	If dbSeek(xFilial("SE2")+Z03->Z03_CPF,.F.)
		Help( ,, "HELP","MDMVlPos", "Nใo pode excluir este titular pois jแ foi vinculado a um PA", 1, 0)
		lRet := .F.
	EndIf
	
	If lRet
		dbSelectArea("Z02")
		dbSetOrder(2)
		If dbSeek(xFilial("Z02")+Z03->Z03_CPF,.F.)
			Help( ,, "HELP","MDMVlPos", "Nใo pode excluir este titular pois jแ foi vinculado a um processo de pagamento", 1, 0)
			lRet := .F.
		EndIf
	EndIf
	
EndIf

Return(lRet)
