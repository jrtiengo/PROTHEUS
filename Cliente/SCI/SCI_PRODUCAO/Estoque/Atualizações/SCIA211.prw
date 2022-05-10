#Include 'rwmake.ch'
#Include "FWMVCDef.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณNOVO4     บAutor  ณMicrosiga           บ Data ณ  12/11/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function SCIA211()

Local oBrowse

Private aRotina := MenuDef()

//Instaciamento da Classe de Browse
oBrowse := FWMBrowse():New()

//Definicao da tabela do Browse
oBrowse:SetAlias("SZF")

//Definicao da legenda
//oBrowse:AddLegend("SZF_COD<>''","YELLOW","OK")

//Definicao de filtro
//oBrowse:SetFilterDefault("ZA0_TIPO='1'")

//Titulo da Browse
oBrowse:SetDescription("Controle Entrega Pedido pelo Almox")

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

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.SCIA211' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.SCIA211' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.SCIA211' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.SCIA211' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

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
Local oStruSZF := FWFormStruct( 1,"SZF" )
Local oModel //Modelo de dados que sera contruido

//Cria o objeto do Modelo de Dados
oModel := MPFormModel():New("SCIA211M", /*{|oModel| u_150PreVl(oModel)}*/, {|oModel| MA210PosVl(oModel)},/*{|oModel| u_150PosVl(oModel)}*/ /*{|oModel| MA130Commi(oModel)}*/)

//oModel:SetVldActive( { |oModel| SCIOpen( oModel ) } ) //neste caso quando tu clicar em excluir ele ja vai dar a mensgaem caso positivo...

//Adiciona ao modelo um componente de formulario
oModel:AddFields( "SZFMASTER", /*cOwner*/, oStruSZF)

oModel:SetPrimaryKey( { "SZF_FILIAL", "SZF_QUEMREC", "SZF_DTREC", "SZF_HRREC" } )

//Adiciona a descri็ใo do Modelo de dados
oModel:SetDescription("Controle Entrega Pedido pelo Almox")

//Adiciona a descri็ใo do Componente do Modelo de Dados
oModel:GetModel("SZFMASTER"):SetDescription("Formulแrio - Controle Entrega Pedido pelo Almox")

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

Local oModel := FWLoadModel("SCIA211")

//Cria a estrutura a ser usada na View
Local oStruSZF := FWFormStruct( 2,"SZF")

//Interface de visualiza็ใo construํda
Local oView

//Cria o objeto de View
oView := FWFormView():New()

//Define qual o Modelo de dados serแ utilizado na View
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo formulแrio (antiga Enchoice)
oView:Addfield( "VIEW_SZF", oStruSZF, "SZFMASTER" )

//Criar um 'box' horizontal para receber algum elemento da view
oView:CreateHorizontalBox( "TELA",100 )

//Relaciona o identificador (ID) da View com o 'box' para exibicao
oView:SetOwnerView( "VIEW_SZF", "TELA" )

Return( oView )

*********************************************************************************************************************************************
*********************************************************************************************************************************************
*********************************************************************************************************************************************
Static Function MA210PosVl( oModel )

Local lRet      := .T.
Local cQuery    := ''
Local nQuantSZF := 0
Local aArea     := GetArea()
Local aAreaSC7  := SC7->(GetArea())

oModel    := FWModelActive()
oModelSZF := oModel:GetModel("SZFMASTER")
cZF_PEDIDO:= oModelSZF:GetValue('ZF_PEDIDO') 
cZF_ITPD   := oModelSZF:GetValue('ZF_ITPD')     
cZF_CODFOR := oModelSZF:GetValue('ZF_CODFOR')   
cZF_LOJFOR := oModelSZF:GetValue('ZF_LOJFOR')  
cZF_PROD   := oModelSZF:GetValue('ZF_PROD')  
nZF_QUANT  := oModelSZF:GetValue('ZF_QUANT')  

If oModel:GetOperation() = MODEL_OPERATION_DELETE
   Return(.T.)
EndIf

//Preciso validar se a quantidade jดpa lan็ada na NF ้ maior ou nใo...nใo pode
cQuery := "SELECT SUM(ZF_QUANT) QUANT"
cQuery += " FROM " + RetSQLName("SZF") + " SZF"
cQuery += " WHERE ZF_FILIAL = '" + xFilial("SZF") + "'"
cQuery += " AND ZF_PEDIDO   = '" + cZF_PEDIDO     + "'"
cQuery += " AND ZF_ITPD     = '" + cZF_ITPD     + "'"
cQuery += " AND SZF.D_E_L_E_T_ <> '*'"
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)
nQuantSZF := TRB->QUANT
TRB->(DbCloseArea())

dbSelectArea("SC7")
dbSetOrder(1)
dbSeek(xFilial("SC7")+cZF_PEDIDO+cZF_ITPD,.f.)   

If nQuantSZF + nZF_QUANT > SC7->C7_QUANT
	Help( ,, "HELP","", "Quantidade lan็ada a maior do que item do Pedido", 1, 0)
	lRet := .F.
EndIf

RestArea(aAreaSC7)
RestArea(aArea)
Return lRet



