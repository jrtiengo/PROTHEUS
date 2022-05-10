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
User Function SCIA210()

Local oBrowse

Private aRotina := MenuDef()

//Instaciamento da Classe de Browse
oBrowse := FWMBrowse():New()

//Definicao da tabela do Browse
oBrowse:SetAlias("SZE")

//Definicao da legenda
//oBrowse:AddLegend("SZE_COD<>''","YELLOW","OK")

//Definicao de filtro
//oBrowse:SetFilterDefault("ZA0_TIPO='1'")

//Titulo da Browse
oBrowse:SetDescription("Controle Entrega NF pelo Almox")

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

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.SCIA210' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.SCIA210' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.SCIA210' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.SCIA210' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

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
Local oStruSZE := FWFormStruct( 1,"SZE" )
Local oModel //Modelo de dados que sera contruido

//Cria o objeto do Modelo de Dados
oModel := MPFormModel():New("SCIA210M", /*{|oModel| u_150PreVl(oModel)}*/, {|oModel| MA210PosVl(oModel)},/*{|oModel| u_150PosVl(oModel)}*/ /*{|oModel| MA130Commi(oModel)}*/)

//oModel:SetVldActive( { |oModel| SCIOpen( oModel ) } ) //neste caso quando tu clicar em excluir ele ja vai dar a mensgaem caso positivo...

//Adiciona ao modelo um componente de formulario
oModel:AddFields( "SZEMASTER", /*cOwner*/, oStruSZE)

oModel:SetPrimaryKey( { "SZE_FILIAL", "SZE_QUEMREC", "SZE_DTREC", "SZE_HRREC" } )

//Adiciona a descri็ใo do Modelo de dados
oModel:SetDescription("Controle Entrega NF pelo Almox")

//Adiciona a descri็ใo do Componente do Modelo de Dados
oModel:GetModel("SZEMASTER"):SetDescription("Formulแrio - Controle Entrega NF pelo Almox")

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

Local oModel := FWLoadModel("SCIA210")

//Cria a estrutura a ser usada na View
Local oStruSZE := FWFormStruct( 2,"SZE")

//Interface de visualiza็ใo construํda
Local oView

//Cria o objeto de View
oView := FWFormView():New()

//Define qual o Modelo de dados serแ utilizado na View
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo formulแrio (antiga Enchoice)
oView:Addfield( "VIEW_SZE", oStruSZE, "SZEMASTER" )

//Criar um 'box' horizontal para receber algum elemento da view
oView:CreateHorizontalBox( "TELA",100 )

//Relaciona o identificador (ID) da View com o 'box' para exibicao
oView:SetOwnerView( "VIEW_SZE", "TELA" )

Return( oView )

*********************************************************************************************************************************************
*********************************************************************************************************************************************
*********************************************************************************************************************************************
Static Function MA210PosVl( oModel )

Local lRet      := .T.
Local cQuery    := ''
Local nQuantSZE := 0
Local aArea     := GetArea()
Local aAreaSD1  := SD1->(GetArea())
oModel    := FWModelActive()
oModelSZE := oModel:GetModel("SZEMASTER")
cZE_NF     := oModelSZE:GetValue('ZE_NF') 
cZE_SERIE  := oModelSZE:GetValue('ZE_SERIE')   
cZE_ITNF   := oModelSZE:GetValue('ZE_ITNF')     
cZE_CODFOR := oModelSZE:GetValue('ZE_CODFOR')   
cZE_LOJFOR := oModelSZE:GetValue('ZE_LOJFOR')  
cZE_PROD   := oModelSZE:GetValue('ZE_PROD')  
nZE_QUANT  := oModelSZE:GetValue('ZE_QUANT')  

If oModel:GetOperation() = MODEL_OPERATION_DELETE
   Return(.T.)
EndIf

//Preciso validar se a quantidade jดpa lan็ada na NF ้ maior ou nใo...nใo pode
cQuery := "SELECT SUM(ZE_QUANT) QUANT"
cQuery += " FROM " + RetSQLName("SZE") + " SZE"
cQuery += " WHERE ZE_FILIAL = '" + xFilial("SZE") + "'"
cQuery += " AND ZE_NF       = '" + cZE_NF       + "'"
cQuery += " AND ZE_SERIE    = '" + cZE_SERIE    + "'"
cQuery += " AND ZE_ITNF     = '" + cZE_ITNF     + "'"
cQuery += " AND ZE_CODFOR   = '" + cZE_CODFOR   + "'"
cQuery += " AND ZE_LOJFOR   = '" + cZE_LOJFOR   + "'"
cQuery += " AND SZE.D_E_L_E_T_ <> '*'"
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)
nQuantSZE := TRB->QUANT
TRB->(DbCloseArea())

dbSelectArea("SD1")
dbSetOrder(1)
dbSeek(xFilial("SD1")+cZE_NF+cZE_SERIE+cZE_CODFOR+cZE_LOJFOR+cZE_PROD+cZE_ITNF,.f.)   

If nQuantSZE + nZE_QUANT > SD1->D1_QUANT
	Help( ,, "HELP","", "Quantidade lan็ada a maior do que item da NF", 1, 0)
	lRet := .F.
EndIf

RestArea(aAreaSD1)
RestArea(aArea)
Return lRet

